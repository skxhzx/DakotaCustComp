417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  Note: IF PROGRAM CHANGES, MAKE CHANGES TO PO232 & PO200.
     *
413bA*  Note: The standard routine DSPSCR was modified for option
     *        *QUICK. This option bypasses displaying the screen
     *        and goes straight to checking the input fields. The
     *        screen will displayed if an error occurs.
     *
     *----------------------------------------------------------------
     *
     *  PO132     PO receiving - Change
     *  08 October, 1996
     *  Hemant Kapadia
     *
     *
     *----------------------------------------------------------------
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
409 A*    02/18/98  RH
     *         - If item is not FSWMS, update PO file only (RC161)
     *
409 A*    05/21/98  HNK 4.09
     *         - Manufacturing date field added. Item will be rejected
     *           if the Receive date is > Latest acceptable date.
     *         - ITEMMSC file added.
     *         - POMFR   file added.
     *         - LABEL2  file added.
     *
409 A*    06/01/98  HNK 4.09
     *         - Condition to check Mfg date changed from indicator 98
     *           to IMMFLG.
     *         - Set IMMFLG to 'N' when no record is found.
     *         - Setof indiocators 1 thru 10.
     *
412 A*    07/21/99  HNK  4.12
     *         - Override logic added for mfg date sensitive item.
     *
412 A*    08/06/99  RH   4.12
     *      - Recompile, ITEMMSC file changed.
     *
413aA*    09/20/99  MLB  4.13
     *         - Modified program to all call to pregram xx123 to
     *           display receiving logic tracking.
     *
413bA*    10/27/99  DAS  4.13
     *      - Added command *QUICK for doing a quick receive.
     *        This option essentially skips displaying the entry
     *        screen and goes right to the checks.
     *        **** Std routine DSPSCR was modified ****
     *
413cA*    11/11/99  DAS  4.13a
     *      - Setoff *INKC and *INKL in routine ZZINZ2. They were being
     *        left on when doing *QUICK receiving.
413dA*    12/16/99  RH   4.13d
     *      - Fix to not write record to POMFR if not Mfg. date item. g
413eA*    02/09/00  RH   4.13
     *      - Add Pack and default tie/hi to screen.
     *      - Add F8 to call tie/hi maint.
413fA*    02/21/00  RH   4.13f
     *      - Add CW variance check if CW is entered.
     *        Use Item variance and system variance checks (see CW112)
413gA*    02/23/00  RH   4.13g
     *      - Add code to force individual F20 to be taken for each
     *        warning condition.
     *
415 A*    02/16/01  DAS  4.15
     *      - Add code to write a record to PORCV for each pallet
     *        that was received when not using license plates.
     *
415bA*    03/06/01  RH   4.15b
     *      - Allow Use by date to be entered in expire date field.
     *      - Calculate to verify use by date item can be received.
     *
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
     *      - Revised ZZUPD1 to NOT lock the UPC record when chaining.
     *
416 A*    09/24/01  DAS  4.16
     *      - Added tables LBL and TYP to assist with descriptions.
     *      - Revised format for displaying descriptions correctly.
     *      - Revised ZZUOM to create descriptions correctly.
     *      - Revised ZZINZ2 to clear message queue
     *      - Revised ZZFIL1 to get home slot of base item if item
     *        is not type ' ' or 'B'.
     *      - Revised to only use the main qty entry field with the
     *        UOM for Brk1 when receiving an SSB item.
     *
416aA*    09/24/01  DAS  4.16a
     *      - Revised to use new receiving option for expiration dates
     *
416bA*    09/24/01  DAS  4.16b
     *      - Revised to use subprogram GETPSLT to get pick slot.
     *      - Removed SLOT3 file because of above change.
     *
416cA*    09/25/01  DAS  4.16c
     *      - Revised to calculate EXPD when using Mfr date.
     *
416dA*    09/26/01  DAS  4.16d
     *      - Revised to use new receiving options for catch weights.
     *
416eA*    09/26/01  DAS  4.16a
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
     *      - Revised where ITMEXCP record is written.
     *      - Revised to move LBQPCK to ITMEXCP record.
     *
416hA*    10/27/01  DAS  4.16h
     *      - Revised size of W1DWGT in FM to 9.2 from 7.2.
     *      - Revised corresponding fields in this program.
416iA*    12/03/01  RH   4.16i
     *      - Recompiled, ITMEXCP file changed.
     *
416jA*    04/12/02  DAS  4.16j
     *      - Added parameters to GETPSLT call.
416kA*    05/23/02  RH   4.16k
    A*      - PORCV file changed, initialize POREDT and PORETI.
416lA*    07/02/02  RH   4.16l
     *      - Recompiled, ITEMMSC changed.
     *
417 A*    04/11/03  MLB  4.17
     *      - Enh: Add call to Retail UPC prompt program. This program
     *        will verify if Retail UPC is on file.
     *      - Added 3 new fields to *RCVLVL. OPRUPC, OPRUPS and OPRUPF.
417aA*    04/03/03  RH   4.17a
     *      - Recompiled, ITEMMSC file changed.
     *      - Add code to check expiration date using # of days out.
     *      - UPC can have multiple items, change to use UPC2 file.
417bA*    04/10/03  MLB  4.17b
     *      - Enh: Revised qty received error checking to include
     *        total exception qty. Added file POEXCP to program.
417cA*    04/15/03  MLB  4.17c
     *      - Enh: Extended length of UPC field to 50 characters and
     *        renamed field W1UPCD.
417dA*    04/28/03  MLB  4.17d
     *      - Fix: Correct error indicators used in ZZCHK1.
     *        Revised ZZCHK1 to clear EXPD when mfg date has error.
417eA*    05/13/03  MLB  4.17e
     *      - Fix: Revised ZZUPD1 to use field W1UPCD instead
     *        of W1UPC
417fA*    05/14/03  MLB  4.17f
     *      - Enh: Add support for lot/license tracking.
417gA*    05/14/03  MLB  4.17g
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
417nA*    07/22/03  RH   4.17n
     *      - FIX:Move code to calculate CKEXDT, was not calculated
     *            in some cases.
417pA*    01/20/04  RH   4.17p
     *      - ENH:Allow Entered (FIFO) date to be entered for MOVEIN
     *        PO. Vendor name='MOVEIN'or MOVEIN PICK. Add W1FIFO field
     *        Call RC160 with $RFIFO
417qA*    08/11/04  RH   4.17q
     *      - Fix: Revised to call GETSLOTITM, if the item was an
     *        alias item for a SSB item, GETBASE would return the SSB
     *        item which is not a slot item.
     *
500 A*    11/11/04  MLB  5.00
     *      - Fix: Revised ZZUPD1 to only convert W1FIFO date if
     *        ind 89 off and W1FIFO date entered.
500bA*    12/27/04  RH   5.00b
     *      - ENH: Add CMD *CHANGES for special receive, call RC160
     *        with *RETURN to force product to pick slot.
     *
500cA*    04/02/05  DAS  5.00c
     *      - ENH: Added parameters to PO136 call to bring it in line with
     *        PO232 call to PO236.
     *      - ENH: Revised to always call PO136 because this is where
     *        license history is updated.
     *      - ENH: Revised set on *IN65 for non-live department. This will
     *        override iaflag (non-FSWMS item).
     *      - ENH: Revised to call PO236 instead of PO136 for an item in
     *        a non-live department.
     *
500dA*    04/02/05  DAS  5.00d
     *      - Revised to use CLCDUR2 instead of julian routines.
     *        (This was a 417r change in PO232)
     *      - Recalculate EXPD in ZZUPD1 routine for Mfr dated items.
     *        (This was a 416i change in PO232)
     *      - FIX:Use W1UPC and W1UPCD to test for add to prevent
     *        blank UPC code in file.
     *        (This was a 417n change in PO232)
     *
500eA*    04/19/05  DAS  5.00e
     *      - Enh: Revised program to add support for Client id
     *
500fA*    04/20/05  DAS  5.00f
     *      - Enh: Revised to send *STUFFIT to PO136 for 52=StuffIt.
     *
510aA*    07/31/06  RH   5.10a
     *      - ENH: Add OBOVR flag to write exception when F20 ovrride
     *        is taken for mfg date error. (5.00c in PO232)
     *        Change CWOVR field used to OAOVR field for clarity.
     *      - FIX: Change to use seperate flags for date checks to
     *        allow override correctly.  (5.00d in PO232)
     *      - FIX: Expiration/#days out override was not working
     *        Dtchk flag was getting being set off in a wrong place.
510cA*    10/12/06  RH   5.10c
     *      - Enh: Revised program to send date keyed in in place
     *        of Mfg date parm.
510dA*    10/26/06  RH   5.10d
     *      - Fix: Initialize license date fields, was writing for
     *        non-dated item.
510eA*    12/27/06  RH   5.10e
     *      - Enh: Write different exception for each date override.
     *        Add OEOVR and OFOVR flags, each override sets a flag.
510fA*    10/02/07  LMC  5.10f
     *      - Enh: Added Call to Mfr Code Decipher program
510gA*    10/09/07  LMC  5.10g
     *      - Enh: Added UPC code to Code Decipher program
510hA*    10/11/07  LMC  5.10h
     *      - Enh: Added call to MF200 with *open to determine if the
     *        date code decipher programs exist on the client site.
510iA*    11/28/07  MLB  5.10i
     *      - Enh: Revised program to add support for Standard weight
     *        items. Standard wgt items will be treated just like
     *        random weight items. ITCWGT=S=Standard weight item.
510jA*    12/03/07  LMC  5.10j
     *      - Enh: Write ITMEXCP record if invalid date is returned
     *        from the date code decipher programs.
510kA*    01/13/08  LMC  5.10k
     *      - Enh: Cmd11 - only valid on date sensitive items
     *
530 A*   02/11/10  MLB  5.30
     *     - Fix: Revised ZZCMD1 to clear $LEXPDAT, $LMFRDAT and
     *       $LRTN when F11 =Mfr Decipher is selected to ensure that
     *       previously processed mfr date data is not used for
     *       the current item being received.
530cA*    03/29/10  RH   5.30c
     *      - Enh: Add code to use DRI programs to create virutal
     *        slots
     *
610aA*    09/01/09  DAS  6.10a
     *      - Revised to not set lflag off for *CHANGES. Re: We are
     *        now creating PORCV records in PO136 for *CHANGES.
610bA*    09/10/09  RH   6.10b
     *      - Enh: Add convert qty to display on order qty. ZZCVQY
640aA*    01/13/11  RH   6.40a
     *      - Enh: Add Whse to CHKLIVE parms
640bA*    05/22/12  RTR  6.40b
     *      - Fix: Always error if catchweight is negative
640cA*    07/13/12  LMC  6.40c
     *      - Enh: return decipher code to pass to licinfo file
     *      - Fix: found mods 530b in po232 applied as 640c to fix
     *        data being passed to MF200.
640dA*    09/20/12  RH   6.40d
     *      - Enh: Change to use wk field to pass mfg shelf life days
     *        to allow use of other values to be used in calculations
640eA*    10/09/12  LMC  6.40e
     *      - Enh: Added Brand field. Pass it to PO136.
     *        Created new display file PO13201 to replace PO132FM.
     *        Added Dri programs for *item.
640fA*    12/18/12  LMC  6.40f
     *      - Fix: Revised program to set W1EXDT, W1MFDT to zeros if
     *        return from MF200 returned with an error and the user
     *        had previously keyed an invalid date into the screen
     *        expiration or mfg date field.
     *
650 A*    03/08/13  MLB  6.50
     *      - Fix: Revised pgm to check if value loaded into exqty > 999
     *        and if yes, then set exqty = 999. Error found at Get
     *        Fresh who stores watermelon in lbs in qty fields.
650aA*    03/22/13  LMC  6.50a
     *      - Enh: Add logic for passing parms needed for haccp cross
     *      reference file.
650bA*    05/16/13  LMC  6.50b
     *      - Enh: Added RCVPO transaction.
650cA*    06/19/13  LMC  6.50c
     *      - Enh: Pass parm to call for PO236/PO136 for GTIN.
     *      Used in calculating PTI for the LICINFO file.
     *      - Enh: Added parm to pass GTIN from PO120 for PTI.
650dA*    07/31/13  LMC  6.50d
     *      - Enh: Added Catch weight override to exception processing
650eA*    09/23/13  LMC  6.50e
     *      - Fix: Lock on chain to POCTYPE, was causing error.
650fA*    10/28/13  LMC  6.50f
     *      - Enh: Added PTI entry edit, with override.
     *      - replaced display file PO13201 with PO13202.
650gA*    10/07/13  LMC  6.50g
     *      - Fix: write pocwexcp everytime
650hA*    11/11/13  LMC  6.50h
     *      - Fix: ERLRNG & ERHRNG were being wiped out when the
     *        a tie/high error was issued, I was using those fields
     *        to write the POCWEXCP file, but when the tie/high error
     *        error occurred it clears the $mdt data structure losing
     *        the value of the fields for the write to the POCWEXCP
     *        file. Moving the value of those fields when they are
     *        populated on the warning to the fields in the POCWEXCP
     *        file to eliminate the dec data error that was occurring.
650iA*    03/08/13  LMC/RH  6.50i (6.50c in PO232)
     *      - Fix: Move calculated check date to RCV exception date
     *      when entered date > today + # of days out (CKEXDT)
650kA*    12/03/13  RH  6.50k
     *      - Fix: Add error check for W1MFDT=0 before dates are
     *      processed.  Prevent 0 date from being processed in error
     *      when other field overrides are taken.
650lA*    12/05/13  RH   6.50l (6.50e mod in PO232)
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
650mA*    03/10/14  LMC  6.50m
     *      - Enh: Added preferred slot definition to screen display
     *        Renamed screen format from PO13705 to PO13706
650nA*    05/13/14  LMC  6.50n
     *      - Fix: PTI edit should only occur if *in73 is off.        d,
     *
650oA*    06/09/14  LMC  6.50o
     *        Pass new blank oss parm to PO236.                       d,
700aA*    04/06/16  LMC  7.00a
     *      - Enh: Adding logic for Metric.
700bA*    09/21/16  LMC  7.00b
     *      - Enh: Adding New screen for capturing breakdown UPC.
     *        This screen will display before the detail entry screen.
720aA*    01/23/18  RH/MLB 7.20a
     *      - Fix: Pick slot receiving was not getting keyed date
     *        Added code to set date(510c mod) used for PO236
     *
720bA*    10/12/18  LMC  7.20b
     *      - Enh: Before calling PO136 for license plates, we need
     *        to print box labels if item is coded for printing
740aA*    02/04/20  LMC  7.40a
     *      - Enh: Use the UOM from the $item.
740bA*    03/30/20  LMC  7.40b
     *      - Enh: Edits for # of days out should not apply for
     *        Manufacturer dated items. Only if Expiration date
     *        is entered.
740c *    05/22/20  LMC  7.40c
     *      - Enh: Send Vendor to all calls of CVTBAR so that the
     *        new decipher barcode process works.
750a *    08/23/21  LMC  7.50a
     *      - Enh: Directed putaway is not allowed for breakdown
     *        Receiving.
760a *    05/10/22  LMC  7.60a
     *      - Enh: Protect UPC entry field on screen1 if the receiving
     *        option OPNUPC is set to Y, to not allow upc's to be
     *        loaded during receiving.
     *
770aA*   08/27/22  TDC  7.70b
     *      - DockVue: Added update of POSTATUS table when the PO is
     *        updated.
     *      - Added check for the dockvue system option (opdckv)
     *----------------------------------------------------------------
     * Saval's Custom Mods
     *
SVLaA*   09/10/09  RH   SVLa
     *     - Added ordered qty to screen 1.
SVLbA*   03/24/10  RH   SVLb
     *     - Revised to create a Virtual pick slot for any items for
     *       in Virutal Whse Pick file.
     *----------------------------------------------------------------
     * YHata's Custom Mods
YHAaA*   09/20/12  RH   YHAa
     *     - Calculate pack date for Date senstitive only item using  tion
     *       # of days out - 1. Store in LICINFO code *MFGDTE         tion
     *----------------------------------------------------------------
     * Kohl Wholesale Custom Mods
     *
KHLa *   08/31/14  RTR  KHLa
     *     - Write new UPC Code to ITMEXCP file for reporting
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   Field position to
     *  21 - 40   Field input error (reverse display)
413aA*  55        Enable function key F17
510hA*  66        Date Code Decipher check to non display cmd11
417gA*  88        Lot code entry not allowed. Hide fields.
417pA*  89        FIFO entered date entry not allowed. Hide fields.
     *  90        View mode (Protect input fields)
     *  91        Change mode (protect key)
     *  97        Error message subfile indicator
     *  98        Error on screen (sound buzzer)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Jordano's Custom Mods
     *
JDO A*   04/19/05  DAS  JDO
     *     - Revised to treat all items for vendor 3194 as being from a
     *       "live" department. This is the Bread vendor and the items
     *       are in the REF department for host picking purposes.
     *     - Revised to create a Virtual pick slot for any items for
     *       vendor 3194.
JDObA*   03/21/06  RH   JDOb
     *     - Set IN01 on to position to qty field not UPC.
JDOcA*   03/09/10  RH   JDOC
     *     - Revised to create a Virtual pick slot for any items for
     *       vendor 3194 in DRY
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *
640eDF*po132fm   cf   e             workstn
650fDF*po13201   cf   e             workstn
650mDF*po13202   cf   e             workstn
700ADF*po13203   cf   e             workstn
700bDF*po13204   cf   e             workstn
700bMFpo13205   cf   e             workstn
     F                                     infds(infds)
219 D*ODTL   UF  E           K        DISK
219 MFpodtl     if   e           k disk
     F                                     rename(pdrec:record)
417bAFpoexcp    if   e           k disk
218 D*OH     UF  E           K        DISK
218 MFpohdr     uf   e           k disk
     Fpiritem   if   e           k disk
     Fwarehs    if   e           k disk
214 AFunmesr    if   e           k disk
219 AFitemdsc   if   e           k disk
219 AFoptions   if   e           k disk
417aD*PC     UF  E           K        DISK                      A
417kAFupc3      uf a e           k disk
417kA*PC2    UF  E           K        DISK                      A
417aD*           UPREC                             KRENAMEU2REC
417jAFupc1      if   e           k disk
     F                                     rename(uprec:u1rec)
416bD**OT3   IF  E           K        DISK
TMP AFslot2     if   e           k disk
     F                                     rename(slrec:s2rec)
409 AFitemmsc   if   e           k disk
409 AFLabel2    if   e           k disk
413eAFitemdef   if   e           k disk
416fAFpoctype   uf a e           k disk
SVLbAFpovpck    if   e           k disk
409 AFpomfr     o    e             disk
415 AFporcv     o  a e           k disk
416eAFitmexcp   o    e           k disk
417pAFpofifo    o    e           k disk
650dAFpocwexcp  uf a e           k disk    Prefix(cw_) rename(exrec:cwexrec)
770aA*----------------------------------------------------------------
770aA*  Standard SQL variables and constants
770aA*----------------------------------------------------------------
770aA
770aA /copy qcopysrc,c#stdsql

700aA*----------------------------------------------------------------
700aA* Function prototypes.
700aA*----------------------------------------------------------------

700aA /copy qcopysrc,p.getimuom

740cA*----------------------------------------------------------------
740cA*  Convert Barcode Parms
740cA*----------------------------------------------------------------

740cA /COPY *libl/qcopysrc,C#CVTPARMS
740cA /COPY *libl/qcopysrc,C#BARCODE
530cA*----------------------------------------------------------------
530cA*  DRI parameters
530cA*----------------------------------------------------------------
530cA
530cA /COPY *libl/qcopysrc,C#DRIPARMS
530cA
530cA*----------------------------------------------------------------
530cA*  Data Formats
530cA*----------------------------------------------------------------
530cA
530cA /COPY *libl/qcopysrc,C#SLOT
640eA /COPY *libl/qcopysrc,C#ITEM
530cAD saveVer#        s                   like($slver#)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
416 AD a13             s              1    dim(13)
416 D**                  DESC    1   6 20
219 D*                   DESC    1   5 20
219 D*                   DESC    1   4 20
650fDD*desc            s             20    dim(7) ctdata perrcd(1)
650fMD desc            s             20    dim(8) ctdata perrcd(1)
416 AD lbl             s             13    dim(4) ctdata perrcd(1)
416 AD typ             s             10    dim(1) ctdata perrcd(1)
416dAD cwt             s             27    dim(3) ctdata perrcd(1)
700bDD*cmdln           s             79    dim(7) ctdata perrcd(1)
700bMD cmdln           s             79    dim(8) ctdata perrcd(1)

650aAD $parms1         s             48    dim(20)
500eA*----------------------------------------------------------------
500eA*  Customer id
500eA*----------------------------------------------------------------
500eA
500eA /copy qcopysrc,id#jordano
SVLaA /copy qcopysrc,id#saval
YHAaA /copy qcopysrc,id#yhata
KHLaA /copy qcopysrc,id#khl
500eA
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
750aAD  $svmput               68     68
416eA*----------------------------------------------------------------
416eA*  Redefinition data structures
416eA*
416eAD                 ds
416eAD  dspo                   1      9
416eAD  dslbl                 10     16  0
416eAD  dsexpd                17     24  0
416eAD  dsfdis                 1     12
416eAD  dstdis                13     24
610b D $cerm           ds
610b D  xcerm                  1     60
610b D  $cmsg                  1      4
417p *----------------------------------------------------------------
417p *  Constants
     D move1           c                   const('MOVEIN PICK')
     D move2           c                   const('MOVEIN OVERFLOW')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @getsi          c                   const('GETSLOTITM')
     D @fmtit          c                   const('FRMTIT')
