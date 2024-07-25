      /copy *libl/qcopysrc,hspecs
750fAH DFTACTGRP(*NO) ACTGRP(*CALLER)
520gA*----------------------------------------------------------------
520gA* For the cutter to work you need to ensure that the END label
520gA* ZPL code in LBLFMTD does not include the ^MMT command.
520gA*----------------------------------------------------------------
520gA
     *----------------------------------------------------------------
     *
     *  This program contains logic for writing to ZBRLOG files.
     *  All necessary code is marked with 510b/c.
     *  Data area ZBRLOG is used to control writing log records.
     *
     *  When a new field is added to FILLB2, also add it to FILLB2NAM.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  PFMT      Truck build picking labels - Label format method
     *
     *  --------------------------------------------------------------
     *     -----   B A S E   version   -----
     *
750gA*    See notes on dealing with custom client versions of PFMT
     *
     *  --------------------------------------------------------------
     *
     *  25 January 2011
     *  Jeffrey Jahnke
     *
     *  Created from PFMTBase version - 12/01/2011
     *
     *  Revisions have been moved to after the notes (5/13/21 DAS)
     *
     *----------------------------------------------------------------

750gA*----------------------------------------------------------------
750gA*  Notes on Custom Client Versions of PFMT
     *
     *   For customers that have a custom version of PFMT we want this
     *   standard/base version of PFMT to be called, then add custom
     *   code the the beginning of the program to divert to the custom
     *   version.
     *
     *   For exmaple, Cheney has not been merged into this version
     *   of PFMT. Therefore, we have renamed their custom version of
     *   PFMT to PFMTCB3, installed this program as the new PFMT
     *   program and added code to the beginning of the program to
     *   call PFMTCB3 then get out.
     *
     *   This will allow all custom versions of PFMT to reside in
     *   our standard libraries (i.e., PIRCUR, PIRENH...), which will
     *   also make using the appropriate PFMT program on our Dev box
     *   easier.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *    This program was designed to work with Zebra type printers
     *    in which a string of codes are sent to the printer to print
     *    a label.
     *
     *    The basic process is as follows:
     *
     *      1) Design the label using a PC program like Bar-One from
     *         the Zebra corporation. The label must be designed
     *         using the defined variable codes. These codes can
     *         be view using program LF150CL. In the label, all the
     *         fields should be defined as text (constant) fields and
     *         not as variable fields.
     *
     *      2) Create a text file containing the codes (script)
     *         need to print the label. With a Zebra printer, this
     *         would be ZPL code.
     *
     *      3) Upload the text file into file IMPLFMT.
     *
     *      4) Using the Set Maintenance program, import the script
     *         for the specific label format type.
     *
     *
     *    To use a specific label set within Truck Builder, enter
     *    the following for the label program name:
     *
     *                    PFMTssssss
     *
     *    where 'ssssss' is the name of the label set to use.
     *
     *----------------------------------------------------------------

750fA*----------------------------------------------------------------
750fA*  Notes on IFS printing
     *
     *    IFS printing was created to work with LabelAry to create
     *    a PDF file of labels.
     *
     *    When $pOutType is set to 'I', the program will generate
     *    multiple IFS files containing the labels that would have
     *    been printed.
     *
     *----------------------------------------------------------------

750fA*----------------------------------------------------------------
750fA*  Notes on LABELOUT file
     *
     *    The LABELOUT file was originally created to work with
     *    SelectPrime belt printing.
     *
     *    SelectPrime belt printing differs from voice belt printing
     *    in that voice belt printing would print all of the labels
     *    for a label # (e.g., 1 of 5, 2 of 5, ...), where SelectPrime
     *    may only print a single label (e.g., just label 1 of 5).
     *
     *    Therefore, it was decide that to make this process more
     *    efficient and less error prone, when labels are first printed
     *    during Pick & Print, we would write the belt printer labels
     *    to new file LABELDO, so all we will need to do is a simple
     *    chain to get the ZPL for a label.
     *
     *    This process assumes *PRINT is only sent during Pick & Print.
     *
     *    We also assume that when a client wants to use a belt printer
     *    a label set will exist for 'BLTccc', which corresponds to the
     *    standard label set 'ZBRccc', and the pick label format names
     *    will be identical within both sets (e.g., PICK, BULK, PALLET ...).
     *
     *    Routine fillb1 has been modified to make 2 passes. The first
     *    pass will work with the label set sent in $plset and work
     *    normally. The second pass will use the BLT set and only
     *    create LABELOUT records, it will not print BLT labels. If
     *    a BLT set doesn't exist, or a particular label format does
     *    not exist (e.g., SETHED), there will be no issue, as we
     *    will just end up jumping out of the loop because no record
     *    was found.
     *
     *    If $pOutType 'O' is sent with $pCmd *PRINT, no printing
     *    will take place and only LABELOUT recs will be created.
     *
     *    If $pOutType 'O' is sent with $pCmd *TEST1, *TEST2 or *BLTTEST,
     *    they will be written to LABELOUT and not be printed.
     *
     *    This process uses the IFS routines, which will also remove
     *    unnecessary Zebra commands from the label.
     *
     *    SelectPrime will call a new program to get the requested
     *    label(s) from the LABELOUT file
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Revisions
     *
510aA*    04/03/07  MLB  5.10a
     *      - Fix: Corrected length of DSPPCS to 5,0 from 3,0.
510bA*    06/01/07  RBD  5.10b
     *      - Enh:  Added files ZBRLOGF and ZBRLOGS.
     *      - Enh:  Revised to write out zebra label fields to the new
     *        files when flag is set in ZBRLOG data area.
510cA*    06/01/07  RBD  5.10c
     *      - Enh:  Revised zzzInzZbrLog to only clear records for zone.
510dA*    11/13/07  DAS  5.10d
     *      - Added label END to print after bulk pick and set summary
510eA*    11/08/07  MLB  5.10e
     *      - Made PALSUM fields DSPCUB, DSPPCS larger to match label.
510gA*    09/26/07  RBD  5.10g
     *      - Added command *PRTLBL.
     *      - Initialize $ldoor, was causing dec data error.
510hA*    09/26/07  RBD  5.10g
     *      - Revised to replace PLTSUM3 with PLTSUM3T when using
     *        full key to ensure a unique key.  With the advent of
     *        substitutes, PLTSUM3 no longer promised a unique key.
     *
510iA*    06/14/07  RBD  5.10b
     *      - Enh: *SYSTEM Opdata needed to be saved because of
     *        subsequent chain to OPTIONS in rev SFGh.
520 A*    01/18/08  RBD  5.20
     *      - Fix: Moved *PRTLBL logic after retrieval of PLTSUM3/T
     *        data; palsum data structure was not getting populated
     *        and in turn pallet and zone were not printing.
520aA*    05/02/08  RBD  5.20a
     *      - Fix: additional logic needed for 510h, PLTSUM3T rev's.
     *        Chg keyps to use the saved pstrn# as it was prior to
     *        calling PRTSEL.  Rev'd PRTSEL to ignore LABEL32X recs
     *        if pstrn# not equal to lsttrn.
520bA*    07/02/08  RBD  5.20b   P#00060
     *      - Enh: Added client custom code support to program.
520cA*    07/15/08  RBD  5.20c   P#00060
     *      - Added cmd *SHORT logic to print shorts pick labels
     *        for runners.
520dA*    07/17/08  RBD  5.20d   P#00060
     *      - Fix: Revised subr PRTLBL to use $PQTY rather
     *        than original label pick qty when $PCMD = *SHORT.
520eA*    12/14/08  JCJ  5.20e
     *      - Var 315 - Combined qty field to get qty fieldset summary
     *        values closer together.
     *      - fix dock door printing.
520fA*    12/20/08  JCJ  5.20f
     *      - Enh: Added new var to 185 Cust#/Cust Name
520gA*    03/14/08  DAS  5.20g
     *      - Added cutter logic.
520jA*    01/27/09  JCJ  5.20h
     *      - Added program getstop to retrieve 5 digit stop number.
520kA*    03/03/08  JCJ  5.20k
     *      - Enh: Revised to add aisle change flag.
520hA*    08/29/09  JCJ  5.20h
     *      - Enh: Add batch pick processing for pick label.
520iA*    08/31/09  JCJ  5.20i
     *      - Enh: Add *PICKLBA & *PICKLBB.
     *      - Enh: Updated *PICKLBL dspecs
     *      - Enh: Added cutter logic.
     *      - Fix: Revised INITSS to set SSDCNT = 1 if zero before start.
530 A*    12/17/09  JCJ  5.30
     *      - Enh: Add option to *PICKLBB. "Print PICK labels for
     *             Zone Pickup.
530 A*    12/16/09  JCJ  5.30
     *      - Revised to use TRUCKH to lookup Template code for
     *        Zone references.
530aA*    12/18/09  JCJ 5.30a
     *      - Revised to print Set summary label by pallet.
530bA*    01/22/10  JCJ 5.30b
     *      - Added additional 3 digit stop number processing.
530cA*    02/08/10  JCJ 5.30c
     *      - Changed to print date from ohmisc/ordh on pick label.
530dA*    09/17/09  RBD  5.30d
     *      - Fix: Moved *PRTLBL logic inside transaction loop. The
     *        palsum data structure is for one transaction, so when
     *        a single label was requested (cmd *PRTLBL or *SHORT)
     *        if it was not the last trans for its zone, the palsum
     *        wasn't holding the pallet data for that label.
530eA*    11/16/10  JCJ  5.30e
     *      - Fix: Added GETORDH & LBLEND to PRTLBL subroutine.
     *      - Enh: Added catch weight labels to sub item printing.
530fA*    11/22/10  JCJ  5.30f
     *      - Enh: Added Zone header label to sub item printing.
     *      - Fix: Key list for OPTIONZ, from truck to template.
530gA*    11/29/10  JCJ  5.30g
     *      - Enh: Switched Zone header label with Sub header label
     *        when printing substitution labels.
640 A*    08/23/11  MLB/JCJ  6.40
     *      - Fix: Revised program to chain to ITEMFLD file to retreive
     *        category code and if CLAMS, print ITL label.
640aA*    03/04/11  JCJ  6.40a
     *      - Fix: moved blanks to Variable 305 to prevent left over
     *             data from printing.
640bA*    03/15/11  JCJ  6.40b
     *      - Enh: Added ability to reprint by Transaction
640cA*    08/19/11  JCJ  6.40c
     *      - Enh: Added tote label processing.
640dA*    08/26/11  JCJ  6.40d
     *      - Enh: Revised to make 2 passes for the main line printing.
     *        The first pass is for the normal PSTYPE 'O' records.
     *        The second pass is for the special PSTYPE 'L' records.
     *      - Revised SETEND merge labels to ignore PSTYPE='L'
640eA*    09/07/11  JCJ  6.40e
     *      - Enh: Added juridiction code logic.
640fA*    09/07/11  JCJ  6.40f
     *      - Added piece count to XTOTE label.
640gA*    09/08/11  JCJ  6.40g
     *      - Added variable heading to Sethed label
     *      - Loaded zone description instead of item desc when zone
     *        is a tote.
640hA*    09/08/11  JCJ  6.40h
     *      - revised to use lbstop if GETSTOP returns 0 for stop
     *        number.
640iA*    09/10/11  JCJ  6.40i
     *      - Enh: Created Xtote3 label to reverse video route/stop
     *        field if last tote of zone.
640jA*    05/13/11  JCJ  6.40j
     *      - Enh: Print aisle change label before UOM change label.
640kA*    05/17/11  JCJ  6.40k
     *      - Fix: added UOM check for previous UOM label.  Prevents
     *        duplicate UOM warning labels.
640lA*    05/18/11  JCJ  6.40l
     *      - Fix: reactivate Combo before warning label.
640mA*    05/20/11  JCJ  6.40m
     *      - Fix: move printing of PALLET label prior to SETSUM.
640nA*    10/04/11  JCJ  6.40n
     *      - revised to use program cnttotes instead of cnttotes2.
640oA*    10/24/11  JCJ  6.40o
     *      - Enh:  add UOM to bulk pick label.
640pA*    11/02/11  JCJ  6.40p
     *      - Ehn:  Add Round Robin Printing by Transaction.
     *              Add call to ZH122cl to control Device Group Code
     *              entry.
     *              Add Round Robin Printing by Route option.
640qA*    12/14/11  JCJ  6.40q
     *      - Ehn:  replace CTWZONDEV file with zone template options
     *              OPDV3 & OPFM3.
640rA*    12/02/11  JCJ  6.40r
     *      - Ehn:  added variable 313 for Brand.
640sA*    01/12/12  JCJ  6.40s
     *      - Ehn:  added delect statement around LABEL32* read loops.
640tA*    01/22/12  JCJ  6.40t
     *      - Ehn:  no longer runroutine crtstp.  Not used anymore.
640uA*    01/22/12  JCJ  6.40u
     *      - Ehn:  renamed fields in KEY32a.  Mod SFGm requirement.
640vA*    01/23/12  MLB  6.40v
     *      - Fix: Revised routine, GETORDH to fix MCH1210 Receiver value
     *        too small to hold result error.
640wA*    02/02/12  JCJ  6.40w
     *      - Ehn:  This is CTWa mod converted to base code made
     *        available to all clients.
640xA*    02/02/12  JCJ  6.40x
     *      - Ehn:  Added missing system options.
640yA*    02/02/12  JCJ  6.40y
     *      - Ehn:  Added missing general pickng options.
640zA*    08/04/11  JCJ  6.40z
     *      - Added program GETSTAMP2 for zone CIG091.
642aA*    03/27/12  DAS  6.42a
     *      - For a loader merge pallet, where everything on the
     *        pallet goes onto a single truck pallet,
     *        get the corresponding truck pallet for the pallet
     *        summary.
642bA*    04/03/12  JCJ  6.42b
     *      - Changed program to print SETSUM label before PICK labels
     *        instead of after the PICK labels.
642cA*    04/09/12  JCJ  6.42c
     *      - Enh:  Added code to retrieve Truck Template.
642dA*    04/10/12  JCJ  6.42d
     *      - Fix:  Added code to retrieve brand for substitute labels
642eA*    05/02/12  JCJ  6.42e
     *      - Fix:  Replaced GETSTAMP with GETSTAMP3.
642fA*    05/08/12  RBD  6.42f
     *      - Recompiled, LABEL31 changed.
642gA*    05/30/12  JCJ/RBD 6.42g
     *      - Fix:  Added ORDP processing to merge pick label.
642hA*    09/10/12  JCJ  6.42h
     *      - Enh:  Reserving this mod mark
642iA*    03/08/12  JCJ  6.40w
     *      - Enh: changed pallet number printed on sethed label for
     *             loader merge processing and OPSPAL = 'Y'.
642jA*    04/11/11  JCJ  6.42j
     *      - Enh: For replenishment labels use print device passed inin
     *        instead of print device in Zone Template.
642kA*    04/12/11  RBD  6.42k
     *      - Fix: Add *PRTLBL cmd to list of pgms which call PFMT and
     *        should use dev and form passed in.
642lA*    09/08/11  JCJ  6.42l
     *      - Added variable heading to Sethed label
     *      - Loaded zone description instead of item desc when zone
     *        is a tote.
650aA*    01/07/13  RBD  6.50a
     *      - Fix:  If *SHORT cmd, pgm was printing the wrong Trax#s
     *        for runner pick labels, it was starting at the beginning
     *        which means it was printing labels with Trax#s which had
     *        already been printed.  This fix will find and print the
     *        next Trax#/s in sequence which haven't yet printed.
     *        Prior to this fix when the driver would scan the shorts
     *        label the unit would return a 'duplicate scanId error'
     *        because the Trax# had already been scanned on a previous
     *        label which was printed for the qty picked before it
     *        was shorted.
     *      - Added cmd *SHORTM.
     *      - If voice option OPUPLV = 'N' and cmd = *SHORT :
     *        Subtract the qty short, which is passed in, from lbqpck
     *        and add 1 to it, and that will be the nth Trax# to use.
     *      - If voice option OPUPLV = 'Y' and cmd = *SHORT
     *                     or OPUPLV = 'Y' and cmd = *SHORTM
     *                     or OPUPLV = 'N' and cmd = *SHORTM :
     *        Add 1 to lbqpck and that will be the nth Trax# to use.
650bA*    04/23/13  JCJ  6.50b
     *      - Fix:  Movel Routeid instead of route and removed client
     *        specific code.
650cA*    06/30/11  JCJ  6.50c
     *      - Enh: Added label range for reprinting pick labels.
650dA*    05/22/13  JCJ  6.50d
     *      - Enh: Added fields RTSDROP, RTSEXTD, RTSSD
650eA*    07/23/13  JCJ  6.40e
     *      - Enh: Added variable 451 for Purchase order.
650fA*    06/17/13  JCJ  6.50f
     *      - Enh: Added print slot barcode on pick labels flag.
650gA*    12/12/13  JCJ  6.50g
     *      - Enh: Added Audit word to pallet label if client sends
     *        a 'Y' in position 11 in OHMISC field in ORDH.
650hA*    12/11/13  DAS  6.50h
     *      - Revised the zone pickup label for a Loader Merge to
     *        print transaction number of the corresponding label
     *        instead of the pallet number.
650iA*    01/17/14  JCJ  6.50i
     *      - Initialize $NANUM when printing stop number for V36 in
     *        Zone pickup label.
650jA*    02/13/14  JCJ  6.50j
     *      - Enh: Created heavy item alert variable.
650kA*    06/05/14  JCJ  650k
     *      - Fix: Added ORDP processing to PRTLBL.
650lA*    10/27/14  JCJ  650l
     *      - Enh: Added section code to combo label.
650mA*    02/25/15  JCJ  650m
     *      - Enh: Turn off Global printing function.
650nA*    06/25/14  JCJ  6.50n
     *      - If cmd *SHORTM or *SHORT use passed in device instead of
     *        device from zone template.
650oA*    06/27/14  JCJ  6.50o
     *      - Added GETORDHM to PRTLBL routine.  This will make sure
     *        ORDHM data gets printed on the Runner Pick labels.
700aA*    05/01/15  JCJ  7.00a
     *      - Fix: Added indicator to ReadE in PRTXDK, was missing
700bA*    05/26/15  JCJ  7.00b
     *      - Enh: Softcode Big Pallet Label.
700cA*    05/31/15  MLB  7.00c
     *      - Fix: Revised routine OPNPRT to add movea cmds to load
     *        print device and formtype into ovrprtf array cmd.
700dA*    06/02/15  JCJ  7.00d
     *      - Fix: Added missing trax number code to PRTXDK subroutine
700eA*    06/12/15  JCJ  7.00e
     *      - Fix: Subroutine PRTLBL was using the wrong key to lookup
     *             the trax number.
700fA*    06/17/15  MLB  7.00f
     *      - Fix: Increase size of DSPWGT,DSSWGT to 9,2 from 7,2. SBR
     *        encountered an DDE error.
700gA*    03/22/05  HNK  700g  (500b change at Cheney)
     *      - Added command *BEGEND to print SETBEG and SETEND for
     *        Belt printer.
700gA*    09/11/15  JCJ  7.00g (was 700k but another 700k coming in)
     *      - Fix: Changed to grab correct trax number.
700hA*    08/04/15  JCJ  700h
     *      - Cleaned up subroutine LBLSHD.  To view original code
     *        see PFMT.0804 in PIROLD700.
700iA*    08/11/15  JCJ  7.00i - Project 1086 was 640b mod on CBI
     *     - Added command *SETSUM to only print the Set Summary label
     *       and then get out.
     *     - Added command *CLOSE to seton *INLR when after printing
     *       batch labels.
700jA*    08/19/15  JCJ  7.00j
     *     - Added code to use PRTSELCBI for cheney and PRTSEL for
     *       everyone else.
700kA*    09/11/15  JCJ  7.00i
     *      - Fix: Changed to grab correct trax number.
700kA*    10/12/15  JCJ  7.00k
     *      - Enh: Added call to program getpltvid to retrive the
     *             voice id to be printed on the pallet label.
700lA*    11/30/15  JCJ  7.00l
     *      - Enh: Added palet label reprint logic.
700wA*    05/09/16  JCJ  7.00w
     *      - Enh: Added Dock Door Department to Big Pallet Label.
     *
701cA*    12/19/16  JCJ  7.01c
     *      - Fix: Added file ITEMMSC to PRTLBL to get Brand.
     *
701dA*    01/12/17  JCJ  7.01d
     *      - Ehn: Updated Gen Pick Data Structure.
720aA*    01/30/18  NLK  7.20a
     *      - Fix: Labels when OverFlow Pallet has same Trn# now
     *             since new OR630 major changes by Trn#, stop seq
720bA*    03.23.18  JCJ  7.20b
     *      - Ehn: added cheney to BIGPAL no print option.
720dA*    08/24/18  NLK  7.20d
     *      - Fix: PRTSEL vs PRTXDK - XDK was missing going to get
     *        ORDHM and ORDD causing invalid oditem value in barcode
730eA*    03/15/19  JCJ  730e
     *      - added new order header process.
730fA*    04/04/19  JCJ  730f
     *      - added variable 461 for new loader number format.
     *      - variable 461 is replacing 455**IF only needing 9 long
730gA*    04/12/19  JCJ  730g
     *      - added new customer number process.
730gA*    04/12/19  JCJ  730g
     *      - added new customer number process.
730pA*    10/23/19  JCJ  730p
     *      - Added Pallet Generation logic for Pallet Type
     *        Determination.
740eA*    05/15/20  NLK  740e
     *      - ENH: use @var 101 for extended CORD (CBI currently)
     *        CORD was 7.0 now 11
720fA*    08/25/18  DAS  7.20f
     *      - Revised *INZSR to get dataarea DragDrop2.
     *      - When using DD2, normal pallets are PLTSUM PSTYPE='P'.
     *        PSTYPE='O' are Location summaries.
     *      - Added file PLTSUM8.
720gA*    09/11/18  DAS  7.20g
     *      - Revised to call GetTBType instead of reading
     *        data area dragdrop2 directly.
     *      - Replaced dd2 with tbEnhanced.
720iA*    11/15/18  DAS  7.20i
     *      - Created keyps3b from keyps3. Uses kygen instead of $pgen.
     *      - Revised PRTBLK to use keyps3b. Sets kygen to 7 when
     *        using Advanced TB otherwise sets it to $pgen.
750aA*    04/01/21  DAS  7.50a
     *      - Added 720f/g/i and 730p changes for TruckBuilder Prime.
750bA*    05/03/21  JCJ  750b
     *      - fixed printing of Bulk pick only pallet for TbEnhanced
750fA*    05/15/21  DAS  750f
     *     - SelectPrime changes.
     *     - Yes, 750f, to correspond with SelectPrime changes in other programs
     *     - Converted to SQLRPGLE
     *     - Moved Revisions to after Notes, as they were getting lost.
     *     - Revised to write certain labels to LABELOUT - See notes.
750gA*    05/28/21  DAS  750g
     *     - Created this client custom version to be called from PFMT
     *       program. See notes above.
750hA*    05/31/21  DAS  750h
     *     - Revised FILCHR to trim trailing spaces
750iA*    06/08/21  JCJ  750i
     *      - Defaulted reprint flag to 'R'.
750jA*    06/23/21  DAS  750j
     *      - Creating Zebra variable data label to be used with Zebra
     *        stored format. This is only done for belt formats that
     *        start with 'PICK'. The stored formats are created
     *        manually using a separate program. The Set name will
     *        start with 'BLD' instead of 'BLT'. The stored format
     *        set will start with 'BLF'.
750kA*    07/21/21  JCJ  750k
     *      - Revised to only reprint 'P' type Big pallet labels for
     *        Rnhanced TB.
750lA*    08/05/21  JCJ  750l
     *      - Fix: Revised routine PRTXDK to add logic to iter when a
     *        2nd label record was read. This was happening when
     *        a sub was added to the pallet that had the XDK item(s).
     *        Found at Panos Foods.
750mA*    10/06/21  LMC  750m
     *      - Enh: Seton *inlr on cmd BLTTEST.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Jordanos
     *
JORaA*    01/29/08  DAS  JORa
     *      - Positon 20 of OHMISC will contain Substitute flag.
     *      - Added variable 305 to fillb2 for sub warning.
JORbA*    01/30/08  MLB  JORb
     *      - Added new entry to OVRPRT array to perform prtf
     *        override to OUTQ instead of DEV.
JORcA*    02/07/08  MLB  JORc
     *      - Revised routine ZZFILB2 to convert Pack to 1 when
     *        item is normal item being picked as Eaches.
JORdA*    04/08/08  CWM  JORd
     *      - Print Ship Date rather than todays date on labels.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Mattingly
     *
MATaA*    09/10/09  JCJ  MATa
     *      - Added printing of unique piece number to PICK label,
     *        variable 107.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Cash-Wa
     *
CWD A*    11/16/08  JCJ  CWD
     *      - Print label format PICK2 for EACH labels.
     *
CWDaA*    11/18/08  JCJ  CWDa
     *      - Added Invoice number
     *      - Added Customer number
     *      - Added Ship date
     *      - Added Stop number
     *      - Added Label number
     *      - Added City / State
     *
CWDbA*    11/20/08  JCJ  CWDb
     *      - removed CWD A change
     *
CWDcA*    11/24/08  JCJ  CWDc
     *      - Added new var to PICK format:
     *      - Added a prefix to file ordh.
     *
CWDdA*    11/25/08  JCJ  CWDd
     *      - Added field 306.
     *
CWDeA*    12/01/08  JCJ  CWDe
     *      - Removed blanks from item barcode and changed length of
     *        v182 from 6 to 8.
     *
CWDfA*    12/06/08  MLB  CWDf
     *      - Revised program to skip printing for items with the
     *        following pick slots: KD-101-1, KF-101-1 and KR-101-1.
     *        These slots are cross-dock slots with product coming
     *        from other warehouses. Per email from Hemant, dated
     *        12/05/08.
     *
cwdgA*    01/20/09  JCJ  cwdg
     *      - add code for new label format XTOT2.
     *
cwdhA*    01/28/09  JCJ  cwdh
     *      - add code redirect tote labels to different printer.
     *
cwdiA*    01/28/09  JCJ  cwdi
     *      - add code to print BULK/COMBO in qty field.
     *
cwdjA*    03/06/09  JCJ  cwdj
     *      - added quantity on hand to pick & bulk labels.  V307
     *
cwdkA*    03/19/09  JCJ  cwdk
     *      - added quantity on hand (eaches) to pick & bulk labels.
     *        (V308)
     *
cwdlA*    03/29/09  JCJ  cwdl
     *      - changed V408 to V409 for use with 3 digit stop# on tote.
     *
cwdmA*    03/30/09  MLB  cwdm
     *      - Changed pgm to retrieve Host label number from ORDDM in
     *        file ORDDM/OMMSC2 in positions 11-20 instead of ORDD in
     *        ODOITM. Field ODOITM needed for item substitutions.
cwdnA*    04/20/09  MLB  cwdn
     *      - Changed routine PRTBLK to call GETORDDM to retrieve
     *        Order Detail Misc. file info.
cwdpA*    06/03/09  JCJ  cwdp
     *      - Added GETORDH to PRTBLK to retrieve customer number
     *        and name.
     *
cwdqA*    11/20/09  JCJ  cwdq
     *      - Stop printing ZONHED label requested by Gayland Weisenburger
     *
cwdrA*    12/15/09  JCJ  cwdr
     *      - Soft coded variable 405 for client id - L=Lincoln, K=Kearney
     *        A=Aberdean.
     *
CWDsA*    03/30/09  HNK  CWDs
     *      - Revised program to always print PICK labels for Zone-
     *        pickup.
     *
CWDtA*    03/22/10  JCJ  CWDt
     *      - Fix:  setup variable 18 to replace variable 107 because
     *        aberdean changed their customer order number from 5,0
     *        to 7,0.
     *
CWDuA*    03/07/12  JCJ  CWDu
     *      - Enh:  added taxrite changes.
     *
CWDvA*    12/24/13  JCJ  CWDv
     *      - Enh: Added from & to stop to SETHED label.
CWDwA*    01/01/14  JCJ  CWDw
     *      - Added printing of new labels CUSTNOTE
CWDxA*    02/08/14  JCJ  CWDx
     *      - Added slot to catch weight label
     *----------------------------------------------------------------
     *  Client Custom Revisions: Halsey
     *
HALaA*    01/19/10  JCJ  Hala
     *      - Removed leading zeros from Pallet id.
HALbA*    02/15/13  JCJ  Halb
     *      - activated 530c mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fischer
     *
FSHaA*    04/07/10  JCJ  Fsha
     *      - Added UOM to Variable 315.
FFCbA*    04/08/10  MLB  FFCb
     *      - Revised PRTLBL to have SSB items print individual labels
     *        unless SSB pick qty > combined label qty.
FFCcA*    04/08/10  MLB  FFCc
     *      - Revised program to use different label format for printing
     *        Each, type B or type S items so they will be Reverse Imaged
FSHdA*    07/07/10  GJA  FSHd
     *      - Added LABEL32D
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cityline
     *
CLDa *    03/26/04 HNK CLDa
     *      - Change SETHEDCL to PALLET.
     *
CLDb *    04/06/04 HNK CLDb
     *      - Disable Aisle change label
     *      - Do not print the word "OUT"
     *      - Reverse ALNn change
     *      - PRINT A COMBO LABEL FOR 'S' TYPE ITEM
     *
CLDd *    04/08/04 DAS CLDd
     *      - Revised parm 60 to user @PSECT instead of LBHND2.
     *      - Revised routine LBLPCK to use GETTPL2 instead of
     *        GETTPLT in order to get the pallet section id.
     *      - Revised routine LBLPCK to fill in @PSECT.
     *      - Added zone pickup field DSZPSI for the pallet section id.
     *      - Revised parm 39, zone merge pallet number, to tack on
     *        the pallet id. FILNUM routine was revised to do this.
     *
CLDe *    04/08/04 DAS CLDe
     *      - Revised PRTSEL to do a special call to SETEND to just
     *        print merge labels. This is done after gen 1 DRY labels
     *        have been printed.
     *      - Added conditions to SETEND to deal with special call.
     *
CLDf *    05/25/04 HNK CLDf
     *      - Add variables to print stop range on Pallet label.ust
     *
CLDg *    06/04/04 HNK CLDg
     *      - print summary zone pickup label for each pallet.
     *
CLDh *    08/10/04 HNK CLDh
     *      - Reverse CLDc change to print label for PIR item with blank slot.
     *
CLDi *    01/14/05 DAS CLDi
     *      - Added file LABEL32X (Aisle order).
     *      - Revised PRTSEL to use LABEL32X.
     *
CLDk *    09/20/05  HNK  CLDk
     *      - Add variable 67 - Pick date
     *      - Hard code shellfish item numbers to print Information
     *        Tracking Label.
     *
CLDl *    10/08/06  DAS  CLDl
     *      - Added files PIRSEQ2, PIRSEQ3.
     *      - Revised LBLPCK routine to use format PIRPICK for
     *        non-generation 1 labels.
     *      - Created routine LBLZPM to print PIR merge seq lbls
     *      - Revised PRTSEL to get PIR seq# for Gen > 1.
     *      - Revised SETEND to call LBLZPM.
     *      - Added <154> and <155> to FILLB2.
     *
CLDn *    10/25/06  DAS  CLDn
     *      - Revised routine LBLZPM to handle a label split between
     *        pallet sections.
     *
CLDo *     7/02/08  RBD  CLDo  P#00060
     *      - Revised to preface the printing of pallet id on the
     *        pallet header label with the 2 rightmost bytes of route.
     *        This combo field is used by the loader module to ensure
     *        that the loader is scanning the correct pallet & route.
     *
CLDp *    10/05/09  JCJ  CLDp
     *      - Added variable 93 for PIR Seq# for PIRPICK belt printer
     *        label (BLTCTL).
     *
CLDq *    12/14/09  GJA  CLDq
     *      - Added summary pieces to calculate FAB items correctly.
     *
CLDs *    03/03/10  JCJ  CLDs
     *      - Var 315 - Combined qty field to get qty fieldset summary
     *        values closer together.
     *      - Removed CLDr change per Steve Dizinno
     *
CLDt *    02/02/11  JCJ  CLDt
     *      - Enh: underline stop 6 on label.
     *
CLDu *    02/27/12  JCJ  CLDu
     *      - Enh: activated PICK2 label.
     *
CLDv *    10/09/12  JCJ  CLDv
     *      - Enh: added SSB check for combo printing
     *
CLDw *    10/10/12  JCJ  CLDw
     *      - Enh: added item notes label
     *      - Enh: added printing of new labels CUSTNOTE
     *
CLDxA*    09/19/13  JCJ  CLDx
     *      - Enh: do not print zone pick up label.
     *
CLDyA*    09/30/13  RTR  CLDy
     *      - Fix: do not print zone pick up label.
     *
CLDzA*    10/21/13  JCJ  CLDz
     *      - Enh: for cityline do not print normal replenishment lbs.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: ISY
     *
ISP A*    12/22/10  JCJ  ISY
     *      - Created
     *
ISYaA*    03/01/06  MLB  ISYa
     *      - Revise program print item description sent with
     *        item if OMPDSC = Y and OMODSC > blanks.
ISYc *    07/20/06  RH   ISYc  I-Supply
     *      - Revise PRTSEL to print pick lables in reverse stop order
     *        use LABEL32I.
ISYd *    11/20/06  RH   ISYd  I-Supply
     *      - Revise when catch weight labels print.
ISYe *    11/11/09  JCJ  ISYe  I-Supply
     *      - changed var 185 from usng %editc to %char to elliminate
     *        leading characters in customer number.
ISPfA*    07/26/11  JCJ  ISPf
     *      - printed pkdate on pick label.
ISYfA*    08/26/11  JCJ  ISYf  I-Supply
     *      - Revised to not print end label.
ISYgA*    01/18/15  JCJ  ISYg
     *      - Revised to add stop range to pallet label.
ISYhA*    01/18/15  JCJ  ISYf
     *      - Print label format PICK2 for EACH labels.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Crumbley
     *
CPCbA*    03/21/11  JCJ  CPCb
     *      - Enh: added chemical color codes to print on pick/bulk
     *             labels.
     *
CPCcA*    03/22/11  JCJ  CPCc
     *      - Enh: added goal times to Set Header label.
     *
CPCdA*    04/11/11  JCJ  CPCd
     *      - Enh: added a dash to slot that prints on labels.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Hearn Kirkwood
     *
HKWa *    09/15/13  GJA  HKWa
     *      - Added LABEL32D - used with DFPICK
     *
HKWbA*    09/19/13  JCJ  HKWb
     *      - Added code to use "Qty level for combined labels" as the
     *        number of catch weight to print.
     *
HKWcA*    09/20/13  JCJ  HKWc
     *      - Activated PICK2 each label.
     *
HKWdA*    09/22/13  JCJ  HKWd
     *      - Changed to print date from ohmisc/ordh on pick label.
     *
HKWeA*    09/23/13  JCJ  HKWe
     *      - exclude combo processing for ittype = 'S'.
     *
HKWfA*    09/24/13  JCJ  HKWf
     *      - Reversed HKWb mods.
     *
HKWgA*    09/27/13  JCJ  HKWg
     *      - Added code to contol number of catch weight labels that
     *        pirnt.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRY A*    01/04/10  JCJ  DRY
     *      - Added ORDHM file for Truck ID.
     *
DRYaA*    01/05/10  JCJ  DRYa
     *      - Added labels PICK2 & CACHWT2 to reverse video the
     *        Breakdown 1 UOM.
     *
DRYbA*    03/03/10  JCJ  DRYb
     *      - FIX: fixed quantity printed on CMBB label.
     *
DRYcA*    05/06/11  JCJ  DRYc
     *      - Enh: added dairyland to the list of clients that use
     *        loader module barcode on the pallet label.
     *
DRYdA*    07/11/11  JCJ  DRYd
     *      - Enh: reformate slot for Hanover.
     *
DRYeA*    05/06/13  JCJ  DRYe
     *      - Fix: Add code to retrieve customer number from OHMISC.
     *
DRYfA*    05/15/14  JCJ  DRYf
     *      - Enh: Add code to print Cruise label.
     *
DRYgA*    07/16/14  JCJ  DRYg
     *      - Enh: use qty picked to determine number of Cruise labels
     *        to print.
     *
DRYhA*    08/26/14  JCJ  DRYh
     *      - Enh: Add brand. V188
     *
DRYiA*    08/28/14  JCJ  DRYi
     *      - Enh: Use delivery date on pick label if passed in.
     *
DRYjA*    10/15/14  JCJ  DRYj
     *      - Enh: Reverse Print Piece Label (uom = 'PC').
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Capitol City Produce
     *
CCPa *    07/27/10  GJA  CCPa
     *      - Added printing of new labels CUSTNOTE
     *
CCPb *    08/23/10  GJA  CCPb
     *      - Added printing of new labels ITEMNOTE.
CCPc *    09/07/10  GJA  CCPc
     *      - Added printing of new labels School pre-pick.
     *
NCSaA*----------------------------------------------------------------
NCSaA*  Client Custom Revisions: Nicholas
NCSaA*
NCSaA*    03/30/11  JCJ  NCSa
NCSaA*      - Changed to only print positions 2 - 12 of the slot.
     *
NCSbA*    04/07/11  JCJ  NCSb
NCSbA*      - Print vendor name on pick label.
     *
NCScA*    04/26/11  JCJ  NCSc
     *      - Change to print today's date on pick label.
     *
NCSdA*    05/05/11  JCJ  NCSd
     *      - Enh: changed to print combo labels in format blocks of
     *        X of X and any remaining labels X of Y.
     *
NCSeA*    05/13/11  JCJ  NCSe
     *      - Enh: changed COMBO pick label to print MULTI instaed of
     *        COMBO.
     *
NCSfA*    05/17/11  JCJ  NCSf
     *      - Fix: changed COMBO logic to handle a combo level entry
     *        of zero.  This will prevent a divid by zero error.
NCSgA*    05/20/11  JCJ  NCSg
     *      - Enh: added ohmisc_ncs.
     *      - Enh: print p/o on pick label.
NCShA*    05/20/11  JCJ  NCSh
     *      - Enh: reversed mod NCSa
     *      - Enh: added '*' before and after combo word 'MULTI xxx'.
     *
EIa A*----------------------------------------------------------------
EIa A*  Client Custom Revisions: European Imports
EIa A*
EIi A*    03/03/15  MLB  EIi
     *     - Added EIi to load dscitm into variable 74.
     *
SLBaA*----------------------------------------------------------------
SLBaA*  Client Custom Revisions: AJ Silberman
SLBaA*
SLBaA*    09/07/11  JCJ  SLBa
SLBaA*      - Add additional Tax jurisdiction code logic.
     *----------------------------------------------------------------
     *  Client Custom Revisions - CDI
     *
CDIaA*    03/14/08  DAS  CDIa
     *      - Print UOMB (UOM Next) label for items with cat=BRKDWN.
     *
CDIbA*    06/23/09  JCJ  CDIb
     *      - Commented out Aisle change label per Roxanne request.
     *      - this was replaced with a pick zone option.
     *
CDIcA*    04/23/10  JCJ  CDIc
     *      - Enh: print two blank labels after the cut command.
CDIdA*    01/03/11  MLB  CDId
     *      - Revised pgm to not load word OUT onto pick labels per
     *        August W ph. call.
CDIeA*    01/04/11  MLB  CDIe
     *      - Enh: Print two blank labels after the cut command for
     *        Atlanta routes. August W ph. call. Chg to CDIc mod.
CDIfA*    05/04/11  JCJ  CDIf
     *      - Enh: print the word "Reprint" on the Pick and Bulk
     *        labels if the labels are reprinted.
CDIiA*    03/01/21  JCJ  CDIi
     *      - Enh: Load '***' for outword. Ticket 3656.
     *
     *----------------------------------------------------------------
     *  Client custom revisions - Glazier
     *
GFCaA*    01/02/12  JCJ  GFCa
     *      - Remove UOM from variable 315.
     *      - Print label format PICK2 for EACH labels.
     *
GFCbA*    03/20/12  JCJ  GFCb
     *      - Format slot before printing on label.
     *
GFCcA*    04/03/12  JCJ  GFCc
     *      - Changed program to print SETSUM label before PICK labels
     *        instead of after the PICK labels.
GFCdA*    04/06/12  JCJ  GFCd
     *      - Enh:  Print truck template on pallet label.
GFCeA*    04/10/12  JCJ  GFCe
     *      - Enh:  Do not print Zone header label if there is no
     *              item detail associated with the zone.
GFCfA*    04/12/12  JCJ  GFCf
     *      - Enh:  Change BULK & COMBO printing logic.
GFCgA*    05/08/12  JCJ  GFCg
     *      - Enh:  Added code to retrieve the customer number from
     *        ORDHM in certain situations. (Route number does not -
     *        start with an 'I' or 'H')
GFChA*    05/29/12  JCJ  GFCh
     *      - Revised routine ZZFILB2 to convert Pack to 1 when
     *        item is normal item being picked as Eaches.
GFCiA*    06/17/13  JCJ  GFCi
     *      - Enh:  Add Slot barcode labels.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Springfield
     *
SFGa  *    05/23/07  HNK SFga
     *      - Format slot number as per SFG requirement. C-A-01-1A
     *
SFGb  *    05/23/07  HNK SFgb
     *      - Changed <20> to display today + 1.
     *
SFGc  *    05/24/07  HNK SFgc
     *      - Add ITEMMSC file to print brand name.
     *
SFGd  *    05/24/07  MLB SFgd
     *      - Revise program to use LABEL32G instead of LABEL32.
     *
SFGe  *    05/24/07  MLB SFGe
     *      - Revise program to not print catchwgt labels between
     *        pick labels.
     *
SFGf  *    05/24/07  HNK SFGf
     *      - Revise program to print packdesc depending on UOM
     *
SFGgA*    06/06/07  DAS  SFGg
     *      - Added field 94 for SFG's order line number.
     *
SFGiA*    09/06/07  JCJ  SFGi
     *      - Print warning unit of measure labels if Master
     *        Pack item field (orddm1_sgc/sgcdm1_ommpck) = 'Y'.
SFGjA*    03/19/09  HNK  SFGj
     *      - Print PICKEA label for eaches.
SFGkA*    05/27/09  JCJ  SFGk
     *      - added retrieval of brand in cross dock routine.
     *      - for cross dock labels add pick slot to labels.
     *
     *        ******* is this still needed  ********
     *
     *      - if compartment is 'F' and unload seq# = 1 print the
     *        word SIDE on label.  Pallet sits in front of door and
     *        needs to be turned sideways so the door can open.
SFGlA*    07/09/09  GJA  SFGl
     *      - Print PICKEA label for BA (bag) and BK (broken).
SFGmA*    12/02/09  GJA  SFGm
     *      - Print merge labels
SFGnA*    12/07/09  JCJ  SFGn
     *      - Add Merge Header Label
SFGoA*    05/20/11  JCJ  SFGo
     *      - Change location from 2 to 3
SFGpA*    01/22/12  JCJ  SFGp
     *      - Printed didisp instead of lbdisp to get SFG slot format.
     *      - set third dash in slot to blanks.
SFGqA*    01/24/12  JCJ  SFGq
     *      - Changed variable for brand from V102 to V313.
SFGrA*    01/30/12  JCJ  SFGr
     *      - Enh: tweeked comb label to print COMBO x of x.
SFGsA*    02/06/13  JCJ  SFGs
     *      - moved the last two digits the route to the first two
     *        digits of pallet id (variable 60) for trax.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - CTW
     *
ctwaA*    05/08/08  JCJ  CTWa
     *      - Added retail 4-up labels
     *      - Added Cigaretts / tobacco / Candy Labels
ctwbA*    06/16/08  HNK  CTWb
     *      - Added Mez and CIG zones.
CTWcA*    06/17/08  MLB  CTWc
     *      - Revised program to use LABEL32E instead of LABEL32C.
     *        City Wholesale needs to have the labels printed in
     *        ascending stop sequence instead of descending stop.
     *        This change will pick lowest stop first  if we have to
     *        pick items for more than one stop from one slot.  CTW's
     *        stop numbers are reverse than most of our other clients.
     *        Highest stop number is the first stop on their route to
     *        unload.
ctwdA*    06/18/08  JCJ  ctwd
     *      - Added lot label.
ctweA*    06/19/08  JCJ  ctwe
     *      - Added recap label.
ctwfA*    06/23/08  JCJ  ctwf
     *      - replaced all the txxxx label formats with standard names
ctwgA*    06/23/08  JCJ  ctwg
     *      - add code for new label format XTOT2.
ctwhA*    06/24/08  JCJ  ctwh
     *      - revised retail price processing to print as is.
ctwiA*    06/24/08  JCJ  ctwi
     *      - fixed pallet id for pick2.
ctwjA*    06/27/08  HNK  ctwj
     *      - Create new flag for Cigarettes.
ctwkA*    06/29/08  JCJ  ctwk
     *      - Do not print pick labels for Cigarettes (Cig011,Cig091).
ctwlA*    07/01/08  HNK  ctwl
     *      - Use PLTSUM9 to print truck zone pallets in ascending seq
ctwmA*    07/01/08  JCJ  ctwm
     *      - replaced cnttotes with cnttotes2
ctwnA*    07/01/08  JCJ  ctwn
     *      - initialize ts arrary with movea
ctwoA*    07/03/08  JCJ  ctwo
     *      - Print RecapJurName if Recap flag = Y
ctwpA*    07/07/08  HNK  ctwp
     *      - Move RECAP label print logic from lblshd subr to prtsel.
ctwqA*    07/08/08  HNK  ctwq
     *      - Add variable V318 and V176.
ctwrA*    07/24/08  JCJ  ctwr
     *      - moved customer order from line 2 to line 3 and right on
     *        munchkin label.
ctwsA*    09/09/08  JCJ  ctws
     *      - changed to save tote labels.
ctwtA*    10/13/08  JCJ  ctwt
     *      - Use PLTSUM13 istead of PLTSUM9.  PLTSUM9 used in TB with
     *        different key.
ctwuA*    11/18/08  JCJ  ctwu
     *      - removed leading zeros from stamping unit number.
ctwvA*    11/24/08  HNK/JCJ CTWv
     *      - removed trailing blanks from variable 125.
ctwwA*    04/14/09  HNK/JCJ CTWw
     *      - add new tote label XTOTES "Special stamp" for Cigarette
     *        zone only.
ctwxA*    06/11/09  JCJ  ctwx
     *      - fixed stamping unit number for tote reprint.
ctwyA*    10/08/09  JCJ  ctwy
     *      - removed leading zeros from tran barcode for check right
     *        tote label (xtote2).
ctwzA*    03/01/11  JCJ  ctwz
     *      - Fix: changed SR LBLSHDT to loop for another label number
     *             if the previous label did not find the tote merge
     *             record.
ct2aA*    07/11/11  JCJ  ct2a
     *      - Enh: added zone PHN132  to loop for another label number
ct2bA*    04/02/12  MLB  ct2b
     *      - Enh: Revised pgm to re-instate CTWm mod to call CNTTOTES2.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Royal
     *
RYLiA*    07/13/10  RH   RYLi
     *      - Fix: Change palletid to print last 2 char from RTID.
     *
     *----------------------------------------------------------------
     *  Client custom revisions - Graves Menu Maker
     *
GMMaA*    04/17/12  JCJ  GMMa
     *      - Print label format PICK2 for EACH labels.
     *----------------------------------------------------------------
     *  Client custom revisions - H & M Wagner
     *
HMWaA*    08/14/12  JCJ  HMWa
     *      - Add code to print the word SUB for substitute items.
HMWbA*    08/22/12  JCJ  HMWb
     *      - Activated PICK2 label for eaches.
HMWcA*    09/10/12  JCJ  HMWc
     *      - Activated V313 - Brand on Pick/Pick2 labels
HMWdA*    10/17/12  JCJ  HMWd
     *      - Revised program to skip printing for items 900300,
     *        900301, 900302, 900300-CS, 900301-CS, 900302-CS.
HMWeA*    12/12/13  RTR  HMWe
     *      - Change mod HMWb to look for CS in the UOM because of
     *        Aspen conversion, -CS/-EA/etc no longer used.
HMWfA*    03/26/14  JCJ  HMWf
     *      - Added HMWf to JORc mod.
HMWgA*    05/14/14  JCJ  HMWg
     *      - Revised to grab pallet code from LBDSP2 instead
     *        LBHND2.
     *----------------------------------------------------------------
     *  Client Custom Revisions - MJK
     *
MJKaA*    08/27/08  JCJ  MJKa
     *      - chnaged ovrprtf to use correct parms.
     *
MJKbA*    09/03/08  DAS  MJKb
     *      - Temporary change to use LABEL32S in PRTSEL.
     *        Re: They want to layer pick right now.
     *
MJKcA*    11/11/08  DAS  MJKc
     *      - Made MJKb limited to Contract routes.
     *
MJKdA*    09/21/12  JCJ  MJKd
     *      - Add PICK2 logic
     *
MJKeA*    09/27/12  JCJ  MJKe
     *      - Removed UOM from X of X variable (V315)
     *
MJKfA*    10/15/12  JCJ  MJKf
     *      - Reversed 640m mod.
     *
MJKgA*    10/16/12  JCJ  MJKg
     *      - Changed program to print SETSUM label before PICK labels
     *        instead of after the PICK labels.
     *
     *----------------------------------------------------------------
     *  Client custom revisions - Kellys Foods
     *
KFS A*    10/05/12  MLB  KFS
     *      - Revised pgm to use LABEL32D instead of default LABEL32C.
     *        Kelly's needs to print REF dept labels in descending seq.
     *        by aisle. Per Hemant phone call 10/04/12.
     *      - Added KFS to FSHd mod.
KFSaA*    02/20/13  JCJ  KFSa
     *      - moved the last two digits the route to the first two
     *        digits of pallet id (variable 60) for trax.
KFSbA*    06/21/13  JCJ  KFSb
     *      - Ehh: added code to print correct date on pick label.
KFScA*    05/22/15  JCJ  KFSc
     *      - Enh: Added stop range to pallet label. v65 & v66
     *      - Enh: Exchanged v60 for v455.  Uses all of the route id
     *             an pallet id.
     *----------------------------------------------------------------
     *  Client custom revisions - BiRite
     *
BIRa *    08/03/05 HNK BIRa
     *      - Change SETHEDCL to SETHEDBR
     *      - Keep CLDa change to print one line of desc from PIRITEM
     *      - Custom DSMISC fields for Pick label
     *      - Create variables for Catch weight entry fields.  Revise
     *        to print Catch weight entry fields on labels based on
     *        quantity.
     *      - Remove CLDc from PRTSEL routine.  Enable Catch wt print
     *        in PRTSEL and custom code for BiRite to print entry line
     *
BIRb *    08/03/05 HNK BIRa
     *      - Print brand name - variable 102
     *      - Print UOM warning before and after each set instead of
     *        after each label as Allen dies it.  Change is not marked
     *        See PRTSEL routine.
     *      - Remove CLDb change to print Combo label for 'S' type.
     *        Keep the AILCHG label disabled. Enable the CLDb change
     *        to print the word "OUT"
     *      - Keep CLDh change to print pick slot if OUT
     *      - Keep CLDf change to print stop range on pallet label.
     *      - Remove CLDj change.  This was part of CLDc code that
     *        got removed.
     *      - Remove CLDe custom change.  Code deleted.
     *      - Remove CLDi custom change.  Code deleted.  LABEL32X not
     *        used anymore.
     *
BIRc *    08/10/05 HNK BIRc
     *      - Disable CLDg change
     *      - Print quantity on CMBB, CMBA, UMB and UMA labels.
     *      - Initialize $NANUM
     *
BIRd *    08/18/05 HNK BIRd
     *      - Add ZZNPCKNLZ file to print special instructions label.
     *      - Add ORDH file and logic to print sp inst labels
BIRe *    08/31/05  MLB  BIRe
     *      - Revised program to strip pack value from ITPDSC when
     *        processing Each type items.
BIRf *    09/15/05  HNK  BIRf
     *      - Add warehouse quantity to pick label.  Variable 6
BIRg *    10/17/05  HNK  BIRg
     *      - Do not print ZONHED, SETSUM, SETHEDBR and ZONPKUP labels
     *        for Willcall order.
BIRh *    05/16/08  HNK  BIRh
     *      - Print label format PICK2 for EACH labels.
YHAaA*----------------------------------------------------------------
YHAaA*  Client Custom Revisions - Yhata
     *
YH2dA*    07/17/14  JCJ  YH2dA P#
     *      - Enh: added lifo item flag.
     *----------------------------------------------------------------
     *  Client custom revisions - Getfresh
     *
GFSaA*    06/12/13  JCJ  GFSa
     *      - Enh:  Added COMBO label flag.
     *
GFSbA*    06/13/13  JCJ  GFSb
     *      - Enh:  If printing a catch weight label print 'CS' as UOM
     *
GFScA*    06/14/13  JCJ  GFSc
     *      - Enh:  Add code for break down 1 logic for pick label.
     *              Activated each pick label.
     *
GFSdA*    06/27/13  JCJ  GFSd
     *      - Enh:  Add additional criteria for generating combo
     *              labels.
     *
GFSeA*    06/27/13  JCJ  GFSe
     *      - Enh:  Changed the date that prints on labels to
     *              Delivery date.
     *
GFSfA*    07/15/13  MLB  GFSf
     *      - Enh:  Revised program to use LABEL32D to print
     *              CLR dept aisle 30 labels before aisle 20.
     *              Per David H email.
     *      - Added GFSf to FSHd mod.
     *
GFSgA*    07/25/13  JCJ  GFSg
     *      - Enh:  added conditions for printing labels CMBA/CMBB
     *
GFShA*    08/05/13  JCJ  GFSh
     *      - Enh:  added additional logic for variable 161 COMBO each
GFSiA*    08/05/13  MLB  GFSi
     *      - Enh:  Disabled printing COMBO label for Brkdown 1/Brkdown 2
     *        labels where UoM = LB and ITMINQ = 0.
GFSjA*    08/07/13  MLB  GFSj
     *      - Enh:  Revised pgm to add support for printing COMBO label
     *        for variable 161 when the GFS Print Combo Label Flag = Y.
GFSkA*    09/27/13  MLB  GFSk
     *      - Added printing of new labels ITEMNOTE.
     *      - Added GFSk to CCPb mod.
GFSlA*    10/14/13  JCJ  GFSl
     *      - Added truck template to pallet label.
GFSmA*    03/06/14  MLB  GFSm
     *      - Added support to print new labels CUSTNOTE. These labels
     *        be used to print critical care warning message. Per David H.
     *        email dated 03/05/14.
     *----------------------------------------------------------------
     *  Client custom revisions - Greenleaf
     *
GLPa *    10/11/13 JCJ GLPa
     *      - Enh: print the letter "R" on the Pick and Bulk
     *        labels if the labels are reprinted.
GLPbA*    02/11/14  MLB  GLPb
     *      - Enh:  Revised program to use LABEL32D to print
     *        labels across all 3 departments. Per Hemant K.
     *        email dated 02/10/14.
     *      - Added GLPb to FSHd mod.
GLPcA*    02/12/14  JCJ  GLPc
     *      - Enh:  Changed the date that prints on labels to
     *              Delivery date.
GLPdA*    02/13/14  JCJ  GLPd
     *      - Enh:  Added Heavy item alert to pick label.
GLPeA*    02/14/14  JCJ  GLPe
     *      - Enh:  Added COMBO label as a seperate label.
GLPf *    04/24/14 KDE GLPf
     *      - Enh: print the physical slot for virtual slots
     *        when repack item labels
     *
     *----------------------------------------------------------------
     *  Client custom revisions - Ellenbee-Leggett
     *
ELBtA*    11/21/13  MLB  ELBt
     *      - Revised routine ZZFILB2 to convert Pack to 1 when
     *        item is normal item being picked as Eaches.
     *      - Added ELBt to JORc mod.
ELBuA*    03/05/14  JCJ  ELBu
     *      - Revised to grab pallet code from LBDSP2 instead
     *        LBHND2.
     *----------------------------------------------------------------
     *  Client Custom Revisions - Saval
     *
SVLbA*    03/12/09  JCJ  SVLb
     *      - Add support for printing brand V313.
SVLeA*    03/23/09  JCJ  SVLe
     *      - Add RTEHED to get report date and add 1 for delivery
     *        date.
SVLfA*    08/18/09  JCJ  SVLf
     *      - changed program to use LABEL32D instead of LABEL32C to
     *        get labels to print in user requested order.
SVLgA*    08/24/09  GJA  SVLg
     *      - Revised to preface the printing of pallet id on the
     *        pallet header label with the 2 rightmost bytes of route.
     *        This combo field is used by the loader module to ensure
     *        that the loader is scanning the correct pallet & route.
SVLhA*    08/28/09  JCJ  SVLh
     *      - Ehn: Added setsum label for will call routres.
SVLiA*    09/02/09  JCJ  SVLi
     *      - Ehn: If slot from label record is a virtual slot grab
     *             the base slot for printing.
SVLjA*    03/17/13  JCJ  SVLj
     *      - Ehn: Added label PICK2 for eaches.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fox River
     *
FRF A*    10/29/10  JCJ  FRF
     *      - Add item notes.
     *      - Add FRF program, INI160 with 3 parms to retrieve
     *        reformated item desc for each label printed.
     *      - Hard code label set name of ZBRFRF.
     *
FRFaA*    11/03/10  JCJ  FRFa
     *      - Change item description variable.
FRFbA*    11/04/10  MLB  FRFb
     *      - Revised program to use LABEL32D instead of LABEL32C.
     *        Needed to match label sequence specified previously in
     *        pgm PFILE.
     *      - Added file LABEL32D to pgm.
FRFcA*    11/05/10  MLB  FRFc
     *      - Revised program to insert dash into slot display field
     *        before printing label. For example: 87-541 for slot 87541.
FRFdA*    12/10/10  JCJ  FRFd
     *      - Retrive load number from ORDH file to print on SETHED
     *        and PALLET label.
     *
FRFeA*    09/09/13  JCJ  FRFe
     *      - add mod FRFa - Change item description variable to BULK
     *        SR.
     *
FRFfA*    02/06/14  JCJ  FRFf
     *      - add palet code.
     *
FRFgA*    06/25/14  JCJ  FRFg
     *      - change slot to print 6 digits instaed of 5.
     *
     *----------------------------------------------------------------
     *  Client custom revisions: Coastal Sunbelt Produce
     *
CSP A*    05/07/14  MLB  CSP
     *      - Enh: Revised program to use routine OPNPRT when
     *             $PCMD = '*SHORT'. Revised pgm to save
     *             device/form passed in to pgm in OPZDTA to be
     *             restored just before call to OPNPRT. This was needed
     *             because the program retrieves the printer/form from
     *             the item's pick zone definition.
     *
CSPl *    08/16/14  JCJ  CSPl
     *      - Enh: Replaced PALLET label with BIGPAL label.
     *
     *----------------------------------------------------------------
     *  Client custom revisions: Williams
     *
WIFaA*    05/13/14  JCJ  WIF
     *      - Enh: Print the text 'Wood Pallet' on pallet label when
     *             Customer has a single pallet selection designation.
     *
     *----------------------------------------------------------------
     *  Client custom revisions: Presto Foods
     *
PFCaA*    10/29/14  JCJ  PFCa
     *      - Enh: Added LABEL32J
PFCbA*    12/01/14  JCJ  PFCb
     *      - Enh:  Changed the date that prints on labels to
     *              Delivery date.
PFCcA*    01/21/15  JCJ  PFCc
     *      - Enh:  Changed PICK2 each label to print when UOM <> 'CS'
     *
     *----------------------------------------------------------------
     *  Client custom revisions: Cheney Brothers
     *
CBIaA*    05/22/03  HNK  CBIa
     *      - Revised to print two lines of desc on pick label.
     *      - Print brand name from ITEMMSC file (Var 102)
     *      - Print special instruction (Var 70)
     *      - Format customer number to print on pick label (Var 19)
     *
CBIbA*    05/23/03  HNK  CBIb
     *      - Revised to print label format PICK2 and PICK3. CBI
     *        needs to print slot number in reverse video if the
     *        pick level is 2 (Format PICK2).  If the pick level is
     *        3, the last two digits must be in reverse video (Format
     *        PICK3).
     *      - Convert first letter of aisle to lower case.
     *
CBIcA*    06/16/03  HNK  CBIc
     *      - Remove ALNa changes for OHMISC field and replace it
     *        with CBIc changes to print fields from OHMISC field
     *        for CBI.
     *      - Print A1A's item number and location.  Original item
     *        number field ODOITM has the info.
     *
CBIdA*    06/17/03  HNK  CBId
     *      - Cleanup
     *      - Add changes for Meat inspection labels
     *
CBIeA*    06/26/03  HNK  CBIe
     *      - Change to print SETHEDCB instead of SETHEDAL.
     *
CBIfA*    07/14/03  HNK  CBIf
     *      - Remove CBIc change for A1A's item number and create
     *        a new variable 72 for A1A's item number.
     *      - Disable Allen's UOM label change and put back default.
     *        It will now only print one UOM change label and not
     *        after every label.
     *
CBIgA*    07/15/03  HNK  CBIg
     *      - Remove ALN custom change for willcall orders.
     *
CBIhA*    07/15/03  HNK  CBIh
     *      - Add custom zone desc label
     *      - Print "No Repack" instead of "Repack".
     *      - Print price for Breakers items.  ODOR2 field has the
     *        price.
     *      - Print truck code for willcall orders.
     *
CBIiA*    07/16/03  HNK  CBIi
     *      - Don't print UMB label for PIR zones.
     *      - Don't print catch weight label when Meat Insp falg='Y'
     *
CBIjA*    07/16/03  DAS  CBIj
     *      - Added output file PFMTPR2.
     *      - Revised to write SETHEDCB to PFMTPR2.
     *
CBIkA*    07/21/03  HNK  CBIk
     *      - Don't make the first letter of slot lower case if it is
     *        a produce item.
     *
CBIlA*    07/22/03  HNK  CBIl
     *      - Print "New transaction" label.
     *      - Print UMA label only for CHEM zone.
     *      - Don't use PICK2 and PICK3 format if item is from 'PRD'
     *        department.
     *
CBImA*    08/07/03  HNK  CBIm
     *      - Hard code slot numbers for 999 items.  Routine ZZ999
     *        added.
     *
CBIpA*    08/21/03  HNK  CBIp
     *      - Revised to print "Merge Next" label.
     *      - Revised to print "10 of 10" for Combo label, instead of
     *        "    of 10".
     *      - Revised to print "3 - 3" for single pallet label instead
     *        of "3 -  ".
     *      - Revised LBLSHD routine to print BIGPALCB for all pallets
     *        and not just for truck pallets.
     *
CBIrA*    08/21/03  HNK  CBIr
     *      - Revised to print different pallet label for merge pallet
     *
CBIsA*    08/28/03  HNK  CBIs
     *      - Revised to print "1 of XX" on Catch Weight labels.
     *
CBItA*    09/02/03  HNK  CBIt
     *      - do not print Big pallet label for Meat Inspection.
     *
CBIuA*    09/05/03  HNK  CBIu
     *      - Print large quantity label (CMBB) after aisle change
     *        label (AISLCHG).
     *
CBIvA*    09/09/03  HNK  CBIv
     *      - Initialize DSDISP in ZZ999 routine.
     *
CBIwA*    09/10/03  HNK  CBIw
     *      - Fix: CBIm change. Do not print location if the item is
     *        >=997000 and this is a Meat Insp order.
     *      - Fix: Do not print Catch Weight labels for Meat insp item
     *      - print MEAT header label after Aisle change label.
     *
CBIxA*    09/11/03  HNK  CBIx
     *      - Print 2nd line of item desc and Pack desc on Zone pickup
     *        summary label.
     *
CBIyA*    09/15/03  RH   CBIy
     *      - Add OVRPRT table entry for PRTPAL2.
     *      - Change BIG PALLET to print on PRTPAL2 for CHEM and DRY.
     *
CBIzA*    09/23/03  HNK  CBIz
     *      - Fix: Print correct 'To" quantity for CW labels.
     *----------------------------------------------------------------
     *
CHYaA*    10/07/03 HNK CHYa
     *      - Do not print BIG PALLETlabel on PRTPAL2 if it is ADD-ONS
     *        truck.
     *      - Print BIGPAL label for CLRPIR, DRYPIR, DRY999, FRZPIR,
     *        FRZ999, ICEPIR, PKCPIR, PKDPIR and PKFPIR on PRTPAL3
     *        printer.  Ref: Tammy's email 10.7.03
     *
CHYbA*    10/07/03 DAS CHYb
     *      - Revised to print different MEAT label for cooler, dry
     *        and freezer.
     *      - Added logic to print PRE-PICK labels, which are
     *        similar to MEAT labels.
     *
CHYcA*    10/08/03 DAS CHYc
     *      - Revised to treat Pre-Pick like Meat (i.e., don't print
     *        catchweight labels).
     *
CHYdA*    10/15/03 DAS CHYd
     *      - Revised PRTSEL routine to initialize MEATPR and PPCKPR.
     *      - Revised PRTSEL routine to initialize MEATPR and PPCKPR.
     *
CHYeA*    11/12/03 HNK CHYe
     *      - Revised to print "PK Next" label for "FRZ" zone.
     *
CHYfA*    11/17/03 DAS CHYf
     *      - Revised to print "PK End" label for "FRZ" zone.
     *      - Added "PK Next/End" labels to "CHEM" zone.
     *
CHYgA*    11/24/03  DAS  CHYg
     *      - Print "PK Next" label (UMB) after aisle change
     *        label (AISLCHG).

CHYhA*    12/01/03  MLB  CHYh
     *      - Revised CHYa above to print big pallet label for truck
     *        ADD-ONS for DRY, PKDRY and CHEM zones.

CHYiA*    12/04/03  MLB  CHYi
     *      - Revised program to print BIG pallet label for PKxxx zones
     *        based on number of pieces on pallet divided by 8.
     *        Rounding up as needed for number of labels to print.

CHYjA*    01/26/04  HNK  CHYj
     *      - Revised to not print BIG pallet label for *SP truck.

CHYkA*    02/05/04  DAS  CHYk
     *      - Create Container header label.

CHYlA*    02/23/04  HNK  CHYl
     *      - Don't print BIGPAL label for truck 'CONTAINER'

CHYmA*    03/22/04  HNK  CHYm
     *      - Change the slot number for 999 items to CS-225-1
     *        instead of CD-538-2 and CE-096-1

CHYn *    04/16/04  HNK  CHYn
     *      - Revise to print "PK NEXT" label for any Will call order s
     *        truck other than "CONTAINE" and "BREAKERS" regardless
     *        of zone.

CHYo *    05/06/04  DAS  CHYo
     *      - Revised PRTSEL routine to call SETEND after CLR         s
     *        aisle D.

CHYp *    05/24/04  HNK  CHYp
     *      - Revised LBLPCK to print word "L I F O' if they send thiss
     *        in ODOITM field.

CHYq *    07/19/04  DAS  CHYq
     *      - Added file LABEL32C.
     *      - Revised PRTSEL to use LABEL32C.

CHYr *    07/27/04  DAS  CHYr
     *      - print BIGPAL labels for ADDONS truck PIR/999 zone on
     *        PRTPAL3

CHYs *    10/13/04  HNK  CHYs
     *      - print NEWTRANW for will calls.  This includes Ord#.

CHYt *    10/22/04  HNK  CHYt
     *      - Don't print BIGPAL label for "WILLCALL", "WILL-CALL"
     *        "SUD-SVC" and "DAMAGES" truck

CHYu *    03/08/05  HNK  CHYu
     *      - Print special instruction label for Will call and SUD-SVC

CHYv *    03/15/05  HNK  CHYv
     *      - Print special instruction label for Breakers.  Use same C
     *        label created for Will call (WLSPCL)

CHYw *    07/20/05  DAS  CHYw
     *      - Revised SETEND to print individual zone pickup labels.
     *      - Revised LBLZPH to print new format ZONPKUPH
     *        unconditionally instead of ZONPKUP when zpdcnt=0.

CHYx *    08/02/05  HNK  CHYx
     *     - Changed to print SETEND for *BEGIN per Marks email 8.2.05

CHYy *    08/05/05  DAS  CHYy
     *     - Revised *END to not call SETEND.
     *     - Revised *END to only print SETHEDCB and SETHED.
     *     - Removed *END logic (500d change) from SETEND.

CHYz *    08/11/05  DAS  CHYz
     *     - Revised SETSUM label to exclude type 'A' records.
     *----------------------------------------------------------------

CBSa *    09/14/05  HNK  CBSa
     *     - Print Big pallet label for PRODUCE on new printer PRTPRD
     *       located at A-One-A.

CBSb *    10/19/05  HNK  CBSb
     *     - Print 'MERGE' in variable 70 (Special Inst) for merge
     *       labels in Cooler and Freezer.  They print individual
     *       pick labels for zone pickup.

CBSc *    11/01/05  HNK  CBSc
     *     - Print Big pallet label for PRODUCE ADD-ON truck on PRTPRD
     *       located at A-One-A.

CBSd *    12/02/05  HNK  CBSd
     *     - Print SETEND label after slot FE-302 instead of FD-435.
     *       Mark's e-mail 12/02/05

CBSe *    12/06/05  HNK  CBSe
     *     - Print 'FLAG' in special instruction for runner pick lbl.

CBSf *    01/05/06  DAS  CBSf
     *     - Added file LABEL32D (LBLVL2,LBWHDP,...).
     *     - Revised to use LABEL32D instead of LABEL32C.

CBSg *    01/06/06  HNK  CBSg
     *     - Print 'MERGE' in variable 70 (Special Inst) for produce
     *       merge labels.

CBSh *    01/11/06  DAS  CBSh
     *     - Revised PRTSEL to use different locations to trigger
     *       the printing of merge labels at Ocala.
     *     - Revised PRTSEL to remove specific FE slot location for
     *       triggering merge labels for Riviera. Re: FE-302 is the
     *       last slot in aisle FE, therefore GT FE is sufficient.

CBSi *    01/17/06  DAS  CBSi
     *     - Revised to ignore special Merge logic for PRD.

CBSj *    01/19/06  MLB  CBSj - Ocala only
     *     - Revised program to direct all labels destined for
     *       PRTPAL3 to PRTPRD.

CBSk *    01/20/06  HNK  CBSk - Riviera only
     *     - Revised program to direct labels to various printers.

CBSL *    01/22/06  HNK  CBSL - Riviera only
     *     - Revised program to direct ICE AND PKCLR TO PRTPAL

CBSmA*    06/05/06 RH  CBSm
     *      - Print BIGPAL label for PKFPIR per Mark's email 4-24-06

CBSnA*    07/10/06 HNK CBSn
     *      - Print ROUTED VIA - Variable 77 on pick labels.
     *        email 6.30.06

CBSoA*    12/05/06 RH  CBSo
     *      - Move char 2 & 3 of Route to beginning of Pallet Id.

CBSpA*    05/09/07  DAS  CBSP
     *      - Added format BIGPALC2 to CBSo change.

CBSqA*    05/23/07  RBD  CBSq
     *      - When returning from GETPSLT if slot = *NONE* and
     *        the item is a special designation item, populate
     *        lbdisp  with dssdsp from DESIGSP file if the item
     *        designation code is found.

CBSrA*    06/26/07  DAS  CBSr
     *      - Revised to always print individual labels for
     *        catchweight items (does not affect bulk picks,
     *        which they are not using anyway at this time).

CBSsA*    07/14/07  DAS  CBSs
     *      - Added label variable <107> for cadec#

CBStA*    05/12/08  HNK  CBSt
     *      - Revised to not print special label for DRY999 items.

CBSuA*    08/06/08  DAS  CBSu
     *      - Revised BIGPALCB label. Changed pallet id barcode to
     *        use <310xxxxx>. This will contain 2 extra characters
     *        at the beginning of the pallet id. Re: So Cheney can
     *        identify if a user scanned the barcode or manually
     *        entered the human readable portion. Revised barcode to
     *        be code 128 in order to allow all 128 ASCII characters.
     *        Revised barcode to not print human readable part.
     *        Use std field <60xxx> to display human readable part.

CBSvA*    09/08/08  DAS  CBSv
     *      - Revised to use ORDP3 instead of ORDP2 because the lbl#
     *        looped in ORDP, but the route id is not part of the
     *        key in ORDP2. It is in ORDP3.

CBSwA*    12/15/08  DAS  CBSw
     *      - Revised to look for special Cadec flag for route.
     *      - Revised to redirect labels for a Cadec route to the
     *        device found in file CADECDEV.

CBSxA*    01/17/09  DAS  CBSx
     *      - CBSw to ignore belt printers.

CBSy *    06/16/09  HNK  CBSy
     *      - Print '*OFS RETURN*' in slot field for Riviera if the
     *        DSOSPC has a 'R'.

CBSzA*    08/16/10  RBD  CBSz
     *      - Fix: Changed name of ORDP3 to ORDP5.
     *----------------------------------------------------------------
     *
CB1aA*    10/11/10  HNK  CB1a
     *      - Added logic to print BIGPALC2 label and print "Merge" on
     *        pick label for new PIR zone FLRPIR that they have created
     *        See Keith's email dated 10.6.10.

CB1bA*    10/29/10  JCJ  CB1b
     *      - Per Keith Sanders changed PIR zone FLRPIR to print on
     *        device PRTPAL2.

CB1cA*    11/24/10  DAS  CB1c
     *      - Revised loction of printing DRY merge labels to occur
     *        after DK-243. Actually, we will use the lblvl2 group
     *        number assigned in DFPICK. DK-243 is the last slot in
     *        group 6.

CB1dA*    12/13/10 DAS CB1d
     *      - Revised to print "PK Next" label for "FLRPIR" zone.
     *        Unlike other PK Next logic, only printing one PK Next
     *        label for the label#, not one for each physical label
     *        printed.

CB1eA*    01/28/13  RBD  CB1e
     *      - Adjunct to 650a mod.  Since Cheney does not yet use
     *        the opuplv option, assume it to be set to 'N'.  If and
     *        when they do use opuplv, CB1e should be disabled.
     *
     *----------------------------------------------------------------
     *
CB2 A*    07/14/09  JCJ  CB2 A
     *      - discontinue printing big pallet label for export
     *        templates.  (PRE-PICK, CONTAINER, MEAT-INSP)

CB2bA*    08/13/13  JCJ  CB2b
     *      - grab the 3rd and 4th position of route instead of the
     *        2nd and 3rd for the pallet label.

CB2cA*    06/07/14  MLB  CB2c  P#01218
     *      - Revised pgm to not send label to printer PRTPAL3 for GWB.
     *        Per Keith S. phone call.

CB2dA*    06/07/14  MLB  CB2d  P#01218
     *      - Revised pgm to print merge labels at end of fixed labels
     *        instead of in the middle.

CB2eA*    09/16/14  JCJ  CB2e
     *      - Revised pgm to print big pallet label to GWPLTL for GWB.

CB2fA*    10/13/14  DAS  CB2f
     *      - Revised to print combo label for PK's for GWB.

CB2gA*    08/02/13  JDG  CB2g
     *      - Revised to replace the hard coded items number range
     *      - 997 to 999 series comparison with the validation of
     *      - the value loaded in Piritem/Itactv field,if the value
     *      - found is "99" the item is within series 997 to 999.

CB2hA*    07/07/15  JCJ  CB2h
     *      - Enh:  Added Cheney to Big Pallet Label.

CB2iA*    08/31/15  JCJ  CB2i
     *      - Enh:  Added PFMTPR5 for printing big pallet label.

CB2jA*    10/08/15  JCJ  CB2j
     *      - Commented out custom code for Dept=FRZ and Aisle>FE.
     *        This will put those items back with the normal pick
     *        items.
     *      - Added code for default printer for Big pallet label.

CB2kA*    10/15/15  JCJ  CB2k
     *      - Added Big Pallet overrides for Punta Gorda.

CB2lA*    10/22/15  JCJ  CB2l
     *      - Exclude Punta Gorda from ZZ999 logic.  Per Keith Sanders

CB2mA*    11/04/15  JCJ  CB2m
     *      - Enh:  Added end label for use with a cutter.

CB2nA*    02/27/16  JCJ  CB2n
     *      - Enh:  Added cheney to from - to stop logic for pallet
     *              label.

CB2oA*    09/01/16  JCJ  CB2o
     *      - Enh:  Added ovrdbf to prtpal3.
     *      - Enh:  Added OCALA BIGPAL ovrdbf.

CB2pA*    10/11/16  MLB  CB2p
     *      - Fix: Added code missed from CBIc mod that retrieves
     *        dock door from OHMISC in positions 13-14.

CB2qA*    10/11/16  JCJ  CB2q
     *      - Fix: Do not print end label for batch picks.
     *
CB2rA*    11/21/16  JCJ  CB2r
     *      - Enh: Change BIGRIV overrides per email from Tam.
     *
CB2sA*    11/22/16  JCJ  CB2s
     *      - Enh:  Do not print Zone header label if there is no
     *              item detail associated with the zone.
     *
CB2tA*    01/26/17  MLB/JCJ  CB2t
     *      - Enh:  Revised routine PRTLBL to use LABEL11 to look up
     *              label rcd when $pcm = *SHORT or *SHORTM and $pgen = 2.
     *              CBI doesn't assign piece nbrs to child zone items but
     *              instead assigns them to the Merge labels. Pgm is using
     *              child zone label nbr to look up piece numbers.
     *
CB2uA*    01/27/17  MLB/JCJ  CB2u
     *      - Enh:  Revised routine PRTLBL to use LABEL11 to look up
     *              label rcd when $pcm = *SHORT or *SHORTM and $pgen = 2.
     *              CBI doesn't assign piece nbrs to child zone items but
     *              instead assigns them to the Merge labels. Pgm is using
     *              child zone label nbr to look up piece numbers.
     *
CB2vA*    03/17/17  JCJ  CB2v
     *      - Enh:  Added subroutines for Big Pallet Overrides for
     *              Pate Dawson - BIGGO, BIGGR, BIGST.
     *
CB2wA*    03/25/17  JCJ  CB2w
     *      - Enh:  Change to allow BIG Pallet label to print for
     *              will call routes if Greenboro.
     *
CB2xA*    03/27/17  JCJ  CB2x
     *      - Hard code slot numbers for 999 items.  Routine ZZ999
     *        added for Pate Dawson warehouses.
     *
CB2yA*    03/30/17  JCJ  CB2y
     *      - For Greensboro, route the big pallet labels based on
     *        the second digit of the route number.
     *
CB2zA*    04/04/17  JCJ  CB2z
     *      - Do not print the Big Pallet label for Pate Dawson
     *        locations if the truck is a WILL-CALL.
     *
     *----------------------------------------------------------------
CB3aA*    04/28/17  JCJ  CB3a
     *      - FIX: Dock Door missing on Label due to field empty
     *
CB3bA*    05/25/17  JCJ  CB3b
     *      - FIX: Added Merge pallet label PSGEN > 1 logic to the
     *             Big pallet reprint.
     *
CB3cA*    05/31/17  JCJ  CB3c
     *      - Exclude Ocala from ZZ999 logic.  Per Ignacio
     *
CB3dA*    07/07/17  JCJ  CB3d
     *      - Changed PRD zone for BIGPAL label to print at PRTPAL3.
     *
CB3eA*    07/13/17  JCJ  CB3e
     *      - Change (BIGPG) to print the FREE zone for BIGPAL label
     *        on device PRTPAL.  Added Default Device to BIGPG.
     *
CB3FA *    07/20/18  NLK  CB3F
      *      - Change (BIGPG) to print the FREE zone for Templt 2 and 9
      *        plus SUB for Templt 9 only.
      *      - IN bigpg=Move 'FREE' from PRTPAL to PRTPRD2
CB3fA*    10/03/17  JCJ  CB3f
     *      - Revised pgm to print big pallet label to PRTMLKP for
     *        MLK.
CB3gA*    10/17/17  MLB  CB3g
     *      - Revised pgm to retrieve dock door from OHMISC for MLK
     *        whse.
     *      - Added CB3g to CB2p mod.
CB3hA*    06/09/18  MLB/JCJ  CB3h (was CB3d)
     *      - Revised pgm to print big pallet labels for Tifton, GA.
     *        Per Hemant K.
CB3iA*    06/11/18  MLB/JCJ  CB3i (was CB3e)
     *      - Revised pgm to add Tifton to CB2p mod for printing dock
     *        doors. Per Hemant K.
     *
CB3jA*    12/28/17  RBD  CB3j
     *      - Print label# passed in ($plbl#) rather than the value
     *        of lblbl#, which in the case of merge/PIR labels is
     *        the M type label.  Per Keith they want it to print the
     *        O type label, which is the one passed in.
CB3kA*    03/27/18  NLK  CB3k
     *      - MLK to RIV - Pick MLK items, send to RIV and RIV will
     *        ship product to clients. CustName is NULL for these.
     *        PICK label if NULL 'Do Not Print'.
     *        BIGPAL label if NULL print extra label BIGPALXD
     *      - Exclude zz999 if XDK FRZ slot
     *      - FIX: if XDD was last record, it didn't print ZONPKUP
     *
CB3lA*    05/07/18  JCJ  CB3l
     *      - Enh: Allow Warehose Department 'DRY' items to enter
     *             ZZ999 processing.
     *      - Fix: Changed CBSq mod to use LBITEM instead of
     *             lb_lbitem.
     *      - Fix: Changed dsppck from position 21 to 17 in DSMISC.
CB3mA*    03/27/18  NLK  CB3m      (700n)
     *      - Enh: Added AMP box code/used with OCA to RIV logic
     *      - OCA to RIV - Cross Dock, missing item description
CB3nA*    01/30/19  JCJ  CB3n
     *      - Riv - Add PO to PICK, PICK2, PICK3, PICKM
     *
CB3oA*    02/28/19  NLK  CB3o
     *      - Enh: Added Big Pallet Label Rte range 8800-8899
     *        even if it is CONTAINER, etc...
CB3pA*    12/05/19  NLK  CB3p
     *      - Enh: Cheney wants ORIG trn# instead of 'M' when
     *        *SHORTM -- move $ptrn# instead of newest lable value
CB3tA*    01/03/19  NLK  CB3t
     *      - RePrint doesn't contain Dock Door
CB3PA*    02/24/20  JCJ  CB3P  (merge code but NO lines for cbist)
     *      - Change to allow dock door retrival for Statesville from
     *        the dock door table instead of OHMISC.
CB3qA*    03/24/20  JCJ  CB3q
     *      - Enh: Do not print pallet label for CBIRIV if the Zone
     *             Template = '*TMPL006'
CB3rA*    05/20/20  JCJ  CB3r
     *      - Enh: do not print Big pallet label for route 9995.
CB3sA*    04/27/21  NLK  CB3s
     *      - Enh: if WLSPCL, get ext ord#
CB3tA*    01/26/21  NLK  CB3t
     *      - Enh: zz999 - skip if statesville, cbist
CB3uA*    07/19/21  JCJ  CB3u
     *      - Enh: do not print Big pallet label in Stateville for
     *             truck 'PICK-PACK'.
CB3vA*    09/24/21  JCJ  CB3v
     *      - Enh: added PICKC - Pick Child Zone label
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Chain indicator
     *  90        Overflow indicator for exception report
     *  91        Overflow indicator for catch weight report
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpltsum3   if   e           k disk
510hAFpltsum3t  if   e           k disk    rename(psrec:psrec3t)
720aAFpltsum3rp if   e           k disk    rename(psrec:psrec3rp)
700lAFpltsum4p  if   e           k disk    rename(psrec:psrec4p)
700lAFpltsum8   if   e           k disk    rename(psrec:psrec8)
7001AFpltsum12  if   e           k disk    rename(psrec:psrec12)
ctwtMFpltsum13  if   e           k disk    rename(psrec:psrec13)
700lAFpltsum15  if   e           k disk    rename(psrec:psrec15)
     Fpltstp1   if   e           k disk
SFGmAFLabel     if   e           k disk
SFGmAF                                     rename(lbrec:lbrec0)
SFGmAF                                     prefix(lb_)
     FLabel3    if   e           k disk
640cAFLabel7    if   e           k disk    rename(l7rec:lb07) Prefix(B)
640cAFLabel11   if   e           k disk    rename(lbrec:lb11) Prefix(A)
     FLabel31   if   e           k disk
     FLabel32   if   e           k disk
ISYcAFLabel32i  if   e           k disk
530aAFLabel33p  if   e           k disk
     FLabel32c  if   e           k disk
FSHdAFLabel32d  if   e           k disk
CTWcAFLabel32e  if   e           k disk
SFGd FLabel32g  if   e           k disk
640cAFLabel32x  if   e           k disk
MJKbAFLabel32s  if   e           k disk
PFCaAFLabel32j  if   e           k disk
     FLabel33   if   e           k disk
750bAFLabel76   if   e           k disk    Prefix(T)
     Fpiritem   if   e           k disk
     Fitemlnk   if   e           k disk
NCSbAFitemmsc   if   e           k disk
VIPhAFitemdsc   if   e           k disk
     Foptions   if   e           k disk
520hAFoptionz   if   e           k disk
     FLblfmth   if   e           k disk
     FLblfmtd   if   e           k disk
     FLblfmtv   if   e           k disk
640uD *label     if   e           k disk    rename(LBREC:LBREC0)
CCPaAFlabel94   if   e           k disk    rename(LBREC:LBREC94)
MATaAFordp2     if   e           k disk
CBSzMFordp5     if   e           k disk    rename(orprec:orp5)
530 AFtruckh    if   e           k disk
640cAFzoneh     if   e           k disk
510bAFzbrlogf   uf a e           k disk
510bAFzbrlogs   uf a e           k disk
ctwaAFctwzondev if   e           k disk
640cAForddm     if   e           k disk
530bAFordh      if   e           k disk    prefix(X)
svlaAFordh4     if   e           k disk    rename(ohrec:ohrec4) Prefix(y)
CWDaAFordd      if   e           k disk
640pAFdevgrpd   if   e           k disk
640pAFdevgrpd2  uf   e           k disk    rename(ddrec:d2rec)
640pAFdevgrpr   if a e           k disk
fdisAFordhm     if   e           k disk
640fAFpirtran   if   e           k disk    prefix(Y)
640iAFtotebund1 if   e           k disk
640iAFtotebund3 if   e           k disk    rename(TBREC:TBREC3)
BIRf Fitemqty   IF   E           K DISK
ALNdAFstdtime   if   e           k disk
ALNoAFpcktime   uf a e           k disk
CLDlAFpirseq2   if   e           k disk
     F                                     rename(psqrec:psqrec2)
CLDlAFpirseq3   if   e           k disk
SVLeAFrtehed    if   e           k disk
SVLiAFslot2     if   e           k disk
SVLiAFvslot1    if   e           k disk
CBSqAFdesigsp   if   e           k disk
CBSwAFcadecrte  if   e           k disk
CBSwAFcadecdev  if   e           k disk
     Fpfmtpr    o    f  198        printer oflind(*in90)
     F                                     usropn
640cAFpfmtpr2   o    f  198        printer oflind(*in91)
640cAF                                     usropn
640cAFpfmtpr3   o    f  198        printer oflind(*in92)
640cAF                                     usropn
CSPlAFpfmtpr4   o    f  198        printer oflind(*in93)
CSPlAF                                     usropn
CB2iAFpfmtpr5   o    f  198        printer oflind(*in94)
CB2iAF                                     usropn
CLDqAFitemfld   if   e           k disk
CLDqAFlabel90   if   e           k disk    Rename(lbrec:x_lbrec)
CLDqAF                                     Prefix(x_)
CLDvAFssbxref   if   e           k disk
700wAFdocroute  if   e           k disk

750fA*----------------------------------------------------------------
750fA*  File data data structure
750fA*----------------------------------------------------------------
750fA
750fAD lorec         E ds                  extname(labelout) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *    General
     *
640cAD a3              s              1    dim(3)
     D a12             s              1    dim(12)
     D a40             s              1    dim(40)
     D a50             s              1    dim(50)
     D a58             s              1    dim(58)
     D a80             s              1    dim(80)
640cAD ts              s              3  0 dim(99)
640cAD os              s              7  0 dim(999)
640cAD cs              s              3  0 dim(999)
     *
     *
     *    Input/Output strings
     *
     D sti             s              1    dim(75)
     D sto             s              1    dim(198)
BIRd D SP              s             12    dim(35)
     *
     *    Large Characters
     *
     *
     *    Printer override
     *
JORbDD*ovrprt          s             80    dim(1) ctdata perrcd(1)
CB2eDD*ovrprt          s             80    dim(2) ctdata perrcd(1)
CB2oDD*ovrprt          s             80    dim(7) ctdata perrcd(1)
CB2oDD*ovrprt          s             80    dim(8) ctdata perrcd(1)
CB3fDD*ovrprt          s             80    dim(12) ctdata perrcd(1)
CB3hDD*ovrprt          s             80    dim(13) ctdata perrcd(1)
CB3oDD*ovrprt          s             80    dim(15) ctdata perrcd(1)
CB3oMD ovrprt          s             80    dim(16) ctdata perrcd(1)
     *
     *    Set summary total description
     *
     D ttldsc          s             40    dim(1) ctdata perrcd(1)
     *
     *    Pick time
     *
     D wds             s              9    dim(99)
     D whs             s              3  0 dim(99)
     D whd             s              5    dim(99)
     D sec             s              1    dim(99)
     D cse             s              5  0 dim(99)
     D slt             s              5  0 dim(99)
     D pal             s              7  0 dim(2)
     D pcs             s              7  0 dim(2)
     *----------------------------------------------------------------
     *  Dakota Client IDs
     *
510cA /copy qcopysrc,id#cheney
510cA /copy qcopysrc,id#cheneyo
510cA /copy qcopysrc,id#cheneyr
CB2kA /copy qcopysrc,id#cheneyp
JOR A /copy qcopysrc,id#jordano
MJK A /copy qcopysrc,id#mjkelln
      /copy qcopysrc,id#matt
CWDfA /copy qcopysrc,id#cashwa
      /copy qcopysrc,id#halsey
FFCbA /copy qcopysrc,id#fischer
CLDoA /copy qcopysrc,id#citylin
ISYaAD/copy qcopysrc,id#isupply
CPCbA /copy qcopysrc,id#cpc
CCPaA /copy qcopysrc,id#capitol
NCSaA /copy qcopysrc,id#nichola
EIf A /copy qcopysrc,id#ei
ctwaA /copy qcopysrc,id#citywho
DRYcA /copy qcopysrc,id#dairyla
DRYdA /copy qcopysrc,id#dryhano
640cA /copy qcopysrc,id#silberm
CDIaA /copy qcopysrc,id#cdi
CDIaA /copy qcopysrc,id#cdijax
GFCaA /copy qcopysrc,id#glazier
640rA /copy qcopysrc,id#ifd
SFGbA /copy qcopysrc,id#sgc
RYLaA /copy qcopysrc,id#royal
VIPbA /copy qcopysrc,id#vip
GMMaA /copy qcopysrc,id#gmm
HMWaA /copy qcopysrc,id#hmwagne
KFS A /copy qcopysrc,id#kfs
BIRxA /copy qcopysrc,id#birite
GFSaA /copy qcopysrc,id#gfs
CSP A /copy qcopysrc,id#coastal
HKWaA /copy qcopysrc,id#hkw
ELBtA /copy qcopysrc,id#ellenbe
GLPaA /copy qcopysrc,id#glp
SVLbA /copy qcopysrc,id#saval
FRF A /copy qcopysrc,id#frf
YHAaA /copy qcopysrc,id#yhata
PFCaA /copy qcopysrc,id#pfc
      /copy qcopysrc,id#swt
CPJaA /COPY QCOPYSRC,id#cpj
     *----------------------------------------------------------------
     *  Customer id
500gA*
500gaD                 ds
500gAD  client                 1     10
500gAD  cliloc                11     20
     D @getcl          c                   const('GETCLIENT')

730eA*----------------------------------------------------------------
730eA*  Standard variables
730eA*----------------------------------------------------------------

730eAD/copy qcopysrc,c#stdvar

750fA*----------------------------------------------------------------
750fA*  Standard SQL variables and constants
750fA*----------------------------------------------------------------
750fA
750fA /copy qcopysrc,c#stdsql

730eA*----------------------------------------------------------------
730eA*  Program information data structure
730eA*----------------------------------------------------------------

730eAD/copy qcopysrc,c#pgminfds

730eA*----------------------------------------------------------------
730eA*  Called program prototypes
730eA*----------------------------------------------------------------

730eAD/copy qcopysrc,p.exordh
640cA*----------------------------------------------------------------
640cA*  Misc field mappings
640cA*----------------------------------------------------------------

DRY A /Copy qcopysrc,ordhm1_dry
DRYfA /Copy qcopysrc,ordhm2_dry
ctwwA /Copy qcopysrc,ohmisc_ctw
GFSmA /Copy qcopysrc,ohmisc_gfs
SLBaA /Copy qcopysrc,orddm2_rtx
NCSgA /Copy qcopysrc,ordhm1_dts
GFCgA /copy qcopysrc,ordhm2_vip
NCSgA /Copy qcopysrc,ohmisc_nch
cwduA /Copy qcopysrc,orddm1_cwd
cwdjA /Copy qcopysrc,orddm2_cwd
SFGiA /copy qcopysrc,orddm1_sgc
HMWaA /copy qcopysrc,orddm1_hmw
GFSaA /copy qcopysrc,orddm1_gfs
CPCbA /Copy qcopysrc,ohmisc_cpc
CPCbA /Copy qcopysrc,orddm1_cpc

     *----------------------------------------------------------------
     *  *SYSTEM  -  System options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
640xA*    OPWRNC  -  Check CW variance during selection closing (N,M,C,B)
640xA*    OPRG1C  -  Catch weight low variance percentage.
640xA*    OPRG2C  -  Catch weight high variance percentage.
640xA*    OPIMPI  -  Import item fields from host.(Y,N).
640xA*    OPICW   -  Check CW count during selection closing (N,M,C,B)
640xA*    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
640xA*    OPRCDY  -  Number of days to keep receiving logs.
640xA*    OPMPCK  -  Number of days to keep picking logs.
640xA*    OPRTHS  -  Number of weeks - exported routes to keep.
640xA*    OPCRHS  -  Number of weeks - exported customer rtns to keep.
640xA*    OPPOHS  -  Number of weeks - exported p/o's to keep.
640xA*    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
640xA*    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
640xA*    OPTBJQ  -  Run Truck Builder on Job Que (Y,N).
640xA*    OPISHS  -  Number of weeks to keep history file
640xA*    OPUCI   -  Use UCI processing (Y,N)
640xA*    OPWRNCR -  Check CW variance during receiving closing (N,M,C,B)
640xM*    OPICWR  -  Check CW count during receiving closing (N,M,C,B)
640xA*    OPTRAX  -  Using TRAX module (Y,N).
640xA*    OPTAXR  -  Using TAXR module (Y/N).
640xA*    OPCHKR  -  Using CHKR module (Y/N).
640xA*    OPVOICE -  Using VOICE module (Y/N).
650fA*    OPSLOT  -  Print Slot barcode on pick label (Y/N).
     *
     * Data structure
     *
     D opdat1          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
640xAD  opletd                 4      4
640xAD  opwrnc                 5      5
640xAD  oprg1c                 6      8  1
640xAD  oprg2c                 9     11  1
640xAD  opimpi                12     12
640xAD  opicw                 13     13
640xAD  opmpck                14     14
640xAD  oprcdy                15     15  0
640xAD  oppkdy                16     16  0
640xAD  oprths                17     19  0
640xAD  opcrhs                20     22  0
640xAD  oppohs                23     25  0
640xAD  opiahs                26     28  0
640xAD  opmshs                29     31  0
640xAD  optbjq                32     32
640xAD  opishs                33     35  0
640xAD  opuci                 36     36
640xAD  opwrncr               37     37
640xAD  opicwr                38     38
640xAD  optrax                39     39
640xAD  optaxr2               40     40
640xAD  opchkr2               41     41
640xAD  opvoice               42     42
650fAD  opslot                43     43
     D  opten2               117    117
530aA*----------------------------------------------------------------
530aA*  *GENPICK -  General picking options.
530aA*----------------------------------------------------------------
530aA*
530aA* Fields
530aA*
530aA*    OPERPT  -  Print exception (short) error report (Y,N).
530aA*    OPELBL  -  Print exception (short) labels (Y,N)
530aA*    OPRFWC  -  Using RF will call (Y,N).
530aA*    OPNRSC  -  Number of pallet sections (1-9).
530aA*    OPHPWC  -  Host pick Will Call (Y/N).
530aA*    OPMRGA  -  Merge Add-on order(s) with Open Routes.
530aA*    OPPLSQ  -  Pallet number sequence. 1=Unload, 2=Load.
530aA*    OPEADJ  -  Close short labels without adjustment (Y,N).
530aA*    OPNOPK  -  Pick items without pick slot as bulk pick? (Y/N)
701dA*    OPGPK1  -  <Not Used / Available>
701dA*    OPGPK2  -  <Not Used / Available>
530aA*    OPCLRF  -  Clear runner flag if qty still short/out? (Y/N)
530aA*    OPRNRM  -  Send break message to user when new Flag Runner
530aA*               task has been assigned. (Y/N)
530aA*    OPJITR  -  Create JIT Letdown or JIT Replenishment (L/R)
640yA*                 0=None. No replenishments are created.
640yA*                 1=Letdowns are created during Truck Builder
640yA*                   Pick/Print processing.
640yA*                 2=Priority Replenishments are created during
640yA*                   Truck Builder Pick/Print processing.
640yA*                 3=JIT Letdowns created when transaction is
640yA*                   checked out.
640yA*                 4=JIT Priority Replenishments created when
640yA*                   transaction is checked out.
530aA*    OPPSET  -  Print separate set summary label for each pallet.
640yA*    OPRFUC  -  RF Pick Verify item with UPC.
640yA*    OPRFLC  -  RF Pick Verify item with license.
640yA*    OPUSF1  -  USF Option: Allow merge items for stop to be split.
640yA*               across truck pallets.
640yA*    OPRFSL  -  RF Pick Verify slot (Y/N)
701dA*               Y=Yes
701dA*               N=No
701dA*               C=Scan Check Digit
701dA*               E=Enter to Continue
640yA*    OPRBN1  -  Round robin printing compatable (Y/N)
640yA*    OPRBN2  -  Round robin Type
640yA*               1=Off
640yA*               2=By route
640yA*               3=By transaction
640yA*    OPSUBT  -  Allow Customer Item Substitution (Y/N)
701dA*    OPRFPM  -  RF Pick Method
701dA*               1=Manual
701dA*               2=Directed
701dA*    OPRPLT  -  Print Pallet Label
701dA*               1=Normal
701dA*               2=Big
701dA*               3=Both
701dA*               4=No
530aA*
530aA* Data structure
530aA*
530aAD oppdta          ds
530aAD  operpt                 1      1
530aAD  opelbl                 2      2
530aAD  oprfwc                 3      3
530aAD  opnrsc                 4      4  0
530aAD  ophpwc                 5      5
530aAD  opmrga                 6      6
530aAD  opplsq                 7      7
530aAD  opeadj                 8      8
530aAD  opnopk                 9      9
701dMD  opgpk1                10     10
701dMD  opgpk2                11     11
530aAD  opclrf                10     10
530aAD  oprnrm                11     11
530aAD  opjitr                12     12
530aAD  oppset                13     13
640yAD  oprfuc                14     14
640yAD  oprflc                15     15
640yAD  opusf1                16     16
640yAD  oprfsl                17     17
640yAD  oprbn1                18     18
640yAD  oprbn2                19     19
640yAD  opsubt                20     20
701dAD  oprfqt                21     21
701dAD  oprfcs                22     22
701dAD  oprUSF                23     26
701dAD  oprfqto               27     29
701dAD  oprfpm                30     30
701dAD  oprplt                31     31
     *----------------------------------------------------------------
     *  Medium stop number data structures.
     *
     D                 ds
     D  ch1                    1    120
     D                                     DIM(12)
     D  stp11                  1     10
     D  stp12                 11     20
     D  stp13                 21     30
     D  stp14                 31     40
     D  stp15                 41     50
     D  stp16                 51     60
     D  stp17                 61     70
     D  stp18                 71     80
     D  stp19                 81     90
     D  stp110                91    100
     D  stp111               101    110
     D  stp112               101    120
     D                 ds
     D  ch2                    1    120
     D                                     DIM(12)
     D  stp21                  1     10
     D  stp22                 11     20
     D  stp23                 21     30
     D  stp24                 31     40
     D  stp25                 41     50
     D  stp26                 51     60
     D  stp27                 61     70
     D  stp28                 71     80
     D  stp29                 81     90
     D  stp210                91    100
     D  stp211               101    110
     D  stp212               101    120
     *----------------------------------------------------------------
     *  Stop summary data structure for one set of labels.
     *  Maximum of 9 stops on one pallet, for fixed section items.
     *  Maximum of 99 stops on one pallet, for PIR section items.
     *
     D stpsum          ds                  occurs(99)
     D  dssstp                 1      2  0
510eMD  dsscub                 3      9  3
700fDD* dsswgt                10     16  2
510eMD  dsspcs                17     20  0
510eMD  dsscnm                21     60
530aAD  dspal#                61     67  0
SvlhAD  dssord                68     74  0
700fAD  dsswgt                75     83  2
     *----------------------------------------------------------------
     *  Pallet summary data structure for one set of labels.
     *
     D palsum          ds                  occurs(9)
     D  dsppal                 1      7  0
     D  dspstp                 8      9  0
700fDD* dspwgt                16     22  2
     D  stp                   26     43  0
     D                                     DIM(9)
     D  dsppli                44     50  0 inz
     D  dsprti                51     55
     D  dsstp1                56     57  0
     D  dsstp2                58     59  0
510eAD  dspcub                65     71  3
510aAD  dsppcs                72     76  0
CPCcAD  dspgtm                77     83  3
700fAD  dspwgt                84     92  2
     *----------------------------------------------------------------
     *  PIR stop summary data structure for route.
     *
     D pirsum          ds                  occurs(99)
     D  dsrstp                 1      2  0
     D  dsrcub                 3      8  3
     D  dsrwgt                 9     15  2
     D  dsrpcs                16     18  0
     D  dsrwdp                19     23
     D  dsrcnm                24     63
     D  dsrflg                64     64
     *----------------------------------------------------------------
     *  Zone pickup summary data structure
     *
     D zonpku          ds                  occurs(20)
     D  dszstp                 1      2  0 inz
     D  dszpcs                 3      7  0 inz
     D  dszitm                 8     22
     D  dszdsc                23     52
     D  dszplt                53     59  0 inz
     D  dszpsi                60     61
CBIxAD  dszds2                62     91
CBIxAD  dszpck                92    106
     *----------------------------------------------------------------
VIPa D                 ds
VIPa D  lidisp                 1     12
SFGa D  linine                 1      1
SFGa D  liasle                 2      2
SFGoDD* liloc                  3      4
SFGoMD  liloc                  3      5
SFGoDD* lilvl                  5     12
SFGoMD  lilvl                  6     12
     *----------------------------------------------------------------
VIPa D                 ds
SFGa D  didisp                 1     12
SFGa D  dinine                 1      1
SFGa D  dids1                  2      2
SFGa D  diasle                 3      3
SFGa D  dids2                  4      4
SFGoDD* diloc                  5      6
SFGoMD  diloc                  5      7
SFGoDD* dids3                  7      7
SFGoMD  dids3                  8      8
SFGoDD* dilvl                  8     12
SFGoMD  dilvl                  9     12
640pA*----------------------------------------------------------------
640pA*  Zone printer round robin printer list
640pA*----------------------------------------------------------------
640pAD zonprt          DS                  OCCURS(50)
640pAD  device                 1     10
     *----------------------------------------------------------------
     D                 ds
     D  wksdte                 1      8
     D  wkmm                   1      2
     D  wksl1                  3      3
     D  wkdd                   4      5
     D  wksl2                  6      6
     D  wkyy                   7      8
     *----------------------------------------------------------------
CBIbAD                 ds
CBIbAD  dsdisp                 1     12
CBIbAD  ds1                    1      1
     *----------------------------------------------------------------
     D                 ds
     D  dsmsc1                 1     40
     D  dscitm                 1     15
     D  dssrp                 16     27
     *----------------------------------------------------------------
     D                 ds
     D  dsmsc2                 1     40
     *----------------------------------------------------------------
     D                 ds
     D  dsmsc3                 1     40
     *----------------------------------------------------------------
     D                 ds
     D  dsmsc4                 1     40
GFScA*----------------------------------------------------------------
GFScAD                 ds
     D  itminq                 4      8  2 inz(0)
     D  itrcvd                 1      8  0 inz(0)
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
     *    OPPDEV  -  Printer device.
     *    OPPFRM  -  Printer form.
520kA*    OPAISL  -  Print aisle change label (Y/N).
520iA*    OPTAXR  -  Include in Tax Right (Y=Yes, N=No).
520iA*    OPCHKR  -  Include in Check Right (Y=Yes, N=No).
650cA*    OPFLBL  -  Reprint from label.
650cA*    OPTLBL  -  Reprint to label.
     *
     * Data structure
     *
520iMD opdta2          ds
     D  opclvl                 1      3  0
     D  opcwra                 4      4
     D  opcwrb                 5      5
     D  opuwra                 6      6
     D  opuwrb                 7      7
     D  optext                 8     50
     D  operr                 51     52  0
     D  opcwgt                53     54  0
     D  oplpgm                55     64
     D  oppdev                65     74
     D  oppfrm                75     84
520kAD  opaisl                85     85
520iAD  optaxr                86     86
520iAD  opchkr                87     87
650cAD  opflbl                88     94  0
650cAD  optlbl                95    101  0
     D  optend               117    117
     *----------------------------------------------------------------
520iA*  *PICKLBA -  Label printing options for the standard pick,
520iA*              retail, and tote labels.
     *
520iA*     08/12/09  RBD  5.20  P#00219
520iA*       - Added record type *PICKLBA which holds printing info
520iA*         for the standard pick, retail, and tote labels.
     *
     *----------------------------------------------------------------
     * Fields
     *
     *    OPLB1   -  Print standard pick label Y/N.   - Standard pick label
     *    OPCU1   -  Use cutter option Y/N.           - Standard pick label
     *    OPLP1   -  Label printing program.          - Standard pick label
     *    OPDV1   -  Printer device.                  - Standard pick label
     *    OPFM1   -  Form.                            - Standard pick label
     *
     *    OPLB2   -  Print retail label Y/N.          - Retail label
     *    OPCU2   -  Use cutter option Y/N.           - Retail label
     *    OPLP2   -  Label printing program.          - Retail label
     *    OPDV2   -  Printer device.                  - Retail label
     *    OPFM2   -  Form.                            - Retail label
     *
     *    OPLB3   -  Print tote label Y/N.            - Tote label
     *    OPCU3   -  Use cutter option Y/N.           - Tote label
     *    OPLP3   -  Label printing program.          - Tote label
     *    OPDV3   -  Printer device.                  - Tote label
     *    OPFM3   -  Form.                            - Tote label
     *
     * Data structure
     *
     D opdta3          ds
     D  oplb1                  1      1
     D  opcu1                  2      2
     D  oplp1                  3     12
     D  opdv1                 13     22
     D  opfm1                 23     32
     D  oplb2                 33     33
     D  opcu2                 34     34
     D  oplp2                 35     44
     D  opdv2                 45     54
     D  opfm2                 55     64
     D  oplb3                 65     65
     D  opcu3                 66     66
     D  oplp3                 67     76
     D  opdv3                 77     86
     D  opfm3                 87     96
     D  opend3               117    117
     *----------------------------------------------------------------
520iA*  *PICKLBB -  Label printing options for the pick list and
520iA*               ASN labels and pick list report.
     *
520iA*     08/12/09  RBD  5.20  P#00219
520iA*       - Added record type *PICKLBB which holds printing info
520iA*         for the pick list and ASN labels and pick list report.
     *
     *----------------------------------------------------------------
     * Fields
     *
     *    OPLB4   -  Print pick list label Y/N.       - Pick list label
     *    OPCU4   -  Use cutter option Y/N.           - Pick list label
     *    OPLP4   -  Label printing program.          - Pick list label
     *    OPDV4   -  Printer device.                  - Pick list label
     *    OPFM4   -  Form.                            - Pick list label
     *
     *    OPLB5   -  Print ASN label Y/N.             - ASN label
     *    OPCU5   -  Use cutter option Y/N.           - ASN label
     *    OPLP5   -  Label printing program.          - ASN label
     *    OPDV5   -  Printer device.                  - ASN label
     *    OPFM5   -  Form.                            - ASN label
     *
     *    OPLB6   -  Print pick list report Y/N.      - Pick list report
     *    OPCU6   -  Use cutter option Y/N.           - Pick list report
     *    OPLP6   -  Label printing program.          - Pick list report
     *    OPDV6   -  Printer device.                  - Pick list report
     *    OPFM6   -  Form.                            - Pick list report
     *
530 A*    OPLB7   -  Print PICK labels for ZONPKUP 1/2- Pick labels
     *
     * Data structure
     *
     D opdta4          ds
     D  oplb4                  1      1
     D  opcu4                  2      2
     D  oplp4                  3     12
     D  opdv4                 13     22
     D  opfm4                 23     32
     D  oplb5                 33     33
     D  opcu5                 34     34
     D  oplp5                 35     44
     D  opdv5                 45     54
     D  opfm5                 55     64
     D  oplb6                 65     65
     D  opcu6                 66     66
     D  oplp6                 67     76
     D  opdv6                 77     86
     D  opfm6                 87     96
530 AD  oplb7                 97     97
     D  opend4               117    117
520hA*----------------------------------------------------------------
520hA*  *PICK  -  Picking options
520hA*
520hA*----------------------------------------------------------------
520hA*
520hA* Fields
520hA*
520hA*    OPNXTP  -  Next pallet number.
520hA*    OPBPCK  -  Bulk pick definition.
520hA*    OPPCUB  -  Maximum cube for PIR.
520hA*    OPFPAL  -  Pallets on fixed fork lift.
520hA*    OPFCUB  -  Maximum cube per fixed pallet.
520hA*    OPFSTP  -  Maximum stops per fixed pallet.
520hA*    OPINCL  -  Include PIR in fixed cube.
520hA*    OPSRCH  -  Number of previous pallets to search for space.
520hA*    OPFBLD  -  Fixed pallet building method.
520hA*                1 = By piece without concern for splitting stop.
520hA*                2 = By stop without splitting stop between plts.
520hA*    OPPBRK  -  Aisle to start new pallet.
520hA*    OPPBLD  -  Pallet building method.
520hA*                1 = By stop then slot location.
520hA*                2 = By slot location then stop.
520hA*                3 = By descening stop, then slot location.
520hA*    OPSELM  -  Selection method.
520hA*                1 = Single pass (By location).
520hA*                2 = Multiple pass (By stop).
520hA*    OPSPLT  -  Allow stop to be split across pallets (Y/N).
520hA*    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
520hA*    OPNWPL  -  Start new pallet when aisle changes if build method
520hA*               is 2=Location.
520hA*    OPFORD  -  Maximun orders per pallet.
520hA*    OPPTYP  -  Pallet type (P=Pallet, T=Tote, B=Batch).
520hA*    OPFTOT  -  Maximum totes per pallet.
520hA*    OPTECB  -  External tote cube.
520hA*    OPTICB  -  Internal tote cube.
520hA*    OPTSTP  -  Maximum stops per tote.
520hA*    OPTPCS  -  Maximum pieces per tote.
520hA*    OPSTOP  -  Honor *SP flag (Y=Yes, N=No).
520hA*    OPGCDE  -  USF Group Code (0-9).
520hA*    OPPKUP  -  Picked up by (S=Selector, L=Loader).
520hA*    OPSPAL  -  Merge pallet should only contain
520hA*               items for single truck pallet (Y=Yes, N=No).
520hA*    OPPITM  -  Maximum items per pallet.
520hA*
520hA* Data structure
520hA*
520hAD opdta1          ds
520hAD  opnxtp                 1      7  0 inz(0)
520hAD  oppcub                10     14  2 inz(0)
520hAD  opfpal                15     15  0 inz(0)
520hAD  opfcub                16     20  2 inz(0)
520hAD  opincl                22     22
520hAD  opsrch                23     24  0 inz(0)
520hAD  opfstp                25     26  0 inz(0)
520hAD  opfbld                27     27  0 inz(0)
520hAD  opbpck                28     30  0 inz(0)
520hAD  oppbrk                31     33
520hAD  oppbld                34     34
520hAD  opselm                35     35
520hAD  opsplt                36     36
520hAD  opbmrg                37     37
520hAD  opnwpl                38     38
520hAD  opford                39     40  0 inz(0)
520hAD  opptyp                41     41
520hAD  opftot                42     43  0 inz(0)
520hAD  optecb                44     48  2 inz(0)
520hAD  opticb                49     53  2 inz(0)
520hAD  optstp                54     55  0 inz(0)
520hAD  optord                56     57  0 inz(0)
520hAD  optpcs                58     60  0 inz(0)
520hAD  opstop                61     61
520hA** Note: Pos 62 is OPGCDE for USF, but OPPKUP for all other clients.
520hAD**opgcde                62     62
520hAD  oppkup                62     62
520hAD  opspal                63     63
520hAD  oppitm                64     67  0 inz(0)
520hAD  opend1               117    117
650aA*----------------------------------------------------------------
650aA*  *VOICE  -  PIR Voice options.
650aA*----------------------------------------------------------------
650aA*
650aA* Fields
650aA*
650aA*    OPINCP  -  Include pack description (Y/N)
650aA*    OPCRTR  -  Create RUNNER entries for shorts (Y/N)
650aA*    OPUPLV  -  Update Label with quantity picked during Voice
650aA*               selection (Y/N)
650aA*               NOTE: Any change to this field will cause OPUPLR
650aA*                     in the *RUNNER options record to be updated.
650aA*    OPVMRG  -  Create Runner entries for Merge records? (Y/N)
650aA*    OPOUTF  -  Create Runner entry after slot marked out. (Y/N)
650aA*    OPFCLR  -  Clear Runner flag if qty still short/out? (Y/N)
650aA*               NOTE: Any change to this field will cause OPCLRF
650aA*                     in the *RUNNER options record to be updated.
650aA*    OPVMLT  -  Allow multiple transaction (Y/N)
650aA*    OPVSPN  -  Speak pallet number (Y/N)
650aA*    OPVSPZ  -  Speak pallet zone (Y/N)
650aA*    OPVSLW  -  Speak large quantity warning (Y/N)
650aA*    OPVSUW  -  Speak unit of measure change warning (Y/N)
650aA*
650aA* Data structure
650aA*
650aA*----------------------------------------------------------------
650aA
650aAD opvdta          ds
650aAD  opincp                 1      1
650aAD  opcrtr                 2      2
650aAD  opuplv                 3      3
650aAD  opvmrg                 4      4
650aAD  opoutf                 5      5
650aAD  opfclr                 6      6
650aAD  opvmlt                 7      7
650aAD  opvspn                 8      8
650aAD  opvspz                 9      9
650aAD  opvslw                10     10
650aAD  opvcep                11     11
650aAD  opvssn                12     12
650aAD  opvcpz                13     13
650aAD  opvend               117    117

     *----------------------------------------------------------------
     *  Variable sample data
     *
     D                 ds
     D  lfvdta                 1     50
     D  dsn020                 1      2  0
     D  dsn030                 1      3  0
     D  dsn050                 1      5  0
     D  dsn063                 1      6  3
     D  dsn070                 1      7  0
     D  dsn072                 1      7  2
     D  dsn100                 1     10  0
     D  dsn110                 1     11  0
     *
     D                 ds
     D  dsmisc                 1     20
CBIcAD  dssdte3                1      8
     D  dsmm                   1      2
     D  dsdd                   3      4
     D  dsyy                   5      6
CBIcAD  dsspcl                 9     11
CBIcAD  dsrpck                12     12
CB2pAD  dsdoor                13     14
CBIdAD  dsmeat                15     15
     D  dssdte                16     19p 0
CB3lMD  dsppck                17     17
CBSn D  dsrvia                19     19
     D  dssub                 20     20
CB3lD * dsppck                21     21
BIRa *
BIRa D                 ds
BIRa D  dsmisc2                1     20
BIRa D  dscmp#                 1      3
BIRa D  dsdivn                 4      6
BIRa D  dsdept                 7      9
BIRa D  dswhse                10     12
BIRa D  dsmemo                13     15
BIRa D  dssdte2               16     19p 0
BIRa D  dspins                20     20
     *
CBIcAD                 ds
CBIcAD  dsoitm                 1     15
CBIcAD  dsaitm                 1      6
CBIcAD  dsf1                   7      7
CBIcAD  dsaloc                 8     14
CHYp D  dslifo                 1      7
CHYv D  dsospc                15     15
     *
CBIaAD                 ds
CBIaAD  dscust                 1     10
CBIaAD  ds8                    1      8
CBIaAD  ds2                    9     10
     *
CBIhAD                 ds
CBIhAD  dsord2                 1      7
CBIhAD  dso5                   1      5
CBIhAD  dso2                   6      7
SFG  *
SFGf D                 ds
SFGf D  dsdsc2                 1     40
SFGf *
SFGf D  dspds1                 1     15
SFGf D  dspds2                16     30
SFGf *
     D                 ds
     D  wkshmo                 1      2
     D  wkshdy                 3      4
     D  wkshyr                 5      6
     D  wkshdt                 1      6  0
     D  shipdt                 7     14
     *
     D                 ds
     D  zksdte                 1      6  0
     D  zkmm                   1      2  0
     D  zkdd                   3      4  0
     D  zkyy                   5      6  0
     *
     D                 ds
     D  pkdate                 1      8
     D  pkmm                   1      2
     D  pkds1                  3      3
     D  pkdd                   4      5
     D  pkds2                  6      6
     D  pkyy                   7      8
     *
SFGbAD                 ds
SFGbAD  todayplus1             1      8
SFGbAD  plus1mm                1      2
SFGbAD  plus11                 3      3
SFGbAD  plus1dd                4      5
SFGbAD  plus12                 6      6
SFGbAD  plus1yy                7      8
     *
     *----------------------------------------------------------------
     *  Called programs
     *
640cAD @getpl          c                   const('GETPALLET')
     D @cvtdt          c                   const('CVTDTE')
520jAD @getstop        c                   const('GETSTOP')
642cAD @gettruck       c                   const('GETTRKTMPL')
BIRdAD @getspcl        c                   const('GETSPCLINS')
FRF AD @getdesc        c                   const('INI160')
650lAD @getlabelps     c                   const('GETLABELPS')
700kAD @getpltvid      c                   const('GETPLTVID')
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
SFGbAD  $cvdr1               133    140
SFGbAD  $cvvl1               141    145  0
SFGbAD  $cvdr2               146    153
SFGbAD  $cvvl2               154    158  0
SFDbAD  $cvdr3               159    166
SFDbAD  $cvvl3               167    171  0
SFDbAD  $cvdr4               172    179
SFDbAD  $cvvl4               180    184  0
     *----------------------------------------------------------------
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lrtid                22     26
     D  $ltrn#                27     33  0
     D  $lwhdp                34     38
     D  $ldoor                39     41  0
     *
     *----------------------------------------------------------------
     *  Constants
     *
     D @desc1          c                   const('Pallet total')
ctwaAD Retail          c                   const('RETAIL')
ctwaAD Candy           c                   const('CANDY')
ctwaAD Tobacco         c                   const('TOBACO')
640cAD Cig011          c                   const('CIG011')
640cAD Cig091          c                   const('CIG091')
ctwbAD Mez032          c                   const('MEZ032')
ct2aAD Phn132          c                   const('PHN132')
ctwbAD Mez101          c                   const('MEZ101')
ctwaAD Tote            c                   const('TOTE  ')
ctwaAD Totefrm         c                   const('TOTE  ')
ctwaAD Slot            c                   const('Slot:')
ctwaAD Order           c                   const('Order:')
ctwaAD Quantity        c                   const('Qty:')
ctwaAD Item            c                   const('Item#')
ctwaAD Lot             c                   const('Lot#:')
ctwaAD Lot25           c                   const('_________________________')
SFGkAD @side           c                   const('SIDE')
CDIfAD @reprint        c                   const('Reprint')
CCPaAD ccpspec         c                   const('Critical Care Customer')
GFSmAD gfsspec         c                   const('*** Critical Care ***')
CCPcAD ccpsch          c                   const('School Pre-Pick')
640gAD ToteHdg         c                   const('Tote  ')
640gAD PalletHdg       c                   const('Pallet')
CSPlAD bigpal          c                   const('BIGPAL')
GFSlAD addon           c                   const('**ADDON**')
650gAD @audit          c                   const('AUDIT')
650jAD @heavy          c                   const('HEAVY')
WIFaAD WoodPalletText  c                   const('Wood Pallet')
     *----------------------------------------------------------------
     D xup             c                   const('ABCDEFGHIJKLMNOPQRST-
     D                                     UVWXYZ')
     D xlo             c                   const('abcdefghijklmnopqrst-
     D                                     uvwxyz')
     *
     D insp            c                   const('*INSPECT*')
     D rpck            c                   const('No Repack')
     D @meat           c                   const('MEAT-INSP')
     D prepck          c                   const('*PRE-PICK*')
     D @prepk          c                   const('PRE-PICK')
     D @sp             c                   const('*SP       ')
     D @cntnr          c                   const('CONTAINER ')
     D @wilcl          c                   const('WILLCALL  ')
     D @wlcl           c                   const('WILL-CALL ')
     D @sudsv          c                   const('SUD-SVC   ')
     D @damag          c                   const('DAMAGES   ')
     D @rvia           c                   const('RTE-VIA')
CBSy D retrn           c                   const('*OFS RETURN*')
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D*               sds
730? D* #prog            *proc
     D* #job                 244    253
     D* #user                254    263
     D* #jobn                264    269
     D* #jobdt               276    281  0
     D* #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Variables
     *
CCPaAD ccpchk          s              3
CCPcAD ccpchks         s              1
510bAD logzebra        s               n
510bA *forever         s               n
700iAD leaveopen       s               n
ctwaAD tobaccoflag     s               n
ctwaAD retailflag      s               n
ctwjAD cigaretflag     s               n
ctwaAD candyflag       s               n
ctwaAD totzon          s               n
700bAD bigpallabel     s               n
CDIaAD $cwhse          s              3
CDIaAD $ccode          s             10
CDIaAD $chhdr          s              1
CDIaAD $chdtl          s              1
CDIaAD $chcat          s              1
     D $nadec          s              2  0
     D $nafp           s              2  0
     D $nanum          s             11  0
     D #from           s             10
     D @len            s              3  0
     D @outpt          s            198
     D @pal#           s                   like(pspal#)
     D @plid           s              7  0
     D @psect          s              2
     D @qty1           s                   like(w1pick)
     D @qty2           s                   like(w1qty)
     D @rtid           s              5
     D @stp1           s              2  0
     D @stp2           s              2  0
     D @var            s              3  0
     D ax              s              2  0
     D ay              s              2  0
CBSwAD blankZone       s                   like(cdvzon)
CBSwAD                                     Inz(' ')
BIRx D c#qpck          s              5  0
JORcAD charpos         s              3  0
     D cmbwrd          s              7
650aAD cntTrax         s              4  0
750fDD*combo           s              1
750fMD combo           s               n
     D count           s              5  0
     D curcol          s                   like(pscol)
     D curpal          s              2  0
     D currow          s                   like(psrow)
     D curunl          s                   like(psunld)
BIRx D cwent1          s              7
BIRx D cwent2          s              7
BIRx D cwent3          s              7
BIRx D cwent4          s              7
BIRx D cwent5          s              7
SFGkAD lstunl          s                   like(psunld)
     D cwtime          s              5  2
     D dpos            s              2  0
     D dszcnm          s             30
640dAD fdiPass         s              3  0
     D dtlcnt          s              3  0
     D fc              s              3  0
     D first           s              1
     D first2          s              1
     D forevr          s              1
     D frdesc          s             30
     D fritem          s             15
     D cbimrg          s              1
510bAD GoodHit         s              1    Inz('0')
VIPdAD imp_flg         s              1
730eD *i               s              2  0
ctwaAD icount          s              2  0
     D ip              s              3  0
     D ix              s             48
     D k               s              3  0
cwdgAD kycode          s                   like(opzcod)
     D kyfmt           s                   like(lfdfmt)
720iAD kygen           s                   like(psgen)
     D kyltyp          s                   like(lbtype)
CB2tAD kylbl#          s                   like(lblbl#)
     D kytype          s                   like(pstype)
     D kyvnum          s                   like(lfvnum)
cwdgAD kyzone          s                   like(opzzon)
     D lbls            s              3  0
     D lc              s              3  0
CB1dAD lastLBL#        s                   like(lblbl#)
     D ln              s              3  0
     D lstlb#          s                   like(lblbl#)
     D lstpid          s                   like(psplid)
     D lststp          s                   like(lbstop)
     D lsttrn          s                   like(lbtrn#)
     D lstum           s                   like(lbutyp)
     D lstwdp          s                   like(lbwhdp)
     D lstzon          s                   like(psszon)
     D maxsti          s              2  0
     D maxsto          s              3  0
     D meatpr          s              1
MJKcAD mjkContract     s               n
     D n               s              3  0
     D nrbigl          s              3  0
     D num1            s              1  0
     D num2            s              1  0
     D op              s              3  0
     D openedpfmtprt2  s              1
     D openedpfmtprt3  s              1
CSPlAD openedpfmtprt4  s              1
CB2iAD openedpfmtprt5  s              1
CSPlAD opfm4a          s             10    inz('BIGP')
     D outwrd          s              3
HMWaAD subwrd          s              3    inz('SUB')
     D pal#            s              7  0
     D palcnt          s              2  0
     D pcktim          s              5  2
     D pcktm0          s              5  0
     D ppckpr          s              1
     D prtall          s              1
     D prtflg          s              1
BIReAD p1              s              3  0
BIReAD p2              s              3  0
     D remain          s              2  0
     D shdcnt          s              3  0
JORcAD strnglen        s              3  0
     D ssdcnt          s              3  0
     D ssocur          s              3  0
BIRd D svord           s              7  0
CSP AD svpdev          s                   like(oppdev)
CSP AD svpfrm          s                   like(oppfrm)
     D stpcnt          s              2  0
     D svaisl          s              3
     D svtype          s              1
     D t#brkr          s              8
BIRx D t#brnd          s             10
     D t#cs12          s             12
     D t#cust          s             11
     D t#desc          s             44
     D t#dsc1          s             40
     D t#dsc2          s             40
     D t#spcl          s             15
     D t#truk          s             10
700xXD t#zdsc          s             12
     D temp1a          s              1
     D temp1n          s              1  0
     D temp10          s             10
     D temp3a          s              3
     D temp40          s             40
ctwaAD temp50          s              5  0
ctwaAD temp5a          s              5
     D temp72          s              7  2
     D temp7a          s              7
ctwaAD temp8           s              8
640cAD temp9           s              9
CBSuAD temp9a          s              9
CSPlAD temp10a         s             10
ctwaAD temp12a         s             12
     D tenpos          s              2  0
     D tmpzon          s                   like(psszon)
     D today           s              8  0
     D todesc          s             30
     D toitem          s             15
     D toqty           s              5  0
     D totpi#          s              7  0
     D totrn#          s                   like(lbtrn#)
     D totwrd          s              3
     D toum            s              5
     D ttlcub          s              8  3
     D ttlpcs          s              7  0
     D ttlwgt          s              9  2
MATaAD unqpiece#       s                   like(orpup#)
     D vflag           s              1
     D wktime          s              5  2
     D w1cse           s              5  0
     D w1ctim          s              5  2
     D w1invc          s              8
     D w1pal#          s                   like(lbpal#)
     D w1pick          s                   like(lbqpck)
     D w1qty           s                   like(lbqpck)
     D w1qty2          s                   like(lbqpck)
     D w1sec           s              1
     D w1slt           s              5  0
     D w1stim          s              5  2
     D w1wds           s              9
     D w1whdp          s              5
     D w1whs           s              3  0
     D w1whse          s              3
BIRd D wkcmp#          s              3
BIRd D wkdivn          s              3
BIRd D wkdept          s              3
BIRd D wkcusn          s             10
BIRd D wkord           s              7  0
730eD *x               s              3  0
     D x1              s              3  0
730eD *y               s              3  0
     D y1              s              3  0
     D zontyp          s              5
     D zpdcnt          s              3  0
     D zpikup          s              1
     D zpitem          s             15
     D zpocur          s              3  0
cdicAD cdiPass         s              3  0
ctwaAD retailprice     s              7
ctwaAD pricecode       s              5
ctwaAD datecode        s              2
ctwaAD retailrows      s              5  0
ctwaAD retailleft      s              3  0
ctwaAD retline1        s             50
ctwaAD retline2        s             50
ctwaAD retline3        s             50
ctwaAD retline4        s             50
ctwaAD retlot1         s             50
ctwaAD retlot2         s             50
ctwaAD retlot3         s             50
ctwaAD retlot4         s             50
ctwaAD statejurcode    s              3
ctwaAD statejurname    s             15
ctwaAD countyjurcode   s              3
ctwaAD countyjurname   s             15
ctwaAD cityjurcode     s              3
ctwaAD cityjurname     s             15
ctwaAD toteq1          s              3
ctwaAD toteq2          s              3
ctwaAD dealcode        s              5
ctweAD recapflag       s              1
ctwfAD taxamount       s              8
ctwoAD recapjurname1   s             15
ctwqAD recapjurname2   s             15
ctwqAD recaptaxamt     s              8
520bAD wkstmp          s             12
ctwuAD txstamptn       s             12  0
ctwyAD wktrn#          s              7
ctwzAD done            s              1
530bAD extStop         s              3
520eAD cwdqtyfld       s             15
GFScAD eachqtyfld      s             20
520fAD workcus         s             46
520aAD savtrn          s                   like(pstrn#)
520dAD pckqty          s                   like(lbqpck)
730eD *error           s              1
520hAD one             s              5  0 inz(1)
520hAD kycod1          s                   like(opzcod)
520iAD kycod3          s                   like(opzcod)
520iAD kycod4          s                   like(opzcod)
CWDaAD alpha5          s              5
530 AD $ptmpl          s             10
520jAD $pordr          s              7  0
520jAD $phstp          s              5  0
520jAD $pdstp          s              2  0
520jAD work4           s              4  0
520jAD work3           s              3  0
520jAD work2           s              2  0
530 AD work2a          s              2
530 AD work7a          s              7
DRYhAD work17a         s             17
CB3nAD work20a         s             20
530 AD t#pal#          s              7  0
530cAD work6           s              6  0
530cAD work6a          s              6
530cAD work8a          s              8
730gAD work11a         s             11
730gAD work11b         s             11
530cAD mdy             s               D   DatFmt(*MDY)
CWDaAD mmddyy          s              6  0
CWDaAD shipdate        s              8
CWDaAD CityState       s             24
640pAD pdocur          s              3  0
640pAD maxcount        s              3  0
640pAD qcmd            s             80
640pAD MPFlag          s              1
640pAD prefix          s              1    inz('<')
640pAD opened          s              1    inz('0')
730eD *#pgm            s             10
640pAD $aut            s              1
640pAD $ubrobn         s              1    inz('2')
640pAD svopdv1         s             10
530gAD svtrn#          s              7  0
CLDqAD fabitems        s               n
CPCbAD PrintColor      s             10
530dAD worklbl         s             10
CPCcAD goaltime        s              7  3
NCSaAD wkdisp          s             11
DRYdAD wkdisp2         s             12
640iAD lasttote        s               n
NCSbAD wkvnam          s             25
NCSdAD cmb1            s                   like(w1pick)
NCSdAD cmb2            s                   like(w1pick)
NCSdAD lblcnt          s                   like(w1pick)
640kAD svutyp          s              1
640cAD zonfrm          s             10
642aAD truckPallet     s              7  0
GFCaAD $pstr           s             60
GFCaAD $plen           s              3  0 inz(15)
GFCaAD work15          s             15
GFCeAD zpdcount        s              1  0
650cAD printlabel      s               n
650dAD stopdrop        s              9
     D chkfab          s             10
     D clddry          s              1
     D wrksum          s              7  0
     D cldmrg          s              8
CBI  D endtyp          s              8
     D nxtseq          s              4  0
     D pcksum          s              7  0
     D skpdry          s              1
     D seqfld          s              6
     D tempn1          s              1  0
     D tempn2          s              2  0
     D tempn3          s              3  0
650gAD auditflag       s              1
SVLbAD work5           s              5  0
SVLbAD cust5           s              5
svleAD mdy2            s              6
svleAD iso             s              8  0
svleAD deliverydate    s              8
DRYfAD deliverydate2   s             10
svleAD mdyDate         s               d   datfmt(*mdy)
svleAD isoDate         s               d   datfmt(*iso)
DRYfAD usaDate         s               d   datfmt(*usa)
svlbAD work16          s             16
SVLiAD tmpslot         s             12
FRF AD olddsc          s             34
FRF AD newdsc          s             68
FRF AD newdsc1         s             34
FRF AD newdsc2         s             34
FRF AD fmtcod          s              1
FRF AD itmnote1        s             18
FRF AD itmnote2        s             18
FRFdAD work3a          s              3
WIFaAD WoodPalletVar   s             11
DRYfAD methodofdlvry   s             30
DRYfAD cruiseshipflg   s              1
650lAD sectionstring   s             20
650lAD sectioncount    s              2  0
700kAD $command        s              9
700kAD voiceid         s              7  0
700lAD wkplid          s              7  0
700lAD wktran          s              7  0
700wAD Department1     s              1
720gAd tbEnhanced      s               n
720gAd tbPalletType    s              1
720gAd tbType          s              1
720gAd tbWhse          s              3  0
750fAD outputType      s             10
750fAd outStr          s          65535    varying
750jAd outStrZdta      s          65535    varying
750fAd sendToPrinter   s               n
750fAd saveSendToPrt   s               n
750fAd savedtlcnt      s                   like(dtlcnt)
750fAd fillb1Pass      s              1  0
750fAd kyset           s                   like(lfhset)
750jAd kysetzdta       s                   like(lfhset)
750fAd rtnCode         s             10
750fAd rtnMsg          s             99    varying
750hAd strLen          s              5  0
750fAd lastkyfmt       s                   like(kyfmt)
750fAd fmtCount        s              5  0
750xMd varFlag         s              1  0 dim(1000) inz(0)

750fA*----------------------------------------------------------------
750fA*  WRTIFS Variables
750fA*----------------------------------------------------------------
750fA
750fAd wCmd            s             10
750fAd wPath           s            256    varying
750fAd wFileName       s            128    varying
750fAd wLine           s           3072    varying
750fAd wFileId         s             10I 0 dim(4)
750fAd wRtn            s             10
750fad wMessage        s             60
750fAd wLabelCount     s              5  0 dim(4)
750fAd wFileCount      s              3  0 dim(4)
750fAd wStamp          s               z
ifs Ad ccFlag          s               n   dim(4)
ifs Ad xaFlag          s               n   dim(4)
ifs Ad prFlag          s               n   dim(4)

     *----------------------------------------------------------------
     *  Called Program Prototypes
     *----------------------------------------------------------------

720gAd/copy qcopysrc,p.gettbtyp

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

750fAd IFSWriteLine    pr
750fAd  fileNum                       3  0 const

750fAd WriteLABELOUT   pr

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   Command
     *              *TEST1   -  Print test labels - no merge.
     *              *TEST2   -  Print test labels - merge sample data.
750fA*              *BLTTEST  -  Print belt printer test label
     *              *REPLEN  -  Print potential replenishments.
500 A*              *PR321   -  Print Breakdown Priority Replenishment
510gA*              *PRTLBL  -  Print single label. Label# is sent in
510gA*                          field $PLBL#.
700gA*              *BEGEND  -  Print SETHED and SETEND label.
700iA*              *SETSUM  -  Print Set Summary label only.
700iA*              *CLOSE   -  Seton *INLR when done printing Batch
700iA*                          labels.
650cA*              *PRTZON  -  Reprint by Pick Zone.
650cA*              *PRTTRN  -  Reprint by Transaction Number.
650cA*              *RPRTLB  -  Reprint by Label Range.
     *      $PLSET  Label set
     *      $PLFMT  Label format (used for testing)
     *      $PWHSE  Warehouse
     *      $PRTID  Route Id
     *      $PCOMP  Compartment
     *      $PTZON  Truck zone
     *      $PGEN   Generation
     *      $PSZON  Slot zone
     *      $PTRUK  Truck
     *      $PRTE   Route
     *      OPZDTA  Picking label options
     *      $PTRN#  Transaction number for reprints
     *              Batch number for *REPL
     *      $PLBL#  Label number
     *      $PQTY
     *      $PCWT#
750fA*      $pOutType  Output type
750fA*                   ' ' = Normal
750fA*                   'N' = Normal
750fA*                   'I' = Write to IFS files
750fA*                   'Q' = Ouptut to QPRINT
750fA*                   'O' = Only output to LABELOUT file
750fA*                         (*PRINT must be sent - See Notes above)
     *                    anything else = Normal spool file output
     *
     *    Returned Parameters
750fA*      $pRtnCode  Optional parm initially used with SelectPrime
750fA*      $pRtnMsg   Optional parm initially used with SelectPrime
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $plset            6
     C                   parm                    $plfmt            8
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $pcomp            1
     C                   parm                    $ptzon            6
     C                   parm                    $pgen             1 0
     C                   parm                    $pszon            6
     C                   parm                    $ptruk           10
     C                   parm                    $prte             5
     C                   parm                    opzdta
     C                   parm                    $ptrn#            7 0
     C                   parm                    $plbl#            7 0
     C                   parm                    $pqty             5 0
     C                   parm                    $pcwt             7 2
750fAC                   parm                    $pOutType         1
750fAC                   parm                    $pRtnCode        10
750fAC                   parm                    $pRtnMsg         99
     *----------------------------------------------------------------
     *  Main line
     *

720aA /free

720aA  wStamp = %timestamp();

720aA  if %parms >= 17;

720aA    select;

720aA      when $pOutTYpe = 'I';
720aA        outputType = 'IFS';
750fA        sendToPrinter = *off;

720aA      when $pOutType = 'Q';
720aA        outputType = 'QPRINT';
750fA        sendToPrinter = *on;

750fA      when $pOutType = 'O';
750fA        outputType = 'LABELOUT';
750fA        sendToPrinter = *off;

720aA      other;
720aA        outputTYpe = 'NORMAL';
750fA        sendToPrinter = *on;

720aA    endsl;

720aA  else;
720aA    outputTYpe = 'NORMAL';
750fA    sendToPrinter = *on;

720aA  endif;

750fA  rtnCode = '';
750fA  rtnMsg = '';
750fA  if %parms >= 18;
750fA    $pRtnCode = '';
750fA    $pRtnMsg = '';
750fA  endif;
750fA
750fA  if $pcmd = '*BLTTEST';
750fA    kyfmt = 'BLTTEST';
750fA    exsr fillb1;
750mD    //return;
750mM    *inlr = *on;
750fA  endif;
750fA
720aA /end-free

700iAC                   if        $pcmd = '*CLOSE'
700iAC                   eval      leaveopen = *off
700iAC                   goto      bottom
700iAC                   endif
700iA*
700iA* Set belt printer flag.
700iA*
700iAC                   if        $pcmd = '*PICK   '
700iAC                             or $pcmd = '*BEGEND '
700iAC                             or $pcmd = '*BEGIN  '
700iAC                             or $pcmd = '*END    '
700iAC                             or $pcmd = '*SHORT  '
700iAC                             or $pcmd = '*SHORTM '
700iAC                             or $pcmd = '*MERGE  '
700iAC                             or $pcmd = '*PRTTRN '
700iAC                             or $pcmd = '*RPRTLB '
700iAC                   eval      prtall = *off
700iAC                   else
700iAC                   eval      prtall = *on
700iAC                   endif
     *
510bAC* Do zbrlog initialization
510bAC*
510bAC                   exsr      zzzInzZbrLog
MJKcA*
MJKcA*  For MJ Kellner check for Contract route.
MJKcA*
MJKcAC                   if        client = mjkellner
MJKcAC                   if        %subst($prte:1:2)='CC'
MJKcAC                   eval      mjkContract = *on
MJKcAC                   else
MJKcAC                   eval      mjkContract = *off
MJKcAC                   endif
MJKcAC                   endif
520hA*
520hA*  Get zone options.
520hA*

520hA*  PCKLBL
520iAC                   eval      opdta2 = opzdta
640cAC                   eval      cigaretflag = *off
640cAC                   select
CTWaAC                   when      client = citywholesale
CTWaAC                             and $pszon = Cig011
CTWaAC                   when      client = citywholesale
CTWaAC                             and $pszon = Cig091
640cAC                   eval      cigaretflag = *on
640cAC                   when      optaxr = 'Y'
640cAC                   eval      cigaretflag = *on
CSP A*
CSP AC                   when          client = coastalsunbelt
CSP AC                             and $pcmd  = '*SHORT'
CSP AC                   eval      svpdev = oppdev
CSP AC                   eval      svpfrm = oppfrm
CSP A*
640cAC                   endsl
cwdgA*
cwdgA* Get zone type.
cwdgA*
cwdgAC                   eval      kycode = '*PICK   '
cwdgAC                   eval      kyzone = $pszon
520hAC                   eval      opptyp = *blanks
cwdgAC     keyopz        chain     optionz
520hAC                   if        %found(optionz)
520hAC                   eval      opdta1 = opzdta
520hAC                   endif
520iA*
640cAC                   if        not %found(optionz)
640cAC                             or opptyp <> 'T'
640cAC                   eval      totzon = *off
640cAC                   else
640cAC                   eval      totzon = *on
640cAC                   endif
     *
520iAC                   eval      opdta3 = *blanks
520dAC                   eval      kycod3 = '*PICKLBA'
520iAC     opzkya        chain     optionz
520iAC                   if        %found(optionz)
520iAC                   eval      opdta3 = opzdta
520iAC                   else
520iAC                   eval      oplp1 = oplpgm
520iAC                   endif

640wAC                   eval      retailflag = *off
640wAC                   if        oplb2 = 'Y'
640wAC                   eval      retailflag = *on
640wAC                   endif
     *
640wAC                   eval      candyflag = *off
CTWaAC                   if        client = citywholesale
640wAC                             and $pszon = Candy
640wAC                   eval      candyflag = *on
640wAC                   endif

CTWaAC                   eval      tobaccoflag = *off
CTWaAC                   if        client = citywholesale
CTWaAC                             and $pszon = Tobacco
CTWaAC                   eval      tobaccoflag = *on
CTWaAC                   endif

520iA*
520iA* do not print standard pick labels
520iA*
520iAC                   if        oplb1 = 'N'
640cAC                             and oplb2 = 'N'
640cAC                             and oplb3 = 'N'
750fAC                   eval      rtnCode = 'NOOUTDEF'
750fAC                   eval      rtnMsg = 'No output defined for zone '
750fAC                                    + %trim($ptmpl) + '/' + $pszon
520iAC                   goto      bottom
520iAC                   endif

640pA*  Call user added initialization routine.

640pAC                   exsr      zzinz
520iA*
520iAC                   eval      kycod4 = '*PICKLBB'
520iAC                   eval      opdta4 = *blanks
520iAC     opzkyb        chain     optionz
520iAC                   if        %found(optionz)
520iAC                   eval      opdta4 = opzdta
520iAC                   endif
ctwaA*
ctwnMC                   movea     *zeros        ts
ctwnAC                   movea     *zeros        os
ctwnAC                   movea     *zeros        cs
     *
     * Get format header record.
     *
640cAC                   if        oplb1 = 'Y'
520iAC                   eval      $plset = %subst(oplp1:5:6)
640cAC                   endif
640cA*
640cAC                   if        oplb2 = 'Y'
640cAC                   eval      $plset = %subst(oplp2:5:6)
640cAC                   endif
640cA*
640cAC                   if        oplb3 = 'Y'
640cAC                             and oplb1 = 'N'
640cAC                             and oplb2 = 'N'
640cAC                   eval      $plset = %subst(oplp3:5:6)
640cAC                   endif
750fA*
750fA* When creating LABELOUT recs, verfiy set exists for belt printer
750fA*
750fA /free
750fA     if outputType = 'LABELOUT';
750fA       kyset = 'BLT' + %subst($plset: 4: 3);
750fA       chain (kyset) lblfmth;
750fA       if not %found(lblfmth);
750fA         lfhslg = '';
750fA         rtnCode = '*BLTNOTFND';
750fA         rtnMsg  = 'Belt label set ' + %trim(kyset) + ' not found';
750fA /end-free
750fAC                   goto      bottom
750fA /free
750fA       endif;
750fA     endif;
750fA /end-free
750fA*
750fA* Verify label set exists
750fA*
     C     keylfh        chain     lblfmth                            79
     C                   if        *in79
     C                   eval      lfhslg = *blanks
750fAC                   eval      rtnCode = '*SETNOTFND'
750fAC                   eval      rtnMsg  = 'Label set ' + %trim($plset) + ' '
750fAC                                      + 'not found'
640cAC                   goto      bottom
     C                   endif
svlhA*
svlhA* Get orh record to determine order type
svlhA*
svlhAC     keyzbr        chain     ordh4
svlhAC                   if        not %found(ordh4)
svlhAC                   eval      yohtype = *blanks
svlhAC                   endif
     *
     * Count detail lines of summary labels.
     *
     C                   exsr      cntshd
     C                   exsr      cntssd
     C                   exsr      cntzpd
svleA*
svleA* Get route header record
svleA*
svleAC                   exsr      getrtehed
GFCeA*
GFCeA* Count zone detail records.
GFCeA*
GFCeAC                   exsr      cntzhd
     *
     * Open printer file for zone.
     *
640yAC                   select
CSP AC                   when          client = Coastalsunbelt
CSP AC                             and $pcmd = '*SHORT'
CSP A* use standard printing for short label printing.
CSP AC                   eval      opdv1 = svpdev
CSP AC                   eval      opfm1 = svpfrm
CSP AC                   exsr      opnprt
CSP A*
640yAC                   when      oprbn1 = 'N'
640yA* use standard printing
640yAC                   exsr      opnprt
640yMC                   when      mpflag = 'N'
640yA* use standard printing
640pAC                   exsr      opnprt
640pAC                   other
640yA* use round robin printing
640pAC                   exsr      opnprt2
640yMC                   endsl
     *
     * Check to see if this is only a test.
     *
     C                   if        $pcmd = '*TEST1  '  or
     C                             $pcmd = '*TEST2  '
     C                   exsr      test1
     C                   goto      bottom
     C                   endif

700lA* Reprint pallet label
700lAC                   select
700lAC                   when      $pcmd = '*RPRTP1'
700lAC                             or $pcmd = '*RPRTP2'
700lAC                             or $pcmd = '*RPRTP3'
700lAC                   exsr      lblPltRePrint
700lAC                   goto      bottom
700lAC                   endsl
     *
     * Print zone heading label.  (Not for Belt Printer)
     *
CBIhAC     zonkey        chain     zoneh                              79
CBIhAC                   if        *in79
CBIhAC                   eval      t#zdsc = *blanks
CBIhAC                   else
CBIhAC                   movel     zhdesc        t#zdsc
CBIhAC                   endif
     *
     C                   if        $pcmd = '*ZONDSC'
     C                   exsr      lblzds
     C                   eval      leaveopen = *on
     C                   goto      bottom
     C                   endif
700iA*
700iAC                   if        $pcmd = '*SETSUM'
700iAC                   exsr      SetSumLbl
700iAC                   goto      bottom
700iAC                   endif
500 A*
500 A* Print Breakdown priority replenishments
500 A*
CTLxAC                   select
CTLxAC                   when      client = cityline
CTLyAC                             and $pcmd = '*PR321  '
500 AC                   exsr      prtrp3
500 AC                   goto      bottom
CTLxAC                   other
500 AC                   if        $pcmd = '*PR321  '
640cAC                             and (oplb1 = 'Y'
640cAC                             or oplb2 = 'Y')
500 AC                   exsr      prtrp3
500 AC                   goto      bottom
500 AC                   endif
CTLxAC                   endsl
     *
     * Print zone heading label.
     *
520 AC                   if        $pcmd <> '*PRTLBL '
520cAC                             and $pcmd <> '*SHORT  '
650aAC                             and $pcmd <> '*SHORTM '
650aAC                             and prtall = *on
640cAC                             and (oplb1 = 'Y'
640cAC                             or oplb2 = 'Y')
cwdqAC                             and client <> cashwa
GFCeAC                   select
GFCeAC                   when      client = GFC
GFCeAC                             and zpdcount <> *zeros
GFCeAC                   exsr      lblzhd
BIRgA*
BIRgAC                   when      client = birite
BIRgAC                   if        $ptruk <> 'WILLCALL'
BIRgAC                   exsr      lblzhd
BIRgAC                   endif
     *
700iAC                   when      client = cheney
CBIhAC                             and prtall = *on
CB2rAC                             and zpdcount <> *zeros
CBIhAC                   exsr      lblzds
     C                   exsr      lblzhd
     *
CHYu * Print Will Call Special instruction label for Will call
     *
CHYu C                   if        $ptruk = @wilcl
CHYu C                             or $ptruk = @wlcl
CHYu C                             or $ptruk = @sudsv
CHYu C                   exsr      lblwsp
CHYu C                   endif
     *
GFCeAC                   when      client <> GFC
CB2rAC                             and client <> cheney
     C                   exsr      lblzhd
GFCeAC                   endsl
520 AC                   endif
     *
     * Print potential replenishments
     *
     C                   if        $pcmd = '*REPLEN '
640cAC                             and (oplb1 = 'Y'
640cAC                             or oplb2 = 'Y')
     C                   if        opletd = 'Y'
     C                   exsr      prtprp
     C                   endif
     C                   goto      bottom
     C                   endif
     *
     * Print letdowns for zone.
     *
     C                   if        opletd = 'Y'
520 AC                             and $pcmd <> '*PRTLBL '
520cAC                             and $pcmd <> '*SHORT  '
650aAC                             and $pcmd <> '*SHORTM '
700iAC                             and prtall = *on
640cAC                             and (oplb1 = 'Y'
640cAC                             or oplb2 = 'Y')
     C                   exsr      prtrpl
     C                   endif
     *
     * Print bulk picks for zone.
     *
520 AC                   if        $pcmd <> '*PRTLBL '
520cAC                             and $pcmd <> '*SHORT  '
650aAC                             and $pcmd <> '*SHORTM '
700iAC                             and prtall = *on
640cAC                             and (oplb1 = 'Y'
640cAC                             or oplb2 = 'Y')
     C                   exsr      prtblk
520 AC                   endif
     *
     * Print selection labels for zone.
     *
     *    Note: First the pallet summary records will be read
     *          and the information saved.  Then, when the
     *          transaction number changes, we go and print
     *          the labels for the previous transacton
     *          number (LSTTRN).
640dA*
640dA*    Do 2 passes.
640dA*      First pass is normal pass for PSTYPE 'O'
640dA*      Second pass if for specisl PSTYPE 'L'
640dA*
640dAC                   for       fdiPass = 1 to 2
     *
     *    Loop through truck pallets for zone.
     *
     C                   eval      first = *on
     *
640dAC                   if        fdiPass = 2
640dAC                   eval      kytype = 'L'
640dAC                   eval      palcnt = 0
640dAC                   else
720fDC**                 eval      kytype = 'O'
720gMC                   eval      kytype = tbPalletType
640dAC                   endif
ctwtMC                   select
ctwtAC                   when      client = citywholesale
ctwtMC     keyps3        setll     pltsum13
720aAC                   when      client = cheney
720aA **-> if location             and cliloc = cbiocl
720aAC     keyps3rp      setll     pltsum3rp
ctwtMC                   other
     C     keyps3        setll     pltsum3
ctwtMC                   endsl
     C                   dou       forevr <> forevr
ctwtMC                   select
ctwtAC                   when      client = citywholesale
ctwtAC     keyps3        reade     pltsum13                               79
720aAC                   when      client = cheney
720aA **-> if location             and cliloc = cbiocl
720aAC     keyps3        reade     pltsum3rp                              79
ctwtAC                   other
     C     keyps3        reade     pltsum3                                79
ctwtAC                   endsl
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *     Skip pallet if nothing was picked.
     *
     C                   if        pspcs = 0
     C                   iter
     C                   endif
416cA*
416cA*     Skip pallet if tran# = 0 and pallet contains bulk pick.
416cA*     In that case we assume that the pallet only contains a
416cA*     bulk pick and was not assigned a tran# in OR630.
416cA*
416cAC                   if        pstrn# = 0  and
416cAC                             psbcnt <> 0
720gAC                             and not tbEnhanced
416cAC                   iter
416cAC                   endif
750bA*
750bAC                   if        tbEnhanced
750bAC                   eval      tlbtrn# = 0
750bAC                   eval      tlbtype = 'M'
750bAC     keylb76       setll     label76
750bAC     keylb76       reade     label76
750bAC                   if        not %eof(label76)
750bAC                   if        tlbstat = 'C'
750bAC                   iter
750bAC                   endif
750bAC                   endif
750bAC                   endif
640bA*
640bA*     Skip pallet if $pcmd = *PRTTRN and pstrn# <> $ptrn#.
640bA*
640bAC                   if        $pcmd = '*PRTTRN '
640bAC                             and pstrn# <> $ptrn#
640bAC                   iter
640bAC                   endif
650cA*
650cA*     Skip pallet if $pcmd = *RPTRLB and pstrn# <> $ptrn#.
650cA*
650cAC                   if        $pcmd = '*RPRTLB '
650cAC                             and pstrn# <> $ptrn#
650cAC                   iter
650cAC                   endif
700iA*
700iA*     Look for specific tran# when not printing all labels.
700iA*
700iAC                   if        prtall = *off  and
700iAC                             pstrn# <> $ptrn#
700iAC                   iter
700iAC                   endif
     *
     *     First time through initialization.
     *
     C                   if        first = *on
     C                   eval      lsttrn = pstrn#
SFGkAC                   eval      lstunl = psunld
     C                   eval      palcnt = 0
     C                   eval      first = *off
     C                   endif
     *
     *     If transaction number changed, go and print the detail
     *       for the previous transaction (LSTTRN).
     *
     C                   if        pstrn# <> lsttrn
     *
     *     Get dock door for the transaction.
     *
     C                   eval      $lwhse = pswhse
     C                   eval      $lrtid = psrtid
     C                   eval      $ltrn# = lsttrn
     C                   eval      $lwhdp = *blanks
     C                   eval      $ldoor = 0
     C                   call      'DH900'
     C                   parm                    $lparm
     C                   eval      curunl = psunld
     C                   eval      currow = psrow
     C                   eval      curcol = pscol
520aAC                   eval      savtrn = pstrn#
520 AC                   if        $pcmd <> '*PRTLBL '
520cAC                             and $pcmd <> '*SHORT  '
650aAC                             and $pcmd <> '*SHORTM '
700iAC                             and prtall = *on
700jAC                   select
700jAC                   when      client = cheney
700jAC                   exsr      prtselcbi
700jAC                   other
     C                   exsr      prtsel
700jAC                   endsl
520 AC                   endif
530dA*
530dA* If printing a single label and the last trans is the
530dA* trans for the requested label, print it and get out.
530dA*
530dAC                   if        $pcmd = '*PRTLBL '
530dAC                             and $ptrn# = lsttrn
530dAC                             or $pcmd = '*SHORT  '
530dAC                             and $ptrn# = lsttrn
650aAC                             or $pcmd = '*SHORTM '
650aAC                             and $ptrn# = lsttrn
530gD ***                exsr      lblzhd
530gMC                   exsr      lblsub
530dAC                   exsr      prtlbl
530dAC                   goto      bottom
530dAC                   endif
530dA*
ctwtMC                   select
ctwtAC                   when      client = citywholesale
ctwtMC     keyps13       setll     pltsum13
ctwtMC                   read      pltsum13                               79
ctwtAC                   other
510hMC     keyps         setll     pltsum3t
510hMC                   read      PLTSUM3T                               79
ctwtMC                   endsl
     C                   eval      lsttrn = pstrn#
SFGkAC                   eval      lstunl = psunld
     C                   eval      palcnt = 0
640pAc                   if        mpflag = 'Y'
640pAc                   close     pfmtpr
640pAc                   eval      opened = *off
640pAc                   exsr      opnprt2
640pAc                   endif
     C                   endif
     *
     *     Add pallet info to pallet summary data structure.
     *
     C                   add       1             palcnt
     C     palcnt        occur     palsum
642iAC                   if        fdipass = 2
642iAC                             and opspal = 'Y'
642iAC                   eval      dsppal = pspal#
642iAC                   else
     C                   eval      dsppal = pspal#
642iAC                   endif
     C                   eval      dspcub = pscube
     C                   z-add     psswgt        dspwgt
CLDqAC                   if        client = cityln
CLDqAC                   exsr      zzcld
CLDqAC                   if        fabitems = *on
CLDqAC                   z-add     pcksum        dsppcs
CLDqAC                   else
CLDqAC                   z-add     pspcs         dsppcs
CLDqAC                   endif
CLDqAC                   else
     C                   eval      dsppcs = pspcs
CLDqAC                   endif
     C                   eval      dspstp = 0
     C                   eval      lststp = -(1)
     C                   eval      dsppli = psplid
     C                   eval      dsprti = psrtid
     C                   eval      dsstp1 = psstp1
     C                   eval      dsstp2 = psstp2
CPCcAC                   call      'GETGOALTM'
CPCcAC                   parm                    $pwhse
CPCcAC                   parm                    pstrn#
CPCcAC                   parm                    goaltime
CPCcAC                   if        goaltime <> *zeros
CPCcAC                   eval      dspgtm = goaltime
CPCcAC                   endif
     C     keyss1        setll     pltstp1
     C                   dow       forevr = forevr
     C     keyss1        reade     pltstp1                                78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   if        pssstp <> lststp
     C                   add       1             dspstp
     C                   eval      lststp = pssstp
     C                   endif
642aA
642aA*    For a loader merge pallet, where everything on the
642aA*    pallet goes onto a single truck pallet,
642aA*    get the corresponding truck pallet for the pallet summary.
642aA
642aAC                   if        psgen > 1
642aAC                             and opspal = 'Y'
642aAC                   exsr      GetTruckPlt
642aAC                   if        truckPallet <> 0
642aAC                   eval      dsppal = truckPallet
642aAC                   endif
642aAC                   endif

     C                   enddo
     *
     C                   enddo
     *
     * Check to see if we are only printing a single label.
     * Or printing labels for shorts.
     *
520 AC                   if        $pcmd = '*PRTLBL '
520cAC                             or $pcmd = '*SHORT  '
650aAC                             or $pcmd = '*SHORTM '
530gD ***                exsr      lblzhd
530gMC                   exsr      lblsub
520 MC                   exsr      prtlbl
520 MC                   goto      bottom
520 MC                   endif
     *
     *   Print last pallet(s), if any.
     *
     C                   if        palcnt > 0
     *
     *     Get dock door for the transaction.
     *
     C                   eval      $lwhse = $pwhse
     C                   eval      $lrtid = $prtid
     C                   eval      $ltrn# = lsttrn
     C                   eval      $lwhdp = *blanks
     C                   eval      $ldoor = 0
     C                   call      'DH900'
     C                   parm                    $lparm
     *
700gAC                   select
700gMC                   when      $pcmd = '*PICK   '
700gMC                             or $pcmd = '*PRTLBL '
530dAC                             and $ptrn# = lsttrn
530dAC                             or $pcmd = '*SHORT  '
530dAC                             and $ptrn# = lsttrn
650aAC                             or $pcmd = '*SHORTM '
650aAC                             and $ptrn# = lsttrn
530gD ***                exsr      lblzhd
700gMC                   if        $pcmd <> '*PICK   '
530gMC                   exsr      lblsub
700gMC                   endif
530dAC                   exsr      prtlbl
530dAC                   goto      bottom
500c *
500c C                   when      $pcmd = '*BEGEND '
500b C                   exsr      setbeg
500b C                   eval      endtyp = '*NOMRG  '
500b C                   exsr      setend
CHYx * Revised to print SETEND with *BEGIN command for Cheney
500c C                   when      $pcmd = '*BEGIN  '
500c C                   exsr      setbeg
CHYx C                   eval      endtyp = '*NOMRG  '
CHYx C                   exsr      setend
     *
500c C                   when      $pcmd = '*END    '
500c C                   eval      endtyp = '*NOMRG  '
CHYyA*
CHYyA*  Print SETHEDCB label for truck (gen=1) pallets.
CHYyAC                   if        $pgen = 1
CHYyAC                   eval      dtlcnt = 0
CHYyAC                   dow       dtlcnt < palcnt
CHYyAC                   add       1             dtlcnt
CHYyAC     dtlcnt        occur     palsum
CHYyAC                   eval      @pal# = dsppal
CHYyAC                   eval      @plid = dsppli
CHYyAC                   eval      @rtid = dsprti
CHYyAC                   eval      @stp1 = dsstp1
CHYyAC                   eval      @stp2 = dsstp2
     *
CHYyAC                   eval      kyfmt = 'SETHEDCB'
CHYyAC                   exsr      fillb1
CHYyAC                   enddo
CHYyAC                   endif
     *
     *  Print SETHED label
500iAC                   eval      lbtrn# = lsttrn
500f C                   eval      dtlcnt = 0
500f C                   dow       dtlcnt < palcnt
500f C                   eval      kyfmt = 'SETHED  '
500f C                   exsr      fillb1
500f C                   enddo
700gA*
700gAC                   when      $pcmd = '*MERGE  '
700gA* Print zone pickup for belt printer
700gAC                   eval      endtyp = '*MERGE  '
700gAC                   exsr      setend
     *
700gMC                   other
700jAC                   select
700jAC                   when      client = cheney
700jAC                   exsr      prtselcbi
700jAC                   other
     C                   exsr      prtsel
700jAC                   endsl
700gMC                   endsl
     *
700gAC                   endif
640dA*
640dA*    End of 2 pass loop.
640dA*
640dAC                   endfor
     *
     *   Bye, Bye.
     *
     C     bottom        tag
750fA /free
750fA   if %parms >= 18 and rtnCode <> '';
750fA     $pRtnCode = rtnCode;
750fA     $pRtnMsg = rtnMsg;
750fA   endif;
750fA /end-free
700iAC                   select
700iAC                   when      leaveopen = *on
700iAC                   return
700iAC                   other
     C                   eval      *inlr = *on
700iAC                   endsl
     *
     *   Close up shop and return home.
     *
     CLr                 if        opened = *on
     CLr                 close     pfmtpr
     CLr                 endif
640cA*
640cACLr                 if        openedpfmtprt2 = *on
640cACLr                 close     pfmtpr2
640cACLr                 endif
640cA*
640cACLr                 if        openedpfmtprt3 = *on
640cACLr                 close     pfmtpr3
640cACLr                 endif
CSPlA*
CSPlACLr                 if        openedpfmtprt4 = *on
CSPlACLr                 close     pfmtpr4
CSPlACLr                 endif
CB2iA*
CB2iACLr                 if        openedpfmtprt5 = *on
CB2iACLr                 close     pfmtpr5
CS2iACLr                 endif
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
500gA*
500gA* Get client id.
500gA*
500gAC                   call      @getcl
500gAC                   parm                    client
500gAC                   parm                    cliloc
500gA*
     C                   eval      forevr = *off
     C                   eval      zpikup = *off
     C                   eval      maxsti = 75
     C                   eval      maxsto = 198
ALNCAC                   eval      dids1 = '-'
ALNCAC                   eval      dids2 = '-'
SFGpAC                   if        client = sgc
SFGpAC                   eval      dids3 = *blanks
SFGpAC                   else
SFGpAC                   eval      dids3 = '-'
SFGpAC                   endif
510gAC                   eval      $ldoor = *zeros
     C                   eval      w1invc = *blanks
     C                   eval      svaisl = *blanks
     C                   eval      outwrd = *blanks
     C                   eval      wkshdt = *zeros
700bAC                   eval      bigpallabel = *off
CBIiAC                   eval      meatpr = *off
CHYbAC                   eval      ppckpr = *off
     *
510bA*  Get zebra logging flag.
510bAC*
510bAC     *DTAARA       define    zbrlog        logzebra
510bAC                   in(e)     logzebra
510bAC                   if        %error
510bAC                   eval      logzebra = *off
510bAC                   endif
CBSuA
CBSuA*  Get pallet id prefix characters
CBSuA
CBSuAC     *DTAARA       define    prefix        cbiPrefix         2
CBSuAC                   in(e)     cbiPrefix
CBSuAC                   if        %error
CBSuAC                   eval      cbiPrefix = '@@'
CBSuAC                   endif
     *
     *
     *  Define key for OPTIONS file.
     *
     C     opkey         klist
     C                   kfld                    opwhse
     C                   kfld                    opcode
MATaA*  Define partial key for ORDP2 file.
MATaA*
MATaAC     keyorp        klist
MATaAC                   kfld                    lblbl#
642gA*
642gAC     keyorp2       klist
642gA ***                kfld                    lb_lblbl#
642gAC                   kfld                    lb_lbctr#
CBSsA*
CBSzM*  Define partial key for ORDP5 file.
CBSsA*
CBSsAC     keyorp5       klist
CBSvAC                   kfld                    lbrte
CBSsAC                   kfld                    lblbl#
     *
     *  Define partial key for PLTSUM3 file.
     *
     C     keyps3        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kytype
     C                   kfld                    $pcomp
     C                   kfld                    $ptzon
     C                   kfld                    $pgen
     C                   kfld                    $pszon
720iAC     keyps3b       klist
720iAC                   kfld                    $pwhse
720iAC                   kfld                    $prtid
720iAC                   kfld                    kytype
720iAC                   kfld                    $pcomp
720iAC                   kfld                    $ptzon
720iAC                   kfld                    kygen
720iAC                   kfld                    $pszon
     *
720aA*  Define partial key for PLTSUM3RP file.
     *
     C     keyps3rp      klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kytype
     C                   kfld                    $pcomp
     C                   kfld                    $ptzon
     C                   kfld                    $pgen
     C                   kfld                    $pszon
     C                   kfld                    savtrn
     *
700lA*  Define full key for PLTSUM8 file.
     *
     C     keyps8        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    $pszon
     *
700lA*  Define partial key for PLTSUM12 file.
     *
     C     keyps12a      klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    wktran
     *
510hA*  Define full key for PLTSUM3T file.
     *
     C     keyps         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kytype
     C                   kfld                    $pcomp
     C                   kfld                    $ptzon
     C                   kfld                    $pgen
     C                   kfld                    $pszon
     C                   kfld                    curunl
     C                   kfld                    currow
     C                   kfld                    curcol
     C                   kfld                    savtrn
     *
ctw A*  Define full key for PLTSUM13 file.
     *
     C     keyps13       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kytype
     C                   kfld                    $pcomp
     C                   kfld                    $ptzon
     C                   kfld                    $pgen
     C                   kfld                    $pszon
     C                   kfld                    curunl
     C                   kfld                    currow
     C                   kfld                    curcol
700lA*
700lA*  Define key for PLTSUM15 file.
700lA*
700lAC     keyps15       klist
700lAC                   kfld                    $pwhse
700lAC                   kfld                    $prtid
700lAC                   kfld                    wkplid
     *
     *  Define partial key for PLTSTP1 file.
     *
     C     keyss1        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    psplid
     C                   kfld                    psrow
     C                   kfld                    pscol
     *
     *  Define partial key for LABEL31 file.
     *
     C     keyl31        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kyltyp
     C                   kfld                    psplid
     *
     *  Define partial key for LABEL32 & LABEL34 file.
     *
     C     keyl32        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kyltyp
     C                   kfld                    lsttrn
     *
     *  Define partial key for LABEL32 & LABEL34 file.
     *
510gACSR   key32a        klist
640uMC                   kfld                    lb_lbwhse
640uMC                   kfld                    lb_lbrte
640uMC                   kfld                    lb_lbtype
640uMC                   kfld                    lb_lbtrn#
640uMC                   kfld                    lb_lbwhdp
640uMC                   kfld                    lb_lbstyp
640uMC                   kfld                    lb_lbaisl
640uMC                   kfld                    lb_lbpseq
640uMC                   kfld                    lb_lbrlvl
640uMC                   kfld                    lb_lbhand
640gMC                   kfld                    lb_lbstop
640cA*
640cAC     keyl11        klist
640cAC                   kfld                    lblbl#
     *
     *  Define partial key for LABEL33 file.
     *
     C     keyl33        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    lsttrn
     *
BIRd *  Define partial key for LABEL33 file.
     *
BIRd C     l33key        klist
BIRd C                   kfld                    $pwhse
BIRd C                   kfld                    $prtid
BIRd C                   kfld                    lbtrn#
530aA*
530aA*  Define partial key for LABEL33P file.
530aA*
530aAC     keyp33        klist
530aAC                   kfld                    $pwhse
530aAC                   kfld                    $prtid
530aAC                   kfld                    lsttrn
     *
     *  Define partial key for LABEL94 file.
     *
CCPaAC     keyl94        klist
CCPaAC                   kfld                    $pwhse
CCPaAC                   kfld                    $prtid
CCPaAC                   kfld                    lbtrn#
     *
CCPaAC     keyl94a       klist
CCPaAC                   kfld                    $pwhse
CCPaAC                   kfld                    $prtid
CCPaAC                   kfld                    lbtrn#
CCPaAC                   kfld                    lbord
     *
     *  Define partial key for LABEL3 file.
     *
     C     keyl3f        klist
     C                   kfld                    $ptrn#
     C                   kfld                    $pwhse
     *
     *  Define key for PIRITEM file. (FOR BROKEN CASE ITEM)
     *
     C     keyib         klist
     C                   kfld                    $pwhse
     C                   kfld                    lb_lbitem
     *
     *  Define key for PIRITEM file. (FOR LINK ITEM)
     *
     C     keyit         klist
     C                   kfld                    $pwhse
     C                   kfld                    ilitm2
     *
     *  Define key for PIRITEM and ITEMLNK file.
     *
     C     keyil         klist
     C                   kfld                    $pwhse
     C                   kfld                    lbitem
     *
     *  Define key for STDTIME file.
     *
     C     keyst         klist
     C                   kfld                    w1whs
     C                   kfld                    w1whdp
     C                   kfld                    w1sec
     *
     *  Define key for ITEM file.
     *
     C     itkey         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbitem
     *
ALNoA*  Define key for PCKTIME file.
     *
ALNoAC     keypc         klist
ALNoAC                   kfld                    lsttrn
     *
     *  Define key for LBLFMTH file.
     *
     C     keylfh        klist
     C                   kfld                    $plset
     *
     *  Define key for LBLFMTD file.
     *
     C     keylfd        klist
     C                   kfld                    $plset
     C                   kfld                    kyfmt
750fA*
750fA*  Define key for LBLFMTD file.
750fA*
750fAC     keylfd2       klist
750fAC                   kfld                    kyset
750fAC                   kfld                    kyfmt
     *
     *  Define key for LBLFMTV file.
     *
     C     keylfv        klist
     C                   kfld                    kyvnum
     *
BIRf *  Define key for PIRITEM and ITEMLNK file.
     *
BIRf C     keyiq         klist
BIRf C                   kfld                    $pwhse
BIRf C                   kfld                    lbitem
640cA*
640cA*  Define key for ORDDM file.
640cA*
640cAC     keyodm        klist
640cAC                   kfld                    $pwhse
640cAC                   kfld                    lbord
640cAC                   kfld                    lbseq
640cAC                   kfld                    lbitem
640pA*
640pA*  Define key for DEVGRPD file.
640pA*
640pAC     gdkey         klist
640pAC                   kfld                    $pwhse
640pAC                   kfld                    opdv1
640pA*
640pA*  Define key for DEVGRPR file.
640pA*
640pAC     grkey         klist
640pAC                   kfld                    $pwhse
640pAC                   kfld                    $prtid
640pAC                   kfld                    opdv1
     *
510bA*  Define partial key for ZBRLOGF/S files.
510bA *
510bAC     keyzbr        klist
510bAC                   kfld                    $pwhse
510bAC                   kfld                    $prtid
520hA*
520hA*  Define key for pick options.
520hA*
520hAC     opzkey        klist
520hAC                   kfld                    kycod1
520hAC                   kfld                    $pwhse
530 D ***                kfld                    $ptruk
530 MC                   kfld                    $ptmpl
520hAC                   kfld                    $pszon
520iA*
520iAC     opzkya        klist
520iAC                   kfld                    kycod3
520iAC                   kfld                    $pwhse
530 D ***                kfld                    $ptruk
530 MC                   kfld                    $ptmpl
520iAC                   kfld                    $pszon
     *
520iAC     opzkyb        klist
520iAC                   kfld                    kycod4
520iAC                   kfld                    $pwhse
530 D ***                kfld                    $ptruk
530 MC                   kfld                    $ptmpl
520iAC                   kfld                    $pszon
530 A*
530 A*  Define key for TRUCKH file.
530 A*
530 AC     trkey         klist
530 AC                   kfld                    $pwhse
530 AC                   kfld                    $ptruk
     *
cwdgA*  Define key for OPTIONZ file.
     *
cwdgAC     keyopz        klist
cwdgAC                   kfld                    kycode
cwdgAC                   kfld                    $pwhse
530fDC****               kfld                    $ptruk
530fMC                   kfld                    $ptmpl
cwdgAC                   kfld                    kyzone
530bA*
530bA*  Define key for ORDH file.
530bA*
530bAC     keyodh        klist
530bAC                   kfld                    $pwhse
530bAC                   kfld                    lbord
CWDaA*
CWDaA*  Define key for ORDD file.
CWDaA*
CWDaAC     keyodd        klist
CWDaAC                   kfld                    $pwhse
CWDaAC                   kfld                    lbord
CWDaAC                   kfld                    lbseq
CWDaAC                   kfld                    lbitem
     *
CCPbA*  Define key for ORDDM file.
CCPbA*
CCPbAC     kyodm         klist
CCPbAC                   kfld                    lbwhse
CCPbAC                   kfld                    lbord
CCPbAC                   kfld                    lbseq
CCPbAC                   kfld                    lbitem
CLDlA*
CLDlA*  Define partial key for PIRSEQ2 file
CLDlA*
CLDlAC     keypq2        klist
CLDlAC                   kfld                    lblbl#
CLDlA*
CLDlA*  Define partial key for PIRSEQ3 file
CLDlA*
CLDlAC     keypq3        klist
CLDlAC                   kfld                    $pwhse
CLDlAC                   kfld                    lsttrn
CLDlA*
CLDlA*  Define key for ORDH file.
CLDlA*
CLDlAC     keyoh         klist
CLDlAC                   kfld                    lb_lbwhse
CLDlAC                   kfld                    lb_lbord
     *
CLDqA* Item Link & Item Fields
CLDqAC     ilkey         klist
CLDqAC                   kfld                    x_lbwhse
CLDqAC                   kfld                    x_lbitem
CLDqA* Item Link-base item
CLDqAC     ilkey2        klist
CLDqAC                   kfld                    ilwhse
CLDqAC                   kfld                    ilitm2
CLDqA* LABEL90
CLDqAC     lb90key       klist
CLDqAC                   kfld                    pswhse
CLDqAC                   kfld                    pstrn#
640cA*
640cA*  Define key for Zone header.
640cA*
640cAC     zonkey        klist
640cAC                   kfld                    $pwhse
640cAC                   kfld                    $ptmpl
640cAC                   kfld                    $pszon
640cA*
640cA*  Define key for Zone header.
640cA*
640cAC     keyl7         klist
640cAC                   kfld                    albtrn#
640cAC                   kfld                    albitem
640fA*
640fA*  Define key for PIRTRAN file.
640fA*
640fAC     keytrn        klist
640fAC                   kfld                    albtrn#
640iA*
640iA*  Define key for TOTEBUND1 file
640iA*
640iAC     TBkey1        klist
640iAC                   kfld                    $pwhse
640iAC                   kfld                    lbtrn#
640iA*
640iA*  Define key for TOTEBUND3 file
640iA*
640iAC     TBkey3        klist
640iAC                   kfld                    tbwhse
640iAC                   kfld                    tbrtid
640iAC                   kfld                    tbmpl#
640iAC                   kfld                    tbszon
NCSbA*
NCSbA*  Define key for ITEMMSC file.
NCSbA*
NCSbAC     keyims        klist
NCSbAC                   kfld                    $pwhse
NCSbAC                   kfld                    lbitem
     *
VIPhA*  Define key for ITEMDSC file.
     *
VIPhAC     keyix         klist
VIPhAC                   kfld                    $pwhse
VIPhAC                   kfld                    lbitem
     *
CBIxAC     ixkey         klist
CBIxAC                   kfld                    $pwhse
CBIxAC                   kfld                    zpitem
     *
SFGa *  Define key for ITEMMSC file.
     *
SFGa C     keyim         klist
SFGa C                   kfld                    $pwhse
SFGa C                   kfld                    lbitem
svleA*
svleA*  Define partial key for RTEHED file.
svleA*
svleAC     keyrte        klist
svleAC                   kfld                    $pwhse
svleAC                   kfld                    $prtid
     *
     *  Slot key
     *
SVLiACSR   slotky        klist
SVLiACSR                 kfld                    lbwhse
SVLiACSR                 kfld                    lbwhdp
SVLiACSR                 kfld                    lbdisp
700lA*
700lA*  Define partial key for LABEL3 file.
700lA*
700lAC     keyps4p       klist
700lAC                   kfld                    $ptrn#
700lAC                   kfld                    $pwhse
     *
700wA*  Define partial key for ZBRLOGF/S files.
700wA*
700wAC     keydoc        klist
700wAC                   kfld                    $pwhse
700wAC                   kfld                    $prte
750bA*
750bA*  Define partial key for LABEL3 file.
750bA*
750bAC     keylb76       klist
750bAC                   kfld                    $pwhse
750bAC                   kfld                    $prtid
750bAC                   kfld                    tlbtrn#
750bAC                   kfld                    psplid
750bAC                   kfld                    tlbtype
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
CLDk *  Convert today's date into MM/DD/YY format.
     *
CLDk C                   eval      $cvcmd = '*CURMDY '
CLDk C                   call      @cvtdt
CLDk C                   parm                    $cvtdt
CLDk C                   eval      zksdte = $cvd6o
     *
     C                   move      zkmm          pkmm
     C                   eval      pkds1 = '/'
     C                   move      zkdd          pkdd
     C                   eval      pkds2 = '/'
     C                   move      zkyy          pkyy
SFGbA
SFGbA*  Add 1 to today's date and put into MM/DD/YY format.
SFGbA
SFGbAC                   eval      $cvcmd = '*CURMDY '
SFGbAC                   move      today         $cvd8i
SFGbAC                   eval      $cvdr1 = '*ADDDAYS'
SFGbAC                   eval      $cvvl1 = 1
SFGbAC                   call      'CLCDUR'
SFGbAC                   parm                    $cvtdt
SFGbAC                   eval      zksdte = $cvd6o
     *
SFGbAC                   move      zkmm          plus1mm
SFGbAC                   eval      plus11 = '/'
SFGbAC                   move      zkdd          plus1dd
SFGbAC                   eval      plus12 = '/'
SFGbAC                   move      zkyy          plus1yy
SFGdA*
SFGdA*   Open Client-Specific files.
SFGdA*
SFGdAC                   if        client = SGC
SFGdAC                   if        not %open(label32g)
SFGdAC                   open      label32g
SFGdAC                   endif
SFGdAC                   endif
     *
     *  Get system options.
     *
     C                   eval      opwhse = 0
     C                   eval      opcode = '*SYSTEM '
     C     opkey         chain     options                            79
     C                   if        *in79
     C                   eval      opletd = 'Y'
510iAC                   else
510iAC                   eval      opdat1 = opdata
     C                   endif
642cA*
642cA* Get Truck Template Code
642cA*
642cAC                   call      @gettruck
642cAC                   parm                    $pwhse
642cAC                   parm                    $prtid
642cAC                   parm                    $ptruk
530 A*
530 A* Get Zone Template Code if Template type is T=Truck
530 A*
530 AC     trkey         chain     truckh
530 AC                   if        %found(truckh) and thtype = 'T'
530 AC                   eval      $ptmpl =  thztmp
GFCdAC                   eval      $ptruk =  thtruk
530 AC                   else
530 AC                   eval      $ptmpl =  $ptruk
530 AC                   endif
530aA*
530aA*  Get system options.
530aA*
530aAC                   eval      opwhse = $pwhse
530aAC                   eval      opcode = '*GENPICK'
530aAC     opkey         chain     options                            79
700bAC                   select
700bAC                   when      not %found(options)
530aAC                   eval      oppset = ' '
700bAC                   eval      oprplt = '1'

CB3qAC                   when      client = cheney
CB3qAC                             and cliloc = cbiriv
CB3qAC                             and thztmp = '*TMPL006'
CB3qAC                   eval      bigpallabel = *off

CB3uAC                   when      client = cheney
CB3uAC                             and cliloc = cbist
CB3uAC                             and $ptruk = 'PICK-PACK'
CB3uAC                   eval      bigpallabel = *off

700bMC                   other
530aAC                   movel     opdata        oppdta
700bAC                   if        oprplt = '2'
720bAC                             or oprplt = '3'
700bAC                   eval      bigpallabel = *on
700bAC                   endif
700bMC                   endsl
     *
650aA*  Get *VOICE options.
650aA*
650aAC                   eval      opwhse = $pwhse
650aAC                   eval      opcode = '*VOICE  '
650aAC     opkey         chain     options
650aAC                   if        not %found
650aAC                   eval      opuplv = ' '
650aAC                   else
650aAC                   eval      opvdta = opdata
650aAC                   endif
     *
CB1eAC                   if        client = cheney
CB1eAC                             and opuplv = ' '
CB1eAC                   eval      opuplv = 'N'
CB1eAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CRTSTP  Create stop numbers.
     *
     C     crtstp        begsr
     *
     *  Seperate characters.
     *
     C     lbstop        div       10            num1
     C                   mvr                     num2
     *
     *  Build first character if not zero.
     *
     C                   call      'BIGNUM'
     C                   parm      '*MB     '    $bncod            8
     C                   parm                    num1
     C                   parm                    ch1
     *
     *  Build second character.
     *
     C                   call      'BIGNUM'
     C                   parm      '*MB     '    $bncod
     C                   parm                    num2
     C                   parm                    ch2
     C                   endsr
     *----------------------------------------------------------------
     *
     *  EDITNA  Edit numeric to alpha.
     *
     C     editna        begsr
     C                   eval      a40 = *blanks
     C     $nanum        cabeq     0             ena01
     C                   eval      temp40 = *blanks
     C                   movel     $nanum        temp40
     C                   movea     temp40        a40
     C                   eval      dpos = 12 - $nadec
     C     dpos          add       2             tenpos
     C                   eval      ax = 12
     C                   eval      ay = 40
     C     lna01         tag
     C                   eval      ax = ax - 1
     C     ax            cabeq     0             ena01
     C                   if        ax < tenpos
     C                   eval      a40(ay) = a40(ax)
     C                   eval      ay = ay - 1
     C                   else
     C                   if        a40(ax) > '0'
     C                   eval      a40(ay) = a40(ax)
     C                   eval      ay = ay - 1
     C                   eval      tenpos = 99
     C                   endif
     C                   endif
     C                   if        ax = dpos
     C                   eval      a40(ay) = '.'
     C                   eval      ay = ay - 1
     C                   endif
     C                   goto      lna01
     C     ena01         tag
     C                   eval      ax = 28
     C     lna02         tag
     C                   add       1             ax
     C     ax            comp      41                                     50
     C   50              goto      ena02
     C     a40(ax)       comp      '0'                                    50
     C  n50a40(ax)       comp      ' '                                    50
     C  n50              goto      ena02
     C                   eval      a40(ax) = ' '
     C                   goto      lna02
     C     ena02         tag
     C                   movea     a40(29)       a12
     C                   if        ax > 40
     C                   eval      $nafp = 12
     C                   else
     C                   eval      $nafp = ax - 28
     C                   endif
     *
     C                   eval      $nanum = 0
     C                   eval      $nadec = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETPAL  Get pallet number.
     *
     C     getpal        begsr
     C                   eval      pal# = 0
     C     1             do        palcnt        curpal
     C     curpal        occur     palsum
     C                   if        dsppli = lbpal#
     C                   eval      pal# = dsppal
     C                   endif
     C                   enddo
     *
     C                   endsr

642aA*----------------------------------------------------------------
642aA*  GetTruckPlt   Get truck pallet for pltsum record
642aA*----------------------------------------------------------------
642aAC     GetTruckPlt   begsr
     C                   eval      truckPallet = 0

     C                   eval      kyltyp = 'O'
     C     keyl31        setll     label31

     C                   dou       forevr <> forevr

     C     keyl31        reade     label31
     C                   if        %eof(label31)
     C                   leave
     C                   endif

     C                   if        lbqpck = 0
     C                   iter
     C                   endif

     C                   call      'GETTPL2'
     C                   parm      '*FIRST'      $gcmd             8
     C                   parm      lblbl#        $glbl#            7 0
     C                   parm                    $gtplt            7 0
     C                   parm                    $gmlbl            7 0
     C                   parm                    $gmpid            7 0
     C                   parm                    $gsplt            1
     C                   parm                    $glow             1
     C                   parm                    $ghnd2            2
     C                   parm                    $gqypk            5 0
     C                   parm                    $gqypl            5 0
     C                   parm                    $grtn             8

     C                   if        $grtn = '*OK'
     C                   eval      truckPallet = $gtplt
     C                   endif

     C                   leave
     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *
     *  INITSS  Initialize data structure for stop summary
     *
     C     initss        begsr
ctwkAC                   if        ssdcnt = 0
ctwkAC                             and client = citywholesale
ctwkAC                   eval      dssstp = 0
ctwkAC                   eval      dsspcs = 0
ctwkAC                   eval      dsscub = 0
ctwkAC                   eval      dsswgt = 0
ctwkAC                   endif
520iA*
520iAC                   if        ssdcnt = 0
520iAC                             and client <> citywholesale
520iAC                   eval      ssdcnt = 1
520iAC                   endif
520iA*
     C     1             do        ssdcnt        ssocur
     C     ssocur        occur     stpsum
     C                   eval      dssstp = 0
     C                   eval      dsspcs = 0
     C                   eval      dsscub = 0
     C                   eval      dsswgt = 0
     C                   eval      dsscnm = *blanks
SvlhAC                   eval      dssord = 0
     C                   enddo
     C                   eval      ssocur = 1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  INITZP  Initialize data structure for zone pickup
     *
     C     initzp        begsr
     C     1             do        zpdcnt        zpocur
     C     zpocur        occur     zonpku
     C                   eval      dszstp = 0
     C                   eval      dszpcs = 0
     C                   eval      dszitm = *blanks
     C                   eval      dszdsc = *blanks
     C                   eval      dszplt = 0
CBIxAC                   eval      dszds2 = *blanks
CBIxAC                   eval      dszpck = *blanks
     C                   eval      dszpsi = *blanks
     C                   enddo
     C                   eval      zpocur = 1
     C                   endsr
640pA*----------------------------------------------------------------
640pA*
640pA*  initpd  Initialize data structure for printer devices
640pA*
640pAC     initpd        begsr
640pAC     1             do        50            pdocur
640pAC     pdocur        occur     zonprt
640pAC                   eval      device = *blanks
640pAC                   enddo
640pAC                   eval      pdocur = 1
640pAC                   endsr
640pA*----------------------------------------------------------------
640pA*
640pA*  loadpd  Load data structure for printer devices
640pA*
640pAc     loadpd        begsr

640pA*    Determine if Printer Device group code or Printer device

640pAc     prefix        scan      opdv1:1
640pAc                   eval      svopdv1 = opdv1

640pAc                   Select
640pA *  Round robin printing by Transaction

640yMc                   when      %found and oprbn2 = '3'
640yD ***                when      %found and $ubrobn = '3'
640pAc                   eval      mpflag = 'N'
640pAc                   eval      pdocur = *zeros
640pAc                   eval      maxcount = *zeros
640pAc     gdkey         setll     devgrpd
640pAc                   dou       %eof(devgrpd)
640pAc     gdkey         reade     devgrpd
640pAc                   if        not %eof(devgrpd)
640pAc                   eval      pdocur = pdocur + 1
640pAc     pdocur        occur     zonprt
640pAc                   eval      device = dvddev
640pAc                   endif
640pAc                   enddo
640pAc                   if        pdocur = 1
640pAc                   eval      opdv1  = dvddev
640pAc                   endif
640pAc                   if        pdocur > 1
640pAc                   eval      mpflag = 'Y'
640pAc                   eval      maxcount = pdocur
640pAc                   eval      pdocur = *zeros
640pAc                   endif

640pA *  Round robin printing is off

640yMc                   when      %found and oprbn2 = '1'
640yD ***                when      %found and $ubrobn = '1'
640pAc                   eval      mpflag = 'N'
640pAc     gdkey         chain     devgrpd
640pAc                   if        %found(devgrpd)
640pAc     1             occur     zonprt
640pAc                   eval      device = dvddev
640pAc                   eval      opdv1  = dvddev
640pAc                   endif

640pA *  Round robin printing by route

640yMc                   when      %found and oprbn2 = '2'
640yD ***                when      %found and $ubrobn = '2'
640pAc                   eval      mpflag = 'N'
640pAc     grkey         chain     devgrpr
640pAc                   if        %found(devgrpr)
640pAc     1             occur     zonprt
640pAc                   eval      device = dvrdev
640pAc                   eval      opdv1  = dvrdev
640pAc                   else
640pAc     gdkey         chain     devgrpd2
640pAc                   if        %found(devgrpd2)
640pAc     1             occur     zonprt
640pAc                   eval      device = dvddev
640pAc                   eval      dvrgrp = oppdev
640pAc                   eval      opdv1  = dvddev
640pAc                   time                    dvdlts
640pAc                   update    d2rec
640pA * create devgrpr record
640pAc                   eval      dvrwhs = $pwhse
640pAc                   eval      dvrrid = $prtid
640pAc                   eval      dvrdev = dvddev
640pAc                   eval      dvrgrp = svopdv1
640pAc                   write     ddrrec
640pAc                   endif
640pAc                   endif

640pA *  Print w/device code

640pAc                   when      not %found
640pAc     1             occur     zonprt
640pAc                   eval      device = opdv1
640pAc                   eval      mpflag = 'N'
640pAc                   endsl

640pAc                   if        device = *blanks
640pAc                   eval      device = '*JOB'
640pAc                   endif

640pAc                   endsr
     *----------------------------------------------------------------
     *
     *  OPNPRT  Open printer file.
     *
     C     opnprt        begsr
     *
     *   Open printer file for department.
     *
     C                   if        opened <> *on
     *
     *      If printer already open then close it.
     *
     C                   if        opened = *on
     C                   close     pfmtpr
     C                   endif
CBSwA*
CBSwA*      Get Cadec flag.
CBSwA*
CBSwAC     $prtid        chain     cadecrte
CBSwAC                   if        not %found
CBSwAC                   eval      crfflg = 'N'
CBSwAC                   endif
CBSwA*
CBSwA*      Get Cadec device.
CBSwA*        First try to get device for zone.
CBSwA*        If not found, try to get generic device.
CBSwA*        If not found, set cadec flag off.
CBSwA*
CBSwAC                   if        crfflg = 'Y'
CBSwAC     $pszon        chain     cadecdev
CBSwAC                   if        not %found
CBSwAC     blankZone     chain     cadecdev
CBSwAC                   if        not %found
CBSwAC                   eval      crfflg = 'N'
CBSwAC                   endif
CBSwAC                   endif
CBSwAC                   endif
     *
     *      Override printer file.
     *
     *          OVRPRTF FILE(PFMTPR) OUTQ(*DEV) DEV(rodev)
     *                  FORMTYPE(roform)
     *
JORbAC                   if        client = Jordanos
JORbA*      Apply prtf override to outq instead of prtdev.
JORbAC                   movea     ovrprt(2)     a80
JORbAC                   else
     C                   movea     ovrprt(1)     a80
JORbAC                   endif
JORbA*
650nAC                   select
     *
CBSwAC                   when      crfflg = 'Y'
CBSxAC                             and prtall = *on
CBSwAC                   movea     ovrprt(1)     a80
CBSwAC                   movea     cdvdev        a80(37)
CBSwAC                   movea     oppfrm        a80(58)
CBSwAC                   movea     a80           qcmd

642kMC                   when      $pcmd = '*PR321  '
642jAC                   eval      opdv1 = oppdev
642jAC                   eval      opfm1 = oppfrm
700cAC                   movea     oppdev        a80(37)
700cAC                   movea     oppfrm        a80(58)

642kAC                   when      $pcmd = '*PRTLBL '
642kAC                             and oppdev <> *blanks
642kAC                             or $pcmd = '*SHORT  '
642kAC                             and oppdev <> *blanks
650aAC                             or $pcmd = '*SHORTM '
650aAC                             and oppdev <> *blanks
700aAC                             or $pcmd = '*ZONDSC '
700aAC                             and oppdev <> *blanks
642kAC                   eval      opdv1 = oppdev
642kAC                   eval      opfm1 = oppfrm
700cAC                   movea     oppdev        a80(37)
700cAC                   movea     oppfrm        a80(58)

650nAC                   when      $pcmd = '*SHORT'
650nAC                             and oppdev <> '*JOB'
650nAC                   movea     oppdev        a80(37)
650nAC                   movea     oppfrm        a80(58)

650nAC                   when      $pcmd = '*SHORTM'
650nAC                             and oppdev <> '*JOB'
650nAC                   movea     oppdev        a80(37)
650nAC                   movea     oppfrm        a80(58)
650nAC                   other
     C                   movea     opdv1         a80(37)
     C                   movea     opfm1         a80(58)
650nAC                   endsl
     C                   movea     a80           qcmd
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
     *
     *      Open printer file.
     *
750fAC                   if        sendToPrinter
     C                   open      pfmtpr
750fAC                   endif
     C                   eval      opened = *on
     *
     C                   endif
640cA
640cA*   Open printer file for tote zone labels
640cA
640cAC                   if        openedpfmtprt3 <> *on

640cA*      Override printer file Tobacco/Retail/Candy labels.

640qD ***  tote          chain     ctwzondev
640qD ***                if        not %found
640qMC                   if        opdv3 = *blanks
640cAc                   eval      zondev = 'QPRINT'
640cAc                   eval      opfm3  = 'TOTE'
640qAC                   else
640qMC                   eval      zondev = opdv3
640cAC                   endif
640cAC                   eval      qcmd = 'OVRPRTF'
640cAC                                  + ' FILE(PFMTPR3)'
640cAC                                  + ' OUTQ(*DEV)'
640cAC                                  + ' DEV(' +  %trim(zondev) + ')'
640qMC                                  + ' FORMTYPE(' +  %trim(opfm3) + ')'
640cAC                                  + ' SAVE(*YES)'

640cAC                   call      'QCMDEXC'
640cAC                   parm                    qcmd
640cAC                   parm      80            qlen
ctwaA
ctwaA*      Open printer file for Retails labels.
ctwaA
750fAC                   if        sendToPrinter
ctwaAC                   open      pfmtpr3
750fAC                   endif
ctwaAC                   eval      openedpfmtprt3 = *on
ctwaAC                   endif
CSPlA
CSPlA*   Open printer file for BIGPAL labels
CSPlA
CSPlAC                   if        openedpfmtprt4 <> *on

CSPlA*      Override printer file BIGPAL labels.

CSPlAC     bigpal        chain     ctwzondev
CSPlAC                   if        not %found(ctwzondev)
CSPlAC                   eval      zondev = 'QPRINT'
CSPlAC                   eval      opfm4a = 'BIGP'
CSPlAC                   endif
CSPlAC                   eval      qcmd = 'OVRPRTF'
CSPlAC                                  + ' FILE(PFMTPR4)'
CSPlAC                                  + ' OUTQ(*DEV)'
CSPlAC                                  + ' DEV(' +  %trim(zondev) + ')'
CSPlAC                                  + ' FORMTYPE(' +  %trim(opfm4a) + ')'
CSPlAC                                  + ' SAVE(*YES)'

CSPlAC                   call      'QCMDEXC'
CSPlAC                   parm                    qcmd
CSPlAC                   parm      80            qlen
CSPlA
CSPlA*      Open printer file for Retails labels.
CSPlA
750fAC                   if        sendToPrinter
CSPlAC                   open      pfmtpr4
750fAC                   endif
CSPlAC                   eval      openedpfmtprt4 = *on
CSPlAC                   endif
ctwaA
ctwaA*   Open printer file for Retail labels
ctwaA
ctwaAC                   if        openedpfmtprt2 <> *on
CBIjA*
CBIjA*      Open printer file PFMTPR2
CBIjA*
ctwaAC                   select

ctwaA*      Override printer file Tobacco/Retail/Candy labels.
ctwaA
ctwaAC                   when      retailflag
ctwaAC                             or tobaccoflag
ctwaAC                             or candyflag
ctwj C                             or cigaretflag
ctwaA
ctwaAC                   if        opdv1 = *blanks
ctwaAC                             and opdv2 = *blanks
ctwaAc                   eval      zondev = 'QPRINT'
ctwaAc                   eval      zonfrm = 'PICKRETL'
ctwaAC                   endif

ctwaAC                   select
ctwaAC                   when      opdv1 <> *blanks
ctwaAC                   eval      zondev = opdv1
ctwaAC                   eval      zonfrm = opfm1
ctwaAC                   when      opdv2 <> *blanks
ctwaAC                   eval      zondev = opdv2
ctwaAC                   eval      zonfrm = opfm2
ctwaAC                   endsl
ctwaAc                   if        opfm1  = *blanks
ctwaAc                             and opfm2  = *blanks
ctwaAc                   eval      zonfrm = 'PICKRETL'
ctwaAC                   endif
ctwaA
ctwaAC                   eval      qcmd = 'OVRPRTF'
ctwaAC                                  + ' FILE(PFMTPR2)'
ctwaAC                                  + ' OUTQ(*DEV)'
ctwaAC                                  + ' DEV(' +  %trim(zondev) + ')'
ctwaAC                                  + ' FORMTYPE(' +  %trim(zonfrm) + ')'
ctwsAC                                  + ' SAVE(*YES)'
ctwaAC                   endsl
ctwaA
ctwaAC                   call      'QCMDEXC'
ctwaAC                   parm                    qcmd
ctwaAC                   parm      80            qlen
ctwaA
ctwaA*      Open printer file for Retails labels.
ctwaA
750fAC                   if        sendToPrinter
ctwaAC                   open      pfmtpr2
750fAC                   endif
ctwaAC                   eval      openedpfmtprt2 = *on
ctwaAC                   endif
CB2iA
CB2iA*   Open printer file for Big Pallet Labels
CB2iA
CB2iAC                   if        openedpfmtprt5 <> *on
     *
     *      Open printer file PFMTPR5
     *
CHYaAC                   select
720bAC                   when      client = cheney
720bAC                             and bigpallabel = *off

CB2kAC                   when      client = cheney
CB2kAC                             and cliloc = cbipntgr
CB2kAc                   exsr      BIGPG

CB2kAC                   when      client = cheney
CB2kAC                             and cliloc = cbiocl
CB2kAc                   exsr      BIGOCL

CB3oAC                   when      client = cheney
CB3oAC                             and $prte >= '8800 '
CB3oAC                             and $prte <= '8899 '
CB3oAC                   eval      qcmd = ovrprt(16)

CB2eAC                   when      client = cheney
CB2eAC                             and cliloc = cbigwb
CB2eAC                   eval      qcmd = ovrprt(7)

CB2kAC                   when      client = cheney
CB2kAC                             and cliloc = cbiriv
CB2kAc                   exsr      BIGRIV

CB2zAC                   when      client = cheney
CB2zAC                             and (cliloc = cbigo
CB2zAC                                 or cliloc = cbigr
CB2zAC                                 or cliloc = cbist)
CB2zAC                             and ($ptruk = 'WILL-CALL'
CB2zAC                                 or $ptruk = 'WILLCALL'
CB3uAC                                 or $ptruk = 'PICK-PACK')

CB2vAC                   when      client = cheney
CB2vAC                             and cliloc = cbigo
CB2vAc                   exsr      BIGGO

CB2vAC                   when      client = cheney
CB2vAC                             and cliloc = cbigr
CB2vAc                   exsr      BIGGR

CB2vAC                   when      client = cheney
CB2vAC                             and cliloc = cbist
CB2vAc                   exsr      BIGST

CB3fAC                   when      client = cheney
CB3fAC                             and cliloc = cbimlk
CB3fAC                   eval      qcmd = ovrprt(13)

CB3hAC                   when      client = cheney
CB3hAC                             and cliloc = cbitif
CB3hAc                   exsr      BIGTIF

CHYhAC                   other

CBSk C                   eval      qcmd = ovrprt(4)
CHYhAC                   endsl

CBIjAC                   call      'QCMDEXC'
CBIjAC                   parm                    qcmd
CBIjAC                   parm      80            qlen
     *
     *      Open printer file.

750fAC                   if        sendToPrinter
     C                   open      pfmtpr5
750fAC                   endif
     C                   eval      openedpfmtprt5 = *on
CB2iAC                   endif
     *
     C                   endsr
640pA*----------------------------------------------------------------
640pA*
640pA*  opnprt2  Open next round robin printer device.
640pA*
640pAc     opnprt2       begsr

640pAc                   if        pdocur = maxcount
640pAc                   eval      pdocur = *zeros
640pAc                   endif

640pAc                   eval      pdocur = pdocur + 1
640pAc     pdocur        occur     zonprt
640pA *   Override printer file.

      *          OVRPRTF FILE(PFMTPR) OUTQ(*DEV) DEV(rodev)
      *                  FORMTYPE(roform)

640pAC                   movea     ovrprt(1)     a80
640pAC                   movea     device        a80(37)
640pAC                   movea     oppfrm        a80(58)
640pAC                   movea     a80           qcmd
640pAC                   call      'QCMDEXC'
640pAC                   parm                    qcmd
     C                   parm      80            qlen

640pA *      Open printer file.

640pAC                   if        opened = *off
750fAC                   if        sendToPrinter
640pAC                   open      pfmtpr
750fAC                   endif
640pAC                   endif
640pAC                   eval      opened = *on

640pAC     prt2end       endsr
     *----------------------------------------------------------------
     *
CB2vA*  BIGGO   Big pallet label for Goldsboro
     *
CB2vAC     biggo         begsr

     C                   select
     *      PRTPAL
     C                   when      $pszon = 'CHEM'
     C                             or $pszon = 'DRY'
     C                             or $pszon = 'DRYPIR'
     C                   eval      qcmd = ovrprt(3)
     *      PRTPAL2
     C                   when      $pszon = 'CLR'
     C                             or $pszon = 'FRZ'
     C                             or $pszon = 'FRZPIR'
     C                             or $pszon = 'ICE'
     C                             or $pszon = 'MEAT'
     C                   eval      qcmd = ovrprt(4)

     C                   other
     C                   eval      qcmd = ovrprt(3)

     C                   endsl

CB2vAC                   endsr
     *----------------------------------------------------------------
     *
CB2vA*  BIGGR   Big pallet label for Greensboro
     *
CB2vAC     biggr         begsr

     C                   select
     *      PRTGRPAL
     C                   when         %subst($prte:2:1) = '1'
     C                             or %subst($prte:2:1) = '2'
     C                   eval      qcmd = ovrprt(10)
     *      PRTGRPAL2
     C                   When         %subst($prte:2:1) = '0'
     C                   eval      qcmd = ovrprt(9)

     C                   other
     C                   eval      qcmd = ovrprt(10)

     C                   endsl

CB2vAC                   endsr
     *----------------------------------------------------------------
     *
CB2vA*  BIGST   Big pallet label for Statesville
     *
CB2vAC     bigst         begsr

     C                   select
     *      PRTSTPAL
     C                   when      $pszon = 'CHEM'
     C                             or $pszon = 'CLR'
     C                             or $pszon = 'DRY'
     C                             or $pszon = 'PRD'
     C                   eval      qcmd = ovrprt(11)
     *      PRTSTPAL2
     C                   when      $pszon = 'DRYPIR'
     C                             or $pszon = 'FRZ'
     C                             or $pszon = 'FRZPIR'
     C                             or $pszon = 'ICE'
     C                             or $pszon = 'MEAT'
     C                   eval      qcmd = ovrprt(12)

     C                   other
     C                   eval      qcmd = ovrprt(11)

     C                   endsl

CB2vAC                   endsr
CB3hA*
CB3hA*----------------------------------------------------------------
CB3hA*
CB3hA*  BIGTIF   Big pallet label for Tifton, GA.
CB3hA*
CB3hAC     bigtif        begsr

CB3hAC                   select
CB3hA*      PRTTFPAL
CB3hAC                   when         $pszon = 'CHEM'
CB3hAC                             or $pszon = 'DRY'
CB3hAC                             or $pszon = 'DRYPIR'
CB3hAC                   eval      qcmd = ovrprt(14)
CB3hA*      PRTTFPAL2
CB3hAC                   when         $pszon = 'CLR'
CB3hAC                             or $pszon = 'FRZ'
CB3hAC                             or $pszon = 'ICE'
CB3hAC                   eval      qcmd = ovrprt(15)

CB3hAC                   other
CB3hAC                   eval      qcmd = ovrprt(14)

CB3hAC                   endsl

CB3hAC                   endsr
CB3hA*
     *----------------------------------------------------------------
     *
CB2oA*  BIGPG   Big pallet label for Puta Gorda
     *
CB2oAC     bigpg         begsr

CB2kAC                   select
CB2kA*      PRTPAL
CB2kAC                   when      $pszon = 'CHEM'
CB2kAC                             or $pszon = 'DRY'
CB3FD **=>                     **  or $pszon = 'FREE'
CB2kAC                   eval      qcmd = ovrprt(3)

CB2kA*      PRTPAL2
CB2kAC                   when      $pszon = 'CLM'
CB2kAC                             or $pszon = 'CLR'
CB2kAC                             or $pszon = 'FRZ'
CB2kAC                             or $pszon = 'ICE'
CB2kAC                             or $pszon = 'OYS'
CB2kAC                             or $pszon = 'PKCLR'
CB2kAC                   eval      qcmd = ovrprt(4)

CB2kA*      PRTPRD2
CB2kAC                   when      $pszon = 'CLRPIR'
CB2kAC                             or $pszon = 'DRYPIR'
CB2kAC                             or $pszon = 'FRZPIR'
CB2kAC                             or $pszon = 'ICEPIR'
CB2kAC                             or $pszon = 'PKCPIR'
CB2kAC                             or $pszon = 'PKDPIR'
CB2kAC                             or $pszon = 'PKDRY'
CB2kAC                             or $pszon = 'PRD'
CB3FAC                             or $pszon = 'FREE'
CB3FAC                             or $pszon = 'SUB'
CB2kAC                   eval      qcmd = ovrprt(5)

CB3eAC                   other
CB3eAC                   eval      qcmd = ovrprt(4)

CB2kAC                   endsl

CB2oAC                   endsr
     *----------------------------------------------------------------
     *
CB2oA*  BIGOCL  Big pallet label for Ocala
     *
CB2oAC     bigocl        begsr

     C                   select

     C                   when      $ptruk = 'ADD-ONS'
     C                   eval      qcmd = ovrprt(4)
     *
     *  CLR, FRZ
     *
     C                   when      $pszon = 'CLR'
     C                             or $pszon = 'FRZ'
     C                   eval      qcmd = ovrprt(3)
     *
     *  CHEM, DRY, DOCHY
     *
     C                   when      $pszon = 'CHEM'
     C                             or $pszon = 'DRY'
     C                             or $pszon = 'DOCHY'
     C                   eval      qcmd = ovrprt(4)
     *
     *  CLM, CLRPIR, DRYPIR, FRZPIR, FRZ999, ICE, ICEPIR, ICE999, OYS
     *  PKCLR, PKDRY, PKCPIR, PKDPIR, PKFPIR, PKFRZ
     *
     C                   when      $pszon = 'CLM'
     C                             or $pszon = 'CLRPIR'
CB2oAC                             or $pszon = 'DRYPIR'
     C                             or $pszon = 'FRZPIR'
     C                             or $pszon = 'FRZ999'
     C                             or $pszon = 'ICE'
     C                             or $pszon = 'ICEPIR'
     C                             or $pszon = 'ICE999'
     C                             or $pszon = 'OYS'
     C                             or $pszon = 'PKCLR'
     C                             or $pszon = 'PKDRY'
     C                             or $pszon = 'PKCPIR'
     C                             or $pszon = 'PKDPIR'
     C                             or $pszon = 'PKFPIR'
     C                             or $pszon = 'PKFRZ'
     C                   eval      qcmd = ovrprt(8)
     *
     *  PRD, SUBWAY
     *
     C                   when      $pszon = 'PRD'
     C                             or $pszon = 'SUBWAY'
     C                   eval      qcmd = ovrprt(6)

     C                   other
     C                   eval      qcmd = ovrprt(6)

     C                   endsl
     *
CB2oAC                   endsr
     *----------------------------------------------------------------
     *
CB2oA*  BIGRIV  Big pallet label for Riviera
     *
CB2oAC     bigriv        begsr

     C                   select
     C                   when      $ptruk = 'ADD-ONS'
     C                   eval      qcmd = ovrprt(4)

     C                   when      $ptruk = @meat
     C                             or $ptruk = @prepk
     C                             or $ptruk = @cntnr
CB2rD ***                eval      qcmd = ovrprt(6)

     C                   when      $pszon = 'CHEM'
     C                             or $pszon = 'DRY'
     C                             or $pszon = 'PKDRY'
     C                             or $pszon = 'FLRPIR'
     C                   eval      qcmd = ovrprt(4)

     C                   when      $pszon = 'CLR'
     C                             or $pszon = 'FRZ'
     C                             or $pszon = 'ICE'
     C                             or $pszon = 'PKCLR'
CB2rAC                             or $pszon = 'OYS'
CB2rAC                             or $pszon = 'CLM'
     C                   eval      qcmd = ovrprt(3)

     C                   when      $pszon = 'CLRPIR'
CB2rD ***                          or $pszon = 'FLRPIR'
     C                             or $pszon = 'DRYPIR'
     C                             or $pszon = 'DRY999'
     C                             or $pszon = 'FRZPIR'
     C                             or $pszon = 'ICEPIR'
     C                             or $pszon = 'ICE999'
     C                             or $pszon = 'PKCPIR'
     C                             or $pszon = 'PKDPIR'
     C                             or $pszon = 'PKFPIR'
     C                             or $pszon = 'PKPPIR'
CB2rAC                             or $pszon = 'PRDPIR'
CB2rAC                             or $pszon = 'FRZ999'
     C                   eval      qcmd = ovrprt(8)

     C                   when      $pszon = 'PRD'
CB3dD ***                eval      qcmd = ovrprt(6)
CB3dMC                   eval      qcmd = ovrprt(8)

     C                   other
     C                   eval      qcmd = ovrprt(3)
     C                   endsl

CB2oAC                   endsr

     *----------------------------------------------------------------
     *
     *  PRINT   Output string to printer.
     *
     C     print         begsr
     C                   eval      prtflg = *off
     C                   movea     sto           @outpt
750fAC                   eval      wLine = %trimr(@outpt)

640cAC                   select
CSPlAC                   when      client = coastalsunbelt
CSPlAC                             and  kyfmt = 'BIGPAL  '
750fAC                   if        sendToPrinter
CSPlAC                   except    #str4
750fAC                   endif
DRYkAC                   when      client = dairyland
DRYkAC                             and  kyfmt = 'BIGPAL  '
750fAC                   if        sendToPrinter
DRYkAC                   except    #str4
750fAC                   endif
CBIaAC                   when      client = cheney
CBIaAC                             and kyfmt = 'BIGPAL  '
750fAC                   if        sendToPrinter
CBIaAC                   exsr      printBigPal
750fAC                   endif
CBIaAC                   when      client = cheney
CBIaAC                             and kyfmt = 'BIGPAL2 '
750fAC                   if        sendToPrinter
CBIaAC                   exsr      printBigPal
750fAC                   endif
640cAC                   when      totzon
640cAC                             and  kyfmt = 'XTOTE   '
750fAC                   if        sendToPrinter
640cAC                   except    #str3
750fAC                   endif
ctwaAC                   when      totzon
ctwaAC                             and  kyfmt = 'XTOTES  '
750fAC                   if        sendToPrinter
ctwaAC                   except    #str3
750fAC                   endif
640qAC                   when      totzon
640qAC                             and  kyfmt = 'XTOTE2  '
640qAC                             and  client = Cashwa
750fAC                   if        sendToPrinter
640qAC                   except    #str3
750fAC                   endif
640cAC                   when      totzon
640iAC                             and  kyfmt = 'XTOTE3  '
750fAC                   if        sendToPrinter
640cAC                   except    #str3
750fAC                   endif
640cAC                   when      totzon
640cAC                             and  kyfmt = 'XTOTE2  '
750fAC                   if        sendToPrinter
640cAC                   except    #str2
750fAC                   endif
ctwaAC                   when      tobaccoflag
750fAC                   if        sendToPrinter
ctwaAC                   except    #str2
750fAC                   endif
ctwaAC                   when      candyflag
750fAC                   if        sendToPrinter
ctwaAC                   except    #str2
750fAC                   endif
ctwaAC                   when      retailflag
750fAC                   if        sendToPrinter
ctwaAC                   except    #str2
750fAC                   endif
640cAC                   other
750fAC                   if        sendToPrinter
     C                   except    #str
750fAC                   endif
750fA /free
750fA                              IFSWriteLine(1);
750fA /end-free
640cAC                   endsl

     C                   eval      sto = *blanks
     C                   eval      op = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PrintBigPal  Output string to printer.
     *
     C     PrintBigPal   begsr

CB2eAC                   select
CB2eAC                   when      cliloc = cbigwb

CB3oA*      2019009 worklist
CB3oAC                   when      client = cheney
CB3oAC                             and $prte >= '8800 '
CB3oAC                             and $prte <= '8899 '
CB3oAC                   except    #str5

CB2wA*      No restiction for Greensboro.
CB2wAC                   when      cliloc = cbigr
CB2wAC                   except    #str5

CBIaA*      Do Not Print BIG Pallet Label for GWB.
CBItAC                   when      $ptruk <> @meat
CHYcAC                             and $ptruk <> @prepk
CHYjAC                             and $ptruk <> @sp
CHYlAC                             and $ptruk <> @cntnr
CHYtAC                             and $ptruk <> @wilcl
CHYtAC                             and $ptruk <> @wlcl
CHYtAC                             and $ptruk <> @sudsv
CHYtAC                             and $ptruk <> @damag
CHYjAC                   except    #str5
CBSsAC                   when      cliloc = cbiriv
CBSsA*    For Riviera, go ahead an print BIG label for following trucks.
CBSsAC                   if        $ptruk = @meat
CBSsAC                             or $ptruk = @cntnr
CBSsAC                             or $ptruk = @prepk
CBSsAC                   except    #str5
CBSsAC                   endif

CB3fA*      No restiction for MLK.
CB3fAC                   when      cliloc = cbimlk
CB3fAC                   except    #str5
640cAC                   endsl

     C                   endsr
     *----------------------------------------------------------------
     *
     *  PRTBLK  Print bulk pick labels for route/department.
     *
     C     prtblk        begsr
     *
     C                   eval      first = *on
     C                   eval      @pal# = -(999)
     *
     *  Loop bulk picks for zone.
     *
     *    Revised to only use a pallet id once.
     *
     C                   eval      lstpid = -(1)
     C                   eval      kytype = 'B'
720iAC                   if        tbEnhanced
720iAC                   eval      kygen = 7
720iAC                   else
720iAC                   eval      kygen = $pgen
720iAC                   endif
CTWtMC                   select
CTWtAC                   when      client = citywholesale
720iDC**   keyps3        setll     pltsum13
720iMC     keyps3b       setll     pltsum13
CTWtMC                   other
720iDC**   keyps3        setll     pltsum3
720iMC     keyps3b       setll     pltsum3
CTWtMC                   endsl

     C                   dou       forevr <> forevr
CTWtMC                   select
CTWtAC                   when      client = citywholesale
20iDAC**   keyps3        reade     pltsum13                               79
720iMC     keyps3b       reade     pltsum13                               79
CTWtAC                   other
720iDC**   keyps3        reade     pltsum3                                79
720iMC     keyps3b       reade     pltsum3                                79
CTWtAC                   endsl

     C                   if        *in79
     C                   leave
     C                   endif
     C                   if        psplid = lstpid
     C                   iter
     C                   endif
650cA*
650cA*     Skip pallet if $pcmd = *PRTTRN and pstrn# <> $ptrn#.
650cA*
650cAC                   if        $pcmd = '*PRTTRN '
650cAC                             and pstrn# <> $ptrn#
650cAC                   iter
650cAC                   endif
650cA*
     C                   eval      lstpid = psplid
     *
     *     Get dock door for the transaction.
     *
     C                   eval      $lwhse = pswhse
     C                   eval      $lrtid = psrtid
     C                   eval      $ltrn# = pstrn#
     C                   eval      $lwhdp = *blanks
     C                   eval      $ldoor = 0
     C                   call      'DH900'
     C                   parm                    $lparm
     *
     *    Loop through bulk pick labels for pallet.
     *      Note: There should only be one label, but this keeps
     *            the coding consistant with replenishments.
     *
     *      The above statment is false. There can be more than
     *      one bulk pick to a pallet especially if an item didn't
     *      have home slot.
     *
     *      The 413 fix was necessary because the LABEL31 file
     *      is joined to the PLTSUM file only using the pallet
     *      id. When there are multiple bulk picks on a pallet
     *      the LABEL31 ends up with duplicate records. These
     *      dups are created in sequence so we can check the
     *      label number against the last one and skip the
     *      record if they are the same.
     *
     C                   eval      lstlb# = -(1)
     C                   eval      kyltyp = 'B'
     C     keyl31        setll     label31
     *
     C                   dou       forevr <> forevr
     *
     C     keyl31        reade     label31                                78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   if        lblbl# = lstlb#
     C                   iter
     C                   endif
     C                   eval      lstlb# = lblbl#
     *
     *       Skip label if nothing was picked.
     *
     C                   if        lbqpck = 0
     C                   iter
     C                   endif
HMWdA*
HMWdA*       Skip these items.
HMWdA*
HMWdAC                   if        client = hmwagner
HMWdA*
HMWdAC                   if           lbitem = '900300-CS'
HMWdAC                             or lbitem = '900301-CS'
HMWdAC                             or lbitem = '900302-CS'
HMWdAC                             or lbitem = '900300'
HMWdAC                             or lbitem = '900301'
HMWdAC                             or lbitem = '900302'
HMWdAC                   iter
HMWdAC                   endif
HMWdAC                   endif
CWDfA*
CWDfA*       Skip cross-dock pick labels.
CWDfA*
CWDfAC                   select
CWDfAC                   when      client = Cashwa
CWDfA*
CWDfAC                   if           lbdisp = 'KD-101-1'
CWDfAC                             or lbdisp = 'KF-101-1'
CWDfAC                             or lbdisp = 'KR-101-1'
CWDfAC                   iter
CWDfAC                   endif
650cA*
650cA*     Skip label if nothing was picked.
650cA*
650cAC                   if        $pcmd = '*RPRTLB '

650cAC                   if        opflbl = lblbl#
650cAC                   eval      printlabel = *on
650cAC                   endif

650cAC                   if        not printlabel
650cAC                   iter
650cAC                   endif

650cAC                   if        optlbl = lblbl#
650cAC                   eval      printlabel = *off
650cAC                   endif

650cAC                   endif
530bA*
530bA*     Get order header record
530bA*
530bAC                   exsr      getORDH
CWDpA*
CWDnA*     Get order detail miscellaneous
CWDnAC                   exsr      getORDDM
CWDnAC                   other
CWDpA*
CWDpA*     Get order header record
CWDpA*
CWDpAC                   exsr      getORDH
CWDfA*
dry A*     Get order detail misc
dry A*
dry AC                   exsr      getORDHM
CWDfA*
CWDfAC                   endsl
NCSbA*
NCSbA*    Get vendor name to print on pick label
NCSbA*
NCSaAC                   select
NCSaAC                   when      client = nicholas
GFCaAC                             or client = gfc
NCSbAC                   eval      wkvnam = *blanks
NCSbAC     keyims        chain     itemmsc
NCSbAC                   if        %found(itemmsc)
NCSbAC                   eval      wkvnam = %subst(imvnam:1:25)
NCSbAC                   endif
640sAC                   when      client = sgc
SFGc *
SFGc C     keyim         chain     itemmsc                            79
SFGc C                   if        *in79=*on
SFGc C                   eval      imbrnd=*blanks
SFGc C                   endif
     *
SFGf C     keyix         chain     itemdsc                            79
SFGf C                   if        *in79=*on
SFGf C                   eval      ixdsc2=*blanks
SFGf C                   eval      dsdsc2=ixdsc2
SFGf C                   else
SFGf C                   eval      dsdsc2=ixdsc2
SFGf C                   endif
HMWc C                   other
HMWc *
HMWc C     keyim         chain     itemmsc                            79
HMWc C                   if        *in79=*on
HMWc C                   eval      imbrnd=*blanks
HMWc C                   endif
HMWc *
SFGf C                   endsl
     *
     *       Print beginning bulk pick label.
     *
     C                   if        first = *on
     C                   exsr      lblbbk
     C                   eval      first = *off
     C                   endif
     *
MATaA*  Get unique piece number for label.
MATaA*
650aA*  If *SHORT or *SHORTM, find and use the next sequential Trax#
650aA*  for this label which hasn't already been used.
650aA*
650aAC                   select
650aA*
650aAC                   when      $pcmd = '*SHORT  '
650aAC                             or $pcmd = '*SHORTM '
650aAC                   if        opuplv = 'N'
650aAC                             and $pcmd = '*SHORT  '
650aAC                   eval      cntTrax = (lbqpck - $pqty) + 1
650aAC                   else
650aAC                   eval      cntTrax = lbqpck +1
650aAC                   endif
650aAC     keyorp        setll     ordp2
650aAC                   do        cntTrax       TraxIndx          4 0
650aAC     keyorp        reade     ordp2
650aAC                   if        %eof
650aAC                   eval      unqpiece# = 0
650aAC                   leave
650aAC                   endif
650aAC                   if        orpttl = 1
650aAC                             or cntTrax = 1
650aAC                   eval      unqpiece# = orpup#
650aAC                   leave
650aAC                   endif
650aAC                   if        TraxIndx = cntTrax
650aAC                   eval      unqpiece# = orpup#
650aAC                   leave
650aAC                   endif
650aAC                   enddo
650aA*
650aAC                   other
650aA*
MATaAC     keyorp        setll     ordp2
MATaAC     keyorp        reade     ordp2
MATaAC                   if        %eof
MATaAC                   eval      unqpiece# = 0
MATaAC                   else
MATaAC                   eval      unqpiece# = orpup#
MATaAC                   endif
650aA*
650aAC                   endsl
     *
     *       Print warning for bulk/replenishment combo.
     *
     *
     *       Print pallet label.
     *
     *         Note: The right most digit of the pallet id is the
     *               bulk pick sequence number. This is changed to
     *               zero to reflect the main truck pallet id.
     *
     C                   if        pspal# <> @pal#
ctwaAC                   select
BIRaAC                   when      client = birite
BIRgAC                             and lbgrp2 <> 'W'
BIRaAC                   eval      kyfmt = 'PALLET  '
     C                   eval      dsstp1 = psstp1
     C                   eval      dsstp2 = psstp2

BIRaAC                   when      client = birite
BIRaAC                   eval      kyfmt = *blanks

CSPlAC                   when      client = coastalsunbelt
DRYkAC                             or client = dairyland
700bAC                             or (bigpallabel
700bAC                             and client <> cheney)
CSPlAC                   eval      kyfmt = 'BIGPAL  '

ctwkAC                   when      cigaretflag
ctwkAC                   eval      kyfmt = *blanks

ctwaAC                   when      tobaccoflag
ctwfD ***                eval      kyfmt = 'TPALLET '
ctwfMC                   eval      kyfmt = 'PALLET  '

ctwaAC                   when      candyflag
ctwfD ***                eval      kyfmt = 'TPALLET '
ctwfMC                   eval      kyfmt = 'PALLET  '
ctwaAC                   when      retailflag
ctwaAC                   eval      kyfmt = 'MPALLET '

ctwaAC                   other
ISPb C                   eval      kyfmt = 'PALLET  '
650lAC                   eval      dsstp1 = psstp1
650lAC                   eval      dsstp2 = psstp2
ctwaAC                   endsl

     C                   eval      @pal# = pspal#
     C     lbpal#        div       10            @plid
     C     @plid         mult      10            @plid
     C                   eval      @rtid = lbrte

700kAC                   eval      voiceid = 0
700kAC                   call      @getpltvid
700kAC                   parm      '*VOICEID'    $command
700kAC                   parm                    @plid
700kAC                   parm                    $pwhse
700kAC                   parm                    $prtid
700kAC                   parm                    voiceid

     C                   exsr      fillb1
     *
     *       Print 2 transaction labels for each bulk pick.  One will
     *       be used by batch clerk and the other will be used by the
     *       operator to scan the transaction for EPM.
     *
BIRaAC                   select
BIRaAC                   when      client = birite
BIRgAC                             and lbgrp2 = 'W'
BIRgAC                   other
     C                   do        2
     C                   eval      kyfmt = 'BLKTRAN '
     C                   exsr      fillb1
     C                   enddo
BIRaAC                   endsl
     *
     C                   endif
     *
     *       Print bulk label.
     *
     C                   eval      w1qty = lbqpck
640tD ***                exsr      crtstp
     **
FRF AC                   eval      newdsc1 = *blanks
FRF AC                   eval      newdsc2 = *blanks
     C     keyil         chain     piritem
FRF AC                   select
FRF AC                   when      not %found(piritem)
FRF AC                   eval      itvit# = *blanks

FRF AC                   when      %found(piritem)
FRF AC                   eval      ixdsc1 = *blanks
FRF AC                   eval      ixdsc2 = *blanks
FRF AC     keyil         chain     itemdsc
FRF AC                   if        %found(itemdsc)

FRF AC                   eval      newdsc1 = *blanks
FRF AC                   eval      newdsc2 = *blanks

FRF AC                   if        client = frf
FRF AC                   call      @getdesc
FRF AC                   parm      ixdsc1        olddsc
FRF AC                   parm                    newdsc
FRF AC                   parm      '2'           fmtcod

FRF AC                   eval      newdsc1 = %subst(newdsc:1:34)
FRF AC                   eval      newdsc2 = %subst(newdsc:35:34)
FRF AC                   endif

FRF AC                   endif
FRF AC                   endsl

     C                   exsr      lblblk
     *
     *       Print replenishment label if necessary.
     *
     C                   if        lbdsp2 <> *blanks
     C                   eval      w1qty = lbqrmn
     C                   exsr      lblrp1
     C                   endif
416dA*
416dA*     Print catch weight labels.
416dA*
416dAC                   if        itcwgt = 'Y'  and
416dAC                             opcwgt <> 0
416dAC     lbqpck        div       opcwgt        lbls
416dAC                   mvr                     remain
416dAC                   if        remain <> 0
416dAC                   add       1             lbls
416dAC                   endif
CBIsAC     1             do        lbls          @qty1
CBIiAC                   select
CBIiAC                   when      client = cheney
CBIiAC                             and dsmeat <> 'Y'
CHYcAC                             and dsppck <> 'Y'
CBIiAC                   exsr      lblcwt
CBIiAC                   other
416dAC                   exsr      lblcwt
CBIiAC                   endsl
416dAC                   enddo
416dAC                   endif
510dA*
510dA*     Print END label.
510dA*
ISYfAC                   if        client <> isupply
510dAC                   exsr      lblend
ISYfAC                   endif
     *
     C                   enddo
     *
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
510gA*  PRTLBL  Print single label.
     *
510gAC     prtlbl        begsr
CB2tA*
CB2tAC                   eval      kylbl# = $plbl#
CB2tA*
CB2tAC                   if        client = Cheney
CB2tA*
CB2tA*    Look up Merge label number for Child zone Runner Flag.
CB2tAC                   if           ($pcmd = '*SHORT'
CB2tAC                              or $pcmd = '*SHORTM')
CB2tAC                             and $pgen = 2
CB2tAC     $plbl#        setll     label11
CB2tAC                   dow       forevr = forevr
CB2tAC     $plbl#        reade     label11
CB2tAC                   if        %eof(label11)
CB2tAC                   leave
CB2tAC                   endif
CB2tA*    Load merge lbl# into key field.
CB2tAC                   if            albrte  = $prtid
CB2tAC                             and albctr# = $plbl#
CB2tAC                   eval      kylbl# = alblbl#
CB2tAC                   leave
CB2tAC                   endif
CB2tAC                   enddo
CB2tA*
CB2tAC                   endif
CB2tA*
CB2tAC                   endif
     *
510gA*  get label record.
     *
CB2tDC*    $plbl#        chain     label
CB2tMC     kylbl#        chain     label
510gAC                   if        not %found(label)
510gAC                   eval      error = *on
510gAC                   goto      endpl
510gAC                   endif
650kA*
650kA*  Position to first unique piece number for label.
650kA*
700eD ***  keyorp2       setll     ordp2
CB2tDC*    $plbl#        setll     ordp2
CB2tMC     kylbl#        setll     ordp2
510gA*
510gA*  Move information into parameter fields.
510gA*
640uMC                   eval      $pwhse = lb_lbwhse
640uMC                   eval      $prtid = lb_lbrte
510gA*
510gA*  Get label record.
510gA*
510gAC     key32a        setll     label32
510gAC                   dou       forevr <> forevr
510gAC     key32a        reade     label32
510gAC                   if        %eof(label32)
CB2tMC                             or lblbl# = kylbl#
CB2tDC*                            or lblbl# = $plbl#
510gAC                   leave
510gAC                   endif
510gAC                   enddo
701cA*
701cAC     keyim         chain     itemmsc
701cAC                   if        not %found(itemmsc)
701cAC                   eval      imbrnd=*blanks
701cAC                   endif
530eA*
530eA*     Get order header record
530eA*
530eAC                   exsr      getORDH
650oA*
650oA*     Get order header misc
650oA*
650oAC                   exsr      getORDHM
720dA*
720dA*     Get order detail record
720dA*
720dAC                   exsr      getORDD
530eA*
530eA*     Get order detail miscellaneous
530eAC                   exsr      getORDDM
650kA*
650kA*          Get unique piece number for label.
650kA*
700eD ***  keyorp2       reade     ordp2
700kM ***  keyorp        reade     ordp2
700kA ***                if        %eof
700kA ***                eval      unqpiece# = 0
700kA ***                else
700kA ***                eval      unqpiece# = orpup#
700kA ***                endif
510gA*
510gA*    If label not found for some strange reason, get out.
510gA*
510gAC                   if        %eof(label32)
510gAC                   eval      error = *on
510gAC                   goto      endpl
510gAC                   endif
     *
CBSe *  Print "Flag" on runner pick label
     *
CBSe C                   eval      t#spcl = *blanks
CBSe C                   if        $pcmd = '*SHORT'
650aAC                             or $pcmd = '*SHORTM'
CBSe C                   move      'FLAG'        t#spcl
CBSe C                   endif
510gA*
510gA*    Initialize label fields.
510gA*
510gA*    When printing short labels, use shorted qty,
510gA*    not original label pick qty.
510gA*
520dAC                   if        $pcmd = '*SHORT  '
650aAC                             or $pcmd = '*SHORTM '
510gAC                   eval      w1qty2 = $pqty
520dAC                   eval      pckqty = $pqty
520dAC                   else
510gAC                   eval      w1qty2 = lbqpck
520dAC                   eval      pckqty = lbqpck
520dAC                   endif
520eA*   If no qty has been picked, set PCKQTY to 1 so
520eA*   1 label will print.
     *
520eAC                   if        pckqty = 0
520eAC                   eval      pckqty = 1
520eAC                   endif
640tD ***                exsr      crtstp
510gA*
510gAC     keyil         chain     piritem
510gAC                   if        not %found(piritem)
510gAC                   eval      itvit# = *blanks
510gAC                   endif
     *
CBIaA*  Get extended description
     *
CBIaAC                   eval      t#dsc1 = *blanks
CBIaAC                   eval      t#dsc2 = *blanks
CBIaAC     keyix         chain     itemdsc                            79
CBIaAC                   if        not *in79
CBIaAC                   eval      t#dsc1 = ixdsc1
CBIaAC                   eval      t#dsc2 = ixdsc2
CBIaAC                   endif
510gA*
510gA*    Print label.
510gA*
510gA*        Either print a combination label ...
510gA*
510gAC                   select
520dMC                   when      pckqty >= opclvl
CB3mAC                             or $pcmd = '*AMPBOX'
510gAC                             or ITTYPE = 'S'
FFCbAC                             and client <> FischerFoods
HKWeAC                             and client <> hkw
510gAC                   eval      combo = '1'
520dMC                   eval      w1pick = pckqty
CCPaAC                   if        client = capitolcity
CWDwAC                             or client = cashwa
GFSkAC                             or client = getfresh
FRFaAC                             or client = frf
CCPaAC                   exsr      lblitmn
CCPaAC                   endif

700kA*          Get unique piece number for label.
700kA*
700kAC     keyorp        reade     ordp2
700kAC                   if        %eof
700kAC                   eval      unqpiece# = 0
700kAC                   else
700kAC                   eval      unqpiece# = orpup#
700kAC                   endif

510gAC                   exsr      lblpck
     C*
510gAC                   other
     *
510gA*        ... Or print individual labels.
     *
510gAC                   eval      combo = *off
CCPaAC                   if        client = capitolcity
CLDwAC                             or client = cityline
CWDwAC                             or client = cashwa
GFSkAC                             or client = getfresh
FRFaAC                             or client = frf
CCPaAC                   exsr      lblitmn
CCPaAC                   endif
530cAC                   eval      $gcmd = '*FIRST  '
530cAC                   eval      $gqypl = *zeros
650aA*
650aA*  If *SHORT or *SHORTM, reset the starting point for ORDP ...
650aA*  find and use the next sequential Trax# for this label which
650aA*  hasn't already been used.
650aA*
650aAC                   select
650aA*
650aAC                   when      $pcmd = '*SHORT  '
650aAC                             or $pcmd = '*SHORTM '
650aAC                   if        opuplv = 'N'
650aAC                             and ($pcmd = '*SHORT  '
700xAC                             or $pcmd = '*SHORTM ')
650aAC                   eval      cntTrax = (lbqpck - $pqty) + 1
650aAC                   else
650aAC                   eval      cntTrax = lbqpck +1
650aAC                   endif
650aAC     keyorp        setll     ordp2
650aAC                   do        cntTrax       TraxIndx          4 0
650aAC     keyorp        reade     ordp2
650aAC                   if        %eof
650aAC                   leave
650aAC                   endif
650aAC                   if        orpttl = 1
650aAC                             or cntTrax = 1
650aAC     keyorp        setll     ordp2
650aAC                   leave
650aAC                   endif
650aAC                   if        TraxIndx = cntTrax
650aAC     keyorp        readpe    ordp2
650aAC                   leave
650aAC                   endif
650aAC                   enddo
650aA*
650aAC                   endsl

520dMC     1             do        pckqty        w1pick

530gA*          Get unique piece number for label.
530gA*
530gAC     keyorp        reade     ordp2
530gAC                   if        %eof
530gAC                   eval      unqpiece# = 0
530gAC                   else
530gAC                   eval      unqpiece# = orpup#
530gAC                   endif

510gAC                   exsr      lblpck
530cAC                   eval      $gqypl = $gqypl - 1
530cAC                   if        $gqypl = 0
530cAC                   eval      $gcmd = '*NEXT   '
530cAC                   else
530cAC                   eval      $gcmd = *blanks
530cAC                   endif
510gAC                   enddo
     *
510gAC                   endsl
     *
ISYfAC                   if        client <> isupply
CB2qAC                             and $pcmd <> '*PICK'
530eAC                   exsr      lblend
ISYfAC                   endif
     *
510gAC     endpl         endsr
500gA*----------------------------------------------------------------
500gA*
500gA*  PRTLB2  Print label(s) for current label record.
500gA*
500gA*    This routine was created to consolidate the logic to print
500gA*    the label(s) for a single LABEL record. This routine is
500gA*    initially going to be called from PRTSEL, PRTLBL and SETEND
500gA*    (because of a Cheney custome mod to print individual zone
500gA*    pickup labels).
500gA*
500gA*    The main code for this routine was take from PRTSEL. It
500gA*    needed to be slightly modified because PRTLBL used the $pqty
500gA*    instead of lbqpck.
500gA*
500gAC     prtlb2        begsr
500gA*
500gA*  Determine quantity to use.
500gA*
500gAC                   if        #from = 'PRTLBL'
500gAC                   eval      pckqty = $pqty
500gAC                   else
500gAC                   eval      pckqty = lbqpck
500gAC                   endif
     *
CBIaA*  Get extended description
     *
CBIaAC                   eval      t#dsc1 = *blanks
CBIaAC                   eval      t#dsc2 = *blanks
CBIaAC     keyix         chain     itemdsc                            79
CBIaAC                   if        not *in79
CBIaAC                   eval      t#dsc1 = ixdsc1
CBIaAC                   eval      t#dsc2 = ixdsc2
CBIaAC                   endif
     *
CBIaA*  Get brand name from ITEMMSC.
     *
CBIaAC                   eval      t#brnd = *blanks
CBIaAC     keyim         chain     itemmsc                            79
CBIaAC                   if        not *in79
CBIaAC                   eval      t#brnd = imbrnd
CBIaAC                   endif
     *   Price for Breakers
CBIaAC                   eval      t#brkr = *blanks
CBIhAC                   if        odor2 > 0
CBIhAC                   move      odor2         dsord2
CBIhAC     t#brkr        cat       dso5:0        t#brkr
CBIhAC     t#brkr        cat       '.':0         t#brkr
CBIhAC     t#brkr        cat       dso2:0        t#brkr
CBIhAC                   endif
CBIhA*   Truck code for Willcall orders
CBIhAC                   eval      t#truk = *blanks
CBIhAC                   if        ohtype = 'W'
CBIhAC                   eval      t#truk = ohtruk
CBIhAC                   endif
     *
CBSe *  Print "Flag" on runner pick label
     *
CBSe C                   eval      t#spcl = *blanks
CBSe C                   if        $pcmd = '*SHORT'
650aAC                             or $pcmd = '*SHORTM'
CBSe C                   move      'FLAG'        t#spcl
CBSe C                   endif
     *
     *     Initialize label fields.
     *
510bA*     When printing short labels, load shorted qty,
510bA*     not original label pick qty.
650aMC                   if        $pcmd = '*SHORT' or
650aAC                             $pcmd = '*SHORTM'
510bAC                   eval      w1qty2 = $pqty
510bAC                   else
     C                   eval      w1qty2 = lbqpck
510bAC                   endif
     C                   exsr      crtstp
     **
ALN AC     keyil         chain     piritem                            79
ALN AC                   if        *in79
ALN AC                   eval      itvit# = *blanks
ALN AC                   endif
CBxxA*
CBxxA*     Get order header record
CBxxA*
CBxxAC                   exsr      getORDH
CBSsA*
CBSsA*  Position to first unique piece number for label.
CBSsA*
CBSzMC     keyorp5       setll     ordp5
     *
     *     Either print a combination label ...
CB2fA*        For Cheney GWB, print combo for PK's
CBSrA*        For Cheney, do not print a combo for cwgt items.
     *
     C                   select
500gMC                   when      pckqty >= opclvl  and
CBSrAC                             itcwgt <> 'Y'
CB2fAC                             or
CB2fAC                             cliloc = cbigwb  and
CB2fAC                             lbutyp <> 'N'
     C                   eval      combo = *on
     *
     *        Print one label.
     *
CBSsA*
CBSsA*          Get unique piece number for label.
CBSsA*
CBSzMC     keyorp5       reade     ordp5
CBSSaC                   if        %eof
CBSSaC                   eval      unqpiece# = 0
CBSSaC                   else
CBSSaC                   eval      unqpiece# = orpup#
CBSSaC                   endif
500gMC                   eval      w1pick = pckqty
     C                   exsr      lblpck
CHYv * Print special instruction for Breakers
CHYv C                   if        dsospc = 'Y'
CHYv C                   exsr      lblwsp
CHYv C                   endif
     *
     *        See if we should print the "after" combo warning.
     *
     C                   if        opcwra = 'Y'
     C                   exsr      lblcma
     C                   endif
     *
     C                   other
     *
     *     Or print individual labels.
     *
     C                   eval      combo = *off
     *
650aA*  If *SHORT or *SHORTM, reset the starting point for ORDP ...
650aA*  find and use the next sequential Trax# for this label which
650aA*  hasn't already been used.
650aA*
650aAC                   select
650aA*
650aAC                   when      $pcmd = '*SHORT  '
650aAC                             or $pcmd = '*SHORTM '
650aAC                   if        opuplv = 'N'
650aAC                             and $pcmd = '*SHORT  '
650aAC                   eval      cntTrax = (lbqpck - $pqty) + 1
650aAC                   else
650aAC                   eval      cntTrax = lbqpck +1
650aAC                   endif
650aAC     keyorp5       setll     ordp5
650aAC                   do        cntTrax       TraxIndx          4 0
650aAC     keyorp5       reade     ordp5
650aAC                   if        %eof
650aAC                   leave
650aAC                   endif
650aAC                   if        orpttl = 1
650aAC                             or cntTrax = 1
650aAC     keyorp5       setll     ordp5
650aAC                   leave
650aAC                   endif
650aAC                   if        TraxIndx = cntTrax
650aAC     keyorp5       readpe    ordp5
650aAC                   leave
650aAC                   endif
650aAC                   enddo
650aA*
650aAC                   endsl
     *
500gMC     1             do        pckqty        w1pick
CBSsA*
CBSsA*          Get unique piece number for label.
CBSsA*
CBSzMC     keyorp5       reade     ordp5
CBSSaC                   if        %eof
CBSSaC                   eval      unqpiece# = 0
CBSSaC                   else
CBSSaC                   eval      unqpiece# = orpup#
CBSSaC                   endif
     *
     C                   exsr      lblpck
CHYv * Print special instruction for Breakers
CHYv C                   if        dsospc = 'Y'
CHYv C                   exsr      lblwsp
CHYv C                   endif
     *
     C                   enddo
     *
     C                   endsl
     *
     *     See if we should print the "after" um warning.
     *
CHYfAC                   if        lbutyp <> 'N'  and
CHYfAC                             opuwra = 'Y'  and
CBYfAC                             $pszon = 'CHEM'  or
CHYfAC                             lbutyp <> 'N'  and
CHYfAC                             opuwra = 'Y'  and
CBYfAC                             $pszon = 'FRZ'
CHYfAC                   exsr      lbluma
CHYfAC                   endif
     *
     *     Print catch weight labels.
     *
     C                   if        itcwgt = 'Y'  and
     C                             opcwgt <> 0  and
CBIqAC                             lbpal# < 20000
500gMC     pckqty        div       opcwgt        lbls
     C                   mvr                     remain
     C                   if        remain <> 0
     C                   add       1             lbls
     C                   endif
CBIsMC     1             do        lbls          @qty1
CBIiAC                   if        dsmeat <> 'Y'  and
CHYcAC                             dsppck <> 'Y'
     C                   exsr      lblcwt
CBIiAC                   endif
     C                   enddo
     C                   endif
     *
ALNhAC                   if        itcwgt = 'Y'
500gMC     pckqty        mult      .083          wktime
ALNhAC                   add       wktime        cwtime
ALNhAC                   endif
ALNdAC                   exsr      zzattl
     *
     C     endpl2        endsr
     *----------------------------------------------------------------
     *
     *  PRTPRP  Print potential replenishment labels.
     *
     C     prtprp        begsr
     *
     C                   eval      first = *on
     *
     *    Loop through potential replenishment batch of labels.
     *
     C     keyl3f        setll     label3
     *
     C                   dou       forevr <> forevr
     *
     C     keyl3f        reade     label3                                 78
     C                   if        *in78
     C                   leave
     C                   endif
     *
     *       Skip label if nothing was picked.
     *
     C                   if        lbqpck = 0
     C                   iter
     C                   endif
     *
     *       Skip label if closed.
     *
     C                   if        lbstat = 'C'
     C                   iter
     C                   endif
     *
     *       Print "Beginning Replenishment" pick label.
     *
     C                   if        first = *on
     C                   exsr      lblbrp
     C                   eval      first = *off
     C                   endif
     *
     *       Print replenishment label if necessary.
     *
     C                   eval      w1qty = lbqpck
     C                   if        ittype = 'B'
     C                   eval      toitem = lbitem
     C                   eval      todesc = itdesc
     C     keyil         chain     itemlnk                            79
     C                   eval      fritem = ilitm2
     C     keyit         chain     piritem                            79
     C                   eval      frdesc = itdesc
     C                   eval      toqty = itumq2
     C                   move      itum2         toum
     C                   exsr      lblrp2
     C                   else
     C                   exsr      lblrp1
     C                   endif
     *
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PRTRPL  Print replenishment labels for zone
     *
     C     prtrpl        begsr
     *
     C                   eval      first = *on
     *
     *  Loop through pallets for zone.
     *
720fDC**                 eval      kytype = 'O'
720gMC                   eval      kytype = tbPalletType
     C     keyps3        setll     pltsum3
     C                   dou       forevr <> forevr
     C     keyps3        reade     pltsum3                                79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *    Loop through replenishment labels for pallet.
     *
     C                   eval      kyltyp = 'R'
     C     keyl31        setll     label31
     *
     C                   dou       forevr <> forevr
     *
     C     keyl31        reade     label31                                78
     C                   if        *in78
     C                   leave
     C                   endif
     *
     *       Skip label if nothing was picked.
     *
     C                   if        lbqpck = 0
     C                   iter
     C                   endif
     *
     *       Print "Beginning Replenishment" pick label.
     *
     C                   if        first = *on
     C                   exsr      lblbrp
     C                   eval      first = *off
     C                   endif
     *
     *       Print replenishment label if necessary.
     *
     C                   eval      w1qty = lbqpck
     C                   if        ittype = 'B'
     C                   eval      toitem = lbitem
     C                   eval      todesc = itdesc
     C     keyil         chain     itemlnk                            79
     C                   eval      fritem = ilitm2
     C     keyit         chain     piritem                            79
     C                   eval      frdesc = itdesc
     C                   eval      toqty = itumq2
     C                   move      itum2         toum
     C                   exsr      lblrp2
     C                   else
     C                   exsr      lblrp1
     C                   endif
     *
     C                   enddo
     *
     C                   enddo
     *
     C                   endsr
500 A*----------------------------------------------------------------
500 A*
500 A*  PRTRP3  Print Breakdown Priority Replenishment labels.
500 A*
500 AC     prtrp3        begsr
     *
     C                   eval      first = *on
     *
     *  Loop through potential replenishment batch of labels.
     *
     C     keyl3f        setll     label3
     *
     C                   dou       forevr <> forevr
     *
     C     keyl3f        reade     label3                                 78
     C                   if        *in78
     C                   leave
     C                   endif
     *
     *    Skip label if nothing was picked.
     *
     C                   if        lbqpck = 0
     C                   iter
     C                   endif
     *
     *    Print "Beginning Replenishment" pick label.
     *
     C                   if        first = *on
500  C                   exsr      lblbr3
     C                   eval      first = *off
     C                   endif
     *
     *    Print replenishment label if necessary.
     *
     C                   eval      svtype = ittype
     C                   if        ittype = 'B'
     C                   eval      toitem = lbitem
     C                   eval      todesc = itdesc
     C     keyil         chain     itemlnk                            79
     C                   eval      fritem = ilitm2
     C     keyit         chain     piritem                            79
     C                   eval      frdesc = itdesc
     C                   eval      toqty = itumq2
     C                   move      itum2         toum
     C                   endif
     *
     C                   eval      combo = *off
     C     1             do        lbqpck        w1qty
     C                   exsr      lblrp3
     C                   enddo
     *
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PRTSEL  Print normal selection labels for zone.
     *
CLDeA*  This routine have been modified to do a special call to SETEND
CLDeA*  after generation 1 DRY labels have been printed. Re: City
CLDeA*  Line combines DRY and REF into a single zone. However, they
CLDeA*  want the DRY merge pickup label to print after the DRY labels.
CLDeA*  They do not have REF PIR.
CLDeA*
     C     prtsel        begsr
CLDeAC                   eval      cldmrg = '*NORMAL '
CLDeAC                   eval      clddry = *off
CLDeAC                   eval      skpdry = *off
     *
     *   Print header for this set of selection labels.
     *
     C                   exsr      setbeg
     *
CLDeAC     beglup        tag
YH2dAC                   if        client = yhata
YH2dAC                   exsr      cntlifo
YH2dAC                   endif
GFCcA*
GFCcA*   Print set summary label.
GFCcA*
GFCcAC                   if        client = gfc
GFCcAC                   exsr      lblsetsum
GFCcAC                   endif
     *
     *   Loop through selection labels for transaction.
     *
     C                   eval      count = 0
     C                   eval      kyltyp = 'O'
650gAC                   eval      auditflag = 'N'
640sAC                   select
FSHdAC                   when      client = FischerFoods
KFS AC                             or client = Kellys
GFSfAC                             or client = Getfresh
HKWaAC                             or client = HKW
GLPbAC                             or client = Greenleaf
SVLfAC                             or client = saval
FRFbAC                             or client = FRF
CPCbAC                             or client = cpc
FSHdAC     keyl32        setll     label32d
CTWcAC                   when      client = citywholesale
CTWcAC     keyl32        setll     label32e
SFGdAC                   when      client = SGC
SFGdAC     keyl32        setll     label32g
MJKcAC                   when      client = mjkellner
MJKcAC                             and mjkContract
MJKbMC     keyl32        setll     label32s
CLDiAC                   when      client = cityline
CLDiMC     keyl32        setll     label32x
PFCaAC                   when      client = Prestofoods
PFCaAC     keyl32        setll     label32j
ISYcMC                   when      client = isupply
ISYcMC     keyl32        setll     label32i
640sAC                   other
     C     keyl32        setll     label32c
640sMC                   endsl
     *
     C                   dou       forevr <> forevr
640sAC                   select
FSHdAC                   when      client = FischerFoods
KFS AC                             or client = Kellys
GFSfAC                             or client = Getfresh
HKWaAC                             or client = HKW
GLPbAC                             or client = Greenleaf
SVLfAC                             or client = saval
FRFbAC                             or client = FRF
CPCbAC                             or client = cpc
FSHdAC     keyl32        reade     label32d                               78
CTWcAC                   when      client = citywholesale
CTWcAC     keyl32        reade     label32e                               78
SFGdAC                   when      client = SGC
SFGdAC     keyl32        reade     label32g                               78
MJKcAC                   when      client = mjkellner
MJKcAC                             and mjkContract
MJKbMC     keyl32        reade     label32s                               78
CLDiAC                   when      client = cityline
CLDiMC     keyl32        reade     label32x                               78
PFCaAC                   when      client = Prestofoods
PFCaAC     keyl32        reade     label32j                               78
ISYcMC                   when      client = isupply
ISYcAC     keyl32        reade     label32i                               78
640sAC                   other
     C     keyl32        reade     label32c                               78
640sMC                   endsl
     C                   if        *in78
640cAC                             or (oplb1 = 'N'
640cAC                             and oplb2 = 'N')
     C                   leave
     C                   endif
     *
     *     There could be more than one PLTSUM rec for the same pallet,
     *     but with a different pstrn#, causing LABEL rec to be read
     *     twice in the joined logical LABEL32X, so make sure the pstrn#
     *     is equal to the lsttrn before printing.
     *
520aACSR                 if        pstrn# <> lsttrn
520aACSR                 iter
520aACSR                 endif
     *
CLDeAC                   if        client = cityline
CLDeA*
CLDeA*     See if we should be ignoring DRY labels.
CLDeA*
CLDeAC                   if        skpdry = *on
CLDeAC                             and lbwhdp = 'DRY'
CLDeAC                   iter
CLDeAC                   endif
CLDeA*
CLDeA*     Flag when we read a Gen 1 DRY label
CLDeA*
CLDeAC                   if        $pgen = 1
CLDeAC                             and lbwhdp = 'DRY'
CLDeAC                   eval      clddry = *on
CLDeAC                   endif
CLDeA*
CLDeA*     See if we should call SETEND to just print merge labels.
CLDeA*
CLDeAC                   if        $pgen = 1
CLDeAC                             and clddry = *on
CLDeAC                             and lbwhdp <> 'DRY'
CLDeAC                   eval      cldmrg = '*MRGONLY'
CLDeAC                   exsr      setend
CLDeAC                   eval      cldmrg = '*SKIPMRG'
CLDeAC                   eval      clddry = *off
CLDeAC                   eval      skpdry = *on
CLDeAC                   goto      beglup
CLDeAC                   endif
CLDeAC                   endif
     *
     *     Skip label if cross dock.
     *
     C                   if        lbstyp = 'X'
     C                   iter
     C                   endif
     *
     *     Skip label if nothing was picked.
     *
     C                   if        lbqpck = 0
     C                   iter
     C                   endif
650cA*
650cA*     Skip label if nothing was picked.
650cA*
650cAC                   if        $pcmd = '*RPRTLB '

650cAC                   if        opflbl = lblbl#
650cAD***                if        opflbl <= lblbl#
650cAD***                          and optlbl >= lblbl#
650cAD***                eval      printlabel = *on
650cAD***                else
650cAC                   eval      printlabel = *on
650cAC                   endif

640iAC                   if        not printlabel
640iAC                   iter
640iAC                   endif

640iAC                   if        optlbl = lblbl#
640iAC                   eval      printlabel = *off
640iAC                   endif

640iAC                   endif
HMWdA*
HMWdA*       Skip these items.
HMWdA*
HMWdAC                   if        client = hmwagner
HMWdA*
HMWdAC                   if           lbitem = '900300-CS'
HMWdAC                             or lbitem = '900301-CS'
HMWdAC                             or lbitem = '900302-CS'
HMWdAC                             or lbitem = '900300'
HMWdAC                             or lbitem = '900301'
HMWdAC                             or lbitem = '900302'
HMWdAC                   iter
HMWdAC                   endif
HMWdAC                   endif
CWDfA*
CWDfA*       Skip cross-dock pick labels.
CWDfA*
CWDfAC                   if        client = Cashwa
CWDfA*
CWDfAC                   if           lbdisp = 'KD-101-1'
CWDfAC                             or lbdisp = 'KF-101-1'
CWDfAC                             or lbdisp = 'KR-101-1'
CWDfAC                   iter
CWDfAC                   endif
CWDfA*
CWDfAC                   endif
     *
     C                   add       1             count
CDIaA*
CDIaA*     For CDI, get category code for item.
CDIaA*
CDIaAC                   move      lbwhse        $cwhse
CDIaAC                   if        client = cdi
CDIaAC                   call      'GETICAT'
CDIaAC                   parm                    $cwhse
CDIaAC                   parm                    lbitem
CDIaAC                   parm                    $ccode
CDIaAC                   parm                    $chhdr
CDIaAC                   parm                    $chdtl
CDIaAC                   parm                    $chcat
CDIaAC                   endif
640jD*
640jD*     See if we should print the "before" um warning.
640jD*
640kMC                   if        lbutyp <> 'N'
640kMC                             and opuwrb = 'Y'
SFGiAC                             or  imp_flg = *on
SFGiAC                             and opuwrb = 'Y'
640jD ***                exsr      lblumb
640kAC                   eval      svutyp = *blanks
640kMC                   endif
     *
     *     Initialize label fields.
     *
     C                   eval      w1qty2 = lbqpck
640tD ***                exsr      crtstp
     **
FRF AC                   eval      newdsc1 = *blanks
FRF AC                   eval      newdsc2 = *blanks
     C     keyil         chain     piritem                            79
FRF AC                   select
FRF AC                   when      not %found(piritem)
FRF AC                   eval      itvit# = *blanks

FRF AC                   when      %found(piritem)
FRF AC                   eval      ixdsc1 = *blanks
FRF AC                   eval      ixdsc2 = *blanks
FRF AC     keyil         chain     itemdsc
FRF AC                   if        %found(itemdsc)

FRF AC                   eval      newdsc1 = *blanks
FRF AC                   eval      newdsc2 = *blanks
FRF AC                   if        client = frf
FRF AC                   call      @getdesc
FRF AC                   parm      ixdsc1        olddsc
FRF AC                   parm                    newdsc
FRF AC                   parm      '2'           fmtcod

FRF AC                   eval      newdsc1 = %subst(newdsc:1:34)
FRF AC                   eval      newdsc2 = %subst(newdsc:35:34)
FRF AC                   endif

FRF AC                   endif
FRF AC                   endsl
CLDvA**
CLDvAC     keyil         chain     ssbxref
CLDvAC                   if        not %found(ssbxref)
CLDvAC                   eval      sscombo = 'N'
CLDvAC                   endif
640 A**
640aAC                   if            client = Cityline
640 AC     keyil         chain     itemfld
640 AC                   if        not %found(itemfld)
640 AC                   eval      ifcat = *blanks
640 AC                   endif
640 AC                   endif
NCSbA*
NCSbA*    Get vendor name to print on pick label
NCSbA*
640sAC                   select
NCSaAC                   when      client = nicholas
GFCaAC                             or client = gfc
NCSbAC                   eval      wkvnam = *blanks
NCSbAC     keyims        chain     itemmsc
NCSbAC                   if        %found(itemmsc)
NCSbAC                   eval      wkvnam = %subst(imvnam:1:25)
NCSbAC                   endif
640sAC                   when      client = sgc
SFGc *
SFGc C     keyim         chain     itemmsc                            79
SFGc C                   if        *in79=*on
SFGc C                   eval      imbrnd=*blanks
SFGc C                   endif
     *
SFGf C     keyix         chain     itemdsc                            79
SFGf C                   if        *in79=*on
SFGf C                   eval      ixdsc2=*blanks
SFGf C                   eval      dsdsc2=ixdsc2
SFGf C                   else
SFGf C                   eval      dsdsc2=ixdsc2
SFGf C                   endif
BIRbAC                   when      client = birite
BIRb C                   eval      t#brnd = *zeros
BIRb C     keyim         chain     itemmsc                            79
BIRb C                   if        not *in79
BIRb C                   eval      t#brnd = imbrnd
BIRb C                   endif
HMWc *
HMWc C                   other
HMWc *
HMWc C     keyim         chain     itemmsc                            79
HMWc C                   if        *in79=*on
HMWc C                   eval      imbrnd=*blanks
HMWc C                   endif
HMWc *
640sAC                   endsl
530bA*
530bA*     Get order header record
530bA*
530bAC                   exsr      getORDH
dry A*
dry A*     Get order header misc
dry A*
dry AC                   exsr      getORDHM
CWDaA*
CWDaA*     Get order detail record
CWDaA*
CWDaAC                   exsr      getORDD
CWDgA*
CWDgA*     Get order detail miscellaneous
CWDgA*
CWDgAC                   exsr      getORDDM
     *
MATaA*  Position to first unique piece number for label.
MATaA*
MATaAC     keyorp        setll     ordp2
CLDlA*
CLDlA*        Get PIR sequence number
CLDlA*
CLDlAC                   if        client = cityline
CLDlAC                             and $pgen > 1
CLDlAC     keypq2        chain     pirseq2
CLDlAC                   if        not %found(pirseq2)
CLDlAC                   eval      psqbeg = 0
CLDlAC                   endif
CLDlAC                   endif
     *
     *     Either print a combination label ...
     *
     C                   select
     C                   when      lbqpck >= opclvl

CLDvMC                             or sscombo = 'Y'

520hAC                             or opptyp = 'B'

GFSaAC                             or client = getfresh
GFSaAC                             and gfsdm1_omcmbflg = 'Y'

GFSiDC*                            or client = getfresh
GFSiDC*                            and lbutyp = '1'
GFSiDC*                            and itum2  = 'LB'
GFSiDC*                            and (itminq = 0
GFSiDC*                            or  itminq = 1)

GFSiDC*                            or client = getfresh
GFSiDC*                            and lbutyp = '2'
GFSiDC*                            and itum2  = 'LB'
GFSiDC*                            and (itminq = 0
GFSiDC*                            or  itminq = 1)

520hAC                   if        opptyp = 'B'
520hAC                   eval      combo = *off
520hAC                   else
     C                   eval      combo = *on
520hAC                   endif
640lD*
640lD*        See if we should print the "before" combo warning.
640lD*
CLDbAC                   select
CLDbAC                   when      client = cityline
CLDbAC                             and opcwrb = 'Y'
CLDbAC                             and ittype <> 'S'
CLDbAC                             and opptyp <> 'B'
CLDbAC                   eval      @qty2 = w1qty2
CLDbAC                   exsr      lblcmb
CLDbAC                   when      client <> cityline
CLDbAC                             and opcwrb = 'Y'
640lMC                             and opptyp <> 'B'
DRYbAC                   eval      @qty2 = w1qty2
640lMC                   exsr      lblcmb
CLDbMC                   endsl
ctwp *        Print "RECAP" label.
ctwpAC                   if        tobaccoflag = *On
ctwp C                             and recapflag = 'Y'
ctwpMC                   eval      kyfmt = 'RECAP   '
ctwpAC                   exsr      fillb1
ctwpAC                   endif
     *
     *        Print one label.
     *
MATaA*
MATaA*          Get unique piece number for label.
MATaA*
MATaAC     keyorp        reade     ordp2
MATaAC                   if        %eof
MATaAC                   eval      unqpiece# = 0
MATaAC                   else
MATaAC                   eval      unqpiece# = orpup#
MATaAC                   endif
650lA*
650lAC                   eval      SectionString = *blanks
650lAC                   eval      SectionCount = 0
650lAC                   call      @getlabelps
650lAC                   parm                    $pwhse
650lAC                   parm                    lblbl#
650lAC                   parm                    SectionString
650lAC                   parm                    SectionCount
650lA*
     C                   eval      w1pick = lbqpck
500dAC                   eval      $gcmd = '*FIRST  '
500dAC                   eval      $gqypl = *zeros
CCPaAC                   if        client = capitolcity
CLDwAC                             or client = cityline
CWDwAC                             or client = cashwa
GFSkAC                             or client = getfresh
FRFaAC                             or client = frf
CCPaAC                   exsr      lblitmn
CCPaAC                   endif
640 MC                   if        client = Cityline
640 AC                             and ifcat  = 'CLAMS'
CLDk C                   exsr      lblitl
CLDk C                   endif
     C                   exsr      lblpck
     *
     *        See if we should print the "after" combo warning.
     *
CLDbAC                   select
CLDbAC                   when      client = cityline
CLDbAC                             and opcwra = 'Y'
CLDbAC                             and ittype <> 'S'
CLDbAC                             and opptyp <> 'B'
CLDbAC                   exsr      lblcma
CLDbAC                   when      client <> cityline
CLDbAC                             and opcwra = 'Y'
520hAC                             and opptyp <> 'B'
640lMC                   exsr      lblcma
CLDbMC                   endsl
     *
     C                   other
     *
     *     Or print individual labels.
     *
ctwp *        Print "RECAP" label.
ctwpAC                   if        tobaccoflag = *on
ctwp C                             and recapflag = 'Y'
ctwpMC                   eval      kyfmt = 'RECAP   '
ctwpAC                   exsr      fillb1
ctwpAC                   endif
     *
     C                   eval      combo = *off
500dAC                   eval      $gcmd = '*FIRST  '
500dAC                   eval      $gqypl = *zeros
CCPaAC                   if        client = capitolcity
CLDwAC                             or client = cityline
CWDwAC                             or client = cashwa
GFSkAC                             or client = getfresh
FRFaAC                             or client = frf
CCPaAC                   exsr      lblitmn
CCPaAC                   endif
ctwaAC                   select
ctwaAC                   when      retailflag
ctwaAC                   eval      retailrows = lbqpck / 4 + 2
ctwaAC                   eval      retailleft = %Rem(lbqpck:4)
ctwaAC     1             do        retailrows    w1pick

ctwaAC                   if        retailrows = w1pick
ctwaAC                             and retailleft = *zeros
ctwaAC                   leave
ctwaAC                   endif
ctweA
ctwaAC                   exsr      lblpck
ctwaAC                   eval      $gqypl = $gqypl - 1
ctwaAC                   if        $gqypl = 0
ctwaAC                   eval      $gcmd = '*NEXT   '
ctwaAC                   else
ctwaAC                   eval      $gcmd = *blanks
ctwaAC                   endif
ctwaAC                   enddo
ctwdA*
ctwdA*  Print lot label
ctwdA*
ctwdAC                   exsr      lbllotm

ctwaAC                   other

650aA*  If *SHORT or *SHORTM, reset the starting point for ORDP ...
650aA*  find and use the next sequential Trax# for this label which
650aA*  hasn't already been used.
650aA*
650aAC                   select
650aA*
650aAC                   when      $pcmd = '*SHORT  '
650aAC                             or $pcmd = '*SHORTM '
650aAC                   if        opuplv = 'N'
650aAC                             and $pcmd = '*SHORT  '
650aAC                   eval      cntTrax = (lbqpck - $pqty) + 1
650aAC                   else
650aAC                   eval      cntTrax = lbqpck +1
650aAC                   endif
650aAC     keyorp        setll     ordp2
650aAC                   do        cntTrax       TraxIndx          4 0
650aAC     keyorp        reade     ordp2
650aAC                   if        %eof
650aAC                   leave
650aAC                   endif
650aAC                   if        orpttl = 1
650aAC                             or cntTrax = 1
650aAC     keyorp        setll     ordp2
650aAC                   leave
650aAC                   endif
650aAC                   if        TraxIndx = cntTrax
650aAC     keyorp        readpe    ordp2
650aAC                   leave
650aAC                   endif
650aAC                   enddo
650aA*
650aAC                   endsl

     C     1             do        lbqpck        w1pick

MATaA*          Get unique piece number for label.
MATaA*
MATaAC     keyorp        reade     ordp2
MATaAC                   if        %eof
MATaAC                   eval      unqpiece# = 0
MATaAC                   else
MATaAC                   eval      unqpiece# = orpup#
MaTaAC                   endif

640 MC                   if        client = Cityline
640 AC                             and ifcat  = 'CLAMS'
CLDk C                   exsr      lblitl
CLDk C                   endif

     C                   exsr      lblpck
500dAC                   eval      $gqypl = $gqypl - 1
500dAC                   if        $gqypl = 0
500dAC                   eval      $gcmd = '*NEXT   '
500dAC                   else
500dAC                   eval      $gcmd = *blanks
500dAC                   endif
     *
     C                   enddo
     *
ctwaAC                   endsl
     *
     C                   endsl

DRYgAC                   if        client = dairyland
DRYgAC                             and CruiseShipFlg = 'Y'
DRYgAC     1             do        lbqpck
DRYgAC                   eval      kyfmt = 'CRUISE  '
DRYgAC                   exsr      fillb1
DRYgAC                   enddo
DRYgAC                   endif
     *
     *     See if we should print the "after" um warning.
     *
     C                   if        lbutyp <> 'N'
     C                             and opuwra = 'Y'
SFGiAC                             or  opuwra = 'Y'
SFGiAC                             and imp_flg = *on
     C                   exsr      lbluma
     C                   endif
     *
     *     Print catch weight labels.
     *
     C                   if        itcwgt = 'Y'
     C                             and opcwgt <> 0
     C     lbqpck        div       opcwgt        lbls              3 0
     C                   mvr                     remain            2 0
     C                   if        remain <> 0
     C                   add       1             lbls
     C                   endif
BIRaAC                   eval      c#qpck = lbqpck

HKWbA ***                if        client = HKW
HKWbA ***                          and lbqpck >= opclvl
HKWbA ***                eval      lbls = opclvl
HKWbA ***                endif

HKWbAC                   if        client = HKW
HKWgAC                   select
HKWgAC                   when      ohcust = 20120
HKWgAC                             or ohcust = 30510
HKWgAC                             or ohcust = 50055
HKWgAC                             or ohcust = 21210
HKWgAC                   if        lbqpck > 10
HWKgAC                   eval      lbls = 10
HKWgAC                   endif

HKWgAC                   when      ohcust = 99010
HKWgAC                             and lbitem = '002284'
HWKgAC                   eval      lbls = 1

HKWgAC                   when      ohcust = 28550
HKWgAC                             and lbitem = '002284'
HWKgAC                   eval      lbls = 1

HKWgAC                   when      lbucod = 'LB'
HKWgAC                             or lbucod = 'EA'
HKWgAC                   if        lbqpck > 10
HWKgAC                   eval      lbls = 10
HKWgAC                   endif

HKWgAC                   endsl
HWKbAC                   endif

     C     1             do        lbls

BIRaAC                   select
BIRaAC                   when      client = birite
BIRaAC                   exsr      cwtent
BIRaAC                   exsr      lblcwt
BIRaAC                   eval      c#qpck = c#qpck - 5
BIRaAC                   other
     C                   exsr      lblcwt
BIRaAC                   endsl
     C                   enddo
     C                   endif
     *
ALNhAC                   if        itcwgt = 'Y'
ALNhAC     lbqpck        mult      .083          wktime
ALNhAC                   add       wktime        cwtime
ALNhAC                   endif
ALNdAC                   exsr      zzattl
     *
     C                   enddo
     *
     *   Print summary for this set of selection labels.
     *
640cAC                   if        oplb1 = 'Y'
640cAC                             or oplb2 = 'Y'

BIRgAC                   select
BIRgAC                   when      client = birite
BIRgAC                             and $ptruk = 'WILLCALL'
BIRgAC                   other
     C                   exsr      setend
BIRgAC                   endsl
640cAC                   endif
510dA*
510dA*   Print END label.
510dA*
ISYfAC                   select
ISYfAC                   when      client = isupply
ISYfAC                   other
640cAC                   if        oplb1 = 'Y'
640cAC                             or oplb2 = 'Y'
510dAC                   exsr      lblend
640cAC                   endif
ISYfAC                   endsl
     *
     C                   endsr
700jA*----------------------------------------------------------------
700jA*
700jA*  PRTSELCBI  Print normal selection labels for zone.
700jA*
700jAC     prtselcbi     begsr
CHYdAC                   eval      meatpr = *off
CHYdAC                   eval      ppckpr = *off
     *
     *   Print header for this set of selection labels.
     *
     C                   exsr      setbeg
     *
     *   Loop through selection labels for transaction.
     *
CHYoAC                   eval      endtyp = '*NORMAL '
CHYoAC                   eval      lstlb# = -(1)
     *
     C                   eval      count = 0
     C                   eval      kyltyp = 'O'
     *
CBSfMC     keyl32        setll     label32d
     C                   dou       forevr <> forevr
CBSfAC     keyl32        reade     label32d                               78

     C                   if        *in78
     C                   leave
     C                   endif
     *
     *     Skip label if cross dock.
     *
     C                   if        lbstyp = 'X'
     C                   iter
     C                   endif
     *
     *     Skip label if nothing was picked.
     *
     C                   if        lbqpck = 0
     C                   iter
     C                   endif
650cA*
650cA*     Skip label if on reprint if a different label
650cA*
650cAC                   if        $pcmd = '*RPRTLB '

650cAC                   if        opflbl = lblbl#
650cAC                   eval      printlabel = *on
650cAC                   endif

650cAC                   if        not printlabel
650cAC                   iter
650cAC                   endif

650cAC                   if        optlbl = lblbl#
650cAC                   eval      printlabel = *off
650cAC                   endif

650cAC                   endif
     *
     C                   add       1             count
CHYoA*
CHYoA*     If we already printed merge labels,
CHYoA*       Then skip labels until we find the one that
CHYoA*            triggered the merge labels to be printed.
CHYoA*
CHYoAC                   if        endtyp = '*MERGE'  and
CHYoAC                             lstlb# <> lblbl#
CHYoAC                   iter
CHYoAC                   endif
CHYoA*
CHYoAC                   if        endtyp = '*MERGE'
CHYoAC                   eval      endtyp = '*LBFOUND'
CHYoAC                   endif
CHYoA*
CHYoA*     See if we should force the printing of merge labels
CHYoA*     in the middle of the pick.
CHYoA*
CHYoA*     Note: If we print the merge labels here, we can't just
CHYoA*     continue because the SETEND routine uses the same file.
CHYoA*     Therefore, we have to reset the file pointer and start
CHYoA*     at the beginning, skipping labels until we get to where
CHYoA*     we left off.
CHYoA*
CB1cA*     The logic for printing merge labels with in the DRY
CB1cA*     department is based on how the label records are
CB1cA*     arranged within DFPICK. The merge labels are to print
CB1cA*     after DK-243, which is the last slot of group lblvl2=6.
CB1cA*     Therefore, we print the merge labels when lblvl2>6.
CB1cA*
CHYoAC                   if        endtyp = '*NORMAL'
CBShAC                   eval      cbimrg = *off
CBShA*
CBShAC                   select
CBShA*
CBSiAC                   when      pstzon = 'PRD'
CBSiA**                Do nothing
CBShAC                   when      cliloc = cbiocl
CBShAC                   if        lbwhdp = 'CLR'
CBOcMC                             and lbaisl > ' CJ'

CBShAC                             or lbwhdp = 'FRZ'
CBShAC                             and lbaisl > ' FG'
CBShAC                   eval      cbimrg = *on
CBShAC                   endif
CBShA*
CBShAC                   other
CB2dA*
CB2dAC                   select
CB2dAC                   when      (cliloc = cbigwb)
CB2dA*      Print Merge Labels at end of Regular pick for GWB.
CB2dAC                   other
CB2dA*
CB1cDC**                 if        lbwhdp = 'CLR'  and
CB1xDC**                           lbaisl > ' CR'  or
CB2jD **                           lbwhdp = 'FRZ'  and
CB2jD **                           lbaisl > ' FE'  or
CB1cDC**                           lbwhdp = 'DRY'  and
CB1cDC**                           lblvl2 > 6
CB1cDC**                           lbwhdp = 'DRY'  and
CB1cDC**                           lbaisl > ' DK'  or
CB1cDC**                           lbwhdp = 'DRY'  and
CB1cDC**                           lbaisl = ' DF'  and
CB1cDC**                           lblvl2 >= 12
CBSd ****       LBAISL    ANDGT' FD'
CBShD****       LBWHDP    OREQ 'FRZ'
CBShD****       LBAISL    ANDEQ' FE'
CBSd ****       LBAISL    ANDEQ' FD'
CBShD****       LBLOC     ANDGT302
CBSd ****       LBLOC     ANDGT435
CB1cDC**                 eval      cbimrg = *on
CB1cDC**                 endif
CBShA*
CBShAC                   endsl
CB2dA*
CB2dAC                   endsl
CB2dA*
CBShA*
CBShAC                   if        cbimrg = *on
CHYoAC                   eval      lstlb# = lblbl#
CHYoAC                   eval      endtyp = '*MERGE  '
CHYoAC                   exsr      setend
CHYoAC                   eval      count = 0
CHYoAC                   eval      kyltyp = 'O'
417xD**         KEYL32    SETLLLABEL32
CBSfD**         KEYL32    SETLLLABEL32C
CBSfAC     keyl32        setll     label32d
CHYoAC                   iter
CHYoAC                   endif
CBShA*
CHYoAC                   endif
500gM*
500gM*    Print label(s) for LABEL record.
500gM*
500gM*      Original code was deleted for clarity.
500gM*      See PFMT.0720 for original code.
500gM*
500gMC                   eval      #from = 'PRTSEL'
500gMC                   exsr      prtlb2
     *
     C                   enddo
     *
     *   Print summary for this set of selection labels.
     *
CHYoA*
CHYoA*   If merge labels have already been printed,
CHYoA*     Then don't print them now.
CHYoA*
CHYoAC                   if        endtyp = '*MERGE'  or
CHYoAC                             endtyp = '*LBFOUND'
CHYoAC                   eval      endtyp = '*NOMRG  '
CHYoAC                   endif
CHYoA*
     C                   exsr      setend
     *
CB2mA*
CB2mA*   Print END label.
CB2mA*
CB2mAC                   if        oplb1 = 'Y'
CB2mAC                             or oplb2 = 'Y'
CB2mAC                   exsr      lblend
CB2mAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CWTENT  Catch weight entry fields
     *
BIRa C     cwtent        begsr
     *
     C                   select
     C                   when      c#qpck = 1
     C                   eval      cwent1 = '_______'
     C                   move      '       '     cwent2
     C                   move      '       '     cwent3
     C                   move      '       '     cwent4
     C                   move      '       '     cwent5
     C                   when      c#qpck = 2
     C                   eval      cwent1 = '_______'
     C                   eval      cwent2 = '_______'
     C                   move      '       '     cwent3
     C                   move      '       '     cwent4
     C                   move      '       '     cwent5
     C                   when      c#qpck = 3
     C                   eval      cwent1 = '_______'
     C                   eval      cwent2 = '_______'
     C                   eval      cwent3 = '_______'
     C                   move      '       '     cwent4
     C                   move      '       '     cwent5
     C                   when      c#qpck = 4
     C                   eval      cwent1 = '_______'
     C                   eval      cwent2 = '_______'
     C                   eval      cwent3 = '_______'
     C                   eval      cwent4 = '_______'
     C                   move      '       '     cwent5
     C                   when      c#qpck >= 5
     C                   eval      cwent1 = '_______'
     C                   eval      cwent2 = '_______'
     C                   eval      cwent3 = '_______'
     C                   eval      cwent4 = '_______'
     C                   eval      cwent5 = '_______'
     *
     C                   other
     *
     C                   move      '       '     cwent1
     C                   move      '       '     cwent2
     C                   move      '       '     cwent3
     C                   move      '       '     cwent4
     C                   move      '       '     cwent5
     C                   endsl
     *
BIRa C                   endsr
     *----------------------------------------------------------------
     *
     *  PRTXDK  Print cross dock labels.
     *
     C     prtxdk        begsr
     *
     *
     *   Loop through selection labels for transaction.
     *
     C                   eval      count = 0
     C                   eval      kyltyp = 'O'
750lAC                   eval      lstlb# = -(1)
     *
640sAC                   select
FSHdAC                   when      client = FischerFoods
KFS AC                             or client = Kellys
GFSfAC                             or client = Getfresh
HKWaAC                             or client = HKW
GLPbAC                             or client = Greenleaf
SVLfAC                             or client = saval
FRFbAC                             or client = FRF
FSHdAC     keyl32        setll     label32d
CTWcAC                   when      client = citywholesale
CTWcAC     keyl32        setll     label32e
SFGdAC                   when      client = SGC
SFGdAC     keyl32        setll     label32g
PFCaAC                   when      client = prestofoods
PFCaAC     keyl32        setll     label32j
640sAC                   other
     C     keyl32        setll     label32c
640sAC                   endsl
     C                   dou       forevr <> forevr
640sAC                   select
FSHdAC                   when      client = FischerFoods
KFS AC                             or client = Kellys
GFSfAC                             or client = Getfresh
HKWaAC                             or client = HKW
GLPbAC                             or client = Greenleaf
SVLfAC                             or client = saval
FRFbAC                             or client = FRF
FSHdAC     keyl32        reade     label32d                               78
CTWcAC                   when      client = citywholesale
CTWcAC     keyl32        reade     label32e                               78
SFGdAC                   when      client = SGC
700aMC     keyl32        reade     label32g                               78
PFCaAC                   when      client = prestofoods
700aMC     keyl32        reade     label32j                               78
640sMC                   other
     C     keyl32        reade     label32c                               78
640sAC                   endsl
     C                   if        *in78
     C                   leave
     C                   endif
     *
     *
     *     Skip label if not cross dock.
     *
     C                   if        lbstyp <> 'X'
     C                   iter
     C                   endif
750lA*
750lA*     There could be more than one PLTSUM rec for the same pallet,
750lA*     but with a different pstrn#, causing LABEL rec to be read
750lA*     twice in the joined logical LABEL32, so make sure the lblbl#
750lA*     is not equal to the lstlb# before printing.
750lA*
750lAC                   if        lblbl# = lstlb#
750lAC                   iter
750lAC                   endif
750lAC                   eval      lstlb# = lblbl#
     *
     *     Skip label if nothing was picked.
     *
     C                   if        lbqpck = 0
     C                   iter
     C                   endif
640 A**
640aAC                   if            client = Cityline
640 AC     keyil         chain     itemfld
640 AC                   if        not %found(itemfld)
640 AC                   eval      ifcat = *blanks
640 AC                   endif
640 AC                   endif
     *
     C                   add       1             count
     *
SFGkAC                   eval      $scmd = '*FIRST'
SFGkAC                   call      'GETPSLT'
SFGkAC                   parm                    $scmd             8
SFGkAC                   parm      lbwhse        $swhse            3 0
SFGkMC                   parm      lbitem        #sitem           15
SFGkAC                   parm                    woslot           12
SFGkAC                   parm                    $saisl            3
SFGkAC                   parm                    $sloc             3 0
SFGkAC                   parm                    $srlvl            2 0
SFGkAC                   parm                    $shand            2
SFGkAC                   parm                    $srtn             8
SFGkAC                   if        $srtn <> '*NONE   '
SFGkAC                   else
SFGkAC                   eval      woslot = *blanks
SFGkAC                   endif
     *
     *   Print warning "Cross dock labels next".
     *
     C                   if        count = 1
     C                   exsr      lblxdb
     C                   endif
SFGk *
SFGk C     keyim         chain     itemmsc                            79
SFGk C                   if        *in79=*on
SFGk C                   eval      imbrnd=*blanks
SFGk C                   endif
     *
     *     See if we should print the "before" um warning.
     *
CBIlAC                   select
CBIlAC                   when      client = cheney
     C                             and lbutyp <> 'N'
     C                             and opuwrb = 'Y'
CBIlAC                             and $pszon = 'CHEM'
     C                   exsr      lblumb

CHYeAC                   when      client = cheney
CHYeAC                             and lbutyp <> 'N'
CHYeAC                             and opuwrb = 'Y'
CHYeAC                             and $pszon = 'FRZ'
     C                   exsr      lblumb

CB1dAC                   when      client = cheney
CB1dAC                             and lbutyp <> 'N'
CB1dAC                             and opuwrb = 'Y'
CB1dAC                             and $pszon = 'FLRPIR'
     C                   exsr      lblumb

CB1dAC                   when      client = cheney
     *
CHYn *  Print "PK NEXT" label for Will call orders except CONTAINER
     *  and BREAKERS truck regardless of zone.  CHEM and FRZ are
     *  excluded here because the logic above will cover that.
     *
CHYn C                             and lbgrp2 = 'W'
CHYn C                             and opuwrb = 'Y'
CHYn C                             and lbutyp <> 'N'
CHYn C                             and pstruk <> @cntnr
CHYn C                             and pstruk <> 'BREAKERS'
CHYn C                             and $pszon <> 'CHEM'
CHYn C                             and $pszon <> 'FRZ'
CB1dAC                             and $pszon <> 'FLRPIR'
CHYn C                   exsr      lblumb

     C                   when      lbutyp <> 'N'  and
     C                             opuwrb = 'Y'
     C                   exsr      lblumb
CBIlAC                   endsl

     C     keyil         chain     piritem                            79
     C                   if        *in79
     C                   eval      itvit# = *blanks
     C                   endif
NCSbA*
NCSbA*    Get vendor name to print on pick label
NCSbA*
NCSaAC                   if        client = nicholas
GFCaAC                             or client = gfc
NCSbAC                   eval      wkvnam = *blanks
GFCaAC                   eval      imbrnd= *blanks
NCSbAC     keyims        chain     itemmsc
NCSbAC                   if        %found(itemmsc)
NCSbAC                   eval      wkvnam = %subst(imvnam:1:25)
NCSbAC                   endif
NCSbAC                   endif
530bA*
530bA*     Get order header record
530bA*
530bAC                   exsr      getORDH
720dA*
720dA*     Get order header misc
720dA*
720dAC                   exsr      getORDHM
720dA*
720dA*     Get order detail record
720dA*
720dAC                   exsr      getORDD
CWDgA*
CWDgA*     Get order detail miscellaneous
CWDgA*
CWDgAC                   exsr      getORDDM
     *
     *     Initialize label fields.
     *
     C                   eval      w1qty2 = lbqpck
640tD ***                exsr      crtstp
CLDvAC     keyil         chain     ssbxref
CLDvAC                   if        not %found(ssbxref)
CLDvAC                   eval      sscombo = 'N'
CLDvAC                   endif
     *
700dA*  Position to first unique piece number for label.
700dA*
700dAC     keyorp        setll     ordp2
     *
     *     Either print a combination label ...
     *
     C                   select
     C                   when      lbqpck >= opclvl
CLDvMC                             or sscombo = 'Y'
     C                   eval      combo = *on
     *
     *        See if we should print the "before" combo warning.
     *
     C                   if        opcwrb = 'Y'
     C                   exsr      lblcmb
     C                   endif
     *
     *        Print one label.
     *
700dA*
700dA*          Get unique piece number for label.
700dA*
700dAC     keyorp        reade     ordp2
700dAC                   if        %eof
700dAC                   eval      unqpiece# = 0
700dAC                   else
700dAC                   eval      unqpiece# = orpup#
700dAC                   endif
700dA*
500dAC                   eval      $gcmd = '*FIRST  '
500dAC                   eval      $gqypl = *zeros
     C                   eval      w1pick = lbqpck
CCPaAC                   if        client = capitolcity
CLDwAC                             or client = cityline
CWDwAC                             or client = cashwa
GFSkAC                             or client = getfresh
FRFaAC                             or client = frf
CCPaAC                   exsr      lblitmn
CCPaAC                   endif
640 MC                   if        client = Cityline
640 AC                             and ifcat  = 'CLAMS'
CLDk C                   exsr      lblitl
CLDk C                   endif
     C                   exsr      lblpck
     *
     *        See if we should print the "after" combo warning.
     *
     C                   if        opcwra = 'Y'
     C                   exsr      lblcma
     C                   endif
     *
     C                   other
     *
     *     Or print individual labels.
     *
500dAC                   eval      $gcmd = '*FIRST  '
500dAC                   eval      $gqypl = *zeros
     C                   eval      combo = *off
CCPaAC                   if        client = capitolcity
CLDwAC                             or client = cityline
CWDwAC                             or client = cashwa
GFSkAC                             or client = getfresh
FRFaAC                             or client = frf
CCPaAC                   exsr      lblitmn
CCPaAC                   endif
     C     1             do        lbqpck        w1pick

700dA*          Get unique piece number for label.
700dA*
700dAC     keyorp        reade     ordp2
700dAC                   if        %eof
700dAC                   eval      unqpiece# = 0
700dAC                   else
700dAC                   eval      unqpiece# = orpup#
700dAC                   endif

640 MC                   if        client = Cityline
640 AC                             and ifcat  = 'CLAMS'
CLDk C                   exsr      lblitl
CLDk C                   endif
     C                   exsr      lblpck
500dAC                   eval      $gqypl = $gqypl - 1
500dAC                   if        $gqypl = 0
500dAC                   eval      $gcmd = '*NEXT   '
500dAC                   else
500dAC                   eval      $gcmd = *blanks
500dAC                   endif
500dA*
     C                   enddo
     *
     C                   endsl
     *
     *     See if we should print the "after" um warning.
     *
CBIlAC                   select
CBIlAC                   when      client = cheney
     C                             and lbutyp <> 'N'
     C                             and opuwra = 'Y'
CHYfAC                             and $pszon = 'CHEM'
     C                   exsr      lbluma

CHYfAC                   when      client = cheney
CHYfAC                             and lbutyp <> 'N'
CHYfAC                             and opuwra = 'Y'
CHYfAC                             and $pszon = 'FRZ'
     C                   exsr      lbluma

     C                   when      lbutyp <> 'N'
     C                             and opuwra = 'Y'
     C                   exsr      lbluma

SFGiAC                   when      opuwra = 'Y'
SFGiAC                             and imp_flg = *on
     C                   exsr      lbluma
     C                   endsl
     *
     *     Print catch weight labels.
     *
     C                   if        itcwgt = 'Y'  and
     C                             opcwgt <> 0
     C     lbqpck        div       opcwgt        lbls
     C                   mvr                     remain
     C                   if        remain <> 0
     C                   add       1             lbls
     C                   endif
BIRa C                   eval      c#qpck = lbqpck
     C     1             do        lbls          @qty1

BIRaAC                   select
BIRaAC                   when      client = birite
BIRaAC                   exsr      cwtent
BIRaAC                   exsr      lblcwt
BIRaAC                   eval      c#qpck = c#qpck - 5

CBIiAC                   when      client = cheney
CBIiAC                             and dsmeat <> 'Y'
CHYcAC                             and dsppck <> 'Y'
     C                   exsr      lblcwt
BIRaAC                   other
     C                   exsr      lblcwt
BIRaAC                   endsl

     C                   enddo
     C                   endif
     *
     C                   enddo
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SETBEG  Start new set of labels.
     *
     C     setbeg        begsr
     *
     *   Print set header label.
     *
     C                   eval      lbtrn# = lsttrn
     C                   exsr      lblshd
     *
BIRdA*   Print spcl inst labels.
     *
BIRdAC                   if        client = birite

BIRdAC     l33key        setll     label33
BIRdAC                   dou       forevr <> forevr
BIRdAC     l33key        reade     label33
BIRdAC                   if        %eof(label33)
BIRdAC                   leave
BIRdAC                   endif

BIRdAC                   if        psszon <> $pszon
BIRdAC                   iter
BIRdAC                   endif
     *
BIRdAC                   eval      wkord = lbord
     *
BIRdAC                   if        svord <> wkord
BIRdAC                   exsr      prtins
BIRdAC                   endif

BIRdAC                   eval      svord = wkord
BIRdAC                   enddo
     *
BIRdAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
BIRdA*  PRTINS  Print instruction labels
     *
BIRdAC     prtins        begsr
     *
     C                   eval      wkcmp# = dscmp#
     C                   eval      wkdivn = dsdivn
     C                   eval      wkdept = dsdept
     C                   move      ohcust        wkcust           11
     C                   movel     wkcust        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
     C                   eval      wkcusn = $cstr
     *
     C                   call      @getspcl
     C                   parm                    wkcmp#
     C                   parm                    wkdivn
     C                   parm                    wkdept
     C                   parm                    wkcusn
     C                   parm                    sp1              35
     C                   parm                    sp2              35
     C                   parm                    sp3              35
     C                   parm                    sp4              35
     C                   parm                    sp5              35
     C                   parm                    sp6              35
     C                   parm                    sp7              35
     C                   parm                    sp8              35
     C                   parm                    sp9              35
     C                   parm                    sp10             35
     C                   parm                    sp11             35
     C                   parm                    sp12             35
     *
     C                   if        sp1 > *blanks
     C                   exsr      lblins
     C                   endif
     *
     C                   if        sp5 > *blanks
     C                   eval      sp1=sp5
     C                   eval      sp2=sp6
     C                   eval      sp3=sp7
     C                   eval      sp4=sp8
     C                   exsr      lblins
     C                   endif
     *
     C                   if        sp9 > *blanks
     C                   eval      sp1=sp9
     C                   eval      sp2=sp10
     C                   eval      sp3=sp11
     C                   eval      sp4=sp12
     C                   exsr      lblins
     C                   endif
     *
BIRd C                   endsr
     *----------------------------------------------------------------
     *
     *  SETEND  End set of labels.
     *
     C     setend        begsr
CLDeAC     cldmrg        cabeq     '*MRGONLY'    begmrg
CHYoA*
CHYoA*   See if we are just want to print the merge labels.
CHYoA*
CHYoAC                   if        endtyp = '*MERGE'
CHYoAC                   goto      begmrg
CHYoAC                   endif
     *
     *   Print cross dock labels.
     *
     C                   exsr      prtxdk
     *
     *   Print discrepancy labels.
     *
     C                   if        operr <> 0
     C     count         div       operr         lbls
     C                   mvr                     remain
     C                   if        remain <> 0
     C                   add       1             lbls
     C                   endif
     C     1             do        lbls
     C                   exsr      lbldis
     C                   enddo
     C                   endif
CHYoA*
CHYoA*   See if we are skipping the merge labels.
CHYoA*
CHYoAC                   if        endtyp = '*NOMRG'
CHYoAC                   goto      skpmrg
CHYoAC                   endif
640mA*
640mA*   Print pallet labels.
640mA*
MJKeAC                   if        client <> mjkellner
640mAC                   exsr      lblpallet
MJKfAC                   endif
     *
CLDeAC     begmrg        tag
CLDeAC     cldmrg        cabeq     '*SKIPMRG'    endmrg
     *
     *
     *   Print merge summary(s) for transaction.
     *
     *     Loop through selection labels for transaction.
     *
CLDg C                   clear                   pal
CLDg C                   clear                   pcs
     C                   eval      first2 = *on
     C                   eval      kyltyp = 'M'
     *
640sAC                   select
FSHdAC                   when      client = FischerFoods
KFS AC                             or client = Kellys
GFSfAC                             or client = Getfresh
HKWaAC                             or client = HKW
GLPbAC                             or client = Greenleaf
SVLfAC                             or client = saval
FSHdAC     keyl32        setll     label32d
CTWcAC                   when      client = citywholesale
CTWcAC     keyl32        setll     label32e
SFGdAC                   when      client = SGC
SFGdAC     keyl32        setll     label32g
PFCaAC                   when      client = prestofoods
PFCaAC     keyl32        setll     label32j
640sMC                   other
     C     keyl32        setll     label32c
640sMC                   endsl
     C                   dou       forevr <> forevr
640sAC                   select
FSHdAC                   when      client = FischerFoods
KFS AC                             or client = Kellys
GFSfAC                             or client = Getfresh
HKWaAC                             or client = HKW
GLPbAC                             or client = Greenleaf
SVLfAC                             or client = saval
FSHdMC     keyl32        reade     label32d                               78
CTWcAC                   when      client = citywholesale
CTWcAC     keyl32        reade     label32e                               78
SFGdAC                   when      client = SGC
SFGdAC     keyl32        reade     label32g
PFCaAC                   when      client = prestofoods
PFCaAC     keyl32        reade     label32j
640sMC                   other
     C     keyl32        reade     label32c                               78
640sMC                   endsl
     C                   if        *in78
     C                   leave
     C                   endif
640dA*
640dA*       For pass 1 only use labels that have a PLTSUM 'O' record.
640dA*       For pass 2 only use labels that have a PLTSUM 'L' record.
640dA*
720fDC**                 if        fdiPass = 1 and PSTYPE <> 'O'
720gMC                   if        fdiPass = 1 and PSTYPE <> tbPalletType
640dAC                             or fdiPass = 2 and PSTYPE <> 'L'
640dAC                   iter
640dAC                   endif
530bA*
530bA*     Get order header record
530bA*
530bAC                   exsr      getORDH
CB3kAC                   exsr      getORDHM
CWDaA*
CWDaA*     Get order detail record
CWDaA*
CWDaAC                   exsr      getORDD
CWDgA*
CWDgA*     Get order detail miscellaneous
CWDgA*
CWDgAC                   exsr      getORDDM
     *
     *       Put together zone from label fields.
     *
     C                   movel     lbwhdp        tmpzon
     C                   move      lbstyp        tmpzon
     *
     *       First time through initialization.
     *
     C                   if        first2 = *on
     C                   exsr      initzp
     C     zpocur        occur     zonpku
     C                   eval      lstzon = tmpzon
     C                   eval      dszstp = lbstop
     C                   exsr      getpal
     C                   eval      dszplt = pal#
650hA
650hA*       For pass 2, use tran of correpsonding label instead of pallet.
650hA
650hAC                   if        fdipass = 2
650hAC                   call      'GETLBLTRN'
650hAC                   parm      lbctr#        $glbl#            7 0
650hAC                   parm                    $gtrn#            7 0
650hAC                   parm                    $grtn             8
650hAC                   if        $grtn <> '*ERROR'
650hAC                   eval      dszplt = $gtrn#
650hAC                   endif
650hAC                   endif
650hA
CLDdAC                   eval      dszpsi = lbhnd2
CBIqAC                   if        client = cheney
CBIpAC                   eval      kyfmt = 'MRGNEXT '
CBIpAC                   exsr      fillb1
CBiPAC                   endif
     C                   exsr      lblzph
     C                   eval      first2 = *off
     C                   endif
     *
     C                   exsr      getpal
     C                   eval      w1pal# = pal#
     *
     *       When zone changes, print summary totals.
     *
     C                   if        tmpzon <> lstzon
530 AC                   if        oplb7 <> '1'
     C                   exsr      lblzpd
530 AC                   endif
     C                   exsr      initzp
     C     zpocur        occur     zonpku
     C                   eval      lstzon = tmpzon
     C                   exsr      lblzph
     C                   endif
CHYwA*
CHYwA*       Print individual zone pickup label.
CHYwA*
CHYwAC                   eval      #from = 'SETEND'
CHYwAC                   exsr      prtlb2
     *
     *       Move information into data structure fields.
     *
     C                   eval      dszitm = lbitem
CBIxAC                   select
CBIxAC                   when      client = cheney
CBIxAC                   eval      zpitem = dszitm
CBIxAC     ixkey         chain     itemdsc                            79
CBIxAC                   if        not *in79
CBIxAC                   movel     ixdsc1        dszdsc
CBIxAC                   movel     ixdsc2        dszds2
CBIxAC                   else
CBIxAC                   eval      dszdsc = itdesc
CBIxAC                   eval      dszds2 = *blanks
CBIxAC                   endif

640gAC                   when      totzon
640gAC                   eval      dszdsc = *blanks
640gAC     zonkey        chain     zoneh
640gAC                   if        %found(zoneh)
640gAC                   eval      dszdsc = zhdesc
640gAC                   endif

     C                   other
     C                   eval      dszdsc = itdesc
CBIxAC                   endsl

     C                   eval      dszpcs = lbqpck
     C                   movel     ohcnam        dszcnm
CBIxAC                   eval      dszpck = itpdsc
     *
CLDg C                   exsr      zzqttl
     *
     *       Move to next data structure occurance.
     *       If we have reached the maximum number of summary detail
     *       lines, then print the label and continue on.
     *
     C                   exsr      getpal
     C                   eval      dszplt = pal#
650hA
650hA*       For pass 2, use tran of correpsonding label instead of pallet.
650hA
650hAC                   if        fdipass = 2
650hAC                   call      'GETLBLTRN'
650hAC                   parm      lbctr#        $glbl#            7 0
650hAC                   parm                    $gtrn#            7 0
650hAC                   parm                    $grtn             8
650hAC                   if        $grtn <> '*ERROR'
650hAC                   eval      dszplt = $gtrn#
650hAC                   endif
650hAC                   endif
650hA
CLDdAC                   eval      dszpsi = lbhnd2
     C                   eval      dszstp = lbstop
     C                   if        zpocur = zpdcnt
CHYwDC                   if        client <> cheney
     C                   exsr      lblzpd
CHYwDC                   endif
     C                   exsr      initzp
     C                   else
     C                   add       1             zpocur
     C                   endif
     C     zpocur        occur     zonpku
     *
     C                   enddo
CB3k *
CB3k *       When zone changes, print summary totals.
CB3k *          One more time after LR read
CB3k *
CB3kAC                   if        tmpzon <> lstzon
CB3kAC                   if        oplb7 <> '1'
CB3kAC                   exsr      lblzpd
CB3kAC                   endif
CB3kAC                   exsr      initzp
CB3kAC     zpocur        occur     zonpku
CB3kAC                   eval      lstzon = tmpzon
CB3kAC                   exsr      lblzph
CB3kAC                   endif
     *
     *     Force printing of label.
     *
     C                   if        zpocur > 1
CHYwDC                   if        client <> cheney
     C                   exsr      lblzpd
CHYwDC                   endif
     C                   exsr      initzp
     C                   endif
     *
SFGmA*   Print PIR merge pick labels.
     *
SFGmAC                   if        client = sgc
SFGmAC                   if        $pgen = 1
SFGnAC                   exsr      lblmhd
SFGmAC                   exsr      lblzpm2
SFGmAC                   endif
SFGmAC                   endif
     *
CLDgAC                   if        client = cityline
CLDg C                   exsr      initzp
CLDg C     1             occur     zonpku
CLDg C                   eval      dszplt = pal(1)
CLDg C                   z-add     pcs(1)        dszpcs
CLDg C                   move      @desc1        dszitm
     *
CLDG C                   if        pcs(2) > 0
CLDg C     2             occur     zonpku
CLDg C                   eval      dszplt = pal(2)
CLDg C                   z-add     pcs(2)        dszpcs
CLDg C                   move      @desc1        dszitm
CLDg C                   endif
     *
CLDg C                   exsr      lblzph
CLDg C                   exsr      lblzpd
CLDlA*
CLDlA*     Print PIR sequence merge labels.
CLDlA*
CLDlAC                   if        $pgen = 1
CLDlAC                   exsr      lblzpm
CLDlAC                   endif
CLDgAC                   endif
     *
CHYoA*
CHYoA*   Skip summary if just printing merge labels.
CHYoA*
CHYoAC                   if        endtyp = '*MERGE'
CHYoAC                   goto      endse
CHYoAC                   endif
CHYoA*
CLDeAC     cldmrg        cabeq     '*MRGONLY'    endse
CLDeAC     endmrg        tag
CHYoA*
CHYoAC     skpmrg        tag
     *
     *   Print set summary for transaction.
     *
ALNdA*   Calculate pick time for this transaction, and zero out totals
     *
CLDgAC                   if        client = cityline
ALNdAC                   exsr      zzclct
ALNdAC                   exsr      zzclra
CLDgAC                   endif
     *
     *     Print header label.
     *
     C                   exsr      lblssh
642bA*
642bA*   Print set summary label.
642bA*
642bAC                   if        client <> gfc
MJKgAC                             and client <> mjkellner
CB2jAC
642bAC                   exsr      lblsetsum
642bAC                   endif
     *
     *  Print pallet label
     *
     C                   if        $pgen = 1
     C                   eval      dtlcnt = 0
     C                   dow       dtlcnt < palcnt
CTWaAC                   select
CSPlAC                   when      client = coastalsunbelt
DRYkAC                             or client = dairyland
700bAC                             or (bigpallabel
700bAC                             and client <> cheney)
CSPlAC                   eval      kyfmt = 'BIGPAL  '
CTWkAC                   when      cigaretflag
CTWkAC                   eval      kyfmt = *blanks
CTWkAC                   eval      palcnt = *zeros
CTWaAC                   when      tobaccoflag
CTWfD ***                eval      kyfmt = 'TPALLET '
CTWfMC                   eval      kyfmt = 'PALLET  '
CTWaAC                   when      candyflag
CTWfD ***                eval      kyfmt = 'TPALLET '
CTWfMC                   eval      kyfmt = 'PALLET  '
CTWaAC                   when      retailflag
CTWaAC                   eval      kyfmt = 'MPALLET '
CTWaAC                   other
     C                   eval      kyfmt = 'PALLET  '
CTWaAC                   endsl
     C                   add       1             dtlcnt
     C     dtlcnt        occur     palsum
     C                   eval      @pal# = dsppal
     C                   eval      @plid = dsppli
     C                   eval      @rtid = dsprti
     C                   eval      @stp1 = dsstp1
     C                   eval      @stp2 = dsstp2
     C                   if        dsppal > 0  or
     C                             $pcmd = '*TEST2  '
      ***                exsr      fillb1
     C                   endif
     C                   enddo
     C                   endif
     *
CLDeAC     endse         tag
     C                   endsr
700iA*----------------------------------------------------------------
700iA*  SETSUMLBL  Print Set Summary Label only
700iA*----------------------------------------------------------------
     *
700iAC     SetSumLbl     begsr
     *
     *   Print set summary for transaction.
     *   Loop through all labels for transaction.
     *
     C                   eval      lsttrn = $ptrn#
     C                   eval      first2 = *on
     C     keyl33        setll     label33
     *
     C                   dou       forevr <> forevr
     C     keyl33        reade     label33
     C                   if        %eof(label33)
     C                   leave
     C                   endif
     *
     *   Ignore Adjustment records, which are created when an OUT
     *   is closed to a non-zero quantity.
     *
     C                   if        lbtype = 'A'
     C                   iter
     C                   endif
     *
     *       First time through initialization.
     *
     C                   if        first2 = *on
     C                   exsr      initss
     C     ssocur        occur     stpsum
     C                   eval      dssstp = lbstop
     C                   eval      ttlcub = 0
     C                   eval      ttlwgt = 0
     C                   eval      ttlpcs = 0
     C                   eval      first2 = *off
     C                   endif
     *
     *       When stop changes, move to next data structure occurance.
     *       If we have reached the maximum number of summary detail
     *       lines, then print the label and continue on.
     *
     C                   if        lbstop <> dssstp
     C                   add       dsscub        ttlcub
     C                   add       dsswgt        ttlwgt
     C                   add       dsspcs        ttlpcs
     C                   if        ssocur = ssdcnt
     C                   exsr      lblssd
     C                   exsr      initss
     C                   else
     C                   add       1             ssocur
     C                   endif
     C     ssocur        occur     stpsum
     C                   eval      dssstp = lbstop
     C                   endif
     *
     *       Update summary amounts for stop.
     *
     C                   add       lbcube        dsscub
     C                   add       lbswgt        dsswgt
     C                   add       lbqpck        dsspcs
     C                   eval      dsscnm = ohcnam
     *
     C                   enddo
     *
     *     Print last stop and totals.
     *
     C                   if        first2 = *off
     *
     *       Detail line.
     *
     C                   add       dsscub        ttlcub
     C                   add       dsswgt        ttlwgt
     C                   add       dsspcs        ttlpcs
     C                   if        ssocur = ssdcnt
     C                   exsr      lblssd
     C                   exsr      initss
     C                   else
     C                   add       1             ssocur
     C                   endif
     C     ssocur        occur     stpsum
     *
     *       Summary totals.
     *
     C                   z-add     ttlcub        dsscub
     C                   z-add     ttlwgt        dsswgt
     C                   z-add     ttlpcs        dsspcs
     C                   movea     ttldsc        dsscnm
     C                   exsr      lblssd
     C                   endif
     *
     *  End of transaction, force print.
     *
     C                   exsr      print
     *
     C                   endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *                       LABEL SUBROUTINES
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  CNTLIFO  Check for LIFO items in transaction
     *
     C     cntlifo       begsr

     C     keyl32        setll     label32c
     *
     C                   dou       forevr <> forevr
     C     keyl32        reade     label32c                               78
     C                   if        not %eof(label32c)
     *
     *     Skip label if nothing was picked.
     *
     C                   if        lbqpck = 0
     C                   iter
     C                   endif
     *
     *     Get order detail miscellaneous
     *
     C                   exsr      getORDDM

     C                   if        rtxdm2_omlifo = 'Y'
     C                   eval      kyfmt = 'LIFO    '
     C                   exsr      fillb1
     C                   leave
     C                   endif

     C                   endif

     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CNTSHD  Count set header detail lines.
     *
     C     cntshd        begsr
     *
     C                   eval      shdcnt = 0
     *
ctwaAC                   select
ctwkAC                   when      cigaretflag
ctwkAC                   eval      kyfmt = *blanks
ctwaAC                   when      tobaccoflag
ctwfD ***                eval      kyfmt = 'TSETHED '
ctwfMC                   eval      kyfmt = 'SETHED  '
ctwaAC                   when      candyflag
ctwfD ***                eval      kyfmt = 'TSETHED '
ctwfMC                   eval      kyfmt = 'SETHED  '
ctwaAC                   when      retailflag
ctwaAC                   eval      kyfmt = 'MSETHED '
ctwaAC                   other
     C                   eval      kyfmt = 'SETHED  '
ctwaAC                   endsl
     C                   eval      kyfmt = 'SETHED  '
     C     keylfd        setll     lblfmtd
     C                   dow       forevr = forevr
     C     keylfd        reade     lblfmtd                                79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     C                   if        lfdstr = *blanks
     C                   iter
     C                   endif
     *
     C                   movea     lfdstr        sti
     *
     C                   eval      vflag = *off
     C                   eval      @var = 0
     C                   eval      @len = 0
     *
     *   Loop through each character of label.
     *
     C     1             do        maxsti        x
     *
     C                   select
     *
     *       Beginning of variable
     *
     C                   when      sti(x) = '<'
     C                   if        vflag = *on  and
     C                             @var = 27
     C                   add       1             shdcnt
     C                   endif
     C                   eval      vflag = *on
     C                   eval      @var = 0
     C                   eval      @len = 1
     *
     *       End of variable
     *
     C                   when      sti(x) = '>'  and
     C                             vflag = *on  and
     C                             @var = 27
     C                   add       1             shdcnt
     C                   eval      vflag = *off
     *
     *       Within variable
     *
     C                   when      vflag = *on
     C                   add       1             @len
     *
     *         Extract variable id number.
     *
     C                   select
     C                   when      @len = 2  and
     C                             sti(x) >= '0'  and
     C                             sti(x) <= '9'
     C                   eval      temp1a = sti(x)
     C                   move      temp1a        temp1n
     C                   eval      @var = temp1n
     C                   when      @len = 3  and
     C                             sti(x) >= '0'  and
     C                             sti(x) <= '9'
     C                   eval      temp1a = sti(x)
     C                   move      temp1a        temp1n
     C                   mult      10            @var
     C                   add       temp1n        @var
     C                   when      @len = 4  and
     C                             sti(x) >= '0'  and
     C                             sti(x) <= '9'
     C                   eval      temp1a = sti(x)
     C                   move      temp1a        temp1n
     C                   mult      10            @var
     C                   add       temp1n        @var
     C                   endsl
     *
     C                   endsl
     *
     C                   enddo
     *
     *   Output variable if neccessary.
     *
     C                   if        vflag = *on  and
     C                             @var = 27
     C                   add       1             shdcnt
     C                   endif
     *
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CNTSSD  Count set summary detail lines.
     *
     C     cntssd        begsr
     *
     C                   eval      ssdcnt = 0
     *
svlhAC                   select
svlhAC                   when      client = Saval
svlhAC                             and yohtype =  'W'
svlhAC                   eval      kyfmt = 'SETSUMW '
svlhAC                   when      client = Saval
svlhAC                             and yohtype <> 'W'
avlhAC                   eval      kyfmt = 'SETSUM  '
ctwkAC                   when      cigaretflag
ctwkAC                   eval      kyfmt = *blanks
ctwaAC                   when      tobaccoflag
ctwfD ***                eval      kyfmt = 'TSETSUM '
ctwfMC                   eval      kyfmt = 'SETSUM  '
ctwaAC                   when      candyflag
ctwfD ***                eval      kyfmt = 'TSETSUM '
ctwfMC                   eval      kyfmt = 'SETSUM  '
ctwaAC                   when      retailflag
ctwaAC                   eval      kyfmt = 'MSETSUM '
ctwaAC                   other
     C                   eval      kyfmt = 'SETSUM  '
ctwaAC                   endsl
     C     keylfd        setll     lblfmtd
     C                   dow       forevr = forevr
     C     keylfd        reade     lblfmtd                                79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     C                   if        lfdstr = *blanks
     C                   iter
     C                   endif
     *
     C                   movea     lfdstr        sti
     *
     C                   eval      vflag = *off
     C                   eval      @var = 0
     C                   eval      @len = 0
     *
     *   Loop through each character of label.
     *
     C     1             do        maxsti        x
     *
     C                   select
     *
     *       Beginning of variable
     *
     C                   when      sti(x) = '<'
     C                   if        vflag = *on  and
     C                             @var = 46
     C                   add       1             ssdcnt
     C                   endif
     C                   eval      vflag = *on
     C                   eval      @var = 0
     C                   eval      @len = 1
     *
     *       End of variable
     *
     C                   when      sti(x) = '>'  and
     C                             vflag = *on  and
     C                             @var = 46
     C                   add       1             ssdcnt
     C                   eval      vflag = *off
     *
     *       Within variable
     *
     C                   when      vflag = *on
     C                   add       1             @len
     *
     *         Extract variable id number.
     *
     C                   select
     C                   when      @len = 2  and
     C                             sti(x) >= '0'  and
     C                             sti(x) <= '9'
     C                   eval      temp1a = sti(x)
     C                   move      temp1a        temp1n
     C                   eval      @var = temp1n
     C                   when      @len = 3  and
     C                             sti(x) >= '0'  and
     C                             sti(x) <= '9'
     C                   eval      temp1a = sti(x)
     C                   move      temp1a        temp1n
     C                   mult      10            @var
     C                   add       temp1n        @var
     C                   when      @len = 4  and
     C                             sti(x) >= '0'  and
     C                             sti(x) <= '9'
     C                   eval      temp1a = sti(x)
     C                   move      temp1a        temp1n
     C                   mult      10            @var
     C                   add       temp1n        @var
     C                   endsl
     *
     C                   endsl
     *
     C                   enddo
     *
     *   Output variable if neccessary.
     *
     C                   if        vflag = *on  and
     C                             @var = 46
     C                   add       1             ssdcnt
     C                   endif
     *
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CNTZPD  Count set zone pickup detail lines.
     *
     C     cntzpd        begsr
     *
     C                   eval      zpdcnt = 0
530 AC                   if        oplb7 = '1'
CWDsAC                   eval      zpdcnt = 1
CWDsAC                   leavesr
530 AC                   endif
     *
     C                   eval      kyfmt = 'ZONPKUP '
     C     keylfd        setll     lblfmtd
     C                   dow       forevr = forevr
     C     keylfd        reade     lblfmtd                                79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     C                   if        lfdstr = *blanks
     C                   iter
     C                   endif
     *
     C                   movea     lfdstr        sti
     *
     C                   eval      vflag = *off
     C                   eval      @var = 0
     C                   eval      @len = 0
     *
     *   Loop through each character of label.
     *
     C     1             do        maxsti        x
     *
     C                   select
     *
     *       Beginning of variable
     *
     C                   when      sti(x) = '<'
     C                   if        vflag = *on  and
     C                             @var = 36
     C                   add       1             zpdcnt
     C                   endif
     C                   eval      vflag = *on
     C                   eval      @var = 0
     C                   eval      @len = 1
     *
     *       End of variable
     *
     C                   when      sti(x) = '>'  and
     C                             vflag = *on  and
     C                             @var = 36
     C                   add       1             zpdcnt
     C                   eval      vflag = *off
     *
     *       Within variable
     *
     C                   when      vflag = *on
     C                   add       1             @len
     *
     *         Extract variable id number.
     *
     C                   select
     C                   when      @len = 2  and
     C                             sti(x) >= '0'  and
     C                             sti(x) <= '9'
     C                   eval      temp1a = sti(x)
     C                   move      temp1a        temp1n
     C                   eval      @var = temp1n
     C                   when      @len = 3  and
     C                             sti(x) >= '0'  and
     C                             sti(x) <= '9'
     C                   eval      temp1a = sti(x)
     C                   move      temp1a        temp1n
     C                   mult      10            @var
     C                   add       temp1n        @var
     C                   when      @len = 4  and
     C                             sti(x) >= '0'  and
     C                             sti(x) <= '9'
     C                   eval      temp1a = sti(x)
     C                   move      temp1a        temp1n
     C                   mult      10            @var
     C                   add       temp1n        @var
     C                   endsl
     *
     C                   endsl
     *
     C                   enddo
     *
     *   Output variable if neccessary.
     *
     C                   if        vflag = *on  and
     C                             @var = 36
     C                   add       1             zpdcnt
     C                   endif
     *
     C                   enddo
     *
     C                   endsr
GFCeA*----------------------------------------------------------------
GFCeA*
GFCeA*  CNTZHD  Count zone detail records.
GFCeA*
GFCeAC     cntzhd        begsr
730fDC**                 eval      kytype = 'O'
720gMC                   eval      kytype = tbPalletType
     C                   eval      zpdcount = *zeros
     C     keyps3        setll     pltsum3
     C                   dou       forevr <> forevr
     C     keyps3        reade     pltsum3                                79
     C                   if        %eof(pltsum3)
     C                             or zpdcount > *zeros
     C                   leave
     C                   endif
     *
     *     Skip pallet if nothing was picked.
     *
     C                   if        pspcs = 0
     C                   iter
     C                   endif
     *
     *     Skip pallet if tran# = 0 and pallet contains bulk pick.
     *     In that case we assume that the pallet only contains a
     *     bulk pick and was not assigned a tran# in OR630.
     *
     C                   if        pstrn# = 0  and
     C                             psbcnt <> 0
720gAC                             and not tbEnhanced
     C                   iter
     C                   endif
     *
     C                   eval      zpdcount += 1
     *
     C                   enddo
GFCeAC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  FILCHR  Fill character variable.
     *
     C     filchr        begsr
750hA*
750hA*   Get size of string without trailing spaces
750hA*
750hAC                   movea     a50           temp50a          50
750hAC                   eval      strLen = %len(%trimr(temp50a))

750jA /free
750jA    if fillb1Pass = 2;
750jA      if varFlag(@var+1) = 0;
750jA        if %subst(kyfmt: 1: 4) = 'PICK' and strLen > 0;
750jA          outStrZdta += '^FN' + %char(@var)
750jA                     + '^FD' + %trimr(temp50a) +'^FS';
750jA        endif;
750jA        varFlag(@var+1) = 1;
750jA      endif;
750jA    endif;
750jA /end-free
     *
     *   Move character string into output string.
750hA*   Remove trailing spaces
     *
750hAC                   if        @len < strLen
414aAC                   eval      lc = @len
750hAC                   else
750hAC                   eval      lc = strLen
750hAC                   endif
     C     1             do        lc            y
     C                   add       1             op
     C                   eval      sto(op) = a50(y)
     C                   if        op = maxsto
     C                   exsr      print
     C                   endif
     C                   enddo
     *
510bA*   Move value into ZBRLOGF log field
510bAC*
510bAC                   if        logzebra
510bAC                   movea     a50           temp50a          50
510bAC                   eval      zffval = %trim(temp50a)
510bAC                   endif
510bAC*
510bAC*   Add field to ZBRLOGS log field.
510bAC*
510bAC                   if        logzebra
510bAC                   eval      zsparm = %trim(zsparm)
510bAC**                                  + ' &'
510bAC                                    + ' <'
510bAC                                    + %trim(%editc(@var:'Z'))
510bAC                                    + ':'
510bAC                                    + %trim(zffnam)
510bAC                                    + '>'
510bAC**                                  + '='
510bAC                                    + %trim(zffval)
510bAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILLB1  Process script for single label format.
     *
750fA*  Revised to make 2 passes;
750fA*    Pass 1 will be for the set that was sent in.
750fA*    Pass 2 will be for the BLT set.
750fA*    See LABELOUT notes for more details
     *
     C     fillb1        begsr
     *
750fA /free
750fA    saveSendToPrt = sendToPrinter;
750fA    savedtlcnt = dtlcnt;
750fA
750fA    if kyfmt <> lastkyfmt;
750fA      fmtCount = 1;
750fA    else;
750fA      fmtCount += 1;
750fA    endif;
750fA    lastkyfmt = kyfmt;
750fA
750fA    for fillb1Pass = 1 to 2;
750fA
750fA      // Skip pass 2 (BLT) if $pCmd <> *PRINT and not printing test label
750fA
750fA      if fillb1Pass = 2
750fA        and $pCmd <> '*PRINT'
750fA        and $pCmd <> '*BLTTEST'
750fA        and %subst($pCmd:1:5) <> '*TEST';
750fA          iter;
750fA      endif;
750fA
750fA      // Define label set to work with for pass
750fA
750fA      if fillb1Pass = 1;
750fA        kyset = $plset;
750fA      else;
750fA        kyset = 'BLT' + %subst($plset: 4: 3);
750jA        kysetzdta = 'BLD' + %subst($plset: 4: 3);
750fA        sendToPrinter = *off;
750fA        dtlcnt = savedtlcnt;
750jA        clear varFlag;
750fA      endif;
750fA
750fA      // Initialize string being written to LABELOUT
750fA
750fA      outStr = '';
750jA      outStrZdta = '^XA^XF' + %trim(kyfmt) + '.ZPL^FS';
750fa
750fA /end-free
750fA
750fAC*    On to normal processing building/printing label
750fA
     C                   eval      sto = *blanks
     C                   eval      op = 0
     *
510bAC                   eval      GoodHit = '0'
510bAC*
510bA*   Initialize zebra logging fields.
510bAC*
510bAC                   eval      zfwhse = $pwhse
510bAC                   eval      zfrte  = $prte
510bAC                   eval      zfrtid = $prtid
750fAC                   if        fillb1pass = 1
510bAC                   eval      zfseq# = zfseq# + 1
750fAC                   endif
510bAC                   eval      zfline = 0
750fDC**                 eval      zflset = $plset
750fMC                   eval      zflset = kyset
510bAC                   eval      zflfmt = kyfmt
510bAC                   eval      zftrn# = lbtrn#
510bAC                   eval      zflbl# = lblbl#
510bAC                   eval      zfcomp = $pcomp
510bAC                   eval      zftzon = $ptzon
510bAC                   eval      zfgen  = $pgen
510bAC                   eval      zfszon = $pszon
510bAC                   eval      zftruk = $ptruk
510bAC                   eval      zffnum = 0
510bAC                   eval      zffnam = ' '
510bAC                   eval      zffval = ' '
510bAC                   time                    zfts
510bAC*
510bAC                   eval      zswhse = $pwhse
510bAC                   eval      zsrte  = $prte
510bAC                   eval      zsrtid = $prtid
750fAC                   if        fillb1pass = 1
510bAC                   eval      zsseq# = zsseq# + 1
750fAC                   endif
510bAC                   eval      zsline = 0
750fDC**                 eval      zslset = $plset
750fMC                   eval      zflset = kyset
510bAC                   eval      zslfmt = kyfmt
510bAC                   eval      zstrn# = lbtrn#
510bAC                   eval      zslbl# = lblbl#
510bAC                   eval      zscomp = $pcomp
510bAC                   eval      zstzon = $ptzon
510bAC                   eval      zsgen  = $pgen
510bAC                   eval      zsszon = $pszon
510bAC                   eval      zstruk = $ptruk
510bAC                   eval      zsparm = ' '
510bAC                   eval      zsts   = zfts
     *
750fDC**   keylfd        setll     lblfmtd
750fMC     keylfd2       setll     lblfmtd
     C                   dow       forevr = forevr
750fDC**   keylfd        reade     lblfmtd                                79
750fMC     keylfd2       reade     lblfmtd                                79
     C                   if        *in79
     C                   leave
     C                   endif
     *
510bAC                   eval      GoodHit = '1'
     *
     C                   if        lfdstr = *blanks
     C                   iter
     C                   endif
     *
     C                   movea     lfdstr        sti
     C                   eval      ip = 0
     *
     C                   eval      vflag = *off
     C                   eval      @var = 0
     C                   eval      @len = 0
     *
     *   Loop through each character of label.
     *
     C     1             do        maxsti        ip
     *
     C                   select
     *
     *       Beginning of variable
     *
     C                   when      sti(ip) = '<'  and
     C                             $pcmd <> '*TEST1  '
     C                   if        vflag = *on
     C                   exsr      fillb2
     C                   endif
     C                   eval      vflag = *on
     C                   eval      @var = 0
     C                   eval      @len = 1
     *
     *       End of variable
     *
     C                   when      sti(ip) = '>'  and
     C                             vflag = *on
     C                   add       1             @len
     C                   exsr      fillb2
     C                   eval      vflag = *off
     *
     *       Within variable
     *
     C                   when      vflag = *on
     C                   add       1             @len
     *
     *         Extract variable id number.
     *
     C                   select
     C                   when      @len = 2  and
     C                             sti(ip) >= '0'  and
     C                             sti(ip) <= '9'
     C                   eval      temp1a = sti(ip)
     C                   move      temp1a        temp1n
     C                   eval      @var = temp1n
     C                   when      @len = 3  and
     C                             sti(ip) >= '0'  and
     C                             sti(ip) <= '9'
     C                   eval      temp1a = sti(ip)
     C                   move      temp1a        temp1n
     C                   mult      10            @var
     C                   add       temp1n        @var
     C                   when      @len = 4  and
     C                             sti(ip) >= '0'  and
     C                             sti(ip) <= '9'
     C                   eval      temp1a = sti(ip)
     C                   move      temp1a        temp1n
     C                   mult      10            @var
     C                   add       temp1n        @var
     C                   endsl
     *
     *       Not within variable - Move character to output string
     *
     C                   other
     C                   add       1             op
     C                   eval      sto(op) = sti(ip)
     C                   if        op = maxsto
     C                   exsr      print
     C                   endif
     *
     C                   endsl
     *
     C                   enddo
     *
     *   Output variable if neccessary.
     *
     C                   if        vflag = *on
     C                   exsr      fillb2
     C                   endif
     *
     *   Force each record to print for 'TEXT' files. Otherwise
     *   the record won't print until it is filled. This is done
     *   to cut down on unnecessary blanks being sent to the printer.
     *
414aD**         LFHSLG    IFEQ 'TEXT'
     C                   exsr      print
414aD**                   ENDIF
     *
     C                   enddo
     *
510bA*   Write ZBRLOGS record.
750fA*     We only need to write to log on pass 1
750fA*     as pass 2 writes to LABELOUT.
510bAC*
510bAC                   if        logzebra and GoodHit = '1'
750fAC                             and fillb1Pass = 1
510bAC***                eval      zsparm = %trim(zsparm)
510bAC                   write(e)  zsrec
510bAC                   endif
750fA /free
750fA
750fA      // See if we should write label to LABELOUT
750fA
750fA      if GoodHit = '1' and fillb1Pass = 2;
750fA        WriteLABELOUT();
750fA      endif;
750fA
750fA    endfor;
750fA
750fA    sendToPrinter = saveSendToPrt;
750fA
750fA /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILLB2  Added variable to ouput string.
     *
     C     Fillb2        begsr
     *
510bAC*
510bA*   Initialize zebra logging fields.
510bAC*
510bAC                   eval      zffnum = @var
510bAC                   eval      zffnam = ' '
510bAC                   eval      zffval = ' '
     *
     C                   if        $pcmd = '*TEST2  '
     C                   eval      kyvnum = @var
     C     keylfv        chain     lblfmtv                            78
     C     *in78         cabeq     *on           endfi2
     C                   endif
     *
     C                   select
     C                   when      @var = 0
510bAC                   eval      zffnam = 'STOP'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
     C                   move      $cstr         $nanum
     C                   else
     C                   move      lbstop        $nanum
     C                   endif
     C                   eval      $nadec = 0
     C                   exsr      filnum
     *
     C                   when      @var = 1
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
530 AC                   select
530 AC                   when      kyfmt = 'PICK    '
530 AC                             or kyfmt = 'BULK    '
CLDtAC                             or kyfmt = 'PICK3   '
530 AC                   eval      zffnam = 'LEVEL'
530 AC                   eval      work2a = %char(lbrlvl)
530 AC                   movea(p)  work2a        a50
530 AC                   other
510bAC                   eval      zffnam = 'CSTATE'
     C                   movea(p)  ohcst         a50
530 AC                   endsl
     C                   exsr      filchr
     C                   endif
     *
     C                   when      @var = 2
510bAC                   eval      zffnam = 'WHSE'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
     C                   move      $pwhse        $nanum
     C                   endif
     C                   eval      $nadec = 0
     C                   exsr      filnum
     *
     C                   when      @var = 3
510bAC                   eval      zffnam = 'COMP'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea     'ZYXWVUT'     a50
     C                   movea(p)  $pcomp        a50
     C                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 4
510bAC                   eval      zffnam = '??'
     *
     C                   when      @var = 5
510bAC                   eval      zffnam = '??'
BIRf * Warehouse quantity
     *
     C                   when      @var = 6
510bAC                   eval      zffnam = '??'
510bAC                   eval      zffnam = 'WhsQty'
BIRf C                   if        $pcmd = '*TEST2  '
BIRf C                   movel     lfvdta        $cstr
BIRf C                   call      'ADJUST'
BIRf C                   parm      '*RIGHT  '    $ccmd
BIRf C                   parm                    $cstr
BIRf C                   move      $cstr         $nanum
BIRf C                   else
BIRf C                   move      iqstk1        $nanum
BIRf C                   endif
BIRf C                   eval      $nadec = 0
BIRf C                   exsr      filnum
     *
     C                   when      @var = 7
510bAC                   eval      zffnam = '??'
     *
     C                   when      @var = 8
640cAC                   select
640cAC                   when      client = citywho
640cAC                             or client = silberman
cwdgAC                             or client = cashwa
640cAC                   eval      zffnam = 'PCKQTY'
640cAC                   movea(p)  toteq1        a50
640cAC                   exsr      filchr
640cAC                   other
510bAC                   eval      zffnam = '??'
640cAC                   endsl
     *
     C                   when      @var = 9
640cAC                   select
640cAC                   when      client = citywho
640cAC                             or client = silberman
cwdgAC                             or client = cashwa
640cAC                   eval      zffnam = 'TOTQTY'
640cAC                   movea(p)  toteq2        a50
640cAC                   exsr      filchr
640cAC                   other
510bAC                   eval      zffnam = '??'
640cAC                   endsl
     *
     C                   when      @var = 10
510bAC                   eval      zffnam = 'TRAN#'
CTWyAC                   eval      wktrn# = *blanks
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
CTWyAC                   select
CTWyAC                   when      client = citywho
CTWyAC                   eval      wktrn# = %char(lbtrn#)
CTWyAC                   move      lbtrn#        $nanum
CTWyAC     ' '           checkr    wktrn#        ln
CTWyAC                   if        ln > *zeros
CTWyaC                   eval      @len = ln
CTWyAC                   endif
CTWyAC                   other
     C                   move      lbtrn#        $nanum
     * 2019146 - on OUT flag type label, print original trn#
CB3pAC                   if        $pcmd = '*SHORTM '
CB3pAC                             and t#spcl = 'MERGE          '
CB3pAC                             and client = cheney
CB3pAC                   move      $ptrn#        $nanum
CB3pAC                   endif

CTWyAC                   endsl
     C                   endif
     C                   eval      $nadec = 0
     C                   exsr      filnum
     *
     C                   when      @var = 11
510bAC                   eval      zffnam = 'SLOT'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
CBIbAC                   movel     lfvdta        dsdisp
CBIkAC                   if        lbwhdp <> 'PRD'
CBIbAC     xup:xlo       xlate     ds1           ds1
CBIkAC                   endif
CBIbAC                   movea     dsdisp        a50
     C                   else

SVLiAC                   select
SVLiAC                   when      client = saval
SVLiAC                   movea(p)  lbdisp        a50
SVLiAC     slotky        chain     slot2
SVLiAC                   if        %found(slot2)
SVLiAC                   if        slrsrv='V'
SVLiAC     slotky        chain     vslot1
SVLiAC                   if        %found(vslot1)
SVLiAC                   eval      tmpslot = vspdis
SVLiAC                   movea(p)  tmpslot       a50
SVLiAC                   endif
SVLiAC                   endif
SVLiAC                   endif

SFGpAC                   when      client = SGC
SFGpAC                   movea(p)  didisp        a50
GLPfAC*
GLPfAC*  print physical slot for Repack pick labels for Green Leaf
GLPfAC*
GLPfAC                   when      client = greenleaf
GLPfAC                               and ittype = 'R'
GLPfAC                   movea(p)  lbdisp        a50
GLPfAC     slotky        chain     slot2
GLPfAC                   if        %found(slot2)
GLPfAC                   if        slrsrv='V'
GLPfAC     slotky        chain     vslot1
GLPfAC                   if        %found(vslot1)
GLPfAC                   eval      tmpslot = vspdis
GLPfAC                   movea(p)  tmpslot       a50
GLPfAC                   endif
GLPfAC                   endif
GLPfAC                   endif
GLPfAC*

CTWaAC                   when      client = citywho
CTWaAC                   eval      temp3a = %subst(lbdisp:1:3)
CTWaAC                   eval      temp8 = %subst(lbdisp:4:8)
CTWaAC                   eval      temp12a = temp3a + '-' + temp8
CTWaAC                   movea(p)  temp12a       a50

GFCbMC                   when      client = gfc
GFCbAC     '-'           scan      lbdisp        charpos
GFCbAC                   if        charpos > *zeros
GFCbMC                   movea(p)  lbdisp        a50
GFCbAC                   else
GFCbMC                   eval      wkdisp = %subst(lbdisp:1:2)
GFCbMC                                      + '-'
GFCbMC                                      + %subst(lbdisp:3:2)
GFCbMC                                      + '-'
GFCbMC                                      + %subst(lbdisp:5:2)
GFCbMC                   movea(p)  wkdisp        a50
GFCbAC                   endif

DRYdAC                   when      cliloc = DryHanover
DRYdAC                             and %subst(lbdisp:4:1) = '-'
DRYdAC                             and %subst(lbdisp:8:1) = '-'
DRYdAC                   movea(p)  lbdisp        a50
DRYdAC                   when      cliloc = DryHanover
DRYdAC                             and %subst(lbdisp:4:1) <> '-'
DRYdAC                             and %subst(lbdisp:8:1) <> '-'
DRYdAC                   eval      wkdisp2 = %subst(lbaisl:1:2) +
DRYdAC                                       '-' +
DRYdAC                                       %editc(lbloc:'X') +
DRYdAC                                       '-' +
DRYdAC                                       %editc(lbrlvl:'1') +
DRYdAC                                       lbhand
DRYdAC                   movea(p)  wkdisp2       a50
FRFcA*
FRFcAC                   when      client = FRF
FRFcAC                   eval      wkdisp = %subst(lbdisp:1:2)
FRFcAC                             + '-'
FRFgMC                             + %subst(lbdisp:3:4)
FRFcAC                   movea (p) wkdisp        a50

CPCdAC                   when      client = cpc
CPCdAC                   eval      wkdisp2 = %subst(lbdisp:1:2) +
CPCdAC                                      '-' +
CPCdAC                                      %subst(lbdisp:3:10)
CPCdAC                   movea(p)  wkdisp2       a50

CBSyAC                   when      client = cheney
CBSyAC                             and cliloc = cbiriv
CBSyAC                             and dsospc = 'R'
CBSyAC                   eval      dsdisp = *blanks
CBSyAC                   movel     retrn         dsdisp

CBIcAC                   when      client = cheney
CBIcAC                             and dsaloc = *blanks
CBIcAC                             and dsmeat <> 'Y'
CHYcAC                             and dsppck <> 'Y'
CBIbAC                   eval      dsdisp = lbdisp

CBIdAC                   when      client = cheney
CBIdAC                             and dsmeat = 'Y'
CBIdAC                   movel     insp          dsdisp

CB3lAC                   when      client = cheney
CB3lAC                             and dsppck = 'Y'
CB3lD *                  movel     prepck        dsdisp
CB3lAC                   eval      dsdisp = lbdisp

CBIcAC                   when      client = cheney
CBIcAC                   movel     dsaloc        dsdisp

SFGpAC                   other
     C                   movea(p)  lbdisp        a50
SFGpAC                   endsl

CB2gMC                   if        client = cheney

CB2gMC                   if        itactv  = '99'
CBIwAC                             and dsmeat <> 'Y'
CBStMC                             and dsppck <> 'Y'
CB3lD ***                          and lbwhdp <> 'DRY  '
CB3kA* Added for MLK to RIV
CB3kAC                             and lbwhdp <> 'XDC  '
CB3kAC                             and lbwhdp <> 'XDD  '
CB3kAC                             and lbwhdp <> 'XDF  '
CB3kAC                             and lbwhdp <> 'XDP  '
CB3kA * I added this then somehow it was removed but I need to
CB3kA * add it back in can't remember why it was removed.
CB3kA * PICK labels for CLR & XDK was changing the disp to cS-255-1
CB3kA* Added for OCA to RIV
CB3kAC                             and lbaisl <> 'XDK'
CB2lAC                             and cliloc <> cbipntgr
CB3cAC                             and cliloc <> cheneyocala
CB3tAC                             and cliloc <> cbist
CBImAC                   exsr      zz999
CBImAC                   endif

CBIkAC                   if        lbwhdp <> 'PRD'
CBIbAC     xup:xlo       xlate     ds1           ds1
CBIkAC                   endif

CBIbAC                   movea     dsdisp        a50
CB3aMC                   endif

svli C                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 12
510bAC                   eval      zffnam = 'TOTQTY'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
520hAC                   select
520hAC                   when      opptyp = 'B'
520hAC                   move      @qty2         $nanum
520hAC                   when      client = Mattfd
520hAC                   move      one           $nanum
520hAC                   other
     C                   move      @qty2         $nanum
520hAC                   endsl
     C                   endif
     C                   eval      $nadec = 0
     C                   exsr      filnum
     *
     C                   when      @var = 13
510bAC                   eval      zffnam = 'UM'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
GFCaAC                   select
GFCaAC                   when      client = gfc
GFCaAC                   movea(p)  lbucod        a50
GFCaAC                   other
     C                   movea(p)  umshrt        a50
GFCaAC                   endsl
     C                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 14
510bAC                   eval      zffnam = 'TIHI'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   exsr      filchr
     C                   else
     C                   move      lbtie         $nanum
     C                   eval      $nadec = 0
     C                   exsr      filnum
     C                   add       1             op
     C                   eval      sto(op) = '/'
     C                   if        op = maxsto
     C                   exsr      print
     C                   endif
     C                   move      lbhigh        $nanum
     C                   eval      $nadec = 0
     C                   exsr      filnum
     C                   endif
     *
     C                   when      @var = 15
510bAC                   eval      zffnam = 'PACK'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
640sAC                   select
SFGf C                   when      client = sgc
SFGf C                   if        lbutyp = 'N'
SFGf c                   movea(p)  itpdsc        a50
SFGf c                   endif
SFGf c                   if        lbutyp = '1'
SFgf C                   movea(p)  dspds1        a50
SFGf c                   endif
SFGf C                   if        lbutyp = '2'
SFGf C                   movea(p)  dspds2        a50
SFGf C                   endif
JORcA*
JORcAC                   when      client = Jordanos
ELBtAC                             or client = Ellenbee
HMWfAC                             or client = hmwagner
JORcA*
JORcA*      Normal item, picked Eaches. Convert item pack to 1.
JORcAC                   if        ittype = ' '
JORcAC                             and lbutyp <> 'N'
ELBtA*
ELBtAC                   if            client = Ellenbee
ELBtAC                             and itcwgt = 'Y'
ELBtAC                   eval      itpdsc = '1/Variable'
ELBtAC                   else
ELBtA*
JORcAC                   eval      charpos = 0
JORcAC     '/'           scan      itpdsc        charpos
JORcAC                   if        charpos > 0
JORcAC                   eval      strnglen= 16 - charpos
JOrcAC                   eval      itpdsc = '1'
JORcAC                               + %subst(itpdsc:charpos:strnglen)
ELBtAC                   endif
ELBtA*
JORcAC                   endif
JORcAC                   endif
JORcA*
JORcAc                   movea(p)  itpdsc        a50
JORcA*
GFCaAC                   when      client = gfc
GFChA*
GFChA*      Normal item, picked Eaches. Convert item pack to 1.
GFChAC                   if        ittype = ' '
GFChAC                             and lbutyp <> 'N'
GFChAC                   eval      charpos = 0
GFChAC     '/'           scan      itpdsc        charpos
GFChAC                   if        charpos > 0
GFChAC                   eval      strnglen= 16 - charpos
GFChAC                   eval      itpdsc = '1'
GFChAC                               + %subst(itpdsc:charpos:strnglen)
GFChAC                   endif
GFChAC                   endif
GFCaA *
GFCaA *   Center report title.
GFCaA *
GFCaAC                   eval      $pstr = itpdsc
GFCaAC                   call      'CENTER'
GFCaAC                   parm                    $pstr
GFCaAC                   parm      15            $plen
GFCaAC                   movel     $pstr         itpdsc
GFCaA*
GFCaAc                   movea(p)  itpdsc        a50
BIReA*
BIReAC                   when      client = birite

BIReA*      Splitable item, change pack to 1.
BIReAC                   if           lbutyp = '1'
BIReAC                             or lbutyp = '2'
BIReAC                             or ittype = 'B'
BIReAC                             or ittype = 'S'
BIReAC
BIReA*      Find '/' separating pack and size.
BIReAC     '/'           scan      itpdsc:1      p1
BIReAC                   if        p1 >= 2
BIReAC
BIReA*      Advance pointer to start of Item Size.
BIReAC                   eval      p1 = p1 + 1
BIReA*      Compute length of Item Size to extract.
BIReAC                   eval      p2 = 16 - p1
BIReAC                   eval      itpdsc = '1/' +
BIReAC                                      %trim(%subst(itpdsc:p1:p2))
BIReAC                   endif
BIReAC                   endif

     C                   movea(p)  itpdsc        a50
640sMC                   other
JORcA*
     c                   movea(p)  itpdsc        a50
640sAC                   endsl
JORcA*
     C                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 16
510bAC                   eval      zffnam = 'DESC'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
ISYaA*
ISYaAC                   select
ISYaAC                   when      client = isupply
ISYaA*
ISYaAC                   if        ompdsc = 'Y'  and
ISYaAC                             omodsc > ' '
ISYaAC                   movea(p)  omodsc        a50
ISYaAC                   else
ISYaAC                   movea     *blanks       a50
ISYaAC                   endif

CBIaAC                   when      client = cheney
CB3mAC                   eval      t#dsc1 = *blanks
CB3mAC     keyix         chain     itemdsc
CB3mAC                   if        %found(itemdsc)
CB3mAC                   eval      t#dsc1 = ixdsc1
CB3mAC                   eval      t#dsc2 = ixdsc2
CB3mAC                   endif
CBIaMC                   movea(p)  t#dsc1        a50

ISYaAC                   other
     C                   movea(p)  itdesc        a50
ISYaAC                   endsl
ISYaA*
     C                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 17
510bAC                   eval      zffnam = 'ITEM'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
CLDxAC                   if        kyfmt = 'PIRMERG2'
CLDxAC                   movea(p)  lb_lbitem     a50
CLDxAC                   else
     C                   movea(p)  lbitem        a50
CLDxAC                   endif
     C                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 18
510bAC                   eval      zffnam = 'CORD'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
700xAC                   select
700xAC                   when      client = cheney
700xAC                             and kyfmt = 'WLSPCL'
700xAC                   move      yohcord       $nanum
700xAC                   eval      temp7a = %char(yohcord)
700xAC                   other
     C                   move      ohcord        $nanum
CWDtAC                   eval      temp7a = %char(ohcord)
700xAC                   endsl
     C                   endif
     C                   eval      $nadec = 0
CWDtD ***                exsr      filnum
CWDtAC                   movea(p)  temp7a        a50
CWDtAC                   exsr      filchr
     *
     C                   when      @var = 19
510bAC                   eval      zffnam = 'CUST#'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
     C                   eval      $nanum = ohcust
     C                   endif
     C                   eval      $nadec = 0
CBIaAC                   select
CBIaAC                   when      client = cheney
CBIaMC                   exsr      editna
CBIAAC                   movea     a12           t#cs12
CBIaAC                   move      t#cs12        dscust
CBIaAC                   eval      t#cust = *blanks
CBIAAC                   movel     ds8           t#cust
CBIaAC                   if        ds2 <> '00'
CBIaAC     t#cust        cat       '-':0         t#cust
CBIaAC     t#cust        cat       ds2:0         t#cust
CBIaAC                   else
CBIaAC                   movel     ds8           t#cust
CBIaAC                   endif
CBIaAC                   movea(p)  t#cust        a50
740eAC                   movea(p)  work11a       a50
CBIaAC                   exsr      filchr
CBIaAC                   other
     C                   exsr      filnum
CBIaAC                   endsl
     *
     *  Date
     *     @VAR=20
     *
ALNkAC                   when      @var = 20
510bAC                   eval      zffnam = 'DATE'
VIPcA*
VIPcAC                   select
JORdAC                   when      client = jordanos
FRFaMC                             or client = frf
ISPfMC                             or client = isupply
530gMC                   movea(p)  pkdate        a50
530gAC                   exsr      filchr

HALbAC                   when      client = halsey
HALbAC                   movea(p)  work8a        a50
HALbAC                   exsr      filchr
HALbA*
SFGbAC                   when      client = sgc
SFGbAC                   movea(p)  todayplus1    a50
ALNKAC                   exsr      filchr

KFSbAC                   when      client = Kellys
KFSbAC                   movea(p)  work8a        a50
     C                   exsr      filchr
SFGbA*
BIRaAC                   when      client = birite
BIRa C                   eval      $cvcmd = '*MDYCMD '
BIRa C                   eval      wkshdt = dssdte2
BIRa C                   move      wkshdt        $cvd6i
BIRa C                   call      @cvtdt
BIRa C                   parm                    $cvtdt
BIRa C                   move      $cvd8o        shipdt
BIRa C                   movea     *blanks       a50
BIRa C                   movea(p)  shipdt        a50
BIRa C                   exsr      filchr
DRYiA*
DRYiAC                   when      client = dairyland
DRYiAC                             and deliverydate2 <> *blanks
DRYiAC                   move      deliverydate2 usadate
DRYiAC                   move      usadate       mdydate
DRYiAC                   move      mdydate       work8a
DRYiAC                   movea(p)  work8a        a50
DRYiAC                   exsr      filchr
     *
GFSeAC                   when      client = getfresh
HKWdAC                             or client = hkw
GLPcAC                             or client = Greenleaf
PFCbAC                             or client = Prestofoods
GFSeMC                   movea(p)  shipdate      a50
GFSeAC                   exsr      filchr

ALNkAC                   when      client = cityline
ALNkAC                   eval      wkmm = dsmm
ALNkAC                   eval      wksl1 = '/'
ALNkAC                   eval      wkdd = dsdd
ALNkAC                   eval      wksl2 = '/'
ALNkAC                   eval      wkyy = dsyy
ALNKAC                   movea(p)  wksdte        a50
ALNKAC                   exsr      filchr

CBIcAC                   when      client = cheney
CBIcAC                   movea(p)  dssdte3       a50
CBIcAC                   exsr      filchr

SFGbAC                   other
NCScMC                   movea(p)  pkdate        a50
NCScD ***                movea(p)  work8a        a50
ALNKAC                   exsr      filchr
VIPcA*
VIPcAC                   endsl
     *
     C                   when      @var = 21
510bAC                   eval      zffnam = 'TRUCK'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
GFSlAC                   select
GFSlAC                   when      client = getfresh
GFSlAC                             and $ptruk = 'ADDON'
GFSlAC                   movea(p)  addon         a50

GFSlAC                   when      client = getfresh
GFSlAC                   movea(p)  '          '  a50

GFSlAC                   other
     C                   movea(p)  ohtruk        a50
GFSlAC                   endsl
     C                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 22
510bAC                   eval      zffnam = 'CNAME'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
CLDxAC                   if        kyfmt = 'PIRMERG2'
CLDxAC                   movea(p)  xohcnam       a50
CLDxAC                   else
     C                   movea(p)  ohcnam        a50
CLDxAC                   endif
     C                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 23
510bAC                   eval      zffnam = 'CADR1'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  ohcad1        a50
     C                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 24
510bAC                   eval      zffnam = 'CCITY'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  ohccty        a50
     C                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 25
510bAC                   eval      zffnam = 'CZIP'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  ohczip        a50
     C                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 26
510bAC                   eval      zffnam = 'PAL#'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
     C                   move      @pal#         $nanum
     C                   endif
     C                   eval      $nadec = 0
     C                   exsr      filnum
     *
     C                   when      @var = 27
510bAC                   eval      zffnam = 'PAL#'
510bAC                   if        logzebra
510bAC                   if        dtlcnt <= palcnt
750fAC                             and fillb1pass = 1
510bAC                   write(e)  zsrec
510bAC                   endif
510bAC                   eval      zsparm = ' '
510bAC                   endif
     C                   add       1             dtlcnt
510bAC                   eval      zsline = dtlcnt
     C                   if        dtlcnt <= palcnt
     C     dtlcnt        occur     palsum
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
     C                   move      dsppal        $nanum
     C                   endif
     C                   eval      $nadec = 0
     C                   exsr      filnum
     C                   endif
     *
     C                   when      @var = 28  and
     C                             dtlcnt <= palcnt
510bAC                   eval      zffnam = 'Stop'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
     C                   move      dspstp        $nanum
     C                   endif
     C                   eval      $nadec = 0
     C                   exsr      filnum
     *
     C                   when      @var = 29  and
     C                             dtlcnt <= palcnt
510bAC                   eval      zffnam = 'Pcs'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
     C                   move      dsppcs        $nanum
     C                   endif
     C                   eval      $nadec = 0
     C                   exsr      filnum
     *
     C                   when      @var = 30  and
     C                             dtlcnt <= palcnt
510bAC                   eval      zffnam = 'Cube'
     C                   if        $pcmd = '*TEST2  '
     C                   exsr      strpdp
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
     C                   move      dspcub        $nanum
     C                   endif
     C                   eval      $nadec = 3
     C                   exsr      filnum
     *
     C                   when      @var = 31  and
     C                             dtlcnt <= palcnt
510bAC                   eval      zffnam = 'Wgt'
     C                   if        $pcmd = '*TEST2  '
     C                   exsr      strpdp
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
     C                   move      dspwgt        $nanum
     C                   endif
     C                   eval      $nadec = 2
     C                   exsr      filnum
     *
     C                   when      @var = 32
510bAC                   eval      zffnam = 'PCKQTY'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
     C                   move      @qty1         $nanum
     C                   endif
     C                   eval      $nadec = 0
     C                   exsr      filnum
     *
     C                   when      @var = 33
510bAC                   eval      zffnam = 'OF'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  totwrd        a50
     C                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 34
510bAC                   eval      zffnam = 'COMBO'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  cmbwrd        a50
     C                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 35
510bAC                   eval      zffnam = 'ZONE'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  $pszon        a50
     C                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 36
510bAC                   eval      zffnam = 'STOP'
510bAC                   if        logzebra
510bAC                   if        dtlcnt <= palcnt
750fAC                             and fillb1pass = 1
510bAC                   write(e)  zsrec
510bAC                   endif
510bAC                   eval      zsparm = ' '
510bAC                   endif
     C                   add       1             dtlcnt
510bAC                   eval      zsline = dtlcnt
650iAC                   eval      $nanum = 0
     C                   if        dtlcnt <= zpdcnt
     C     dtlcnt        occur     zonpku
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
520jAC                   eval      work2 = dszstp
520jAC                   call      @getstop
520jAC                   parm      '*PLTSTP'     $lcmd
520jAC                   parm                    $pwhse
520jAC                   parm                    $prtid
520jAC                   parm      *zeros        $pordr
520jAC                   parm                    work2
520jAC                   parm                    $phstp
520jAC                   if        $phstp <> *zeros
520jAC                   eval      work4 = $phstp
520jMC                   move      work4         $nanum
520jMC                   else
     C                   move      dszstp        $nanum
520jMC                   endif
     C                   endif
     C                   eval      $nadec = 0
     C                   exsr      filnum
     C                   endif
     *
     C                   when      @var = 37  and
     C                             dtlcnt <= zpdcnt
510bAC                   eval      zffnam = 'PCS'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
     C                   move      dszpcs        $nanum
     C                   endif
     C                   eval      $nadec = 0
     C                   exsr      filnum
     *
     C                   when      @var = 38  and
     C                             dtlcnt <= zpdcnt
510bAC                   eval      zffnam = 'ITEM'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   if        dszitm = *blanks  and
     C                             dszdsc = *blanks
     C                   eval      a50 = *blanks
     C                   else
     C                   eval      ix = %trimr(dszitm) + ' ' + '-'
     C                   eval      ix = %trimr(ix) + ' ' + dszdsc
     C                   movea(p)  ix            a50
     C                   endif
     C                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 39  and
     C                             dtlcnt <= zpdcnt
510bAC                   eval      zffnam = 'PAL#'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
     C                   move      dszplt        $nanum
     C                   endif
     C                   eval      $nadec = 0
     C                   exsr      filnum
     *
     C                   when      @var = 40
510bAC                   eval      zffnam = 'TRAN#'
510bAC                   eval      zftrn# = lsttrn
510bAC                   eval      zstrn# = lsttrn
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
     C                   move      lsttrn        $nanum
     C                   endif
     C                   eval      $nadec = 0
     C                   exsr      filnum
     *
     C                   when      @var = 41
510bAC                   eval      zffnam = 'ZONE'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  lstzon        a50
     C                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 42
510bAC                   eval      zffnam = 'TOSLOT'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
SFGkA*
SFGkAC                   Select
SFGkAC                   when      client = sgc
SFGkAC                             and lbstyp = 'X'
SFGkAC                   movea(p)  woslot        a50
SFGkAC                   exsr      filchr
SFGkAC                   other
500cA*
500cAC                   if        $pcmd = '*PR321'
500cA*    Find actual length of To Slot.
500cAC     ' '           checkr    lbdsp2        ln
500cA*    Strip off blanks from To Slot display field.
500cAC                   if        ln > 0
500cAC                   eval      @len = ln
500cAC                   endif
500cAC                   endif
500cA*
     C                   movea(p)  lbdsp2        a50
     C                   exsr      filchr
SFGkAC                   endsl
     C                   endif
     *
     C                   when      @var = 43
510bAC                   eval      zffnam = 'RTE'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  $prte         a50
     C                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 44
510bAC                   eval      zffnam = 'ZTYPE'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  zontyp        a50
     C                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 45
510bAC                   eval      zffnam = 'OUTWRD'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
HMWaAC                   if        hmwdm1_omsubsts = 'SUB'
HMWaAC                   movea(p)  subwrd        a50
HMWaAC                   else
     C                   movea(p)  outwrd        a50
HMWaAC                   endif
     C                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 46
510bAC                   eval      zffnam = 'STOP'
510bAC                   if        logzebra
510bAC                   if        dtlcnt <= palcnt
750fAC                             and fillb1pass = 1
510bAC                   write(e)  zsrec
510bAC                   endif
510bAC                   eval      zsparm = ' '
510bAC                   endif
     C                   add       1             dtlcnt
510bAC                   eval      zsline = dtlcnt
     C                   if        dtlcnt <= ssdcnt
     C     dtlcnt        occur     stpsum
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
520jAC                   eval      work2 = dssstp
520jAC                   call      @getstop
520jAC                   parm      '*PLTSTP'     $lcmd
520jAC                   parm                    $pwhse
520jAC                   parm                    $prtid
520jAC                   parm      *zeros        $pordr
520jAC                   parm                    work2
520jAC                   parm                    $phstp
520jAC                   if        $phstp <> *zeros
520jAC                   eval      work4 = $phstp
520jMC                   move      work4         $nanum
520jAC                   else
     C                   move      dssstp        $nanum
520jAC                   endif
     C                   endif
     C                   eval      $nadec = 0
     C                   exsr      filnum
     C                   endif
     *
     C                   when      @var = 47  and
     C                             dtlcnt <= ssdcnt
510bAC                   eval      zffnam = 'PCS'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
     C                   move      dsspcs        $nanum
     C                   endif
     C                   eval      $nadec = 0
     C                   exsr      filnum
     *
     C                   when      @var = 48  and
     C                             dtlcnt <= ssdcnt
510bAC                   eval      zffnam = 'CUBE'
     C                   if        $pcmd = '*TEST2  '
     C                   exsr      strpdp
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
     C                   move      dsscub        $nanum
     C                   endif
     C                   eval      $nadec = 3
     C                   exsr      filnum
     *
     C                   when      @var = 49  and
     C                             dtlcnt <= ssdcnt
510bAC                   eval      zffnam = 'WGT'
     C                   if        $pcmd = '*TEST2  '
     C                   exsr      strpdp
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
     C                   move      dsswgt        $nanum
     C                   endif
     C                   eval      $nadec = 2
     C                   exsr      filnum
     *
     C                   when      @var = 50  and
     C                             dtlcnt <= ssdcnt
510bAC                   eval      zffnam = 'CNUM'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  dsscnm        a50
     C                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 51
510bAC                   eval      zffnam = 'PCKQTY'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
     C                   move      toqty         $nanum
     C                   endif
     C                   eval      $nadec = 0
     C                   exsr      filnum
     *
     C                   when      @var = 52
510bAC                   eval      zffnam = 'UOM'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  toum          a50
     C                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 53
510bAC                   eval      zffnam = 'FRMITEM'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  fritem        a50
     C                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 54
510bAC                   eval      zffnam = 'TOITEM'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  toitem        a50
     C                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 55
510bAC                   eval      zffnam = 'FRMDSC'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  frdesc        a50
     C                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 56
510bAC                   eval      zffnam = 'TODSC'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  todesc        a50
     C                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 57
510bAC                   eval      zffnam = 'LBL#'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
     C                   endif
     C                   eval      $nadec = 0
CB3jAC                   if        client = cheney
CB3jAC                             and $pcmd = '*SHORTM '
CB3jAC                   move      $plbl#        temp7a
CB3jAC                   else
ALNfAC                   move      lblbl#        temp7a
CB3jAC                   endif
ALNfAC                   movea(p)  temp7a        a50
ALNfAC                   exsr      filchr
     *
     C                   when      @var = 58
510bAC                   eval      zffnam = 'MFR#'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
     C                   move      itven#        $nanum
     C                   endif
     C                   eval      $nadec = 0
     C                   exsr      filnum
     *   Pallet ID
CBSuA*     *** If a change is made to this it also needs to
CBSuA*     *** be made in variable 310 below.
     C                   when      @var = 60
510bAC                   eval      zffnam = 'PLID'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
     C                   move      @plid         $nanum
     C                   endif
     C                   eval      $nadec = 0
     C                   move      @plid         temp7a

CBSoAC                   select
CBSoA*  Move char 2 & 3 of route to beginning of pallet id.
CBSoAC                   when      cliloc = cbiriv  or
CBSoAC                             cliloc = cbiocl
CBSoAC                   if        kyfmt = 'BIGPALCB'  or
CBSpAC                             kyfmt = 'BIGPALC2'
CB2bMC                   eval      temp2a = %subst($prte:3:2)
CBSoAC                   movel     temp2a        temp7a
CBSoAC                   endif

CBSoAC                   other
650bA*   Move last 2 chars of route id to beginning of pallet id.
650bAC                   movel     $prtID        $cstr
650bAC                   call      'ADJUST'
650bAC                   parm      '*RIGHT  '    $CCMD             8
650bAC                   parm                    $CSTR            30
650bAC                   move      $CSTR         TEMP2A            2
650bAC                   movel     TEMP2A        TEMP7A
     C                   movea(p)  temp7a        a50
CBSoAC                   endsl
650bA*
     C                   exsr      filchr
     *  Route ID
     C                   when      @var = 61
510bAC                   eval      zffnam = 'RTID'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  @rtid         a50
     C                   endif
     C                   exsr      filchr
ALNdA*   Pick time
     C                   when      @var = 62
510bAC                   eval      zffnam = 'PICKTIME'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
ALNgMC                   move      pcktm0        $nanum
     C                   endif
ALNgMC                   eval      $nadec = 0
     C                   exsr      filnum
CBIaA*  Item description line 2
CBIaAC                   when      @var = 63
CBIaAC                   if        $pcmd = '*TEST2  '
CBIaAC                   movea     lfvdta        a50
CBIaAC                   else
CBIaMC                   movea(p)  t#dsc2        a50
CBIaAC                   endif
CBIaAC                   exsr      filchr
     *
CLDf *   From Stop
     *     @VAR=65
CLDf C                   when      @var = 65
510bAC                   eval      zffnam = 'STP1'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
BIRcAC                   select
BIRcA* Birite
BIRcAC                   when      client = birite
FSHxAC                             or client = fischerfoods
PFCaAC                             or client = prestofoods
ISYgAC                             or client = isupply
KFScAC                             or client = Kellys
CB2nAC                             or client = cheney

BIRcAC                   eval      $nanum = 0
BIRcAC                   eval      work2 = dsstp1
BIRcAC                   call      @getstop
BIRcAC                   parm      '*PLTSTP'     $lcmd
BIRcAC                   parm                    $pwhse
BIRcAC                   parm                    $prtid
BIRcAC                   parm      *zeros        $pordr
BIRcAC                   parm                    work2
BIRcAC                   parm                    $phstp
BIRcAC                   if        $phstp <> *zeros
BIRcAC                   eval      work4 = $phstp
BIRcAC                   move      work4         $nanum
BIRcAC                   else
BIRcAC                   move      dsstp1        $nanum
BIRcAC                   endif

CWDvA* Cash-wa
CWDvAC                   when      client = cashwa
CWDvAC                             and kyfmt <> 'PALLET'
CWDvAC                             and dtlcnt <= palcnt
     C                   eval      zffnam = 'FromStop'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
     C                   eval      $nanum = 0
     C                   eval      work2 = dsstp1
     C                   call      @getstop
     C                   parm      '*PLTSTP'     $lcmd
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm      *zeros        $pordr
     C                   parm                    work2
     C                   parm                    $phstp
     C                   if        $phstp <> *zeros
     C                   eval      work4 = $phstp
     C                   move      work4         $nanum
     C                   else
     C                   move      dsstp1        $nanum
     C                   endif
     C                   endif

CWDvA* Cash-wa
CWDvAC                   when      client = cashwa
CWDvAC                             and kyfmt = 'PALLET'
     C                   eval      $nanum = 0
     C                   eval      work2 = dsstp1
     C                   call      @getstop
     C                   parm      '*PLTSTP'     $lcmd
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm      *zeros        $pordr
     C                   parm                    work2
     C                   parm                    $phstp
     C                   if        $phstp <> *zeros
     C                   eval      work4 = $phstp
     C                   move      work4         $nanum
     C                   else
     C                   move      dsstp1        $nanum
     C                   endif
CWDvA* Cash-wa
CWDvAC                   when      client = cashwa
BIRcAC                   eval      $nanum = 0
     *
BIRc C                   other
BIRc C                   eval      $nanum = 0
     C                   move      dsstp1        $nanum
BIRc C                   endsl
     C                   endif
     C                   eval      $nadec = 0
     C                   exsr      filnum
     *
     *   To Stop
     *     @VAR=66
     C                   when      @var = 66
     C                   eval      zffnam = 'STP2'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
BIRcAC                   select
BIRcAC                   when      client = birite
FSHxAC                             or client = fischerfoods
PFCaAC                             or client = prestofoods
ISYgAC                             or client = isupply
KFScAC                             or client = Kellys
CB2nAC                             or client = cheney

BIRcAC                   eval      $nanum = 0

BIRcAC                   if        dsstp2 = 0
BIRcAC                   eval      work2 = dsstp1
BIRcAC                   call      @getstop
BIRcAC                   parm      '*PLTSTP'     $lcmd
BIRcAC                   parm                    $pwhse
BIRcAC                   parm                    $prtid
BIRcAC                   parm      *zeros        $pordr
BIRcAC                   parm                    work2
BIRcAC                   parm                    $phstp
BIRcAC                   if        $phstp <> *zeros
BIRcAC                   eval      work4 = $phstp
BIRcAC                   move      work4         $nanum
BIRcAC                   else
BIRcAC                   move      dsstp1        $nanum
BIRcAC                   endif

BIRcAC                   else
BIRcAC                   eval      work2 = dsstp2
BIRcAC                   call      @getstop
BIRcAC                   parm      '*PLTSTP'     $lcmd
BIRcAC                   parm                    $pwhse
BIRcAC                   parm                    $prtid
BIRcAC                   parm      *zeros        $pordr
BIRcAC                   parm                    work2
BIRcAC                   parm                    $phstp
BIRcAC                   if        $phstp <> *zeros
BIRcAC                   eval      work4 = $phstp
BIRcAC                   move      work4         $nanum
BIRcAC                   else
BIRcAC                   move      dsstp2        $nanum
BIRcAC                   endif
BIRcAC                   endif

CWDvA* Cash-wa
CWDvAC                   when      client = cashwa
CWDvAC                             and kyfmt <> 'PALLET'
CWDvAC                             and dtlcnt <= palcnt
     C                   eval      zffnam = 'ToStop'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
     C                   eval      $nanum = 0
     C                   eval      work2 = dsstp2
     C                   call      @getstop
     C                   parm      '*PLTSTP'     $lcmd
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm      *zeros        $pordr
     C                   parm                    work2
     C                   parm                    $phstp
     C                   if        $phstp <> *zeros
     C                   eval      work4 = $phstp
     C                   move      work4         $nanum
     C                   else
     C                   move      dsstp2        $nanum
     C                   endif
     C                   endif

CWDvA* Cash-wa
CWDvAC                   when      client = cashwa
CWDvAC                             and kyfmt = 'PALLET'
     C                   eval      $nanum = 0
     C                   eval      work2 = dsstp2
     C                   call      @getstop
     C                   parm      '*PLTSTP'     $lcmd
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm      *zeros        $pordr
     C                   parm                    work2
     C                   parm                    $phstp
     C                   if        $phstp <> *zeros
     C                   eval      work4 = $phstp
     C                   move      work4         $nanum
     C                   else
     C                   move      dsstp2        $nanum
     C                   endif
CWDvA* Cash-wa
CWDvAC                   when      client = cashwa
     C                   eval      $nanum = 0
     *
BIRc C                   other
     *
     C                   if        dsstp2 = 0
     C                   move      dsstp1        $nanum
     C                   else
     C                   move      dsstp2        $nanum
     C                   endif
BIRcAC                   endsl
     *
     C                   endif
     C                   eval      $nadec = 0
     C                   exsr      filnum
     *
     C                   when      @var = 67
CBIxAC                   if        $pcmd = '*TEST2  '
CBIxAC                   movea     lfvdta        a50
CBIxAC                   else
CBIxAC                   select
CBIxAC                   when      client = cheney
     *  2nd line desc for Zone Pickup summary
CBIxAC                   movea(p)  dszds2        a50
CBIxAC                   other
     C                   movea(p)  pkdate        a50
CBIxAC                   endsl
CBIxAC                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 68
CBIxAC                   if        $pcmd = '*TEST2  '
CBIxAC                   movea     lfvdta        a50
CBIxAC                   else
CBIxAC                   select
CBIxAC                   when      client = cheney
CBIxAC                   movea(p)  dszpck        a50
CBIxAC                   other
     C                   movea(p)  ohcpo         a50
CBIxAC                   endsl
CBIxAC                   endif
     C                   exsr      filchr
     *
     C                   when      @var = 69
     C                   movea(p)  dscitm        a50
     C                   exsr      filchr
     *
CBIaA*  Special instructions
CBIaAC                   when      @var = 70
CBIaAC                   if        $pcmd = '*TEST2  '
CBIaAC                   movea     lfvdta        a50
CBIaAC                   else
CBIaAC                   movea(p)  t#spcl        a50
CBIaAC                   endif
CBIaAC                   exsr      filchr
CDIfA*
CDIfA*  Reprint / Price for Breakers
     C                   when      @var = 71
     C                   eval      zffnam = 'Reprint'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   if        $pcmd = '*REPRINT'
650cAC                             or $pcmd = '*RPRTZN'
650cAC                             or $pcmd = '*RPRTLB'
650cAC                             or $pcmd = '*PRTTRN'

GLPaAC                   select
750iMC                   when      client <> greenleaf
750iMC                             and client <> cpj
750iMC                             and client <> prestofoods
750iMC                   movea(p)  @reprint      a50
750iMC                   other
750iMC                   movea(p)  'R'           a50
GLPaAC                   endsl
     C                   else
750fAC                   if        fillb1pass = 2
750fAC                   movea(p)  '<71>'        a50
750fAC                   else
     C                   movea(p)  *blanks       a50
750fAC                   endif
     C                   endif
     C                   endif
CDIfAC                   exsr      filchr
CBIfA*  A1A item number
CBIfAC                   when      @var = 72  and
CHYp C                             dsaitm <> 'L I F '
CBIfAC                   if        $pcmd = '*TEST2  '
CBIfAC                   movea     lfvdta        a50
CBIfAC                   else
CBIfAC                   movea(p)  dsaitm        a50
CBIfAC                   endif
CBIfAC                   exsr      filchr
CBIhA*  Zone description
CBIhAC                   when      @var = 73
CBIhAC                   if        $pcmd = '*TEST2  '
CBIhAC                   movea     lfvdta        a50
CBIhAC                   else
CBIhAC                   movea(p)  t#zdsc        a50
CBIhAC                   endif
CBIfAC                   exsr      filchr
642cA*
642cA*  Truck Template
     C                   when      @var = 74
     C                   eval      zffnam = 'Truck'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
GFSlAC                   select
GFSlAC                   when      client = getfresh
GFSlAC                             and $ptruk = 'ADDON'
GFSlAC                   movea(p)  addon         a50
GFSlAC                   when      client = getfresh

GFSlAC                   movea(p)  '          '  a50
EIi A*
EIi AC                   when      client = EI
EIi AC                   movea(p)  dscitm        a50

CBIhAC                   when      client = cheney
CBIhAC                   movea(p)  t#truk        a50

GFSlAC                   other
     C                   movea(p)  $ptruk        a50
GFSlAC                   endsl
     C                   endif
     C                   exsr      filchr
     *
FRFaAC                   when      @var = 75
FRFaAC                   eval      zffnam = 'DESC'
FRFaAC                   if        $pcmd = '*TEST2  '
FRFaAC                   movea     lfvdta        a50
FRFaAC                   else
FRFaAC                   select
FRFaAC                   when      client = frf
FRFaAC                   movea(p)  newdsc1       a50
FRFaAC                   when      client = cheney
     *  Willcall special instructions-1
CHYu C                   movea(p)  yohcad1       a50
FRFaAC                   endsl
FRFaAC                   endif
FRFaAC                   exsr      filchr
     *
FRFaAC                   when      @var = 76
FRFaAC                   eval      zffnam = 'DESC'
FRFaAC                   if        $pcmd = '*TEST2  '
FRFaAC                   movea     lfvdta        a50
FRFaAC                   else
FRFaAC                   select
FRFaAC                   when      client = frf
FRFaAC                   movea(p)  newdsc2       a50
FRFaAC                   when      client = cheney
     *  Willcall special instructions-2
CHYu C                   movea(p)  yohcad2       a50
FRFaAC                   endsl
FRFaAC                   endif
FRFaAC                   exsr      filchr
     *  Route Via indicator
CBSn C                   when      @var = 77
CBSn C                   if        $pcmd = '*TEST2  '
CBSn C                   movea     lfvdta        a50
CBSn C                   else
CBSn C                   if        dsrvia = *blanks
CBSn C                   eval      a50 = *blanks
CBSn C                   else
CBSn C                   movea(p)  @rvia         a50
CBSn C                   endif
CBSn C                   endif
CBSn C                   exsr      filchr

     C                   when      @var = 82
510bAC                   eval      zffnam = 'STOP'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
     C                   move      lbstop        $nanum
     C                   endif
     C                   eval      $nadec = 0
     C                   exsr      filnum
730eA*
730eA*  Host Order number.
730eA*     @VAR = 91
730eAC                   when      @var = 91
730aAC                   eval      zffnam = 'CORD'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
730gAC                   if        client = Cheney
730gAC                   movea(p)  work11b       a50
730gAC                   else
     C                   movea(p)  work8a        a50
730gAC                   endif
     C                   endif
730eAC                   exsr      filchr
     *  Original item number.
     *     @VAR = 92
     *
CLDpA*  Pir Seq#
     *     @VAR = 93
     C                   when      @var = 93
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
     C                   move      nxtseq        $nanum
     C                   endif
     C                   eval      $nadec = 0
     C                   exsr      filnum
     *
     *  Order Seq #
530 A*     @VAR = 94
     *
     C                   when      @var = 94
510bAC                   eval      zffnam = 'ORDSEQ#'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
SFGgAC                   if        client = sgc
SFGgAC                   move      odor2         $nanum
SFGgAC                   else
     C                   move      lbseq         $nanum
SFGgAC                   endif
     C                   endif
     C                   eval      $nadec = 0
     C                   exsr      filnum
530 A*
530 A*  Batch #
530 A*     @VAR = 95
530 A*
530 AC                   when      @var = 95
530 AC                   eval      zffnam = 'BATCH #'
530 AC                   if        $pcmd = '*TEST2  '
530 AC                   movel     lfvdta        $cstr
530 AC                   call      'ADJUST'
530 AC                   parm      '*RIGHT  '    $ccmd
530 AC                   parm                    $cstr
530 AC                   move      $cstr         $nanum
530 AC                   else
530 AC                   move      lbpbat        $nanum
530 AC                   endif
530 AC                   eval      $nadec = 0
530 AC                   exsr      filnum
530 A*
     *  Vendor Item #/ Mfg code - ITVIT# field.
     C                   when      @var = 97
510bAC                   eval      zffnam = 'VENITEM'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
GFCaAC                   select
GFCaAC                   when      client = gfc
GFCaAC                   evalr     work15 = %trimr(itvit#)
GFCaAC                   movea(p)  work15        a50
GFCaAC                   other
     C                   movea(p)  itvit#        a50
GFCaAC                   endsl
     C                   endif
     C                   exsr      filchr
EIc  *  SRP
     *    @VAR = 98
     *
EIc  C                   when      @var = 98  and
EIC  C                             dssrp <> *blanks
EIc  C                   movea(p)  dssrp         a50
EIc  C                   exsr      filchr
     *  Memo
     *    @VAR = 99
     *
NFC A*  UPC
     *    @VAR = 100
     *
SFC A*  Mfg Code - Custom SFC
740eA*  CORD extended length 7.0 to 11 (currently at Cheney)
     *    @VAR = 101
740eAC                   when      @var = 101
740eAC                   eval      zffnam = 'CORD'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
740eAC                   select
740eAC                   when      client = cheney
740eAC                             and kyfmt = 'WLSPCL'
CB3sAC                   exsr      GetOrd
740eAC                   move      yohcord       $nanum
740eAC                   eval      temp7a = %char(yohcord)
740eAC                   other
     C                   move      ohcord        $nanum
740eAC                   eval      temp7a = %char(ohcord)
740eAC                   endsl
     C                   endif
     C                   eval      $nadec = 0
740eAC                   if        client = cheney
740eAC                   movea(p)  work11b       a50
740eAC                   else
740eAC                   movea(p)  temp7a        a50
740eAC                   endif
740eAC                   exsr      filchr
     *
SFC A*  Brand name
     *    @VAR = 102
     *
SFGc C                   when      @var = 102
510bAC                   eval      zffnam = 'BRAND'
SFGc C                   if        $pcmd = '*TEST2  '
SFGc C                   movea     lfvdta        a50
SFGc C                   else
SFGc C                   movea(p)  imbrnd        a50
SFGc C                   endif
SFGc C                   exsr      filchr
     *
     *  Department
     *
ALN AC                   when      @var = 103
510bAC                   eval      zffnam = 'WHDP'
ALN AC                   if        $pcmd = '*TEST2  '
ALN AC                   movea     lfvdta        a50
ALN AC                   else
700wAC                   select
700wAC                   when      client = Cheney
700wAC                             and kyfmt = bigpal
700wAC                   eval      department1 = *blanks
GFSlAC                   movea(p)  '          '  a50
700wAC     keydoc        chain     docroute
700wAC                   if        %found(docroute)
700wAC                   eval      department1 = %subst(drwhdp:1:1)
ALN AC                   movea(p)  department1   a50
700wAC                   endif
700wAC                   other
ALN AC                   movea(p)  $pcomp        a50
700wAC                   endsl
ALN AC                   endif
ALN AC                   exsr      filchr
     *
SFC A*  Misc field OHMISC
     *    @VAR = 104
     *
     *
ALN A*  Pallet section
     *    @VAR = 105
ALN AC                   when      @var = 105
510bAC                   eval      zffnam = 'PLTSECT'
ALN AC                   if        $pcmd = '*TEST2  '
ALN AC                   movea     lfvdta        a50
ALN AC                   else
CLDdD**                   MOVEALBHND2    A50       P
CLDdMC                   movea(p)  @psect        a50
ALN AC                   endif
ALN AC                   exsr      filchr
     *
     *
ALN A*  Dock door number
     *    @VAR = 106
     *
     C                   when      @var = 106
510bAC                   eval      zffnam = 'DOOR'
ctwaAC                   eval      $nanum = *zeros
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
CB2pA*
CB2pAC                   select
CB2pAC                   when      client = Cheney
CB2pAC                             and (cliloc = cheneyriviera
CB3tAC                               or cliloc = cbist
CB3gAC                               or cliloc = cbimlk
CB3iAC                               or cliloc = cbitif
CB2pAC                               or cliloc = cheneyocala)
CB2pAC                   movea (p) dsdoor        a50
CB2pAC                   other
CB2pA*
520eD ***                move      $ldoor        $nanum
520eMC                   z-add     $ldoor        $nanum
CB2pAC                   endsl
CB2pA*
     C                   endif
CB2pA*
CB2pAC                   select
CB2pAC                   when      client = Cheney
CB2pAC                             and (cliloc = cheneyriviera
CB3tAC                               or cliloc = cbist
CB3gAC                               or cliloc = cbimlk
CB3iAC                               or cliloc = cbitif
CB2pAC                               or cliloc = cheneyocala)
CB2pAC                   exsr      filchr
CB2pAC                   other
CB2pA*
     C                   eval      $nadec = 0
     C                   exsr      filnum
CB2pAC                   endsl
CB2pA*
     *
cwdgA*  Unique piece number (POD#)
cwdgA*    @VAR = 107
cwdgA*
cwdgAC                   when      @var = 107

cwdgAC                   eval      zffnam = 'CORD'
cwdgAC                   if        $pcmd = '*TEST2  '
cwdgAC                   movel     lfvdta        $cstr
cwdgAC                   call      'ADJUST'
cwdgAC                   parm      '*RIGHT  '    $ccmd
cwdgAC                   parm                    $cstr
cwdgAC                   move      $cstr         $nanum
cwdgAC                   move      $nanum        temp5a
cwdgAC                   else
CBSsAC                   select
CBSsAC                   when      client = cheney
CBSsAC                   move      unqpiece#     temp5a
CBSsAC                   other
xxxxxC                   if        ohcord > 99999
xxxxxC                   move      ohcord        temp5a
xxxxxC                   else
cwdgAC                   z-add     ohcord        temp50
cwdgAC                   eval      temp5a = %char(temp50)
xxxxxC                   endif
CBSsAC                   endsl
cwdgAC                   endif
cwdgAC                   movea(p)  temp5a        a50
cwdgAC                   exsr      filchr
     *
650dA*  Stop Drop
650dA*    @VAR = 108
650dAC                   when      @var = 108
650dAC                   eval      zffnam = 'Stop Drop'
650dAC                   if        $pcmd = '*TEST2  '
650dAC                   movea     lfvdta        a50
650dAC                   else
650dMC                   movea(p)  stopdrop      a50
650dAC                   endif
650dAC                   exsr      filchr
640cA*
640cA*  Aisle
640cA*    @VAR = 114
640cA*
640cAC                   when      @var = 114
640cAC                   eval      zffnam = 'AISLE'
640cAC                   eval      $nanum = *zeros
640cAC                   if        $pcmd = '*TEST2  '
640cAC                   movel     lfvdta        $cstr
640cAC                   call      'ADJUST'
640cAC                   parm      '*RIGHT  '    $ccmd
640cAC                   parm                    $cstr
640cAC                   move      $cstr         $nanum
640cAC                   else
640cAC                   move      lbaisl        $nanum
640cAC                   endif
640cAC                   eval      $nadec = 0
640cAC                   exsr      filnum
640fA*
640fA*  Generic 5-Char field - Tote piece count
640fA*    @VAR = 120
640fAC                   when      @var = 120
640fAC                   eval      zffnam = 'PCSCNT'
640fAC                   if        $pcmd = '*TEST2  '
640fAC                   movel     lfvdta        $cstr
640fAC                   call      'ADJUST'
640fAC                   parm      '*RIGHT  '    $ccmd
640fAC                   parm                    $cstr
640fAC                   move      $cstr         $nanum
640fAC                   else
640fAC                   move      yptpcs        $nanum
640fAC                   endif
640fAC                   eval      $nadec = 0
640fAC                   exsr      filnum
     *
SvlhA*  Customer order number
SvlhA*    @VAR = 122
SvlhAC                   when      @var = 122
SvlhAC                             and dtlcnt <= ssdcnt
SvlhAC                   eval      zffnam = 'OHCORD'
SvlhAC                   if        $pcmd = '*TEST2  '
SvlhAC                   movel     lfvdta        $cstr
SvlhAC                   call      'ADJUST'
SvlhAC                   parm      '*RIGHT  '    $ccmd
SvlhAC                   parm                    $cstr
SvlhAC                   move      $cstr         $nanum
SvlhAC                   else
SvlhAC                   move      dssord        $nanum
SvlhAC                   endif
SvlhAC                   eval      $nadec = 0
SvlhAC                   exsr      filnum
640cA*
640cA*  Stamping unit / Saval barcode
     *
     *  cccccpppppmmddyy
     *  cust5item5mmddyy
     *
640cA*    @VAR = 125
640cAC                   when      @var = 125

SVLbAC                   select
SVLbAC                   when      client = saval
SVLbAC                   eval      zffnam = 'SVLBcde'
SVLbAC                   if        $pcmd = '*TEST2  '
SVLbAC                   movea     lfvdta        a50
SVLbAC                   else
SVLbAC                   move      work5         cust5
SVLbAC                   eval      work16 = cust5 +
SVLbAC                                      %subst(lbitem:1:5) +
SVLeAC                                      mdy2
SVLbMC                   movea(p)  work16        a50
SVLbAC                   endif

SVLbAC                   other

SVLbAC                   eval      zffnam = 'Stamp'
640cAC                   movea(p)  wkstmp        a50
640cAC     ' '           checkr    wkstmp        ln
640cAC                   if        ln > *zeros
640cAC                   eval      @len = ln
640cAC                   endif
     C                   endsl

640cAC                   exsr      filchr
CPCcA*
CPCcA*  Pick Goal Time
CPCcA*    @VAR = 132
CPCcAC                   when      @var = 132 and
CPCcAC                             dtlcnt <= palcnt
CPCcAC                   eval      zffnam = 'GoalTm'
CPCcAC                   if        $pcmd = '*TEST2  '
CPCcAC                   exsr      strpdp
CPCcAC                   movel     lfvdta        $cstr
CPCcAC                   call      'ADJUST'
CPCcAC                   parm      '*RIGHT  '    $ccmd
CPCcAC                   parm                    $cstr
CPCcAC                   move      $cstr         $nanum
CPCcAC                   else
CPCcAC                   move      dspgtm        $nanum
CPCcAC                   endif
CPCcAC                   eval      $nadec = 3
CPCcAC                   exsr      filnum
     *
VIPa *  Memo code
     *    @VAR = 154
BIRa C                   when      @var = 154
BIRa C                   eval      zffnam = 'MemoCd'
BIRa C                   if        $pcmd = '*TEST2  '
BIRa C                   movea     lfvdta        a50
BIRa C                   else

CLDlAC                   select
CLDlAC                   when      client = cityline
CLDlAC                   move      nxtseq        $nanum
CLDlAC                   eval      $nadec = 0
CLDlAC                   exsr      filnum
CLDlAC                   other
BIRa C                   movea(p)  dsmemo        a50
BIRa C                   exsr      filchr
CLDlAC                   endsl
BIRa C                   endif
     *
CLDlA*   PIR Merge Lbl
     C                   when      @var = 155
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  seqfld        a50
     C                   endif
     C                   exsr      filchr
     *
CLDlA*   LBCTR#
     C                   when      @var = 156
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         temp7a
     C                   else
     C                   move      lbctr#        temp7a
     C                   endif
     C                   movea(p)  temp7a        a50
     C                   exsr      filchr
     *
CCPaA*  Customer specific instructions
CCPaA*    @VAR = 158
CCPaAC                   when      @var = 158
CCPaAC                   if        $pcmd = '*TEST2  '
CCPaAC                   movea     lfvdta        a50
CCPaAC                   else
CCPaAC                   if        client = capitolcity
CCPaAC                             or client = cityln
CCPaAC                   if        ccpchk = '*SP'
CCPaAC                   movea(p)  ccpspec       a50
CCPaAC                   endif
CCPcAC                   if        ccpchks = 'Y'
CCPcAC                   movea(p)  ccpsch        a50
CCPcAC                   endif
CCPaAC                   endif
CCPaAC                   endif
GFSmA*
GFSmAC                   if        client = getfresh
GFSmA*      Load customer critical care message.
GFSmAC                   if        gfsmsc_ohccar = 'Y'
GFSmAC                   movea(p)  gfsspec       a50
GFSmAC                   endif
GFSmA*
GFSmAC                   endif
GFSmA*
CCPaAC                   exsr      filchr
     *
CCPaA*  Item specific instructions
CCPaA*    @VAR = 159
CCPaAC                   when      @var = 159
CCPaAC                   if        $pcmd = '*TEST2  '
CCPaAC                   movea     lfvdta        a50
CCPaAC                   else
CCPaAC                   movea(p)  ommsc5        a50
CCPaAC                   endif
CCPaAC                   exsr      filchr
     *
GFScA*  Each quantity for PICK2
GFScA*    @VAR = 161
GFScAC                   when      @var = 161
     C                   eval      zffnam = 'Each x of x'
     C                   select
GFShAC                   when      lbutyp = '1'
GFShAC                             and itum2 = 'LB'

GFShAC                   if        itminq = 0
GFShAC                   eval      itminq = 1.00
GFShAC                   endif

GFSjAC                   if        Combo = '1'
GFSjAC                   eval      eachqtyfld = 'COMBO'
GFSjAC                                          + ' '
GFSjAC                                          + %trim(%editc(@qty2:'4'))
GFSjAC                                          + ' '
GFSjAC                                          + %trim(%editc(itminq:'4'))
GFSjAC                                          + ' '
GFSjAC                                          + %trim(itum2)
GFSjAC                   else
GFShMC                   eval      eachqtyfld = %trim(%editc(@qty1:'4'))
GFShMC                                          + ' of '
GFShMC                                          + %trim(%editc(@qty2:'4'))
GFShMC                                          + ' '
GFShMC                                          + %trim(%editc(itminq:'4'))
GFShMC                                          + ' '
GFShMC                                          + %trim(itum2)
GFSjAC                   endif

     C                   when      lbutyp = '2'
     C                             and itum3 = 'LB'

GFShAC                   if        itminq = 0
GFShAC                   eval      itminq = 1.00
GFShAC                   endif

GFSjAC                   if        Combo = '1'
GFSjAC                   eval      eachqtyfld = 'COMBO'
GFSjAC                                          + ' '
GFSjAC                                          + %trim(%editc(@qty2:'4'))
GFSjAC                                          + ' '
GFSjAC                                          + %trim(%editc(itminq:'4'))
GFSjAC                                          + ' '
GFSjAC                                          + %trim(itum3)
GFSjAC                   else
GFShMC                   eval      eachqtyfld = %trim(%editc(@qty1:'4'))
GFShMC                                          + ' of '
GFShMC                                          + %trim(%editc(@qty2:'4'))
GFShMC                                          + ' '
GFShMC                                          + %trim(%editc(itminq:'4'))
GFShMC                                          + ' '
GFShMC                                          + %trim(itum3)
GFSjAC                   endif

     C                   other
     C                   eval      eachqtyfld = %trim(%editc(@qty1:'4'))
     C                                          + ' of '
     C                                          + %trim(%editc(@qty2:'4'))
     C                                          + ' '
     C                                          + %trim(umshrt)
     C                   endsl
     C                   movea(p)  eachqtyfld    a50
     C                   exsr      filchr
650lA*
650lA*  Pallet Section String
650lA*    @VAR = 169
650lAC                   when      @var = 169
650lAC                   eval      zffnam = 'Sect String'
650lAC                   if        $pcmd = '*TEST2  '
650lAC                   movea     lfvdta        a50
650lAC                   else
650lAC                   movea(p)  sectionstring a50
650lAC                   endif
650lAC                   exsr      filchr
CB3nA*
CB3nA*  P/O Number
CB3nA*    @VAR = 170
CB3nAC                   when      @var = 170
CB3nAC                   eval      zffnam = 'P/O Number'
CB3nAC                   if        $pcmd = '*TEST2  '
CB3nAC                   movea     lfvdta        a50
CB3nAC                   else
CB3nAC                   select
CB3nAC                   when      client = cheney
CB3nAC                             and ohcpo <> *blanks
CB3nAC                             and (kyfmt = 'PICK'
CB3nAC                             or   kyfmt = 'PICK2'
CB3nAC                             or   kyfmt = 'PICK3'
CB3nAC                             or   kyfmt = 'PICKM')
CB3nAC                   eval      work20a = 'PO# ' + ohcpo
CB3nAC                   movea(p)  work20a       a50
CB3nAC                   exsr      filchr
CB3nAC                   endsl
CB3nAC                   eval      work20a = *blanks
CB3nAC                   endif
CTWfA*
CTWfA*  Tax Amount 8-Char field
CTWfA*    @VAR = 175
CTWfAC                   when      @var = 175
CTWfAC                   eval      zffnam = 'Tax Amt'
CTWfAC                   select
CTWfAC                   when      client = citywho
CTWfAC                             and  kyfmt = 'PICK2 '
CTWfAC                             and  recapflag = 'Y'
CTWfAC                   movea(p)  taxamount     a50
CTWfAC                   when      client = citywho
CTWfAC                   other
CTWfAC                   movea(p)  *blanks       a50
CTWfAC                   endsl
CTWfAC                   exsr      filchr
     *
     *  Recap Tax Amount 8-Char field
     *    @VAR = 176
CTWqAC                   when      @var = 176
CTWqAC                   eval      zffnam = 'Tax Amt'
CTWqAC                   select
CTWqAC                   when      client = citywho
CTWqAC                             and  kyfmt = 'PICK2 '
CTWqAC                             and  recapflag = 'Y'
CTWqAC                   movea(p)  recaptaxamt   a50
CTWqAC                   other
CTWqAC                   movea(p)  *blanks       a50
CTWqAC                   endsl
CTWqAC                   exsr      filchr
640gA*
640gA*  Pallet/Tote heading
640gA*    @VAR = 177
640gAC                   when      @var = 177
640gAC                   eval      zffnam = 'Heading'
640gAC                   if        $pcmd = '*TEST2  '
640gAC                   movea     lfvdta        a50
640gAC                   else
640gAC                   select
640gAC                   when      totzon
640gAC                   movea(p)  Totehdg       a50
640gAC                   when      not totzon
640gAC                   movea(p)  PalletHdg     a50
640gAC                   endsl
640gAC                   endif
640gAC                   exsr      filchr
     *
CWDaA*  CWD City State
CWDaA*    @VAR = 179
CWDaAC                   when      @var = 179
CWDaAC                   eval      zffnam = 'citysta'
CWDaAC                   if        $pcmd = '*TEST2  '
CWDaAC                   movea     lfvdta        a50
CWDaAC                   else
CWDaMC                   movea(p)  citystate     a50
CWDaAC                   endif
CWDaAC                   exsr      filchr
     *
CWDaA*  CWD Invoice Number
CWDaA*    @VAR = 180
CWDaAC                   when      @var = 180
CWDaAC                   eval      zffnam = 'Invoice'
CWDaAC                   if        $pcmd = '*TEST2  '
CWDaAC                   movea     lfvdta        a50
CWDaAC                   else
CWDaMC                   movea(p)  xohcpo        a50
CWDaAC                   endif
CWDaAC                   exsr      filchr
     *
CWDaA*  CWD Customer Number
CWDaA*    @VAR = 181
CWDaAC                   when      @var = 181
CWDaAC                   eval      zffnam = 'Cust#'
CWDaAC                   if        $pcmd = '*TEST2  '
CWDaAC                   movea     lfvdta        a50
CWDaAC                   else
CWDaMC                   movea(p)  xohczip       a50
CWDaAC                   endif
CWDaAC                   exsr      filchr
     *
CWDaA*  CWD Ship date
CWDaA*    @VAR = 182
CWDaAC                   when      @var = 182
CWDaAC                   eval      zffnam = 'ShipDte'
CWDaAC                   if        $pcmd = '*TEST2  '
CWDaAC                   movea     lfvdta        a50
CWDaAC                   else
svlaAC                   select
svlaAC                   when      client = saval
svlaAC                   movea(p)  deliverydate  a50
svlaAC                   other
CWDaMC                   movea(p)  shipdate      a50
svlaAC                   endsl
CWDaAC                   endif
CWDaAC                   exsr      filchr
     *
530bA*  extended Stop number
530bA*    @VAR = 183
530bAC                   when      @var = 183
530bAC                   eval      zffnam = 'Stop #'
530bAC                   if        $pcmd = '*TEST2  '
530bAC                   movea     lfvdta        a50
530bAC                   else
530bMC                   movea(p)  extStop       a50
530bAC                   endif
530bAC                   exsr      filchr
     *
CWDaA*  CWD Label number
CWDaA*    @VAR = 184
CWDaAC                   when      @var = 184
CWDaAC                   eval      zffnam = 'Label#'
CWDaAC                   if        $pcmd = '*TEST2  '
CWDaAC                   movea     lfvdta        a50
CWDaAC                   else
CWDeA*    Find actual length of Item.
CWDmDC*    ' '           checkr    odoitm        ln
CWDuD ***  ' '           checkr    cwddm2_lblnbr ln
CWDuMC     ' '           checkr    cwddm1_lblnbr ln
CWDeA*    Strip off blanks from Item field.
CWDeAC                   if        ln > 0
CWDeAC                   eval      @len = ln
CWDeAC                   endif
CWDmDC*                  movea(p)  odoitm        a50
CWDuD ***                movea(p)  cwddm2_lblnbr a50
CWDuMC                   movea(p)  cwddm1_lblnbr a50
CWDaAC                   endif
CWDaAC                   exsr      filchr
     *
520fA*  Customer # / Customer name
520fA*    @VAR = 185
520fAC                   when      @var = 185
520fAC                   eval      zffnam = 'Cs#/Nm'
520fAC                   if        $pcmd = '*TEST2  '
520fAC                   movea     lfvdta        a50
520fAC                   else
520fAC                   select
GFCaAC                   when      client = gfc
GFCgMC                             and ohcust <> *zeros
GFCaAC                   eval      workcus = %trim(%editc(ohcust:'4'))
GFCaAC                                         + '  '
GFCaAC                                         + %trim(ohcnam)
GFCgAC                   movea(p)  workcus       a50

GFCgAC                   when      client = gfc
GFCgAC                             and ohcust =  *zeros
GFCgAC                             and %subst($prte:1:1) <> 'H'
GFCgAC                             and %subst($prte:1:1) <> 'I'
GFCgAC                   exsr      getordhm
GFCgAC                   eval      workcus = %trim(viphm2_ohcusn)
GFCgAC                                         + '  '
GFCgAC                                         + %trim(ohcnam)
GFCgAC                   movea(p)  workcus       a50

GFCaAC                   when      client = gfc
GFCaAC                   eval      workcus = %trim(ohcnam)
GFCaAC                   movea(p)  workcus       a50

520fAC                   when      client = cashwa
520fAC                   eval      workcus = %trim(xohczip)
520faC                                         + '  '
520faC                                         + %trim(xohcnam)
520faC                   movea(p)  workcus       a50

DRYeAC                   when      client = dairyland
DRYeAC                   eval      workcus = %subst(ohmisc:11:10)
DRYeAC                                         + '  '
DRYeAC                                         + %trim(ohcnam)
DRYeAC                   movea(p)  workcus       a50

ISYeMC                   when      client = isupply
ISYeMC                   eval      workcus = %char(ohcust)
ISYeMC                                         + '  '
ISYeMC                                         + %trim(ohcnam)
ISYeMC                   movea(p)  workcus       a50

730gAC                   when      client = swt
730gAC                             or client = cheney
730gAC                   eval      workcus = %trim(work11a)
730gAC                                         + '  '
730gAC                                         + %trim(xohcnam)
730gAC                   movea(p)  workcus       a50

520fAC                   other
520fAC                   eval      workcus = %editc(ohcust:'4')
520faC                                         + '  '
520fAC                                         + %trim(ohcnam)
520faC                   movea(p)  workcus       a50
520fAC                   endsl
520faC                   endif
520faC                   exsr      filchr
     *
530dA*  Unique piece number
530dA*    @VAR = 187
530dAC                   when      @var = 187
530dAC                   if        $pcmd = '*TEST2  '
530dAC                   movea     lfvdta        a50
530dAC                   else
530dAC                   move      unqpiece#     temp5a
530eMC                   eval      worklbl = $prtid + temp5a
530dAC                   movea(p)  worklbl       a50
530dAC                   endif
530dAC                   exsr      filchr
     *
DRYhA*  Brand
DRYhA*    @VAR = 188
DRYhAC                   when      @var = 188
DRYhAC                   eval      zffnam = 'Brand'
DRYhAC                   eval      work17a = *blanks
DRYhAC                   if        $pcmd = '*TEST2  '
DRYhAC                   movea     lfvdta        a50
DRYhAC                   else
DRYhAC                   if        imbrnd <> *blanks
DRYhAC                   eval      work17a = 'Brand: ' + %trim(imbrnd)
DRYhAC                   movea(p)  work17a       a50
DRYhAC                   endif
DRYhAC                   endif
DRYhAC                   exsr      filchr
     *
CBIaA*  Price for Breakers
CBIaAC                   when      @var = 189
CBIaAC                   if        $pcmd = '*TEST2  '
CBIaAC                   movea     lfvdta        a50
CBIaAC                   else
CBIaAC                   movea(p)  t#brkr        a50
CBIaAC                   endif
CBIaAC                   exsr      filchr
     *
     *  Generic 5-Char field
     *    @VAR = 305
JORaAC                   when      @var = 305
     C                   eval      zffnam = 'GEN305M'
     C                   select
     C                   when      client = jordanos
     C                   if        dssub = 'Y'
     C                   movea(p)  '*SUB*'       a50
     C                   else
     C                   movea(p)  '*NO*'        a50
     C                   endif
640aAC                   other
640aAC                   movea(p)  ' '           a50
     C                   endsl
     C                   exsr      filchr
640eA*
640eA*  Generic 5-Char field - CTW deal code
640eA*    @VAR = 306
640eAC                   when      @var = 306
640eAC                   eval      zffnam = 'DEALCode'
640eAC                   select
640eAC                   when      client = citywho
640eAC                   movea(p)  dealcode      a50
CWDdAC                   when      client = cashwa
CWDdAC                   eval      alpha5 = %trim(%editc(@pal#:'4'))
CWDdAC                   movea     alpha5        a50
DRY AC                   when      client = dairyland
DRY AC                   eval      zffnam = 'Truck#'
DRY AC                   if        $pcmd = '*TEST2  '
DRY AC                   movea     lfvdta        a50
DRY AC                   else
DRY AC                   movea(p)  dryhm1_trkid  a50
DRY AC                   endif
640eAC                   other
640eAC                   movea(p)  *blanks       a50
640eAC                   endsl
640eAC                   exsr      filchr
640eA*
640eA*  Generic 5-Char field - State Jurisdiction code
640eA*    @VAR = 307
640eAC                   when      @var = 307
640eAC                   eval      zffnam = 'STATECD'
640eAC                   select
640eAC                   when      client = citywho
640eAC                   movea(p)  statejurcode  a50
640eAC                   exsr      filchr
cwdjAC                   when      client = cashwa
cwdjAC                   eval      zffnam = 'QOH    '
cwduD ***                z-add     cwddm2_qoh    $nanum
cwduMC                   z-add     cwddm1_qoh    $nanum
cwdjAC                   eval      $nadec = 0
cwdjAC                   exsr      filnum
640eAC                   other
640eAC                   movea(p)  *blanks       a50
640eAC                   exsr      filchr
640eAC                   endsl
640eA*
640eA*  Generic 5-Char field - County Jurisdiction code
FRFdA*                       - Load number
640eA*    @VAR = 308
640eAC                   when      @var = 308
FRFdAC                   if        $pcmd = '*TEST2  '
FRFdAC                   movea     lfvdta        a50
FRFdAC                   exsr      filchr
FRFdAC                   else
640eAC                   eval      zffnam = 'COUNTYCD'
640eAC                   select
640eAC                   when      client = citywho
640eAC                   movea(p)  countyjurcode a50
640eAC                   exsr      filchr

cwdkAC                   when      client = cashwa
cwdkAC                   eval      zffnam = 'QOH ea '
cwduD ***                z-add     cwddm2_eqoh   $nanum
cwduMC                   z-add     cwddm1_eqoh   $nanum
cwdkAC                   eval      $nadec = 0
cwdkAC                   exsr      filnum

FRFdAC                   when      client = frf
FRFdAC                   eval      zffnam = 'Load#'
FRFdAC                   movea(p)  work3a        a50
FRFdAC                   exsr      filchr

640eAC                   other
640eAC                   movea(p)  *blanks       a50
640eAC                   exsr      filchr
640eAC                   endsl
FRFdAC                   endif
     *
640eA*  Generic 5-Char field - City Jurisdiction code
640eA*    @VAR = 309
640eAC                   when      @var = 309
640eAC                   eval      zffnam = 'CITYCD'
640eAC                   select
640eAC                   when      client = citywho
640eAC                   movea(p)  cityjurcode   a50
640eAC                   other
640eAC                   movea(p)  *blanks       a50
640eAC                   endsl
640eAC                   exsr      filchr
CPCbA*
CPCbA*  Generic 10-Char field
CPCbA*    @VAR = 310
CPCbAC                   when      @var = 310
CPCbAC                   eval      zffnam = 'ChemCde'
CPCbAC                   if        $pcmd = '*TEST2  '
CPCbAC                   movea     lfvdta        A50
CPCbAC                   else
CBSuAC                   select
CBSuAC                   when      client = cheney
CBSuAC                   move      @plid         $nanum
CBSuA*   Pallet ID barcode
CBSuA*    @VAR = 310
CBSuA*     Adds 2 special characters to front of pallet id.
CBSuA*     *** The temp7a formating should be identical to
CBSuA*     *** what is done in variable 60 above.
CBSuA*  Move char 2 & 3 of route to beginning of pallet id.
CBSuAC                   if        cliloc = cbiriv
CBSuAC                             or cliloc = cbiocl
CBSuAC                   if        kyfmt = 'BIGPALCB'
CBSpAC                             or kyfmt = 'BIGPALC2'
CB2bMC                   eval      temp2a = %subst($prte:3:2)
CBSuAC                   movel     temp2a        temp7a
CBSuAC                   endif
CBSuAC                   endif
CBSuAC                   if        cliloc = cbiocl
CBSuAC                   movea(p)  temp7a        a50
CBSuAC                   eval      @len = 7
CBSuAC                   else
CBSuAC                   eval      temp9a = cbiPrefix + temp7a
CBSuAC                   movea(p)  temp9a        a50
CBSuAC                   eval      @len = 9
CBSuAC                   endif
CBSuAC                   other
CPCbAC                   movea(p)  printcolor    a50
CBSuAC                   endsl
CPCbAC                   endif
CPCbAC                   exsr      filchr
DRYfA*
DRYfA*  Delivery Date USA Format @VAR311
DRYfA*
DRYfAC                   when      @var = 311
     C                   eval      zffnam = 'DelDate'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        A50
     C                   else
     C                   movea(p)  deliverydate2 a50
     C                   endif
     C                   exsr      filchr
640rA *
640rA *  Generic 10-Char field
640rA *    @VAR = 313
640rAC                   when      @var = 313
640rAC                   select
640rAC                   when      client = ifd
640rAC                             or client = gfc
SFGqAC                             or client = sgc
HMWcAC                             or client = hmwagner
SVLbAC                             or client = saval
640rAC                   eval      zffnam = 'Brand'
640rAC                   movea(p)  imbrnd        a50
BIRbAC                   when      client = birite
BIRbAC                   movea(p)  t#brnd        a50
640rAC                   other
640rAC                   eval      zffnam = *blanks
640rAC                   movea(p)  *blanks       a50
640rAC                   endsl
640rAC                   exsr      filchr
520eA*
520eA*  Create Combined Qty field.
520eA*    @VAR = 315
520eAC                   when      @var = 315
520eAC                   eval      zffnam = 'Qty'
520eAC                   if        $pcmd = '*TEST2  '
520eAC                   movea     lfvdta        A50
520eAC                   else

520iAC                   movea(p)  *blanks       A50
520iAC                   eval      cwdqtyfld = *blanks
520iAC                   select
SVLjAC                   when      client = saval
SVLjAC                             and lbutyp <> 'N'
SVLjAC                   eval      cwdqtyfld = %editc(@qty1:'4')
SVLjAC                                         + ' of '
SVLjAC                                         + %trim(%editc(@qty2:'4'))
SVLjAC                                         + ' '
SVLjAC                                         + %trim(umshrt)
GFCaAC                   when      kyfmt = 'BULK  '
GFCaAC                             and client = gfc
GFCaAC                   eval      cwdqtyfld = 'BULK'
GFCaAC                                         + ' '
GFCaAC                                         + %trim(%editc(@qty2:'4'))
GFCaA *
GFCaA *   Center report title.
GFCaA *
GFCaAC                   eval      $pstr = cwdqtyfld
GFCaAC                   call      'CENTER'
GFCaAC                   parm                    $pstr
GFCaAC                   parm      15            $plen
GFCaAC                   movel     $pstr         cwdqtyfld

MJKgAC                   when      kyfmt = 'BULK  '
MJKgAC                             and client = mjkellner
MJKgAC                   eval      cwdqtyfld = 'BULK'
MJKgAC                                         + ' '
MJKgAC                                         + %trim(%editc(@qty2:'4'))

DRYaAC                   when      kyfmt <> 'PICK'
DRYaAC                             and client = dairyland
DRYaAC                   eval      cwdqtyfld = %trim(%editc(@qty1:'4'))
DRYaAC                                         + ' of '
DRYaAC                                         + %trim(%editc(@qty2:'4'))

520iAC                   when      kyfmt = 'BULK  '
520iAC                   eval      cwdqtyfld = 'BULK'
520iAC                                         + ' '
520iAC                                         + %trim(%editc(@qty2:'4'))
640nAC                                         + ' '
640nAC                                         + %trim(umshrt)
GFCaAC                   when      combo = *on
GFCaAC                             and client = gfc
GFCaAC                   eval      cwdqtyfld = 'COMBO'
GFCaAC                                         + ' '
GFCaAC                                         + %trim(%editc(@qty2:'4'))
GFCaA *
GFCaA *   Center report title.
GFCaA *
GFCaAC                   eval      $pstr = cwdqtyfld
GFCaAC                   call      'CENTER'
GFCaAC                   parm                    $pstr
GFCaAC                   parm      15            $plen
GFCaAC                   movel     $pstr         cwdqtyfld

650lAC                   when      combo = *on
650lAC                             and client = fischerfoods
650lAC                   eval      cwdqtyfld = 'COMBO'
650lAC                                         + ' '
650lAC                                         + %trim(%editc(@qty2:'4'))
650lA *
650lA *   Center report title.
650lA *
650lAC                   eval      $pstr = cwdqtyfld
650lAC                   call      'CENTER'
650lAC                   parm                    $pstr
650lAC                   parm      15            $plen
650lAC                   movel     $pstr         cwdqtyfld

NCSeAC                   when      combo = *on
NCSaAC                             and client = nicholas
NCShD ***                eval      cwdqtyfld = 'MULTI'
NCShMC                   eval      cwdqtyfld = '*MULTI'
NCSeAC                                         + ' '
NCSeAC                                         + %trim(%editc(@qty2:'4'))
NCShAC                                         + '*'
SFGrAC                   when      combo = *on
SFGrAC                             and client = SGC
SFGrAC                   eval      cwdqtyfld = 'COMBO'
SFGrAC                                         + ' '
SFGrAC                                         + %trim(%editc(@qty2:'4'))
SFGrAC                                         + ' of '
SFGrAC                                         + %trim(%editc(@qty2:'4'))

MJKgMC                   when      combo = *on
MJKgAC                             and client = mjkellner
MJKgAC                   eval      cwdqtyfld = '#'
MJKgAC                                         + ' '
MJKgAC                                         + %trim(%editc(@qty2:'4'))
MJKgA *
MJKgA *   Center report title.
MJKgA *
MJKgAC                   eval      $pstr = cwdqtyfld
MJKgAC                   call      'CENTER'
MJKgAC                   parm                    $pstr
MJKgAC                   parm      15            $plen
MJKgAC                   movel     $pstr         cwdqtyfld

520hMC                   when      combo = *on
CLDsAC                             and client = cityline
CLDsAC                   eval      cwdqtyfld = %trim(%editc(@qty2:'4'))
CLDsAC                                         + ' of '
CLDsAC                                         + %trim(%editc(@qty2:'4'))
CLDsAC                                         + ' '
CLDsAC                                         + %trim(umshrt)

520hMC                   when      combo = *on
520eAC                   eval      cwdqtyfld = 'COMBO'
520eAC                                         + ' '
520eAC                                         + %trim(%editc(@qty2:'4'))
640gAC                                         + ' '
640gAC                                         + %trim(umshrt)
GFCaAC                   when      client = gfc
GFCaAC                   eval      cwdqtyfld = %trim(%editc(@qty1:'4'))
GFCaAC                                         + ' of '
GFCaAC                                         + %trim(%editc(@qty2:'4'))
GFCaA *
GFCaA *   Center report title.
GFCaA *
GFCaAC                   eval      $pstr = cwdqtyfld
GFCaAC                   call      'CENTER'
GFCaAC                   parm                    $pstr
GFCaAC                   parm      15            $plen
GFCaAC                   movel     $pstr         cwdqtyfld

MJKeAC                   when      client = mjkellner
MJKeAC                   eval      cwdqtyfld = %trim(%editc(@qty1:'4'))
MJKeAC                                         + ' of '
MJKeAC                                         + %trim(%editc(@qty2:'4'))

GFSbAC                   when      client = getfresh
GFSbAC                             and itcwgt = 'Y'
GFSbAC                             and opcwgt <> 0
     C                   eval      cwdqtyfld = %trim(%editc(@qty1:'4'))
     C                                         + ' of '
     C                                         + %trim(%editc(@qty2:'4'))
     C                                         + '  '
     C                                         + %trim('CS')

GFSbAC                   when      client = getfresh
520eAC                   eval      cwdqtyfld = %trim(%editc(@qty1:'4'))
520eAC                                         + ' of '
520eAC                                         + %trim(%editc(@qty2:'4'))
FSHaAC                                         + '  '
FSHaAC                                         + %trim(umshrt)

520iMC                   other
520eAC                   eval      cwdqtyfld = %trim(%editc(@qty1:'4'))
520eAC                                         + ' of '
520eAC                                         + %trim(%editc(@qty2:'4'))
FSHaAC                                         + ' '
FSHaAC                                         + %trim(umshrt)
520iMC                   endsl
520eAC                   movea(p)  cwdqtyfld     a50
520eAC                   endif
520eAC                   EXSR      FILCHR
640eA*
640eA*  Generic 15-Char field - State Jurisdiction name
640eA*    @VAR = 316
640eAC                   when      @var = 316
640eAC                   eval      zffnam = 'STATENM'
640eAC                   select
640eAC                   when      client = citywho
640eAC                   movea(p)  statejurname  a50
640eAC                   when      client = silberman
640eAC                   movea(p)  statejurname  a50
640eAC                   other
640eAC                   movea(p)  *blanks       a50
640eAC                   endsl
640eAC                   exsr      filchr
640eA*
640eA*  Generic 15-Char field - County Jurisdiction name
640eA*    @VAR = 317
640eAC                   when      @var = 317
640eAC                   eval      zffnam = 'COUNTYNM'
640eAC                   select
640eAC                   when      client = citywho
640eAC                   movea(p)  countyjurname a50
640eAC                   other
640eAC                   movea(p)  *blanks       a50
640eAC                   endsl
640eAC                   exsr      filchr
640eA*
640eA*  Generic 15-Char field - City Jurisdiction name
640eA*    @VAR = 318
640eAC                   when      @var = 318
640eAC                   eval      zffnam = 'CITYNM'
640eA*
640eAC                   select
640eAC                   when      client = citywho
640eAC                             and  kyfmt = 'PICK2 '
640eAC                             and  recapflag = 'Y'
640eAC                   movea(p)  recapjurname1 a50
640eAC                   when      client = citywho
640eAC                             and  kyfmt = 'PICK2 '
640eAC                             and  recapflag <> 'Y'
640eAC                   movea(p)  *blanks       a50
640eAC                   when      client = citywho
640eAC                             and  kyfmt <> 'PICK2 '
640eAC                   movea(p)  cityjurname   a50
640eAC                   other
640eAC                   movea(p)  *blanks       a50
640eAC                   endsl
640eAC                   exsr      filchr
640eA*
640eA*  Generic 15-Char field - Recap Jurisdiction name
640eA*    @VAR = 319
640eAC                   when      @var = 319
640eAC                   eval      zffnam = 'CITYNM'
640eAC                   select
640eAC                   when      client = citywho
640eAC                             and  kyfmt = 'PICK2 '
640eAC                             and  recapflag = 'Y'
640eMC                   movea(p)  recapjurname2 a50
640eAC                   other
640eAC                   movea(p)  *blanks       a50
640eAC                   endsl
640eAC                   exsr      filchr
     *
NCSbA*  Vendor name
NCSbA*    @VAR = 327
NCSbAC                   when      @var = 327
NCSbAC                   eval      zffnam = 'V Name'
NCSbAC                   if        $pcmd = '*TEST2  '
NCSbAC                   movea     lfvdta        a50
NCSbAC                   else
NCSbMC                   movea(p)  wkvnam        a50
NCSbAC                   endif
NCSbAC                   exsr      filchr
DRYfA*
DRYfA*  Method of Delivery @var330
DRYfA*
DRYfAC                   when      @var = 330
     C                   eval      zffnam = 'MOD   '
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  methodofdlvry a50
     C                   endif
     C                   exsr      filchr
ctwaA*
ctwaA*  Generic 50-Char field
ctwaA*    @VAR = 350
ctwaAC                   when      @var = 350

ctwaAC                   if        client = citywho
ctwaAC                   eval      retline1 = *blanks
ctwaAC                   exsr      zzline14up
ctwaAC                   endif

ctwaAC                   if        $pcmd = '*TEST2  '
ctwaAC                   movea     lfvdta        a50
ctwaAC                   else
ctwaAC                   movea(p)  retline1      a50
ctwaAC                   endif

ctwaAC                   select
ctwaAC                   when      retailrows = w1pick
ctwaAC                             and retailleft = *zeros
ctwaAC                   other
ctwaAC                   exsr      filchr
ctwaAC                   endsl
ctwaA*
ctwaA*  Generic 50-Char field
ctwaA*    @VAR = 351
ctwaAC                   when      @var = 351

ctwaAC                   if        client = citywho
ctwaAC                   eval      retline2 = *blanks
ctwaAC                   exsr      zzline24up
ctwaAC                   endif

ctwaAC                   if        $pcmd = '*TEST2  '
ctwaAC                   movea     lfvdta        a50
ctwaAC                   else
ctwaAC                   movea(p)  retline2      a50
ctwaAC                   endif

ctwaAC                   select
ctwaAC                   when      retailrows = w1pick
ctwaAC                             and retailleft = *zeros
ctwaAC                   other
ctwaAC                   exsr      filchr
ctwaAC                   endsl
ctwaA*
ctwaA*  Generic 50-Char field
ctwaA*    @VAR = 352
ctwaAC                   when      @var = 352

ctwaAC                   if        client = citywho
ctwaAC                   eval      retline3 = *blanks
ctwaAC                   exsr      zzline34up
ctwaAC                   endif

ctwaAC                   if        $pcmd = '*TEST2  '
ctwaAC                   movea     lfvdta        a50
ctwaAC                   else
ctwaAC                   movea(p)  retline3      a50
ctwaAC                   endif

ctwaAC                   select
ctwaAC                   when      retailrows = w1pick
ctwaAC                             and retailleft = *zeros
ctwaAC                   other
ctwaAC                   exsr      filchr
ctwaAC                   endsl
ctwaA*
ctwaA*  Generic 50-Char field
ctwaA*    @VAR = 353
ctwaAC                   when      @var = 353

ctwaAC                   if        client = citywho
ctwaAC                   eval      retline4 = *blanks
ctwaAC                   exsr      zzline44up
ctwaAC                   endif

ctwaAC                   eval      retline3 = *blanks
ctwaAC                   if        $pcmd = '*TEST2  '
ctwaAC                   movea     lfvdta        a50
ctwaAC                   else
ctwaAC                   movea(p)  retline4      a50
ctwaAC                   endif

ctwaAC                   select
ctwaAC                   when      retailrows = w1pick
ctwaAC                             and retailleft = *zeros
ctwaAC                   other
ctwaAC                   exsr      filchr
ctwaAC                   endsl
ctwaA*
ctwaA*  Generic 50-Char field
ctwaA*    @VAR = 354
ctwaAC                   when      @var = 354

ctwaAC                   if        client = citywho
ctwaAC                   eval      zffnam = 'Rte/Stop'
ctwaAC                   eval      retlot1 = 'RTE:' + $prte
ctwaAC                                              + '/'
ctwaAC                                              + %char(lbstop)
ctwaAC                   endif

ctwaAC                   if        $pcmd = '*TEST2  '
ctwaAC                   movea     lfvdta        a50
ctwaAC                   else
ctwaAC                   movea(p)  retlot1       a50
ctwaAC                   endif
ctwaAC                   exsr      filchr
ctwaA*
ctwaA*  Generic 50-Char field
ctwaA*    @VAR = 355
ctwaAC                   when      @var = 355

ctwaAC                   if        client = citywho
ctwaAC                   eval      zffnam = 'Item/Ord'
ctwaAC                   eval      temp7a = %char(ohcord)
ctwaAC                   eval      retlot2 = %trim(item) + ' ' +
ctwaAC                                       %trim(lbitem) + ' ' +
ctwaAC                                       %trim(order) + ' ' +
ctwaAC                                       %trim(temp7a)
ctwaAC                   endif

ctwaAC                   if        $pcmd = '*TEST2  '
ctwaAC                   movea     lfvdta        a50
ctwaAC                   else
ctwaAC                   movea(p)  retlot2       a50
ctwaAC                   endif
ctwaAC                   exsr      filchr
ctwaA*
ctwaA*  Generic 50-Char field
ctwaA*    @VAR = 356
ctwaAC                   when      @var = 356

ctwaAC                   if        client = citywho
ctwaAC                   eval      zffnam = 'Lot/Qty'
ctwaAC                   eval      temp5a = %char(lbqpck)
ctwaAC                   eval      retlot3 = Lot + Lot25
ctwaAC                                           + ' '
ctwaAC                                           + quantity
ctwaAC                                           + ' '
ctwaAC                                           + %trim(temp5a)
ctwaAC                   endif

ctwaAC                   if        $pcmd = '*TEST2  '
ctwaAC                   movea     lfvdta        a50
ctwaAC                   else
ctwaAC                   movea(p)  retlot3       a50
ctwaAC                   endif
ctwaAC                   exsr      filchr
ctwaA*
ctwaA*  Generic 50-Char field
ctwaA*    @VAR = 357
ctwaAC                   when      @var = 357

ctwaAC                   if        client = citywho
ctwaAC                   eval      retlot4 = *blanks
ctwaAC                   endif

ctwaAC                   if        $pcmd = '*TEST2  '
ctwaAC                   movea     lfvdta        a50
ctwaAC                   else
ctwaAC                   movea(p)  retlot4       a50
ctwaAC                   endif
ctwaAC                   exsr      filchr
GLPdA*
GLPdA*  Heavy item alet
GLPdA*    @VAR=359
GLPdAC                   when      @var = 359
     C                   eval      zffnam = 'Heavy Item'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        A50
     C                   else
     C                   select
     C                   when      lbswgt >= 30
     C                   movea(p)  @heavy        a50
     C                   other
     C                   movea(p)  *blanks       a50
     C                   endsl
     C                   endif
     C                   exsr      filchr
700kA*
700kA*  Voice id
700kA*    @VAR=367
700kAC                   when      @var = 367
     C                   eval      zffnam = 'Voice id'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        A50
     C                   else
     C                   endif
YH2dA*
YH2dA*  LIFO Flag
YH2dA*    @VAR=375
YH2dAC                   when      @var = 375
     C                   eval      zffnam = 'Lifo Flag'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        A50
     C                   else
     C                   select
     C                   when      rtxdm2_omlifo = 'Y'
     C                   movea(p)  'L'           a50
     C                   other
     C                   movea(p)  *blanks       a50
     C                   endsl
     C                   endif
     C                   exsr      filchr
cwdrA*
cwdrA*  Generic 5-Char field client id
cwdrA*    @VAR = 405
cwdrAC                   when      @var = 405
cwdrAC                   eval      zffnam = 'Client '
cwdrAC                   select
cwdrAC                   when      cliloc = 'ABERDEEN'
cwdrAC                   movea(p)  'A'           a50
cwdrAC                   when      cliloc = 'KEARNEY '
cwdrAC                   movea(p)  'K'           a50
cwdrAC                   when      cliloc = 'LINCOLN '
cwdrAC                   movea(p)  'L'           a50
cwdrAC                   endsl
cwdrAC                   exsr      filchr
650gA*
650gA*  Audit word
650gA*    @VAR=406
650gAC                   when      @var = 406
     C                   eval      zffnam = 'Audit Word'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        A50
     C                   else
     C                   select
     C                   when      auditflag = 'Y'
     C                   movea(p)  @Audit        a50
     C                   other
     C                   movea(p)  *blanks       a50
     C                   endsl
     C                   endif
     C                   exsr      filchr
530 A*
530 A*  Slot
530 A*    @VAR=407
530 AC                   when      @var = 407
530 AC                   eval      zffnam = 'Slot'
530 AC                   if        $pcmd = '*TEST2  '
530 AC                   movea     lfvdta        A50
530 AC                   else
ctwaAC                   select
ctwaAC                   when      client = citywho
ctwaAC                   eval      zffnam = 'RTLPRICE'
ctwhMC                   movea(p)  retailprice   a50
ctwaAC                   other
530 AC                   eval      work7a = lbaisl
530 AC                                      + %editc(lbloc:'X')
530 AC                                      + '-'
530 AC                   movea     work7a        a50
ctwaAC                   endsl
530 AC                   endif
530 AC                   exsr      filchr
640aA*
640cA*  Generic 8-Char field
640cA*    @VAR = 408
640cAC                   when      @var = 408
640cAC                   select
640cAC                   when      client = citywho
640cAC                             or client = silberman
cwdgAC                             or client = cashwa
640cAC                   eval      zffnam = 'Rte/Stop'
640cAC                   eval      temp8 = $prte + '/' + %char(lbstop)
640cAC                   movea(p)  temp8         a50
640cAC                   endsl
640cAC                   exsr      filchr
640aA*
640cA*  Generic 9-Char field
640cA*    @VAR = 409
640cAC                   when      @var = 409
640cAC                   select
640cAC                   when      client = citywho
640cAC                             or client = silberman
cwdlAC                             or client = cashwa
640cAC                   eval      zffnam = 'Rte/Stop'
640cAC                   eval      temp9 = $prte + '/' + extstop
640cAC                   movea(p)  temp9         a50
640cAC                   endsl
640cAC                   exsr      filchr
WIFaA*
WIFaA*  Williams
WIFaA*    @VAR=411
WIFaAC                   when      @var = 411
     C                   eval      zffnam = 'Wood Pallet'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        A50
     C                   else
     C                   movea(p)  woodpalletvar a50
     C                   endif
     C                   exsr      filchr
NCSgA*
NCSgA*  Customer P/O field.
NCSgA*    @VAR = 415
NCSgAC                   when      @var = 415
NCSgAC                   eval      zffnam = 'P/O'
NCSgAC                   if        $pcmd = '*TEST2  '
NCSgAC                   movea     lfvdta        A50
NCSgAC                   else
NCSgAC                   movea(p)  ohcpo         a50
NCSgAC                   endif
NCSgAC                   exsr      filchr
     *
BIRa *  Catch weight entry field 1 - BiRite
     *    @VAR = 416
BIRa C                   when      @var = 416
BIRa C                   if        $pcmd = '*TEST2  '
BIRa C                   movea     lfvdta        a50
BIRa C                   else
BIRa C                   movea(p)  cwent1        a50
BIRa C                   endif
BIRa C                   exsr      filchr
     *
BIRa *  Catch weight entry field 2 - BiRite
     *    @VAR = 417
BIRa C                   when      @var = 417
BIRa C                   if        $pcmd = '*TEST2  '
BIRa C                   movea     lfvdta        a50
BIRa C                   else
BIRa C                   movea(p)  cwent2        a50
BIRa C                   endif
BIRa C                   exsr      filchr
     *
BIRa *  Catch weight entry field 3 - BiRite
     *    @VAR = 418
BIRa C                   when      @var = 418
BIRa C                   if        $pcmd = '*TEST2  '
BIRa C                   movea     lfvdta        a50
BIRa C                   else
BIRa C                   movea(p)  cwent3        a50
BIRa C                   endif
BIRa C                   exsr      filchr
     *
BIRa *  Catch weight entry field 4 - BiRite
     *    @VAR = 419
BIRa C                   when      @var = 419
BIRa C                   if        $pcmd = '*TEST2  '
BIRa C                   movea     lfvdta        a50
BIRa C                   else
BIRa C                   movea(p)  cwent4        a50
BIRa C                   endif
BIRa C                   exsr      filchr
     *
BIRa *  Catch weight entry field 5 - BiRite
     *    @VAR = 420
BIRa C                   when      @var = 420
BIRa C                   if        $pcmd = '*TEST2  '
BIRa C                   movea     lfvdta        a50
BIRa C                   else
BIRa C                   movea(p)  cwent5        a50
BIRa C                   endif
BIRa C                   exsr      filchr
     *
BIRd *  Special instruction - BiRite only
     *    @VAR = 421
BIRa C                   when      @var = 421
BIRa C                   if        $pcmd = '*TEST2  '
BIRa C                   movea     lfvdta        a50
BIRa C                   else
BIRa C                   movea(p)  sp1           a50
BIRa C                   endif
BIRa C                   exsr      filchr
     *
BIRd *  Special instruction - BiRite only
     *    @VAR = 422
BIRa C                   when      @var = 422
BIRa C                   if        $pcmd = '*TEST2  '
BIRa C                   movea     lfvdta        a50
BIRa C                   else
BIRa C                   movea(p)  sp2           a50
BIRa C                   endif
BIRa C                   exsr      filchr
     *
BIRd *  Special instruction - BiRite only
     *    @VAR = 423
BIRa C                   when      @var = 423
BIRa C                   if        $pcmd = '*TEST2  '
BIRa C                   movea     lfvdta        a50
BIRa C                   else
BIRa C                   movea(p)  sp3           a50
BIRa C                   endif
BIRa C                   exsr      filchr
     *
BIRd *  Special instruction - BiRite only
     *    @VAR = 424
BIRa C                   when      @var = 424
BIRa C                   if        $pcmd = '*TEST2  '
BIRa C                   movea     lfvdta        a50
BIRa C                   else
DRYfAC                   select
DRYfAC                   when      client = dairyland
DRYfAC                   movea(p)  dryhm1_voyid  a50
DRYfAC                   other
BIRa C                   movea(p)  sp4           a50
DRYfAC                   endsl
BIRa C                   endif
BIRa C                   exsr      filchr
     *
650eA*  Customer Purchase order
650eA*    @VAR = 451
650eAC                   when      @var = 451
650eAC                   eval      zffnam = 'Cus PO#'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  xohcpo        a50
     C                   endif
     C                   exsr      filchr
CSPlA*   Pallet ID
CSPlA*    @VAR = 455
     C                   when      @var = 455
     C                   eval      zffnam = 'RTEID/PLID'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
     C                   move      @plid         $nanum
     C                   endif
     C                   eval      $nadec = 0
     C                   move      @plid         temp5a
     *
     *   Move route id to beginning of pallet id.
     C                   eval      temp10a = $prtid + temp5a
     C                   movea(p)  temp10a       a50
     C                   exsr      filchr
730fA*   Pallet ID
730fA*    @VAR = 461
     C                   when      @var = 461
     C                   eval      zffnam = 'rrrrppppp'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         $nanum
     C                   else
     C                   move      @plid         $nanum
     C                   endif
     C                   eval      $nadec = 0
     C                   move      @plid         temp5a
     *
     *   Move route id to beginning of pallet id.
     *     var 455 doesn't cut off 1st # of rtid
     C                   eval      temp9 = %subst($prtid:2:4) + temp5a
     C                   movea(p)  temp9         a50
     C                   exsr      filchr
     *
     C                   endsl
     *
510bA*   Write ZBRLOGF record.
510bAC*
510bAC                   if        logzebra
750fAC                             and fillb1pass = 1
510bAC                   write(e)  zfrec
510bAC                   endif
     *
     C     endfi2        endsr
     *----------------------------------------------------------------
     *
CBImA*  ZZ999  Format slot number for 999 items.
     *
CBImAC     zz999         begsr

CB3l  /free
CB3l
CB3l    chain ($pwhse:lbitem) itemmsc;
        if not %Found(itemmsc);
          imbnbr = *zeros;
CB3l    endif;

        select;
CB2xA     when dsdisp > *blanks and
CB2xA          cliloc = cbigo;

CB2xA       if itwhdp = 'DRY' and
CB2xA          lbdisp <> 'BF-40-21';
CB2xA         dsdisp = 'BF-40-21';
CB2xA       endif;

CB2xA       if itwhdp = 'FRZ' and
CB2xA          lbdisp <> 'DA-66-21';
CB2xA         dsdisp = 'DA-66-21';
CB2xA       endif;

CB2xA       if itwhdp = 'CLR' and
CB2xA          lbdisp <> 'CC-36-31';
CB2xA         dsdisp = 'CC-36-31';
CB2xA       endif;

CB2xA     when dsdisp > *blanks and
CB2xA          cliloc = cbigr;

CB2xA       if itwhdp = 'DRY' and
CB2xA          lbdisp <> 'GD-21-11';
CB2xA         dsdisp = 'GD-21-11';
CB2xA       endif;

CB2xA       if itwhdp = 'FRZ' and
CB2xA          lbdisp <> 'KC-39-21';
CB2xA         dsdisp = 'KC-39-21';
CB2xA       endif;

CB2xA       if itwhdp = 'CLR' and
CB2xA          lbdisp <> 'JD-40-13';
CB2xA         dsdisp = 'JD-40-13';
CB2xA       endif;

CB2xA     when dsdisp > *blanks and
CB2xA          cliloc = cbist;

CB2xA       if itwhdp = 'DRY' and
CB2xA          lbdisp <> 'TC-07-11';
CB2xA         dsdisp = 'TC-07-11';
CB2xA       endif;

CB2xA       if itwhdp = 'FRZ' and
CB2xA          lbdisp <> 'UD-99-11';
CB2xA         dsdisp = 'UD-99-11';
CB2xA       endif;

CB2xA       if itwhdp = 'CLR' and
CB2xA          lbdisp <> 'SG-99-11';
CB2xA         dsdisp = 'SG-99-11';
CB2xA       endif;

xxxj      when dsdisp > *blanks and
xxxj           cliloc <> cbiriv  or
xxxj           dsdisp > *blanks and
xxxj           cliloc = cbiriv  and
xxxj           lbasl2 = 'OUT';

xxxJJ     // when dsdisp > *blanks;

            if itwhdp = 'DRY' and
               lbaisl <> ' DY' and
               lbloc <> 101;
              dsdisp = 'DY-101-' + itdesg;
            endif;

            if itwhdp = 'FRZ' and
               lbaisl <> ' FY' and
               lbloc <> 262;
              dsdisp = 'FY-262-' + itdesg;
            endif;

            if itwhdp = 'CLR' and
CHYm           lbdisp <> 'CS-225-1';
CHYm           dsdisp = 'CS-225-1';
            endif;

CB2xA     when dsdisp = *blanks and
CB2xA          cliloc = cbigo;

CB2xA       if itwhdp = 'DRY';
CB2xA         dsdisp = 'BF-40-21';
CB2xA       endif;

CB2xA       if itwhdp = 'FRZ';
CB2xA         dsdisp = 'DA-66-21';
CB2xA       endif;

CB2xA       if itwhdp = 'CLR';
CB2xA         dsdisp = 'CC-36-31';
CB2xA       endif;

CB2xA     when dsdisp = *blanks and
CB2xA          cliloc = cbigr;

CB2xA       if itwhdp = 'DRY';
CB2xA         dsdisp = 'GD-21-11';
CB2xA       endif;

CB2xA       if itwhdp = 'FRZ';
CB2xA         dsdisp = 'KC-39-21';
CB2xA       endif;

CB2xA       if        itwhdp = 'CLR';
CB2xA         dsdisp = 'JD-40-13';
CB2xA       endif;

CB2xA     when dsdisp = *blanks and
CB2xA          cliloc = cbist;

CB2xA       if itwhdp = 'DRY';
CB2xA     //  dsdisp = 'TC-07-11';
CB2xA       endif;

CB2xA       if itwhdp = 'FRZ';
CB2xA     //  lbdisp = 'UD-99-11';
CB2xA       endif;

CB2xA       if itwhdp = 'CLR';
CB2xA     //  lbdisp = 'SG-99-11';
CB2xA       endif;

          when dsdisp = *blanks and
               cliloc <> cbiriv;

            if itwhdp = 'DRY';
              dsdisp = 'DY-101-' + itdesg;
            endif;

            if itwhdp = 'FRZ';
              dsdisp = 'FY-262-' + itdesg;
            endif;

            if itwhdp = 'CLR';
CHYm          dsdisp = 'CS-225-' + itdesg;
            endif;

          when dsdisp = *blanks and
          //  cliloc = cbiriv;
xxxj          cliloc = cbiriv and
xxxj          lbasl2 = 'OUT';

            if itwhdp = 'DRY';
              dsdisp = 'DY-101-' + %char(imbnbr);
            endif;

            if itwhdp = 'FRZ';
              dsdisp = 'FY-262-' + %char(imbnbr);
            endif;

            if itwhdp = 'CLR';
              dsdisp = 'CS-225-1';
            endif;

        endsl;

CB3l  /end-free

CBImAC     end999        endsr
     *
     *----------------------------------------------------------------
     *
     *  FILNUM  Fill numeric variable.
     *
     C     filnum        begsr
     *
     *   Format number.
     *
     C                   exsr      editna
     *
     *   Find first character in array string.
     *
     C                   eval      fc = 1
     C                   dou       fc = 13
     C                   if        a12(fc) <> *blank
     C                   leave
     C                   endif
     C                   add       1             fc
     C                   enddo
     *
     *   Move formatted number into output string.
     *
     C                   eval      a50 = *blanks
     C                   eval      y = @len
     *
     *   Added pallet section id to zone merge pallet number.
     *
     C                   if        @var = 39  and
     C                             dszpsi <> ' '
     C                   movel     dszpsi        temp1a
     C                   eval      a50(y) = temp1a
     C                   eval      y = y - 1
     C                   endif
     *
     C                   eval      x = 12
     C                   dou       x = 0  or
     C                             y = 0
     C                   eval      a50(y) = a12(x)
     C                   eval      x = x - 1
     C                   eval      y = y - 1
     C                   enddo
     C                   exsr      filchr
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLASL  Aisle change label.
     *
     C     lblasl        begsr
520kAC                   if        opaisl = 'Y'
520kAC                             or opaisl = ' '
ctwaAC                   select
ctwkAC                   when      cigaretflag
ctwkAC                   eval      kyfmt = *blanks
ctwaAC                   when      tobaccoflag
ctwfD ***                eval      kyfmt = 'TAISLCHG'
ctwfMC                   eval      kyfmt = 'AISLCHG '
ctwaAC                   when      candyflag
ctwfD ***                eval      kyfmt = 'TAISLCHG'
ctwfMC                   eval      kyfmt = 'AISLCHG '
ctwaAC                   when      retailflag
ctwaAC                   eval      kyfmt = 'MAISLCHG'
ctwaAC                   other
     C                   eval      kyfmt = 'AISLCHG '
ctwaAC                   endsl
     C                   exsr      fillb1
520kAC                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLBBK  Begin bulk picks
     *
     C     lblbbk        begsr
     C                   if        $pgen = 1
     C                   eval      zontyp = 'Truck'
     C                   else
     C                   eval      zontyp = 'Stage'
     C                   endif
ctwaAC                   select
ctwkAC                   when      cigaretflag
ctwkAC                   eval      kyfmt = *blanks
ctwaAC                   when      tobaccoflag
ctwfD ***                eval      kyfmt = 'TBEGBLK '
ctwfMC                   eval      kyfmt = 'BEGBLK  '
ctwaAC                   when      candyflag
ctwfD ***                eval      kyfmt = 'TBEGBLK '
ctwfMC                   eval      kyfmt = 'BEGBLK  '
ctwaAC                   when      retailflag
ctwaAC                   eval      kyfmt = 'MBEGBLK '
ctwaAC                   other
     C                   eval      kyfmt = 'BEGBLK  '
ctwaAC                   endsl
     C                   exsr      fillb1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLBRP  Begining of letdowm label.
     *
     C     lblbrp        begsr
     C                   if        $pgen = 1
     C                   eval      zontyp = 'Truck'
     C                   else
     C                   eval      zontyp = 'Stage'
     C                   endif
     C                   eval      kyfmt = 'BEGRPL  '
     C                   exsr      fillb1
     C                   endsr
     *----------------------------------------------------------------
     *
500  *  LBLBR3  Begining of Breakdown replenishments
     *
500  C     lblbr3        begsr
     C                   if        $pgen = 1
     C                   eval      zontyp = 'Truck'
     C                   else
     C                   eval      zontyp = 'Stage'
     C                   endif
     C                   eval      kyfmt = 'BRKDOWNS'
     C                   exsr      fillb1
500  C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLBLK  Bulk pick labels.
     *
     C     lblblk        begsr
     C                   eval      stpcnt = 0
     C                   eval      @qty2 = w1qty
     C                   eval      @pal# = pspal#
ctwaAC                   select
CLDtAC                   when      client = cityline
CLDtAC                             and lbgrp2 = 'W'
CLDtAC                             and extstop = '6  '
CLDtAC                   eval      kyfmt = 'WLBULKA3'

CLDtAC                   when      client = cityline
CLDtAC                             and lbgrp2 = 'W'
CLDtAC                             and extstop <>'6  '
CLDtAC                   eval      kyfmt = 'WLBULKAL'

CLDtAC                   when      client = cityline
CLDtAC                             and extstop = '6  '
CLDtAC                   eval      kyfmt = 'BULK3   '

ctwkAC                   when      cigaretflag
ctwkAC                   eval      kyfmt = *blanks
ctwaAC                   when      tobaccoflag
ctwfD ***                eval      kyfmt = 'TBULK   '
ctwfMC                   eval      kyfmt = 'BULK    '
ctwaAC                   when      candyflag
ctwfD ***                eval      kyfmt = 'TBULK   '
ctwfMC                   eval      kyfmt = 'BULK    '
ctwaAC                   when      retailflag
ctwaAC                   eval      kyfmt = 'MBULK   '
      * readable slot
GFCiAC                   when      client = GFC
GFCiAC                             and opslot <> 'Y'
GFCiAC                   eval      kyfmt = 'BULK    '
      * barcoded slot
GFCiAC                   when      client = GFC
GFCiAC                             and opslot = 'Y'
GFCiAC                   eval      kyfmt = 'BULKB   '

ctwaAC                   other
     C                   eval      kyfmt = 'BULK    '
ctwaAC                   endsl
BIRaAC                   select
BIRaAC                   when      client = birite
BIRaAC                   eval      dsmisc2 = xohmisc
CBIcAC                   when      client = cheney
CBIcAC                   eval      dsmisc = xohmisc
CBIcAC                   eval      dsoitm = odoitm
BIRaAC                   other
ALNaAC                   eval      dsmisc = xohmisc
BIRaAC                   endsl
     *
VIPa C                   eval      lidisp = *blanks
VIPa C                   eval      lidisp = lbdisp
SFGa C                   eval      dinine = linine
VIPa C                   eval      diasle = liasle
VIPa C                   eval      diloc = liloc
VIPa C                   movel     lilvl         dilvl
     *
     C                   exsr      fillb1
     C                   endsr
520iA*----------------------------------------------------------------
520iA*
520iA*  LBLCUT  Send cut mode command.
520iA*
520iAC     lblcut        begsr
     C                   MOVEA(P)  '^XA^MMC^XZ'  A50
     C                   eval      @len = 10
     C                   exsr      filchr
     C                   exsr      print
     C                   endsr
520iA*----------------------------------------------------------------
520iA*
520iA*  LBLTEAR  Send tear-off mode command.
520iA*
520iAC     lbltear       begsr
     C                   MOVEA(P)  '^XA^MMT^XZ'  A50
     C                   eval      @len = 10
     C                   exsr      filchr
     C                   exsr      print
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLCWT  Catch weight labels.
     *
     C     lblcwt        begsr
ctwaAC                   select
DRYaAC                   when      lbutyp = 'N'
DRYaAC                             and client = dairyland
DRYaAC                   eval      kyfmt = 'CACHWT  '

DRYaAC                   when      client = dairyland
DRYaAC                   eval      kyfmt = 'CACHWT2 '

ctwkAC                   when      cigaretflag
ctwkAC                   eval      kyfmt = *blanks
ctwaAC                   when      tobaccoflag
ctwfD ***                eval      kyfmt = 'TCACHWT '
ctwfMC                   eval      kyfmt = 'CACHWT  '
ctwaAC                   when      candyflag
ctwfD ***                eval      kyfmt = 'TCACHWT '
ctwfMC                   eval      kyfmt = 'CACHWT  '
ctwaAC                   when      retailflag
ctwaAC                   eval      kyfmt = 'MCACHWT '
ctwaAC                   other
     C                   eval      kyfmt = 'CACHWT  '
ctwaAC                   endsl
BIRaAC                   select
BIRaAC                   when      client = birite
BIRaAC                   eval      dsmisc2 = ohmisc

CBIcAC                   when      client = cheney
CBIcAC                   eval      dsmisc = ohmisc
CBIcAC                   eval      dsoitm = odoitm

BIRaAC                   other
ALNaAC                   eval      dsmisc = ohmisc
BIRaAC                   endsl
     C                   exsr      fillb1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLCMB  Combined label is next.
     *
     C     lblcmb        begsr
BIRc C                   eval      @qty2 = lbqpck
ctwaAC                   select
GFSgAC                   when      client = getfresh
GFSgAC                             and lbutyp = '1'
GFSgAC                             and itum2  = 'LB'
GFSgAC                             and (itminq = 0
GFSgAC                             or  itminq = 1)

GFSgAC                             or client = getfresh
GFSgAC                             and lbutyp = '2'
GFSgAC                             and itum2  = 'LB'
GFSgAC                             and (itminq = 0
GFSgAC                             or  itminq = 1)
GFSgAC                   leavesr

ctwkAC                   when      cigaretflag
ctwkAC                   eval      kyfmt = *blanks
ctwaAC                   when      tobaccoflag
ctwfD ***                eval      kyfmt = 'TCMBB   '
ctwfMC                   eval      kyfmt = 'CMBB    '
ctwaAC                   when      candyflag
ctwfD ***                eval      kyfmt = 'TCMBB   '
ctwfMC                   eval      kyfmt = 'CMBB    '
ctwaAC                   when      retailflag
ctwaAC                   eval      kyfmt = 'MCMBB   '
ctwaAC                   other
     C                   eval      kyfmt = 'CMBB    '
ctwaAC                   endsl
     C                   exsr      fillb1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLCMA  Combined label is before.
     *
     C     lblcma        begsr
BIRc C                   eval      @qty2 = lbqpck
ctwaAC                   select
GFSgAC                   when      client = getfresh
GFSgAC                             and lbutyp = '1'
GFSgAC                             and itum2  = 'LB'
GFSgAC                             and (itminq = 0
GFSgAC                             or  itminq = 1)

GFSgAC                             or client = getfresh
GFSgAC                             and lbutyp = '2'
GFSgAC                             and itum2  = 'LB'
GFSgAC                             and (itminq = 0
GFSgAC                             or  itminq = 1)
GFSgAC                   leavesr

ctwkAC                   when      cigaretflag
ctwkAC                   eval      kyfmt = *blanks
ctwaAC                   when      tobaccoflag
ctwfD ***                eval      kyfmt = 'TCMBA   '
ctwfMC                   eval      kyfmt = 'CMBA    '
ctwaAC                   when      candyflag
ctwfD ***                eval      kyfmt = 'TCMBA   '
ctwfMC                   eval      kyfmt = 'CMBA    '
ctwaAC                   when      retailflag
ctwaAC                   eval      kyfmt = 'MCMBA   '
ctwaAC                   other
     C                   eval      kyfmt = 'CMBA    '
ctwaAC                   endsl
     C                   exsr      fillb1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLDIS  Discrepancies label.
     *
     C     lbldis        begsr
     C                   eval      kyfmt = 'DISCRP  '
     C                   exsr      fillb1
     C                   endsr
     *----------------------------------------------------------------
     *
CBIdA*  LBMEAT  Meat
     *
CBIdAC     lbmeat        begsr
CHYbAC                   select
CHYbAC                   when      lbwhdp = 'DRY'
CHYbAC                   eval      kyfmt = 'MEATD   '
CHYbAC                   when      lbwhdp = 'FRZ'
CHYbAC                   eval      kyfmt = 'MEATF   '
CHYbAC                   other
CHYbAC                   eval      kyfmt = 'MEATC   '
CHYbAC                   endsl
     C                   exsr      fillb1
CBIdAC                   endsr
CHYbA*----------------------------------------------------------------
CHYbA*
CHYbA*  LBPPCK  Pre-Picks
CHYbA*
CHYbAC     lbppck        begsr
     C                   select
     C                   when      lbwhdp = 'DRY'
     C                   eval      kyfmt = 'PREPCKD '
     C                   when      lbwhdp = 'FRZ'
     C                   eval      kyfmt = 'PREPCKF '
     C                   other
     C                   eval      kyfmt = 'PREPCKC '
     C                   endsl
     C                   exsr      fillb1
     C                   endsr
     *----------------------------------------------------------------
     *
BIRd *  LBLINS  Special instruction.
     *
     C     lblins        begsr
     C                   eval      kyfmt = 'SPCLINST'
     C                   exsr      fillb1
BIRd C                   endsr
510dA*----------------------------------------------------------------
510dA*
510dA*  LBLEND  END label
510dA*
510dAC     lblend        begsr

520iA*  Send cut command just before printing END label

520iAC                   if        opcu1 = 'Y'
520iAC                   exsr      lblcut
520iAC                   endif
520aA
520aA*  Print END label
520aA
ctwaAC                   select
ctwkAC                   when      cigaretflag
ctwkAC                   eval      kyfmt = *blanks
ctwaAC                   when      tobaccoflag
ctwfD ***                eval      kyfmt = 'TEND    '
ctwfMC                   eval      kyfmt = 'END     '
ctwaAC                   when      candyflag
ctwfD ***                eval      kyfmt = 'TEND    '
ctwfMC                   eval      kyfmt = 'END     '
ctwaAC                   when      retailflag
ctwaAC                   eval      kyfmt = 'MEND    '
ctwaAC                   other
     C                   eval      kyfmt = 'END     '
ctwaAC                   endsl
     C                   exsr      fillb1

520iA*  Send tear-off command after printing END label

520iAC                   if        opcu1 = 'Y'
ctwkAC                   if        not cigaretflag
520iAC                   exsr      lbltear
ctwkAC                   endif
520iAC                   endif

cdicA*  Print blanks label

cdieDC*                  if        client = cdijax
cdieMC                   if        client = cdi
cdicAC                   for       cdiPass = 1 to 2
cdicAC                   exsr      lblfiller
cdicAC                   endfor
cdicAC                   endif

     C                   endsr
CDIcA*----------------------------------------------------------------
     *
     *  LBLFILLER  Blanks Label.
     *
     C     lblfiller     begsr

     *  Print blank label

     C                   eval      ohcst = *blanks

     C                   eval      kyfmt = 'FILLER  '
     C                   exsr      fillb1
     C                   endsr
640mA*----------------------------------------------------------------
640mA*
640mA*  LBLPALLET  Pallet label.
640mA*
640mAC     lblpallet     begsr
     *
     C                   if        $pgen = 1
     C                   eval      dtlcnt = 0
     C                   dow       dtlcnt < palcnt
CSPlAC                   select
CSPlAC                   when      client = coastalsunbelt
DRYkAC                             or client = dairyland
700bAC                             or (bigpallabel
700bAC                             and client <> cheney)
CSPlAC                   eval      kyfmt = 'BIGPAL  '
CSPlAC                   other
     C                   eval      kyfmt = 'PALLET  '
CSPlAC                   endsl
     C                   add       1             dtlcnt
     C     dtlcnt        occur     palsum
     C                   eval      @pal# = dsppal
     C                   eval      @plid = dsppli
     C                   eval      @rtid = dsprti
     C                   eval      @stp1 = dsstp1
     C                   eval      @stp2 = dsstp2
     C                   if        dsppal > 0  or
     C                             $pcmd = '*TEST2  '

700kAC                   eval      voiceid = 0
700kAC                   call      @getpltvid
700kAC                   parm      '*VOICEID'    $command
700kAC                   parm                    @plid
700kAC                   parm                    $pwhse
700kAC                   parm                    $prtid
700kAC                   parm                    voiceid

     C                   exsr      fillb1
     C                   endif
     C                   enddo
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  lblPleRePrint
     *
700lAC     lblPltRePrint begsr
     *
700lAC                   select
700lAC                   when      $pcmd = '*RPRTP1'

     * reprint a zone

     C     keyps8        setll     pltsum8
     C                   dow       forevr = forevr
     C     keyps8        reade     pltsum8                                78
     C                   if        %eof(pltsum8)
     C                   leave
     C                   endif

750kAC                   if        tbEnhanced
750kAC                             and psgen = 1
750kAC                             and pstype = 'O'
750kAC                   iter
750kAC                   endif

     C                   if        pspcs = 0
     C                             and pscube = 0
     C                             and psswgt = 0
     C                   iter
     C                   endif


     C                   eval      @pal# = pspal#
     C                   eval      @plid = psplid
     C                   eval      @rtid = psrtid
     C                   eval      dsstp1 = psstp1
     C                   eval      dsstp2 = psstp2
     C                   eval      dsppcs = pspcs
     C                   eval      dspcub = pscube
     C                   eval      lbtrn# = pstrn#
CB3aAC                   if        client = Cheney
CB3aAC                             and (cliloc = cheneyriviera
CB3tAC                               or cliloc = cbist
CB3aAC                               or cliloc = cheneyocala)
CB3a  /free
CB3a
CB3a    chain (pswhse:pstrn#) label90;
CB3a    lbord = x_lbord;
CB3a
CB3a  /end-free
CB3aAC                   exsr      getordh
CB3aAC                   endif

     *       ISY req to print 3 Pallet Labels with BIG print
     *                  everyone else continues to print PALLET
     *
ISYiAC                   select
ISYiAC                   when      client = isupply
ISYiAC                             and $ptruk <> 'WILLCALL'
ISYiAC                   eval      kyfmt = 'PALLET1 '
ISYiAC                   exsr      fillb1
ISYiAC                   eval      kyfmt = 'PALLET2 '
ISYiAC                   exsr      fillb1
ISYiAC                   eval      kyfmt = 'PALLET3 '
ISYiAC                   exsr      fillb1

CB3bAC                   when      client = cheney

CB3bAC                   if        pstruk <> 'PRE-PICK'
CB3bAC                             and pstruk <> 'CONTAINER'
CB3bAC                             and pstruk <> 'MEAT-INSP'
CB3oAC                             or $prte >= '8800 '
CB3oAC                             and $prte <= '8899 '

CB3bAC                   if        psgen = 1
CB3bMC                   eval      kyfmt = 'BIGPAL'
CB3bA*
CB3bA*    Calculate how many extra BIG pallet labels to print.
CB3bAC                   eval      nrbigl = 1
CB3bAC                   select
CB3bAC                   when         $pszon = 'PKCLR '
CB3bAC                             or $pszon = 'PKDRY '
CB3bAC                             or $pszon = 'PKFRZ '

CB3bAC     dsppcs        div(h)    8             nrbigl
CB3bAC                   if        nrbigl <= 0
CB3bAC                   eval      nrbigl = 1
CB3bAC                   endif
CB3bAC                   endsl
CB3bA*
CB3bA*    Loop to print required number of BIG pallet labels.
CB3bAC     1             do        nrbigl
CB3bAC                   exsr      fillb1
CB3bAC                   enddo
CB3bA*
CB3bAC                   else
CB3bAC                   eval      kyfmt = 'BIGPAL2'
CB3bA*
CB3bA*    Calculate how many extra BIG pallet labels to print.
CB3bAC                   eval      nrbigl = 1
CB3bAC                   select
CB3bAC                   when         $pszon = 'PKCLR '
CB3bAC                             or $pszon = 'PKDRY '
CB3bAC                             or $pszon = 'PKFRZ '
CB3bAC     dsppcs        div(h)    8             nrbigl
CB3bAC                   if        nrbigl <= 0
CB3bAC                   eval      nrbigl = 1
CB3bAC                   endif
CB3bAC                   endsl
CB3bA*
CB3bA*    Loop to print required number of BIG pallet labels.
CB3bAC     1             do        nrbigl
CB3bAC                   exsr      fillb1
CB3bAC                   enddo
CB3bA*
CB3bAC                   endif
CB3bAC                   endif
ISYiAC                   other

     C                   if        bigpallabel
     C                   eval      kyfmt = 'BIGPAL  '
     C                   else
     C                   eval      kyfmt = 'PALLET  '
     C                   endif

     C                   exsr      fillb1
ISYiAC                   endsl

     C                   enddo

700lAC                   when      $pcmd = '*RPRTP2'

     * reprint a Pallet by Transaction

     C                   eval      wktran = $ptrn#
     C     keyps12a      setll     pltsum12
     C                   dow       forevr = forevr
     C     keyps12a      reade     pltsum12
     C                   if        %eof(pltsum12)
     C                   leave
     C                   endif

     C                   if        psgen <> 1
     C                   iter
     C                   endif

     C                   if        pspcs = 0
     C                             and pscube = 0
     C                             and psswgt = 0
     C                   iter
     C                   endif

     C                   eval      @pal# = pspal#
     C                   eval      @plid = psplid
     C                   eval      @rtid = psrtid
     C                   eval      dsstp1 = psstp1
     C                   eval      dsstp2 = psstp2
     C                   eval      dsppcs = pspcs
     C                   eval      dspcub = pscube
     C                   eval      lbtrn# = pstrn#
CB3aAC                   if        client = Cheney
CB3aAC                             and (cliloc = cheneyriviera
CB3tAC                               or cliloc = cbist
CB3aAC                               or cliloc = cheneyocala)
CB3a  /free
CB3a
CB3a    chain (pswhse:pstrn#) label90;
CB3a    lbord = x_lbord;
CB3a
CB3a  /end-free
CB3aAC                   exsr      getordh
CB3aAC                   endif

     * I-Supply requires 3 Pallet Labels with BIG print
     * everyone else continues to print 1 Pallet label
     *
     C                   select
     C                   when      client = isupply
     C                             and $ptruk <> 'WILLCALL'
     C                   eval      kyfmt = 'PALLET1 '
     C                   exsr      fillb1
     C                   eval      kyfmt = 'PALLET2 '
     C                   exsr      fillb1
     C                   eval      kyfmt = 'PALLET3 '
     C                   exsr      fillb1

CB3bAC                   when      client = cheney

CB3bAC                   if        pstruk <> 'PRE-PICK'
CB3bAC                             and pstruk <> 'CONTAINER'
CB3bAC                             and pstruk <> 'MEAT-INSP'
CB3oAC                             or $prte >= '8800 '
CB3oAC                             and $prte <= '8899 '

CB3bAC                   if        psgen = 1
CB3bMC                   eval      kyfmt = 'BIGPAL'
CB3bA*
CB3bA*    Calculate how many extra BIG pallet labels to print.
CB3bAC                   eval      nrbigl = 1
CB3bAC                   select
CB3bAC                   when         $pszon = 'PKCLR '
CB3bAC                             or $pszon = 'PKDRY '
CB3bAC                             or $pszon = 'PKFRZ '

CB3bAC     dsppcs        div(h)    8             nrbigl
CB3bAC                   if        nrbigl <= 0
CB3bAC                   eval      nrbigl = 1
CB3bAC                   endif
CB3bAC                   endsl
CB3bA*
CB3bA*    Loop to print required number of BIG pallet labels.
CB3bAC     1             do        nrbigl
CB3bAC                   exsr      fillb1
CB3bAC                   enddo
CB3bA*
CB3bAC                   else
CB3bAC                   eval      kyfmt = 'BIGPAL2'
CB3bA*
CB3bA*    Calculate how many extra BIG pallet labels to print.
CB3bAC                   eval      nrbigl = 1
CB3bAC                   select
CB3bAC                   when         $pszon = 'PKCLR '
CB3bAC                             or $pszon = 'PKDRY '
CB3bAC                             or $pszon = 'PKFRZ '
CB3bAC     dsppcs        div(h)    8             nrbigl
CB3bAC                   if        nrbigl <= 0
CB3bAC                   eval      nrbigl = 1
CB3bAC                   endif
CB3bAC                   endsl
CB3bA*
CB3bA*    Loop to print required number of BIG pallet labels.
CB3bAC     1             do        nrbigl
CB3bAC                   exsr      fillb1
CB3bAC                   enddo
CB3bA*
CB3bAC                   endif
CB3bAC                   endif
     C                   other

     C                   if        bigpallabel
     C                   eval      kyfmt = $plfmt
     C                   else
     C                   eval      kyfmt = 'PALLET  '
     C                   endif

     C                   exsr      fillb1
     C                   endsl

     C                   enddo

700lAC                   when      $pcmd = '*RPRTP3'

     * reprint a pallet

     C                   eval      wkplid = $ptrn#
     C     keyps15       chain     pltsum15
     C                   if        not %found(pltsum15)
     C                   eval      dsstp1 = 0
     C                   eval      dsstp2 = 0
     C                   endif

     C                   eval      @pal# = pspal#
     C                   eval      @plid = psplid
     C                   eval      @rtid = psrtid
     C                   eval      dsstp1 = psstp1
     C                   eval      dsstp2 = psstp2
     C                   eval      dsppcs = pspcs
     C                   eval      dspcub = pscube
     C                   eval      lbtrn# = pstrn#
CB3aAC                   if        client = Cheney
CB3aAC                             and (cliloc = cheneyriviera
CB3tAC                               or cliloc = cbist
CB3aAC                               or cliloc = cheneyocala)
CB3a  /free
CB3a
CB3a    chain (pswhse:pstrn#) label90;
CB3a    lbord = x_lbord;
CB3a
CB3a  /end-free
CB3aAC                   exsr      getordh
CB3aAC                   endif

     * I-Supply requires 3 Pallet Labels with BIG print
     * everyone else continues to print 1 Pallet label
     *
     C                   select
     C                   when      client = isupply
     C                             and $ptruk <> 'WILLCALL'
     C                   eval      kyfmt = 'PALLET1 '
     C                   exsr      fillb1
     C                   eval      kyfmt = 'PALLET2 '
     C                   exsr      fillb1
     C                   eval      kyfmt = 'PALLET3 '
     C                   exsr      fillb1

CB3bAC                   when      client = cheney

CB3bAC                   if        pstruk <> 'PRE-PICK'
CB3bAC                             and pstruk <> 'CONTAINER'
CB3bAC                             and pstruk <> 'MEAT-INSP'
CB3oAC                             or $prte >= '8800 '
CB3oAC                             and $prte <= '8899 '

CB3bAC                   if        psgen = 1
CB3bMC                   eval      kyfmt = 'BIGPAL'
CB3bA*
CB3bA*    Calculate how many extra BIG pallet labels to print.
CB3bAC                   eval      nrbigl = 1
CB3bAC                   select
CB3bAC                   when         $pszon = 'PKCLR '
CB3bAC                             or $pszon = 'PKDRY '
CB3bAC                             or $pszon = 'PKFRZ '

CB3bAC     dsppcs        div(h)    8             nrbigl
CB3bAC                   if        nrbigl <= 0
CB3bAC                   eval      nrbigl = 1
CB3bAC                   endif
CB3bAC                   endsl
CB3bA*
CB3bA*    Loop to print required number of BIG pallet labels.
CB3bAC     1             do        nrbigl
CB3bAC                   exsr      fillb1
CB3bAC                   enddo
CB3bA*
CB3bAC                   else
CB3bAC                   eval      kyfmt = 'BIGPAL2'
CB3bA*
CB3bA*    Calculate how many extra BIG pallet labels to print.
CB3bAC                   eval      nrbigl = 1
CB3bAC                   select
CB3bAC                   when         $pszon = 'PKCLR '
CB3bAC                             or $pszon = 'PKDRY '
CB3bAC                             or $pszon = 'PKFRZ '
CB3bAC     dsppcs        div(h)    8             nrbigl
CB3bAC                   if        nrbigl <= 0
CB3bAC                   eval      nrbigl = 1
CB3bAC                   endif
CB3bAC                   endsl
CB3bA*
CB3bA*    Loop to print required number of BIG pallet labels.
CB3bAC     1             do        nrbigl
CB3bAC                   exsr      fillb1
CB3bAC                   enddo
CB3bA*
CB3bAC                   endif
CB3bAC                   endif
     C                   other

     C                   if        bigpallabel
     C                   eval      kyfmt = $plfmt
     C                   else
     C                   eval      kyfmt = 'PALLET  '
     C                   endif

     C                   exsr      fillb1
     C                   endsl

     C                   endsl
     *
700lAC                   endsr
     *----------------------------------------------------------------
     *
CLDk *  LBLITL  Information tracking label
     *
CLDk C     lblitl        begsr
     C                   eval      kyfmt = 'ITL     '
     C                   exsr      fillb1
CLDk C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLPSD  Pallet summary detail line.
     *
     C     lblpsd        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLPSH  Pallet summary header line.
     *
     C     lblpsh        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLPCK  Pick labels.
     *
     C     lblpck        begsr
     *
CBIcAC                   eval      dsoitm = odoitm
CBIaAC                   eval      t#spcl = *blanks
CBIcAC                   if        dsspcl = '*SP'
CBIcAC                   movel     '*SP'         t#spcl
CBIcAC                   endif
CBIhAC                   if        dsrpck = 'N'
CBIhAC     t#spcl        cat       rpck:1        t#spcl
CBIcAC                   endif
     *
CBSb C                   if        lbtype = 'M'
CBSb C                   if        lbwhdp = 'CLRPI'
CB1a C                             or lbwhdp = 'FLRPI'
CBSb C                             or lbwhdp = 'FRZPI'
CBSb C                             or lbwhdp = 'PKCPI'
CBSb C                             or lbwhdp = 'PKFPI'
CBSrMC                             or lbwhdp = 'PRDPI'
CBSrAC                             or lbwhdp = 'DRY99'
CBSb C                   eval      t#spcl = *blanks
CBSb C                   movel     'MERGE'       t#spcl
CBSb C                   endif
CBSb C                   endif
     *  Print aisle change label.
     C                   if        svaisl = *blanks
     C                   eval      svaisl = lbaisl
     C                   endif
     *
CHYw C                   select
CHYw C                   when      client = cheney
     C                   if        lbaisl <> svaisl
CHYw C                             and #from <> 'SETEND'
     C                   exsr      lblasl
     C                   eval      svaisl = lbaisl
     C                   endif
CHYw C                   other
     C                   if        lbaisl <> svaisl
     C                   exsr      lblasl
     C                   eval      svaisl = lbaisl
     C                   endif
CHYw C                   endsl
CBIdA*  CBIw - Moved this logic here
CHYbA*  Check if Meat Inspection label should be printed.
CBIdAC                   if        dsmeat = 'Y'
CBIiAC                             and meatpr = *off
CBIdAC                   exsr      lbmeat
CBIiAC                   eval      meatpr = *on
CBIdAC                   endif
CBIdA*
CHYbA*  Check if Pre-Pick label should be printed.
CHYbAC                   if        dsppck = 'Y'  and
CHYbAC                             ppckpr = *off
CHYbAC                   exsr      lbppck
CHYbAC                   eval      ppckpr = *on
CHYbAC                   endif
640jA*
640jA*     See if we should print the "before" um warning.
640jA*
640jAC                   select
640jAC                   when      lbutyp <> 'N'
640kAC                             and lbutyp <> svutyp
640jAC                             and opuwrb = 'Y'
640jAC                   exsr      lblumb

SFGiAC                   when      imp_flg = *on
SFGiAC                             and opuwrb = 'Y'
SFGiAC                             and lbutyp <> svutyp
SFGiAC                   exsr      lblumb

CDIaAC                   when      client = cdi
CDIaAC                             and $ccode = 'BRKDWN'
CDIaAC                             and lbutyp <> svutyp
CDIaAC                   exsr      lblumb

CHYgAC                   when      client = cheney
CHYgAC                             and lbutyp <> 'N'
CHYgAC                             and opuwrb = 'Y'
CHYgAC                             and $pszon = 'CHEM'
CHYgAC                   exsr      lblumb

CHYgAC                   when      client = cheney
CHYgAC                             and lbutyp <> 'N'
CHYgAC                             and opuwrb = 'Y'
CHYgAC                             and $pszon = 'FRZ'
CHYgAC                   exsr      lblumb

CHYgAC                   when      client = cheney
CB1dAC                             and lbutyp <> 'N'
CB1dAC                             and opuwrb = 'Y'
CB1dAC                             and $pszon = 'FLRPIR'
CB1dAC                             and lblbl# <> lastLBL#
CB1dAC                   exsr      lblumb
640jAC                   endsl
640kAC                   eval      svutyp = lbutyp
     *
CB1dAC                   eval         lastLBL# = lblbl#

CHYn C                   if        client = cheney
     *
CHYn *  Print "PK NEXT" label for Will call orders except CONTAINER
     *  and BREAKERS truck regardless of zone.  CHEM and FRZ are
     *  excluded here because the logic above will cover that.
     *
CHYn C                   if        lbgrp2 = 'W'
CHYn C                             and opuwrb = 'Y'
CHYn C                             and lbutyp <> 'N'
CHYn C                             and pstruk <> @cntnr
CHYn C                             and pstruk <> 'BREAKERS'
CHYn C                             and $pszon <> 'CHEM'
CHYn C                             and $pszon <> 'FRZ'
CB1dAC                             and $pszon <> 'FLRPIR'
CHYn C                   exsr      lblumb
CHYn C                   endif
     *
CBIuA*        See if we should print the "before" combo warning.
     *
CBIuAC                   if        combo = *on
CBIuAC                             and opcwrb = 'Y'
CBIuAC                   exsr      lblcmb
CBIuAC                   endif
CHYnAC                   endif
     *
     C                   eval      stpcnt = 0
     C                   exsr      getpal
ALNbAC                   if        $pgen = 1
ALNbAC                   eval      @pal# = pal#
500eA*
500eA*    Item split between multiple sections on pallet.
500eA*    Retrieve pallet section for current case number.
500eAC                   if        lbhnd2 = '*P'
500eAC                   call      'GETSCID'
500eAC                   parm      *blanks       $scmd             8
500eAC                   parm      lbwhse        $swhse            3 0
500eAC                   parm      lblbl#        $slbl#            7 0
500eAC                   parm      w1pick        $scas#            5 0
500eAC                   parm      *blanks       $sscid            2
500eAC                   parm      *blanks       $srtn             8
500eAC                   if        $srtn = '*OK'
FRFaAC                   select
FRFfAC                   when      client = frf
ELBuAC                             or client = ellenbee
HMWgAC                             or client = hmwagner
FRFfAC                   eval      @psect = %replace((%subst($sscid:1:1
FRFfAC                             )):@psect:1:1)
FRFfAC                   eval      @psect = %replace((%subst(lbdsp2:1:1
FRFfAC                             )):@psect:2:1)
FRFfAC                   other
500eAC                   eval      @psect = $sscid
FRFfAC                   endsl
500eAC                   else
500eAC                   eval      @psect = *blanks
500eAC                   endif
500eA*
500eA*    Item assigned to single pallet section.
500eAC                   else
FRFaAC                   select
FRFfAC                   when      client = frf
ELBuAC                             or client = ellenbee
HMWgAC                             or client = hmwagner
FRFfAC                   eval      @psect = %replace((%subst(lbhnd2:1:1
FRFfAC                             )):@psect:1:1)
FRFfAC                   eval      @psect = %replace((%subst(lbdsp2:1:1
FRFfAC                             )):@psect:2:1)
FRFfAC                   other
CLDdAC                   eval      @psect = lbhnd2
FRFfAC                   endsl
500eAC                   endif
500eA*
ALNbAC                   else
CLDdD**                   CALL 'GETTPLT'
500dA*
500dAC                   if        $gcmd = '*FIRST  '  or
500dAC                             $gcmd = '*NEXT   '
500dA*
CLDdMC                   call      'GETTPL2'
500dAC                   parm                    $gcmd             8
ALNbAC                   parm      lblbl#        $glbl#            7 0
ALNbAC                   parm                    $gtplt            7 0
ALNbAC                   parm                    $gmlbl            7 0
ALNbAC                   parm                    $gmpid            7 0
ALNbAC                   parm                    $gsplt            1
ALNbAC                   parm                    $glow             1
CLDdAC                   parm                    $ghnd2            2
500dAC                   parm                    $gqypk            5 0
500dAC                   parm                    $gqypl            5 0
ALNbAC                   parm                    $grtn             8
500dAC                   endif
640cAC                   if        $grtn <> '*OK'
640cAC     keyl7         chain     label7
640cAC                   if        %found(label7)
640cAC                   call      'GETTPL2'
640cAC                   parm                    $gcmd
640cAC                   parm      blbctr#       $glbl#
640cAC                   parm                    $gtplt
640cAC                   parm                    $gmlbl
640cAC                   parm                    $gmpid
640cAC                   parm                    $gsplt
640cAC                   parm                    $glow
640cAC                   parm                    $ghnd2
640cAC                   parm                    $gqypk
640cAC                   parm                    $gqypl
640cAC                   parm                    $grtn
640cAC                   endif
640cAC                   endif
500eA*
500eA*    Item split between multiple sections on Merge pallet.
500eA*    Retrieve pallet section for current case number.
500eAC                   if        $ghnd2 = '*P'
500eAC                   call      'GETSCID'
500eAC                   parm      *blanks       $scmd
500eAC                   parm      lbwhse        $swhse
500eAC                   parm      $gmlbl        $slbl#
500eAC                   parm      w1pick        $scas#
500eAC                   parm      *blanks       $sscid
500eAC                   parm      *blanks       $srtn
500eAC                   if        $srtn = '*OK'
FRFfAC                   select
FRFfAC                   when      client = frf
ELBuAC                             or client = ellenbee
HMWgAC                             or client = hmwagner
FRFfAC                   eval      @psect = %replace((%subst($sscid:1:1
FRFfAC                             )):@psect:1:1)
FRFfAC                   eval      @psect = %replace((%subst(lbdsp2:1:1
FRFfAC                             )):@psect:2:1)
FRFfAC                   other
500eAC                   eval      @psect = $sscid
FRFfAC                   endsl
500eAC                   else
FRFfAC                   select
FRFfAC                   when      client = frf
ELBuAC                             or client = ellenbee
HMWgAC                             or client = hmwagner
FRFfAC                   eval      @psect = %replace((%subst($ghnd2:1:1
FRFfAC                             )):@psect:1:1)
FRFfAC                   eval      @psect = %replace((%subst(lbdsp2:1:1
FRFfAC                             )):@psect:2:1)
FRFfAC                   other
500eAC                   eval      @psect = $ghnd2
FRFfAC                   endsl
500eAC                   endif
500eA*
500eAC                   eval      @pal# = $gtplt
500eA*
500eAC                   else
500dA*
ALNbAC                   eval      @pal# = $gtplt
FRFfAC                   select
FRFfAC                   when      client = frf
ELBuAC                             or client = ellenbee
HMWgAC                             or client = hmwagner
FRFfAC                   eval      @psect = %replace((%subst($ghnd2:1:1
FRFfAC                             )):@psect:1:1)
FRFfAC                   eval      @psect = %replace((%subst(lbdsp2:1:1
FRFfAC                             )):@psect:2:1)
FRFfAC                   other
CLDdAC                   eval      @psect = $ghnd2
FRFfAC                   endsl
500eAC                   endif
ALNbAC                   endif
     C                   if        combo = *off
     C                   eval      @qty1 = w1pick
     C                   eval      @qty2 = w1qty2
     C                   eval      totwrd = ' of'
     C                   move      '       '     cmbwrd
     C                   else
CLDb C                   eval      @qty1 = w1qty2
     C                   eval      @qty2 = w1qty2
     C                   eval      totwrd = 'TOT'
     C                   eval      cmbwrd = '(COMBO)'
     C                   endif
     *
CHYp C                   if        dslifo = 'L I F O'
CHYp C                   eval      cmbwrd = dslifo
CHYp C                   endif

     C                   if        lbasl2 = 'OUT'
CDIdA*
CDIdAC                   if        client = CDI
CDIiD ***                eval      outwrd = ' '
CDIiMC                   eval      outwrd = '***'
CDIdAC                   else
     C                   eval      outwrd = 'OUT'
CDIdAC                   endif
CDIdA*
     C                   else
     C                   move      '   '         outwrd
     C                   endif
     *
CLDhA*  Print pick slot, if OUT label and Slot number is blank.
     *
CLDh C                   if        lbasl2 = 'OUT'  and
CLDh C                             lbdisp = *blanks
CLDh C                   eval      $scmd = '*FIRST'
CLDh C                   call      'GETPSLT'
CLDh C                   parm                    $scmd
CLDh C                   parm      lbwhse        $swhse
CLDh C                   parm      lbitem        #sitem           15
     C                   parm                    woslot           12
     C                   parm                    $saisl            3
     C                   parm                    $sloc             3 0
     C                   parm                    $srlvl            2 0
     C                   parm                    $shand            2
     C                   parm                    $srtn
     C                   if        $srtn <> '*NONE   '
     C                   eval      lbdisp = woslot
     C                   endif

CB3l  /free

CBSa      // Use Special Designaiton Slot for Special deisg item. CBSa

CBSqA   if client = cheney and
CBSqA      $srtn = '*NONE   ';
CB3lM     chain ($pwhse:lbitem) piritem;
CBSqA     if %found(piritem);
CB3lM       chain (itdesg) desigsp;
CBSqA       if %found(desigsp);
CBSqA         lbdisp = dssdsp ;
CBSqA       endif;
CBSqA     endif;
CBSqA   endif;

CB3l  /end-free
     C                   endif
     *
     *      Print Catchweight Labels between Pick Labels.
     C                   if        itcwgt = 'Y'  and
     C                             opcwgt <> 0   and
530eAC                             $pcmd = '*PRTLBL '
SFGeAC                   if        client <> SGC
BIRaAC                             and client <> birite
530eMC                   exsr      lblcwt
SFGeAC                   endif
     C                   endif
     *
SLBaAC                   select
650lAC                   when      client = FischerFoods
650lAC                             and combo = *on
650lAC                             and SectionCount > 1
650lAC                   eval      kyfmt = 'COMBO   '

FFCcAC                   when      client = FischerFoods
FFCcAC                             and (lbutyp <> 'N'
FFCcAC                             or ittype = 'B'
FFCcAC                             or ittype = 'S')
FFCcAC                   eval      kyfmt = 'PICK2   '

CLDuAC                   when      client = Cityline
     *
CLDtAC                   exsr      getordh
     *
CLDtAC                   select
CLDuAC                   when      lbutyp <> 'N'
CLDuAC                   eval      kyfmt = 'PICK2   '
CLDtAC                   when      lbgrp2 = 'W'
CLDtMC                             and extstop = '6  '
CLDtAC                   eval      kyfmt = 'WLPICKA3'
CLDtAC                   when      lbgrp2 = 'W'
CLDtMC                             and extstop <>'6  '
CLDtAC                   eval      kyfmt = 'WLPICKAL'
CLDtMC                   when      $pgen = 1
CLDtMC                             and extstop = '6  '
CLDtMC                   eval      kyfmt = 'PICK3   '
CLDtMC                   when      $pgen = 1
CLDtMC                             and extstop <>'6  '
CLDtMC                   eval      kyfmt = 'PICK    '
CLDtMC                   when      $pgen <> 1
CLDtMC                             and extstop = '6  '
CLDtMC     psqbeg        add       w1pick        nxtseq
CLDtMC                   eval      nxtseq = nxtseq - 1
CLDtMC                   eval      kyfmt = 'PIRPICK3'
CLDtMC                   other
CLDtMC     psqbeg        add       w1pick        nxtseq
CLDtMC                   eval      nxtseq = nxtseq - 1
CLDtMC                   eval      kyfmt = 'PIRPICK '
CLDtMC                   endsl

SLBaAC                   when      client = silberman
SLBaAC                             and lbutyp = 'N'
SLBaAC                   eval      kyfmt = 'PICK2   '

GFCaAC                   when      client = gfc
GFCfAC                             and combo <> *on
GFCaAC     'E'           scan      lbitem        charpos

GFCiAC                   select
      * slot readable
GFCaAC                   when      charpos = *zeros
GFCfAC                             and opslot <> 'Y'
GFCaAC                   eval      kyfmt = 'PICK    '
      * slot readable
GFCaAC                   when      lbutyp = 'N'
GFCfAC                             and opslot <> 'Y'
GFCaAC                   eval      kyfmt = 'PICK    '
      * slot barcode
GFCaAC                   when      charpos = *zeros
GFCfAC                             and opslot = 'Y'
GFCaAC                   eval      kyfmt = 'PICKB   '
      * slot barcode
GFCaAC                   when      lbutyp = 'N'
GFCfAC                             and opslot = 'Y'
GFCaAC                   eval      kyfmt = 'PICKB   '
      * slot readable
GFCaAC                   when      charpos > *zeros
GFCfAC                             and opslot <> 'Y'
GFCaAC                   eval      kyfmt = 'PICK2   '
      * slot readable
GFCaAC                   when      lbutyp <> 'N'
GFCfAC                             and opslot <> 'Y'
GFCaAC                   eval      kyfmt = 'PICK2   '
      * slot barcode
GFCaAC                   when      charpos > *zeros
GFCfAC                             and opslot = 'Y'
GFCaAC                   eval      kyfmt = 'PICK2B  '
      * slot barcode
GFCaAC                   when      lbutyp <> 'N'
GFCfAC                             and opslot = 'Y'
GFCaAC                   eval      kyfmt = 'PICK2B  '
GFCaAC                   endsl

GFCfAC                   when      client = gfc
GFCfAC                             and combo = *on
GFCfAC     'E'           scan      lbitem        charpos

GFCiAC                   select
      * slot readable
GFCaAC                   when      charpos = *zeros
GFCfAC                             and opslot <> 'Y'
GFCaAC                   eval      kyfmt = 'COMBO   '
      * slot readable
GFCaAC                   when      lbutyp = 'N'
GFCfAC                             and opslot <> 'Y'
GFCaAC                   eval      kyfmt = 'COMBO   '
      * slot barcode
GFCaAC                   when      charpos = *zeros
GFCfAC                             and opslot = 'Y'
GFCaAC                   eval      kyfmt = 'COMBOB  '
      * slot barcode
GFCaAC                   when      lbutyp = 'N'
GFCfAC                             and opslot = 'Y'
GFCaAC                   eval      kyfmt = 'COMBOB  '
      * slot readable
GFCaAC                   when      charpos > *zeros
GFCfAC                             and opslot <> 'Y'
GFCaAC                   eval      kyfmt = 'COMBO2  '
      * slot readable
GFCaAC                   when      lbutyp <> 'N'
GFCfAC                             and opslot <> 'Y'
GFCaAC                   eval      kyfmt = 'COMBO2  '
      * slot barcode
GFCaAC                   when      charpos > *zeros
GFCfAC                             and opslot = 'Y'
GFCaAC                   eval      kyfmt = 'COMBO2B '
      * slot barcode
GFCaAC                   when      lbutyp <> 'N'
GFCfAC                             and opslot = 'Y'
GFCaAC                   eval      kyfmt = 'COMBO2B '
GFCfAC                   endsl

GMMaAC                   when      client = menumaker
GMMaAC                             and lbutyp <> 'N'
GMMaAC                   eval      kyfmt = 'PICK2   '

SFGjAC                   when      client = SGC
VIPa C                   eval      lidisp = *blanks
VIPa C                   eval      lidisp = lbdisp
SFGa C                   eval      dinine = linine
VIPa C                   eval      diasle = liasle
VIPa C                   eval      diloc = liloc
VIPa C                   movel     lilvl         dilvl
SFGjAC                   if        lbutyp = '1'
SFGjAC                             or lbucod='EA'
SFGjAC                             or lbucod='ea'
SFGjAC                             or lbucod='ba'
SFGjAC                             or lbucod='BA'
SFGlAC                             or lbucod='bk'
SFGlAC                             or lbucod='BK'
SFGjAC                   eval      kyfmt = 'PICKEA  '
SFGjAC                   else
SFGjAC                   eval      kyfmt = 'PICK    '
SFGjAC                   endif
CTWaAC                   when      client = citywho
CTWaAC                   select
CTWkAC                   when      cigaretflag
CTWkAC                   eval      kyfmt = *blanks
CTWaAC                   when      tobaccoflag
CTWaAC                   eval      totwrd = ' of'
CTWfD ***                eval      kyfmt = 'TPICK   '
CTWfMC                   eval      kyfmt = 'PICK2   '
CTWiAC                   eval      @pal# = lbpal#
CTWiiC                   eval      @pal# = pal#
CTWaAC                   when      candyflag
CTWaAC                   eval      totwrd = ' of'
CTWfD ***                eval      kyfmt = 'TPICK   '
CTWfMC                   eval      kyfmt = 'PICK2   '
CTWiAC                   eval      @pal# = lbpal#
CTWiiC                   eval      @pal# = pal#
CTWaAC                   when      retailflag
CTWaAC                   eval      kyfmt = 'MPICK   '
CTWaAC                   other
CTWaAC                   eval      kyfmt = 'PICK    '
CTWaAC                   endsl

HMWbAC                   when      client = hmwagner
HMWeAC*    '-CS'         scan      lbitem:1
HMWeAC*                  if        %found
HMWeAC                   if        lbucod = 'CS'
HMWbAC                   eval      kyfmt = 'PICK    '
HMWbAC                   else
HMWbAC                   eval      kyfmt = 'PICK2   '
HMWbAC                   endif

MJKdAC                   when      client = mjkellner
MJKdAC                             and lbutyp <> 'N'
MJKdAC                   eval      kyfmt = 'PICK2   '

BIRhAC                   when      client = birite
BIRhAC                             and lbutyp <> 'N'
BIRhAC                   eval      kyfmt = 'PICK2   '

DRYaAC                   when      client = dairyland
DRYaAC                             and lbutyp <> 'N'
DRYaAC                   eval      kyfmt = 'PICK2   '

DRYjAC                   when      client = dairyland
DRYjAC                             and lbutyp = 'N'
DRYjAC                             and lbucod = 'PC'
DRYjAC                   eval      kyfmt = 'PICK2   '

GFScAC                   when      client = getfresh
GFScAC                             and lbutyp <> 'N'
GFScAC                   eval      kyfmt = 'PICK2   '

HKWcAC                   when      client = HKW
HKWcAC                             and lbutyp <> 'N'
HKWcAC                   eval      kyfmt = 'PICK2   '

HKWcAC                   when      client = HKW
HKWcAC                             and combo = *on
HKWcAC                   eval      kyfmt = 'COMBO   '

GLPeAC                   when      client = greenleaf
GLPeAC                             and combo = *on
GLPeAC                   eval      kyfmt = 'COMBO   '

SVLjAC                   when      client = saval
SVLjAC                             and lbutyp <> 'N'
SVLjAC                   eval      kyfmt = 'PICK2   '

PFCaAC                   when      client = prestofoods
PFCcD ***                          and lbutyp <> 'N'
PFCcMC                             and lbucod <> 'CS'
PFCaAC                   eval      kyfmt = 'PICK2   '

ISYhAC                   when      client = isupply
ISYhAC                             and lbutyp <> 'N'
ISYhAC                   eval      kyfmt = 'PICK2   '

CBIbAC                   when      client = cheney
CBIbAC                             and lbrlvl = 2
CBIlAC                             and lbwhdp <> 'PRD  '
CB3 MC                             and itactv <> '99'
CBIbAC                   eval      kyfmt = 'PICK2   '

CBIbAC                   when      client = cheney
CBIbAC                             and lbrlvl = 3
CBIlAC                             and lbwhdp <> 'PRD  '
CB3 MC                             and itactv <> '99'
CBIbAC                   eval      kyfmt = 'PICK3   '

CB3jAC                   when      client = cheney
CB3jAC                             and $pcmd = '*SHORTM '
CB3jAC                   eval      kyfmt = 'PICKM   '

CB3vAC                   when      client = cheney
CB3vAC                             and $pgen <> 1
CB3vAC                             and tbPalletType = 'O'
CB3vAC                   eval      kyfmt = 'PICKC   '

DRYaAC                   other
    AC                   eval      kyfmt = 'PICK    '
DRYaAC                   endsl
FFCcA*
BIRaAC                   select
BIRaAC                   when      client = birite
BIRaAC                   eval      dsmisc2 = xohmisc
BIRaAC                   other
     C                   eval      dsmisc = xohmisc
BIRaAC                   endsl
NCSdAC                   select
NCSdAC                   when      client = nicholas
NCSdAC                             and combo = *on
NCSdAC                   exsr      lblcombo
NCSdAC                   other
      *
BIRf C     keyiq         chain     itemqty                            79
BIRf C                   if        *in79=*on
BIRf C                   eval      iqstk1=0
BIRf C                   endif
     C                   exsr      fillb1

DRYgD ***                if        client = dairyland
DRYgD ***                          and CruiseShipFlg = 'Y'
DRYgD ***                eval      kyfmt = 'CRUISE  '
DRYgD ***                exsr      fillb1
DRYgD ***                endif

NCSdAC                   endsl
     C                   eval      combo = *off
     C                   endsr
NCSdA*----------------------------------------------------------------
NCSdA*
NCSdA*  LBLCOMBO  Print combo label for client
NCSdA*
NCSdAC     lblcombo      begsr

NCSfAC                   if        opclvl = 0
NCSfAC                   eval      cmb1 = 0
NCSfAC                   eval      cmb2 = lbqpck
NCSfAC                   else

     C     lbqpck        div       opclvl        cmb1
     C                   mvr                     cmb2

     *  Print the X of X combo labels

     C                   for       lblcnt = 1 to cmb1
     C                   eval      @qty1 = opclvl
     C                   eval      @qty2 = opclvl
     C                   exsr      fillb1
     C                   endfor

NCSfAC                   endif

     *  Print the X of Y remaining labels

     C                   if        cmb2 <> 0
     C                   eval      combo = *off
     C                   for       lblcnt = 1 to cmb2
     C                   eval      @qty1 = lblcnt
     C                   eval      @qty2 = cmb2
     C                   exsr      fillb1
     C                   endfor
     C                   endif

NCSdAC                   endsr
642bA*----------------------------------------------------------------
642bA*
642bA*  LBLSETSUM  Set Summary Label
642bA*
642bAC     lblsetsum     begsr
     *
530aAC                   select
530aAC                   when      oppset = 'N'
530aAC                             or oppset = ' '
     *
     *     Loop through all labels for transaction.
     *
     C                   eval      first2 = *on
     C     keyl33        setll     label33
     *
     C                   dou       forevr <> forevr
     C     keyl33        reade     label33                                78
     C                   if        *in78
     C                   leave
     C                   endif
CHYzA*
CHYzA*       Ignore Adjustment records, which are created when an OUT
CHYzA*       is closed to a non-zero quantity.
CHYzA*
CHYZAC                   if        client = cheney
CHYZAC                             and lbtype = 'A'
CHYzAC                   iter
CHYzAC                   endif
640dA*
640dA*       For pass 1 only use labels that have a PLTSUM 'O' record.
640dA*       For pass 2 only use labels that have a PLTSUM 'L' record.
640dA*
730fDC**                 if        fdiPass = 1 and PSTYPE <> 'O'
720gMC                   if        fdiPass = 1 and PSTYPE <> tbPalletType
640dAC                             or fdiPass = 2 and PSTYPE <> 'L'
640dAC                   iter
640dAC                   endif
     *
     *       First time through initialization.
     *
     C                   if        first2 = *on
     C                   exsr      initss
     C     ssocur        occur     stpsum
     C                   eval      dssstp = lbstop
     C                   eval      ttlcub = 0
     C                   eval      ttlwgt = 0
     C                   eval      ttlpcs = 0
     C                   eval      first2 = *off
     C                   eval      dssord = xohcord
     C                   endif
     *
     *       When stop changes, move to next data structure occurance.
     *       If we have reached the maximum number of summary detail
     *       lines, then print the label and continue on.
     *
     C                   if        lbstop <> dssstp
     C                   add       dsscub        ttlcub
     C                   add       dsswgt        ttlwgt
     C                   add       dsspcs        ttlpcs
     C                   if        ssocur = ssdcnt
     C                   exsr      lblssd
     C                   exsr      initss
     C                   else
     C                   add       1             ssocur
     C                   endif
     C     ssocur        occur     stpsum
     C                   eval      dssstp = lbstop
SvlhAC                   eval      dssord = xohcord
     C                   endif
     *
     *       Update summary amounts for stop.
     *
     C                   add       lbcube        dsscub
     C                   add       lbswgt        dsswgt
     C                   add       lbqpck        dsspcs
     C                   eval      dsscnm = ohcnam
     *
     C                   enddo
     *
     *     Print last stop and totals.
     *
     C                   if        first2 = *off
     *
     *       Detail line.
     *
     C                   add       dsscub        ttlcub
     C                   add       dsswgt        ttlwgt
     C                   add       dsspcs        ttlpcs
     C                   if        ssocur = ssdcnt
     C                   exsr      lblssd
     C                   exsr      initss
     C                   else
     C                   add       1             ssocur
     C                   endif
     C     ssocur        occur     stpsum
     *
     *       Summary totals.
     *
     C                   z-add     ttlcub        dsscub
     C                   z-add     ttlwgt        dsswgt
     C                   z-add     ttlpcs        dsspcs
     C                   movea     ttldsc        dsscnm
     C                   exsr      lblssd
     C                   endif
     *
     *  End of transaction, force print.
     *
     C                   exsr      print
     *
530aAC                   when      oppset = 'Y'
530aA*
530aA*     Loop through all labels for transaction.
530aA*
530aAC                   eval      first2 = *on
500aAC     keyp33        setll     label33p
500aA*
530aAC                   dou       forevr <> forevr
530aAC     keyp33        reade     label33p                               78
530aAC                   if        *in78
530aAC                   leave
530aAC                   endif
530aA*
530aA*       First time through initialization.
530aA*
530aAC                   if        first2 = *on
530aAC                   exsr      initss
530aAC     ssocur        occur     stpsum
530aAC                   eval      dssstp = lbstop
530aAC                   eval      dspal# = lbpal#
530aAC                   exsr      getpal
530aAC                   eval      @pal# = pal#
530aAC                   eval      ttlcub = 0
530aAC                   eval      ttlwgt = 0
530aAC                   eval      ttlpcs = 0
530aAC                   eval      first2 = *off
530aAC                   endif
530aA*
530aA*       When stop changes, move to next data structure occurance.
530aA*       If we have reached the maximum number of summary detail
530aA*       lines, then print the label and continue on.
530aA*
530aAC                   if        lbstop <> dssstp  or
530aAC                             lbpal# <> dspal#
530aAC                   add       dsscub        ttlcub
530aAC                   add       dsswgt        ttlwgt
530aAC                   add       dsspcs        ttlpcs
530aAC                   if        ssocur = ssdcnt  or
530aAC                             lbpal# <> dspal#
530aAC                   eval      t#pal# = dspal#
530aAC                   if        ssocur = ssdcnt
530aAC                   exsr      lblssd
530aAC                   exsr      initss
530aAC                   endif
530aAC                   if        lbpal# <> t#pal#
530aAC                   add       1             ssocur
530aAC     ssocur        occur     stpsum
530aAC                   z-add     ttlcub        dsscub
530aAC                   z-add     ttlwgt        dsswgt
530aAC                   z-add     ttlpcs        dsspcs
530aAC                   movea     ttldsc        dsscnm
530aAC                   exsr      lblssd
530aAC                   exsr      initss
530aAC                   eval      dspal# = 0
530aAC                   eval      ttlcub = 0
530aAC                   eval      ttlwgt = 0
530aAC                   eval      ttlpcs = 0
530aAC                   endif
530aAC                   else
530aAC                   add       1             ssocur
530aAC                   endif
530aAC     ssocur        occur     stpsum
530aAC                   eval      dssstp = lbstop
530aAC                   eval      dspal# = lbpal#
530aAC                   exsr      getpal
530aAC                   eval      @pal# = pal#
530aAC                   endif
530aA*
530aA*       Update summary amounts for stop.
530aA*
530aAC                   add       lbcube        dsscub
530aAC                   add       lbswgt        dsswgt
530aAC                   add       lbqpck        dsspcs
530aAC                   eval      dsscnm = ohcnam
530aA*
530aAC                   enddo
530aA*
530aA*     Print last stop and totals.
530aA*
530aAC                   if        first2 = *off
530aA*
530aA*       Detail line.
530aA*
530aAC                   add       dsscub        ttlcub
530aAC                   add       dsswgt        ttlwgt
530aAC                   add       dsspcs        ttlpcs
530aAC                   if        ssocur = ssdcnt
530aAC                   exsr      lblssd
530aAC                   exsr      initss
530aAC                   else
530aAC                   add       1             ssocur
530aAC                   endif
530aAC     ssocur        occur     stpsum
530aA*
530aA*       Summary totals.
530aA*
530aAC                   z-add     ttlcub        dsscub
530aAC                   z-add     ttlwgt        dsswgt
530aAC                   z-add     ttlpcs        dsspcs
530aAC                   movea     ttldsc        dsscnm
530aAC                   exsr      lblssd
530aAC                   endif
530aA*
530aA*
530aA*  End of transaction, force print.
530aA*
530aAC                   exsr      print
530aA*
530aAC                   endsl
     *
642bAC                   endsr
     *----------------------------------------------------------------
     *
     *  LBLZPD  Zone pickup detail line.
     *
     C     lblzpd        begsr
     C                   select
530 AC                   when      oplb7 = '1'
530 AC                             and $pcmd <> '*TEST1'
530 AC                             and $pcmd <> '*TEST2'
SFGnAC                   if        client = SGC
SFGnA* Print merge header label
SFGnAC                   exsr      lblmhd
SFGnAC                   endif
530 AC                   exsr      lblzps
414bAC                   when      zpdcnt = 0  and
414bAC                             $pcmd <> '*TEST1'  and
414bAC                             $pcmd <> '*TEST2'
414bAC                   exsr      lblzps
     C                   other
     C                   eval      dtlcnt = 0
CLDxAC                   Select
CLDxAC                   when      client = cityline
CLDxAC                   eval      kyfmt = *blanks
CLDxAC                   other
     C                   eval      kyfmt = 'ZONPKUP '
CLDxAC                   endsl
     C                   exsr      fillb1
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLZPH  Zone pickup header line.
     *
     C     lblzph        begsr
     C                   if        zpdcnt = 0
CLDxAC                   Select
CLDxAC                   when      client = cityline
CLDxAC                   eval      kyfmt = *blanks
CLDxAC                   other
     C                   eval      kyfmt = 'ZONPKUP '
CLDxAC                   endsl
     C                   exsr      fillb1
     C                   endif
     C                   endsr
SFGnA*----------------------------------------------------------------
SFGnA*
SFGnA*  LBLMHD  Merge header label.
SFGnA*
SFGnAC     lblmhd        begsr
SFGnAC                   eval      kyfmt = 'MRGHED  '
SFGnAC                   exsr      fillb1
SFGnAC                   endsr
CLDlA*----------------------------------------------------------------
CLDlA*
CLDlA*  LBLZPM  Zone PIR merge sequence labels.
CLDlA*
CLDlAC     lblzpm        begsr
     *
     *   Whip through PIRSEQ records using last tran#.
     *
     C     keypq3        setll     pirseq3
     *
     C                   dou       forevr <> forevr
     C     keypq3        reade     pirseq3                                77
     C                   if        *in77
     C                   leave
     C                   endif
     *
     *     Get corresponding transaction label record.
     *     This should be an 'M' record.
     *
     C     psqlbl        chain     label                              76
     *
     *     Get item record.
     *
     C     keyib         chain     piritem                            79
     *
     *     Get order header record.
     *
     C     keyoh         chain     ordh                               76
530fA*
530fAC     keyorp2       setll     ordp2
     *
     *     Print a label for each sequence number.
     *
CLDnAC                   eval      $scas# = 0
     C                   eval      nxtseq = psqbeg
     C                   dou       nxtseq > psqend
     *
     *       Create sequence number to print.
     *
     C                   eval      seqfld = *blanks
     C                   select
     C                   when      nxtseq <= 9
     C                   z-add     nxtseq        tempn1
     C                   movel     tempn1        seqfld
     C                   when      nxtseq <= 99
     C                   z-add     nxtseq        tempn2
     C                   movel     tempn2        seqfld
     C                   when      nxtseq <= 999
     C                   z-add     nxtseq        tempn3
     C                   movel     tempn3        seqfld
     C                   other
     C                   movel     nxtseq        seqfld
     C                   endsl
     C     seqfld        cat       '-':0         seqfld
     C     seqfld        cat       psqind:0      seqfld
     *
     *       Set pallet number.
     *
     C                   eval      @pal# = psqpal
     *
     *       Set pallet section id.
     *
     C                   eval      @psect = psqind
CLDnA*
CLDnA*         If item split between multiple sections on pallet,
CLDnA*         override PSQIND value by retrieving pallet section
CLDnA*         for current number from file LABELPS.
CLDnA*
CLDnAC                   if        lbhnd2 = '*P'
CLDnAC                   add       1             $scas#
CLDnAC                   call      'GETSCID'
CLDnAC                   parm      *blanks       $scmd
CLDnAC                   parm      lbwhse        $swhse
CLDnAC                   parm      lblbl#        $slbl#
CLDnAC                   parm                    $scas#
CLDnAC                   parm      *blanks       $sscid
CLDnAC                   parm      *blanks       $srtn
CLDnAC                   if        $srtn = '*OK'
CLDnAC                   eval      @psect = $sscid
CLDnAC                   endif
CLDnAC                   endif
     *
530fA*  Get unique piece number for label.
530fAC     keyorp2       reade     ordp2
530fAC                   if        %eof(ordp2)
530fAC                   eval      unqpiece# = 0
530fAC                   else
530fAC                   eval      unqpiece# = orpup#
530fAC                   endif
     *
     *       Set label format to be used.
     *
     C                   eval      kyfmt = 'PIRMERG2'
     *
     *       Print label.
     *
     C                   exsr      fillb1
     C                   add       1             nxtseq
     *
     C                   enddo
     *
     C                   enddo
     *
     C                   endsr
SFGmA*----------------------------------------------------------------
SFGmA*
SFGmA*  LBLZPM2 Zone PIR merge pick labels.
SFGmA*
SFGmAC     lblzpm2       begsr
SFGmA*
     *  Whip through merge label records using last tran#.
     *
     C                   eval      first2 = *on
     C                   eval      kyltyp = 'M'
     *
     C                   if        client = SGC
     C     keyl32        setll     label32g
     C                   else
     C     keyl32        setll     label32x
     C                   endif

     C                   dou       forevr <> forevr
     C                   if        client = SGC
     C     keyl32        reade     label32g
     C                   else
     C     keyl32        reade     label32x
     C                   endif

     C                   if        %eof(label32x)
     C                             or %eof(label32g)
     C                   leave
     C                   endif
     *
     *     Skip label if cross dock.
     *
     C                   if        lbstyp = 'X'
     C                   iter
     C                   endif
     *
     *  Skip label if nothing was picked.
     *
     C                   if        lbqpck = 0
     C                   iter
     C                   endif
     *
     *  Put together zone from label fields.
     *
     C                   movel     lbwhdp        tmpzon
     C                   move      lbstyp        tmpzon
     *
     *  Get corresponding transaction label record.
     *
     C     lbctr#        chain     label
     C                   eval      lbdsp2 = lb_lbdsp2
     *
     *     Set item master pack flag for possible "before" and "after"
     *     um warning labels.
     C                   exsr      getorddm
     *
     *     See if we should print the "before" um warning.
     *
     C                   if        lbutyp <> 'N'
     C                             and opuwrb = 'Y'
     C                             or  opuwrb = 'Y'
     C                             and imp_flg = *on
     C                   exsr      lblumb
     C                   endif
     *
     *  Get extended description
     *
     C     keyim         chain     itemmsc                            79
     C                   if        *in79=*on
     C                   eval      imbrnd=*blanks
     C                   endif
     *
     C     keyix         chain     itemdsc                            79
     C                   if        *in79=*on
     C                   eval      ixdsc2=*blanks
     C                   eval      dsdsc2=ixdsc2
     C                   else
     C                   eval      dsdsc2=ixdsc2
     C                   endif
     *
     *     Initialize label fields.
     *
     C                   eval      w1qty2 = lbqpck
640tD ***                exsr      crtstp
     *
     C     keyil         chain     piritem
     C                   if        not %found(piritem)
     C                   eval      itvit# = *blanks
     C                   endif
530bA*
530bA*     Get order header record
530bA*
530bAC                   exsr      getORDH
     *
642gA*  Position to first unique piece number for label.
642gA*
642gAC     keyorp2       setll     ordp2
     *
     *     Either print a combination label ...
     *
     C                   select
     C                   when      lbqpck >= opclvl
     C                   eval      combo = *on
     *
     *        See if we should print the "before" combo warning.
     *
     C                   if        opcwrb = 'Y'
     C                   exsr      lblcmb
     C                   endif
     *
     *        Print one label.
     *
642gA*
642gA*          Get unique piece number for label.
642gA*
642gAC     keyorp2       reade     ordp2
642gAC                   if        %eof
642gAC                   eval      unqpiece# = 0
642gAC                   else
642gAC                   eval      unqpiece# = orpup#
642gAC                   endif
642gA*
     C                   z-add     lbqpck        w1pick
     C                   eval      $gcmd = '*FIRST  '
     C                   eval      $gqypl = *zeros
     C                   exsr      lblpck
     *
     *        See if we should print the "after" combo warning.
     *
     C                   if        opcwra = 'Y'
     C                   exsr      lblcma
     C                   endif
     *
     C                   other
     *
     *     Or print individual labels.
     *
650aA*  If *SHORT or *SHORTM, reset the starting point for ORDP ...
650aA*  find and use the next sequential Trax# for this label which
650aA*  hasn't already been used.
650aA*
650aAC                   select
650aA*
650aAC                   when      $pcmd = '*SHORT  '
650aAC                             or $pcmd = '*SHORTM '
650aAC                   if        opuplv = 'N'
650aAC                             and $pcmd = '*SHORT  '
650aAC                   eval      cntTrax = (lbqpck - $pqty) + 1
650aAC                   else
650aAC                   eval      cntTrax = lbqpck +1
650aAC                   endif
650aAC     keyorp        setll     ordp2
650aAC                   do        cntTrax       TraxIndx          4 0
650aAC     keyorp        reade     ordp2
650aAC                   if        %eof
650aAC                   leave
650aAC                   endif
650aAC                   if        orpttl = 1
650aAC                             or cntTrax = 1
650aAC     keyorp        setll     ordp2
650aAC                   leave
650aAC                   endif
650aAC                   if        TraxIndx = cntTrax
650aAC     keyorp        readpe    ordp2
650aAC                   leave
650aAC                   endif
650aAC                   enddo
650aA*
650aAC                   endsl
     *
     C                   eval      combo = *off
     C                   eval      $gcmd = '*FIRST  '
     C                   eval      $gqypl = *zeros
     C     1             do        lbqpck        w1pick
642gA*
642gA*          Get unique piece number for label.
642gA*
642gAC     keyorp2       reade     ordp2
642gAC                   if        %eof
642gAC                   eval      unqpiece# = 0
642gAC                   else
642gAC                   eval      unqpiece# = orpup#
642gAC                   endif
642gA*
     C                   exsr      lblpck
     C                   eval      $gqypl = $gqypl - 1
     C                   if        $gqypl = 0
     C                   eval      $gcmd = '*NEXT   '
     C                   else
     C                   eval      $gcmd = *blanks
     C                   endif
     C                   enddo
     *
     C                   endsl
     *
     *     See if we should print the "after" um warning.
     *
     C                   if        lbutyp <> 'N'
     C                             and opuwra = 'Y'
     C                             or  opuwra = 'Y'
     C                             and imp_flg = *on
     C                   exsr      lbluma
     C                   endif
     *
     *     Print catch weight labels.
     *
     C                   if        itcwgt = 'Y'
     C                             and opcwgt <> 0
     C     lbqpck        div       opcwgt        lbls
     C                   mvr                     remain
     C                   if        remain <> 0
     C                   add       1             lbls
     C                   endif
     C     1             do        lbls
     C                   exsr      lblcwt
     C                   enddo
     C                   endif
     *
     C                   if        itcwgt = 'Y'
     C     lbqpck        mult      .083          wktime
     C                   add       wktime        cwtime
     C                   endif
     *
     C                   enddo
     *
     C                   endsr
414bA*----------------------------------------------------------------
414bA*
414bA*  LBLZPS  Zone pickup individual selection labels
414bA*
414baC     lblzps        begsr
dry A*
dry A*     Get order header misc
dry A*
dry AC                   exsr      getORDHM
     *
     *     See if we should print the "before" um warning.
     *
     C                   if        lbutyp <> 'N'  and
     C                             opuwrb = 'Y'
     C                   exsr      lblumb
     C                   endif
     *
     *     Initialize label fields.
     *
     C                   eval      w1qty2 = lbqpck
640tD ***                exsr      crtstp
     *
     *     Either print a combination label ...
     *
     C                   select
     C                   when      lbqpck >= opclvl
CLDbMC                             or client = cityline
CLDbMC                             and ittype = 'S'
     C                   eval      combo = *on
     *
     *        See if we should print the "before" combo warning.
     *
CLDbAC                   select
CLDbAC                   when      client = cityline
CLDbAC                             and opcwrb = 'Y'
CLDbAC                             and ittype <> 'S'
CLDbAC                   exsr      lblcmb
CLDbAC                   when      client <> cityline
CLDbAC                             and opcwrb = 'Y'
     C                   exsr      lblcmb
CLDbAC                   endsl
     *
     *        Print one label.
     *
500dAC                   eval      $gcmd = '*FIRST  '
500dAC                   eval      $gqypl = *zeros
     C                   eval      w1pick = lbqpck
CCPaAC                   if        client = capitolcity
CLDwAC                             or client = cityline
CWDwAC                             or client = cashwa
GFSkAC                             or client = getfresh
FRFaAC                             or client = frf
CCPaAC                   exsr      lblitmn
CCPaAC                   endif
     C                   exsr      lblpck
     *
     *        See if we should print the "after" combo warning.
     *
CLDbAC                   select
CLDbAC                   when      client = cityline
CLDbAC                             and opcwra = 'Y'
CLDbAC                             and ittype <> 'S'
CLDbAC                             and ittype <> 'S'
CLDbAC                   exsr      lblcma
CLDbAC                   when      client <> cityline
     C                             and opcwra = 'Y'
     C                   exsr      lblcma
CLDbAC                   endsl
     *
     C                   other
     *
     *     Or print individual labels.
     *
500dAC                   eval      $gcmd = '*FIRST  '
500dAC                   eval      $gqypl = *zeros
     C                   eval      combo = *off
CCPaAC                   if        client = capitolcity
CLDwAC                             or client = cityline
CWDwAC                             or client = cashwa
GFSkAC                             or client = getfresh
FRFaAC                             or client = frf
CCPaAC                   exsr      lblitmn
CCPaAC                   endif
     C     1             do        lbqpck        w1pick
     C                   exsr      lblpck
     C                   enddo
     *
     C                   endsl
     *
     *     See if we should print the "after" um warning.
     *
     C                   if        lbutyp <> 'N'  and
     C                             opuwra = 'Y'
     C                   exsr      lbluma
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLRP1  Replenishment/Letdown
     *
     C     lblrp1        begsr
     C                   eval      @qty1 = w1qty
     C                   eval      @qty2 = lbqavl
     C                   eval      totwrd = ' of'
500  C                   eval      umshrt = *blanks
500  C                   movel     itum1         umshrt
     C                   eval      kyfmt = 'REPL1   '
     C                   exsr      fillb1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLRP2  Replenishment/Letdown - Breakdown.
     *
     C     lblrp2        begsr
     C                   eval      @qty1 = w1qty
     C                   eval      @qty2 = lbqavl
     C                   eval      totwrd = ' of'
500  C                   eval      umshrt = *blanks
500  C                   movel     itum1         umshrt
     C                   eval      kyfmt = 'REPL2   '
     C                   exsr      fillb1
     C                   endsr
500 A*----------------------------------------------------------------
500 A*
500 A*  LBLRP3  Replenishment/Letdown - Breakdown.
500 A*
500 AC     lblrp3        begsr
     C                   eval      @qty1 = w1qty
     C                   eval      @qty2 = lbqpck
     C                   eval      totwrd = ' of'
     C                   eval      umshrt = *blanks
     C                   movel     itum1         umshrt
CLDzAC                   select
CLDzMC                   when      svtype = 'B'
     C                   eval      kyfmt = 'REPL2   '
     C                   exsr      fillb1
CLDzMC                   when      svtype <> 'B'
CLDzAC                             and client <> cityln
     C                   eval      kyfmt = 'REPL1   '
     C                   exsr      fillb1
CLDzMC                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLSHD  Set header.(Batch, Warehouse etc.)
     *
     C     lblshd        begsr
     C                   if        $pgen = 1
     C                   eval      zontyp = 'Truck'
     C                   else
     C                   eval      zontyp = 'Stage'
     C                   endif
640cA*
640cA*  Print TOTE label
640cAC                   if        totzon = *on
640cAC                   exsr      lblshdt
640cAC                   if        oplb1 = 'N'
640cAC                             and oplb2 = 'N'
640cAC                   goto      endshd
640cAC                   endif
640cAC                   endif
640cA*
CBIlAC                   if        client = cheney
CBIlAC                   exsr      lblntr
CBIlAC                   endif

     C                   eval      dtlcnt = 0
FRFdAC                   if        client = frf
FRFdAC     keyl94        chain     label94
FRFdAC                   exsr      getordh
FRFdAC                   endif
     C                   dow       dtlcnt < palcnt
ctwaAC                   select
ctwkAC                   when      cigaretflag
ctwkAC                   eval      kyfmt = *blanks
ctwkAC                   eval      palcnt = *zeros
ctwaAC                   when      tobaccoflag
ctwfD ***                eval      kyfmt = 'TSETHED '
ctwfMC                   eval      kyfmt = 'SETHED  '
ctwaAC                   when      candyflag
ctwfD ***                eval      kyfmt = 'TSETHED '
ctwfMC                   eval      kyfmt = 'SETHED  '
ctwaAC                   when      retailflag
ctwaAC                   eval      kyfmt = 'MSETHED '
ctwaAC                   other
     C                   eval      kyfmt = 'SETHED  '
ctwaAC                   endsl
     C                   exsr      fillb1
     C                   enddo
MJKgA*
MJKgA*   Print set summary label.
MJKgA*
MJKgAC                   if        client = mjkellner
MJKgAC                   exsr      lblsetsum
MJKgAC                   endif
640mA*
CBIpAC                   if        client = cheney
CBIpAC                             and lbgrp2 <> 'W'

CBIpAC                             or client = cheney
CBIpAC                             and pstruk = 'BREAKERS'

CBIpAC                             or client <> cheney
     C                             and $pgen = 1

     C                   eval      dtlcnt = 0
     C                   dow       dtlcnt < palcnt
     C                   add       1             dtlcnt
     C     dtlcnt        occur     palsum
     C                   eval      @pal# = dsppal
     *
CCPaMC                   if        client = capitolcity
CLDaMC                             or client = cityln
CWDwAC                             or client = cashwa
GFSmAC                             or client = Getfresh
700hAC                   exsr      lblcustnotes
CCPaMC                   endif
     *
     C                   eval      @plid = dsppli
     C                   eval      @rtid = dsprti
     C                   eval      @stp1 = dsstp1
     C                   eval      @stp2 = dsstp2
     C                   if        dsppal > 0  or
     C                             $pcmd = '*TEST2  '
     *
700hAC                   select
MJKfMC                   when      client = mjkellner
MJKfMC                   eval      kyfmt = 'PALLET  '

700kAC                   eval      voiceid = 0
700kAC                   call      @getpltvid
700kAC                   parm      '*VOICEID'    $command
700kAC                   parm                    @plid
700kAC                   parm                    $pwhse
700kAC                   parm                    $prtid
700kAC                   parm                    voiceid

MJKfMC                   exsr      fillb1
700hMC                   when      client = cheney
FRFdAC     keyl94        chain     label94
FRFdAC                   exsr      getordh
700hMC                   exsr      lblshdcbi
700hAC                   endsl

     C                   endif
     C                   enddo
     C                   endif
640mMC     endshd        endsr
ctwaA*----------------------------------------------------------------
ctwaA*
ctwaA*  LBLSHDT  Set header.(Batch, Warehoute etc.)
ctwaA*
ctwaAC     lblshdt       begsr
ctwaA*
ctwaAC                   eval      kyltyp = 'O'
ctwaAC     keyl32        setll     label32x
ctwzAC                   dou       %eof(label32x)
ctwaAC     keyl32        reade     label32x
ctwaAC                   if        %eof(label32x)
ctwaAC                   eval      lbstop = 0
ctwaAC                   eval      @pal# = 0
ctwaAC                   eval      totpi# = 0
ctwaAC                   eval      totrn# = lsttrn
ctwZAC                   eval      dszitm = *blanks
ctwzAC                   leave
ctwzAC                   endif
ctwaA*
ctwaAC                   eval      done = 'N'
ctwzAC     keyl11        setll     label11
ctwzAC                   dou       %eof(label11)
ctwzAC     keyl11        reade     label11
ctwzAC                   if        not %eof(label11)
ctwzAC                   if        $prtid = albrte
ctwZAC                   eval      dszitm = albitem
BIRaAC                   select
BIRaAC                   when      client = birite
BIRaAC                   eval      dsmisc2 = ohmisc
BIRaAC                   other
ctwaAC                   eval      dsmisc = ohmisc
BIRaAC                   endsl
ctwaAC                   eval      totrn# = lbtrn#
ctwaAC                   eval      totpi# = lbpal#
ctwaAC                   exsr      totplt
ctwaAC                   eval      @pal# = $gpal#
ctwaAC                   exsr      totcnt
ctwaAC                   eval      done = 'Y'
ctwzAC                   leave
ctwzAC                   endif
ctwzAC                   endif
ctwzAC                   enddo
ctwzAC                   if        done = 'Y'
640xAC                   eval      $gcmd = '*FIRST  '
640xAC                   call      'GETTPL2'
640xAC                   parm                    $gcmd
640xAC                   parm      albctr#       $glbl#
640xAC                   parm                    $gtplt
640xAC                   parm                    $gmlbl
640xAC                   parm                    $gmpid
640xAC                   parm                    $gsplt
640xAC                   parm                    $glow
640xAC                   parm                    $ghnd2
640xAC                   parm                    $gqypk
640xAC                   parm                    $gqypl
640xAC                   parm                    $grtn
640xAC                   eval      @pal# = $gtplt
ctwzAC                   leave
ctwzAC                   endif
ctwzAC                   enddo
640cA*
640fAC     totrn#        chain     pirtran
640fAC                   if        not %found(pirtran)
640fAC                   eval      yptpcs = *zeros
640fAC                   endif
ctwaA*
ctwaAC                   exsr      getORDDM
ctwaAC                   eval      dszdsc = *blanks
640cAC     zonkey        chain     zoneh
640cAC                   if        %found(zoneh)
640cAC                   eval      dszdsc = zhdesc
640cAC                   endif
640cAC                   eval      dszpcs = lbqpck
ctwaA*
ctwwA*     Get order header record
ctwwA*
ctwwAC                   exsr      getORDH
640cA*
640cAC                   select
640cAC                   when      client = citywholesale
640cAC                             and cigaretflag = *on
640cAC                             and $pszon = cig091
640cAC                             or  opchkr = 'Y'
640cAC                   call      'GETSTAMP2'
640cAC                   parm                    $pwhse
640cAC                   parm                    $prtid
640cAC                   parm                    totrn#
640cAC                   parm                    $pstmp           16
640cAC                   if        $pstmp = ' '
640cAC                   eval      $pstmp = '0000000000000000'
640cAC                   endif
640cAC                   eval      txstamptn = %dec($pstmp:12:0)
640cAC                   eval      wkstmp = %char(txstamptn)
642eAC                   when      optaxr = 'Y'
640eMC                   call      'GETSTAMP3'
640eMC                   parm                    $pwhse
640eMC                   parm                    $prtid
640eMC                   parm                    lblbl#
640cAC                   parm                    $pstmp           16
640cAC                   if        $pstmp = ' '
640cAC                   eval      $pstmp = '0000000000000000'
640cAC                   endif
640cAC                   eval      txstamptn = %dec($pstmp:12:0)
640cAC                   eval      wkstmp = %char(txstamptn)
640cAC                   other
642eAC                   call      'GETSTAMP3'
642eAC                   parm                    $pwhse
642eAC                   parm                    $prtid
642eAC                   parm                    lblbl#
642eAC                   parm                    $pstmp           16
642eAC                   if        $pstmp = ' '
642eAC                   eval      $pstmp = '0000000000000000'
642eAC                   endif
642eAC                   eval      txstamptn = %dec($pstmp:12:0)
642eAC                   eval      wkstmp = %char(txstamptn)
640cAC                   endsl

640iAC                   eval      lasttote = *off
640iAC     tbkey1        chain     totebund1
640iAC                   if        %found(totebund1)
640iAC     tbkey3        setgt     totebund3
640iAC     tbkey3        readpe    totebund3
640iAC                   if        not %eof(totebund3)
640iAC                   if        tbtrn# = lbtrn#
640iAC                   eval      lasttote = *on
640iAC                   endif
640iAC                   endif
640iAC                   endif

640cAC                   select
ctwgAC                   when      client = citywho
ctwgAC                             and tobaccoflag
ctwgAC                   eval      kyfmt = 'XTOTE2  '
ctwgAC                   when      client = citywho
ctwgAC                             and candyflag
ctwgAC                   eval      kyfmt = 'XTOTE2  '
ctwgAC                   when      client = citywho
ctwaAC                   eval      kyfmt = 'XTOTE   '
640cAC                   when      totzon
640cAC                             and cigaretflag
640iAC                             and not lasttote
640cAC                   eval      kyfmt = 'XTOTE   '
640iAC                   when      totzon
640iAC                             and cigaretflag
640iAC                             and lasttote
640iAC                   eval      kyfmt = 'XTOTE3  '
640cAC                   other
640cAC                   eval      kyfmt = 'XTOTE2  '
640cAC                   endsl
640cAC                   eval      totwrd = ' of'
640cAC                   exsr      fillb1
640cA* Special stamp
640cAC                   if        client = citywholesale
640cAC                             and cigaretflag = *on
640cAC                             and ctwmsc_sflag = 'Y'
ctwwAC                   eval      kyfmt = 'XTOTES  '
ctwwAC                   exsr      fillb1
ctwwAC                   endif
ctwwA*
ctwaAC                   endsr
700hA*----------------------------------------------------------------
700hA*
700hA*  LBLSHDCBI  Set header.(Batch, Warehoute etc.)
700hA*
700hAC     lblshdcbi     begsr

CB2 AC                   if        pstruk <> 'PRE-PICK'
CB2 AC                             and pstruk <> 'CONTAINER'
CB2 AC                             and pstruk <> 'MEAT-INSP'
CB3oAC                             or $prte >= '8800 '
CB3oAC                             and $prte <= '8899 '
CBIrAC                   if        $pgen = 1
500d C                   if        $pcmd <> '*BEGIN  '
CBIeMC                   eval      kyfmt = 'SETHEDCB'
ALN AC                   exsr      fillb1
500d C                   endif
CBIjMC                   eval      kyfmt = 'BIGPAL'
CHYiA*
CHYiA*    Calculate how many extra BIG pallet labels to print.
CHYiAC                   eval      nrbigl = 1
CHYiAC                   select
CHYiAC                   when      $pszon = 'PKCLR '  or
CHYiAC                             $pszon = 'PKDRY '  or
CHYiAC                             $pszon = 'PKFRZ '
CHYiAC     dsppcs        div(h)    8             nrbigl
CHYiAC                   if        nrbigl <= 0
CHYiAC                   eval      nrbigl = 1
CHYiAC                   endif
CHYiAC                   endsl
CHYiA*
CHYiA*    Loop to print required number of BIG pallet labels.
CHYiAC     1             do        nrbigl
CBIjAC                   exsr      fillb1
CHYiAC                   enddo
CHYiA*
CBIrAC                   else
500d C                   if        $pcmd <> '*BEGIN  '
CBIrAC                   eval      @pal# = 0
CBIrMC                   eval      kyfmt = 'SETHDCB2'
CBIrAC                   exsr      fillb1
500d C                   endif
CBIrMC                   eval      kyfmt = 'BIGPAL2'
CHYiA*
CHYiA*    Calculate how many extra BIG pallet labels to print.
CHYiAC                   eval      nrbigl = 1
CHYiAC                   select
CHYiAC                   when      $pszon = 'PKCLR '  or
CHYiAC                             $pszon = 'PKDRY '  or
CHYiAC                             $pszon = 'PKFRZ '
CHYiAC     dsppcs        div(h)    8             nrbigl
CHYiAC                   if        nrbigl <= 0
CHYiAC                   eval      nrbigl = 1
CHYiAC                   endif
CHYiAC                   endsl
CHYiA*
CHYiA*    Loop to print required number of BIG pallet labels.
CHYiAC     1             do        nrbigl
CBIrAC                   exsr      fillb1
CHYiAC                   enddo
CHYiA*
CBIrAC                   endif
CB2 AC                   endif

700hAC                   endsr
ctwdA*----------------------------------------------------------------
ctwdA*
ctwdA*  LBLLOTM  Set header.(Batch, Warehouse etc.)
ctwdA*
ctwdAC     lbllotm       begsr
ctwdAC                   if        lbaisl = '132'
ctwdAC                             or  lbaisl = '151'
ctwdA*
ctwdAC                   eval      icount = *zeros
ctwdA*
ctwdAC                   do        lbqpck        icount
ctwdAC                   eval      kyfmt = 'MLOT    '
ctwdAC                   eval      totwrd = ' of'
ctwdAC                   exsr      fillb1
ctwdAC                   if        icount >= 5
ctwdAC                   leave
ctwdAC                   endif
ctwdAC                   enddo
ctwdA*
ctwdAC                   endif
ctwdAC                   endsr
     *----------------------------------------------------------------
     *
     *  LBLSSD  Set summary detail lines.
     *
     C     lblssd        begsr
     C                   eval      dtlcnt = 0
svlhAC                   select
svlhAC                   when      client = saval
svlhAC                             and yohtype =  'W'
svlhAC                   eval      kyfmt = 'SETSUMW '
svlhAC                   when      client = saval
svlhAC                             and yohtype <> 'W'
svlhAC                   eval      kyfmt = 'SETSUM  '
ctwkAC                   when      cigaretflag
ctwkAC                   eval      kyfmt = *blanks
ctwaAC                   when      tobaccoflag
ctwfD ***                eval      kyfmt = 'TSETSUM '
ctwfMC                   eval      kyfmt = 'SETSUM  '
ctwaAC                   when      candyflag
ctwfD ***                eval      kyfmt = 'TSETSUM '
ctwfMC                   eval      kyfmt = 'SETSUM  '
ctwaAC                   when      retailflag
ctwaAC                   eval      kyfmt = 'MSETSUM '
ctwaAC                   other
     C                   eval      kyfmt = 'SETSUM  '
ctwaAC                   endsl
     C                   exsr      fillb1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLSSH  Set summary header line.
     *
     C     lblssh        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLUMA  Unit of measure change is before.
     *
     C     lbluma        begsr
BIRc C                   eval      @qty2 = lbqpck
ctwaAC                   select
ctwkAC                   when      cigaretflag
ctwkAC                   eval      kyfmt = *blanks
ctwaAC                   when      tobaccoflag
ctwfD ***                eval      kyfmt = 'TUMA    '
ctwfMC                   eval      kyfmt = 'UMA     '
ctwaAC                   when      candyflag
ctwfD ***                eval      kyfmt = 'TUMA    '
ctwfMC                   eval      kyfmt = 'UMA     '
ctwaAC                   when      retailflag
ctwaAC                   eval      kyfmt = 'MUMA    '
ctwaAC                   other
     C                   eval      kyfmt = 'UMA     '
ctwaAC                   endsl
     C                   exsr      fillb1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLUMB  Unit of measure change is next.
     *
     C     lblumb        begsr
BIRc C                   eval      @qty2 = lbqpck
ctwaAC                   select
ctwkAC                   when      cigaretflag
ctwkAC                   eval      kyfmt = *blanks
ctwaAC                   when      tobaccoflag
ctwfD ***                eval      kyfmt = 'TUMB    '
ctwfMC                   eval      kyfmt = 'UMB     '
ctwaAC                   when      candyflag
ctwfD ***                eval      kyfmt = 'TUMB    '
ctwfMC                   eval      kyfmt = 'UMB     '
ctwaAC                   when      retailflag
ctwaAC                   eval      kyfmt = 'MUMB    '
ctwaAC                   other
     C                   eval      kyfmt = 'UMB     '
ctwaAC                   endsl
     C                   exsr      fillb1
     C                   endsr
     *----------------------------------------------------------------
     *
CHYu *  LBLWSP  Will Call Special instruction label
     *
CHYu C     lblwsp        begsr
CHYu C                   eval      kyfmt = 'WLSPCL  '
CHYu C                   exsr      fillb1
CHYu C                   endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  LBLZHD  Zone header label.
     *
     C     lblzhd        begsr
ctwaAC                   select
ctwkAC                   when      cigaretflag
ctwkAC                   eval      kyfmt = *blanks
ctwaAC                   when      tobaccoflag
ctwfD ***                eval      kyfmt = 'TZONHED '
ctwfMC                   eval      kyfmt = 'ZONHED  '
ctwaAC                   when      candyflag
ctwfD ***                eval      kyfmt = 'TZONHED '
ctwfMC                   eval      kyfmt = 'ZONHED  '
ctwaAC                   when      retailflag
ctwaAC                   eval      kyfmt = 'MZONHED '
ctwaAC                   other
     C                   eval      kyfmt = 'ZONHED  '
ctwaAC                   endsl
     C                   exsr      fillb1
     C                   endsr
CBIhA*----------------------------------------------------------------
CBIhA*
CBIhA*  LBLZDS  Zone desc label.
CBIhA*
CBIhAC     lblzds        begsr
CBIhAC                   eval      kyfmt = 'ZONEDESC'
CBIhAC                   exsr      fillb1
CBIhAC                   endsr
CBIlA*----------------------------------------------------------------
CBIlA*
CBIlA*  LBLNTR  New transaction.
CBIlA*
CBIlAC     lblntr        begsr
CHYs C                   if        ohtype = 'W'
CHYs C                   eval      kyfmt = 'NEWTRANW'
CHYs C                   else
CBIlAC                   eval      kyfmt = 'NEWTRAN '
CHYs C                   endif
CBIlAC                   exsr      fillb1
CBIlAC                   endsr
530gA*----------------------------------------------------------------
530gA*
530gA*  LBLSUB  Substitution header label.
530gA*
530gAC     lblsub        begsr

530gAC                   eval      svtrn# = lbtrn#
530gAC                   eval      lbtrn# = lsttrn

530gAC                   eval      kyfmt = 'SUBHED  '
530gAC                   exsr      fillb1

530gAC                   eval      lbtrn# = svtrn#

530gAC                   endsr
     *----------------------------------------------------------------
     *
     *  LBLXDB  Cross dock labels are next.
     *
     C     lblxdb        begsr
     C                   eval      kyfmt = 'XDKB    '
     C                   exsr      fillb1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLITMN Item notes.
     *
     C     lblitmn       begsr
     C                   eval      itmnote1 = *blanks
     C                   eval      itmnote2 = *blanks
CCPaAC     kyodm         chain     orddm                              79
FRFaAC                   select
FRFaAC                   when      %found(orddm)
FRFaAC                             and client = frf
FRFaAC                             and (ommsc4 <> *blanks
FRFaAC                             or ommsc5 <> *blanks)
FRFaAC                   eval      itmnote1 = %subst(ommsc4:1:18)
FRFaAC                   eval      itmnote2 = %subst(ommsc5:1:18)
FRFaA ***                eval      kyfmt = 'ITEMNOTE'
FRFaA ***                exsr      fillb1

CCPaAC                   when      %found(orddm)
CCPaAC                             and ommsc5 <> *blanks
CCPaAC                   eval      kyfmt = 'ITEMNOTE'
cwdwwC                   if        client <> cashwa
CCPaAC                   exsr      fillb1
cwdwwC                   endif
CCPaAC                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLCUSTNOTES - print customer notes label
     *
700hAC     lblcustnotes  begsr

CCPaMC     keyl94        setll     label94
CCPaMC                   dou       %eof(label94)
CCPaMC     keyl94        reade     label94
CCPaMC                   if        not %eof(label94)
CCPaMC                   exsr      getordh
CCPaMC                   if        ccpchk = '*SP'
CCPaMC                             and @pal# > 0
GFSmAC                             and client = Capitolcity
GFSmA*
GFSmA*      Print custoemr critical care label.
GFSmAC                             or gfsmsc_ohccar = 'Y'
GFSmAC                             and @pal# > 0
GFSmAC                             and client = Getfresh
GFSmA*
CCPaMC                   eval      ohcord = xohcord
CCPaMC                   eval      ohcust = xohcust
CCPaMC                   eval      ohcnam = xohcnam
CCPaMC                   eval      kyfmt = 'CUSTNOTE'
CCPaMC                   exsr      fillb1
CCPaMC                   endif
CCPcMC                   if        ccpchks = 'Y'
CCPcMC                             and @pal# > 0
CCPcMC                   eval      ohcord = xohcord
CCPcMC                   eval      ohcust = xohcust
CCPcMC                   eval      ohcnam = xohcnam
CCPcMC                   eval      kyfmt = 'CUSTNOTE'
CCPcMC                   exsr      fillb1
CCPcMC                   endif
CCPaMC     keyl94a       setgt     label94
CCPaMC                   endif
CCPaMC                   enddo

700hAC                   endsr
     *----------------------------------------------------------------
     *
     *  STRPDP  Strip decimal point from sample data
     *
     C     strpdp        begsr
     C                   movea     lfvdta        a50
     C                   eval      y1 = 0
     C     1             do        50            x1
     C                   if        a50(x1) >= '0'  and
     C                             a50(x1) <= '9'
     C                   add       1             y1
     C                   eval      a50(y1) = a50(x1)
     C                   endif
     C                   enddo
     C                   if        y1 < 50
     C                   add       1             y1
     C                   movea     *blanks       a50(y1)
     C                   endif
     C                   movea     a50           lfvdta
     C                   endsr
     *----------------------------------------------------------------
     *
     *  TEST1   Test 1 - Print label definitions
     *
     C     test1         begsr
     *
ALN AC     1             do        shdcnt        k
ALN AC     k             occur     palsum
ALN AC                   eval      dsppal = k
ALN AC                   enddo
     *
     C                   if        $plfmt = '*ALL    '  or
     C                             $plfmt = 'BEGBLK  '
     C                   exsr      lblbbk
     C                   endif
     *
ctwaAC                   if        $plfmt = '*ALL    '  or
ctwaAC                             $plfmt = 'HBEGBLK '
ctwaAC                   exsr      lblbbk
ctwaAC                   endif
ctwaA*
ctwaAC                   if        $plfmt = '*ALL    '  or
ctwaAC                             $plfmt = 'TBEGBLK '
ctwaAC                   exsr      lblbbk
ctwaAC                   endif
ctwaA*
     C                   if        $plfmt = '*ALL    '  or
     C                             $plfmt = 'BEGRPL  '
     C                   exsr      lblbrp
     C                   endif
     *
     C                   if        $plfmt = '*ALL    '  or
     C                             $plfmt = 'BULK    '
     C                   exsr      lblblk
     C                   endif
     *
ctwaAC                   if        $plfmt = '*ALL    '  or
ctwaAC                             $plfmt = 'MBULK   '
ctwaAC                   exsr      lblblk
ctwaAC                   endif
ctwaA*
ctwaAC                   if        $plfmt = '*ALL    '  or
ctwaAC                             $plfmt = 'TBULK   '
ctwaAC                   exsr      lblblk
ctwaAC                   endif
ctwaA*
     C                   if        $plfmt = '*ALL    '  or
     C                             $plfmt = 'CACHWT  '
     C                   exsr      lblcwt
     C                   endif
     *
ctwaAC                   if        $plfmt = '*ALL    '  or
ctwaAC                             $plfmt = 'MCACHWT '
ctwaAC                   exsr      lblcwt
ctwaAC                   endif
ctwaA*
ctwaAC                   if        $plfmt = '*ALL    '  or
ctwaAC                             $plfmt = 'TCACHWT '
ctwaAC                   exsr      lblcwt
ctwaAC                   endif
ctwaA*
DRYaAC                   if        $plfmt = '*ALL    '  or
DRYaAC                             $plfmt = 'CACHWT2 '
DRYaAC                   exsr      lblcwt
DRYaAC                   endif
DRYaA*
     C                   if        $plfmt = '*ALL    '  or
     C                             $plfmt = 'CMBA    '
     C                   exsr      lblcma
     C                   endif
     *
ctwaAC                   if        $plfmt = '*ALL    '  or
ctwaAC                             $plfmt = 'MCMBA   '
ctwaAC                   exsr      lblcma
ctwaAC                   endif
ctwaA*
ctwaAC                   if        $plfmt = '*ALL    '  or
ctwaAC                             $plfmt = 'TCMBA   '
ctwaAC                   exsr      lblcma
ctwaAC                   endif
ctwaA*
     C                   if        $plfmt = '*ALL    '  or
     C                             $plfmt = 'CMBB    '
     C                   exsr      lblcmb
     C                   endif
     *
ctwaAC                   if        $plfmt = '*ALL    '  or
ctwaAC                             $plfmt = 'MCMBB   '
ctwaAC                   exsr      lblcma
ctwaAC                   endif
ctwaA*
ctwaAC                   if        $plfmt = '*ALL    '  or
ctwaAC                             $plfmt = 'TCMBB   '
ctwaAC                   exsr      lblcma
ctwaAC                   endif
ctwaA*
     C                   if        $plfmt = '*ALL    '  or
     C                             $plfmt = 'DISCRP  '
     C                   exsr      lbldis
     C                   endif
     *
     C                   if        $plfmt = '*ALL    '  or
     C                             $plfmt = 'PICK    '
500dAC                   eval      $gcmd = '*FIRST  '
500dAC                   eval      $gqypl = *zeros
     C                   exsr      lblpck
     C                   endif
DRYaA*
DRYaAC                   if        $plfmt = '*ALL    '  or
DRYaAC                             $plfmt = 'PICK2   '
DRYaAC                   eval      $gcmd = '*FIRST  '
DRYaAC                   eval      $gqypl = *zeros
DRYaAC                   exsr      lblpck
DRTaAC                   endif
     *
ctwaAC                   if        $plfmt = '*ALL    '  or
ctwaAC                             $plfmt = 'MPICK   '
ctwaAC                   eval      $gcmd = '*FIRST  '
ctwaAC                   eval      $gqypl = *zeros
ctwaAC                   exsr      lblpck
ctwaAC                   endif
ctwaA*
ctwaAC                   if        $plfmt = '*ALL    '  or
ctwfD ***                          $plfmt = 'TPICK   '
ctwfMC                             $plfmt = 'PICK2   '
ctwaAC                   eval      $gcmd = '*FIRST  '
ctwaAC                   eval      $gqypl = *zeros
ctwaAC                   exsr      lblpck
ctwaAC                   endif
ctwaA*
     C                   if        $plfmt = '*ALL    '  or
     C                             $plfmt = 'REPL1   '
     C                   exsr      lblrp1
     C                   endif
     *
     C                   if        $plfmt = '*ALL    '  or
     C                             $plfmt = 'REPL2   '
     C                   exsr      lblrp2
     C                   endif
     *
510dAC                   if        $plfmt = '*ALL    '  or
510dAC                             $plfmt = 'SETHDCB2'
510dAC                   eval      kyfmt = $plfmt
510dAC                   exsr      fillb1
510dAC                   endif
     *
     C                   if        $plfmt = '*ALL    '  or
     C                             $plfmt = 'SETHED  '
     C                   if        $pcmd = '*TEST1  '
     C                   eval      zontyp = 'Truck'
     C                   eval      kyfmt = 'SETHED  '
     C                   exsr      fillb1
ISPb C                   eval      kyfmt = 'PALLET  '
ALN AC                   exsr      fillb1
     C                   else
     C                   z-add     shdcnt        palcnt
     C                   exsr      lblshd
     C                   endif
     C                   endif
ctwaA*
ctwaAC                   if        $plfmt = '*ALL    '  or
ctwaAC                             $plfmt = 'MSETHED '
ctwaAC                   if        $pcmd = '*TEST1  '
ctwaAC                   eval      zontyp = 'Truck'
ctwaAC                   eval      kyfmt = 'MSETHED '
ctwaAC                   exsr      fillb1
ctwaAC                   eval      kyfmt = 'MPALLET '
ctwaAC                   exsr      fillb1
ctwaAC                   else
ctwaAC                   z-add     shdcnt        palcnt
ctwaAC                   exsr      lblshd
ctwaAC                   endif
ctwaAC                   endif
ctwaA*
ctwaAC                   if        $plfmt = '*ALL    '  or
ctwaAC                             $plfmt = 'TSETHED '
ctwaAC                   if        $pcmd = '*TEST1  '
ctwaAC                   eval      zontyp = 'Truck'
ctwfD ***                eval      kyfmt = 'TSETHED '
ctwfMC                   eval      kyfmt = 'SETHED  '
ctwaAC                   exsr      fillb1
ctwfD ***                eval      kyfmt = 'TPALLET '
ctwfMC                   eval      kyfmt = 'PALLET  '
ctwaAC                   exsr      fillb1
ctwaAC                   else
ctwaAC                   z-add     shdcnt        palcnt
ctwaAC                   exsr      lblshd
ctwaAC                   endif
ctwaAC                   endif
     *
     C                   if        $plfmt = '*ALL    '  or
     C                             $plfmt = 'SETSUM  '
     C                   exsr      lblssd
     C                   endif
ctwaA*
ctwaAC                   if        $plfmt = '*ALL    '  or
ctwaAC                             $plfmt = 'MSETSUM '
ctwaAC                   exsr      lblssd
ctwaAC                   endif
ctwaA*
ctwaAC                   if        $plfmt = '*ALL    '  or
ctwaAC                             $plfmt = 'TSETSUM '
ctwaAC                   exsr      lblssd
ctwaAC                   endif
     *
     C                   if        $plfmt = '*ALL    '  or
     C                             $plfmt = 'UMA     '
     C                   exsr      lbluma
     C                   endif
ctwaA*
ctwaAC                   if        $plfmt = '*ALL    '  or
ctwaAC                             $plfmt = 'MUMA    '
ctwaAC                   exsr      lbluma
ctwaAC                   endif
ctwaA*
ctwaAC                   if        $plfmt = '*ALL    '  or
ctwaAC                             $plfmt = 'TUMA    '
ctwaAC                   exsr      lbluma
ctwaAC                   endif
     *
     C                   if        $plfmt = '*ALL    '  or
     C                             $plfmt = 'UMB     '
     C                   exsr      lblumb
     C                   endif
ctwaA*
ctwaAC                   if        $plfmt = '*ALL    '  or
ctwaAC                             $plfmt = 'MUMB    '
ctwaAC                   exsr      lbluma
ctwaAC                   endif
ctwaA*
ctwaAC                   if        $plfmt = '*ALL    '  or
ctwaAC                             $plfmt = 'TUMB    '
ctwaAC                   exsr      lbluma
ctwaAC                   endif
     *
     C                   if        $plfmt = '*ALL    '  or
     C                             $plfmt = 'XDKB    '
     C                   exsr      lblxdb
     C                   endif
     *
     C                   if        $plfmt = '*ALL    '  or
     C                             $plfmt = 'ZONHED  '
     C                   exsr      lblzhd
     C                   endif
     *
ctwaAC                   if        $plfmt = '*ALL    '  or
ctwaAC                             $plfmt = 'MZONHED '
ctwaAC                   exsr      lblzhd
ctwaAC                   endif
ctwaA*
ctwaAC                   if        $plfmt = '*ALL    '  or
ctwaAC                             $plfmt = 'TZONHED '
ctwaAC                   exsr      lblzhd
ctwaAC                   endif
ctwaA*
     C                   if        $plfmt = '*ALL    '  or
     C                             $plfmt = 'ZONPKUP '
     C                   exsr      lblzpd
     C                   endif
ctwaA*
ctwaAC                   if        $plfmt = '*ALL    '  or
ctwaAC                             $plfmt = 'MZONPKUP'
ctwaAC                   exsr      lblzpd
ctwaAC                   endif
ctwaA*
ctwaAC                   if        $plfmt = '*ALL    '  or
ctwaAC                             $plfmt = 'TZONPKUP'
ctwaAC                   exsr      lblzpd
ctwaAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
ALNdA*  ZZATTL  Accumulate totals to calculate std time for transactn
     *
ALNdAC     zzattl        begsr
     C                   eval      w1wds = *blanks
     C                   move      lbwhse        w1whse
ALNiAC     itkey         chain     piritem                            79
ALNiAC                   if        *in79
ALNiAC                   eval      itwhdp = *blanks
ALNiAC                   eval      itstyp = *blanks
ALNiAC                   endif
ALNiMC     w1whse        cat       itwhdp:0      w1wds
ALNiMC     w1wds         cat       itstyp:0      w1wds
     C                   eval      n = 1
     C     w1wds         lookup    wds(n)                                 81
     * Found
     C                   if        *in81
     *
ALNhAC                   if        zpikup = *on  and
ALNQAC                             lbwhdp <> 'FRZ'  and
ALNqAC                             lbaisl <> '22R'  and
ALNqAC                             lbaisl <> '22S'  and
ALNqAC                             lbaisl <> '23W'  and
ALNqAC                             lbaisl <> '23X'  and
ALNqAC                             lbaisl <> '23Y'
ALNhAC                   add       lbqalc        cse(n)
ALNhAC                   else
     C                   add       lbqalc        cse(n)
     C                   add       1             slt(n)
ALNhAC                   endif
     *
     C                   else
     * Not found
     C                   eval      wds(n) = w1wds
     C                   eval      cse(n) = lbqalc
     C                   eval      slt(n) = 1
     C                   eval      whs(n) = lbwhse
     C                   eval      whd(n) = lbwhdp
     C                   eval      sec(n) = lbstyp
     C                   endif
     *
ALNdAC                   endsr
     *----------------------------------------------------------------
     *
ALNdA*  ZZCLCT  Calculate pick time
     *
ALNdAC     zzclct        begsr
     C                   eval      pcktim = 0
     C                   eval      n = 0
     C                   do        99            n
     C                   if        wds(n) > *blanks
     C                   eval      w1whs = whs(n)
     C                   eval      w1whdp = whd(n)
     C                   eval      w1sec = sec(n)
     C                   eval      w1cse = cse(n)
     C                   eval      w1slt = slt(n)
     C                   eval      w1stim = 0
     C                   eval      w1ctim = 0
     C     keyst         chain     stdtime                            79
     C                   if        not *in79
     C     ststim        mult      w1slt         w1stim
     C     stctim        mult      w1cse         w1ctim
     C                   else
     C                   iter
     C                   endif
     C     pcktim        add       stptim        pcktim
     C     pcktim        add       w1stim        pcktim
     C     pcktim        add       w1ctim        pcktim
     C                   endif
     C                   enddo
     *
ALNhAC                   add       cwtime        pcktim
ALNgAC                   eval      pcktm0 = pcktim
     *
ALNoA*  Write record to PCKTIME file.
     *
ALNoAC     keypc         chain     pcktime                            79
ALNoAC                   if        *in79
ALNoAC                   eval      pcwhse = $pwhse
ALNoAC                   eval      pcrtid = $prtid
ALNoAC                   eval      pctrn# = lsttrn
ALNoAC                   z-add     pcktm0        pcptim
ALNoAC                   write     pcrec
ALNoAC                   endif
     *
ALNdAC                   endsr
     *----------------------------------------------------------------
     *
ALNdA*  ZZCLRA  Clear totals array
     *
ALNdAC     zzclra        begsr
     C                   eval      n = 0
     C                   do        99            n
     C                   eval      wds(n) = *blanks
     C                   eval      whs(n) = 0
     C                   eval      whd(n) = *blanks
     C                   eval      sec(n) = *blanks
     C                   eval      cse(n) = 0
     C                   eval      slt(n) = 0
     C                   enddo
ALNhAC                   eval      cwtime = 0
ALNdAC                   endsr
CLDqA*----------------------------------------------------------------
     * zzcld: grab FAB quantity breakdown
     *----------------------------------------------------------------
     *
     C     zzcld         begsr
     C                   z-add     0             pcksum
     C                   eval      fabitems = *off
     C     lb90key       setll     label90
     C                   DoW       Forevr = Forevr
     C                   read      label90
     C                   If        x_lbtrn# <> pstrn# or %EOF(label90)
     C                   Leave
     C                   endif
     C                   If        psplid = x_lbpal#
     C     ilkey         chain     itemlnk
     C                   if        %found(itemlnk)
     C     ilkey2        chain     itemfld
     C                   if        %found(itemfld) and
     C                             ifcat='FAB       '
     C                   eval      fabitems = *on
     C     ilkey2        chain(n)  piritem
     C                   if        %found(piritem)
     C                   if        x_lbqpck <= itumQ2 and itumq2 >0
     C                   add       1             pcksum
     C                   else
     C                   if        x_lbqpck > itumQ2 and itumq2 >0
     C                   eval      pcksum = (x_lbqpck/itumq2) + pcksum
     C                   endif
     C                   endif
     C                   endif
     C                   else
     C                   eval      pcksum = x_lbqpck + pcksum
     C                   endif
     C                   else
     C                   eval      pcksum = x_lbqpck + pcksum
     C                   endif
     C                   endif
     C                   enddo
     C                   endsr
     *
     *----------------------------------------------------------------
     *
CLDg *  ZZQTTL  Accumulate total zone pick qty for each pallet
     *
CLDg C     zzqttl        begsr
     C                   eval      n = 1
     C     w1pal#        lookup    pal(n)                                 81
     * Found
     C                   if        *in81
     C                   add       lbqpck        pcs(n)
     *
     C                   else
     * Not found
     C     *zeros        lookup    pal(n)                                 82
     * Found
     C                   if        *in82
     C                   eval      pal(n) = w1pal#
     C                   eval      pcs(n) = lbqpck
     C                   endif
     *
     C                   endif
     *
CLDg C                   endsr
ctwaA*----------------------------------------------------------------
ctwaA*
ctwaA*  TOTCNT  Get tote count for stop.
ctwaA*
ctwaA*    All parms must be passed in.
ctwaA*
ctwaAC     totcnt        begsr
ctwaA*
ctwaA*   Get count
ctwaA*
ct2bAC                   if        client = CityWholesale
ct2bAC                   call      'CNTTOTES2'
ct2bAC                   parm                    $gwhse
ct2bAC                   parm                    $grtid
ct2bAC                   parm                    $gtype
ct2bAC                   parm                    $gcomp
ct2bAC                   parm                    $gtzon
ct2bAC                   parm                    $ggen
ct2bAC                   parm                    $gszon
ct2bAC                   parm                    $gstp1
ct2bAC                   parm      0             $gtcnt            3 0
ct2bAC                   parm      lbord         $gord             7 0
ct2bAC                   parm      ' '           $grtn
ct2bAC                   else
ct2bA
ctwmD ***                call      'CNTTOTES2'
ctwmMC                   call      'CNTTOTES'
ctwaAC                   parm                    $gwhse
ctwaAC                   parm                    $grtid
ctwaAC                   parm                    $gtype
ctwaAC                   parm                    $gcomp
ctwaAC                   parm                    $gtzon
ctwaAC                   parm                    $ggen
ctwaAC                   parm                    $gszon
ctwaAC                   parm                    $gstp1
ctwaAC                   parm      0             $gtcnt            3 0
ctwmD ***                parm      lbord         $gord             7 0
ctwaAC                   parm      ' '           $grtn
ct2bA*
ct2bAC                   endif
ctwaA*
ctwaA*   Format into nn of nn string.
ctwaA*
ctwaA*     Start with general string.
ctwaA*
ctwaAC                   eval      temp10 = '    OF'
ctwaA*
ctwaA*     Move printed count into it.
ctwaA*
ctwaAC                   eval      i = $gstp1
ctwaAC                   if        i = 0
ctwaAC                   eval      temp3a = '  0'
ctwaAC                   else
640cD **                 eval      n = 1
640cD **   lbord         lookup    os(n)                                  81
640cD**found
640cD **                 if        *in81
640cD **                 eval      cs(n) = cs(n) + 1
640cD **                 move      cs(n)         temp3a
640cD **                 else
640cD**not found
640cD **   *zeros        lookup    os(n)                                  82
ctwaA **                 if        *in82
ctwaA **                 eval      os(n) = lbord
ctwaA **                 eval      cs(n) = 1
ctwaA **                 move      cs(n)         temp3a
ctwaA **                 endif
ctwaA **                 endif

ctwaAC                   add       1             ts(i)
ctwaAC                   move      ts(i)         temp3a
ctwaAC                   movea     temp3a        a3
ctwaAC                   if        a3(1) = '0'
ctwaAC                   eval      a3(1) = ' '
ctwaAC                   endif
ctwaAC                   if        a3(1) = ' '  and
ctwaAC                             a3(2) = '0'
ctwaAC                   eval      a3(2) = ' '
ctwaAC                   endif
ctwaAC                   movea     a3            temp3a
ctwaAC                   endif
ctwaAC                   movel     temp3a        temp10
ctwaAC                   eval      toteq1 = temp3a
ctwaA*
ctwaA*     Move maximum into it.
ctwaA*
ctwaAC                   move      $gtcnt        temp3a
ctwaAC                   movea     temp3a        a3
ctwaAC                   if        a3(1) = '0'
ctwaAC                   eval      a3(1) = ' '
ctwaAC                   endif
ctwaAC                   if        a3(1) = ' '  and
ctwaAC                             a3(2) = '0'
ctwaAC                   eval      a3(2) = ' '
ctwaAC                   endif
ctwaAC                   movea     a3            temp3a
ctwaAC                   move      temp3a        temp10
ctwaAC                   eval      toteq2 = temp3a
ctwaA*
ctwaAC                   endsr
ctwaA*----------------------------------------------------------------
640cA*
640cA*  TOTPLT  Get tote pallet.
640cA*
640cAC     totplt        begsr
640cA*
640cAC                   call      @getpl
640cAC                   parm      $pwhse        $gwhse            3 0
640cAC                   parm      $prtid        $grtid            5
720fDC**                 parm      'O'           $gtype            1
730pMC                   parm      tbPalletType  $gtype            1
640cAC                   parm      totpi#        $gplid            7 0
640cAC                   parm      0             $gpal#            7 0
640cAC                   parm      ' '           $gtzon            6
640cAC                   parm      ' '           $gpzon            6
640cAC                   parm      ' '           $gszon            6
640cAC                   parm      ' '           $gcomp            1
640cAC                   parm      0             $ggen             1 0
640cAC                   parm      ' '           $gtruk           10
640cAC                   parm      0             $gunld            2 0
640cAC                   parm      0             $grow             2 0
640cAC                   parm      0             $gcol             1 0
640cAC                   parm      0             $gstp1            2 0
640cAC                   parm      0             $gstp2            2 0
640cAC                   parm      0             $gpcs             5 0
640cAC                   parm      0             $gcube            7 3
640cAC                   parm      0             $gswgt            9 2
640cAC                   parm      0             $gbcnt            1 0
640cAC                   parm      ' '           $gflag            1
640cAC                   parm      0             $glbl#
640cAC                   parm      0             $gtrn#            7 0
640cAC                   parm      ' '           $grtn
640cA*
640cAC                   endsr
640c
     *----------------------------------------------------------------
     *  getORD    Get Extended Order Header for WC Special Instructns
     *----------------------------------------------------------------
CB3sAC     getORD        begsr

CB3sAC                   eval      work11a = *blanks
CB3sAC                   eval      work11b = *blanks
CB3sAC                   eval      ohaorda = *blanks
CB3sAC                   eval      ohacusta = *blanks

      /free

         // Get the new 11 DGT alpha order number for WLSPCL label

CB3s   if lbord = 0;
CB3s    chain ($pwhse:$prtid) ordh4;
CB3s    if %Found(ordh4);
CB3s      clear oharec;
CB3s      ohaord = yohord;
CB3s      exWhse = $pwhse;
CB3s    endif;
CB3s   else;

CB3s   clear oharec;
CB3s   exWhse = $pwhse;
CB3s   ohaord = lbord;
CB3s   endif;

         // ohaorda = 'ORD9876';
         // ohacusta = 'CST123ABC';
CB3s     monitor;
           exordh ('*GET': exRtnCode: exRtnMsg: exWhse: ohaord:
                   ohaaudflg: ohaaudid: ohaaudcmp: ohaaudby: ohaaudts:
                  ohaorda: ohacusta);

           on-error;
           endmon;
      /end-free

CB3sAC                   select
CB3sAC                   when      exRtnCode =   '*OK'
CB3sAC                             and (ohaorda <> *blanks
CB3sAC                                 or ohacusta <> *blanks)
CB3sAC                   if        ohaorda <> *blanks
CB3sAC                   eval      work8a = %subst(ohaorda:1:8)
CB3sAC                   eval      work11b = %subst(ohaorda:1:11)
CB3sAC                   endif
CB3sAC                   if        ohacusta <> *blanks
CB3sAC                   eval      work11a = %subst(ohacusta:1:11)
CB3sAC                   endif

CB3sAC                   endsl
CB3sAC                   endsr

530bA*----------------------------------------------------------------
530bA*  getORDH   Get Order Header Record.
530bA*----------------------------------------------------------------
530bAC     getORDH       begsr

530cAC                   eval      work8a = *blanks
530bAC                   eval      extStop = *blanks
730gAC                   eval      work11a = *blanks
730gAC                   eval      work11b = *blanks
730eAC                   eval      ohaorda = *blanks
730gAC                   eval      ohacusta = *blanks

      /free

         // First you must get all the current field values

       clear oharec;
       exWhse = $pwhse;
       ohaord = lbord;
         // ohaorda = 'ORD9876';
         // ohacusta = 'CST123ABC';
         monitor;
           exordh ('*GET': exRtnCode: exRtnMsg: exWhse: ohaord:
                   ohaaudflg: ohaaudid: ohaaudcmp: ohaaudby: ohaaudts:
                  ohaorda: ohacusta);

           on-error;
           endmon;
      /end-free

730eAC                   select
730eAC                   when      exRtnCode =   '*OK'
730eAC                             and (ohaorda <> *blanks
730gAC                                 or ohacusta <> *blanks)
730eAC                   if        ohaorda <> *blanks
730eAC                   eval      work8a = %subst(ohaorda:1:8)
730eAC                   eval      work11b = %subst(ohaorda:1:11)
730eAC                   endif
730gAC                   if        ohacusta <> *blanks
730gAC                   eval      work11a = %subst(ohacusta:1:11)
730gAC                   endif

730eAC                   endsl

530bAC     keyodh        chain     ordh

640cAC                   select
640cAC                   when      client = citywholesale
640cAC                   if        not %found(ordh)
640cAC                   eval      ctwmsc_sflag = *blanks
640cAC                   else
640cAC                   eval      ctwmsc_base = xohmisc
640cAC                   endif

CCPaAC                   when      client = capitolcity
CCPaAC                   if        not %found(ordh)
CCPaAC                   eval      ccpchk = *blanks
CCPaAC                   eval      ccpchks = *blanks
CCPaAC                   else
CCPaAC                   eval      ccpchk = %subst(xohmisc:7:3)
CCPaAC                   eval      ccpchks = %subst(xohmisc:12:1)
CCPaAC                   eval      work6a = %subst(xohmisc:1:6)
CCPaAC                   move      work6a        work6
CCPaAC     *mdy          test(d)                 work6                  99
CCPaAC                   if        *in99 = *off
CCPaAC                   move      work6         mdy
CCPaAC                   move      mdy           work8a
CCPaAC                   endif
CCPaAC                   endif

NCSaAC                   when      client = nicholas
530cAC                   eval      work8a = *blanks
530bAC                   eval      extStop = *blanks

NCSgAC                   if        not %found(ordh)
NCSgAC                   eval      nchmsc_date = *blanks
NCSgAC                   eval      nchmsc_Sngplt = *blanks
NCSgAC                   eval      nchmsc_Subs = *blanks
NCSgAC                   eval      nchmsc_Cid = *blanks
NCSgAC                   eval      nchmsc_Whse = *blanks
NCSgAC                   eval      nchmsc_Pkzn = *blanks
NCSgAC                   else
NCSgAC                   eval      nchmsc_base = ohmisc
530cAC                   move      nchmsc_date   work6
530cAC     *mdy          test(d)                 work6                  99
530cAC                   if        *in99 = *off
530cAC                   move      work6         mdy
530cAC                   move      mdy           work8a
530cAC                   endif
530cAC                   endif

CWDaAC                   when      client = cashwa
CWAaA
CWDwAC                   if        not %found(ordh)
CWDwAC                   eval      ccpchk = *blanks
CWDwAC                   eval      ccpchks = *blanks
CWDwAC                   else
CWDwAC                   eval      ccpchk = %subst(xohmisc:7:3)
CWDwAC                   eval      ccpchks = %subst(xohmisc:12:1)
CWAaAC                   eval      work6a = %subst(xohmisc:1:6)
CWAaAC                   move      work6a        mmddyy
CWAaAC                   move      mmddyy        mdy
CWAaAC                   move      mdy           shipdate
CWDaAC                   eval      citystate = %trim(xohccty)
CWDaAC                                         + ', '
CWDaAC                                         + xohcst
CWAaAC                   endif

KFSbAC                   when      client = Kellys
KFSbA
KFSbAC                   if        %found(ordh)
KFSbAC                   eval      work6a = %subst(xohmisc:1:6)
KFSbAC                   move      work6a        mmddyy
KFSbAC                   move      mmddyy        mdy
KFSbAC                   move      mdy           work8a
KFSbAC                   endif

JORdAC                   when      client = jordanos
JordAC                   eval      dsmisc = xohmisc
JORdAc                   z-add     dsSdte        zksDte
JORdAc                   move      zkmm          pkmm
JORdAc                   eval      pkds1 = '/'
JORdAc                   move      zkdd          pkdd
JORdAc                   eval      pkds2 = '/'
JORdAc                   move      zkyy          pkyy

HALbAC                   when      client = halsey
HALbAC                   if        not %found(ordh)
HALbAC                   eval      work8a = *blanks
HALbAC                   else
HALbAC                   eval      work6a = %subst(xohmisc:1:6)
HALbAC                   move      work6a        work6
HALbAC     *mdy          test(d)                 work6                  99
HALbAC                   if        *in99 = *off
HALbAC                   move      work6         mdy
HALbAC                   move      mdy           work8a
HALbAC                   endif
HALbAC                   endif

GFSeAC                   when      client = getfresh
HKWdAC                             or client = HKW
GLPcAC                             or client = Greenleaf
PFCbAC                             or client = Prestofoods
GFSeAC                   if        %found(ordh)
GFSeAC                   eval      work6a = %subst(xohmisc:1:6)
650gAC                   if        auditflag <> 'Y'
650gAC                   eval      auditflag = %subst(xohmisc:11:1)
GFSeAC                   endif
GFSeAC                   move      work6a        mmddyy
GFSeAC                   move      mmddyy        mdy
GFSeAC                   move      mdy           shipdate
GFSmAC                   eval      gfsmsc_base = xohmisc
GFSeAC                   endif
GFSeA
CLDwAC                   when      client = cityline
CLDwAC                   if        not %found(ordh)
CLDwAC                   eval      ccpchk = *blanks
CLDwAC                   eval      ccpchks = *blanks
CLDwAC                   else
CLDwAC                   eval      ccpchk = %subst(xohmisc:7:3)
CLDwAC                   eval      ccpchks = %subst(xohmisc:12:1)
530cAC                   eval      work6a = %subst(xohmisc:1:6)
530cAC                   move      work6a        work6
530cAC     *mdy          test(d)                 work6                  99
530cAC                   if        *in99 = *off
530cAC                   move      work6         mdy
530cAC                   move      mdy           work8a
530cAC                   endif
CLDwAC                   endif

SVLbAC                   when      client = saval
svlbA* customer number
svlbAC                   eval      work5 = xohcust

640cAC                   when      client = frf

530cAC                   eval      work8a = *blanks
FRFdAC                   eval      work3a = *blanks
CCPaAC                   eval      ccpchk = *blanks
CCPcAC                   eval      ccpchks = *blanks
530bAC                   eval      extStop = *blanks
530bAC                   if        %found(ordh)

FRFdAC                   eval      work3a = %subst(xohmisc:11:3)
CCPaAC                   eval      ccpchk = %subst(xohmisc:7:3)
CCPcAC                   eval      ccpchks = %subst(xohmisc:12:1)
530cAC                   eval      work6a = %subst(xohmisc:1:6)
530cAC                   move      work6a        work6
530cAC     *mdy          test(d)                 work6                  99
530cAC                   if        *in99 = *off
530cAC                   move      work6         mdy
530cAC                   move      mdy           work8a
530cAC                   endif
530cAC                   endif

DRYfAC                   when      client = dairyland
DRYiAC                   eval      deliverydate2 = *blanks
DRYfAC                   eval      work6a = %subst(ohmisc:1:6)
DRYfAC                   move      work6a        mmddyy
DRYfAC     *mdy          test(d)                 mmddyy                 99
DRYfAC                   if        *in99 = *off
DRYfAC                   move      mmddyy        mdy
DRYfAC                   move      mdy           usadate
DRYfAC                   move      usadate       deliverydate2
DRYfAC                   endif

CBIhAC                   when      client = cheney
CBIhAC                   eval      dsmisc = xohmisc
CBIhAC                   eval      t#truk = *blanks
CBIhAC                   if        ohtype = 'W'
CBIhAC                   eval      t#truk = ohtruk
CBIhAC                   endif
      * In cheney still,
730eAC                   select
730eAC                   when      ohaorda <> *blanks
730eAC                   eval      work8a = %subst(ohaorda:1:8)
730eAC                   eval      work11b = %subst(ohaorda:1:11)
730eAC                   other
730eAC                   if        not %found(ordh)
SWTbAC                   eval      work8a = *blanks
730eAC                   eval      work11b = *blanks
730eAC                   else
SWTbAC                   eval      work8a = %char(ohcord)
730aAC                   eval      work11b = %char(ohcord)
730eAC                   endif
730aAC                   endsl

730gAC                   select
730gAC                   when      ohacusta <> *blanks
730gAC                   eval      work11a = %subst(ohacusta:1:11)
730gAC                   other
730gAC                   if        not %found(ordh)
730gAC                   eval      work11a = *blanks
730gAC                   else
730gAC                   eval      work11a = %char(xohcust)
730gAC                   endif
730gAC                   endsl

CCPaAC                   endsl

530bAC                   call      @getstop
530bAC                   parm      '*ORDSTP'     $lcmd
530bAC                   parm                    $pwhse
530bAC                   parm                    $prtid
530bAC                   parm                    lbord
530bAC                   parm      *zeros        $pdstp
530bAC                   parm                    $phstp
530bAC                   if        $phstp <> *zeros
640vDC*                  eval      work3 = $phstp
640vMC                   eval      work3=
640vMC                               %dec(%subst(%editc($phstp:'X'):3:3):3:0)
530bAC                   eval      extstop = %char(work3)
640hAC                   else
640hAC                   eval      extstop = %char(lbstop)
NCSgAC                   endif

530bAC                   endsr
     *----------------------------------------------------------------
GFCgA*  getORDHM  Get Order Header Miscellaneous Record.
     *----------------------------------------------------------------
GFCgAC     getORDHM      begsr

     C     keyodh        chain     ordhm

     C                   select
     C                   when      not %found(ordhm)
     C                   eval      viphm2_ohcusn = *blanks
dry AC                   eval      dryhm1_trkid = *blanks
DRYfAC                   eval      dryhm1_voyid = *blanks
DRYfAC                   eval      dryhm2_motcd = *blanks
DRYfAC                   eval      methodofdlvry = *blanks
DRYfAC                   eval      cruiseshipflg = *blanks

dry AC                   when      client = dairyland
dry AC                   eval      dryhm1_base = hmmsc1
DRYfAC                   eval      dryhm2_base = hmmsc2
DRYfAC                   if        dryhm2_motcd <> *blanks
DRYfAC                   call      'GETMOT'
DRYfAC                   parm                    dryhm2_motcd
DRYfAC                   parm                    methodofdlvry
DRYfAC                   parm                    cruiseshipflg
     C                   parm                    $rtn              8
DRYfAC                   endif
DRYfAC                   other
     C                   eval      viphm2_base = hmmsc2
     C                   endsl

GFCgAC                   endsr
CWDaA*----------------------------------------------------------------
CWDaA*  getORDD   Get Order Detail Record.
CWDaA*----------------------------------------------------------------
CWDaAC     getORDD       begsr
CWDaA
CWAaAC     keyodd        chain     ordd
CWAaA
CWDaAC                   endsr
640cA*----------------------------------------------------------------
640cA*  getORDDM  Get Order Detail Misc Record.
640cA*----------------------------------------------------------------
640cAC     getORDDM      begsr
640cA
640cAC     keyodm        chain     orddm
640cA
640cAC                   select
640cAC                   when      not %found(orddm)
640cAC                   eval      retailprice = *blanks
640cAC                   eval      pricecode = *blanks
640cAC                   eval      statejurcode = *blanks
640cAC                   eval      statejurname = *blanks
640cAC                   eval      countyjurcode = *blanks
640cAC                   eval      countyjurname = *blanks
640cAC                   eval      cityjurcode = *blanks
640cAC                   eval      cityjurname = *blanks
640cAC                   eval      datecode = *blanks
640cAC                   eval      dealcode = *blanks
640cAC                   eval      recapflag = 'N'
640cAC                   eval      taxamount = *blanks
640cAC                   eval      recapjurname1 = *blanks
640cAC                   eval      recapjurname2 = *blanks
640cAC                   eval      recaptaxamt = *blanks
640eAC                   eval      rtxdm2_omupcv = *blanks
640eAC                   eval      rtxdm2_omtnme = *blanks
cwduMC                   eval      cwddm1_base = *blanks
cwdkMC                   eval      cwddm2_base = *blanks
cwduD ***                eval      cwddm2_qoh  = *zeros
cwduMC                   eval      cwddm1_qoh  = *zeros
cwduD ***                eval      cwddm2_eqoh  = *zeros
cwduMC                   eval      cwddm1_eqoh  = *zeros
SFGiAC                   eval      sgcdm1_base = *blanks
SFGiAC                   eval      imp_flg = *off
HMWaAC                   eval      hmwdm1_omsubsts = *blanks
CPCbAC                   eval      cpcdm1_ombchpck = 'N'
CPCbAC                   eval      cpcdm1_omchemcd = *blanks
ISYaAC                   eval      omodsc = *blanks
ISYaAC                   eval      ompdsc = 'N'
ISYaAC                   eval      omrdsc = 'N'
ISYaAC                   eval      omcbox = 'N'
ISYaAC                   eval      omcexp = 'N'
640cA
640cAC                   when      client = citywholesale
640cA
640cAC                   eval      retailprice = %subst(ommsc1:1:7)
640cAC                   eval      pricecode = %subst(ommsc1:36:5)
640cAC                   eval      statejurcode = %subst(ommsc2:1:3)
640cAC                   eval      statejurname = %subst(ommsc2:4:15)
640cAC                   eval      countyjurcode = %subst(ommsc2:19:3)
640cAC                   eval      countyjurname = %subst(ommsc2:22:15)
640cAC                   eval      cityjurcode = %subst(ommsc2:37:3)
640cAC                   eval      cityjurname = %subst(ommsc3:1:15)
640cAC                   eval      datecode = %subst(ommsc3:16:2)
640cAC                   eval      dealcode = %subst(ommsc3:20:5)
640cAC                   eval      recapflag = %subst(ommsc3:25:1)
640cAC                   eval      taxamount = %subst(ommsc3:26:8)
640cAC                   eval      recapjurname1 = %subst(ommsc4:1:15)
640cAC                   eval      recapjurname2 = %subst(ommsc4:16:15)
640cAC                   eval      recaptaxamt = %subst(ommsc4:31:8)
SLBaA
SLBaAC                   when      client = silberman
SLBaAC                   eval      rtxdm2_base = ommsc2
SLBaAC                   eval      statejurname = %subst(rtxdm2_omtnme:1:14)
CWDgA
CWDgAC                   when      client = cashwa
cwduAC                   eval      cwddm1_base = ommsc1
cwduAC                   eval      cwddm2_base = ommsc2
cwduAC                   eval      retailprice = %subst(ommsc1:1:7)
cwduAC                   eval      pricecode = %subst(ommsc1:36:5)
cwduAC                   eval      statejurcode = %subst(ommsc2:1:3)
cwduAC                   eval      statejurname = %subst(ommsc2:4:15)
cwduAC                   eval      countyjurcode = %subst(ommsc2:19:3)
cwduAC                   eval      countyjurname = %subst(ommsc2:22:15)
cwduAC                   eval      cityjurcode = %subst(ommsc2:37:3)
cwduAC                   eval      cityjurname = %subst(ommsc3:1:15)
cwduAC                   eval      datecode = %subst(ommsc3:16:2)
cwduAC                   eval      dealcode = %subst(ommsc3:20:5)
cwduAC                   eval      recapflag = %subst(ommsc3:25:1)
cwduAC                   eval      taxamount = %subst(ommsc3:26:8)
cwduAC                   eval      recapjurname1 = %subst(ommsc4:1:15)
cwduAC                   eval      recapjurname2 = %subst(ommsc4:16:15)
cwduAC                   eval      recaptaxamt = %subst(ommsc4:31:8)
SFGiA
SFGiAC                   when      client = sgc
SFGiAC                   eval      sgcdm1_base = ommsc1
SFGiAC                   if        sgcdm1_ommpck = 'Y'
SFGiAC                   eval      imp_flg = *on
SFGiAC                   else
SFGiAC                   eval      imp_flg = *off
SFGiAC                   endif
HMWaA
HMWaAC                   when      client = hmwagner
HMWaAC                   eval      hmwdm1_base = ommsc1
YHAeA
YHAeAC                   when      client = yhata
YH2dAC                   eval      rtxdm2_base = ommsc2

GFSaAC                   when      client = getfresh
GFSaAC                   eval      gfsdm1_base = ommsc1
CPCbA
CPCbAC                   when      client = citywholesale
CPCbAC                   eval      cpcdm1_base = ommsc1

CPCbAC                   select
CPCbAC                   when      cpcdm1_omchemcd = 'RED'
CPCbAC                   eval      printcolor = 'RED'
CPCbAC                   when      cpcdm1_omchemcd = 'BLU'
CPCbAC                   eval      printcolor = 'BLUE'
CPCbAC                   when      cpcdm1_omchemcd = 'ORG'
CPCbAC                   eval      printcolor = 'ORANGE'
CPCbAC                   other
CPCbAC                   eval      printcolor = *blanks
CPCbAC                   endsl
ISYaAC                   when      client = isupply
ISYa C                   eval      dsmsc1 = ommsc1
ISYa C                   eval      dsmsc2 = ommsc2
ISYa C                   eval      dsmsc3 = ommsc3
ISYa C                   eval      dsmsc4 = ommsc4

640eAC                   endsl
640cA
640cAC                   endsr
svleA*----------------------------------------------------------------
svleA*  getRTEHED Get Route Header Record.
svleA*----------------------------------------------------------------
svleAC     getRTEHED     begsr

svleAC     keyrte        chain     rtehed

svleAC                   eval      deliverydate = *blanks
svleAC                   eval      mdy2 = *blanks
svleAC                   if        %found(rtehed)
svleA* delivery date

svleAC     *iso          TEST(DE)                rhrptd
svleAC                   if        not %error
svleAC                   move      rhrptd        isodate
svleAC                   adddur    1:*D          isodate
svleAC                   move      isodate       mdydate
svleAC                   extrct    mdydate:*M    month             2
svleAC                   extrct    mdydate:*D    day               2
svleAC                   extrct    mdydate:*Y    year              2
svleAC                   eval      mdy2 = month + day + year
svleAC                   move      mdydate       deliverydate
svleAC                   endif

svleAC                   endif

svleAC                   endsr
640pA*----------------------------------------------------------------
640pA*
640pA*  zzinz    Extra program initialization. Called from *INZSR.
640pA*
640pAC     zzinz         begsr
720fAc*
720fAc*   Determine if using TruckBUilder Enhanced
720fAc*
720fA /free
720fA      tbWhse = $pwhse;
720fA      GetTBType(tbWhse: $prtid: tbType);
720fA      if tbType = 'E';
720fA        tbEnhanced = *on;
720fA        tbPalletType = 'P';
720fA      else;
720fA        tbEnhanced = *off;
720fA        tbPalletType = 'O';
720fA      endif;
730pA      if $pgen <> 1;
730pA        tbPalletType = 'O';
730pA      endif;
720fA /end-free

640pAC                   eval      mpflag = 'N'
640pAC                   exsr      initpd
640pAC                   exsr      loadpd

640pA *   Set data area PIRROBIN to 'Y'.  That will activate Zone
640pA *   maintenance to allow device group codes.

640yD ***                call      'ZH122CL'
640yD ***                parm      'PFMT'        #PGM
640yD ***                parm                    $AUT

640pAC                   endsr
ctwaA*----------------------------------------------------------------
ctwaA*  zzlin14up  - Load line 1 of retail 4up labels
ctwaA*----------------------------------------------------------------
ctwaAC     zzline14up    begsr

ctwaAC                   select
ctwaAC                   when      w1pick = 1
ctwaAC                   eval      retline1 = %trim(lbitem) + ' ' +
ctwaAC                                        %trim(itdesc)
ctwaAC                   eval      zffnam = 'Item/Desc'

ctwaAC                   when      retailrows <> w1pick
ctwaAC                   eval      retline1 = %replace
ctwaAC                             (datecode:retline1:2:2)
ctwaAC                   eval      retline1 = %replace
ctwaAC                             (pricecode:retline1:6:5)
ctwaAC                   eval      retline1 = %replace
ctwaAC                             (datecode:retline1:12:2)
ctwaAC                   eval      retline1 = %replace
ctwaAC                             (pricecode:retline1:16:5)
ctwaAC                   eval      retline1 = %replace
ctwaAC                             (datecode:retline1:22:2)
ctwaAC                   eval      retline1 = %replace
ctwaAC                             (pricecode:retline1:26:5)
ctwaAC                   eval      retline1 = %replace
ctwaAC                             (datecode:retline1:32:2)
ctwaAC                   eval      retline1 = %replace
ctwaAC                             (pricecode:retline1:36:5)
ctwaAC                   eval      zffnam = 'DATE/PRICE'

ctwaAC                   when      retailrows = w1pick
ctwaAC                             and retailleft <> *zeros
ctwaAC                   select
ctwaAC                   when      retailleft = 1
ctwaAC                   eval      retline1 = %replace
ctwaAC                             (datecode:retline1:2:2)
ctwaAC                   eval      retline1 = %replace
ctwaAC                             (pricecode:retline1:6:5)
ctwaAC                   when      retailleft = 2
ctwaAC                   eval      retline1 = %replace
ctwaAC                             (datecode:retline1:2:2)
ctwaAC                   eval      retline1 = %replace
ctwaAC                             (pricecode:retline1:6:5)
ctwaAC                   eval      retline1 = %replace
ctwaAC                             (datecode:retline1:12:2)
ctwaAC                   eval      retline1 = %replace
ctwaAC                             (pricecode:retline1:16:5)
ctwaAC                   when      retailleft = 3
ctwaAC                   eval      retline1 = %replace
ctwaAC                             (datecode:retline1:2:2)
ctwaAC                   eval      retline1 = %replace
ctwaAC                             (pricecode:retline1:6:5)
ctwaAC                   eval      retline1 = %replace
ctwaAC                             (datecode:retline1:12:2)
ctwaAC                   eval      retline1 = %replace
ctwaAC                             (pricecode:retline1:16:5)
ctwaAC                   eval      retline1 = %replace
ctwaAC                             (datecode:retline1:22:2)
ctwaAC                   eval      retline1 = %replace
ctwaAC                             (pricecode:retline1:26:5)
ctwaAC                   endsl
ctwaAC                   eval      zffnam = 'DATE/PRICE'

ctwaAC                   endsl

ctwaAC                   endsr

ctwaA*----------------------------------------------------------------
ctwaA*  zzlin24up  - Load line 2 of retail 4up labels
ctwaA*----------------------------------------------------------------
ctwaAC     zzline24up    begsr

ctwaAC                   eval      retline2 = *blanks
ctwaAC                   select
ctwaAC                   when      w1pick = 1
ctwaAC                   eval      temp3a = %subst(lbdisp:1:3)
ctwaAC                   eval      temp8 = %subst(lbdisp:4:8)
ctwaAC                   eval      temp12a = temp3a + '-' + temp8
ctwrD ***                eval      temp7a = %char(ohcord)
ctwaAC                   eval      retline2 = %trim(slot) + ' ' +
ctwrD ***                                     %trim(temp12a) + ' ' +
ctwrMC                                        %trim(temp12a)
ctwrD ***                                     %trim(order) + ' ' +
ctwrD ***                                     %trim(temp7a)
ctwaAC                   eval      zffnam = 'Slot/Cord'
      * Full row
ctwaAC                   when      retailrows <> w1pick
ctwaAC                   eval      retline2 = %replace
ctwaAC                             (lbitem:retline2:2:7)
ctwaAC                   eval      retline2 = %replace
ctwaAC                             (lbitem:retline2:13:7)
ctwaAC                   eval      retline2 = %replace
ctwaAC                             (lbitem:retline2:23:7)
ctwaAC                   eval      retline2 = %replace
ctwaAC                             (lbitem:retline2:34:7)
ctwaAC                   eval      zffnam = 'ITEM'

ctwaAC                   when      retailrows = w1pick
ctwaAC                             and retailleft <> *zeros
ctwaAC                   select
ctwaAC                   when      retailleft = 1
ctwaAC                   eval      retline2 = %replace
ctwaAC                             (lbitem:retline2:2:7)
ctwaAC                   when      retailleft = 2
ctwaAC                   eval      retline2 = %replace
ctwaAC                             (lbitem:retline2:2:7)
ctwaAC                   eval      retline2 = %replace
ctwaAC                             (lbitem:retline2:13:7)
ctwaAC                   when      retailleft = 3
ctwaAC                   eval      retline2 = %replace
ctwaAC                             (lbitem:retline2:2:7)
ctwaAC                   eval      retline2 = %replace
ctwaAC                             (lbitem:retline2:13:7)
ctwaAC                   eval      retline2 = %replace
ctwaAC                             (lbitem:retline2:23:7)
ctwaAC                   endsl
ctwaAC                   eval      zffnam = 'ITEM'
ctwaAC                   endsl

ctwaAC                   endsr

ctwaA*----------------------------------------------------------------
ctwaA*  zzlin34up  - Load line 3 of retail 4up labels
ctwaA*----------------------------------------------------------------
ctwaAC     zzline34up    begsr

ctwaAC                   eval      retline3 = *blanks
ctwaAC                   select
ctwaAC                   when      w1pick = 1
ctwaAC                   eval      temp5a = %char(lbqpck)
ctwrAC                   eval      temp7a = %char(ohcord)
ctwaAC                   eval      retline3 = %trim(quantity) + ' ' +
ctwaAC                                        %trim(temp5a) + ' ' +
ctwaAC                                        outwrd        + ' ' +
ctwrD ***                                     dealcode
ctwrMC                                        dealcode     + '       ' +
ctwrAC                                        %trim(order) + ' ' +
ctwrAC                                        %trim(temp7a)
ctwaAC                   eval      zffnam = 'Quantity'

ctwaAC                   when      retailrows <> w1pick
ctwaAC                   eval      temp7a = %char(lblbl#)
ctwaAC                   eval      retline3 = %replace
ctwaAC                             (temp7a:retline3:2:7)
ctwaAC                   eval      retline3 = %replace
ctwaAC                             (temp7a:retline3:13:7)
ctwaAC                   eval      retline3 = %replace
ctwaAC                             (temp7a:retline3:23:7)
ctwaAC                   eval      retline3 = %replace
ctwaAC                             (temp7a:retline3:34:7)
ctwaAC                   eval      zffnam = 'Lbl#'

ctwaAC                   when      retailrows = w1pick
ctwaAC                             and retailleft <> *zeros
ctwaAC                   eval      temp7a = %char(lblbl#)
ctwaAC                   select
ctwaAC                   when      retailleft = 1
ctwaAC                   eval      retline3 = %replace
ctwaAC                             (temp7a:retline3:2:7)
ctwaAC                   when      retailleft = 2
ctwaAC                   eval      retline3 = %replace
ctwaAC                             (temp7a:retline3:2:7)
ctwaAC                   eval      retline3 = %replace
ctwaAC                             (temp7a:retline3:13:7)
ctwaAC                   when      retailleft = 3
ctwaAC                   eval      retline3 = %replace
ctwaAC                             (temp7a:retline3:2:7)
ctwaAC                   eval      retline3 = %replace
ctwaAC                             (temp7a:retline3:13:7)
ctwaAC                   eval      retline3 = %replace
ctwaAC                             (temp7a:retline3:23:7)
ctwaAC                   endsl
ctwaAC                   eval      zffnam = 'LBL#'
ctwaAC                   endsl

ctwaAC                   endsr

ctwaA*----------------------------------------------------------------
ctwaA*  zzlin44up  - Load line 4 of retail 4up labels
ctwaA*----------------------------------------------------------------
ctwaAC     zzline44up    begsr

ctwaAC                   eval      retline4 = *blanks
ctwhD ***                move      retailprice   temp72
ctwaAC                   eval      temp7a = *blanks
ctwhD ***                eval      temp7a = %char(temp72)
ctwhMC                   eval      temp7a = retailprice
ctwaAC                   select
ctwaA*    4-up header
ctwaAC                   when      w1pick = 1
ctwaAC                   eval      zffnam = 'Filler'
ctwaA*    4 labels
ctwaAC                   when      retailrows <> w1pick
ctwaAC                   eval      retline4 = %replace
ctwaAC                             (temp7a:retline4:2:7)
ctwaAC                   eval      retline4 = %replace
ctwaAC                             (temp7a:retline4:13:7)
ctwaAC                   eval      retline4 = %replace
ctwaAC                             (temp7a:retline4:23:7)
ctwaAC                   eval      retline4 = %replace
ctwaAC                             (temp7a:retline4:34:7)
ctwaAC                   eval      zffnam = 'RETAIL PRICE'
ctwaA*    remander labels
ctwaAC                   when      retailrows = w1pick
ctwaAC                             and retailleft <> *zeros
ctwaAC                   select
ctwaAC                   when      retailleft = 1
ctwaAC                   eval      retline4 = %replace
ctwaAC                             (temp7a:retline4:2:7)
ctwaAC                   when      retailleft = 2
ctwaAC                   eval      retline4 = %replace
ctwaAC                             (temp7a:retline4:2:7)
ctwaAC                   eval      retline4 = %replace
ctwaAC                             (temp7a:retline4:13:7)
ctwaAC                   when      retailleft = 3
ctwaAC                   eval      retline4 = %replace
ctwaAC                             (temp7a:retline4:2:7)
ctwaAC                   eval      retline4 = %replace
ctwaAC                             (temp7a:retline4:13:7)
ctwaAC                   eval      retline4 = %replace
ctwaAC                             (temp7a:retline4:23:7)
ctwaAC                   endsl
ctwaAC                   eval      zffnam = 'RETAIL PRICE'

ctwaAC                   endsl

ctwaAC                   endsr

     *----------------------------------------------------------------
510bA*  zzzInzZbrLog  Initialization for zbrlog.
510bA*
510bACSR   zzzInzZbrLog  begsr

510bA*  Get out if not logging.

510bAC     logzebra      cabeq     *off          endInzZbrLog

510cM*  Delete existing zbrlogf records for route/szone

510bAC     keyzbr        setll     zbrlogf
510bAC                   dow       forever = forever
510bAC     keyzbr        reade(e)  zbrlogf
510bAC                   if        %eof
510bAC                   leave
510bAC                   endif
510cAC                   if        zfszon <> $pszon
510cAC                   iter
510cAC                   endif
510bAC                   delete    zfrec
510bAC                   enddo

510cM*  Delete existing zbrlogs records for route/szone

510bAC     keyzbr        setll     zbrlogs
510bAC                   dow       forever = forever
510bAC     keyzbr        reade(e)  zbrlogs
510bAC                   if        %eof
510bAC                   leave
510bAC                   endif
510cAC                   if        zsszon <> $pszon
510cAC                   iter
510cAC                   endif
510bAC                   delete    zsrec
510bAC                   enddo

     *  Initialize sequence number.

510bAC                   eval      zfseq# = 0

510bAC     endInzZbrLog  endsr
     *----------------------------------------------------------------
     *  Output Specs
     *
     Opfmtpr    e            #str           1
     O                       @outpt             198
640cAOpfmtpr2   e            #str2          1
640cAO                       @outpt             198
640cAOpfmtpr3   e            #str3          1
640cAO                       @outpt             198
CSPlAOpfmtpr4   e            #str4          1
CSPlAO                       @outpt             198
CB2iAOpfmtpr5   e            #str5          1
CB2iAO                       @outpt             198

720aA*----------------------------------------------------------------
720aA*  IFSWriteLine    Write line to IFS file
720aA*----------------------------------------------------------------
720aA
720aAp IFSWriteLine    b
     d IFSWriteLine    pi
     d  fileNum                       3  0 const

ifs Ad newLine         s           3072    varying
ifs Ad i               s              5  0
ifs Ad zCmd            s              3

      /free

ifs A  // Strip out unwanted commands
ifs A  // www.labelary.com only allows 50 labels per file
ifs A  // They count every ^XA as a new label
ifs A  // MRC puts in a lot of extra ^XA ^XZ combinations around other commands
ifs A
ifs A  newLine = '';
ifs A  for i = 1 to %len(wLine);
ifs A    monitor;
           if i > %len(wLine)-2;
             zCmd = '';
           else;
ifs A        zCmd = %subst(wLine: i: 3);
           endif;
ifs A
ifs A      select;
750jA
750jA        // For pass 2 we are assuming ZPL has been cleaned up
750jA        // using program ZPLCLEANUP.
750jA        // And, we don't need to count labels for pass 2.
750jA
750jA        when fillb1pass = 2;
750jA          newLine += %subst(wLine: i: 1);
ifs A
ifs A        // We only want 1 XA command per label
ifs A
ifs A        when zCmd = '^XA';
ifs A          if xaFlag(fileNum);
ifs A            i += 2;
ifs A            iter;
ifs A          else;
ifs A            xaFlag(fileNum) = *on;
ifs A            newLine += %subst(wLine: i: 3);
ifs A            i += 2;
ifs A          endif;
ifs A
ifs A        // We only want the XZ that comes after the PR command
ifs A
ifs A        when zCmd = '^XZ';
ifs A          if not prFlag(fileNum);
ifs A            i += 2;
ifs A            iter;
ifs A          else;
ifs A            xaFlag(fileNum) = *off;
ifs A            prFlag(fileNum) = *off;
ifs A            newLine += %subst(wLine: i: 3);
ifs A            i += 2;
ifs A          endif;
ifs A
ifs A        // There is only 1 PR command within a label format, so
ifs A        // we will use it for counting labels.
ifs A
ifs A        when zCmd = '^PR';
ifs A          prFlag(fileNum) = *on;
ifs A          wLabelCount(fileNum) += 1;
ifs A          newLine += %subst(wLine: i: 3);
ifs A          i += 2;
ifs A
ifs A        other;
ifs A          newLine += %subst(wLine: i: 1);
ifs A
ifs A      endsl;
ifs A
ifs A    on-error;
ifs A      newLine += %subst(wLine: i: 1);
ifs A      zCmd = '';
ifs A
ifs A    endmon;
ifs A  endfor;
ifs A
ifs A  if newLine = '';
ifs A    return;
ifs A  endif;

750fA  // Append line to outStr
750fA
750fA  outStr += newLine;

       return;

      /end-free

     p IFSWriteLine    e

750fA*----------------------------------------------------------------
750fA*  WriteLABELOUT     Write label to LABELOUT
750fA*----------------------------------------------------------------
750fA
750fAp WriteLABELOUT   b
     d WriteLABELOUT   pi

     d start           s              5  0
     d charLeft        s              5  0
     d maxOutputLen    s              5  0
     d outStrLen       s              5  0
     d rtid            s                   like($prtid)
     d lblcnt          s                   like(w1pick)
     d lbl             s                   like(lblbl#)
     d sqlCount        s             10i 0
     d temp3           s              3
     d writeBLD        s               n

      /free

       maxOutputLen = %size(looutput) - 2;
       outstrLen = %len(outStr);

       if outstrLen = 0;
         return;
       endif;

       select;
         when $pCmd = '*BLTTEST';
           rtid = '';
         when $pCmd = '*TEST1';
           rtid = 'TEST1';
         when $pCmd = '*TEST2';
           rtid = 'TEST2';
         other;
           rtid = $prtid;
       endsl;

       temp3 = %subst(kyfmt: 1: 3);

       if temp3='SET' or temp3='PAL';
         lbl = 0;
       else;
         lbl = lblbl#;
       endif;

       select;
         when temp3='SET' or temp3='PAL';
           lblcnt = fmtCount;
         when combo or w1pick = 0;
           lblcnt = 1;
         other;
           lblcnt = w1pick;
       endsl;

       // Get out if records alread exist for label number

       exec sql select count(*) into :sqlCount
                from LABELOUT
                where lowhse = :$pwhse
                  and lortid = :rtid
                  and lotrn = :lbtrn#
                  and lolbl = :lbl
                  and lolblcnt = :lblcnt
                  and lofmt = :kyfmt
                fetch first 1 rows only;

       if sqlstt = sqlSuccess and sqlCount > 0;
         return;
       endif;

       // Write string to LABELOUT

       lopart = 0;
       looutlen = outStrLen;
       start = 1;

       dou start > loOutLen;

         charLeft = outstrLen - start + 1;

         if charLeft <= maxOutputLen;
           looutput = %subst(outStr: start);
           start += charLeft;
         else;
           looutput = %subst(outStr: start: maxOutputLen);
           start += maxOutputLen;
         endif;

         lopart += 1;

         exec sql
           insert into
           labelout (LOWHSE, LORTID, LOPRTSEQ, LOPART, LOSET, LOFMT,
                     LOTRN, LOLBL, LOLBLTYPE, LOLBLCOMBO, LOLBLCNT,
                     LOPLID, LOGEN, LOSZON, LOADDTS,
                     LOADDUSER, LOADDJOB, LOADDJOBU, LOADDJOBN,
                     LOOUTLEN, LOOUTPUT )
           values   (:$pwhse, :rtid, :zsseq#, :lopart, :kyset, :kyfmt,
                     :lbtrn#, :lbl, :lbtype, :combo, :lblcnt,
                     :lbpal#, :$pgen, :$pszon, CURRENT TIMESTAMP,
                     :#curruser, :#jobnbr, :#user, :#job,
                     :looutlen, :looutput );

          if sqlstt <> sqlSuccess;
          endif;

       enddo;

750jA  // Write data record to be used with stored label format
750jA
750jA    monitor;
750jA      if %subst(kyfmt: 1: 4) = 'PICK';
750jA        writeBLD = *on;
750jA      else;
750jA        writeBLD = *off;
750jA      endif;
750jA    on-error;
750jA      writeBLD = *off;
750jA    endmon;
750jA
750jA    if writeBLD;
750jA
750jA      lopart = 1;
750jA      looutput = outStrZdta + '^XZ';
750jA      looutlen = %len(outStrZDta);
750jA      exec sql
750jA        insert into
750jA        labelout (LOWHSE, LORTID, LOPRTSEQ, LOPART, LOSET, LOFMT,
750jA                  LOTRN, LOLBL, LOLBLTYPE, LOLBLCOMBO, LOLBLCNT,
750jA                  LOPLID, LOGEN, LOSZON, LOADDTS,
750jA                  LOADDUSER, LOADDJOB, LOADDJOBU, LOADDJOBN,
750jA                  LOOUTLEN, LOOUTPUT )
750jA        values   (:$pwhse, :rtid, :zsseq#, :lopart, :kysetzdta, :kyfmt,
750jA                  :lbtrn#, :lbl, :lbtype, :combo, :lblcnt,
750jA                  :lbpal#, :$pgen, :$pszon, CURRENT TIMESTAMP,
750jA                  :#curruser, :#jobnbr, :#user, :#job,
750jA                  :looutlen, :looutput );
750jA
750jA       if sqlstt <> sqlSuccess;
750jA       endif;
750jA
750jA    endif;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**   OVRPRTF statment
OVRPRTF FILE(PFMTPR) OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
OVRPRTF FILE(PFMTPR)           outq(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
OVRPRTF FILE(PFMTPR5) OUTQ(*DEV) DEV(PRTPAL)
OVRPRTF FILE(PFMTPR5) OUTQ(*DEV) DEV(PRTPAL2)
OVRPRTF FILE(PFMTPR5) OUTQ(*DEV) DEV(PRTPRD2)
OVRPRTF FILE(PFMTPR5) OUTQ(*DEV) DEV(PRTPRD)
OVRPRTF FILE(PFMTPR5) OUTQ(*DEV) DEV(GWPLTL)
OVRPRTF FILE(PFMTPR5) OUTQ(*DEV) DEV(PRTPAL3)
OVRPRTF FILE(PFMTPR5) OUTQ(*DEV) DEV(PRTGRPAL)
OVRPRTF FILE(PFMTPR5) OUTQ(*DEV) DEV(PRTGRPAL2)
OVRPRTF FILE(PFMTPR5) OUTQ(*DEV) DEV(PRTSTPAL)
OVRPRTF FILE(PFMTPR5) OUTQ(*DEV) DEV(PRTSTPAL2)
OVRPRTF FILE(PFMTPR5) OUTQ(*DEV) DEV(PRTMLKP)
OVRPRTF FILE(PFMTPR5) OUTQ(*DEV) DEV(PRTTFPAL)
OVRPRTF FILE(PFMTPR5) OUTQ(*DEV) DEV(PRTTFPAL2)
OVRPRTF FILE(PFMTPR5) OUTQ(*DEV) DEV(PRTEXP2)
**   TTLDSC
<<< TOTALS >>>
