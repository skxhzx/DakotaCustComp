500 A /copy *libl/qcopysrc,hspecs
650uAH dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1957
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PO236   VS License entry P.O. receiving
     *  16 February, 1998
     *  Roxanne Harrison
     *
     *----------------------------------------------------------------
409 A*  Note:
     *      - Revised license plate entry screen to identify cross docks
     *        and protect the license plate field.
     *      - Revised to not check/add license plate for cross dock.
     *    Created using PO136 and RC160,
     *    Previous version comments were removed.
     *    A record exists in the CROSSDK file for each customer order
     *      cross dock line item.
     *    This program calculates the quantity needed for cross dock
     *      using the SLOT file, (only one record per crossdock item.
     *    ZZXQTY was written to calculate the quantity needed for XDK
     *      on a given PO, the ORDD qty ordered less the qty picked.
     *      However, couldn't determine when to use ZZXQTY instead
     *      the slot quantity, so ZZXQTY is not executed.
     *
     *----------------------------------------------------------------
     *  Revisions
410 A*    10/22/98  RH   4.10
     *      - Change to call OPLPGM with parm $PWHS, ($PWHSE is packed
     *
414 A*    09/27/00  KDE  4.14
    A*      - Add code to write a record to PORCV as manual receiving
     *        is completed.  This marks detail sequence as touched.
     *
414 A*    10/12/00  DAS  4.14
     *      - Made misc mods to above 414 changes.
     *
415 A*    11/16/00  MLB  4.15
     *      - Revised program to make sure duplicate license numbers
     *        have not been assigned.
     *
415aA*    03/10/01  DAS  4.15a
     *      - Revised to work with PO200 RF small screen receiving.
     *      - Created separate message subfile in order to put
     *        message on line 8 of small display screen. New records
     *        are MSGREC2, MSGCTL2 and MSGCLR2.
     *
415bA*    03/19/01  DAS  4.15b
     *      - Revised to use FRMTIT2 for small screen.
     *
415cA*    08/06/01  HNK  4.15c
     *      - Corrected to be able to receive each quantity.
     *
415dA*    08/23/01  DAS  4.15d
     *      - Removed 415c change.
     *      - Revised ZZUSUB to handle SSB items correctly.
     *
416 A*    02/11/02  DAS  4.16
     *      - Added external data structure $SLOT.
     *      - Added routines ZZZS2D, ZZZCOP
     *      - Added xdock DRI interface.
     *
416aA*    03/01/02  DAS  4.16a
     *      - Added *FEATURE option.
     *      - Replaced routine ZZUXDR with routines ZZUXFL and ZZUXLC.
     *      - Revised to put crossdock quantity into pick slot when
     *        working with a Locator system and quantity was retrieved
     *        from host.
     *      - Added call *XDOCK with *RECEIVE.
     *      - Revised crossdock logic in ZZFIL1.
     *
416bA*    11/30/01  MLB  4.16
     *      - Revised ZZCHK1 to not allow negative license
     *        plate numbers to be entered.
     *      - *** NOT IMPLEMENTED BECAUSE OF 416c CHANGE ***
     *
416cA*    05/23/02  RRH  4.16
     *      - Change W1LCNS, W2LCNS to 15 Alphanumeric.
     *      - Left justify, remove leadind blanks for license
     *
416dA*    06/11/02  DAS  4.16d
     *      - Changed A$LIC# from 7.0 to 15.
416eA*    08/30/02  MLB  4.16e
     *      - Fix: Revised ZZFIL1 to reverse 4.15d change when
     *        testing PCTR counter.
     *
417 A*    04/24/03  MLB  4.17
     *      - Fix. Undo 4.16e revision.  Change no longer needed.
417aA*    04/28/03  MLB  4.17a
     *      - Revised ZZCHK1 to use *LEFTNOZ for call to ADJUST.
417bA*    05/13/03  MLB  4.17b
     *      - Enh: Added support for lot/license plate tracking.
417cA*    05/13/03  MLB  4.17c
     *      - Enh: Revised program to receive lot code from PO232.
417dA*    06/25/03  HNK  4.17d
     *      - Fix: Do not allow entry of special characters in license
     *             entry field.
417eA*    11/13/03  MLB  4.17e
     *      - Enh: Revised $RPARM DS to add two new fields,
     *        $RFSLP and $RTSLP.
     *
417fA*    03/23/04  DAS  4.17f
     *      - Never used.
417gA*    05/26/04  MLB  4.17g
     *      - Fix: Revised ZZFIL1 to load correct unit of measure into
     *        subfile when only breakdown 1 or breakdown 2 qty's rcv'd.
417hA*    06/04/04  DAS  4.17h
     *      - Fix: Revised PO236FM to send back the subfile the cursor
     *             is on (RTNRRN).
     *      - Fix: Revised to total quantity check so the cursor will
     *             be position to the next line in the subfile.
417iA*    06/07/04  MLB  4.17i
     *      - Fix: Changed size of variable X used as counter to be 5,0
     *        instead of 2,0.
     *
417xA*    03/23/04  DAS  4.17x
     *      - Revised to receive and use average weights.
     *      - Revised to always write lichist record.
     *
417xA*    05/13/04  DAS  4.17x
     *      - Converted to ILE.
     *      - Replace program information data structure fields with
     *        /COPY C#PGMINFDS.
     *      - Changed all #PROG to #PGM.
     *      - Revised to receive mfg date, fifo date and upc.
     *      - Revised to use DRI to write license info.
     *      - Change error into a logical field.
     *
417yA*    07/22/04  DAS  4.17y
     *      - Converted DRI from legacy to ILE
     *
417zA*    07/22/04  DAS  4.17z
     *      - Added DRI LICHIST instead of updllptrk
     *
500 A*    01/24/05  DAS  5.00
     *      - Replaced PIRITEM file with DRIITEM *GET.
     *      - Revised call to to *LICHIST to set the "Dock" item to the
     *        received item's corresponding "Slot" item.
     *
500aA*    03/31/05  DAS  5.00a
     *      - Added logic for non-live departments. User will not be
     *        asked for license and label/transaction will be closed.
     *      - Revised zzusub to call zzllp unconditionally.
     *      - Revised zzllp to update license history before info.
     *
500bA*    04/01/05  DAS  5.00b
     *      - Revised to fill in qty when only 1 pallet being received.
     *
500cA*    11/21/05  JCJ  5.00c
     *      - Revised to collect clam information.
     *      - Add call to TagFmt program.
     *
510 A*    06/14/06  JCJ  5.10
     *      - Revised to collect UCI information.
     *
510aA*    07/31/06  JCJ  5.10a
     *      - Enh: Add Client support for client id
510bA*    10/12/06  RH   5.10b
     *      - Enh: Capture date entered,type and date settings
     *        Replace MFDT with INDT for keyed in date.
510cA*    10/31/06  JCJ  5.10c
     *      - Enh: Added missing LCNS array processing to ZZCHK2
510dA*    11/07/07  DAS  5.10d
     *      - Enh: Added TPC custom code.
     *
520 A*    06/30/08  MLB/RH  5.20
     *      - Fix: Revised program to only update LICENSE file when
     *        LIVESTAT=*LIVE.
     *      - Added code to release record lock on LICENSE in the
     *        event we find a record, but don't update it.
520aA*    04/17/09  RBD  5.20a
     *      - Revised to collect 'SHUCKED' information.
520bA*    05/28/09  MLB  5.20b
     *      - Fix: Revised routine ZZPXDK to not lock SLOT2 rcds
     *        when they are read.
     *
530aA*    09/23/10  RBD  5.30a
     *      - Removed CROSSDK2, as the po # and po seq in CROSSDK are
     *        now optional ... instead, PODTL field PDSPCL will now
     *        be imported with value 'XD' for cross dock items.
     *        Revised to use SLOT10 instead of SLOT2.
     *      - Revised to bypass license entry scrns for cross dock items.
     *      - Revised to always receive entire qty into xdk slot,
     *        making rev TPCa standard for everyone.
     *      - Revised to call DRISLOT with %CRTXDOCK for all XD items
     *        and use %ADJUSTOSS to put the qty into the slot.
     *      - Fix: It appears that subr's zzuxfl and zzuxlc have yet to
     *        be used as still no program exists in DRIFILE for *XDOCK.
     *        But just in case the code is ever used, I fixed locatr
     *        code to exec zzuxlc when *on and zzuxfl when *off, rather
     *        than the other way around.
     *
530bA*    08/17/10  RH   5.30b   (brought from Royal 530a by RBD)
     *      - Increment RPAL if UOM is needed after qty upped and was
     *        not originally used so UOM line will display on sc1.
     *
600aA*    10/23/08  DAS  6.00a
     *      - Revised to put license qty into an RCV intermediary slot.
     *
600bA*    10/25/08  DAS  6.00b
     *      - Revised to use #curruser instead of #user.
     *      - Revised to not send *RCVJOB and *RCVTS to LICINFO.
     *
600cA*    02/02/09  GJA  6.00c
     *      - Enh: Added External Storage
     *
600dA*    04/22/09  DAS  6.00d
     *      - Enh: Revised how External storage works.
     *
600eA*    05/14/09  GJA  6.00e
     *      - Fix: Off Site storage was not closing transaction or
     *             label.  Filled $pdev for label print for Off Site.
     *
600fA*    05/15/09  DAS  6.00f
     *      - Fix: New zzurcvslot in routine zzusub was being
     *             executed when qty was zero.
     *
600gA*    05/20/09  DAS  6.00g
     *      - Revised to not allow using a license that starts with OS
     *        if and OSS license is not found for it. Re: If you print
     *        and OSS license, then get out, the OSS record is deleted.
     *        However, if the user gets back in and scans the unused
     *        license, the system treated it as a normal license and
     *        put the qty into a RCV slot.
600hA*    05/27/09  GJA  6.00h
     *      - Revised to skip OSS checks if error already occured.
     *        Re: OSS check was clearing error flag.
600iA*    06/01/09  DAS  6.00i
     *      - Revised to create an LP for XDK's and create LICLOG entry.
600jA*    06/01/09  DAS  6.00j
     *      - Revised to use DRISLOT to receive qty into XDK slot.
     *        This will also add the qty to ITEMQTY and create a
     *        LICACTIVE record.
610aA*    07/21/09  DAS  6.10a
     *      - Revised to call zsclr at the beginning of program.
     *        Re: For some reason webfacing wasn't clearing the
     *        preceeding screen, even though this is coded like other
     *        programs.
610bA*    08/13/09  GJA  6.10b
     *      - Enh:  Added ability to print produce labels
610cA*    08/27/09  DAS  6.10c
     *      - Fix:  Fix label UOM info for SSB items.
610dA*    08/27/09  DAS  6.10d
     *      - Fix:  Remove SSB logic from %RCVIN and %ADJUSTOSS.
610eA*    10/21/09  GJA  6.10e
     *      - Fix:  Removed the ability for user to enter blank for
     *              OSS staging
610fA*    01/15/10  DAS  6.10f
     *      - Fix:  Initialize values for NOTLIVE in ZZURCVSLOT.
610g *    04/29/10  GJA  6.10g    P#00243
     *      - Enh:  Changed UCI to be option driven.  OPUCI
610h *    05/11/10  GJA  6.10h    P#00243
     *      - Fix:  Changed UCI option position.
640aA*    01/13/11  RH   6.40a
     *      - Enh: Add Whse to CHKLIVE parms
640bA*    04/19/11  JGD & RBD   6.40b
     *      - Enh: Changed format name to PO23601.
     *      - Enh: Added entry of special status code and F4 to
     *        prompt it.  If a status code is entered it will be
     *        assigned to that set of license plates being received
     *        and to the slots they go into.
640cA*    02/06/12  LMC         6.40c
     *      - Enh: position cursor to Qty if only 1 pallet.
640dA*    04/05/12  LMC  6.40d
     *      - Enh: Added New HACCP processing. - in process
640eA*    07/13/12  LMC  6.40e
     *      - Enh: Added Decipher code to incoming parms and write
     *        to Licinfo file.
640fA*    08/03/12  LMC  6.40f
     *      - Enh: Added LPN in order to update POASN file.
640gA*    09/10/12  LMC  6.40g
     *      - Enh: Added UCI processing.
640hA*    09/13/12  LMC  6.40h
     *      - Enh: Write New LICINFO record.
650aA*    03/22/13  LMC  6.50a
     *      - Enh: Add logic for passing parms needed for haccp cross
     *      reference file. Load HACCPXRF file data.
650bA*    03/26/13  LMC  6.50b
     *      - Fix: Need to get current date before writing porcv
     *      records, problem came up at CDI Jacksonville, they receive
     *      at night, PORCV was loading current time with previous day
     *      when the receipt happened right after midnight.
650cA*    02/20/13  LMC  6.50c
     *      - Fix: Increase field size from 6 to 7. Get Fresh fields
     *        calculated to larger than 6 positions. This may need to
     *        be increased, once we find the Maximum field size for
     *        the quantity ordered on Get Fresh host.
650dA*    05/17/13  LMC  6.50d
     *      - Enh: Added RCVPO transaction.
650eA*    06/10/13  LMC  6.50e
     *      - Enh: Need to set License passed in from PO200 - GS1/UCI
650fA*    06/19/13  LMC  6.50f
     *      - Enh: Add call to CALCPTI
     *      NOTE: this enhancement needs to include Program CALCPTI
650gA*    07/16/13  LMC  6.50g
     *      - Enh: Added additional checks for unique license.
     *      LICINFO and LICLOG records stay longer with new cleanup.
     *      We need to check LICLOG before we allow the user to
     *      reuse a license number.
650hA*    09/03/13  LMC  6.50h - mods in process
650iA*    09/11/13  LMC  6.50i
     *      - Fix: Edit in mod 650g does not apply for OS license.
     *      The OS* license will exist in licactive/liclog because
     *      it was just created for use.
650jA*    09/06/13  LMC  6.50j
     *      - Enh: Pass License to clam print programs.
650kA*    10/01/13  LMC  6.50k
     *      - Enh: Require Clam information for each license.
     *        Pass the license to PO172.
650lA*    10/28/13  LMC  6.50l
     *      - Fix: 650g code should only execute if there are no
     *        current errors. This code sets the error field off
     *        and was causing the potential for a blank license to
     *        be written to liclog and licinfo.
650mA*    01/17/14  MLB  6.50m
     *      - Fix: Increase field size from 6 to 7 for wtlqty. Same
     *        issue as 6.50c mod for Get Fresh.
650nA*    02/17/14  JCJ  6.50n
     *      - Enh:  Create one spool file instead of individual
     *              spool files for each produce label
650oA*    03/13/14  RH   6.50o
     *      - Fix:  Move code to get date from ZZINZ to ZZINZ2.  Was
     *              only getting date first time in, used wrong date
     *              if user didn't sign off each night.
650pA*    06/05/14  LMC  6.50p
     *      - Enh:  New OSS Receiving.
     *        New incoming parm to indicate OSS Receiving.
     *        Disable F9 if new OSS Receiving parm is populated.
     *        New OSS logic - does everything F9 does except we
     *        DO NOT create an OSS license.
     *        User will be using regular license.
     *      - Enh: Changed format name to PO23602.
     *        Added Note field to HEAD1 screen for visual notification
650qA*    05/27/14  RBD  6.50q
     *      - Enh: New pgm RC180 along with these 650q changes allow
     *        a user to receive an item into inventory without a PO.
     *        This was requested by City Line and is being written as
     *        a standard enhancement so other clients may use it too.
     *        When RC180 calls this pgm it sends cmd *NONE and the
     *        following logic will apply:
     *        1. PO files will not be updated as there is no PO.
     *        2. Use RF screen2 for entry instead of full screen head1.
     *        3. Write inventory adjustment record using code Z9. Make
     *           sure adj code Z9 "Item received without PO" has been
     *           added to the adjustment code table ADJCODE.
     *        4. Call RC200 putaway for each license.
650rA*    06/27/14  LMC  6.50r
     *      - Fix: Movel on uom field for RF screen. Field was
     *        displaying blank uom.
     *
650sA*    07/15/14  RBD  650s
     *      - Fix: Changed to call TAGFMT with parm $PWHS because $PWHSE
     *        is packed and was causing dec data error in TAGFMT.
     *
650tA*    08/26/14  LMC  650t
     *      - Fix: Changed key klist for chain OPTIONS when getting   SE
     *        *SYSTEM record, key should have zero warehouse.
650uA*     09/08/14  LMC  6.50u
     *       - Enh: Add program tracking.
     *         Data area PGMTRACK has been created to control whether
     *         log records should be written to file PGMTRCK.
     *         Records are written to the file when the data are
     *         contains a '1'.
     *
650vA*    07/28/14  LMC  650v
     *      - Enh: Replace T licenses in UCIINFO that we are using forSE
     *        storing detail weights entered in CW122 or total weight
     *        entered in PO232, non UCI receiving.
     *
650wA*    12/02/14  LMC  6.50w
     *      - Fix: Need to write batctl records when we return from
     *      the call to PIRBAT# retrieving the next batch# to be used.
700aA*    04/30/15  LMC  7.00a
     *      - Fix: clear the UISELCSEQ when replacing, we are using   SE
     *        this field temporarily for CW122.
700bA*    12/23/15  LMC  7.00b
     *      - Enh: Added the ability to load a special license for
     *        clients who want to print receiving labels, when
     *        Receiving option "Use Generic License" = 'N'
     *      - Enh: Additional logic when Receiving label print program
     *        begins with RFMT.
700cA*    01/12/16  MLB  7.00c
     *      - Fix: Revised routine ZZCHK2 to fully left justify
     *      license plate when called from PO200. Found at I-Supply.
700dA*    05/02/16  LMC  7.00d
     *      - Fix: Cross dock was not writing LICENSE record.
     *      - Fix: label records not getting slot data loaded
     *        unless the item already has a XDK slot.
     *      - Fix: Cross dock was not writing license to PORCV record.
     *      - Fix: Cross dock expiration date was not being sent to
     *             DRISLOT, as a result the license was not getting
     *             a correct expiration date loaded.
     *      - Fix: Need1,Need2,Need3 qtys need to be set based on
     *             the uom qtys sent in.
700eA*    07/11/16  LMC  7.00e
     *      - Enh: Recompile only - DB change to workoss.
     *
700fA*    01/04/16  LMC  7.00f
     *      - Fix: NOTLIVE Departments - should not attempt to create
     *             licinfo records.
700eA*    07/11/16  LMC  7.00e
     *      - Enh: Recompile only - DB change to workoss.
     *
710aA*    04/04/17  LMC/RH 710a
     *      - Enh: Adding the slot type and information text field
     *      to PO236.01.
     *      We will be getting the pick slot for all customers now.
710bA*    05/02/17  LMC  7.10b
     *      - Fix - Need to check to make sure old LICINFO record
     *        doesn't exist. If it does, the program actually fails
     *        in the update process.
710cA*    11/29/17  JCJ  7.10c
     *      - Enh: Changed to print the Base Item and description.
     *             This will handle the case when the ordered item
     *             is an Alias.
710dA*    11/30/17  JCJ  7.10d
     *      - Enh: Retrieve Manufacture Tie/Hi for printing on PUTMAN
     *        label (file ITEMMSC).
     *
720aA*    05/15/18  LMC  7.20a
     *      - Enh: Only write PTI records to the uciinfo file if the
     *        item is setup for pti selection
     *
720bA*    10/12/18  LMC  7.20b
     *      - Enh: Additional receiving methods have been created.
     *        4,5 & 6. They all are standard receiving with an addon
     *        for printing labels (aka Box labeler).
     *
720cA*    07/29/16  LMC  7.20c  Reserved
     *      - Enh: UCI Tracking.
720dA*    11/26/18  RH   7.20d
     *      - Fix: Change to use separate UOM qty for each adjustment
720eA*    11/28/18  LMC  7.20e
     *      - Fix - Only check to make sure old LICINFO record
     *        doesn't exist if $pgslcns = ' '
730aA*    09/23/19  LMC  7.30a
     *      - Enh: Only display screen2 if pflag = *on or an error
     *      - Enh: Send RWOIN instead of RCVIN to
     *        drislot when coming from rc180 - $pcmd = '*NONE   '
730bA*    09/30/19  LMC  7.30b
     *      - Fix: Quantities were not loaded correctly on breakdowns
     *        being received from RC180.
730cA*    09/30/19  LMC  7.30c
     *      - Enh: Added logic for licadj, copied from IV510 logic.
740aA*    02/18/20  LMC  7.40a
     *      - Enh: Added logic to accomodate RF uci Receiving.
     *      - Anywhere PO200 was referenced also reference PO201.
740bA*    07/03/20  MLB  7.40b  ZD#2125
     *      - Enh: Changed @PRTPG to BFCPRTLBL from PRTLBL due to
     *        conflict with TL Ashford pgm of the same name.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: EG Forrest
EGFaA*    01/11/10  RH   EGFa
     *      - Revised to display home pick slot at extended desc end.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: Eastland
     *
EFCa *    03/03/11  GJA  EFCa
     *      - Fill external storage window default values
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: Get Fresh Kitchen
     *
GFKa *    12/14/18  DAS  GFKa
     *      - Revised to skip calling RC200.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Sunrise Food Service
     *
SUNa *    09/01/20  LMC  SUNa
     *      - Revised to skip calling RC200.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Natalie's Juice Company
     *
NOJa *    09/08/20  LMC  NOJa
     *      - Revised to skip calling RC200.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: Halsey
     *
HSYaA*    10/20/09  RH   HSY
     *      - Revised to display home pick slot at extended desc end.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jordano's
     *
JDO A*    03/31/05  DAS  JDO
     *      - Revised ZZCKNS to only allow virtual pick slots to be
     *        created for PIR slots.
     *
PCK A*    07/31/06  JCJ  PCK
     *      - Revised ZZUPD1 to limit access to UCI entry to packers.
     *
PCKaA*    10/31/06  JCJ  PCK
     *      - Pass Transaction number to @uci.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Renzi
     *
RNZaA*    09/23/08  RH   RNZa
     *      - Revised to display error if catch weight item and wt = 0.
     *        14 detail lines had 0 wt from 8-18 thru 9-17-08.
     *        Creted for debugging purposes.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: RYLa
     *
RYLaA*    08/16/10  RH   RYLa
     *      - Add to TPC mod to put entire received qty into
     *        XDK slot.

     *----------------------------------------------------------------
     *  Client Custom Revisions: TPC
     *
TPCaA*    11/07/07  DAS  TPCa
     *      - Revised ZZPXDK to put entire received qty into
     *        XDK slot.
TPCbA*    07/08/09  MLB  TPCb
     *      - Revised ZZUXDK to force W1QTY into AVAIL1 so that
     *        entire qty is placed into XDK slot.
     *      - Revised ZZUXDK to force SLSTAT = XD when it anything
     *        other than XD when updating the slot.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: SGC
     *
SGCaA*    02/02/09  GJA  SGCa
     *      - Fill external storage window default values
     *
SGCbA*    05/18/09  GJA  SGCb
     *      - Enh:  If willow default to LP7, if Kansas default to LP8
SGCcA*    05/20/09  MLB  SGCc
     *      - Revised ZZPXDK to put entire received qty into
     *        XDK slot.
     *      - Added SGC to TPCa mod.
SGCdA*    05/28/09  GJA  SGCd
     *      - Add check in ZZCHK1 to only allow 7 digit license
SGCeA*    06/03/09  GJA  SGCe  (associated with 6.00b on PO236FM)
     *      - Add *IN95 to protect stage field from being overwritten
SGCfA*    02/11/13  JCJ  SGCf
     *      - Changed storage label to print on a zebra printer
SGCgA*    04/04/17  LMC/RH SGCg
     *      - Added information to let receiver know that the pallet
     *        will be put into the slot sideways for correct placement
     *        of the license plate on pallet.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt
     *
CSP A*    10/08/10  RBD  CSP
     *      - When calling DRISLOT with %CRTXDOCK, force aisle
     *        to be 'JIT' if pdspcl = 'XD'.
CSPaA*    07/10/19  RH   CSPa
     *      - When calling DRISLOT with %CRTXDOCK, force aisle
     *        to be 'PC ' if pdspcl = 'XD'.
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Client Custom Revisions: ICB
ICBaA*    08/01/12  RH   ICBa
     *      - Enh: Default W1LCNS to off site storage license, they
     *        do not physically receive product at warehouse, ships
     *        to OSS.
     *----------------------------------------------------------------
     *  Client Custom Revisions: ISupply
     *
ISPa *    02/12/14  GJA  ISPa
     *      - Enh: Default W1LCNS to off site storage license, they
     *        do not physically receive product at warehouse, ships
     *        to OSS.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Glazier
     *
GFCa *    08/02/10  JCJ  GFCa
     *      - Enh: Allow '-' in the license plate.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Get Fresh Sales
     *
GFS A*    03/08/13  MLB  GFS
     *      - Enh: ZZCHK1 to ensure that first character of license
     *        plate begins with G. Per Hemant/David H. email.
GFSaA*    01/14/19  MLB  GFSa
     *      - Enh: ZZCHK1 to ensure that first character of license
     *        plate begins with G, F or K. Per Shawn S phone call.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
DRYaA*    04/29/13  LMC  DRYa
     *      - Revised to Not use the PDSPCL to set cross dock. Client
     *        does not use our cross dock logic.
DRYbA*    06/13/16  LMC DRYb
     *      - Enh: If the expiration  is <= today, and the user
     *        overrides - Chef's want the status in PO236 to be set
     *        to 'QU' for quanrantine. Send QU in the $parms
DRYcA*    10/30/17  LMC DRYc
     *      - Enh: OSS receipts need to be put into a slot with a
     *        status of "O" temporatily, because Chef's has a trigger
     *        process that fires if the status is active. They asked
     *        for us to use status "O" which is not a valid status, so
     *        they can control the triggers on slots changing from
     *        status "O" to "A".
     *      - Enh: Do not allow the f4 to change the status to be used
     *             Do not allow any status to be entered.
     *      - Enh: changed display file to PO23606.
DRYeA*    05/16/19  NLK  DRYe like GFKa
     *      - Revised to skip calling RC200.
DRYfA*    09/23/19  LMC  DRYf
     *      - Enh: setup label program and label set name for printing
     *        item license labels from RC180.
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Line
CLDaA*    06/17/14  RBD  CLDa
     *      - Use adjustment code 4 rather than Z9.
     *----------------------------------------------------------------
     *  Client Custom Revisions: FoodPro
     *
FPR A*    07/06/15  RH   FPRa
     *      - Enh: ZZCHK1 to ensure that first character of license
     *        plate begins with F or R per Carolyn H.
FPRbA*    06/03/19  MLB  FPRb
     *      - Enh: ZZCHK1 to ensure that first character of license
     *        plate begins with F or R or P. per Eli H.
     *----------------------------------------------------------------
     *  Client Custom Revisions: VIP Foodservice
     *
VIP A*    04/29/16  MLB  VIP
     *      - Revised to add message field to HEAD format.
     *      - Check if item category = ALLERGEN, then load info msg.
     *      - Renamed PO23601 to PO23604.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Westside
     *
WSFa *    09/19/16  GJA  WSFa
     *      - Add check in ZZCHK1 to only allow 7 digit license
     *----------------------------------------------------------------
     *  Client Custom Revisions: Presto Foods
     *
PFCa *    08/14/20 RTR PFCa
     *      - Enh: Add support to program to capture information
     *        needed for APT Interface.
     *
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   Field position to
     *  21 - 40   Field input error (reverse display)
VIP A*  45        VIP: Reverse image Allergen message on display.
600cA*  71        Chain indicator for LICEXST DSP
     *  81        Display subfile records (SFLDSP)
     *  82        Display subfile screen (SFLDSPCTL)
     *  83        Clear subfile (SFLCLR)
     *  84        Allow subfile to display '+' (SFLEND)
     *  85        Manually set subfile change flag (SFLNXTCHG)
     *  90        View mode (Protect input fields)
     *  91        Change mode (protect key)
600cA*  92        Too many license pallets requested-External storage
600cA*  93        No license pallets entered-External storage
SGCeA*  95        Protect site code on off site storage window
650pA*  96        Used to disable F9 off site storage
     *  97        Error message subfile indicator
     *  98        Error on screen (sound buzzer)
     *  99        Universal record indicator (very temporary usage)
     *
650uA*----------------------------------------------------------------
650uA*  Binding Directories
650uA*----------------------------------------------------------------
650uA
650uAHbnddir('BFCBND')
     *----------------------------------------------------------------
     *  File Specs
     *
640bDF*po236fm   cf   e             workstn
640pDF*po23601   cf   e             workstn
700bDF*po23602   cf   e             workstn
VIP DF*po23603   cf   e             workstn
710aDF*po23604   cf   e             workstn
DRYcDF*po23605   cf   e             workstn
DRYcMFpo23606   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(detail1:recno)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(msgrec2:msgk)
416 AFslot1     uf a e           k disk
     F                                     rename(slrec:s1rec)
530aDF*slot2     uf   e           k disk
530aDF*                                    rename(slrec:s2rec)
416 AFslot3     uf   e           k disk
     F                                     rename(slrec:s3rec)
530aAFslot10    if   e           k disk
530aAF                                     rename(slrec:s10rec)
     FLabel2    if   e           k disk
     F                                     rename(lbrec:record)
     FLicense   uf a e           k disk
     Fpodtl     uf   e           k disk
     FLabel     o  a e           k disk
     Fwarehs    if   e           k disk
500 DF**ritem   if   e           k disk
     Fitemdsc   if   e           k disk
     Foptions   if   e           k disk
530aDF*crossdk2  if   e           k disk
     Fordd      if   e           k disk
600dAFworkoss   uf a e           k disk
600dAFworkoss1  uf   e           k disk
600dAF                                     rename(worec:worec1)
414 AFporcv     o  a e           k disk
650aAfhaccpxrf  o  a e             disk
650qAFitemadj   o  a e             disk
650uAFpgmtrck   o  a e           k disk
650wAFbatctl    o    e           k disk
710gAFitemmsc   if   e           k disk
730cAFlicadj    o  a e           k disk    usropn
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
416cMD lcns            s             15    dim(500)
640bDD*desc            s             50    dim(10) ctdata perrcd(1)
640bMD desc            s             50    dim(12) ctdata perrcd(1)

650aAd $lparm1         s             48    dim(20)
650aAD $parms1         s             48    dim(20)
510aA*----------------------------------------------------------------
510aA*  Customer id
510aA*----------------------------------------------------------------

510aA /copy qcopysrc,id#packers
TPCaA /copy qcopysrc,id#tpc
RNZaA /copy qcopysrc,id#renzi
SGCaA /copy qcopysrc,id#sgc
SVLaA /copy qcopysrc,id#saval
HSYaA /copy qcopysrc,id#halsey
GLZaA /copy qcopysrc,id#glazier
EGFaA /copy qcopysrc,id#egf
RYLaA /copy qcopysrc,id#royal
CSP A /COPY QCOPYSRC,Id#Coastal
EFCaA /COPY QCOPYSRC,Id#Eastlan
ICBaA /COPY QCOPYSRC,Id#ICB
ISPaA /COPY QCOPYSRC,Id#ISupply
DRYaA /copy qcopysrc,id#dairyla
GFS A /COPY QCOPYSRC,Id#GFS
CLDaA /copy qcopysrc,id#citylin
FPRaA /copy qcopysrc,Id#fpr
VIP A /COPY QCOPYSRC,Id#VIP
WSFaA /copy qcopysrc,Id#westsid
GFKaA /copy qcopysrc,id#gfk
SUNaA /copy qcopysrc,id#sun
NOJaA /copy qcopysrc,id#noj

417yD*----------------------------------------------------------------
417yD*  External data structure for Dakota Realtime Interface.
417yD*
417yDD*$slot         e ds                  extname(c#slotdds)
417yDD*$xdock        e ds                  extname(c#xdockdds)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
417yA /COPY *libl/qcopysrc,C#SLOT
417yA /COPY *libl/qcopysrc,C#XDOCK
      /COPY *libl/qcopysrc,C#LICINFO
417zA /COPY *libl/qcopysrc,C#LICHIST
600aA /COPY *libl/qcopysrc,C#LICENSE
500 A /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#UCIINFO
710aA /COPY *libl/qcopysrc,C#SLOTDEF
417aAD savever#        s                   like($lnver#)

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
     D  $ppo                  37     45
     D  $prq1                 46     50  0
     D  $prq2                 51     55  0
     D  $prq3                 56     60  0
     D  $prpal                61     63  0
417bAD  $plott                64     64
417bAD  $plict                65     65
DRYbAD  $QUstat               66     67

417gA*  Extra parameters not part of data structure.

510bDD*$pmfdt          s              8  0
510bMD $pindt          s              8  0
417gAD $pfifo          s              8  0

650aAD $p1parms1       ds
650aAD  $p1whse                1      3
650aAD  $p1po                  4     12
650aAD  $p1poseq              13     17
650aAD  $p1qstseq             18     22
650aAD  $p1uctime                      Z
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
405 AD  $ltype                81     88
     *
     *   Redefine key
     *
640bAD  $lstat                19     20
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     D  $lrack                22     26
     *
     D  $lbld                 19     20
     *
405 AD  $lrte                 22     26
405 AD  $lpo                  27     35
405 AD  $ltrn#                36     42  0
640dA*   for Haccp
640dAD  $llevel               22     25
640dAD  $llicense             26     40
640dAD  $lhpo                 41     49
640dAD  $lhseq                50     54  0
640dAD  $lhtype               55     57
     *
510 AD $mparm          ds
510 AD  $mcmd                  1      8
510 AD  $mprg                  9     18
510 AD  $muky                 19     68
510 AD  $mrtn                 69     76
510 AD  $merm                 77    136
510 AD  $mmsg                 77     80
510 AD  $mtype                81     88
     *
510 AD  $mwhs2                19     20P 0
510 AD  $mpo2                 21     29
510 AD  $mseq                 30     32P 0
510 AD  $mitem                33     47
510 AD  $mqyr1                48     50P 0
510 AD  $mqyr2                51     53P 0
510 AD  $mqyr3                54     56P 0
510 AD  $mcwte                57     59P 0
510 AD  $mcwtt                60     64P 2
510 AD  $mcwta                65     68P 2

417zD * LICHIST - License history (Input Data)
417zD
417zDD**rparm          ds
417zDD**$rwhse                 1      3  0
417zDD**$rltrn                 4      7p 0
417zDD**$racfl                 8      9
417zDD**$rtrn#                10     13p 0
417zDD**$rlbl#                14     17p 0
417zDD**$rlcns                18     32
417zDD**$rfmlc                33     47
417zDD**$rorlc                48     62
417zDD**$rlqy1                63     66p 0
417zDD**$rlqy2                67     70p 0
417zDD**$rlqy3                71     74p 0
417zDD**$raqy1                75     78p 0
417zDD**$raqy2                79     82p 0
417zDD**$raqy3                83     86p 0
417zDD**$rfmcd                87     87
417zDD**$rfara                88    102
417zDD**$rfwhd               103    107
417zDD**$rfasl               108    110
417zDD**$rfloc               111    113  0
417zDD**$rflvl               114    115  0
417zDD**$rfhnd               116    117
417zDD**$rfslp               118    119p 0
417zDD**$rtocd               120    120
417zDD**$rtara               121    135
417zDD**$rtwhd               136    140
417zDD**$rtasl               141    143
417zDD**$rtloc               144    146  0
417zDD**$rtlvl               147    148  0
417zDD**$rthnd               149    150
417zDD**$rtslp               151    152p 0
417zDD**$rtord               153    156p 0
417zDD**$rtseq               157    159p 0
417zDD**$rexcd               160    167
417zDD**$radts               168    193
417zDD**$raemp               194    196p 0
417zDD**$rausr               197    206
417zDD**$rajob               207    216
417zDD**$rajbn               217    222
417zDD**$rcdts               223    248
417zDD**$rcemp               249    251p 0
417zDD**$rcusr               252    261
417zDD**$rcjob               262    271
417zDD**$rcjbn               272    277
417zDD**isc. work fields
417zDD**rdata          ds
417zDD**$rpo                   1      9
417zDD**$rseq                 10     12p 0
417zDD**$ritem                13     27
417zDD**$rlotc                28     57
417zDD**$rcwgt                58     62p 2
    D
     D rcv01           c                   const('Receiving')
     D rcv02           c                   const('Dock')
500cAD Clams           c                   const('CLAMS     ')
520aAD Shucked         c                   const('SHUCKED   ')
417dA*----------------------------------------------------------------
417dA*  Name constants
417dA*
     D valid           c                   const('0123456789 ABCDEFGHI-
     D                                     JKLMNOPQRSTUVWXYZabc-
     D                                     defghijklmnopqrstuvw-
     D                                     xyz')
GFCdA*
     D GLZvalid        c                   const('0123456789 ABCDEFGHI-
     D                                     JKLMNOPQRSTUVWXYZabc-
     D                                     defghijklmnopqrstuvw-
     D                                     xyz-')
SGCd D SGCvalid        c                   const('0123456789')
WSFa D WSFvalid        c                   const('0123456789')
VIP AD VIPallergen     c                   const('***Attention*** Alle-
VIP AD                                     rgen Item ***Attenti-
VIP AD                                     on***')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
     D @fmti2          c                   const('FRMTIT2')
     D @addtr          c                   const('ADDSTDTRN')
650dAD @crtrcv         c                   const('CRTRCVTRN')
417zDD*@llptr          c                   const('UPDLLPTRK')
740bAD @prtpg          c                   const('BFCPRTLBL')
510 AD @uci            c                   const('CW130')
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
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  erqty1                 1      4p 0
     D  erqty2                 5      8p 0
     D  eruom                  9     13
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
     D  opstyp                 1      1
     D  opwhdp                 2      6
     D  opum1                  7      8
     D  opdum                  9     23
     D  opcum                 24     43
     D  opcdiv                44     52  2
     D  opcaut                53     53
     D  opcwrn                54     54
     D  opcrng                55     57  1
     D  opwum                 58     72
     D  opxdsc                73     73
     *                                     117 117 OPTEND
     *  Receiving options.
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
     D  optend               117    117
610gA*----------------------------------------------------------------
610gA*  *SYSTEM   -  System options.
610gA*----------------------------------------------------------------
610gA*
610gA* Fields
610gA*
610gA*    OPUCI   -  Use UCI processing (Y,N)
610gA*----------------------------------------------------------------
610gA*
610gA* Data structure
610gA*
610gAD opdat4          ds
610hDD**opuci                 33     33
610hMD  opuci                 36     36
610gAD  op4end               117    117
416aA*  *FEATURE  -  PIR Feature options.
416aA*----------------------------------------------------------------
416aA*
416aA* Fields
416aA*
416aA*    OPFEAT  -  PIR Installed feature.
416aA*                 1=Locator system installed.
416aA*                 2=Full system installed.
416aA*                 3=Stand Alone system installed.
416aA*
416aA* Data structure
416aA*
416aAD opdat3          ds
416aAD  opfeat                 1      1
416aAD  op3end               117    117
     *----------------------------------------------------------------
     *  Program info data structure
     *
      /COPY *libl/qcopysrc,C#PGMINFDS
     D*               sds
     D* #prog            *proc
     D* #job                 244    253
     D* #user                254    263
     D* #jobn                264    269
     D* #jobdt               276    281  0
     D* #jobtm               282    287  0
640dA*----------------------------------------------------------------
640dA*  Prototypes
640dA*----------------------------------------------------------------
640dAD ha410           pr                  extpgm('HA410')
640dA * Input
640dAD   pparm                       80
650aAD   pparm1                      48    dim(20)
650fAD calcpti         pr                  extpgm('CALCPTI')
650fA * Input
650fAD   pGTIN                             like($lgtin)
650fAD   pLOT                              like(pplot)
650fAD   pPackDate                         like($pbcProdD)
650fAD   pPTI                              like(pppti)
650fAD ucilic#         pr                  extpgm('UCILIC#')
650fA * Input
650fAD   unext                       13  0 const
650fAD   uwhse                        3  0 const
730cA /copy qcopysrc,p.getoptio
730cA
730cAD getRecId        pr                  extpgm('GETRECID')
730cAD  pWhse                         3s 0 const
730cAD  pFile                        10    const
730cAD  pRecId                       11p 0
730cA
730cAD getAdjCode      pr                  extpgm('GETADJCOD')
730cAD  pCode                         2    const
730cAD  pDesc                        30
730cAD  pSys                          1

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
SGCdAD chklcns         ds
SGCdAD  chkoss2                1      2
SGCdAD  chk7lcns               1      7
SGCdAD  chk8lcns               8     15
WSFaAD WSFlcns         ds
WSFaAD  WSF99I                 1      3
WSFaAD  WSF7lcns               1      7
WSFaAD  WSF8lcns               8     15
     *----------------------------------------------------------------
640bA*  Verify Subprogram Variables.
640bA*
640bAD $vcommand       s              8
640bAD $vdesc          s             30
640bAD $vmessage       s             60
640bAD $vmsgk          s              4
640bAD $vprg           s             10
640bAD $vreturn        s             10
640bAD $vstat          s                   like($slstat)
PFCaA*----------------------------------------------------------------
PFCaA*  Constants/Variables for APT
PFCaA
PFCaAd aptsk1          c                   '*RCVBEG   '
PFCaA
PFCaAd logapt          s               n   inz(*on)

     *----------------------------------------------------------------
     *  Variables
     *
     D $adisp          s             12
     D $apslt          s             12
     D $astyp          s              1
600eAD $ewhdp          s              5
     D $msgf           s             10
650fAD $unext          s             13  0
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D blklcn          s             15
     D ck4err          s              1
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
650qAD curtime         s              6  0
650uAD dsecs           s             14  0
     D dummy           s              3  0
     D e               s              2  0
     D enter           s              5  0
417gDD*error           s              1
417gMD error           s               n
600cAD extstgFlag      s               n
     D forevr          s              1
     D gs1seqqty       s              5  0
     D help            s              5  0
650aAD hxwhse          s              3  0
650aAD hxpo            s              9
650aAD hxposeq         s              5  0
650aAD hxseq#          s              5  0
650aAD hxadduc         s               z
650aAD hxlcns          s             15
600dAD i               s              3  0
640hAD j               s              2  0
ICBaAD icbLcns         s               n
ICBaAD icbOlcn         s             15
650fAD k               s                   like($lnrcvqty)
     D k1aisl          s                   like(slaisl)
     D k3pick          s                   like(slpick)
     D k3stat          s                   like(slstat)
530aAD kystat          s                   like(slstat)
     D l               s              3  0
700bAD lblpgm          s                   like(oplpgm)
600dAD lcnsExists      s               n
     D locatr          s              1
530bAD lowumq2         s                   like($itumq2)
530bAD lowumq3         s                   like($itumq3)
650cDD*lwtqty          s              6  0
650cMD lwtqty          s              7  0
     D msgk            s              4  0
     D need1           s              5  0
     D need2           s              5  0
     D need3           s              5  0
600aAD newlbl#         s                   like(lblbl#)
600aAD noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')
417hAD nxtrec          s              5  0
     D nxtscr          s              3
     D ocode           s              8
600dAD ossLcns         s               n
     D pctr            s              3  0
650uAD pgmtracking     s               n
600aAD pllStampSys     s               z
600aAD pllStampUc      s               z
650dAD poppcs          s                   like(@ppcs)
     D posrec          s              4  0
     D ptqty           s              6  0
650fAd pplot           s             20
650fAd pppti           s              4  0
     D q1lft           s              5  0
     D q2lft           s              5  0
     D q3lft           s              5  0
510b D rcvdday         s              3
510b D rcvmday         s              3
510b D rcvuday         s              3
650dAD rcvpocomplete   s               n
     D reccnt          s              4  0
     D recno           s              4  0
     D redspl          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D rpal            s              3  0
     D savdsp          s             12
     D sclear          s              1
     D sflrec          s              5  0
530aAD sv_pdspcl       s              2
     D tmpflg          s              1
     D tmploc          s              3  0
     D today           s              8  0
     D today6          s              6  0
     D totqty          s              6  0
     D t1qty           s              6  0
     D t2qty           s              6  0
     D t3qty           s              6  0
650fAD unexta          s             13
     D uxflag          s              1
     D warn            s              1
650tAD wkwhse          s              3  0
650mDD*wtlqty          s              6  0
650mMD wtlqty          s              7  0
417iDD*x               s              2  0
417iMD x               s              5  0
     D xdkdri          s              1
     D xdkflg          s              1
     D xdkupd          s              1
     D xqty            s              6  0
     D xx              s              5  0
600aAD zmflag          s               n
600aAD zmsflag         s               n
500cAD $phdte          s              8  0
500cAD $phloc          s             20
500cAD $pcert          s             20
500cAD $pcode          s             10
500cAD $phhdr          s              1
500cAD $phdtl          s              1
500cAD $phcat          s              1
500cAD sav$pcmd        s              8
500cAD $plbl#          s              7  0
500cAD $plic#          s             15
500cAD $pqty           s              5  0
500cAD $pprt           s             10
500cAD $pform          s             10
PCKaAD @pttrn#         s              7  0
600cAD $p1qty          s              6  0
600cAD $p2qty          s              6  0
600cAD $p3qty          s              6  0

     D currtimestamp   s               z

500 AD #rcvarea        s              6
500 AD #rcvitem        s                   like($ititem)
500 AD #rcvtype        s                   like($ittype)
500 AD #rcvdesc        s                   like($itdesc)
500 AD #rcvpdsc        s                   like($itpdsc)
500 AD #rcvwhdp        s                   like($itwhdp)
500 AD #rcvstyp        s                   like($itstyp)
500 AD #rcvdesg        s                   like($itdesg)
500 AD #rcvum1         s                   like($itum1)
500 AD #rcvflg1        s                   like($itflg1)
500 AD #rcvum2         s                   like($itum2)
500 AD #rcvumq2        s                   like($itumq2)
500 AD #rcvflg2        s                   like($itflg2)
500 AD #rcvum3         s                   like($itum3)
500 AD #rcvumq3        s                   like($itumq3)
510bAD #rcvdday        s                   like($imdday)
510bAD #rcvmday        s                   like($immday)
510bAD #rcvmflg        s                   like($immflg)
510bAD #rcvuday        s                   like($imuday)
500 AD #rcvnrpk        s                   like($imnrpk)
500 AD #rcvflgd        s                   like($itflgd)
500 AD #rcvcube        s                   like($itcube)
500 AD #rcvswgt        s                   like($itswgt)
500 AD #rcvupc         s                   like($itupc)

500 AD #slotitem       s                   like($ititem)
500 AD #slottype       s                   like($ittype)
510 AD #rcvcwgt        s                   like($itcwgt)

730cAD useLicAdj       s               n
730cAD recidnum        s             11p 0
730cAD gaDesc          s             30a
730cAD gaSys           s              1a
730cAD getoptval       s            117a

650uA*----------------------------------------------------------------
650uA*  Time variables
650uA*----------------------------------------------------------------
650uA
650uAD CurrStamploc    s               z
650uAD CurrStampsys    s               z
650uAD CurrStampuc     s               z
650uA
650uAD bfcoffset       s              3  0 inz(0)
650uA*----------------------------------------------------------------
650uA* Function prototypes.
650uA*----------------------------------------------------------------
650uA
650uA /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *CHANGE  - Update licnese #.
     *              *VIEW    - View only
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key for everything by *ADD.
     *      $PUM1-3 Units of measure 1, 2, 3.
     *      $PFLAG  License option flag.
     *      $PVEN   Vendor number for *RECEIVE.
     *      $PVNAM  Vendor name for *RECEIVE.
     *      $PORD   Order number for *RETURN.
     *      $PEXPD  Expiration date.
     *      $PDEV   Printer device to use or *DEFAULT.
219 A*      $PDWGT  Catch weight
     *      $PFORM  Printer form to use or *DEFAULT.
     *
     *    Returned Parameters
     *      $PUKY   Unchanged.
     *      $PRTN   blank    - No problem encountered.
     *              *CANCEL  - Cancel, no update.
     *              *OK      - Update completed.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
     C                   parm                    $pum1             5
     C                   parm                    $pum2             5
     C                   parm                    $pum3             5
     C                   parm                    $pord             7 0
     C                   parm                    $pflag            1
     C                   parm                    $pseq             5 0
     C                   parm                    $pven            11 0
     C                   parm                    $pvnam           40
     C                   parm                    $pvitm           15
     C                   parm                    $pexpd            8 0
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm                    $pdwgt            9 2
417xAC                   parm                    $pawt1            7 2
417xAC                   parm                    $pawt2            7 2
417xAC                   parm                    $pawt3            7 2
417cAC                   parm                    $plotc           30
510bDC*                  parm                    $pmfdt
510bMC                   parm                    $pindt
417gAC                   parm                    $pfifo
417gAC                   parm                    $pupc            20
640eAC                   parm                    $pdecvalue       15
640eAC                   parm                    $pmfexpd          8 0
640eAC                   parm                    $pmfgdt           8 0
640fAC                   parm                    $plpn            50
640gAC                   parm                    $pgslcns         15
640gAC                   parm                    $pbrand          10
650aAC                   parm                    $parms1
650dAC                   parm                    $lsavetrn         7 0
650fAC                   parm                    $lgtin           14
650fAC                   parm                    $pbcProdD         6 0
650fAC                   parm                    $pbclot          20
650fAC                   parm                    $pw1pti           4 0
650pAC                   parm                    $posscode         1
     *
500cAC     po172p        plist
500cAC                   parm                    $parms
500cAC                   parm                    $pseq
500cAC                   parm                    $phdte
500cAC                   parm                    $phloc
500cAC                   parm                    $pcert
500cAC                   parm                    $pprt
500cAC                   parm                    $pform
650kAC                   parm                    $saToLcns
     *
500cAC     tagfmtP       plist
500cAC                   parm                    $pcmd
650sDC**                 parm                    $pwhse
650sMC                   parm      $pwhse        $pwhs
500cAC                   parm                    $ppo
500cAC                   parm                    $pseq
500cAC                   parm                    $pitem
500cAC                   parm                    #rcvdesc
650jDC*                  parm                    $plic#
650jMC                   parm      $LNLCNS       $plic#
500cAC                   parm                    $pqty
500cAC                   parm                    $phdte
500cAC                   parm                    $phloc
500cAC                   parm                    $pcert
500cAC                   parm                    $plbl#
500cAC                   parm                    $pprt
500cAC                   parm                    $pform
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
610aAC                   exsr      zsclr
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
650uAc                   exsr      zzstrt
     C     nxtscr        caseq     '01 '         sc1
415aAC     nxtscr        caseq     '02 '         sc2
     C                   endcs
650uAc                   exsr      zzend
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
600dAC                   exsr      zzwodltjob
     C                   exsr      zsclr
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
     *
     *R         NXTSCR    WHEQ '01 '
     *R                   EXFMTSCREEN1
     *
415aMC                   when      nxtscr = '02 '
730aDc*                  if        $pgslcns = ' ' or
730aMc                   if        $pgslcns = ' '  and $pflag = *on or
650eAc                             error = *on
415aMC                   exfmt     screen2
650eAc                   endif
     *
     *R         NXTSCR    WHEQ '03 '
     C                   when      nxtscr = '01 '
     C                   exsr      sfldsp
640gAc                   if        $pgslcns = ' ' or
640gAc                             error = *on
     C                   read      head1                                  50
640gAc                   endif
     *
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
     C                   setoff                                       363738
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
     C                   eval      nxtscr = '01 '
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
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
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft2
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget2
     C                   exsr      zzfil2
     C                   endif
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft3
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget3
     C                   exsr      zzfil3
     C                   endif
     C     end03i        endsr
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
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
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
409 D*R         *LOVAL    SETLLRECORD
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
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
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     redspl        cabeq     *on           endsc1
     C     error         cabeq     *on           endsc1
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
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
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
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
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
415aD**         *LOVAL    SETLLRECORD
415aD**         $PCMD     IFEQ '*ADD    '
415aD**                   MOVE '01 '     NXTSCR
415aD**                   ELSE
     C                   eval      nxtscr = 'EOJ'
415aD**                   ENDIF
     C                   eval      $prtn = '*CANCEL '
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
     C                   if        $pcmd = '*ADD    '  or
650qMC                             $pcmd = '*CHANGE '  or
650qAC                             $pcmd = '*NONE   '
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     redspl        cabeq     *on           endsc2
     C     error         cabeq     *on           endsc2
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Everything went fine so get out of program.
     *
415aD**                   MOVE 'EOJ'     NXTSCR
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
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr03i
     C                   endif
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C     *loval        setll     record
     C                   if        $pcmd = '*ADD    '
     C                   eval      nxtscr = '01 '
     C                   else
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc3
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
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     redspl        cabeq     *on           endsc3
     C     error         cabeq     *on           endsc3
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
     C     endsc3        endsr
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
650uAC     *dtaara       define    pgmtrack      pgmtracking
650uAC                   in        pgmtracking
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
     *  Initialize subfile values
     *
     *                    Z-ADD1         RECNO
     *                    WRITEDETAIL1                79
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
     C                   write     detail1
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
     C                   write     head1
     C                   eval      *in82 = *on
     C                   eval      *in83 = *off
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     **                   WRITEOPTREC
     C                   write     cmdrec
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     **                   WRITEPOSTNREC
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   if        reccnt > 0
     C                   eval      *in81 = *on
     C                   endif
     C                   eval      recno = posrec
     C                   write     head1
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
415aAC                   if        $pprg = 'PO200'
740aAc                             or $pprg = 'PO201'
650qAC                             or $pcmd = '*NONE   '
415aAC                   write     msgctl2
415aAC                   else
     C                   write     msgctl
415aAC                   endif
     C                   eval      msgk = *zeros
415aAC                   if        $pprg = 'PO200'
740aAc                             or $pprg = 'PO201'
650qAC                             or $pcmd = '*NONE   '
415aAC                   write     msgctl2
415aAC                   else
     C                   write     msgclr
415aAC                   endif
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
415aAC                   if        $pprg = 'PO200'
740aAc                             or $pprg = 'PO201'
650qAC                             or $pcmd = '*NONE   '
415aAC                   write     msgctl2
415aAC                   else
     C                   write     msgctl
415aAC                   endif
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     C     zmimsg        begsr
417gMC                   eval      #pgmq = #pgm
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
415aAC                   if        $pprg = 'PO200'
740aAc                             or $pprg = 'PO201'
650qAC                             or $pcmd = '*NONE   '
415aAC                   write     msgrec2
415aAC                   else
     C                   write     msgrec
415aAC                   endif
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
415aAC                   if        $pprg = 'PO200'
740aAc                             or $pprg = 'PO201'
650qAC                             or $pcmd = '*NONE   '
415aAC                   write     msgrec2
415aAC                   else
     C                   write     msgrec
415aAC                   endif
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
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

     *----------------------------------------------------------------
     *    DRI0001  Local system caused error
     *----------------------------------------------------------------

     C     zm0001        begsr
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
     *    DRI0001s Local system caused error (send to different program)
     *----------------------------------------------------------------

     C     zm0001s       begsr
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
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
500bA*----------------------------------------------------------------
500bA*      0105s
500bA*
500bAC     zm0105s       begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
RNZa *   PIR0110  Value must be > 0.
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
RNZa C                   endsr
     *----------------------------------------------------------------
     *   PIR0201  Code must be entered for create.
     *
     C     zm01          begsr
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO20033  License # required.
     *
     C     zm033         begsr
     C                   eval      #msgid = 'PO20033'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO20034  License already exists.
     *
     C     zm034         begsr
     C                   eval      #msgid = 'PO20034'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO23601  Total qty must equal total qty received.
     *
     C     zm036         begsr
     C                   eval      #msgid = 'PO23601'
     C                   eval      #msgtp = '*DIAG  '
     **                   Z-ADDPTQTY     ERQTY1
     **                   Z-ADDTOTQTY    ERQTY2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7871  Error in writing a record.
     *
     C     zm7871        begsr
     C                   eval      #msgid = 'PIR7871'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7872  Error in updating a record.
     *
     C     zm7872        begsr
     C                   eval      #msgid = 'PIR7872'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
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
     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Slot record is locked.
     *
     C     zm74          begsr
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
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0113  Field 1 must be greater than or equal to field 2.
     *
     C     zm0113        begsr
     C                   eval      #msgid = 'PIR0113'
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
     *   IT11021  Invalid item type entered.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'IT11021'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
650dAc                   exsr      zzrcvpocheck
     *
     *  When adding ....
     *
     C                   if        $pcmd = '*ADD    '
     C                   endif
     *
     C                   eval      error = *off
     C                   eval      totqty = 0
     C                   eval      t1qty = 0
     C                   eval      t2qty = 0
     C                   eval      t3qty = 0
640bA*
640bA*  Verify status code.

640bAC                   if        w1stat <> ' '
640bAC                   call(e)   'VFYSSTAT'
640bAC                   parm      '*VERIFY'     $vcommand
640bAC                   parm      '*NONE'       $vprg
640bAC                   parm      w1stat        $vstat
640bAC                   parm      ' '           $vdesc
640bAC                   parm      ' '           $vreturn
640bAC                   parm      ' '           $vmessage
640bAC                   parm      ' '           $vmsgk

640bAC                   select
640bAC                   when      %error
640bAC                   eval      error = *on
640bAC                   eval      *in20 = *on
640bAC                   eval      *in02 = *on
640bAC                   eval      errmsg = desc(11)
640bAC                   exsr      zm1001

640bAC                   when      $vreturn <> '*OK'
640bAC                   eval      error = *on
640bAC                   eval      *in20 = *on
640bAC                   eval      *in02 = *on
640bAC                   eval      errmsg = desc(11)
640bAC                   exsr      zm1001

640bAC                   endsl
640bAC                   endif
640bA*
640bAC                   if        w1stat = 'A'    or
640bAC                             w1stat = 'Z'    or
640bAC                             w1stat = 'V'
640bAC                   eval      error = *on
640bAC                   eval      *in20 = *on
640bAC                   eval      *in02 = *on
640bAC                   eval      errmsg = desc(12)
640bAC                   exsr      zm1001
640bAC                   endif
640bA*
416cD**                   MOVE *ZEROS    LCNS
416cMC                   eval      lcns = *blanks
     C                   eval      eruom = *blanks
     *
     *   Set cross dock indicators.
     *
     C                   if        w1xdk = 'Y'
     C                   eval      *in69 = *on
     C                   else
     C                   eval      *in69 = *off
     C                   endif
     *
     *   Verify changed subfile records.
     *
     C                   if        reccnt > 0
     C                   eval      posrec = 0
     C                   eval      *in79 = *off
     C                   dou       *in79
     C                   readc     detail1                                79
     *
     C                   if        *in79
     C                   leave
     C                   endif
     *
     C                   eval      *in13 = *off
     C                   eval      *in33 = *off
405 A*
405 A*  Only do checks for non-cross dock records.
405 A*
405 AC                   if        w1xdk <> 'Y'
     *
     *  Only do checks if licnese option is used.
405 AC                   if        $pflag = *on
     *
     *  License # must be entered if a qty is entered.
     C                   if        w1qty <> 0  and
416cD**         W1LCNS    ANDEQ0
416cMC                             w1lcns = *blanks
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   exsr      zm033
     C                   endif
416cA*
416cA*  Left justify license.
416cAC                   eval      $cstr = *blanks
416cAC                   move      w1lcns        $cstr
416cAC                   call      'ADJUST'
417aD*R                   PARM '*LEFT   '$CCMD   8
417aMC                   parm      '*LEFTNOZ'    $ccmd             8
416cAC                   parm                    $cstr            30
416cAC                   movel     $cstr         w1lcns
     *
417dAC                   eval      *in81 = *off
GFCaAC                   select
GFCaAC                   when      client = glazier
GFCaAC     GLZvalid      check     w1lcns                                 81
GFCaAC                   other
417dAC     valid         check     w1lcns                                 81
GFCaAC                   endsl
417dA*
417dA*  *IN81 = *ON - One of the positions did not have valid value
417dA*
417dAC                   if        *in81
417dAC                   eval      error = *on
417dAC                   eval      *in33 = *on
417dAC                   eval      *in13 = *on
417dAC                   eval      errmsg = desc(10)
417dAC                   exsr      zm1001
417dAC                   endif
     *
     *  If springfield verify license is 7 numeric long
     *
SGCdAC                   if        client = sgc
SGCdAC                   eval      chklcns = w1lcns
SGCdAC                   if        chkoss2 <> 'OS'
SGCdAC     SGCvalid      check     chk7lcns                               81
SGCdAC                   if        *in81 or chk8lcns<>*blanks
SGCdAC                   eval      error = *on
SGCdAC                   eval      *in33 = *on
SGCdAC                   eval      *in13 = *on
SGCdAC                   eval      errmsg = desc(10)
SGCdAC                   exsr      zm1001
SGCdAC                   endif
SGCdAC                   endif
SGCdAC                   endif
WSFaA*
WSFaAC                   if        client = WestSide
WSFaAC                   eval      WSFlcns = w1lcns
WSFaAC                   if        WSF99I  <> 'OS'
WSFaAC     WSFvalid      check     WSF7lcns                               81
WSFaAC                   if        *in81 or WSF8lcns<>*blanks
WSFaAC                   eval      error = *on
WSFaAC                   eval      *in33 = *on
WSFaAC                   eval      *in13 = *on
WSFaAC                   eval      errmsg = desc(10)
WSFaAC                   exsr      zm1001
WSFaAC                   endif
WSFaAC                   endif
WSFaAC                   endif
GFS A*
GFSaM*  If Get Fresh, verify license begins with 'G', F or K.
GFS A*
GFS AC                   if        client = getfresh
GFS A*
GFS AC                   if        %subst(w1lcns:1:1) <> 'G'
GFSaAC                             and %subst(w1lcns:1:1) <> 'F'
GFSaAC                             and %subst(w1lcns:1:1) <> 'K'
GFS AC                   eval      error = *on
GFS AC                   eval      *in33 = *on
GFS AC                   eval      *in13 = *on
GFS AC                   eval      errmsg = desc(10)
GFS AC                   exsr      zm1001
GFS AC                   endif
GFS A*
GFS AC                   endif
FPRaA*
FPRaA*  If Food Pro, verify license begins with 'F' or 'R'
FPRaA*
FPRaAC                   if        client = FoodPro
FPRaA*
FPRaAC                   if        %subst(w1lcns:1:1) <> 'F' and
FPRaAC                             %subst(w1lcns:1:1) <> 'R'
FPRbAC                             and %subst(w1lcns:1:1) <> 'P'
FPRaAC                   eval      error = *on
FPRaAC                   eval      *in33 = *on
FPRaAC                   eval      *in13 = *on
FPRaAC                   eval      errmsg = desc(10)
FPRaAC                   exsr      zm1001
FPRaAC                   endif
FPRaA*
FPRaAC                   endif
ICBa *
ICBa *  ICB - Default license if F9 was taken for OSS license.
ICBa *
ICBa C                   select
ICBa C                   when      client = icb or
ISPaAC                             client = ISupply
ICBa C                   if        w1lcns = 'OSS'
ICBa C                             and icblcns = *on
ICBa C                   eval      w1lcns = icbolcn
ICBa C                   endif
ICBa C                   if        w1lcns = 'OSS'
ICBa C                             and icblcns = *off
ICBa C                   eval      error = *on
ICBa C                   eval      *in33 = *on
ICBa C                   eval      *in13 = *on
ICBa C                   exsr      zm034
ICBa C                   endif
ICBa C                   endsl
ICBa *
     *  License # must be unique.
     *
416cD**         W1LCNS    IFNE 0
416cMC                   if        w1lcns <> *blanks
409 D*R         LCNSKY    SETLLLICENSE                  79
     C     fileky        setll     license                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   exsr      zm034
     C                   endif
650gA*
650gA*  Check LICLOG before accepting this license
650gA*
650lAc                   if        error = *off
650gAC                   exsr      clr$license
650gAC                   eval      $liToLcnsU = *on
650gAC                   eval      $liToLcns = w1lcns
650gAC                   eval      $liOLcnsU = *on
650gAC                   eval      $liOLcns = w1lcns
650gAC                   eval      $dricommand = '*LICENSE'
650gAC                   eval      $drisubcmd  = '%GETINFO'
650gAC                   eval      $drisys2upd = 'D'
650gAC                   eval      ck4err = *off
650gAC                   exsr      zzzdricop
650gAc* if we get an ok on the return this means it exist - don't use
650gAC                   if        $drireturn = '*OK'
650iAC                             and $liToAisl <> 'OSS'
650gAC                   eval      error = *on
650gAC                   eval      *in33 = *on
650gAC                   eval      *in13 = *on
650gAC                   exsr      zm034
650gAC                   endif
650lAC                   endif
720dAc                   if        $pgslcns = ' '
710bA*
710bA*  Check LICINFO before accepting this license
710bA*
710bAc                   if        error = *off
710bAC                   exsr      clr$licinfo
710bAC                   eval      $lnwhse  = $pwhse
710bAC                   eval      $lnlcns = w1lcns
710bAC                   eval      $dricommand = '*LICINFO'
710bAC                   eval      $drisubcmd  = '%GET'
710bAC                   eval      $drisys2upd = 'D'
710bAC                   eval      ck4err = *off
710bAC                   exsr      zzzdricop
710bAc* if it exist don't allow to use.
710bAC                   if        $drireturn = '*OK'
710bAC                   eval      error = *on
710bAC                   eval      *in33 = *on
710bAC                   eval      *in13 = *on
710bAC                   exsr      zm034
710bAC                   endif
710bAC                   endif
720dAc                   endif
600dA
600hA*  Skip OSS checks if error already occured.
600hA
600hAC                   if        not error
600dA
600dA*  If license found in licactive,
600dA*    then it must be an unused oss license.
600dA
600dAC                   exsr      zzchkoss
600dAC                   if        lcnsExists and not ossLcns
600dAC                   eval      error = *on
600dAC                   eval      *in33 = *on
600dAC                   eval      *in13 = *on
600dAC                   eval      errmsg = 'License ('
600dAC                                    + %trim(w1lcns)
600dAC                                    + ') already used'
600dAC                   exsr      zm0105
600dAC                   endif
600gA
600gA*  'OS' license must exist in LICACTIVE file.
600gA*  It would have been created with F9 label printing.
600gA*  If it doesn't exist then user probably backed out after
600gA*  printing, then got back in and is trying to use it.
600gA
600gAC                   if        %subst(w1lcns:1:2) = 'OS'
600dAC                             and not lcnsExists
600dAC                   eval      error = *on
600gAC                   eval      *in33 = *on
600gAC                   eval      *in13 = *on
600gAC                   eval      errmsg = 'Old OSS tag ('
600gAC                                    + %trim(w1lcns)
600gAC                                    + '), toss and print new one'
600gAC                   exsr      zm0105
600gAC                   endif
600hA
600hAC                   endif
415 A*
415 A*     Verify user hasn't scanned same license# multiple times.
415 A*
415 AC                   eval      l = 1
415 AC     w1lcns        lookup    lcns(1)                                80
415 AC                   select
415 AC                   when      *in80
415 A*
415 AC                   eval      error = *on
415 AC                   eval      *in33 = *on
415 AC                   eval      *in13 = *on
415 AC                   eval      errmsg = desc(9)
415 AC                   exsr      zm0105
415 A*
415 AC                   when      not *in80
415 A*
415 A*    License# not found.  Find next empty element.
415 AC                   eval      l = 1
416cAC                   eval      blklcn = *blanks
416cD**         0000000   LOKUPLCNS,L                   80
416cMC     blklcn        lookup    lcns(l)                                80
415 AC                   if        *in80
416cD**                   Z-ADDW1LCNS    LCNS,L
416cMC                   eval      lcns(l) = w1lcns
415 AC                   endif
415 A*
415 AC                   endsl
     C                   endif
     C                   endif
     *
405 AC                   endif
     *
     *  Accumulate quantities entered.
     *
409  C                   add       w1qty         totqty
     C                   if        w1umt = 'N'
409  C                   add       w1qty         t1qty
     C                   else
     C                   if        w1umt = '1'
409  C                   add       w1qty         t2qty
     C                   else
409  C                   add       w1qty         t3qty
     C                   endif
     C                   endif
     *
222 AC                   eval      *in85 = *on
     C                   update    detail1
     C                   if        posrec = 0
     C                   if        *in33
     C                   eval      posrec = recno
     C                   endif
     C                   endif
     C                   enddo
     *
     *  Quantities entered must equal total quantity.
     *
417hAC                   if        rtnrrn < reccnt
417hAC     rtnrrn        add       1             nxtrec
417hAC                   else
417hAC                   z-add     rtnrrn        nxtrec
417hAC                   endif
     *
530bAC                   if        #rcvumq2 = 0
530bAC                   eval      lowumq2 = 1
530bAC                   else
530bAC                   eval      lowumq2 = #rcvumq2
530bAC                   endif
530bAC                   if        #rcvumq3 = 0
530bAC                   eval      lowumq3 = 1
530bAC                   else
530bAC                   eval      lowumq3 = #rcvumq3
530bAC                   endif
530bAC                   eval      lwtqty = (t1qty * lowumq2 * lowumq3)
530bAC                                    + (t2qty * lowumq3)
530bAC                                    + t3qty
530bAC                   eval      wtlqty = (w1qrc1 * lowumq2 * lowumq3)
530bAC                                    + (w1qrc2 * lowumq3)
530bAC                                    + w1qrc3
     C                   select
     *
     *  BREAK2 UOM
     C                   when      t3qty <> w1qrc3
530bAC                             and wtlqty=0
530bA*  Above code added so when will not execute.
     C                   eval      eruom = w1um3
     C                   eval      erqty1 = t3qty
     C                   eval      erqty2 = w1qrc3
     C                   eval      error = *on
417hDC**                 eval      *in32 = *on
417hAC                   eval      posrec = nxtrec
417hAC     nxtrec        chain     detail1                            79
     C                   eval      *in12 = *on
417hAC                   eval      *in85 = *on
417hAC                   if        not *in79
417hAC                   update    detail1
417hAC                   endif
     C                   exsr      zm036
     *  BREAK1 UOM
     C                   when      t2qty <> w1qrc2
530bAC                             and wtlqty=0
530bA*  Above code added so when will not execute.
     C                   eval      eruom = w1um2
     C                   eval      erqty1 = t2qty
     C                   eval      erqty2 = w1qrc2
     C                   eval      error = *on
417hDC**                 eval      *in32 = *on
417hAC                   eval      posrec = nxtrec
417hAC     nxtrec        chain     detail1                            79
     C                   eval      *in12 = *on
417hAC                   eval      *in85 = *on
417hAC                   if        not *in79
417hAC                   update    detail1
417hAC                   endif
     C                   exsr      zm036
     *
     *  NORMAL UOM
     C                   when      t1qty <> w1qrc1
530bAC                             and wtlqty=0
530bA*  Above code added so when will not execute.
     C                   eval      eruom = w1um1
     C                   eval      erqty1 = t1qty
     C                   eval      erqty2 = w1qrc1
     C                   eval      error = *on
417hDC**                 eval      *in32 = *on
417hAC                   eval      posrec = nxtrec
417hAC     nxtrec        chain     detail1                            79
     C                   eval      *in12 = *on
417hAC                   eval      *in85 = *on
417hAC                   if        not *in79
417hAC                   update    detail1
417hAC                   endif
     C                   exsr      zm036
     *
     *  TOTAL  UOM
530bA*   Changed to use lowest UOM qty for compare.
530bMC                   when      lwtqty <> wtlqty
530bDC**                 when      totqty <> ptqty
     C                   eval      eruom = *blanks
530bDC**                 eval      erqty1 = totqty
530bDC**                 eval      erqty2 = ptqty
530bMC                   eval      erqty1 = lwtqty
530bMC                   eval      erqty2 = wtlqty
     C                   eval      error = *on
417hDC**                 eval      *in32 = *on
417hAC                   eval      posrec = nxtrec
417hAC     nxtrec        chain     detail1                            79
     C                   eval      *in12 = *on
417hAC                   eval      *in85 = *on
417hAC                   if        not *in79
417hAC                   update    detail1
417hAC                   endif
     C                   exsr      zm036
     C                   endsl
     *
     C                   if        posrec = 0
     C                   eval      posrec = 1
     C                   endif
     *
     C                   endif
     *
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 1 error checking.
     *
415aA*    Started using this routine in 4.15a
     *
     C     zzchk2        begsr
     C                   eval      error = *off
650dAc                   exsr      zzrcvpocheck
     *
     *   Update subfile record.
     *
     C     w2pctr        chain     detail1                            79
     C                   eval      w1qty = w2qty
416cD**                   Z-ADDW2LCNS    W1LCNS
416cMC                   eval      w1lcns = w2lcns
     C                   eval      *in85 = *on
     C                   update    detail1
     *
     *  Skip checks if crossdock or license option is not used.
     *
     C                   if        w1xdk = 'Y'  or
     C                             $pflag <> *on
     C                   goto      endck2
     C                   endif
     *
     *  License # must be entered.
     *
416cD**         W2LCNS    IFEQ 0
416cMC                   if        w2lcns = *blanks
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   exsr      zm033
     C                   goto      endck2
     C                   endif
700cA*
700cA*  Left justify license.
700cAC                   eval      $cstr = *blanks
700cAC                   move      w2lcns        $cstr
700cAC                   call      'ADJUST'
700cAC                   parm      '*LEFTNOZ'    $ccmd
700cAC                   parm                    $cstr
700cAC                   movel     $cstr         w2lcns
     *
417dAC                   eval      *in81 = *off
GFCaAC                   select
GFCaAC                   when      client = glazier
GFCaAC     GLZvalid      check     w2lcns                                 81
GFCaAC                   other
417dAC     valid         check     w2lcns                                 81
GFCaAC                   endsl
417dA*
417dA*  *IN81 = *ON - One of the positions did not have valid value
417dA*
417dAC                   if        *in81
417dAC                   eval      error = *on
417dAC                   eval      *in33 = *on
417dAC                   eval      *in13 = *on
417dAC                   eval      errmsg = desc(10)
417dAC                   exsr      zm1001
417dAC                   endif
     *
     *  License # must be unique.
     *
     C     lcnsky        setll     license                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   exsr      zm034
     C                   goto      endck2
     C                   endif
650gA*
650gA*  Check LICLOG before accepting this license
650gA*
650lAc                   if        error = *off
650gAC                   exsr      clr$license
650gAC                   eval      $liToLcnsU = *on
650gAC                   eval      $liToLcns = w1lcns
650gAC                   eval      $liOLcnsU = *on
650gAC                   eval      $liOLcns = w1lcns
650gAC                   eval      $dricommand = '*LICENSE'
650gAC                   eval      $drisubcmd  = '%GETINFO'
650gAC                   eval      $drisys2upd = 'D'
650gAC                   eval      ck4err = *off
650gAC                   exsr      zzzdricop
650gAc* if we get an ok on the return this means it exist - don't use
650gAC                   if        $drireturn = '*OK'
650gAC                   eval      error = *on
650gAC                   eval      *in33 = *on
650gAC                   eval      *in13 = *on
650gAC                   exsr      zm034
650gAC                   goto      endck2
650gAC                   endif
650lAC                   endif
740aAc                   if        $pgslcns = ' '
710bA*
710bA*  Check LICINFO before accepting this license
710bA*
710bAc                   if        error = *off
710bAC                   exsr      clr$licinfo
710bAC                   eval      $lnwhse  = $pwhse
710bAC                   eval      $lnlcns = w1lcns
710bAC                   eval      $dricommand = '*LICINFO'
710bAC                   eval      $drisubcmd  = '%GET'
710bAC                   eval      $drisys2upd = 'D'
710bAC                   eval      ck4err = *off
710bAC                   exsr      zzzdricop
710bAc* if it exist don't allow to use.
710bAC                   if        $drireturn = '*OK'
710bAC                   eval      error = *on
710bAC                   eval      *in33 = *on
710bAC                   eval      *in13 = *on
710bAC                   exsr      zm034
710bAC                   endif
710bAC                   endif
740aAc                   endif
510cA*
510cA*     Verify user hasn't scanned same license# multiple times.
510cA*
510cAC                   eval      l = 1
510cAC     w2lcns        lookup    lcns(1)                                80
510cAC                   select
510cAC                   when      *in80
510cA*
510cAC                   eval      error = *on
510cAC                   eval      *in33 = *on
510cAC                   eval      *in13 = *on
510cAC                   eval      errmsg = desc(9)
510cAC                   exsr      zm0105
510cAC                   goto      endck2
510cA*
510cAC                   when      not *in80
510cA*
510cA*    License# not found.  Find next empty element.
510cAC                   eval      l = 1
510cAC                   eval      blklcn = *blanks
510cAC     blklcn        lookup    lcns(l)                                80
510cAC                   if        *in80
510cAC                   eval      lcns(l) = w2lcns
510cAC                   endif
510cAC                   endsl
     *
     C     1             do        w2pal         xx
     C     xx            chain     detail1                            77
     C                   if        *in77  or
     C                             xx = w2pctr  or
     C                             w1xdk = 'Y'
     C                   iter
     C                   endif
     C                   if        w2lcns = w1lcns
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   exsr      zm034
     C                   goto      endck2
     C                   endif
     C                   enddo
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   eval      error = *off
650dAc                   exsr      zzrcvpocheck
     *
     C     endck3        endsr
415 A*----------------------------------------------------------------
415 A*
415 A*  ZZCHKM   Manual putaway final check.
415 A*
415 AC     zzchkm        begsr
     C                   eval      error = *off
650dAc                   exsr      zzrcvpocheck
     *
     C                   eval      totqty = 0
     C                   eval      t1qty = 0
     C                   eval      t2qty = 0
     C                   eval      t3qty = 0
     *
     *   Loop through changed subfile records and add/update file.
     *
     C     1             do        w2pal         xx
     C     xx            chain     detail1                            77
     C                   if        *in77
     C                   iter
     C                   endif
     *
     *  Accumulate quantities entered.
     *
409  C                   add       w1qty         totqty
     C                   if        w1umt = 'N'
409  C                   add       w1qty         t1qty
     C                   else
     C                   if        w1umt = '1'
409  C                   add       w1qty         t2qty
     C                   else
409  C                   add       w1qty         t3qty
     C                   endif
     C                   endif
     *
     C                   enddo
     *
     *  Quantities entered must equal total quantity.
     *
     C                   select
     *
     *  BREAK2 UOM
     C                   when      t3qty <> w1qrc3
     C                   eval      eruom = w1um3
     C                   eval      erqty1 = t3qty
     C                   eval      erqty2 = w1qrc3
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   exsr      zm036
     *  BREAK1 UOM
     C                   when      t2qty <> w1qrc2
     C                   eval      eruom = w1um2
     C                   eval      erqty1 = t2qty
     C                   eval      erqty2 = w1qrc2
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   exsr      zm036
     *
     *  NORMAL UOM
     C                   when      t1qty <> w1qrc1
     C                   eval      eruom = w1um1
     C                   eval      erqty1 = t1qty
     C                   eval      erqty2 = w1qrc1
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   exsr      zm036
     *
     *  TOTAL  UOM
     C                   when      totqty <> ptqty
     C                   eval      eruom = *blanks
     C                   eval      erqty1 = totqty
     C                   eval      erqty2 = ptqty
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   exsr      zm036
     C                   endsl
     *
     C     endckm        endsr
600dA*----------------------------------------------------------------
600dA*
600dA*  ZZCHKOSS   Check if license is an OSS license
600dA*
600dAC     zzchkoss      begsr
     C                   eval      lcnsExists = *off
     C                   eval      ossLcns = *off

     *  See if license exists in licactive file.

     C                   exsr      clr$license
     C                   eval      $liToLcnsU = *on
     C                   eval      $liToLcns = w1lcns
     C                   eval      $dricommand = '*LICENSE'
     C                   eval      $drisubcmd  = '%GETLCNS'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      zmflag  = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      lcnsExists = *off
     C                   eval      error = *off
     C                   leavesr
     C                   else
     C                   eval      lcnsExists = *on
     C                   endif

     *  Now see if it is an unused oss license.

     C                   if        $liToAisl <> 'OSS'
     C                             or $liToCode <> 'D'
     C                             or $liToItem <> $pitem
     C                             or $liToRQty1 <> 0
     C                             or $liToRQty2 <> 0
     C                             or $liToRQty3 <> 0
     C                   eval      ossLcns = *off
     C                   else
     C                   eval      ossLcns = *on
     C                   endif

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
DRYcAC     client        wheneq    DAIRYLAND
640bAC     csrfld        wheneq    'W1STAT'
640bAC                   eval      $lcmd = '*LOOKUP '
640bAC                   eval      $lstat = w1stat
640bAC                   call      'SS900'
640bAC                   parm                    $lparm
640bAC                   if        $lrtn = '*SELECT '
640bAC                   eval      w1stat = $lstat
640bAC                   endif
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
     C                   endif
     *
600cA*  Test for F9  - External Storage License Print
600cA*
600cAC                   if        *inki
650pAc                             and $posscode = ' '
600cAC                   eval      cmdtkn = *on
600cAC                   exsr      zzextstg
600cAC                   goto      endcm1
600cAC                   endif
     *
610bA*
610bA*  Test for F8  - Produce Label
610bA*
610bAC                   if        *inkh
610bAC                   eval      cmdtkn = *on
610bAC                   exsr      zzprdlbl
610bAC                   goto      endcm1
610bAC                   endif
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
     *
     C                   select
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
415aA*
415aA*  Test for F7 - Lookup
415aA*
415aAC                   if        *inkg
415aAC                   eval      cmdtkn = *on
415aAC                   if        w2pctr > 1
415aAC                   eval      w2pctr = w2pctr - 1
415aAC                   exsr      scr02i
415aAC                   endif
415aAC                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 1.
     *
     C     zzcmd3        begsr
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
     *
     *     Build code.
     *
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm3
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm3        endsr
     *----------------------------------------------------------------
530aA*
530aA*  ZZCRXD   Use DRISLOT with %CRTXDOCK to get existing cross
530aA*           dock slot or create new one.
530aA*
530aAC     zzcrxd        begsr
530aA*
     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #rcvwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = savdsp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = #rcvitem
     C                   eval      $slaislu = *on
700dAc                   eval      $slexpd = $pexpd
700dAc                   eval      $slexpdu = *on
CSP AC                   if        client = CoastalSunbelt
CSP AC                             and sv_pdspcl = 'XD'
CSPaAC                   if        $itdesg = 'PC'
CSPaAC                   eval      $slaisl = ' PC'
CSPaAC                   else
CSP AC                   eval      $slaisl = 'JIT'
CSPaAC                   endif
CSP AC                   else
     C                   eval      $slaisl  = 'XDK'
CSP AC                   endif
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd = '%CRTXDOCK'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error = *on
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   exsr      sflclr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT3   Get default values for add.
     *
     C     zzdft3        begsr
     *
     C                   exsr      sflclr
     C                   endsr
650uA*----------------------------------------------------------------
650uA*
650uA*  ZZEND   End timer
650uA*
650uAC     zzend         begsr
     *
650uAc                   eval      pgtnsc = nxtscr
650uAC                   callp     getmicrotime(currstampuc:currstampsys)
650uAc                   eval      pgtEndts = currstampsys
     *
650uAc     pgtEndts      subdur    pgtStrts      dsecs:*s
650uAc                   eval(h)   pgtsec = dsecs
650uA*
650uAC                   eval      pgtjob = #job
650uAC                   eval      pgtusr = #user
650uAC                   move      #jobn         pgtjb#
     *
650uAC                   if        pgmtracking
650uAC                   write     pgtrec
650uAC                   endif
     *
650uAC     endzze        endsr
650uA*----------------------------------------------------------------
650uA*
650uA*  ZZENDP  End timer - call to another program
650uA*
650uAC     zzendp        begsr
     *
650uAc                   eval      pgtnsc = 'PO236'
650uAC                   callp     getmicrotime(currstampuc:currstampsys)
650uAc                   eval      pgtEndts = currstampsys
     *
650uAc     pgtEndts      subdur    pgtStrts      dsecs:*s
650uAc                   eval(h)   pgtsec = dsecs
     *
650uAC                   eval      pgtjob = #job
650uAC                   eval      pgtusr = #user
650uAC                   move      #jobn         pgtjb#
     *
650uAC                   if        pgmtracking
650uAC                   write     pgtrec
650uAC                   endif
     *
650uAC     endzzep       endsr
600cA*----------------------------------------------------------------
600cA*
600cA*  ZZEXTSTG   External Storage Label creation
600cA*
     C     zzextstg      begsr
     C                   eval      $ewhdp = #rcvwhdp
     C                   eval      w3dev  = '*JOB'
     C                   eval      w3stg  = 'E'

     *  Springfield setup defaults for screen

     C                   if        client = sgc
SGCeA*  Protect stage field
SGCeAC                   eval      *in95 = *on
     C                   if        $ewhdp = 'DRY  '
     C                   eval      w3stg = 'K'
SGCbAC                   eval      w3dev  = 'LP8'
     C                   else
     C                   eval      w3stg = 'W'
SGCbAC                   eval      w3dev  = 'LP7'
     C                   endif
SGCbDC**                 eval      w3dev  = 'LP8       '
     C                   endif

     *  Eastland setup defaults for screen

EFCaAC                   if        client = eastland
EFCaA*  Protect stage field
EFCaAC                   eval      *in95 = *on
EFCaAC                   if        $ewhdp = 'CB   '
EFCaAC                   eval      w3stg = 'G'
EFCaAC***                eval      w3dev  = 'LP8'
EFCaAC                   else
EFCaAC                   eval      w3stg = 'F'
EFCaAC***                eval      w3dev  = 'LP7'
EFCaAC                   endif
EFCaAC                   endif

     *  Process window to produce license plates for external storage

     C                   dow       forevr = forevr
     C                   exfmt     WEXTSTG
     C                   if        *inkl = *on
     C                   leave
     C                   endif

     C                   eval      *in92 = *off
     C                   eval      *in93 = *off
610eAC                   eval      *in94 = *off
SGCeAC                   eval      *in95 = *off

     *     Make sure staging is not blank

610eAC                   if        w3stg = ' '
610eAC                   eval      *in94 = *on
610eAC                   iter
610eAC                   endif

     *     Check number of pallets entered

     C                   if        rpal < w3pal
     C                   eval      *in92 = *on
     C                   iter
     C                   endif

     *     Number of pallets cannot be zero

     C                   if        w3pal = 0
     C                   eval      *in93 = *on
     C                   iter
     C                   endif


     *     No errors, create slots and print labels

     C                   eval      extstgFlag = *on
     C                   for       i = 1 to w3pal
     C                   exsr      zzextstg2
ICBaAC                   eval      icblcns = *off
ICBaAC                   eval      icbolcn = *blanks
     C                   if        error
     C                   leave
     C                   endif
ICBaAC                   if        client = icb or
ISPaAC                             client = ISupply
ICBaAC                   eval      icbolcn = wklic
ICBaAC                   eval      icblcns = *on
ICBaAC                   endif
     C                   endfor
     C                   leave

     C                   enddo

     C                   endsr
650pA*----------------------------------------------------------------
650pA*
650pA*  ZZEXTSTGNEW  New Oss Receiving
650pA*
650pAC     zzextstgnew   begsr
650pAC                   eval      $ewhdp = #rcvwhdp
650pAC                   eval      w3dev  = '*JOB'
650pAC                   eval      w3stg  = $posscode
650pAC                   eval      w3pal = 1
650pA
650pA*  Springfield setup defaults for screen
650pA
650pA*  May need to use the setup of w3dev for sgc - come back
650pAC                   if        client = sgc
650pA*  Protect stage field
650pAC                   eval      *in95 = *on
650pAC                   if        $ewhdp = 'DRY  '
650pAC                   eval      w3dev  = 'LP8'
650pAC                   else
650pAC                   eval      w3dev  = 'LP7'
650pAC                   endif
650pAC                   endif
650pA
650pA*  Eastland setup defaults for screen
650pA
650pAC                   if        client = eastland
650pA*  Protect stage field
650pAC                   eval      *in95 = *on
650pAC                   if        $ewhdp = 'CB   '
650pAC                   else
650pAC                   endif
650pAC                   endif
650pA
650pA*  Process
650pA
650pAC                   dow       forevr = forevr
650pA
650pAC                   eval      *in92 = *off
650pAC                   eval      *in93 = *off
650pAC                   eval      *in94 = *off
650pAC                   eval      *in95 = *off
650pA
650pA*     No errors, create slots
650pA
650pAC                   eval      extstgFlag = *on
650pAC                   for       i = 1 to w3pal
650pAC                   exsr      zzextstg2New
650pAC                   eval      icblcns = *off
650pAC                   eval      icbolcn = *blanks
650pAC                   if        error
650pAC                   leave
650pAC                   endif
650pAC                   if        client = icb
650pAC                   eval      icbolcn = wklic
650pAC                   eval      icblcns = *on
650pAC                   endif
650pAC                   endfor
650pAC                   leave
650pA
650pAC                   enddo
650pA
650pAC                   endsr
600dA*----------------------------------------------------------------
600dA*
600dA*  ZZEXTSTG2  Create OSS slot
600dA*
600dAC     zzextstg2     begsr

     *  Set #rcvarea to apppropriate OSS area.

     C                   select

SGCaAC                   when      client = sgc
SGCaAC                             and w3stg = 'K'
SGCaAC                   eval      #rcvarea = 'KANSAS'

SGCaAC                   when      client = sgc
SGCaAC                             and w3stg = 'W'
SGCaAC                   eval      #rcvarea = 'WILLOW'

EFCaAC                   when      client = eastland
EFCaAC                             and w3stg = 'G'
EFCaAC                   eval      #rcvarea = 'CGEN'

EFCaAC                   when      client = eastland
EFCaAC                             and w3stg = 'F'
EFCaAC                   eval      #rcvarea = 'CFROZ'

     C                   other
     C                   eval      #rcvarea = w3stg

     C                   endsl

     *  Create special license

     C                   call      'PIROSSLCN'
     C                   parm                    $pwhse
     C                   parm                    w3stg
     C                   parm      ' '           wklic            15

     *  Initialize slot fields

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #rcvwhdp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = #rcvitem
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = ' '
640bAC                   eval      $slstatu = *on
DRYcAC                   if        client = dairyland
DRYcAC                   eval      $slstat  = 'O'
DRYcAc                   else
640bAC                   eval      $slstat  = w1stat
DRYcAc                   endif
     C                   eval      $slstypu = *on
     C                   eval      $slstyp = #rcvstyp
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd = $pexpd
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = #rcvitem

     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = 0
     C                   eval      $saqty2 = 0
     C                   eval      $saqty3 = 0

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'OSS'
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
     C                   eval      $saToLcns = wklic
     C                   eval      $saOLcnsU = *on
     C                   eval      $saOLcns = wklic

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%OSSIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      zmflag  = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   leavesr
     C                   endif

     *  Create workoss record

     C                   eval      wowhse  = $slwhse
     C                   eval      wowhdp  = $slwhdp
     C                   eval      wodisp  = $sldisp
     C                   eval      wolcns  = wklic
     C                   eval      woaddts   = %timestamp()
     C                   eval      woaddcusr = #curruser
     C                   eval      woaddjob  = #job
     C                   eval      woaddnbr  = #jobnbr
     C                   write(e)  worec

     *  Print label

     C                   eval      $plfmt = 'STORAGE'
     C                   select
     C                   when      client = sgc
SFGfD ***                eval      $plset = 'STOSFG'
SFGfMC                   eval      $plset = 'ZBRSF2'
EFCaAC                   when      client = eastland
EFCaAC                   eval      $plset = 'ZBREFC'
     C                   other
     C                   eval      $plset = 'PLBL40'
     C                   endsl
      *
600eAC                   if        w3dev <> '*JOB'
600eAC                   eval      $pdev  = w3dev
600eAC                   endif

     C                   eval      $pexpda = %editc($pexpd:'X')
     C                   eval      $pindta = %editc(today:'X')

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
     C                   parm                    wklic            15
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

     C                   endsr
650pA*----------------------------------------------------------------
650pA*
650pA*  ZZEXTSTG2New  Create OSS slot
650pA*
650pAC     zzextstg2New  begsr
650pA
650pA*  Set #rcvarea to apppropriate OSS area.
650pA
650pAC                   select
650pA
650pAC                   when      client = sgc
650pAC                             and w3stg = 'K'
650pAC                   eval      #rcvarea = 'KANSAS'
650pA
650pAC                   when      client = sgc
650pAC                             and w3stg = 'W'
650pAC                   eval      #rcvarea = 'WILLOW'
650pA
650pAC                   when      client = eastland
650pAC                             and w3stg = 'G'
650pAC                   eval      #rcvarea = 'CGEN'
650pA
650pAC                   when      client = eastland
650pAC                             and w3stg = 'F'
650pAC                   eval      #rcvarea = 'CFROZ'
650pA
650pAC                   other
650pAC                   eval      #rcvarea = w3stg
650pA
650pAC                   endsl
650pA
650pA*  Initialize slot fields
650pA
650pAc                   eval      wklic = w1lcns
650pAC                   exsr      clr$slot
650pAC                   eval      $slwhseu = *on
650pAC                   eval      $slwhse  = $pwhse
650pAC                   eval      $slwhdpu = *on
650pAC                   eval      $slwhdp  = #rcvwhdp
650pAC                   eval      $slitemu = *on
650pAC                   eval      $slitem  = #rcvitem
650pAC                   eval      $sldispu = *on
650pAC                   eval      $sldisp  = ' '
650pAC                   eval      $slstatu = *on
DRYcAC                   if        client = dairyland
DRYcAC                   eval      $slstat  = 'O'
DRYcAC                   else
650pAC                   eval      $slstat  = w1stat
DRYcAC                   endif
650pAC                   eval      $slstypu = *on
650pAC                   eval      $slstyp = #rcvstyp
650pAC                   eval      $slexpdu = *on
650pAC                   eval      $slexpd = $pexpd
650pAC                   eval      $saitemu = *on
650pAC                   eval      $saitem  = #rcvitem
650pA
650pAC                   eval      $saqtyu = *on
650pAC                   eval      $saqty1 = 0
650pAC                   eval      $saqty2 = 0
650pAC                   eval      $saqty3 = 0
650pA
650pAC                   eval      $saActionU = *on
650pAC                   eval      $saAction = 'OSS'
650pAC                   eval      $saTrn#U = *on
650pAC                   eval      $saTrn# = 0
650pAC                   eval      $saETrn#U = *on
650pAC                   eval      $saETrn# = 0
650pAC                   eval      $saLbl#U = *on
650pAC                   eval      $saLbl# = 0
650pAC                   eval      $saToPosU = *on
650pAC                   eval      $saToPos = 1
650pAC                   eval      $saToVrfyU = *on
650pAC                   eval      $saToVrfy = 'N'
650pAC                   eval      $saToCodeu = *on
650pAC                   eval      $saToCode = 'D'
650pAC                   eval      $saToAreaU = *on
650pAC                   eval      $saToArea = #rcvarea
650pA
650pAC                   eval      $saToLcnsU = *on
650pAC                   eval      $saToLcns = wklic
650pAC                   eval      $saOLcnsU = *on
650pAC                   eval      $saOLcns = wklic
650pA
650pAC                   eval      $dricommand = '*SLOT'
650pAC                   eval      $drisubcmd  = '%OSSIN'
650pAC                   eval      $drisys2upd = 'D'
650pAC                   eval      ck4err = *on
650pAC                   eval      zmflag  = *on
650pAC                   exsr      zzzdricop
650pAC                   if        error
650pAC                   leavesr
650pAC                   endif
650pA
650pA*  Create workoss record  - not sure I need to do this
650pA
650pAC                   eval      wowhse  = $slwhse
650pAC                   eval      wowhdp  = $slwhdp
650pAC                   eval      wodisp  = $sldisp
650pAC                   eval      wolcns  = wklic
650pAC                   eval      woaddts   = %timestamp()
650pAC                   eval      woaddcusr = #curruser
650pAC                   eval      woaddjob  = #job
650pAC                   eval      woaddnbr  = #jobnbr
650pAC                   write(e)  worec
650pA
650pAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *   Move PO
     *
     C                   eval      w1po = $ppo
     *
     *   Move qtys
     *
     C                   eval      w1qrc1 = $prq1
     C                   eval      w1qrc2 = $prq2
     C                   eval      w1qrc3 = $prq3
     C                   eval      w1um1 = $pum1
     C                   eval      w1um2 = $pum2
     C                   eval      w1um3 = $pum3
     C                   eval      rpal = $prpal
     *
     *   Increment # of Pallets if multiple units of measure received.
     *
     C                   eval      pctr = 0
     C                   if        w1qrc1 <> 0
     C                   add       1             pctr
     C                   endif
     C                   if        w1qrc2 <> 0
     C                   add       1             pctr
     C                   endif
     C                   if        w1qrc3 <> 0
     C                   add       1             pctr
     C                   endif
     C                   if        pctr > 0
     C                   eval      pctr = pctr - 1
     C                   add       pctr          rpal
     C                   endif
     *   Allow license field entry and display.
     C                   if        $pflag = *on
     C                   eval      *in68 = *off
700bAC                   eval      *in70 = *off
     C                   else
     C                   eval      *in68 = *on
700bAC                   eval      *in70 = *on
     C                   endif
     *
     C                   exsr      sflclr
     C                   eval      xdkflg = *off
     C                   eval      savdsp = *blanks
     C     1             do        rpal          x
     C                   eval      w1qty = 0
     C                   eval      w1umt = *blanks
     C                   eval      w1uom = *blanks
416cD**                   Z-ADD0         W1LCNS
416cMC                   eval      w1lcns = *blanks
640gAc                   if        $pgslcns <> ' '
640gAc                   eval      w1lcns = $pgslcns
640gAc                   endif
     C                   if        xdkflg = *off
     C                   exsr      zzpxdk
     C                   eval      xdkflg = *on
     C                   endif
416aD**                   MOVE SAVDSP    W1DISP
416aMC                   eval      w1disp = *blanks
416aD**                   MOVELSAVDSP    SVAISL  3
416aAC                   eval      w1xdk = *blanks
     *
     C                   select
     C                   when      need3 > 0
416aAC                   eval      w1disp = savdsp
416aAC                   eval      w1xdk = 'Y'
     C                   eval      w1qty = need3
     C                   eval      w1umt = '2'
TPCaAC                   if        client <> tpc
SGCcAC                             and client <> sgc
RYLaAC                             and client <> royal
530aDC**                 add       1             rpal
TPCaAC                   endif
     C                   eval      need3 = 0
     *
     C                   when      need2 > 0
416aAC                   eval      w1disp = savdsp
416aAC                   eval      w1xdk = 'Y'
     C                   eval      w1qty = need2
     C                   eval      w1umt = *on
TPCaAC                   if        client <> tpc
SGCcAC                             and client <> sgc
RYLaAC                             and client <> royal
530aDC**                 add       1             rpal
TPCaAC                   endif
     C                   eval      need2 = 0
     *
     C                   when      need1 > 0
416aAC                   eval      w1disp = savdsp
416aAC                   eval      w1xdk = 'Y'
     C                   eval      w1qty = need1
     C                   eval      w1umt = 'N'
TPCaAC                   if        client <> tpc
SGCcAC                             and client <> sgc
RYLaAC                             and client <> royal
530aDC**                 add       1             rpal
TPCaAC                   endif
     C                   eval      need1 = 0
     *
417 MC                   when      pctr > 0
417 D*R         PCTR      WHGE 0
416eD*R         PCTR      WHGT 0
415dD**         PCTR      WHGE 0
     C                   if        q3lft <> 0
     C                   eval      w1qty = q3lft
     C                   eval      q3lft = 0
     C                   eval      w1umt = '2'
     C                   eval      pctr = pctr - 1
     C                   else
     C                   if        q2lft <> 0
     C                   eval      w1qty = q2lft
     C                   eval      q2lft = 0
     C                   eval      w1umt = *on
     C                   eval      pctr = pctr - 1
     C                   else
     C                   eval      w1umt = 'N'
     C                   eval      pctr = 0
410 AC                   eval      rpal = rpal - 1
     C                   endif
     C                   endif
     *
     C                   other
417gA*
417gA*    Only 2nd breakdown qty received. Use brkdn 2 u/m.
417gAC                   select
417gAC                   when      w1qrc3 > 0  and
417gAC                             w1qrc2 = 0  and
417gAC                             w1qrc1 = 0
417gAC                   eval      w1umt = '2'
417gA*
417gA*    Only 1st breakdown qty received. Use brkdn 1 u/m.
417gAC                   when      w1qrc2 > 0  and
417gAC                             w1qrc3 = 0  and
417gAC                             w1qrc1 = 0
417gAC                   eval      w1umt = *on
417gA*
417gA*    Only case qty received. Use case u/m.
417gAC                   other
     C                   eval      w1umt = 'N'
417gAC                   endsl
     C                   endsl
     *
409  **         W1QTY     IFGT PTQTY
409  **                   EXSR ZZXQTY
409  **                   Z-ADDXQTY      W1QTY
409  **                   ENDIF
416aD**         NEED1     IFEQ 0
416aD**         NEED2     ANDEQ0
416aD**         NEED3     ANDEQ0
416aD**                   MOVE *BLANKS   SAVDSP
416aD**                   ENDIF
     *
416aD**         SVAISL    IFEQ 'XDK'
416aMC                   if        w1xdk = 'Y'
416aD**                   MOVE 'Y'       W1XDK
405 AC                   eval      *in69 = *on
405 A**                   MOVE *ON       *IN90
405 AC                   else
416aD**                   MOVE ' '       W1XDK
     C                   eval      *in69 = *off
     **                   MOVE *OFF      *IN90
     C                   endif
     *
     C                   select
     C                   when      w1umt = '1'
     C                   eval      w1uom = w1um2
     *
     C                   when      w1umt = '2'
     C                   eval      w1uom = w1um3
     *
     C                   other
     C                   eval      w1uom = w1um1
     C                   endsl
500bA
500bA*    If qty is 0 and only a single pallet is being received,
500bA*      Then we assume that we are receiving 1 pallet of normal qty
500bA*           and set the subfile qty to the total qty being received
500bA
500bAC                   eval      *in13 = *off
640cAC                   eval      *in12 = *off
720cAc                   select
720cAc                   when      $pgslcns <> ' ' and $ifrcvmth = '2'
730bAc                             or $pcmd = '*NONE'
500bAC                   if        w1qty = 0 and $prpal = 1
720cAc                   select
720cAc                   when      $prq1 > 0
500bAC                   eval      w1qty = $prq1
720cAc                   when      $prq2 > 0
500bAC                   eval      w1qty = $prq2
720cAc                   when      $prq3 > 0
500bAC                   eval      w1qty = $prq3
720cAc                   endsl
500bAC                   eval      *in13 = *on
640cAc                   else
640cAc                   eval      *in12 = *on
500bAC                   endif
720cAc                   other
500bAC                   if        w1qty = 0 and $prpal = 1
500bAC                   eval      w1qty = $prq1
500bAC                   eval      *in13 = *on
640cAc                   else
640cAc                   eval      *in12 = *on
500bAC                   endif
720cAc                   endsl
500bA
     *
     C                   exsr      sfladd
     C                   enddo
VIP A*
VIP AC                   if        client = VIP
VIP A*
VIP AC                   if        $pcode = 'ALLERGEN'
VIP AC                   eval      *in45 = '1'
VIP AC                   eval      w1msg = vipallergen
VIP AC                   else
VIP AC                   eval      *in45 = '0'
VIP AC                   eval      w1msg = ' '
VIP AC                   endif
VIP A*
VIP AC                   endif
VIP A*
     C                   eval      posrec = 1
640bAC                   eval      w1stat = *blank
DRYbAC                   if        client = dairyland
DRYbAC                   eval      w1stat = $QUstat
DRYbAc                   endif
650pA * OSS Receiving
650pA /free
650pA     w1note = ' ';
650pA     *in96 = '0';
650pA   if $posscode <> ' ';
650pA     w1note = 'OSS Receiving';
650pA     *in96 = '1';
650pA   endif;
DRYcA   if client = dairyland;
DRYcA     *in67 = *on;
DRYcA   else;
DRYcA     *in67 = *off;
DRYcA   endif;
650pA /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
415aA*    Started using this routine in 4.15a
     *
     C     zzfil2        begsr
     *
     *   Get subfile record.
     *
     C     w2pctr        chain     detail1                            79
     C                   eval      w2po = w1po
     C                   eval      w2line = $pseq
     C                   eval      w2item = woitem
     C                   eval      w2qty = w1qty
650rDC*                  move      w1uom         w2um
650rMC                   movel     w1uom         w2um
     C                   eval      w2tihi = prfth
416cD**                   Z-ADDW1LCNS    W2LCNS
650eAc                   if        $pgslcns <> ' '
650eAc                   eval      w2lcns = $pgslcns
650eAc                   else
416cMC                   eval      w2lcns = w1lcns
650eAc                   endif
     C                   if        w1xdk = 'Y'
     C                   eval      w2xdk = 'XDK'
     C                   eval      *in69 = *on
     C                   else
     C                   move      '   '         w2xdk
     C                   eval      *in69 = *off
     C                   endif
     *
     *   Allow license field entry and display.
     *
     C                   if        $pflag = *on
     C                   eval      *in68 = *off
700bAC                   eval      *in70 = *off
     C                   else
     C                   eval      *in68 = *on
700bAC                   eval      *in70 = *on
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr

      * get item category

500cAC                   call      'GETICAT'
500cAC                   parm                    $pwhse
500cAC                   parm                    $pitem
500cAC                   parm                    $pcode
500cAC                   parm                    $phhdr
500cAC                   parm                    $phdtl
500cAC                   parm                    $phcat

     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 2.
     *
     C     zzget2        begsr
     C     endgt2        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET3   Get record(s) for screen 3.
     *
     C     zzget3        begsr
     C     endgt3        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
510aA
510aA* Get client id.
510aA
510aAC                   call      'GETCLIENT'
510aAC                   parm                    client           10
     *
     *  Define key for LICENSE file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    w1lcns
     *
     *  Define partial key for item LABEL file.
     *
     C     partk2        klist
     C                   kfld                    $pord
     C                   kfld                    $pwhse
     *
     *  Define key for PIRITEM file.
     *
     C     itkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     *
     *  Define key for LICENSE file.
     *
     C     lcnsky        klist
     C                   kfld                    $pwhse
     C                   kfld                    w1lcns
     *
     *     OPTIONS
     *
     C     opkey         klist
650tDC*                  kfld                    $pwhse
650tMC                   kfld                    wkwhse
     C                   kfld                    ocode
     *
     *  Define key for PODTL file.
     *
     C     keypd         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
     C                   kfld                    $pseq
     C                   kfld                    $pitem
404 A*
404 A*  Define key for CrossDk2 file.
404 A*
404 AC     keycd2        klist
404 AC                   kfld                    $pwhse
404 AC                   kfld                    $ppo
404 AC                   kfld                    $pseq
     *
530aA*  Define key for slot10 file.
530aA*
530aAC     keys10        klist
530aAC                   kfld                    $pwhse
530aAC                   kfld                    $pitem
530aAC                   kfld                    kystat
     *
     *  Define key for ORDD file for cross dock.
     *
530aDC**   keyod         klist
530aDC**                 kfld                    $pwhse
530aDC**                 kfld                    cdord
530aDC**                 kfld                    cdorsq
530aDC**                 kfld                    $pitem
404 A*
404 A*  Define key for SLOT2 file for cross dock.
404 A*
530aDC**   keys2x        klist
530aDC**                 kfld                    cdwhse
530aDC**                 kfld                    cdwhdp
530aDC**                 kfld                    cdslot
     *
414 A*
414 A*    Key list for PORCV
414 A*
414 AC     keypor        klist
414 AC                   kfld                    $pwhse
414 AC                   kfld                    $ppo
414 AC                   kfld                    $pseq
416 A*
416 A*  Define partial keys for SLOT1 file.
416 A*
416 AC     keys1b        klist
416 AC                   kfld                    $pwhse
500 DC**                 kfld                    itwhdp
500 MC                   kfld                    #rcvwhdp
416 AC                   kfld                    k1aisl
416 A*
416 A*  Define partial key for SLOT3 file.
416 A*
416 AC     keys3b        klist
416 AC                   kfld                    $pwhse
416 AC                   kfld                    $pitem
416 AC                   kfld                    k3stat
416aA*
416aA*  Define partial key for SLOT3 file.
416aA*
416aAC     keys3         klist
416aAC                   kfld                    $pwhse
416aAC                   kfld                    $pitem
416aAC                   kfld                    k3stat
416aAC                   kfld                    k3pick
600dA*
600dA*  Define partial key for WORKOSS1 file.
600dA*
600dAC     keywo1        klist
600dAC                   kfld                    #curruser
600dAC                   kfld                    #job
600dAC                   kfld                    #jobnbr
     *
     *  Variables and constants.
     *
     C                   eval      forevr = *off
416aA*
416aA*  Get Feature option.
416aA*
650tAc                   eval      wkwhse = $pwhse
416aAC                   eval      ocode = '*FEATURE'
416aAC     opkey         chain     options                            79
416aAC                   if        *in79
416aAC                   eval      opfeat = '2'
416aAC                   else
416aAC                   eval      opdat3 = opdata
416aAC                   endif
416aAC                   if        opfeat = '1'
416aAC                   eval      locatr = *on
416aAC                   else
416aAC                   eval      locatr = *off
416aAC                   endif
610gA*
610gA*  Get System option.
610gA*
650tAc                   eval      wkwhse = 0
610gAC                   eval      ocode = '*SYSTEM '
610gAC     opkey         chain     options                            79
610gAC                   if        *in79
610gAC                   eval      opuci  = 'N'
610gAC                   else
610gAC                   eval      opdat4 = opdata
610gAC                   endif
     *
650oD*  Convert today's date into century format.
650oD*  Moved to ZZINZ2.
650oDC*                  eval      $cvcmd = '*CURCMD '
650oDC*                  call      @cvtdt
650oDC*                  parm                    $cvtdt
650oDC*                  eval      todayd =$cvd8o
650oD*
650oD*  Convert today's date into MMDDYY format.
650oD*
650oDC*                  eval      $cvcmd = '*CURMDY '
650oDC*                  call      @cvtdt
650oDC*                  parm                    $cvtdt
650oDC*                  eval      today6 = $cvd6o
     *
417gAC                   eval      $lprg = #pgm

PFCaA*  Define partial key for OPTIONS file.
PFCaAc     opkey2        klist
PFCaAc                   kfld                    kywhse            3 0
PFCaAc                   kfld                    kycode            8
PFCaA
PFCaA*   Check for APT logging option
PFCaAc                   eval      kywhse = 1
PFCaAc                   eval      kycode = '*APTFTP '
PFCaAc     opkey2        chain     options                            79
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
650oA*
650o *  Convert today's date into century format.
650o *  Move from ZZINZ to get date each time.
650o C                   eval      $cvcmd = '*CURCMD '
650o C                   call      @cvtdt
650o C                   parm                    $cvtdt
650o C                   eval      today = $cvd8o
650o *
650o *  Convert today's date into MMDDYY format.
650o *
650o C                   eval      $cvcmd = '*CURMDY '
650o C                   call      @cvtdt
650o C                   parm                    $cvtdt
650o C                   eval      today6 = $cvd6o
     *
     *
     *  Initialize quantity left.
     *
     C                   eval      q1lft = $prq1
     C                   eval      q2lft = $prq2
     C                   eval      q3lft = $prq3
     *
     *  Initialize variables.
     *
     C                   eval      need1 = 0
     C                   eval      need2 = 0
     C                   eval      need3 = 0
     C                   eval      pctr = 0
415 AC                   eval      l = *zeros
416cD**                   MOVE *ZEROS    LCNS
416cMC                   eval      lcns = *blanks
     *
     *   Set indicator for subfile change(SFLNXTCHG)
     C                   eval      *in85 = *on
     *   Get total quantity
     C                   eval      ptqty = $prq1
     C                   add       $prq2         ptqty
     C                   add       $prq3         ptqty
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *   Move PO
     *
     C                   eval      w1po = $ppo
     *
530aA*   Save PDSPCL.  If it's 'XD', it's a cross dock item.
     *
530aAC                   eval      sv_pdspcl = ' '
530aAC     keypd         chain(n)  podtl
530aAC                   if        %found(podtl)
DRYaAC                   if        client = dairyland
DRYaAC                   eval      sv_pdspcl = ' '
DRYaAc                   else
530aAC                   eval      sv_pdspcl = pdspcl
DRYaAc                   endif
530aAC                   endif
     *
     *   Get item description.
     *
     C                   exsr      zzxopt
     *
     C                   eval      woitem = *blanks
     C                   eval      wodsc1 = *blanks
     C                   eval      wodsc2 = *blanks
500 DC**   itkey         chain     piritem                            79
500 DC**                 if        *in79
500 DC**                 eval      itdesc = *blanks
500 DC**                 eval      itpdsc = *blanks
500 DC**                 goto      enditm
500 DC**                 endif
500 A
500 A*  Use DRI interface to get item.
500 A
500 AC                   exsr      clr$item
500 AC                   eval      $itwhse  = $pwhse
500 AC                   eval      $ititem  = $pitem
500 A
500 AC                   eval      $dricommand = '*ITEM'
500 AC                   eval      $drisubcmd  = '%GETALL'
500 AC                   eval      $drisys2upd = 'D'
500 AC                   eval      ck4err = *on
500 AC                   exsr      zzzdricop
500 AC                   if        error
500 AC                   clear                   #rcvitem
500 AC                   clear                   #rcvtype
500 AC                   clear                   #rcvdesc
500 AC                   clear                   #rcvpdsc
500 AC                   clear                   #rcvwhdp
500 AC                   clear                   #rcvstyp
500 AC                   clear                   #rcvdesg
500 AC                   clear                   #rcvum1
500 AC                   clear                   #rcvflg1
500 AC                   clear                   #rcvum2
500 AC                   clear                   #rcvumq2
500 AC                   clear                   #rcvflg2
500 AC                   clear                   #rcvum3
500 AC                   clear                   #rcvumq3
500 AC                   clear                   #rcvnrpk
510bAC                   clear                   #rcvmflg
510bAC                   clear                   #rcvdday
510bAC                   clear                   #rcvmday
510bAC                   clear                   #rcvuday
500 AC                   clear                   #rcvflgd
500 AC                   clear                   #rcvcube
500 AC                   clear                   #rcvswgt
500 AC                   clear                   #slotitem
500 AC                   clear                   #slottype
500 AC                   clear                   #rcvcwgt
500 AC                   goto      enditm
500 AC                   endif
500 A
CSP A*       If this item has a designation code of JIT, populate
CSP A*       pdspcl and sv_pdspcl with 'XD' so that it will be
CSP A*       updated and treated as a cross dock item.
CSP AC                   if        client = CoastalSunbelt
CSPaDC**                           and $itdesg = 'JIT  '
CSPaAC                   If        $itdesg = 'JIT  '
CSPaAC                             or $itdesg = 'PC   '
CSP AC                   eval      pdspcl = 'XD'
CSP AC                   eval      sv_pdspcl = 'XD'
CSPaAC                   endif
CSP AC                   endif
500 A
500 AC                   eval      #rcvitem = $ititem
500 AC                   eval      #rcvtype = $ittype
500 AC                   eval      #rcvdesc = $itdesc
500 AC                   eval      #rcvpdsc = $itpdsc
500 AC                   eval      #rcvwhdp = $itwhdp
500 AC                   eval      #rcvstyp = $itstyp
500 AC                   eval      #rcvdesg = $itdesg
500 AC                   eval      #rcvum1  = $itum1
500 AC                   eval      #rcvflg1 = $itflg1
500 AC                   eval      #rcvum2  = $itum2
500 AC                   eval      #rcvumq2 = $itumq2
500 AC                   eval      #rcvflg2 = $itflg2
500 AC                   eval      #rcvum3  = $itum3
500 AC                   eval      #rcvumq3 = $itumq3
500 AC                   eval      #rcvnrpk = $imnrpk
510bAC                   eval      #rcvmflg = $immflg
510bAC                   eval      #rcvdday = $imdday
510bAC                   eval      #rcvmday = $immday
510bAC                   eval      #rcvuday = $imuday
500 AC                   eval      #rcvflgd = $itflgd
500 AC                   eval      #rcvcube = $itcube
500 AC                   eval      #rcvswgt = $itswgt
510 AC                   eval      #rcvcwgt = $itcwgt

     C                   if        uxflag = '0'
     C                   eval      $iitem = $pitem
500 MC                   eval      $idesc = $itdesc
500 MC                   eval      $ipdsc = $itpdsc
     C                   eval      $istr = *blanks
415bAC                   if        $pprg = 'PO200'
740aAc                             or $pprg = 'PO201'
650qAC                             or $pcmd = '*NONE   '
415bAC                   call      @fmti2
415bAC                   parm                    $iitem           15
415bAC                   parm                    $idesc           30
415bAC                   parm                    $ipdsc           15
415bAC                   parm                    $istr            70
415bAC                   else
     C                   call      @fmtit
     C                   parm                    $iitem
     C                   parm                    $idesc
     C                   parm                    $ipdsc
     C                   parm                    $istr
415bAC                   endif
     C                   movel     $istr         woitem
     C                   else
     C                   movel     $pitem        woitem
500 DC**   itkey         chain     itemdsc                            79
500 DC**                 if        not *in79
500 MC                   eval      wodsc1 = $ixdsc1
500 MC                   eval      wodsc2 = $ixdsc2
500 DC**                 endif
     C                   endif
710aA*   Get item pick slot to display.
710aA*   Moved the Halsey and EGf logic down to condition adding
710aA*   the slot display to the end of the description field.
HSYaA*  Halsey - Get item pick slot to display.
HSYaAC                   eval      k3stat = 'A '
HSYaAC                   eval      k3pick = 'Y'
HSYaAC     keys3         setll     slot3
HSYaAC     keys3         reade(n)  slot3                                  79
HSYaAC                   if        not *in79
HSYaAC                   if        client = halsey
EGFaAC                             or client = egf
HSYaAC                   move      sldisp        wodsc2
HSYaAC                   endif
730aAC                   move      sldisp        $apslt
710aA*  Use DRI interface to get Slot Definition
710aA
710aAC                   exsr      clr$slotdef
710aAC                   eval      $sdwhse  = slwhse
710aAC                   eval      $sdcode  = slsdef
710aA
710aAC                   eval      $dricommand = '*SLOTDEF'
710aAC                   eval      $drisubcmd  = '%GET'
710aAC                   eval      $drisys2upd = 'D'
710aAC                   eval      ck4err = *on
710aAC                   eval      zmsflag = *off
710aAC                   exsr      zzzdricop
710aAC                   if        not error
710aAc                   eval      wosdef = $sdcode
710aAc                   eval      wospin = ' '
SGCgAc                   select
SGCgAc                   when      client = sgc
SGCgAc                   if        $sdlen < 48
SGCgAc                   eval      wospin = 'SPIN'
SGCgAc                   endif
SGCgAc                   other
SGCgAc                   endsl
710aAC                   endif
HSYaAC                   endif
500 A
500 A*  Use DRI interface to get Slot item.
500 A
500 AC                   exsr      clr$item
500 AC                   eval      $itwhse  = $pwhse
500 AC                   eval      $ititem  = $pitem
500 A
500 AC                   eval      $dricommand = '*ITEM'
500 AC                   eval      $drisubcmd  = '%GETSLOT'
500 AC                   eval      $drisys2upd = 'D'
500 AC                   eval      ck4err = *on
500 AC                   exsr      zzzdricop
500 AC                   if        error
500 AC                   clear                   #slotitem
500 AC                   clear                   #slottype
500 AC                   endif
500 A
500 AC                   eval      #slotitem = $ititem
500 AC                   eval      #slottype = $ittype
     *
     C     enditm        tag
     *
     *  Get receiving options.
     *
650tAc                   eval      wkwhse = $pwhse
     C                   eval      ocode = '*RCVLBL '
     C     opkey         chain     options                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*NOOPT  '
     C                   goto      endint
     C                   endif
     *
414 A*
414 A*    Get User's employee number to be written to PORCV file
414 A*    if any records are flagged as touched.
414 A*
414 AC                   call      'GETUSER'
600bDC**                 parm      #user         $code            10
600bAC                   parm      #curruser     $code            10
414 AC                   parm      0             $whse             3 0
414 AC                   parm      0             $emp#             5 0
414 AC                   parm      *blanks       $fnam            15
414 AC                   parm      *blanks       $init             1
414 AC                   parm      *blanks       $lnam            20
414 AC                   parm      *blanks       $whdp             5
414 AC                   parm      *blanks       $styp             1
414 AC                   parm      *blanks       $shft             6
414 AC                   parm      *blanks       $crew             6
414 AC                   parm      0             $nhrs             3 1
414 AC                   parm      *blanks       $rtn              8
     *
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i
415aA*
415aA*   If being called from PO200 RF small screen receiving
650qA*   or cmd passed in = '*NONE' (called from RC180)
415aA*     Then use screen 2 for entry.
415aA*
415aAC                   if        $pprg = 'PO200'
740aAc                             or $pprg = 'PO201'
650qAC                             or $pcmd = '*NONE   '
415aAC                   eval      w2pctr = 1
415aAC                   eval      w2pal = reccnt
415aAC                   call      'GETPTIHI'
415aAC                   parm      $pwhse        prfwhs            3 0
415aAC                   parm                    $pitem
415aAC                   parm                    prfti             4 0
415aAC                   parm                    prfhi             2 0
415aAC                   parm                    prfth             7
415aAC                   parm                    $lrtn
415aAC                   exsr      scr02i
415aAC                   endif
500aA
500aA*  Get live status for item's department.
500aA
500aAC                   call      'CHKLIVE'
640aAC                   parm      $pwhse        $pwhs             3 0
500aAC                   parm                    #rcvwhdp
500aAC                   parm                    livestat          8
500aA
500aA*  If department is not live, then post and get out.
530aA*  Or, if cross dock item, then post and get out.
500aA
500aAC                   if        livestat = '*NOTLIVE'
530aAC                             or sv_pdspcl = 'XD'
500aAC                   exsr      zzupd1
500aAC                   if        error = *off
500aAC                   eval      nxtscr = 'EOJ'
500aAC                   endif
500aAC                   endif

     C     endint        endsr
600aD **---------------------------------------------------------------
600aD **
600aD ** ZZLLP    Lot/license tracking item. Write out tracking info.
600aD **
600aDC**   zzllp         begsr
600aD **
600aD ** Add license to license history.
600aD **
600aDC**                 exsr      clr$lichist
600aDC**                 eval      $lrlcnsu = *on
600aDC**                 eval      $lrlcns  = w1lcns
600aDC**                 eval      $lrtrn#u = *on
600aDC**                 eval      $lrtrn#  = pttrn#
600aDC**                 eval      $lrlbl#u = *on
600aDC**                 eval      $lrlbl#  = lblbl#
417zAC**??????????       eval      $lrolic  = w1lcns
600aDC**                 select
600aDC**                 when      w1umt = '1'
600aDC**                 eval      $lrlqy2u = *on
600aDC**                 eval      $lrlqy2  = w1qty
600aDC**                 when      w1umt = '2'
600aDC**                 eval      $lrlqy3u = *on
600aDC**                 eval      $lrlqy3  = w1qty
600aDC**                 other
600aDC**                 eval      $lrlqy1u = *on
600aDC**                 eval      $lrlqy1  = w1qty
600aDC**                 endsl
600aDC**                 eval      $lrfcodu = *on
600aDC**                 eval      $lrfcod  = 'R'
600aDC**                 eval      $lrfarau = *on
600aDC**                 eval      $lrfara  = 'Receiving'
600aDC**                 eval      $lrfitmu = *on
600aDC**                 eval      $lrfitm  = #rcvitem
600aDC**                 eval      $lrfitypu = *on
600aDC**                 eval      $lrfityp = #rcvtype
600aDC**                 eval      $lrtcodu = *on
600aDC**                 eval      $lrtcod  = 'D'
600aDC**                 eval      $lrtarau = *on
600aDC**                 eval      $lrtara  = 'Dock'
600aDC**                 eval      $lrtwhdu = *on
600aDC**                 eval      $lrtwhd  = $slwhdp
600aDC**                 eval      $lrtdspu = *on
600aDC**                 eval      $lrtdsp  = $sldisp
600aDC**                 eval      $lrtaslu = *on
600aDC**                 eval      $lrtasl  = $slaisl
600aDC**                 eval      $lrtlocu = *on
600aDC**                 eval      $lrtloc  = $slloc
600aDC**                 eval      $lrtlvlu = *on
600aDC**                 eval      $lrtlvl  = $slrlvl
600aDC**                 eval      $lrthndu = *on
600aDC**                 eval      $lrthnd  = $slhand
600aDC**                 eval      $lrtitmu = *on
600aDC**                 eval      $lrtitm  = #slotitem
600aDC**                 eval      $lrtitypu = *on
600aDC**                 eval      $lrtityp = #slottype
600aD **
600aD **    If department is not live, then override some values.
600aD **
600aDC**                 if        livestat = '*NOTLIVE'
600aDC**                 eval      $lrlcns = '*PO'
600aDC**                 eval      $lrtcod = 'X'
600aDC**                 eval      $lrtwhd = #rcvwhdp
600aDC**                 eval      $lrtara = 'Dept Not Live'
600aDC**                 endif
600aD **
600aDC**                 eval      $dricommand = '*LICHIST'
600aDC**                 eval      $drisubcmd  = '%ADDLIC'
600aDC**                 eval      $drisys2upd = 'D'
600aDC**                 exsr      zzzdricop
600aDC**                 if        error
600aDC**                 endif
600aD **
600aDC**                 if        livestat = '*NOTLIVE'
600aDC**                 eval      w1lcns = $lrlcns
600aDC**                 endif
600aA
600aA*----------------------------------------------------------------
600aA*  ZZLICINFO   Update licinfo
600aA*----------------------------------------------------------------
600aA
600aAC     zzlicinfo     begsr
417gA
417gA*  Write out standard license information.
417gA
417gAC                   exsr      clr$licinfo
417gA
600bDC**                 eval      $lnemp# = 0
600bDC**                 eval      $lnuser = #user
417gAC                   eval      $lnpgm  = #pgm
417gAC                   eval      $lnjob  = #job
417gAC                   eval      $lnjobnbr  = #jobnbr
417gA
417gAC                   eval      $lnwhse  = $pwhse
417gAC                   eval      $lntype  = 'P'
600iDC**                 eval      $lnlcns  = w1lcns
600iMC                   eval      $lnlcns  = $saToLcns
417gA
417gAC                   eval      $lncodeu(1) = *on
417gAC                   eval      $lncode(1) = '*PO'
417gAC                   eval      $lncseq(1) = 1
417gAC                   eval      $lnvaltyp(1) = 'A'
417gAC                   eval      $lnvalchr(1) = $ppo
417gAC                   eval      $lnvalnum(1) = 0
417gA
417gAC                   eval      $lncodeu(2) = *on
417gAC                   eval      $lncode(2) = '*POSEQ'
417gAC                   eval      $lncseq(2) = 1
417gAC                   eval      $lnvaltyp(2) = 'N'
417gAC                   eval      $lnvalchr(2) = ' '
417gAC                   eval      $lnvalnum(2) = $pseq
417gA
417gAC                   eval      $lncodeu(3) = *on
417gAC                   eval      $lncode(3) = '*ITEM'
417gAC                   eval      $lncseq(3) = 1
417gAC                   eval      $lnvaltyp(3) = 'A'
417gAC                   eval      $lnvalchr(3) = $pitem
417gAC                   eval      $lnvalnum(3) = 0
417gA
600bDC**                 eval      $lncodeu(4) = *on
600bDC**                 eval      $lncode(4) = '*RCVJOB'
600bDC**                 eval      $lncseq(4) = 1
600bDC**                 eval      $lnvaltyp(4) = 'A'
600bDC**                 eval      $lnvalchr(4) = %trim(#user) + '/'
600bDC**                                        + %trim(#job) + '/'
600gDC**                                        + %trim(#jobnbr)
600bDC**                 eval      $lnvalnum(4) = 0
417gA
417bAC                   eval      $lncodeu(5) = *on
417gAC                   eval      $lncode(5) = '*RCVTRN#'
417gAC                   eval      $lncseq(5) = 1
417gAC                   eval      $lnvaltyp(5) = 'N'
417gAC                   eval      $lnvalchr(5) = ' '
417gAC                   eval      $lnvalnum(5) = pttrn#
417gA
600bDC**                 eval      $lncodeu(6) = *on
600bDC**                 eval      $lncode(6) = '*RCVTS'
600bDC**                 eval      $lncseq(6) = 1
600bDC**                 eval      $lnvaltyp(6) = 'A'
600bDC**                 time                    currtimestamp
600bDC**                 eval      $lnvalchr(6) = %char(currtimestamp)
600bDC**                 eval      $lnvalnum(6) = 0
417gA
417gAC                   eval      $lncodeu(7) = *on
417gAC                   eval      $lncode(7) = '*RCVLQTY'
417gAC                   eval      $lncseq(7) = 1
417gAC                   eval      $lnvaltyp(7) = 'N'
417gAC                   eval      $lnvalchr(7) = ' '
417gAC                   eval      $lnvalnum(7) = w1qty
417gA
417gAC                   eval      $dricommand = '*LICINFO'
417gAC                   eval      $drisubcmd  = '%ADD'
417gAC                   eval      $drisys2upd = 'D'
417yAC                   eval      ck4err = *on
417gAC                   exsr      zzzdricop
417gAC                   if        error
417gAC                   endif
417gA
417gA*  Write out more standard and optional license information.
417gA
417gAC                   exsr      clr$licinfo
417gA
600bDC**                 eval      $lnemp# = 0
600bDC**                 eval      $lnuser = #user
417gAC                   eval      $lnpgm  = #pgm
417gAC                   eval      $lnjob  = #job
417gAC                   eval      $lnjobnbr  = #jobnbr
417gA
417gAC                   eval      $lnwhse  = $pwhse
417gAC                   eval      $lntype  = 'P'
600iDC**                 eval      $lnlcns  = w1lcns
600iMC                   eval      $lnlcns  = $saToLcns
417gA
417gAC                   eval      $lncodeu(1) = *on
417gAC                   eval      $lncode(1) = '*RCVLBL#'
417gAC                   eval      $lncseq(1) = 1
417gAC                   eval      $lnvaltyp(1) = 'N'
417gAC                   eval      $lnvalchr(1) = ' '
417gAC                   eval      $lnvalnum(1) = lblbl#
417gA
417gAC                   if        $pexpd > 0
417gAC                   eval      $lncodeu(2) = *on
417gAC                   eval      $lncode(2) = '*EXPDTE'
417gAC                   eval      $lncseq(2) = 1
417gAC                   eval      $lnvaltyp(2) = 'N'
417gAC                   eval      $lnvalchr(2) = ' '
417gAC                   eval      $lnvalnum(2) = $pexpd
417gAC                   endif
510bM
510bMC                   if        $pindt > 0
510bMC                   eval      $lncodeu(3) = *on
510bMC                   eval      $lncode(3) = '*DATEIN '
510bMC                   eval      $lncseq(3) = 1
510bMC                   eval      $lnvaltyp(3) = 'N'
510bMC                   eval      $lnvalchr(3) = ' '
510bMC                   eval      $lnvalnum(3) = $pindt
510bMC                   endif
417gA
510bDC*                  if        $pmfdt > 0
510bDC*                  eval      $lncodeu(3) = *on
510bDC*                  eval      $lncode(3) = '*MFGDTE'
510bDC*                  eval      $lncseq(3) = 1
510bDC*                  eval      $lnvaltyp(3) = 'N'
510bDC*                  eval      $lnvalchr(3) = ' '
510bDC*                  eval      $lnvalnum(3) = $pmfdt
510BDC*                  endif
417gA
417gAC                   if        $pfifo > 0
417gAC                   eval      $lncodeu(4) = *on
417gAC                   eval      $lncode(4) = '*FIFODTE'
417gAC                   eval      $lncseq(4) = 1
417gAC                   eval      $lnvaltyp(4) = 'N'
417gAC                   eval      $lnvalchr(4) = ' '
417gAC                   eval      $lnvalnum(4) = $pfifo
417gAC                   endif
417gA
417gAC                   if        $plotc <> ' '
417gAC                   eval      $lncodeu(5) = *on
417gAC                   eval      $lncode(5) = '*LOT'
417gAC                   eval      $lncseq(5) = 1
417gAC                   eval      $lnvaltyp(5) = 'A'
417gAC                   eval      $lnvalchr(5) = $plotc
417gAC                   eval      $lnvalnum(5) = 0
417gAC                   endif
417gA
417gAC                   if        w1umt = 'N' and $pawt1 > 0
417gAC                             or w1umt = '1' and $pawt2 > 0
417gAC                             or w1umt = '2' and $pawt3 > 0
417gAC                   eval      $lncodeu(6) = *on
417gAC                   eval      $lncode(6) = '*AVGWGT'
417gAC                   eval      $lncseq(6) = 1
417gAC                   eval      $lnvaltyp(6) = 'N'
417gAC                   eval      $lnvalchr(6) = ' '
417gAC                   select
417gAC                   when      w1umt = '1'
417gAC                   eval      $lnvalnum(6) = $pawt2
417gAC                   when      w1umt = '2'
417gAC                   eval      $lnvalnum(6) = $pawt3
417gAC                   other
417gAC                   eval      $lnvalnum(6) = $pawt1
417gAC                   endsl
417gAC                   endif

417gA
417gAC                   eval      $dricommand = '*LICINFO'
417gAC                   eval      $drisubcmd  = '%ADD'
417gAC                   eval      $drisys2upd = 'D'
417yAC                   eval      ck4err = *on
417gAC                   exsr      zzzdricop
417gAC                   if        error
417gAC                   endif
417gA
510bA*  Write out date type license information.
510bA
510bAC                   exsr      clr$licinfo
510bA
600bDC**                 eval      $lnemp# = 0
600bDC**                 eval      $lnuser = #user
510bAC                   eval      $lnpgm  = #pgm
510bAC                   eval      $lnjob  = #job
510bAC                   eval      $lnjobnbr  = #jobnbr
510bA
510bAC                   eval      $lnwhse  = $pwhse
510bAC                   eval      $lntype  = 'P'
600iDC**                 eval      $lnlcns  = w1lcns
600iMC                   eval      $lnlcns  = $saToLcns
510bA
510bAC                   if        $pfifo > 0
510bAC                   eval      $lncodeu(1) = *on
510bAC                   eval      $lncode(1) = '*DATETYP'
510bAC                   eval      $lncseq(1) = 1
510bAC                   eval      $lnvaltyp(1) = 'A'
510bAC                   eval      $lnvalchr(1) = '*FIFODT'
510bAC                   eval      $lnvalnum(1) = 0
510bAC                   else
510bAC                   if        #rcvflgd = 'Y'
510bAC                   eval      $lncodeu(1) = *on
510bAC                   eval      $lncode(1) = '*DATETYP'
510bAC                   eval      $lncseq(1) = 1
510bAC                   eval      $lnvaltyp(1) = 'A'
510bAC                   eval      $lnvalnum(1) = 0
510bAC                   select
510bAC                   when      #rcvuday > 0 or
510bAC                             #rcvdday > 0
510bAC                   if        #rcvmflg = 'Y'
510bAC                   eval      $lnvalchr(1) = '*MFGDTE'
510bAC                   else
510bAC                   eval      $lnvalchr(1) = '*USEDTE'
510bAC                   endif
510bAC                   other
510bAC                   eval      $lnvalchr(1) = '*EXPDTE'
510bAC                   endsl
510bAC                   else
510bAC                   eval      $lncodeu(1) = *on
510bAC                   eval      $lncode(1) = '*DATETYP'
510bAC                   eval      $lncseq(1) = 1
510bAC                   eval      $lnvaltyp(1) = 'A'
510bAC                   eval      $lnvalchr(1) = '*ENTDTE'
510bAC                   eval      $lnvalnum(1) = 0
510bAC                   endif
510bA
510bAC                   move      #rcvuday      rcvuday
510bAC                   move      #rcvdday      rcvdday
510bAC                   move      #rcvmday      rcvmday
510bAC                   eval      $lncodeu(2) = *on
510bAC                   eval      $lncode(2) = '*DTESET1'
510bAC                   eval      $lncseq(2) = 1
510bAC                   eval      $lnvaltyp(2) = 'A'
510bAC                   eval      $lnvalchr(2) = '&DTEF='+(#rcvflgd) +
510bAC                             ' &MFGF='+(#rcvmflg)
510bAC                   eval      $lnvalnum(2) = 0
510bM
510bAC                   eval      $lncodeu(3) = *on
510bAC                   eval      $lncode(3) = '*DTESET2'
510bAC                   eval      $lncseq(3) = 1
510bAC                   eval      $lnvaltyp(3) = 'A'
510bAC                   eval      $lnvalchr(3) = '&MFGD='+(rcvmday) +
510bAC                             ' &USRD='+(rcvuday) +
510bAC                             ' &DSTD='+(rcvdday)
510bAC                   eval      $lnvalnum(3) = 0
510bAC                   endif

640eAC                   if        $pdecvalue > ' '
640eAC                   eval      $lncodeu(4) = *on
640eAC                   eval      $lncode(4) = '*MFGDCOD'
640eAC                   eval      $lncseq(4) = 1
640eAC                   eval      $lnvaltyp(4) = 'A'
640eAC                   eval      $lnvalchr(4) = %trim($pdecvalue)
640eAC                   eval      $lnvalnum(4) = 0
640eAC                   endif

640eAC                   if        $pmfexpd > 0
640eAC                   eval      $lncodeu(5) = *on
640eAC                   eval      $lncode(5) = '*MFGEXP'
640eAC                   eval      $lncseq(5) = 1
640eAC                   eval      $lnvaltyp(5) = 'N'
640eAC                   eval      $lnvalchr(5) = ' '
640eAC                   eval      $lnvalnum(5) = $pmfexpd
640eAC                   endif
510b
640eAC                   eval      $lncodeu(6) = *on
640eAC                   eval      $lncode(6) = '*MFGDTE'
640eAC                   eval      $lncseq(6) = 1
640eAC                   eval      $lnvaltyp(6) = 'N'
640eAC                   eval      $lnvalchr(6) = ' '
640eAC                   eval      $lnvalnum(6) = $pmfgdt
510b
510bAC                   eval      $dricommand = '*LICINFO'
510bAC                   eval      $drisubcmd  = '%ADD'
510bAC                   eval      $drisys2upd = 'D'
510bAC                   eval      ck4err = *on
510bAC                   exsr      zzzdricop
510bAC                   if        error
510bAC                   endif
510bA
500cA*  Clam information.
520aA*  and Shucked information.

500cAC                   if        $pcode = Clams
520aAC                             or $pcode = Shucked
500cAC                   exsr      clr$licinfo

600bDC**                 eval      $lnemp# = 0
600bDC**                 eval      $lnuser = #user
500cAC                   eval      $lnpgm  = #pgm
500cAC                   eval      $lnjob  = #job
500cAC                   eval      $lnjobnbr  = #jobnbr

500cAC                   eval      $lnwhse  = $pwhse
500cAC                   eval      $lntype  = 'P'
600iDC**                 eval      $lnlcns  = w1lcns
600iMC                   eval      $lnlcns  = $saToLcns

500cAC                   if        $phdte > *Zeros
500cAC                   eval      $lncodeu(1) = *on
500cAC                   eval      $lncode(1) = '*HRVDATE'
500cAC                   eval      $lncseq(1) = 1
500cAC                   eval      $lnvaltyp(1) = 'N'
500cAC                   eval      $lnvalchr(1) = ' '
500cAC                   eval      $lnvalnum(1) = $phdte
500cAC                   endif

500cAC                   if        $phloc <> *blanks
500cAC                   eval      $lncodeu(2) = *on
500cAC                   eval      $lncode(2) = '*HRVLOC'
500cAC                   eval      $lncseq(2) = 1
500cAC                   eval      $lnvaltyp(2) = 'A'
500cAC                   eval      $lnvalchr(2) = $phloc
500cAC                   eval      $lnvalnum(2) = *zeros
500cAC                   endif

500cAC                   if        $pcert <> *blanks
500cAC                   eval      $lncodeu(3) = *on
500cAC                   eval      $lncode(3) = '*HRVCERT'
500cAC                   eval      $lncseq(3) = 1
500cAC                   eval      $lnvaltyp(3) = 'A'
500cAC                   eval      $lnvalchr(3) = $pcert
500cAC                   eval      $lnvalnum(3) = *zeros
500cAC                   endif

500cAC                   eval      $dricommand = '*LICINFO'
500cAC                   eval      $drisubcmd  = '%ADD'
500cAC                   eval      $drisys2upd = 'D'
500cAC                   eval      ck4err = *on
500cAC                   exsr      zzzdricop
500cAC                   if        error
500cAC                   endif
500cAC                   endif

417bAC                   endsr
640hA*----------------------------------------------------------------
640hA*  ZZLICINFONew Update New format of LICINFO
640hA*----------------------------------------------------------------
640hA
640hA /free
640hA   begsr zzlicinfonew;

640hA     // first I need to deal with the cross dock licinfo and uciinfo
640hA     if $pgslcns <> ' ' and w1xdk = 'Y';
640hA       exsr zzxdktemplcns;
640hA     endif;
650vA     // check for temporaty T license for detail CW in uciinfo
650vA       exsr zzcwtemplcns;
640hA     // Write out standard license information
640hA     exsr clr$licinfo;
640hA     $lnwhse  = $pwhse;
640hA     $lnlcns  = $saToLcns;
640hA     $lnseq = 1;

640hA     // $PGSLCNS SHOULD BE POPULATED IF CALL FROM THE UCI/GSI RECEIVING
640hA     // Need to get existing record so we don't overlay lnseqqty
640hA     if $pgslcns <> ' ';
640hA     $dricommand = '*LICINFO';
640hA     $drisubcmd  = '%GET';
640hA     $drisys2upd = 'D';
640hA     ck4err = *on;
640hA     exsr zzzdricop;
640hA     endif;
640hA     if error;
640hA       gs1seqqty = 0;
640hA     else;
640hA       gs1seqqty = $lnseqqty;
640hA     endif;

640hA     exsr clr$licinfo;
640hA     $lnwhse  = $pwhse;
640hA     $lnlcns  = $saToLcns;
640hA
640hA     $lnseq = 1;
640hA     $lnpo = $ppo;
640hA     $lnposeq = $pseq;
650fD     //if $ifucicde = ' ' or $ifucicde = '1';
720bD     //if $ifrcvmth = ' ' or $ifrcvmth = '1';
720bM     if $ifrcvmth = ' ' or $ifrcvmth = '1' or
720bA        $ifrcvmth = '4' or $ifrcvmth = '5' or
720bA        $ifrcvmth = '6';
640hA       $lnseqqty = w1qty;
640hA     else;
640hA       $lnseqqty = gs1seqqty;
640hA     endif;
640hA     $lnitem = $pitem;
640hA     // LNRCVTYP notes
640hA     // 1 = Manual quantity (original method)
640hA     // 2 = Manual quantity with initial GS1 scan
640hA     // 3 = UCI using Mfg GS1 barcodes
640hA     // 4 = UCI using Internal GS1 barcodes (start with 99)
640hA     // 5 = ASN file

640hA     select;
640hA       when $plpn <> ' ';
640hA         $lnrcvtyp = '5';
640hA       when $ifucicde = ' ';
640hA         $lnrcvtyp = '1';
640hA       when $ifucicde = '1';
640hA         $lnrcvtyp = '1';
640hA       when $ifucicde = '2';
640hA         $lnrcvtyp = '3';
640hA       when $ifucicde = '3';
640hA         $lnrcvtyp = '4';
640hA       // don't know exactly what 2 will represent
640hA     endsl;
640hA     //$lnrcvtyp  = 'P';
640hA     $lnrcvtrn# = pttrn#;
640hA     $lnrcvlbl# = lblbl#;
640hA     $lnrcvqty = w1qty;

640hA     if $pindt > 0;
640hA       $lnentdate = $pindt;
640hA     endif;

640hA     if $pfifo > 0;
640hA       $lnenttype = '*FIFODT';
640hA     else;
640hA       if #rcvflgd = 'Y';
640hA         select;
640hA           when #rcvuday > 0 or
640hA                #rcvdday > 0;
640hA             if #rcvmflg = 'Y';
640hA               $lnenttype = '*MFGDTE';
640hA             else;
640hA               $lnenttype = '*USEDTE';
640hA             endif;
640hA           other;
640hA             $lnenttype = '*EXPDTE';
640hA         endsl;
640hA       else;
640hA         $lnenttype = '*ENTDTE';
640hA       endif;

640hA       $lndateflag = #rcvflgd;
640hA       $lnmfgflag = #rcvmflg;

640hA       $lnmfgdays = #rcvmday;
640hA       $lnusrdays = #rcvuday;
640hA       $lndstdays = #rcvdday;
640hA     endif;

640hA     $lnmfgdate = $pmfgdt;

640hA     if $pmfexpd > 0;
640hA       $lnmfgexp = $pmfexpd;
640hA     endif;

640hA     if $pfifo > 0;
640hA       $lnfifodate = $pfifo;
640hA     endif;

640hA     if $pexpd > 0;
640hA       $lnexpdate = $pexpd;
640hA     endif;

640hA     if $pdecvalue > ' ';
640hA       $lnmfgcode = $pdecvalue;
640hA     endif;

640hA     $lnttllbs = $pdwgt;

640hA     if w1umt = 'N' and $pawt1 > 0
640hA        or w1umt = '1' and $pawt2 > 0
640hA        or w1umt = '2' and $pawt3 > 0;
640hA       select;
640hA         when w1umt = '1';
640hA           $lnavglbs = $pawt2;
640hA         when w1umt = '2';
640hA           $lnavglbs = $pawt3;
640hA         other;
640hA           $lnavglbs = $pawt1;
640hA       endsl;
640hA     endif;

640hA     if $plotc <> ' ';
640hA       $lnlot = $plotc;
640hA     endif;

640hA     if $pbrand <> ' ';
640hA       $lnbrand = $pbrand;
640hA     endif;

640hA    // Clam and Shucked information.
640hA     if $pcode = Clams
640hA        or $pcode = Shucked;

640hA       if $phdte > 0;
640hA         $lnhrvdate = $phdte;
640hA       endif;

640hA       if $phloc <> ' ';
640hA         $lnhrvloc = $phloc;
640hA       endif;

640hA       if $pcert <> ' ';
640hA         $lnhrvcert = $pcert;
640hA       endif;
640hA     endif;

650fA     if $pgslcns = ' ';
650fA       // calculate the PTI.
650fA       if $pbclot <> ' ' and $lgtin <> ' ';
650fA         pplot  = %subst($pbclot: 1 : 20);
650fA         if $pw1pti = 0;
650fA           calcpti ($lgtin: pplot: $pbcProdD: pppti);
650fA         else;
650fA           pppti = $pw1pti;
650fA         endif;
650fA         if pppti > 0
720aA            and $ifsltmth = '3';
650fA           $lnlotPTI4 = %editc(pppti:'X');
650fA           $lnlotPTI2 = %Subst(%EditC(pppti:'X'):3:2);
650fA           k = 0;
650fA           if $ifrcvmth <> '2';
650fA             dou k = $lnrcvqty;
650fA               k = k + 1;
650fA               exsr clr$uciinfo;
650fA               $uiWhse = $pwhse;
650fA               $uiItem = $pitem;
650fA               $uiuci = %trim(%editc(pppti:'X'));
650fA               ucilic#($unext: $pwhse);
650fA               unexta = %editc($unext:'X');
650fA               $uiuciLcns = 'P:' + unexta;
650fA               $uiLcns = $saToLcns;
650fA               $uiseq = 1;
650fA               $uiSerial = ' ';
650fA               // weight is calculated as average
650fA               if w1umt = 'N' and $pawt1 > 0
650fA                 or w1umt = '1' and $pawt2 > 0
650fA                 or w1umt = '2' and $pawt3 > 0;
650fA                 select;
650fA                   when w1umt = '1';
650fA                     $uiwgtlbs = $pawt2;
650fA                   when w1umt = '2';
650fA                     $uiwgtlbs = $pawt3;
650fA                   other;
650fA                     $uiwgtlbs = $pawt1;
650fA                 endsl;
650fA               endif;
720cA               $uiaUTyp  = w1umt;
720cA               $uiaSlUTyp = 'N';
720cA               if $lgtin = *blanks;
720cA                  $uiaGtin = 0;
720cA               else;
720cA                  $uiaGtin  = %DEC($lgtin:14:0);
720cA               endif;
720cA               $uiaLot   = $pbclot;
720cA               $uiaExpD  = $pexpd;
720cA               $uiaEntD  = today;
650fA               $uiSelTrn# = 0;
650fA               $uiSelLbl# = 0;
650fA               $uiSelOrd = 0;
650fA               $uiSelSeq = 0;
650fA               $uiSelCSeq = 0;
650fA               $uiSelTrax = ' ';
650fA               $uiCrtBy = '1';

650fA               $dricommand = '*UCIINFO';
650fA               $drisubcmd  = '%ADD';
650fA               $drisys2upd = 'D';
650fA               ck4err = *on;
650fA               zmflag  = *off;
650fA               exsr zzzdricop;
650fA             enddo;
650fA           endif;
650fA         endif;
650fA       endif;

650fA     endif;
640hA     $dricommand = '*LICINFO';
640hA     // $PGSLCNS SHOULD BE POPULATED IF CALL FROM THE UCI/GSI RECEIVING
640hA     if $pgslcns = ' ';
640hA       $drisubcmd  = '%ADDS';
640hA     else;
640hA       $drisubcmd  = '%CHANGES';
640hA     endif;
640hA     $drisys2upd = 'D';
640hA     ck4err = *on;
640hA     exsr zzzdricop;
640hA     if error;
640hA     endif;

640hA   endsr;
640hA /end-free
640fA*----------------------------------------------------------------
664fA*  ZZPOASN     Update poasn file
640fA*----------------------------------------------------------------
640fA
640fAC     zzpoasn       begsr
640fA * check to make sure programs exist or don't allow this command
640fAc                   eval      qcmd = 'CHKOBJ '
640fAc                                  + 'OBJ(GETASN) '
640fAc                                  + 'OBJTYPE(*PGM)'
640fAC                   call      'QCMDEXC'                            78
640fAC                   parm                    qcmd            256
640fAC                   parm      80            qlen             15 5
640fAc                   if        *in78 = *off
640fAc                   if        $plpn <> *blanks
640fAc                   eval      $ascmd = '*PUTLCNS'
640fAc                   call      'GETASN'
640fAc                   parm                    $ascmd            8
640fAc                   parm      ' '           $asrtn            8
640fAc                   parm      $pwhse        $aswhse           3 0
640fAc                   parm      $ppo          $aspo             9
640fAc                   parm      $plpn         $asLPN           50
640fAc                   parm      $saToLcns     $aslcns          15
640fAc                   parm      $plotc        $aslot           20
640fAc                   parm      $pitem        $asitem          15
640fAc                   parm      $pseq         $asseq            5 0
640fAc                   parm      0             $asqty            8 0
640fAc                   parm      0             $asmfgdt          6 0
640fAc                   parm      0             $asexpdt          6 0
640fAc                   parm      0             $aswgt           11 3
640fAc                   endif
640fAc                   endif
640fAC                   endsr
417bA*
610bA*----------------------------------------------------------------
610bA*
610bA*  ZZPRDLBL   Produce label creation
610bA*
     C     zzprdlbl      begsr
     C                   eval      w4dev  = '*JOB'
     C                   eval      w4lqty = ptqty

     *  Process window to produce license plates for external storage

     C                   dow       forevr = forevr
     C                   exfmt     Wprdlbl
     C                   if        *inkl = *on
     C                   leave
     C                   endif

     C                   eval      *in94 = *off

     *     Number of labels cannot be zero

     C                   if        w4lqty = 0
     C                   eval      *in94 = *on
     C                   iter
     C                   endif

     *     No errors, print labels

     *  Print label

     C                   eval      $plfmt = 'PRODUCE'
     C                   if        client = saval
     C                   eval      $plset = 'ZBRSVL'
     C                   else
     C                   eval      $plset = 'PLBL40'
     C                   endif
      *testing purpose
     C                   eval      $plset = 'ZBRSVL'
      *
     C                   if        w4dev <> '*JOB'
     C                   eval      $pdev  = w4dev
     C                   endif
650nAC                   eval      sav$pcmd = $pcmd

     C                   for       i = 1 to w4lqty

740bMC                   call      @PRTPG
650nMC                   parm      '*PRODUCE'    $pcmd             8
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
     C                   parm                    wklic            15
     C                   parm                    $plcn2           15
     C                   parm                    $ititem
     C                   parm                    $pbrnd           10
     C                   parm                    $itpdsc          15
     C                   parm                    $itdesc          30
     C                   parm      $ppo          $ptxt1           30
     C                   parm                    $ptxt2           30
     C                   parm                    $ptxt3           30
     C                   parm                    $ptrailr          8
     C                   parm                    $psize            3
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm                    $pexpda           8
     C                   parm                    $pindta           8
     C                   endfor
     C                   leave

     C                   enddo

740bMC                   call      @PRTPG
650nAC                   parm      '*PRODEND'    $pcmd
650nAC                   parm                    $plset
650nAC                   parm                    $plfmt
650nAC                   parm      $pwhse        $plwhse
650nAC                   parm                    $pwhsd
650nAC                   parm                    $slwhdp
650nAC                   parm                    $sldisp
650nAC                   parm                    $pdispa
650nAC                   parm                    $pdispb
650nAC                   parm                    $pchkd1
650nAC                   parm                    $pchkd2
650nAC                   parm                    $pchkd3
650nAC                   parm                    wklic
650nAC                   parm                    $plcn2
650nAC                   parm                    $ititem
650nAC                   parm                    $pbrnd
650nAC                   parm                    $itpdsc
650nAC                   parm                    $itdesc
650nAC                   parm      $ppo          $ptxt1
650nAC                   parm                    $ptxt2
650nAC                   parm                    $ptxt3
650nAC                   parm                    $ptrailr
650nAC                   parm                    $psize
650nAC                   parm                    $pdev
650nAC                   parm                    $pform
650nAC                   parm                    $pexpda
650nAC                   parm                    $pindta
650nAC                   eval      $pcmd = sav$pcmd

     C                   endsr
404 A*----------------------------------------------------------------
404 A*
404 A*  ZZPXDK  Try to put item into cross dock slots.
404 A*
404 AC     zzpxdk        begsr
404 A*
404 A*  P.O. detail info must have been sent to program.
404 A*
404 AC     $pseq         cabeq     0             endpx
416 A*
416 A*   See if host is providing an xdock quantity.
416 A*
416 AC                   eval      xdkdri = *off
416 AC                   exsr      zzzx2d
417yMC                   eval      $dricommand = '*XDOCK'
417yMC                   eval      $drisubcmd  = '*GETQTY'
417yMC                   exsr      zzzdricop
417yMC                   if        $xdqty1 > 0  or
417yMC                             $xdqty2 > 0  or
417yMC                             $xdqty3 > 0
416 AC                   eval      xdkdri = *on
416 AC                   exsr      zzpxdr
416 AC                   goto      endpx
416 AC                   endif
404 A*
404 A*  Loop through any cross dock records for line item.
404 A*
404 AC                   eval      xdkupd = *off
409 A*R         KEYCD2    SETLLCROSSDK2
409 A*R         FOREVR    DOWEQFOREVR
409 A*R         KEYCD2    READECROSSDK2                 77
530aDC**   keycd2        chain     crossdk2                           77
530aDC**                 if        *in77
530aA*  If this is not a cross dock item, get out.
530aAC                   if        sv_pdspcl <> 'XD'
409 AC                   goto      endpx
409 AC                   else
404 A*
404 A*  Get slot assigned to cross dock item.
404 A*
409 D***                  MOVE CDSLOT    K2DISP
520bDC*    keys2x        chain     slot2                              76
530aDC**   keys2x        chain (n) slot2                              76
530aDC**                 if        *in76
530aAC                   eval      kystat = 'XD'
530aAC     keys10        chain     slot10
700dA * We want to set the need quantites based on the quantites
700dA * sent in. And get out.
700dDC*                  if        not %found(slot10)
530aAC                   eval      need1 = $prq1
530aAC                   eval      need2 = $prq2
530aAC                   eval      need3 = $prq3
404 AC                   goto      endpx
700dDC*                  endif
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
404 AC                   parm                    stock1            5 0
404 AC                   parm                    stock2            3 0
404 AC                   parm                    stock3            3 0
404 A*
404 AC                   parm                    avail1            5 0
404 AC                   parm                    avail2            3 0
404 AC                   parm                    avail3            3 0
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
TPCaA*
TPCaA*   For TPC, set needed quantity to qty received.
SGCcA*   For SGC, set needed quantity to qty received.
SGCcA*   For RYL, set needed quantity to qty received.
TPCaA*   Re: We want everything to go into XDK slot.
530aA*   Change of plans: do this for EVERYONE now.
TPCaA*
530aDC**                 if        client = tpc
530aDC**                           or client = sgc
530aDC**                           or client = royal
TPCaAC                   eval      need1 = q1lft
TPCaAC                   eval      need2 = q2lft
TPCaAC                   eval      need3 = q3lft
530aDC**                 endif
404 A*
404 A*   Get out if nothing needed.
404 A*
404 AC                   if        need1 = 0  and
404 AC                             need2 = 0  and
404 AC                             need3 = 0
530aDC**                 unlock    slot2
404 A**                   ITER
404 AC                   goto      endpx
404 AC                   endif
404 A*
404 A*   Make sure breakdown qty's are not greater than unit of
404 A*   measure quantity.
404 A*
500 MC                   dow       need3 >= #rcvumq3  and
500 MC                             #rcvumq3 <> 0
500 MC                   eval      need3 = need3 - #rcvumq3
404 AC                   add       1             need2
404 AC                   enddo
404 A*
500 MC                   dow       need2 >= #rcvumq2  and
500 MC                             #rcvumq2 <> 0
500 MC                   eval      need2 = need2 - #rcvumq2
404 AC                   add       1             need1
404 AC                   enddo
404 A*
404 A*   Receive needed quantity.
404 A*   If breakdown quantity is needed and a corresponding breakdown
404 A*   qty is being received, then take it.
404 A*   If breakdown quantity is needed but a corresponding breakdown
404 A*   qty is not being received, then increase the qty needed by
404 A*   the next larger breakdown by 1. We don't want the receivers
404 A*   to breakdown boxes.  That job is left for the selectors.
404 A*
404 AC                   if        need3 > 0
404 AC                   select
404 AC                   when      q3lft = 0
404 AC                   add       1             need2
409 AC                   eval      need3 = 0
404 AC                   when      need3 <= q3lft
409 D**                   Z-ADDNEED3     SLRCV3
404 AC                   eval      q3lft = q3lft - need3
404 AC                   other
409 D**                   Z-ADDQ3LFT     SLRCV3
409 D***                  Z-ADD0         Q3LFT
404 AC                   add       1             need2
409 AC                   eval      need3 = 0
404 AC                   endsl
404 AC                   endif
404 A*
404 AC                   if        need2 > 0
404 AC                   select
404 AC                   when      q2lft = 0
404 AC                   add       1             need1
409 AC                   eval      need2 = 0
404 AC                   when      need2 <= q2lft
409 D**                   Z-ADDNEED2     SLRCV2
404 AC                   eval      q2lft = q2lft - need2
404 AC                   other
409 D**                   Z-ADDQ2LFT     SLRCV2
409 D***                  Z-ADD0         Q2LFT
404 AC                   add       1             need1
409 AC                   eval      need2 = 0
404 AC                   endsl
404 AC                   endif
404 A*
404 AC                   if        need1 > 0
404 AC                   select
404 AC                   when      need1 <= q1lft
409 D**                   Z-ADDNEED1     SLRCV1
404 AC                   eval      q1lft = q1lft - need1
404 AC                   other
409 D**                   Z-ADDQ1LFT     SLRCV1
409 D***                  Z-ADD0         Q1LFT
404 AC                   endsl
404 AC                   endif
404 A*
404 A*
404 A*   Save info for final post.
404 A*
409 AC                   eval      savdsp = sldisp
404 A**                   Z-ADDSLRCV1    SAVQ1
404 A**                   Z-ADDSLRCV2    SAVQ2
404 A**                   Z-ADDSLRCV3    SAVQ3
404 A**                   Z-ADD0         SAVTIE
404 A**                   Z-ADD0         SAVHGH
404 A**                   MOVE SLSTAT    SAVSTA
404 A**                   Z-ADD1         SAVLBL
404 A**         LSTLBL    ADD  1         X
404 A**                   MOVE SAVSLT    SLT,X
404 A**                   Z-ADDX         LSTLBL
404 A*
404 A*   Update slot record.
404 A*
404 A*R                   MOVE TODAY     SLSDTE
404 A*R                   TIME           SLSTIM
404 A*R                   MOVE TODAY     SLENTD
404 A*R                   Z-ADD$PEXPD    SLEXPD
404 A*R                   Z-ADD0         SLPRTY
404 A*R                   UPDATS2REC
404 AC                   eval      xdkupd = *on
404 A*
404 A*   Get out if when nothing left.
404 A*
404 A*R         Q1LFT     IFEQ 0
404 A*R         Q2LFT     ANDEQ0
404 A*R         Q3LFT     ANDEQ0
404 A*R                   LEAVE
404 A*R                   ENDIF
404 A*
404 A**                   ENDDO
404 AC                   endif
409 A**                   ENDDO
404 A*
    A*  DO WE NEED RECALC?  WHY DO WE WANT TO RECALC THE # OF SLOTS
    A*   NEEDED? CHECKS TIE/HI ECT.  4-22-98
404 A**         XDKUPD    IFEQ *ON
404 A**                   EXSR RECALC
404 A**                   ENDIF
404 A*
404 AC     endpx         endsr
416 A*----------------------------------------------------------------
416 A*
416 A*  ZZPXDR  Crossdocking using Dakota Realtime Interface.
416 A*
416 AC     zzpxdr        begsr
     C                   eval      xdkupd = *off
     *
     *   Calculate quantity needed.
     *
417yMC                   if        $xdqty1 > q1lft
     C                   eval      need1 = q1lft
     C                   else
417yMC                   eval      need1 = $xdqty1
     C                   endif
417yMC                   if        $xdqty2 > q2lft
     C                   eval      need2 = q2lft
     C                   else
417yMC                   eval      need2 = $xdqty2
     C                   endif
417yMC                   if        $xdqty3 > q3lft
     C                   eval      need3 = q3lft
     C                   else
417yMC                   eval      need3 = $xdqty3
     C                   endif
     *
     C                   eval      xdkupd = *on
     C                   eval      savdsp = 'XDK'
     *
     C                   eval      q1lft = q1lft - need1
     C                   eval      q2lft = q2lft - need2
     C                   eval      q3lft = q3lft - need3
     *
416 AC                   endsr
650dA*----------------------------------------------------------------
650dA*
650dA*  ZZRCVPOCHECK check for started RCVPO Transaction
650dA*
650dAC     zzrcvpocheck  begsr
650dA*
650dA*  See if RCVPO transaction is status 2 - start new if needed
650dA*
650dAC                   call      @crtrcv
650dAC                   parm      '*PO'         $lcmdr           10
650dAC                   parm      '*CHECK '     $lsubcmd         10
650dAC                   parm      $pwhse        @lwhse            3 0
650dAC                   parm      0             $lpcs             5 0
650dAC                   parm      0             $lpallets         5 0
650dAC                   parm                    $lsavetrn         7 0
650dAC                   parm                    $ppo              9
650dAC                   parm      $itstyp       $litstyp          1
650dAC                   parm      $itwhdp       $litwhdp          5
650dAC                   parm                    $lrtnr           10
650dAC                   endsr
650uA*----------------------------------------------------------------
650uA*
650uA*  ZZSTRT  Start timer
650uA*
650uAC     zzstrt        begsr
     *
650uAc                   eval      pgtpgm = #prog
650uAc                   eval      pgtscr = nxtscr
650uAC                   callp     getmicrotime(currstampuc:currstampsys)
650uAc                   eval      pgtStrts = currstampsys
     *
650uAC     endzzs        endsr
640hA*----------------------------------------------------------------
640hA*  ZZXDKTEMPLCNS Replace licinfo & uciinfo temp lcns with xdk license
640hA*----------------------------------------------------------------
640hA
640hA /free
640hA   begsr zzxdktemplcns;
640hA   // records that have a temporary license from gs1 scanning.
640hA   // will need to get the temp license record data, then replace the
640hA   // licinfo with the same data but real license.
640hA   // must loop to process all the licinfo seq#
640hA   // Let's handle the uciinfo file first
640hA      dou $drireturn = '*DONE';
640hA       exsr clr$uciinfo;
640hA
640hA       $uiWhse = $pwhse;
640hA       $uilcns = $pgslcns;
640hA
640hA       $dricommand = '*UCIINFO';
650vD       //$drisubcmd  = '%GETALL';
650vM       $drisubcmd  = '%GET1UCI';
640hA       $drisys2upd = 'D';
640hA       ck4err = *on;
640hA       zmflag  = *off;
640hA       exsr zzzdricop;
640hA       if error;
640hA       endif;
640hA       if $drireturn <> '*DONE';

720cA         // Lets add some more stuff for tracking
720cA         $uiaction = 'RCVRPLTEMP';
720cA         $uiaolcns = $PGSLCNS;
720cA         $uialcns = $pgslcns;
720cA         $uiaoseq = $uiseq;
720cA         $uiscan = ' ';
720cA         //$uifuci = $uiuci;
720cA         //$uifitem = $uiitem;
720cA         //$uiFItype  = $ittype;
720cA         //$uifutyp = $uiUTyp;
720cA         //$uifsitem = slot$item.$ititem;
720cA         //$uifsitype  = slot$item.$ittype;
720cA         //$uifsutyp = $uiUTyp;
720cA         //$uiflcns = $uilcns;
720cA         //$uifseq = $uiseq;
720cA         //$uifentd = today;
720cA         //$uifexpd = $uiExpD;

640hA         // replace - which will add a new record
640hA         $uilcns = $satolcns;

640hA         $dricommand = '*UCIINFO';
640hA         $drisubcmd  = '%REPLACE';
640hA         $drisys2upd = 'D';
640hA         ck4err = *on;
640hA         zmflag  = *off;
640hA         exsr zzzdricop;
640hA         if error;
640hA         endif;
640hA       // now delete the originals

720cA       // Lets add some more stuff for tracking
720cA       $uiaction = 'RCVDLTTEMP';
720cA       $uiaolcns = $pgslcns;
720cA       $uialcns = $pgslcns;
720cA       $uiaoseq = $uiseq;
720cA       $uiscan = ' ';
720cA       //$uifuci = $uiuci;
720cA       //$uifitem = $uiitem;
720cA       //$uiFItype  = $ittype;
720cA       //$uifutyp = 'N';
720cA       //$uifsitem = slot$item.$ititem;
720cA       //$uifsitype  = slot$item.$ittype;
720cA       //$uifsutyp = 'N';
720cA       //$uiflcns = $pgslcns;
720cA       //$uifseq = $uiseq;
720cA       //$uifentd = today;
720cA       //$uifexpd = $uiExpD;

640hA       $uilcns = $pgslcns;

640hA       $dricommand = '*UCIINFO';
640hA       $drisubcmd  = '%DELETE1';
640hA       $drisys2upd = 'D';
640hA       ck4err = *on;
640hA       zmflag  = *off;
640hA       exsr zzzdricop;
640hA       if error;
640hA       endif;
640hA       endif;
640hA     enddo;

640hA   // Now let's handle the replacement of the licinfo records

640hA   for j = 1 to 99;
640hA   exsr clr$licinfo;

640hA   // Get the temp license record
640hA   $lnwhse  = $pwhse;
640hA   $lnlcns  = $pgsLcns;
640hA   $lnseq = j;

640hA   $dricommand = '*LICINFO';
640hA   $drisubcmd  = '%GET';
640hA   $drisys2upd = 'D';
640hA   ck4err = *on;
640hA   exsr zzzdricop;
640hA   if error;
640hA     leave;
640hA   endif;

640hA   // Replace with new license - this will actually write a new record
640hA   // With the data from the temporary record
640hA   $lnlcns  = $satolcns;

640hA   $dricommand = '*LICINFO';
640hA   $drisubcmd  = '%REPLACE';
640hA   $drisys2upd = 'D';
640hA   ck4err = *on;
640hA   exsr zzzdricop;
640hA   if error;
640hA   endif;

640hA   endfor;
640hA   // Now delete the temporary gs1/uci xdock
640hA   exsr clr$licinfo;
640hA   $lnwhse  = $pwhse;
640hA   $lnlcns  = $pgslcns;

640hA   $dricommand = '*LICINFO';
640hA   $drisubcmd  = '%DELETEALL';
640hA   $drisys2upd = 'D';
640hA   ck4err = *on;
640hA   exsr zzzdricop;
640hA   if error;
640hA   endif;

640hA   endsr;
640hA /end-free
650vA*----------------------------------------------------------------
650vA*  ZZCWTEMPLCNS Replace CW uciinfo temp lcns with new or xdk license
650vA*----------------------------------------------------------------
650vA
650vA /free
650vA   begsr zzcwtemplcns;
650vA   // CW122 now writes uciinfo records with a temp license.
650vA   // PO232 writes a single total CW uciinfo when UCI receiving is
650vA   // not being used.                                             the
          // first check to see if we have CW uciinfo records to update
650vA     exsr clr$uciinfo;
650vA     $uiWhse = $pwhse;
650vA     $uiLcns = 'T' + $ppo + %editc($pseq:'X');
650vA     $dricommand = '*UCIINFO';
650vA     $drisubcmd  = '%GETLICREC';
650vA     $drisys2upd = 'D';
650vA     ck4err = *on;
650vA     zmflag  = *off;
650vA     exsr zzzdricop;
650vA     if error = *on;
650vA       leavesr;
650vA     endif;
650vA      dou $drireturn = '*DONE';
650vA       exsr clr$uciinfo;
650vA
650vA       $uiWhse = $pwhse;
650vA       $uiLcns = 'T' + $ppo + %editc($pseq:'X');
650vA
650vA       $dricommand = '*UCIINFO';
650vA       $drisubcmd  = '%GET1UCI';
650vA       $drisys2upd = 'D';
650vA       ck4err = *on;
650vA       zmflag  = *off;
650vA       exsr zzzdricop;
650vA       if error;
650vA       endif;
650vA       if $drireturn <> '*DONE';

720cA         // Lets add some more stuff for tracking
720cA         $uiaction = 'RCVRPLTEMP';
720cA         $uiaolcns = $satolcns;
720cA         $uialcns = $satolcns;
720cA         $uiaoseq = $uiseq;
720cA         $uiscan = ' ';
720cA         //$uifuci = $uiuci;
720cA         //$uifitem = $uiitem;
720cA         //$uiFItype  = $ittype;
720cA         //$uifutyp = 'N';
720cA         //$uifsitem = slot$item.$ititem;
720cA         //$uifsitype  = slot$item.$ittype;
720cA         //$uifsutyp = 'N';
720cA         //$uiflcns = $uilcns;
720cA         //$uifseq = $uiseq;
720cA         //$uifentd = today;
720cA         //$uifexpd = $uiExpD;
650vA         // replace - which will add a new record
650vA         $uilcns = $satolcns;
700aA         $uiselcseq = 0;

650vA         $dricommand = '*UCIINFO';
650vA         $drisubcmd  = '%REPLACE';
650vA         $drisys2upd = 'D';
650vA         ck4err = *on;
650vA         zmflag  = *off;
650vA         exsr zzzdricop;
650vA         if error;
650vA         endif;
650vA       // now delete the originals

650vA       $uiLcns = 'T' + $ppo + %editc($pseq:'X');

650vA       $dricommand = '*UCIINFO';
650vA       $drisubcmd  = '%DELETE1';
650vA       $drisys2upd = 'D';
650vA       ck4err = *on;
650vA       zmflag  = *off;
650vA       exsr zzzdricop;
650vA       if error;
650vA       endif;
650vA       endif;
650vA     enddo;

650vA   endsr;
650vA /end-free
     *----------------------------------------------------------------
     *
     *  NOTE: This SR is not executed - Use slot quantity.
     *  ZZXQTY  Get cross dock quantity from ORDD file.
     *
     C     zzxqty        begsr
     *
     *  P.O. detail info must have been sent to program.
     *
     C     $pseq         cabeq     0             endqx
     *
     C                   eval      xqty = 0
     *
     *  Loop through any cross dock records for line item.
     *
530aDC**   keycd2        setll     crossdk2
     C                   dow       forevr = forevr
530aDC**   keycd2        reade     crossdk2                               77
     C                   if        *in77
     C                   goto      endqx
     C                   else
     *
     *  Get order detail line for cross dock item.
     *
530aDC**   keyod         chain     ordd                               76
530aDC**                 if        *in76
530aDC**                 goto      endqx
530aDC**                 endif
    A*  Skip closed orders
     C                   if        odstat = 'C'
     C                   goto      endqx
     C                   endif
404 A*  Calculate qty for cross dock.
     C                   if        odqor1 > 0
     C                   eval      xqty = odqor1 - odqpk1
     C                   else
     C                   if        odqor2 > 0
     C                   eval      xqty = odqor2 - odqpk2
     C                   else
     C                   eval      xqty = odqor3 - odqpk3
     C                   endif
     C                   endif
     *
     C                   endif
     C                   enddo
     *
     C     endqx         endsr
PFCaA*----------------------------------------------------------------
PFCaA*  ZZAPT   Call APT interface.
PFCaA
PFCaAc     zzapt         begsr
PFCaA
PFCaAC                   eval      APSEQ# = APSEQ# + 1
PFCaA
PFCaAc*    Create APT output record.
PFCaA
PFCaAc                   CALL      'APTMAIN'
PFCaAc                   PARM                    APCMD            10
PFCaAc                   PARM      #PROG         APPGM            10
PFCaAc                   PARM      $PWHSE        APWHSE            3 0
PFCaAc                   PARM      LBLBL#        APLBL#            7 0
PFCaAc                   PARM      LBTRN#        APTRN#            7 0
PFCaAc                   PARM      #USER         APUSER           10
PFCaAc                   PARM      $EMP#         APEMP#            5 0
PFCaAc                   PARM      *BLANKS       APRTID            5
PFCaAc                   PARM      *BLANKS       APRTE             5
PFCaAc                   PARM                    APLOC            20
PFCaAc                   PARM                    APSEQ#            5 0
PFCaAc                   PARM                    APRTN            10
PFCaAc                   PARM                    APMSG            60
PFCaA
PFCaAc                   endsr
PFCaA
     *----------------------------------------------------------------
     *
     *  ZZUSUB   Update using subfile records.
     *
     C     zzusub        begsr
     C                   eval      error = *off
     *
650kA * this code was moved to be entered for each license
650kDC*                  Eval      $phdte = *Zeros
650kDC*                  Eval      $phloc = *Blanks
650kDC*                  Eval      $pcert = *Blanks
     *
650kDC*                  if        $pcode = Clams
650kDC*                            or $pcode = Shucked
650kDC*                  eval      sav$pcmd = $pcmd
650kDC*                  eval      $pcmd = '*ITEM'
650kDC*                  call      'PO172'       po172P
650kDC*                  eval      $pcmd = sav$pcmd
650kDC*                  if        $prtn = '*EXIT   ' or $prtn = '*CANCEL '
650kDC*                  eval      redspl = *on
650kDC*                  goto      endusub
650kDC*                  endif
650kDC*                  endif
     *
     *  Get batch number for labels.
     *
     C                   call      'PIRBAT#'
     C                   parm      *zeros        $pbat             7 0
650wA*
650wA*     - Create batch control record.
650wA*
650wAC                   eval      btbat# = $pbat
650wAC                   eval      btwhse = $pwhse
650wAC                   eval      bttype = '*RCV    '
650wAC                   eval      btstat = ' '
650wAC                   eval      btrte = ' '
650wAC                   eval      $cvcmd = '*CURCMD '
650wAC                   call      @cvtdt
650wAC                   parm                    $cvtdt
650wAC                   eval      btstrd = $cvd8o
650wAC                   time                    btstrt
650wAC                   eval      btstrb = #user
650wAC                   write     btrec
     *
     *   Loop through changed subfile records and add/update file.
     *
415 D**                   MOVE *OFF      *IN77
415 D**         *IN77     DOUEQ*ON                             DO1
415 D**                   READCDETAIL1                  77
415 D**         *IN77     IFEQ *ON                             IF1
415 D**                   LEAVE
415 D**                   ENDIF                                EF1
     *
415aAC     1             do        reccnt        sflrec
415aAC     sflrec        chain     detail1                            77
     *
213 AC                   eval      @pgrp1 = 'P'
500aA
500aA*     If dept not live, then calculate qty for pallet.
530aA*     Or, if cross dock item.
500aA
500aAC                   if        livestat = '*NOTLIVE'
500aAC                             and w1qty = 0
530aAC                             or w1xdk = 'Y'
530aAC                             and w1qty = 0
500aAC     $prq1         div       reccnt        w1qty
500aAC                   mvr                     remain            5 0
500aAC                   if        sflrec = reccnt
500aAC                   eval      w1qty = w1qty + remain
500aAC                   endif
500aAC                   endif
600fA*
600fA*     Ignore subfile records without a qty.
600fA*
600fAC                   if        w1qty <= 0
600fAC                   iter
600fAC                   endif
650pA* This is new oss processing
650pAc                   if        $posscode <> ' '
650pAc                   exsr      zzextstgnew
650pAc                   endif
600aA*
600aA*     Get transaction and label numbers
600aA*     This needs to be done so they can be sent to drislot.
600aA*
600aAC                   call      'PIRTRN#'
600aAC                   parm                    pttrn#            7 0
600aA
600aAC                   call      'PIRLBL#'
600aAC                   parm                    newlbl#
405 A*
405 A*     Update slot for cross dock records.
600aA*     OR, Put license into RCV slot.
405 A*
405 AC                   if        w1xdk = 'Y'
409 AC                   exsr      zzuxdk
600aAC                   else
700bAc                   if        $pflag = *off and w1lcns = ' '
700bAc                   eval      w1lcns = 'R' + %editc(pttrn#:'X')
700bAc                   endif
600aAC                   exsr      zzurcvSlot
600aAC                   if        error
600aAC                   goto      endusub
600aAC                   endif
404 AC                   endif
600aD**
600aD**       Get transaction number.
600aD**
600aDC**                 call      'PIRTRN#'
600aDC**                 parm                    pttrn#            7 0
     ***********************************************
     *
     *    - Create transaction record.
     *    - Create label record for each quantity type.
     *
     C                   eval      tmpflg = *off
     *
     *
600fDC**                 if        w1qty > 0
     *
     *        Create label record for Normal qty.
     *
     C                   clear                   lbrec
     C                   eval      lbwhse = $pwhse
500 MC                   eval      lbwhdp = #rcvwhdp
600aDC**                 eval      lbaisl = *blanks
600aDC**                 eval      lbloc = 0
600aDC**                 eval      lbrlvl = 0
600aDC**                 eval      lbhand = *blanks
     C                   eval      lbpseq = 0
600aDC**                 eval      lbstyp = *blanks
     C                   eval      lbqryf = 0
600aDC**                 eval      lbdisp = *blanks
600aAC                   eval      lbaisl = $slaisl
600aAC                   eval      lbloc = $slloc
600aAC                   eval      lbrlvl = $slrlvl
600aAC                   eval      lbhand = $slhand
600aAC                   eval      lbstyp = $slstyp
600aAC                   eval      lbdisp = $sldisp
     C                   movel     '*MANUAL'     lbdsp2
     C                   eval      lbitem = $pitem
     C                   eval      lbseq = $pseq
     C                   eval      lbpbat = $pbat
     C                   eval      lbpo = $ppo
     C                   eval      lbord = $pord
     C                   eval      lbqalc = w1qty
     C                   eval      lbqpck = w1qty
     C                   eval      lbtie = 0
     C                   eval      lbhigh = 0
     *        Create label record for Normal qty.
     C                   if        w1umt = 'N'  and
500 MC                             #rcvtype <> 'S'
     C                   eval      lbutyp = 'N'
500 MC                   eval      lbucod = #rcvum1
500 MC                   eval      lbucub = #rcvcube
     C     lbucub        mult      w1qty         lbcube
500 MC                   eval      lbuwgt = #rcvswgt
     C     lbuwgt        mult      w1qty         lbswgt
     C                   endif
     *
     *        Create label record for breakdown 1 qty.
     *
610cDC**                 if        w1umt = '1'  or
610cDC**                           w1umt = 'N'  and
610cDC**                           #rcvtype = 'S'
610cMC                   if        w1umt = '1'  and #rcvtype <> 'S'
610cMC                             or w1umt = 'N'  and #rcvtype = 'S'
610cDC**                 eval      lbutyp = *on
610cMC                   eval      lbutyp = w1umt
500 MC                   eval      lbucod = #rcvum2
500 MC                   if        #rcvumq2 <> 0
500 MC     #rcvcube      div(h)    #rcvumq2      lbucub
     C     lbucub        mult      w1qty         lbcube
500 MC     #rcvswgt      div(h)    #rcvumq2      lbuwgt
     C     lbuwgt        mult      w1qty         lbswgt
     C                   endif
     C                   endif
     *
     *        Create label record for breakdown 2 qty.
     *
610cDC**                 if        w1umt = '2'  or
610cDC**                           w1umt = '1'  and
610cDC**                           #rcvtype = 'S'
610cMC                   if        w1umt = '2'  and #rcvtype <> 'S'
610cMC                             or w1umt = '1'  and #rcvtype = 'S'
610cDC**                 eval      lbutyp = '2'
610cMC                   eval      lbutyp = w1umt
500 MC                   eval      lbucod = #rcvum3
500 MC                   if        #rcvumq2 <> 0  and
500 MC                             #rcvumq3 <> 0
500 MC     #rcvcube      div(h)    #rcvumq2      lbucub
500 MC     lbcube        div(h)    #rcvumq3      lbucub
     C     lbucub        mult      w1qty         lbcube
500 MC     #rcvswgt      div(h)    #rcvumq2      lbuwgt
500 MC     lbswgt        div(h)    #rcvumq3      lbuwgt
     C     lbuwgt        mult      w1qty         lbswgt
     C                   endif
     C                   endif
     *
     C                   eval      lbtrn# = pttrn#
600aAC                   eval      lblbl# = newlbl#
600aDC**                 call      'PIRLBL#'
600aDC**                 parm                    lblbl#
213 AC                   eval      lbgrp1 = @pgrp1
213 AC                   eval      lbgrp2 = @pgrp2
     C                   eval      lbtype = 'P'
     C                   eval      lbstat = 'P'
500aA
500aA*    If dept not live, then set status to Closed.
500aA
500aAC                   if        livestat = '*NOTLIVE'
600eAC                             or osslcns
600jAC                             or w1xdk = 'Y'
500aAC                   eval      lbstat = 'C'
500aAC                   endif
500aA
     C                   eval      lbsdte = today
     C                   time                    lbstim
     C                   eval      lbrdte = today
     C                   if        w1xdk = 'Y'
700dDC*                  eval      lbaisl = slaisl
700dDC*                  eval      lbloc = slloc
700dDC*                  eval      lbrlvl = slrlvl
700dDC*                  eval      lbhand = slhand
700dDC*                  eval      lbpseq = slpseq
416aD**                   MOVE 'X'       LBSTYP
700dDC*                  eval      lbstyp = slstyp
700dDC*                  eval      lbdisp = sldisp
     C                   eval      lbdsp2 = *blanks
416aAC                   eval      lbasl2 = 'XDK'
700dAC* these fields were not being loaded correct
700dMC                   eval      lbaisl = $slaisl
700dMC                   eval      lbloc = $slloc
700dMC                   eval      lbrlvl = $slrlvl
700dMC                   eval      lbhand = $slhand
700dMC                   eval      lbpseq = $slpseq
700dMC                   eval      lbstyp = $slstyp
700dMC                   eval      lbdisp = $sldisp
     C                   endif
     C                   write     lbrec
     *
     *         Print label.
500aA*          ... only if dept is live.
     *
     C                   if        $pflag = *off
500aAC                             and livestat = '*LIVE'
     C                   eval      $acmd = '*LABEL  '
     C                   eval      $atie = 0
     C                   eval      $ahigh = 0
     C                   eval      $aqty = w1qty
730aDC*                  eval      $apslt = *blanks
     C                   eval      $adisp = *blanks
     C                   eval      $astyp = *blanks
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
700bA /free
DRYfA   if $pprg = 'RC180' and client = dairyland;
DRYfA     oplpgm = 'RFMTZBRDRY';
DRYfA   endif;
700bA   // parse out the program name and label set name
700bA   if %subst(oplpgm:1:4) = 'RFMT';
700bA     lblset = %subst(oplpgm: 5 : 6);
700bA     lblpgm = %subst(oplpgm: 1 : 4);
710gA   chain(n) ($pwhse: #slotitem) itemmsc;
710gA   if not %found(itemmsc)
710gA     or $adisp <> ' ';
710gA     imtie = 0;
710gA     imhigh = 0;
710gA   endif;
700bA /end-free
700bAC                   call      lblpgm
700bAC                   parm                    $acmd             8
700bAC                   parm                    lblset            6
700bAC                   parm      ' '           $plfmt            8
700bAC                   parm                    pttrn#
700bAC                   parm      $pwhse        $pwhs             3 0
700bAC                   parm                    #rcvwhdp
700bAC                   parm                    $astyp
700bAC                   parm                    $adisp
700bAC                   parm                    $apslt
700bAC                   parm                    $aqty             5 0
700bAC                   parm                    $aum              2
700bAC                   parm      imtie         $atie             4 0
700bAC                   parm      imhigh        $ahigh            2 0
710fD *                  parm                    $pitem
710fD *                  parm                    #rcvdesc
710fMC                   parm                    #slotitem
710fMC                   parm                    $itdesc
700bAC                   parm                    #rcvpdsc
700bAC                   parm                    #rcvupc
700bAC                   parm                    $pven
700bAC                   parm                    $pvitm
700bAC                   parm                    $ppo
700bAC                   parm                    today6
700bAC                   parm                    $aexpd            6 0
700bAC                   parm                    $pdev
700bAC                   parm                    $pform
700bA /free
700bA   else;
700bA /end-free
     C                   call      oplpgm
     C                   parm                    $acmd             8
     C                   parm                    pttrn#
410 D*R                   PARM           $PWHSE
410 MC                   parm      $pwhse        $pwhs             3 0
500 MC                   parm                    #rcvwhdp
     C                   parm                    $astyp
     C                   parm                    $adisp
     C                   parm                    $apslt
     C                   parm                    $aqty             5 0
     C                   parm                    $aum              2
     C                   parm                    $atie             4 0
     C                   parm                    $ahigh            2 0
     C                   parm                    $pitem
500 MC                   parm                    #rcvdesc
500 MC                   parm                    #rcvpdsc
500 MC                   parm                    #rcvupc
     C                   parm                    $pven
     C                   parm                    $pvitm
     C                   parm                    $ppo
     C                   parm                    today6
     C                   parm                    $aexpd            6 0
     C                   parm                    $pdev
     C                   parm                    $pform
700bA /free
700bA   endif;
700bA /end-free
     C                   endif
     *
     *        Create transaction record.
     *
     C                   if        w1xdk = 'Y'
     C                   eval      @pwhdp = slwhdp
     C                   eval      @pstyp = slstyp
     C                   else
500 MC                   eval      @pwhdp = #rcvwhdp
500 MC                   eval      @pstyp = #rcvstyp
     C                   endif
     *
     C                   call      @addtr
     C                   parm      '*CREATE '    @pcmd             8
     C                   parm                    #job
     C                   parm      pttrn#        @ptrn#            7 0
     C                   parm      'PUTEMP'      @ptask            6
     C                   parm      $pwhse        @pwhse            3 0
     C                   parm                    @pwhdp            5
     C                   parm                    @pstyp            1
     C                   parm      lbcube        @pcube            9 3
     C                   parm      lbswgt        @pswgt            9 2
     C                   parm      lbqpck        @ppcs             5 0
     C                   parm      1             @paisl            5 0
     C                   parm      1             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      $ppo          @ppo              9
     C                   parm      'P'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
PFCaA
PFCaAc*    Send receiving data to APT.
PFCaAc                   if        logapt
PFCaAc                   MOVE      APTSK1        APCMD
PFCaAc                   MOVE      *ZEROS        APSEQ#
PFCaAc                   EXSR      ZZAPT
PFCaAc                   endif
     C*
500aA
500aA*         If dept not live, then close transaction.
500aA
500aAC                   if        livestat = '*NOTLIVE'
600eAC                             or osslcns
600eAC                             or w1xdk = 'Y'
500aAC                   call      @addtr
500aAC                   parm      '*CLOSE  '    @pcmd             8
500aAC                   parm                    #job
500aAC                   parm      pttrn#        @ptrn#            7 0
500aAC                   parm      'PUTEMP'      @ptask            6
500aAC                   parm      $pwhse        @pwhse            3 0
500aAC                   parm                    @pwhdp            5
500aAC                   parm                    @pstyp            1
500aAC                   parm      lbcube        @pcube            9 3
500aAC                   parm      lbswgt        @pswgt            9 2
500aAC                   parm      lbqpck        @ppcs             5 0
500aAC                   parm      1             @paisl            5 0
500aAC                   parm      1             @pqty1            5 0
500aAC                   parm      0             @pqty2            5 0
500aAC                   parm      0             @pqty3            5 0
500aAC                   parm      ' '           @prte             5
500aAC                   parm      $ppo          @ppo              9
500aAC                   parm      'P'           @pgrp1            1
500aAC                   parm      ' '           @pgrp2            1
500aAC                   parm      ' '           @prtn             8
500aAC                   parm      ' '           @pmsg             4
500aAC                   endif
     *
600jD **
600jD **       Close transaction if it is a for cross dock.
600jD **         and dept is live.
600jD **
600jDC**                 if        w1xdk = 'Y'
600jDC**                           and livestat = '*LIVE'
600jDC**                 eval      $lcmd = '*CLOSE  '
600jDC**                 eval      $ltype = '*INTER  '
600jDC**                 eval      $lwhse = 0
600jDC**                 eval      $lrte = *blanks
600jDC**                 eval      $lpo = *blanks
600jDC**                 eval      $ltrn# = pttrn#
600jDC**
600jDC**                 call      'PT132'
600jDC**                 parm                    $lparm
600jDC**                 endif
600aD **
600aD **   License tracking item. Write out tracking record.
600aD **
600aDC**                 exsr      zzllp
600aA
650kA * Code moved to here to allow entry for each license.
650kAC                   Eval      $phdte = *Zeros
650kAC                   Eval      $phloc = *Blanks
650kAC                   Eval      $pcert = *Blanks
     *
650kAC                   if        $pcode = Clams
650kAC                             or $pcode = Shucked
650kAc                   dow       $phdte = 0
650kAc                             or $phloc = ' '
650kAc                             or $pcert = ' '
650kAC                   eval      sav$pcmd = $pcmd
650kAC                   eval      $pcmd = '*ITEM'
650kAC                   call      'PO172'       po172P
650kAC                   eval      $pcmd = sav$pcmd
650kAc                   enddo
650kAC                   endif
600aA*    Update licinfo.
600aA
640hDC*                  exsr      zzlicinfo
700fAc                   if        livestat <> '*NOTLIVE'
640hMC                   exsr      zzlicinfonew
650aA * new haccp cross ref added
650aA /free
650aA    hxlcns = $lnlcns;
650aA    for xx = 1 to 20;
650aA      $p1parms1 = $parms1(xx);
650aA        if $p1po <> ' ';
650aA          hxwhse =  %dec($p1whse:3:0);
650aA          hxPO = $p1po;
650aA          hxPOSeq = %dec($p1poseq:5:0);
650aA          hxseq# = %dec($p1qstseq:5:0);
650aA          hxadduc = $p1uctime;
650aA          write hxrec;
650aA        endif;
650aA    endfor;
650aA /end-free
700fAC                   endif
640fA*    Update POASN
640fA
640fAC                   exsr      zzpoasn

500cA* Print clam tags

500cAC                   if        $pcode = Clams and livestat = '*LIVE'
500cAC                   eval      $pqty = W1Qty
500cAC                   call      'TAGFMT'      tagfmtP
500cAC                   endIf

650qA*  If cmd = *NONE, meaning this item's being received without a PO:
650qA*    1. Call RC200 to do the put away.
GFKaA*         Do not call RC200 for Get Fresh Kitchen
DRYeA*                            or Chef's Warehouse
650qA*    2. Do not add a record to PORCV.

650qAC                   select
650qAC                   when      $pcmd = '*NONE   '
GFKaAC                   if        client <> gfkkitchen
DRYeAC                             and client <> dairyland
SUNaAC                             and client <> sunrise
NOJaAC                             and client <> natalies
650qAC                   call      'RC200'
650qAC                   parm                    $lnlcns
650qAC                   parm                    #pgm
GFKaAC                   endif

650qAC                   other

414 A*
414 A*      Add record to PORCV to mark as touched/received.
414 A*
414 AC                   exsr      zzurcv
640dA * Begin Haccp Detail License Processing
      /free
        $lwhse = $pwhse;
        $lcmd = '*PODTL  ';
        $llevel = 'RCVL';
        $llicense = w1lcns;
        $lhpo = $ppo;
        $lhseq = $pseq;
        $lhtype = ' ';
650aD   //ha410($lparm);
650aM   ha410($lparm:$lparm1);
      /end-free
640dA * End Haccp Detail License Processing
600aA*
650qAC                   endsl
650qA
600aA*  Process putaway for external storage
     *
     *  Create license record.
     *
700dDC*                  if        w1xdk <> 'Y'
700dDC*                            and livestat = '*LIVE'
700dMC                   if        livestat = '*LIVE'
700dAc                   if        w1xdk = 'Y'
700dAc                   eval      w1lcns = $satolcns
700dAc                   endif
     C     fileky        chain     license                            7978
     *
     C                   eval      liwhse = $pwhse
416cD**                   Z-ADDW1LCNS    LILCNS
416cMC                   eval      lilcns = w1lcns
     C                   eval      litrn# = pttrn#
     *     Record not found. Try adding record.
     *
     C                   if        *in79
     C                   write     lirec                                76
     C                   if        not *in76
500aD **
500aD **   License tracking item. Write out tracking record.
417xD**         $PLICT    IFEQ 'Y'
417xD**         $PLOTT    OREQ 'Y'
500aDC**                 exsr      zzllp
417xD**                   ENDIF
417bA*
     C                   iter
     C                   endif
     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      *in39 = *on
     C                   eval      *in40 = *on
     C                   eval      *in19 = *on
409 D*R                   UPDATDETAIL1
     C                   eval      errmsg = desc(4)
     C                   exsr      zm7871
     C                   exsr      sfldsp
     C                   leave
520 A*
520 AC                   else
520 A*      Release record lock if license found.
520 AC                   unlock    license
409 AC                   endif
     C                   endif
600fDC**                 endif
     *
     C                   enddo
     *
     *   Flush labels out of spool file.
     *
     C                   if        $pflag = *off
     C                   eval      $acmd = '*FLUSH  '
700bA /free
DRYfA   if $pprg = 'RC180' and client = dairyland;
DRYfA     oplpgm = 'RFMTZBRDRY';
DRYfA   endif;
700bA   // parse out the program name and label set name
700bA   if %subst(oplpgm:1:4) = 'RFMT';
700bA     lblset = %subst(oplpgm: 5 : 6);
700bA     lblpgm = %subst(oplpgm: 1 : 4);
710gA   chain(n) ($pwhse: #slotitem) itemmsc;
710gA   if not %found(itemmsc)
710gA     or $adisp <> ' ';
710gA     imtie = 0;
710gA     imhigh = 0;
710gA   endif;
700bA /end-free
700bAC                   call      lblpgm
700bAC                   parm                    $acmd
700bAC                   parm      ' '           lblset            6
700bAC                   parm      ' '           $plfmt            8
700bAC                   parm                    pttrn#
700bAC                   parm                    $pwhse
700bAC                   parm                    #rcvwhdp
700bAC                   parm                    $astyp
700bAC                   parm                    $adisp
700bAC                   parm                    $apslt
700bAC                   parm                    $aqty
700bAC                   parm                    $aum
700bAC                   parm      imtie         $atie
700bAC                   parm      imhigh        $ahigh
710fD *                  parm                    $pitem
710fD *                  parm                    #rcvdesc
710fMC                   parm                    #slotitem
710fMC                   parm                    $itdesc
700bAC                   parm                    #rcvpdsc
700bAC                   parm                    #rcvupc
700bAC                   parm                    $pven
700bAC                   parm                    $pvitm
700bAC                   parm                    $ppo
700bAC                   parm                    today6
700bAC                   parm                    $aexpd
700bAC                   parm                    $pdev
700bAC                   parm                    $pform
700bA /free
700bA   else;
700bA /end-free
     C                   call      oplpgm
     C                   parm                    $acmd
     C                   parm                    pttrn#
     C                   parm                    $pwhse
500 MC                   parm                    #rcvwhdp
     C                   parm                    $astyp
     C                   parm                    $adisp
     C                   parm                    $apslt
     C                   parm                    $aqty
     C                   parm                    $aum
     C                   parm                    $atie
     C                   parm                    $ahigh
     C                   parm                    $pitem
500 MC                   parm                    #rcvdesc
500 MC                   parm                    #rcvpdsc
500 MC                   parm                    #rcvupc
     C                   parm                    $pven
     C                   parm                    $pvitm
     C                   parm                    $ppo
     C                   parm                    today6
     C                   parm                    $aexpd
     C                   parm                    $pdev
     C                   parm                    $pform
700bA /free
700bA   endif;
700bA /end-free
     C                   endif
     *
     *
     *        Update PO detail record.
     *
218 AC     keypd         chain     podtl                              79
218 AC                   if        not *in79
218 AC                   add       $prq1         pdqrc1
218 AC                   add       $prq2         pdqrc2
218 AC                   add       $prq3         pdqrc3
406 MC                   add       $pdwgt        pddwgt
218 AC                   update    pdrec
218 AC                   endif
409 AC                   eval      $prtn = '*OK     '
409 AC                   eval      $pord = $pbat
500bAC                   eval      errmsg = %trim(%editc(ptqty:'P'))
500bAC                                    + ' received of '
500bAC                                    + $pitem
500bAC                   if        livestat = '*NOTLIVE'
500bAC                   eval      errmsg = %trim(errmsg)
500bAC                                    + ' in non-live department'
500bAC                   endif
500bAC                   exsr      zm0105s
500cAC     endusub       endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     *
     *
     *  Otherwise, update files and return.
     *
     *     Move screen fields to record fields.
     *
RNZaA*
RNZaA*   For Renzi, check weight is not 0 for catch weight item.
RNZaA*
RNZaAC                   if        client = renzi
RNZa C                   if        #rcvcwgt='S'
RNZa C                   eval      #rcvcwgt='N'
RNZaAC                   endif
RNZa C                   if        #rcvcwgt='Y' and
RNZa C                             $pdwgt = 0
RNZaAC                   eval      error = *on
RNZaAC                   eval      errmsg = *blanks
RNZaAC                   movel     'Catch Wt'    errmsg
RNZaAC                   exsr      zm0110
RNZaAC                   endif
RNZaAC     error         cabeq     *on           endup1
RNZaAC                   endif
     *
     *  Update detail first.
     *
     C                   if        reccnt > 0
     C                   exsr      zzusub
     C     error         cabeq     *on           endup1
500cAC     redspl        cabeq     *on           endup1
     C                   endif

510 A*     Enter Catch weights for UCI labels

510 AC                   if        $itcwgt = 'Y' and
610gAC                             opuci  = 'Y'
PCK AC*****                        client = packers
510 AC                   call      @uci
510 AC                   parm                    $Parms
510 AC                   parm                    woitem
510 AC                   parm                    lcns
510 AC                   parm                    $pseq
510 AC                   parm                    $pexpd
510 AC                   parm                    $plotc
510 AC                   parm                    today
PCKaAC                   parm      pttrn#        @pttrn#
510 AC                   endif
     *
     *      Move key values to parameters
     *
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update record.
     *
415aA*    Started using this routine in 4.15a
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     *
     *   If all of the license plates have not been entered
     *     then move on to the next one.
     *
     C                   if        w2pctr < w2pal
     C                   add       1             w2pctr
     C                   exsr      scr02i
     C                   goto      endup2
     C                   endif
415 A*
415 A*   Otherwise, do one last check to make sure the entered
415 A*     quantity equals received quantity.
415 A*
415 AC                   exsr      zzchkm
415 AC     error         cabeq     *on           endup2
RNZaA*
RNZaA*   For Renzi, check weight is not 0 for catch weight item.
RNZaA*
RNZaAC                   if        client = renzi
RNZa C                   if        #rcvcwgt='S'
RNZa C                   eval      #rcvcwgt='N'
RNZaAC                   endif
RNZa C                   if        #rcvcwgt='Y' and
RNZa C                             $pdwgt = 0
RNZaAC                   eval      error = *on
RNZaAC                   eval      errmsg = *blanks
RNZaAC                   movel     'Catch Wt'    errmsg
RNZaAC                   exsr      zm0110
RNZaAC                   endif
RNZaAC     error         cabeq     *on           endup2
RNZaAC                   endif
     *
     *   If everything is ok, update files.
     *
     C                   exsr      zzupd1
     *
     *   Now get out
     *
     C                   eval      nxtscr = 'EOJ'
     *
     C     endup2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update record.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
     *
     *
     C     endup3        endsr
     *
600cA*---------------------------------------------------------------
600cA*
600cA*  zzurcvOSS    Put license into OSS slot
600cA*
600cAC     zzurcvOSS     begsr

     *  Put license into a OSS slot

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #rcvwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = $liToDisp
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = #rcvitem

     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = 0
     C                   eval      $saqty2 = 0
     C                   eval      $saqty3 = 0
     C                   select
610dDC**                 when      w1umt = 'N' and #rcvtype <> 'S'
610dMC                   when      w1umt = 'N'
     C                   eval      $saqty1 = w1qty
     C                   when      w1umt = '1'
610dDC**                           or w1umt = 'N' and #rcvtype = 'S'
     C                   eval      $saqty2 = w1qty
     C                   when      w1umt = '2'
610dDC**                           or w1umt = '1' and #rcvtype = 'S'
     C                   eval      $saqty3 = w1qty
     C                   endsl
600dA
600dAC                   eval      $sacwtau = *on
600dAC                   eval      $sacwta  = 0
600dAC                   eval      $sacodeu = *on
600dAC                   eval      $sacode  = '@@'
600dAC                   eval      $samemou = *on
600dAC                   eval      $samemo  = ' '
600dAC                   eval      $sabyu   = *on
600dAC                   eval      $saby    = #curruser

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'OSS'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = pttrn#
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saLbl#U = *on
     C                   eval      $saLbl# = newlbl#
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = 1
     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = w1lcns
     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'Y'
     C                   eval      $saOLcnsU = *on
     C                   eval      $saOLcns = w1lcns

     C                   eval      $dricommand = '*SLOT'
600dMC                   eval      $drisubcmd  = '%ADJUSTOSS'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      zmflag  = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif
600dA
600dA*  Delete workoss record for license
600dA
600dAC     lcnsky        chain     workoss
600dAC                   if        %found(workoss)
600dAC                   delete(e) workoss
600dAC                   endif

     C                   endsr
600aA*---------------------------------------------------------------
600aA*
600aA*  zzurcvSlot   Put license into RCV slot
600aA*
600aAC     zzurcvSlot    begsr

     *  Only do update for live departments.

     C                   if        livestat <> '*LIVE'
610fAC                   exsr      clr$slot
     C                   leavesr
     C                   endif
600cA
600cA*  Call different routine when putting into an
600cA*  Outside Storage Slot.
600cA
600dAC                   exsr      zzchkoss
650pAc                   if        $posscode <> ' '
650pAc                   eval      ossLcns = *on
650pAc                   endif
600dAC                   if        ossLcns
600cAC                   exsr      zzurcvOSS
600cAC                   leavesr
600cAC                   endif

     *  Put license into a RCV slot

600aAC                   eval      #rcvArea = 'DOCK'

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #rcvwhdp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = #rcvitem
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = ' '
640bAC                   eval      $slstatu = *on
640bAC                   eval      $slstat  = w1stat
     C                   eval      $slstypu = *on
     C                   eval      $slstyp = #rcvstyp
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd = $pexpd
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = #rcvitem

     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = 0
     C                   eval      $saqty2 = 0
     C                   eval      $saqty3 = 0
     C                   select
610dDC**                 when      w1umt = 'N' and #rcvtype <> 'S'
610dMC                   when      w1umt = 'N'
     C                   eval      $saqty1 = w1qty
     C                   when      w1umt = '1'
610dDC**                           or w1umt = 'N' and #rcvtype = 'S'
     C                   eval      $saqty2 = w1qty
     C                   when      w1umt = '2'
610dDC**                           or w1umt = '1' and #rcvtype = 'S'
     C                   eval      $saqty3 = w1qty
     C                   endsl

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'RCV'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = pttrn#
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saLbl#U = *on
     C                   eval      $saLbl# = newlbl#
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = 1
     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = w1lcns
     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'Y'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'D'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = #rcvarea
     C                   eval      $saOLcnsU = *on
     C                   eval      $saOLcns = w1lcns

     C                   eval      $dricommand = '*SLOT'
730aAc                   if        $pcmd = '*NONE   '
730aAC                   eval      $drisubcmd  = '%RWOIN'
730aAc                   else
     C                   eval      $drisubcmd  = '%RCVIN'
730aAc                   endif
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      zmflag  = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   goto      endurcvslot
     C                   endif

650qA*  Create item adjustment record for item received without PO
650qA
650qAC                   time                    curtime
650qA /free
650qA    if $pcmd = '*NONE   ';
650qA      iawhse = $slwhse;
650qA      iaitem = $slitem;
650qA      iadate = today;
650qA      iatime = curtime;
650qA      iaby   = #user;
650qA      iawhdp = $slwhdp;
650qA      iadisp = $sldisp;
650qA      iacwta = $pdwgt;
720dD   // iaqty1 = $prq1;   //
720dD   // iaqty2 = $prq2;   //
720dD   // iaqty3 = $prq3;   //
720dA      iaqty1 = $saqty1;
720dA      iaqty2 = $saqty2;
720dA      iaqty3 = $saqty3;
650qA      iaudte = 0;
650qA      iautim = 0;
CLDaA      select;
CLDaA        when client = cityline;
CLDaA          iacode = '4 ';
CLDaA        other;
650qA          iacode = 'Z9';
CLDaA      endsl;
650qA      iamemo = 'RC180:Item received without PO';
650qA      write iarec;
730cA      exsr wrtlicadj;
650qA    endif;
650qA /end-free

     C     endurcvslot   endsr
414 A*---------------------------------------------------------------
414 A*
414 A*  ZZURCV   Update PORCV file.
414 A*
414 AC     zzurcv        begsr
414 A*
414 A*   Add record to PORCV.
414 A*
414 AC                   eval      porwhs = $pwhse
414 AC                   eval      porpo = $ppo
414 AC                   eval      porseq = $pseq
650bA*
650bA*  Convert today's date into century format.
650bA*
650bAC                   eval      $cvcmd = '*CURCMD '
650bAC                   call      @cvtdt
650bAC                   parm                    $cvtdt
650bAC                   eval      today = $cvd8o
650bA*
650bA*  Convert today's date into MMDDYY format.
650bA*
650bAC                   eval      $cvcmd = '*CURMDY '
650bAC                   call      @cvtdt
650baC                   parm                    $cvtdt
650bAC                   eval      today6 = $cvd6o
650bA *
414 AC                   eval      pordte = today
414 AC                   time                    portim
600bDC**                 eval      porusr = #user
600bMC                   eval      porusr = #curruser
414 AC                   eval      pordev = #job
414 AC                   eval      poremp = $emp#
414 AC                   eval      portrn = pttrn#
416cMC                   eval      porlic = w1lcns
414 AC                   eval      porlbl = lblbl#
414 AC                   eval      poract = 'R'
416cAC                   eval      poredt = 0
416cAC                   eval      poreti = 0
414 AC                   write     porrec                               49
414 AC                   endsr
730cA*---------------------------------------------------------------
730cA*
730cA*  WRTLICADJ  Write LICADJ record.
730cA /free
730cA  begsr wrtlicadj;
730cA   monitor;
730cA     GetOptions(%editc(iawhse:'X'): '*ADJUST': '002': '001': getoptval);
730cA     if getoptval = 'Y';
730cA       useLicAdj = *on;
730cA     else;
730cA       useLicAdj = *off;
730cA     endif;
730cA   on-error;
730cA     useLicAdj = *off;
730cA   endmon;
730cA
730cA   // If option not on, do nothing.
730cA   if useLicAdj = *off;
730cA     leavesr;
730cA   endif;
730cA
730cA   // If file not open, open it.
730cA   if not %open(licadj);
730cA     open LicAdj;
730cA   endif;
730cA
730cA   // Get unique adjustment record id.
730cA   GetRecId(iawhse: 'LICADJ': recidnum);
730cA
730cA   // Get adjustment code description/system.
730cA   GetAdjCode(iacode: gaDesc: gaSys);
730cA
730cA   adjwhs = iawhse;
730cA   adjnbr = %char(recidnum);
730cA   adjparent = *blanks;
730cA   adjcode = iacode;
730cA   adjcsys = gaSys;
730cA   adjitem = iaitem;
730cA   adjaqty1 = iaqty1;
730cA   adjaqty2 = iaqty2;
730cA   adjaqty3 = iaqty3;
730cA   adjcqta = iacwta;
730cA   adjwhdp = iawhdp;
730cA   adjdisp = iadisp;
730cA   adjaisl = $slaisl;
730cA   adjloc = $slloc;
730cA   adjrlvl = $slrlvl;
730cA   adjhand = $slhand;
730cA   adjstat = 'A';
730cA   adjmemo = iamemo;
730cA   //ADJLLTRN =
730cA   //ADJLLTRSQ =
730cA   adjlcns = *blank;
730cA   adjaddts = %timestamp();
730cA   adjadduc = %timestamp();
730cA   adjaddcpgm = #prog;
730cA   adjaddjpgm = #prog;
730cA   adjaddemp = *zero;
730cA   adjaddcusr = #curruser;
730cA   adjaddjusr = #user;
730cA   adjaddjob = #job;
730cA   adjaddnbr = #jobn;
730cA   adjexpflag = *blank;
730cA   adjdrislot = *blanks;
730cA   adjdrilic = *blanks;
730cA
730cA   write adjrec;
730cA
730cA  endsr;  // wrtlicadj
730cA /end-free
404 A*--------------------T-------------------------------------------
404 A*
404 A*  ZZUXDK  Update slot for cross dock.
404 A*
404 AC     zzuxdk        begsr
404 A*
404 A*  P.O. detail info must have been sent to program.
404 A*
404 AC     $pseq         cabeq     0             endux
416aA*
416aA*  Initialize quantities.
416aA*
416aAC                   eval      q1lft = 0
416aAC                   eval      q2lft = 0
416aAC                   eval      q3lft = 0
416aAC                   eval      need1 = 0
416aAC                   eval      need2 = 0
416aAC                   eval      need3 = 0
416 A*
416 A*   See if host is providing an xdock quantity.
416 A*
416 AC                   if        xdkdri = *on
416aAC                   if        locatr = *on
530aDC**                 exsr      zzuxfl
530aMC                   exsr      zzuxlc
416aAC                   else
530aDC**                 exsr      zzuxlc
530aMC                   exsr      zzuxfl
416aAC                   endif
416 AC                   goto      endux
416 AC                   endif
404 A*
530aD*  Loop through any cross dock records for line item.
404 A*
530aDC**   keycd2        chain     crossdk2                           77
530aDC**                 if        *in77
530aA*  If this is not a cross dock item, get out.
530aAC                   if        sv_pdspcl <> 'XD'
409 AC                   goto      endux
600jDC**                 else
600jMC                   endif
     *
530aA*  Use DRISLOT with %CRTXDOCK to get existing cross dock slot or
530aA*  create new one.
     *
530aAC                   exsr      zzcrxd
404 A*
404 A*  Get slot assigned to cross dock item.
404 A*
600jDC**   keys2x        chain     slot2                              76
530aDC**   keys2x        chain(n)  slot2                              76
530aDC**                 if        *in76
530aDC**                 goto      endux
530aDC**                 endif
404 A*
404 A*  Calculate qty still needed.
404 AC                   if        w1umt = 'N'
404 AC                   eval      q1lft = w1qty
404 AC                   else
404 AC                   if        w1umt = '1'
404 AC                   eval      q2lft = w1qty
404 AC                   else
404 AC                   if        w1umt = '2'
404 AC                   eval      q3lft = w1qty
404 AC                   endif
404 AC                   endif
404 AC                   endif
     *
530aA*  Most of the remaining code in this subr no longer applies since
530aA*  we are now receiving all of the qty into the slot using DRISLOT
530aA*  with %ADJUSTOSS.  So rather than comment out tons of code, skip
530aA*  over what is no longer needed.
     *
530aAC                   goto      skip1
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
TPCbA*
TPCbAC                   if        client = TPC
TPCbA*   Force qty to be negative so that rcv'd qty put into XDK slot.
TPCbAC                   z-sub     w1qty         avail1
TPCbAC                   endif
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

530aAC     skip1         tag

530aA*   We want everything received for an 'XD' to go into
530aA*   the cross dock slot.
530aAC                   eval      need1 = q1lft
530aAC                   eval      need2 = q2lft
530aAC                   eval      need3 = q3lft
404 A*
404 A*   Get out if nothing needed.
404 A*
404 AC                   if        need1 = 0  and
404 AC                             need2 = 0  and
404 AC                             need3 = 0
600jDC**                 unlock    slot2
404 AC                   goto      endux
404 AC                   endif
404 A*
404 A*   Make sure breakdown qty's are not greater than unit of
404 A*   measure quantity.
404 A*
500 MC                   dow       need3 >= #rcvumq3  and
500 MC                             #rcvumq3 <> 0
500 MC                   eval      need3 = need3 - #rcvumq3
404 AC                   add       1             need2
404 AC                   enddo
404 A*
500 MC                   dow       need2 >= #rcvumq2  and
500 MC                             #rcvumq2 <> 0
500 MC                   eval      need2 = need2 - #rcvumq2
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
409 AC                   z-add     need3         slrcv3
404 AC                   eval      q3lft = q3lft - need3
404 AC                   other
409 AC                   z-add     q3lft         slrcv3
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
409 AC                   z-add     need2         slrcv2
404 AC                   eval      q2lft = q2lft - need2
404 AC                   other
409 AC                   z-add     q2lft         slrcv2
404 AC                   eval      q2lft = 0
404 AC                   add       1             need1
404 AC                   endsl
404 AC                   endif
404 A*
404 AC                   if        need1 > 0
404 AC                   select
404 AC                   when      need1 <= q1lft
409 AC                   eval      slrcv1 = need1
404 AC                   eval      q1lft = q1lft - need1
404 AC                   other
409 AC                   eval      slrcv1 = q1lft
404 AC                   eval      q1lft = 0
404 AC                   endsl
404 AC                   endif
404 A*
530aA*   Skip some more code ......
530aAC                   goto      skip2
404 A*
404 A*   Update slot record.
404 A*
TPCbAC                   if        client = TPC
TPCbA*
TPCbA*    Force slot status to XD when updating slot with qty.
TPCbAC                   if        slstat <> 'XD'
TPCbAC                   eval      slstat = 'XD'
TPCbAC                   endif
TPCbA*
TPCbAC                   endif
TPCbA*
404 AC                   move      today         slsdte
404 AC                   time                    slstim
404 AC                   move      today         slentd
404 AC                   eval      slexpd = $pexpd
404 AC                   eval      slprty = 0
600jDC**                 update    s2rec
404 AC                   eval      xdkupd = *on
600jDC**                 exsr      zzzs2d
600jDC**                 eval      $slstatu = *on
600jDC**                 eval      $slsdteu = *on
600jDC**                 eval      $slstimu = *on
600jDC**                 eval      $slentdu = *on
600jDC**                 eval      $slexpdu = *on
600jDC**                 eval      $slprtyu = *on
600jDC**                 eval      $saitemu = *on
600jDC**                 eval      $saitem = slitem
600jDC**                 eval      $saqtyu = *on
600jDC**                 eval      $saqty1 = slrcv1
600jDC**                 eval      $saqty2 = slrcv2
600jDC**                 eval      $saqty3 = slrcv3
600jDC**                 eval      $dricommand = '*SLOT'
600jDC**                 eval      $drisubcmd  = '%RECEIVE'
600jDC**                 eval      $drireturn  = '*NOUPDATE*'
600jDC**                 eval      ck4err = *off
600jDC**                 exsr      zzzdricop
600jDC**                 endif
530aA
530aAC     skip2         tag
530aA
600jA*  Adjust qty into XDK slot
600jA
530aDC**                 exsr      clr$slot
600jAC                   eval      $slwhseu = *on
530aDC**                 eval      $slwhse  = $pwhse
600jAC                   eval      $slwhdpu = *on
530aDC**                 eval      $slwhdp  = slwhdp
600jAC                   eval      $sldispu = *on
530aDC**                 eval      $sldisp  = sldisp
600jAC                   eval      $saitemu = *on
530aDC**                 eval      $saitem  = slitem
530aMC                   eval      $saitem  = $slitem
600jA
600jAC                   eval      $saqtyu = *on
600jAC                   eval      $saqty1 = 0
600jAC                   eval      $saqty2 = 0
600jAC                   eval      $saqty3 = 0
600jAC                   select
610dDC**                 when      w1umt = 'N' and #rcvtype <> 'S'
610dMC                   when      w1umt = 'N'
600jAC                   eval      $saqty1 = w1qty
600jAC                   when      w1umt = '1'
610dDC**                           or w1umt = 'N' and #rcvtype = 'S'
600jAC                   eval      $saqty2 = w1qty
600jAC                   when      w1umt = '2'
610dDC**                           or w1umt = '1' and #rcvtype = 'S'
600jAC                   eval      $saqty3 = w1qty
600jAC                   endsl
600jA
600jAC                   eval      $sacwtau = *on
600jAC                   eval      $sacwta  = 0
600jAC                   eval      $sacodeu = *on
600jAC                   eval      $sacode  = '@@'
600jAC                   eval      $samemou = *on
600jAC                   eval      $samemo  = ' '
600jAC                   eval      $sabyu   = *on
600jAC                   eval      $saby    = #curruser
600jA
600jAC                   eval      $saActionU = *on
600jAC                   eval      $saAction = 'XDK'
600jAC                   eval      $saTrn#U = *on
600jAC                   eval      $saTrn# = pttrn#
600jAC                   eval      $saETrn#U = *on
600jAC                   eval      $saETrn# = 0
600jAC                   eval      $saLbl#U = *on
600jAC                   eval      $saLbl# = newlbl#
600jAC                   eval      $saToPosU = *on
600jAC                   eval      $saToPos = 1
600jAC                   eval      $saToLcnsU = *on
600jAC                   eval      $saToLcns = '*XD'
600jAC                                       + %editc(pttrn#:'X')
700dAc                   eval      w1lcns = $saToLcns
600jAC                   eval      $saToVrfyU = *on
600jAC                   eval      $saToVrfy = 'Y'
600jAC                   eval      $saFrmLcnsU = *on
600jAC                   eval      $saFrmLcns = $saToLcns
600jAC                   eval      $saOLcnsU = *on
600jAC                   eval      $saOLcns = $saToLcns
600jA
600jAC                   eval      $dricommand = '*SLOT'
600jAC                   eval      $drisubcmd  = '%ADJUSTOSS'
600jAC                   eval      $drisys2upd = 'D'
600jAC                   eval      ck4err = *on
600jAC                   eval      zmflag  = *on
600jAC                   exsr      zzzdricop
600jAC                   if        error
600jAC                   endif
404 A*
404 AC     endux         endsr
416aA*----------------------------------------------------------------
416aA*
416aA*  ZZUXFL  DRI crossdocking for full system.
416aA*
416aAC     zzuxfl        begsr
     C                   eval      xdkupd = *off
     *
     *   Calculate quantity needed.
     *
     C                   if        w1umt = 'N'
     C                   eval      q1lft = w1qty
     C                   eval      need1 = w1qty
     C                   else
     C                   if        w1umt = '1'
     C                   eval      q2lft = w1qty
     C                   eval      need2 = w1qty
     C                   else
     C                   if        w1umt = '2'
     C                   eval      q3lft = w1qty
     C                   eval      need3 = w1qty
     C                   endif
     C                   endif
     C                   endif
     *
     *  See if xdock slot exists
     *
     *     Note: When program is updated to work directly with
     *           DRI interface, this can be replaced with %GETXDOCK.
     *
     C                   eval      k3stat = 'XD'
     C     keys3b        setll     slot3
     C                   dow       forevr = forevr
     C                   read      slot3                                  79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *    Double verify that slot is an xdock slot in same department.
     *
     C                   if        slaisl <> 'XDK'  or
500 MC                             slwhdp <> #rcvwhdp
     C                   iter
     C                   endif
     *
     *    XDock slot found for item. Update receiving.
     *
     C                   add       need1         slrcv1
     C                   add       need2         slrcv2
     C                   add       need3         slrcv3
     C                   move      today         slsdte
     C                   time                    slstim
     C                   move      today         slentd
     C                   eval      slexpd = $pexpd
     C                   eval      slprty = 0
     C                   update    s3rec
     *
     C                   exsr      zzzs2d
417yMC                   eval      $saitemu = *on
417yMC                   eval      $saitem = slitem
417yMC                   eval      $saqtyu = *on
417yMC                   eval      $saqty1 = need1
417yMC                   eval      $saqty2 = need2
417yMC                   eval      $saqty3 = need3
417yMC                   eval      $dricommand = '*SLOT'
417yMC                   eval      $drisubcmd  = '%RECEIVE'
417yMC                   eval      $drireturn  = '*NOUPDATE*'
     C                   eval      ck4err = *off
417yMC                   exsr      zzzdricop
     *
417yMC                   if        $drireturn = '*OK'
     C                   goto      savxdr
     C                   endif
     *
     C                   leave
     *
     C                   enddo
     *
     *  XDock slot not found for item. Create one.
     *
     *     Note: When program is updated to work directly with
     *           DRI interface, this can be replaced with %CRTXDOCK.
     *
     *    Find next available XDK slot to use.
     *
530aAC                   exsr      zzcrxd
     *
530aA*    The following code has been moved to subr zzcrxd.
530aDC**                 eval      tmploc = 1
530aDC**                 eval      k1aisl = 'XDK'
530aDC**   keys1b        setll     slot1
530aDC**                 dow       forevr = forevr
530aDC**   keys1b        reade(n)  slot1                                  79
530aDC**                 if        *in79  or
530aDC**                           slloc > tmploc
530aDC**                 leave
530aDC**                 endif
530aDC**   slloc         add       1             tmploc
530aDC**                 enddo
530aD***
530aD***  Initialize slot fields.
530aD***
530aDC**                 clear                   s1rec
530aDC**                 eval      slwhse = $pwhse
530aDC**                 eval      slwhdp = #rcvwhdp
530aDC**                 eval      slaisl = 'XDK'
530aDC**                 eval      slloc = tmploc
530aDC**                 eval      slrlvl = 1
530aDC**                 eval      slhand = *blanks
530aDC**                 eval      slstyp = 'X'
530aDC**                 eval      slpseq = tmploc
530aDC**                 eval      slitem = $pitem
530aDC**                 eval      slstat = 'XD'
530aDC**                 eval      slsdte = today
530aDC**                 time                    slstim
530aDC**                 eval      slpick = 'N'
530aDC**                 eval      slrsrv = 'N'
530aDC**   slloc         div       2             dummy
530aDC**                 mvr                     slside
530aDC**                 if        slside < 0
530aDC**                 eval      slside = -(slside)
530aDC**                 endif
530aDC**                 move      today         slentd
530aDC**                 eval      slexpd = $pexpd
530aDC**                 eval      slprty = 0
530aDC**                 eval      slrcv1 = need1
530aDC**                 z-add     need2         slrcv2
530aDC**                 z-add     need3         slrcv3
530aD***
530aD***  Format display slot.
530aD***
530aDC**                 call      'FRMTSL'
530aDC**                 parm                    slwhse
530aDC**                 parm                    slwhdp
530aDC**                 parm                    slaisl
530aDC**                 parm                    slloc
530aDC**                 parm                    slrlvl
530aDC**                 parm                    slhand
530aDC**                 parm                    slstyp
530aDC**                 parm                    slpseq
530aDC**                 parm                    sldisp
530aD***
530aD***  Add record
530aD***
530aDC**                 write     s1rec
     *
     C                   exsr      zzzs2d
     C                   exsr      zzzfs1
417yMC                   eval      $dricommand = '*SLOT'
417yMC                   eval      $drisubcmd  = '%ADD' + 'XDOCK'
417yMC                   eval      $drireturn  = '*NOUPDATE*'
     C                   eval      ck4err = *off
417yMC                   exsr      zzzdricop
     *
417yMC                   if        $drireturn <> '*OK'
     C                   goto      endxfl
     C                   endif
     *
     C                   exsr      zzzs2d
417yMC                   eval      $saitemu = *on
417yMC                   eval      $saitem = slitem
417yMC                   eval      $saqtyu = *on
417yMC                   eval      $saqty1 = need1
417yMC                   eval      $saqty2 = need2
417yMC                   eval      $saqty3 = need3
417yMC                   eval      $dricommand = '*SLOT'
417yMC                   eval      $drisubcmd  = '%RECEIVE'
417yMC                   eval      $drireturn  = '*NOUPDATE*'
     C                   eval      ck4err = *off
417yMC                   exsr      zzzdricop
     *
417yMC                   if        $drireturn <> '*OK'
     C                   goto      endxfl
     C                   endif
     *
     *   Save info for final post.
     *
     C     savxdr        tag
     C                   eval      xdkupd = *on
416aA*
416aA*   Tell host quantity received into xdock slot.
416aA*
416aAC                   exsr      zzzx2d
417yMC                   eval      $xdqty1 = need1
417yMC                   z-add     need2         $xdqty2
417yMC                   z-add     need3         $xdqty3
417yMC                   eval      $dricommand = '*XDOCK'
417yMC                   eval      $drisubcmd  = '*RECEIVE'
417yMC                   exsr      zzzdricop
     *
416aAC     endxfl        endsr
416aA*----------------------------------------------------------------
416aA*
416aA*  ZZUXLC  DRI crossdocking for Locator system.
416aA*
416aAC     zzuxlc        begsr
     C                   eval      xdkupd = *off
     *
     *   Calculate quantity needed.
     *
     C                   if        w1umt = 'N'
     C                   eval      q1lft = w1qty
     C                   eval      need1 = w1qty
     C                   else
     C                   if        w1umt = '1'
     C                   eval      q2lft = w1qty
     C                   eval      need2 = w1qty
     C                   else
     C                   if        w1umt = '2'
     C                   eval      q3lft = w1qty
     C                   eval      need3 = w1qty
     C                   endif
     C                   endif
     C                   endif
     *
     *  Put crossdock into first pick slot for item.
     *
     C                   eval      k3stat = 'A '
     C                   eval      k3pick = 'Y'
     C     keys3         setll     slot3
     C     keys3         reade(n)  slot3                                  79
     *
     *    If it doesn't exist, throw error.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*NOTENGH'
     C                   goto      endxlc
     C                   endif
     *
     *    Otherwise, update slot.
     *
     *      Add crossdock qty to receive quantity.
     *
     C                   add       need1         slrcv1
     C                   add       need2         slrcv2
     C                   add       need3         slrcv3
     *
     *      Update entered date if necessary.
     *
     C                   if        slentd = 0  or
     C                             slstk1 = 0  and
     C                             slstk2 = 0  and
     C                             slstk3 = 0  and
     C                             slalc1 = 0  and
     C                             slalc2 = 0  and
     C                             slalc3 = 0  and
     C                             sltfr1 = 0  and
     C                             sltfr2 = 0  and
     C                             sltfr3 = 0  and
     C                             slpck1 = 0  and
     C                             slpck2 = 0  and
     C                             slpck3 = 0  and
     C                             slrcv1 = 0  and
     C                             slrcv2 = 0  and
     C                             slrcv3 = 0
     C                   move      today         slentd
     C                   eval      slexpd = 0
     C                   endif
     *
     *      Update expiration date if necessary.
     *
     C                   if        slexpd = 0  or
     C                             $pexpd < slexpd
     C                   eval      slexpd = $pexpd
     C                   endif
     *
     *      Update record.
     *
     C                   update    s3rec
     *
     C                   exsr      zzzs2d
417yMC                   eval      $saitemu = *on
417yMC                   eval      $saitem = slitem
417yMC                   eval      $saqtyu = *on
417yMC                   eval      $saqty1 = need1
417yMC                   eval      $saqty2 = need2
417yMC                   eval      $saqty3 = need3
417yMC                   eval      $dricommand = '*SLOT'
417yMC                   eval      $drisubcmd  = '%RECEIVE'
417yMC                   eval      $drireturn  = '*NOUPDATE*'
     C                   eval      ck4err = *off
417yMC                   exsr      zzzdricop
     *
     ***        DRIRTN    IFNE '*OK'   *** Reinstate after     ***
     ***                  GOTO ENDXLC  *** NOUPDATE is removed ***
     ***                  ENDIF                                          END2
     *
     *   Tell host quantity received into xdock slot.
     *
     C                   exsr      zzzx2d
417yMC                   eval      $xdqty1 = need1
417yMC                   z-add     need2         $xdqty2
417yMC                   z-add     need3         $xdqty3
417yMC                   eval      $dricommand = '*XDOCK'
417yMC                   eval      $drisubcmd  = '*RECEIVE'
417yMC                   exsr      zzzdricop
     *
416aAC     endxlc        endsr
600dA*----------------------------------------------------------------
600dA*
600dA*  ZZWODLTJOB     Delete WORKOSS records for current job
600dA*
600dAC     zzWoDltJob    begsr

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

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'OSS'
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%DELETEX'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *off
     C                   eval      zmflag  = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     *    Delete workoss record.

     C                   delete(e) workoss1

     C                   enddo

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZXOPT   Get use extended description option
     *
     C     zzxopt        begsr
     *
     *   Get extended description option.
     C                   eval      uxflag = *off
650tAc                   eval      wkwhse = $pwhse
     C                   eval      ocode = '*ITEMMNT'
     *
     C     opkey         chain     options                            79
     C                   if        not *in79
     C                   if        opxdsc = 'Y'
     C                   eval      uxflag = *on
     C                   endif
     C                   endif
     *
     C                   endsr
416 A*----------------------------------------------------------------
416 A*     ZZZFS1 - Fill data structure slot fields for Add.
416 A*
416 AC     zzzfs1        begsr
     *
417yMC                   eval      $slwhseu = *on
417yMC                   eval      $slwhdpu = *on
417yMC                   eval      $sldispu = *on
417yMC                   eval      $slaislu = *on
417yMC                   eval      $sllocu  = *on
417yMC                   eval      $slrlvlu = *on
417yMC                   eval      $slhandu = *on
417yMC                   eval      $slsideu = *on
417yMC                   eval      $slstypu = *on
417yMC                   eval      $slstatu = *on
417yMC                   eval      $slsdteu = *on
417yMC                   eval      $slstimu = *on
417yMC                   eval      $slpicku = *on
417yMC                   eval      $slpsequ = *on
417yMC                   eval      $slexpdu = *on
417yMC                   eval      $slrsrvu = *on
417yMC                   eval      $slitemu = *on
     *
416 AC                   endsr
416 A*----------------------------------------------------------------
416 A*     ZZZS2D - Copy slot fields into data structure fields.
416 A*
416 AC     zzzs2d        begsr
     *
417yMC                   eval      $slwhseu = *on
417yMC                   eval      $slwhse = slwhse
     *
417yMC                   eval      $slwhdpu = *on
417yMC                   eval      $slwhdp = slwhdp
     *
417yMC                   eval      $sldispu = *on
417yMC                   eval      $sldisp = sldisp
     *
417yMC                   eval      $slaislu = *on
417yMC                   eval      $slaisl = slaisl
     *
417yMC                   eval      $sllocu = *on
417yMC                   eval      $slloc = slloc
     *
417yMC                   eval      $slrlvlu = *on
417yMC                   eval      $slrlvl = slrlvl
     *
417yMC                   eval      $slhandu = *on
417yMC                   eval      $slhand = slhand
     *
417yMC                   eval      $slsideu = *off
417yMC                   eval      $slside = slside
     *
417yMC                   eval      $slstypu = *off
417yMC                   eval      $slstyp = slstyp
     *
417yMC                   eval      $slstatu = *off
417yMC                   eval      $slstat = slstat
     *
417yMC                   eval      $slsdteu = *off
417yMC                   eval      $slsdte = slsdte
     *
417yMC                   eval      $slstimu = *off
417yMC                   eval      $slstim = slstim
     *
417yMC                   eval      $slsdefu = *off
417yMC                   eval      $slsdef = slsdef
     *
417yMC                   eval      $sldesgu = *off
417yMC                   eval      $sldesg = sldesg
     *
417yMC                   eval      $slactvu = *off
417yMC                   eval      $slactv = slactv
     *
417yMC                   eval      $slbldu = *off
417yMC                   eval      $slbld = slbld
     *
417yMC                   eval      $slpicku = *off
417yMC                   eval      $slpick = slpick
     *
417yMC                   eval      $slpsequ = *off
417yMC                   eval      $slpseq = slpseq
     *
417yMC                   eval      $slprtyu = *off
417yMC                   eval      $slprty = slprty
     *
417yMC                   eval      $slentdu = *off
417yMC                   eval      $slentd = slentd
     *
417yMC                   eval      $slexpdu = *off
417yMC                   eval      $slexpd = slexpd
     *
417yMC                   eval      $slslfdu = *off
417yMC                   eval      $slslfd = slslfd
     *
417yMC                   eval      $slrsrvu = *off
417yMC                   eval      $slrsrv = slrsrv
     *
417yMC                   eval      $slitemu = *off
417yMC                   eval      $slitem = slitem
     *
417yMC                   eval      $slstk1 = slstk1
417yMC                   eval      $slstk2 = slstk2
417yMC                   eval      $slstk3 = slstk3
417yMC                   eval      $slalc1 = slalc1
417yMC                   eval      $slalc2 = slalc2
417yMC                   eval      $slalc3 = slalc3
417yMC                   eval      $sltfr1 = sltfr1
417yMC                   eval      $sltfr2 = sltfr2
417yMC                   eval      $sltfr3 = sltfr3
417yMC                   eval      $slpck1 = slpck1
417yMC                   eval      $slpck2 = slpck2
417yMC                   eval      $slpck3 = slpck3
417yMC                   eval      $slrcv1 = slrcv1
417yMC                   eval      $slrcv2 = slrcv2
417yMC                   eval      $slrcv3 = slrcv3
417yMC                   eval      $slphy1 = 0
417yMC                   eval      $slphy2 = 0
417yMC                   eval      $slphy3 = 0
417yMC                   eval      $slavl1 = 0
417yMC                   eval      $slavl2 = 0
417yMC                   eval      $slavl3 = 0
417yMC                   eval      $sladj1 = 0
417yMC                   eval      $sladj2 = 0
417yMC                   eval      $sladj3 = 0
     *
417yMC                   eval      $saitemu = *off
417yMC                   eval      $saitem = *blanks
     *
417yMC                   eval      $saqtyu = *off
417yMC                   eval      $saqty1 = 0
417yMC                   eval      $saqty2 = 0
417yMC                   eval      $saqty3 = 0
     *
417yMC                   eval      $saorgu = *off
417yMC                   eval      $saorg1 = 0
417yMC                   eval      $saorg2 = 0
417yMC                   eval      $saorg3 = 0
     *
417yMC                   eval      $sacwtau = *off
417yMC                   eval      $sacwta = 0
     *
417yMC                   eval      $sacodeu = *off
417yMC                   eval      $sacode = *blanks
     *
417yMC                   eval      $samemou = *off
417yMC                   eval      $samemo = *blanks
     *
417yMC                   eval      $sabyu = *off
417yMC                   eval      $saby = *blanks
     *
417yMC                   eval      $sadateu = *off
417yMC                   eval      $sadate = 0
     *
417yMC                   eval      $satimeu = *off
417yMC                   eval      $satime = 0
     *
600aMC                   eval      $saFrmVrfyu = *off
600aMC                   eval      $saFrmVrfy = *blanks
     *
417yMC                   eval      $satrn#u = *off
417yMC                   eval      $satrn# = 0
     *
600aMC                   eval      $saFrmLcnsu = *off
416dD**                   Z-ADD0         A$LIC#
600aMC                   eval      $saFrmLcns = *blanks
     *
417yMC                   eval      $satasku = *off
417yMC                   eval      $satask = *blanks
     *
417yMC                   eval      $sacdspu = *off
417yMC                   eval      $sacdsp = *blanks
     *
     C                   endsr
416 A*----------------------------------------------------------------
416 A*     ZZZX2D - Copy xdock fields into data structure fields.
416 A*
416 AC     zzzx2d        begsr
     *
417yMC                   eval      $xdwhseu = *on
417yMC                   eval      $xdwhse = $pwhse
     *
417yMC                   eval      $xditemu = *on
417yMC                   eval      $xditem = $pitem
     *
417yMC                   eval      $xdpou = *on
417yMC                   eval      $xdpo = $ppo
     *
417yMC                   eval      $xdseq#u = *on
417yMC                   move      $pseq         $xdseq#
     *
417yMC                   eval      $xdqtyu = *off
417yMC                   eval      $xdqty1 = 0
417yMC                   eval      $xdqty2 = 0
417yMC                   eval      $xdqty3 = 0
     *
     C                   endsr

417aA*----------------------------------------------------------------
417aA*----------------------------------------------------------------
417aA*                     DRI SUBROUTINES
417aA*----------------------------------------------------------------
417aA*----------------------------------------------------------------

500 A*----------------------------------------------------------------
500 A*  clr$item  Clear $item data structure fields
500 A*----------------------------------------------------------------
500 A
500 AC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
600aAC                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

600aA*----------------------------------------------------------------
600aA*  clr$license  Clear $license data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C                   eval      $liemp# = $emp#
     C                   eval      $liuser = #curruser
     C                   eval      $lipgm  = #pgm
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobnbr
     C                   eval      $liTowhse = $pwhse
     C                   eval      $liTowhseu = *on
     C                   endsr

417zA*----------------------------------------------------------------
417zA*  clr$lichist  Clear $lichist data structure fields
417zA*----------------------------------------------------------------
417zA
417zAC     clr$lichist   begsr
     C                   eval      savever# = $lrver#
     C                   clear                   $lichist
     C                   eval      $lrver# = savever#
     C                   eval      $lremp# = $emp#
600bDC**                 eval      $lruser = #user
600bMC                   eval      $lruser = #curruser
     C                   eval      $lrpgm  = #pgm
     C                   eval      $lrjob  = #job
     C                   eval      $lrjobn = #jobnbr
     C                   eval      $lrwhse = $pwhse
     C                   eval      $lrwhseu = *on
     C                   endsr

     *----------------------------------------------------------------
     *  clr$licinfo  Clear $licinfo data structure fields
     *----------------------------------------------------------------

     C     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
640hAC                   clear                   $licinfo2
     C                   eval      $lnver# = savever#

600bDC**                 eval      $lnuser = #user
600bMC                   eval      $lnuser = #curruser
600bAC                   eval      $lnemp# = $emp#
     C                   eval      $lnpgm  = #pgm
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobnbr

     C                   endsr

600dA*----------------------------------------------------------------
600dA*  clr$slot  Clear $slot data structure fields
600dA*----------------------------------------------------------------
600dA
600dAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
600aAC                   clear                   $slot2
     C                   eval      $slver# = savever#
600aAC                   eval      $saemp#U = *on
600aAC                   eval      $saemp# = $emp#
     C                   endsr

710aA*----------------------------------------------------------------
710aA*  clr$slotdef  Clear $slotdef data structure fields
710aA*----------------------------------------------------------------
710aA
710aAC     clr$slotdef   begsr
710aAC                   eval      savever# = $sdver#
710aAC                   clear                   $slotdef
710aAC                   eval      $sdver# = savever#
710aAC                   endsr
710aA
     *----------------------------------------------------------------
     *  clr$uciinfo  Clear $uciinfo data structure fields
     *----------------------------------------------------------------

     C     clr$uciinfo   begsr
     C                   eval      savever# = $uiver#
     C                   clear                   $uciinfo
720cAC                   clear                   $uciinfo2
     C                   eval      $uiver# = savever#
     C                   eval      $uiaddemp = $emp#
     C                   eval      $uiaddusr = #curruser
     C                   eval      $uiaddpgm  = #pgm
     C                   eval      $uiaddjob  = #job
     C                   eval      $uiaddnbr = #jobnbr
     C*                  eval      $uiwhse = $pwhse
     C*                  eval      $uiTowhseu = *on
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
417yAC                   when      $dricommand = '*SLOT'
417yAC                   eval      $dridata = $slot
600aAC                   eval      $dridata2 = $slot2
417yAC                   when      $dricommand = '*XDOCK'
417yAC                   eval      $dridata = $xdock
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
640hAC                   eval      $dridata2 = $licinfo2
417zAC                   when      $dricommand = '*LICHIST'
417zAC                   eval      $dridata = $lichist
600aAC                   when      $dricommand = '*LICENSE'
600aAC                   eval      $dridata = $license
600aAC                   eval      $dridata2 = $license2
500 AC                   when      $dricommand = '*ITEM'
500 AC                   eval      $dridata = $item
500 AC                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $dridata = $uciinfo
720cAC                   eval      $dridata2 = $uciinfo2
710aAC                   when      $dricommand = '*SLOTDEF'
710aAC                   eval      $dridata = $slotdef
     C                   endsl

500 AC                   if        $dricommand = '*ITEM'
600aAC                             or $dricommand = '*SLOT'
600aAC                             or $dricommand = '*LICENSE'
640hAC                             or $dricommand = '*LICINFO'
720cAC                             or $dricommand = '*UCIINFO'
500 AC                   call(e)   'DRICOP'
500 AC                   parm                    $dricommand
500 AC                   parm                    $drisubcmd
500 AC                   parm                    $drisys2upd
500 AC                   parm      #pgm          $driprogram
500 AC                   parm      ' '           $drireturn
500 AC                   parm      ' '           $drimessage
500 AC                   parm                    $dridata
500 AC                   parm                    $dridata2
500 AC                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
417gMC                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
500 AC                   endif

     C                   select

417yMC                   when      %error and ck4err = *on
     C                   eval      error = *on
600aAC                   eval      errmsg    = 'Error occured on call to '
600aAC                                       + 'DRICOP'
600aAC                                       + '/' + %trim($drisubcmd)
600aAC                                       + ' from ' + #pgm
600aAC                   select
600aAC                   when      zmsflag
600aAC                   exsr      zm0105s
600aAC                   when      zmflag
600aAC                   exsr      zm0105
600aAC                   endsl

417yMC                   when      $drireturn <> '*OK' and ck4err = *on
     C                   eval      error = *on
600aAC                   select
600aAC                   when      zmsflag
600aAC                   exsr      zm0001s
600aAC                   when      zmflag
600aAC                   exsr      zm0001
     C*                  exsr      zzerrind
600aAC                   endsl

     C                   endsl

     C                   select
417yAC                   when      $dricommand = '*SLOT'
417yAC                   eval      $slot = $dridata
600aAC                   eval      $slot2 = $dridata2
417yAC                   when      $dricommand = '*XDOCK'
417yAC                   eval      $xdock = $dridata
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
640hAC                   eval      $licinfo2 = $dridata2
417zAC                   when      $dricommand = '*LICHIST'
417zAC                   eval      $lichist = $dridata
600aAC                   when      $dricommand = '*LICENSE'
600aAC                   eval      $license = $dridata
600aAC                   eval      $license2 = $dridata2
500 AC                   when      $dricommand = '*ITEM'
500 AC                   eval      $item = $dridata
500 AC                   eval      $item2 = $dridata2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $uciinfo = $dridata
720cAC                   eval      $uciinfo2 = $dridata2
710aAC                   when      $dricommand = '*SLOTDEF'
710aAC                   eval      $slotdef = $dridata
     C                   endsl

600aAC                   eval      zmflag = *off
600aAC                   eval      zmsflag = *off
417yAC                   eval      ck4err = *off
     C     enddricop     endsr

     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Aisle
Start From
Starting Level
Detail record
Starting Number
Current Maximum Level
Future Maximum Level
Racks on One Side
Duplicate license numbers found
license number
Status
Status, cannot be A, V, or Z