650bAD @crtrcv         c                   const('CRTRCVTRN')
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
417fAD  $llott                64     64
417fAD  $llict                65     65
     *
TMP AD  $lwhs2                19     21  0
TMP AD  $lwhd2                22     26
TMP AD  $litm2                27     41
TMP AD  $ldisp                42     53
TMP AD  $ldesg                54     58
TMP AD  $lst                  59     60
TMP AD  $lsdef                61     62
TMP AD  $lactv                63     64
415dA*
415dAD  $lwhs3                19     20p 0
415dAD  $lpo3                 21     29
415dAD  $lseq                 30     32p 0
415dAD  $litm3                33     47
415dAD  $lqyr1                48     50p 0
415dAD  $lqyr2                51     53p 0
415dAD  $lqyr3                54     56p 0
415dAD  $lcwte                57     59p 0
415dAD  $lcwtt                60     64p 2
415dAD  $lcwta                65     68p 2
417fA*
417fAD  $llot                 37     37
417fAD  $lltrk                38     38
510fA*
640cDD* $lmfr#                19     29  0
640cDD* $lmfritem             30     44
640cDD* $ldakitem             45     59
640cMD  $lmfr#                22     32  0
640cMD  $lmfritem             33     47
640cMD  $ldakitem             48     62
221 A*
417fA*----------------------------------------------------------------
417fA*  Working fields.
417fA*
417fAD                 ds
417fAD  lottrk                 1      4
417fAD  lictrk                 5      8
     *
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
640bDD* errmsg                 1     50
640bMD  errmsg                 1     78
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
415bA*
415bAD  erused                 1      4p 0
415bAD  erdisd                 5      6p 0
415bAD  erusrd                 7      8p 0
415bAD  ersell                 9     12p 0
413fA*
413fAD  ertcwt                 1      5p 2
413fAD  erlrng                 6     10p 2
413fAD  erhrng                11     15p 2
413fAD  errg1c                16     17p 1
413fAD  errg2c                18     19p 1
413fAD  erexwt                20     24p 2
     *
413f D  ertcw#                 1      3p 0
413f D  erqpck                 4      6p 0
     *
416aAD  erentd                 1      5p 0
416aAD  ertod                  6     10p 0
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
219 A* Data structure
219 A*
417 A*    OPRUPC  -  Prompt user for Retail UPC during receiving? (Y,N)
417 A*    OPRUPS  -  Allow user to skip Retail UPC scan? (Y,N)
417 A*    OPRUPF  -  Require Retail UPC on file before receipt? (Y,N)
760aA*    OPNUPC  -  Do Not allow UPC's to be loaded during receiving
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
760aAD  opnupc                62     62
413fA*  *SYSTEM  -  System options.
413f *    OPEPM   -  Using EPM module (Y,N).
413f *    OPRF    -  Using RF module (Y,N).
413f *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
413f *    OPLETD  -  Print letdown labels (Y,N).
413fA*    OPWRNC  -  Perform catch weight variance check (Y,N).
413fA*    OPRG1C  -  Catch weight low variance percentage.
413fA*    OPRG2C  -  Catch weight high variance percentage.
413fA*    OPIMPI  -  Import item fields from host.(Y,N).
413fA*    OPICW   -  Individual catch weight entry (Y,N).
     *
413f D  opepm                  1      1
413f D  oprf                   2      2
413f D  opcapc                 3      3
413f D  opletd                 4      4
413fAD  opwrnc                 5      5
413fAD  oprg1c                 6      8  1
413fAD  oprg2c                 9     11  1
413fAD  opimpi                12     12
413fAD  opicw                 13     13
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
640eA /COPY *libl/qcopysrc,C#PGMINFDS
640eDD*               sds
640eDD* #prog            *proc
640eDD* #pgm             *proc
640eDD* #job                 244    253
640eDD* #user                254    263
640eDD* #jobn                264    269
640eDD* #jobdt               276    281  0
640eDD* #jobtm               282    287  0
650fA*----------------------------------------------------------------
650fA*  Prototypes
650fA*----------------------------------------------------------------
650fAD calcpti         pr                  extpgm('CALCPTI')
650fA * Input
650fAD   pGTIN                             like($pgtin)
650fAD   pLOT                              like($pbclot)
650fAD   pPackDate                         like($pbcProdD)
650fAD   pPTI                              like(pppti)
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

500dA*------------------------------------------------------------------
500dA* CLCDUR2 parameters
500dA*------------------------------------------------------------------

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

     *----------------------------------------------------------------
     *  Variables
     *
500cAD $ldwgt          s              9  2
500cAD $lflag          s              1
     D $lord           s              7  0
     D $lum1           s              5
     D $lum2           s              5
     D $lum3           s              5
500cAD $lven           s             11  0
500cAD $lvitm          s             15
500cAD $lvnam          s             40
650fAD $pw1pti         s              4  0
     D $msgf           s             10
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
500cAD avgwt1          s              7  2
500cAD avgwt2          s              7  2
500cAD avgwt3          s              7  2
700bAD b1type          s              7
700bAD b2type          s              7
700bAD b1upc           s                   like(upupc)
700bAD b2upc           s                   like(upupc)
530cAD chk4err         s               n
     D ckexdt          s              8  0
     D clear           s              5  0
     D cmdtkn          s              1
700aAD CnvWgt          s              9  2
     D comand          s              5  0
     D cwcalc          s              1  0
     D cwovr           s              1
     D date1           s              8  0
     D date16          s              6  0
     D date2           s              8  0
     D date2o          s              6  0
     D date26          s              6  0
510jAD ddcode          s              1
     D done            s              1
770aAD dockvue         s              1n    inz('0')
     D dtchk           s              1
     D dtchk2          s              1
510a D dtchk3          s              1
510a D dtchk4          s              1
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
     D hvskp           s              1
     D iaflag          s              1
     D iatest          s              1
     D ihrng           s              9  2
     D ihvar           s              9  2
     D ilrng           s              9  2
     D ilvar           s              9  2
700aAD kgs2lbs         c                   2.20462262
700aAD KiloLbs         s              1
700aAD IMkilolbs       s              1
700aAD IMUom           s              3
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
JDO AD jdobread        s               n
     D kypick          s                   like(slpick)
     D kystat          s                   like(slstat)
SVLb D kyven#          s             10  0
SVLb D kywhdp          s                   like(slwhdp)
     D lflag           s              1
     D ltstd6          s              6  0
     D ltstd8          s              8  0
     D lvskp           s              1
     D lwrng           s              9  2
     D lwvar           s              9  2
     D mfdtj           s              5  0
     D mfgd            s              8  0
640cAD mexpd           s              8  0
640cAD mfgdte          s              8  0
700bAD Needb1          s               n
700bAD Needb2          s               n
770aAD nostamp         s               z     inz
700bAD Ntype           s              7
     D nxtscr          s              3
     D ocode           s              8
510a D oaovr           s              1
510a D obovr           s              1
510e D ocovr           s              1
     D odovr           s              1
510e D oeovr           s              1
510e D ofovr           s              1
     D ovrrid          s              1
     D part            s              1
650bAD poppcs          s                   like($lrq1)
     D prg1c           s              4  3
     D prg2c           s              4  3
650fAd pplot           s             20
650fAd pppti           s              4  0
650fAD ptiovr          s              1
650fAD ptichk          s              1
650fAd ptinodate       s              6  0
     D qtchk           s              1
     D rcverr          s                   like(error)
650bAD rcvpocomplete   s               n
     D recv            s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D sdqrc1          s              5  0
     D sdqrc2          s              5  0
     D sdqrc3          s              5  0
     D sprcv           s              1
     D ssbflg          s              1
     D stop            s              1
     D svcwen          s              1
     D svcwfr          s              1
     D svcwtp          s              1
     D svdwgt          s              9  2
     D svexck          s              1
     D svexdt          s              6  0
     D svhi            s              2  0
650mAD svsdef          s              2
     D svmfdt          s              6  0
650fAD svpti           s              4  0
     D svqrc1          s                   like(pdqrc1)
     D svqrc2          s                   like(pdqrc2)
     D svqrc3          s                   like(pdqrc3)
     D svrupc          s              1
760aAD svnupc          s              1
     D svtie           s              4  0
     D svupc           s             50
     D temp10          s             10
     D tmpwgt          s              9  2
     D today           s              8  0
     D todayo          s              6  0
     D todyj           s              5  0
     D upchk           s              1
     D upchk2          s              1
     D uxflag          s              1
     D vrfycw          s              1
     D warn            s              1
     D whse            s              3  0
640dAD wkmday          s              3  0
     D wkwhse          s                   like($pwhse)
SVLb D wodisp          s             12
510cAD woexdt          s              8  0
     D wofifo          s              8  0
510cAD woindt          s              8  0
500cAD womfdt          s              8  0
     D work2           s              2
     D work4           s              4
     D wotcw           s              9  2
700bAD Writeb1         s               n
700bAD Writeb2         s               n
     D wrttyp          s              1
     D wtchk           s              1
     D w1item          s             15
     D w1upc           s                   like(upupc)
640eAD zmflag          s               n
640eAD zmsflag         s               n
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new batch.
     *              *EDIT    - Edit batch.
     *              *DELETE  - Delete batch.
     *              *PRINT   - Print batch edit listing.
     *              *POST    - Post batch.
413bA*              *QUICK   - Quick receive
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
640eAc                   parm                    $pexpdt           6 0
640eAc                   parm                    $pwgt            11 3
640eAc                   parm                    $pmfgdt           6 0
640eAc                   parm                    $plot            20
640eAc                   parm                    $plpn            50
640eAc                   parm                    $puci           100
640eAc                   parm                    $pxd              2
650aAc                   parm                    $parms1
650bAC                   parm                    $lsavetrn         7 0
650cAc                   parm                    $pgtin           14
650cAc                   parm                    $pbcProdD         6 0
650cAc                   parm                    $pbclot          20
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
650bAc                   eval      rcvpocomplete = *off
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
700bAC     nxtscr        caseq     '01B'         sc1b
     C     nxtscr        caseq     '02 '         sc2
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
650bA*
650bA*   check to see if po receipt is completed
650bA*   if completed update label/transaction with qty information
650bA*   else just mark them closed. - ended and closed dates
650bAC                   exsr      zzrcvpoclose
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
413bAC     $pcmd         cabeq     '*QUICK  '    skpdsp
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
700aAC                   write     cmdrec
     C                   exfmt     screen1                              50
     C                   endif
     *
700bAC                   if        nxtscr = '01B'
700bAC                   write     cmdrec
700bAC                   exfmt     screen1b                             50
700bAC                   endif
     *
     C                   if        nxtscr = '02 '
     **                   EXFMTSCREEN2                50
     C                   endif
     *
413bAC     skpdsp        tag
     *
     *   Initialize error indicators and fields
     *
409 AC                   setoff                                       010203
409 AC                   setoff                                       040506
409 AC                   setoff                                       070809
409 AC                   setoff                                       10
     C                   setoff                                       111213
650fAC                   setoff                                       17
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       303132
     C                   setoff                                       33
650fAC                   setoff                                       37
     C                   setoff                                       616263
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
413bAC                   if        $pcmd = '*QUICK  '
413bAC                   eval      $pcmd = '*CHANGE '
413bAC                   endif
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
700bA*----------------------------------------------------------------
700bA*
700bA*  Screen 01b initialization
700bA*
700bAC     scr01bi       begsr
700bA*
700bA*  This screen will get initiated if receiving options to
700bA*  capture upc's for breakdown is turned on.
700bA*
700bA*  We will display the screen1b if the item has breakdowns
700bA*  defined, and we do not have a UPC record for the breakdown uom
700bA*
700bA /free
700bA   writeb1 = *off;
700bA   writeb2 = *off;
700bA   w1buom1 = ' ';
700bA   w1bupc1 = ' ';
700bA   w1buom2 = ' ';
700bA   w1bupc2 = ' ';
700bA   // breakdown 1 is setup on item
700bA   if $itum2 <> ' ';
700bA     Needb1  = *on;
700bA     // do we have a upc loaded for this breakdown uom
700bA     setll ($pwhse: $pitem) upc1;
700bA     dow forevr = forevr;
700bA       reade ($pwhse: $pitem) upc1;
700bA       if %eof(upc1);
700bA         leave;
700bA       endif;
700bA       if upuom = $itum2;
700bA         needb1  = *off;
700bA         leave;
700bA       endif;
700bA     enddo;
700bA   endif;
700bA   // breakdown 2 is setup on item
700bA   if $itum3 <> ' ';
700bA     Needb2  = *on;
700bA     // do we have a upc loaded for this breakdown uom
700bA     setll ($pwhse: $pitem) upc1;
700bA     dow forevr = forevr;
700bA       reade ($pwhse: $pitem) upc1;
700bA       if %eof(upc1);
700bA         leave;
700bA       endif;
700bA       if upuom = $itum3;
700bA         needb2  = *off;
700bA         leave;
700bA       endif;
700bA     enddo;
700bA   endif;
700bA   // need to capture a breakdown upc
700bA   if needb1 = *on or needb2 = *on;
700bA     nxtscr = '01B';
700bA     exsr zzdft1b;
700bA   endif;
700bA /end-free
700bAC     end01ib       endsr
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
510iAC                             or itcwgt = 'S'
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
510iAC                             or itcwgt = 'S'
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

700aA*     Setup converted weight field.
700aAC                   exsr      zzcnvwgt

     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     C                   endif
     C                   exsr      zzuhdr
     C                   eval      nxtscr = 'EOJ'
     C     endsc1        endsr
700bA*----------------------------------------------------------------
700bA*
700bA*  SC1b -  Screen 1b
700bA*
700bAC     sc1b          begsr
700bA*
700bA*  Test for F3 - Exit
700bA*
700baC                   if        *inkc
700bAC     *loval        setll     record
700bAC                   eval      nxtscr = 'EOJ'
700bAC                   eval      $prtn = '*EXIT   '
700bAC                   goto      endsc1b
700bAC                   endif
700bA*
700bA*  Test for F5 - Refresh
700bA*
700bAC                   if        *inke
700bAC                   if        $pcmd <> '*VIEW   '
700bAC                   exsr      scr01bi
700bAC                   endif
700bAC                   goto      endsc1b
700bAC                   endif
700bA*
700bA*  Test for F12 - Previous
700bA*
700bAC                   if        *inkl
700bAC     *loval        setll     record
700bAC                   eval      nxtscr = 'EOJ'
700bAC                   eval      $prtn = '*CANCEL '
700bAC                   goto      endsc1b
700bAC                   endif
700bA*  Test for F9  - skip
700bA*
700bAC                   if        *inki
700bAC     *loval        setll     record
700bAC                   eval      nxtscr = '01 '
700bA*    Setup command display line 1.
700bA*
700bAC                   select
700bA*
700bAC                   when      itcwgt <> 'N' and itflgd = 'Y'
700bAc                             and KiloLbs = 'P'
700bAC                   eval      cmdln1 = cmdln(1)
700bA*
700bAc                   when      itcwgt <> 'N' and itflgd = 'Y'
700bAc                             and KiloLbs = 'K'
700bAC                   eval      cmdln1 = cmdln(2)
700bA*
700bAC                   when      itcwgt <> 'N' and itflgd = 'N'
700bAc                             and KiloLbs = 'P'
700bAC                   eval      cmdln1 = cmdln(3)
700bA*
700bAc                   when      itcwgt <> 'N' and itflgd = 'N'
700bAc                             and KiloLbs = 'K'
700bAC                   eval      cmdln1 = cmdln(4)
700bA*
700bAC                   when      itcwgt = 'N' and itflgd = 'Y'
700bAC                   eval      cmdln1 = cmdln(5)
700bA*
700bAC                   when      itcwgt = 'N' and itflgd = 'N'
700bAC                   eval      cmdln1 = cmdln(6)
700bA*
700bAC                   endsl
700bAC                   goto      endsc1b
700bAC                   endif
700bA*
700bA*  Test for other command keys
700bA*
700bAC                   exsr      zzcmd1b
700bAC     cmdtkn        cabeq     *on           endsc1b
700bA*
700bA*  Some other key pressed.
700bA*
700bA*     Check input and write/update record.
700bA*
700bAC                   if        $pcmd = '*ADD    '  or
700bAC                             $pcmd = '*CHANGE '
700bA
700bAC                   exsr      zzchk1b
700bAC     error         cabeq     *on           endsc1b
700bAC                   exsr      zzupd1b
700bAC     error         cabeq     *on           endsc1b
700bAC                   endif
700bA*  If error, then do not update P.O. header file
700bAC     $lrtn         cabeq     '*CANCEL '    endsc1b
700bAC     $lrtn         cabeq     '*EXIT   '    endsc1b
700bA*
700bAC                   eval      nxtscr = '01 '
700bAC     endsc1b       endsr
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
500dA* ************ DO NOT USE  -  USE CLCDUR2 INSTEAD **************
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
500dA* ************ DO NOT USE  -  USE CLCDUR2 INSTEAD **************
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

530cA*----------------------------------------------------------------
530cA*    DRI0001  Local system caused error
530cA*----------------------------------------------------------------
530cA
530cAC     zm0001        begsr
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
530c C                   endsr

415cA*   PIR0105  Invalid slot entered.
     *
415cAC     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
415cAC                   endsr
JDO A*----------------------------------------------------------------
JDO A*     PIR0105  General message sent back to calling program.
JDO A*
JDO AC     zm0105s       begsr
JDO AC                   eval      #msgid = 'PIR0105'
JDO AC                   eval      #msgtp = '*DIAG  '
JDO AC                   movea     errmsg        $md(1)
JDO AC                   exsr      zmsmsg
JDO AC                   eval      $pmsg = #msgk
JDO AC                   eval      $prtn = '*PGMQ'
JDO AC                   endsr
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
510kA*----------------------------------------------------------------
510kA*    ZM13250  Item not date sensitive.
510kA*
510kAC     zm13250       begsr
510kAC                   eval      #msgid = 'PO13250'
510kAC                   eval      #msgtp = '*DIAG  '
510kAC                   movea     errmsg        $md
510kAC                   exsr      zmpmsg
510kAC                   endsr
640bA*----------------------------------------------------------------
640bA*   PIR9999  Generic message - length 78 chars.
640bA*
640bAC     zm9999        begsr
640bAC                   eval      #msgid = 'PIR9999'
640bAC                   eval      #msgtp = '*DIAG  '
640bAC                   movea     errmsg        $md(1)
640bAC                   exsr      zmpmsg
640bAC                   endsr
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
413fA*----------------------------------------------------------------
413fA*   PT13019  Warning: Entered catch weight not within +/- range.
413fA*
413fAC     zm19          begsr
413fAC                   eval      #msgid = 'PT13019'
413fAC                   eval      #msgtp = '*DIAG  '
413fAC                   movea     errmsg        $md
413fAC                   exsr      zmpmsg
413fAC                   endsr
417jA*----------------------------------------------------------------
417jA*   PO23201  Error: UPC code exists for ventor/item.
417jA*
417jAC     zm21          begsr
417jAC                   eval      #msgid = 'PO23201'
417jAC                   eval      #msgtp = '*DIAG  '
417jAC                   movea     errmsg        $md
417jAC                   exsr      zmpmsg
417jAC                   endsr
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
650fA*----------------------------------------------------------------
650fA*   PO23203  PTI doesn't match calculated PTI.
650fA*
650fAC     zm3203        begsr
650fAC                   eval      #msgid = 'PO23203'
650fAC                   eval      #msgtp = '*DIAG  '
650fAC                   movea     errmsg        $md(1)
650fAC                   exsr      zmpmsg
650fAC                   endsr
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
409 A*     PO13228  Item cannot be accepted - Mfr date
409 A*
409 AC     zm3228        begsr
409 AC                   eval      #msgid = 'PO13228'
409 AC                   eval      #msgtp = '*DIAG  '
409 AC                   movea     errmsg        $md(1)
409 AC                   exsr      zmpmsg
409 AC                   endsr
415bA*----------------------------------------------------------------
415bA*     PO13229  Item cannot be accepted - Use by Date
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
510jA*   DDCODE= Invalid Date returned from the Decipher progrmas
510a *   CWOVR = Weight error override taken.
650fA*   PTIOVR= PTI override taken.
413g *   DTCHK, QTCHK, WTCHK Flags are used to force F20 for each test
650fM*   DTCHK2,PTICHK
413g *   Values: Flag = 0 Do check.
413g *           Flag = 1 Check was done, ok.
413g *           Flag = 2 Warning condition.
413g *
     C                   eval      error = *off
650bAc                   exsr      zzrcvpocheck
     *
     *  When adding ....
     *
     C                   if        $pcmd = '*ADD    '
     C                   endif
