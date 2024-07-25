     *----------------------------------------------------------------
     *
     *  OPTIONSDS  Redefinition data structures for OPTIONS file
     *  23 March 1993
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
213 A*    05/20/96  DAS
     *      - Added *PATTERN option.
     *
405 A*    09/06/97  DAS  4.05
     *      - Added *SYSTEM option.
     *
409 A*    04/09/98  HNK/DAS 4.09
     *      - Added OPPCHM to receiving options.
     *      - Added OPPMIX to receiving options.
410 A*    09/29/98  RH   4.10
     *      - Added OPWRNC to system options.
     *      - Added OPRG1C to system options.
     *      - Added OPRG2C to system options.
410AA*    11/13/98  RH   4.10
     *      - Added *GENPICK option.
     *      - Added *CLOSE option.
410BA*    12/21/98  RH   4.10
     *      - Added OPRFWC to *GENPICK option
     *
411 A*    03/04/99  DAS  4.11
     *      - Added *FTP options
411 A*    05/25/99  RH   4.11
     *      - Add Import item from host field OPIMPI
     *      - Added Import Item options *IMPITEM
     *
412 A*    08/02/99  RH   4.12
     *      - Added OPICW Individual catch weight entry (Y,N)
     *
412 A*    08/19/99  MLB  4.12
     *      - Added new option to *SYSTEM; Allow multiple pick slots
     *        for fixed items (Y/N). Field OPMPCK
     *      - Added new option to *RCVLBL; Assign pick slots auto-
     *        matically for fixed items (Y/N). Field OPAPCK
     *
413 A*    10/05/99  MLB  4.13
     *      - Added new option to *SYSTEM; Number of days to keep
     *        receiving logs. Field OPRCDY
     *      - Added new option to *SYSTEM; Number of days to keep
     *        picking logs. Field OPPKDY
413aA*    12/20/99  MLB  4.13a
     *      - Added *DAYEND option.
413bA*    01/12/00  MLB  4.13b
     *      - Added *REPLEN option.
     *
413cA*    03/13/00  MLB  4.13c
     *      - Added OPNRSC Number of pallet sections to *GENPICK
     *        options.
     *
414 A*    10/09/00  DAS  4.14
     *      - Added new option to *RCVLBL; Force marking of all P.O.
     *        detail lines (Y/N). Field OPFRCM
414aA*    03/30/00  MLB  4.14a
     *      - Added OPHPWC Host pick Will Call (Y/N) to *GENPICK
     *        options.
414bA*    04/21/00  MLB  4.14b
     *      - Added OPRTHS, OPCRHS, OPPOHS, OPIAHS and OPMSHS to
     *        *SYSTEM options for number of weeks history to keep.
414dA*    07/17/00  MLB  4.14d
     *      - Added OPOQRP Order qty replenishments to *REPLEN
     *        options.
     *
415 A*    06/04/01  MLB  4.15
     *      - Added new record type *FEATURE.
     *
415aA*    07/27/01  DAS  4.15a
     *      - Added new record type *RFPUT
     *
415bA*    08/02/01  DAS  4.15b
     *      - Added new field OPPQTY to *RFPUT
     *
415cA*    07/27/01  MLB  4.15a
     *      - Added new field to *GENPICK. Allow Add-on's to be
     *        merged with Open Routes.
     *
415dA*    08/06/01  MLB  4.15b
     *      - Added new field to *GENPICK. Pallet number sequence.
     *
416 A*    09/24/01  DAS  4.16
     *      - Added option OPEXCK to *RCVLBL; Expiration date check.
     *      - Added option OPCWEN to *RCVLBL; Catch weight entry
     *      - Added option OPCWTP to *RCVLBL; Catch weight value type
     *      - Added option OPCWFR to *RCVLBL; Force cw entry
416aA*    10/19/01  MLB  4.16
     *      - Added new record type *RETURNS.
416bA*    10/29/01  RH   4.16b
416bA*      - Added option OPRFLB to *RETURNS; Force return label entry
416cA*    11/29/01  RH   4.16c
416cA*      - Added option OPREXQ to *RETURNS; Export Quick returns Y/N
416dA*    02/04/02  RH   4.16d
416dA*      - Added option OPRULB to *RETURNS; Use Label for PutawayY/N
416eA*    04/19/02  RH   4.16e
416eA*      - Added option OPEADJ to *GENPICK; Close out label withoutN
416eA*        adjustment, will allow slot to go negative.             N
     *
416fA*    11/16/01  DAS  4.16f
     *      - Added option record *ZEROVFY.
     *
416gA*    12/12/01  DAS  4.16g
     *      - Added option OPIPCK to *RCVLBL; Ignore existing pck slot
     *
416hA*    12/18/01  MLB  4.16h
     *      - Added 2 new fields to *REPLEN. OPRPEX, OPRPFI
416iA*    07/10/02  RH   4.16i
     *      - Added 8 new fields to *IMPITEM, ORNSLT, ORXDCK, ORBNBR
     *        ORBNAM, ORVNAM, ORBRND, ORLOT, ORLTRK.
     *
417 A*    04/11/03  MLB  4.17
     *      - Added 3 new fields to *RCVLBL. OPRUPC, OPRUPS and OPRUPF.
417aA*    04/14/03  MLB  4.17a
     *      - Added 1 new field to *REPLEN. OPLMTS.
417bA*    05/12/03  MLB  4.17b
     *      - Added new record to OPTIONS file. *DOCDOOR.
417cA*    06/26/03  MLB  4.17c
     *      - Added 1 new field to *RFPUT. OPMSCN.
417dA*    07/03/03  MLB  4.17d
     *      - Added 1 new field to *GENPICK. OPNOPK.
417eA*    11/22/02  MLB  4.17e
     *      - Added two new record types: *VIRTUAL,*LICENSE to support
     *        license plate/lot number tracking.
417fA*    12/02/02  MLB  4.16f
     *      - Added one new record type: *DATEOPT to support rules for
     *        updating expiration/entered dates into destination slot.
417gA*    07/21/03  MLB  4.17g
     *      - Added 1 new field to *LICENSE, OPTKSP.
417hA*    02/01/04  MLB  4.17h
     *      - Added 1 new field to *RCVLBL, OPMSPO.
417iA*    05/17/04  DAS  4.17i
     *      - Added new record type *VOICE.
417jA*    05/18/04  MLB  4.17j
     *      - Added 1 new field to *GENPICK. OPCLRF.
417kA*    07/14/04  RH   4.17k
     *      - Added new record type *DLYHIT for Daily Slot Hit Process
417kA*    08/19/04  MLB  4.17k
     *      - Added 1 new field to *GENPICK. OPRNRM
417lA*    08/25/04  DAS  4.17l
     *      - Added *TRACKSP options.
417mA*    08/21/04  RH   4.17m
     *      - Added 1 new field to *GENPICK. OPJITR
     *
500 A*    11/15/04  DAS  5.00
     *      - Redefined *LICENSE tracking options to be default
     *        tracking levels (L,M,H).
     *      - *LICENSE option OPLPTR no longer used. Re: Everything
     *        is tracked so there is no need for an option to turn
     *        it on and off. Item record will contain the level the
     *        item should be tracked at.
     *      - Removed option OPTKSP (Track all push back slot pos).
     *        Replaced by *TRACKSP option OPSPTR.
     *      - Added 1 new field to *LICENSE. OPSPLT
     *
500aA*    01/13/05  DAS  5.00a
     *      - Renamed OPSPLT to OPPSPL (Putaway split)
     *      - Added field OPTSPL (Transfer split) to *LICENSE.
     *
500b *    03/31/05  HNK  5.00b
     *      - Added field OPPSET Set summary label by pallet option to
     *        *GENPICK.
500cA*    08/18/05  MLB  5.00c
     *      - Enh: Revised *DATEOPT format to add two new options:
     *          OPRCVO - Receiving to overflow slot
     *          OPRTNO - Returns to overflow slot
     *        Changed text for two existing options:
     *          W1PARC - Receiving to pick slot
     *          W1PART - Returns to pick slot
500dA*    09/14/05  MLB  5.00d
     *      - Enh: Revised *VOICE format to add one new option:
     *          OPCRTR - Create RUNNER entries for shorts/outs.
500eA*    10/07/05  MLB  5.00e
     *      - Enh: Added new code for field W1JITR. Converted
     *        all letter codes to numbers. Updated *GENPICK options with
     *        new values. All previous 5.00 changes for W1JITR have been
     *        overwritten for clarity.
500fA*    10/28/05  MLB  5.00f
     *      - Enh: Remove Runner options from *GENPICK. Options being
     *        moved to new *RUNNER options record. Fields OPCLRF, OPRNRM.
500gA*    10/28/05  MLB  5.00g
     *      - Enh: Create new option record *RUNNER - Runner Flag options.
     *
500hA*    11/23/05  DAS  5.00h
     *      - Renamed OPUPDL fields to OPUPLV and OPUPLR in the
     *        *VOICE and *RUNNER options, respectively. Re: This way
     *        both sets of options can be used in the same program.
500iA*    12/22/05  MLB  5.00i
     *      - Enh: Added two new fields to *RUNNER options: OPRPCK -
     *        Print runner pick list and OPRLBL - Print Runner pick
     *        labels.
     *
500jA*    12/23/05  DAS  5.00j
     *      - Enh: Created *INTERLV options.
     *
500kA*    01/03/06  DAS  5.00k
     *      - Enh: Added new *VOICE options.
500lA*    01/13/06  MLB  5.00l
     *      - Enh: Revised *VOICE options to remove field OPFRPL since
     *        it was not used. Renamed OPFRPL to OPFCLR - Clear RUNNER
     *        flag if quantity still short/out.
500m *    01/18/06  RH   5.00m
     *      - Added field OPRFUC RF Pick verify item with UPC *GENPICK
     *      - Added field OPRFLC RF Pick verify item with license
     *        *GENPICK.
500nA*    04/13/06  RH   5.00n
     *      - Added 1 new field to *REPLEN. OPCQTY, check "To Slot"
     *        quantity during replen/letdown/transfer.
500oA*    02/15/06  JCJ  5.00o
     *      - Enh: add new *runner option (OPRBDU)
     *
510aA*    07/12/06  RH   5.10a
     *      - Added 1 new field to *REPLEN. OPBDRP, check for bulk
     *        drops.
510bA*    10/10/06  MLB  5.10b
     *      - Enh: Created *FTPIMP options.
510cA*    10/25/06  RH   5.10c
     *      - Added 1 new field to *SYSTEM. OPTBJQ, run truck builder
     *        on Job Que (Y/N).
510dA*    12/15/06  RH   5.10d
     *      - Enh: Created *COUNT Inventory count options
510eA*    12/29/06  RH   5.10e
     *      - Fix: Corrected OPEXCK description to 1=Allow, 2=Prevent
     *        3=Warn.
510fA*    03/03/07  DAS  5.10f
     *      - Fix: Created *REPACK options
510gA*    03/13/07  DAS  5.10g
     *      - Fix: Created *HARBOR options
510hA*    04/02/07  DAS  5.10h
     *      - Added USF option to *GENPICK
510iA*    05/22/07  RH   5.10i
     *      - Enh: Added scan UPC/Lic to add item for *COUNT options
     *        Added key item to add item for *COUNT options
510jA*    06/11/07  DAS  5.10j
     *      - Enh: Created *CHKDGT Check Digit options.
520aA*    06/04/08  DAS  5.20a  P#00094
     *      - Enh: Added field OPREAD to *CHKDGT options.
520bA*    08/31/08  DAS  5.20b
     *      - Enh: Added options *PODSYS, *POD1, *POD2.
520cA*    01/09/09  RBD  5.20c
     *      - Enh: Added option *LOADER.
520dA*    01/20/09  RBD  5.20d
     *      - Enh: Added four new fields to *RUNNER options:
     *        OPRSCN - Scan tran# or label# to start pick.
     *                 1=tran#, 2=label#.
     *        OPRVFS - Verify pick slot, Y/N.
     *        OPRVFQ - Verify qty found, Y/N.
     *        OPRLOA - Using loader module, Y/N.
