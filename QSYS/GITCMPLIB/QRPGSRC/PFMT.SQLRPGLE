      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
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
642iA*    03/08/12  JCJ  6.42i
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
642mA*    05/30/12  JCJ  6.42m
     *      - Ehn:  Add code for new PICKEXP label.
642nA*    06/09/12  GJA  6.42n
     *      - Ehn:  Add code for new PICKEXP label-line 2
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
     *
700 A*    04/16/15  MLB  7.00
     *      - Enh: Added DRI interface support for License Info.
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
700gA*    09/11/15  JCJ  7.00g
     *      - Fix: Changed to grab correct trax number.
700hA*    08/04/15  JCJ  7.00h
     *      - Enh: created SR lblcustnotes.
700iA*    09/11/15  JCJ  7.00i
     *      - Fix: populated dsstp1 & dsstp2 for bulk picks.
     *
700jA*    09/22/15  NLK  7.00j
     *      - Enh: print the new PICK label for AMP orders
     *        AMP order is written to new file AMPxRef due to
     *        Y in col 13 of field HMMSC4 in ORDHM
     *      - Enh: Added AMPBOX file
700kA*    10/12/15  JCJ  7.00k
     *      - Enh: Added call to program getpltvid to retrive the
     *             voice id to be printed on the pallet label.
700lA*    11/30/15  JCJ  7.00l
     *      - Enh: Added palet label reprint logic.
700mA*    12/16/15  MLB  7.00m
     *      - Fix: Added indicator 78 to ReadE in SETEND, was missing
     *        on SGC mod and PFC mod. Caused PIR Merge pick labels to
     *        not print.
700nA*    01/22/16  JCJ  7.00n
     *      - Enh: reserved for AMP box code
700oA*    01/22/16  JCJ/MLB  7.00o
     *      - Fix: Revised routine OPNPRT to add test for OPPDEV = *JOB
     *             so that printer defined for pick zone will be used.
700pA*    01/29/16  JCJ/MLB  7.00p
     *      - Fix: Changed to grab correct trax number in routine,
     *        SETEND. Was not retrieving Trax#.
700qA*    02/23/16  MLB  7.00q
     *      - Fix: Change to 7.00p mod. Added read of ORDP2 into routine
     *        LBLZPS.  Was printing first Trax# for multiple cases.
700sA*    03/07/16  JCJ/NLK  7.00s
     *        Fix: AMPBOX not printing on Belt Printer
     *        Fix: AMP Picking Label & AMP BOX Label
700tA*    03/11/16  NLK  7.00t
     *        Enh: Label change to print BOX not TOTE
700u *    03/14/16  GJA  7.00u
     *        Recompile only for LABEL32X change
700v *    04/19/16  NLK  7.00v
     *        FIX: AMPxRef1 should contain RouteID/now use Ref13
     *        GLP states AMP orders can add more qty of one item
     *          after the first AMP order is already picked.
700w *    05/09/16  JCJ  7.00w
     *        Enh: Reserved
700x *    06/14/16  NLK  7.00x
     *        Enh: Increased AMPBOX# from 3.0 to 5.0
700yA*    07/06/16  MLB  7.00y
     *      - Fix: Revised 5.10e mod to increase size of DSSPCS to 5,0
     *        from 4,0.
700zA*    08/26/16  JCJ  7.00z
     *      - Enh: Added Lookup of Truck Description for printing on
     *             the SETHED label.
701aA*    08/30/16  JCJ  7.01a
     *      - Enh: Added allergen code.
     *
701bA*    08/31/16  JCJ  7.01b
     *      - Enh: Created routine FILINT in order to translate intermec
     *        commands like '<STX>' into a readable command like '^B'.
     *      - Enh: Revised FILLB1 to assume that a Dakota field marker
     *        always has a number following the '<'. When a letter is
     *        found, assume Intermec command.
     *
701cA*    11/10/16  DAS  7.01c
     *      - Enh: Revised mainline to work with by Column option
     *
701dA*    01/12/17  JCJ  7.01d
     *      - Ehn: Updated Gen Pick Data Structure.
     *
701eA*    12/19/16  JCJ  7.01e
     *      - Fix: Added file ITEMMSC to PRTLBL to get Brand.
701fA*    10/18/16  JCJ  7.01f
     *      - Enh: Added logic for special merge zone printing.
701gA*    12/02/16  MLB  7.01g
     *      - Fix: Revised 7.01c mod to not try to print Zone pick up
     *        labels when doing will-call routes.
701hA*    03/22/16  JCJ  7.01h
     *      - Enh: Add UOM file.
710aA*    08/01/17  JCJ  7.10a
     *      - Ehn: Added License number to FILLB2.
710b *    08/21/17  RTR  7.10b
     *      - Enh: Added Variable 459 for GS1 barcode. Originally for
     *        Saval Foods.
710c *    11/15/17  RTR  7.10c
     *      - Fix: mod 650b pallet id first 2 chars were wrong because
     *        $cstr wasn't being cleared first.
710dA*    01/12/17  JCJ  7.10d
     *      - Enh: getTrkComp
     *
720aA*    02/14/18  DAS  720a
     *      - Enh: Added optional parameter $pOutType
     *      - Enh: Revised to base output on $pOutTYpe
     *             'I' = Write to IFS files
     *             'Q' = Ouptut to QPRINT
     *             anything else = Normal spool file output
     *
720bA*    06/27/18  JCJ  720b
     *      - Enh: Moved printing of pallet label after Zone Pickup
     *             label.
     *
720cA*    01/30/18  NLK  7.20c (originally 7.20a)
     *      - Fix: Labels when OverFlow Pallet has same Trn# now
     *             since new OR630 major changes by Trn#, stop seq
720dA*    08/24/18  NLK  7.20d
     *      - Fix: PRTSEL vs PRTXDK - XDK was missing going to get
     *        ORDHM and ORDD causing invalid oditem value in barcode
     *
720eA*    10/02/18  JCJ  7.20e
     *      - Enh: Added extended item desc processing to PRTXDK.
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
720jA*    12/12/18  JCJ  7.20j
     *      - Enh: Added extended item desc processing to PRTLBL.
720kA*    12/17/18  LMC  7.20k
     *      - Enh: UCI Tracking
730aA*    02/01/19  JCJ  730a
     *      - Added line 3 & 4 ITEMNOTEs.
730bA*    02/13/19  DAS  730b
     *      - Wrapped call to IFSClosePgm with outputType check.
730cA*    02/13/19  JCJ  730c
     *      - populate route id in PRTLBL before printing END label.
730dA*    02/20/19  JCJ  730d
     *      - force label rotation to normal.
730eA*    03/15/19  JCJ  730e
     *      - added new order header process.
730fA*    04/04/19  JCJ  730f
     *      - added variable 461 for new loader number format.
     *      - variable 461 is replacing 455**IF only needing 9 long
730gA*    04/12/19  JCJ  730g
     *      - added new customer number process.
730hA*    05/16/19  JCJ  730h
     *      - Fix: added to 640k UOM check.  Prevents duplicate UOM
     *        warning labels.
730iA*    05/28/19  DAS  730i
     *      - Revised usage of LABEL32D to be controled by new
     *        variable useDFPICKordB. The name was chosen because it
     *        is similar to what is used in OR620 (curDFPICKordB).
     *        LALBEL32 puts the LBLBL2 field before LBWHDP.
     *        Note, the hardcoded client code was removed for clarity
     *        and moved into *INZSR to set new field.
     *        In the future, hard coding is not necessary and will
     *        be handled through user-defined DFPICK.
730jA*    05/21/19  KDE  7.30j
     *      - Enh: Print in lvl2 order if soft coding exist
730kA*    07/16/19  NLK  7.30k
     *      - Enh: Add RTID to END label
730lA*    07/19/19  JCJ  7.30l
     *      - Enh: Add chain to PIRITEM in SETEND to populate ITITEM
     *        used to populate V459
730mA*    08/14/19  DAS  7.30m
     *      - Enh: Revised to force Flex Pick label to be a combo label
     *      - Enh: For Pick-To-Weight label, getting label qty (weight)
     *        and UOM from LABELUM file.
730nA*    10/03/19  NLK  7.30n RESERVE BAD Dock Door
730o *    10/08/19  RTR  7.30o
     *      - Enh: Changed to NOT print non-stock items (desig NSTK*)
     *        when OPTIONINT value is Y.
730pA*    10/23/19  JCJ  730p
     *      - Added Pallet Generation logic for Pallet Type
     *        Determination.
740a *    02/03/20  NLK  7.40a
     *      - CHG: Label# prints with leading zeroes   @var 57
     *        GUI RePrint, if you enter leading zeros, No Rcd Found
     *        This change removes leading zeros on PICK label of lbl#
740b *    02/04/20  JCJ  740b
     *      - FIX: if utyp is 'N' for case, move utyp to save utyp
740c *    02/07/20  JCJ  740c
     *      - FIX: add brand retrieval to SR LBLZPS.
740d *    05/08/20  JCJ  740d
     *      - Enh: added logic to print Expired Item Warning label.
740e *    05/25/20  NLK 740e
     *      - Enh: use @var 101 for extended CORD  (CBI currently)
     *        CORD was 7.0 now 11
750aA*    01/25/21  JCJ  750a
     *      - fixed printing of Customer order number on Customer
     *        note label.
750bA*    05/03/21  JCJ  750b
     *      - fixed printing of Bulk pick only pallet for TbEnhanced
750cA*    05/07/21  DAS  750c
     *      - Put a monitor statement around code getting a date
     *        from misc file.
750fA*    05/15/21  DAS  750f
     *     - SelectPrime changes.
     *     - Yes, 750f, to correspond with SelectPrime changes in other program
     *     - Converted to SQLRPGLE
     *     - Moved Revisions to after Notes, as they were getting lost.
     *     - Revised to write certain labels to LABELOUT - See notes.
750gA*    05/28/21  DAS  750g
     *     - Revised to call client custom version of PFMT from this
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
750mA*    09/17/21  LMC  750m
     *      - Enh: Increase the varflag dim from 200 to 1000
750nA*    10/01/21  JCJ  750n
     *      - Fix: looping issue when BLT* setname not found.
750oA*    10/06/21  LMC  750o
     *      - Enh: Seton *inlr on cmd BLTTEST.
750pA*    10/06/21  JCJ  750p
     *      - Enh: Removed obsolete Pallet ID & Pallet section code.
750qA*    12/29/18  JCJ  7.50q
     *      - Enh: Added extended item desc2 V453.
     *      - Enh: Added extended item desc3 V460.
750rA*    11/16/21  DAS  750r
     *      - Added command *RPRTP2S. This is similar to *RPRTP2 but
     *        comes from SelectPrime(c) when printing the BIGPAL label.
     *        The device to be used for label will be sent in the
     *        oppdev field, which is coming from OR640J.
760aA*    03/04/22  NLK  7.60a
     *      - Enh: Added Character value to PICK v106
760bA*    03/08/22  JCJ  7.60b
     *      - Enh: Added door number processing to pallet reprint.
760cA*    03/14/22  JCJ  7.60c
     *      - Enh: Added catch weight counter V99.
760dA*    03/22/22  DAS  7.60d
     *      - Reserved
     *----------------------------------------------------------------
     *  Client Custom Revisions - Cheney
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Dilgard
     *
DFFa *    02/25/19  GJA  DFFa
     *      - Added new entry to OVRPRT array to perform prtf
     *        override to OUTQ instead of DEV.
     *
DFFbA*    04/23/19  JCJ  DFFb
     *      - add palet code.
     *
DFFcA*    05/03/19  JCJ  DFFc
     *      - Ehn: Added brand to pick labels
     *
DFFd *    05/08/19  RTR  DFFd
     *      - Changed to print date from ohmisc/ordh on pick label.
     *
DFFeA*    08/09/19  JCJ  DFFe
     *      - ENH: Change to use LABEL32S for layer pick.
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
JOReA*    02/21/14  MLB  JORe
     *      - Revised JORd mod to retrieve ship date from ORDHM in
     *        field HMMSC2. Needed for Jordano's upgrade to Retalix P/E.
JORfA*    04/14/19  MLB  JORfORg
     *      - Revised 7.20b mod to print Pallet Label ahead of zone pick
     *        up label.
JORgA*    09/01/20  MLB/RH  JORg
     *      - Fix - Revised JORc mod to convert Pack to 1 for Alias
     *        item being picked as Eaches.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Jack Palmer
     *
JPF A*    02/03/09  JCJ  JPF
     *      - Added company name v334 and company phone number v317
     *        to pick label.
     *
JPFaA*    02/20/09  JCJ  JPFa
     *      - Added file RTEHED to determine if willcall route.  If it
     *        is do not print labels AISLChg,Pallet,SETSUM,ZONHED.
     *
JPFbA*    03/10/09  JCJ  JPFb
     *      - add end label to sub item processing.
     *
JPFcA*    03/19/09  JCJ  JPFc
     *      - added file ORDH file to retrieve sub item flag.
     *
JPFdA*    05/27/09  JCJ  JPFd
     *      - changed program to use LABEL32D instead of LABEL32C to
     *        get labels to print in user requested order.
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
     *      - FIX by Max - trying to sub an item(copied over by NLK)
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
CWDyA*    08/20/16  JCJ  CWDy
     *      - Enh: Added BIGPAL label.
     *        Added for DRY, REF, and FRZ only
     *        Added NEW Printer for BIGPAL in the REF and FRZ/BIGPCOOL
CWDzA*    03.23.18  JCJ  CWDz
     *      - Enh: Added 2D Barcodes to TOTE & Pick labels
CWD0A*    07.16.18  MLB  CWD0
     *      - Enh: Revised PFCe mod to not clear SVAISL. Was causing
     *        aisle change label to not print.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Halsey
     *
HALaA*    01/19/10  JCJ  Hala  (now 650b)
     *      - Removed leading zeros from Pallet id.
HALbA*    02/15/13  JCJ  Halb
     *      - activated 530c mod.
HALcA*    10/10/17  NLK  Halc
     *      - Print label PALLET broke into 3 Labels with BIG print
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
FFCeA*    11/20/14  MLB  FFCe
     *      - Print Ship Date rather than todays date on labels.
FSHfA*    04/09/20  JCJ  FSHf
     *      - Print item notes label if item category = FRESHFROZN
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Julius Silvert
     *
JSLa *    09/16/15  GJA  JSLa
     *      - Added LABEL32D - used with DFPICK
     *
JSLb *    10/30/15  JCJ  JSLb
     *      - Added reverse image to breakdown
     *
JSLcA*    12/17/15  JCJ  JSLc
     *      - Added a seperate variable V13 to print UOM on PICK2
     *        label.  It was previously print with V315.
JSLdA *    01/10/17  NLK  JSLd
      *      - Added code to Break PALLET into 3 labels
      *        PALLET now PALLET1, PALLET2, PALLET3
      *        In addition, some 700l code has been added for reprint
      *        client = jslvrt not jsilvert
JSLeA *    04/07/17  NLK  JSLe
      *        PALLET now PALLET1, PALLET2 into PROD with Upgrade
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
CL2aA*    01/17/17  JCJ  CL2a
     *      - Enh: Added today's date to the REPL2 label.
     *
CL2bA*    07/23/19  JCJ  CL2b
     *      - Enh: Print Pallet label before Setsum label.
     *
CL2cA*    01/08/20  RBD  CL2c
     *      - Removed Cityline from SSB type logic for printing
     *        combination substitute label.
     *
CL2dA*    04/23/21  JCJ  CL2d
     *      - Added logic to print Catch weight labels for reprints
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Packers
     *
PCKa *    06/29/20  JCJ  PCKa
     *      - added extended description to pick label.
     *
PCKc *    09/22/04  MLB  PCKc
     *      - Revised to print variable 89 Alpha stop character
     *        for multi-invoice orders.
     *
PCKd *    09/27/04  DAS  PCKd
     *      - Revised to 'Top'/'Back' instead of A/B for pal pos (105)
     *
PCKe *    07/22/20  JCJ  PCKe
     *      - Use depatrment code instead of compartment code.
     *
PCKn *    07/19/11  MLB  PCKn
     *      - Revised program to discontinue printing of label format
     *        CACHWT per email from Carlos S. dated 07/18/11.
     *
PCKo *    09/14/20  JCJ  PCKo
     *      - Revised program to discontinue printing of label format
     *        XDK per call from Roxanne (requested by Carlos S.)
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Colony Foods
     *
CFIa *    09/13/18 GJA CFIa
     *      - Added file LABEL32X (Aisle order).
     *      - Revised PRTSEL to use LABEL32X.
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
ISYiA*    03/18/16  NLK  ISYi
     *      - Print label PALLET broke into 3 Labels with BIG print
ISYjA*    05/17/16  JCJ  ISYj
     *      - added tote processing.
ISYk *    07/19/17  GJA  ISYk
     *      - Change ISYa to default to ITDESC if
     *        OMPDSC = N
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
     *
CPCeA*    08/14/17  JCJ  CPCe
     *      - Enh: get license number for slot.
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
DRYlA*    03/26/15  MLB  DRYl
     *      - Enh: Revised pgm to read LABEL32D for custom sequencing
     *        done using DFPICK for Bronx whse only. Per Kelly R. email
     *        dated 03/23/15.
DRYkA*    04/24/16  MLB  DRYk
     *      - Enh: Revised DRYe mod to check OHMISC > '' else use
     *        OHCUST to print on pick labels. Found at Chef's CDN.
DRYmA*    02/02/17  MLB  DRYm
     *      - Enh: Revised pgm to add whse 70 Chicago to DRYl mod
     *        to use LF, LABEL32D. Includes mods to DFPICK.
     *      - Per Hemant email, dated 02.02.17.
DRYnA*    04/26/17  JCJ  DRYn
     *      - Enh: Add code to print the LOT label.
DRYoA*    08/14/17  JCJ  DRYo
     *      - Fix: Moved were the $prtflag was getting initialized
     *             so the value does not get carried over from
     *             a previous order.  Some orders were getting lot
     *             labels that were not flagged to get them.
DRYpA*    09/13/18  MLB  DRYp
     *      - Enh: Revised pgm to add whse 30 Toronto to DRYl mod
     *        to use LF, LABEL32D. Includes mods to DFPICK.
     *      - Per Kelly R email, dated 09.12.18.
DRYqA*    12/18/18  MLB  DRYq
     *      - Enh: Switched label PICK for PICK2D.
DRYrA*    11/01/20  MLB  DRYr
     *      - Fix: Revised DRYk mod to disable "client = Dairyland"
     *        in PRTBLK and LBLPALLET that was causing KYFMT to be
     *        set to BIGPAL in error.
