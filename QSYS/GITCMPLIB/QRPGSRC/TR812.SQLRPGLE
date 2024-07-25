      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TR812     Create version 2.0 Trax XML file.
     *            Based on TR811
     *
     *  19 April 2017
     *  Dave Sommerville
     *
     *  Revisions
     *
710 A*    04/19/17  DAS  7.10
     *      - Created.
     *
710aA*    05/30/17  DAS  7.10a
     *      - Added xmlns:xsi to <TRAXData>.
     *      - Changed stop to stopNumber.
     *      - Removed routeId from configs.
     *      - Change traxRouteGroupdID to traxRouteGroupID in configs
     *      - Added configType to configs (Default/Driver/Route/Stop)
     *      - Revised Stop config to only send changes.
     *      - Added WriteUserInfo
     *      - Added WriteCompany
     *      - Added $pcmd parameter to control writing Route file
     *        or Company file. Don't want company info in every
     *        route file.
     *
710bA*    07/10/17  DAS  7.10b
     *      - Revised GetZoneOpts to use LWTZON.
     *
710cA*    10/11/17  RBD  7.10c
     *      - Changed $pCmd COMPANY to *COMPANY and ROUTE to *ROUTE.
     *
710dA*    11/09/17  DAS  7.10d
     *      - Added stopId, which is the 2-digit internal Stop
     *      - Revised current stop in XML file to be Host stop (5.0)
     *      - Added call to GETSTOP to get Host Stop
     *
710eA*    11/18/17  DAS  7.10e
     *      - Revised to get IFS folder from *TRAX2 options
     *
710fA*    12/28/17  DAS  7.10f
     *      - Revised to not send IP address in config
     *      - Added new fields to getempl call.
     *
720aA*    02/28/18  RBD  7.20a
     *      - Get out if route id is part of a merged route and any
     *        of the routes, parent or children, excluding the one
     *        passed in, have not been exported yet.
     *      - If route id is a child of a merged route get the parent
     *        route id and use it in the xml file name and the rest of
     *        the pgm.  In other words the xml will only be created
     *        for the parent route id.
     *      - Added gRoutes looping for stop flags.
     *
720bA*    03/27/18  RBD  7.20b
     *      - Customer number in OPTIONC changed from num to alpha.
     *        Added logic to look for alpha customer in order misc field
     *        if numeric customer number field is zeros.
     *
720cA*    04/03/18  KDE  7.20c
     *      - Few mods to finish integration of OPTIONC
720dA*    03/15/18  LMC  7.20d
     *      - Added PCM questions.
     *
720eA*    06/12/18  RBD  7.20e
     *      - Fix: Bail if route or any associated (merged) routes are
     *        not found in route header or haven't been exported yet.
     *
720fA*    08/03/18  RBD  7.20f
     *      - Added bfcdebug logic.
     *
720g *    08/09/18  LMC/GJA 7.20g
     *      - Fixed:  ScanID was Defaulting to Route ID sent in, but
     *                should have been using the Route ID from ORDP.
     *                It was using ORPUP# so it should match.
     *
720h *    09/24/18  LMC  7.20h
     *      - Fixed:  Need to loop for stop numbers on stop questions
     *                apparently I need to send the same question
     *                over and over for each stop.
     *
720iA*    10/02/18  RBD  7.20i
     *      - If stop has no items with qty picked do not write to xml.
     *
730aA*    01/31/19  RBD  7.30a
     *      - Fix: For truck stop flag logic use order from ordh9
     *        rather than ordh.
     *
730bA*    04/01/19  RBD  7.30b
     *      - Added several new route level and cust level options.
     *
730cA*    04/02/19  RBD  7.30c
     *      - Look for customer order in ORDHEXA, if not found use
     *        customer order from ORDH.
     *
730dA*    04/03/19  RBD  7.30d
     *      - Comment out hoststop being overlaid with internal
     *        stop after each call to GETSTOP.
     *
730eA*    04/15/19  RBD  7.30e
     *      - Look for customer number in ORDHEXA, if not found use
     *        customer number from ORDH. Will no longer use alpha
     *        customer from ORDH/OHMISC.
     *      - Fix: Customer level option 'Filter By Department' wasn't
     *        being written correctly, was being written with the value
     *        of the route level option.
     *
730fA*    04/19/19  DAS  7.30f
     *      - Added *PSSR routine
     *
730g *    08/30/19  GJA  7.30g
     *      - Fix: wasn't using correct order number to ORDHEXA
     *
730hA*    09/12/19  RBD  7.30h
     *      - Fix: only write stop level pallets enabled flag if not
     *        blank and not the same as route level flag.
730iA*    12/26/19  LMC  7.30i
     *      - Enh: Send the customer number to pcm program to select
     *        customer specific questions.
730jA*    12/30/19  LMC  7.30j
     *      - Enh: In order to get customer questions, we have to loop
     *        thru the stops to get the correct customer number.
     *
740aA*    03/20/20  RBD  7.40a
     *      - Fix for pallets enabled: retain leadings 0's from ohcust.
     *
740bA*    04/02/20  RBD  7.40b
     *      - Fix imported stop flags stop numbers: use Dakota order
     *        from flag to get Dakota stop, then use Dakota stop to get
     *        host stop.
     *
740cA*    05/05/20  RBD  7.40c
     *      - Added stop flag unique id to xml as stopFlagSequence.
     *      - Fix: For predefined stop flags by truck changed
     *        stopNumber from internal stop to host stop and
     *        added stopId as internal stop.
     *
740dA*    08/17/20  RBD  7.40d
     *      - Fix: Set breakdown quantity to 1 if unit of measure
     *        being sold is a breakdown.
     *
740e *    09/22/20  GJA  7.40e
     *      - Enh: Add option flags
     *             Multiple routes OPTMUL/traxMultirouteEnable
     *             Save Login info OPTSVL/traxLogLevel
     *             Send stop pictures OPTSSP/traxSendStopPicturesEnable
     *             Send stop  ignatures OPTSSS/traxSendStopSignaturesEnable
     *             Send stop TRAX log OPTSST/traxSendStopTRAXLogEnable
     *             Keep log info OPTKPL/traxKeepLoginInfo
     *             Show log info OPTSHL/traxShowLogInfo
     *             Enable printer OPTPRT/enablePrinter
     *             Enable Speak OPTSPK/enableSpeak
     *             Enable GPS OPTGPS/enableGPS
     *             GPS Probe minutes OPTMIN/gpsProbePeriodMinutes
     *             GPS Probe distance meters OPTMET/gpsProbeDistanceMeters
     *             Admin password OPTPWD/traxAdminCode
     *             Admin password encryption offset OPTOFF/traxOffset
     *             App auto update OPTAUT/traxAppAutoUpdate
     *             Company phone number OPTPH1/traxCompanyCallPhoneNumber
     *             Dispatch phone number for texting OPTPH2/
     *                                 traxCompanyDispatchMessagePhoneNumber
     *             Camera barcode scanner OPTCAM/enableCameraBarcodeScanner
     *             Disable driver ID login validation OPTDIL/
     *                                  disableDriverLoginValidation
     *             Disable driver password login validation OPTDIP/
     *                                  disableDriverPasswordLoginValidation
     *             URL address where Trax app update is located. Must begin
     *                    with http:// and server address OPTURL/traxAppUrl
     *             Sygic Truck Intregration OPTSYG/traxSygicIntegration
     *
740fA*    11/10/20  RBD  7.40f
     *      - Added *TRAX option optraxinv.
     *      - Added new files: TTIVCH, TTIVCD, TTIVCC.
     *      - Added new records: <Invoices, <InvoiceItems and
     *        <InvoiceCatchweights.
     *      - Added order sequence number to Items/Item record.
     *
750aA*    08/17/21  LMC  7.50a
     *      - Corrected PCM customer specific logic.
     *      - Wrong stop number was being loaded for CS1 & CS2
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions -
     *
CLDaA*    02/10/18  DAS  CLDa
     *      - Revised to force signature capture
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions - I Supply
     *
ISYaA*    02/27/19  RBD  ISYa
     *      - Prefix compartment to mandate sequencing of items
     *        on the Trax unit.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *      - Use BFCIFSBND binding directory.
     *
     *      - Used code page logic to write the file as an
     *        ASCII file so that when downloaded to a PC it
     *        will be readable ... by wordpad or notepad.
     *        In essence, it will be written as ccsid 819
     *        rather than ccsid 37.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Flabel94   if   e           k disk
     Foptionc   if   e           k disk
     Foptions   if   e           k disk
     Foptionz   if   e           k disk
     Fordd      if   e           k disk
     Fordh      if   e           k disk
     Fordh9     if   e           k disk    prefix(oh9_)
     F                                     rename(ohrec:ohrec9)
     Fordp2     if   e           k disk    rename(orprec:orprec2)
     Fordp4     if   e           k disk
     Fpiruser1  if   e           k disk
     Fpltsum12  if   e           k disk
     Frtehed    if   e           k disk
     Frtesum    if   e           k disk
     Frtncode   if   e           k disk
     Ftotehdr1  if   e           k disk    prefix(t1_)
     Ftotehdr2  if   e           k disk    rename(tohrec:tohrec2)
     Fttflag    if   e           k disk
     Fttgrp     if   e           k disk
     Fttlog     uf a e           k disk
     Fttmerg    if   e           k disk
     Fttmerg2   if   e           k disk    rename(ttmrec:ttmrec2) prefix(tt2_)
     Fttrte     if   e           k disk
     Fttstpflg  if   e           k disk
     Ftttrkflg  if   e           k disk
     Fupc2      if   e           k disk
     Fworklbfi  if   e           k disk
     Fworklbl   if   e           k disk
     Fworklbl7  if   e           k disk    prefix(lb7_)
     F                                     rename(lwrec:lwrec7)
     Fworklb94  if   e           k disk    rename(lwrec:lwrec94)
710aAFwarehs    if   e           k disk
710aAFwarehsad  if   e           k disk
720fAfbfcdbgflg if   e           k disk    usropn
720fAfbfcdebug  o    e           k disk    usropn
     Frtetrck   o  a e           k disk
740fAfttivch    if   e           k disk
740fAfttivcd    if   e           k disk
740fAfttivcc    if   e           k disk

     *----------------------------------------------------------------
     *  Clients
     *----------------------------------------------------------------

     D/copy qcopysrc,ID#CITYLIN
ISYaAD/copy qcopysrc,ID#ISUPPLY

     *----------------------------------------------------------------
     *  CVTDTE program parameters
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
     D  $cvdr1               133    140
     D  $cvvl1               141    145  0

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#Item
     D savever#        s                   like($itver#)
     D save$item       s                   like($item)
     D save$item2      s                   like($item2)

     *----------------------------------------------------------------
     *  *SYSTEM  -  System options.
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *    OPWRNC  -  Check CW variance during selection closing (N,M,C,B)
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
     *    OPICW   -  Check CW count during selection closing (N,M,C,B)
     *    OPWRNCR -  Check CW variance during Rcv inividual entry(Y,N)
     *    OPICWR  -  Check CW count during Rcv individual entry (Y,N)
     *
     * Data structure
     *
     D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opicw                 13     13
     D  opuci                 36     36
     D  opwrncr               37     37
     D  opicwr                38     38
     D  optend               117    117

     *----------------------------------------------------------------
     *  *TRAX  -  TRAX options
     *
     * Fields
     *
     *    OPTHST  -  Days to keep TRAX export data (1-999)
     *    OPTSLI  -  Save log info
     *    OPTCWR  -  Catch weight required
     *    OPTOFT  -  Order number field type
     *    OPTDFT  -  Driver field type
     *    OPTRFT  -  Route field type
     *    OPTCAP  -  Capitalize input
     *    OPTDBL  -  Double click delivery
     *    OPTEKD  -  Entry key delivery
     *    OPTDAR  -  Delivery after return
     *    OPTIDB  -  Include item data base
     *    OPTBDA  -  Breakdowns allowed
     *    OPTGBD  -  Generic breakdown allowed
     *    OPTRTQ  -  Pre-trip questions
     *    OPTOTQ  -  Post-trip questions
     *    OPTCCE  -  Credit card enabled
     *    OPTSIG  -  Signature enabled
     *    OPTPIV  -  Print invoice
     *    OPTSDA  -  Send data after stop
     *    OPTWSP  -  Ws port
     *    OPTWSI  -  Ws IP
     *    OPTSVD  -  Save days
     *    OPTERT  -  Environment run time
     *    OPTEDV  -  Environment device
     *    OPTEOS  -  Environment OS
     *    OPTESW  -  Environment screen width
     *    OPTESH  -  Environment screen height
     *    OPTARE  -  Add return enabled
     *    OPTIDL  -  Icon delivery
     *    OPTDCI  -  Double click icons
     *    OPTPAL  -  Pallets enabled
     *    OPTCRA  -  Cradle upload enabled
     *    OPTDRV  -  Driver assigned before download
     *    OPTBUL  -  Bulk items enabled
     *    OPTEYS  -  Display empty stops
     *    OPTSAS  -  Save after scan
     *    OPTSDL  -  Save delay
     *    OPTSDT  -  Sync date and time
     *    OPTLRK  -  Left/right keys enabled
     *    OPTGSS  -  GS1 scanning
     *    OPTGSU  -  GS1 unique
     *    OPTSBV  -  Scan beep volume
     *    OPTRAG  -  Restart after get route.
     *    OPTRD   -  Restart daily.
     *    OPTRDT  -  Restart daily time.
     *    OPTRFP  -  Reader focus position.
     *    OPTRFM  -  Reader focus mode.
     *    OPTNSR  -  Non scan reason prompt.
     *    OPTFBD  -  Filter by department.
     *    OPTDSF  -  Display stop flags before restart.
730bA*    OPTSOR  -  Sort items by compartment Y/N.
730bA*    OPTODE  -  Customer on site delivery enable Y/N.
730bA*    OPTODP  -  Customer on site delivery verification period, 5-60.
730bA*    OPTONT  -  On truck picking Y/N.
730bA*    OPTOTP  -  Override truck picking Y/N.
730bA*    OPTNSB  -  No signee button on signature screen Y/N.
740fA*    OPTRAXINV - 1 = Print all invoices
740fA*                2 = Print pristine invoices only
740fA*                3 = Print non-pristine invoices only
740fA*                9 = Print no invoices
     *
     * Data structure
     *
     D opdta           ds
     D  opthst                 1      3  0
     D  optsli                 4      4
     D  optcwr                 5      5
     D  optoft                 6      6
     D  optdft                 7      7
     D  optrft                 8      8
     D  optcap                 9      9
     D  optdbl                10     10
     D  optekd                11     11
     D  optdar                12     12
     D  optidb                13     13
     D  optbda                14     14
     D  optgbd                15     15
     D  optrtq                16     16
     D  optotq                17     17
     D  optcce                18     18
     D  optsig                19     19
     D  optpiv                20     20
     D  optsda                21     21
     D  optwsp                22     26  0
     D  optwsi                27     41
     D  optsvd                42     43  0
     D  optert                44     47
     D  optedv                48     57
     D  opteos                58     67
     D  optesw                68     71  0
     D  optesh                72     75  0
     D  optare                76     76
     D  optidl                77     77
     D  optdci                78     78
     D  optpal                79     79
     D  optcra                80     80
     D  optdrv                81     81
     D  optbul                82     82
     D  opteys                83     83
     D  optsas                84     84
     D  optsdl                85     86  0
     D  optsdt                87     87
     D  optlrk                88     88
     D  optgss                89     89
     D  optgsu                90     90
     D  optsbv                91     91  0
     D  optrag                92     92
     D  optrd                 93     93
     D  optrdt                94     97  0
     D  optrfp                98     98
     D  optrfm                99     99
     D  optnsr               100    100
     D  optfbd               101    101
     D  optdsf               102    102
