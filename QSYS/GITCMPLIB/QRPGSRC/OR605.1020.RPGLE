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
600aA*    05/08/09  DAS  6.00a  P#00045
     *      - License tracking
     *      - Letdowns have been removed for license tracking.
     *        Revised to ensure OPJITR option is not set for Letdowns.
     *
510eA*----------------------------------------------------------------
510eA*  Client Custom Revisions: Cheney
510e *
CBIaA*    06/20/07  DAS  CBIa
     *      - Added call to OR637 to create ORDP piece seq# records.
     *
510aA*----------------------------------------------------------------
510aA*  Client Custom Revisions: CityLine
510a *
CLDaA*    10/07/06  DAS  CLDa
     *      - Added call to OR638 to assign PIR seq#'s
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
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval Foodservice (SVL)
     *
SVL A*    03/04/09  JCJ  SVL
     *      - Added call to OR690 to print Transaction Audit Report
     *        for all transactions.
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
413 AFreports   if   e           k disk
     Fordh      uf a e           k disk
     Fordd      o  a e           k disk
415 AFrtetrck   o  a e           k disk
HARcAFtaxrctl   o    e             disk
CTWaAFckrctl    o    e             disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D tcod            s              8    dim(7) ctdata perrcd(1)
     D tdsc            s             51    dim(7) alt(tcod)
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
510fMD/COPY QCOPYSRC,ID#PACKERS
MJK A /COPY QCOPYSRC,ID#MJKELLN
CTW A /copy qcopysrc,id#citywho
FDI A /copy qcopysrc,id#finkle
IFD AD/COPY QCOPYSRC,ID#IFD
SVL AD/COPY QCOPYSRC,ID#saval
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @clcdr          c                   const('CLCDUR')
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
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
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
     D $pstr           s             60
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
     D dummy           s              1
     D enter           s              5  0
     D eofrh2          s              1
     D error           s              1
     D forevr          s              1
     D help            s              5  0
     D jobok           s              8
     D kycode          s                   like(opcode)
     D kystat          s                   like(rhstat)
     D msgk            s              4  0
     D rolldn          s              5  0
     D rollup          s              5  0
     D rstat           s              1
     D sclear          s              1
     D standa          s              1
     D stat            s              1
     D svdte1          s              8  0
     D svdte2          s              8  0
     D svpgm1          s             10
     D svpgm2          s             10
     D svtim1          s              6  0
     D svtim2          s              6  0
     D t               s              2  0
     D wkprtf          s             10
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
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     *
     * Get out if a valid command wasn't sent to us.
     *
     C                   if        $pcmd <> '*PICK   '  and
     C                             $pcmd <> '*RESTART'
     C                   eval      $prtn = '*ERROR  '
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
510dAC                   if        $otype = ' '
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
500dA*
500dA* Get client id.
500dA*
500dAC                   call      @getcl
500dAC                   parm                    client           10
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
     *
     *  Define key for ORDH file.
     *
     C     keyoh         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pord
