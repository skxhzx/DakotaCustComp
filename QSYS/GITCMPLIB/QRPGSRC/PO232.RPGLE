417sA /COPY *libl/qcopysrc,hspecs
650rAH dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PO232   VS PO receiving - Change
     *  16 February, 1998
     *  Roxanne Harrison
     *  NOTES:
409 A*  Created using PO132, previous revision comments were removed.
     *    Calls PO236 for manual put away.
409 A*    02/18/98  RH
     *         - If item is not FSWMS, update PO file only (RC161)
409 A*    06/02/98  RH
     *         - Add manufacturer date field and code.
     *    12/16/15  RH
     *         - Non-stock items, not put away to warehouse in ZZUOM
     *           uses Designation code with '*' in position 5 (NSTK*)
     *
     *  Revisions
     *
218 A*    01/13/97  RH   2.18
     *      - Call RC160 with Parm $RSEQ, $RRPCK, $RPLBL
     *      - Use POHDR & PODTL instead of POH & POD
     *
219 A*    03/12/97  RH   2.19
     *      - Add  Average field to screen 1
     *      - Protect & non-display catch weight average if ITCWGT<>Y.
     *      - Added catch weight W1TWGT to PARMs.
     *      - Add extended item description
     *      - Update PODTL file in RC160 not PO132.
     *      - Fix to pass sequence # correctly to RC160.
221 A*    05/15/97  RH   2.21
     *      - Fix warning to compare qty recvd. to PO qty ordered.
     *      - Move PODTL vendor item to W2VITM to pass parm to print on label.
221 A*    06/10/97  RH   2.21
     *      - Add UPC code to SC1, optional entry field.
     *      - Add $PUPC to Parameters.
     *      - Add OPPLCN use generic license option to set LFLAG.
     *      - Add call PO136 to enter licnese #.
     *      - Change to default SC1 fields to 0 in ZZFIL1.
221 A*    06/12/97  HNK  2.21
     *      - Pass Ok message from RC160 to calling program.
222 A*    06/17/97  RH   2.22
     *      - Add $PRSQT parm to return total qty put away to calling program.
223 A*    07/07/97  RH   2.23
     *      - Only chain to update UPC in ZZUPD1 if UPC code is not blank.
401 A*    07/11/97  HNK  4.01
     *      - Error check added. (Cannot receive an item, if ready for
     *        export.)
     *      - ZZUHDR subroutine revised set the partial flag right.
401 A*    07/14/97  RH   4.01
     *      - Add Home slot to screen 1 for fixed item.
     *
TMP A*    07/17/97  DAS  TMP
     *      - Temporary revision for AFI.
     *      - Added slot number to screen for entry.
     *      - Pass slot number to RC160.
     *      - Assumptions:
     *         - Entire qty entered will be put into entered slot.
     *         - This should only be used if we can't find a slot.
     *         - Slot must be a verified slot or one that contains
     *           the item currently.
     *
TMP A*    07/29/97  HNK  TMP
     *         - Catch weight entry made optional.
     *
412 A*    07/21/99  HNK  4.12
     *         - Override logic added for mfg date sensitive item.
412 A*    08/06/99  RH   4.12
     *      - Recompile, ITEMMSC file changed.
     *
413 A*    10/27/99  DAS  4.13
     *      - Added command *QUICK for quick receive.
     *        This command only fills in the quantity received with
     *        the qty ordered. It must display the screen in order
     *        to get the number of pallets received.
413aA*    02/09/00  RH   4.13a
     *      - Add Pack and default tie/hi to screen.
     *      - Add F8 to call tie/hi maint.
413bA*    02/21/00  RH   4.13b
     *      - Add CW variance check if CW is entered.
     *        Use Item variance and system variance checks (see CW112)
413cA*    02/23/00  RH   4.13g
     *      - Add code to force individual F20 to be taken for each
     *        warning condition.
     *
414 A*    10/02/00  DAS  4.14
     *      - Revised ZZUOM to get corresponding SSB item. If SSB
     *        item exists then allow breakdown entry.
     *      - Revised format to display SSB info.
     *
414aA*    10/16/00  DAS  4.14a
     *      - Revised ZZUPD1 to NOT lock the UPC record when chaining.
     *
415 A*    11/16/00  HNK/RH  4.15
     *      - Commented line that moved 0 to W1EXDT.  This was putting
     *        zero in exp date field of slot file, when they take F20
     *        to override the warning.
415bA*    03/06/01  RH   4.15b
     *      - Allow Use by date to be entered in expire date field.
     *      - Calculate to verify use by date item can be received.
415cA*    03/29/01  HNK  4.15c
     *      - Check UPC code entered using CVTBAR program.
     *      - ZM0105 routine added.
     *      - Changed UPC error into a warning/override.
     *      - Displaying new warning message plus message sent
     *        back from CVTBAR.
     *      - If Mfg date entered is zero, branch out to end.
415dA*    04/12/01  MLB  4.15d
     *      - Add support to program for scanning catchwgt barcodes.
     *      - Revised SC1 to call DELTMPCW program when F3/F12 pressed.
     *      - Revised ZZCMD1 to call CW122 program.
     *      - Revised ZZINZ2 to call DELTMPCW program.
     *      - Revised ZZUHDR to call DELTMPCW program.
415eA*    08/06/01  HNK  4.15e
     *      - Enable Brk1 UOM for Same slot breakdown item.
     *
415fA*    08/22/01  DAS  4.15f
     *      - Revised 415e changes. Instead of allowing both normal
     *        and Brk1 qty entry, revised to only use the main qty
     *        entry field with the UOM for Brk1.
     *      - Added tables LBL and TYP to assist with descriptions.
     *      - Revised format for displaying descriptions correctly.
     *      - Revised ZZUOM to create descriptions correctly.
     *      - Revised ZZINZ2 to clear message queue
     *      - Revised ZZFIL1 to get home slot of base item if item
     *        is not type ' ' or 'B'.
     *
416aA*    09/24/01  DAS  4.16a
     *      - Revised to use new receiving option for expiration dates
     *
416bA*    09/25/01  DAS  4.16b
     *      - Revised to use subprogram GETPSLT to get pick slot.
     *      - Removed SLOT3 file because of above change.
     *
416cA*    09/25/01  DAS  4.16c
     *      - Revised to calculate EXPD when using Mfr date.
     *
416dA*    09/26/01  DAS  4.16d
     *      - Revised to use new receiving options for catch weights.
     *
416eA*    09/26/01  DAS  4.16e
     *      - Added file ITMEXCP.
     *      - Write record to ITMEXCP when exp date override taken.
     *
416fA*    10/06/01  DAS  4.16f
     *      - Revised to allow average to be selected when doing
     *        "First time only" catch weight entry.
     *      - Added file POCTYPE to track catch weight entry type.
     *      - Added routine ZZZCW to calculat catch weight.
     *
416gA*    10/18/01  DAS  4.16g
     *      - Revised to move LBQPCK to ITMEXCP record.
     *
416hA*    10/27/01  DAS  4.16h
     *      - Revised size of W1DWGT in FM to 9.2 from 7.2.
     *      - Revised corresponding fields in this program.
     *
416iA*    11/01/01  HNK  4.16i
     *      - Recalculate EXPD in ZZUPD1 routine for Mfr dated items.
     *        Reverse 415 change.
     *
416jA*    11/06/01  HNK  4.16j
     *      - Reset DTCHK to zero.
     *
416kA*    11/13/01  HNK  4.16k
     *      - Initialize EXPD.
416lA*    12/03/01  RH   4.16l
     *      - Recompiled, ITMEXCP file changed.
416mA*    02/28/02  MBL/HNK  4.16m
     *      - Revised program to receieve 4 new parms on the call
     *        to GETPSLT.
416nA*    07/02/02  RH   4.16n
     *      - Recompiled, ITEMMSC changed.
     *
417 A*    04/11/03  MLB  4.17
     *      - Enh: Add call to Retail UPC prompt program. This program
     *        will verify if Retail UPC is on file.
     *      - Added 3 new fields to *RCVLVL. OPRUPC, OPRUPS and OPRUPF.
417aA*    04/02/03  RH   4.17a
     *      - Add code to check expiration date using # of days out.
     *      - ITEMMSC file changed.
417bA*    04/08/03  RH   4.17b
     *      - UPC can have multiple items, change to use UPC2 file.
417cA*    04/10/03  MLB  4.17c
     *      - Enh: Revised qty received error checking to include
     *        total exception qty. Added file POEXCP to program.
417dA*    04/15/03  MLB  4.17d
     *      - Enh: Extended length of UPC field to 50 characters and
     *        renamed field W1UPCD.
417eA*    04/21/03  RH   4.17e
     *      - Change- allow override for #of days out from expiration
     *      - Enh: Create exception record if expire date override.
417fA*    04/28/03  MLB  4.17f
     *      - Fix: Revised ZZCHK1 to clear EXPD when mfg date has error.
417gA*    05/13/03  MLB  4.17g
     *      - Fix: Revised ZZUPD1 to use field W1UPCD instead
     *        of W1UPC
417hA*    05/13/03  MLB  4.17h
     *      - Enh: Add support for lot/license tracking.
417iA*    05/13/03  MLB  4.17i
     *      - Enh: Add support for lot code entry.
417jA*    05/27/03  RH   4.17j
     *      - Fix: Only allow one UPC code per Vendor/Item
     *      - Allow override, the current UPC may the correct and the
     *        existing UPC is wrong.
417kA*    05/28/03  RH   4.17k
     *      - Enh: Capture and add UPC for item-vendor if not on file.
417lA*    05/29/03  RH   4.17l
     *      - FIX: Right adjust UPC code after CVTBAR even if invalid.
417mA*    06/04/03  RH   4.17m
     *      - FIX:ODOVR date override was left on after first time in.
417nA*    07/01/03  RH   4.17n
     *      - FIX:Use W1UPC and W1UPCD to test for add to prevent
     *        blank UPC code in file.
417oA*    07/22/03  RH   4.17o
     *      - FIX:Move code to calculate CKEXDT, was not calculated
     *            in some cases.
417pA*    01/20/04  RH   4.17p
     *      - ENH:Allow Entered (FIFO) date to be entered for MOVE IN
     *        PO. Vendor name='MOVEIN'or MOVEIN PICK. Add W1FIFO field
417qA*    02/01/04  HNK  4.17q
     *      - FIX:Put an additional qty check so cursor gets
     *        positioned to qty field after scanning the UPC code.
     *        UPC scan user CHECK(ER).
     *
417rA*    03/23/04  DAS  4.17r
     *      - Converted into ILE.
     *      - Revised to use CLCDUR2 instead of julian routines.
     *      - Revised to send mfg date, fifo date, upc and
     *        average weights to PO236.
     *
417sA*    06/07/04  MLB  4.17s
     *      - Fix: Changed Valid range for number of pallets error
     *        to be 1 to 999 instead of 0 to 99999. Variable passed
     *        to PO236 is defined 3,0.
     *
417tA*    08/11/04  RH   4.17t
     *      - Fix: Revised to call GETSLOTITM, if the item was an
     *        alias item for a SSB item, GETBASE would return the SSB
     *        item which is not a slot item.
     *
500 A*    10/17/04  DAS  5.00
     *      - Enh: Revised to allow F10 along with F20.
     *
500aA*    04/02/05  DAS  5.00a
     *      - ENH: Revised set on *IN65 for non-live department. This will
     *        override iaflag (non-FSWMS item).
     *      - FIX: After returning from PO236 revised code to use $l fields
     *        instead of $r fields.
     *
500bA*    10/11/05  RH   5.00b
     *      - ENH: Revised to chain to POMFR1 with label#, update
     *        existing record if found.  Problem POMFR records
     *        already existing when label# have cycled around again
     *        and having previous item's expiration date info.
500cA*    02/06/06  RH   5.00c
     *      - ENH: Add OBOVR flag to write exception when F20 ovrride
     *        is taken for mfg date error.
     *        Change CWOVR field used to OAOVR field for clarity.
500dA*    02/20/06  RH   5.00d
     *      - FIX: Change to use seperate flags for date checks to
     *        allow override correctly.
510aA*    07/31/06  RH   5.10a
     *      - FIX: Expiration/#days out override was not working
     *        Dtchk flag was getting being set off in a wrong place.
510bA*    10/03/06  RAH  5.10b
     *      - Enh: Revised program to add support for Client id
510cA*    10/12/06  RH   5.10c
     *      - Enh: Revised program to send date keyed in in place
     *        of Mfg date parm.
510dA*    10/26/06  RH   5.10d
     *      - Fix: Initialize license date fields, was writing for
     *        non-dated item.
510eA*    12/27/06  RH   5.10e
     *      - Enh: Write different exception for each date override.
     *        Add OEOVR and OFOVR flags, each override sets a flag.
510fA*    04/28/07  MLB  5.10f
     *      - Fix: Revised ZZZCW to correct divide by zero error
     *        when only Eaches are received.
510gA*    09/27/07  LMC  5.10g
     *      - Enh: Added Call to Mfr Code Decipher program
510hA*    10/09/07  LMC  5.10h
     *      - Enh: Added UPC code to Code Decipher program
510iA*    10/10/07  RH   5.10i
     *      - Enh: Added call to convert string/qty.
510jA*    10/11/07  LMC  5.10j
     *      - Enh: Added call to MF200 with *open to determine if the
     *        date code decipher programs exist on the client site.
510kA*    11/28/07  MLB  5.10k
     *      - Enh: Revised program to add support for Standard weight
     *        items. Standard wgt items will be treated just like
     *        random weight items. ITCWGT=S=Standard weight item.
510lA*    12/03/07  LMC  5.10l
     *      - Enh: Write ITMEXCP record if invalid date is returned
     *        from the date code decipher programs.
510mA*    01/13/08  LMC  5.10m
     *      - Enh: Cmd11 - only valid on date sensitive items
520aA*    02/11/08  RH   5.20a
     *      - Fix: For Mfg dt item, expd is reduced by user days,
     *             DATE2 was reducing expd by user days again.  Fix to
     *             use EXPD for DATE2 on mfg dated items.
520bA*    06/18/08  RH   5.20b
     *      - Enh: Display new message if qty received is greater
     *        than qty ordered.  Will allow user to notify buyer.
520cA*    06/08/09  MLB  5.20c
     *      - Fix: Defined new Result fields for W1QRC1,2,3 on call
     *        to RC161. DSPF fields were causing DDE errors.
520dA*   10/14/09  MLB  5.20d
     *     - Fix: Revised program to process catchwgt variance first
     *       time when no qty has been received when Catchwgt Option
     *       set to 2=First time only.
     *
530 A*   02/11/10  MLB  5.30
     *     - Fix: Revised ZZCMD1 to clear $LEXPDAT, $LMFRDAT and
     *       $LRTN when F11 =Mfr Decipher is selected to ensure that
     *       previously processed mfr date data is not used for
     *       the current item being received.
     *
530aA*    06/11/10  JCJ  5.30a
     *      - Enh: Reference new receiving system options
530bA*   08/12/10  RH   5.30b
     *     - Enh: Add whse to parms for MF200.
640aA*    01/13/11  RH   6.40a
     *      - Enh: Add Whse to CHKLIVE parms
     *
640bA*    02/08/11  RBD  6.40b
     *      - Enh: Allow weight to be entered in kilograms ... it
     *        typically is entered in pounds.  Use F7 to toggle
     *        between F7=Kilograms and F7=Pounds.
     *      - Removed function key text from dds and added it as
     *        command lines in this program.  Changed scrn specs
     *        from PO232FM to PO23201.
     *      - Fix: Don't setof 63 in dspscr.
640cA*    08/16/11  RH   6.40c
     *      - Enh: Add Overflow Y/N to screen.
     *        Rename fro PO23201 to PO23202 for GUI
640dA*    05/22/12  RTR  6.40d
     *      - Fix: Always error if catchweight is negative
640eA*    07/13/12  LMC  6.40e
     *      - Enh: return decipher code to pass to licinfo file
640fA*    07/31/12  LMC  6.40f
     *      - Enh: Add incoming parms from GS1 or POASn to auto
     *        populate the fields on the screen.
640gA*    09/10/12  LMC  6.40g
     *      - Enh: Added parm to PO236 to pass blank license#
640hA*    09/19/12  LMC  6.40h
     *      - Enh: Added Brand field. Pass it to PO236.
     *        Created new display file PO23204 to replace PO23203.
     *        Added Dri programs for *item.
640iA*    09/20/12  RH   6.40i
     *      - Enh: Change to use wk field to pass mfg shelf life days
     *        to allow use of other values to be used in calculations
640jA*    12/17/12  MLB  6.40j
     *      - Fix: Revised program to set W1EXDT, W1MFDT to zeros if
     *        return from MF200 returned with an error and the user
     *        had previously keyed an invalid date into the screen
     *        expiration or mfg date field.
     *
650aA*    01/10/13  LMC  6.50a
     *      - Fix: CMDLN1 was not being loaded correctly
650bA*    02/26/13  LMC  6.50b
     *      - Fix: SSB items not setting indicator *in94 correctly
650cA*    03/08/13  LMC/RH  6.50c
     *      - Fix: Move calculated check date to RCV exception date
     *      when entered date > today + # of days out (CKEXDT)
650dA*    03/08/13  MLB  6.50d
     *      - Fix: Revised pgm to check if value loaded into exqty > 999
     *        and if yes, then set exqty = 999. Error found at Get
     *        Fresh who stores watermelon in lbs in qty fields.
650eA*    03/26/13  RBD  6.50e
     *      - Problem: Sporadically, PO's were being received with no c/w
     *        written to PODTL even though c/w was in fact being entered.
     *      - Scenario: User enters c/w which falls into the acceptable
     *        range and blanks out Average Y/N (W1AVG) which turns on
     *        error, but then subr zzchkt sets off error and W1AVG goes
     *        into zzzcw as blank. Note, qty recv'd, whether they enter
     *        the full qty ordered or not, has no impact.
     *      - Fix: In the above scenario, W1AVG was allowed to be blank,
     *        then in subr zzzcw value cwcalc was not getting populated,
     *        which in turn kept w1twgt from getting populated, then
     *        w1twgt would get passed to PO236 as 0. The culprit was in
     *        subr zzchkt, it should not have been setting off error.
650fA*    03/22/13  LMC  6.50f
     *      - Enh: Add logic for passing parms needed for haccp cross
     *      reference file.
650gA*    05/15/13  LMC  6.50g
     *      - Enh: Added RCVPO transaction.
650hA*    06/04/13  LMC  6.50h
     *      - Enh: GFCc Mods has been changed to a standard 650 mod
650iA*    06/19/13  LMC  6.50i
     *      - Enh: Parm added on call to PO236 for GTIN. Used for
     *      calculating PTI for the LICINFO file.
     *      - Enh: Added parm to pass GTIN from PO120 for PTI.
650jA*    07/31/13  LMC  6.50j
     *      - Enh: Added Catch weight override to exception processing
     *      - Enh: Added new file to hold catch weight supporting info
650kA*    09/23/13  LMC  6.50k
     *      - Fix: Lock on chain to POCTYPE, was causing error.
650lA*    10/24/13  LMC  6.50l
     *      - Enh: Added PTI entry edit, with override.
     *      - replaced display file PO23204 with PO23205.
650mA*    10/07/13  LMC  6.50m
     *      - Fix: write pocwexcp everytime
650nA*    11/11/13  LMC  6.50n
     *      - Fix: ERLRNG & ERHRNG were being wiped out when the
     *        a tie/high error was issued, I was using those fields
     *        to write the POCWEXCP file, but when the tie/high error
     *        error occurred it clears the $mdt data structure losing
     *        the value of the fields for the write to the POCWEXCP
     *        file. Moving the value of those fields when they are
     *        populated on the warning to the fields in the POCWEXCP
     *        file to eliminate the dec data error that was occurring.
650oA*    12/09/13  RBD  6.50o
     *      - Fix: Fields holding low/high var were not getting cleared,
     *        so if an item had zero var but the previous item did not, the
     *        var for the last item was used instead of the system var.
650pA*    12/09/13  LMC  6.50p
     *      - Fix: PTI edit should only occur if *in73 is off.        d,
650qA*    06/05/14  LMC  6.50q
     *      - Enh: Added incoming parm for New oss receiving notice.  d,
     *        Pass new oss parm to PO236.                             d,
     *        Load W1NOTE field to indicate OSS Receiving on display. d,
     *      - replaced display file PO23205 with PO23206.
650rA*     09/08/14  LMC  6.50r
     *       - Enh: Add program tracking.
     *         Data area PGMTRACK has been created to control whether
     *         log records should be written to file PGMTRCK.
     *         Records are written to the file when the data are
     *         contains a '1'.
650sA*     09/24/14  MLB/RH  6.50s
     *       - Fix: Revised routine ZZCHK1 to clear fields W1EXDT, EXPD
     *         when processing mfr dated item. These 2 fields were
     *         causing expiration date validations to take place and
     *         causing error message PO13243 to be issued in error.
650tA*    07/25/14  LMC  6.50t
     *      - Enh: Removed Uciinfo for catch weight entry if user     d,
     *        cancels his receiving.                                  d,
     *
650uA*    02/16/15  LMC  6.50u
     *      - Enh: Load w1note with cross dock if pdspcl = 'XD'
     *      This takes priority over user selecting oss receiving.
     *      This allows the user to see they are doing a cross-dock
     *      which is helpful if they are use to seeing direct putaway
     *      program instead of manual. We modified PO120 to send all
     *      cross docking to PO232. Xdock takes priority over directed
     *      putaway.
700aA*    08/28/15  RH   7.00a
     *      - Fix: Protect Breakdown 1 entry if itum2=blanks.  Was
     *      allowing breakdown qty to be recieved for type 'S' item
     *      when no breakdown UOM or quantity was defined. Error on
     *      PO236 forced F12 but left qty in the RCVDOCK slots.
700bA*    03/21/16  LMC  7.00b
     *      - Enh: Adding logic for Metric.
700cA*    09/02/16  LMC  7.00c
     *      - Enh: Adding New screen for capturing breakdown UPC.
     *        This screen will display before the detail entry screen.
710aA*    05/03/17  RH   7.10a
     *      - Enh: Move Glazier date checking to zzzGFCd s/r, remove
     *        from zzchk1.
720aA*    10/11/18  LMC  7.20a
     *      - Enh: Before calling PO236 for license plates, we need
     *        to print box labels if item is coded for printing
720bA*    11/28/18  LMC  7.20b
     *      - Enh: UCI Tracking
730aA*    10/28/19  LMC/RH  7.30a
     *      - FIX: Use ITFLGD to test for earlier expiration date
     *        error, was not processing if override was taken for
     *        not enough shelf life days.
740aA*    02/04/20  LMC  7.40a
     *      - Enh: Use the UOM from the $item.
740bA*    03/30/20  LMC  7.40b
     *      - Enh: Edits for # of days out should not apply for
     *        Manufacturer dated items. Only if Expiration date
     *        is entered.
740c *    05/22/20  LMC  7.40c
     *      - Enh: Send Vendor to all calls of CVTBAR so that the
     *        new decipher barcode process works.
740d *    08/04/20  LMC  7.40d
     *      - Enh: Only display pti entry if the item is setup for
     *        pti selection.
750a *    06/01/21  LMC  7.50a
     *      - Enh: CW variances for breakdown were not being
     *        calculated.
760a *   04/29/22  LMC  760a
     *     - The host system FRESHBYTE requires a lot code.
     *       They tell us the lot code is the po&line number
     *       On a call today 4/29/22 they said the lot# was
     *       8 positions, 6 for po with leading zeros and 2 for line
     *       I am assuming the 2 positions for line# should have a
     *       leading zero also. so po 00030001 300 is po line 1.
760b *   02/01/23  LMC  760b
     *     - 650s was causing a issue when and error occured in zzchk1
     *       it was wiping out the expd and the w1expt fields, but
     *       they were never being recalulated and then the check
     *       to see if newer product exist fails because the expd
     *       field value is 0. expd is never recalculated.
760c *    05/10/22  LMC  7.60c
     *      - Enh: Protect UPC entry field on screen1 if the receiving
     *        option OPNUPC is set to Y, to not allow upc's to be
     *        loaded during receiving.
     *
770aA*   08/27/22  TDC  7.70a
     *      - DockVue: Added update of POSTATUS table when the PO is
     *        updated.
     *      - Added check for the dockvue system option (opdckv)
     *----------------------------------------------------------------
     * BiRite's Custom Mods
     *
BIR A*   10/03/06  RAH  BIR
     *     - Added file UPCLOG.  Add records to this file any time    a
     *       a UPC record is added to UPC3.
BIRaA*   07/21/05  HNK  BIRa
     *     - Display qty ordered.                                     a
BIRbA*   04/24/17  MLB  BIRb  P#01737
     *     - Enh: Revised pgm to call pgm, HPOIUSE to check if Retalix
     *       P/O in use. If not, set p/o Inuse flag (DDHIUSE = Y) and
     *       DDHZUA3, pos 1-1 = D=Dakota. Indicates that BFC has started
     *       receiving on the p/o and can continue to do so. If Inuse and
     *       and DDHZUA3 <> 'D', then receiving cannot proceed. Display
     *       error to user with ID of user that has p/o locked.
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
     *----------------------------------------------------------------
     * Client Custom Revisions: Dairyland
     *
DRYaA*    03/16/11  RH   DRYa
     *      - Revised program to NOT allow CW variace override.
DRYbA*    03/21/11  RH   DRYb
     *      - Reversed DRYA change. SVCWEN=1st time wt, total entry
     *        calculates based on ordered qty, will not work for
     *        partial received.
DRYcA*    07/19/13  RBD  DRYc
     *      - Force the following options' values as follows:
     *        'Force catch weight entry' = Y
     *        'Allow catch weight entry' = 2 (First receipt only)
     *        'Catch weight value to enter' = 2 (Total)
     *      - Instead of comparing the entered weight against Dakota
     *        variances, the weight will be compared against the total weight
     *        sent by the host in the first misc field of PODTLM.
     *        If the weight entered by the user is not within the host
     *        weight variance, the user can't receive the item.
     *        Note: to calculate the c/w tolerances, divide the imported
     *        weight by the qty ordered to get the unit weight, and use
     *        the unit weight to calculate the tolerances based on the
     *        qty received.  This allows them to enter a qty received which
     *        is different from the qty ordered.
     *      - Added code to test the weight being sent from the host to
     *        ensure the contents are numeric. If not numeric, then use
     *        existing comparison tests.
     *      - Do not allow user to override catchweight entered.
     *      - Disable F9=Cwgt Entry.
     *      - Per K Romano's request, replaced msg PT13019 with new
     *        shorter version, PT13023.
DRYdA*    09/04/13  RH   DRYd
     *      - Fix: Add code to use PDQOR2 or PDQOR3 to calculate
     *        hostUnitWgt to prevent divide by 0 error.
DRYeA*    09/05/13  RBD DRYe
     *      - Fix: Use correct breakdown for qty received to calculate
     *        weight tolerances.
DRYfA*    11/14/13  RBD DRYf
     *      - Per L DiMarco, changed logic for calculating tolerance
     *        percentage. Item recv'd must pass 2 different tests.
     *        1. Calc the unit wt difference between what was ordered
     *           and received, and divide it by the ordered unit weight
     *           to get the tol%.  If tol% >= high var, throw hard halt.
     *        2. If there is a brkdn 1 qty ordered or received, calc the
     *           qty diff between ordered and received and divide it by
     *           qty ordered to get the tol%.  If tol% >= high var, throw
     *           hard halt.
     *      - Note: it doesn't matter whether we compare tol% to low or
     *        high var, at Dairyland they're always the same per Laury.
     *      - Added conversion breakdown logic as they can import
     *        weight for one u/m and then receive the item in the same
     *        and/or different units of measure.
     *      - This rev replaces DRYd and DRYe.
DRYgA*    01/07/14  RBD DRYg
     *      - Fix: Increased size of some fields to avoid receiver value
     *        too small error.
DRYhA*    06/08/16  LMC DRYh
     *      - Enh: Bypass hard edit on expiration date. User will
     *        get this warning instead.
     *        "Item cannot be accepted - Use by date"  will allow them
     *        to receive expired product on date sensitive items, just
     *        as it does on Mfg Dated items, with the warning "Not
     *        Enough Shelf life remaining"
DRYiA*    06/13/16  LMC DRYi
     *      - Enh: If the expirtation is <= today, and the user
     *        overrides - Chef's want the status in PO236 to be set
     *        to 'QU' for Quarantine.
DRYjA*    06/29/16  LMC DRYj
     *      - Enh: If the mfg date entered fails the Not Enough Shelf
     *        life edit - Chef's want the status in PO236 to be set
     *        to 'QU' for Quarantine.
DRYkA*    10/30/17  LMC DRYk
     *      - Enh: Chef's no longer wants the receipts that are
     *        expired to have QU status.
     *----------------------------------------------------------------
     * Client Custom Revisions: Finkle Distributing
     *
FKL A*    03/02/09  MLB  FKL
     *      - Revised program to retrieve w/h dept, section type and
     *        item desc. for all 9's items.
     *      - Added Finkle to RNZa mod.
FKLaA*    08/19/08  RH   FKLa
     *      - Non-display tie/hi set on 88.
FKLbA*    10/17/08  RH   FKLb
     *      - Only allow one UPC code for an item/vendor
FKLcA*    12/18/08  RH   FKLc
     *      - Fix: change non-display tie/hi from 88 to 86
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Food Pro
     *
FPRaA*    03/18/15  RH   FPRa
     *      -  Enh: Do not allow breakdown UOM / qty to be entered
     *----------------------------------------------------------------
     * Jordanos Custom Mods
     *
JORaA*   11/01/10  RH   JORa
     *     - Position cursor to quantity field, custom mod missed
     *       during V6.10 update.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions:  Inter County Bakers
     *
ICBa *   07/10/12  GJA  ICBa
     *     - Position cursor to quantity field
     *
     *----------------------------------------------------------------
     * MJ Kellner Custom Mods
MJKa *   08/19/08  RH   MJKa
     *     - Changed to not default W1FIFO to today's date
MJKb *   09/24/14  RH   MJKb                                          a
     *     - Changed to require Lot code for Lot code item.
760a *   09/30/22  01/26/16  RH  V7.60  NOTE                          a
     *     - FIX: Add MJKb code not merged in ENH for original change.
     *----------------------------------------------------------------
     * Client Custom Revisions: Renzi Foodservice
     *
RNZ A*   08/11/08  MLB  RNZ
     *     - Revised program to force ITCWGT='N' when ITCWGT='S'.
     *       Want std wgt catchwgt items treated as non-catchwgt.
RNZaA*    03/02/09  MLB  RNZa
     *      - Revised program to retrieve w/h dept, section type and
     *        item desc. for all 9's items.
     *      - Added file PODTLM.
     *
     *----------------------------------------------------------------
     * Saval Custom Mods
     *
SVLaA*   07/22/09  RH   SVLa
     *     - Default # of pallets to 1 on screen 1
SVLbA*   08/05/09  RH   SVLb
     *     - Allow invalid UPC codes to be captured.
     *----------------------------------------------------------------
     * Client Custom Revisions: Springfield
SGCaA*   12/03/09  RH   SGCa
     *     - Enh: Revised program to display error if receive pallet
     *       qty is greater than mfg tie/hi quantity.
SGCbA*   02/15/12  RH   SGCb
     *     - Fix: Add to only execute SGCA for Springfield, fix desc
     *     - Only display error if Mfg Tie/hi is not 0
SGCcA*   05/08/17  MLB  SGCc
     *     - Enh: Revised pgm to call pgm, HPOIUSE to check if Retalix
     *       P/O in use. If not, set p/o Inuse flag (DDHIUSE = Y) and
     *       DDHZUA3, pos 1-1 = D=Dakota. Indicates that BFC has started
     *       receiving on the p/o and can continue to do so. If Inuse and
     *       and DDHZUA3 <> 'D', then receiving cannot proceed. Display
     *       error to user with ID of user that has p/o locked.
     *     - Add SGCc to BIRb mod.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: SoFo Foods
     *
SOFaA*   02/27/09  RH   SOFa
     *     - Do not process standard wt items ITCWGT='S' like random
     *       weight catch wegiht items, do not enter wt.
SOF A*    03/02/09  MLB  SOF
     *      - Revised program to retrieve w/h dept, section type and
     *        item desc. for all 9's items.
     *      - Added SoFo to RNZa mod.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Glazier
     *
GFCa *    10/04/11  GJA  GFCa
     *      - Enh:  Add password window when date override is
     *        processed.
GFCb *    10/04/11  GJA  GFCb
     *      - Enh:  Change expiration date check to be
     *        Expiration date < today + distr days
     *        Expiration date > today + mfg shelf life days
     *        Mfg date < today - distr days
     *        Mfg date = today
     *        Use by date < today + distr days
     *        Use by date > today + mfg shelf life days
GFCc *    03/25/12  GJA  GFCc
     *      - Fix:  Mfg date = today was sending wrong message
GFCd *    01/24/13  GJA  GFCd
     *      - Fix:  Change expiation date message
     *              LMC fixed issue with condition on mfg date
     *
     *----------------------------------------------------------------
     * YHata's Custom Mods
     *
YHA A*   10/10/07  RH   YHA
     *     - Added ordered qty to screen 1.
YHAbA*   12/19/07  RH   YHAb
     *     - Allow invalid UPC codes to be captured.
YHAcA*   04/24/08  RH   YHAc
     *     - Display error if mfg date = today, allow override & exception
YHAdA*   09/20/12  RH   YHAd
     *     - Calculate pack date for Date senstitive only item using
     *       # of days out - 1. Store in LICINFO code *MFGDTE
YHAeA*   11/26/12  RH   YHAe - HILO
     *     - If Mfg Decipher code is not found for PO vendor, use
     *       item vendor #.
YHAfA*   06/04/13  LM   YHAf
     *     - Yhata will receive old message until they can be trained
     *       with the new message, then this mod will be removed
YHAhA*   09/29/16  MLB/RH   YHAh - Kauai
     *     - If Mfg Decipher code is not found for PO vendor, use
     *       item vendor #.
     *     - Add YHAh to YHAe mod.
     *
     *----------------------------------------------------------------
     * Client Custom Revisisions: CDI
     *
CDI A*   07/14/14  MLB  CDI
     *     - Allow invalid UPC codes to be captured.
     *     - Added CDI Miss warehouse to YHAb mod.
     *
     *----------------------------------------------------------------
     * Client Custom Revisisions: Kohl Wholesale
     *
KHLaA*   08/12/14  LMC  KHLa
     *     - Allow invalid UPC codes to be captured.
KHLb *   08/31/14  RTR  KHLb
     *     - Write new UPC Code to ITMEXCP file for reporting
     *
     *----------------------------------------------------------------
ADFaA*    04/20/17  RH  ADFa
     *      - Enh: Add to DRYh mod to bypass hard edit on expiration
     *        date. User will get warning instead
     *
     *----------------------------------------------------------------
     * Client Custom Revisisions: Colony Foods
     *
CFIa *   09/17/18  RTR  CFIa
     *     - Added CFI to BIR mod to log UPC codes.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   Field position to
     *  21 - 40   Field input error (reverse display)
510jA*  66        Date Code Decipher check to non display cmd11
417iA*  88        Lot code entry not allowed. Hide fields.
417pA*  89        FIFO entered date entry not allowed. Hide fields.
     *  90        View mode (Protect input fields)
     *  91        Change mode (protect key)
     *  97        Error message subfile indicator
     *  98        Error on screen (sound buzzer)
     *  99        Universal record indicator (very temporary usage)
     *
650rA*----------------------------------------------------------------
650rA*  Binding Directories
650rA*----------------------------------------------------------------
650rA
650rAHbnddir('BFCBND')
     *----------------------------------------------------------------
     *  File Specs
     *
640bDF*po232fm   cf   e             workstn
640cDF*po23201   cf   e             workstn
GFCaDF*po23202   cf   e             workstn
640hDF*po23203   cf   e             workstn
650lDF*po23204   cf   e             workstn
650qDF*po23205   cf   e             workstn
700bDF*po23206   cf   e             workstn
700cDF*po23207   cf   e             workstn
700cMFpo23208   cf   e             workstn
     F                                     infds(infds)
     Fpodtl     if   e           k disk
     F                                     rename(pdrec:record)
RNZaAFpodtlm    if   e           k disk
417cAFpoexcp    if   e           k disk
     Fpohdr     uf   e           k disk
BIRbAF                                     infds(file1ds)
     Fpiritem   if   e           k disk
     Fwarehs    if   e           k disk
214 AFunmesr    if   e           k disk
CBIaAFdesigsp   if   e           k disk
219 AFitemdsc   if   e           k disk
219 AFoptions   if   e           k disk
417bA*PC     UF  E           K        DISK                      A
417kAFupc3      uf a e           k disk
417kA*PC2    IF  E           K        DISK
417k *           UPREC                             KRENAMEU2REC
417jAFupc1      if   e           k disk
     F                                     rename(uprec:u1rec)
416bD**OT3   IF  E           K        DISK
TMP AFslot2     if   e           k disk
     F                                     rename(slrec:s2rec)
640bAFslot3     if   e           k disk
     F                                     rename(slrec:s3rec)