417lA*  Extract UPC code from entered string.
417lA*
417lMC                   if        w1upcd <> *blanks
417lAC                   eval      $cbcmd = '*UPC    '
417dD*R                   MOVELW1UPC     $CBBAR    P
417dMC                   eval      $cbbar = w1upcd
417lA*
417lAC                   call      'CVTBAR'
417lAC                   parm                    $cbcmd            8
417lAC                   parm                    $cbbar          100
417lAC                   parm                    $cbcod            3 0
417lAC                   parm                    $cbdec            1 0
417lAC                   parm                    $cbdsc           30
417lAC                   parm                    $cbpos            3 0
417lAC                   parm                    $cbtyp            1 0
417lAC                   parm                    $cbv1            11 3
417lAC                   parm                    $cbv2            50
417lAC                   parm                    $cbrtn            8
417lAC                   parm                    $cberm           60
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
417lAC                   endif
415cA*   Do UPC Check
417cD*R         W1UPC     IFNE *BLANKS                    Begin If
417cMC                   if        w1upcd <> *blanks  and
417lMC                             $pupc = *blanks
417cD*R         SVUPC     IFNE W1UPC
417cMC                   if        svupc <> w1upcd
415cAC                   eval      upchk = *off
417jAC                   eval      upchk2 = *off
415cAC                   endif
415cA*
415cAC                   if        upchk <> '2'  and
415cAC                             ovrrid = *on  and
417lAC                             $cbrtn <> '*INVALID'
415cAC                   eval      upchk = *on
415cAC                   endif
415cA*
415cAC                   if        upchk <> '1'
415cAC                   eval      upchk = *on
415cA*  Moved code to extract UPC code from entered string. see above.
415cA*  Extract UPC code from entered string.
415cA*
415cAC                   select
415cA*
415cAC                   when      $cbrtn = '*OK'
700bAc                   eval      ntype = %trimr($cbdsc)
417lD*R                   MOVEL$CBV2     $CSTR
417lD*R                   CALL 'ADJUST'
417lD*R                   PARM '*RIGHT  '$CCMD   8
417lD*R                   PARM           $CSTR  30
417lA*R                   MOVE *BLANKS   W1UPC
417lA*R                   MOVE $CSTR     W1UPC
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
415cD**         W1UPC     IFNE *BLANKS
415cD**                   MOVE *BLANKS   $CSTR
415cD**                   MOVELW1UPC     $CSTR
415cD**                   CALL 'ADJUST'
415cD**                   PARM '*RIGHT  '$CCMD   8
415cD**                   PARM           $CSTR  30
415cD**                   MOVE $CSTR     W1UPC
417lD*   Allow multiple upc for whse/item, must be different vendor.
417lD*   No longer need to check if UPC exists for WHSE/ITEM/UPC
417aA*R         UPCKY     CHAINUPC                 N79
417lD*R         UPCKY2    CHAINUPC2                N79
417lD*R         *IN79     IFEQ *OFF
417lA*R         UPITEM    IFNE $PITEM
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
417jAC                   if        upchk2 <> '2'  and
417jAC                             ovrrid = *on
417jAC                   eval      upchk2 = *on
417jAC                   endif
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
650fA * pti check
650fA /free
650fA       // calculate the PTI.
650nD       //if $pbclot <> ' ' and $pgtin <> ' ';
650nM       if $pbclot <> ' ' and $pgtin <> ' ' and *in73 = *off;
650fA         if w1pti = 0;
650fA           error = *on;
650fA           *in37 = *on;
650fA           *in17 = *on;
650fA           errmsg = desc(8);
650fA           exsr zm0110;
650fA         endif;
650fA       endif;
650fA /end-free
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
417p C                   endif
650kA *
650kA*  Verify manufacture date entered.
650kA*
650kAC                   if        immflg = 'Y' and
650kAC                             w1mfdt = 0
650kAC                   eval      error = *on
650kAC                   eval      dtchk4 = *off
650kAC                   eval      obovr = *off
650kAC                   eval      *in27 = *on
650kAC                   eval      *in07 = *on
650kAC                   eval      errmsg = *blanks
650kAC                   exsr      zm1008
650kAC                   goto      enderr
650kAC                   endif
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
417aA*
417nA*  Moved code here to calculate CKEXDT
417aA*  Verify Expiration date is within parameter (# of days out)     days)
417aA*  Calculate (Today + # days out)  = CHEXDT                       days)
417aA*
500dAC                   call      'CLCDUR2'
500dAC                   parm      '*ADD'        $cdcmd
500dAC                   parm      today         $cddatein
500dAC                   parm      0             $cdtimein
500dAC                   parm      0             $cdyears
500dAC                   parm      0             $cdmonths
500dAC                   parm      imoday        $cddays
500dAC                   parm      0             $cdhours
500dAC                   parm      0             $cdminutes
500dAC                   parm      0             $cdseconds
500dAC     ckexdt        parm      0             $cddateout
500dAC                   parm      0             $cdtimeout

500dDC**                 move      today         g$date
500dDC**                 eval      dtfrmt = 1
500dDC**                 exsr      gtoj$
500dDC**                 eval      todyj = g$jd
417aA*
500dDC**   todyj         add       imoday        j$jd
500dDC**                 exsr      jtog$
500dDC**                 eval      date16 = j$date
417aA*
500dDC**                 move      date16        $cvd6i
500dDC**                 eval      $cvcmd = '*YMDCMD '
500dDC**                 call      @cvtdt
500dDC**                 parm                    $cvtdt
500dDC**                 move      $cvd8o        ckexdt
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
214 AC                   if        expd <= today
214 AC                   eval      error = *on
214 AC                   eval      *in24 = *on
214 AC                   eval      *in04 = *on
214 AC                   eval      errmsg = *blanks
214 AC                   exsr      zm1009
214 AC                   endif
417nA*  Code to calculate CKEXDT was moved from here to above.
415bA*
415bA*  Verify Use by date.                                            days)
415bA*  Calculate (Today + Dist Days)  = DATE1                         days)
415bA*  Calculate  (Use By - User Days) = DATE2                        days)
415bA*

500dAC                   call      'CLCDUR2'
500dAC                   parm      '*ADD'        $cdcmd
500dAC                   parm      today         $cddatein
500dAC                   parm      0             $cdtimein
500dAC                   parm      0             $cdyears
500dAC                   parm      0             $cdmonths
500dAC                   parm      imdday        $cddays
500dAC                   parm      0             $cdhours
500dAC                   parm      0             $cdminutes
500dAC                   parm      0             $cdseconds
500dAC     date1         parm      0             $cddateout
500dAC                   parm      0             $cdtimeout

500dAC                   call      'CLCDUR2'
500dAC                   parm      '*SUB'        $cdcmd
500dAC                   parm      expd          $cddatein
500dAC                   parm      0             $cdtimein
500dAC                   parm      0             $cdyears
500dAC                   parm      0             $cdmonths
500dAC                   parm      imuday        $cddays
500dAC                   parm      0             $cdhours
500dAC                   parm      0             $cdminutes
500dAC                   parm      0             $cdseconds
500dAC     date2         parm      0             $cddateout
500dAC                   parm      0             $cdtimeout

500dDC**                 move      today         g$date
500dDC**                 eval      dtfrmt = 1
500dDC**                 exsr      gtoj$
500dDC**                 eval      todyj = g$jd
415bA*
500dDC**   todyj         add       imdday        j$jd
500dDC**                 exsr      jtog$
500dDC**                 eval      date16 = j$date
415bA*
500dDC**                 move      date16        $cvd6i
500dDC**                 eval      $cvcmd = '*YMDCMD '
500dDC**                 call      @cvtdt
500dDC**                 parm                    $cvtdt
500dDC**                 move      $cvd8o        date1
415bA*
500dDC**                 move      expd          g$date
500dDC**                 eval      dtfrmt = 1
500dDC**                 exsr      gtoj$
500dDC**                 eval      expdj = g$jd
415bA*
500dDC**                 eval      j$jd = expdj - imuday
500dDC**                 exsr      jtog$
500dDC**                 eval      date26 = j$date
415bA*
500dDC**                 move      date26        $cvd6i
500dDC**                 eval      $cvcmd = '*YMDCMD '
500dDC**                 call      @cvtdt
500dDC**                 parm                    $cvtdt
500dDC**                 move      $cvd8o        date2
415bA*
500dDC**                 move      date26        $cvd6i
500dDC**                 eval      $cvcmd = '*YMDMDY '
500dMC                   move      date2         $cvd8i
500dMC                   eval      $cvcmd = '*CMDMDY '
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
510aDC*                  eval      dtchk = *off
417eMC                   eval      expd = date2
417eAC                   endif
415bA*
415bA*  Verify Use by date.                                            days)
415bAC                   if        expd <> 0
415bAC                   if        svexdt <> w1exdt
500fMC                   eval      dtchk3 = *off
500fDC*                  eval      dtchk = *off
415bAC                   endif
415b *
 00fDC*                  if        dtchk = '2'  and
415bAC                   if        dtchk3 = '2'  and
415bAC                             ovrrid = *on
510aAC                   eval      odovr = *on
510aAC                   eval      dtchk3 = *on
510aDC*                  eval      dtchk = *on
415bAC                   endif
415b *
510aDC*                  if        dtchk <> '1'
510aDC*                  eval      dtchk = *on
510aMC                   if        dtchk3 <> '1'
510aMC                   eval      dtchk3 = *on
417bA*
510aA*   This code was duplicated and did not belong here.
417aA*   If EXPD > /CKEXDT - Reject.
417aA*
510aDC*                  if        expd > ckexdt
510aDC*                  eval      error = *on
510aDC*                  eval      dtchk = '2'
510aDC*                  eval      warn = *on
510aAC*                  eval      *in24 = *on
510aAC*                  eval      *in04 = *on
510aAC*                  eval      errmsg = *blanks
510aAC*                  eval      erused = w1exdt
510aAC*                  eval      erdisd = imoday
510aAC*                  exsr      zm3243
510aAC*                  endif
415bA*
415bA*   If DATE2 <= Date1 - Reject.
415bA*
415bAC                   if        date2 <= date1
415bAC                   eval      error = *on
510aDC*                  eval      dtchk = '2'
510aMC                   eval      dtchk3 = '2'
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
415bMC                   eval      expd = date2
415bAC                   endif
     *
413gA*R         DTCHK     IFEQ '1'
510aA*  Change to use DTCHK4 for override                                  )
413gAC                   if        svmfdt <> w1mfdt
500dMC                   eval      dtchk4 = *off
510aDC*                  eval      dtchk = *off
413gAC                   endif
413g *
510aDC*                  if        dtchk = '2'  and
510aMC                   if        dtchk4 = '2'  and
413gAC                             ovrrid = *on
510aDC*                  eval      dtchk = *on
510eAC                   if        mfgd > today
510aAC                   eval      obovr = *on
510eAC                   endif
510eAC                   if        today > ltstd8
510eAC                   eval      oeovr = *on
510eAC                   endif
510aAC                   eval      dtchk4 = *on
413gAC                   endif
413g *
413g *R         OVRRID    IFEQ *OFF
510aDC*                  if        dtchk <> '1'
510aDC*                  eval      dtchk = *on
510aMC                   if        dtchk4 <> '1'
510aMC                   eval      dtchk4 = *on
     *
409 A*
409 A*  Verify manufacturing date.
409 A*
409 AC                   select
409 D**         *IN98     WHEQ *OFF
409 AC                   when      immflg = 'Y'
409 AC                   if        w1mfdt = 0
409 AC                   eval      error = *on
510aDC*                  eval      dtchk = *off
510aMC                   eval      dtchk4 = *off
510aAC                   eval      obovr = *off
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
510aDC*                  eval      dtchk = *off
510aMC                   eval      dtchk4 = *off
510aAC                   eval      obovr = *off
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
510aDC*                  eval      dtchk = *off
510aMC                   eval      dtchk4 = *off
510aAC                   eval      obovr = *off
409 AC                   eval      *in27 = *on
409 AC                   eval      *in07 = *on
409 AC                   eval      errmsg = *blanks
409 AC                   exsr      zm1010
409 AC                   endif
409 AC                   endif
409 AC                   endif
409 AC                   endif
     *
415CAC     error         cabeq     *on           enderr
409 A*
409 A*  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
409 A*
500dAC                   eval      $cvcmd = '*MDYCMD '
500dAC                   move      w1mfdt        $cvd6i
500dAC                   call      @cvtdt
500dAC                   parm                    $cvtdt
500dAC                   move      $cvd8o        expd
500dA
500dAC                   call      'CLCDUR2'
500dAC                   parm      '*ADD'        $cdcmd
500dAC                   parm      expd          $cddatein
500dAC                   parm      0             $cdtimein
500dAC                   parm      0             $cdyears
500dAC                   parm      0             $cdmonths
500dAC                   parm      immday        $cddays
500dAC                   parm      0             $cdhours
500dAC                   parm      0             $cdminutes
500dAC                   parm      0             $cdseconds
500dAC                   parm      0             $cddateout
500dAC                   parm      0             $cdtimeout
500dA
500dAC                   call      'CLCDUR2'
500dAC                   parm      '*SUB'        $cdcmd
500dAC                   parm      $cddateout    $cddatein
500dAC                   parm      0             $cdtimein
500dAC                   parm      0             $cdyears
500dAC                   parm      0             $cdmonths
500dAC                   parm      imuday        $cddays
500dAC                   parm      0             $cdhours
500dAC                   parm      0             $cdminutes
500dAC                   parm      0             $cdseconds
500dAC     expd          parm      0             $cddateout
500dAC                   parm      0             $cdtimeout
500dA
500dAC                   eval      $cvcmd = '*CMDMDY '
500dAC                   move      expd          $cvd8i
500dAC                   call      @cvtdt
500dAC                   parm                    $cvtdt
500dAC                   move      $cvd6o        w1exdt

500dDC**                 move      w1mfdt        g$date
500dDC**                 eval      dtfrmt = 2
500dDC**                 exsr      gtoj$
500dDC**                 eval      mfdtj = g$jd
409 A*
500dDC**   mfdtj         add       immday        j$jd
500dDC**                 eval      j$jd = j$jd - imuday
500dDC**                 exsr      jtog$
500dDC**                 move      j$date        $cvd6o
500dDC**                 eval      w1exdt = $cvd6o
     *
500dDC**                 eval      $cvcmd = '*MDYCMD '
500dDC**                 move      w1exdt        $cvd6i
500dDC**                 call      @cvtdt
500dDC**                 parm                    $cvtdt
500dDC**                 move      $cvd8o        expd
409 A*
409 A*  Find the latest acceptable date.: Exp date -Dist days
409 A*
500dAC                   eval      $cvcmd = '*MDYCMD '
500dAC                   move      w1exdt        $cvd6i
500dAC                   call      @cvtdt
500dAC                   parm                    $cvtdt
500dAC                   move      $cvd8o        ltstd8
500dA
500dAC                   call      'CLCDUR2'
500dAC                   parm      '*SUB'        $cdcmd
500dAC                   parm      ltstd8        $cddatein
500dAC                   parm      0             $cdtimein
500dAC                   parm      0             $cdyears
500dAC                   parm      0             $cdmonths
500dAC                   parm      imdday        $cddays
500dAC                   parm      0             $cdhours
500dAC                   parm      0             $cdminutes
500dAC                   parm      0             $cdseconds
500dAC     ltstd8        parm      0             $cddateout
500dAC                   parm      0             $cdtimeout
500dA
500dAC                   eval      $cvcmd = '*CMDMDY '
500dAC                   move      ltstd8        $cvd8i
500dAC                   call      @cvtdt
500dAC                   parm                    $cvtdt
500dAC                   move      $cvd6o        ltstd6

500dDC**                 move      w1exdt        g$date
500dDC**                 eval      dtfrmt = 2
500dDC**                 exsr      gtoj$
500dDC**                 eval      exdtj = g$jd
409 A*
500dDC**                 eval      j$jd = exdtj - imdday
500dDC**                 exsr      jtog$
500dDC**                 move      j$date        $cvd6o
500dDC**                 move      $cvd6o        ltstd6
409 A*
500dDC**                 move      ltstd6        $cvd6i
500dDC**                 eval      $cvcmd = '*MDYCMD '
500dDC**                 call      @cvtdt
500dDC**                 parm                    $cvtdt
500dDC**                 move      $cvd8o        ltstd8
409 A*
409 A*   If Today's date is > Latest acceptable date - Reject.
409 A*
409 AC                   if        today > ltstd8
409 AC                   eval      error = *on
510eAC                   eval      oeovr = *off
510aDC*                  eval      dtchk = '2'
510aMC                   eval      dtchk4 = '2'
413g C                   eval      warn = *on
417dD*R                   MOVE *ON       *IN28
417dMC                   eval      *in27 = *on
417dD*R                   MOVE *ON       *IN08
417dMC                   eval      *in07 = *on
409 AC                   eval      errmsg = *blanks
409 AC                   eval      ermday = immday
409 AC                   eval      ermfdt = w1mfdt
409 AC                   eval      erexdt = w1exdt
409 AC                   eval      erltst = ltstd6
409 AC                   eval      erdday = imdday
409 AC                   eval      eruday = imuday
409 AC                   exsr      zm3228
415 D**                   Z-ADD0         W1EXDT
417dAC                   eval      w1exdt = *zeros
417dAC                   eval      expd = *zeros
409 AC                   endif
409 AC                   endsl
     *
413bA*   Save screen fields.
413bA*R                   Z-ADDW1MFDT    SVMFDT  60
413bAC     error         cabeq     *on           enderr
412 AC                   endif
416aA*
416aA*   Check for ealier expiration dates (optional)                  days)
416aA*
416aA*     See if we can skip the check.                               days)
416aA*
416aAC                   if        w1exdt = 0  or
416aAC                             svexck <> '2'  and
416aAC                             svexck <> '3'
416aAC                   goto      skpxck
416aAC                   endif
416aA*
416aA*     Set warning check flag.                                     days)
416aA*
416aAC                   if        svexdt <> w1exdt
416aAC                   eval      dtchk2 = *off
510aMC                   eval      oaovr = *off
510eAC                   eval      ofovr = *off
510aDC*                  eval      cwovr = *off
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
416aAC                   endif
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
416aA*         '2' = Error (Not Allowed)
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
510aDC*                  eval      cwovr = *on
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
416aA*
416aAC     skpxck        tag
650fA * pti check
650fA /free
650fA   // calculate the PTI.
650nD   //if $pbclot <> ' ' and $pgtin <> ' ';
650nM   if $pbclot <> ' ' and $pgtin <> ' ' and *in73 = *off;
650fA     pplot  = %subst($pbclot: 1 : 20);
650fA     calcpti ($pgtin: pplot: $pbcProdD: pppti);
650fA     if svpti <> w1pti;
650fA       ptichk = *off;
650fa     endif;
650fa     if ptichk = '2' and
650fa        ovrrid = *on;
650fa        ptiovr = *on;
650fa        ptichk = *on;
650fa     endif;
650fa     if ptichk <> '1';
650fa       ptichk = *on;
650fA       if w1pti <> pppti
650fA         and ptiovr <> '1';
650fA         // recalc pti without production date
650fA         calcpti ($pgtin: pplot: ptinodate: pppti);
650fA         if w1pti <> pppti;
650fA           error = *on;
650fA           *in37 = *on;
650fA           *in17 = *on;
650fa           ptichk = '2';
650fA           warn = *on;
650fA           exsr zm3203;
650fA         endif;
650fA       endif;
650fA     endif;
650fA   endif;
650fA /end-free
650fAc     error         cabeq     *on           enderr
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
640bA*
640bA*  Always error if catchweight is negative
640bA*
640bAC                   if        w1dwgt < 0
640bAC                   eval      error = *on
640bAC                   eval      *in25 = *on
640bAC                   eval      *in05 = *on
640bAC                   eval      errmsg = 'Negative catchweight entered. '
640bAC                             + 'Catchweight must be greater than zero.'
640bAC                   exsr      zm9999
640bAC                   goto      enderr
640bAC                   endif
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
416fA*
416fA*  Skip catch weight variance check when ...
416fA*    "First time only" entry
416fA*
416fAC                   if        svcwen = '2'
413cAC                   goto      skipcw
416fAC                   endif
     *
     *  Catch weight variance check.
