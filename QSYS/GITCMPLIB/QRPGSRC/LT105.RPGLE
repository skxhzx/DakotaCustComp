      /copy *libl/qcopysrc,hspecs
600uAH dftactgrp(*NO) actgrp(*NEW)
600rA*----------------------------------------------------------------
600rA*  Multilingual Verision
600rA*  Every screen and message has a corresponding Spanish version.
600rA*  Any changes must be made to both languages.
600rA*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (630) 790-8383
     *----------------------------------------------------------------
     *
     *  LT105     RF Let-Down - Automated
     *  01 March 2000
     *  Max Blacknik
     *
     *  Notes
     *       8 X 40 Screens for hand held scanners
     *       DONE = *ON No more replenishment records exists for the
     *                  department/slot selected, prompt user for qty
     *                  in slot and then create let-down if possible.
     *                  If no let-downs created, display list of slots
     *                  available.
     *
     *  Revisions
     *
414aA*    07/25/00  MLB  4.14a
     *      - Major revisions to program. All other previous changes
     *        have been removed.  All changes will not be documented.
414 A*    08/18/00  MLB  4.14
     *      - Revised SC5 when F12 is pressed to return to previous
     *        screen that was displayed.
414bA*    08/21/00  MLB  4.14b
     *      - Revised ZZRVRS to reverse changes when F12 is selected
     *        for a break down item.
     *      - Revised ZZCHK3 to correct qty test.
     *      - Revised ZZFIL3 to initialize W3BALQ.
     *      - Defined new field CASES in ZZINZ.
     *      - Revised ZZUPD3 to initialize label rcd for putaway.
414cA*    08/22/00  MLB  4.14c
     *      - Revised ZZUPD3 to correctly handle changes in qty
     *        for a break down item.
414dA*    08/23/00  MLB  4.14d
     *      - Revised ZZUPD3 to flag priority replenishment rcds
     *        with a 'D' instead of doing a hard delete.
414eA*    08/23/00  MLB  4.14e
     *      - Revised ZZUPD4 put balance into last slot of put away
     *        when F10=Excpt is pressed from SCREEN8.
414fA*    08/24/00  MLB  4.14f
     *      - Revised pgm to create IDLE transactions only when needed.
414gA*    08/28/00  MLB  4.14g
     *      - Revised ZZUPD4 to removed unneeded REPLTF records.
414hA*    08/29/00  MLB  4.14h
     *      - Revised ZZUPD2 to only create REPLTF records one time.
414iA*    08/30/00  MLB  4.14i
     *      - Created new routine ZZCVDT to be called each time
     *        field TODAY is used in program.
414jA*    09/07/00  MLB  4.14j
     *      - Revised ZZCHK8 to load SLDISP into W8SCAN when item
     *        is found in a virtual slot.
414kA*    09/11/00  MLB  4.14k
     *      - Corrected return to point on excption screen using F12.
     *      - Revised ZZUPD2 to only display Verify Slot screen when
     *        certain conditions are met.
     *      - Revised ZZCKSL to no longer lock VSLOT2 on reads.
     *
415aA*    11/30/00  MLB  4.15a
     *      - Revised ZZCHK2 to check if more than one replenishment
     *        exists for the from slot.
     *      - Revised ZZCHK3 to correct calculation being done for
     *        available qty in the From Slot.
     *      - Revised text of error msg DESC,20.
415bA*    12/13/00  MLB  4.15b
     *      - Revised ZZPAWY to verify slots when slot is empty.
415cA*    01/05/01  MLB  4.15c
     *      - Revised ZZUPD4 when processing an exception, letdowns
     *        will be closed to zero.
415dA*    02/05/01  HNK  4.15d
     *      - Revised to show verify zero screen only when the slot is
     *        physically empty. A new program RTNSTAT created to
     *        return status of a slot.  ZZUPD3 and ZZCHKV routines
     *        changed.  ZZCHKB routine created.
415eA*    03/09/01  MLB  4.15e
     *      - Revised ZZCHK3 to convert replenishment qty to cases qty
     *        when testing quantity pulled for breakdown replenishment.
415fA*    03/23/01  MLB  4.15f
     *      - Revised ZZUPD5 to turn on flag SKPSLT when checking for
     *        existing virtual slots.
415gA*    03/26/01  MLB  4.15g
     *      - Revised ZZUPD5 to write new error code NOTEMTY.
415hA*    04/02/01  MLB  4.15h
     *      - Revised routine ZZUPD4 to correct update error.
415iA*    04/05/01  MLB  4.15i
     *      - Revised ZZSPFC to loop if transaction number read
     *        doesn't match number passed back to program.
415jA*    04/09/01  MLB  4.15j
     *      - Revised pgm to handle break-down replenishments greater
     *        than one case per transaction.
415kA*    04/16/01  MLB  4.15k
     *      - Revised SC1,SC6, SC7 to return to processing letdowns/
     *        priority replenishment loop when F12 is used from specific
     *        slot replenishment SCREEN1.
415lA*    04/17/01  MLB  4.15l
     *      - Revised program to not allow virtual putaway when the
     *        department is set up to use Directed Putaway.
     *      - Added file OPTIOND to program to allow retrieval of *PICK.
415mA*    04/23/01  MLB  4.15m
     *      - Revised program to send a msg to the user when working with
     *        Specific Slot replenishments that new Letdowns/Priority
     *        replenishments have been found.
415nA*    05/02/01  MLB  4.15n
     *      - Revised program to check quantity in pick slot before
     *        updating expiration date, entered date. When updating
     *        expiration dates with qty in the pick slot, the oldest
     *        date will take precedence. If slot is empty, then date
     *        from replenishment slot will be updated.
415oA*    05/15/01  MLB  4.15o
     *      - Revised routine ZZCMD7 to run ZZCHK7 if F7=Specific is
     *        selected.
415pA*    05/21/01  MLB  4.15p
     *      - Revised routine ZZFIL2 to position cursor on W2NQTY if
     *        field is zero.
     *      - Revised routine ZZCHK2 to not allow user to enter zero
     *        for a pull qty when processing letdowns.
     *        Added new msg to array DESC.
415qA*    06/05/01  MLB  4.15q
     *      - Revised routine ZZABRT to remove test for negative
     *        available qty.
415rA*    06/07/01  MLB  4.15r
     *      - Revised routine ZZCLSE to pass warehouse to PT132.
415sA*    06/08/01  MLB  4.15s
     *      - Revised routine ZZCKNS to loop for 702, not 720.
415tA*    06/11/01  MLB  4.15t
     *      - Revised ZZCHK2 to include receive qty's in test to
     *        return leftover product back to From Slot.
     *      - Revised ZZSPFC to run ZZCHK2 when doing Specific
     *        Slot replenishments.
     *      - Revised ZZUPD8 to update receive qty when left over
     *        product being returned to From Slot.
415uA*    06/21/01  MLB  4.15u
     *      - Revised ZZSTRT,ZZSTR2 to loop if label record trans-
     *        action number doesn't match Tran file number.
     *      - Revised ZZSTRT to set on switch if user skipped a let-
     *        down.
     *      - Revised ZZUPD1 to loop around if no more letdowns/ priority
     *        replenishments were found and user skipped a letdown.
415vA*    07/11/01  MLB  4.15v
     *      - Revised ZZPAWY to update SVTRN# with current tran#.
     *      - Revised SC2 to save To slot.
     *      - Revised ZZUPD3 to save To slot.
     *      - Revised ZZUPD4 to update slot field before
     *        calling IT276.
     *      - Revised ZZCKU2 to update PIRTRAN only when time difference.
     *
416aA*    08/23/01  MLB  4.16a
     *      - Revised SC8 to add GOTO when REDSPL is on.
416bA*    08/27/01  MLB  4.16b
     *      - Add SLOT3, ITEMMSC to check multiple pick options.
     *      - Note: IMNRPK can = 0 to allow no pick slots.
416cA*    08/17/01  DAS  4.16c
     *      - Revised ZZFIL2 to create *LETDOWN heading with route
     *        and label status time).
     *      - Added RTEHED file to program.
416dA*    09/05/01  MLB  4.16d
     *      - Revised ZZUPD3 to correctly handle changes to qty's
     *        when doing break down item replen's.
416eA*    02/19/02  MLB  4.16e
     *      - Revised ZZUPD3 to correctly update expiration dates.
416fA*    02/20/02  DAS  4.16f
     *      - Revised to work with DRISLOT interface.
     *      - Added external data structure $SLOT.
     *      - Added routines ZZZD2S, ZZZCOP, ZZZISF, ZZZFS2, ZZZFS3
416gA*    02/27/02  MLB  4.16g
     *      - Revised ZZPAWY to correctly update SLRCV qty's.
     *      - Revised ZZCMD8 to reset PTTASK with saved task value.
416hA*    03/05/02  MLB  4.16h
     *      - Revised ZZSTRT to inizialize working task fields.
     *      - Revised ZZSTR2 to inizialize working task fields.
416iA*    03/29/02  MLB  4.16i
     *      - Revised ZZFIL8 to fill new field W8ORSL with slot
     *        where replenishment originated from.
416jA*    04/23/02  MLB  4.16j
     *      - Revised ZZFIL5 to default W5ZERO to blank instead of
     *        'N'.
416kA*    05/08/02  MLB  4.16k
     *      - Fix - revised SCR02I to reset zero verify flag used in
     *        ZZUPD3
     *
416lA*    06/11/02  DAS  4.16l
     *      - Changed A$LIC# from 7.0 to 15.
416mA*    08/22/02  MLB  4.16m
     *      - Fix: Revised SC7,ZZCMD7 to do setll for PRPLFIL1.
     *      - Fix: Revised ZZNEXT to setll to top and then loop
     *        once more to check for open priority replenishments.
416nA*    08/27/02  MLB  4.16n
     *      - Fix: Revised ZZUPD2 to see if pull qty matches transfer
     *        qty, then prompt user if slot is empty.
416oA*    09/18/02  MLB  4.16o
     *      - Enh: Revised program to allow user to use F8=List to
     *        zero out letdown, create exception with new error code
     *        and log slot to new exception file so that letdowns will
     *        not be created from that location and then show slot
     *        list to user.
     *      - Revised SC2 to add support for F8=List.
     *      - Added new file to program - SLTRPEX.
     *      - Rename SLTRPEX fields to use 'SX'.
     *        Re: $SLOT data structure already using 'SE' prefix.
     *      - Added new routine ZZEXSL to program.
     *      - Revised routine ZZUPD4 to load new exception code.
416pA*    10/02/02  MLB  4.16p
     *      - Fix: Revised ZZCLS0 to not clear LBQALC when closing
     *        transactions to zero.
416qA*    12/04/02  MLB  4.16q
     *      - Enh: Added support to program to prevent product from
     *        being returned to an inactive slot.
416sA*    12/12/02  MLB  4.16s
     *      - Fix: Revised ZZABRT to not abort priority replenishments.
     *        Close transactions to zero. This will result in more
     *        accurate EPM tracking.
     *      - Fix: Revised ZZPAWY to call ADDSTDTRN2 to capture start
     *        date/time for use in creating multiple REPLTF transactions.
     *
417 A*    02/13/03  MLB  4.17
     *      - Fix: Revised ZZCLSE to call new routine ZZENDI to close
     *        any open(inuse) Indirect tasks before closing current
     *        direct task.  Having Indirect tasks still open while
     *        closing the current task was causing the direct task
     *        to be updated with negative direct minutes.
417aA*    04/03/03  RH   4.17a
     *      - Recompiled, ITEMMSC file changed.
417bA*    04/29/03  MLB  4.17b
     *      - Revised ZZCHK3 to use S$AVL1 instead of AVAIL1 when
     *        converting available qty for breakdown replenishments.
     *      - Revised ZZUPD3 to correct calculation of qty change
     *        for breakdown replenishments.
417cA*    05/15/03  MLB  4.17c
     *      - Enh: Added lot/license plate tracking support to program.
417dA*    05/15/03  MLB  4.17d
     *      - Enh: Added support for new Expiration/Entered date update
     *        options.
417eA*    08/11/03  MLB  4.17e
     *      - Enh: Added support for (PPR) Pushback Priority Replenishments.
417EA*    08/20/03  MLB  4.17E
     *      - Fix: Revised ZZUPD3 to not allow expiration dates
     *        less than current date to update pick slot.
417fA*    08/22/03  MLB  4.17f
     *      - Fix - Revise routine ZZCKU2 to READE using partial key
     *        of employee number.  This will prevent incorrect times
     *        from being calculated.
417gA*    09/03/03  MLB  4.17g
     *      - Fix - Revise routine ZZFEAT to turn off *in61. *in61 is
     *        used to condition display of order qty for priority
     *        replenishments.
417hA*    09/15/03  MLB  4.17h
     *      - Enh: Revise program to re-position back to last letdown/
     *        priority replenishment when F12=Cancel is taken from
     *        LT105.01 screen.
417iA*    09/21/03  MLB  4.17i
     *      - Enh: Revise program to remove aisle range checks when
     *        doing Specific Slot Replenishment. Aisle ranges will
     *        only be used to feed Letdowns and Priority Replenishments
     *        to the forklift operator.
417jA*    10/25/03  MLB  4.17j
     *      - Fix - Revise program to fix problem where REPLTF trans-
     *        action was being deleted when user logged an exception
     *        from screen 8 - Balance Putaway.
417kA*    12/08/03  MLB  4.17k
     *      - Enh: Added support for new *VIRTUAL slot options.
417lA*    04/05/04  MLB  4.17l
     *      - Enh: When processing Specific Breakdown item re-
     *        plenishments, always display screen 2. (from slot)
     *        to allow the user to change pull qty.
417mA*    08/11/04  RH   4.17m
     *      - Note: Did not put call to GETSLOTITM in program, code
     *        already loops to find the correct base slot.
417nA*    09/09/04  RH   4.17n
     *      - Note: Removed 'E' option for W7RPLT until license
     *        tracking is in place and tested.  Default W7RPLT to 'N'.
     *
500 A*    10/15/04  DAS  5.00
     *      - Enh: Changed Pushback to FlowRack, Eaches to Breakdown.
     *
500aA*    12/31/04  DAS  5.00a
     *      - Enh: Converted into ILE.
     *
500bA*    01/08/05  DAS  5.00b
     *      - Enh: Revised to call LT210 for license tracking.
     *
500cA*    01/25/05  DAS  5.00c
     *      - Enh: Split *PUTAWAY into *PUTAWYB / *PUTAWYA.
     *
500dA*    02/02/05  DAS  5.00d
     *      - Enh: Converted from legacy DRI into ILE DRI.
     *      - Enh: Change all s$ and a$ fields to $sl and $sa fields.
     *      - Enh: Converted to do all starting/ending of transactions
     *        through ADJTRAN2. PT132 is not used anymore.
     *
500eA*    03/05/05  DAS  5.00e
     *      - *** Removed all old commented code ***
     *      - *** See LT105.0305 for program with commented code ***
     *
500fA*    03/05/05  DAS  5.00f
     *      - Revised ZZUPD2 to update orig label with entered qty.
     *      - Added routine ZZUPD7.
     *      - Revised SC7 to call ZZUPD7, moving appropriate logic
     *        out of SC7 into ZZUPD7. Deleted logic to go along with
     *        500e.
     *      - Revised to check for *SSRPL after call LT107.
     *
500gA*    03/25/05  DAS  5.00g
     *      - Revised ZZUPD3 to set $saorg1 to $saqty1 for %CLSTFROUT.
     *        Re: We only want to reduce the Tfr bucket by the quantity
     *        was put into the Pick slot, not the original quantity pulled
     *        from the overflow slot. If only part of the pulled qty is put
     *        into the pick slot, the remainder will be removed from the
     *        Tfr bucket when it is put away.
     *      - Added check for *PICK when returning from LT210 *PULDROP.
     *
500hA*    03/27/05  DAS  5.00h
     *      - Revised ZZUPD1 to handle non-*OK values when returning from
     *        calling LT210 with *PULDROP.
     *      - Revised ZZUPD4 to reverse *PULDROP.
     *
500iA*    04/07/05  DAS  5.00i
     *      - Fix: Revised to send Enter date in %CLSTFICHG command.
     *      - Revised ZZPAWY to identify if qty is being put back into the
     *        From slot, If so, then we don't have to do a TFRIN and just
     *        send a negative qty with TFROUT to remove it from the Tfr
     *        bucket.
     *      - Revised routine ZZRVRS to use #from fields for From slot upd.
     *      - Revised routine ZZRVRS to use #pick fields for To slot upd.
     *      - Revised routine ZZUPD2 to not update Pick slot when qty chgs.
     *      - Revised routine ZZFIL2 to init UOM values correctly.
     *
500jA*    04/08/05  DAS  5.00j
     *      - Revised to use #fromslitem instead of #ovrfslitem.
     *      - Revised ZZFIL8 to initialize W8ITEM field correctly.
     *      - Revised ZZUPD2 to refresh #from qtys after TFROUT.
     *
500kA*    04/10/05  DAS  5.00k
     *      - Revised call to LT107 to use right adjusted aisles
     *
500lA*    04/11/05  DAS  5.00l
     *      - Revised to do a better job of verifing entered quantites
     *        before trying to use them. In some cases we were getting
     *        an error that  use them. In some cases we were getting a
     *        "target to small" error.
     *
500mA*    04/11/05  DAS  5.00m
     *      - Revised to get tracking information.
     *      - Revised force leftover back to original slot when the
     *        original slot has multiple pallet positions.
     *        Re: This has been done to try and keep all of the pallet
     *        positions of the original slot in synch.
     *
500nA*    04/13/05  DAS  5.00n
     *      - Revised to have user work only with full cases when doing a
     *        Breakdown replenishment.
     *
500oA*    04/13/05  DAS  5.00o
     *      - Revised to not allow the user to enter a replenish qty on
     *        screen2. Program will now skip directly to screen 3.
     *      - Re: This better reflects what a user does for replenishment,
     *        where he takes an entire pallet and does the replenishment.
     *      - Re: Also, this is necessary for keeping the License History
     *        in synch.
     *      - Right now screen 3 is showing a Repl Qty equal to the pulled
     *        quantity.
     *      - For a Breakdown replenishment, a user probably will pull only
     *        the quantity that he wants to replenish, instead of the whole
     *        pallet. Therefore, this method is a little strange for that
     *        situation. Probably needs to be re-examined.
     *
500pA*    04/13/05  DAS  5.00p
     *      - Added condition to ZZASKVERIFY that avail must be zero.
     *      - Revised to use CHG versions of *SLOT commands.
     *      - Revised LT210 logic for screens 3 and 8 in order to handle
     *        Breakdown replenishments correctly.
     *
500qA*    04/21/05  DAS  5.00q
     *      - Revised to update label status to 'C' correctly.
     *
500rA*    04/22/05  DAS  5.00r
     *      - Revised to work with Breakdowns correctly.
     *
500sA*    04/22/05  DAS  5.00s
     *      - Added Side to SC7 and parms sent to LT107.
     *      - Added priority replenishment condition for side. Only takes
     *        affect if aisle range is enterd.
     *
500tA*    04/24/05  DAS  5.00t
     *      - Added flag to indicate first time through SC2.
     *      - Revised to only allow quantity change on SC2 on the first
     *        time through for REPLBK.
     *
500uA*    04/25/05  DAS  5.00u
     *      - Revised ZZNEXT to check for any type of priority replen when
     *        just checking if a replenishment exists.
     *
500vA*    04/28/05  DAS  5.00v
     *      - Revised ZZCHK1 for check that slot is a Fixed Pick slot.
     *      - Revised SC2 to do a *PULRTN instead of an *PULUNDO when
     *        task is not 'REPLBK'
     *
500wA*    04/29/05  DAS  5.00w
     *      - Revised so pull quantity is always put into transit.
     *      - Revised to not be concerned if item is being put back into
     *        slot it was originally pulled from.
     *      - Revised to do PUTAWYA instead of a PULUNDO.
     *
500xA*    04/30/05  DAS  5.00x
     *      - Enh: Added $tnorm1/2/3 parms.
     *
500yA*    05/03/05  DAS  5.00y
     *      - Added LT210 commands *RMVZERO and *RMVZRTN to remove
     *        (inactivate) a zero lichist record.
     *
500zA*    06/15/05  MLB  5.00z
     *      - Fix: Revised ZZUPD3 to update LBSTAT='C' when entire
     *        qty is put into pick slot.
     *
501aA*    06/20/05  MLB  5.01a
     *      - Fix: Revised ZZCLS0 to update LBSTAT='C' when replen-
     *        ishment is skipped, exceptioned or user canceled.
     *
501bA*    06/24/05  DAS  5.01b
     *      - Fix: Revised SC2 to not call PUTAWYA's when sc2first = *ON.
     *        Re: Transit record has not been created yet. Therefore, all
     *        that needs to be done is to put the pallet back into slot.
510bA*    07/12/06  RH   5.10b
     *      - Enh: Revised to check OPBDRP option to call Bulk Drop.
510dA*    02/20/07  JCJ  5.10d
     *      - Enh: Added Replenishment type 'R'.
     *      - Added scrn10 Replenishment type prompt.
510fA*    08/22/07  MLB  5.10f
     *      - Fix: Revised program to initialize $PBAT on call to LT108
     *        with zeros.
510gA*    08/22/07  MLB  5.10g
     *      - Fix: Revised program to loop looking for another *IMMED
     *        replenishment if the one processed didn't yield a valid
     *        replenishment transaction.
510hA*    10/25/07  LMC  5.10h
     *      - Enh: Added 16 X 20 screens for handheld device
     *      - Added scrn10sp Replenishment type prompt was not
     *        added in 510f mod
510iA*    12/07/07  RH   5.10i
     *      - Enh: Added F11 to call transfer program IT252
     *
520aA*    07/02/08  DAS  5.20a
     *      *** Not needed in this version ***
     *      - Enh: Revised to get base slot for pick slot and use
     *        within ZZCHK3.
520bA*    10/22/08  MLB/RH  5.20b
     *      *** Not needed in this version ***
     *      - Fix: Revised ZZCHK8 to add code to not allow an item
     *        to be put into more pick slots than allowed.
520cA*    11/07/08  DAS/RH  5.20c
     *      - Fix: Revised to call ZZRVRS for F12 from screen5.
     *        Change ZZRVRS to use RVREQP & RVPULQ field.
     *        Change to correct leaving stock SLOT tfr qty.
520dA*    12/19/08  RH   5.20d
     *      *** Not needed in this version ***
     *      - Fix: Revised to fix SLTDTE if pick slot had negative #.
520eA*    07/09/09  RH      5.20e
     *      - Fix: Revised to create ITEMADJ adjustment records with
     *        CI code for breakdown type 'B' item replenishment.
520fA*    07/09/09  RH      5.20f
     *      *** Not needed in this version ***
     *      - Fix: Can only return full case qty for breakdown replen.
     *
530 A*    12/03/09  MLB/RH  5.30
     *      - Fix: Revised ZZNEXT to correctly position the pointer when
     *        processing *IMMED (JIT) replenishments. Fixed problem when
     *        replenishment was skipped and then a replenishment was
     *        processed, pointer was incorrectly reset back to top instead
     *        of positioning pointer after last replenishment processed.
530aA*    12/07/09  MLB/RH  5.30a
     *      - Fix: Revised ZZNEXT to add code to unlock PRPLFIL1 when we
     *        exit and we don't find JIT or reg priority replenishments.
530bA*    12/11/09  MLB/RH  5.30b
     *      - Fix: Default W4ITEM to 'Y' so user doesn't need to enterwe
     *
600 A*    07/04/08  DAS  6.00  P#00045
     *      - License Tracking
     *      - LIC version used as base, then 510520 changes added.
     *
600aA*    01/25/08  LMC  5.20a
     *      - This mod is merged from PIRENH510/LT105 mod 500A MLB 01/20/05
     *      - Enh: Revised program to add support for Client id
     *
600bA*    01/25/08  LMC  5.20b
     *      - This mod is merged from PIRENH510/LT105 mod 500B MLB 01/21/05
     *      - Enh: Revised program to call IT231 - Slot listing when
     *        F8=List is selected. IF IT231 returns with *SSR, then
     *        normal F8=List processing continues. Otherwise, screen 2
     *        is redisplayed, leaving Letdown/Priority replen open.
     *
600cA*    01/25/08  LMC  5.20c
     *      - This mod is merged from PIRENH510/LT105 mod 500c MLB 03/21/05
     *      - Enh: Revised program to check file SLOTOUT for an entry
     *        when pick slot is replenished. If positive qty is put into
     *        the pick slot, then the record is deleted from SLOTOUT and
     *        the Runner Flag file is updated to Replenished status.
     *
600dA*    01/25/08  LMC  5.20d
     *      - This mod is merged from PIRENH510/LT105 mod 500d MLB 07/28/05
     *      - Enh: Revised program to include time in heading when
     *        creating Priority Replenishments when sequence number is
     *        negative.
     *
600eA*    01/25/08  LMC  5.20e
     *      - This mod is merged from PIRENH510/LT105 mod 500e MLB 07/28/05
     *      - Fix: Revised ZZNEXT to not reposition to top of priority
     *        replenishment file when using F9=Skip when end of file is
     *        reached. Allow control to return to looking for open
     *        letdowns.
     *
600fA*    01/28/08  LMC  5.20f
     *      - This mod is merged from PIRENH510/LT105 mod 500f MLB 08/01/05
     *      - Enh: Revised ZZUPD1, ZZNEXT to look for Immediate Priority
     *        Replenishments (PRSEQ < 0) before looking for open Letdowns
     *        and then normal Priority Replenishments (PRSEQ >= 0).
     *
600gA*    01/28/08  LMC  5.20g
     *      - This mod is merged from PIRENH510/LT105 mod 500g MLB 08/05/05
     *      - Enh: Change to 5.00c mod. Removed file SLOTOUT from program.
     *        Processing added to pgm RU380.
     *      - Removed requirement to compile pgm with CVTOPT(*DATETIME).
     *        Note at top of program has been deleted.
     *
600iA*    01/30/08  LMC  5.20i
     *      - This mod is merged from PIRENH510/LT105 mod 500i RH 10/26/05
     *      - ENH: Revised routine ZZZZUPD4 to save info to re-start
     *        priority or letdown transaction if F12 from specific
     *        replenish.
     *
600jA*    01/30/08  LMC  5.20j
     *      - This mod is merged from PIRENH510/LT105 mod 500j RH  11/09/05
     *      - Fix: Add code to end IDLE task and start re-start trans
     *        for 500I
     *      - This mod is merged from PIRENH510/LT105 mod 500j RH  11/10/05
     *      - Fix: Add code to set start date/time for original repl when
     *        specific transaction was done instead. (REDATE, RETIME)
     *      - This mod is merged from PIRENH510/LT105 mod 500j RH  11/11/05
     *      - Fix: Add code to set start date/time for idle trans.
     *        to original repl start date/time when F10 specific taken
     *      - Fix: Add code to prevent update PTIMIN to negative #.
     *
600mA*    01/30/08  LMC  5.20m
     *      - This mod is merged from PIRENH510/LT105 mod 500m MLB 01/03/06
     *      - Fix: Revise routine ZZSPFC to check if previous trans-
     *        action is still open before setting back to Inuse status.
     *        If transaction is no longer Open, look for next Re-
     *        plenishment.
     *
600oA*    01/30/08  LMC  5.20o
     *      - This mod is merged from PIRENH510/LT105 mod 500o RH  04/07/06
     *      - Enh: Add call to check for RF Bulk Drop, call RF Bulk
     *        Drop if one exists for department.
     *
600pA*    01/30/08  LMC  5.20p
     *      - This mod is merged from PIRENH510/LT105 mod 500p RH  04/13/06
     *      - Enh: Add call to check "To Slot" quantity if OPCQTY=Y
     *
600qA*    01/30/08  LMC  5.20q
     *      - This mod is merged from PIRENH510/LT105 mod 500q MLB 05/03/06
     *      - Enh: Revised program to add support to process inter-
     *        leaving replenishments while doing putaways.
     *      - Added *entry parm to program. New commands will be
     *        *STDRPL or *INTERLV.
     *
600rA*    01/31/08  LMC  5.20r
     *      - This mod is merged from PIRENH510/LT105 mod 500r JCJ 05/31/06
     *      - Added Multilingual logic.
     *
600sA*    01/31/08  LMC  5.20s
     *      - Fix: Desc table was missing 1 message, and same entries 31/06
     *        were used in both versions for different reasons
     *        added entries to resolve the conflict
     *
600tA*    07/06/08  DAS  5.20t
     *      - Change screen from LT105FM to LT10501.
     *
600uA*    01/29/09  DAS  6.00u
     *      - Revised to work with USR slots.
     *      - Added file workusr
     *      - Revised how parms are sent to IT276 and *IT231
     *
600vA*    03/03/09  DAS  6.00v
     *      - Added wuPulBase to WORKUSR file.
     *      - Added $slPullLcns, $saPullDisp, $saPullBase to c#slot.
     *
600wA*    05/14/09  DAS  6.00w
     *      - Revised to work with LT108 correctly.
     *
600xA*    05/15/09  DAS  6.00x
     *      - Revised zzupd4 (exception) to use %usr2put.
     *
600yA*    05/18/09  DAS  6.00y
     *      - Revised zzcrpr to call LT108 with revised method.
     *
600zA*    06/10/09  DAS  6.00z
     *      - Revised to write $saFrmEmpty to workusr file after
     *        %TFR2USR.
     *      - Revised to use new wupulvfy to determine if 'empty'
     *        screen should be displayed.
     *      - Revised to use %GETCHKVX instead of %GETCHKV. %GETCHKVX
     *        will not count the slot that was sent.
     *
601aA*    06/28/09  DAS  6.01a
     *      - Revised SC5 to call zzrvrs unconditionally at the
     *        beginning of the F12 logic.
     *
601bA*    06/29/09  DAS  6.01b
     *      - Never used.
     *
601cA*    07/01/09  DAS  6.01c
     *      - Revised ZZUPD4 to user w8balq instead of w8nqty.
     *
601dA*    07/01/09  DAS  6.01d
     *      - Revised ZZPAWY2 to send base slot in $sldisp.
     *
610aA*    07/06/09  DAS  6.10a
     *      - Revised zzspfc to delete workusr rec for a brkdn repl.
     *        Re: SC2 is displayed for brkdn repl and it assumes
     *        there is no workusr record.
     *      - Revised $sacitem that is sent for %tfr2usr. We want the
     *        USR slot to end up with the 'From' item, not the 'To item.
     *
610bA*    07/17/09  DAS  6.10b
     *      - Revised to pass in $satask for %usr2put.
     *
610cA*    07/21/09  DAS  6.10c
     *      - Revised to call zsclr at the beginning of program.
     *        Re: For some reason webfacing wasn't clearing the
     *        preceeding screen, even though this is coded like other
     *        programs.
610dA*    07/27/09  DAS  6.10d
     *      - Fix: Do not allow 0 quantity pulled from slot.
610eA*    08/04/09  RH   6.10e
     *      - Enh: Rename screen format to LT105002
     *      - Enh: Add 16 X 20 screens SCREEN72, SCREEN73, SCREEN78
     *      - Enh: Change Y,N to output field WOYN to display Y,N or
     *        1,9 for Saval.
610fA*    11/11/09  DAS  6.10f
     *      - Enh: Revised to send 'To' slot to LT210 for PULDROP.
610gA*    12/09/09  DAS  6.10g
     *      - Enh: Revised zzupd4 to delete workusr record.
     *
610hA*    01/15/10  DAS  6.10h
     *      - Fix: Revised difpck calculation to use w2sltq instead
     *        of w2repq (lbqpck). Re: When the pick slot ti/hi was
     *        less than overflow slot ti/hi, and we only pull the
     *        pick slot ti/hi qty, the program would thought we were
     *        pulling the entire qty from the overflow slot because
     *        the label record contained the pick slot ti/hi qty.
     *        Thus, license tracking would get messed up.
     *
610iA*    08/03/10  DAS  6.10i
     *      - Added phrase logging.
610jA*    08/05/10  RH   6.10j
     *      - Fix: Set value of curlic# in ZZGET2, was calling LT210
     *        with ' ' license and causing LCNS exception.
610kA*    09/01/10  JCJ  6.10k
     *      - Changed to allow specific slot replenishment for slots
     *        with a status of 'RP'.
610lA*    10/20/10  RH   6.10l
     *      - Fix: Change ZZUPD1 to call LT210 with *PULDROP for JIT
     *        replenishmends, was skipping LT210 process.
610mA*    11/23/10  MLB/RH   6.10m
     *      - Fix: Change ZZUPD2 to correctly update label record when
     *        entire qty is pulled from the pick slot. Label rcd was
     *        not being updated which caused pgm to display LT105.08
     *        screen even though entire qty was replenished into break-
     *        down item.
610nA*    12/14/10  MLB/RH   6.10n
     *      - Fix: Change ZZUPD3 to correctly set $TPARTIAL flag when
     *        there is no change in replenish qty, but more qty is
     *        pulled than replenished.  The pick slot was being
     *        updated with the pulled license not a '*PS' license     -
     *        The return qty was bing assinged a '*EX' extra license. -
640aA*    04/11/11  DAS  6.40a
     *      - Fix: Revised routine zzspfc to not call zzchk2 when
     *        pttask = REPLBK.
640bA*    08/22/11  RH   6.40b
     *      - ENH: Display scren6a, scren66a, scn6asp, scn66asp if
     *        no open JIT replenishments are left.
     *        Rename format member to LT10503
640c *    08/25/11  GJA  6.40c
     *      - Fix: Revised process to zero verify pull slot after
     *        WORKUSR record is removed.
640d *    02/09/12  RH   6.40d
     *      - Enh: Set LT210 heading to 'Replenish JIT' for JIT replen
640e *    04/26/12  RH   6.40e
     *      - Enh: Get current from slot quantites, display error
     *        if quantities are no longer valid.  To prevent user
     *        from continuing when quantity is no longer available.
640f *    05/07/12  RH   6.40f
     *      - Fix: Do not get from slot quantities for IT276,
     *        qty already moved to USR slot in IT276.
640g *    05/30/12  LMC  6.40g
     *      - Fix: Slot def with max pos > 1 was falling out of the
     *        zzaskzrovfy routine. It wasn't taking into consideration
     *        only if there were virtual slots.
     *      - Fix: In zzaskzrovfy added a check on the $slstat.
     *        Logic needed to leave only if it found an active slot.
640hA*    06/18/12  RH/MLB  6.40h
     *      - Fix: Revised program to correctly set curlic# with pull
     *        license from WORKUSR3 when returning from specific slot
     *        replenishments.
     *      - Note:Had original license even when new lic# created in
     *        in IT276, overflow had partial qty allocated for bulk
     *        created new lic to replenish available quantity.
640iA*    06/19/12  RH      6.405
     *      - Fix: Set RTNORIG to $SAEXCD in ZZUPD8 to update license
     *        quantity correctly when returning extra qty to original
     *        slot.  Slot was correct, license qty was being replaced
     *        when from slot had qty allocated.
640jA*    06/05/12  LMC     6.40j
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
640kA*    07/20/12  RH      6.40k
     *      - Fix: Do not display SC6, no more JIT, displays after
     *        each LOW tracked item priority replenishment.
640lA*    11/14/12  DAS  6.40l
     *      - Fix: Revised zzchk8 to send $saPullDisp to DRISLOT.
640mA*    11/13/12  RTR     6.40m
     *      - Fix: if tie or high > 999, so will not error when 1000+
640nA*    12/12/12  LMC     6.40n
     *      - Fix: The call to zzzdricop in subr ZZSPFD needs to be
     *      conditioned on the IT276FLAG being off, otherwise the
     *      from slot disp that is returned from IT276 gets trashed.
     *      Leaving the specific slot replenishment transaction in an
     *      ended status, also leaving the product in the USR slot.
     *
650aA*    03/02/13  DAS  6.50a
     *      - Revises to save date/time of %TFR2 and use it for the
     *        'from' ITEMADJ record if the item is changed. This is
     *        done so record can be connected back LICLOG record.
650bA*    07/09/13  RBD  6.50b
     *      - Renamed format member to LT10504.
     *      - Fix: F4 prompts were not pointing to the correct rows
     *        and columns.
     *      - Enh: Added logic to look for JIT every time a priority repl
     *        is completed, and if found, show it to user, rather than
     *        cycling through all of the repl's before going back to the
     *        beginning to start over with JIT's.
     *      - Enh: Added logic to look for JIT every time a spec slot repl
     *        is completed, and if found, display a screen telling the
     *        user one exists with an option to go into JIT's as if he
     *        went back to the first screen and pressed Enter.
     *      - Enh: Added zzupd7All and zznextAll to process *ALL repl
     *        types and/or dept's. When all dept's are selected, ignore
     *        Aisle and Side entries. Do all the JIT's first in dept order.
     *        Once you've done all the JIT's and are doing normal repl's,
     *        still check for new JIT's and show them when found.
     *      - Enh: When a user does a specific slot repl and a JIT or
     *        priority repl exists for the overflow slot just used,
     *        delete it.
650cA*    03/08/13  MLB  6.50c
     *      - Fix: Revised pgm to check if value loaded into exqty > 999
     *        and if yes, then set exqty = 999. Error found at Get
     *        Fresh who stores watermelon in lbs in qty fields.
650d *    03/08/13  GJA  6.50d
     *      - Reserved, revisions to come.
650eA*    07/18/13  RBD  6.50e
     *      - Fix: If user skips record on screen2, add it to whdp_seq.
     *        If dept *ALL, wrap back around to the beginning if user
     *        skips the last replenishment.
650f *    11/24/13  KDE  6.50f
     *      - Update calling program after return from LT107
650g *    01/15/14  RH   6.50g
     *      - Fix: Change 640e mod to use available qty in place of
     *        (stock + receive qty) we no longer user RCV buckets
650h *    06/19/14  KDE  6.50h
     *      - Enh: Modify to handle Production Type Replenishments
650i *    09/08/14  LMC  6.50i
     *      - Enh: When a user does a specific slot repl and a JIT or
     *        priority repl exists for the pick slot just used,
     *        delete the first priority or JIT with PRFLAG = 'S'
650j *    09/24/14  LMC  6.50j
     *      - Fix: Initialize wocol and worow when we are filling
     *        screen3, otherwise the program is positioning to the
     *        last worow/wocol from the last call to APICVTSLT
650k *    11/04/14  RBD  6.50k
     *      - Added new *REPLEN option OPSKPR, Skip if pick slot physical
     *        quantity is greater than item replenishment level. In
     *        addition, item replenishment level must be greater than zero.
     *        Do not do this check for Specific Slot Replenishments.
650l *    12/16/14  RBD  6.50l
     *      - Fix: increased size of idx (number of skips) and array
     *        whdp_seq because Coastal skipped more than 99 times and
     *        caused target too small error.
650m *    03/02/15  RBD  6.50m
     *      - Added new *REPLEN option OPJITW. During specific slot repl
     *        if this option equals N don't bother checking for JIT's as
     *        the user does not want the JIT notification window.
650n *    03/09/15  RBD  6.50n
     *      - Fix: The it276flag is used to create the USR slot and license
     *        for REPLBK because it gets deleted in zzwrkdel which is
     *        called from zzspfc for REPLBK.  The flag was being turned off
     *        unconditionally in zzspfc but should not have been turned
     *        off there for breakdown repl's task REPLBK.  For specific
     *        slot REPLBK the flag should be turned off in sc2 after
     *        zzchk2.  Before this fix the flag was not on for specific
     *        slot REPLBK in zzchk2 and it was causing error PIR0153
     *        "Slot qty changed unavailable for replenishment", this edit
     *        should be bypassed for spec slot REPLBK repl's.
700a *    04/23/15  LMC  7.00a
     *      - Fix: The transaction pieces were not being populated
     *        correctly if the user replenished a qty different then
     *        the original replenish qty showing on screen3. Added an
     *        adjustment routine to handle this situation.
     *      - Fix: The REPLTF was being updated twice with the qty
     *        that was replaced from screen8. Removed the extra update
     *        of the transaction record, and let ZZTRNUPDATE remain
     *        the same which was handling the update of pirtran.
700b *    05/11/15  RH   7.00b
     *      - Rename format member to LT10505
     *      - Fix: Move ordq to left side of screen so 20 character
     *        screen can see without shifting screen, move fields down
700c *    08/05/15  RH   7.00c
     *      - Fix: zzupawy3-W8balq was already reduced before call to
     *        LT210.  F12 cancel was leaving remain qty wrong and qty
     *        stuck in USR slot with NO license (*NONE)
700d *    01/08/16  RH   7.00d
     *      - Fix: rename screen format to LT105.06 incrreased W3Tie
     *        field length
700eA*    07/21/16  LMC  7.00e
     *      - Reserved - UCI Tracking
700fA*    09/21/16  TAB  7.00f
     *      - Added new code when from slot has been changed in program
     *        LT210 via different licence being pulled.
     *
700gA*    10/20/15  MLB/RBD  7.00g
     *      - Fix: Revised routine ZZNEXT to set PRWHSE, PRWHDP with
     *        values from screen 7. First time in and no replenishments
     *        processed, JIT replenishments weren't being displayed.
700hA*    05/20/16  JCJ  7.00h
     *      - Enh: Add logic to execute new FKey=F14 process: Display
     *        Pick Slots with qty less than xx cases and having
     *        available stock to replenish it.
     *
710aA*    04/20/17  DAS  7.10a
     *      - Enh: Revised to skip a replenishment record if another
     *        replen exists for the same item with a better FIFO date.
     *      - Currently, Renzi is the only one using this.
     *      - Added file PRPLFIL9.
     *      - Added routine zzchkfifo.
710bA*    04/21/17  DAS  710b
     *     - Removed file slot2, as it was no longer being used.
710cA*    05/19/17  RH   710c
     *     - Fix: add code to remove JIT or replen for specific when
     *       partial qty replenished.  Moved 650i mod to ZZDELRPL
     *
710dA*    06/14/17  LMC  710d
     *     - Fix: Disable F10 key on screen 8, if an error was
     *       encountered on the slot being entered in the RtnTo field.
     *     - Renamed display file LT10506 to LT10507.
710eA*    06/27/17  NLK  7.10e
     *      - ENH: Don't allow Replen if From and To Slots are the
     *        same, selector accidently scanned same slot. Screen 2
     *     - Renamed display file LT10507 to LT10508.
710fA*    07/31/17  NLK  7.10f
     *     - ENH: Display the JIT screen after screen8 from a
     *       partial qty replenished.
     *     - TPC request (waiting for them to approve.)
710gA*    08/14/17  NLK  7.10g
     *     - FIX: remove forcing rtnhom, was always putting rmdr back
     *     - ENH: add JIT if remainder moving to diff slot
     *     - TPC request (waiting for them to approve.)
710hA*    08/30/17  MLB  7.10h
     *     - FIX: Revised routine, ZZUPD7ALL to bypass any rcds where
     *       PRFLAG = 'D'. Was causing LT107 to be called repeatedly
     *       and having to display LT107.07 screen that no more replen's
     *       were available to process. Only way to exit was to press F3
     *       or Enter until rcds were exhaused and then pgm would look
     *       for regular replenishments.
710iA*    09/25/17  KDE  710i
     *     - Fix: change data structure name for *FEATURE option
     *       Field OPFEAT was getting overwritten because DS named
     *       as record format for options (OPDATA).  This was impacting
     *       how Repl Qty was being calculated
     *
720a *    02/27/18  LMC  720a
     *     - Enh: Allow user to scan a license instead of scanning the
     *       pick slot to start the specific slot replenishment.
     *       This is conditioned on a new field in the *REPLEN record
     *       that must be *on to use the license scanning feature.
     *     - We are also sending the licactive display field to IT276
     *       as an additional parm, so we can use that display field
     *       to automatically select the from slot.
     *     - Renamed display file from LT10508 to LT10509.
     *
720bA*    02/21/18  KDE  7.20b
     *      - Enh: Modify to handle On-Site Store Replenishments
     *      - Enh: IT276 can now return code STRNOSTK meaning no
     *        stock found in Store when the Specific Slot scanned
     *        as Pick Slot to fill is a Store slot.  In this case
     *        we will display message stating such and create a
     *        Priority Replenishment
     *
720cA*    03/12/18  KDE  7.20c
     *      - Enh: Modify Replen type program defined table
     *
720dA*    03/16/18  KDE  7.20d
     *      - Fix: Specific Slot Replen had problem introduced with
     *        mod 720a when pick slot scanned has more than one item
     *        in the slot.  It should only skip the has virtual
     *        indicator when the license was TRUELY scanned.
720eA*    04/27/18  MLB  7.20e
     *     - Enh: Recompiled pgm due to change to PRPLFIL10. Added
     *       Add date/time to end of keys. Ensure that oldest JIT's
     *       are displayed first.
720fA*    04/29/18  MLB  7.20f
     *     - Enh: Change to 7.20a. If Scan License option wasn't turned
     *       on the value from scan field wasn't loaded into W1TDISP
     *       and then causing the pgm to log an error that the slot
     *       doesn't exist.
720gA*    05/17/18  KDE  7.20g
     *     - Enh: Change to allow user to scan license to run Specific
     *       slot when not a Store Staging Replenishment
720hA*    07/21/16  LMC  7.20h
     *      - Reserved - UCI Tracking
720iA*    12/23/18  KDE  7.20i
     *     - Fix: Remove mod 720g.  This was confused with mod in IT276.
     *       Should only allow user to scan license if Staging Replenishment
     *       identified by aisle RPA.
720jA*    01/10/19  DAS  7.20j
     *     - Fix: Revised to calculate adjustment cube when doing a
     *       breakdown replenishment.
730aA*    05/31/19  LMC  7.30a
     *     - Fix: Clear out the ladisp field if a slot is entered.
730bA*    08/26/19  KDE  7.30b
     *     - Fix: Change Production Replen type to 'O'
740 A*    08/18/20  KDE  7.40
     *     - ENH: Add Drop Picks message in Red under Replenishments
     *       if drop picks exist for warehouse, and department
750aA*    05/05/21  RH   7.50a
     *     - Fix: use edited display from APICVTSLT for double scan.
     *
750bA*    08/20/21  RBD  7.50b
     *     - Reserved.
     *
750cA*    09/22/21  DAS  7.50c
     *     - Added *APT to ZZZDRICOP.
     *     - Revised APT logic to call ZZZDRICOP instead of APTMAIN.
     *     - Revised ZZUPD3 to send *RPLEND3 instead of *RPLEND to APT
     *       for a Full replen. DRIAPT will use this to indicate that
     *       KVI-1-Pallet should be set to 1 for the *RPLEND record.
750dA*    01/15/21  RH   7.50d
     *     - Added 730c previous fix missed.
     *    12/13/19  KDE (was 7.30c)
     *     - Fix: Return Full Slot form Less Than 5 Qty when not Cheneyk
750eA*    02/23/22  RH      7.50e
     *     - Fix: Test if replenishment meets aisle criteria
     *       when Repl type = A All before calling LT107
770bA*    05/05/23  RH      7.70b
     *     - Fix: change to use W7Whse/W7Whdp as parms for OR688
     *
     *----------------------------------------------------------------
     *
     *  Client Custom Revisions:
     *
     *  CHENEY
CHY A*    08/01/00  DAS  CHY
     *      - Revised format to split slot input field(s).
     *      - Data structure was added to handle the combining of
     *        slot input field(s).
     *        This was done because Symbol scanners only scan into
     *        the first position of a field instead of where the
     *        cursor lies. Therefore, in order to do double scanning
     *        the slot field had to be split into two parts with 1
     *        character inbetween. Program APICVTSLT was modified
     *        to handle the positioning correctly.
CHY2A*    08/02/00  DAS  CHY2
     *      - Revised split fields to 7 and 5 characters, respectively.
CBIaA*    09/12/03  DAS  CBIa
     *      - Revised SC6 to return to screen 7 when Enter pressed.
     *        In future we should look at having F5 check to see if
     *        any new letdowns exist.
CBIbA*    09/30/03  MLB  CBIb
     *      - Revised SCR02I to accumulate total remaining Priority
     *        Replenishments and display total on screen 2. Added
     *        file PRPLFIL5 to program.
CBIcA*    04/14/04  MLB  CBIc
     *      - Revised program to no longer log entries into the
     *        slot replenishment exception file SLTRPEX.
CBIdA*    02/24/05  DAS  CBId
     *      - Revised to display Letdowns in pick slot order based
     *        on new flag LETORD.
CBIeA*    06/28/05  MLB  CBIe
     *      - Fix to CBId. Revised ZZUPD1 to reset WKRTPO back to '0'
     *        after successful return from LT108. when sequence is SLOT.
     *        Priority Replenishment transaction wasn't being picked
     *        up after skipping through all Letdowns.
     *        Revised ZZUPD1 to clear RPLTYP when no more Priority
     *        replenishments are found and restart looking for letdowns
     *        from the beginning when sequence is SLOT.
CBIfA*    09/21/05  MLB  CBIf
     *      - Fix to CBId. Revised ZZSTRT to loop and read next LABEL12
     *        record if transaction number is not found when in
     *        slot mode.
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Line
CLDaA*    04/12/11  RH   CLDa
     *      - Revised to use 'BK' adjustment code for brk repl.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Finkle Distributors
FKLaA*    07/09/08  RH   FKLa
     *      - Revised to zero verify aisle TRL slots or 95-101 slot
     *----------------------------------------------------------------
     *  Client Custom Revisions: Glazier
GFCa *    02/21/11  GJA  GFCa
     *      - Enh:  default quantity with pulled quantity
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greenleaf Produce
GLP A*    04/10/13  LMC  GLP.a
     *      - Enh: Use 1,9 for Y,N because of handheld RF keys.
     *        same as saval mod SLVb.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jack Palmer Foodservice
JPF A*    04/02/07  MLB  JPF
     *      *** Not needed in this version ***
     *      *** Done in DRISLOT ***
     *      - Revised to allow virtual pick slots to be created on
     *        slots with SPCL designation only.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval
SVLaA*    08/04/09  RH   SVLa
     *      - Revised to use new 16 X 20 screens for 16 line RF.
SVLbA*    08/14/09  RH   SVLb
     *      - Revised to use 1,9 in place of Y,N choice.
SVLcA*    02/17/14  RH   SVLc
     *      - Add screen11 to use 1,9 in place of Y,N choice.
     *----------------------------------------------------------------
     *  Client Custom Revisions: YHata
YHA A*    02/26/08  RH   YHA
     *      - Revised to only display replenishments with from and to
     *        aisle = 61 if aisle range is 61 to 61.  Special for high
     *        density aisle.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Renzi
RNZaA*    04/21/17  DAS  RNZa
     *      - Revised to use new 710a zzchkfifo routine.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: SGC Foodservice
SGC A*    07/18/17  MLB  SGC
     *      - Revised to use new 710a zzchkfifo routine.
     *      - Added SGC to RNZa/7.10a mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Holt Paper
HPCaA*    06/16/20  RH   HPCa
     *      - Enh: Use '2 ' adj code for brk repl. Add to CLD mod
     *----------------------------------------------------------------
     *  Client Custom Revisions: Presto Foods
     *
PFCa *    08/14/20 RTR PFCa
     *      - Enh: Add support to program to capture information
     *        needed for APT Interface.
     *
PFCb *    10/21/21  DAS  PFCb
     *      - Enh: Revised screen 2 to fill in From slot, w2scan.
     *      - Enh: Revised screen 8 to fill in quantity to put away.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
416oM*  70        Specific slot replenishments - F7,F8,F9 not avail.
CBIbA*  74        EOF on read to file PRPLFIL5.
416oA*  76        Error indicator on write to SLTRPEX.
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------

600uA*----------------------------------------------------------------
600uA*  Binding Directories
600uA*----------------------------------------------------------------
600uA
600uAHbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

600tDF*t105fm   cf   e             workstn
610eDF*t10501   cf   e             workstn
640bDF*t10502   cf   e             workstn
650bDF*t10503   cf   e             workstn
700bDF*t10504   cf   e             workstn
700dDF*t10505   cf   e             workstn
710dDF*Lt10506  cf   e             workstn
710eD *Lt10507  cf   e             workstn
720aDF*Lt10508   cf   e             workstn
740 DF*Lt10509   cf   e             workstn
740 MFLt10511   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
510hAF                                     sfile(m16rec:msgk)
5203AFitemadj   o    e           k disk
     Fitemdef   if   e           k disk
     Fitemlnk   if   e           k disk
416bAFitemmsc   if   e           k disk
     FLabel     uf a e           k disk
     FLabel7    if   e           k disk
415lAFoptiond   if   e           k disk
     Foptions   if   e           k disk
     Fpiritem   if   e           k disk
     Fpirtran   uf a e           k disk
     Fpirtran1  if   e           k disk
     F                                     rename(ptrec:ptrec1)
     Fpirtran2  if   e           k disk
     F                                     rename(ptrec:ptrec2)
     Fpirtran3  if   e           k disk
     F                                     rename(ptrec:ptrec3)
     Fprplfil1  uf   e           k disk
CBIbAFprplfil5  if   e           k disk
CBIbAF                                     rename(prrec:prrec5)
650bAFprplfil10 uf   e           k disk    rename(prrec:prrec10)
650bAFprplfil11 uf   e           k disk    rename(prrec:prrec11)
650iAFprplfil3  uf   e           k disk    rename(prrec:prrec3)
     F                                     prefix(pr_)
740 AFprplfil6  if   e           k disk    rename(prrec:prrec6)
     F                                     prefix(dd_)
710aAFprplfil9  if   e           k disk    rename(prrec:prrec9)
710aAF                                     prefix(p9_)
     Fslot1     if   e           k disk
     F                                     rename(slrec:slrec1)
416bAFslot3     if   e           k disk
     F                                     rename(slrec:slrec3)
     Fslotdef   if   e           k disk
600gD*SLOTOUT UF  E           K        DISK
     Ftask      if   e           k disk
     Ftaskdet   uf   e           k disk
     Fvslot1    uf   e           k disk
     Fvslot2    uf a e           k disk
     F                                     rename(vsrec:vsrec2)
416cAFrtehed    if   e           k disk
     Fitmexcp   o    e           k disk
416oAFsltrpex   uf a e           k disk
CBIdAFLabel12   if   e           k disk
CBIdAF                                     rename(lbrec:lbrec12)
600uAFworkusr3  uf a e           k disk
600uAF                                     rename(wurec:wurec3)
720aAFlicactive if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a2n             s              1    dim(2)
     D a10             s              1    dim(10)
650lDD*whdp_seq        s             11    dim(99)
650lMD whdp_seq        s             11    dim(2000)
500lDD**esc            s             50    dim(25) ctdata perrcd(1)
500sDD**esc            s             50    dim(26) ctdata perrcd(1)
600sDD*desc            s             50    dim(27) ctdata perrcd(1)
650bDD*desc            s             50    dim(31) ctdata perrcd(1)
700hDD*desc            s             50    dim(33) ctdata perrcd(1)
700hMD desc            s             50    dim(34) ctdata perrcd(1)
     D hnd             s              2    dim(702)
     D ltr             s              1    dim(27) ctdata perrcd(27)
600sDD*descsp          s             50    dim(27) ctdata perrcd(1)
650bDD*descsp          s             50    dim(31) ctdata perrcd(1)
650bMD descsp          s             50    dim(33) ctdata perrcd(1)
600aA*----------------------------------------------------------------
600aA*  Customer id
600aA*
600aAD @getcl          c                   const('GETCLIENT')
600aA*
600aA /COPY QCOPYSRC,ID#CHENEY
600aA /COPY QCOPYSRC,ID#BIRITE
ADWaA /COPY QCOPYSRC,ID#ANDREWS
JPF A /COPY QCOPYSRC,ID#PALMER
FKLaA /COPY QCOPYSRC,ID#FINKLE
YHA A /COPY QCOPYSRC,ID#YHATA
SVLaA /COPY QCOPYSRC,ID#SAVAL
CLDaA /COPY QCOPYSRC,ID#CITYLIN
GFCaA /COPY QCOPYSRC,ID#GLAZIER
GLPaA /COPY QCOPYSRC,ID#glp
710aA /COPY QCOPYSRC,ID#RENZI
SGC A /COPY QCOPYSRC,ID#SGC
HPCaA /COPY QCOPYSRC,ID#HPC
PFCbA /COPY QCOPYSRC,ID#PFC
600fA*
600fA*  Priority Replen. Type: *IMMED, *NORMAL.
600fAD                 ds
600fAD  prptyp                 1      8
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
416cAD                 ds
416cAD  lbstim                 1      6  0
416cAD  stath                  1      2
416cAD  statm                  3      4
416cAD  stats                  5      6
600dAD                 ds
600dA*  Add time from Priority Replenishment file.
600dAD  pratim                 1      6  0
600dAD  prath                  1      2
600dAD  pratm                  3      4
600dAD  prats                  5      6

600dA*----------------------------------------------------------------
500dA*  DRI parameters
500dA*----------------------------------------------------------------
500dA
500dA /COPY *libl/qcopysrc,C#DRIPARMS
500dA
500dA*----------------------------------------------------------------
500dA*  Data Formats
500dA*----------------------------------------------------------------
500dA
750cA /COPY *libl/qcopysrc,C#APT
720bA /COPY *libl/qcopysrc,C#PRTYRPL
500dA /COPY *libl/qcopysrc,C#ITEM
500dA /COPY *libl/qcopysrc,C#SLOT
500dA /COPY *libl/qcopysrc,C#SLOTDEF
500dAD saveVer#        s                   like($slver#)
500dAD save$slot       s                   like($slot)

600uA*----------------------------------------------------------------
600uA* Function prototypes.
600uA*----------------------------------------------------------------
600uA
600uA /copy qcopysrc,p.bfcdteti
720aA /copy qcopysrc,p.IT278
640jA*----------------------------------------------------------------
640jA*  Prototypes
640jA*----------------------------------------------------------------
640jA
640jAD wrttran1        pr                  extpgm('WRTTRAN1')
640jA * Input
640jAD   ppcmd                        8
640jAD   ppwait                       2  0
640jAD   ppwhse                       3  0
640jAD   pptran#                      7  0
640jAD   ppfromdate                   8  0
640jAD   pptodate                     8  0
640jAD   ppemp#                       5  0

CHY A*----------------------------------------------------------------
CHY A*  Slot redefinition
CHY A*
CHY AD                 ds
CHY AD  w1tdis                 1     12
CHY2MD  w1tds1                 1      7
CHY2MD  w1tds2                 8     12
CHY AD                 ds
CHY AD  w2scan                 1     12
CHY2MD  w2scn1                 1      7
CHY2MD  w2scn2                 8     12
CHY AD                 ds
CHY AD  w3scan                 1     12
CHY2MD  w3scn1                 1      7
CHY2MD  w3scn2                 8     12
CHY AD                 ds
CHY AD  w8scan                 1     12
CHY2MD  w8scn1                 1      7
CHY2MD  w8scn2                 8     12
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1    100
600uDD**$whse                  1      3  0
600uDD**$itemds                4     18
600uDD**$home                 19     30
600uDD**$disp                 31     42
600uDD**$lbl#                 43     49  0
600uDD**$trn#                 50     56  0
600uDD**$bat#                 57     63  0
600uDD**$lalwc                47     47
600uDD**$prg#                 64     73
600uDD**$pllp#                74     88
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     D  $pwhse                19     21  0
     D  $pwhdp                22     26
     D  $pfail                27     29
     D  $ptail                30     32
     D  $pseq#                33     37  0
     D  $ptrn#                38     44  0
     D  $pfeat                45     45
417eAD  $prplt                46     46
417eAD  $pcrtt                47     47
417eAD  $pbat#                48     51p 0
417eAD  $plbl#                52     55p 0
     *
     *----------------------------------------------------------------
     *  Called programs
     *
600fAD @crtpr          c                   const('LT108')
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
     D @addtr          c                   const('ADDSTDTRN')
     D @addt2          c                   const('ADDSTDTRN2')
     D @adjtd          c                   const('ADJTSKDET')
     D @adjtr          c                   const('ADJTRAN  ')
     D @llptr          c                   const('UPDLLPTRK')
700hAD @lessthan5      c                   const('LT111CL')
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D  dsukey                 1     50
     D  prwhse                 1      3  0 inz(0)
     D  prwhdp                 4      8
     D  prfail                 9     11
     D  prtail                12     14
     D  prseq#                15     19  0 inz(0)
     *----------------------------------------------------------------
     *  Called program parameters
     *
     *
600qA*
600qAD $sparm          ds
600qAD  $scmd                  1      8
600qAD  $sprg                  9     18
600qAD  $suky                 19     68
600qAD  $srtn                 69     76
600qAD  $serm                 77    136
600qAD  $smsg                 77     80
600qAD  $stype                81     88
600qA*
600qA*   Redefine key
600qA*
600qAD  $swhse                19     21  0
600qAD  $swhdp                22     26
600qAD  $stasl                27     29
600qAD  $stloc                30     32  0
600qAD  $stlvl                33     34  0
600qAD  $sthnd                35     36
600qAD  $sdisp                37     48
600qAD  $strn#                49     55  0
600qAD  $srplt                56     57
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
     *
     D  $lwhdp                22     26
     D  $litem                27     41
     D  $ldisp                42     53
     D  $lzero                54     54
416qAD  $lstat                59     60
     D  $ltrn2                55     61  0
     *
510i D  $ldsp2                54     65
     *
     D  $lrte                 22     26
     D  $lpo                  27     35
     D  $ltrn#                36     42  0
     *
     D  $litm2                22     36
     D  $ltdsp                37     48
     D  $lfdsp                49     60
     *
     D  $ldsp1                27     38
     D  $litm1                39     53
414eA*
414eAD  $ldesg                19     23
414eAD  $ltyp                 24     24
     *
600gD*                                      39  39 $LNWST
600gAD  $litm3                39     53
417cAD  $llot                 37     37
417cAD  $lltrk                38     38
417eA*
417eAD  $lfas                 27     29
417eAD  $ltas                 30     32
417eAD  $lrplt                33     33
500sAD  $lside                34     34
600oA*
600o D  $lbsts                27     28
     *
500mAD  $lwhse2               19     21  0
500mAD  $ltrackitem           22     22
500mAD  $ltrackpos            23     23
500mAD  $lposmrg              24     24
500mAD  $lposrtn              25     25
500mAD  $lpsplit              26     26
500mAD  $ltsplit              27     27
     *
600uAD  $lwhse3               19     21  0
600uAD  $litem3               22     36
600uAD  $lalwc3               65     65
417cA*
417cA*----------------------------------------------------------------
417cA*  LICHIST - License history (Input Data)
417cA*
417cAD $rparm          ds
417cAD  $rwhse                 1      3  0
417cAD  $rltrn                 4      7p 0
417cAD  $racfl                 8      9
417cAD  $rtrn#                10     13p 0
417cAD  $rlbl#                14     17p 0
417cAD  $rlcns                18     32
417cAD  $rfmlc                33     47
417cAD  $rorlc                48     62
417cAD  $rlqy1                63     66p 0
417cAD  $rlqy2                67     70p 0
417cAD  $rlqy3                71     74p 0
417cAD  $raqy1                75     78p 0
417cAD  $raqy2                79     82p 0
417cAD  $raqy3                83     86p 0
417cAD  $rfmcd                87     87
417cAD  $rfara                88    102
417cAD  $rfwhd               103    107
417cAD  $rfasl               108    110
417cAD  $rfloc               111    113  0
417cAD  $rflvl               114    115  0
417cAD  $rfhnd               116    117
417eAD  $rfslp               118    119p 0
417cAD  $rtocd               120    120
417cAD  $rtara               121    135
417cAD  $rtwhd               136    140
417cAD  $rtasl               141    143
417cAD  $rtloc               144    146  0
417cAD  $rtlvl               147    148  0
417cAD  $rthnd               149    150
417eAD  $rtslp               151    152p 0
417cAD  $rtord               153    156p 0
417cAD  $rtseq               157    159p 0
417cAD  $rexcd               160    167
417cAD  $radts               168    193
417cAD  $raemp               194    196p 0
417cAD  $rausr               197    206
417cAD  $rajob               207    216
417cAD  $rajbn               217    222
417cAD  $rcdts               223    248
417cAD  $rcemp               249    251p 0
417cAD  $rcusr               252    261
417cAD  $rcjob               262    271
417cAD  $rcjbn               272    277

500bA*----------------------------------------------------------------
500bA*  LT210 parameters
500bA*----------------------------------------------------------------

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
500xAD  $tnorm1        s              5  0
500xAD  $tnorm2        s              3  0
500xAD  $tnorm3        s              3  0
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
610fAD  $ttoslot       s             12
720hAD  $tpartime      s               Z

417cA*----------------------------------------------------------------
417cA*
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
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
     *----------------------------------------------------------------
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
     *----------------------------------------------------------------
     *  API programs
     *
     D @apics          c                   const('APICVTSLT ')
417cA*
417cA*----------------------------------------------------------------
417cA*  Working fields.
417cA*
417cAD                 ds
417cAD  lottrk                 1      4
417cAD  lictrk                 5      8
417cAD  llptyp                 9     16
417cAD  savllp                17     31
     D llp01           c                   const('Scan lic nbr:     ')
     D llp03           c                   const('Scan new lic#:    ')
     D llp05           c                   const('Original lic#:    ')
417cA*
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erwhse                 1      2p 0
     *
     D  erfld                  1     30
     *
     D  erqty                  1      4p 0
     D  ernqty                 5      8p 0
416bA*
416bAD  ernpck                 1      3p 0
416bAD  erapck                 4      6p 0
     *
     D  erfmsl                 1     12
     D  ertosl                13     24
414eA*
414eAD  eritdp                 1      5
414eAD  erslds                 6     17
414eAD  ersldp                18     22
414eAD  eritsc                23     23
414eAD  erslsc                24     24
     *
416fAD  erdmsg                 1     60
416fAD  erdrtn                61     70
416fAD  erdcmd                71     80
416fAD  erdsub                81     90
     D                 ds
     D  $ec                    1      2p 0
416oAD                 ds
416oAD  errtyp                 1      8
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
600rAD #msgsp          c                   const('PIRMSGFSP ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
417kA*----------------------------------------------------------------
417kA*  *VIRTUAL  -  Virtual Slot options
417kA*----------------------------------------------------------------
417kA*
417kA* Fields
417kA*
417kA*    OPVALL  -  Always create Virtual slot. (Y/N)
417kA*    OPVPCK  -  Allow Virtual pick slots to be created.  (Y/N)
417kA*    OPVSLT  -  Create Virtual slot for item when base slot and
417kA*               corresponding Virtual slot(s) item(s) are different.
417kA*               Always Yes.
417kA*    OPVEXP  -  Create Virtual slot when item exists and
417kA*               expiration date is different.  (Y/N)
417kA*    OPVEND  -  Create Virtual slot when item exists and
417kA*               entered date is different.  (Y/N)
417kA*    OPVSAM  -  Merge product when entered/expiration dates
417kA*               are the same.  (Y/N)
417kA*    OPVEDF  -  Merge product when entered dates are different and
417kA*               expiration dates are the same.  (Y/N)
417kA*
417kA* Data structure
417kA*
417kAD opdat4          ds
417kAD  opvall                 1      1
417kAD  opvpck                 2      2
417kAD  opvslt                 3      3
417kAD  opvexp                 4      4
417kAD  opvend                 5      5
417kAD  opvsam                 6      6
417kAD  opvedf                 7      7
417kAD  opten4               117    117
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
     *  *FEATURE  -  PIR Feature options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPFEAT  -  PIR Installed feature.
     *                 1=Locator system installed.
     *                 2=Full system installed.
     *
     * Data structure
     *
710idD*opdata          ds
710iAD opdta4          ds
     D  opfeat                 1      1
     D  optend               117    117
415lA*----------------------------------------------------------------
415lA*  *PICK     -  Department receiving options.
415lA*----------------------------------------------------------------
415lA*
415lA* Fields
415lA*
415lA*    OPNXTP  -  Next pallet number.
415lA*    OPBPCK  -  Bulk pick definition.
415lA*    OPPCUB  -  Maximum cube for PIR.
415lA*    OPFPAL  -  Pallets on fixed fork lift.
415lA*    OPFCUB  -  Maximum cube per fixed pallet.
415lA*    OPFSTP  -  Maximum stops per fixed pallet.
415lA*    OPINCL  -  Include PIR in fixed cube.
415lA*    OPSRCH  -  Number of previous pallets to search for space.
415lA*    OPFBLD  -  Fixed pallet building method.
415lA*                1 = By piece without concern for splitting stop.
415lA*                2 = By stop without splitting stop between plts.
415lA*    OPPBRK  -  Aisle to start new pallet.
415lA*    OPMPUT  -  Manual put away (Y,N).
415lA*
415lA* Data structure
415lA*
415lAD opddta          ds
415lAD  opnxtp                 1      7  0 inz(0)
415lAD  oppcub                10     14  2 inz(0)
415lAD  opfpal                15     15  0 inz(0)
415lAD  opfcub                16     20  2 inz(0)
415lAD  opincl                22     22
415lAD  opsrch                23     24  0 inz(0)
415lAD  opfstp                25     26  0 inz(0)
415lAD  opfbld                27     27  0 inz(0)
415lAD  opbpck                28     30  0 inz(0)
415lAD  oppbrk                31     33
415lAD  opmput                34     34
415lAD  opdend               117    117
416bA*----------------------------------------------------------------
416bA*  *SYSTEM  -  System options.
416bA*----------------------------------------------------------------
416bA*
416bA* Fields
416bA*
416bA*    OPEPM   -  Using EPM module (Y,N).
416bA*    OPRF    -  Using RF module (Y,N).
416bA*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
416bA*    OPLETD  -  Print letdown labels (Y,N).
416bA*    OPWRNC  -  Perform catch weight variance check (Y,N).
416bA*    OPRG1C  -  Catch weight low variance percentage.
416bA*    OPRG2C  -  Catch weight high variance percentage.
416bA*    OPIMPI  -  Import item fields from host.(Y,N).
416bA*    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
416bA*
416bA* Data structure
416bA*
416bAD opdat2          ds
416bAD  opepm                  1      1
416bAD  oprf                   2      2
416bAD  opcapc                 3      3
416bAD  opletd                 4      4
416bAD  opwrnc                 5      5
416bAD  oprg1c                 6      8  1
416bAD  oprg2c                 9     11  1
416bAD  opimpi                12     12
416bAD  opmpck                14     14
416bAD  opten2               117    117
600pA*----------------------------------------------------------------
600pA*  *REPLEN  -  Replenishment options.
600pA*----------------------------------------------------------------
600pA*
600pA* Fields
600pA*
600pA*    OPRPLB  -  Replenishment basis (*AVGQTY, *ORDQTY).
600pA*    OPOQRP  -  Order qty replenishment (Y/N).
600pA*    OPRPEX  -  Allow replenishment on expired items.
600pA*               1=Allow, 2=Don't allow, 3=Warn
600pA*    OPRPFI  -  Allow replenishments out of FIFO order.
600pA*               1=Allow, 3=Warn
600pA*    OPLMTS  -  Limit Specific Slot replenishment program to
600pA*               to display only one overflow location at a
600pA*               time. (Y/N)
600nA*    OPCQTY  -  Check quantity of "To Slot" during replenish/
600nA*               letdown/transfer. (Y/N)
650kA*    OPBDRP  -  Check for Bulk Drops. (Y/N)
650kA*    OPRSRT  -  Sort Replenishment  (*DEMAND, *TOSLOT).
650kA*    OPSKPR  -  Skip if pick slot physical qty is greater than
650kA*               item replenishment level.
650mA*    OPJITW  -  During specific slot repl if this option = N don't
650mA*               bother checking for JIT's as the user does not want
650mA*               the JIT notification window.
700aA*    OPLQTY  -  Replenish pick slots that display less than X
700aA*               cases.
740 A*    OPCKDD  -  Check and Warn for Drop Pick Replens
600pA*
600pA* Data structure
600pA*
600pAD opdta3          ds
600pAD  oprplb                 1      8
600pAD  opoqrp                 9      9
600pAD  oprpex                10     10
600pAD  oprpfi                11     11
600pAD  oplmts                12     12
600nAD  opcqty                13     13
510bAD  opbdrp                14     14
650kAD  oprsrt                15     24
650kAD  opskpr                25     25
650mAD  opjitw                26     26
700hAD  oplqty                27     28  0
700hAD  oplqtya               27     28
720aAD  opsslcn               29     29
740 Ad  opckdd                32     32
600pAD  opcend               117    117
     *----------------------------------------------------------------
     *  PIRTRAN record layout for use as parameters
     *
     D ptparm        e ds                  extname(pirtran)
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
500dAD  #pgm             *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
500dAD  #jobnbr              264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
600uAD  #curruser            358    367
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
     *  Variables
     *

500dAD #fromitwhse     s                   like($itwhse)
500dAD #fromititem     s                   like($ititem)
500dAD #fromittype     s                   like($ittype)
500dAD #fromitdesc     s                   like($itdesc)
500dAD #fromitpdsc     s                   like($itpdsc)
500dAD #fromithead     s             70
500dAD #fromitwhdp     s                   like($itwhdp)
500dAD #fromitstyp     s                   like($itstyp)
500dAD #fromitdesg     s                   like($itdesg)
500dAD #fromitum1      s                   like($itum1)
500dAD #fromitflg1     s                   like($itflg1)
500dAD #fromitum2      s                   like($itum2)
500dAD #fromitumq2     s                   like($itumq2)
500dAD #fromitflg2     s                   like($itflg2)
500dAD #fromitum3      s                   like($itum3)
500dAD #fromitumq3     s                   like($itumq3)
500dAD #fromitnrpk     s                   like($imnrpk)
500dAD #fromitflgd     s                   like($itflgd)
500dAD #fromitcube     s                   like($itcube)
500dAD #fromitswgt     s                   like($itswgt)
500dAD #fromitcwgt     s                   like($itcwgt)
500dAD #fromitmitem    s                   like($itmitem)
500dAD #fromitsdef     s                   like($idsdef)
500dAD #fromittie      s                   like($idtie)
500dAD #fromithigh     s                   like($idhigh)

500dAD #fromssbflag    s               n
500dAD #fromssbititem  s                   like($ititem)
500dAD #fromssbittype  s                   like($ittype)
500dAD #fromssbitdesc  s                   like($itdesc)
500dAD #fromssbitpdsc  s                   like($itpdsc)
500dAD #fromssbitwhdp  s                   like($itwhdp)
500dAD #fromssbitstyp  s                   like($itstyp)
500dAD #fromssbitdesg  s                   like($itdesg)
500dAD #fromssbitum1   s                   like($itum1)
500dAD #fromssbitum2   s                   like($itum2)
500dAD #fromssbitumq2  s                   like($itumq2)
500dAD #fromssbitum3   s                   like($itum3)
500dAD #fromssbitumq3  s                   like($itumq3)

500dAD #fromslwhse     s                   like($slwhse)
500dAD #fromslwhdp     s                   like($slwhdp)
500dAD #fromslstyp     s                   like($slstyp)
500dAD #fromsldisp     s                   like($sldisp)
500dAD #fromslaisl     s                   like($slaisl)
500dAD #fromslloc      s                   like($slloc)
500dAD #fromslpseq     s                   like($slpseq)
500dAD #fromslrlvl     s                   like($slrlvl)
500dAD #fromslhand     s                   like($slhand)
500dAD #fromslstat     s                   like($slstat)
500dAD #fromslrsrv     s                   like($slrsrv)
500dAD #fromslentd     s                   like($slentd)
500dAD #fromslexpd     s                   like($slexpd)
500dAD #fromslslfd     s                   like($slslfd)
500dAD #fromslactv     s                   like($slactv)
500dAD #fromslbld      s                   like($slbld)
500dAD #fromslpick     s                   like($slpick)
500dAD #fromslitem     s                   like($slitem)
500dAD #fromslsdef     s                   like($slsdef)
500dAD #fromslpos      s                   like($sdpos)
500dAD #fromslvirt     s                   like($sfvirt)
500dAD #fromslstk1     s                   like($slstk1)
500dAD #fromslstk2     s                   like($slstk2)
500dAD #fromslstk3     s                   like($slstk2)
500dAD #fromslalc1     s                   like($slalc1)
500dAD #fromslalc2     s                   like($slalc2)
500dAD #fromslalc3     s                   like($slalc3)
500dAD #fromsltfr1     s                   like($sltfr1)
500dAD #fromsltfr2     s                   like($sltfr2)
500dAD #fromsltfr3     s                   like($sltfr3)
500dAD #fromslpck1     s                   like($slpck1)
500dAD #fromslpck2     s                   like($slpck2)
500dAD #fromslpck3     s                   like($slpck3)
500dAD #fromslrcv1     s                   like($slrcv1)
500dAD #fromslrcv2     s                   like($slrcv2)
500dAD #fromslrcv3     s                   like($slrcv3)
500dAD #fromslphy1     s                   like($slphy1)
500dAD #fromslphy2     s                   like($slphy2)
500dAD #fromslphy3     s                   like($slphy3)
500dAD #fromslavl1     s                   like($slavl1)
500dAD #fromslavl2     s                   like($slavl2)
500dAD #fromslavl3     s                   like($slavl3)
500dAD #frombasesldsp  s                   like($sldisp)
600uAD #fromsaToLcns   s                   like($saToLcns)
500iAD #fromsaToPos    s                   like($saToPos)
600uAD #fromsaOLcns    s                   like($saOLcns)
500iAD #fromslSide     s                   like($slSide)

500dAD #ovrfslwhse     s                   like($slwhse)
500dAD #ovrfslwhdp     s                   like($slwhdp)
500dAD #ovrfslstyp     s                   like($slstyp)
500dAD #ovrfsldisp     s                   like($sldisp)
500dAD #ovrfslaisl     s                   like($slaisl)
500dAD #ovrfslloc      s                   like($slloc)
500dAD #ovrfslpseq     s                   like($slpseq)
500dAD #ovrfslrlvl     s                   like($slrlvl)
500dAD #ovrfslhand     s                   like($slhand)
500dAD #ovrfslstat     s                   like($slstat)
500dAD #ovrfslrsrv     s                   like($slrsrv)
500dAD #ovrfslentd     s                   like($slentd)
500dAD #ovrfslexpd     s                   like($slexpd)
500dAD #ovrfslslfd     s                   like($slslfd)
500dAD #ovrfslactv     s                   like($slactv)
500dAD #ovrfslbld      s                   like($slbld)
500dAD #ovrfslpick     s                   like($slpick)
500dAD #ovrfslitem     s                   like($slitem)
500dAD #ovrfslsdef     s                   like($slsdef)
500dAD #ovrfslpos      s                   like($sdpos)
500dAD #ovrfslvirt     s                   like($sfvirt)
500dAD #ovrfslstk1     s                   like($slstk1)
500dAD #ovrfslstk2     s                   like($slstk2)
500dAD #ovrfslstk3     s                   like($slstk2)
500dAD #ovrfslalc1     s                   like($slalc1)
500dAD #ovrfslalc2     s                   like($slalc2)
500dAD #ovrfslalc3     s                   like($slalc3)
500dAD #ovrfsltfr1     s                   like($sltfr1)
500dAD #ovrfsltfr2     s                   like($sltfr2)
500dAD #ovrfsltfr3     s                   like($sltfr3)
500dAD #ovrfslpck1     s                   like($slpck1)
500dAD #ovrfslpck2     s                   like($slpck2)
500dAD #ovrfslpck3     s                   like($slpck3)
500dAD #ovrfslrcv1     s                   like($slrcv1)
500dAD #ovrfslrcv2     s                   like($slrcv2)
500dAD #ovrfslrcv3     s                   like($slrcv3)
500dAD #ovrfslphy1     s                   like($slphy1)
500dAD #ovrfslphy2     s                   like($slphy2)
500dAD #ovrfslphy3     s                   like($slphy3)
500dAD #ovrfslavl1     s                   like($slavl1)
500dAD #ovrfslavl2     s                   like($slavl2)
500dAD #ovrfslavl3     s                   like($slavl3)
500dAD #ovrfbasesldsp  s                   like($sldisp)

500dAD #pickitwhse     s                   like($itwhse)
500dAD #pickititem     s                   like($ititem)
500dAD #pickittype     s                   like($ittype)
500dAD #pickitdesc     s                   like($itdesc)
500dAD #pickitpdsc     s                   like($itpdsc)
500dAD #pickithead     s             70
500dAD #pickitwhdp     s                   like($itwhdp)
500dAD #pickitstyp     s                   like($itstyp)
500dAD #pickitdesg     s                   like($itdesg)
500dAD #pickitum1      s                   like($itum1)
500dAD #pickitflg1     s                   like($itflg1)
500dAD #pickitum2      s                   like($itum2)
500dAD #pickitumq2     s                   like($itumq2)
500dAD #pickitflg2     s                   like($itflg2)
500dAD #pickitum3      s                   like($itum3)
500dAD #pickitumq3     s                   like($itumq3)
500dAD #pickitnrpk     s                   like($imnrpk)
500dAD #pickitflgd     s                   like($itflgd)
500dAD #pickitcube     s                   like($itcube)
500dAD #pickitswgt     s                   like($itswgt)
500dAD #pickitcwgt     s                   like($itcwgt)
500dAD #pickitmitem    s                   like($itmitem)
500dAD #pickitsdef     s                   like($idsdef)
500dAD #pickittie      s                   like($idtie)
500dAD #pickithigh     s                   like($idhigh)

500dAD #pickssbflag    s               n
500dAD #pickssbititem  s                   like($ititem)
500dAD #pickssbittype  s                   like($ittype)
500dAD #pickssbitdesc  s                   like($itdesc)
500dAD #pickssbitpdsc  s                   like($itpdsc)
500dAD #pickssbitwhdp  s                   like($itwhdp)
500dAD #pickssbitstyp  s                   like($itstyp)
500dAD #pickssbitdesg  s                   like($itdesg)
500dAD #pickssbitum1   s                   like($itum1)
500dAD #pickssbitum2   s                   like($itum2)
500dAD #pickssbitumq2  s                   like($itumq2)
500dAD #pickssbitum3   s                   like($itum3)
500dAD #pickssbitumq3  s                   like($itumq3)

500dAD #pickslwhse     s                   like($slwhse)
500dAD #pickslwhdp     s                   like($slwhdp)
500dAD #pickslstyp     s                   like($slstyp)
500dAD #picksldisp     s                   like($sldisp)
500dAD #pickslaisl     s                   like($slaisl)
500dAD #pickslloc      s                   like($slloc)
500dAD #pickslpseq     s                   like($slpseq)
500dAD #pickslrlvl     s                   like($slrlvl)
500dAD #pickslhand     s                   like($slhand)
500dAD #pickslstat     s                   like($slstat)
500dAD #pickslrsrv     s                   like($slrsrv)
500dAD #pickslentd     s                   like($slentd)
500dAD #pickslexpd     s                   like($slexpd)
500dAD #pickslslfd     s                   like($slslfd)
500dAD #pickslactv     s                   like($slactv)
500dAD #pickslbld      s                   like($slbld)
500dAD #pickslpick     s                   like($slpick)
500dAD #pickslitem     s                   like($slitem)
500dAD #pickslsdef     s                   like($slsdef)
500dAD #pickslpos      s                   like($sdpos)
500dAD #pickslvirt     s                   like($sfvirt)
500dAD #pickslstk1     s                   like($slstk1)
500dAD #pickslstk2     s                   like($slstk2)
500dAD #pickslstk3     s                   like($slstk2)
500dAD #pickslalc1     s                   like($slalc1)
500dAD #pickslalc2     s                   like($slalc2)
500dAD #pickslalc3     s                   like($slalc3)
500dAD #picksltfr1     s                   like($sltfr1)
500dAD #picksltfr2     s                   like($sltfr2)
500dAD #picksltfr3     s                   like($sltfr3)
500dAD #pickslpck1     s                   like($slpck1)
500dAD #pickslpck2     s                   like($slpck2)
500dAD #pickslpck3     s                   like($slpck3)
500dAD #pickslrcv1     s                   like($slrcv1)
500dAD #pickslrcv2     s                   like($slrcv2)
500dAD #pickslrcv3     s                   like($slrcv3)
500dAD #pickslphy1     s                   like($slphy1)
500dAD #pickslphy2     s                   like($slphy2)
500dAD #pickslphy3     s                   like($slphy3)
500dAD #pickslavl1     s                   like($slavl1)
500dAD #pickslavl2     s                   like($slavl2)
500dAD #pickslavl3     s                   like($slavl3)
500dAD #pickbasesldsp  s                   like($sldisp)

     D $msgf           s             10
     D $vaisl          s              3
     D $vloc           s              3  0
     D $vpick          s              1
     D $vpseq          s              5  0
     D $vrlvl          s              2  0
     D $vstyp          s              1
     D $vwhdp          s              5
     D $vwhse          s              3  0
     D #bitem          s                   like(lbitem)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
650bAD allDepts        s               n
500dAD askzrovfy       s               n
     D availf          s              7  0
     D a58             s             58
     D balexc          s              1
     D balrem          s              4
     D bszero          s              1
     D bypass          s              1
     D cases           s                   like(lbqpck)
500dAD chk4err         s               n
     D chknew          s              1
     D ckdate          s              8  0
     D ck4err          s              1
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D crtdsc          s              1
     D crtrcd          s              1
     D csqty           s                   like(lbqpck)
500qAD curdate         s              8  0
     D curent          s              1
500bAD curitm          s                   like($titem)
500bAD curlic#         s                   like($tlic#)
500qAD curtime         s              6  0
     D curtrn          s              7  0
     D curtrn#         s              7  0
     D curtsk          s              6
     D curtyp          s              1
500bAD curwhd          s                   like(lbwhdp)
     D difpck          s                   like(lbqpck)
     D difrep          s                   like(lbqpck)
     D difrpl          s                   like(lbqpck)
700hAD aisl1           s              3
700hAD aisl2           s              3
700hAD dspless5        s              1
     D done            s              1
500jMD drierr          s               n
     D drizm           s              1
     D dteofl          s              1
     D dteold          s              1
     D e               s              2  0
     D enter           s              5  0
     D eof             s              1
     D errflg          s              1
500dMD error           s               n
     D excptn          s              1
     D exist           s              1
     D fintim          s                   like(ptetim)
710aAD firstP9         s               n
     D flaghs          s              1
600jAD flgf10          s              1
     D fmentd          s                   like(slentd)
     D fmexpd          s                   like(slexpd)
     D fmpck           s                   like(slpick)
     D forever         s               n
     D forevr          s              1
     D found           s              1
     D frmasl          s                   like(slaisl)
500dAD fullcases       s              5  0
500dAD getwhse         s                   like($slwhse)
500dAD getwhdp         s                   like($slwhdp)
500dAD getdisp         s                   like($sldisp)
     D hasvs           s              1
     D help            s              5  0
600iAD hldlbl          s                   like(lblbl#)
     D hldseq          s                   like(prseq#)
650bAD hldseqAlpha     s              6
     D hldtrn          s                   like(pttrn#)
     D hlrtpo          s                   like(ptrtpo)
650bAD hldwhdpseq      s             11
     D i               s              2  0
650lDD*idx             s              2  0
650lMD idx             s              4  0
     D itdtyp          s                   like($ltyp)
600uAD it276Flag       s               n
600wAD lt108Flag       s               n
     D j               s              2  0
     D k               s              3  0
     D kyaisl          s                   like(slaisl)
     D kycode          s                   like(opcode)
     D kydcod          s                   like(opdcod)
     D kydisp          s                   like(sldisp)
     D kydwdp          s                   like(opdwdp)
     D kydwhs          s                   like(opdwhs)
     D kyitem          s                   like(ilitm2)
600uAD kyrectype       s                   like(wurectype)
     D kystat          s                   like(ptstat)
     D kytrn#          s                   like(pttrn#)
     D kywhdp          s                   like(lbwhdp)
     D kywhse          s                   like(opwhse)
     D k3pick          s                   like(slpick)
     D k3stat          s                   like(slstat)
CBIdAD letord          s              5
720bAd levelOk         s               n
500qAD lasttime        s              6  0
     D loop            s              1
     D lstscr          s              3
     D lstslt          s             12
     D lsttyp          s              8
     D msgk            s              4  0
     D nbrpck          s              5  0
     D newlb           s              1
     D newtrn          s              1
     D newvs           s              1
650bAD nextAllFirst    s               n
     D nwstat          s                   like(slstat)
     D nwstk1          s                   like(slstk1)
     D nwstk2          s                   like(slstk2)
     D nwstk3          s                   like(slstk3)
     D nxtscr          s              3
600jAD orgdte          s                   like(ptsdte)
600jAD orgtim          s                   like(ptstim)
710aAD outOfFifoOrder  s               n
600jAD ovrdte          s                   like(ptsdte)
600jAD ovrtim          s                   like(ptstim)
     D ovrrid          s              1
600uAD partial         s               n
650kAD pckSltPhyQ      s             10  0
     D phactv          s                   like(slactv)
     D phaisl          s                   like(slaisl)
     D phbld           s                   like(slbld)
     D phdesg          s                   like(sldesg)
     D phdisp          s                   like(sldisp)
     D phhand          s                   like(slhand)
     D phloc           s                   like(slloc)
     D phpseq          s                   like(slpseq)
     D phrlvl          s                   like(slrlvl)
     D phsdef          s                   like(slsdef)
     D phside          s                   like(slside)
     D phslfd          s                   like(slslfd)
     D phstyp          s                   like(slstyp)
     D phwhdp          s                   like(slwhdp)
     D phwhse          s                   like(slwhse)
     D qtychg          s              1
500jAD redate          s                   like(ptsdte)
     D redspl          s              1
     D refrsh          s              1
500dAD remainder       s              5  0
     D restrt          s              1
     D restr2          s              1
CBIdAD restr3          s              1
600jAD retime          s                   like(ptstim)
     D rolldn          s              5  0
     D rollup          s              5  0
700aAD rpladjcmd       s             10
700aAD rpldifqty       s                   like(w3nqty)
     D rpldif          s                   like(sltfr1)
     D rplqty          s                   like(lbqpck)
     D rpltyp          s              8
     D rtnhom          s              1
     D rtnto           s              8
     D rvpulq          s                   like(lbqpck)
     D rvrepq          s                   like(lbqrmn)
710aAD saveEntd        s                   like(slentd)
710aAD saveExpd        s                   like(slexpd)
710aAD savePrty        s                   like(slprty)
650bAD savprty         s                   like(prprty)
     D savseq          s                   like(prseq#)
     D savtrn          s                   like(pttrn#)
650bAD savwhdp         s                   like(prwhdp)
     D sbaisl          s                   like(lbaisl)
     D sbdisp          s                   like(lbdisp)
     D sbdsp2          s                   like(lbdsp2)
     D sbgrp1          s                   like(lbgrp1)
     D sbgrp2          s                   like(lbgrp2)
     D sbhand          s                   like(lbhand)
     D sbhigh          s                   like(lbhigh)
     D sbitem          s                   like(lbitem)
     D sbloc           s                   like(lbloc)
     D sbord           s                   like(lbord)
     D sbpal#          s                   like(lbpal#)
     D sbpbat          s                   like(lbpbat)
     D sbpo            s                   like(lbpo)
     D sbpseq          s                   like(lbpseq)
     D sbqryf          s                   like(lbqryf)
     D sbrdte          s                   like(lbrdte)
     D sbrlvl          s                   like(lbrlvl)
     D sbseq           s                   like(lbseq)
     D sbstat          s                   like(lbstat)
     D sbstyp          s                   like(lbstyp)
     D sbtie           s                   like(lbtie)
     D sbtrn#          s                   like(lbtrn#)
     D sbtype          s                   like(lbtype)
     D sbucod          s                   like(lbucod)
     D sbucub          s                   like(lbucub)
     D sbutyp          s                   like(lbutyp)
     D sbuwgt          s                   like(lbuwgt)
     D sbwhdp          s                   like(lbwhdp)
     D sbwhse          s                   like(lbwhse)
500tAD sc2first        s               n
     D sclear          s              1
     D skippd          s              1
     D skpslt          s              1
     D sldtyp          s                   like($ltyp)
     D spcslt          s              1
     D spfcrp          s              4
     D stdate          s                   like(ptsdte)
     D strtim          s                   like(ptstim)
     D sttime          s                   like(ptstim)
     D svcube          s                   like(lbcube)
CBIdAD svdsp2          s                   like(lbdsp2)
     D svexpd          s                   like(slexpd)
     D svfdis          s                   like(sldisp)
     D svitem          s                   like(lbitem)
     D svlbl#          s                   like(lblbl#)
     D svorsl          s                   like(sldisp)
     D svpick          s                   like(slpick)
     D svqalc          s                   like(lbqalc)
     D svqpck          s                   like(lbqpck)
     D svqrmn          s                   like(lbqrmn)
     D svrplb          s                   like(lblbl#)
     D svrtpo          s                   like(ptrtpo)
     D svswgt          s                   like(lbswgt)
     D svtask          s                   like(pttask)
     D svtfr1          s                   like(sltfr1)
     D svtlen          s                   like(ptdmin)
     D svtran          s                   like(pttrn#)
     D svtrn#          s                   like(pttrn#)
     D svtype          s                   like(ittype)
     D svumq2          s                   like(itumq2)
     D svumq3          s                   like(itumq3)
CBIdAD svwhdp          s                   like(lbwhdp)
     D svwhse          s                   like(w1whse)
     D t#task          s              6
     D tempa2          s              2
     D temp1a          s              1
     D temp13          s             13
500sAD temp3n          s              3  0
     D timlen          s                   like(ptdmin)
650aAD tfr2usrDate     s                   like(iadate)
650aAD tfr2usrTime     s                   like(iatime)
     D tmpbeg          s              4  0
     D tmpend          s              4  0
     D toaisl          s                   like(slaisl)
     D today           s              8  0
     D topck           s                   like(slpick)
     D topick          s                   like(lbqpck)
     D toslot          s                   like(sldisp)
500mAD trackitem       s              1
500mAD trackpos        s              1
500mAD trackposmrg     s              1
500mAD trackposrtn     s              1
500mAD trackpsplit     s              1
500mAD tracktsplit     s              1
     D trndte          s              8  0
500pAD trnlic#         s                   like($tlic#)
     D trntim          s              6  0
     D usrrpl          s              1
     D vrtslt          s              1
     D warn            s              1
600pAD whse            s              3  0
CBIdAD wkdsp2          s                   like(lbdsp2)
     D wkgrp1          s                   like(ptgrp1)
     D wkgrp2          s                   like(ptgrp2)
     D wkqty           s                   like(lbqpck)
650bAD wkrplt          s                   like(prrplt)
     D wkrtpo          s                   like(ptrtpo)
CBIdAD wkwhdp          s                   like(lbwhdp)
     D woemty          s              1
     D wotrn#          s                   like(pttrn#)
     D wozero          s              1
     D wrkqty          s                   like(lbqpck)
640jAD wrtpcmd         s             10
640jAD wrtpwait        s              2  0
640jAD wrtpwhse        s              3  0
640jAD wrtptran#       s                   like(pttrn#)
640jAD wrtpfrmdate     s              8  0
640jAD wrtptodate      s              8  0
640jAd wrtpemp#        s                   like(ptemp#)
     D w1task          s              6
720aAD w1lcns          s             15
     D w2aval          s              7  0
     D w3qty           s              7  0
     D w4qty           s              1
     D zzedte          s                   like(ptedte)
     D zzetim          s                   like(ptetim)
500dAD zmsflag         s               n
     D zzsdte          s                   like(ptsdte)
     D zzstim          s                   like(ptstim)
750cAd apseq#          s              5  0

PFCaA*----------------------------------------------------------------
PFCaA*  Constants/Variables for APT
PFCaA
750cDd**ptsk1          c                   '*RPLBEG   '
750cMd aptsk_BEGIN     c                   '*RPLBEG   '
750cDd**ptsk2          c                   '*RPLPLC   '
750cMd aptsk_PLACE     c                   '*RPLPLC   '
750cDd**ptsk3          c                   '*RPLTRAVEL'
750cMd aptsk_TRAVEL    c                   '*RPLTRAVEL'
750cDd**ptsk4          c                   '*RPLEND   '
750cMd aptsk_END       c                   '*RPLEND   '
750cDd**ptsk5          c                   '*JOB0100  '
750cMd aptsk_JOB0100   c                   '*JOB0100  '
PFCaA
PFCaAd logapt          s               n   inz(*on)

600uA*----------------------------------------------------------------
600uA*  Time variables
600uA*----------------------------------------------------------------
600ua
600uAD CurrStamploc    s               z
600uAD CurrStampsys    s               z
600uAD CurrStampuc     s               z
600uA
600uaD bfcoffset       s              3  0 inz(0)

610iA*----------------------------------------------------------------
610iA*  Phrase Variables
610iA*----------------------------------------------------------------
610iA
610iA /COPY *libl/qcopysrc,c#phrasvar
610iAD  currFile       s             10
610iAD  currRoutine    s             20
610iAD  lastnxtscr     s              3
610iAD  stackCount     s              3  0
610iAD  aRoutine       s             20    dim(30)
610iA
610iA*----------------------------------------------------------------
610iA*  Phrases
610iA*----------------------------------------------------------------
610iA
610iA /COPY *libl/qcopysrc,c#phrases

CBIbA*----------------------------------------------------------------
CBIbA*  PRPLFIL5 record layout
CBIbA*
CBIbAIprrec5
CBIbAI              prwhse                      prwhs5
CBIbAI              prwhdp                      prwhd5
CBIbAI              prfail                      prfai5
CBIbAI              prtail                      prtai5
CBIbAI              prfdis                      prfdi5
CBIbAI              prtdis                      prtdi5
CBIbAI              pritem                      pritm5
CBIbAI              prseq#                      prseq5
CBIbAI              prqty                       prqty5
CBIbAI              prsdef                      prsde5
CBIbAI              prflag                      prflg5
CBIbAI              prprty                      prprt5
CBIbAI              prfree                      prfre5
CBIbAI              prstat                      prsta5
CBIbAI              prtype                      prtyp5
CBIbAI              pradte                      pradt5
CBIbAI              pratim                      pratm5
CBIbAI              praqs                       praqs5
416oA*----------------------------------------------------------------
416oA*  Redefine field names in file SLOTRPEX
416oA*
416oAIserec
416oAI              sewhse                      sxwhse
416oAI              sewhdp                      sxwhdp
416oAI              sedisp                      sxdisp
416oAI              seitem                      sxitem
416oAI              seadte                      sxadte
416oAI              seatim                      sxatim
416oAI              seaby                       sxaby
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     Iitrec
     I              itdesc                      pitdsc
     I              itpdsc                      pitpds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
600qA*      $SCMD   *STDRPL  - Standard replenishment. All program
600qA*                         functions are avilable.
600qA*              *INTERLV - Interleaving replenishment. Certain
600qA*                         functions restricted.
600qA*      $SPRG   Program to send messages back to.
600qA*      $SUKY   Contains key for everything by *ADD.
     *
     *    Returned Parameters
600qA*      $SUKY   Contains new batch number for *ADD.
600qA*              Unchanged for everything else.
600qA*      $SRTN   blank    - No problem encountered.
600qA*              *CANCEL  - User canceled replenishment
600qA*              *RPLDONE - Replenishment completed.
600qA*              *ERROR   - Error occured. Message in $PERM
600qA*              *PGMQ    - Error occured. Message sent to pgmq.
600qA*      $SERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Main line
     *
600qAC     *entry        plist
600qAC                   parm                    $sparm
600qA*----------------------------------------------------------------
600qA*
610iAC                   eval      stackCount = 0
610iAC                   eval      currRoutine = 'main'
610iAC                   exsr      phpgmV1V2V3s

     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
610cAC                   exsr      zsclr
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
417cAC     nxtscr        caseq     '09 '         sc9
640bAC     nxtscr        caseq     '11 '         sc6a
650bAC     nxtscr        caseq     '111'         sc11
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
610bAC                   exsr      phpgmV1V2V3e
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
610iA*
610iA*   Write tracking phrase of which screen is being displayed.
610iA*
610iAC                   exsr      phscrV1PgmV2
     *
     *  Overlay screen with screen to be processed.
     *
     C                   select
     C                   when      nxtscr = '01 '
600rAC                   select
600rAC                   when      e$lng = 'SP'
510hAC                   if        #lline = '16'
510hAC                   exfmt     scrn61sp                             50
510hAC                   else
600rAC                   exfmt     scrn1sp                              50
510hAC                   endif
600rAC                   other
510hAC                   if        #lline = '16'
740 Ac                   if        opckdd='Y'
740 Ac                   eval      w7whse=w1whse
740 Ac                   eval      w7whdp=w1whdp
740 Ac                   exsr      chkForDD
740 Ac                   endif
510hAC                   exfmt     screen61                             50
510hAC                   else
740 Ac                   if        opckdd='Y'
740 Ac                   eval      w7whse=w1whse
740 Ac                   eval      w7whdp=w1whdp
740 Ac                   exsr      chkForDD
740 Ac                   endif
     C                   exfmt     screen1                              50
510hAC                   endif
600rAC                   endsl
     *
     C                   when      nxtscr = '02 '
600rAC                   select
600rAC                   when      e$lng = 'SP'
510hAC                   if        #lline = '16'
510hAC                   exfmt     scrn62sp                             50
510hAC                   else
600rAC                   exfmt     scrn2sp                              50
510hAC                   endif
600rAC                   other
510hAC                   if        #lline = '16'
610eAC                   if        client = saval
610eAC                   exfmt     screen72                             50
610eAC                   else
510hAC                   exfmt     screen62                             50
610eAC                   endif
510hAC                   else
     C                   exfmt     screen2                              50
510hAC                   endif
600rAC                   endsl
     *
     C                   when      nxtscr = '03 '
600rAC                   select
600rAC                   when      e$lng = 'SP'
510hAC                   if        #lline = '16'
510hAC                   exfmt     scrn63sp                             50
510hAC                   else
600rAC                   exfmt     scrn3sp                              50
510hAC                   endif
600rAC                   other
510hAC                   if        #lline = '16'
610eAC                   if        client = saval
610eAC                   exfmt     screen73                             50
610eAC                   else
510hAC                   exfmt     screen63                             50
610eAC                   endif
510hAC                   else
     C                   exfmt     screen3                              50
510hAC                   endif
600rAC                   endsl
     *
     C                   when      nxtscr = '04 '
600rAC                   select
600rAC                   when      e$lng = 'SP'
510hAC                   if        #lline = '16'
510hAC                   exfmt     scrn64sp                             50
510hAC                   else
600rAC                   exfmt     scrn4sp                              50
510hAC                   endif
600rAC                   other
510hAC                   if        #lline = '16'
510hAC                   exfmt     screen64                             50
510hAC                   else
     C                   exfmt     screen4                              50
510hAC                   endif
600rAC                   endsl
     *
     C                   when      nxtscr = '05 '
600rAC                   select
600rAC                   when      e$lng = 'SP'
510hAC                   if        #lline = '16'
600rAC                   exfmt     scrn65sp                             50
510hAC                   else
600rAC                   exfmt     scrn5sp                              50
510hAC                   endif
600rAC                   other
510hAC                   if        #lline = '16'
510hAC                   exfmt     screen65                             50
510hAC                   else
     C                   exfmt     screen5                              50
510hAC                   endif
600rAC                   endsl
     *
     C                   when      nxtscr = '06 '
600rAC                   select
600rAC                   when      e$lng = 'SP'
510hAC                   if        #lline = '16'
510hAC                   exfmt     scrn66sp                             50
510hAC                   else
600rAC                   exfmt     scrn6sp                              50
510hAC                   endif
600rAC                   other
510hAC                   if        #lline = '16'
510hAC                   exfmt     screen66                             50
510hAC                   else
     C                   exfmt     screen6                              50
510hAC                   endif
600rAC                   endsl
     *
     C                   when      nxtscr = '07 '
600rAC                   select
600rAC                   when      e$lng = 'SP'
510hAC                   if        #lline = '16'
510hAC                   exfmt     scrn67sp                             50
510hAC                   else
600rAC                   exfmt     scrn7sp                              50
510hAC                   endif
600rAC                   other
510hAC                   if        #lline = '16'
740 Ac                   if        opckdd='Y'
740 Ac                   exsr      chkForDD
740 Ac                   endif
510hAC                   exfmt     screen67                             50
510hAC                   else
740 Ac                   if        opckdd='Y'
740 Ac                   exsr      chkForDD
740 Ac                   endif
     C                   exfmt     screen7                              50
510hAC                   endif
600rAC                   endsl
     *
     C                   when      nxtscr = '08 '
600rAC                   select
600rAC                   when      e$lng = 'SP'
510hAC                   if        #lline = '16'
510hAC                   exfmt     scrn68sp                             50
510hAC                   else
600rAC                   exfmt     scrn8sp                              50
510hAC                   endif
600rAC                   other
510hAC                   if        #lline = '16'
610eAC                   if        client = saval
610eAC                   exfmt     screen78                             50
610eAC                   else
510hAC                   exfmt     screen68                             50
610eAC                   endif
510hAC                   else
     C                   exfmt     screen8                              50
510hAC                   endif
600rAC                   endsl
     *
640b C                   when      nxtscr = '11 '
640bAC                   select
640bAC                   when      e$lng = 'SP'
640bAC                   if        #lline = '16'
640bAC                   exfmt     scn66asp                             50
640bAC                   else
640bAC                   exfmt     scn6asp                              50
640bAC                   endif
640bAC                   other
640bAC                   if        #lline = '16'
640bAC                   exfmt     scren66a                             50
640bAC                   else
640bAC                   exfmt     scren6a                              50
640bAC                   endif
640bAC                   endsl
     *
650bAC                   when      nxtscr = '111'
650bAC                   select
650bAC                   when      e$lng = 'SP'
650bAC                   if        #lline = '16'
650bAC                   exfmt     scr611sp                             50
650bAC                   else
650bAC                   exfmt     scrn11sp                             50
650bAC                   endif
650bAC                   other
650bAC                   if        #lline = '16'
650bAC                   exfmt     scrn611                              50
650bAC                   else
650bAC                   exfmt     scrn11                               50
650bAC                   endif
650bAC                   endsl
     *
     C                   endsl
610iA*
610iA*   Write tracking phrase of what was pressed.
610iA*
610iAC                   exsr      phV2onV1
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
     C                   setoff                                       9298
740 Ac                   setoff                                       45
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
     C                   eval      nxtscr = '01 '
     C                   exsr      zzfil1
     C                   eval      refrsh = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   eval      availf = 0
     C                   eval      hasvs = *off
416kAC                   eval      wozero = 'N'
500dAC                   exsr      zzget2
     C                   exsr      zzfil2
     C                   eval      refrsh = *off
415vAC                   eval      rtnhom = *off
417cA*
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     C                   exsr      zzfil3
     C                   eval      refrsh = *off
     C                   eval      ovrrid = *off
     C     end03i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 04 initialization
     *
     C     scr04i        begsr
     C                   eval      nxtscr = '04 '
     C                   exsr      zzfil4
     C                   eval      refrsh = *off
     C     end04i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 05 initialization
     *
     C     scr05i        begsr
     C                   eval      nxtscr = '05 '
     C                   exsr      zzfil5
     C                   eval      refrsh = *off
     C     end05i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 06 initialization
     *
     C     scr06i        begsr
     *
     *    Create idle transaction.
     *
416sAC                   eval      curtrn = 0
416sAC                   eval      curtsk = *blanks
416sAC                   eval      curtyp = *blanks
416sAC                   eval      curent = *off
416sAC                   exsr      zztask
416sAC                   if        curent = *off
416sAC                   eval      w1task = 'IDLE  '
500dMC                   exsr      zztrnidle
416sAC                   endif
     *
     C                   eval      nxtscr = '06 '
     C                   exsr      zzfil6
     C                   eval      refrsh = *off
     C     end06i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 07 initialization
     *
     C     scr07i        begsr
     C                   eval      nxtscr = '07 '
     C                   exsr      zzfil7
     C                   eval      refrsh = *off
     C     end07i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 08 initialization
     *
     C     scr08i        begsr
     C                   eval      nxtscr = '08 '
     C                   exsr      zzfil8
     C                   eval      refrsh = *off
     C     end08i        endsr
417cA*
417cA*----------------------------------------------------------------
417cA*
417cA*  Screen 09 initialization
417cA*
417cAC     scr09i        begsr
417cAC                   eval      nxtscr = '09 '
417cAC                   exsr      zzfil9
417cAC                   eval      refrsh = *off
417cAC     end09i        endsr
640bA*----------------------------------------------------------------
640bA*
640bA*  Screen 6a initialization
640bA*
640bAC     scr6ai        begsr
640bAC                   eval      nxtscr = '11 '
640bAC                   exsr      zzfil6a
640bAC                   eval      refrsh = *off
640bAC     end6ai        endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  Screen 08 initialization
650bA*
650bAC     scr11i        begsr
650bAC                   eval      nxtscr = '111'
650bAC                   exsr      zzfil11
650bAC                   eval      refrsh = *off
650bAC     end11i        endsr
650bA*
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
700hAC                   eval      dspless5 = '0'
600qA*
600qAC                   if        $scmd = '*INTERLV'
600qAC                   eval      $srtn = '*CANCEL '
600qAC                   endif
600qA*
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
700hAC                   eval      dspless5 = '0'
415kAC                   select
600qA*
600qA*    Interleaving replenishment canceled.
600qAC                   when      $scmd = '*INTERLV'
600qAC                   eval      $srtn = '*CANCEL '
600qAC                   eval      nxtscr = 'EOJ'
600qA*
417hA*
417hA*    Bring user back to interupted transaction.
417hAC                   when      restrt = *on
417hAC                   eval      restr2 = *on
417hAC                   eval      rtnto = *blanks
417hAC                   eval      w1tdis = *blanks
720aAC                   eval      w1lcns = *blanks
720aAC                   eval      w1scan = *blanks
417hAC                   eval      usrrpl = *off
417hAC                   eval      bypass = *off
417hAC                   exsr      zzupd1
417hAC                   goto      endsc1
417hA*
415kAC                   when      rtnto = 'LETDOWN '
415kAC                   eval      rtnto = *blanks
415kAC                   eval      w1tdis = *blanks
720aAC                   eval      w1lcns = *blanks
720aAC                   eval      w1scan = *blanks
415kAC                   eval      usrrpl = *off
415kAC                   eval      bypass = *off
415kAC                   eval      wkrtpo = '0'
415kAC                   exsr      zzupd1
415kAC                   goto      endsc1
415kA*
415kAC                   other
     C                   eval      nxtscr = '07 '
415kAC                   eval      rtnto = *blanks
     C                   goto      endsc1
415kAC                   endsl
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
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C     redspl        cabeq     *on           endsc1
     *
     C                   eval      usrrpl = *off
     C                   eval      bypass = *off
     C                   eval      wkrtpo = '0'
417kA*
417kA*   Check if warehouse changed. If yes, get all new options.
417kA*
417kAC                   if        w1whse <> svwhse
417kAC                   eval      svwhse = w1whse
417kAC                   eval      kywhse = w1whse
417kA*
415lA*
415lA*    Check for putaway option - Manual or directed.
415lA*
415lAC                   eval      kydwhs = w1whse
415lAC                   eval      kydwdp = w1whdp
415lAC                   exsr      zzrtno
600pA*
600pA*    Retrieve Check "To Slot" quantity option.
600pAC                   exsr      zzcqty
     *
     *    Check installed feature level.
     *
     C                   eval      kywhse = w1whse
     C                   exsr      zzfeat
417kA*
417kAC                   endif
     *
417iAC                   eval      spfcrp = '*YES'
600fA*    Set Priority Replen. type to Normal so that we can
600fA*    look for any open Letdowns for the slot scanned.
600fAC                   eval      prptyp = '*NORMAL '
     C                   exsr      zzupd1
417iAC                   eval      spfcrp = '*NO '
     C     error         cabeq     *on           endsc1
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
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
     C                   if        done = *off
416sAC                   if        usrrpl = *on
416sAC                   exsr      zzcls0
500dMC                   eval      curtrn# = pttrn#
500dMC                   exsr      zztrnclose
500bA
500bA*    Undo pulling of license plate
500wA
500wA*    Return quantity that was put into transit.
500wA
500wAC                   if        w2nqty > 0
501bAC                             and not sc2first
500wAC                   exsr      zzzclr$lt210
500wAC                   eval      $tcmd     = '*PUTAWYA'
500wAC                   eval      $tnexttask= 'PUTAWAY'
500wAC                   eval      $tlic#    = curlic#
500wAC                   eval      $tinlic#  = curlic#
500wAC                   eval      $toutlic# = curlic#
500wAC                   eval      $twhse    = #fromslwhse
500wAC                   eval      $twhdp    = #fromslwhdp
500wAC                   eval      $tslot    = #fromsldisp
500wAC                   eval      $titem    = #fromslitem
500wAC                   eval      $titemdsc = #fromithead
500wAC                   eval      $tpartial = *off
500wAC                   eval      $tqty1    = w2nqty
500wAC                   eval      $tqty2    = 0
500wAC                   eval      $tqty3    = 0
500xAC                   eval      $tnorm1   = w2nqty
500xAC                   eval      $tnorm2   = 0
500xAC                   eval      $tnorm3   = 0
500wAC                   exsr      zzzcall$lt210
500wAC                   endif
500vA
500wM*    Return pallet(s) to slot
500bAC
500bAC                   exsr      zzzclr$lt210
500vAC                   eval      $tcmd  = '*PULRTN'
500bAC                   eval      $twhse  = #fromslwhse
500vAC                   eval      $twhdp  = #fromslwhdp
500vAC                   eval      $tslot  = #fromsldisp
500vAC                   eval      $titem  = #fromslitem
500bAC                   eval      $tlic#  = curlic#
500vAC                   eval      $titemdsc = #fromithead
500bAC                   exsr      zzzcall$lt210
416sA*
416sAC                   if        error = *off
416sA*
416sA*    Reset priority replenishment so it can be processed later.
416sA*
416sAC                   select
416sAC                   when      rpltyp = '*PRIORTY'
416sAC     keypr2        chain     prplfil1                           7978
416sAC                   if        not *in79
416sAC                   eval      prflag = 'S'
416sAC                   update    prrec                                78
416sAC                   endif
416sAC                   endsl
416sA*
416sA*    Start an 'IDLE' task, if no open task.
416sA*
416sAC                   eval      curtrn = 0
416sAC                   eval      curtsk = *blanks
416sAC                   eval      curtyp = *blanks
416sAC                   eval      curent = *off
416sAC                   exsr      zztask
416sAC                   if        curent = *off
416sAC                   eval      w1task = 'IDLE  '
500dMC                   exsr      zztrnidle
416sAC                   endif
416sAC                   endif
416sQC                   else
     C                   exsr      zzabrt
PFCaA
PFCaAc*    Call APT Interface.
PFCaAc                   if        logapt
PFCaAc                   if        error = *off
PFCaAc*    Send Replenishment "Travel" record.
750cDc**                 eval      apcmd = aptsk3
750cDc**                 eval      aplbl# = 0
750cDc**                 eval      aptrn# = 0
750cDc**                 eval      aploc = w2fmsl
750cDc**                 exsr      zzapt
750cAc                   eval      apseq# += 1
750cAc                   exsr      clr$apt
tst  c****               eval      $apuser = 'SC2'
750cAC                   eval      $apwhse  = lbwhse
750cAC                   eval      $aplocation = w2fmsl
750cAC                   eval      $dricommand = '*APT'
750cAC                   eval      $drisubcmd  = aptsk_TRAVEL
750cAC                   eval      $drisys2upd = 'D'
750cAC                   eval      chk4err = *off
750cAC                   eval      zmsflag = *off
750cAC                   exsr      zzzdricop
PFCaAc                   endif
PFCaAc                   endif
PFCaA
416sQC                   endif
     *
     *    Unable to abort transaction - re-display screen.
     *
     C                   select
     C                   when      error = *on
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endsl
     C                   if        crtrcd = *on
TEST C                   exsr      zzrmtf
     C                   endif
     C                   endif
600qA*
600qA*    When processing interleaving replenishments, return to
600qA*    put-away program.
600qAC                   if        $scmd = '*INTERLV'
600qAC                   eval      $srtn = '*CANCEL '
600qAC                   endif
600qA*
     C                   eval      nxtscr = 'EOJ'
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
     *    Test for F7 - User selected specific slot replenishment.
     *
     C                   if        *inkg
     C                   eval      refrsh = *off
417hA*
417hA*    Save current values for restarting current interupted
417hA*    transaction.
417hAC                   eval      restrt = *on
417hAC                   eval      lsttyp = rpltyp
417hAC                   eval      hldtrn = pttrn#
417hAC                   eval      hlrtpo = ptrtpo
417hAC                   eval      hldseq = prseq#
417hA*
     C                   if        done = *off
416sAC                   if        usrrpl = *on
416sAC                   exsr      zzcls0
500dMC                   eval      curtrn# = pttrn#
500dMC                   exsr      zztrnclose
500bA
500bA*    Undo pulling of license plate
500wA
500wA*    Return quantity that was put into transit.
500wA
500wAC                   if        w2nqty > 0
501bAC                             and not sc2first
500wAC                   exsr      zzzclr$lt210
500wAC                   eval      $tcmd     = '*PUTAWYA'
500wAC                   eval      $tnexttask= 'PUTAWAY'
500wAC                   eval      $tlic#    = curlic#
500wAC                   eval      $tinlic#  = curlic#
500wAC                   eval      $toutlic# = curlic#
500wAC                   eval      $twhse    = #fromslwhse
500wAC                   eval      $twhdp    = #fromslwhdp
500wAC                   eval      $tslot    = #fromsldisp
500wAC                   eval      $titem    = #fromslitem
500wAC                   eval      $titemdsc = #fromithead
500wAC                   eval      $tpartial = *off
500wAC                   eval      $tqty1    = w2nqty
500wAC                   eval      $tqty2    = 0
500wAC                   eval      $tqty3    = 0
500xAC                   eval      $tnorm1   = w2nqty
500xAC                   eval      $tnorm2   = 0
500xAC                   eval      $tnorm3   = 0
500wAC                   exsr      zzzcall$lt210
500wAC                   endif
500vA
500wM*    Return pallet(s) to slot
500bAC
500bAC                   exsr      zzzclr$lt210
500vAC                   eval      $tcmd  = '*PULRTN'
500bAC                   eval      $twhse  = #fromslwhse
500vAC                   eval      $twhdp  = #fromslwhdp
500vAC                   eval      $tslot  = #fromsldisp
500vAC                   eval      $titem  = #fromslitem
500bAC                   eval      $tlic#  = curlic#
500vAC                   eval      $titemdsc = #fromithead
500bAC                   exsr      zzzcall$lt210
500bA
416sAC                   if        error = *off
416sA*
416sA*    Reset priority replenishment so it can be processed later.
416sA*
416sAC                   select
416sAC                   when      rpltyp = '*PRIORTY'
416sAC     keypr2        chain     prplfil1                           7978
416sAC                   if        not *in79
416sAC                   eval      prflag = 'S'
416sAC                   update    prrec                                78
416sAC                   endif
416sAC                   endsl
416sA*
416sA*    Start an 'IDLE' task, if no open task.
416sA*
416sAC                   eval      curtrn = 0
416sAC                   eval      curtsk = *blanks
416sAC                   eval      curtyp = *blanks
416sAC                   eval      curent = *off
416sAC                   exsr      zztask
416sAC                   if        curent = *off
416sAC                   eval      w1task = 'IDLE  '
500dMC                   exsr      zztrnidle
416sAC                   endif
416sAC                   endif
416sQC                   else
     C                   exsr      zzabrt
416sQC                   endif
     *
     *    Unable to abort transaction - re-display screen.
     *
     C                   select
     C                   when      error = *on
     C                   eval      bypass = *off
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endsl
     C                   if        crtrcd = *on
TEST C                   exsr      zzrmtf
     C                   endif
     C                   endif
     *
     *    User selected specific slot replenishment.
     *
     C                   eval      refrsh = *on
     C                   eval      w1tdis = *blanks
720aAC                   eval      w1lcns = *blanks
720aAC                   eval      w1scan = *blanks
     C                   eval      usrrpl = *off
     C                   exsr      scr01i
415kAC                   eval      rtnto = 'LETDOWN '
     C                   goto      endsc2
     C                   endif
416oA*
416oA*  Test for F8 - Zero letdown, log exception and then display
416oA*     slot list display.
416oA*
416oAC                   if        *inkh
600qA*
600qA*    Interleaving replenishment in progress,
600qA*    F9=Skip not allowed.
600qAC                   if        $scmd = '*INTERLV'
600rAC                   select
600rAC                   when      e$lng = 'SP'
600sDC*                  eval      errmsg = descsp(26)
600sMC                   eval      errmsg = descsp(28)
600rAC                   other
600sDC*                  eval      errmsg = desc(26)
600sMC                   eval      errmsg = desc(28)
600rAC                   endsl
600qAC                   eval      error = *on
600qAC                   exsr      zm0105
600qAC                   goto      endsc2
600qAC                   endif
600qA*
416oAC                   eval      refrsh = *off
600uMC                   eval      $lwhse3 = w1whse
600uMC                   eval      $litem3 = #fromslitem
600uMC                   eval      $lalwc3 = 'N'
600bA*
600bA*    Display list of slots for user. Current transaction stays open.
600bAC                   call      'IT231'
600uMC                   parm                    $luky
600bAC                   parm      'LT105   '    $rtncd            8
600bA*
600bA*    User chose to switch to Specific Slot replenishments.
600bAC                   if        $rtncd = '*SSR    '
417hA*
417hA*    Save current values for restarting current interupted
417hA*    transaction.
417hAC                   eval      restrt = *on
417hAC                   eval      lsttyp = rpltyp
417hAC                   eval      hldtrn = pttrn#
417hAC                   eval      hlrtpo = ptrtpo
417hAC                   eval      hldseq = prseq#
600iAC                   eval      hldlbl = lblbl#
600jAC     hldtrn        chain(n)  pirtran                            79
600jAC                   if        *in79 <> *on
600jAC                   eval      orgdte = ptsdte
600jAC                   eval      orgtim = ptstim
600jAC                   endif
416oA*
416oA*    Save destination slot for later processing.
416oAC                   eval      balexc = *off
500cMC                   eval      toslot = #picksldisp
416oAC                   eval      errtyp = '*LIST   '
416oAC                   eval      w4item = 'Y'
600iAC                   eval      w1tdis = toslot
600iA*
600iA*  THE FOLLOWING CODE WAS ADDED TO ALLOW CURRENT TRANS TO
600iA*  REMAIN OPEN IF F12 IS TAKEN FROM SPECIFIC SLOT REPLENISHMENT LIKE F7
600i C                   if        done = *off
600iAC                   if        usrrpl = *on
600iAC                   exsr      zzcls0
600iDC*                  exsr      zzclse
600iAC                   eval      curtrn# = pttrn#
600iAC                   exsr      zztrnclose
600iAC                   if        error = *off
600iA*
600iA*    Reset priority replenishment so it can be processed later.
600iA*
600iAC                   select
600iAC                   when      rpltyp = '*PRIORTY'
600iAC     keypr2        chain     prplfil1                           7978
600iAC                   if        not *in79
600iAC                   eval      prflag = 'S'
600iAC                   update    prrec                                78
600iAC                   endif
600iAC                   endsl
600iA*
600iA*    Start an 'IDLE' task, if no open task.
600iA*
600iAC                   eval      curtrn = 0
600iAC                   eval      curtsk = *blanks
600iAC                   eval      curtyp = *blanks
600iAC                   eval      curent = *off
600iAC                   exsr      zztask
600iAC                   if        curent = *off
600jAC                   eval      flgf10 = *on
600iAC                   eval      w1task = 'IDLE  '
600iAC                   exsr      zztrnidle
600jAC                   eval      flgf10 = *off
600iAC                   endif
600iAC                   endif
600iAC                   else
600i C                   exsr      zzabrt
600iAC                   endif
600i *
600iA*    Unable to abort transaction - re-display screen.
600i *
600i C                   select
600i C                   when      error = *on
600i C                   eval      bypass = *off
600i C                   exsr      scr02i
600i C                   goto      endsc2
600i C                   endsl
600i C                   if        crtrcd = *on
600i C                   exsr      zzrmtf
600i C                   endif
600i C                   endif
500bA
500bA*    Undo pulling of license plate
500wA
500wA*    Return quantity that was put into transit.
500wA
500wAC                   if        w2nqty > 0
501bAC                             and not sc2first
500wAC                   exsr      zzzclr$lt210
500wAC                   eval      $tcmd     = '*PUTAWYA'
500wAC                   eval      $tnexttask= 'PUTAWAY'
500wAC                   eval      $tlic#    = curlic#
500wAC                   eval      $tinlic#  = curlic#
500wAC                   eval      $toutlic# = curlic#
500wAC                   eval      $twhse    = #fromslwhse
500wAC                   eval      $twhdp    = #fromslwhdp
500wAC                   eval      $tslot    = #fromsldisp
500wAC                   eval      $titem    = #fromslitem
500wAC                   eval      $titemdsc = #fromithead
500wAC                   eval      $tpartial = *off
500wAC                   eval      $tqty1    = w2nqty
500wAC                   eval      $tqty2    = 0
500wAC                   eval      $tqty3    = 0
500xAC                   eval      $tnorm1   = w2nqty
500xAC                   eval      $tnorm2   = 0
500xAC                   eval      $tnorm3   = 0
500wAC                   exsr      zzzcall$lt210
500wAC                   endif
500vA
500wM*    Return pallet(s) to slot
500bA
500bAC                   exsr      zzzclr$lt210
500vAC                   eval      $tcmd  = '*PULRTN'
500bAC                   eval      $twhse  = #pickslwhse
500vAC                   eval      $twhdp  = #fromslwhdp
500vAC                   eval      $tslot  = #fromsldisp
500vAC                   eval      $titem  = #fromslitem
500bAC                   eval      $tlic#  = curlic#
500vAC                   eval      $titemdsc = #fromithead
500bAC                   exsr      zzzcall$lt210
500bA
600i *
600i *    User selected specific slot replenishment.
600i *
600i C                   exsr      zzspfc
416oA*
600iA*  THE FOLLOWING CODE HAS BEEN REMOVED TO ALLOW CURRENT TRANS TO
600iA*  REMAIN OPEN IF F12 IS TAKEN FROM SPECIFIC SLOT REPLENISHMENT LIKE F7
416oA*    Write slot exception record only when full system in use.
416oA*    This will prevent letdown(s) from being generated from this
416oA*    location till file is cleared the next day via pgm SL405.
600iDC*                  if        opfeat = '2'
cbicDC*                  exsr      zzexsl
600iDC*                  endif
416oA*
600iDC*                  exsr      zzupd4
416oAC                   eval      errtyp = *blanks
600iDC*                  eval      w4item = 'N'
600bAC                   endif
416oAC                   goto      endsc2
416oAC                   endif
     *
     *  Test for F9 - Bypass transaction
     *
     C                   if        *inki
600qA*
600qA*    Interleaving replenishment in progress,
600qA*    F9=Skip not allowed.
600qAC                   if        $scmd = '*INTERLV'
600rAC                   select
600rAC                   when      e$lng = 'SP'
600sDC*                  eval      errmsg = descsp(27)
600sMC                   eval      errmsg = descsp(29)
600rAC                   other
600sDC*                  eval      errmsg = desc(27)
600sMC                   eval      errmsg = desc(29)
600rAC                   endsl
600qAC                   eval      error = *on
600qAC                   exsr      zm0105
600qAC                   goto      endsc2
600qAC                   endif
600qA*
     C                   eval      bypass = *on
     C                   eval      refrsh = *off
     C                   eval      savtrn = pttrn#
     C                   eval      svrtpo = ptrtpo
     C                   eval      savseq = prseq#
650eAC                   eval      idx = idx + 1
650eAC                   eval      hldseqAlpha = %char(prseq#)
650eAC                   movel     prwhdp        whdp_seq(idx)
650eAC                   move      hldseqAlpha   whdp_seq(idx)
     C                   if        done = *off
416sAC                   if        usrrpl = *on
416sAC                   exsr      zzcls0
500dMC                   eval      curtrn# = pttrn#
500dMC                   exsr      zztrnclose
500bA
500bA*    Undo pulling of license plate
500wA
500wA*    Return quantity that was put into transit.
500wA
500wAC                   if        w2nqty > 0
501bAC                             and not sc2first
500wAC                   exsr      zzzclr$lt210
500wAC                   eval      $tcmd     = '*PUTAWYA'
500wAC                   eval      $tnexttask= 'PUTAWAY'
500wAC                   eval      $tlic#    = curlic#
500wAC                   eval      $tinlic#  = curlic#
500wAC                   eval      $toutlic# = curlic#
500wAC                   eval      $twhse    = #fromslwhse
500wAC                   eval      $twhdp    = #fromslwhdp
500wAC                   eval      $tslot    = #fromsldisp
500wAC                   eval      $titem    = #fromslitem
500wAC                   eval      $titemdsc = #fromithead
500wAC                   eval      $tpartial = *off
500wAC                   eval      $tqty1    = w2nqty
500wAC                   eval      $tqty2    = 0
500wAC                   eval      $tqty3    = 0
500xAC                   eval      $tnorm1   = w2nqty
500xAC                   eval      $tnorm2   = 0
500xAC                   eval      $tnorm3   = 0
500wAC                   exsr      zzzcall$lt210
500wAC                   endif
500vA
500wM*    Return pallet(s) to slot
500bA
500bAC                   exsr      zzzclr$lt210
500vAC                   eval      $tcmd  = '*PULRTN'
500bAC                   eval      $twhse  = #fromslwhse
500vAC                   eval      $twhdp  = #fromslwhdp
500vAC                   eval      $tslot  = #fromsldisp
500vAC                   eval      $titem  = #fromslitem
500bAC                   eval      $tlic#  = curlic#
500vAC                   eval      $titemdsc = #fromithead
500bAC                   exsr      zzzcall$lt210
500bA
416sA*
416sA*    Reset priority replenishment so it can be processed later.
416sA*
416sAC                   select
416sAC                   when      rpltyp = '*PRIORTY'  and
416sAC                             error = *off
416sAC     keypr2        chain     prplfil1                           7978
416sAC                   if        not *in79
416sAC                   eval      prflag = 'S'
416sAC                   update    prrec                                78
416sAC                   endif
416sAC                   endsl
416sQC                   else
     C                   exsr      zzabrt
416sQC                   endif
     *
     *    Unable to abort transaction - re-display screen.
     *
     C                   select
     C                   when      error = *on
     C                   eval      bypass = *off
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endsl
     C                   if        crtrcd = *on
TEST C                   exsr      zzrmtf
     C                   endif
     C                   endif
     *
     *    User chose to bypass transaction - find next let down.
     *
     C                   eval      refrsh = *on
     C                   eval      w1tdis = *blanks
720aAC                   eval      w1lcns = *blanks
720aAC                   eval      w1scan = *blanks
     C                   eval      usrrpl = *off
600fAC                   eval      prptyp = '*IMMED  '
     C                   exsr      zzupd1
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F10 - Exception found with replenishment.
     *
     C                   if        *inkj
     C                   eval      refrsh = *off
417hA*
417hA*    Save current values for restarting current interupted
417hA*    transaction.
417hAC                   eval      restrt = *on
417hAC                   eval      lsttyp = rpltyp
417hAC                   eval      hldtrn = pttrn#
417hAC                   eval      hlrtpo = ptrtpo
417hAC                   eval      hldseq = prseq#
415vA*
415vA*    Save destination slot for later processing.
500cMC                   eval      toslot = #picksldisp
     C                   exsr      scr04i
     C                   goto      endsc2
     C                   endif
510iA*
510iA*  Test for F11 - Call transfer program, bypass transaction.
     *  Code is from F9 skip.
     *
     C                   if        *inkk
510iA*
510iA*    Interleaving replenishment in progress,
510iA*    F11=Skip not allowed.
510iAC                   if        $scmd = '*INTERLV'
510iAC                   select
510iAC                   when      e$lng = 'SP'
600sDC*                  eval      errmsg = descsp(27)
600sMC                   eval      errmsg = descsp(31)
510iAC                   other
600sDC*                  eval      errmsg = desc(27)
600sMC                   eval      errmsg = desc(31)
510iAC                   endsl
510iAC                   eval      error = *on
510iAC                   exsr      zm0105
510iAC                   goto      endsc2
510iAC                   endif
510iA*
510iAC                   eval      bypass = *on
510iAC                   eval      refrsh = *off
510iAC                   eval      savtrn = pttrn#
510iAC                   eval      svrtpo = ptrtpo
510iAC                   eval      savseq = prseq#
510iAC                   if        done = *off
510iAC                   if        usrrpl = *on
510iAC                   exsr      zzcls0
510iDC*                  exsr      zzclse
510iAC                   eval      curtrn# = pttrn#
510iAC                   exsr      zztrnclose
510iA*
510iA*    Reset priority replenishment so it can be processed later.
510iA*
510iAC                   select
510iAC                   when      rpltyp = '*PRIORTY'  and
510iAC                             error = *off
510iAC     keypr2        chain     prplfil1                           7978
510iAC                   if        not *in79
510iAC                   eval      prflag = 'S'
510iAC                   update    prrec                                78
510iAC                   endif
510iAC                   endsl
510iAC                   else
510iAC                   exsr      zzabrt
510iAC                   endif
     *
510i *    Unable to abort transaction - re-display screen.
     *
510iAC                   select
510iAC                   when      error = *on
510iAC                   eval      bypass = *off
510iAC                   exsr      scr02i
510iAC                   goto      endsc2
510iAC                   endsl
510iAC                   if        crtrcd = *on
510iAC                   exsr      zzrmtf
510iAC                   endif
510iAC                   endif
510iA*
510iA*    Call RF transfer.                                           en.
510iAC                   eval      $lwhse = lbwhse
510iAC                   eval      $lwhdp = lbwhdp
510iAC                   eval      $litem = lbitem
510iAC                   eval      $ldisp = lbdisp
510iAC                   eval      $ldsp2 = lbdsp2
510iAC                   call      'IT250'
510iAC                   parm                    $lparm
510iA*
510i *
510i *    If transfer done, bypass transaction - find next let down.
510i *
510iAC                   if        $lrtn <> '*OKTFR  '
510iAC                   eval      bypass = *off
510iAC                   endif
510iA*
510iAC                   eval      refrsh = *on
510iAC                   eval      w1tdis = *blanks
720aAC                   eval      w1lcns = *blanks
720aAC                   eval      w1scan = *blanks
510iAC                   eval      usrrpl = *off
510iAC                   eval      prptyp = '*IMMED  '
510iAC                   exsr      zzupd1
510iAC                   goto      endsc2
510iAC                   endif
510iA*************
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
710eAC                   eval      *in44 = *off
     C                   if        done = *off
416sAC                   if        usrrpl = *on
416sAC                   exsr      zzcls0
500dMC                   eval      curtrn# = pttrn#
500dMC                   exsr      zztrnclose
500bA
500bA*    Undo pulling of license plate
500wA
500wA*    Return quantity that was put into transit.
500wA
500wAC                   if        w2nqty > 0
501bAC                             and not sc2first
500wAC                   exsr      zzzclr$lt210
500wAC                   eval      $tcmd     = '*PUTAWYA'
500wAC                   eval      $tnexttask= 'PUTAWAY'
500wAC                   eval      $tlic#    = curlic#
500wAC                   eval      $tinlic#  = curlic#
500wAC                   eval      $toutlic# = curlic#
500wAC                   eval      $twhse    = #fromslwhse
500wAC                   eval      $twhdp    = #fromslwhdp
500wAC                   eval      $tslot    = #fromsldisp
500wAC                   eval      $titem    = #fromslitem
500wAC                   eval      $titemdsc = #fromithead
500wAC                   eval      $tpartial = *off
500wAC                   eval      $tqty1    = w2nqty
500wAC                   eval      $tqty2    = 0
500wAC                   eval      $tqty3    = 0
500xAC                   eval      $tnorm1   = w2nqty
500xAC                   eval      $tnorm2   = 0
500xAC                   eval      $tnorm3   = 0
500wAC                   exsr      zzzcall$lt210
500wAC                   endif
500vA
500wM*    Return pallet(s) to slot
500bA
500bAC                   exsr      zzzclr$lt210
500vAC                   eval      $tcmd  = '*PULRTN'
500bAC                   eval      $twhse  = #pickslwhse
500vAC                   eval      $twhdp  = #fromslwhdp
500vAC                   eval      $tslot  = #fromsldisp
500vAC                   eval      $titem  = #fromslitem
500bAC                   eval      $tlic#  = curlic#
500vAC                   eval      $titemdsc = #fromithead
500bAC                   exsr      zzzcall$lt210
500bA
416sA*
416sAC                   if        error = *off
416sA*
416sA*    Mark priority replenishment as done since user is logging error.
416sA*
416sAC                   select
416sAC                   when      rpltyp = '*PRIORTY'
416sAC     keypr2        chain     prplfil1                           7978
416sAC                   if        not *in79
416sAC                   eval      prflag = 'S'
416sAC                   update    prrec                                78
416sAC                   endif
416sAC                   endsl
416sA*
416sA*    Start an 'IDLE' task, if no open task.
416sA*
416sAC                   eval      curtrn = 0
416sAC                   eval      curtsk = *blanks
416sAC                   eval      curtyp = *blanks
416sAC                   eval      curent = *off
416sAC                   exsr      zztask
416sAC                   if        curent = *off
416sAC                   eval      w1task = 'IDLE  '
500dMC                   exsr      zztrnidle
416sAC                   endif
416sAC                   endif
416sQC                   else
     C                   exsr      zzabrt
416sQC                   endif
     *
     *    Unable to abort transaction - re-display screen.
     *
     C                   select
     C                   when      error = *on
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endsl
     C                   if        crtrcd = *on
TEST C                   exsr      zzrmtf
     C                   endif
     C                   endif
     *
     C                   select
600qA*
600qA*    When processing interleaving replenishments, return to
600qA*    put-away program.
600qAC                   when      $scmd = '*INTERLV'
600qAC                   eval      $srtn = '*CANCEL '
600qAC                   eval      nxtscr = 'EOJ'
600qA*
     C                   when      rpltyp = '*SPECIFC'
     C                   exsr      scr01i
     *
     C                   other
     C                   exsr      scr07i
     C                   endsl
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
650nAC                   if        pttask = 'REPLBK'
650nAC                   eval      it276Flag = *off
650nAC                   endif
     C     error         cabeq     *on           endsc2
     C     redspl        cabeq     *on           endsc2
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
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr03i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F10 - Exception found with replenishment.
     *
     C                   if        *inkj
     C                   eval      refrsh = *off
     C                   exsr      scr04i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
520cAC                   z-add     w3repq        rvrepq
520cAC                   z-add     w3pulq        rvpulq
     C                   exsr      zzrvrs
     C                   exsr      scr02i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for other command keys
     *
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
     C     redspl        cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
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
     C                   eval      refrsh = *off
     C                   exsr      scr02i
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
     C                   if        *inkl
     C                   eval      refrsh = *off
414kAC                   select
414kAC                   when      lstscr = '08 '
414kAC                   eval      lstscr = *blanks
414kAC                   exsr      scr08i
414kAC                   other
     C                   exsr      scr02i
414kAC                   endsl
     C                   goto      endsc4
     C                   endif
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
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc5
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr05i
     C                   goto      endsc5
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl

601AA*    Move qty from USR slot back into normal slot.
601aA
601aAC                   eval      rvpulq = w2nqty
601aAC                   if        pttask = 'REPLBK  '
601aAC                   eval      rvrepq = lbqrmn
601aAC                   else
601aAC                   eval      rvrepq = lbqpck
601aAC                   endif
601aAC                   exsr      zzrvrs
414 A*
414 A*    When user has created a specific slot replen,
414 A*    and pull slot is a single slot, we have to remove
414 A*    the current transaction. This is because we go
414 A*    back to IT276 where the user could create a new repl.
500mA*
500mA*    OR slot has multiple positions and tracking slot position.
414 A*
414 AC                   select
500wMC                   when      rpltyp = '*SPECIFC'
500wDC**                           #fromslpos <= 1
500wDC**                           or
500wDC**                           rpltyp = '*SPECIFC'  and
500wDC**                           #fromslpos > 1  and
500wDC**                           trackpos = 'Y'
500wA
500wA*      Return quantity that was put into transit.
500wA
500wAC                   exsr      zzzclr$lt210
500wAC                   eval      $tcmd     = '*PUTAWYA'
500wAC                   eval      $tnexttask= 'PUTAWAY'
500wAC                   eval      $tlic#    = curlic#
500wAC                   eval      $tinlic#  = curlic#
500wAC                   eval      $toutlic# = curlic#
500wAC                   eval      $twhse    = #fromslwhse
500wAC                   eval      $twhdp    = #fromslwhdp
500wAC                   eval      $tslot    = #fromsldisp
500wAC                   eval      $titem    = #fromslitem
500wAC                   eval      $titemdsc = #fromithead
500wAC                   eval      $tpartial = *off
500wAC                   eval      $tqty1    = w2nqty
500wAC                   eval      $tqty2    = 0
500wAC                   eval      $tqty3    = 0
500xAC                   eval      $tnorm1   = w2nqty
500xAC                   eval      $tnorm2   = 0
500xAC                   eval      $tnorm3   = 0
500wAC                   exsr      zzzcall$lt210
500wA
500wA*      Return pallet(s) to slot (Already done for REPLBK).
500wAC
500wAC                   if        pttask <> 'REPLBK'
500wAC                   exsr      zzzclr$lt210
500wAC                   eval      $tcmd  = '*PULRTN'
500wAC                   eval      $twhse  = #fromslwhse
500wAC                   eval      $twhdp  = #fromslwhdp
500wAC                   eval      $tslot  = #fromsldisp
500wAC                   eval      $titem  = #fromslitem
500wAC                   eval      $tlic#  = curlic#
500wAC                   eval      $titemdsc = #fromithead
500wAC                   exsr      zzzcall$lt210
500wAC                   endif
414 AC                   eval      bypass = *on
414 AC                   exsr      zzabrt
414 AC                   eval      bypass = *off
414 A*
414 A*    Unable to abort transaction - re-display screen.
414 A*
414 AC                   select
414 AC                   when      error = *on
414 AC                   exsr      scr05i
414 AC                   goto      endsc5
414 AC                   endsl
414 AC                   if        crtrcd = *on
414 AC                   exsr      zzrmtf
414 AC                   endif
414 AC                   exsr      zzspfc
414 A*
414 AC                   other
414 A*
601aDC**                 z-add     w2nqty        rvpulq
601aDC**                 if        pttask = 'REPLBK  '
601aDC**                 eval      rvrepq = lbqrmn
601aDC**                 else
601aDC**                 eval      rvrepq = lbqpck
601aDC**                 endif
601aDC**                 exsr      zzrvrs
     C                   exsr      scr02i
414 AC                   endsl
     C                   goto      endsc5
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
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc6
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr06i
     C                   goto      endsc6
     C                   endif
     *
     *  Test for F7 - User selected specific slot replenishment.
     *
     C                   if        *inkg
     C                   eval      refrsh = *on
     C                   eval      w1tdis = *blanks
720aAC                   eval      w1lcns = *blanks
720aAC                   eval      w1scan = *blanks
     C                   eval      usrrpl = *off
     C                   exsr      scr01i
415kAC                   eval      rtnto = 'LETDOWN '
     C                   goto      endsc6
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     *R                   EXSR SCR01I
     C                   exsr      scr07i
     C                   goto      endsc6
     C                   endif
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
CBIaA*
CBIaA*  Assume ENTER pressed and treat like F12.
CBIaA*
CBIaAC                   eval      refrsh = *off
CBIaAC                   exsr      scr07i
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
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc7
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr07i
     C                   goto      endsc7
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc7
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd7
     C     cmdtkn        cabeq     *on           endsc7
415oAC     error         cabeq     *on           endsc7
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk7
     C     error         cabeq     *on           endsc7

650bA*    If user selected ALL replenishment types and/or departments,
650bA*    use zzupd7ALL to do the loop processing, else, use zzupd7.

650bAC                   if        w7rplt = 'A' or
650bAC                             w7whdp = '*ALL '
650bAC                   exsr      zzupd7ALL
650bAC                   else
500faC                   exsr      zzupd7
650bAC                   endif

500fAC     error         cabeq     *on           endsc7
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
     C                   eval      refrsh = *on
710dAC                   eval      *in82 = *off
414kAC                   exsr      scr08i
     C                   goto      endsc8
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
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
416aAC     redspl        cabeq     *on           endsc8
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
417cA*
417cA*----------------------------------------------------------------
417cA*
417cA*  SC9  -  Screen 9
417cA*
417cAC     sc9           begsr
417cA*
417ca*  Test for F3 - Exit
417cA*
417cAC                   if        *inkc
417cAC                   eval      nxtscr = '09 '
417cAC                   goto      endsc9
417cAC                   endif
417cA*
417cA*  Test for F5 - Refresh
417cA*
417cAC                   if        *inke
417cAC                   eval      refrsh = *on
417cAC                   exsr      scr09i
417cAC                   goto      endsc9
417cAC                   endif
417cA*
417cA*  Test for F12 - Previous
417cA*
417cAC                   if        *inkl
417cAC                   eval      nxtscr = '09 '
417cAC                   goto      endsc9
417cAC                   endif
417cA*
417cA*  Test for other command keys BEFORE verification and update.
417cA*
417cAC                   eval      cmdchk = '*BEFORE '
417cAC                   exsr      zzcmd9
417cAC     cmdtkn        cabeq     *on           endsc9
417cA*
417cA*  Some other key pressed.
417cA*
417cA*     Check input and write/update record.
417cA*
417cAC                   exsr      zzchk9
417cAC     error         cabeq     *on           endsc9
417cAC     redspl        cabeq     *on           endsc9
417cAC                   exsr      zzupd9
417cAC     error         cabeq     *on           endsc9
417cA*
417cA*  Test for other command keys AFTER verification and update.
417cA*
417cAC                   eval      cmdchk = '*AFTER  '
417cAC                   exsr      zzcmd9
417cAC     cmdtkn        cabeq     *on           endsc9
417cA*
417cAC     endsc9        endsr
640b *----------------------------------------------------------------
640b *
640b *  SC6a -  Screen 6a
640b *
640b C     sc6a          begsr
640b *
640b *  Test for F3 - Exit
640b *
640b C                   if        *inkc
640b C                   endif
640b *
640b *  Test for F5 - Refresh
640b *
640b C                   if        *inke
640b C                   endif
640b *
640b *
640b *  Test for F12 - Previous
640b *
640b C                   if        *inkl
640b C                   endif
640b *
640b *  Test for other command keys BEFORE verification and update.
640b *
640b C                   eval      cmdchk = '*BEFORE '
640b C                   exsr      zzcmd6a
640b C     cmdtkn        cabeq     *on           endsc6a
640b *
640b *  Some other key pressed.
640b *
640b *     Check input and write/update record.
640b *
640b C     error         cabeq     *on           endsc6a
640b C                   exsr      zzupd6a
640b C     error         cabeq     *on           endsc6a
640b *
640b *  Test for other command keys AFTER verification and update.
640b *
640b C                   eval      cmdchk = '*AFTER  '
640b C                   exsr      zzcmd6a
640b C     cmdtkn        cabeq     *on           endsc6a
640b *
640b C     endsc6a       endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  SC11 -  Screen 11
650bA*
650bAC     sc11          begsr
650bA*
650bA*  Test for F3 - Exit
650bA*
650bAC                   if        *inkc
650bAC                   eval      nxtscr = 'EOJ'
650bAC                   goto      endsc11
650bAC                   endif
650bA*
650bA*  Some other key pressed.
650bA*
650bA*     Check input and write/update record.
650bA*
650bAC                   exsr      zzchk11
650bAC     error         cabeq     *on           endsc11
650bAC     redspl        cabeq     *on           endsc11
650bAC                   exsr      zzupd11
650bAC     error         cabeq     *on           endsc11
650bA*
650bAC     endsc11       endsr
650bA*
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
     *----------------------------------------------------------------
     *    chkForDD  -  Check for Drop Pick Replenishments
     *                 if found it sets a string that is display
     *                 at top of screen alering operator
     *----------------------------------------------------------------
740 Ac     chkForDD      begsr
740 A *   Display Drop Picks message if they exist for whse and dept
740 A /free
740 A            *in45=*off;
740 A            w7ddmsg=*blanks;
740 A            if w7whdp = '*ALL';
740 A              setll (w7whse:'D') prplfil9;
740 A            else;
740 A              setll (w7whse:w7whdp:'D') prplfil6;
740 A            endif;
740 A            dow forever = forever;
740 A              if w7whdp = '*ALL';
740 A                reade (w7whse:'D') prplfil9;
740 A                if not %equal(prplfil9) or %eof(prplfil9);
740 A                  leave;
740 A                endif;
740 A                if p9_prflag = 'S';
740 A                  w7ddmsg='Drop Picks Exist (Type=D)';
740 A                  *in45=*on;
740 A                  leave;
740 A                endif;
740 A              else;
740 A                reade (w7whse:w7whdp:'D') prplfil6;
740 A                if not %equal(prplfil6) or %eof(prplfil6);
740 A                  leave;
740 A                endif;
740 A                if dd_prflag = 'S';
740 A                  w7ddmsg='Drop Picks Exist (Type=D)';
740 A                  *in45=*on;
740 A                  leave;
740 A                endif;
740 A              endif;
740 A            enddo;
740 A /end-free
740 Ac                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
510hAC                   select
510hAC                   when      #lline = '16'
510hAC                   write     m16ctl
510hAC                   other
     C                   write     msgctl
510hAC                   endsl
     C                   eval      msgk = *zeros
510hAC                   select
510hAC                   when      #lline = '16'
510hAC                   write     m16clr
510hAC                   other
     C                   write     msgclr
510hAC                   endsl
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
510hAC                   select
510hAC                   when      #lline = '16'
510hAC                   write     m16ctl
510hAC                   other
     C                   write     msgctl
510hAC                   endsl
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
600rAC                   select
600rAC                   when      e$lng = 'SP'
600rAC                   eval      $msgf = #msgsp
600rAC                   other
     C                   eval      $msgf = #msgf
600rAC                   endsl
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
510hAC                   select
510hAC                   when      #lline = '16'
510hAC                   write     m16rec
510hAC                   other
     C                   write     msgrec
510hAC                   endsl
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
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
510hAC                   select
510hAC                   when      #lline = '16'
510hAC                   write     m16rec
510hAC                   other
     C                   write     msgrec
510hAC                   endsl
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

640e *----------------------------------------------------------------
640e *     PIR0153  Qty changed slot unavailable for replenishment.
640e *
640e C     zm0153        begsr
640e C                   eval      #msgid = 'PIR0153'
640e C                   eval      #msgtp = '*DIAG  '
640e C                   movea     errmsg        $md(1)
640e C                   exsr      zmpmsg
640e C                   eval      $lmsg = #msgk
640e C                   endsr
     *----------------------------------------------------------------
     *    PIR0203  Value cannot be blank.
     *
     C     zm0203        begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR1051  Inactive slot unavailable for replenishment.
     *
     C     zm1051        begsr
     C                   eval      #msgid = 'PIR1051'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   eval      $lmsg = #msgk
     C                   endsr
710e *----------------------------------------------------------------
710e *     IT15202  From and To slot cannot be same.
710e *
710eAC     zm1522        begsr
710eAC                   move      'IT15202'     #msgid
710eAC                   move      '*DIAG  '     #msgtp
710eAC                   eval      $md = *blanks
710eAC                   exsr      zmpmsg
710eAC                   endsr
415lA*----------------------------------------------------------------
415lA*     IT15203  To slot contains a different item.
415lA*
415lAC     zm1523        begsr
415lAC                   eval      #msgid = 'IT15203'
415lAC                   eval      #msgtp = '*DIAG  '
415lAC                   eval      $md = *blanks
415lAC                   exsr      zmpmsg
415lAC                   endsr
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
     *   RC20003 Put Away Quantity must be > 0.
     *
     C     zm2003        begsr
     C                   eval      #msgid = 'RC20003'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
416qA*----------------------------------------------------------------
416qA*   PIR2007  Invalid slot, slot inactive.
416qA*
416qAC     zm2007        begsr
416qAC                   eval      #msgid = 'PIR2007'
416qAC                   eval      #msgtp = '*DIAG  '
416qAC                   eval      $md = *blanks
416qAC                   exsr      zmpmsg
416qAC                   endsr
     *----------------------------------------------------------------
     *     IT25201  Date sensitive item exists in to slot with dif dte
     *
     C     zm2521        begsr
     C                   eval      #msgid = 'IT25201'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
416bA*----------------------------------------------------------------
416bA*     IT25206  # of pick slots exceeds # allowed.
416bA*
416bAC     zm5206        begsr
416bAC                   eval      #msgid = 'IT25206'
416bAC                   eval      #msgtp = '*DIAG  '
416bAC                   eval      ernpck = nbrpck
416bAC                   eval      erapck = imnrpk
416bAC                   movea     errmsg        $md(1)
416bAC                   exsr      zmpmsg
416bAC                   endsr
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
416bA*----------------------------------------------------------------
416bA*     IT12273  Adjustment not completed - Record doesn't exist.
416bA*
416bAC     zm73          begsr
416bAC                   eval      #msgid = 'IT12273'
416bAC                   eval      #msgtp = '*DIAG  '
416bAC                   eval      $md = *blanks
416bAC                   exsr      zmpmsg
416bAC                   endsr
     *----------------------------------------------------------------
     *   IT13208  Replenishment transaction cannot be cancelled.
     *
     C     zm1320        begsr
     C                   eval      #msgid = 'IT13208'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IT29001  Invalid slot entered.(FROM)
     *
     C     zm2901        begsr
     C                   eval      #msgid = 'IT29001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IT29002  Invalid slot entered.(TO)
     *
     C     zm2902        begsr
     C                   eval      #msgid = 'IT29002'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IT29003 Qty cannot be > system assigned qty.
     *
     C     zm2903        begsr
     C                   eval      #msgid = 'IT29003'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IT29004 Only one of the options can be "Y".
     *
     C     zm2904        begsr
     C                   eval      #msgid = 'IT29004'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IT29005 Only one of the options can be "N".
     *
     C     zm2905        begsr
     C                   eval      #msgid = 'IT29005'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IT29006 No more replenishments.
     *
     C     zm2906        begsr
     C                   eval      #msgid = 'IT29006'
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
     *      0110  Number must be > 0
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
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
     *    IT27001  Slot not a pick slot or not in fixed section.
     *
     C     zm7001        begsr
     C                   eval      #msgid = 'IT27001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
414eA*----------------------------------------------------------------
414eA*    IT27003  Slot department/section not same as item.
414eA*
414eAC     zm7003        begsr
414eAC                   eval      #msgid = 'IT27003'
414eAC                   eval      #msgtp = '*DIAG  '
414eAC                   movea     errmsg        $md(1)
414eAC                   exsr      zmpmsg
414eAC                   endsr
414eA*----------------------------------------------------------------
414eA*    IT27004  Slot designation not same as item.
414eA*
414eAC     zm7004        begsr
414eAC                   eval      #msgid = 'IT27004'
414eAC                   eval      #msgtp = '*DIAG  '
414eAC                   movea     errmsg        $md(1)
414eAC                   exsr      zmpmsg
414eAC                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
416bA*---------------------------------------------------------------
416bA*  Retrieve number of pick slots for item and accumulate
416bA*  number of pick slots assigned to item.
416bA*
416bAC     chkpck        begsr
416bAC     imkey         chain     itemmsc                            79
416bAC                   if        *in79
416bAC                   eval      imnrpk = 1
416bAC                   endif
416bA*
416bA*    Accumulate number of pick slots assigned to item.
416bA*
416bAC                   eval      k3stat = 'A '
416bAC                   eval      k3pick = 'Y'
416bAC     keys3         setll     slot3
416bAC                   eval      nbrpck = *zeros
416bAC                   eval      eof = *off
416bAC                   dow       eof = *off
416bAC     keys3         reade     slot3                                  79
416bAC                   move      *in79         eof
416bAC                   if        not *in79
416bAC                   add       1             nbrpck
416bAC                   endif
416bAC                   enddo
416bAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZABRT   Abort a transaction
     *
     C     zzabrt        begsr
500dAC                   eval      error = *off
     *
     *  Update slot qty (Decrease RCV qty) (To Slot)
     *
     *    Reset values for transaction that was NOT created
     *    by this program.
     *
500dDC** ??              select
500dDC** ??              when      pttask = 'REPL'  and
500dDC** ??                        usrrpl = *off
500dDC** ??              add       svqpck        slrcv1
500dDC** ??              add       svqpck        $saqty1
500dDC** ??              when      pttask = 'REPLBK'  and
500dDC** ??                        usrrpl = *off
500dDC** ??              add       svqrmn        slrcv1
500dDC** ??              add       svqrmn        $saqty1
500dDC** ??              endsl
416fA*
600uDC**                 exsr      clr$slot
600uDC**                 eval      $slwhseu = *on
600uDC**                 eval      $slwhse  = #pickslwhse
600uDC**                 eval      $slwhdpu = *on
600uDC**                 eval      $slwhdp  = #pickslwhdp
600uDC**                 eval      $sldispu = *on
600uDC**                 eval      $sldisp  = #picksldisp
600uDC**                 eval      $saitemu = *on
600uDC**                 eval      $saitem  = #pickslitem
600uDC**                 eval      $satrn#u = *on
600uDC**                 eval      $satrn#  = lbtrn#
600uDC**                 eval      $satasku = *on
600uDC**                 eval      $satask  = pttask
600uDC**                 eval      $saqtyu = *on
600uDC**                 eval      $saqty1 = -(svqpck)
600uDC**                 eval      $sacitemu = *on
600uDC**                 eval      $sacitem  = #fromslitem
600uDC**                 eval      $saqty2 = 0
600uDC**                 eval      $saqty3 = 0
600uDC**                 eval      $dricommand = '*SLOT'
600uDC**                 eval      $drisubcmd = '%TFRINCHG'
600uDC**                 eval      chk4err = *off
600uDC**                 eval      zmsflag = *off
600uDC**                 exsr      zzzdricop
600uDC**
600uDC**                 sub       w2qty         $saqty1
600uDC**                 exsr      clr$slot
600uDC**                 eval      $slwhseu = *on
600uDC**                 eval      $slwhse  = #fromslwhse
600uDC**                 eval      $slwhdpu = *on
600uDC**                 eval      $slwhdp  = #fromslwhdp
600uDC**                 eval      $sldispu = *on
600uDC**                 eval      $sldisp  = #fromsldisp
600uDC**                 eval      $saitemu = *on
600uDC**                 eval      $saitem  = #fromslitem
600uDC**                 eval      $sacitemu = *on
600uDC**                 eval      $sacitem  = #pickslitem
600uDC**                 eval      $satrn#u = *on
600uDC**                 eval      $satrn#  = lbtrn#
600uDC**                 eval      $satasku = *on
600uDC**                 eval      $satask  = pttask
600uDC**                 eval      $saqtyu = *on
600uDC**                 eval      $saqty1 = -(svqpck)
600uDC**                 eval      $saqty2 = 0
600uDC**                 eval      $saqty3 = 0
600uDC**                 eval      $dricommand = '*SLOT'
500pDC**                 eval      $drisubcmd = '%TFROUT'
600uDC**                 eval      $drisubcmd = '%TFROUTCHG'
600uDC**                 eval      chk4err = *off
600uDC**                 eval      zmsflag = *off
600uDC**                 exsr      zzzdricop
416fA*
     *    Abort transaction.
     *
500dAC                   exsr      zztrnabort
     *
     *    Update label record.
     *
     C     lbkey         chain     label                              79
     C                   select
     C                   when      usrrpl = *on  and
     C                             not *in79
     C                   delete    lbrec
     *
     C                   other
     C                   if        not *in79
     C                   eval      lbqalc = svqalc
     C                   eval      lbqpck = svqpck
     C                   eval      lbcube = svcube
     C                   eval      lbswgt = svswgt
     C                   eval      lbqrmn = svqrmn
     C                   update    lbrec
     C                   endif
     *
     C                   endsl
     *
     *    If broken case item - Adjust picking warehouse quantities.
     *
     C                   eval      crtdsc = *off
     *
500wDC
500wDC*    Undo pulling of license plate.
500wDC
500wDC**                 exsr      zzzclr$lt210
500wDC**                 eval      $tcmd   = '*PULUNDO'
500wDC**                 eval      $twhse  = #fromslwhse
500wDC**                 eval      $tlic#  = curlic#
500wDC**                 exsr      zzzcall$lt210
500wA
500wA*    Return quantity that was put into transit.
500wA
500wAC**???              exsr      zzzclr$lt210
500wAC**???              eval      $tcmd     = '*PUTAWYA'
500wAC**???              eval      $tnexttask= 'PUTAWAY'
500wAC**???              eval      $tlic#    = curlic#
500wAC**???              eval      $tinlic#  = curlic#
500wAC**???              eval      $toutlic# = curlic#
500wAC**???              eval      $twhse    = #fromslwhse
500wAC**???              eval      $twhdp    = #fromslwhdp
500wAC**???              eval      $tslot    = #fromsldisp
500wAC**???              eval      $titem    = #fromslitem
500wAC**???              eval      $titemdsc = #fromithead
500wAC**???              eval      $tpartial = *off
500wAC**???              eval      $tqty1    = w1qt01
500wAC**???              eval      $tqty2    = w1qt02
500wAC**???              eval      $tqty3    = w1qt03
500xAC**???              eval      $tnorm1   = w1qt01
500xAC**???              eval      $tnorm2   = w1qt02
500xAC**???              eval      $tnorm3   = w1qt03
500wAC**???              exsr      zzzcall$lt210
     *
     *    Reset priority replenishment so it can be processed later.
     *
     C                   select
     C                   when      rpltyp = '*PRIORTY'
     C     keypr2        chain     prplfil1                           7978
     C                   if        not *in79
     C                   eval      prflag = 'S'
     C                   update    prrec                                78
     C                   endif
     C                   endsl
     *
     C                   eval      usrrpl = *off
     *
     *    Start an 'IDLE' task.
     *      Only if user has not selected to bypass a transaction.
     *
     C                   if        bypass = *off
414fA*
414fA*    Start an 'IDLE' task, if no open task.
414fAC                   eval      curtrn = 0
414fAC                   eval      curtsk = *blanks
414fAC                   eval      curtyp = *blanks
414fAC                   eval      curent = *off
414fAC                   exsr      zztask
414fAC                   if        curent = *off
414fAC                   eval      w1task = 'IDLE  '
500dMC                   exsr      zztrnidle
414fAC                   endif
     C                   endif
     C     endabr        endsr

PFCaA*----------------------------------------------------------------
PFCaA*
PFCaA*  ZZAPT    Call APT interface.
PFCaA
750cDc**   zzapt         begsr
750cD **
750cDc**                 eval      apseq# = apseq# + 1
750cD **
750cDc**                 CALL      'APTMAIN'
750cDc**                 PARM                    APCMD            10
750cDc**                 PARM      #PROG         APPGM            10
750cDc**                 PARM      LBWHSE        APWHSE            3 0
750cDc**                 PARM                    APLBL#            7 0
750cDc**                 PARM                    APTRN#            7 0
750cDc**                 PARM      #USER         APUSER           10
750cDc**                 PARM      #EMP#         APEMP#            5 0
750cDc**                 PARM                    APRTID            5
750cDc**                 PARM      *BLANKS       APRTE             5
750cDc**                 PARM                    APLOC            20
750cDc**                 PARM                    APSEQ#            5 0
750cDc**                 PARM                    APRTN            10
750cDc**                 PARM                    APMSG            60
750cD **
750cDc**                 endsr
PFCaA
500dA*----------------------------------------------------------------
500dA*  ZZASKZROVFY  See if we should ask user to zero verify the slot
500dA*----------------------------------------------------------------
500dA
500dAC     zzaskzrovfy   begsr
500dAC                   eval      askzrovfy = *off

     C                   dow       forever = forever

     *  Ask the user to zero verify slot if ...

     *  ... the replenishment is not for a Breakdown item.

     C** ?????           if        rpltype = 'B'
     C** ?????           leave
     C** ?????           endif

     *  ... the slot only has 1 pallet position.

     C                   if        #fromslpos > 1
640gAC                             and #fromslvirt = 'Y'
     C                   leave
     C                   endif

     *  ... the slot doesn't have a virtual slot associated with it.

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
600nDC** ... slot quantities don't reflect other activity.
600nDC**
600nDC**                 if        #fromslalc1 <> 0 or
600nDC**                           #fromslalc2 <> 0 or
600nDC**                           #fromslalc3 <> 0 or
600nDC**                           #fromslrcv1 <> 0 or
600nDC**                           #fromslrcv2 <> 0 or
600nDC**                           #fromslrcv3 <> 0 or
600nDC**                           #fromsltfr1 - w2nqty <> 0 or
600nDC**                           #fromsltfr2 <> 0 or
600nDC**                           #fromsltfr3 <> 0
600nDC**                 leave
600nDC**                 endif
600nDC**
600nDC** ... slot's available quantity is zero.
600nDC**
600nDC**                 if        #fromslavl1 <> 0 or
600nDC**                           #fromslavl2 <> 0 or
600nDC**                           #fromslavl3 <> 0
600nDC**                 leave
600nDC**                 endif

     *  ... slot is either not a virtual slot or
     *      it is the only virtual and the base slot is empty.

     C                   if        #fromslrsrv = 'V'

     *        Get base slot info.

     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = #frombasesldsp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
     C                   leave
     C                   endif

     *        Status must be 'Z' or 'V'

     C                   if        $slstat <> 'V' and $slstat <> 'Z'
     C                   leave
     C                   endif

     *        See if any other virtuals are associated with slot.

     C                   eval      $sacdspu = *on
     C                   eval      $sacdsp = $sldisp
     C                   eval      $sldisp = ' '
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%NXTVSLOT'
     C                   eval      $drisys2upd = 'D'
     C                   dow       forever = forever
     C                   exsr      zzzdricop
     C                   if        error or $drireturn = 'EOF'
     C                   leave
     C                   endif
     C                   if        $sldisp = #fromsldisp
     C                   iter
     C                   endif
640gAC                   if        $slstat = 'Z' or $slstat = 'V'
640gAC                   iter
640gAC                   endif
     C                   leave
     C                   enddo
     C                   if        $drireturn <> 'EOF'
     C                   leave
     C                   endif

     C                   endif

     *  Whew! We have finally determined that we can have the user
     *     verify if the slot is physically empty.

     C                   eval      askzrovfy = *on

     C                   leave
     C                   enddo

     C     endaskzrovfy  endsr

     *----------------------------------------------------------------
     *
     *  ZZBITM   Broken case item
     *
     C     zzbitm        begsr
     C     ilkey         chain     piritem                            79
     C                   if        *in79
     C                   eval      ittype = *blanks
     C                   else
     C                   eval      svtype = ittype
     C                   endif
     *
     C     ilkey         chain     itemlnk                            79
     C                   if        *in79
     C                   eval      ilitm2 = *blanks
     C                   eval      ilitm3 = *blanks
     C                   endif
     C                   select
     C                   when      svtype = 'C'
     C                   eval      kyitem = ilitm3
     C                   other
     C                   eval      kyitem = ilitm2
     C                   endsl
     *
     C     itkey         chain     piritem                            79
     C                   if        *in79
     C                   eval      itumq2 = *zeros
     C                   eval      itumq3 = *zeros
     C                   endif
     C                   eval      svumq2 = itumq2
     C                   eval      svumq3 = itumq3
     C                   if        svtype = 'C'
     C                   eval      $iitem = ilitm3
     C                   else
     C                   eval      $iitem = ilitm2
     C                   endif
     *
     *    A transaction is being aborted - bypass description build.
     *
     C     crtdsc        cabeq     *on           endbit
     *
     C                   eval      $idesc = pitdsc
     C                   eval      $ipdsc = pitpds
     C                   exsr      zzgeti
     C     endbit        endsr
415cA*----------------------------------------------------------------
415cA*
415cA*  ZZCLS0   Close transaction to Zero
415cA*
415cAC     zzcls0        begsr
415cA*
415cAC                   eval      topick = *zeros
415cA*    Update pick quantity in label record.
415cAC     lbkey         chain     label                              79

500dAC                   eval      lbqpck = 0
500dAC                   eval      lbqrmn = 0
500dAC                   eval      lbcube = 0
500dAC                   eval      lbswgt = 0
501aA*    No qty putaway. Close label record.
501aAC                   eval      lbstat = 'C'
501aAC                   exsr      zzgetdatetime
501aAC                   eval      lbsdte = curdate
501aAC                   eval      lbstim = curtime

415cAC                   update    lbrec
415cA*    Update quantity in transaction record.
500dMC     ptkey         chain(n)  pirtran                            79
600jA*    Update start date/time if transation was reset open for spec rpl.
500dAC                   exsr      zztrnzero
600uDC**   Update transfer quantity in slot record.(From slot)
600uDC**
600uDC**                 exsr      clr$slot
600uDC**
600uDC**                 eval      $slwhseu = *on
600uDC**                 eval      $slwhse  = #fromslwhse
600uDC**                 eval      $slwhdpu = *on
600uDC**                 eval      $slwhdp  = #fromslwhdp
600uDC**                 eval      $sldispu = *on
600uDC**                 eval      $sldisp  = #fromsldisp
600uDC**                 eval      $saitemu = *on
600uDC**                 eval      $saitem  = #fromslitem
600uDC**                 eval      $sacwhdu = *on
600uDC**                 eval      $sacwhd  = wuUsrWhdp
600uDC**                 eval      $sacdspu = *on
600uDC**                 eval      $sacdsp  = wuUsrDisp
600uDC**                 eval      $sacitemu = *on
500rDC**                 eval      $sacitem  = #fromslitem
600uDC**                 eval      $sacitem  = #pickslitem
600uDC**                 eval      $satrn#u = *on
600uDC**                 eval      $satrn#  = lbtrn#
600uDC**                 eval      $satasku = *on
600uDC**                 eval      $satask  = pttask
600uDC**                 eval      $saqtyu = *on
600uDC**                 eval      $saqty1 = -(svqpck)
600uDC**                 eval      $saqty2 = 0
600uDC**                 eval      $saqty3 = 0
600uDC**                 eval      $dricommand = '*SLOT'
500pDC**                 eval      $drisubcmd = '%TFROUT'
600uDC**                 eval      $drisubcmd = '%TFROUTCHG'
600uDC**                 eval      chk4err = *off
600uDC**                 eval      zmsflag = *off
600uDC**                 exsr      zzzdricop
600uDC**
600uDC**   Update receive quantity in slot record.(To slot)
600uDC**
600uDC**                 exsr      clr$slot
600uDC**
600uDC**                 eval      $slwhseu = *on
600uDC**                 eval      $slwhse  = #pickslwhse
600uDC**                 eval      $slwhdpu = *on
600uDC**                 eval      $slwhdp  = #pickslwhdp
600uDC**                 eval      $sldispu = *on
600uDC**                 eval      $sldisp  = #picksldisp
600uDC**                 eval      $saitemu = *on
600uDC**                 eval      $saitem  = #pickslitem
600uDC**                 eval      $sacitemu = *on
600uDC**                 eval      $sacitem  = #fromslitem
600uDC**                 eval      $satrn#u = *on
600uDC**                 eval      $satrn#  = lbtrn#
600uDC**                 eval      $satasku = *on
600uDC**                 eval      $satask  = pttask
600uDC**                 eval      $saqtyu = *on
600uDC**                 eval      $saqty1 = -(svqpck)
600uDC**                 eval      $saqty2 = 0
600uDC**                 eval      $saqty3 = 0
600uDC**                 eval      $dricommand = '*SLOT'
600uDC**                 eval      $drisubcmd = '%TFRINCHG'
600uDC**                 eval      chk4err = *off
600uDC**                 eval      zmsflag = *off
600uDC**                 exsr      zzzdricop
415cA*
415cAC     endcl0        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *    Verify warehouse and get description.
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
     *    Verify warehouse department.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
720aA*
720aA*  Did user scan a license - this is only valid if replenishment
720aA*  option OPSSLCN is turned on.
720aA*
720aA /free
720aA   if opsslcn = 'Y';
720aA     // did the user scan a license?
730aA     ladisp = ' ';
720aA     if w1scan <> ' ';
720aA       w1lcns = w1scan;
720aA       w1tdis = w1scan;
720aA       chain (w1whse: w1lcns) licactive;
720aA       if %found(licactive) and laaisl='RPA';
720iD          // Removed all 720g code to make more readable.  Old code
720iD          // can be found in PIROLD720
720aA          // blank out slot field - will get that from it278
720aA          w1whdp=lawhdp;
720aA          w1tdis = ' ';
720aA          IT278(#PGM: lawhse: lawhdp: w1tdis: laitem: $iReturn);
720dA       else;
720dA         w1lcns = *blanks;
720iA         ladisp=*blanks;
720dA         if %found(licactive);
720dA            error = *on;
720dA            *in21 = *on;
720dA            *in01 = *on;
720dA            errmsg = 'Scanned license must be unprocessed ' +
720iM                     'Staging lcns';
720dA            exsr zm0105;
720aA          endif;
720aA       endif;
720aA     endif;
720fA   else;
720fA     w1tdis = %trim(%subst(w1scan:1:12));
720aa   endif;
720aA /end-free
     *
     *  Call API for slot.
     *
510hA* Set worow/wocol based on the size of the screen being processed
510hAC                   if        #lline = '16'
510hAC                   eval      worow = 6
510hAC                   eval      wocol = 8
510hAC                   else
510hAC                   eval      worow = 6
510hAC                   eval      wocol = 19
510hAC                   endif
     C                   call      @apics
     C                   parm                    w1tdis
510hDC*                  parm      6             worow
510hDC*                  parm      19            wocol
510hMC                   parm                    worow
510hMC                   parm                    wocol
     C                   parm                    @artn             8
     C                   if        @artn = '*REDSPLY'
750aAC                   eval      w1scan = w1tdis
     C                   eval      redspl = *on
     C                   goto      endck1
     C                   endif
     *
     *    Slot can't be blank.
     *
     C                   if        w1tdis = *blanks
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
600rAC                   select
600rAC                   when      e$lng = 'SP'
600rAC                   eval      errmsg = descsp(4)
600rAC                   other
     C                   movea     desc(4)       errmsg
600rAC                   endsl
     C                   exsr      zm0203
     C                   endif
500dA
500dA*  Get slot information.
500dA
500dAC                   eval      getwhse = w1whse
500dAC                   eval      getwhdp = w1whdp
500dAC                   eval      getdisp = w1tdis
500dAC                   exsr      zzgetpicksl
500dAC                   if        error
500dAC                   eval      *in23 = *on
500dAC                   eval      *in03 = *on
500dAC                   goto      endck1
500dAC                   endif
500dA
414kA*
414kA*    Check for virtual slots attached to pick slot.
414kA*
500dAC                   if        #pickslvirt = 'Y'
720aAc                             and w1lcns = ' '
500dAC                   eval      hasvs = *on
500dAC                   else
500dAC                   eval      hasvs = *off
500dAC                   endif
500dA
414kAC                   if        hasvs = *on
414kAC                   eval      $lcmd = '*SELECT '
414kAC                   eval      $lwhse = w1whse
414kAC                   eval      $lwhdp = w1whdp
414kAC                   eval      $ldsp1 = w1tdis
414kAC                   call      'VS820'
414kAC                   parm                    $lparm
414kAC                   select
414kAC                   when      $lrtn = '*SELECT '
414kAC                   eval      w1tdis = $ldsp1
500dAC                   eval      getwhse = w1whse
500dAC                   eval      getwhdp = w1whdp
500dAC                   eval      getdisp = w1tdis
500dAC                   exsr      zzgetpicksl
500dAC                   if        error
500dAC                   eval      *in23 = *on
500dAC                   eval      *in03 = *on
500dAC                   goto      endck1
500dAC                   endif
414kAC                   other
414kAC                   eval      error = *on
414kAC                   endsl
414kAC                   endif
     *
     *    Slot must be a active.
     *
500dMC                   if        #pickslstat <> 'A '
610kAC                             and #pickslstat <> 'RP'
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = sldisp
     C                   exsr      zm1051
     C                   endif
     *
     *    Slot must be a pick slot and in fixed section.
     *
500dMC                   if        #pickslstyp <> 'F'  and
500dMC                             #pickslpick <> 'Y'  or
     *
500vDC**                           not *in79  and
500dMC                             #pickslstyp = 'F'  and
500dMC                             #pickslpick <> 'Y'
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm7001
     C                   endif
     *
     *    Slot must be occupied by item.
     *
500dMC                   if        #pickslitem = *blanks
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
600rAC                   select
600rAC                   when      e$lng = 'SP'
600rAC                   eval      errmsg = descsp(6)
600rAC                   other
     C                   eval      errmsg = desc(6)
600rAC                   endsl
     C                   exsr      zm1001
     C                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
640eA* Get from slot qty to verify qty still available
640fAC                   if        IT276flag = *off
640eAC                   eval      getdisp = #fromsldisp
640eAC                   exsr      zzgetfromsl
650gDC*                  if        w2sltq > (#fromslstk1 + #fromslrcv1)
650gMC                   if        w2sltq > #fromslavl1
640eAC                   eval      error = *on
640eAC                   eval      *in23 = *on
640eAC                   eval      *in03 = *on
640eAC                   eval      errmsg = *blanks
640eAC                   eval      errmsg = sldisp
640eAC                   exsr      zm0153
640eAC                   goto      endck2
640eAC                   endif
640fAC                   endif
500lA*
500lA*    Cannot pull more qty than is currently in the slot
500lA*    or Contract item types cannot have replenishment qty
500lA*    increased.
500lA*
500lAC                   if        w2nqty > w2sltq  or
500lA*
500lAC                             w2nqty > w2repq  and
500lAC                             svtype = 'C'
500lA*
500lAC                   eval      error = *on
500lAC                   eval      *in23 = *on
500lAC                   eval      *in03 = *on
500lAC                   eval      errmsg = *blanks
500lAC                   if        svtype = 'C'
500lAC                   eval      erqty = w2repq
500lAC                   else
500lAC                   eval      erqty = w2sltq
500lAC                   endif
500lAC                   eval      ernqty = w2nqty
500lAC                   exsr      zm2903
500lAC                   goto      endck2
500lAC                   endif
500lA*
500lA*    Replenish qty cannot be less than zero.
500lA*     and Replenish qty cannot be equal to zero.
500lA*
500lAC                   if        w2nqty < 0
610dAC                             or w2nqty = 0
500lAC                   eval      error = *on
500lAC                   eval      *in23 = *on
500lAC                   eval      *in03 = *on
600rAC                   select
600rAC                   when      e$lng = 'SP'
600rAC                   eval      errmsg = descsp(12)
600rAC                   other
500lAC                   eval      errmsg = desc(12)
600rAC                   endsl
500lAC                   exsr      zm0105
500lAC                   goto      endck2
500lAC                   endif
500lA*
500lA*    Replenish qty cannot be less than zero.
500lA*
500lAC                   if        w2nqty <= 0  and
500lAC                             rpltyp = '*LETDOWN'
500lAC                   eval      error = *on
500lAC                   eval      *in23 = *on
500lAC                   eval      *in03 = *on
600rAC                   select
600rAC                   when      e$lng = 'SP'
600rAC                   eval      errmsg = descsp(24)
600rAC                   other
500lAC                   eval      errmsg = desc(24)
600rAC                   endsl
500lAC                   exsr      zm0105
500lAC                   goto      endck2
500lAC                   endif
500lA*
500lA*    Pull qty cannot be greater than slot qty.
500lA*
500lAC                   if        w2nqty > w2sltq
500lAC                   eval      error = *on
500lAC                   eval      *in23 = *on
500lAC                   eval      *in03 = *on
600rAC                   select
600rAC                   when      e$lng = 'SP'
600rAC                   eval      errmsg = descsp(18)
600rAC                   other
500lAC                   eval      errmsg = desc(18)
600rAC                   endsl
500lAC                   exsr      zm0105
500lAC                   goto      endck2
500lAC                   endif
500lA*
500lA*  Calculate difference.
500lA*
610hDC**                 eval      difpck = w2nqty - w2repq
610hMC                   eval      difpck = w2nqty - w2sltq
720aAc* we won't call apicvtslt when pulling from the RPADOCK slot, so
720aAc* the format of the slot display will not be changed on this slot
720aAc                   if        w2scan = 'RPADOCK'
720AAc                   else
     *
     *  Call API for slot.
     *
510hA* Set worow/wocol based on the size of the screen being processed
510hAC                   if        #lline = '16'
510hAC                   eval      worow = 10
510hAC                   eval      wocol = 9
510hAC                   else
510hAC                   eval      worow = 6
510hAC                   eval      wocol = 29
510hAC                   endif
     C                   call      @apics
     C                   parm                    w2scan
510hDC*                  parm      6             worow
510hDC*                  parm      29            wocol
510hMC                   parm                    worow
510hMC                   parm                    wocol
     C                   parm                    @artn
     C                   if        @artn = '*REDSPLY'
     C                   eval      redspl = *on
     C                   goto      endck2
     C                   endif
720aAc                   endif
     *
     *    Verify display.(SCAN slot)
     *
500dMC                   if        w2scan <> #frombasesldsp
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = #frombasesldsp
     C                   exsr      zm2901
     C                   endif
     *
     *    Re-compute slot qty as it may have changed.
600uM*    No longer necessary when using new USR slots.
     *
600uDC**                 eval      rtnhom = *off
600uDC**
600uDC**                 exsr      clr$slot
600uDC**                 eval      $slwhseu = *on
600uDC**                 eval      $slwhse  = #fromslwhse
600uDC**                 eval      $slwhdpu = *on
600uDC**                 eval      $slwhdp  = #fromslwhdp
600uDC**                 eval      $sldispu = *on
600uDC**                 eval      $sldisp  = #fromsldisp
600uDC**                 eval      $dricommand = '*SLOT'
600uDC**                 eval      $drisubcmd = '%GETCHKV'
600uDC**                 eval      $drireturn = *blanks
600uDC**                 eval      chk4err = *on
600uDC**                 eval      zmsflag = *off
600uDC**                 exsr      zzzdricop
500jDC**                 if        error
600uDC**                 if        drierr
600uDC**                 eval      error = *on
600uDC**                 eval      *in24 = *on
600uDC**                 eval      *in04 = *on
600uDC**                 goto      endck2
600uDC**                 endif
600uDC**
600uDC**                 eval      #fromslwhdp = $slwhdp
600uDC**                 eval      #fromslstyp = $slstyp
600uDC**                 eval      #fromsldisp = $sldisp
600uDC**                 eval      #fromslaisl = $slaisl
600uDC**                 eval      #fromslloc  = $slloc
600uDC**                 eval      #fromslpseq = $slpseq
600uDC**                 eval      #fromslrlvl = $slrlvl
600uDC**                 eval      #fromslhand = $slhand
600uDC**                 eval      #fromslrsrv = $slrsrv
600uDC**                 eval      #fromslentd = $slentd
600uDC**                 eval      #fromslexpd = $slexpd
600uDC**                 eval      #fromslslfd = $slslfd
600uDC**                 eval      #fromslactv = $slactv
600uDC**                 eval      #fromslbld  = $slbld
600uDC**                 eval      #fromslpick = $slpick
600uDC**                 eval      #fromslitem = $slitem
600uDC**                 eval      #fromslsdef = $slsdef
600uDC**                 eval      #fromslvirt = $sfvirt
600uDC**                 eval      #fromslstk1 = $slstk1
600uDC**                 eval      #fromslstk2 = $slstk2
600uDC**                 eval      #fromslstk3 = $slstk3
600uDC**                 eval      #fromslalc1 = $slalc1
600uDC**                 eval      #fromslalc2 = $slalc2
600uDC**                 eval      #fromslalc3 = $slalc3
600uDC**                 eval      #fromsltfr1 = $sltfr1
600uDC**                 eval      #fromsltfr2 = $sltfr2
600uDC**                 eval      #fromsltfr3 = $sltfr3
600uDC**                 eval      #fromslpck1 = $slpck1
600uDC**                 eval      #fromslpck2 = $slpck2
600uDC**                 eval      #fromslpck3 = $slpck3
600uDC**                 eval      #fromslrcv1 = $slrcv1
600uDC**                 eval      #fromslrcv2 = $slrcv2
600uDC**                 eval      #fromslrcv3 = $slrcv3
600uDC**                 eval      #fromslphy1 = $slphy1
600uDC**                 eval      #fromslphy2 = $slphy2
600uDC**                 eval      #fromslphy3 = $slphy3
600uDC**                 eval      #fromslavl1 = $slavl1
600uDC**                 eval      #fromslavl2 = $slavl2
600uDC**                 eval      #fromslavl3 = $slavl3
600uDC**                 eval      #fromToPos = $saToPos
416fA*
     C                   eval      w2sltq = #fromslstk1 + #fromslrcv1
     C                   if        w2sltq < *zeros
     C                   eval      w2sltq = *zeros
     C                   endif
415aAC                   eval      rpldif = #fromsltfr1 - svqpck
     *
     *    Check if product is allocated or picked. If yes, then flag
     *    any overflow to come back to this slot.
600uD **** Or more than one replenishment exists from this slot.
500mA*    Or tracking slot position and slot has multiple positions.
     *
600uAC                   eval      rtnhom = *off
     *
     C                   if        #fromslpck1 <> 0  or
     C                             #fromslpck2 <> 0  or
     C                             #fromslpck3 <> 0  or
     *
     C                             #fromslalc1 <> 0  or
     C                             #fromslalc2 <> 0  or
     C                             #fromslalc3 <> 0  or
415aA*
415tAC                             #fromslrcv1 <> 0  or
415tAC                             #fromslrcv2 <> 0  or
600uMC                             #fromslrcv3 <> 0
415tA*
600uDC**                           rpldif <> 0
500mA*
500cDC**                           trackpos = 'Y' and #fromslpos > 1
     C                   eval      rtnhom = *on
     C                   endif
     *
     C                   eval      fmentd = #fromslentd
     C                   eval      fmexpd = #fromslexpd
500lDC**
500lDC**  Cannot pull more qty than is currently in the slot
500lDC**  or Contract item types cannot have replenishment qty
500lDC**  increased.
500lDC**
500lDC**                 if        w2nqty > w2sltq  or
500lDC**
500lDC**                           w2nqty > w2repq  and
500lDC**                           svtype = 'C'
500lDC**
500lDC**                 eval      error = *on
500lDC**                 eval      *in23 = *on
500lDC**                 eval      *in03 = *on
500lDC**                 eval      errmsg = *blanks
500lDC**                 if        svtype = 'C'
500lDC**                 eval      erqty = w2repq
500lDC**                 else
500lDC**                 eval      erqty = w2sltq
500lDC**                 endif
500lDC**                 eval      ernqty = w2nqty
500lDC**                 exsr      zm2903
500lDC**                 endif
500lDC**
500lDC**  Replenish qty cannot be less than zero.
500lDC**
500lDC**                 if        w2nqty < 0
500lDC**                 eval      error = *on
500lDC**                 eval      *in23 = *on
500lDC**                 eval      *in03 = *on
500lDC**                 eval      errmsg = desc(12)
500lDC**                 exsr      zm0105
500lDC**                 endif
500lDC**
500lDC**  Replenish qty cannot be less than zero.
500lDC**
500lDC**                 if        w2nqty <= 0  and
500lDC**                           rpltyp = '*LETDOWN'
500lDC**                 eval      error = *on
500lDC**                 eval      *in23 = *on
500lDC**                 eval      *in03 = *on
500lDC**                 eval      errmsg = desc(24)
500lDC**                 exsr      zm0105
500lDC**                 endif
500lDC**
500lDC**  Pull qty cannot be greater than slot qty.
500lDC**
500lDC**                 if        w2nqty > w2sltq
500lDC**                 eval      error = *on
500lDC**                 eval      *in23 = *on
500lDC**                 eval      *in03 = *on
500lDC**                 eval      errmsg = desc(18)
500lDC**                 exsr      zm0105
500lDC**                 endif
500dA
500dA*  Use DRI interface to do rest of the verifications.
500dA
500dAC                   if        difpck <> 0
500dAC                   exsr      clr$slot
500dAC                   eval      $slwhseu  = *on
500dAC                   eval      $slwhse   = #fromslwhse
500dAC                   eval      $slwhdpu  = *on
500dAC                   eval      $slwhdp   = #fromslwhdp
500dAC                   eval      $sldispu  = *on
500dAC                   eval      $sldisp   = #fromsldisp
500dAC                   eval      $saitemu  = *on
500dAC                   eval      $saitem   = #fromslitem
500pAC                   eval      $sacitemu = *on
500pAC                   eval      $sacitem  = #pickslitem
500dAC                   eval      $saqtyu   = *on
500dAC                   eval      $saqty1   = difpck
500dAC                   eval      $saqty2   = 0
500dAC                   eval      $saqty3   = 0
500dA
500dAC                   eval      $dricommand = '*SLOT'
500dAC                   eval      $drisubcmd  = '%VFYTFOCHG'
500dAC                   eval      $drisys2upd = 'D'
500dAC                   eval      chk4err = *on
500dAC                   eval      zmsflag = *off
500dAC                   exsr      zzzdricop
500jDC**                 if        error
500jMC                   if        drierr
500jAC                   eval      error = *on
500dAC                   exsr      zm0001
500dAC                   goto      endck2
500dAC                   endif
     *
500pAC                   exsr      clr$slot
500pAC                   eval      $slwhseu = *on
500pAC                   eval      $slwhse  = #pickslwhse
500pAC                   eval      $slwhdpu = *on
500pAC                   eval      $slwhdp  = #pickslwhdp
500pAC                   eval      $sldispu = *on
500pAC                   eval      $sldisp  = #picksldisp
500pAC                   eval      $saitemu = *on
500pAC                   eval      $saitem  = #pickslitem
500pAC                   eval      $sacitemu = *on
500pAC                   eval      $sacitem  = #fromslitem
500pAC                   eval      $satrn#u = *on
500pAC                   eval      $satrn#  = lbtrn#
500pAC                   eval      $satasku = *on
500pAC                   eval      $satask = pttask
500pAC                   eval      $saqtyu = *on
500pAC                   eval      $saqty1 = difpck
500pAC                   eval      $saqty2 = 0
500pAC                   eval      $saqty3 = 0
500pAC                   eval      $dricommand = '*SLOT'
500pAC                   eval      $drisubcmd = '%VFYTFICHG'
500pAC                   eval      chk4err = *off
500pAC                   eval      zmsflag = *off
500pAC                   exsr      zzzdricop
500dAC                   endif
     *
     *    No more replenishments.
     *
     C                   if        done = *on
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm2906
     C                   endif
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   eval      error = *off
     C                   eval      errflg = *off
     *
     *  Call API for slot.
     *
510hA* Set worow/wocol based on the size of the screen being processed
510hAC                   if        #lline = '16'
510hAC                   eval      worow = 8
510hAC                   eval      wocol = 9
510hAC                   else
510hAC                   eval      worow = 6
510hAC                   eval      wocol = 29
510hAC                   endif
     C                   call      @apics
     C                   parm                    w3scan
510hDC*                  parm      6             worow
510hDC*                  parm      29            wocol
510hMC                   parm                    worow
510hMC                   parm                    wocol
     C                   parm                    @artn
     C                   if        @artn = '*REDSPLY'
     C                   eval      redspl = *on
     C                   goto      endck3
     C                   endif
     *
     *    Verify display.(TO slot)
     *
500dMC                   if        w3scan <> #pickbasesldsp
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   movel     w3tosl        errmsg
     C                   exsr      zm2902
500lAC                   goto      endck3
     C                   endif
710e *
710e *    'Same Slot" From and To Slot can't be the same.
710e *
710eAC                   if        #fromsldisp = w3scan
710eAC                   eval      error = *on
710e  *don't allow F10 by using in44 on display file-must back out
710eAC                   eval      *in44 = *on
710eAC                   eval      *in23 = *on
710eAC                   eval      *in03 = *on
710eAC                   eval      errmsg = *blanks
710eAC                   select
710eAC                   when      e$lng = 'SP'
710eAC                   eval      errmsg = descsp(4)
710eAC                   other
710eAC                   movea     desc(4)       errmsg
710eAC                   endsl
710eAC                   exsr      zm1522
710eAC                   goto      endck3
710eAC                   endif
     *
     *    Replenish qty cannot be less than zero.
     *
     C                   if        w3nqty < 0
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
600rAC                   select
600rAC                   when      e$lng = 'SP'
600rAC                   eval      errmsg = descsp(12)
600rAC                   other
     C                   eval      errmsg = desc(12)
600rAC                   endsl
     C                   exsr      zm0105
500lAC                   goto      endck3
     C                   endif
     *
     *    Replenish qty cannot be greater than slot qty for
     *    base items. Breakdown items must be same as repl. qty.
500nA*
500nA*    Screen 3 now deals with full cases, not brkdwn qtys.
     *
500nDC**                 if        w3nqty > w3pulq  and
500nDC**                           pttask <> 'REPLBK  '  or
     *
500nDC**                           pttask = 'REPLBK  '  and
500nDC**                           w3nqty > w3repq
500nA
500nMC                   if        w3nqty > w3pulq
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
600rAC                   select
600rAC                   when      e$lng = 'SP'
600rAC                   eval      errmsg = descsp(19)
600rAC                   other
     C                   eval      errmsg = desc(19)
600rAC                   endsl
     C                   exsr      zm0105
500lAC                   goto      endck3
     C                   endif
500nDC**
500nDC**  For a Breakdown item,
500nDC**    Make sure qty is evenly divisible by UOM quantity.
500nDC**
500nDC**                 eval      fullcases = w3nqty
500nDC**                 if        pttask = 'REPLBK  '
500nDC**
500nDC**                 if        w3nqty > 0
500nDC**   w3nqty        div       #fromitumq2   fullcases
500nDC**                 mvr                     remainder
500nDC**                 if        remainder > 0
500nDC**                 eval      error = *on
500nDC**                 eval      *in22 = *on
500nDC**                 eval      *in02 = *on
500nDC**                 eval      errmsg = desc(19)
500nDC**                 eval      errmsg = 'Quantity must be divisible by '
500nDC**                                  + 'BrkDn 1 qty ('
500nDC**                                  + %trim(%editc(#fromitumq2:'Z'))
500nDC**                                  + ')'
500nDC**                 exsr      zm0105
500nDC**                 goto      endck3
500nDC**                 endif
500nDC**                 endif
500nDC**
500nDC**                 endif
500dA
500dA*  Use DRI interface to do 'In' verifications.
500dA
500dA*  Note: We are using %VFYCLSTFI instead of %VFYCLSTIC because
500dA*  the quantity we are using is the breakdown quantity and does
500dA*  not need to be converted like it did in screen 2.
500dA
500pA*  Now uses %VFYCLSTIC because we are dealing with full cases.
500pA
500dAC                   exsr      clr$slot
500dAC                   eval      $slwhseu  = *on
500dAC                   eval      $slwhse   = #pickslwhse
500dAC                   eval      $slwhdpu  = *on
500dAC                   eval      $slwhdp   = #pickslwhdp
500dAC                   eval      $sldispu  = *on
500dAC                   eval      $sldisp   = #picksldisp
500dAC                   eval      $slexpdu  = *on
500dAC                   eval      $slexpd   = #fromslexpd
500dAC                   eval      $saitemu  = *on
500dAC                   eval      $saitem   = #pickslitem
500pAC                   eval      $sacitemu = *on
500pAC                   eval      $sacitem  = #fromslitem
500dAC                   eval      $saqtyu   = *on
500nDC**                 eval      $saqty1   = w3nqty
500pDC**                 if        pttask = 'REPLBK  '
500pDC**                 eval      $saqty1   = w3nqty * #fromitumq2
500pDC**                 else
500nMC                   eval      $saqty1   = w3nqty
500pDC**                 endif
500dAC                   eval      $saqty2   = 0
500dAC                   eval      $saqty3   = 0
500dAC                   eval      $saorgu   = *on
500pDC**                 if        pttask = 'REPLBK  '
500pDC**                 eval      $saorg1   = w3pulq * #fromitumq2
500pDC**                 else
500nMC                   eval      $saorg1   = w3pulq
500pDC**                 endif
500nDC**                 eval      $saorg1   = w3repq
500nDC**                 else
500nDC**                 eval      $saorg1   = w3pulq
500nMC**                 eval      $saorg1   = w3pulq * #fromitumq2
500nDC**                 endif
500dAC                   eval      $saorg2   = 0
500dAC                   eval      $saorg3   = 0
500dA
500dAC                   eval      $dricommand = '*SLOT'
500pDC**                 eval      $drisubcmd  = '%VFYCLSTFI'
500pAC                   eval      $drisubcmd  = '%VFYCLSTIC'
500dAC                   eval      $drisys2upd = 'D'
500dAC                   eval      chk4err = *on
500dAC                   eval      zmsflag = *off
500dAC                   exsr      zzzdricop
500jDC**                 if        error
500jMC                   if        drierr
500jAC                   eval      error = *on
500dAC                   eval      *in23 = *on
500dAC                   eval      *in03 = *on
500dAC                   goto      endck3
500dAC                   endif
600uD **
600uD ** Use DRI interface to do 'Out' verifications.
600uD **
600uDC**                 exsr      clr$slot
600uDC**                 eval      $slwhseu  = *on
600uDC**                 eval      $slwhse   = #fromslwhse
600uDC**                 eval      $slwhdpu  = *on
600uDC**                 eval      $slwhdp   = #fromslwhdp
600uDC**                 eval      $sldispu  = *on
600uDC**                 eval      $sldisp   = #fromsldisp
600uDC**                 eval      $saitemu  = *on
600uDC**                 eval      $saitem   = #fromslitem
600uDC**                 eval      $sacitemu = *on
600uDC**                 eval      $sacitem  = #pickslitem
600uDC**                 eval      $saqtyu   = *on
500nDC**                 eval      $saqty1   = fullcases
600uDC**                 eval      $saqty1   = w3nqty
600uDC**                 eval      $saqty2   = 0
600uDC**                 eval      $saqty3   = 0
600uDC**                 eval      $saorgu   = *on
500nDC**                 eval      $saorg1   = fullcases
600uDC**                 eval      $saorg1   = w3nqty
600uDC**                 eval      $saorg2   = 0
600uDC**                 eval      $saorg3   = 0
600uD **
600uDC**                 eval      $dricommand = '*SLOT'
500pDC**                 eval      $drisubcmd  = '%VFYCLSTFO'
600uDC**                 eval      $drisubcmd  = '%VFYCLSTOC'
600uDC**                 eval      $drisys2upd = 'D'
600uDC**                 eval      chk4err = *on
600uDC**                 eval      zmsflag = *off
600uDC**                 exsr      zzzdricop
500jDC**                 if        error
600uDC**                 if        drierr
600uDC**                 eval      error = *on
600uDC**                 eval      *in23 = *on
600uDC**                 eval      *in03 = *on
600uDC**                 goto      endck3
600uDC**                 endif
     *
     C     endck3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK4   Screen 4 error checking.
     *
     C     zzchk4        begsr
     C                   eval      error = *off
SVLb C                   if        client = saval
GLPaAC                             or client = greenleaf
SVLb C                   if        w4item = '1'
SVLb C                   eval      w4item  = 'Y'
SVLb C                   endif
SVLb C                   if        w4item = '9'
SVLb C                   eval      w4item = 'N'
SVLb C                   endif
SVLb C                   if        w4qty = '1'
SVLb C                   eval      w4qty = 'Y'
SVLb C                   endif
SVLb C                   if        w4qty = '9'
SVLb C                   eval      w4qty = 'N'
SVLb C                   endif
SVLb C*
SVLb C                   endif
     *
     *    Verify exception options. (Item)
     *
     C                   if        w4item <> 'Y'  and
     C                             w4item <> 'N'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
600rAC                   select
600rAC                   when      e$lng = 'SP'
600rAC                   eval      errmsg = descsp(1)
600rAC                   other
     C                   eval      errmsg = desc(1)
600rAC                   endsl
     C                   exsr      zm1005
     C                   endif
     *
     *    Verify exception options. (Qty)
     *
     C                   if        w4qty <> 'Y'  and
     C                             w4qty <> 'N'
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
600rAC                   select
600rAC                   when      e$lng = 'SP'
600rAC                   eval      errmsg = descsp(2)
600rAC                   other
     C                   eval      errmsg = desc(2)
600rAC                   endsl
     C                   exsr      zm1005
     C                   endif
     *
     *    Only one of the options canbe "Y".
     *
     C                   if        w4item = 'Y'  and
     C                             w4qty = 'Y'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in22 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm2904
     C                   endif
     *
     *    Only one of the options canbe "N".
     *
     C                   if        w4item = 'N'  and
     C                             w4qty = 'N'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in22 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm2905
     C                   endif
     *
     C     endck4        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK5   Screen 5 error checking.
     *
     C     zzchk5        begsr
     C                   eval      error = *off
SVLb C*
SVLb C                   if        client = saval
GLPaAC                             or client = greenleaf
SVLb C                   if        w5zero = '1'
SVLb C                   eval      w5zero = 'Y'
SVLb C                   endif
SVLb C                   if        w5zero = '9'
SVLb C                   eval      w5zero = 'N'
SVLb C                   endif
SVLb C*
SVLb C                   endif
     *
     *
     *    Verify Zero, Y,N
     *
     C                   if        w5zero <> 'Y'  and
     C                             w5zero <> 'N'
     C                   eval      error = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
600rAC                   select
600rAC                   when      e$lng = 'SP'
600rAC                   eval      errmsg = descsp(3)
600rAC                   other
     C                   eval      errmsg = desc(3)
600rAC                   endsl
     C                   exsr      zm1005
     C                   endif
     *
     C     endck5        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK6   Screen 06 error checking.
     *
     C     zzchk6        begsr
     C                   eval      error = *off
     *
     C     endch6        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK7   Screen 07 error checking.
     *
     C     zzchk7        begsr
     C                   eval      error = *off
500fAC                   eval      rpltyp = ' '
     *
     *    Verify warehouse and get description.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w7whse
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
CBIdA*
CBIdA*    Verify Letdowns display sequence.
CBIdA*
CBIdAC                   if        w7dsps <> 1  and
CBIdAC                             w7dsps <> 2
CBIdAC                   eval      error = *on
CBIdAC                   eval      *in25 = *on
CBIdAC                   eval      *in05 = *on
CBIdAC                   eval      errmsg = *blanks
600rAC                   select
600rAC                   when      e$lng = 'SP'
600sDC*                  eval      errmsg = descsp(25)
600sAC                   eval      errmsg = descsp(30)
600rAC                   other
600sDC*                  eval      errmsg = desc(25)
600sAC                   eval      errmsg = desc(30)
600rAC                   endsl
CBIdAC                   exsr      zm0105
CBIdAC                   else
CBIdAC                   if        w7dsps = 1
CBIdAC                   eval      letord = 'SLOT '
CBIdAC                   else
CBIdAC                   eval      letord = 'ROUTE'
CBIdAC                   endif
CBIdAC                   endif
     *
     *    Verify warehouse department.
     *
650bAC                   select
650bAC                   when      w7whdp = '*ALL '
650bAC                   if        *inkg
650bAC                   eval      error = *on
650bAC                   eval      *in22 = *on
650bAC                   eval      *in02 = *on
650bAC                   eval      errmsg = desc(33)
650bAC                   exsr      zm0105
650bAC                   endif
     *
650bAC                   other
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w7whse
     C                   eval      $lwhdp = w7whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
650bAC                   endsl
417eA*
417eA*    Verify Replenishment type code.
720bM*      N=Normal, F=FlowRack, B=Breakdown, R=Repack, D=Drop Pick, O=Product
417eA*
417eAC                   if        w7rplt <> 'N'  and
500 MC                             w7rplt <> 'F'  and
510dAC                             w7rplt <> 'R'  and
650bMC                             w7rplt <> 'B'  and
730bMC                             w7rplt <> 'D'  and
730bMC                             w7rplt <> 'O'  and
720bAC                             w7rplt <> 'S'  and
650bAC                             w7rplt <> 'A'
417eAC                   eval      error = *on
417eAC                   eval      *in25 = *on
417eAC                   eval      *in05 = *on
600rAC                   select
600rAC                   when      e$lng = 'SP'
600rMC                   eval      errmsg = descsp(25)
600rAC                   other
417eAC                   eval      errmsg = desc(25)
600rAC                   endsl
510dDC*                  exsr      zm1001
510dMC                   exsr      zm0105
417eAC                   endif
     *
     *    Verify from aisle.
     *
     *    Right adjust From aisle code.
     *
     C                   eval      frmasl = *blanks
     C                   if        w7fas > *blanks
     C                   eval      $cstr = w7fas
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
     *
     C                   move      $cstr         kyaisl
     C                   move      $cstr         frmasl
     C     keysl1        setll     slot1                                  78
     C                   if        not *in78
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
600rAC                   select
600rAC                   when      e$lng = 'SP'
600rAC                   eval      errmsg = descsp(13)
600rAC                   other
     C                   eval      errmsg = desc(13)
600rAC                   endsl
     C                   exsr      zm0105
     C                   endif
     C                   endif
     *
     *    Verify To aisle.
     *
     *    Right adjust To aisle code.
     *
     C                   eval      toaisl = *blanks
     C                   if        w7tas > *blanks
     C                   eval      $cstr = w7tas
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     *
     C                   move      $cstr         kyaisl
     C                   move      $cstr         toaisl
     C     keysl1        setll     slot1                                  78
     C                   if        not *in78
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
600rAC                   select
600rAC                   when      e$lng = 'SP'
600rAC                   eval      errmsg = descsp(14)
600rAC                   other
     C                   eval      errmsg = desc(14)
600rAC                   endsl
     C                   exsr      zm0105
     C                   endif
     C                   endif
     *
     *    Verify from/to aisles both blank or both filled in.
     *
     C                   if        w7fas = *blanks  and
     C                             w7tas > *blanks  or
     *
     C                             w7fas > *blanks  and
     C                             w7tas = *blanks
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
600rAC                   select
600rAC                   when      e$lng = 'SP'
600rAC                   eval      errmsg = descsp(15)
600rAC                   other
     C                   eval      errmsg = desc(15)
600rAC                   endsl
     C                   exsr      zm0105
     C                   endif
500sA*
500sA*    Verify Side
500sA*      B=Both, O=Odd, E=Even
500sA*
500sAC                   if        w7side <> 'B'  and
500sAC                             w7side <> 'O'  and
500sAC                             w7side <> 'E'
500sAC                   eval      error = *on
500sAC                   eval      *in26 = *on
500sAC                   eval      *in06 = *on
500sAC                   eval      errmsg = desc(27)
500sAC                   exsr      zm1001
500sAC                   endif
     *
     C     endck7        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK8   Screen 8 error checking.
     *
     C     zzchk8        begsr
     C                   eval      error = *off
710d c                   eval      *in82 = *off
     *
     *  Call API for slot.
     *
510hA* Set worow/wocol based on the size of the screen being processed
510hAC                   if        #lline = '16'
510hAC                   eval      worow = 8
510hAC                   eval      wocol = 9
510hAC                   else
510hAC                   eval      worow = 5
510hAC                   eval      wocol = 29
510hAC                   endif
     C                   call      @apics
     C                   parm                    w8scan
510hDC*                  parm      5             worow
510hDC*                  parm      29            wocol
510hMC                   parm                    worow
510hMC                   parm                    wocol
     C                   parm                    @artn
     C                   if        @artn = '*REDSPLY'
     C                   eval      redspl = *on
     C                   goto      endck8
     C                   endif
     *
     *    Slot can't be blank.
     *
     C                   if        w8scan = *blanks
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
600rAC                   select
600rAC                   when      e$lng = 'SP'
600rAC                   eval      errmsg = descsp(4)
600rAC                   other
     C                   movea     desc(4)       errmsg
600rAC                   endsl
     C                   exsr      zm0203
500lAC                   goto      endck8
     C                   endif
     *
     *    Verify slot.
     *
500dAC                   exsr      zzgetovrfsl
500dAC                   if        error
500dAC                   eval      *in23 = *on
500dAC                   eval      *in03 = *on
710dAC                   eval      *in82 = *on
500dAC                   goto      endck8
500dAC                   endif
414eA*
414eA*    Return Home Flag on - product must go back to pull slot.
414eA*
414eAC                   if        *inkj  and
414eAC                             rtnhom = *on
414eAC                   eval      error = *on
414eAC                   eval      *in23 = *on
414eAC                   eval      *in03 = *on
600rAC                   select
600rAC                   when      e$lng = 'SP'
600rAC                   eval      errmsg = descsp(21)
600rAC                   other
414eAC                   eval      errmsg = desc(21)
600rAC                   endsl
414eAC                   exsr      zm0105
500lAC                   goto      endck8
414eAC                   endif
     *
     *    Quantity must be greater than 0.
     *
     C                   if        w8nqty <= 0
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   exsr      zm2003
500lAC                   goto      endck8
     C                   endif
414kA*
414kA*    Quantity cannot be greater than balance.
414kA*     This test is only performed when SCREEN8 is being
414kA*     displayed and processed.  This routine is also called
414kA*     from   ZZUPD4 - item exception.
414kA*
414kAC                   if        w8nqty > w8balq
414kAC                   eval      error = *on
414kAC                   eval      *in22 = *on
414kAC                   eval      *in02 = *on
600rAC                   select
600rAC                   when      e$lng = 'SP'
600rAC                   eval      errmsg = descsp(22)
600rAC                   other
414kAC                   eval      errmsg = desc(22)
600rAC                   endsl
414kAC                   exsr      zm0105
500lAC                   goto      endck8
414kAC                   endif
416bA*
416bA*    Retrieve "From Slot".
416bAC                   if        rtnhom = *off
500dMC                   eval      fmpck = #fromslpick
500dMC                   eval      svpick = #fromslpick
416bA*
     C                   endif
     *
     *    Product allocated - must go back to overflow slot.
     *
     C                   if        rtnhom = *on  and
     C                             w8scan <> w8rtn2
     *
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
600rAC                   select
600rAC                   when      e$lng = 'SP'
600rAC                   eval      errmsg = %trimr(descsp(16)) + ' ' + w8rtn2
600rAC                   other
     C                   eval      errmsg = %trimr(desc(16)) + ' ' + w8rtn2
600rAC                   endsl
     C                   exsr      zm0105
500dAC                   goto      endck8
     C                   endif
     *
     *    Product allocated - Entire balance must be returned.
     *
     C                   if        rtnhom = *on  and
     C                             w8nqty <> w8balq
     *
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
600rAC                   select
600rAC                   when      e$lng = 'SP'
600rAC                   eval      errmsg = descsp(17)
600rAC                   other
     C                   eval      errmsg = desc(17)
600rAC                   endsl
     C                   exsr      zm0105
500dAC                   goto      endck8
     C                   endif
500dA
500dA*  Use DRI interface to do rest of the verifications.
500dA
500dAC                   exsr      clr$slot
500dAC                   eval      $slwhseu  = *on
500dAC                   eval      $slwhse   = #fromslwhse
500dAC                   eval      $slwhdpu  = *on
500dAC                   eval      $slwhdp   = #fromslwhdp
500dAC                   eval      $sldispu  = *on
500dAC                   eval      $sldisp   = w8scan
500dAC                   eval      $slexpdu  = *on
500dAC                   eval      $slexpd   = #fromslexpd
500dAC                   eval      $saitemu  = *on
500dAC                   eval      $saitem   = #fromslitem
500dAC                   eval      $saqtyu   = *on
500dAC                   eval      $saqty1   = w8nqty
500dAC                   eval      $saqty2   = 0
500dAC                   eval      $saqty3   = 0
640lAC                   eval      $sapullwhdpu = *on
640lAC                   eval      $sapullwhdp  = wuPulWhdp
640lAC                   eval      $sapulldispu = *on
640lAC                   eval      $sapulldisp  = wuPulDisp
640lAC                   eval      $sapullbaseu = *on
640lAC                   eval      $sapullbase  = wuPulBase
640lAC                   eval      $sapulllcnsu = *on
640lAC                   eval      $sapulllcns  = wuPulLcns
500dA
500dAC                   eval      $dricommand = '*SLOT'
500dAC                   eval      $drisubcmd  = '%VERIFYTFI'
500dAC                   eval      $drisys2upd = 'D'
500dAC                   eval      chk4err = *on
500dAC                   eval      zmsflag = *off
500dAC                   exsr      zzzdricop
500jDC**                 if        error
500jMC                   if        drierr
500jAC                   eval      error = *on
500dAC                   eval      *in23 = *on
500dAC                   eval      *in03 = *on
710dAC                   eval      *in82 = *on
500dAC                   goto      endck8
500dAC                   endif
     *
     C     endck8        endsr
417cA*
417cA*----------------------------------------------------------------
417cA*
417cA*  ZZCHK9   Screen 9 error checking.
417cA*
417cAC     zzchk9        begsr
417cAC                   eval      error = *off
417cA*
417cA*    Verify Lot/License plate entered by user.
417cA*
417cAC                   if        w9nllp = *blanks
417cAC                   eval      error = *on
417cAC                   eval      *in28 = *on
417cAC                   eval      *in08 = *on
417cAC                   eval      errmsg = *blanks
600rAC                   select
600rAC                   when      e$lng = 'SP'
600rAC                   eval      errmsg = descsp(3)
600rAC                   other
417cAC                   eval      errmsg = desc(3)
600rAC                   endsl
417cAC                   exsr      zm1005
417cAC                   endif
417cA*
417cAC     endck9        endsr
417cA*
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZCHK11  Screen 11 error checking.
650bA*
650bAC     zzchk11       begsr
650bA*
     C                   eval      error = *off
     *
     *    Go into JIT replenishments, Y,N
     *
SVLc C                   if        client = saval
GLPaAC                             or client = greenleaf
SVLc C                   if        w11jit = '1'
SVLc C                   eval      w11jit  = 'Y'
SVLc C                   endif
SVLc C                   if        w11jit = '9'
SVLc C                   eval      w11jit = 'N'
SVLc C                   endif
SVLc C                   endif
     C                   if        w11jit <> 'Y'  and
     C                             w11jit <> 'N'
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   select
     C                   when      e$lng = 'SP'
     C                   eval      errmsg = descsp(32)
     C                   other
     C                   eval      errmsg = desc(32)
     C                   endsl
     C                   exsr      zm1005
     C                   endif
     *
     C     endck11       endsr
     *----------------------------------------------------------------
     *
415dA*  ZZCHKB   Check if base slot has quantity.
     *
415dAC     zzchkb        begsr
415dAC                   eval      bszero = *off
     *
415dAC                   call      'RTNSTAT'
415dAC                   parm                    kywhse
415dAC                   parm                    kywhdp
415dAC                   parm                    vspdis
415dAC                   parm                    $pstat            2
415dAC                   if        $pstat = 'Z '  or
415dAC                             $pstat = 'V '
415dAC                   eval      bszero = *on
415dAC                   endif
     *
415dAC     endckb        endsr

710aA*----------------------------------------------------------------
710aA*
710aA*  ZZCHKFIFO    Check if selected replen is out of FIFO order
710aA*
710aAC     zzchkfifo     begsr


      /free

       outOfFifoOrder = *off;

       // See if we should do this check

RNZaA  if client <> renzi
SGC A     and client <> SGC;
RNZaA    leavesr;
RNZaA  endif;

       //  Loop through replenishments for item
       //  PRPLFIL9 only includes prflag='S' records.

       firstP9 = *on;

       setll (prwhse: prrplt: pritem) prplfil9;

       dou forever <> forever;

         reade (prwhse: prrplt: pritem) prplfil9;

         if %eof(prplfil9);
           leave;
         endif;

         // Skip selected record

         if p9_prfdis = prfdis;
           iter;
         endif;

         // First time through, get slot for selected replen

         if firstP9 = *on;

           // Get slot info for selected replen

           exsr clr$slot;
           $slwhseu = *on;
           $slwhse  = prwhse;
           $slwhdpu = *on;
           $slwhdp  = prwhdp;
           $sldispu = *on;
           $sldisp  = prfdis;

           $dricommand = '*SLOT';
           $drisubcmd  = '%GET2';
           $drisys2upd = 'D';
           chk4err = *off;
           zmsflag = *off;

           exsr zzzdricop;
           if drierr;
             leavesr;
           endif;

           savePrty = $slprty;
           saveExpd = $slexpd;
           saveEntd = $slentd;
           firstP9 = *off;

         endif;

         // Get slot info for P9 record

         exsr clr$slot;
         $slwhseu = *on;
         $slwhse  = p9_prwhse;
         $slwhdpu = *on;
         $slwhdp  = p9_prwhdp;
         $sldispu = *on;
         $sldisp  = p9_prfdis;

         $dricommand = '*SLOT';
         $drisubcmd  = '%GET2';
         $drisys2upd = 'D';
         chk4err = *off;
         zmsflag = *off;

         exsr zzzdricop;
         if drierr;
           iter;
         endif;

         // Keep selected rec if priority is greater than p9 rec

         if savePrty > $slprty;
           iter;
         endif;

         // Keep selected rec if expiration date is less than p9 rec

         if saveExpd <= $slexpd;
           iter;
         endif;

         // Keep selected rec if entered date is less than or equal to p9 rec
         // Only check when not using expiration dates.

         if (saveExpd <= 0 and $slexpd <= 0) and saveEntd <= $slentd;
           iter;
         endif;

         // Otherwise, P9 rec should be replenished first,
         // So, set flag and get out

         outOfFifoOrder = *on;
         leave;

       enddo;

      /end-free

     C                   endsr

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
     *    Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     *     Warehouse.
     *
     C                   when      row# = 4
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whse = $lwhse
     C                   endif
     *
     *     Warehouse department.
     *
     C                   when      row# = 5
     C                   eval      *in02 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whdp = $lwhdp
     C                   endif
     *
     C                   other
     *
     *    Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
     C                   endif
     C                   endif
700hA*
700hA*  Test for F14 - Show Pick Slots w/< 5 Cases
700hA*
700hAC                   if        *inkn
700hA *
700hAC                   if        dspless5 = '0'
700hAC                   eval      aisl1    = *blanks
700hAC                   eval      aisl2    = *blanks
700hAC                   endif
700hA *
700hAC                   move      w1whse        ltwhse            3
700hAC                   call      @lessthan5
700hAC                   parm                    ltwhse
700hAC                   parm                    w1tds1
700hAC                   parm                    w1whdp
700hAC                   parm                    dspless5
700hAC                   parm                    aisl1
700hAC                   parm                    aisl2
750dAc                   parm                    fulldisp         12
700hAC                   eval      cmdtkn = *on
750dAc     client        ifne      cheney
750dAc     fulldisp      andne     *blanks
750dAc                   eval      w1scan=fulldisp
750dAc                   endif
700hAC                   endif
     *
     *    Command keys to check AFTER verification and update.
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
     *    Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *    Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
     C                   eval      cmdtkn = *off
     *
     *    Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *    Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     C                   other
     *
     *    Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm3
     C                   endif
     *
     *    Test for F10 - Exception
     *
     C                   if        *inkj
     C                   eval      cmdtkn = *on
     C                   exsr      scr04i
     C                   goto      endcm3
     C                   endif
     *
     *    F20 - Accept Warning.
     *
     C                   if        *inku
     C                   eval      ovrrid = *on
     C                   endif
     *
     C                   endif
     *
     *    Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     *
     *    F20 - Accept Warning.
     *
     C                   if        *inku
     C                   eval      ovrrid = *on
     C                   endif
     *
     C                   endif
     C     endcm3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD4   User defined command keys for screen 4.
     *
     C     zzcmd4        begsr
     *
     *    Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *    Command keys to check AFTER verification and update.
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
     *    Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *    Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm5        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD6   User defined command keys for screen 06.
     *
     C     zzcmd6        begsr
     *
     *    Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm6        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD6a  User defined command keys for screen 06a.
     *
     C     zzcmd6a       begsr
     *
     *    Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm6a       endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD7   User defined command keys for screen 07.
     *
     C     zzcmd7        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *    Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     *     Warehouse.
     *
650bDC**                 when      row# = 4
650bAC                   when      (row# = 3 and col# = 17 and #lline <> '16')
650bAC                              or
650bAC                             (row# = 3 and col# = 9  and #lline = '16')
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w7whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w7whse = $lwhse
     C                   endif
     *
     *     Warehouse department.
     *
650bDC**                 when      row# = 5
650bAC                   when      (row# = 3 and col# = 23 and #lline <> '16')
650bAC                              or
650bAC                             (row# = 4 and col# = 9  and #lline = '16')
     C                   eval      *in02 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w7whse
     C                   eval      $lwhdp = w7whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w7whdp = $lwhdp
     C                   endif
510dA*
510dA*     Replenishment Type
510dA*
650bDC**                 when      row# = 5
650bAC                   when      (row# = 4 and col# = 17 and #lline <> '16')
650bAC                              or
650bAC                             (row# = 5 and col# = 9  and #lline = '16')
510dAC                   eval      *in01 = *on
510hAC                   select
510hAC                   when      e$lng = 'SP'
510hAC                   if        #lline = '16'
510hAC                   exfmt     scr610sp
510hAC                   else
510hAC                   exfmt     scrn10sp
510hAC                   endif
510hAC                   other
510hAC                   if        #lline = '16'
510hAC                   exfmt     scrn610
510hAC                   else
510dAC                   exfmt     scrn10
510hAC                   endif
510hAC                   endsl
510dAC                   if        w10tp1 <> *blanks
510dAC                   eval      *in05 = *on
510dAC                   move      w10tp1        w7rplt
510dAC                   endif
     *
     C                   other
     *
     *    Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     *
     C                   goto      endcm7
     C                   endif
     *
     *    Test for F7 - Specific slot replenishment.
     *
     C                   if        *inkg
415oA*
415oA*    Validate info entered on SCREEN7 before proceeding.
415oAC                   exsr      zzchk7
415oAC                   if        error = *on
415oAC                   goto      endcm7
415oAC                   endif
     C                   eval      cmdtkn = *on
     C                   eval      w1tdis = *blanks
720aAC                   eval      w1lcns = *blanks
720aAC                   eval      w1scan = *blanks
     C                   eval      usrrpl = *off
     C                   eval      w1whse = w7whse
     C                   eval      w1whdp = w7whdp
     C     keypr1        setll     prplfil1
     C                   exsr      scr01i
415kAC                   eval      rtnto = 'STARTDSP'
     C                   goto      endcm7
     C                   endif
     *
     C                   endif
     *
     *    Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
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
     *
     *    Test for F10 - Exception
     *
414eAC                   eval      balexc = *off
     C                   if        *inkj  and
414eAC                             rtnhom = *off
     C                   eval      cmdtkn = *on
414eAC                   eval      balexc = *on
414kAC                   eval      lstscr = nxtscr
416gAC                   eval      pttask = svtask
     C                   exsr      scr04i
     C                   goto      endcm8
     C                   endif
     *
     C                   endif
     *
     *    Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm8        endsr
417cA*
417cA*----------------------------------------------------------------
417cA*
417cA*  ZZCMD9   User defined command keys for screen 9.
417cA*
417cAC     zzcmd9        begsr
417cA*
417cA*    Command keys to check BEFORE verification and update.
417cA*
417cAC                   if        cmdchk = '*BEFORE '
417cAC                   endif
417cA*
417cA*    Command keys to check AFTER verification and update.
417cA*
417cAC                   if        cmdchk = '*AFTER  '
417cAC                   endif
417cAC     endcm9        endsr
417cA*
600pA*----------------------------------------------------------------
600pA*
600pA*  ZZCQTY   Retrieve Check "To Slot" quantity option.
600pA*
600pAC     zzcqty        begsr
600pA*
600pA**                   Z-ADD$PWHSE    KYWHSE
600pAC                   eval      kycode = '*REPLEN '
600pAC     opkey         chain     options                            79
600pA*
600pA*    Record not found. Set defaults to No
600pA*
600pAC                   if        *in79
720aAc                   eval      *in83 = *off
600pAC                   eval      opcqty = 'N'
650kAC                   eval      opskpr = 'N'
700hAC                   eval      f14dsc = 'F14=< ' +
700hAC                                      '00'     +
700hAC                                      ' Cases'
650mA*
650mA*    Record not found. Set defaults to Yes
650mAC                   eval      opjitw = 'Y'
600pA*
600pA*    Record found. Load file data structure.
600pAC                   else
600pAC                   eval      opdta3 = opdata
700hAC                   eval      f14dsc = 'F14=< ' +
700hAC                                      oplqtya  +
700hAC                                      ' Cases'
720aAc                   if        opsslcn = 'Y'
720aAc                   eval      *in83 = *on
720aAc                   else
720aAc                   eval      *in83 = *off
720aAc                   endif
600pA*
600pAC                   endif
600pA*
600pAC                   endsr
600pA*
414iA*----------------------------------------------------------------
414iA*
414iA*  ZZCVDT  Convert date to proper format.
414iA*
414iAC     zzcvdt        begsr
414iA*
414iA*    Convert date into proper format.
414iA*
414iAC                   call      @cvtdt
414iAC                   parm                    $cvtdt
414iAC     endcvd        endsr
710cA*----------------------------------------------------------------
710cA*  zzdelrpl      Delete JIT/Priority Repl slot filled by specific
710cA*----------------------------------------------------------------
710cA
710cAC     zzdelrpl      begsr
     *
710cA*    If there's a JIT or priority repl for the from slot just used
710cA*    in specific slot replenishment, delete it.

710cAC     keypr11       chain     prplfil11
710cAC                   if        %found
710cAC                   eval      prflag = 'D'
710cAC                   update    prrec11                              78
710cAC                   endif
710cAC                   unlock    prplfil11
650iA /free
650iA   if not %found(prplfil11);
650iA     // see if repl exist for the pick slot just filled
650iA     setll (#pickslwhse: #pickslwhdp:
650iA            #pickslaisl: #picksldisp) prplfil3;
650iA     dow forever = forever;
650iA       reade (#pickslwhse: #pickslwhdp:
650iA              #pickslaisl: #picksldisp) prplfil3;
650iA       if %eof(prplfil3);
650iA         leave;
650iA       endif;
650iA       if pr_prflag <> 'S';
650iA         iter;
650iA       endif;
650iA       pr_prflag = 'D';
650iA       update prrec3;
650iA       leave;
650iA     enddo;
650iA   endif;
650iA /end-free
710cAC     enddelrpl     endsr
     *----------------------------------------------------------------
     *
     *  ZZEXCP Write item exception record to file.
     *
     C     zzexcp        begsr
     *
     *    Write an item exception record, and delete replenishment
     *    record.
     C                   eval      exwhse = lbwhse
     C                   eval      exwhdp = lbwhdp
     C                   eval      exstyp = lbstyp
     C                   eval      exitem = lbitem
     C                   eval      exfdis = lbdisp
417jA*    User logged exception from Balance Putaway screen.
417jA*    No To Slot used.
417jAC                   if        balexc = *on
417jAC                   eval      extdis = *blanks
417jAC                   else
     C                   eval      extdis = lbdsp2
417jAC                   endif
     C                   eval      extask = pttask
414iA*    Get todays date.
414iAC                   eval      $cvcmd = '*CURCMD '
414iAC                   exsr      zzcvdt
414iAC                   eval      today = $cvd8o
     C                   eval      exgdte = today
     C                   time                    exgtim
     C                   eval      exgby = #user
     C                   eval      exesta = '1 '
     C                   write     exrec
     *
     C     endexc        endsr
416oA*----------------------------------------------------------------
416oA*
416oA*  ZZEXSL Write slot exception record to file.
416oA*
416oAC     zzexsl        begsr
416oA*
416oA*    Write a slot exception record. This will prevent slot
416oA*    from being selected for another letdown transaction.
416oA*
416oAC                   eval      sxwhse = lbwhse
416oAC                   eval      sxwhdp = lbwhdp
416oAC                   eval      sxdisp = lbdisp
416oAC                   eval      sxitem = lbitem
416oA*    Get todays date.
416oAC                   eval      $cvcmd = '*CURCMD '
416oAC                   exsr      zzcvdt
416oAC                   eval      sxadte = $cvd8o
416oAC                   time                    sxatim
416oAC                   eval      sxaby = #user
416oAC                   write     serec                                76
416oA*
416oAC     endse         endsr
     *----------------------------------------------------------------
     *
     *  ZZFEAT   Check for installed feature.
     *
     C     zzfeat        begsr
     *
     C                   eval      spcslt = *off
416bAC                   eval      kycode = '*FEATURE'
     C     opkey         chain     options                            79
     C                   if        *in79
     C                   eval      opfeat = '2'
710iAc                   else
710iAC                   eval      opdta4 = opdata
     C                   endif
     *
     *    Check which feature installed.
     *
     C                   select
     *
     *    Locator system installed.  With locator system, only
     *    specific slot replenishment is available.
     *
     C                   when      opfeat = '1'
     C                   eval      spcslt = *on
     *
     C                   when      opfeat = '2'
     *
     *    Full system installed.
     *
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     C                   eval      crtrcd = *off
     C                   eval      w1tdis = *blanks
720aAc                   eval      w1lcns = *blanks
720aAC                   eval      w1scan = *blanks
415mA*
415mAC                   eval      chknew = *on
415mAC                   eval      newtrn = *off
415mA*
415mA*    Go check for any new Letdowns.
415mAC                   exsr      zzstrt
600oA*    No Letdowns found - Check for Bulk Drops.
600oA*****      NEWTRN    IFEQ *OFF
510bAC                   if        opbdrp = 'Y'
600oAC                   eval      $lcmd = *blanks
600oAC                   eval      $lprg = #prog
770bDC**                 eval      $lwhse = kydwhs
770bDC**                 eval      $lwhdp = kydwdp
770bMC                   eval      $lwhse = w7whse
770bMC                   eval      $lwhdp = w7whdp
600oAC                   eval      $lbsts = '1 '
600oAC                   call      'OR688'
600oAC                   parm                    $lparm
600oAC                   if        $lrtn = '*OK     '
600oAC                   call      'OR686'
600oAC                   parm                    $lparm
600oAC                   endif
510bAC                   endif
600oA*****                ENDIF
600o *
415mA*
415mA*    No Letdowns found - Check for Priority Replenishments.
415mAC                   if        newtrn = *off
415mAC                   exsr      zznext
415mAC                   endif
415mA*
415mA*    If tying to replen Store Pick and no stock remains send message
415mA*    and call routine to automatically generate Priority Replenishment
720bAc                   if        $iReturn = 'STRNOSTK'
720bAc                   if        not levelOk
720bAc                   eval      errmsg = 'Store stock low. ' +
720bAc                                      'Priority Replen generated'
720bAc                   else
720bAc                   eval      errmsg = 'Store Pick Slot has ' +
720bAc                                      'enough available Inventory'
720bAc                   endif
720bAc                   exsr      zm0105
720bAc                   eval      $iReturn = *blanks
720bAc                   endif
720bAc                   if        $iReturn = 'STRNOSLT'
720bAc                   eval      errmsg = 'License scanned is not ' +
720bAc                                      'a valid Store License'
720bAc                   exsr      zm0105
720bAc                   eval      $iReturn = *blanks
720bAc                   endif
415mA*
415mA*    Transaction found - Send info message to user.
415mAC                   if        newtrn = *on
600rAC                   select
600rAC                   when      e$lng = 'SP'
600rAC                   eval      errmsg = descsp(23)
600rAC                   other
415mAC                   eval      errmsg = desc(23)
600rAC                   endsl
415mAC                   exsr      zm0105
415mAC                   endif
415mAC                   eval      chknew = *off
415mA*
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     C                   eval      *in60 = *off
     C                   eval      *in64 = *off
     C                   eval      wohdr1 = *blanks
     C                   eval      wohdr2 = *blanks
     C                   if        done = *off
     C                   eval      *in60 = *on
500tA*
500tA*  Only allow user to change pull quantity the first time through
500tA*  for a REPLBK.
500tA*  Re: It messes up the license history records.
500tA*
500tAC                   if        pttask = 'REPLBK  '
500tAC                             and sc2first
500tAC                   eval      *in93 = *off
500tAC                   else
500tAC                   eval      *in93 = *on
500tAC                   endif
     *
     *    Load appropriate display headings.
     *
     C                   select
     C                   when      rpltyp = '*LETDOWN'
416cAC     keyrh         chain     rtehed                             75
416cAC                   if        *in75
416cAC                   eval      rhrte = '???  '
416cAC                   endif
416cAC                   eval      temp13 = '('
416cAC     temp13        cat       rhrte:0       temp13
416cAC     temp13        cat       stath:1       temp13
416cAC     temp13        cat       ':':0         temp13
416cAC     temp13        cat       statm:0       temp13
416cAC     temp13        cat       ')':0         temp13
416cAC                   move      temp13        temp1a
416cAC                   if        temp1a = ' '
416cAC     'LD'          cat       temp13:1      wohdr1
416cAC                   else
416cAC     'LD'          cat       temp13:0      wohdr1
416cAC                   endif
     *
     C                   when      rpltyp = '*PRIORTY'
600dA*
600dA*    Include time in heading when processing
600dA*    Immediate Priority Replenishment.
600dAC                   if        prseq# < 0
600dAC                   eval      wohdr1 = 'Pr Repl '
600dAC                   eval      temp13 = '('
600dAC     temp13        cat       prath:0       temp13
600dAC     temp13        cat       ':':0         temp13
600dAC     temp13        cat       pratm:0       temp13
600dAC     temp13        cat       ')':0         temp13
600dAC     wohdr1        cat       temp13:1      wohdr1
600dAC                   else
600rAC                   select
600rAC                   when      e$lng = 'SP'
600rAC                   movel     descsp(10)    wohdr1
600rAC                   other
     C                   movel     desc(10)      wohdr1
600rAC                   endsl
600dAC                   endif
CBIbA*
CBIbA*    Accumulate total Priority Replenishments remaining
CBIbA*    to be completed.
CBIbAC                   exsr      zztprp
     *
     C                   when      rpltyp = '*SPECIFC'
600rAC                   select
600rAC                   when      e$lng = 'SP'
600rAC                   movel     descsp(11)    wohdr1
600rAC                   other
     C                   movel     desc(11)      wohdr1
600rAC                   endsl
     *
     C                   endsl
     *
     C                   select
     C                   when      pttask = 'REPL'
     *
500dMC                   eval      $iitem = #pickititem
500dMC                   eval      $idesc = #pickitdesc
500dMC                   eval      $ipdsc = #pickitpdsc
     C                   eval      w2item = *blanks
610e C                   movel     $iitem        w2itm
610e C                   movel     $ipdsc        w2it1
610e C                   movel     $idesc        w2it2
610e C                   move      $idesc        w2it3
     C                   exsr      zzgeti
     *
     C                   when      pttask = 'REPLBK  '
     C                   eval      *in64 = *on
     * ???????????
     C                   exsr      zzbitm
600rAC                   select
600rAC                   when      e$lng = 'SP'
600rAC                   movel     descsp(7)     wohdr2
600rAC                   other
     C                   movel     desc(7)       wohdr2
600rAC                   endsl
     *
     C                   endsl
     *
     C                   movel     $istr         w2item
500dDC**                 eval      w2fmsl = lbdisp
500dMC                   eval      w2fmsl = #fromsldisp
500dMC                   eval      w2tosl = #picksldisp
     *
     *    Retrieve tie/high for From Slot.
     *
640mAC                   if        #fromittie > 999
640mAC                   eval      w2tie  = 999
640mAC                   else
500dAC                   eval      w2tie  = #fromittie
640mAC                   endif
640mAC                   if        #fromithigh > 999
640mAC                   eval      w2high = #fromithigh
640mAC                   else
500dAC                   eval      w2high = #fromithigh
640mAC                   endif
     *  ??????? What happens this is a Secific or Letdown ?????
     C                   eval      w2ordq = praqs
     *
500dMC                   eval      w2sltq = #fromslstk1 + #fromslrcv1
     C                   if        w2sltq < *zeros
     C                   eval      w2sltq = *zeros
     C                   endif
     *
     C                   if        pttask = 'REPLBK  '
500rDC**                 eval      w2nqty = #fromslavl1 + #fromsltfr1
500rMC                   eval      w2nqty = lbqpck
417lA*
417lA*    Clear qty for specific breakdown replenishments.
500oDC**                 if        rpltyp = '*SPECIFC'
500oDC**                 eval      w2nqty = *zeros
500oDC**                 else
500oDC**                 eval      w2nqty = lbqpck
500oDC**                 endif
     *
     C                   else
600wD **   Only load Pull Qty if this is a single pallet slot,
600wD **   otherwise clear field and make user enter the qty.
600wD **   And not tracking slot positions.
600wA
600wA*    With license tracking we know the qty being taken
600wDC**                 if        #fromslpos >= 2
600wDC**                           and trackpos <> 'Y'
600wDC**                 eval      w2nqty = *zeros
600wDC**                 else
414kA*
500oDC**                 eval      w2nqty = w2sltq
500oMC                   eval      w2nqty = #fromslavl1 + #fromsltfr1
600wDC**                 endif
     C                   endif
     *
500dMC                   eval      w2um1a = #fromitum1
500iMC                   eval      w2um2a = #fromitum1
500iMC                   eval      w2um3a = #fromitum1
     C                   eval      w2qty = lbqpck
     C                   eval      w2repq = lbqpck

     C                   eval      w2aval = lbqavl
     C                   eval      w3qty = rplqty
     C                   else
     C                   eval      w2item = *blanks
610e C                   eval      w2itm = *blanks
610e C                   eval      w2it1 = *blanks
610e C                   eval      w2it2 = *blanks
610e C                   eval      w2it3 = *blanks
     C                   eval      w2fmsl = *blanks
     C                   eval      w2qty = *zeros
     C                   eval      w2sltq = *zeros
     C                   eval      w2nqty = *zeros
     C                   eval      w2tie = *zeros
     C                   eval      w2high = *zeros
     C                   endif
     *
     *    When a specific slot replenishment is being processed fill
     *    in scan field with from slot to eliminate a double scan.
     *    Otherwise, clear field.
     *
     C                   select
     C                   when      rpltyp = '*SPECIFC'
500dMC                   eval      w2scan = #frombasesldsp
     C                   eval      *in03 = *on
     C                   eval      *in70 = *on
415pA*
415pA*    Pull qty field is zero - Position cursor on qty.
415pAC                   when      w2nqty = 0
415pAC                   eval      *in03 = *on
415pAC                   eval      w2scan = *blanks
415pAC                   eval      *in70 = *off
415pA*
     C                   other
     C                   eval      w2scan = *blanks
     C                   eval      *in70 = *off
     C                   endsl

PFCbA*  For Presto, fill in the From slot field
PFCbA*  Presto does double scan, so add period at end
PFCbA*  which fakes the second scan.
PFCbA
PFCbA /free
PFCbA    if client = Presto and w2scan = '';
PFCbA      w2scan = %trim(#frombasesldsp) + '.';
PFCbA    endif;
PFCbA /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     *
500dMC                   eval      $iitem = #pickititem
500dMC                   eval      $idesc = #pickitdesc
500dMC                   eval      $ipdsc = #pickitpdsc
     C                   exsr      zzgeti
     C                   eval      w3item = $istr
610e C                   movel     $iitem        w3itm
610b C                   movel     $ipdsc        w3it1
610b C                   movel     $idesc        w3it2
610b C                   move      $idesc        w3it3
     C                   eval      w3tosl = lbdsp2
     C                   eval      w3um1a = w2um1a
     C                   eval      w3um2a = w2um2a
     C                   eval      w3um3a = w2um3a
     *
     *    Retrieve tie/high for To Slot.
     *
640mAC                   if        #pickittie > 999
640mAC                   eval      w3tie  = 999
640mAC                   else
500dAC                   eval      w3tie  = #pickittie
640mAC                   endif
640mAC                   if        #pickithigh > 999
640mAC                   eval      w3high = 999
640mAC                   else
500dAC                   eval      w3high = #pickithigh
640mAC                   endif
     *
     C                   eval      w3pulq = w2nqty
500nDC**                 if        pttask = 'REPLBK  '
500nDC**                 eval      w3repq = lbqrmn
500nDC**                 else
     C                   eval      w3repq = lbqpck
500nDC**                 endif
     C                   eval      w3balq = w3pulq - w3repq
     C                   if        w3balq > *zeros
     C                   eval      *in63 = *on
     C                   eval      balrem = '*YES'
     C                   else
     C                   eval      *in63 = *off
     C                   eval      balrem = '*NO '
414bAC                   eval      w3balq = *zeros
     C                   endif
GFCaAC                   if        client = glazier
GFCaAC                   eval      *IN03 = *on
GFCaAC                   eval      w3nqty = w3pulq
GFCaAC                   else
     C                   eval      w3nqty = *zeros
GFCaAC                   endif
     *
     C                   eval      w3scan = *blanks
650jAc                   eval      worow = 0
650jAc                   eval      wocol = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL4   Fill screen 4 fields with info from file.
     *
     C     zzfil4        begsr
     *
SVLb C*
SVLb C                   if        client = saval
GLPaAC                             or client = greenleaf
SVLb C                   eval      w4item = '9'
SVLb C                   eval      w4qty = '9'
SVLb C                   else
530bDC*                  eval      w4item = 'N'
530bMC                   eval      w4item = 'Y'
     C                   eval      w4qty = 'N'
SVLb C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL5   Fill screen 5 fields with info from file.
     *
     C     zzfil5        begsr
     *
500dMC                   eval      w5whdp = #fromslwhdp
500dMC                   eval      w5fmsl = #fromsldisp
416jMC                   eval      w5zero = ' '
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL6   Fill screen 06 fields with info from file.
     *
     C     zzfil6        begsr
     *
     C                   eval      w6whse = w1whse
     C                   eval      w6whdp = w1whdp
     *
     *    Start an 'IDLE' task, if no open task.
     *
     C                   eval      curtrn = 0
     C                   eval      curtsk = *blanks
     C                   eval      curtyp = *blanks
     C                   eval      curent = *off
     C                   exsr      zztask
     C                   if        curent = *off
     C                   eval      w1task = 'IDLE  '
500dMC                   exsr      zztrnidle
     C                   endif

PFCaA*    Call APT Interface.
PFCaAc                   if        logapt
PFCaAc                   if        ERROR = *OFF
750cDc**                 eval      apcmd = aptsk5
750cDc**                 eval      aplbl# = 0
750cDc**                 eval      aptrn# = PTTRN#
750cDc**                 eval      aploc = W2FMSL
750cDc**                 exsr      ZZAPT
750cAc                   eval      apseq# += 1
750cAc                   exsr      clr$apt
tst  c****               eval      $apuser = 'ZZFIL6'
750cAC                   eval      $aptrn#  = pttrn#
750cAC                   eval      $aplocation = w2fmsl
750cAC                   eval      $dricommand = '*APT'
750cAC                   eval      $drisubcmd  = aptsk_JOB0100
750cAC                   eval      $drisys2upd = 'D'
750cAC                   eval      chk4err = *off
750cAC                   eval      zmsflag = *off
750cAC                   exsr      zzzdricop
PFCaAc                   endif
PFCaAc                   endif
PFCaA
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL7   Fill screen 07 fields with info from file.
     *
     C     zzfil7        begsr
     *
500raC                   eval      *in93 = *off
     C                   eval      crtrcd = *off
417mAC                   eval      w7rplt = 'N'
500sAC                   eval      w7side = 'B'
650bAC                   eval      wkrplt = ' '
650bAC                   eval      allDepts = *off
650bAC                   eval      savwhdp = *blanks
650bAC                   eval      savprty = -9
650bAC                   eval      whdp_seq = *blanks
650bAC                   eval      idx = 0
650bAC                   eval      nextAllFirst = '1'

650kA*    Retrieve "Skip if pick slot phys qty > item repl level" option.
650kAC                   eval      kywhse = w7whse
650kAC                   exsr      zzcqty

PFCaAc*    Clear APT Counter every time new task started.
PFCaAc                   if        logapt
PFCaAc                   eval      apseq# = 0
PFCaAc                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL8   Fill screen 8 fields with info from file.
     *
     C     zzfil8        begsr
     *
416iAC                   eval      svorsl = *blanks
414kAC                   if        newlb = *off
     C                   eval      wkrtpo = '0'
     C                   eval      kytrn# = lbtrn#
     C                   exsr      zzstr2
     *
500dMC                   eval      svorsl = #fromsldisp
500jDC**                 eval      w8item = #fromslitem

500jAC                   eval      $iitem = #fromititem
500jAC                   eval      $idesc = #fromitdesc
500jAC                   eval      $ipdsc = #fromitpdsc
500jAC                   exsr      zzgeti
500jAC                   eval      w8item = $istr
610e C                   movel     $iitem        w8itm
610b C                   movel     $ipdsc        w8it1
610b C                   movel     $idesc        w8it2
610b C                   move      $idesc        w8it3

     C                   eval      w8balq = w3balq
414kAC                   endif
416iA*    Load originating slot for replenishment.
416iAC                   eval      w8orsl = svorsl
     C                   if        rtnhom = *on
     C                   eval      *in65 = *on
500mDC**                 eval      w8rtn2 = #fromsldisp
500mMC                   eval      w8rtn2 = #frombasesldsp
     C                   else
     C                   eval      *in65 = *off
     C                   eval      w8rtn2 = *blanks
     C                   endif
     *
     C                   eval      w8scan = *blanks
     C                   eval      w8nqty = *zeros

PFCbA*  For Presto, fill in the quantity
PFCbA
PFCbA /free
PFCbA    if client = Presto;
PFCbA      w8nqty = w8balq;
PFCbA      *in03 = *on;
PFCbA    endif;
PFCbA /end-free

     C                   endsr
417cA*
417cA*----------------------------------------------------------------
417cA*
417cA*  ZZFIL9   Fill screen 09 fields with info from file.
417cA*
417cAC     zzfil9        begsr
417cA*
417cA*
417cAC                   endsr
500dA
640bA*----------------------------------------------------------------
640bA*
640bA*  ZZFIL6a  Fill screen 06a fields with info from file.
640bA*
640bAC     zzfil6a       begsr
640bA*
640bAC                   eval      w6whse = w1whse
640bAC                   eval      w6whdp = w1whdp
640bA*
640bAC                   endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZFIL11  Fill screen 11 fields with info from file.
650bA*
650bAC     zzfil11       begsr
650bA*
SVLc C                   if        client = saval
GLPaAC                             or client = greenleaf
SVLc C                   eval      w11jit = '1'
SVLc C                   else
650bAC                   eval      w11jit = 'Y'
SVLc C                   endif
650bA*
650bAC                   endsr
500dA*----------------------------------------------------------------
500dA*  ZZGET2   Get record(s) for screen 1.
500dA*----------------------------------------------------------------
500dA
500dAC     zzget2        begsr

     *  Get From slot information.

     C                   eval      getwhse = lbwhse
     C                   eval      getwhdp = lbwhdp
     C                   eval      getdisp = lbdisp
     C                   exsr      zzgetfromsl
610jAC                   eval      curlic# = $satolcns

     *  Get From Item information.

     C                   exsr      zzgetfromit

     *  Get Pick slot information.

     C                   eval      getwhse = lbwhs2
     C                   eval      getwhdp = lbwhd2
     C                   eval      getdisp = lbdsp2
     C                   exsr      zzgetpicksl

     *  Get Pick Item information.

     C                   exsr      zzgetpickit

     C     endget2       endsr

600uA*----------------------------------------------------------------
600uA*  getcurrstamp  Get current timestamps
600uA*----------------------------------------------------------------
600uA
600uAC     zzgetcurrstampbegsr

     C                   callp     getmicrotime(currstampuc:currstampsys)
     C     currstampsys  adddur    bfcoffset:*H  currstamploc

     C                   endsr
720bA
720bA*--------------------------------------------------------------------
720bA*  ZZPRIREPLEN  Generate Priority Replenishment for Store Location
720bA*--------------------------------------------------------------------
720bA
720bAC     zzPriReplen   begsr
720bA
720bA
720bAc                   eval      levelOk = *off
720bAC                   exsr      clr$prtyrpl
720bA
720bAC                   eval      $prwhseu = *on
720bAC                   eval      $prwhse  = $iWhse
720bA
720bAC                   eval      $pritemu = *on
720bAC                   eval      $pritem  = $iItem
720bA
720bAC                   eval      $prwhdpu = *on
720bAC                   eval      $prwhdp  = $iWhdp
720bA
720bAC                   eval      $prslotu = *on
720bAC                   eval      $prslot  = $iHome
720bA
720bA*   Note, DRIPRTYRPL will determine qty needed.
720bA
720bAC**                 eval      $prqtynu = *off
720bAC**                 eval      $prqtyn  = 0
720bA
720bA*   Note, DRIPRTYRPL will determine if slot is filled to needed qty.
720bA
720bAC**                 eval      $prfillu = *on
720bAC**                 eval      $prfill  = 'Y'
720bA
720bAC                   eval      $dricommand = '*PRTYRPL'
720bAC                   eval      $drisubcmd  = '*RPLLVL'
720bA
720bAC                   eval      $drisys2upd = 'D'
720bAC                   exsr      zzzdricop
720bAC                   if        error
720bAc                   else
720bAc                   if        $driReturn = 'LVLOK'
720bAc                   eval      levelOk = *on
720bAc                   endif
720bAC                   endif
720bA
720bAC                   exsr      sortrpl
720bA
720bAC                   endsr

500qA*----------------------------------------------------------------
500qA*  zzgetdatetime  Get current date & time
500qA*----------------------------------------------------------------
500qA
500qAC     zzgetdatetime begsr

     C                   time                    curtime

     C                   if        curtime < lasttime or curdate = 0
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o
     C                   endif

     C                   eval      lasttime = curtime

     C                   endsr
500dA
500dA*----------------------------------------------------------------
500dA*  ZZGETFROMIT   Get From item being replenished.
500dA*----------------------------------------------------------------
500dA
500dAC     zzgetfromit   begsr

     *  Get item.

     C                   exsr      clr$item
     C                   eval      $itwhse  = #fromslwhse
     C                   eval      $ititem  = #fromslitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETALL'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
500jDC**                 if        error
500jMC                   if        drierr
500jAC                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   goto      endgetfromit
     C                   endif

     C                   eval      #fromitwhse = $itwhse
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
     C                   eval      #fromitsdef = ' '
     C                   eval      #fromittie  = 0
     C                   eval      #fromithigh = 0

     *  Create heading description.

     C                   call      'FRMTIT'
     C                   parm                    #fromititem
     C                   parm                    #fromitdesc
     C                   parm                    #fromitpdsc
     C                   parm      ' '           #fromithead

     *  Save tie/high info if defined for item.

     C     1             do        5             i
     C                   if        $idsdef(i) = #fromslsdef
     C                   eval      #fromitsdef = $idsdef(i)
     C                   eval      #fromittie  = $idtie(i)
     C                   eval      #fromithigh = $idhigh(i)
     C                   leave
     C                   endif
     C                   enddo
500mA
500mA*  Get tracking info for item.
500mA
500mAC                   exsr      zzgettrack

     *  Get corresponding SSB item, if any.

     C                   exsr      clr$item
     C                   eval      $itwhse  = #fromitwhse
     C                   eval      $ititem  = #fromititem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETSSB'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        $drireturn = 'SSBNOTFND'
     C                   eval      #fromssbflag = *off
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
     C                   else
     C                   eval      #fromssbflag = *on
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
     C                   endif

     C     endgetfromit  endsr
500dA
500dA*----------------------------------------------------------------
500dA*  ZZGETFROMSL   Get From slot.
500dA*----------------------------------------------------------------
500dA
500dAC     zzgetfromsl   begsr

600uA*    Do not call DRISLOT after coming from IT276/LT108.
600uA*    Re: IT276 has already moved qtys from the From slot into
600uA*        the USR slot, so IT276/LT108 sends us the $slot/2 info.

600uAC                   if        not it276Flag
600wAC                             and not lt108Flag

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = getwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = getwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = getdisp

     C                   eval      $dricommand = '*SLOT'
600zDC**                 eval      $drisubcmd  = '%GETCHKV'
600zMC                   eval      $drisubcmd  = '%GETCHKVX'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
500jDC**                 if        error
500jMC                   if        drierr
500jAC                   eval      error = *on
     C                   goto      endgetfromsl
     C                   endif

600uAC                   endif

     C                   eval      #fromslwhse = $slwhse
     C                   eval      #fromslwhdp = $slwhdp
     C                   eval      #fromslstyp = $slstyp
     C                   eval      #fromsldisp = $sldisp
     C                   eval      #fromslaisl = $slaisl
     C                   eval      #fromslloc  = $slloc
     C                   eval      #fromslpseq = $slpseq
     C                   eval      #fromslrlvl = $slrlvl
     C                   eval      #fromslhand = $slhand
     C                   eval      #fromslstat = $slstat
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

     C                   eval      #frombasesldsp = $sacdsp
     C                   eval      #fromsaToLcns = $saToLcns
     C                   eval      #fromsaToPos  = $saToPos
     C                   eval      #fromsaOLcns = $saOLcns
     C                   eval      #fromslSide = $slSide

     *  Get slot definition for From slot.

     C                   exsr      clr$slotdef
     C                   eval      $sdwhse  = $slwhse
     C                   eval      $sdcode  = $slsdef

     C                   eval      $dricommand = '*SLOTDEF'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
500jDC**                 if        error
500jMC                   if        drierr
     C                   eval      error = *off
     C                   eval      $sdpos = 1
     C                   endif
     C                   eval      #fromslpos = $sdpos

     C     endgetfromsl  endsr
500dA
500dA*----------------------------------------------------------------
500dA*  ZZGETOVRFSL   Get Overflow slot.
500dA*----------------------------------------------------------------
500dA
500dAC     zzgetovrfsl   begsr

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = #fromslwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #fromslwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = w8scan

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GETCHKV'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
500jDC**                 if        error
500jMC                   if        drierr
500jAC                   eval      error = *on
     C                   goto      endgetovrfsl
     C                   endif

     C                   eval      #ovrfslwhse = $slwhse
     C                   eval      #ovrfslwhdp = $slwhdp
     C                   eval      #ovrfslstyp = $slstyp
     C                   eval      #ovrfsldisp = $sldisp
     C                   eval      #ovrfslaisl = $slaisl
     C                   eval      #ovrfslloc  = $slloc
     C                   eval      #ovrfslpseq = $slpseq
     C                   eval      #ovrfslrlvl = $slrlvl
     C                   eval      #ovrfslhand = $slhand
     C                   eval      #ovrfslstat = $slstat
     C                   eval      #ovrfslrsrv = $slrsrv
     C                   eval      #ovrfslentd = $slentd
     C                   eval      #ovrfslexpd = $slexpd
     C                   eval      #ovrfslslfd = $slslfd
     C                   eval      #ovrfslactv = $slactv
     C                   eval      #ovrfslbld  = $slbld
     C                   eval      #ovrfslpick = $slpick
     C                   eval      #ovrfslitem = $slitem
     C                   eval      #ovrfslsdef = $slsdef
     C                   eval      #ovrfslvirt = $sfvirt
     C                   eval      #ovrfslstk1 = $slstk1
     C                   eval      #ovrfslstk2 = $slstk2
     C                   eval      #ovrfslstk3 = $slstk3
     C                   eval      #ovrfslalc1 = $slalc1
     C                   eval      #ovrfslalc2 = $slalc2
     C                   eval      #ovrfslalc3 = $slalc3
     C                   eval      #ovrfsltfr1 = $sltfr1
     C                   eval      #ovrfsltfr2 = $sltfr2
     C                   eval      #ovrfsltfr3 = $sltfr3
     C                   eval      #ovrfslpck1 = $slpck1
     C                   eval      #ovrfslpck2 = $slpck2
     C                   eval      #ovrfslpck3 = $slpck3
     C                   eval      #ovrfslrcv1 = $slrcv1
     C                   eval      #ovrfslrcv2 = $slrcv2
     C                   eval      #ovrfslrcv3 = $slrcv3
     C                   eval      #ovrfslphy1 = $slphy1
     C                   eval      #ovrfslphy2 = $slphy2
     C                   eval      #ovrfslphy3 = $slphy3
     C                   eval      #ovrfslavl1 = $slavl1
     C                   eval      #ovrfslavl2 = $slavl2
     C                   eval      #ovrfslavl3 = $slavl3

     C                   eval      #ovrfbasesldsp = $sacdsp

     *  Get slot definition for From slot.

     C                   exsr      clr$slotdef
     C                   eval      $sdwhse  = $slwhse
     C                   eval      $sdcode  = $slsdef

     C                   eval      $dricommand = '*SLOTDEF'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
500jDC**                 if        error
500jMC                   if        drierr
     C                   eval      error = *off
     C                   eval      $sdpos = 1
     C                   endif
     C                   eval      #ovrfslpos = $sdpos

     C     endgetovrfsl  endsr
500dA
500dA*----------------------------------------------------------------
500dA*  ZZGETPICKIT   Get pick slot item being replenished.
500dA*----------------------------------------------------------------
500dA
500dAC     zzgetpickit   begsr

     *  Get item.

     C                   exsr      clr$item
     C                   eval      $itwhse  = #pickslwhse
     C                   eval      $ititem  = #pickslitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETALL'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
500jDC**                 if        error
500jMC                   if        drierr
500jAC                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   goto      endgetpickit
     C                   endif

     C                   eval      #pickitwhse = $itwhse
     C                   eval      #pickititem = $ititem
     C                   eval      #pickittype = $ittype
     C                   eval      #pickitdesc = $itdesc
     C                   eval      #pickitpdsc = $itpdsc
     C                   eval      #pickitwhdp = $itwhdp
     C                   eval      #pickitstyp = $itstyp
     C                   eval      #pickitdesg = $itdesg
     C                   eval      #pickitum1  = $itum1
     C                   eval      #pickitflg1 = $itflg1
     C                   eval      #pickitum2  = $itum2
     C                   eval      #pickitumq2 = $itumq2
     C                   eval      #pickitflg2 = $itflg2
     C                   eval      #pickitum3  = $itum3
     C                   eval      #pickitumq3 = $itumq3
     C                   eval      #pickitnrpk = $imnrpk
     C                   eval      #pickitflgd = $itflgd
     C                   eval      #pickitcube = $itcube
     C                   eval      #pickitswgt = $itswgt
     C                   eval      #pickitcwgt = $itcwgt
     C                   eval      #pickitmitem = $itmitem
     C                   eval      #pickitsdef = ' '
     C                   eval      #pickittie  = 0
     C                   eval      #pickithigh = 0

     *  Create heading description.

     C                   call      'FRMTIT'
     C                   parm                    #pickititem
     C                   parm                    #pickitdesc
     C                   parm                    #pickitpdsc
     C                   parm      ' '           #pickithead

     *  Save tie/high info if defined for item.

     C     1             do        5             i
     C                   if        $idsdef(i) = #pickslsdef
     C                   eval      #pickitsdef = $idsdef(i)
     C                   eval      #pickittie  = $idtie(i)
     C                   eval      #pickithigh = $idhigh(i)
     C                   leave
     C                   endif
     C                   enddo

     *  Get corresponding SSB item, if any.

     C                   exsr      clr$item
     C                   eval      $itwhse  = #pickitwhse
     C                   eval      $ititem  = #pickititem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETSSB'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        $drireturn = 'SSBNOTFND'
     C                   eval      #pickssbflag = *off
     C                   eval      #pickssbititem = ' '
     C                   eval      #pickssbittype = ' '
     C                   eval      #pickssbitdesc = ' '
     C                   eval      #pickssbitpdsc = ' '
     C                   eval      #pickssbitwhdp = ' '
     C                   eval      #pickssbitstyp = ' '
     C                   eval      #pickssbitdesg = ' '
     C                   eval      #pickssbitum1  = ' '
     C                   eval      #pickssbitum2  = ' '
     C                   eval      #pickssbitumq2 = 0
     C                   eval      #pickssbitum3  = ' '
     C                   eval      #pickssbitumq3 = 0
     C                   else
     C                   eval      #pickssbflag = *on
     C                   eval      #pickssbititem = $ititem
     C                   eval      #pickssbittype = $ittype
     C                   eval      #pickssbitdesc = $itdesc
     C                   eval      #pickssbitpdsc = $itpdsc
     C                   eval      #pickssbitwhdp = $itwhdp
     C                   eval      #pickssbitstyp = $itstyp
     C                   eval      #pickssbitdesg = $itdesg
     C                   eval      #pickssbitum1  = $itum1
     C                   eval      #pickssbitum2  = $itum2
     C                   eval      #pickssbitumq2 = $itumq2
     C                   eval      #pickssbitum3  = $itum3
     C                   eval      #pickssbitumq3 = $itumq3
     C                   endif

     C     endgetpickit  endsr
500dA
500dA*----------------------------------------------------------------
500dA*  ZZGETPICKSL   Get Pick slot.
500dA*----------------------------------------------------------------
500dA
500dAC     zzgetpicksl   begsr

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = getwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = getwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = getdisp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GETCHKV'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
500jDC**                 if        error
500jMC                   if        drierr
500jAC                   eval      error = *on
     C                   goto      endgetpicksl
     C                   endif

     C                   eval      #pickslwhse = $slwhse
     C                   eval      #pickslwhdp = $slwhdp
     C                   eval      #pickslstyp = $slstyp
     C                   eval      #picksldisp = $sldisp
     C                   eval      #pickslaisl = $slaisl
     C                   eval      #pickslloc  = $slloc
     C                   eval      #pickslpseq = $slpseq
     C                   eval      #pickslrlvl = $slrlvl
     C                   eval      #pickslhand = $slhand
     C                   eval      #pickslstat = $slstat
     C                   eval      #pickslrsrv = $slrsrv
     C                   eval      #pickslentd = $slentd
     C                   eval      #pickslexpd = $slexpd
     C                   eval      #pickslslfd = $slslfd
     C                   eval      #pickslactv = $slactv
     C                   eval      #pickslbld  = $slbld
     C                   eval      #pickslpick = $slpick
     C                   eval      #pickslitem = $slitem
     C                   eval      #pickslsdef = $slsdef
     C                   eval      #pickslvirt = $sfvirt
     C                   eval      #pickslstk1 = $slstk1
     C                   eval      #pickslstk2 = $slstk2
     C                   eval      #pickslstk3 = $slstk3
     C                   eval      #pickslalc1 = $slalc1
     C                   eval      #pickslalc2 = $slalc2
     C                   eval      #pickslalc3 = $slalc3
     C                   eval      #picksltfr1 = $sltfr1
     C                   eval      #picksltfr2 = $sltfr2
     C                   eval      #picksltfr3 = $sltfr3
     C                   eval      #pickslpck1 = $slpck1
     C                   eval      #pickslpck2 = $slpck2
     C                   eval      #pickslpck3 = $slpck3
     C                   eval      #pickslrcv1 = $slrcv1
     C                   eval      #pickslrcv2 = $slrcv2
     C                   eval      #pickslrcv3 = $slrcv3
     C                   eval      #pickslphy1 = $slphy1
     C                   eval      #pickslphy2 = $slphy2
     C                   eval      #pickslphy3 = $slphy3
     C                   eval      #pickslavl1 = $slavl1
     C                   eval      #pickslavl2 = $slavl2
     C                   eval      #pickslavl3 = $slavl3

     C                   eval      #pickbasesldsp = $sacdsp

     *  Get slot definition for From slot.

     C                   exsr      clr$slotdef
     C                   eval      $sdwhse  = $slwhse
     C                   eval      $sdcode  = $slsdef

     C                   eval      $dricommand = '*SLOTDEF'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
500jDC**                 if        error
500jMC                   if        drierr
     C                   eval      error = *off
     C                   eval      $sdpos = 1
     C                   endif
     C                   eval      #pickslpos = $sdpos

     C     endgetpicksl  endsr
     *----------------------------------------------------------------
650kA*  ZZGETPICKSLQ   Get Pick slot physical qty.
650kA*----------------------------------------------------------------
650kA
650kAC     zzgetpickslq  begsr
650kA
     *   Get SLOT record.

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = prwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = prwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = prtdis

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GET2'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   eval      pckSltPhyQ = 0
     C                   eval      $pcmd = '*QTY2STR'
     *
     *      Convert physical quantity to string.
     *
     C                   eval      $pqty1 = $slphy1
     C                   eval      $pqty2 = $slphy2
     C                   eval      $pqty3 = $slphy3
     *
     C                   call      'CVTQTY'
     C                   parm                    $pcmd
     C                   parm                    $pprg
     C                   parm                    $pqty1            7 0
     C                   parm                    $pqty2            7 0
     C                   parm                    $pqty3            7 0
     C                   parm                    $pum1             2
     C                   parm                    $pum2             2
     C                   parm                    $pum3             2
     C                   parm                    $pqstr           10
     C                   parm                    $pustr           17
     C                   parm                    $prtn
     C                   parm                    $perm

     *   Convert string to numeric.

     C                   monitor
     C                   eval      pckSltPhyQ = %dec($pqstr:10:0)
     C                   on-error
     C                   eval      pckSltPhyQ = 0
     C                   endmon

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGETI   Get item description and pack description.
     *
     C     zzgeti        begsr
     *
     *    LABEL7 file is a Join file with PIRITEM and hence, no need
     *    to chain to that file.
     *
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   eval      svitem = $iitem
     *
     C                   endsr

500mA*----------------------------------------------------------------
500mA*  ZZGETTRACK  Get tracking options.
500mA*----------------------------------------------------------------
500mA
500mAC     zzgettrack    begsr

     C                   eval      $lcmd = *blanks
     C                   eval      $lprg = #pgm
     C                   eval      $lwhse2 = $itwhse
     C                   eval      $ltrackitem = $imltrk

     C                   call      'GETTRACK'
     C                   parm                    $lparm

     C                   eval      trackitem   = $ltrackitem
     C                   eval      trackpos    = $ltrackpos
     C                   eval      trackposmrg = $lposmrg
     C                   eval      trackposrtn = $lposrtn
     C                   eval      trackpsplit  = $lpsplit
     C                   eval      tracktsplit  = $ltsplit

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      curtrn = 0
     C                   eval      curtsk = *blanks
     C                   eval      curtyp = *blanks
414eAC                   eval      lstslt = *blanks
     C                   eval      curent = *off
     C                   eval      rtnhom = *off
     C                   eval      crtrcd = *off
414eAC                   eval      balexc = *off
414kAC                   eval      skpslt = *off
414kAC                   eval      vrtslt = *off
414kAC                   eval      lstscr = *blanks
417kAC                   eval      svwhse = #whse
     *
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   eval      wozero = 'N'
     C                   eval      woemty = ' '
     C                   eval      newvs = *off
     C                   eval      newlb = *off
     C                   eval      exist = *off
     C                   eval      flaghs = *off
     C                   eval      forevr = *off
     C                   eval      bypass = *off
     C                   eval      spcslt = *off
415dAC                   eval      bszero = *off
415mAC                   eval      chknew = *off
415mAC                   eval      newtrn = *off
415nAC                   eval      dteold = *off
415nAC                   eval      dteofl = *off
415uAC                   eval      skippd = *off
417hAC                   eval      restrt = *off
417hAC                   eval      restr2 = *off
     C                   eval      rpltyp = *blanks
417hAC                   eval      lsttyp = *blanks
     C                   eval      w4qty = *blanks
     C                   eval      balrem = *blanks
415kAC                   eval      rtnto = *blanks
417iAC                   eval      spfcrp = '*NO '
700hAC                   eval      dspless5 = '0'
700hAC                   eval      aisl1    = *blanks
700hAC                   eval      aisl2    = *blanks
SVLbAC                   if        client = saval
GLPaAC                             or client = greenleaf
SVLbAC                   eval      woyn = '1,9 '
610eAC                   else
610eAC                   eval      woyn = 'Y,N '
SVLbAC                   endif
     *
     *    Define partial key for LABEL7 file.
     *
     C     lbkey7        klist
     C                   kfld                    pttrn#
     *
     *    Define key for ITEMDEF file.
     *
     C     keyid         klist
     C                   kfld                    lbwhse
     C                   kfld                    slitem
     C                   kfld                    slsdef
416bA*
416bA*  Define key for ITEMMSC file.
416bA*
416bAC     imkey         klist
416bAC                   kfld                    lbwhse
416bAC                   kfld                    lbitem
     *
     *    Define key for LABEL file.
     *
     C     lbkey         klist
     C                   kfld                    svlbl#
415lA*
415lA*  Define key for OPTIOND file.
415lA*
415lAC                   eval      kydcod = '*PICK   '
415lAC     opdkey        klist
415lAC                   kfld                    kydcod
415lAC                   kfld                    kydwhs
415lAC                   kfld                    kydwdp
     *
     *    Define key for OPTIONS file.
     *
     C     opkey         klist
     C                   kfld                    kywhse
     C                   kfld                    kycode
     C                   eval      kycode = '*FEATURE'
     *
     *    Define key for PIRTRAN file.
     *
     C     ptkey         klist
     C                   kfld                    svtrn#
     *
     *    Define key for PIRTRAN2 file.
     *
     C     ptke22        klist
     C                   kfld                    #emp#
     C                   kfld                    stdate
     C                   kfld                    sttime
     *
     *  Define key for PIRTRAN1 file.
     *
     C     ptkey1        klist
     C                   kfld                    #emp#
     C                   kfld                    kystat
     *
     *    Define partial key for PIRTRAN2 file.
     *
     C     ptkey2        klist
     C                   kfld                    #emp#
     C                   kfld                    stdate
     *
     *    Define partial key for PIRTRAN3 file.
     *
     C                   eval      wkgrp1 = 'L'
     C                   eval      wkgrp2 = ' '
     C     ptkey3        klist
     C                   kfld                    w1whse
     C                   kfld                    wkgrp1
     C                   kfld                    wkgrp2
     *
     *    Define Full key for PIRTRAN3 file.
     *
     C                   eval      wkrtpo = '0'
     C     ptky3a        klist
     C                   kfld                    w1whse
     C                   kfld                    wkgrp1
     C                   kfld                    wkgrp2
     C                   kfld                    wkrtpo
     C                   kfld                    kytrn#
CBIdA*
CBIdA*    Define Full key for LABEL12 file.
CBIdA*
CBIdAC     lbky12        klist
CBIdAC                   kfld                    w1whse
CBIdAC                   kfld                    wkgrp1
CBIdAC                   kfld                    wkgrp2
CBIdAC                   kfld                    wkwhdp
CBIdAC                   kfld                    wkdsp2
CBIdAC                   kfld                    kytrn#
     *
     *    Define Partial key for PRPLFIL1 file.
     *
     C     keypr1        klist
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
     *
     C     keypr2        klist
     C                   kfld                    prwhse
     C                   kfld                    prwhdp
     C                   kfld                    prseq#
CBIbA*
CBIbA*    Define Partial key for PRPLFIL5 file.
CBIbA*
CBIbAC     keypr5        klist
CBIbAC                   kfld                    w7whse
CBIbAC                   kfld                    w7whdp
     *
650bA*    Define Partial key for PRPLFIL10 file.
650bA*
650bAC     keypr10       klist
650bAC                   kfld                    w7whse
650bAC                   kfld                    wkrplt
     *
650bA*    Define key for PRPLFIL11 file.
650bA*
650bAC     keypr11       klist
650bAC                   kfld                    #fromslwhse
650bAC                   kfld                    #fromslwhdp
650bAC                   kfld                    #fromsldisp
     *
     *    Define key for SLOTDEF file.
     *
     C     sdkey         klist
     C                   kfld                    lbwhse
     C                   kfld                    slsdef
600gD*
600gD*  Define key for SLOTOUT file.
600gD*
600gD*          KEYSO     KLIST
600gD*                    KFLD           LBWHSE
600gD*                    KFLD           LBWHDP
600gD*                    KFLD           LBDSP2
600gD*                    KFLD           LBITEM
     *
     *    Define key for SLOT2 file. (From slot)
     *
     C     keysl1        klist
     C                   kfld                    w7whse
     C                   kfld                    w7whdp
     C                   kfld                    kyaisl
     *
     *    Define key for SLOT2 file. (From slot)
     *
     C     slfkey        klist
     C                   kfld                    lbwhse
     C                   kfld                    lbwhdp
     C                   kfld                    lbdisp
     C     slfmky        klist
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
     C                   kfld                    w1tdis
     *
     C     sfmky2        klist
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
     C                   kfld                    w8scan
     *
     *    Define key for SLOT2 file. (To slot)
     *
     C     sltkey        klist
     C                   kfld                    lbwhse
     C                   kfld                    lbwhdp
     C                   kfld                    lbdsp2
416bA*
416bA*  Define partial key for SLOT3 file.
416bA*
416bAC     keys3         klist
416bAC                   kfld                    lbwhse
416bAC                   kfld                    lbitem
416bAC                   kfld                    k3stat
416bAC                   kfld                    k3pick
     *
     *    Define key for TASK file.
     *
     C     tkkey         klist
     C                   kfld                    t#task
     *
     *    Define key for TASKDET file.
     *
     C     keytd         klist
     C                   kfld                    pttask
     C                   kfld                    ptwhse
     C                   kfld                    ptwhdp
     C                   kfld                    ptstyp
     *
     *    Define key for PIRITEM file.
     *
     C     itkey         klist
     C                   kfld                    lbwhse
     C                   kfld                    kyitem
     *
650kA*    Define key for PIRITEM file.
650kA*
650kAC     itkey1        klist
650kAC                   kfld                    prwhse
650kAC                   kfld                    pritem
     *
     *    Define key for ITEMLNK file.
     *
     C     ilkey         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbitem
     *
     *    Define key for VSLOT1 file. (From slot)
     *
     C     svfkey        klist
     C                   kfld                    lbwhse
     C                   kfld                    lbwhdp
     C                   kfld                    svfdis
414kAC     keyvs2        klist
414kAC                   kfld                    kywhse
414kAC                   kfld                    kywhdp
414kAC                   kfld                    kydisp
416cA*
416cA*    Define key for RTEHED file.
416cA*
416cAC     keyrh         klist
416cAC                   kfld                    lbwhse
416cAC                   kfld                    lbrte
600uA*
600uA*    Define partial key for WORKUSR 3 file
600uA*
600uAC     keywu3p       klist
600uAC                   kfld                    kyrectype
600uAC                   kfld                    #emp#
600uA*
600uA*    Define full key for WORKUSR 3 file
600uA*
600uAC     keywu3        klist
600uAC                   kfld                    kyrectype
600uAC                   kfld                    #emp#
600uAC                   kfld                    kywhse
600uaC                   kfld                    kywhdp
600uAC                   kfld                    kydisp
416cA*
416bA*
416bA*   Get system options.
416bAC                   eval      kywhse = *zeros
416bAC                   eval      kycode = '*SYSTEM '
416bAC     opkey         chain     options                            79
416bAC                   if        *in79
416bAC                   eval      opmpck = 'N'
416bAC                   else
416bAC                   eval      opdat2 = opdata
416bAC                   endif
416bAC                   eval      nbrpck = *zeros
     *
     *    Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
417EAC                   eval      ckdate = $cvd8o
     *
     *    - Get default values for the user.
     *
     C                   call      'GETUSER'
     C                   parm                    #user
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
600rAC                   parm                    e$bpu             1
600rAC                   parm                    e$lng             2
600rAC                   if        #rtn <> '*OK'
600rAC                   eval      e$lng = 'EN'
600rAC                   endif
     *
     C                   eval      w1whse = #whse
     C                   eval      w7whse = #whse
600qA*
600qA*    Initialize fields in $sparm ds  when called from LT105CL.
600qAC                   if        $scmd = '*STDRPL '
600qAC                   eval      $sprg = #prog
600qAC                   eval      $swhse = *zeros
600qAC                   eval      w7whse = #whse
600qAC                   eval      $strn# = *zeros
600qAC                   endif
600qA*
     C                   select
     C                   when      #rtn = '*OK     '
     C                   eval      w1whdp = #whdp
     C                   eval      w7whdp = #whdp
     *
     C                   endsl
600o C                   if        client = cheney
CBIdAC                   eval      w7dsps = 1
600oAC                   else
600oAC                   eval      w7dsps = 2
600oAC                   endif
416oA*
416oA*  Dummy read for compiler.
416oA*
416oAC                   if        0 = 1
416oAC                   read      sltrpex                                79
416oAC                   endif
600eA*
600eA*   Load handstack array with codes (A..Z, AA..AZ, ...)
600eA*
600eAC                   eval      k = 0
600eAC     1             do        27            i
600eAC     2             do        27            j
600eAC                   add       1             k
600eAC     ltr(i)        cat       ltr(j)        hnd(k)
600eAC                   enddo
600eAC                   enddo
     *
PFCaA*   Check for APT logging option
PFCaAc                   eval      kywhse = 1
PFCaAc                   eval      kycode = '*APTFTP '
PFCaAc     opkey         chain     options                            79
PFCaAc                   if        %found(options)
PFCaAc                             and %subst(opdata:1:1) = 'Y'
PFCaAc                   eval      logapt = *on
PFCaAc                   else
PFCaAc                   eval      logapt = *off
PFCaAc                   endif

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
610iAC                   eval      currRoutine = 'zzinz2'
610iAC                   exsr      phpgmV1V2V3s
600uAC                   eval      kyrectype = 'RPL'
500rMC                   eval      *in93 = *off
     C                   eval      worow = *zeros
     C                   eval      wocol = *zeros
     C                   eval      refrsh = *on
     C                   eval      done = *off
     C                   eval      excptn = *off
600fAC                   eval      prptyp = '*IMMED  '
600uA*
600uA*   Clear work file for user.
600uA*
600uAC                   exsr      zzwrkinz
510hA*
510hA*   Get screen size being used.
510hA*
510hAC                   call      'PIRRFSCR'
510hAC                   parm      '*GET'        #lcmd             8
510hAC                   parm                    #lline            2
510hAC                   parm                    #lcol             3
     *
600qA*
600qAC                   select
600qA*    Process interleaving replenishment.
600qAC                   when      $scmd = '*INTERLV'
600qAC                   eval      $srtn = *blanks
600qA*
600qA*    Force warehouse,dept. to incoming values from calling pgm.
600qAC                   eval      w1whse = $swhse
600qAC                   eval      w7whse = $swhse
600qAC                   eval      #whse = $swhse
600qAC                   eval      w1whdp = $swhdp
600qAC                   eval      w7whdp = $swhdp
600qAC                   eval      #whdp = $swhdp
600qA*
600qAC                   eval      crtrcd = *off
600qAC                   eval      done = *off
600qAC                   eval      chknew = *off
600qAC                   eval      restrt = *off
600qAC                   eval      restr2 = *off
600qA*
600qAC                   eval      letord = 'ROUTE'
600qAC                   eval      rpltyp = *blanks
600qAC                   eval      frmasl = *blanks
600qAC                   eval      toaisl = *blanks
600qAC                   eval      w7fas = *blanks
600qAC                   eval      w7tas = *blanks
600qAC                   eval      w7rplt = 'N'
600qA*    Get all replenishment options since SC7 routine
600qA*    isn't being run when in Interleave Replen mode.
600qA*
600qA*    Check for putaway option - Manual or directed.
600qAC                   eval      kydwhs = w7whse
600qAC                   eval      kydwdp = w7whdp
600qAC                   exsr      zzrtno
600qA*    Retrieve Expiration/Entered date options.
600qAC                   eval      kywhse = w7whse
600pA*    Retrieve Check "To Slot" quantity option.
600qAC                   exsr      zzcqty
600qA*    Check installed feature level.
600qAC                   exsr      zzfeat
600qA*
600qA*    Send user to replenishment found by RC200.
600qAC                   select
600qA*      Process Letdown replenishment found by RC200.
600qAC                   when      $srplt = 'LD'
600qAC     $strn#        chain(n)  pirtran                            79
600qAC                   if        *in79  or
600qAC                             ptstat <> '1'
600qAC                   eval      nxtscr = 'EOJ'
600qAC                   eval      $srtn = '*CANCEL '
600qA*
600qAC                   else
600qA*      Letdown still available.
600qAC                   eval      wkgrp1 = ptgrp1
600qAC                   eval      wkgrp2 = ptgrp2
600qAC                   eval      wkrtpo = ptrtpo
600qAC                   eval      kytrn# = pttrn#
600qA*
600qA*      Start Letdown transaction for user.
600qAC                   exsr      zzstrt
600qA*
600qA*      Letdown not available. Return to calling pgm.
600qAC                   if        done = *on
600qAC                   eval      nxtscr = 'EOJ'
600qAC                   eval      $srtn = '*CANCEL '
600qA*
600qAC                   else
600qAC                   eval      $strn# = *zeros
600qAC                   eval      rpltyp = '*LETDOWN'
600qAC                   exsr      scr02i
600qAC                   endif
600qA*
600qAC                   endif
600qA*
600qA*      Process Priority Replenishment found by RC200.
600qAC                   when      $srplt = 'PR'
600qAC                   eval      prptyp = $scmd
600qAC                   eval      prwhse = $swhse
600qAC                   eval      prwhdp = $swhdp
600qAC                   z-add     $strn#        prseq#
600qAC     keypr2        chain(n)  prplfil1                           79
600qAC                   if        *in79  or
600qAC                             prflag <> 'S'
600qAC                   eval      nxtscr = 'EOJ'
600qAC                   eval      $srtn = '*CANCEL '
600qA*
600qAC                   else
600qA*      Priority Replenishment still available.
600qAC                   exsr      zznext
600qA*
600qA*      Priority Replenishment not available. Return to calling pgm.
600qAC                   if        done = *on
600qAC                   eval      nxtscr = 'EOJ'
600qAC                   eval      $srtn = '*CANCEL '
600qA*
600qAC                   else
600qA*      Create Priority Replenishment transaction.
600qAC                   exsr      zzcrpr
600qAC                   eval      $strn# = *zeros
600qAC                   endif
600qA*
600qAC                   endif
600qA*
600qAC                   endsl
600qA*
600qAC                   other
600qA*
     C                   exsr      scr07i
600qAC                   endsl
600qA*
610iAC                   exsr      phpgmV1V2V3e
     C                   endsr
600fA*
600fA*----------------------------------------------------------------
600fA*
600fA*  ZZCRPR   Create Immediate Priority Replenishment.
600fA*
600fAC     zzcrpr        begsr
600fA*
600fAC                   eval      $pcmd = '*DELETE '
600fAC                   eval      $puky = dsfkey
600fAC                   eval      $pfeat = opfeat
600qA*
600qAC                   eval      $prplt = ' '
600qAC                   eval      $pcrtt = 'Y'
600qAC                   eval      $pbat# = *zeros
510fAC                   eval      $ptrn# = *zeros
600qAC                   eval      $plbl# = *zeros
600yMC                   call      'LT108'
600fAC                   parm                    $parms
600yAC                   parm                    $slot
600yAC                   parm                    $slot2
600fAC                   if        $prtn = '*NONE   '
600fAC     keypr2        chain     prplfil1                           7978
600fAC                   if        not *in79
600fAC                   eval      prflag = 'D'
600fAC                   update    prrec                                78
600fAC                   endif
600fAC                   goto      #endcr
600fAC                   endif
600fA*
600yAC                   eval      lt108Flag = *on
600fAC                   eval      rpltyp = '*PRIORTY'
600fAC                   eval      *in61 = *on
600fAC                   eval      usrrpl = *on
600fAC                   eval      bypass = *off
600fAC                   eval      kytrn# = $ptrn#
CBIeA*
CBIeAC                   if        letord = 'SLOT'
CBIeAC                   eval      wkrtpo = '0'
CBIeAC                   endif
600fA*
600fA*    Start Immediate Priority Replenishment transaction.
600fAC                   exsr      zzstr2
600fA*
600fA*    Setup Screen 2 with Priority Replenishment info.
600fAC                   exsr      scr02i
600fA*
600yAC                   eval      lt108Flag = *off
600fAC     #endcr        endsr
417dA*
     *----------------------------------------------------------------
     *
     *  ZZNEXT   Find next priority replenishment.
     *
     C     zznext        begsr
600qA*
600qA*    Start at Letdown transaction passed to pgm.
600qAC                   if        $scmd = '*INTERLV'  and
600qAC                             $strn# > 0
600qAC     keypr2        setll     prplfil1
600qAC                   goto      #nxt01
600qAC                   endif
600qA*
     *    -Skip priority replenishment - Get next replenisment avail.
     C                   if        bypass = *on
     C                   eval      prseq# = savseq
     C     keypr2        setgt     prplfil1
     C                   endif
530 A*
530 A*    -Nothing skipped - Get next replenisment avail.
530 AC                   if        bypass = *off
530 A*
530 A*    -Get next JIT replenisment avail.
530 AC                   if        prptyp = '*IMMED'
700gAC                   eval      prwhse = w1whse
700gAC                   eval      prwhdp = w1whdp
530 AC                   eval      prseq# = -99999
530 A*    -Position to first JIT replenishments.
530 AC     keypr2        setll     prplfil1
530 AC                   else
530 A*
530 AC                   eval      prseq# = savseq
530 AC     keypr2        setgt     prplfil1
530 AC                   endif
530 A*
530 AC                   endif
417hA*
417hA*    -Restart at last interupted Priority replenisment.
417hAC                   if        restrt = *on  and
417hAC                             restr2 = *on
417hAC                   eval      wkrtpo = hlrtpo
417hAC                   eval      prseq# = hldseq
417hAC     keypr2        setll     prplfil1
417hAC                   eval      restrt = *off
417hAC                   eval      restr2 = *off
417hAC                   endif
     *
600qAC     #nxt01        tag
416mAC                   eval      loop = *off
     C                   dow       forevr = forevr
     C     keypr1        reade     prplfil1                             7879
     C                   select
     C                   when      *in79
     *
     *     If end of file is reached and a replenishment was skipped,
     *     reset back to top of file looking for another or same trans.
416mAC                   select
600eA*
600eA*     If bypass is on, return to looking for open letdowns.
416mAC                   when      loop = *off  and
600eAC                             bypass = *off
416mAC     keypr1        setll     prplfil1
416mAC                   eval      loop = *on
416mAC                   iter
416mAC                   endsl
     C                   if        bypass = *on
     C                   endif
     *
     C                   eval      done = *on
     C                   leave
     *
600fA*
600fA*    Processing Immediate Priority Replenishments,
600fA*    skip all Normal Priority Replenishments.
600fAC                   when      prptyp = '*IMMED  '  and
530 DC*                            prseq# >= 0  or
530 MC                             prseq# >= 0
530 AC                   eval      done = *on
530aAC                   unlock    prplfil1
530 AC                   leave
530 A*
600fA*    Processing Noraml Priority Replenishments,
600fA*    skip all Immediate Priority Replenishments.
530 DC*                            prptyp = '*NORMAL '  and
530 MC                   when      prptyp = '*NORMAL '  and
600fAC                             prseq# < 0
600fAC                   iter
     C                   when      *in78  or
     C                             prflag <> 'S'  or
     C                             w7fas > *blanks  and
     C                             prtail < frmasl  or
     C                             w7fas > *blanks  and
     C                             prtail > toaisl  or
YHA  *     YHata - Aisle 61 only process if from and to aisle = 61
YHA  C                             client = yhata  and
YHA  C                             frmasl = ' 61'  and
YHA  C                             toaisl = ' 61'  and
YHA  C                             prfail <> ' 61'  or
     *     User selected to skip this replenishment.
     C                             bypass = *on  and
     C                             prseq# = savseq  or
417eA*
417eA*     Not a normal case replenishment.
500uA*         and we are not just checking to see if a repl exists.
500uDC**                           prrplt <> ' '
500uMC                             prrplt <> ' ' and chknew = *off
     C                   iter
     *
     C                   other
710aA*
710aA*     See if another replen for same item should be done first
710aA*
710aAC                   exsr      zzchkfifo
710aAC                   if        outOfFifoOrder
710aAC                   iter
710aAC                   endif
500sA*
500sA*     See if replenishment is for correct side.
500sA*      Note: Only when aisle range is being used.
500sAC                   if        w7fas > *blanks
500sAC     prtloc        div       2             temp3n
500sAC                   mvr                     remainder
500sAC                   if        remainder = 0 and w7side = 'O'
500sAC                             or remainder > 0 and w7side = 'E'
500sAC                   iter
500sAC                   endif
500sAC                   endif
415mA*
415mA*    If just checking for new transactions - set flag and exit.
415mAC                   if        chknew = *on
415mAC                   eval      newtrn = *on
415mAC                   unlock    prplfil1
415mAC                   goto      endnxt
415mAC                   endif
     *
650kA*    If *REPLEN flag OPSKPR = Y and the phys qty > item repl level,
650kA*    and the item repl level is > 0, skip this replenishment.
650kA*
650kAC                   if        opskpr = 'Y'
650kAC                   exsr      zzGetPickslQ
650kAC     itkey1        chain     piritem
650kAC                   if        %found(piritem)
650kAC                             and itrepl > 0
650kAC                             and pckSltPhyQ > itrepl
650kAC                   iter
650kAC                   endif
650kAC                   endif
650kA*
     *    Tag replenishment record as in process.
     *
530 AC                   eval      savseq = prseq#
     C                   eval      prflag = 'A'
     C                   update    prrec
     C                   eval      done = *off
     C                   leave
     *
     C                   endsl
     C                   enddo
415mMC     endnxt        endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZNEXTALL   User selected *ALL departments.
650bA*              Find next replenishment, always looking for JIT's first,
650bA*              by department.  For example, if there are 3 JIT's in CLR,
650bA*              1 JIT in DRY, 2 normal repl's in CLR, and 1 normal repl in
650bA*              FRZ, they will process in the following order:
650bA*              - 3 JIT's in CLR
650bA*              - 1 JIT in DRY
650bA*              - 2 normal repl's in CLR
650bA*              - 1 normal repl in FRZ
650bA*              Keep in mind that if any new JIT's are added while doing
650bA*              the normal repl's, the JIT's will take precedence and be
650bA*              displayed.
650bA*
650bAC     zznextAll     begsr
650bA*
     *    Position to beginning to get any JIT's first.
     C     keypr10       setll     prplfil10
     *
     C                   dow       forevr = forevr
     C     keypr10       reade     prplfil10                            7879
     *
     C                   if        %eof
     C                   eval      done = *on
650eAC                   exsr      zzfil7
650eAC                   eval      allDepts = *on
     C                   leave
     C                   endif
     *
     *    Check to see if this repl was bypassed, if so, go get next record.
     *    Note: allow length of 6 for prseq# to include the sign.
     *
     C                   eval      hldseqAlpha = %char(prseq#)
     C                   movel     prwhdp        hldwhdpseq
     C                   move      hldseqAlpha   hldwhdpseq
     C     hldwhdpseq    lookup    whdp_seq                               81
     C                   if        %equal
     C                   iter
     C                   endif
     *
     *    If the last repl processed was JIT and the one just read is not,
     *    it means you've finished all JIT's for the last dept, so we need
     *    to go back and start over at the beginning of JIT's.
     *
     C                   if        savprty > 0
     C                             and prprty = 0
     C                   eval      savwhdp = *blanks
     C                   eval      savprty = -9
     C     keypr10       setll     prplfil10
     C                   iter
     C                   endif
     *
     *    If this is a normal repl you don't have to worry about dept, because
     *    the logical is sorted by dept within priority, and all normal repl's
     *    have the same priority value, 0.  So they will naturally process by
     *    department order.
     *
     C                   if        prprty = 0
     C                   goto      nextchk
     C                   endif
     *
     *    If this is not the first pass after selecting *ALL depts and the
     *    dept just read is not the same as the last one, and the last one
     *    was a JIT, go look for another one of the same dept.
     *
     C                   if        nextAllFirst = '1'
     C                   eval      nextAllFirst = '0'
     C                   else
     C                   if        prwhdp <> savwhdp and
     C                             savprty > 0
     C                   iter
     C                   endif
     C                   endif
     *
     C     nextchk       tag
     *
     C                   select
     *
     C                   when      *in78  or
     C                             prflag <> 'S'  or
YHA  *     YHata - Aisle 61 only process if from and to aisle = 61
YHA  C                             client = yhata  and
YHA  C                             frmasl = ' 61'  and
YHA  C                             toaisl = ' 61'  and
YHA  C                             prfail <> ' 61'  or
     *     Not a normal case replenishment.
     *         and we are not just checking to see if a repl exists.
     C                             prrplt <> ' ' and chknew = *off
     C                   iter
     *
     C                   other
     *
     *    If just checking for new transactions - set flag and exit.
     C                   if        chknew = *on
     C                   eval      newtrn = *on
     C                   unlock    prplfil10
     C                   goto      endnxtAll
     C                   endif
     *
650kA*    If *REPLEN flag OPSKPR = Y and the phys qty > item repl level,
650kA*    and the item repl level is > 0, skip this replenishment.
650kA*
650kAC                   if        opskpr = 'Y'
650kAC                   exsr      zzGetPickslQ
650kAC     itkey1        chain     piritem
650kAC                   if        %found(piritem)
650kAC                             and itrepl > 0
650kAC                             and pckSltPhyQ > itrepl
650kAC                   iter
650kAC                   endif
650kAC                   endif
710aA*
710aA*     See if another replen for same item should be done first
710aA*
710aAC                   exsr      zzchkfifo
710aAC                   if        outOfFifoOrder
710aAC                   iter
710aAC                   endif
     *
     *    Tag replenishment record as in process.
     *
     C                   eval      savseq = prseq#
     C                   eval      prflag = 'A'
     C                   update    prrec10
     C                   eval      done = *off
     C                   eval      savwhdp = prwhdp
     C                   eval      savprty = prprty
     C                   leave
     *
     C                   endsl
     C                   enddo
     C     endnxtAll     endsr
600cA*
600cA*----------------------------------------------------------------
600cA*
600cA*  ZZOUT    User flagged item as having no overflow product to
600cA*           replenish into pick slot.
600cA*
600cAC     zzout         begsr
600cD*
600gA*    Logic for SLOTOUT file moved to RU380.
600gD*          KEYSO     CHAINSLOTOUT              79
600gD*          *IN79     IFEQ *OFF
600gD*                    DELETSOREC
600gD*                    ENDIF
600cA*
600cA*
600cA*    Change status of all Open Flag Runner entries to
600cA*    R=Replenished.
600cAC                   eval      $lcmd = '*CHG2RPL'
600cAC                   eval      $lwhse = lbwhse
600cAC                   eval      $lwhdp = lbwhdp
600cAC                   eval      $ldsp1 = lbdsp2
600gD*                    MOVE 'R'       $LNWST
600gAC                   eval      $litm3 = lbitem
600cA*
600cAC                   call      'RU380'
600cAC                   parm                    $lparm
600cA*
600cAC     endout        endsr
600cA*
     *----------------------------------------------------------------
     *
     *  ZZPAWY   Put extra quantity away.
     *
     C     zzpawy        begsr
500pAC                   eval      error = *off
500pA
500pA*  Update license history and slots.
500pA
500pA*    Two different methods are used depending on whether the
500pA*    quantity is going back into the original #FROM slot or not.
500pA
500pAC                   if        #ovrfslwhse = #fromslwhse  and
500pAC                             #ovrfslwhdp = #fromslwhdp  and
500wMC                             #ovrfbasesldsp = #frombasesldsp and
600wAC                             w8balq <= 0
500wDC**                           #pickittype <> 'B'
600wMC                   exsr      zzpawy2
600wDC**                 exsr      zzpawy3
500pAC                   else
500pAC                   exsr      zzpawy3
     C                   endif
700cAC     $treturn      cabeq     '*CANCEL'     endpaw
500pAC     error         cabeq     *on           endpaw
     *
     *   Update the LABEL record with slot.
     *
     C                   if        newlb = *off
     C     lblbl#        chain     label                              79
     C                   if        not *in79
     C                   z-add     w8nqty        lbqpck
     C                   eval      lbqrmn = *zeros
     C                   z-add     w8nqty        lbqalc
     *    Calculate cube and weight for put away qty.
     C     lbucub        mult      w8nqty        lbcube
     C     lbuwgt        mult      w8nqty        lbswgt
     *    Move slot info to label record.
500dMC                   eval      lbasl2 = #ovrfslaisl
500dMC                   eval      lbloc2 = #ovrfslloc
500dMC                   eval      lblvl2 = #ovrfslrlvl
500dMC                   eval      lbhnd2 = #ovrfslhand
500dMC                   eval      lbstyp = #ovrfslstyp
500dMC                   eval      lbdsp2 = #ovrfsldisp
500dMC                   if        #ovrfslstyp = 'P'
     C                   eval      lbqryf = 1
     C                   else
     C                   eval      lbqryf = 0
     C                   endif
500qAC                   exsr      zzgetdatetime
500qAC                   eval      lbstat = 'C'
500qAC                   eval      lbsdte = curdate
500qAC                   eval      lbstim = curtime
     *
     C                   update    lbrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endpaw
     C                   endif
     *
     *    Update quantity in transaction record.
500dAC                   exsr      zztrnupdate
     *
417jA*    Turn off flag since label has been used.
417jAC                   eval      crtrcd = *off
417jA*
     C                   eval      newlb = *on
     C                   endif
     *
     *    Create new label/transaction records.
     *
     C                   else
     *
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     *
     C                   call      'PIRTRN#'
     C                   parm                    pttrn#
415vAC                   eval      svtrn# = pttrn#
     *
     C                   eval      lbpo = *blanks
     C                   eval      lbord = *zeros
     C                   eval      lbgrp1 = 'L'
     C                   eval      lbgrp2 = *blanks
     C                   eval      lbtype = 'R'
     C                   eval      lbpal# = *zeros
     C                   eval      lbtrn# = pttrn#
414iA*    Get todays date.
414iAC                   eval      $cvcmd = '*CURCMD '
414iAC                   exsr      zzcvdt
414iAC                   eval      today = $cvd8o
     C                   eval      lbrdte = today
500qDC**                 eval      lbstat = sbstat
500qMC                   eval      lbstat = 'C'
     *
     C                   z-add     w8nqty        lbqpck
     C                   eval      lbqrmn = *zeros
     C                   z-add     w8nqty        lbqalc
     *    Calculate cube and weight for put away qty.
500dMC     #fromitcube   mult      w8nqty        lbcube
500dMC     #fromitswgt   mult      w8nqty        lbswgt
     *    Move slot info to label record.
500dMC                   eval      lbasl2 = #ovrfslaisl
500dMC                   eval      lbloc2 = #ovrfslloc
500dMC                   eval      lblvl2 = #ovrfslrlvl
500dMC                   eval      lbhnd2 = #ovrfslhand
500dMC                   eval      lbstyp = #ovrfslstyp
500dMC                   eval      lbdsp2 = #ovrfsldisp
     C                   if        slstyp = 'P'
     C                   eval      lbqryf = 1
     C                   else
     C                   eval      lbqryf = 0
     C                   endif
     *
     C                   write     lbrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endpaw
     C                   endif
     *
500qAC                   eval      svrplb = lblbl#
500dAC                   exsr      zztrncrtstart
     *
     C                   endif
     *
414eA*    Close the put away transaction.
416gAC                   eval      svtask = pttask
500dMC                   eval      curtrn# = pttrn#
500dMC                   exsr      zztrnclose
     *
     C                   select
     C                   when      error = *off
414eAC                   eval      lstslt = w8scan
415bA*
415bA*    Change slot status.
415bA*
415bAC                   if        wozero = 'Y'
415bAC                   exsr      zzzero
415bAC                   endif
     *
     C                   select
     *
     *    Entire qty has been sucessfully put away.
     C                   when      w8balq <= *zeros
600uA
600uA*      Delete workusr record.
600uA
600uAC                   exsr      zzwrkdel
PFCaAc*
PFCaAc*    Call APT Interface.
PFCaAc                   if        logapt
PFCaAc*    Send Replenishment "End" record.
750cDc**                 eval      apcmd = aptsk4
750cDc**                 eval      aplbl# = LBLBL#
750cDc**                 eval      aptrn# = PTTRN#
750cDc**                 eval      aploc = W8SCAN
750cDc**                 EXSR      ZZAPT
750cAc                   eval      apseq# += 1
750cAc                   exsr      clr$apt
tst  c****               eval      $apuser = 'ZZPAWY'
750cAC                   eval      $aplbl#  = lblbl#
750cAC                   eval      $aptrn#  = pttrn#
750cAC                   eval      $aplocation = w8scan
750cAC                   eval      $dricommand = '*APT'
750cAC                   eval      $drisubcmd  = aptsk_END
750cAC                   eval      $drisys2upd = 'D'
750cAC                   eval      chk4err = *off
750cAC                   eval      zmsflag = *off
750cAC                   exsr      zzzdricop
PFCaAc                   ENDIF
     *
     *      When user is in specific slot replenishment mode,
     *      take them back.  Otherwise, find next letdown or
     *      priority replenishment.
     *
     C                   select
     C                   when      rpltyp = '*SPECIFC'
414fA*
414fA*      Start an 'IDLE' task, if no open task.
414fAC                   eval      curtrn = 0
414fAC                   eval      curtsk = *blanks
414fAC                   eval      curtyp = *blanks
414fAC                   eval      curent = *off
414fAC                   exsr      zztask
414fAC                   if        curent = *off
414fAC                   eval      w1task = 'IDLE  '
500dMC                   exsr      zztrnidle
414fAC                   endif
600qA*
600qAC                   select
600qA*      Interleaving replenishment complete. Return to Putaway pgm.
600qAC                   when      $scmd = '*INTERLV'
600qAC                   eval      nxtscr = 'EOJ'
600qAC                   eval      $srtn = '*RPLDONE'
600qA*
600qAC                   other
     C                   exsr      scr01i
500qAC                   endsl
     *
     C                   other
     *
600qAC                   select
600qA*      Interleaving replenishment complete. Return to Putaway pgm.
600qAC                   when      $scmd = '*INTERLV'
600qAC                   eval      nxtscr = 'EOJ'
600qAC                   eval      $srtn = '*RPLDONE'
600qA*
600qA*      Start an 'IDLE' task, if no open task.
600qAC                   eval      curtrn = 0
600qAC                   eval      curtsk = *blanks
600qAC                   eval      curtyp = *blanks
600qAC                   eval      curent = *off
600qAC                   exsr      zztask
600qAC                   if        curent = *off
600qAC                   eval      w1task = 'IDLE  '
600qAC                   exsr      zztrnidle
600qAC                   endif
600qA*
600qAC                   other
650bAC                   eval      prptyp = '*IMMED  '
650bAC                   eval      bypass = *off
     C                   exsr      zzupd1
500qAC                   endsl
500qA*
     C                   endsl
     *
     *    Qty remaining to be put away.
     C                   when      w8balq > *zeros
PFCaA
PFCaA*    Send APT Replenishment "Place" record.
PFCaAc**                 if        logapt
PFCaAc**                 eval      apcmd = aptsk2
PFCaAc*                  eval      aplbl# = LBLBL#
PFCaAc*                  eval      aptrn# = PTTRN#
PFCaAc*                  eval      aploc = W8SCAN
PFCaAc*                  EXSR      ZZAPT
PFCaAc*                  ENDIF
416sA*
416sA*      Capture date/time user closed transaction. This will be used
416sA*      for starting next transaction. This will more accurately
416sA*      reflect when the process started.
416sAC                   eval      $cvcmd = '*CURCMD '
416sAC                   exsr      zzcvdt
416sAC                   eval      trndte = $cvd8o
416sAC                   time                    trntim
     *
     C                   eval      w8scan = *blanks
     C                   eval      w8nqty = *zeros
415cAC                   z-add     w8balq        svqpck
600uA
600uA*      Update workusr record.
600uA
600uAC                   exsr      zzwrkupd8
     *
     C                   endsl
     *
     *    Errors occured during close - re-display screen with error.
     *
     C                   when      error = *on
     C     w8balq        add       w8nqty        w8balq
     C                   eval      w8scan = *blanks
     C                   exsr      scr08i
     C                   endsl
     *
     *
     C     endpaw        endsr
500pA
500pA*----------------------------------------------------------------
500pA*  ZZPAWY2   Putting full/partial quantity into #from slot.
500pA*----------------------------------------------------------------
500pA
500pAC     zzpawy2       begsr
500wA
500wA*  Note: We don't do a PUTAWYB because we are putting the qty back
500wA*        where it came from and are assuming that it is physically
500wA*        being put back where it came from (i.e. same pallet pos).
500wA*        Therefore, we do not want to ask the user any questions.
500wA
500wDC**
500wDC** Put balance into transit, if any.
500wDC**
500wDC**                 if        w8balq > 0
500wDC**                 exsr      zzzclr$lt210
500wDC**                 eval      $tcmd  = '*PULTRAN'
500wDC**                 eval      $tlic# = curlic#
500wDC**                 eval      $tnewlic# = curlic#
500wDC**                 eval      $twhse  = #fromslwhse
500wDC**                 eval      $titem  = #fromslitem
500wDC**                 eval      $titemdsc = #fromithead
500wDC**                 eval      $tpartial = *on
500wDC**                 eval      $tqty1 = w8balq
500wDC**                 eval      $tqty2 = 0
500wDC**                 eval      $tqty3 = 0
500wDC**                 eval      $tnorm1 = w8balq
500wDC**                 eval      $tnorm2 = 0
500wDC**                 eval      $tnorm3 = 0
500wDC**                 exsr      zzzcall$lt210
500wDC**
500wDC**                 select
500wDC**                 when      $treturn = '*CANCEL'
500wDC**                 goto      endpaw2
500wDC**                 when      $treturn <> '*OK'
500wDC**                 eval      error = *on
500wDC**                 eval      *in21 = *on
500wDC**                 eval      *in01 = *on
500wDC**                 goto      endpaw2
500wDC**                 endsl
500wDC**
500wDC**                 eval      curlic# = $tlic#
500wDC**
500wDC**                 endif
500wDC**
500wDC**Tell user to put back #FROM slot pallets.
500wDC**
500wDC**                 exsr      zzzclr$lt210
500wDC**                 eval      $tcmd  = '*PULRTN'
500wDC**                 eval      $twhse  = #fromslwhse
500wDC**                 eval      $twhdp  = #fromslwhdp
500wDC**                 eval      $tslot  = #fromsldisp
500wDC**                 eval      $titem  = #fromslitem
500wDC**                 eval      $titemdsc = #fromithead
500wDC**                 exsr      zzzcall$lt210
500wDC**                 if        $treturn <> '*OK'
500wDC**                 endif

     *  Use DRI interface to update #FROM slot.

     *  We just send a negative qty back because all we want to do
     *  is remove the qty from the Tfr bucket.

     C                   exsr      clr$slot
     C                   eval      $slwhseu  = *on
     C                   eval      $slwhse   = #fromslwhse
     C                   eval      $slwhdpu  = *on
     C                   eval      $slwhdp   = #fromslwhdp
     C                   eval      $sldispu  = *on
601dMC                   eval      $sldisp   = #frombasesldsp
601dDC**                 eval      $sldisp   = #fromsldisp
     C                   eval      $saitemu  = *on
     C                   eval      $saitem   = #fromslitem
600uAC                   eval      $sacwhdu = *on
600uAC                   eval      $sacwhd  = wuUsrWhdp
600uAC                   eval      $sacdspu = *on
600uAC                   eval      $sacdsp  = wuUsrDisp
     C                   eval      $sacitemu = *on
     C                   eval      $sacitem  = #fromslitem
     C                   eval      $saqtyu   = *on
600uDC**                 eval      $saqty1   = -(w8nqty)
600uMC                   eval      $saqty1   = w8nqty
     C                   eval      $saqty2   = 0
     C                   eval      $saqty2   = 0
     C                   eval      $saorgu   = *off
     C                   eval      $saorg1   = 0
     C                   eval      $saorg2   = 0
     C                   eval      $saorg2   = 0
600uA
600uAC                   eval      $saActionU = *on
600uAC                   eval      $saAction = 'RPL'
600uAC                   eval      $saTrn#U = *on
600uAC                   eval      $saTrn# = lbtrn#
600uAC                   eval      $saETrn#U = *on
600uAC                   eval      $saETrn# = 0
600uAC                   eval      $saLbl#U = *on
600uAC                   eval      $saLbl# = lblbl#
600uAC                   eval      $saToLcnsU = *on
600wDC**                 eval      $saToLcns = wuUsrLcns
600wMC                   eval      $saToLcns = wuPulLcns
600uAC                   eval      $saToPosU = *on
600wDC**                 eval      $saToPos = $tslotpos
600wMC                   eval      $saToPos = wuPulpos
600uAC                   eval      $saToVrfyU = *on
600uAC                   eval      $saToVrfy = 'N'
600uAC                   eval      $saToCodeu = *on
600uAC                   eval      $saToCode = 'S'
600uAC                   eval      $saToAreaU = *on
600uAC                   eval      $saToArea = 'Slot'
600uAC                   eval      $saFrmLcnsU = *on
600uAC                   eval      $saFrmLcns = wuUsrLcns
600uAC                   eval      $saOLcnsU = *on
600uAC                   eval      $saOLcns = wuPulOLcns
600wAC                   eval      $sapullwhdpu = *on
600wAC                   eval      $sapullwhdp  = wuPulWhdp
600vAC                   eval      $sapulldispu = *on
600vAC                   eval      $sapulldisp  = wuPulDisp
600vAC                   eval      $sapullbaseu = *on
600vAC                   eval      $sapullbase  = wuPulBase
600vAC                   eval      $sapulllcnsu = *on
600vAC                   eval      $sapulllcns  = wuPulLcns

600wAC                   eval      $saexcdU = *on
600wAC                   eval      $saexcd  = 'RTNORIG'
610bAC                   eval      $satasku = *on
610bAC                   eval      $satask  = pttask

720hAc                   if        $tpartial = *on
720hAc                   eval      $saUCIts = $tpartime
720hAc                   eval      $saUCItsU = *on
720hAc                   endif

     C                   eval      $dricommand = '*SLOT'
600uDC**                 eval      $drisubcmd  = '%TFROUTCHG'
600uMC                   eval      $drisubcmd  = '%USR2PUT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     *  Update #OVRF info for writting to label file later.

     C                   eval      #ovrfslhand = $slhand
     C                   eval      #ovrfsldisp = $sldisp
500wA
500wA*  Call license tracking for putaway - After update.
500wA
500wA*  Note: Since we didn't call PUTAWYB, we need to fill in a few
500wA*        extra parameters.
500wA
500wAC                   eval      $tcmd  = '*PUTAWYA'
500wAC                   eval      $tnexttask= 'PUTAWAY'
500wAC                   eval      $tlic#  = curlic#
500wAC                   eval      $tinlic#  = curlic#
500wAC                   eval      $toutlic# = curlic#
600wDC**                 if        w8balq > 0
600wDC**                 eval      $tpartial = *on
600wDC**                 else
500wAC                   eval      $tpartial = *off
600wDC**                 endif
500wAC                   eval      $twhse  = #ovrfslwhse
500wAC                   eval      $twhdp  = #ovrfslwhdp
500wAC                   eval      $tslot  = #ovrfsldisp
500wAC                   eval      $titem  = #fromslitem
500wAC                   eval      $titemdsc = #fromithead
500wAC                   eval      $tqty1 = w8nqty
500wAC                   eval      $tqty2 = 0
500wAC                   eval      $tqty3 = 0
500xAC                   eval      $tnorm1 = w8nqty
500xAC                   eval      $tnorm2 = 0
500xAC                   eval      $tnorm3 = 0
500wAC                   exsr      zzzcall$lt210
500wA
500wAC                   if        $treturn <> '*OK'
500wAC                   endif
500wA
500wA*  If everything putaway, ensure all #From pallets have been put up.
500wA
500wAC                   if        w8balq <= 0
500wAC                   exsr      zzzclr$lt210
500yDC**                 eval      $tcmd  = '*PULRTN'
500yMC                   eval      $tcmd  = '*RMVZRTN'
500wAC                   eval      $twhse  = #fromslwhse
500wAC                   eval      $twhdp  = #fromslwhdp
601dDC**                 eval      $tslot  = #fromsldisp
601MAC                   eval      $tslot  = #frombasesldsp
500wAC                   eval      $titem  = #fromslitem
500wAC                   eval      $titemdsc = #fromithead
600yAC                   eval      $tlic#  = curlic#
500wAC                   exsr      zzzcall$lt210
500wAC                   if        $treturn <> '*OK'
500wAC                   endif
500wAC                   endif

     C     endpaw2       endsr
500pA
500pA*----------------------------------------------------------------
500pA*  ZZPAWY3   Putting full/partial quantity into non-#from slot.
500pA*----------------------------------------------------------------
500pA
500pAC     zzpawy3       begsr

     *  Initialize interface data structure.

     C                   exsr      clr$slot

     *  Call license tracking for putaway - Before update

     C                   exsr      zzzclr$lt210
     C                   eval      $tcmd  = '*PUTAWYB'
     C                   eval      $tlic#  = curlic#
     C                   if        w8balq > 0
     C                   eval      $tpartial = *on
     C                   else
     C                   eval      $tpartial = *off
     C                   endif
     C                   eval      $twhse  = #ovrfslwhse
     C                   eval      $twhdp  = #ovrfslwhdp
601dDC**                 eval      $tslot  = #ovrfsldisp
601dMC                   eval      $tslot  = #ovrfbasesldsp
     C                   eval      $titem  = #fromslitem
     C                   eval      $titemdsc = #fromithead
     C                   eval      $tqty1 = w8nqty
     C                   eval      $tqty2 = 0
     C                   eval      $tqty3 = 0
500xAC                   eval      $tnorm1 = w8nqty
500xAC                   eval      $tnorm2 = 0
500xAC                   eval      $tnorm3 = 0
     C                   exsr      zzzcall$lt210

     C                   select
     C                   when      $treturn = '*CANCEL'
700cAC     w8balq        add       w8nqty        w8balq
     C                   eval      redspl = *on
     C                   goto      endpaw3
     C                   when      $treturn <> '*OK'
     C                   eval      error = *on
600wAC                   eval      errmsg = 'LT210: ' + $terrmsg
600wAC                   exsr      zm0105
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   goto      endpaw3
     C                   endsl

     *  Use DRI interface to update To slot.

     C                   exsr      clr$slot
     C                   eval      $slwhseu  = *on
     C                   eval      $slwhse   = #ovrfslwhse
     C                   eval      $slwhdpu  = *on
     C                   eval      $slwhdp   = #ovrfslwhdp
     C                   eval      $sldispu  = *on
601dMC                   eval      $sldisp   = #ovrfbasesldsp
601dDC**                 eval      $sldisp   = #ovrfsldisp
     C                   eval      $slentdu  = *on
     C                   eval      $slentd   = #fromslentd
     C                   eval      $slexpdu  = *on
     C                   eval      $slexpd   = #fromslexpd
     C                   eval      $saitemu  = *on
     C                   eval      $saitem   = #fromslitem
600uAC                   eval      $sacwhdu = *on
600uAC                   eval      $sacwhd  = wuUsrWhdp
600uAC                   eval      $sacdspu = *on
600uAC                   eval      $sacdsp  = wuUsrDisp
     C                   eval      $sacitemu = *on
     C                   eval      $sacitem  = #fromslitem
     C                   eval      $saqtyu   = *on
     C                   eval      $saqty1   = w8nqty
     C                   eval      $saqty2   = 0
     C                   eval      $saqty3   = 0
     C                   eval      $saToPosu = *on
     C                   eval      $saToPos  = $tslotpos
600uA
600uAC                   eval      $saActionU = *on
600uAC                   eval      $saAction = 'RPL'
600uAC                   eval      $saTrn#U = *on
600uAC                   eval      $saTrn# = lbtrn#
600uAC                   eval      $saETrn#U = *on
600uAC                   eval      $saETrn# = 0
600uAC                   eval      $saLbl#U = *on
600uAC                   eval      $saLbl# = lblbl#
600uAC                   eval      $saToLcnsU = *on
600uAC                   eval      $saToLcns = $tinlic#
600uAC                   eval      $saToPosU = *on
600uAC                   eval      $saToPos = $tslotpos
600uAC                   eval      $saToVrfyU = *on
600uAC                   eval      $saToVrfy = 'N'
600uAC                   eval      $saToCodeu = *on
600uAC                   eval      $saToCode = 'S'
600uAC                   eval      $saToAreaU = *on
600uAC                   eval      $saToArea = 'Slot'
600uAC                   eval      $saFrmLcnsU = *on
600uAC                   eval      $saFrmLcns = $toutlic#
600uAC                   eval      $saOLcnsU = *on
600uAC                   eval      $saOLcns = wuPulOLcns
600wAC                   eval      $sapullwhdpu = *on
600wAC                   eval      $sapullwhdp  = wuPulWhdp
600vAC                   eval      $sapulldispu = *on
600vAC                   eval      $sapulldisp  = wuPulDisp
600vAC                   eval      $sapullbaseu = *on
600vAC                   eval      $sapullbase  = wuPulBase
600vAC                   eval      $sapulllcnsu = *on
600vAC                   eval      $sapulllcns  = wuPulLcns
610bAC                   eval      $satasku = *on
610bAC                   eval      $satask  = pttask

     C                   eval      $dricommand = '*SLOT'
600uDC**                 eval      $drisubcmd  = '%CLSTFRIN'
600uMC                   eval      $drisubcmd  = '%USR2PUT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        drierr
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   goto      endpaw3
     C                   endif

     *  Update #TO slot info in case item was put into a virtual slot.

     C                   eval      #ovrfslhand = $slhand
     C                   eval      #ovrfsldisp = $sldisp
600uD **
600uD ** Use DRI interface to update From slot.
600uD **
600uDC**                 exsr      clr$slot
600uDC**                 eval      $slwhseu  = *on
600uDC**                 eval      $slwhse   = #fromslwhse
600uDC**                 eval      $slwhdpu  = *on
600uDC**                 eval      $slwhdp   = #fromslwhdp
600uDC**                 eval      $sldispu  = *on
600uDC**                 eval      $sldisp   = #fromsldisp
600uDC**                 eval      $saitemu  = *on
600uDC**                 eval      $saitem   = #fromslitem
600uDC**                 eval      $sacitemu = *on
600uDC**                 eval      $sacitem  = #pickslitem
600uDC**                 eval      $saqtyu   = *on
600uDC**                 eval      $saqty1   = w8nqty
600uDC**                 eval      $saqty2   = 0
600uDC**                 eval      $saqty2   = 0
600uDC**                 eval      $saorgu   = *on
600uDC**                 eval      $saorg1   = w8nqty
600uDC**                 eval      $saorg2   = 0
600uDC**                 eval      $saorg2   = 0
600uD **
600uDC**                 eval      $dricommand = '*SLOT'
600uDC**                 eval      $drisubcmd  = '%CLSTFOCHG'
600uD **
600uDC**                 eval      $drisys2upd = 'D'
600uDC**                 eval      chk4err = *off
600uDC**                 eval      zmsflag = *off
600uDC**                 exsr      zzzdricop

     *  Call license tracking for putaway - After update.
     *  Note, some parms remembered from Before processing.

     C                   eval      $tcmd  = '*PUTAWYA'
     C                   eval      $tlic#  = curlic#
     C                   if        w8balq > 0
     C                   eval      $tpartial = *on
     C                   else
     C                   eval      $tpartial = *off
     C                   endif
     C                   eval      $twhse  = #ovrfslwhse
     C                   eval      $twhdp  = #ovrfslwhdp
     C                   eval      $tslot  = #ovrfsldisp
     C                   eval      $titem  = #fromslitem
     C                   eval      $titemdsc = #fromithead
     C                   eval      $tqty1 = w8nqty
     C                   eval      $tqty2 = 0
     C                   eval      $tqty3 = 0
500xAC                   eval      $tnorm1 = w8nqty
500xAC                   eval      $tnorm2 = 0
500xAC                   eval      $tnorm3 = 0
     C                   exsr      zzzcall$lt210

     C                   if        $treturn <> '*OK'
     C                   endif
500vA
500vA*  If everything putaway, ensure all #From pallets have been put up.
500vA
500vAC                   if        w8balq <= 0
500vAC                   exsr      zzzclr$lt210
500yDC**                 eval      $tcmd  = '*PULRTN'
500yMC                   eval      $tcmd  = '*RMVZRTN'
500vAC                   eval      $twhse  = #fromslwhse
500vAC                   eval      $twhdp  = #fromslwhdp
601dDC**                 eval      $tslot  = #fromsldisp
601dMC                   eval      $tslot  = #frombasesldsp
500vAC                   eval      $titem  = #fromslitem
500vAC                   eval      $titemdsc = #fromithead
600yAC                   eval      $tlic#  = curlic#
500vAC                   exsr      zzzcall$lt210
500vAC                   if        $treturn <> '*OK'
500vAC                   endif
500vAC                   endif

     C     endpaw3       endsr

     *----------------------------------------------------------------
     *
     *  ZZRMTF   Remove transfer label/transaction records.
     *
     C     zzrmtf        begsr
     *
     C                   eval      crtrcd = *off
     C                   eval      @pcmd = '*ABORT  '
     *
     C     svrplb        chain     label                              79
     C                   if        not *in79
     C     lbtrn#        chain(n)  pirtran                            78
     C                   if        *in79
     C                   eval      pttask = *blanks
     C                   eval      pttrn# = *zeros
     C                   endif
     *
     C                   call      @adjtr
     C                   parm                    @pcmd
     C                   parm                    #job
     C                   parm      lbtrn#        @ptrn#
     C                   parm      pttask        @ptask
     C                   parm      w1whse        @pwhse
     C                   parm      lbwhdp        @pwhdp
     C                   parm      lbstyp        @pstyp
     C                   parm      lbcube        @pcube
     C                   parm      lbswgt        @pswgt
     C                   parm      lbqpck        @ppcs
     C                   parm      0             @paisl
     C                   parm      0             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      '0'           @prte
     C                   parm      ' '           @ppo
     C                   parm      'L'           @pgrp1
     C                   parm      ' '           @pgrp2
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     *    Delete label record.
     *
     C                   delete    lbrec
     *
     *    Remove link in coresponding tran# of original rcd.
     C     svlbl#        chain     label                              79
     C                   if        not *in79
     C                   eval      lbctr# = *zeros
     C                   update    lbrec                                78
     C                   endif
     *
     C                   endif
     *
     C                   endsr
415lA*
415lA*----------------------------------------------------------------
415lA*
415lA*  ZZRTNO   Retrieve putaway option - Manual or Directed
415lA*
415lAC     zzrtno        begsr
415lA*
415lAC     opdkey        chain     optiond                            79
415lAC                   if        *in79
415lAC                   eval      opmput = 'N'
415lA*
415lAC                   endif
415lA*
415lAC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZRVRS   Reverse the quantities.
     *
     C     zzrvrs        begsr
     C                   eval      error = *off
600uDC**                 goto      endrvs
600uDC**
600uDC**   Update task detail record.
600uDC**
600uDC**                 select
600uDC**                 when      pttask = 'REPLBK'
600uDC**   Update pick quantity in label record.
600uDC**   lbkey         chain     label                              79
600uDC**                 eval      lbqalc = svqalc
600uDC**                 eval      lbqrmn = svqrmn
600uDC**                 eval      lbqpck = svqpck
600uDC**   lbucub        mult      lbqpck        lbcube
600uDC**   lbuwgt        mult      lbqpck        lbswgt
600uDC**                 update    lbrec
600uDC**   Update quantity in transaction record.
600uDC**   ptkey         chain     pirtran                            79
600uDC**                 eval      ptpcs = svqpck
600uDC**   lbucub        mult      ptpcs         ptcube
600uDC**   lbuwgt        mult      ptpcs         ptswgt
600uDC**                 update    ptrec
600uDC**                 endsl
     *
     *    Update transfer quantity in slot record.(From slot)
416fA*
416fAC                   exsr      clr$slot
416fA*
416fAC                   eval      $slwhseu = *on
500iMC                   eval      $slwhse  = #fromslwhse
416fAC                   eval      $slwhdpu = *on
500iMC                   eval      $slwhdp  = #fromslwhdp
416fAC                   eval      $sldispu = *on
601dMC                   eval      $sldisp  = #frombasesldsp
601dDC**                 eval      $sldisp  = #fromsldisp
416fAC                   eval      $saitemu = *on
500iMC                   eval      $saitem  = #fromslitem
600uAC                   eval      $sacwhdu = *on
600uAC                   eval      $sacwhd  = wuUsrWhdp
600uAC                   eval      $sacdspu = *on
600uAC                   eval      $sacdsp  = wuUsrDisp
600uAC                   eval      $sacitemu = *on
600uAC                   eval      $sacitem  = #fromslitem
416fAC                   eval      $satrn#u = *on
416fAC                   eval      $satrn#  = lbtrn#
416fAC                   eval      $satasku = *on
416fAC                   eval      $satask  = pttask
416fAC                   eval      $saqtyu = *on
520cDC**                 eval      $saqty1 = $saqty1 - w3pulq
600uDC**                 eval      $saqty1 = $saqty1 - rvpulq
600uDC**                 eval      $saqty1 = $saqty1 + svqpck
600uMC                   eval      $saqty1 = wuRemQty1
416fAC                   eval      $saqty2 = 0
416fAC                   eval      $saqty3 = 0
600uA
600uAC                   eval      $saActionU = *on
600uAC                   eval      $saAction = 'RPL'
600uAC                   eval      $saTrn#U = *on
600uAC                   eval      $saTrn# = lbtrn#
600uAC                   eval      $saETrn#U = *on
600uAC                   eval      $saETrn# = 0
600uAC                   eval      $saLbl#U = *on
600uAC                   eval      $saLbl# = lblbl#
600uAC                   eval      $saToLcnsU = *on
600uAC                   eval      $saToLcns = wuPulLcns
600uAC                   eval      $saToPosU = *on
600uAC                   eval      $saToPos = $tslotpos
600uAC                   eval      $saToVrfyU = *on
600uAC                   eval      $saToVrfy = 'N'
600uAC                   eval      $saToCodeu = *on
600uAC                   eval      $saToCode = 'S'
600uAC                   eval      $saToAreaU = *on
600uAC                   eval      $saToArea = 'Slot'
600uAC                   eval      $saFrmLcnsU = *on
600uAC                   eval      $saFrmLcns = wuUsrLcns
600uAC                   eval      $saOLcnsU = *on
600uAC                   eval      $saOLcns = wuPulOLcns
600wAC                   eval      $sapullwhdpu = *on
600wAC                   eval      $sapullwhdp  = wuPulWhdp
600vAC                   eval      $sapulldispu = *on
600vAC                   eval      $sapulldisp  = wuPulDisp
600vAC                   eval      $sapullbaseu = *on
600vAC                   eval      $sapullbase  = wuPulBase
600vAC                   eval      $sapulllcnsu = *on
600vAC                   eval      $sapulllcns  = wuPulLcns

720hAc                   if        $tpartial = *on
720hAc                   eval      $saUCIts = $tpartime
720hAc                   eval      $saUCItsU = *on
720hAc                   endif
600uA
600vAC                   eval      $saexcdU = *on
600vAC                   eval      $saexcd  = 'CANCEL'
600uA
416fAC                   eval      $dricommand = '*SLOT'
600uDC**                 eval      $drisubcmd = '%TFROUT'
600uMC                   eval      $drisubcmd = '%USR2PUT'
416fAC                   eval      chk4err = *off
416fAC                   eval      zmsflag = *off
416fAC                   exsr      zzzdricop
     *
416fA*
600uDC**                 exsr      clr$slot
600uD **
600uDC**                 eval      $slwhseu = *on
500iDC**                 eval      $slwhse  = lbwhse
600uDC**                 eval      $slwhse  = #pickslwhse
600uDC**                 eval      $slwhdpu = *on
500iDC**                 eval      $slwhdp  = lbwhdp
600uDC**                 eval      $slwhdp  = #pickslwhdp
600uDC**                 eval      $sldispu = *on
500iDC**                 eval      $sldisp  = lbdsp2
600uDC**                 eval      $sldisp  = #picksldisp
600uDC**                 eval      $slentdu  = *on
600uDC**                 eval      $slentd   = #pickslentd
600uDC**                 eval      $slexpdu  = *on
600uDC**                 eval      $slexpd   = #pickslexpd
600uDC**                 eval      $saitemu = *on
500iDC**                 eval      $saitem  = slitem
600uDC**                 eval      $saitem  = #pickslitem
600uDC**                 eval      $satrn#u = *on
600uDC**                 eval      $satrn#  = lbtrn#
600uDC**                 eval      $satasku = *on
600uDC**                 eval      $satask  = pttask
600uDC**                 eval      $saqtyu = *on
520cDC**                 eval      $saqty1 = $saqty1 - w3repq
600uDC**                 eval      $saqty1 = $saqty1 - rvrepq
600uDC**                 eval      $saqty1 = $saqty1 + svqrmn
600uDC**                 eval      $saqty2 = 0
600uDC**                 eval      $saqty3 = 0
600uDC**                 eval      $dricommand = '*SLOT'
600uDC**                 eval      $drisubcmd = '%TFRIN'
600uDC**                 eval      chk4err = *off
600uDC**                 eval      zmsflag = *off
600uDC**                 exsr      zzzdricop
600uA
600uA*    Delete workusr record.
600uA
600uAC                   exsr      zzwrkdel
600uA
600uA*    Get new From slot, which may have changed when qty was put back.
600uA
600uAC                   eval      getWhse = $slwhse
600uAC                   eval      getWhdp = $slwhdp
600uAC                   eval      getDisp = $sldisp
600uAC                   exsr      zzgetfromsl
416fA*
     C     endrvs        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZSPFC   Call to display specific slot replenishments.
     *
     C     zzspfc        begsr
     C                   eval      error = *off
     C                   eval      done = *off
     *
     *    Display list of slots item occupies.
     *
600uMC                   eval      $iWhse = #pickslwhse
600uMC                   eval      $iItem = #pickslitem
600uAC                   eval      $iWhdp = #pickslwhdp
600uMC                   eval      $iHome = #picksldisp
600uDC**                 eval      $lbl# = *zeros
600uDC**                 eval      $trn# = *zeros
600uDC**                 eval      $bat# = *zeros
600uMC                   eval      $iPrg = #prog
     *
     C                   call      'IT276'
600bAC                   parm                    $iPrg            10
600bAC                   parm                    $iWhse            3 0
600bAC                   parm                    $iWhdp            5
600bAC                   parm                    $iHome           12
600bAC                   parm                    $iItem           15
600bAC                   parm                    $slot
600bAC                   parm                    $slot2
600bAC                   parm                    $iReturn          8
720aAC                   parm      ladisp        $ilcnsdisp       12
600bD **
600bDC**                 parm                    $prtky
600bDC**                 parm      *blanks       $lrtn
600bDC**                 parm      *blanks       $lzero
720bA*
720bA*    Request to generate Priority Replenishment
720bA*
720bAC                   if        $iReturn = 'STRNOSTK'
720bAc                   exsr      zzPriReplen
720bAc                   endif
     *
     *    Replenishment was created - proceed to update repenishment.
     *
600uMC                   if        $iReturn = '*OK     '
600uAC                   eval      it276Flag = *on
600iAC                   if        errtyp = '*LIST   '
600iAC                   exsr      zzspfd
600iAC                   endif
600uA
600uA*    Get workusr record created in it276.
600uA
600uAC                   eval      kywhse = $iWhse
600uAC                   eval      kywhdp = $slwhdp
600uAC                   eval      kydisp = $sldisp
600uAC     keywu3        chain(n)  workusr3
600uAC                   if        not %found(workusr3)
640hAC                   eval      wuusrlcns = ' '
600uAC                   goto      #spfc1
600uAC                   endif
600uA
600uA*    Get transaction record created in it276
600uA
     C                   eval      wkrtpo = *blanks
600uDC**                 eval      kytrn# = $trn#
600uMC                   eval      kytrn# = wuTrn#
     C     ptky3a        setll     pirtran3
     C     #spfc1        tag
     C     ptkey3        reade     pirtran3                               77
     *    - EOF
     C                   if        *in77
     C                   eval      done = *on
     C                   goto      #spfc2
     C                   endif
415iA*
415iA*    - Wrong transaction number.
600uDC**                 if        pttrn# <> $trn#
600uMC                   if        pttrn# <> wuTrn#
415iAC                   goto      #spfc1
415iAC                   endif
     *
     *    - Transaction inuse.
     C                   if        ptstat <> '2'
     C                   goto      #spfc1
     C                   endif
     *
     *    - Different department.
     *
500dMC                   if        ptwhdp <> #pickslwhdp
     C                   goto      #spfc1
     C                   endif
     *
     *    Found Specific Slot replenishment rcd - Process it.
     C                   eval      svtrn# = pttrn#
     *
     *    - Get replenishment record. Replen. has only one label record
     *      per transaction number.
     *
     C     lbkey7        setll     label7
     C     lbkey7        reade     label7                                 79
     *    - EOF
     C                   if        *in79
     C                   eval      done = *on
     C                   goto      #spfc2
     C                   endif
     *    - Wrong To slot.
600uDC**                 if        lbdisp <> $disp  and
600uDC**                           $disp > *blanks
600uMC                   if        lbdisp <> wuPulDisp  and
600uMC                             wuPulDisp > *blanks
     C                   goto      #spfc1
     C                   endif
     *
415vAC                   eval      rpltyp = '*SPECIFC'
     C                   eval      topick = lbqpck
500nDC**                 if        pttask = 'REPLBK'
500nDC**                 eval      rplqty = lbqrmn
500nDC**                 else
     C                   eval      rplqty = topick
500nDC**                 endif
     *
     *    Save this info to use it when a transaction is aborted.
     *
     C                   eval      usrrpl = *on
600uDC**                 eval      curlic# = $pllp#
600uDC**                 eval      savllp = $pllp#
600uMC                   eval      curlic# = wuUsrLcns
600uMC                   eval      savllp = wuUsrLcns
     C                   eval      svlbl# = lblbl#
     C                   eval      svqalc = lbqalc
     C                   eval      svqpck = lbqpck
     C                   eval      svcube = lbcube
     C                   eval      svswgt = lbswgt
     C                   eval      svqrmn = lbqrmn
     *
     *    Fill Screen 2 fields for display.
     *
500tAC                   eval      sc2first = *on
     C                   exsr      scr02i
415tA*
415tA*    Verify no errors with slot selected for replenishment.
415tA*
640aAC                   if        pttask <> 'REPLBK'
415tAC                   exsr      zzchk2
640aAC                   endif
     *
500nDC**  Process Screen 2 as if user pressed Enter since user
500nDC**  is processing a single pallet slot.
500nDC**  Only when replenishment isn't for breakdown item.
500nDC**  Or when tracking slot pos and slot has multiple positions.
500nA
500nA*    Now we are always skipping screen 2.
500nA
500nDC**                 if        #fromslpos <= 1  and
500nDC**                           error = *off  and
500nDC**                           pttask <> 'REPLBK'
500nDC**                           or
500nDC**                           #fromslpos > 1  and
500nDC**                           trackpos = 'Y' and
500nDC**                           error = *off  and
500nDC**                           pttask <> 'REPLBK'
500rAC                   if        pttask <> 'REPLBK'
     C                   exsr      zzupd2
500rAC                   endif
610aA
610aA*    Delete workusr record for breakdown replenishment.
610aA*    Yes, this seems weird, but breakdown repl go to sc2 to get
610aA*    the pull qty, but sc2 assumes there is no current workusr
610aA*    record. We need to create it in IT276 because it passes back
610aA*    information used above. Deleting it here allows SC2 to work
610aA*    without any changes.
610aA
610aAC                   if        pttask = 'REPLBK'
610aAC                   exsr      zzwrkdel
610aAC                   endif
     *
     *    Specific slot replenishment canceled.
     *
     C                   else
     *
     C     #spfc2        tag
600i C                   if        errtyp = '*LIST   '
600j *    Close idle transaction.
600nA*    Get current task.
600nAC                   eval      curtrn = *zeros
600nAC                   eval      curtsk = *blanks
600nAC                   eval      curtyp = *blanks
600nAC                   eval      curent = *off
600nAC                   exsr      zztask
600nA*    Now end current task.
600nAC*                  if        curent = *on
600i C*                  exsr      zzetsk
600nAC*                  endif
600j *    Start original transaction.
600jAC     hldtrn        chain(n)  pirtran                            79
600mAC                   if        not *in79  and
600mAC                             ptstat = '1'
600jMC                   eval      svtrn# = hldtrn
600jA*
600jAC                   eval      @ptask = pttask
600jAC                   eval      @pcube = lbcube
600jAC                   eval      @pswgt = lbswgt
600j c                   exsr      zztrnstart
600jAC                   eval      topick = lbqpck
600jA*
600i C                   goto      endspf
600mA*
600mA*    Original transaction no longer available. Find next available
600mA*    replenishment.
600mAC                   else
600mAC                   eval      refrsh = *on
600mAC                   eval      w1tdis = *blanks
720aAC                   eval      w1lcns = *blanks
720aAC                   eval      w1scan = *blanks
     *
600fAC                   eval      prptyp = '*IMMED  '
600mAC                   eval      usrrpl = *off
600mAC                   eval      bypass = *off
600mAC                   eval      wkrtpo = '0'
600mAC                   exsr      zzupd1
600mAC                   goto      endspf
600mAC                   endif
600i C                   endif
     C                   eval      usrrpl = *off
     C                   eval      bypass = *off
     C                   eval      wkrtpo = '0'
     *
     *    Return user to specific slot screen.
     *
     C                   exsr      scr01i
     *
     C                   endif
600uAC     endspf        tag
650nAC                   if        pttask <> 'REPLBK'
600uAC                   eval      it276Flag = *off
650nAC                   endif
600uMC                   endsr
600i *----------------------------------------------------------------
600i *
600i *  ZZSPFD   Close rec after specific slot replenishment was done.
600i *
600i C     zzspfd        begsr
600i *
600i *    Update transfer quantity in slot record.(From slot)
600i *
600iA*
640nAc                   if        it276flag = *off
600idC*                  exsr      zzzisf
600iMc                   exsr      clr$slot
600iDC*                  exsr      zzzfs3
600iAC                   eval      $slwhse = lbwhse
600iAC                   eval      $slwhdp = lbwhdp
600iAC                   eval      $sldisp = lbdisp
416fAC                   eval      $dricommand = '*SLOT'
600iAC                   eval      $drisubcmd = '%GET'
600iAC                   eval      $drireturn = *blanks
600iAC                   eval      chk4err = *on
416fAC                   eval      zmsflag = *off
600iDC*                  exsr      zzzcop
600iMC                   exsr      zzzdricop
600iDC*                  exsr      zzzd2s
600iAC                   eval      *in79 = drierr
600iA*
600iAC                   if        not *in79
600iAC                   eval      fmexpd = slexpd
600iAC                   eval      fmentd = slentd
600iAC                   else
600iAC                   eval      fmexpd = *zeros
600iAC                   eval      fmentd = *zeros
600iAC                   endif
640nAc                   endif
600i *
600i *    Write exception to file.
600iAC                   select
600iA*    User skipped slot that had no problem, just can't get
600iA*    to product for some reason.
600iAC                   when      errtyp = '*LIST   '
600iAC                   eval      exerid = 'LIST   '
600iA*
600iA*    User logged exception from Balance Putaway screen.
600iAC                   when      balexc = *on
600iAC                   eval      exerid = 'QTYEXC '
600iA*
600iAC                   other
600i C                   eval      exerid = 'WRGITM '
600iAC                   endsl
600i C                   if        rpltyp = '*PRIORTY'  or
600i C                             rpltyp = '*SPECIFC'
600i C                   eval      pttask = 'REPL  '
600iAC                   endif
600iA*
600iA*    User logged exception from Balance Putaway screen.
600iAC                   if        balexc = *on
650cA*
650cAC                   if        w8balq > 999
650cAC                   eval      exqty = 999
650cAC                   else
650cA*
600iAC                   z-add     w8balq        exqty
650cAC                   endif
650cA*
600iAC                   else
650cA*
650cAC                   if        lbqpck > 999
650cAC                   eval      exqty = 999
650cAC                   else
650cA*
600i C                   z-add     lbqpck        exqty
650cAC                   endif
650cA*
600iAC                   endif
600i C                   exsr      zzexcp
600i *
600i C                   select
600i *    Abort specific/priority replenishments.
600i C                   when      rpltyp = '*PRIORTY'  or
600i C                             rpltyp = '*SPECIFC'
600iA*
600iA*    CLOSE DONE PREVIOUSLY IF *SSR RETUNED
600iA*
600iA*R                   EXSR ZZCLS0
600iA*R                   EXSR ZZCLSE
600i *
600i *    Close letdowns as if they were completed.
600i C                   other
600iA*
600iA*    Exception occured. Close letdown to zero.
600iA*
600jAC                   if        errtyp = '*LIST   '
600jAC                   eval      $cvcmd = '*CURCMD '
600jAC                   exsr      zzcvdt
600jAC                   eval      redate = $cvd8o
600j C                   time                    retime
600jAC                   endif
600iAC                   exsr      zzcls0
600iDC*                  exsr      zzclse
600iAC                   eval      curtrn# = pttrn#
600iAC                   exsr      zztrnclose
600jAC                   eval      redate = 0
600jAC                   eval      retime = 0
600i C                   endsl
600i *
600i *
600i C                   select
600i C                   when      error = *off
600i C                   eval      excptn = *off
600i *
600i *
600i *    Remove priority replenishment record.
600i C                   if        rpltyp = '*PRIORTY'
600i C     keypr2        chain     prplfil1                           7978
600i C                   if        not *in79
600iAC                   eval      prflag = 'D'
600iMC                   update    prrec                                78
600i C                   endif
600i C                   endif
600iA*
600iA*    Removed unneeded replenishment transfer record.
600iAC                   if        crtrcd = *on
600iAC                   exsr      zzrmtf
600iAC                   endif
600i *
600?A*                    MOVE *OFF      RESTRT
600iAC                   eval      balexc = *off
600i C                   eval      refrsh = *on
600i ***                  MOVE *BLANKS   W1TDIS
600i ***                  MOVE *OFF      USRRPL
600i *
600iAC                   endsl
600i C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZSTRT   Start a new transaction
     *
     C     zzstrt        begsr
600qA*
600qA*    Start at Letdown transaction passed to pgm.
600qAC                   if        $scmd = '*INTERLV'  and
600qAC                             $strn# > 0
600qAC     ptky3a        setll     pirtran3
600qAC                   goto      next
600qAC                   endif
600qA*
     C     #top          tag
CBIdAC                   eval      restr3 = *off
     C                   eval      done = *off
     *    Get next Let-Down record.
CBIdAC     ptkey3        setll     label12                                77
     C     ptkey3        setll     pirtran3                               77
     *    -Match not found
     C                   if        not *in77
     C                   eval      done = *on
     C                   goto      endstr
     C                   endif
     *    -Bypass letdown - Get next let down available.
     C                   if        bypass = *on
CBIdAC                   if        letord = 'SLOT'  and
CBIdAC                             rpltyp <> '*PRIORTY'  and
CBIdAC                             rpltyp <> '*SPECIFC'
CBIdAC                   eval      wkwhdp = svwhdp
CBIdAC                   eval      wkdsp2 = svdsp2
CBIdAC                   eval      kytrn# = savtrn
CBIdAC     lbky12        setgt     label12
CBIdAC                   else
     C                   eval      wkrtpo = svrtpo
     C                   eval      kytrn# = savtrn
     C     ptky3a        setgt     pirtran3
     C                   eval      wkrtpo = '0'
CBIdAC                   endif
     C                   endif
417hA*
417hA*    - Restart at last letdown that was interupted.
417hAC                   if        restrt = *on  and
417hAC                             restr2 = *on
CBIdAC                   eval      restr3 = *on
417hAC                   eval      wkrtpo = hlrtpo
417hAC                   eval      kytrn# = hldtrn
417hAC     ptky3a        setll     pirtran3
417hAC                   eval      wkrtpo = '0'
417hAC                   eval      restrt = *off
417hAC                   eval      restr2 = *off
417hAC                   endif
417hA*
     *    -Match found - Read the records until we find the Let-Down.
     C     next          tag
CBIdA*
CBIdAC                   if        letord = 'SLOT'  and
CBIdAC                             restr3 = *off  and
CBIdAC                             rpltyp <> '*PRIORTY'  and
CBIdAC                             rpltyp <> '*SPECIFC'
CBIdA*
CBIdAC     ptkey3        reade     label12                                77
CBIdAC                   if        not *in77
CBIdAC                   eval      wkrtpo = lbrte
CBIdAC                   eval      kytrn# = lbtrn#
CBIdAC     ptky3a        setll     pirtran3
CBIdAC     ptkey3        reade     pirtran3                               77
CBIfA*
CBIfA*     If matching tran record not found, get next label record.
CBIfAC                   if        *in77
CBIfAC                   goto      next
CBIfAC                   endif
CBIdA*
CBIdAC                   endif
CBIdA*
CBIdAC                   else
CBIdA*
     C     ptkey3        reade     pirtran3                               77
CBIdA*
CBIdAC                   endif
     *    - EOF
     C                   if        *in77
     *
     *    If end of file is reached and a let down was bypassed,
     *    reset back to top of file looking for another or same transaction.
     C                   if        bypass = *on  and
     C                             rpltyp = '*LETDOWN'
     C                   eval      bypass = *off
415uAC                   eval      skippd = *on
     C                   endif
     *
     C                   eval      done = *on
     C                   goto      endstr
     C                   endif
     *    User selected to skip this transaction.
     C                   if        bypass = *on  and
     C                             pttrn# = savtrn
     C                   goto      next
     C                   endif
     *
     *    - Found a record
     C                   if        pttask <> 'REPL    '  and
     C                             pttask <> 'REPLBK  '  or
     C                             ptrtpo = *blanks
     C                   goto      next
     C                   endif
     *    - Transaction inuse.
     C                   if        ptstat >= '2'
     C                   goto      next
     C                   endif
     *    - Different department.
     C                   if        ptwhdp <> w1whdp
     C                   goto      next
     C                   endif
     *    Found a let-down record. Process it.
414fMC                   eval      svtran = pttrn#
     *
     *    - Get label record. LetDowns has only one label record
     *      per transaction number.
     *
     C     lbkey7        setll     label7
     C     lbkey7        reade     label7                                 79
415uA*
415uA*    - Wrong transaction number.
415uAC                   if        lbtrn# <> pttrn#  or
415uAC                             *in79
415uAC                   goto      next
415uAC                   endif
     *    - Wrong To slot.
     C                   if        lbdsp2 <> w1tdis  and
     C                             w1tdis > *blanks
     C                   goto      next
     C                   endif
     *    - Aisle outside range to process.
417iA*      Note: Only apply aisle range when processing
417iA*      Letdowns and Priority Replenishments.
     C                   if        w7fas > *blanks  and
417iAC                             spfcrp = '*NO '
     C                   if        lbasl2 < frmasl  or
     C                             lbasl2 > toaisl
     C                   goto      next
     C                   endif
     C                   endif
500sA*    - Wrong side
500sA*      Note: Only apply aisle range when processing
500sA*      Letdowns and Priority Replenishments.
500sAC                   if        w7fas > *blanks  and
500sAC                             spfcrp = '*NO '
500sAC     lbloc2        div       2             temp3n
500sAC                   mvr                     remainder
500sAC                   if        remainder = 0 and w7side = 'O'
500sAC                             or remainder > 0 and w7side = 'E'
500sAC                   goto      next
500sAC                   endif
500sAC                   endif
415mA*
415mA*    If just checking for new transactions - set flag and exit.
415mAC                   if        chknew = *on
415mAC                   eval      newtrn = *on
415mAC                   goto      endstr
415mAC                   endif
     *
CBIdA*    Save label information for Bypass.
CBIdAC                   eval      svwhdp = lbwhdp
CBIdAC                   eval      svdsp2 = lbdsp2
     *
414fA*    Get current task.
416hAC                   eval      curtrn = *zeros
416hAC                   eval      curtsk = *blanks
416hAC                   eval      curtyp = *blanks
416hAC                   eval      curent = *off
414fA*    Now retrieve next task record again.
414fAC     svtran        chain(n)  pirtran                            79
414fMC                   eval      svtrn# = svtran

500dAC                   exsr      zztrnstart

     C                   eval      topick = lbqpck
500nDC**                 if        pttask = 'REPLBK'
500nDC**                 eval      rplqty = lbqrmn
500nDC**                 else
     C                   eval      rplqty = topick
500nDC**                 endif
     *
     *    Save this info to use it when a transaction is aborted.
     *
     C                   eval      svlbl# = lblbl#
     C                   eval      svqalc = lbqalc
     C                   eval      svqpck = lbqpck
     C                   eval      svcube = lbcube
     C                   eval      svswgt = lbswgt
     C                   eval      svqrmn = lbqrmn
     C     endstr        endsr
     *----------------------------------------------------------------
     *
     *  ZZSTR2   Start a new transaction - (Created automatically)
     *
     C     zzstr2        begsr
     C                   eval      done = *off
     *    Get next Let-Down record.
     C     ptky3a        setll     pirtran3                               77
     *    -Match not found
     C                   if        not *in77
     C                   eval      done = *on
     C                   goto      endst2
     C                   endif
     *    -Match found - Read the records until we find the Let-Down.
     C     ptky3a        reade     pirtran3                               77
     *    - EOF
     C                   if        *in77
     C                   eval      done = *on
     C                   goto      endst2
     C                   endif
     *    - Transaction inuse.
     C                   if        ptstat >= '2'
     C                   eval      done = *on
     C                   goto      endst2
     C                   endif
     *
     *    Found created let-down record.  Process it.
     *
414fMC                   eval      svtran = pttrn#
     *
     *    - Get label record. LetDowns has only one label record
     *      per transaction number.
     *
     C     lbkey7        setll     label7
     C     lbkey7        reade     label7                                 79
415uA*
415uA*    - Wrong transaction number.
415uAC                   if        lbtrn# <> pttrn#  or
415uAC                             *in79
415uAC                   eval      done = *on
415uAC                   goto      endst2
415uAC                   endif
     *
414fA*    Get current task.
416hAC                   eval      curtrn = *zeros
416hAC                   eval      curtsk = *blanks
416hAC                   eval      curtyp = *blanks
416hAC                   eval      curent = *off
414fA*    Now retrieve next task record again.
414fAC     svtran        chain(n)  pirtran                            79
414fMC                   eval      svtrn# = svtran

500dAC                   exsr      zztrnstart

     C                   eval      topick = lbqpck
500nDC**                 if        pttask = 'REPLBK'
500nDC**                 eval      rplqty = lbqrmn
500nDC**                 else
     C                   eval      rplqty = topick
500nDC**                 endif
     C                   eval      svlbl# = lblbl#
     C                   eval      svqalc = lbqalc
     C                   eval      svqpck = lbqpck
     C                   eval      svcube = lbcube
     C                   eval      svswgt = lbswgt
     C                   eval      svqrmn = lbqrmn
     C     endst2        endsr
     *----------------------------------------------------------------
     *
     *  ZZTASK  Get current task.
     *
     C     zztask        begsr
     C                   eval      stdate = *hival
     C                   eval      sttime = *hival
     *
     C                   eval      kystat = '2'
     C     ptkey1        setll     pirtran1
     C     ptkey1        reade     pirtran1                               79
     C                   if        *in79
     C                   eval      found = *off
     C                   goto      endtsk
     C                   endif
     *
     C     ptke22        setll     pirtran2
     C                   dow       forevr = forevr
     C                   read      pirtran2                               79
     C                   if        *in79  or
     C                             ptemp# <> #emp#
     C                   eval      found = *off
     C                   leave
     C                   endif
     C                   if        ptstat <> '2'
     C                   iter
     C                   endif
     *    Found an active transaction
     C                   eval      curent = *on
     C                   eval      curtrn = pttrn#
     C                   eval      t#task = pttask
     C     tkkey         chain     task                               79
     C                   if        not *in79
     C                   eval      curtsk = tkcode
     C                   eval      curtyp = tktype
     C                   endif
     C                   leave
     C                   enddo
     C     endtsk        endsr

500dA*----------------------------------------------------------------
500dA*  ZZTRNABORT  Abort/Undo a transaction.
500dA*----------------------------------------------------------------
500dA
500dAC     zztrnabort    begsr

     *    If this replenishment was created by this program then,
     *    remove transaction completely. Otherwise just reset
     *    transaction

     C                   if        usrrpl = *on
     C                   eval      @pcmd = '*ABORT'
     C                   else
     C                   eval      @pcmd = '*UNDO'
     C                   endif

     C                   call      'ADJTRAN2'
     C                   parm                    @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      pttrn#        @ptrn#            7 0
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
     C                   parm      #user         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr

500dA*----------------------------------------------------------------
500dA*  ZZTRNCLOSE  Close a transaction
500dA*----------------------------------------------------------------
500dA
500dAC     zztrnclose    begsr

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
     C                   parm      #user         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr

500dA*----------------------------------------------------------------
500dA*  ZZTRNCRTSTART  Create and Start transaction
500dA*----------------------------------------------------------------
500dA
500dAC     zztrncrtstart begsr

     C                   call      'ADJTRAN2'
     C                   parm      '*CRTSTRT'    @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      pttrn#        @ptrn#            7 0
     C                   parm      'REPLTF'      @ptask            6
     C                   parm      lbwhse        @pwhse            3 0
     C                   parm      lbwhdp        @pwhdp            5
     C                   parm      lbstyp        @pstyp            1
     C                   parm      lbcube        @pcube            9 3
     C                   parm      lbswgt        @pswgt            9 2
     C                   parm      lbqpck        @ppcs             5 0
     C                   parm      1             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      'L'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      trndte        @pdate            8 0
     C                   parm      trntim        @ptime            6 0
     C                   parm      #user         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   eval      curtrn# = @ptrn#
     C                   endsr

500dA*----------------------------------------------------------------
500dA*  ZZTRNIDLE   Start and IDLE transaction.
500dA*----------------------------------------------------------------
500dA
500dAC     zztrnidle     begsr

600jAC                   if        flgf10 = *on
600jAC                   eval      ovrdte = orgdte
600jAC                   eval      ovrtim = orgtim
600jAc                   else
600jAc                   eval      ovrdte = 0
600jAc                   eval      ovrtim = 0
600jAc                   endif
     C                   call      'ADJTRAN2'
     C                   parm      '*CRTSTRT'    @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      0             @ptrn#            7 0
     C                   parm      'IDLE'        @ptask            6
     C                   parm      #fromslwhse   @pwhse            3 0
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
600jDC*                  parm      0             @pdate            8 0
600jDC*                  parm      0             @ptime            6 0
600jMC                   parm      ovrdte        @pdate            8 0
600jMC                   parm      ovrtim        @ptime            6 0
     C                   parm      #user         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr

500dA*----------------------------------------------------------------
500dA*  ZZTRNSTART  Start a transaction
500dA*----------------------------------------------------------------
500dA
500dAC     zztrnstart    begsr

     C                   call      'ADJTRAN2'
     C                   parm      '*START'      @pcmd            10
     C                   parm      #pgm          @pprg            10
600jDC*                  parm      '*BATCH'      @ptype            8
600jMC                   parm      '*INTER  '    @ptype
     C                   parm      pttrn#        @ptrn#            7 0
     C                   parm      ' '           @ptask            6
     C                   parm      lbwhse        @pwhse            3 0
     C                   parm      lbwhdp        @pwhdp            5
     C                   parm      lbstyp        @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
600jDC*                  parm      0             @ppcs             5 0
600jMC                   parm      lbqpck        @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
600jdC*                  parm      'T'           @pgrp1            1
600jMC                   parm      'L'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
     C                   parm      #user         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   eval      curtrn# = @ptrn#
     C                   endsr

500dA*----------------------------------------------------------------
500dA*  ZZTRNUPDATE  Update transaction pcs, cube and weight.
500dA*----------------------------------------------------------------
500dA
500dAC     zztrnupdate   begsr

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
     C                   parm      #user         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr

700aA*----------------------------------------------------------------
700aA*  ZZREPLADJ  Adjust the pieces qty in pirtran.
700aA*----------------------------------------------------------------
700aA
700aAC     zzrepladj     begsr

700aAC                   call      'ADJTRAN2'
700aAC                   parm      rpladjcmd     @pcmd            10
700aAC                   parm      #pgm          @pprg            10
700aAC                   parm      '*BATCH'      @ptype            8
700aAC                   parm      pttrn#        @ptrn#            7 0
700aAC                   parm      ' '           @ptask            6
700aAC                   parm      0             @pwhse            3 0
700aAC                   parm      ' '           @pwhdp            5
700aAC                   parm      ' '           @pstyp            1
700aAC                   parm      0             @pcube            9 3
700aAC                   parm      0             @pswgt            9 2
700aAC                   parm      rpldifqty     @ppcs             5 0
700aAC                   parm      0             @paisl            5 0
700aAC                   parm      0             @pqty1            5 0
700aAC                   parm      0             @pqty2            5 0
700aAC                   parm      0             @pqty3            5 0
700aAC                   parm      ' '           @prte             5
700aAC                   parm      ' '           @ppo              9
700aAC                   parm      ' '           @pgrp1            1
700aAC                   parm      ' '           @pgrp2            1
700aAC                   parm      0             @pdate            8 0
700aAC                   parm      0             @ptime            6 0
700aAC                   parm      #user         @puser           10
700aAC                   parm      ' '           @prtn             8
700aAC                   parm      ' '           @pmsg             4
700aA
700aAC                   endsr

500dA*----------------------------------------------------------------
500dA*  ZZTRNZERO  Zero transaction pcs, cube and weight.
500dA*----------------------------------------------------------------
500dA
500dAC     zztrnzero     begsr

600jAC                   if        redate <> 0
600jAC                   eval      ovrdte = orgdte
600jAC                   eval      ovrtim = orgtim
600jAC                   else
600jAC                   eval      ovrdte = 0
600jAC                   eval      ovrtim = 0
600jAC                   endif
     C                   call      'ADJTRAN2'
     C                   parm      '*DECTTL'     @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      pttrn#        @ptrn#            7 0
     C                   parm      ' '           @ptask            6
     C                   parm      0             @pwhse            3 0
     C                   parm      ' '           @pwhdp            5
     C                   parm      ' '           @pstyp            1
     C                   parm      ptcube        @pcube            9 3
     C                   parm      ptswgt        @pswgt            9 2
     C                   parm      ptpcs         @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      ' '           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
600jDC*                  parm      0             @pdate            8 0
600jDC*                  parm      0             @ptime            6 0
600jMC                   parm      ovrdte        @pdate            8 0
600jMC                   parm      ovrtim        @ptime            6 0
     C                   parm      #user         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr

CBIbA*
CBIbA*----------------------------------------------------------------
CBIbA*
CBIbA*  ZZTPRP   Total Remaining Priority Replenishments
CBIbA*
CBIbAC     zztprp        begsr
CBIbA*
CBIbAC                   eval      w2tprp = *zeros
CBIbAC     keypr5        setll     prplfil5
CBIbA*
CBIbAC                   dow       forevr = forevr
CBIbAC     keypr5        reade     prplfil5                               74
CBIbAC                   select
CBIbAC                   when      *in74
CBIbAC                   leave
CBIbA*
CBIbAC                   when      w7fas > *blanks  and
CBIbAC                             prtai5 >= frmasl  and
CBIbAC                             prtai5 <= toaisl  or
CBIbA*
CBIbAC                             w7fas = *blanks
CBIbA*
CBIbAC                   add       1             w2tprp
CBIbAC                   endsl
CBIbAC                   enddo
CBIbA*
CBIbAC     endtrp        endsr
CBIbA*
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     C                   eval      excptn = *off
     C                   eval      refrsh = *on
     C                   eval      done = *off
     C                   eval      crtrcd = *off
417gAC                   eval      *in61 = *off
PFCaA
PFCaAc*    Clear APT Counter every time new task started.
PFCaAc                   if        logapt
PFCaAc                   eval      apseq# = 0
PFCaAc                   endif
     *
     *    Start new transaction.
     *
     C     #upd1         tag
414kAC                   select
414kAC                   when      rpltyp = '*PRIORTY'  and
600fDC*                            bypass = *on  or
600fMC                             bypass = *on  and
600fAC                             prptyp <> '*IMMED  '  or
417hA*
417hA*    Return to interupted Priority Replenishment. Do
417hA*    this one time even if open Letdowns exist.
417hAC                             restrt = *on  and
417hAC                             restr2 = *on  and
600fDC*                            lsttyp = '*PRIORTY'
600fMC                             lsttyp = '*PRIORTY' and
600fAC                             prptyp <> '*IMMED  '
417hA*
414kAC                   eval      done = *on
414kA*
414kAC                   other
600fA*
600fA*    Look for open Immediate Priority Replenishments needed
600fA*    to fill open Flag Runner entries.
600fAC                   select
600fAC                   when      prptyp = '*IMMED  '
600fA*
600fAC                   eval      usrrpl = *off
650bAC                   if        allDepts = *on and
650bAC                             wkrplt = ' '
650bAC                   exsr      zznextAll
650bAC                   else
600fAC                   exsr      zznext
650bAC                   endif
600fAC                   if        done = *off
600fAC                   exsr      zzcrpr
600fA*
600fA*    Immediate Priority Replenishments created, get out.
610lDC*    usrrpl        cabeq     *on           endup1
610lMC     usrrpl        cabeq     *on           jit1
510gA*    Immediate Priority Replenishment not created, check for more.
510gAC     usrrpl        cabeq     *off          #upd1
510gA*
510gAC                   else
510gA*    End of Immediate Priority Replenishments. Switch to normal.
510gAC                   eval      prptyp = '*NORMAL '
640bAC**                 eval      nxtscr = '11 '
640kMC***                exsr      scr6ai
640kMC***                goto      endup1
600fAC                   endif
600fA*    Otherwise, continue on, looking for open Letdowns.
600fA*
600fAC                   endsl
600fA*
     C                   exsr      zzstrt
600oA*    Do NOT Check for Bulk Drops if starting Specific replen.
510bAC                   if        opbdrp = 'Y'
600oAC                   if        nxtscr <> '01 '
600oAC                   eval      $lcmd = *blanks
600oAC                   eval      $lprg = #prog
600oAC                   eval      $lwhse = kydwhs
600oAC                   eval      $lwhdp = kydwdp
600oAC                   eval      $lbsts = '1 '
600oAC                   call      'OR688'
600oAC                   parm                    $lparm
600oAC                   if        $lrtn = '*OK     '
600oAC                   call      'OR686'
600oAC                   parm                    $lparm
600oAC                   endif
600oAC                   endif
510bAC                   endif
600o *
414kAC                   endsl
600fAC     #upd12        tag
     *
     C                   select
     *
     *    Slot entered and no letdowns found - Create letdown.
     *
     C                   when      done = *on  and
     C                             w1tdis > *blanks
     C                   eval      rpltyp = '*SPECIFC'
     C                   exsr      zzspfc
     *
     *    No slot entered and no letdowns found - Check for priority
     *    replenishments to process.
     *
     C                   when      done = *on  and
     C                             w1tdis = *blanks
600fAC                   eval      prptyp = '*NORMAL '
650bAC                   if        allDepts = *on and
650bAC                             wkrplt = ' '
650bAC                   exsr      zznextAll
650bAC                   else
     C                   exsr      zznext
650bAC                   endif
     *
     C                   select
     *
     *    Priority replenishment transaction created.
     *
     C                   when      done = *off
     C                   eval      $pcmd = '*DELETE '
     C                   eval      $puky = dsfkey
     C                   eval      $pfeat = opfeat
417eAC                   eval      $prplt = ' '
417eAC                   eval      $pcrtt = 'Y'
417eAC                   eval      $pbat# = *zeros
510fAC                   eval      $ptrn# = *zeros
417eAC                   eval      $plbl# = *zeros
500dMC                   call      'LT108'
     C                   parm                    $parms
600xAC                   parm                    $slot
600xAC                   parm                    $slot2
     C                   if        $prtn = '*NONE   '
414kAC     keypr2        chain     prplfil1                           7978
414kAC                   if        not *in79
414kAC                   eval      prflag = 'D'
414kAC                   update    prrec                                78
414kAC                   endif
     C                   goto      #upd1
     C                   endif
     *
600wAC                   eval      lt108Flag = *on
     C                   eval      rpltyp = '*PRIORTY'
417gAC                   eval      *in61 = *on
     C                   eval      usrrpl = *on
414kAC                   eval      bypass = *off
     C                   eval      kytrn# = $ptrn#
CBIeAC                   if        letord = 'SLOT'
CBIeAC                   eval      wkrtpo = '0'
CBIeAC                   endif
     C                   exsr      zzstr2
     *
500tAC                   eval      sc2first = *on
     C                   exsr      scr02i
     *
600wAC                   eval      lt108Flag = *off
610lAC     jit1          tag
500bA*
500bA*    Call program that will (if necessary) ...
500bA*      - Prompt user to pull pallet.
500bA*      - Have user verify license being pulled.
500bA*      - Update license information.
500bA*
500bAC                   exsr      zzzclr$lt210
500bAC                   eval      $tcmd   = '*PULDROP'
500bAC                   eval      $twhse  = #fromslwhse
500bAC                   eval      $twhdp  = #fromslwhdp
500bAC                   eval      $tslot  = #fromsldisp
500bAC                   eval      $titem  = #fromslitem
500cAC                   eval      $titemdsc = #fromithead
600uAC                   eval      $tlic# = #fromsaToLcns
610fAC                   eval      $ttoslot = #picksldisp
500bAC                   exsr      zzzcall$lt210

700fAC                   If        #fromsldisp <> $tslot and
700fAC                             $tslot <> *blanks
700fAC                   Eval      #fromsldisp = $tslot
700fAC                   Eval      w2fmsl = #fromsldisp
700fAC                   Exsr      zzChgRpl
700fAC                   EndIf
500bAC                   eval      curlic# = $tlic#
500hA
500hA*      See how it went ...
500hA
500bAC                   select
500hA
500hA*        ... User canceled.
500hA
500bAC                   when      $treturn = '*CANCEL'
500hAC                   eval      refrsh = *off
500hAC                   if        done = *off
500hAC                   if        usrrpl = *on
500hAC                   exsr      zzcls0
500hAC                   eval      curtrn# = pttrn#
500hAC                   exsr      zztrnclose
500hA
500hA*           - Undo pulling of license plate.
500hA
500wDC**                 exsr      zzzclr$lt210
500wDC**                 eval      $tcmd   = '*PULUNDO'
500wDC**                 eval      $twhse  = #fromslwhse
500wDC**                 eval      $tlic#  = curlic#
500wDC**                 exsr      zzzcall$lt210
500wA
500wA*    Return quantity that was put into transit.
500wA
500wAC**???              exsr      zzzclr$lt210
500wAC**???              eval      $tcmd     = '*PUTAWYA'
500wAC**???              eval      $tnexttask= 'PUTAWAY'
500wAC**???              eval      $tlic#    = curlic#
500wAC**???              eval      $tinlic#  = curlic#
500wAC**???              eval      $toutlic# = curlic#
500wAC**???              eval      $twhse    = #fromslwhse
500wAC**???              eval      $twhdp    = #fromslwhdp
500wAC**???              eval      $tslot    = #fromsldisp
500wAC**???              eval      $titem    = #fromslitem
500wAC**???              eval      $titemdsc = #fromithead
500wAC**???              eval      $tpartial = *off
500wAC**???              eval      $tqty1    = w1qt01
500wAC**???              eval      $tqty2    = w1qt02
500wAC**???              eval      $tqty3    = w1qt03
500xAC**???              eval      $tnorm1   = w1qt01
500xAC**???              eval      $tnorm2   = w1qt02
500xAC**???              eval      $tnorm3   = w1qt03
500wAC**???              exsr      zzzcall$lt210
500hA
500hAC                   if        error = *off
500hA
500hA*           - Reset priority replenishment so it can be done later.
500hA
500hAC                   select
500hAC                   when      rpltyp = '*PRIORTY'
500hAC     keypr2        chain     prplfil1                           7978
500hAC                   if        not *in79
500hAC                   eval      prflag = 'S'
500hAC                   update    prrec                                78
500hAC                   endif
500hAC                   endsl
500hA
500hA*           - Start an 'IDLE' task, if no open task.
500hA
500hAC                   eval      curtrn = 0
500hAC                   eval      curtsk = *blanks
500hAC                   eval      curtyp = *blanks
500hAC                   eval      curent = *off
500hAC                   exsr      zztask
500hAC                   if        curent = *off
500hAC                   eval      w1task = 'IDLE  '
500hAC                   exsr      zztrnidle
500hAC                   endif
500hAC                   endif
500hAC                   else
500hAC                   exsr      zzabrt
500hAC                   endif
500hA
500hA*           - Unable to abort transaction - re-display screen.
500hA
500hAC                   select
500hAC                   when      error = *on
500hAC                   exsr      scr02i
500hAC                   goto      endup1
500hAC                   endsl
500hAC                   if        crtrcd = *on
500hAC                   exsr      zzrmtf
500hAC                   endif
500hAC                   endif
500hA*
500hAC                   select
500hAC                   when      rpltyp = '*SPECIFC'
500hAC                   exsr      scr01i
500hA*
500hAC                   other
500hAC                   exsr      scr07i
500hAC                   endsl
500hAC                   goto      endup1
500hA
500hA*        ... User pressed F9=Skip
500hA
500hAC                   when      $treturn = '*SKIP'
500hAC                   eval      bypass = *on
500hAC                   eval      refrsh = *off
500hAC                   eval      savtrn = pttrn#
500hAC                   eval      svrtpo = ptrtpo
500hAC                   eval      savseq = prseq#
650bAC                   eval      idx = idx + 1
650bAC                   eval      hldseqAlpha = %char(prseq#)
650bAC                   movel     prwhdp        whdp_seq(idx)
650bAC                   move      hldseqAlpha   whdp_seq(idx)
500hAC                   if        done = *off
500hAC                   if        usrrpl = *on
500hAC                   exsr      zzcls0
500hAC                   eval      curtrn# = pttrn#
500hAC                   exsr      zztrnclose
500hA
500hA*           - Undo pulling of license plate.
500hA
500wDC**                 exsr      zzzclr$lt210
500wDC**                 eval      $tcmd   = '*PULUNDO'
500wDC**                 eval      $twhse  = #fromslwhse
500wDC**                 eval      $tlic#  = curlic#
500wDC**                 exsr      zzzcall$lt210
500wA
500wA*    Return quantity that was put into transit.
500wA
500wAC**???              exsr      zzzclr$lt210
500wAC**???              eval      $tcmd     = '*PUTAWYA'
500wAC**???              eval      $tnexttask= 'PUTAWAY'
500wAC**???              eval      $tlic#    = curlic#
500wAC**???              eval      $tinlic#  = curlic#
500wAC**???              eval      $toutlic# = curlic#
500wAC**???              eval      $twhse    = #fromslwhse
500wAC**???              eval      $twhdp    = #fromslwhdp
500wAC**???              eval      $tslot    = #fromsldisp
500wAC**???              eval      $titem    = #fromslitem
500wAC**???              eval      $titemdsc = #fromithead
500wAC**???              eval      $tpartial = *off
500wAC**???              eval      $tqty1    = w1qt01
500wAC**???              eval      $tqty2    = w1qt02
500wAC**???              eval      $tqty3    = w1qt03
500xAC**???              eval      $tnorm1   = w1qt01
500xAC**???              eval      $tnorm2   = w1qt02
500xAC**???              eval      $tnorm3   = w1qt03
500wAC**???              exsr      zzzcall$lt210
500hA
500hA*           - Reset priority replenishment so it can be done later.
500hA
500hAC                   select
500hAC                   when      rpltyp = '*PRIORTY'  and
500hAC                             error = *off
500hAC     keypr2        chain     prplfil1                           7978
500hAC                   if        not *in79
500hAC                   eval      prflag = 'S'
500hAC                   update    prrec                                78
500hAC                   endif
500hAC                   endsl
500hAC                   else
500hAC                   exsr      zzabrt
500hAC                   endif
500hA
500hA*           - Unable to abort transaction - re-display screen.
500hA
500hAC                   select
500hAC                   when      error = *on
500hAC                   eval      bypass = *off
500hAC                   exsr      scr02i
500hAC                   goto      endup1
500hAC                   endsl
500hAC                   if        crtrcd = *on
500hAC                   exsr      zzrmtf
500hAC                   endif
500hAC                   endif
500hA
500hA*          - User chose to bypass transaction - find next let down.
500hA
500hAC                   eval      refrsh = *on
500hAC                   eval      w1tdis = *blanks
720aAC                   eval      w1lcns = *blanks
720aAC                   eval      w1scan = *blanks
500hAC                   eval      usrrpl = *off
500hAC                   goto      #upd1
500hA
500hA*        ... User pressed F10=Except when item not found on pallet.
500hA
500hAC                   when      $treturn = '*NOTFND'
500hAC                   eval      bypass = *on
500hAC                   eval      refrsh = *off
500hAC                   eval      savtrn = pttrn#
500hAC                   eval      svrtpo = ptrtpo
500hAC                   eval      savseq = prseq#
500hAC                   if        done = *off
500hAC                   if        usrrpl = *on
500hAC                   exsr      zzcls0
500hAC                   eval      curtrn# = pttrn#
500hAC                   exsr      zztrnclose
500hA
500hA*           - Undo pulling of license plate.
500hA
500wDC**                 exsr      zzzclr$lt210
500wDC**                 eval      $tcmd   = '*PULUNDO'
500wDC**                 eval      $twhse  = #fromslwhse
500wDC**                 eval      $tlic#  = curlic#
500wDC**                 exsr      zzzcall$lt210
500wA
500wA*    Return quantity that was put into transit.
500wA
500wAC**???              exsr      zzzclr$lt210
500wAC**???              eval      $tcmd     = '*PUTAWYA'
500wAC**???              eval      $tnexttask= 'PUTAWAY'
500wAC**???              eval      $tlic#    = curlic#
500wAC**???              eval      $tinlic#  = curlic#
500wAC**???              eval      $toutlic# = curlic#
500wAC**???              eval      $twhse    = #fromslwhse
500wAC**???              eval      $twhdp    = #fromslwhdp
500wAC**???              eval      $tslot    = #fromsldisp
500wAC**???              eval      $titem    = #fromslitem
500wAC**???              eval      $titemdsc = #fromithead
500wAC**???              eval      $tpartial = *off
500wAC**???              eval      $tqty1    = w1qt01
500wAC**???              eval      $tqty2    = w1qt02
500wAC**???              eval      $tqty3    = w1qt03
500xAC**???              eval      $tnorm1   = w1qt01
500xAC**???              eval      $tnorm2   = w1qt02
500xAC**???              eval      $tnorm3   = w1qt03
500wAC**???              exsr      zzzcall$lt210
500hA
500hA*           - Delete priority replenishment.
500hA
500hAC                   select
500hAC                   when      rpltyp = '*PRIORTY'  and
500hAC                             error = *off
500hAC     keypr2        chain     prplfil1                           7978
500hAC                   if        not *in79
500hAC                   eval      prflag = 'D'
500hAC                   update    prrec                                78
500hAC                   endif
500hAC                   endsl
500hAC                   else
500hAC                   exsr      zzabrt
500hAC                   endif
500hA
500hA*           - Unable to abort transaction - re-display screen.
500hA
500hAC                   select
500hAC                   when      error = *on
500hAC                   eval      bypass = *off
500hAC                   exsr      scr02i
500hAC                   goto      endup1
500hAC                   endsl
500hAC                   if        crtrcd = *on
500hAC                   exsr      zzrmtf
500hAC                   endif
500hAC                   endif
500hA
500hA*          - Find next replenishment.
500hA
500hAC                   eval      refrsh = *on
500hAC                   eval      w1tdis = *blanks
720aAC                   eval      w1lcns = *blanks
720aAC                   eval      w1scan = *blanks
500hAC                   eval      usrrpl = *off
500hAC                   goto      #upd1
500hA
500bAC                   endsl
     *
     *    No letdowns or priority replenishments found -
     *    prompt for next.
     *
     C                   when      done = *on
     *
     *     If using Locator System, and no priority replenishments
     *     found take user to Specific Slot replenishments.
     *
     C                   select
414kAC                   when      bypass = *on
414kAC                   eval      bypass = *off
600fAC                   eval      prptyp = '*IMMED  '
CBIeA*
CBIeA*     End of Priority Replenishments, start at beginning of
CBIeA*     Letdowns when working in SLOT sequence.
CBIeAC                   if        letord = 'SLOT'  and
CBIeAC                             rpltyp = '*PRIORTY'
CBIeAC                   eval      rpltyp = *blanks
CBIeAC                   endif
414kAC                   goto      #upd1
415uA*
415uA*    User skipped a letdown, no other letdowns/priority replen's found.
415uA*    Go back and re-display letdown to user.
415uAC                   when      skippd = *on
415uAC                   eval      skippd = *off
600fAC                   eval      prptyp = '*IMMED  '
415uAC                   goto      #upd1
415uA*
     C                   when      spcslt = *on
     C                   exsr      scr01i
     C                   other
     *
414kAC                   eval      bypass = *off
     C                   exsr      scr06i
     *
     C                   endsl
     *
     C                   endsl
     *
     C                   when      done = *off
     C                   eval      rpltyp = '*LETDOWN'

500tAC                   eval      sc2first = *on
     C                   exsr      scr02i
500bA*
500bA*    Call program that will (if necessary) ...
500bA*      - Prompt user to pull pallet.
500bA*      - Have user verify license being pulled.
500bA*      - Update license information.
500bA*
500bAC                   exsr      zzzclr$lt210
500bAC                   eval      $tcmd   = '*PULDROP'
500bAC                   eval      $twhse  = #fromslwhse
500bAC                   eval      $twhdp  = #fromslwhdp
500bAC                   eval      $tslot  = #fromsldisp
500bAC                   eval      $titem  = #fromslitem
500cAC                   eval      $titemdsc = #fromithead
600uAC                   eval      $tlic# = #fromsaToLcns
610fAC                   eval      $ttoslot = #picksldisp
500bAC                   exsr      zzzcall$lt210
500bAC                   eval      curlic# = $tlic#
500hA
500hA*      See how it went ...
500hA
500bAC                   select
500hA
500hA*        ... User canceled.
500hA
500bAC                   when      $treturn = '*CANCEL'
500hAC                   eval      refrsh = *off
500hAC                   if        done = *off
500hAC                   if        usrrpl = *on
500hAC                   exsr      zzcls0
500hAC                   eval      curtrn# = pttrn#
500hAC                   exsr      zztrnclose
500hA
500hA*           - Undo pulling of license plate.
500hA
500wDC**                 exsr      zzzclr$lt210
500wDC**                 eval      $tcmd   = '*PULUNDO'
500wDC**                 eval      $twhse  = #fromslwhse
500wDC**                 eval      $tlic#  = curlic#
500wDC**                 exsr      zzzcall$lt210
500wA
500wA*    Return quantity that was put into transit.
500wA
500wAC**???              exsr      zzzclr$lt210
500wAC**???              eval      $tcmd     = '*PUTAWYA'
500wAC**???              eval      $tnexttask= 'PUTAWAY'
500wAC**???              eval      $tlic#    = curlic#
500wAC**???              eval      $tinlic#  = curlic#
500wAC**???              eval      $toutlic# = curlic#
500wAC**???              eval      $twhse    = #fromslwhse
500wAC**???              eval      $twhdp    = #fromslwhdp
500wAC**???              eval      $tslot    = #fromsldisp
500wAC**???              eval      $titem    = #fromslitem
500wAC**???              eval      $titemdsc = #fromithead
500wAC**???              eval      $tpartial = *off
500wAC**???              eval      $tqty1    = w1qt01
500wAC**???              eval      $tqty2    = w1qt02
500wAC**???              eval      $tqty3    = w1qt03
500xAC**???              eval      $tnorm1   = w1qt01
500xAC**???              eval      $tnorm2   = w1qt02
500xAC**???              eval      $tnorm3   = w1qt03
500wAC**???              exsr      zzzcall$lt210
500hA
500hAC                   if        error = *off
500hA
500hA*           - Reset priority replenishment so it can be done later.
500hA
500hAC                   select
500hAC                   when      rpltyp = '*PRIORTY'
500hAC     keypr2        chain     prplfil1                           7978
500hAC                   if        not *in79
500hAC                   eval      prflag = 'S'
500hAC                   update    prrec                                78
500hAC                   endif
500hAC                   endsl
500hA
500hA*           - Start an 'IDLE' task, if no open task.
500hA
500hAC                   eval      curtrn = 0
500hAC                   eval      curtsk = *blanks
500hAC                   eval      curtyp = *blanks
500hAC                   eval      curent = *off
500hAC                   exsr      zztask
500hAC                   if        curent = *off
500hAC                   eval      w1task = 'IDLE  '
500hAC                   exsr      zztrnidle
500hAC                   endif
500hAC                   endif
500hAC                   else
500hAC                   exsr      zzabrt
500hAC                   endif
500hA
500hA*           - Unable to abort transaction - re-display screen.
500hA
500hAC                   select
500hAC                   when      error = *on
500hAC                   exsr      scr02i
500hAC                   goto      endup1
500hAC                   endsl
500hAC                   if        crtrcd = *on
500hAC                   exsr      zzrmtf
500hAC                   endif
500hAC                   endif
500hA*
500hAC                   select
500hAC                   when      rpltyp = '*SPECIFC'
500hAC                   exsr      scr01i
500hA*
500hAC                   other
500hAC                   exsr      scr07i
500hAC                   endsl
500hAC                   goto      endup1
500hA
500hA*        ... User pressed F9=Skip
500hA
500hAC                   when      $treturn = '*SKIP'
500hAC                   eval      bypass = *on
500hAC                   eval      refrsh = *off
500hAC                   eval      savtrn = pttrn#
500hAC                   eval      svrtpo = ptrtpo
500hAC                   eval      savseq = prseq#
650bAC                   eval      idx = idx + 1
650bAC                   eval      hldseqAlpha = %char(prseq#)
650bAC                   movel     prwhdp        whdp_seq(idx)
650bAC                   move      hldseqAlpha   whdp_seq(idx)
500hAC                   if        done = *off
500hAC                   if        usrrpl = *on
500hAC                   exsr      zzcls0
500hAC                   eval      curtrn# = pttrn#
500hAC                   exsr      zztrnclose
500hA
500hA*           - Undo pulling of license plate.
500hA
500wDC**                 exsr      zzzclr$lt210
500wDC**                 eval      $tcmd   = '*PULUNDO'
500wDC**                 eval      $twhse  = #fromslwhse
500wDC**                 eval      $tlic#  = curlic#
500wDC**                 exsr      zzzcall$lt210
500wA
500wA*    Return quantity that was put into transit.
500wA
500wAC**???              exsr      zzzclr$lt210
500wAC**???              eval      $tcmd     = '*PUTAWYA'
500wAC**???              eval      $tnexttask= 'PUTAWAY'
500wAC**???              eval      $tlic#    = curlic#
500wAC**???              eval      $tinlic#  = curlic#
500wAC**???              eval      $toutlic# = curlic#
500wAC**???              eval      $twhse    = #fromslwhse
500wAC**???              eval      $twhdp    = #fromslwhdp
500wAC**???              eval      $tslot    = #fromsldisp
500wAC**???              eval      $titem    = #fromslitem
500wAC**???              eval      $titemdsc = #fromithead
500wAC**???              eval      $tpartial = *off
500wAC**???              eval      $tqty1    = w1qt01
500wAC**???              eval      $tqty2    = w1qt02
500wAC**???              eval      $tqty3    = w1qt03
500xAC**???              eval      $tnorm1   = w1qt01
500xAC**???              eval      $tnorm2   = w1qt02
500xAC**???              eval      $tnorm3   = w1qt03
500wAC**???              exsr      zzzcall$lt210
500hA
500hA*           - Reset priority replenishment so it can be done later.
500hA
500hAC                   select
500hAC                   when      rpltyp = '*PRIORTY'  and
500hAC                             error = *off
500hAC     keypr2        chain     prplfil1                           7978
500hAC                   if        not *in79
500hAC                   eval      prflag = 'S'
500hAC                   update    prrec                                78
500hAC                   endif
500hAC                   endsl
500hAC                   else
500hAC                   exsr      zzabrt
500hAC                   endif
500hA
500hA*           - Unable to abort transaction - re-display screen.
500hA
500hAC                   select
500hAC                   when      error = *on
500hAC                   eval      bypass = *off
500hAC                   exsr      scr02i
500hAC                   goto      endup1
500hAC                   endsl
500hAC                   if        crtrcd = *on
500hAC                   exsr      zzrmtf
500hAC                   endif
500hAC                   endif
500hA
500hA*          - User chose to bypass transaction - find next let down.
500hA
500hAC                   eval      refrsh = *on
500hAC                   eval      w1tdis = *blanks
720aAC                   eval      w1lcns = *blanks
720aAC                   eval      w1scan = *blanks
500hAC                   eval      usrrpl = *off
500hAC                   goto      #upd1
500hA
500hA*        ... User pressed F10=Except when item not found on pallet.
500hA
500hAC                   when      $treturn = '*NOTFND'
500hAC                   eval      bypass = *on
500hAC                   eval      refrsh = *off
500hAC                   eval      savtrn = pttrn#
500hAC                   eval      svrtpo = ptrtpo
500hAC                   eval      savseq = prseq#
500hAC                   if        done = *off
500hAC                   if        usrrpl = *on
500hAC                   exsr      zzcls0
500hAC                   eval      curtrn# = pttrn#
500hAC                   exsr      zztrnclose
500hA
500hA*           - Undo pulling of license plate.
500hA
500wDC**                 exsr      zzzclr$lt210
500wDC**                 eval      $tcmd   = '*PULUNDO'
500wDC**                 eval      $twhse  = #fromslwhse
500wDC**                 eval      $tlic#  = curlic#
500wDC**                 exsr      zzzcall$lt210
500wA
500wA*    Return quantity that was put into transit.
500wA
500wAC**???              exsr      zzzclr$lt210
500wAC**???              eval      $tcmd     = '*PUTAWYA'
500wAC**???              eval      $tnexttask= 'PUTAWAY'
500wAC**???              eval      $tlic#    = curlic#
500wAC**???              eval      $tinlic#  = curlic#
500wAC**???              eval      $toutlic# = curlic#
500wAC**???              eval      $twhse    = #fromslwhse
500wAC**???              eval      $twhdp    = #fromslwhdp
500wAC**???              eval      $tslot    = #fromsldisp
500wAC**???              eval      $titem    = #fromslitem
500wAC**???              eval      $titemdsc = #fromithead
500wAC**???              eval      $tpartial = *off
500wAC**???              eval      $tqty1    = w1qt01
500wAC**???              eval      $tqty2    = w1qt02
500wAC**???              eval      $tqty3    = w1qt03
500xAC**???              eval      $tnorm1   = w1qt01
500xAC**???              eval      $tnorm2   = w1qt02
500xAC**???              eval      $tnorm3   = w1qt03
500wAC**???              exsr      zzzcall$lt210
500hA
500hA*           - Delete priority replenishment.
500hA
500hAC                   select
500hAC                   when      rpltyp = '*PRIORTY'  and
500hAC                             error = *off
500hAC     keypr2        chain     prplfil1                           7978
500hAC                   if        not *in79
500hAC                   eval      prflag = 'D'
500hAC                   update    prrec                                78
500hAC                   endif
500hAC                   endsl
500hAC                   else
500hAC                   exsr      zzabrt
500hAC                   endif
500hA
500hA*           - Unable to abort transaction - re-display screen.
500hA
500hAC                   select
500hAC                   when      error = *on
500hAC                   eval      bypass = *off
500hAC                   exsr      scr02i
500hAC                   goto      endup1
500hAC                   endsl
500hAC                   if        crtrcd = *on
500hAC                   exsr      zzrmtf
500hAC                   endif
500hAC                   endif
500hA
500hA*          - Find next replenishment.
500hA
500hAC                   eval      refrsh = *on
500hAC                   eval      w1tdis = *blanks
720aAC                   eval      w1lcns = *blanks
720aAC                   eval      w1scan = *blanks
500hAC                   eval      usrrpl = *off
500hAC                   goto      #upd1
500hA
500bAC                   endsl
     *
     C                   endsl
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
     C                   eval      savtrn = pttrn#
600uAC                   eval      svqpck = w2nqty
610hDC**   w2nqty        sub       w2repq        difpck
610hMC                   eval      difpck = w2nqty - w2sltq
600uAC                   if        difpck <> 0
600uAC                   eval      partial = *on
600uAC                   else
600uAC                   eval      partial = *off
600uAC                   endif
600uDC**
600uDC** Update slots when there is a difference.
600uDC**
600uDC**                 if        difpck <> 0
600uDC**
600uDC**                 exsr      clr$slot
600uDC**                 eval      $slwhseu = *on
600uDC**                 eval      $slwhse  = #fromslwhse
600uDC**                 eval      $slwhdpu = *on
600uDC**                 eval      $slwhdp  = #fromslwhdp
600uDC**                 eval      $sldispu = *on
600uDC**                 eval      $sldisp  = #fromsldisp
600uDC**                 eval      $saitemu = *on
600uDC**                 eval      $saitem  = #fromslitem
600uDC**                 eval      $sacitemu = *on
600uDC**                 eval      $sacitem  = #pickslitem
600uDC**                 eval      $satrn#u = *on
600uDC**                 eval      $satrn#  = lbtrn#
600uDC**                 eval      $satasku = *on
600uDC**                 eval      $satask  = pttask
600uDC**                 eval      $saqtyu = *on
600uDC**                 eval      $saqty1 = difpck
600uDC**                 eval      $saqty2 = 0
600uDC**                 eval      $saqty3 = 0
600uDC**                 eval      $dricommand = '*SLOT'
600uDC**                 eval      $drisubcmd = '%TFROUTCHG'
600uDC**                 eval      chk4err = *off
600uDC**                 eval      zmsflag = *off
600uDC**                 exsr      zzzdricop
600uDC**
600uDC**                 eval      #fromslstk1 = $slstk1
600uDC**                 eval      #fromslstk2 = $slstk2
600uDC**                 eval      #fromslstk3 = $slstk3
600uDC**                 eval      #fromslalc1 = $slalc1
600uDC**                 eval      #fromslalc2 = $slalc2
600uDC**                 eval      #fromslalc3 = $slalc3
600uDC**                 eval      #fromsltfr1 = $sltfr1
600uDC**                 eval      #fromsltfr2 = $sltfr2
600uDC**                 eval      #fromsltfr3 = $sltfr3
600uDC**                 eval      #fromslpck1 = $slpck1
600uDC**                 eval      #fromslpck2 = $slpck2
600uDC**                 eval      #fromslpck3 = $slpck3
600uDC**                 eval      #fromslrcv1 = $slrcv1
600uDC**                 eval      #fromslrcv2 = $slrcv2
600uDC**                 eval      #fromslrcv3 = $slrcv3
600uDC**                 eval      #fromslphy1 = $slphy1
600uDC**                 eval      #fromslphy2 = $slphy2
600uDC**                 eval      #fromslphy3 = $slphy3
600uDC**                 eval      #fromslavl1 = $slavl1
600uDC**                 eval      #fromslavl2 = $slavl2
600uDC**                 eval      #fromslavl3 = $slavl3
     *
600uDC**                 exsr      clr$slot
600uDC**                 eval      $slwhseu = *on
600uDC**                 eval      $slwhse  = #pickslwhse
600uDC**                 eval      $slwhdpu = *on
600uDC**                 eval      $slwhdp  = #pickslwhdp
600uDC**                 eval      $sldispu = *on
600uDC**                 eval      $sldisp  = #picksldisp
600uDC**                 eval      $saitemu = *on
600uDC**                 eval      $saitem  = #pickslitem
600uDC**                 eval      $sacitemu = *on
600uDC**                 eval      $sacitem  = #fromslitem
600uDC**                 eval      $satrn#u = *on
600uDC**                 eval      $satrn#  = lbtrn#
600uDC**                 eval      $satasku = *on
600uDC**                 eval      $satask = pttask
600uDC**                 eval      $saqtyu = *on
600uDC**                 eval      $saqty1 = difpck
600uDC**                 eval      $saqty2 = 0
600uDC**                 eval      $saqty3 = 0
600uDC**                 eval      $dricommand = '*SLOT'
600uDC**                 eval      $drisubcmd = '%TFRINCHG'
600uDC**                 eval      chk4err = *off
600uDC**                 eval      zmsflag = *off
600uDC**                 exsr      zzzdricop
600uDC**
600uDC**                 eval      #pickslstk1 = $slstk1
600uDC**                 eval      #pickslstk2 = $slstk2
600uDC**                 eval      #pickslstk3 = $slstk3
600uDC**                 eval      #pickslalc1 = $slalc1
600uDC**                 eval      #pickslalc2 = $slalc2
600uDC**                 eval      #pickslalc3 = $slalc3
600uDC**                 eval      #picksltfr1 = $sltfr1
600uDC**                 eval      #picksltfr2 = $sltfr2
600uDC**                 eval      #picksltfr3 = $sltfr3
600uDC**                 eval      #pickslpck1 = $slpck1
600uDC**                 eval      #pickslpck2 = $slpck2
600uDC**                 eval      #pickslpck3 = $slpck3
600uDC**                 eval      #pickslrcv1 = $slrcv1
600uDC**                 eval      #pickslrcv2 = $slrcv2
600uDC**                 eval      #pickslrcv3 = $slrcv3
600uDC**                 eval      #pickslphy1 = $slphy1
600uDC**                 eval      #pickslphy2 = $slphy2
600uDC**                 eval      #pickslphy3 = $slphy3
600uDC**                 eval      #pickslavl1 = $slavl1
600uDC**                 eval      #pickslavl2 = $slavl2
600uDC**                 eval      #pickslavl3 = $slavl3
600uDC**
600uDC**                 eval      svqpck = w2nqty
600uDC**
600uDC**                 endif
600uA
600uA*    Tfr qty into USR slot.
600uA*      Only if not coming from IT276, which already did this.
600uA
600uAC                   if        not it276Flag
600uA
600uA*      Call license tracking
600uA
600uAC                   exsr      zzzclr$lt210
600uAC                   eval      $tcmd     = '*PULTRAN'
600uAC                   eval      $tlic#    = #fromsaToLcns
600uAC                   eval      $tnewlic# = #fromsaToLcns
600uAC                   eval      $twhse    = #fromslwhse
600uAC                   eval      $titem    = #fromslitem
600uAC                   eval      $titemdsc = #fromithead
600uAC                   eval      $tpartial = partial
600uAC                   eval      $tqty1    = w2nqty
600uAC                   eval      $tqty2    = 0
600uAC                   eval      $tqty3    = 0
600uAC                   eval      $tnorm1   = w2nqty
600uAC                   eval      $tnorm2   = 0
600uAC                   eval      $tnorm3   = 0
600uaC                   exsr      zzzcall$lt210
600ua
600uaC                   if        $treturn <> '*OK'
600uAC                   endif
600uA
600wDC**                 eval      curlic# = $tinlic#
500 A
500 A*      Use DRI interface to tfr qty to USR slot.
500 A
600uA
600uAC                   exsr      clr$slot
600uAC                   eval      $slwhseu = *on
600uAC                   eval      $slwhse = #fromslwhse
600uAC                   eval      $slwhdpu = *on
600uAC                   eval      $slwhdp = #fromslwhdp
600uAC                   eval      $sldispu = *on
600uAC                   eval      $sldisp = #fromsldisp
600uAC                   eval      $saitemu = *on
600uAC                   eval      $saitem = #fromslitem
600uAC                   eval      $sacitemu = *on
610aDC**                 eval      $sacitem = #pickslitem
610aMC                   eval      $sacitem = #fromslitem
600uAC                   eval      $saqtyu = *on
600uAC                   eval      $saqty1 = w2nqty
600uAC                   eval      $saqty2 = 0
600uAC                   eval      $saqty3 = 0
600uAC                   eval      $satrn#u = *on
600uAC                   eval      $satrn# = curtrn#
600uAC                   eval      $satasku = *on
600uAC                   if        #pickittype = 'B'
600uAC                   eval      $satask = 'REPLBK'
600uAC                   else
600uAC                   eval      $satask = 'REPL  '
600uAC                   endif
600uA
600uAC                   eval      $saActionU = *on
600uAC                   eval      $saAction = 'RPL'
600uAC                   eval      $saETrn#U = *on
600uAC                   eval      $saETrn# = 0
600uAC                   eval      $saLbl#U = *on
600uAC                   eval      $saLbl# = lblbl#
600uAC                   eval      $saToLcnsU = *on
600uAC                   eval      $saToLcns = $tinlic#
600uAC                   eval      $saToPosU = *on
600uAC                   eval      $saToPos = $tslotpos
600uAC                   eval      $saToVrfyU = *on
600uAC                   eval      $saToVrfy = 'N'
600uAC                   eval      $saToCodeu = *on
600uAC                   eval      $saToCode = 'U'
600uAC                   eval      $saToAreaU = *on
600uAC                   eval      $saToArea = 'User'
600uAC                   eval      $saFrmLcnsU = *on
600uAC                   eval      $saFrmLcns = $toutlic#
600uAC                   eval      $saOLcnsU = *on
600uAC                   eval      $saOLcns = #fromsaOLcns
600uA
600uAC                   eval      $dricommand = '*SLOT'
600uAC                   eval      $drisubcmd = '%TFR2USR'
600uAC                   eval      chk4err = *off
600uAC                   eval      zmsflag = *off
600uAC                   if        w2nqty > 0
600uAC                   exsr      zzzdricop
650aAC                   exsr      zzgetdatetime
650aAC                   eval      tfr2usrDate = curdate
650aAC                   eval      tfr2usrTime = curtime
600uAC                   endif
600wA
600wAC                   eval      curlic# = $saToLcns
600uA
600uA*      Create workusr record.
600uA
600uAC                   exsr      zzwrkadd
600uA
600uA*      Then tell user to put back an pulled pallets.
600uA*         and move on to the putaway process.
600uA
600uAC                   exsr      zzzclr$lt210
600uAC                   eval      $tcmd  = '*PULRTN'
600uAC                   eval      $twhse = #fromslwhse
600uAC                   eval      $twhdp = #fromslwhdp
600uAC                   eval      $tslot = #fromsldisp
600uAC                   eval      $titem = #fromslitem
600uAC                   eval      $titemdsc = #fromithead
600yAC                   eval      $tlic#  = curlic#
600uAC                   exsr      zzzcall$lt210
600uAC                   if        $treturn <> '*OK'
600uAC                   endif
600uA
640hA*    Returned successfully from IT276. Reset license with USR lic#.
640hAC                   else
640hA*
600hA*    Load new user license with value created in IT276.
640hAC                   eval      curlic# = WuUsrLcns
600uAC                   endif
     *
     *    Update LABEL,PIRTRAN rcds with changes.
     *
     C                   select
500oDC**                 when      pttask = 'REPLBK'  and
500oDC**                           difpck <> 0
500oMC                   when      difpck <> 0
610mA*    Breakdown replenishments from IT276 doesn't update label rcd.
610mAC                             or pttask = 'REPLBK'
610mAC                             and rpltyp = '*SPECIFC'
610mA*
     *    Update pick quantity in label record.
     C     lbkey         chain     label                              79
     C                   z-add     w2nqty        lbqpck
500oDC**                 if        #fromitumq2 > *zeros
500rAC                   if        pttask = 'REPLBK'  and
500rAC                             #fromitumq2 > *zeros
500rAC     #fromitumq2   mult      w2nqty        wrkqty
500rAC                   eval      lbqrmn = wrkqty
500rAC                   eval      lbqrmn = wrkqty
500rAC                   endif
500nDC**                 else
     C                   z-add     w2nqty        wrkqty
500nDC**                 endif
     C     lbucub        mult      wrkqty        lbcube
     C     lbuwgt        mult      wrkqty        lbswgt
     C                   update    lbrec
     *    Update quantity in transaction record.
     C     ptkey         chain     pirtran                            79
     C                   eval      ptpcs = wrkqty
     C     lbucub        mult      wrkqty        ptcube
     C     lbuwgt        mult      wrkqty        ptswgt
     C                   update    ptrec
640jAc                   exsr      zzwrttrand
414cA*
414cAC                   other
414cA*    Retrieve label record for current values.
414cAC     lbkey         chain(n)  label                              79
     *
     C                   endsl
     *
     *    Create transaction/label rcds to hold extra qty.
414hA*    Note: This is done only once for each originating
414hA*          transaction.  Thereafter, rcds are just updated.
     *
414hAC                   if        crtrcd = *off
     C                   call      'PIRTRN#'
     C                   parm                    pttrn#            7 0
     *
     C                   eval      @ptask = 'REPLTF'
500oDC**                 eval      @ppcs  = -(difpck)
500oMC                   eval      @ppcs  = 0
500dMC                   eval      @pcube = @ppcs * #fromitcube
500dMC                   eval      @pswgt = @ppcs * #fromitswgt
     C                   call      @addtr
     C                   parm      '*CREATE '    @pcmd
     C                   parm                    #job
     C                   parm      pttrn#        @ptrn#
     C                   parm                    @ptask
414cMC                   parm      lbwhse        @pwhse
414cMC                   parm      lbwhdp        @pwhdp
414cMC                   parm      lbstyp        @pstyp
     C                   parm                    @pcube
     C                   parm                    @pswgt
     C                   parm                    @ppcs
     C                   parm      1             @paisl
     C                   parm      0             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      '0'           @prte
     C                   parm      *blanks       @ppo
     C                   parm      'L'           @pgrp1
     C                   parm      ' '           @pgrp2
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
414hAC                   else
414hA*
414hA*    Record already created, just update it this time.
414hAC     lbctr#        chain     pirtran                            79
414hA*
414hAC                   eval      ptwhse = lbwhse
414hAC                   eval      ptwhdp = lbwhdp
414hAC                   eval      ptstyp = lbstyp
500oDC**                 eval      ptpcs = -(difpck)
500oMC                   eval      ptpcs = 0
500dMC                   eval      @pcube = ptpcs * #fromitcube
500dMC                   eval      @pswgt = ptpcs * #fromitswgt
414hAC                   update    ptrec
640jAc                   exsr      zzwrttrand
414hAC                   endif
     *
414hAC                   eval      $ptrn# = pttrn#
     *
     *    Retrieve new label nbr.
414hA*    Note: This is done only once for each originating
414hA*          transaction.  Thereafter, rcds are just updated.
     *
414hAC                   if        crtrcd = *off
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   eval      svrplb = *zeros
     C     lblbl#        chain     label                              79
414hAC                   else
414hA*    Record already created, retrieve it this time.
414hAC     svrplb        chain     label                              79
414hAC                   endif
     *
     C                   eval      svrplb = lblbl#
     * TO Slot.
500dMC                   eval      lbwhs2 = #fromslwhse
500dMC                   eval      lbwhd2 = #fromslwhdp
     *
     *    Left over product will be returned to slot.
     *
     C                   if        rtnhom = *on
500dMC                   eval      lbasl2 = #fromslaisl
500dMC                   eval      lbloc2 = #fromslloc
500dMC                   eval      lblvl2 = #fromslrlvl
500dMC                   eval      lbhnd2 = #fromslhand
500dMC                   eval      lbdsp2 = #fromsldisp
     C                   else
     C                   eval      lbasl2 = *blanks
     C                   eval      lbloc2 = *zeros
     C                   eval      lblvl2 = *zeros
     C                   eval      lbhnd2 = *blanks
     C                   eval      lbdsp2 = *blanks
     C                   endif
     *
     C                   eval      lbrte = *blanks
     *
     C                   eval      lbpbat = *zeros
500dMC                   eval      lbucub = #fromitcube
500dMC                   eval      lbuwgt = #fromitswgt
     *
     C                   eval      lbqavl = *zeros
500iDC**                 eval      lbqalc = -(difpck)
500oDC**                 eval      lbqalc = difpck
500oMC                   eval      lbqalc = 0
     C                   eval      lbqrmn = *zeros
500iDC**                 eval      lbqpck = -(difpck)
500oDC**                 eval      lbqpck = difpck
500oMC                   eval      lbqpck = 0
     *
500dMC                   eval      lbcube = lbqpck * lbucub
500dMC                   eval      lbswgt = lbqpck * lbuwgt
500dMC                   eval      lbucod = #fromitum1
500dMC                   eval      lbtie  = #fromittie
500dMC                   eval      lbhigh = #fromithigh
     C                   eval      lbtrn# = pttrn#
     C                   eval      lbctr# = savtrn
     C                   eval      lbgrp1 = 'L'
     C                   eval      lbgrp2 = ' '
     C                   eval      lbtype = 'R'
     C                   eval      lbstat = 'O'
414iA*    Get todays date.
414iAC                   eval      $cvcmd = '*CURCMD '
414iAC                   exsr      zzcvdt
414iAC                   eval      today = $cvd8o
     C                   eval      lbsdte = today
     C                   time                    lbstim
414iA*    Get todays date.
414iAC                   eval      $cvcmd = '*CURCMD '
414iAC                   exsr      zzcvdt
414iAC                   eval      today = $cvd8o
     C                   eval      lbrdte = today
414hAC                   if        crtrcd = *off
     C                   write     lbrec
414hAC                   else
414hAC                   update    lbrec
414hAC                   endif
     *
     C                   eval      crtrcd = *on
     *
     *    Update LABEL replen. record link to new transfer rcd.
     *
     C     svlbl#        chain     label                              79
     C                   if        not *in79
     C                   eval      lbctr# = pttrn#
500iDC**                 eval      lbqpck = w2nqty
     C                   update    lbrec
     C                   endif
PFCaAc*
PFCaA*  Send APT Replenishment "Begin" record.
PFCaAc                   if        logapt
750cDc**                 eval      apcmd = aptsk1
750cDc**                 eval      aplbl# = LBLBL#
750cDc**                 eval      aptrn# = LBTRN#
750cDc**                 eval      apseq# = 0
750cDc**                 eval      aploc = W2SCAN
750cDc**                 exsr      zzapt
750cAc                   eval      apseq# += 1
750cAc                   exsr      clr$apt
tst  c****               eval      $apuser = 'ZZUPD2'
750cAC                   eval      $aplbl#  = lblbl#
750cAC                   eval      $aptrn#  = lbtrn#
750cAC                   eval      $aplocation = w2scan
750cAC                   eval      $dricommand = '*APT'
750cAC                   eval      $drisubcmd  = aptsk_BEGIN
750cAC                   eval      $drisys2upd = 'D'
750cAC                   eval      chk4err = *off
750cAC                   eval      zmsflag = *off
750cAC                   exsr      zzzdricop
PFCaAc                   endif
     *
     *    Get replenishment transaction rcd back.
     *
     C     savtrn        chain(n)  pirtran                            79
600uDC**
600uDC**   License plate tracking item. Update to show in transit.
600uDC**
600uDC**   Only for REPLBK.
600uDC**
600uDC**   Only the first time through. The second time through user is not
600uDC**   allowed to change quantity.
600uDC**
600uDC**                 if        sc2first
600uDC**
600uDC**                 exsr      zzzclr$lt210
600uDC**                 eval      $tcmd  = '*PULTRAN'
600uDC**                 eval      $tlic# = curlic#
600uDC**                 eval      $tnewlic# = curlic#
600uDC**                 eval      $twhse  = #fromslwhse
600uDC**                 eval      $titem  = #fromslitem
600uDC**                 eval      $titemdsc = #fromithead
600uDC**                 if        difpck <> 0
600uDC**                 eval      $tpartial = *on
600uDC**                 else
600uDC**                 eval      $tpartial = *off
600uDC**                 endif
600uDC**                 select
600uDC**                 when      lbutyp = 'N'
600uDC**                 eval      $tqty1 = w2nqty
600uDC**                 eval      $tnorm1 = w2nqty
600uDC**                 when      lbutyp = '1'
600uDC**                 eval      $tqty2 = w2nqty
600uDC**                 eval      $tnorm2 = w2nqty
600uDC**                 when      lbutyp = '2'
600uDC**                 eval      $tqty3 = w2nqty
600uDC**                 eval      $tnorm3 = w2nqty
600uDC**                 endsl
500wDC**                 if        pttask = 'REPLBK'
600uDC**                 exsr      zzzcall$lt210
600uDC**
600uDC**                 if        $treturn <> '*OK'
600uDC**                 endif
600uDC**
600uDC**                 eval      curlic# = $tlic#
500wDC**                 endif
600uDC**
600uDC**                 endif
600uDC**
600uDC**   Then tell user to put back an pulled pallets.
600uDC**        and move on to the putaway process.
600uDC**
600uDC**   Only for REPLBK.
600uDC**
600uDC**   Only the first time through. The second time through user is not
600uDC**   allowed to change quantity.
600uDC**
600uDC**                 if        sc2first
600uDC**
600uDC**                 exsr      zzzclr$lt210
600uDC**                 eval      $tcmd  = '*PULRTN'
600uDC**                 eval      $twhse  = #fromslwhse
600uDC**                 eval      $twhdp  = #fromslwhdp
600uDC**                 eval      $tslot  = #fromsldisp
600uDC**                 eval      $titem  = #fromslitem
600uDC**                 eval      $titemdsc = #fromithead
600uDC**                 eval      $tlic# = #fromsaToLcns
600uDC**                 if        pttask = 'REPLBK'
600uDC**                 exsr      zzzcall$lt210
600uDC**                 if        $treturn <> '*OK'
600uDC**                 endif
600uDC**                 endif
600uDC**
600uDC**                 endif
500tA*
500tA*    Indicate that we have processed SC2.
500tA*
500tAC                   eval      sc2first = *off
     *
     *    Always display Verify Slot - Checking to see if slot is
     *    physically empty and can have status chg'd to 'Z'.
414kA*    NOTE: With this modification, Verify slot will only be
414kA*          displayed in certain situations now.
     *
500dAC                   exsr      zzaskzrovfy
500dAC                   if        askzrovfy
500dAC                   exsr      scr05i
500dAC                   else
500dAC                   eval      *in03 = *off
500dAC                   exsr      scr03i
500dAC                   endif
     *
     C     endup2        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update for screen 3.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
416eAC                   eval      qtychg = *off
417EA*    Get todays date.
417EAC                   eval      $cvcmd = '*CURCMD '
417EAC                   exsr      zzcvdt
417EAC                   eval      ckdate = $cvd8o
     *
     *  old code starts here
     *
500nDC**                 if        w3nqty <> svqpck  and
500nDC**                           pttask = 'REPL  '  or
500nDC**                           w3nqty <> svqrmn  and
500nDC**                           pttask = 'REPLBK'
500nMC                   if        w3nqty <> svqpck
     C                   eval      excptn = *on
     C                   else
     C                   eval      excptn = *off
     C                   endif
     *
     *    Calculate quantity not being put into pick slot.
     *
500nDC**                 select
500nDC**                 when      pttask = 'REPL  '
     C     w3nqty        sub       lbqpck        difrep
500nDC**                 when      pttask = 'REPLBK'
500nDC**   w3nqty        sub       lbqrmn        difrep
500nDC**                 endsl
417cA*
500pA*    Call license tracking for putaway - First show it in transit.
500pA*    This is done for two reasons. First, to ask any necessary license
500pA*    questions. Second, for REPLBK this will create the necessary
500pA*    split record to be updated with the new item number and qty.
500pA*
500rA*    Don't need to do when there is no difrep for REPLBK.
500rA*
500wDC**                 exsr      zzzclr$lt210
500wDC**                 eval      $tcmd  = '*PULTRAN'
500wDC**                 eval      $tlic# = curlic#
500wDC**                 eval      $tnewlic# = curlic#
500wDC**                 eval      $twhse  = #fromslwhse
500wDC**                 eval      $titem  = #fromslitem
500wDC**                 eval      $titemdsc = #fromithead
500wDC**                 if        difrep <> 0
500wDC**                 eval      $tpartial = *on
500wDC**                 else
500wDC**                 eval      $tpartial = *off
500wDC**                 endif
500wDC**                 eval      $tqty1 = w3nqty
500rA*
500wDC**                 if        pttask <> 'REPLBK'
500wDC**                           or difrep <> 0
500wDC**                 exsr      zzzcall$lt210
500pA*
500wDC**                 select
500wDC**                 when      $treturn = '*CANCEL'
500wDC**                 goto      endup3
500wDC**                 when      $treturn <> '*OK'
500wDC**                 eval      error = *on
500wDC**                 eval      *in21 = *on
500wDC**                 eval      *in01 = *on
500wDC**                 goto      endup3
500wDC**                 endsl
500wDC**                 endif
500pA*
500wDC**                 eval      trnlic# = $tlic#
500cA*
500cA*    Call license tracking for putaway - Now do the Before update
500cA*
500cAC                   exsr      zzzclr$lt210
500cAC                   eval      $tcmd  = '*PUTAWYB'
500wAC                   eval      $tlic#  = curlic#
500wDC**                 eval      $tlic#  = trnlic#
500wAC                   if        difrep = 0
610nAC                             and w3nqty = w3pulq
500cAC                   eval      $tpartial = *off
500wAC                   else
500wAC                   eval      $tpartial = *on
500wAC                   endif
500cAC                   eval      $twhse  = #pickslwhse
500cAC                   eval      $twhdp  = #pickslwhdp
500cAC                   eval      $tslot  = #picksldisp
500cAC                   eval      $titem  = #pickslitem
500bAC                   eval      $titemdsc = #pickithead
500pAC                   if        pttask = 'REPLBK'
500pAC                   eval      $tqty1 = w3nqty * #fromitumq2
500pAC                   else
500pAC                   eval      $tqty1 = w3nqty
500pAC                   endif
500pAC                   eval      $tqty2 = 0
500pAC                   eval      $tqty3 = 0
500xAC                   eval      $tnorm1 = w3nqty
500xAC                   eval      $tnorm2 = 0
500xAC                   eval      $tnorm3 = 0
500cAC                   exsr      zzzcall$lt210
500cA*
500cAC                   select
500cAC                   when      $treturn = '*CANCEL'
500cAC                   goto      endup3
500cAC                   when      $treturn <> '*OK'
500cAC                   eval      error = *on
600wAC                   eval      errmsg = 'LT210: ' + $terrmsg
600wAC                   exsr      zm0105
500cAC                   eval      *in21 = *on
500cAC                   eval      *in01 = *on
500cAC                   goto      endup3
500cAC                   endsl

     *    Update Pick slot.
500dA
500dA*  Note: We are using %CLSTFRIN instead of %CLSTFICHG because
500dA*  the quantity we are using is the breakdown quantity and does
500dA*  not need to be converted like it did in screen 2.
500pA
500pA*  Now using %CLSTFICHG because we are working with full cases.

500dAC                   exsr      clr$slot
500dAC                   eval      $slwhseu = *on
500dAC                   eval      $slwhse  = #pickslwhse
500dAC                   eval      $slwhdpu = *on
500dAC                   eval      $slwhdp  = #pickslwhdp
500dAC                   eval      $sldispu = *on
500dAC                   eval      $sldisp  = #picksldisp
500iAC                   eval      $slentdu  = *on
500iAC                   eval      $slentd   = #fromslentd
500dAC                   eval      $slexpdu  = *on
500dAC                   eval      $slexpd   = #fromslexpd
500dAC                   eval      $saitemu = *on
500dAC                   eval      $saitem  = #pickslitem
600uAC                   eval      $sacwhdu = *on
600uAC                   eval      $sacwhd  = wuUsrWhdp
600uAC                   eval      $sacdspu = *on
600uAC                   eval      $sacdsp  = wuUsrDisp
500pAC                   eval      $sacitemu = *on
500pAC                   eval      $sacitem  = #fromslitem
500dAC                   eval      $satrn#u = *on
500dAC                   eval      $satrn#  = lbtrn#
500dAC                   eval      $satasku = *on
500dAC                   eval      $satask  = pttask
500dAC                   eval      $saqtyu = *on
500nDC**                 eval      $saqty1 = w3nqty
500pDC**                 if        pttask = 'REPLBK'
500pDC**                 eval      $saqty1 = w3nqty * #fromitumq2
500pDC**                 else
500nMC                   eval      $saqty1 = w3nqty
500pDC**                 endif
500dAC                   eval      $saqty2 = 0
500dAC                   eval      $saqty3 = 0
600uDC**                 eval      $saorgu = *on
500pDC**                 if        pttask = 'REPLBK'
500pDC**                 eval      $saorg1 = lbqrmn
500pDC**                 else
600uDC**                 eval      $saorg1 = lbqpck
500pDC**                 endif
600uDC**                 eval      $saorg2 = 0
600uDC**                 eval      $saorg3 = 0
500iAC                   eval      $saToPosu = *on
500iAC                   eval      $saToPos  = $tslotpos
600uA
600uAC                   eval      $saActionU = *on
600uAC                   eval      $saAction = 'RPL'
600uAC                   eval      $saTrn#U = *on
600uAC                   eval      $saTrn# = lbtrn#
600uAC                   eval      $saETrn#U = *on
600uAC                   eval      $saETrn# = 0
600uAC                   eval      $saLbl#U = *on
600uAC                   eval      $saLbl# = lblbl#
600uAC                   eval      $saToLcnsU = *on
600uAC                   eval      $saToLcns = $tinlic#
600uAC                   eval      $saToPosU = *on
600uAC                   eval      $saToPos = $tslotpos
600uAC                   eval      $saToVrfyU = *on
600uAC                   eval      $saToVrfy = 'N'
600uAC                   eval      $saToCodeu = *on
600uAC                   eval      $saToCode = 'S'
600uAC                   eval      $saToAreaU = *on
600uAC                   eval      $saToArea = 'Slot'
600uAC                   eval      $saFrmLcnsU = *on
600uAC                   eval      $saFrmLcns = $toutlic#
600uAC                   eval      $saOLcnsU = *on
600uAC                   eval      $saOLcns = wuPulOLcns
600wAC                   eval      $sapullwhdpu = *on
600wAC                   eval      $sapullwhdp  = wuPulWhdp
600vAC                   eval      $sapulldispu = *on
600vAC                   eval      $sapulldisp  = wuPulDisp
600vAC                   eval      $sapullbaseu = *on
600vAC                   eval      $sapullbase  = wuPulBase
600vAC                   eval      $sapulllcnsu = *on
600vAC                   eval      $sapulllcns  = wuPulLcns

720hAc                   if        $tpartial = *on
720hAc                   eval      $saUCIts = $tpartime
720hAc                   eval      $saUCItsU = *on
720hAc                   endif
600uA
416fAC                   eval      $dricommand = '*SLOT'
500pDC**                 eval      $drisubcmd = '%CLSTFRIN'
600uDC**                 eval      $drisubcmd = '%CLSTFICHG'
600uMC                   eval      $drisubcmd = '%USR2PUT'
500dAC                   eval      chk4err = *on
500dAC                   eval      zmsflag = *off
500dAC                   exsr      zzzdricop
500dA*
500jDC**                 if        error
500jMC                   if        drierr
500jAC                   eval      error = *on
500dAC                   eval      *in21 = *on
500dAC                   eval      *in01 = *on
500dAC                   goto      endup3
500dAC                   endif
600uD **
600uD **   Update From slot.
600uD **
600uDC**                 exsr      clr$slot
600uDC**                 eval      $slwhseu = *on
600uDC**                 eval      $slwhse  = #fromslwhse
600uDC**                 eval      $slwhdpu = *on
600uDC**                 eval      $slwhdp  = #fromslwhdp
600uDC**                 eval      $sldispu = *on
600uDC**                 eval      $sldisp  = #fromsldisp
600uDC**                 eval      $saitemu = *on
600uDC**                 eval      $saitem  = #fromslitem
600uDC**                 eval      $sacitemu = *on
600uDC**                 eval      $sacitem  = #pickslitem
600uDC**                 eval      $satrn#u = *on
600uDC**                 eval      $satrn#  = lbtrn#
600uDC**                 eval      $satasku = *on
600uDC**                 eval      $satask  = pttask
600uDC**                 eval      $saqtyu = *on
500nDC**                 eval      $saqty1 = fullcases
600uDC**                 eval      $saqty1 = w3nqty
600uDC**                 eval      $saqty2 = 0
600uDC**                 eval      $saqty3 = 0
600uDC**                 eval      $saorgu = *on
500gDC**                 eval      $saorg1 = lbqpck
600uDC**                 eval      $saorg1 = $saqty1
600uDC**                 eval      $saorg2 = 0
600uDC**                 eval      $saorg3 = 0
600uDC**                 eval      $dricommand = '*SLOT'
500pDC**                 eval      $drisubcmd = '%CLSTFROUT'
600uDC**                 eval      $drisubcmd = '%CLSTFOCHG'
600uDC**                 eval      chk4err = *off
600uDC**                 eval      zmsflag = *off
600uDC**                 exsr      zzzdricop
417cA*
500bM*    Call license tracking for putaway - After Update
500cM*    Note, most parms remembered from Before processing.
500bA*
500cMC                   eval      $tcmd  = '*PUTAWYA'
500bAC                   exsr      zzzcall$lt210
500bA*
500bAC                   if        $treturn <> '*OK'
500bAC                   endif
     *
     *    Update pick quantity in label record.
     *
PFCaA
PFCaA*    Call APT Interface to begin replen.
PFCaAc*                  if        logapt
PFCaAc*                            and qtychg = *on
PFCaAc*                  eval      apcmd = aptsk2
PFCaAc*                  eval      aplbl# = APLBL#
PFCaAc*                  eval      aptrn# = APTRN#
PFCaAc*                  eval      apseq# = 0
PFCaAc*                  eval      aploc = W3SCAN
PFCaAc*                  exsr      zzapt
PFCaAc*                  endif
PFCaA
     C                   if        difrep <> 0
500zAC                             or difrep = 0
500zDC*                  eval      qtychg = *on
     *
     C     lbkey         chain     label                              79
500zAC                   select
500zA*    Entire qty putaway. Close label record.
500zAC                   when      difrep = 0
500zAC                   eval      lbstat = 'C'
500zAC                   exsr      zzgetdatetime
500zAC                   eval      lbsdte = curdate
500zAC                   eval      lbstim = curtime
500zAC                   update    lbrec
500zA*
500zAC                   other
500zAC                   eval      qtychg = *on
     C                   z-add     w3nqty        lbqpck
414cAC                   z-add     w3nqty        wrkqty
     C                   if        pttask = 'REPLBK  '  and
500nMC                             #fromitumq2 > *zeros
500nDC**                           svumq2 > *zeros
500nDC**   w3nqty        div       svumq2        lbqpck
500nDC**                 z-add     w3nqty        lbqrmn
500nMC                   eval      lbqrmn = w3nqty * #fromitumq2
     C                   else
     C                   z-add     w3nqty        wrkqty
     C                   endif
     C     lbucub        mult      wrkqty        lbcube
     C     lbuwgt        mult      wrkqty        lbswgt
500qAC                   exsr      zzgetdatetime
500qAC                   eval      lbstat = 'C'
500qAC                   eval      lbsdte = curdate
500qAC                   eval      lbstim = curtime
     C                   update    lbrec
500zAC                   endsl
500dAC
500dAC                   endif
520eA
520eA*    Create adjustment records for REPLBK
520eA
520eAC                   if        pttask = 'REPLBK'
520eAC                   exsr      zzgetdatetime
520eA
520eA*      Create 'From' adjustment record
520eA
520eAC                   clear                   iarec
520eAC                   eval      iawhse = #fromslwhse
520eAC                   eval      iaitem = #fromslitem
650aDC**                 eval      iadate = curdate
650aDC**                 eval      iatime = curtime
650aMC                   eval      iadate = tfr2usrDate
650aMC                   eval      iatime = tfr2usrTime
520eAC                   eval      iaby   = #curruser
520eAC                   eval      iawhdp = #fromslwhdp
520eAC                   eval      iadisp = #fromsldisp
720jAC                   if        #fromitcwgt = 'Y'
720jAC                   eval      iacwta = -(#fromitswgt * w3nqty)
720jAC                   else
520eAC                   eval      iacwta = 0
720jAC                   endif
520eAC                   eval      iaqty1 = -(w3nqty)
520eAC                   eval      iaqty2 = 0
520eAC                   eval      iaqty3 = 0
HPCaAC                   select
HPCaDC*                  if        client = cityline
HPCaMC                   when      client = cityline
CLDaAC                   eval      iacode = 'BK'
HPCaAC                   when      client = holtpaper
HPCaAC                   eval      iacode = '2 '
HPCaDC*                  else
HPCaMC                   other
520eAC                   eval      iacode = 'CI'
HPCaDC*                  endif
HPCaMC                   endsl
520eAC                   eval      iamemo = 'To ' + #pickslitem
520eAC                   write     iarec
520eA
520eA*      Create 'To' adjustment record
520eA
520eAC                   clear                   iarec
520eAC                   eval      iawhse = #pickslwhse
520eAC                   eval      iaitem = #pickslitem
520eAC                   eval      iadate = curdate
520eAC                   eval      iatime = curtime
520eAC                   eval      iaby   = #curruser
520eAC                   eval      iawhdp = #pickslwhdp
520eAC                   eval      iadisp = #picksldisp
720jAC                   select
720jaC*      Use weight of From item if both items are cwgt items
720jAC                   when      #pickitcwgt = 'Y' and #fromitcwgt = 'Y'
720jAC                   eval      iacwta = #fromitswgt * w3nqty
720jaC*      Calculate weight if only To item is cwgt items
720jAC                   when      #pickitcwgt = 'Y'
720jAC                   eval      iacwta = #pickitswgt * (w3nqty * #fromitumq2)
720jAC                   other
520eAC                   eval      iacwta = 0
720jAC                   endsl
520eAC                   eval      iaqty1 = w3nqty * #fromitumq2
520eAC                   eval      iaqty2 = 0
520eAC                   eval      iaqty3 = 0
HPCaAC                   select
HPCaDC*                  if        client = cityline
HPCaMC                   when      client = cityline
CLDaAC                   eval      iacode = 'BK'
HPCaAC                   when      client = holtpaper
HPCaAC                   eval      iacode = '2 '
HPCaDC*                  else
HPCaMC                   other
520eAC                   eval      iacode = 'CI'
HPCaDC*                  endif
HPCaMC                   endsl
520eAC                   eval      iamemo = 'From ' + #fromslitem
520eAC                   write     iarec
520eA
520eAC                   endif
500dAC
     *    Update quantity in transaction record.
500dMC     ptkey         chain(n)  pirtran                            79
700aA * if qty repl is different from ptpcs originally put in pirtran
700aA * need to increase or decrease as needed.
700aA /free
700aA   if pttask = 'REPL';
700aA     rpldifqty = ptpcs - w3nqty;
700aA     select;
700aA       when rpldifqty > 0;
700aA         // user replenished less than ptpcs has in pirtran
700aA         rpladjcmd = '*DECTTL';
700aA         exsr zzrepladj;
700aA       when rpldifqty < 0;
700aA         // user replenished more than ptpcs has in pirtran
700aA         rpladjcmd = '*INCTTL';
700aA         rpldifqty = rpldifqty * -1;
700aA         exsr zzrepladj;
700aA       other;
700aA     endsl;
700aA   endif;
700aA /end-free
     *
     *    Close transaction.
     *
     C                   eval      svtask = pttask
500dMC                   eval      curtrn# = pttrn#
500dMC                   exsr      zztrnclose
     *
     *    Update dates in slot record.(To slot)
     *
     C                   eval      excptn = *off
415vA*
415vA*    Save destination slot in case user logs an exception.
500dMC                   eval      toslot = #picksldisp
     *
     *    Remove priority replenishment from file when has been
     *    successfully completed.
     *
     C                   select
     C                   when      rpltyp = '*PRIORTY'
     C     keypr2        chain     prplfil1                           7978
     C                   if        not *in79
414dAC                   eval      prflag = 'D'
414dMC                   update    prrec                                78
     C                   endif
     C                   endsl
     *
     *    Change slot status.
     *
     C                   if        wozero = 'Y'
     C                   exsr      zzzero
FKLaAC                   else
FKLaAC                   if        client = finkle
FKLaAC                   if        slaisl = 'TRL'  or
FKLaAC                             sldisp = '95-101-1'
FKLaAC                   exsr      zzzero
FKLaAC                   endif
FKLaAC                   endif
     C                   endif
     *
     C                   eval      refrsh = *on
     C                   eval      w1tdis = *blanks
720aAC                   eval      w1lcns = *blanks
720aAC                   eval      w1scan = *blanks
     C                   eval      usrrpl = *off
750cD **
750cD** If this was a partial putback, send place APT record.
750cDC**   Call APT Interface.
750cDC**                 if        logapt
750cDc**                           and qtychg = *on
750cDC**                 eval      apcmd = aptsk2
750cDC**                 eval      aptrn# = SVTRN#
750cDC**                 eval      aplbl# = SVLBL#
750cDC**                 eval      aploc = W3SCAN
750cDC**                 EXSR      ZZAPT
750cDC**                 ENDIF
600cA*
600cA*    Slot was replenished. Update Runner Flag entries.
600cA*
600cAC                   if        w3nqty > 0
600cAC                   exsr      zzout
600cAC                   endif
600pA*  Option to check slot quantity
600pAC                   if        opcqty = 'Y'
600p *  Call program to check slot quantity.
600pA**                   MOVE LBDSP2    $PDISP
600pA**                   MOVE W1WHDP    $PWHDP
600p C                   eval      whse = lbwhse
600pAC                   call      'SL635'
600pAC                   parm                    whse
600pAC                   parm                    lbwhdp
600pAC                   parm                    lbdsp2
600pAC                   endif
750cA
750cAC*    Call APT Interface.
750cA*      If partial repln, send Place record
750cA*      Otherwise, send End record
750cAC                   if        logapt
750cAc                   eval      apseq# += 1
750cAc                   exsr      clr$apt
tst  c****               eval      $apuser = 'ZZUPD3'
750cAC                   eval      $aplbl#  = svlbl#
750cAC                   eval      $aptrn#  = svtrn#
750cAC                   eval      $aplocation = w3scan
750cAC                   eval      $dricommand = '*APT'
750cAc                   if        w3nqty = w3pulq
750cAC                   eval      $drisubcmd  = aptsk_END
750cAC                   eval      $drisubcmd  = %trimr($drisubcmd) + '3'
750cAC                   else
750cAC                   eval      $drisubcmd  = aptsk_PLACE
750cAC                   endif
750cAC                   eval      $drisys2upd = 'D'
750cAC                   eval      chk4err = *off
750cAC                   eval      zmsflag = *off
750cAC                   exsr      zzzdricop
PFCaAC                   ENDIF
     C                   select
     *    Entire qty was put into pick slot.
     C                   when      w3nqty = w3pulq  and
     C                             svtask = 'REPL  '  or
     C                             w3nqty = w3repq  and
     C                             svtask = 'REPLBK'
417cA*
     C                   exsr      zzrmtf
600uA
600uA*    Delete workusr record.
600uA
600uAC                   exsr      zzwrkdel
600uD **
600uD **   Then tell user to put back an pulled pallets.
600uD **        and remove left behind zero lichist record
600uD **        and move on to the putaway process.
600uD **
600uD **   Return was already done from REPLBK.
600uD **
600uDC**                 exsr      zzzclr$lt210
500yDC**                 eval      $tcmd  = '*PULRTN'
600uDC**                 eval      $tcmd  = '*RMVZRTN'
600uDC**                 eval      $twhse  = #fromslwhse
600uDC**                 eval      $twhdp  = #fromslwhdp
600uDC**                 eval      $tslot  = #fromsldisp
600uDC**                 eval      $titem  = #fromslitem
600uDC**                 eval      $titemdsc = #fromithead
600uDC**                 eval      $tlic# = #fromsaToLcns
600uDC**                 if        pttask <> 'REPLBK'
600uDC**                 exsr      zzzcall$lt210
600uDC**                 if        $treturn <> '*OK'
600uDC**                 endif
600uDC**                 endif
600uD **
600uD **   For REPLBK, see if a zero rec needs to be removed.
600uD **   For REPL this was done above in the return step.
600uD **
600uDC**                 if        pttask = 'REPLBK'
600uDC**                 exsr      zzzclr$lt210
600uDC**                 eval      $tcmd  = '*RMVZERO'
600uDC**                 eval      $twhse  = #fromslwhse
600uDC**                 eval      $twhdp  = #fromslwhdp
600uDC**                 eval      $tslot  = #fromsldisp
600uDC**                 eval      $titem  = #fromslitem
600uDC**                 eval      $titemdsc = #fromithead
600uDC**                 eval      $tlic# = #fromsaToLcns
600uDC**                 exsr      zzzcall$lt210
600uDC**                 if        $treturn <> '*OK'
600uDC**                 endif
600uDC**                 endif
     *
     *    When user is in specific slot replenishment mode,
     *    take them back.  Otherwise, find next letdown or
     *    priority replenishment.
     *
     C                   select
     C                   when      rpltyp = '*SPECIFC'
PFCaA
750cD**   Send APT Replenishment "End" record.
750cDc**                 if        logapt
750cDc**                 eval      apcmd = aptsk4
750cDc**                 eval      aptrn# = LBTRN#
750cDc**                 eval      aplbl# = LBLBL#
750cDc**                 eval      aploc = W8SCAN
750cDc**                 EXSR      ZZAPT
750cDc**                 ENDIF


650bA*    If there's a JIT or priority repl for the from slot just used
650bA*    in specific slot replenishment, delete it.

710cA*    Moved 650b and 650i mods below to ZZDELRPL subroutine.
710cAC                   exsr      zzdelrpl
710cDC*    keypr11       chain     prplfil11
710cDC*                  if        %found
710cDC*                  eval      prflag = 'D'
710cDC*                  update    prrec11                              78
710cDC*                  endif
710cDC*                  unlock    prplfil11
710cDC*/free

650mA*    If option "Show JIT win during spec slot repl" equals N
650mA*    don't bother checking for JIT's as the user does not want
650mA*    the JIT notification window.
650mAC                   if        opjitw <> 'N'

650bA*    Before moving on to another specific slot repl, check for
650bA*    JIT repl's and if you find one, ask user if he wants to
650bA*    process the JIT/s instead of continuing on with specific
650bA*    slot replenishment.

650bAC                   eval      chknew = *on
650bAC                   eval      bypass = *off
650bAC                   eval      prptyp = '*IMMED  '
650bAC                   exsr      zznext
650bAC                   if        done = *off
650bAC                   exsr      scr11i
650bAC                   goto      endup3
650bAC                   endif

650mAC                   endif
414fA*
414fA*    Start an 'IDLE' task, if no open task.
414fA*
414fAC                   eval      curtrn = 0
414fAC                   eval      curtsk = *blanks
414fAC                   eval      curtyp = *blanks
414fAC                   eval      curent = *off
414fAC                   exsr      zztask
414fAC                   if        curent = *off
414fAC                   eval      w1task = 'IDLE  '
500dMC                   exsr      zztrnidle
414fAC                   endif
     C                   exsr      scr01i
     *
     C                   other
     *
600fAC                   eval      prptyp = '*IMMED  '
     C                   exsr      zzupd1
     C                   endsl
     *
     C                   other
     *
     *    Qty left over, direct user to put product back in stock.
     *
500nDC**                 select
500nDC**                 when      svtask = 'REPL  '
414kAC     w3pulq        sub       w3nqty        wrkqty
500nDC**
500nDC**                 when      svtask = 'REPLBK'
500nDC**   w3repq        sub       w3nqty        wrkqty
500nDC**                 endsl
     *
     C                   if        wrkqty <> *zeros
414kMC                   eval      w3balq = wrkqty
     *
     C     svrplb        chain     label                              79
     C                   if        not *in79
414kMC                   eval      lbqpck = wrkqty
500nDC**
500nDC**  If break-down replenishment was processed, convert label rcd
500nDC**  info back to base item for return to slots.
500nDC**                 if        svtask = 'REPLBK  '
500nDC**                 eval      lbqrmn = *zeros
500nDC**                 eval      lbqalc = *zeros
500nDC**                 eval      lbitem = #fromititem
500nDC**                 eval      lbswgt = #fromitswgt
500nDC**                 eval      lbucub = #fromitcube
500nDC**                 if        #fromitumq2 > *zeros
500nDC**   w3balq        div       #fromitumq2   w3balq
500nDC**                 mvr                     cases
500nDC**                 if        cases > *zeros
500nDC**                 add       1             w3balq
500nDC**                 endif
500nDC**                 endif
500nDC**                 endif
414bAC                   z-add     w3balq        lbqpck
     C     lbucub        mult      lbqpck        lbcube
     C     lbuwgt        mult      lbqpck        lbswgt
     C                   update    lbrec
     C                   endif
700aA *This doubles the pcs in the transaction
     *    Update quantity in transaction record.
700aDC*    lbtrn#        chain     pirtran                            79
700aDC*                  if        not *in79
700aDC*                  eval      ptpcs = wrkqty
700aDC*    lbucub        mult      ptpcs         ptcube
700aDC*    lbuwgt        mult      ptpcs         ptswgt
700aDC*                  update    ptrec
700aDc*                  exsr      zzwrttrand
700aDC*                  endif
     C                   endif
600uA
600uA*    Update workusr record.
600uA
600uAC                   exsr      zzwrkupd3
     *
710cA*    If there's a JIT or priority repl for the from slot just used
710cA*    in specific slot replenishment, delete it.
710cAC                   exsr      zzdelrpl

     C                   eval      newlb = *off
414eAC                   eval      lstslt = w3scan
     C                   exsr      scr08i
     *
     C                   endsl
     *
     C     endup3        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD4   Update for screen 4.
     *
     C     zzupd4        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     C                   select
     C                   when      w4item = 'Y'
     *
     *    Write exception to file.
416oAC                   select
416oA*    User skipped slot that had no problem, just can't get
416oA*    to product for some reason.
416oAC                   when      errtyp = '*LIST   '
416oAC                   eval      exerid = 'LIST   '
416oA*
417jA*    User logged exception from Balance Putaway screen.
417jAC                   when      balexc = *on
417jAC                   eval      exerid = 'QTYEXC '
417jA*
416oAC                   other
     C                   eval      exerid = 'WRGITM '
416oAC                   endsl
416oA*
417jA*    User logged exception from Balance Putaway screen.
417jAC                   if        balexc = *on
650cA*
650cAC                   if        w8balq > 999
650cAC                   eval      exqty = 999
650cAC                   else
650cA*
417jAC                   z-add     w8balq        exqty
650cAC                   endif
650cA*
417jAC                   else
650cA*
650cAC                   if        lbqpck > 999
650cAC                   eval      exqty = 999
650cAC                   else
650cA*
     C                   z-add     lbqpck        exqty
650cAC                   endif
650cA*
417jAC                   endif
     C                   exsr      zzexcp
     *
     C                   select
     *    Abort specific/priority replenishments.
     C                   when      rpltyp = '*PRIORTY'  or
     C                             rpltyp = '*SPECIFC'
415hA*
415hA*    Exception taken from balance screen.  Remove qty left over.
415hAC                   if        balexc = *on
416fA*
416fAC                   exsr      clr$slot
416fAC                   eval      $slwhseu = *on
416fAC                   eval      $slwhse  = #fromslwhse
416fAC                   eval      $slwhdpu = *on
416fAC                   eval      $slwhdp  = #fromslwhdp
416fAC                   eval      $sldispu = *on
601dMC                   eval      $sldisp  = #frombasesldsp
601dDC**                 eval      $sldisp  = #fromsldisp
416fAC                   eval      $saitemu = *on
416fAC                   eval      $saitem  = #fromslitem
600xAC                   eval      $sacwhdu = *on
600xAC                   eval      $sacwhd  = wuUsrWhdp
600xAC                   eval      $sacdspu = *on
600xAC                   eval      $sacdsp  = wuUsrDisp
500pAC                   eval      $sacitemu = *on
600xDC**                 eval      $sacitem  = #pickslitem
600xMC                   eval      $sacitem  = #fromslitem
416fAC                   eval      $satrn#u = *on
416fAC                   eval      $satrn#  = lbtrn#
416fAC                   eval      $satasku = *on
416fAC                   eval      $satask  = pttask
416fAC                   eval      $saqtyu = *on
600xDC**                 eval      $saqty1 = -(w8balq)
601cDC**                 eval      $saqty1 = w8nqty
601cMC                   eval      $saqty1 = w8balq
416fAC                   eval      $saqty2 = 0
416fAC                   eval      $saqty3 = 0
600xA
600xAC                   eval      $saActionU = *on
600xAC                   eval      $saAction = 'RPL'
600xAC                   eval      $saTrn#U = *on
600xAC                   eval      $saTrn# = lbtrn#
600xAC                   eval      $saETrn#U = *on
600xAC                   eval      $saETrn# = 0
600xAC                   eval      $saLbl#U = *on
600xAC                   eval      $saLbl# = lblbl#
600xAC                   eval      $saToLcnsU = *on
600xMC                   eval      $saToLcns = wuPulLcns
600xAC                   eval      $saToPosU = *on
600xMC                   eval      $saToPos = wuPulPos
600xAC                   eval      $saToVrfyU = *on
600xAC                   eval      $saToVrfy = 'N'
600xAC                   eval      $saToCodeu = *on
600xAC                   eval      $saToCode = 'S'
600xAC                   eval      $saToAreaU = *on
600xAC                   eval      $saToArea = 'Slot'
600xAC                   eval      $saFrmLcnsU = *on
600xAC                   eval      $saFrmLcns = wuUsrLcns
600xAC                   eval      $saOLcnsU = *on
600xAC                   eval      $saOLcns = wuPulOLcns
600xAC                   eval      $sapullwhdpu = *on
600xAC                   eval      $sapullwhdp  = wuPulWhdp
600xAC                   eval      $sapulldispu = *on
600xAC                   eval      $sapulldisp  = wuPulDisp
600xAC                   eval      $sapullbaseu = *on
600xAC                   eval      $sapullbase  = wuPulBase
600xAC                   eval      $sapulllcnsu = *on
600xAC                   eval      $sapulllcns  = wuPulLcns

720hAc                   if        $tpartial = *on
720hAc                   eval      $saUCIts = $tpartime
720hAc                   eval      $saUCItsU = *on
720hAc                   endif
600xA
416fAC                   eval      $dricommand = '*SLOT'
500pDC**                 eval      $drisubcmd = '%TFROUT'
600xDC**                 eval      $drisubcmd = '%TFROUTCHG'
600xMC                   eval      $drisubcmd = '%USR2PUT'
416fAC                   eval      chk4err = *off
416fAC                   eval      zmsflag = *off
416fAC                   exsr      zzzdricop
415hA*
610gAC                   exsr      zzwrkdel
610gA
415hAC                   else
415hA*
416sAC                   exsr      zzcls0
500dMC                   eval      curtrn# = pttrn#
500dMC                   exsr      zztrnclose
500hA
500wDC**                 exsr      zzzclr$lt210
500wDC**                 eval      $tcmd   = '*PULUNDO'
500wDC**                 eval      $twhse  = #fromslwhse
500wDC**                 eval      $tlic#  = curlic#
500wDC**                 exsr      zzzcall$lt210
415hAC                   endif
500wA
500wA*    Return quantity that was put into transit.
500wA
500wAC                   if        w2nqty > 0
501bAC                             and not sc2first
500wAC                   exsr      zzzclr$lt210
500wAC                   eval      $tcmd     = '*PUTAWYA'
500wAC                   eval      $tnexttask= 'PUTAWAY'
500wAC                   eval      $tlic#    = curlic#
500wAC                   eval      $tinlic#  = curlic#
500wAC                   eval      $toutlic# = curlic#
500wAC                   eval      $twhse    = #fromslwhse
500wAC                   eval      $twhdp    = #fromslwhdp
601dDC**                 eval      $tslot    = #fromsldisp
601dMC                   eval      $tslot    = #frombasesldsp
500wAC                   eval      $titem    = #fromslitem
500wAC                   eval      $titemdsc = #fromithead
500wAC                   eval      $tpartial = *off
500wAC                   eval      $tqty1    = exqty
500wAC                   eval      $tqty2    = 0
500wAC                   eval      $tqty3    = 0
500xAC                   eval      $tnorm1 = exqty
500xAC                   eval      $tnorm2 = 0
500xAC                   eval      $tnorm3 = 0
500wAC                   exsr      zzzcall$lt210
500wAC                   endif
500wA
500wA*      Return pallet(s) to slot (Already done for REPLBK).
500wAC
500wAC                   exsr      zzzclr$lt210
500wAC                   eval      $tcmd  = '*PULRTN'
500wAC                   eval      $twhse  = #fromslwhse
500wAC                   eval      $twhdp  = #fromslwhdp
601dDC**                 eval      $tslot  = #fromsldisp
601dMC                   eval      $tslot  = #frombasesldsp
500wAC                   eval      $titem  = #fromslitem
500wAC                   eval      $tlic#  = curlic#
500wAC                   eval      $titemdsc = #fromithead
500wAC                   exsr      zzzcall$lt210
     *
     *    Close letdowns as if they were completed.
     C                   other
415cA*
415cA*    Exception occured. Close letdown to zero.
415cA*
415cAC                   exsr      zzcls0
415cA*
500dMC                   eval      curtrn# = pttrn#
500dMC                   exsr      zztrnclose
500hA
500wDC**                 exsr      zzzclr$lt210
500wDC**                 eval      $tcmd   = '*PULUNDO'
500wDC**                 eval      $twhse  = #fromslwhse
500wDC**                 eval      $tlic#  = curlic#
500wDC**                 exsr      zzzcall$lt210
500wA
500wA*    Return quantity that was put into transit.
500wA
500wAC                   if        w2nqty > 0
501bAC                             and not sc2first
500wAC                   exsr      zzzclr$lt210
500wAC                   eval      $tcmd     = '*PUTAWYA'
500wAC                   eval      $tnexttask= 'PUTAWAY'
500wAC                   eval      $tlic#    = curlic#
500wAC                   eval      $tinlic#  = curlic#
500wAC                   eval      $toutlic# = curlic#
500wAC                   eval      $twhse    = #fromslwhse
500wAC                   eval      $twhdp    = #fromslwhdp
601dDC**                 eval      $tslot    = #fromsldisp
601dMC                   eval      $tslot    = #frombasesldsp
500wAC                   eval      $titem    = #fromslitem
500wAC                   eval      $titemdsc = #fromithead
500wAC                   eval      $tpartial = *off
500wAC                   eval      $tqty1    = exqty
500wAC                   eval      $tqty2    = 0
500wAC                   eval      $tqty3    = 0
500xAC                   eval      $tnorm1 = exqty
500xAC                   eval      $tnorm2 = 0
500xAC                   eval      $tnorm3 = 0
500wAC                   exsr      zzzcall$lt210
500wAC                   endif
500wA
500wA*      Return pallet(s) to slot (Already done for REPLBK).
500wAC
500wAC                   exsr      zzzclr$lt210
500wAC                   eval      $tcmd  = '*PULRTN'
500wAC                   eval      $twhse  = #fromslwhse
500wAC                   eval      $twhdp  = #fromslwhdp
601dDC**                 eval      $tslot  = #fromsldisp
601dMC                   eval      $tslot  = #frombasesldsp
500wAC                   eval      $titem  = #fromslitem
500wAC                   eval      $tlic#  = curlic#
500wAC                   eval      $titemdsc = #fromithead
500wAC                   exsr      zzzcall$lt210
     C                   endsl
     *
     *    Update dates in slot record.(To slot)
     *
     C                   select
     C                   when      error = *off
     C                   eval      excptn = *off
PFCaA
PFCaAc*    Call APT Interface.
PFCaAc                   if        logapt
PFCaAc*    Send Replenishment "Travel" record.
750cDc**                 eval      apcmd = aptsk3
750cDc**                 eval      aptrn# = LBTRN#
750cDc**                 eval      aplbl# = LBLBL#
750cDc**                 eval      aploc = LBDISP
750cDc**                 EXSR      ZZAPT
750cAc                   eval      apseq# += 1
750cAc                   exsr      clr$apt
tst  c****               eval      $apuser = 'ZZUPD4'
750cAC                   eval      $aplbl#  = lblbl#
750cAC                   eval      $aptrn#  = lbtrn#
750cAC                   eval      $aplocation = lbdisp
750cAC                   eval      $dricommand = '*APT'
750cAC                   eval      $drisubcmd  = aptsk_TRAVEL
750cAC                   eval      $drisys2upd = 'D'
750cAC                   eval      chk4err = *off
750cAC                   eval      zmsflag = *off
750cAC                   exsr      zzzdricop
PFCaAc                   ENDIF
     *
     *    Remove priority replenishment record.
     C                   if        rpltyp = '*PRIORTY'
     C     keypr2        chain     prplfil1                           7978
     C                   if        not *in79
414dAC                   eval      prflag = 'D'
414dMC                   update    prrec                                78
     C                   endif
     C                   endif
414gA*
414gA*    Removed unneeded replenishment transfer record.
414gAC                   if        crtrcd = *on
414gAC                   exsr      zzrmtf
414gAC                   endif
     *
415hAC                   eval      balexc = *off
     C                   eval      refrsh = *on
     C                   eval      w1tdis = *blanks
720aAC                   eval      w1lcns = *blanks
720aAC                   eval      w1scan = *blanks
     C                   eval      usrrpl = *off
     *
     C                   select
     *    Return to specific slot replenishment, otherwise find
     *    next transaction to process.
     C                   when      rpltyp = '*SPECIFC'
414fA*
414fA*    Start an 'IDLE' task, if no open task.
414fAC                   eval      curtrn = 0
414fAC                   eval      curtsk = *blanks
414fAC                   eval      curtyp = *blanks
414fAC                   eval      curent = *off
414fAC                   exsr      zztask
414fAC                   if        curent = *off
414fAC                   eval      w1task = 'IDLE  '
500dMC                   exsr      zztrnidle
414fAC                   endif

710fA*    If there's a JIT or priority repl for the from slot just used
710fA*    in specific slot replenishment, delete it.

710fAC                   exsr      zzdelrpl

710fA*    If option "Show JIT win during spec slot repl" equals N
710fA*    don't bother checking for JIT's as the user does not want
710fA*    the JIT notification window.
710fAC                   if        opjitw <> 'N'

710fA*    Before moving on to another specific slot repl, check for
710fA*    JIT repl's and if you find one, ask user if he wants to
710fA*    process the JIT/s instead of continuing on with specific
710fA*    slot replenishment.

710fAC                   eval      chknew = *on
710fAC                   eval      bypass = *off
710fAC                   eval      prptyp = '*IMMED  '
710fAC                   exsr      zznext
710f  **                 if        done = *off
710fAC                   exsr      scr11i
710fAC                   goto      endup4
710f  **                 endif

710fAC                   endif

600qA*
600qA*    Interleaving replenishment in progress,
600qA*    return to putaway program.
600qaC                   if        $scmd = '*INTERLV'
600qAC                   eval      nxtscr = 'EOJ'
600qAC                   eval      $srtn = '*CANCEL '
600qAC                   else
     C                   exsr      scr01i
600qAC                   endif
600qA*
     *
415cA*    User had exception on letdown - direct user to slot list
415cA*    display so they can create a specific slot replenishment.
600qDC*                  when      rpltyp = '*LETDOWN'  or
600qMC                   when      rpltyp = '*LETDOWN'  and
600qaC                             $scmd <> '*INTERLV'  or
600qDC*                            rpltyp = '*PRIORTY'
600qMC                             rpltyp = '*PRIORTY' and
600qaC                             $scmd <> '*INTERLV'
415cA*
415cA*    Start an 'IDLE' task, if no open task.
415cAC                   eval      curtrn = 0
415cAC                   eval      curtsk = *blanks
415cAC                   eval      curtyp = *blanks
415cAC                   eval      curent = *off
415cAC                   exsr      zztask
415cAC                   if        curent = *off
415cAC                   eval      w1task = 'IDLE  '
500dMC                   exsr      zztrnidle
415cAC                   endif
415cA*
500dMC                   eval      w1tdis = #picksldisp
415cAC                   exsr      zzchk1
415cAC                   exsr      zzspfc
415cA*
     C                   other
600qA*
600qA*    Interleaving replenishment in progress,
600qA*    return to putaway program.
600qaC                   if        $scmd = '*INTERLV'
600qAC                   eval      nxtscr = 'EOJ'
600qAC                   eval      $srtn = '*CANCEL '
600qAC                   else
     *    Find next letdown for user, no longer prompt to continue.
     C                   exsr      zzupd1
600qAC                   endif
600qA*
     C                   endsl
     *
     *    Errors occured during close - re-display screen with error.
     C                   when      error = *on
     C                   exsr      scr04i
     C                   endsl
414eA*
     C                   when      w4qty = 'Y'  and
414eAC                             balexc = *off
     *
     C                   endsl
     *
     C     endup4        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD5   Update for screen 5.
     *
     C     zzupd5        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
415gAC                   select
500dMC                   when      #fromslvirt ='Y' and
     C                             w5zero = 'Y'
     C                   eval      exerid = 'VRTSLT '
     C                   eval      exqty = *zeros
     C                   exsr      zzexcp
415gA*
415gA*    User said slot was not empty and system thinks it is.
500dMC                   when      #fromslvirt = 'N'  and
415gAC                             w5zero = 'N'
415gAC                   eval      exerid = 'NOTEMTY'
415gAC                   eval      exqty = *zeros
415gAC                   exsr      zzexcp
415gMC                   endsl
     *
     C                   eval      wozero = w5zero
     C                   exsr      scr03i
     C     endup5        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD6   Update for screen 06.
     *
     C     zzupd6        begsr
     *
     C                   exsr      scr07i
     *
     C     endup6        endsr

500fA*----------------------------------------------------------------
500fA*  ZZUPD7   Update for screen 07.
500fA*----------------------------------------------------------------
500fA
500fAC     zzupd7        begsr
     C                   eval      error = *off

     C                   eval      w1tdis = *blanks
720aAC                   eval      w1lcns = *blanks
720aAC                   eval      w1scan = *blanks
     C                   eval      usrrpl = *off
     C                   eval      bypass = *off
530 AC                   eval      savseq = 0
     C                   eval      wkrtpo = '0'

     *    Load SCREEN1 fields with SCREEN7 values.

     C                   eval      w1whse = w7whse
     C                   eval      w1whdp = w7whdp

417kA*   Check if warehouse changed. If yes, get all new options.

417kAC                   if        w7whse <> svwhse
417kAC                   eval      svwhse = w7whse
417kAC                   eval      kywhse = w7whse

415lA*    Check for putaway option - Manual or directed.

415lAC                   eval      kydwhs = w7whse
415lAC                   eval      kydwdp = w7whdp
415lAC                   exsr      zzrtno

     *    Check installed feature level.

     C                   eval      kywhse = w7whse
     C                   exsr      zzfeat

417kAC                   endif

417eAC                   select

500 M*    FlowRack / Breakdown replenishments.

500 MC                   when      w7rplt = 'F'  or
510dAC                             w7rplt = 'R'  or
730bMC                             w7rplt = 'D'  or
730bMC                             w7rplt = 'O'  or
720bAC                             w7rplt = 'S'  or
500 MC                             w7rplt = 'B'

417eAC                   eval      $lcmd = '*STRPPR '
417eAC                   eval      $lwhse = w7whse
417eAC                   eval      $lwhdp = w7whdp
500kDC**                 eval      $lfas = w7fas
500kMC                   eval      $lfas = frmasl
500kDC**                 eval      $ltas = w7tas
500kMC                   eval      $ltas = toaisl
417eAC                   eval      $lrplt = w7rplt
500sAC                   eval      $lside = w7side

417eAC                   call      'LT107'
417eAC                   parm                    $lparm
650fAc                   eval      $lprg = #prog
500fA
500fA*      See if user wants to go to Specific Slot Replenishments
500fA
500fAC                   if        $lrtn = '*SSRPL'
500fAC                   eval      refrsh = *on
500fAC                   eval      w1tdis = *blanks
720aAC                   eval      w1lcns = *blanks
720aAC                   eval      w1scan = *blanks
500fAC                   eval      usrrpl = *off
500fAC                   exsr      scr01i
500fAC                   eval      rtnto = 'LETDOWN '
500fAC                   goto      endup7
500fAC                   endif

417eA*    All other replenishments. (Normal)

417eAC                   other

416sAC     keypr1        setll     prplfil1
600fAC                   eval      prptyp = '*IMMED  '
     C                   exsr      zzupd1
     C     error         cabeq     *on           endup7

417eAC                   endsl

     C     endup7        endsr
     *
650bA*----------------------------------------------------------------
650bA*  ZZUPD7ALL   Update for screen 07 when user selects ALL for
650bA*              replenishment type and/or department.
650bA*----------------------------------------------------------------
650bA
650bAC     zzupd7ALL     begsr
650bA
     C                   eval      error = *off

     C                   select
     C                   when      w7rplt <> 'A' and
     C                             w7rplt <> 'N'
     C                   eval      wkrplt = w7rplt
     C                   endsl

     C                   if        w7whdp = '*ALL '
     C                   eval      allDepts = *on
     C                   endif

     C     w1whse        setll     prplfil10
     C                   dow       forever = forever
     C     w1whse        reade     prplfil10
     C                   unlock    prplfil10

710hDC*                  if        %eof
710hMC                   if        %eof(prplfil10)
     C                   leave
     C                   endif

     C                   if        w7rplt <> 'A' and
     C                             wkrplt <> prrplt
710hAC                             or prflag = 'D'
     C                   iter
     C                   endif

750e  *    Skip if not in selected alsiel range.
750eAC                   if        frmasl <> *blanks and
750eAC                             toaisl <> *blanks
750eAC                   if        (prfail < frmasl  or
750eAC                             prfail > toaisl) or
750eAC                             (prtail < frmasl or
750eAC                             prtail > toaisl)
750eAC                   iter
750eAC                   endif
750eAC                   endif

     C                   if        allDepts = *off and
     C                             w7whdp <> prwhdp
     C                   iter
     C                   endif

     C                   if        allDepts = *on
     C                   eval      w7whdp = prwhdp
     C                   endif

     C                   if        w7rplt = 'A'
     C                   eval      wkrplt = prrplt
     C                   endif

     C                   eval      w1tdis = *blanks
720aAC                   eval      w1lcns = *blanks
720aAC                   eval      w1scan = *blanks
     C                   eval      usrrpl = *off
     C                   eval      bypass = *off
     C                   eval      savseq = 0
     C                   eval      wkrtpo = '0'

     *    Load SCREEN1 fields with SCREEN7 values.

     C                   eval      w1whse = w7whse
     C                   eval      w1whdp = w7whdp

     *   Check if warehouse changed. If yes, get all new options.

     C                   if        w7whse <> svwhse
     C                   eval      svwhse = w7whse
     C                   eval      kywhse = w7whse

     *    Check for putaway option - Manual or directed.

     C                   eval      kydwhs = w7whse
     C                   eval      kydwdp = w7whdp
     C                   exsr      zzrtno

     *    Check installed feature level.

     C                   eval      kywhse = w7whse
     C                   exsr      zzfeat

     C                   endif

     C                   select

     *    FlowRack / Breakdown replenishments.

     C                   when      wkrplt = 'F'  or
     C                             wkrplt = 'R'  or
730bMC                             w7rplt = 'D'  or
730bMC                             w7rplt = 'O'  or
720bAC                             w7rplt = 'S'  or
     C                             wkrplt = 'B'

     C                   eval      $lcmd = '*STRPPR '
     C                   eval      $lwhse = w7whse
     C                   eval      $lwhdp = w7whdp
     C                   eval      $lfas = frmasl
     C                   eval      $ltas = toaisl
     C                   eval      $lrplt = wkrplt
     C                   eval      $lside = w7side

     C                   call      'LT107'
     C                   parm                    $lparm
650fAc                   eval      $lprg = #prog

     C                   iter

     *    All other replenishments. (Normal)

     C                   other

     C     keypr1        setll     prplfil1
     C                   eval      prptyp = '*IMMED  '
     C                   exsr      zzupd1
     C                   leave

     C                   endsl

     C                   enddo

     C     endup7All     endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD8   Update for screen 8.
     *
     C     zzupd8        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
     C                   eval      w8balq = w8balq - w8nqty
500cA*
     C                   select
     *
     *    Product is allocated - must go back to original slot.
     *
     C                   when      rtnhom = *on
500vA
500vA*  Note: We don't do a PUTAWYB because we are putting the qty back
500vA*        where it came from and are assuming that it is physically
500vA*        being put back where it came from (i.e. same pallet pos).
500vA*        Therefore, we do not want to ask the user any questions.
500mDC**
500mDC**   Call license tracking for putaway - Before update
500mDC**
500mDC**                 exsr      zzzclr$lt210
500mDC**                 eval      $tcmd  = '*PUTAWYB'
500mDC**                 eval      $tlic#  = curlic#
500mDC**                 if        w8balq > 0
500mDC**                 eval      $tpartial = *on
500mDC**                 else
500mDC**                 eval      $tpartial = *off
500mDC**                 endif
500mDC**                 eval      $twhse  = #ovrfslwhse
500mDC**                 eval      $twhdp  = #ovrfslwhdp
500mDC**                 eval      $tslot  = #ovrfsldisp
500mDC**                 eval      $titem  = #ovrfslitem
500mDC**                 eval      $titem  = #fromslitem
500mDC**                 eval      $titemdsc = #fromithead
500mDC**                 exsr      zzzcall$lt210
500cA*
500mDC**                 select
500mDC**                 when      $treturn = '*CANCEL'
500mDC**                 goto      endup8
500mDC**                 when      $treturn <> '*OK'
500mDC**                 eval      error = *on
500mDC**                 eval      *in21 = *on
500mDC**                 eval      *in01 = *on
500mDC**                 goto      endup8
500mDC**                 endsl
500dA
500dA*    Since we are going back to the From slot we only need to do
500dA*    a TFROUT. No sense in doing an TFROUT and then a TFRIN.
500dA
500dAC                   exsr      clr$slot
500dAC                   eval      $slwhseu = *on
500dAC                   eval      $slwhse  = #fromslwhse
500dAC                   eval      $slwhdpu = *on
500dAC                   eval      $slwhdp  = #fromslwhdp
500dAC                   eval      $sldispu = *on
601dMC                   eval      $sldisp  = #frombasesldsp
601dDC**                 eval      $sldisp  = #fromsldisp
500dAC                   eval      $saitemu = *on
500dAC                   eval      $saitem  = #fromslitem
600uAC                   eval      $sacwhdu = *on
600uAC                   eval      $sacwhd  = wuUsrWhdp
600uAC                   eval      $sacdspu = *on
600uAC                   eval      $sacdsp  = wuUsrDisp
500pAC                   eval      $sacitemu = *on
500pAC                   eval      $sacitem  = #fromslitem
500dAC                   eval      $satrn#u = *on
500dAC                   eval      $satrn# = lbtrn#
500dAC                   eval      $satasku = *on
500dAC                   eval      $satask = pttask
500dAC                   eval      $saqtyu = *on
500mDC**                 eval      $saqty1 = 0
600uDC**                 eval      $saqty1 = -(w8nqty)
600uMC                   eval      $saqty1 = w8nqty
500dAC                   eval      $saqty2 = 0
500dAC                   eval      $saqty3 = 0
500mDC**                 eval      $saorgu = *on
500mDC**                 eval      $saorg1 = w8nqty
500mDC**                 eval      $saorg2 = 0
500mDC**                 eval      $saorg3 = 0
600uA
600uAC                   eval      $saActionU = *on
600uAC                   eval      $saAction = 'RPL'
600uAC                   eval      $saTrn#U = *on
600uAC                   eval      $saTrn# = lbtrn#
600uAC                   eval      $saETrn#U = *on
600uAC                   eval      $saETrn# = 0
600uAC                   eval      $saLbl#U = *on
600uAC                   eval      $saLbl# = lblbl#
600uAC                   eval      $saToLcnsU = *on
600wDC**                 eval      $saToLcns = wuUsrLcns
600wMC                   eval      $saToLcns = wuPulLcns
600uAC                   eval      $saToPosU = *on
600wDC**                 eval      $saToPos = $tslotpos
600wMC                   eval      $saToPos = wuPulPos
600uAC                   eval      $saToVrfyU = *on
600uAC                   eval      $saToVrfy = 'N'
600uAC                   eval      $saToCodeu = *on
600uAC                   eval      $saToCode = 'S'
600uAC                   eval      $saToAreaU = *on
600uAC                   eval      $saToArea = 'Slot'
600uAC                   eval      $saFrmLcnsU = *on
600uAC                   eval      $saFrmLcns = wuUsrLcns
600uAC                   eval      $saOLcnsU = *on
600uAC                   eval      $saOLcns = wuPulOLcns
600wAC                   eval      $sapullwhdpu = *on
600wAC                   eval      $sapullwhdp  = wuPulWhdp
600vAC                   eval      $sapulldispu = *on
600vAC                   eval      $sapulldisp  = wuPulDisp
600vAC                   eval      $sapullbaseu = *on
600vAC                   eval      $sapullbase  = wuPulBase
600vAC                   eval      $sapulllcnsu = *on
600vAC                   eval      $sapulllcns  = wuPulLcns

640iAC                   eval      $saexcdU = *on
640iAC                   eval      $saexcd  = 'RTNORIG'

720hAc                   if        $tpartial = *on
720hAc                   eval      $saUCIts = $tpartime
720hAc                   eval      $saUCItsU = *on
720hAc                   endif
600uA
416fAC                   eval      $dricommand = '*SLOT'
500mDC**                 eval      $drisubcmd = '%CLSTFROUT'
500pDC**                 eval      $drisubcmd = '%TFROUT'
600uDC**                 eval      $drisubcmd = '%TFROUTCHG'
600uMC                   eval      $drisubcmd = '%USR2PUT'
500jDC**                 eval      chk4err = *off
500jMC                   eval      chk4err = *on
500dAC                   eval      zmsflag = *off
500dAC                   exsr      zzzdricop
500jDC**                 if        error
500jMC                   if        drierr
500jAC                   eval      error = *on
500cAC                   eval      *in21 = *on
500cAC                   eval      *in01 = *on
500cAC                   goto      endup8
500cAC                   endif
415tA*
     C     svrplb        chain     label                              79
     C                   if        not *in79
500wDC**                 eval      lbasl2 = #ovrfslaisl
500wDC**                 eval      lbloc2 = #ovrfslloc
500wDC**                 eval      lblvl2 = #ovrfslrlvl
500wDC**                 eval      lbhnd2 = #ovrfslhand
500wDC**                 eval      lbdsp2 = #ovrfsldisp
500wMC                   eval      lbasl2 = #fromslaisl
500wMC                   eval      lbloc2 = #fromslloc
500wMC                   eval      lblvl2 = #fromslrlvl
500wMC                   eval      lbhnd2 = #fromslhand
500wMC                   eval      lbdsp2 = #fromsldisp
500qAC                   exsr      zzgetdatetime
500qAC                   eval      lbstat = 'C'
500qAC                   eval      lbsdte = curdate
500qAC                   eval      lbstim = curtime
     C                   update    lbrec
     C                   endif
417cA*
500bM*    Call license tracking for putaway - After update
500wA
500wA*  Note: Since we didn't call PUTAWYB, we need to fill in a few
500wA*        extra parameters.
500bA*
500wAC                   eval      $tcmd  = '*PUTAWYA'
500wAC                   eval      $tnexttask= 'PUTAWAY'
500wAC                   eval      $tlic#  = curlic#
500wAC                   eval      $tinlic#  = curlic#
500wAC                   eval      $toutlic# = curlic#
500wAC                   eval      $tpartial = *off
500wAC                   eval      $twhse  = #fromslwhse
500wAC                   eval      $twhdp  = #fromslwhdp
601dDC**                 eval      $tslot  = #fromsldisp
601dMC                   eval      $tslot  = #frombasesldsp
500wAC                   eval      $titem  = #fromslitem
500wAC                   eval      $titemdsc = #fromithead
500wAC                   select
500wAC                   when      lbutyp = 'N'
500wAC                   eval      $tqty1 = w8nqty
500wAC                   when      lbutyp = '1'
500wAC                   eval      $tqty2 = w8nqty
500wAC                   when      lbutyp = '2'
500wAC                   eval      $tqty3 = w8nqty
500wAC                   endsl
500wAC                   exsr      zzzcall$lt210
500mA
500mA*    Then tell user to put back any pulled pallets.
500mA*         and move on to the putaway process.
500mA
500mAC                   exsr      zzzclr$lt210
500mAC                   eval      $tcmd  = '*PULRTN'
500mAC                   eval      $twhse  = #fromslwhse
500mAC                   eval      $twhdp  = #fromslwhdp
601dDC**                 eval      $tslot  = #fromsldisp
610dMC                   eval      $tslot  = #frombasesldsp
500mAC                   eval      $titem  = #fromslitem
500mAC                   eval      $titemdsc = #fromithead
600uAC                   eval      $tlic# = #fromsaToLcns
500mDC                   exsr      zzzcall$lt210
500mAC                   if        $treturn <> '*OK'
500mAC                   endif
600uA
600uA*    Delete workusr record.
600uA
600uAC                   exsr      zzwrkdel
500bA*
     *    Update quantity in transaction record.
     C     ptkey         chain(n)  pirtran                            79
     *    Update quantity in transaction record.
500dMC                   eval      curtrn# = pttrn#
500dMC                   exsr      zztrnclose
     C                   select
     C                   when      error = *off
PFCaA
PFCaAc*    Call APT Interface.
PFCaAc                   if        logapt
PFCaAc*    Send Replenishment "End" record.
750cDc**                 eval      apcmd = aptsk4
750cDc**                 eval      aptrn# = LBTRN#
750cDc**                 eval      aplbl# = LBLBL#
750cDc**                 eval      aploc = W8SCAN
750cDc**                 EXSR      ZZAPT
750cAc                   eval      apseq# += 1
750cAc                   exsr      clr$apt
tst  c****               eval      $apuser = 'ZZUPD8'
750cAC                   eval      $aplbl#  = lblbl#
750cAC                   eval      $aptrn#  = lbtrn#
750cAC                   eval      $aplocation = w8scan
750cAC                   eval      $dricommand = '*APT'
750cAC                   eval      $drisubcmd  = aptsk_END
750cAC                   eval      $drisys2upd = 'D'
750cAC                   eval      chk4err = *off
750cAC                   eval      zmsflag = *off
750cAC                   exsr      zzzdricop
PFCaAc                   ENDIF
PFCaA
414eAC                   eval      lstslt = w8scan
     *    Get next transaction for user.
     *
     *    When user is specific slot replenishment mode,
     *    take them back.  Otherwise, find next letdown or
     *    priority replenishment.
     *
     C                   select
     C                   when      rpltyp = '*SPECIFC'
414fA*
414fA*    Start an 'IDLE' task, if no open task.
414fAC                   eval      curtrn = 0
414fAC                   eval      curtsk = *blanks
414fAC                   eval      curtyp = *blanks
414fAC                   eval      curent = *off
414fAC                   exsr      zztask
414fAC                   if        curent = *off
414fAC                   eval      w1task = 'IDLE  '
500dMC                   exsr      zztrnidle
414fAC                   endif
600qA*
600qAC                   select
600qA*    Interleaving replenishment complete. Return to Putaway pgm.
600qAC                   when      $scmd = '*INTERLV'
600qAC                   eval      nxtscr = 'EOJ'
600qAC                   eval      $srtn = '*RPLDONE'
600qA*
600qAC                   other
     C                   exsr      scr01i
600qAC                   endsl
     *
     C                   other
600qAC                   select
600qA*    Interleaving replenishment complete. Return to Putaway pgm.
600qAC                   when      $scmd = '*INTERLV'
600qAC                   eval      nxtscr = 'EOJ'
600qAC                   eval      $srtn = '*RPLDONE'
600qA*
600qA*    Start an 'IDLE' task, if no open task.
600qAC                   eval      curtrn = 0
600qAC                   eval      curtsk = *blanks
600qAC                   eval      curtyp = *blanks
600qAC                   eval      curent = *off
600qAC                   exsr      zztask
600qAC                   if        curent = *off
600qAC                   eval      w1task = 'IDLE  '
600qAC                   exsr      zztrnidle
600qAC                   endif
600qA*
600qAC                   other
600fAC                   eval      prptyp = '*IMMED  '
     C                   exsr      zzupd1
600qAC                   endsl
600qA*
     C                   endsl
     *
     C                   when      error = *on
     C                   exsr      scr08i
     C                   endsl
     *
     C                   other
     *    Process slot scanned by user. Put excess product away.
     C                   exsr      zzpawy
     *
     C                   endsl

710g *            Now allow JIT screen to appear if F7 was used
710gAC                   select
710gAC                   when      rpltyp = '*SPECIFC'  and
710gAC                             w8balq = 0
     *
710fA*    If there's a JIT or priority repl for the from slot just used
710fA*    in specific slot replenishment, delete it.

710fAC                   exsr      zzdelrpl

710fA*    If option "Show JIT win during spec slot repl" equals N
710fA*    don't bother checking for JIT's as the user does not want
710fA*    the JIT notification window.
710fAC                   if        opjitw <> 'N'

710fA*    Before moving on to another specific slot repl, check for
710fA*    JIT repl's and if you find one, ask user if he wants to
710fA*    process the JIT/s instead of continuing on with specific
710fA*    slot replenishment.

710fAC                   eval      chknew = *on
710fAC                   eval      bypass = *off
710fAC                   eval      prptyp = '*IMMED  '
710fAC                   exsr      zznext
710f  **                 if        done = *off
710fAC                   exsr      scr11i
710fAC                   goto      endup8
710f  **                 endif

710fAC                   endif
710gAC                   endsl
     *
     C     endup8        endsr
417cA*
417cA*----------------------------------------------------------------
417cA*
417cA*  ZZUPD9   Update for screen 9.
417cA*
417cAC     zzupd9        begsr
417cAC                   eval      error = *off
417cA*
417cA*
417cAC                   exsr      scr08i
417cAC     endup9        endsr
600uA
640bA*----------------------------------------------------------------
640bA*
640bA*  ZZUPD6a  Update for screen 6a.
640bA*
640bAC     zzupd6a       begsr
640bA*
640bAC                   eval      nxtscr = '07 '
640bAC                   eval      prptyp = '*NORMAL '
640bAC                   exsr      zzupd1
640bA*
640bAC     endup6a       endsr
640bA
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZUPD11  Update for screen 11.
650bA*
650bAC     zzupd11       begsr
650bAC                   eval      error = *off
650bA*
650bAC                   if        w11jit = 'Y'
650bAC                   eval      nxtscr = '07 '
650bAC                   eval      prptyp = '*IMMED  '
650bAC                   eval      wkrtpo = '0'
650bAC                   exsr      zzupd1
650bA*
650bAC                   else
650bA*
650bA*    Start an 'IDLE' task, if no open task.
650bA*
650bAC                   eval      nxtscr = '01 '
650bAC                   eval      curtrn = 0
650bAC                   eval      curtsk = *blanks
650bAC                   eval      curtyp = *blanks
650bAC                   eval      curent = *off
650bAC                   exsr      zztask
650bAC                   if        curent = *off
650bAC                   eval      w1task = 'IDLE  '
650bAC                   exsr      zztrnidle
650bAC                   endif
650bAC                   exsr      scr01i
650bAC                   endif
650bA*
650bAC     endup11       endsr

600uA*----------------------------------------------------------------
600uA*  ZZWRKADD   Add record to workusr file
600uA*----------------------------------------------------------------
600uA*
600uAC     zzwrkadd      begsr

     C                   exsr      zzgetcurrstamp

     C                   eval      wurectype = 'RPL'
     C                   eval      wuscannbr = #fromsaToLcns
     C                   eval      wuscantype = 'P'
     C                   eval      wutrn#    = lbtrn#
     C                   eval      wulbl#    = lblbl#
     C                   eval      wustat    = ' '
     C                   eval      wuwhse    = #fromslwhse

     C                   eval      wupulitem = #fromslitem
     C                   eval      wunewitem = #pickslitem

     C                   eval      wuremqty1 = w2nqty
     C                   eval      wuremqty2 = 0
     C                   eval      wuremqty3 = 0

     C                   eval      wupullcns  = #fromsaToLcns
     C                   eval      wupulolcns = #fromsaOLcns
     C                   eval      wupulwhdp  = #fromslwhdp
600vAC                   eval      wupulbase  = #frombasesldsp
     C                   eval      wupuldisp  = #fromsldisp
     C                   eval      wupulaisl  = #fromslaisl
     C                   eval      wupulloc   = #fromslloc
     C                   eval      wupulrlvl  = #fromslrlvl
     C                   eval      wupulhand  = #fromslhand
     C                   eval      wupulcode  = 'S'
     C                   eval      wupularea  = 'Slot'
     C                   eval      wupulpos   = $tslotpos
     C                   eval      wupulpseq  = #fromslpseq
     C                   eval      wupulside  = #fromslside
     C                   eval      wupulutype = lbutyp
600zAC                   eval      wupulvfy   = $saFrmEmpty

600wDC**                 eval      wuusrlcns  = $tinlic#
600wMC                   eval      wuusrlcns  = $saToLcns
     C                   eval      wuusrwhdp  = $slwhdp
     C                   eval      wuusrdisp  = $sldisp

     C                   eval      wupckwhdp  = #pickslwhdp
     C                   eval      wupckdisp  = #picksldisp
     C                   eval      wupckaisl  = #pickslaisl
     C                   eval      wupckloc   = #pickslloc
     C                   eval      wupckrlvl  = #pickslrlvl
     C                   eval      wupckhand  = #pickslhand
     C                   eval      wupckcode  = 'S'
     C                   eval      wupckarea  = 'Slot'
     C                   eval      wupckpos   = 0
     C                   eval      wupckpseq  = #pickslpseq
     C                   eval      wupckside  = 0
     C                   eval      wupckutype = ' '

     C                   eval      wurtnhome  = rtnhom
     C                   eval      wurpltype  = ' '

     C                   eval      wuaddts  = currstampsys
     C                   eval      wuadduc  = currstampuc
     C                   eval      wuaddpgm = #pgm
     C                   eval      wuaddemp = #emp#
     C                   eval      wuaddeusr = #curruser
     C                   eval      wuaddjusr = #user
     C                   eval      wuaddjob = #job
     C                   eval      wuaddnbr = #jobnbr

     C                   write(e)  wurec3

     C                   endsr
600uA
600uA*----------------------------------------------------------------
600uA*  zzwrkdel   Delete work file record
600uA*----------------------------------------------------------------
600uA
600uAC     zzwrkdel      begsr

     C                   eval      kywhse = #fromslwhse
     C                   eval      kywhdp = #fromslwhdp
     C                   eval      kydisp = #fromsldisp

     C     keywu3        chain(e)  workusr3

     C                   if        %found(workusr3)
     C                   delete    wurec3
     C                   endif

640cAC                   if        wozero = 'Y'
640cAC                   exsr      zzzero
640cAC                   endif

     C                   endsr
600uA
600uA*----------------------------------------------------------------
600uA*  zzwrkinz   Delete existing work records for user.
600uA*             Don't try to put anything back.
600uA*----------------------------------------------------------------
600uA
600uAC     zzwrkinz      begsr
     *
     C     keywu3p       setll     workusr3
     C                   dow       forever = forever
     C     keywu3p       reade     workusr3
     C                   if        %eof(workusr3)
     C                   leave
     C                   endif
     C                   delete    wurec3
     C                   enddo

     C                   endsr
600uA
600uA*----------------------------------------------------------------
600uA*  zzwrkupd3  Update work file record
600uA*----------------------------------------------------------------
600uA
600uAC     zzwrkupd3     begsr

     C                   eval      kywhse = #fromslwhse
     C                   eval      kywhdp = #fromslwhdp
     C                   eval      kydisp = #fromsldisp

     C     keywu3        chain(e)  workusr3

     C                   eval      wulbl# = lblbl#
     C                   eval      wutrn# = pttrn#

     C                   eval      wuremqty1 = w3balq

     C                   eval      wuusrlcns = $toutlic#

     C                   update    wurec3

     C                   endsr
600uA
600uA*----------------------------------------------------------------
600uA*  zzwrkupd8  Update work file record
600uA*----------------------------------------------------------------
600uA
600uAC     zzwrkupd8     begsr

     C                   eval      kywhse = #fromslwhse
     C                   eval      kywhdp = #fromslwhdp
     C                   eval      kydisp = #fromsldisp

     C     keywu3        chain(e)  workusr3

     C                   eval      wulbl# = lblbl#
     C                   eval      wutrn# = pttrn#

     C                   eval      wuremqty1 = w8balq

     C                   eval      wuusrlcns = $toutlic#

     C                   update    wurec3

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZZERO   Verify zero slots.
     *
     C     zzzero        begsr

500dAC                   exsr      clr$slot
500dAC                   eval      $slwhseu = *on
500dAC                   eval      $slwhse  = #fromslwhse
500dAC                   eval      $slwhdpu = *on
500dAC                   eval      $slwhdp  = #fromslwhdp
500dAC                   eval      $sldispu = *on
500dAC                   eval      $sldisp  = #fromsldisp
500dA
500dAC                   eval      $dricommand = '*SLOT'
500dAC                   eval      $drisubcmd  = '%ZEROVFY'
500dAC                   eval      $drisys2upd = 'D'
500dAC                   exsr      zzzdricop
500dAC                   if        error
500dAC                   eval      error = *off
500dAC                   endif
     *
     C     endzro        endsr
     *

     *----------------------------------------------------------------
     *  sortrpl  Sort (sequence) replenishments
     *----------------------------------------------------------------

     C     sortrpl       begsr

     C                   exsr      clr$prtyrpl
     C                   eval      $prwhseu = *on
     C                   eval      $prwhse  = $iWhse

     C                   eval      $dricommand = '*PRTYRPL'
     C                   eval      $drisubcmd  = '*SEQPRTRPL'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     C                   endsr

500dA*----------------------------------------------------------------
500dA*----------------------------------------------------------------
500dA*                     DRI SUBROUTINES
500dA*----------------------------------------------------------------
500dA*----------------------------------------------------------------

750cA*----------------------------------------------------------------
750cA*  clr$apt   Clear $apt data structure fields
750cA*----------------------------------------------------------------
750cA
750cAC     clr$apt       begsr
     C                   eval      savever# = $apver#
     C                   clear                   $aptds
     C                   eval      $apver# = savever#
     C                   eval      $apuser = #user
     C                   eval      $apjob  = #job
     C                   eval      $apjobn = #jobnbr
     C                   eval      $apwhseu = *on
     C                   eval      $apwhse  = w1whse
     C                   eval      $apemp#u = *on
     C                   eval      $apemp#  = #emp#
     C                   eval      $apseq#u = *on
     C                   eval      $apseq#  = apseq#
     C                   eval      $aplbl#u = *on
     C                   eval      $aptrn#u = *on
     C                   eval      $aplocationu = *on
     C                   eval      $aprteidu = *on
     C                   eval      $aprte    = *on
     C                   endsr

500dA*----------------------------------------------------------------
500dA*  clr$item  Clear $item data structure fields
500dA*----------------------------------------------------------------
500dA
500dAC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
600tAC                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr
720bA
720bA*----------------------------------------------------------------
720bA*  clr$prtyrpl  Clear $prtyrpl data structure fields
720bA*----------------------------------------------------------------
720bA
720bAC     clr$prtyrpl   begsr
720bAC                   eval      savever# = $prver#
720bAC                   clear                   $prtyrpl
720bAC                   eval      $prver# = savever#
720bAC                   endsr

500dA*----------------------------------------------------------------
500dA*  clr$slot  Clear $slot data structure fields
500dA*----------------------------------------------------------------
500dA
500dAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
600uAC                   clear                   $slot2
     C                   eval      $slver# = savever#
600uAC                   eval      $saemp#U = *on
600uAC                   eval      $saemp# = #emp#
     C                   endsr

500dA*----------------------------------------------------------------
500dA*  clr$slotdef  Clear $slotdef data structure fields
500dA*----------------------------------------------------------------
500dA
500dAC     clr$slotdef   begsr
     C                   eval      savever# = $sdver#
     C                   clear                   $slotdef
     C                   eval      $sdver# = savever#
     C                   endsr
500dA
500dA*----------------------------------------------------------------
500dA*  zzzcvtsubcmd   Convert drisubcmd.
500dA*----------------------------------------------------------------
500dA
500dAC     zzzcvtsubcmd  begsr

500dA*  Convert $drisubcmd based on replenishment type.

416sAC                   select

500dA*    Priority Replenishment

416sAC                   when      rpltyp = '*PRIORTY'
416sAC                   select
500dAC                   when      $drisubcmd = '%CLSTFRIN'
500dAC                   eval      $drisubcmd = '%CLSPRIN'
500dAC                   when      $drisubcmd = '%CLSTFROUT'
500dAC                   eval      $drisubcmd = '%CLSPROUT'
500dAC                   when      $drisubcmd = '%CLSTFICHG'
500dAC                   eval      $drisubcmd = '%CLSPRICHG'
500dAC                   when      $drisubcmd = '%CLSTFOCHG'
500dAC                   eval      $drisubcmd = '%CLSPROCHG'
416fAC                   when      $drisubcmd = '%TFRIN'
416fAC                   eval      $drisubcmd = '%PRIN'
416fAC                   when      $drisubcmd = '%TFRINCHG'
416fAC                   eval      $drisubcmd = '%PRINCHG'
416fAC                   when      $drisubcmd = '%TFROUT'
416fAC                   eval      $drisubcmd = '%PROUT'
416fAC                   when      $drisubcmd = '%TFROUTCHG'
416fAC                   eval      $drisubcmd = '%PROUTCHG'
500dAC                   when      $drisubcmd = '%VERIFYTFI'
500dAC                   eval      $drisubcmd = '%VERIFYPRI'
500dAC                   when      $drisubcmd = '%VFYTFICHG'
500dAC                   eval      $drisubcmd = '%VFYPRICHG'
500dAC                   when      $drisubcmd = '%VFYTFOCHG'
500dAC                   eval      $drisubcmd = '%VFYPROCHG'
500dAC                   when      $drisubcmd = '%VFYCLSTFI'
500dAC                   eval      $drisubcmd = '%VFYCLSPRI'
500dAC                   when      $drisubcmd = '%VFYCLSTFO'
500dAC                   eval      $drisubcmd = '%VFYCLSPRO'
415pAC                   endsl

500dA*    Specific Slot Replenishment

     C                   when      rpltyp = '*SPECIFC'
416sAC                   select
500dAC                   when      $drisubcmd = '%CLSTFRIN'
500dAC                   eval      $drisubcmd = '%CLSSSIN'
500dAC                   when      $drisubcmd = '%CLSTFROUT'
500dAC                   eval      $drisubcmd = '%CLSSSOUT'
500dAC                   when      $drisubcmd = '%CLSTFICHG'
500dAC                   eval      $drisubcmd = '%CLSSSICHG'
500dAC                   when      $drisubcmd = '%CLSTFOCHG'
500dAC                   eval      $drisubcmd = '%CLSSSOCHG'
416fAC                   when      $drisubcmd = '%TFRIN'
416fAC                   eval      $drisubcmd = '%SSIN'
416fAC                   when      $drisubcmd = '%TFRINCHG'
416fAC                   eval      $drisubcmd = '%SSINCHG'
416fAC                   when      $drisubcmd = '%TFROUT'
416fAC                   eval      $drisubcmd = '%SSOUT'
416fAC                   when      $drisubcmd = '%TFROUTCHG'
416fAC                   eval      $drisubcmd = '%SSOUTCHG'
500dAC                   when      $drisubcmd = '%VERIFYTFI'
500dAC                   eval      $drisubcmd = '%VERIFYSSI'
500dAC                   when      $drisubcmd = '%VFYTFICHG'
500dAC                   eval      $drisubcmd = '%VFYSSICHG'
500dAC                   when      $drisubcmd = '%VFYTFOCHG'
500dAC                   eval      $drisubcmd = '%VFYSSOCHG'
500dAC                   when      $drisubcmd = '%VFYCLSTFI'
500dAC                   eval      $drisubcmd = '%VFYCLSSSI'
500dAC                   when      $drisubcmd = '%VFYCLSTFO'
500dAC                   eval      $drisubcmd = '%VFYCLSSSO'
415pAC                   endsl

500dA*    Letdown

415pAC                   when      rpltyp = '*LETDOWN'
416sAC                   select
500dAC                   when      $drisubcmd = '%CLSTFRIN'
500dAC                   eval      $drisubcmd = '%CLSLETIN'
500dAC                   when      $drisubcmd = '%CLSTFROUT'
500dAC                   eval      $drisubcmd = '%CLSLETOUT'
500dAC                   when      $drisubcmd = '%CLSTFICHG'
500dAC                   eval      $drisubcmd = '%CLSLTICHG'
500dAC                   when      $drisubcmd = '%CLSTFOCHG'
500dAC                   eval      $drisubcmd = '%CLSLTOCHG'
416fAC                   when      $drisubcmd = '%TFRIN'
416fAC                   eval      $drisubcmd = '%LETIN'
416fAC                   when      $drisubcmd = '%TFRINCHG'
416fAC                   eval      $drisubcmd = '%LETINCHG'
416fAC                   when      $drisubcmd = '%TFROUT'
416fAC                   eval      $drisubcmd = '%LETOUT'
416fAC                   when      $drisubcmd = '%TFROUTCHG'
416fAC                   eval      $drisubcmd = '%LETOUTCHG'
500dAC                   when      $drisubcmd = '%VERIFYTFI'
500dAC                   eval      $drisubcmd = '%VERIFYLTI'
500dAC                   when      $drisubcmd = '%VFYTFICHG'
500dAC                   eval      $drisubcmd = '%VFYLTICHG'
500dAC                   when      $drisubcmd = '%VFYTFOCHG'
500dAC                   eval      $drisubcmd = '%VFYLTOCHG'
500dAC                   when      $drisubcmd = '%VFYCLSTFI'
500dAC                   eval      $drisubcmd = '%VFYCLSLTI'
500dAC                   when      $drisubcmd = '%VFYCLSTFO'
500dAC                   eval      $drisubcmd = '%VFYCLSLTO'
415pAC                   endsl

500dA*    Unknown (don't change)

415pAC                   other

415pAC                   endsl

500dAC                   endsr
500dA
500dA*----------------------------------------------------------------
500dA*  zzzdriclose   Close any open files or programs.
500dA*----------------------------------------------------------------
500dA
500dAC     zzzdriclose   begsr

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

     C                   eval      $dricommand = '*PRTYRPL'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C                   endsr
500dA
500dA*----------------------------------------------------------------
500dA*  zzzdricop  Call DRICOP
500dA*----------------------------------------------------------------
500dA
500dAC     zzzdricop     begsr
     C                   eval      drierr = *off

     C                   exsr      zzzcvtsubcmd

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
600tAC                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*SLOTDEF'
     C                   eval      $dridata = $slotdef
     C                   when      $dricommand = '*PRTYRPL'
     C                   eval      $dridata = $prtyrpl
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
750cAC                   when      $dricommand = '*APT'
750cAC                   eval      $dridata = $aptds
     C                   endsl

     C                   if        $dricommand = '*ITEM'
600tAC                             or $dricommand = '*SLOT'
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
     C                   eval      drierr = *on
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
     C                   eval      drierr = *on
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
600tAC                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*SLOTDEF'
     C                   eval      $slotdef = $dridata
720bAC                   when      $dricommand = '*PRTYRPL'
720bAC                   eval      $prtyrpl = $dridata
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
750cdC                   when      $dricommand = '*APT'
750cAC                   eval      $aptds = $dridata
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr

500bA*----------------------------------------------------------------
500bA*  ZZZCLR$LT210  -  Clear LT210 parameters.
500bA*----------------------------------------------------------------
500bA
500bAC     ZZZCLR$LT210  begsr

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
500xAC                   clear                   $tnorm1
500xAC                   clear                   $tnorm2
500xAC                   clear                   $tnorm3
     C                   clear                   $tpartial
     C                   clear                   $tpulled
500cAC                   clear                   $tinslot
500cAC                   clear                   $tsamepos
500cAC                   clear                   $tdiffpos
500cAC                   clear                   $tpsplit
500cAC                   clear                   $tinlic#
500cAC                   clear                   $toutlic#
500caC                   clear                   $tnexttask
     C                   clear                   $treturn
     C                   clear                   $terrmsg
     C                   clear                   $tmsgid
610fAC                   clear                   $ttoslot
720hAC                   clear                   $tpartime

     C                   endsr

500bA*----------------------------------------------------------------
500bA*  ZZZCALL$LT210  -  Call LT210 program.
500bA*----------------------------------------------------------------
500bA
500bAC     ZZZCALL$LT210 begsr

640dAC                   if        prseq# < 0
640dAC                   eval      $thead = 'Replenish JIT'
640dAC                   else
640dAC                   eval      $thead = 'Replenish'
640dAC                   endif
     C                   call      'LT210'
     C                   parm                    $tcmd
     C                   parm      #prog         $tprogram
     C                   parm      'RPL'         $ttype
640dDC*                  parm      'Replenish'   $thead
640dMC                   parm                    $thead
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
500cAC                   parm                    $tinslot
500cAC                   parm                    $tsamepos
500cAC                   parm                    $tdiffpos
500cAC                   parm                    $tpsplit
500cAC                   parm                    $tinlic#
500cAC                   parm                    $toutlic#
500cAC                   parm                    $tnexttask
     C                   parm                    $treturn
     C                   parm                    $terrmsg
     C                   parm                    $tmsgid
610fAC                   parm                    $ttoslot
720hAC                   parm                    $tpartime

     C                   endsr
600iA*----------------------------------------------------------------
600iA*     ZZZSET - Reset trans, label and slots
600iA*     Trans was interupted for Specific but no specific was done.
600iA*
600iAC     zzzset        begsr
600iAC                   eval      restrt = *on
600iAC                   endsr
600i *

610iA*----------------------------------------------------------------
610iA*----------------------------------------------------------------
610iA*  Phrase Routines
610iA*----------------------------------------------------------------
610iA*----------------------------------------------------------------

610iA*----------------------------------------------------------------
610iA*  pushRoutine  -  Add routine to stack
610iA*----------------------------------------------------------------
610iA
      /free
       begsr pushRoutine;

         for i = stackCount downto 1;
           eval aRoutine(i+1) = aRoutine(i);
         endfor;

         aRoutine(1) = currRoutine;
         stackCount += 1;

       endsr;
      /end-free

610iA*----------------------------------------------------------------
610iA*  popRoutine  -  Remove routine from stack
610iA*----------------------------------------------------------------
610iA
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

610iA*----------------------------------------------------------------
610iA*  phClearVars  - Clear phrase variables
610iA*----------------------------------------------------------------
610iA
      /free
       begsr phClearVars;

         v1 = ' ';
         v2 = ' ';
         v3 = ' ';
         v4 = ' ';
         v5 = ' ';

       endsr;
      /end-free


610iA*----------------------------------------------------------------
610iA*  zzWrtPhrase  - Write logging phrase
610iA*----------------------------------------------------------------

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

610iA*----------------------------------------------------------------
610iA*  phV2onV1
610iA*----------------------------------------------------------------
610iA
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

610iA*----------------------------------------------------------------
610iA*  phScrV1pgmV2
610iA*----------------------------------------------------------------
610iA
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

610iA*----------------------------------------------------------------
610iA*  phPgmV1V2V3e
610iA*----------------------------------------------------------------
610iA
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

610iA*----------------------------------------------------------------
610iA*  phPgmV1V2V3s
610iA*----------------------------------------------------------------
610iA
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
640jA*----------------------------------------------------------------*********
640jA*
640jA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640jA*
640jA /free
640jA   begsr zzwrttrand;
640jA     wrtpcmd = '*ONETRAN';
640jA     wrtpwait = 0;
640jA     wrtpwhse = ptwhse;
640jA     wrtptran# = pttrn#;
640jA     wrtpfrmdate = 0;
640jA     wrtptodate = 0;
640jA     wrtpemp# = 0;
640jA
640jA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640jA               wrtpfrmdate: wrtptodate: wrtpemp#);
640jA   endsr;
640jA /end-free

700fA*----------------------------------------------------------------
700fA*  zzChgRpl     -  User changed replenishment in LT210
700fA*----------------------------------------------------------------
700fA
      /free
       begsr zzChgRpl;
         Exsr clr$slot;
         Eval $slwhseu = *on;
         Eval $slwhse  = #fromslwhse;
         Eval $slwhdpu = *on;
         Eval $slwhdp  = #fromslwhdp;
         Eval $sldispu = *on;
         Eval $sldisp  = #fromsldisp;
         Eval $dricommand = '*SLOT';
         Eval $drisubcmd  = '%GET';
         Eval $drisys2upd = 'D';
         Exsr zzzdricop;

         Chain (svlbl#) Label;

         If %Found(Label);
           Eval lbaisl = $slaisl;
           Eval lbloc  = $slloc;
           Eval lbrlvl = $slrlvl;
           Eval lbhand = $slhand;
           Eval lbdisp = $sldisp;
           Eval lbqavl = $slavl1;
           Update lbrec;
           Exsr scr02i;
         EndIf;
       endsr;
      /end-free

     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Item
Qty
Verify Zero
Slot
Slot empty
Item number
 Brkdwn
Replenishment
   Let down
 Priority Repl
 Specific Repl
Let down qty cannot be less than zero.
From aisle not valid.
To aisle not valid.
From/to both blank or both filled in.
Rtn product to slot:
Entire bal. qty must be entered.
Pull qty cannot be gt than slot qty.
Replen qty cannot be gt than pull qty.
Repl qty gt avail qty in from slot.
F10=Excpt not avail when Rtn home active
Qty putaway cannot be gt than balance.
New Replen's to do.
Pull qty must be gt zero for letdown.
Repl type
Invalid quantity entered
Side
F8=List not available at this time.
F9=Skip not available at this time.
Invalid Letdown Sequence
F11=transfer not available this time.
Go to JIT repl
No F7 with dept *ALL
**
 ABCDEFGHIJKLMNOPQRSTUVWXYZ
** Descsp
Producto
Ctd
Verificar con 0
Slot
Slot vacio
# de producto
 roto
Reaprovisionamiento
   Let down
 Reap. de prioridad
 Reap. especifico
Ctd de Let down no puede ser menos que 0.
De pasillo no es valido.
A pasillo no es valido.
De/A son blancos ambos o llenas ambos.
Vlv producto al slot:
Todo la cantidad de balance debe ser incorporado.
Ctd de escoger no puede ser mayor que la ctd de slot.
Ctd de Reap no puede ser mayor que la ctd de escoger.
Ctd de Reap mas grande que la ctd disponible en DE slot.
F10=Excpc no disp. cuando Vlv inicio activo
El guardar de Ctd no puede ser mayor que balance.
Nuevo Reaps de hacer.
Ctd de escoger debe ser mayor que 0 por Let down.
Repl type
Invalid quantity entered
Side
F8=Lista no esta disponible ahora.
F9=Pasar sobre no esta disponible ahora.
Invalid Letdown Sequence
F11=transfer not available this time.
Reap. JIT
Not authorized to use function key (F14)