409 AFitemmsc   if   e           k disk
409 AFLabel2    if   e           k disk
413aAFitemdef   if   e           k disk
416fAFpoctype   uf a e           k disk
500bDF*omfr     o    e             disk
500bAFpomfr1    uf a e           k disk
416eAFitmexcp   o    e           k disk
417pAFpofifo    o    e           k disk
BIR AFupclog    if a e           k disk
650jAFpocwexcp  uf a e           k disk    Prefix(cw_) rename(exrec:cwexrec)
650rAFpgmtrck   o  a e           k disk
770aA*----------------------------------------------------------------
770aA*  Standard SQL variables and constants
770aA*----------------------------------------------------------------
770aA
770aA /copy qcopysrc,c#stdsql
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
415fAD a13             s              1    dim(13)
415fD**                  DESC    1   7 20
640bDD*desc            s             20    dim(8) ctdata perrcd(1)
SGCaDD*desc            s             20    dim(9) ctdata perrcd(1)
DRYcDD*desc            s             20    dim(10)ctdata perrcd(1)
650lDD*desc            s             20    dim(12)ctdata perrcd(1)
650lMD desc            s             20    dim(13)ctdata perrcd(1)
415fAD lbl             s             13    dim(4) ctdata perrcd(1)
415fAD typ             s             10    dim(1) ctdata perrcd(1)
416dAD cwt             s             27    dim(3) ctdata perrcd(1)
700cDD*cmdln           s             79    dim(7) ctdata perrcd(1)
700cMD cmdln           s             79    dim(8) ctdata perrcd(1)
650fAD $parms1         s             48    dim(20)
     *----------------------------------------------------------------
510bA*  Customer id
     *----------------------------------------------------------------
510bA /copy qcopysrc,id#birite
CBIaA /copy qcopysrc,id#cheney
FKL A /copy qcopysrc,id#finkle
RNZ A /copy qcopysrc,id#renzi
SVLaA /copy qcopysrc,id#saval
SGC A /copy qcopysrc,id#sgc
SOF A /copy qcopysrc,id#sofo
YHAaA /copy qcopysrc,id#yhata
YHAeA /copy qcopysrc,id#yhahilo
500eA /copy qcopysrc,id#jordano
DRYaA /copy qcopysrc,id#dairyla
GFCaA /copy qcopysrc,id#glazier
ICBaA /copy qcopysrc,id#icb
KHLaA /copy qcopysrc,id#khl
CDI A /copy qcopysrc,id#cdi
CDI A /copy qcopysrc,id#cdijac
MJK A /copy qcopysrc,id#mjkelln
FPRaA /COPY QCOPYSRC,Id#fpr
CFIaA /copy qcopysrc,id#cfi
ADFaA /COPY QCOPYSRC,ID#adf
RNZaA*----------------------------------------------------------------
RNZaA*  P/O Detail Misc. /copy mbrs
RNZaA*
RNZaA /copy qcopysrc,podm1_rtx
RNZaA /copy qcopysrc,podm2_rtx
RNZaA /copy qcopysrc,podm3_rtx
RNZaA /copy qcopysrc,podm4_rtx
RNZaA /copy qcopysrc,podm5_rtx
RNZaA*
RNZaA*----------------------------------------------------------------
RNZaA*  Working variables
RNZaA*
RNZaAD rtxall9item     C                   const('9999999999')
DRYcAD digits          c                   const('0123456789')
770aAD dockvue         s              1n    inz('0')
770aAD nostamp         s               z     inz
RNZaAD*
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
     D  $ppo                  22     30
     D  $pseq                 31     35  0
     D  $pitem                36     50
416eA*----------------------------------------------------------------
416eA*  Redefinition data structures
416eA*
416eAD                 ds
416eAD  dspo                   1      9
416eAD  dslbl                 10     16  0
416eAD  dsexpd                17     24  0
416eAD  dsfdis                 1     12
416eAD  dstdis                13     24
510i D $cerm           ds
510i D  xcerm                  1     60
510i D  $cmsg                  1      4
417p *----------------------------------------------------------------
417p *  Constants
     D move1           c                   const('MOVEIN PICK')
     D move2           c                   const('MOVEIN OVERFLOW')
760a D freshbyte       c                   const('FRESHBYTE')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
417tAD @getsi          c                   const('GETSLOTITM')
GFCaAD @pwd            c                   const('CHKLIST')
     D @fmtit          c                   const('FRMTIT')
650gAD @crtrcv         c                   const('CRTRCVTRN')
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
     *
720aAD $bparm          ds
720aAD  $bcmd                  1      8
720aAD  $bprg                  9     18
720aAD  $buky                 19     68
720aAD  $brtn                 69     76
720aAD  $berm                 77    136
720aAD  $bmsg                 77     80
720aA*   Redefine key
720aAD  $bpo                  19     27
720aAD  $brcvdt               28     35  0
720aAD  $bqty                 36     40  0
720aAD  $bprint               41     50
720aAD  $bitem                51     65
720aAD  $buom                 66     67
     *
221 AD $lparm          ds
221 AD  $lcmd                  1      8
221 AD  $lprg                  9     18
221 AD  $luky                 19     68
221 AD  $lrtn                 69     76
221 AD  $lerm                 77    136
221 AD  $lmsg                 77     80
221 A*   Redefine key
221 AD  $lwhse                19     21  0
221 AD  $litem                22     36
221 AD  $lpo                  37     45
221 AD  $lrq1                 46     50  0
221 AD  $lrq2                 51     55  0
221 AD  $lrq3                 56     60  0
221 AD  $lrpal                61     63  0
417hAD  $llott                64     64
417hAD  $llict                65     65
DRYiAD  $QUstat               66     67
     *
TMP AD  $lwhs2                19     21  0
TMP AD  $lwhd2                22     26
TMP AD  $litm2                27     41
TMP AD  $ldisp                42     53
TMP AD  $ldesg                54     58
TMP AD  $lst                  59     60
TMP AD  $lsdef                61     62
TMP AD  $lactv                63     64
417hA*
417hAD  $llot                 37     37
417hAD  $lltrk                38     38
510gA*
530bDD* $lmfr#                19     29  0
530bDD* $lmfritem             30     44
530bDD* $ldakitem             45     59
530bMD  $lmfr#                22     32  0
530bMD  $lmfritem             33     47
530bMD  $ldakitem             48     62
415dA*
415dAD $mparm          ds
415dAD  $mcmd                  1      8
415dAD  $mprg                  9     18
415dAD  $muky                 19     68
415dAD  $mrtn                 69     76
415dAD  $merm                 77    136
415dAD  $mmsg                 77     80
415dA*   Redefine key
415dAD  $mwhs3                19     20p 0
415dAD  $mpo3                 21     29
415dAD  $mseq                 30     32p 0
415dAD  $mitm3                33     47
415dAD  $mqyr1                48     50p 0
415dAD  $mqyr2                51     53p 0
415dAD  $mqyr3                54     56p 0
415dAD  $mcwte                57     59p 0
415dAD  $mcwtt                60     64p 2
415dAD  $mcwta                65     68p 2
BIRbA*
BIRbAD $rparm          ds
BIRbAD  $rcmd                  1      8
BIRbAD  $rprg                  9     18
BIRbAD  $ruky                 19     68
BIRbAD  $rrtn                 69     76
BIRbAD  $rpousr               77     86
BIRbAD  $rerm                 77    136
BIRbAD  $rmsg                 77     80
BIRbA*   Redefine key
BIRbAD  $rcmpn                19     21
BIRbAD  $rdivn                22     24
BIRbAD  $rdptn                25     27
BIRbAD  $rwhsn                28     30
BIRbAD  $rwhse                31     33  0 inz(0)
BIRbAD  $rvndn                34     43
BIRbAD  $rpo                  44     52
BIRbAD  $rbfcflib             53     62

640fA*----------------------------------------------------------------
640fA*  Convert Barcode Parms
640fA*----------------------------------------------------------------

640fA /COPY *libl/qcopysrc,C#CVTPARMS
640fA /COPY *libl/qcopysrc,C#BARCODE
640hA*----------------------------------------------------------------
640hA*  DRI parameters
640hA*----------------------------------------------------------------
640hA /COPY *libl/qcopysrc,C#DRIPARMS
640hA
640hA*----------------------------------------------------------------
640hA*  Data Formats
640hA*----------------------------------------------------------------
640hA /COPY *libl/qcopysrc,C#ITEM
650tA /COPY *libl/qcopysrc,C#UCIINFO
640hAD savever#        s                   like($itver#)
417rA*------------------------------------------------------------------
417rA* CLCDUR2 parameters
417rA*------------------------------------------------------------------

     D $cdcmd          s              8

     D $cddatein       s              8  0
     D $cdtimein       s              6  0

     D $cdyears        s              3  0
     D $cdmonths       s              3  0
     D $cddays         s              3  0
     D $cdhours        s              3  0
     D $cdminutes      s              3  0
     D $cdseconds      s              3  0

     D $cddateOut      s              8  0
     D $cdtimeOut      s              6  0

221 A*
417hA*----------------------------------------------------------------
417hA*  Working fields.
417hA*
417hAD                 ds
417hAD  lottrk                 1      4
417hAD  lictrk                 5      8
     *
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
640dDD* errmsg                 1     50
640dMD  errmsg                 1     78
     *
     D  erwhse                 1      2p 0
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  eritm                  1     15
     D  erco#                 16     19p 0
     *
TMP AD  erdisp                16     27
409 A*
409 AD  ermday                 1      2p 0
409 AD  ermfdt                 3      6p 0
409 AD  erexdt                 7     10p 0
409 AD  erltst                11     14p 0
409 AD  erdday                15     16p 0
409 AD  eruday                17     18p 0
     D  $ec                    1      2p 0
415bA*
415bAD  erused                 1      4p 0
415bAD  erdisd                 5      6p 0
415bAD  erusrd                 7      8p 0
415bAD  ersell                 9     12p 0
413bA*
413bAD  ertcwt                 1      5p 2
413bAD  erlrng                 6     10p 2
413bAD  erhrng                11     15p 2
413bAD  errg1c                16     17p 1
413bAD  errg2c                18     19p 1
413bAD  erexwt                20     24p 2
     *
     D  ertcw#                 1      3p 0
     D  erqpck                 4      6p 0
     *
416aAD  erentd                 1      5p 0
416aAD  ertod                  6     10p 0
     *----------------------------------------------------------------
219 A* Data structure
219 A*
417 A*    OPRUPC  -  Prompt user for Retail UPC during receiving? (Y,N)
417 A*    OPRUPS  -  Allow user to skip Retail UPC scan? (Y,N)
417 A*    OPRUPF  -  Require Retail UPC on file before receipt? (Y,N)
760cA*    OPNUPC  -  Do Not allow UPC's to be loaded during receiving
417 A*
219 AD opdata          ds
219 AD  opstyp                 1      1
219 AD  opwhdp                 2      6
219 AD  opum1                  7      8
219 AD  opdum                  9     23
219 AD  opcum                 24     43
219 AD  opcdiv                44     52  2
770aAD  opdckv                50     50
219 AD  opcaut                53     53
219 AD  opcwrn                54     54
219 AD  opcrng                55     57  1
219 AD  opwum                 58     72
219 AD  opxdsc                73     73
219 AD  optend               117    117
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
416aAD  opexck                28     28
416dAD  opcwen                29     29
416dAD  opcwtp                30     30
416dAD  opcwfr                31     31
417 AD  opipck                32     32
417 AD  oprupc                33     33
417 AD  oprups                34     34
417 AD  oprupf                35     35
760cAD  opnupc                62     62
413bA*  *SYSTEM  -  System options.
413b *    OPEPM   -  Using EPM module (Y,N).
413b *    OPRF    -  Using RF module (Y,N).
413b *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
413b *    OPLETD  -  Print letdown labels (Y,N).
530aD*****OPWRNC  -  Perform catch weight variance check (Y,N).
530aM*    OPWRNC  -  Check CW variance in Truck Builder (N,M,C,B)
413bA*    OPRG1C  -  Catch weight low variance percentage.
413bA*    OPRG2C  -  Catch weight high variance percentage.
413bA*    OPIMPI  -  Import item fields from host.(Y,N).
530aD*****OPICW   -  Individual catch weight entry (Y,N).
530aM*    OPICW   -  Check CW count in Truck Builder. (N,M,C,B)
530aA*    OPMPCK  -  Allow multiple pick slots for fixed items (Y/N).
530aA*    OPRCDY  -  Number of days to keep receiving logs.
530aA*    OPPKDY  -  Number of days to keep picking logs.
530aA*    OPRTHS  -  Number of weeks - exported routes to keep.
530aA*    OPCRHS  -  Number of weeks - exported customer rtns to keep.
530aA*    OPPOHS  -  Number of weeks - exported p/o's to keep.
530aA*    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
530aA*    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
530aA*    OPTBJQ  -  Run Truck builder on Job Que (Y/N)
530aA*    OPISHS  -  Number of weeks to keep history file
530aA*    OPUCI   -
530aA*    OPWRNCR -  Check CW var during RCV individual Entry
530aA*    OPICWR  -  Check CW count during RCV individual Entry
530aA*    OPTRAX  -  Using TRAX module (Y/N).
770aA*    OPDCKV  -  Using DockVue (Y/N).
     *
413b D  opepm                  1      1
413b D  oprf                   2      2
413b D  opcapc                 3      3
413b D  opletd                 4      4
413bAD  opwrnc                 5      5
413bAD  oprg1c                 6      8  1
413bAD  oprg2c                 9     11  1
413bAD  opimpi                12     12
413bAD  opicw                 13     13
530aAD  opmpck                14     14
530aAD  oprcdy                15     15  0
530aAD  oppkdy                16     16  0
530aAD  oprths                17     19  0
530aAD  opcrhs                20     22  0
530aAD  oppohs                23     25  0
530aAD  opiahs                26     28  0
530aAD  opmshs                29     31  0
530aAD  optbjq                32     32
530aAD  opishs                33     35  0
530aAD  opishsa               33     35
530aAD  opuci                 36     36
530aAD  opwrncr               37     37
530aAD  opicwr                38     38
530aAD  optrax                39     39
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
640hA*----------------------------------------------------------------
640hA*  Program info data structure
640hA*
640hA /COPY *libl/qcopysrc,C#PGMINFDS
     *----------------------------------------------------------------
     *  Program info data structure
     *
640hDD*               sds
640hDD* #prog            *proc
640hDD* #job                 244    253
640hDD* #user                254    263
640hDD* #jobn                264    269
640hDD* #jobdt               276    281  0
640hDD* #jobtm               282    287  0
BIRba*
BIRbA*----------------------------------------------------------------
BIRba*  File info data structures
BIRbA*----------------------------------------------------------------
BIRbA
BIRbA /COPY *libl/qcopysrc,C#file1ds
650lA*----------------------------------------------------------------
650lA*  Prototypes
650lA*----------------------------------------------------------------
650lAD calcpti         pr                  extpgm('CALCPTI')
650lA * Input
650lAD   pGTIN                             like($pgtin)
650lAD   pLOT                              like($pbclot)
650lAD   pPackDate                         like($pbcProdD)
650lAD   pPTI                              like(pppti)
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
     *  D-Specs created by RPG4MAX conversion.
     *
     D $ldwgt          s              9  2
     D $lflag          s              1
     D $lord           s              7  0
     D $lseq           s              5  0
     D $lum1           s              5
     D $lum2           s              5
     D $lum3           s              5
     D $lven           s             11  0
     D $lvitm          s             15
     D $lvnam          s             40
650lAD $pw1pti         s              4  0
     D $msgf           s             10
650tAD $unext          s             13  0
     D #bsu1           s              5
     D #bsu2           s              5
     D #bsu3           s              5
     D #msgid          s              7
     D #msgtp          s              7
     D #odesc          s             30
     D #oitem          s             15
     D #opdsc          s             15
     D #osu1           s              5
     D #osu2           s              5
     D #osu3           s              5
     D #oswgt          s              7  2
     D #oswt2          s              7  2
     D #oswt3          s              7  2
     D #otype          s              1
     D #oum1           s              2
     D #oum2           s              2
     D #oum2q          s              3  0
     D #oum3           s              2
     D #oum3q          s              3  0
YHAeAD #oven#          s             10  0
     D #sitem          s             15
417rAD avgwt1          s              7  2
417rAD avgwt2          s              7  2
417rAD avgwt3          s              7  2
700cAD b1type          s              7
700cAD b2type          s              7
700cAD b1upc           s                   like(upupc)
700cAD b2upc           s                   like(upupc)
DRYgMD caltol1         s             11  4
DRYgMD caltol2         s             11  4
DRYgMD caltol1x100     s             13  4
DRYgMD caltol2x100     s             13  4
640hAD chk4err         s               n
     D ckexdt          s              8  0
SGCaAD ckqrc1          s                   like(pdqrc1)
     D clear           s              5  0
     D cmdtkn          s              1
640bAD CnvWgt          s              9  2
     D comand          s              5  0
     D cwcalc          s              1  0
     D cwovr           s              1
     D date1           s              8  0
     D date16          s              6  0
     D date2           s              8  0
     D date2o          s              6  0
     D date26          s              6  0
510lAD ddcode          s              1
     D done            s              1
650rAD dsecs           s             14  0
     D dtchk           s              1
     D dtchk2          s              1
500d D dtchk3          s              1
500d D dtchk4          s              1
     D dtfrmt          s              1  0
     D e               s              2  0
     D enter           s              5  0
     D eof             s              1
     D error           s              1
     D exdtj           s              5  0
     D expd            s              8  0
     D expdj           s              5  0
     D exwgt           s              9  2
     D forevr          s              1
     D full            s              1
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
     D gmwksv          s              2  0
     D help            s              5  0
     D hirng           s              9  2
     D hivar           s              9  2
DRYcAD hostcw0         s              7  0
DRYcAD hostcwa         s              7
DRYfMD hostcw2dec      s              7  2
DRYfAD hostUnitWgt     s              9  4
     D hvskp           s              1
     D iaflag          s              1
     D iatest          s              1
     D ihrng           s              9  2
     D ihvar           s              9  2
     D ilrng           s              9  2
     D ilvar           s              9  2
     D j$date          s              6  0
     D j$dd            s              2  0
     D j$jd            s              5  0
     D j$md            s              3  0
     D j$mm            s              2  0
     D j$tst           s              9  9
     D j$x             s              2  0
     D j$yd            s              7  0
     D j$yywk          s              3  0
     D j$yyyy          s              4  0
640bAD kgs2lbs         c                   2.20462262
640bAD KiloLbs         s              1
     D kyitem          s                   like(slitem)
     D kypick          s                   like(slpick)
     D kystat          s                   like(slstat)
     D lflag           s              1
     D ltstd6          s              6  0
     D ltstd8          s              8  0
GFCbAD glzmfd          s              8  0
     D lvskp           s              1
     D lwrng           s              9  2
     D lwvar           s              9  2
     D mfdtj           s              5  0
     D mfgd            s              8  0
GFCdAD netdays         s              3  0
SGCaAD maxqty          s                   like(pdqrc1)
640eAD mexpd           s              8  0
640eAD mfgdte          s              8  0
700cAD Needb1          s               n
700cAD Needb2          s               n
700cAD Ntype           s              7
     D nxtscr          s              3
     D ocode           s              8
500c D oaovr           s              1
500c D obovr           s              1
510e D ocovr           s              1
     D odovr           s              1
510e D oeovr           s              1
510e D ofovr           s              1
     D ovrrid          s              1
     D part            s              1
650rAD pgmtracking     s               n
650gAD poppcs          s                   like($lpcs)
     D prg1c           s              4  3
     D prg2c           s              4  3
650lAd pplot           s             20
650lAd pppti           s              4  0
650lAD ptiovr          s              1
650lAD ptichk          s              1
650lAd ptinodate       s              6  0
     D qtchk           s              1
SGCaAD qtchk1          s              1
DRYfAD qtyDiff         s              5  0
DRYfAD qtyord          s              5  0
DRYfAD qtyord1         s              5  0
DRYfAD qtyord2         s              5  0
DRYfAD qtyord3         s              5  0
DRYfAD qtyrcv          s              5  0
DRYfAD qtyrcv1         s              5  0
DRYfAD qtyrcv2         s              5  0
DRYfAD qtyrcv3         s              5  0
650gAD rcvpocomplete   s               n
DRYgMD rcvUnitWgt      s             11  4
     D recv            s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
CBIa D sdesig          s              1
     D sdqrc1          s              5  0
     D sdqrc2          s              5  0
     D sdqrc3          s              5  0
     D ssbflg          s              1
     D stop            s              1
SGCaAD svckq1          s                   like(pdqrc1)
     D svcwen          s              1
     D svcwfr          s              1
     D svcwtp          s              1
     D svdwgt          s              9  2
     D svexck          s              1
     D svexdt          s              6  0
     D svhi            s              2  0
     D svmfdt          s              6  0
700bAD svopwum         s                   like(opwum)
650lAD svpti           s              4  0
     D svqrc1          s                   like(pdqrc1)
     D svqrc2          s                   like(pdqrc2)
     D svqrc3          s                   like(pdqrc3)
     D svrupc          s              1
760cAD svnupc          s              1
     D svtie           s              4  0
     D svupc           s             50
     D temp10          s             10
     D tmpwgt          s              9  2
     D today           s              8  0
     D todayo          s              6  0
     D todyj           s              5  0
650tAD uciexists       s               n
650tAD unexta          s             13
     D upchk           s              1
     D upchk2          s              1
     D uxflag          s              1
     D vrfycw          s              1
     D warn            s              1
DRYgMD wgtDiff         s             11  4
     D whse            s              3  0
640iAD wkmday          s              3  0
     D wkwhse          s                   like($pwhse)
510cAD woexdt          s              8  0
     D wofifo          s              8  0
510cAD woindt          s              8  0
417rAD womfdt          s              8  0
     D work2           s              2
     D work4           s              4
     D wotcw           s              9  2
700cAD Writeb1         s               n
700cAD Writeb2         s               n
     D wrttyp          s              1
     D wtchk           s              1
     D w1item          s             15
     D w1upc           s                   like(upupc)
640hAD zmflag          s               n
640hAD zmsflag         s               n
650tA*----------------------------------------------------------------
650tA*  Prototypes
650tA*----------------------------------------------------------------
650tAD ucilic#         pr                  extpgm('UCILIC#')
650tA * Input
650tAD   unext                       13  0 const
650tAD   uwhse                        3  0 const
650rA*----------------------------------------------------------------
650rA*  Time variables
650rA*----------------------------------------------------------------
650rA
650rAD CurrStamploc    s               z
650rAD CurrStampsys    s               z
650rAD CurrStampuc     s               z
650rA
650rAD bfcoffset       s              3  0 inz(0)
650rA*----------------------------------------------------------------
650rA* Function prototypes.
650rA*----------------------------------------------------------------
650rA
650rA /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new batch.
     *              *EDIT    - Edit batch.
     *              *DELETE  - Delete batch.
     *              *PRINT   - Print batch edit listing.
     *              *POST    - Post batch.
413 A*              *QUICK   - Quick receive
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
221 AC                   parm                    $pupc            20
222 AC                   parm                    $prsqt            7 0
640fAc                   parm                    $pqty             8 0
640fAc                   parm                    $p#pall           5 0
640fAc                   parm                    $pexpdt           6 0
640fAc                   parm                    $pwgt            11 3
640fAc                   parm                    $pmfgdt           6 0
640fAc                   parm                    $plot            20
640fAc                   parm                    $plpn            50
650fAc                   parm                    $parms1
650gAC                   parm                    $lsavetrn         7 0
650iAc                   parm                    $pgtin           14
650iAc                   parm                    $pbcProdD         6 0
650iAc                   parm                    $pbclot          20
650qAc                   parm                    $posscode         1
     *                    PARM           $PDEV  10
     *                    PARM           $PFORM 10
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
221 AC                   eval      *in92 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
650gAc                   eval      rcvpocomplete = *off
640fAc                   eval      $barcode = $cvtdata
640fAc                   eval      $barcode2 = $cvtdata2
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
650rAc                   exsr      zzstrt
     C     nxtscr        caseq     '01 '         sc1
700cAC     nxtscr        caseq     '01B'         sc1b
     C     nxtscr        caseq     '02 '         sc2
     C                   endcs
650rAc                   exsr      zzend
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
650gA*
650gA*   check to see if po receipt is completed
650gA*   if completed update label/transaction with qty information
650gA*   else just mark them closed. - ended and closed dates
650gAC                   exsr      zzrcvpoclose
     *
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
640bAC                   write     cmdrec
     C                   exfmt     screen1                              50
     C                   endif
     *
700cAC                   if        nxtscr = '01B'
700cAC                   write     cmdrec
700cAC                   exfmt     screen1b                             50
700cAC                   endif
     *
     C                   if        nxtscr = '02 '
     **                   EXFMTSCREEN2                50
     C                   endif
     *
     *   Initialize error indicators and fields
     *
409 AC                   setoff                                       010203
409 AC                   setoff                                       040506
409 AC                   setoff                                       070809
409 AC                   setoff                                       10
     C                   setoff                                       111213
     C                   setoff                                       14
700cAC                   setoff                                       1516
650lAC                   setoff                                       17
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       303132
     C                   setoff                                       3334
650lAC                   setoff                                       37
640bDC**                 setoff                                       616263
640bMC                   setoff                                       6162
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcpmq
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
JDO A*    For Jordano's ...
JDOb *  Position cursor to QTY field.
JDO A
JDO AC                   if        client = jordanos
ICBaAC                             or client = icb
JDOb C                   eval      *in01 = *on
JDOb C                   endif
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
700cA*----------------------------------------------------------------
700cA*
700cA*  Screen 01b initialization
700cA*
700cAC     scr01bi       begsr
700cA*
700cA*  This screen will get initiated if receiving options to
700cA*  capture upc's for breakdown is turned on.
700cA*
700cA*  We will display the screen1b if the item has breakdowns
700cA*  defined, and we do not have a UPC record for the breakdown uom
700cA*
700cA /free
700cA   writeb1 = *off;
700cA   writeb2 = *off;
700cA   w1buom1 = ' ';
700cA   w1bupc1 = ' ';
700cA   w1buom2 = ' ';
700cA   w1bupc2 = ' ';
700cA   *in15 = *off;
700cA   *in16 = *off;
700cA   // breakdown 1 is setup on item
700cA   if $itum2 <> ' ';
700cA     Needb1  = *on;
700cA     // do we have a upc loaded for this breakdown uom
700cA     setll ($pwhse: $pitem) upc1;
700cA     dow forevr = forevr;
700cA       reade ($pwhse: $pitem) upc1;
700cA       if %eof(upc1);
700cA         leave;
700cA       endif;
700cA       if upuom = $itum2;
700cA         needb1  = *off;
700cA         leave;
700cA       endif;
700cA     enddo;
700cA   endif;
700cA   // breakdown 2 is setup on item
700cA   if $itum3 <> ' ';
700cA     Needb2  = *on;
700cA     // do we have a upc loaded for this breakdown uom
700cA     setll ($pwhse: $pitem) upc1;
700cA     dow forevr = forevr;
700cA       reade ($pwhse: $pitem) upc1;
700cA       if %eof(upc1);
700cA         leave;
700cA       endif;
700cA       if upuom = $itum3;
700cA         needb2  = *off;
700cA         leave;
700cA       endif;
700cA     enddo;
700cA   endif;
700cA   // need to capture a breakdown upc
700cA   if needb1 = *on or needb2 = *on;
700cA     nxtscr = '01B';
700cA     exsr zzdft1b;
700cA   endif;
700cA /end-free
700cAC     end01ib       endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzget2
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
415dA*
415dA*   Remove any existing catchweight entry records.
415dAC                   if        itcwgt = 'Y'
510kAC                             or itcwgt = 'S'
SOFaAC                             and client <> sofo
415dAC                   exsr      zzdlcw
415dAC                   endif
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
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
415dA*
415dA*   Remove any existing catchweight entry records.
415dAC                   if        itcwgt = 'Y'
510kAC                             or itcwgt = 'S'
SOFaAC                             and client <> sofo
415dAC                   exsr      zzdlcw
415dAC                   endif
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys
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

640bA*     Setup converted weight field.
640bAC                   exsr      zzcnvwgt

     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     C                   endif
     *  If error, then do not update P.O. header file
     C     $lrtn         cabeq     '*CANCEL '    endsc1
     C     $lrtn         cabeq     '*EXIT   '    endsc1
     *
     C                   exsr      zzuhdr
     C                   eval      nxtscr = 'EOJ'
     C     endsc1        endsr
700cA*----------------------------------------------------------------
700cA*
700cA*  SC1b -  Screen 1b
700cA*
700cAC     sc1b          begsr
700cA*
700cA*  Test for F3 - Exit
700cA*
700caC                   if        *inkc
700cAC     *loval        setll     record
700cAC                   eval      nxtscr = 'EOJ'
700cAC                   eval      $prtn = '*EXIT   '
700cAC                   goto      endsc1b
700cAC                   endif
700cA*
700cA*  Test for F5 - Refresh
700cA*
700cAC                   if        *inke
700cAC                   if        $pcmd <> '*VIEW   '
700cAC                   exsr      scr01bi
700cAC                   endif
700cAC                   goto      endsc1b
700cAC                   endif
700cA*
700cA*  Test for F12 - Previous
700cA*
700cAC                   if        *inkl
700cAC     *loval        setll     record
700cAC                   eval      nxtscr = 'EOJ'
700cAC                   eval      $prtn = '*CANCEL '
700cAC                   goto      endsc1b
700cAC                   endif
700cA*  Test for F9  - skip
700cA*
700cAC                   if        *inki
700cAC     *loval        setll     record
700cAC                   eval      nxtscr = '01 '
700cA*    Setup command display line 1.
700cA*
700cAC                   select
700cA*
700cAC                   when      itcwgt <> 'N' and itflgd = 'Y'
700cAc                             and KiloLbs = 'P'
700cAC                   eval      cmdln1 = cmdln(1)
700cA*
700cAc                   when      itcwgt <> 'N' and itflgd = 'Y'
700cAc                             and KiloLbs = 'K'
700cAC                   eval      cmdln1 = cmdln(2)
700cA*
700cAC                   when      itcwgt <> 'N' and itflgd = 'N'
700cAc                             and KiloLbs = 'P'
700cAC                   eval      cmdln1 = cmdln(3)
700cA*
700cAc                   when      itcwgt <> 'N' and itflgd = 'N'
700cAc                             and KiloLbs = 'K'
700cAC                   eval      cmdln1 = cmdln(4)
700cA*
700cAC                   when      itcwgt = 'N' and itflgd = 'Y'
700cAC                   eval      cmdln1 = cmdln(5)
700cA*
700cAC                   when      itcwgt = 'N' and itflgd = 'N'
700cAC                   eval      cmdln1 = cmdln(6)
700cA*
700cAC                   endsl
700cAC                   goto      endsc1b
700cAC                   endif
700cA*
700cA*  Test for other command keys
700cA*
700cAC                   exsr      zzcmd1b
700cAC     cmdtkn        cabeq     *on           endsc1b
700cA*
700cA*  Some other key pressed.
700cA*
700cA*     Check input and write/update record.
700cA*
700cAC                   if        $pcmd = '*ADD    '  or
700cAC                             $pcmd = '*CHANGE '
700cA
700cAC                   exsr      zzchk1b
700cAC     error         cabeq     *on           endsc1b
700cAC                   exsr      zzupd1b
700cAC     error         cabeq     *on           endsc1b
700cAC                   endif
700cA*  If error, then do not update P.O. header file
700cAC     $lrtn         cabeq     '*CANCEL '    endsc1b
700cAC     $lrtn         cabeq     '*EXIT   '    endsc1b
700cA*
700cAC                   eval      nxtscr = '01 '
700cAC     endsc1b       endsr
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
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys
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
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     C                   endif
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

     *
650rAC     *dtaara       define    pgmtrack      pgmtracking
650rAC                   in        pgmtracking
510bA* Get client id.

510bAC                   call      'GETCLIENT'
510bAC                   parm                    client           10
YHAeAC                   parm                    client2          10
760aAc                   parm                    clientinit        3
760aAc                   parm                    clienthost       10
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
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
417rA* ************ DO NOT USE  -  USE CLCDUR2 INSTEAD **************
     *                                                                   DOC
409 AC     gtoj$         begsr
     C                   eval      g$date = g$date
     * SPLIT DATE INTO MONTH, DAY, YEAR FIELDS
     C                   if        dtfrmt = 1
     C                   movel     g$date        g$yy
     C                   move      g$date        work4
     C                   movel     work4         g$mm
     C                   move      work4         g$dd
     C                   else
     C                   movel     g$date        g$mm
     C                   move      g$date        work4
     C                   movel     work4         g$dd
     C                   move      work4         g$yy
     C                   endif
     * CREATE 4 DIGIT YEAR
     C                   move      g$yy          g$yyyy
     C                   if        g$yy >= 60
     C                   movel     '19'          g$yyyy
     C                   else
     C                   movel     '20'          g$yyyy
     C                   endif
     C                   eval      g$jd = 0
     C                   eval      g$mmwk = g$mm - 3
     C                   eval      gmwksv = g$mmwk
     C                   if        g$mmwk < 0
     C                   add       12            g$mmwk
     C                   endif
     C                   if        gmwksv <> 0
     C                   eval(h)   g$jd = g$mmwk * 30.6
     C                   endif
     C                   add       g$dd          g$jd
     C     g$yyyy        sub       1900          g$yywk
     C                   if        g$yywk <> 0
     C                   if        gmwksv < 0
     C                   eval      g$yywk = g$yywk - 1
     C                   endif
     C                   endif
     C                   eval      g$jyd = g$yywk * 365.25
     C                   add       g$jyd         g$jd
     C     g$jd          div       7             g$wk7
     C                   mvr                     g$dw
409 AC                   endsr
     *----------------------------------------------------------------
     *
417rA* ************ DO NOT USE  -  USE CLCDUR2 INSTEAD **************
     *                                                                   DOC
409 AC     jtog$         begsr
     C     j$jd          div       365.25        j$yywk
     C     j$jd          div       365.25        j$tst
     C                   if        j$tst = 0
     C                   eval      j$yywk = j$yywk - 1
     C                   endif
     C                   eval      j$yd = j$yywk * 365.25
     C                   eval      j$yd = j$jd - j$yd
     C                   if        j$yd > 306
     C                   add       1             j$yywk
     C                   endif
     C                   eval      j$x = 0
     C                   dou       j$yd <= j$md
     C                   add       1             j$x
     C     j$x           mult(h)   30.6          j$md
     C                   enddo
     C                   eval      j$x = j$x - 1
     C     j$x           mult(h)   30.6          j$md
     C     j$yd          sub       j$md          j$dd
     C     j$x           add       3             j$mm
     C                   if        j$mm > 12
     C                   eval      j$mm = j$mm - 12
     C                   endif
     C     j$yywk        add       1900          j$yyyy
     C                   if        dtfrmt = 1
     C                   move      j$yyyy        work2
     C                   movel     j$mm          work4
     C                   move      j$dd          work4
     C                   movel     work2         j$date
     C                   move      work4         j$date
     C                   else
     C                   move      j$yyyy        work2
     C                   movel     j$mm          work4
     C                   move      j$dd          work4
     C                   move      work2         j$date
     C                   movel     work4         j$date
     C                   endif
409 AC                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCPMQ  Clear program message queue.
     *
     C     zmcpmq        begsr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   write     msgctl
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
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
401 A*
401 A*    ZMSMSG  Send program message to a different program msgq
401 A*
401 AC     zmsmsg        begsr
401 AC                   if        $msgf = *blanks
401 AC                   eval      $msgf = #msgf
401 AC                   endif
401 AC                   call      'PUTMSG'
401 AC                   parm                    $msgf
401 AC                   parm                    #msgid
401 AC                   parm                    #msgtp
401 AC                   parm                    #msgdt
401 AC                   parm      $pprg         #pgmq2           10
401 AC                   parm                    #msgk             4
401 AC                   eval      #msgdt = *blanks
401 AC                   eval      $msgf = *blanks
401 AC                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
640bM*   PIR0105  Generic message.
     *
415cAC     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
415cAC                   endsr
     *
BIRbA*    Send message to previous pgm message queue.
BIRbAC     zm0105p       begsr
BIRbAC                   eval      #msgid = 'PIR0105'
BIRbAC                   eval      #msgtp = '*DIAG  '
BIRbAC                   movea     errmsg        $md(1)
BIRbAC                   exsr      zmsmsg
BIRbAC                   eval      $pmsg = #msgk
BIRbAC                   endsr
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
409 A*----------------------------------------------------------------
409 A*    PIR1010  Date must be <OR= today's date.
409 A*
409 AC     zm1010        begsr
409 AC                   eval      #msgid = 'PIR1010'
409 AC                   eval      #msgtp = '*DIAG  '
409 AC                   movea     errmsg        $md
409 AC                   exsr      zmpmsg
409 AC                   endsr
510mA*----------------------------------------------------------------
510mA*    ZM13250  Item not date sensitive.
510mA*
510mAC     zm13250       begsr
510mAC                   eval      #msgid = 'PO13250'
510mAC                   eval      #msgtp = '*DIAG  '
510mAC                   movea     errmsg        $md
510mAC                   exsr      zmpmsg
510mAC                   endsr
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
221 D*R                   MOVEADESC      ERRMSG
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
413bA*----------------------------------------------------------------
413bA*   PT13020  Warning: Entered catch weight not within +/- range.
413bA*
413bAC     zm19          begsr
413bAC                   eval      #msgid = 'PT13019'
413bAC                   eval      #msgtp = '*DIAG  '
413bAC                   movea     errmsg        $md
413bAC                   exsr      zmpmsg
413bAC                   endsr
417jA*----------------------------------------------------------------
417jA*   PO23201  Error: UPC code exists for ventor/item.
417jA*
417jAC     zm21          begsr
417jAC                   eval      #msgid = 'PO23201'
417jAC                   eval      #msgtp = '*DIAG  '
417jAC                   movea     errmsg        $md
417jAC                   exsr      zmpmsg
417jAC                   endsr
DRYcA*----------------------------------------------------------------
DRYcA*   PT13023  Warning: Tot c/w not within +/- range.
DRYcA*
DRYcAC     zm23          begsr
DRYcAC                   eval      #msgid = 'PT13023'
DRYcAC                   eval      #msgtp = '*DIAG  '
DRYcAC                   movea     errmsg        $md
DRYcAC                   exsr      zmpmsg
DRYcAC                   endsr
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
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7973  Record does not exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
    AC                   exsr      zmpmsg
     ****                 EXSR ZMSMSG
     ****                 MOVE #MSGK     $PMSG
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Record is locked.
     *
     C     zm74          begsr
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
    AC                   exsr      zmpmsg
     ****                 EXSR ZMSMSG
     ****                 MOVE #MSGK     $PMSG
     C                   endsr
     *----------------------------------------------------------------