413gA*R         WTCHK     IFEQ '1'
413gAC                   if        svdwgt <> w1dwgt
413gAC                   eval      wtchk = *off
413gAC                   endif
413g *
413gAC                   if        wtchk = '2'  and
413gAC                             ovrrid = *on
650dAc                   eval      cwovr = *on
413gAC                   eval      wtchk = *on
413gAC                   endif
413g *
413gMC                   if        wtchk <> '1'
413gAC                   eval      wtchk = *on
413f *
413fA*   If catch weight >0,
413fA*     Calculate total expected catch weight,
413fA*     Calculate low/high ranges.
413fAC                   if        w1dwgt <> 0
413fAC                   eval      lwvar = 0
413fAC                   eval      hivar = 0
413fAC                   eval      lwrng = 0
413fAC                   eval      hirng = 0
413fAC                   eval      exwgt = 0
413fAC                   eval      ilvar = 0
413fAC                   eval      ihvar = 0
413fAC                   eval      ilrng = 0
413fAC                   eval      ihrng = 0
413fd**         LBQPCK    MULT LBUWGT    EXWGT
413f *
413fAC                   if        w1avg = 'Y'
413fAC                   eval      exwgt = itswgt
700aDC*                  eval      wotcw = w1dwgt
700aMC                   eval      wotcw = cnvwgt
413fAC                   else
416dAC                   if        svcwen = '2'
416dAC     pdqor1        mult      itswgt        exwgt
416dAC                   else
413fAC     w1qrc1        mult      itswgt        exwgt
416dAC                   endif
700aDC*                  eval      wotcw = w1dwgt
700aMC                   eval      wotcw = cnvwgt
413fAC                   endif
413f *
413f **   Iniz. flag used to skip variance check if = *ON.
413f C                   eval      lvskp = *off
413f C                   eval      hvskp = *off
413f **   Use item variance % if it exists
413f C     imkey         chain     itemmsc                            79
413f C                   if        not *in79
413f *
413f C                   if        imrg1c <> 0
413f C     imrg1c        div       100           prg1c
413f C                   if        imrg1c = 99
413f C                   eval      lvskp = *on
413f C                   endif
413f C                   endif
413f *
413f C                   if        imrg2c <> 0
413f C     imrg2c        div       100           prg2c
413f C                   if        imrg2c = 99
413f C                   eval      hvskp = *on
413f C                   endif
413f C                   endif
413f *
413f C                   endif
     *
413f C                   if        prg1c = 0
413fAC     oprg1c        div       100           prg1c
413f C                   endif
413f C                   if        prg2c = 0
413fAC     oprg2c        div       100           prg2c
413f C                   endif
413fA*
413fMC                   if        prg1c > 0
413fAC     exwgt         mult      prg1c         lwvar
413fAC                   eval      ilvar = itswgt * prg1c
413fAC                   endif
413fAC                   eval      lwrng = exwgt - lwvar
413fAC                   eval      ilrng = itswgt - ilvar
413fMC                   if        prg2c > 0
413fAC     exwgt         mult      prg2c         hivar
413fAC                   eval      ihvar = itswgt * prg2c
413fAC                   endif
413fAC     exwgt         add       hivar         hirng
413fAC     itswgt        add       ihvar         ihrng
413fA*
413fAC                   endif
413f *
413fA*     Check CW variance if CW > 0
700aDC*                  if        w1dwgt <> 0
700aMC                   if        cnvwgt > 0
413fAC                   exsr      zzchkt
413fAC                   endif
     *
413gA*   Save screen fields.
413gA*R                   Z-ADDW1DWGT    SVDWGT  72
413gAC     error         cabeq     *on           enderr
413gAC                   endif
416dA*
416dAC     skipcw        tag
413f *
TMP A*
TMP A*    Make sure slot is valid.
TMP A*
TMP AC                   if        w1slot <> *blanks
TMP AC     slkey         chain     s2rec                              79
TMP A*
TMP A*      Slot doesn't exist.
TMP A*
TMP AC                   if        *in79
TMP AC                   eval      error = *on
TMP AC                   eval      *in33 = *on
TMP AC                   eval      *in13 = *on
TMP AC                   exsr      zm04
413GA*R                   GOTO ENDCK1
413GAC                   goto      enderr
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
413GA*R                   GOTO ENDCK1
413GAC                   goto      enderr
TMP AC                   endif
TMP A*
TMP A*      Slot is a zero slot.
TMP A*
TMP AC                   if        slstat = 'Z'
TMP AC                   eval      error = *on
TMP AC                   eval      *in33 = *on
TMP AC                   eval      *in13 = *on
TMP AC                   exsr      zm06
413GA*R                   GOTO ENDCK1
413GAC                   goto      enderr
TMP AC                   endif
TMP AC                   endif
     *
     *
     *  Warning: Quantity
     *
     C     w1qrc1        add       pdqrc1        svqrc1
     C     w1qrc2        add       pdqrc2        svqrc2
     C     w1qrc3        add       pdqrc3        svqrc3
417bA*
417bA*    Accumulate total exceptions to include in qty test.
417bAC                   exsr      zzttle
     *  Quantity.
413gA*R         QTCHK     IFEQ '1'
413gAC                   if        sdqrc1 <> w1qrc1  or
413gAC                             sdqrc2 <> w1qrc2  or
413gAC                             sdqrc3 <> w1qrc3
413gAC                   eval      qtchk = *off
413gAC                   endif
413gA*R                   ENDIF
413g *
413gAC                   if        qtchk = '2'  and
413gAC                             ovrrid = *on
413gAC                   eval      qtchk = *on
413gAC                   endif
413g *
413gMC                   if        qtchk <> '1'
413gAC                   eval      qtchk = *on
413f *
413g *R         OVRRID    IFEQ *OFF
221 D*R         SVQRC1    IFNE PDQRC1
221 D*R         SVQRC2    ORNE PDQRC2
221 D*R         SVQRC3    ORNE PDQRC3
221 MC                   if        svqrc1 <> pdqor1  or
221 MC                             svqrc2 <> pdqor2  or
221 MC                             svqrc3 <> pdqor3
     C                   eval      warn = *on
     C                   eval      error = *on
413g C                   eval      qtchk = '2'
     C                   eval      *in21 = *on
     C                   eval      *in22 = *on
     C                   eval      *in23 = *on
     C                   eval      *in01 = *on
     C                   exsr      zm7201
     C                   endif
     *
413gA*   Save screen fields.
413gA*R                   Z-ADDW1QRC1    SDQRC1  50
413gA*R                   Z-ADDW1QRC2    SDQRC2  50
413gA*R                   Z-ADDW1QRC3    SDQRC3  50
413gAC     error         cabeq     *on           enderr
413g *
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
413gA*   Save screen fields.
416hD**                   Z-ADDW1DWGT    SVDWGT  72
416hMC                   eval      svdwgt = w1dwgt
413gAC                   eval      sdqrc1 = w1qrc1
413gAC                   eval      sdqrc2 = w1qrc2
413gAC                   eval      sdqrc3 = w1qrc3
413bAC                   eval      svmfdt = w1mfdt
415bAC                   eval      svexdt = w1exdt
417cD*R                   MOVE W1UPC     SVUPC  20
417cMC                   eval      svupc = w1upcd
650fAC                   eval      svpti  = w1pti
     C     endck1        endsr
700bA*----------------------------------------------------------------
700bA*
700bA*  ZZCHK1b  Screen 1 error checking.
700bA*
700bAC     zzchk1b       begsr
700bAC                   eval      error = *off
700bA*  at least one UPC must be entered or f9 to skip.
700bAc                   select
700bAc                   when      w1buom1 <> ' ' and
700bAC                             w1bupc1 = ' '  and
700bAc                             w1buom2 <> ' ' and
700bAC                             w1bupc2 = ' '
700bAC                   eval      error = *on
700bAC                   eval      *in15 = *on
700bAc                   eval      errmsg =  'Invalid ' + desc(6)
700bAc                   exsr      zm0105
700bAc                   leavesr
700bAc                   when      w1buom1 <> ' ' and
700bAC                             w1bupc1 = ' '  and
700bAc                             w1buom2 =  ' '
700bAC                   eval      error = *on
700bAC                   eval      *in15 = *on
700bAc                   eval      errmsg =  'Invalid ' + desc(6)
700bAc                   exsr      zm0105
700bAc                   leavesr
700bAc                   when      w1buom2 <> ' ' and
700bAC                             w1bupc2 = ' '  and
700bAc                             w1buom1 =  ' '
700bAC                   eval      error = *on
700bAC                   eval      *in16 = *on
700bAc                   eval      errmsg =  'Invalid ' + desc(6)
700bAc                   exsr      zm0105
700bAc                   leavesr
700bAc                   endsl
700bA*
700bA*  Extract UPC code from entered string.
700bA*
700bA * edit breakdown 1 upc
700bAc                   if        w1buom1 <> ' ' and
700bAC                             w1bupc1 <> *blanks
700bAC                   eval      $cbcmd = '*UPC    '
700bAC                   eval      $cbbar = w1bupc1
700bA*
700bAC                   call      'CVTBAR'
700bAC                   parm                    $cbcmd            8
700bAC                   parm                    $cbbar          100
700bAC                   parm                    $cbcod            3 0
700bAC                   parm                    $cbdec            1 0
700bAC                   parm                    $cbdsc           30
700bAC                   parm                    $cbpos            3 0
700bAC                   parm                    $cbtyp            1 0
700bAC                   parm                    $cbv1            11 3
700bAC                   parm                    $cbv2            50
700bAC                   parm                    $cbrtn            8
700bAC                   parm                    $cberm           60
740cAC                   parm      $itven#       $cbven           10 0
740cAC                   parm                    $cvtdata
740cAC                   parm                    $cvtdata2
700bA*
700bAC                   movel     $cbv2         $cstr
700bAC                   call      'ADJUST'
700bAC                   parm      '*RIGHT  '    $ccmd             8
700bAC                   parm                    $cstr            30
700bAC                   move      $cstr         b1upc
700bAC                   endif
700bA*   Do UPC Check
700bAC                   if        w1bupc1 <> ' '
700bA*
700bA*  MOVED CODE TO EXTRACT UPC CODE FROM ENTERED STRING
700bAC                   select
700bA*
700bAC                   when      $cbrtn = '*OK'
700bAc                   eval      writeb1 = *on
700bAc                   eval      b1type = %trimr($cbdsc)
700bA*
700bAC                   other
700bAC                   eval      error = *on
700bAC                   eval      *in26 = *on
700bAC                   eval      *in06 = *on
700bAC                   movel     $cberm        errmsg
700bAC                   exsr      zm0105
700bAC                   endsl
700bA*
700bAC     error         cabeq     *on           endck1b
700bAC                   endif
700bA*
700bA * edit breakdown 2 upc
700bAc                   if        w1buom2 <> ' ' and
700bAC                             w1bupc2 <> *blanks
700bAC                   eval      $cbcmd = '*UPC    '
700bAC                   eval      $cbbar = w1bupc2
700bA*
700bAC                   call      'CVTBAR'
700bAC                   parm                    $cbcmd            8
700bAC                   parm                    $cbbar          100
700bAC                   parm                    $cbcod            3 0
700bAC                   parm                    $cbdec            1 0
700bAC                   parm                    $cbdsc           30
700bAC                   parm                    $cbpos            3 0
700bAC                   parm                    $cbtyp            1 0
700bAC                   parm                    $cbv1            11 3
700bAC                   parm                    $cbv2            50
700bAC                   parm                    $cbrtn            8
700bAC                   parm                    $cberm           60
740cAC                   parm      $itven#       $cbven           10 0
740cAC                   parm                    $cvtdata
740cAC                   parm                    $cvtdata2
700bA*
700bAC                   movel     $cbv2         $cstr
700bAC                   call      'ADJUST'
700bAC                   parm      '*RIGHT  '    $ccmd             8
700bAC                   parm                    $cstr            30
700bAC                   move      $cstr         b2upc
700bAC                   endif
700bA*   Do UPC Check
700bAC                   if        w1bupc2 <> ' '
700bA*
700bA*  MOVED CODE TO EXTRACT UPC CODE FROM ENTERED STRING
700bAC                   select
700bA*
700bAC                   when      $cbrtn = '*OK'
700bAc                   eval      writeb2 = *on
700bAc                   eval      b2type = %trimr($cbdsc)
700bA*
700bAC                   other
700bAC                   eval      error = *on
700bAC                   eval      *in16 = *on
700bAC                   movel     $cberm        errmsg
700bAC                   exsr      zm0105
700bAC                   endsl
700bA*
700bAC     error         cabeq     *on           endck1b
700bAC                   endif
700bA*
700bAC     endck1b       endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
650bAc                   exsr      zzrcvpocheck
     *
     C     endck2        endsr
     *----------------------------------------------------------------
413f *
413f *  ZZCHKT   Screen 3 error check totals
413f *
413f C     zzchkt        begsr
650lDC**                 eval      error = *off
413f *
413f *
413f *     Check # of entrys if individual catchweight entry = Y
413f *
     *
413 A*
413 A*     Compare total catchweight to expected catchweight
413 A*
     *
413fAC                   if        lvskp = *off  and
413fAC                             wotcw < lwrng
413f C                   eval      error = *on
413gAC                   eval      wtchk = '2'
413f C                   eval      warn = *on
413f C                   eval      *in25 = *on
413f C                   eval      *in05 = *on
413f C                   eval      errmsg = *blanks
413f C                   eval      ertcwt = wotcw
413f C                   eval      erlrng = lwrng
650hAC                   eval      CW_exrngl = erlrng
413fAC                   if        hvskp = *on
413fAC                   eval      erhrng = 0
650hAC                   eval      CW_exrngh = erhrng
413fAC                   else
413f C                   eval      erhrng = hirng
650hAC                   eval      CW_exrngh = erhrng
413fAC                   endif
413f C     prg1c         mult      100           errg1c
413f C     prg2c         mult      100           errg2c
416dAC                   eval      erexwt = exwgt
413f C                   exsr      zm19
413f C                   endif
     *
413fAC                   if        hvskp = *off  and
413fAC                             wotcw > hirng
413f C                   eval      error = *on
413gAC                   eval      wtchk = '2'
413f C                   eval      warn = *on
413f C                   eval      *in25 = *on
413f C                   eval      *in05 = *on
413f C                   eval      errmsg = *blanks
413f C                   eval      ertcwt = wotcw
413fAC                   if        lvskp = *on
413fAC                   eval      erlrng = 0
650hAC                   eval      CW_exrngl = erlrng
413fAC                   else
413f C                   eval      erlrng = lwrng
650hAC                   eval      CW_exrngl = erlrng
413fAC                   endif
413f C                   eval      erhrng = hirng
650hAC                   eval      CW_exrngh = erhrng
413f C     prg1c         mult      100           errg1c
413f C     prg2c         mult      100           errg2c
413fD*                    Z-ADDOPRG1C    ERRG1C
413fD*                    Z-ADDOPRG2C    ERRG2C
416dAC                   eval      erexwt = exwgt
413f C                   exsr      zm19
413f C                   endif
     *
413fA*R                   ENDIF
     *
413fAC                   endsr
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
700aA*
700aA*  Test for F7 - Kilograms/Pounds toggle
700aA*
700aAC                   if        *inkg
700aAC                   eval      cmdtkn = *on
700aAC                   if        KiloLbs = 'P'
700aAC                   eval      KiloLbs = 'K'
700aAC                   eval      W1KgLb  = 'Kgs'
700aAC                   else
700aAC                   eval      KiloLbs = 'P'
700aAC                   eval      W1KgLb  = 'Lbs'
700aAC                   endif
700aAC                   select

700aAC                   when      KiloLbs = 'K' and itflgd = 'Y'
700aAC                   eval      cmdln1 = cmdln(2)

700aAC                   when      KiloLbs = 'P' and itflgd = 'Y'
700aAC                   eval      cmdln1 = cmdln(1)

700aAC                   when      KiloLbs = 'K' and itflgd = 'N'
700aAC                   eval      cmdln1 = cmdln(4)

700aAC                   when      KiloLbs = 'P' and itflgd = 'N'
700aAC                   eval      cmdln1 = cmdln(3)

700aAC                   endsl
700aAC                   endif
413eA*
413eA*
413eA*      F8  - Item Tie/High Maintenance.
413eA*
413eAC                   if        *inkh
413eAC                   eval      cmdtkn = *on
413eAC                   eval      whse = $pwhse
413eAC                   call      'IT141'
413eAC                   parm                    whse
413eAC                   parm                    $pitem
413eAC                   endif
415dA*
415dA*
415dA*      F9  - Scan Item Catchweight labels.
415dA*
415dAC                   if        *inki  and
510iMC                             (itcwgt = 'Y'
510iAC                              or itcwgt = 'S')
415dAC                   eval      cmdtkn = *on
415dAC                   eval      $lcmd = '*CHANGE '
415dAC                   eval      $lwhs3 = $pwhse
415dAC                   eval      $lpo3 = $ppo
415dAC                   eval      $lseq = $pseq
415dAC                   eval      $litm3 = $pitem
415dAC                   eval      $lqyr1 = w1qrc1
415dAC                   eval      $lqyr2 = w1qrc2
415dAC                   eval      $lqyr3 = w1qrc3
415dAC                   eval      $lcwte = *zeros
415dAC                   eval      $lcwtt = *zeros
415dAC                   eval      $lcwta = *zeros
415dAC                   call      'CW122'
415dAC                   parm                    $lparm
415dA*
415dA*    Load weight from entry program / Change flag to show not avg.
415dAC                   eval      w1dwgt = $lcwtt
415dAC                   eval      w1avg = 'N'
415dAC                   endif
     *
510fA*
510fA*      F11 - Manufacturer code decipher
510fA*
510fAc                   if        *inkk
530 AC                   eval      $lexpdat = 0
530 AC                   eval      $lmfrdat = 0
530 AC                   eval      $lrtn = ' '
510kA * f11 is only valid on date sensitive items
510kAc                   If        itflgd = 'Y' or immflg = 'Y'
510fAc                   eval      $lmfr#    = phven
510fAc                   eval      $lmfritem = pdvitm
510fAc                   eval      $ldakitem = pditem
510gAc                   eval      $lupc     = w1upcd
510jAc                   eval      ddcode = *off
510hDc*                  call      'MF200'
510hMc                   call      'MF200'                              66
510fAC                   parm                    $lparm
510fAC                   parm      0             $lexpdat          6 0
510fAC                   parm      0             $lmfrdat          6 0
510gAC                   parm                    $lupc            20
640cAC                   parm      ' '           $ldecvalue       15
510kAc                   else
510kac                   exsr      zm13250
510kAc                   endif
510jA * Set ddcode if date returned is invalid
510jAc                   if        $lrtn <> *blanks and $lrtn <> 'OK'
510jAc                   select
510jAc                   when      $lexpdat = 0 and $lmfrdat = 0
510jAc                   eval      ddcode = *on
640fAc                   eval      w1exdt = 0
640fAc                   eval      w1mfdt = 0
510jA
510jAc                   when      $lexpdat <> 0
510jAc                   eval      $cvcmd = '*MDYEDT'
510jAc                   move      $lexpdat      $cvd6i
510jAc                   call      @cvtdt
510jAC                   parm                    $cvtdt
510jAC                   if        $cvrtn = '*PGMQ   '
510jAC                   eval      ddcode= *on
510jAc                   endif
510jA
510jAc                   when      $lmfrdat <> 0
510jAc                   eval      $cvcmd = '*MDYEDT'
510jAc                   move      $lmfrdat      $cvd6i
510jAc                   call      @cvtdt
510jAC                   parm                    $cvtdt
510jAC                   if        $cvrtn = '*PGMQ   '
510jAC                   eval      ddcode= *on
510jAc                   endif
510jAc                   other
510jAc
510jAc                   endsl
510jAc                   endif
640cAc                   exsr      zzmfrdates
510fAC                   eval      w1exdt = $lexpdat
640cAc                   if        immflg = 'Y'
510fAC                   eval      w1mfdt = $lmfrdat
640cAc                   endif
510fAc                   endif
413aA*
413aA*      F17 - Display receiving log.
413aA*
413aAC                   if        *inkr  and
413aAC                             rcverr = *on
413aAC                   call      'PO133'
413aAC                   parm      '*VIEW   '    $mcmd             8
413aAC                   parm      $pwhse        $mwhse            3 0
413aAC                   parm      $ppo          $mpo              9
413aAC                   parm      $pitem        $mitem           15
413aAC                   parm      *zeros        $mrcdt            8 0
413aAC                   parm      *zeros        $mrctm            6 0
413aAC                   parm      *blanks       $mdev            10
413aAC                   parm      *blanks       $muser           10
413aAC                   eval      cmdtkn = *on
413aAC                   endif
     *
     *      F20 - Accept Warning.
     *
     C                   if        *inku
     C                   eval      ovrrid = *on
413g C                   else
413g C                   eval      ovrrid = *off
     C                   endif
     *
     C     endcm1        endsr
700bA*----------------------------------------------------------------
700bA*
700bA*  ZZCMD1b  User defined command keys for screen 1b.
700bA*
700bAC     zzcmd1b       begsr
700bAC                   eval      cmdtkn = *off
700bA*
700bAC     endcm1b       endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     C     endcm2        endsr
     *----------------------------------------------------------------
700aA*
700aA*  ZZCNVWGT  Setup converted weight field.
700aA*
700aAC     zzcnvwgt      begsr
700aA*
     *
     * If item options is setup as kgs and user enters kgs no conversion
     * If item options is setup as kgs and user enters lbs need conversion
     * If item options is setup as lbs and user enters lbs no conversion
     * If item options is setup as lbs and user enters kgs need conversion
700aA /free
700aA   select;
700aA     when IMkilolbs = 'K';
700aA       if KiloLbs = 'K';
700aA         eval cnvwgt = w1dwgt;
700aa       else;
700aA         eval(h) cnvwgt = w1dwgt / kgs2lbs;
700aA       endif;
700aA     other;
700aM       if KiloLbs = 'K';
700aM         eval(h) cnvwgt = w1dwgt * kgs2lbs;
700aM       else;
700aM         eval cnvwgt = w1dwgt;
700aM       endif;
700aA   endsl;
700aA /end-free

     C                   endsr