DRYsA*    10/14/20  JCJ  DRYs
     *      - Enh: Replaced v97 (vendor item) with v415 (cust po#).
DRYvA*    05/24/21  JCJ  DRYv
     *      - Enh: added super route changes
DRYwA*    06/11/21  JCJ  DRYw
     *      - Enh: Added 095 San Francisco PICKQR & PICK2QR label
     *        printing.
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
CDIgA*    04/13/13  MLB  CDIg
     *      - Enh: Revised pgm to not print combo label when truck
     *        template is EXPORT1IT. Need individual labels for all
     *        ordered qty. Per Becky phone call.
CDIhA*    09/29/15  JCJ  CDIh
     *      - Enh: For Pre-Pul zones print 99 for the pallet number.
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
SFGtA*    02/12/17  MLB  SFGt
     *      - Revised SFGa mod to only insert dashes into slot display
     *        for slots that do not have them. New DRY whse slots have
     *        dashes inserted already.
     *      - FIX: if FRZ has aisle 3 long
SFGuA*    02/12/17  MLB  SFGu
     *      - Mod SFGm no longer needed.  In the previous version of
     *        the program the READE failed making SFGm needed to print
     *        merge labels.  The READE no longer fails so the Merge
     *        labels print normally now.
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
RYLb *    07/17/07  HNK  RYLb
     *      - Print COMBO label for Breakdown qty 2 or more.
     *
RYLc *    07/16/07  RBD  RYLc
     *      - Print 2 SETSUM labels.
RYLeA*    03/30/09  JCJ  RYLeA
     *      - Centered item description.
RYLfA*    09/15/09  JCJ  RYLfA
     *      - Changed to use LABEL32D instead of LABEL32C.  This will
     *        allow DFPICK changes to be processed.
RYLgA*    07/06/10  JCJ  RYLg
     *      - Fix: Add royal to New variable 60 processing.
RYLhA*    07/11/10  JCJ  RYLh
     *      - Fix: Remove uom from variable 315.
RYLiA*    07/13/10  RH   RYLi
     *      - Fix: Change palletid to print last 2 char from RTID.
RYLjA*    08/22/16  JCJ  RYLj
     *      - Ehn: Added code to print PICK2 label.
RYLkA*    03/06/17  JCJ  RYLk
     *      - Ehn: Changed Ship date for PICK labels.
     *
     *----------------------------------------------------------------
     *  Client custom revisions - Graves Menu Maker
     *
GMMaA*    04/17/12  JCJ  GMMa
     *      - Print label format PICK2 for EACH labels.
GMMbA*    01/05/16  JCJ  GMMb
     *      - Changed program to print SETSUM label before PICK labels
     *        instead of after the PICK labels.
GMMeA*    08/12/19  MLB  GMMe
     *      - Disabled GMMc mod. GMM moved to Retalix from NDS. Customer
     *        number is numeric and retrieved from ORDH/OHCORD.
GMMfA*    08/17/19  MLB  JORc
     *      - Revised routine ZZFILB2 to convert Pack to 1 when
     *        item is normal item being picked as Eaches.
     *      - Added GMMf to JORc mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: VIP Foodservice
     *
VIPnA*    08/30/16  JCJ  VIPa
     *      - Print Allergen code on PICK & PICK2 labels.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: TPC
     *
TPC A*    10/02/07  RBD  TPC
     *      - Add printing of new warning label NOLABEL when there
     *        should be no pick labels on product ... determined when
     *        pos 7 of ohmisc = Y.  Also under this condition, always
     *        print Combo label.
TPCaA*    10/04/07  RBD  TPCa
     *      - For var 11, print slot from label file, lbdisp.
TPCbA*    11/27/07  RH   TPCb
     *      - For produce, print by stop.
TPCcA*    02/28/08  RH   TPCc
     *      - Change to process LABEL32D to print in DFPICK sequence.
TPCdA*    05/08/19  NLK  TPCd
     *      - Change date from MISC field of Entered Date to DeliveryDate
     *        created in getRTEHDE Report date + 1 (ex was 1 week diff)
TPCeA*    01/29/20  JCJ  TPCe
     *      - Change to process LABEL32X to print in DFPICK Aisle
     *        sequence. This logical has remove section code from key.
TPCfA*    02/11/20  JCJ  TPCf
     *      - add tpf to brand logic for variable 313.
TPCgA*    01/08/22  MLB  TPCg
     *      - Revised pgm to load first 15 char of IXDSC2 into
     *        varianble for vendor item number. Per Michelle H.
TPChA*    01/26/22  TDC  TPCh
     *      - Revised modification TPC. The no label check will
     *        be based on HMMSC2 pos 1=Y, rather than the check
     *        on pos 7 of ohmisc = Y.
     *
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
HMWh *    09/20/16  RTR  HMWh
     *      - Added HMW to mod SFGb to use todayplus1 for var20-date.
     *        Per email from Joe Harrison.
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
MJKhA*    08/11/16  JCJ  MJKh
     *      - Added printing of new label CUSTNOTE
     *      - Added printing of new label ITEMNOTE.
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
KFSdA*    06/10/15  JCJ  KFSd
     *      - Enh: Print label format PICK2 for EACH labels.
KFSeA*    08/14/18  MLB  KFSe
     *      - Enh: Revised PRTSEL to not print combo label when process-
     *        ing batch picks. Per Bobby H email dated 08.14.18.
     *
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
YH2lA*    05/17/16  JCJ  YH2l
     *      - added tote processing.
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
GFSnA*    04/16/15  MLB  GFSn
     *      - Added support to retrieve Receive Date from picking slot.
     *        Entered Date from DRILICENSE will be printed on pick
     *        label using new variable, 145.  Lookup for the Rcv date
     *        will be done for the following Hilton/Westgate Host Keycode
     *        /OHCUST customer numbers: 3216-3238, 3387, 3449, 3659, 3812,
     *        5744, 5774-5775 and 6387. per email from Andrew M.
     *      - Added SLOT3 to pgm.
     *      - Added support for DRI interface calls.
GFSo *    11/13/17  NLK  GFSo (like CSPn)
     *      - Enh: New LSGxxxx Label - PICKLSG (quote #01831)
     *        Cust#s starting with LSG - flds ohcord,oditem,itpdsc
     *
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
GLPg *    01/22/16 KDE GLPg
     *      - Enh: reserved for AMP box print
GLPh *    03/09/16 JCJ GLPh
     *      - Enh: added client to LABEL32X logic. Changing GLPB
GLPi  *    03/11/16 RTR GLPi
      *      - Enh: changed position of customer name/code
GLPjA*    12/12/16  NLK  GLPj(ADFc)
     *      - Added label PICKHVY
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
SVLk *    12/05/16  RTR  SVLk
     *      - Ehn: Added check for delivery date in OPTIONS. If found,
     *        uses that instead of calculated report date +1. OPTIONS
     *        is updated by Saval via FTP calling QDSVL002. Needed for
     *        holiday/weekend deliveries that are not report date +1.
     *        NOTE: If their FTP process fails, the date will be wrong
     *        on the labels. Fix the OPTIONS record and reprint labels.
SVLlA*    04/05/18  NLK  SVLl
     *      - Ehn: Added label PALDROP if *SP, Single Pallet Process
SVLmA*    08/24/18  JCJ  SVLm
     *      - Ehn: Added PIRPICK label for JITP zone.
SVLnA*    07/02/19  JCJ  SVLn
     *      - Ehn: change how we loaded V459.
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
     *  Client Custom Revisions: S. Bertram
     *
SBRaA*    02/16/15  JCJ  SBRa
     *      - Ehn: Activated Each label - PICK2
SBRbA*    02/18/15  JCJ/MLB  SBRb
     *      - Ehn: Added SBRb to GFC mod to print Brand on pick label.
     *      - Added SBRb to 6.40r mod.
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
CSPi *    10/11/13  JCJ  CSPi
     *      - Enh: if route is a pre-pick route do not print the stop
     *             number on the pick label.
     *
CSPl *    08/16/14  JCJ  CSPl
     *      - Enh: Replaced PALLET label with BIGPAL label.
     *
CSPm *    12/28/16  NLK  CSPm
     *      - Enh: New Amazon Label - PICKAMZ. (quote #01686)
CSPn *    09/22/17  NLK  CSPn
     *      - Enh: New LSGxxxx Label - PICKLSG (quote #01823)
     *        Cust#s starting with LSG - flds ohcord,oditem,itpdsc
CSPx *        **Temporary - look at LSG04 only**
     *
CSPoA*    10/30/17  NLK  CSPo  P#01834
     *      - Enh: New Label - PICKDUP. Duplicate Customer Order
     *        PICK label, print DUPLICATE in reverse video only if
     *        RT changed.
     *      - FIX: Print ONLY if item was in PrePull Route
CSPp *    03/08/18  NLK  CSPp (addtl CSPi)  Quote 1860
     *      - Enh: if route is a pre-pick route do not print the stop
     *             number on the pick label and BIGPAL.
CSPq *    03/09/18  NLK  CSPq Quote 1861
     *      - Enh: ADD-ON route do not need BIGPAL labels
CSPrA*    07/02/18  MLB  CSPr  P#01950
     *      - Enh: Added customer LSG01 to mod CSPn.
CSPsA*    07/16/18  NLK  CSPs  P#00000
     *      - Enh: SETSUM changes, rmv cube, weight, add cust#.
     *        Print for each Pallet, chg in General Picking Options.
     *      - Put V48 Cube back in.
CSPtA*    11/16/18  NLK  CSPt  P#1862
     *      - Enh: BIGPAL(A) add Dispatch time - ordhm/hmmsc4 col9-12
CSPuA*    02/06/19  MLB  CSPu  P#02029
     *      - Enh: Revised pgm to create custom off-truck delivery barcode
     *        value using last 4 digits of OHCORD, last 3 digits of ODSEQ and
     *        last 3 digits of 'x of' qty value. This will replace Trax# on
     *        all pick labels. Coastal needs this for their 3rd party off
     *        truck delivery application.
     *
     *----------------------------------------------------------------
     *  Client custom revisions: Williams
     *
WIFaA*    08/08/17  JCJ  WIFa
     *      - Enh: Print the Pallet label before the Pick labels.
WIFbA*    08/09/17  JCJ  WIFb
     *      - Enh: Print 'WOOD' on sethed label and 'W' on pick labels
     *        if any ORDH record for the transaction being processed
     *        is flagged.
WIFcA*    05/13/14  JCJ  WIFc
     *      - Enh: Print the text 'Wood Pallet' on pallet label when
     *             Customer has a single pallet selection designation.
WIFdA*    04/18/18  JCJ  WIFd
     *      - Enh: NDS upgrade changed the customer nuber to be sent
     *             in the ORDH/OHMISC.
WIFeA*    12/16/19  JCJ  WIFe
     *      - Enh: Added MRGHED merge header label
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
PFCdA*    11/05/15  JCJ  PFCd
     *      - Enh: Revised program to use routine OPNPRT when
     *             $PCMD = '*SHORT'. Revised pgm to save
     *             device/form passed in to pgm in OPZDTA to be
     *             restored just before call to OPNPRT. This was needed
     *             because the program retrieves the printer/form from
     *             the item's pick zone definition.
PFCeA*    12/16/15  JCJ  PFCe
     *      - Enh: Added MRGHED merge header label
     *      - Enh: Clear svaisl at beginning of merge print
PFCfA*    03/18/16  NLK  PFCf
     *      - Enh:  Changed PICK2 each label to print when UOM = 'TU'
PFCgA*    07/25/18  JCJ  PFCg
     *      - Enh:  Replaced Trax barcode with OMMSC3 on the PICK,
     *              PICK2 and BULK labels.
PFCh *    04/10/19  GJA  PFCh
     *      - Enh: Removed LABEL32J and replaced with LABEL32D.
PFCi *    05/07/21  JCJ  PFCi
     *      - Enh: Added reprint flag to pick label.
PFCj *    09/16/21  JCJ  PFCj
     *      - Enh: Added Pallet section next to Extended stop
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Sofo Foods
     *
SOFaA*    06/24/20  JCJ  SOFa
     *      - Enh: Added MRGHED merge header label
     *
     *----------------------------------------------------------------
     *  Client custom revisions: Will Foods
     *
WIL A*    08/31/15  MLB  WIL
     *      - Enh:  Revised program to use LABEL32D to print
     *        labels across all 2 departments. Per Hemant K.
     *        email dated 08/31/15.
     *      - Added WIL to FSHd mod.
     *
     *----------------------------------------------------------------
     *  Client custom revisions: Panos
     *
PANaA*    03/01/16  JCJ  PANa  (NLK brought back to ENH700)
     *      - Print label format PICK2 for EACH labels.
PANbA*    03/02/16  RTR  PANb  (NLK brought back to ENH700)
     *      - Changed to print customer number from ohmisc/ordh.
PANcA*    03/28/16  MLB  PANc  (NLK brought back to ENH700)
     *      - Revised pgm to use LABEL32D instead of LABEL32C due to
     *        combined department pick zones.
PANdA*    07/31/18  JCJ  PANd
     *      - Ehn:  activated variable 313 for Brand.
PANeA*    09/12/18  JCJ  PANe
     *      - Ehn:  created new POD Barcode to pick labels
PANfA*    03/24/21  JCJ  PANf
     *      - Ehn:  created another new POD Barcode to pick labels.
     *              changed the field length from 16 to 17.  Changed
     *              variable from 125 to 129.
     *              Revised PANe mod to add '0' to end of barcode.
     *              Per Paul Capello - NECS email dated 03/10/21
     *              07:41 am CT.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Renzi
     *
RNZjA*    05/20/16  JCJ  RNZj  P#01565
     *      - Enh:  Added Filler(Blank) label processing.
RNZkA*    05/27/16  MLB  RNZk  P#01565
     *      - Enh:  Revised pgm to use LABEL32D for label processing
     *        now that CLR/DRY dept are being picked together. Aisles
     *        N and P are split between departments now they want them
     *        to be picked consecutively.
     *      - Added RNZk to FSHd mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Indianhead
     *
IFDaA*    09/30/08  JCJ  IFDa
     *      - Positon 1-1of OHMISC will contain Key Type. Variable 306
     *      - Positon 2-3of OHMISC will contain Type Code.Variable 307
IFDbA*    02/05/09  JCJ  IFDb
     *      - Add support for printing brand V313.
IFDcA*    02/17/09  JCJ  IFDc
     *      - Add support for printing V164 (underline).
IFDdA*    02/03/14  JCJ  IFDd
     *      - Any item that has a slot that begins with a 'X' print
     *        a second set of labels.
IFDeA*    12/03/14  JCJ  IFDe
     *      - Enh: added code to print label PICK@ for Cust 83833.
     *        This label prints reverse video of keytype.
IFDf *    11/21/16  GJA  IFDf
     *      - Reversed 640m mod.
     *      - Someone did a IFDf on type with no comments, this is not
     *        made with my modification.
IFDgA*    12/17/18  JCJ  IFDg
     *      - Enh: Print no pick labels for selected items.
IFDhA*    03/11/18  JCJ  IFDh
     *      - Enh: Changed to print COMBO label instead of skipping
     *        the printing of these labels.  Force to Quantity of 1.
IFDiA*    08/12/20  JCJ  IFDi
     *      - Enh: Added item 57106 to the ifdcomboQTY processing.
IFDjA*    09/03/20  JCJ  IFDj
     *      - Enh: Added item 101883 to the ifdcomboQTY processing.
     *----------------------------------------------------------------
     *  Client custom revisions: FoodPro
     *
FPRaA*    03/21/16  JCJ  FPRa
     *      - Enh: Added reverse video to PICK label instead of PICK2.
     *
FPRbA*    03/22/16  JCJ  FPRb
     *      - Enh: Added code to prevent 'Cases' from printing as UOM
     *             on the PICK label.
FPRcA*    03/22/16  MLB  FPRc
     *      - Enh: Revised pgm to retrieve Delivery Date from ORDHM for
     *             printing on PICK label.
FPRdA*    03/23/16  MLB  FPRd
     *      - Added LABEL32D for changes to DFPICK.
     *      - This mod was replaced with 730i.
FPReA*    03/25/22  MLB  FPRe
     *      - Revised routine ZZFILB2 to convert Pack to 1 when
     *        item is normal item being picked as Eaches.
     *      - Added FPRe to JORc mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: A&D Foods
     *
ADFaA*    09/13/16  NLK  ADFa
     *      - Added label PICK2
ADFbA*    10/24/16  MLB  ADFb  P#
     *      - Enh:  Revised pgm to use LABEL32D for label processing
     *        now that F/R/D depts are being picked together in single
     *        pick zone with single compartment. Per Hemant K email
     *        dated 10.24.2016 4:22 pm CT.
     *      - Added ADFb to FSHd mod.
ADFcA*    12/12/16  NLK  ADFc
     *      - Added label PICKHVY
ADFdA*    08/31/17  JCJ  ADFd (per Hemant)
     *      - Remove label PICKHVY
ADFeA*    10/30/17  JCJ  ADFe
     *      - Replace Item description with Item Extended Description.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Greco & Sons
     *
GRC A*    10/18/18  MLB  GRC
     *      - Enh:  Revised pgm to use LABEL32D for label processing.
     *      - Added GRC to FSHd mod.
     *
GRCaA*    11/02/18  JCJ  GRCa
     *      - Enh:  Get customer number from ORDHM/HMMSC1 pos 1 - 6.
     *
GRCbA*    11/05/18  JCJ  GRCb
     *      - Revised to grab pallet code from LBDSP2 instead
     *        LBHND2.
     *
GRCcA*    02/05/19  JCJ  GRCc
     *      - Revised to add stop range to pallet label.
     *
GRCdA*    02/02/19  JCJ  GRCd
     *      - Ehn: Print Item Notes
     *
GRCeA*    02/21/19  JCJ  GRCe
     *      - Start print PICK2 (each) label.
     *
GRCfA*    04/08/19  JCJ  GRCf
     *      - Get Delivery Date from ORDH.
     *
     *----------------------------------------------------------------
     *  Client custom revisions - Cotati
     *
COTaA*    09/19/18  JCJ  COTa
     *      - Print label format PICK2 for EACH labels.
COTbA*    09/25/18  MLB  COTb
     *      - changed program to use LABEL32D instead of LABEL32C to
     *        get labels to print in user requested order.
COTcA*    09/28/18  JCJ  COTc
     *      - Removed Cotati from SSB type logic for printing
     *        combination substitute label.
COTdA*    09/28/18  JCJ  COTd
     *      - Added V199 to print extended item description.
     *
     *----------------------------------------------------------------
     *
MQSaA*    09/09/19  JCJ  MQSa
     *      - Print label format PICK2 for EACH labels.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Farm Boy Foods
     *
FBYaA*    06/06/18  JCJ  FBYa
     *      - Added label PICK2 logic
     *
FBYbA*    06/06/18  JCJ  FBYb
     *      - stop printing the out word on pick labels.
     *
FBYcA*    06/29/18  JCJ  FBYc
     *      - ENH: retrive Customer from OHMISC/ORDH.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kohl Wholesale
     *
KHLaA*    06/29/18  JCJ  KHLa
     *      - ENH: added client id.
     *      - ENH: retrive Customer from OHMISC/ORDH.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Merit Foods
     *
MRT A*    11/12/18  MLB  MRT
     *      - Enh:  Revised program to use LABEL32D to print
     *        labels across all 3 departments. Per Hemant K.
     *        email dated 10/26/18.
     *      - Added MRT to FSHd mod.
     *
MRTbA*    11/13/18  JCJ  MRTb
     *      - Enh: activated PICK2 label.
     *
MRTcA*    11/13/18  JCJ  MRTc
     *      - Removed Merit from SSB type logic for printing
     *        combination substitute label.
     *
MRTd *    12/13/19  NLK  MRTd
     *      - Merit needs a desc if subbed item not in orddm
     *----------------------------------------------------------------
     *  Client Custom Revisions: Seashore
     *
SFPaA*    10/03/18  JCJ  SFPa
     *      - Ehn: Activated Each label - PICK2
     *
SFPbA*    11/11/18  JCJ  SFPb
     *      - Ehn: any item with the word 'SPLIT' in positions 2 - 6
     *        in item description should print using label PICK2 with
     *        the work SPLIT replacing the UOM.
     *
SFPcA*    07/25/19  JCJ  SFPc
     *      - Added printing of new labels CUSTNOTE
     *
SFPdA*    08/14/19  JCJ  SFPd
     *      - Added printing of new labels ITEMNOTE.
     *
SFPeA*    02/27/23  JCJ  SFPe
     *      - Changed the item description custome code.
     *        Was printing 22 characters now printing 33.
     *
SFPfA*    06/12/23  NLK  SFPf
     *      - FIX: custnote didn't have correct ohord to get ordhm
     *
SFPgA*    07/06/23  NLK  SFPg
     *      - ADD: CC on PICKs for critical care
     *
SFPhA*    10/13/23  NLK  SFPh   (like SFPg)
     *      - ADD: XS and NC for Special Notes on PICK labels
     *        additional codes added, could move codes to array
     *      - Critical care='CC', VIP='CC', Special='XS' and
     *        New Customer='NC'
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Southwest Traders
     *
SWT A*    03/08/19  MLB  SWT
     *      - Enh:  Revised program to use LABEL32D to print
     *        labels across all 3 departments. Per Hemant K.
     *        email dated 03/08/19.
     *      - Added SWT to FSHd mod.
     *
SWTbA*    03/16/19  JCJ  SWTb
     *      - Revised to grab pallet code from LBDSP2 instead
     *        LBHND2.
     *
SWTcA*    03/19/19  JCJ  SWTc
     *      - Do not print a virtual slots, only print the base
     *        slot.
     *
SWTdA*    03/19/19  JCJ  SWTd
     *      - Retrieve Trax number for totes.
     *
SWTeA*    04/30/19  JCJ  SWTe
     *      - Ehn: Activated Each label - PICK2
     *
SWTfA*    08/16/19  JCJ  SWTf
     *      - Ehn: Added uom 'IP'/'PK'/'BG'/'BX'/'RL' to Each label
     *        processing.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Earls Organic Produce
     *
EOPa *    02/19/19  JCJ  EOPa
     *        Enh:  added EOP copyspec
EOPb *    11/14/18  RTR  EOPb
     *        Enh:  Set Variable 77 to their organic certifier code
     *        from ITEMEXT field IKMSC4.
EOPc *    03/04/19  JCJ  EOPc
     *        Enh:  Activated Variable 77 for all EOP labels.
EOPd *    03/04/19  JCJ  EOPd
     *        Enh:  Added Address Handler.
EOPe *    03/07/19  JCJ  EOPe
     *        Enh:  Added GS1 barcode v411barcd.
EOPf *    03/12/19  JCJ  EOPf
     *        Enh:  Added customer number to V185.
EOPg *    03/14/19  JCJ  EOPg
     *      - Revised to grab pallet code from LBDSP2 instead
     *        LBHND2.
EOPh *    07/23/19  JCJ  EOPh
     *        Enh:  Added customer notes label.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Accardi
     *
ACCaA*    03/05/09  JCJ  ACCa
     *      - Ehn: Changed PRTSEL to use LABEL32S for zones
     *        REFF & FRZBIN.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Holt Paper Company
     *
HPCaA*    03/31/20  JCJ  HPCa
     *      - Ehn: do not put UPM in variable 315
HPCb *    03/14/21  RTR  HPCb
     *      - Do not print a virtual slots, only print the base
     *        slot. Added to SWTc mod.
HPCc *    04/16/21  JCJ  HPCc
     *      - Enh: Added MRGHED merge header label
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Vitco
     *
VFIa *    01/07/20  JCJ  VFIa
     *      - Enh: added POD barcode to PICK / PICK2 labels
VFIb *    01/21/20  NLK  VFIb
     *      - Ehn: Added label PICK2 for eaches to Rev Image RI
VFIc *    01/29/20  GJA  VFIc
     *      - Enh:  Replaced Trax barcode with OMMSC3 on the PICK,
     *              PICK2 and BULK labels. POD new barcd - Remove VFIa
     *      - FIX:  getORDDM needed to grab POD data from ORDDM file
VFId *    01/30/20  NLK  VFId
     *              Was using V125BARCD, due to length use V455BARCD
VFIe *    01/31/20  NLK  VFIe
     *      - Enh:  have Combo Rev Image like Eaches using PICK2
VFIf *    02/04/20  NLK  VFIf
     *        Changed position of PALLET label, BULK only incorrect.
     *        Prints at bottom for all labels except BULK.
     *      - REQ: BULK Pallet to print at bottom before END.
VFIe *    03/05/20  NLK  VFIe FIX
     *      - FIX: in lblpck, remove check KYFMT not needed
VFIg *    06/21/21  JCJ  VFIg
     *      - Enh: added special order number processing.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Caribbean Producers
     *
CPJa *    08/18/20  JCJ  CPJa
     *      - Enh: Removed Pack Description, Added Extended iten
     *             Description, Added Extended order number. Added
     *             Reprint flag.
     *
CPJb *    08/19/20  JCJ  CPJb
     *      - Enh: Added each label processing.
     *
CPJc *    08/20/20  JCJ  CPJc
     *      - Enh: Grab customer number from ORDHEXA
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
     *
     *    Notes for City Wholesale:
     *
     *    All labels are printed to a printer defined in CTWZONDEV file.
     *
     *    Cigarette zones CIG011 & CIG091 - No pick labels.  Just Pick
     *                                      sheets.
     *                                      Tote labels size 4"x2"
ctwwA*                                      Two tote labels
ctwwA*                                      Xtote
ctwwA*                                      Xtotes "Special stamp"
     *
     *
     *
     *    TOBACO and CANDY zones      - Pick labels size 3 1/2" x 1 1/2"
     *                                  PICK2 #str2 on pfmtpr2
     *                                  Tote labels size 3 1/2" x 1 1/2"
     *                                  XTOTE2 #str2 on pfmtpr2
     *
     *    DRY, FRZ & REF case zones   - Pick labels size 3 1/2"x1 1/2"
     *                                  No tote labels for these zones
     *
640zA*    RETAIL, MEZ032, MEZ101, PHN132  - Pick labels size 3/4"x3/4" 4Up
     *                                      Tote labels size 4"x2"
     *
     *
     *
     *

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
701cAFpltsum3rp if   e           k disk    rename(psrec:psrec3rp)
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
EOPbAfitemext1  if   e           k disk
     Foptions   if   e           k disk
520hAFoptionz   if   e           k disk
     FLblfmth   if   e           k disk
     FLblfmtd   if   e           k disk
     FLblfmtv   if   e           k disk
640uD *label     if   e           k disk    rename(LBREC:LBREC0)
CCPaAFlabel94   if   e           k disk    rename(LBREC:LBREC94)
MATaAFordp2     if   e           k disk
SWTdAFordp5     if   e           k disk    rename(orprec:orp5) Prefix(k)
530 AFtruckh    if   e           k disk
700zAFtruckh2   if   e           k disk    rename(threc:threc2) Prefix(j)
640cAFzoneh     if   e           k disk
510bAFzbrlogf   uf a e           k disk
510bAFzbrlogs   uf a e           k disk
ctwaAFctwzondev if   e           k disk
640cAForddm     if   e           k disk
530bAFordh      if   e           k disk    prefix(X)
RYLaAFordh3     if   e           k disk    Rename(ohrec:ohrec3)
svlaAFordh4     if   e           k disk    rename(ohrec:ohrec4) Prefix(y)
CWDaAFordd      if   e           k disk
640pAFdevgrpd   if   e           k disk
640pAFdevgrpd2  uf   e           k disk    rename(ddrec:d2rec)
640pAFdevgrpr   if a e           k disk
fdisAFordhm     if   e           k disk
640fAFpirtran   if   e           k disk    prefix(Y)
GFSnAFslot3     if   e           k disk    rename(slrec:slrec3)
640iAFtotebund1 if   e           k disk
640iAFtotebund3 if   e           k disk    rename(TBREC:TBREC3)
642mAFcustexp   if   e           k disk
BIRf Fitemqty   IF   E           K DISK
ALNdAFstdtime   if   e           k disk
ALNoAFpcktime   uf a e           k disk
CLDlAFpirseq2   if   e           k disk
     F                                     rename(psqrec:psqrec2)
CLDlAFpirseq3   if   e           k disk
SVLeAFrtehed    if   e           k disk
SVLiAFslot2     if   e           k disk
SVLiAFvslot1    if   e           k disk
710dAFtrkcomp   if   e           k disk
     Fpfmtpr    o    f  198        printer oflind(*in90)
     F                                     usropn
640cAFpfmtpr2   o    f  198        printer oflind(*in91)
640cAF                                     usropn
640cAFpfmtpr3   o    f  198        printer oflind(*in92)
640cAF                                     usropn
CSPlAFpfmtpr4   o    f  198        printer oflind(*in93)
CSPlAF                                     usropn
CLDqAFitemfld   if   e           k disk
CLDqAFlabel90   if   e           k disk    Rename(lbrec:x_lbrec)
CLDqAF                                     Prefix(x_)
CLDvAFssbxref   if   e           k disk
700vDF*ampxref1  if   e           k disk
700vAFampxref13 if   e           k disk
700nAFampbox    if   e           k disk
701hAFunmesr1   if   e           k disk    Prefix(u_)
CSPoAFPreXRef6  if   e           k disk
DRYvAFsrord     if   e           k disk
DRYvAFsrrte     if   e           k disk

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
JORbMD ovrprt          s             80    dim(2) ctdata perrcd(1)
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
      /copy qcopysrc,id#cheney
      /copy qcopysrc,id#cheneyo
      /copy qcopysrc,id#cheneyr
      *copy qcopysrc,id#cheneyg
      /copy qcopysrc,id#cheneyp
JOR A /copy qcopysrc,id#jordano
jpfbA /copy qcopysrc,id#palmer
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
DRYlA /copy qcopysrc,id#drybron
DRYmA /copy qcopysrc,id#dryqchi
DRYqA *copy qcopysrc,id#drycinc
DRYqA /copy qcopysrc,id#drymia
640cA /copy qcopysrc,id#silberm
CDIaA /copy qcopysrc,id#cdi
CDIaA /copy qcopysrc,id#cdijax
GFCaA /copy qcopysrc,id#glazier
640rA /copy qcopysrc,id#ifd
SFGbA /copy qcopysrc,id#sgc
RYLaA /copy qcopysrc,id#royal
VIPbA /copy qcopysrc,id#vip
TPC A /copy qcopysrc,id#tpc
GMMaA /copy qcopysrc,id#gmm
HMWaA /copy qcopysrc,id#hmwagne
KFS A /copy qcopysrc,id#kfs
BIRxA /copy qcopysrc,id#birite
GFSaA /copy qcopysrc,id#gfs
WIFdA /Copy qcopysrc,ohmisc_wif
CSP A /copy qcopysrc,id#coastal
HKWaA /copy qcopysrc,id#hkw
ELBtA /copy qcopysrc,id#ellenbe
GLPaA /copy qcopysrc,id#glp
SVLbA /copy qcopysrc,id#saval
FRF A /copy qcopysrc,id#frf
SBRaA /copy qcopysrc,id#sbr
YHAaA /copy qcopysrc,id#yhata
PFCaA /copy qcopysrc,id#pfc
SOF A /copy qcopysrc,id#sofo
WIL A /copy qcopysrc,id#wil
FPRaA /copy qcopysrc,id#fpr
JSLaA /copy qcopysrc,id#jsl
WIFaA /copy qcopysrc,id#wif
PANaA /copy qcopysrc,id#pan
RNZkA /copy qcopysrc,id#renzi
ADFaA /copy qcopysrc,id#ADF
GRC A /copy qcopysrc,id#grc
CFIaA /copy qcopysrc,id#CFI
COTaA /copy qcopysrc,id#COT
MQSaA /copy qcopysrc,id#mqs
FBYaA /copy qcopysrc,id#fby
KHLaA /copy qcopysrc,id#khl
MRT A /copy qcopysrc,id#mrt
SFPaA /copy qcopysrc,id#SFP
DFFaA /COPY QCOPYSRC,id#dff
SWT A /copy qcopysrc,id#SWT
ACCaA /copy qcopysrc,id#ACC
EOPaA /COPY QCOPYSRC,id#eop
HPCaA /COPY QCOPYSRC,id#hpc
VFIaA /COPY QCOPYSRC,id#vfi
PCKaA /copy qcopysrc,id#packers
CPJaA /COPY QCOPYSRC,id#cpj
     *----------------------------------------------------------------
     *  Customer id
500gA*
500gaD                 ds
500gAD  client                 1     10
500gAD  cliloc                11     20
     D @getcl          c                   const('GETCLIENT')

700 A*----------------------------------------------------------------
700 A*  DRI parameters
700 A*----------------------------------------------------------------
700 A /COPY *libl/qcopysrc,C#DRIPARMS
700 A
700 A*----------------------------------------------------------------
700 A*  Data Formats
700 A*----------------------------------------------------------------
700 A /COPY *libl/qcopysrc,C#SLOT
700 A /COPY *libl/qcopysrc,C#XDOCK
700 A /COPY *libl/qcopysrc,C#LICINFO
700 A /COPY *libl/qcopysrc,C#LICHIST
700 A /COPY *libl/qcopysrc,C#LICENSE
700 A /COPY *libl/qcopysrc,C#ITEM
700 A /COPY *libl/qcopysrc,C#UCIINFO

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

700 AD savever#        s                   like($lnver#)
700 A
640cA*----------------------------------------------------------------
640cA*  Misc field mappings
640cA*----------------------------------------------------------------

DRY A /Copy qcopysrc,ordhm1_dry
DRYfA /Copy qcopysrc,ordhm2_dry
JOReA /Copy qcopysrc,ordhm2_rtx
ctwwA /Copy qcopysrc,ohmisc_ctw
GFSmA /Copy qcopysrc,ohmisc_gfs
JPFcA /Copy qcopysrc,ohmisc_jpf
FBYcA /Copy qcopysrc,ohmisc_fby
KHLaA /Copy qcopysrc,ohmisc_khl
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
CSPbA /copy qcopysrc,ordhm1_csp
CSPgA /copy qcopysrc,ohmisc_csp
CPCbA /Copy qcopysrc,orddm1_cpc
700jA /Copy qcopysrc,ordhm4_amp
CWDyA /Copy qcopysrc,ordhm1_cwd

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
701dA*    OPRFSL  -  RF Pick Verify slot
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
650aA*    OPRFQT  -  RF Pick Allow Qty Entry (Y/N)
700aA*    OPRFQTO -     With Quantity Over (if RF Pick Allow Qty Entry = Y)
650bA*    OPRFCS  -  RF Pick Allow Change Slot (Y/N)
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
700yDD* dsspcs                17     20  0
700yMD  dsspcs                17     21  0
700yMD  dsscnm                22     61
700yMD  dspal#                62     68  0
700yMD  dssord                69     75  0
700yAD  dsswgt                76     84  2
CSPsAD  dsscno                85     90
DRYvAD  dssrst                91     99
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
701cA*    OPLBL   -  Label printing method.
701cA*                N = Row
701cA*                S = Column
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
701cAD  oplbl                 68     68
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
     D  dsmm                   1      2
     D  dsdd                   3      4
     D  dsyy                   5      6
PCKcAD  dsalph                 9      9
     D  dssdte                16     19p 0
     D  dssub                 20     20
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

     *----------------------------------------------------------------
     *  Called programs
     *
640cAD @getpl          c                   const('GETPALLET')
     D @cvtdt          c                   const('CVTDTE')
520jAD @getstop        c                   const('GETSTOP')
642cAD @gettruck       c                   const('GETTRKTMPL')
BIRdAD @getspcl        c                   const('GETSPCLINS')
GLPnAD @getsi          c                   const('GETSLOTITM')
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
GFSnA
GFSnA*------------------------------------------------------------------
GFSnA* CLCDUR2 parameters
GFSnA*------------------------------------------------------------------
GFSnA
GFSnAD $cdcmd          s              8
GFSnA
GFSnAD $cddatein       s              8  0
GFSnAD $cdtimein       s              6  0
GFSnA
GFSnAD $cdyears        s              3  0
GFSnAD $cdmonths       s              3  0
GFSnAD $cddays         s              3  0
GFSnAD $cdhours        s              3  0
GFSnAD $cdminutes      s              3  0
GFSnAD $cdseconds      s              3  0
GFSnA
GFSnAD $cddateOut      s              8  0
GFSnAD $cdtimeOut      s              6  0
GFSnA
GFSnA*----------------------------------------------------------------
GFSnA*  Data structure for error message parameters
GFSnA*
GFSnAD $mdt            ds
GFSnAD  errmsg                 1     50
GFSnA*
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
JPF  D @company        c                   const('Palmer Foodservice')
JPF  D @phone          c                   const('(931)684-7011')
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
SFPgAD sfpspec         c                   const('CC')
SFPhAD sfpXS           c                   const('XS')
SFPhAD sfpNC           c                   const('NC')
CCPcAD ccpsch          c                   const('School Pre-Pick')
640gAD ToteHdg         c                   const('Tote  ')
640gAD PalletHdg       c                   const('Pallet')
CSPlAD bigpal          c                   const('BIGPAL')
GFSlAD addon           c                   const('**ADDON**')
650gAD @audit          c                   const('AUDIT')
650jAD @heavy          c                   const('HEAVY')
WIFcAD WoodPalletText  c                   const('Wood Pallet')
701aAD Allergen        c                   const('ALLERGEN')
EOPdAD AddressHand1    c                   const('Earls Organic SF CA 94124')
EOPdAD AddressHand2    c                   const('CCOF HANDLER PR244  ')
EOPeAD EOPGS1          c                   const('08622430001')
FSHfAD FreshFroznTxt   c                   const('Keep Frozen - Thaw In Refrge+
     D                                     ration')
740dAD ExpiredItem     c                   const('Check Date for Next Item')
     *----------------------------------------------------------------
     *  Variables
     *
SFGtAD aisl1           s              1
CCPaAD ccpchk          s              3
CCPcAD ccpchks         s              1
SFGtAD dash            s              1
510bAD logzebra        s               n
730eD *forever         s               n
ctwaAD tobaccoflag     s               n
ctwaAD retailflag      s               n
ctwjAD cigaretflag     s               n
ctwaAD candyflag       s               n
ctwaAD totzon          s               n
700bAD bigpallabel     s               n
CWDyAD bigpal2         s              6
IFDhD *skipitem        s               n
IFDhMD ifdcomboQTY1    s               n
IFDgAD ifdcombo        s               n
CDIaAD $cwhse          s              3
CDIaAD $ccode          s             10
CDIaAD $chhdr          s              1
CDIaAD $chdtl          s              1
CDIaAD $chcat          s              1
JOReAD ckdate          s              8
     D $nadec          s              2  0
     D $nafp           s              2  0
     D $nanum          s             11  0
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
700jDD*AMPBox#         s              3
700xAD AMPBox#         s              5
     D ax              s              2  0
     D ay              s              2  0
642nAD chkRDD          s              3
BIRx D c#qpck          s              5  0
JORcAD charpos         s              3  0
700 AD ck4err          s              1
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
PFCeAD first3          s              1
     D forevr          s              1
     D frdesc          s             30
     D fritem          s             15
510bAD GoodHit         s              1    Inz('0')
VIPdAD imp_flg         s              1
730eD *i               s              2  0
ctwaAD icount          s              2  0
701bAD intcmd          s             10
701bAD intflag         s              1
     D ip              s              3  0
     D ix              s             48
     D k               s              3  0
cwdgAD kycode          s                   like(opzcod)
     D kyfmt           s                   like(lfdfmt)
720iAD kygen           s                   like(psgen)
     D kyltyp          s                   like(lbtype)
     D kytype          s                   like(pstype)
     D kyvnum          s                   like(lfvnum)
cwdgAD kyzone          s                   like(opzzon)
     D lbls            s              3  0
     D lc              s              3  0
     D ln              s              3  0
     D lstlb#          s                   like(lblbl#)
     D lstpid          s                   like(psplid)
     D lststp          s                   like(lbstop)
     D lsttrn          s                   like(lbtrn#)
     D lstum           s                   like(lbutyp)
     D lstwdp          s                   like(lbwhdp)
     D lstzon          s                   like(psszon)
TPCb D lsszon          s                   like(psszon)
     D maxsti          s              2  0
     D maxsto          s              3  0
MJKcAD mjkContract     s               n
     D n               s              3  0
701bAD newcmd          s              1
     D num1            s              1  0
     D num2            s              1  0
     D op              s              3  0
SVLkAD opdeldt         s              8a
     D openedpfmtprt2  s              1
     D openedpfmtprt3  s              1
CSPlAD openedpfmtprt4  s              1
CSPlAD opfm4a          s             10    inz('BIGP')
     D outwrd          s              3
SVLlAD snglpal         s              3
HMWaAD subwrd          s              3    inz('SUB')
     D pal#            s              7  0
     D palcnt          s              2  0
     D pcktim          s              5  2
     D pcktm0          s              5  0
     D prtflg          s              1
BIReAD p1              s              3  0
BIReAD p2              s              3  0
     D remain          s              2  0
CWDyAD runtime         s              6  0
CWDyAD runtimea        s              6
     D shdcnt          s              3  0
701cAD sidebysideflag  s              1
JORcAD strnglen        s              3  0
     D ssdcnt          s              3  0
     D ssocur          s              3  0
BIRd D svord           s              7  0
CSP AD svpdev          s                   like(oppdev)
CSP AD svpfrm          s                   like(oppfrm)
     D stpcnt          s              2  0
     D svaisl          s              3
     D svtype          s              1
BIRx D t#brnd          s             10
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
     D zpocur          s              3  0
CSPtAD dispHH          s              2
CSPtAD dispMM          s              2
CSPtAD dispatch        s              5
520gAD keytype         s              1
520gAD typecode        s              2
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
JPFaAD willcall        s               n
IFDcAD*underline       s             11    inz('^GB103,0,04')
IFDcAD underline       s             11    inz('^GB103,0,15')
520hAD one             s              5  0 inz(1)
520hAD kycod1          s                   like(opzcod)
520iAD kycod3          s                   like(opzcod)
520iAD kycod4          s                   like(opzcod)
GFSnAD kyitem          s                   like(slitem)
GFSnAD kypick          s                   like(slpick)
GFSnAD kystat          s                   like(slstat)
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
SVLnAD work21          s             21
GFSnAD wrkdate         s                   like(lbrdte)
GFSnAD wrkdatea        s              8
DRYhAD work17a         s             17
RNZjAD fillerpass      s              3  0
530 AD t#pal#          s              7  0
530cAD work6           s              6  0
530cAD work6a          s              6
530cAD work8a          s              8
730gAD work11a         s             11
530cAD mdy             s               D   DatFmt(*MDY)
CWDaAD mmddyy          s              6  0
GFSnAD norcvdate       s              1    inz('0')
GFSnAD rcvdate         s             13
GFSnAD rcvtext         s              5
CSPmAD mmddyyyy        s              8  0
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
CSPiAD PreFlg          s              1
CSPoAD PreDup          s              1
530gAD svtrn#          s              7  0
CLDqAD fabitems        s               n
CPCbAD PrintColor      s             10
530dAD worklbl         s             10
PFCgAD target          s             10
CPCcAD goaltime        s              7  3
NCSaAD wkdisp          s             11
DRYdAD wkdisp2         s             12
640iAD lasttote        s               n
NCSbAD wkvnam          s             25
NCSdAD cmb1            s                   like(w1pick)
NCSdAD cmb2            s                   like(w1pick)
NCSdAD lblcnt          s                   like(w1pick)
640kAD svutyp          s              1
642mAD @pick           s              8
GFSnAD svwhdp          s                   like(lbwhdp)
GFSnAD svdisp          s                   like(lbdisp)
700 AD zmflag          s               n
700 AD zmsflag         s               n
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
701fAD svldry          s              1
     D wrksum          s              7  0
     D cldmrg          s              8
     D nxtseq          s              4  0
     D pcksum          s              7  0
     D skpdry          s              1
701fAD skp3            s              1
     D seqfld          s              6
     D tempn1          s              1  0
     D tempn2          s              2  0
     D tempn3          s              3  0
650gAD auditflag       s              1
SVLbAD work5           s              5  0
EOPbAD work10          s             10a
SVLbAD cust5           s              5
svleAD mdy2            s              6
svleAD iso             s              8  0
svleAD deliverydate    s              8
DRYfAD deliverydate2   s             10
svleAD mdyDate         s               d   datfmt(*mdy)
svleAD isoDate         s               d   datfmt(*iso)
DRYfAD usaDate         s               d   datfmt(*usa)
svlbAD work16          s             16
PANfAD work17          s             17
SVLiAD tmpslot         s             12
FRF AD olddsc          s             34
FRF AD newdsc          s             68
FRF AD newdsc1         s             34
FRF AD newdsc2         s             34
FRF AD fmtcod          s              1
FRF AD itmnote1        s             18
FRF AD itmnote2        s             18
CSPmAD itmnum          s             18
CSPnAD lsgnum          s             24
FRFdAD work3a          s              3
650mAD globalprtflg    s               n
650mAD globalfpass     s               n
WIFbAD woodflag        s               n
WIFcAD WoodPalletVar   s             11
DRYfAD methodofdlvry   s             30
DRYnD **cruiseshipflg  s              1
DRYnMD $prtflag        s              1
650lAD sectionstring   s             20
650lAD sectioncount    s              2  0
700kAD $command        s              9
700kAD voiceid         s              7  0
IFDhAD savopclvl       s              3  0
700kAD voiceid4n       s              4  0
700kAD voiceid4a       s              4
700lAD wkplid          s              7  0
700lAD wktran          s              7  0
CPCeAD chk4err         s               n
CPCeAD curlic#         s             15
CPCeAD $msgf           s             10
CPCeAD #fromToLcns     s                   like($saToLcns)
CPCeAD #fromOLcns      s                   like($saOLcns)
SFPbAD desc22          s             22
SFPeAD desc33          s             33
720aAD outputType      s             10
720gAd tbEnhanced      s               n
720gAd tbPalletType    s              1
720gAd tbType          s              1
720gAd tbWhse          s              3  0
730iAd useDFPICKordB   s               n
PCKaAd t#desc          s             44
740dAd wkpick          s              1
740dAd wkexpd          s              8  0
740dAd printexpb       s              1
DRYvAd superroute      s               n
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
750gad clientPFMT      s             10
750hAd strLen          s              5  0
750fAd lastkyfmt       s                   like(kyfmt)
750fAd fmtCount        s              5  0
750mDd*varFlag         s              1  0 dim(200) inz(0)
750mMd varFlag         s              1  0 dim(1000) inz(0)
760cAD CWTCount        s              3  0

720aA*----------------------------------------------------------------
720aA*  WRTIFS Variables
720aA*----------------------------------------------------------------
720aA
720aAd wCmd            s             10
720aAd wPath           s            256    varying
720aAd wFileName       s            128    varying
720aAd wLine           s           3072    varying
720aAd wFileId         s             10I 0 dim(4)
720aAd wRtn            s             10
720aad wMessage        s             60
720aAd wLabelCount     s              5  0 dim(4)
720aAd wFileCount      s              3  0 dim(4)
720aAd wStamp          s               z
ifs Ad ccFlag          s               n   dim(4)
ifs Ad xaFlag          s               n   dim(4)
ifs Ad prFlag          s               n   dim(4)

     *----------------------------------------------------------------
     *  Called Program Prototypes
     *----------------------------------------------------------------

720aA /copy qcopysrc,p.wrtifs
720gAd/copy qcopysrc,p.gettbtyp
730mAd/copy qcopysrc,p.umlabel

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

720aAd IFSOpenFile     pr
720aAd  fileNum                       3  0 const

720aAd IFSWriteLine    pr
720aAd  fileNum                       3  0 const

720aAd IFSCloseFile    pr
720aAd  fileNum                       3  0 const

720aAd IFSClosePgm     pr

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

750gA*----------------------------------------------------------------
750gA*  Divert to client PFMT program if necessary
750gA*----------------------------------------------------------------
750gA /free
750gA    clientPFMT = '';
750gA    select;
750gA      when client = cheney;
750gA        clientPFMT = 'PFMTCB3';
750gA    endsl;
750fA    $cpOutType = '';
750fA    $cpRtnCode = '';
750fA    $cpRtnMsg = '';
750fA    if %parms >= 17;
750fA      $cpOutType = $pOutType;
750fA    endif;
750fA    if %parms >= 18;
750fA      $cpRtnCode = $pRtnCode;
750fA      $cpRtnMsg = $pRtnMsg;
750fA    endif;
750gA    if clientPFMT <> '';
750gA /end-free
750gAC                   call      clientPFMT
750gAC                   parm                    $pcmd             8
750gAC                   parm                    $plset            6
750gAC                   parm                    $plfmt            8
750gAC                   parm                    $pwhse            3 0
750gAC                   parm                    $prtid            5
750gAC                   parm                    $pcomp            1
750gAC                   parm                    $ptzon            6
750gAC                   parm                    $pgen             1 0
750gAC                   parm                    $pszon            6
750gAC                   parm                    $ptruk           10
750gAC                   parm                    $prte             5
750gAC                   parm                    opzdta
750gAC                   parm                    $ptrn#            7 0
750gAC                   parm                    $plbl#            7 0
750gAC                   parm                    $pqty             5 0
750gAC                   parm                    $pcwt             7 2
750gAC                   parm                    $cpOutType        1
750gAC                   parm                    $cpRtnCode       10
750gAC                   parm                    $cpRtnMsg        99
750gA /free
750gA      if $pCmd = '*CLOSE'
750gA        or client <> cheney;
750gA        *inlr = *on;
750gA      endif;
750fA      if %parms >= 17;
750fA        $pOutType = $cpOutType;
750fA      endif;
750fA      if %parms >= 18;
750fA        $pRtnCode = $cpRtnCode;
750fA        $pRtnMsg = $cpRtnMsg;
750fA      endif;
750gA      return;
750gA    endif;
750gA /end-free

     *----------------------------------------------------------------
     *  Main line
     *

720aA /free
750gA      if $pCmd = '*CLOSE';
750gA        *inlr = *on;
750gA        return;
750gA      endif;

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
750oD    //return;
750oM    *inlr = *on;
750fA  endif;
750fA
720aA /end-free

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
PFCdAC                   when          client = prestofoods
PFCdAC                             and ($pcmd  = '*SHORT'
PFCdAC                             or   $pcmd  = '*SHORTM')
PFCdAC                   eval      svpdev = oppdev
PFCdAC                   eval      svpfrm = oppfrm
PFCdA*
640cAC                   endsl
cwdgA*
cwdgA* Get zone type.
cwdgA*
701cAC                   eval      sidebysideflag = 'N'
cwdgAC                   eval      kycode = '*PICK   '
cwdgAC                   eval      kyzone = $pszon
520hAC                   eval      opptyp = *blanks
cwdgAC     keyopz        chain     optionz
520hAC                   if        %found(optionz)
520hAC                   eval      opdta1 = opzdta
701cAC                   if        oplbl = 'S'
701cAC                             and $pgen = 1
701cAC                   eval      sidebysideflag = 'S'
701cAC                   endif
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
700sAC                             and $pcmd <> '*AMPBOX'
520iAC                   eval      $plset = %subst(oplp1:5:6)
640cAC                   endif
640cA*
640cAC                   if        oplb2 = 'Y'
700sAC                             and $pcmd <> '*AMPBOX'
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
PFCdAC                             or  client = prestofoods
PFCdAC                             and $pcmd = '*SHORT'
PFCdAC                             or  client = prestofoods
PFCdAC                             and $pcmd = '*SHORTM'
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
RYLaA*
RYLaA*   Get an order header record for route.
RYLaA*
RYLaAC     keyoh3        chain     ordh3
RYLaAC                   if        not %found(ordh3)
RYLaAC                   eval      ohord = *zeros
RYLaAC                   endif

DRYvA*    Determin if this is a super route

DRYvAC                   eval      superroute = *off
DRYvAC     keyzbr        chain     srrte
DRYvAC                   if        %found(srrte)
DRYvAC                   eval      superroute = *on
DRYvAC                   endif

700lA* Reprint pallet label
700lAC                   select
700lAC                   when      $pcmd = '*RPRTP1'
700lAC                             or $pcmd = '*RPRTP2'
750rAC                             or $pcmd = '*RPRTP2S'
700lAC                             or $pcmd = '*RPRTP3'
700lAC                   exsr      lblPltRePrint
700lAC                   goto      bottom
700lAC                   endsl
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
700nAC                             and $pcmd <> '*AMPBOX '
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

GFCeAC                   when      client <> GFC
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
700nAC                             and $pcmd <> '*AMPBOX '
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
700nAC                             and $pcmd <> '*AMPBOX '
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
701cAC                   when      sidebysideflag = 'S'
701cAC     keyps3        setll     pltsum3rp
ctwtAC                   when      client = citywholesale
ctwtMC     keyps3        setll     pltsum13
720cAC                   when      client = cheney
720cA **-> if location             and cliloc = cbiocl
720cAC     keyps3rpx     setll     pltsum3rp
ctwtMC                   other
     C     keyps3        setll     pltsum3
ctwtMC                   endsl
     C                   dou       forevr <> forevr
ctwtMC                   select
701cAC                   when      sidebysideflag = 'S'
701cAC     keyps3        reade     pltsum3rp                              79
ctwtAC                   when      client = citywholesale
ctwtAC     keyps3        reade     pltsum13                               79
720cAC                   when      client = cheney
720cA **-> if location             and cliloc = cbiocl
720cAC     keyps3        reade     pltsum3rp                              79
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
     *
     *     First time through initialization.
     *
     C                   if        first = *on
     C                   eval      lsttrn = pstrn#
TPCb C                   eval      lsszon = psszon
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
700nAC                             and $pcmd <> '*AMPBOX '
     C                   exsr      prtsel
520 AC                   endif
530dA*
530dA* If printing a single label and the last trans is the
530dA* trans for the requested label, print it and get out.
530dA*
700nAC                   Select
530dAC                   When      $pcmd = '*PRTLBL '
530dAC                             and $ptrn# = lsttrn
530gMC                   exsr      lblsub
530dAC                   exsr      prtlbl
jpfbA*
jpfbA*   Print END label.
jpfbA*
jpfbAC                   if        client = palmer
jpfbAC                   exsr      lblend
jpfbAC                   endif
530dAC                   goto      bottom

700nMC                   when      $pcmd = '*SHORT  '
530dAC                             and $ptrn# = lsttrn
530gMC                   exsr      lblsub
530dAC                   exsr      prtlbl
530dAC                   goto      bottom

700nMC                   when      $pcmd = '*SHORTM '
650aAC                             and $ptrn# = lsttrn
530gMC                   exsr      lblsub
530dAC                   exsr      prtlbl
530dAC                   goto      bottom

700nAC                   when      $pcmd = '*AMPBOX '
700nAC                             and $ptrn# = lsttrn
700nAC                   exsr      prtlbl
700nAC                   goto      bottom
700nMC                   endsl
530dA*
ctwtMC                   select
701cAC                   when      sidebysideflag = 'S'
701cAC     keyps3rp      setll     pltsum3rp
701cAC                   read      pltsum3rp
ctwtAC                   when      client = citywholesale
ctwtMC     keyps13       setll     pltsum13
ctwtMC                   read      pltsum13                               79
ctwtAC                   other
510hMC     keyps         setll     pltsum3t
510hMC                   read      PLTSUM3T                               79
ctwtMC                   endsl
     C                   eval      lsttrn = pstrn#
TPCb C                   eval      lsszon = psszon
SFGkAC                   eval      lstunl = psunld
     C                   eval      palcnt = 0
640pAc                   if        mpflag = 'Y'
720aAC                   if        outputType = 'IFS'
720aA /free
720aA                              IFSCloseFile(1);
720aA /end-free
720aAC                   else
640pAc                   close     pfmtpr
720aAC                   endif
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
700nAC                   select
700nMC                   when      $pcmd = '*PRTLBL '
520cAC                             or $pcmd = '*SHORT  '
650aAC                             or $pcmd = '*SHORTM '
530gD ***                exsr      lblzhd
530gMC                   exsr      lblsub
520 MC                   exsr      prtlbl
jpfbA*
jpfbA*   Print END label.
jpfbA*
jpfbAC                   if        client = palmer
jpfbAC                   exsr      lblend
jpfbAC                   endif
520 MC                   goto      bottom
700nAC                   when      $pcmd = '*AMPBOX '
700nAC                   exsr      prtlbl
700nAC                   goto      bottom
700nMC                   endsl
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

700nAC                   select
700nMC                   when      $pcmd = '*PRTLBL '
530dAC                             and $ptrn# = lsttrn
530dAC                             or $pcmd = '*SHORT  '
530dAC                             and $ptrn# = lsttrn
650aAC                             or $pcmd = '*SHORTM '
650aAC                             and $ptrn# = lsttrn
530gD ***                exsr      lblzhd
530gMC                   exsr      lblsub
530dAC                   exsr      prtlbl
jpfbA*
jpfbA*   Print END label.
jpfbA*
jpfbAC                   if        client = palmer
jpfbAC                   exsr      lblend
jpfbAC                   endif
530dAC                   goto      bottom

700nMC                   when      $pcmd = '*AMPBOX '
700nAC                   exsr      prtlbl
700nAC                   goto      bottom
700nMC                   endsl

     C                   exsr      prtsel
     C                   endif
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
     C                   eval      *inlr = *on
     *
     *   Close up shop and return home.
     *
720aM*   (Removed Lr from close statements)
     *
     C                   if        opened = *on
720aAC                   if        outputType = 'IFS'
720aA /free
720aA                              IFSCloseFile(1);
720aA /end-free
720aAC                   else
     C                   close     pfmtpr
720aAC                   endif
     C                   endif
640cA*
640cAC                   if        openedpfmtprt2 = *on
720aAC                   if        outputType = 'IFS'
720aA /free
720aA                              IFSCloseFile(2);
720aA /end-free
720aAC                   else
640cAC                   close     pfmtpr2
720aAC                   endif
640cAC                   endif
640cA*
640cAC                   if        openedpfmtprt3 = *on
720aAC                   if        outputType = 'IFS'
720aA /free
720aA                              IFSCloseFile(3);
720aA /end-free
720aAC                   else
640cAC                   close     pfmtpr3
720aAC                   endif
640cAC                   endif
CSPlA*
CSPlAC                   if        openedpfmtprt4 = *on
720aAC                   if        outputType = 'IFS'
720aA /free
720aA                              IFSCloseFile(4);
720aA /end-free
720aAC                   else
CSPlAC                   close     pfmtpr4
720aAC                   endif
CSPlAC                   endif

730bAC                   if        outputType = 'IFS'
720aA /free
720aA                              IFSClosePgm();
720aA /end-free
730bAC                   endif

     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
500gA*
500gA* Get client id.
500gA*
500gAC                   call      @getcl
500gAC                   parm                    client
500gAC                   parm                    cliloc
500gA*
GFSnA*      Open Slot3 file.
GFSnA*
GFSnAC                   if        client = Getfresh
GFSnA*
GFSnAC                   if        not %open(slot3)
GFSnAC                   open      slot3
GFSnAC                   endif
GFSnA*
GFSnAC                   endif
GFSnA*
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
750aAC                   eval      xohord = 0
     *
510bA*  Get zebra logging flag.
510bAC*
510bAC     *DTAARA       define    zbrlog        logzebra
510bAC                   in(e)     logzebra
510bAC                   if        %error
510bAC                   eval      logzebra = *off
510bAC                   endif
     *
     *
     *  Define key for AMPxRef file to get AMP slot
     *
700jAC     keyAMPX1      klist
700jAC                   kfld                    $pwhse
700vAC                   kfld                    lbrte
700jAC                   kfld                    ohcord
700jAC                   kfld                    lbitem
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
SWTdA*
SWTdA*  Define partial key for ORDP2 file.
SWTdA*
SWTdAC     keyorp5       klist
SWTdAC                   kfld                    $prtid
SWTdAC                   kfld                    alblbl#
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
701cA*  Define full key for PLTSUM3RP file.
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
     C                   kfld                    curunl
     C                   kfld                    currow
     C                   kfld                    curcol
     *
720cA*  Define partial key for PLTSUM3RPx file.
     *
     C     keyps3rpx     klist
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
CSPo *
CSPo *  Define key for PREXREF5 looking for Dup Rt process
CSPo *
CSPoAC     keypred       klist
CSPoAC                   kfld                    $pwhse
CSPoAC                   kfld                    ohcord
CSPoAC                   kfld                    lbitem
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
GFSnA*
GFSnA*  Define partial key for SLOT3 file.
GFSnA*
GFSnAC     keysl3        klist
GFSnAC                   kfld                    $pwhse
GFSnAC                   kfld                    kyitem
GFSnAC                   kfld                    kystat
GFSnAC                   kfld                    kypick
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
RYLaA*
RYLaA*  Define key for ORDH3 file.
RYLaA*
RYLaAC     keyoh3        klist
RYLaAC                   kfld                    $pwhse
RYLaAC                   kfld                    $prtid
     *
RYLaA*  Define key for ORDHM file.
RYLaA*
RYLaAC     kyohm         klist
RYLaAC                   kfld                    $pwhse
RYLaAC                   kfld                    ohord
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
SFGa *  Define key for ITEMMSC file.
     *
SFGa C     keyim         klist
SFGa C                   kfld                    $pwhse
SFGa C                   kfld                    lbitem
642mA*
642mA*  Define key for CUSTEXP file.
642mA*
642mAC     keyexp        klist
642mAC                   kfld                    $pwhse
642mAC                   kfld                    ohcust

642mAC     keyexp2       klist
642mAC                   kfld                    $pwhse
642mAC                   kfld                    ohcust
642mAC                   kfld                    itwhdp
svleA*
svleA*  Define partial key for RTEHED file.
svleA*
svleAC     keyrte        klist
svleAC                   kfld                    $pwhse
svleAC                   kfld                    $prtid
     *
     *  Slot key
     *
SVLiAC     slotky        klist
SVLiAC                   kfld                    lbwhse
SVLiAC                   kfld                    lbwhdp
SVLiAC                   kfld                    lbdisp
     *
     *  Define key for UNMESR1
     *
701hAC     keyUOM        klist
701hAC                   kfld                    umshrt
700lA*
700lA*  Define partial key for LABEL3 file.
700lA*
700lAC     keyps4p       klist
700lAC                   kfld                    $ptrn#
700lAC                   kfld                    $pwhse
710dA*
710dA*  Define key for Trkcomp file.
710dA*
710dAC     kytrcp        klist
710dAC                   kfld                    $pwhse
710dAC                   kfld                    pscomp
     *
     *  Define key for ITEMEXT
     *
EOPbAC     keyitext      klist
EOPbAC                   kfld                    $pwhse
EOPbAC                   kfld                    lbitem
750bA*
750bA*  Define partial key for LABEL3 file.
750bA*
750bAC     keylb76       klist
750bAC                   kfld                    $pwhse
750bAC                   kfld                    $prtid
750bAC                   kfld                    tlbtrn#
750bAC                   kfld                    psplid
750bAC                   kfld                    tlbtype

DRYvA*
DRYvA*  Define key for SRORD1 file.
DRYvA*
DRYvAC     keysor        klist
DRYvAC                   kfld                    $pwhse
DRYvAC                   kfld                    $prtid
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     *  Convert today's runtime
     *
CWDyAC                   time                    runtime
     C                   move      runtime       runtimea
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
700bMC                   other
530aAC                   movel     opdata        oppdta
700bAC                   if        oprplt = '2'
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
650mA*   Turn on Global printing flag'
650mA*
650mAC                   eval      Globalprtflg = '1'
650mAC                   eval      Globalfpass = '1'
730jA**
730jA**  See if we are using user-defined DFPICK
730jA**
730jAc                   eval      gpscmd = '*ISSOFT'
730jAc                   monitor
730jAc                   call      'GETPSEQO'
730jAc                   parm                    gpscmd            8
730jAc                   parm                    $pwhse
730jAc                   parm      ' '           gpswhdp           5
730jAc                   parm      ' '           gpsdisp          12
730jAc                   parm      ' '           gpsSeqcd          1
730jAc                   parm      0             gpsSeq            5 0
730jAc                   parm      ' '           usrDFPICK         1
730jAc                   on-error
730jAc                   eval      usrDFPICK = 'N'
730jAc                   endmon
730iA*
730iA*   Set usage of LABEL32D file (LBLVL2 before LBWHDP)
730iA*
FSHdAC                   if        client = FischerFoods
KFS AC                             or client = Kellys
DRYlAC                             or client = dairyland
DRYmMC                             and (cliloc = drybronx
DRYpAC                               or cliloc = drytoronto
DRYmAC                               or cliloc = dryqznchicago)
GFSfAC                             or client = Getfresh
HKWaAC                             or client = HKW
GLPhD *                            or client = Greenleaf
SVLfAC                             or client = saval
FRFbAC                             or client = FRF
CPCbAC                             or client = cpc
PFChAC                             or client = Prestofoods
WIL AC                             or client = WillFoods
FPRdAC                             or client = FoodPro
JSLaAC                             or client = JSilvert
PANcAC                             or client = Panos
RNZkAC                             or client = Renzi
ADFbAC                             or client = AandDFoods
TPCcAC                             or client = tpc
TPCcAC                             and lsszon <> 'PROD'
RYLfMC                             or client = royal
JPFdAC                             or client = palmer
MRT AC                             or client = merit
GRC AC                             or client = Greco
COTbAC                             or client = cotati
SWT AC                             or client = swt
730jAC                             or usrDFPICK = 'Y'
730iAC                   eval      useDFPICKordB = *on
730iAC                   else
730iAC                   eval      useDFPICKordB = *off
730iAC                   endif
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
DRYvAC                   eval      dssrst = *blanks
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
     *
     *      Override printer file.
     *
     *          OVRPRTF FILE(PFMTPR) OUTQ(*DEV) DEV(rodev)
     *                  FORMTYPE(roform)
     *
JORbAC                   if        client = Jordanos
DFFaAC                             or client = Dilgard
JORbA*      Apply prtf override to outq instead of prtdev.
JORbAC                   movea     ovrprt(2)     a80
JORbAC                   else
     C                   movea     ovrprt(1)     a80
JORbAC                   endif
JORbA*
650nAC                   select
     *
642kMC                   when      $pcmd = '*PR321  '
642jAC                   eval      opdv1 = oppdev
642jAC                   eval      opfm1 = oppfrm
700cAC                   movea     oppdev        a80(37)
700cAC                   movea     oppfrm        a80(58)

700oA*      Override labels using device from template.
700oAC                   when      $pcmd = '*PRTLBL '
700oAC                             and oppdev = '*JOB'
700nAC                             or $pcmd = '*AMPBOX '
700nAC                             and oppdev = '*JOB'
700oAC                   movea     opdv1         a80(37)
700oAC                   movea     opfm1         a80(58)

642kAC                   when      $pcmd = '*PRTLBL '
642kAC                             and oppdev <> *blanks
642kAC                             or $pcmd = '*SHORT  '
642kAC                             and oppdev <> *blanks
650aAC                             or $pcmd = '*SHORTM '
650aAC                             and oppdev <> *blanks
700nAC                             or $pcmd = '*AMPBOX '
700nAC                             and oppdev <> *blanks
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
720aA*
720aA*   See if we should override to QPRINT
720aA*
720aAC                   if        outputType = 'QPRINT'
720aAC                   movea     ovrprt(1)     a80
720aAC                   movea     'QPRINT    '  a80(37)
720aAC                   endif

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
720aA*
720aA*      See if we should override to QPRINT
720aA*
720aAC                   if        outputType = 'QPRINT'
720aAc                   eval      zondev = 'QPRINT'
720aAC                   endif

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

CWDyAC                   select
CWDyAC                   when      client = cashwa
CWDyAC                   eval      opfm4a = 'BIGP'
CWDyAC                   eval      bigpal2 = 'BIGP' + $pcomp
CWDyAC     bigpal2       chain     ctwzondev
CWDyAC                   if        not %found(ctwzondev)
CWDyAC                   eval      bigpal2 = 'BIGPAL'
CWDyAC     bigpal2       chain     ctwzondev
CWDyAC                   if        not %found(ctwzondev)
CWDyAC                   eval      zondev = 'QPRINT'
CWDyAC                   eval      opfm4a = 'BIGP'
CWDyAC                   endif
CWDyAC                   endif

     C                   other
CWDyAC                   eval      bigpal2 = 'BIGPAL'
CSPlAC     bigpal2       chain     ctwzondev
CSPlAC                   if        not %found
CSPlAC                   eval      zondev = 'QPRINT'
CSPlAC                   eval      opfm4a = 'BIGP'
CSPlAC                   endif
     C                   endsl
720aA*
720aA*      See if we should override to QPRINT
720aA*
720aAC                   if        outputType = 'QPRINT'
720aAc                   eval      zondev = 'QPRINT'
720aAC                   endif

CSPlAC                   eval      qcmd = 'OVRPRTF'
CSPlAC                                  + ' FILE(PFMTPR4)'
CSPlAC                                  + ' OUTQ(*DEV)'
CSPlAC                                  + ' DEV(' +  %trim(zondev) + ')'
CSPlAC                                  + ' FORMTYPE(' +  %trim(opfm4a) + ')'
CSPlAC                                  + ' SAVE(*YES)'

750rA*         Use sent in device for *RPRTP2S
750rA
750rAC                   if        $pcmd = '*RPRTP2S'
750rA /free
750rA    qcmd = 'OVRPRTF FILE(PFMTPR4) OUTQ(*DEV) '
750rA         + 'DEV(' + %trim(oppdev) + ')'
750rA         + ' FORMTYPE(' +  %trim(opfm4a) + ')'
750rA         + ' SAVE(*YES)';
750rA /end-free
750rAC                   endif

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
ctwaA
ctwaA*      Override printer file Tobacco/Retail/Candy labels.
ctwaA
ctwaAC                   if        retailflag
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
ctwaA
ctwaD ***  $pszon        chain     ctwzondev
ctwaD ***                if        not %found(ctwzondev)
ctwaD ***                eval      zondev = 'QPRINT'
ctwaD ***                endif
ctwaAC                   endif
ctwaAc                   if        opfm1  = *blanks
ctwaAc                             and opfm2  = *blanks
ctwaAc                   eval      zonfrm = 'PICKRETL'
ctwaAC                   endif
720aA*
720aA*      See if we should override to QPRINT
720aA*
720aAC                   if        outputType = 'QPRINT'
720aAc                   eval      zondev = 'QPRINT'
720aAC                   endif

ctwaAC                   eval      qcmd = 'OVRPRTF'
ctwaAC                                  + ' FILE(PFMTPR2)'
ctwaAC                                  + ' OUTQ(*DEV)'
ctwaAC                                  + ' DEV(' +  %trim(zondev) + ')'
ctwaAC                                  + ' FORMTYPE(' +  %trim(zonfrm) + ')'
ctwsAC                                  + ' SAVE(*YES)'
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
720aA*
720aA*   See if we should override to QPRINT
720aA*
720aAC                   if        outputType = 'QPRINT'
720aAC                   movea     'QPRINT    '  a80(37)
720aAC                   endif

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
     *  PRINT   Output string to printer.
     *
     C     print         begsr
     C                   eval      prtflg = *off
     C                   movea     sto           @outpt
720aAC                   eval      wLine = %trimr(@outpt)

640cAC                   select

CSPqAC                   when      client = coastalsunbelt
CSPqAC                             and  kyfmt = 'BIGPAL  '
CSPqAC                             and (rhtruk = 'ADD-ON'
CSPqAC                             or rhtruk = 'ADDONLATES')
CSPqA **>                except ** #str4

650mAC                   when      Globalprtflg
650mAC                             and Globalfpass
650mAC                             and kyfmt = 'ZONHED'
650mAC                             and @outpt = '~CC^'
720aAC                   if        outputType = 'IFS'
720aA /free
720aA                              IFSWriteLine(1);
720aA /end-free
720aAC                   else
750fAC                   if        sendToPrinter
650mAC                   except    #str
750fAC                   endif
720aAC                   endif

650mAC                   eval      @outpt = '^XA^ZC2^JUS^XZ'
720aAC                   if        outputType = 'IFS'
720aA /free
720aA                              wLine = %trimr(@outpt);
720aA                              IFSWriteLine(1);
720aA /end-free
720aAC                   else
750fAC                   if        sendToPrinter
650mAC                   except    #str
750fAC                   endif
720aAC                   endif

730dAC                   eval      @outpt = '^XA^PON^XZ'
730dAC                   if        outputType = 'IFS'
730dA /free
730dA                              wLine = %trimr(@outpt);
730dA                              IFSWriteLine(1);
730dA /end-free
730dAC                   else
750fAC                   if        sendToPrinter
730dAC                   except    #str
750fAC                   endif
730dAC                   endif
730dAC                   eval      Globalfpass = '0'

700bAC                   when      kyfmt = 'BIGPAL  '
720aAC                   if        outputType = 'IFS'
720aA /free
720aA                              IFSWriteLine(4);
720aA /end-free
720aAC                   else
750fAC                   if        sendToPrinter
700bAC                   except    #str4
750fAC                   endif
720aAC                   endif

CSPlAC                   when      client = coastalsunbelt
CSPlAC                             and  (kyfmt = 'BIGPAL  '
CSPpAC                             or kyfmt = 'BIGPALA ')
720aAC                   if        outputType = 'IFS'
720aA /free
720aA                              IFSWriteLine(4);
720aA /end-free
720aAC                   else
750fAC                   if        sendToPrinter
CSPlAC                   except    #str4
750fAC                   endif
720aAC                   endif

DRYkAC                   when      client = dairyland
DRYkAC                             and  kyfmt = 'BIGPAL  '
720aAC                   if        outputType = 'IFS'
720aA /free
720aA                              IFSWriteLine(4);
720aA /end-free
720aAC                   else
750fAC                   if        sendToPrinter
DRYkAC                   except    #str4
750fAC                   endif
720aAC                   endif

SWTdAC                   when      totzon
SWTdAC                             and  client = swt
SWTdAC                             and  kyfmt  = 'XTOTE   '
SWTdAC                   if        outputType  = 'IFS'
SWTdA /free
SWTdA                              IFSWriteLine(1);
SWTdA /end-free
SWTdAC                   else
750fAC                   if        sendToPrinter
SWTdAC                   except    #str
750fAC                   endif
SWTdAC                   endif

640cAC                   when      totzon
640cAC                             and  kyfmt = 'XTOTE   '
720aAC                   if        outputType = 'IFS'
720aA /free
720aA                              IFSWriteLine(3);
720aA /end-free
720aAC                   else
750fAC                   if        sendToPrinter
640cAC                   except    #str3
750fAC                   endif
720aAC                   endif

CWDzAC                   when      totzon
CWDzAC                             and  kyfmt = 'XTOTE2D '
720aAC                   if        outputType = 'IFS'
720aA /free
720aA                              IFSWriteLine(3);
720aA /end-free
720aAC                   else
750fAC                   if        sendToPrinter
CWDzAC                   except    #str3
750fAC                   endif
720aAC                   endif

ctwaAC                   when      totzon
ctwaAC                             and  kyfmt = 'XTOTES  '
720aAC                   if        outputType = 'IFS'
720aA /free
720aA                              IFSWriteLine(3);
720aA /end-free
720aAC                   else
750fAC                   if        sendToPrinter
ctwaAC                   except    #str3
750fAC                   endif
720aAC                   endif

640qAC                   when      totzon
640qAC                             and  kyfmt = 'XTOTE2  '
640qAC                             and  client = Cashwa
720aAC                   if        outputType = 'IFS'
720aA /free
720aA                              IFSWriteLine(3);
720aA /end-free
720aAC                   else
750fAC                   if        sendToPrinter
640qAC                   except    #str3
750fAC                   endif
720aAC                   endif

CWDzAC                   when      totzon
CWDzAC                             and  kyfmt = 'XTOTE22D'
CWDzAC                             and  client = Cashwa
720aAC                   if        outputType = 'IFS'
720aA /free
720aA                              IFSWriteLine(3);
720aA /end-free
720aAC                   else
750fAC                   if        sendToPrinter
CWDzAC                   except    #str3
750fAC                   endif
720aAC                   endif

CWDzAC                   when      totzon
CWDzAC                             and  kyfmt = 'XTOTE32D'
CWDzAC                             and  client = Cashwa
720aAC                   if        outputType = 'IFS'
720aA /free
720aA                              IFSWriteLine(3);
720aA /end-free
720aAC                   else
750fAC                   if        sendToPrinter
CWDzAC                   except    #str3
750fAC                   endif
720aAC                   endif

640cAC                   when      totzon
640iAC                             and  kyfmt = 'XTOTE3  '
720aAC                   if        outputType = 'IFS'
720aA /free
720aA                              IFSWriteLine(3);
720aA /end-free
720aAC                   else
750fAC                   if        sendToPrinter
640cAC                   except    #str3
750fAC                   endif
720aAC                   endif

640cAC                   when      totzon
640cAC                             and  kyfmt = 'XTOTE2  '
720aAC                   if        outputType = 'IFS'
720aA /free
720aA                              IFSWriteLine(2);
720aA /end-free
720aAC                   else
750fAC                   if        sendToPrinter
640cAC                   except    #str2
750fAC                   endif
720aAC                   endif

ctwaAC                   when      tobaccoflag
720aAC                   if        outputType = 'IFS'
720aA /free
720aA                              IFSWriteLine(2);
720aA /end-free
720aAC                   else
750fAC                   if        sendToPrinter
ctwaAC                   except    #str2
750fAC                   endif
720aAC                   endif

ctwaAC                   when      candyflag
720aAC                   if        outputType = 'IFS'
720aA /free
720aA                              IFSWriteLine(2);
720aA /end-free
720aAC                   else
750fAC                   if        sendToPrinter
ctwaAC                   except    #str2
750fAC                   endif
720aAC                   endif

ctwaAC                   when      retailflag
720aAC                   if        outputType = 'IFS'
720aA /free
720aA                              IFSWriteLine(2);
720aA /end-free
720aAC                   else
750fAC                   if        sendToPrinter
ctwaAC                   except    #str2
750fAC                   endif
720aAC                   endif

640cAC                   other
750fDC**                 if        outputType = 'IFS'
720aA /free
720aA                              IFSWriteLine(1);
720aA /end-free
750fDC**                 else
750fAC                   if        sendToPrinter
     C                   except    #str
750fAC                   endif
750fDC**                 endif

640cAC                   endsl

     C                   eval      sto = *blanks
     C                   eval      op = 0
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
720iDC**   keyps3        reade     pltsum13                               79
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
650cA*
650cA*     Skip if reprint by label and printing a different label.
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
701hA*
701hA*     Get uom code
701hA*
701hAC                   eval      u_umcode = *blanks
701hAC     keyUOM        chain     unmesr1
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
VFIcA*     Get order detail misc
VFIcA*
VFIcAC                   exsr      getORDDM
CWDfA*
dry A*     Get order detail misc
dry A*
JOReAC                   if        client = Jordanos
JOReA*      Header Misc. retrieved in GETORDH.
JOReAC                   else
JOReA*
dry AC                   exsr      getORDHM
JOReAC                   endif
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
640sAC                             or client = cpc
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
GFSnA*
GFSnA*    Get receive date from License active file for pick slot.
GFSnA*
GFSnAC                   select
GFSnAC                   when      client = Getfresh
GFSnAC                   exsr      rcvdategfs
GFSnAC                   endsl
     *
CPCeA*  Get slot information (License)
     *
CPCeAC                   if        client = cpc
CPCeAC                   exsr      zzgets
CPCeAC                   endif
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
SBRx C                   when      client = sbertram
SBRx C                   eval      kyfmt = 'PALLET  '
SBRx C                   eval      dsstp1 = psstp1
SBRx C                   eval      dsstp2 = psstp2

BIRaAC                   when      client = birite
BIRgAC                             and lbgrp2 <> 'W'
BIRaAC                   eval      kyfmt = 'PALLET  '
     C                   eval      dsstp1 = psstp1
     C                   eval      dsstp2 = psstp2

BIRaAC                   when      client = birite
BIRaAC                   eval      kyfmt = *blanks

VFIfAC                   when      client = vitco
VFIfAC                   eval      kyfmt = *blanks

JPFaAC                   when      client = palmer
JPFaAC                             and willcall
JPFaAC                   eval      kyfmt = *blanks

CSPpAC                   when      client = coastalsunbelt
CSPpAC                             and preflg = 'Y'
CSPpAC                   eval      kyfmt = 'BIGPALA '

CSPlAC                   when      client = coastalsunbelt
DRYrDC*                            or client = dairyland
700bAC                             or bigpallabel
CWDyAC                             or client = cashwa
CWDyAC                             and $pcomp = 'D'
CWDyAC                             or client = cashwa
CWDyAC                             and $pcomp = 'F'
CWDyAC                             or client = cashwa
CWDyAC                             and $pcomp = 'R'
CSPlAC                   eval      kyfmt = 'BIGPAL  '
GMMx C                   eval      dsstp1 = psstp1
GMMx C                   eval      dsstp2 = psstp2

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
700iAC                   eval      dsstp1 = psstp1
700iAC                   eval      dsstp2 = psstp2
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

     *
     *       ISY req to print 3 Pallet Labels with BIG print
     *                  everyone else continues to print PALLET
ISYiAC                   select
ISYiAC                   when      (client = isupply
HALcAC                             or client = halsey)
ISYiAC                             and $ptruk <> 'WILLCALL'
ISYiAC                   eval      kyfmt = 'PALLET1 '
ISYiAC                   exsr      fillb1
ISYiAC                   eval      kyfmt = 'PALLET2 '
ISYiAC                   exsr      fillb1
ISYiAC                   eval      kyfmt = 'PALLET3 '
ISYiAC                   exsr      fillb1

JSLeAC                   when      client = jslvrt
JSLeAC                             and $ptruk <> 'WILLCALL'
JSLeAC                   eval      kyfmt = 'PALLET1 '
JSLeAC                   exsr      fillb1
JSLeAC                   eval      kyfmt = 'PALLET2 '
JSLeAC                   exsr      fillb1

     *  Vitco wants Pallet Label just before END, SKIP here
VFIfAC                   when      client = vitco

ISYiAC                   other

     C                   exsr      fillb1
ISYiAC                   endsl
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
CL2dAC                   select
416dAC                   when      itcwgt = 'Y'
416dAC                             and opcwgt <> 0
416dAC     lbqpck        div       opcwgt        lbls
416dAC                   mvr                     remain
416dAC                   if        remain <> 0
416dAC                   add       1             lbls
416dAC                   endif
416dAC     1             do        lbls          CWTCount
PCKnAC                   if        client = pack730
PCKnA*       Bypass printing catchwgt labels.
PCKnAC                   else
416dAC                   exsr      lblcwt
PCKnAC                   endif
PCKnA*
416dAC                   enddo

CL2dAC                   when      client = cityline
CL2dAC                             and itcwgt = 'Y'
CL2dAC                             and opcwgt = 0
CL2dAC                             and ($pcmd = '*REPRINT'
CL2dAC                             or   $pcmd = '*RPRTZN'
CL2dAC                             or   $pcmd = '*RPRTLB'
CL2dAC                             or   $pcmd = '*PRTTRN')
CL2dAC     1             do        lbqpck
CL2dAC                   exsr      lblcwt
CL2dAC                   enddo

CL2dMC                   endsl
     *
     *       Print pallet label.
     *             Vitco wants Pallet Label just before END.
VFIfAC                   if        client = vitco
VFIfAC                   eval      kyfmt = 'PALLET  '
VFIfAC                   exsr      fillb1
VFIfAC                   endif
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
     *
510gA*  get label record.
     *
510gAC     $plbl#        chain     label
510gAC                   if        not %found(label)
510gAC                   eval      error = *on
510gAC                   goto      endpl
510gAC                   endif
650kA*
650kA*  Position to first unique piece number for label.
650kA*
700eD ***  keyorp2       setll     ordp2
700eMC     $plbl#        setll     ordp2
510gA*
510gA*  Move information into parameter fields.
510gA*
640uMC                   eval      $pwhse = lb_lbwhse
640uMC                   eval      $prtid = lb_lbrte
730cAC                   eval      @rtid  = lb_lbrte
510gA*
510gA*  Get label record.
510gA*
510gAC     key32a        setll     label32
510gAC                   dou       forevr <> forevr
510gAC     key32a        reade     label32
510gAC                   if        %eof(label32)
510gAC                             or lblbl# = $plbl#
510gAC                   leave
510gAC                   endif
510gAC                   enddo
701eA*
701eAC     keyim         chain     itemmsc
701eAC                   if        not %found(itemmsc)
701eAC                   eval      imbrnd=*blanks
701eAC                   endif
530eA*
530eA*     Get order header record
530eA*
530eAC                   exsr      getORDH
650oA*
650oA*     Get order header misc
650oA*
JOReAC                   if        client = Jordanos
JOReA*      Header Misc. retrieved in GETORDH.
JOReAC                   else
JOReA*
650oAC                   exsr      getORDHM
JOReAC                   endif
530eA*
530eA*     Get order detail miscellaneous
530eAC                   exsr      getORDDM
730mA*
730mA*     Get label UM record
730mAC                   exsr      getLABELUM
650kA*
650kA*          Get unique piece number for label.
650kA*
700eD ***  keyorp2       reade     ordp2
700gM ***  keyorp        reade     ordp2
700gA ***                if        %eof
700gA ***                eval      unqpiece# = 0
700gA ***                else
700gA ***                eval      unqpiece# = orpup#
700gA ***                endif
510gA*
510gA*    If label not found for some strange reason, get out.
510gA*
510gAC                   if        %eof(label32)
510gAC                   eval      error = *on
510gAC                   goto      endpl
510gAC                   endif
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
720jAC                   eval      ixdsc1 = *blanks
720jAC                   eval      ixdsc2 = *blanks
510gAC                   eval      itvit# = *blanks
510gAC     keyil         chain     piritem
510gAC                   if        %found(piritem)
720jAC     keyil         chain     itemdsc
510gAC                   endif
510gA*
510gA*    Print label.
510gA*
510gA*        Either print a combination label ...
510gA*
510gAC                   select
520dMC                   when      pckqty >= opclvl
730mAC                             or umFlexPickFlag = 'P2W'
730mAC                             or umFlexPickFlag = 'PAQ'
700nAC                             or $pcmd = '*AMPBOX'
510gAC                             or ITTYPE = 'S'
FFCbAC                             and client <> FischerFoods
HKWeAC                             and client <> hkw
COTcAC                             and client <> cotati
MRTcAC                             and client <> merit
CL2cAC                             and client <> cityline

RYLbAC                             or client =royal
RYLbAC                             and $pqty >= 2
RYLbAC                             and itum2 = 'Y'
510gAC                   eval      combo = '1'
520dMC                   eval      w1pick = pckqty
CCPaAC                   if        client = capitolcity
CWDwAC                             or client = cashwa
GFSkAC                             or client = getfresh
FRFaAC                             or client = frf
MJKhAC                             or client = mjkellner
RYLaAC                             or client = royal
SFPdAC                             or client = seashore
GRCdAC                             or client = greco
CCPaAC                   exsr      lblitmn
CCPaAC                   endif

700gA*          Get unique piece number for label.
700gA*
700gAC     keyorp        reade     ordp2
700gAC                   if        %eof
700gAC                   eval      unqpiece# = 0
700gAC                   else
700gAC                   eval      unqpiece# = orpup#
700gAC                   endif
730mA
730mA*    Set quantity to weight for pick-to-weight
730mA /free
730mA
730mA    select;
730mA      when umFlexPickFlag = 'P2W';
730mA        w1qty2 = lbswgt;
730mA        w1pick = lbswgt;
730mA        umshrt = lbualu1;
730mA    endsl;
730mA
730mA /end-free

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
MJKhAC                             or client = mjkellner
RYLaAC                             or client = royal
SFPdAC                             or client = seashore
GRCdAC                             or client = greco
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
700nAC                             and $pcmd <> '*AMPBOX'
530eAC                   exsr      lblend
ISYfAC                   endif
     *
510gAC     endpl         endsr
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
701fAC                   eval      svldry = *off
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
TPCeAC                   when      useDFPICKordB
TPCeAC                             and client = tpc
TPCeAC     keyl32        setll     label32x
730iMC                   when      useDFPICKordB
FSHdAC     keyl32        setll     label32d
CTWcAC                   when      client = citywholesale
CTWcAC     keyl32        setll     label32e
SFGdAC                   when      client = SGC
SFGdAC     keyl32        setll     label32g
MJKcAC                   when      client = mjkellner
MJKcAC                             and mjkContract
TPCcAC                             or client = tpc
TPCcAC                             and lsszon = 'PROD'
MJKbMC     keyl32        setll     label32s
ACCaAC                   when      client = accardi
ACCaAC                             and ($pszon = 'REFF'
ACCaAC                             or  $pszon = 'FRZBIN')
ACCaAC     keyl32        setll     label32s

DFFeAC                   when      client = Dilgard
DFFeMC     keyl32        setll     label32s

CLDiAC                   when      client = cityline
GLPhAC                             or client = Greenleaf
CFIaAC                             or client = Colony
CLDiMC     keyl32        setll     label32x
PFCaAC***PFChD           when      client = Prestofoods
PFCaAC*PFChkeyl32        setll     label32j
ISYcMC                   when      client = isupply
ISYcMC     keyl32        setll     label32i
640sAC                   other
     C     keyl32        setll     label32c
640sMC                   endsl
     *
     C                   dou       forevr <> forevr
640sAC                   select
TPCeAC                   when      useDFPICKordB
TPCeAC                             and client = tpc
TPCeAC     keyl32        reade     label32x                               78
730iMC                   when      useDFPICKordB
FSHdAC     keyl32        reade     label32d                               78
CTWcAC                   when      client = citywholesale
CTWcAC     keyl32        reade     label32e                               78
SFGdAC                   when      client = SGC
SFGdAC     keyl32        reade     label32g                               78
MJKcAC                   when      client = mjkellner
MJKcAC                             and mjkContract
TPCcAC                             or client = tpc
TPCcAC                             and lsszon = 'PROD'
MJKbMC     keyl32        reade     label32s                               78
ACCaAC                   when      client = accardi
ACCaAC                             and ($pszon = 'REFF'
ACCaAC                             or  $pszon = 'FRZBIN')
ACCaAC     keyl32        reade     label32s                               78

DFFeAC                   when      client = Dilgard
DFFeAC     keyl32        reade     label32s                               78

CLDiAC                   when      client = cityline
GLPhAC                             or client = Greenleaf
CFIaAC                             or client = Colony
CLDiMC     keyl32        reade     label32x                               78
PFCaAC***PFChD           when      client = Prestofoods
PFCaAC*PFChkeyl32        reade     label32j                               78
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
701fAC                   select
701fAC                   when      client = cityline
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

701fAC                   when      client = saval
701fA*
701fAC                   if        lbaisl > ' '
701gAC                             and ohtype <> 'W'
701fAC                   eval      temp1a = %subst(%trim(lbaisl):1:1)
701fAC                   else
701fAC                   eval      temp1a = ' '
701fAC                   endif
701fA*
701fA*     See if we should be ignoring Dry.
701fA*
701fAC                   if        skpdry = *on
701fAC                             and temp1a <= 'C'
701fAC                   iter
701fAC                   endif
701fA*
701fA*     Flag when we read a Gen 1 DRY label
701fA*
701fAC                   if        $pgen = 1
701fAC                             and skpdry = '0'
701fAC                             and temp1a = 'D'
701fAC                   eval      svldry = *on
701fAC                   endif

701fA*
701fA*     See if we should call SETEND to just print merge labels.
701fA*
701fAC                   if        $pgen = 1
701fAC                             and svldry = *on
701fAC                             and temp1a = 'D'
701fAC                   eval      cldmrg = '*MRGONLY'
701fAC                   exsr      setend
701fAC                   eval      cldmrg = '*SKIPMRG'
701fAC                   eval      svldry = *off
701fAC                   eval      skpdry = *on
701fAC                   goto      beglup
701fAC                   endif
701fAC                   endsl
740dA*
740dA*     Check for Expired Items.
740dA*
740dAC                   exsr      zzgets2
740dAC                   if        wkpick = 'Y'
740dAC                             and wkexpd > *zeros
740dAC                             and wkexpd < Today
740dAC                   eval      printexpb = '1'
740dAC                   endif
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
650cA*     Label reprint
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
IFDgA*
IFDgA*       Skip these items.
IFDgA*
IFDgAC                   if        client = ifd
IFDgA*
IFDgAC                   exsr      getIFDPrtFlag
IFDhD ***                if        skipitem
IFDhD ***                iter
IFDhD ***                endif
IFDgAC                   endif
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
VIPnAC                             or client = vip
FSHfAC                             or client = FischerFoods
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
730hAC                   if        lbutyp <> svutyp
640kAC                   eval      svutyp = *blanks
730hAC                   endif
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
CSPo **   Next Item - Is this ITEM on PrePull Route?
CSPoAC                   eval      PreDup = 'N'
CSPoAC     keypred       chain     prexref6
CSPoAC                   if        %found(prexref6)
CSPoAC                   eval      PreDup = 'Y'
CSPoAC                   endif
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

PCKaAC                   when      client = pack730

PCKaA*  Get extended description
PCKaAC                   eval      t#desc = *blanks
PCKaAC     keyix         chain     itemdsc
PCKaAC                   if        %found(itemdsc)
PCKaAC                   eval      t#desc = ixdsc1 + ' ' + ixdsc2
PCKaAC                   endif

HMWc *
HMWc C                   other
HMWc *
HMWc C     keyim         chain     itemmsc                            79
HMWc C                   if        *in79=*on
HMWc C                   eval      imbrnd=*blanks
HMWc C                   endif
HMWc *
640sAC                   endsl
GFSnA*
GFSnA*    Get receive date from License active file for pick slot.
GFSnAC                   select
GFSnAC                   when      client = Getfresh
GFSnAC                   exsr      rcvdategfs
GFSnAC                   endsl
701hA*
701hA*     Get uom code
701hA*
701hAC                   eval      u_umcode = *blanks
701hAC     keyUOM        chain     unmesr1
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
730mA*
730mA*     Get label UM record
730mA*
730mAC                   exsr      getLABELUM
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
CDIgAC                             and (client <> CDI)

730mAC                             or umFlexPickFlag = 'P2W'

730mAC                             or umFlexPickFlag = 'PAQ'

TPC AC                             or  client = TPC
TPChDC*                            and %subst(ohmisc:7:1) = 'Y'
TPChAC                             and %subst(hmmsc2:1:1) = 'Y'

CLDvMC                             or sscombo = 'Y'

520hAC                             or opptyp = 'B'
KFSeMC                             and client <> Kellys
KFSeA
KFSeAC                             or  opptyp = 'B'
KFSeAC                             and lbqpck >= opclvl
KFSeAC                             and client = Kellys

GFSaAC                             or client = getfresh
GFSaAC                             and gfsdm1_omcmbflg = 'Y'

CDIgAC                             or client = CDI
CDIgAC                             and lbqpck >= opclvl
CDIgAC                             and $ptruk <> 'EXPORT1IT'

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

IFDgAC                             or client = ifd
IFDgAC                             and (ifdcombo
IFDhAC                             or  ifdcomboQTY1)

520hAC                   if        opptyp = 'B'
520hAC                   eval      combo = *off
520hAC                   else
     C                   eval      combo = *on
520hAC                   endif
730mA
730mA /free
730mA
730mA    select;
730mA      when umFlexPickFlag = 'P2W';
730mA        combo = *on;
730mA        w1qty2 = lbswgt;
730mA        umshrt = lbualu1;
730mA      when umFlexPickFlag = 'PAQ';
730mA        combo = *on;
730mA    endsl;
730mA
730mA /end-free
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
740dA*
740dA*  Print expired item warning label
740dA*
740dAC                   if        printexpb = '1'
740dAC                   exsr      lblexpb
740dAC                   endif
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
730mA /free
730mA
730mA    if umFlexPickFlag = 'P2W';
730mA      w1pick = lbswgt;
730mA      umshrt = lbualu1;
730mA    endif;
730mA
730mA /end-free
500dAC                   eval      $gcmd = '*FIRST  '
500dAC                   eval      $gqypl = *zeros
CCPaAC                   if        client = capitolcity
CLDwAC                             or client = cityline
CWDwAC                             or client = cashwa
GFSkAC                             or client = getfresh
FRFaAC                             or client = frf
MJKhAC                             or client = mjkellner
RYLaAC                             or client = royal
SFPdAC                             or client = seashore
GRCdAC                             or client = greco
CCPaAC                   exsr      lblitmn
CCPaAC                   endif
640 MC                   if        client = Cityline
640 AC                             and ifcat  = 'CLAMS'
CLDk C                   exsr      lblitl
CLDk C                   endif

     C                   exsr      lblpck

FSHfAC                   if        client = FischerFoods
FSHfAC                             and $ccode = 'FRESHFROZN'
FSHfAC                   exsr      lblitmn
FSHfAC                   endif
     *
IFDdAC                   select
IFDdAC                   when      client = ifd
IFDdAC                             and lbaisl = 'X  '
IFDdAC                             or client = ifd
IFDdAC                             and lbaisl = ' X '
IFDdAC                             or client = ifd
IFDdAC                             and lbaisl = '  X'
IFDdAC                   exsr      lblpck
IFDdAC                   endsl
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
740dA*
740dA*  Print expired item warning label
740dA*
740dAC                   if        printexpb = '1'
740dAC                   exsr      lblexpb
740dAC                   endif
     *
     C                   eval      combo = *off
500dAC                   eval      $gcmd = '*FIRST  '
500dAC                   eval      $gqypl = *zeros
CCPaAC                   if        client = capitolcity
CLDwAC                             or client = cityline
CWDwAC                             or client = cashwa
GFSkAC                             or client = getfresh
FRFaAC                             or client = frf
MJKhAC                             or client = mjkellner
RYLaAC                             or client = royal
SFPdAC                             or client = seashore
GRCdAC                             or client = greco
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

FSHfAC                   if        client = FischerFoods
FSHfAC                             and $ccode = 'FRESHFROZN'
FSHfAC                   exsr      lblitmn
FSHfAC                   endif

500dAC                   eval      $gqypl = $gqypl - 1
500dAC                   if        $gqypl = 0
500dAC                   eval      $gcmd = '*NEXT   '
500dAC                   else
500dAC                   eval      $gcmd = *blanks
500dAC                   endif
     *
     C                   enddo
     *
IFDdAC                   select
IFDdAC                   when      client = ifd
IFDdAC                             and lbaisl = 'X  '
IFDdAC                             or client = ifd
IFDdAC                             and lbaisl = ' X '
IFDdAC                             or client = ifd
IFDdAC                             and lbaisl = '  X'
IFDdAC                   eval      combo = *off
IFDdAC                   eval      $gcmd = '*FIRST  '
IFDdAC                   eval      $gqypl = *zeros
IFDdAC     1             do        lbqpck        w1pick
IFDdA
IFDdAC                   exsr      lblpck
IFDdAC                   eval      $gqypl = $gqypl - 1
IFDdAC                   if        $gqypl = 0
IFDdAC                   eval      $gcmd = '*NEXT   '
IFDdAC                   else
IFDdAC                   eval      $gcmd = *blanks
IFDdAC                   endif
IFDdA*
IFDdAC                   enddo
IFDdAC                   endsl
     *
ctwaAC                   endsl
     *
     C                   endsl

DRYgAC                   if        client = dairyland
DRYnMC                             and $prtflag = 'C'
DRYgAC     1             do        lbqpck
DRYgAC                   eval      kyfmt = 'CRUISE  '
DRYgAC                   exsr      fillb1
DRYgAC                   enddo
DRYgAC                   endif

DRYnAC                   if        client = dairyland
DRYnAC                             and $prtflag = 'L'
DRYnAC                   eval      kyfmt = 'LOT     '
DRYnAC                   exsr      fillb1
DRYnAC                   endif
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
CL2dAC                   select
CL2dMC                   when      itcwgt = 'Y'
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

760cMC     1             do        lbls          CWTCount

BIRaAC                   select
BIRaAC                   when      client = birite
BIRaAC                   exsr      cwtent
BIRaAC                   exsr      lblcwt
BIRaAC                   eval      c#qpck = c#qpck - 5
PCKnAC                   when      client = pack730
PCKnA*     Bypass printing catchwgt labels.
BIRaAC                   other
     C                   exsr      lblcwt
BIRaAC                   endsl
     C                   enddo

CL2dAC                   when      client = cityline
CL2dAC                             and itcwgt = 'Y'
CL2dAC                             and opcwgt = 0
CL2dAC                             and ($pcmd = '*REPRINT'
CL2dAC                             or   $pcmd = '*RPRTZN'
CL2dAC                             or   $pcmd = '*RPRTLB'
CL2dAC                             or   $pcmd = '*PRTTRN')
CL2dAC     1             do        lbqpck
CL2dAC                   exsr      lblcwt
CL2dAC                   enddo

CL2dMC                   endsl
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
TPCeAC                   when      useDFPICKordB
TPCeAC                             and client = tpc
TPCeAC     keyl32        setll     label32x
730iMC                   when      useDFPICKordB
FSHdAC     keyl32        setll     label32d
CTWcAC                   when      client = citywholesale
CTWcAC     keyl32        setll     label32e
SFGdAC                   when      client = SGC
SFGdAC     keyl32        setll     label32g
PFCaAC***PFChD           when      client = prestofoods
PFCaAC*PFChkeyl32        setll     label32j
TPCcAC                   when      client = tpc
TPCcAC                             and lsszon = 'PROD'
TPCcAC     keyl32        setll     label32s
640sAC                   other
     C     keyl32        setll     label32c
640sAC                   endsl
     C                   dou       forevr <> forevr
640sAC                   select
TPCeAC                   when      useDFPICKordB
TPCeAC                             and client = tpc
TPCeAC     keyl32        reade     label32x                               78
730iMC                   when      useDFPICKordB
FSHdAC     keyl32        reade     label32d                               78
CTWcAC                   when      client = citywholesale
CTWcAC     keyl32        reade     label32e                               78
SFGdAC                   when      client = SGC
700aMC     keyl32        reade     label32g                               78
PFCaAC***PFChD           when      client = prestofoods
PFCaAC*PFChkeyl32        reade     label32j                               78
TPCcAC                   when      client = tpc
TPCcAC     keyl32        reade     label32s                               78
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
PCKoAC                   if        client = pack730
PCKoA*       Bypass printing XDB labels.
PCKoAC                   else
     C                   exsr      lblxdb
PCKoAC                   endif
     C                   endif
SFGk *
SFGk C     keyim         chain     itemmsc                            79
SFGk C                   if        *in79=*on
SFGk C                   eval      imbrnd=*blanks
SFGk C                   endif
     *
     *     See if we should print the "before" um warning.
     *
     C                   if        lbutyp <> 'N'  and
     C                             opuwrb = 'Y'
     C                   exsr      lblumb
     C                   endif
720eAC                   eval      ixdsc1 = *blanks
720eAC                   eval      ixdsc2 = *blanks
     C                   eval      itvit# = *blanks
     C     keyil         chain     piritem
     C                   if        %found(piritem)
720eAC     keyil         chain     itemdsc
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
701hA*
701hA*     Get uom code
701hA*
701hAC                   eval      u_umcode = *blanks
701hAC     keyUOM        chain     unmesr1
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
TPC AC                             or  client = TPC
TPChDC*                            and %subst(ohmisc:7:1) = 'Y'
TPChAC                             and %subst(hmmsc2:1:1) = 'Y'
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
MJKhAC                             or client = mjkellner
RYLaAC                             or client = royal
SFPdAC                             or client = seashore
GRCdAC                             or client = greco
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
MJKhAC                             or client = mjkellner
RYLaAC                             or client = royal
SFPdAC                             or client = seashore
GRCdAC                             or client = greco
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
     C                   if        lbutyp <> 'N'
     C                             and opuwra = 'Y'
SFGiAC                             or  opuwra = 'Y'
SFGiAC                             and imp_flg = *on
     C                   exsr      lbluma
     C                   endif
     *
     *     Print catch weight labels.
     *
CL2dAC                   select
CL2dMC                   when      itcwgt = 'Y'
CL2dMC                             and opcwgt <> 0

     C     lbqpck        div       opcwgt        lbls
     C                   mvr                     remain
     C                   if        remain <> 0
     C                   add       1             lbls
     C                   endif
BIRa C                   eval      c#qpck = lbqpck
760cMC     1             do        lbls          CWTCount

BIRaAC                   select
BIRaAC                   when      client = birite
BIRaAC                   exsr      cwtent
BIRaAC                   exsr      lblcwt
BIRaAC                   eval      c#qpck = c#qpck - 5
PCKnAC                   when      client = pack730
PCKnA*     Bypass printing catchwgt labels.
BIRaAC                   other
     C                   exsr      lblcwt
BIRaAC                   endsl

     C                   enddo

CL2dAC                   when      client = cityline
CL2dMC                             and itcwgt = 'Y'
CL2dAC                             and opcwgt = 0
CL2dAC                             and ($pcmd = '*REPRINT'
CL2dAC                             or   $pcmd = '*RPRTZN'
CL2dAC                             or   $pcmd = '*RPRTLB'
CL2dAC                             or   $pcmd = '*PRTTRN')
CL2dAC     1             do        lbqpck
CL2dAC                   exsr      lblcwt
CL2dAC                   enddo

CL2dMC                   endsl
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
720bD*
720bD*   Print pallet labels.
720bD*
720bD *                  if        client <> mjkellner
JORfAC                   if        client = Jordanos
720bD *                            and client <> ifd
720bD *                            and client <> wiffod
JORfAC                   exsr      lblpallet
JORfAC                   endif
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
CWD0A*
CWD0AC                   if        client = CashWa
CWD0A*      Don't clear save fld. Need Aisle Change lbl to print.
CWD0AC                   else
CWD0A*
PFCeAC                   eval      svaisl = *blanks
CWD0AC                   endif
CWD0A*
     C                   eval      first2 = *on
PFCeAC                   eval      first3 = *on
     C                   eval      kyltyp = 'M'
     *
640sAC                   select
TPCeAC                   when      useDFPICKordB
TPCeAC                             and client = tpc
TPCeAC     keyl32        setll     label32x
730iMC                   when      useDFPICKordB
FSHdAC     keyl32        setll     label32d
CTWcAC                   when      client = citywholesale
CTWcAC     keyl32        setll     label32e
SFGdAC                   when      client = SGC
SFGdAC     keyl32        setll     label32g
PFCaAC***PFChD           when      client = prestofoods
PFCaAC*PFChkeyl32        setll     label32j
640sMC                   other
     C     keyl32        setll     label32c
640sMC                   endsl
     C                   dou       forevr <> forevr
640sAC                   select
TPCeAC                   when      useDFPICKordB
TPCeAC                             and client = tpc
TPCeAC     keyl32        reade     label32x                               78
730iMC                   when      useDFPICKordB
FSHdMC     keyl32        reade     label32d                               78
CTWcAC                   when      client = citywholesale
CTWcAC     keyl32        reade     label32e                               78
SFGdAC                   when      client = SGC
700mMC     keyl32        reade     label32g                               78
PFCaAC***PFChD           when      client = prestofoods
PFCaAC*PFChkeyl32        reade     label32j                               78
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
CWDaA*
CWDaA*     Get order detail record
CWDaA*
CWDaAC                   exsr      getORDD
CWDgA*
CWDgA*     Get order detail miscellaneous
CWDgA*
CWDgAC                   exsr      getORDDM
700pA*
700pA*  Position to first unique piece number for label.
700pA*  Note: Must use corresponding lbl# to get actual
700pA*        pick label rcd.
700pAC     lbctr#        setll     ordp2
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
     *
     *       Move information into data structure fields.
     *
730lAC     keyil         chain     piritem
     C                   eval      dszitm = lbitem
640gAC                   if        totzon
640gAC                   eval      dszdsc = *blanks
640gAC     zonkey        chain     zoneh
640gAC                   if        %found(zoneh)
640gAC                   eval      dszdsc = zhdesc
640gAC                   endif
640gAC                   endif
     C                   eval      dszdsc = itdesc
     C                   eval      dszpcs = lbqpck
     C                   movel     ohcnam        dszcnm
700pA*
700pA*          Get unique piece number for label.
700pAC     lbctr#        reade     ordp2
700pAC                   if        %eof(ordp2)
700pAC                   eval      unqpiece# = 0
700pAC                   else
700pAC                   eval      unqpiece# = orpup#
700pAC                   endif
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
     C                   exsr      lblzpd
     C                   exsr      initzp
     C                   else
     C                   add       1             zpocur
     C                   endif
     C     zpocur        occur     zonpku
     *
     C                   enddo
     *
     *     Force printing of label.
     *
     C                   if        zpocur > 1
     C                   exsr      lblzpd
     C                   exsr      initzp
     C                   endif
     *
SFGmA*   Print PIR merge pick labels.
     *
SFGuD ***                if        client = sgc
SFGuD ***                if        $pgen = 1
SFGuD ***                exsr      lblmhd
SFGuD ***                exsr      lblzpm2
SFGuD ***                endif
SFGuD ***                endif
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
CLDeAC     cldmrg        cabeq     '*MRGONLY'    endse
CLDeAC     endmrg        tag
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
GMMbAC                             and client <> menumaker
CL2bAC                             and client <> cityline
642bAC                   exsr      lblsetsum
642bAC                   endif
     *
     *  Print pallet label
     *
MJKeAC                   if        client <> mjkellner
IFDfAC                             and client <> ifd
WIFaAC                             and client <> wiffod
CL2bAC                             and client <> cityline
JORfAC                             and client <> Jordanos
640mAC                   exsr      lblpallet
MJKfAC                   endif
     *
CL2bA*  Print pallet label
     *
CL2bAC                   if        client = cityline
CL2bAC                   exsr      lblpallet
CL2bAC                   endif
     *
CL2bA*   Print set summary label.
     *
CL2bAC                   if        client = cityline
CL2bAC                   exsr      lblsetsum
CL2bAC                   endif
     *
CLDeAC     endse         tag
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
720fDC**                 eval      kytype = 'O'
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

750nA        chain (kyset: kyfmt) lblfmtd;
750nA        if %found(lblfmtd);
750fA        dtlcnt = savedtlcnt;
750jA        clear varFlag;
750nA        else;
750nA          dtlcnt = 999;
750jA          clear varFlag;
750nA          iter;
750nA        endif;
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
701bAC                   if        intflag = *on
701bAC                   exsr      filint
701bAC                   endif
701bA
701bA*          If next charcter is not a number,
701bA*            then assume it is a command and not a Dakota field.
701bA*            (Intermec uses commands like '<STX>' instead of a ^ or ~)
701bA
701bAC                   if        ip < maxsti
701bAC                             and (sti(ip+1) < '0' or sti(ip+1) > '9')
701bAC                   eval      intflag = *on
701bAC                   eval      intcmd = ''
701bAC                   else
     C                   eval      vflag = *on
701bAC                   endif
     C                   eval      @var = 0
     C                   eval      @len = 1
     *
     *       End of variable
     *
     C                   when      sti(ip) = '>'  and
701bMC                             (vflag = *on or intflag = *on)
701bDC**                           vflag = *on
     C                   add       1             @len
701bAC                   select
701bAC                   when      vflag = *on
     C                   exsr      fillb2
701bAC                   when      intflag = *on
701bAC                   exsr      filint
701bAC                   endsl
     C                   eval      vflag = *off
701bAC                   eval      intflag = *off
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
701bA*
701bA*       Within variable (Intermec)
701bA*
701bAC                   when      intflag = *on
701bAC                   eval      intcmd = %trimr(intcmd) + sti(ip)
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
     C     fillb2        begsr
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
SFPgAC                   when      client = seashore
SFPhAC                   select
SFPhMC                   when      hmmsc5 = 'Critical Care '
SFPhAC                             or hmmsc5 = 'VIP'
SFPgAC                   movea(p)  sfpspec       a50
SFPhAC                   when      hmmsc5 = 'Special'
SFPhAC                   movea(p)  sfpXS         a50
SFPhAC                   when      hmmsc5 = 'New Customer'
SFPhAC                   movea(p)  sfpNC         a50
SFPhMC                   other
SFPgAC                   movea     *blanks       a50
SFPhMC                   endsl

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
ISYjAC                             or client = isupply
YHAlAC                             or client = yhata
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
ISYjAC                             or client = isupply
YHAlAC                             or client = yhata
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
CTWyAC                   endsl
     C                   endif
     C                   eval      $nadec = 0
     C                   exsr      filnum
     *
     C                   when      @var = 11
510bAC                   eval      zffnam = 'SLOT'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else

SVLiAC                   select
SVLiAC                   when      client = saval
SWTcAC                             or client = swt
HPCbAc                             or client = HoltPaper
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
SFGtAC                   eval      dash = *blanks
SFGtAC                   eval      dash = %subst(lbdisp:3:1)
SFGtAC                   if        dash = '-'
SFGtAC                   movea(p)  lbdisp        a50
SFGtAC                   else
SFGpAC                   movea(p)  didisp        a50
SFGtAC                   endif
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

SFGpAC                   other
     C                   movea(p)  lbdisp        a50
SFGpAC                   endsl

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
CLDb ***        LBUCOD    ANDEQ'EA'
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
GMMfAC                             or client = menumaker
FPReAC                             or client = FoodPro
JORcA*
JORcA*      Normal item, picked Eaches. Convert item pack to 1.
JORgMC                   if        (ittype = ' '
JORgAC                             or ittype = 'A')
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
ISYaAC**ISYkD            movea     *blanks       a50
ISYkMC                   movea(p)  itdesc        a50
ISYaAC                   endif
CWDzA*
CWDzAC                   when      client = cashwa
CWDzAC                   eval      @len = 20
CWDzAC                   movea(p)  itdesc        a50
CSPmA*
CSPmA *   Center if Coastal's Amazon Label
CSPnA *                    or LSG customers
GFSoA *   Center if Get Fresh LSG customers
CSPmA *
CSPmAC                   when      client = coastalsunbelt and
CSPnMC                             (kyfmt = 'PICKAMZ ' or
CSPnMC                             kyfmt = 'PICKLSG ')
GFSoAC                             or client = getfresh and
GFSoAC                             kyfmt = 'PICKLSG '
CSPmA **                 **        and kyfmt = 'PICKAMZ '
CSPmAC                   eval      $pstr = itdesc
CSPmAC                   call      'CENTER'
CSPmAC                   parm                    $pstr
CSPmAC                   parm      30            $plen
CSPmAC                   movel     $pstr         itdesc
CSPmA* now move centered value
CSPmAc                   movea(p)  itdesc        a50

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

VFIgAC                   select
VFIgAC                   when      client = vitco
VFIgAC                   eval      temp7a = %char(ohcord)

VFIgAC                   select
VFIgAC                   when      ohcord >= 100000
VFIgAC                             and ohcord <= 199999
VFIgAC                   eval      temp7a = %replace('A':temp7a:1:1)

VFIgAC                   when      ohcord >= 200000
VFIgAC                             and ohcord <= 299999
VFIgAC                   eval      temp7a = %replace('B':temp7a:1:1)

VFIgAC                   when      ohcord >= 300000
VFIgAC                             and ohcord <= 399999
VFIgAC                   eval      temp7a = %replace('C':temp7a:1:1)

VFIgAC                   when      ohcord >= 400000
VFIgAC                             and ohcord <= 499999
VFIgAC                   eval      temp7a = %replace('D':temp7a:1:1)

VFIgAC                   when      ohcord >= 500000
VFIgAC                             and ohcord <= 599999
VFIgAC                   eval      temp7a = %replace('E':temp7a:1:1)

VFIgAC                   when      ohcord >= 600000
VFIgAC                             and ohcord <= 699999
VFIgAC                   eval      temp7a = %replace('F':temp7a:1:1)

VFIgAC                   when      ohcord >= 700000
VFIgAC                             and ohcord <= 799999
VFIgAC                   eval      temp7a = %replace('G':temp7a:1:1)

VFIgAC                   when      ohcord >= 800000
VFIgAC                             and ohcord <= 899999
VFIgAC                   eval      temp7a = %replace('H':temp7a:1:1)

VFIgAC                   when      ohcord >= 900000
VFIgAC                             and ohcord <= 999999
VFIgAC                   eval      temp7a = %replace('I':temp7a:1:1)

VFIgAC                   endsl

VFIgAC                   other

     C                   move      ohcord        $nanum
CWDtAC                   eval      temp7a = %char(ohcord)
VFIgAC                   endsl

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
     C                   exsr      filnum
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
FFCeAC                             or client = fischerfoods
ISPfMC                             or client = isupply
530gMC                   movea(p)  pkdate        a50
530gAC                   exsr      filchr

HALbAC                   when      client = halsey
HALbAC                   movea(p)  work8a        a50
HALbAC                   exsr      filchr
HALbA*
SFGbAC                   when      client = sgc
HMWhAC                             or client = hmwagner
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
SBRaAC                             or client = sbertram
PFCbAC                             or client = Prestofoods
DFFdAC                             or client = Dilgard
GFSeMC                   movea(p)  shipdate      a50
GFSeAC                   exsr      filchr

TPCdAC                   when      client = tpc
TPCdAC                   movea(p)  deliverydate  a50
TPCdAC                   exsr      filchr

ALNkAC                   when      client = cityline
CL2aAC                             and kyfmt <> 'REPL2'
ALNkAC                   eval      wkmm = dsmm
ALNkAC                   eval      wksl1 = '/'
ALNkAC                   eval      wkdd = dsdd
ALNkAC                   eval      wksl2 = '/'
ALNkAC                   eval      wkyy = dsyy
ALNKAC                   movea(p)  wksdte        a50
ALNKAC                   exsr      filchr

FPRcAC                   when      client = FoodPro
FPRcAC                   eval      $cvcmd = '*CMDMDY '
FPRcAC                   eval      $cvd8i = %editc(rtxhm2_hmdtei : 'X')
FPRcAC                   call      @cvtdt
FPRcAC                   parm                    $cvtdt
FPRcAC                   move      $cvd6o        zksdte
FPRcAC                   eval      wkmm = %editc(zkmm : 'X')
FPRcAC                   eval      wksl1 = '/'
FPRcAC                   eval      wkdd = %editc(zkdd : 'X')
FPRcAC                   eval      wksl2 = '/'
FPRcAC                   eval      wkyy = %editc(zkyy : 'X')
FPRcAC                   movea     *blanks       a50
FPRcAC                   movea(p)  wksdte        a50
FPRcAC                   exsr      filchr

RYLkAC                   when      client = royal
RYLkAC                   movea(p)  work8a        a50
RYLkAC                   exsr      filchr

GRCfAC                   when      client = greco
GRCfAC                   movea(p)  work8a        a50
GRCfAC                   exsr      filchr

SFGbAC                   other
NCScMC                   movea(p)  pkdate        a50
NCScD ***                movea(p)  work8a        a50
ALNKAC                   exsr      filchr
VIPcA*
VIPcAC                   endsl
VIPcA*
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
700zD ***                movea(p)  ohtruk        a50
700zMC                   movea(p)  jthtruk       a50
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

CSPiAC                   select
CSPiAC                   when      client = coastl
CSPiAC                             and preflg = 'Y'
CSPiAC                             and kyfmt = 'PICK'
CSPiAC                   move      0             $nanum

CDIhAC                   when      client = cdi
CDIhAC                             and opptyp = 'S'
CDIhAC                             and kyfmt = 'PALLET  '
CDIhAC                   move      99            $nanum

CSPiAC                   other
     C                   move      @pal#         $nanum
CSPiAC                   endsl
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
650aAc                   parm                    $pDdrop           3
650aAc                   parm                    $pDextd          30
650aAc                   parm                    $pDsd             9
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

SWTdAC                   select
SWTdAC                   when      client = swt
SWTdAC                   eval      ix = %trimr(dszitm)
SWTdAC                   movea(p)  ix            a50
SWTdAC                   other
     C                   eval      ix = %trimr(dszitm) + ' ' + '-'
     C                   eval      ix = %trimr(ix) + ' ' + dszdsc
     C                   movea(p)  ix            a50
SWTdAC                   endsl

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
FBYbAC                   select
FBYbAC                   when      client = farmboy
FBYbAC                   movea(p)  *blanks       a50
HMWaAC                   when      hmwdm1_omsubsts = 'SUB'
HMWaAC                   movea(p)  subwrd        a50
HMWaAC                   other
     C                   movea(p)  outwrd        a50
HMWaAC                   endsl
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
650aAc                   parm                    $pDdrop
650aAc                   parm                    $pDextd
650aAc                   parm                    $pDsd
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
CSPsAC                   if        client = CoastalSunbelt
CSPsAC                   movea(p)  dsscno        a50
CSPsAC                   exsr      filchr
CSPsAC                   else
     C                   move      dsswgt        $nanum
     C                   eval      $nadec = 2
     C                   exsr      filnum
     C                   endif
CSPsAC                   endif
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
ALNfAC                   move      lblbl#        temp7a
740aA*   Strip off leading zeros
740aAC                   move      *blanks       column1           1 0
740aAC                   dow       forever = forever
740aAC                   eval      column1 = %scan('0':temp7a:1)
740aAC                   if        column1 = 1
740aAC                   eval      %subst(temp7a: column1:1) = ' '
740aAC                   eval      temp7a=%triml(temp7a)
740aAC                   else
740aAC                   leave
740aAC                   endif
740cAC                   enddo

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
650bA*
650bA*   Move last 2 chars of route id to beginning of pallet id.
710cAC                   move      *blanks       $cstr
650bAC                   movel     $prtID        $cstr
650bAC                   call      'ADJUST'
650bAC                   parm      '*RIGHT  '    $CCMD             8
650bAC                   parm                    $CSTR            30
650bAC                   move      $CSTR         TEMP2A            2
650bAC                   movel     TEMP2A        TEMP7A
     C                   movea(p)  temp7a        a50
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
700jA*   AMP check digit
700jA*    @VAR=64
700jAC                   when      @var = 64
700jAC                   eval      zffnam = 'AMP chkd'
700jAC                   if        $pcmd = '*TEST2  '
700jAC                   movel     lfvdta        $cstr
700jAC                   else
700jAC*
700jAC*  print PICK label with AMP slot instead of rte# and stop#
700jAC*      need chk dgt now from ampbox and need boxid to getit
700jAC*
700sA*   WATCH if AMPxRef has the dup lbitems with same CORD
      *
700jAC                   movea(p)  *blanks       a50
700vMC     keyAMPX1      chain     ampxref13
700sAC                   if        $pcmd <> '*AMPBOX '
700sDC                   eval      work3a = %char(axachkdgt)
700sAC                   endif
700jAC*
      /free
700sA    if $pcmd = '*AMPBOX ';
700jA      setll (lbwhse: axaboxid) ampbox;
700jA      reade (lbwhse: axaboxid) ampbox;
700jA      if not %eof(ampbox);
700jA        work3a = %char(abxchkdgt);
700jA      endif;
700sA    endif;
700jA /end-free
700jAC
700jAC                   movea(p)  work3a        a50
700jAC
700jAC                   endif
700jAC                   exsr      filchr
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
IFDgAC                             or client = ifd
GRCcAC                             or client = Greco

BIRcAC                   eval      $nanum = 0
BIRcAC                   eval      work2 = dsstp1
BIRcAC                   call      @getstop
BIRcAC                   parm      '*PLTSTP'     $lcmd
BIRcAC                   parm                    $pwhse
BIRcAC                   parm                    $prtid
BIRcAC                   parm      *zeros        $pordr
BIRcAC                   parm                    work2
BIRcAC                   parm                    $phstp
650aAc                   parm                    $pDdrop
650aAc                   parm                    $pDextd
650aAc                   parm                    $pDsd
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
IFDgAC                             or client = ifd
GRCcAC                             or client = Greco

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
650aAc                   parm                    $pDdrop
650aAc                   parm                    $pDextd
650aAc                   parm                    $pDsd
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
650aAc                   parm                    $pDdrop           3
650aAc                   parm                    $pDextd          30
650aAc                   parm                    $pDsd             9
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
650aAc                   parm                    $pDdrop           3
650aAc                   parm                    $pDextd          30
650aAc                   parm                    $pDsd             9
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
650aAc                   parm                    $pDdrop
650aAc                   parm                    $pDextd
650aAc                   parm                    $pDsd
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
     C                   movea(p)  pkdate        a50
     C                   exsr      filchr
     *
     C                   when      @var = 68
     C                   movea(p)  ohcpo         a50
     C                   exsr      filchr
     *
     C                   when      @var = 69
     C                   movea(p)  dscitm        a50
     C                   exsr      filchr

CPJaA*  Extended order#

     C                   when      @var = 70
     C                   if        ohaorda <> *blanks
     C                   movea(p)  ohaorda       a50
     C                   else
     C                   move      ohcord        $nanum
     C                   eval      temp7a = %char(ohcord)
     C                   movea(p)  temp7a        a50
     C                   endif
     C                   eval      $nadec = 0
     C                   exsr      filchr
CDIfA*
CDIfA*  Reprint
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
CSPmA*
CSPmAC                   when      client = coastalsunbelt

     *   Center Trailer

     C                   eval      $pstr = csphm1_trkid
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm      10            $plen
     C                   movel     $pstr         csphm1_trkid
     *
     C                   movea(p)  csphm1_trkid  a50
EIi A*
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

ADFeAC                   select
ADFeAC                   when      client = AandDFoods
ADFeAC                   movea(p)  ixdsc1        a50
ADFeAC                   other
FRFaAC                   movea(p)  newdsc1       a50
ADFeAC                   endsl

FRFaAC                   endif
FRFaAC                   exsr      filchr
     *
FRFaAC                   when      @var = 76
FRFaAC                   eval      zffnam = 'DESC'
FRFaAC                   if        $pcmd = '*TEST2  '
FRFaAC                   movea     lfvdta        a50
FRFaAC                   else

ADFeAC                   select
ADFeAC                   when      client = AandDFoods
ADFeAC                   movea(p)  ixdsc2        a50
ADFeAC                   other
FRFaAC                   movea(p)  newdsc2       a50
ADFeAC                   endsl

FRFaAC                   endif
FRFaAC                   exsr      filchr
     *  Organic Certifier
EOPbAc                   when      @var = 77
EOPbAc                   eval      zffnam = 'OrgCert'
EOPbAc                   if        $pcmd = '*TEST2  '
EOPbAc                   movel     lfvdta        a50
EOPbAc                   else
EOPbAc                   move      *blanks       a50
EOPbAc*
EOPbAc                   if        client = Earls
EOPcA ***                                   and kyfmt= 'PRODUCE'
EOPbAc     keyitext      chain     itemext1
EOPbAc                   if        %found(itemext1)
EOPbAc                   eval      work10 = %subst(ikmsc4:1:10)
EOPbAc                   movea     work10        a50
EOPbAc                   endif
EOPbAc                   endif
EOPbAc                   endif
EOPbAc                   exsr      filchr

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
PCKcA*
PCKcA*  Alpha for stop
PCKcA*     @VAR = 89
PCKcAC                   when      @var = 89
PCKcAC                   if        $pcmd = '*TEST2  '
PCKcAC                   movea     LFVDTA        a50
PCKcAC                   else
PCKcAC                   movea(p)  DSALPH        a50
PCKcAC                   endif
PCKcAC                   exsr      filchr
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
     C                   movea(p)  work8a        a50
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
      *  Order Seq #
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
TPCgA*
TPCgAC                   when      client = tpc
TPCgAC                   eval      ixdsc2 = %trim(ixdsc2)
TPCgAC                   eval      work15 = %subst(ixdsc2:1:15)
TPCgAC                   movea(p)  work15        a50
TPCgA*
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
     *  Catch weight counter
     *    @VAR = 99
     *
760cAC                   when      @var = 99
760cMC                   eval      $nanum = CWTCount
760cMC                   eval      $nadec = 0
760cMC                   exsr      filnum
NFC A*  UPC
     *    @VAR = 100
     *
SFC A*  Mfg Code - Custom SFC
740eA*  CORD extended length - 7.0 to 11 (currently at Cheney)
     *    @VAR = 101
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
PCKeAC                   select
PCKeAC                   when      client = PACK730
PCKeAC                   movea(p)  lbwhdp        a50
PCKeAC                   other
ALN AC                   movea(p)  $pcomp        a50
PCKeAC                   endsl
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
CSPiAC                   select
CSPiAC                   when      client = coastl
CSPiAC                             and preflg = 'Y'
CSPiAC                             and kyfmt = 'PICK'
CSPiAC                   movea(p)  'PP     '     a50
PCKdAC                   when      client = pack730
PCKdAC                             and @psect = 'A'
PCKdAC                   movea(p)  'TOP'         a50
PCKdAC                   when      client = pack730
PCKdAC                             and @psect = 'B'
PCKdAC                   movea(p)  'BACK'        a50
CSPiAC                   other
CLDdMC                   movea(p)  @psect        a50
CSPiAC                   endsl
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
760aMC                   eval      $nadec = 0
760aMC                   exsr      filnum
     C                   else
760aAC                   if        client = CDI
760aAC                   Select
760aAC                   when      ohcust > 200000
760aAC                             and ohcust < 299999
760aAC                   movea(p)  'POP'         a50
760aAC                   when      ohcust > 300000
760aAC                             and ohcust < 399999
760aAC                   movea(p)  'CHK'         a50
760aAC                   when      ohcust > 600000
760aAC                             and ohcust < 699999
760aAC                   movea(p)  'SUB'         a50
760aAC                   exsr      filchr
760aAC                   other
760aAC                   movea(p)  *blanks       a50
760aAC                   exsr      filchr
760aAC                   endsl
760aAC                   else
520eD ***                move      $ldoor        $nanum
520eMC                   z-add     $ldoor        $nanum
     C                   eval      $nadec = 0
     C                   exsr      filnum
760aAC                   endif
760aMC                   endif
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
cwdgAC                   z-add     ohcord        temp50
cwdgAC                   eval      temp5a = %char(temp50)
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

PANfA* Field to hold 17 characters for additional POD
PANfA* moved to 129barcd
PANfD ***                when      client = panos
PANfD ***                          or client = vitco
PANfD ***                eval      work8a = %char(xohcord)
PANfD ***                eval      work16 = work8a + %subst(lbitem:1:8)
PANfD ***                movea(p)  work16        a50

VFIdA*    Field to hold 10 characters for additional Target POD
VFIdA* moved to 455barcd
VFIdD *            *     when      client = vitco
VFIdD *            *     eval      work10 = target
VFIdD *            *     movea(p)  work10        a50

SVLbAC                   other

SVLbAC                   eval      zffnam = 'Stamp'
640cAC                   movea(p)  wkstmp        a50
640cAC     ' '           checkr    wkstmp        ln
640cAC                   if        ln > *zeros
640cAC                   eval      @len = ln
640cAC                   endif
     C                   endsl

640cAC                   exsr      filchr
PANfA*
PANfA*  Panos POD barcode
     *  cccccccciiiiiiii0
PANfA*    @VAR = 129
PANfAC                   when      @var = 129

PANfAC                   eval      zffnam = 'PANBcde'
PANfAC                   if        $pcmd = '*TEST2  '
PANfAC                   movea     lfvdta        a50
PANfAC                   else

PANfAC                   eval      work8a = %editc(xohcord:'X')
PANfAC                   eval      work17 = work8a + %subst(lbitem:1:8)
PANfAC                                      + '0'
PANfAC                   movea(p)  work17        a50
PANFAC                   endif
PANfAC                   exsr      filchr
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
DRYvAC                   when      @var = 138
DRYvAC                   eval      zffnam = 'STOP'
DRYvAC                   if        logzebra
DRYvAC                   if        dtlcnt <= palcnt
750fAC                             and fillb1pass = 1
DRYvAC                   write(e)  zsrec
DRYvAC                   endif
DRYvAC                   eval      zsparm = ' '
DRYvAC                   endif
DRYvAC                   add       1             dtlcnt
DRYvAC                   eval      zsline = dtlcnt
DRYvAC                   if        dtlcnt <= ssdcnt
DRYvAC     dtlcnt        occur     stpsum
DRYvAC                   movea(p)  dssrst        a50
DRYvAC                   endif
DRYvAC                   exsr      filchr
GFSnA*
GFSnA*  Received Date
GFSnA*    @VAR = 145
GFSnAC                   when      @var = 144
GFSnAC                   eval      zffnam = 'RCVD'
GFSnA*
GFSnAC                   select
GFSnAC                   when      client = getfresh
GFSnAC                   select
GFSnAC                   when          ohcust >= 3216
GFSnAC                             and ohcust <= 3238
GFSnAC                              or ohcust  = 3387
GFSnAC                              or ohcust  = 3449
GFSnAC                              or ohcust  = 3659
GFSnAC                              or ohcust  = 3812
GFSnAC                              or ohcust  = 5744
GFSnAC                              or ohcust >= 5774
GFSnAC                             and ohcust <= 5775
GFSnAC                              or ohcust  = 6387
GFSnAC                   movea(p)  rcvdate       a50
GFSnAC                   exsr      filchr
GFSnA*
GFSnAC                   endsl
GFSnA*
GFSnAC                   endsl
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
730aA*  Item specific instructions
730aA*    @VAR = 157
730aAC                   when      @var = 157
730aAC                   if        $pcmd = '*TEST2  '
730aAC                   movea     lfvdta        a50
730aAC                   else

EOPhAC                   select
EOPhAC                   when      client = earls
EOPhAC                   movea(p)  hmmsc3        a50
EOPhAC                   other
730aAC                   movea(p)  ommsc1        a50
EOPhAC                   endsl
730aAC                   endif
730aAC                   exsr      filchr
     *
CCPaA*  Customer specific instructions
CCPaA*    @VAR = 158
CCPaAC                   when      @var = 158
CCPaAC                   if        $pcmd = '*TEST2  '
CCPaAC                   movea     lfvdta        a50
CCPaAC                   else

RYLaAC                   select
CCPaAC                   when      client = capitolcity
CCPaAC                             or client = cityln
CCPaAC                   if        ccpchk = '*SP'
CCPaAC                   movea(p)  ccpspec       a50
CCPaAC                   endif
CCPcAC                   if        ccpchks = 'Y'
CCPcAC                   movea(p)  ccpsch        a50
CCPcAC                   endif

GFSmA*
GFSmAC                   when      client = getfresh
GFSmA*      Load customer critical care message.
GFSmAC                   if        gfsmsc_ohccar = 'Y'
GFSmAC                   movea(p)  gfsspec       a50
GFSmAC                   endif

EOPhAC                   when      client = earls
EOPhAC                   movea(p)  hmmsc4        a50

GRCdAC                   when      client = greco
GRCdAC                   movea(p)  ommsc2        a50

RYLaAC                   other
RYLaAC                   movea(p)  hmmsc5        a50

RYLaMC                   endsl
CCPaMC                   endif
GFSmA*
CCPaAC                   exsr      filchr
     *
CCPaA*  Item specific instructions
CCPaA*    @VAR = 159
CCPaAC                   when      @var = 159
CCPaAC                   if        $pcmd = '*TEST2  '
CCPaAC                   movea     lfvdta        a50
CCPaAC                   else

GRCdAC                   select
FSHfAC                   when      client = FischerFoods
FSHfAC                   movea(p)  FreshFroznTxt a50

GRCdAC                   when      client = greco
GRCdAC                   movea(p)  ommsc3        a50
GRCdAC                   other
CCPaAC                   movea(p)  ommsc5        a50
GRCdAC                   endsl

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
IFDcA*
IFDcA*    @VAR = 164
IFDcA*
IFDcA*  Underline stop 6.
IFDcA*
IFDcAC                   when      @var = 164
IFDcAC                   if        $pcmd = '*TEST2  '
IFDcAC                   movea     lfvdta        a50
IFDcAC                   else
IFDcAC                   select
IFDcAC                   when      lbstop = 6
IFDcAC                   movea     underline     a50
IFDcAC                   other
IFDcAC                   movea     *blanks       a50
IFDcAC                   endsl
IFDcAC                   endif
IFDcAC                   exsr      filchr
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

710aA* License number

710aAC                   when      @var = 173
710aAC                   eval      zffnam = 'License'
710aAC                   if        $pcmd = '*TEST2  '
710aAC                   movel     lfvdta        a50
710aAC                   else
710aAC                   move      *blanks       a50
710aAC                   movea     curlic#       a50
710aAC                   endif
710aAC     ' '           checkr    curlic#       ln
710aAC                   if        ln > *zeros
710aAC                   eval      @len = ln
710aAC                   endif
710aAC                   exsr      filchr
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
CSPiAC                   select
CSPiAC                   when      client = coastl
CSPiAC                             and preflg = 'Y'
CSPiAC                             and kyfmt = 'PICK'
530bMC                   movea(p)  '       '     a50

PFCjAC                   when      client = presto
PFCjAC                             and $PLSET = 'BLTPF2'
PFCjAC                             and (kyfmt = 'PICK'
PFCjAC                             or  kyfmt = 'PICK2')
PFCjAC                   eval      temp5a = %trim(extstop) + %trim(@psect)
PFCjAC                   movea(p)  temp5a        a50

CSPiAC                   other
530bMC                   movea(p)  extStop       a50
CSPiAC                   endsl
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
CWDeAC                   else
CWDeAC                   eval      @len = 10
CWDeAC                   eval      cwddm1_lblnbr = '0000000000'
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
DRYkA*
DRYkAC                   if        %subst(ohmisc:11:10) = ' '
DRYkAC                   eval      workcus = %trim(%editc(ohcust: '4'))
DRYkAC                                         + '  '
DRYkAC                                         + %trim(ohcnam)
DRYkAC                   else
DRYkA*
DRYeAC                   eval      workcus = %subst(ohmisc:11:10)
DRYeAC                                         + '  '
DRYeAC                                         + %trim(ohcnam)
DRYkAC                   endif
DRYkA*
DRYeAC                   movea(p)  workcus       a50
SBRaAC                   when      client = sbertram
SBRaAC                   eval      workcus = %editc(xohcust:'4')
SBRaAC                                         + '  '
SBRaAC                                         + %trim(xohcnam)
SBRaAC                   movea(p)  workcus       a50

WIFdAC                   when      client = wiffod
WIFdAC                   eval      workcus = %trim(wifmsc_ohcust)
WIFdAC                                         + '  '
WIFdAC                                         + %trim(xohcnam)
WIFdAC                   movea(p)  workcus       a50

PANbAC                   when      client = Panos
PANbAC                   eval      workcus = %trim(%subst(hmmsc1:1:10))
PANbAC                                         + '  '
PANbAC                                         + %trim(ohcnam)
PANbAC                   movea(p)  workcus       a50

ISYeMC                   when      client = isupply
ISYeMC                   eval      workcus = %char(ohcust)
ISYeMC                                         + '  '
ISYeMC                                         + %trim(ohcnam)
ISYeMC                   movea(p)  workcus       a50
GLPiAC
GLPiAC                   when      client = greenleaf
GLPiAC                   eval      workcus = %trim(ohcnam)
GLPiAC                   movea(p)  workcus       a50
GLPiAC
GRCaAC                   when      client = greco
GRCaAC                   eval      workcus = %trim(%subst(hmmsc1:1:6))
GRCaAC                                         + '  '
GRCaAC                                         + %trim(xohcnam)
GRCaAC                   movea(p)  workcus       a50
FBYcAC                   when      client = farmboy
FBYcAC                   eval      workcus = %trim(fbymsc_ohcust)
FBYcAC                                         + '  '
FBYcAC                                         + %trim(xohcnam)
FBYcAC                   movea(p)  workcus       a50

KHLaAC                   when      client = kohl
KHLaAC                   eval      workcus = %trim(khlmsc_ohcust)
KHLaAC                                         + '  '
KHLaAC                                         + %trim(xohcnam)
KHLaAC                   movea(p)  workcus       a50

EOPfAC                   when      client = Earls
EOPfAC                   exsr      getordhm
EOPfAC                   eval      workcus = %trim(%subst(hmmsc1:1:10))
EOPfAC                                         + '  '
EOPfAC                                         + %trim(xohcnam)
EOPfAC                   movea(p)  workcus       a50

730gAC                   when      client = swt
730gAC                   eval      workcus = %trim(work11a)
730gAC                                         + '  '
730gAC                                         + %trim(xohcnam)
730gAC                   movea(p)  workcus       a50

CPJcAC                   when      client = cpj
CPJcAC                   eval      workcus = %trim(ohacusta)
CPJcAC                                         + '  '
CPJcAC                                         + %trim(xohcnam)
CPJcAC                   movea(p)  workcus       a50

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
CSPuA*
CPSuAC                   select
PFCgAC                   when      client = prestofoods
PFCgAC                   eval      worklbl = target
PFCgAC                   movea(p)  worklbl       a50
CSPuA*
CSPuAC                   when      client = Coastalsunbelt
CSPuA*      Create custom off-truck delivery number.
CSPuAC                   eval      worklbl = %subst(%editc(ohcord:'X'):4:4) +
CSPuAC                                       %subst(%editc(lbseq:'X'):3:3)
CSPuAC                   if        combo = '1'
CSPuAC                   eval      worklbl = %trim(worklbl) + '030'
CSPuAC                   else
CSPuAC                   eval      worklbl = %trim(worklbl) +
CSPuAC                                       %subst(%editc(@qty1:'X'):3:3)
CSPuAC                   endif

SWTdAC                   when      client = swt
SWTdAC                             and  kyfmt = 'XTOTE '

SWTdAC                   move      unqpiece#     temp5a
SWTdAC                   eval      worklbl = $prtid + temp5a

CSPuAC                   other
CSPuA*
530dAC                   move      unqpiece#     temp5a
530eMC                   eval      worklbl = $prtid + temp5a
CSPuAC                   endsl
CSPuA*
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
730aA*  Item specific instructions
730aA*    @VAR = 190
730aAC                   when      @var = 190
730aAC                   if        $pcmd = '*TEST2  '
730aAC                   movea     lfvdta        a50
730aAC                   else
730aAC                   movea(p)  ommsc4        a50
730aAC                   endif
730aAC                   exsr      filchr
cotdA*
cotdA*  Extended Item Desription
cotdA*    @VAR = 199
cotdAC                   when      @var = 199

     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   select
SFPbA *
SFPbAC                   when      client = seashore
SFPbAC                             and %subst(ixdsc1:2:5) = 'SPLIT'
SFPbD *                  eval      desc22 = %subst(ixdsc1:9:32)
SFPbD *                  movea(p)  desc22        a50
SFPbD *                  eval      desc22 = *blanks

SFPeMC                   eval      desc33 = %subst(ixdsc1:8:33)
SFPeMC                   movea(p)  desc33        a50
SFPeMC                   eval      desc33 = *blanks

     C                   when      client = cotati
     C                   movea(p)  ixdsc1        a50
MRTd * Added if ommsc1 eq blanks due to a SUBBED item with NO rcd
MRTd *   in orddm, so let it hit 'other'
MRTdSC                   when      client = merit
MRTdAC                             and ommsc1 > *blanks
MRTdAC                   movea(p)  ommsc1        a50

CWDyAC                   when      client = cashwa
CWDyAC                   eval      zffnam = 'RteDs'
CWDyA *
CWDyA *   Center Route Description
CWDyA *
CWDyAC                   eval      $pstr = cwdhm1_RteDs
CWDyAC                   call      'CENTER'
CWDyAC                   parm                    $pstr
CWDyAC                   parm      40            $plen
CWDyAC                   movel     $pstr         cwdhm1_RteDs
CWDYA*
CWDyAC                   movea(p)  cwdhm1_RteDs  a50

     C                   other
     C                   movea(p)  ixdsc1        a50
     C                   endsl
     C                   endif

     C                   exsr      filchr
     *
700zA*  Truck Description
700zA*    @VAR = 200
700zAC                   when      @var = 200
700zAC                   eval      zffnam = 'Trk Desc'
700zAC                   if        $pcmd = '*TEST2  '
700zAC                   movea     lfvdta        a50
700zAC                   else
700zAC                   movea(p)  jthdesc       a50
700zAC                   endif
700zAC                   exsr      filchr
     *
701aA*  Allergen Code
701aA*    @VAR = 201
701aAC                   when      @var = 201
701aAC                   eval      zffnam = 'Allergen'
701aAC                   if        $pcmd = '*TEST2  '
701aAC                   movea     lfvdta        a50
701aAC                   else
701aAC                   if        $ccode = Allergen
701aAC                   movea(p)  'A'           a50
701aAC                   endif
701aAC                   endif
701aAC                   exsr      filchr
     *
710dA*  Truck Compartment Description
710dA*    @VAR = 202
710dAC                   when      @var = 202
710dAC                   eval      zffnam = 'Trk Comp'
710dAC                   if        $pcmd = '*TEST2  '
710dAC                   movea     lfvdta        a50
710dAC                   else
710dA*
710dA*  Get Truck Compartment Description
710dA*
710dAC                   exsr      getTRKCOMP
710dAC                   if        tpdesc <> *blanks
710dAC                   movea(p)  tpdesc        a50
710dAC                   endif
710dAC                   endif
710dAC                   exsr      filchr
     *
WIFbA*  Wood pallet
WIFbA*    @VAR = 203
WIFbAC                   when      @var = 203
WIFbAC                   eval      zffnam = 'Wood Flag'
WIFbAC                   if        $pcmd = '*TEST2  '
WIFbAC                   movea     lfvdta        a50
WIFbAC                   else
WIFbAC                   select
WIFbAC                   when      woodflag
WIFbAC                   movea(p)  'WOOD'        a50
WIFbAC                   other
WIFbAC                   movea(p)  *blanks       a50
WIFbAC                   endsl
WIFbAC                   endif
WIFbAC                   exsr      filchr
     *
WIFbA*  Wood pallet
WIFbA*    @VAR = 204
WIFbAC                   when      @var = 204
WIFbAC                   eval      zffnam = 'Wood Flag2'
WIFbAC                   if        $pcmd = '*TEST2  '
WIFbAC                   movea     lfvdta        a50
WIFbAC                   else
WIFbAC                   select
WIFbAC                   when      woodflag
WIFbAC                   movea(p)  'W'           a50
WIFbAC                   other
WIFbAC                   movea(p)  *blanks       a50
WIFbAC                   endsl
WIFbAC                   endif
WIFbAC                   exsr      filchr
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
CSPtAC                   when      client = coastalsunbelt
CSPtAC                   movea(p)  dispatch      a50
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
IFDaAC                   when      client = ifd
     C                   eval      zffnam = 'KeyType'
     C                   movea(p)  keytype       a50
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
IFDaAC                   when      client = ifd
     C                   eval      zffnam = 'TypeCde'
     C                   movea(p)  typecode      a50
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

JPFcAC                   when      client = palmer
JPFcAC                   eval      zffnam = 'SubFlag'
JPFcAC                   if        jpfmsc_subflg <> 'Y'
JPFcAC                   movea(p)  '  $  '       a50
JPFcAC                   else
JPFcAC                   movea(p)  '     '       a50
JPFcAC                   endif

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
CPCbAC                   movea(p)  printcolor    a50
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
SBRbAC                             or client = SBertram
JSLaAC                             or client = jslvrt
PANdAC                             or client = Panos
DFFcAC                             or client = Dilgard
TPCfAC                             or client = tpc
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
JSLcAC                   when      kyfmt = 'PICK2 '
JSLcAC                             and client = JSilvert
JSLcAC                   eval      cwdqtyfld = %trim(%editc(@qty1:'4'))
JSLcAC                                         + ' of '
JSLcAC                                         + %trim(%editc(@qty2:'4'))

SFPbAC                   when      kyfmt = 'PICK2 '
SFPbAC                             and client = seashore
SFPbAC                             and %subst(itdesc:2:5) = 'SPLIT'
SFPbAC                   eval      cwdqtyfld =   %trim(%editc(@qty1:'4'))
SFPbAC                                         + ' of '
SFPbAC                                         + %trim(%editc(@qty2:'4'))
SFPbAC                                         + ' '
SFPbAC                                         + %trim('SPLIT')

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

FPRbAC                   when      client = FoodPro
FPRbAC                             and kyfmt = 'BULK  '
FPRbAC                             and u_umcode = 'CS'
FPRbAC                   eval      cwdqtyfld = 'BULK'
FPRbAC                                         + ' '
FPRbAC                                         + %trim(%editc(@qty2:'4'))

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

FPRbAC                   when      client = FoodPro
FPRbMC                             and kyfmt = 'PICK  '
FPRbMC                             and u_umcode = 'CS'
FPRbAC                   eval      cwdqtyfld = %trim(%editc(@qty1:'4'))
FPRbAC                                         + ' of '
FPRbAC                                         + %trim(%editc(@qty2:'4'))

RYLhAC                   when      client = royal
RYLhAC                   eval      cwdqtyfld = %trim(%editc(@qty1:'4'))
RYLhAC                                         + ' of '
RYLhAC                                         + %trim(%editc(@qty2:'4'))

HPCaAC                   when      client = holtpaper
HPCaAC                   eval      cwdqtyfld = %trim(%editc(@qty1:'4'))
HPCaAC                                         + ' of '
HPCaAC                                         + %trim(%editc(@qty2:'4'))

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

JPF AC                   when      client = palmer
JPF AC                   eval      zffnam = 'Phone#'
JPF AC                   movea(p)  @phone        a50
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
CSPmA*
CSPmA*  Generic 20-Char field - Amazon STD Item Number
CSPmA*    @VAR = 320
CSPmAC                   when      @var = 320
CSPmAC                   eval      zffnam = 'ITMNUM'
CSPmAC                   select
CSPmAC                   when      client = coastalsunbelt
CSPmAC                             and  kyfmt = 'PICKAMZ '
CSPmMC                   movea(p)  itmnum        a50
CSPmAC                   other
CSPmAC                   movea(p)  *blanks       a50
CSPmAC                   endsl
CSPmAC                   exsr      filchr
EOPdA*
EOPdA*  EOP Address Handler
EOPdA*    @VAR=321
EOPdAC                   when      @var = 321
     C                   eval      zffnam = 'Address'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        A50
     C                   else
     C                   movea     AddressHand2  a50
     C                   exsr      filchr
     C                   endif
     C                   movea(p)  *blanks       a50
CSPnA*
CSPnA*  Generic 25-Char field - LSG Customer Names
CSPnA*    @VAR = 325
CSPnAC                   when      @var = 325
CSPnAC                   eval      zffnam = 'LSGNUM'
CSPnAC                   select
CSPnAC                   when      client = coastalsunbelt
CSPnAC                             and  kyfmt = 'PICKLSG '
GFSoAC                             or client = getfresh
GFSoAC                             and  kyfmt = 'PICKLSG '
CSPnAC                   eval      lsgnum = '0' +
CSPnAC                                      %subst(temp7a:1:7) +
CSPnAC                                      %subst(oditem:1:6) +
CSPnAC                                      %subst(itpdsc:1:10)
CSPnAC                   movea(p)  lsgnum        a50
CSPnAC                   other
CSPnAC                   movea(p)  *blanks       a50
CSPnAC                   endsl
CSPnAC                   exsr      filchr
740dA*
740dA*  Generic 25-Char field - Expired Item Warning
740dA*    @VAR = 326
740dAC                   when      @var = 326
740dAC                   eval      zffnam = 'EXPITM'
740dAC                   movea(p)  expireditem   a50
740dAC                   exsr      filchr
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
EOPdA*
EOPdA*  EOP Address Handler
EOPdA*    @VAR=329
EOPdAC                   when      @var = 329
     C                   eval      zffnam = 'Address'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        A50
     C                   else
     C                   movea     AddressHand1  a50
     C                   exsr      filchr
     C                   endif
     C                   movea(p)  *blanks       a50
DRYfA*
DRYfA*  Method of Delivery @var330
DRYfA*
DRYfAC                   when      @var = 330
     C                   eval      zffnam = 'MOD   '
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
642mAC                   select
642mAC                   when      client = cdi
642mAC                   movea(p)  coinf1        a50
642mAC                   other
     C                   movea(p)  methodofdlvry a50
642mAC                   endsl
     C                   endif
     C                   exsr      filchr
     *
642mA*  Customer line2 export information
642mA*    @VAR = 331
642mAC                   when      @var = 331
     C                   eval      zffnam = 'Line 2'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  coinf2        a50
     C                   endif
     C                   exsr      filchr
     *
642mA*  Customer line3 export information
642mA*    @VAR = 332
642mAC                   when      @var = 332
     C                   eval      zffnam = 'Line 3'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  coinf3        a50
     C                   endif
     C                   exsr      filchr
     *
642mA*  Customer line4 export information
642mA*    @VAR = 333
642mAC                   when      @var = 333
     C                   eval      zffnam = 'Line 4'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  coinf4        a50
     C                   endif
     C                   exsr      filchr
JPF A*
JPF A*  Generic 30-Char field - Company Name
JPF A*    @VAR = 334
JPF AC                   when      @var = 334

642mAC                   select
642mAC                   when      client = cdi
642mAC                   eval      zffnam = 'Line 5'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  coinf5        a50
     C                   endif
642mAC                   other
JPF AC                   eval      zffnam = 'Company#'
JPF AC                   movea(p)  @company      a50
642mAC                   endsl
JPF AC                   exsr      filchr
     *
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
cpc  C                   select
ctwaAC                   when      client = citywho
ctwaAC                   movea(p)  retline1      a50
ctwaAC                   when      client = cpc
640bAC                   movea(p)  ixdsc1        a50
ctwaAC                   endsl
ctwaAC                   endif

ctwaAC                   select
ctwaAC                   when      client = citywho
ctwaAC                             and retailrows = w1pick
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
cpc  C                   select
ctwaAC                   when      client = citywho
ctwaAC                   movea(p)  retline2      a50
ctwaAC                   when      client = cpc
640bAC                   movea(p)  ixdsc2        a50
ctwaAC                   endsl
ctwaAC                   endif

ctwaAC                   select
ctwaAC                   when      client = citywho
ctwaAC                             and retailrows = w1pick
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
     C                   eval      voiceid4n = voiceid
     C                   eval      voiceid4a = %editc(voiceid4n:'X')
     C                   movea     voiceid4A     a50
     C                   exsr      filchr
     C                   endif
     C                   eval      voiceid4a = *blanks
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
     *
PFCkA*  Unique piece number
PFCkA*    @VAR = 378
PFCkAC                   when      @var = 378
PFCkAC                   if        $pcmd = '*TEST2  '
PFCkAC                   movea     lfvdta        a50
PFCkAC                   else
PFCkA*
PFCkAC                   select
PFCkAC                   when      client = prestofoods
PFCkAC                   eval      worklbl = target
PFCkAC                   movea(p)  worklbl       a50

CWDzAC                   when      client = cashwa
CWDzAC                   movea(p)  worklbl       a50
PFCkAC                   other

PFCkAC                   move      unqpiece#     temp5a
PFCkMC                   eval      worklbl = $prtid + temp5a
PFCkAC                   movea(p)  worklbl       a50
PFCkAC                   endsl
PFCkA*
PFCkAC                   endif
PFCkAC                   exsr      filchr
     *
CWDzA*  Unique piece number
CWDzA*    @VAR = 379
CWDzAC                   when      @var = 379

710bxC                   eval      zffnam = 'Stamp'
CWDzAC                   if        $pcmd = '*TEST2  '
CWDzAC                   movea     lfvdta        a50
CWDzAC                   else
CWDzAC                   movea(p)  wkstmp        a50
CWDzAC     ' '           checkr    wkstmp        ln
CWDzAC                   if        ln > *zeros
CWDzAC                   eval      @len = ln
CWDzAC                   endif
CWDzAC                   endif

CWDzAC                   exsr      filchr
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
ISYjAC                             or client = isupply
YHAlAC                             or client = yhata
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
ISYjAC                             or client = isupply
YHAlAC                             or client = yhata
640cAC                   eval      zffnam = 'Rte/Stop'
640cAC                   eval      temp9 = $prte + '/' + extstop
640cAC                   movea(p)  temp9         a50
640cAC                   endsl
640cAC                   exsr      filchr
WIFcA*
WIFcA*  Williams
WIFcA*    @VAR=411
WIFcAC                   when      @var = 411
     C                   eval      zffnam = 'Wood Pallet'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        A50
     C                   else

EOPeAC                   select
EOPeAC                   when      client = Earls
EOPeAC                   movea(p)  EOPGS1        a50

DRYvAC                   when      superroute
DRYvAC     keysor        setll     srord
DRYvAC                   dou       forevr <> forevr
DRYvAC     keysor        reade     srord
DRYvAC                   if        %eof(srord)
DRYvAC                             or sromordid = lbord
DRYvAC                   leave
DRYvAC                   endif
DRYvAC                   enddo
DRYvAC                   eval      work11a = $prte + '/' + sromrte
DRYvAC                   movea(p)  work11a       a50
EOPeAC                   other
DRYvD ***                movea(p)  woodpalletvar a50
DRYvAC                   eval      work11a = $prte
DRYvAC                   movea(p)  work11a       a50
EOPeAC                   endsl
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
750qA*
750qA*  Extended Item Desription
750qA*    @VAR = 453
750qAC                   when      @var = 453

     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  ommsc2        a50
     C                   endif

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
VFIdA*    Field to hold 10 characters for additional Target POD
VFIdA* moved from 125Barcd *** 455 used for PALLET label as well
VFIdAC                   if        client = vitco
VFIdAC                             and (kyfmt = 'PICK    '
VFIdAC                             or  kyfmt = 'PICK2   '
VFIdAC                             or  kyfmt = 'COMBO   '
VFIdAC                             or  kyfmt = 'BULK    ')
VFIdAC                   eval      work10 = target
VFIdAC                   movea(p)  work10        a50
VFIdAC                   else
     *
     *   Move route id to beginning of pallet id.
     *     var 461 cuts off 1st # of rtid if 0 and not needed
     C                   eval      temp10a = $prtid + temp5a
     C                   movea(p)  temp10a       a50
VFIdAC                   endif
     C                   exsr      filchr
700jA*   AMP Slot
700jA*    @VAR=456
700jAC                   when      @var = 456
700jAC                   eval      zffnam = 'AMP Slot'
700jAC                   if        $pcmd = '*TEST2  '
700jAC                   movel     lfvdta        $cstr
700jAC                   else
700jAC*
700jAC*  print PICK label with AMP slot instead of rte# and stop#
700jAC*
700jAC                   movea(p)  *blanks       a50
700vMC     keyAMPX1      chain     ampxref13
700vMC                   if        %found(ampxref13)
700jAC                   movea(p)  axadisp       a50
700jAC                   endif
700jAC*
700jAC                   endif
700jAC                   exsr      filchr
700nA*   AMP Box
700nA*    @VAR=457
700nAC                   when      @var = 457
700nAC                   eval      zffnam = 'AMP Box '
700nAC                   if        $pcmd = '*TEST2  '
700nAC                   movel     lfvdta        $cstr
700nAC                   else
      /free
700jA    setll (lbwhse: axaboxid) ampbox;
700jA    reade (lbwhse: axaboxid) ampbox;
700jA    if not %eof(ampbox);
700jA      AMPBox# = %editc(abxbox#: 'X');
700jA      else;
700jA      AMPBox# = '0';
700jA    endif;
700jA /end-free
700jAC                   movea(p)  AMPBox#       a50
700nAC*
700nAC                   endif
700nAC                   exsr      filchr
     *
CWDyA*  CWD current time  (share CERT, used for Cheney)
CWDyA*    @VAR = 458
CWDyAC                   when      @var = 458
CWDyAC                   select
CWDyAC                   when      client = cashwa
CWDyAC                   movea(p)  runtimea      a50
CWDyAC                   other
CWDyAC                   movea(p)  *blanks       a50
CWDyAC                   endsl
CWDyAC                   exsr      filchr
     *
710bA*   GS1 Barcode
710bA*    @VAR=459
710b  /free
710bA      when @var = 459;
710bA        zffnam = 'AMP Box ';
710bA        if $pcmd = '*TEST2  ';
710bA          $cstr = lfvdta;
710bA        else;
710bA          select;
710bA            when client = saval;
SVLnM /end-free
SVLnMC                   eval      work21 = %subst(%editc(ohcust:'X'):7:5)
SVLnMC                             + %subst(ititem:1:5) + mdy2
SVLnMC                             + %editc(orpup#:'X')
SVLnMC                   movea(p)  work21        a50
SVLnA /free
710bA          endsl;
710bA        endif;
710bA
710bA        exsr filchr;
710bA /end-free
750qA*
750qA*  Extended Item Desription
750qA*    @VAR = 460
750qAC                   when      @var = 460

     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  ommsc3        a50
     C                   endif

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
PCKaA*  Item extended description
PCKaA*    @VAR = 463
PCKaAC                   when      @var = 463
PCKaAC                   eval      zffnam = 'Extended dsc'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  t#desc        a50
     C                   endif
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
701bA*----------------------------------------------------------------
701bA*
701bA*  FILINT  Fill Intermec command code
701bA*
701bAC     filint        begsr
701bAC                   eval      intcmd = '<' + %trimr(intcmd) + '>'
701bAC                   select
701bAC                   when      intcmd = '<NUL>'
701bAC                   eval      newcmd = '@'
701bAC                   when      intcmd = '<SOH>'
701bAC                   eval      newcmd = 'A'
701bAC                   when      intcmd = '<STX>'
701bAC                   eval      newcmd = 'B'
701bAC                   when      intcmd = '<ETX>'
701bAC                   eval      newcmd = 'C'
701bAC                   when      intcmd = '<EOT>'
701bAC                   eval      newcmd = 'D'
701bAC                   when      intcmd = '<ENQ>'
701bAC                   eval      newcmd = 'E'
701bAC                   when      intcmd = '<ACK>'
701bAC                   eval      newcmd = 'F'
701bAC                   when      intcmd = '<BEL>'
701bAC                   eval      newcmd = 'G'
701bAC                   when      intcmd = '<BS>'
701bAC                   eval      newcmd = 'H'
701bAC                   when      intcmd = '<HT>'
701bAC                   eval      newcmd = 'I'
701bAC                   when      intcmd = '<LF>'
701bAC                   eval      newcmd = 'J'
701bAC                   when      intcmd = '<VT>'
701bAC                   eval      newcmd = 'K'
701bAC                   when      intcmd = '<FF>'
701bAC                   eval      newcmd = 'L'
701bAC                   when      intcmd = '<CR>'
701bAC                   eval      newcmd = 'M'
701bAC                   when      intcmd = '<SO>'
701bAC                   eval      newcmd = 'N'
701bAC                   when      intcmd = '<SI>'
701bAC                   eval      newcmd = 'O'
701bAC                   when      intcmd = '<DLE>'
701bAC                   eval      newcmd = 'P'
701bAC                   when      intcmd = '<DC1>'
701bAC                   eval      newcmd = 'Q'
701bAC                   when      intcmd = '<DC2>'
701bAC                   eval      newcmd = 'R'
701bAC                   when      intcmd = '<DC3>'
701bAC                   eval      newcmd = 'S'
701bAC                   when      intcmd = '<DC4>'
701bAC                   eval      newcmd = 'T'
701bAC                   when      intcmd = '<NAK>'
701bAC                   eval      newcmd = 'U'
701bAC                   when      intcmd = '<SYN>'
701bAC                   eval      newcmd = 'V'
701bAC                   when      intcmd = '<ETB>'
701bAC                   eval      newcmd = 'W'
701bAC                   when      intcmd = '<CAN>'
701bAC                   eval      newcmd = 'X'
701bAC                   when      intcmd = '<EM>'
701bAC                   eval      newcmd = 'Y'
701bAC                   when      intcmd = '<SUB>'
701bAC                   eval      newcmd = 'Z'
701bAC                   when      intcmd = '<ESC>'
701bAC                   eval      newcmd = '['
701bAC                   when      intcmd = '<FS>'
701bAC                   eval      newcmd = '\'
701bAC                   when      intcmd = '<GS>'
701bAC                   eval      newcmd = ']'
701bAC                   when      intcmd = '<RS>'
701bAC                   eval      newcmd = ' '
701bAC                   when      intcmd = '<US>'
701bAC                   eval      newcmd = '_'
701bAC                   when      intcmd = '<SP>'
701bAC                   eval      newcmd = ' '
701bAC                   when      intcmd = '<DEL>'
701bAC                   eval      newcmd = '?'
701bAC                   endsl
701bAC                   if        newcmd <> ' '
701bAC                   add       1             op
701bAC                   eval      sto(op) = '^'
701bAC                   if        op = maxsto
701bAC                   exsr      print
701baC                   endif
701bAC                   add       1             op
701bAC                   eval      sto(op) = newcmd
701bAC                   if        op = maxsto
701bAC                   exsr      print
701baC                   endif
701bAC                   endif
701bAC                   endsr
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

JPFaAC                   select
JPFaAC                   when      client = palmer
JPFaAC                             and willcall
JPFaAC                   other
     C                   exsr      fillb1
JPFaMC                   endsl

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
730kAC                   eval      @rtid  = $prtid

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
JPFaAC                   when      client = palmer
JPFaAC                             and willcall
JPFaAC                   eval      kyfmt = *blanks

CSPpAC                   when      client = coastalsunbelt
CSPpAC                             and preflg = 'Y'
CSPpAC                   eval      kyfmt = 'BIGPALA '

CSPlAC                   when      client = coastalsunbelt
DRYrDC*                            or client = dairyland
700bAC                             or bigpallabel
CWDyAC                             or client = cashwa
CWDyAC                             and $pcomp = 'D'
CWDyAC                             or client = cashwa
CWDyAC                             and $pcomp = 'F'
CWDyAC                             or client = cashwa
CWDyAC                             and $pcomp = 'R'
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

     *
     *       ISY req to print 3 Pallet Labels with BIG print
     *                  everyone else continues to print PALLET
ISYiAC                   select
ISYiAC                   when      (client = isupply
HALcAC                             or client = halsey)
ISYiAC                             and $ptruk <> 'WILLCALL'
ISYiAC                   eval      kyfmt = 'PALLET1 '
ISYiAC                   exsr      fillb1
ISYiAC                   eval      kyfmt = 'PALLET2 '
ISYiAC                   exsr      fillb1
ISYiAC                   eval      kyfmt = 'PALLET3 '
ISYiAC                   exsr      fillb1

JSLeAC                   when      client = jslvrt
JSLeAC                             and $ptruk <> 'WILLCALL'
JSLeAC                   eval      kyfmt = 'PALLET1 '
JSLeAC                   exsr      fillb1
JSLeAC                   eval      kyfmt = 'PALLET2 '
JSLeAC                   exsr      fillb1

ISYiAC                   other

CWDyAC                   if        fdipass <> 2
CWDyAC                   exsr      getORDHM
     C                   exsr      fillb1
CWDyAC                   endif
     * Print Extra Label before PALLET if Single Pallet Process
SVLLA*==>moved per Gary, place before SETHED and PICK labels.
SVLlA *==>               if        client = saval and
SVLlA *==>                         snglpal = '*SP'
SVLlA *==>               eval      kyfmt = 'PALDROP '
SVLlA *==>               exsr      fillb1
SVLlA *==>               endif
SVLlA *==>               eval      snglpal = *blanks
     *==>
ISYiAC                   endsl
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

760bA*     Get dock door for the transaction.

760bAC                   eval      $lwhse = pswhse
760bAC                   eval      $lrtid = psrtid
760bAC                   eval      $ltrn# = pstrn#
760bAC                   eval      $lwhdp = *blanks
760bAC                   eval      $ldoor = 0
760bAC                   call      'DH900'
760bAC                   parm                    $lparm

     C                   eval      @pal# = pspal#
     C                   eval      @plid = psplid
     C                   eval      @rtid = psrtid
     C                   eval      dsstp1 = psstp1
     C                   eval      dsstp2 = psstp2

     *       ISY req to print 3 Pallet Labels with BIG print
     *                  everyone else continues to print PALLET
     *
ISYiAC                   select
ISYiAC                   when      (client = isupply
HALcAC                             or client = halsey)
ISYiAC                             and $ptruk <> 'WILLCALL'
ISYiAC                   eval      kyfmt = 'PALLET1 '
ISYiAC                   exsr      fillb1
ISYiAC                   eval      kyfmt = 'PALLET2 '
ISYiAC                   exsr      fillb1
ISYiAC                   eval      kyfmt = 'PALLET3 '
ISYiAC                   exsr      fillb1

JSLeAC                   when      client = jslvrt
JSLeAC                             and $ptruk <> 'WILLCALL'
JSLeAC                   eval      kyfmt = 'PALLET1 '
JSLeAC                   exsr      fillb1
JSLeAC                   eval      kyfmt = 'PALLET2 '
JSLeAC                   exsr      fillb1

ISYiAC                   other

     C                   if        bigpallabel
     C                   eval      kyfmt = 'BIGPAL  '
     * bigpal may be BIGPALA if PrePull for Coastal
CSPpAC                   if        client = coastalsunbelt
CSPpAC                             and preflg = 'Y'
CSPpAC                   eval      kyfmt = 'BIGPALA '
CSPpAC                   endif
     *
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

760bA*     Get dock door for the transaction.

760bAC                   eval      $lwhse = pswhse
760bAC                   eval      $lrtid = psrtid
760bAC                   eval      $ltrn# = pstrn#
760bAC                   eval      $lwhdp = *blanks
760bAC                   eval      $ldoor = 0
760bAC                   call      'DH900'
760bAC                   parm                    $lparm

     C                   eval      @pal# = pspal#
     C                   eval      @plid = psplid
     C                   eval      @rtid = psrtid
     C                   eval      dsstp1 = psstp1
     C                   eval      dsstp2 = psstp2

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

JSLeAC                   when      client = jslvrt
JSLeAC                             and $ptruk <> 'WILLCALL'
JSLeAC                   eval      kyfmt = 'PALLET1 '
JSLeAC                   exsr      fillb1
JSLeAC                   eval      kyfmt = 'PALLET2 '
JSLeAC                   exsr      fillb1

     C                   other

     C                   if        bigpallabel
     C                   eval      kyfmt = $plfmt
     * bigpal may be BIGPALA if PrePull for Coastal
CSPpAC                   if        client = coastalsunbelt
CSPpAC                             and preflg = 'Y'
CSPpAC                   eval      kyfmt = 'BIGPALA '
CSPpAC                   endif
     *
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

     C                   eval      @pal# = pspal#
     C                   eval      @plid = psplid
     C                   eval      @rtid = psrtid
     C                   eval      dsstp1 = psstp1
     C                   eval      dsstp2 = psstp2

760bA*     Get dock door for the transaction.

760bAC                   eval      $lwhse = pswhse
760bAC                   eval      $lrtid = psrtid
760bAC                   eval      $ltrn# = pstrn#
760bAC                   eval      $lwhdp = *blanks
760bAC                   eval      $ldoor = 0
760bAC                   call      'DH900'
760bAC                   parm                    $lparm

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

JSLeAC                   when      client = jslvrt
JSLeAC                             and $ptruk <> 'WILLCALL'
JSLeAC                   eval      kyfmt = 'PALLET1 '
JSLeAC                   exsr      fillb1
JSLeAC                   eval      kyfmt = 'PALLET2 '
JSLeAC                   exsr      fillb1

     C                   other

     C                   if        bigpallabel
     C                   eval      kyfmt = $plfmt
     * bigpal may be BIGPALA if PrePull for Coastal
CSPpAC                   if        client = coastalsunbelt
CSPpAC                             and preflg = 'Y'
CSPpAC                   eval      kyfmt = 'BIGPALA '
CSPpAC                   endif
     *
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
TPC A*
TPC A*  LBLNOL  No pick labels on product.
     *
TPC AC     lblnol        begsr
TPC AC                   eval      kyfmt = 'NOLABEL '
TPC AC                   exsr      fillb1
TPC AC                   endsr
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
     *  Print aisle change label.
     C                   if        svaisl = *blanks
     C                   eval      svaisl = lbaisl
     C                   endif
     *
     C                   if        lbaisl <> svaisl
     C                   exsr      lblasl
     C                   eval      svaisl = lbaisl
     C                   endif
640jA*
640jA*     See if we should print the "before" um warning.
640jA*
740bAC                   select

740bA*   found issue for all client to populate sav
740bAC                   when      lbutyp = 'N'
740bAC                   eval      svutyp = lbutyp

640jAC                   when      lbutyp <> 'N'
640kAC                             and lbutyp <> svutyp
640jAC                             and opuwrb = 'Y'
SFGiAC                             or  imp_flg = *on
SFGiAC                             and opuwrb = 'Y'
SFGiAC                             and lbutyp <> svutyp
CDIaAC                             or client = cdi
CDIaAC                             and $ccode = 'BRKDWN'
CDIaAC                             and lbutyp <> svutyp
640jAC                   exsr      lblumb
640kAC                   eval      svutyp = lbutyp
740bAC                   endsl
     *
     C                   eval      stpcnt = 0
     C                   exsr      getpal
ALNbD**                   Z-ADDPAL#      @PAL#
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
750pD **                 select
750pD **                 when      client = frf
750pD **                           or client = ellenbee
750pD **                           or client = hmwagner
750pD **                           or client = earls
750pD **                           or client = Dilgard
750pD **                           or client = greco
750pD **                           or client = swt
750pD **                           or client = presto
750pD **                 eval      @psect = %replace((%subst($sscid:1:1
750pD **                           )):@psect:1:1)
750pD **                 eval      @psect = %replace((%subst(lbdsp2:1:1
750pD **                           )):@psect:2:1)
750pD **                 other
500eAC                   eval      @psect = $sscid
750PA **                 endsl
500eAC                   else
500eAC                   eval      @psect = *blanks
500eAC                   endif
500eA*
500eA*    Item assigned to single pallet section.
500eAC                   else
750pD **                 select
750pD **                 when      client = frf
750pD **                           or client = ellenbee
750pD **                           or client = hmwagner
750pD **                           or client = earls
750pD **                           or client = Dilgard
750pD **                           or client = greco
750pD **                           or client = swt
750pD **                           or client = presto
750pD **                 eval      @psect = %replace((%subst(lbhnd2:1:1
750pD **                           )):@psect:1:1)
750pD **                 eval      @psect = %replace((%subst(lbdsp2:1:1
750pD **                           )):@psect:2:1)
750pD **                 other
CLDdAC                   eval      @psect = lbhnd2
750pD **                 endsl
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
750pD **                 select
750pD **                 when      client = frf
750pD **                           or client = ellenbee
750pD **                           or client = hmwagner
750pD **                           or client = earls
750pD **                           or client = Dilgard
750pD **                           or client = greco
750pD **                           or client = swt
750pD **                 eval      @psect = %replace((%subst($sscid:1:1
750pD **                           )):@psect:1:1)
750pD **                 eval      @psect = %replace((%subst(lbdsp2:1:1
750pD **                           )):@psect:2:1)
750pD **                 other
500eAC                   eval      @psect = $sscid
750pD **                 endsl
500eAC                   else
750pD **                 select
750pD **                 when      client = frf
750pD **                           or client = ellenbee
750pD **                           or client = hmwagner
750pD **                           or client = earls
750pD **                           or client = Dilgard
750pD **                           or client = greco
750pD **                           or client = swt
750pD **                 eval      @psect = %replace((%subst($ghnd2:1:1
750pD **                           )):@psect:1:1)
750pD **                 eval      @psect = %replace((%subst(lbdsp2:1:1
750pD **                           )):@psect:2:1)
750pD **                 other
500PAC                   eval      @psect = $ghnd2
750pD **                 endsl
500eAC                   endif
500eA*
500eAC                   eval      @pal# = $gtplt
500eA*
500eAC                   else
500dA*
ALNbAC                   eval      @pal# = $gtplt
750pD **                 select
750pD **                 when      client = frf
750pD **                           or client = ellenbee
750pD **                           or client = hmwagner
750pD **                           or client = earls
750pD **                           or client = Dilgard
750pD **                           or client = greco
750pD **                           or client = swt
750pD **                 eval      @psect = %replace((%subst($ghnd2:1:1
750pD **                           )):@psect:1:1)
750pD **                 eval      @psect = %replace((%subst(lbdsp2:1:1
750pD **                           )):@psect:2:1)
750pD **                 other
CLDdAC                   eval      @psect = $ghnd2
750pD **                 endsl
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
730mA*
730mA*  Put Flex Pick code into OUT field
730mA*
730mAC                   if        combo =*on
730mAC                             and umFlexPickFlag <> ''
730mAC                   eval      outwrd = umFlexPickFlag
730mAC                   endif
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
     C                   endif
     *
     *      Print Catchweight Labels between Pick Labels.
CL2dAC                   select
CL2dMC                   when      itcwgt = 'Y'
CL2dMC                             and opcwgt <> 0
CL2dMC                             and $pcmd = '*PRTLBL '
SFGeAC                   if        client <> SGC
BIRaAC                             and client <> birite
PCKnAC                             and client <> pack730
530eMC                   exsr      lblcwt
SFGeAC                   endif

CL2dAC                   when      client = cityline
CL2dMC                             and itcwgt = 'Y'
CL2dAC                             and opcwgt = 0
CL2dMC                             and $pcmd = '*PRTLBL '
CL2dAC                             and ($pcmd = '*REPRINT'
CL2dAC                             or   $pcmd = '*RPRTZN'
CL2dAC                             or   $pcmd = '*RPRTLB'
CL2dAC                             or   $pcmd = '*PRTTRN')
CL2dAC                   exsr      lblcwt

CL2dMC                   endsl
     *
SLBaAC                   select

700nAC                   when      $pcmd = '*AMPBOX'
700nAC                   eval      kyfmt = 'AMPBOX3 '

700jAC                   when      amphm4_ampfl = 'Y'
700jAC                   eval      kyfmt = 'PICKAMP '

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
SFGtAC                   eval      aisl1 = *blanks
VIPa C                   eval      lidisp = *blanks
VIPa C                   eval      lidisp = lbdisp
SFGtAC                   eval      aisl1 = %subst(lbaisl:1:1)
SFGtAC                   if        aisl1 = ' '
SFGtAC                   eval      dids1 = '-'
SFGtAC                   eval      dids2 = '-'
SFGa C                   eval      dinine = linine
VIPa C                   eval      diasle = liasle
VIPa C                   eval      diloc = liloc
VIPa C                   movel     lilvl         dilvl
SFGtAC                   endif
      * FRZ aisle has 3 characters FBB117 they want FBB-117
SFGtAC                   if        aisl1 > ' '
SFGtAC                   eval      didisp = %subst(lidisp:1:3) +
SFGtAC                             '-' + %subst(lidisp:4:3)
SFGtAC                   endif
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
     *
TPC A*        Under certain conditions, print "no pick labels on product"
TPC A*        warning.
     *
TPC AC                   when      client = TPC

TPChDC*                  if        %subst(ohmisc:7:1) = 'Y'
TPChAC                   if        %subst(hmmsc2:1:1) = 'Y'
TPC AC                             and combo = *on
TPC AC                   exsr      lblnol
TPC AC                   endif
TPC AC                   eval      kyfmt = 'PICK    '

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

DRYqAC                   when      client = dairyland
DRYqAC                             and (cliloc = DryCin
DRYqAC                             or cliloc = drybronx
DRYpAC                             or cliloc = dryhou
DRYpAC                             or cliloc = drysa
DRYpAC                             or cliloc = drydal
DRYpAC                             or cliloc = dryswd
DRYpAC                             or cliloc = drymiami
DRYwAC                             or cliloc = drysanfran)
DRYqAC                             and lbutyp <> 'N'
DRYqAC                   eval      kyfmt = 'PICK2QR '

DRYqAC                   when      client = dairyland
DRYqAC                             and (cliloc = DryCin
DRYqAC                             or cliloc = drybronx
DRYpAC                             or cliloc = dryhou
DRYpAC                             or cliloc = drysa
DRYpAC                             or cliloc = drydal
DRYpAC                             or cliloc = dryswd
DRYpAC                             or cliloc = drymiami
DRYwAC                             or cliloc = drysanfran)
DRYqAC                             and lbutyp = 'N'
DRYqAC                             and lbucod = 'PC'
DRYqAC                   eval      kyfmt = 'PICK2QR '

DRYqAC                   when      client = dairyland
DRYqAC                             and (cliloc = DryCin
DRYqAC                             or cliloc = drybronx
DRYpAC                             or cliloc = dryhou
DRYpAC                             or cliloc = drysa
DRYpAC                             or cliloc = drydal
DRYpAC                             or cliloc = dryswd
DRYpAC                             or cliloc = drymiami
DRYwAC                             or cliloc = drysanfran)
DRYqAC                   eval      kyfmt = 'PICKQR  '

DRYqAC                   when      client = dairyland
DRYqAC                             and cliloc = DryHanover
DRYqAC                   eval      kyfmt = 'PICK2D  '

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

SVLmAC                   when      client = saval
SVLmAC                             and $pszon = 'JITP'
SVLmAC                   eval      kyfmt = 'PIRPICK '

SVLjAC                   when      client = saval
SVLjAC                             and lbutyp <> 'N'
SVLjAC                   eval      kyfmt = 'PICK2   '

VFIbAC                   when      client = vitco
VFIbAC                             and lbutyp <> 'N'
VFIbA * VFIe  (not needed)      ** and (lbutyp <> 'N'
VFIeD * shouldn't be necesary    * or kyfmt = 'COMBO   '
VFIeD * at this point PICKorPICK2* or combo = *on)
VFIbAC                   eval      kyfmt = 'PICK2   '

CSPo * There are times a PrePull changes routes and they want
CSPo * the PICK label to be marked DUPLICATE to they don't
CSPo * pull the items again.  BUT allow PICK if they chose
CSPo * RePrint or if the UnPick and re ALLOC & Pick/Print
CSPoAC                   when      client = coastalsunbelt
CSPoAC                             and PreDup = 'Y'
CSPoAC                             and rhrte <> pxhrte
CSPoAC                   eval      kyfmt = 'PICKDUP '

SBRaAC                   when      client = sbrtrm
SBRaAC                             and lbutyp <> 'N'
SBRaAC                   eval      kyfmt = 'PICK2   '

JSLbAC                   when      client = jslvrt
JSLbAC                             and (lbutyp <> 'N'
JSLbAC                             or ittype = 'B'
JSLbAC                             or ittype = 'S')
JSLbAC                   eval      kyfmt = 'PICK2   '

PFCaAC                   when      client = prestofoods
PFCcD ***                          and lbutyp <> 'N'
PFCcD ***                          and lbucod <> 'CS'
PFCcMC                             and (lbucod = 'BD'
PFCcMC                             or lbucod = 'BO'
PFCcMC                             or lbucod = 'BX'
PFCcMC                             or lbucod = 'CA'
PFCcMC                             or lbucod = 'EA'
PFCcMC                             or lbucod = 'GA'
PFCcMC                             or lbucod = 'JA'
PFCcMC                             or lbucod = 'LB'
PFCcMC                             or lbucod = 'PC'
PFCcMC                             or lbucod = 'PK'
PFCfMC                             or lbucod = 'TU'
PFCcMC                             or lbucod = 'BA')
PFCaAC                   eval      kyfmt = 'PICK2   '

ISYhAC                   when      client = isupply
ISYhAC                             and lbutyp <> 'N'
ISYhAC                   eval      kyfmt = 'PICK2   '

CWDzAC                   when      client = cashwa
CWDzAC                   eval      kyfmt = 'PICK2D  '

FPRaAC                   when      client = foodpro
FPRaAC                             and u_umcode = 'CS'
FPRaAC                   eval      kyfmt = 'PICK    '

FPRaAC                   when      client = foodpro
FPRaAC                             and lbutyp <> 'N'
FPRaAC                   eval      kyfmt = 'PICK2   '

PANaAC                   when      client = Panos
PANaAC                             and (lbutyp <> 'N'
PANaAC                             or ittype = 'B'
PANaAC                             or ittype = 'S')
PANaAC                   eval      kyfmt = 'PICK2   '

IFDeAC                   when      client = ifd
IFDeAC                             and lbutyp <> 'N'
IFDeAC                   eval      kyfmt = 'PICK2   '

IFDeAC                   when      client = ifd
IFDeAC                             and ohcust = 83833
IFDeAC                   eval      kyfmt = 'PICK3   '

ADFaAC                   when      client = AandDFoods
ADFaAC                             and (lbutyp <> 'N'
ADFaAC                             or ittype = 'B'
ADFaAC                             or ittype = 'S')
ADFaAC                   eval      kyfmt = 'PICK2   '

ADFdD ***                when      client = AandDFoods
ADFdD ***                          and lbswgt >= 30
ADFdD ***                eval      kyfmt = 'PICKHVY '

GLPjAC                   when      client = Greenleaf
GLPjAC                             and lbswgt >= 30
GLPjAC                   eval      kyfmt = 'PICKHVY '

RYLjAC                   when      client = Royal
RYLjAC                             and (lbutyp <> 'N'
RYLjAC                             or ittype = 'B'
RYLjAC                             or ittype = 'S')
RYLjAC                   eval      kyfmt = 'PICK2   '

KFSdAC                   when      client = Kellys
KFSdAC                             and lbutyp <> 'N'
KFSdAC                   eval      kyfmt = 'PICK2   '

MQSaAC                   when      client = marques
MQSaAC                             and (lbutyp <> 'N'
MQSaAC                             or ittype = 'B'
MQSaAC                             or ittype = 'S')
MQSaAC                   eval      kyfmt = 'PICK2   '

GRCeAC                   when      client = greco
GRCeAC                             and (lbutyp <> 'N'
GRCeAC                             or ittype = 'B'
GRCeAC                             or ittype = 'S'
GRCeAC                             or lbucod = 'JU'
GRCeAC                             or lbucod = 'PC'
GRCeAC                             or lbucod = 'EA'
GRCeAC                             or lbucod = 'GA'
GRCeAC                             or lbucod = 'GL'
GRCeAC                             or lbucod = 'BG'
GRCeAC                             or lbucod = 'JR')
GRCeAC                   eval      kyfmt = 'PICK2   '

COTaAC                   when      client = cotati
COTaAC                             and (lbutyp <> 'N'
COTaAC                             or ittype = 'B'
COTaAC                             or ittype = 'S')
COTaAC                   eval      kyfmt = 'PICK2   '

FBYaAC                   when      client = farmboy
FBYaAC                             and (lbutyp <> 'N'
FBYaAC                             or ittype = 'B'
FBYaAC                             or ittype = 'S')
FBYaAC                   eval      kyfmt = 'PICK2   '

MRTbAC                   when      client = merit
MRTbAC                             and (lbutyp <> 'N'
MRTbAC                             or ittype = 'B'
MRTbAC                             or ittype = 'S')
MRTbAC                   eval      kyfmt = 'PICK2   '

SFPaAC                   when      client = seashore
SFPaAC                             and (lbutyp <> 'N'
SFPaAC                             or ittype = 'B'
SFPaAC                             or ittype = 'S')
SFPaAC                   eval      kyfmt = 'PICK2   '

SFPbAC                   when      client = seashore
SFPbAC                             and %subst(itdesc:2:5) = 'SPLIT'
SFPbAC                   eval      kyfmt = 'PICK2   '

SWTeAC                   when      client = SWT
SWTeAC                             and (lbutyp <> 'N'
SWTeAC                             or ittype = 'B'
SWTeAC                             or ittype = 'S'
SWTeAC                             or lbucod = 'EA'
SWTfAC                             or lbucod = 'IP'
SWTfAC                             or lbucod = 'PK'
SWTfAC                             or lbucod = 'BG'
SWTfAC                             or lbucod = 'BX'
SWTfAC                             or lbucod = 'RL')
SWTeAC                   eval      kyfmt = 'PICK2   '

642mAC                   when      client = cdi
642mMC                   eval      kyfmt = @PICK

CPJbAC                   when      client = cpj
CPJbAC                             and (lbutyp <> 'N'
CPJbAC                             or ittype = 'B'
CPJbAC                             or ittype = 'S')
CPJbAC                   eval      kyfmt = 'PICK2   '

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

IFDgAC                   when      client = ifd
IFDgAC                             and (ifdcombo
IFDhAC                             or  ifdcomboQTY1)
IFDgAC                   exsr      lblcombo
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
      * Coastal req to print an Amazon label after every PICK label (AMA01)
CSPmAC                   if        client = coastalsunbelt
CSPmAC                             and %subst(ohmisc:11:6) = 'AMA01 '
CSPmAC                   eval      kyfmt = 'PICKAMZ '
CSPmAC                   exsr      fillb1
CSPmAC                   endif

      * Coastal req to print an LSG label after every PICK label (LSGxxxx)
GFSo  *         Get Fresh, LSG label after every PICK label if LSG in Cust Name
GFSoAC                   if        client = getfresh
GFSoAC                             and %subst(ohcnam:1:3) = 'LSG'
CSPnAC                             or client = coastalsunbelt
CSPrMC                             and (%subst(ohmisc:11:6) = 'LSG04 '
CSPrAC                               or %subst(ohmisc:11:6) = 'LSG01 ')
CSPnA *  PROD when ready       **  and %subst(ohmisc:11:3) = 'LSG'
CSPnAC                   eval      kyfmt = 'PICKLSG '
CSPnAC                   exsr      fillb1
CSPnAC                   endif

     C                   eval      combo = *off
     C                   endsr
NCSdA*----------------------------------------------------------------
NCSdA*
NCSdA*  LBLCOMBO  Print combo label for client
NCSdA*
NCSdAC     lblcombo      begsr

IFDhAC                   select
IFDhAC                   when      client = ifd
IFDhAC                             and ifdcomboQTY1 = '1'
IFDhAC                   eval      savopclvl = opclvl
IFDhAC                   eval      opclvl = 1

IFDhMC                   when      client = ifd
IFDhAC                             and ifdcombo = '1'
IFDhAC                   eval      savopclvl = opclvl
IFDgAC                   eval      opclvl = 60
IFDhMC                   endsl

NCSfAC                   if        opclvl = 0
NCSfAC                   eval      cmb1 = 0
NCSfAC                   eval      cmb2 = lbqpck
NCSfAC                   else

     C     lbqpck        div       opclvl        cmb1
     C                   mvr                     cmb2

     *  Print the X of X combo labels

IFDgAC                   select
IFDiAC                   when      client = ifd
IFDiAC                             and ifdcomboQTY1 = '1'
IFDjMC                             and (lbitem = '57106'
IFDjMC                             or  lbitem = '101883')
IFDiAC                   eval      @qty1 = opclvl
IFDiAC                   eval      @qty2 = lbqpck
IFDiAC                   exsr      fillb1
IFDiAC                   eval      cmb2 = 0

IFDhAC                   when      client = ifd
IFDhAC                             and ifdcomboQTY1 = '1'
IFDhAC                   eval      @qty1 = opclvl
IFDhAC                   eval      @qty2 = 1
IFDhAC                   exsr      fillb1
IFDhAC                   eval      cmb2 = 0

IFDgAC                   when      client = ifd
     C                   for       lblcnt = 1 to cmb1
     C                   eval      @qty1 = opclvl
     C                   eval      @qty2 = lbqpck
     C                   exsr      fillb1
     C                   endfor
IFDgAC                   other

     C                   for       lblcnt = 1 to cmb1
     C                   eval      @qty1 = opclvl
     C                   eval      @qty2 = opclvl
     C                   exsr      fillb1
     C                   endfor

IFDgAC                   endsl

NCSfAC                   endif

     *  Print the X of Y remaining labels

     C                   if        cmb2 <> 0

IFDgAC                   select
IFDgAC                   when      client = ifd
IFDgAC                   eval      @qty1 = cmb2
IFDgAC                   eval      @qty2 = lbqpck
IFDgAC                   exsr      fillb1
IFDgAC                   other

     C                   eval      combo = *off
     C                   for       lblcnt = 1 to cmb2
     C                   eval      @qty1 = lblcnt
     C                   eval      @qty2 = cmb2
     C                   exsr      fillb1
     C                   endfor

IFDgAC                   endsl

     C                   endif

IFDhAC                   if        client = ifd
IFDhAC                             and (ifdcombo = '1'
IFDhAC                             or   ifdcomboQTY1 = '1')
IFDhAC                   eval      opclvl = savopclvl
IFDhAC                   endif

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
640dA*
640dA*       For pass 1 only use labels that have a PLTSUM 'O' record.
640dA*       For pass 2 only use labels that have a PLTSUM 'L' record.
640dA*
720fDC**                 if        fdiPass = 1 and PSTYPE <> 'O'
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

DRYvA*    Find child order number

DRYvAC     keysor        setll     srord
DRYvAC                   dou       forevr <> forevr
DRYvAC     keysor        reade     srord
DRYvAC                   if        %eof(srord)
DRYvAC                             or sromordid = lbord
DRYvAC                   eval      dssrst = sromrte + '/' + %char(extstop)
DRYvAC                   leave
DRYvAC                   endif
DRYvAC                   enddo
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

DRYvA*    Find child order number

DRYvAC     keysor        setll     srord
DRYvAC                   dou       forevr <> forevr
DRYvAC     keysor        reade     srord
DRYvAC                   if        %eof(srord)
DRYvAC                             or sromordid = lbord
DRYvAC                   eval      dssrst = sromrte + '/' + %char(extstop)
DRYvAC                   leave
DRYvAC                   endif
DRYvAC                   enddo
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

DRYvA*    Find child order number

DRYvAC     keysor        setll     srord
DRYvAC                   dou       forevr <> forevr
DRYvAC     keysor        reade     srord
DRYvAC                   if        %eof(srord)
DRYvAC                             or sromordid = lbord
DRYvAC                   eval      dssrst = sromrte + '/' + %char(extstop)
DRYvAC                   leave
DRYvAC                   endif
DRYvAC                   enddo

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

DRYvA*    Find child order number

DRYvAC     keysor        setll     srord
DRYvAC                   dou       forevr <> forevr
DRYvAC     keysor        reade     srord
DRYvAC                   if        %eof(srord)
DRYvAC                             or sromordid = lbord
DRYvAC                   eval      dssrst = sromrte + '/' + %char(extstop)
DRYvAC                   leave
DRYvAC                   endif
DRYvAC                   enddo

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
CSPsA
CSPsAC                   eval      dsscno = %subst(ohmisc:11:6)
CSPsA
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
PFCeAC                             or client = PrestoFoods
WIFeAC                             or client = wiffod
SOFaAC                             or client = SofoFoods
HPCcAC                             or client = Holtpaper
SFGnAC                   if        first3 = *on
SFGnA* Print merge header label
SFGnAC                   exsr      lblmhd
PFCeAC                   eval      first3 = *off
SFGnAC                   endif
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
CL2dAC                   select
CL2dMC                   when      itcwgt = 'Y'
CL2dMC                             and opcwgt <> 0
     C     lbqpck        div       opcwgt        lbls
     C                   mvr                     remain
     C                   if        remain <> 0
     C                   add       1             lbls
     C                   endif
760cMC     1             do        lbls          CWTCount
PCKnAC                   if        client = pack730
PCKnA*     Bypass printing catchwgt labels.
PCKnAC                   else
     C                   exsr      lblcwt
PCKnAC                   endif
PCKnA*
     C                   enddo

CL2dAC                   when      client = cityline
CL2dMC                             and itcwgt = 'Y'
CL2dAC                             and opcwgt = 0
CL2dAC                             and ($pcmd = '*REPRINT'
CL2dAC                             or   $pcmd = '*RPRTZN'
CL2dAC                             or   $pcmd = '*RPRTLB'
CL2dAC                             or   $pcmd = '*PRTTRN')
CL2dAC     1             do        lbqpck
CL2dAC                   exsr      lblcwt
CL2dAC                   enddo

CL2dMC                   endsl
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

740cAC     keyim         chain     itemmsc
740cAC                   if        not %found(itemmsc)
740cAC                   eval      imbrnd=*blanks
740cAC                   endif
     *
     *     For Box Labels, print BOX instead of TOTE
     *
700tAC                   if        %subst(lbitem:1:4) = 'TOTE'
700tAC                   eval      lbitem = %replace('BOX ':lbitem)
700tAC                   endif
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
TPC AC                             or  client = TPC
TPChDC*                            and %subst(ohmisc:7:1) = 'Y'
TPChAC                             and %subst(hmmsc2:1:1) = 'Y'
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
MJKhAC                             or client = mjkellner
RYLaAC                             or client = royal
SFPdAC                             or client = seashore
GRCdAC                             or client = greco
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
MJKhAC                             or client = mjkellner
RYLaAC                             or client = royal
SFPdAC                             or client = seashore
GRCdAC                             or client = greco
CCPaAC                   exsr      lblitmn
CCPaAC                   endif
     C     1             do        lbqpck        w1pick
     C                   exsr      lblpck
700qA*
700qA*          Get unique piece number for next unit.
700qAC     lbctr#        reade     ordp2
700qAC                   if        %eof(ordp2)
700qAC                   eval      unqpiece# = 0
700qAC                   else
700qAC                   eval      unqpiece# = orpup#
700qAC                   endif
700qA*
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

WIFbMC                   if        client = wiffod
WIFbAC                   eval      woodflag = *off
WIFbAC     lbtrn#        setll     label7
WIFbAC                   dou       forevr <> forevr
WIFbAC     lbtrn#        reade     label7
WIFbAC                   if        %eof(label7)
WIFbAC                   leave
WIFbAC                   endif
WIFbAC                   if        %subst(bohmisc:16:1)='Y'
WIFbAC                   eval      woodflag = *on
WIFbAC                   leave
WIFbAC                   endif
WIFbAC                   enddo
WIFbAC                   endif

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
     * Print Extra Label before SETHED if Single Pallet Process
SVLlAC                   if        client = saval
SVLlAC     keyl94        setll     label94
SVLlAC                   dou       %eof(label94)
SVLlAC     keyl94        reade     label94
SVLlAC                   if        not %eof(label94)
SVLlAC                   exsr      getordh
SVLlAC                   if        snglpal = '*SP'
SVLlAC                   eval      @plid = lbpal#
SVLlAC                   eval      kyfmt = 'PALDROP'
SVLlAC                   exsr      fillb1
SVLlAC                   leave
SVLlAC                   endif
SVLlAC                   endif
SVLlAC                   enddo
SVLlAC                   endif
SVLlAC                   eval      snglpal = *blanks
     *
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
GMMbAC                             or client = menumaker
MJKgAC                   exsr      lblsetsum
MJKgAC                   endif
640mA*
     C                   if        $pgen = 1
     C                   eval      dtlcnt = 0
     C                   dow       dtlcnt < palcnt
CCPaD ***                eval      kyfmt = 'PALLET  '
     C                   add       1             dtlcnt
     C     dtlcnt        occur     palsum
     C                   eval      @pal# = dsppal
     *
CCPaMC                   if        client = capitolcity
CLDaMC                             or client = cityln
CWDwAC                             or client = cashwa
GFSmAC                             or client = Getfresh
MJKhA ****                         or client = mjkellner
RYLaAC                             or client = royal
EOPhAC                             or client = earls
SFPcAC                             or client = seashore
700hAc                   exsr      lblcustnotes
CCPaMC                   endif

     C                   eval      @plid = dsppli
     C                   eval      @rtid = dsprti
     C                   eval      @stp1 = dsstp1
     C                   eval      @stp2 = dsstp2

     C                   if        dsppal > 0  or
     C                             $pcmd = '*TEST2  '
MJKfMC                   if        client = mjkellner
IFDfMC                             or client = IFD
WIFaMC                             or client = wiffod
CCPaMC                   eval      kyfmt = 'PALLET  '

700kAC                   eval      voiceid = 0
700kAC                   call      @getpltvid
700kAC                   parm      '*VOICEID'    $command
700kAC                   parm                    @plid
700kAC                   parm                    $pwhse
700kAC                   parm                    $prtid
700kAC                   parm                    voiceid

MJKfMC                   exsr      fillb1
MJKfMC                   endif
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
SWTdAC     keyorp5       chain     ordp5
SWTdAC                   if        %found(ordp5)
SWTdAC                   eval      unqpiece# = korpup#
SWTdAC                   endif
SWTdA*
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

CWDzAC                   if        client = cashwa
640cAC                   eval      kyfmt = 'XTOTE2D '
CWDzAC                   else
CWDzAC                   eval      kyfmt = 'XTOTE   '
CWDzAC                   endif

640iAC                   when      totzon
640iAC                             and cigaretflag
640iAC                             and lasttote

CWDzAC                   if        client = cashwa
640cAC                   eval      kyfmt = 'XTOTE32D'
CWDzAC                   else
640iAC                   eval      kyfmt = 'XTOTE3  '
CWDzAC                   endif

SWT AC                   when      client = swt
SWT AC                             and totzon
SWT AC                   eval      kyfmt = 'XTOTE   '

640cAC                   other

CWDzAC                   if        client = cashwa
640cAC                   eval      kyfmt = 'XTOTE22D'
CWDzAC                   else
640cAC                   eval      kyfmt = 'XTOTE2  '
CWDzAC                   endif
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

RNZj *  Print blanks label

RNZj C                   if        client = renzi
RNZj C                   for       fillerPass = 1 to 1
RNZj C                   exsr      lblfiller
RNZj C                   endfor
RNZj C                   endif

     C                   eval      dtlcnt = 0
svlhAC                   select
DRYvAC                   when      superroute
DRYvAC                   eval      kyfmt = 'SETSUM2 '
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

JPFaAC                   select
JPFaAC                   when      client = palmer
JPFaAC                             and willcall
JPFaAC                   other
     C                   exsr      fillb1
JPFaAC                   endsl
     *
RYLcA*  Print 2nd SETSUM label for Royal.
RYLcAC                   if        client = royal
RYLcAC                   eval      dtlcnt = 0
RYLcAC                   eval      kyfmt = 'SETSUM  '
RYLcAC                   exsr      fillb1
RYLcAC                   endif
     *
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
740dA*----------------------------------------------------------------
740dA*
740dA*  LBLexpb Item expired warning label
740dA*
740dAC     lblexpb       begsr
     C                   eval      kyfmt = 'EXPB    '
     C                   exsr      fillb1
     C                   endsr
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

JPFaAC                   select
JPFaAC                   when      client = palmer
JPFaAC                             and willcall
JPFaAC                   other
     C                   exsr      fillb1
JPFaMC                   endsl

     C                   endsr
GRCdA*----------------------------------------------------------------
GRCdA*
GRCdA*  LBLSpecial  Special notes warning label.
GRCdA*
GRCdAC     lblspecial    begsr

GRCdAC                   eval      kyfmt = 'SPECIAL '
GRCdAC                   exsr      fillb1

GRCdAC                   endsr
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

GRCdA *                  select
GRCdA *                  when      client = greco
GRCdA *                            and (ommsc1 <> *blanks
GRCdA *                            or ommsc2 <> *blanks
GRCdA *                            or ommsc3 <> *blanks
GRCdA *                            or ommsc4 <> *blanks)
GRCdA *                  exsr      lblspecial
GRCdA *                  endsl

     C                   eval      itmnote1 = *blanks
     C                   eval      itmnote2 = *blanks
CCPaAC     kyodm         chain     orddm                              79
FRFaAC                   select
FRFaAC                   when      client = FischerFoods
FSHfAC                   eval      kyfmt = 'ITEMNOTE'
FSHfAC                   exsr      fillb1

FRFaAC                   when      %found(orddm)
FRFaAC                             and client = frf
FRFaAC                             and (ommsc4 <> *blanks
FRFaAC                             or ommsc5 <> *blanks)
FRFaAC                   eval      itmnote1 = %subst(ommsc4:1:18)
FRFaAC                   eval      itmnote2 = %subst(ommsc5:1:18)
FRFaA ***                eval      kyfmt = 'ITEMNOTE'
FRFaA ***                exsr      fillb1

GRCdAC                   when      %found(orddm)
GRCdAC                             and client = greco
GRCdAC                             and (ommsc1 <> *blanks
GRCdAC                             or ommsc2 <> *blanks
GRCdAC                             or ommsc3 <> *blanks
GRCdAC                             or ommsc4 <> *blanks)
GRCdAC                   eval      kyfmt = 'ITEMNOTE'
GRCdAC                   exsr      fillb1

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
     *  LBLCUSTNOTES - Print customer notes label
     *
700hAC     lblcustnotes  begsr

RYLaAC                   Select
RYLaAC                   when      client = royal
RYLaAC     kyohm         chain     ordhm
RYLaAC                   if        %found(ordhm)
RYLaAC                             and hmmsc5 <> *blanks
RYLaAC                   eval      kyfmt = 'CUSTNOTE'
RYLaAC                   exsr      fillb1
RYLaAC                   endif
RYLaAC                   other

CCPaMC     keyl94        setll     label94
CCPaMC                   dou       %eof(label94)
CCPaMC     keyl94        reade     label94
CCPaMC                   if        not %eof(label94)
CCPaMC                   exsr      getordh
730 AC                   select
730 MC                   when      ccpchk = '*SP'
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

CCPcMC                   if        ccpchks = 'Y'
CCPcMC                             and @pal# > 0
CCPcMC                   eval      ohcord = xohcord
CCPcMC                   eval      ohcust = xohcust
CCPcMC                   eval      ohcnam = xohcnam
CCPcMC                   eval      kyfmt = 'CUSTNOTE'
CCPcMC                   exsr      fillb1
CCPcMC                   endif

EOPhAC                   when      client = earls
EOPhAC     kyohm         chain     ordhm
EOPhAC                   if        %found(ordhm)
EOPhAC                             and (hmmsc3 <> *blanks
EOPhAC                             or   hmmsc4 <> *blanks
EOPhAC                             or   hmmsc5 <> *blanks)
750aAC                   eval      ohcord = xohcord
750aAC                   eval      ohcust = xohcust
750aAC                   eval      ohcnam = xohcnam
EOPhAC                   eval      kyfmt = 'CUSTNOTE'
EOPhAC                   exsr      fillb1
EOPhAC                   endif

730mAC                   other

SFPf *    Seashore needed lbord here for ordhm & hmmsc5
RYLaA **   kyohm         chain     ordhm
SFPfAC     keyodh        chain     ordhm
RYLaAC                   if        %found(ordhm)
SFPcAC                             and hmmsc5 <> *blanks
750aAC                   eval      ohcord = xohcord
750aAC                   eval      ohcust = xohcust
750aAC                   eval      ohcnam = xohcnam
SFPcAC                   eval      kyfmt = 'CUSTNOTE'
SFPcAC                   exsr      fillb1
SFPcAC                   endif
SFPcAC                   endsl

CCPaMC     keyl94a       setgt     label94
CCPaMC                   endif
CCPaMC                   enddo
SFPcAC                   endsl

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
CPCeA*  ZZGETS   Get slot information.
     *
     C     zzgets        begsr
     C                   eval      error = *off
     C                   eval      curlic# = *blanks
     *  Use DRI interface to get slot information.

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = lbwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = lbwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = lbdisp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GETCHKVX'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   exsr      zzzdricop
     C                   if        error = *on
     C                   goto      endgts
     C                   endif

     C                   eval      #fromToLcns = $saToLcns
     C                   eval      #fromOLcns = $saOLcns

     C                   eval      curlic# = #fromToLcns
     *
     C     endgts        endsr
     *
     *----------------------------------------------------------------
     *
740dA*  ZZGETS2  Get slot information.
     *
     C     zzgets2       begsr
     C                   eval      error = *off
     C                   eval      wkpick = *blanks
     C                   eval      wkexpd = *zeros
     C                   eval      printexpb = *off
     *  Use DRI interface to get slot information.

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = lbwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = lbwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = lbdisp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   exsr      zzzdricop
     C                   if        error = *on
     C                   goto      endgts2
     C                   endif

     C                   eval      wkpick = $slpick
     C                   eval      wkexpd = $slexpd
     *
     C     endgts2       endsr
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

IFDgA*----------------------------------------------------------------
IFDgA*  getIFDPrtFlag  Get Indianhead Item print flag.
IFDgA*----------------------------------------------------------------
IFDgAC     getIFDPrtFlag begsr

IFDhD ***                eval      skipitem = '0'
IFDhMC                   eval      ifdcomboQTY1 = '0'
IFDgaC                   eval      ifdcombo = '0'

IFDgAC                   if           lbitem = '12023'
IFDgAC                             or lbitem = '12024'
IFDgAC                             or lbitem = '12028'
IFDgAC                             or lbitem = '12529'
IFDgAC                             or lbitem = '12764'
IFDgAC                             or lbitem = '13117'
IFDgAC                             or lbitem = '13118'
IFDgAC                             or lbitem = '13169'
IFDgAC                             or lbitem = '13178'
IFDgAC                             or lbitem = '13366'
IFDgAC                             or lbitem = '13407'
IFDgAC                             or lbitem = '13409'
IFDgAC                             or lbitem = '13411'
IFDgAC                             or lbitem = '13412'
IFDgAC                             or lbitem = '13413'
IFDgAC                             or lbitem = '13414'
IFDgAC                             or lbitem = '13416'
IFDgAC                             or lbitem = '17040'
IFDgAC                             or lbitem = '17041'
IFDgAC                             or lbitem = '17042'
IFDgAC                             or lbitem = '17043'
IFDgAC                             or lbitem = '17045'
IFDgAC                             or lbitem = '17046'
IFDgAC                             or lbitem = '17047'
IFDgAC                             or lbitem = '17048'
IFDgAC                             or lbitem = '17049'
IFDgAC                             or lbitem = '17050'
IFDgAC                             or lbitem = '17051'
IFDgAC                             or lbitem = '17052'
IFDgAC                             or lbitem = '17053'
IFDgAC                             or lbitem = '17054'
IFDgAC                             or lbitem = '17055'
IFDgAC                             or lbitem = '17056'
IFDiAC                             or lbitem = '57106'
IFDjAC                             or lbitem = '101883'
IFDhD ***                eval      skipitem = '1'
IFDhMC                   eval      ifdcomboQTY1 = '1'
IFDgAC                   endif

IFDgA* using ohcust from LABEL32C because GETORDH is executed later
IFDgA* which used xohcust.

IFDgAC                   if        (ohcust = 74927
IFDgAC                             or ohcust = 36055
IFDgAC                             or ohcust = 50318
IFDgAC                             or ohcust = 74194)
IFDgAC                             and lbitem = '28787'
IFDgaC                   eval      ifdcombo = '1'
IFDgAC                   endif

IFDgAC                   endsr
640c
530bA*----------------------------------------------------------------
530bA*  getORDH   Get Order Header Record.
530bA*----------------------------------------------------------------
530bAC     getORDH       begsr

IFDgA* SR changes to use ORDH  X prefix fields.
530cAC                   eval      work8a = *blanks
730gAC                   eval      work11a = *blanks
530bAC                   eval      extStop = *blanks
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
730eAC                   endif
730gAC                   if        ohacusta <> *blanks
730gAC                   eval      work11a = %subst(ohacusta:1:11)
730gAC                   endif

730eAC                   endsl

IFDgA* Chain changes to use ORDH  X prefix fields.
IFDgA* After chain use XOHORD for order, not OHORD.
530bAC     keyodh        chain     ordh
JOReA*
JOReAC                   if        client = Jordanos
JOReAC                   exsr      getordhm
JOReAC                   endif

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
JOReAC                   if        rtxhm2_hmdtei = 0
JORdAc                   z-add     dsSdte        zksDte
JOReAC                   else
JOReA*
JOReAC                   eval      $cvcmd = '*CMDMDY '
JOReAC                   move      rtxhm2_hmdtei $cvd8i
JOReAC                   call      @cvtdt
JOReAC                   parm                    $cvtdt
JOReAC                   move      $cvd6o        zksDte
JOReAC                   endif
JOReA*
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
GLPcAC                             or client = sbertram
PFCbAC                             or client = Prestofoods
DFFdAC                             or client = Dilgard
GFSeAC                   if        %found(ordh)
GFSeAC                   eval      work6a = %subst(xohmisc:1:6)
650gAC                   if        auditflag <> 'Y'
650gAC                   eval      auditflag = %subst(xohmisc:11:1)
GFSeAC                   endif
750cAC                   monitor
GFSeAC                   move      work6a        mmddyy
GFSeAC                   move      mmddyy        mdy
GFSeAC                   move      mdy           shipdate
750cAC                   on-error
750cAC                   eval      shipdate = ''
750cAC                   endmon
GFSmAC                   eval      gfsmsc_base = xohmisc
GFSoAC                   eval      temp7a = %char(ohcord)
GFSoAC                   else
GFSoAC                   eval      temp7a = *blanks
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
SVLlA* if already *SP, don't let it reset until after lblpallet
SVLlAC                   if        snglpal <> '*SP'
SVLlAC                   eval      snglpal = %subst(xohmisc:7:3)
SVLlAC                   endif

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

WIFdAC                   when      client = wiffod
WIFdAC                   if        not %found(ordh)
WIFdAC                   eval      wifmsc_ohcust = *blanks
WIFdAC                   else
WIFdAC                   eval      wifmsc_base = xohmisc
WIFdAC                   endif

DRYfAC                   when      client = dairyland
CSPmAC                             or client = coastalsunbelt
DRYsAC                   if        not %found(ordh)
DRYsAC                   eval      ohcpo = *blanks
DRYsAC                   eval      ohmisc = *blanks
DRYsAC                   else
DRYiAC                   eval      deliverydate2 = *blanks
DRYfAC                   eval      work6a = %subst(ohmisc:1:6)
DRYfAC                   move      work6a        mmddyy
DRYfAC     *mdy          test(d)                 mmddyy                 99
DRYfAC                   if        *in99 = *off
DRYfAC                   move      mmddyy        mdy
DRYfAC                   move      mdy           usadate
DRYfAC                   move      usadate       deliverydate2
DRYfAC                   endif
DRYsAC                   endif
MJKhA
MJKhAC                   when      client = mjkellner
MJKhAC                   if        not %found(ordh)
MJKhAC                   eval      ccpchk = *blanks
MJKhAC                   eval      ccpchks = *blanks
MJKhAC                   else
MJKhAC                   eval      ccpchk = %subst(xohmisc:7:3)
MJKhAC                   eval      ccpchks = %subst(xohmisc:12:1)
MJKhAC                   eval      work6a = %subst(xohmisc:1:6)
MJKhAC                   move      work6a        work6
MJKhAC     *mdy          test(d)                 work6                  99
MJKhAC                   if        *in99 = *off
MJKhAC                   move      work6         mdy
MJKhAC                   move      mdy           work8a
MJKhAC                   endif
MJKhAC                   endif

FFCeAC                   when      client = fischerfoods
FFCeAC                   eval      dsmisc = ohmisc
FFCeA*      Ship date not sent with order, use today's date.
FFCeAC                   if           dsmm = ' '
FFCeAC                             or dsdd = ' '
FFCeAC                             or dsyy = ' '
FFCeAC                   movel     zksdte        dsmisc
FFCeAC                   endif
FFCeAC                   move      dsmm          pkmm
FFCeAC                   eval      pkds1 = '/'
FFCeAC                   move      dsdd          pkdd
FFCeAC                   eval      pkds2 = '/'
FFCeAC                   move      dsyy          pkyy

RYLkAC                   when      client = royal
RYLkAC                   eval      work8a = *blanks
RYLkAC                   eval      work8a = %subst(xohmisc:1:8)

JPFcAC                   when      client = palmer

JPFcAC                   if        not %found(ordh)
JPFcAC                   eval      jpfmsc_subflg = *blanks
JPFcAC                   else
JPFcAC                   eval      jpfmsc_base = xohmisc
JPFcAC                   endif

CSPnAC                   when      client = coastalsunbelt
CSPnAC                   if        not %found(ordh)
CSPnAC                   eval      temp7a = *blanks
CSPnAC                   else
CSPnAC                   eval      temp7a = %char(ohcord)
CSPnAC                   endif

GRCbAC                   when      client = Greco
GRCbA
GRCbAC                   if        %found(ordh)
GRCbAC                   eval      work6a = %subst(xohmisc:1:6)
GRCbAC                   move      work6a        mmddyy
GRCbAC                   move      mmddyy        mdy
GRCbAC                   move      mdy           work8a
GRCbAC                   endif

FBYcAC                   when      client = farmboy
FBYcAC                   if        not %found(ordh)
FBYcAC                   eval      fbymsc_ohcust = *blanks
FBYcAC                   else
FBYcAC                   eval      fbymsc_base = xohmisc
FBYcAC                   endif

KHLaAC                   when      client = kohl
KHLaAC                   if        not %found(ordh)
KHLaAC                   eval      khlmsc_ohcust = *blanks
KHLaAC                   else
KHLaAC                   eval      khlmsc_base = xohmisc
KHLaAC                   endif

SWTbAC                   when      client = swt

730eAC                   select
730eAC                   when      ohaorda <> *blanks
730eAC                   eval      work8a = %subst(ohaorda:1:8)
730eAC                   other
SWTbAC                   if        not %found(ordh)
SWTbAC                   eval      work8a = *blanks
SWTbAC                   else
SWTbAC                   eval      work8a = %char(ohcord)
730eAC                   endif
SWTbAC                   endsl

730eAC                   select
730gAC                   when      ohacusta <> *blanks
730gAC                   eval      work11a = %subst(ohacusta:1:11)
SWTbAC                   other
SWTbAC                   if        not %found(ordh)
SWTbAC                   eval      work11a = *blanks
SWTbAC                   else
SWTbAC                   eval      work11a = %char(xohcust)
SWTbAC                   endif
730gAC                   endsl

CCPaAC                   endsl

530bAC                   call      @getstop
530bAC                   parm      '*ORDSTP'     $lcmd
530bAC                   parm                    $pwhse
530bAC                   parm                    $prtid
530bAC                   parm                    lbord
530bAC                   parm      *zeros        $pdstp
530bAC                   parm                    $phstp
650aAc                   parm                    $pDdrop
650aAc                   parm                    $pDextd
650aAc                   parm                    $pDsd
650aAc                   if        $pDsd <> *blanks
650aAc                   eval      stopdrop = $pDsd
     c                   else
650aAc                   eval      stopdrop = *blanks
650aAc                   endif
530bAC                   if        $phstp <> *zeros
640vDC*                  eval      work3 = $phstp
640vMC                   eval      work3=
640vMC                               %dec(%subst(%editc($phstp:'X'):3:3):3:0)
530bAC                   eval      extstop = %char(work3)
640hAC                   else
640hAC                   eval      extstop = %char(lbstop)
NCSgAC                   endif

642mAC                   eval      coinf1 = *blanks
642mAC                   eval      coinf2 = *blanks
642mAC                   eval      coinf3 = *blanks
642mAC                   eval      coinf4 = *blanks
642mAC                   eval      coinf5 = *blanks
642mAC                   eval      @pick  = 'PICK'
642mAC     keyexp2       chain     custexp
642mAC                   select
642mAC                   when      %found(custexp)
642mAC                   eval      coinf1 = %trim(coinf1)
642mAC                                      + ' '
642mAC                                      + %subst(ohcpo:3:4)
642mAC                                      + ' '
642mAC                                      + %subst(ohcpo:7:4)
642nAC                   eval      chkRDD = %trim(coinf2)
642nAC                   if        chkRDD = 'RDD'
642nAC                   eval      coinf2 = %subst(coinf2:1:3)
642nAC                                      + ' '
642nAC                                      + %subst(ohcpo:12:3)
642nAC                                      + ' '
642nAC                                      + %subst(coinf2:9:3)
642nAC                   endif
642mAC                   eval      @pick  = 'PICKEXP'
642mAC                   when      not %found(custexp)
642mAC     keyexp        chain     custexp
642mAC                   if        %found(custexp)
642mAC                   eval      coinf1 = %trim(coinf1)
642mAC                                      + ' '
642mAC                                      + %subst(ohcpo:3:4)
642mAC                                      + ' '
642mAC                                      + %subst(ohcpo:7:4)
642mAC                   eval      @pick  = 'PICKEXP'
642mAC                   endif
642mAC                   endsl

530bAC                   endsr
     *----------------------------------------------------------------
GFCgA*  GetORDHM  Get Order Header Miscellaneous Record.
     *----------------------------------------------------------------
GFCgAC     getORDHM      begsr

     C     keyodh        chain     ordhm

DRYoMC                   eval      $prtflag = *blanks

     C                   select
     C                   when      not %found(ordhm)
     C                   eval      viphm2_ohcusn = *blanks
FPRcAC                   eval      rtxhm2_hmdtei = 0
dry AC                   eval      dryhm1_trkid = *blanks
JOReAC                   eval      rtxhm2_hmdtei = 0
DRYfAC                   eval      dryhm1_voyid = *blanks
DRYfAC                   eval      dryhm2_motcd = *blanks
DRYfAC                   eval      methodofdlvry = *blanks
DRYnD ***                eval      cruiseshipflg = *blanks
DRYoD ***                eval      $prtflag = *blanks
CSPmAC                   eval      csphm1_trkid = *blanks

dry AC                   when      client = dairyland
dry AC                   eval      dryhm1_base = hmmsc1
DRYfAC                   eval      dryhm2_base = hmmsc2
DRYfAC                   if        dryhm2_motcd <> *blanks
DRYfAC                   call      'GETMOT'
DRYfAC                   parm                    dryhm2_motcd
DRYfAC                   parm                    methodofdlvry
DRYnMC                   parm                    $prtflag
     C                   parm                    $rtn              8
DRYfAC                   endif

CWDyAC                   when      client = cashwa
CWDyAC                   eval      cwdhm1_base = hmmsc1
JOReA*
JOReAC                   when      client = jordanos
JOReAC                   eval      rtxhm2_base = hmmsc2
JOReAC                   eval      ckdate = %subst(rtxhm2_base:1:8)
JOReAC                   testn                   ckdate                   52
JOReAC                   if        *in52 = '1'
JOReAC                   eval      rtxhm2_hmdtei = 0
JOReAC                   endif
JOReA*
CSPmAC                   when      client = coastalsunbelt
CSPmAC                   eval      csphm1_base = hmmsc1
CSPtAC                   eval      dispHH = %subst(hmmsc4:9:10)
CSPtAC                   eval      dispMM = %subst(hmmsc4:11:12)
CSPtAC                   eval      dispatch = dispHH + ':' + dispMM

GRCaAC                   when      client = greco
DRYfAC                   other
     C                   eval      viphm2_base = hmmsc2
FPRcAC                   eval      rtxhm2_base = hmmsc2
700jAC                   eval      amphm4_base = hmmsc4
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
PFCgAC                   eval      target = *blanks
ISYaAC                   eval      omodsc = *blanks
ISYaAC                   eval      ompdsc = 'N'
ISYaAC                   eval      omrdsc = 'N'
ISYaAC                   eval      omcbox = 'N'
ISYaAC                   eval      omcexp = 'N'
IFDaAC                   eval      keytype  = *blanks
IFDfAC                   eval      typecode = *blanks
750qAC                   eval      ommsc1   = *blanks
750qAC                   eval      ommsc2   = *blanks
750qAC                   eval      ommsc3   = *blanks
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

GFSaAC                   when      client = getfresh
GFSaAC                   eval      gfsdm1_base = ommsc1

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

PFCgAC                   when      client = prestofoods
VFIcAC                             or client = vitco
PFCgAC                   eval      target = %subst(ommsc3:1:10)

ISYaAC                   when      client = isupply
ISYa C                   eval      dsmsc1 = ommsc1
ISYa C                   eval      dsmsc2 = ommsc2
ISYa C                   eval      dsmsc3 = ommsc3
ISYa C                   eval      dsmsc4 = ommsc4

IFDaAC                   when      client = ifd
IFDaAC                   eval      keytype = %subst(ommsc1:1:1)
IFDaAC                   eval      typecode = %subst(ommsc1:2:2)

CSPmAC                   when      client = coastalsunbelt
CSPmAC                   eval      itmnum = %subst(ommsc2:1:18)

640eAC                   endsl
640cA
640cAC                   endsr
730mA*----------------------------------------------------------------
730mA*  getLABELUM   Get Label UM Reecord
730mA*----------------------------------------------------------------
730mAC     getLABELUM    begsr
730mA /free
730mA
730mA  monitor;
730mA    umWhse = lbwhse;
730mA    umlabel('*GET': umRtnCode: umRtnMsg:
730mA            umWhse: lblbl#:
730mA            umFlexPickFlag:
730mA            lbualq1: lbualu1: lbualq2: lbualu2: lbualq3: lbualu3);
730mA  on-error;
730mA    umRtnCode = '*ERROR';
730mA    umFlexPickFlag = '';
730mA  endmon;
730mA
730mA  if umRtnCode <> '*OK';
730mA    umFlexPickFlag = '';
730mA  endif;
730mA
730mA /end-free
730mAC                   endsr
GFSnA*
GFSnA*----------------------------------------------------------------
GFSnA*  RcvDateGFS  Received Date Processing for Get Fresh
GFSnA*----------------------------------------------------------------
GFSnAC     RcvDateGFS    begsr
GFSnA
GFSnAC                   eval      rcvdate = ' '
GFSnAC                   eval      norcvdate = '0'
GFSnAC                   select
GFSnAC                   when          ohcust >= 3216
GFSnAC                             and ohcust <= 3238
GFSnA*
GFSnAC                              or ohcust  = 3387
GFSnAC                              or ohcust  = 3449
GFSnAC                              or ohcust  = 3659
GFSnAC                              or ohcust  = 3812
GFSnAC                              or ohcust  = 5744
GFSnA*
GFSnAC                              or ohcust >= 5774
GFSnAC                             and ohcust <= 5775
GFSnA*
GFSnAC                              or ohcust  = 6387
GFSnA*
GFSnA*      Get Received Date when department or slot changes.
GFSnAC                   if            lbwhdp <> svwhdp
GFSnAC                             or lbdisp <> svdisp
GFSnAC                   eval      svwhdp = lbwhdp
GFSnAC                   eval      svdisp = lbdisp
GFSnA*
GFSnAC                   exsr      clr$license
GFSnAC                   exsr      clr$licinfo
GFSnA
GFSnAC                   eval      $liToWhse = lbwhse
GFSnAC                   eval      $liToWhdp = lbwhdp
GFSnAC                   eval      $liToDisp = lbdisp
GFSnAC                   exsr      getrcvdate
GFSnA*
GFSnA*       No license found for pick location. Try first overflow.
GFSnAC                   select
GFSnAC                   when          error = '1'
GFSnAC                             or  $LiFirstNEFifoEntd = 0
GFSnAC                   eval      kyitem = lbitem
GFSnAC                   eval      kypick = 'N'
GFSnAC                   eval      kystat = 'A '
GFSnA*
GFSnA*       Not a slotted item, get slotted item.
GFSnAC                   if           ittype = 'A'
GFSnAC                             or ittype = 'R'
GFSnAC                             or ittype = 'S'
GFSnAC                   call      @getsi
GFSnAC                   parm      lbwhse        $gwhse            3 0
GFSnAC                   parm      lbitem        #gitem           15
GFSnAC                   parm      ' '           #sitem           15
GFSnAC                   parm                    #sityp            1
GFSnAC                   parm                    #sdesc           30
GFSnAC                   parm                    #spdsc           15
GFSnAC                   parm                    #srtn            10
GFSnAC                   parm                    #smsg            60
GFSnAC                   if        #srtn = '*OK'
GFSnAC                   eval      kyitem = #sitem
GFSnA*
GFSnA*       Repack item. Look for RPK work-order overflow slot first,
GFSnA*       otherwise, assume on-demand repack pick slot.
GFSnAC                   if        ittype = 'R'
GFSnAC                   eval      kystat = 'RP'
GFSnAC     keysl3        setll     slot3
GFSnAC                   if        not %equal(slot3)
GFSnAC                   eval      kypick = 'Y'
GFSnAC                   endif
GFSnAC                   endif
GFSnA*
GFSnAC                   endif
GFSnA*
GFSnAC                   endif
GFSnA*
GFSnAC     keysl3        setll     slot3
GFSnAC                   dow       forevr = forevr
GFSnAC     keysl3        reade     slot3
GFSnAC                   if        %eof(slot3)
GFSnAC                   eval      norcvdate = '1'
GFSnAC                   exsr      fmtrcvdate
GFSnAC                   leave
GFSnAC                   endif
GFSnAC
GFSnAC                   if           sldesg = 'BFC'
GFSnAC                             or  slexpd < Today
GFSnAC                             and slexpd <> 0
GFSnAC                             and itflgd = 'Y'
GFSnAC                   iter
GFSnAC                   endif
GFSnA*
GFSnAC                   exsr      clr$license
GFSnAC                   exsr      clr$licinfo
GFSnAC
GFSnAC                   eval      $liToWhse = lbwhse
GFSnAC                   eval      $liToWhdp = slwhdp
GFSnAC                   eval      $liToDisp = sldisp
GFSnAC                   exsr      getrcvdate
GFSnAC                   if            error = '0'
GFSnAC                             and $LiFirstNEFifoEntd > 0
GFSnAC                   exsr      fmtrcvdate
GFSnAC                   leave
GFSnAC                   endif
GFSnAC
GFSnAC                   enddo
GFSnAC
GFSnAC                   when          error = '0'
GFSnAC                             and $LiFirstNEFifoEntd > 0
GFSnAC                   exsr      fmtrcvdate
GFSnAC
GFSnAC                   endsl
GFSnAC
GFSnAC                   endif
GFSnAC
GFSnAC                   endsl
GFSnA
GFSnAC                   endsr
GFSnA*
GFSnA*----------------------------------------------------------------
GFSnA*  getRcvDate  Get Received Date from picking slot.
GFSnA*----------------------------------------------------------------
GFSnAC     getRcvDate    begsr
GFSnA
GFSnAC                   eval      $liToWhseu = *on
GFSnAC                   eval      $liToWhse = $pwhse
GFSnAC                   eval      $liToWhdpU = *on
GFSnAC                   eval      $liToDispU = *on
GFSnAC                   eval      $dricommand = '*LICENSE'
GFSnAC                   eval      $drisubcmd  = '%GETSLTLIC'
GFSnAC                   eval      $drisys2upd = 'D'
GFSnAC                   exsr      zzzdricop
GFSnA
GFSnAC                   endsr
GFSnA*
GFSnA*----------------------------------------------------------------
GFSnA*  fmtRcvDate  Format Received Date into Printing format.
GFSnA*----------------------------------------------------------------
GFSnAC     fmtRcvDate    begsr
GFSnA*
GFSnA*      No Received Date found for picking slot.
GFSnAC                   if        NoRcvDate = '1'
GFSnAC                   eval      rcvtext = 'Rcv:_'
GFSnA*
GFSnA*      Use Delivery Date from Order Header.
GFSnAC                   eval      $cvd6o    = 0
GFSnAC                   eval      $cvd8o    = 0
GFSnAC                   eval      $cddatein = 0
GFSnAC                   if            %subst(ohmisc:1:6) >= '000000'
GFSnAC                             and %subst(ohmisc:1:6) <= '999999'
GFSnAC                   eval      $cvcmd = '*MDYCMD '
GFSnAC                   eval      $cvd6i = %subst(ohmisc:1:6)
GFSnAC                   call      @cvtdt
GFSnAC                   parm                    $cvtdt
GFSnAC                   eval      $cddatein = $cvd8o
GFSnA*
GFSnAC                   else
GFSnA*      No Delivery Date found, use Today's Date.
GFSnAC                   eval      $cddatein = today
GFSnAC                   endif
GFSnA*
GFSnA*  Calculate (Delivery Date - 2 Days) for Receive Date when not found.
GFSnAC                   call      'CLCDUR2'
GFSnAC                   parm      '*SUB'        $cdcmd
GFSnAC                   parm                    $cddatein
GFSnAC                   parm      0             $cdtimein
GFSnAC                   parm      0             $cdyears
GFSnAC                   parm      0             $cdmonths
GFSnAC                   parm      2             $cddays
GFSnAC                   parm      0             $cdhours
GFSnAC                   parm      0             $cdminutes
GFSnAC                   parm      0             $cdseconds
GFSnAC                   parm      0             $cddateout
GFSnAC                   parm      0             $cdtimeout
GFSnAC                   eval      wrkdate = $cddateout
GFSnA
GFSnAC                   else
GFSnA*      Received Date found from pick location.
GFSnAC                   eval      rcvtext = 'Rcv: '
GFSnAC                   eval      wrkdate = $LiFirstNEFifoEntd
GFSnAC                   endif
GFSnA*
GFSnA*  Convert Received Date into MM/DD/YY format.
GFSnAC                   eval      $cvcmd = '*CMDMDY '
GFSnAC                   move      wrkdate       $cvd8i
GFSnAC                   call      @cvtdt
GFSnAC                   parm                    $cvtdt
GFSnA*
GFSnAC                   eval      wrkdatea= %editc($cvd6o : 'X')
GFSnAC                   eval      rcvdate = rcvtext
GFSnAC                                       + %subst(wrkdatea:1:2)
GFSnAC                                       + '/'
GFSnAC                                       + %subst(wrkdatea:3:2)
GFSnAC                                       + '/'
GFSnAC                                       + %subst(wrkdatea:5:2)
GFSnA
GFSnAC                   endsr
GFSnA*
svleA*----------------------------------------------------------------
svleA*  getRTEHED Get Route Header Record.
svleA*----------------------------------------------------------------
svleAC     getRTEHED     begsr

svleAC     keyrte        chain     rtehed

svleAC                   eval      deliverydate = *blanks
svleAC                   eval      mdy2 = *blanks
JPFaAC                   eval      willcall = *off
svleAC                   if        %found(rtehed)

JPFaA* Willcall flag
JPFaAC                   if        client = palmer
JPFaAC                             and rhtype = 'W'
JPFaAC                   eval      willcall = *on
JPFaAC                   endif

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

SVLkA*
SVLkA*  Get Saval Delivery Date option.
SVLkA*
SVLkAC                   eval      opwhse = 1
SVLkAC                   eval      opcode = '*SVLDATE'
SVLkAC     opkey         chain     options
SVLkAC                   if        %found(options)
SVLkAC                   eval      opdeldt = opdata
SVLkAC                   else
SVLkAC                   eval      opdeldt = *blanks
SVLkAC                   endif
SVLkAC                   if        opdeldt <> *blanks
SVLkAC                   eval      deliverydate = opdeldt
SVLkAC                   eval      mdy2 = %subst(opdeldt:1:2)
SVLkAC                                  + %subst(opdeldt:4:2)
SVLkAC                                  + %subst(opdeldt:7:2)
SVLkAC                   endif

svleAC                   endif

700zA /free
           chain(n) (rhwhse: rhtruk) truckh2;

           if not %found(truckh2);
             jthdesc = '*** not found ***';
           endif;

700zA /end-free

svleAC                   endsr
710dA*----------------------------------------------------------------
710dA*  getTRKCOMP get truck compartment record
710dA*----------------------------------------------------------------
710dA*
710dAC     getTRKCOMP    begsr

710dAC                   eval      tpdesc = *blanks
710dAC     kytrcp        chain     trkcomp

710dAC                   endsr
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
700
700 A*----------------------------------------------------------------
700 A*  clr$license  Clear $license data structure fields
700 A*----------------------------------------------------------------
700 A
700 AC     clr$license   begsr
700 AC                   eval      savever# = $liver#
700 AC                   clear                   $license
700 AC                   clear                   $license2
700 AC                   eval      $liver# = savever#
700 AC                   eval      $liuser = #user
700 AC                   eval      $lipgm  = #pgm
700 AC                   eval      $lijob  = #job
700 AC                   eval      $lijobn = #jobn
700 AC                   if        $saemp#U
700 AC                   eval      $liemp# = 0
700 AC                   endif
700 AC                   endsr
700 A
700 A*----------------------------------------------------------------
700 A*  clr$licinfo  Clear $licinfo data structure fields
700 A*----------------------------------------------------------------
700 A
700 AC     clr$licinfo   begsr
700 AC                   eval      savever# = $lnver#
700 AC                   clear                   $licinfo
700 AC                   clear                   $licinfo2
700 AC                   eval      $lnver# = savever#
700 A
700 AC                   eval      $lnuser = #user
700 AC                   eval      $lnemp# = 0
700 AC                   eval      $lnpgm  = #pgm
700 AC                   eval      $lnjob  = #job
700 AC                   eval      $lnjobnbr = #jobn
700 A
700 AC                   endsr
700 A
700 A*----------------------------------------------------------------
700 A*  zzzdricop  Call DRICOP
700 A*----------------------------------------------------------------
700 A
700 AC     zzzdricop     begsr
700 AC                   eval      error = *off
700 A
700 AC                   select
700 AC                   when      $dricommand = '*SLOT'
700 AC                   eval      $dridata = $slot
700 AC                   eval      $dridata2 = $slot2
700 AC                   when      $dricommand = '*XDOCK'
700 AC                   eval      $dridata = $xdock
700 AC                   when      $dricommand = '*LICINFO'
700 AC                   eval      $dridata = $licinfo
700 AC                   eval      $dridata2 = $licinfo2
700 AC                   when      $dricommand = '*LICHIST'
700 AC                   eval      $dridata = $lichist
700 AC                   when      $dricommand = '*LICENSE'
700 AC                   eval      $dridata = $license
700 AC                   eval      $dridata2 = $license2
700 AC                   when      $dricommand = '*ITEM'
700 AC                   eval      $dridata = $item
700 AC                   eval      $dridata2 = $item2
700 AC                   when      $dricommand = '*UCIINFO'
700 AC                   eval      $dridata = $uciinfo
720kAC                   eval      $dridata2 = $uciinfo2
700 AC                   endsl
700 A
700 AC                   if           $dricommand = '*ITEM'
700 AC                             or $dricommand = '*SLOT'
700 AC                             or $dricommand = '*LICENSE'
700 AC                             or $dricommand = '*LICINFO'
720kAC                             or $dricommand = '*UCIINFO'
700 AC                   call(e)   'DRICOP'
700 AC                   parm                    $dricommand
700 AC                   parm                    $drisubcmd
700 AC                   parm                    $drisys2upd
700 AC                   parm      #pgm          $driprogram
700 AC                   parm      ' '           $drireturn
700 AC                   parm      ' '           $drimessage
700 AC                   parm                    $dridata
700 AC                   parm                    $dridata2
700 AC                   else
700 AC                   call(e)   'DRICOP'
700 AC                   parm                    $dricommand
700 AC                   parm                    $drisubcmd
700 AC                   parm                    $drisys2upd
700 AC                   parm      #pgm          $driprogram
700 AC                   parm      ' '           $drireturn
700 AC                   parm      ' '           $drimessage
700 AC                   parm                    $dridata
700 AC                   endif
700 A
700 AC                   select
700 A
700 AC                   when      %error and ck4err = *on
700 AC                   eval      error = *on
700 AC                   eval      errmsg    = 'Error occured on call to '
700 AC                                       + 'DRICOP'
700 AC                                       + '/' + %trim($drisubcmd)
700 AC                                       + ' from ' + #pgm
700 AC                   select
700 AC                   when      zmsflag
700 AC*                  exsr      zm0105s
700 AC                   when      zmflag
700 AC*                  exsr      zm0105
700 AC                   endsl
700 A
700 AC                   when      $drireturn <> '*OK' and ck4err = *on
700 AC                   eval      error = *on
700 AC                   select
700 AC                   when      zmsflag
700 AC*                  exsr      zm0001s
700 AC                   when      zmflag
700 AC*                  exsr      zm0001
700 AC*                  exsr      zzerrind
700 AC                   endsl
700 A
700 AC                   endsl
700 A
700 AC                   select
700 AC                   when      $dricommand = '*SLOT'
700 AC                   eval      $slot = $dridata
700 AC                   eval      $slot2 = $dridata2
700 AC                   when      $dricommand = '*XDOCK'
700 AC                   eval      $xdock = $dridata
700 AC                   when      $dricommand = '*LICINFO'
700 AC                   eval      $licinfo = $dridata
700 AC                   eval      $licinfo2 = $dridata2
700 AC                   when      $dricommand = '*LICHIST'
700 AC                   eval      $lichist = $dridata
700 AC                   when      $dricommand = '*LICENSE'
700 AC                   eval      $license = $dridata
700 AC                   eval      $license2 = $dridata2
700 AC                   when      $dricommand = '*ITEM'
700 AC                   eval      $item = $dridata
700 AC                   eval      $item2 = $dridata2
700 AC                   when      $dricommand = '*UCIINFO'
700 AC                   eval      $uciinfo = $dridata
720kAC                   eval      $uciinfo2 = $dridata2
700 AC                   endsl
700 A
700 AC                   eval      zmflag = *off
700 AC                   eval      zmsflag = *off
700 AC                   eval      ck4err = *off
700  C     enddricop     endsr

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
CPCeA*  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   endsr

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

720aA*----------------------------------------------------------------
720aA*  IFSOpenFile     Open IFS files
720aA*----------------------------------------------------------------
720aA
720aAp IFSOpenFile     b
     d IFSOpenFile     pi
     d  fileNum                       3  0 const

      /free

       wFileCount(fileNum) += 1;

       if outputType <> 'IFS';
         return;
       endif;

       // Close file if open

       IFSCloseFile(fileNum);

       // Set IFS path

       wPath = '/BFCLabels';

       // Create file name

       wFileName = 'w' + %char($pwhse);

       if $prtid <> '';
         wFileName += '_r' + $prtid;
       endif;

       if $ptzon <> '';
         wFileName += '_z' + %trim($pszon);
       endif;

       if $ptrn# <> 0;
         wFileName += '_t' + %char($ptrn#);
       endif;

       if $plbl# <> 0;
         wFileName += '_l' + %char($plbl#);
       endif;

       wFileName += '_s' + %char(wStamp);

       wFileName += '_f' + %char(fileNum);

       wFileName += '_c' + %char(wFileCount(fileNum));

       // Open File

       WrtIFS('OPENFILE': wPath: wFileName: '': wFileId(fileNum):wRtn:wMessage);

       if wRtn <> '*OK';
         wMessage = wMessage;
       endif;

       return;

      /end-free

     p IFSOpenFile     e

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

       // Only want to open/create a file if there is something to write to it

       if wLabelCount(fileNum) = 0;
         IFSOpenFile(fileNum);
         wLabelCount(fileNum) = 1;
       endif;

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

       // Write line to file

       if outputType = 'IFS';
ifs D    //WrtIFS('WRITELINE': '': '': wLine: wFileId(fileNum): wRtn: wMessage);
ifs M    WrtIFS('WRITELINE': '': '': newLine: wFileId(fileNum): wRtn: wMessage);

         if wRtn <> '*OK';
           wMessage = wMessage;
         endif;
       endif;

       // Using webservice at labelary.com to print labels to pdf
       // Service only allows a maximum of 50 labels
       // We can print 12 2.9 x 1.6 labels per page (2 columns, 6 rows)
       // Therefore we will limt a file to 48 labels.

       select;

         when %len(wLine) >= 3 and %subst(wLine: 1: 3) = '^PR';
           wLabelCount(fileNum) += 1;

         when wLine = '^XZ';
           if wLabelCount(fileNum) = 49;
             IFSCloseFile(fileNum);
             wLabelCount(fileNum) = 0;
           endif;

       endsl;

       return;

      /end-free

     p IFSWriteLine    e

720aA*----------------------------------------------------------------
720aA*  IFSCloseFile    Close IFS files
720aA*----------------------------------------------------------------
720aA
720aAp IFSCloseFile    b
     d IFSCloseFile    pi
     d  fileNum                       3  0 const

      /free

       if outputType <> 'IFS';
         return;
       endif;

       WrtIFS('CLOSEFILE': '': '': '': wFileId(fileNum): wRtn: wMessage);

       if wRtn <> '*OK';
         wMessage = wMessage;
       endif;


       return;

      /end-free

     p IFSCloseFile    e

720aA*----------------------------------------------------------------
720aA*  IFSClosePgm     Close IFS program
720aA*----------------------------------------------------------------
720aA
720aAp IFSClosePgm     b
     d IFSClosePgm     pi


     * Local Variables

     d  fd             s             10i 0

      /free

       if outputType <> 'IFS';
         return;
       endif;

       WrtIFS('CLOSEPGM': '': '': '': fd: wRtn: wMessage);

       return;

      /end-free

     p IFSClosePgm     e

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
**   TTLDSC
<<< TOTALS >>>