219 A*   PIR1005  Value must be 'Y' or 'N'
     *
219 AC     zm1005        begsr
219 AC                   eval      #msgid = 'PIR1005'
219 AC                   eval      #msgtp = '*DIAG  '
219 AC                   movea     errmsg        $md
219 AC                   exsr      zmpmsg
219 AC                   endsr
640dA*----------------------------------------------------------------
640dA*   PIR9999  Generic message - length 78 chars.
640dA*
640dAC     zm9999        begsr
640dAC                   eval      #msgid = 'PIR9999'
640dAC                   eval      #msgtp = '*DIAG  '
640dAC                   movea     errmsg        $md(1)
640dAC                   exsr      zmpmsg
640dAC                   endsr
219 A*----------------------------------------------------------------
219 A*    PO21001  Multiple qty entered, Catch wt avg must be 'N'
219 A*
219 AC     zm2101        begsr
219 AC                   eval      #msgid = 'PO21001'
219 AC                   eval      #msgtp = '*DIAG  '
219 AC                   eval      $md = *blanks
219 AC                   exsr      zmpmsg
219 AC                   endsr
     *----------------------------------------------------------------
     *   TF17201
     *
     C     zm3201        begsr
     C                   eval      #msgid = 'TF17201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
520bA*----------------------------------------------------------------
520b *   PO23202  Qty received greater than qty ordered.
520b *
520b C     zm3202        begsr
520b C                   eval      #msgid = 'PO23202'
520b C                   eval      #msgtp = '*DIAG  '
520b C                   movea     errmsg        $md(1)
520b C                   exsr      zmpmsg
520b C                   endsr
650lA*----------------------------------------------------------------
650lA*   PO23203  PTI doesn't match calculated PTI.
650lA*
650lAC     zm3203        begsr
650lAC                   eval      #msgid = 'PO23203'
650lAC                   eval      #msgtp = '*DIAG  '
650lAC                   movea     errmsg        $md(1)
650lAC                   exsr      zmpmsg
650lAC                   endsr
401 A*----------------------------------------------------------------
401 A*     PO13226  cannot receive an item, if ready for export.
401 A*
401 AC     zm3226        begsr
401 AC                   eval      #msgid = 'PO13226'
401 AC                   eval      #msgtp = '*DIAG  '
401 AC                   movea     errmsg        $md(1)
401 AC                   exsr      zmsmsg
401 AC                   eval      $pmsg = #msgk
401 AC                   endsr
409 A*----------------------------------------------------------------
409 A*     PO13228  Item cannot be accepted.
409 A*
409 AC     zm3228        begsr
409 AC                   eval      #msgid = 'PO13228'
409 AC                   eval      #msgtp = '*DIAG  '
409 AC                   movea     errmsg        $md(1)
409 AC                   exsr      zmpmsg
409 AC                   endsr
415bA*----------------------------------------------------------------
415bA*     PO13229  Item cannot be accepted.
415bA*
415bAC     zm3229        begsr
415bAC                   eval      #msgid = 'PO13229'
415bAC                   eval      #msgtp = '*DIAG  '
415bAC                   movea     errmsg        $md(1)
415bAC                   exsr      zmpmsg
415bAC                   endsr
416aA*----------------------------------------------------------------
416aA*     PO13230  Item cannot be accepted - Exp Date
416aA*
416aAC     zm3230        begsr
416aAC                   eval      #msgid = 'PO13230'
416aAC                   eval      #msgtp = '*DIAG  '
416aAC                   movea     errmsg        $md(1)
416aAC                   exsr      zmpmsg
416aAC                   endsr
416aA*----------------------------------------------------------------
416aA*     PO13231  Warning: Exp date comes before existing date.
416aA*
416aAC     zm3231        begsr
416aAC                   eval      #msgid = 'PO13231'
416aAC                   eval      #msgtp = '*DIAG  '
416aAC                   movea     errmsg        $md(1)
416aAC                   exsr      zmpmsg
416aAC                   endsr
416aA*----------------------------------------------------------------
416aA*     PO13232  Item cannot be accepted - Calc Exp Date
416aA*
416aAC     zm3232        begsr
416aAC                   eval      #msgid = 'PO13232'
416aAC                   eval      #msgtp = '*DIAG  '
416aAC                   movea     errmsg        $md(1)
416aAC                   exsr      zmpmsg
416aAC                   endsr
416aA*----------------------------------------------------------------
416aA*     PO13233  Warning: Calc exp date comes before existing date.
416aA*
416aAC     zm3233        begsr
416aAC                   eval      #msgid = 'PO13233'
416aAC                   eval      #msgtp = '*DIAG  '
416aAC                   movea     errmsg        $md(1)
416aAC                   exsr      zmpmsg
416aAC                   endsr
416fA*----------------------------------------------------------------
416fA*     PO13234  CW must be zero when Avg = 'Y' for "First time"
416fA*
416fAC     zm3234        begsr
416fAC                   eval      #msgid = 'PO13234'
416fAC                   eval      #msgtp = '*DIAG  '
416fAC                   movea     errmsg        $md(1)
416fAC                   exsr      zmpmsg
416fAC                   endsr
417aA*----------------------------------------------------------------
417aA*     PO13243  Item cannot be accepted. # of days out
417aA*
417aAC     zm3243        begsr
417aAC                   eval      #msgid = 'PO13243'
417aAC                   eval      #msgtp = '*DIAG  '
417aAC                   movea     errmsg        $md(1)
417aAC                   exsr      zmpmsg
417aAC                   endsr
GFCbA*----------------------------------------------------------------
GFCbA*     PO23210  Not enough shelf life remaining.
GFCbA*
GFCbAC     zm23210       begsr
GFCbAC                   eval      #msgid = 'PO23210'
GFCbAC                   eval      #msgtp = '*DIAG  '
GFCbAC                   movea     errmsg        $md(1)
GFCbAC                   exsr      zmpmsg
GFCbAC                   endsr
GFCbA*----------------------------------------------------------------
GFCbA*     PO23211  This is a production date, enter date must be
GFCbA*              date previous to today.
GFCbA*
GFCbAC     zm23211       begsr
GFCbAC                   eval      #msgid = 'PO23211'
GFCbAC                   eval      #msgtp = '*DIAG  '
GFCbAC                   movea     errmsg        $md(1)
GFCbAC                   exsr      zmpmsg
GFCbAC                   endsr
GFCbA*----------------------------------------------------------------
GFCbA*     PO23212  Days exceed Total shelf life.
GFCbA*
GFCbAC     zm23212       begsr
GFCbAC                   eval      #msgid = 'PO23212'
GFCbAC                   eval      #msgtp = '*DIAG  '
GFCbAC                   movea     errmsg        $md(1)
GFCbAC                   exsr      zmpmsg
GFCbAC                   endsr
BIRbA*----------------------------------------------------------------
BIRbA*     PO23215  PO Inuse on Retalix. Rcv cancelled.
BIRbA*
BIRbAC     zm23215       begsr
BIRbAC                   eval      #msgid = 'PO23215'
BIRbAC                   eval      #msgtp = '*DIAG  '
BIRbAC                   movea     errmsg        $md(1)
BIRbAC                   exsr      zmsmsg
BIRbAC                   eval      $pmsg = #msgk
BIRbAC                   endsr
     *----------------------------------------------------------------
     *     TF17201  Warning: Quantity received not equal to ordered.
     *
     C     zm7201        begsr
     C                   eval      #msgid = 'TF17201'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13202  Info message.
     *
     C     zm7202        begsr
     C                   eval      #msgid = 'PO13202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
TMP A*----------------------------------------------------------------
TMP A*     ZM04     Slot record does not exist.
TMP A*
TMP AC     zm04          begsr
TMP AC                   eval      #msgid = 'IT13204'
TMP AC                   eval      #msgtp = '*DIAG  '
TMP AC                   eval      erdisp = w1slot
TMP AC                   movea     errmsg        $md(1)
TMP AC                   exsr      zmpmsg
TMP AC                   endsr
TMP A*----------------------------------------------------------------
TMP A*     ZM05     Slot is occupied with different item.
TMP A*
TMP AC     zm05          begsr
TMP AC                   eval      #msgid = 'PO13221'
TMP AC                   eval      #msgtp = '*DIAG  '
TMP AC                   eval      eritm = slitem
TMP AC                   movea     errmsg        $md(1)
TMP AC                   exsr      zmpmsg
TMP AC                   endsr
TMP A*----------------------------------------------------------------
TMP A*     ZM06     Slot is a zero slot. It must be verified first.
TMP A*
TMP AC     zm06          begsr
TMP AC                   eval      #msgid = 'PO13227'
TMP AC                   eval      #msgtp = '*DIAG  '
TMP AC                   eval      $md = *blanks
TMP AC                   exsr      zmpmsg
TMP AC                   endsr
TMP A*----------------------------------------------------------------
TMP A*   PIR9905  Cursor not in correct position for lookup.
TMP A*
TMP AC     zm9905        begsr
TMP AC                   eval      #msgid = 'PIR9905'
TMP AC                   eval      #msgtp = '*DIAG  '
TMP AC                   eval      $md = *blanks
TMP AC                   exsr      zmpmsg
TMP AC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
500c *   OAOVR = Manufacture date override, Caluclated exp date
500c *           comes before existing overflow exp date. (PO13233)
500c *   OBOVR = Manufacture date override, Manufacture date entered
500c *           is greater than today.(PIR1010)
500c *   OCOVR = Expiration date override, Expiration date is greater
500c *           than allowed # of days out. (PO13243)
500c *   ODOVR = Use by date override, Not enough user/dist days to
500c *           sell before expiration date (PO13229)
500c *   OEOVR = Mfg date override, Not enough user/dist days to
500c *           sell before calculated expiration date (PO13228)
500c *   OFOVR = Expiration date override, Expiration date entered
500c *           comes before existing overflow exp date. (PO13231)
510lA*   DDCODE= Invalid Date returned from the Decipher progrmas
500c *   CWOVR = Weight error override taken.
650lA*   PTIOVR= PTI override taken.
413c *   DTCHK, QTCHK, WTCHK Flags are used to force F20 for each test
650lM*   DTCHK2 DTCHK3, DTCHK4,UPCHK2 PTICHK
SGCaA*   QTCHK1
413c *   Values: Flag = 0 Do check.
413c *           Flag = 1 Check was done, ok.
413c *           Flag = 2 Warning condition.
413c *
     C                   eval      error = *off
650gAc                   exsr      zzrcvpocheck
     *
     *  When adding ....
     *
     C                   if        $pcmd = '*ADD    '
     C                   endif
417lA*  Extract UPC code from entered string.
415cA*
417lMC                   if        w1upcd <> *blanks
415cAC                   eval      $cbcmd = '*UPC    '
417dD*R                   MOVELW1UPC     $CBBAR    P
417dMC                   eval      $cbbar = w1upcd
415cA*
415cAC                   call      'CVTBAR'
415cAC                   parm                    $cbcmd            8
415cAC                   parm                    $cbbar          100
415cAC                   parm                    $cbcod            3 0
415cAC                   parm                    $cbdec            1 0
415cAC                   parm                    $cbdsc           30
415cAC                   parm                    $cbpos            3 0
415cAC                   parm                    $cbtyp            1 0
415cAC                   parm                    $cbv1            11 3
415cAC                   parm                    $cbv2            50
415cAC                   parm                    $cbrtn            8
415cAC                   parm                    $cberm           60
740cAC                   parm      $itven#       $cbven           10 0
740cAC                   parm                    $cvtdata
740cAC                   parm                    $cvtdata2
417lA*
417lAC                   movel     $cbv2         $cstr
417lAC                   call      'ADJUST'
417lAC                   parm      '*RIGHT  '    $ccmd             8
417lAC                   parm                    $cstr            30
417lAC                   eval      w1upc = *blanks
417lAC                   move      $cstr         w1upc
415cAC                   endif
415cA*   Do UPC Check
417dD*R         W1UPC     IFNE *BLANKS                    Begin If
417dMC                   if        w1upcd <> *blanks  and
417lMC                             $pupc = *blanks
417dD*R         SVUPC     IFNE W1UPC
417dMC                   if        svupc <> w1upcd
415cAC                   eval      upchk = *off
417jAC                   eval      upchk2 = *off
415cAC                   endif
415cA*
YHAbAC                   if        client = yhata
CDI A*
CDI AC                             or   client = cdi
CDI AC                             and (client2 = cdijacksonms)
CDI A*
YHAbAC                   if        upchk <> '2'  and
YHAbAC                             ovrrid = *on
YHAbAC                   eval      upchk = *on
YHAbAC                   endif
YHAbAC                   else
415cAC                   if        upchk <> '2'  and
415cAC                             ovrrid = *on  and
417lAC                             $cbrtn <> '*INVALID'
415cAC                   eval      upchk = *on
415cAC                   endif
SVLcA*  Allow invalid UPC codes to be entered.
SVLcAC                   if        client = saval
KHLaAc                             or client = kohl
SVLcAC                   eval      upchk = *on
SVLcAC                   endif
YHAbAC                   endif
415cA*
415cAC                   if        upchk <> '1'
415cAC                   eval      upchk = *on
415cA*
417lA*  MOVED CODE TO EXTRACT UPC CODE FROM ENTERED STRING
415cAC                   select
415cA*
415cAC                   when      $cbrtn = '*OK'
700cAc                   eval      ntype = %trimr($cbdsc)
417lD*R                   MOVEL$CBV2     $CSTR
417lD*R                   CALL 'ADJUST'
417lD*R                   PARM '*RIGHT  '$CCMD   8
417lD*R                   PARM           $CSTR  30
417lD*R                   MOVE *BLANKS   W1UPC
417lD*R                   MOVE $CSTR     W1UPC
415cA*
415cAC                   other
415cAC                   eval      error = *on
415cAC                   eval      *in26 = *on
415cAC                   eval      *in06 = *on
415cAC                   movel     $cberm        errmsg
415cAC                   exsr      zm0105
415cAC                   endsl
415cA*
415cAC     error         cabeq     *on           enderr
415cAC                   endif
415cD*
415cD*   Right adjust UPC code.
415cD*
415cD**                   MOVE *BLANKS   $CSTR
415cD**                   MOVELW1UPC     $CSTR
415cD**                   CALL 'ADJUST'
415cD**                   PARM '*RIGHT  '$CCMD   8
415cD**                   PARM           $CSTR  30
415cD**                   MOVE $CSTR     W1UPC
417lD*   Allow multiple upc for whse/item, must be different vendor.
417lD*   No longer need to check if UPC exists for WHSE/ITEM/UPC
417bD*R         UPCKY     CHAINUPC                 N79
417lD*R         UPCKY2    CHAINUPC2                N79
417lD*R         *IN79     IFEQ *OFF
417lD*R         UPITEM    IFNE $PITEM
417lD*R                   MOVE *ON       ERROR
417lD*R                   MOVE *ON       *IN26
417lD*R                   MOVE *ON       *IN06
417lD*R                   MOVE *BLANKS   ERRMSG
417lD*R                   MOVELDESC,6    ERRMSG
417lD*R                   EXSR ZM02
417lD*R                   ENDIF
417lD*R                   ENDIF
221 AC                   endif
417jA*
417jAC                   if        upchk2 = '0'  and
417jAC                             ovrrid = *on
417jAC                   eval      ovrrid = *off
417jAC                   endif
FKLbAC                   if        client = finkle and
FKLbAC                             upchk2 <> '2'  and
FKLbAC                             ovrrid = *on
FKLbAC                   eval      upchk2 = '0'
FKLbAC                   else
417jAC                   if        upchk2 <> '2'  and
417jAC                             ovrrid = *on
417jAC                   eval      upchk2 = *on
417jAC                   endif
FKLbAC                   endif
417jA*
417jAC                   if        upchk2 <> '1'
417jAC                   eval      upchk2 = *on
     *  ERROR - UPC CODE EXISTS FOR ITEM/VENDOR
417jAC                   if        w1upcd <> *blanks  and
417jAC                             $pupc = *blanks
417jAC     upcky1        chain(n)  upc1                               79
417jAC                   if        not *in79  and
417kAC                             upupc <> w1upc
417jAC                   eval      error = *on
417jAC                   eval      *in26 = *on
417jAC                   eval      *in06 = *on
417jAC                   eval      errmsg = *blanks
417jAC                   exsr      zm21
417jAC                   endif
417jAC                   endif
417jAC     error         cabeq     *on           enderr
417jAC                   endif
     *
     *  Verify normal quantity.
     *
417q C                   if        w1qrc1 = 0  and
417q C                             w1qrc2 = 0  and
417q C                             w1qrc3 = 0
417q C                   eval      error = *on
417q C                   eval      *in21 = *on
417q C                   eval      *in01 = *on
417q C                   eval      errmsg = *blanks
417q C                   movel     desc(1)       erfld
417q C                   movel     '0'           erfrom
417q C                   movel     '99999'       erto
417q C                   exsr      zm0112
417q C                   endif
     *
     C                   if        w1qrc1 < 0  or
     C                             w1qrc1 > 99999
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       erfld
     C                   movel     '0'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
     *
     *  Verify breakdown 1 unit of measure quantity.
     *
     C                   if        w1qrc2 < 0  or
     C                             w1qrc2 > 99999
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(2)       erfld
     C                   movel     '0'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
     *
     *  Verify breakdown 2 unit of measure quantity.
     *
     C                   if        w1qrc3 < 0  or
     C                             w1qrc3 > 99999
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(3)       erfld
     C                   movel     '0'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
409 A*
409 A*  Verify # of Pallets.
409 A*
409 AC                   if        w1plts <= 0  or
417sAC                             w1plts > 999
409 AC                   eval      error = *on
409 AC                   eval      *in34 = *on
409 AC                   eval      *in14 = *on
409 AC                   eval      errmsg = *blanks
409 AC                   movel     desc(7)       erfld
417sDC*                  movel     '0'           erfrom
417sMC                   movel     '1'           erfrom
417sDC*                  movel     '99999'       erto
417sMC                   movel     '999'         erto
409 AC                   exsr      zm0112
409 AC                   endif
650lA * pti check
650lA /free
650lA       // calculate the PTI.
650pD       //if $pbclot <> ' ' and $pgtin <> ' ';
650pM       if $pbclot <> ' ' and $pgtin <> ' ' and *in73 = *off;
650lA         if w1pti = 0;
650lA           error = *on;
650lA           *in37 = *on;
650lA           *in17 = *on;
650lA           errmsg = desc(13);
650lA           exsr zm0110;
650lA         endif;
650lA       endif;
650lA /end-free
710a *  Beginning of Date checking code.
710a *  Date check with Glazier moved to zzzGFCd
710a *  Remove code from zzchk1
GFCeAC                   if        client = glazier
GFCeAC                   exsr      zzzGFCd
GFCeAC     error         cabeq     *on           enderr
GFCeAC                   goto      skpxck
GFCeAC                   endif
417p *
417p *  Verify FIFO (entered) date.
417p *
417p C                   if        not *in89  and
417p C                             w1fifo <> 0
417p C                   eval      $cvcmd = '*MDYEDT '
417p C                   move      w1fifo        $cvd6i
417p C                   call      @cvtdt
417p C                   parm                    $cvtdt
417p C                   if        $cvrtn = '*PGMQ   '
417p C                   eval      error = *on
417p C                   eval      *in29 = *on
417p C                   eval      *in09 = *on
417p C                   eval      #msgk = $cvmsg
417p **                   EXSR ZMQMSG
417p C                   goto      enderr
417p C                   else
417p C                   eval      w1fifo = $cvd6o
417p C                   endif
MJKa C                   else
MJKa C                   if        not *in89  and
MJKa C                             w1fifo = 0 and
MJKa C                             client = mjkellner
MJKa C                   eval      error = *on
MJKa C                   eval      *in29 = *on
MJKa C                   eval      *in09 = *on
MJKa C                   eval      errmsg = *blanks
MJKa C                   exsr      zm1008
MJKa C                   endif
417p C                   endif
     *
     *  Verify expiration date.
     *
214 AC                   if        not *in96  and
214 AC                             w1exdt = 0
214 AC                   eval      error = *on
214 AC                   eval      *in24 = *on
214 AC                   eval      *in04 = *on
214 AC                   eval      errmsg = *blanks
214 AC                   exsr      zm1008
214 AC                   else
417oA*  Moved code here to calculate CKEXDT
417aA*  Verify Expiration date is within parameter (# of days out)     days)
417aA*  Calculate (Today + # days out)  = CHEXDT                       days)
417aA*

417rAC                   call      'CLCDUR2'
417rAC                   parm      '*ADD'        $cdcmd
417rAC                   parm      today         $cddatein
417rAC                   parm      0             $cdtimein
417rAC                   parm      0             $cdyears
417rAC                   parm      0             $cdmonths
417rAC                   parm      imoday        $cddays
417rAC                   parm      0             $cdhours
417rAC                   parm      0             $cdminutes
417rAC                   parm      0             $cdseconds
417rAC     ckexdt        parm      0             $cddateout
417rAC                   parm      0             $cdtimeout

     C                   if        w1exdt <> 0
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1exdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      #msgk = $cvmsg
     **                   EXSR ZMQMSG
     C                   goto      enderr
     C                   else
     C                   eval      w1exdt = $cvd6o
214 AC                   eval      $cvcmd = '*MDYCMD '
214 AC                   call      @cvtdt
214 AC                   parm                    $cvtdt
214 AC                   move      $cvd8o        expd
510cAC                   move      $cvd8o        woexdt
DRYhAc                   Select
DRYhAc                   when      client = Dairyland
ADFaAc                   when      client = AandDFoods
DRYhAc                   other
    A*  check expiration date enter to make sure it is greater than today.
214 AC                   if        expd <= today
214 AC                   eval      error = *on
214 AC                   eval      *in24 = *on
214 AC                   eval      *in04 = *on
214 AC                   eval      errmsg = *blanks
214 AC                   exsr      zm1009
650hAC                   goto      enderr
214 AC                   endif
DRYhAc                   endsl
417oA*  Code to calculate CKEXDT was moved from here to above.
415bA*
415bA*
415bA*  Verify Use by date.                                            days)
415bA*  Calculate (Today + Dist Days)  = DATE1                         days)
415bA*  Calculate  (Use By - User Days) = DATE2                        days)
415bA*

417rAC                   call      'CLCDUR2'
417rAC                   parm      '*ADD'        $cdcmd
417rAC                   parm      today         $cddatein
417rAC                   parm      0             $cdtimein
417rAC                   parm      0             $cdyears
417rAC                   parm      0             $cdmonths
417rAC                   parm      imdday        $cddays
417rAC                   parm      0             $cdhours
417rAC                   parm      0             $cdminutes
417rAC                   parm      0             $cdseconds
417rAC     date1         parm      0             $cddateout
417rAC                   parm      0             $cdtimeout

520aAC                   if        immflg = 'Y'
520aAC                   eval      date2 = expd
520aAC                   else
417rAC                   call      'CLCDUR2'
417rAC                   parm      '*SUB'        $cdcmd
417rAC                   parm      expd          $cddatein
417rAC                   parm      0             $cdtimein
417rAC                   parm      0             $cdyears
417rAC                   parm      0             $cdmonths
417rAC                   parm      imuday        $cddays
417rAC                   parm      0             $cdhours
417rAC                   parm      0             $cdminutes
417rAC                   parm      0             $cdseconds
417rAC     date2         parm      0             $cddateout
417rAC                   parm      0             $cdtimeout
520aAC                   endif

417rMC                   move      date2         $cvd8i
417rMC                   eval      $cvcmd = '*CMDMDY '
415bAC                   call      @cvtdt
415bAC                   parm                    $cvtdt
415bAC                   move      $cvd6o        date2o
415bA*
     C                   endif
     C                   endif
     C                   endif
417eA***
417eA*  Verify Expire date and # of days out                           days)
417eA*  Allow warning and override                                     days)
417eAC                   if        expd <> 0
417eAC                   if        svexdt <> w1exdt
417eAC                   eval      dtchk = *off
510eMC                   eval      ocovr = *off
510eDC*                  eval      odovr = *off
417eAC                   endif
417e *
417eAC                   if        dtchk = '2'  and
417eAC                             ovrrid = *on
510eMC                   eval      ocovr = *on
510eDC*                  eval      odovr = *on
417eAC                   eval      dtchk = *on
417eAC                   endif
417e *
417eMC                   if        dtchk <> '1'
417eAC                   eval      dtchk = *on
417eA*
417eA*   If EXPD > /CKEXDT - Reject.
417eA*
417eAC                   if        expd > ckexdt
740bAC                             and $immflg <> 'Y'
417eAC                   eval      error = *on
417eAC                   eval      dtchk = '2'
417eAC                   eval      warn = *on
417eAC                   eval      *in24 = *on
417eAC                   eval      *in04 = *on
417eAC                   eval      errmsg = *blanks
417eAC                   eval      erused = w1exdt
417eAC                   eval      erdisd = imoday
417eAC                   exsr      zm3243
417eAC                   endif
417e *
417eAC     error         cabeq     *on           enderr
417e *
417eAC                   endif
510aDC***                eval      dtchk = *off
417eMC                   eval      expd = date2
417eAC                   endif
     *
415bA*
415bA*  Verify Use by date.                                            days)
415bAC                   if        expd <> 0
415bAC                   if        svexdt <> w1exdt
500dMC                   eval      dtchk3 = *off
500dDC*                  eval      dtchk = *off
415bAC                   endif
415b *
415bAC                   if        dtchk3 = '2'  and
415bAC                             ovrrid = *on
500cAC                   eval      odovr = *on
415bAC                   eval      dtchk3 = *on
415bAC                   endif
415b *
415bMC                   if        dtchk3 <> '1'
415bAC                   eval      dtchk3 = *on
415bA*
415bA*   If DATE2 <= Date1 - Reject.
415bA*
415bAC                   if        date2 <= date1
415bAC                   eval      error = *on
415bAC                   eval      dtchk3 = '2'
415bAC                   eval      warn = *on
415bAC                   eval      *in24 = *on
415bAC                   eval      *in04 = *on
415bAC                   eval      errmsg = *blanks
415bAC                   eval      erused = w1exdt
415bAC                   eval      erdisd = imdday
415bAC                   eval      erusrd = imuday
415bAC                   eval      ersell = date2o
415bAC                   exsr      zm3229
415bAC                   endif
415b *
415bAC     error         cabeq     *on           enderr
415b *
415bAC                   endif
500dDC*                  eval      dtchk = *off
415bMC                   eval      expd = date2
415bAC                   endif
     *
     *
413cA*R         DTCHK     IFEQ '1'
500dA*  Change to use DTCHK4 for override                                  )
413cAC                   if        svmfdt <> w1mfdt
500dMC                   eval      dtchk4 = *off
500dDC*                  eval      dtchk = *off
413cAC                   endif
413c *
500dDC*                  if        dtchk = '2'  and
500dMC                   if        dtchk4 = '2'  and
413cAC                             ovrrid = *on
510eAC                   if        mfgd > today
500cAC                   eval      obovr = *on
510eAC                   endif
YHAcAC                   if        client = yhata  and
YHAcAC                             mfgd = today
YHAcAC                   eval      obovr = *on
YHAcAC                   endif
510eAC                   if        today > ltstd8
510eAC                   eval      oeovr = *on
510eAC                   endif
500dAC                   eval      dtchk4 = *on
413cAC                   endif
413c *
413 D*R         OVRRID    IFEQ *OFF
500dMC                   if        dtchk4 <> '1'
500dMC                   eval      dtchk4 = *on
     *
409 A*
409 A*  Verify manufacturing date.
409 A*
409 AC                   select
409 AC                   when      immflg = 'Y'
409 AC                   if        w1mfdt = 0
409 AC                   eval      error = *on
500dDC*                  eval      dtchk = *off
500dMC                   eval      dtchk4 = *off
500cAC                   eval      obovr = *off
409 AC                   eval      *in27 = *on
409 AC                   eval      *in07 = *on
409 AC                   eval      errmsg = *blanks
409 AC                   exsr      zm1008
409 AC                   else
409 AC                   if        w1mfdt <> 0
409 AC                   eval      $cvcmd = '*MDYEDT '
409 AC                   move      w1mfdt        $cvd6i
409 AC                   call      @cvtdt
409 AC                   parm                    $cvtdt
409 AC                   if        $cvrtn = '*PGMQ   '
409 AC                   eval      error = *on
500dDC*                  eval      dtchk = *off
500dMC                   eval      dtchk4 = *off
500cAC                   eval      obovr = *off
409 AC                   eval      *in27 = *on
409 AC                   eval      *in07 = *on
409 AC                   eval      #msgk = $cvmsg
409 A**                   EXSR ZMQMSG
409 AC                   goto      enderr
409 AC                   else
409 AC                   eval      w1mfdt = $cvd6o
409 AC                   eval      $cvcmd = '*MDYCMD '
409 AC                   call      @cvtdt
409 AC                   parm                    $cvtdt
409 AC                   move      $cvd8o        mfgd
409 AC                   if        mfgd > today
409 AC                   eval      error = *on
500dDC*                  eval      dtchk = *off
500dMC                   eval      dtchk4 = *off
500cAC                   eval      obovr = *off
409 AC                   eval      *in27 = *on
409 AC                   eval      *in07 = *on
409 AC                   eval      errmsg = *blanks
409 AC                   exsr      zm1010
409 AC                   endif
YHAcAC                   if        client = yhata  and
YHAcAC                             mfgd = today
YHAcAC                   eval      error = *on
YHAcAC                   eval      dtchk4 = '2'
YHAcAC                   eval      obovr = *off
YHAcAC                   eval      *in27 = *on
YHAcAC                   eval      *in07 = *on
YHAcAC                   eval      errmsg = *blanks
YHAcAC                   exsr      zm1010
YHAcAC                   endif
409 AC                   endif
409 AC                   endif
409 AC                   endif
     *
415CAC     error         cabeq     *on           enderr
409 A*
409 A*  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
409 A*

417rAC                   eval      $cvcmd = '*MDYCMD '
417rAC                   move      w1mfdt        $cvd6i
417rAC                   call      @cvtdt
417rAC                   parm                    $cvtdt
417rAC                   move      $cvd8o        expd

417rAC                   call      'CLCDUR2'
417rAC                   parm      '*ADD'        $cdcmd
417rAC                   parm      expd          $cddatein
417rAC                   parm      0             $cdtimein
417rAC                   parm      0             $cdyears
417rAC                   parm      0             $cdmonths
417rAC                   parm      immday        $cddays
417rAC                   parm      0             $cdhours
417rAC                   parm      0             $cdminutes
417rAC                   parm      0             $cdseconds
417rAC                   parm      0             $cddateout
417rAC                   parm      0             $cdtimeout

417rAC                   call      'CLCDUR2'
417rAC                   parm      '*SUB'        $cdcmd
417rAC                   parm      $cddateout    $cddatein
417rAC                   parm      0             $cdtimein
417rAC                   parm      0             $cdyears
417rAC                   parm      0             $cdmonths
417rAC                   parm      imuday        $cddays
417rAC                   parm      0             $cdhours
417rAC                   parm      0             $cdminutes
417rAC                   parm      0             $cdseconds
417rAC     expd          parm      0             $cddateout
417rAC                   parm      0             $cdtimeout

417rAC                   eval      $cvcmd = '*CMDMDY '
417rAC                   move      expd          $cvd8i
417rAC                   call      @cvtdt
417rAC                   parm                    $cvtdt
417rAC                   move      $cvd6o        w1exdt

409 A*
409 A*  Find the latest acceptable date.: Exp date -Dist days
409 A*

417rAC                   eval      $cvcmd = '*MDYCMD '
417rAC                   move      w1exdt        $cvd6i
417rAC                   call      @cvtdt
417rAC                   parm                    $cvtdt
417rAC                   move      $cvd8o        ltstd8

417rAC                   call      'CLCDUR2'
417rAC                   parm      '*SUB'        $cdcmd
417rAC                   parm      ltstd8        $cddatein
417rAC                   parm      0             $cdtimein
417rAC                   parm      0             $cdyears
417rAC                   parm      0             $cdmonths
417rAC                   parm      imdday        $cddays
417rAC                   parm      0             $cdhours
417rAC                   parm      0             $cdminutes
417rAC                   parm      0             $cdseconds
417rAC     ltstd8        parm      0             $cddateout
417rAC                   parm      0             $cdtimeout

417rAC                   eval      $cvcmd = '*CMDMDY '
417rAC                   move      ltstd8        $cvd8i
417rAC                   call      @cvtdt
417rAC                   parm                    $cvtdt
417rAC                   move      $cvd6o        ltstd6

409 A*
409 A*   If Today's date is > Latest acceptable date - Reject.
409 A*
GFCbAC                   select
GFCbA*   For Glazier mfg date < today - dist days
409 AC                   when      today > ltstd8
409 AC                   eval      error = *on
510eAC                   eval      oeovr = *off
500dDC*                  eval      dtchk = '2'
500dMC                   eval      dtchk4 = '2'
413c C                   eval      warn = *on
416cD**                   MOVE *ON       *IN28
416cD**                   MOVE *ON       *IN08
416cMC                   eval      *in27 = *on
416cMC                   eval      *in07 = *on
409 AC                   eval      errmsg = *blanks
409 AC*                  eval      ermday = immday
409 AC*                  eval      ermfdt = w1mfdt
409 AC*                  eval      erexdt = w1exdt
409 AC*                  eval      erltst = ltstd6
409 AC*                  eval      erdday = imdday
409 AC*                  eval      eruday = imuday
GFCbAC                   z-add     immday        ermday
GFCbAC                   z-add     w1mfdt        ermfdt
GFCbAC                   z-add     w1exdt        erexdt
GFCbAC                   z-add     ltstd6        erltst
GFCbAC                   z-add     imdday        erdday
GFCbAC                   z-add     imuday        eruday
409 DC***                exsr      zm3228
YHAfAc                   Select
YHAfAc                   when      client = yhata
YhafAC                   exsr      zm3228
YHAfAC                   other
650hMC                   exsr      zm23210
YHAfAC                   endsl
416iMC                   eval      w1exdt = 0
417fAC                   eval      expd = *zeros
GFCbMC                   endsl
409 AC                   endsl
     *
413cAC     error         cabeq     *on           enderr
412 AC                   endif
416aA*
416aA*   Check for earlier expiration dates (optional)                 days)
416aA*
416aA*     See if we can skip the check.                               days)
416aA*
730aDC**                 if        w1exdt = 0  or
730aMC                   if        itflgd = 'N'  or
416aAC                             svexck <> '2'  and
416aAC                             svexck <> '3'
416aAC                   goto      skpxck
416aAC                   endif
416aA*
416aA*     Set warning check flag.                                     days)
416aA*
416aAC                   if        svexdt <> w1exdt
416aAC                   eval      dtchk2 = *off
500cMC                   eval      oaovr = *off
510eAC                   eval      ofovr = *off
500cDC*                  eval      cwovr = *off
416aAC                   endif
416aA*
416aAC                   if        dtchk2 = '2'  and
416aAC                             ovrrid = *on
510eDC*                  eval      odovr = *on
510eAC                   if        immflg = 'Y'
510eMC                   eval      oaovr = *on
510eAC                   else
510eAC                   eval      ofovr = *on
510eAC                   endif
416aAC                   eval      dtchk2 = *on
416aAC                   goto      skpxck
 16aAC                   endif
416aA*
416aAC     dtchk2        cabeq     '1'           skpxck
416aA*
416aA*     Do actual check                                             days)
416aA*
416aAC                   eval      dtchk2 = *on
416aA*
416aA*       Get date range of overflow slots.
416aA*
416aAC                   call      'GETEXPD'
416aAC                   parm      $pwhse        $swhse            3 0
416aAC                   parm                    #sitem
416aAC                   parm                    $dfrom            8 0
416aAC                   parm                    $dto              8 0
416aA*
416aA*       If date comes after end of range
416aA*         Then date can be recevied so skip the rest of the check
416aA*
416aAC                   if        expd >= $dto
416aAC                   goto      skpxck
416aAC                   endif
416aA*
416aA*       Otherwise, see if it's an error or warning.
416aA*
416aA*         '1' = Allow Let it go through
416aA*         '2' = Error (not allowed)
510eA*         '3' = Warning.
416aA*
416aAC                   eval      error = *on
416aAC                   if        immflg = 'Y'
416aAC                   eval      *in27 = *on
416aAC                   eval      *in07 = *on
416aAC                   else
416aAC                   eval      *in24 = *on
416aAC                   eval      *in04 = *on
416aAC                   endif
416aAC                   eval      errmsg = *blanks
416aAC                   eval      erentd = expd
416aAC                   eval      ertod = $dto
416aAC                   select
416aAC                   when      svexck = '2'
416aAC                   eval      dtchk2 = *off
416aAC                   if        immflg = 'Y'
416aAC                   exsr      zm3232
416aAC                   else
416aAC                   exsr      zm3230
416aAC                   endif
416aAC                   when      svexck = '3'
416aAC                   eval      dtchk2 = '2'
416aAC                   eval      warn = *on
510eDC*                  eval      oaovr = *on
500cDC*                  eval      cwovr = *on
416aAC                   if        immflg = 'Y'
510eAC                   eval      oaovr = *on
416aAC                   exsr      zm3233
416aAC                   else
510eAC                   eval      ofovr = *on
416aAC                   exsr      zm3231
416aAC                   endif
416aAC                   endsl
416aA*
416aAC     error         cabeq     *on           enderr
710aA*  End of date checking code.
416aA*
416aAC     skpxck        tag
650lA * pti check
650lA /free
650lA   // calculate the PTI.
650pD   //if $pbclot <> ' ' and $pgtin <> ' ';
650pM   if $pbclot <> ' ' and $pgtin <> ' ' and *in73 = *off;
650lA     pplot  = %subst($pbclot: 1 : 20);
650lA     calcpti ($pgtin: pplot: $pbcProdD: pppti);
650lA     if svpti <> w1pti;
650lA       ptichk = *off;
650la     endif;
650la     if ptichk = '2' and
650la        ovrrid = *on;
650la        ptiovr = *on;
650la        ptichk = *on;
650la     endif;
650la     if ptichk <> '1';
650la       ptichk = *on;
650lA       if w1pti <> pppti
650lA         and ptiovr <> '1';
650lA         // recalc pti without production date
650lA         calcpti ($pgtin: pplot: ptinodate: pppti);
650lA         if w1pti <> pppti;
650lA           error = *on;
650lA           *in37 = *on;
650lA           *in17 = *on;
650la           ptichk = '2';
650lA           warn = *on;
650lA           exsr zm3203;
650lA         endif;
650lA       endif;
650lA     endif;
650lA   endif;
650lA /end-free
650lAc     error         cabeq     *on           enderr
     *
