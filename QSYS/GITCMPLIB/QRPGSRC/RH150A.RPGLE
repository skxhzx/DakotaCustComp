      /copy *libl/qcopysrc,hspecs
720aAH DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RH150A  Closed routes (One whse) - Display
     *  27 June 1997
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
402 A*    07/15/97   HNK  4.02
     *        Add Option 9 to view order details.
404 A*    08/18/97   RH   4.04
     *        Add option 8 view breakdown.
404 A*    09/05/97   DAS  4.04
     *        Add $PCMMD to pass to PS130.
     *
411 A*    03/05/99   DAS  4.11
     *      - Added file OPTIONS.
     *      - Added data structure for *FTP options
     *      - Revised ZZINZ routine to get *FTP options.
     *      - Revised ENT03 routine to call RH155CL if OPFTP='Y'.
     *        Othewise, the original program will be called, RH151.
     *
414aA*    04/13/00   MLB  4.14a
     *      - Revised program to check status of route before allowing
     *        option 1 to proceed.
     *      - Revised the following routines: ENT02, ENT03, SAVOPT,
     *        ZZINZ.
     *      - Added new routine ZZCKST to check route status.
     *      - Added new error msg routine: ZM9907.
     *
414bA*    06/30/00  DAS  4.14b
     *      - Revised display file to use ind 21 with SFLNXTCHG
     *        instead of ind 85 as stated in this program. The
     *        actual indicator used in the program was never changed
     *        from 21 to 85.
     *      - Only had to recompile the program.
     *
414cA*    08/15/00  DAS  4.14
     *      - Revised to call OR675CL when option 6=Reprint is taken.
     *      - Added call to OR670CL when exporting routen with opt 1.
     *
416 A*    04/16/02  MLB  4.16
     *      - Revised program to call RS120 for compartment summary
     *        when option 8=Summary is selected.
416aA*    04/16/02  MLB  4.16a
     *      - Revised routine ZZCMD to add function key F9
     *        to call dock matrix display.
     *      - Revised array CMDLN to add text for F9.
416bA*    04/18/02  MLB  4.16b
     *      - Revised array OPTLN to add text for opt 11 -
     *        Dock door details
     *      - Added opt 11 to OPTLST array.
     *      - Added call to DH130 - dock door details.
     *
416cA*    05/09/02  DAS  416c
     *      - Revised SCR03I routine to try and check in data area
     *        EXPORD. If unsuccessful, error is sent back to user.
     *      - Revised SCR03E routine to check out data area EXPORD.
     *      - Added table EM.
     *      - This will prevent 2 people from exporting at the same
     *        time.
     *      - Non-Ftp users can also lock the dataarea so a user
     *        cannot export a route while the export process is
     *        running on the host side.
     *      - A host initiated ftp transfer of the exported routes
     *        locks the dataarea so a user cannot export while the
     *        ftp is running.
416dA*    07/02/02  RH   416d
     *      - FIX - Change OPTION 11=View truck detail to 12=View
417aA*    10/08/03  RH   4.17a
     *      - Enh:Revised program to call CHKIUSE to set inuse flag
     *        in route header when route is selected for export trans,
     *        Allow only 1 user to work with a route for this option
     *      - Revised to check inuse status of route before proceeding
     *      - Created new message routine ZM9908.
417bA*    12/08/03  MLB  4.17b
     *      - Fix: Revised program to not allow multiple routes to be
     *        set inuse if a route is inuse and error message sent.
510 A*    06/15/06  RMC  5.10
     *      - Enh: Create new subfile (DSPPSF) to display
     *             Shipment number for Packers.
     *             Add logic to determine if Packers is accessing
     *             this program.
510aA*    12/01/06  JCJ  5.10a
     *      - ENH: Add option 13=Zone Detail.
520aA*    04/28/08  DAS  5.20a  P#00046
     *      - Added option 'CI' to ZZOPT.
520bA*    08/27/09  RBD  5.20b
     *      - Fix:  Added call to OR633 to update ORDP, unique piece
     *        number file.
520cA*    11/11/09  RBD  5.20c
     *      - Fix:  Parm $pwhse in call to OR633 causes dec data
     *        error, will move it to $whs30 and send it instead.
     *
530 A*    01/18/10  MLB  5.30
     *      - Fix - Added $ROVR parm defaulted to N=NO on OR670CL call.
     *
530aA*    05/14/10  RBD  5.30a
     *      - Added data structure for *SYSTEM options.
     *      - Revised ZZINZ routine to get *SYSTEM options.
     *      - Revised array OPTLN to add text for opt 14 -
     *        Assign driver.
     *      - Added opt 14 to OPTLST array.
     *      - Added call to TR850 - Assign driver to route if
     *        system option 'Using TRAX' equals Y.
     *      - Added call to TR810 - Create TRAX xml route file if
     *        client is a TRAX user and selects 1=export.
     *
530bA*    09/02/10  RBD  5.30b
     *      - Converted to ILE.
     *      - Replaced display of exported date and time with driver.
     *      - Changed name of dspf from RH150AFM to RH150A01.
     *
640aA*    03/03/11  DAS  6.40a
     *      - Revised to call staging export when FTP option is 'S'.
640bA*    05/18/11  MLB  6.40b
     *      - Enh: Revised to call staging export to host when FTP
     *        option is 'S'.
     *
640cA*    10/20/11  RBD  6.40c
     *      - Recompiled, TTRTE file changed.
640dA*    12/02/11  MLB/RH  6.40d
     *      - Fix: Revised program to set $prtn to blanks when return
     *        from TR810 = *OK. Was causing CPF2410 error in pgm.
     *
640eA*    01/17/12  RBD  6.40e
     *      - Recompiled, TTRTE file changed.
     *      - If Trax user and the route is being exported and
     *        is a merged route, only call TR810 if all of the
     *        connected routes have also been exported.
     *
650aA*    03/28/13  DAS  6.50a
     *      - Revised to have CI send *CLEARCI to CHKIUSE.
     *
650bA*    04/09/13  DAS  6.50b
     *      - Requires corresponding change in CHKIUSE program.
     *      - Revised to call CHKIUSE with *GETIUSE to get status
     *        when RHSHPD <> 0.
     *
650c *    12/23/13  DAS  6.50c
     *      - Revised to use CHKIUSE2.
     *      - No longer uses rhshpd for inuse flag.
     *      - Requires new CHKIUSE2 progam and new RTEINUSE file.
     *
650d *    01/16/14  MLB  6.50d
     *      - Enh: Added ClientLoc parm to call to GetClient
     *
700a *    01/08/16  RBD  7.00a
     *      - Added call to TR811 to create version 1.3 Trax(c) xml
     *        file if client is a Trax(c) user and selects 1=export.
     *
700b *    04/25/16  NLK  7.00b
     *      - Added option BX to allow view of AMP Box information
     *
710aA*    04/19/17  RBD  7.10a
     *      - For now skip over code that writes merged routes into
     *        the same xml. The handheld is not yet ready to handle
     *        multiple routes in the same xml.  So for now merged
     *        routes (TTMERG) is only used by the Loader Module.
     *        When you're ready to reinstate this logic simply take out
     *        these 710a revs.
     *
720aA*    08/03/18  RBD  7.20a
     *      - Fix: Skip over Trax logic in this program and instead
     *        run it from RH155S.  Why ?  When RH155SCL is called from
     *        this program to update route status if multiple routes were
     *        selected for export at the same time RH155SCL would do a
     *        sbmjob on itself thus running in batch.  So we've got to be
     *        sure it's finished before calling the Trax programs ... by
     *        moving the Trax logic from here to RH155S we ensure that the
     *        route status for the routes have been updated.
     *      - Added bfcdebug logic.
     *
730aA*    10/03/19  LMC  7.30a
     *      - Treat OPFTP = 'R' same as OPFTP = 'S'.
     *        R=Real time staging export.
     *
750 A*    06/17/21  KDE  7.50
     *      - Enh: Add support for Super Routes
     *----------------------------------------------------------------
CDI A*  Client Custom Revisions: Customized Distributors
     *    01/03/13  RBD  CDI
     *      - Note: This rev was installed at CDI in lib PIRIFCV36
     *        by CWM.  I have removed it from PIRIFCV36 and added it
     *        here, where it should have been added to begin with.
     *      - Enh: Force OPFPT to N.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney
CBIaA*    03/03/11  DAS  CBIa
     *      - Revised to call RH155S with *HDRDTL because at CBI
     *        transactions are exported when they are closed. Therefore
     *        for this export we only want to export the header and
     *        detail files to indicate the route is finished.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Harbor
HAR A*    12/11/07  RBD  HAR
     *      - Added call to XM155 to create XML/POD export IFS files
     *        when user selects ' 1=export transactions '.
HARaA*    04/02/08  DAS  HARa
     *      - Fix: Revised call to XM155 to use 3.0 packed warehouse.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: MJ Kellner
     *
MJKaA*  09/19/08  CWM  MJKa
     *    - Added call to OR671CL with new print 'E' exceptions parm
     *      to only print detail lines where Pick Qty is different
     *      than Order Qty.
MJKbA*  01/22/20  MLB  MJKb
     *    - Revised pgm to not call OR670CL. Report was cluttering up
     *      user's wrksplf lists. Per Mike D. email dated 01.22.2020.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Dairyland
     *
DRYaA*  02/20/10  MLB  DRYa
     *    - Added call to OR671CL with new print 'E' exceptions parm
     *      to only print detail lines where Pick Qty is different
     *      than Order Qty.
     *    - Added Dairyland to MJKa mod.
DRYbA*  01/16/14  MLB  DRYb
     *    - Revised program to call RH155S for select warehouses. Orders
     *      will be exported to JDEdwards.
DRYdA*  05/16/14  MLB  DRYd
     *    - Revised DRYb mod. Revised pgm to set $PCMD = *ALL to cause
     *      RH155SCL to be submitted to QS36EVOKE. Per Kelly R. phone
     *      call 05/16/14.
DRYeA*  02/06/15  MLB  DRYe
     *    - Revised DRYb mod. Revised ENT03 to not run ZZIUSE with cmd
     *      *CLEAR. Clear cmd to be run by RH155S upon successful
     *      export of route in batch. Was allowing the route to be
     *      exported multiple times.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: IndianHead Foodservice
     *
IFDa *  11/22/16  GJA  IFDa   (this was missed in upgrade)
     *    - Added call to OR671CL with new print 'E' exceptions parm
     *      to only print detail lines where Pick Qty is different
     *      than Order Qty.
     *
IFDb *  11/22/16  GJA  IFDb
     *      - Added call to OR660CCL to print Catchwgt by Pallet Report
     *        for all transactions.
     *
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Kelly's Foods
     *
KFSaA*  09/19/12  MLB  KFSa
     *    - Added call to OR671CL with new print 'E' exceptions parm
     *      to only print detail lines where Pick Qty is different
     *      than Order Qty.
     *    - Added KFSa to MJKa mod.
KFSbA*    10/01/12  MLB  KFSb
     *      - Added call to OR660CCL to print Catchwgt by Pallet Report
     *        for all transactions.
KFScA*    06/11/15  MLB  KFSc
     *      - Revised pgm to not call RH155SCL. Was causing duplicate
     *        batches of same route in STGBATCH and export order files.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: HM Wagner
     *
HMWaA*  09/21/12  MLB  HMWa
     *    - Added call to OR671CL with new print 'E' exceptions parm
     *      to only print detail lines where Pick Qty is different
     *      than Order Qty.
     *    - Added HMWa to MJKa mod.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Julius Silvert
     *
JSLaA*  04/01/15  RTR  JSLa
     *    - Do not need 2 calls to RH155S for Julius Silvert, skip first.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Will Foods
     *
WILaA*  04/01/15  RTR  WILa
     *    - Do not need 2 calls to RH155S for Will Foods, skip first.
     *    - Added to JSLa mod.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Coastal Sunbelt Produce
     *
CSPaA*  05/30/14  MLB  CSPa
     *    - Added call to OR671CL with new print 'E' exceptions parm
     *      to only print detail lines where Pick Qty is different
     *      than Order Qty.
     *    - Added CSPa to MJKa mod.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Panos
     *
PANaA*    05/19/17  MR   PANa
     *      - Add process to build EXPSPLBL and update with payroll
     *        and performance data.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: A and D Foods
     *
ADF A*  10/05/17  MLB  ADF
     *    - Added call to OR671CL with new print 'E' exceptions parm
     *      to only print detail lines where Pick Qty is different
     *      than Order Qty.
     *    - Added AandDFoods to MJKa mod.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Southwest Traders
     *
SWTa *  03/18/19  RTR  SWTa
     *    - Added call to RH155CL2 for SWT to run different export
     *      programs.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Greco & Sons
     *
KFScA*    04/21/20  MLB  GRC
     *      - Revised pgm to not call RH155SCL. Was causing duplicate
     *        batches of same route in STGBATCH and export order files.
     *      - Added GRC to KFSc mod.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: TPC Foodservice
     *