610bA*----------------------------------------------------------------
610bA*     ZZCVQY - Convert receive qty's to string for msg display
610bA*
610bAC     zzcvqy        begsr
610bAC                   call      'CVTQTY'
610bAC                   parm                    $ccmd             8
610bAC                   parm                    $cprg            10
610bAC                   parm                    $cqty1            7 0
610bAC                   parm                    $cqty2            7 0
610bAC                   parm                    $cqty3            7 0
610bAC                   parm                    $cum1             2
610bAC                   parm                    $cum2             2
610bAC                   parm                    $cum3             2
610bAC                   parm                    $cqstr           10
610bAC                   parm                    $custr           17
610bAC                   parm                    $crtn             8
610bAC                   parm                    $cerm
610bAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   endsr
700bA*----------------------------------------------------------------
700bA*
700bA*  ZZDFT1b  Get default values for add.
700bA*
700bAC     zzdft1b       begsr
700bA /free
700bA   // setup which fields are displayed
700bA   if needb1 = *on;
700bA     w1bupc1 = ' ';
700bA     w1buom1 = $itum2;
700bA     *in38 = *off;
700bA   else;
700bA     *in38 = *on;
700bA   endif;
700bA   if needb2 = *on;
700bA     w1bupc2 = ' ';
700bA     w1buom2 = $itum3;
700bA     *in39 = *off;
700bA   else;
700bA     *in39 = *on;
700bA   endif;
700bA /end-free
700bAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     C                   endsr
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
417gA*    Protect,non-display lot code entry field.
417gAC                   eval      *in88 = *on
417fA*    Retrieve Item Lot/license plate tracking info.
417fAC                   eval      $lcmd = *blanks
417fAC                   eval      $lprg = #prog
417fAC                   eval      $lwhse = $pwhse
417fAC                   eval      $litem = pditem
417fAC                   call      'GETLLP'
417fAC                   parm                    $lparm
417fA*
417fAC                   select
417fA*    Lot/license plate tracking values found.
417fAC                   when      $lrtn = '*OK     '
417fAC                   if        $llot = 'Y'
640eAc                             or $plot <> ' '
417fAC                   eval      lottrk = '*YES'
417gA*    Display lot code entry field.
417gAC                   eval      *in88 = *off
417fAC                   else
417fAC                   eval      lottrk = '*NO '
417fAC                   endif
417fAC                   if        $lltrk = 'Y'
417fAC                   eval      lictrk = '*YES'
417fAC                   else
417fAC                   eval      lictrk = '*NO '
417fAC                   endif
417fAC                   other
417fAC                   eval      lottrk = '*NO '
417fAC                   eval      lictrk = '*NO '
417fAC                   endsl
417fA*
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
413bAC                   if        $pcmd = '*QUICK  '
413bAC                   eval      w1qrc1 = pdqor1
413bAC                   eval      w1qrc2 = pdqor2
413bAC                   eval      w1qrc3 = pdqor3
413bAC                   else
221 MC                   eval      w1qrc1 = 0
221 MC                   eval      w1qrc2 = 0
221 MC                   eval      w1qrc3 = 0
     C                   eval      w1exdt = 0
413bAC                   endif
219 AC                   eval      w1avg = 'N'
409 AC                   eval      iatest = *blanks
409 AC                   eval      iaflag = *off
409 AC                   eval      w1mfdt = 0
417gAC                   eval      w1lotc = *blanks
510dAC                   eval      woexdt = 0
510dAC                   eval      woindt = 0
650fAC                   eval      w1pti  = 0
214 A*
214 A*   Get Unit of measure fields
214 A*
214 AC                   eval      w1um1 = *blanks
214 AC                   eval      w1um2 = *blanks
214 AC                   eval      w1um3 = *blanks
214 AC                   exsr      zzuom
SVLaAC                   if        client = saval
SVLaAC                   eval      *in63 = *off
SVLa C*   Convert quantity to string.
SVLa C                   eval      $ccmd = '*QTY2STR'
SVLa C                   eval      $cprg = #prog
SVLa C                   eval      $cqty1 = pdqor1
SVLa C                   eval      $cqty2 = pdqor2
SVLa C                   eval      $cqty3 = pdqor3
SVLa C                   exsr      zzcvqy
SVLa C                   eval      woqor = $cqstr
SVLa C*
SVLaAC                   else
SVLaAC                   eval      *in63 = *on
SVLa C                   eval      woqor = *blanks
SVLaAC                   endif
     *
221 D*R                   Z-ADDPDDWGT    W1DWGT
221 MC                   eval      w1dwgt = 0
     *
416dA*
416dA*   Enable/Disable catch weight fields.
416dA*
416dAC                   eval      vrfycw = *off
416dAC                   eval      *in82 = *off
416dA*
416dA*     First, see if catch weight entry is allowed.
416dA*
510iDC*                  if        itcwgt <> 'Y'  or
510iMC                   if        (itcwgt <> 'Y'  and
510iAC                              itcwgt <> 'S') or
416dAC                             svcwen = '3'
214 AC                   eval      *in95 = *on
416dAC                   eval      vrfycw = *off
214 AC                   else
214 AC                   eval      *in95 = *off
416dAC                   eval      vrfycw = *on
214 AC                   endif
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
416jAC                   parm                    $saisl            3
416jAC                   parm                    $sloc             3 0
416jAC                   parm                    $srlvl            2 0
416jAC                   parm                    $shand            2
416bAC                   parm                    $srtn             8
     *
TMP AC                   eval      w1slot = *blanks
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
640eA * load up fields from gs1 incoming information
640eA * Expiration Date
640eAc                   If        not *in96
640eAc                   if        $pexpdt > 0
640eAC                   move      $pexpdt       $cvd6i
640eAC                   eval      $cvcmd = '*YMDMDY '
640eAC                   call      @cvtdt
640eAC                   parm                    $cvtdt
640eAC                   move      $cvd6o        w1exdt
640eac                   endif
640eac                   endif
640eA * Manufacturing Date
640eAc                   If        immflg = 'Y'
640eAc                   if        $pmfgdt > 0
640eAC                   move      $pmfgdt       $cvd6i
640eAC                   eval      $cvcmd = '*YMDMDY '
640eAC                   call      @cvtdt
640eAC                   parm                    $cvtdt
640eAC                   move      $cvd6o        w1mfdt
640eac                   endif
640eac                   endif
640eA * Lot
640eAc                   If        lottrk = '*YES'
640eAc                   if        $pLot <> ' '
640eAc                   eval      w1lotc = $plot
640eAc                   endif
640eac                   endif
640eA * Catch Weight
640eAc                   If        vrfycw = *on
640eAc                   if        $pwgt > 0
640eAc                   eval      w1dwgt = $pwgt
640eAc                   endif
640eac                   endif
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
     *
413eA*
413eA*  Define partial key for item tie/high definition file.
413eA*
413eAC     partk2        klist
413eAC                   kfld                    $pwhse
413eAC                   kfld                    $pitem
219 A*
219 A*     OPTIONS
219 A*
219 AC     opkey         klist
413FD*                    KFLD           $PWHSE
413FMC                   kfld                    wkwhse
219 AC                   kfld                    ocode
219 A*
219 A*     EXTENDED ITEM DESCRIPTION
219 A*
219 AC     idkey         klist
219 AC                   kfld                    $pwhse
219 AC                   kfld                    $pitem
SVLbA*
SVLbAC     povky1        klist
SVLbAC                   kfld                    $pwhse
SVLbAC                   kfld                    kyven#
SVLbAC                   kfld                    kywhdp
221 A*
221 A*     UPC
221 A*
221 AC     upcky         klist
221 AC                   kfld                    $pwhse
221 AC                   kfld                    w1upc
221 A*
417jAC     upcky1        klist
417jAC                   kfld                    $pwhse
417jAC                   kfld                    $pitem
417jAC                   kfld                    phven
     *
417bAC     upcky2        klist
417bAC                   kfld                    $pwhse
417bAC                   kfld                    $pitem
417bAC                   kfld                    w1upc
     *
417kAC     upcky3        klist
417kAC                   kfld                    $pwhse
417kAC                   kfld                    $pitem
417kAC                   kfld                    w1upc
417kAC                   kfld                    phven
700bAC     upcky3U       klist
700bAC                   kfld                    $pwhse
700bAC                   kfld                    $pitem
700bAC                   kfld                    w1upc
700bAC                   kfld                    phven
700bAc                   kfld                    uputyp
     *
401 A*  Define partial key for SLOT3 file.
401 A*
401 AC     keysl3        klist
401 AC                   kfld                    $pwhse
401 AC                   kfld                    $pitem
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
409 AC                   kfld                    $rord
409 AC                   kfld                    $pwhse
416fA*
416fA*  Define key for POCTYPE file.
416fA*
416fAC     keypoc        klist
416fAC                   kfld                    $pwhse
416fAC                   kfld                    $ppo
416fAC                   kfld                    $pseq
417bAC                   eval      forevr = *on
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
510hA * determine if mfr decipher is available to client
510hAc                   eval      $lcmd = '*OPEN'
510hAc                   call      'MF200'                              66
510hAC                   parm                    $lparm
510hAC                   parm      0             $lexpdat          6 0
510hAC                   parm      0             $lmfrdat          6 0
510hAC                   parm                    $lupc            20
640cAC                   parm      ' '           $ldecvalue       15
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
500eA
500eA* Get client id.
500eA
500eAC                   call      'GETCLIENT'
500eAC                   parm                    client           10
416 A*
416 A*   Initialize error subfile
416 A*
416 AC                   exsr      zmcpmq
     *
413cAC                   setoff                                       kckl
413gAC                   eval      dtchk = *off
416aAC                   eval      dtchk2 = *off
413gAC                   eval      qtchk = *off
413gAC                   eval      wtchk = *off
415cAC                   eval      upchk = *off
417jAC                   eval      upchk2 = *off
416kAC                   eval      expd = 0
700bAC                   eval      needb1 = *off
700bAC                   eval      needb2 = *off
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
413fAC                   eval      ocode = '*SYSTEM '
413fAC                   eval      wkwhse = 0
413fAC     opkey         chain     options                            79
413fAC                   if        *in79
413fAC                   eval      opcapc = 'Y'
413fAC                   eval      opwrnc = 'N'
413fAC                   eval      oprg1c = 0
413fAC                   eval      oprg2c = 0
413f C                   eval      opicw = 'N'
770aAC                   eval      opdckv = 'N'
413fAC                   endif
770aA
770aAc                   if        opdckv = 'Y'
770aAc                   eval      dockvue = *on
770aAc                   else
770aAc                   eval      dockvue = *off
770aAc                   endif
770aA
415 A*
415 A*    Get User's employee number to be written to PORCV file
415 A*    if any records are flagged as touched.
415 A*
415 AC                   call      'GETUSER'
415 AC                   parm      #user         $code            10
415 AC                   parm      0             $whse             3 0
415 AC                   parm      0             $emp#             5 0
415 AC                   parm      *blanks       $fnam            15
415 AC                   parm      *blanks       $init             1
415 AC                   parm      *blanks       $lnam            20
415 AC                   parm      *blanks       $whdp             5
415 AC                   parm      *blanks       $styp             1
415 AC                   parm      *blanks       $shft             6
415 AC                   parm      *blanks       $crew             6
415 AC                   parm      0             $nhrs             3 1
415 AC                   parm      *blanks       $rtn              8
     *
     *   Select first screen to display.
     *
417cAC                   eval      w1upcd = *blanks
221 AC                   if        $pupc <> *blanks
760aAc                             or svnupc = 'Y'
221 AC                   eval      *in92 = *on
417cA*
417cA*    Left adjust UPC for better and easier viewing.
417cAC                   move(p)   $pupc         $cstr
417cAC                   call      'ADJUST'
417cAC                   parm      '*LEFTNOZ'    $ccmd
417cAC                   parm                    $cstr
417cAC                   movel     $cstr         w1upcd
221 AC                   endif
     *
417KAC                   movel     w1upcd        w1upc
417cD*R                   MOVE $PUPC     W1UPC
413aA*
413aA*       Condition function key on display.
413aA*
414aAC                   if        $pcmd = '*CHANGE '
413aAC                   eval      *in55 = *on
413aAC                   else
413aAC                   eval      *in55 = *off
413aAC                   endif
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '  or
413bAC                             $pcmd = '*QUICK  '
     C                   exsr      scr01i
700bAC                   if        $ifrcvmth = '3' and $ittype = ' '
700bAc                   exsr      scr01bi
700bAc                   endif
SVLbA
SVLbA*    For Saval ...
SVLbAC                   if        client = saval
SVLbAC                   eval      kyven# = phven
SVLbAC                   eval      kywhdp = itwhdp
SVLbA
SVLbAC     povky1        chain(n)  povpck                             79
SVLbAC                   if        not *in79
SVLb2C****               if        phven = 3031
SVLbA*      This will try and create a virtual slot if necessary.
SVLbA
SVLbAC                   if        sprcv = '1'
SVLbAC                             and $srtn = '*NONE'
SVLbMC                   eval      wodisp = povdsp
SVLbDC****               eval      wodisp = 'DZ910'
SVLbAC                   exsr      zzvpck
SVLbA
SVLbAC                   eval      woslot = $sldisp
SVLbA
SVLbAC                   endif
SVLbA
SVLbAC                   endif
SVLbAC                   endif
JDO A
JDO A*    For Jordano's ...
JDO A
JDO AC                   if        client = jordanos
JDO A
JDO A*      See if the is a special Bread PO.
JDO A
JDO AC                   if        phven = 3194
JDO AC                   eval      jdobread = *on
JDO AC                   else
JDO AC                   eval      jdobread = *off
JDO AC                   endif
JDO A
JDO A*      For Bread PO, make sure slot exists for item.
JDO A*      This will try and create a virtual slot if necessary.
JDO A
JDO AC                   if        jdobread
JDO AC                             and sprcv = '1'
JDO AC                             and $srtn = '*NONE'
JDO A
JDO AC                   call      'CRTVPICK'
JDO AC                   parm      #prog         $vprg            10
JDO AC                   parm      $pwhse        $vwhse            3 0
JDOcDC*                  parm      'REF'         $vwhdp            5
JDOcMC                   parm      'DRY'         $vwhdp            5
JDO AC                   parm      '958A'        $vdisp           12
JDO AC                   parm      #sitem        $vitem           15
JDO AC                   parm      ' '           $vrtn            10
JDO AC                   parm      ' '           $verm            60
JDO AC                   if        $vrtn <> 'VRTPCKCRT'
JDO AC                             and $vrtn <> 'INSLOT'
JDO AC                   eval      error = *on
JDO AC                   eval      errmsg = 'Err: Cannot create pick slot '
JDO AC                                    + '(' + %trim($vrtn) + ')'
JDO AC                   exsr      zm0105s
JDO AC                   goto      endinz
JDO AC                   endif
JDO A
JDO AC                   eval      woslot = $vdisp
JDO A
JDO AC                   endif
JDO A
JDO AC                   endif
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
700aA*
700aA*   Get Item Maintenance options.
700aA*
700aA /free
700aA   whse = $pwhse;
700aA   getimuom(whse: IMkilolbs: IMUom);
700aA     select;
700aA       when IMkilolbs = 'K';
700aA         KiloLbs = 'K';
700aA         W1KgLb  = IMUom;
700aA         cmdln1 = cmdln(2);
700aA       other;
700aA         KiloLbs = 'P';
700aA         W1KgLb  = 'Lbs';
700aA         cmdln1 = cmdln(1);
700aA     endsl;
700aA /end-free
700aA*    Setup command display line 2.
700aAC                   eval      cmdln2 = cmdln(7)
700aA*
700aA*    Setup command display line 1.
700aA*
700aAC                   select
700aA*
700bAc                   When      Needb1 = *on or Needb2 = *on
700bAC                   eval      cmdln1 = cmdln(8)
700aAC                   when      itcwgt <> 'N' and itflgd = 'Y'
700aAc                             and KiloLbs = 'P'
700aAC                   eval      cmdln1 = cmdln(1)
700aA*
700aAc                   when      itcwgt <> 'N' and itflgd = 'Y'
700aAc                             and KiloLbs = 'K'
700aAC                   eval      cmdln1 = cmdln(2)
700aA*
700aAC                   when      itcwgt <> 'N' and itflgd = 'N'
700aAc                             and KiloLbs = 'P'
700aAC                   eval      cmdln1 = cmdln(3)
700aA*
700aAc                   when      itcwgt <> 'N' and itflgd = 'N'
700aAc                             and KiloLbs = 'K'
700aAC                   eval      cmdln1 = cmdln(4)
700aA*
700aAC                   when      itcwgt = 'N' and itflgd = 'Y'
700aAC                   eval      cmdln1 = cmdln(5)
700aA*
700aAC                   when      itcwgt = 'N' and itflgd = 'N'
700aAC                   eval      cmdln1 = cmdln(6)
700aA*
700aAC                   endsl
700aA*

     C     endinz        endsr
415dA*----------------------------------------------------------------
415dA*
415dA*  ZZDLCW   Delete catchweight entry records.
415dA*
415dAC     zzdlcw        begsr
415dA*
415dAC                   eval      $lwhs3 = $pwhse
415dAC                   eval      $lpo3 = $ppo
415dAC                   eval      $lseq = $pseq
415dAC                   call      'DELTMPCW'
415dAC                   parm                    $lparm
415dA*
415dAC                   endsr
     *----------------------------------------------------------------
     *
221 A*  ZZLCNS   Get use generic license option
     *
221 AC     zzlcns        begsr
     *
500bAC                   eval      sprcv = *off
221 A*   Get use generic license option.
221 AC                   eval      lflag = *off
416aAC                   eval      svexck = *on
416dAC                   eval      svcwen = *on
416dAC                   eval      svcwtp = *on
416dAC                   eval      svcwfr = 'N'
417 AC                   eval      svrupc = 'N'
221 AC                   eval      ocode = '*RCVLBL '
413FAC                   eval      wkwhse = $pwhse
     *
221 AC     opkey         chain     options                            79
221 AC                   if        not *in79
221 AC                   if        opplcn = 'Y'
221 AC                   eval      lflag = *on
221 AC                   endif
500bAC                   if        $pcmd = '*CHANGES'
500bAC                   eval      $pcmd = '*CHANGE '
610aDC**                 eval      lflag = *off
500bAC                   eval      sprcv = *on
500bAC                   endif
416aAC                   eval      svexck = opexck
416dAC                   eval      svcwen = opcwen
416dAC                   eval      svcwtp = opcwtp
416dAC                   eval      svcwfr = opcwfr
417 AC                   eval      svrupc = oprupc
760aAC                   eval      svnupc = opnupc
221 AC                   endif
     *
221 AC                   endsr
640cA*----------------------------------------------------------------
640cA*
640cA*  ZZmfrdates  Set manufactures dates
640cA*
640cAC     zzmfrdates    begsr
640cAc                   select
640cAc                   when      $lmfrdat > 0 and $ldecvalue > ' '
640cA*
640cA*  Calculate Mfg Exp    date.(Mfg date + Mfg Shelf life days)
640cA*

640cAC                   eval      $cvcmd = '*MDYCMD '
640cAC                   move      $lmfrdat      $cvd6i
640cAC                   call      @cvtdt
640cAC                   parm                    $cvtdt
640cAC                   move      $cvd8o        mfgdte

640cA*  Create mfg expiration date mfgdate + mfg shelf life days
640cA
640cAC                   call      'CLCDUR2'
640cAC                   parm      '*ADD'        $cdcmd
640cAC                   parm      mfgdte        $cddatein
640cAC                   parm      0             $cdtimein
640cAC                   parm      0             $cdyears
640cAC                   parm      0             $cdmonths
640cAC                   parm      immday        $cddays
640cAC                   parm      0             $cdhours
640cAC                   parm      0             $cdminutes
640cAC                   parm      0             $cdseconds
640cAC     mexpd         parm      0             $cddateout
640cAC                   parm      0             $cdtimeout

640cA*
640cA*  Calculate Mfg date if mfg exp date is entered
640cA*
640cAc                   when      $lexpdat > 0 and $ldecvalue > ' '

640cA*
640cA*  Calculate Mfg date.(Mfg exp date - Mfg Shelf life days)
640cA*

640cAC                   eval      $cvcmd = '*MDYCMD '
640cAC                   move      $lexpdat      $cvd6i
640cAC                   call      @cvtdt
640cAC                   parm                    $cvtdt
640cAC                   move      $cvd8o        mexpd
640dAC                   eval      wkmday = immday
YHAaA*  Use By date -1 to be used as mfg shelf life days
YHAaAC                   if        client = yhata
YHAaAC                   if        immday = 0
YHAaAC                             and imoday > 0
YHAaAC                   eval      wkmday = imoday - 1
YHAaAC                   endif
YHAaAC                   endif

640cA*  Create mfg date - date mfg exp date - mfg shelf life days
640cA
640cAC                   call      'CLCDUR2'
640cAC                   parm      '*SUB'        $cdcmd
640cAC                   parm      mexpd         $cddatein
640cAC                   parm      0             $cdtimein
640cAC                   parm      0             $cdyears
640cAC                   parm      0             $cdmonths
640dDC*                  parm      immday        $cddays
640dMC                   parm      wkmday        $cddays
640cAC                   parm      0             $cdhours
640cAC                   parm      0             $cdminutes
640cAC                   parm      0             $cdseconds
640cAC     mfgdte        parm      0             $cddateout
640cAC                   parm      0             $cdtimeout