413 A*
413 AC     rpkey         klist
413 AC                   kfld                    wkprtf
     *
     *   Fool the compiler.
     *
     C                   eval      dummy = *blanks
     C                   if        dummy <> *blanks
     C     keyoh         chain     ordh                               79
     C                   endif
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
     C                   if        $pcmd2 = '*ALOCBLD'  or
     C                             $pcmd2 = '*REBUILD'
     C                   eval      $retrn = '*ENDBLD '
     C                   goto      enddo1
     C                   endif
     *
     *     Phase 3 - Pick stock from slots.
     *
     C     phase3        tag
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
510bAC                   call      'OR630P'
510b C                   parm                    $pbat
510b C                   parm                    $pwhse
510b C                   parm                    $otype
510b C                   parm                    rhrte
510b C                   parm                    rhrtid
510b C                   parm                    rhtruk
510bAC                   else
520dAC                   call      'OR630B'
520dAC                   parm                    $pwhse
520dAC                   parm                    rhrtid
520dAC                   parm                    rhtruk
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
CBIaAC                   if        client = cheney
HARdAC                             or client = harbor
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
CBIaAC                   endif
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
CLDaAC                   if        client = cityln
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
     *       Mark route as 'Printed' even though it hasn't been printed.
     *         If something goes wrong during printing, it is easy to
     *         reprint.
     *
     C                   eval      rstat = '4'
     C                   exsr      updrte
     *
     *     Phase 4 - Print labels.
     *
     C     phase4        tag
     C                   eval      stat = '4'
     C                   exsr      updctl
     C                   if        $pjtyp = *on
     C                   exsr      zm24
     C                   endif
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
ISYa C                   if        client = isuply
ISYa C                   if        $pcmd = '*PICK   '
ISYAAC                   eval      $tpgm = 'PT725CL'
ISYa C                   exsr      zzstrt
ISYa C                   call      'PT725CL'
HAR  *ISYa                PARM           $WHSE
HAR  C                   parm                    $whsea
ISYa C                   parm                    rhrtid
ISYa C                   parm                    rhrte
ISYa C                   parm      ' '           $reex             1
ISYa C                   eval      $tpgm = 'PT725CL'
ISYa C                   exsr      zzend
ISYaAC                   endif
ISYaAC                   endif
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
404 MC                   if        $ptype <> '*WCPICK '  and
404 MC                             $ptype <> '*WCPICK1'
MJK AC                             and client <>  MJKellner
MJK AC*
MJK AC                             or  client = MJKellner
MJK MC                             and $PTYPE <> '*WCPICK '
MJK MC                             and $PTYPE <> '*WCPICK1'
MJK AC                             and %subst(rhrte:1:1) <> 'I'
MJK AC*
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
404 MC                   endif
402 M*
402 M*     Phase 6 - Print pallet summary
402 M*
402 MC     phase6        tag
HARaA*     Skip printing -
HARaAC     client        cabeq     harbor        phase7
HARaA*
404 MC                   if        $ptype <> '*WCPICK '  and
404 MC                             $ptype <> '*WCPICK1'
MJK AC                             and client <>  MJKellner
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
402 MC                   move      $pwhse        $whsea
500 AC                   eval      $dev = '*JOB    '
500 AC                   eval      $form = '*STD    '
402 MC                   call      'OR660CL'
402 MC                   parm                    $pcmd
404 D**                   PARM '*SUMMARY'RTYPE   8
404 AC                   parm      '*DETAIL '    rtype             8
402 MC                   parm                    $whsea
402 MC                   parm                    rhrtid
402 MC                   parm                    $retrn
417 AC                   parm                    $dev
417 AC                   parm                    $form
500 AC                   eval      $dev = '*JOB    '
500 AC                   eval      $form = '*STD    '
409 AC                   call      'OR660CL'
409 AC                   parm                    $pcmd
409 AC                   parm      '*SUMMARY'    rtype
409 AC                   parm                    $whsea
409 AC                   parm                    rhrtid
409 AC                   parm                    $retrn
417 AC                   parm                    $dev
417 AC                   parm                    $form
500cA*
520 D ***                call      'OR660TCL'
520 D ***                parm                    $pcmd
520 D ***                parm      '*DETAIL '    rtype
520 D ***                parm                    $whsea
520 D ***                parm                    rhrtid
520 D ***                parm                    $retrn
520 D ***                parm                    $dev
520 D ***                parm                    $form
PCKbAC                   endif
500cA*
414cAC                   call      'OR665CL'
414cAC                   parm                    $pcmd
414cAC                   parm      '*DETAIL '    rtype
414cAC                   parm                    $whsea
414cAC                   parm                    rhrtid
414cAC                   parm                    $retrn
415 AC                   eval      $tpgm = 'OR660'
415 AC                   exsr      zzend
IFD A*
IFDaDC*                  if        client = IFD
SVL AC                   if        client = saval
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
415bMC                   call      'OR770'
414aAC                   parm      *blanks       $pcmd
414aAC                   parm      '*DETAIL '    rtype
414aAC                   parm                    $whsea
414aAC                   parm                    rhrtid
414aAC                   parm                    $retrn
     *
415 AC                   eval      $tpgm = 'OR647'
415 AC                   exsr      zzend
414aAC                   endif
415 AC                   if        $pcmd2 = '*PCKPRNT'
415 AC                   eval      $tpgm = $pcmd2
415 AC                   exsr      zzend
415 AC                   endif
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
510dAC                   eval      rhshpd = *zeros
510dAC                   endif
     C                   when      rstat = '4'
     C                   eval      rhprtd = rhstsd
     C                   eval      rhprtt = rhstst
510dA*    Clear Inuse flag for route.
510dAC                   if        $otype = ' '
510dAC                   eval      rhshpd = *zeros
510dAC                   endif
     C                   endsl
     C                   update    rhrec
     C                   endif
     *
     C                   endsr
415 A*----------------------------------------------------------------
415 A*
415 A*  ZZEND   End timer
415 A*
415 AC     zzend         begsr
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
510dA*----------------------------------------------------------------
510dA*
510dA*  ZZIUSE   Clear Inuse flag for route.
510dA*
510dAC     zziuse        begsr
510dA*
510dAC                   call      'CHKIUSE'
510dAC                   parm      '*CLEAR  '    $icmd             8
510dAC                   parm      $pwhse        $iwhse            3 0
510dAC                   parm      $prtid        $irtid            5
510dAC                   parm      *blanks       $irtn             8
510dA*
510dAC                   endsr
415 A*----------------------------------------------------------------
415 A*
415 A*  ZZSTRT  Start timer
415 A*
415 AC     zzstrt        begsr
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