TPC A*  09/21/20  MLB  TPC
     *    - Added call to OR671CL with new print 'E' exceptions parm
     *      to only print detail lines where Pick Qty is different
     *      than Order Qty.
     *    - Added TPC to MJKa mod.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Packer's Provision
     *
PCK A*  02/10/21  MLB  PCK
     *    - Added call to RH155CL2 for SWT to run different export
     *      programs.
     *      - Added PCK to SWT mod.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    This program has been revised to work with option '1'
     *    selections similar to how it works with option '4' selections.
     *
     *    This program uses to display subfiles to show more than one
     *    view of the record. To see what was changed search for VW2
     *    starting in column 1.
     *
     *    Allowed F17 and F18 for positioning to top and bottom.
     *
     *    Created a second line for commands.
     *
     *    CMD5 changed to chain and update each view seperately.
     *
     *    RECNO used for all subfiles, SFLRCDNBR not used in format member.
     *
414aA*    * Important * Make sure that any new options added to this pro-
414aA*                  gram that allow changes to the route in any way
414aA*                  are preceeded with a call to subroutine ZZCKST
414aA*                  to verify that the route is still at 'closed'
414aA*                  status.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        Position Cursor
     *  21 - 29   Field Input Error (Reverse Display)
510  *  70        Chain Indicator (ORDHM2)
     *  79        Chain Indicator
     *  81        Display subfile records (SFLDSP)
     *  82        Display subfile screen (SFLDSPCTL)
     *  83        Clear subfile (SFLCLR)
     *  84        Allow subfile to display '+' (SFLEND)