640dDc*                  if        immday = 0
640dMc                   if        wkmday = 0
     c                   eval      mfgdte = 0
640cAc                   endif

640cAc                   when      w1mfdt > 0 and itflgd = 'Y'
640cA*
640cA*  Calculate Mfg Exp    date.(Mfg date + Mfg Shelf life days)
640cA*

640cAC                   eval      $cvcmd = '*MDYCMD '
640cAC                   move      w1mfdt        $cvd6i
640cAC                   call      @cvtdt
640cAC                   parm                    $cvtdt
640cAC                   move      $cvd8o        mfgdte

640cA*  Create mfg expiration date mfgdate + mfg shelf life days
640cA
640cAC                   call      'CLCDUR2'
640cAC                   parm      '*ADD'        $cdcmd
640cAC                   parm      mfgdte        $cddatein
640cAC                   parm      0             $cdtimein
640cAC                   parm      0             $cdyears
640cAC                   parm      0             $cdmonths
640cAC                   parm      immday        $cddays
640cAC                   parm      0             $cdhours
640cAC                   parm      0             $cdminutes
640cAC                   parm      0             $cdseconds
640cAC     mexpd         parm      0             $cddateout
640cAC                   parm      0             $cdtimeout

640cAc                   when      w1exdt > 0

640cA*
640cA*  Calculate Mfg date.(Mfg exp date - Mfg Shelf life days)
640cA*

640cAC                   eval      $cvcmd = '*MDYCMD '
640cAC                   move      w1exdt        $cvd6i
640cAC                   call      @cvtdt
640cAC                   parm                    $cvtdt
640cAC                   move      $cvd8o        mexpd
640dAC                   eval      wkmday = immday
YHAaA*  Use By date -1 to be used as mfg shelf life days
YHAaAC                   if        client = yhata
YHAaAC                   if        immday = 0
YHAaAC                             and imoday > 0
YHAaAC                   eval      wkmday = imoday - 1
YHAaAC                   endif
YHAaAC                   endif

640cA*  Create mfg date - date mfg exp date - mfg shelf life days
640cA
640cAC                   call      'CLCDUR2'
640cAC                   parm      '*SUB'        $cdcmd
640cAC                   parm      mexpd         $cddatein
640cAC                   parm      0             $cdtimein
640cAC                   parm      0             $cdyears
640cAC                   parm      0             $cdmonths
640dDC*                  parm      immday        $cddays
640dMC                   parm      wkmday        $cddays
640cAC                   parm      0             $cdhours
640cAC                   parm      0             $cdminutes
640cAC                   parm      0             $cdseconds
640cAC     mfgdte        parm      0             $cddateout
640cAC                   parm      0             $cdtimeout

640dDc*                  if        immday = 0
640dMc                   if        wkmday = 0
     c                   eval      mfgdte = 0
640cAc                   endif

640cAc                   endsl
640cAC                   endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZRCVPOCHECK check for started RCVPO Transaction
650bA*
650bAC     zzrcvpocheck  begsr
650bA*
650bA*  See if RCVPO transaction is status 2 - start new if needed
650bA*
650bAC                   call      @crtrcv
650bAC                   parm      '*PO'         $lcmdr           10
650bAC                   parm      '*CHECK '     $lsubcmd         10
650bAC                   parm      $pwhse        @lwhse            3 0
650bAC                   parm      0             $lpcs             5 0
650bAC                   parm      0             $lpallets         5 0
650bAC                   parm                    $lsavetrn         7 0
650bAC                   parm                    $ppo              9
650bAC                   parm      itstyp        $litstyp          1
650bAC                   parm      itwhdp        $litwhdp          5
650bAC                   parm                    $lrtnr           10
650bAC                   endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZRCVPOCLOSE  Close RCVPO transaction.
650bA*
650bAC     zzrcvpoclose  begsr
650bAc                   if        rcvpocomplete

650bAc                   select
650bAc                   when      $lrq1 > 0
650bAc                   eval      poppcs = $lrq1
650bAc                   when      $lrq2 > 0
650bAc                   eval      poppcs = $lrq2
650bAc                   when      $lrq3 > 0
650bAc                   eval      poppcs = $lrq3
650bAc                   endsl

650bAC                   call      @crtrcv
650bAC                   parm      '*PO'         $lcmdr           10
650bAC                   parm      '*COMPLETE'   $lsubcmd         10
650bAC                   parm      $pwhse        @lwhse            3 0
650bAC                   parm      poppcs        $lpcs             5 0
650bAC                   parm      $lrpal        $lpallets         5 0
650bAC                   parm                    $lsavetrn         7 0
650bAC                   parm                    $ppo              9
650bAC                   parm      $itstyp       $litstyp          1
650bAC                   parm      $itwhdp       $litwhdp          5
650bAC                   parm                    $lrtnr           10

650bAc                   else

650bAC                   call      @crtrcv
650bAC                   parm      '*PO'         $lcmdr           10
650bAC                   parm      '*CLOSE'      $lsubcmd         10
650bAC                   parm      $pwhse        @lwhse            3 0
650bAC                   parm      0             $lpcs             5 0
650bAC                   parm      0             $lpallets         5 0
650bAC                   parm                    $lsavetrn         7 0
650bAC                   parm                    $ppo              9
650bAC                   parm      $itstyp       $litstyp          1
650bAC                   parm      $itwhdp       $litwhdp          5
650bAC                   parm                    $lrtnr           10
650bAc                   endif
650bAC                   endsr
417 A*
417 A*----------------------------------------------------------------
417 A*
417 A*  ZZRUPC   Verify Retail UPC on file for item.
417 A*
417 AC     zzrupc        begsr
417 A*
417 AC                   eval      $lcmd = '*VERIFY '
417 AC                   eval      $lwhs3 = $pwhse
417 AC                   eval      $lpo3 = $ppo
417 AC                   eval      $lseq = $pseq
417 AC                   eval      $litm3 = $pitem
417 A*
417 AC                   call      'PO245'
417 AC                   parm                    $lparm
417 A*
417 AC                   select
417 AC                   when      $lrtn = '*EXIT   '  or
417 AC                             $lrtn = '*CANCEL '
417 AC                   eval      error = *on
417 A*
417 AC                   endsl
417 A*
417 AC                   endsr
     *
413e *----------------------------------------------------------------
413e *
413eA*  ZZTIHI   Get use Preferred or 1st tie hi record.
413e *
413eAC     zztihi        begsr
413e *
413eA*  GET TIE HI, PREFERRED OR 1ST RECORD.
413eAC                   eval      done = *off
413eAC                   eval      wotie = 0
413eAC                   eval      wohi = 0
650mAC                   eval      wosdef = ' '
413eAC                   eval      svtie = 0
413eAC                   eval      svhi = 0
650mAC                   eval      svsdef = ' '
413eAC     partk2        setll     itemdef
413eAC                   dou       done = *on
413eAC     partk2        reade     idrec                                  79
413eAC                   if        *in79
413eAC                   eval      done = *on
413eAC                   else
413eAC                   if        svtie = 0  and
413eAC                             svhi = 0
413eAC                   eval      svtie = idtie
413eAC                   eval      svhi = idhigh
650mAC                   eval      svsdef = idsdef
413eAC                   endif
413eAC                   if        idpref = 'Y'
413eAC                   eval      wotie = idtie
413eAC                   eval      wohi = idhigh
650mAC                   eval      wosdef = idsdef
413eAC                   eval      done = *on
413eAC                   endif
413eAC                   endif
413eAC                   enddo
413eAC                   if        wotie = 0  and
413eAC                             wohi = 0
413eAC                   eval      wotie = svtie
413eAC                   eval      wohi = svhi
650mAC                   eval      wosdef = svsdef
413eAC                   endif
413e *
413eAC                   endsr
417bA*
417bA*----------------------------------------------------------------
417bA*
417bA*  ZZTTLE   Accumlate total exception quantity.
417bA*
417bAC     zzttle        begsr
417bA*
417bAC     fileky        setll     poexcp
417bAC                   dow       forevr = forevr
417bAC     fileky        reade     poexcp                                 76
417bAC                   select
417bAC                   when      *in76
417bAC                   leave
417bA*
417bAC                   other
417bAC                   add       peqex1        svqrc1
417bAC                   add       peqex2        svqrc2
417bAC                   add       peqex3        svqrc3
417bAC                   endsl
417bAC                   enddo
417bA*
417bAC                   endsr
413e *
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
416 AC                   eval      wolbl = *blanks
219 AC                   eval      woitem = *blanks
219 AC                   eval      wodsc1 = *blanks
219 AC                   eval      wodsc2 = *blanks
     *
416 AC                   eval      ssbflg = *off
416 AC                   eval      wolbls = *blanks
416 AC                   eval      wositm = *blanks
416 AC                   eval      w1um1 = *blanks
416 AC                   eval      w1um2 = *blanks
416 AC                   eval      w1um3 = *blanks
     *
640eA * add dri to get data from itemfld
640eA /free
640eA       exsr clr$item;

640eA       $itWhse = $pwhse;
640eA       $ititem = $litem;

640eA       $dricommand = '*ITEM';
640eA       $drisubcmd  = '%GETALL';
640eA       $drisys2upd = 'D';
640eA       chk4err = *on;
640eA       zmflag  = *off;
640eA       exsr zzzdricop;
640eA       if error = *on;
640eA         $ifucicde = ' ';
640eA         $ifrcvmth = ' ';
640eA         $ifbrdflg = ' ';
640eA       endif;
640eA       if $ifbrdflg = 'Y';
640eA         *in74 = *off;
640eA       else;
640eA         *in74 = *on;
640eA       endif;
650fA       if $ifsltmth = '3' or
650fA          $ifucicde <> '1'and $ifrcvmth <> '2';
650fA         *in73 = *off;
650fA       else;
650fA         *in73 = *on;
650fA       endif;
640eA /end-free
214 AC     ittkey        chain     piritem                            75
214 AC                   if        *in75
214 AC                   eval      *in94 = *on
214 AC                   eval      *in93 = *on
     C                   eval      itdesc = *blanks
     C                   eval      itpdsc = *blanks
413eAC                   eval      wopdsc = *blanks
416 AC                   eval      wolbl = lbl(4)
416 AC                   movel     desc(7)       woitem
416 AC     '-'           cat       woitem:1      woitem
416 AC     $pitem        cat       woitem:1      woitem
214 AC                   goto      enduom
214 AC                   else
413eAC                   eval      wopdsc = itpdsc
413eAC                   exsr      zztihi
416 A*
416 A*  Save information about selected item (Item that was sent in)
416 A*
416 AC                   eval      #otype = ittype
416 AC                   eval      #oitem = ititem
416 AC                   eval      #odesc = itdesc
416 AC                   eval      #opdsc = itpdsc
416fAC                   eval      #oswgt = itswgt
416 AC                   eval      #oum1 = itum1
416 AC                   eval      #oum2 = itum2
416fAC                   eval      #oum2q = itumq2
416fAC                   eval      #oswt2 = 0
416fAC                   if        #oum2q <> 0
416fAC     itswgt        div(h)    #oum2q        #oswt2
416fAC                   endif
416 AC                   eval      #oum3 = itum3
416fAC                   eval      #oum3q = itumq3
416fAC                   eval      #oswt3 = 0
416fAC                   if        #oum3q <> 0
416fAC     itswgt        div(h)    #oum2q        #oswt3
416fAC     #oswt3        div(h)    #oum3q        #oswt3
416fAC                   endif
416 A*
416 A*   Get short UOM descriptions for selected item.
416 A*
416 AC                   eval      #osu1 = *blanks
416 AC                   eval      #osu2 = *blanks
416 AC                   eval      #osu3 = *blanks
416 A*
416 AC                   if        itum1 <> *blanks
416 AC     itum1         chain     unmesr                             77
416 AC                   if        not *in79
416 AC                   eval      #osu1 = umshrt
416 AC                   else
416 AC                   movel     itum1         #osu1
416 AC                   endif
416 AC                   endif
416 A*
416 AC                   if        itum2 <> *blanks
416 AC     itum2         chain     unmesr                             77
416 AC                   if        not *in79
416 AC                   eval      #osu2 = umshrt
416 AC                   else
416 AC                   movel     itum2         #osu2
416 AC                   endif
416 AC                   endif
416 A*
416 AC                   if        itum3 <> *blanks
416 AC     itum3         chain     unmesr                             77
416 AC                   if        not *in79
416 AC                   eval      #osu3 = umshrt
416 AC                   else
416 AC                   movel     itum3         #osu3
416 AC                   endif
416 AC                   endif
416 A*
416 A*   Initialize base information.
416 A*
416 AC                   eval      #bitem = ititem
417qAC                   eval      #sitem = ititem
416 AC                   eval      #bityp = ittype
416 AC                   eval      #bdesc = itdesc
416 AC                   eval      #bpdsc = itpdsc
416 AC                   eval      #bum1 = itum1
416 AC                   eval      #bum2 = itum2
416 AC                   eval      #bum3 = itum3
416 AC                   eval      #bsu1 = #osu1
416 AC                   eval      #bsu2 = #osu2
416 AC                   eval      #bsu3 = #osu3
416 A*
416 A*   Get SSB item, if one exists
416 A*
416 AC                   if        ittype = ' '
416 AC                   call      'GETSSB'
416 AC                   parm      itwhse        $gwhse            3 0
416 AC                   parm      ititem        $gitem           15
416 AC                   parm      ' '           #bitem           15
416 AC                   parm                    #bdesc           30
416 AC                   parm                    #bpdsc           15
416 AC                   parm                    #bwhdp            5
416 AC                   parm                    #bstyp            1
416 AC                   parm                    #bum              2
416 AC                   parm                    #bum2             2
416 AC                   parm                    #bumq2            3 0
416 AC                   parm                    #bum3             2
416 AC                   parm                    #bumq3            3 0
416 AC                   parm                    #brtn             8
416 A*
416 AC                   if        #brtn = '*FOUND  '
416 AC                   eval      ssbflg = *on
416 AC                   eval      #bityp = 'S'
416 AC                   endif
416 AC                   endif
416 A*
416 A*  If selected item is a Contract, Alias, SSB or Breakdown item . . .
416 A*    Then get corresponding Base item.
416 A*
416 AC                   if        ittype = 'C'  or
416 AC                             ittype = 'A'  or
416 AC                             ittype = 'S'  or
416 AC                             ittype = 'B'
416 AC                   call      'GETBASE'
416 AC                   parm      itwhse        $gwhse
416 AC                   parm      ititem        $gitem
416 AC                   parm      ' '           #bitem
416 AC                   parm                    #bityp            1
416 AC                   parm                    #bdesc
416 AC                   parm                    #bpdsc
416 AC                   parm                    #bwhdp
416 AC                   parm                    #bstyp
416 AC                   parm                    #bum1             2
416 AC                   parm                    #bum2
416 AC                   parm                    #bumq2
416 AC                   parm                    #bum3
416 AC                   parm                    #bumq3
416 AC                   parm      ' '           #bcitm           15
416 AC                   parm                    #bctyp            1
416 AC                   parm                    #bcdsc           30
416 AC                   parm                    #bcpds           15
416 AC                   parm                    #bcwdp            5
416 AC                   parm                    #bcstp            1
416 AC                   parm                    #bcum1            2
416 AC                   parm                    #bcum2            2
416 AC                   parm                    #bcuq2            3 0
416 AC                   parm                    #bcum3            2
416 AC                   parm                    #bcuq3            3 0
416 AC                   parm                    #brtn
416 AC                   endif
417qA*   Get slot item.
417qAC                   call      @getsi
417qAC                   parm      itwhse        $gwhse
417qAC                   parm      ititem        $gitem
417qAC                   parm      ' '           #sitem           15
417qAC                   parm                    #sityp            1
417qAC                   parm                    #sdesc           30
417qAC                   parm                    #spdsc           15
417qAC                   parm                    #srtn            10
417qAC                   parm                    #smsg            60
416 A*
416 A*   Get short UOM descriptions for base item.
416 A*
416 AC                   if        #bum1 <> #oum1
416 AC     #bum1         chain     unmesr                             77
416 AC                   if        not *in79
416 AC                   eval      #bsu1 = umshrt
416 AC                   else
416 AC                   movel     #bum1         #bsu1
416 AC                   endif
416 AC                   endif
416 A*
416 AC                   if        #bum2 <> #oum2
416 AC     #bum2         chain     unmesr                             77
416 AC                   if        not *in79
416 AC                   eval      #bsu2 = umshrt
416 AC                   else
416 AC                   movel     #bum2         #bsu2
416 AC                   endif
416 AC                   endif
416 A*
416 AC                   if        #bum3 <> #oum2
416 AC     #bum3         chain     unmesr                             77
416 AC                   if        not *in79
416 AC                   eval      #bsu3 = umshrt
416 AC                   else
416 AC                   movel     #bum3         #bsu3
416 AC                   endif
416 AC                   endif
416 A*
416 A*
416 A*   Set indicators to protect breakdown quantities.
416 A*
214 AC                   if        itflg1 = 'N'  and
416 AC                             ssbflg = *off
750aAc                             or $svmput = 'N'
214 AC                   eval      *in94 = *on
214 AC                   endif
214 AC                   if        itflg2 = 'N'  and
416 AC                             ssbflg = *off  or
416 AC                             itflg2 = 'N'  and
416 AC                             ssbflg = *on  and
416 AC                             itum3 = *blanks
750aAc                             or $svmput = 'N'
214 AC                   eval      *in93 = *on
214 AC                   endif
416 A*
416 A*   When dealing with an SSB item, the quantity is actually
416 A*   received into the "normal" screen quantity. If a third
416 A*   breakdown is allowed, then that will be received into the
416 A*   breakdown 1 quantity on the screen. The second breakdown
416 A*   screen quantity is always protected for an SSB item.
416 A*
416 AC                   if        ittype = 'S'  and
416 AC                             itflg2 = 'Y'
416 AC                   eval      *in94 = *off
416 AC                   endif
416 A*
416 AC                   if        ittype = 'S'
416 AC                   eval      *in93 = *on
416 AC                   endif
416 A*
416 A*   Create label for selected item
416 A*
416 A*     If selected item is a SSB item . . .
416 A*        Then display the breakdown 1 UOM.
416 A*        Otherwise use the normal UOM.
416 A*
416 A*     Note: Except for the description, the SSB fields
416 A*           should be identical to its Base item's fields.
416 A*
416 AC                   movea     lbl(1)        a13
416 AC                   if        #otype = 'S'
416 AC                   movea     #osu2         a13(7)
416 AC                   else
416 AC                   movea     #osu1         a13(7)
416 AC                   endif
416 AC                   movea     a13           wolbl
416 AC     wolbl         cat       ')':0         wolbl
416 AC                   move      ':'           wolbl
416 A*
416 A*   Create description for selected item
416 A*
416 AC                   movea     typ(1)        a10
416 AC                   movea     #otype        a10(8)
416 AC                   movea     a10           temp10
416 A*
416 AC     #oitem        cat       temp10:1      woitem
416 AC     woitem        cat       '-':1         woitem
416 AC     woitem        cat       #odesc:1      woitem
416 A*
416 A*   Create label and description for corresponding item.
416 A*
416 AC                   select
416 A*
416 A*     If selected item is a Base item . . .
416 A*        Then display its corresponding SSB item (if any)
416 A*        Otherwise display nothing.
416 A*
416 AC                   when      #otype = ' '
416 AC                   if        #bityp = 'S'
416 AC                   movea     lbl(3)        a13
416 AC                   movea     #bsu2         a13(6)
416 AC                   movea     a13           wolbls
416 AC     wolbls        cat       ')':0         wolbls
416 AC                   move      ':'           wolbls
416 A*
416 AC                   movea     typ(1)        a10
416 AC                   movea     #bityp        a10(8)
416 AC                   movea     a10           temp10
416 A*
417qD**         #BITEM    CAT  TEMP10:1  WOSITM
417qMC     #sitem        cat       temp10:1      wositm
416 AC     wositm        cat       '-':1         wositm
416 AC     wositm        cat       #bdesc:1      wositm
416 AC                   endif
416 A*
416 A*     If selected item is a Breakdown item . . .
416 A*        Then display its corresponding Base item.
416 A*             Note: UOM is not applicable in this situation.
416 A*
416 AC                   when      #otype = 'B'
416 AC                   movea     lbl(2)        a13
416 AC                   movea     'N/A'         a13(7)
416 AC                   movea     a13           wolbls
416 AC     wolbls        cat       ')':0         wolbls
416 AC                   move      ':'           wolbls
416 A*
416 AC                   movea     typ(1)        a10
416 AC                   movea     #bityp        a10(8)
416 AC                   movea     a10           temp10
416 A*
417qD**         #BITEM    CAT  TEMP10:1  WOSITM
417qMC     #sitem        cat       temp10:1      wositm
416 AC     wositm        cat       '-':1         wositm
416 AC     wositm        cat       #bdesc:1      wositm
416 A*
416 A*     Otherwise . . .
416 A*        Then display its corresponding Base item w/UOM.
416 A*             Note: UOM of Base should match UOM of selected item.
416 A*
416 AC                   other
416 AC                   movea     lbl(2)        a13
416 AC                   movea     #bsu1         a13(7)
416 AC                   movea     a13           wolbls
416 AC     wolbls        cat       ')':0         wolbls
416 AC                   move      ':'           wolbls
416 A*
416 AC                   movea     typ(1)        a10
416 AC                   movea     #bityp        a10(8)
416 AC                   movea     a10           temp10
416 A*
417qD**         #BITEM    CAT  TEMP10:1  WOSITM
417qMC     #sitem        cat       temp10:1      wositm
416 AC     wositm        cat       '-':1         wositm
416 AC     wositm        cat       #bdesc:1      wositm
416 A*
416 AC                   endsl
416bA*
416bA*   Determine item number going into slot.
416bA*
416bAC                   if        #otype = ' '  or
416bAC                             #otype = 'B'
416bAC                   eval      #sitem = #oitem
417qD**                   ELSE
417qD**                   MOVE #BITEM    #SITEM 15
416bAC                   endif
416 A*
416 A*   Get extend description headings if being used.
416 A*
219 AC                   if        uxflag = *off
416 D**                   MOVELW1ITEM    $IITEM
416 D**                   MOVELITDESC    $IDESC
416 D**                   MOVELITPDSC    $IPDSC
416 D**                   MOVE *BLANKS   $ISTR
416 D**                   CALL @FMTIT
416 D**                   PARM           $IITEM 15
416 D**                   PARM           $IDESC 30
416 D**                   PARM           $IPDSC 15
416 D**                   PARM           $ISTR  70
416 D**                   MOVEL$ISTR     WOITEM
219 AC                   else
416 D**                   MOVELW1ITEM    WOITEM
219 AC     idkey         chain     itemdsc                            79
219 AC                   if        not *in79
219 AC                   eval      wodsc1 = ixdsc1
219 AC                   eval      wodsc2 = ixdsc2
219 AC                   endif
219 AC                   endif
416 A*
416 A*   Initialize unit of measure names for quantity fields.
416 A*
416 AC                   if        #otype = 'S'
416 AC                   eval      w1um1 = #osu2
416 AC                   else
416 AC                   eval      w1um1 = #osu1
416 AC                   endif
416 A*
416 AC                   if        not *in94
416 AC                   if        #otype = 'S'
416 AC                   eval      w1um2 = #osu3
416 AC                   else
416 AC                   eval      w1um2 = #osu2
416 AC                   endif
416 AC                   endif
416 A*
416 AC                   if        not *in93
416 AC                   eval      w1um3 = #osu3
416 AC                   endif
416 A*
416 A*   Determine if this item should be put away into warehouse.
416 A*   An '*' in last position of designation says that the item
416 A*   will NOT be put away into the warehouse.
416 A*
409 AC                   move      itdesg        iatest
409 AC                   if        iatest = '*'
409 AC                   eval      iaflag = *on
409 AC                   eval      *in64 = *off
409 AC                   else
409 AC                   eval      iaflag = *off
409 AC                   eval      *in64 = *on
409 AC                   endif
500cA
500cA*  ... Or department isn't live (this overrides iaflag).
500cA
500cAC                   call      'CHKLIVE'
640aAC                   parm      $pwhse        $swhse
500cAC                   parm                    itwhdp
500cAC                   parm                    livestat          8
500cA
500cAC                   if        livestat = '*NOTLIVE'
500cAC                   eval      *in65 = *off
500cAC                   eval      iaflag = *off
500cAC                   eval      *in64 = *on
500cAC                   else
500cAC                   eval      *in65 = *on
500cAC                   endif
416 A*
416 A*    The following EndIf is for statment *IN75 IFEQ *ON, which
416 A*    comes after the chain to PIRITEM.
416 A*
214 AC                   endif
214 A*
416 D**         ITUM1     CHAINUNMESR               75
416 D**         *IN75     IFEQ *OFF
416 D**                   MOVE UMSHRT    W1UM1
416 D**                   ELSE
416 D**                   MOVE *BLANKS   W1UM1
416 D**                   ENDIF
416 D**
416 D**         *IN94     IFEQ *OFF
416 D**         ITUM2     CHAINUNMESR               75
416 D**         *IN75     IFEQ *OFF
416 D**                   MOVE UMSHRT    W1UM2
416 D**                   ELSE
416 D**                   MOVE *BLANKS   W1UM2
416 D**                   ENDIF
416 D**                   ENDIF
416 D**
416 D**         *IN93     IFEQ *OFF
416 D**         ITUM3     CHAINUNMESR               75
416 D**         *IN75     IFEQ *OFF
416 D**                   MOVE UMSHRT    W1UM3
416 D**                   ELSE
416 D**                   MOVE *BLANKS   W1UM3
416 D**                   ENDIF
416 D**                   ENDIF
214 AC     enduom        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
640cAc                   if        $ldecvalue = ' '
640cAc                   exsr      zzmfrdates
640cAc                   endif
     C     phkey         chain(n)  pohdr                              79
     C                   if        *in79
     C                   eval      phven = 0
     C                   eval      phvnam = *blanks
     C                   endif
     *