TMP D*
TMP D*   Verify weight.
TMP D*
TMP D*R         *IN95     IFEQ *OFF
TMP D*R         W1DWGT    ANDEQ0
TMP D*R                   MOVE *ON       ERROR
TMP D*R                   MOVE *ON       *IN25
TMP D*R                   MOVE *ON       *IN05
TMP D*R                   MOVE *BLANKS   ERRMSG
TMP D*R                   MOVELDESC,4    ERRMSG
TMP D*R                   EXSR ZM0110
TMP D*R                   ENDIF
640dA*
640dA*  Always error if catchweight is negative
640dA*
640dAC                   if        w1dwgt < 0
640dAC                   eval      error = *on
640dAC                   eval      *in25 = *on
640dAC                   eval      *in05 = *on
640dAC                   eval      errmsg = 'Negative catchweight entered. '
640dAC                             + 'Catchweight must be greater than zero.'
640dAC                   exsr      zm9999
640dAC                   goto      enderr
640dAC                   endif
416dA*
416dA*  See if we need to verify catch weight.
416dA*
416dAC     vrfycw        cabeq     *off          skipcw
416dA*
416dA*  CW can't be zero if forced entry is selected.
416dA*
416fA*    One exception for 'First time only' entry with Avg = 'Y'
416fA*
416dAC                   if        svcwfr = 'Y'  and
416dAC                             w1dwgt = 0
416fAC                   if        svcwen = '1'  or
416fAC                             svcwen = '2'  and
416fAC                             w1avg <> 'Y'
416dAC                   eval      error = *on
416dAC                   eval      *in25 = *on
416dAC                   eval      *in05 = *on
416dAC                   eval      errmsg = *blanks
416dAC                   movel     desc(4)       errmsg
416dAC                   exsr      zm0110
416fAC                   endif
416dAC                   endif
219 A*
219 A*  Verify Catch weight average  (Y/N).
219 A*
219 AC                   if        w1avg <> 'Y'  and
219 AC                             w1avg <> 'N'
219 AC                   eval      error = *on
219 AC                   eval      *in32 = *on
219 AC                   eval      *in12 = *on
219 AC                   eval      errmsg = *blanks
219 AC                   movel     desc(5)       errmsg
219 AC                   exsr      zm1005
219 AC                   endif
416fA*
416fA*  When 'First time only' entry with Avg = 'Y'
416fA*    Then catch weight must be zero.
416fA*
416fAC                   if        svcwen = '2'  and
416fAC                             w1avg = 'Y'  and
416fAC                             w1dwgt <> 0
416fAC                   eval      error = *on
416fAC                   eval      *in25 = *on
416fAC                   eval      *in05 = *on
416fAC                   eval      errmsg = *blanks
416fAC                   exsr      zm3234
416fAC                   endif
     *
219 A*
219 A*  When more than one qty is entered, catch weight average must be N
219 A*
416fA*    One exception for 'First time only' entry with Avg = 'Y'
416fA*
219 AC                   select
219 AC                   when      w1qrc1 <> 0  and
219 AC                             w1avg = 'Y'  and
416fAC                             svcwen <> '2'
219 AC                   if        w1qrc2 <> 0  or
219 AC                             w1qrc3 <> 0
219 AC                   eval      error = *on
219 AC                   eval      *in32 = *on
219 AC                   eval      *in12 = *on
219 AC                   eval      errmsg = *blanks
219 AC                   movel     desc(5)       errmsg
219 AC                   exsr      zm2101
219 AC                   endif
     *
219 AC                   when      w1qrc2 <> 0  and
219 AC                             w1avg = 'Y'  and
416fAC                             svcwen <> '2'
219 AC                   if        w1qrc1 <> 0  or
219 AC                             w1qrc3 <> 0
219 AC                   eval      error = *on
219 AC                   eval      *in32 = *on
219 AC                   eval      *in12 = *on
219 AC                   eval      errmsg = *blanks
219 AC                   movel     desc(5)       errmsg
219 AC                   exsr      zm2101
219 AC                   endif
     *
219 AC                   when      w1qrc3 <> 0  and
219 AC                             w1avg = 'Y'  and
416fAC                             svcwen <> '2'
219 AC                   if        w1qrc1 <> 0  or
219 AC                             w1qrc2 <> 0
219 AC                   eval      error = *on
219 AC                   eval      *in32 = *on
219 AC                   eval      *in12 = *on
219 AC                   eval      errmsg = *blanks
219 AC                   movel     desc(5)       errmsg
219 AC                   exsr      zm2101
219 AC                   endif
     *
219 AC                   endsl
     *
416fA*
416fA*  Skip catch weight variance check when ...
416fA*    "First time only" entry
416fA*
416fAC                   if        svcwen = '2'
520dA*      Skip variance check once qty has been received for item.
520dAC                             and (pdqrc1 > 0
520dAC                             or   pdqrc2 > 0
520dAC                             or   pdqrc3 > 0)
520dAC
413cAC                   goto      skipcw
416fAC                   endif
413b *
     *
     *  Catch weight variance check.
413cA*R         WTCHK     IFEQ '1'
413cAC                   if        svdwgt <> w1dwgt
413cAC                   eval      wtchk = *off
413cAC                   endif
413c *
DRYaAC                   select
DRYaAC                   when      client = Dairyland
DRYaAC                   if        wtchk = '2'  and
DRYaAC                             ovrrid = *on
DRYaAC***                eval      wtchk = '2'
650jAc                   eval      cwovr = *on
DRYbAC                   eval      wtchk = *on
DRYaAC                   endif
DRYaAC                   other
413cAC                   if        wtchk = '2'  and
413cAC                             ovrrid = *on
650jAc                   eval      cwovr = *on
413cAC                   eval      wtchk = *on
413cAC                   endif
DRYaAC                   endsl
413c *
413cMC                   if        wtchk <> '1'
413cAC                   eval      wtchk = *on
413bA*   If catch weight >0,
413bA*     Calculate total expected catch weight,
413bA*     Calculate low/high ranges.
413bAC                   if        w1dwgt <> 0
413bAC                   eval      lwvar = 0
413bAC                   eval      hivar = 0
413bAC                   eval      lwrng = 0
413bAC                   eval      hirng = 0
413bAC                   eval      exwgt = 0
413bAC                   eval      ilvar = 0
413bAC                   eval      ihvar = 0
413bAC                   eval      ilrng = 0
413bAC                   eval      ihrng = 0
DRYfAC                   eval      hostcw0 = 0
DRYfAC                   eval      hostcw2dec = 0
413bd**         LBQPCK    MULT LBUWGT    EXWGT
413b *
413bAC                   if        w1avg = 'Y'
413fAC                   eval      exwgt = itswgt
640bDC**                 eval      wotcw = w1dwgt
640bMC                   eval      wotcw = cnvwgt
413bAC                   else
416dAC                   if        svcwen = '2'
750aA /free
750aA   exwgt = pdqor1 * itswgt;
750aA   if pdqor2 > 0 and itumq2 > 0;
750aA     exwgt = exwgt + (pdqor2 * (itswgt /itumq2));
750aA   endif;
750aA   if pdqor3 > 0 and itumq3 > 0;
750aA     exwgt = exwgt + (pdqor3 * (itswgt /itumq3));
750aA   endif;
750aA /end-free
750aDC*    pdqor1        mult      itswgt        exwgt

DRYcA* If specific client, use imported c/w value for variance checking if
DRYcA* it's numeric, otherwise, use standard comparison tests.

DRYfAC                   eval      hostUnitWgt  = 0
DRYfAC                   eval      rcvUnitWgt  = 0

DRYcAC                   select
DRYcAC                   when      client = Dairyland
DRYcAC                   eval      hostcwa = %subst(pdmms1:9:7)
DRYcAC     digits        check     hostcwa                                68
DRYcAC                   if        *in68 = *off
DRYcAC                   eval      hostcw0 = %dec(%subst(pdmms1:9:7):7:0)
DRYfMC                   move      hostcw0       hostcw2dec

DRYfAC                   eval      qtyord  = 0
DRYfAC                   eval      qtyord1 = 0
DRYfAC                   eval      qtyord2 = 0
DRYfAC                   eval      qtyord3 = 0

DRYfAC                   if        pdqor1 > 0
DRYfAC                   eval      qtyord1 = pdqor1
DRYfAC                   if        $itumq2 > 0
DRYfAC                   eval      qtyord1 = qtyord1 * $itumq2
DRYfAC                   endif
DRYfAC                   if        $itumq3 > 0
DRYfAC                   eval      qtyord1 = qtyord1 * $itumq3
DRYfAC                   endif
DRYfAC                   endif

DRYfAC                   if        pdqor2 > 0
DRYfAC                   eval      qtyord2 = pdqor2
DRYfAC                   if        $itumq3 > 0
DRYfAC                   eval      qtyord2 = qtyord2 * $itumq3
DRYfAC                   endif
DRYfAC                   endif

DRYfAC                   if        pdqor3 > 0
DRYfAC                   eval      qtyord3 = pdqor3
DRYfAC                   endif

DRYfAC                   eval      qtyord = qtyord1 + qtyord2 + qtyord3

DRYfAC                   eval      exwgt = 0
DRYfAC                   eval      qtyrcv = 0
DRYfAC                   eval      qtyrcv1 = 0
DRYfAC                   eval      qtyrcv2 = 0
DRYfAC                   eval      qtyrcv3 = 0

DRYfAC                   if        w1qrc1 > 0
DRYfAC                   eval      qtyrcv1 = w1qrc1
DRYfAC                   if        $itumq2 > 0
DRYfAC                   eval      qtyrcv1 = qtyrcv1 * $itumq2
DRYfAC                   endif
DRYfAC                   if        $itumq3 > 0
DRYfAC                   eval      qtyrcv1 = qtyrcv1 * $itumq3
DRYfAC                   endif
DRYfAC                   endif

DRYfAC                   if        w1qrc2 > 0
DRYfAC                   eval      qtyrcv2 = w1qrc2
DRYfAC                   if        $itumq3 > 0
DRYfAC                   eval      qtyrcv2 = qtyrcv2 * $itumq3
DRYfAC                   endif
DRYfAC                   endif

DRYfAC                   if        w1qrc3 > 0
DRYfAC                   eval      qtyrcv3 = w1qrc3
DRYfAC                   endif

DRYfAC                   eval      qtyrcv = qtyrcv1 + qtyrcv2 + qtyrcv3

DRYfAC                   eval      hostUnitWgt = hostcw2dec / qtyord
700bDC*                  eval      rcvUnitWgt = w1dwgt / qtyrcv
700bMC                   eval      rcvUnitWgt = cnvwgt / qtyrcv
DRYfAC                   eval      wgtDiff = hostUnitWgt - rcvUnitWgt
DRYfAC                   eval      caltol1 = %abs(wgtDiff) / hostUnitWgt

DRYfAC                   if           pdqor2 > 0 or pdqor3 > 0
DRYfAC                             or w1qrc2 > 0 or w1qrc3 > 0
DRYfAC                   eval      qtyDiff  = qtyord - qtyrcv
DRYfAC                   eval      caltol2  = %abs(qtyDiff) / qtyord
DRYfAC                   endif

DRYcAC                   else
DRYcAC     w1qrc1        mult      itswgt        exwgt
DRYcAC                   endif
DRYcAC                   endsl

416dAC                   else
750aA /free
750aA   exwgt = w1qrc1 * itswgt;
750aA   if w1qrc2 > 0 and itumq2 > 0;
750aA     exwgt = exwgt + (w1qrc2 * (itswgt /itumq2));
750aA   endif;
750aA   if w1qrc3 > 0 and itumq3 > 0;
750aA     exwgt = exwgt + (w1qrc3 * (itswgt /itumq3));
750aA   endif;
750aA /end-free
750aDC*    w1qrc1        mult      itswgt        exwgt
416dAC                   endif
640bDC**                 eval      wotcw = w1dwgt
640bMC                   eval      wotcw = cnvwgt
413bAC                   endif
413b *
413b **   Iniz. flag used to skip variance check if = *ON.
413b C                   eval      lvskp = *off
413b C                   eval      hvskp = *off
650oA*
650oA**   Iniz. fields used to hold low/high variance.
650oAC                   eval      prg1c = 0
650oAC                   eval      prg2c = 0
413b **   Use item variance % if it exists
413b C     imkey         chain     itemmsc                            79
413b C                   if        not *in79
413b *
413b C                   if        imrg1c <> 0
413b C     imrg1c        div       100           prg1c
413b C                   if        imrg1c = 99
413b C                   eval      lvskp = *on
413b C                   endif
413b C                   endif
413b *
413b C                   if        imrg2c <> 0
413b C     imrg2c        div       100           prg2c
413b C                   if        imrg2c = 99
413b C                   eval      hvskp = *on
413b C                   endif
413b C                   endif
413b *
413b C                   endif
     *
413b C                   if        prg1c = 0
413bAC     oprg1c        div       100           prg1c
413b C                   endif
413b C                   if        prg2c = 0
413bAC     oprg2c        div       100           prg2c
413b C                   endif
DRYfA*
DRYfA*     Don't do following extended weight calcs if you're using
DRYfA*     Dairyland's imported c/w method for comparing wgt tolerance.
DRYfAC                   select
DRYfAC                   when      hostcw2dec = 0
413bA*
413bMC                   if        prg1c > 0
413bAC     exwgt         mult      prg1c         lwvar
413bAC                   eval      ilvar = itswgt * prg1c
413bAC                   endif
413bAC                   eval      lwrng = exwgt - lwvar
413bAC                   eval      ilrng = itswgt - ilvar
413bMC                   if        prg2c > 0
413bAC     exwgt         mult      prg2c         hivar
413bAC                   eval      ihvar = itswgt * prg2c
413bAC                   endif
413bAC     exwgt         add       hivar         hirng
413bAC     itswgt        add       ihvar         ihrng
413bA*
DRYfAC                   endsl
413bAC                   endif
413b *
413bA*     Check CW variance if CW > 0
640dDC**                 if        w1dwgt <> 0
700bDC*                  if        w1dwgt > 0
700bMC                   if        cnvwgt > 0
DRYfAC                   if        hostcw2dec > 0
DRYfA*     Use Dairyland's tests for comparing wgt and qty tolerances.
DRYfAC                   exsr      zzchkt1
DRYfAC                   else
413bAC                   exsr      zzchkt
DRYfAC                   endif
413bAC                   endif
413cAC     error         cabeq     *on           enderr
413cAC                   endif
416dA*
416dAC     skipcw        tag
413b *
TMP A*
TMP A*    Make sure slot is valid.
TMP A*
TMP AC                   if        w1slot <> *blanks
TMP AC     slkey         chain(n)  s2rec                              79
TMP A*
TMP A*      Slot doesn't exist.
TMP A*
TMP AC                   if        *in79
TMP AC                   eval      error = *on
TMP AC                   eval      *in33 = *on
TMP AC                   eval      *in13 = *on
TMP AC                   exsr      zm04
413cD*R                   GOTO ENDCK1
413cMC                   goto      enderr
TMP AC                   endif
TMP A*
TMP A*      Slot occupied by different item.
TMP A*
TMP AC                   if        slstat <> 'Z'  and
TMP AC                             slitem <> ' '  and
TMP AC                             slitem <> $pitem
TMP AC                   eval      error = *on
TMP AC                   eval      *in33 = *on
TMP AC                   eval      *in13 = *on
TMP AC                   exsr      zm05
413cD*R                   GOTO ENDCK1
413cMC                   goto      enderr
TMP AC                   endif
TMP A*
TMP A*      Slot is a zero slot.
TMP A*
TMP AC                   if        slstat = 'Z'
TMP AC                   eval      error = *on
TMP AC                   eval      *in33 = *on
TMP AC                   eval      *in13 = *on
TMP AC                   exsr      zm06
413cD*R                   GOTO ENDCK1
413cMC                   goto      enderr
TMP AC                   endif
TMP AC                   endif
     *
SGCbAC                   if        client = sgc
SGCaAC*  Error if pallet qty > tie/hi qty.
SGCaAC                   z-add     0             maxqty
SGCaAC     imtie         mult      imhigh        maxqty
SGCaAC                   if        w1qrc1 > 0
SGCaAC     w1qrc1        div       w1plts        ckqrc1
SGCaAC                   endif
SGCaAC                   if        w1qrc2 > 0
SGCaAC     w1qrc2        div       w1plts        ckqrc1
SGCaAC                   endif
SGCaAC                   if        svckq1 <> ckqrc1
SGCaAC                   eval      qtchk1 = *off
SGCaAC                   endif
SGCaA*
SGCaAC                   if        qtchk1 = '2'  and
SGCaAC                             ovrrid = *on
SGCaAC                   eval      qtchk1 = *on
SGCaAC                   endif
SGCaA*
SGCaAC                   if        qtchk1 <> '1'
SGCaAC                   eval      qtchk1 = *on
SGCaAC                   if        ckqrc1 > maxqty
SGCbAC                             and maxqty > 0
SGCaAC                   eval      qtchk1 = '2'
SGCaAC                   eval      warn = *on
SGCaAC                   eval      error = *on
SGCaAC                   eval      *in21 = *on
SGCaAC                   eval      *in01 = *on
SGCaAC                   eval      errmsg = *blanks
SGCbDC*                  movel     desc(9)       erfld
SGCbMC                   movel     desc(10)      erfld
SGCaAC                   movel     '1'           erfrom
SGCaAC                   move      maxqty        erto
SGCaAC                   exsr      zm0112
SGCaAC                   endif
SGCaAC     error         cabeq     *on           enderr
SGCaAC                   endif
SGCbAC                   endif
MJKb *
MJKb *  Lot Code required for Lot code item.
MJKb *
MJKbAC                   select
MJKbAC                   when      client = mjkellner
MJKbAC                   if        *in88 = *off and
MJKbAC                             W1lotc = *blanks
MJKbAC                   eval      error = *on
MJKbAC                   eval      *in28 = *on
MJKbAC                   eval      *in08 = *on
MJKbAC                   eval      errmsg = *blanks
MJKbAC                   eval      errmsg = 'Lot code required'
MJKbAC                   exsr      zm0105
MJKbAC                   endif
MJKbAC                   endsl
     *
     *  Warning:
     *
     C     w1qrc1        add       pdqrc1        svqrc1
     C     w1qrc2        add       pdqrc2        svqrc2
     C     w1qrc3        add       pdqrc3        svqrc3
417cA*
417cA*    Accumulate total exceptions to include in qty test.
417cAC                   exsr      zzttle
     *  Quantity.
413cA*R         QTCHK     IFEQ '1'
413cAC                   if        sdqrc1 <> w1qrc1  or
413cAC                             sdqrc2 <> w1qrc2  or
413cAC                             sdqrc3 <> w1qrc3
413cAC                   eval      qtchk = *off
413cAC                   endif
413cA*R                   ENDIF
413c *
413cAC                   if        qtchk = '2'  and
413cAC                             ovrrid = *on
413cAC                   eval      qtchk = *on
413cAC                   endif
413c *
413cMC                   if        qtchk <> '1'
413cAC                   eval      qtchk = *on
413c *
413c *R         OVRRID    IFEQ *OFF
221 D*R         SVQRC1    IFNE PDQRC1
221 D*R         SVQRC2    ORNE PDQRC2
221 D*R         SVQRC3    ORNE PDQRC3
520bDC*                  if        svqrc1 <> pdqor1  or
520bDC*                            svqrc2 <> pdqor2  or
520bDC*                            svqrc3 <> pdqor3
520bMC                   if        svqrc1 < pdqor1  or
520bMC                             svqrc2 < pdqor2  or
520bMC                             svqrc3 < pdqor3
     C                   eval      warn = *on
     C                   eval      error = *on
413c C                   eval      qtchk = '2'
     C                   eval      *in21 = *on
     C                   eval      *in22 = *on
     C                   eval      *in23 = *on
     C                   eval      *in01 = *on
     C                   exsr      zm7201
     C                   endif
520bAC                   if        svqrc1 > pdqor1  or
520bAC                             svqrc2 > pdqor2  or
520bAC                             svqrc3 > pdqor3
520bAC                   eval      warn = *on
520bAC                   eval      error = *on
520bAC                   eval      qtchk = '2'
520bAC                   eval      *in21 = *on
520bAC                   eval      *in22 = *on
520bAC                   eval      *in23 = *on
520bAC                   eval      *in01 = *on
520bAC                   exsr      zm3202
520bAC                   endif
413cAC     error         cabeq     *on           enderr
     C                   endif
     *
     C     enderr        tag
     *
214 D*          ERROR     IFEQ *ON
214 D*          ITUM1     IFEQ *BLANKS
214 D*                    MOVE *ON       *IN61
214 D*                    ENDIF
214 D*          ITUM2     IFEQ *BLANKS
214 D*                    MOVE *ON       *IN62
214 D*                    ENDIF
214 D*          ITUM3     IFEQ *BLANKS
214 D*                    MOVE *ON       *IN63
214 D*                    ENDIF
214 D*                    ENDIF
413cA*   Save screen fields.
416hD**                   Z-ADDW1DWGT    SVDWGT  72
416hMC                   eval      svdwgt = w1dwgt
413cAC                   eval      sdqrc1 = w1qrc1
413cAC                   eval      sdqrc2 = w1qrc2
413cAC                   eval      sdqrc3 = w1qrc3
413cAC                   eval      svmfdt = w1mfdt
415bAC                   eval      svexdt = w1exdt
417dD*R                   MOVE W1UPC     SVUPC  20
417dMC                   eval      svupc = w1upcd
SGCaAC                   eval      svckq1 = ckqrc1
650lAC                   eval      svpti  = w1pti
650sA*
650sA*      Clear expiration date work fields.
650sAC                   if        immflg = 'Y'
760bAC                             and error = *off
650sAC                   eval      w1exdt = 0
650sAC                   eval      expd   = 0
650sAC                   endif
650sA*
     C     endck1        endsr
700cA*----------------------------------------------------------------
700cA*
700cA*  ZZCHK1b  Screen 1 error checking.
700cA*
700cAC     zzchk1b       begsr
700cAC                   eval      error = *off
700cA*  at least one UPC must be entered or f9 to skip.
700cAc                   select
700cAc                   when      w1buom1 <> ' ' and
700cAC                             w1bupc1 = ' '  and
700cAc                             w1buom2 <> ' ' and
700cAC                             w1bupc2 = ' '
700cAC                   eval      error = *on
700cAC                   eval      *in15 = *on
700cAc                   eval      errmsg =  'Invalid ' + desc(6)
700cAc                   exsr      zm0105
700cAc                   leavesr
700cAc                   when      w1buom1 <> ' ' and
700cAC                             w1bupc1 = ' '  and
700cAc                             w1buom2 =  ' '
700cAC                   eval      error = *on
700cAC                   eval      *in15 = *on
700cAc                   eval      errmsg =  'Invalid ' + desc(6)
700cAc                   exsr      zm0105
700cAc                   leavesr
700cAc                   when      w1buom2 <> ' ' and
700cAC                             w1bupc2 = ' '  and
700cAc                             w1buom1 =  ' '
700cAC                   eval      error = *on
700cAC                   eval      *in16 = *on
700cAc                   eval      errmsg =  'Invalid ' + desc(6)
700cAc                   exsr      zm0105
700cAc                   leavesr
700cAc                   endsl
700cA*
700cA*  Extract UPC code from entered string.
700cA*
700cA * edit breakdown 1 upc
700cAc                   if        w1buom1 <> ' ' and
700cAC                             w1bupc1 <> *blanks
700cAC                   eval      $cbcmd = '*UPC    '
700cAC                   eval      $cbbar = w1bupc1
700cA*
700cAC                   call      'CVTBAR'
700cAC                   parm                    $cbcmd            8
700cAC                   parm                    $cbbar          100
700cAC                   parm                    $cbcod            3 0
700cAC                   parm                    $cbdec            1 0
700cAC                   parm                    $cbdsc           30
700cAC                   parm                    $cbpos            3 0
700cAC                   parm                    $cbtyp            1 0
700cAC                   parm                    $cbv1            11 3
700cAC                   parm                    $cbv2            50
700cAC                   parm                    $cbrtn            8
700cAC                   parm                    $cberm           60
740cAC                   parm      $itven#       $cbven           10 0
740cAC                   parm                    $cvtdata
740cAC                   parm                    $cvtdata2
700cA*
700cAC                   movel     $cbv2         $cstr
700cAC                   call      'ADJUST'
700cAC                   parm      '*RIGHT  '    $ccmd             8
700cAC                   parm                    $cstr            30
700cAC                   move      $cstr         b1upc
700cAC                   endif
700cA*   Do UPC Check
700cAC                   if        w1bupc1 <> ' '
700cA*
700cA*  MOVED CODE TO EXTRACT UPC CODE FROM ENTERED STRING
700cAC                   select
700cA*
700cAC                   when      $cbrtn = '*OK'
700cAc                   eval      writeb1 = *on
700cAc                   eval      b1type = %trimr($cbdsc)
700cA*
700cAC                   other
700cAC                   eval      error = *on
700cAC                   eval      *in15 = *on
700cAC                   movel     $cberm        errmsg
700cAC                   exsr      zm0105
700cAC                   endsl
700cA*
700cAC     error         cabeq     *on           endck1b
700cAC                   endif
700cA*
700cA * edit breakdown 2 upc
700cAc                   if        w1buom2 <> ' ' and
700cAC                             w1bupc2 <> *blanks
700cAC                   eval      $cbcmd = '*UPC    '
700cAC                   eval      $cbbar = w1bupc2
700cA*
700cAC                   call      'CVTBAR'
700cAC                   parm                    $cbcmd            8
700cAC                   parm                    $cbbar          100
700cAC                   parm                    $cbcod            3 0
700cAC                   parm                    $cbdec            1 0
700cAC                   parm                    $cbdsc           30
700cAC                   parm                    $cbpos            3 0
700cAC                   parm                    $cbtyp            1 0
700cAC                   parm                    $cbv1            11 3
700cAC                   parm                    $cbv2            50
700cAC                   parm                    $cbrtn            8
700cAC                   parm                    $cberm           60
740cAC                   parm      $itven#       $cbven           10 0
740cAC                   parm                    $cvtdata
740cAC                   parm                    $cvtdata2
700cA*
700cAC                   movel     $cbv2         $cstr
700cAC                   call      'ADJUST'
700cAC                   parm      '*RIGHT  '    $ccmd             8
700cAC                   parm                    $cstr            30
700cAC                   move      $cstr         b2upc
700cAC                   endif
700cA*   Do UPC Check
700cAC                   if        w1bupc2 <> ' '
700cA*
700cA*  MOVED CODE TO EXTRACT UPC CODE FROM ENTERED STRING
700cAC                   select
700cA*
700cAC                   when      $cbrtn = '*OK'
700cAc                   eval      writeb2 = *on
700cAc                   eval      b2type = %trimr($cbdsc)
700cA*
700cAC                   other
700cAC                   eval      error = *on
700cAC                   eval      *in16 = *on
700cAC                   movel     $cberm        errmsg
700cAC                   exsr      zm0105
700cAC                   endsl
700cA*
700cAC     error         cabeq     *on           endck1b
700cAC                   endif
700cA*
700cAC     endck1b       endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
650gAc                   exsr      zzrcvpocheck
     *
     C     endck2        endsr
     *----------------------------------------------------------------
413b *
413b *  ZZCHKT   Screen 3 error check totals
413b *
413b C     zzchkt        begsr
650eDC**                 eval      error = *off
     *
     *
     *     Check # of entrys if individual catchweight entry = Y
     *
     *
413bA*
413bA*
413bA*     Compare total catchweight to expected catchweight
413bA*
     *
530aD ***                if        lvskp = *off and
530aD ***                          wotcw < lwrng
530aMC                   if        lvskp = *off
530aMC                             and wotcw < lwrng
530aAC                             and opwrncr = 'Y'
    D*R                   Z-ADD1         POSREC
413b C                   eval      error = *on
413cAC                   eval      wtchk = '2'
413b C                   eval      warn = *on
413b C                   eval      *in25 = *on
413b C                   eval      *in05 = *on
413b C                   eval      errmsg = *blanks
413b C                   eval      ertcwt = wotcw
413b C                   eval      erlrng = lwrng
650nAC                   eval      CW_exrngl = erlrng
413bAC                   if        hvskp = *on
413bAC                   eval      erhrng = 0
650nAC                   eval      CW_exrngh = erhrng
413bAC                   else
413b C                   eval      erhrng = hirng
650nAC                   eval      CW_exrngh = erhrng
413bAC                   endif
413b C     prg1c         mult      100           errg1c
413b C     prg2c         mult      100           errg2c
410 D*                    Z-ADDOPRG1C    ERRG1C
410 D*                    Z-ADDOPRG2C    ERRG2C
416dAC                   eval      erexwt = exwgt
DRYcAC                   select
DRYcAC                   when      client = Dairyland
DRYcAC                   exsr      zm23
DRYcAC                   other
413b C                   exsr      zm19
DRYcAC                   endsl
413b C                   endif
     *
530aD ***                if        hvskp = *off  and
530aD ***                          wotcw > hirng
530aMC                   if        hvskp = *off
530aMC                             and wotcw > hirng
530aAC                             and opwrncr = 'Y'
    D*R                   Z-ADD1         POSREC
413b C                   eval      error = *on
413cAC                   eval      wtchk = '2'
413b C                   eval      warn = *on
413b C                   eval      *in25 = *on
413b C                   eval      *in05 = *on
413b C                   eval      errmsg = *blanks
413b C                   eval      ertcwt = wotcw
413bAC                   if        lvskp = *on
413bAC                   eval      erlrng = 0
650nAC                   eval      CW_exrngl = erlrng
413bAC                   else
413b C                   eval      erlrng = lwrng
650nAC                   eval      CW_exrngl = erlrng
413bAC                   endif
413b C                   eval      erhrng = hirng
650nAC                   eval      CW_exrngh = erhrng
413b C     prg1c         mult      100           errg1c
413b C     prg2c         mult      100           errg2c
410 D*                    Z-ADDOPRG1C    ERRG1C
410 D*                    Z-ADDOPRG2C    ERRG2C
416dAC                   eval      erexwt = exwgt
DRYcAC                   select
DRYcAC                   when      client = Dairyland
DRYcAC                   exsr      zm23
DRYcAC                   other
413b C                   exsr      zm19
DRYcAC                   endsl
413b C                   endif
     *
     *
413bA*R                   ENDIF
     *
413bAC                   endsr
DRYfA*----------------------------------------------------------------
DRYfA*
DRYfA*  ZZCHKT1  Screen 3 error checks:
DRYfA*           1. Compare imported cw to entered cw.
DRYfA*           2. Compare ordered qty to received qty.
DRYfA*
DRYfAC     zzchkt1       begsr
     *
     C                   if        hvskp = *off
     C                             and opwrncr = 'Y'
     C                             and caltol1 >= prg2c
     C                   eval      error = *on
     C                   eval      wtchk = '2'
     C                   eval      warn = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   eval      CW_exrngl = 0
     C                   eval      CW_exrngh = caltol1
     C                   eval      caltol1x100 = caltol1 * 100
     C                   eval      errg2c = prg2c * 100

     C                   eval      errmsg = 'Wgt tol% '
     C                                      + %triml(%editc(caltol1x100:'3'))
     C                                      + ' >= var% '
     C                                      + %triml(%editc(errg2c:'3'))
     C                   exsr      zm0105
     C                   goto      endckt1
     C                   endif

     C                   if        hvskp = *off
     C                             and opwrncr = 'Y'
     C                             and caltol2 >= prg2c
     C                   eval      error = *on
     C                   eval      wtchk = '2'
     C                   eval      warn = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   eval      CW_exrngl = 0
     C                   eval      CW_exrngh = caltol2
     C                   eval      caltol2x100 = caltol2 * 100
     C                   eval      errg2c = prg2c * 100

     C                   eval      errmsg = 'Qty tol% '
     C                                      + %triml(%editc(caltol2x100:'3'))
     C                                      + ' >= var% '
     C                                      + %triml(%editc(errg2c:'3'))
     C                   exsr      zm0105
     C                   goto      endckt1
     C                   endif

     C     endckt1       endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
TMP A*
TMP A*  Test for F4 - Lookup
TMP A*
TMP AC                   if        *inkd
TMP AC                   eval      cmdtkn = *on
TMP AC                   z-add     0             row#
TMP AC                   eval      row = rowin
TMP AC                   z-add     0             col#
TMP AC                   eval      col = colin
TMP A*
TMP AC                   select
TMP A*
TMP A*     Slot.
TMP A*
TMP AC                   when      row# = 18
TMP AC                   eval      *in13 = *on
TMP A**                   MOVE '*VRFYZRO'$LCMD
TMP AC                   eval      $lcmd = '*BOTH   '
TMP AC                   eval      $lwhs2 = $pwhse
TMP AC                   eval      $lwhd2 = itwhdp
TMP AC                   eval      $litm2 = $pitem
TMP AC                   eval      $ldisp = *blanks
TMP AC                   eval      $ldesg = itdesg
TMP AC                   eval      $lst = 'V '
TMP AC                   eval      $lsdef = *blanks
TMP AC                   eval      $lactv = *blanks
TMP AC                   call      'SL900'
TMP AC                   parm                    $lparm
TMP AC                   if        $lrtn = '*SELECT '
TMP AC                   eval      w1slot = $ldisp
TMP AC                   endif
TMP A*
TMP A*     Cursor not on a valid lookup field.
TMP A*
TMP AC                   other
TMP AC                   eval      error = *on
TMP AC                   exsr      zm9905
TMP AC                   endsl
TMP AC                   goto      endcm1
TMP AC                   endif
     *
640bA*  Test for F7 - Kilograms/Pounds toggle
640bA*
640bAC                   if        *inkg and itcwgt = 'N'
640bAC                   eval      cmdtkn = *on
640bAC                   eval      error = *on
640bAC                   eval      errmsg = *blanks
640bAC                   movel     desc(9)       errmsg
640bAC                   exsr      zm0105
640bAC                   goto      endcm1
640bAC                   endif
640bAC                   if        *inkg
640bAC                   eval      cmdtkn = *on
640bAC                   if        KiloLbs = 'P'
640bAC                   eval      KiloLbs = 'K'
640bAC                   eval      W1KgLb  = 'Kgs'
640bAC                   else
640bAC                   eval      KiloLbs = 'P'
640bAC                   eval      W1KgLb  = 'Lbs'
640bAC                   endif
640bAC                   select

650aDC*                  when      KiloLbs = 'K' and immflg = 'Y'
650aMC                   when      KiloLbs = 'K' and itflgd = 'Y'
640bAC                   eval      cmdln1 = cmdln(2)

650aDC*                  when      KiloLbs = 'P' and immflg = 'Y'
650aMC                   when      KiloLbs = 'P' and itflgd = 'Y'
640bAC                   eval      cmdln1 = cmdln(1)

650aDC*                  when      KiloLbs = 'K' and immflg = 'N'
650aMC                   when      KiloLbs = 'K' and itflgd = 'N'
640bAC                   eval      cmdln1 = cmdln(4)

650aDC*                  when      KiloLbs = 'P' and immflg = 'N'
650aMC                   when      KiloLbs = 'P' and itflgd = 'N'
640bAC                   eval      cmdln1 = cmdln(3)

