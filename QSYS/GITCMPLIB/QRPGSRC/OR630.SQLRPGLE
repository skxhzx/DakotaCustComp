      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave #203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR630     Truck build - Pick items
     *  21 June 1997
     *  Dave Sommerville
     *
500e *  NOTE:
500e *      -  Need to compile with TYPECONV = *DATETIME for datestamp
750aA*      -  TYPECONV parm no longer applies, disregard compile
750aA*         instruction to compile with TYPECONV = *DATETIME.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    06/21/97  DAS  4.00
     *      -  Major revisions for truck build process.  This program
     *         based on OR530.  Old revisions were removed to clean
     *         up program.
     *      - Initial revisions have not be marked with the version.
     *      - A new route id field is used to uniquely identify routes.
     *      - Options are now tied to zones, not departments.
     *        Therefore, file OPTIONS has been replaced with OPTIONZ.
     *        There are no override options anymore.
     *
404 A*    08/05/97  HNK  4.04
     *      -  Fix PCKFIX subroutine. If stock qty is -ve pick zero
     *         qty from slot.
     *
404 A*    08/06/97  DAS  4.04
     *      -  Move LW2LB routine to put in alpha order.
     *      -  Added routine UPDDIF to update PLTSUM, PLTSTP and
     *         corresponding merge records with aloc vs. picked differences.
     *
404 A*    08/07/97  DAS  4.04
     *      -  Revised PICKB routine to clear the "Transfer To" slot
     *         information when a letdown is not going to be done.
     *
404 A*    08/08/97  HNK  4.04
     *      -  Revised UPDDIF subroutine to update child records
     *         correctly, if the pick qty is different from allocated
     *         quantity.
     *
404 A*    08/25/97  DAS/HNK  4.04
     *      -  Revised UPDDIF again to update child records.
404 A*    09/02/97  RH   4.04
     *      -  Revised for Cross dock, update cross dock file.
406 A*    10/09/97  RH   4.06
     *      -  Add UPDRPL to update worklbl replenishments with pallet # if
     *         the pallet # was 0.
408 A*    01/15/98  RH   4.08
     *      -  Change KEYIT to use LWITEM, LBITEM is blank at this point.
408 A*    01/22/98 RH   4.08
408 A*      - Revised to not call OR631 if item is date sensitive.
     *      - Added return parameters entered data and expiration date
     *        to OR632 call.  Updated pick slot with these dates.
410 A*    08/20/98 RH   4.10
     *      - If RF level for will call orders, write record for rf
     *        selection. Write 'last' record saved fields.
410aA*    11/20/98 DAS  4.10a
     *      - Added file OPTIONS along with data structure.
     *      - Added WRKLABEL file for output.
     *      - Made revisions to deal with exception labels.
     *      - Made revisions to create labels for exceptions (not
     *        enough stock) based on user option.
410BA*    12/22/98 RH   4.10b
     *      - Added Using RF Will Call option.
     *
411 A*    06/09/99  DAS  4.11
     *      - Revised to deal with new item types.
     *      - Revised AVAIL routine to set available qtys to zero
     *        if they are negative.
     *
411 A*    06/16/99  DAS/RH  4.11
     *      - Initialize DIFF1, DIFF2, DIFF3, had values left
     *
WS1 A*    09/03/99  DAS/RH  WS1
     *      - REMOVED CALL TO OR631
412 A*    09/15/99  DAS  4.12a
     *      - Set TRNQTY to 0 when task is *BULKP.
     *      - Using LWQALC instead of LWQPCK when creating tran.
     *
413 A*    11/05/99  DAS  4.13
     *      - Revised routine PICK to execute PCKFIX if section
     *        is blank. Without this change an 'OUT' label would be
     *        created but it would never get a transaction number
     *        written to it.
     *
413aA*    09/27/99  MLB  4.13a
     *      - Revised to add tracking modifications to program.
     *        Added file PIRTRCK2 to pgm.
413bA*    11/09/99  MLB  4.13b
     *      - Revised routine *INZSR to add batch number to
     *        report title.
413cA*    11/10/99  MLB  4.13c
     *      - Revised *INZSR to initialize field TIME for exception
     *        report.
414aA*    04/03/00  MLB  4.14a
     *      - Revised the following routines to add Host pick Will Call
     *        support to program: *INZSR, PCKFIX and PRTERR.
     *      - Added new fields to *GENPICK data structure.
414 A*    08/11/00  DAS  4.14
     *      - Revised PCKFIX to update transaction totals when OUT
     *        label is created.
414bA*    09/29/00  DAS  4.14b
     *      - Revised UPDDIF to skip OUT records.
414cA*    06/16/00  RH   4.14c
     *      - Add item description, can use extended description.
     *
415 A*    02/16/01  DAS  4.15
     *      - Added REPORTS override for OR630PR.
     *
415aA*    06/20/01  HNK  4.15a
     *      - Revised to skip PCKFIX routine and treat "***"(In LWASL2)
     *        like "OUT" labels.  This change affects only clients who
     *        uses Truck builder without picking on BFC side.
     *
415bA*    07/16/01  DAS  4.15b
     *      - Revised to pick everything for Host Picked WillCalls.
     *
416 A*    09/13/01  DAS  4.16
     *      - Replaced file LABEL with LABEL13. Changed from output
     *        only to update with add.
     *      - Revised routint UPDRPL to use file LABEL13 instead of
     *        LABEL. Reason: Letdowns are now written directly to the
     *        LABEL file.
416aA*    03/12/02  RH   4.16a
     *      - File ORDSLCT changed, Re-compile only.
     *
     *
416bA*    06/28/02  DAS  4.16b
     *      - Revised PICKB to update PLTSUM with tran#.
     *
416cA*    07/12/02  DAS  4.16c
     *      - Revised to skip normal pallets that only contain
     *        bulk picks. The result will be that these pallets
     *        will not print with a Truck Set of labels on a
     *        Zone Pickup *BULK* label.
     *
416dA*    07/11/02  DAS  4.16d
     *      - Removed 414b change so OUT's are not skipped in UPDDIF.
     *      - Zeroed LWQALC when creating OUT record. This will allow
     *        UPDDIF to properly calculate pallet quantities.
416eA*    07/19/02  DAS  4.16e
     *      - Revised bulk only check in CHK4OB.
416fA*    07/22/02  MLB  4.16f
     *      - Fix: Changed Z-ADD to ADD for accumulating PLTPCS.
     *
417AA*    07/08/03 RH
     *      - Add OTEMP#, OTLBL#, OTPCK1, OTPCK2, OTPCK3 to ORDT file.
     *        The transaction does not have emp # or qty at this time.
417bA*    08/06/03  DAS  4.17b
     *      - Fix: Revised to set LBVRFY to 0 if LWQPCK = 0. PT132
     *        will use this to determine if a label record should be
     *        displayed during closing.
417cA*    08/14/03  DAS  4.17c
     *      - Fix: Revised PCKFIX routine to set LWQALC to LWQPCK
     *        when 1) the entire LWQALC wasn't picked and 2) system
     *        creates OUT labels. Now PT132 will show the actual qty
     *        printed on the original label.
     *      - Fix: Revised PCKFIX routine to set LWQALC to LWQPCK
     *        for and OUT record. Now PT132 will show the actual qty
     *        printed on the OUT label and not zero.
417dA*    08/15/03  DAS  4.17d
     *      - Fix: Revised to set LBSTAT to 'C' when 417b fix changes
     *        LBVRFY to '0'. Without this the record would not get
     *        changed to a 'C' because it is never loaded into the
     *        PT132, screen 6 subfile.
417eA*    07/28/04  DAS  4.17e
     *      - Fix: Revised to call GETSLOTITM instead of GETBASE.
     *        Re: The item being retrieved from GETBASE was being
     *            used to get the slot for the original item. However,
     *            if the original item was an Alias item for an SSB
     *            item, GETBASE would return the SSB item, which is
     *            not a slot item. Therefore no slot would be found
     *            for the original item.
     *
500 A*    07/08/05  MLB  5.00
     *      - Enh: Added client custom code support.
500aA*    07/08/05  MLB  5.00a
     *      - Enh: Added JIT Letdown/Replen option to program. This
     *        mod will only allow Letdowns to be created when OPJITR=L.
     *        If OPJITR is R or N then no replenishments are created
     *        at this time.
500bA*    10/05/05  MLB  5.00b
     *      - Enh: Added new code for OPJITR, P=Regular letdowns created.
     *        This mod changes 500a above. Letdowns will only be created
     *        by this program when OPJITR=P.
500cA*    10/07/05  MLB  5.00c
     *      - Enh: Revised program to convert codes used for JIT
     *        Replenishments. Update *GENPICK options text. All
     *        previous 5.00 changes relating to OPJITR have been
     *        overwritten for clarity.
500dA*    11/11/05  MLB  5.00d
     *      - Enh: Revised program to allow cases to be broken down
     *        into eaches as needed, but only create Letdowns
     *        when OPJITR='1'.
500eA*    04/03/06  RH   5.00e
     *      - Enh: Revised program to write BULKDRP for bulk pick.
510aA*    11/02/06  RH   5.10a
     *      - Enh: Add USF code from PIRSTD stand alone library.
510bA*    10/16/06  RAH  5.10b
     *      - Enh: Added call to program RU385 to write records into
     *             the RUNNER file.
510cA*    06/26/07  MLB  5.10c
     *      - Fix: Revised program to pass label type to RU385.
510dA*    08/30/07  MLB  5.10d
     *      - Fix: Revised program to retrieve *RUNNER options
     *        to determine whether a OUT label should be flagged.
     *
520 A*    05/30/08  RBD  5.20  P#00060
     *      - Enh: Added Loader Module logic, to load Truck Builder
     *        and Breakers pallet info into header and detail loader
     *        system files.  (Taken from rev's marked CBI1 in Cheney's
     *        version of OR630.)
     *
520aA*    10/03/08  DAS  5.20a  P#00140
     *      - Revised to up qty before updating Whse/Slot qtys.
     *        Re: We were running into breakdown 1 ordered qtys
     *            that were greater than 999.
     *
520bA*    10/23/08  DAS  5.20b  P#00140
     *      - Missed a spot where I needed to set PCKALL=*ON
     *
520cA*    01/13/09  DAS  5.20c
     *      - Converted to ILE
     *      - Added Finke revisions FDIa.
     *
520dA*    06/17/09  JCJ  5.20d
     *      - Added new zone options for Loader merge processing
     *
600aA*    05/08/09  DAS  6.00a  P#00045
     *      - License tracking
     *      - Letdowns have been removed for license tracking.
     *        Revised to ensure OPJITR option is not set for Letdowns.
     *
530 A*    11/17/09  JCJ  5.30
     *      - Revised to use TRUCKH to lookup Template code for
     *        Zone references.
     *
530aA*    02/10/10  RBD  5.30a
     *      - Fix: Only write/update loader hdr and detail records
     *        for pallets whose pallet id ends in 0.
530bA*    02/10/10  MLB  5.30b
     *      - Fix: Revised program initialize BDDRPS using field
     *        tsinz instead of CLEAR cmd.
     *
530cA*    04/29/10  RBD  5.30c
     *      - Fix: Changed logic for writing Loader recs. Pallets with
     *        only bulk picks on them were not creating loader recs.
530dA*    07/14/10  RBD  5.30d
     *      - Fix: Do not overlay or update loader header and detail
     *        records, always write new records.  When there's a route
     *        being added to the loader mod which already exists, we
     *        want to ADD the hdr and dtl records, which of course will
     *        have a different route id than the same route/s already
     *        in the l/m.  One hook though in the loader module ...
     *        if the same route (diff route id) in the l/m needs to be
     *        assigned the same truck, as is the case with add-on
     *        routes, you can only assign the truck to one of the
     *        routes at a time.  Once it's closed to the l/m, the
     *        other route id for that same route can then be assigned
     *        that same truck.
610aA*    02/23/10  DAS  6.10a
     *      - Added custom Dierks mod DRKa
640aA*    06/28/11  JCJ  6.40a
     *      - Fix:  PLTSUM3 and PLTSUM3T are identical except PLTSUM3T
     *        has transaction number at the end of it. If
     *        PLTSUM3T was created before PLTSUM3 it will implicitly
     *        attach itself to use the key from PLTSUM3T. If this
     *        occurs, when you update the record with the transaction
     *        number the revised key comes after the one you just
     *        read, thus retrieving the record a second time.
     *        Code has been added to skip this second read if it
     *        occurs.
640bA*    10/12/11  MLB/JCJ  6.40b
     *      - Fix: Revised to only run routine CHK4OB when the program
     *        is processing a Gen 1 Pallet.  This was done to insure
     *        tote pallets get assigned a transaction number.
640cA*    10/19/11  JCJ  6.40c
     *      - Fix: Revised to not create a Loader merge transaction
     *        Pallet sum type ('L') if the 'O' type transaction has
     *        no labels associtated with it.  This will prevent a
     *        transaction being created for a pallet with no
     *        associated label records.  The 'O' type transaction
     *        will be used to post to the label records.
650a *    05/04/13  GJA  6.50a
     *      - Enh: Add option for Label printing method instead of
     *             custom client code  (WSTa)
650bA*    05/23/13  JCJ  6.50b
     *      - Fix: Added code to unsure Side X Side PLTSUM zones get
     *        transactions assigned.
650cA*    10/30/13  RBD  6.50c
     *      - Fix: Changed LDRDETL2 logic to use LDRDETL instead, and
     *        chain to LDRDETL before adding to make sure the record
     *        doesn't already exist ... that should be impossible since
     *        the key contains route id, but inexplicably we've gotten
     *        dup key errors so we want to make sure if it happens that
     *        the pgm doesn't blow up and we just move on.
     *      - Fix: Added option OPRLOA; will only process Loader Module
     *        records if client is using it.
650dA*    01/20/15  RBD  6.50d
     *      - Recompiled, LDRDETL file changed.
CWD A*    04/26/16  MLB  CWD  P#01349
     *      - Enh: Re-compiled pgm. WORKLBL5 had order id, descending
     *        added to key for tote processing.
700 A*    07/06/16  NLK  7.00
     *      - see GLPa for AMP short items to create Runner on DelvRt
     *        Future AMP clients may need the same change.
700aA*    07/06/16  RBD  7.00a
     *      - Enh: If option *LOADER/OPADDO = Y (auto define add-ons)
     *        and you find the same host route in LDRHDR then default
     *        this route's trailer and start date and time to the
     *        same as the one in loader header.
710 A*    02/20/17  RH/MLB  7.10
     *      - Fix: Revised pgm to run WRTTRN when PSSZON and LSTZON ch
     *        and new zone is using Side x Side. Was skipping writing
     *        out new PIRTRAN rcd.
710aA*    03/27/17  LMC     7.10a
     *      - Enh: Do not write items with NOALC designation to the
     *        loader files. All items on the pallet must have NOALC
     *        designation to exclude them from the loader files.
     *    ------------------------------------------
     *    --added from OR630P from USF mod marks  --
     *    --USF mods h,i,j,k,p converted to 710   --
     *    ------------------------------------------
710bA*    01/23/07  JCJ  USFh-710b
     *      - Changed mainline routine by moving the code under the
     *        text 'Work with bulk picks first' to subroutine PICK1.
     *        Moved code under the text 'Now work with normal picks'
     *        to subroutine PICK2.  Next put subroutine pick2 into a
     *        3 phase do loop. Phase 1 will assign transaction numbers
     *        to Gen 2+ pallets.  Phase 2 will assign tranaction
     *        numbers to Gen 1 pallets with unload sequence # < 71.
     *        Phase 3 will assign tranaction numbers to Gen 1 pallets
     *        with unload sequence # >= 71.
710cA*    01/27/07  DAS  USFi-710c
     *      - Revised mainline tocsee if a wrttrn should be done
     *        after phase 1 and phase 3. Re: transaction record
     *        was not being written after phase 1 and then the
     *        curtrn field was cleared at the beginning of phase 2.
710dA*    01/29/07  DAS  USFj-710d
     *      - Added file PLTSUM5
     *      - Rewrote PICK2 routine. Split into PICK3 and PICK99.
     *      - Revised how phase 3 works. Old method split a phase 2
     *        pallet from a phase 3 pallet. Now phase 2 calls new
     *        subroutine PICK3 to process the >= 71 pallets for
     *        phase 2.
     *      - For clarity, did not keep old code.
710eA*    02/06/07  DAS  USFk-710e
     *      - PICK2 was revised to handle a 71 pallet that belongs
     *        to a compartment that is not in the actual truck
     *        definition (i.e., I = Ice Cream)
710fA*    08/30/10  JCJ  USFp-710f = P#00153
     *      - Enh: Assign transaction by stop using logical PLTSUM14.
     *        Commented out references to Psys custom code.
     *    ------------------------------------------
     *
720aA*    03/29/18  DAS  7.20a
     *      - Revised *INZSR to get dataarea DragDrop2.
     *      - When using DD2, normal pallets are PLTSUM PSTYPE='P'.
     *        PSTYPE='O' are Location summaries.
     *      - Added file PLTSUM8.
     *      - Revised UPDDIF to update corresponding location records.
720bA*    07/20/18  NLK  720b
     *      - FIX when adding OR630P code into OR630, I mistakenly
     *        used OR630PPR and should have left it OR630PR
720cA*    09/11/18  DAS  7.20c
     *      - Revised to call GetTBType instead of reading
     *        data area dragdrop2 directly.
     *      - Replaced dd2 with tbEnhanced.
720dA*    11/14/18  DAS  7.20d
     *      - Revised Pick2 to use tbPalletType.
730aA*    04/23/19  DAS  7.30a
     *      - Changed to SQLRPGLE.
     *      - Created CHK4OB2
     *      - Revised CHK4OB to call CHK4OB2 for DD2
730bA*    07/09/19  NLK  7.30b   (In Progress)
     *      - Changed @addtr/addstdtrn calls to ADJTRAN2
     *      - few 'parm' need to be changed
730cA*    07/26/19  KDE     7.30c
     *      - Fix: Revised to clear curtrn after WRTTRN in 710 mod
730dA*    08/07/19  KDE     7.30d
     *      - Fix: Coatal reported after 7.30c mod that the Safeway
     *        product was getting outted.  After further investigation
     *        I found if flag sidebyside was on it called routine WSTTRN
     *        which zeroed curtrn before checking to see if trans should
     *        written.  This mode corrects that issue
730eA*    08/14/19  DAS     7.30e
     *      - Revised to copy WORKLBLUM record to LABELUM record.
730fA*    10/18/19  KDE     7.30f
     *      - Revised PICK2 to always use type "O" for phase one
     *        For DD2 it was using type "P" and gen 2 records are
     *        always type "O"
730g *    10/21/19  RTR     7.30g
     *      - Set label records to closed for non-stock items.
     *        Controlled by OPTIONINT setting, defaults to flag/print.
730iA*    12/05/19  DAS  7.30i
     *      - Revised to call PIRLBL#W instead of PIRLBL#
     *      - Revised to call PIRTRN#W instead of PIRTRN#
     *      - Added file BFCDEBUG to record error getting next lbl#/trn#
     *      - Forcing divide by zero to halt program if error.
740aA*    06/11/20  DAS  7.40a
     *      - Fix: Revised PICK3 to write the last transaction before
     *        assigning transactions to Overflow pallets. This used to
     *        be done before the call to PICK3 was moved into PICK2.
     *        Re: PFMT prints transactions by looping through PLTSUM
     *        in reverse useq. Let's say that useq 2/3 were assigned
     *        tran #101 and useq 1/71 were assigned tran #102. PFMT
     *        would end up printing tran #102 because of reading
     *        useq 71, then #101 because of reading useq 3, it would
     *        skip useq 2 because it was same tran as useq 2, then
     *        it would print tran #102 again because of useq 1.
740bA*    06/19/20  DAS  7.40b
     *      - Fix: Missed initializint pcount=0 for 740a change.
740cA*    10/19/20  DAS  7.40c
     *      - Fix: Revised PICKB to not assume "normal" quantity.
     *        Will now call unalc1pckfx1 for brkdn1.
     *
750 A*    04/09/21  MLB  7.50
     *      - Fix: Revised Loader routine to add logic to test pallet
     *        sequence nbr to be <> 0 when TBEnhanced flag is off. If
     *        pallet sequence number = 0 and TBEnhanced flag is on then
     *        bypass the pallet.
     *
750aA*    11/18/21  RBD  7.50a
     *      - Fix: Mod 710a was preventing TOTE pallets from being written
     *        to Loader because there wasn't a TOTE record in PIRITEM.
     *        Revised to not bypass loader routine if PIRITEM not found.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Brothers, Inc.
     *
CBI A*    07/10/03  MLB  CBI
     *      -  Revised routine PICK to run PCKFIX when section is gt ' '
     *         and LWASL2 = '***'. This will cause the label record to
     *         for non-stock items to have a transaction number assigned.
CBIaA*    06/30/15  MLB  CBIa
     *      -  Force OPCRTM to always be 'N', this will make sure that
     *         a label prints for all outs.  OPCRTR should always be
     *         'Y' so that voice will create a runner flag when out
     *      -  Added CBIa to ISY mod.
CBIbA*    12/22/03  RH   CBIb
     *      -  ENH: Skip letdown logic for CONTAINER or CRUISE orders  '
CBIdA*    02/05/04  DAS  CBId
     *      -  FIX: Revised to add cc Pick qty into STOCK fields.      '
CBIeA*    10/05/04  RH   CBIe
     *      - Do not print any reports if truck code is "WILL-CALL"
     *        "SUD-SVC" or "DAMAGES" per 9-28-04 email.
     *
CBIfA*    06/01/16  RBD  CBIf
     *      - Per Keith Sanders, reactivate the 530c logic which bypasses
     *        the creation of loader recs under certain conditions.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: GLP Greenleaf
     *
GLPaA*    07/07/16  NLK  GLPa
     *      -  Force OPCRTM to always be 'N', this will make sure that
     *         a label prints for all outs.  OPCRTR should always be
     *         'Y' so that voice will create a runner flag when out
     *      -  LBLVFY has 'F' to create Runner flag for VoSelect
     *      AMP orders that were shorted should be OPCRTM 'Y' so
     *      labels don't print and still have OPCRTR = 'Y'
     *      AMP flag from PPro ORDDM fld OMMSC1 pos 1
GLPbA*    09/16/16  NLK  GLPb
     *      -  An Extension to GLPa, if we will create Runner Flag
     *         do NOT move ALC qty to PCK bucket. ONE it doesn't
     *         get picked by Selector-TWO it isn't ever cleared.
GLPcA*    06/25/20  MLB  GLPc
     *      -  Correction to GLPa. Logic was forcing OPCRTM = N
     *         for all other clients.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: I Supply
     *
ISYaA*    11/18/09  GJA  ISYa
     *      -  Force OPCRTM to always be 'N', this will make sure that
     *         a label prints for all outs.  OPCRTR should always be
     *         'Y' so that voice will create a runner flag when out
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Eastland
     *
EFCa *    11/26/13  GJA  EFCa
     *      -  Force OPCRTM to always be 'N', this will make sure that
     *         a label prints for all outs.  OPCRTR should always be
     *         'Y' so that voice will create a runner flag when out
     *
     *
     *
     *----------------------------------------------------------------
VFI  *  Client Custom Revisions: Vitco Food
     *
VFIa *    01/28/20  GJA  VFIa
     *      -  Force OPCRTM to always be 'N', this will make sure that
     *         a label prints for all outs.  OPCRTR should always be
     *         'Y' so that voice will create a runner flag when out
     *
     *
     *
     *----------------------------------------------------------------
YHT A*  Client Custom Revisions: Yhata
     *
YHT A*    10/10/08  MLB  YHT (merged from PIRMODS/OR630 into
     *                        PIRENH520/OR630 by RBD 9/16/09)
     *
     *      -  Added YHT to CBI mod as described above.
     *      -  Revised routine PICK to run PCKFIX when section is gt ' '
     *         and LWASL2 = '***'. This will cause the label record
     *         for non-stock items to have a transaction number assigned.
YHTaA*    11/19/12  MLB  YHTa  *Required IDS interface mod *
     *      - Using first five characters of LBPO to contain a label
     *        sequence number to be used by IDS. The number starts at
     *        1 for each transaction.
     *      - Added YHTa to SLB mod.
     *
     *----------------------------------------------------------------
EI   *  Client Custom Revisions: European Imports
EIb A*    08/28/11  RH   EI Add to FDIb
     *      -  Revised program to not write OUT label entries into
     *         Runner flag module.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Marques Foods
MQSa *    02/12/19  GJA  MQSa
     *      -  Revised program to not write OUT label entries into
     *         Runner flag module.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Finkle
     *
FDIaA*    01/13/08  DAS  FDIa
     *      -  Revised routine PICK to do 2 loops
FDIbA*    03/24/10  MLB  FDIb
     *      -  Revised program to not write OUT label entries into
     *         Runner flag module.
     *
     *----------------------------------------------------------------
BAD  *  Client Custom Revisions: Big Apple Deli
      *
BADa *    09/18/19  GJA  BADa
     *      -  Added BADa to ISYa mod.
     *----------------------------------------------------------------
     *  Client Custom Revisions: MJ Kellner
     *
MJK A*    08/06/08  MLB  MJK
     *      -  Added MJK to CBI mod as described above.
     *      -  Revised routine PICK to run PCKFIX when section is gt ' '
     *         and LWASL2 = '***'. This will cause the label record to
     *         for non-stock items to have a transaction number assigned.
MJKbA*    12/15/15  MLB/RH  MJKb
     *      -  Added MJK to ISYa mod.
MJKcA*    12/18/15  MLB  MJKc
     *      -  Removed MJKb mod per Mike D phone call. MJK allocates
     *         product on Retalix when product will be out. Allowing
     *         OUT labels to be printed caused the wrong customers to
     *         receive product.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval Foodservice
     *
SVLaA*    09/02/09  GJA  SVL
     *      -  Revised so that will call orders will not create runners