500dAC                   if        immflg = 'Y'
500dA*
500dA*  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
500dA*
500dA
500dAC                   eval      $cvcmd = '*MDYCMD '
500dAC                   move      w1mfdt        $cvd6i
500dAC                   call      @cvtdt
500dAC                   parm                    $cvtdt
500dAC                   move      $cvd8o        expd
500dAC                   move      $cvd8o        womfdt
500dA
500dAC                   call      'CLCDUR2'
500dAC                   parm      '*ADD'        $cdcmd
500dAC                   parm      expd          $cddatein
500dAC                   parm      0             $cdtimein
500dAC                   parm      0             $cdyears
500dAC                   parm      0             $cdmonths
500dAC                   parm      immday        $cddays
500dAC                   parm      0             $cdhours
500dAC                   parm      0             $cdminutes
500dAC                   parm      0             $cdseconds
500dAC                   parm      0             $cddateout
500dAC                   parm      0             $cdtimeout
500dA
500dAC                   call      'CLCDUR2'
500dAC                   parm      '*SUB'        $cdcmd
500dAC                   parm      $cddateout    $cddatein
500dAC                   parm      0             $cdtimein
500dAC                   parm      0             $cdyears
500dAC                   parm      0             $cdmonths
500dAC                   parm      imuday        $cddays
500dAC                   parm      0             $cdhours
500dAC                   parm      0             $cdminutes
500dAC                   parm      0             $cdseconds
500dAC     expd          parm      0             $cddateout
500dAC                   parm      0             $cdtimeout
500dA
500dAC                   eval      $cvcmd = '*CMDMDY '
500dAC                   move      expd          $cvd8i
500dAC                   call      @cvtdt
500dAC                   parm                    $cvtdt
500dAC                   move      $cvd6o        w1exdt
500dA
500dAC                   endif
     *
417eD**         W1UPC     IFNE *BLANKS
417eMC                   if        w1upcd <> *blanks and
500dAC                             w1upc <> *blanks
416 D**         UPCKY     CHAINUPC                  79
417aD*R         UPCKY     CHAINUPC                 N79
417kD*R         UPCKY2    CHAINUPC2                N79
700bA /free
700bA   select;
700bA     when      w1qrc1 > 0;
700bA       eval      uputyp = 'N';
700bA     when      w1qrc2 > 0;
700bA       eval      uputyp = '1';
700bA     when      w1qrc3 > 0;
700bA       eval      uputyp = '2';
700bA   endsl;
700bA /end-free
700bDC*    upcky3        chain(n)  upc3                               79
700bMC     upcky3U       chain(n)  upc3                               79
221 AC                   if        *in79
221 AC                   eval      upwhse = $pwhse
221 AC                   eval      upitem = $pitem
221 AC                   eval      upupc = w1upc
221 AC                   eval      upven = phven
221 AC                   eval      upvnam = phvnam
221 AC                   eval      upvitm = pdvitm
221 AC                   eval      upbran = *blanks
700bA * load new upc fields
700bA /free
700bA   select;
700bA     when      w1qrc1 > 0;
700bA       eval      upuom = $itum1;
700bA       eval      uputyp = 'N';
700bA     when      w1qrc2 > 0;
700bA       eval      upuom = $itum2;
700bA       eval      uputyp = '1';
700bA     when      w1qrc3 > 0;
700bA       eval      upuom = $itum3;
700bA       eval      uputyp = '2';
700bA   endsl;
700bA   Select;
700bA     when ntype = 'UPC-12';
700bA       upctyp = '1';
700bA     when ntype = 'EAN-13';
700bA       upctyp = '2';
700bA     when ntype = 'GTIN';
700bA       upctyp = '3';
700bA     when ntype = 'SCC-14';
700bA       upctyp = '4';
700bA     when ntype = 'SSCC-18';
700bA       upctyp = '5';
700bA   endsl;
700bA /end-free
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
     C                   eval      $cvcmd = '*MDYCMD '
415bD**                   MOVE W1EXDT    $CVD6I
415bD**                   CALL @CVTDT
415bD**                   PARM           $CVTDT
415bD**                   MOVE $CVD8O    $REXPD
415bAC                   eval      $rexpd = expd
     C                   endif
417pA*
500 A*    Validate FIFO date if a MoveIn P/O. Otherwise, set to zero.
500 A*
500 AC                   if        w1fifo <> 0  and
500 AC                             not *in89
500 A*
417pAC                   move      w1fifo        $cvd6i
417pAC                   eval      $cvcmd = '*MDYCMD '
417pAC                   call      @cvtdt
417pAC                   parm                    $cvtdt
417pAC                   move      $cvd8o        wofifo
500 AC                   else
500 AC                   eval      wofifo = *zeros
500 AC                   endif
219 A*
416fDC                   exsr      zzzcw
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
219 AC                   eval      $rseq = $pseq
TMP AC                   eval      $rslot = w1slot
409 A*
409 AC                   call      'RC161'
409 AC                   parm      '*RECEIVE'    $rcmd             8
409 AC                   parm                    $rprg            10
409 AC                   parm      '*INTER  '    $rtype            8
409 AC                   parm                    w1whse
409 AC                   parm                    w1item
409 AC                   parm                    w1qrc1
409 AC                   parm                    w1qrc2
409 AC                   parm                    w1qrc3
409 AC                   parm                    $rpo              9
409 AC                   parm                    $rven            11 0
409 AC                   parm                    $rvnam           40
221 D*R                   PARM *BLANKS   #RVITM 15
221 MC                   parm                    w2vitm           15
409 AC                   parm      0             $rord             7 0
409 AC                   parm      *blanks       $rrcod            2
409 AC                   parm      *blanks       $rrmem           30
409 AC                   parm                    $rexpd            8 0
409 AC                   parm                    $pdev            10
409 AC                   parm                    $pform           10
214 AC                   parm                    $rslot           12
218 D*R                   PARM 0         $RSEQ   50
219 MC                   parm                    $rseq             5 0
218 AC                   parm                    $rrpck            1
218 AC                   parm                    $rplbl            1
219 AC                   parm                    w1twgt            9 2
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
500cA*
500cA*   If not a FSWMS item, don't put away only update PODTL
500cA*
500cAC                   if        livestat = '*NOTLIVE'
JDO AC                             and not jdobread
500cAC                   eval      $lflag = lflag
500cAC                   eval      $lcmd = '*CHANGE '
500cAC                   eval      $lwhse = $pwhse
500cAC                   eval      $lpo = $ppo
500cAC                   eval      $litem = $pitem
500cAC                   eval      $lrq1 = w1qrc1
500cAC                   eval      $lrq2 = w1qrc2
500cAC                   eval      $lrq3 = w1qrc2
500cAC                   eval      $lrpal = 1
500cAC                   eval      $lum1 = w1um1
500cAC                   eval      $lum2 = w1um2
500cAC                   eval      $lum3 = w1um3
500cAC                   eval      $lord = $rord
500cAC                   eval      $lseq# = $pseq
700aDC*                  eval      $lcwgt = w1dwgt
700aMC                   eval      $lcwgt = cnvwgt
510cDC*                  eval      wofifo = 0
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
500cA*
500cAC                   call      'PO236'
500cAC                   parm                    $lparm
500cAC                   parm                    $lum1
500cAC                   parm                    $lum2
500cAC                   parm                    $lum3
500cAC                   parm                    $lord
500cAC                   parm                    $lflag            1
500cAC                   parm                    $lseq#            5 0
500cAC                   parm                    $lven
500cAC                   parm                    $lvnam
500cAC                   parm                    $lvitm
500cAC                   parm                    $rexpd
500cAC                   parm                    $pdev
500cAC                   parm                    $pform
500cAC                   parm                    $lcwgt            9 2
500cAC                   parm                    avgwt1
500cAC                   parm                    avgwt2
500cAC                   parm                    avgwt3
500cAC                   parm                    w1lotc
510cDC*                  parm                    womfdt
510cMC                   parm                    woindt
500cAC                   parm                    wofifo
500cAC                   parm                    w1upc
640cAc                   parm                    $ldecvalue
640cAC                   parm      mexpd         $lmfgex           8 0
640cAC                   parm      mfgdte        $lmfgdt           8 0
650aAC                   parm      $plpn         $llpn            50
650aAC                   parm      ' '           NOlcns           15
650aAC                   parm                    w1brand
650aAC                   parm                    $parms1
650bAC                   parm                    $lsavetrn
650cAC                   parm                    $pgtin           14
650cAc                   parm                    $pbcProdD
650cAc                   parm                    $pbclot
650fAc                   parm      w1pti         $pw1pti
650oAc                   parm      ' '           $losscode         1
500cAC                   eval      $prtn = $lrtn
500cAC                   eval      $pmsg = $lmsg
640cMC                   if        $lrtn = '*OK     '
640cAc                   eval      $ldecvalue  = ' '
640cAc                   eval      $lmfgex = 0
640cAc                   eval      $lmfgdt = 0
640cAc                   eval      mexpd     = 0
640cAc                   eval      mfgdte   = 0
650bAc                   eval      rcvpocomplete = *on
650fAc                   eval      w1pti = 0
650fAc                   eval      $pw1pti = 0
650fAc                   eval      w1brand  = ' '
640cAc                   endif
500cAC                   call      'MOVMSGP'
500cAC                   parm                    $pprg
500cAC                   goto      jmpup1
500cAC                   endif
     *
     *   Try to put-away the item received.
     *
     C                   eval      $rpo = $ppo
219 AC                   eval      $rseq = $pseq
TMP AC                   eval      $rslot = w1slot
413aAC                   eval      rcverr = *off
     *
417pA*   Set command to send.
417pAC                   select
417pAC                   when      phvnam = 'MOVEIN'
417pAC                   eval      $rcmd = '*RECEIVE'
417pAC                   eval      $rfifo = wofifo
417pAC                   when      phvnam = move1
417pAC                   eval      $rcmd = '*MOVEINP'
417pAC                   eval      $rfifo = wofifo
417pAC                   when      phvnam = move2
417pAC                   eval      $rcmd = '*MOVEINO'
417pAC                   eval      $rfifo = wofifo
500bAC                   when      sprcv = '1'
500bAC                   eval      $rcmd = '*SPRECV '
500bAC                   eval      $rfifo = 0
417pAC                   other
417pAC                   eval      $rcmd = '*RECEIVE'
417pAC                   eval      $rfifo = 0
417pAC                   endsl
     C                   call      'RC160'
417pD**                   PARM '*RECEIVE'$RCMD   8
417pMC                   parm                    $rcmd
     C                   parm                    $rprg
     C                   parm      '*INTER  '    $rtype
     C                   parm                    w1whse
     C                   parm                    w1item
     C                   parm                    w1qrc1
     C                   parm                    w1qrc2
     C                   parm                    w1qrc3
     C                   parm                    $rpo
     C                   parm                    $rven
     C                   parm                    $rvnam
221 D*R                   PARM *BLANKS   #RVITM 15
221 MC                   parm                    w2vitm
     C                   parm      0             $rord
     C                   parm      *blanks       $rrcod
     C                   parm      *blanks       $rrmem
     C                   parm                    $rexpd
417p C                   parm                    $rfifo            8 0
     C                   parm                    $pdev
     C                   parm                    $pform
214 AC                   parm                    $rslot
218 D*R                   PARM 0         $RSEQ   50
219 MC                   parm                    $rseq
218 AC                   parm                    $rrpck
218 AC                   parm                    $rplbl
219 AC                   parm                    w1twgt
     C                   parm                    $rrq1
     C                   parm                    $rrq2
     C                   parm                    $rrq3
     C                   parm                    $rrpal
     C                   parm                    $rrtn
     C                   parm                    $rmsg
     *  If error, then do not update transfer order file.
     C                   if        $rrtn = '*PGMQ   '
     C                   eval      error = *on
413aAC                   eval      rcverr = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   goto      endup1
     C                   else
222 AC                   add       $rrq1         $prsqt
222 AC                   add       $rrq2         $prsqt
222 AC                   add       $rrq3         $prsqt
     *
500cDC**                 if        lflag = *on
500cAC                   eval      $lflag = lflag
500cAC                   if        lflag = *off
500cAC                   eval      $lcmd = '*LICONLY'
500cAC                   else
221 AC                   eval      $lcmd = '*CHANGE '
500cAC                   endif
500fAC                   if        sprcv = *on
500fAC                   eval      $lcmd = '*STUFFIT'
500fAC                   endif
221 AC                   eval      $lwhse = $pwhse
221 AC                   eval      $lpo = $ppo
221 AC                   eval      $litem = $pitem
221 AC                   eval      $lrq1 = $rrq1
221 AC                   eval      $lrq2 = $rrq2
221 AC                   eval      $lrq3 = $rrq3
221 AC                   eval      $lrpal = $rrpal
221 AC                   eval      $lum1 = w1um1
221 AC                   eval      $lum2 = w1um2
221 AC                   eval      $lum3 = w1um3
221 AC                   eval      $lord = $rord
417fA*    Lot tracking item - Pass single char flag to license entry pgm
417fAC                   if        lottrk = '*YES'
417fAC                   eval      $llott = 'Y'
417fAC                   else
417fAC                   eval      $llott = 'N'
417fAC                   endif
417fA*    Lic.tracking item - Pass single char flag to license entry pgm
417fAC                   if        lictrk = '*YES'
417fAC                   eval      $llict = 'Y'
417fAC                   else
417fAC                   eval      $llict = 'N'
417fAC                   endif
417gAC                   eval      $lseq# = $pseq
700aDC*                  eval      $lcwgt = w1dwgt
700aMC                   eval      $lcwgt = cnvwgt
500cAC                   eval      wofifo = 0
417fA*
720aA* Move mfg or expire or fifo date to keyed in date field
720aA* to send to PO236
720aAC                   eval      woindt = 0
720aAC                   select
720aAC                   when      w1fifo <> 0
720aAC                   eval      woindt = wofifo
720aAC                   when      w1mfdt <> 0
720aAC                   eval      woindt = womfdt
720aAC                   other
720aAC                   eval      woindt = woexdt
720aAC                   endsl
720aA*
720bA ** do we need to print box labels
720bA ** 4 and 6 print normal uom labels
720bAc                   if        $ifrcvmth = '4' and $lrq1 > 0 or
720bAc                             $ifrcvmth = '6' and $lrq1 > 0
720bAc                   eval      $bpo = $lpo
720bAc                   eval      $brcvdt = today
720bAc                   eval      $bqty = $lrq1
720bAc                   eval      $bprint = '*JOB'
720bAc                   eval      $bitem = $litem
740aDc*                  eval      $buom =  $lum1
740aMc                   eval      $buom =  $itum1
720bAc                   call      'PO250'
720bAC                   parm                    $bparm
720bAc                   endif
720bA **
720bA ** 5 and 6 print breakdown1 uom labels
720bAc                   if        $ifrcvmth = '5' and $lum2 <> ' ' and
720bAc                             $itflg1 = 'Y' or
720bAc                             $ifrcvmth = '6' and $lum2 <> ' ' and
720bAc                             $itflg1 = 'Y'
720bAc                   eval      $bpo = $lpo
720bAc                   eval      $brcvdt = today
720bAc                   if        $lrq1 <> 0
720bAc                   eval      $bqty = ($lrq1 * $itumq2) + $lrq2
720bAc                   else
720bAc                   eval      $bqty = $lrq2
720bAc                   endif
720bAc                   eval      $bprint = '*JOB'
720bAc                   eval      $bitem = $litem
740aDc*                  eval      $buom =  $lum2
740aMc                   eval      $buom =  $itum2
720bAc                   call      'PO250'
720bAC                   parm                    $bparm
720bAc                   endif
720bA **
720bA ** 5 and 6 print breakdown2 uom labels
720bAc                   if        $ifrcvmth = '5' and $lum3 <> ' ' and
720bAc                             $itflg2 = 'Y' or
720bAc                             $ifrcvmth = '6' and $lum3 <> ' ' and
720bAc                             $itflg2 = 'Y'
720bAc                   eval      $bpo = $lpo
720bAc                   eval      $brcvdt = today
720bAc                   if        $lrq1 <> 0 or $lrq2 <> 0
720bAc                   eval      $bqty = ($lrq1 * $itumq2 * $itumq3)
720bAc                                   + ($lrq2 * $itumq3) + $lrq3
720bAc                   else
720bAc                   eval      $bqty = $lrq3
720bAc                   endif
720bAc                   eval      $bprint = '*JOB'
720bAc                   eval      $bitem = $litem
740aDc*                  eval      $buom =  $lum3
740aMc                   eval      $buom =  $itum3
720bAc                   call      'PO250'
720bAC                   parm                    $bparm
720bAc                   endif
720bA **
221 AC                   call      'PO136'
221 AC                   parm                    $lparm
221 AC                   parm                    $lum1
221 AC                   parm                    $lum2
221 AC                   parm                    $lum3
221 AC                   parm                    $lord
500cAC                   parm                    $lflag            1
417gAC                   parm                    $lseq#            5 0
500cAC                   parm                    $lven
500cAC                   parm                    $lvnam
500cAC                   parm                    $lvitm
500cAC                   parm                    $rexpd
500cAC                   parm                    $pdev
500cAC                   parm                    $pform
417gAC                   parm                    $lcwgt            9 2
500cAC                   parm                    avgwt1
500cAC                   parm                    avgwt2
500cAC                   parm                    avgwt3
417gAC                   parm                    w1lotc
720aDC*                  parm                    womfdt
720aMC                   parm                    woindt
500cAC                   parm                    wofifo
500cAC                   parm                    w1upc
640cAc                   parm                    $ldecvalue
640cAC                   parm      mexpd         $lmfgex           8 0
640cAC                   parm      mfgdte        $lmfgdt           8 0
640eAC                   parm      $plpn         $llpn            50
640eAC                   parm      ' '           NOlcns           15
640eAC                   parm                    w1brand
650aAC                   parm                    $parms1
650bAC                   parm                    $lsavetrn
650cAC                   parm                    $pgtin           14
650cAc                   parm                    $pbcProdD
650cAc                   parm                    $pbclot
650fAc                   parm      w1pti         $pw1pti
500cDC**                 endif
221 AC                   if        $rrtn = '*OK     '
221 AC                   eval      $prtn = $rrtn
221 AC                   eval      $pmsg = $rmsg
640cAc                   eval      $ldecvalue  = ' '
640cAc                   eval      $lmfgex = 0
640cAc                   eval      $lmfgdt = 0
640cAc                   eval      mexpd     = 0
640cAc                   eval      mfgdte   = 0
640eAc                   eval      w1brand  = ' '
650bAc                   eval      rcvpocomplete = *on
650fAc                   eval      w1pti = 0
650fAc                   eval      $pw1pti = 0
     *  If no error was found then send message to calling program.
     C                   call      'MOVMSGP'