640bAC                   endsl
640bAC                   endif
413aA*
413aA*      F8  - Item Tie/High Maintenance.
413aA*
413aAC                   if        *inkh
413aAC                   eval      cmdtkn = *on
413aAC                   eval      whse = $pwhse
413aAC                   call      'IT141'
413aAC                   parm                    whse
413aAC                   parm                    $pitem
413aAC                   endif
415dA*
DRYcA* If specific client, do not allow F9=Cwgt Entry.
DRYcA*
DRYcAC                   if        *inki and
DRYcAC                             client = Dairyland
DRYcAC                   eval      cmdtkn = *on
DRYcAC                   eval      error = *on
DRYcAC                   eval      errmsg = *blanks
DRYcAC                   movel     desc(11)      errmsg
DRYcAC                   exsr      zm0105
DRYcAC                   goto      endcm1
DRYcAC                   endif
415dA*
415dA*      F9  - Scan Item Catchweight labels.
415dA*
415dAC                   if        *inki  and
510kMC                             (itcwgt = 'Y'
SOFaMC                              or itcwgt = 'S'
SOFaMC                              and client <> sofo)
SOFaDC*                             or itcwgt = 'S')
415dAC                   eval      cmdtkn = *on
415dAC                   eval      $mcmd = '*CHANGE '
415dAC                   eval      $mwhs3 = $pwhse
415dAC                   eval      $mpo3 = $ppo
415dAC                   eval      $mseq = $pseq
415dAC                   eval      $mitm3 = $pitem
415dAC                   eval      $mqyr1 = w1qrc1
415dAC                   eval      $mqyr2 = w1qrc2
415dAC                   eval      $mqyr3 = w1qrc3
415dAC                   eval      $mcwte = *zeros
415dAC                   eval      $mcwtt = *zeros
415dAC                   eval      $mcwta = *zeros
415dAC                   call      'CW122'
415dAC                   parm                    $mparm
415dA*
415dA*    Load weight from entry program / Change flag to show not avg.
415dAC                   eval      w1dwgt = $mcwtt
415dAC                   eval      w1avg = 'N'
700bA*    If weight is returned, set to default item options UOM mode
640bA*    If weight is returned, force 'pounds' mode.-700b changed and
700bA*    We no longer force the mode to pounds mode.
640bAC                   if        $mcwtt > 0
700bDC*                  eval      KiloLbs = 'P'
700bdC*                  eval      W1KgLb  = 'Lbs'
700bDC*                  select
650aDC*                  when      immflg = 'Y'
700bDC*                  when      itflgd = 'Y'
700bDC*                  eval      cmdln1 = cmdln(1)
700bDC*                  other
700bDC*                  eval      cmdln1 = cmdln(3)
700bdC*                  endsl
      /free
700bA   select;
700bA     when svopwum = 'KGS'
700bA      or svopwum = 'kgs'
700bA      or svopwum = 'Kgs';
700bA       KiloLbs = 'K';
700bA       W1KgLb  = svopwum;
700bA       if itflgd = 'Y';
700bA         cmdln1 = cmdln(2);
700bA       else;
700bA         cmdln1 = cmdln(4);
700bA       endif;
700bA     other;
700bA       KiloLbs = 'P';
700bA       W1KgLb  = 'Lbs';
700bA       if itflgd = 'Y';
700bA         cmdln1 = cmdln(1);
700bA       else;
700bA         cmdln1 = cmdln(3);
700bA       endif;
700bA   endsl;
      /end-free
640bAC                   endif
415dAC                   endif
510gA*
510gA*      F11 - Manufacturer code decipher
510gA*
510gAc                   if        *inkk
530 AC                   eval      $lexpdat = 0
530 AC                   eval      $lmfrdat = 0
530 Ac                   eval      $lrtn = ' '
510mA * f11 is only valid on date sensitive items
510mAc                   If        itflgd = 'Y' or immflg = 'Y'
510gAc                   eval      $lmfr#    = phven
510gAc                   eval      $lmfritem = pdvitm
510gAc                   eval      $ldakitem = pditem
510hAc                   eval      $lupc     = w1upcd
510lAc                   eval      ddcode = *off
510jDc*                  call      'MF200'
510jMc                   call      'MF200'                              66
510gAC                   parm                    $lparm
510gAC                   parm      0             $lexpdat          6 0
510gAC                   parm      0             $lmfrdat          6 0
510hAC                   parm                    $lupc            20
640eAC                   parm      ' '           $ldecvalue       15
510mAc                   else
510mac                   exsr      zm13250
510mAc                   endif
YHAeA * For Hilo, if date returned is invalid try using item vend #
YHAeAc                   if        client=Yhata and client2='HILO'
YHAhAc                             or client=Yhata and client2='KAUAI'
YHAeAc                   if        $lrtn <> *blanks and $lrtn <> 'OK'
YHAeAc                   eval      $lmfr#    = #oven#
YHAeAc                   eval      $lmfritem = pdvitm
YHAeAc                   eval      $ldakitem = pditem
YHAeAc                   eval      $lupc     = w1upcd
YHAeAc                   eval      ddcode = *off
YHAeAc                   call      'MF200'                              66
YHAeAC                   parm                    $lparm
YHAeAC                   parm      0             $lexpdat          6 0
YHAeAC                   parm      0             $lmfrdat          6 0
YHAeAC                   parm                    $lupc            20
YHAeAC                   parm      ' '           $ldecvalue       15
YHAeAc
YHAeAc                   endif
YHAeAc                   endif
510lA * Set ddcode if date returned is invalid
510lAc                   if        $lrtn <> *blanks and $lrtn <> 'OK'
510lAc                   select
510lAc                   when      $lexpdat = 0 and $lmfrdat = 0
510lAc                   eval      ddcode = *on
640jAc                   eval      w1exdt = 0
640jAc                   eval      w1mfdt = 0
510lA
510lAc                   when      $lexpdat <> 0
510lAc                   eval      $cvcmd = '*MDYEDT'
510lAc                   move      $lexpdat      $cvd6i
510lAc                   call      @cvtdt
510lAC                   parm                    $cvtdt
510lAC                   if        $cvrtn = '*PGMQ   '
510lAC                   eval      ddcode= *on
510lAc                   endif
510lA
510lAc                   when      $lmfrdat <> 0
510lAc                   eval      $cvcmd = '*MDYEDT'
510lAc                   move      $lmfrdat      $cvd6i
510lAc                   call      @cvtdt
510lAC                   parm                    $cvtdt
510lAC                   if        $cvrtn = '*PGMQ   '
510lAC                   eval      ddcode= *on
510lAc                   endif
510lAc                   other
510lAc
510lAc                   endsl
510lAc                   endif
640eAc                   exsr      zzmfrdates
510gAC                   eval      w1exdt = $lexpdat
640eAc                   if        immflg = 'Y'
510gAC                   eval      w1mfdt = $lmfrdat
640eAc                   endif
510gAc                   endif
     *
     *      F20 - Accept Warning.
DRYcA*
DRYcA* If specific client, do not allow override for c/w difference.
DRYcA*
DRYcAC                   if        (*inku or *inkj) and
DRYcAC                             wtchk = '2' and
DRYcAC                             client = Dairyland
DRYcAC                   eval      cmdtkn = *on
DRYcAC                   eval      error = *on
DRYcAC                   eval      errmsg = *blanks
DRYcAC                   movel     desc(12)      errmsg
DRYcAC                   exsr      zm0105
DRYcAC                   goto      endcm1
DRYcAC                   endif
415dA*
     *
     C                   if        *inku
500 AC                             or *inkj
     C                   eval      ovrrid = *on
413c C                   else
413c C                   eval      ovrrid = *off
     C                   endif
     *
     C     endcm1        endsr
700cA*----------------------------------------------------------------
700cA*
700cA*  ZZCMD1b  User defined command keys for screen 1b.
700cA*
700cAC     zzcmd1b       begsr
700cAC                   eval      cmdtkn = *off
700cA*
700cAC     endcm1b       endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     C     endcm2        endsr
     *----------------------------------------------------------------
640bA*
640bA*  ZZCNVWGT  Setup converted weight field.
640bA*
640bAC     zzcnvwgt      begsr
640bA*
     *    If in kilograms mode, convert into pounds for processing.
     *
     * If item options is setup as kgs and user enters kgs no conversion
     * If item options is setup as kgs and user enters lbs need conversion
     * If item options is setup as lbs and user enters lbs no conversion
     * If item options is setup as lbs and user enters kgs need conversion
700bA /free
700bA   select;
700bA     when svopwum = 'KGS'
700bA      or svopwum = 'kgs'
700bA      or svopwum = 'Kgs';
700bA       if KiloLbs = 'K';
700bA         eval cnvwgt = w1dwgt;
700ba       else;
700bA         eval(h) cnvwgt = w1dwgt / kgs2lbs;
700bA       endif;
700bA     other;
700bM       if KiloLbs = 'K';
700bM         eval(h) cnvwgt = w1dwgt * kgs2lbs;
700bM       else;
700bM         eval cnvwgt = w1dwgt;
700bM       endif;
700bA   endsl;
700bA /end-free
700bDC*                  if        KiloLbs = 'K'
700bDC*                  eval(h)   cnvwgt = w1dwgt * kgs2lbs
700bDC*                  else
700bDC*                  eval      cnvwgt = w1dwgt
700bDC*                  endif

     C                   endsr
510iA*----------------------------------------------------------------
510iA*     ZZCVQY - Convert receive qty's to string for msg display
510iA*
510iAC     zzcvqy        begsr
510iAC                   call      'CVTQTY'
510iAC                   parm                    $ccmd             8
510iAC                   parm                    $cprg            10
510iAC                   parm                    $cqty1            7 0
510iAC                   parm                    $cqty2            7 0
510iAC                   parm                    $cqty3            7 0
510iAC                   parm                    $cum1             2
510iAC                   parm                    $cum2             2
510iAC                   parm                    $cum3             2
510iAC                   parm                    $cqstr           10
510iAC                   parm                    $custr           17
510iAC                   parm                    $crtn             8
510iAC                   parm                    $cerm
510iAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   endsr
700cA*----------------------------------------------------------------
700cA*
700cA*  ZZDFT1b  Get default values for add.
700cA*
700cAC     zzdft1b       begsr
700cA /free
700cA   // setup which fields are displayed
700cA   if needb1 = *on;
700cA     w1bupc1 = ' ';
700cA     w1buom1 = $itum2;
700cA     *in38 = *off;
700cA   else;
700cA     *in38 = *on;
700cA   endif;
700cA   if needb2 = *on;
700cA     w1bupc2 = ' ';
700cA     w1buom2 = $itum3;
700cA     *in39 = *off;
700cA   else;
700cA     *in39 = *on;
700cA   endif;
700cA /end-free
700cAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     C                   endsr
650rA*----------------------------------------------------------------
650rA*
650rA*  ZZEND   End timer
650rA*
650rAC     zzend         begsr
     *
650rAc                   eval      pgtnsc = nxtscr
650rAC                   callp     getmicrotime(currstampuc:currstampsys)
650rAc                   eval      pgtEndts = currstampsys
     *
650rAc     pgtEndts      subdur    pgtStrts      dsecs:*s
650rAc                   eval(h)   pgtsec = dsecs
650rA*
650rAC                   eval      pgtjob = #job
650rAC                   eval      pgtusr = #user
650rAC                   move      #jobn         pgtjb#
     *
650rAC                   if        pgmtracking
650rAC                   write     pgtrec
650rAc                   endif
     *
650rAC     endzze        endsr
650rA*----------------------------------------------------------------
650rA*
650rA*  ZZENDP  End timer - call to another program
650rA*
650rAC     zzendp        begsr
     *
650rAc                   eval      pgtnsc = 'PO236'
650rAC                   callp     getmicrotime(currstampuc:currstampsys)
650rAc                   eval      pgtEndts = currstampsys
     *
650rAc     pgtEndts      subdur    pgtStrts      dsecs:*s
650rAc                   eval(h)   pgtsec = dsecs
     *
650rAC                   eval      pgtjob = #job
650rAC                   eval      pgtusr = #user
650rAC                   move      #jobn         pgtjb#
     *
650rAC                   if        pgmtracking
650rAC                   write     pgtrec
650rAC                   endif
     *
650rAC     endzzep       endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
417pA*    Default FIFO entered date if entry is allowed.
417pAC                   if        not *in89
417pAC                   move      today         $cvd8i
417pAC                   eval      $cvcmd = '*CMDMDY '
417pAC                   call      @cvtdt
417pAC                   parm                    $cvtdt
417pAC                   move      $cvd6o        todayo
417pA*
417pAC                   eval      w1fifo = todayo
417pAC                   else
417pAC                   eval      w1fifo = 0
417pAC                   endif
MJKbA*   For an MJ Kellner do not default FIFO = today's date.
MJKaAC                   if        client = mjkellner
MJKaAC                   eval      w1fifo = 0
MJKaAC                   endif
417hA*    Retrieve Item Lot/license plate tracking info.
417hAC                   eval      $lcmd = *blanks
417hAC                   eval      $lprg = #prog
417hAC                   eval      $lwhse = $pwhse
417hAC                   eval      $litem = pditem
417iA*    Protect,non-display lot code entry field.
417iAC                   eval      *in88 = *on
417hAC                   call      'GETLLP'
417hAC                   parm                    $lparm
417hA*
417hAC                   select
417hA*    Lot/license plate tracking values found.
417hAC                   when      $lrtn = '*OK     '
417hAC                   if        $llot = 'Y'
640fAc                             or $plot <> ' '
417hAC                   eval      lottrk = '*YES'
417iA*    Display lot code entry field.
417iAC                   eval      *in88 = *off
417hAC                   else
417hAC                   eval      lottrk = '*NO '
417hAC                   endif
417hAC                   if        $lltrk = 'Y'
417hAC                   eval      lictrk = '*YES'
417hAC                   else
417hAC                   eval      lictrk = '*NO '
417hAC                   endif
417hAC                   other
417hAC                   eval      lottrk = '*NO '
417hAC                   eval      lictrk = '*NO '
417hAC                   endsl
417hA*
     C                   eval      w1po = pdpo
     C                   eval      w1item = pditem
221 AC                   eval      w2vitm = pdvitm
     C                   eval      w1whse = $pwhse
     C     w1whse        chain     warehs                             79
     C                   if        not *in79
     C                   eval      w1fdsc = whdesc
     C                   else
     C                   eval      w1fdsc = *blanks
     C                   endif
221 D*R                   Z-ADDPDQRC1    W1QRC1
221 D*R                   Z-ADDPDQRC2    W1QRC2
221 D*R                   Z-ADDPDQRC3    W1QRC3
413 AC                   if        $pcmd = '*QUICK  '
413 AC                   eval      w1qrc1 = pdqor1
413 AC                   eval      w1qrc2 = pdqor2
413 AC                   eval      w1qrc3 = pdqor3
413 AC                   else
221 MC                   eval      w1qrc1 = 0
221 MC                   eval      w1qrc2 = 0
221 MC                   eval      w1qrc3 = 0
413 AC                   endif
     C                   eval      w1plts = 0
SVLaAC                   if        client = saval
SVLaAC                   eval      w1plts = 1
SVLaAC                   endif
     C                   eval      w1exdt = 0
219 AC                   eval      w1avg = 'N'
409 AC                   eval      iatest = *blanks
409 AC                   eval      iaflag = *off
409 AC                   eval      w1mfdt = 0
417iAC                   eval      w1lotc = *blanks
510dAC                   eval      woexdt = 0
510dAC                   eval      woindt = 0
650lAC                   eval      w1pti  = 0
214 A*
214 A*   Get Unit of measure fields
214 A*
214 AC                   eval      w1um1 = *blanks
214 AC                   eval      w1um2 = *blanks
214 AC                   eval      w1um3 = *blanks
214 AC                   exsr      zzuom
     *
221 D*R                   Z-ADDPDDWGT    W1DWGT
221 MC                   eval      w1dwgt = 0
     *
CBIaAC                   if        client = cheney
CBIaAC     itdesg        chain     desigsp                            79
CBIaAC                   if        *in79 = *off
CBIaAC                   eval      sdesig = *on
CBIaAC                   else
CBIaAC                   eval      sdesig = *off
CBIaAC                   eval      dsscde = *blanks
CBIaAC                   endif
CBIaAC                   endif
YHA AC                   if        client = yhata
BIRaAC                             or client = birite
YHA AC                   eval      *in63 = *off
YHA  C*   Convert quantity to string.
YHA  C                   eval      $ccmd = '*QTY2STR'
YHA  C                   eval      $cprg = #prog
YHA  C                   eval      $cqty1 = pdqor1
YHA  C                   eval      $cqty2 = pdqor2
YHA  C                   eval      $cqty3 = pdqor3
YHA  C                   exsr      zzcvqy
YHA  C                   eval      woqor = $cqstr
YHA  C*
YHA AC                   else
YHA AC                   eval      *in63 = *on
YHA  C                   eval      woqor = *blanks
YHA AC                   endif
416dA*
416dA*   Enable/Disable catch weight fields.
416dA*
416dAC                   eval      vrfycw = *off
416dAC                   eval      *in82 = *off
416dA*
416dA*     First, see if catch weight entry is allowed.
416dA*
SOFaAC                   if        client = sofo
SOFaAC                   if        itcwgt <> 'Y'  or
SOFaAC                             svcwen = '3'
SOFaAC                   eval      *in95 = *on
SOFaAC                   eval      vrfycw = *off
SOFaAC                   else
SOFaAC                   eval      *in95 = *off
SOFAAC                   eval      vrfycw = *on
SOFaAC                   endif
SOFaAC                   else
510kDC*                  if        itcwgt <> 'Y'  or
510kMC                   if        (itcwgt <> 'Y'  and
510kAC                              itcwgt <> 'S') or
416dAC                             svcwen = '3'
214 AC                   eval      *in95 = *on
416dAC                   eval      vrfycw = *off
214 AC                   else
214 AC                   eval      *in95 = *off
416dAC                   eval      vrfycw = *on
214 AC                   endif
SOFaAC                   endif
416dA*
416dA*     Then see if we should block entry ...
416dA*       because catch weight previously entered.
416dA*
416dAC                   if        svcwen = '2'  and
416dAC                             pddwgt <> 0
416dAC                   eval      *in82 = *on
416fAC                   eval      *in95 = *on
416dAC                   eval      vrfycw = *off
416dAC                   endif
416dA*
416dA*     Then see what value is to be entered (1=Choice,2=Ttl,3=Avg)
416dA*
416dAC                   select
416dAC                   when      svcwtp = '2'
416dAC                   eval      *in81 = *on
416dAC                   eval      w1avg = 'N'
416dAC                   eval      wocrcv = cwt(2)
416dAC                   when      svcwtp = '3'
416dAC                   eval      *in81 = *on
416dAC                   eval      w1avg = 'Y'
416dAC                   eval      wocrcv = cwt(3)
416dAC                   other
416dAC                   eval      *in81 = *off
416dAC                   eval      w1avg = 'N'
416dAC                   eval      wocrcv = cwt(1)
416dAC                   endsl
416dA*
416dA*   Enable/Disable expiration date fields.
416dA*
214 AC                   if        itflgd <> 'Y'
214 AC                   eval      *in96 = *on
214 AC                   else
214 AC                   eval      *in96 = *off
214 AC                   endif
     *
401 A*   Get the picking slot for the item.
401 A*
416bD**         ITSTYP    IFEQ 'F'
416bD**                   MOVE 'A '      KYSTAT
416bD**                   MOVE 'Y'       KYPICK
416bD**         ITTYPE    IFEQ ' '
416bD**         ITTYPE    OREQ 'B'
416bD**                   MOVE ITITEM    KYITEM
416bD**                   ELSE
416bD**                   MOVE #BITEM    KYITEM
416bD**                   ENDIF
416bD**         KEYSL3    SETLLSLOT3
416bD**         KEYSL3    READESLOT3                    77
416bD**         *IN77     IFEQ *ON
416bD**                   MOVEL'NONE'    WOSLOT
416bD**                   ELSE
416bD**                   MOVELSLDISP    WOSLOT
416bD**                   ENDIF
416bD**                   ELSE
416bD**                   MOVE *BLANKS   WOSLOT
416bD**                   MOVEL'NONE'    WOSLOT
416bD**                   ENDIF
     *
416bAC                   if        itstyp = 'P'
416bAC                   eval      $scmd = '*LAST'
416bAC                   else
416bAC                   eval      $scmd = '*FIRST'
416bAC                   endif
416bAC                   call      'GETPSLT'
416bAC                   parm                    $scmd             8
416bAC                   parm      itwhse        $swhse
416bMC                   parm                    #sitem
416bAC                   parm                    woslot
416mAC                   parm      *blanks       $saisl            3
416mAC                   parm      *zeros        $sloc             3 0
416mAC                   parm      *zeros        $srlvl            2 0
416mAC                   parm      *blanks       $shand            2
416bAC                   parm                    $srtn             8
CBIaA*
CBIaA* Try to display Special Designation slot.
CBIaAC                   select
CBIaAC                   when      Client = cheney
CBIbAC                   if        woslot = '*NONE*  ' and
CBIaAC                             sdesig = *on
CBIaAC                   eval      woslot = dssdsp
CBIaAC                   endif
CBIbAC                   endsl
     *
TMP AC                   eval      w1slot = *blanks
640cA*  See if any stock in overflow slot.
640cA*
640cAC                   eval      wOostk = 'N'
640cAC                   move      'A '          kystat
640cAC                   eval      kypick = 'N'
640cAC     keys3         setll     slot3
640cAC                   dow       forevr = forevr
640cAC     keys3         reade     slot3                                  79
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
640cAC                   eval      wOostk = 'Y'
640cAC                   leave
640cAC                   endif
640cAC                   endif
640cAC                   enddo
409 A*
409 A*   Enable Mfg date and disable Exp date, if Mfg date flag = 'Y'
409 A*
409 AC     imkey         chain     itemmsc                            79
409 AC                   if        not *in79  and
409 AC                             immflg = 'Y'
409 AC                   eval      *in87 = *off
409 AC                   eval      *in96 = *on
409 AC                   else
409 AC                   eval      *in87 = *on
409 AC                   endif
409 AC                   if        *in79
409 AC                   eval      immflg = 'N'
409 AC                   endif
640fA * load up fields from gs1 incoming information
640fA * Expiration Date
640fAc                   If        not *in96
640fAc                   if        $pexpdt > 0
640fAC                   move      $pexpdt       $cvd6i
640fAC                   eval      $cvcmd = '*YMDMDY '
640fAC                   call      @cvtdt
640fAC                   parm                    $cvtdt
640fAC                   move      $cvd6o        w1exdt
640fac                   endif
640fac                   endif
640fA * Manufacturing Date
640fAc                   If        immflg = 'Y'
640fAc                   if        $pmfgdt > 0
640fAC                   move      $pmfgdt       $cvd6i
640fAC                   eval      $cvcmd = '*YMDMDY '
640fAC                   call      @cvtdt
640fAC                   parm                    $cvtdt
640fAC                   move      $cvd6o        w1mfdt
640fac                   endif
640fac                   endif
640fA * Lot
640fAc                   If        lottrk = '*YES'
640fAc                   if        $pLot <> ' '
640fAc                   eval      w1lotc = $plot
640fAc                   endif
640fac                   endif
640fA * Catch Weight
640fAc                   If        vrfycw = *on
640fAc                   if        $pwgt > 0
640fAc                   eval      w1dwgt = $pwgt
640fAc                   endif
640fac                   endif
640fA * Quantity
640fAc                   if        $pqty > 0
640fAc                   eval      w1qrc1 = $pqty
640fAc                   endif
640fA * # of Pallets
640fAc                   if        $p#pall > 0
640fAc                   eval      w1plts = $p#pall
640fAc                   endif
650qA * OSS Receiving
650qA /free
650qA     w1note = ' ';
650uA   // if po line is marked for cross dock that take priority
650uA     Select;
650uA       When pdspcl = 'XD';
650uA         w1note = ' Cross-Dock  ';
650uA       other;
650qA         if $posscode <> ' ';
650qA           w1note = 'OSS Receiving';
650qA         endif;
650uA     endsl;
760aA     if clienthost = freshbyte;
760aA       w1lotc = %subst(pdpo:1:6) +
760aa                %subst(%EditC(pdseq:'X'):3:3);
760aA       *in88 = *on;
760aA     endif;
760qA /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.
     *
219 D*R         FILEKY    CHAINRECORD               7978
219 MC     fileky        chain     record                             79
     *
     *  Record locked.
     *
219 D*R         *IN78     IFEQ *ON
     *R                   MOVE *ON       ERROR
     *R                   MOVE '*PGMQ   '$PRTN
     *R                   EXSR ZM74
     *R                   GOTO ENDGT1
     *R                   END
     *
     *  Record not found.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt1
     C                   endif
     *
     *   If viewing, release record.
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C     *loval        setll     record
     C                   endif
RNZaAC*
RNZaAC                   if           client = Renzi
FKL AC                             or client = Finkle
SOF AC                             or client = SoFo
DRYcAC                             or client = Dairyland
RNZaAC*      Retrieve P/O Detail Misc. record.
RNZaAC                   if        pditem = rtxall9item
DRYcAC                             or client = Dairyland
RNZaAC                   exsr      zzgtpdm
RNZaAC                   endif
RNZaAC                   endif
RNZaAC*
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 1.
     *
     C     zzget2        begsr
     C     endgt2        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
     C                   kfld                    $pseq
     C                   kfld                    $pitem
     *
     *  Define partial key for main file.
     *
     C     partky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
TMP A*
TMP A*  Define key for SLOT2 file.
TMP A*
TMP AC     slkey         klist
TMP AC                   kfld                    $pwhse
TMP AC                   kfld                    itwhdp
TMP AC                   kfld                    w1slot
409 A*  Define partial key for SLOT3 file.
409 A*
640cAC     keys3         klist
640cAC                   kfld                    $pwhse
640cAC                   kfld                    ititem
640cAC                   kfld                    kystat
640cAC                   kfld                    kypick
     *
     *  Define key for POHDR file.
     *
     C     phkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
     *
     *  Define key for PIRITEM file.
     *
     C     ittkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
413aA*
413aA*  Define partial key for item tie/high definition file.
413aA*
413aAC     partk2        klist
413aAC                   kfld                    $pwhse
413aAC                   kfld                    $pitem
     *
219 A*
219 A*     OPTIONS
219 A*
219 AC     opkey         klist
413bA*                    KFLD           $PWHSE
413bMC                   kfld                    wkwhse
219 AC                   kfld                    ocode
219 A*
219 A*     EXTENDED ITEM DESCRIPTION
219 A*
219 AC     idkey         klist
219 AC                   kfld                    $pwhse
219 AC                   kfld                    $pitem
221 A*
221 A*     UPC
221 A*
221 AC     upcky         klist
221 AC                   kfld                    $pwhse
221 AC                   kfld                    w1upc
221 A*
417kAC     upcky3        klist
417kAC                   kfld                    $pwhse
417kAC                   kfld                    $pitem
417kAC                   kfld                    w1upc
417kAC                   kfld                    phven
221 A*
700cAC     upcky3U       klist
700cAC                   kfld                    $pwhse
700cAC                   kfld                    $pitem
700cAC                   kfld                    w1upc
700cAC                   kfld                    phven
700cAc                   kfld                    uputyp
221 A*
417bAC     upcky2        klist
417bAC                   kfld                    $pwhse
417bAC                   kfld                    $pitem
417bAC                   kfld                    w1upc
221 A*
417jAC     upcky1        klist
417jAC                   kfld                    $pwhse
417jAC                   kfld                    $pitem
417jAC                   kfld                    phven
     *
401 A*  Define partial key for SLOT3 file.
401 A*
401 AC     keysl3        klist
401 AC                   kfld                    $pwhse
415fD**                   KFLD           $PITEM
415fMC                   kfld                    kyitem
401 AC                   kfld                    kystat
401 AC                   kfld                    kypick
     *
     *  Define key for ITEMMSC file.
     *
409 AC     imkey         klist
409 AC                   kfld                    itwhse
409 AC                   kfld                    ititem
     *
     *  Define key for LABEL2  file.
     *
409 AC     lbkey         klist
409 D*R                   KFLD           $RORD
409 MC                   kfld                    $lord
409 AC                   kfld                    $pwhse
416fA*
416fA*  Define key for POCTYPE file.
416fA*
416fAC     keypoc        klist
416fAC                   kfld                    $pwhse
416fAC                   kfld                    $ppo
416fAC                   kfld                    $pseq
417cAC                   eval      forevr = *on
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
221 D*R                   MOVE #PROG     $PPRG
     C                   eval      $cvprg = #prog
MSG AC                   eval      #pgmq = #prog
     C                   eval      $rprg = #prog
510jA * determine if mfr decipher is available to client
510jAc                   eval      $lcmd = '*OPEN'
510jAc                   call      'MF200'                              66
510jAC                   parm                    $lparm
510jAC                   parm      0             $lexpdat          6 0
510jAC                   parm      0             $lmfrdat          6 0
510jAC                   parm                    $lupc            20
640eAC                   parm      ' '           $ldecvalue       15
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
415fA*
415fA*   Initialize error subfile
415fA*
415fAC                   exsr      zmcpmq
     *
413cAC                   setoff                                       kckl
413cAC                   eval      dtchk = *off
416aAC                   eval      dtchk2 = *off
500dAC                   eval      dtchk3 = *off
500dAC                   eval      dtchk4 = *off
413cAC                   eval      qtchk = *off
SGCaAC                   eval      qtchk1 = *off
413cAC                   eval      wtchk = *off
415cAC                   eval      upchk = *off
417jAC                   eval      upchk2 = *off
416kAC                   eval      expd = 0
700cAC                   eval      needb1 = *off
700cAC                   eval      needb2 = *off
640bA*    Default to 'pounds' mode.
700bDC*                  eval      KiloLbs = 'P'
700bDC*                  eval      W1KgLb  = 'Lbs'
640bA*    Setup command display line 2.
640bAC                   eval      cmdln2 = cmdln(7)
401 A*
401 A*   Cannot receive an item, if the PO is ready for export.
401 A*
401 AC     phkey         chain(n)  pohdr                              79
401 AC                   if        not *in79  and
401 AC                             phstat = '3'
401 AC                   exsr      zm3226
401 AC                   eval      $prtn = '*PGMQ   '
401 AC                   eval      error = *on
401 AC                   goto      endinz
401 AC                   endif
BIRbA*
BIRbA*   Check if p/o is Inuse on P/E-Retalix.
BIRbA*
BIRbAC                   if           client = BiRite
SGCcAC                             or client = SGC
BIRbA*
BIRbAC                   exsr      zzchkiuse
BIRbAC                   if        error = '1'
BIRbAC                   goto      endinz
BIRbAC                   endif
BIRbA*
BIRbAC                   endif
417pA*
417pA*   Set Move In FIFO flag.
417pAC                   if        phvnam = 'MOVEIN'  or
417pAC                             phvnam = move1  or
417pAC                             phvnam = move2
417pAC                   eval      *in89 = *off
417pAC                   else
417pAC                   eval      *in89 = *on
417pAC                   endif
415dA*
415dA*   Remove any existing catchweight entry records.
415dAC                   exsr      zzdlcw
     *
221 MC                   eval      lflag = *off
219 AC                   exsr      zzxopt
221 AC                   exsr      zzlcns
     *
413bAC                   eval      ocode = '*SYSTEM '
413bAC                   eval      wkwhse = 0
413bAC     opkey         chain     options                            79
413bAC                   if        *in79
413bAC                   eval      opcapc = 'Y'
413bAC                   eval      opwrnc = 'N'
413bAC                   eval      oprg1c = 0
413bAC                   eval      oprg2c = 0
413b C                   eval      opicw = 'N'
770aAC                   eval      opdckv = 'N'
413bAC                   endif
770aA
770aAc                   if        opdckv = 'Y'
770aAc                   eval      dockvue = *on
770aAc                   else
770aAc                   eval      dockvue = *off
770aAc                   endif
770aA
     *
     *   Select first screen to display.
     *
417dAC                   eval      w1upcd = *blanks
221 AC                   if        $pupc <> *blanks
760cAc                             or svnupc = 'Y'
221 AC                   eval      *in92 = *on
417dA*
417dA*    Left adjust UPC for better and easier viewing.
417dAC                   move(p)   $pupc         $cstr
417dAC                   call      'ADJUST'
417dAC                   parm      '*LEFTNOZ'    $ccmd
417dAC                   parm                    $cstr
417dAC                   movel     $cstr         w1upcd
221 AC                   endif
     *
417KAC                   movel     w1upcd        w1upc
417dD*R                   MOVE $PUPC     W1UPC
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '  or
413 AC                             $pcmd = '*QUICK  '
     C                   exsr      scr01i
700cAC                   if        $ifrcvmth = '3' and $ittype = ' '
700cAc                   exsr      scr01bi
700cAc                   endif
417 A*
417 A*    Confirm Retail UPC on file before continuing with receiving.
417 A*
417 AC                   if        svrupc = 'Y'
417 AC                   exsr      zzrupc
417 AC     error         cabeq     *on           endinz
417 AC                   endif
417 A*
     C                   endif
     *
     C                   if        $pcmd = '*VIEW   '
     **                   EXSR SCR02I
     C                   endif
640bA*
640bA*    Setup command display line 1.
640bA*
640bAC                   select
640bA*
700cAc                   When      Needb1 = *on or Needb2 = *on
700cAC                   eval      cmdln1 = cmdln(8)
650aDC*                  when      itcwgt <> 'N' and immflg = 'Y'
650aMC                   when      itcwgt <> 'N' and itflgd = 'Y'
700bAc                             and KiloLbs = 'P'
640bAC                   eval      cmdln1 = cmdln(1)
700bA*
700bAc                   when      itcwgt <> 'N' and itflgd = 'Y'
700bAc                             and KiloLbs = 'K'
700bAC                   eval      cmdln1 = cmdln(2)
640bA*
650aDC*                  when      itcwgt <> 'N' and immflg = 'N'
650aMC                   when      itcwgt <> 'N' and itflgd = 'N'
700bAc                             and KiloLbs = 'P'
640bAC                   eval      cmdln1 = cmdln(3)
700bA*
700bAc                   when      itcwgt <> 'N' and itflgd = 'N'
700bAc                             and KiloLbs = 'K'
700bAC                   eval      cmdln1 = cmdln(4)
640bA*
650aDC*                  when      itcwgt = 'N' and immflg = 'Y'
650aMC                   when      itcwgt = 'N' and itflgd = 'Y'
640bAC                   eval      cmdln1 = cmdln(5)
640bA*
650aDC*                  when      itcwgt = 'N' and immflg = 'N'
650aMC                   when      itcwgt = 'N' and itflgd = 'N'
640bAC                   eval      cmdln1 = cmdln(6)
640bA*
640bAC                   endsl
640bA*
413 AC                   if        $pcmd <> '*QUICK  '
413 AC                   eval      $pcmd = '*CHANGE '
413 AC                   endif
     C     endinz        endsr
BIRbA*
BIRbA*----------------------------------------------------------------
BIRbA*
BIRbA*  ZZCHKIUSE   Check Retalix P/O If available for receiving.
BIRbA*
BIRbAC     zzchkiuse     begsr
BIRbA*
BIRbA*
BIRbA*    Call w/h validation pgm. If found, call pgm.
BIRbAC                   eval      $rcmd = '*VERIFY2'
BIRbAC                   eval      $rprg = #prog
BIRbAC                   eval      $rcmpn = ' '
BIRbAC                   eval      $rdivn = ' '
BIRbAC                   eval      $rdptn = ' '
BIRbAC                   eval      $rwhsn = ' '
BIRbAC                   eval      $rwhse = $pwhse
BIRbAC                   eval      $rvndn = ' '
BIRbAC                   eval      $rpo   = ' '
BIRbAC                   eval      $rrtn = ' '
BIRbAC                   eval      $rerm = ' '
BIRbAC                   call      'HHW900'
BIRbAC                   parm                    $rparm
BIRbA*
BIRbAC                   if        $rrtn = '*OK'
BIRbAC                   eval      $rcmd = '*INUSE1 '
BIRbAC                   eval      $rprg  = #prog
BIRbAC                   eval      $rrtn  = ' '
BIRbAC                   eval      $rerm  = ' '
BIRbAC                   evalr     $rvndn = %trimr(phvzp1)
BIRbAC                   eval      $rpo   = $ppo
SGCcAC                   eval      $rbfcflib = f1library
BIRbAC                   call      'HPOIUSE'
BIRbAC                   parm                    $rparm
BIRbAC                   if        $rrtn <> '*OK'
BIRbAC                   eval      error = '1'
BIRbA*
BIRbAC                   select
BIRbAC                   when      $rrtn = '*NOTFND'
BIRbAC                   eval      errmsg = *blanks
BIRbAC                   eval      errmsg = 'P/O: '
BIRbAC                             + %trim($ppo)
BIRbAC                             + ' not found on Retalix.Receipt cancelled'
BIRbAC                   exsr      zm0105p
BIRbAC                   eval      $prtn = '*PGMQ   '
BIRbA*
BIRbAC                   when      $rrtn = '*RCDLOCK'
BIRbAC                   eval      errmsg = *blanks
BIRbAC                   eval      errmsg = 'P/O: '
BIRbAC                             + %trim($ppo)
BIRbAC                             + ' rcd locked in Retalix. Wait 5 min. Try'
BIRbAC                             + ' again.'
BIRbAC                   exsr      zm0105p
BIRbAC                   eval      $prtn = '*PGMQ   '
BIRbA*
BIRbAC                   when      $rrtn = '*RTXIUSE'
BIRbAC                   eval      errmsg = %replace($ppo:errmsg:1:9)
BIRbAC                   eval      errmsg = %replace($rpousr:errmsg:10:10)
BIRbAC                   eval      errmsg = %replace($pitem:errmsg:20:15)
BIRbAC                   exsr      zm23215
BIRbAC                   eval      $prtn = '*PGMQ   '
BIRbAC                   endsl
BIRbA*
BIRbAC                   endif
BIRbA*
BIRbAC                   endif
BIRbA*
BIRbAC                   endsr
BIRbA*
415dA*----------------------------------------------------------------
415dA*
415dA*  ZZDLCW   Delete catchweight entry records.
415dA*
415dAC     zzdlcw        begsr
415dA*
415dAC                   eval      $mwhs3 = $pwhse
415dAC                   eval      $mpo3 = $ppo
415dAC                   eval      $mseq = $pseq
415dAC                   call      'DELTMPCW'
415dAC                   parm                    $mparm
650tAc                   exsr      zzuci
415dA*
415dAC                   endsr
RNZaA*
RNZaA*----------------------------------------------------------------
RNZaA*
RNZaA*  ZZGTPDM  Get P/O Detail Misc. file
RNZaA*
RNZaAC     ZZGTPDM       Begsr
RNZaAC*
RNZaAC     fileky        chain     podtlm
RNZaAC                   if        not %found(podtlm)
RNZaAC                   eval      pdmitm = ' '
RNZaAC                   eval      pdmpom = ' '
RNZaAC                   eval      pdmods = ' '
RNZaAC                   eval      pdmms1 = ' '
RNZaAC                   eval      pdmms2 = ' '
RNZaAC                   eval      pdmms3 = ' '
RNZaAC                   eval      pdmms4 = ' '
RNZaAC                   eval      pdmms5 = ' '
RNZaAC                   eval      podm1_rtx = ' '
RNZaAC                   eval      rtxdm1_dnpckm = 0
RNZbAC                   eval      rtxdm1_dniaov = 'N'
RNZbAC                   eval      rtxdm1_dncwcd = 'N'
RNZaAC                   eval      rtxdm1_dnwtiw = 0
RNZaAC                   eval      rtxdm1_dncbec = 0
RNZaAC                   eval      podm2_rtx = ' '
RNZaAC                   eval      podm3_rtx = ' '
RNZaAC                   eval      podm4_rtx = ' '
RNZaAC                   eval      podm5_rtx = ' '
RNZaAC                   else
RNZaA*      Load P/O Detail Misc. record into Host Interface map fields.
RNZaAC                   eval      podm1_rtx = pdmms1
RNZaAC                   eval      podm2_rtx = pdmms2
RNZaAC                   eval      podm3_rtx = pdmms3
RNZaAC                   eval      podm4_rtx = pdmms4
RNZaAC                   eval      podm5_rtx = pdmms5
RNZaAC                   endif
RNZaAC*
RNZaAC                   Endsr
RNZaAC*
     *----------------------------------------------------------------
     *