SVLbA*    02/04/14  MLB  SVLb
     *      -  Force OPCRTM to always be 'N', this will make sure that
     *         a label prints for all outs.  OPCRTR should always be
     *         'Y' so that voice will create a runner flag when out
     *      -  This mod replaces mod SVL above.
     *      -  Added SVLb to ISY mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fischer Foods
     *
FSHa *    09/11/16  GJA  FSHa
     *      -  Revised so that runner will not be created for OUT.
     *----------------------------------------------------------------
     *  Client Custom Revisions: SOFO
     *
SOF A*    04/01/15  MLB  SLB  *Required IDS interface mod *
     *      - Using first five characters of LBPO to contain a label
     *        sequence number to be used by IDS. The number starts at
     *        1 for each transaction.
SOFaA*    04/01/15  MLB  SOFa
     *      -  Revised routine PICK to run PCKFIX when section is gt ' '
     *         and LWASL2 = '***'. This will cause the label record to
     *         for non-stock items to have a transaction number assigned.
     *      -  Added SOF to CBI mod as described above.
SOFbA*    04/01/15  MLB  SOFb
     *      -  Force OPCRTM to always be 'N', this will make sure that
     *         a label prints for all outs.  OPCRTR should always be
     *         'Y' so that voice will create a runner flag when out
     *      -  Added SOFb to ISYa mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Halsey
     *
HALaA*    02/15/10  GJA  HALa
     *      -  Revised so that runner will not be created for OUT.
HALbA*    02/17/10  RH   HALb
     *      -  Fix: Add code to not update LBVFY="F" for OUT label.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: VIP Foodservice
     *
VIP A*    04/09/07  MLB  VIP
     *      -  Added VIP to CBI mod as described above.
     *      -  Revised routine PICK to run PCKFIX when section is gt ' '
     *         and LWASL2 = '***'. This will cause the label record to
     *         for non-stock items to have a transaction number assigned.
VIPbA*    06/21/12  RH   VIPb
     *      -  Enh: Do not process Will Call for LOADER module
     *
VIP A*----------------------------------------------------------------
510a *  Client Custom Revisions: USF-Corp
     *
USF A*    06/14/05  MLB  USF
     *      - Using first ten characters of LBDSP2 to contain a label
     *        sequence number to be used by P-Sys. The number starts at
     *        1 for each transaction.
USFaA*    08/16/05  MLB  USFa
     *      - Revised program to call GETBLDC to retrieve group code
     *        that is stored in item build code.
USFbA*    08/18/05  MLB  USFb
     *      - Revised program to add filler character to Group/Load/
     *        Batch/Batch Seq string stored in LBDSP2.
USFcA*    08/22/05  MLB  USFc
     *      - Revised program to reset Batch counter every time Group
     *        code changes.
     *    ------------------------------------------
     *    --added from OR630P from USF mod marks  --
     *    --USF mods h,i,j,k,p converted to 710   --
     *    ------------------------------------------
USFdA*    11/30/06  MLB  USFd
     *      - Revised program to create label sequence number when
     *        USF client location = ASYS.
USFeA*    12/02/06  MLB  USFe
     *      - Revised program to add file WORKLBLU. WORKLBLU will be
     *        used to ensure that duplicate group/load/batch keys are
     *        not created.
USFfA*    12/07/06  MLB  USFf
     *      - Revised USFd mod above. Add call to GETUSFSYS to retrieve
     *        USF System Type (ASYS or PSYS).
USFgA*    01/19/07  MLB  USFg
     *      - Revised program to retrieve USF Group Code from *PICK pick
     *        zone record instead of retrieving Build Code for item.
     *        This change is for P-Sys only.
USFlA*    03/02/07  MLB  USFl
     *      - BULK was revised to create assignment id for A-Sys
     *        and P-Sys transactions.
USFmA*    04/09/08  JCJ  USFm-P#00020
     *      - Revised subroutines PICK & PICKB to ignore label type
     *        of 'M' when deciding to reset batch number.
USFnA*    07/29/08  JCJ  USFn-P#00099
     *      - Add call to program to process Single work Assignment
     *        picks.
USFoA*    10/10/08  JCJ  USFo-P#00099
     *      - Add code to only do Single work Asignment picks for
     *        ASys branches.
USFqA*    07/05/12   JCJ  USFq
     *      - Enh: If Multi Route Picking PCMD2 = '*STGPRNT' don't
     *        assign USF Assignment numbers.
     *
510 A*----------------------------------------------------------------
510 A*  Westside Custom Revisions
510 A*
WSTaA*    10/03/06  DAS  WSTa
     *      - Revised assigning of transaction numbers to be by side
     *        by using new file PLTSUM10 instead of PLTSUM3. Also,
     *        a transaction will only include pallets for one side.
     *
WSTbA*    10/03/06  DAS  WSTb
     *      - Conditioned CHK4OB so it wouldn't be called for WestSide
WSTcA*    06/13/09  HNK  WSTc (originally WSTa)
     *      - Changed to pirnt custom ord# and cust name.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
CLD A*    08/13/04  MLB  CLD
     *      -  Revised program to not create 'OUT' label for PIR item
     *         that don't have any slots in warehouse.
     *
CLDAA*    12/16/04  DAS  CLDa
     *      -  ENH: Skip letdown logic for all orders, don't create
     *         letdowns, system will create JIT letdowns.
     *
CLDb *    03/08/11  GJA  CLDb
     *      -  Revised program to not write OUT label entries into
     *         Runner flag module.
CLDc *    04/27/11  GJA  CLDc
     *      -  If OUT label and there is no slot send to runner
CLDd *    10/02/13  JCJ  CLDd
     *      -  added CLDc mod to CLDb.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Renzi Foodservice
     *
RNZaA*    03/27/09  MLB  RNZa
     *      - Revised array OVR to use OUTQ instead of DEV on prtf
     *        overrides. Removed parm OUTQ(*DEV).
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRYa *    06/25/10  GJA  DRYa
     *      - Force OPCRTM to always be 'N', this will make sure that
     *        a label prints for all outs.  OPCRTR should always be
     *        'Y' so that voice will create a runner flag when out.
     *
DRYb *    03/24/22  RBD  DRYb
     *      -  Enh: Do not process Will Call for LOADER module
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dierks Waukesha
     *
DRKaA*    02/23/10  DAS  DRKa
     *      - Temp mod to force Letdowns (OPJITR = '1')
     *
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Royal
     *
RYLaA*    07/12/10  JCJ  RYLa
     *      -  Revised program to not write OUT label entries into
     *         Runner flag module.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Accardi
     *
ACCa *    04/15/19  GJA  ACCa
     *      -  Revised program to not write OUT label entries into
     *         Runner flag module.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Presto
     *
PFCa *    11/02/14  GJA  PFCa
     *      -  Revised program to not write OUT label entries into
     *         Runner flag module.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt Produce
     *
CSPaA*    02/24/11  MLB  CSPa
     *      -  Revised program to not write OUT label entries into
     *         Runner flag module.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Glazier Foods
     *
GFC A*    07/25/11  MLB  GFC
     *      -  Added GFC to CBI mod as described above.
     *      -  Revised routine PICK to run PCKFIX when section is gt ' '
     *         and LWASL2 = '***'. This will cause the label record to
     *         for non-stock items to have a transaction number assigned.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: AJ Silberman's
     *
SLB A*    10/02/11  MLB  SLB  *Required IDS interface mod *
     *      - Using first five characters of LBPO to contain a label
     *        sequence number to be used by IDS. The number starts at
     *        1 for each transaction.
SLBaA*    10/02/11  MLB  SLBa
     *      -  Revised routine PICK to run PCKFIX when section is gt ' '
     *         and LWASL2 = '***'. This will cause the label record to
     *         for non-stock items to have a transaction number assigned.
     *      -  Added SLB to CBI mod as described above.
SLBb *    11/08/11  GJA  SLBb
     *      -  Revised program to not write OUT label entries into
     *         Runner flag module.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Graves MenuMaker
     *
GMMa *    08/01/12  GJA  GMMa
     *      -  Revised program to not write OUT label entries into
     *         Runner flag module.
GMMbA*    05/30/18  MLB  GMMb
     *      -  Added BIR to CBI mod as described above.
     *      -  Revised routine PICK to run PCKFIX when section is gt ' '
     *         and LWASL2 = '***'. This will cause the label record to
     *         for non-stock items to have a transaction number assigned.
GMMcA*    05/30/18  MLB  GMMc  *Required Retalix interface mod *
     *      - Using first five characters of LBPO to contain a label
     *        sequence number to be used by IDS. The number starts at
     *        1 for each transaction.
     *      - Added GMMc to SLB mod.
GMMdA*    02/10/20  MLB  GMMd
     *      - Do not use phase transaction processing for Jordanos.  They
     *        want transactions assigned in order of department
     *      - Added GMMd to JORb mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: BiRite Foodservice
     *
BIRbA*    07/19/12  MLB  BIRb
     *      -  Force OPCRTM to always be 'N', this will make sure that
     *         a label prints for all outs.  OPCRTR should always be
     *         'Y' so that voice will create a runner flag when out
     *      -  Added BIRb to ISYa mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cash Wa Distributing
     *
CWD A*    04/23/13  MLB  CWD
     *      - Force OPCRTM to always be 'N', this will make sure that
     *        a label prints for all outs.  OPCRTR should always be
     *        'Y' so that voice will create a runner flag when out
     *      - Added CWD to ISYa mod.
CWDaA*    02/07/14  MLB  CWDa
     *      - Disable mod CWD above per Dustin H. phone message 02/07/14.
CWDbA*    09/14/14  MLB  CWDb
     *      - Force OPCRTM to always be 'N', this will make sure that
     *        a label prints for all outs.  OPCRTR should always be
     *        'Y' so that voice will create a runner flag when out.
     *        Aberdeen whse only.
     *      - Added CWD to ISYa mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jordano's
     *
JOR A*    06/13/13  MLB  JOR  *Required IDS interface mod *
     *      - Using first five characters of LBPO to contain a label
     *        sequence number to be used by IDS. The number starts at
     *        1 for each transaction.
     *      - Added JOR to SLB mod.
JORaA*    07/18/16  MLB  JORa
     *      - Force OPCRTM to always be 'N', this will make sure that
     *        a label prints for all outs.  OPCRTR should always be
     *        'Y' so that voice will create a runner flag when out
     *      - Added JORa to ISYa mod.
JORaA*    04/15/19  KDE  JORb
     *      - Do not use phase transaction processing for Jordanos.  They
     *        want transactions assigned in order of department
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Springfield
     *
SGCaA*    11/21/13  RBD  SGCa
     *      -  Enh: Do not process Will Call for LOADER module
SGCbA*    11/24/14  MLB  SGCb
     *      -  Force OPCRTM to always be 'N', this will make sure that
     *         a label prints for all outs.  OPCRTR should always be
     *         'Y' so that voice will create a runner flag when out
     *      -  Added SGCb to ISYa mod.
SGCcA*    09/29/16  MLB  SGCc
     *      -  Added SGCc to CBI mod as described above.
     *      -  Revised routine PICK to run PCKFIX when section is gt ' '
     *         and LWASL2 = '***'. This will cause the label record to
     *         for non-stock items to have a transaction number assigned.
SGCdA*    09/29/16  MLB  SGCd  *Required IDS interface mod *
     *      - Using first five characters of LBPO to contain a label
     *        sequence number to be used by IDS. The number starts at
     *        1 for each transaction.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Will Foods
     *
WILA *   10/06/15  GJA  WILa
     *     -  Force OPCRTM to always be 'N', this will make sure that
     *        a label prints for all outs.  OPCRTR should always be
     *        'Y' so that voice will create a runner flag when out
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Julius Silvert
     *
JSLa *    10/14/15  GJA  JSLa
     *      -  Force OPCRTM to always be 'N', this will make sure that
     *         a label prints for all outs.  OPCRTR should always be
     *         'Y' so that voice will create a runner flag when out
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: S Bertram
     *
SBR A*   02/01/16  MLB  SBR
     *     - Force OPCRTM to always be 'N', this will make sure that
     *       a label prints for all outs.  OPCRTR should always be
     *       'Y' so that voice will create a runner flag when out
     *     - Added SBR to ISYa mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: SouthWest Trader
     *
SWTa *   03/28/19  GJA  SWTa
     *      - Force OPCRTM to always be 'N', this will make sure that
     *        a label prints for all outs.  OPCRTR should always be
     *        'Y' so that voice will create a runner flag when out
     *      - Added SWTa to ISYa mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: HM Wagner
     *
HMW A*    01/04/15  MLB  HMW
     *      - Force OPCRTM to always be 'N', this will make sure that
     *        a label prints for all outs.  OPCRTR should always be
     *        'Y' so that voice will create a runner flag when out
     *      - Added HMW to ISYa mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: FoodPro
     *
FPR A*    03/04/16  MLB  FPR  *Required IDS interface mod *
     *      - Using first five characters of LBPO to contain a label
     *        sequence number to be used by IDS. The number starts at
     *        1 for each transaction.
FPRaA*    03/04/16  MLB  FPRa
     *      -  Revised routine PICK to run PCKFIX when section is gt ' '
     *         and LWASL2 = '***'. This will cause the label record to
     *         for non-stock items to have a transaction number assigned.
     *      -  Added SLB to CBI mod as described above.
FPRbA*    03/04/16  MLB  FPRb
     *      -  Revised program to not write OUT label entries into
     *         Runner flag module.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: TPC
     *
TPCaA*    11/19/07  RH   TPCa
     *      - Revised program to print zone merge for all bulk pick.t
TPCbA*    02/06/08  MLB  TPCb
     *      - Revised program to bypass Bulk Drops for bulk picks.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: A&D Foods
     *
ADF A*    03/21/18  MLB  ADF
     *      - Force OPCRTM to always be 'N', this will make sure that
     *        a label prints for all outs.  OPCRTR should always be
     *        'Y' so that voice will create a runner flag when out
     *      - Added ADF to ISYa mod.
     *
ADFaA*    05/19/21  RBD  ADFa
     *      -  Enh: Do not process Will Call for LOADER module
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kelly's Foods
     *
KFS A*    03/03/19  MLB  KFS
     *      -  Added KFS to CBI mod as described above.
     *      -  Revised routine PICK to run PCKFIX when section is gt ' '
     *         and LWASL2 = '***'. This will cause the label record to
     *         for non-stock items to have a transaction number assigned.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greco & Sons
     *
GRC A*    03/06/19  MLB  GRC
     *      - Force OPCRTM to always be 'N', this will make sure that
     *        a label prints for all outs.  OPCRTR should always be
     *        'Y' so that voice will create a runner flag when out
     *      - Added GRC to ISYa mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Colony Foods
     *
CFI A*    09/17/18  MLB  CFI
     *      - Force OPCRTM to always be 'N', this will make sure that
     *        a label prints for all outs.  OPCRTR should always be
     *        'Y' so that voice will create a runner flag when out
     *      - Added CFI to ISYa mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Natalie's Organic
     *
NOJ A*    02/09/21  MLB  NOJ
     *      - Force OPCRTM to always be 'N', this will make sure that
     *        a label prints for all outs.  OPCRTR should always be
     *        'Y' so that voice will create a runner flag when out
     *      - Added NOJ to ISYa mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Seashore Fruit & Produce
     *
SFP A*    08/28/22  MLB  SFP
     *      - Force OPCRTM to always be 'N', this will make sure that
     *        a label prints for all outs.  OPCRTR should always be
     *        'Y' so that voice will create a runner flag when out
     *      - Added NOJ to ISYa mod.
     *
411 A*----------------------------------------------------------------
     *  Quantity Types Notes
     *