520eA*    06/03/09  RBD  5.20e  P#00212
     *      - Enh: Added 5 more POD error message recipients.
     *
600aA*    06/05/09  DAS  6.00a
     *      - Enh: Added option *SLTFIFO.
     *        This replaces the use of *DATEOPT in ver 6.00.
610aA*    08/25/09  RH/GJA  6.10a
     *      - Enh: Added missed 5.20 change below
     *        5.20 Added new field OPRFSL - RF Pick Verify slot
     *
610aA*    04/13/10  GJA  6.10a
     *      - Enh: Added new field OPUCI - UCI usage
     *
610bA*    05/11/10  GJA  6.10b
     *      - Added 2 new field to *SYSTEM. OPICWR & OPWRNCR
610cA*    05/11/10  GJA  6.10c
     *      - Added 1 new field to *SYSTEM. OPISHS
530 A*    05/13/10  RBD  5.30
530 A*      - Added new field to *SYSTEM, OPTRAX.
530aA*    06/23/10  RBD  5.30a
530aA*      - Enh: Added option *TRAX.
530bA*    12/13/10  RBD  5.30b
530bA*      - Enh: Added several fields to option *TRAX.
640aA*    02/03/11  RBD  6.40a
640aA*      - Enh: Added several more fields to option *TRAX.
640bA*    07/05/11  RBD  6.40b
640bA*      - Enh: Added *TRAX options Icon Delivery and Double
640bA*        Click Icons.
640cA*    11/03/11  RBD  6.40c
640cA*      - Enh: Added *TRAX options Pallets Enabled and Cradle
640cA*        Upload Enabled.
640dA*    12/12/11  RBD  6.40d
640dA*      - Enh: Added *TRAX option Driver Assigned Before Download.
640eA*    01/18/12  JCJ  6.40e
640eA*      - Enh: Added new *SYSTEM options OPTAXR, OPCHKR, OPVOICE.
640eA*      - Enh: Added new *GENPICK options OPRBN1, OPRBN2, OPSUBT.
640fA*    01/27/12  RBD  6.40f
640fA*      - Enh: Added *TRAX option Bulk Items Enabled.
640gA*    02/16/12  RBD  6.40g
640gA*      - Enh: Added *TRAX option Display Empty Stops.
640hA*    03/01/12  LMC  6.40h
640hA*      - Enh: Added OPRSRT - Sort Replenishment Option.
640iA*    11/14/12  DAS  6.40i
640iA*      - Enh: Added Allow Virtual Overflow Slots to *VIRTUAL.
650aA*    06/17/13  JCJ  6.50a
650aA*      - Enh: Added Print Slot Barcode on Pick Label question.
650bA*    07/08/13  RBD  6.50b
650bA*      - Enh: Added *TRAX options :
650bA*             Save After Scan.
650bA*             Save Delay.
650bA*             Sync Date and Time.
650bA*             Left/Right Keys Enabled.
650bA*             GS1 Scanning.
650bA*             GS1 Unique.
650bA*             Scan Beep Volume.
650cA*    09/16/13  RBD  6.50c
650cA*      - Enh: Added *TRAX options :
650cA*        OPTRAG - Restart after get route. Y = yes, restart with no
650cA*                 prompt. P = prompt and allow driver to override.
650cA*                 N = does not restart.
650cA*        OPTRD  - Restart daily, Y/N.
650cA*        OPTRDT - Restart daily time, 0000 - 2345, in 15 min
650cA*                 increments.
650dA*    10/10/13  RBD  6.50d
650dA*      - Enh: Added *TRAX options :
650dA*        OPTRFP - Reader focus position, N=Near F=Far
650dA*        OPTRFM - Reader focus mode, A=Auto F=Fixed
650dA*        OPTNSR - Non scan reason prompt, Y or N
650dA*        OPTFBD - Filter by department, Y or N
650eA*    10/25/13  RTR  6.50e
650eA*      - Enh: Added *DBGINTF for Interface Debugging Options.
650fA*    11/04/13  RBD  6.50f
650fA*      - Enh: Added new record type *TRAX1. Added *TRAX1 options :
650fA*        OPTER  - Email receipt
650fA*        OPTREF - Receipt email from
650fA*                 Default: trax@DoNotReply.com
650fA*        OPTRES - Receipt email subject
650fA*                 Default: TraxPODSystemReceipt
650gA*    03/07/14  RBD  6.50g
650gA*      - Enh: Added *TRAX option :
650gA*        OPTDSF - Display stop flags before restart, Y/N
650gA*      - Enh: Added new record type *TRAX2. Added *TRAX2 options :
650gA*        OPTSBU - Use system suspend battery power timeout, Y/N
650gA*        OPTSB  - System suspend battery power timeout, default 5
650gA*        OPTSEU - Use system suspend external power timeout, Y/N
650gA*        OPTSE  - System suspend external power timeout, default 30
650gA*        OPTBBU - Use backlight off battery power timeout, Y/N
650gA*        OPTBB  - Backlight off battery power timeout, default 60
650gA*        OPTBEU - Use backlight off external power timeout, Y/N
650gA*        OPTBE  - Backlight off external power timeout, default 5
650h *    04/09/14  GJA  6.50h
650h *      - Enh: Added *LOADER option :
650h *        OPLDOR - Loading order, 0=Any,1=Std,2=Row/col,3=col
650h *        OPTLID - Speak trailer id, Y/N
650h *        OPRWCL - Speak row/column, Y/N
650h *        OPVYPL - Verify pallet position, Y/N
650i *    11/11/13  LMC  6.50i
650i *      - Enh: Added RF selection options to GENPICK
650iA*        OPRFQT  -  RF Pick Allow Qty Entry (Y,N)
650iA*        OPRFCS  -  RF Pick Allow Change Slot (Y,N)
650jA*    10/29/14  RBD  6.50j
650jA*      - Added new field OPSKPR to *REPLEN, skip if pick slot
650jA*        physical qty is greater than item replenishment level.
650kA*    03/02/15  RBD  6.50k
650kA*      - Added new field OPJITW to *REPLEN.  During specific slot
650kA*        repl if this option equals N don't bother checking for JIT's
650kA*        as the user does not want the JIT notification window.
650lA*    03/05/15  RBD  6.50l
650lA*      - Added new field OPVFYP to *LOADER, verify pallet label
650lA*        against route id and pallet on pick label.
700aA*    04/22/15  DAS  7.00a
     *      - Added *GENPICK options OPPMTA, OPMAXA and OPDOCK.
     *        In USF pos were 21-24, pos are now 23-26.
     *        Created for USF.
700b *    05/21/15  GJA  7.00b
     *      - Enh: Added Display last three digits of license.
700cA*    02/17/16  RBD  7.00c
     *      - Added new field OPADDO to *LOADER, auto define add-on
     *        routes Y/N. When a route goes to printed status and this
     *        option is Y check to see if a matching host route exists in
     *        RTEHED within the loader start and end times for the current
     *        day. If a match is found and it doesn't exist in TTMERG,
     *        then designate the one found in RTEHED as the parent, the one
     *        just pick/printed as the child and write both to TTMERG.
     *        If a match is found and it does exist in TTMERG, add the
     *        one just pick/printed as a child in TTMERG. This saves the
     *        user the manual task of defining add-ons through the Trax
     *        Merge Route Maintenance.  Of course the user may still
     *        maintain add-ons through the maintenance program if desired.
     *
700dA*    08/23/16  RBD  7.00d
     *      - Added new field OPEQIP to *LOADER, Y/N. If Y call Load
     *        Equip program from Merged Pallet Loading program.
     *      - Added new field OPBYPL to *LOADER, Y/N. If Y bypass the
     *        entry of quantity when loading equipment.
     *      - Added new field OPBYPR to *LOADER, Y/N. If Y bypass the
     *        entry of quantity when returning equipment.
710aA*    05/02/17  LMC  7.10a
     *      - Added new field OPMPLT to *RCVLBL, Y/N. Default to Y, if
     *        blank or Y, we allow multiple pallet receiving in GUI.
710bA*    07/20/17  LMC  7.10b
     *      - Added new field OPPEXP to *RCVLBL, Y/N. Default to Y, if
     *        blank or Y, we allow partial export in gui receiving.
     *
710cA*    10/10/17  RBD  7.10c
     *      - Added *TRAX2 options :
     *        OPTV12 - Default = N.  Y = create version 1.2 xml.
     *        OPTV20 - Default = N.  Y = create version 2.0 xml.
     *
710dA*    11/18/17  das  7.10d
     *      - Added *TRAX2 option OPTDIR, main IFS directory.
     *
710eA*    11/29/17  RBD  7.10e
     *      - Added *TRAX2 option OPTIU, IFS user.
     *
710fA*    12/19/17  LMC  7.10f
     *      - Added *RFPUT option OPISWN - warning for inactive slot
720aA*    05/30/18  LMC  7.20a
     *      - Added *GENPICK field OPRFUI - Scan individual upc for
     *        verification of every unit.
     *      - Added fields that were missing.
720bA*    06/07/18  LMC  7.20b
     *      - Added *GENPICK field OPRFZP - Zone Pickup - Y directed,
     *        N - no zone pickup, M - manual zone pickup
     *      - Added *GENPICK field OPRFUW - Auto load weight if found
     *        during individual upc scans.
720cA*    07/02/18  DAS  7.20c
     *      - Added *TRAX2 option OPTOSG.