221 A*  ZZLCNS   Get use generic license option
     *
221 AC     zzlcns        begsr
     *
221 A*   Get use generic license option.
221 AC                   eval      lflag = *off
416aAC                   eval      svexck = *on
416dAC                   eval      svcwen = *on
416dAC                   eval      svcwtp = *on
416dAC                   eval      svcwfr = 'N'
417 AC                   eval      svrupc = 'N'
221 AC                   eval      ocode = '*RCVLBL '
413bAC                   eval      wkwhse = $pwhse
     *
221 AC     opkey         chain     options                            79
DRYcAC                   if        client = Dairyland
DRYcAC                   eval      opcwen = '2'
DRYcAC                   eval      opcwtp = '2'
DRYcAC                   eval      opcwfr = 'Y'
DRYcAC                   endif
221 AC                   if        not *in79
221 AC                   if        opplcn = 'Y'
221 AC                   eval      lflag = *on
221 AC                   endif
416aAC                   eval      svexck = opexck
416dAC                   eval      svcwen = opcwen
416dAC                   eval      svcwtp = opcwtp
416dAC                   eval      svcwfr = opcwfr
417 AC                   eval      svrupc = oprupc
760cAC                   eval      svnupc = opnupc
221 AC                   endif
     *
221 AC                   endsr
417 A*
640eA*----------------------------------------------------------------
640eA*
640eA*  ZZmfrdates  Set manufactures dates
640eA*
640eAC     zzmfrdates    begsr
640eAc                   select
640eAc                   when      $lmfrdat > 0 and $ldecvalue > ' '
640eA*
640eA*  Calculate Mfg Exp    date.(Mfg date + Mfg Shelf life days)
640eA*

640eAC                   eval      $cvcmd = '*MDYCMD '
640eAC                   move      $lmfrdat      $cvd6i
640eAC                   call      @cvtdt
640eAC                   parm                    $cvtdt
640eAC                   move      $cvd8o        mfgdte

640eA*  Create mfg expiration date mfgdate + mfg shelf life days
640eA
640eAC                   call      'CLCDUR2'
640eAC                   parm      '*ADD'        $cdcmd
640eAC                   parm      mfgdte        $cddatein
640eAC                   parm      0             $cdtimein
640eAC                   parm      0             $cdyears
640eAC                   parm      0             $cdmonths
640eAC                   parm      immday        $cddays
640eAC                   parm      0             $cdhours
640eAC                   parm      0             $cdminutes
640eAC                   parm      0             $cdseconds
640eAC     mexpd         parm      0             $cddateout
640eAC                   parm      0             $cdtimeout


640eA*
640eA*  Calculate Mfg date if mfg exp date is entered
640eA*
640eAc                   when      $lexpdat > 0 and $ldecvalue > ' '

640eA*
640eA*  Calculate Mfg date.(Mfg exp date - Mfg Shelf life days)
640eA*

640eAC                   eval      $cvcmd = '*MDYCMD '
640eAC                   move      $lexpdat      $cvd6i
640eAC                   call      @cvtdt
640eAC                   parm                    $cvtdt
640eAC                   move      $cvd8o        mexpd
640iAC                   eval      wkmday = immday
YHAdA*  Use By date -1 to be used as mfg shelf life days
YHAdAC                   if        client = yhata
YHAdAC                   if        immday = 0
YHAdAC                             and imoday > 0
YHAdAC                   eval      wkmday = imoday - 1
YHAdAC                   endif
YHAdAC                   endif

640eA*  Create mfg date - date mfg exp date - mfg shelf life days
640eA
640eAC                   call      'CLCDUR2'
640eAC                   parm      '*SUB'        $cdcmd
640eAC                   parm      mexpd         $cddatein
640eAC                   parm      0             $cdtimein
640eAC                   parm      0             $cdyears
640eAC                   parm      0             $cdmonths
640iDC*                  parm      immday        $cddays
640iMC                   parm      wkmday        $cddays
640eAC                   parm      0             $cdhours
640eAC                   parm      0             $cdminutes
640eAC                   parm      0             $cdseconds
640eAC     mfgdte        parm      0             $cddateout
640eAC                   parm      0             $cdtimeout
640iDc*                  if        immday = 0
640iMc                   if        wkmday = 0
     c                   eval      mfgdte = 0
640eAc                   endif

640eAc                   when      w1mfdt > 0 and itflgd = 'Y'
640eA*
640eA*  Calculate Mfg Exp    date.(Mfg date + Mfg Shelf life days)
640eA*

640eAC                   eval      $cvcmd = '*MDYCMD '
640eAC                   move      w1mfdt        $cvd6i
640eAC                   call      @cvtdt
640eAC                   parm                    $cvtdt
640eAC                   move      $cvd8o        mfgdte

640eA*  Create mfg expiration date mfgdate + mfg shelf life days
640eA
640eAC                   call      'CLCDUR2'
640eAC                   parm      '*ADD'        $cdcmd
640eAC                   parm      mfgdte        $cddatein
640eAC                   parm      0             $cdtimein
640eAC                   parm      0             $cdyears
640eAC                   parm      0             $cdmonths
640eAC                   parm      immday        $cddays
640eAC                   parm      0             $cdhours
640eAC                   parm      0             $cdminutes
640eAC                   parm      0             $cdseconds
640eAC     mexpd         parm      0             $cddateout
640eAC                   parm      0             $cdtimeout

640eAc                   when      w1exdt > 0

640eA*
640eA*  Calculate Mfg date.(Mfg exp date - Mfg Shelf life days)
640eA*

640eAC                   eval      $cvcmd = '*MDYCMD '
640eAC                   move      w1exdt        $cvd6i
640eAC                   call      @cvtdt
640eAC                   parm                    $cvtdt
630eAC                   move      $cvd8o        mexpd
640iAC                   eval      wkmday = immday
YHAdA*  Use By date -1 to be used as mfg shelf life days
YHAdAC                   if        client = yhata
YHAdAC                   if        immday = 0
YHAdAC                             and imoday > 0
YHAdAC                   eval      wkmday = imoday - 1
YHAdAC                   endif
YHAdAC                   endif

640eA*  Create mfg date - date mfg exp date - mfg shelf life days
640eA
640eAC                   call      'CLCDUR2'
640eAC                   parm      '*SUB'        $cdcmd
640eAC                   parm      mexpd         $cddatein
640eAC                   parm      0             $cdtimein
640eAC                   parm      0             $cdyears
640eAC                   parm      0             $cdmonths
640iDC*                  parm      immday        $cddays
640iMC                   parm      wkmday        $cddays
640eAC                   parm      0             $cdhours
640eAC                   parm      0             $cdminutes
640eAC                   parm      0             $cdseconds
640eAC     mfgdte        parm      0             $cddateout
640eAC                   parm      0             $cdtimeout

640iDc*                  if        immday = 0
640iMc                   if        wkmday = 0
     c                   eval      mfgdte = 0
640eAc                   endif

640eAc                   endsl
640eAC                   endsr
     *----------------------------------------------------------------
     *
GFCaA*  ZZPWD    Get password for expirtation date override
     *
     C     zzpwd         begsr
     *
     C                   eval      w1pwrd = *blanks
     C                   exfmt     paswrd
     C                   call      @pwd
     C                   parm      'PO232'       $PGMID           10
     C                   parm      w1pwrd        $PGMOPT          20
     C                   parm      'BFC'         $PUSR            10
     C                   parm                    $PRTN             8
     *
     C                   endsr
650gA*----------------------------------------------------------------
650gA*
650gA*  ZZRCVPOCHECK check for started RCVPO Transaction
650gA*
650gAC     zzrcvpocheck  begsr
650gA*
650gA*  See if RCVPO transaction is status 2 - start new if needed
650gA*
650gAC                   call      @crtrcv
650gAC                   parm      '*PO'         $lcmdr           10
650gAC                   parm      '*CHECK '     $lsubcmd         10
650gAC                   parm      $pwhse        @lwhse            3 0
650gAC                   parm      0             $lpcs             5 0
650gAC                   parm      0             $lpallets         5 0
650gAC                   parm                    $lsavetrn         7 0
650gAC                   parm                    $ppo              9
650gAC                   parm      itstyp        $litstyp          1
650gAC                   parm      itwhdp        $litwhdp          5
650gAC                   parm                    $lrtnr           10
650gAC                   endsr
650gA*----------------------------------------------------------------
650gA*
650gA*  ZZRCVPOCLOSE  Close RCVPO transaction.
650gA*
650gAC     zzrcvpoclose  begsr
650gAc                   if        rcvpocomplete

650gAc                   select
650gAc                   when      $lrq1 > 0
650gAc                   eval      poppcs = $lrq1
650gAc                   when      $lrq2 > 0
650gAc                   eval      poppcs = $lrq2
650gAc                   when      $lrq3 > 0
650gAc                   eval      poppcs = $lrq3
650gAc                   endsl

650gAC                   call      @crtrcv
650gAC                   parm      '*PO'         $lcmdr           10
650gAC                   parm      '*COMPLETE'   $lsubcmd         10
650gAC                   parm      $pwhse        @lwhse            3 0
650gAC                   parm      poppcs        $lpcs             5 0
650gAC                   parm      $lrpal        $lpallets         5 0
650gAC                   parm                    $lsavetrn         7 0
650gAC                   parm                    $ppo              9
650gAC                   parm      $itstyp       $litstyp          1
650gAC                   parm      $itwhdp       $litwhdp          5
650gAC                   parm                    $lrtnr           10

650gAc                   else

650gAC                   call      @crtrcv
650gAC                   parm      '*PO'         $lcmdr           10
650gAC                   parm      '*CLOSE'      $lsubcmd         10
650gAC                   parm      $pwhse        @lwhse            3 0
650gAC                   parm      0             $lpcs             5 0
650gAC                   parm      0             $lpallets         5 0
650gAC                   parm                    $lsavetrn         7 0
650gAC                   parm                    $ppo              9
650gAC                   parm      $itstyp       $litstyp          1
650gAC                   parm      $itwhdp       $litwhdp          5
650gAC                   parm                    $lrtnr           10
650gAc                   endif
650gAC                   endsr
417 A*----------------------------------------------------------------
417 A*
417 A*  ZZRUPC   Verify Retail UPC on file for item.
417 A*
417 AC     zzrupc        begsr
417 A*
417 AC                   eval      $mcmd = '*VERIFY '
417 AC                   eval      $mwhs3 = $pwhse
417 AC                   eval      $mpo3 = $ppo
417 AC                   eval      $mseq = $pseq
417 AC                   eval      $mitm3 = $pitem
417 A*
417 AC                   call      'PO245'
417 AC                   parm                    $mparm
417 A*
417 AC                   select
417 AC                   when      $mrtn = '*EXIT   '  or
417 AC                             $mrtn = '*CANCEL '
417 AC                   eval      error = *on
417 A*
417 AC                   endsl
417 A*
417 AC                   endsr
     *
650rA*----------------------------------------------------------------
650rA*
650rA*  ZZSTRT  Start timer
650rA*
650rAC     zzstrt        begsr
     *
650rAc                   eval      pgtpgm = #prog
650rAc                   eval      pgtscr = nxtscr
650rAc                   if        pgtnsc = 'PO236     '
650rAc                   eval      pgtscr = pgtnsc
650rAc                   endif
650rAC                   callp     getmicrotime(currstampuc:currstampsys)
650rAc                   eval      pgtStrts = currstampsys
     *
650rAC     endzzs        endsr
     *
413a *----------------------------------------------------------------
413a *
413aA*  ZZTIHI   Get use Preferred or 1st tie hi record.
413a *
413aAC     zztihi        begsr
413a *
413aA*  GET TIE HI, PREFERRED OR 1ST RECORD.
413aAC                   eval      done = *off
413aAC                   eval      wotie = 0
413aAC                   eval      wohi = 0
413aAC                   eval      svtie = 0
413aAC                   eval      svhi = 0
413aAC     partk2        setll     itemdef
413aAC                   dou       done = *on
413aAC     partk2        reade     idrec                                  79
413aAC                   if        *in79
413aAC                   eval      done = *on
413aAC                   else
413aAC                   if        svtie = 0  and
413aAC                             svhi = 0
413aAC                   eval      svtie = idtie
413aAC                   eval      svhi = idhigh
413aAC                   endif
413aAC                   if        idpref = 'Y'
413aAC                   eval      wotie = idtie
413aAC                   eval      wohi = idhigh
413aAC                   eval      done = *on
413aAC                   endif
413aAC                   endif
413aAC                   enddo
413aAC                   if        wotie = 0  and
413aAC                             wohi = 0
413aAC                   eval      wotie = svtie
413aAC                   eval      wohi = svhi
413aAC                   endif
413a *
FKLcAc                   if        client = finkle
FKLcAC                   eval      *in86 = *on
FKLcAC                   else
FKLcAC                   eval      *in86 = *off
FKLcAC                   endif
413aAC                   endsr
417cA*
417cA*----------------------------------------------------------------
417cA*
417cA*  ZZTTLE   Accumlate total exception quantity.
417cA*
417cAC     zzttle        begsr
417cA*
417cAC     fileky        setll     poexcp
417cAC                   dow       forevr = forevr
417cAC     fileky        reade     poexcp                                 76
417cAC                   select
417cAC                   when      *in76
417cAC                   leave
417cA*
417cAC                   other
417cAC                   add       peqex1        svqrc1
417cAC                   add       peqex2        svqrc2
417cAC                   add       peqex3        svqrc3
417cAC                   endsl
417cAC                   enddo
417cA*
417cAC                   endsr
413a *
214 A*----------------------------------------------------------------
214 A*
214 A*  ZZUOM    Get Unit Of Measure Normal, Breakdown1, Breakdown2.
214 A*
214 AC     zzuom         begsr
214 A*
214 A*   Get Unit of Measures.
214 A*    *IN94=Protect & non-display breakdown1 unit of measure
214 A*    *IN93=Protect & non-display breakdown2 unit of measure
214 A*
214 A*
214 AC                   eval      *in94 = *off
214 AC                   eval      *in93 = *off
415fAC                   eval      wolbl = *blanks
219 AC                   eval      woitem = *blanks
219 AC                   eval      wodsc1 = *blanks
219 AC                   eval      wodsc2 = *blanks
     *
414 AC                   eval      ssbflg = *off
414 AC                   eval      wolbls = *blanks
414 AC                   eval      wositm = *blanks
415fAC                   eval      w1um1 = *blanks
415fAC                   eval      w1um2 = *blanks
415fAC                   eval      w1um3 = *blanks
     *  Food Pro - Do not allow breakdown qty entered.
FPRaAC                   if        client = FoodPro
FPRaAC                   eval      *in94 = *on
FPRaAC                   eval      *in93 = *on
FPRaAC                   endif
     *
640hA * add dri to get data from itemfld
640hA /free
640hA       exsr clr$item;

640hA       $itWhse = $pwhse;
640hA       $ititem = $litem;

640hA       $dricommand = '*ITEM';
640hA       $drisubcmd  = '%GETALL';
640hA       $drisys2upd = 'D';
640hA       chk4err = *on;
640hA       zmflag  = *off;
640hA       exsr zzzdricop;
640hA       if error = *on;
640hA         $ifucicde = ' ';
640hA         $ifrcvmth = ' ';
640hA         $ifbrdflg = ' ';
640hA       endif;
640hA       if $ifbrdflg = 'Y';
640hA         *in74 = *off;
640hA       else;
640hA         *in74 = *on;
640hA       endif;
740dD       //if $ifsltmth = '3' or
650lA       if $ifsltmth = '3' and
650lA          $ifucicde <> '1'and $ifrcvmth <> '2';
650lA         *in73 = *off;
650lA       else;
650lA         *in73 = *on;
650lA       endif;
640hA /end-free
214 AC     ittkey        chain     piritem                            75
214 AC                   if        *in75
214 AC                   eval      *in94 = *on
214 AC                   eval      *in93 = *on
     C                   eval      itdesc = *blanks
     C                   eval      itpdsc = *blanks
640bAC                   eval      itcwgt = 'N'
413aAC                   eval      wopdsc = *blanks
415fAC                   eval      wolbl = lbl(4)
415fAC                   movel     desc(8)       woitem
415fAC     '-'           cat       woitem:1      woitem
415fAC     $pitem        cat       woitem:1      woitem
214 AC                   goto      enduom
214 AC                   else
RNZaAC*
RNZaAC                   if        client = Renzi
FKL AC                             or client = Finkle
SOF AC                             or client = SoFo
RNZaAC                   if        pditem = rtxall9item
RNZaAC                   eval      itwhdp = rtxdm1_dnwhdp
RNZaAC                   eval      itdesc = pdmods
RNZaAC                   eval      itcwgt = rtxdm1_dncwcd
RNZaAC                   eval      itswgt = rtxdm1_dnwtiw
RNZaAC                   eval      itcube = rtxdm1_dncbec
RNZaAC                   endif
RNZaAC                   endif
RNZaAC*
413aAC                   eval      wopdsc = itpdsc
413aAC                   exsr      zztihi
415fA*
415fA*  Save information about selected item (Item that was sent in)
415fA*
YHAeAC                   eval      #oven# = itven#
415fAC                   eval      #otype = ittype
415fAC                   eval      #oitem = ititem
415fAC                   eval      #odesc = itdesc
415fAC                   eval      #opdsc = itpdsc
416fAC                   eval      #oswgt = itswgt
415fAC                   eval      #oum1 = itum1
415fAC                   eval      #oum2 = itum2
416fAC                   eval      #oum2q = itumq2
416fAC                   eval      #oswt2 = 0
416fAC                   if        #oum2q <> 0
416fAC     itswgt        div(h)    #oum2q        #oswt2
416fAC                   endif
415fAC                   eval      #oum3 = itum3
416fAC                   eval      #oum3q = itumq3
416fAC                   eval      #oswt3 = 0
416fAC                   if        #oum3q <> 0
416fAC     itswgt        div(h)    #oum2q        #oswt3
416fAC     #oswt3        div(h)    #oum3q        #oswt3
416fAC                   endif
RNZ A*
RNZ AC                   if        client = Renzi
RNZ A*   Force standard-wgt catchwgt to non-catchwgt.
RNZ AC                   if        itcwgt = 'S'
RNZ AC                   eval      itcwgt = 'N'
RNZ AC                   endif
RNZ A*
RNZ AC                   endif
415fA*
415fA*   Get short UOM descriptions for selected item.
415fA*
415fAC                   eval      #osu1 = *blanks
415fAC                   eval      #osu2 = *blanks
415fAC                   eval      #osu3 = *blanks
415fA*
415fAC                   if        itum1 <> *blanks
415fAC     itum1         chain     unmesr                             77
415fAC                   if        not *in79
415fAC                   eval      #osu1 = umshrt
415fAC                   else
415fAC                   movel     itum1         #osu1
415fAC                   endif
415fAC                   endif
415fA*
415fAC                   if        itum2 <> *blanks
415fAC     itum2         chain     unmesr                             77
415fAC                   if        not *in79
415fAC                   eval      #osu2 = umshrt
415fAC                   else
415fAC                   movel     itum2         #osu2
415fAC                   endif
415fAC                   endif
415fA*
415fAC                   if        itum3 <> *blanks
415fAC     itum3         chain     unmesr                             77
415fAC                   if        not *in79
415fAC                   eval      #osu3 = umshrt
415fAC                   else
415fAC                   movel     itum3         #osu3
415fAC                   endif
415fAC                   endif
415fA*
415fA*   Initialize base information.
415fA*
415fAC                   eval      #bitem = ititem
417tAC                   eval      #sitem = ititem
415fAC                   eval      #bityp = ittype
415fAC                   eval      #bdesc = itdesc
415fAC                   eval      #bpdsc = itpdsc
415fAC                   eval      #bum1 = itum1
415fAC                   eval      #bum2 = itum2
415fAC                   eval      #bum3 = itum3
415fAC                   eval      #bsu1 = #osu1
415fAC                   eval      #bsu2 = #osu2
415fAC                   eval      #bsu3 = #osu3
414 A*
414 A*   Get SSB item, if one exists
414 A*
414 AC                   if        ittype = ' '
414 AC                   call      'GETSSB'
414 AC                   parm      itwhse        $gwhse            3 0
414 AC                   parm      ititem        $gitem           15
414 AC                   parm      ' '           #bitem           15
414 AC                   parm                    #bdesc           30
414 AC                   parm                    #bpdsc           15
414 AC                   parm                    #bwhdp            5
414 AC                   parm                    #bstyp            1
414 AC                   parm                    #bum              2
414 AC                   parm                    #bum2             2
414 AC                   parm                    #bumq2            3 0
414 AC                   parm                    #bum3             2
414 AC                   parm                    #bumq3            3 0
414 AC                   parm                    #brtn             8
414 A*
414 AC                   if        #brtn = '*FOUND  '
414 AC                   eval      ssbflg = *on
415fAC                   eval      #bityp = 'S'
414 AC                   endif
414 AC                   endif
415fA*
415fA*  If selected item is a Contract, Alias, SSB or Breakdown item . . .
415fA*    Then get corresponding Base item.
415fA*
415fAC                   if        ittype = 'C'  or
415fAC                             ittype = 'A'  or
415fAC                             ittype = 'S'  or
415fAC                             ittype = 'B'
415fAC                   call      'GETBASE'
415fAC                   parm      itwhse        $gwhse
415fAC                   parm      ititem        $gitem
415fAC                   parm      ' '           #bitem
415fAC                   parm                    #bityp            1
415fAC                   parm                    #bdesc
415fAC                   parm                    #bpdsc
415fAC                   parm                    #bwhdp
415fAC                   parm                    #bstyp
415fAC                   parm                    #bum1             2
415fAC                   parm                    #bum2
415fAC                   parm                    #bumq2
415fAC                   parm                    #bum3
415fAC                   parm                    #bumq3
415fAC                   parm      ' '           #bcitm           15
415fAC                   parm                    #bctyp            1
415fAC                   parm                    #bcdsc           30
415fAC                   parm                    #bcpds           15
415fAC                   parm                    #bcwdp            5
415fAC                   parm                    #bcstp            1
415fAC                   parm                    #bcum1            2
415fAC                   parm                    #bcum2            2
415fAC                   parm                    #bcuq2            3 0
415fAC                   parm                    #bcum3            2
415fAC                   parm                    #bcuq3            3 0
415fAC                   parm                    #brtn
415fAC                   endif
417tA*   Get slot item.
417tAC                   call      @getsi
417tAC                   parm      itwhse        $gwhse
417tAC                   parm      ititem        $gitem
417tAC                   parm      ' '           #sitem           15
417tAC                   parm                    #sityp            1
417tAC                   parm                    #sdesc           30
417tAC                   parm                    #spdsc           15
417tAC                   parm                    #srtn            10
417tAC                   parm                    #smsg            60
415fA*
415fA*   Get short UOM descriptions for base item.
415fA*
415fAC                   if        #bum1 <> #oum1
415fAC     #bum1         chain     unmesr                             77
415fAC                   if        not *in79
415fAC                   eval      #bsu1 = umshrt
415fAC                   else
415fAC                   movel     #bum1         #bsu1
415fAC                   endif
415fAC                   endif
415fA*
415fAC                   if        #bum2 <> #oum2
415fAC     #bum2         chain     unmesr                             77
415fAC                   if        not *in79
415fAC                   eval      #bsu2 = umshrt
415fAC                   else
415fAC                   movel     #bum2         #bsu2
415fAC                   endif
415fAC                   endif
     *
415fAC                   if        #bum3 <> #oum2
415fAC     #bum3         chain     unmesr                             77
415fAC                   if        not *in79
415fAC                   eval      #bsu3 = umshrt
415fAC                   else
415fAC                   movel     #bum3         #bsu3
415fAC                   endif
415fAC                   endif
     *
415fA*
415fA*   Set indicators to protect breakdown quantities.
415fA*
214 AC                   if        itflg1 = 'N'  and
700aDC*                            ssbflg = *off
700aMC                             ssbflg = *off  or
700aAC                             itflg1 = 'N'  and
700aAC                             ssbflg = *on  and
700aAC                             itum2 = *blanks
214 AC                   eval      *in94 = *on
214 AC                   endif
214 AC                   if        itflg2 = 'N'  and
414 AC                             ssbflg = *off  or
414 AC                             itflg2 = 'N'  and
414 AC                             ssbflg = *on  and
414 AC                             itum3 = *blanks
214 AC                   eval      *in93 = *on
214 AC                   endif
415fA*
415fA*   When dealing with an SSB item, the quantity is actually
415fA*   received into the "normal" screen quantity. If a third
415fA*   breakdown is allowed, then that will be received into the
415fA*   breakdown 1 quantity on the screen. The second breakdown
415fA*   screen quantity is always protected for an SSB item.
415fA*
415fAC                   if        ittype = 'S'  and
415fAC                             itflg2 = 'Y'
415fAC                   eval      *in94 = *off
650bAc                   else
650bAc                   if        ittype = 'S'
650bAc                   eval      *in94 = *on
650bAc                   endif
415fAC                   endif
415fA*
415fAC                   if        ittype = 'S'
415fAC                   eval      *in93 = *on
415fAC                   endif
415fA*
415fA*   Create label for selected item
415fA*
415fA*     If selected item is a SSB item . . .
415fA*        Then display the breakdown 1 UOM.
415fA*        Otherwise use the normal UOM.
415fA*
415fA*     Note: Except for the description, the SSB fields
415fA*           should be identical to its Base item's fields.
415fA*
415fAC                   movea     lbl(1)        a13
415fAC                   if        #otype = 'S'
415fAC                   movea     #osu2         a13(7)
415fAC                   else
415fAC                   movea     #osu1         a13(7)
415fAC                   endif
415fAC                   movea     a13           wolbl
415fAC     wolbl         cat       ')':0         wolbl
415fAC                   move      ':'           wolbl
415fA*
415fA*   Create description for selected item
415fA*
415fAC                   movea     typ(1)        a10
415fAC                   movea     #otype        a10(8)
415fAC                   movea     a10           temp10
415fA*
415fAC     #oitem        cat       temp10:1      woitem
415fAC     woitem        cat       '-':1         woitem
415fAC     woitem        cat       #odesc:1      woitem
415fA*
415fA*   Create label and description for corresponding item.
415fA*
415fAC                   select
415fA*
415fA*     If selected item is a Base item . . .
415fA*        Then display its corresponding SSB item (if any)
415fA*        Otherwise display nothing.
415fA*
415fAC                   when      #otype = ' '
415fAC                   if        #bityp = 'S'
415fAC                   movea     lbl(3)        a13
415fAC                   movea     #bsu2         a13(6)
415fAC                   movea     a13           wolbls
415fAC     wolbls        cat       ')':0         wolbls
415fAC                   move      ':'           wolbls
415fA*
415fAC                   movea     typ(1)        a10
415fAC                   movea     #bityp        a10(8)
415fAC                   movea     a10           temp10
415fA*
417tDC**   #bitem        cat       temp10:1      wositm
417tMC     #sitem        cat       temp10:1      wositm
415fAC     wositm        cat       '-':1         wositm
415fAC     wositm        cat       #bdesc:1      wositm
415fAC                   endif
415fA*
415fA*     If selected item is a Breakdown item . . .
415fA*        Then display its corresponding Base item.
415fA*             Note: UOM is not applicable in this situation.
415fA*
415fAC                   when      #otype = 'B'
415fAC                   movea     lbl(2)        a13
415fAC                   movea     'N/A'         a13(7)
415fAC                   movea     a13           wolbls
415fAC     wolbls        cat       ')':0         wolbls
415fAC                   move      ':'           wolbls
415fA*
415fAC                   movea     typ(1)        a10
415fAC                   movea     #bityp        a10(8)
415fAC                   movea     a10           temp10
415fA*
417tDC**   #bitem        cat       temp10:1      wositm
417tMC     #sitem        cat       temp10:1      wositm
415fAC     wositm        cat       '-':1         wositm
415fAC     wositm        cat       #bdesc:1      wositm
415fA*
415fA*     Otherwise . . .
415fA*        Then display its corresponding Base item w/UOM.
415fA*             Note: UOM of Base should match UOM of selected item.
415fA*
415fAC                   other
415fAC                   movea     lbl(2)        a13
415fAC                   movea     #bsu1         a13(7)
415fAC                   movea     a13           wolbls
415fAC     wolbls        cat       ')':0         wolbls
415fAC                   move      ':'           wolbls
415fA*
415fAC                   movea     typ(1)        a10
415fAC                   movea     #bityp        a10(8)
415fAC                   movea     a10           temp10
415fA*
417tDC**   #bitem        cat       temp10:1      wositm
417tMC     #sitem        cat       temp10:1      wositm
415fAC     wositm        cat       '-':1         wositm
415fAC     wositm        cat       #bdesc:1      wositm
415fA*
415fAC                   endsl
416bA*
416bA*   Determine item number going into slot.
416bA*
416bAC                   if        #otype = ' '  or
416bAC                             #otype = 'B'
416bAC                   eval      #sitem = #oitem
417tDC**                 else
417tDC**                 eval      #sitem = #bitem
416bAC                   endif
415fA*
415fA*   Get extend description headings if being used.
415fA*
219 AC                   if        uxflag = *off
415fD**                   MOVELW1ITEM    $IITEM
415fD**                   MOVELITDESC    $IDESC
415fD**                   MOVELITPDSC    $IPDSC
415fD**                   MOVE *BLANKS   $ISTR
415fD**                   CALL @FMTIT
415fD**                   PARM           $IITEM 15
415fD**                   PARM           $IDESC 30
415fD**                   PARM           $IPDSC 15
415fD**                   PARM           $ISTR  70
415fD**                   MOVEL$ISTR     WOITEM
219 AC                   else
415fD**                   MOVELW1ITEM    WOITEM
219 AC     idkey         chain     itemdsc                            79
219 AC                   if        not *in79
RNZaAC*
RNZaAC                   if        client = Renzi
FKL AC                             or client = Finkle
SOF AC                             or client = SoFo
RNZaAC                   if        pditem = rtxall9item
RNZaAC                   eval      ixdsc1 = pdmods
RNZaAC                   endif
RNZaAC                   endif
RNZaAC*
219 AC                   eval      wodsc1 = ixdsc1
219 AC                   eval      wodsc2 = ixdsc2
219 AC                   endif
219 AC                   endif
415fA*
415fA*   Initialize unit of measure names for quantity fields.
415fA*
415fAC                   if        #otype = 'S'
415fAC                   eval      w1um1 = #osu2
415fAC                   else
415fAC                   eval      w1um1 = #osu1
415fAC                   endif
415fA*
415fAC                   if        not *in94
415fAC                   if        #otype = 'S'
415fAC                   eval      w1um2 = #osu3
415fAC                   else
415fAC                   eval      w1um2 = #osu2
415fAC                   endif
415fAC                   endif
415fA*
415fAC                   if        not *in93
415fAC                   eval      w1um3 = #osu3
415fAC                   endif
415fA*
415fA*   Determine if this item should be put away into warehouse.
415fA*   An '*' in last position of designation says that the item
415fA*   will NOT be put away into the warehouse.
415fA*
409 AC                   move      itdesg        iatest
409 AC                   if        iatest = '*'
409 AC                   eval      iaflag = *on
409 AC                   eval      *in64 = *off
409 AC                   else
409 AC                   eval      iaflag = *off
409 AC                   eval      *in64 = *on
409 AC                   endif
500aA
500aA*  ... Or department isn't live (this overrides iaflag).
500aA
500aAC                   call      'CHKLIVE'
640aAC                   parm      $pwhse        $swhse
500aAC                   parm                    itwhdp
500aAC                   parm                    livestat          8
500aA
500aAC                   if        livestat = '*NOTLIVE'
500aAC                   eval      *in65 = *off
500aAC                   eval      iaflag = *off
500aAC                   eval      *in64 = *on
500aAC                   else
500aAC                   eval      *in65 = *on
500aAC                   endif
415fA*
415fA*    The following EndIf is for statment *IN75 IFEQ *ON, which
415fA*    comes after the chain to PIRITEM.
415fA*
214 AC                   endif
415fD**
415fD**         ITTYPE    IFEQ 'S'
415fD**                   MOVE *OFF      *IN94
415fD**                   ENDIF
415fD**
415fD**         ITUM1     CHAINUNMESR               75
415fD**         *IN75     IFEQ *OFF
415fD**                   MOVE UMSHRT    W1UM1
415fD**                   ELSE
415fD**                   MOVE *BLANKS   W1UM1
415fD**                   ENDIF
415fD**
415fD**         *IN94     IFEQ *OFF
415fD**         ITUM2     CHAINUNMESR               75
415fD**         *IN75     IFEQ *OFF
415fD**                   MOVE UMSHRT    W1UM2
415fD**                   ELSE
415fD**                   MOVE *BLANKS   W1UM2
415fD**                   ENDIF
415fD**                   ENDIF
415fD**
415fD**         *IN93     IFEQ *OFF
415fD**         ITUM3     CHAINUNMESR               75
415fD**         *IN75     IFEQ *OFF
415fD**                   MOVE UMSHRT    W1UM3
415fD**                   ELSE
415fD**                   MOVE *BLANKS   W1UM3
415fD**                   ENDIF
415fD**                   ENDIF
415fD**
415fD**         SSBFLG    IFEQ *ON
415fD**                   MOVEL'SSB ('   WOLBLS
415fD**         WOLBLS    CAT  W1UM2:0   WOLBLS                               -
415fD**         WOLBLS    CAT  ')':0     WOLBLS
415fD**                   MOVE ':'       WOLBLS
415fD**
415fD**                   MOVE *BLANKS   $ISTR
415fD**                   CALL @FMTIT
415fD**                   PARM           #BITEM 15
415fD**                   PARM           #BDESC 30
415fD**                   PARM           #BPDSC 15
415fD**                   PARM           $ISTR  70
415fD**                   MOVEL$ISTR     WOSITM
415fD**
415fD**                   ENDIF
214 AC     enduom        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
640eAc                   if        $ldecvalue = ' '
640eAc                   exsr      zzmfrdates
640eAc                   endif
     C     phkey         chain(n)  pohdr                              79
     C                   if        *in79
     C                   eval      phven = 0
     C                   eval      phvnam = *blanks
     C                   endif
     *
416iAC                   if        immflg = 'Y'
416iA*
416iA*  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
416iA*

417rAC                   eval      $cvcmd = '*MDYCMD '
417rAC                   move      w1mfdt        $cvd6i
417rAC                   call      @cvtdt
417rAC                   parm                    $cvtdt
417rAC                   move      $cvd8o        expd
417rAC                   move      $cvd8o        womfdt

GFCbAC                   if        client = Glazier
417rAC                   eval      imuday = *zeros
417rAC                   endif

417rAC                   call      'CLCDUR2'
417rAC                   parm      '*ADD'        $cdcmd
417rAC                   parm      expd          $cddatein
417rAC                   parm      0             $cdtimein
417rAC                   parm      0             $cdyears
417rAC                   parm      0             $cdmonths
417rAC                   parm      immday        $cddays
417rAC                   parm      0             $cdhours
417rAC                   parm      0             $cdminutes
417rAC                   parm      0             $cdseconds
417rAC                   parm      0             $cddateout
417rAC                   parm      0             $cdtimeout

417rAC                   call      'CLCDUR2'
417rAC                   parm      '*SUB'        $cdcmd
417rAC                   parm      $cddateout    $cddatein
417rAC                   parm      0             $cdtimein
417rAC                   parm      0             $cdyears
417rAC                   parm      0             $cdmonths
417rAC                   parm      imuday        $cddays
417rAC                   parm      0             $cdhours
417rAC                   parm      0             $cdminutes
417rAC                   parm      0             $cdseconds
417rAC     expd          parm      0             $cddateout
417rAC                   parm      0             $cdtimeout

417rAC                   eval      $cvcmd = '*CMDMDY '
417rAC                   move      expd          $cvd8i
417rAC                   call      @cvtdt
417rAC                   parm                    $cvtdt
417rAC                   move      $cvd6o        w1exdt

