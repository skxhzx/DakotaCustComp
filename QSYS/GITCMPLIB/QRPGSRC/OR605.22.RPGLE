      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR605     Truck build - Traffic cop
     *  12 June 1997
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
400 A*    06/12/97   DAS  4.00
     *      - Major revisons for truck build process. This program was
     *        based on OR505. Old revisions were removed to clean up
     *        program.
     *      - Initial revisions have not be marked with the version.
     *      - RTEHED3 has replaced ORDH2.
     *      - A new route id field is used to uniquely identify routes.
     *      - *** Transfers will not work correctly becuase the    ***
     *        *** program will need to create route records.       ***
     *
223 A*    07/02/97   HNK  2.23
     *      - Validate truck number.
     *      - $PMSG parameter added.
     *
402 A*    07/18/97   DAS  4.02
     *      - Removed skip around loading sheet.
     *      - Changed loading sheet to call truck summary program.
     *      - Revised warehouse parameter on pallet summary call.
     *
404 A*    08/26/97   HNL  4.04
     *      - Changed to call OR660CL with '*DETAIL'.
     *
404 A*    08/27/97   DAS  4.04
     *      - Change *POSPICK and *POSPCK1 to *WCPICK and *WCPICK1.
     *      - Implemented *ALL to do everything at one time.
     *
404 A*    09/05/97   DAS  4.04
     *      - Revised to skip summary reports for Will Call route.
     *
409 A*    05/22/98   RH   4.09
     *      - Changed to call OR660CL 2nd time with '*SUMMARY'.
     *
413 A*    01/06/00   HNK  4.13
     *      - Use reports override for device and form to print
     *        the PS311 report.
413aA*    03/22/00   MLB  4.13a
     *      - Added call to OR625 - Assign pallet sections to items.
414aA*    04/06/00   MLB  4.14a
     *      - Added file OPTIONS to program to retrieve *GENPICK
     *        defaults.
     *      - Revised routine PICK to not call pgm OR640 when processing
     *        Host pick Will Call orders.
     *      - Added call to pgm PT647 - Host pick Will Call Auto
     *        Close Transactions.
     *      - Added call to pgm OR670 - Print Host pick Will Call Item
     *        Exceptions.
414bA*    04/06/00   MLB  4.14b
     *      - Revised routine UPDCTL to not create new batch control
     *        number when $PCMD2 is *REBUILD or *PCKPRNT.
     *      - Revised routine UPDRTE to update batch number in RTEHED
     *        only during allocate/build step.
     *      - Revised mainline code to load batch number from RTEHED
     *        when $PCMD is NOT equal to *RESTART.
     *      - Revised routine PICK to set JOBOK to *DONE and update
     *        file BATCTL with 9=Finished status.
414cA*    07/14/00   HNK  4.14c
     *      - Revised to print catch weight report OR665CL.
414dA*    10/26/00   DAS  4.14d
     *      - Moved retreival of OPTIONS to outside of select stmt.
     *
415 A*    04/30/01   DAS  4.15
     *      - Added logic to track length of time for each process.
     *
415aA*    05/03/01   DAS  4.15a
     *      - Line to OPEN OPTIONS file was not deleted
     *        correctly in 414d change.
     *
415bA*    05/31/01   MLB  4.15b
     *      - Changed pgm to call OR770 instead of OR670.
     *
416 A*    02/11/02  MLB  4.16
     *      - Added call to OR626 to accumulate compartment totals.
416aA*    04/03/02  MLB  4.16a
     *      - Added call to DK130 to assign dock doors to route.  .
416bA*    07/19/02  MLB  4.16b
     *      - Fix: Added order type to test for assigning dock doors.
417 A*    08/20/03  DAS  4.17
     *      - Enh: Added DEV/FORM parms to OR660CL call.
     *