414bD** 85        Manually set subfile change flag (SFLNXTCHG)
414bM*  21        Manually set subfile change flag (SFLNXTCHG)
     *  90        Protect Input Fields for Delete Display
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound Buzzer)
     *  99        Universal Record Indicator (Very Temporary Usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
530bDF*rh150afm  cf   e             workstn
530bMFrh150a01  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(vw2sfl:recno)
     F                                     sfile(vw3sfl:recno)
     F                                     sfile(dsppsf:recno)
222 D*                                       RECNO2KSFILE VW2SFL
222 D*                                       RECNO3KSFILE VW3SFL
     F                                     sfile(msgrec:msgk)
     Fworkopt   uf a e           k disk
     Frtehed2   if   e           k disk
     F                                     rename(rhrec:record)
640eAfrtehed    if   e           k disk    rename(rhrec:rhrec2)
640eAf                                     prefix(r_)
     Frtesum    if   e           k disk
411 AFoptions   if   e           k disk
510  Fordhm2    if   e           k disk
530aAFpiruser   if   e           k disk
640eAFttmerg1   if   e           k disk    prefix(t1_)
640eAfttmerg2   if   e           k disk    rename(ttmrec:ttmrec2)
640eAf                                     prefix(t2_)
530aAFttrte     if   e           k disk
PANaAFpltsum3   if   e           k disk
PANaAFoptionz   if   e           k disk
PANaAFtruckh    if   e           k disk
720aAfbfcdbgflg if   e           k disk    usropn
720aAfbfcdebug  o    e           k disk    usropn
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a10             s              1    dim(10)
     D a75             s              1    dim(75)
     D fkey            s             50    dim(10)
     D ukey            s             50    dim(10)
     D optlst          s              2    dim(24)
     D cmdlst          s              2    dim(24)
     D zopt            s              2    dim(20) ctdata perrcd(20)
222 MD optln           s             75    dim(2) ctdata perrcd(1)
VW2 D*                   CMDLN   1   1 79
VW2 MD cmdln           s             79    dim(6) ctdata perrcd(1)
417aMD stat            s             10    dim(7) ctdata perrcd(1)
417aD*                   STAT    1   6 10
530aD**                  EM      1   1 50
530aMD em              s             50    dim(2) ctdata perrcd(1)
510  *
PCK M /COPY QCOPYSRC,ID#PACKERS
HAR A /COPY QCOPYSRC,ID#HARBOR
MJKaA /COPY QCOPYSRC,ID#MJKELLN
DRYaA /COPY QCOPYSRC,ID#DAIRYLA
DRYbA /COPY QCOPYSRC,ID#DRYBRON
CBIaA /COPY QCOPYSRC,ID#CHENEY
KFSaA /COPY QCOPYSRC,ID#KFS
HMWaA /COPY QCOPYSRC,ID#HMWAGNE
CDI A /COPY QCOPYSRC,ID#CDI
JSLaA /COPY QCOPYSRC,ID#JSL
WILaA /COPY QCOPYSRC,ID#WIL
CSPaA /COPY QCOPYSRC,ID#COASTAL
IFDaA /COPY QCOPYSRC,ID#IFD
PANaA /COPY QCOPYSRC,ID#PAN
ADF A /COPY QCOPYSRC,ID#ADF
SWTaA /copy qcopysrc,id#swt
GRC A /copy qcopysrc,id#grc
TPC A /copy qcopysrc,id#tpc
     D @getcl          c                   const('GETCLIENT')
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1     50
     D  $kwhse                 1      3  0
     D  $kstat                 4      4
     D  $ktype                 5      5
416aA*
416aAD  $khdte                 4     11  0
416aAD  $khtim                12     17  0
416aA*
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D  dsukey                 1     50
     D  rhwhse                 1      3  0 inz(0)
     D  rhrte                  4      8
     D  rhrtid                 9     13
     D  rhtruk                14     23
     D  rhstat                24     24
     D  rhtype                25     25
PANaA*----------------------------------------------------------------
PANaA*  Data structure for OPTIONZ
PANaAD opdta2          ds
PANaAD  opclvl                 1      3  0 inz(0)
PANaAD  opcwra                 4      4
PANaAD  opcwrb                 5      5
PANaAD  opuwra                 6      6
PANaAD  opuwrb                 7      7
PANaAD  optext                 8     50
PANaAD  operr                 51     52  0 inz(0)
PANaAD  opcwgt                53     54  0 inz(0)
PANaAD  oplpgm                55     64
PANaAD  oppdev                65     74
PANaAD  oppfrm                75     84
PANaAD  optend2              117    117
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
     D  optend               117    117
     *----------------------------------------------------------------
530aA*  *SYSTEM  -  System options.
530aA*----------------------------------------------------------------
530aA*
530aA* Fields
530aA*
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *    OPWRNC  -  Perform catch weight variance check (Y,N).
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
     *    OPICW   -  Individual catch weight entry (Y,N).
     *    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
     *    OPRCDY  -  Number of days to keep receiving logs.
     *    OPMPCK  -  Number of days to keep picking logs.
     *    OPRTHS  -  Number of weeks - exported routes to keep.
     *    OPCRHS  -  Number of weeks - exported customer rtns to keep.
     *    OPPOHS  -  Number of weeks - exported p/o's to keep.
     *    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
     *    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
     *    OPTBJQ  -  Run Truck Builder on Job Que (Y,N).
     *    OPISHS  -  Number of weeks to keep history file
     *    OPUCI   -  Use UCI processing (Y,N).
     *    OPICWR  -  Check CW count for receiving. (N,M,B,C)
     *    OPWRNR -   Check CW variance for receiving. (N,M,B,C)
     *    OPTRAX -   Using TRAX module (Y,N).
     *
     * Data structure
     *
     D opdat1          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opicw                 13     13
     D  opmpck                14     14
     D  oprcdy                15     15  0
     D  oppkdy                16     16  0
     D  oprths                17     19  0
     D  opcrhs                20     22  0
     D  oppohs                23     25  0
     D  opiahs                26     28  0
     D  opmshs                29     31  0
     D  optbjq                32     32
     D  opishs                33     35  0
     D  opuci                 36     36
     D  opicwr                37     37
     D  opwrnr                38     38
     D  optrax                39     39
     D  opten1               117    117
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @chgpg          c                   const('RH122')
     D @delpg          c                   const('NONE')
414cD**            'PS310CL'             C         @PRTPG
     D @prtpg          c                   const('OR675CL')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $postn          ds
     D  $pocmd                 1      8
     D  $poprg                 9     18
     D  $pofky                19     68
     D  $pouky                69    118
     D  $podsc               119    307
     D                                     DIM(3)
     D  $popt1               308    322
     D  $popt2               323    335
     D  $portn               336    343
     D  $poerm               344    403
     D  $pomsg               336    339
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
222 AD  $pwhse                19     21  0 inz(0)
222 AD  $prte                 22     26
222 AD  $prtid                27     31
414 AD  $ptruk                32     41
414 AD  $pstat                42     42
414 AD  $ptype                43     43
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
     D  $ltruk                22     31
     D  $ltrk2                32     41
416aA*
416aAD  $lhdte                22     29  0
416aAD  $lhtim                30     35  0
510aA*
510aAD  $krte                 32     36
510aAD  $krtid                37     41
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
     *  Other data structures
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
510  *  Shipment number from Miscellaneous field
510  D                 ds
510  D  hmmsc1                 1     40
510  D  hmmshp                 4     14
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
414aA*
414aAD  eropt                  1     20
414aAD  erstat                21     40
414aAD  ertype                41     50
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
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
720aAD  #curruser            358    367
     *----------------------------------------------------------------
     *  Variables
     *
     D $awhse          s              3
     D $emp#           s              5
     D $msgf           s             10
     D $pcmmd          s              8
PANaAD $ptmpl          s             10
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D bot             s              1
     D cancel          s              1
     D clear           s              5  0
     D comand          s              5  0
PANaAD cmd             s              8
720aAd dbgflgExists    s               n
720aAd debug           s               n
720aAd debugAfter      s               n
720aAd debugBefore     s               n
720aAd debugLoc        s              1
     D dsplyd          s              2  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
640eAD firstpass       s              1
     D forceb          s              1
     D forevr          s              1
     D frstky          s                   like($puky)
     D goback          s              2  0
     D help            s              5  0
PANaAD kycode          s                   like(opzcod)
     D kyrte           s                   like(rhrte)
     D kyrtid          s                   like(rhrtid)
     D kystat          s                   like(rhstat)
     D kytype          s                   like(rhtype)
     D kywhse          s                   like(rhwhse)
PANaAD kyzone          s                   like(opzzon)
PANaAD lstzon          s                   like(psszon)
     D maxvw           s              1  0
     D msgk            s              4  0
     D nomore          s              1
     D nxtscr          s              3
     D otaken          s              1
     D p               s              2  0
     D pagcmd          s              8
640eAD parentRte       s              5
     D posrec          s              4  0
     D p1              s              1  0
     D reccnt          s              4  0
     D recno           s              4  0
     D refrsh          s              1
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stop            s              1
     D stserr          s              1
     D top             s              1
     D v               s              2  0
     D view            s              1  0
     D warn            s              1
PANaAD $whse           s              3  0
     D x               s              3  0
     D y               s              3  0

720aA*----------------------------------------------------------------
720aA*  Sub-procedure prototypes
720aA*----------------------------------------------------------------

720aAd WrtDebugLibl    pr

720aA*----------------------------------------------------------------
720aA*  Prototypes
720aA*----------------------------------------------------------------

720aAd GetLiblCL       pr                  extpgm('GETLIBLCL')
720aAd  libList                    1024

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PRTKY  Partial key
     *
     *    Returned Parameters
     *      $RTNCD  *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $prtky
     C                   parm                    $rtncd            8
     *
     *  Define keys
     *
     *     WORKOPT  (Unique key)
     *
     C     wkounq        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     C                   kfld                    wkokyf
     C                   kfld                    wkokyu
     *
     *     WORKOPT  (Partial key)
     *
     C     wkoprt        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     *
     *     WORKOPT  (Save key for top record on delete display)
     *
     C     deltop        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     C                   kfld                    $wkof
     C                   kfld                    $wkou
     *----------------------------------------------------------------
     *  Main line
     *

720aA /free

720aA   // See if debug is turned on

720aA   debug = *off;
720aA   if dbgflgExists;
720aA     chain(e) (#prog) bfcdbgflg;
720aA     if %found(bfcdbgflg);
720aA       select;
720aA         when bdfflag > 0;
720aA           debug = *on;
720aA       endsl;
720aA     endif;
720aA   endif;

720aA   // Write out current library list if debugging

720aA   if debug;
720aA     WrtDebugLibl();
720aA   endif;

720aA /end-free

     C                   eval      *in97 = *on
     C                   eval      $rtncd = *blanks
     C                   exsr      zzinz2
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
OP1 AC     nxtscr        caseq     '03 '         sc3
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   exsr      clrsch
     C                   seton                                        lr
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = '1'
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Set OFF command key indicators
     *
     C                   setoff                                       kckekf
     C                   setoff                                       kl
     *
     *   Overlay screen with title
     *
     C                   write     title
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *   Overlay screen with subfile screen
     *
     C                   if        nxtscr = '01 '
     C                   exsr      sfldsp
     C                   read      postnrec                               50
     C                   endif
     C                   if        nxtscr = '02 '
     C                   exsr      deldsp
     C                   endif
OP1 AC                   if        nxtscr = '03 '
OP1 AC                   exsr      deldsp
OP1 AC                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       2021
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cancel = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
VW2 AC                   select
VW2 AC                   when      view = 1
510  C                   if        client = packer
510  C                   read      dsppfc                                 50
510  C                   else
     C                   read      dspsfc                                 50
510  C                   endif
VW2 AC                   when      view = 2
VW2 AC                   read      vw2sfc                                 50
VW2 AC                   when      view = 3
VW2 AC                   read      vw3sfc                                 50
VW2 AC                   endsl
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
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   write     clr0306
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   eval      *in90 = *on
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   write     clr0306
     C                   write     delrec
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag02
     C                   write     cmddel
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 wrap-up
     *
     C     scr02e        begsr
     C                   eval      nxtscr = '01 '
     C                   eval      *in90 = *off
     C                   write     clr0306
     *
     *   If delete was not canceled (no errors)
     *     then reposition to record just before first deleted rec.
     *
     C                   if        cancel = *off
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = frstky
     C                   exsr      fgtway
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     C                   if        $portn = '*NOMORE '
     C                   eval      $pocmd = '*TOP    '
     C                   else
     *
     *   Otherwise, position to last record read.
     *
     C                   eval      $pocmd = '*POSTN2 '
     C                   endif
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   exsr      optns
     C                   else
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
     C                   endsr
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  Screen 03 initialization
OP1 A*
OP1 AC     scr03i        begsr
416cA*
416cA*  Check in to make sure FTP process isn't running.
416cA*
416cAC                   call      'CHKINOUT'                           49
416cAC                   parm      '*IN'         $xtype            5
416cAC                   parm      'EXPORD'      $xdara           10
416cAC                   if        *in49
416cAC                   eval      error = *on
416cAC                   eval      wkoerr = *on
416cAC                   update    wkorec
416cAC                   eval      otaken = *off
416cAC                   eval      errmsg = em(1)
416cAC                   exsr      zm0105
416cAC                   goto      end03i
416cAC                   endif
416cA*
OP1 AC                   eval      nxtscr = '03 '
OP1 AC                   eval      *in90 = *on
OP1 AC                   move      *loval        $wkof
OP1 AC                   move      *loval        $wkou
OP1 AC                   write     clr0306
OP1 AC                   write     op1rec
OP1 AC                   eval      pagcmd = '*REFRESH'
OP1 AC                   exsr      pag03
OP1 AC                   write     cmdop1
416cAC     end03i        tag
OP1 AC                   endsr
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  Screen 03 wrap-up
OP1 A*
OP1 AC     scr03e        begsr
OP1 AC                   eval      nxtscr = '01 '
OP1 AC                   eval      *in90 = *off
OP1 AC                   write     clr0306
OP1 A*
OP1 A*   If option 1 was not canceled (no errors)
OP1 A*     then reposition to record just before first deleted rec.
OP1 A*
OP1 AC                   if        cancel = *off
OP1 AC                   eval      $pocmd = '*POSTN2 '
OP1 AC                   eval      $pofky = frstky
OP1 AC                   exsr      fgtway
OP1 AC                   eval      $pocmd = '*GETPREV'
OP1 AC                   exsr      fgtway
OP1 AC                   if        $portn = '*NOMORE '
OP1 AC                   eval      $pocmd = '*TOP    '
OP1 AC                   else
OP1 A*
OP1 A*   Otherwise, position to last record read.
OP1 A*
OP1 AC                   eval      $pocmd = '*POSTN2 '
OP1 AC                   endif
OP1 AC                   exsr      fgtway
OP1 AC                   eval      pagcmd = '*REPOS  '
OP1 AC                   exsr      pag01
OP1 AC                   exsr      optns
OP1 AC                   else
OP1 AC                   eval      $pocmd = '*POSTN2U'
OP1 AC                   eval      $pouky = $puky
OP1 AC                   exsr      fgtway
OP1 AC                   eval      pagcmd = '*REPOS  '
OP1 AC                   exsr      pag01
OP1 AC                   endif
416cA*
416cA*  Check out so FTP process can run.
416cA*
416cAC                   call      'CHKINOUT'                           49
416cAC                   parm      '*OUT'        $xtype
416cAC                   parm      'EXPORD'      $xdara
416cA*
OP1 AC                   endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     C     status        caseq     rollup        roll01
     C     status        caseq     rolldn        roll01
     C     status        caseq     comand        cmd01
     C                   cas                     ent01
     C                   endcs
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     C     status        caseq     rollup        roll02
     C     status        caseq     rolldn        roll02
     C     status        caseq     comand        cmd02
     C                   cas                     ent02
     C                   endcs
     C     endsc2        endsr
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  SC3  -  Screen 3
OP1 A*
OP1 AC     sc3           begsr
OP1 AC     status        caseq     rollup        roll03
OP1 AC     status        caseq     rolldn        roll03
OP1 AC     status        caseq     comand        cmd03
OP1 AC                   cas                     ent03
OP1 AC                   endcs
OP1 AC     endsc3        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
510 A*
510 A* Get client id.
510 A*
510 AC                   call      @getcl
510 AC                   parm                    client           10
650dAC                   parm                    clientloc        10
510 A*

720aA /free

720aA    open(e) bfcdbgflg;
720aA    if %error;
720aA      dbgflgExists = *off;
720aA    else;
720aA      dbgflgExists = *on;
720aA    endif;

720aA /end-free
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
     *  Initialize subfile (DSPSFL) record
     *
     C                   eval      recno = 1
510  C                   if        client = packer
510  C                   write     dsppsf                               79
510  C                   else
     C                   write     dspsfl                               79
510  C                   endif
222 D*                    Z-ADD1         RECNO2
VW2 AC                   write     vw2sfl                               79
222 D*                    Z-ADD1         RECNO3
VW2 AC                   write     vw3sfl                               79
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CLRSCH   Clear everything out of work file
     *
     C     clrsch        begsr
     C     wkoprt        setll     workopt
     C     wkoprt        reade     workopt                              7979
     C                   dow       not *in79
     C                   delete    wkorec
     C     wkoprt        reade     workopt                              7979
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CMD01    Screen 1 command key routine
     *
     C     cmd01         begsr
     *
     *  TEST FOR CMD3 - EXIT
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*EXIT   '
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*CANCEL '
     C                   goto      cmd01e
     C                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
     *     TEST FOR CMD5 - REFRESH
     *
     C                   if        *inke
     C                   exsr      clrsch
     C     1             do        10            x
510  C                   if        client = packer
510  C     x             chain     dsppsf                             79
510  C                   else
     C     x             chain     dspsfl                             79
510  C                   endif
222 D*R         X         CHAINVW2SFL               79
222 D*R         X         CHAINVW3SFL               79
     C                   if        not *in79
     C                   eval      option = '  '
510  C                   if        client = packer
510  C                   update    dsppsf
510  C                   else
     C                   update    dspsfl
510  C                   endif
222 D*R                   UPDATVW2SFL
222 D*R                   UPDATVW3SFL
     C                   endif
222 AC     x             chain     vw2sfl                             79
222 AC                   if        not *in79
222 AC                   eval      option = '  '
222 AC                   update    vw2sfl
222 AC                   endif
222 AC     x             chain     vw3sfl                             79
222 AC                   if        not *in79
222 AC                   eval      option = '  '
222 AC                   update    vw3sfl
222 AC                   endif
     C                   enddo
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  VERIFY AND SAVE ANY OPTIONS THAT WERE ENTERED
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           cmd01e
     *
     *  EXECUTE COMMAND KEYS THAT DID NEED THE OPTIONS VERIFIED
     *
     *  TEST FOR CMD6 - ADD RECORD
     *
     C                   if        *inkf
     C                   exsr      inzpar
     C                   eval      $pcmd = '*ADD    '
     C                   call      @chgpg
     C                   parm                    $parms
     C                   if        $prtn = '*ERROR  '
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   else
     C                   if        $prtn <> '*CANCEL '  and
     C                             $prtn <> '*EXIT   '
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
     C                   endif
     C                   endif
220 AC                   eval      pagcmd = '*REFRESH'
220 AC                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
VW2 D*  TEST FOR CMD10 - MOVE RECORD THAT CUSOR IS ON TO TOP
VW2 M*  TEST FOR CMD20 - MOVE RECORD THAT CUSOR IS ON TO TOP
     *
VW2 D*R         *INKJ     IFEQ '1'
VW2 MC                   if        *inku
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     MAKE SURE CURSOR IS ON ONE OF THE DISPLAYED RECORDS
     *
     C                   sub       10            row#
     C                   if        row# < 1  or
     C                             row# > dsplyd
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0106
     C                   goto      cmd01e
     C                   endif
     *
     *     REPOSITION RECORD THAT CURSOR IS ON TO THE TOP
     *
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = ukey(row#)
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       CMD01E
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
VW2 A*
VW2 A*  TEST FOR CMD10 - Previous view
VW2 A*
VW2 AC                   if        *inkj
VW2 AC                   if        view = 1
VW2 AC                   eval      view = maxvw
VW2 AC                   else
VW2 AC                   eval      view = view - 1
VW2 AC                   endif
VW2 AC                   eval      v = view * 2
VW2 AC                   eval      cmdln2 = cmdln(v)
VW2 AC                   eval      v = v - 1
VW2 AC                   eval      cmdln1 = cmdln(v)
VW2 AC                   goto      cmd01e
VW2 AC                   endif
VW2 A*
VW2 A*  TEST FOR CMD11 - Next view
VW2 A*
VW2 AC                   if        *inkk
VW2 AC                   if        view = maxvw
VW2 AC                   eval      view = 1
VW2 AC                   else
VW2 AC                   add       1             view
VW2 AC                   endif
VW2 AC                   eval      v = view * 2
VW2 AC                   eval      cmdln2 = cmdln(v)
VW2 AC                   eval      v = v - 1
VW2 AC                   eval      cmdln1 = cmdln(v)
VW2 AC                   goto      cmd01e
VW2 AC                   endif
     *
     *  TEST FOR CMD17 - REPOSITION TO TOP OF DISPLAY
     *
     C                   if        *inkr
     C                   eval      pagcmd = '*TOP    '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD18 - REPOSITION TO BOTTOM OF DISPLAY
     *
     C                   if        *inks
     C                   eval      pagcmd = '*BOTTOM '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *   Process non-standard function keys.
     *
     C                   exsr      zzcmd
     C     cmd01e        endsr
     *----------------------------------------------------------------
     *
     *  CMD02    Screen 2 command key routine
     *
     C     cmd02         begsr
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      cancel = *on
     C                   exsr      scr02e
     C                   goto      cmd02e
     C                   endif
     C     cmd02e        endsr
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  CMD03    Screen 3 command key routine
OP1 A*
OP1 AC     cmd03         begsr
OP1 A*
OP1 A*  TEST FOR CMD12 - PREVIOUS
OP1 A*
OP1 AC                   if        *inkl
OP1 AC                   eval      cancel = *on
OP1 AC                   exsr      scr03e
OP1 AC                   goto      cmd03e
OP1 AC                   endif
OP1 AC     cmd03e        endsr
     *----------------------------------------------------------------
     *
     *  DELADD   Add record to subfile for delete display
     *
     C     deladd        begsr
     C                   if        recno < 11
     C                   add       1             recno
222 D*R                   ADD  1         RECNO2
222 D*R                   ADD  1         RECNO3
     C                   z-add     recno         y
     *
     *  GET RECORD INFO
     *
     C                   eval      $pocmd = '*GET    '
     C                   eval      $pouky = wkokyu
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       DELADE
     *
     *  SAVE KEY TO RECORD OF FIRST SCREEN LINE
     *
     C                   if        recno = 1
     C                   eval      $wkof = wkokyf
     C                   eval      $wkou = wkokyu
     C                   endif
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
     C                   eval      option = wkoopt
510  C                   if        client = packer
510  C                   write     dsppsf
510  C                   else
     C                   write     dspsfl
510  C                   endif
VW2 AC                   write     vw2sfl
VW2 AC                   write     vw3sfl
     C                   endif
     C     delade        endsr
     *----------------------------------------------------------------
     *
     *  DELDSP   Display subfile of records marked for deletion
     *
     C     deldsp        begsr
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in81 = *on
     C                   eval      recno = 1
222 A*R                   Z-ADD1         RECNO2
222 A*R                   Z-ADD1         RECNO3
VW2 AC                   select
VW2 AC                   when      view = 1
510  C                   if        client = packer
510  C                   write     dsppfc
510  C                   else
     C                   write     dspsfc
510  C                   endif
VW2 AC                   when      view = 2
VW2 AC                   write     vw2sfc
VW2 AC                   when      view = 3
VW2 AC                   write     vw3sfc
VW2 AC                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ENT01    Screen 1 enter key routine
     *
     C     ent01         begsr
     *
     *  VERIFY AND SAVE OPTIONS
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           ent01e
     *
     *  SEE IF USER IS TRYING TO POSITION TO A CERTAIN SPOT
     *
     C                   eval      repos = *off
     C                   exsr      zzpos
     C                   if        repos = *on
     C                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*POSTN2 '
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      ent01e
     C                   endif
     *
     *  IF NOT POSITIONING THEN EXECUTE THE ENTERED OPTIONS
     *
     C                   exsr      optns
     *
     *  IF OPTION WAS NOT TAKEN THEN RETURN LIKE CMD12 WAS ENTERED
     *
     *R         OTAKEN    IFEQ '0'
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   GOTO ENT01E
     *R                   END
     C     ent01e        endsr
     *----------------------------------------------------------------
     *
     *  ENT02    Screen 2 enter key routine
     *
     C     ent02         begsr
     *
     *  Save first delete key.
     *
     C                   eval      frstky = $puky
     *
     *  Delete the records that have been selected
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C                   dou       stop = '1'
     C     wkoprt        reade     workopt                                79
414aAC                   eval      *in21 = *off
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     *
     C                   if        wkoopt = ' 4'
     *
     *  Call delete program
     *
     C                   exsr      inzpar
     C                   eval      $pcmd = '*DELETE '
     C                   eval      $puky = wkokyu
414aA*
414aA*    Verify that route is still at "closed" status.
414aA*
414aAC                   eval      dsukey = $puky
414aAC                   exsr      zzckst
414aAC                   if        stserr = *on
414aAC                   delete    wkorec
414aAC                   iter
414aAC                   endif
414aA*
     C                   call      @delpg
     C                   parm                    $parms
     *
     *     Error occured - Error message sent back
     *
     C                   if        $prtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     *
     *     Error occured - Error message sent to program msgq
     *
     C                   if        $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   else
     *
     *     Delete canceled
     *
     C                   if        $prtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   else
     *
     *     Delete was successful.
     *
     C                   if        $prtn = '*OK     '
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   if        cancel = '0'
     C                   delete    wkorec
     C                   else
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   endif
     C                   endif
     *
     C                   endif
     C                   enddo
414aA*
414aA*    If ERROR flag is on due to one or more routes no
414aA*    longer at 'closed' status, set on CANCEL.
414aA*
414aAC                   if        error = *on
414aAC                   eval      cancel = error
414aAC                   endif
     C                   exsr      scr02e
     C     ent02e        endsr
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  ENT03    Screen 3 enter key routine
OP1 A*
OP1 AC     ent03         begsr
OP1 A*
OP1 A*  Save first option 1 key.
OP1 A*
OP1 AC                   eval      frstky = $puky
OP1 A*
OP1 A*  Perform option 1 on the records that have been selected
OP1 A*
OP1 AC     wkoprt        setll     workopt
OP1 AC                   eval      stop = *off
OP1 AC                   dou       stop = '1'
OP1 AC     wkoprt        reade     workopt                                79
414aAC                   eval      *in21 = *off
OP1 AC                   if        *in79
OP1 AC                   eval      stop = *on
OP1 AC                   else
OP1 A*
OP1 AC                   if        wkoopt = ' 1'
414cA*
414cA*  Call Route Summary by Stop Report
414cA*
MJKbAC                   if           client = mjkeln
TPC AC                             or client = tpc
MJKbA*       Bypass printing report.
MJKbAC                   else
MJKbA*
414cAC                   move      $pwhse        $rwhse
414cAC                   call      'OR670CL'
414cAC                   parm                    $rwhse            3
414cAC                   parm      rhrtid        $rrtid            5
414cAC                   parm      ' '           $rrtn             8
530 AC                   parm      'N'           $rovr             1
MJKbAC                   endif
KFSbA*
KFSbAC                   if        client = Kellys
IFDbAC                             or client = IFD
KFSbAC                   call      'OR660CCL'
KFSbAC                   parm      ' '           $rcmd             8
KFSbAC                   parm      '*SUMMARY'    $rtype            8
KFSbAC                   parm                    $rwhse
KFSbAC                   parm      rhrtid        $rrtid
KFSbAC                   parm      ' '           $rrtn
KFSbAC                   parm      'N'           $rovr
KFSbAC                   endif
MJKAA*
MJKaA*  Call Route Summary by Stop Report
MJKaA*
MJKaAC                   if        client = mjkeln  or
MJKaAC                             client = dairyl
KFSaAC                             or client = Kellys
HMWaAC                             or client = HMWagner
CSPaAC                             or client = CoastalSunbelt
IFDaAC                             or client = IFD
ADF AC                             or client = AandDFoods
TPC AC                             or client = tpc
MJKaAC                   call      'OR671CL'
MJKaAC                   parm                    $rwhse
MJKaAC                   parm      rhrtid        $rrtid
MJKaAC                   parm      ' '           $rrtn
MJKaAC                   parm      'N'           $rovr
MJKaAC                   parm      'E'           $rtds             1
MJKaAC                   endif
OP1 A*
OP1 A*  Call option 1 program
OP1 A*
     *
411 A*  4.11 Notes
     *
     *    The call to RH151 has been left alone, except to include
     *    it in the new select statement. Notice, that RH151 will
     *    never display an error because it does not use $PRTN.
     *
OP1 AC                   eval      $puky = wkokyu
OP1 AC                   eval      dsukey = $puky
414aA*
414aA*    Verify that route is still at "closed" status.
414aA*
414aAC                   exsr      zzckst
414aAC                   if        stserr = *on
414aAC                   delete    wkorec
414aAC                   iter
414aAC                   endif
417aA*    Set Inuse flag for export processing.
417aA*
417aAC                   eval      $icmd = '*INUSE4 '
417aAC                   exsr      zziuse
417aAC                   if        stserr = *on
417aAC                   goto      ent03e
417aAC                   endif
520bA*
520bA*    Update unique piece number recs' scan qty, file ORDP.
520bA*
520cAC                   eval      $whs30 = $pwhse
520bAC                   call      'OR633'
520bA****520cD            PARM           $PWHSE
520cMC                   parm                    $whs30
520bAC                   parm                    rhrtid
417aA*
HAR A*    Conditionally call pgms to write XML/POD export files
HAR A*    and XML/ASN export files.
HAR A*
HAR AC                   if        client = harbor
     *
HARaAC                   eval      $whs30 = $pwhse
HAR AC                   call      'XM155'
HARaD**                   PARM $PWHSE    $WHS15 155
HARaMC                   parm      $pwhse        $whs30            3 0
HAR AC                   parm      rhrtid        $brtid            5
HAR AC                   parm      rhrte         $btrte            5
HAR AC                   parm      ' '           $prtn
     *
HAR AC                   endif

720aA*    Don't do Trax logic in this program any more, instead
720aA*      call it from RH155S
720aAC                   goto      skipTR810
     *
700aM*    If client is using TRAX call TR810 and TR811 to create
700aM*    Trax(c) xml files.
530aA*
530aAC                   if        optrax = 'Y'
710aAC                   goto      skipMerge
640eA*
640eA*    If this is a Trax merged route, do not build Trax xml unless
640eA*    all of the connected routes have also been exported.
640eA*
640eAC                   eval      parentRte = rhrtid
640eAC     keyrs         setll     ttmerg2
640eAC                   dow       forevr = forevr
640eAC     keyrs         reade     ttmerg2
640eAC                   if        %eof
640eAC                   leave
640eAC                   else
640eAC                   eval      parentRte = t2_ttmpri
640eAC                   leave
640eAC                   endif
640eAC                   enddo
640eA*
640eAC                   eval      firstpass = *on
640eAC     keyttm        setll     ttmerg1
640eAC                   dow       forevr = forevr
640eAC     keyttm        reade     ttmerg1
640eAC                   if        %eof
640eAC                   leave
640eAC                   endif
640eA*
640eA*  Don't build Trax xml if this is a child being exported
640eA*  and the parent route has not yet been exported.
640eAC                   if        firstpass = *on and parentRte <> rhrtid
640eAC     keyttm        chain     rtehed
640eAC                   if        %found(rtehed)
640eAC                             and r_rhstat = '6'
640eAC                   else
640eAC                   goto      skipTR810
640eAC                   endif
640eAC                   endif
640eAC                   eval      firstpass = *off
640eA*
640eAC                   if        t1_rhstat <> '6'
640eAC                             and t1_ttmcri <> rhrtid
640eAC                   goto      skipTR810
640eAC                   endif
640eAC                   enddo

710aAC     skipMerge     tag

530aAC                   eval      usemp# = 0
530aAC     keyrs         chain     ttrte                              77
530aAC                   if        not *in77
530aAC     ttrusr        chain     piruser                            77
530aAC                   endif
530aAC                   move      usemp#        $emp#
530aAC                   eval      $whs30 = $pwhse
530aAC                   call      'TR810'
530aAC                   parm      $pwhse        $whs30
530aAC                   parm      rhrtid        $brtid
530aAC                   parm                    $emp#
530aAC                   parm      ' '           $filsn           30
530aAC                   parm      ' '           $prtn
530aAC                   parm      ' '           $perm
640dA*      Prevent ZMQMSG routine from executing.
640dAC                   if        $prtn = '*OK'
640dAC                   eval      $prtn = ' '
640dAC                   endif
700aA*
700aAC                   call      'TR811'
700aAC                   parm      $pwhse        $whs30
700aAC                   parm      rhrtid        $brtid
700aAC                   parm                    $emp#
700aAC                   parm      ' '           $filsn           30
700aAC                   parm      ' '           $prtn
700aAC                   parm      ' '           $perm
700aA*      Prevent ZMQMSG routine from executing.
700aAC                   if        $prtn = '*OK'
700aAC                   eval      $prtn = ' '
700aAC                   endif
700aA*
700aAC                   endif
     *
640eAC     skipTR810     tag
     *
OP1 A*R                   CALL 'OR605'
CDI AC                   if        client = cdi
CDI AC                   eval      opftp = 'N'
CDI AC                   endif

411 AC                   select

SWTaAC                   when      opftp = 'Y'
PCK MC                             and (client = SWT
PCK AC                              or  client = PACK730)
SWTaAC                   call      'RH155CL2'
SWTaAC                   parm      #prog         $bpgm            10
SWTaAC                   parm      $pwhse        $brwhs            3 0
SWTaAC                   parm      rhrtid        $brtid
SWTaAC                   parm      rhrte         $btrte
SWTaAC                   parm      ' '           $prtn
SWTaAC                   parm      ' '           $pmsg

411 AC                   when      opftp = 'Y'
DRYbA*
DRYbAC                   select
DRYbAC                   when          client = Dairyland
750 Ac                                 or %subst(rhrte:1:3)='#SR'
DRYbAC                   eval      $rwhse = %editc($pwhse:'X')
750 Ac                   if        %subst(rhrte:1:3) = '#SR'
750 AC                   call      'SREXP'
750 AC                   parm                    $rwhse
750 AC                   parm      rhrtid        pRtid             5
750 AC                   parm      rhrte         pRte              5
750 AC                   parm      *blanks       pMessage         99
750 Ac*  write error message to queue if one returned
750 AC                   if        pMessage <> *blanks
750 AC                   eval      error = *on
750 AC                   eval      cancel = *on
750 AC                   eval      stop = *on
750 AC                   eval      #msgk = pMessage
750 AC                   exsr      zmqmsg
750 Ac                   endif
750 Ac                   else
DRYbA*      Call Stage export to Host pgm.
DRYdAC                   eval      $bcmd = '*ALL'
DRYbAC                   call      'RH155SCL'
DRYbAC                   parm                    $bcmd
DRYbAC                   parm                    $rwhse
DRYbAC                   parm      rhrtid        $brtid
DRYbAC                   parm      rhrte         $btrte
DRYbAC                   parm      ' '           $prtn
750 Ac                   endif
DRYbA*
DRYbAC                   other
411 AC                   call      'RH155CL'
411 AC                   parm      #prog         $bpgm            10
411 AC                   parm      $pwhse        $brwhs            3 0
411 AC                   parm      rhrtid        $brtid
411 AC                   parm      rhrte         $btrte
411 AC                   parm      ' '           $prtn
411 AC                   parm      ' '           $pmsg
DRYbAC                   endsl
DRYbA*

640aAC                   when      opftp = 'S'
730aAc                             or opftp ='R'
640aAC                   if        client = cheney
640aAC                   eval      $bcmd = '*HDRDTL'
640aAC                   else
640aAC                   eval      $bcmd = '*ALL'
640aAC                   endif
JSLaAC                   if        client <> jsilvert
WILaAC                             and client <> willfoods
640aAC                   call      'RH155S'
640aAC                   parm                    $bcmd             8
640aAC                   parm      $pwhse        $brwhs            3 0
640aAC                   parm      rhrtid        $brtid
640aAC                   parm      rhrte         $btrte
640aAC                   parm      ' '           $prtn
JSLaAC                   endif
640bA*
640bAC                   if        $prtn = ' '
KFScAC                             and client <> Kellys
GRC AC                             and client <> Greco
640bA*      Call Stage export to Host pgm.
640bAC                   eval      $rwhse = %editc($pwhse:'X')
640bAC                   call      'RH155SCL'
640bAC                   parm                    $bcmd
640bAC                   parm                    $rwhse
640bAC                   parm      rhrtid        $brtid
640bAC                   parm      rhrte         $btrte
640bAC                   parm      ' '           $prtn
640bAC                   endif
640bA*
411 AC                   other
OP1 AC                   call      'RH151'
OP1 AC                   parm      $pwhse        $brwhs
OP1 AC                   parm      rhrtid        $brtid
OP1 AC                   parm      rhrte         $btrte
OP1 AC                   parm      ' '           $brtn             8
411 AC                   endsl
OP1 A*
OP1 A*     Error occured - Error message sent to program msgq
OP1 A*
OP1 AC                   if        $prtn = '*PGMQ   '
OP1 AC                   eval      error = *on
OP1 AC                   eval      cancel = *on
OP1 AC                   eval      stop = *on
OP1 AC                   eval      #msgk = $pmsg
OP1 AC                   exsr      zmqmsg
OP1 AC                   else
OP1 A*
OP1 A*     Option 1 was successful.
OP1 A*
OP1 AC                   if        $prtn = '*OK     '
OP1 AC                   eval      #msgk = $pmsg
OP1 AC                   exsr      zmqmsg
OP1 AC                   endif
OP1 AC                   endif
OP1 AC                   if        cancel = '0'
OP1 AC                   delete    wkorec
OP1 AC                   else
OP1 AC                   eval      wkoerr = *on
OP1 AC                   update    wkorec
OP1 AC                   endif
OP1 AC                   endif
417aA*    Reset Inuse flag.
417aA*
DRYeAC                   if        client = Dairyland
DRYeA*      Do not clear Inuse flag for route. Export job submitted
DRYeA*      Batch for processing. Inuse flag will be cleared in RH155S.
DRYeAC                   else
DRYeA*
417aAC                   eval      $icmd = '*CLEAR  '
417aAC                   exsr      zziuse
DRYeAC                   endif
OP1 A*
OP1 AC                   endif
OP1 AC                   enddo
PANaA*   Build PFILES for Panos
PANaAC                   if        client = panos
PANaAC                   exsr      runpfiles
PANaAC                   endif
PANaA*
414aA*
414aA*    If ERROR flag is on due to one or more routes no
414aA*    longer at 'closed' status, set on CANCEL.
414aA*
414aAC                   if        error = *on
414aAC                   eval      cancel = error
414aAC                   endif
OP1 AC                   exsr      scr03e
OP1 AC     ent03e        endsr
     *----------------------------------------------------------------
     *
     *  FGTWAY   Gateway to file handling routines
     *
     *    Input Parameters
     *      $POCMD   *INIT    - Initialize and return
     *               *GET     - Get record for $POUKY value
     *               *GETNEXT - Get next record
     *               *GETPREV - Get previous record
     *               *WRITPOS - Write position record to display
     *               *READPOS - Read position record
     *               *POSTN2  - Position to $POFKY
     *               *POSTN2U - Position to $POUKY
     *               *TOP     - Position to top of file
     *               *BOTTOM  - Position to bottom of file
     *      $POFKY   Key for positioning within file
     *      $POUKY   Unique key used for change/delete operations
     *
     *    Returned Parameters
     *      $PORTN   *NOMORE  - Beginning/End of file was reached
     *               *NOTFND  - Record not found on a GET
     *               *FOUND   - Record found
     *               *REPOS   - Repositioning took place
     *               *ERROR   - Error occured
     *      $POERM   Error message
     *
     C     fgtway        begsr
     C                   eval      $portn = *blanks
     C     $pocmd        caseq     '*GET    '    fget
     C     $pocmd        caseq     '*GETNEXT'    fgetn
     C     $pocmd        caseq     '*GETPREV'    fgetp
     C     $pocmd        caseq     '*POSTN2 '    fpos2
     C     $pocmd        caseq     '*POSTN2U'    fpos2u
     C     $pocmd        caseq     '*TOP'        zzpos2
     C     $pocmd        caseq     '*BOTTOM'     zzpos2
     C                   endcs
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGET     Get record using file with unique key
     *
     *              In this case the lookup file and the unique key
     *              file are the same.
     *
     C     fget          begsr
     C                   eval      dsukey = $pouky
     C                   exsr      zzfget
     C                   if        *in79
     C                   eval      $portn = '*NOTFND '
     C                   eval      $pouky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGETN    Get next record
     *
     C     fgetn         begsr
     C                   exsr      zzfgtn
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   eval      $pouky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGETP    Get previous record
     *
     C     fgetp         begsr
     C                   exsr      zzfgtp
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   eval      $pouky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS2    Position to record
     *
     C     fpos2         begsr
     C                   eval      dsfkey = $pofky
     C     fileky        setll     record
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS2U   Position to record using unique key
     *
     C     fpos2u        begsr
     *
     *  GET RECORD FOR UNIQUE KEY
     *
     C                   exsr      fget
     *
     *  POSITION TO RECORD IN LOOKUP FILE
     *
     C                   exsr      fpos2
     C                   endsr
     *----------------------------------------------------------------
     *
     *  INZPAR   Initialize parameters for calling add/chg/del program
     *
     C     inzpar        begsr
     C                   clear                   $parms
     C                   eval      $pprg = #prog
     C                   eval      $puky = $prtky
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPTNS    Perform options that user entered
     *
     C     optns         begsr
     C                   eval      otaken = *off
OP1 A*
OP1 A*     Do all option 1's together.
OP1 A*
OP1 AC     wkoprt        setll     workopt
OP1 AC                   eval      stop = *off
OP1 AC     wkoprt        reade     workopt                                79
OP1 AC                   dow       not *in79  and
OP1 AC                             wkoopt <> ' 1'
OP1 AC     wkoprt        reade     workopt                                79
OP1 AC                   enddo
OP1 AC                   if        not *in79  and
OP1 AC                             wkoopt = ' 1'
OP1 AC                   eval      otaken = *on
OP1 AC                   eval      $puky = wkokyu
OP1 AC                   exsr      scr03i
OP1 AC                   goto      optnse
OP1 AC                   endif
     *
     *     DO ALL DELETES FIRST (OPTION 4)
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C     wkoprt        reade     workopt                                79
     C                   dow       not *in79  and
     C                             wkoopt <> ' 4'
     C     wkoprt        reade     workopt                                79
     C                   enddo
     C                   if        not *in79  and
     C                             wkoopt = ' 4'
     C                   eval      otaken = *on
     C                   eval      $puky = wkokyu
     C                   exsr      scr02i
     C                   goto      optnse
     C                   endif
     *
     *  THEN DO THE OTHER OPTIONS IN THE ORDER THEY WERE ENTERED
     *     STOP WHEN NO MORE OPTIONS OR USER ENTERS CMD12
     *
     C     wkoprt        setll     workopt
     C                   eval      cancel = *off
     C                   eval      stop = *off
     C                   dou       stop = '1'  or
     C                             cancel = '1'
     C     wkoprt        reade     workopt                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   if        wkoopt <> '  '
     C                   eval      otaken = *on
     C                   exsr      optns2
     C     wkounq        chain     workopt                            78
     C                   eval      refrsh = *on
     C                   if        error = '0'
     C                   delete    wkorec
     C                   endif
     C                   if        cancel = '1'
     C                   eval      stop = *on
     C                   if        error = '1'
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   endif
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   endif
     C                   endif
     C                   endif
     C                   enddo
     C                   if        refrsh = '1'
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   endif
     C     optnse        endsr
     *----------------------------------------------------------------
     *
     *  OPTNS2   Execute individual options
     *
     C     optns2        begsr
     C                   exsr      inzpar
     C                   eval      $puky = wkokyu
     *
     *   Change
     *
     C                   if        wkoopt = ' 2'
     C                   eval      $pcmd = '*CHANGE '
     C                   call      @chgpg
     C                   parm                    $parms
     C                   else
     *
     *   View
     *
     C                   if        wkoopt = ' 5'
     C                   eval      $pcmd = '*VIEW   '
     C                   call      @chgpg
     C                   parm                    $parms
     C                   else
     *
     *   Reprint
     *
     C                   if        wkoopt = ' 6'
     *R                   CALL 'PS130'
     *R                   PARM           $PUKY
     *R                   PARM           $PRTN
414cAC                   eval      $pcmd = '*REPRINT'
414cAC                   call      @prtpg
414cAC                   parm                    $pcmd
414cAC                   parm                    $ptype
414cAC                   parm                    $pwhse
414cAC                   parm                    $prte
414cAC                   parm                    $prtid
414cAC                   parm                    $ptruk
414cAC                   parm                    $prtn
     C                   else
530aA*
530aA*   Assign driver to route.
530aA*
530aAC                   if        wkoopt = '14'
530aAC                   if        optrax <> 'Y'
530aAC                   eval      error = *on
530aAC                   eval      wkoerr = *on
530aAC                   update    wkorec
530aAC                   eval      otaken = *off
530aAC                   eval      errmsg = em(2)
530aAC                   exsr      zm0105
530aAC                   goto      endop2
530aAC                   endif
530aAC                   move      $pwhse        $awhse
530aAC                   call      'TR850'
530aAC                   parm                    $pprg
530aAC                   parm                    $awhse
530aAC                   parm                    $prtid
530aAC                   parm      *blanks       $prtn
530aAC                   else
700bA*
700bA*   Get AMPBOX info
700bA*
700bAC                   if        wkoopt = 'BX'
700bAC                   eval      $pcmd = '*AMPINFO'
700bAC                   call      'BX310'
700bAC                   parm                    $pcmd
700bAC                   parm                    $pwhse
700bAC                   parm                    $cvd6i
700bAC                   parm                    $prte
700bAC                   parm                    $prtid
700bAC                   parm                    $prtn
700bAC                   else
     *
     C                   exsr      zzopt
700bAC                   endif
530aAC                   endif
     C                   endif
     C                   endif
     C                   endif
     *
     C                   if        $prtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   else
     C                   if        $prtn = '*ERROR  '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $prtn = '*PGMQ   '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
530aMC     endop2        endsr
     *----------------------------------------------------------------
     *
     *  PAG01    Screen 1 page routines
     *
     C     pag01         begsr
     *
     *  NEXT PAGE
     *
     C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag1fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV   '
     C                   exsr      pag1bk
     C                   else
     *
     *  TOP
     *
     C                   if        pagcmd = '*TOP    '
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       PAG01E
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      forceb = *off
     C                   exsr      pag1fw
     C                   else
     *
     *  BOTTOM
     *
     C                   if        pagcmd = '*BOTTOM '
     C                   eval      bot = *on
     C                   eval      dsplyd = 0
     C                   exsr      pag1bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C                   if        fkey(1) = *loval
     C                   eval      $pocmd = '*TOP    '
     C                   else
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = fkey(1)
     C                   endif
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       PAG01E
     C                   eval      bot = *off
     C                   exsr      pag1fw
     C                   else
     *
     *  REPOSITIONING
     *
     C                   if        pagcmd = '*REPOS  '
     C                   eval      bot = *off
     C                   eval      forceb = *off
     C                   exsr      pag1fw
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = *blanks
     C     pag01e        endsr
     *----------------------------------------------------------------
     *
     *  PAG02    Screen 2 page routines
     *
     C     pag02         begsr
     *
     *  NEXT PAGE
     *
     C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag2fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV   '
     C                   exsr      pag2bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C     deltop        setll     workopt
     C                   eval      bot = *off
     C                   exsr      pag2fw
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = *blanks
     C     pag02e        endsr
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  PAG03    Screen 3 page routines
OP1 A*
OP1 AC     pag03         begsr
OP1 A*
OP1 A*  NEXT PAGE
OP1 A*
OP1 AC                   if        pagcmd = '*NEXT   '
OP1 AC                   exsr      pag3fw
OP1 AC                   else
OP1 A*
OP1 A*  PREVIOUS PAGE
OP1 A*
OP1 AC                   if        pagcmd = '*PREV   '
OP1 AC                   exsr      pag3bk
OP1 AC                   else
OP1 A*
OP1 A*  REFRESH SCREEN
OP1 A*
OP1 AC                   if        pagcmd = '*REFRESH'
OP1 AC     deltop        setll     workopt
OP1 AC                   eval      bot = *off
OP1 AC                   exsr      pag3fw
OP1 AC                   endif
OP1 AC                   endif
OP1 AC                   endif
OP1 AC                   eval      pagcmd = *blanks
OP1 AC     pag03e        endsr
     *----------------------------------------------------------------
     *
     *  PAG1FW   Let's see that next page of records
     *
     C     pag1fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     '1'           endf
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   exsr      sflclr
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     *
     *  GET 10 RECORDS TO DISPLAY
     *
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfac
     C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
     C                   if        p >= 10
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C     endfac        tag
     C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     C     endf          endsr
     *----------------------------------------------------------------
     *
     *  PAG1BK   Let's see the previous page
     *
     C     pag1bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     '1'           endb
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     C     dsplyd        add       10            goback
     C                   if        bot = '1'
     C                   if        goback = 10
     C                   eval      forceb = *on
     C                   endif
     C                   eval      $pocmd = '*BOTTOM '
     C                   exsr      fgtway
     C                   add       1             goback
     C                   endif
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      stop = *off
     *
     *  READ SPECIFIED FLITCHES FILE
     *
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     *
     *  HIT TOP OF FILE
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk
     C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C     endbk         tag
     C                   enddo
     *
     * IF THE TOP WAS REACHED THEN POSITION POINTER TO TOP OF FILE
     *
     C                   if        top = '1'
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     C                   endif
     C                   exsr      pag1fw
     C     endb          endsr
     *----------------------------------------------------------------
     *
     *  PAG2FW   Let's see that next page of delete records
     *
     C     pag2fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     '1'           endf2
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   exsr      sflclr
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     *
     *  GET 10 RECORDS TO DISPLAY
     *
     C                   dou       stop = '1'
     C     wkoprt        reade     workopt                                79
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfw2
     C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   exsr      deladd
     C                   if        p >= 10
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C                   endif
     C     endfw2        tag
     C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     C     endf2         endsr
     *----------------------------------------------------------------
     *
     *  PAG2BK   Let's see the previous page of delete records
     *
     C     pag2bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     '1'           endb2
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     C     dsplyd        add       10            goback
     C                   if        bot = '1'
     C     wkoprt        setgt     workopt
     C                   add       1             goback
     C                   endif
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      stop = *off
     *
     *  READ SPECIFIED FLITCHES FILE
     *
     C                   dou       stop = '1'
     C     wkoprt        readpe    workopt                                79
     *
     *  HIT TOP OF FILE
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk2
     C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C                   endif
     C     endbk2        tag
     C                   enddo
     *
     * IF WE HIT THE TOP REPOSITION POINTER TO TOP OF FILE
     *
     C                   if        top = '1'
     C     wkoprt        setll     workopt
     C                   endif
     C                   exsr      pag2fw
     C     endb2         endsr
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  PAG3FW   Let's see that next page of delete records
OP1 A*
OP1 AC     pag3fw        begsr
OP1 A*
OP1 A*  IF WE ARE AT THE BOTTOM THEN DO NOTHING
OP1 A*
OP1 AC     bot           cabeq     '1'           endf3
OP1 A*
OP1 A*  INITIALIZE VARIABLES FOR LOOKUP
OP1 A*
OP1 AC                   exsr      sflclr
OP1 AC                   move      *loval        $wkof
OP1 AC                   move      *loval        $wkou
OP1 AC                   eval      bot = *off
OP1 AC                   eval      top = *off
OP1 AC                   eval      stop = *off
OP1 AC                   eval      p = 0
OP1 A*
OP1 A*  GET 10 RECORDS TO DISPLAY
OP1 A*
OP1 AC                   dou       stop = '1'
OP1 AC     wkoprt        reade     workopt                                79
OP1 A*
OP1 A*  OUT OF RECORDS - INFORM USER AND SET FLAG
OP1 A*
OP1 AC                   if        *in79
OP1 AC                   eval      stop = *on
OP1 AC                   eval      bot = *on
OP1 AC                   eval      moreln = 'Bottom '
OP1 AC                   goto      endfw3
OP1 AC                   endif
OP1 A*
OP1 A*  RECORD READ - STOP AFTER 10 GOOD RECORDS
OP1 A*
OP1 AC                   if        wkoopt = ' 1'
OP1 AC                   add       1             p
OP1 AC                   exsr      deladd
OP1 AC                   if        p >= 10
OP1 AC                   eval      stop = *on
OP1 AC                   if        forceb = '1'
OP1 AC                   eval      bot = *on
OP1 AC                   eval      moreln = 'Bottom '
OP1 AC                   else
OP1 AC                   eval      moreln = 'More...'
OP1 AC                   endif
OP1 AC                   endif
OP1 AC                   endif
OP1 AC     endfw3        tag
OP1 AC                   enddo
OP1 A*
OP1 A*  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
OP1 A*
OP1 AC                   eval      dsplyd = p
OP1 AC                   eval      forceb = *off
OP1 AC     endf3         endsr
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  PAG3BK   Let's see the previous page of delete records
OP1 A*
OP1 AC     pag3bk        begsr
OP1 A*
OP1 A*  IF WE ARE AT THE TOP THEN DO NOTHING
OP1 A*
OP1 AC     top           cabeq     '1'           endb3
OP1 AC                   eval      forceb = *off
OP1 A*
OP1 A*  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
OP1 A*
OP1 AC     dsplyd        add       10            goback
OP1 AC                   if        bot = '1'
OP1 AC     wkoprt        setgt     workopt
OP1 AC                   add       1             goback
OP1 AC                   endif
OP1 A*
OP1 A*  INITIALIZE VARIABLES FOR LOOKUP
OP1 A*
OP1 AC                   eval      p = 0
OP1 AC                   eval      top = *off
OP1 AC                   eval      bot = *off
OP1 AC                   eval      stop = *off
OP1 A*
OP1 A*  READ SPECIFIED FLITCHES FILE
OP1 A*
OP1 AC                   dou       stop = '1'
OP1 AC     wkoprt        readpe    workopt                                79
OP1 A*
OP1 A*  HIT TOP OF FILE
OP1 A*
OP1 AC                   if        *in79
OP1 AC                   eval      stop = *on
OP1 AC                   eval      top = *on
OP1 AC                   goto      endbk3
OP1 AC                   endif
OP1 A*
OP1 A*  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
OP1 A*
OP1 AC                   if        wkoopt = ' 1'
OP1 AC                   add       1             p
OP1 AC                   if        p >= goback
OP1 AC                   eval      stop = *on
OP1 AC                   endif
OP1 AC                   endif
OP1 AC     endbk3        tag
OP1 AC                   enddo
OP1 A*
OP1 A* IF WE HIT THE TOP REPOSITION POINTER TO TOP OF FILE
OP1 A*
OP1 AC                   if        top = '1'
OP1 AC     wkoprt        setll     workopt
OP1 AC                   endif
OP1 AC                   exsr      pag3fw
OP1 AC     endb3         endsr
     *----------------------------------------------------------------
     *
     *  ROLL01   Screen 1 roll up/down routine
     *
     C     roll01        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     C     rol01e        endsr
     *----------------------------------------------------------------
     *
     *  ROLL02   Screen 2 roll up/down routine
     *
     C     roll02        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     C     rol02e        endsr
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  ROLL03   Screen 3 roll up/down routine
OP1 A*
OP1 AC     roll03        begsr
OP1 A*
OP1 A*  TEST FOR ROLLUP
OP1 A*
OP1 AC                   if        status = rollup
OP1 AC                   eval      pagcmd = '*NEXT   '
OP1 AC                   exsr      pag03
OP1 AC                   goto      rol03e
OP1 AC                   endif
OP1 A*
OP1 A*  TEST FOR ROLLDOWN
OP1 A*
OP1 AC                   if        status = rolldn
OP1 AC                   eval      pagcmd = '*PREV   '
OP1 AC                   exsr      pag03
OP1 AC                   goto      rol03e
OP1 AC                   endif
OP1 AC     rol03e        endsr
     *----------------------------------------------------------------
     *
     *  SAVOPT   Verify and save options that were entered
     *
     C     savopt        begsr
     *
     *  READ ONLY THE CHANGED OPTIONS
     *
     C                   eval      nomore = *off
     C                   dou       nomore = '1'
     C                   eval      *in21 = *off
VW2 AC                   select
VW2 AC                   when      view = 1
510  C                   if        client = packer
510  C                   readc     dsppsf                                 79
510  C                   else
     C                   readc     dspsfl                                 79
510  C                   endif
VW2 AC                   when      view = 2
VW2 AC                   readc     vw2sfl                                 79
VW2 AC                   when      view = 3
VW2 AC                   readc     vw3sfl                                 79
VW2 AC                   endsl
     C                   if        *in79
     C                   eval      nomore = *on
     C                   goto      enddo1
     C                   endif
     *
     *  DISPLAY ERROR IF OPTION IS NOT VALID
     *
     C                   if        option <> *blanks
     C                   movea     option        a2
     C                   if        a2(2) = ' '
     C                   eval      a2(2) = a2(1)
     C                   eval      a2(1) = ' '
     C                   movea     a2            option
     C                   endif
     *
     *    LOOK UP OPTION IN PROFILE - ERROR IF NOT FOUND
     *
     C     option        lookup    zopt                                   50
     C                   if        not *in50
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0108
     C                   endif
     C                   endif
     *
     *  SAVE OPTION
     *
VW2 AC                   select
VW2 AC                   when      view = 1
     C                   z-add     recno         y
VW2 AC                   when      view = 2
222 D*R                   Z-ADDRECNO2    Y       30
222 MC                   z-add     recno         y
VW2 AC                   when      view = 3
222 D*R                   Z-ADDRECNO3    Y       30
222 MC                   z-add     recno         y
VW2 AC                   endsl
414aA*
414aA*    Verify that route is still at "closed" status.
414aA*
414aAC                   select
414aAC                   when      option = ' 1'
414aAC                   eval      dsukey = fkey(y)
414aAC                   exsr      zzckst
414aAC                   endsl
414aA*
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C     wkounq        chain     workopt                            79
     C                   if        not *in79
     C                   if        option = *blanks
     C                   delete    wkorec
     C                   else
     C                   eval      wkoopt = option
     C                   move      *in21         wkoerr
     C                   update    wkorec
     C                   endif
     C                   else
     C                   if        option <> *blanks
     C                   eval      wkousr = #user
     C                   eval      wkopgm = #prog
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C                   eval      wkoopt = option
     C                   move      *in21         wkoerr
     C                   write     wkorec
     C                   endif
     C                   endif
     C     enddo1        tag
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     C                   if        reccnt < 11
     C                   add       1             reccnt
     C                   eval      recno = reccnt
222 D*R                   Z-ADDRECCNT    RECNO2
222 D*R                   Z-ADDRECCNT    RECNO3
     C                   z-add     reccnt        y
     *
     *  SAVE FILE AND UNIQUE KEYS
     *
     C                   eval      fkey(y) = $pofky
     C                   eval      ukey(y) = $pouky
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
510  C                   if        client = packer
510  C                   write     dsppsf
510  C                   else
     C                   write     dspsfl
510  C                   endif
VW2 AC                   write     vw2sfl
VW2 AC                   write     vw3sfl
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      *in81 = *off
     C                   eval      *in82 = *off
     C                   eval      *in83 = *on
     C                   eval      *in84 = *on
     *
510  C                   if        client = packer
510  C                   write     dsppfc
510  C                   else
     C                   write     dspsfc
510  C                   endif
VW2 AC                   write     vw2sfc
VW2 AC                   write     vw3sfc
     C                   eval      reccnt = 0
     C                   eval      posrec = 1
     C                   eval      recno = 0
222 D*R                   Z-ADD0         RECNO2  40
222 D*R                   Z-ADD0         RECNO3  40
     *
     C                   eval      *in82 = *on
     C                   eval      *in83 = *off
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     C                   write     optrec
     C                   write     cmdrec
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     C                   write     postnrec
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflopt
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> '1'
VW2 AC                   select
VW2 AC                   when      view = 1
510  C                   if        client = packer
510  C     1             chain     dsppsf                             79
510  C                   else
     C     1             chain     dspsfl                             79
510  C                   endif
     C                   if        not *in79
     C                   eval      *in20 = *on
510  C                   if        client = packer
510  C                   update    dsppsf
510  C                   else
     C                   update    dspsfl
510  C                   endif
     C                   endif
VW2 AC                   when      view = 2
VW2 AC     1             chain     vw2sfl                             79
VW2 AC                   if        not *in79
VW2 AC                   eval      *in20 = *on
VW2 AC                   update    vw2sfl
VW2 AC                   endif
VW2 AC                   when      view = 3
VW2 AC     1             chain     vw3sfl                             79
VW2 AC                   if        not *in79
VW2 AC                   eval      *in20 = *on
VW2 AC                   update    vw3sfl
VW2 AC                   endif
VW2 AC                   endsl
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
222 D*R         RECCNT    IFGT 0
     C                   eval      *in81 = *on
222 D*R                   ENDIF
     C                   eval      recno = posrec
222 D*R                   Z-ADDPOSREC    RECNO2
222 D*R                   Z-ADDPOSREC    RECNO3
VW2 AC                   select
VW2 AC                   when      view = 1
510  C                   if        client = packer
510  C                   write     dsppfc
510  C                   else
     C                   write     dspsfc
510  C                   endif
VW2 AC                   when      view = 2
VW2 AC                   write     vw2sfc
VW2 AC                   when      view = 3
VW2 AC                   write     vw3sfc
VW2 AC                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
     C     1             do        10            x
VW2 AC                   select
VW2 AC                   when      view = 1
510  C                   if        client = packer
510  C     x             chain     dsppsf                             79
510  C                   else
     C     x             chain     dspsfl                             79
510  C                   endif
VW2 AC                   when      view = 2
VW2 AC     x             chain     vw2sfl                             79
VW2 AC                   when      view = 3
VW2 AC     x             chain     vw3sfl                             79
VW2 AC                   endsl
     C                   if        not *in79
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt                            78
     C                   if        not *in78
     C                   eval      option = wkoopt
     C                   eval      *in21 = wkoerr
     C                   eval      *in20 = wkoerr
     C                   else
     C                   eval      option = *blanks
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
     C                   endif
VW2 AC                   select
VW2 AC                   when      view = 1
510  C                   if        client = packer
510  C                   update    dsppsf
510  C                   else
     C                   update    dspsfl
510  C                   endif
VW2 AC                   when      view = 2
VW2 AC                   update    vw2sfl
VW2 AC                   when      view = 3
VW2 AC                   update    vw3sfl
VW2 AC                   endsl
     C                   endif
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   write     msgclr
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
     C                   parm      #prog         #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     *R                   WRITECLRSCR
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
     C                   parm      '*PREV'       #pgmq
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0001  Option under construction.
     *
     C     zm0001        begsr
     C                   eval      #msgid = 'PIR0001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0101  Program not found.
     *
     C     zm0101        begsr
     C                   eval      #msgid = 'PIR0101'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0102  Program not found.
     *
     C     zm0102        begsr
     C                   eval      #msgid = 'PIR0102'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0103  Program not found while exec. subroutine.
     *
     C     zm0103        begsr
     C                   eval      #msgid = 'PIR0103'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0104  Pressed an invalid key.
     *
     C     zm0104        begsr
     C                   eval      #msgid = 'PIR0104'
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
     *----------------------------------------------------------------
     *      0106  Invalid cursor position.
     *
     C     zm0106        begsr
     C                   eval      #msgid = 'PIR0106'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0107  Invalid value for "position To"
     *
     C     zm0107        begsr
     C                   eval      #msgid = 'PIR0107'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0108  Invalid Option.
     *
     C     zm0108        begsr
     C                   eval      #msgid = 'PIR0108'
     C                   eval      #msgtp = '*DIAG  '
     C                   movel     option        errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
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
414aA*----------------------------------------------------------------
414aA*   PIR9907  &1 no longer at status of &2.
414aA*
414aAC     zm9907        begsr
414aAC                   eval      #msgid = 'PIR9907'
414aAC                   eval      #msgtp = '*DIAG  '
414aAC                   movea     errmsg        $md(1)
414aAC                   exsr      zmpmsg
414aAC                   endsr
417aA*----------------------------------------------------------------
417aA*   PIR9908  &1 currently inuse. &2 in progress.
417aA*
417aAC     zm9908        begsr
417aAC                   eval      #msgid = 'PIR9908'
417aAC                   eval      #msgtp = '*DIAG  '
417aAC                   movea     errmsg        $md(1)
417aAC                   exsr      zmpmsg
417aAC                   endsr
414aA*----------------------------------------------------------------
414aA*
414aA*  ZZCKST   Check status of route before proceeding.
414aA*
414aAC     zzckst        begsr
414aA*
414aAC                   eval      stserr = *off
414aAC                   eval      kywhse = rhwhse
414aAC                   eval      kystat = rhstat
414aAC                   eval      kytype = rhtype
414aAC                   eval      kyrte = rhrte
414aAC                   eval      kyrtid = rhrtid
414aA*
414aAC     ckstky        setll     rtehed2                                79
414aA*
414aA*    If *IN79 - off - Route is no longer at correct status. Halt user
414aA*    from proceeding.
414aA*
414aAC                   select
414aAC                   when      not *in79
414aAC                   eval      stserr = *on
414aAC                   eval      error = *on
414aAC                   eval      *in21 = *on
414aAC                   eval      eropt = kyrte
414aAC                   eval      erstat = stat(5)
414aAC                   eval      ertype = 'Routes  '
414aAC                   exsr      zm9907
414aAC                   endsl
414aA*
414aAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD    Process non-standard function keys
     *
     C     zzcmd         begsr
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     Warehouse department.
     *
     C                   if        row# = 4  and
     C                             col# >= 48
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = ptinp1
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      ptinp1 = $lwhse
     C                   endif
     C                   else
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endif
     C                   goto      endcm1
     C                   endif
     *
     *
     *  Test for F8 - Truck detail
     *
     C                   if        *inkh
     C                   eval      $pcmd = '*CHANGE '
     C                   call      'TM110A'
     C                   parm                    $prtky
     C                   parm                    $rtncd
     C                   endif
416aA*
416aA*  Test for F9 - Dock matrix
416aA*
416aAC                   if        *inki
416aA*
416aA*
416aA*    Retrieve last dock matrix history record.
416aAC                   eval      $lprg = #prog
416aAC                   eval      $lwhse = $kwhse
416aAC                   call      'DH910'
416aAC                   parm                    $lparm
416aAC                   if        $lrtn = '*OK     '
416aAC                   eval      $khdte = $lhdte
416aAC                   eval      $khtim = $lhtim
416aAC                   else
416aAC                   eval      $khdte = *zeros
416aAC                   eval      $khtim = *zeros
416aAC                   endif
416aA*
416aAC                   eval      $pcmmd = '*VIEW   '
416aAC                   call      'DH120A'
416aAC                   parm                    $pcmmd
416aAC                   parm                    $prtky
416aAC                   parm                    $rtncd
416aA*
416aAC                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFGET   Get record with unique key.
     *
     C     zzfget        begsr
     *
     *    Code to use when file key and unique key are the same.
     *
     C     fileky        chain     record                             79
     *
     *    Code to use when file key and unique key are different.
     *
     *R         FILUKY    CHAINRECORDU              79
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTN   Get next record
     *
     C     zzfgtn        begsr
     C     try1          tag
     *
     *    Code to use when we are not using a partial key.
     *
     *                    READ RECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     C     partky        reade     record                                 79
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTP   Get previous record
     *
     C     zzfgtp        begsr
     C     try2          tag
     *
     *    Code to use when we are not using a partial key.
     *
     *R                   READPRECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     C     partky        readpe    record                                 79
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     *
     *   Status description
     *
650bA*   Inuse status.
650bA*
650cAC                   eval      $icmd = '*GETIUSE'
650cAC                   exsr      zziuse
650cA*
650bAC                   select
650cA*
650cA*   Route is inuse
650cAC                   when      $irtn = '*ERROR'
650cAC                   eval      w1stat = $itext10
650cAC                   eval      w3stat = $itext10
650cA*
650dDC**                 when      rhshpd <> 0
650cDC**                 eval      $icmd = '*GETIUSE'
650cDC**                 exsr      zziuse
650cDC**                 eval      w1stat = $itext10
650cDC**                 eval      w3stat = $itext10
650bA
650bA*   Otherwise, Route Open.
650bAC                   other
650bA
     C                   move      rhstat        p1
     C                   eval      w1stat = stat(p1)
     C                   eval      w3stat = stat(p1)
650bAC                   endsl
     *
     *   Summary totals
     *
     C                   eval      w1cube = 0
     C                   eval      w1swgt = 0
     C                   eval      w1pcs = 0
     C     keyrs         setll     rtesum
     C                   dow       forevr = forevr
     C     keyrs         reade     rtesum                                 79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   add       rsordc        w1cube
     C                   add       rsordw        w1swgt
     C                   add       rsordp        w1pcs
     C                   enddo
     *
     *   Report date
     *
     C                   if        rhrptd = 0
     C                   eval      w2rptd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      rhrptd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w2rptd = $cvd6o
     C                   endif
     *
     *   Imported date
     *
     C                   if        rhimpd = 0
     C                   eval      w2impd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      rhimpd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w2impd = $cvd6o
     C                   endif
     *
     *   Built date
     *
     C                   if        rhbldd = 0
     C                   eval      w2bldd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      rhbldd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w2bldd = $cvd6o
     C                   endif
     *
     *   Printed date
     *
     C                   if        rhprtd = 0
     C                   eval      w2prtd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      rhprtd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w2prtd = $cvd6o
     C                   endif
     *
     *   Exported date
     *
530bDC**                 if        rhexpd = 0
530bDC**                 eval      w3expd = 0
530bDC**                 else
530bDC**                 eval      $cvcmd = '*CMDMDY '
530bDC**                 move      rhexpd        $cvd8i
530bDC**                 call      @cvtdt
530bDC**                 parm                    $cvtdt
530bDC**                 eval      w3expd = $cvd6o
530bDC**                 endif
     *
     *   Driver
     *
530bAC     keyrs         chain     ttrte
530bAC                   if        not %found
530bAC                   eval      ttrusr = ' '
530bAC                   endif
     *
     *   Status date
     *
     C                   if        rhstsd = 0
     C                   eval      w3stsd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      rhstsd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w3stsd = $cvd6o
     C                   endif
510  *
510  *   Shipment Number for Packers
510  *
510  C                   eval      w1ship = *blanks
510  C                   if        client = packer
510  C     keyrs         chain     ordhm2                             70
510  C                   if        not *in70
510  C                   eval      w1ship = hmmshp
510  C                   endif
510  C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      forevr = *on
414aAC                   eval      stserr = *off
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    rhwhse
     C                   kfld                    rhstat
     C                   kfld                    rhtype
     C                   kfld                    rhrte
     C                   kfld                    rhrtid
     *
     *  Define UNIQ key for main file.
     *
     C     filuky        klist
     C                   kfld                    rhwhse
     C                   kfld                    rhstat
     C                   kfld                    rhtype
     C                   kfld                    rhrte
     C                   kfld                    rhrtid
414aA*
414aA*    Define full key for main file to check route status.
414aA*
414aAC     ckstky        klist
414aAC                   kfld                    kywhse
414aAC                   kfld                    kystat
414aAC                   kfld                    kytype
414aAC                   kfld                    kyrte
414aAC                   kfld                    kyrtid
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kstat
     C                   kfld                    $ktype
     *
     *  Define partial key for file RTESUM.
     *
     C     keyrs         klist
     C                   kfld                    rhwhse
     C                   kfld                    rhrtid
     *
640eA*  Define partial key for file TTMERG1.
640eA*
640eAC     keyttm        klist
640eAC                   kfld                    rhwhse
640eAC                   kfld                    parentRte
411 A*
PANaA*  Define partial key for truckh file.
PANaA*
PANaAC     keyth         klist
PANaAC                   kfld                    $pwhse
PANaAC                   kfld                    $ptruk
PANaA*
PANaA*  Define partial key for options file.
PANaA*
PANaAC     keyopz        klist
PANaAC                   kfld                    kycode
PANaAC                   kfld                    $pwhse
PANaAC                   kfld                    $ptmpl
PANaAC                   kfld                    kyzone
PANaA*
411 A*  Define key for options file.
411 A*
411 AC     keyop         klist
411 AC                   kfld                    opwhse
411 AC                   kfld                    opcode
PANaA*
PANaAC     keyop2        klist
PANaAC                   kfld                    kycode
PANaAC                   kfld                    $pwhse
PANaAC                   kfld                    $ptmpl
PANaA*
PANaA*  Define key for pltsum3 file.
PANaA*
PANaAC     keyps3        klist
PANaAC                   kfld                    $pwhse
PANaAC                   kfld                    $prtid
PANaAC                   kfld                    kytype
411 A*
530aA*   Get *SYSTEM options from options file.
530aA*
530aAC                   eval      opwhse = 0
530aAC                   eval      opcode = '*SYSTEM '
530aAC     keyop         chain     options                            79
530aAC                   if        *in79
530aAC                   eval      optrax = 'N'
530aAC                   else
530aAC                   eval      opdat1 = opdata
530aAC                   endif
     *
411 A*   Get FTP options from options file.
411 A*
411 AC                   eval      opwhse = 0
411 AC                   eval      opcode = '*FTP    '
411 AC     keyop         chain     options                            79
411 AC                   if        *in79
411 AC                   eval      opftp = 'N'
411 AC                   endif
     *
     *  Setup option and command display lines.
     *
VW2 AC                   eval      view = 1
VW2 AC                   eval      maxvw = 3
     C                   eval      optln1 = optln(1)
222 AC                   eval      optln2 = optln(2)
     C                   eval      cmdln1 = cmdln(1)
VW2 AC                   eval      cmdln2 = cmdln(2)
     *
     C                   eval      $pprg = #prog
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from *INZSR.
     *
     C     zzinz2        begsr
222 MC                   eval      $ktype = ' '
222 MC                   eval      $kstat = '5'
     C                   eval      dsfkey = $prtky
222 D*R                   MOVE ' '       $KTYPE
222 D*R                   MOVE '3'       $KSTAT
     *
     *   Get warehouse for user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     rhwhse        parm      0             #whse             3 0
     *
     *   Verify warehouse and get description.
     *
     C                   eval      whcode = rhwhse
     C                   eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = rhwhse
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
     C                   else
     C                   eval      $kwhse = rhwhse
     C                   eval      whcode = rhwhse
     C                   movel     $lerm         whdesc
     C                   endif
     C                   endif
     *
     C                   exsr      clrsch
     C                   exsr      scr01i
     C                   endsr
417aA*----------------------------------------------------------------
417aA*
417aA*  ZZIUSE   Set Inuse flag for route before proceeding.
417aA*
417aAC     zziuse        begsr
417bAC                   eval      stserr = *off
417aA*
650cDC**                 call      'CHKIUSE'
650cDC**                 parm                    $icmd             8
650cDC**                 parm      rhwhse        $iwhse            3 0
650cDC**                 parm      rhrtid        $irtid            5
650cDC**                 parm      *blanks       $irtn             8
650cDC**                 parm      0             $iflag            1 0
650cDC**                 parm      0             $isubflag         1 0
650cDC**                 parm      ' '           $itext10         10
650cDC**                 parm      ' '           $itext30         30

650cAC                   call      'CHKIUSE2'
650cAC                   parm                    $icmd             8
650cAC                   parm      rhwhse        $iwhse            3 0
650cAC                   parm      rhrtid        $irtid            5
650cAC                   parm      #prog         $ipgm            20
650cAC                   parm      ''            $iuser           10
650cAC                   parm      ''            $isessid         40
650cAC                   parm                    $irtn             8
650cAC                   parm                    $itext10         10
650cAC                   parm                    $itext30         30
650cAC                   parm                    $iucmd            8
650cAC                   parm                    $iupgm           20
650cAC                   parm                    $iuuser          10
650cAC                   parm                    $iuSessId        40
650cAC                   parm                    $iuJobName       10
650cAC                   parm                    $iuJobNbr         6
650cAC                   parm                    $iuJobUser       10
650cAC                   parm                    $iuStamp         26

650bAC                   if        $icmd = '*GETIUSE'
650bAC                   leavesr
650bAC                   endif

417aAC                   select
417aAC                   when      $irtn = '*ERROR  '
417aAC                   eval      stserr = *on
417bAC                   eval      cancel = *on
417aAC                   eval      error = *on
417aAC                   eval      *in21 = *on
417aAC                   eval      eropt = rhrte
417aAC                   eval      erstat = stat(7)
417aAC                   eval      ertype = 'Routes  '
417aAC                   exsr      zm9908
417aAC                   endsl
417aA*
417aAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYF   Create key for file being used
     *
     C     zzkeyf        begsr
     C                   eval      $pofky = dsfkey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     C     zzkeyu        begsr
     C                   eval      $pouky = dsukey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS2.
     *
     C     zzopt         begsr
     C                   select
404 A*
404 A*   Department summary
404 A*
404 AC                   when      wkoopt = ' 8'
416 D*R                   CALL 'RS110'
416 MC                   call      'RS120'
404 AC                   parm                    $puky
404 AC                   parm                    $prtn
402 A*
402 A*   Order Details
402 A*
402 AC                   when      wkoopt = ' 9'
402 AC                   eval      $luky = $puky
402 AC                   eval      $lrtn = *blanks
402 AC                   call      'RH170'
402 AC                   parm                    $luky
402 AC                   parm                    $lrtn
416bA*
416bA*   Dock door details.
416bA*
416bAC                   when      wkoopt = '11'
416bAC                   eval      $pcmmd = '*VIEW   '
416bAC                   call      'DH130'
416bAC                   parm                    $pcmmd
416bAC                   parm                    $puky
416bAC                   parm      *blanks       $prtn
     *
     *   Truck Detail
     *
     C                   when      wkoopt = '12'
404 AC                   eval      $pcmmd = '*VIEW   '
     C                   call      'PS130'
404 AC                   parm                    $pcmmd
     C                   parm                    $puky
     C                   parm                    $prtn
     *
510aA*   Zone Detail
510aA*
510aAC                   when      wkoopt = '13'
510aAC                   eval      error = *off
510aAC                   eval      $lwhse = $pwhse
510aAC                   eval      $ltruk = rhtruk
510aAC                   eval      $krte = rhrte
510aAC                   eval      $krtid = rhrtid
510aAC                   call      'ZH140'
510aAC                   parm                    $luky
510aAC                   parm                    $lrtn
     *
520aA*
520aA*   Clear In-Use flag
520aA*
520aAC                   when      wkoopt = 'CI'
520aAC                   eval      $luky = $puky
650aDC**                 eval      $icmd = '*CLEAR  '
650aMC                   eval      $icmd = '*CLEARCI'
520aAC                   exsr      zziuse
510aA*
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *  See if user is trying to change warehouse.
     *
     C                   if        ptinp1 <> 0
     *
     *      Verify warehouse entry.
     *
     C                   eval      whcode = ptinp1
     C                   eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = ptinp1
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   goto      endzps
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   goto      endzps
     C                   else
     C                   eval      rhwhse = ptinp1
     C                   eval      $kwhse = rhwhse
222 MC                   eval      rhstat = $kstat
     C                   eval      rhrte = *blanks
     C                   eval      rhrtid = *blanks
     C                   eval      rhtruk = *blanks
     C                   eval      whcode = ptinp1
     C                   movel     $lerm         whdesc
     C                   eval      ptinp1 = 0
     C                   eval      repos = *on
     C                   endif
     C                   endif
     C                   endif
     *
     *  See if user is trying to position to code
     *
     C                   if        ptinp2 <> *blanks
     C                   eval      rhrte = ptinp2
     C                   eval      rhrtid = *blanks
     C                   eval      rhtruk = *blanks
     C                   eval      ptinp2 = *blanks
     C                   eval      repos = *on
     C                   endif
     C     endzps        endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS2   Position to record
     *
     C     zzpos2        begsr
     *
     *    Code to use when we are not using a partial key.
     *
     *R         $POCMD    IFEQ '*TOP'
     *R         *LOVAL    SETLLRECORD
     *R                   ELSE
     *R         $POCMD    IFEQ '*BOTTOM'
     *R         *HIVAL    SETLLRECORD
     *R                   END
     *R                   END
     *
     *    Code to use when we do have a partial key to use.
     *
     C                   if        $pocmd = '*TOP'
     C     partky        setll     record
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     partky        setgt     record
     C                   endif
     C                   endif
     C                   endsr
PANaA*----------------------------------------------------------------
PANaA*
PANaA*  Build EXPSPLBL process
PANaA*
PANaAC     RUNPFILES     BEGSR
PANaA*
PANaA* Get Zone Template Code if Template type is T=Truck
PANaA*
PANaAC     keyth         chain     truckh
PANaAC                   if        %found(truckh)
PANaAC                             and thtype = 'T'
PANaAC                   eval      $ptmpl =  thztmp
PANaAC                   else
PANaAC                   eval      $ptmpl =  $ptruk
PANaAC                   endif
PANaA*
PANaAc*                  if        parentrte = *blanks
PANaAc*                  eval      parentrte = rhrtid
PANaAc*                  endif
PANaAC*    keyttm        chain     rtehed
PANaAC*                  if        %found(rtehed)
PANaAc*                  eval      $prte = rhrte
PANaAC*                  end
PANaAc                   eval      $prte = rhrte
PANaAc                   eval      $prtid = rhrtid
PANaA*
PANaA*  Loop through pallets in reverse generation order.
PANaA*
PANaAC                   eval      kytype = 'O'
PANaAC     keyps3        setll     pltsum3
PANaAC                   dow       forevr = forevr
PANaAC     keyps3        reade     pltsum3                                79
PANaAC                   if        *in79
PANaAC                   leave
PANaAC                   endif
PANaA*
PANaA*
PANaA*    Skip duplicate zones.
PANaA*
PANaAC                   if        psszon = lstzon
PANaA*    or skip empty pallet zones.
PANaAC                             or pstzon = ' '
PANaAC                             and pspzon = ' '
PANaAC                             and psszon = ' '
PANaAC                             and pstrn# = 0
PANaAC                   iter
PANaAC                   else
PANaAC                   eval      lstzon=psszon
PANaAC                   endif
PANaA*
PANaA*    Get picking options for zone.
PANaA*
PANaAC                   eval      kycode = '*PICKLBL'
PANaAC                   eval      kyzone = psszon
PANaAC                   eval      opdta2 = *blanks
PANaAC     keyopz        chain     optionz                            79
PANaAC                   if        *in79 = *off
PANaAC                   eval      opdta2 = opzdta
PANaAC                   endif
PANaAC                   if        *in79
PANaAC     keyop2        setll     optionz
PANaAC     keyop2        reade     optionz                                78
PANaAC                   if        *in78
PANaAC                   eval      oplpgm = *blanks
PANaAC                   else
PANaAC                   eval      opdta2 = opzdta
PANaAC                   endif
PANaAC                   endif
PANaAc*
PANaA*  Build EXPSLBL with export data
PANaAC                   eval       $whse=$pwhse
PANaAc*
PANaAC                   call      'PFILES'
PANaAC                   parm      '*PRINT  '    cmd
PANaAC                   parm                    $whse
PANaAC                   parm                    $prtid
PANaAC                   parm                    pscomp
PANaAC                   parm                    pstzon
PANaAC                   parm                    psgen
PANaAC                   parm                    psszon
PANaAC                   parm                    $ptruk
PANaAC                   parm                    $prte
PANaAC                   parm                    opdta2
PANaAC                   parm                    $prtn
PANaAC                   call      'PFILES'
PANaAC                   parm      '*CLOSE  '    cmd
PANaAC                   parm                    $whse
PANaAC                   parm                    $prtid
PANaAC                   parm                    pscomp
PANaAC                   parm                    pstzon
PANaAC                   parm                    psgen
PANaAC                   parm                    psszon
PANaAC                   parm                    $ptruk
PANaAC                   parm                    $prte
PANaAC                   parm                    opdta2
PANaAC                   parm                    $prtn
PANaA*
PANaAc                   enddo
PANaA*
PANaA*  Update EXPSLBL with payroll and performance data
PANaA*
PANaAc                   call      'PFILES2'
PANaA*
PANaAC                   endsr

720aA*----------------------------------------------------------------
720aA*  wrtDebug  Write out debug error
720aA*----------------------------------------------------------------

720aA /free
720aA  begsr wrtDebug;

         bdaddts = %timestamp();
         bdaddpgm = #prog;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobn;

         write(e) bdrec;

       endsr;
      /end-free

720aA*----------------------------------------------------------------
720aA*  wrtDebugLibl   Write out debug parm record
720aA*----------------------------------------------------------------
720aA
     p WrtDebugLibl    b
     d WrtDebugLibl    pi

      /free

        if not %open(bfcdebug);
          open bfcdebug;
        endif;

        bdtype = 'LIBL';

        GetLiblCL(bdvalues);

        bdaddts = %timestamp();
        bdaddpgm = #prog;
        bdaddcusr = #curruser;
        bdaddjusr = #user;
        bdaddjob = #job;
        bdaddnbr = #jobn;

        write bdrec;

      /end-free
     p                 e

     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options
 1 6 8 911121314CI
**  OPTLN - Option display line
  1=Export transactions  6=Reprint  8=View breakdown  9=Order detail
 11=Dock door details  12=Truck detail  13=Zone detail  14=Assign driver
**  CMDLN - Command display line
F3=Exit  F4=Prompt  F5=Refresh  F8=Truck maint.  F9=Dock matrix  F12=Cancel
F10=View 3  F11=View 2  F17=Top  F18=Bottom  F20=Move to top
F3=Exit  F4=Prompt  F5=Refresh  F8=Truck maint.  F9=Dock matrix  F12=Cancel
F10=View 1  F11=View 3  F17=Top  F18=Bottom  F20=Move to top
F3=Exit  F4=Prompt  F5=Refresh  F8=Truck maint.  F9=Dock matrix  F12=Cancel
F10=View 2  F11=View 1  F17=Top  F18=Bottom  F20=Move to top
**  STAT - Route status codes
Open
Allocated
Built
Printed
Closed
Exported
Export tran
**  EM - Error message
Not allowed to take 1=Export at this time.
Opt 14 not allowed, must be a TRAX user.