417rDC**                 move      w1mfdt        g$date
417rDC**                 eval      dtfrmt = 2
417rDC**                 exsr      gtoj$
417rDC**                 eval      mfdtj = g$jd
417rDC**
417rDC**   mfdtj         add       immday        j$jd
417rDC**                 eval      j$jd = j$jd - imuday
417rDC**                 exsr      jtog$
417rDC**                 move      j$date        $cvd6o
417rDC**                 eval      w1exdt = $cvd6o
417rDC**
417rDC**                 eval      $cvcmd = '*MDYCMD '
417rDC**                 move      w1exdt        $cvd6i
417rDC**                 call      @cvtdt
417rDC**                 parm                    $cvtdt
417rDC**                 move      $cvd8o        expd
     *
416iAC                   endif
     *
417gD*          W1UPC     IFNE *BLANKS
417gMC                   if        w1upcd <> *blanks  and
417nMC                             w1upc <> *blanks
414aD**         UPCKY     CHAINUPC                  79
417bD*R         UPCKY     CHAINUPC                 N79
417kD*R         UPCKY2    CHAINUPC2                N79
700cA /free
700cA   select;
700cA     when      w1qrc1 > 0;
700cA       eval      uputyp = 'N';
700cA     when      w1qrc2 > 0;
700cA       eval      uputyp = '1';
700cA     when      w1qrc3 > 0;
700cA       eval      uputyp = '2';
700cA   endsl;
700cA /end-free
700cDC*    upcky3        chain(n)  upc3                               79
700cMC     upcky3U       chain(n)  upc3                               79
221 AC                   if        *in79
221 AC                   eval      upwhse = $pwhse
221 AC                   eval      upitem = $pitem
221 AC                   eval      upupc = w1upc
221 AC                   eval      upven = phven
221 AC                   eval      upvnam = phvnam
221 AC                   eval      upvitm = pdvitm
221 AC                   eval      upbran = *blanks
700cA * load new upc fields
700cA /free
700cA   select;
700cA     when      w1qrc1 > 0;
700cA       eval      upuom = $itum1;
700cA       eval      uputyp = 'N';
700cA     when      w1qrc2 > 0;
700cA       eval      upuom = $itum2;
700cA       eval      uputyp = '1';
700cA     when      w1qrc3 > 0;
700cA       eval      upuom = $itum3;
700cA       eval      uputyp = '2';
700cA   endsl;
700cA   Select;
700cA     when ntype = 'UPC-12';
700cA       upctyp = '1';
700cA     when ntype = 'EAN-13';
700cA       upctyp = '2';
700cA     when ntype = 'GTIN';
700cA       upctyp = '3';
700cA     when ntype = 'SCC-14';
700cA       upctyp = '4';
700cA     when ntype = 'SSCC-18';
700cA       upctyp = '5';
700cA   endsl;
700cA /end-free
221 A*
221 A*   Add record
221 A*
221 AC                   write     uprec                                78
221 AC                   if        *in78
221 AC                   eval      error = *on
221 AC                   exsr      zm71
221 AC                   goto      endup1
221 AC                   endif
     *
KHLaAC                   if        client = kohl
KHLaAC                   exsr      zzupcex
KHLaAC                   endif
     *
221 AC                   endif
BIR Ac                   if        client = birite
CFIaAc                             or client = Colony
BIR Ac                   exsr      outlog
BIR Ac                   endif
223 AC                   endif
     *
     C                   eval      $rven = phven
     C                   eval      $rvnam = phvnam
     *
     *   Call receiving program, if this is a replenishment type
     *   of transfer.(Customer order# blank)
     *
     C                   if        w1exdt = 0
     C                   eval      $rexpd = 0
     C                   else
415bD*R                   MOVE '*MDYCMD '$CVCMD
415bD*R                   MOVE W1EXDT    $CVD6I
415bD*R                   CALL @CVTDT
415bD*R                   PARM           $CVTDT
415bD*R                   MOVE $CVD8O    $REXPD
415bAC                   eval      $rexpd = expd
     C                   endif
219 A*
416fDC                   exsr      zzzcw
650tAC                   if        w1twgt <> 0 and $ifrcvmth <> '2'
650tAC                   exsr      zzucichk
650tAC                   endif
416fD**                   Z-ADD0         W1TWGT
416fD**         W1AVG     IFEQ 'Y'
416fD**         W1DWGT    MULT W1QRC1    W1TWGT
416fD**                   ELSE
416fD**                   Z-ADDW1DWGT    W1TWGT
416fD**                   ENDIF
409 A*
409 A*   If not a FSWMS item, don't put away only update PODTL
409 A*
409 AC                   if        iaflag = *on
409 AC                   eval      $rpo = $ppo
409 AC                   eval      $rseq = $pseq
409 AC                   eval      $rslot = w1slot
409 A*
409 AC                   call      'RC161'
409 AC                   parm      '*RECEIVE'    $rcmd             8
409 AC                   parm                    $rprg            10
409 AC                   parm      '*INTER  '    $rtype            8
409 AC                   parm                    w1whse
409 AC                   parm                    w1item
520cDC*                  parm                    w1qrc1
520cMC                   parm      w1qrc1        $rqrc1            5 0
520cDC*                  parm                    w1qrc2
520cMC                   parm      w1qrc2        $rqrc2            5 0
520cDC*                  parm                    w1qrc3
520cMC                   parm      w1qrc3        $rqrc3            5 0
409 AC                   parm                    $rpo              9
409 AC                   parm                    $rven            11 0
409 AC                   parm                    $rvnam           40
409 AC                   parm                    w2vitm           15
409 AC                   parm      0             $rord             7 0
409 AC                   parm      *blanks       $rrcod            2
409 AC                   parm      *blanks       $rrmem           30
409 AC                   parm                    $rexpd            8 0
409 AC                   parm                    $pdev            10
409 AC                   parm                    $pform           10
409 AC                   parm                    $rslot           12
409 AC                   parm                    $rseq             5 0
409 AC                   parm                    $rrpck            1
218 AC                   parm                    $rplbl            1
409 AC                   parm                    w1twgt            9 2
409 AC                   parm                    $rrq1             5 0
409 AC                   parm                    $rrq2             5 0
409 AC                   parm                    $rrq3             5 0
409 AC                   parm                    $rrpal            3 0
409 AC                   parm                    $rrtn             8
409 AC                   parm                    $rmsg             4
409 A*R If error          PARM           $RMSG   4
409 AC                   if        $rrtn = '*PGMQ   '
409 AC                   eval      error = *on
409 AC                   eval      *in21 = *on
409 AC                   eval      *in01 = *on
409 AC                   goto      endup1
409 AC                   endif
409 AC                   goto      jmpup1
409 AC                   endif
     *
     *
     *   Enter qty per pallet and license.
     *
409 AC                   eval      $lflag = lflag
409 AC                   eval      $lcmd = '*CHANGE '
409 AC                   eval      $lwhse = $pwhse
409 AC                   eval      $lpo = $ppo
409 AC                   eval      $litem = $pitem
409 D*R                   Z-ADD$RRQ1     $LRQ1
409 D*R                   Z-ADD$RRQ2     $LRQ2
409 D*R                   Z-ADD$RRQ3     $LRQ3
409 AC                   eval      $lrq1 = w1qrc1
409 AC                   eval      $lrq2 = w1qrc2
409 AC                   eval      $lrq3 = w1qrc3
409 MC                   z-add     w1plts        $lrpal
409 D*R                   Z-ADD$RRPAL    $LRPAL
409 AC                   eval      $lum1 = w1um1
409 AC                   eval      $lum2 = w1um2
409 AC                   eval      $lum3 = w1um3
409 AC                   eval      $lord = $rord
409 AC                   eval      $lseq = pdseq
409 AC                   eval      $lven = phven
409 AC                   eval      $lvnam = phvnam
409 AC                   eval      $lvitm = pdvitm
409 AC                   eval      $ldwgt = 0
417hA*    Lot tracking item - Pass single char flag to license entry pgm
417hAC                   if        lottrk = '*YES'
417hAC                   eval      $llott = 'Y'
417hAC                   else
417hAC                   eval      $llott = 'N'
417hAC                   endif
417hA*    Lic.tracking item - Pass single char flag to license entry pgm
417hAC                   if        lictrk = '*YES'
417hAC                   eval      $llict = 'Y'
417hAC                   else
417hAC                   eval      $llict = 'N'
417hAC                   endif
417sA*    Convert fifo date into yyyymmdd.
417sAC                   if        w1fifo = 0
417sAC                   eval      wofifo = 0
417sAC                   else
417sAC                   eval      $cvcmd = '*MDYCMD '
417sAC                   move      w1fifo        $cvd6i
417sAC                   call      @cvtdt
417sAC                   parm                    $cvtdt
417sAC                   move      $cvd8o        wofifo
417sAC                   endif
510cA* Move mfg or expire or fifo date to keyed in date field
510cA* to send to PO236
510cAC                   eval      woindt = 0
510cAC                   select
510cAC                   when      w1fifo <> 0
510cAC                   eval      woindt = wofifo
510cAC                   when      w1mfdt <> 0
510cAC                   eval      woindt = womfdt
510cAC                   other
510cAC                   eval      woindt = woexdt
510cAC                   endsl
417hA*
650rAc                   exsr      zzendp
DRYkDc*                  Select
DRYkDc*                  when      client = Dairyland
DRYkDc*                  if        expd <= today and
DRYkDc*                            odovr = *on
DRYkDC*                            or oeovr = *on
DRYkDc*                  eval      $QUstat = 'QU'
DRYkDc*                  else
DRYkDc*                  eval      $QUstat = '  '
DRYkDc*                  endif
DRYkDC*                  other
DRYiac                   eval      $QUstat = '  '
DRYkDc*                  endsl
720aA ** do we need to print box labels
720aA ** 4 and 6 print normal uom labels
720aAc                   if        $ifrcvmth = '4' and $lrq1 > 0 or
720aAc                             $ifrcvmth = '6' and $lrq1 > 0
720aAc                   eval      $bpo = $lpo
720aAc                   eval      $brcvdt = today
720aAc                   eval      $bqty = $lrq1
720aAc                   eval      $bprint = '*JOB'
720aAc                   eval      $bitem = $litem
740aDc*                  eval      $buom =  $lum1
740aMc                   eval      $buom =  $itum1
720aAc                   call      'PO250'
720aAC                   parm                    $bparm
720aAc                   endif
720aA **
720aA ** 5 and 6 print breakdown1 uom labels
720aAc                   if        $ifrcvmth = '5' and $lum2 <> ' ' and
720aAc                             $itflg1 = 'Y' or
720aAc                             $ifrcvmth = '6' and $lum2 <> ' ' and
720aAc                             $itflg1 = 'Y'
720aAc                   eval      $bpo = $lpo
720aAc                   eval      $brcvdt = today
720aAc                   if        $lrq1 <> 0
720aAc                   eval      $bqty = ($lrq1 * $itumq2) + $lrq2
720aAc                   else
720aAc                   eval      $bqty = $lrq2
720aAc                   endif
720aAc                   eval      $bprint = '*JOB'
720aAc                   eval      $bitem = $litem
740aDc*                  eval      $buom =  $lum2
740aMc                   eval      $buom =  $itum2
720aAc                   call      'PO250'
720aAC                   parm                    $bparm
720aAc                   endif
720aA **
720aA ** 5 and 6 print breakdown2 uom labels
720aAc                   if        $ifrcvmth = '5' and $lum3 <> ' ' and
720aAc                             $itflg2 = 'Y' or
720aAc                             $ifrcvmth = '6' and $lum3 <> ' ' and
720aAc                             $itflg2 = 'Y'
720aAc                   eval      $bpo = $lpo
720aAc                   eval      $brcvdt = today
720aAc                   if        $lrq1 <> 0 or $lrq2 <> 0
720aAc                   eval      $bqty = ($lrq1 * $itumq2 * $itumq3)
720aAc                                   + ($lrq2 * $itumq3) + $lrq3
720aAc                   else
720aAc                   eval      $bqty = $lrq3
720aAc                   endif
720aAc                   eval      $bprint = '*JOB'
720aAc                   eval      $bitem = $litem
740aDc*                  eval      $buom =  $lum3
740aMc                   eval      $buom =  $itum3
720aAc                   call      'PO250'
720aAC                   parm                    $bparm
720aAc                   endif
720aA **
409 AC                   call      'PO236'
409 AC                   parm                    $lparm
409 AC                   parm                    $lum1
409 AC                   parm                    $lum2
409 AC                   parm                    $lum3
409 AC                   parm                    $lord
409 AC                   parm                    $lflag
     C                   parm                    $lseq
     C                   parm                    $lven
     C                   parm                    $lvnam
     C                   parm                    $lvitm
     C                   parm                    $rexpd
     C                   parm                    $pdev
     C                   parm                    $pform
     C                   parm                    w1twgt
417rAC                   parm                    avgwt1
417rAC                   parm                    avgwt2
417rAC                   parm                    avgwt3
417iAC                   parm                    w1lotc
510cDC*                  parm                    womfdt
510cMC                   parm                    woindt
417rAC                   parm                    wofifo
417rAC                   parm                    w1upc
640eAc                   parm                    $ldecvalue
640eAC                   parm      mexpd         $lmfgex           8 0
640eAC                   parm      mfgdte        $lmfgdt           8 0
640fAC                   parm      $plpn         $llpn            50
640gAC                   parm      ' '           NOlcns           15
640hAC                   parm                    w1brand
650fAC                   parm                    $parms1
650gAC                   parm                    $lsavetrn
650iAC                   parm                    $pgtin           14
650iAc                   parm                    $pbcProdD
650iAc                   parm                    $pbclot
650lAc                   parm      w1pti         $pw1pti
650qAc                   parm      $posscode     $losscode         1
221 A*
650rAc                   exsr      zzstrt
500aMC                   if        $lrtn = '*OK     '
500aMC                   eval      $prtn = $lrtn
500aMC                   eval      $pmsg = $lmsg
640eAc                   eval      $ldecvalue  = ' '
640eAc                   eval      $lmfgex = 0
640eAc                   eval      $lmfgdt = 0
640eAc                   eval      mexpd     = 0
640eAc                   eval      mfgdte   = 0
640hAc                   eval      w1brand  = ' '
650gAc                   eval      rcvpocomplete = *on
650lAc                   eval      w1pti = 0
650lAc                   eval      $pw1pti = 0
     *  If no error was found then send message to calling program.
     C                   call      'MOVMSGP'
     C                   parm                    $pprg
     C                   endif
409 A*
409 A*    Write records to POMFR file.
409 A*    Note: RC160 returns batch number in $RORD field which is
409 A*          used as first part of the LBKEY.
409 A*
221 AC                   if        $lrtn = '*OK     '
221 AC                   if        w1mfdt <> 0  or
221 AC                             w1exdt <> 0
409 AC     lbkey         setll     label2
409 AC                   eval      stop = *off
409 AC                   dou       stop = *on
409 AC     lbkey         reade     label2                                 79
409 AC                   if        *in79
409 AC                   eval      stop = *on
409 AC                   else
500bAC     lblbl#        chain     pomfr1                             78
409 AC                   eval      pmwhse = $pwhse
409 AC                   eval      pmpo = $ppo
409 AC                   eval      pmseq = $pseq
409 AC                   eval      pmitem = $pitem
409 AC                   eval      pmexpd = $rexpd
409 AC                   if        w1mfdt <> 0
409 AC                   move      w1mfdt        $cvd6i
409 AC                   eval      $cvcmd = '*MDYCMD '
409 AC                   call      @cvtdt
409 AC                   parm                    $cvtdt
409 AC                   eval      pmmfgd = $cvd8o
409 AC                   else
409 AC                   eval      pmmfgd = 0
409 AC                   endif
409 AC                   eval      pmtrn# = lbtrn#
409 AC                   eval      pmlbl# = lblbl#
500bAC                   if        *in78  = *off
500bAC                   update    pmrec
500bAC                   else
409 AC                   write     pmrec
500bAC                   endif
416eA*
416eA*      Write record to item exception file for date override.
416eA*
510lA * add additional exception if date decipher error
510lAc                   if        ddcode = *on
510lAC                   eval      exerid = 'DD-CODE'
510lAC                   eval      exwhse = lbwhse
510lAC                   eval      exwhdp = lbwhdp
510lAC                   eval      exstyp = lbstyp
510lAC                   eval      exitem = lbitem
510lAC                   eval      dspo = lbpo
510lAC                   eval      dslbl = lblbl#
510lAC                   eval      dsexpd = $dto
510lAC                   eval      exfdis = dsfdis
510lAC                   eval      extdis = dstdis
510lAC                   eval      exgdte = lbsdte
510lAC                   eval      exgtim = lbstim
650dA*
650dAC                   if        lbqpck > 999
650dAC                   eval      exqty = 999
650dAC                   else
650dA*
510lMC                   z-add     lbqpck        exqty
650dAC                   endif
650dA*
510laC                   eval      extask = 'RCV'
510lAC                   eval      exgby = #user
510lAC                   eval      exesta = '1 '
510lAC                   write     exrec
510lAC                   eval      ddcode = *off
510lac                   endif
500cDC*                  if        cwovr = *on  or
500cMC                   if        oaovr = *on  or
510eAC                             obovr = *on  or
510eAC                             ocovr = *on  or
417eAC                             odovr = *on  or
510eAC                             oeovr = *on  or
510eAC                             ofovr = *on
416eAC                   eval      exwhse = lbwhse
416eAC                   eval      exwhdp = lbwhdp
416eAC                   eval      exstyp = lbstyp
416eAC                   eval      exitem = lbitem
416eAC                   eval      dspo = lbpo
416eAC                   eval      dslbl = lblbl#
650cAC                   select
650cAC                   when      ocovr = *on
650cAC                   eval      dsexpd = ckexdt
650cAC                   other
416eAC                   eval      dsexpd = $dto
650cAC                   endsl
416eAC                   eval      exfdis = dsfdis
416eAC                   eval      extdis = dstdis
416eAC                   eval      exgdte = lbsdte
416eAC                   eval      exgtim = lbstim
416gD**                   Z-ADD0         EXQTY
650dA*
650dAC                   if        lbqpck > 999
650dAC                   eval      exqty = 999
650dAC                   else
650dA*
416gMC                   z-add     lbqpck        exqty
650dAC                   endif
650dA*
416eaC                   eval      extask = 'RCV'
416eAC                   eval      exgby = #user
500cDC*                  if        odovr = *on
510eAC                   select
510eAC                   when      oaovr = *on
510eAC                   eval      exerid = 'OA-DOVR'
510eAC                   when      obovr = *on
510eAC                   eval      exerid = 'OB-DOVR'
510eAC                   when      ocovr = *on
510eAC                   eval      exerid = 'OC-DOVR'
510eAC                   when      odovr = *on
510eAC                   eval      exerid = 'OD-DOVR'
510eAC                   when      oeovr = *on
510eAC                   eval      exerid = 'OE-DOVR'
510eAC                   when      ofovr = *on
510eAC                   eval      exerid = 'OF-DOVR'
510eAC                   other
510eAC                   eval      exerid = 'EXPDOVR'
510eAC                   endsl
500cAC***                if        odovr = *on  or
500cAC***                          oaovr = *on  or
500cAC***                          obovr = *on
417eA***                  MOVEL'DAYSOVR' EXERID
417eAC***                eval      exerid = 'EXPDOVR'
417eAC***                else
416eAC***                eval      exerid = 'EXPDOVR'
417eAC***                endif
416eAC                   eval      exesta = '1 '
416eAC                   write     exrec
510eAC                   eval      oaovr = *off
510eAC                   eval      obovr = *off
510eAC                   eval      ocovr = *off
510eAC                   eval      odovr = *off
510eAC                   eval      oeovr = *off
510eAC                   eval      ofovr = *off
416eAC                   endif
416eA*
409 AC                   endif
409 AC                   enddo
409 AC                   endif
650jA* catch weight override exception
650jAC                   if        cwovr = *on
650jAC     lbkey         setll     label2
650jAC                   eval      stop = *off
650jAC                   dou       stop = *on
650jAC     lbkey         reade     label2                                 79
650jAC                   if        *in79
650jAC                   eval      stop = *on
650jAc                   leave
650jAC                   else
650jAC                   if        lbqpck > 999
650jAC                   eval      exqty = 999
650jAC                   else
650jAC                   z-add     lbqpck        exqty
650jAC                   endif
650jAC                   endif
650jA*
650jAC                   eval      exwhse = lbwhse
650jAC                   eval      exwhdp = lbwhdp
650jAC                   eval      exstyp = lbstyp
650jAC                   eval      exitem = lbitem
650jAC                   eval      dspo = lbpo
650jAC                   eval      dslbl = lblbl#
650jAC*                  eval      dsexpd = $dto
650jAC                   eval      dsexpd = 0
650jAC                   eval      exfdis = dsfdis
650jAC                   eval      extdis = dstdis
650jAC                   eval      exgdte = lbsdte
650jAC                   eval      exgtim = lbstim
650jA*
650jAC                   eval      extask = 'RCV'
650jAC                   eval      exgby = #user
650jAC                   select
650jAC                   when      cwovr = *on
650jAC                   eval      exerid = 'CW-OVR '
650jAC                   endsl
650jAC                   eval      exesta = '1 '
650jAC                   write     exrec
650jA * load new file pocwexcp
650jA /free
650mD   //chain ($pwhse: lblbl#) pocwexcp;
650mD   //cw_exwhse = $pwhse;
650mD   //cw_expo = $ppo;
650mD   //cw_exseq = $pseq;
650mD   //cw_exitem = $pitem;
650jA   cw_exwhse = lbwhse;
650jA   cw_expo = lbpo;
650jA   cw_exseq = lbseq;
650jA   cw_exitem = lbitem;
650jA   cw_extrn# = lbtrn#;
650jA   cw_exlbl# = lblbl#;
700bD   //cw_exwgt = W1DWGT;
700bM   cw_exwgt = cnvwgt;
650nD   //cw_exrngl = erlrng;
650nD   //cw_exrngh = erhrng;
650jA   cw_exgdte = lbsdte;
650jA   cw_exgtim = lbstim;
650jA   cw_exrg1c = prg1c * 100;
650jA   cw_exrg2c = prg2c * 100;
650jA   cw_exswgt = exwgt;
650jA   select;
650jA     when imrg1c > 0;
650jA       cw_exrg1w = 'I';
650jA     when oprg1c > 0;
650jA       cw_exrg1w = 'S';
650jA     other;
650jA       cw_exrg1w = 'P';
650jA   endsl;
650jA   select;
650jA     when imrg2c > 0;
650jA       cw_exrg2w = 'I';
650jA     when oprg2c > 0;
650jA       cw_exrg2w = 'S';
650jA     other;
650jA       cw_exrg2w = 'P';
650jA   endsl;
650mD   //if %found(pocwexcp);
650mD     //update cwexrec;
650mD   //else;
650jA     write cwexrec;
650mD   //endif;
650jA /end-free
650jAC                   enddo
650jAC                   eval      cwovr = *off
650jA*
650jAC                   endif
409 AC                   endif
417pA*
417pA*    Write records to POFIFO file.
417pAC                   if        $lrtn = '*OK     '  and
417pAC                             w1fifo <> 0
417pAC     lbkey         setll     label2
417pAC                   eval      stop = *off
417pAC                   dou       stop = *on
417pAC     lbkey         reade     label2                                 79
417pAC                   if        *in79
417pAC                   eval      stop = *on
417pAC                   else
417pA*
417pAC                   move      w1fifo        $cvd6i
417pAC                   eval      $cvcmd = '*MDYCMD '
417pAC                   call      @cvtdt
417pAC                   parm                    $cvtdt
417pAC                   move      $cvd8o        wofifo
417pAC                   eval      pffifo = wofifo
417pAC                   eval      pflbl# = lblbl#
417pAC                   write     pfrec
417pAC                   endif
417pAC                   enddo
417pAC                   endif
     *
     *   Move key values to parameters
     *
409 AC     jmpup1        tag
     C                   eval      $pseq = pdseq
     C                   eval      $pitem = pditem
     C     endup1        endsr
700cA*----------------------------------------------------------------
700cA*
700cA*  ZZUPD1b  Write breakdown upc
700cA*
700cAC     zzupd1b       begsr

700cA /free
700cA   // breakdown1
700cA   if writeb1 = *on;
700cA     upwhse = $pwhse;
700cA     upitem = $pitem;
700cA     upupc = b1upc;
700cA     upven = phven;
700cA     upvnam = phvnam;
700cA     upvitm = $itvit#;
700cA     upbran = $imbrnd;
700cA     upuom = w1buom1;
700cA     uputyp = '1';
700cA     Select;
700cA       when b1type = 'UPC-12';
700cA         upctyp = '1';
700cA       when b1type = 'EAN-13';
700cA         upctyp = '2';
700cA       when b1type = 'GTIN';
700cA         upctyp = '3';
700cA       when b1type = 'SCC-14';
700cA         upctyp = '4';
700cA       when b1type = 'SSCC-18';
700cA         upctyp = '5';
700cA     endsl;
700cA     write uprec;
700cA     if client = birite
CFIaA      or client = Colony;
700cA       exsr outlog;
700cA     endif;
700cA   endif;
700cA   // breakdown2
700cA   if writeb2 = *on;
700cA     upwhse = $pwhse;
700cA     upitem = $pitem;
700cA     upupc = b2upc;
700cA     upven = phven;
700cA     upvnam = phvnam;
700cA     upvitm = $itvit#;
700cA     upbran = $imbrnd;
700cA     upuom = w1buom2;
700cA     uputyp = '2';
700cA     Select;
700cA       when b2type = 'UPC-12';
700cA         upctyp = '1';
700cA       when b2type = 'EAN-13';
700cA         upctyp = '2';
700cA       when b2type = 'GTIN';
700cA         upctyp = '3';
700cA       when b2type = 'SCC-14';
700cA         upctyp = '4';
700cA       when b2type = 'SSCC-18';
700cA         upctyp = '5';
700cA     endsl;
700cA     write uprec;
700cA     if client = birite
CFIaA      or client = Colony;
700cA       exsr outlog;
700cA     endif;
700cA   endif;
700cA /end-free
700cAC                   endsr
     *----------------------------------------------------------------
     *
BIR A*  Outlog - Write UPCLOG Record for BiRite.
     *
BIR Ac     outlog        begsr
     *
BIR Ac     upcky3        chain     upclog
BIR Ac                   if        Not %Found(upclog)
     *
BIR Ac                   eval      ulwhse = $pwhse
BIR Ac                   eval      ulitem = $pitem
700cAc                   Select
700cAc                   when      w1upc <> ' '
700cAc                   eval      ulupc  = w1upc
700cAc                   when      b1upc <> ' '
700cAc                   eval      ulupc  = b1upc
700cAc                   when      b2upc <> ' '
700cAc                   eval      ulupc  = b2upc
700cAc                   endsl
700cDc*                  eval      ulupc  = w1upc
BIR Ac                   eval      ulven  = phven
BIR Ac                   eval      ulvnam = upvnam
BIR Ac                   eval      ulvitm = upvitm
BIR Ac                   eval      ulbran = upbran
BIR Ac                   eval      ulpo   = $ppo
BIR Ac                   eval      ulposq = $pseq
BIR Ac                   eval      uladte = today
BIR Ac                   time                    ulatim
BIR Ac                   eval      uluser = #user
BIR Ac                   eval      uljob  = #job
BIR Ac                   eval      uljob# = #jobn
BIR Ac                   write     ulrec
     *
BIR Ac                   endif
     *
BIR Ac                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUHDR   Update HDR record.
     *
     C     zzuhdr        begsr
     C                   eval      error = *off
401 MC                   eval      full = *on
     C                   eval      part = *off
401 AC                   eval      recv = *off
     C     partky        setll     podtl                              79
     C                   move      *in79         eof
     C                   dow       eof = *off
     C     partky        reade     podtl                                  79
     C                   move      *in79         eof
     C                   if        not *in79
401 MC                   if        pdqrc1 < pdqor1
401 MC                   eval      part = *on
401 MC                   eval      full = *off
401 MC                   endif
401 M*
401 MC                   if        pdqrc2 < pdqor2
401 MC                   eval      part = *on
401 MC                   eval      full = *off
401 MC                   endif
401 M*
401 MC                   if        pdqrc3 < pdqor3
401 MC                   eval      part = *on
401 MC                   eval      full = *off
401 MC                   endif
401 A*
401 AC                   if        pdqrc1 > 0
401 AC                   eval      recv = *on
401 AC                   endif
401 A*
401 AC                   if        pdqrc2 > 0
401 AC                   eval      recv = *on
401 AC                   endif
401 A*
401 AC                   if        pdqrc3 > 0
401 AC                   eval      recv = *on
401 AC                   endif
     C                   endif
     C                   enddo
401 A*
401 AC                   if        recv = *off
401 AC                   eval      full = *off
401 AC                   eval      part = *off
401 AC                   endif
     *
     C     phkey         chain     pohdr                              79
     C                   if        not *in79
     C                   if        part = *on
     C                   eval      phstat = *on
     C                   endif
     C                   if        full = *on
     C                   eval      phstat = '2'
     C                   endif
401 AC                   if        part = *off  and
401 AC                             full = *off
401 AC                   eval      phstat = *off
401 AC                   endif
     C                   update    phrec
770aA*
770aA*   Update the POSTATUS file for a change to POHDR
770aA*   Check for DockVue system option
770aA*
770aA /free
770aA   // Set status for DockVue
770aA   if dockvue;
770aA     exec sql update postatus
770aA                 set posstat = :phstat,
770aA                     posupdts = current_timestamp
770aA               where poswhs = :phwhse
770aA                 and pospo  = :phpo;
770aA
770aA     if sqlstate <> sqlSuccess;
770aA       exec sql insert into postatus
770aA                values (:phwhse, :phpo, :phstat,
770aA                        current_timestamp, :nostamp);
770aA     endif;
770aA   endif;
770aA /end-free
770aA*
     C                   endif
415dA*
415dA*   Remove any existing catchweight entry records.
415dAC                   if        itcwgt = 'Y'
510kAC                             or itcwgt = 'S'
SOFaAC                             and client <> sofo
415dAC                   exsr      zzdlcw
415dAC                   endif
     *
     C     endhdr        endsr
KHLbA*
KHLbA*----------------------------------------------------------------
KHLbA*
KHLbA*  ZZUPCEX  Add UPC to ITMEXCP
KHLbA*
KHLbAC     zzupcex       begsr
KHLbA*
KHLbAC                   eval      extask = 'UPCADD'
KHLbAC                   eval      exerid = 'UPCADD'
KHLbAC                   eval      exwhse = $pwhse
KHLbAC                   eval      exitem = $pitem
KHLbAC                   eval      exgdte = today
KHLbAC                   eval      exgtim = %dec(%char(%time():*iso0):6:0)
KHLbAC                   eval      exfdis = %subst(w1upc:1:12)
KHLbAC                   eval      extdis = %subst(w1upc:13:8)
KHLbAC                   eval      exgby = #user
KHLbAC                   eval      exesta = '1 '
KHLbAC                   write     exrec
KHLbA*
KHLbAC     endupcex      endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update record.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     *
     *   Move key values to parameters
     *
     C     endup2        endsr
     *
     *----------------------------------------------------------------
     *
219 A*  ZZXOPT   Get use extended description option
     *
219 AC     zzxopt        begsr
     *
219 A*   Get extended description option.
219 AC                   eval      uxflag = *off
219 AC                   eval      ocode = '*ITEMMNT'
413bAC                   eval      wkwhse = $pwhse
     *
219 AC     opkey         chain     options                            79
219 AC                   if        not *in79
219 AC                   if        opxdsc = 'Y'
219 AC                   eval      uxflag = *on
219 AC                   endif
700bA*    We will set the default for lbs/kgs from the option file
700bA /free
700bA   // save the field for later use, the opdata field gets changed
700bA   svopwum = opwum;
700bA   select;
700bA     when opwum = 'KGS'
700bA      or opwum = 'kgs'
700bA      or opwum = 'Kgs';
700bA       KiloLbs = 'K';
700bA       W1KgLb  = opwum;
700bA     other;
700bA       KiloLbs = 'P';
700bA       W1KgLb  = 'Lbs';
700bA   endsl;
700bA /end-free
219 AC                   endif
     *
219 AC                   endsr
416fA*----------------------------------------------------------------
416fA*
416fA*  ZZZCW    Calculate catch weight
416fA*
     *
     *  Action Table
     *
     *   VRFYCW  SVCWEN  SVCWTP  W1AVG  POCTYP  Action
     *   ------  ------  ------  -----  ------  --------------------
     *     Y       1       1       N       -    CW = Calc1
     *
     *     Y       1       1       Y       -    CW = Calc2
     *
     *     Y       1       2       -       -    CW = Calc1
     *
     *     Y       1       3       -       -    CW = Calc2
     *
     *     Y       2       1       N       -    CW = Calc1
     *                                          Write POCTYP = 'T'
     *
     *     Y       2       1       Y       -    CW = Calc3
     *                                          Write POCTYP = 'A'
     *
     *     Y       2       2       -       -    CW = Calc1
     *                                          Write POCTYP = 'T'
     *
     *     Y       2       3       -       -    Not allowed
     *
     *     N       1       -       -       -    Not allowed
     *
     *     N       2       -       -       T    None
     *
     *     N       2       -       -       A    CW = Calc3
     *
     *     N       3       -       -       -    None
     *
     *  Keys:
     *
     *   SVCWEN - 1=Every time, 2=First time only, 3=Never
     *   SVCWTP - 1=Choice, 2=Total, 3=Average
     *   Calc1  - Entered weight
     *   Calc2  - Qty * Entered weight
     *   Calc3  - Qty * Item weight
     *
     *----------------------------------------------------------------
416fAC     zzzcw         begsr
     *
     C                   eval      w1twgt = 0
417rAC                   eval      avgwt1 = 0
417rAC                   eval      avgwt2 = 0
417rAC                   eval      avgwt3 = 0
     C                   eval      cwcalc = 0
     C                   eval      wrttyp = ' '
     *
     *   Get POCTYPE record.
     *
     C                   if        svcwen = '2'
650kMC     keypoc        chain(n)  poctype                            79
650kDC**   keypoc        chain     poctype                            79
     C                   if        *in79
     C                   eval      poctyp = 'T'
     C                   endif
     C                   endif
     *
     *   Determine what needs to be done based on table.
     *
     C                   select
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '1'  and
     C                             svcwtp = '1'  and
     C                             w1avg = 'N'
     C                   eval      cwcalc = 1
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '1'  and
     C                             svcwtp = '1'  and
     C                             w1avg = 'Y'
     C                   eval      cwcalc = 2
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '1'  and
     C                             svcwtp = '2'
     C                   eval      cwcalc = 1
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '1'  and
     C                             svcwtp = '3'
     C                   eval      cwcalc = 2
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '2'  and
     C                             svcwtp = '1'  and
     C                             w1avg = 'N'
     C                   eval      cwcalc = 1
     C                   eval      wrttyp = 'T'
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '2'  and
     C                             svcwtp = '1'  and
     C                             w1avg = 'Y'
     C                   eval      cwcalc = 3
     C                   eval      wrttyp = 'A'
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '2'  and
     C                             svcwtp = '2'
     C                   eval      cwcalc = 1
     C                   eval      wrttyp = 'T'
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '2'  and
     C                             svcwtp = '3'
     *
     C                   when      vrfycw = *off  and
     C                             svcwen = '1'
     *
     C                   when      vrfycw = *off  and
     C                             svcwen = '2'  and
     C                             poctyp = 'T'
     *
     C                   when      vrfycw = *off  and
     C                             svcwen = '2'  and
     C                             poctyp = 'A'
     C                   eval      cwcalc = 3
     *
     C                   when      vrfycw = *off  and
     C                             svcwen = '3'
     *
     C                   endsl
     *
     *   Calculate catch weight.
     *
     C                   select
     *
     *     Straight total.
     *
     C                   when      cwcalc = 1
640bDC**                 eval      w1twgt = w1dwgt
640bMC                   eval      w1twgt = cnvwgt
510fAC                   select
510fAC                   when      w1qrc1 > 0
640bDC**   w1dwgt        div       w1qrc1        avgwt1
640bMC     cnvwgt        div       w1qrc1        avgwt1
510fAC                   when      w1qrc2 > 0
640bDC**   w1dwgt        div       w1qrc2        avgwt1
640bMC     cnvwgt        div       w1qrc2        avgwt1
510fAC                   when      w1qrc3 > 0
640bDC**   w1dwgt        div       w1qrc3        avgwt1
640bMC     cnvwgt        div       w1qrc3        avgwt1
510fAC                   endsl
     *
     *     Entered quantity * Entered weight.
     *
     C                   when      cwcalc = 2
510fAC                   select
510fAC                   when      w1qrc1 > 0
640bDC**   w1dwgt        mult      w1qrc1        w1twgt
640bMC     cnvwgt        mult      w1qrc1        w1twgt
510fAC                   when      w1qrc2 > 0
640bDC**   w1dwgt        mult      w1qrc2        w1twgt
640bMC     cnvwgt        mult      w1qrc2        w1twgt
510fAC                   when      w1qrc3 > 0
640bDC**   w1dwgt        mult      w1qrc3        w1twgt
640bMC     cnvwgt        mult      w1qrc3        w1twgt
510fAC                   endsl
640bDC**                 z-add     w1dwgt        avgwt1
640bMC                   z-add     cnvwgt        avgwt1
     *
     *     Entered quantity * Item weight.
     *
     C                   when      cwcalc = 3
     *
     *       Normal qty for non-SSB items.
     *
     C                   if        w1qrc1 > 0  and
     C                             #otype <> 'S'
     C     #oswgt        mult      w1qrc1        w1twgt
417rAC                   eval      avgwt1 = #oswgt
     C                   endif
     *
     *       Normal qty for SSB items.
     *
     C                   if        w1qrc1 > 0  and
     C                             #otype = 'S'
     C     #oswt2        mult      w1qrc1        w1twgt
417rAC                   eval      avgwt1 = #oswt2
     C                   endif
     *
     *       Brk1 qty for non-SSB items.
     *
     C                   if        w1qrc2 > 0  and
     C                             #otype <> 'S'
     C     #oswt2        mult      w1qrc2        tmpwgt
     C                   add       tmpwgt        w1twgt
417rAC                   eval      avgwt2 = #oswt2
     C                   endif
     *
     *       Brk1 qty for SSB items.
     *
     C                   if        w1qrc2 > 0  and
     C                             #otype = 'S'
     C     #oswt3        mult      w1qrc2        tmpwgt
     C                   add       tmpwgt        w1twgt
417rAC                   eval      avgwt2 = #oswt3
     C                   endif
     *
     *       Brk2 qty for non-SSB items.
     *
     C                   if        w1qrc3 > 0  and
     C                             #otype <> 'S'
     C     #oswt3        mult      w1qrc3        tmpwgt
     C                   add       tmpwgt        w1twgt
417rAC                   eval      avgwt3 = #oswt3
     C                   endif
     *
     C                   endsl
     *
     *   Write POCTYPE record.
     *
     C                   if        wrttyp <> ' '
     C     keypoc        chain     poctype                            79
     C                   if        not *in79
     C                   eval      poctyp = wrttyp
     C                   update    pocrec
     C                   else
     C                   eval      pocwhs = $pwhse
     C                   eval      pocpo = $ppo
     C                   eval      pocseq = $pseq
     C                   eval      poctyp = wrttyp
     C                   write     pocrec                               78
     C                   endif
     C                   endif
     *
     C                   endsr
710aA*----------------------------------------------------------------
710aA*
710aA*  ZZZGFCd  Glazier Date checking
710aAC     zzzgfcd       begsr
417p *
417p *  Verify FIFO (entered) date.
417p *
417p C                   if        not *in89  and
417p C                             w1fifo <> 0
417p C                   eval      $cvcmd = '*MDYEDT '
417p C                   move      w1fifo        $cvd6i
417p C                   call      @cvtdt
417p C                   parm                    $cvtdt
417p C                   if        $cvrtn = '*PGMQ   '
417p C                   eval      error = *on
417p C                   eval      *in29 = *on
417p C                   eval      *in09 = *on
417p C                   eval      #msgk = $cvmsg
417p **                   EXSR ZMQMSG
417p C                   goto      enderr1
417p C                   else
417p C                   eval      w1fifo = $cvd6o
417p C                   endif
MJKa C                   else
MJKa C                   if        not *in89  and
MJKa C                             w1fifo = 0 and
MJKa C                             client = mjkellner
MJKa C                   eval      error = *on
MJKa C                   eval      *in29 = *on
MJKa C                   eval      *in09 = *on
MJKa C                   eval      errmsg = *blanks
MJKa C                   exsr      zm1008
MJKa C                   endif
417p C                   endif
     *
     *  Verify expiration date.
     *
214 AC                   if        not *in96  and
214 AC                             w1exdt = 0
214 AC                   eval      error = *on
214 AC                   eval      *in24 = *on
214 AC                   eval      *in04 = *on
214 AC                   eval      errmsg = *blanks
214 AC                   exsr      zm1008
214 AC                   else
417oA*  Moved code here to calculate CKEXDT
417aA*  Verify Expiration date is within parameter (# of days out)     days)
417aA*  Calculate (Today + # days out)  = CHEXDT                       days)
417aA*

GFCdAC                   if        client = glazier
GFCdAC                   z-add     itslif        imoday
GFCdAC                   endif
417rAC                   call      'CLCDUR2'
417rAC                   parm      '*ADD'        $cdcmd
417rAC                   parm      today         $cddatein
417rAC                   parm      0             $cdtimein
417rAC                   parm      0             $cdyears
417rAC                   parm      0             $cdmonths
417rAC                   parm      imoday        $cddays
417rAC                   parm      0             $cdhours
417rAC                   parm      0             $cdminutes
417rAC                   parm      0             $cdseconds
417rAC     ckexdt        parm      0             $cddateout
417rAC                   parm      0             $cdtimeout

417rDC**                 move      today         g$date
417rDC**                 eval      dtfrmt = 1
417rDC**                 exsr      gtoj$
417rDC**                 eval      todyj = g$jd
417rDC**
417rDC**   todyj         add       imoday        j$jd
417rDC**                 exsr      jtog$
417rDC**                 eval      date16 = j$date
417rDC**
417rDC**                 move      date16        $cvd6i
417rDC**                 eval      $cvcmd = '*YMDCMD '
417rDC**                 call      @cvtdt
417rDC**                 parm                    $cvtdt
417rDC**                 move      $cvd8o        ckexdt
     C                   if        w1exdt <> 0
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1exdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      #msgk = $cvmsg
     **                   EXSR ZMQMSG
     C                   goto      enderr1
     C                   else
     C                   eval      w1exdt = $cvd6o
214 AC                   eval      $cvcmd = '*MDYCMD '
214 AC                   call      @cvtdt
214 AC                   parm                    $cvtdt
214 AC                   move      $cvd8o        expd
510cAC                   move      $cvd8o        woexdt
DRYhAc                   Select
DRYhAc                   when      client = Dairyland
DRYhAc                   other
    A*  check expiration date enter to make sure it is greater than today.
214 AC                   if        expd <= today
214 AC                   eval      error = *on
214 AC                   eval      *in24 = *on
214 AC                   eval      *in04 = *on
214 AC                   eval      errmsg = *blanks
214 AC                   exsr      zm1009
650hAC                   goto      enderr1
214 AC                   endif
DRYhAc                   endsl
417oA*  Code to calculate CKEXDT was moved from here to above.
415bA*
415bA*
415bA*  Verify Use by date.                                            days)
415bA*  Calculate (Today + Dist Days)  = DATE1                         days)
415bA*  Calculate  (Use By - User Days) = DATE2                        days)
415bA*