730bAD  optsor               103    103
730bAD  optode               104    104
730bAD  optodp               105    106  0
730bAD  optont               107    107
730bAD  optotp               108    108
730bAD  optnsb               109    109
740fAD  optraxinv            110    110
     D  opten                117    117
     *----------------------------------------------------------------
     *  *TRAX1    -  More TRAX options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPTER   -  Email receipt.
     *    OPTREF  -  Receipt email from.
     *    OPTRES  -  Receipt email subject.
     *
     * Data structure
     *
     D opdta1          ds
     D  opter                  1      1
     D  optref                 2     61
     D  optres                62    116
     D  opten1               117    117
     *----------------------------------------------------------------
     *  *TRAX2  -  More TRAX options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPTSBU  -  Use system suspend battery power timeout.
     *    OPTSB   -  System suspend battery power timeout.
     *    OPTSEU  -  Use system suspend external power timeout.
     *    OPTSE   -  System suspend external power timeout.
     *    OPTBBU  -  Use backlight off battery power timeout.
     *    OPTBB   -  Backlight off battery power timeout.
     *    OPTBEU  -  Use backlight off external power timeout.
     *    OPTBE   -  Backlight off external power timeout.
710eA*    OPTV12  -  Default = N.  Y = create V1.2 xml.
710eA*    OPTV20  -  Default = N.  Y = create V2.0 xml.
710eA*    OPTDIR  -  IFS main directory
730bA*    OPTSVL  -  Save login info Y/N.
730bA*    OPTSSP  -  Send stop pictures enable Y/N.
730bA*    OPTSSS  -  Send stop signatures enable Y/N.
730bA*    OPTSST  -  Send stop Trax log enable Y/N.
730bA*    OPTMUL  -  Multi route enable Y/N.
730bA*    OPTKPL  -  Keep log info Y/N.
730bA*    OPTSHL  -  Show log info Y/N.
730bA*    OPTPRT  -  Enable printer Y/N.
730bA*    OPTSPK  -  Enable speak Y/N.
730bA*    OPTGPS  -  Enable GPS Y/N.
730bA*    OPTMIN  -  GPS probe period minutes, greater than 0.
730bA*    OPTMET  -  GPS probe distance meters, greater than 0.
730bA*               Entered in yards, converted to meters.
730bA*    OPTPWD  -  Admin password.
730bA*    OPTOFF  -  Admin password encryption offset.
730bA*    OPTAUT  -  App auto update Y/N.
730bA*    OPTPH1  -  Company phone number.
730bA*    OPTPH2  -  Dispatch phone number for texting.
730bA*    OPTCAM  -  Camera barcode scanner Y/N.
730bA*    OPTDIL  -  Disable driver id login validation Y/N.
730bA*    OPTDIP  -  Disable driver password login validation Y/N.
     *
     * Data structure
     *
     D opdta2          ds
     D  optsbu                 1      1
     D  optsb                  2      4  0
     D  optseu                 5      5
     D  optse                  6      8  0
     D  optbbu                 9      9
     D  optbb                 10     13  0
     D  optbeu                14     14
     D  optbe                 15     17  0
710eAD  optv12                18     18
710eAD  optv20                19     19
710eAD  optdir                20     39
730bAD  optsvl                51     51
730bAD  optssp                52     52
730bAD  optsss                53     53
730bAD  optsst                54     54
730bAD  optmul                55     55
730bAD  optkpl                56     56
730bAD  optshl                57     57
730bAD  optprt                58     58
730bAD  optspk                59     59
730bAD  optgps                60     60
730bAD  optmin                61     63  0
730bAD  optmet                64     69  0
730bAD  optpwd                70     89
730bAD  optoff                90     91  0
730bAD  optaut                92     92
730bAD  optph1                93    102  0
730bAD  optph2               103    112  0
730bAD  optcam               113    113
730bAD  optdil               114    114
730bAD  optdip               115    115
     D  opten2               117    117
730bA*----------------------------------------------------------------
730bA*  *TRAX3    -  More TRAX options
730bA*----------------------------------------------------------------
730bA*
730bA* Fields
730bA*
730bA*    OPTURL  -  URL address where Trax app update is located. Must
730bA*               begin with http:// and server address.
730bA*
730bA* Data structure
730bA*
730bAD opdta3          ds
730bAD  opturl                 1     60
740eAD  optsyg                61     61
730bAD  opten3               117    117
     *----------------------------------------------------------------
     *  *TRAX  -  TRAX customer options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPCCWR  -  Catch weight required
     *    OPCBDA  -  Breakdowns allowed
     *    OPCGBD  -  Generic breakdown allowed
     *    OPCRTQ  -  Pre-trip questions
     *    OPCOTQ  -  Post-trip questions
     *    OPCCCE  -  Credit card enabled
     *    OPCSIG  -  Signature enabled
     *    OPCPIV  -  Print invoice
     *    OPCSDA  -  Send data after stop
     *    OPCARE  -  Add return enabled
     *    OPCPAL  -  Pallets enabled
     *    OPCBUL  -  Bulk items enabled
     *    OPCGSS  -  GS1 scanning
     *    OPCGSU  -  GS1 unique
     *    OPCNSR  -  Non scan reason prompt.
     *    OPCFBD  -  Filter by department.
730bA*    OPCSOR  -  Sort items by compartment Y/N.
730bA*    OPCODX  -  Customer on site delivery enable Y/N.
730bA*    OPCODP  -  Customer on site delivery verification period, 5-60.
730bA*    OPCONT  -  On truck picking Y/N.
730bA*    OPCOTP  -  Override truck picking Y/N.
730bA*    OPCNSB  -  No signee button on signature screen Y/N.
     *
     * Data structure
     *
     D opcdta0         ds
     D  opccwr                 5      5
     D  opcbda                14     14
     D  opcgbd                15     15
     D  opcrtq                16     16
     D  opcotq                17     17
     D  opccce                18     18
     D  opcsig                19     19
     D  opcpiv                20     20
     D  opcsda                21     21
     D  opcare                76     76
     D  opcpal                79     79
     D  opcbul                82     82
     D  opcgss                89     89
     D  opcgsu                90     90
     D  opcnsr               100    100
     D  opcfbd               101    101
730bAD  opcsor               103    103
730bAD  opcodx               104    104
730bAD  opcodp               105    106  0
730bAD  opcont               107    107
730bAD  opcotp               108    108
730bAD  opcnsb               109    109
     D  opcend               117    117
     *----------------------------------------------------------------
     *  *TRAX1    -  More TRAX customer options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPCER   -  Email receipt.
     *    OPCREF  -  Receipt email from.
     *    OPCRES  -  Receipt email subject.
     *
     * Data structure
     *
     D opcdta1         ds
     D  opcer                  1      1
     D  opcref                 2     61
     D  opcres                62    116
     D  opcend1              117    117
     *
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
     *    OPPBLD  -  Pallet building method.
     *                1 = By stop then slot location.
     *                2 = By slot location then stop.
     *                3 = By descening stop, then slot location.
     *    OPSELM  -  Selection method.
     *                1 = Single pass (By location).
     *                2 = Multiple pass (By stop).
     *    OPSPLT  -  Allow stop to be split across pallets (Y/N).
     *    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
     *    OPNWPL  -  Start new pallet when aisle changes if build method
     *               is 2=Location.
     *    OPFORD  -  Maximun orders per pallet.
     *    OPPTYP  -  Pallet type (P=Pallet, T=Tote, B=Batch).
     *    OPFTOT  -  Maximum totes per pallet.
     *    OPTECB  -  External tote cube.
     *    OPTICB  -  Internal tote cube.
     *    OPTSTP  -  Maximum stops per tote.
     *    OPTPCS  -  Maximum pieces per tote.
     *    OPSTOP  -  Honor *SP flag (Y=Yes, N=No).
     *    OPGCDE  -  USF Group Code (0-9).
     *    OPPKUP  -  Picked up by (S=Selector, L=Loader).
     *    OPSPAL  -  Merge pallet should only contain
     *               items for single truck pallet (Y=Yes, N=No).
     *    OPPITM  -  Maximum items per pallet.
     *
     * Data structure
     *
     D opzdta          ds
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
     D  oppbld                34     34
     D  opselm                35     35
     D  opsplt                36     36
     D  opbmrg                37     37
     D  opnwpl                38     38
     D  opford                39     40  0 inz(0)
     D  opptyp                41     41
     D  opftot                42     43  0 inz(0)
     D  optecb                44     48  2 inz(0)
     D  opticb                49     53  2 inz(0)
     D  optstp                54     55  0 inz(0)
     D  optord                56     57  0 inz(0)
     D  optpcs                58     60  0 inz(0)
     D  opstop                61     61
     ** Note: Pos 62 is OPGCDE for USF, but OPPKUP for all other clients.
     D**opgcde                62     62
     D  oppkup                62     62
     D  opspal                63     63
     D  oppitm                64     67  0 inz(0)
     D  opend1               117    117

     *----------------------------------------------------------------
     *  Working variables
     *