500 A*    11/23/04  MLB  5.00
     *      - Enh: Revised program to initialize dev/form on call to
     *        OR660CL to *JOB/*STD.
500aA*    08/31/05  DAS  5.00a
     *      - Enh: Added call to DFPICK for special pick sequence
500bA*    10/07/05  MLB  5.00b
     *      - Enh: Updated *GENPICK data structure to retrieve JIT
     *        replenishments option. If OPJITR=2, then call CCJITPCL
     *        to create Priority Replenishments during Pick/Print
     *        processing.
500cA*    03/17/06   JCJ  5.00c
     *      - Enh: Added call to OR660TCL
500dA*    05/05/06  RH   5.00d
     *      - Enh: Added Client code.
     *
510aA*    10/07/06  DAS  5.10a
     *      - Added call to OR638, conditioned by client.
     *      - Added City Line custom mod.
510bA*    11/02/06  RH   5.10b
     *      - Enh: Add *FEATURE to include code for Stand Alone system
     *      - Enh: Add 510c code (500a) from PIRSTD library.
510cA*    09/11/05  MLB  5.10c
     *      - Enh: Revised program to call new programs OR610P and
     *        OR630P in place of OR10 and OR630. These new programs
     *        will not do any allocation at the warehouse or slot
     *        levels. The pick slot for each item is sent along with
     *        each order detail record.
510dA*    12/01/06  RH   5.10d
     *      - Added code run on job que.
510eA*    06/20/07  DAS  5.10e
     *      - Added call to OR637, conditioned by client.
510fA*    08/30/07  DAS  5.10f
     *      - Converted to ILE.
     *      - Moved OR626 and DK130 within *ALOCBLD tracking.
520 A*    05/06/08  JCJ  5.20
     *      - Discontinue printing OR660t
520aA*    02/06/08  RBD  5.20a  P#00003
     *      - Added call to OR639D to delete preexisting ORDAD recs
     *        for a route.
     *      - Added call to OR639 to create ORDAD unique sscc18 recs
     *        for a route.
520bA*    02/12/08  DAS  5.20b  P#00003, P#00011
     *      - Added call to OR635 to update TOTEHDR recs with trn#'s
520cA*    04/05/08  DAS  5.20c
     *      - Fix: Revised pgm to load KYCODE instead of OPCODE
     *        when retrieving *FEATURE record.
     *
520dA*    06/24/09  JCJ  5.20d
     *      - Enh: Added call to OR630B for Loader Merge processing.
     *
520eA*    09/24/09  JCJ  5.20e
     *      - Enh: Added call to OR610B for batch pick processing
     *      - Enh: Added call to OR610B2 for batch pick processing
600aA*    05/08/09  DAS  6.00a  P#00045
     *      - License tracking
     *      - Letdowns have been removed for license tracking.
     *        Revised to ensure OPJITR option is not set for Letdowns.
530aA*    11/09/09  DAS  5.30a
     *      - Enh: Recomplied for database change to TRUCKH.
610aA*    02/23/10  DAS  6.10a
     *      - Added custom Dierks mod DRKa
     *
530bA*    03/08/10  MLB  5.30b
     *      - Fix: Correct parameters passed to OR660CL for both
     *        *DETAIL and *SUMMARY versions.  This patch is for the
     *        new printer override supported added in a previous version.
     *
610bA*    11/08/10  RBD  6.10b
     *      - Added call to OR642 to create PRE slots for pre-pick
     *        routes.
     *
610cA*    12/01/10  DAS  6.10c
     *      - Moved call to OR642 before setting printed status.
     *        If an error occurs during OR642, the route will be
     *        left at Built status and can be processed again once
     *        the error has been fixed.
     *      - Added cmd parameter to OR642.
     *
640aA*    03/02/11  DAS  6.40a
     *      - Revised to make creating ORDP records standard.
640bA*    07/16/11  MLB  6.40b
     *      - Enh: Added parm to pgm GETCLIENT to retrieve clientloc.
640cA*    03/06/12  JCJ  6.40c
     *      - Enh: Added OR630B to OUTBOUND only clients.
640dA*    05/07/12  RBD  6.40d
     *      - Added pallet id and transaction parms to pgm OR626.
     *        These parms are not currently used in this pgm and will
     *        only be initialized.
     *
650aA*    12/27/13  DAS  6.50a
     *      - Revised to use CHKIUSE2 instead of setting RHSHPD.
     *      - No longer uses rhshpd for inuse flag.
     *      - Requires new CHKIUSE2 progam and new RTEINUSE file.
     *
650bA*    03/11/14  DAS  6.50b
     *      - Added logic to write to bfcdebug file.
650xA*    04/03/14  RH   6.50x
     *      - Temp Mod: do not use file BFCDBGFLG, file only at BFC
     *
700aA*    04/18/15  DAS  7.00a
     *      - Reserved for USF changes.
     *
700bA*    04/18/15  DAS  7.00b
     *      - Reserved for USF changes.
     *
700cA*    04/19/15  DAS  7.00c
     *      - Reserved for USF changes.
     *
700dA*    07/24/15  NLK  7.00c
     *      - AMP - Advanced Merge Pick process added
     *      - NEW pgm OR643 call
     *      - keep 'CALL' OR642 & OR643 since ohmisc has no value here
     *
700eA*    08/28/15  DLS  7.00e
     *      - Added call to OR641 to assign 4 digit voice ids.
     *
700f *    12/23/15  GJA  7.00f
     *      - Fix:  Add parms to OR641 call
700g *    03/18/16  LMC  7.00g
     *      - Fix:  On command rebuild if user has a DD lock do not
     *        clear in use. We found that if the user rebuilds the
     *        route within DD, the lock on the route is cleared, but
     *        the user is still in DD.
     *
700hA*    05/12/16  RBD  7.00h
     *      - Enh: If option *LOADER/OPADDO = Y call TR875 to auto
     *        define add-on routes in TTMERG.
     *        Note: client does not have to use the Loader Module
     *        though OPADDO is in the *LOADER options.
     *
700i *    07/11/16  TAB  7.00i
     *      - Comments added before call to OR620CL
     *
710aA*    12/29/17  DAS  7.10a
     *      - Enh: Added logging to GLORTELOG file
     *      - Stopped logging RTETRCK file
     *      - Was 650a in USF version.
     *
710bA*    12/29/17  DAS  7.10b
     *      - Enh: Do not print truck map when $PCMD2 = '*STGPRNT'
     *      - Was 650b in USF version.
     *
710cA*    12/29/17  DAS  7.10c
     *      - Added lines to allow REBUILD to use same Grp ID(700d in USF)
     *
720 A*    04/10/18  KDE  7.20
     *      - Added call to OR630ADB to support DragDrop 2
     *
720aA*    04/19/18  DAS  7.20a
     *      - Moved call to or630ADB to before OR640
     *
720bA*    09/07/18  DAS  7.20b
     *      - Revised to call GetTBType instead of reading
     *        data area dragdrop2 directly.
     *      - Replaced dd2 with tbEnhanced.
     *
720cA*    10/08/18  DAS  7.20b
     *      - Revised how zzendlog sets $ltype to '3'
     *
730aA*    11/23/18  DAS  7.30a
     *      - Enh: Call program SETRTEAUD after OR630.
     *
CBI A*----------------------------------------------------------------
CBI A*  Client Custom Revisions: Cheney
CBI A*
CBI A*    08/05/03  HNK  CBI
     *      - Call OR662CL to print truck pallet report for Produce
     *        items only.  this report will be directed to A1A's
     *        warehouse printer.
     *
CBIbA*    09/03/03  HNK  CBIb
     *      - print OR660 Summary for Willcall 'BREAKERS' truck.
     *
CBIcA*    10/16/03  HNK  CBIc
     *      - Enable printing OR660 detail report. Ref-Email 10.16.03
     *      - Print 3 copies of summary instead of 2.
     *
CBIdA*    10/17/03  HNK  CBId
     *      - Disable printing OR660 detail report. Ref-Email 10.17.03
     *      - Print OR663 Driver's Pallet detail report instead.
     *      - Disable third copy of Summary report. Ref-Email 10.16.03
CBIeA*    10/29/03  RH   CBIe
     *      - Disable printing OR663 detail report, will print at
     *        close in PT640 and PT645.
CBIfA*    11/14/03  HNK  CBIf
     *      - Print OR660 summary report and PS311 for Will Call order
     *        with truck code of 'ADD-ONS'
     *    11/17/03 HNK
     *      - Print OR662 as well.
CBIgA*    11/18/03  RH   CBIg
     *      - Disable printing 2nd copy OR660 Summary.. 11-17-03 email
CBIhA*    11/24/03  RH   CBIh
     *      - Change to print list at allocate/build for PRD at A1A
CBIiA*    12/17/03  RH   CBIi
     *      - Use PRNTLOG file to only print list for PRD once at A1A
CBIjA*    12/19/03  HNK  CBIj
     *      - print OR660 detail report on LP10 for truck codes
     *        'MEAT-INSP', 'PRE-PICK' and 'CONTAINER'
     *      - Changed to use LP31 on 03-18-04. Per Tammy.
CBIkA*    01/07/04  MLB  CBIk
     *      - Add call to CK370CL. Print Ship Check List for all
     *        'flagged' customers.
     *      - Changed to use LP10 on 03-18-04. Per Tammy.
CBIlA*    02/24/03  MLB  CBIl - replaced by base code 510d
     *      - Add call to CHKIUSE to clear inuse flag in route
     *        header after alloc/build, pick/print are complete
     *        for regular routes. Added to support processing
     *        of routes from Batch.
CBImA*    07/19/04  HNK  CBIm
     *      - Temporarily change reports to print on LP10 instead of
     *        LP31.
     *        This was removed with CBIo
CBInA*    07/19/04  DAS  CBIn
     *      - Added call to DFPICK.
     *      - Mod 500a in base code
CBIoA*    07/22/04  HNK  CBIo
     *      - Change it back to LP31
     *      - No mod marks
CBIpA*    08/19/04  RH   CBIp
     *      - Add call to OR664CL to print Truck Pallet Detail
     *        for Compartment X only.
CBIqA*    10/05/04  RH   CBIq
     *      - Do not print any reports if truck code is "WILL-CALL"
     *        "SUD-SVC" or "DAMAGES" per 9-28-04 email.
CBIrA*    01/16/06  RH   CBIr
     *      - Change printer for PLST40CB from LP02 to LP11
     *      - Comment out call to PLST40CB for PRD.
CBIsA*    06/20/07  DAS  CBIs changed to match Client version was CBIa
     *        in our base code. CBIs on client.
     *      - Added call to OR637 to create ORDP piece seq# records.
     *      - Has been replace by base code 640a.
CBItA*    06/05/14  MLB  CBIt  P#01218
     *      - Revised program to call PS310CL and OR660CL *DETAIL for
     *        GWB warehouse. All orders for GWB are sent to TB as
     *        Will-Call orders. Per Keith S.
     *
CBI1A*    07/13/06  JDG-CBI
     *      - Stop printing second copy of Truck Pallet Detail
     *        Compartment 'X' only report (OR664CL-RIVIERA only).
     *
CBI2A*    05/08/08  JGD-CBI
     *      - Stop printing Truck Pallet Detail
     *        Compartment 'X' only report (OR664CL-RIVIERA only).
     *
CBI3A*    12/02/13  JGD-CBI
     *      - add SUDDEN-SERVICE to Truck Pallet Report logic.
     *
CBI4A*    07/23/14  CBI4-JGD
     *      - Change SUDDEN-SERVICE "Truck Pallet Detail" Report
     *        print outq from LP10 to PRTSUD.
     *
CBI5A*    02/02/16  CBI5-JGD
     *      - Stop printing Manager's Ship List ' report (per MarkE.)
     *
CBI6A*    11/26/16  CBI6-JCJ
     *      - Special override for Sudden-Service
     *
CBI7A*    02/17/16  CBI7-JCJ
     *      - reactivate CBI5. (per MarkE.)
     *
CBI8A*    08/08/03  HNK  CBI8
     *      - Disable printing OR660 detail report. Ref-Email 8.7.03
     *      - Print 2 copies of summary instead.
     *
CBI9A*    12/05/17  NLK  CBI9
     *      - Change Report title & Control Print File if RT 9998
     *        & WillCall.  Modify OR605 and OR660; New OR660PRP
     *        & OR660PCL then add print file in rp110cl.
CB1aA*    06/26/18  NLK  CB1a
     *      - CK370CL had incorrect printer hard coded
     *        Add read to Reports for CK375PR
CB1cA*    03/11/19  NLK  CB1c     2019009 RIV onl
     *      - Add logic to create 'Truck Pallet Detail' report
     *
510aA*----------------------------------------------------------------
510aA*  Client Custom Revisions: CityLine
510a *
CLDaA*    10/07/06  DAS  CLDa
     *      - Added call to OR638 to assign PIR seq#'s
CLDeA*    05/26/10  RBD  CLDe
     *      - Added call to OR637 to create ORDP piece seq# records.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRYaA*    03/16/11  RH   DRYa
     *      - Revised program to not print the following reports
     *        if RHTRUCK = "WHOLESALE". PS311.
DRYbA*    07/16/11  MLB  DRYb
     *      - Added call to OR690 to print Transaction Audit Report
     *        for all transactions.
     *      - Added DRYb to SVL mod.
DRYcA*    12/21/11  MLB  DRYc
     *      - Revised pgm to add locations, Miami, Los Angeles, San
     *        Francisco and Portland, OR to DRYb mod.
DRYdA*    05/16/13  JCJ  DRYd
     *      - Revised pgm to add locations, Las Vegas OR to DRYb mod.
DRYeA*    06/05/13  MLB  DRYe
     *      - Revised pgm to remove Portland from list of whse's
     *        that are printing the OR695 Trans. Audit Report. Per
     *        Hemant skype on 06/05/13 2:19 pm CT from on-site.
DRYfA*    06/18/13  MLB  DRYf
     *      - Revised pgm to remove Miami from list of whse's
     *        that are printing the OR695 Trans. Audit Report. Per
     *        Hemant skype on 06/18/13 3:23 pm CT from on-site.
DRYgA*    08/08/14  MLB  DRYg
     *      - Revised pgm to add location, Qzina Chicago to DRYb mod.
DRYhA*    08/20/14  MLB  DRYh
     *      - Revised pgm to add location, Qzina NJ to DRYb mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: European Imports
     *
EI  A*    02/08/06  MLB  EI
EI   *      - Revised program to run OR660 for both *DETAIL, *SUMMARY
EI   *        when processing will call orders.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: I-Supply
     *
ISYaA*    05/05/06  RH   ISYa
     *      - Call PT725CL to export Route Info.
ISYcA*    11/16/09  MLB  ISYc
     *      - Corrected variable used on call to PT725CL.
ISYd *    03/22/12  GJA  ISYd
     *      - Do not make call to PT725CL if will call route
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Julius Silvert
     *
JSLaA*    10/25/15  GJA  JSLa
     *      - Automatically print audit sheets
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Harbor Wholesale
     *
HAR A*    06/26/06  RMC  HAR
     *      - Call TAXR to export info to Harbor, Tax-Right.
HARaA*    12/04/06  RH   HARa
     *      - Skip phase 6 printing OR660, OR660T and OR665 for Harbor
HARbA*    12/17/06  JCJ  HARb
     *      - Added $pcmd to parm list of call to TAXR.
     *      - Retrieve $pcmd from options file with *TAXR.
HARcA*    03/12/07  JCJ  HARc
     *      - Added file TAXRCTL.  Will be used to control how program
     *      TAXR will br processed.
HARdA*    02/12/08  DAS  HARd  P#00004
     *      - Revised to call OR637 to create unique piece numbers
     *        for POD system.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: MJ Kellner
     *
MJK A*    03/12/08  MLB  MJK
     *      - Revised program to not print the following reports
     *        if $PRTE begins with 'I'. PS311, OR660 (Dtl,Sum),
     *        OR660T and OR665.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt
     *
CSPa *    03/09/18  NLK  CSPa
     *      - Skip rpts PS311, OR660, BIGPAL if Truck is 'ADD ON'.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: BFC Demo
BD  A*
BD  A*    10/06/10  RBD  BD
     *      - Added call to OR637 to create ORDP piece seq# records.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Silberman
     *
SLBa *    08/29/11  GJA  SLBa
     *      - Add to TAXR processing.
SLBb *    04/06/09  MLB  SLBb    (FDIa)
     *      - Add call to OR660TCL - Print Tote Report Summary
SLBc *    04/20/09  CWM  SLBc    (FDIb)
     *      - Add call to OR660TBCL - Print Tote Bundle Report.
SLBd *    05/04/09  MLB  SLBd    (FDIc)
     *      - Add call to OR660FDICL - Print Pallet Detail Bulk Picks.
SLBe *    04/23/10  RBD  SLBe    (FDId)
     *      - Add call to TB130 - Write TOTEBUND records.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Packers
PCKa F*    07/15/04 HNK PCKa
     F*     - Print CK365 report
PCKb F*    08/27/04 HNK PCKb
     F*     - Don't print OR660 report
PCKc F*    06/26/06 DAS PCKc
     F*     - Don't print OR660T report
PCKd F*    02/16/07 HNK PCKd
     F*     - Print CK365 for Willcalls.
PCKe F*    07/23/07 RH  PCKe
     F*     - Change to NOT print CK365 report, printed when trans is
     F*       complete in voice. Reverse PCKa and PCKd changes
     F*
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Wholesale
     *
CTW A*    10/22/08  JCJ  CTW
     *      - Add CTW to Taxr processing.
CTWaA*    06/23/09  JCJ  CTWa
     *      - Add Check Right processing.
CTWbA*    10/03/12  RBD  CTWb
     *      - Added call to OR660CLCTW to print Pallet Detail report
     *        for aisles 040 - 049.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Finkle
     *
FDI A*    02/06/09  JCJ  FDI
     *      - Add FDI to Taxr processing.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Indianhead Foodservice (IFD)
     *
IFD A*    02/05/09  MLB  IFD
     *      - Added call to OR690 to print Transaction Audit Report
     *        for all transactions.
IFDaA*    04/08/09  MLB  IFDa
     *      - Commented out call to OR690 - Transaction Audit Report
     *        per email from Deb K. on 04/08/09.
IFDbA*    08/05/09  MLB  IFDb
     *      - Added call to CK370CL to print Manager Ship List for
     *        only flagged customers in ORDH.
IFDcA*    08/07/09  MLB  IFDc
     *      - Revised program to remove call to OR660 *DETAIL per
     *        email from Deb K. dated 08/07/09.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval Foodservice (SVL)
     *
SVL A*    03/04/09  JCJ  SVL
     *      - Added call to OR690 to print Transaction Audit Report
     *        for all transactions.
SVLb *    01/23/14  RH   SVLb
     *      - Fix: merge SVLa mod below, fix to work for V6.40
SVLa *    05/10/12  GJA  SVLa
     *      - Remove call to OR690  .. just changed if not SAVAL
     *
     *----------------------------------------------------------------
EBL A*  Client Custom Revisions: Ellenbee Leggett  (EBL)
     *
EBL A*    08/31/09  RBD  EBL
     *      - Added call to OR637 to create ORDP piece seq# records.
EBLaA*    09/02/09  RBD  EBLa
     *      - Inactivated call to OR630B since Ellenbee does not have
     *        loader merge.
     *----------------------------------------------------------------
MATaA*  Client Custom Revisions: Mattingly   (MAT)
     *
MATaA*    09/10/09  JCJ  MAT
     *      - Added call to OR637 to create ORDP piece seq# records.
MATaA*    10/02/09  MLB  MATa
     *      - Added call to OR740CL to create goal time information
     *        export file.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dierks Waukesha
     *
DRKaA*    02/23/10  DAS  DRKa
     *      - Temp mod to force Letdowns (OPJITR = '1')
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Inter County Bakers
     *
ICBa *    07/09/12  GJA  ICBa
     *      - Added call to OR690 to print Transaction Audit Report
     *        for all transactions.
ICBb *    07/13/12  GJA  ICBb
     *      - Changed call to OR660 to only print summary.
ICBc *    08/16/12  GJA  ICBc  (remove ICBa)
     *      - Remove call to OR690 to print Transaction Audit Report
     *        for all transactions.
ICBd *    12/28/15  RH   ICBd
     *      - Added call to OR638 to assign PIR seq#'s like City Line
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cash-WA
     *
CWDaA*    03/06/12  JCJ  CWDa
     *      - Add call to OR630B
     *      - Add to taxrite processing
CWDbA*    03/16/12  JCJ  CWDb
     *      - Add call to TB130 - Write TOTEBUND records.
CWDcA*    03/19/12  LMC  CWDc
     *      - Added call to TOTE for export of file for photo link.
CWDdA*    04/19/12  LMC  CWDd
     *      - Removed call to TOTE for export of file for photo link.
     *      - This is being moved to VOSELECT.
     *----------------------------------------------------------------
     *  Client Custom Revisions: West Side Foods
WST1A*    09/14/99  DAS  WST1
     *      - Skipped call to report OR660 at Tom's request.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kelly's Foods
     *
KFS A*    10/01/12  MLB  KFS
     *      - Added call to OR690 to print Transaction Audit Report
     *        for all transactions.
     *      - Added KFS to SVL mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Sofo Foods
     *
SOF A*    05/06/15  MLB  SOF
     *      - Added call to OR690 to print Transaction Audit Report
     *        for all transactions.
     *      - Added SOF to SVL mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Y.hata
     *
YHT A*    02/07/17  MLB  YHT
     *      - Revised pgm to not print OR660 (Det/Sum) Report3
     *        Per Glenn L. phone call 02.07.2017.
YHTaA*    08/01/17  MLB  YHTa
     *      - Revised pgm to print OR660 (Det/Sum) Report for all
     *        routes except routes that begin with Ixxxx.
     *        Per Glenn L. phone call 08.01.2017.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: A&D Foods
     *
ADF A*    11/30/17  MLB  ADF
     *      - Added call to OR690 to print Transaction Audit Report
     *        for all transactions.
     *      - Added ADF to SVL mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: S Bertram
     *
SBR A*    02/08/18  MLB  SBR
     *      - Added call to OR690 to print Transaction Audit Report
     *        for all transactions.
     *      - Added SBR to SVL mod.
     *
SBRa *    08/23/18  GJA  SBRa
     *      - Remove SBR per Abraham
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Merit Foods
     *
MRT A*    11/15/18  MLB  MRT
     *      - Added call to OR690 to print Transaction Audit Report
     *        for all transactions.
     *      - Added MRT to SVL mod.
     *
     *----------------------------------------------------------------
     *
     *  Notes
     *
     *    - The screen for this program must be compiled with
     *      defer write equal to *NO.
     *
     *----------------------------------------------------------------
     *
     *  Transfer notes
     *
     *    - Currently all transfer and POS orders are picked.  The
     *      program is not set up to handle one route out of many
     *      like it does for customer orders.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 30   Field input error (reverse display)
HARc *  78        Error on write
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     For605fm   cf   e             workstn usropn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fbatctl    uf a e           k disk
     Frtehed    uf   e           k disk
     Frtehed3   if   e           k disk
     F                                     rename(rhrec:rhrec3)
     Ftordh3    uf   e           k disk
223 AFtruckh    if   e           k disk
     Ftordd     if   e           k disk
414aAFoptions   if   e           k disk    usropn
CBIhAFoptionz   if   e           k disk    usropn
413 AFreports   if   e           k disk
CBIi Fprntlog   uf a e           k disk
     Fordh      uf a e           k disk
     Fordd      o  a e           k disk
650xAF*bfcdbgflg if   e           k disk    usropn
650bAFbfcdebug  o    e           k disk
415 AFrtetrck   o  a e           k disk
HARcAFtaxrctl   o    e             disk
CTWaAFckrctl    o    e             disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
CBI6AD a80             s              1    dim(80)
     D tcod            s              8    dim(7) ctdata perrcd(1)
     D tdsc            s             51    dim(7) alt(tcod)
CBI6AD ovrprt          s             80    dim(2) ctdata perrcd(1)
500dA*----------------------------------------------------------------
500dA*  Customer id
500dA*
     D @getcl          c                   const('GETCLIENT')
500dA*
510fM /COPY QCOPYSRC,ID#ISUPPLY
HAR A*
510fM /COPY QCOPYSRC,ID#HARBOR
510fM /COPY QCOPYSRC,ID#CITYLIN
510fMD/COPY QCOPYSRC,ID#EI
510fMD/COPY QCOPYSRC,ID#CHENEY
CBItAD/COPY QCOPYSRC,ID#CHENEYG
CBIqA /copy qcopysrc,id#cheneyo
CBIqA /copy qcopysrc,id#cheneyp
CBI1A /copy qcopysrc,id#cheneyr
510fMD/COPY QCOPYSRC,ID#PACKERS
MJK A /COPY QCOPYSRC,ID#MJKELLN
CTW A /copy qcopysrc,id#citywho
FDI A /copy qcopysrc,id#finkle
IFD AD/COPY QCOPYSRC,ID#IFD
SVL AD/COPY QCOPYSRC,ID#saval
EBL A /copy qcopysrc,id#ellenbe
MAT A /copy qcopysrc,id#matt
DRKaA /copy qcopysrc,id#dierks
BD  A /copy qcopysrc,id#bfcdemo
DRYaA /COPY QCOPYSRC,ID#DAIRYLA
DRYbA /copy qcopysrc,id#dryhano
DRYcA /copy qcopysrc,id#drymia
DRYcA /copy qcopysrc,id#dryla
DRYcA /copy qcopysrc,id#drysf
DRYcA /copy qcopysrc,id#dryport
DRYdA /copy qcopysrc,id#drylv
DRYgA /copy qcopysrc,id#dryqchi
DRYhA /copy qcopysrc,id#dryqnj
SLBaA /copy qcopysrc,id#silberm
CWDaA /copy qcopysrc,id#cashwa
ICBaA /copy qcopysrc,id#icb
WST1A /copy qcopysrc,id#westsid
KFS A /copy qcopysrc,id#kfs
HKW A /copy qcopysrc,id#hkw
JSLaA /copy qcopysrc,id#jsl
SOF A /copy qcopysrc,id#sofo
YHT A /copy qcopysrc,id#yhata
ADF A /copy qcopysrc,id#adf
SBR A /copy qcopysrc,id#sbr
CSPaA /copy qcopysrc,id#coastal
MRT A /copy qcopysrc,id#mrt
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @clcdr          c                   const('CLCDUR')
IFDbAD @WLCLL          C                   CONST('WILLCALL')
CBIjA*  Constants
CBIjAD @cntnr          c                   const('CONTAINER')
CBIjAD @prpck          c                   const('PRE-PICK')
CBIjAD @mtins          c                   const('MEAT-INSP')
CBIqAD @wlcllCBI       c                   const('WILL-CALL')
CBIqAD @sdsvc          c                   const('SUD-SVC')
CBIqAD @dmges          c                   const('DAMAGES')
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
415 AD  $cvdr1               133    140
415 AD  $cvvl1               141    145  0
415 AD  $cvdr2               146    153
415 AD  $cvvl2               154    158  0
415 AD  $cvdr3               159    166
415 AD  $cvvl3               167    171  0
415 AD  $cvdr4               172    179
415 AD  $cvvl4               180    184  0
500bA*
500bAD $lparm          ds
500bAD  $lcmd                  1      8
500bAD  $lprg                  9     18
500bAD  $luky                 19     68
500bAD  $lrtn                 69     76
500bAD  $lerm                 77    136
500bAD  $lmsg                 77     80
500bA*
500bA*   Redefine key
500bA*
500bAD  $lwhse                19     21  0
500bAD  $lrte                 22     26
500bAD  $lgrp1                27     27
500bAD  $lgrp2                28     28
500bA*
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  eritem                 1     15
     D                 ds
     D  $ec                    1      2p 0
414aA*----------------------------------------------------------------
414aA*  *GENPICK -  General picking options.
414aA*----------------------------------------------------------------
414aA*
414aA* Fields
414aA*
414aA*    OPERPT  -  Print exception (short) error report (Y,N).
414aA*    OPELBL  -  Print exception (short) labels (Y,N)
414aA*    OPRFWC  -  Using RF will call (Y,N).
414aA*    OPNRSC  -  Number of pallet sections (1-9).
414aA*    OPHPWC  -  Host pick Will Call (Y/N).
500bA*    OPMRGA  -  Merge Add-on order(s) with Open Routes.
500bA*    OPPLSQ  -  Pallet number sequence. 1=Unload seq, 2=Load seq
500bA*    OPEADJ  -  Close short labels without adjustment (Y,N).
500bA*    OPNOPK  -  Pick items without pick slot as bulk pick? (Y/N)
500bA*    OPJITR  -  Create JIT Letdown or JIT Replenishment
500bA*                 0=None. No replenishments are created.
500bA*                 1=Letdowns are created during Truck Builder
500bA*                   Pick/Print processing.
500bA*                 2=Priority Replenishments are created during
500bA*                   Truck Builder Pick/Print processing.
500bA*                 3=JIT Letdowns created when transaction is
500bA*                   checked out.
500bA*                 4=JIT Priority Replenishments created when
500bA*                   transaction is checked out.
414aA*
414aA* Data structure
414aA*
414aAD opdata          ds
414aAD  operpt                 1      1
414aAD  opelbl                 2      2
414aAD  oprfwc                 3      3
414aAD  opnrsc                 4      4  0
414aAD  ophpwc                 5      5
500bAD  opmrga                 6      6
500bAD  opplsq                 7      7
500bAD  opeadj                 8      8
500bAD  opnopk                 9      9
500bAD  opjitr                12     12
414aAD  optend               117    117
CBIh *----------------------------------------------------------------
CBIh *  *PICKLBL  -  Picking label options
CBIh *----------------------------------------------------------------
CBIh *
CBIh * Fields
CBIh *
CBIh *    OPCLVL  -  Qty level for combined labels.
CBIh *    OPCWRB  -  Print combined label warning before.
CBIh *    OPCWRA  -  Print combined label warning after.
CBIh *    OPUWRB  -  Print unit of measure warning before.
CBIh *    OPUWRA  -  Print unit of measure warning after.
CBIh *    OPTEXT  -  Text for last line of label.
CBIh *    OPERR   -  Error label ratio.
CBIh *    OPCWGT  -  Catch weight label ratio.
CBIh *    OPLPGM  -  Picking label program.
CBIh *    OPPDEV  -  Printer device.
CBIh *    OPPFRM  -  Printer form.
CBIh *
CBIh * Data structure
CBIh *
CBIh D opzdta          ds
CBIh D  opclvl                 1      3  0
CBIh D  opcwra                 4      4
CBIh D  opcwrb                 5      5
CBIh D  opuwra                 6      6
CBIh D  opuwrb                 7      7
CBIh D  optext                 8     50
CBIh D  operr                 51     52  0
CBIh D  opcwgt                53     54  0
CBIh D  oplpgm                55     64
CBIh D  oppdev                65     74
CBIh D  oppfrm                75     84
CBIh D  oppend               117    117
510bA*----------------------------------------------------------------
510bA*  *FEATURE  -  PIR Feature options.
510bA*----------------------------------------------------------------
510bA*
510bA* Fields
510bA*
510bA*    OPFEAT  -  PIR Installed feature.
510bA*                 1=Locator system installed.
510bA*                 2=Full system installed.
510bA*
510bA* Data structure
510bA*
510bAD opdat3          ds
510bAD  opfeat                 1      1
510bAD  op3end               117    117
HARbA*----------------------------------------------------------------
HARbA*  *TAXR  -  Tax Rite - Options
HARbA*----------------------------------------------------------------
HARbA*
HARbA* Fields
HARbA*
HARbA*    OPTXHS  -  Days to keep Tax-Right export data (1-999).
HARbA*    OPCMD1  -  Command for Tax-Right file processing.
HARbA*
HARbA* Data structure
HARbA*
HARbAD opdat4          ds
HARbAD  optxhs                 1      3  0
HARbAD  opcmd1                 4     11
HARbAD  op4end               117    117
CTWaA*----------------------------------------------------------------
CTWaA*  *CKR  -  Check Right - Options
CTWaA*----------------------------------------------------------------
CTWaA*
CTWaA* Fields
CTWaA*
CTWaA*    xPTXHS  -  Days to keep Check Right export data (1-999).
CTWaA*    xPCMD1  -  Command for Check Right file processing.
CTWaA*
CTWaA* Data structure
CTWaA*
CTWaAD opdat5          ds
CTWaAD  xptxhs                 1      3  0
CTWaAD  xpcmd1                 4     11
CTWaAD  op5end               117    117
700hA*----------------------------------------------------------------
700hA*  *LOADER  -  Loader options.
700hA*----------------------------------------------------------------
700hA*
700hA* Fields
700hA*
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
     D                sds
     D  #prog            *proc
650bAD  #pgm                   1     10
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
650bAD  #jobnbr              264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
650bAD  #curruser            358    367
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
     D $msgf           s             10
     D $otype          s              1
     D $plen           s              3  0
640dAD $pplid          s              7  0
     D $pstr           s             60
640dAD $ptrn           s              7  0
     D $pwhse          s              3  0
     D $retrn          s              8
     D $tpgm           s             10
     D $whsea          s              3
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D allrte          s              1
     D bflag           s              1
     D clear           s              5  0
     D comand          s              5  0
650bAD dbgflgExists    s               n
650bAD debug           s               n
     D dummy           s              1
     D enter           s              5  0
     D eofrh2          s              1
     D error           s              1
     D forevr          s              1
     D help            s              5  0
     D jobok           s              8
     D kycode          s                   like(opcode)
CBIiAD kyprtf          s              8
     D kystat          s                   like(rhstat)
CBIhAD kyzone          s              6
     D msgk            s              4  0
700h D psttm           s              6  0
700h D pentm           s              6  0
     D rolldn          s              5  0
     D rollup          s              5  0
     D rstat           s              1
650bAD saveValues      s                   like(bdvalues)
     D sclear          s              1
     D standa          s              1
     D stat            s              1
     D svdte1          s              8  0
     D svdte2          s              8  0
700gAD sv$icmd         s                   like($icmd)
     D svpgm1          s             10
     D svpgm2          s             10
     D svtim1          s              6  0
     D svtim2          s              6  0
     D t               s              2  0
720bAd tbEnhanced      s               n
720bAd tbType          s              1
     D wkprtf          s             10
710aAD $pgid           s              7  0
710aAD $jobqts         s             26
710aAD $jobquc         s             26

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

720bAd/copy qcopysrc,p.gettbtyp

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *PICK    - Pick new orders.
     *              *RESTART - Restart abnormally ended batch.
     *      $PCMD2  *ALOCBLD - Allocate and build
     *              *PCKPRNT - Pick and print
     *              *REBUILD - Rebuild
     *              *ALL     - Do all phases without pausing after build.
     *      $PTYPE  *PICK    - Pick normal customer orders (all routes)
     *              *PICK1   - Pick normal customer orders (one route)
     *              *TFRPICK - Pick transfer orders (all routes)
     *              *TFRPCK1 - Pick transfer orders (one route)
404 D*              *POSPICK - Pick POS orders (all routes)
404 D*              *POSPCK1 - Pick POS orders (one route)
404 M*              *WCPICK  - Pick will call orders (all routes)
404 M*              *WCPICK1 - Pick will call orders (one route)
     *      $PJTYP  0 - Batch
     *              1 - Interactive
     *      $PWHS   Warehouse
     *      $PBAT   Batch number for *RESTART.
     *      $PSTAT  Status for *RESTART.
     *      $PRTID  Route for *RESTART.
     *      $PORD   Order number for *RESTART.
     *      $PRWHS  Receiving warehouse for *TFRPICK.
     *      $PTRTE  Route for *TFRPICK.
     *
     *    Returned Parameters
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *      $PMSG   - Message ID.
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pcmd2            8
     C                   parm                    $ptype            8
     C                   parm                    $pjtyp            1
     C                   parm                    $pwhs            15 5
     C                   parm                    $pbat             7 0
     C                   parm                    $pstat            1
     C                   parm                    $prtid            5
     C                   parm                    $pord             7 0
     C                   parm                    $prwhs            3 0
     C                   parm                    $ptrte            5
     C                   parm                    $prtn             8
223 AC                   parm                    $pmsg             4
223 AC                   parm                    $pprg            10
710aMC                   parm                    $pgidx            7 0
710aMC                   parm                    $jobqtsx         26
710aMC                   parm                    $jobqucx         26
     *----------------------------------------------------------------
     *  Main line
     *
710aAC                   if        %parms > 14
710aAC                   eval      $pgid    = $pgidx
710aAC                   eval      $jobqts  = $jobqtsx
710aAC                   eval      $jobquc  = $jobqucx
710aAC                   endif
710aA*
     C                   eval      error = *off
     C                   eval      $prtn = *blanks

650bA /free
650bA
650xA  //if dbgflgExists;
650xA    //chain(e) (#pgm) bfcdbgflg;
650xA    //if %found(bfcdbgflg);
650xA      //debug = (bdfflag = 1);
650xA    //else;
650bA        debug = *off;
650xA    //endif;
650xA  //endif;
650bA
650bA    if debug;
650bA      exsr WrtDebugParms;
650bA    endif;
650bA
650bA /end-free

     *
     * Get out if a valid command wasn't sent to us.
     *
     C                   if        $pcmd <> '*PICK   '  and
     C                             $pcmd <> '*RESTART'
     C                   eval      $prtn = '*ERROR  '
650bAC                   eval      bdvalues = 'Invalid command: ' + $pcmd
650bAC                   exsr      WrtDebugError
     C                   goto      endpgm
     C                   endif
223 A*
223 A* Get out if invalid truck number
223 A*
223 AC     keyrh         chain(n)  rtehed                             79
223 AC                   if        *in79
223 AC                   eval      rhtruk = *blanks
414bAC                   eval      rhpbat = *zeros
223 AC                   endif
414bAC                   if        $pcmd <> '*RESTART'
414bAC                   eval      $pbat = rhpbat
414bAC                   endif
223 AC     keyth         chain     truckh                             79
223 AC                   if        *in79
510dAC                   if        $pjtyp = *on
223 AC                   exsr      zm2001
510dAC                   endif
223 AC                   eval      $prtn = '*PGMQ   '
650bAC                   eval      bdvalues = 'Invalid truck: ' + rhtruk
650bAC                   exsr      WrtDebugError
223 AC                   goto      endpgm
223 AC                   endif
     *
     * Go and pick the orders.
     *
     C                   exsr      pick
     C                   eval      $prtn = $retrn
     *
     * If error occured during picking display error screen.
     *
     C                   if        $retrn = '*ERROR  '  and
     C                             $pjtyp = *on
     C                   eval      #msgk = $msgid
     C                   exsr      zmqmsg
     C                   exsr      zmdmsg
     C                   eval      *in98 = *on
     C                   exfmt     screen2
     C                   endif
     *
     * End of the picking process.
     *
     C     endpgm        tag
510dA*
510dA* If errors occured during alloc/build or pick/print
510dA*  then clear inuse flag.
510dAC                   if        $prtn = '*ERROR  '  or
510dAC                             $prtn = '*PGMQ   '
650bAC                   eval      bdvalues = 'Pick error occured'
650bAC                   exsr      WrtDebugError
510dAC                   if        $otype = ' '
650aAC                   eval      $icmd = '*CLEAR'
510dAC                   exsr      zziuse
510dAC                   endif
510dAC                   endif
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
     C                   z-add     $pwhs         $pwhse
     C                   eval      forevr = *on
650bA /free
650xA  //open(e) bfcdbgflg;
650xA  //if %error;
650xA    //dbgflgExists = *off;
650xA  //else;
650xA    //dbgflgExists = *on;
650xA  //endif;
650bA /end-free
500dA*
500dA* Get client id.
500dA*
500dAC                   call      @getcl
500dAC                   parm                    client           10
640bAC                   parm                    clientloc        10
510bA*
520cDC*                  eval      opcode = '*FEATURE'
520cMC                   eval      kycode = '*FEATURE'
510dAC                   open      options
510bAC     keyop         chain     options                            79
510bAC                   if        *in79
510bAC                   eval      opfeat = '2'
510bAC                   else
510bAC                   eval      opdat3 = opdata
510bAC                   endif
510bAC                   if        opfeat = '3'
510bAC                   eval      standa = *on
510bAC                   else
510bAC                   eval      standa = *off
510bAC                   endif
510bA*
     *
     *   Get screen heading and open display file if this program
     *   is being run interactively.
     *
     C                   if        $pjtyp = *on
     *
     C                   eval      t = 1
     C                   eval      $pstr = *blanks
     C                   eval      $plen = 50
     C     $ptype        lookup    tcod(t)                                50
     C                   if        t = 0
     C                   move      tdsc(1)       $pstr
     C                   else
     C                   move      tdsc(t)       $pstr
     C                   endif
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         w1hed
     *
     C                   open      or605fm
     C                   endif
     *
     *   Initialize order type.
     *
     C                   select
     C                   when      $ptype = '*PICK   '  or
     C                             $ptype = '*PICK1  '
     C                   eval      $otype = ' '
     C                   when      $ptype = '*TFRPICK'  or
     C                             $ptype = '*TFRPCK1'
     C                   eval      $otype = 'T'
404 D*          $PTYPE    WHEQ '*POSPICK'
404 D*          $PTYPE    OREQ '*POSPCK1'
404 D*                    MOVE 'P'       $OTYPE
404 MC                   when      $ptype = '*WCPICK '  or
404 MC                             $ptype = '*WCPICK1'
404 MC                   eval      $otype = 'W'
415aD**                   OPEN OPTIONS
414dD**
414dD**   Get general picking options from options file.
414dD**
414dD**                   MOVE '*GENPICK'KYCODE
414dD**         KEYOP     CHAINOPTIONS              79
414dD**         *IN79     IFEQ *ON
414dD**                   MOVE 'Y'       OPERPT
414dD**                   MOVE 'N'       OPELBL
414dD**                   MOVE '1'       OPNRSC
414dD**                   MOVE 'N'       OPHPWC
414dD**                   ENDIF
     C                   endsl
HARbA*
HARbA*    Get tax rite file processing command from options file.
HARbA*
HARbAC                   if        client = 'HARBOR'
CTW AC                             or client = citywholesale
FDI AC                             or client = finkle
SLBaAC                             or client = silberman
CWDaAC                             or client = cashwa
CWDaAC                             and clientloc = cashwakearney
HARbAC                   eval      kycode = '*TAXR   '
HARbAC     keyop         chain     options                            79
HARbAC                   if        *in79
HARbAC                   move      '*NONE  '     opcmd1
HARbAC                   else
HARbAC                   eval      opdat4 = opdata
HARbAC                   endif
HARbAC                   endif
CTWaA*
CTWaA*    Get tax rite file processing command from options file.
CTWaA*
CTWaAC                   if        client = citywholesale
CTWaAC                   eval      kycode = '*CKR    '
CTWaAC     keyop         chain     options
CTWaAC                   if        not %found(options)
CTWaAC                   move      '*NONE  '     xpcmd1
CTWaAC                   else
CTWaAC                   eval      opdat5 = opdata
CTWaAC                   endif
CTWaAC                   endif
700hA*
700hA*   Get *LOADER options record.
700hA*
700hAC                   eval      kycode = '*LOADER '
700hAC     keyop         chain     options
700hAC                   if        not %found(options)
700hAC                   eval      opaddo = 'N'
700hAC                   eval      opsttm = 0
700hAC                   eval      opentm = 0
700hAC                   else
700hAC                   eval      opdat6 = opdata
700hAC                   endif
700hA*
414dA*
414dA*    Get general picking options from options file.
414dA*
510dD***                  OPEN OPTIONS
414dAC                   eval      kycode = '*GENPICK'
414dAC     keyop         chain     options                            79
414dAC                   if        *in79
414dAC                   eval      operpt = 'Y'
414dAC                   eval      opelbl = 'N'
414dAC                   move      '1'           opnrsc
414dAC                   eval      ophpwc = 'N'
500bAC                   eval      opjitr = '2'
414dAC                   endif
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
     *   Are we working with all routes or one route?
     *
     C                   select
     C                   when      $ptype = '*PICK   '  or
     C                             $ptype = '*TFRPICK'  or
404 D*          $PTYPE    OREQ '*POSPICK'
404 MC                             $ptype = '*WCPICK '
     C                   eval      allrte = *on
     C                   when      $ptype = '*PICK1  '  or
     C                             $ptype = '*TFRPCK1'  or
404 D*          $PTYPE    OREQ '*POSPCK1'
404 MC                             $ptype = '*WCPICK1'
     C                   eval      allrte = *off
     C                   endsl
     *
     *   Initialize special keys
     *
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125
     *
     *   Initialize message handling
     *
     C                   if        $pjtyp = *on
     C                   exsr      zmimsg
     C                   endif
     *
     *  Initialize variables
     *
     C                   eval      $retrn = *blanks
414bAC                   eval      jobok = *blanks
     C                   eval      error = *off
     *
     *   Define key for route header file by stat/route (RTEHED3)
     *
     C     keyrh3        klist
     C                   kfld                    $pwhse
     C                   kfld                    kystat
     C                   kfld                    $otype
     C                   kfld                    $prtid
     *
     *   Define key for route header file by stat/type (RTEHED3)
     *
     C     keyrtp        klist
     C                   kfld                    $pwhse
     C                   kfld                    kystat
     C                   kfld                    $otype
     *
     *   Define key for route header file (RTEHED)
     *
     C     keyrh         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
223 A*
223 A*   Define key for truck header file (TRUCKH)
223 A*
223 AC     keyth         klist
223 AC                   kfld                    $pwhse
223 AC                   kfld                    rhtruk
     *
     *  Define partial key for transfer header file.
     *
     C     keytoh        klist
     C                   kfld                    $pwhse
     *
     *  Define partial key for transfer detail file.
     *
     C     keytod        klist
     C                   kfld                    tohnum
414aA*
414aA*  Define partial key for OPTIONS file.
414aA*
414aAC     keyop         klist
414aAC                   kfld                    $pwhse
414aAC                   kfld                    kycode
CBIhA*
CBIhA*  Define partial key for OPTIONZ file.
CBIhA*
CBIhAC     keyopz        klist
CBIhAC                   kfld                    kycode
CBIhAC                   kfld                    $pwhse
CBIhAC                   kfld                    rhtruk
CBIhAC                   kfld                    kyzone
     *
     *  Define key for ORDH file.
     *
     C     keyoh         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pord
413 A*
413 AC     rpkey         klist
413 AC                   kfld                    wkprtf
CBIiA*   Key for PRNTLOG
CBIiAC     keyprt        klist
CBIiAC                   kfld                    rhrtid
CBIiAC                   kfld                    kyprtf
     *
     *   Fool the compiler.
     *
     C                   eval      dummy = *blanks
     C                   if        dummy <> *blanks
     C     keyoh         chain     ordh                               79
     C                   endif
720bMc*
720bMc*   Determine if using TruckBUilder Enhanced
720bMc*
720bA /free
720bA      GetTBType($pwhse: $prtid: tbType);
720bA      if tbType = 'E';
720bA        tbEnhanced = *on;
720bA      else;
720ba        tbEnhanced = *off;
720ba      endif;
720bA /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CPYORD  Copy authorized orders to picking order files.
     *
     C     cpyord        begsr
     *
     C     keytoh        setll     tordh3
     C                   dou       forevr <> forevr
     C     keytoh        reade     tordh3                                 79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *      Only select authorized records for the receiving warehouse.
     *
     C                   if        tohsts <> '3'  or
     C                             tohtwh <> $prwhs
     C                   iter
     C                   endif
     *
     *      Add record to picking header file.
     *
     C                   clear                   ohrec
     C                   eval      ohwhse = tohfwh
     C                   call      'PIRORD#'
     C                   parm      ohwhse        $owhse            3 0
     C     ohord         parm      0             $oord             7 0
     C                   eval      ohorig = 'T'
     C                   eval      ohtype = 'T'
     C                   eval      ohcord = tohnum
     C                   eval      ohrte = $ptrte
     C                   eval      ohstop = tohstp
     C                   eval      ohstat = 'O'
     C                   write     ohrec
     *
     *      Copy detail records to picking detail file.
     *
     C     keytod        setll     tordd
     C                   dou       forevr <> forevr
     C     keytod        reade     tordd                                  78
     C                   if        *in78
     C                   leave
     C                   endif
     *
     *         Add record to picking detail file.
     *
     C                   clear                   odrec
     C                   eval      odwhse = ohwhse
     C                   eval      odord = ohord
     C                   eval      odseq = todseq
     C                   eval      oditem = toditm
     C                   eval      odqor1 = todqo1
     C                   eval      odqor2 = todqo2
     C                   eval      odqor3 = todqo3
     C                   eval      odstat = 'O'
     C                   write     odrec
     C                   enddo
     *
     *      Update status of transfer order.
     *
     C                   eval      tohsts = '4'
     C                   update    tohrec
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PICK    Pick new customer orders.
     *
     C     pick          begsr
     *
     C                   eval      bflag = *off
     C                   eval      $retrn = *blanks
     *
     *     Phase 0 - Copy authorized transfer orders to picking files.
     *               This needs to be done before anything else.
     *
     C     phase0        tag
     C                   if        $pcmd2 = '*ALOCBLD'  or
404 AC                             $pcmd2 = '*ALL    '
     C                   eval      stat = *off
     C                   exsr      updctl
     C                   if        $ptype = '*TFRPICK'
     C                   if        $pjtyp = *on
     C                   eval      w1rte = *blanks
     C                   write     screen1
     C                   exsr      zm20
     C                   endif
     C                   exsr      cpyord
     C                   endif
     C                   endif
     *
     *   Process orders one route at a time.
     *
     C                   if        $pcmd2 = '*ALOCBLD'  or
404 AC                             $pcmd2 = '*ALL    '
     C                   eval      kystat = *on
     C                   endif
     C                   if        $pcmd2 = '*REBUILD'  or
     C                             $pcmd2 = '*PCKPRNT'
     C                   eval      kystat = '3'
     C                   endif
     C                   if        $pcmd = '*PICK   '
     C                   if        allrte = *on
     C     keyrtp        setll     rtehed3
     C                   else
     C     keyrh3        setll     rtehed3
     C                   endif
     C                   endif
     *
     C                   eval      eofrh2 = *off
     *
     C                   dou       eofrh2 = *on  or
     C                             $retrn = '*ERROR  '  or
     C                             $retrn = '*ENDBLD '  or
     C                             $retrn = '*DONE   '
     *
     C                   if        $pcmd = '*PICK   '
     C                   if        allrte = *on
     C     keyrtp        reade     rtehed3                                79
     C                   else
     C     keyrh3        reade     rtehed3                                79
     C                   endif
     C                   if        *in79
     C                   leave
     C                   endif
     C                   eval      $prtid = rhrtid
     C                   endif
     *
     *      Display informational screen.
     *
     C                   eval      w1rte = rhrte
     C                   if        $pjtyp = *on
     C                   write     screen1
     C                   endif
     *
     *      If we are picking new orders then start at phase 1.
     *
     C                   if        $pcmd = '*PICK   '
     C     $pcmd2        cabeq     '*ALL    '    phase1
     C     $pcmd2        cabeq     '*ALOCBLD'    phase1
     C     $pcmd2        cabeq     '*REBUILD'    phase2
     C     $pcmd2        cabeq     '*PCKPRNT'    phase3
     C                   endif
     *
     *      Otherwise, skip to the phase where the restarted batch
     *      left off.
     *
     C     $pstat        cabeq     '1'           phase1
     C     $pstat        cabeq     '2'           phase2
     C     $pstat        cabeq     '3'           phase3
     C     $pstat        cabeq     '4'           phase4
     C     $pstat        cabeq     '5'           phase5
     C     $pstat        cabeq     '6'           phase6
     *
     *     Phase 1 - Allocate items from slots.
     *
     C     phase1        tag
415 AC                   if        $pcmd2 = '*ALOCBLD'
415 AC                   eval      $tpgm = $pcmd2
415 AC                   exsr      zzstrt
415 AC                   endif
510b C                   if        standa = *on
510bAC                   eval      $tpgm = 'OR610P'
510bAC                   else
415 AC                   eval      $tpgm = 'OR610'
510bAC                   endif
415 AC                   exsr      zzstrt
     C                   eval      stat = *on
     C                   exsr      updctl
     C                   if        $pjtyp = *on
     C                   exsr      zm21
     C                   endif
510b C                   if        standa = *on
520eAC                   call      'OR610B'
520eAC                   parm                    $pcmd
520eAC                   parm                    #prog
520eAC                   parm                    $pbat
520eAC                   parm                    $pwhse
520eAC                   parm                    rhtruk
520eAC                   parm                    $otype
520eAC                   parm                    rhrtid
520eaC                   parm                    rhrte
520eAC                   parm                    $pord
520eAC                   parm                    $retrn
520eAC                   parm                    $msgid
510bAC                   call      'OR610P'
510b C                   parm                    $pcmd
510b C                   parm                    #prog
510b C                   parm                    $pbat
510b C                   parm                    $pwhse
510b C                   parm                    rhtruk
510b C                   parm                    $otype
510b C                   parm                    rhrtid
510b C                   parm                    rhrte
510b C                   parm                    $pord
510b C                   parm                    $retrn
510b C                   parm                    $msgid            4
510bAC                   eval      $tpgm = 'OR610P'
510bAC                   else
520eAC                   call      'OR610B2'
520eAC                   parm                    $pcmd
520eAC                   parm                    #prog
520eAC                   parm                    $pbat
520eAC                   parm                    $pwhse
520eAC                   parm                    rhtruk
520eAC                   parm                    $otype
520eAC                   parm                    rhrtid
520eAC                   parm                    rhrte
520eAC                   parm                    $pord
520eAC                   parm                    $retrn
520eAC                   parm                    $msgid
     C                   call      'OR610'
     C                   parm                    $pcmd
     C                   parm                    #prog
     C                   parm                    $pbat
     C                   parm                    $pwhse
     C                   parm                    rhtruk
     C                   parm                    $otype
     C                   parm                    rhrtid
     C                   parm                    rhrte
     C                   parm                    $pord
     C                   parm                    $retrn
     C                   parm                    $msgid
415 AC                   eval      $tpgm = 'OR610'
510bAC                   endif
415 AC                   exsr      zzend
     C     $retrn        cabeq     '*ERROR  '    enddo1
     *
     *     Phase 2 - Build pallets.
     *
     C     phase2        tag
415 AC                   eval      $tpgm = 'OR620'
415 AC                   exsr      zzstrt
     C                   eval      stat = '2'
     C                   exsr      updctl
     C                   if        $pjtyp = *on
     C                   exsr      zm22
     C                   endif
700iA*
700iA*      Prior to running OR620 program in the CL, a call to DFPICK
700iA*      immediately folowing call to program OR615 has been added.
700iA*
     C                   call      'OR620CL'
     C                   parm                    $pbat
     C                   parm                    $pwhse
     C                   parm                    rhtruk
     C                   parm                    $otype
     C                   parm                    rhrtid
     C                   parm                    $retrn
415 AC                   eval      $tpgm = 'OR620'
415 AC                   exsr      zzend
510fD**         $PCMD2    IFEQ '*ALOCBLD'
510fD**                   MOVEL$PCMD2    $TPGM     P
510fD**                   EXSR ZZEND
510fD**                   ENDIF
416 A*
416 A*    Accumulate totals by compartment.
416 AC                   if        $pcmd2 = '*ALOCBLD'  or
416 AC                             $pcmd2 = '*REBUILD'  or
416 AC                             $pcmd2 = '*ALL    '
416 AC                   eval      $tpgm = 'OR626'
416 AC                   exsr      zzstrt
416 AC                   call      'OR626'
416 AC                   parm                    $pcmd2
416 AC                   parm                    $pbat
416 AC                   parm                    $pwhse
416 AC                   parm                    $otype
416 AC                   parm                    rhrtid
416 AC                   parm                    rhtruk
640dAC                   parm      0             $pplid
640dAC                   parm      0             $ptrn
416 AC                   eval      $tpgm = 'OR626'
416 AC                   exsr      zzend
416 AC                   endif
416aA*
416aA*    Assign dock doors to built route.
416aAC                   if        $pcmd2 = '*ALOCBLD'  and
416bAC                             $otype = ' '  or
416aAC                             $pcmd2 = '*REBUILD'  and
416bAC                             $otype = ' '  or
416aAC                             $pcmd2 = '*ALL    '  and
416bAC                             $otype = ' '
416aAC                   eval      $tpgm = 'DK130'
416aAC                   exsr      zzstrt
416aAC                   call      'DK130'
416aAC                   parm                    $pcmd2
416aAC                   parm                    $pbat
416aAC                   parm                    $pwhse
416aAC                   parm                    $otype
416aAC                   parm                    rhrtid
416aAC                   parm                    rhtruk
416aAC                   eval      $tpgm = 'DK130'
416aAC                   exsr      zzend
416aAC                   endif
     *
     *       Mark route as 'built'.
     *
510fAC                   if        $pcmd2 = '*ALOCBLD'
510fAC                   eval      $tpgm = $pcmd2
510fAC                   exsr      zzend
510fAC                   endif
     C                   eval      rstat = '3'
     C                   exsr      updrte
CBIhAc                   if        client = cheney
CBIh C                   if        $pcmd2 = '*ALOCBLD'
CBIiA*    Check if already printed for route id.
CBIhAC                   eval      kyprtf = 'PLST40PC'
CBIiAC     keyprt        chain     prntlog                            77
CBIiAC                   if        *in77
CBIhA*
CBIhA*    Get PICKLBL options from OPTIONZ'file.
CBIhAC                   open      optionz
CBIhA*
CBIhAC                   eval      kycode = '*PICKLBL'
CBIhAC                   movel     'PRD'         kyzone
CBIhAC     keyopz        chain     optionz                            79
CBIhAC                   if        *in79
CBIhAC                   eval      opclvl = 1
CBIhAC                   eval      opcwra = 'N'
CBIhAC                   eval      opcwrb = 'N'
CBIhAC                   eval      opuwra = 'N'
CBIhAC                   eval      opuwrb = 'N'
CBIhAC                   eval      optext = *blanks
CBIhAC                   eval      operr = 0
CBIhAC                   eval      opcwgt = 0
CBIhAC                   movel     'PLBL40'      oplpgm
CBIhAC                   eval      oppdev = *blanks
CBIhAC                   movel     'LP02'        oppdev
CBIhAC                   movel     '*STD'        oppfrm
CBIhAC                   endif
CBIhAC                   eval      oppdev = *blanks
CBIrD**                   MOVEL'LP02'    OPPDEV
CBIrMC                   movel     'LP11'        oppdev
CBIqAC                   if        rhtruk <> @wlcllCBI  and
CBIqAC                             rhtruk <> @sdsvc  and
CBIqAC                             rhtruk <> @dmges
CBIrD***                  CALL 'PLST40CB'
CBIrD*                    PARM           $PCMD
CBIrD*                    PARM           $PWHSE
CBIrD*                    PARM           RHRTID
CBIrD*                    PARM 'P'       COMP    1
CBIrD*                    PARM 'PRD   '  ZONE    6
CBIrD*                    PARM 1         PGEN    10
CBIrD*                    PARM 'PRD   '  PSZON   6
CBIrD*                    PARM           RHTRUK
CBIhD**                   PARM           $OTYPE
CBIrD*                    PARM           RHRTE
CBIrD*                    PARM           OPZDTA
CBIrD*                    PARM           $TRN    70
CBIqAC                   endif
CBIhAC                   eval      $tpgm = 'PLST40CB'
CBIiAC                   eval      $cvcmd = '*CURCMD '
CBIiAC                   call      @cvtdt
CBIiAC                   parm                    $cvtdt
CBIiAC                   eval      prdate = $cvd8o
CBIiAC                   time                    prtime
CBIhAC                   eval      prrtid = rhrtid
CBIhAC                   eval      prprtf = kyprtf
CBIhAC                   eval      prpctr = 1
CBIhAC                   write     prrec
CBIiAC                   else
CBIhAC                   unlock    prntlog
CBIiAC                   endif
CBIhAC                   endif
CBIhAc                   endif
     C                   if        $pcmd2 = '*ALOCBLD'  or
     C                             $pcmd2 = '*REBUILD'
     C                   eval      $retrn = '*ENDBLD '
     C                   goto      enddo1
     C                   endif
     *
     *     Phase 3 - Pick stock from slots.
     *
     C     phase3        tag
720 A *
720 A *   If Drag Drop 2 then requence Pallets before Print
720 A *
720bMc                   if        tbEnhanced
720 AC                   call      'OR627'
720 AC                   parm                    $pwhse
720 AC                   parm                    rhrtid
720 Ac                   endif
720 A *
730aA *   Set audit flag for orders
730aA *
730aAC                   monitor
730aAC                   call      'SETRTEAUD'
730aAC                   parm                    $pwhse
730aAC                   parm                    rhrtid
730aAC                   on-error
730aAC                   endmon
730aA *
415 AC                   if        $pcmd2 = '*PCKPRNT'
415 AC                   eval      $tpgm = $pcmd2
415 AC                   exsr      zzstrt
415 AC                   endif
510b C                   if        standa = *on
510bAC                   eval      $tpgm = 'OR630P'
510bAC                   else
415 AC                   eval      $tpgm = 'OR630'
510bAC                   endif
415 AC                   exsr      zzstrt
     C                   eval      stat = '3'
     C                   exsr      updctl
     C                   if        $pjtyp = *on
     C                   exsr      zm23
     C                   endif
510b C                   if        standa = *on
CWDaAC                   if        client = cashwa
CWDaAC                             and clientloc = cashwakearney
640cAC                   call      'OR630B'
640cAC                   parm                    $pwhse
640cAC                   parm                    rhrtid
640cAC                   parm                    rhtruk
CWDaAC                   endif
510bAC                   call      'OR630P'
510b C                   parm                    $pbat
510b C                   parm                    $pwhse
510b C                   parm                    $otype
510b C                   parm                    rhrte
510b C                   parm                    rhrtid
510b C                   parm                    rhtruk
510bAC                   else
EBLaAC                   if        client <> ellenbee
520dAC                   call      'OR630B'
520dAC                   parm                    $pwhse
520dAC                   parm                    rhrtid
520dAC                   parm                    rhtruk
EBLaAC                   endif
     C                   call      'OR630'
     C                   parm                    $pbat
     C                   parm                    $pwhse
     C                   parm                    $otype
     C                   parm                    rhrte
     C                   parm                    rhrtid
     C                   parm                    rhtruk
510bAC                   endif
500aAC                   call      'DFPICK'
500aAC                   parm                    $pwhse
500aAC                   parm                    rhrtid
510b C                   if        standa = *on
510bAC                   eval      $tpgm = 'OR630P'
510bAC                   else
415 AC                   eval      $tpgm = 'OR630'
510bAC                   endif
415 AC                   exsr      zzend
413aA*
413aA*       Assign pallet sections to items.
413aA*
413aAC                   if        $ptype = '*PICK   '  or
413aAC                             $ptype = '*PICK1  '  or
413aAC                             $ptype = '*WCPICK '  or
413aAC                             $ptype = '*WCPICK1'
415 AC                   eval      $tpgm = 'OR625'
415 AC                   exsr      zzstrt
413aAC                   call      'OR625'
413aAC                   parm                    $pbat
413aAC                   parm                    $pwhse
413aAC                   parm                    $otype
413aAC                   parm                    rhrtid
413aAC                   parm                    rhtruk
415 AC                   eval      $tpgm = 'OR625'
415 AC                   exsr      zzend
413aAC                   endif
520bA*
520bA*       Update TOTEHDR recs with Tran#'s.
520bA*
520bAC                   if        $ptype = '*PICK   '  or
520bAC                             $ptype = '*PICK1  '  or
520bAC                             $ptype = '*WCPICK '  or
520bAC                             $ptype = '*WCPICK1'
520bAC                   eval      $tpgm = 'OR635'
520bAC                   exsr      zzstrt
520bAC                   call      'OR635'
520bAC                   parm                    $pwhse
520bAC                   parm                    rhrtid
520bAC                   eval      $tpgm = 'OR635'
520bAC                   exsr      zzend
520bAC                   endif
510eA*
510eA*       Create ORDP piece seq# records.
510eA*
640aDC**                 if        client = cheney
640aDC**                           or client = harbor
640aDC**                           or client = ellenbee
640aDC**                           or client = mattfd
640aDC**                           or client = cityline
640aDC**                           or client = bfcdemo
510eAC                   if        $ptype = '*PICK   '  or
510eAC                             $ptype = '*PICK1  '  or
510eAC                             $ptype = '*WCPICK '  or
510eAC                             $ptype = '*WCPICK1'
510eAC                   eval      $tpgm = 'OR637'
510eAC                   exsr      zzstrt
510eAC                   call      'OR637'
510eAC                   parm                    $pwhse
510eAC                   parm                    rhrtid
510eAC                   eval      $tpgm = 'OR637'
510eAC                   exsr      zzend
510eAC                   endif
640aDC**                 endif
700eA*
700eA*       Call OR641 to generate & save 4 digit voice pallet IDs
700eA*
700eAC                   monitor
700eAC                   call      'OR641'
700fAC                   parm                    $pwhse
700fAC                   parm                    rhrtid
700eAC                   on-error
700eAC                   endmon
     *
520aA*       Delete any preexisting ORDAD recs for this route,
520aA*       then create ORDAD unique sscc18 recs.
520aA*
520aAC                   if        $ptype = '*PICK   '  or
520aAC                             $ptype = '*PICK1  '  or
520aAC                             $ptype = '*WCPICK '  or
520aAC                             $ptype = '*WCPICK1'
520aAC                   eval      $tpgm = 'OR639'
520aAC                   exsr      zzstrt
520aAC                   call      'OR639D'
520aAC                   parm                    $pwhse
520aAC                   parm                    rhrtid
520aA
520aAC                   call      'OR639'
520aAC                   parm                    $pwhse
520aAC                   parm                    rhrtid
520aAC                   eval      $tpgm = 'OR639'
520aAC                   exsr      zzend
520aAC                   endif
413aA*
510aA*       Assign PIR seq#'s
510aA*
CLDaAC                   if        client = cityln or
ICBdAC                             client = ICB
510aAC                   if        $ptype = '*PICK   '  or
510aAC                             $ptype = '*PICK1  '  or
510aAC                             $ptype = '*WCPICK '  or
510aAC                             $ptype = '*WCPICK1'
510aAC                   eval      $tpgm = 'OR638'
510aAC                   exsr      zzstrt
510aAC                   move      $pwhse        $whsea
510aAC                   call      'OR638'
510aAC                   parm                    $whsea
510aAC                   parm                    rhrtid
510aAC                   eval      $tpgm = 'OR638'
510aAC                   exsr      zzend
510aAC                   endif
CLDaAC                   endif
HAR A*
HAR A*
HAR A*       Send picking information to Tax-Right for Harbor
HAR A*
HAR AC                   select
HAR AC                   when      client = harbor
HAR AC                             and opcmd1 <> '*NONE  '
CTW AC                             or client = citywholesale
CTW AC                             and opcmd1 <> '*NONE  '
FDI AC                             or client = finkle
FDI AC                             and opcmd1 <> '*NONE  '
SLBaAC                             or client = silberman
SLBaAC                             and opcmd1 <> '*NONE  '
CWDaAC                             or client = cashwa
CWDaAC                             and opcmd1 <> '*NONE  '
HAR A*
HAR A*
HAR AC                   if        $ptype = '*PICK   '  or
HAR AC                             $ptype = '*PICK1  '  or
HAR AC                             $ptype = '*WCPICK '  or
HAR AC                             $ptype = '*WCPICK1'
HAR AC                   eval      $tpgm = 'TAXR '
HAR AC                   exsr      zzstrt
HAR A*
HARcAC                   eval      $txwhs = $pwhse
HARcAC                   eval      $txcmd = opcmd1
HARcAC                   eval      $txrti = rhrtid
HARcAC                   eval      $txrte = rhrte
HARcAC                   eval      $txtrn = *zeros
HARcAC                   write     trec                                 78
HARcA*
HAR AC                   call      'TAXR'
HAR AC                   parm                    $txwhs            3 0
HARbAC                   parm                    $txcmd            8
HAR AC                   parm                    $txrti            5
HAR AC                   parm                    $txrte            5
HAR AC                   parm      0             $txtrn            7 0
HAR A*
HAR AC                   eval      $tpgm = 'TAXR '
HAR AC                   exsr      zzend
HAR AC                   endif
HAR A*
HAR AC                   endsl
CTWaA*
CTWaA*       Send picking information to Check Right
CTWaA*
CTWaAC                   select
CTWaAC                   when      client = citywholesale
CTWaAC                             and xpcmd1 <> '*NONE  '
CTWaA*
CTWaA*
CTWaAC                   if        $ptype = '*PICK   '  or
CTWaAC                             $ptype = '*PICK1  '  or
CTWaAC                             $ptype = '*WCPICK '  or
CTWaAC                             $ptype = '*WCPICK1'
CTWaAC                   eval      $tpgm = 'CKR  '
CTWaAC                   exsr      zzstrt
CTWaA*
CTWaAC                   eval      $ckwhs = $pwhse
CTWaAC                   eval      $ckcmd = opcmd1
CTWaAC                   eval      $ckrti = rhrtid
CTWaAC                   eval      $ckrte = rhrte
CTWcAC                   eval      $cktrn = *zeros
CTWcAC                   write     crec                                 78
CTWaA*
CTWaAC                   call      'CKR '
CTWaAC                   parm                    $ckwhs
CTWaAC                   parm                    $ckcmd
CTWaAC                   parm                    $ckrti
CTWaAC                   parm                    $ckrte
CTWaAC                   parm      0             $cktrn
CTWaA*
CTWaAC                   eval      $tpgm = 'CKR  '
CTWaAC                   exsr      zzend
CTWaAC                   endif
CTWaA*
CTWaAC                   endsl
     *
610bA*       Call OR642 to create PRE slots for pre-pick routes.
     *
610bAC                   call      'OR642'
610cAC                   parm      '*CREATE'     $lcmd
610bAC                   parm                    $pwhse
610bAC                   parm                    rhrtid
700dA*
700dA*
700dA*       Call OR643 to create AMP slots for advanced merge pick
700dA*
700dAC                   call      'OR643'
700dAC                   parm      '*CREATE'     $lcmd
700dAC                   parm                    $pwhse
700dAC                   parm                    rhrtid
SLBeA*
SLBeAC                   if        client = silberman
CWDbAC                             or client = cashwa
SLBeAC                   call      'TB130'
SLBeAC                   parm                    $pwhse
SLBeAC                   parm                    rhrtid
SLBeAC                   parm                    rhrte
SLBeAC                   parm                    $retrn
SLBeAC                   endif
CWDdAc*                  if        client = cashwa and
CWDdAc*                            clientloc = cashwaKearney
CWDcA*
CWDcA*       Call TOTE to create export file for cashwa for Photo Link
CWDcA*
CWDdAC*                  call      'TOTE'
CWDdAC*                  parm                    $txwhs            3 0
CWDdAC*                  parm      '*CREATE'     $txcmd            8
CWDdAC*                  parm                    $txrti            5
CWDdAC*                  parm                    $txrte            5
CWDcA*       Call TOTE to send export file for cashwa for Photo Link
CWDcA*
CWDdAC*                  call      'TOTE'
CWDdAC*                  parm                    $txwhs            3 0
CWDdAC*                  parm      '*SEND  '     $txcmd            8
CWDdAC*                  parm                    $txrti            5
CWDdAC*                  parm                    $txrte            5
CWDdAc*                  endif
     *
     *       Mark route as 'Printed' even though it hasn't been printed.
     *         If something goes wrong during printing, it is easy to
     *         reprint.
     *
     C                   eval      rstat = '4'
     C                   exsr      updrte
     *
700hA*    If option OPADDO = Y call pgm to auto define add-on routes
700hAC                   if        opaddo = 'Y'
700hAC                             and rhprtt <> 0
700hAC                             and opsttm <> 0
700hAC                             and opentm <> 0
700hAC                   call      'TR875'
700hAC                   parm                    rhwhse
700hAC                   parm                    rhrte
700hAC                   parm                    rhrtid
700hAC                   parm                    rhprtt
700hAC                   parm      opsttm        psttm
700hAC                   parm      opentm        pentm
700hAC                   parm                    pRtn             10
700hAC                   endif
     *
     *     Phase 4 - Print labels.
     *
     C     phase4        tag
     C                   eval      stat = '4'
     C                   exsr      updctl
     C                   if        $pjtyp = *on
     C                   exsr      zm24
     C                   endif
720aAc*
720aAc*  If using TruckBuilder Enhanced,
720aAc*  then call process to generate unique SSCC18 labels for pallets
720aAc*
720bAc                   if        tbEnhanced
720aAc                   call      'OR630ADB'
720aAc                   parm                    $pWhse
720aAc                   parm                    rhrtid
720aAc                   endif
720aAc*
     C                   move      $pwhse        $whsea
414aAC                   if        ophpwc = 'N'  or
414aAC                             ophpwc = 'Y'  and
414aAC                             $otype <> 'W'
415 AC                   eval      $tpgm = 'OR640'
415 AC                   exsr      zzstrt
     C                   call      'OR640'
     C                   parm      '*PRINT  '    $xcmd             8
     C                   parm                    $whsea
     C                   parm                    rhrtid
     C                   parm                    rhrte
     C                   parm                    rhtruk
     C                   parm      '*ALL  '      $xszon            6
415 AC                   eval      $tpgm = 'OR640'
415 AC                   exsr      zzend
ISYaA*    Export Route Info.
ISYa C                   if        client = isupply and
ISYdAC                             rhtruk <> 'WILLCALL  '
ISYa C                   if        $pcmd = '*PICK   '
ISYAAC                   eval      $tpgm = 'PT725CL'
ISYa C                   exsr      zzstrt
ISYa C                   call      'PT725CL'
HAR  *ISYa                PARM           $WHSE
ISYbDC***********        parm                    $whsea
ISYcDC*                  parm                    $pwhse
ISYcMC                   parm      $pwhse        $ywhse            3 0
ISYa C                   parm                    rhrtid
ISYa C                   parm                    rhrte
ISYa C                   parm      ' '           $reex             1
ISYa C                   eval      $tpgm = 'PT725CL'
ISYa C                   exsr      zzend
ISYaAC                   endif
ISYaAC                   endif
MATaA*
MATaA*    Export Goal time information.
MATaAC                   if        client = Mattfoods
MATaA*
MATaAC                   if        $pcmd = '*PICK   '
MATaAC                   eval      $tpgm = 'OR740CL'
MATaAC                   exsr      zzstrt
MATaAC*
MATaAC                   call      'OR740CL'
MATaAC                   parm                    $pwhse
MATaAC                   parm                    $otype
MATaAC                   parm                    rhrtid
MATaAC                   parm                    rhrte
MATaAC                   parm      '  '          $retrn
MATaAC                   parm                    $msgid
MATaAC                   eval      $tpgm = 'OR740CL'
MATaAC                   exsr      zzend
MATaAC                   endif
MATaA*
MATaAC                   endif
500bA*
500bA*    Create Priority Replenishments for route just printed.
500bAC                   if        opjitr = '2'
500bAC                   eval      $tpgm = 'CCJITPCL'
500bAC                   exsr      zzstrt
500bAC                   eval      $lcmd = '*TKPRTY '
500bAC                   eval      $lprg = #prog
500bAC                   z-add     $pwhs         $lwhse
500bAC                   eval      $lrte = $prtid
500bAC                   eval      $lgrp1 = 'S'
500bAC                   if        $ptype = '*WCPICK '  or
500bAC                             $ptype = '*WCPICK1'
500bAC                   eval      $lgrp2 = 'W'
500bAC                   else
500bAC                   eval      $lgrp2 = ' '
500bAC                   endif
500bA*
500bAC                   call      'CCJITPCL'
500bAC                   parm                    $lparm
500bA*
500bAC                   eval      $tpgm = 'CCJITPCL'
500bAC                   exsr      zzend
500bA*
500bAC                   endif
500bA*
414aAC                   endif
402 M*********************
402 M*
402 M*     Phase 5 - Print loading sheet (Truck Summary).
402 M*
402 MC     phase5        tag
CSPaA*  skip reports if ADD-ON route for Coastal
CSPaAC                   if        client = coastalsunbelt
CSPaAC                             and (rhtruk = 'ADD-ON'
CSPaAC                             or rhtruk = 'ADDONLATES')
CSPaAC                   goto      skip1
CSPaAC                   endif
CSPaA*
404 MC                   if        $ptype <> '*WCPICK '  and
404 MC                             $ptype <> '*WCPICK1'
MJK AC                             and client <>  MJKellner
DRYaAC                             and client <>  Dairyland
MJK AC*
MJK AC                             or  client = MJKellner
MJK MC                             and $PTYPE <> '*WCPICK '
MJK MC                             and $PTYPE <> '*WCPICK1'
MJK AC                             and %subst(rhrte:1:1) <> 'I'
MJK AC*
DRYaAC                             or  client = Dairyland
DRYaMC                             and $PTYPE <> '*WCPICK '
DRYaMC                             and $PTYPE <> '*WCPICK1'
DRYaAC                             and rhtruk <> 'WHOLESALE'
DRYaAC*
MJK AC*
CBItAC                             or  client = cheney and
CBItAC                                 clientloc = cbigwb
CBItA*      GWB needs Truck Map for Will-Call orders
CBItA*
710bAC                   if        $pcmd2 <> '*STGPRNT'
415 AC                   eval      $tpgm = 'PS310'
415 AC                   exsr      zzstrt
402 MC                   eval      stat = '5'
402 MC                   exsr      updctl
402 MC                   if        $pjtyp = *on
402 MC                   exsr      zm25
402 MC                   endif
402 MC                   move      $pwhse        $whsea
413 MC                   eval      $dev = *blanks
413 MC                   eval      $form = *blanks
413 AC                   movel     'PS311PR '    wkprtf
413 AC     rpkey         chain     reports                            79
413 AC                   if        not *in79
413 AC                   eval      $dev = rpdev
413 AC                   eval      $form = rpform
413 AC                   else
413 AC                   movel     '*JOB    '    $dev
413 AC                   movel     '*STD    '    $form
413 AC                   endif
402 MC                   call      'PS310CL'
402 MC                   parm                    $whsea
402 MC                   parm                    rhrtid
402 MC                   parm                    $retrn
413 AC                   parm                    $dev             10
413 AC                   parm                    $form            10
413 D**                   PARM '*JOB'    $DEV   10
413 D**                   PARM '*STD'    $FORM  10
415 AC                   eval      $tpgm = 'PS310'
415 AC                   exsr      zzend

710bAC                   endif

404 MC                   endif
402 M*
402 M*     Phase 6 - Print pallet summary
402 M*
402 MC     phase6        tag
720aAc**
720aAc*  If using TruckBuilder Enhanced
720aAc*  then call process to generate unique SSCC18 labels for pallets
720aAc**
720aAc**                 if        tbEnhanced
720aAc**                 call      'OR630ADB'
720aAc**                 parm                    $pWhse
720aAc**                 parm                    rhrtid
720aAc**                 endif
720aAc**
CBIbAc                   if        client = cheney

CBI9AC                   if        rhrte = '9998 ' and
CBI9AC                             rhtype = 'W'    or
CB1cAC                             rhrte >= '8800 ' and
CB1cAC                             rhrte <= '8899 ' and
CB1cAC                             rhtype = 'W' and
CB1cAC                             clientloc = cbiriv
CBI9AC                   call      'OR660PCL'
CBI9AC                   parm                    $pcmd
CBI9AC                   parm      '*DETAIL '    rtype             8
CBI9AC                   parm                    $whsea
CBI9AC                   parm                    rhrtid
CBI9AC                   parm                    $retrn
CBI9AC                   parm      'N'           $povr             1
CBI9AC                   endif

CBIbAC                   select
CBIbAC                   when      $ptype = '*WCPICK '  and
CBIbAC                             rhtruk = 'BREAKERS'  or
CBIbAC                             $ptype = '*WCPICK1'  and
CBIbAC                             rhtruk = 'BREAKERS'
CBIbAC                   call      'OR660CL'
CBIbAC                   parm                    $pcmd
CBIbAC                   parm      '*SUMMARY'    rtype             8
CBIbAC                   parm                    $whsea
CBIbAC                   parm                    rhrtid
CBIbAC                   parm                    $retrn
530bAC                   parm      'N'           $povr             1
CBIbAC*                  parm      '*JOB    '    $dev
CBIbAC*                  parm      '*STD    '    $form

CBIjA*   Container truck
CBIjAC                   when      $ptype = '*WCPICK '  and
CBIjAC                             rhtruk = @cntnr  or
     *
CBIjAC                             $ptype = '*WCPICK1'  and
CBIjAC                             rhtruk = @cntnr  or
     *   Pre-Pick truck
CBIjAC                             $ptype = '*WCPICK '  and
CBIjAC                             rhtruk = @prpck  or
     *
CBIjAC                             $ptype = '*WCPICK1'  and
CBIjAC                             rhtruk = @prpck  or
     *   Meat-insp truck
CBIjAC                             $ptype = '*WCPICK '  and
CBIjAC                             rhtruk = @mtins  or
     *
CBIjAC                             $ptype = '*WCPICK1'  and
CBIjAC                             rhtruk = @mtins  or
CBI3A*   Sud-Svc truck
CBI3AC                             client = cheney
CBI3AC                             and (clientloc = cbipntgr
CBI3AC                             or   clientloc = cbiocl
CBI3AC                             or   clientloc = cbiriv)
CBI3AC                             and ($ptype = '*WCPICK '
CBI3AC                             or   $ptype = '*WCPICK1')
CBI3AC                             and rhtruk = @sdsvc
CBIqA*
CBItAC                             or client = cheney
CBItAC                             and clientloc = cbigwb
CBItA*      GWB needs Truck Pallet Detail for Will-Call orders.
CBItA*
CBItAC                   select
CBI3AC                   when      rhtruk = @sdsvc
CBI4AC                   eval      $dev = 'PRTSUD'
CBI6AC                   eval      $form = '*STD    '
     *
     *      Override printer file.
     *
     *          OVRPRTF FILE(OR660PR) OUTQ(*DEV) DEV($dev)
     *                  FORMTYPE($form)
     *
     C                   movea     ovrprt(1)     a80
     C                   movea     $dev          a80(38)
     C                   movea     $form         a80(59)
     C                   movea     a80           qcmd
     *
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
CBI3AC                   endsl
     *
CBIjAC                   call      'OR660CL'
CBIjAC                   parm                    $pcmd
CBIjAC                   parm      '*DETAIL '    rtype
CBIjAC                   parm                    $whsea
CBIjAC                   parm                    rhrtid
CBIjAC                   parm                    $retrn
530bAC                   parm      'N'           $povr             1

CBI6AC                   if        rhtruk = @sdsvc
CBI6AC                   movea     ovrprt(2)     a80
CBI6AC                   movea     a80           qcmd
CBI6AC                   call      'QCMDEXC'
CBI6AC                   parm                    qcmd
CBI6AC                   parm      80            qlen
CBI6AC                   endif

CBIfA* Print OR660 Summary, PS311 for 'ADD-ONS truck.
CBIfAC                   when      $ptype = '*WCPICK '  and
CBIfAC                             rhtruk = 'ADD-ONS '  or
CBIfAC                             $ptype = '*WCPICK1'  and
CBIfAC                             rhtruk = 'ADD-ONS '
CBIfAC                   call      'OR660CL'
CBIfAC                   parm                    $pcmd
CBIfAC                   parm      '*SUMMARY'    rtype
CBIfAC                   parm                    $whsea
CBIfAC                   parm                    rhrtid
CBIfAC                   parm                    $retrn
530bAC                   parm      'N'           $povr             1
CBIfAC*                  parm      '*JOB    '    $dev
CBIfAC*                  parm      '*STD    '    $form
     *
CBIfAC                   move      $pwhse        $whsea
CBIfAC                   eval      $dev = *blanks
CBIfAC                   eval      $form = *blanks
CBIfAC                   movel     'PS311PR '    wkprtf
CBIfAC     rpkey         chain     reports                            79
CBIfAC                   if        not *in79
CBIfAC                   eval      $dev = rpdev
CBIfAC                   eval      $form = rpform
CBIfAC                   else
CBIfAC                   movel     '*JOB    '    $dev
CBIfAC                   movel     '*STD    '    $form
CBIfAC                   endif
CBIfMC                   call      'PS310CL'
CBIfMC                   parm                    $whsea
CBIfMC                   parm                    rhrtid
CBIfMC                   parm                    $retrn
CBIfAC                   parm                    $dev
CBIfAC                   parm                    $form
CBIfA*  Print truck pallet report for Produce items only
CBIfAC                   call      'OR662CL'
CBIfAC                   parm                    $pcmd
CBIfAC                   parm      '*DETAIL '    rtype
CBIfAC                   parm                    $whsea
CBIfAC                   parm                    rhrtid
CBIfAC                   parm                    $retrn
     *
CBIbAc                   endsl
CBIbAc                   endif
HARaA*     Skip printing -
HARaAC     client        cabeq     harbor        phase7
WST1AC     client        cabeq     westside      skip1
HARaA*
404 MC                   if        $ptype <> '*WCPICK '  and
404 MC                             $ptype <> '*WCPICK1'
MJK AC                             and client <>  MJKellner
IFDcAC                             and client <>  IFD
EI  AC                             or client = ei
MJK AC*
MJK AC                             or  client = MJKellner
MJK MC                             and $PTYPE <> '*WCPICK '
MJK MC                             and $PTYPE <> '*WCPICK1'
MJK AC                             and %subst(rhrte:1:1) <> 'I'
MJK AC*
415 AC                   eval      $tpgm = 'OR660'
415 AC                   exsr      zzstrt
402 MC                   eval      stat = '6'
402 MC                   exsr      updctl
402 MC                   if        $pjtyp = *on
402 MC                   exsr      zm26
402 MC                   endif
PCKbAC                   if        client <> packers
YHTaDC*                            and client <> yhata
YHTaA*
YHTaA*     Print OR660 Detail/Summary for all non-transfer routes.
YHTaMC                             or  client = yhata
YHTaAC                             and %subst($ptrte:1:1) <> 'I'
YHTaA*
500 AC                   eval      $dev = '*JOB    '
500 AC                   eval      $form = '*STD    '
ICBbAC                   if        client <> icb
CBIdAC                             and client <> cheney
402 MC                   call      'OR660CL'
402 MC                   parm                    $pcmd
404 D**                   PARM '*SUMMARY'RTYPE   8
404 AC                   parm      '*DETAIL '    rtype             8
402 MC                   parm                    $whsea
402 MC                   parm                    rhrtid
402 MC                   parm                    $retrn
530bAC                   parm      'N'           $povr             1
530bDC*                  parm                    $dev
530bDC*                  parm                    $form
ICBbAC                   endif
500 AC                   eval      $dev = '*JOB    '
500 AC                   eval      $form = '*STD    '
409 AC                   call      'OR660CL'
409 AC                   parm                    $pcmd
409 AC                   parm      '*SUMMARY'    rtype
409 AC                   parm                    $whsea
409 AC                   parm                    rhrtid
409 AC                   parm                    $retrn
530bAC                   parm      'N'           $povr             1
530bDC*                  parm                    $dev
530bDC*                  parm                    $form
500cA*
520 D ***                call      'OR660TCL'
520 D ***                parm                    $pcmd
520 D ***                parm      '*DETAIL '    rtype
520 D ***                parm                    $whsea
520 D ***                parm                    rhrtid
520 D ***                parm                    $retrn
520 D ***                parm                    $dev
520 D ***                parm                    $form
SLBbA *
SLBbAC                   if        client = silberman
SLBbAC                   call      'OR660TCL'
SLBbAC                   parm                    $pcmd
SLBbAC                   parm      '*SUMMARY'    rtype
SLBbAC                   parm                    $whsea
SLBbAC                   parm                    rhrtid
SLBbAC                   parm                    $retrn
SLBbAC                   parm                    $dev
SLBbAC                   parm                    $form
SLBcA *
SLBcAC                   call      'OR660TBCL'
SLBcAC                   parm                    $whsea
SLBcAC                   parm                    rhrtID
SLBdA *
SLBdAC                   eval      $dev = '*JOB    '
SLBdAC                   eval      $form = '*STD    '
SLBdAC                   call      'OR660FDICL'
SLBdAC                   parm      '*BULK   '    $Fcmd             8
SLBdAC                   parm      '*DETAIL '    rtype
SLBdAC                   parm                    $whsea
SLBdAC                   parm                    rhrtid
SLBdAC                   parm                    $retrn
SLBdAC                   parm                    $dev
SLBdAC                   parm                    $form
      *
SLBcAC                   endif
SLBcA *
CTWbAC                   if        client = citywholesale
CTWbAC                   call      'OR660CLCTW'
CTWbAC                   parm                    $pcmd
CTWbAC                   parm      '*DETAIL '    rtype             8
CTWbAC                   parm                    $whsea
CTWbAC                   parm                    rhrtid
CTWbAC                   parm                    $retrn
CTWbAC                   parm      'N'           $povr             1
CTWbAC                   eval      $dev = '*JOB    '
CTWbAC                   eval      $form = '*STD    '
CTWbAC                   endif
CTWbA *
PCKbAC                   endif
500cA*
414cAC                   call      'OR665CL'
414cAC                   parm                    $pcmd
414cAC                   parm      '*DETAIL '    rtype
414cAC                   parm                    $whsea
414cAC                   parm                    rhrtid
414cAC                   parm                    $retrn
CBI AC                   if        client = cheney
CBI A*  Print truck pallet report for Produce items only
CBI AC                   call      'OR662CL'
CBI AC                   parm                    $pcmd
CBI AC                   parm      '*DETAIL '    rtype
CBI AC                   parm                    $whsea
CBI AC                   parm                    rhrtid
CBI AC                   parm                    $retrn
CBI AC                   endif
CBIpA*  Print truck pallet detail report for Compartment X only
CBI1AC                   if        client = cheney
CBI1AC                             and (clientloc = cbiocl
CBI1AC                             or clientloc = cbipntgr
CBI1AC                             or clientloc = cbigwb)
CBIpAC                   call      'OR664CL'
CBIpAC                   parm                    $pcmd
CBIpAC                   parm      '*DETAIL '    rtype
CBIpAC                   parm                    $whsea
CBIpAC                   parm                    rhrtid
CBIpAC                   parm                    $retrn
CBIpA*  Print truck pallet detail report for Comp X only 2nd copy
CBIpAC                   call      'OR664CL'
CBIpAC                   parm                    $pcmd
CBIpAC                   parm      '*DETAIL '    rtype
CBIpAC                   parm                    $whsea
CBIpAC                   parm                    rhrtid
CBIpAC                   parm                    $retrn
CBI1AC                   endif
     *
415 AC                   eval      $tpgm = 'OR660'
415 AC                   exsr      zzend
IFD A*
IFDaDC*                  if        client = IFD
SVLbDC**                 if        client = saval
ICBaAC*****                        or  client = icb
DRYbAC                   if        client = dairyland
SVLbDC**                           or  client = dairyland
DRYcMC                             and (clientloc = dryhanover
DRYfDC*                              or clientloc = drymiami
DRYcAC                               or clientloc = drylosangeles
DRYeDC*                              or clientloc = dryportland
DRYcAC                               or clientloc = drysanfran
DRYgAC                               or clientloc = dryqznchicago
DRYhAC                               or clientloc = dryqnj
DRYdAC                               or clientloc = drylv)
KFS AC                             or  client = kellys
HKW AC                             or  client = hkw
JSLaAC                             or  client = JSilvert
SOF AC                             or  client = SofoFoods
ADF AC                             or  client = AandDFoods
SBRaDC***                          or  client = SBertram
MRT AC                             or  client = Merit
IFD A*
IFD AC                   eval      $tpgm = 'OR690'
IFD AC                   exsr      zzstrt
IFD A*
IFD A*      Print Transaction Audit report for entire route.
IFD AC                   call      'OR690'
IFD AC                   parm      '*PRINT  '    $pcmd
IFD AC                   parm                    $whsea
IFD AC                   parm                    rhrtid
IFD AC                   parm                    rhrte
IFD AC                   parm                    rhtruk
IFD AC                   parm      '*ALL  '      $xszon
IFD AC                   parm      '*DFT      '  $dev
IFD AC                   parm      '*DFT      '  $form
IFD A*
IFD AC                   eval      $tpgm = 'OR690'
IFD AC                   exsr      zzend
IFD A*
IFD AC                   endif
IFD A*
404 MC                   endif
414aA*
414aA*     Phase 7 - Print Host pick Will Call Item Exceptions
414aA*
414aAC     phase7        tag
414aAC                   if        $otype = 'W'  and
414aAC                             ophpwc = 'Y'
415 AC                   eval      $tpgm = 'OR647'
415 AC                   exsr      zzstrt
414aAC                   move      $pwhse        $whsea
414aA*     Host pick Will Call Auto Close transactions.
414aAC                   call      'PT647'
414aAC                   parm      *blanks       $pcmd
414aAC                   parm                    $whsea
414aAC                   parm                    rhrtid
414aAC                   parm                    $retrn
415bA**                   CALL 'OR670'
CBIqAc                   if        client <> cheney
CBIqAc                             or client = cheney and
CBIqAC                             rhtruk <> @wlcllCBI  and
CBIqAC                             rhtruk <> @sdsvc  and
CBIqAC                             rhtruk <> @dmges
415bMC                   call      'OR770'
414aAC                   parm      *blanks       $pcmd
414aAC                   parm      '*DETAIL '    rtype
414aAC                   parm                    $whsea
414aAC                   parm                    rhrtid
414aAC                   parm                    $retrn
CBIqAC                   endif
     *
415 AC                   eval      $tpgm = 'OR647'
415 AC                   exsr      zzend
414aAC                   endif
415 AC                   if        $pcmd2 = '*PCKPRNT'
415 AC                   eval      $tpgm = $pcmd2
415 AC                   exsr      zzend
415 AC                   endif
CBI5Ac                   select
CBI5Ac                   when      client = cheney
CBI7D **                           and clientloc = cbiriv
CBI7D **                 when      client = cheney
CBIkA*
CBIkA*    Print Manager Ship List for Flagged Customers.
CBIkA*
CBIkAC                   if        $pcmd2 = '*PCKPRNT'  or
CBIkAC                             $pcmd2 = '*ALL    '
CBIqAC                   if        rhtruk <> @wlcllCBI  and
CBIqAC                             rhtruk <> @sdsvc  and
CBIqAC                             rhtruk <> @dmges
CBIkAC                   eval      $tpgm = 'CK370'
CBIkAC                   exsr      zzstrt

CB1aAC                   eval      $dev = *blanks
CB1aAC                   eval      $form = *blanks
CB1aAC                   movel     'CK375PR '    wkprtf
CB1aAC     rpkey         chain     reports                            79
CB1aAC                   if        not *in79
CB1aAC                   eval      $dev = rpdev
CB1aAC                   eval      $form = rpform
CB1aAC                   else
CB1aAC                   movel     '*JOB    '    $dev
CB1aAC                   movel     '*STD    '    $form
CB1aAC                   endif

CBIkA*
CBIkAC                   call      'CK370CL'
CBIkAC                   parm                    $whsea
CBIkAC                   parm                    rhrtid
CBIkAC                   parm      '*ALL   '     $cord#            7
CBIkAC                   parm      'Y'           $cjobq            1
CB1aMC                   parm      $dev          $cdev            10
CBIkAC                   parm      '*STD    '    $cform           10
CBIkA*
CBIkAC                   eval      $tpgm = 'CK370'
CBIkAC                   exsr      zzend
CBIqAC                   endif
CBIkAC                   endif
CBI5Ac                   endsl
IFDbAC*
IFDbAC*    Print Manager Ship List for Flagged Customers.
IFDbAC*
IFDbAC                   if        client = IFD
IFDbAC*
IFDbAC     $PCMD2        IFEQ      '*PCKPRNT'
IFDbAC     $PCMD2        OREQ      '*ALL    '
IFDbAC*
IFDbAC     RHTRUK        IFNE      @WLCLL
IFDbAC                   MOVEL(P)  'CK370'       $TPGM
IFDbAC                   EXSR      ZZSTRT
IFDbAC*
IFDbAC                   move      $pwhse        $whsea
IFDbAC                   CALL      'CK370CL'
IFDbAC                   PARM                    $WHSEA
IFDbAC                   PARM                    RHRTID
IFDbAC                   PARM      '*ALL   '     $CORD#            7
IFDbAC                   PARM      'Y'           $CJOBQ            1
IFDbAC                   PARM      '*JOB    '    $CDEV            10
IFDbAC                   PARM      '*STD    '    $CFORM           10
IFDbAC*
IFDbAC                   MOVEL(P)  'CK370'       $TPGM
IFDbAC                   EXSR      ZZEND
IFDbAC                   ENDIF
IFDbAC                   ENDIF
IFDbA*
IFDbAC                   ENDIF
     *
414bA*    All processing completed successfully, set job status.
414bA*
414bAC                   eval      jobok = '*DONE   '
414bA*
     *
     C     skip1         tag
     *
     C                   eval      $pcmd = '*PICK   '
     *
     C     enddo1        tag
     C                   enddo
     *
     *  Mark batch as finished if no error occured.
     *
     C                   if        $retrn <> '*ERROR  '  and
     C                             bflag = *on
414bD*R         $RETRN    IFEQ '*DONE   '
414bMC                   if        jobok = '*DONE   '
     C                   eval      stat = '9'
     C                   endif
     C                   exsr      updctl
     C                   endif
     *
     C     endpst        endsr
     *----------------------------------------------------------------
     *
     *  UPDCTL  Update batch control record. Lock it if necessary.
     *
     C     updctl        begsr
     *
     *   If this is for phase1 and a new batch ...
     *
     C                   if        stat = '0'  and
     C                             $pcmd = '*PICK   '  and
     C                             bflag = *off  or
     C                             $pcmd2 = '*REBUILD'  and
     C                             bflag = *off  and
414bAC                             stat = '0'  or
     C                             $pcmd2 = '*PCKPRNT'  and
     C                             bflag = *off  and
414bAC                             stat = '0'
     *
     *     - Get new batch number.
     *
     C                   call      'PIRBAT#'
     C                   parm                    $pbat
     *
     *     - Create batch control record.
     *
     C                   eval      btbat# = $pbat
     C                   eval      btwhse = $pwhse
     C                   eval      bttype = $ptype
     C                   eval      btstat = stat
     C                   eval      btrte = $prtid
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      btstrd = $cvd8o
     C                   time                    btstrt
     C                   eval      btstrb = #user
     C                   write     btrec
     C                   else
     *
     *   Otherwise, update control record with current phase.
     *     - If finished then mark with time stamp.
     *
     C     $pbat         chain     btrec                              79
     C                   eval      btstat = stat
     C                   eval      btrte = rhrtid
     C                   if        stat = '9'
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      btendd = $cvd8o
     C                   time                    btendt
     C                   endif
     C                   update    btrec
     C                   endif
     *
     *   Grab control record to let others know a batch is being
     *   processed unless, of course, we are finished.
     *
     C                   if        stat <> '9'
     C     $pbat         chain     btrec                              79
     C                   endif
     C                   eval      bflag = *on
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  UPDRTE  Update route header record.
     *
     C     updrte        begsr
650aAC                   eval      $icmd = ''
     *
     *   Get route header and update.
     *
     C     keyrh         chain     rtehed                             79
     C                   if        not *in79
     C                   eval      rhstat = rstat
414bD*R                   Z-ADD$PBAT     RHPBAT
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      rhstsd = $cvd8o
     C                   time                    rhstst
     C                   select
     C                   when      rstat = '3'
414bAC                   eval      rhpbat = $pbat
     C                   eval      rhbldd = rhstsd
     C                   eval      rhbldt = rhstst
510dA*    Clear Inuse flag for route.
510dAC                   if        $otype = ' '
650aDC**                 eval      rhshpd = *zeros
650aAC                   eval      $icmd = '*CLEAR'
700gA * we do not want to clear the in use flag if user is doing a
700gA * rebuild from gui DD
700gAc                   if        $pcmd2 = '*REBUILD'
700gAc                   exsr      zzchkDD
700gAc                   endif
510dAC                   endif
     C                   when      rstat = '4'
     C                   eval      rhprtd = rhstsd
     C                   eval      rhprtt = rhstst
510dA*    Clear Inuse flag for route.
510dAC                   if        $otype = ' '
650aDC**                 eval      rhshpd = *zeros
650aAC                   eval      $icmd = '*CLEAR'
510dAC                   endif
     C                   endsl
     C                   update    rhrec
650aAC                   if        $icmd <> ''
650aAC                   exsr      zziuse
650aAC                   endif
     C                   endif
     *
     C                   endsr
700gA*----------------------------------------------------------------
700gA*
700gA*  ZZCHKDD  Check inuse flag for route - for DD lock
700gA*
700gAC     zzchkdd       begsr
700gA*
700gAC                   eval      sv$icmd  = $icmd

700gAC                   call      'CHKIUSE2'
700gAC                   parm      '*GETIUSE'    $icmd             8
700gAC                   parm      $pwhse        $iwhse            3 0
700gAC                   parm      $prtid        $irtid            5
700gAC                   parm      #prog         $ipgm            20
700gAC                   parm      ''            $iuser           10
700gAC                   parm      ''            $isessid         40
700gAC                   parm                    $irtn             8
700gAC                   parm                    $itext10         10
700gAC                   parm                    $itext30         30
700gAC                   parm                    $iucmd            8
700gAC                   parm                    $iupgm           20
700gAC                   parm                    $iuuser          10
700gAC                   parm                    $iuSessId        40
700gAC                   parm                    $iuJobName       10
700gAC                   parm                    $iuJobNbr         6
700gAC                   parm                    $iuJobUser       10
700gAC                   parm                    $iuStamp         26
700gA*
700gAc                   if        $irtn = '*ERROR' and
700gAc                             $itext10 = 'Drag Drop'
700gAc                   eval      $icmd = ' '
700gAc                   else
700gAc* reset the value of $icmd = if we are not in Drag Drop
700gAC                   eval      $icmd = sv$icmd
700gAc                   endif
700gAC                   endsr
415 A*----------------------------------------------------------------
415 A*
415 A*  ZZEND   End timer
415 A*
415 AC     zzend         begsr
710aAC                   exsr      zzendlog
710aAC                   leavesr
     C     $otype        cabne     ' '           endzze
     *
     C                   eval      rttwhs = $pwhse
     C                   eval      rttrid = rhrtid
     *
     C                   select
     C                   when      $tpgm = '*ALOCBLD'  or
     C                             $tpgm = '*PCKPRNT'
     C                   eval      rttpgm = svpgm1
     C                   eval      rttsdt = svdte1
     C                   eval      rttstm = svtim1
     *
     C                   other
     C                   eval      rttpgm = svpgm2
     C                   eval      rttsdt = svdte2
     C                   eval      rttstm = svtim2
     *
     C                   endsl
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      rttedt = $cvd8o
     C                   time                    rttetm
     *
     C                   eval      rttrdt = rttsdt
     *
     *      If start time is less than 5:00am
     *       Then subtract 1 from the day for report date.
     *
     C                   if        rttstm < 50000
     C                   eval      $cvcmd = '*CMDCMD '
     C                   move      rttsdt        $cvd8i
     C                   eval      $cvdr1 = '*SUBDAYS'
     C                   eval      $cvvl1 = 1
     C                   call      @clcdr
     C                   parm                    $cvtdt
     C                   eval      rttrdt = $cvd8o
     C                   endif
     *
     C                   call      'CALCTIME'
     C                   parm      '*MINUTES'    $cvcmd
     C                   parm                    rttsdt
     C                   parm                    rttstm
     C                   parm                    rttedt
     C                   parm                    rttetm
     C                   parm      0             rttmin
     *
     C                   eval      rttjob = #job
     C                   eval      rttusr = #user
     C                   move      #jobn         rttjb#
     *
     C                   write     rttrec
     *
     C     endzze        endsr
710aA*----------------------------------------------------------------
710aA*
710aA*  ZZENDLOG   End timer
710aA*
710aAC     zzendlog      begsr
     *
     C                   select
720cDC**                 when      jobok = '*DONE '
720cDC**                 eval      $ltype = '3'
720cDC**                 eval      $ppgm = 'OR605'
720cDC**                 when      jobok = '*DONEA'
720cDC**                 eval      $ltype = '3'
720cDC**                 eval      $ppgm = 'OR605'
720cAC                   when      $tpgm = '*ALOCBLD'
720cAC                             or $tpgm = '*PCKPRNT'
720cAC                             or $tpgm = '*STGPRNT'
720cAC                   eval      $ltype = '3'
720cAC                   eval      $ppgm = 'OR605'
720cAC                   eval      $subgrp = *blanks
     C                   other
     C                   eval      $ltype = '2'
     C                   endsl
     *
     * Write RTELOG record
     *
     C                   call      'WRTRTELOG'
     C                   parm                    $pwhse
     C                   parm      $prtid        $rtid
     C                   parm                    $tmstmp
     C                   parm      $pgid         $grpid
     C                   parm      $pcmd2        $grpcode
     C                   parm                    $subgrp
     C                   parm                    $ltype
     C                   parm                    $curusr
     C                   parm      'OR605'       $ppgm
     C                   parm                    $jobqts
     C                   parm                    $jobquc
     * add in USF as 700d
710cAC                   if        $pgid = 0
710cAC                   eval      $pgid = $grpid
710cAC                   endif
710cA*
     C     endzzelog     endsr
510dA*----------------------------------------------------------------
510dA*
510dA*  ZZIUSE   Clear Inuse flag for route.
510dA*
510dAC     zziuse        begsr
510dA*
650aDC**                 call      'CHKIUSE'
650aDC**                 parm      '*CLEAR  '    $icmd             8
650aDC**                 parm      $pwhse        $iwhse            3 0
650aDC**                 parm      $prtid        $irtid            5
650aDC**                 parm      *blanks       $irtn             8

650aAC                   call      'CHKIUSE2'
650aAC                   parm                    $icmd             8
650aAC                   parm      $pwhse        $iwhse            3 0
650aAC                   parm      $prtid        $irtid            5
650aAC                   parm      #prog         $ipgm            20
650aAC                   parm      ''            $iuser           10
650aAC                   parm      ''            $isessid         40
650aAC                   parm                    $irtn             8
650aAC                   parm                    $itext10         10
650aAC                   parm                    $itext30         30
650aAC                   parm                    $iucmd            8
650aAC                   parm                    $iupgm           20
650aAC                   parm                    $iuuser          10
650aAC                   parm                    $iuSessId        40
650aAC                   parm                    $iuJobName       10
650aAC                   parm                    $iuJobNbr         6
650aAC                   parm                    $iuJobUser       10
650aAC                   parm                    $iuStamp         26
510dA*
510dAC                   endsr
415 A*----------------------------------------------------------------
415 A*
415 A*  ZZSTRT  Start timer
415 A*
415 AC     zzstrt        begsr
710aAC                   exsr      zzstrtlog
710aAC                   leavesr
     C     $otype        cabne     ' '           endzzs
     *
     C                   select
     C                   when      $tpgm = '*ALOCBLD'  or
     C                             $tpgm = '*PCKPRNT'
     C                   eval      svpgm1 = $tpgm
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      svdte1 = $cvd8o
     C                   time                    svtim1
     *
     C                   other
     C                   eval      svpgm2 = $tpgm
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      svdte2 = $cvd8o
     C                   time                    svtim2
     *
     C                   endsl
     *
     C     endzzs        endsr
710aA*----------------------------------------------------------------
710aA*
710aA*  ZZSTRTLOG  Start timer
710aA*
710aAC     zzstrtlog     begsr
     *
     C                   select
     C                   when      $tpgm = '*ALOCBLD'
     C                             or $tpgm = '*PCKPRNT'
     C                             or $tpgm = '*STGPRNT'
     C                   eval      $ppgm = 'OR605'
     C                   eval      $subgrp = *blanks
     C                   other
     C                   eval      $ppgm = $tpgm
     C                   eval      $subgrp = $tpgm
     C                   endsl
     *
     * Write RTELOG record
     *
     C                   call      'WRTRTELOG'
     C                   parm                    $pwhse
     C                   parm      $prtid        $rtid             5
     C                   parm                    $tmstmp          26
     C                   parm      $pgid         $grpid            7 0
     C                   parm      $pcmd2        $grpcode         10
     C                   parm                    $subgrp          12
     C                   parm      '1'           $ltype            1
     C                   parm                    $curusr          10
     C                   parm      'OR605'       $ppgm            10
     C                   parm                    $jobqts
     C                   parm                    $jobquc
     * added was 700d in USF
710cAC                   if        $pgid = 0
710cAC                   eval      $pgid = $grpid
710cAC                   endif
710cA*
     C     endzzslog     endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMCPMQ  Clear program message queue.
     *
     C     zmcpmq        begsr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMCSBF  Clear message subfile.
     *
     C     zmcsbf        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   write     msgctl
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
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
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
     C                   write     msgrec
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
223 AC                   parm      $pprg         #pgmq2           10
223 D**                   PARM 'OR600CL' #PGMQ2 10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *   TF50020  Copying authorized orders to picking files.
     *
     C     zm20          begsr
     C                   exsr      zmcmsg
     C                   eval      #msgid = 'TF50020'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     *blanks       $md
     C                   exsr      zmpmsg
     C                   exsr      zmdmsg
     C                   exsr      zmcpmq
     C                   exsr      zmcsbf
     C                   endsr
     *----------------------------------------------------------------
     *   OR50021  Allocating stock from slots.
     *
     C     zm21          begsr
     C                   exsr      zmcmsg
     C                   eval      #msgid = 'OR50021'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     *blanks       $md
     C                   exsr      zmpmsg
     C                   exsr      zmdmsg
     C                   exsr      zmcpmq
     C                   exsr      zmcsbf
     C                   endsr
     *----------------------------------------------------------------
     *   OR50022  Building pallets.
     *
     C     zm22          begsr
     C                   exsr      zmcmsg
     C                   eval      #msgid = 'OR50022'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     *blanks       $md
     C                   exsr      zmpmsg
     C                   exsr      zmdmsg
     C                   exsr      zmcpmq
     C                   exsr      zmcsbf
     C                   endsr
     *----------------------------------------------------------------
     *   OR50023  Picking stock from slots.
     *
     C     zm23          begsr
     C                   exsr      zmcmsg
     C                   eval      #msgid = 'OR50023'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     *blanks       $md
     C                   exsr      zmpmsg
     C                   exsr      zmdmsg
     C                   exsr      zmcpmq
     C                   exsr      zmcsbf
     C                   endsr
     *----------------------------------------------------------------
     *   OR50024  Printing labels.
     *
     C     zm24          begsr
     C                   exsr      zmcmsg
     C                   eval      #msgid = 'OR50024'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     *blanks       $md
     C                   exsr      zmpmsg
     C                   exsr      zmdmsg
     C                   exsr      zmcpmq
     C                   exsr      zmcsbf
     C                   endsr
     *----------------------------------------------------------------
     *   OR50025  Print loading sheet.
     *
     C     zm25          begsr
     C                   exsr      zmcmsg
     C                   eval      #msgid = 'OR50025'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     *blanks       $md
     C                   exsr      zmpmsg
     C                   exsr      zmdmsg
     C                   exsr      zmcpmq
     C                   exsr      zmcsbf
     C                   endsr
     *----------------------------------------------------------------
     *   OR50026  Print pallet summary.
     *
     C     zm26          begsr
     C                   exsr      zmcmsg
     C                   eval      #msgid = 'OR50026'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     *blanks       $md
     C                   exsr      zmpmsg
     C                   exsr      zmdmsg
     C                   exsr      zmcpmq
     C                   exsr      zmcsbf
     C                   endsr
223 A*----------------------------------------------------------------
223 A*     RH12001  Invalid truck number.
223 A*
223 AC     zm2001        begsr
223 AC                   eval      #msgid = 'RH12001'
223 AC                   eval      #msgtp = '*DIAG  '
223 AC                   movea     errmsg        $md(1)
223 AC                   exsr      zmsmsg
223 AC                   eval      $pmsg = #msgk
223 AC                   endsr

650bA*----------------------------------------------------------------
650bA*  WrtDebugParms  Write out debug parm record
650bA*----------------------------------------------------------------
650bA
650bA /free
650bA  begsr WrtDebugParms;

         bdtype = 'PARMS';

         bdvalues = 'cmd:' + %trim($pcmd) + ', '
                  + 'cmd2:' + %trim($pcmd2) + ', '
                  + 'type:' + %trim($ptype) + ', '
                  + 'whse:' + %char($pwhs) + ', '
                  + 'rtid:' + %trimr($prtid);

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free

650bA*----------------------------------------------------------------
650bA*  WrtDebugError  Write out debug error
650bA*----------------------------------------------------------------
650bA
650bA /free
650bA  begsr WrtDebugError;

         if not debug;
           saveValues = bdvalues;
           exsr WrtDebugParms;
           bdvalues = saveValues;
         endif;

         bdtype = 'ERROR';

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
**  Screen headings
         ** Unknown Batch Type **
*PICK    Pick Customer Orders - All Routes
*PICK1   Pick Customer Orders - Single Route
*TFRPICK Pick Transfer Orders - All Routes
*TFRPCK1 Pick Transfer Orders - Single Route
*WCPICK  Pick Will Call Orders - All Routes
*WCPICK1 Pick Will Call Orders - Single Route
**   OVRPRTF statment
OVRPRTF FILE(OR660PR)           OUTQ(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
DLTOVR  FILE(OR660PR)