417rAC                   call      'CLCDUR2'
417rAC                   parm      '*ADD'        $cdcmd
417rAC                   parm      today         $cddatein
417rAC                   parm      0             $cdtimein
417rAC                   parm      0             $cdyears
417rAC                   parm      0             $cdmonths
417rAC                   parm      imdday        $cddays
417rAC                   parm      0             $cdhours
417rAC                   parm      0             $cdminutes
417rAC                   parm      0             $cdseconds
417rAC     date1         parm      0             $cddateout
417rAC                   parm      0             $cdtimeout

520aAC                   if        immflg = 'Y'
520aAC                   eval      date2 = expd
520aAC                   else
GFCbAC                   if        client = Glazier
417rAC                   eval      imuday = *zeros
417rAC                   endif
417rAC                   call      'CLCDUR2'
417rAC                   parm      '*SUB'        $cdcmd
417rAC                   parm      expd          $cddatein
417rAC                   parm      0             $cdtimein
417rAC                   parm      0             $cdyears
417rAC                   parm      0             $cdmonths
417rAC                   parm      imuday        $cddays
417rAC                   parm      0             $cdhours
417rAC                   parm      0             $cdminutes
417rAC                   parm      0             $cdseconds
417rAC     date2         parm      0             $cddateout
417rAC                   parm      0             $cdtimeout
520aAC                   endif

417rDC**                 move      today         g$date
417rDC**                 eval      dtfrmt = 1
417rDC**                 exsr      gtoj$
417rDC**                 eval      todyj = g$jd
417rDC**
417rDC**   todyj         add       imdday        j$jd
417rDC**                 exsr      jtog$
417rDC**                 eval      date16 = j$date
417rDC**
417rDC**                 move      date16        $cvd6i
417rDC**                 eval      $cvcmd = '*YMDCMD '
417rDC**                 call      @cvtdt
417rDC**                 parm                    $cvtdt
417rDC**                 move      $cvd8o        date1
417rDC**
417rDC**                 move      expd          g$date
417rDC**                 eval      dtfrmt = 1
417rDC**                 exsr      gtoj$
417rDC**                 eval      expdj = g$jd
417rDC**
417rDC**                 eval      j$jd = expdj - imuday
417rDC**                 exsr      jtog$
417rDC**                 eval      date26 = j$date
417rDC**
417rDC**                 move      date26        $cvd6i
417rDC**                 eval      $cvcmd = '*YMDCMD '
417rDC**                 call      @cvtdt
417rDC**                 parm                    $cvtdt
417rDC**                 move      $cvd8o        date2
415bA*
417rDC**                 move      date26        $cvd6i
417rDC**                 eval      $cvcmd = '*YMDMDY '
417rMC                   move      date2         $cvd8i
417rMC                   eval      $cvcmd = '*CMDMDY '
415bAC                   call      @cvtdt
415bAC                   parm                    $cvtdt
415bAC                   move      $cvd6o        date2o
415bA*
     C                   endif
     C                   endif
     C                   endif
417eA***
417eA*  Verify Expire date and # of days out                           days)
417eA*  Allow warning and override                                     days)
417eAC                   if        expd <> 0
417eAC                   if        svexdt <> w1exdt
417eAC                   eval      dtchk = *off
510eMC                   eval      ocovr = *off
510eDC*                  eval      odovr = *off
417eAC                   endif
417e *
417eAC                   if        dtchk = '2'  and
417eAC                             ovrrid = *on
GFCaAC                   if        client = Glazier
GFCaAC                   exsr      zzpwd
GFCaAC                   if        $prtn = '*NO'
GFCaAC                   eval      ovrrid = *off
GFCaAC                   eval      error  = *on
GFCaAC                   goto      enderr1
GFCaAC                   else
GFCaAC                   eval      error = *on
GFCaAC                   eval      dtchk = '2'
GFCaAC                   eval      warn = *on
GFCaAC                   eval      *in24 = *on
GFCaAC                   eval      *in04 = *on
GFCaAC                   eval      errmsg = *blanks
GFCaAC                   eval      erused = w1exdt
GFCaAC                   eval      erdisd = imoday
GFCaAC                   exsr      zm3243
GFCaAC                   eval      ovrrid = *off
GFCaAC                   endif
GFCaAC                   endif
510eMC                   eval      ocovr = *on
510eDC*                  eval      odovr = *on
417eAC                   eval      dtchk = *on
417eAC                   endif
417e *
417eMC                   if        dtchk <> '1'
417eAC                   eval      dtchk = *on
417eA*
417eA*   If EXPD > /CKEXDT - Reject.
417eA*
417eAC                   if        expd > ckexdt
GFCdAC***                          and client <> glazier
417eAC                   eval      error = *on
417eAC                   eval      dtchk = '2'
417eAC                   eval      warn = *on
417eAC                   eval      *in24 = *on
417eAC                   eval      *in04 = *on
417eAC                   eval      errmsg = *blanks
417eAC                   eval      erused = w1exdt
417eAC                   eval      erdisd = imoday
GFCdAC                   if        client <> glazier
417eAC                   exsr      zm3243
GFCdAC                   else
GFCdAC                   eval      erdisd = itslif
GFCdAC                   exsr      zm23212
GFCdAC                   endif
417eAC                   endif
417e *
417eAC     error         cabeq     *on           enderr1
417e *
417eAC                   endif
510aDC***                eval      dtchk = *off
417eMC                   eval      expd = date2
417eAC                   endif
     *
415bA*
415bA*  Verify Use by date.                                            days)
415bAC                   if        expd <> 0
415bAC                   if        svexdt <> w1exdt
500dMC                   eval      dtchk3 = *off
500dDC*                  eval      dtchk = *off
415bAC                   endif
415b *
415bAC                   if        dtchk3 = '2'  and
415bAC                             ovrrid = *on
GFCaAC                   if        client = Glazier
GFCaAC                   exsr      zzpwd
GFCaAC                   if        $prtn = '*NO'
GFCaAC                   eval      ovrrid = *off
GFCaAC                   eval      error  = *on
GFCaAC                   eval      dtchk3 = '2'
GFCaAC                   eval      warn = *on
GFCaAC                   eval      *in24 = *on
GFCaAC                   eval      *in04 = *on
GFCaAC                   eval      errmsg = *blanks
GFCaAC                   eval      erused = w1exdt
GFCaAC                   eval      erdisd = imdday
GFCaAC                   eval      erusrd = imuday
GFCaAC                   eval      ersell = date2o
GFCaAC                   exsr      zm3229
GFCaAC                   goto      enderr1
GFCaAC                   endif
GFCaAC                   endif
500cAC                   eval      odovr = *on
415bAC                   eval      dtchk3 = *on
415bAC                   endif
415b *
415bMC                   if        dtchk3 <> '1'
415bAC                   eval      dtchk3 = *on
415bA*
415bA*   If DATE2 <= Date1 - Reject.
415bA*
415bAC                   if        date2 <= date1
415bAC                   eval      error = *on
415bAC                   eval      dtchk3 = '2'
415bAC                   eval      warn = *on
415bAC                   eval      *in24 = *on
415bAC                   eval      *in04 = *on
415bAC                   eval      errmsg = *blanks
415bAC                   eval      erused = w1exdt
415bAC                   eval      erdisd = imdday
415bAC                   eval      erusrd = imuday
415bAC                   eval      ersell = date2o
415bAC                   exsr      zm3229
415bAC                   endif
415b *
415bAC     error         cabeq     *on           enderr1
415b *
415bAC                   endif
500dDC*                  eval      dtchk = *off
415bMC                   eval      expd = date2
415bAC                   endif
     *
     *
413cA*R         DTCHK     IFEQ '1'
500dA*  Change to use DTCHK4 for override                                  )
413cAC                   if        svmfdt <> w1mfdt
500dMC                   eval      dtchk4 = *off
500dDC*                  eval      dtchk = *off
413cAC                   endif
413c *
500dDC*                  if        dtchk = '2'  and
500dMC                   if        dtchk4 = '2'  and
413cAC                             ovrrid = *on
GFCaAC                   if        client = Glazier
GFCaAC                   exsr      zzpwd
GFCaAC                   if        $prtn = '*NO'
GFCaAC                   eval      ovrrid = *off
GFCaAC                   eval      error  = *on
GFCaAC                   goto      enderr1
GFCaAC                   endif
GFCaAC                   endif
510eAC                   if        mfgd > today
500cAC                   eval      obovr = *on
510eAC                   endif
YHAcAC                   if        client = yhata  and
YHAcAC                             mfgd = today
YHAcAC                   eval      obovr = *on
YHAcAC                   endif
510eAC                   if        today > ltstd8
510eAC                   eval      oeovr = *on
510eAC                   endif
500dAC                   eval      dtchk4 = *on
413cAC                   endif
413c *
413 D*R         OVRRID    IFEQ *OFF
500dMC                   if        dtchk4 <> '1'
500dMC                   eval      dtchk4 = *on
     *
409 A*
409 A*  Verify manufacturing date.
409 A*
409 AC                   select
409 AC                   when      immflg = 'Y'
409 AC                   if        w1mfdt = 0
409 AC                   eval      error = *on
500dDC*                  eval      dtchk = *off
500dMC                   eval      dtchk4 = *off
500cAC                   eval      obovr = *off
409 AC                   eval      *in27 = *on
409 AC                   eval      *in07 = *on
409 AC                   eval      errmsg = *blanks
409 AC                   exsr      zm1008
409 AC                   else
409 AC                   if        w1mfdt <> 0
409 AC                   eval      $cvcmd = '*MDYEDT '
409 AC                   move      w1mfdt        $cvd6i
409 AC                   call      @cvtdt
409 AC                   parm                    $cvtdt
409 AC                   if        $cvrtn = '*PGMQ   '
409 AC                   eval      error = *on
500dDC*                  eval      dtchk = *off
500dMC                   eval      dtchk4 = *off
500cAC                   eval      obovr = *off
409 AC                   eval      *in27 = *on
409 AC                   eval      *in07 = *on
409 AC                   eval      #msgk = $cvmsg
409 A**                   EXSR ZMQMSG
409 AC                   goto      enderr1
409 AC                   else
409 AC                   eval      w1mfdt = $cvd6o
409 AC                   eval      $cvcmd = '*MDYCMD '
409 AC                   call      @cvtdt
409 AC                   parm                    $cvtdt
409 AC                   move      $cvd8o        mfgd
409 AC                   if        mfgd > today
409 AC                   eval      error = *on
500dDC*                  eval      dtchk = *off
500dMC                   eval      dtchk4 = *off
500cAC                   eval      obovr = *off
409 AC                   eval      *in27 = *on
409 AC                   eval      *in07 = *on
409 AC                   eval      errmsg = *blanks
409 AC                   exsr      zm1010
409 AC                   endif
YHAcAC                   if        client = yhata  and
YHAcAC                             mfgd = today
YHAcAC                   eval      error = *on
YHAcAC                   eval      dtchk4 = '2'
YHAcAC                   eval      obovr = *off
YHAcAC                   eval      *in27 = *on
YHAcAC                   eval      *in07 = *on
YHAcAC                   eval      errmsg = *blanks
YHAcAC                   exsr      zm1010
YHAcAC                   endif
409 AC                   endif
409 AC                   endif
409 AC                   endif
     *
415CAC     error         cabeq     *on           enderr1
409 A*
409 A*  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
409 A*

417rAC                   eval      $cvcmd = '*MDYCMD '
417rAC                   move      w1mfdt        $cvd6i
417rAC                   call      @cvtdt
417rAC                   parm                    $cvtdt
417rAC                   move      $cvd8o        expd

GFCbAC                   if        client = Glazier
GFCbA*  Create expiration date mfgdate + mfg shelf life days
GFCbA*      instead of mfgdata + mfg shelf life days - User days
GFCbAC                   eval      imuday = *zeros
GFCbAC                   endif
GFCbA
417rAC                   call      'CLCDUR2'
417rAC                   parm      '*ADD'        $cdcmd
417rAC                   parm      expd          $cddatein
417rAC                   parm      0             $cdtimein
417rAC                   parm      0             $cdyears
417rAC                   parm      0             $cdmonths
417rAC                   parm      immday        $cddays
417rAC                   parm      0             $cdhours
417rAC                   parm      0             $cdminutes
417rAC                   parm      0             $cdseconds
417rAC                   parm      0             $cddateout
417rAC                   parm      0             $cdtimeout

417rAC                   call      'CLCDUR2'
417rAC                   parm      '*SUB'        $cdcmd
417rAC                   parm      $cddateout    $cddatein
417rAC                   parm      0             $cdtimein
417rAC                   parm      0             $cdyears
417rAC                   parm      0             $cdmonths
417rAC                   parm      imuday        $cddays
417rAC                   parm      0             $cdhours
417rAC                   parm      0             $cdminutes
417rAC                   parm      0             $cdseconds
417rAC     expd          parm      0             $cddateout
417rAC                   parm      0             $cdtimeout

417rAC                   eval      $cvcmd = '*CMDMDY '
417rAC                   move      expd          $cvd8i
417rAC                   call      @cvtdt
417rAC                   parm                    $cvtdt
417rAC                   move      $cvd6o        w1exdt

417rDC**                 move      w1mfdt        g$date
417rDC**                 eval      dtfrmt = 2
417rDC**                 exsr      gtoj$
417rDC**                 eval      mfdtj = g$jd
417rDC**
417rDC**   mfdtj         add       immday        j$jd
417rDC**                 eval      j$jd = j$jd - imuday
417rDC**                 exsr      jtog$
417rDC**                 move      j$date        $cvd6o
417rDC**                 eval      w1exdt = $cvd6o
417rDC**
417rDC**                 eval      $cvcmd = '*MDYCMD '
417rDC**                 move      w1exdt        $cvd6i
417rDC**                 call      @cvtdt
417rDC**                 parm                    $cvtdt
417rDC**                 move      $cvd8o        expd
409 A*
409 A*  Find the latest acceptable date.: Exp date -Dist days
409 A*

417rAC                   eval      $cvcmd = '*MDYCMD '
417rAC                   move      w1exdt        $cvd6i
417rAC                   call      @cvtdt
417rAC                   parm                    $cvtdt
417rAC                   move      $cvd8o        ltstd8

417rAC                   call      'CLCDUR2'
417rAC                   parm      '*SUB'        $cdcmd
417rAC                   parm      ltstd8        $cddatein
417rAC                   parm      0             $cdtimein
417rAC                   parm      0             $cdyears
417rAC                   parm      0             $cdmonths
417rAC                   parm      imdday        $cddays
417rAC                   parm      0             $cdhours
417rAC                   parm      0             $cdminutes
417rAC                   parm      0             $cdseconds
417rAC     ltstd8        parm      0             $cddateout
417rAC                   parm      0             $cdtimeout

417rAC                   eval      $cvcmd = '*CMDMDY '
417rAC                   move      ltstd8        $cvd8i
417rAC                   call      @cvtdt
417rAC                   parm                    $cvtdt
417rAC                   move      $cvd6o        ltstd6

417rDC**                 move      w1exdt        g$date
417rDC**                 eval      dtfrmt = 2
417rDC**                 exsr      gtoj$
417rDC**                 eval      exdtj = g$jd
417rDC**
417rDC**                 eval      j$jd = exdtj - imdday
417rDC**                 exsr      jtog$
417rDC**                 move      j$date        $cvd6o
417rDC**                 move      $cvd6o        ltstd6
417rDC**
417rDC**                 move      ltstd6        $cvd6i
417rDC**                 eval      $cvcmd = '*MDYCMD '
417rDC**                 call      @cvtdt
417rDC**                 parm                    $cvtdt
417rDC**                 move      $cvd8o        ltstd8
409 A*
409 A*   If Today's date is > Latest acceptable date - Reject.
409 A*
GFCbAC                   if        client = Glazier
GFCdAc                   eval      netdays = immday - imdday
GFCbAC                   call      'CLCDUR2'
GFCbAC                   parm      '*SUB'        $cdcmd
GFCbAC                   parm      today         $cddatein
GFCbAC                   parm      0             $cdtimein
GFCbAC                   parm      0             $cdyears
GFCbAC                   parm      0             $cdmonths
GFCdDC*                  parm      imdday        $cddays
GFCdMC                   parm      netdays       $cddays
GFCbAC                   parm      0             $cdhours
GFCbAC                   parm      0             $cdminutes
GFCbAC                   parm      0             $cdseconds
GFCbAC     glzmfd        parm      0             $cddateout
GFCbAC                   parm      0             $cdtimeout
GFCbAC                   endif
GFCbAC                   select
GFCbA*   For Glazier mfg date < today - dist days
GFCbAC                   when      client = Glazier and
GFCbAC                             mfgd < glzmfd
409 AC                   eval      error = *on
510eAC                   eval      oeovr = *off
500dDC*                  eval      dtchk = '2'
500dMC                   eval      dtchk4 = '2'
413c C                   eval      warn = *on
416cMC                   eval      *in27 = *on
416cMC                   eval      *in07 = *on
409 AC                   eval      errmsg = *blanks
409 AC*                  eval      ermday = immday
409 AC*                  eval      ermfdt = w1mfdt
409 AC*                  eval      erexdt = w1exdt
409 AC*                  eval      erltst = ltstd6
409 AC*                  eval      erdday = imdday
409 AC*                  eval      eruday = imuday
GFCbAC                   z-add     immday        ermday
GFCbAC                   z-add     w1mfdt        ermfdt
GFCbAC                   z-add     w1exdt        erexdt
GFCbAC                   z-add     ltstd6        erltst
GFCbAC                   z-add     imdday        erdday
GFCbAC                   z-add     imuday        eruday
409 AC                   exsr      zm23210
416iMC                   eval      w1exdt = 0
417fAC                   eval      expd = *zeros
GFCbA*   For Glazier today's date is = expiration date
GFCbAC                   when      client = Glazier and
GFCbAC                             today = mfgd
GFCbA*   For Glazier mfg date < today - dist days
409 AC                   eval      error = *on
510eAC                   eval      oeovr = *off
500dDC*                  eval      dtchk = '2'
500dMC                   eval      dtchk4 = '2'
413c C                   eval      warn = *on
416cMC                   eval      *in27 = *on
416cMC                   eval      *in07 = *on
409 AC                   eval      errmsg = *blanks
409 AC*                  eval      ermday = immday
409 AC*                  eval      ermfdt = w1mfdt
409 AC*                  eval      erexdt = w1exdt
409 AC*                  eval      erltst = ltstd6
409 AC*                  eval      erdday = imdday
409 AC*                  eval      eruday = imuday
GFCbAC                   z-add     immday        ermday
GFCbAC                   z-add     w1mfdt        ermfdt
GFCbAC                   z-add     w1exdt        erexdt
GFCbAC                   z-add     ltstd6        erltst
GFCbAC                   z-add     imdday        erdday
GFCbAC                   z-add     imuday        eruday
409 AC                   exsr      zm23211
416iMC                   eval      w1exdt = 0
417fAC                   eval      expd = *zeros
409 AC                   when      today > ltstd8
409 AC                   eval      error = *on
510eAC                   eval      oeovr = *off
500dDC*                  eval      dtchk = '2'
500dMC                   eval      dtchk4 = '2'
413c C                   eval      warn = *on
416cD**                   MOVE *ON       *IN28
416cD**                   MOVE *ON       *IN08
416cMC                   eval      *in27 = *on
416cMC                   eval      *in07 = *on
409 AC                   eval      errmsg = *blanks
409 AC*                  eval      ermday = immday
409 AC*                  eval      ermfdt = w1mfdt
409 AC*                  eval      erexdt = w1exdt
409 AC*                  eval      erltst = ltstd6
409 AC*                  eval      erdday = imdday
409 AC*                  eval      eruday = imuday
GFCbAC                   z-add     immday        ermday
GFCbAC                   z-add     w1mfdt        ermfdt
GFCbAC                   z-add     w1exdt        erexdt
GFCbAC                   z-add     ltstd6        erltst
GFCbAC                   z-add     imdday        erdday
GFCbAC                   z-add     imuday        eruday
409 DC***                exsr      zm3228
GFCbDC***                exsr      zm23212
YHAfAc                   Select
YHAfAc                   when      client = yhata
YhafAC                   exsr      zm3228
YHAfAC                   other
650hMC                   exsr      zm23210
YHAfAC                   endsl
416iMC                   eval      w1exdt = 0
417fAC                   eval      expd = *zeros
GFCbDC***                endif
GFCbMC                   endsl
409 AC                   endsl
     *
413cAC     error         cabeq     *on           enderr1
412 AC                   endif
416aA*
416aA*   Check for ealier expiration dates (optional)                  days)
416aA*
416aA*     See if we can skip the check.                               days)
416aA*
416aAC                   if        w1exdt = 0  or
416aAC                             svexck <> '2'  and
416aAC                             svexck <> '3'
710aDC**                 goto      skpxck
710aMC                   goto      enderr1
416aAC                   endif
416aA*
416aA*     Set warning check flag.                                     days)
416aA*
416aAC                   if        svexdt <> w1exdt
416aAC                   eval      dtchk2 = *off
500cMC                   eval      oaovr = *off
510eAC                   eval      ofovr = *off
500cDC*                  eval      cwovr = *off
416aAC                   endif
416aA*
416aAC                   if        dtchk2 = '2'  and
416aAC                             ovrrid = *on
GFCaAC                   if        client = Glazier
GFCaAC                   exsr      zzpwd
GFCaAC                   if        $prtn = '*NO'
GFCaAC                   eval      error  = *on
GFCaAC                   goto      enderr1
GFCaAC                   endif
GFCaAC                   endif
510eDC*                  eval      odovr = *on
510eAC                   if        immflg = 'Y'
510eMC                   eval      oaovr = *on
510eAC                   else
510eAC                   eval      ofovr = *on
510eAC                   endif
416aAC                   eval      dtchk2 = *on
710aDC*                  goto      skpxck
710aMC                   goto      enderr1
 16aAC                   endif
416aA*
710aDC*    dtchk2        cabeq     '1'           skpxck
710aAC     dtchk2        cabeq     '1'           enderr1
416aA*
416aA*     Do actual check                                             days)
416aA*
416aAC                   eval      dtchk2 = *on
416aA*
416aA*       Get date range of overflow slots.
416aA*
416aAC                   call      'GETEXPD'
416aAC                   parm      $pwhse        $swhse            3 0
416aAC                   parm                    #sitem
416aAC                   parm                    $dfrom            8 0
416aAC                   parm                    $dto              8 0
416aA*
416aA*       If date comes after end of range
416aA*         Then date can be recevied so skip the rest of the check
416aA*
416aAC                   if        expd >= $dto
710aDC*                  goto      skpxck
710aMC                   goto      enderr1
416aAC                   endif
416aA*
416aA*       Otherwise, see if it's an error or warning.
416aA*
416aA*         '1' = Allow Let it go through
416aA*         '2' = Error (not allowed)
510eA*         '3' = Warning.
416aA*
416aAC                   eval      error = *on
416aAC                   if        immflg = 'Y'
416aAC                   eval      *in27 = *on
416aAC                   eval      *in07 = *on
416aAC                   else
416aAC                   eval      *in24 = *on
416aAC                   eval      *in04 = *on
416aAC                   endif
416aAC                   eval      errmsg = *blanks
416aAC                   eval      erentd = expd
416aAC                   eval      ertod = $dto
416aAC                   select
416aAC                   when      svexck = '2'
416aAC                   eval      dtchk2 = *off
416aAC                   if        immflg = 'Y'
416aAC                   exsr      zm3232
416aAC                   else
416aAC                   exsr      zm3230
416aAC                   endif
416aAC                   when      svexck = '3'
416aAC                   eval      dtchk2 = '2'
416aAC                   eval      warn = *on
510eDC*                  eval      oaovr = *on
500cDC*                  eval      cwovr = *on
416aAC                   if        immflg = 'Y'
510eAC                   eval      oaovr = *on
416aAC                   exsr      zm3233
416aAC                   else
510eAC                   eval      ofovr = *on
416aAC                   exsr      zm3231
416aAC                   endif
416aAC                   endsl
416aA*
416aAC     error         cabeq     *on           enderr1
710aAC     enderr1       tag
710aA*  End of date checking code.
710aAC                   endsr
640hA*----------------------------------------------------------------
640hA*  clr$item  Clear $item data structure fields
640hA*----------------------------------------------------------------

640hAC     clr$item      begsr
640hAC                   eval      savever# = $itver#
640hAC                   clear                   $item
640hAC                   clear                   $item2
640hAC                   eval      $itver# = savever#
640hAC                   endsr

650tA*----------------------------------------------------------------
650tA*  clr$uciinfo  Clear $uciinfo data structure fields
650tA*----------------------------------------------------------------

650tAC     clr$uciinfo   begsr
650tAC                   eval      savever# = $uiver#
650tAC                   clear                   $uciinfo
720bAC                   clear                   $uciinfo2
650tAC                   eval      $uiver# = savever#
650tAC                   eval      $uiaddemp = 0
650tAC                   eval      $uiaddusr = #curruser
650tAC                   eval      $uiaddpgm  = #pgm
650tAC                   eval      $uiaddjob  = #job
650taC                   eval      $uiaddnbr = #jobnbr
650tAC                   endsr

650tA*----------------------------------------------------------------
650tA*
650tA*  ZZUCIADD Add weight record to uciinfo.
650tA*
650tAC     zzuciadd      begsr
650tA /free
650tA   exsr clr$uciinfo;
650tA   $uiWhse = $pwhse;
650tA   $uiItem = $pitem;
650tA   $uiuci = %editc(w1twgt:'X');
650tA   ucilic#($unext: $pwhse);
650tA   unexta = %editc($unext:'X');
650tA   $uiuciLcns = 'U:' + unexta;
650tA   $uiLcns = 'T' + $ppo + %editc($pseq:'X');
720bA   $uialcns = $uilcns;
720bA   $uiaolcns = $uilcns;
650tA   $uiseq = 1;
650tA   $uiSerial = ' ';
700bA   Select;
700bA     when svopwum = 'KGS'
700bA      or svopwum = 'kgs'
700bA      or svopwum = 'Kgs';
700bA       $uiwgtkgs = w1twgt;
700bA       $uiWgtlbs = 0;
700bA     other;
650tA       $uiwgtlbs = w1twgt;
650tA       $uiWgtKgs = 0;
700bA   endsl;
650tA   $uiSelTrn# = 0;
650tA   $uiSelLbl# = 0;
650tA   $uiSelOrd = 0;
650tA   $uiSelSeq = 0;
650tA   $uiSelCSeq = 0;
650tA   $uiSelTrax = ' ';
650tA   $uiCrtBy = '7';

650tA   $dricommand = '*UCIINFO';
650tA   $drisubcmd  = '%ADD';
650tA   $drisys2upd = 'D';
650tA   chk4err = *on;
650tA   zmflag  = *off;
650tA   exsr zzzdricop;
650tA   if error = *on;
650tA     uciExists = *on;
650tA     error = *on;
650tA     errmsg= desc(9);
650tA     exsr zm02;
650tA     leavesr;
650tA   else;
650tA     UciExists = *off;
650tA     error = *off;
650tA   endif;
650tA /end-free
650tAC                   endsr
650tA*----------------------------------------------------------------
650tA*
650tA*  ZZUCI    Delete UCI records.
650tA*
650tA /free
650tA   begsr zzuci;
650tA     exsr clr$uciinfo;
650tA     // warehouse
650tA     $uiWhse = $pwhse;

650tA     // This is a temporary catch weight license
650tA     $uiLcns = 'T' + $ppo + %editc($pseq:'X');

650tA     $dricommand = '*UCIINFO';
650tA     $drisubcmd  = '%CANCEL';
650tA     $drisys2upd = 'D';
650tA     chk4err = *on;
650tA     zmflag  = *off;
650tA     exsr zzzdricop;
650tA   endsr;
650tA /end-free
650tA*----------------------------------------------------------------
650tA*
650tA*  ZZUCICHK Check to see if UCI's have been entered for CW
650tA*
650tA /free
650tA   begsr zzucichk;
650tA     exsr clr$uciinfo;
650tA     // warehouse
650tA     $uiWhse = $pwhse;

650tA     // This is a temporary catch weight license
650tA     $uiLcns = 'T' + $ppo + %editc($pseq:'X');

650tA     $dricommand = '*UCIINFO';
650tA     $drisubcmd  = '%GETLICREC';
650tA     $drisys2upd = 'D';
650tA     chk4err = *on;
650tA     zmflag  = *off;
650tA     exsr zzzdricop;
650tA     if error = *on;
650tA       // No detail records in uciinfo for cw
650tA       // Write one summary record
650tA       exsr zzuciadd;
650tA       error = '0';
650tA     endif;
650tA   endsr;
650tA /end-free
640hA*----------------------------------------------------------------
640hA*  zzzdricop  Call DRICOP
640hA*----------------------------------------------------------------

640hAC     zzzdricop     begsr
640hAC                   eval      error = *off

640hAC                   select
640hAC                   when      $dricommand = '*ITEM'
640hAC                   eval      $dridata = $item
640hAC                   eval      $dridata2 = $item2
650tAC                   when      $dricommand = '*UCIINFO'
650tAC                   eval      $dridata = $uciinfo
720bAC                   eval      $dridata2 = $uciinfo2
640hAC                   endsl

640hAC                   if        $dricommand = '*ITEM' or
720bAC                             $dricommand = '*UCIINFO'
640hAC                   call(e)   'DRICOP'
640hAC                   parm                    $dricommand
640hAC                   parm                    $drisubcmd
640hAC                   parm                    $drisys2upd
640hAC                   parm      #pgm          $driprogram
640hAC                   parm      ' '           $drireturn
640hAC                   parm      ' '           $drimessage
640hAC                   parm                    $dridata
640hAC                   parm                    $dridata2
640hAC                   else
640hAC                   call(e)   'DRICOP'
640hAC                   parm                    $dricommand
640hAC                   parm                    $drisubcmd
640hAC                   parm                    $drisys2upd
640hAC                   parm      #pgm          $driprogram
640hAC                   parm      ' '           $drireturn
640hAC                   parm      ' '           $drimessage
640hAC                   parm                    $dridata
640hAC                   endif

640hAC                   select

640hAC                   when      chk4err and %error
640hAC                   eval      error = *on

640hAC                   when      chk4err and $drireturn <> '*OK'
640hAC                   eval      error = *on

640hAC                   endsl

640hAC                   select
640hAC                   when      $dricommand = '*ITEM'
640hAC                   eval      $item = $dridata
640hAC                   eval      $item2 = $dridata2
650tAC                   when      $dricommand = '*UCIINFO'
650tAC                   eval      $uciinfo = $dridata
720bAC                   eval      $uciinfo2 = $dridata2
640hAC                   endsl

640hAC                   eval      zmflag = *off
640hAC                   eval      zmsflag = *off
640hAC                   eval      chk4err = *off
640hAC     enddricop     endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Normal quantity
Breakdown 1 quantity
Breakdown 2 quantity
Catch weight
Average
UPC code
Number of pallets
* * INVALID ITEM * *
F7 only for c/w's
Tie/Hi Qty on Pallet
F9=CwEnt not allowed
No F20 CW out of tol
PTI Code
**
Item (
Base (
SSB (
Item  . . . .
**
(Type ' ')
**
Catch weight (Ttl or Avg) .
Catch weight (Total)  . . .
Catch weight (Average)  . .
**  CMDLN - Command display line
F7=Kilograms  F8=Tie/Hi  F9=Cwgt Entry  F11=Mfr Code
F7=Pounds  F8=Tie/Hi  F9=Cwgt Entry  F11=Mfr Code
F7=Kilograms  F8=Tie/Hi  F9=Cwgt Entry
F7=Pounds  F8=Tie/Hi  F9=Cwgt Entry
F8=Tie/Hi  F11=Mfr Code
F8=Tie/Hi
F3=Exit  F5=Refresh  F12=Cancel  F20=Accept warning
F9=Skip