720bAD pc              c                   Const('%')
730cDD*sq              c                   Const('''')
     D $puser          s             10
     D $ptmpl          s             10
     D bulk            s              1
     D brkDwnFlg       s              1
740dAD defaultBrkQty   s              1  0 inz(1)
     D canbrk1         s              1
     D canbrk2         s              1
     D client          s             10
     D clientloc       s             10
720fAd dbgflgExists    s               n
720fAd debug           s               n
720fAd debugAfter      s               n
720fAd debugBefore     s               n
720fAd debugLoc        s              1
710eAD dirLen          s              3  0
730cDD*error           s               n
     D fd              s             10I 0
     D filnam          s             25
     D first           s              1
730cDD*forever         s               n
     D gs1item         s              1
     D gs1uniq         s              1
720aAD hasChildren     s               n
730cDD*i               s              3  0
     D ihrng           s              9  2
     D ihvar           s              9  2
     D ilrng           s              9  2
     D ilvar           s              9  2
     D hld_ohord       s                   like(ohord)
     D hld_ohcord      s                   like(ohcord)
730cAD hld_ohcorda     s             15
     D hld_plid        s                   like(psplid)
     D hld_rtidplt     s              9
     D hld_trn         s                   like(pstrn#)
     d line            s           3072    varying
     d gToteFlag       s               n
     d gToteNum        s                   like(tohcnt)
     d gToteId         s                   like(tohlbl)

     D logStatus       s                   like(ttlStatus)
     D logErrCode      s                   like(ttlErrCode)
     D logErrMsg       s                   like(ttlErrMsg)
     D NoNameDriver    s              5  0 inz(99999)
     D ordp_cub        s              9  3 inz(0)
     D ordp_wgt        s              9  2 inz(0)
     D ordp_pcs        s              5  0 inz(0)
     D out_flags       s             10u 0
     D out_mode        s             10u 0
     D prg1c           s              4  3
     D prg2c           s              4  3
     D sFileSnd        s             30
     D stmfSend        S            256A
     D stpFlgCnt       s              3  0
     D totrtec         s              9  3 inz(0)
     D totrtew         s              9  2 inz(0)
     D totrtep         s              5  0 inz(0)
     D url             S            256A
720cAD wkMisc          s             20
     D wrtChunk        s               n
720dAD question        S            512A


     *----------------------------------------------------------------
     *  Date/time variables
     *
     D bfcoffset       s              3  0 inz(0)
     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

720bA*----------------------------------------------------------------
720bA*  Standard SQL variables and constants
720bA*----------------------------------------------------------------

720bA /copy qcopysrc,c#stdsql
730cAD/copy qcopysrc,c#stdvar

720bA   // SQL Data Structure for ORDH/OHMISC retrieval

720bAd CusDta          ds            20    Qualified
720bAd  cusnum                       20    overlay(cusdta)

     *----------------------------------------------------------------
     *
     * Data structure

     D optrdtDS        ds
     D  optrdt12               1      2    inz('00')
     D  optrdt3                3      3    inz(':')
     D  optrdt45               4      5    inz('00')

     *----------------------------------------------------------------
     *  Routes List
     DgTimers          DS                  occurs(20) qualified
     D startDate                      8  0
     D StartTime                      6  0

     *----------------------------------------------------------------
     *  Routes List
     DgRoutes          DS                  occurs(20) qualified
     D rtid                                like(rhrtid)
     D rte                                 like(rhrte)
     D truckid                             like(rhtruk)
     D license                       15

     *----------------------------------------------------------------
     *  Department Summary List
     DgDeptSum         DS                  occurs(500) qualified
     D dept                                like(lbwhdp)
     D pcs                            5  0
     D wgt                            9  2
     D cube                           9  3

     *----------------------------------------------------------------
     *  Stops Summary List
     DgStops           DS                  occurs(500) qualified
710dDD*stop                                like(lbstop)
710dMD hostStop                       5  0
710dAD stopId                              like(lbstop)
     D pcs                            5  0
     D wgt                            9  2
     D cube                           9  3
720bDD*custNumber                          like(ohcust)
720bMD custNumber                    20
     D custName                            like(ohcnam)
     D companyName                         like(ohcnam)
     D custAdr1                            like(ohcad1)
     D custAdr2                            like(ohcad2)
     D custCity                            like(ohccty)
     D custState                           like(ohcst)
     D custZip                             like(ohczip)

     *----------------------------------------------------------------
     *  Global Variables
     D gGroupId        s              5  0
     D gParentId       s             10
     D gRoutesCount    s              3  0
     D gDeptSumCount   s              3  0
     D gStopsCount     s              3  0
     D gDriverFirst    s             15
     D gDriverLast     s             20
     D gDriverPhone    s             15

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d CmdInzROUTE     pr

     d GetCurrStamp    pr

     d GetCWRange      pr

     d GetItem         pr

     d GetOptions      pr

     d GetZoneOpts     pr

     d LineAdd         pr
     d  attributeName               100    const varying
     d  value                       500    const varying

     d LineEnd         pr

     d LineStart       pr
     d  elementName                 100    const varying

     d OpenFile        pr

720dAd PCMAdd          pr
720dAd  PCMQuestion                1000    const varying

     d SetLogTime      pr

     d TimerStart      pr
     d  timerNumber                   3  0 const

     d TimerStop       pr
     d  timerNumber                   3  0 const

     d UpdateTTLog     pr

     d WriteCompany    pr

     d WriteConfig     pr

     d WriteConfigCust...
     d                 pr

     d WriteConfigs    pr

720fAd WrtDebugLibl    pr
720fAd WrtDebugParms   pr
720fAd WrtDebug        pr

     d WriteDepartmentSummary...
     d                 pr

     d GetDriver       pr

     d WriteGTIN       pr

     d WriteHeader     pr

740fAd WriteInvoice    pr

     d WriteInvoices   pr

740fAd WriteInvItem    pr

740fAd WriteInvItems   pr

740fAd WriteInvCW      pr

740fAd WriteInvCWs     pr

     d WriteItem       pr

     d WriteItems      pr

     d WriteTotes      pr

720dAd WriteQuestion   pr
720dAd  timing                        1    const
720dAd  nextquestion               1000    const varying
720hAd  stoptype                      3    const varying

     d WriteQuestions  pr

     d WriteReasonCodes...
     d                 pr

     d WriteReturnCodes...
     d                 pr

     d WriteRoute      pr

     d WriteRoutes     pr

     d WriteStop       pr

     d WriteStops      pr

     d WriteStopFlag   pr

     d WriteStopFlags  pr

     d WriteSummary    pr

     d WriteSummaryTotal...
     d                 pr

     d WriteTruckStopFlag...
     d                 pr

     d WriteTTLog      pr

     d WriteUserInfo   pr

     d ZZDriCop        pr


     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

     D/copy qcopysrc,p.calctime
     D/copy qcopysrc,p.cvtdte
     D/copy qcopysrc,p.cvttext
     D/copy qcopysrc,p.clcdur
     D/copy qcopysrc,p.getclien
     D/copy qcopysrc,p.trvfyemp
     D/copy qcopysrc,p.dricop
     D/copy qcopysrc,p.getzontm
710aAD/copy qcopysrc,p.getempl
710dAD/copy qcopysrc,p.getstop
720dAD/copy qcopysrc,p.pcmgetqt
730cAD/copy qcopysrc,p.exordh

     *----------------------------------------------------------------
     *  IFS Prototypes
     *----------------------------------------------------------------

     D/copy qcopysrc,c#ifsio_h
     D/copy qcopysrc,errno_h
      /copy qcopysrc,p.bfcdteti

     D chkifsobj       pr                  extpgm('CHKIFSOBJ')
     D  path                        640A   const
     D  authority                    10A   const

720fA*----------------------------------------------------------------
720fA*  Prototypes
720fA*----------------------------------------------------------------

720fAd GetLiblCL       pr                  extpgm('GETLIBLCL')
720fAd  libList                    1024

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ROUTE
     *              *COMPANY
     *      $PWHSE  Warehouse
     *      $PRTID  Route ID
     *      $PEMP   Employee
     *
     *    Returned Parameters
     *      $FILNAM          - XML file name.
     *      $PRTN   *OK      - Route was processed.
     *              *CANCEL  - Route was not processed.
     *      $PERM            - Error message.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd            10
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $pemp             5
     C                   parm                    sFileSnd
     C                   parm                    $prtn             8
     C                   parm                    $perm            60
     *
     * Main line
     *

      /free
       *inlr = *on;
       $prtn = '*OK';

720fA   // See if debug is turned on

720fA   debug = *off;
720fA   if dbgflgExists;
720fA     chain(e) (#pgm) bfcdbgflg;
720fA     if %found(bfcdbgflg);
720fA       select;
720fA         when bdfflag > 0;
720fA           debug = *on;
720fA       endsl;
720fA     endif;
720fA   endif;

720fA   if debug;
720fA     WrtDebugLibl();
720fA     WrtDebugParms();
720fA   endif;

       // Verify command

710cM  if $pCmd <> '*COMPANY'
710cM    and $pCmd <> '*ROUTE';
           $prtn = '*INVLDCMD';
           $perm = 'Invalid command sent - ' + $pCmd;
           return;
       endif;

720aA  // Get the parent (if the route passed in is not the parent)
720aA
720aA  hasChildren = *off;
720aA  gParentId = $prtid;
720aA
720aA  chain ($pwhse: $prtid) ttmerg;
720aA  if %found(ttmerg);
720aA    hasChildren = *on;
720aA    gParentId = $prtid;
720aA  else;
720aA    chain ($pwhse: $prtid) ttmerg2;
720aA    if %found(ttmerg2);
720aA      hasChildren = *on;
720aA      gParentId = tt2_ttmpri;
720aA    endif;
720aA  endif;

       // Start the timer and begin

       TimerStart(1);

       //  Write or update FILESTART record to log file

       logErrCode = 'FILESTART';
       logErrMsg = 'File creation start';
       logStatus = '1';
       UpdateTTLog();

       //  Open the file to write to, get out if error

       OpenFile();
       if fd < 0;
         TimerStop(1);
         return;
       endif;

       // Write XML Header

       WriteHeader();

       // Start XML file

710aD  //line = '<TRAXData>';
710aM  line = '<TRAXData '
710aA       + 'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
710aA       + 'xsi:noNamespaceSchemaLocation="http://'
710aA       + %Trim(optwsi) + ':' + %TrimL(%editc(optwsp:'P'))
710aA       + '/BFCTraxWS/BFCTraxV20.xsd"'
710aA       + '>';
       WriteLine(fd: %addr(line)+2: %len(line));

       // Write Sections
       //   We track the time but only write it if writeChunk = *on

       wrtChunk = *on;

       select;

710cM    when $pCmd = '*COMPANY';
           WriteCompany();

710cM    when $pCmd = '*ROUTE';
           CmdInzROUTE();
           if $prtn = '*CANCEL';
             return;
           endif;

           WriteUserInfo();

           TimerStart(2);
             WriteRoutes();
720eA        if $prtn = '*CANCEL';
720eA          return;
720eA        endif;
           TimerStop(2);

           TimerStart(3);
             WriteSummary();
           TimerStop(3);

           TimerStart(4);
             WriteStops();
           TimerStop(4);

           TimerStart(5);
             WriteItems();
           TimerStop(5);

           TimerStart(6);
             WriteInvoices();
740fA        WriteInvItems();
740fA        WriteInvCWs();
           TimerStop(6);

           TimerStart(7);
             WriteConfigs();
             WriteReturnCodes();
             WriteReasonCodes();
             WriteQuestions();
             WriteStopFlags();
           TimerStop(7);

       endsl;


       // End XML file

       line = '</TRAXData>';
       WriteLine(fd: %addr(line)+2: %len(line));

       //  The route's XML has been successfully written, update log record.

       logErrCode = 'FILEEND';
       logErrMsg = 'File creation end';
       logStatus = '2';
       UpdateTTLog();

       //  Close the file

       callp close(fd);

       TimerStop(1);

      /end-free

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

      /free
       begsr *pssr;

         // Make sure we don't get caught in an infinite loop

         if pssrflag;
           *inlr = *on;
           return;
         endif;

         pssrflag = *on;

         //  Send message back to calling program

         dump(a);

         $prtn = '*ERROR';
         $perm = 'PSSR: ' + %trim(#pgm) + ' (' + %char(#stmt) + ') '
                + #status + ' - ' + %trim(#pgmmsg);

         *inlr = *on;
         return;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
      /free

720fA    open(e) bfcdbgflg;
720fA    if %error;
720fA      dbgflgExists = *off;
720fA    else;
720fA      dbgflgExists = *on;
720fA    endif;

       first = *on;

       GetClient(client: clientLoc);

       getOptions();

       //  Reformat restart daily time

      /end-free

     C                   if        optrdt > 0
     C                   movel     optrdt        optrdt12
     C                   move      optrdt        optrdt45
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  CndInzROUTE  ROUTE command initialization
     *----------------------------------------------------------------

     p CmdInzROUTE     b
     d CmdInzROUTE     pi

     * Local Variables

     d  uEmp           s              5  0
     d  uWhse          s              3  0
     d  uUser          s             10
     d  e$fnam         s             15
     d  e$init         s              1
     d  e$lnam         s             20
     d  e$whdp         s              5
     d  e$styp         s              1
     d  e$shft         s              6
     d  e$crew         s              6
     d  e$nhrs         s              3  1
     d  e$rtn          s              8
     d  e$bpu          s              1
     d  e$lng          s              2
710fAd  e$email        s              1
710fAd  e$pics         s              1

      /free

       //  If emp# is blank, check to see if a 'no name driver' exists.
       //  If so, force $pemp to be the 'no name driver'.

       if $pemp = ' '
         or $pemp = '00000';
           chain NoNameDriver piruser1;
           if %found(piruser1);
             $pemp = %char(NoNameDriver);
           endif;
       endif;

       //  Verify employee ... get out if not found

       TRVfyEmp($pemp: $perm: $puser);

       if $perm <> ' ';
         $prtn = '*CANCEL';
         return;
       endif;

       // Get driver info

       monitor;
         uEmp = %dec($pemp:5:0);
       on-error;
         uEmp = NoNameDriver;
       endmon;

710fM  //GetEmpl(uEmp: uWhse: uUser: e$fnam: e$init: e$lnam:
       //        e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
       //        e$bpu: e$lng: e$email: e$pics);
710fM  GetEmpl(uEmp: uWhse: uUser: e$fnam: e$init: e$lnam:
               e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
               e$bpu: e$lng);

       gDriverFirst = e$fnam;
       gDriverLast = e$lnam;
       gDriverPhone = '';

       // Get route group ID

       chain ($pwhse: $prtid) ttgrp;
       if not %found(ttgrp);
         gGroupId = 0;
       else;
         gGroupId = ttggid;
       endif;

      /end-free

     p CmdInzROUTE     e

     *----------------------------------------------------------------
     *  GetCurrStamp   Get current timestamps
     *----------------------------------------------------------------

     p GetCurrStamp    b
     d GetCurrStamp    pi

      /free

       getmicrotime(currstampuc:currstampsys);
       currstamploc = currstampsys + %hours(bfcoffset);

      /end-free

     p GetCurrStamp    e

     *----------------------------------------------------------------
     *  GetCWRange   Get catchweight range
     *----------------------------------------------------------------

     p GetCWRange      b
     d GetCWRange      pi

      /free

       ilvar = 0;
       ihvar = 0;
       ilrng = 0;
       ihrng = 0;
       prg1c = *zeros;
       prg2c = *zeros;

       if $itcwgt <> 'Y';
         return;
       endif;

       if $imrg1c <> 0;
         prg1c = $imrg1c / 100;
       endif;

       if $imrg2c <> 0;
         prg2c = $imrg2c / 100;
       endif;

       if prg1c = 0;
         prg1c = oprg1c / 100;
       endif;

       if prg2c = 0;
         prg2c = oprg2c / 100;
       endif;

       if prg1c > 0;
         ilvar = $itswgt * prg1c;
       endif;
       ilrng = $itswgt - ilvar;

       if prg2c > 0;
         ihvar = $itswgt * prg2c;
       endif;
       ihrng = $itswgt + ihvar;

      /end-free

     p GetCWRange      e

     *----------------------------------------------------------------
     *  GetItem  Get item info.
     *----------------------------------------------------------------

     p GetItem         b
     d GetItem         pi

      /free

       savever# = $itver#;
       clear $item;
       clear $item2;
       $itver# = savever#;

       $itwhse   = orpwhs;
       $ititem   = orpitm;

       $dricommand = '*ITEM';
       $drisubcmd  = '%GETMAIN';
       $drisys2upd = 'D';

       ZZDricop();

       if error = *on;
         $itcwgt = 'N';
         $itdesc = *blanks;
         $itupc  = *blanks;
         $itum2  = *blanks;
         $itumq2 = 0;
         $itum3  = *blanks;
         $itumq3 = 0;
         $itdesg = *blanks;
       endif;

      /end-free

     p GetItem         e

     *----------------------------------------------------------------
     *  GetOptions  Get options
     *----------------------------------------------------------------

     p GetOptions      b
     d GetOptions      pi

      /free

       chain ($pwhse: '*TRAX') Options;
       if not %found;
         opdta  = ' ';
       else;
         opdta  = opdata;
       endif;

       chain ($pwhse: '*TRAX1') Options;
       if not %found;
         opdta1  = ' ';
       else;
         opdta1  = opdata;
       endif;

       chain ($pwhse: '*TRAX2') Options;
       if not %found;
         opdta2  = ' ';
       else;
         opdta2  = opdata;
       endif;

       chain (0: '*SYSTEM') Options;
       if not %found;
         opcapc = 'Y';
         opwrncr = 'N';
         oprg1c = 0;
         oprg2c = 0;
         opicwr = 'N';
       endif;

      /end-free

     p GetOptions      e

     *----------------------------------------------------------------
     *  GetZoneOpts   Get zone options
     *----------------------------------------------------------------

     p GetZoneOpts     b
     d GetZoneOpts     pi

      /free

       GetZonTmpl($pwhse: pstruk: $ptmpl);

710bM  chain(e) ('*PICK': $pwhse: $ptmpl: lwtzon) optionz;
       if not %found(optionz);
         opptyp = '';
       endif;

      /end-free

     p GetZoneOpts     e

     *----------------------------------------------------------------
     *  LineAdd     Add attribut to element line
     *----------------------------------------------------------------

     p LineAdd         b
     d LineAdd         pi
     d  attributeName               100    const varying
     d  value                       500    const varying

     * Local Variables

     d  cmd            s             10
     d  valueIn        s            500
     d  valueOut       s            500

      /free

        cmd = '*XML';
        valueIn = value;
        valueOut = '';
        CvtText(cmd: valueIn: valueOut);

        line += ' ' + attributeName + '="' + %trim(valueOut) + '"';
        return;

      /end-free

     p LineAdd         e

     *----------------------------------------------------------------
     *  LineEnd     End element line
     *----------------------------------------------------------------

     p LineEnd         b
     d LineEnd         pi

      /free
        line += '/>';
        return;
      /end-free

     p LineEnd         e

     *----------------------------------------------------------------
     *  LineStart   Start element line
     *----------------------------------------------------------------

     p LineStart       b
     d LineStart       pi
     d  elementName                 100    const varying

      /free
        line = '<' + elementName;
        return;
      /end-free

     p LineStart       e

     *----------------------------------------------------------------
     *  OpenFile      Open file
     *----------------------------------------------------------------

     p OpenFile        b
     d OpenFile        pi

     * Local Variables

     d  i              s              3  0

      /free

       //  Construct file name using whse, route id and version

       select;

710cM    when $pCmd = '*COMPANY';
           sFileSnd = 'Company'
                    + '_W' +  %TrimL(%editc($pwhse:'X'))
                    + '_V020.XML';

710cM    when $pCmd = '*ROUTE';
           sFileSnd = 'W' +  %TrimL(%editc($pwhse:'X'))
720aD  //           + 'R' + $prtid
720aM               + 'R' + %trim(gParentId)
                    + '_V020'
                    + '_RTE.XML';

       endsl;

       select;

710eA    when optdir <> '';
710eA      dirLen = %len(%trimr(optdir));
710eA      if %subst(optdir:1:1) <> '/';
710eA        url = '/' + optdir;
710eA      else;
710eA        url = optdir;
710eA      endif;
710eA      if %subst(optdir:dirLen:1) <> '/';
710eA        url = %trimr(url) + '/';
710eA      endif;

         when optert = 'PROD';
           url = '/BFCTrax/';

         when optert = 'TEST';
           url = '/BFCTraxTest/';

         when optert = 'DEV ';
           url = '/BFCTraxDev/';

       endsl;

       stmfSend = %trimr(url) + sFileSnd;

       // Set file properties

       out_flags = o_wronly + o_creat + o_trunc
                 + o_share_rdwr + o_codepage;

       out_mode = s_irusr + s_iwusr + s_ixusr
                + s_irgrp + s_iwgrp + s_ixgrp
                + s_iroth + s_iwoth + s_ixoth;

       // Open file, get out if error

       fd = open(%trimr(stmfSend)
            :out_flags
            :out_mode:819);
       if fd < 0;
         logErrCode = 'CRTOPNERR1';
         logErrMsg = 'File create error: '
                   + %str(strerror(errno));
         logStatus = '9';
         UpdateTTLog();
         return;
       endif;

       //  Close, then re-open the file in text mode

       callp close(fd);
       fd = open(%trimr(stmfSend):
            O_WRONLY+O_TEXTDATA);
       if fd < 0;
         logErrCode = 'CRTOPNERR1';
         logErrMsg = 'File reopen error: '
                   + %str(strerror(errno));
         logStatus = '9';
         updateTTLog();
         return;
       endif;

       return;

      /end-free

     p OpenFile        e

720dA*----------------------------------------------------------------
720dA*  PCMAdd      Add PCM Question to element line
720dA*----------------------------------------------------------------

720dAp PCMAdd          b
720dAd PCMAdd          pi
720dAd  PCMQuestion                1000    const varying

720dA* Local Variables

720dA /free

720dA   line += ' ' + %trimr(PCMQuestion);
720dA   return;

720dA /end-free

720dAp PCMAdd          e

     *----------------------------------------------------------------
     *  SetLogTime  Set appropriate log time fields
     *----------------------------------------------------------------

     p SetLogTime      b
     d SetLogTime      pi

      /free

         getCurrStamp();

         select;
           when ttlStatus = '1';
             ttlTS1   = currStampLoc;
             ttlPgm1  = #pgm;
             ttlUser1 = #user;
             ttlJob1  = #Job;
             ttlNbr1  = #Jobnbr;
           when ttlStatus = '2';
             ttlTS2   = currStampLoc;
         endsl;

         ttlTS9   = currStampLoc;

      /end-free

     p SetLogTime      e

     *----------------------------------------------------------------
     *  TimerStart    Start timer
     *----------------------------------------------------------------

     p TimerStart      b
     d TimerStart      pi
     d  timerNumber                   3  0 const

      /free

       %occur(gTimers) = timerNumber;

       $cvcmd = '*CURCMD';
       cvtdte($cvtdt);
       gTimers.startDate = $cvd8o;
       gTImers.StartTime = %dec(%time():*hms);

      /end-free

     p TimerStart      e

     *----------------------------------------------------------------
     *  TimerStop    Stop timer
     *----------------------------------------------------------------

     p TimerStop       b
     d TimerStop       pi
     d  timerNumber                   3  0 const

      /free

       if timerNumber > 1 and wrtChunk = *off;
         return;
       endif;

       %occur(gTimers) = timerNumber;

       if timerNumber = 1;
         rttpgm = '*TRAXXML';
       else;
         rttpgm = %trim(#pgm) + '.' + %char(timerNumber);
       endif;

       rttwhs = $pwhse;
720aD  //rttrid = $prtid;
720aM  rttrid = gParentId;
       rttsdt = gTimers.startDate;
       rttstm = gTimers.StartTime;

       $cvcmd = '*CURCMD ';
       cvtdte($cvtdt);
       rttedt = $cvd8o;
       rttetm = %dec(%time():*hms);
       rttrdt = rttsdt;

       // If start time is less than 5:00am
       // Then subtract 1 from the day for report date.

       if rttstm < 50000;
         $cvcmd = '*CMDCMD ';
         $cvd8i = %editc(rttsdt: 'X');
         $cvdr1 = '*SUBDAYS';
         $cvvl1 = 1;
         ClcDur($cvtdt);
         rttrdt = $cvd8o;
       endif;

       $cvcmd = '*MINUTES';
       CalcTime($cvcmd: rttsdt: rttstm: rttedt: rttetm: rttmin);

       rttjob = #job;
       rttusr = #user;
       rttjb# = %dec(#jobn: 8: 0);

       write rttrec;

      /end-free

     p TimerStop       e

     *----------------------------------------------------------------
     *  UpdateTTLog   Update log
     *----------------------------------------------------------------

     p UpdateTTLog     b
     d UpdateTTLog     pi

      /free

720aD  //chain ($pwhse: $prtid) ttrte;
720aM  chain ($pwhse: gParentId) ttrte;
       if not %found(ttrte);
         ttrser = '';
       endif;

720aD  //chain ($pwhse: $prtid: 1) ttlog;
720aM  chain ($pwhse: gParentId: 1) ttlog;
       if not %found(ttlog);
         WriteTTLog();
       else;
         ttlStatus = logStatus;
         ttlErrCode = logErrCode;
         ttlErrMsg  = logErrMsg;
         ttlSer = ttrSer;
         SetLogTime();
         update(e) ttlrec;
       endif;

      /end-free

     p UpdateTTLog     e

     *----------------------------------------------------------------
     *  WriteCompany    Write company info
     *----------------------------------------------------------------

     p WriteCompany    b
     d WriteCompany    pi

     * Local Variables

     d  line2          s             30

      /free

       chain ($pwhse) warehs;
       if not %found(warehs);
         clear whrec;
       endif;


       chain ($pwhse) warehsad;
       if not %found(warehsad);
         clear wharec;
       endif;

       line2 = %trim(whacty) + ', ' + %trim(whast) + ' ' + %trim(whazip);

       LineStart('CompanyInfo');

       LineAdd('warehouse': %editc($pwhse:'P'));
       LineAdd('name': whdesc);
       LineAdd('addressLine1': whaad1);
       LineAdd('addressLine2': whaad2);
       LineAdd('city': whacty);
       LineAdd('state': whast);
       LineAdd('zip': whazip);
       LineAdd('companyPhone': '');
       LineAdd('contactName': '');
       LineAdd('contactLastName': '');
       LineAdd('contactEMail': '');
       LineAdd('logoFileName': '');
       LineAdd('logoDrawingWidth': '');
       LineAdd('logoDrawingHeight': '');
       LineAdd('logoData': '');

       LineEnd();

       WriteLine(fd: %addr(line)+2: %len(line));

       return;

      /end-free

     p WriteCompany    e

     *----------------------------------------------------------------
     *  WriteConfig    Write configuration element
     *----------------------------------------------------------------

     p WriteConfig     b
     d WriteConfig     pi

      /free

        LineStart('Configuration');

710aA   LineAdd('configType': 'Default');
710aM   LineAdd('traxRouteGroupID': '');
        LineAdd('parentRouteID': '');
        LineAdd('routeID': '');
        LineAdd('stopNumber': '');
710fD   //LineAdd('wsIP': optwsi);
710fD   //LineAdd('wsPort': %editc(optwsp:'P'));
        LineAdd('warehouseCode': '');
        LineAdd('driverFieldType': optdft);
        LineAdd('routeFieldType': optrft);
        LineAdd('capitalizeInput': optcap);
        LineAdd('doubleClickDelivery': optdbl);
        LineAdd('entryKeyDelivery': optekd);
        LineAdd('deliveryAfterReturn': optdar);
        LineAdd('includeItemDB': optidb);
        LineAdd('breakDownsAllowed': optbda);
        LineAdd('genericBreakDownAllowed': optgbd);
        LineAdd('preTripQuestions': optrtq);
        LineAdd('postTripQuestions': optotq);
        LineAdd('creditCardEnabled': optcce);
CLDaA   if client = cityline;
CLDaA     LineAdd('signatureEnabled': 'Y');
CLDaA   else;
          LineAdd('signatureEnabled': optsig);
CLDaA   endif;
        LineAdd('printInvoice': optpiv);
        LineAdd('sendDataAfterStop': optsda);
        LineAdd('saveLoginInfo': optsli);
        LineAdd('orderNumberFieldType': optoft);
        LineAdd('catchWeightRequired': optcwr);
        LineAdd('saveDays': %editc(optsvd:'P'));
        LineAdd('client': client);
        LineAdd('clientLoc': clientloc);
        LineAdd('envRuntime': optert);
        LineAdd('envDevice': optedv);
        LineAdd('envOS': opteos);
        LineAdd('envScreenWidth': %editc(optesw:'P'));
        LineAdd('envScreenHeight': %editc(optesh:'P'));
        LineAdd('addReturnEnabled': optare);
        LineAdd('iconDelivery': optidl);
        LineAdd('doubleClickIcons': optdci);
        LineAdd('emailReceipt': opter);
        LineAdd('receiptEmailFrom': optref);
        LineAdd('receiptEmailSubject': optres);
        LineAdd('palletsEnabled': optpal);
        LineAdd('cradleUploadEnabled': optcra);
        LineAdd('displayEmptyStop': opteys);
        LineAdd('bulkItemsEnabled': optbul);
        LineAdd('saveAfterScan': optsas);
        LineAdd('saveDelay': %editc(optsdl:'P'));
        LineAdd('syncDateTime': optsdt);
        LineAdd('scanBeepVolume': %editc(optsbv:'P'));
        LineAdd('gs1Scanning': optgss);
        LineAdd('gs1Unique': optgsu);
        LineAdd('leftRightKeysEnabled': optlrk);
        LineAdd('restartAfterGetRoute': optrag);
        LineAdd('restartDaily': optrd);
        LineAdd('restartDailyTime': optrdtDS);
        LineAdd('filterByDepartment': optfbd);
        LineAdd('nonScanReasonPrompt': optnsr);
        LineAdd('readerFocusMode': optrfm);
        LineAdd('readerFocusPosition': optrfp);
        LineAdd('useSystemSuspendBatteryPowerTimeout': optsbu);
        LineAdd('systemSuspendBatteryPowerTimeout':%editc(optsb:'P'));
        LineAdd('useSystemSuspendExternalPowerTimeout': optseu);
        LineAdd('systemSuspendExternalPowerTimeout': %editc(optse:'P'));
        LineAdd('useBackLightOffBatteryPowerTimeout': optbbu);
        LineAdd('backLightOffBatteryPowerTimeout': %editc(optbb:'P'));
        LineAdd('useBackLightOffExternalPowerTimeout': optbeu);
        LineAdd('backLightOffExternalPowerTimeout': %editc(optbe:'P'));
        LineAdd('displayStopFlagsBeforeRestart': optdsf);
730bA   LineAdd('customerOnSiteDeliveryEnable': optode);
730bA   LineAdd('customerOnSiteDeliveryVerificationPeriod': %editc(optodp:'P'));
730bA   LineAdd('onTruckPicking': optont);
730bA   LineAdd('enableOverrideTruckPicking': optotp);
730eA   LineAdd('traxSortItemsByCompartment': optsor);
730eA   LineAdd('enableNoSigneeButton': optnsb);
740eA   LineAdd('traxMultirouteEnable': optmul);
740eA   LineAdd('traxLogLevel': optsvl);
740eA   LineAdd('traxSendStopPicturesEnable': optssp);
740eA   LineAdd('traxSendStopSignaturesEnable': optsss);
740eA   LineAdd('traxSendStopTRAXLogEnable': optsst);
740eA   LineAdd('traxKeepLoginInfo':optkpl);
740eA   LineAdd('traxShowLogInfo': optshl);
740eA   LineAdd('enablePrinter': optprt);
740eA   LineAdd('enableSpeak': optspk);
740eA   LineAdd('enableGPS': optgps);
740eA   LineAdd('gpsProbePeriodMinutes':%editc(optmin:'P'));
740eA   LineAdd('gpsProbeDistanceMeters':%editc(optmet:'P'));
740eA   LineAdd('traxAdminCode': optpwd);
740eA   LineAdd('traxOffset':%editc(optoff:'P'));
740eA   LineAdd('traxAppAutoUpdate': optaut);
740eA   LineAdd('traxCompanyCallPhoneNumber':%editc(optph1:'P'));
740eA   LineAdd('traxCompanyDispatchMessagePhoneNumber':%editc(optph2:'P'));
740eA   LineAdd('enableCameraBarcodeScanner': optcam);
740eA   LineAdd('disableDriverLoginValidation': optdil);
740eA   LineAdd('disableDriverPasswordLoginValidation': optdip);
740eA   LineAdd('traxAppUrl': opturl);
740eA   LineAdd('traxSygicIntegration': optsyg);

        LineEnd();

        WriteLine(fd: %addr(line)+2: %len(line));

        return;

      /end-free

     p WriteConfig     e

     *----------------------------------------------------------------
     *  WriteConfig    Write configuration element
     *----------------------------------------------------------------

     p WriteConfigCust...
     p                 b
     d WriteConfigCust...
     d                 pi

      /free

        LineStart('Configuration');

710aA   LineAdd('configType': 'Stop');
710aM   LineAdd('traxRouteGroupID': %editc(gGroupId: 'X'));
710aM   LineAdd('parentRouteID': gParentId);
        LineAdd('routeID': gParentId);
710dM   LineAdd('stopNumber': %editc(gStops.hostStop: 'P'));
710dM   LineAdd('stopId': %editc(gStops.stopId: 'P'));
        if opcbda <> optbda;
          LineAdd('breakDownsAllowed': opcbda);
        endif;
        if opcgbd <> optgbd;
        LineAdd('genericBreakDownAllowed': opcgbd);
        endif;
        if opcrtq <> optrtq;
        LineAdd('preTripQuestions': opcrtq);
        endif;
        if opcotq <> optotq;
        LineAdd('postTripQuestions': opcotq);
        endif;
        if opccce <> optcce;
        LineAdd('creditCardEnabled': opccce);
        endif;
        if opcsig <> optsig;
        LineAdd('signatureEnabled': opcsig);
        endif;
        if opcpiv <> optpiv;
        LineAdd('printInvoice': opcpiv);
        endif;
        if opcsda <> optsda;
        LineAdd('sendDataAfterStop': opcsda);
        endif;
        if opccwr <> optcwr;
        LineAdd('catchWeightRequired': opccwr);
        endif;
        if opcare <> optare;
        LineAdd('addReturnEnabled': opcare);
        endif;
        if opcer <> opter;
        LineAdd('emailReceipt': opcer);
        endif;
        if opcref <> optref;
        LineAdd('receiptEmailFrom': opcref);
        endif;
        if opcres <> optres;
        LineAdd('receiptEmailSubject': opcres);
        endif;
730hD   //if opcpal <> optpal;
730hM   if opcpal <> optpal and opcpal <> ' ';
        LineAdd('palletsEnabled': opcpal);
        endif;
        if opcbul <> optbul;
        LineAdd('bulkItemsEnabled': opcbul);
        endif;
        if opcgss <> optgss;
        LineAdd('gs1Scanning': opcgss);
        endif;
        if opcgsu <> optgsu;
        LineAdd('gs1Unique': opcgsu);
        endif;
        if opcfbd <> optfbd;
730eD   //LineAdd('filterByDepartment': optfbd);
730dM   LineAdd('filterByDepartment': opcfbd);
        endif;
        if opcnsr <> optnsr;
        LineAdd('nonScanReasonPrompt': opcnsr);
        endif;
730bA   if opcodx <> optode;
730bA   LineAdd('customerOnSiteDeliveryEnable': opcodx);
730bA   endif;
730bA   if opcodp <> optodp;
730bA   LineAdd('customerOnSiteDeliveryVerificationPeriod': %editc(opcodp:'P'));
730bA   endif;
730bA   if opcont <> optont;
730bA   LineAdd('onTruckPicking': opcont);
730bA   endif;
730bA   if opcotp <> optotp;
730bA   LineAdd('enableOverrideTruckPicking': opcotp);
730bA   endif;
730eA   if opcsor <> optsor;
730eA   LineAdd('traxSortItemsByCompartment': opcsor);
730eA   endif;
730eA   if opcnsb <> optnsb;
730eA   LineAdd('enableNoSigneeButton': opcnsb);
730eA   endif;

        LineEnd();

        WriteLine(fd: %addr(line)+2: %len(line));

        return;

      /end-free

     p WriteConfigCust...
     p                 e

     *----------------------------------------------------------------
     *  WriteConfigs   Write configurations
     *----------------------------------------------------------------

     p WriteConfigs    b
     d WriteConfigs    pi

     * Local Variables

     d  i              s              3  0

      /free

       //  Write begin tag for Configurations

       line = '<Configurations>';
       WriteLine(fd: %addr(line)+2: %len(line));

       // Loop through configs

       WriteConfig();

       // Write Customer configuration overrides

       for i = 1 to gStopsCount;

         %occur(gStops) = i;

         chain ('*TRAX': $pwhse: gStops.custNumber) Optionc;
         if not %found;
           opcdta0  = ' ';
730cA      opcodp  = 0;
         else;
           opcdta0  = opcdta;
         endif;

         chain ('*TRAX1': $pwhse: gStops.custNumber) Optionc;
         if not %found;
           opcdta1  = ' ';
         else;
           opcdta1  = opcdta;
         endif;

         WriteConfigCust();

       endfor;


       //  Write end tag for Configurations

       line = '</Configurations>';
       WriteLine(fd: %addr(line)+2: %len(line));

       return;

      /end-free

     p WriteConfigs    e

720fA*----------------------------------------------------------------
720fA*  wrtDebugLibl   Write out debug parm record
720fA*----------------------------------------------------------------
720fA
     p WrtDebugLibl    b
     d WrtDebugLibl    pi

      /free

        if not %open(bfcdebug);
          open bfcdebug;
        endif;

        bdtype = 'LIBL';

        GetLiblCL(bdvalues);

        bdaddts = %timestamp();
        bdaddpgm = #pgm;
        bdaddcusr = #curruser;
        bdaddjusr = #user;
        bdaddjob = #job;
        bdaddnbr = #jobnbr;

        write bdrec;

      /end-free
     p                 e

720fA*----------------------------------------------------------------
720fA*  wrtDebugParms  Write out debug parm record
720fA*----------------------------------------------------------------
720fA
     p WrtDebugParms   b
     d WrtDebugParms   pi

      /free

        if not %open(bfcdebug);
          open bfcdebug;
        endif;

        bdtype = 'PARMS';

        bdvalues = 'pCmd=' + %trim($pcmd) + ', '
                 + 'pWhse=' + %trim(%char($pwhse)) + ', '
                 + 'pRtid=' + %trim($prtid) + ', '
                 + 'pemp=' + %trim($pemp) + ', '
                 + 'pFileSnd=' + %trim(sFileSnd) + ', '
                 + 'pRtnCode=' + %trim($prtn) + ', '
                 + 'rhrte=' + %trim(rhrte) + ', '
                 + 'rhrtid=' + %trim(rhrtid) + ', '
                 + 'rhstat=' + %trim(rhstat) + ', '
                 + 'pRtnMsg=' + %trim($perm);

        bdaddts = %timestamp();
        bdaddpgm = #pgm;
        bdaddcusr = #curruser;
        bdaddjusr = #user;
        bdaddjob = #job;
        bdaddnbr = #jobnbr;

        write(e) bdrec;

      /end-free

     p                 e

720fA*----------------------------------------------------------------
720fA*  wrtDebug  Write out debug record
720fA*----------------------------------------------------------------
720fA
     p WrtDebug        b
     d WrtDebug        pi

      /free

        if not %open(bfcdebug);
          open bfcdebug;
        endif;

        bdvalues = 'hasChildren=' + hasChildren + ', '
                 + 'rhrtid=' + rhrtid + ', '
                 + 'rhstat=' + rhstat + ', '
                 + 'gParentId=' + gParentId + ', '
                 + '$pRtn=' + $prtn;

        bdaddts = %timestamp();
        bdaddpgm = #pgm;
        bdaddcusr = #curruser;
        bdaddjusr = #user;
        bdaddjob = #job;
        bdaddnbr = #jobnbr;

        write(e) bdrec;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  WriteDepartmentSummary   Write department summary element
     *----------------------------------------------------------------

     p WriteDepartmentSummary...
     p                 b
     d WriteDepartmentSummary...
     d                 pi

      /free

          LineStart('DepartmentSummary');

          LineAdd('traxRouteGroupID': %editc(gGroupId: 'X'));
          LineAdd('parentRouteID': gParentId);
710aA     LineAdd('routeID': gParentId);
          LineAdd('department': gDeptSum.dept);
          LineAdd('cube': %editc(gDeptSum.cube:'P'));
          LineAdd('weight': %editc(gDeptSum.wgt:'P'));
          LineAdd('pieces': %editc(gDeptSum.pcs:'P'));

          LineEnd();

          WriteLine(fd: %addr(line)+2: %len(line));

        return;

      /end-free

     p WriteDepartmentSummary...
     p                 e

     *----------------------------------------------------------------
     *  WriteGTIN       Write item GTIN's
     *----------------------------------------------------------------

     p WriteGTIN       b
     d WriteGTIN       pi


     * Local Variables

     d  firstGTIN      s               n
     d  gtinLen        s              3  0

      /free

       firstGTIN = *on;

       setll ($pwhse: oditem) upc2;

       dou forever <> forever;

         reade ($pwhse: oditem) upc2;
         if %eof(upc2);
           leave;
         endif;

         //  Only grab codes that are 14 or 18 characters


         gtinLen = %len(%trim(upupc));
         if gtinLen <> 14 and gtinLen <> 18;
           iter;
         endif;

         //  GTIN must numeric

         if %check('0123456789': %trim(upupc)) > 0;
           iter;
         endif;

         //  Separate multiple GTIN's with '|'

         if firstGTIN;
           line += ' GTIN="';
           firstGTIN = *off;
         else;
           line += '|';
         endif;

         //  Add GTIN to line

         line += %trim(upupc);

       enddo;

       //  Separate multiple GTIN's with '|'

       if not firstGTIN;
         line += '"';
       endif;

       return;

      /end-free

     p WriteGTIN       e

     *----------------------------------------------------------------
     *  WriteHeader   Write XML header
     *----------------------------------------------------------------

     p WriteHeader     b
     d WriteHeader     pi

      /free

       //  Write XML version record

       line = '<?xml version="1.0" encoding="UTF-8" ?>';
       WriteLine(fd: %addr(line)+2: %len(line));

       return;

      /end-free

     p WriteHeader     e

740fA*----------------------------------------------------------------
740fA*  WriteInvoice   Write invoice element
740fA*----------------------------------------------------------------

740fAp WriteInvoice    b
740fAd WriteInvoice    pi

      /free

          // Get Dakota stop number
          chain (tvhwhs: tvhordid) ordh;
          if not %found(ordh);
            clear ohrec;
          endif;

          if tvhest <= 0;
            tvhest = ohstop;
          endif;

          LineStart('Invoice');

          LineAdd('traxRouteGroupID': %editc(gGroupId: 'X'));
          LineAdd('parentRouteID': gParentId);
          LineAdd('routeID': ohrte);
          LineAdd('stopNumber': %editc(tvhest:'P'));
          LineAdd('stopId': %editc(ohstop:'P'));
          LineAdd('invoiceNumber': tvhinvoice);
          LineAdd('invoiceTerms': tvhterms);
          LineAdd('customerPo': tvhcpo);
          LineAdd('accountManager': tvhactmgr);
          LineAdd('billToName': tvhcnm);
          LineAdd('billToAddr1': tvhca1);
          LineAdd('billToAddr2': tvhca2);
          LineAdd('billToCity': tvhcct);
          LineAdd('billToState': tvhcst);
          LineAdd('billToZip': tvhczp);
          LineAdd('invoiceTotalTax': %editc(tvhtottax:'P'));
          LineAdd('invoiceTotal': %editc(tvhtotinv:'P'));
          LineAdd('invoiceSurchargesFees': %editc(tvhtotfee:'P'));
          LineAdd('printFlag': tvhpmode);
          LineAdd('printCatchweightDetails': tvhpwgts);

          LineEnd();

          WriteLine(fd: %addr(line)+2: %len(line));

        return;

      /end-free

     p WriteInvoice    e

     *----------------------------------------------------------------
     *  WriteInvoices   Write invoices element
     *----------------------------------------------------------------

     p WriteInvoices   b
     d WriteInvoices   pi

      /free

740fA   //  Write begin tag for Invoices

740fA   line = '<Invoices>';
740fA   WriteLine(fd: %addr(line)+2: %len(line));

740fA   // Loop through gRoutes
740fA
740fA   for i = 1 to gRoutesCount;
740fA
740fA     %occur(gRoutes) = i;

740fA     // Loop through invoice headers

740fA     setll ($pwhse: gRoutes.rtid) ttivch;

740fA     dou forever <> forever;

740fA       reade ($pwhse: gRoutes.rtid) ttivch;
740fA       if %eof(ttivch);
740fA         leave;
740fA       endif;

740fA       WriteInvoice();

740fA     enddo;

740fA   endfor;

740fA   //  Write end tag for Invoices

740fA   line = '</Invoices>';
740fA   WriteLine(fd: %addr(line)+2: %len(line));

        return;

      /end-free

     p WriteInvoices   e

740fA*----------------------------------------------------------------
740fA*  WriteInvItem   Write invoice item element
740fA*----------------------------------------------------------------

740fAp WriteInvItem    b
740fAd WriteInvItem    pi

     * Local Variables

     d  hostStop       s              5  0

      /free

          // Get Dakota and Host Stop numbers

          chain (tvdwhs: tvdordid) ordh;
          if not %found(ordh);
            clear ohrec;
          endif;

          GetStop('*PLTSTP': tvdwhs: ohrte: 0: ohstop: hostStop);
          if hostStop <= 0;
            hostStop = ohstop;
          endif;

          LineStart('InvoiceItem');

          LineAdd('traxRouteGroupID': %editc(gGroupId: 'X'));
          LineAdd('parentRouteID': gParentId);
          LineAdd('routeID': ohrte);
          LineAdd('stopNumber': %editc(hostStop:'P'));
          LineAdd('stopId': %editc(ohstop:'P'));
          LineAdd('invoiceNumber': tvdinvoice);
          LineAdd('orderSequenceNumber': %editc(tvdseq:'P'));
          LineAdd('itemNumber': tvditem);
          LineAdd('sortSequence': tvdcsqnr);
          LineAdd('sortSequenceDescription': tvdcsqdsc);
          LineAdd('normalQuantityOrdered': %editc(tvdqo1:'P'));
          LineAdd('breakDown1QuantityOrdered': %editc(tvdqo2:'P'));
          LineAdd('breakDown2QuantityOrdered': %editc(tvdqo3:'P'));
          LineAdd('normalQuantityInvoiced': %editc(tvdqp1:'P'));
          LineAdd('breakDown1QuantityInvoiced': %editc(tvdqp2:'P'));
          LineAdd('breakDown2QuantityInvoiced': %editc(tvdqp3:'P'));
          LineAdd('originalItem': tvdoit);
          LineAdd('customerItemNumber': tvdcitm);
          LineAdd('itemDescriptionOverride': tvddsc);
          LineAdd('unitSalesPrice': %editc(tvduprc:'P'));
          LineAdd('extendedSalesPrice': %editc(tvdextprc:'P'));
          LineAdd('unitSalesTax': %editc(tvdutax:'P'));
          LineAdd('extendedSalesTax': %editc(tvdexttax:'P'));
          LineAdd('unitSurchargesFees': %editc(tvdufee:'P'));
          LineAdd('extendedUnitSurchargesFees': %editc(tvdextfee:'P'));
          LineAdd('extendedCatchweight': %editc(tvdextwgt:'P'));
          LineAdd('deliverableItem': tvdlvr);

          LineEnd();

          WriteLine(fd: %addr(line)+2: %len(line));

        return;

      /end-free

     p WriteInvItem    e

740fA*----------------------------------------------------------------
740fA*  WriteInvItems   Write invoice items element
740fA*----------------------------------------------------------------

740fAp WriteInvItems   b
740fAd WriteInvItems   pi

      /free

        //  Write begin tag for Invoice Items

        line = '<InvoiceItems>';
        WriteLine(fd: %addr(line)+2: %len(line));

        // Loop through gRoutes

        for i = 1 to gRoutesCount;

          %occur(gRoutes) = i;

          // Loop through invoice detail records

          setll ($pwhse: gRoutes.rtid) ttivcd;

          dou forever <> forever;

            reade ($pwhse: gRoutes.rtid) ttivcd;
            if %eof(ttivcd);
              leave;
            endif;

            WriteInvItem();

          enddo;

        endfor;

        //  Write end tag for Invoice Items

        line = '</InvoiceItems>';
        WriteLine(fd: %addr(line)+2: %len(line));

        return;

      /end-free

     p WriteInvItems   e

740fA*----------------------------------------------------------------
740fA*  WriteInvCW   Write invoice catchweight element
740fA*----------------------------------------------------------------

740fAp WriteInvCW      b
740fAd WriteInvCW      pi

     * Local Variables

     d  hostStop       s              5  0

      /free

          // Get Dakota and Host Stop numbers

          chain (tvcwhs: tvcordid) ordh;
          if not %found(ordh);
            clear ohrec;
          endif;

          GetStop('*PLTSTP': tvcwhs: ohrte: 0: ohstop: hostStop);
          if hostStop <= 0;
            hostStop = ohstop;
          endif;

          LineStart('InvoiceCWItem');

          LineAdd('traxRouteGroupID': %editc(gGroupId: 'X'));
          LineAdd('parentRouteID': gParentId);
          LineAdd('routeID': ohrte);
          LineAdd('stopNumber': %editc(hostStop:'P'));
          LineAdd('stopId': %editc(ohstop:'P'));
          LineAdd('invoiceNumber': tvcinvoice);
          LineAdd('orderSequenceNumber': %editc(tvcosq:'P'));
          LineAdd('itemNumber': tvcitm);
          LineAdd('itemCatchweightSequenceNumber': %editc(tvcseq:'P'));
          LineAdd('itemCatchweight': %editc(tvcwgt:'P'));

          LineEnd();

          WriteLine(fd: %addr(line)+2: %len(line));

        return;

      /end-free

     p WriteInvCW      e

740fA*----------------------------------------------------------------
740fA*  WriteInvCWs   Write invoice catchweights element
740fA*----------------------------------------------------------------

740fAp WriteInvCWs     b
740fAd WriteInvCWs     pi

      /free

        //  Write begin tag for Invoice Catchweights

        line = '<InvoiceCatchweights>';
        WriteLine(fd: %addr(line)+2: %len(line));

        // Loop through gRoutes

        for i = 1 to gRoutesCount;

          %occur(gRoutes) = i;

          // Loop through invoice catchweight records

          setll ($pwhse: gRoutes.rtid) ttivcc;

          dou forever <> forever;

            reade ($pwhse: gRoutes.rtid) ttivcc;
            if %eof(ttivcc);
              leave;
            endif;

            WriteInvCW();

          enddo;

        endfor;

        //  Write end tag for Invoice Catchweights

        line = '</InvoiceCatchweights>';
        WriteLine(fd: %addr(line)+2: %len(line));

        return;

      /end-free

     p WriteInvCWs     e

     *----------------------------------------------------------------
     *  WriteItem  Write itemtelement
     *----------------------------------------------------------------

     p WriteItem       b
     d WriteItem       pi

     * Local Variables

710dAd  hostStop       s              5  0

      /free

       hld_rtidplt = %subst(gRoutes.rtid: 2: 4) + %trim(%editc(hld_plid:'P'));

       //  Set boolean value for bulk.

       //if lwtype = 'M' and lwwhdp = '*BULK';
       if ordp_pcs > 1;
         bulk = '1';
       else;
         bulk = '0';
       endif;

       //  Set canbreakdown1 & 2 values.

       if $itumq2 > 0;
         canbrk1 = 'Y';
       else;
         canbrk1 = 'N';
       endif;

       if $itumq3 > 0;
         canbrk2 = 'Y';
       else;
         canbrk2 = 'N';
       endif;

       //  Get breakdown flag value.

       brkDwnFlg = '0';
       chain ($pwhse: orpord: orpsq#) ordd;
       if %found(ordd);
         select;
           when odqor2 > 0;
             brkDwnFlg = '1';
           when odqor3 > 0;
             brkDwnFlg = '2';
         endsl;
       endif;

       //  Get catchweight range

       GetCWRange();

       //  Set GS1 item level flags
       //  Set flags to N if not batch pick item

       gs1item = 'N';
       gs1uniq = 'N';
       getZoneOpts();
       if opptyp = 'B';
         if $ifucicde = '2' or $ifucicde = '3';
           gs1item = 'Y';
         endif;
         if $ifucicde = '2';
           gs1uniq = 'Y';
         endif;
       endif;

710dA  // Get Host Stop number
710dA
710dA  GetStop('*PLTSTP': lwwhse: lwrte: 0: lwstop: hostStop);
710dA  if hostStop <= 0;
710dA    hostStop = lwstop;
710dA  endif;

730dD    //hostStop = lwstop;

730cA    exWhse = $pwhse;
730cA    hld_ohcorda = *blanks;
730cA    hld_ohcorda = %char(ohcord);
730gD    // exordh ('*GET': exRtnCode: exRtnMsg: exWhse: orpord:
730gM    exordh ('*GET': exRtnCode: exRtnMsg: exWhse: ohord:
                 ohaaudflg: ohaaudid: ohaaudcmp: ohaaudby: ohaaudts:
                 ohaorda: ohacusta);

730cA    if exRtnCode = '*OK';
730cA      if ohaorda <> *blanks;
730cA        hld_ohcorda = ohaorda;
730cA      endif;
730cA    endif;


       // Write Item line

       LineStart('Item');

       LineAdd('traxRouteGroupID': %editc(gGroupId: 'X'));
       LineAdd('parentRouteID': gParentId);
710aA  LineAdd('routeID': lwrte);
720gD  //LineAdd('scanID': $prtid +  %trim(%editc(orpup#:'X')));
720gM  LineAdd('scanID': orprid +  %trim(%editc(orpup#:'X')));
       LineAdd('palletScanID': hld_rtidplt);
710dD  //LineAdd('palletNumber': %editc(hld_plid:'P'));
710dM  LineAdd('palletNumber': %editc(pspal#:'P'));
710dA  LineAdd('palletId': %editc(hld_plid:'P'));
710dM  LineAdd('stopNumber': %editc(hostStop:'P'));
710dA  LineAdd('stopId': %editc(lwstop:'P'));
       LineAdd('bulk': bulk);
       LineAdd('toteFlag': gToteFlag);
       LineAdd('toteId': %editc(gToteId:'P'));
       LineAdd('toteNumber': %editc(gToteNum:'P'));
       LineAdd('itemNumber': lwitem);
       LineAdd('unloadSequence': %editc(psunld:'P'));
       LineAdd('cube': %editc(ordp_cub:'P'));
       LineAdd('weight': %editc(ordp_wgt:'P'));
       LineAdd('pieces': %editc(ordp_pcs:'P'));
ISYaA  if client = isupply;
ISYaA  // insert number to sequence compartments per I Supply;
ISYaA    select;
ISYaA      when lwcomp = 'F';
ISYaA        LineAdd('compartment': '1F');
ISYaA      when lwcomp = 'R';
ISYaA        LineAdd('compartment': '2R');
ISYaA      when lwcomp = 'D';
ISYaA        LineAdd('compartment': '3D');
ISYaA      other;
ISYaA        LineAdd('dept': '4' + %trim(lwcomp));
ISYaA    endsl;
ISYaA  else;
       LineAdd('compartment': lwcomp);
ISYaA  endif;
       LineAdd('zone': lwtzon);
       LineAdd('dept': lwwhdp);
       LineAdd('type': lwstyp);
       LineAdd('description': $itdesc);
       LineAdd('uccCode': $itupc);
       LineAdd('unitMeasure': lwucod);
       LineAdd('internalOrderNumber': %editc(ohord:'P'));
740fA  LineAdd('orderSequenceNumber': %editc(odseq:'P'));
730cD  //LineAdd('customerOrderNumber': %editc(ohcord:'P'));
730cM  LineAdd('customerOrderNumber': hld_ohcorda);
       LineAdd('breakDown1UM': $itum2);
740dA  if lwucod = $itum2;
740dA    LineAdd('breakDown1Quantity': %editc(defaultBrkQty:'P'));
740dA  else;
         LineAdd('breakDown1Quantity': %editc($itumq2:'P'));
740dA  endif;
       LineAdd('breakDown2UM': $itum3);
740dA  if lwucod = $itum3;
740dA    LineAdd('breakDown2Quantity': %editc(defaultBrkQty:'P'));
740dA  else;
         LineAdd('breakDown2Quantity': %editc($itumq3:'P'));
740dA  endif;
       LineAdd('catchweightFlag': $itcwgt);
       LineAdd('catchWeightMin': %editc(ilrng:'P'));
       LineAdd('catchWeightMax': %editc(ihrng:'P'));
       LineAdd('catchWeight': %editc($itswgt:'P'));
       LineAdd('actualCatchWeight': %editc(orpwgt:'P'));
       LineAdd('canBreakDown1': canbrk1);
       LineAdd('canBreakDown2': canbrk2);
       //LineAdd('breakDownFlag': brkDwnFlg);
       LineAdd('gs1Item': gs1item);
       LineAdd('gs1Unique': gs1uniq);
       LineAdd('designationCode': $itdesg);

       if gs1item = 'Y';
         WriteGTIN();
       endif;

       LineEnd();

       WriteLine(fd: %addr(line)+2: %len(line));

       return;

      /end-free

     p WriteItem       e

     *----------------------------------------------------------------
     *  WriteItems   Write items element
     *----------------------------------------------------------------

     p WriteItems      b
     d WriteItems      pi

     * Local Variables

     d  i              s              3  0
     d  lastOrd        s                   like(lword)

      /free

       lastOrd = -1;
       gToteFlag = '0';
       gToteNum = 0;
       gToteId = 0;

       //  Write begin tag for Items

       line = '<Items>';
       WriteLine(fd: %addr(line)+2: %len(line));

       // Loop through gRoutes

       for i = 1 to gRoutesCount;

         %occur(gRoutes) = i;

        // Loop through items

        //  Loop through and write Item records (non-tote)

        setll ($pwhse: gRoutes.rtid) ordp4;

        dou forever <> forever;

          reade ($pwhse: gRoutes.rtid) ordp4;

          if %eof(ordp4);
            leave;
          endif;

          if orpsq# = 0;
            iter;
          endif;

          if orpscn = 0;
            iter;
          endif;

          chain orplbl worklbl;
          if not %found(worklbl);
            iter;
          endif;

          chain lwtrn# totehdr1;
          if %found(totehdr1);
            iter;
          endif;

          //  Calc cube, wgt, & pcs for this unique piece# (aka scanID)

          ordp_cub = lwucub * orpscn;
          ordp_wgt = lwuwgt * orpscn;
          ordp_pcs = orpscn;

          //  Get PIRITEM data for this item

          GetItem();

          //  Get ORDH info when order changes

          if lword <> lastOrd;
            lastOrd = lword;
            chain (lwwhse: lword) ordh;
            if not %found(ordh);
              clear ohrec;
              ohord = -(lword);
              ohcord = -(lwwhse);
            endif;
          endif;

          //  Get PLTSUM12 unload sequence for this item ...
          //  If it's a gen 2 or higher rec, will have to go get the unload
          //  sequence for its merge record

          clear psrec;
          select;
          when lwgen < 2;
            hld_trn  = lwtrn#;
            hld_plid = lwpal#;
            chain (lwwhse: lwrte: lwtrn#: lwpal#) pltsum12;

          other;
            chain (lwwhse: lwrte: lwlbl#) worklbl7;
            if %found(worklbl7);
              hld_trn  = lb7_lwtrn#;
              hld_plid = lb7_lwpal#;
              chain (lb7_lwwhse: lb7_lwrte: lb7_lwtrn#: lb7_lwpal#) pltsum12;
            endif;
          endsl;

          //  Write record

          WriteItem();

        enddo;

        endfor;

        WriteTotes();

         //  Write end tag for Routes

        line = '</Items>';
        WriteLine(fd: %addr(line)+2: %len(line));

        return;

      /end-free

     p WriteItems      e

720dA*----------------------------------------------------------------
720dA*  WriteQuestion   Write Question element
720dA*----------------------------------------------------------------

720dAp WriteQuestion   b
720dAd WriteQuestion   pi
720dAd  timing                        1    const
720dAd  nextquestion               1000    const varying
720hAd  stoptype                      3    const varying

720dA* Local Variables

720dAd  hostStop       s              5  0
720dAd  saveStop       s              5  0

720dA /free

720hA   // if stop question types ST1 or ST2 need to loop thru ordh9
720hA   select;
720hA     when stoptype = 'ST1';
720hA       savestop = 0;
720hA       setll ($pwhse: gRoutes.rtid) ordh9;
720hA       dou forever <> forever;
720hA         reade ($pwhse: gRoutes.rtid) ordh9;
720hA         if %eof(ordh9);
720hA           leave;
720hA         endif;
720hA         if savestop = oh9_ohstop;
720hA           iter;
720hA         endif;
720hA         savestop = oh9_ohstop;
720hA         if timing = '2'  or timing = '3' or timing = '4';
720hA           // Get Host Stop number
720hA
720hA           GetStop('*PLTSTP': oh9_ohwhse: gRoutes.rtid: 0:
720hA                    oh9_ohstop: hostStop);
720hA           if hostStop <= 0;
720hA             hostStop = oh9_ohstop;
720hA           endif;
730dD           //hostStop = oh9_ohstop;
720hA         endif;

720hA         LineStart('Question');

720hA         LineAdd('traxRouteGroupID': %editc(gGroupId: 'X'));
720hA         LineAdd('parentRouteID': gParentId);
720hA         LineAdd('routeID': gParentId);
720hA         LineAdd('stopNumber': %editc(hostStop:'P'));
720hA         LineAdd('questionDisplayTime': timing);
720hA         PCMAdd(nextquestion);

720hA         LineEnd();

720hA         WriteLine(fd: %addr(line)+2: %len(line));
720hA       enddo;

720hA     when stoptype = 'ST2';
720hA       savestop = 0;
720hA       setll ($pwhse: gRoutes.rtid) ordh9;
720hA       dou forever <> forever;
720hA         reade ($pwhse: gRoutes.rtid) ordh9;
720hA         if %eof(ordh9);
720hA           leave;
720hA         endif;
720hA         if savestop = oh9_ohstop;
720hA           iter;
720hA         endif;
720hA         savestop = oh9_ohstop;
720hA         if timing = '2'  or timing = '3' or timing = '4';
720hA           // Get Host Stop number
720hA
720hA           GetStop('*PLTSTP': oh9_ohwhse: gRoutes.rtid: 0:
720hA                    oh9_ohstop: hostStop);
720hA           if hostStop <= 0;
720hA             hostStop = oh9_ohstop;
720hA           endif;
730dD           //hostStop = oh9_ohstop;
720hA         endif;

720hA         LineStart('Question');

720hA         LineAdd('traxRouteGroupID': %editc(gGroupId: 'X'));
720hA         LineAdd('parentRouteID': gParentId);
720hA         LineAdd('routeID': gParentId);
720hA         LineAdd('stopNumber': %editc(hostStop:'P'));
720hA         LineAdd('questionDisplayTime': timing);
720hA         PCMAdd(nextquestion);

720hA         LineEnd();

720hA         WriteLine(fd: %addr(line)+2: %len(line));
720hA       enddo;
750aA     when stoptype = 'CS1' or stoptype = 'CS2';
750aA       if timing = '2'  or timing = '3' or timing = '4';
750aA         // Get Host Stop number
750aA         GetStop('*PLTSTP': oh9_ohwhse: gRoutes.rtid: 0:
750aA                  oh9_ohstop: hostStop);
750aA         if hostStop <= 0;
750aA           hostStop = oh9_ohstop;
750aA         endif;
750aA       endif;

750aA       LineStart('Question');

750aA       LineAdd('traxRouteGroupID': %editc(gGroupId: 'X'));
750aA       LineAdd('parentRouteID': gParentId);
750aA       LineAdd('routeID': gParentId);
750aA       LineAdd('stopNumber': %editc(hostStop:'P'));
750aA       LineAdd('questionDisplayTime': timing);
750aA       PCMAdd(nextquestion);

750aA       LineEnd();

750aA       WriteLine(fd: %addr(line)+2: %len(line));
720hA     other;
720dA       if timing = '2'  or timing = '3' or timing = '4';
720dA         // Get Host Stop number
720dA
720dA         GetStop('*PLTSTP': lwwhse: lwrte: 0: lwstop: hostStop);
720dA         if hostStop <= 0;
720dA           hostStop = lwstop;
720dA         endif;
730dD         //hostStop = lwstop;
720dA       endif;

720dA       LineStart('Question');

720dA       LineAdd('traxRouteGroupID': %editc(gGroupId: 'X'));
720dA       LineAdd('parentRouteID': gParentId);
720dA       LineAdd('routeID': gParentId);
720dA       LineAdd('stopNumber': %editc(hostStop:'P'));
720dA       LineAdd('questionDisplayTime': timing);
720dA       PCMAdd(nextquestion);

720dA       LineEnd();

720dA       WriteLine(fd: %addr(line)+2: %len(line));

720hA   endsl;
720dA   return;

720dA /end-free

720dAp WriteQuestion   e

     *----------------------------------------------------------------
     *  WriteQuestions    Write Questions Element
     *----------------------------------------------------------------

     p WriteQuestions  b
     d WriteQuestions  pi

720dA* Local Variables

720dAd  pcallnum       s              1  0
720dAd  pCmd           s              8    varying
720dAd  pWhse          s              3  0
720dAd  pLevel         s              4    varying
720dAd  pType          s              3    varying
720dAd  pUser          s             10    varying
720dAd  pxml           s          20000    varying
730iAd  pcust          s             15    varying
720dAd  ppgm           s             20
720dAd  ptiming        s              1
720dAd count           s              5p 0
720dAd i               s              5p 0
720dAd qGroupPos       s              5p 0
720dAd begpos          s              5p 0
720dAd begpos1         s              5p 0
720dAd endpos          s              5p 0
720dAd endxml          s              5p 0
720dAd questionlen     s              5p 0
730jAd  hostStop       s              5  0
730jAd  saveStop       s              5  0
      /free

        //  Write begin tag for Questions

        line = '<Questions>';
        WriteLine(fd: %addr(line)+2: %len(line));

720dA   for count = 1 to 10 by 1;
730iA     pcust = ' ';
720dA     // Get begin Route questions
720dA     Select;
720dA       when count = 1;
720dA         pcmd = 'ROUTE';
720dA         plevel = 'TRAX';
720dA         ptype = 'DV1';
720dA         ptiming = '1';
720dA       when count = 2;
720dA         pcmd = 'ROUTE';
720dA         plevel = 'TRAX';
720dA         ptype = 'DV2';
720dA         ptiming = '5';
720dA       when count = 3;
720dA         pcmd = 'STOP';
720dA         plevel = 'TRAX';
720dA         ptype = 'ST1';
720dA         ptiming = '2';
720dA       when count = 4;
720dA         pcmd = 'STOP';
720dA         plevel = 'TRAX';
720dA         ptype = 'ST2';
720dA         ptiming = '3';
720dA       when count = 5;
720dA         pcmd = 'STOP';
720dA         plevel = 'TRAX';
720dA         ptype = 'CS1';
720dA         ptiming = '2';
730jD         //pcust = gStops.custNumber;
730jM         pcust = ' ';
720dA       when count = 6;
720dA         pcmd = 'STOP';
720dA         plevel = 'TRAX';
720dA         ptype = 'CS2';
720dA         ptiming = '3';
730jD         //pcust = gStops.custNumber;
730jM         pcust = ' ';
720dA       when count = 7;
720dA         pcmd = 'ROUTE';
720dA         plevel = 'TRAX';
720dA         ptype = 'DT1';
720dA         ptiming = '1';
720dA       when count = 8;
720dA         pcmd = 'ROUTE';
720dA         plevel = 'TRAX';
720dA         ptype = 'DT2';
720dA         ptiming = '5';
720dA       when count = 9;
720dA         pcmd = 'ROUTE';
720dA         plevel = 'TRAX';
720dA         ptype = 'RT1';
720dA         ptiming = '1';
720dA       when count = 10;
720dA         pcmd = 'ROUTE';
720dA         plevel = 'TRAX';
720dA         ptype = 'RT2';
720dA         ptiming = '5';
720dA     endsl;
720dA     pcallNum = 0;
720dA     puser = #user;
720dA     ppgm = #pgm;
720dA     pxml  = ' ';
720dA     pcmgetqtr(pcallNum: puser: ppgm: pcmd:
730iD               //$pwhse: plevel: ptype: pxml);
730iM               $pwhse: plevel: ptype: pxml: pcust);

720dA     // Loop through questions
720dA     if %len(pxml) = 0;
720dA     else;
720dA       i = 1;
720dA       dow forever = forever;
720dA         // Get next question

720dA         qGroupPos = %scan('questionGroup': pxml: i);
720dA         if qGroupPos = 0 and i = 1;
720dA           leave;
720dA         endif;
720dA         // find the begining of the next question
720dA         begpos = qGrouppos;
720dA         begpos1 = qGrouppos + 1;
720dA         endpos = %scan('questionGroup': pxml: begpos1);
720dA         // last question
720dA         if endpos = 0;
720dA           endxml =  %len(pxml);
720dA           questionLen = endxml - begpos;
720dA         else;
720dA           questionLen = endpos - begpos;
720dA         endif;

720dA         question = %subst(pxml: begpos: questionLen);
720hD         //WriteQuestion(ptiming: question);
720hM         WriteQuestion(ptiming: question: ptype);

720dA         if endpos = 0;
720dA           leave;
720dA         else;
720dA           i = endpos;
720dA         endif;
720dA       enddo;
720dA     endif;
720dA   endfor;

730jA   // lets process all stops to get customer questions
730jA
730jA   savestop = 0;
730jA   setll ($pwhse: gRoutes.rtid) ordh9;
730jA   dou forever <> forever;
730jA     reade ($pwhse: gRoutes.rtid) ordh9;
730jA     if %eof(ordh9);
730jA       leave;
730jA     endif;
730jA     if savestop = oh9_ohstop;
730jA       iter;
730jA     endif;
730jA     savestop = oh9_ohstop;
730jA     // Get Host Stop number
730jA
730jA     GetStop('*PLTSTP': oh9_ohwhse: gRoutes.rtid: 0:
730jA              oh9_ohstop: hostStop);
730jA     if hostStop <= 0;
730jA       hostStop = oh9_ohstop;
730jA     endif;
730jA     // Get Customer if in ordhexa
730jA     exWhse = $pwhse;
730jA     pcust = *blanks;
730jA     pcust = %char(oh9_ohcust);
730jA     exordh ('*GET': exRtnCode: exRtnMsg: exWhse: orpord:
730jA            ohaaudflg: ohaaudid: ohaaudcmp: ohaaudby: ohaaudts:
730jA            ohaorda: ohacusta);

730jA     if exRtnCode = '*OK';
730jA       if ohacusta <> *blanks;
730jA         pcust = ohacusta;
730jA       endif;
730jA     endif;

730jA     pcmd = 'STOP';
730jA     plevel = 'TRAX';
730jA     ptype = 'CS1';
730jA     ptiming = '2';

730jA     pcallNum = 0;
730jA     puser = #user;
730jA     ppgm = #pgm;
730jA     pxml  = ' ';
730jA     pcmgetqtr(pcallNum: puser: ppgm: pcmd:
730jA               //$pwhse: plevel: ptype: pxml);
730jA               $pwhse: plevel: ptype: pxml: pcust);

730jA     // Loop through questions
730jA     if %len(pxml) = 0;
730jA     else;
730jA       i = 1;
730jA       dow forever = forever;
730jA         // Get next question

730jA         qGroupPos = %scan('questionGroup': pxml: i);
730jA         if qGroupPos = 0 and i = 1;
730jA           leave;
730jA         endif;
730jA         // find the begining of the next question
730jA         begpos = qGrouppos;
730jA         begpos1 = qGrouppos + 1;
730jA         endpos = %scan('questionGroup': pxml: begpos1);
730jA         // last question
730jA         if endpos = 0;
730jA           endxml =  %len(pxml);
730jA           questionLen = endxml - begpos;
730jA         else;
730jA           questionLen = endpos - begpos;
730jA         endif;

730jA         question = %subst(pxml: begpos: questionLen);
730jA         //WriteQuestion(ptiming: question);
730jA         WriteQuestion(ptiming: question: ptype);

730jA         if endpos = 0;
730jA           leave;
730jA         else;
730jA           i = endpos;
730jA         endif;
730jA       enddo;
730jA     endif;
730jA
730jA     pcmd = 'STOP';
730jA     plevel = 'TRAX';
730jA     ptype = 'CS2';
730jA     ptiming = '3';

730jA     pcallNum = 0;
730jA     puser = #user;
730jA     ppgm = #pgm;
730jA     pxml  = ' ';
730jA     pcmgetqtr(pcallNum: puser: ppgm: pcmd:
730jA               //$pwhse: plevel: ptype: pxml);
730jA               $pwhse: plevel: ptype: pxml: pcust);

730jA     // Loop through questions
730jA     if %len(pxml) = 0;
730jA     else;
730jA       i = 1;
730jA       dow forever = forever;
730jA         // Get next question

730jA         qGroupPos = %scan('questionGroup': pxml: i);
730jA         if qGroupPos = 0 and i = 1;
730jA           leave;
730jA         endif;
730jA         // find the begining of the next question
730jA         begpos = qGrouppos;
730jA         begpos1 = qGrouppos + 1;
730jA         endpos = %scan('questionGroup': pxml: begpos1);
730jA         // last question
730jA         if endpos = 0;
730jA           endxml =  %len(pxml);
730jA           questionLen = endxml - begpos;
730jA         else;
730jA           questionLen = endpos - begpos;
730jA         endif;

730jA         question = %subst(pxml: begpos: questionLen);
730jA         //WriteQuestion(ptiming: question);
730jA         WriteQuestion(ptiming: question: ptype);

730jA         if endpos = 0;
730jA           leave;
730jA         else;
730jA           i = endpos;
730jA         endif;
730jA       enddo;
730jA     endif;
730jA   enddo;

730jA   // end process for all stops to get customer questions

        //  Write end tag for Questions

        line = '</Questions>';
        WriteLine(fd: %addr(line)+2: %len(line));

        return;

      /end-free

     p WriteQuestions  e

     *----------------------------------------------------------------
     *  WriteReasonCodes  Write reason codes element
     *----------------------------------------------------------------

     p WriteReasonCodes...
     p                 b
     d WriteReasonCodes...
     d                 pi

      /free

        //  Write begin tag for ReasonCodes

        line = '<ReasonCodes>';
        WriteLine(fd: %addr(line)+2: %len(line));

        //  Write end tag for ReasonCodes

        line = '</ReasonCodes>';
        WriteLine(fd: %addr(line)+2: %len(line));

        return;

      /end-free

     p WriteReasonCodes...
     p                 e

     *----------------------------------------------------------------
     *  WriteReturnCodes  Write return codes element
     *----------------------------------------------------------------

     p WriteReturnCodes...
     p                 b
     d WriteReturnCodes...
     d                 pi


      /free

        //  Write begin tag for ReturnCodes

        line = '<ReturnCodes>';
        WriteLine(fd: %addr(line)+2: %len(line));

        //  Loop through and write ReturnCode records

        setll *loval rtncode;

        dou forever <> forever;

          read rtncode;
          if %eof(rtncode);
            leave;
          endif;

          LineStart('ReturnCode');
          LineAdd('code': rncode);
          LineAdd('description': rndesc);
          LineEnd();

          WriteLine(fd: %addr(line)+2: %len(line));

        enddo;

        //  Write end tag for ReturnCodes

        line = '</ReturnCodes>';
        WriteLine(fd: %addr(line)+2: %len(line));

        return;

      /end-free

     p WriteReturnCodes...
     p                 e

     *----------------------------------------------------------------
     *  WriteRoute   Write route element
     *----------------------------------------------------------------

     p WriteRoute      b
     d WriteRoute      pi

      /free

          LineStart('Route');

          LineAdd('traxRouteGroupID': %editc(gGroupId: 'X'));
          LineAdd('parentRouteID': gParentId);
          LineAdd('routeID': gRoutes.rtid);
          LineAdd('driverID': $pemp);
          LineAdd('truckID': gRoutes.truckid);
          LineAdd('licensePlate': gRoutes.license);
          LineAdd('routeName': gRoutes.rte);
          LineAdd('warehouseCode': %editc($pwhse:'X'));

          LineEnd();

          WriteLine(fd: %addr(line)+2: %len(line));

        return;

      /end-free

     p WriteRoute      e

     *----------------------------------------------------------------
     *  WriteRoutes  Write route element
     *----------------------------------------------------------------

     p WriteRoutes     b
     d WriteRoutes     pi

     * Local Variables

     d  i              s              3  0

      /free

       // Put route(s) into gRoutes data structure

       // First, the main/parent route

720fA  rhrtid = ' ';
       chain ($pwhse: gParentId) rtehed;
       if not %found(rtehed);
         $perm = 'Route not found (' + %trim(gParentId) + ')';
         $prtn = '*CANCEL';
720fA    if debug;
720fA      bdtype='ParNotFnd';
720fA      wrtDebug();
720fA    endif;
         return;
       endif;

720aA  // Check if all corresponding merged routes have been exported.
720aA
720aA  if hasChildren  and rhstat < '6';
720aA    $perm = 'All merged routes not exported, parent id +
720aA            (' + %trim(gParentId) + ')';
720aA    $prtn = '*CANCEL';
720fA    if debug;
720fA      bdtype='AllNotExpP';
720fA      wrtDebug();
720fA    endif;
720aA    return;
720aA  endif;

       gRoutesCount += 1;
       %occur(gRoutes) = gRoutesCount;
       gRoutes.rtid = rhrtid;
       gRoutes.rte = rhrte;
       gRoutes.truckid = rhtruk;
       gRoutes.license = '';

       // Next, the children (if any)

       setll ($pwhse: gParentId) ttmerg;
       dow forever = forever;
         reade ($pwhse: gParentId) ttmerg;
         if %eof(ttmerg);
           leave;
         endif;
720fA    rhrtid = ' ';
         chain ($pwhse: ttmcri) rtehed;
         if not %found(rtehed);
           $perm = 'Route not found (' + %trim(ttmcri) + ')';
           $prtn = '*CANCEL';
720fA    if debug;
720fA      bdtype='ChiNotFnd';
720fA      wrtDebug();
720fA    endif;
           return;
         endif;

720aA  // Check if all corresponding merged routes have been exported.
720aA
720aA    if hasChildren and rhstat < '6';
720aA      $perm = 'All merged routes not exported, parent id +
720aA              (' + %trim(gParentId) + ')';
720aA      $prtn = '*CANCEL';
720fA    if debug;
720fA      bdtype='AllNotExpC';
720fA      wrtDebug();
720fA    endif;
720aA      return;
720aA    endif;

         gRoutesCount += 1;
         %occur(gRoutes) = gRoutesCount;
         gRoutes.rtid = rhrtid;
         gRoutes.rte = rhrte;
         gRoutes.truckid = rhtruk;
         gRoutes.license = '';

       enddo;

        //  Write begin tag for Routes

        line = '<Routes count="' + %char(gRoutesCount) + '">';
        WriteLine(fd: %addr(line)+2: %len(line));

        // Loop through gRoutes
        for i = 1 to gRoutesCount;
          %occur(gRoutes) = i;
          WriteRoute();
        endfor;

        //  Write end tag for Routes

        line = '</Routes>';
        WriteLine(fd: %addr(line)+2: %len(line));

        return;

      /end-free

     p WriteRoutes     e

     *----------------------------------------------------------------
     *  WriteStop   Write stop element
     *----------------------------------------------------------------

     p WriteStop       b
     d WriteStop       pi

      /free

          LineStart('Stop');

          LineAdd('traxRouteGroupID': %editc(gGroupId: 'X'));
          LineAdd('parentRouteID': gParentId);
710aA     LineAdd('routeID': gParentId);
710dM     LineAdd('stopNumber': %editc(gStops.hostStop:'P'));
710dA     LineAdd('stopId': %editc(gStops.stopId:'P'));
          LineAdd('cube': %editc(gStops.cube:'P'));
          LineAdd('weight': %editc(gStops.wgt:'P'));
          LineAdd('pieces': %editc(gStops.pcs:'P'));
720bD    // LineAdd('customerNumber': %editc(gStops.custNumber:'P'));
720bM     LineAdd('customerNumber': gStops.custNumber);
          LineAdd('customerName': gStops.custName);
          LineAdd('companyName': gStops.companyName);
          LineAdd('addressLine1': gStops.custAdr1);
          LineAdd('addressLine2': gStops.custAdr2);
          LineAdd('city': gStops.custCity);
          LineAdd('state': gStops.custState);
          LineAdd('zipCode': gStops.custZip);
          LineAdd('contactName': '');
          LineAdd('contactLastName': '');
          LineAdd('phone': '');
          LineAdd('emailTo': '');
          LineAdd('emailCC': '');

          LineEnd();

          WriteLine(fd: %addr(line)+2: %len(line));

        return;

      /end-free

     p WriteStop       e

     *----------------------------------------------------------------
     *  WriteStops    Write Stops
     *----------------------------------------------------------------

     p WriteStops      b
     d WriteStops      pi

     * Local Variables

     d  i              s              3  0
     d  j              s              3  0
     d  foundStop      s               n
     d  lastStop       s                   like(lwstop)
     d  hostStop       s              5  0

      /free

       gStopsCount = 0;
       clear gStops;

       // Loop through gRoutes

       for i = 1 to gRoutesCount;

         %occur(gRoutes) = i;

         // Loop through stops for route

         lastStop = -1;
         setll ($pwhse: gRoutes.rtid) worklbfi;

         dow forever = forever;

           reade ($pwhse: gRoutes.rtid) worklbfi;
           if %eof(worklbfi);
             leave;
           endif;

           // Get gStops record

           if lastStop <> lwstop;

720iA        if gstops.pcs = 0 and laststop <> -1;
720iA          gStops.hostStop = 0;
720iA          gStops.stopid = 0;
720iA          gStops.pcs = 0;
720iA          gStops.wgt = 0;
720iA          gStops.cube = 0;
720iA          gStops.custNumber = *blanks;
720iA          gStops.custName = *blanks;
720iA          gStops.companyName = *blanks;
720iA          gStops.custAdr1 = *blanks;
720iA          gStops.custAdr2 = *blanks;
720iA          gStops.custCity = *blanks;
720iA          gStops.custState = *blanks;
720iA          gStops.custZip = *blanks;
720iA          gStopsCount -= 1;
720iA          j -= 1;
720iA        endif;

             lastStop = lwstop;
             foundStop = *off;

             for j = 1 to gStopsCount;

               %occur(gStops) = j;
710dD          //if gStops.stop = lwstop;
710dM          if gStops.stopId = lwstop;
                 foundStop = *on;
                 leave;
               endif;

             endfor;

             if not foundStop;
               gStopsCount += 1;
               chain (lwwhse: lword) ordh;
               if not %found(ordh);
                 clear ohrec;
               endif;
               %occur(gStops) = gStopsCount;
710dA          gStops.stopId = lwstop;
710dA          GetStop('*PLTSTP': lwwhse: lwrte: 0: lwstop: hostStop);
710dA          if hostStop > 0;
710dA            gStops.hostStop = hostStop;
710dA          else;
                 gStops.hostStop = lwstop;
710dA          endif;
730dD          //gStops.hostStop = lwstop;
               gStops.pcs = 0;
               gStops.wgt = 0;
               gStops.cube = 0;
720cA          gStops.custNumber = *blanks;
730eD          //if ohcust > 0;
730eD            //gStops.custNumber = %TrimL(%editc(ohcust:'X'));
730eD          //else;
730eD            //if ohmisc <> *blanks;
730eD              //sqlStmt = 'select opccus from optionc,ordh ' +
730eD                        //'where opcwhs = ' + %char(lwwhse) + ' and ' +
730eD                        //'opcwhs = ohwhse and ' +
730eD                        //'ohord = ' + %char(lword) + ' and ' +
730eD                        //'trim(ohmisc) like ' + sq + pc + sq + ' concat ' +
730eD                        //'trim(opccus) concat ' + sq + pc + sq;

730eD              //exec sql PREPARE cus FROM :SqlStmt;
730eD              //exec sql DECLARE cusrec SCROLL CURSOR FOR cus;
730eD              //exec sql OPEN cusrec;

730eD              //exec sql fetch first from cusrec into :cusdta;

730eD              //dow sqlStt='00000';
730eD                //gStops.custNumber = CusDta.cusnum;
730eD                //leave;
730eD              //enddo;
730eD            //exec sql close cusrec;
730eD            //endif;
730eD          //endif;      // only do sequel to optionc when ohmisc not blanks


730eA    exWhse = $pwhse;
730eA    gStops.custNumber = *blanks;
730eA    //gStops.custNumber = %char(ohcust);       **740aD**
740aM    gStops.custNumber = %editc(ohcust:'X');
730gD    //exordh ('*GET': exRtnCode: exRtnMsg: exWhse: orpord:
730gM    exordh ('*GET': exRtnCode: exRtnMsg: exWhse: ohord:
                 ohaaudflg: ohaaudid: ohaaudcmp: ohaaudby: ohaaudts:
                 ohaorda: ohacusta);

730eA    if exRtnCode = '*OK';
730eA      if ohacusta <> *blanks;
730eA        gStops.custNumber = ohacusta;
730eA      endif;
730eA    endif;

               gStops.custName = ohcnam;
               gStops.companyName = ohcnam;
               gStops.custAdr1 = ohcad1;
               gStops.custAdr2 = ohcad2;
               gStops.custCity = ohccty;
               gStops.custState = ohcst;
               gStops.custZip = ohczip;
             endif;
           endif;

           if lwtype <> 'O'  and
              lwtype <> 'B';
             iter;
           endif;

           gStops.pcs += lbqpck;
           gStops.wgt += lbswgt;
           gStops.cube += lbcube;

         enddo;

       endfor;

       //  Write begin tag for Stop

       line = '<Stops count="' + %char(gStopsCount) + '">';
       WriteLine(fd: %addr(line)+2: %len(line));

       // Write Stop records

       for i = 1 to gStopsCount;

         %occur(gStops) = i;
         WriteStop();

       endfor;

       //  Write end tag for Stops

       line = '</Stops>';
       WriteLine(fd: %addr(line)+2: %len(line));

       return;

      /end-free

     p WriteStops      e

     *----------------------------------------------------------------
     *  WriteStopFlag   Write stopflag element
     *----------------------------------------------------------------

     p WriteStopFlag   b
     d WriteStopFlag   pi

     * Local Variables

710dAd  hostStop       s              5  0

      /free

740bM     // Get Dakota and Host Stop numbers
740bA     chain (ttfwhs: ttford) ordh;
740bA     if not %found(ordh);
740bA       clear ohrec;
740bA     endif;
710dA
710dA     //740bD GetStop('*PLTSTP': ttfwhs: ttfrti: 0: ttfstp: hostStop);
740bM     GetStop('*PLTSTP': ttfwhs: ttfrti: 0: ohstop: hostStop);
710dA     if hostStop <= 0;
710dA       //740bD hostStop = ttfstp;
740bM       hostStop = ohstop;
710dA     endif;
730dD     //hostStop = ttfstp;

          LineStart('StopFlag');

          LineAdd('traxRouteGroupID': %editc(gGroupId: 'X'));
          LineAdd('parentRouteID': gParentId);
710aA     LineAdd('routeID': gParentId);
710dM     LineAdd('stopNumber': %editc(hostStop:'P'));
710dA     //740bD LineAdd('stopId': %editc(ttfstp:'P'));
740bM     LineAdd('stopId': %editc(ohstop:'P'));
          //LineAdd('stopFlagType': x);
          LineAdd('stopFlagDisplayTime': ttfdsp);
          LineAdd('stopFlagChar': ttfchr);
          LineAdd('stopFlagAlert': ttfale);
          //LineAdd('stopFlagIconName': x);
740cA     LineAdd('stopFlagSequence': ttfuid);

          LineEnd();

          WriteLine(fd: %addr(line)+2: %len(line));

        return;

      /end-free

     p WriteStopFlag   e

     *----------------------------------------------------------------
     *  WriteStopFlags  Write Stop flags
     *----------------------------------------------------------------

     p WriteStopFlags  b
     d WriteStopFlags  pi

740cA* Local Variables

740cAd  hostStop       s              5  0

      /free

        //  Write begin tag for StopFlags

        line = '<StopFlags>';
        WriteLine(fd: %addr(line)+2: %len(line));

720aA   // Loop through gRoutes
720aA
720aA   for i = 1 to gRoutesCount;
720aA
720aA     %occur(gRoutes) = i;

          // Loop through stop flags

          stpFlgCnt = 0;
720aD     //setll ($pwhse: $prtid) ttstpflg;
720aM     setll ($pwhse: gRoutes.rtid) ttstpflg;

          dou forever <> forever;

720aD       //reade ($pwhse: $prtid) ttstpflg;
720aM       reade ($pwhse: gRoutes.rtid) ttstpflg;
            if %eof(ttstpflg);
              leave;
            endif;

            stpFlgCnt = stpFlgCnt + 1;

            if ttfchr = '';
              ttfchr = '?';
            endif;

            if ttfale = '';
              ttfale = '?';
            endif;

            if ttfdsp = '';
              ttfdsp = '1';
            endif;

740cA       if ttfuid = '';
740cA         ttfuid = '?';
740cA       endif;

            WriteStopFlag();

720aD       //setgt ($pwhse: $prtid: ttfstp: ttfchr) ttstpflg;
720aM       //740bD setgt ($pwhse: gRoutes.rtid: ttfstp: ttfchr) ttstpflg;

          enddo;

          //  Loop through truck stop flags

720aD     //setll ($pwhse: $prtid) ordh9;
720aM     setll ($pwhse: gRoutes.rtid) ordh9;
          dou forever <> forever;
720aD       //reade ($pwhse: $prtid) ordh9;
720aM       reade ($pwhse: gRoutes.rtid) ordh9;
            if %eof(ordh9);
              leave;
            endif;

            // Stop should never be blank, but iter if it is

730aD       //if ohstop = 0;
730aM       if oh9_ohstop = 0;
              iter;
            endif;

740cA     GetStop('*PLTSTP': oh9_ohwhse: oh9_ohrte: 0: oh9_ohstop: hostStop);
740cA     if hostStop <= 0;
740cA       hostStop = oh9_ohstop;
740cA     endif;

            //  Write predefined stop flags by truck for each stop

            setll ($pwhse: rhtruk) tttrkflg;
            dou forever <> forever;
              reade ($pwhse: rhtruk) tttrkflg;
              if %eof(tttrkflg);
                leave;
              endif;

              stpFlgCnt = stpFlgCnt + 1;

              chain ($pwhse: ttkchr) ttflag;
              if not %found(ttflag);
                ttaale = 'Not found';
              endif;

              if ttkchr = '';
                ttkchr = '?';
              endif;

              if ttaale = '';
                ttaale = '?';
              endif;

              if ttkdsp = '';
                ttkdsp = '1';
              endif;

              WriteTruckStopFlag();

              // Move on to the next stop/char

            enddo;

            //  Move on to the next stop.

720aD       //setgt ($pwhse: $prtid: oh9_ohstop) ordh9;
720aM       setgt ($pwhse: gRoutes.rtid: oh9_ohstop) ordh9;

          enddo;

720aA   endfor;

        //  Write end tag for StopFlags

        line = '</StopFlags>';
        WriteLine(fd: %addr(line)+2: %len(line));

        return;

      /end-free

     p WriteStopFlags  e

     *----------------------------------------------------------------
     *  WriteSummary    Write Summary
     *----------------------------------------------------------------

     p WriteSummary    b
     d WriteSummary    pi

     * Local Variables

     d  i              s              3  0
     d  j              s              3  0
     d  foundDept      s               n

      /free

       //  Loop through routes, calculate department summaries

       totrtec = 0;
       totrtew = 0;
       totrtep = 0;

       gDeptSumCount = 0;
       clear gDeptSum;

       for i = 1 to gRoutesCount;

         %occur(gRoutes) = i;

         setll ($pwhse: gRoutes.rtid) rtesum;

         dou forever <> forever;

           reade ($pwhse: gRoutes.rtid) rtesum;
           if %eof(rtesum);
             leave;
           endif;

           if rspckp <= 0;
             iter;
           endif;

           foundDept = *off;

           for j = 1 to gDeptSumCount;

             %occur(gDeptSum) = j;
             if gDeptSum.dept = rswhdp;
               foundDept = *on;
               leave;
             endif;

           endfor;

           if not foundDept;
             gDeptSUmCount += 1;
             %occur(gDeptSum) = gDeptSumCount;
             gDeptSum.dept = rswhdp;
             gDeptSum.pcs = 0;
             gDeptSum.wgt = 0;
             gDeptSum.cube = 0;
           endif;

           // Update department summary

           gDeptSum.pcs += rspckp;
           gDeptSum.wgt += rspckw;
           gDeptSum.cube += rspckc;

           // Update route totals

           totrtec += rspckc;
           totrtew += rspckw;
           totrtep += rspckp;

         enddo;

       endfor;

       //  Write begin tag for Summary

       line = '<Summary count="' + %char(gDeptSumCount) + '">';
       WriteLine(fd: %addr(line)+2: %len(line));

       //  Write Department Summary Records

       for i = 1 to gDeptSumCount;

         %occur(gDeptSum) = i;
         WriteDepartmentSummary();

       endfor;

       //  Write Total

       WriteSummaryTotal();

       //  Write end tag for StopFlags

       line = '</Summary>';
       WriteLine(fd: %addr(line)+2: %len(line));

       return;

      /end-free

     p WriteSummary    e

     *----------------------------------------------------------------
     *  WriteSummaryTotal   Write summary total element
     *----------------------------------------------------------------

     p WriteSummaryTotal...
     p                 b
     d WriteSummaryTotal...
     d                 pi

      /free

          LineStart('Total');

          LineAdd('traxRouteGroupID': %editc(gGroupId: 'X'));
          LineAdd('parentRouteID': gParentId);
710aA     LineAdd('routeID': gParentId);
          LineAdd('cube': %editc(totrtec:'P'));
          LineAdd('weight': %editc(totrtew:'P'));
          LineAdd('pieces': %editc(totrtep:'P'));

          LineEnd();

          WriteLine(fd: %addr(line)+2: %len(line));

        return;

      /end-free

     p WriteSummaryTotal...
     p                 e

     *----------------------------------------------------------------
     *  WriteTotes   Write totes
     *----------------------------------------------------------------

     p WriteTotes      b
     d WriteTotes      pi

     * Local Variables

     d  i              s              3  0

      /free

       // Loop through gRoutes

       for i = 1 to gRoutesCount;

         %occur(gRoutes) = i;

         // Loop through totes for route

         setll ($pwhse: gRoutes.rtid) totehdr2;

         dou forever <> forever;

           reade ($pwhse: gRoutes.rtid) totehdr2;
           if %eof(totehdr2);
             leave;
           endif;

           // Get order info

           chain (tohwhs: tohord) ordh;
           if not %found(ordh);
             clear ohrec;
           endif;

           gToteFlag = '1';
           gToteNum = tohcnt;
           gToteId = tohlbl;

           //  Total cube, wgt, & pcs for tote

           ordp_cub = 0;
           ordp_wgt = 0;
           ordp_pcs = 0;

           setll (tohwhs: tohrid: tohtr#) label94;

           dou forever <> forever;

             reade (tohwhs: tohrid: tohtr#) label94;
             if %eof(label94);
               leave;
             endif;

             ordp_cub += lbcube;
             ordp_wgt += lbswgt;
             ordp_pcs += lbqpck;

           enddo;

           //  If all items in this tote have been outed, do not write it, move
           //  on to the next tote.

           if ordp_pcs = 0;
             iter;
           endif;

           //  Get WORKLBL, ORDP2, PLTSUM12, and PIRITEM data for the tote itself

           clear lwrec;
           chain tohml# worklbl;

           clear orprec2;
           chain tohml# ordp2;

           clear psrec;
           hld_trn  = tohmt#;
           hld_plid = tohmpi;
           chain (tohwhs: tohrid: tohmt#: tohmpi) pltsum12;

           GetItem();

           // Write Tote record

           WriteItem();

           //  Write tote item records

           gToteFlag = '0';

           setll (tohwhs: tohrid: tohtr#) worklb94;

           dou forever <> forever;

             reade (tohwhs: tohrid: tohtr#) worklb94;
             if %eof(worklb94);
               leave;
             endif;

             //  Get ORDP2 data for the tote item

             clear orprec2;
             chain lwlbl# ordp2;
             if %found(ordp2);
               ordp_cub = lwucub * orpscn;
               ordp_wgt = lwuwgt * orpscn;
               ordp_pcs = orpscn;
             else;
               ordp_pcs = 0;
             endif;

             //  If this tote item has been outed, do not write it, move on to the
             //  next tote item.

             if ordp_pcs = 0;
               iter;
             endif;

             //  Get order and customer order number for the tote item,
             //  as all items within the tote may not be from the same order.

             hld_ohord  = 0;
             hld_ohcord = 0;
             chain ($pwhse: lword) ordh;
             if not %found(ordh);
               clear ohrec;
             endif;

             //  Get PIRITEM data for the tote item

             GetItem();

             //  Build string of common Item elements

             ////exsr zzBldItemStr;

             // Write tote item record

             WriteItem();

           enddo;

         enddo;

       endfor;

       return;

      /end-free

     p WriteTotes      e

     *----------------------------------------------------------------
     *  WriteTruckStopFlag   Write Truck Stop Flag element
     *----------------------------------------------------------------

     p WriteTruckStopFlag...
     p                 b
     d WriteTruckStopFlag...
     d                 pi

740cA* Local Variables

740cAd  hostStop       s              5  0

      /free

          LineStart('StopFlag');

          LineAdd('traxRouteGroupID': %editc(gGroupId: 'X'));
          LineAdd('parentRouteID': gParentId);
710aA     LineAdd('routeID': gParentId);
730aD     //LineAdd('stopNumber': %editc(ohstop:'P'));
740cD     //LineAdd('stopNumber': %editc(oh9_ohstop:'P'));
740cM     LineAdd('stopNumber': %editc(hoststop:'P'));
740cA     LineAdd('stopId': %editc(oh9_ohstop:'P'));
          //LineAdd('stopFlagType': x);
          LineAdd('stopFlagDisplayTime': ttkdsp);
          LineAdd('stopFlagChar': ttkchr);
          LineAdd('stopFlagAlert': ttaale);
          //LineAdd('stopFlagIconName': x);

          LineEnd();

          WriteLine(fd: %addr(line)+2: %len(line));

        return;

      /end-free

     p WriteTruckStopFlag...
     p                 e

     *----------------------------------------------------------------
     *  WriteTTLog    Write log record
     *----------------------------------------------------------------

     p WriteTTLog      b
     d WriteTTLog      pi

      /free

       clear ttlRec;

       ttlWhse = $pWhse;
720aD  //ttlRtid = $prtid;
720aM  ttlRtid = gParentId;
       ttlRte  = rhrte;
       ttlTry = 1;
       ttlStatus = logStatus;
       ttlFileSnd = sFileSnd;
       ttlErrCode = logErrCode;
       ttlErrMsg  = logErrMsg;
       ttlSer = ttrSer;

       SetLogTime();

       write(e) ttlrec;

      /end-free

     p WriteTTLog      e

     *----------------------------------------------------------------
     *  WriteUserInfo   Write user info
     *----------------------------------------------------------------

     p WriteUserInfo   b
     d WriteUserInfo   pi

      /free

       // Write UserInformation line

       LineStart('UserInformation');

       LineAdd('driverID': $pemp);
       LineAdd('name': gDriverFirst);
       LineAdd('lastname': gDriverLast);
       LineAdd('phone': gDriverPhone);

       LineEnd();

       WriteLine(fd: %addr(line)+2: %len(line));

       return;

      /end-free

     p WriteUserInfo   e

     *----------------------------------------------------------------
     *  ZZDriCop   Get item info.
     *----------------------------------------------------------------

     p ZZDriCop        b
     d ZZDriCop        pi

      /free

       error = *off;

       select;
         when $dricommand = '*ITEM';
           $dridata = $item;
           $dridata2 = $item2;
       endsl;

       driCop($dricommand: $drisubcmd: $drisys2upd: #prog:
                $drireturn: $drimessage: $dridata: $dridata2);

       select;
         when %error;
           error = *on;
         when $drireturn <> '*OK';
           error = *on;
       endsl;

       select;
         when $dricommand = '*ITEM';
           $item = $dridata;
           $item2 = $dridata2;
       endsl;

      /end-free

     p ZZDriCop        e

     *
     *----------------------------------------------------------------
     *          IFS Procedure API's / Error Handling
     *----------------------------------------------------------------
      /define errno_load_procedure
      /copy qcopysrc,errno_h