221 D*R                   PARM           #PROG
221 MC                   parm                    $pprg
221 AC                   endif
     C                   endif
409 A*
409 A*    Write records to POMFR file.
409 A*    Note: RC160 returns batch number in $RORD field which is
409 A*          used as first part of the LBKEY.
409 A*
409 AC     lbkey         setll     label2
409 AC                   eval      stop = *off
409 AC                   dou       stop = *on
409 AC     lbkey         reade     label2                                 79
409 AC                   if        *in79
409 AC                   eval      stop = *on
409 AC                   else
416gD**         IMMFLG    IFEQ 'Y'
416gMC                   if        $rexpd > 0
409 AC                   eval      pmwhse = $pwhse
409 AC                   eval      pmpo = $ppo
409 AC                   eval      pmseq = $pseq
409 AC                   eval      pmitem = $pitem
409 AC                   eval      pmexpd = $rexpd
416gAC                   if        w1mfdt <> 0
409 AC                   move      w1mfdt        $cvd6i
409 AC                   eval      $cvcmd = '*MDYCMD '
409 AC                   call      @cvtdt
409 AC                   parm                    $cvtdt
409 AC                   eval      pmmfgd = $cvd8o
416gAC                   else
416gAC                   eval      pmmfgd = 0
416gAC                   endif
409 AC                   eval      pmtrn# = lbtrn#
409 AC                   eval      pmlbl# = lblbl#
409 AC                   write     pmrec
416eA*
416eA*      Write record to item exception file for date override.
416eA*
510jA * add additional exception if date decipher error
510jAc                   if        ddcode = *on
510jAC                   eval      exerid = 'DD-CODE'
510jAC                   eval      exwhse = lbwhse
510jAC                   eval      exwhdp = lbwhdp
510jAC                   eval      exstyp = lbstyp
510jAC                   eval      exitem = lbitem
510jAC                   eval      dspo = lbpo
510jAC                   eval      dslbl = lblbl#
510jAC                   eval      dsexpd = $dto
510jAC                   eval      exfdis = dsfdis
510jAC                   eval      extdis = dstdis
510jAC                   eval      exgdte = lbsdte
510jAC                   eval      exgtim = lbstim
650 A*
650 AC                   if        lbqpck > 999
650 AC                   eval      exqty = 999
650 AC                   else
650 A*
510jMC                   z-add     lbqpck        exqty
650 AC                   endif
650 A*
510jaC                   eval      extask = 'RCV'
510jAC                   eval      exgby = #user
510jAC                   eval      exesta = '1 '
510jAC                   write     exrec
510jAC                   eval      ddcode = *off
510jac                   endif
510aDC*                  if        cwovr = *on  or
510aMC                   if        oaovr = *on  or
510eAC                             obovr = *on  or
510eAC                             ocovr = *on  or
417eAC                             odovr = *on  or
510eAC                             oeovr = *on  or
510eAC                             ofovr = *on
510eDC*                            obovr = *on
416eAC                   eval      exwhse = lbwhse
416eAC                   eval      exwhdp = lbwhdp
416eAC                   eval      exstyp = lbstyp
416eAC                   eval      exitem = lbitem
416eAC                   eval      dspo = lbpo
416eAC                   eval      dslbl = lblbl#
650iAC                   select
650iAC                   when      ocovr = *on
650iAC                   eval      dsexpd = ckexdt
650iAC                   other
416eAC                   eval      dsexpd = $dto
650iAC                   endsl
416eAC                   eval      exfdis = dsfdis
416eAC                   eval      extdis = dstdis
416eAC                   eval      exgdte = lbsdte
416eAC                   eval      exgtim = lbstim
416gD**                   Z-ADD0         EXQTY
650 A*
650 AC                   if        lbqpck > 999
650 AC                   eval      exqty = 999
650 AC                   else
650 A*
416gMC                   z-add     lbqpck        exqty
650 AC                   endif
650 A*
416eaC                   eval      extask = 'RCV'
416eAC                   eval      exgby = #user
510aDC*                  if        odovr = *on
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
510eDC*                  if        odovr = *on  or
510eDC*                            oaovr = *on  or
510eDC*                            obovr = *on
416eAC*                  eval      exerid = 'EXPDOVR'
510aAC*                  else
510aAC*                  eval      exerid = 'EXPDOVR'
417eAC*                  endif
416eAC                   eval      exesta = '1 '
416eAC                   write     exrec
510eAC                   eval      oaovr = *off
510aAC                   eval      obovr = *off
510eAC                   eval      ocovr = *off
417mAC                   eval      odovr = *off
510eAC                   eval      oeovr = *off
510eAC                   eval      ofovr = *off
416eAC                   endif
416eA*
413dAC                   endif
415 AC                   if        lflag = *off
415 AC                   exsr      zzurcv
415 AC                   endif
409 AC                   endif
409 AC                   enddo
     *  Move screen fields to record fields
221 D*R                   ADD  W1QRC1    PDQRC1
221 D*R                   ADD  W1QRC2    PDQRC2
221 D*R                   ADD  W1QRC3    PDQRC3
221 D*R                   ADD  W1DWGT    PDDWGT
     *   - Update record (it was read and locked in ZZGET1)
219 D*R                   UPDATRECORD                 79
219 D*R         *IN79     IFEQ *ON
219 D*R                   MOVE *ON       ERROR
219 D*R                   EXSR ZM72
219 D*R                   GOTO ENDUP1
219 D*R                   ENDIF
417pA*
417pA*    Write records to POFIFO file.
417pA**         $LRTN     IFEQ '*OK     '
417pAC                   if        w1fifo <> 0
417pAC     lbkey         setll     label2
417pAC                   eval      stop = *off
417pAC                   dou       stop = *on
417pAC     lbkey         reade     label2                                 79
417pAC                   if        *in79
417pAC                   eval      stop = *on
417pAC                   else
417pAC                   eval      pffifo = wofifo
417pAC                   eval      pflbl# = lblbl#
417pAC                   write     pfrec
417pAC                   endif
417pAC                   enddo
417pAC                   endif
650dA* catch weight override exception
650dAC                   if        cwovr = *on
650dAC     lbkey         setll     label2
650dAC                   eval      stop = *off
650dAC                   dou       stop = *on
650dAC     lbkey         reade     label2                                 79
650dAC                   if        *in79
650dAC                   eval      stop = *on
650dAc                   leave
650dAC                   else
650dAC                   if        lbqpck > 999
650dAC                   eval      exqty = 999
650dAC                   else
650dA*
650dAC                   z-add     lbqpck        exqty
650dAC                   endif
650dAC                   endif
650dA*
650dAC                   eval      exwhse = lbwhse
650dAC                   eval      exwhdp = lbwhdp
650dAC                   eval      exstyp = lbstyp
650dAC                   eval      exitem = lbitem
650dAC                   eval      dspo = lbpo
650dAC                   eval      dslbl = lblbl#
650dAC                   eval      dsexpd = 0
650dAC                   eval      exfdis = dsfdis
650dAC                   eval      extdis = dstdis
650dAC                   eval      exgdte = lbsdte
650dAC                   eval      exgtim = lbstim
650dAC                   eval      extask = 'RCV'
650dAC                   eval      exgby = #user
650dAC                   select
650dAC                   when      cwovr = *on
650dAC                   eval      exerid = 'CW-OVR '
650dAC                   endsl
650dAC                   eval      exesta = '1 '
650dAC                   write     exrec
650dA * load new file pocwexcp
650dA /free
650gD   //chain ($pwhse: lblbl#) pocwexcp;
650gD   //cw_exwhse = $pwhse;
650gD   //cw_expo = $ppo;
650gD   //cw_exseq = $pseq;
650gD   //cw_exitem = $pitem;
650dA   cw_exwhse = lbwhse;
650dA   cw_expo = lbpo;
650dA   cw_exseq = lbseq;
650dA   cw_exitem = lbitem;
650dA   cw_extrn# = lbtrn#;
650dA   cw_exlbl# = lblbl#;
700aD   //cw_exwgt = W1DWGT;
700aM   cw_exwgt = cnvwgt;
650hD   //cw_exrngl = erlrng;
650hD   //cw_exrngh = erhrng;
650dA   cw_exgdte = lbsdte;
650dA   cw_exgtim = lbstim;
650dA   cw_exrg1c = prg1c * 100;
650dA   cw_exrg2c = prg2c * 100;
650dA   cw_exswgt = exwgt;
650dA   select;
650dA     when imrg1c > 0;
650dA       cw_exrg1w = 'I';
650dA     when oprg1c > 0;
650dA       cw_exrg1w = 'S';
650dA     other;
650dA       cw_exrg1w = 'P';
650dA   endsl;
650dA   select;
650dA     when imrg2c > 0;
650dA       cw_exrg2w = 'I';
650dA     when oprg2c > 0;
650dA       cw_exrg2w = 'S';
650dA     other;
650dA       cw_exrg2w = 'P';
650dA   endsl;
650gD   //if %found(pocwexcp);
650gD     //update cwexrec;
650gD   //else;
650dA     write cwexrec;
650gD   //endif;
650dA /end-free
650dAC                   enddo
650dAC                   eval      cwovr = *off
650dAC                   endif
     *
     *   Move key values to parameters
     *
409 AC     jmpup1        tag
     C                   eval      $pseq = pdseq
     C                   eval      $pitem = pditem
     C     endup1        endsr
700bA*----------------------------------------------------------------
700bA*
700bA*  ZZUPD1b  Write breakdown upc
700bA*
700bAC     zzupd1b       begsr

700bA /free
700bA   // breakdown1
700bA   if writeb1 = *on;
700bA     upwhse = $pwhse;
700bA     upitem = $pitem;
700bA     upupc = b1upc;
700bA     upven = phven;
700bA     upvnam = phvnam;
700bA     upvitm = $itvit#;
700bA     upbran = $imbrnd;
700bA     upuom = w1buom1;
700bA     uputyp = '1';
700bA     Select;
700bA       when b1type = 'UPC-12';
700bA         upctyp = '1';
700bA       when b1type = 'EAN-13';
700bA         upctyp = '2';
700bA       when b1type = 'GTIN';
700bA         upctyp = '3';
700bA       when b1type = 'SCC-14';
700bA         upctyp = '4';
700bA       when b1type = 'SSCC-18';
700bA         upctyp = '5';
700bA     endsl;
700bA     write uprec;
700bA   endif;
700bA   // breakdown2
700bA   if writeb2 = *on;
700bA     upwhse = $pwhse;
700bA     upitem = $pitem;
700bA     upupc = b2upc;
700bA     upven = phven;
700bA     upvnam = phvnam;
700bA     upvitm = $itvit#;
700bA     upbran = $imbrnd;
700bA     upuom = w1buom2;
700bA     uputyp = '2';
700bA     Select;
700bA       when b2type = 'UPC-12';
700bA         upctyp = '1';
700bA       when b2type = 'EAN-13';
700bA         upctyp = '2';
700bA       when b2type = 'GTIN';
700bA         upctyp = '3';
700bA       when b2type = 'SCC-14';
700bA         upctyp = '4';
700bA       when b2type = 'SSCC-18';
700bA         upctyp = '5';
700bA     endsl;
700bA     write uprec;
700bA   endif;
700bA /end-free
700bAC                   endsr
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
760aA*
760aA*   Update the POSTATUS file for a change to POHDR
760aA*   Check for DockVue system option
760aA*
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
510iAC                             or itcwgt = 'S'
415dAC                   exsr      zzdlcw
415dAC                   endif
     *
     C     endhdr        endsr
     *
KHLaA*----------------------------------------------------------------
KHLaA*
KHLaA*  ZZUPCEX  Add UPC to ITMEXCP
KHLaA*
KHLaAC     zzupcex       begsr
KHLaA*
KHLaAC                   eval      extask = 'UPCADD'
KHLaAC                   eval      exerid = 'UPCADD'
KHLaAC                   eval      exwhse = $pwhse
KHLaAC                   eval      exitem = $pitem
KHLaAC                   eval      exgdte = today
KHLaAC                   eval      exgtim = %dec(%char(%time():*iso0):6:0)
KHLaAC                   eval      exfdis = %subst(w1upc:1:12)
KHLaAC                   eval      extdis = %subst(w1upc:13:8)
KHLaAC                   eval      exgby = #user
KHLaAC                   eval      exesta = '1 '
KHLaAC                   write     exrec
KHLaA*
KHLaAC     endupcex      endsr
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
415 A*---------------------------------------------------------------
415 A*
415 A*  ZZURCV   Update PORCV file.
415 A*
415 AC     zzurcv        begsr
415 A*
415 A*   Add record to PORCV.
415 A*
415 AC                   eval      porwhs = $pwhse
415 AC                   eval      porpo = $ppo
415 AC                   eval      porseq = $pseq
415 AC                   eval      pordte = today
415 AC                   time                    portim
415 AC                   eval      porusr = #user
415 AC                   eval      pordev = #job
415 AC                   eval      poremp = $emp#
415 AC                   eval      portrn = lbtrn#
416kD**                   Z-ADD0         PORLIC
416kMC                   eval      porlic = *blanks
415 AC                   eval      porlbl = lblbl#
415 AC                   eval      poract = 'R'
416kAC                   eval      poredt = 0
416kAC                   eval      poreti = 0
415 AC                   write     porrec                               49
415 AC                   endsr
     *
     *----------------------------------------------------------------
     *
530cA*  ZZVPCK   Create virutial pick slot.
     *
530cAC     zzvpck        begsr
     *    code pulled from SL270 ****
530cA
530cA*  Use DRI interface to do everything, including creating VSlot.
530cA
530cAC                   exsr      clr$slot
530cAC                   eval      $slwhseu = *on
530cAC                   eval      $slwhse  = $pwhse
530cAC                   eval      $slwhdpu = *on
530cAC                   eval      $slwhdp  = itwhdp
530cAC                   eval      $sldispu = *on
530cAC                   eval      $sldisp  = wodisp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = ititem
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd = '%CRTVPICK'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   exsr      zzzdricop
     C                   if        error = *on
     C                   if        $slwhsee = '1'
     C                   eval      *in21 = *on
     C                   endif
     C                   if        $slwhdpe = '1'
     C                   eval      *in22 = *on
     C                   endif
     C                   if        $sldispe = '1'
     C                   eval      *in23 = *on
     C                   endif
     C                   if        $sliteme = '1'
     C                   eval      *in24 = *on
     C                   endif
     C                   endif
530cA

530cAC     endvpk        endsr
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
413FAC                   eval      wkwhse = $pwhse
     *
219 AC     opkey         chain     options                            79
219 AC                   if        not *in79
219 AC                   if        opxdsc = 'Y'
219 AC                   eval      uxflag = *on
219 AC                   endif
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
500cAC                   eval      avgwt1 = 0
500cAC                   eval      avgwt2 = 0
500cAC                   eval      avgwt3 = 0
     C                   eval      cwcalc = 0
     C                   eval      wrttyp = ' '
     *
     *   Get POCTYPE record.
     *
     C                   if        svcwen = '2'
650eMC     keypoc        chain(n)  poctype                            79
650eDC**   keypoc        chain     poctype                            79
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
700aDC*                  eval      w1twgt = w1dwgt
700aMC                   eval      w1twgt = cnvwgt
700aDC*    w1dwgt        div       w1qrc1        avgwt1
700aMC     cnvwgt        div       w1qrc1        avgwt1
     *
     *     Entered quantity * Entered weight.
     *
     C                   when      cwcalc = 2
700aDC*    w1dwgt        mult      w1qrc1        w1twgt
700aMC     cnvwgt        mult      w1qrc1        w1twgt
500cAC                   z-add     w1dwgt        avgwt1
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
500cAC                   eval      avgwt1 = #oswgt
     C                   endif
     *
     *       Normal qty for SSB items.
     *
     C                   if        w1qrc1 > 0  and
     C                             #otype = 'S'
     C     #oswt2        mult      w1qrc1        w1twgt
500cAC                   eval      avgwt1 = #oswt2
     C                   endif
     *
     *       Brk1 qty for non-SSB items.
     *
     C                   if        w1qrc2 > 0  and
     C                             #otype <> 'S'
     C     #oswt2        mult      w1qrc2        tmpwgt
     C                   add       tmpwgt        w1twgt
500cAC                   eval      avgwt2 = #oswt2
     C                   endif
     *
     *       Brk1 qty for SSB items.
     *
     C                   if        w1qrc2 > 0  and
     C                             #otype = 'S'
     C     #oswt3        mult      w1qrc2        tmpwgt
     C                   add       tmpwgt        w1twgt
500cAC                   eval      avgwt2 = #oswt3
     C                   endif
     *
     *       Brk2 qty for non-SSB items.
     *
     C                   if        w1qrc3 > 0  and
     C                             #otype <> 'S'
     C     #oswt3        mult      w1qrc3        tmpwgt
     C                   add       tmpwgt        w1twgt
500cAC                   eval      avgwt3 = #oswt3
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
     *
530cA*----------------------------------------------------------------
530cA*----------------------------------------------------------------
530cA*                     DRI SUBROUTINES
530cA*----------------------------------------------------------------
530cA*----------------------------------------------------------------

530cA*----------------------------------------------------------------
530cA*  clr$slot  Clear $slot data structure fields
530cA*----------------------------------------------------------------
530cA
530cAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
530cAC                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   endsr
530cA
640eA*----------------------------------------------------------------
640eA*  clr$item  Clear $item data structure fields
640eA*----------------------------------------------------------------

640eAC     clr$item      begsr
640eAC                   eval      savever# = $itver#
640eAC                   clear                   $item
640eAC                   clear                   $item2
640eAC                   eval      $itver# = savever#
640eAC                   endsr

530cA*----------------------------------------------------------------
530cA*  zzzdricop  Call DRICOP
530cA*----------------------------------------------------------------
530cA
530cAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
640eAC                   when      $dricommand = '*ITEM'
640eAC                   eval      $dridata = $item
640eAC                   eval      $dridata2 = $item2
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

     C                   when      chk4err and %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   exsr      zm0105
     C                   when      chk4err and $drireturn = 'VRTPCKCRT'

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C                   exsr      zm0001
     C***                exsr      zzerrind

     C                   endsl

640eAc                   select
640eAC                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
640eAC                   when      $dricommand = '*ITEM'
640eAC                   eval      $item = $dridata
640eAC                   eval      $item2 = $dridata2
640eAC                   endsl

     C                   eval      chk4err = *off
530cAC     enddricop     endsr
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
* * INVALID ITEM * *
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
F5=Refresh  F12=Cancel  F17=Rcv log  F20=Accept warning
F9=Skip