411 A*   Contract Item
     *     - Quantity ordered is allocated from the warehouse quantity
     *       of the Contract item.
     *     - Quantity ordered is NOT allocated from the warehouse quantity
     *       of Base item (it was allocated at receiving).
     *     - Quantity is allocated from slots containing the Base item.
     *     - Label record will contain Contract item number.
     *     - Label record type will correspond to quantity type being
     *       received (Normal, Brk1, Brk2).
     *
     *   Same Slot Breakdown (SSB) Item
     *     - Quantity ordered is allocated from Base item Warehouse/Slot
     *       breakdown quantities (ie. a normal qty being picked will be
     *       allocated from the warehouse breakdown 1 quantity).
     *     - Quantity is allocated from slots containing the Base item.
     *     - Label record will contain SSB item number.
     *     - Label record type will correspond to warehouse/slot
     *       quantity being used internally (ie. a normal qty being
     *       picked will be put into the warehouse/slot breakdown 1
     *       quantity and would therefore have a label type of '2'.
     *
411 A*----------------------------------------------------------------
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
     *----------------------------------------------------------------
     *  Indicator usage
     *
USFeA*  50        USF Group/Load/Batch sequence found
     *  79        Chain indicator
     *  90        Overflow indicator for exception report
     *  91        Overflow indicator for catch weight report
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
FDIaDF*ltsum3   uf   e           k disk
FDIaMFpltsum3   uf a e           k disk
710dAFpltsum5a  uf   e           k disk
710dAF                                     rename(psrec:psrec5)
710fAFpltsum14  uf   e           k disk
710fAF                                     rename(psrec:psrec14)
WSTaAFpltsum10  uf   e           k disk
     F                                     rename(psrec:psrec10)
     Fworklbl5  uf   e           k disk
     Fslot2     uf   e           k disk
     Foptionz   if   e           k disk
410aAFoptions   if   e           k disk
     Fpiritem   if   e           k disk
414cAFitemdsc   if   e           k disk
404 AFworklbl7  uf   e           k disk
     F                                     rename(lwrec:lwrec7)
404 AFpltsum4   uf   e           k disk
     F                                     rename(psrec:psrec4)
720aAFpltsum8   uf   e           k disk    prefix(ps8_)
720aAF                                     rename(psrec:psrec8)
404 AFpltstp1   uf   e           k disk
404 AFcrossdk1  uf   e           k disk
410 AFpirslct1  if   e           k disk
410 AFordh      if   e           k disk
GLPaAForddm     if   e           k disk
416 AFLabel13   uf a e           k disk
410aAFworklbl   o    e           k disk
     F                                     rename(lwrec:lwrec0)
520dAFzoneh     if   e           k disk
     Fordt      o  a e             disk
413aAFpirtrck2  o    e             disk
410 AFordslct   uf a e           k disk
500eAFbulkdrp   o  a e             disk
520 AFLdrhdr    uf a e           k disk
650cDF*Ldrdetl2  uf a e           k disk
650cDF*                                    rename(lddrec:lddrc2)
520 AFLdrdetl   uf a e           k disk
720bMFOR630PR   O    E             PRINTER OFLIND(*IN90)
     F                                     usropn
530 AFtruckh    if   e           k disk
710aAFworklbl6  if   e           k disk
710aAF                                     rename(lwrec:lwrec6) prefix(wl_)
710aAFitemfld   if   e           k disk
730iAFbfcdebug  o  a e           k disk    rename(bdrec:bdbrec)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a40             s              1    dim(40)
415 AD a80             s              1    dim(80)
410 MD msg             s             40    dim(4) ctdata perrcd(1)
410 D*                   MSG     1   3 40
720bMD ovrprt          s             80    dim(1) ctdata perrcd(1)
500 A*----------------------------------------------------------------
500 A*  Client ID
500 A*
     D @getcl          c                   const('GETCLIENT')
500 A*
500 A* client source entries go here.
ADF A /COPY QCOPYSRC,ID#ADF
BIRbA /COPY QCOPYSRC,ID#Birite
CWD A /COPY QCOPYSRC,ID#Cashwa
JOR A /COPY QCOPYSRC,ID#Jordano
CBI A /COPY QCOPYSRC,ID#CHENEY
CLD A /COPY QCOPYSRC,ID#CITYLIN
CSPaA /COPY QCOPYSRC,ID#COASTAL
DRY A /copy qcopysrc,id#dairyla
DRKaA /copy qcopysrc,id#dierks
EFCaA /copy qcopysrc,id#eastlan
EI aA /COPY QCOPYSRC,ID#EI
ELL AD/COPY QCOPYSRC,ID#ELLENBE
FDIaA /COPY QCOPYSRC,ID#FINKLE
FSHaA /COPY QCOPYSRC,ID#FISCHER
GFC A /COPY QCOPYSRC,ID#GLAZIER
GLPaA /COPY QCOPYSRC,ID#GLP
730fA /COPY QCOPYSRC,ID#MQS
GMMaA /COPY QCOPYSRC,ID#GMM
HALaA /COPY QCOPYSRC,ID#HALSEY
FPR A /COPY QCOPYSRC,ID#FPR
HMW A /COPY QCOPYSRC,ID#HMWAGNE
ISYaA /COPY QCOPYSRC,ID#ISUPPLY
JSLaA /COPY QCOPYSRC,ID#JSL
MJK A /COPY QCOPYSRC,ID#MJKELLN
ACCaA /COPY QCOPYSRC,ID#ACC
RNZ A /COPY QCOPYSRC,ID#RENZI
RYLaA /COPY QCOPYSRC,ID#ROYAL
SVLaA /COPY QCOPYSRC,ID#SAVAL
SBRaA /COPY QCOPYSRC,ID#SBR
SGCaA /COPY QCOPYSRC,ID#SGC
PFCaA /COPY QCOPYSRC,ID#PFC
SLB A /COPY QCOPYSRC,ID#SILBERM
SOF A /COPY QCOPYSRC,ID#SOFO
TPC A /copy qcopysrc,id#tpc
510aA /COPY QCOPYSRC,ID#USFCRP
VIP A /COPY QCOPYSRC,ID#VIP
WSTaA /COPY QCOPYSRC,ID#WESTSID
WILaA /COPY QCOPYSRC,ID#WIL
YHT A /COPY QCOPYSRC,ID#YHATA
SWTaA /COPY QCOPYSRC,ID#SWT
GRC A /COPY QCOPYSRC,ID#GRC
GLPaA /COPY QCOPYSRC,ORDDM1_AMP
KFS A /COPY QCOPYSRC,ID#KFS
VFIaA /COPY QCOPYSRC,ID#VFI
BADaA /COPY QCOPYSRC,ID#BAD
CFI A /COPY QCOPYSRC,ID#CFI
NOJ A /COPY QCOPYSRC,ID#NOJ
SFP A /COPY QCOPYSRC,ID#SFP
500 A*
500 A* Constants
     D tsinz           c                   const('0001-01-01-00.00.00.-
     D                                     000000')
404 A*----------------------------------------------------------------
404 A*  General Data structure.
404 A*
404 AD ds0             ds
404 AD  dsrec                  1     30
404 AD  dslbl#                 1      7  0
404 AD  dsfpck                 8     12  0
404 AD  dsfcub                13     21  3
404 AD  dsfwgt                22     30  2
USF A*----------------------------------------------------------------
USF A*  USF Corp - Batch key ds.
USF A*
USF AD usfkey          ds
USF AD  usfgrp                 1      1
USF AD  usfrte                 2      4
USFdAD  usfasq                 1      4  0
USFbAD  usffil                 5      5  0
USFBD*                                       5   60USFBAT
USFBMD  usfbat                 6      7  0
USFeAD  usfglb                 1      7
USFbD*                                       7  100USFSEQ
USFbMD  usfseq                 8     11  0
USFcAD                 ds
USFcAD  hldgrp                 1      1
USF A*
404 A*----------------------------------------------------------------
404 A*  Data structure.
404 A*
404 AD ds1             ds                  occurs(50)
404 AD  ary                    1   1500
     D                                     DIM(30)
404 AD  lstary              1501   1502  0
     *----------------------------------------------------------------
     *  *PICK  -  Picking options
     *
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
     *    OPPBRK  -  Aisle to start new pallet.
400 A*    OPPBLD  -  Pallet building method.
400 A*                1 = By stop then slot location.
400 A*                2 = By slot location then stop.
400 A*    OPSELM  -  Selection method.
400 A*                1 = Single pass (By location).
400 A*                2 = Multiple pass (By stop).
400 A*    OPSPLT  -  Allow stop to be split across pallets (Y/N).
USFgA*    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
520dA*    OPNWPL  -  Start new pallet when aisle changes if build method
520dA*               is 2=Location.
520dA*    OPFORD  -  Maximun orders per pallet.
520dA*    OPPTYP  -  Pallet type (P=Pallet, T=Tote).
520dA*    OPFTOT  -  Maximum totes per pallet.
520dA*    OPTECB  -  External tote cube.
520dA*    OPTICB  -  Internal tote cube.
520dA*    OPTSTP  -  Maximum stops per tote.
520dA*    OPTPCS  -  Maximum pieces per tote.
520dA*    OPSTOP  -  Honor *SP flag (Y=Yes, N=No).
520dA*    OPGCDE  -  USF Group Code (0-9).
520dA*    OPPKUP  -  Picked up by (S=Selector, L=Loader).
520dA*    OPSPAL  -  Merge pallet should only contain
520dA*               items for single truck pallet (Y=Yes, N=No).
650aA*    OPLBL   -  Label printing method.
650aA*                N = Normal
650aA*                S = Side by side
     *
     * Data structure
     *
520dDD*opzdta          ds
520dMD opzdta1         ds
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
400 AD  oppbld                34     34
400 AD  opselm                35     35
400 AD  opsplt                36     36
400 AD  opbmrg                37     37
520dAD  opnwpl                38     38
520dAD  opford                39     40  0 inz(0)
520dAD  opptyp                41     41
520dAD  opftot                42     43  0 inz(0)
520dAD  optecb                44     48  2 inz(0)
520dAD  opticb                49     53  2 inz(0)
520dAD  optstp                54     55  0 inz(0)
520dAD  optord                56     57  0 inz(0)
520dAD  optpcs                58     60  0 inz(0)
520dAD  opstop                61     61
520dA** Note: Pos 62 is OPGCDE for USF, but OPPKUP for all other clients.
520dAD**opgcde                62     62
520dAD  oppkup                62     62
520dAD  opspal                63     63
650aAD  oplbl                 68     68
700aMD  opgcde                76     76
     D  opdend               117    117
520dA*----------------------------------------------------------------
520dA*  *PICK  -  Picking options
520dA*
520dA*----------------------------------------------------------------
     *
     * Fields
     *
     *    xPNXTP  -  Next pallet number.
     *    xPBPCK  -  Bulk pick definition.
     *    xPPCUB  -  Maximum cube for PIR.
     *    xPFPAL  -  Pallets on fixed fork lift.
     *    xPFCUB  -  Maximum cube per fixed pallet.
     *    xPFSTP  -  Maximum stops per fixed pallet.
     *    xPINCL  -  Include PIR in fixed cube.
     *    xPSRCH  -  Number of previous pallets to search for space.
     *    xPFBLD  -  Fixed pallet building method.
     *                1 = By piece without concern for splitting stop.
     *                2 = By stop without splitting stop between plts.
     *    xPPBRK  -  Aisle to start new pallet.
     *    xPPBLD  -  Pallet building method.
     *                1 = By stop then slot location.
     *                2 = By slot location then stop.
     *    xPSELM  -  Selection method.
     *                1 = Single pass (By location).
     *                2 = Multiple pass (By stop).
     *    xPSPLT  -  Allow stop to be split across pallets (Y/N).
     *    xPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
     *    xPNWPL  -  Start new pallet when aisle changes if build method
     *               is 2=Location.
     *    xPFORD  -  Maximun orders per pallet.
     *    xPPTYP  -  Pallet type (P=Pallet, T=Tote).
     *    xPFTOT  -  Maximum totes per pallet.
     *    xPTECB  -  External tote cube.
     *    xPTICB  -  Internal tote cube.
     *    xPTSTP  -  Maximum stops per tote.
     *    xPTPCS  -  Maximum pieces per tote.
     *    xPSTOP  -  Honor *SP flag (Y=Yes, N=No).
     *    xPPKUP  -  Picked up by (S=Selector, L=Loader).
     *    xPSPAL  -  Merge pallet should only contain
     *               items for single truck pallet (Y=Yes, N=No).
650aA*    xPLBL   -  Label printing method.
650aA*                N = Normal
650aA*                S = Side by side
     *
     * Data structure
     *
     D opzdta2         ds
     D  xpnxtp                 1      7  0 inz(0)
     D  xppcub                10     14  2 inz(0)
     D  xpfpal                15     15  0 inz(0)
     D  xpfcub                16     20  2 inz(0)
     D  xpincl                22     22
     D  xpsrch                23     24  0 inz(0)
     D  xpfstp                25     26  0 inz(0)
     D  xpfbld                27     27  0 inz(0)
     D  xpbpck                28     30  0 inz(0)
     D  xppbrk                31     33
     D  xppbld                34     34
     D  xpselm                35     35
     D  xpsplt                36     36
     D  xpbmrg                37     37
     D  xpnwpl                38     38
     D  xpford                39     40  0 inz(0)
     D  xpptyp                41     41
     D  xpftot                42     43  0 inz(0)
     D  xptecb                44     48  2 inz(0)
     D  xpticb                49     53  2 inz(0)
     D  xptstp                54     55  0 inz(0)
     D  xptord                56     57  0 inz(0)
     D  xptpcs                58     60  0 inz(0)
     D  xpstop                61     61
     D  xppkup                62     62
     D  xpspal                63     63
650aAD  xplbl                 68     68
     D  xpdend               117    117
410aA*----------------------------------------------------------------
410a *  *GENPICK  -  General Picking options
410a *
410a * Fields
410a *
410aA*    OPERPT  -  Print exception (short) error report (Y,N).
410aA*    OPELBL  -  Print exception (short) labels (Y,N)
410BA*    OPRFWC  -  Using RF will call (Y,N).
413cA*    OPNRSC  -  Number of pallet sections (1-9).
414aA*    OPHPWC  -  Host pick Will Call (Y/N).
500aA*    OPMRGA  -  Merge Add-on order(s) with Open Routes.
500aA*    OPPLSQ  -  Pallet number sequence. 1=Unload, 2=Load.
500aA*    OPEADJ  -  Close short labels without adjustment (Y,N).
500aA*    OPNOPK  -  Pick items without pick slot as bulk pick? (Y/N)
500cM*    OPJITR  -  Create JIT Letdown or JIT Replenishment
500cM*                 0=None. No replenishments are created.
500cA*                 1=Letdowns are created during Truck Builder
500cA*                   Pick/Print processing.
500cA*                 2=Priority Replenishments are created during
500cA*                   Truck Builder Pick/Print processing.
500cA*                 3=JIT Letdowns created when transaction is
500cA*                   checked out.
500cA*                 4=JIT Priority Replenishments created when
500cA*                   transaction is checked out.
410 A*
410 A* Data structure
410 A*
414cD*PDATA      DS
414cMD opdta1          ds
410aAD  operpt                 1      1
410aAD  opelbl                 2      2
410bAD  oprfwc                 3      3
413cAD  opnrsc                 4      4  0
414aAD  ophpwc                 5      5
500aAD  opmrga                 6      6
500aAD  opplsq                 7      7
500aAD  opeadj                 8      8
500aAD  opnopk                 9      9
500aAD  opjitr                12     12
410aAD  optend               117    117
414cAD opdta2          ds
414cAD  opstyp                 1      1
414cAD  opwhdp                 2      6
414cAD  opum1                  7      8
414cAD  opdum                  9     23
414cAD  opcum                 24     43
414cAD  opcdiv                44     52  2
414cAD  opcaut                53     53
414cAD  opcwrn                54     54
414cAD  opcrng                55     57  1
414cAD  opwum                 58     72
414cAD  opxdsc                73     73
510dA*----------------------------------------------------------------
510dA*  *RUNNER  -  PIR Runner Flag Options
510dA*----------------------------------------------------------------
510dA*
510dA* Fields
510dA*
510dA*    OPCRTM  -  Create Manual Runner entries for shorts/outs (Y/N)
510dA*    OPUPLR  -  Update Label with quantity shorted during manual
510dA*               flag entry (Y/N)
510dA*               NOTE: Any change to this field will cause OPUPLV
510dA*                     in the *VOICE options record to be updated.
510dA*    OPRPLF  -  Replenish flagged items before print report? (Y/N)
510dA*               & create Priority Replenishment if necessary.
510dA*    OPMRGF  -  Create Runner entries for Merge records? (Y/N)
510dA*    OPCLRF  -  Clear Runner flags if qty still short/out? (Y/N)
510dA*    OPRNRM  -  Send break message to user when new Runner
510dA*               task has been assigned. (Y/N)
510dA*    OPCLSF  -  Update Label quantity at flag close (Y/N).
510dA*    OPOUTF  -  Create Runner entry after slot marked out. (Y/N)
510dA*    OPRPCK  -  Print Runner pick list. (Y/N)
510dA*    OPRLBL  -  Print Runner pick labels. 0=No, 1=full size Zebra
510dA*               printer, 2=Belt printer
650cA*    OPRBDU  -  Allow shorts to be filled with breakdown units (Y/N).
650cA*    OPRSCN  -  Scan tran# or label# to start pick.
650cA*                 1=tran#, 2=label#.
650cA*    OPRVFS  -  Verify pick slot, Y/N.
650cA*    OPRVFQ  -  Verify qty found, Y/N.
650cA*    OPRLOA  -  Using loader module, Y/N.
510dA*
510dA* Data structure
510dA*
510dAD opdtar          ds
510dAD  opcrtm                 1      1
510dAD  opuplr                 2      2
510dAD  oprplf                 3      3
510dAD  opmrgf                 4      4
510dAD  opclrf                 5      5
510dAD  oprnrm                 6      6
510dAD  opclsf                 7      7
510dAD  opoutf                 8      8
510dAD  oprpck                 9      9
510dAD  oprlbl                10     10
650cAD  oprbdu                11     11
650cAD  oprscn                12     12
650cAD  oprvfs                13     13
650cAD  oprvfq                14     14
650cAD  oprloa                15     15
510dAD  optenr               117    117
510dA*
     *----------------------------------------------------------------
700aA*  *LOADER  -  Loader options.
700aA*----------------------------------------------------------------
700aA*
700aA* Fields
700aA*
     *    OPSTTM  -  Start time for a day's routes.
     *    OPENTM  -  End time for a day's routes.
     *    OPLDOR  -  Loading order.
     *    OPTLID  -  Speak trailer id.
     *    OPRWCL  -  Speak row/column.
     *    OPVYPL  -  Verify pallet position.
     *    OPVFYP  -  Verify pallet label against pick label.
     *    OPADDO  -  Auto define add-on routes Y/N.
     *
     * Data structure
     *
     D opdat6          ds
     D  opsttm                 1      6  0
     D  opentm                 7     12  0
     D  opldor                13     13
     D  optlid                14     14
     D  oprwcl                15     15
     D  opvypl                16     16
     D  opvfyp                17     17
     D  opaddo                18     18
     D  op6end               117    117
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
413aA*----------------------------------------------------------------
413aA*
413aA* The following data structures are for capturing picking
413aA* tracking info.
413aA*
413aA*----------------------------------------------------------------
413aA*  *PCK001   -  Picking Batch detail info
413aA*----------------------------------------------------------------
413aA*
413aA* Fields
413aA*
413aA*    TRPCMD  -  Program processing option
413aA*    TRPPRG  -  Calling program
413aA*    TROTYP  -  Order type
413aA*    TRRORD  -  Restart Order number
413aA*    TRPKST  -  Picking status
413aA*    TRFLPK  -  Picking options error flag (0=Rcd found, 1=Missing)
413aA*    TRFLTK  -  Truck options error flag (0=Rcd found, 1=Missing)
413aA*
413aA* Data structure
413aA*
413aAD tr01ds          ds
413aAD  trpcmd                 1      8
413aAD  trprg                  9     18
413aAD  trotyp                19     19
413aAD  trrord                20     26  0
413aAD  trpkst                27     46
413aAD  trflpk                47     47
413aAD  trfltk                48     48
413aAD  trdt01                 1    150
413aA*----------------------------------------------------------------
413aA*  *PCK002  -  General Picking options
413aA*----------------------------------------------------------------
413aA*
413aA* Fields
413aA*
413aA*    Note: See general picking options definition.
413aA*
413aA* Data structure
413aA*
413aAD tr02ds          ds
413aAD  trdt02                 1    150
413aA*----------------------------------------------------------------
413aA*  *PCK003  -  Truck Header info
413aA*----------------------------------------------------------------
413aA*
413aA* Fields
413aA*
413aA*    TRROWS -  Row in trailer
413aA*    TRCOLS -  Column in trailer
413aA*    TRBULK -  Allow bulk picks (Y/N)
413aA*    TRBAT  -  Allow batch picks (Y/N)
413aA*
413aA* Data structure
413aA*
413aAD tr03ds          ds
413aAD  trrows                 1      2  0
413aAD  trcols                 3      3  0
413aAD  trbulk                 4      4
413aAD  trbat                  5      5
413aAD  trdt03                 1    150
413aA*----------------------------------------------------------------
413aA*  *PCK010  -  Zone pick options definition.
413aA*----------------------------------------------------------------
413aA*
413aA* Fields
413aA*
413aA*    TRDT10  -  See defintion for zone pick options.
413aA*
413aA* Data structure
413aA*
413aAD tr10ds          ds
413aAD  trdt10                 1    150
413aA*----------------------------------------------------------------
413aA*  *PCK040  -  Subroutines entered
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
     D                                     DIM(25)
413aAD  trrfld                 1    150
413aA*----------------------------------------------------------------
413aA*  *PCK050  -  Tracking message(s)
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
     D tr05            c                   const('Item master record n-
     D                                     ot on file.')
     D tr06            c                   const('Picking options not -
     D                                     found for zone.')
     D tr07            c                   const('QtyAlc1:')
     D tr08            c                   const('QtyAlc2:')
     D tr09            c                   const('QtyAlc3:')
     D tr10            c                   const('QtyPck1:')
     D tr11            c                   const('QtyPck2:')
     D tr12            c                   const('QtyPck3:')
     D tr13            c                   const('Dept:')
     D tr14            c                   const('Slot:')
413aA*  Picking status messages.
     D trerfl          c                   const('*NOTFOUND')
     D tr15            c                   const('Warehouse picking co-
     D                                     mpleted with no erro-
     D                                     rs.')
     D tr16            c                   const('Warehouse picking co-
     D                                     mpleted with at leas-
     D                                     t one picking except-
     D                                     ion.')
     D tr80            c                   const('Picked              ')
     D tr81            c                   const('Picking error       ')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @addtr          c                   const('ADDSTDTRN')
     D @getsi          c                   const('GETSLOTITM')
     D @cvtdt          c                   const('CVTDTE')
     D @usrms          c                   const('USRMSG')
USFnAD @sw             c                   const('OR630PW')
     *----------------------------------------------------------------
CBIe *  Constants
CBIe D @wlcll          c                   const('WILL-CALL')
CBIe D @sdsvc          c                   const('SUD-SVC')
CBIe D @dmges          c                   const('DAMAGES')
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
     *  Program info data structure
     *
730iA /copy qcopysrc,c#pgminfds
730iDD*               sds
730iDD* #prog            *proc
730iDD* #job                 244    253
730iDD* #user                254    263
730iDD* #jobn                264    269
730iDD* #jobdt               276    281  0
730iDD* #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------
730eA /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     * Work variables
     *----------------------------------------------------------------
     D $laisl          s                   like(slaisl)
     D $ldisp          s                   like(sldisp)
     D $lhand          s                   like(slhand)
     D $lloc           s                   like(slloc)
     D $lrlvl          s                   like(slrlvl)
     D $mcord          s              7
     D $msgdt          s            128
     D $muser          s             10
     D $pjob           s             10
     D $puser          s             10
     D blkpcs          s              5  0
710aAD BypassLoader    s               n
     D curpal          s                   like(lwpal#)
     D curtrn          s                   like(lwtrn#)
     D curtyp          s              2
     D cvt5a           s              5
     D cvt8a           s              8
     D difcub          s                   like(lwcube)
     D difflg          s              1
     D diff1           s                   like(lwqalc)
     D diff2           s                   like(lwqalc)
     D diff3           s                   like(lwqalc)
     D diflft          s                   like(lwqpck)
     D difpck          s                   like(lwqpck)
     D difwgt          s                   like(lwswgt)
     D dscln           s             80
FDIaAD fditrn          s                   like(lwtrn#)
FDIaAD fdicub          s                   like(@pcube)
FDIaAD fdipcs          s                   like(@ppcs)
FDIaAD fdiwgt          s                   like(@pswgt)
FDIaAD fdiwdp          s                   like(lwwhdp)
     D first           s              1
     D flgpck          s              1
     D flgtrk          s              1
     D forevr          s              1
SLB AD hsseq#          s              5  0
SLB AD hsseqa          s              5
     D kycode          s                   like(opzcod)
     D kydflt          s                   like(stdflt)
     D kylbl#          s                   like(lwlbl#)
     D kyltyp          s                   like(lwtype)
     D kyndte          s                   like(osndte)
     D kyntim          s                   like(osntim)
     D kyord           s                   like(osord)
     D kyplid          s                   like(psplid)
     D kyprty          s                   like(osprty)
     D kystat          s                   like(osstat)
     D kytype          s                   like(pstype)
     D kyuser          s                   like(osuser)
     D kyzone          s                   like(opzzon)
520dAD kyzone2         s                   like(opzzon)
520dAD parentzone      s                   like(zhpzon)
730eDD*lf              s              1
730eMD pltsumLF        s              1
     D lslcto          s                   like(slctor)
     D lsrte           s                   like(lwrte)
     D lstcmp          s                   like(pscomp)
     D lstcol          s              1  0
     D lstdev          s                   like($dev)
     D lstfrm          s                   like($form)
     D lstitm          s                   like(lwitem)
     D lstmlt          s              3  0
     D lsttrn          s              7  0
     D lstwdp          s                   like(lwwhdp)
     D lstwhs          s                   like($whse)
     D lstzon          s                   like(psszon)
     D lzone           s                   like(psszon)
     D newpk2          s              5  0
     D nwfcub          s                   like(difcub)
     D nwfpck          s                   like(difpck)
FDIaAD pass            s              3  0
FDIaAD passes          s              3  0
FDIaAD pass2First      s               n
     D nwfwgt          s                   like(difwgt)
     D obflag          s              1
     D ocode           s              8
     D opened          s              1
     D pckall          s              1
     D pcount          s              3  0
     D phase           s              1  0
     D picked          s              5  0
530aAD plpos1          s              1  0
     D pltpcs          s              5  0
     D prflag          s              1
     D r               s              3  0
     D rplflg          s              1
700aAD sav_trlr        s                   like(lhtrlr)
700aAD sav_strd        s                   like(lhstrd)
700aAD sav_strt        s                   like(lhstrt)
     D slctor          s                   like(stuser)
     D svfcub          s                   like(difcub)
     D svfpck          s                   like(difpck)
     D svfwgt          s                   like(difwgt)
     D svqty2          s              5  0
     D svcomp          s                   like(pscomp)
     D svfrst          s              1
     D svgen           s                   like(psgen)
     D svszon          s                   like(psszon)
     D svtype          s                   like(pstype)
     D svtzon          s                   like(pstzon)
     D s2bcnt          s                   like(psbcnt)
     D s2col           s                   like(pscol)
     D s2comp          s                   like(pscomp)
     D s2cube          s                   like(pscube)
     D s2flag          s                   like(psflag)
     D s2gen           s                   like(psgen)
     D s2lbl#          s                   like(pslbl#)
     D s2maxc          s                   like(psmaxc)
     D s2pal#          s                   like(pspal#)
     D s2pcs           s                   like(pspcs)
     D s2plid          s                   like(psplid)
     D s2pzon          s                   like(pspzon)
     D s2row           s                   like(psrow)
     D s2rtid          s                   like(psrtid)
     D s2stp1          s                   like(psstp1)
     D s2stp2          s                   like(psstp2)
     D s2swgt          s                   like(psswgt)
     D s2szon          s                   like(psszon)
     D s2trn#          s                   like(pstrn#)
     D s2truk          s                   like(pstruk)
     D s2type          s                   like(pstype)
     D s2tzon          s                   like(pstzon)
     D s2unld          s                   like(psunld)
     D s2whse          s                   like(pswhse)
     D temp30          s             30
     D today           s              8  0
     D trerr           s              1
     D trkey           s             10
     D trnbr           s              4
     D trnqty          s              7  0
     D trntyp          s              8
     D trsq10          s              5  0
     D trsq40          s              5  0
     D trsq50          s              5  0
     D trsubr          s              6
     D ttlcub          s                   like(@pcube)
     D ttlpcs          s                   like(@ppcs)
     D ttlwgt          s                   like(@pswgt)
720cAd tbEnhanced      s               n
720cAd tbPalletType    s              1
720cAd tbType          s              1
720cAd tbWhse          s              3  0
     D uxflag          s              1
730eDD*x               s              3  0
730eDD*y               s              3  0
     D z               s              3  0
     D zone            s                   like(psszon)
530 AD $ptmpl          s             10
640cAD TranUsedCount   s              5  0
650bAD sidebysideflag  s              1
730aAD totalCount      s              5  0
730aAD bulkCount       s              5  0
730iAD pNextLbl#       s             11  0
730iAd nextLbl#        s                   like(lblbl#)
730iAD pNextTrn#       s             11  0
730iAd nextTrn#        s                   like(lbtrn#)
730iAd pttrn#          s                   like(lbtrn#)

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

730aA /copy qcopysrc,c#stdsql

720aA*----------------------------------------------------------------
720aA*  Pallet id data structure
720aA*
720aA*    DSPLID  -  Pallet id.
720aA*    DSPLXX  -  Unused.
720aA*    DSPLGN  -  Generation.
720aA*    DSPLRW  -  Pallet row.
720aA*    DSPLCL  -  Pallet column.
720aA*    DSPLSQ  -  Sequence number.
720aA*               Equal to zero     - Only one pallet in this position.
720aA*               Greater than zero - Multiple pallets in this position.
720aA*
720aA*
720aAD pltid           ds
720aAD  dsplid                 1      7  0 inz(0)
720aAD  dsplxx                 1      2  0
720aAD  dsplgn                 3      3  0
720aAD  dsplrw                 4      5  0
720aAD  dsplcl                 6      6  0
720aAD  dsplsq                 7      7  0

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

720cAd/copy qcopysrc,p.gettbtyp
730eAd/copy qcopysrc,p.umworklb
730eAd/copy qcopysrc,p.umlabel
730iA /copy qcopysrc,p.pirlbl#w
730iA /copy qcopysrc,p.pirtrn#w

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PBAT   Batch number
     *      $PWHSE  Warehouse
     *      $POTYP  Order type
     *      $PRTID  Route
     *      $PRTID  Route id
     *      $PTRUK  Truck
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pbat             7 0
     C                   parm                    $pwhse            3 0
     C                   parm                    $potyp            1
     C                   parm                    $prte             5
     C                   parm                    $prtid            5
     C                   parm                    $ptruk           10
USFqAC                   parm                    $pcmd2            8
     *
USFnAC     or630pw       plist
USFnAC                   parm                    $pbat
USFnAC                   parm                    $pwhse
USFnAC                   parm                    $potyp
USFnAC                   parm                    $prte
USFnAC                   parm                    $prtid
USFnAC                   parm                    $ptruk
USFnAC                   parm                    $pcmd2            8
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      prflag = *off
     *
     *  Work with single work assignment picks.
     *
USFoAC                   if        client = usfcrp
USFnAC                   call      @sw           or630pw
USFoAC                   endif
415 A*
415 A* Open printer
415 A*
415 AC                   exsr      opnprt
     *
     * USF has a modified main line
     *
      **            **   select
710fA **            **   when      client = usfcrp
     *  Work with bulk picks first.
     *
JORbAC                   if        client <> Jordanos
GMMdAC                             and client <> MenuMaker
710bAC                   exsr      pick1
710bA*
710bA*  Perform 2 phase process
710bA*   Phase 1 process all Gen 2+ Picks
710dM*   Phase 2 process all Gen 1 w/unload <= 70
710eM*   Phase 3 process all Gen 1 w/unload > 70 and Tran=0.
710bA*
710bAC                   eval      phase = *zeros
710bAC                   dow       forevr = forevr
710bA*
710bAC                   add       1             phase
710fAC                   select
710fD **           **    when      client = usfcrp
710fAC                   when      phase > 2
710fAC                   leave
710fAC                   other
710eMC                   if        phase > 3
710bAC                   leave
710bAC                   endif
710fAC                   endsl
     *
     *  Now work with normal picks.
     *
710bAC                   exsr      pick2
     *
     *  Write out last transaction.
     *
     C                   if        curtrn <> 0
     C                   exsr      wrttrn
     *  Write selector for RF will call
     C                   if        $potyp = 'W'  and
     C                             prodt = '*RF     '  and
     C                             oprfwc = 'Y'
     C                   eval      lslcto = slctor
     C                   eval      lzone = zone
     C                   exsr      wrtsct
     C                   exsr      sndusr
     C                   endif
710cAC                   eval      curtrn = 0
     C                   endif
     *
710bAC                   enddo
JORbAC                   endif
     *
     *  Work with bulk picks first.
     *
     C                   eval      kytype = 'B'
     C     keyps3        setll     pltsum3
     C                   dow       forevr = forevr
     C     keyps3        reade     pltsum3                                79
     C                   if        *in79
     C                   leave
     C                   endif
     *
640aA*  Skip record if transaction number has already been posted.
640aA*  This can occur if a double read has happened because of a
640aA*  shared access path between PLTSUM3T & PLTSUM3.
640aA*
640aAC                   if        pstrn# <> 0
640aAC                   iter
640aAC                   endif
640aA*
406 AC                   eval      kyplid = psplid
410 A*  Get zone selector for RF will call
410 AC                   if        $potyp = 'W'  and
410  C                             prodt = '*RF     '  and
410bAC                             oprfwc = 'Y'
410 AC                   exsr      getsct
410 AC                   endif
     C                   exsr      pickb
     *
     C                   enddo
     *
     *  Now work with normal picks.
     *
404 AC                   eval      difflg = *off
720cDC**                 eval      kytype = 'O'
720cMC                   eval      kytype = tbPalletType
     C                   eval      pcount = 0
     C                   eval      curtrn = 0
     C                   eval      curpal = 0
650bAC                   eval      sidebysideflag = 'N'
     C                   move      *hival        lstcmp
     C                   move      *hival        lstzon
USF AC                   if        client = usfcrp
SLB AC                             or client = Silberman
SGCdAC                             or client = SGC
SOF AC                             or client = Sofofoods
YHTaAC                             or client = YHata
FPRaAC                             or client = FoodPro
GMMcAC                             or client = MenuMaker
JOR AC                             or client = Jordanos
USF AC                   eval      lsttrn = -(1)
USF AC                   endif
     C     keyps3        setll     pltsum3
     C                   dow       forevr = forevr
     C     keyps3        reade     pltsum3                                79
     C                   if        *in79
     C                   leave
     C                   endif
640aA*
640aA*  Skip record if transaction number has already been posted.
640aA*  This can occur if a double read has happened because of a
640aA*  shared access path between PLTSUM3T & PLTSUM3.
640aA*
640aAC                   if        pstrn# <> 0
640aAC                   iter
640aAC                   endif
     *
     *    Loop if nothing on pallet.
     *
     C                   if        pspcs = 0
     C                   iter
     C                   endif
416cA*
416cA*    Loop if pallet only contains bulk picks.
416cA*
640bAC                   eval      obflag = *off
WSTbAC                   if        client <> westside
TPCaAC                             and client <> tpc
640bAC                             and psgen = 1
416cAC                   exsr      chk4ob
416cAC                   if        obflag = *on
416cAC                   iter
416cAC                   endif
WSTbAC                   endif
406 A*
406 AC                   eval      kyplid = psplid
     *
     *    Get picking options for zone.
     *
     C                   if        psszon <> lstzon
     C                   eval      kyzone = psszon
     C                   exsr      getopt
710 A*
710 A*  Slot zone changed and Tran Assign Method chg'd to By Column,
710 A*  force last transaction processed to be written out.
710 AC                   if            oplbl = 'S'
710 AC                             and curtrn <> 0
710 AC                   exsr      wrttrn
730cAc                   eval      curtrn=0
710 AC                   endif
710 A*
     C                   eval      lstzon = psszon
     C                   eval      pcount = 0
410 A*  Get zone selector for RF will call
410 AC                   if        $potyp = 'W'  and
410 AC                             prodt = '*RF     '  and
410bAC                             oprfwc = 'Y'
410 AC                   exsr      getsct
410 AC                   endif
     C                   endif
WSTaA*
WSTaA*    Skip gen 1 records for side by side processing.
WSTaA*
650aAC                   if        oplbl = 'S'
WSTaAC                             and psgen = 1
650bAC                   eval      sidebysideflag = 'S'
WSTaAC                   iter
WSTaAC                   endif
     *
     *    Increment pallet count.
     *
     C                   if        pcount >= opfpal
     C                   eval      pcount = 1
     C                   else
     C                   add       1             pcount
     C                   endif
650aD*
650aD*    For Side by Side, start new tran when column changes.
650aD*
650aDC                   if        oplbl = 'S' and
650aDC                             lstcol <> pscol
650aDC                   eval      pcount = 1
650aDC                   eval      lstcol = pscol
650aDC                   endif
     *
     *    Get transaction number for pallet.
     *
     C                   if        pstrn# <> 0
     C                   eval      trntyp = '*EXIST  '
     C                   eval      curtrn = pstrn#
     C                   else
     C                   if        pcount = 1
     C                   eval      trntyp = '*NEW    '
     C                   exsr      newtrn
     C                   endif
     C                   endif
SLB A*
SLB A*    Start IDS Seq# over for each tran.
SLB A*
SLB AC                   if        curtrn <> lsttrn  and
YHTaMC                             (Client = Silberman
JOR AC                             or client = Jordanos
SGCdAC                             or client = SGC
YHTaAC                             or Client = YHata
FPRaAC                             or Client = FoodPro
GMMcAC                             or client = MenuMaker
SOF AC                             or Client = Sofofoods)
SLB AC                   eval      lsttrn = curtrn
SLB AC                   eval      hsseq# = 0
SLB AC                   endif
USF A*
USF A*    Start USF Seq# over for each tran.
USF A*
USF AC                   if        client = usfcrp
USF A*
USF AC                   if        curtrn <> lsttrn
USF AC                   eval      lsttrn = curtrn
USF AC                   movel     $prte         usfrte
USFbAC                   eval      usffil = *zeros
USF A*    Force Group to W when processing Will-Call orders.
USF AC                   if        $potyp = 'W'
USF AC                   eval      usfgrp = 'W'
USF AC                   else
USFcMC                   eval      usfgrp = '@'
USF AC                   endif
USF AC                   add       1             usfbat
USF AC                   eval      usfseq = 0
USF AC                   endif
USF A*
USF AC                   endif
     *
     *    Update pallet with transaction number.
     *
     C                   eval      pstrn# = curtrn
     C                   update    psrec
     *
     *    Pick items for pallet.
     *
     C                   exsr      pick
     *
     C                   enddo
WSTaA*
WSTaA*  For Side by Side, assign tran #'s to gen 1 records.
WSTaA*
650bAC                   if        sidebysideflag = 'S'
WSTaAC                   exsr      wsttrn
WSTaAC                   endif
     *
     *  Write out last transaction.
     *
     C                   if        curtrn <> 0
     C                   exsr      wrttrn
410 A*  Write selector for RF will call
410 AC                   if        $potyp = 'W'  and
410 AC                             prodt = '*RF     '  and
410bAC                             oprfwc = 'Y'
410 AC                   eval      lslcto = slctor
410 AC                   eval      lzone = zone
410 AC                   exsr      wrtsct
410 AC                   exsr      sndusr
410 AC                   endif
     C                   endif
404 A*
404 A*    Update files with any allocated vs. picked differences.
404 A*
404 AC                   if        difflg = *on
404 AC                   exsr      upddif
404 AC                   endif
     *
530cA*    Update loader module files.
650cA*    Only if client is using loader module.
650cAC                   if        oprloa = 'Y'
     *
VIPbA*    VIP will not process Will Call orders thru LOADER.
SGCaA*    SGC will not process Will Call orders thru LOADER.
ADFaA*    ADF will not process Will Call orders thru LOADER.
DRYbA*    DRY will not process Will Call orders thru LOADER.
VIPbAC                   select
VIPbAC                   when      client = vip
SGCaAC                             or client = sgc
ADFaAC                             or client = AandDFoods
DRYbAC                             or client = Dairyland
VIPbAC                   if        $potyp <> 'W'
VIPbAC                   exsr      createLoader
VIPbAC                   endif
CBIfA*    CBI will not process certain Will Call orders thru LOADER.
CBIfAC                   when      client = Cheney
CBIfAC                   if        $potyp = 'W'  and
CBIfAC                             $ptruk <> 'BREAKERS'  and
CBIfAC                             $ptruk <> 'ADD-ONS '
CBIfAC                   else
CBIfAC                   exsr      createLoader
CBIfAC                   endif
VIPbAC                   other
530cAC                   exsr      createLoader
VIPbAC                   endsl
     *
650cAC                   endif
     *
     *    Copy records from WORKLBL to LABEL file.
     *
     C                   exsr      lw2lb
     *
     * Close up shop and return home.
     *
     C                   if        prflag = *on
     C                   write     foot1
     C                   endif
413aA*
413aA*  Write out completion message.
413aA*
413aAC                   if        trerr = *on
413aAC                   eval      trnbr = 'TR16'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'MAINLN  '    trsr50
413aAC                   exsr      zztrck
413aAC                   else
413aAC                   eval      trnbr = 'TR15'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'MAINLN  '    trsr50
413aAC                   exsr      zztrck
413aAC                   endif
413aA*
413aA*  Write out tracking record, force out contents of array.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'EXIT    '    trsubr
413aAC                   eval      r = 32
413aAC                   exsr      zztrck
413aA*
413aA*    Write out tracking record *PCK001.
413aA*
413aAC                   eval      trcode = '*PCK001 '
413aAC                   exsr      zztrck
413aA*
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
500 A*
500 A* Get client id.
500 A*
500 AC                   call      @getcl
500 AC                   parm                    client           10
CWDbAC                   parm                    clientloc        10
720cAc*
720cAc*   Determine if using TruckBUilder Enhanced
720cAc*
720cA /free
720cA      tbWhse = $pwhse;
720cA      GetTBType(tbWhse: $prtid: tbType);
720cA      if tbType = 'E';
720cA        tbEnhanced = *on;
720cA        tbPalletType = 'P';
720cA      else;
720cA        tbEnhanced = *off;
720cA        tbPalletType = 'O';
720cA      endif;
720cA /end-free
500 A*
413aA*
413aA*  Initialize tracking key.
413aA*
413aAC                   eval      trwhse = $pwhse
413aAC                   movel(p)  #prog         trpgm
413aAC                   eval      trjbnr = #jobn
413aAC                   eval      $cvcmd = '*MDYCMD '
730iMC                   move      #jobdate      $cvd6i
413aAC                   eval      $cvd8o = *zeros
413aAC                   call      @cvtdt
413aAC                   parm                    $cvtdt
413aAC                   eval      trjbdt = $cvd8o
730iMC                   eval      trjbtm = #jobtime
413aAC                   eval      trdev = #job
413aAC                   eval      truser = #user
413aAC                   eval      trtruk = $ptruk
413aAC                   eval      trrte = $prte
413aAC                   eval      trrtid = $prtid
413aAC                   eval      trpbat = $pbat
413aAC                   eval      r = *zeros
413aAC                   eval      trsubr = *blanks
413aAC                   eval      trrfld = *blanks
413aAC                   eval      trsq10 = *zeros
413aAC                   eval      trsq40 = *zeros
413aAC                   eval      trsq50 = *zeros
413aAC                   eval      trnbr = *blanks
413aAC                   eval      cvt5a = *blanks
413aAC                   eval      cvt8a = *blanks
413aAC                   eval      trkey = *blanks
413aAC                   eval      trerr = *off
413aAC                   eval      flgpck = *off
413aAC                   eval      flgtrk = *off
USF A*
USFdAC                   if        client = usfcrp
USFdAC                   eval      usfbat = *zeros
USFdAC                   eval      usfasq = *zeros
USFdAC                   eval      usfseq = *zeros
USFcAC                   eval      hldgrp = '@'
USFdAC                   endif
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     '*INZSR  '    trsubr
413aAC                   exsr      zztrck
     C                   eval      forevr = *off
     *
404 A*  Define key for CROSSDK1 file.
     *
404 AC     keycd1        klist
404 AC                   kfld                    lwwhse
404 AC                   kfld                    lword
404 AC                   kfld                    lwseq
USFeA*
USFeA*  Define partial key for WORKLBLU file.
USFeA*
USFeAC     kylbus        klist
USFeAC                   kfld                    $pwhse
USFeAC                   kfld                    $prtid
USFeAC                   kfld                    usfglb
     *
     *  Define partial key for WORKLBL5 file.
     *
     C     keylw         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
     *  Define partial key for WORKLBL5 file.
     *
     C     keylw5        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
406 MC                   kfld                    kyplid
404 A*
404 A*  Define partial key for WORKLBL7 file.
404 A*
404 AC     keylw7        klist
404 AC                   kfld                    $pwhse
404 AC                   kfld                    $prtid
404 AC                   kfld                    kylbl#
     *
     *  Define partial key for PLTSUM3 file.
     *
     C     keyps3        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kytype
404 A*
404 A*  Define key for PLTSUM4 file.
404 A*
404 AC     keyps4        klist
404 AC                   kfld                    lwtrn#
710dA*
710dA*  Define partial key for PLTSUM5 file.
710dA*
710dAC     keyps5        klist
710dAC                   kfld                    $pwhse
710dAC                   kfld                    $prtid
710dAC                   kfld                    svcomp
710dAC                   kfld                    svtzon
710dAC                   kfld                    svgen
710dAC                   kfld                    svszon
710dAC                   kfld                    svtype
404 A*
404 A*  Define key for PLTSTP file.
404 A*
404 AC     keypss        klist
404 AC                   kfld                    $pwhse
404 AC                   kfld                    $prtid
404 AC                   kfld                    psplid
404 AC                   kfld                    psrow
404 AC                   kfld                    pscol
404 AC                   kfld                    lwstop
404 AC                   kfld                    psbcnt
416cA*
416cA*  Define partial key for PLTSTP1 file.
416cA*
416cAC     keyss1        klist
416cAC                   kfld                    $pwhse
416cAC                   kfld                    $prtid
416cAC                   kfld                    psplid
     *
410a *  Define partial key for options file.
     *
410a C     keyop         klist
410a C                   kfld                    $pwhse
410a C                   kfld                    opcode
     *
     *  Define partial key for options file.
     *
     C     keyopz        klist
     C                   kfld                    kycode
     C                   kfld                    $pwhse
530 MC                   kfld                    $ptmpl
     C                   kfld                    kyzone
520dA*
520dAC     keyopz2       klist
520dAC                   kfld                    kycode
520dAC                   kfld                    $pwhse
530 MC                   kfld                    $ptmpl
520dAC                   kfld                    kyzone2
414cA*
414cA*     OPTIONS
414cA*
414cAC     opkey         klist
414cAC                   kfld                    $pwhse
414cAC                   kfld                    ocode
414cA*
414cA*     EXTENDED ITEM DESCRIPTION
414cA*
414cAC     idkey         klist
414cAC                   kfld                    $pwhse
414cAC                   kfld                    ititem
     *
     *
     *  Define key for SLOT2 file.
     *
     C     keysl2        klist
     C                   kfld                    $pwhse
     C                   kfld                    lwwhdp
     C                   kfld                    lwdisp
     *
     *  Define key for PIRITEM file.
     *
     C     keyit         klist
     C                   kfld                    $pwhse
408 MC                   kfld                    lwitem
     *
410 A*  Define key for PIRSLCT1 file.
410 A*
410 AC     keysct        klist
410 AC                   kfld                    $pwhse
410 AC                   kfld                    pstruk
410 AC                   kfld                    psszon
     *
410 A*  Define key for ORDH file.
410 A*
410 AC     keyodh        klist
410 AC                   kfld                    $pwhse
410 AC                   kfld                    lword
     *
520 A*  Define LDRHDR file key.
     *
520 AC     lhdrky        klist
520 AC                   kfld                    $pwhse
520 AC                   kfld                    $prte
530dAC                   kfld                    $prtid
     *
700aA*  Define LDRHDR file key.
700aA*
700aAC     lhdrky1       klist
700aAC                   kfld                    $pwhse
700aAC                   kfld                    $prte
     *
520 A*  Define LDRDETL2 file partial key.
     *
520 AC     ldtl2k        klist
520 AC                   kfld                    $pwhse
520 AC                   kfld                    $prte
520 AC                   kfld                    psplid
     *
520 A*  Define LDRDETL file partial key.
     *
520 AC     ldtlky        klist
520 AC                   kfld                    $pwhse
520 AC                   kfld                    $prte
520 AC                   kfld                    $prtid
520 AC                   kfld                    psplid
     *
410 A*  Define key for ORDSLCT  file.
410 A*
410 AC     kyosct        klist
410 AC                   kfld                    $pwhse
410 AC                   kfld                    kyuser
410 AC                   kfld                    kystat
410 AC                   kfld                    kyprty
410 AC                   kfld                    kyndte
410 AC                   kfld                    kyntim
410 AC                   kfld                    kyord
520dA*
520dA*  Define  key for ZONEH file.
520dA*
520dAC     keyzh         klist
     C                   kfld                    $pwhse
530 MC                   kfld                    $ptmpl
     C                   kfld                    kyzone2
530 A*
530 A*  Define key for TRUCKH file.
530 A*
530 AC     keyth         klist
530 AC                   kfld                    $pwhse
530 AC                   kfld                    $ptruk
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
410 AC     *dtaara       define    product       prodt             8
410 A*
410 A*  Get product level from data area.
410 A*
410 AC                   in        prodt
     *
     *  Create report heading.
413bA*
413bA*    Start with batch number ...
413bA*
413cAC                   time                    time
413bAC                   move      $pbat         temp30
413bAC                   call      'ADJUST'
413bAC                   parm      '*LEFT   '    $acmd             8
413bAC                   parm                    temp30
413bAC     'BATCH:'      cat       temp30:1      hedln2
     *
     *    Then add warehouse ...
     *
413bAC     hedln2        cat       'WARE':2      hedln2
413bAC     hedln2        cat       'HOUSE:':0    hedln2
     C                   eval      temp30 = *blanks
     C                   move      $pwhse        temp30
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $acmd
     C                   parm                    temp30
     C     hedln2        cat       temp30:1      hedln2
     *
     *    Finish with route.
     *
     C     hedln2        cat       'ROUTE:':2    hedln2
     C     hedln2        cat       $prte:1       hedln2
     *
     *    Center it so it will look pretty.
     *
     C                   call      'CENTER'
     C                   parm                    hedln2
     C                   parm      60            $clen             3 0
530 A*
530 A* Get Zone Template Code if Template type is T=Truck
530 A*
530 AC     keyth         chain     truckh
530 AC                   if        %found(truckh)
530 AC                             and thtype = 'T'
530 AC                   eval      $ptmpl =  thztmp
530 AC                   else
530 AC                   eval      $ptmpl =  $ptruk
530 AC                   endif
510dA*
510dA*   Get *RUNNER options record.
510dA*
510dAC                   eval      opcode = '*RUNNER '
510dAC     keyop         chain     options                            79
510dAC                   eval      opdtar = opdata
510dAC                   if        *in79
510dAC                   eval      opcrtm = 'N'
510dAC                   eval      opmrgf = 'N'
510dAC                   eval      opuplr = 'N'
510dAC                   endif
     *
ISYa *   Force option "Create manual runner entries shorts/out" to
     *       always be set to "N" so OUT labels will print
ISYaAC                   if        client = isupply
DRYaAC                             or client = Dairyland
EFCaAC                             or client = Eastland
BIRbAC                             or client = Birite
CWDbMC                             or client = Cashwa
CWDcAC                             and clientloc = CashwaAberdeen
JORaAC                             or client = Jordanos
SVLbAC                             or client = Saval
PFCaAC                             or client = Presto
WILaAC                             or client = WillFoods
JSLaAC                             or client = JSilvert
SBRaAC                             or client = Sbertram
PFCaAC                             or client = Presto
ACCaAC                             or client = ACC
SGCbAC                             or client = SGC
HMW AC                             or client = HMWagner
FPR AC                             or client = FoodPro
CBIaAC                             or client = Cheney
SOFbAC                             or client = Sofofoods
CFI AC                             or client = Colony
ADF AC                             or client = AandDFoods
MQSaAC                             or client = Marques
SWTaAC                             or client = SWT
GRC AC                             or client = Greco
VFIaAC                             or client = Vitco
BADaAC                             or client = BigApple
NOJ AC                             or client = Natalies
SFP AC                             or client = Seashore
ISYaAC                   eval      opcrtm = 'N'
ISYaAC                   endif
GLP A*
GLP A* AMP items shorted will have Runner flag on Delv Rt
GLP A* Not HERE, no label info to see if Import flag exists
GLP A*
     *
410a *   Get general picking options from options file.
     *
410a C                   eval      opcode = '*GENPICK'
410a C     keyop         chain     options                            79
414cAC                   eval      opdta1 = opdata
410a C                   if        *in79
410a C                   eval      operpt = 'Y'
410a C                   eval      opelbl = 'N'
414aAC                   move      '1'           opnrsc
500cMC                   eval      opjitr = '2'
413aAC                   eval      flgpck = *on
410a C                   endif
600aA
600aA* No longer allowing Letdowns. Adjust option accordingly.
600aA
600aAC                   select
600aAC                   when         opjitr = '1'
600aAC                   eval         opjitr = '2'
600aAC                   when         opjitr = '3'
600aAC                   eval         opjitr = '4'
600aAC                   endsl
DRKaA
DRKaA* Dierks - Temporarily force Letdowns only.
DRKaA
DRKaAC                   if           client = dierks
DRKaAC                   eval         opjitr = '1'
DRKaAC                   endif
     *
700aA*   Get *LOADER options record.
700aA*
700aAC                   eval      opcode = '*LOADER '
700aAC     keyop         chain     options
700aAC                   if        not %found(options)
700aAC                   eval      opaddo = 'N'
700aAC                   eval      opsttm = 0
700aAC                   eval      opentm = 0
700aAC                   else
700aAC                   eval      opdat6 = opdata
700aAC                   endif
     *
     *   Define variables.
     *
710dAC                   eval      svfrst = *off
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK002 '
413aAC                   exsr      zztrck
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  AVAIL   Calculate available quantities for slot.
     *
     C     avail         begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'AVAIL   '    trsubr
413aAC                   exsr      zztrck
     *
CBIbAC                   if        client = Cheney
CBIbA*  Call program to calculate Container/Cruise alloc/pick qty.
CBIbAC                   call      'CCQTY'
CBIbAC                   parm                    $pwhse
CBIbAC                   parm                    slitem
CBIbAC                   parm                    slstyp
CBIbAC                   parm                    slwhdp
CBIbAC                   parm                    slaisl
CBIbAC                   parm                    slpseq
CBIbAC                   parm                    slrlvl
CBIbAC                   parm                    slhand
CBIbAC                   parm                    $lpck1            5 0
CBIbAC                   parm                    $lpck2            3 0
CBIbAC                   parm                    $lpck3            3 0
CBIbAC                   parm                    $lalc1            5 0
CBIbAC                   parm                    $lalc2            3 0
CBIbAC                   parm                    $lalc3            3 0
CBIbAC                   endif
     *
     *  Call program to calculate availabe slot quantities.
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
CBIbAC                   if        client = Cheney
CBIbA*  Increase available by Container/cruise pick/allocate quantity.
CBIdAC                   add       $lpck1        stock1
CBIdAC                   add       $lpck2        stock2
CBIdAC                   add       $lpck3        stock3
CBIbAC     avail1        add       $lpck1        avail1
CBIbAC     avail2        add       $lpck2        avail2
CBIbAC     avail3        add       $lpck3        avail3
CBIbAC     avail1        add       $lalc1        avail1
CBIbAC     avail2        add       $lalc2        avail2
CBIbAC     avail3        add       $lalc3        avail3
CBIbAC                   endif
     *
411 AC                   if        avail1 < 0
411 AC                   eval      avail1 = 0
411 AC                   endif
411 AC                   if        avail2 < 0
411 AC                   eval      avail2 = 0
411 AC                   endif
411 AC                   if        avail3 < 0
411 AC                   eval      avail3 = 0
411 AC                   endif
     C                   endsr
416cA*----------------------------------------------------------------
416cA*
416cA*  CHK4OB  Check for only bulk picks on pallet.
416cA*
416cAC     chk4ob        begsr
     C                   eval      obflag = *off
730aA*
730aA*  In Enhanced, all P and B records will have psbcnt > 0.
730aA*  Therefore, call different routine to check for only bulk picks
730aA
730aAC                   if        tbEnhanced
730aAC                   exsr      chk4ob2
730aAC                   leavesr
730aAC                   endif
     *
     C                   eval      pltpcs = 0
     C                   eval      blkpcs = 0
     *
     C     keyss1        setll     pltstp1
     C                   dow       forevr = forevr
     *
     C                   read(n)   pltstp1                                79
     C                   if        *in79  or
     C                             psswhs <> pswhse  or
     C                             pssrid <> psrtid  or
     C                             pssrow <> psrow  or
     C                             psscol <> pscol
     C                   leave
     C                   endif
     *
     C                   if        pssbsq = 0
416fMC                   add       psspcs        pltpcs
     C                   else
     C                   add       psspcs        blkpcs
     C                   endif
     *
     C                   enddo
     *
416eMC                   if        blkpcs > 0  and
     C                             pltpcs = blkpcs
     C                   eval      obflag = *on
     C                   endif
     *
     C                   endsr
730aA*----------------------------------------------------------------
730aA*
730aA*  CHK4OB2 Check for only bulk picks on pallet for DD2
730aA*
730aAC     chk4ob2       begsr

      /free

        exec sql select count(*)
                  into :totalCount
                 from worklbl
                 where lwwhse = :$pwhse and lwrte = :$prtid and lwpal# = :psplid
                   and lwtype in ('O', 'M');

        if sqlstt <> sqlSuccess;
          leavesr;
        endif;

        exec sql select count(*)
                  into :bulkCount
                 from worklbl a
                 left outer join worklbl b
                   on b.lwwhse=a.lwwhse and b.lwlbl#=a.lwctr#
                 where a.lwwhse = :$pwhse and a.lwrte = :$prtid
                   and a.lwpal# = :psplid and a.lwtype ='M'
                   and a.lwctr# > 0 and b.lwtype = 'B';

        if sqlstt <> sqlSuccess;
          leavesr;
        endif;

        if bulkCount = totalCount;
          obflag = *on;
        endif;

      /end-free


     C                   endsr
     *----------------------------------------------------------------
530cA*
530cA*  CREATELOADER  Whip through PLTSUM and go create loader recs.
530cA*
530cAC     createLoader  begsr
     *
720cDC**                 eval      kytype = 'O'
720cMC                   eval      kytype = tbPalletType
     C     keyps3        setll     pltsum3
     C                   dow       forevr = forevr
     C     keyps3        reade     pltsum3                                79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *    Loop if nothing on pallet.
     *
     C                   if        pspcs = 0
     C                   iter
     C                   endif
710aA*
710aA*    Exclude pallets when all item have NOALC designation
710aA*
710aA /free
710aA   bypassloader = *off;
710aA   setll (pswhse: psrtid: psplid) worklbl6;
710aA   dow forevr = forevr;
710aA     reade (pswhse: psrtid: psplid) worklbl6;
710aA     if %eof(worklbl6);
710aA       bypassloader = *on;
710aA       leave;
710aA     endif;
710aA     // is this item NOALC designation?
710aA     chain (wl_lwwhse: wl_lwitem) piritem;
750aA     // if item not found DO NOT bypass loader
750aA     if not %found(piritem);
750aA       leave;
750aA     endif;
710aA     if %found(piritem);
710aA       if itdesg <> 'NOALC';
710aA         leave;
710aA       endif;
710aA       // Does this item also have category = Pallet
710aA       chain (wl_lwwhse: wl_lwitem) itemfld;
710aA       if %found(itemfld);
710aA         if ifcat <> 'PALLET';
710aA           leave;
710aA         endif;
710aA       endif;
710aA     endif;
710aA   enddo;
710aA /end-free
     *
     *    Update loader module files.
     *
710aAc                   if        BypassLoader = *off
     C                   exsr      loader
710aAC                   endif
     *
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETITM  Get item record.
     *
     C     getitm        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'GETITM  '    trsubr
413aAC                   exsr      zztrck
     *
     C                   if        lwitem <> lstitm
     C     keyit         chain     piritem                            78
     C                   if        *in78
411 AC                   eval      ittype = *blanks
     C                   eval      itumq2 = 0
     C                   eval      itumq3 = 0
413aAC                   eval      trnbr = 'TR05'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'GETITM  '    trsr50
413aAC                   exsr      zztrck
     C                   endif
414cAC                   exsr      zzxopt
414cAC                   eval      dscln = *blanks
414cAC                   if        uxflag = *off
414cAC                   movel     itdesc        dscln
414cAC                   else
414cAC                   movel     ixdsc1        dscln
414cAC                   move      ixdsc2        dscln
414cAC                   endif
411 AC                   eval      #bitem = lwitem
411 AC                   eval      #bityp = ittype
411 AC                   eval      #bdesc = itdesc
411 AC                   eval      #bpdsc = itpdsc
411 A*
411 A*     If Contract, Alias or SSB item
411 A*       Then get Base item.
411 A*
411 AC                   if        ittype = 'C'  or
411 AC                             ittype = 'A'  or
411 AC                             ittype = 'S'
417eMC                   call      @getsi
411 AC                   parm      itwhse        $gwhse            3 0
411 AC                   parm      ititem        $gitem           15
411 AC                   parm      ' '           #bitem           15
411 AC                   parm                    #bityp            1
411 AC                   parm                    #bdesc           30
411 AC                   parm                    #bpdsc           15
417eAC                   parm                    #srtn            10
417eAC                   parm                    #smsg            60
411 AC                   endif
     C                   eval      lstitm = lwitem
     C                   endif
     *
     C                   endsr

730iA*----------------------------------------------------------------
730iA*  GetNextLbl#    Get next label number
730iA*----------------------------------------------------------------
730iA
730iAC     getNextLbl#   begsr
      /free

         // Get next label number

         PirLbl#W($pwhse: pNextLbl#);

         // Make sure it isn't too large

         monitor;
           nextLbl# = pNextLbl#;
         on-error;
           nextLbl# = -9;
         endmon;

         // See if there was an error getting label number

         if nextLbl# <= 0;

           // Write message to BFCDEBUG

           bdvalues = 'Error getting lbl# '
                    + '(p' + %char(pNextLbl#) + '/' + %char(nextLbl#) + ') '
                    + 'for '
                    + 'Whse: ' + %char(lwwhse) + ', '
                    + 'Rtid: ' + %trimr(lwrte) + ', '
                    + 'Ord: ' + %char(lword) + ', '
                    + 'Seq: ' + %char(lwseq) + ', '
                    + 'Itm: ' + %trimr(lwitem);
           bdtype = '*ERROR';
           exsr wrtDebug;

           // Force divide by zero error to abnormally end program.

           nextLbl# = 0;
           pNextLbl# = pNextLbl# / nextLbl#;

         endif;

      /end-free
     C                   endsr

730iA*----------------------------------------------------------------
730iA*  GetNextTrn#    Get next tran number
730iA*----------------------------------------------------------------
730iA
730iAC     getNextTrn#   begsr
      /free

         // Get next label number

         PirTrn#W($pwhse: pNextTrn#);

         // Make sure it isn't too large

         monitor;
           nextTrn# = pNextTrn#;
         on-error;
           nextTrn# = -9;
         endmon;

         // See if there was an error getting label number

         if nextTrn# <= 0;

           // Write message to BFCDEBUG

           bdvalues = 'Error getting lbl# '
                    + '(p' + %char(pNextTrn#) + '/' + %char(nextTrn#) + ') '
                    + 'for '
                    + 'Whse: ' + %char($pwhse) + ', '
                    + 'Rtid: ' + %trimr($prtid);
           bdtype = '*ERROR';
           exsr wrtDebug;

           // Force divide by zero error to abnormally end program.

           nextTrn# = 0;
           pNextTrn# = pNextTrn# / nextTrn#;

         endif;

      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETOPT  Get picking options for zone.
     *
     C     getopt        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'GETOPT  '    trsubr
413aAC                   exsr      zztrck
     *
     C                   eval      kycode = '*PICK   '
     C     keyopz        chain     optionz                            79
520dAC                   if        %found(optionz)
520dAC                   eval      opzdta1 = opzdta
520dAC                   else
730dAc                   eval      oplbl='N'
     C                   eval      opfpal = 1
     C                   eval      opfcub = 64
     C                   eval      opfstp = 99
     C                   eval      oppbld = *on
USFgAC                   eval      opgcde = *off
413aAC                   eval      trnbr = 'TR06'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'GETOPT  '    trsr50
413aAC                   exsr      zztrck
     C                   endif
     *
     C                   endsr
520dA*----------------------------------------------------------------
520dA*
520dA*  GETOPT2 Get picking options for zone.
520dA*
520dAC     getopt2       begsr
     *
     C                   eval      kyzone2 = %trim(lwwhdp) +
     C                                       %trim(lwstyp)
     *
     C                   eval      kycode = '*PICK   '
     C     keyopz2       chain     optionz
     C                   if        %found(optionz)
     C                   eval      opzdta2 = opzdta
     C                   else
     C                   eval      xppkup = ' '
     C                   eval      xpspal = ' '
     C                   endif
     *
     C                   eval      parentzone = *blanks
     C     keyzh         chain     zoneh
     C                   if        %found(zoneh)
     C                             and xppkup = 'L'
     C                             and xpspal = 'Y'
     C                   eval      parentzone = zhpzon
     C                   endif
     *
     C                   endsr
410 A*----------------------------------------------------------------
410 A*
410 A*  GETSCT  Get selector for zone.
410 A*
410 AC     getsct        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'GETSCT  '    trsubr
413aAC                   exsr      zztrck
410 A*
410 AC                   eval      kydflt = 'Y'
410 AC                   eval      lslcto = slctor
410 AC                   eval      lzone = zone
410 AC     keysct        setll     pirslct1
410 AC     nxtsct        tag
410 AC     keysct        reade     pirslct1                               79
410 AC                   if        not *in79
410 AC                   eval      slctor = stuser
410 AC                   eval      zone = stzone
410 AC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
520 A*  LOADER  Create truck loader records.
     *
520 AC     loader        begsr
     *
530aA*  Only write or update loader header and detail recs for
     *  pallets whose pallet id ends in 0.
     *
530aAC                   move      psplid        plpos1
750 A*       Bypass Std TB pallet if p1pos1 <> zero.
530aAC                   if        plpos1 <> 0
750 AC                             and TbEnhanced = '0'
750 A*
750 A*       Bypass TB Prime pallet if p1pos1 is zero.
750 AC                             or plpos1 = 0
750 AC                             and TbEnhanced = '1'
750 A*
530aAC                   goto      endldr
530aAC                   endif
     *
700aA*  If auto define add-on routes is turned on and you find the
700aA*  same host route in LDRHDR then default this route's
700aA*  trailer and start date and time to the same as the one
700aA*  in loader header.
700aA*
700aAC                   eval      sav_trlr = *blanks
700aAC                   eval      sav_strd = 0
700aAC                   eval      sav_strt = 0
700aAC                   if        opaddo = 'Y'
700aAC     lhdrky1       setll     ldrhdr
700aAC     lhdrky1       reade     ldrhdr
700aAC                   if        not %eof
700aAC                   eval      sav_trlr = lhtrlr
700aAC                   eval      sav_strd = lhstrd
700aAC                   eval      sav_strt = lhstrt
700aAC                   endif
700aAC                   endif
     *
520 AC                   if        $potyp = 'W'
520 AC                   goto      brkrs
520 AC                   endif
     *
     *=======------ Truck Builder Pallet Info Starts Here -----=======
520 AC     lhdrky        chain     ldrhdr                             79
     *
530dAC                   if        *in79
520 AC                   clear                   lhrec
520 AC                   eval      lhwhse = $pwhse
520 AC                   eval      lhrte = $prte
520 AC                   eval      lhrtid = $prtid
520 AC                   eval      lhstat = *on
700aAC                   if        sav_trlr > ' '
700aAC                   eval      lhstat = '2'
700aAC                   endif
700aAC                   eval      lhtrlr = sav_trlr
700aAC                   eval      lhstrd = sav_strd
700aAC                   eval      lhstrt = sav_strt
     *
520 AC                   write     lhrec
520 AC                   endif
     *
     *  If parent Zone
520 AC                   if        pspzon <> *blanks
520 AC                   goto      endldr
520 AC                   endif
     *                                                    pallet
650cAC     ldtlky        chain     ldrdetl
650cAC                   if        %found
650cAC                   goto      endldr
650cAC                   endif
     *
650cMC                   clear                   lddrec
     *
520 AC                   eval      ldwhse = $pwhse
520 AC                   eval      ldrte = $prte
520 AC                   eval      ldplid = psplid
520 AC                   eval      ldrtid = $prtid
520 AC                   eval      ldtrkz = pstzon
520 AC                   eval      ldldsq = psunld
520 AC                   z-add     pscube        ldcube
520 AC                   eval      ldpcs = pspcs
520 AC                   eval      ldstp1 = psstp1
520 AC                   eval      ldstp2 = psstp2
     *
650cMC                   write     lddrec
     *
520 AC                   goto      endldr
     *
     *=======---- Breakers Pallet Info Loading Starts Here ----=======
520 AC     brkrs         tag
520 AC     lhdrky        chain     ldrhdr                             79
520 AC                   if        *in79
     *
520 AC                   eval      lhwhse = $pwhse
520 AC                   eval      lhrte = $prte
520 AC                   eval      lhrtid = $prtid
520 AC                   eval      lhstat = *on
700aAC                   if        sav_trlr > ' '
700aAC                   eval      lhstat = '2'
700aAC                   endif
700aAC                   eval      lhtrlr = sav_trlr
700aAC                   eval      lhstrd = sav_strd
700aAC                   eval      lhstrt = sav_strt
     *
520 AC                   write     lhrec
520 AC                   endif
     *
     *  If parent Zone
520 AC                   if        pspzon <> *blanks
520 AC                   goto      endldr
520 AC                   endif
     *
520 AC                   if        pspcs <> *zeros
     *                                                    not empty
650cAC     ldtlky        chain     ldrdetl
650cAC                   if        %found
650cAC                   goto      endldr
650cAC                   endif
     *
520 AC                   clear                   lddrec
     *
520 AC                   eval      ldwhse = $pwhse
520 AC                   eval      ldrte = $prte
520 AC                   eval      ldrtid = $prtid
     *
520 AC                   eval      ldplid = psplid
520 AC                   eval      ldtrkz = pstzon
520 AC                   eval      ldldsq = psunld
520 AC                   z-add     pscube        ldcube
520 AC                   eval      ldpcs = pspcs
520 AC                   eval      ldstp1 = psstp1
520 AC                   eval      ldstp2 = psstp2
     *
520 AC                   write     lddrec
520 AC                   endif
     *
520 AC     endldr        endsr
     *----------------------------------------------------------------
     *
     *  LW2LB   Work label record to normal label record.
     *
     C     lw2lb         begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'LW2LB   '    trsubr
413aAC                   exsr      zztrck
     *
     *  Loop through label records for route.
     *
     C     keylw         setll     worklbl5
     C                   dou       forevr <> forevr
     C     keylw         reade     worklbl5                               78
     C                   if        *in78
     C                   leave
     C                   endif
     *
     *     Copy fields.
     *
     C                   eval      lbwhse = lwwhse
     C                   eval      lbwhdp = lwwhdp
     C                   eval      lbseq = lwseq
     C                   eval      lbitem = lwitem
     C                   eval      lbpbat = lwpbat
     C                   eval      lbaisl = lwaisl
     C                   eval      lbloc = lwloc
     C                   eval      lbrlvl = lwrlvl
     C                   eval      lbhand = lwhand
     C                   eval      lbpseq = lwpseq
     C                   eval      lbstyp = lwstyp
     C                   eval      lbqryf = lwqryf
     C                   eval      lbdisp = lwdisp
     C                   eval      lbqavl = lwqavl
     C                   eval      lbwhs2 = lwwhs2
     C                   eval      lbwhd2 = lwwhd2
     C                   eval      lbasl2 = lwasl2
     C                   eval      lbloc2 = lwloc2
     C                   eval      lblvl2 = lwlvl2
     C                   eval      lbhnd2 = lwhnd2
     C                   eval      lbdsp2 = lwdsp2
     C                   eval      lbrte = lwrte
     C                   eval      lbstop = lwstop
     C                   eval      lbord = lword
     C                   eval      lbspcl = lwspcl
     C                   eval      lbpo = lwpo
     C                   eval      lbutyp = lwutyp
     C                   eval      lbucod = lwucod
     C                   eval      lbucub = lwucub
     C                   eval      lbcube = lwcube
     C                   eval      lbuwgt = lwuwgt
     C                   eval      lbswgt = lwswgt
     C                   eval      lbqalc = lwqalc
     C                   eval      lbqrmn = lwqrmn
     C                   eval      lbqpck = lwqpck
     C                   eval      lbtie = lwtie
     C                   eval      lbhigh = lwhigh
     C                   eval      lbgrp1 = lwgrp1
     C                   eval      lbgrp2 = lwgrp2
     C                   eval      lbtype = lwtype
     C                   eval      lblbl# = lwlbl#
     C                   eval      lbpal# = lwpal#
     C                   eval      lbtrn# = lwtrn#
     C                   eval      lbctr# = lwctr#
     C                   eval      lbstat = lwstat
     C                   eval      lbprty = lwprty
     C                   eval      lbsdte = lwsdte
     C                   eval      lbstim = lwstim
     C                   eval      lbrdte = lwrdte
     C                   eval      lbvrfy = lwvrfy
GLP A*
GLP A* AMP items shorted will have Runner flag on Delv Rt
GLP A* Get ORDDM field OMMSC1 by using label field values
GLP A* and get AMP Short Flag.
GLP A*
GLPaA /free
GLPaA    orddm1_amp = ' ';
GLPaA    setll (lwwhse: lword: lwseq: lwitem) orddm;
GLPaA    reade (lwwhse: lword: lwseq: lwitem) orddm;
GLPaA      if not %eof(orddm);
GLPaA      orddm1_amp = ommsc1;
GLPaA      endif;
GLPaA /end-free
     *
GLPa *   Force option "Create manual runner entries shorts/out" to
GLPa *       always be set to "N" so OUT labels will print
GLPa *       except set to "Y" when previous AMP order shorted item
GLPa *       and will be sent to Runner Module
GLPaAC                   if        client = greenleaf
GLPcDC*                            and ampdm4_ampfl = 'Y'
GLPcMC                   if        ampdm4_ampfl = 'Y'
GLPaAC                   eval      opcrtm = 'Y'
GLPaAC                   else
GLPaAC                   eval      opcrtm = 'N'
GLPaAC                   endif
GLPcAC                   endif
417bA*
417bA*     Set LBVRFY to '0' if nothing was picked.
417dA*         and LBSTAT to 'C'.
417bA*
417bAC                   if        lbqpck = 0  and
417bAC                             lbasl2 <> '***'  and
417bAC                             lbasl2 <> 'OUT'
417bAC                   eval      lbvrfy = *off
417dAC                   eval      lbstat = 'C'
417baC                   endif
510bA*
510bA*     Set LBVRFY to 'F' when processing OUT label.
510bA*
SVLbMC                   if           client = cityln and lbdisp=*blanks
SLVaAC                             or client <> saval
HALbAC                             and client <> halsey
FDIbAC                             and client <> Finkle
EI bAC                             and client <> EI
RYLaAC                             and client <> Royal
CSPaAC                             and client <> CoastalSunbelt
CLDbAC                             and client <> cityln
SLBbAC                             and client <> Silberman
PFCaAC                             and client <> Presto
GMMaAC                             and client <> MenuMaker
FSHaAC                             and client <> fischr
SOFaAC                             and client <> SOFO
PFCaAC                             and client <> Presto
MQSAAC                             and client <> Marques
ACCaAC                             and client <> ACC
510dA*     Runner options set to allow OUT's to be flagged.
510dAC                   if        opcrtm = 'Y'
510dA*
510dA*
510dA*     Flag label records that aren't Merge records.
510dAC                   if        opmrgf = 'N'  and
510dAC                             lbtype <> 'M'  or
510dA*     or Flag all label records.
510dAC                             opmrgf = 'Y'
510dA*
510bAC                   if        lbasl2 = 'OUT'
GLPaAC                             or client = greenleaf
GLPaAC                             and ampdm4_ampfl = 'Y'
510bAC                   eval      lbvrfy = 'F'
510bAC                   endif
SVLaAC                   endif
510dA*
510dAC                   endif
510dA*
510dAC                   endif
     *
     *     Create label record.
     *
     C                   write     lbrec
730eA
730eA*     Copy WORKLBLUM record to LABELUM
730eA
730eA /free
730eA
730eA  // Get WORKLBLUM record
730eA
730eA  monitor;
730eA    umWhse = lwwhse;
730eA    umworklbl('*GET': umRtnCode: umRtnMsg:
730eA              umWhse: lwlbl#:
730eA              umFlexPickFlag:
730eA              lwualq1: lwualu1: lwualq2: lwualu2: lwualq3: lwualu3);
730eA  on-error;
730eA    umRtnCode = '*ERROR';
730eA  endmon;
730eA
730eA  // Create LABELUM record
730eA
730eA  if umRtnCode = '*OK';
730eA    monitor;
730eA      umWhse = lbwhse;
730eA      umlabel('*ADD': umRtnCode: umRtnMsg:
730eA              umWhse: lblbl#:
730eA              umFlexPickFlag:
730eA              lwualq1: lwualu1: lwualq2: lwualu2: lwualq3: lwualu3);
730eA    on-error;
730eA    endmon;
730eA  endif;
730eA
730eA /end-free
730eA
     *
     *     Update status of work record.
     *
     C                   eval      lwstat = 'X'
     C                   eval      lwsdte = today
     C                   time                    lwstim
     C                   update    lwrec
     *
510bA*     Write records to RUNNER file.
     *
510dA*     Runner options set to allow OUT's to be flagged.
510dAC                   if        opcrtm = 'Y'
510dA*
510bA*     Flag label records that aren't Merge records.
510dAC                   if        opmrgf = 'N'  and
510dAC                             lbtype <> 'M'  or
510bA*     or Flag all label records.
510dAC                             opmrgf = 'Y'
510dA*
510bAC                   if        lbasl2 = 'OUT'
GLPaAC                             or client = greenleaf
GLPaAC                             and ampdm4_ampfl = 'Y'
SVLbMC                   if           client = cityln and lbdisp=*blanks
SVLaAC                             or client <> saval
HALaAC                             and client <> halsey
FDIbAC                             and client <> Finkle
EIb AC                             and client <> EI
RYLaAC                             and client <> Royal
CSPaAC                             and client <> CoastalSunbelt
CLDbAC                             and client <> cityln
SLBbAC                             and client <> Silberman
GMMaAC                             and client <> MenuMaker
FSHaAC                             and client <> fischr
SOF AC                             and client <> SOFO
PFCaAC                             and client <> Presto
MQSaAC                             and client <> Marques
ACCaAC                             and client <> ACC
GLPaAC                             or client = greenleaf
GLPaAC                             and ampdm4_ampfl = 'Y'
510bAC                   call      'RU385'
510bAC                   parm      '*ADD    '    $cmd
510bAC                   parm                    lbwhse
510bAC                   parm                    lbwhdp
510bAC                   parm                    lblbl#
510bAC                   parm                    lbtrn#
510bAC                   parm                    lbdisp
510bAC                   parm                    lbqalc
510cAC                   parm                    lbtype
SVLaAC                   endif
510bAC                   endif
510dA*
510dAC                   endif
510dA*
510dAC                   endif
     *
500eA*     Create Bulk Drop record for Bulk label.
500eAC                   if        lbtype = 'B'
TPCbAC                             and client <> tpc
500eA*     Convert date/time to datestamp.
500eAC                   call      'GETTS'
500eAC                   parm                    bdcrts
500eA*     Initialize other datestamp fields.
530bMC                   movel     tsinz         bddrps
500eA*
500eAC                   eval      bdwhse = lbwhse
500eAC                   eval      bdwhdp = lbwhdp
500eAC                   eval      bdlbl# = lblbl#
500eAC                   eval      bdstat = '1 '
500eAC                   eval      bduser = *blanks
500eAC                   eval      bdjob = *blanks
500eAC                   eval      bdjobn = *blanks
500eAC                   write     bdrec
500eAC                   endif
     *
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  NEWTRN   Get new transaction number.
     *
     C     newtrn        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'NEWTRN  '    trsubr
413aAC                   exsr      zztrck
     *
     *  Write out current transaction.
     *
     C                   if        curtrn <> 0
     C                   exsr      wrttrn
410 A*  Write selector for RF will call
410 AC                   if        $potyp = 'W'  and
410 AC                             prodt = '*RF     '  and
410bAC                             oprfwc = 'Y'
410 AC                   exsr      wrtsct
410 AC                   exsr      sndusr
410 AC                   endif
     C                   endif
     *
     *  Get new transaction number.
     *
730iDC**                 call      'PIRTRN#'
730iDC**                 parm                    curtrn
730iMC                   exsr      GetNextTrn#
730iMC                   eval      curtrn = nextTrn#
     *
     *  Inizialize transaction totals.
     *
     C                   eval      ttlcub = 0
     C                   eval      ttlwgt = 0
     C                   eval      ttlpcs = 0
     *
     C                   endsr
FDIaA*----------------------------------------------------------------
FDIaA*
FDIaA*  NEWTRNFDI   Get new transaction number for FDI special case
FDIaA*
FDIaAC     newtrnfdi     begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'NEWTRNFD'    trsubr
     C                   exsr      zztrck
     *
     *  Get new transaction number.
     *
730iDC**                 call      'PIRTRN#'
730iDC**                 parm                    fditrn
730iMC                   exsr      GetNextTrn#
730iMC                   eval      fditrn = nextTrn#
     *
     *  Inizialize transaction totals.
     *
     C                   eval      fdiwdp = lwwhdp
     C                   eval      fdicub = 0
     C                   eval      fdiwgt = 0
     C                   eval      fdipcs = 0
     *
     C                   endsr
415 A*----------------------------------------------------------------
415 A*
415 A*  OPNPRT  Open printer file.
415 A*
415 AC     opnprt        begsr
     *
     *   Get device and form type for department.
     *
     C                   if        $pwhse <> lstwhs
     C                   call      'GETRPT'
     C                   parm      '*DEVFORM'    $cmd              8
720bMC                   parm      'OR630PR'     $lrpt            10
     C                   parm      $pwhse        $whse             3 0
     C                   parm      ' '           $styp             1
     C                   parm      ' '           $whdp             5
     C                   parm                    $desc            50
     C                   parm                    $dev             10
     C                   parm                    $form            10
     C                   eval      lstwhs = $whse
     C                   endif
     *
     *   Open printer file for department.
     *
     C                   if        opened <> *on  or
     C                             $dev <> lstdev  or
     C                             $form <> lstfrm
     *
     *      If printer already open then close it.
     *
     C                   if        opened = *on
720bMC                   close     or630pr
     C                   endif
     *
     *      Override printer file.
     *
720bM*          OVRPRTF FILE(OR630PR) OUTQ(*DEV) DEV($dev)
     *                  FORMTYPE($form)
     *
     C                   movea     ovrprt(1)     a80
720bMC                   movea     $dev          a80(38)
720bMC                   movea     $form         a80(59)
     C                   movea     a80           qcmd
     *
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
     *
     *      Open printer file.
     *
720bMC                   open      or630pr
     C                   eval      opened = *on
     C                   eval      lstdev = $dev
     C                   eval      lstfrm = $form
     *
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PCKFIX   Pick fixed section item.
     *
     *    Note: There is a chance that there will not be enough stock
     *          in the slots to fulfill what was generally allocated.
     *          This would only occur if the ITEMQTY totals do not
     *          match the slot totals.  Also, now is the time for all
     *          good cartons to be broken down if necessary. For PIR
     *          items these checks were done during allocation.
     *
     C     pckfix        begsr
GLP A*
GLP A* AMP items shorted will have Runner flag on Delv Rt
GLP A* Get ORDDM field OMMSC1 by using label field values
GLP A* and get AMP Short Flag.
GLP A*
GLPbA /free
GLPbA    orddm1_amp = ' ';
GLPbA    setll (lwwhse: lword: lwseq: lwitem) orddm;
GLPbA    reade (lwwhse: lword: lwseq: lwitem) orddm;
GLPbA      if not %eof(orddm);
GLPbA      orddm1_amp = ommsc1;
GLPbA      endif;
GLPbA /end-free
520aAC                   eval      pckall = *off
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'PCKFIX  '    trsubr
413aAC                   exsr      zztrck
     *
411 AC                   eval      diff1 = 0
411 AC                   eval      diff2 = 0
411 AC                   eval      diff3 = 0
410aA*   Pick everything for exceptions.
410aA*
410aAC                   if        lwasl2 = 'OUT'  or
415aAC                             lwasl2 = '***'
410aAC                   eval      lwqpck = lwqalc
410aAC                   goto      updlbl
410aAC                   endif
415bA*
415bA*   Pick everything for host pick will call and updates slot.
415bA*
CLDaA*   City Line - Pick everything. Using JIT replenishments instead
CLDaA*
415bAC                   if        $potyp = 'W'  and
415bAC                             ophpwc = 'Y'  or
CLDaAC                             client = cityln
500aA*
500dD*   JIT Replenishment is not 1=Letdown created during Pick/Print.
500dD*          OPJITR    ORNE '1'
520aA*
520aAC                   eval      pckall = *on
500aA*
415bAC                   select
415bAC                   when      lwutyp = 'N'
415bAC                   eval      stock1 = lwqalc
415bAC                   when      lwutyp = '1'
415bAC                   z-add     lwqalc        stock2
415bAC                   when      lwutyp = '2'
415baC                   z-add     lwqalc        stock3
415bAC                   endsl
415bAC                   goto      updslt
415bAC                   endif
     *
     *
     *   Get quantities for pick slot.
     *
     C                   exsr      avail
     *
     *   Loop until pick slot has enough stock in it or we run out
     *     of reserve stock trying to do a replenishment.
     *
     C                   dou       forevr <> forevr
     *
     *      Breakdown carton if necessary.
     *
     C                   select
     *
     *        Breakdown 1 quantity.
     *
     C                   when      lwutyp = '1'
     C                   dow       lwqalc > stock2  and
     C                             stock1 > 0
     C                   exsr      getitm
     C                   if        itumq2 <= 0
     C                   leave
     C                   endif
     C                   eval      stock1 = stock1 - 1
     C                   add       itumq2        stock2
     C                   enddo
     *
     *        Breakdown 2 quantity.
     *
     C                   when      lwutyp = '2'
     C                   dow       lwqalc > stock3
     C                   if        stock1 <= 0  and
     C                             stock2 <= 0
     C                   leave
     C                   endif
     C                   exsr      getitm
     C                   if        itumq2 <= 0  or
     C                             itumq3 <= 0
     C                   leave
     C                   endif
     C                   if        stock2 > 0
     C                   eval      stock2 = stock2 - 1
     C                   add       itumq3        stock3
     C                   eval      slstk2 = slstk2 - 1
     C                   add       itumq3        slstk3
     C                   else
     C                   eval      stock1 = stock1 - 1
     C                   add       itumq2        stock2
     C                   eval      slstk1 = slstk1 - 1
     C                   add       itumq2        slstk2
     *
     C                   eval      stock2 = stock2 - 1
     C                   add       itumq3        stock3
     C                   eval      slstk2 = slstk2 - 1
     C                   add       itumq3        slstk3
     C                   endif
     *
     C                   enddo
     *
     C                   endsl
     *
     *      If we have enough stock then get out of loop.
     *
500dA*
500dA*   JIT Replenishment is not 1=Letdown, force qty to be picked.
500dAC                   if        opjitr <> '1'
520bAC                   eval      pckall = *on
500dAC                   select
500dAC                   when      lwutyp = 'N'
500dAC                   eval      stock1 = lwqalc
500dAC                   when      lwutyp = '1'
500dAC                   z-add     lwqalc        stock2
500dAC                   when      lwutyp = '2'
500daC                   z-add     lwqalc        stock3
500dAC                   endsl
500dAC                   goto      updslt
500dAC                   endif
500dA*
     C                   if        lwutyp = 'N'  and
     C                             lwqalc <= stock1  or
     C                             lwutyp = '1'  and
     C                             lwqalc <= stock2  or
     C                             lwutyp = '2'  and
     C                             lwqalc <= stock3
     C                   leave
     C                   endif
     *
     *      Otherwise, try to replenish slot.
     *
     C                   exsr      getitm
414aAC                   eval      $lqty = *zeros
414aAC                   if        ophpwc = 'N'  or
414aA*
414aAC                             ophpwc = 'Y'  and
414aAC                             $potyp <> 'W'
414aA*
     C                   call      'OR632'
     C                   parm                    $pbat
     C                   parm                    $pwhse
     C                   parm                    $prtid
411 MC                   parm                    #bitem
     C                   parm                    itum1
     C                   parm                    itcube
     C                   parm                    itswgt
     C                   parm                    curtrn
     C                   parm                    lwpal#
     C                   parm                    lwwhdp
     C                   parm                    lwaisl
     C                   parm                    lwloc
     C                   parm                    lwrlvl
     C                   parm                    lwhand
     C                   parm                    lwdisp
     C                   parm      0             $lqty             7 0
408 AC                   parm                    $lentd            8 0
408 AC                   parm                    $lexpd            8 0
     C                   parm      ' '           $lrtn             8
414aAC                   endif
     *
     *      If nothing was replenished then get out of loop.
     *
     C                   if        $lqty = 0
     C                   leave
     C                   endif
     *
     *      Otherwise, update stock qty and repeat loop.
     *
     C                   add       $lqty         stock1
     C                   add       $lqty         slrcv1
408  C                   eval      slentd = $lentd
408  C                   eval      slexpd = $lexpd
520aDC                   exsr      avail
     *
     C                   enddo
     *
     *  Update slot record.
     *
     *    If there isn't enough stock on hand then reduce the
     *    slot allocation by the qty that was allocated but only
     *    pick the qty that is on hand.
     *
     *
415bAC     updslt        tag
     *
     C                   select
     C                   when      lwutyp = 'N'
     C                   eval      slalc1 = slalc1 - lwqalc
     C                   if        slalc1 < 0
     C                   eval      slalc1 = 0
     C                   endif
     C                   eval      lwqpck = lwqalc
     C                   if        lwqalc > stock1
404 AC                   eval      difflg = *on
     C                   eval      picked = stock1
     C                   eval      p1msg = msg(3)
     C                   exsr      prterr
404 AC                   if        stock1 < 0
404 AC                   eval      lwqpck = 0
404 AC                   else
     C                   eval      lwqpck = stock1
404 AC                   endif
413aAC                   eval      trnbr = 'TR31'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'PCKFIX  '    trsr50
413aAC                   exsr      zztrck
     C     lwqpck        mult      lwucub        lwcube
     C     lwqpck        mult      lwuwgt        lwswgt
     C                   eval      diff1 = lwqalc - lwqpck
     C                   eval      diff2 = 0
     C                   eval      diff3 = 0
520aAC                   eval      $acmd = '*UNALOCN'
     C                   exsr      unaloc
417cAC                   if        opelbl = 'Y'
417cAC                   eval      lwqalc = lwqpck
417cAC                   endif
     C                   endif
     *
GLPb *   GLP creates Runner entry for shorts so no need to
GLPb *       move qty to pick bucket since it won't be 'Picked'
GLPbAC                   if        client = greenleaf
GLPbAC                             and ampdm4_ampfl = 'Y'
GLPb *    any pick qty left from AMP pick gets sent to Runner
GLPbAC                   else
     C                   add       lwqpck        slpck1
GLPaAC                   endif
     *
     C                   when      lwutyp = '1'
520aAC                   exsr      getitm
520aAC                   exsr      unalc1
520aAC                   exsr      pckfx1
520aMC                   if        lwqalc > lwqpck
404 AC                   eval      difflg = *on
520aMC                   eval      picked = lwqpck
     C                   eval      p1msg = msg(3)
     C                   exsr      prterr
413aAC                   eval      trnbr = 'TR32'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'PCKFIX  '    trsr50
413aAC                   exsr      zztrck
     C     lwqpck        mult      lwucub        lwcube
     C     lwqpck        mult      lwuwgt        lwswgt
     C                   eval      diff1 = 0
     C                   eval      diff2 = lwqalc - lwqpck
     C                   eval      diff3 = 0
520aAC                   eval      $acmd = '*UNALOC1'
     C                   exsr      unaloc
417cAC                   if        opelbl = 'Y'
417cAC                   eval      lwqalc = lwqpck
417cAC                   endif
     C                   endif
     *
     C                   when      lwutyp = '2'
     C                   sub       lwqalc        slalc3
     C                   if        slalc3 < 0
     C                   eval      slalc3 = 0
     C                   endif
     C                   eval      lwqpck = lwqalc
     C                   if        lwqalc > stock3
404 AC                   eval      difflg = *on
     C                   eval      picked = stock3
     C                   eval      p1msg = msg(3)
     C                   exsr      prterr
404 AC                   if        stock3 < 0
404 AC                   eval      lwqpck = 0
404 AC                   else
     C                   eval      lwqpck = stock3
404 AC                   endif
413aAC                   eval      trnbr = 'TR33'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'PCKFIX  '    trsr50
413aAC                   exsr      zztrck
     C     lwqpck        mult      lwucub        lwcube
     C     lwqpck        mult      lwuwgt        lwswgt
     C                   eval      diff1 = 0
     C                   eval      diff2 = 0
     C                   eval      diff3 = lwqalc - lwqpck
520aAC                   eval      $acmd = '*UNALOC2'
     C                   exsr      unaloc
417cAC                   if        opelbl = 'Y'
417cAC                   eval      lwqalc = lwqpck
417cAC                   endif
     C                   endif
     C                   add       lwqpck        slpck3
     *
     C                   endsl
     *
     C                   update    slrec
     *
     *  Update label record.
     *
     C     updlbl        tag
     *
     C                   eval      lwtrn# = curtrn
     C                   eval      lwstat = 'P'
     C                   eval      lwsdte = today
     C                   time                    lwstim
640cAC                   if        pass = 1
640cAC                   eval      TranUsedCount +=1
640cAC                   endif
     C                   update    lwrec
     *
     *   Add transaction number to order detail transaction file.
     *
     C                   exsr      wrtodt
     *
     *  Update transaction totals.
     *
     C                   add       lwcube        ttlcub
     C                   add       lwswgt        ttlwgt
     C                   add       lwqpck        ttlpcs
     *
410a *  Create label for exception.
410a *
410a C                   if        opelbl = 'Y'  and
414aAC                             ophpwc = 'N'  or
     *
414aAC                             opelbl = 'Y'  and
414aAC                             ophpwc = 'Y'  and
414aAC                             $potyp <> 'W'
410a C                   if        diff1 > 0  or
410a C                             diff2 > 0  or
410a C                             diff3 > 0
CLD A*
CLD AC                   if        client = cityln
CLD A*    Don't create label record for PIR item that doesn't
CLD A*    have any slots in warehouse.
CLD AC                   if        lwstyp = 'P'  and
CLD AC                             lwasl2 = 'OUT'  and
CLD AC                             lwdisp = *blanks
CLD AC                   goto      endpkf
CLD A*
CLD AC                   endif
CLD AC                   endif
CLD A*
410a C                   select
410a C                   when      diff1 > 0
410a C                   eval      lwqpck = diff1
410a C                   eval      lwutyp = 'N'
410a C                   eval      lwucod = itum1
410a C                   eval      lwucub = itcube
410a C     lwucub        mult      lwqpck        lwcube
410a C                   eval      lwuwgt = itswgt
410a C     lwuwgt        mult      lwqpck        lwswgt
410a C                   when      diff2 > 0
410a C                   eval      lwqpck = diff2
410a C                   eval      lwutyp = *on
410a C                   eval      lwucod = itum2
410a C                   if        itumq2 <> 0
410a C     itcube        div(h)    itumq2        lwucub
410a C     lwucub        mult      lwqpck        lwcube
410a C     itswgt        div(h)    itumq2        lwuwgt
410a C     lwuwgt        mult      lwqpck        lwswgt
410a C                   endif
410a C                   when      diff3 > 0
410a C                   eval      lwqpck = diff3
410a C                   eval      lwutyp = '2'
410a C                   eval      lwucod = itum3
410a C                   if        itumq2 <> 0  and
410a C                             itumq3 <> 0
410a C     itcube        div(h)    itumq2        lwucub
410a C     lwucub        div(h)    itumq3        lwucub
410a C     lwucub        mult      lwqpck        lwcube
410a C     itswgt        div(h)    itumq2        lwuwgt
410a C     lwuwgt        div(h)    itumq3        lwuwgt
410a C     lwuwgt        mult      lwqpck        lwswgt
410a C                   endif
410a C                   endsl
417c C                   eval      lwqalc = lwqpck
410a C                   eval      lwasl2 = 'OUT'
730iDC**                 call      'PIRLBL#'
730iDC**                 parm                    lwlbl#
730iMC                   exsr      GetNextLbl#
730iMC                   eval      lwlbl# = nextLbl#
410a C                   write     lwrec0
414 AC                   add       lwcube        ttlcub
414 AC                   add       lwswgt        ttlwgt
414 AC                   add       lwqpck        ttlpcs
410a C                   endif
410a C                   endif
CLD A*
CLD AC     endpkf        tag
     *
     C                   endsr
520aA*----------------------------------------------------------------
520aA*
520aA*  PCKFX1  Pick breakdown 1 quantity.
520aA*
520aAC     pckfx1        begsr
     C                   exsr      avail
     C                   eval      svqty2 = lwqalc
     C                   eval      lwqpck = 0
     C                   eval      newpk2 = slpck2
     *
     *   If there is enough breakdown 1 qty available then grab it.
     *
     C                   select
     C                   when      lwqalc <= avail2
     C                   add       lwqalc        newpk2
     C                   eval      lwqpck = lwqalc
     C                   sub       lwqalc        avail2
     *
     *   Otherwise try to break a larger unit to get qty needed.
     *
     *     We try to pick full cases then eaches. This is because
     *     brkdn 1 qty's over 999 were being sent to be picked.
     *     The 'PICKU' qtys reflect the actual uom qty's we picked
     *     from the slot, while the 'PICKQ' qty's is what we picked
     *     of the label.
     *
     C                   other
     *
     *   First, try to pick full cases
     *
     C                   dow       svqty2 >= itumq2  and
     C                             avail1 > 0  and
     C                             itumq2 > 0
     C                   add       1             slpck1
     C                   eval      avail1 = avail1 - 1
     C                   add       itumq2        lwqpck
     C                   eval      svqty2 = svqty2 - itumq2
     C                   enddo
     *
     *   Then pick the remaining qty from the brkdn 1 qty
     *
     C                   dow       svqty2 > 0
     *
     *       If enough available, pick entire qty.
     *
     C                   if        svqty2 <= avail2
     C                   add       svqty2        newpk2
     C                   add       svqty2        lwqpck
     C                   sub       svqty2        avail2
     C                   eval      svqty2 = 0
     C                   leave
     C                   endif
     *
     *       Not enough availalbe, break down a case and loop.
     *
     C                   if        avail1 > 0  and
     C                             itumq2 > 0
     C                   eval      avail1 = avail1 - 1
     C                   add       itumq2        avail2
     C                   eval      slstk1 = slstk1 - 1
     C                   add       itumq2        slstk2
     C                   iter
     C                   endif
     *
     *       Case not available, take what we can get.
     *
     C                   if        avail2 > 0
     C                   add       avail2        newpk2
     C                   add       avail2        lwqpck
     C                   eval      svqty2 = svqty2 - avail2
     C                   eval      avail2 = 0
     C                   endif
     *
     C                   leave
     C                   enddo
     *
     *   If any qty still remains and we are to pick it all
     *     Then pick it all, cases first, then brkdn 1.
     *
     C                   if        pckall = *on
     *
     C                   if        svqty2 > 0
     C                   dow       svqty2 >= itumq2  and
     C                             itumq2 > 0
     C                   add       1             slpck1
     C                   eval      avail1 = avail1 - 1
     C                   add       itumq2        lwqpck
     C                   eval      svqty2 = svqty2 - itumq2
     C                   enddo
     C                   endif
     *
     C                   if        svqty2 > 0
     C                   add       svqty2        newpk2
     C                   add       svqty2        lwqpck
     C                   sub       svqty2        avail2
     C                   eval      svqty2 = 0
     C                   endif
     *
     C                   endif
     *
     C                   endsl
     *
     *   Now, convert pick brkdnq's into cases.
     *
     C                   dow       newpk2 >= itumq2  and
     C                             itumq2 > 0
     C                   add       1             slpck1
     C                   eval      newpk2 = newpk2 - itumq2
     C                   enddo
     *
     *   Move NEWPK2 (which should be less than 1 case) into SLPCK2 field.
     *
     C                   z-add     newpk2        slpck2
     *
     *   Last, see if stock brkdn1 can be converted to cases.
     *
     C                   exsr      avail
     C                   dow       avail2 >= itumq2  and
     C                             slstk2 >= itumq2  and
     C                             itumq2 > 0
     C                   add       1             slstk1
     C                   eval      slstk2 = slstk2 - itumq2
     C                   eval      avail2 = avail2 - itumq2
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PCKMRG   Pick merge records.
     *
     *     Note: Merge records only get added to the pallet's transaction.
     *           The slot qty's are not adjusted.
     *
     *
     C     pckmrg        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'PCKMRG  '    trsubr
413aAC                   exsr      zztrck

520dAC                   exsr      getopt2
FDIaA
FDIaA*  For Finkle ...
FDIaA*    - Get corresponding label.
FDIaA*    - For pass 1, skip "DRY-O" records.
FDIaA*    - For pass 2, skip non-"DRY-O" records.
FDIaA
520dAC                   if        xppkup = 'L'
520dAC                             and xpspal = 'Y'
FDIaAC                   select
520dMC                   when      pass=1 and psszon = parentzone
FDIaAC                   leavesr
520dMC                   when      pass=2 and psszon <> parentzone
FDIaAC                   leavesr
FDIaAC                   when      pass=2 and pass2First
640cAC                             and TranUsedCount > 0
FDIaAC                   eval      pass2First = *off
FDIaAC                   exsr      newtrnfdi
FDIaAC                   endsl
FDIaAC                   endif
     *
     *     Update label record.
     *
     C                   eval      lwqpck = lwqalc
520dMC                   if        xppkup = 'L' and xpspal = 'Y'
520dMC                                          and pass = 2
640cAC                             and TranUsedCount > 0
FDIaAC                   eval      lwtrn# = fditrn
FDIaAC                   else
     C                   eval      lwtrn# = curtrn
640cAC                   if        pass = 1
640cAC                   eval      TranUsedCount +=1
640cAC                   endif
FDIaAC                   endif
     C                   eval      lwstat = 'P'
     C                   eval      lwsdte = today
     C                   time                    lwstim
     C                   update    lwrec
     *
     *   Add transaction number to order detail transaction file.
     *
     C                   exsr      wrtodt
     *
     *     Update transaction totals.
     *
520dD ***                if        client = finkle and pass = 2
520dMC                   if        xppkup = 'L' and xpspal = 'Y'
520dMC                                          and pass = 2
FDIaAC                   add       lwcube        fdicub
FDIaAC                   add       lwswgt        fdiwgt
FDIaAC                   add       lwqpck        fdipcs
FDIaAC                   else
     C                   add       lwcube        ttlcub
     C                   add       lwswgt        ttlwgt
     C                   add       lwqpck        ttlpcs
FDIaAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PCKPIR   Pick PIR section item.
     *
     *     Note: With a PIR section item the allocation and breakdown
     *           checks were done at allocation time.  A special order
     *           item, whether it is a Fixed or PIR item, is always
     *           treated as a PIR item.
     *
     *
     C     pckpir        begsr
520aAC                   exsr      getitm
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'PCKPIR  '    trsubr
413aAC                   exsr      zztrck
     *
     *     Update slot record.
     *
410aAC                   if        lwasl2 <> 'OUT'  and
415aAC                             lwasl2 <> '***'
     C                   select
     C                   when      lwutyp = 'N'
     C                   eval      slalc1 = slalc1 - lwqalc
     C                   if        slalc1 < 0
     C                   eval      slalc1 = 0
     C                   endif
     C                   add       lwqalc        slpck1
     *
     C                   when      lwutyp = '1'
520aAC                   exsr      unalc1
520aAC                   eval      pckall = *on
520aAC                   exsr      pckfx1
     *
     C                   when      lwutyp = '2'
     C                   sub       lwqalc        slalc3
     C                   if        slalc3 < 0
     C                   eval      slalc3 = 0
     C                   endif
     C                   add       lwqalc        slpck3
     *
     C                   endsl
     *
     C                   update    slrec
410aAC                   endif
     *
     *     Update label record.
     *
     C                   eval      lwqpck = lwqalc
     C                   eval      lwtrn# = curtrn
     C                   eval      lwstat = 'P'
     C                   eval      lwsdte = today
     C                   time                    lwstim
640cAC                   eval      TranUsedCount +=1
     C                   update    lwrec
     *
404 A*   Add transaction number and label numbers to cross dock file.
     *
404 AC                   if        lwstyp = 'X'
404 AC     keycd1        chain     crossdk1                           77
404 AC                   if        not *in77
404 AC                   eval      cdort# = lwtrn#
404 AC                   eval      cdorl# = lwlbl#
404 AC                   update    cdrec
404 AC                   endif
404 AC                   endif
     *
     *   Add transaction number to order detail transaction file.
     *
     C                   exsr      wrtodt
     *
     *     Update transaction totals.
     *
     C                   add       lwcube        ttlcub
     C                   add       lwswgt        ttlwgt
     C                   add       lwqpck        ttlpcs
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PICK     Pick non-bulk pallets.
     *
     C     pick          begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'PICK    '    trsubr
413aAC                   exsr      zztrck
FDIaA
FDIaA*  Set up number of passes we should make.
FDIaA
FDIaAC                   eval      passes = 2
640cAC                   eval      tranusedcount = *zeros
FDIaAC                   eval      pass2First = *on
FDIaA
FDIaA*  Loop for the number of passes defined above.
FDIaA
FDIaAC                   for       pass = 1 to passes
     *
     C                   eval      first = *on
     C                   eval      lstitm = *blanks
     C                   eval      curtyp = *blanks
     *
     *  Loop through pick labels for pallet.
     *
     C     keylw5        setll     worklbl5
     *
     C                   dou       forevr <> forevr
     *
     C     keylw5        reade     worklbl5                               78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   eval      lstwdp = lwwhdp
     *
     *     Only work with normal and merge records.
     *
     C                   if        lwtype <> 'O'  and
     C                             lwtype <> 'M'
     C                   iter
     C                   endif
     *
     *     Ignore labels that have already been picked.
     *
     C                   if        lwstat = 'P'  or
     C                             lwstat = 'X'
     C                   iter
     C                   endif
520dAC                   if        pass = 2
520dAC                             and lwtype <> 'M'
520dAC                   iter
520dAC                   endif
     *
     *     Get slot record.
     *
     C                   if        lwtype <> 'M'  and
410aAC                             lwasl2 <> 'OUT'  and
415aAC                             lwasl2 <> '***'
     C                   eval      picked = 0
     C     keysl2        chain     slot2                              7778
     C                   if        *in77
     C                   eval      p1msg = msg(1)
     C                   exsr      prterr
413aAC                   eval      trnbr = 'TR01'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'PICK    '    trsr50
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
     C                   if        *in78
     C                   eval      p1msg = msg(2)
     C                   exsr      prterr
413aAC                   eval      trnbr = 'TR02'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'PICK    '    trsr50
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
     C                   endif
SLB A*
SLB A*     Increment IDS seq# and put into LWPO.
SLB A*
YHTaMC                   if        (client = Silberman
FPRaAC                             or client = FoodPro
JOR AC                             or client = Jordanos
SGCdAC                             or client = SGC
YHTaAC                             or client = YHata
GMMcAC                             or client = MenuMaker
SOF AC                              or client = Sofofoods)
SLB AC                   add       1             hsseq#
SLB AC                   move      hsseq#        hsseqa
SLB AC                   movel     hsseqa        lwpo
SLB AC                   endif
USF A*
USF A*     Increment USF batch seq. number and put into LWDSP2
USF A*
USF AC                   if        client = usfcrp
USFdA*
USFdA*    Force Group to W when processing Will-Call orders.
USFdA*
USF A*  PirUSF700M - this was all removed up to this same line below \/
USF A *                  if        $potyp = 'W'
USF A *                  eval      usfgrp = 'W'
USF A *                  else
USFaA*    Retrieve group code from item build code.
USFaA *                  call      'GETBLDC'
USFaA *                  parm                    lwwhse
USFaA *                  parm                    lwitem
USFaA *                  parm      '  '          $pbld             2
USFaA *                  parm                    $prtn             8
USFaA*
USFaA *                  movel     $pbld         usfgrp
USFcA*
USFcA*    Start USF Batch Number over each time Group changes.
USFcA *                  if        usfgrp <> hldgrp  and
USFcA *                            lwtype <> 'M'
USFcA *                  eval      usfbat = 1
USFcA *                  eval      hldgrp = usfgrp
USFcA *                  endif
USFcA*
USF A *                  endif
USFaA*
USF A *                  add       1             usfseq
USF A * PirUSF700M - this was all removed up to this same line below /\
USFaA*
USF AC                   eval      lwdsp2 = usfkey
USF A*
USF AC                   endif
     *
     *     Execute routine to pick product.
     *
     C                   select
     *
     *       Merge record.
     *
     C                   when      lwtype = 'M'
     C                   eval      curtyp = 'FP'
     C                   exsr      pckmrg
     *
     *       PIR section pick.
     *
     C                   when      lwstyp = 'P'
     C                   eval      curtyp = 'PP'
     C                   exsr      pckpir
     *
     *       Fixed section pick - Normal.
     *
     C                   when      lwstyp = 'F'  and
     C                             lwspcl = *blanks  and
415aAC                             lwasl2 <> '***'  or
VIP A*
VIP AC                             client = vip  and
VIP AC                             lwstyp = 'F'  and
VIP AC                             lwasl2 = '***'  or
YHT A*
YHT AC                             client = yhata  and
YHT AC                             lwstyp = 'F'  and
YHT AC                             lwasl2 = '***'  or
GLZ MC                             (client = mjkeln  or
SGCcAC                              client = sgc or
GLZ AC                              client = glazier or
GMMbAC                              client = MenuMaker or
FPRaAC                              client = FoodPro   or
SOFaAC                              client = SofoFoods or
SLBaAC                              client = Silberman) and
MJK AC                             lwstyp = 'F'  and
MJK AC                             lwasl2 = '***'
VIP A*
     C                   eval      curtyp = 'FP'
     C                   exsr      pckfix
     *
     *       Fixed section pick - Special order.
     *
     C                   when      lwstyp = 'F'  and
     C                             lwspcl <> *blanks
     C                   eval      curtyp = 'FP'
     C                   exsr      pckpir
     *
404 A*       Cross dock pick -
     *
404 AC                   when      lwstyp = 'X'  and
404 AC                             lwspcl <> *blanks
404 AC                   eval      curtyp = 'FP'
404 AC                   exsr      pckpir
     *
413 A*       Missing section
413 A*
413 AC                   when      lwstyp = ' '  and
415aAC                             lwasl2 <> '***'  or
CBI A*
CBI AC                             client = cheney  and
CBI AC                             lwstyp > ' '  and
CBI AC                             lwasl2 = '***'  or
VIP A*
VIP AC                             client = vip  and
VIP AC                             lwstyp > ' '  and
VIP AC                             lwasl2 = '***'  or
YHT A*
YHT AC                             client = yhata  and
YHT AC                             lwstyp > ' '  and
YHT AC                             lwasl2 = '***'  or
MJK A*
GFC DC*                            client = mjkeln  and
GFC MC                             (client = mjkeln  or
GMMbAC                              client = menumaker or
SGCcAC                              client = SGC  or
KFS AC                              client = Kellys or
GFC AC                              client = glazier) and
MJK AC                             lwstyp > ' '  and
MJK AC                             lwasl2 = '***'
VIP A*
413 AC                   eval      curtyp = 'FP'
413 AC                   exsr      pckfix
     *
     C                   endsl
     *
     C                   enddo
FDIaA
FDIaA*  End the "passes" loop
FDIaA
FDIaAC                   endfor
FDIaA
FDIaA*  See if we need to write out a pass 2 transaction
FDIaA
520dAC                   if        xppkup = 'L' and xpspal = 'Y'
520dMC                                          and not pass2First
640cAC                                          and TranUsedCount > 0
FDIaAC                   exsr      wrttrnfdi
FDIaAC                   endif
     *
406 A*       Update replenishment with pallet #.
     *
406 AC                   eval      kyplid = 0
406 AC                   exsr      updrpl
406 AC                   eval      kyplid = psplid
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PICKB   Pick bulk pick item.
     *
     *    Note: It is assumed that bulk picks are "normal" quantities.
     *          Also, each bulk pick gets a unique tran# and pallet #.
     *
740cA*          Can no longer assume bulk picks are "normal" quantities.
740cA*          An item without a Pick slot can be created as a Bulk pick.
     *
     C     pickb         begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'PICKB   '    trsubr
413aAC                   exsr      zztrck
     *
     *  Loop through bulk labels for pallet.
     *
     C     keylw5        setll     worklbl5
     *
     C                   dou       forevr <> forevr
     *
     C     keylw5        reade     worklbl5                               78
     C                   if        *in78
     C                   leave
     C                   endif
     *
     *     Only work with bulk pick records.
     *
     C                   if        lwtype <> 'B'
     C                   iter
     C                   endif
     *
     *     Ignore labels that have already been picked.
     *
     C                   if        lwstat = 'P'  or
     C                             lwstat = 'X'
     C                   iter
     C                   endif
USFcA*
USFcA*     Increment USF batch seq. number and put into LWDSP2
USFcA*
USFcAC                   if        client = usfcrp
USFcA*
USFqAC                   select
USFqAC                   when      $pcmd2 <> '*STGPRNT'
USFlAC                   call      'PIRUSF#'
USFlAC                   parm      0             curseq            7 0
USFlAC                   z-add     curseq        usfasq
USFdA*
USFqAC                   when      $pcmd2 =  '*STGPRNT'
USFdAC                   eval      curseq = *zeros
USFdAC                   eval      usfasq = *zeros
USFqAC                   endsl
USFqA*
USFlAC                   eval      usfseq = *zeros
USFlA*
USFdA*    Otherwise create PSYS group/load/batch.
USFcA*    Force Group to W when processing Will-Call orders.
USFcA *                  if        $potyp = 'W'
USFcA *                  eval      usfgrp = 'W'
USFcA *                  else
USFcA*    Retrieve group code from item build code.
USFcA *                  call      'GETBLDC'
USFcA *                  parm                    lwwhse
USFcA *                  parm                    lwitem
USFcA *                  parm      '  '          $pbld
USFcA *                  parm                    $prtn
USFcA*
USFcA *                  movel     $pbld         usfgrp
USFcA*
USFcA*    Start USF Batch Number over each time Group changes.
USFcA *                  if        usfgrp <> hldgrp  and
USFcA *                            lwtype <> 'M'
USFcA *                  eval      usfbat = 1
USFcA *                  eval      hldgrp = usfgrp
USFcA *                  endif
USFcA*
USFcA *                  endif
USFcA*
USFcA *                  add       1             usfseq
USFcAC                   eval      lwdsp2 = usfkey
USFcA*
USFcAC                   endif
     *
     *     Get slot record.
     *
     C     keysl2        chain     slot2                              7778
     C                   if        *in77
     C                   eval      p1msg = msg(1)
     C                   exsr      prterr
413aAC                   eval      trnbr = 'TR01'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'PICKB   '    trsr50
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
     C                   if        *in78
     C                   eval      p1msg = msg(2)
     C                   exsr      prterr
413aAC                   eval      trnbr = 'TR02'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'PICKB   '    trsr50
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
     *
     *  If partial pallet see if we can put remainder in pick slot.
     *
     C                   eval      rplflg = *off
     C                   if        lwqrmn > 0
     *
     *    First determine if quantity remaining is still available.
     *
     C                   exsr      avail
     C                   if        avail1 >= lwqrmn
     C                   eval      trnqty = lwqrmn
     C                   else
     C                   eval      trnqty = avail1
     C                   endif
408 A*
408 A*    Get item information.
408 A*
408 AC                   exsr      getitm
     *
     *    Then try to replenish pick slot with it.
408 A*    Note: Do not do this for date sensitive item.
     *
     C                   if        trnqty > 0  and
408 AC                             itflgd <> 'Y'
     *
     C                   endif
     *
     C                   endif
     *
     *  Update slot record.
     *
     C                   select
     C                   when      lwutyp = 'N'
     C                   eval      slalc1 = slalc1 - lwqalc
     C                   if        slalc1 < 0
     C                   eval      slalc1 = 0
     C                   endif
     C                   add       lwqalc        slpck1
     C                   if        rplflg = *on
     C                   add       trnqty        sltfr1
     C                   endif
     *
     C                   when      lwutyp = '1'
740cDC**                 sub       lwqalc        slalc2
740cDC**                 if        slalc2 < 0
740cDC**                 eval      slalc2 = 0
740cDC**                 endif
740cDC**                 add       lwqalc        slpck2
740cAC                   exsr      getitm
740cAC                   exsr      unalc1
740cAC                   eval      pckall = *on
740cAC                   exsr      pckfx1
     *
     C                   when      lwutyp = '2'
     C                   sub       lwqalc        slalc3
     C                   if        slalc3 < 0
     C                   eval      slalc3 = 0
     C                   endif
     C                   add       lwqalc        slpck3
     *
     C                   endsl
     C                   update    slrec
     *
     *  Create transaction record.
     *
730iDC**                 call      'PIRTRN#'
730iDC**                 parm                    pttrn#            7 0
730iMC                   exsr      GetNextTrn#
730iMC                   eval      pttrn# = nextTrn#
     C                   select
     C                   when      lwqrmn = 0
     C                   eval      @ptask = 'BULKF '
     C                   when      trnqty > 0  and
     C                             rplflg = *on
     C                   eval      @ptask = 'BULKR '
     C                   other
     C                   eval      @ptask = 'BULKP '
412aAC                   eval      trnqty = 0
     C                   endsl
     *
     C                   call      @addtr
     C                   parm      '*CREATE '    @pcmd             8
     C                   parm                    #job
     C                   parm      pttrn#        @ptrn#            7 0
     C                   parm                    @ptask            6
     C                   parm      lwwhse        @pwhse            3 0
     C                   parm      lwwhdp        @pwhdp            5
     C                   parm      lwstyp        @pstyp            1
     C                   parm      lwcube        @pcube            9 3
     C                   parm      lwswgt        @pswgt            9 2
412aAC                   parm      lwqalc        @ppcs             5 0
     C                   parm      1             @paisl            5 0
     C                   parm      1             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      $prtid        @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      'S'           @pgrp1            1
     C                   parm      $potyp        @pgrp2            1
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
     *
410 A*  Write selector for RF will call
410 AC                   if        $potyp = 'W'  and
410 AC                             prodt = '*RF     '  and
410bAC                             oprfwc = 'Y'
410 AC                   exsr      wrtsct
410 AC                   exsr      sndusr
410 AC                   endif
     *
     *  Update label record.
     *
     C                   if        rplflg = *on
     C                   eval      lwwhs2 = lwwhse
     C                   eval      lwwhd2 = lwwhdp
     C                   eval      lwasl2 = $laisl
     C                   eval      lwloc2 = $lloc
     C                   eval      lwlvl2 = $lrlvl
     C                   eval      lwhnd2 = $lhand
     C                   eval      lwdsp2 = $ldisp
404 AC                   else
404 AC                   eval      lwwhs2 = 0
404 AC                   eval      lwwhd2 = *blanks
404 AC                   eval      lwasl2 = *blanks
404 AC                   eval      lwloc2 = 0
404 AC                   eval      lwlvl2 = 0
404 AC                   eval      lwhnd2 = *blanks
USFcA*
USFcAC                   if        client = usfcrp
USFcA*    Do nothing....
USFcAC                   else
404 AC                   eval      lwdsp2 = *blanks
USFcAC                   endif
USFcA*
     C                   endif
     C                   eval      lwqpck = lwqalc
     C                   z-add     trnqty        lwqrmn
     C                   eval      lwtrn# = pttrn#
     C                   eval      lwstat = 'P'
     C                   eval      lwsdte = today
     C                   time                    lwstim
YHTaMC                   if        (client = Silberman
FPRaAC                             or client = FoodPro
GMM AC                             or client = MenuMaker
JOR AC                             or client = Jordanos
SGCdAC                             or client = SGC
SOf AC                              or client = Sofofoods
YHTaAC                             or client = YHata)
SLB AC                   movel     '00001'       lwpo
SLB AC                   endif
     C                   update    lwrec
     *
     *   Add transaction number to order detail transaction file.
     *
     C                   exsr      wrtodt
     *
     C                   enddo
     *
406 A*       Update replenishment with pallet #.
     *
406 AC                   eval      kyplid = 0
406 AC                   exsr      updrpl
406 AC                   eval      kyplid = psplid
416bA*
416bA*   Update pallet with transaction number.
416bA*
416bA*   Note: It is assumed that there is only one bulk pick label
416bA*         record for each bulk pick pallet summary record.
416bA*
416bAC                   eval      pstrn# = pttrn#
416bAC                   update    psrec
     *
     C                   endsr
710bA*----------------------------------------------------------------
710bA*
710bA*  PICK1   Bulk Picks
710bA*
710bAC     pick1         begsr
710bA*
USFgAC                   if        client = usfcrp
USFgAC                   move      *hival        lstcmp
USFgAC                   move      *hival        lstzon
USFgAC                   endif
USFgA*
     C                   eval      kytype = 'B'
     C     keyps3        setll     pltsum3
     C                   dow       forevr = forevr
     C     keyps3        reade     pltsum3                                79
     C                   if        *in79
     C                   leave
     C                   endif
USFnA*
USFnM*   Skip pallet if already assigned a transaction
USFnA*
USFnAC                   if        pstrn# <> *zeros
USFnAC                   iter
USFnAC                   endif
     *
     C                   eval      kyplid = psplid
USFgA*
     *  Get zone selector for RF will call
     C                   if        $potyp = 'W'  and
     C                             prodt = '*RF     '  and
     C                             oprfwc = 'Y'
     C                   exsr      getsct
     C                   endif
     C                   exsr      pickb
     *
     C                   enddo
710bAC                   endsr
710bA*----------------------------------------------------------------
710bA*
710bA*  PICK2   Normal Picks
710bA*
710bAC     pick2         begsr
710bA*
710bAC                   if        phase = 1  or
710bAC                             phase = 2  or
710eAC                             phase = 3
     C                   eval      difflg = *off
720dDC**                 eval      kytype = 'O'
730fAc                   if        phase = 1
730fAc                   eval      kytype = 'O'
730fAc                   else
720dMC                   eval      kytype = tbPalletType
730fAc                   endif
     C                   eval      pcount = 0
     C                   eval      curtrn = 0
     C                   eval      curpal = 0
     C                   move      *hival        lstcmp
     C                   move      *hival        lstzon
710dAC                   move      *hival        svcomp
710dAC                   move      *hival        svtzon
710dAC                   eval      svgen = *hival
710dAC                   move      *hival        svszon
710dAC                   move      *hival        svtype
710dAC                   eval      svfrst = *on
     C                   if        client = usfcrp
     C                   eval      lsttrn = -(1)
     C                   endif
710bAC                   endif

710fAC                   select
710fA **                 when  **  client = usfcrp
710fAC                   when      phase = 3
710fAC     keyps3        setll     pltsum14
710fAC                   other
     C     keyps3        setll     pltsum3
710fAC                   endsl

     C                   dow       forevr = forevr

710fAC                   select
710fA **                 when  **  client = usfcrp
710fAC                   when      phase = 3
710fAC     keyps3        reade     pltsum14                               79
710fAC                   other
     C     keyps3        reade     pltsum3                                79
710fAC                   endsl

     C                   if        *in79
     C                   leave
     C                   endif
     *
710bAC                   select
710eA*
710eM*   Skip empty pallets.
710eA*
710eAC                   when      pspcs = 0
710eAC                   iter
710eA*
710eM*   Skip pallet if already assigned a transaction
710eA*
710eAC                   when      pstrn# <> *zeros
710eAC                   iter
710cA*
710cM*   For phase 1, only work with Gen 2+
710cA*
710bAC                   when      phase = 1
710cMC                   if        psgen < 2
710vAC                   iter
710vAC                   endif
710vA*
710cM*   For phase 2, *** NON USF *** only work w/unload seq <= 70
710eA*     assigned to it.
710bA*
710bAC                   when      phase = 2
710fA **                        ** and client <> usfcrp
710dAC                   if        psgen <> 1  or
710cMC                             psunld > 70
710dAC                   iter
710dAC                   endif
710fA*
710fA*   For phase 2, *** USF *** work w/unload seq#'s that have
710fA*     not had a tran assigned to it.
710fA*
710fAC                   when      phase = 2
710fA **                        ** and client = usfcrp
710fAC                   if        psgen <> 1
710fAC                             and pstrn# > 0
710fAC                   iter
710fAC                   endif
710eA*
710eM*   For phase 3, only work w/unload seq > 70 that
710eA*     has not had a tran assigned to it.
710eA*
710eAC                   when      phase = 3
710eAC                   if        psgen <> 1  or
710eMC                             psunld <= 70  or
710eAC                             pstrn# > 0
710eAC                   iter
710eAC                   endif
710cA*
710bAC                   endsl
710dA*
710dA*    If save info changed, execute phase 3 for that info.
710eM*       Only for phase 2 and 3
710dA*
710dMC                   if        phase = 2  or
710eMC                             phase = 3
710dAC                   if        svtype <> pstype  or
710dAC                             svcomp <> pscomp  or
710dAC                             svtzon <> pstzon  or
710dAC                             svgen <> psgen  or
710dAC                             svszon <> psszon
710dAC                   if        svfrst = *off
710dAC                   exsr      pick3
710dAC                   endif
710dAC                   eval      svtype = pstype
710dAC                   eval      svcomp = pscomp
710dAC                   eval      svtzon = pstzon
710dAC                   eval      svgen = psgen
710dAC                   eval      svszon = psszon
710dAC                   eval      svfrst = *off
710dAC                   endif
710dAC                   endif
710dA*
710dA*    Assign transaction.
710eA*      Except for phase 3.
710dA*
710eAC                   if        phase <> 3
730edC**                 eval      lf = '3'
730emC                   eval      pltsumLF = '3'
710dAC                   exsr      pick99
710eAC                   endif
     *
     C                   enddo
710dA*
710dA*    Execute phase 3 for last info processed.
710dA*
710eMC                   if        phase >= 2  and
710dAC                             svfrst = *off
710dAC                   exsr      pick3
710dAC                   endif
710bA*
710bAC                   endsr
710dA*----------------------------------------------------------------
710dA*
710dA*  PICK3   >= 71 pallets for phase 2
710dA*
710dAC     pick3         begsr
     *
710dAC                   eval      s2whse = pswhse
710dAC                   eval      s2rtid = psrtid
710dAC                   eval      s2plid = psplid
710dAC                   eval      s2comp = pscomp
710dAC                   eval      s2tzon = pstzon
710dAC                   eval      s2pzon = pspzon
710dAC                   eval      s2szon = psszon
710dAC                   eval      s2gen = psgen
710dAC                   eval      s2truk = pstruk
710dAC                   eval      s2unld = psunld
710dAC                   eval      s2row = psrow
710dAC                   eval      s2col = pscol
710dAC                   eval      s2maxc = psmaxc
710dAC                   eval      s2pal# = pspal#
710dAC                   eval      s2stp1 = psstp1
710dAC                   eval      s2stp2 = psstp2
710dAC                   eval      s2pcs = pspcs
710dAC                   eval      s2cube = pscube
710dAC                   eval      s2swgt = psswgt
710dAC                   eval      s2type = pstype
710dAC                   eval      s2bcnt = psbcnt
710dAC                   eval      s2flag = psflag
710dAC                   eval      s2lbl# = pslbl#
710dAC                   eval      s2trn# = pstrn#
710dA*
740aA*  Write out last transaction.
740aA*  We do not want an overflow and truck pallet on same transaction.
740aA*
740aAC                   if        curtrn <> 0
740aAC                   exsr      wrttrn
740aA*  Write selector for RF will call
740aAC                   if        $potyp = 'W'  and
740aAC                             prodt = '*RF     '  and
740aAC                             oprfwc = 'Y'
740aAC                   eval      lslcto = slctor
740aAC                   eval      lzone = zone
740aAC                   exsr      wrtsct
740aAC                   exsr      sndusr
740aAC                   endif
740aAC                   eval      curtrn = 0
740bAC                   eval      pcount = 0
740aAC                   endif
740aA
     C     keyps5        setll     pltsum5a
     C                   dow       forevr = forevr
     C     keyps5        reade     pltsum5a                               79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *    Only work with overflow pallets.
     *         now with 5a, unld < 70 is just a skip/not end.
     *
     C                   if        psunld <= 70
710eAC*               ** unlock    pltsum5a
710eAC*               ** leave
710xAC                   iter
     C                   endif
710eA*
710eA*    Skip if pallet already has transaction number
710eA*
710eAC                   if        pstrn# <> 0
710eAC                   iter
710eAC                   endif
     *
     *    Assign transaction.
     *
720eDC**                 eval      lf = '5'
720eMC                   eval      pltsumLF = '5'
     C                   exsr      pick99
     *
     C                   enddo
     *
     *  Write out last transaction.
     *
     C                   if        curtrn <> 0
     C                   exsr      wrttrn
     *  Write selector for RF will call
     C                   if        $potyp = 'W'  and
     C                             prodt = '*RF     '  and
     C                             oprfwc = 'Y'
     C                   eval      lslcto = slctor
     C                   eval      lzone = zone
     C                   exsr      wrtsct
     C                   exsr      sndusr
     C                   endif
710cAC                   eval      curtrn = 0
     C                   endif
     *
710dAC                   eval      pswhse = s2whse
710dAC                   eval      psrtid = s2rtid
710dAC                   eval      psplid = s2plid
710dAC                   eval      pscomp = s2comp
710dAC                   eval      pstzon = s2tzon
710dAC                   eval      pspzon = s2pzon
710dAC                   eval      psszon = s2szon
710dAC                   eval      psgen = s2gen
710dAC                   eval      pstruk = s2truk
710dAC                   eval      psunld = s2unld
710dAC                   eval      psrow = s2row
710dAC                   eval      pscol = s2col
710dAC                   eval      psmaxc = s2maxc
710dAC                   eval      pspal# = s2pal#
710dAC                   eval      psstp1 = s2stp1
710dAC                   eval      psstp2 = s2stp2
710dAC                   eval      pspcs = s2pcs
710dAC                   eval      pscube = s2cube
710dAC                   eval      psswgt = s2swgt
710dAC                   eval      pstype = s2type
710dAC                   eval      psbcnt = s2bcnt
710dAC                   eval      psflag = s2flag
710dAC                   eval      pslbl# = s2lbl#
710dAC                   eval      pstrn# = s2trn#
     *
     C                   endsr
710dA*----------------------------------------------------------------
710dA*
710dA*  PICK99  Assign transaction and other stuff
710dA*
710dAC     pick99        begsr
710dA*
     *
     *    Loop if nothing on pallet.
     *
     C                   if        pspcs = 0
     C                   goto      end99
     C                   endif
     *
     *    Loop if pallet only contains bulk picks.
     *
     C                   exsr      chk4ob
     C                   if        obflag = *on
     C                   goto      end99
     C                   endif
     *
     C                   eval      kyplid = psplid
     *
     *    Get picking options for zone.
     *
     C                   if        psszon <> lstzon
     C                   eval      kyzone = psszon
     C                   exsr      getopt
     C                   eval      lstzon = psszon
     C                   eval      pcount = 0
     *  Get zone selector for RF will call
     C                   if        $potyp = 'W'  and
     C                             prodt = '*RF     '  and
     C                             oprfwc = 'Y'
     C                   exsr      getsct
     C                   endif
     C                   endif
     *
     *    Increment pallet count.
     *
     C                   if        pcount >= opfpal
     C                   eval      pcount = 1
     C                   else
     C                   add       1             pcount
     C                   endif
     *
     *    Get transaction number for pallet.
     *
     C                   if        pstrn# <> 0
     C                   eval      trntyp = '*EXIST  '
     C                   eval      curtrn = pstrn#
     C                   else
     C                   if        pcount = 1
     C                   eval      trntyp = '*NEW    '
     C                   exsr      newtrn
     C                   endif
     C                   endif
     *
     *    Start USF Seq# over for each tran.
     *
     C                   if        client = usfcrp
     *
     C                   if        curtrn <> lsttrn
     C                   eval      lsttrn = curtrn
USFdA*
USFdA*    When client location is ASYS, then create 4 digit
USFdA*    assignment number.
USFqA*
USFqAC                   select
USFqAC                   when      $pcmd2 <> '*STGPRNT'
USFdAC                   call      'PIRUSF#'
USFdAC                   parm      0             curseq
USFdAC                   z-add     curseq        usfasq
USFqA*
USFqAC                   when      $pcmd2 =  '*STGPRNT'
USFdAC                   eval      curseq = *zeros
USFdAC                   eval      usfasq = *zeros
USFqAC                   endsl
USFqA*
USFdAC                   eval      usfseq = *zeros
USFdA*
     C                   endif
     *
     C                   endif
     *
     *    Update pallet with transaction number.
     *
     C                   eval      pstrn# = curtrn
730eDC**                 if        lf = '5'
730eAC                   if        pltsumLF = '5'
710dAC                   update    psrec5
710dAC                   else

     *    Added to update correct file

710fAC                   select
710fD **                 when   ** client = usfcrp
710fAC                   when      phase = 3
     C                   update    psrec14
710fAC                   other
     C                   update    psrec
710fAC                   endsl

710dAC                   endif
     *
     *    Pick items for pallet.
     *
     C                   exsr      pick
     *
     C     end99         endsr
     *----------------------------------------------------------------
     *
     *  PRTERR  Print error exception.
     *
     C     prterr        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'PRTERR  '    trsubr
413aAC                   exsr      zztrck
CBIeAC                   if        client = Cheney and
CBIeAC                             ($ptruk = @wlcll or $ptruk = @sdsvc or
CBIeAC                              $ptruk = @dmges)
CBIeAC                   goto      endPrt
CBIeAC                   endif
410aAC                   if        operpt <> 'N'  and
414aAC                             ophpwc = 'N'  or
414aA*
414aAC                             operpt <> 'N'  and
414aAC                             ophpwc = 'Y'  and
414aAC                             $potyp <> 'W'
     *
     *  See if we should printer header.
     *
     C                   if        prflag <> *on  or
     C                             *in90
     C                   write     head1
     C                   if        *in90
     C                   write     head2
     C                   endif
WSTc C                   if        client = westside
WSTc C                   write     columnsw
WSTc C                   else
     C                   write     columns
WSTc C                   endif
     C                   eval      prflag = *on
     C                   eval      *in90 = *off
     C                   endif
     *
     *   Print detail line.
     *
WSTc C                   if        client = westside
WSTc C     keyodh        chain     ordh                               79
WSTc C                   if        *in79
WSTc C                   eval      ohcord = 0
WSTc C                   eval      ohcnam = *blanks
WSTc C                   else
WSTc C                   move      ohcnam        cusnam
WSTc C                   endif
WSTc C                   endif
WSTc C*
WSTc C                   if        client = westside
WSTc C                   write     detail1w
WSTc C                   else
     C                   write     detail1
WSTc C                   endif
414cAC                   write     detail2
410aAC                   endif
     *
CBIeMC     endPrt        endsr
     *----------------------------------------------------------------
410 A*
410 A*  SNDUSR  Notify user Will Call is ready to pick.
410 A*
410 AC     sndusr        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'SNDUSR  '    trsubr
413aAC                   exsr      zztrck
410 A*
410 AC                   eval      $muser = osuser
410 AC                   movel     msg(4)        $msgdt
410 AC                   eval      $puser = #user
410 AC                   eval      $pjob = #job
410 D*R                   Z-ADDOSCORD    $MCORD  70
410 AC                   move      oscord        $mcord
410 AC                   call      @usrms
410 AC                   parm                    $muser
410 AC                   parm                    $msgdt
410 AC                   parm                    $puser
410 AC                   parm                    $pjob
410 AC                   parm                    $mcord
410 A*
410 AC     kyosct        chain     ordslct                            77
410 AC                   if        not *in77
410 AC                   eval      osstat = '2'
410 AC                   update    osrec
410 AC                   endif
410 AC                   endsr
520aA*----------------------------------------------------------------
520aA*
520aA*  UNALC1  UnAllocate quantity from Normal and Brkdn 1.
520aA*
520aAC     unalc1        begsr
     C                   exsr      avail
     C                   eval      svqty2 = lwqalc
     *
     *   First, try to unallocate full cases
     *
     C                   dow       svqty2 >= itumq2  and
     C                             slalc1 > 0  and
     C                             itumq2 > 0
     C                   eval      slalc1 = slalc1 - 1
     C                   eval      svqty2 = svqty2 - itumq2
     C                   enddo
     *
     *   Then unallocate the remaining qty from the brkdn 1 qty
     *
     C                   dow       svqty2 > 0
     *
     *       If enough available, unallocate entire qty.
     *
     C                   if        svqty2 <= slalc2
     C                   sub       svqty2        slalc2
     C                   eval      svqty2 = 0
     C                   leave
     C                   endif
     *
     *       Not enough availalbe, break down a case and loop.
     *
     C                   if        slalc1 > 0  and
     C                             itumq2 > 0
     C                   eval      slalc1 = slalc1 - 1
     C                   add       itumq2        slalc2
     C                   iter
     C                   endif
     *
     *       Case not available, zero out allocated qty.
     *
     C                   eval      slalc2 = 0
     *
     C                   leave
     C                   enddo
     *
     *   Last, see if stock brkdn1 can be converted to cases.
     *
     C                   exsr      avail
     C                   dow       avail2 >= itumq2  and
     C                             slstk2 >= itumq2  and
     C                             itumq2 > 0
     C                   add       1             slstk1
     C                   eval      slstk2 = slstk2 - itumq2
     C                   eval      avail2 = avail2 - itumq2
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  UNALOC  Unallocate quantity from ITEMQTY file.
     *
411 A*    Revised to unallocate from Base item when item ordered
411 A*    is an Alias or Same Slot Breakdown item.
     *
     C     unaloc        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'UNALOC  '    trsubr
413aAC                   exsr      zztrck
     *
520aD**                   MOVE '*UNALLOC'$ACMD
     C                   eval      $aprg = #prog
     C                   eval      $atype = '*BATCH  '
     C                   eval      $awhse = $pwhse
411 AC                   if        ittype = 'A'  or
411 AC                             ittype = 'S'
411 AC                   eval      $aitem = #bitem
411 AC                   else
     C                   eval      $aitem = lwitem
411 AC                   endif
     C                   eval      $aqty1 = diff1
     C                   eval      $aqty2 = diff2
     C                   eval      $aqty3 = diff3
     *
     C                   call      'ADJQTY'
     C                   parm                    $acmd
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
     *
     C                   endsr
404 A*----------------------------------------------------------------
404 A*
404 A*  UPDDIF  Update files with allocated vs. picked differences.
404 A*
     C     upddif        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'UPDDIF  '    trsubr
413aAC                   exsr      zztrck
     *
     *  Loop through label records for route.
     *
     C     keylw         setll     worklbl5
     C                   dou       forevr <> forevr
     C     keylw         reade     worklbl5                               79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *     Ignore record if type is not 'O' or no difference.
414bA*      or if label is 'OUT' record.
     *
     C                   if        lwtype <> 'O'  or
     C                             lwqalc = lwqpck  or
416dA**         LWASL2    OREQ 'OUT'
415aAC                             lwasl2 = '***'  or
415bAC                             $potyp = 'W'  and
415bAC                             ophpwc = 'Y'
     C                   iter
     C                   endif
     *
     *     Calculate differences.
     *
     *
     C                   eval      difpck = lwqalc - lwqpck
     C     difpck        mult      lwucub        difcub
     C     difpck        mult      lwuwgt        difwgt
     *
     *     Update corresponding PLTSUM and PLTSTP records.
     *
     C     keyps4        setll     pltsum4
     C                   dou       forevr <> forevr
     C     keyps4        reade     pltsum4                                78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   if        lwpal# <> psplid
     C                   iter
     C                   endif
     *
406 AC                   eval      kyplid = psplid
     C                   eval      pspcs = pspcs - difpck
     C                   sub       difcub        pscube
     C                   eval      psswgt = psswgt - difwgt
     C                   update    psrec4
720aA*
720aA*       Update corresponding PLTSUM/PLTSTP DD2 Location records
720aA*
720aA /free
720cM    if tbEnhanced;
720aA      dsplid = psplid;
720aA      if dsplsq > 0;
720aA        dsplsq = 0;
720aA        chain (lwwhse: lwrte: lwszon: dsplid: 'O') pltsum8;
720aA        if %found(pltsum8);
720aa          ps8_pspcs -= difpck;
720aA          ps8_pscube -= difcub;
720aA          ps8_psswgt -= difwgt;
720aA          update psrec8;
720aA        endif;
720aA        chain (lwwhse: lwrte: dsplid: psrow: pscol: lwstop: 0) pltstp1;
720aA        if %found(pltstp1);
720aa          psspcs -= difpck;
720aA          psscub -= difcub;
720aA          pssswt -= difwgt;
720aA          update psrec8;
720aA        endif;
720aA      endif;
720aA    endif;
720aa /end-free
     *
520 A*    Update loader module files.
     *
530cDC**                 if        $potyp = 'W'  and
530cDC**                           $ptruk <> 'BREAKERS'  and
530cDC**                           $ptruk <> 'ADD-ONS '
530cDC**                 else
530cDC**                 exsr      loader
530cDC**                 endif
     *
     C     keypss        chain     pltstp1                            77
     C                   if        *in77 <> *on
     C                   eval      psspcs = psspcs - difpck
     C                   sub       difcub        psscub
     C                   eval      pssswt = pssswt - difwgt
     C                   update    pssrec
     C                   endif
     *
     C                   enddo
     *
404 A*
404 AC     1             occur     ds1
404 AC                   eval      dslbl# = lwlbl#
404 AC                   eval      dsfpck = difpck
404 AC                   eval      dsfcub = difcub
404 AC                   eval      dsfwgt = difwgt
404 AC                   move      dsrec         ary(1)
404 AC                   eval      lstary = 1
404 AC                   eval      lstmlt = 1
404 A*
404 AC     1             do        lstmlt        x
404 AC     x             occur     ds1
404 A*
404 AC     1             do        lstary        y
404 AC                   move      ary(y)        dsrec
404 AC                   eval      kylbl# = dslbl#
404 AC                   eval      svfpck = dsfpck
404 AC                   eval      svfcub = dsfcub
404 AC                   eval      svfwgt = dsfwgt
404 A*
404 AC     x             add       1             lstmlt
404 AC     lstmlt        occur     ds1
404 AC                   eval      lstary = 0
404 AC                   eval      ary = *blanks
     *
     *     Update corresponding merge label records.
     *
     C                   eval      diflft = svfpck
     *
     C     keylw7        setll     worklbl7
     C                   dow       forevr = forevr
     C     keylw7        reade     worklbl7                               78
     C                   if        *in78
     C                   leave
     C                   endif
404 A*
404 AC                   if        diflft = 0
404 AC                   leave
404 AC                   endif
404 A*
404 D*R                   SUB  DIFPCK    LWQPCK
404 D*R                   SUB  DIFCUB    LWCUBE
404 D*R                   SUB  DIFWGT    LWSWGT
     *
404 AC                   if        lwqpck >= svfpck
404 AC                   eval      nwfpck = svfpck
404 AC                   eval      nwfcub = svfcub
404 AC                   eval      nwfwgt = svfwgt
404 AC                   eval      lwqpck = lwqpck - svfpck
404 AC                   eval      lwcube = lwcube - svfcub
404 AC                   eval      lwswgt = lwswgt - svfwgt
404 AC                   eval      diflft = 0
404 AC                   else
404 AC                   eval      nwfpck = lwqpck
404 AC                   eval      nwfcub = lwcube
404 AC                   eval      nwfwgt = lwswgt
404 AC                   eval      svfpck = svfpck - lwqpck
404 AC                   eval      svfcub = svfcub - lwcube
404 AC                   eval      svfwgt = svfwgt - lwswgt
404 AC                   eval      lwqpck = 0
404 AC                   eval      lwcube = 0
404 AC                   eval      lwswgt = 0
404 AC                   eval      diflft = diflft - nwfpck
404 AC                   endif
     *
     C                   update    lwrec7
     *
     *        Update corresponding PLTSUM and PLTSTP records.
     *
     C     keyps4        setll     pltsum4
     C                   dou       forevr <> forevr
     C     keyps4        reade     pltsum4                                78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   if        lwpal# <> psplid
     C                   iter
     C                   endif
     *
406 AC                   eval      kyplid = psplid
404 D*R                   SUB  DIFPCK    PSPCS
404 D*R                   SUB  DIFCUB    PSCUBE
404 D*R                   SUB  DIFWGT    PSSWGT
404 AC                   eval      pspcs = pspcs - nwfpck
404 AC                   sub       nwfcub        pscube
404 AC                   eval      psswgt = psswgt - nwfwgt
     C                   update    psrec4
720aA*
720aA*       Update corresponding PLTSUM/PLTSTP DD2 Location records
720aA*
720aA /free
720cM    if tbEnhanced;
720aA      dsplid = psplid;
720aA      if dsplsq > 0;
720aA        dsplsq = 0;
720aA        chain (lwwhse: lwrte: lwszon: dsplid: 'O') pltsum8;
720aA        if %found(pltsum8);
720aa          ps8_pspcs -= nwfpck;
720aA          ps8_pscube -= nwfcub;
720aA          ps8_psswgt -= nwfwgt;
720aA          update psrec8;
720aA        endif;
720aA        chain (lwwhse: lwrte: dsplid: psrow: pscol: lwstop: 0) pltstp1;
720aA        if %found(pltstp1);
720aa          psspcs -= nwfpck;
720aA          psscub -= nwfcub;
720aA          pssswt -= nwfwgt;
720aA          update psrec8;
720aA        endif;
720aA      endif;
720aA    endif;
720aa /end-free
     *
520 A*    Update loader module files.
     *
530cDC**                 if        $potyp = 'W'  and
530cDC**                           $ptruk <> 'BREAKERS'  and
530cDC**                           $ptruk <> 'ADD-ONS '
530cDC**                 else
530cDC**                 exsr      loader
530cDC**                 endif
     *
     C     keypss        chain     pltstp1                            77
     C                   if        *in77 <> *on
404 D*R                   SUB  DIFPCK    PSSPCS
404 D*R                   SUB  DIFCUB    PSSCUB
404 D*R                   SUB  DIFWGT    PSSSWT
     C                   eval      psspcs = psspcs - nwfpck
     C                   sub       nwfcub        psscub
     C                   eval      pssswt = pssswt - nwfwgt
     C                   update    pssrec
     C                   endif
     *
     C                   enddo
     *
404 AC                   eval      dslbl# = lwlbl#
404 AC                   eval      dsfpck = nwfpck
404 AC                   eval      dsfcub = nwfcub
404 AC                   eval      dsfwgt = nwfwgt
404 AC                   add       1             lstary
404 AC                   eval      z = lstary
404 AC                   move      dsrec         ary(z)
     *
     C                   enddo
     *
404 AC     x             occur     ds1
     *
404 AC                   enddo
404 A*
404 AC                   enddo
     *
     C                   enddo
     *
     C                   endsr
406 A*----------------------------------------------------------------
406 A*
406 A*  UPDRPL  Update pallet # in WORKLBL8 replenishments if pallet was 0.
406 A*
406 AC     updrpl        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'UPDRPL  '    trsubr
413aAC                   exsr      zztrck
406 A*
406 A*
406 A*  Loop through labels for pallet# = 0.
406 A*
416 D**         KEYLW5    SETLLWORKLBL5
416 MC     keylw5        setll     label13
406 A*
406 AC                   dou       forevr <> forevr
406 A*
416 D**         KEYLW5    READEWORKLBL5                 78
416 MC     keylw5        reade     label13                                78
406 AC                   if        *in78
406 AC                   leave
406 AC                   endif
406 A*
406 A*     Only work with replenishment records.
406 A*
416 D**         LWTYPE    IFNE 'R'
416 MC                   if        lbtype <> 'R'
406 AC                   iter
406 AC                   endif
406 A*
406 A*     Update worklbl record with pallet #
406 A*
406 AC                   call      'OR636'
406 AC                   parm                    $pwhse
406 AC                   parm                    $prtid
416 D**                   PARM           LWITEM
416 MC                   parm                    lbitem
406 AC                   parm      0             $lpal#            7 0
406 AC                   parm      ' '           $lrtn
406 A*
406 A*
406 A*      Update pallet # and repeat loop.
406 A*
416 D**                   Z-ADD$LPAL#    LWPAL#
416 MC                   eval      lbpal# = $lpal#
416 D**                   UPDATLWREC
416 MC                   update    lbrec
406 A*
406 AC                   enddo
406 A*
406 AC                   endsr
730iA*----------------------------------------------------------------
730iA*  wrtDebug    Write out debug record
730iA*----------------------------------------------------------------
730iA
730iA /free
730iA  begsr wrtDebug;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdbrec;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  WRTODT  Write out order detail transaction record.
     *
     C     wrtodt        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'WRTODT  '    trsubr
413aAC                   exsr      zztrck
     C                   eval      otwhse = lwwhse
     C                   eval      otord = lword
     C                   eval      otseq = lwseq
     C                   eval      otitem = lwitem
     C                   eval      ottrn# = lwtrn#
417aAC                   eval      otlbl# = lwlbl#
417aAC                   eval      otemp# = 0
417aAC                   eval      otpck1 = 0
417aAC                   eval      otpck2 = 0
417aAC                   eval      otpck3 = 0
     C                   write     otrec                                49
     *
     C                   endsr
410 A*----------------------------------------------------------------
410 A*
410 A*  WRTSCT  Write out order selector record for RF will call.
410 A*
410 AC     wrtsct        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'WRTSCT  '    trsubr
413aAC                   exsr      zztrck
410 AC     keyodh        chain     ordh                               76
410 AC                   if        not *in76
410 AC                   eval      oscord = ohcord
410 AC                   else
410 AC                   eval      oscord = 0
410 AC                   endif
410 A*
410 AC                   eval      oswhse = $pwhse
410 AC                   eval      osrte = lwrte
410 AC                   eval      ostruk = $ptruk
410 AC                   eval      osotyp = $potyp
410 AC                   eval      osord = lword
410 AC                   eval      ostran = @ptrn#
410 AC                   eval      oszone = lzone
410 AC                   eval      osuser = lslcto
410 AC                   eval      osstat = *on
410 AC                   eval      osprty = 0
410 AC                   eval      osndte = today
410 AC                   time                    osntim
410 AC                   write     osrec                                49
410 A*
410 AC                   eval      kyuser = osuser
410 AC                   eval      kystat = osstat
410 AC                   eval      kyprty = osprty
410 AC                   eval      kyndte = osndte
410 AC                   eval      kyntim = osntim
410 AC                   eval      kyord = osord
410 AC                   endsr
     *----------------------------------------------------------------
     *
     *  WRTTRN  Write out current transaction.
     *
     C     wrttrn        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'WRTTRN  '    trsubr
413aAC                   exsr      zztrck
     *
     C                   select
     C                   when      curtyp = 'PP'
     C                   eval      @ptask = 'PIR   '
     C                   eval      @pstyp = 'P'
     C                   other
     C                   eval      @ptask = 'FIXED '
     C                   eval      @pstyp = 'F'
     C                   endsl
     *
     C                   call      @addtr
     C                   parm      '*CREATE '    @pcmd
     C                   parm                    #job
     C                   parm      curtrn        @ptrn#
     C                   parm                    @ptask
     C                   parm      $pwhse        @pwhse
     C                   parm      lstwdp        @pwhdp
     C                   parm                    @pstyp
     C                   parm      ttlcub        @pcube
     C                   parm      ttlwgt        @pswgt
     C                   parm      ttlpcs        @ppcs
     C                   parm      0             @paisl
     C                   parm      0             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      ' '           @prte
     C                   parm      $prtid        @ppo
     C                   parm      'S'           @pgrp1
     C                   parm      $potyp        @pgrp2
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     C                   endsr
FDIaA*----------------------------------------------------------------
FDIaA*
FDIaA*  WRTTRNFDI  Write out current special FDI transaction
FDIaA*
FDIaAC     wrttrnfdi     begsr

     *  Write out tracking record.

     C                   eval      trcode = '*PCK040 '
     C                   movel     'WRTTRNFD'    trsubr
     C                   exsr      zztrck

     *  Create transaction

     C                   eval      @ptask = 'FIXED '
     C                   eval      @pstyp = 'F'

     C                   call      @addtr
     C                   parm      '*CREATE '    @pcmd
     C                   parm                    #job
     C                   parm      fditrn        @ptrn#
     C                   parm                    @ptask
     C                   parm      $pwhse        @pwhse
     C                   parm      fdiwdp        @pwhdp
     C                   parm                    @pstyp
     C                   parm      fdicub        @pcube
     C                   parm      fdiwgt        @pswgt
     C                   parm      fdipcs        @ppcs
     C                   parm      0             @paisl
     C                   parm      0             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      ' '           @prte
     C                   parm      $prtid        @ppo
     C                   parm      'S'           @pgrp1
     C                   parm      $potyp        @pgrp2
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg

     *  Create corresponding 'L' PLTSUM record.

     C                   eval      pstype = 'L'
     C                   eval      psstp1 = 0
     C                   eval      psstp2 = 0
     C                   eval      pspcs  = fdipcs
     C                   eval      pscube = fdicub
     C                   eval      psswgt = fdiwgt
     C                   eval      psbcnt = 0
     C                   eval      pstrn# = fditrn
     C                   write     psrec
     *
     C                   endsr
WSTaA*----------------------------------------------------------------
WSTaA*  WSTTRN - Assign tran# to gen 1 records for WestSide
WSTaA*
WSTaA*    This routine is almost identical to the logic in the
WSTaA*    mainline, execpt that this uses PLTSUM10 instead of
WSTaA*    PLTSUM3 and only works with gen 1 records.
WSTaA*
WSTaAC     wsttrn        begsr
     *
730dAc                   if        curtrn <> 0
730dAc                   exsr      wrttrn
730dAc                   endif
     C                   eval      difflg = *off
720cDC**                 eval      kytype = 'O'
720cMC                   eval      kytype = tbPalletType
     C                   eval      pcount = 0
     C                   eval      curtrn = 0
     C                   eval      curpal = 0
     C                   move      *hival        lstcmp
     C                   move      *hival        lstzon
WSTaAC                   eval      lstcol = 0
     C     keyps3        setll     pltsum10
     C                   dow       forevr = forevr
     C     keyps3        reade     pltsum10                               79
     C                   if        *in79
     C                   leave
     C                   endif
650bA*
650bA*  Skip record if transaction number has already been posted.
650bA*
650bAC                   if        pstrn# <> 0
650bAC                   iter
650bAC                   endif
     *
     *    Loop if not gen 1
     *
     C                   if        psgen <> 1
     C                   iter
     C                   endif
     *
     *    Loop if nothing on pallet.
     *
     C                   if        pspcs = 0
     C                   iter
     C                   endif
406 A*
406 AC                   eval      kyplid = psplid
     *
     *    Get picking options for zone.
     *
     C                   if        psszon <> lstzon
     C                   eval      kyzone = psszon
     C                   exsr      getopt
     C                   eval      lstzon = psszon
     C                   eval      pcount = 0
410 A*  Get zone selector for RF will call
410 AC                   if        $potyp = 'W'  and
410 AC                             prodt = '*RF     '  and
410bAC                             oprfwc = 'Y'
410 AC                   exsr      getsct
410 AC                   endif
     C                   endif
     *
     *    Increment pallet count.
     *
     C                   if        pcount >= opfpal
     C                   eval      pcount = 1
     C                   else
     C                   add       1             pcount
     C                   endif
WSTaA*
WSTaA*    For WestSide, start new tran when column changes.
WSTaA*
WSTaAC                   if        lstcol <> pscol
WSTaCC                   eval      pcount = 1
WSTaAC                   eval      lstcol = pscol
WSTaAC                   endif
     *
     *    Get transaction number for pallet.
     *
     C                   if        pstrn# <> 0
     C                   eval      trntyp = '*EXIST  '
     C                   eval      curtrn = pstrn#
     C                   else
     C                   if        pcount = 1
     C                   eval      trntyp = '*NEW    '
     C                   exsr      newtrn
     C                   endif
     C                   endif
     *
     *    Update pallet with transaction number.
     *
     C                   eval      pstrn# = curtrn
     C                   update    psrec10
     *
520 A*    Update loader module files.
     *
530cDC**                 if        $potyp = 'W'  and
530cDC**                           $ptruk <> 'BREAKERS'  and
530cDC**                           $ptruk <> 'ADD-ONS '
530cDC**                 else
530cDC**                 exsr      loader
530cDC**                 endif
     *
     *    Pick items for pallet.
     *
     C                   exsr      pick
     *
     C                   enddo
     *
WSTaAC                   endsr
413aA*----------------------------------------------------------------
413aA*     ZZTRCK - Write tracking records to tracking file
413aA*
413aAC     zztrck        begsr
413aAC                   select
413aAC                   when      trcode = '*PCK001 '
413aAC                   movel     '*PICK'       trpcmd
413aAC                   eval      trprg = *blanks
413aAC                   eval      trpbat = $pbat
413aAC                   eval      trotyp = $potyp
413aAC                   eval      trrtid = $prtid
413aAC                   select
413aAC                   when      trerr = *off
413aAC                   eval      trpkst = tr80
413aAC                   when      trerr = *on
413aAC                   eval      trpkst = tr81
413aAC                   endsl
413aAC                   eval      trflpk = flgpck
413aAC                   eval      trfltk = flgtrk
413aAC                   eval      trdata = tr01ds
413aAC                   eval      trsqnr = *zeros
413aAC                   write     tr01rec
413aA*
413aAC                   when      trcode = '*PCK002 '
413aAC                   eval      trdata = opdata
413aAC                   eval      trsqnr = *zeros
413aAC                   write     tr02rec
413aA*
413aAC                   when      trcode = '*PCK040 '
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
413aAC                   when      trcode = '*PCK050 '
413aAC                   add       1             trsq50
413aA*
413aAC     keyodh        chain     ordh                               76
413aAC                   if        *in76
413aAC                   eval      ohord = *zeros
413aAC                   endif
413aA*
413aAC                   eval      trord = ohord
413aAC                   eval      trstop = ohstop
413aAC                   eval      tritem = lwitem
413aAC                   eval      trmsgt = 'S'
413aA*
413aAC                   select
413aAC                   when      trnbr = 'TR01'
413aAC                   eval      trerr = *on
413aAC                   eval      trdt50 = msg(1)
413aAC     trdt50        cat       tr13:2        trdt50
413aAC     trdt50        cat       lwwhdp:1      trdt50
413aAC     trdt50        cat       tr14:2        trdt50
413aAC     trdt50        cat       lwdisp:1      trdt50
413aA*
413aAC                   when      trnbr = 'TR02'
413aAC                   eval      trerr = *on
413aAC                   eval      trdt50 = msg(2)
413aAC     trdt50        cat       tr13:2        trdt50
413aAC     trdt50        cat       lwwhdp:1      trdt50
413aAC     trdt50        cat       tr14:2        trdt50
413aAC     trdt50        cat       lwdisp:1      trdt50
413aA*
413aAC                   when      trnbr = 'TR31'
413aAC                   eval      trerr = *on
413aAC                   eval      trdt50 = msg(3)
413aAC     trdt50        cat       tr07:2        trdt50
413aAC                   move      lwqalc        cvt5a
413aAC     trdt50        cat       cvt5a:1       trdt50
413aAC     trdt50        cat       tr10:2        trdt50
413aAC                   move      lwqpck        cvt5a
413aAC     trdt50        cat       cvt5a:1       trdt50
413aA*
413aAC                   when      trnbr = 'TR32'
413aAC                   eval      trdt50 = msg(3)
413aAC     trdt50        cat       tr08:2        trdt50
413aAC                   move      lwqalc        cvt5a
413aAC     trdt50        cat       cvt5a:1       trdt50
413aAC     trdt50        cat       tr11:2        trdt50
413aAC                   move      lwqpck        cvt5a
413aAC     trdt50        cat       cvt5a:1       trdt50
413aA*
413aAC                   when      trnbr = 'TR33'
413aAC                   eval      trdt50 = msg(3)
413aAC     trdt50        cat       tr09:2        trdt50
413aAC                   move      lwqalc        cvt5a
413aAC     trdt50        cat       cvt5a:1       trdt50
413aAC     trdt50        cat       tr12:2        trdt50
413aAC                   move      lwqpck        cvt5a
413aAC     trdt50        cat       cvt5a:1       trdt50
413aA*
413aAC                   when      trnbr = 'TR05'
413aAC                   eval      trdt50 = tr05
413aAC                   select
413aAC                   when      lwutyp = 'N'
413aAC     trdt50        cat       tr07:2        trdt50
413aAC                   when      lwutyp = '1'
413aAC     trdt50        cat       tr08:2        trdt50
413aAC                   when      lwutyp = '2'
413aAC     trdt50        cat       tr09:2        trdt50
413aAC                   endsl
413aAC                   move      lwqalc        cvt5a
413aAC     trdt50        cat       cvt5a:1       trdt50
413aA*
413aAC                   when      trnbr = 'TR15'
413aAC                   eval      trord = *zeros
413aAC                   eval      trstop = *zeros
413aAC                   eval      tritem = *blanks
413aAC                   eval      trdt50 = tr15
413aA*
413aAC                   when      trnbr = 'TR16'
413aAC                   eval      trord = *zeros
413aAC                   eval      trstop = *zeros
413aAC                   eval      tritem = *blanks
413aAC                   eval      trdt50 = tr16
413aA*
413aAC                   endsl
413aA*
413aAC                   eval      trdata = tr50ds
413aAC                   eval      trmsgn = trnbr
413aAC                   eval      trsqnr = trsq50
413aAC                   write     tr50rec
413aAC                   endsl
413aAC                   endsr
414cA*----------------------------------------------------------------
     *
414cA*  ZZXOPT   Get use extended description option
     *
414cAC     zzxopt        begsr
     *
414cA*   Get extended description option.
414cAC                   eval      uxflag = *off
414cAC                   eval      ocode = '*ITEMMNT'
     *
414cAC     opkey         chain     options                            79
414cAC                   if        not *in79
414cAC                   move      opdata        opdta2
414cAC                   if        opxdsc = 'Y'
414cAC                   eval      uxflag = *on
414cAC                   endif
414cAC                   endif
     *
414cAC                   if        uxflag = *on
414cAC     idkey         chain     itemdsc                            79
414cAC                   if        *in79
414cAC                   eval      ixdsc1 = *blanks
414cAC                   eval      ixdsc2 = *blanks
414cAC                   endif
414cAC                   endif
414cAC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**   Error messages
Slot does not exist.
Slot record was locked.
Not enough stock available.
Will call ready to pick.
**   OVRPRTF statment
OVRPRTF FILE(OR630PR) OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