720dA*    11/17/18  DAS  7.20d
     *      - Added *SYSTEM option OPTBPM (TruckBuilder processing method.
     *
730aA*    03/07/19  RBD  7.30a
     *      - Added *TRAX options OPTSOR, OPTODE, OPTODP, OPTONT, OPTOTP
     *        and OPTNSB.
     *      - Added *TRAX2 options OPTSVL, OPTSSP, OPTSSS, OPTSST, OPTMUL,
     *        OPTKPL, OPTSHL, OPTPRT, OPTSPK, OPTGPS, OPTMIN, OPTMET,
     *        OPTPWD, OPTOFF, OPTAUT, OPTPH1, OPTPH2, OPTCAM, OPTDIL
     *        and OPTDIP.
     *      - Added new record type *TRAX3 and option OPTURL.
     *
730bA*    05/30/19  LMC  7.30b
     *      - Added *COUNT options OPCDQT, OPCADJ, OPCCWV and OPCTMU  TP
730cA*    01/02/20  LMC  7.30c
     *      - Added *Voice options opgvfy. Also put previously added  TP
     *        fields into this DS.                                    TP
740aA*    03/25/20  LMC  7.40a
     *      - Added *GENPICK options oprvup.
     *      - Added *GENPICK options oprvsl.
     *      - Added *GENPICK options oprvcd.
740bA*    07/15/20  LMC  7.40b
     *      - Added *RCVLBL options OPLOTR, OPPSRA, OPPLTD, OPOSSA    TP
     *      - OPSQTO, OPBRKA, OPEXPE, OPSPN1, OPSPN2, OPSPN3          TP
740cA*    08/31/20  DAS  7.40c
     *      - Created option *PLTPRTY for auto pallet building priorities
     *
740dA*    09/22/20  RBD  7.40d
     *      - Added *GENPICK option opbarc.
     *
740e *    09/24/20  GJA  7.40e
     *      - Added *TRAX2 option optsyg.
     *
740f *    09/25/20  KDE  7.40f
     *      - Added field oplght
     *      - Added W1TBTYPE, W1TBCOL
     *      - Added W1PLTBL, W1PLTYPS
     *      - Additions to *REPLEN from over years missed
     *
740gA*    09/29/20  RBD  7.40g
     *      - Additions to *GENPICK which have been missed.
     *        Moved position of opbarc.
     *      - Only added fields to OPTIONSDSL.
     *
740hA*    10/29/20  RBD  7.40h
     *      - Added *TRAX option optraxinv.
     *      - Added *TRAX2 optsyg field spec (740e only added comment).
     *
750aA*    06/03/21  LMC  7.50a
     *      - Added *GENPICK OPRFQTCW
     *      - Added *GENPICK OPRFQTAS
     *      - Added *GENPICK OPRFSSSV
     *      - Added *GENPICK OPSPPS
     *      - Added *GENPICK OPSPATRN
     *      - Added *GENPICK OPSPPLBL
     *      - Added *GENPICK OPSPBTXT
     *      - Added *GENPICK OPSPPSH
     *      - Added *GENPICK OPSPPSS
750bA*    06/10/21  LMC  7.50b
     *      - Added *RETURN  OPPLTL
     *      found these two fields added in op250 but not here
     *      - OPREAD  -  Export as adjustments. (Y/N)
     *      - OPREAC  -  Adjustment code to use.
     *
750cA*    06/11/21  RBD  7.50c
     *      - Added *GENPICK option OPAUTS, Allow auto subs.
     *
750dA*    06/17/21  DAS  7.50d
     *      - Added *GENPICK OPSPPBA field for SelectPrime
     *
750eA*    07/07/21  RBD  7.50e
     *      - Added *RUNNER option OPSCNL, Scan short to loader
     *        required before clearing runner flag.
     *
750FA*    09/10/21  KDE  7.50f
     *      - Add option (optrna) for Assigning Selection Transactions
     *        On-Demand
     *      - Add option (opsrta) for Assigning Selection Transactions
     *        in a specific order
     *      - Add option (opsrte) for using Super Routes
     *
750gA*    12/13/21  LMC  7.50g
     *      - Add option opspck and opsbrd - used to control showing
     *        on gui po item list program
     *
750hA*    01/31/22  KDE  7.50h
     *      - Add option (opdckv) to indicate customer using Dockvue Module
     *
750iA*    03/10/22  LMC  7.50i
     *      - Added *GENPICK options oppspldl
     *      - Added *GENPICK options opspssn
     *      - Added *GENPICK options opautot
     *
760 A*    04/25/22  KDE  7.60
     *      - Add *SYSTEM (OPAEPF) Auto Assign per Pallet positions for
     *        equipment being used
     *      - Add *SYSTEM (OPAEPO) Open for use
     *      - Add *SYSTEM (OPAMRT) Auto Assign transactions from mixed
     *        routes
417bA*----------------------------------------------------------------
417bA*  *DOCDOOR -  Dock Door options
417bA*----------------------------------------------------------------
417bA*
417bA* Fields
417bA*
417bA*    OPATYP  -  Dock door assignment. 0=No assignment, 1=Auto, 2=Manual.
417bA*    OPLTYP  -  Dock door loading. 1=Single door, 2=By Department.
417bA*
417bA* Data structure
417bA*
417bAD opdata          ds
417bAD  opatyp                 1      1
417bAD  opltyp                 2      2
417bAD  optend               117    117
415 A*----------------------------------------------------------------
415 A*  *FEATURE  -  PIR Feature options.
415 A*----------------------------------------------------------------
415 A*
415 A* Fields
415 A*
415 A*    OPFEAT  -  PIR Installed feature.
740fA*    OPLGHT  -  Truck Build Full/Light code
740fA*    OPTBTYPE - TruckBuilder Type (S=Standard, E-Enhanced/Advanced, B=Both)
730aA*    OPTBCOL - TruckBuilder Columns (N=Std 2 columns, Y=3+ Columns)
740 A*    OPPLTBL - TruckBuilder Pallet Build Method (1=Std  2=Some Automation  3=More item ops)
740 A*    OPPLTYPS -TruckBuilder Pallet Types used
415 A*
415 A* Data structure
415 A*
415 AD opdata          ds
415 AD  opfeat                 1      1
640aAD  oplght                 2      4
730aAD  optbtype               5      5
730aAD  optbcol                6      6
740 AD  oppltbl                7      7
740 AD  oppltyps             107    116
415 AD  optend               117    117
     *----------------------------------------------------------------
     *  *PATTERN  -  Tie pattern options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPHANG  -  Pallet overhang.
     *    OPDINC  -  Dimension increment.
     *
     * Data structure
     *
     D opdata          ds
     D  ophang                 1      3  2
     D  opdinc                 4      6  2
     D  optend               117    117
     *----------------------------------------------------------------
    D*  *PICK  -  Picking options
    D*
    D*     11/28/94  DAS
    D*       - Changed OPFSTP to 2 digits from 1.
    D*
    D*     02/16/95  DAS
    D*       - Moved option from OPTIONS to OPTIOND in order to have
    D*         the options by department.
    D*
    D*----------------------------------------------------------------
    D*
    D* Fields
    D*
    D*    OPNXTP  -  Next pallet number.
    D*    OPBPCK  -  Bulk pick definition.
    D*    OPPCUB  -  Maximum cube for PIR.
    D*    OPFPAL  -  Pallets on fixed fork lift.
    D*    OPFCUB  -  Maximum cube per fixed pallet.
    D*    OPFSTP  -  Maximum stops per fixed pallet.
    D*    OPINCL  -  Include PIR in fixed cube.
    D*    OPSRCH  -  Number of previous pallets to search for space.
    D*
    D* Data structure
    D*
    DD opdata          ds
    DD  opnxtp                 1      7  0 inz(0)
    DD  opbpck                 8      9  0 inz(0)
    DD  oppcub                10     14  2 inz(0)
    DD  opfpal                15     15  0 inz(0)
    DD  opfcub                16     20  2 inz(0)
    D*I            0                        21  210OPFSTP
    DD  opincl                22     22
    DD  opsrch                23     24  0 inz(0)
    DD  opfstp                25     26  0 inz(0)
    DD  optend               117    117
     *----------------------------------------------------------------
     *  *PICKLBL  -  Picking label options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPCLVL  -  Qty level for combined labels.
     *    OPCWRB  -  Print combined label warning before.
     *    OPCWRA  -  Print combined label warning after.
     *    OPUWRB  -  Print unit of measure warning before.
     *    OPUWRA  -  Print unit of measure warning after.
     *    OPTEXT  -  Text for last line of label.
     *    OPERR   -  Error label ratio.
     *    OPCWGT  -  Catch weight label ratio.
     *    OPLPGM  -  Picking label program.
     *
     * Data structure
     *
     D opdata          ds
     D  opclvl                 1      3  0 inz(0)
     D  opcwra                 4      4
     D  opcwrb                 5      5
     D  opuwra                 6      6
     D  opuwrb                 7      7
     D  optext                 8     50
     D  operr                 51     52  0 inz(0)
     D  opcwgt                53     54  0 inz(0)
     D  oplpgm                55     64
     D  optend               117    117
     *----------------------------------------------------------------
     *  *RCVLBL  -  Receiving options
     *----------------------------------------------------------------
     *
217 A*    11/ 6/96  RH
     *      - Added OPPASL & OPPFRC.
221 A*    05/14/97  RH
     *      - Added OPPLCN
409 A*    04/09/98  HNK
     *      - Added OPPCHM
     *      - Added OPPMIX
412 A*    08/19/99  MLB
     *      - Added OPAPCK
414 A*    10/09/00  DAS
     *      - Added OPFRCM
416 A*    09/24/01  DAS
     *      - Added OPEXCK, OPCWEN, OPCWTP, OPCWFR
416gA*    12/12/01  DAS
     *      - Added OPIPCK
     *
417 A*    04/11/03  MLB
     *      - Added OPRUPC, OPRUPS, OPRUPF.
417hA*    02/01/04  MLB
     *      - Added OPMSPO.
     * Fields
     *
     *    OPLPGM  -  Receiving label program.
     *    OPUPCT  -  Ideal slot usage percentage.
     *    OPPDEF  -  PIR minimum number of slots priority.
     *    OPPBLD  -  PIR same build code priority.
     *    OPPACT  -  PIR same activity zone priority.
     *    OPFDEF  -  Fixed minimum number or slots priority.
     *    OPFASL  -  Fixed same aisle priority.
     *    OPFSID  -  Fixed same side priority.
     *    OPFLVL  -  Fixed highest level priority.
217 A*    OPPASL  -  PIR same aisle priority.
217 A*    OPPFRC  -  Force PIR same aisle priority.
221 A*    OPPLCN  -  Use generic license plates.
409 A*    OPPCHM  -  Check chimney (Y,N)
409 A*    OPPMIX  -  Allow mixed expiration dates in fixed home slot(Y,N)
412 A*    OPAPCK  -  Assign pick slots automatically for fixed items(Y,N)
414 A*    OPFRCM  -  Force marking of all P.O. detail lines (Y,N)
416 A*    OPEXCK  -  Expiration date check (1,2,3)
416 A*                What to do when exp date being rcvd comes
416 A*                earlier than existing overflow exp date ...
510eM*                  1 = Let it go through
510eM*                  2 = Prevent
510eM*                  3 = Warn user & log when overridden
416 A*    OPCWEN  -  Allow catch weight entry (1,2,3)
416 A*                  1 = Every receipt
416 A*                  2 = First receipt only
416 A*                  3 = Never
416 A*    OPCWTP  -  Catch weight value entered (1,2,3)
416 A*                  1 = User choice
416 A*                  2 = Average
416 A*                  3 = Total
416 A*    OPCWFR  -  Force catch weight entry (Y,N)
416gA*    OPIPCK  -  Ignore existing pick slots (Y,N)
417 A*    OPRUPC  -  Prompt user for Retail UPC during receiving? (Y,N)
417 A*    OPRUPS  -  Allow user to skip Retail UPC scan? (Y,N)
417 A*    OPRUPF  -  Require Retail UPC on file before receipt? (Y,N)
417hA*    OPMSPO  -  Allow single po attached to multiple Super P/Os? (Y/N)
710aA*    OPMPLT  -  Allow Gui Multiple Pallet Receiving    (Y,N)     (Y/N)
710bA*    OPPEXP  -  Allow Partial Export in gui Receiving  (Y,N)     (Y/N)
740bA*    OPLOTR  -  Lot required if lot item               (Y,N)     (Y/N)
740bA*    OPPSRA  -  Allow Pick slot receiving              (Y,L,N)   (Y/N)
740bA*    OPPLTD  -  DO NOT USE USE, USE OPMPLT INSTEAD
740bA*    OPOSSA  -  Allow offsite storage receipt          (Y,N)     (Y/N)
740bA*    OPSQTO  -  Show qty ordered during receiving      (Y,N)     (Y/N)
740bA*    OPBRKA  -  Allow breakdown qty to be received     (Y,N)     (Y/N)
740bA*    OPEXPE  -  Expiration date Error or Warning       (E,W)     (Y/N)
740bA*    OPSPN1  -  Spin pallet for license placement      (Y,N)     (Y/N)
740bA*    OPSPN2  -  Spin pallet length                               (Y/N)
740bA*    OPSPN3  -  Spin pallet text                                 (Y/N)
750gA*    OPSPCK  -  Show Pack Description for WEB receiving          (Y/N)
750gA*    OPSBRD  -  Show Brand name for WEB receiving                (Y/N)
     *
     * Data structure
     *
     D opdata          ds
     D  oplpgm                 1     10
     D  opupct                11     13  0
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
412 AD  opapck                26     26
414 AD  opfrcm                27     27
416 AD  opexck                28     28
416 AD  opcwen                29     29
416 AD  opcwtp                30     30
416 AD  opcwfr                31     31
416gAD  opipck                32     32
417 AD  oprupc                33     33
417 AD  oprups                34     34
417 AD  oprupf                35     35
417hAD  opmspo                36     36
710aAD  opmplt                37     37
710bAD  oppexp                38     38
740bAD  oplotr                39     39
740bAD  oppsra                40     40
740bAD  oppltd                41     41
740bAD  opossa                42     42
740bAD  opsqto                43     43
740bAD  opbrka                44     44
740bAD  opexpe                45     45
740bAD  opspn1                46     46
740bAD  opspn2                47     49  0
740bAD  opspn3                50     59
750gAD  opspck                60     60
750gAD  opsbrd                61     61
     D  optend               117    117
     *----------------------------------------------------------------
     *  *ITEMMNT  -  Item maintenance options.
     *----------------------------------------------------------------
     *
219 A*    03/05/97  RH
     *      - Added OPXDSC
     * Fields
     *
     *    OPSTYP  -  Default section type
     *    OPWHDP  -  Default warehouse department
     *    OPUM1   -  Default normal unit of measure
     *    OPDUM   -  Unit of measure for dimensions
     *    OPCUM   -  Unit of measure for cube
     *    OPCDIV  -  Divisor for cube
     *    OPCAUT  -  Automaticaly calculate cube when zero (Y/N)
     *    OPCWRN  -  Display cube warning (Y/N)
     *    OPCRNG  -  Display cube warning range percentage
     *    OPWUM   -  Unit of measure for weight
219 A*    OPXDSC  -  Use extended description (Y/N)
219 A*    OPHVY   -  Heavy items are greater than or equal to
     *
     * Data structure
     *
     D opdata          ds
     D  opstyp                 1      1
     D  opwhdp                 2      6
     D  opum1                  7      8
     D  opdum                  9     23
     D  opcum                 24     43
     D  opcdiv                44     52  2 inz(0)
     D  opcaut                53     53
     D  opcwrn                54     54
     D  opcrng                55     57  1 inz(0)
     D  opwum                 58     72
219 AD  opxdsc                73     73
     D  ophvy                 74     75  0 inz(0)
     D  optend               117    117
     *----------------------------------------------------------------
     *  *SLOT  -  Slot options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPPFMT  -  PIR section shelf label format.
     *    OPFFMT  -  Fixed section shelf label format.
     *    OPFSEQ  -  Fixed section picking sequence.
     *
     * Data structure
     *
     D opdata          ds
     D  oppfmt                 1      1
     D  opffmt                 2      2
     D  opfseq                 3      3
     D  optend               117    117
405 A*----------------------------------------------------------------
405 A*  *SYSTEM  -  System options.
405 A*----------------------------------------------------------------
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
610bD*****OPWRNC  -  Perform catch weight variance check (Y,N).
610bM*    OPWRNC  -  Check CW variance during selection closing (N,M,C,B)
410 A*    OPRG1C  -  Catch weight low variance percentage.
410 A*    OPRG2C  -  Catch weight high variance percentage.
411 A*    OPIMPI  -  Import item fields from host.(Y,N).
610bD*****OPICW   -  Individual catch weight entry (Y,N).
610bM*    OPICW   -  Check CW count during selection closing (N,M,C,B)
412 A*    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
413aA*    OPRCDY  -  Number of days to keep receiving logs.
413aA*    OPMPCK  -  Number of days to keep picking logs.
414bA*    OPRTHS  -  Number of weeks - exported routes to keep.
414bA*    OPCRHS  -  Number of weeks - exported customer rtns to keep.
414bA*    OPPOHS  -  Number of weeks - exported p/o's to keep.
414bA*    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
414bA*    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
510c *    OPTBJQ  -  Run Truck Builder on Job Que (Y,N).
510 A*    OPISHS  -  Number of weeks to keep history file
610aA*    OPUCI   -  Use UCI processing (Y,N)
610bA*    OPWRNCR -  Check CW variance during receiving closing (N,M,C,B)
610bM*    OPICWR  -  Check CW count during receiving closing (N,M,C,B)
530 A*    OPTRAX  -  Using TRAX module (Y,N).
640eA*    OPTAXR  -  Using TAXR module (Y/N).
640eA*    OPCHKR  -  Using CHKR module (Y/N).
640eA*    OPVOICE -  Using VOICE module (Y/N).
650aA*    OPSLOT  -  Print Slot barcode on Pick Label (Y/N).
700bA*    OPDSPL  -  Display last three digits of license (Y/N).
720dA*    OPTBPM  -  TruckBuilder processing method
720dA*                 1 = Standard TB Only (default when blank)
720dA*                 2 = Advanced TB Only
720dA*                 3 = User chooses
720dA*                 4 = Default to Standard, user can change
720dA*                 5 = Default to Advanced, user can change
750fA*    OPTRNA  -  Assign Selection Transactions On-Demand
750fA*    OPSRTA  -  Assign Selection Transactions On-Demand Sort Order
750fA*    OPSRTE  -  Use Super Routes
750fA*    OPTALL  -  Assign All Routes or Select Routes with Auto Assign
750hA*    OPDCKV  -  Using Dockvue module (Y/N).
760 A*    OPAEPF  -  Auto Assign in Pallet position priority
760 A*    OPAEPO  -  Auto Assign transactions that only match equipment
760 A*    OPAMRT  -  Auto Assign with mixed routes
     *
     * Data structure
     *
     D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
410 AD  opwrnc                 5      5
410 AD  oprg1c                 6      8  1
410 AD  oprg2c                 9     11  1
411 AD  opimpi                12     12
412 AD  opicw                 13     13
412 AD  opmpck                14     14
413aAD  oprcdy                15     15  0
413aAD  oppkdy                16     16  0
414bAD  oprths                17     19  0
414bAD  opcrhs                20     22  0
414bAD  oppohs                23     25  0
414bAD  opiahs                26     28  0
414bAD  opmshs                29     31  0
510cAD  optbjq                32     32
510 AD  opishs                33     35  0
610bAD  opuci                 36     36
610cAD  opwrncr               37     37
610cAD  opicwr                38     38
530 AD  optrax                39     39
640eAD  optaxr                40     40
640eAD  opchkr                41     41
640eAD  opvoice               42     42
650aAD  opslot                43     43
700bAD  opdspl                44     44
720dAD  optbpm                45     45
750fAd  opsrte                46     46
750fAd  optrna                47     47
750fAd  opsrta                48     48
750fAd  optall                49     49
750hAd  opdckv                50     50
760 Ad  opaepf                51     51
760 Ad  opaepo                52     52
760 Ad  opamrt                53     53
     D  optend               117    117
410aA*----------------------------------------------------------------
410aA*  *GENPICK -  General picking options.
410aA*----------------------------------------------------------------
410 A*
    D*
    D*     03/31/05  HNK
    D*       - OPPSET added.
410 A* Fields
410 A*
410 A*    OPERPT  -  Print exception (short) error report (Y,N).
410 A*    OPELBL  -  Print exception (short) labels (Y,N)
410BA*    OPRFWC  -  Using RF will call (Y,N).
413cA*    OPNRSC  -  Number of pallet sections (1-9).
414aA*    OPHPWC  -  Host pick Will Call (Y/N).
415cA*    OPMRGA  -  Merge Add-on order(s) with Open Routes.
415dA*    OPPLSQ  -  Pallet number sequence. 1=Unload, 2=Load.
416eA*    OPEADJ  -  Close short labels without adjustment (Y,N).
417dA*    OPNOPK  -  Pick items without pick slot as bulk pick? (Y/N)
500fD*    OPGPK1  -  <Not Used / Available>
500fD*    OPGPK2  -  <Not Used / Available>
417kA*               task has been assigned. (Y/N)
500fM*    OPJITR  -  Create JIT Letdown or JIT Replenishment
500fA*                 0=None. No replenishments are created.
500fA*                 1=Letdowns are created during Truck Builder
500fA*                   Pick/Print processing.
500fA*                 2=Priority Replenishments are created during
500fA*                   Truck Builder Pick/Print processing.
500fA*                 3=JIT Letdowns created when transaction is
500fA*                   checked out.
500fA*                 4=JIT Priority Replenishments created when
500fA*                   transaction is checked out.
500bD*    OPPSET  -  Print separate set summary label for each pallet.
500mA*    OPRFUC  -  RF Pick Verify item with UPC.
500mA*    OPRFLC  -  RF Pick Verify item with license.
510hA*    OPUSF1  -  USF Option: Allow merge items for stop to be split.
510hA*               across truck pallets.
610aA*    OPRFSL  -  RF Pick Verify slot (Y/N)
640eA*    OPRBN1  -  Round robin printing compatable (Y/N)
640eA*    OPRBN2  -  Round robin Type ing compatable (Y/N)
640eA*               1=Off
640eA*               2=By route
640eA*               3=By transaction
640eA*    OPSUBT  -  Allow Customer Item Substitution (Y/N)
650iA*    OPRFQT  -  RF Pick Allow Qty Entry (Y,N)
650iA*    OPRFCS  -  RF Pick Allow Change Slot (Y,N)
700aA*    OPPMTA  -  USF Option: Allow multi-truck assignments.
700aA*    OPMAXA  -  USF Option: Staged route selection limit.
700aA*    OPDOCK  -  USF Option: Dock door prompt choice.
720aA*    OPRFQO  -  RF with Qty over.
720aA*    OPRFPM  -  RF Pick Method.
720aA*    OPRPLT  -  Print Pallet Label.
720aA*    OPRFUI  -  Scan individual UPC for each unit.
720bA*    OPRFZP  -  Zone Pickup.
720bA*    OPRFUW  -  Auto load weight if found in individual upc
740gA*    OPPSEQ  -  Slot pick sequence
740aA*    OPRVUP  -  RF Location verification UPC
740aA*    OPRVSL  -  RF Location verification Slot
740aA*    OPRVCD  -  RF Location verification Check Digit
740gA*    OPCAD   -  Cust audit duration
740gA*    OPPMSC  -  Merge stops when cube less than value
740gA*    OPPSVH  -  When oppmsc true allow stop as highest on pallet
740gA*    OPPSVM  -  When oppmsc true allow stop as middle on pallet
740gA*    OPPSVL  -  When oppmsc true allow stop as lowest on pallet
740gA*    OPPISSV -  Ideal trailer side-to-side weight difference
740gA*    OPPISSP -  Ideal trailer side-to-side percent difference
740gA*    OPPMSSV -  Max trailer side-to-side weight difference
740gA*    OPPMSSP -  Max trailer side-to-side percent difference
740gA*    OPPFDB  -  Allow Freezer pallet at rear door
740dA*    OPBARC  -  Print tran and label barcodes
740gA*               1=Barcode 3 of 9
740gA*               2=Barcode 128
740gA*               3=Barcode PDF417
740gA*               9=None
750aA*    OPRFQTCW-  SelectPrime - allow Qty entry on cw items.
750aA*    OPRFQTAS-  SelectPrime - assume short from qty entry.
750aA*    OPRFSSSV-  SelectPrime - Same Slot skip Loc verification
750aA*    OPSPPS  -  SelectPrime - Auto display pallet Summary-82
750aA*    OPSPATRN-  SelectPrime - Auto assign transactions
750aA*    OPSPPLBL-  SelectPrime - Print pallet label on Belt Printer
750aA*    OPSPBTXT-  SelectPrime - Next Item breakdown warning text
750aA*    OPSPPSH -  SelectPrime - Print SetHed Label
750aA*    OPSPPSS -  SelectPrime - Print SetSum Label
740gA*               N=No
740gA*               B=with the Sethed
740gA*               E=with the pallet
750cA*    OPAUTS  -  Allow auto substitutions (Y/N)
750dA*    OPSPPBA -  SelectPrime - Print Before/After Pick (B/A)
750dA*               (entering qty, scanning uci)
750iA*    OPSPJP  -  SelectPrime - Pallet jack prefix
750iA*    OPSPSSN- SelectPrime - Same Slot/More Qty visual Notification
750iA*    OPSPPLDL-  SelectPrime - remove items from pick list as
750iA*                   they are picked.
750iA*    OPAUTOT - Auto assign truck during order import.
410 A*
410 A* Data structure
410 A*
410 AD opdata          ds
410 AD  operpt                 1      1
410 AD  opelbl                 2      2
410BAD  oprfwc                 3      3
413cAD  opnrsc                 4      4  0
414aAD  ophpwc                 5      5
415cAD  opmrga                 6      6
415dAD  opplsq                 7      7
416eAD  opeadj                 8      8
417dAD  opnopk                 9      9
500fD*                                      10  10 OPGPK1
500fD*                                      11  11 OPGPK2
417mAD  opjitr                12     12
500bAD  oppset                13     13
500mAD  oprfuc                14     14
500mAD  oprflc                15     15
510hAD  opusf1                16     16
610aAD  oprfsl                17     17
640eAD  oprbn1                18     18
640eAD  oprbn2                19     19
640eAD  opsubt                20     20
650iAD  oprfqt                21     21
650iAD  oprfcs                22     22
700aAD  oppmta                23     23
700aAD  opmaxa                24     25  0
700aAD  opmaxab               24     25
700aAD  opdock                26     26
720aAD  oprfqo                27     29  0
720aAD  oprfpm                30     30
720aAD  oprplt                31     31
720aAD  oprfui                32     32
720bAD  oprfzp                33     33
720bAD  oprfuw                34     34
740gAD  oppseq                35     35
740aAD  oprvup                36     36  0
740aAD  oprvsl                37     37  0
740aAD  oprvcd                38     38  0
740gAD  opcad                 39     40  0
740gAD  oppmsc                41     42  0
740gAD  oppsvh                43     43
740gAD  oppsvm                44     44
740gAD  oppsvl                45     45
740gAD  oppissv               46     50  0
740gAD  oppissp               51     53  0
740gAD  oppmssv               54     58  0
740gAD  oppmssp               59     61  0
740gAD  oppfdb                62     62
740gMD  opbarc                63     63
750aMD  oprfqtcw              64     64
750aMD  oprfqtas              65     65
750aMD  oprfsssv              66     66
750aMD  opspps                67     67
750aMD  opspatrn              68     68
750aMD  opspplbl              69     69
750aMD  opspbtxt              70     99
750aMD  opsppsh              100    100
750aMD  opsppss              101    101
750cAD  opauts               102    102
750dAD  opsppba              103    103
750iAD  opspjp               104    108
750iAD  opspssn              109    109
750iAD  opsppldl             110    110
750iAD  opautot              111    111
410 AD  optend               117    117
410aA*----------------------------------------------------------------
410aA*  *CLOSE   -  Transaction close options.
410aA*----------------------------------------------------------------
410 A*
410 A* Fields
410 A*
410 A*    OPEXCD  -  Exception labels picked - code.
410 A*    OPNSCD  -  Not enough stock to close transaction - code.
410 A*    OPDICD  -  Different item found in slot - code.
410 A*
410 A* Data structure
410 A*
410 AD opdata          ds
410 AD  opexcd                 1      2
410 AD  opnscd                 3      4
410 AD  opdicd                 5      6
410 AD  optend               117    117
510dA*----------------------------------------------------------------
510dA*  *COUNT   -  Inventory count options.
510dA*----------------------------------------------------------------
510dA*
510dA* Fields
510dA*
510dA*    OPCUPC  -  Scan UPC to confirm item counted Y/N
510dA*    OPCADD  -  RF add item in slot Y/N
510iA*    OPCSCN  -  RF scan UPC or Lic to add item Y/N
510iA*    OPCKIN  -  RF key in item to add item Y/N
510dA*    OPCCWT  -  Capture catch weight Y/N
730bA*    OPCDQT  -  Show current Inventory Y/N
730bA*    OPCADJ  -  Create Adjustment for 0 qty Diff Y/N
730bA*    OPCCWV  -  Check CW variance Y/N
730bA*    OPCTMU  -  RTC - Teams Used Y/N
510dA*
510dA* Data structure
510dA*
510dAD opdata          ds
510dAD  opcupc                 1      1
510dAD  opcadd                 2      2
510iAD  opcscn                 3      3
510iAD  opckin                 4      4
510iAD  opccwt                 5      5
730bAD  opcdqt                 6      6
730bAD  opcadj                 7      7
730bAD  opccwv                 8      8
730bAD  opctmu                 9      9
510dAD  optend               117    117
413aA*----------------------------------------------------------------
413aA*  *DAYEND  -  Day end processing options.
413aA*----------------------------------------------------------------
413aA*
413aA* Fields
413aA*
413aA*    OPSTR1  -  Sunday - Warehouse start time
413aA*    OPSTR2  -  Monday - Warehouse start time
413aA*    OPSTR3  -  Tuesday - Warehouse start time
413aA*    OPSTR4  -  Wednesday - Warehouse start time
413aA*    OPSTR5  -  Thursday - Warehouse start time
413aA*    OPSTR6  -  Friday - Warehouse start time
413aA*    OPSTR7  -  Saturday - Warehouse start time
413aA*    OPLTDT  -  Last transaction processed date
413aA*    OPLTTM  -  Last transaction processed time
413aA*    OPLODT  -  Last order processed date
413aA*    OPLOTM  -  Last order processed time
413aA*    OPWEEK  -  Current week number
413aA*    OPWKAV  -  Number of weeks for average
413aA*    OPDYAV  -  Day to compute averages  (1=Sun - 7=Sat)
413aA*
413aA* Data structure
413aA*
413aAD opdata          ds
413aAD  opstr1                 1      6  0
413aAD  opstr2                 7     12  0
413aAD  opstr3                13     18  0
413aAD  opstr4                19     24  0
413aAD  opstr5                25     30  0
413aAD  opstr6                31     36  0
413aAD  opstr7                37     42  0
413aAD  opltdt                43     50  0
413aAD  oplttm                51     56  0
413aAD  oplodt                57     64  0
413aAD  oplotm                65     70  0
413aAD  opweek                71     72  0
413aAD  opwkav                73     75  0
413aAD  opdyav                76     76  0
417kA*----------------------------------------------------------------
417kA*  *DLYHIT  -  Daily Slot Hit Process options.
417kA*----------------------------------------------------------------
417kA*
417kA* Fields
417kA*
417kA*    OPHSTR  -  Daily Slot Hit start time
417kA*    OPHWKS  -  # of weeks to keep history.
417kA*
417kA* Data structure
417kA*
417kAD opdata          ds
417kAD  ophstr                 1      6  0
417kAD  ophwks                 7      8  0
411 A*----------------------------------------------------------------
411 A*  *FTP      -  FTP options
411 A*----------------------------------------------------------------
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
     D opdata          ds
     D  opftp                  1      1
     D  opsrvr                 2     33
     D  opuser                34     48
     D  oppwd                 49     63
     D  oppath                64     95
     D  optend               117    117
510b *----------------------------------------------------------------
510b *  *FTPIMP   -  FTP Import options
510b *----------------------------------------------------------------
510b *
510b * Fields
510b *
510b *    OPIFTP  -  Use FTP for importing (Y,N)
510b *    OPISRV  -  FTP Import Server name
510b *    OPIUSR  -  FTP Import User id
510b *    OPIPWD  -  FTP Import Password
510b *    OPIPTH  -  Path for remote file
510b *
510b * Data structure
510b *
510b D opdata          ds
510b D  opiftp                 1      1
510b D  opisrv                 2     33
510b D  opiusr                34     48
510b D  opipwd                49     63
510b D  opipth                64     95
510b D  optend               117    117
510gA*----------------------------------------------------------------
510gA*  *HARBOR  -  Custom Harbor options
510gA*----------------------------------------------------------------
510gA*
510gA* Fields
510gA*
510gA*    OPCIGL  -  Use special CIG labels (Y,N)
510gA*    OPLSTL  -  Use special PCKLST label (Y,N)
510gA*
510gA* Data structure
510gA*
510gAD opdata          ds
510gAD  opcigl                 1      1
510gAD  oplstl                 2      2
510gAD  optend               117    117
411 A*----------------------------------------------------------------
411 A*  *IMPITEM  -  Import Item options.
     *----------------------------------------------------------------
     *
     *    Y = Maintained by Host, imported to FSWMS
     * Fields
     *
     *    OPITYP  -  Item type
     *    OPDESC  -  Item description
     *    OPWHDP  -  Warehouse department
     *    OPSTYP  -  Section type
     *    OPWHDP  -  Default warehouse department
     *    OPDESG  -  Designation
     *    OPACTV  -  Activity
     *    OPBLD   -  Build code
     *    OPVEN#  -  Vendor number
     *    OPVIT#  -  Vendor item number
     *    OPPDSC  -  Pack description
     *    OPUM1   -  Normal unit of measure
     *    OPUM2   -  Breakdown 1 unit of measure
     *    OPUMQ2  -  Breakdown 1 UM quantity
     *    OPFLG1  -  Allow Breakdown 1 Sale
     *    OPUM3   -  Breakdown 2 unit of measure
     *    OPUMQ3  -  Breakdown 2 UM quantity
     *    OPFLG2  -  Allow Breakdown 2 Sale
     *    OPULEN  -  Unit length
     *    OPUWDT  -  Unit width
     *    OPUHGT  -  Unit height
     *    OPCUBE  -  Cube/Unit
     *    OPSWGT  -  Shipping weight
     *    OPCWGT  -  Catch weight
     *    OPREPL  -  Replenish level
     *    OPFLGD  -  Date sensitive
     *    OPFLGB  -  Allow bulk pick
     *    OPSLIF  -  Shelf life days
     *    OPNDAY  -  Notice days
     *    OPTIE   -  Mfr. Tie
     *    OPHIGH  -  Mfr. High
     *    OPMFLG  -  Manufacturing date
     *    OPDDAY  -  Distributor days
     *    OPUDAY  -  End user days
     *    OPMDAY  -  Mfr. shelf life days
     *    OPMITM  -  Master item number
     *    OPCITM  -  Contract Base item #
416i *    OPNSLT  -  Non-slotted item
416i *    OPXDCK  -  Crossdock item
416i *    OPBNBR  -  Buyer number
416i *    OPBNAM  -  Buyer name
416i *    OPVNAM  -  Vendor name
416i *    OPBRND  -  Brand
416i *    OPLOT   -  Lot code item
416i *    OPLTRK  -  Track by license
     *
     * Data structure
     *
411 D*PDATA      DS
     D  opityp                 1      1
     D  opdesc                 2      2
     D  opwhdp                 3      3
     D  opstyp                 4      4
     D  opdesg                 5      5
     D  opactv                 6      6
     D  opbld                  7      7
     D  opven#                 8      8
     D  opvit#                 9      9
     D  oppdsc                10     10
     D  opum1                 11     11
     D  opum2                 12     12
     D  opumq2                13     13
     D  opflg1                14     14
     D  opum3                 15     15
     D  opumq3                16     16
     D  opflg2                17     17
     D  opulen                18     18
     D  opuwdt                19     19
     D  opuhgt                20     20
     D  opcube                21     21
     D  opswgt                22     22
     D  opcwgt                23     23
     D  oprepl                24     24
     D  opflgd                25     25
     D  opflgb                26     26
     D  opslif                27     27
     D  opnday                28     28
     D  optie                 29     29
     D  ophigh                30     30
     D  opmflg                31     31
     D  opdday                32     32
     D  opuday                33     33
     D  opmday                34     34
     D  opmitm                35     35
     D  opcitm                36     36
416i D  opnslt                37     37
416i D  opxdck                38     38
416i D  opbnbr                39     39
416i D  opbnam                40     40
416i D  opvnam                41     41
416i D  opbrnd                42     42
416i D  oplot                 43     43
416i D  opltrk                44     44
413bA*----------------------------------------------------------------
413bA*  *REPLEN  -  Replenishment options.
413bA*----------------------------------------------------------------
413bA*
413bA* Fields
413bA*
413bA*    OPRPLB  -  Replenishment basis (*AVGQTY, *ORDQTY).
414dA*    OPOQRP  -  Order qty replenishment (Y/N).
416hA*    OPRPEX  -  Allow replenishment on expired items.
416hA*               1=Allow, 2=Don't allow, 3=Warn
416hA*    OPRPFI  -  Allow replenishments out of FIFO order.
416hA*               1=Allow, 3=Warn
417aA*    OPLMTS  -  Limit Specific Slot replenishment program to
417aA*               to display only one overflow location at a
417aA*               time. (Y/N)
500nA*    OPCQTY  -  Check quantity of "To Slot" during replenish/
500nA*               letdown/transfer. (Y/N)
510aA*    OPBDRP  -  Check for Bulk Drops. (Y/N)
640hA*    OPRSRT  -  Sort Replenishment  (*DEMAND, *TOSLOT).
650jA*    OPSKPR  -  Skip if pick slot physical qty is greater than
650jA*               item replenishment level.
650kA*    OPJITW  -  During specific slot repl if this option = N don't
650kA*               bother checking for JIT's as the user does not want
650kA*               the JIT notification window.
740fA*    OPLQTY  -  Replenish pick slots that display less than X    t
740fA*               cases.                                           nt
740fA*    OPSSLCN -  Initiate Specific Slot Replenishment from License
740fA*               scan vs. Pick Slot
740fA*    OPRZST  -  Stop Type for DRIPRTYRPL to use when Pick Slot exist
740fA*               for both Store/Remote Location and Primary Warehouse
740fA*    OPCKDD  -  Check for Drop Pick Replenishments
413bA*
413bA* Data structure
413bA*
413bAD opdata          ds
413bAD  oprplb                 1      8
414dAD  opoqrp                 9      9
416hAD  oprpex                10     10
416hAD  oprpfi                11     11
417aAD  oplmts                12     12
500nAD  opcqty                13     13
510aAD  opbdrp                14     14
640hAD  oprsrt                15     24
650jAD  opskpr                25     25
650kAD  opjitw                26     26
740fAD  oplqty                27     28  0
740fAD  oplqtya               27     28
740fAd  opsslcn               29     29
740fAd  oprzst                30     31
740fAd  opckdd                32     32
414dAD  optend               117    117
415aA*----------------------------------------------------------------
415aA*  *RFPUT   -  RF Putaway options
415aA*----------------------------------------------------------------
415aA*
415aA* Fields
415aA*
415aA*    OPVRFY  -  Verify scanned slot for manual putaway (Y,N)
415bA*    OPPQTY  -  Verify pallet quantity (Y,N)
417cA*    OPMSCN  -  Allow multiple license/labels to be scanned during
417cA*               putaway? (Y/N)
710fA*    OPISWN  -  Allow warning override on inactive slot edit.    g
415aA*
415aA* Data structure
415aA*
415aAD opdata          ds
415aAD  opvrfy                 1      1
415bAD  oppqty                 2      2
417cAD  opmscn                 3      3
710fAD  opiswn                 4      4
415bAD  optend               117    117
510fA*----------------------------------------------------------------
510fA*  *REPACK  -  Repack options
510fA*----------------------------------------------------------------
510fA*
510fA* Fields
510fA*
510fA*    OPPADJ  -  Parent adjustment code
510fA*    OPWADJ  -  Parent waste adjustment code
510fA*    OPRADJ  -  Repack adjustment code
510fA*    OPRASL  -  Repack area aisle
510fA*
510fA* Data structure
510fA*
510fAD opdata          ds
510fAD  oppadj                 1      2
510fAD  opwadj                 3      4
510fAD  opradj                 5      6
510fAD  oprasl                 7      9
510fAD  optend               117    117
416aA*----------------------------------------------------------------
416aA*  *RETURNS -  Customer Returns options
416aA*----------------------------------------------------------------
416aA*
416aA* Fields
416aA*
416aA*    OPRQCH  -  Allow changes to return quantity. (Y,N).
416aA*    OPRQEC  -  Allow changes to qty if return exported. (Y/N)
416bA*    OPRFLB  -  Force return label entry. (Y/N)
416cA*    OPREXQ  -  Export Quick returns.(Y/N)
416dA*    OPRULB  -  Use label for putaway.(Y/N)
750bA*    OPREAD  -  Export as adjustments. (Y/N)
750bA*    OPREAC  -  Adjustment code to use.
750bA*    OPPLTL  -  Allow Pallet License.(Y/N)
416aA*
416aA* Data structure
416aA*
416aAD opdata          ds
416aAD  oprqch                 1      1
416aAD  oprqec                 2      2
416bAD  oprflb                 3      3
416cAD  oprexq                 4      4
416dAD  oprulb                 5      5
750bAD  opread                 6      6
750bAD  opreac                 7      8
750bAD  oppltl                 9      9
416aAD  optend               117    117
417lA*----------------------------------------------------------------
417lA*  *TRACKSP  -  Track slot position options
417lA*----------------------------------------------------------------
417lA*
417lA* Fields
417lA*
417lA*    OPSPTR  -  Track slot pallet position (Y/N)
417lA*    OPMRG   -  Putaway merge option
417lA*               1 = Only ask for pallet position.
417lA*               2 = Direct user step by step.
417lA*    OPRTN   -  Return pallet option
417lA*               1 = Assume user returns pallets in LOFI order.
417lA*               2 = Direct user step by step.
417lA*
417lA* Data structure
417lA*
417lAD opdata          ds
417lAD  opsptr                 1      1
417lAD  opmrg                  2      2
417lAD  oprtn                  3      3
417lAD  optend               117    117
416fA*----------------------------------------------------------------
416fA*  *ZEROVFY -  Zero verify options
416fA*----------------------------------------------------------------
416fA*
416fA* Fields
416fA*
416fA*    OPVFYV  -  Verify virtual slot using RF (Y,N)
416fA*
416fA* Data structure
416fA*
416fAD opdata          ds
416fAD  opvrfv                 1      1
416fAD  optend               117    117
417cA*
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
640iA*    OPVOVF  -  Allow Virtual overflow slots to be created (Y/N)
600iA*
417eA*
417eA* Data structure
417eA*
417eAD opdata          ds
417eAD  opvall                 1      1
417eAD  opvpck                 2      2
417eAD  opvslt                 3      3
417eAD  opvexp                 4      4
417eAD  opvend                 5      5
417eAD  opvsam                 6      6
417eAD  opvedf                 7      7
640iAD  opvovf                 8      8
417eAD  optend               117    117
417eA*
417eA*----------------------------------------------------------------
417eA*  *LICENSE  -  License Plate Tracking options
417eA*----------------------------------------------------------------
500 A*
500 A* Tracking Levels
500 A*
500 A*   Low     -  User is not asked for any extra info.
500 A*              All tracking is done in the background.
500 A*
500 A*   Medium  -  User may be asked to apply new license plate to
500 A*              a split quantity.
500 A*              Applying new license plate is optional.
500 A*
500 A*   High    -  User may be asked to apply new license plate to
500 A*              a split quantity.
500 A*              Applying new license plate is manditory.
500 A*              User may be asked to confirm license plate being
500 A*              used for task.
500 A*
500 A*----------------------------------------------------------------
500 A*
500 A* Split Putaway Quantity Options (OPPSPL)
500 A*
500aA*   This option comes into play when a user is putting a partial
500aA*   quantity into a slot. This could either be during Putaway,
500aA*   Replenishment or Transfer.
500aA*
500 A*   1  =  LP goes with first quantity put into a slot.
500 A*   2  =  LP goes with last quantity put into a slot.
500 A*   3  =  Ask user.
500 A*
500aA*----------------------------------------------------------------
500aA*
500aA* Split Transfer Quantity Options (OPTSPL)
500aA*
500aA*   This option comes into play when a user is doing a partial
500aA*   quantity transfer and will identify how to deal with the
500aA*   license plate for the quantity that stays in the From slot
500aA*   vs. the quantity that is being transfered.
500aA*
500aA*   1  =  LP stays with remaining quantity in From slot.
500aA*   2  =  LP goes with partial quantity being transfered.
500aA*   3  =  Ask user.
500aA*
500 A*----------------------------------------------------------------
417eA*
417eA* Fields
417eA*
500 M*    OPLPTR  -  Allow license plate tracking ** NOT USED **
500 M*    OPLPAL  -  Default for all other items (L,M,H).
500 M*    OPLPDS  -  Default for date sensitive items (L,M,H).
500 M*    OPLPLC  -  Default for lot code items (L,M,H).
500 M*    OPLPCW  -  Default for catchweight items (L,M,H).
500 D*    OPTKSP  -  Track push back slot positions *** REMOVED ***
500aM*    OPPSPL  -  Splitting Putaway quantity (see above)
500aA*    OPTSPL  -  Splitting Transfer quantity (see above)
417eA*
417eA* Data structure
417eA*
417eAD opdata          ds
417eAD  oplptr                 1      1
417eAD  oplpal                 2      2
417eAD  oplpds                 3      3
417eAD  oplplc                 4      4
417eAD  oplpcw                 5      5
500 D***                                     6   6 OPTKSP
500aMD  oppspl                 6      6
500aAD  optspl                 7      7
417eAD  optend               117    117
417eA*
417fA*----------------------------------------------------------------
417fA*  *DATEOPT  -  Expiration/Entered date options
417fA*----------------------------------------------------------------
417fA*
417fA* Fields
417fA*
417fA*    OPLTDN  -  Letdown transactions.  <1-3>
417fA*    OPODRP  -  On-demand replenishment transactions. <1-3>
417fA*    OPSLTF  -  Slot transfer transactions. <1-3>
500cM*    OPPARC  -  Receiving to pick slot. <1-3>
500cM*    OPPART  -  Returns to pick slot. <1-3>
500cA*    OPRCVO  -  Receiving to overflow slot. <1-3>
500cA*    OPRTNO  -  Returns to overflow slot.  <1-3>
417fA*
417fA*     Destination options:
417fA*       1=Use From Slot date.
417fA*       2=Use oldest date.
417fA*       3=Use From Slot date if To Slot available qty is zero.
417fA*
417fA*     Note: For Receiving/Returns, substitute date captured during
417fA*           receiving/returns processing for From Slot date.
417fA*
417fA* Data structure
417fA*
417fAD opdata          ds
417fAD  opltdn                 1      1
417fAD  opodrp                 2      2
417fAD  opsltf                 3      3
417fAD  opparc                 4      4
417fAD  oppart                 5      5
500cAD  oprcvo                 6      6
500cAD  oprtno                 7      7
417fAD  optend               117    117
417iA*----------------------------------------------------------------
417iA*  *VOICE  -  PIR Voice options (Y/N)
417iA*----------------------------------------------------------------
417iA*
417iA* Fields
417iA*
417iA*    OPINCP  -  Include pack description.
500dA*    OPCRTR  -  Create RUNNER entries for shorts/outs (Y/N)
500hM*    OPUPLV  -  Update Label with quantity picked during Voice
500gA*               selection (Y/N)
500hM*               NOTE: Any change to this field will cause OPUPLR
500gA*                     in the *RUNNER options record to be updated.
500gA*    OPVMRG  -  Create Runner entries for Merge records? (Y/N)
500gA*    OPFOUT  -  Create Runner entry after slot marked out. (Y/N)
500lM*    OPFCLR  -  Clear Runner flag if qty still short/out? (Y/N)
500lM*               NOTE: Any change to this field will cause OPCLRF
500lA*                     in the *RUNNER options record to be updated.
500kA*    OPVMLT  -  Allow multiple transaction (Y/N)
500kA*    OPVSPN  -  Speak pallet number (Y/N)
500kA*    OPVSPZ  -  Speak pallet zone (Y/N)
500kA*    OPVSLW  -  Speak large quantity warning (Y/N)
500kA*    OPVCEP  -  Confirm EACH pick (Y/N)
500kA*    OPVSSN  -  Speak stop number (Y/N)
500kA*    OPVCPZ  -  Confirm pallet zone (Y/N)
730cA*    OPESTP  -  Extended stop number length (2-5)
730cA*    OPGVFY  -  Voice Location Verification
417iA*
417iA* Data structure
417iA*
417iAD opdata          ds
417iAD  opincp                 1      1
500dAD  opcrtr                 2      2
500hMD  opuplv                 3      3
500gAD  opvmrg                 4      4
500gAD  opoutf                 5      5
500lMD  opfclr                 6      6
500kAD  opvmlt                 7      7
500kAD  opvspn                 8      8
500kAD  opvspz                 9      9
500kAD  opvslw                10     10
500kAD  opvcep                11     11
500kAD  opvssn                12     12
500kAD  opvcpz                13     13
730cAD  opestp                14     14
730cAD  opgvfy                15     15
417iAD  optend               117    117
500gA*
500gA*----------------------------------------------------------------
500gA*  *RUNNER  -  PIR Runner Flag Options
500gA*----------------------------------------------------------------
500gA*
500gA* Fields
500gA*
500gA*    OPCRTM  -  Create Manual Runner entries for shorts/outs (Y/N)
500hM*    OPUPLR  -  Update Label with quantity shorted during manual
500gA*               flag entry (Y/N)
500hM*               NOTE: Any change to this field will cause OPUPLV
500gA*                     in the *VOICE options record to be updated.
500gA*    OPRPLF  -  Replenish flagged items before print report? (Y/N)
500gA*               & create Priority Replenishment if necessary.
500gA*    OPMRGF  -  Create Runner entries for Merge records? (Y/N)
500gA*    OPCLRF  -  Clear Runner flags if qty still short/out? (Y/N)
500gA*    OPRNRM  -  Send break message to user when new Runner
500gA*               task has been assigned. (Y/N)
500gA*    OPCLSF  -  Update Label quantity at flag close (Y/N).
500gA*    OPOUTF  -  Create Runner entry after slot marked out. (Y/N)
500iA*    OPRPCK  -  Print Runner pick list. (Y/N)
500iA*    OPRLBL  -  Print Runner pick labels. 0=No, 1=full size Zebra
500iA*               printer, 2=Belt printer
500oA*    OPRBDU  -  Allow shorts to be filled with breakdown units (Y/N).
520dA*    OPRSCN  -  Scan tran# or label# to start pick.
520dA*                 1=tran#, 2=label#.
520dA*    OPRVFS  -  Verify pick slot, Y/N.
520dA*    OPRVFQ  -  Verify qty found, Y/N.
520dA*    OPRLOA  -  Using loader module, Y/N.
750eA*    OPSCNL  -  Scan short to loader required before
750eA*               clearing runner flag, Y/N.
500gA*
500gA* Data structure
500gA*
500gAD opdata          ds
500gAD  opcrtm                 1      1
500hMD  opuplr                 2      2
500gAD  oprplf                 3      3
500gAD  opmrgf                 4      4
500gAD  opclrf                 5      5
500gAD  oprnrm                 6      6
500gAD  opclsf                 7      7
500gAD  opoutf                 8      8
500iAD  oprpck                 9      9
500iAD  oprlbl                10     10
500oAD  oprbdu                11     11
520dAD  oprscn                12     12
520dAD  oprvfs                13     13
520dAD  oprvfq                14     14
520dAD  oprloa                15     15
750eAD  opscnl                16     16
500gAD  optend               117    117
500jA*
500jA*----------------------------------------------------------------
500jA*  *INTERLV -  Interleaving Options
500jA*----------------------------------------------------------------
500jA*
500jA* Fields
500jA*
500jA*    OPINTL  -  Allow interleaving (Y/N).
500jA*    OPMAXR  -  Maximum number of replenishments allowed.
500jA*
500jA*    OPFSAB  -  From slot - Aisles before current aisle.
500jA*    OPFSAA  -  From slot - Aisles after current aisle.
500jA*    OPFSBB  -  From slot - Bays before current location.
500jA*    OPFSBA  -  From slot - Bays after current location.
500jA*
500jA*    OPTSAB  -  To slot - Aisles before current aisle.
500jA*    OPTSAA  -  To slot - Aisles after current aisle.
500jA*    OPTSBB  -  To slot - Bays before current location.
500jA*    OPTSBA  -  To slot - Bays after current location.
500jA*
500jA* Data structure
500jA*
500jAD opdata          ds
500jAD  opintl                 1      1
500jMD  opmaxr                 2      3  0
500jAD  opfsab                 4      5  0
500jAD  opfsaa                 6      7  0
500jAD  opfsbb                 8     10  0
500jAD  opfsba                11     13  0
500jAD  optsab                14     15  0
500jAD  optsaa                16     17  0
500jAD  optsbb                18     20  0
500jAD  optsba                21     23  0
500jAD  optend               117    117
510jA*----------------------------------------------------------------
510jA*  *CHKDGT  -  Check digit options.
510jA*----------------------------------------------------------------
510jA*
510jA* Fields
510jA*
510jA*    OPCOD#  -  Number of check digit codes per slot (1,2,3)
510jA*    OPDGT#  -  Maximum number of digits per code  (2,3)
510jA*    OPIDC1  -  Code 1 identifier
510jA*    OPIDC2  -  Code 2 identifier
510jA*    OPUNU2  -  Unused
510jA*    OPIDC3  -  Code 3 identifier
510jA*    OPUNU3  -  Unused
510jA*    OPIDD1  -  Digit 1 identifier
510jA*    OPIDD2  -  Digit 2 identifier
510jA*    OPIDD3  -  Digit 3 identifier
510jA*    OPRCOD  -  Current code to read (S=Single,R=Random)
510jA*    OPRCD1  -  Use code 1 for current reading (Y,N)
510jA*    OPRCD2  -  Use code 2 for current reading (Y,N)
510jA*    OPRCD3  -  Use code 3 for current reading (Y,N)
510jA*    OPRORD  -  Current read order (S=Single, R=Random)
510jA*    OPRLCR  -  Use read order Left/Center/Right (Y,N)
510jA*    OPRRCL  -  Use read order Right/Center/Left (Y,N)
510jA*    OPRLRC  -  Use read order Left/Right/Center (Y,N)
510jA*    OPRRLC  -  Use read order Right/Left/Center (Y,N)
510jA*    OPRCLR  -  Use read order Cener/Left/Right  (Y,N)
510jA*    OPRCRL  -  Use read order Cener/Right/Left  (Y,N)
520aA*    OPREAD  -  Number of digits user reads for codes
520aA*               less than 100.
510jA*
510jA* Data structure
510jA*
510jAD opdata          ds
510jAD  opcod#                 1      1  0
510jAD  opdgt#                 2      2  0
510jAD  opidc1                 3      8
510jAD  opidc2                 9     14
510jAD  opunu2                15     16
510jAD  opidc3                17     22
510jAD  opunu3                23     24
510jAD  opidd1                25     30
510jAD  opidd2                31     36
510jAD  opidd3                37     42
510jAD  oprcod                43     43
510jAD  oprcd1                44     44
510jAD  oprcd2                45     45
510jAD  oprcd3                46     46
510jAD  oprord                47     47
510jAD  oprlcr                48     48
510jAD  oprrcl                49     49
510jAD  oprlrc                50     50
510jAD  oprrlc                51     51
510jAD  oprclr                52     52
510jAD  oprcrl                53     53
520aAD  opread                54     54  0
510jAD  optend               117    117
520bA*----------------------------------------------------------------
520bA*  *PODSYS  -  POD systeom options
520bA*----------------------------------------------------------------
520bA*
520bA* Fields
520bA*
520bA*    OPPHST  -  Days to keep POD export data (1-999)
520bA*
520bA* Data structure
520bA*
520bAD opdata          ds
     D  opphst                 1      3  0
     D  optend               117    117
520bA*----------------------------------------------------------------
520bA*  *POD1    -  POD options - Part 1
520bA*----------------------------------------------------------------
520bA*
520bA* Fields
520bA*
520bA*    OPPOPT  -  Export to POD (Y,N)
520bA*    OPPIFS  -  IFS folder
520bA*    OPPSRV  -  POD HTTP Server
520bA*    OPPUSR  -  POD HTTP Server User Id
520bA*    OPPPWD  -  POD HTTP Server Password
520bA*
520bA* Data structure
520bA*
520bAD opdata          ds
     D  oppopt                 1      1
     D  opppth                 2     33
     D  oppsrv                34     83
     D  oppusr                84     98
     D  opppwd                99    113
     D  optend               117    117
520bA*----------------------------------------------------------------
520bA*  *POD2    -  POD options - Part 2
520bA*----------------------------------------------------------------
520bA*
520bA* Fields
520bA*
520bA*    OPUSR1  -  Error message user 1
520bA*    OPUSR2  -  Error message user 2
520bA*    OPUSR3  -  Error message user 3
520bA*    OPUSR4  -  Error message user 4
520bA*    OPUSR5  -  Error message user 5
520eA*    OPUSR6  -  Error message user 6
520eA*    OPUSR7  -  Error message user 7
520eA*    OPUSR8  -  Error message user 8
520eA*    OPUSR9  -  Error message user 9
520eA*    OPUS10  -  Error message user 10
520bA*
520bA* Data structure
520bA*
520bAD opdata          ds
     D  opusr1                 1     10
     D  opusr2                11     20
     D  opusr3                21     30
     D  opusr4                31     40
     D  opusr5                41     50
520eAD  opusr6                51     60
520eAD  opusr7                61     70
520eAD  opusr8                71     80
520eAD  opusr9                81     90
520eAD  opus10                91    100
     D  optend               117    117
520cA*----------------------------------------------------------------
520cA*  *LOADER  -  Loader options.
520cA*----------------------------------------------------------------
520cA*
520cA* Fields
520cA*
520cA*    OPSTTM  -  Start time for a day's routes.
520cA*    OPENTM  -  End time for a day's routes.
650hA*    OPLDOR  -  Loading order.
650hA*    OPTLID  -  Speak trailer id.
650hA*    OPRWCL  -  Speak row/column.
650hA*    OPVYPL  -  Verify pallet position.
650lA*    OPVFYP  -  Verify pallet label against pick label.
700cA*    OPADDO  -  Auto define add-on routes Y/N.
700dA*    OPEQIP  -  Load Equip by zone Y/N.
700dA*    OPBYPL  -  Bypass entry of qty when loading equipment Y/N.
700dA*    OPBYPR  -  Bypass entry of qty when returning equipment Y/N.
520cA*
520cA* Data structure
520cA*
520cAD opdata          ds
     D  opsttm                 1      6  0
     D  opentm                 7     12  0
650hAD  opldor                13     13
650hAD  optlid                14     14
650hAD  oprwcl                15     15
650hAD  opvypl                16     16
650lAD  opvfyp                17     17
700cAD  opaddo                18     18
700dAD  opeqip                19     19
700dAD  opbypl                20     20
700dAD  opbypr                21     21
     D  optend               117    117
530aA*----------------------------------------------------------------
530aA*  *TRAX  -  TRAX options
530aA*----------------------------------------------------------------
530aA*
530aA* Fields
530aA*
530aA*    OPTHST  -  Days to keep TRAX export data (1-999)
530bA*    OPTSLI  -  Save log info
530bA*    OPTCWR  -  Catch weight required
530bA*    OPTOFT  -  Order number field type
530bA*    OPTDFT  -  Driver field type
530bA*    OPTRFT  -  Route field type
530bA*    OPTCAP  -  Capitalize input
530bA*    OPTDBL  -  Double click delivery
530bA*    OPTEKD  -  Entry key delivery
530bA*    OPTDAR  -  Delivery after return
530bA*    OPTIDB  -  Include item data base
530bA*    OPTBDA  -  Breakdowns allowed
530bA*    OPTGBD  -  Generic breakdown allowed
530bA*    OPTRTQ  -  Pre-trip questions
530bA*    OPTOTQ  -  Post-trip questions
530bA*    OPTCCE  -  Credit card enabled
530bA*    OPTSIG  -  Signature enabled
530bA*    OPTPIV  -  Print invoice
530bA*    OPTSDA  -  Send data after stop
530bA*    OPTWSP  -  Ws port
530bA*    OPTWSI  -  Ws IP
640aA*    OPTSVD  -  Save days
640aA*    OPTERT  -  Environment run time
640aA*    OPTEDV  -  Environment device
640aA*    OPTEOS  -  Environment OS
640aA*    OPTESW  -  Environment screen width
640aA*    OPTESH  -  Environment screen height
640aA*    OPTARE  -  Add return enabled
640bA*    OPTIDL  -  Icon delivery
640bA*    OPTDCI  -  Double click icons
640cA*    OPTPAL  -  Pallets enabled
640cA*    OPTCRA  -  Cradle upload enabled
640dA*    OPTDRV  -  Driver assigned before download
640fA*    OPTBUL  -  Bulk items enabled
640gA*    OPTEYS  -  Display empty stops
650bA*    OPTSAS  -  Save after scan
650bA*    OPTSDL  -  Save delay
650bA*    OPTSDT  -  Sync date and time
650bA*    OPTLRK  -  Left/right keys enabled
650bA*    OPTGSS  -  GS1 scanning
650bA*    OPTGSU  -  GS1 unique
650bA*    OPTSBV  -  Scan beep volume
650cA*    OPTRAG  -  Restart after get route.
650cA*    OPTRD   -  Restart daily.
650cA*    OPTRDT  -  Restart daily time.
650dA*    OPTRFP  -  Reader focus position.
650dA*    OPTRFM  -  Reader focus mode.
650dA*    OPTNSR  -  Non scan reason prompt.
650dA*    OPTFBD  -  Filter by department.
650gA*    OPTDSF  -  Display stop flags before restart.
730aA*    OPTSOR  -  Sort items by compartment Y/N.
730aA*    OPTODE  -  Customer on site delivery enable Y/N.
730aA*    OPTODP  -  Customer on site delivery verification period, 5-60.
730aA*    OPTONT  -  On truck picking Y/N.
730aA*    OPTOTP  -  Override truck picking Y/N.
730aA*    OPTNSB  -  No signee button on signature screen Y/N.
740hA*    OPTRAXINV - 1 = Print all invoices
740hA*                2 = Print pristine invoices only
740hA*                3 = Print non-pristine invoices only
740hA*                9 = Print no invoices
530aA*
530aA* Data structure
530aA*
530aAD opdata          ds
530aAD  opthst                 1      3  0
530bAD  optsli                 4      4
530bAD  optcwr                 5      5
530bAD  optoft                 6      6
530bAD  optdft                 7      7
530bAD  optrft                 8      8
530bAD  optcap                 9      9
530bAD  optdbl                10     10
530bAD  optekd                11     11
530bAD  optdar                12     12
530bAD  optidb                13     13
530bAD  optbda                14     14
530bAD  optgbd                15     15
530bAD  optrtq                16     16
530bAD  optotq                17     17
530bAD  optcce                18     18
530bAD  optsig                19     19
530bAD  optpiv                20     20
530bAD  optsda                21     21
530bAD  optwsp                22     26  0
530bAD  optwsi                27     41
640aAD  optsvd                42     43  0
640aAD  optert                44     47
640aAD  optedv                48     57
640aAD  opteos                58     67
640aAD  optesw                68     71  0
640aAD  optesh                72     75  0
640aAD  optare                76     76
640bAD  optidl                77     77
640bAD  optdci                78     78
640cAD  optpal                79     79
640cAD  optcra                80     80
640dAD  optdrv                81     81
640fAD  optbul                82     82
640gAD  opteys                83     83
650bAD  optsas                84     84
650bAD  optsdl                85     86  0
650bAD  optsdt                87     87
650bAD  optlrk                88     88
650bAD  optgss                89     89
650bAD  optgsu                90     90
650bAD  optsbv                91     91  0
650cAD  optrag                92     92
650cAD  optrd                 93     93
650cAD  optrdt                94     97  0
650dAD  optrfp                98     98
650dAD  optrfm                99     99
650dAD  optnsr               100    100
650dAD  optfbd               101    101
650gAD  optdsf               102    102
730aAD  optsor               103    103
730aAD  optode               104    104
730aAD  optodp               105    106  0
730aAD  optont               107    107
730aAD  optotp               108    108
730aAD  optnsb               109    109
740hAD  optraxinv            110    110
530aAD  optend               117    117
650fA*----------------------------------------------------------------
650fA*  *TRAX1    -  More TRAX options
650fA*----------------------------------------------------------------
650fA*
650fA* Fields
650fA*
650fA*    OPTER   -  Email receipt.
650fA*    OPTREF  -  Receipt email from.
650fA*    OPTRES  -  Receipt email subject.
650fA*
650fA* Data structure
650fA*
650fAD opdata          ds
650fAD  opter                  1      1
650fAD  optref                 2     61
650fAD  optres                62    116
650fAD  optend               117    117
650gA*----------------------------------------------------------------
650gA*  *TRAX2  -  More TRAX options
650gA*----------------------------------------------------------------
650gA*
650gA* Fields
650gA*
650gA*    OPTSBU  -  Use system suspend battery power timeout.
650gA*    OPTSB   -  System suspend battery power timeout.
650gA*    OPTSEU  -  Use system suspend external power timeout.
650gA*    OPTSE   -  System suspend external power timeout.
650gA*    OPTBBU  -  Use backlight off battery power timeout.
650gA*    OPTBB   -  Backlight off battery power timeout.
650gA*    OPTBEU  -  Use backlight off external power timeout.
650gA*    OPTBE   -  Backlight off external power timeout.
710cA*    OPTV12  -  Default = N.  Y = create V1.2 xml.
710cA*    OPTV20  -  Default = N.  Y = create V2.0 xml.
710dA*    OPTDIR  -  IFS main directory
710eA*    OPTIU   -  IFS user
720cA*    OPTOSIG -  Create Customer Order Signatures (Default = N)
720cA*               OPTOSG add for compatability with OPTIONSDS
730aA*    OPTSVL  -  Save login info Y/N.
730aA*    OPTSSP  -  Send stop pictures enable Y/N.
730aA*    OPTSSS  -  Send stop signatures enable Y/N.
730aA*    OPTSST  -  Send stop Trax log enable Y/N.
730aA*    OPTMUL  -  Multi route enable Y/N.
730aA*    OPTKPL  -  Keep log info Y/N.
730aA*    OPTSHL  -  Show log info Y/N.
730aA*    OPTPRT  -  Enable printer Y/N.
730aA*    OPTSPK  -  Enable speak Y/N.
730aA*    OPTGPS  -  Enable GPS Y/N.
730aA*    OPTMIN  -  GPS probe period minutes, greater than 0.
730aA*    OPTMET  -  GPS probe distance meters, greater than 0.
730aA*               Entered in yards, converted to meters.
730aA*    OPTPWD  -  Admin password.
730aA*    OPTOFF  -  Admin password encryption offset.
730aA*    OPTAUT  -  App auto update Y/N.
730aA*    OPTPH1  -  Company phone number.
730aA*    OPTPH2  -  Dispatch phone number for texting.
730aA*    OPTCAM  -  Camera barcode scanner Y/N.
730aA*    OPTDIL  -  Disable driver id login validation Y/N.
730aA*    OPTDIP  -  Disable driver password login validation Y/N.
740aA*    OPTSYG  -  Sygic Truck Integration Y/N.
650gA*
650gA* Data structure
650gA*
650gAD opdata          ds
650gAD  optsbu                 1      1
650gAD  optsb                  2      4  0
650gAD  optseu                 5      5
650gAD  optse                  6      8  0
650gAD  optbbu                 9      9
650gAD  optbb                 10     13  0
650gAD  optbeu                14     14
650gAD  optbe                 15     17  0
710cAD  optv12                18     18
710cAD  optv20                19     19
710dAD  optdir                20     39
710eAD  optiu                 40     49
720cAD  optosg                50     50
720cAD  optosig               50     50
730aAD  optsvl                51     51
730aAD  optssp                52     52
730aAD  optsss                53     53
730aAD  optsst                54     54
730aAD  optmul                55     55
730aAD  optkpl                56     56
730aAD  optshl                57     57
730aAD  optprt                58     58
730aAD  optspk                59     59
730aAD  optgps                60     60
730aAD  optmin                61     63  0
730aAD  optmet                64     69  0
730aAD  optpwd                70     89
730aAD  optoff                90     91  0
730aAD  optaut                92     92
730aAD  optph1                93    102  0
730aAD  optph2               103    112  0
730aAD  optcam               113    113
730aAD  optdil               114    114
730aAD  optdip               115    115
740hAD  optsyg               116    116
650gAD  optend               117    117
730aA*----------------------------------------------------------------
730aA*  *TRAX3    -  More TRAX options
730aA*----------------------------------------------------------------
730aA*
730aA* Fields
730aA*
730aA*    OPTURL  -  URL address where Trax app update is located. Must
730aA*               begin with http:// and server address.
730aA*
730aA* Data structure
730aA*
730aAD opdata          ds
730aAD  opturl                 1     60
730aAD  optend               117    117
600aA*----------------------------------------------------------------
600aA*  *SLTFIFO  -  Pick slot FIFO information options
600aA*----------------------------------------------------------------
600aA*
600aA* Fields
600aA*
600aA*    OPPFF   -  Pick slot, use info from first FIFO license.
600aA*    OPPLF   -  Pick slot, use info from last FIFO license.
600aA*    OPPFNF  -  Pick slot, use info from first non-expired FIFO license.
600aA*
600aA* Data structure
600aA*
600aAD opdata          ds
600aAD  oppff                  1      1
600aAD  opplf                  2      2
600aAD  oppfnf                 3      3
650eAD  optend               117    117
650eA*----------------------------------------------------------------
650eA*  *DBGINTF  -  Debug Interface Options
650eA*----------------------------------------------------------------
650eA*
650eA* Fields
650eA*
650eA*    OPDIIT  -  Debug Import Items Y/N.
650eA*    OPDISL  -  Debug Import Slots Y/N.
650eA*    OPDIPO  -  Debug Import POs Y/N.
650eA*    OPDIOR  -  Debug Import Orders Y/N.
650eA*    OPDIRP  -  Debug Import Repacks Y/N.
650eA*
650eA*    OPDEIT  -  Debug Export Items Y/N.
650eA*    OPDESL  -  Debug Export Slots Y/N.
650eA*    OPDEPO  -  Debug Export POs Y/N.
650eA*    OPDEOR  -  Debug Export Orders Y/N.
650eA*
650eA* Data structure
650eA*
650eAD opdata          ds
650eAD  opdiit                 1      1
650eAD  opdisl                 2      2
650eAD  opdipo                 3      3
650eAD  opdior                 4      4
650eAD  opdirp                 5      5
650eAD  opdeit                51     51
650eAD  opdesl                52     52
650eAD  opdepo                53     53
650eAD  opdeor                54     54
650eAD  optend               117    117
650eA*
740cA*----------------------------------------------------------------
740cA*  *PLTPRTY  -  Auto pallet build priorities
740cA*----------------------------------------------------------------
740cA*
740cA* Fields
740cA*
740cA*    opSplitItem  - No item splits
740cA*    opSplitStop  - No Stop splits
740cA*    opIdealCube  - Build to Ideal cube
740cA*    opMinPallets - Minimize pallets
740cA*    opSideWgt    - Balance weight side-to-side
740cA*    opZoneWgt    - Balance weight within Zone
740cA*    opZoneCube   - Balance cube within Zone
740cA*    opMinStops   - Minimize Stops on pallet
740cA*    opBulkhead   - Get to bulkhead
740cA*
740cA* Data structure
740cA*
740cAD opdata          ds
740cAD  opSplitItem            1      2  0
740cAD  opSplitStop            3      4  0
740cAD  opIdealCube            5      6  0
740cAD  opMinPallets           7      8  0
740cAD  opSideWgt              9     10  0
740cAD  opZoneWgt             11     12  0
740cAD  opZoneCube            13     14  0
740cAD  opMinStops            15     16  0
740cAD  opBulkhead            17     18  0
740cAD  optend               117    117
740cA*
