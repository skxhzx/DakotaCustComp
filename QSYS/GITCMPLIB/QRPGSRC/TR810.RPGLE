      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   24 Washington Ave North #203
     *   Batavia IL  60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TR810     Create Tracker XML files.
     *
     *  16 December 2009
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *
     *  To compile:
     *
     *    CRTBNDRPG PGM(xxxlib/*CTLSPEC) SRCFILE(xxxlib/QRPGSRC)
     *     SRCMBR(tr810) DBGVIEW(*SOURCE)
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    12/16/09  RBD  5.30
     *      - Created.
     *
640 A*    05/10/11  MLB  6.40
     *      - Fix: Revised program to add additional authoritities
     *        XML output file.
     *
640aA*    07/05/11  RBD  6.40a
     *      - Added config options Icon Delivery and Double Click
     *        Icons.
     *      - Added actual catchweight to the item record for future
     *        use.  It's defined in the xsd and ORDP file, but is not
     *        yet being updated in ORDP.
     *
640bA*    07/26/11  RBD  6.40b
     *      - Replaced Compartment totals with Department totals. Was
     *        using RTECSUM to get compartment totals, but discovered
     *        that RTECSUM qty's are based on worklbl qty allocated
     *        rather than picked.  So instead, use RTESUM to provide
     *        picked qty's per department.
     *      - For readability, overlaid RTECSUM code with RTESUM code,
     *        marked as 640bM rev's.  To see former RTECSUM code,
     *        refer to PIROLD640/TR810.0726.
     *
640cA*    08/31/11  RBD  6.40c
     *      - Added breakdown flag to download file.
     *
640dA*    10/11/11  RBD  6.40d
     *      - Force url to point to root directory ... this ensures
     *        that the xml is written to BFCxxxx in the root directory
     *        even if the user's profile points to another one.
     *
640eA*    10/31/11  RBD  6.40e
     *      - Fix: Use pallet number from corresponding worklbl rec
     *        for merge records.
     *
640fA*    11/08/11  RBD  6.40f
     *      - Added config options Pallets Enabled and Cradle Upload
     *        Enabled.
     *
640gA*    01/04/12  RBD  6.40g
     *      - Added logic to accommodate Trax merged routes.  If two
     *        or more routes have been merged, write the parent route
     *        xml first, then write the xml for each of the merged
     *        routes in the same xml file as the parent.
     *
640hA*    02/01/12  RBD  6.40h
     *      - Added config option Bulk Items Enabled.
     *      - Added config option Display Empty Stops.
     *
640iA*    03/02/12  RBD  6.40i
     *      - Fix: If only 1 stop on route the handheld crashes
     *        because there are no ToStop records.  Will now write a
     *        ToStop record for the single stop to prevent handheld
     *        crash.
     *
640jA*    05/14/12  RBD  6.40j
     *      - Fix: Close xml file before leaving, otherwise, it's
     *        locked until the user signs off, making it unavailable
     *        for example, to be copied and pasted.
     *
640kA*    06/05/12  RBD  6.40k
     *      - Fix: Revisions to Trax merged routes logic. Removed
     *        some 640g code for clarity, as it's not yet in
     *        production anywhere.
     *
650aA*    02/01/13  RBD  6.50a
     *      - Removed and added some fields in TTSTPFLG.
     *      - Added logic to write only 1 stop flag to the xml if the
     *        same stop flag exists for multiple orders on the same
     *        stop. Right now the handheld cannot handle 2 or more
     *        orders on the same stop with the same stop flag.
     *
650bA*    02/20/13  RBD  6.50b
     *      - If any stop flag elements are blank, populate with '?'.
     *
650cA*    02/28/13  RBD  6.50c
     *      - Enh: added Route Tracking file processing.
     *      - Always write the record which times how long TR810 takes
     *        to run.
     *      - Only write the records which time isolated chunks of
     *        code if flag WRTCHUNK is on. Normally this flag will be
     *        off, but if TR810 is taking too long to run, we can turn
     *        on the WRTCHUNK flag, recompile, and review the RTETRCK
     *        records which get written to see what's taking too long.
     *        Then turn the flag back off and recompile this pgm.
     *
650dA*    07/09/13  RBD  6.50d
     *      - Added config option Save After Scan.
     *      - Added config option Save Delay.
     *      - Added config option Sync Date and Time.
     *      - Added config option GS1 Scanning.
     *      - Added config option GS1 Unique.
     *      - Added config option Left/Right Keys Enabled.
     *      - Added config option Scan Beep Volume.
     *
650eA*    08/09/13  RBD  6.50e
     *      - Enh: Added GS1 item, GS1 unique, and GTIN number at the
     *        item level for batch picked items. If not batch picked,
     *        the GS1 flags will be set to N.
     *
650fA*    08/22/13  RBD  6.50f
     *      - Added customer number to Stop record.
     *      - Added item designation code to Item record, but only
     *        when it's '    *', denoting a non-item.
     *
650gA*    06/12/12  RBD  6.50g
     *      - Reserved for future change.
     *
650hA*    09/25/12  RBD  6.50h
     *      - Reserved for future change.
     *
650iA*    08/26/13  RBD  6.50i
     *      - Added serial# to log record.
     *
650jA*    08/30/13  RBD  6.50j
     *      - Fix: Remove item from GTIN element. Change the way
     *        batch picks are identified.
     *
650k *    10/21/13  GJA  6.50k
     *      - Added option Restart After Get Route.
     *      - Added option Restart Daily.
     *      - Added option Restart Daily Time.
     *      - Added option Reader Focus Position.
     *      - Added option Reader Focus Mode.
     *      - Added option Non Scan Reason Prompt.
     *      - Added option Filter by Department.
     *      - Reformat restart daily time as xx:xx, RBD.
     *
650lA*    03/14/14  RBD  6.50l
     *      - Added *TRAX option:
     *          Display Stop Flags Before Restart.
     *      - Added *TRAX1 record and options:
     *          Email Receipt.
     *          Receipt Email From.
     *          Receipt Email Subject.
     *      - Added *TRAX2 record and options:
     *          Use System Suspend Battery Power Timeout.
     *          System Suspend Battery Power Timeout.
     *          Use System Suspend External Power Timeout.
     *          System Suspend External Power Timeout.
     *          Use Backlight Off Battery Power Timeout.
     *          Backlight Off Battery Power Timeout.
     *          Use Backlight Off External Power Timeout.
     *          Backlight Off External Power Timeout.
     *
CWD A*    04/28/15  MLB  CWD  P#01349
     *      - Enh: Re-compiled pgm. TOTEHDR file had order id added
     *        to make file key unique.
700aA*    03/04/16  RBD  7.00a
     *      - Enh: Added new files TTFLAG, Trax predefined stop
     *        flags and TTTRKFLG, Trax predefined stop flags by
     *        truck. Will look for the truck flags and if found
     *        will write them into the xml.
700bA*    11/03/16  LMC  7.00b
     *      - Enh: UPC file has a database change. Recompile only.
     *
710aA*    04/11/17  RBD  7.10a
     *      - For now skip over code (640g and 640k) that writes merged
     *        routes into the same xml. The handheld is not yet ready
     *        to handle multiple routes in the same xml.  So for now
     *        merged routes (TTMERG) is only used by the Loader Module.
     *        When you're ready to reinstate this logic simply take out
     *        the 710a rev.
     *
710bA*    10/11/17  RBD  7.10b
     *      - Using new Trax options optv12 and optv20:
     *          1. Call TR812 if option 2.0 is set.
     *          2. Get out if option 1.2 is not set.
     *
710cA*    11/18/17  DAS  7.10c
     *      - Revised to get IFS folder from *TRAX2 options
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: CDI
     *
CDIaA*    10/06/15  RBD  CDIa
     *      - Do not write category CART items to xml file.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Julius Silvert
     *
JSLa *    04/04/17  RBD/GJA   JSLa
     *      - Format URL for CLOUD
     *
     *
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
     * Indicators
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Flabel94   if   e           k disk
     Foptions   if   e           k disk
650jAFoptionz   if   e           k disk
640cAFordd      if   e           k disk
650eAForddm     if   e           k disk
     Fordh      if   e           k disk    prefix(oh_)
     Fordh9     if   e           k disk    rename(ohrec:ohrec9)
     Fordp2     if   e           k disk
     F                                     rename(orprec:orprec2)
     Fordp4     if   e           k disk
     Fpiruser1  if   e           k disk
     Fpltsum12  if   e           k disk
     Fttlog     uf a e           k disk
640bMFrtesum    if   e           k disk
     Frtehed    if   e           k disk
650cAFrtetrck   o  a e           k disk
     Frtncode   if   e           k disk
640gAFttmerg    if   e           k disk
640kAFttmerg2   if   e           k disk    rename(ttmrec:ttmrec2) prefix(tt2_)
650iAFttrte     if   e           k disk
     Fttstpflg  if   e           k disk
700aAFttflag    if   e           k disk
700aAFtttrkflg  if   e           k disk
     Ftotehdr1  if   e           k disk    prefix(t1_)
     Ftotehdr2  if   e           k disk
     F                                     rename(tohrec:tohrec2)
650eAFupc2      if   e           k disk
     Fworklbfi  if   e           k disk
     Fworklbl   if   e           k disk
     Fworklbl7  if   e           k disk    prefix(lb7_)
     F                                     rename(lwrec:lwrec7)
     Fworklb94  if   e           k disk
     F                                     rename(lwrec:lwrec94)

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D recval          s             90    dim(3) ctdata perrcd(1)
     D stops           s              3  0 dim(999)

     *----------------------------------------------------------------
     *  Customer id
     *
      /COPY QCOPYSRC,ID#harbor
CDIaA /COPY QCOPYSRC,ID#cdi
JSLaA /COPY QCOPYSRC,ID#jsl

650cA*----------------------------------------------------------------
650cA*  Called programs
650cA*
650cAD @cvtdt          c                   const('CVTDTE')
650cAD @clcdr          c                   const('CLCDUR')
650cA*----------------------------------------------------------------
650cA*  Called program parameters
650cA*
650cAD $cvtdt          ds
650cAD  $cvcmd                 1      8
650cAD  $cvprg                 9     18
650cAD  $cvd6i                19     24
650cAD  $cvd8i                25     32
650cAD  $cvd6o                33     38  0
650cAD  $cvd8o                39     46  0
650cAD  $cvsto                47     64
650cAD  $cvrtn                65     72
650cAD  $cverm                73    132
650cAD  $cvmsg                73     76
650cAD  $cvdr1               133    140
650cAD  $cvvl1               141    145  0

     *----------------------------------------------------------------
     *  IFS Prototypes
     *----------------------------------------------------------------

     D/copy qcopysrc,c#ifsio_h
     D/copy qcopysrc,errno_h
      /copy qcopysrc,p.bfcdteti

     D chkifsobj       pr                  extpgm('CHKIFSOBJ')
     D  path                        640A   const
     D  authority                    10A   const

     *----------------------------------------------------------------
710bA*  Prototypes
     *----------------------------------------------------------------

710bAD tr812           pr                  extpgm('TR812')
710bA * Input
710bAD   pCmd                        10    const
710bAD   pWhse                        3  0 const
710bAD   pRtid                        5    const
710bAD   pEmp                         5    const
710bA * Output
710bAD   pFileSnd                    30    const
710bAD   pRtn                         8    const
710bAD   pErm                        60    const

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
640aA*    OPTIDL  -  Icon delivery
640aA*    OPTDCI  -  Double click icons
640fA*    OPTPAL  -  Pallets enabled
640fA*    OPTCRA  -  Cradle upload enabled
640hA*    OPTDRV  -  Driver assigned before download
640hA*    OPTBUL  -  Bulk items enabled
640hA*    OPTEYS  -  Display empty stops
650dA*    OPTSAS  -  Save after scan
650dA*    OPTSDL  -  Save delay
650dA*    OPTSDT  -  Sync date and time
650dA*    OPTLRK  -  Left/right keys enabled
650dA*    OPTGSS  -  GS1 scanning
650dA*    OPTGSU  -  GS1 unique
650dA*    OPTSBV  -  Scan beep volume
650kA*    OPTRAG  -  Restart after get route.
650kA*    OPTRD   -  Restart daily.
650kA*    OPTRDT  -  Restart daily time.
650kA*    OPTRFP  -  Reader focus position.
650kA*    OPTRFM  -  Reader focus mode.
650kA*    OPTNSR  -  Non scan reason prompt.
650kA*    OPTFBD  -  Filter by department.
650lA*    OPTDSF  -  Display stop flags before restart.
     *
     * Data structure
     *
650lMD opdta           ds
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
640aAD  optidl                77     77
640aAD  optdci                78     78
640fAD  optpal                79     79
640fAD  optcra                80     80
640hAD  optdrv                81     81
640hAD  optbul                82     82
640hAD  opteys                83     83
650dAD  optsas                84     84
650dAD  optsdl                85     86  0
650dAD  optsdt                87     87
650dAD  optlrk                88     88
650dAD  optgss                89     89
650dAD  optgsu                90     90
650dAD  optsbv                91     91  0
650kAD  optrag                92     92
650kAD  optrd                 93     93
650kAD  optrdt                94     97  0
650kAD  optrfp                98     98
650kAD  optrfm                99     99
650kAD  optnsr               100    100
650kAD  optfbd               101    101
650lAD  optdsf               102    102
     D  opten                117    117
650lA*----------------------------------------------------------------
650lA*  *TRAX1    -  More TRAX options
650lA*----------------------------------------------------------------
650lA*
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
650lA*----------------------------------------------------------------
650lA*  *TRAX2  -  More TRAX options
650lA*----------------------------------------------------------------
650lA*
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
710bA*    OPTV12  -  Default = N.  Y = create V1.2 xml.
710bA*    OPTV20  -  Default = N.  Y = create V2.0 xml.
710cA*    OPTDIR  -  IFS main directory
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
710bAD  optv12                18     18
710bAD  optv20                19     19
710cAD  optdir                20     39
     D  opten2               117    117
     *----------------------------------------------------------------
650jA*  *PICK  -  Picking options
650jA*
650jA*----------------------------------------------------------------
650jA*
650jA* Fields
650jA*
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
     *  Order Misc field data structures
     *----------------------------------------------------------------

      /copy qcopysrc,ohmisc_har

     *----------------------------------------------------------------
     *  Working variables
     *
650cAD $tpgm           s             10
     D bulk            s              1
640cAD brkDwnFlg       s              1
     D canbrk1         s              1
     D canbrk2         s              1
640gAD childRte        s               n
     D directions      s            800
710cAD dirLen          s              3  0
     D error           s               n
     D errorCtr        s              2  0
     D fd              s             10I 0
     D filnam          s             25
     D first           s              1
650eAD gs1item         s              1
650eAD gs1uniq         s              1
650eAD gtin#           s             18
     D ihrng           s              9  2
     D ihvar           s              9  2
     D ilrng           s              9  2
     D ilvar           s              9  2
     D hld_ohord       s                   like(ohord)
     D hld_ohcord      s                   like(ohcord)
640kAD hld_parent      s              5
     D hld_plid        s                   like(psplid)
     D hld_rtid2       s              2
     D hld_rtidplt     s              7
     D hld_trn         s                   like(pstrn#)
     D ix1             s              3  0 inz(0)
     D ix2             s              3  0 inz(0)
650jAD kycode          s                   like(opzcod)
650lDD*ItemStr         s           1024
650lMD ItemStr         s           2048
     D licpCtr         s              3  0
650lDD*line            s           1024A
650lMD line            s           2048A
     D len             s             10I 0
     D logStatus       s                   like(ttlStatus)
     D logErrCode      s                   like(ttlErrCode)
     D logErrMsg       s                   like(ttlErrMsg)
     D lstStop         s              2  0 inz(0)
640kAD mergeParent     s               n
     D miles           s              7  2 inz(0)
     D msg2snd         S            512A
     D NoNameDriver    s              5  0 inz(99999)
     D ordp_cub        s              9  3 inz(0)
     D ordp_wgt        s              9  2 inz(0)
     D ordp_pcs        s              5  0 inz(0)
640 AD out_flags       s             10u 0
640 AD out_mode        s             10u 0
     D pathlen         s              3  0
     D prg1c           s              4  3
     D prg2c           s              4  3
     D sFileRcv        s             30
     D sFileSnd        s             30
     D sFileTry        s             30
     D sMsg            s             60
     D sReturn         s             10
     D stmfSend        S            256A
     D stpcnt          s              3  0
     D stpFlgCnt       s              3  0
     * The sv_ fields have been converted and may contain character
     * translations, thus the need for the field sizes to allow extra
     * room for the translations.
     D sv_comp         s             10
     D sv_desc         s            200
650fAD sv_desg         s              5
650fAD sv_desg1        s              1
     D sv_item         s            100
     D sv_rncode       s             20
     D sv_rndesc       s            200
     D sv_styp         s             10
     D sv_ttfale       s            200
650aDD*sv_ttfchr       s             10
650aMD sv_ttfchr       s              1
650aAD sv_ttfdsp       s              1
     D sv_ttfico       s            100
     D sv_ttftyp       s            200
700aAD sv_ttaale       s            200
700aAD sv_ttkchr       s              1
700aAD sv_ttkdsp       s              1
     D sv_ucod         s             20
     D sv_um2          s             20
     D sv_um3          s             20
     D sv_upc          s            150
     D sv_whdp         s             50
     D sv_zone         s             50
650cAD svdte           s              8  0
650cAD svdteA          s              8  0
650cAD svdteB          s              8  0
650cAD svdteC          s              8  0
650cAD svdteD          s              8  0
650cAD svdteE          s              8  0
650cAD svdteF          s              8  0
700aAD svdteG          s              8  0
650cAD svpgm           s             10
650cAD svpgmA          s             10
650cAD svpgmB          s             10
650cAD svpgmC          s             10
650cAD svpgmD          s             10
650cAD svpgmE          s             10
650cAD svpgmF          s             10
700aAD svpgmG          s             10
650cAD svtim           s              6  0
650cAD svtimA          s              6  0
650cAD svtimB          s              6  0
650cAD svtimC          s              6  0
650cAD svtimD          s              6  0
650cAD svtimE          s              6  0
650cAD svtimF          s              6  0
700aAD svtimG          s              6  0
     D totrtec         s              9  3 inz(0)
     D totrtew         s              9  2 inz(0)
     D totrtep         s              5  0 inz(0)
     D totstpc         s              9  3 inz(0)
     D totstpw         s              9  2 inz(0)
     D totstpp         s              5  0 inz(0)
     D trlrctr         s              3  0
650eAD upc14           S             14A
650eAD upc18           S             18A
     D url             S            256A
650cAD wrtChunk        s               n

     *----------------------------------------------------------------
     *  Date/time variables
     *
     D bfcoffset       s              3  0 inz(0)
     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D currtimestamp   s               z
     D datestamp       s               d
     D editdate        s               d
     D edittime        s               t   timfmt(*hms:)
     D micro           s             26
     D micro2          s              2
     D timestamp       s               t   timfmt(*hms:)
     D traveltime      s               t   timfmt(*hms:)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Key definitions
     *----------------------------------------------------------------

     D keyop           ds                  likerec(oprec : *key)
     D keyttl          ds                  likerec(ttlrec : *key)
650iAD keyttr          ds                  likerec(ttrrec : *key)

     *----------------------------------------------------------------
     *  Constants
     *
     D forevr          c                   const('1')
650eAD Numbers         C                   '0123456789'

     *----------------------------------------------------------------
     *
     * Data structure

650kAD optrdtDS        ds
650kAD  optrdt12               1      2    inz('00')
650kAD  optrdt3                3      3    inz(':')
650kAD  optrdt45               4      5    inz('00')

     *----------------------------------------------------------------
     *  CVTTEXT Parameters

     D $cmd            s             10
     D $in             s            500
     D $out            s            500

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
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
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $pemp             5
     C                   parm                    sFileSnd
     C                   parm                    $prtn             8
     C                   parm                    $perm            60
     *
     * Main line
     *

710bA /free

710bA  if optv20 = 'Y';
710bA    tr812('*ROUTE': $pwhse: $prtid: $pemp: '': '': '');
710bA  endif;

710bA  if optv12 <> 'Y';
710bA    return;
710bA  endif;

710bA /end-free

710aAC                   goto      skipChildren
640kA*   Find out if this route is a parent or child of a merged route.
640kA*   If so, write the parent xml first, then each of the children.
     *
640kAC     keyoh_p       chain     ttmerg
640kAC                   if        %found(ttmerg)
640kAC                   eval      mergeParent = *on
640kAC                   eval      hld_parent = $prtid
640kAC                   else
640kAC     keyoh_p       chain     ttmerg2
640kAC                   if        %found
640kAC                   eval      mergeParent = *on
640kAC                   eval      hld_parent = tt2_ttmpri
640kAC                   eval      $prtid = tt2_ttmpri
640kAC                   endif
640kAC                   endif
640kAC                   goto      skipChildren
     *
640kAC     doChildren    tag
     *
640gAC     keyTTM        setll     ttmerg
640gAC                   dou       forevr <> forevr
640gAC     keyTTM        reade     ttmerg
640gAC                   if        %eof(ttmerg)
640gAC                   leave
640gAC                   endif
640gAC                   eval      first = *on
640gAC                   eval      childRte = *on
640gAC                   eval      $prtid = ttmcri
640gAC                   move      $prtid        hld_rtid2
     *
640kAC     skipChildren  tag
     *
     *  Get route header data ... get out if not found
     *
     C     keyoh_p       chain     rtehed
     C                   if        not %found(rtehed)
     C                   eval      $perm = 'Route not found'
     C                   eval      $prtn = '*CANCEL'
     C                   goto      bottom
     C                   endif
     *
     *  If emp# is blank, check to see if a 'no name driver' exists.
     *  If so, force $pemp to be the 'no name driver'.
     *
     C                   if        $pemp = ' '
     C                             or $pemp = '00000'
     C     NoNameDriver  chain     piruser1
     C                   if        %found(piruser1)
     C                   eval      $pemp = '99999'
     C                   endif
     C                   endif
     *
     *  Verify employee ... get out if not found
     *
     C                   call      'TRVFYEMP'
     C                   parm                    $pemp
     C                   parm                    $perm
     C                   parm                    $puser           10
     C                   if        $perm <> ' '
     C                   eval      $prtn = '*CANCEL '
     C                   goto      bottom
     C                   endif
     *
     *  Route and employee are good, let's build the file
     *
     C                   eval      $prtn = '*OK     '
     *
     *      Get and format date/time
     *
     C                   time                    currtimestamp
     C                   move      currtimestamp datestamp
     C                   move      currtimestamp timestamp
     C                   move      currtimestamp micro
     C                   eval      micro2 = %subst(micro:20:2)
     *
     *  Construct file name using whse, route id, and datestamp
     *
     C                   eval      filnam = 'W'
     C                                +  %TrimL(%editc($pwhse:'X'))
     C                                + 'R'
     C                                + $prtid
     *
     C                   eval      sFileSnd = %trimr(filnam) + '_RTE.XML'
     C                   eval      sFileRcv = %trimr(filnam) + '_RTN.XML'
     C                   eval      sFileTry = %trimr(filnam) + '_RTN1.XML'
     *
     C                   select

710cAC                   when      optdir <> ''
710cAC                   eval      dirLen = %len(%trimr(optdir))
710cAC                   if        %subst(optdir:1:1) <> '/'
710cAC                   eval      url = '/' + optdir
710cAC                   else
710cAC                   eval      url = optdir
710cAC                   endif
710cAC                   if        %subst(optdir:dirLen:1) <> '/'
710cAC                   eval      url = %trimr(url) + '/'
710cAC                   endif

     C                   when      optert = 'PROD'
640dDC**                 eval      url = 'BFCTrax/'
JSLaAC                   if        client = JSilvert
JSLaAC                   eval      url = '/JSLTrax/'
JSLaAC                   else
640dMC                   eval      url = '/BFCTrax/'
JSLaAC                   endif

     C                   when      optert = 'TEST'
640dDC**                 eval      url = 'BFCTraxTest/'
JSLaAC                   if        client = JSilvert
JSLaAC                   eval      url = '/JSLTraxTest/'
JSLaAC                   else
640dMC                   eval      url = '/BFCTraxTest/'
JSLaAC                   endif

     C                   when      optert = 'DEV '
640dDC**                 eval      url = 'BFCTraxDev/'
640dMC                   eval      url = '/BFCTraxDev/'

     C                   endsl
     C                   eval      stmfSend = %trimr(url) + sFileSnd
     *
     *  Write or update FILESTART record to log file
     *
     C                   eval      logErrCode = 'FILESTART'
     C                   eval      logErrMsg = 'File creation start'
     C                   eval      logStatus = '1'
     C                   exsr      updateTTLog
     *
     *  Open the file to write to, get out if error
     *
640gA*  Do not perform file open logic for child routes, as the
640gA*  xml file has already been opened.
     *
640gAC                   if        childRte = *off
640 AC                   eval      out_flags =  o_wronly
640 AC                                        + o_creat
640 AC                                        + o_trunc
640 AC                                        + o_share_rdwr
640 AC                                        + o_codepage
640 AC*
640 AC                   eval      out_mode  =  s_irusr
640 AC                                        + s_iwusr
640 AC                                        + s_ixusr
640 AC*
640 AC                                        + s_irgrp
640 AC                                        + s_iwgrp
640 AC                                        + s_ixgrp
640 AC*
640 AC                                        + s_iroth
640 AC                                        + s_iwoth
640 AC                                        + s_ixoth
640 AC*
640 Dc*                  eval      fd = open(%trimr(stmfSend):
640 Dc*                                 O_TRUNC+O_CREAT+O_WRONLY+
640 Dc*                                 O_CODEPAGE:
640 Dc*                                 S_IWUSR+S_IRUSR+S_IRGRP+S_IROTH:
640 Dc*                                 819)
640 Mc                   eval      fd = open(%trimr(stmfSend)
640 Mc                                  :out_flags
640 Mc                                  :out_mode:819)
     c                   if        fd < 0
     C                   eval      logErrCode = 'CRTOPNERR1'
     C                   eval      logErrMsg = 'File create error: '
     C                                     + %str(strerror(errno))
     C                   eval      logStatus = '9'
     C                   exsr      updateTTLog
     C                   goto      bottom
     c                   endif
     *
     *  Close, then re-open the file in text mode
     *
     C                   callp     close(fd)
     c                   eval      fd = open(%trimr(stmfSend):
     c                                  O_WRONLY+O_TEXTDATA)
     c                   if        fd < 0
     C                   eval      logErrCode = 'CRTOPNERR1'
     C                   eval      logErrMsg = 'File reopen error: '
     C                                     + %str(strerror(errno))
     C                   eval      logStatus = '9'
     C                   exsr      updateTTLog
     C                   goto      bottom
     c                   endif
640gAc                   endif
     *
     C                   eval      $prtn = '*OK    '
     *
     *  Write XML version record
     *
     C                   eval      line = %Trim(recval(1))
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Route xmlns record
     *
     C                   eval      line = %Trim(recval(2))
     C                                +  ' '
     C                                +  %Trim(recval(3))
     C                                +  %Trim(optwsi)
     C                                +  ':'
     C                                +  %TrimL(%editc(optwsp:'P'))
     C                                +  '/BFCTraxWS/BFCTrax.xsd"'
     C                                +  ' driverID="'
     C                                +  %Trim($pemp)
     C                                +  '" truckID="'
     C                                +  rhtruk
     C                                +  '" licensePlate="'
     C                                +  'XXXXXXXX'
     C                                +  '" routeID="'
     C                                +  %Trim($prtid)
     C                                +  '" routeName="'
     C                                +  %Trim(rhrte)
     C                                +  '" warehouseCode="'
     C                                +  %TrimL(%editc($pwhse:'X'))
     C                                +  '">'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write start tag Stops record
     *
     C                   eval      line = '<Stops>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Get order header data
     *
650cAC                   eval      $tpgm = 'TR810A    '
650cAC                   exsr      zzstrt
     C     keyoh_p       setll     ordh9
     C                   dou       forevr <> forevr
     C     keyoh_p       reade     ordh9
     C                   if        %eof(ordh9)
     C                   leave
     C                   endif
     *
     *    Stop should never be blank, but it's happened with test data,
     *    so to keep the xml from blowing up in the handheld, if it's
     *    blank, set it to 99.
     *
     C                   if        ohstop = 0
     c                   eval      ohstop = 99
     C                   endif
     *
     *    First time through, write first Stop record to file and array
     *
     C                   if        first = *on
     c                   exsr      zzWrtStop
     c                   eval      lstStop = ohstop
     c                   eval      ix1 = 1
     c                   eval      stops(ix1) = ohstop
     C                   eval      first = *off
     C                   endif
     *
     *  If Stop changes :
     *  Write end tag Items record
     *  Write end tag Stop record
     *  Write Stop record for next stop
     *  Write Stop to stops array
     *
     C                   if        ohstop <> lstStop
     *
     C                   eval      line = '</Items>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     C                   eval      line = '</Stop>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)

     c                   exsr      zzWrtStop
     c                   eval      lstStop = ohstop
     c                   eval      ix1 = ix1 + 1
     c                   eval      stops(ix1) = ohstop

     c                   endif
     *
     *-------------------------------------------------------------------------
     *
     *  Loop through and write Tote and Tote Item records
     *
     c                   exsr      zzWrtTote
     *
     *  Loop through and write Item records (non-tote)
     *
650cAC                   eval      $tpgm = 'TR810B    '
650cAC                   exsr      zzstrt
     C     keyord        setll     ordp4
     C                   dou       forevr <> forevr
     C     keyord        reade     ordp4
     C                   select
     C                   when      %eof(ordp4)
     C                   leave
     C                   when      orpsq# = 0
     C                   iter
     C                   when      orpscn = 0
     C                   iter
     C                   other
CDIaA*
CDIaA* For specific customer(s) check to see if this is a category of item which
CDIaA* should not be written to the xml file.
CDIaA*
CDIaAC                   if        client = cdi
CDIaAC                   exsr      getitem
CDIaAC                   if        $ifcat = 'CART      '
CDIaAC                   iter
CDIaAC                   endif
CDIaAC                   endif
CDIaA*
     C     orplbl        chain     worklbl
     c                   if        not %found(worklbl)
     c                   iter
     c                   endif
     C     lwtrn#        chain     totehdr1
     c                   if        %found(totehdr1)
     c                   iter
     c                   endif
     *
     * Write Item record
     *
     c                   exsr      zzWrtItem
     *
650eA* Write GTIN/s for item, if any.
650eA*
650eAc                   if        gs1item = 'Y'
650eAc                   exsr      zzWrtGTIN
650eAc                   endif
650eA*
     C                   endsl
     C                   enddo
650cAC                   eval      $tpgm = 'TR810B    '
650cAC                   exsr      zzend
     *
     C                   enddo
650cAC                   eval      $tpgm = 'TR810A    '
650cAC                   exsr      zzend
     *
     *---------------------------------------------------------------------
     *
     *  Finish up with end of route processing
     *
     *  Write end tag Items record for last stop
     *
     C                   eval      line = '</Items>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write end tag Stop record for last stop
     *
     C                   eval      line = '</Stop>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write end tag Stops record
     *
     C                   eval      line = '</Stops>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
640bM* Write Summary, Department Summary, and Total records
     *
     c                   exsr      zzWrtSumm
     *
     * Write Driving Estimations records
     *
     c                   exsr      zzWrtDrive
     *
     * Write Return Codes records
     *
     c                   exsr      zzWrtRtnCode
     *
     * Write Stop Flag records
     *
     c                   exsr      zzWrtStopFlg
     *
700aA* Write predefined stop flags by truck for each stop
700aA*
700aAc                   exsr      zzWrtStopFlgP
     *
     * Write Configuration record
     *
650lMC                   if        opdta  <> ' '
     c                   exsr      zzWrtConfig
     C                   endif
     *
     *  Write end tag Route record
     *
     C                   eval      line = '</route>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  The file has been successfully built, update log record.
     *
     C                   eval      logErrCode = 'FILEEND'
     C                   eval      logErrMsg = 'File creation end'
     C                   eval      logStatus = '2'
     C                   exsr      updateTTLog
     *
     C     bottom        tag
     *
640kA*  If this is a merged route and you just processed the parent,
640kA*  go back to the top into the do loop to process the children.
     *
640kAC                   if        mergeParent = *on
640kAC                   eval      mergeParent = *off
640kAC                   goto      doChildren
640kAC                   endif
     *
640gAC                   enddo
     *
640jA*  Close the file
640jA*
640jAC                   callp     close(fd)
     *
650cAC                   eval      $tpgm = '*TRAXXML  '
650cAC                   exsr      zzend
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     C                   eval      first = *on
650cAC                   eval      wrtChunk = *off
     *
650cAC                   eval      $tpgm = '*TRAXXML  '
650cAC                   exsr      zzstrt
     *
     *   Get client id
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     *
     *   Define full key for ORDH file
     *
     C     keyoh         klist
     C                   kfld                    $pwhse
     C                   kfld                    lword
     *
     *   Define partial key for ORDH9 file
     *
     C     keyoh_p       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
640cA*   Define partial key for ORDD file
640cA*
640cAC     keyod         klist
640cAC                   kfld                    $pwhse
640cAC                   kfld                    orpord
640cAC                   kfld                    orpsq#
     *
     *   Define partial key for TTSTPFLG file
     *
     C     keyStpFlg     klist
     C                   kfld                    $pwhse
650aDC**                 kfld                    rhrte
     C                   kfld                    $prtid
650bDC**                 kfld                    ohstop
650bMC                   kfld                    ttfstp
650bMC                   kfld                    ttfchr
     *
     *   Define partial key for WORKLBFI file
     *
     C     keywlbfi      klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    ohstop
     *
     *   Define full key for PLTSUM12 file
     *
     C     keyps12       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    hld_trn
     C                   kfld                    hld_plid
     *
     *   Define partial key for TOTEHDR2 & ORDP4
     *
     C     keyord        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    ohord
     *
     *   Define partial key for WORKLBL7
     *
     C     keywrklb7     klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    lwlbl#
     *
     *   Define partial key for WORKLB94
     *
     C     keywrklb94    klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    tohtr#
     C                   move      $prtid        hld_rtid2
     *
640gA*   Define key for TTMERG
     *
640gAC     keyTTM        klist
640gAC                   kfld                    $pwhse
640gAC                   kfld                    hld_parent
     *
650eA*  Define key for ORDDM file.
650eA*
650eAC     keyom         klist
650eAC                   kfld                    $pwhse
650eAC                   kfld                    ohord
650eAC                   kfld                    odseq
650eAC                   kfld                    oditem
     *
650eA*  Define key for UPC2 file.
650eA*
650eAC     keyupc2       klist
650eAC                   kfld                    $pwhse
650eAC                   kfld                    oditem
     *
650jA*  Define key for OPTIONZ file.
650jA*
650jAC     keyopz        klist
650jAC                   kfld                    kycode
650jAC                   kfld                    $pwhse
650jAC                   kfld                    $ptmpl
650jAC                   kfld                    psszon
     *
700aA*  Define key for TTTRKFLG
700aA*
700aAC     keytrkfl      klist
700aAC                   kfld                    $pwhse
700aAC                   kfld                    rhtruk
     *
700aA*  Define key for TTFLAG
700aA*
700aAC     keyflag       klist
700aAC                   kfld                    $pwhse
700aAC                   kfld                    ttkchr
     *
     C                   exsr      getOptions
     *
650kA*  Reformat restart daily time
650kA
650kAC                   if        optrdt > 0
650kAC                   movel     optrdt        optrdt12
650kAC                   move      optrdt        optrdt45
650kAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GetItem    Get item master data
     *
     C     getItem       begsr

     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#

     C                   eval      $itwhse   = ohwhse
     C                   eval      $ititem   = orpitm

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzdricop
     C                   if        error = *on
     C                   eval      $itcwgt = 'N'
     C                   eval      $itdesc = *blanks
     C                   eval      $itupc  = *blanks
     C                   eval      $itum2  = *blanks
     C                   eval      $itumq2 = 0
     C                   eval      $itum3  = *blanks
     C                   eval      $itumq3 = 0
650fAC                   eval      $itdesg = *blanks
CDIaAC                   eval      $ifcat  = *blanks
     C                   endif

     C                   endsr

650jA*----------------------------------------------------------------
650jA*  getZoneOpts   Get zone options
650jA*----------------------------------------------------------------
650jA
650jAC     getZoneOpts   begsr
650jA
     C                   call      'GETZONTMPL'
     C                   parm                    $pwhse
     C                   parm                    pstruk
     C                   parm                    $ptmpl           10

     C                   eval      kycode = '*PICK   '
     C     keyopz        chain(e)  optionz
     C                   if        not %found
     C                   eval      opptyp = *blanks
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZBLDITEMSTR  Build string of common Item elements which will
     *                be used for writing tote records, tote item
     *                records, and non-tote item records.
     *
     C     zzBldItemStr  begsr
     *
     *  First, send all alpha fields thru CVTTEXT and save them for output.
     *  CVTTEXT translates special characters into acceptable XML values.
     *
     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      lwitem        $in
     C                   parm      *blanks       $out
     C                   eval      sv_item = $out

     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      lwcomp        $in
     C                   parm      *blanks       $out
     C                   eval      sv_comp = $out

     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      lwtzon        $in
     C                   parm      *blanks       $out
     C                   eval      sv_zone = $out

     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      lwwhdp        $in
     C                   parm      *blanks       $out
     C                   eval      sv_whdp = $out

     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      lwstyp        $in
     C                   parm      *blanks       $out
     C                   eval      sv_styp = $out

     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      $itdesc       $in
     C                   parm      *blanks       $out
     C                   eval      sv_desc = $out

     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      $itupc        $in
     C                   parm      *blanks       $out
     C                   eval      sv_upc  = $out

650fAc                   call      'CVTTEXT'
650fAC                   parm      '*XML      '  $cmd
650fAC                   parm      $itdesg       $in
650fAC                   parm      *blanks       $out
650fAC                   eval      sv_desg = $out

     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      lwucod        $in
     C                   parm      *blanks       $out
     C                   eval      sv_ucod = $out

     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      $itum2        $in
     C                   parm      *blanks       $out
     C                   eval      sv_um2  = $out

     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      $itum3        $in
     C                   parm      *blanks       $out
     C                   eval      sv_um3  = $out

     *  Put together combo field of last 2 char of rtid and full
     *  pallet id.

640eDC**                 move      lwpal#        hld_rtidplt
640eMC                   move      hld_plid      hld_rtidplt
     C                   movel     hld_rtid2     hld_rtidplt

     *  Set boolean value for bulk.

     C                   if        lwtype = 'M'
     c                             and lwwhdp = '*BULK'
     c                   eval      bulk = '1'
     C                   else
     c                   eval      bulk = '0'
     C                   endif

     *  Set canbreakdown1 & 2 values.

     C                   if        $itumq2 > 0
     c                   eval      canbrk1 = 'Y'
     C                   else
     c                   eval      canbrk1 = 'N'
     C                   endif
     C                   if        $itumq3 > 0
     c                   eval      canbrk2 = 'Y'
     C                   else
     c                   eval      canbrk2 = 'N'
     C                   endif

640cA*  Get breakdown flag value.
640cA
640cAC                   eval      brkDwnFlg = '0'
640cAC     keyod         chain     ordd
640cAC                   if        %found(ordd)
640cAC                   select
640cAC                   when      odqor2 > 0
640cAC                   eval      brkDwnFlg = '1'
640cAC                   when      odqor3 > 0
640cAC                   eval      brkDwnFlg = '2'
640cAc                   endsl
640cAc                   endif

     C                   eval      ItemStr = 'itemNumber="'
     C                                +  %Trim(sv_item)
     C                                +  '" palletNumber="'
640eDC**                              +  %TrimL(%editc(lwpal#:'P'))
640eMC                                +  %TrimL(%editc(hld_plid:'P'))
     C                                +  '" unloadSequence="'
     C                                +  %TrimL(%editc(psunld:'P'))
     C                                +  '" cube="'
     C                                +  %TrimL(%editc(ordp_cub:'P'))
     C                                +  '" weight="'
     C                                +  %TrimL(%editc(ordp_wgt:'P'))
     C                                +  '" pieces="'
     C                                +  %TrimL(%editc(ordp_pcs:'P'))
     C                                +  '" compartment="'
     C                                +  %Trim(sv_comp)
     C                                +  '" zone="'
     C                                +  %Trim(sv_zone)
     C                                +  '" dept="'
     C                                +  %Trim(sv_whdp)
     C                                +  '" bulk="'
     C                                +  %Trim(bulk)
     C                                +  '" description="'
     C                                +  %Trim(sv_desc)
     C                                +  '" scanID="'
     C                                +  %Trim($prtid)
     C                                +  %TrimL(%editc(orpup#:'X'))
     C                                +  '" palletScanID="'
     C                                +  %Trim(hld_rtidplt)
     C                                +  '" internalOrderNumber="'
     C                                +  %TrimL(%editc(hld_ohord:'P'))
     C                                +  '" customerOrderNumber="'
     C                                +  %TrimL(%editc(hld_ohcord:'P'))
     C                                +  '" canBreakDown1="'
     C                                +  %Trim(canbrk1)
     C                                +  '" canBreakDown2="'
     C                                +  %Trim(canbrk2)
640cAC                                +  '" breakDownFlag="'
640cAC                                +  %Trim(brkDwnFlg)
     C                                +  '"'
     *
     *  If all u/m's are blank, force normal u/m to be 'GE'.
     *
     C                   if        sv_ucod = ' '
     C                             and sv_um2 = ' '
     C                             and sv_um3 = ' '
     C                   eval      sv_ucod = 'GE'
     C                   endif
     *
     C                   if        sv_ucod <> ' '
     C                   eval      ItemStr = %Trim(ItemStr)
     C                                +  ' unitMeasure="'
     C                                +  %Trim(sv_ucod)
     C                                +  '"'
     C                   endif
     *
     C                   if        sv_upc <> ' '
     C                   eval      ItemStr = %Trim(ItemStr)
     C                                +  ' uccCode="'
     C                                +  %Trim(sv_upc)
     C                                +  '"'
     C                   endif
     *
     C                   if        sv_styp <> ' '
     C                   eval      ItemStr = %Trim(ItemStr)
     C                                +  ' type="'
     C                                +  %Trim(sv_styp)
     C                                +  '"'
     C                   endif
     *
     C                   if        $itumq2 <> 0
     C                   eval      ItemStr = %Trim(ItemStr)
     C                                +  ' breakDown1Quantity="'
     C                                +  %TrimL(%editc($itumq2:'P'))
     C                                +  '"'
     C                   endif
     *
     C                   if        $itumq3 <> 0
     C                   eval      ItemStr = %Trim(ItemStr)
     C                                +  ' breakDown2Quantity="'
     C                                +  %TrimL(%editc($itumq3:'P'))
     C                                +  '"'
     C                   endif
     *
     C                   if        sv_um2 <> ' '
     C                   eval      ItemStr = %Trim(ItemStr)
     C                                +  ' breakDown1UM="'
     C                                +  %Trim(sv_um2)
     C                                +  '"'
     C                   endif
     *
     C                   if        sv_um3 <> ' '
     C                   eval      ItemStr = %Trim(ItemStr)
     C                                +  ' breakDown2UM="'
     C                                +  %Trim(sv_um3)
     C                                +  '"'
     C                   endif
     *
650fA*  For now, only send designation code if it's a non-item designation,
650fA*  which is '    *'.  Only send 1 char.
650fA*
650fAC                   eval      sv_desg1 = *blanks
650fAC                   select
650fAC                   when      sv_desg = '    *'
650fAC                   eval      sv_desg1 = '*'
650fAC                   endsl
650fA*
650fAC                   if        sv_desg1 <> ' '
650fAC                   eval      ItemStr = %Trim(ItemStr)
650fAC                                +  ' designationCode="'
650fAC                                +  %Trim(sv_desg1)
650fAC                                +  '"'
650fAC                   endif
650fA*
     C                   select
     C                   when      $itcwgt = 'Y'
     C                   exsr      zzcw

     C                   if        ilrng <> 0
     C                   eval      ItemStr = %Trim(ItemStr)
     C                                +  ' catchWeightMin="'
     C                                +  %TrimL(%editc(ilrng:'P'))
     C                                +  '"'
     C                   endif
     *
     C                   if        ihrng <> 0
     C                   eval      ItemStr = %Trim(ItemStr)
     C                                +  ' catchWeightMax="'
     C                                +  %TrimL(%editc(ihrng:'P'))
     C                                +  '"'
     C                   endif
     *
     C                   if        $itswgt <> 0
     C                   eval      ItemStr = %Trim(ItemStr)
     C                                +  ' catchWeight="'
     C                                +  %TrimL(%editc($itswgt:'P'))
     C                                +  '"'
     C                   endif
     *
640aAC                   if        orpwgt <> 0
640aAC                   eval      ItemStr = %Trim(ItemStr)
640aAC                                +  ' actualCatchWeight="'
640aAC                                +  %TrimL(%editc(orpwgt:'P'))
640aAC                                +  '"'
640aAC                   endif
     *
     C                   endsl
     *
650eA*  Set GS1 item level flags
650eA*
650eA*    Set flags to N if not batch pick item
650eA*
650eAC                   eval      gs1item = 'N'
650eAC                   eval      gs1uniq = 'N'
650jDC**   keyom         chain     orddm
650jDC**                 if        %found(orddm)
650jDC**                           and %subst(ommsc1:1:1) = 'Y'
650jAC                   exsr      getZoneOpts
650jAC                   if        opptyp = 'B'
650eAC                   if        $ifucicde = '2' or
650eAC                             $ifucicde = '3'
650eAC                   eval      gs1item = 'Y'
650eAC                   endif
650eAC                   if        $ifucicde = '2'
650eAC                   eval      gs1uniq = 'Y'
650eAC                   endif
650eAC                   endif
650eAC                   eval      ItemStr = %Trim(ItemStr)
650eAC                                +  ' gs1Item="'
650eAC                                +  %Trim(gs1item)
650eAC                                +  '"'
650eAC                   eval      ItemStr = %Trim(ItemStr)
650eAC                                +  ' gs1Unique="'
650eAC                                +  %Trim(gs1uniq)
650eAC                                +  '"'
     *
     C                   endsr

     *-------------------------------------------------------------------------
     *
     *  ZZCW   Calculate catchweight min and max
     *
     C     zzcw          begsr
     *
     C                   eval      ilvar = 0
     C                   eval      ihvar = 0
     C                   eval      ilrng = 0
     C                   eval      ihrng = 0
     C                   eval      prg1c = *zeros
     C                   eval      prg2c = *zeros
     *
     C                   if        $imrg1c <> 0
     C     $imrg1c       div       100           prg1c
     C                   endif
     *
     C                   if        $imrg2c <> 0
     C     $imrg2c       div       100           prg2c
     C                   endif
     *
     C                   if        prg1c = 0
     C     oprg1c        div       100           prg1c
     C                   endif
     *
     C                   if        prg2c = 0
     C     oprg2c        div       100           prg2c
     C                   endif
     *
     C                   if        prg1c > 0
     C                   eval      ilvar = $itswgt * prg1c
     C                   endif
     C                   eval      ilrng = $itswgt - ilvar
     C                   if        prg2c > 0
     C                   eval      ihvar = $itswgt * prg2c
     C                   endif
     C                   eval      ihrng = $itswgt + ihvar
     *
     C                   endsr

     *----------------------------------------------------------------
     *  zzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzdricop      begsr
     C                   eval      error = *off

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $item         parm      $item         $dridata
     C     $item2        parm      $item2        $dridata2

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C                   endsl

     C     enddricop     endsr

     *-------------------------------------------------------------------------
650cA*  ZZEND   End timer
650cA*
650cAC     zzend         begsr
     *
     C                   if        wrtChunk = *off and
     C                             $tpgm <> '*TRAXXML  '
     C                   goto      endzze
     C                   endif
     *
     C                   eval      rttwhs = $pwhse
     C                   eval      rttrid = $prtid
     *
     C                   select
     *
     C                   when      $tpgm = '*TRAXXML  '
     C                   eval      rttpgm = svpgm
     C                   eval      rttsdt = svdte
     C                   eval      rttstm = svtim
     *
     C                   when      $tpgm = 'TR810A    '
     C                   eval      rttpgm = svpgmA
     C                   eval      rttsdt = svdteA
     C                   eval      rttstm = svtimA
     *
     C                   when      $tpgm = 'TR810B    '
     C                   eval      rttpgm = svpgmB
     C                   eval      rttsdt = svdteB
     C                   eval      rttstm = svtimB
     *
     C                   when      $tpgm = 'TR810C    '
     C                   eval      rttpgm = svpgmC
     C                   eval      rttsdt = svdteC
     C                   eval      rttstm = svtimC
     *
     C                   when      $tpgm = 'TR810D    '
     C                   eval      rttpgm = svpgmD
     C                   eval      rttsdt = svdteD
     C                   eval      rttstm = svtimD
     *
     C                   when      $tpgm = 'TR810E    '
     C                   eval      rttpgm = svpgmE
     C                   eval      rttsdt = svdteE
     C                   eval      rttstm = svtimE
     *
     C                   when      $tpgm = 'TR810F    '
     C                   eval      rttpgm = svpgmF
     C                   eval      rttsdt = svdteF
     C                   eval      rttstm = svtimF
     *
700aAC                   when      $tpgm = 'TR810G    '
700aAC                   eval      rttpgm = svpgmG
700aAC                   eval      rttsdt = svdteG
700aAC                   eval      rttstm = svtimG
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
     *-------------------------------------------------------------------------
650cA*  ZZSTRT  Start timer
650cA*
650cAC     zzstrt        begsr
     *
     C                   select
     *
     C                   when      $tpgm = '*TRAXXML  '
     C                   eval      svpgm  = $tpgm
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      svdte  = $cvd8o
     C                   time                    svtim
     *
     C                   when      $tpgm = 'TR810A    '
     C                   eval      svpgmA = $tpgm
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      svdteA = $cvd8o
     C                   time                    svtimA
     *
     C                   when      $tpgm = 'TR810B    '
     C                   eval      svpgmB = $tpgm
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      svdteB = $cvd8o
     C                   time                    svtimB
     *
     C                   when      $tpgm = 'TR810C    '
     C                   eval      svpgmC = $tpgm
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      svdteC = $cvd8o
     C                   time                    svtimC
     *
     C                   when      $tpgm = 'TR810D    '
     C                   eval      svpgmD = $tpgm
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      svdteD = $cvd8o
     C                   time                    svtimD
     *
     C                   when      $tpgm = 'TR810E    '
     C                   eval      svpgmE = $tpgm
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      svdteE = $cvd8o
     C                   time                    svtimE
     *
     C                   when      $tpgm = 'TR810F    '
     C                   eval      svpgmF = $tpgm
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      svdteF = $cvd8o
     C                   time                    svtimF
     *
700aAC                   when      $tpgm = 'TR810G    '
700aAC                   eval      svpgmG = $tpgm
700aAC                   eval      $cvcmd = '*CURCMD '
700aAC                   call      @cvtdt
700aAC                   parm                    $cvtdt
700aAC                   eval      svdteG = $cvd8o
700aAC                   time                    svtimG
     *
     C                   endsl
     *
     C     endzzs        endsr
     *-------------------------------------------------------------------------
     *
640bM*  ZZWRTDEPTSUMM  Write Department Summary records
     *
640bMC     zzWrtDeptSumm begsr
     *
640bM*  Write start tag Department Summary record
     *
640bMC                   eval      line = '<DepartmentSummary>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
640bM*  Write Department record
     *
640bMC                   eval      line = '<department>'
640bMC                                +  %Trim(rswhdp)
640bMC                                +  '</department>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
640bM*  Write Department Summary Cube record
     *
     C                   eval      line = '<cube>'
640bMC                                +  %TrimL(%editc(rspckc:'P'))
     C                                +  '</cube>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
640bM*  Write Department Summary Weight record
     *
     C                   eval      line = '<weight>'
640bMC                                +  %TrimL(%editc(rspckw:'P'))
     C                                +  '</weight>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
640bM*  Write Department Summary Pieces record
     *
     C                   eval      line = '<pieces>'
640bMC                                +  %TrimL(%editc(rspckp:'P'))
     C                                +  '</pieces>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
640bM*  Write end tag Department Summary record
     *
640bMC                   eval      line = '</DepartmentSummary>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     C                   endsr

     *-------------------------------------------------------------------------
     *
     *  ZZWRTCONFIG  Write Configuration record
     *
     C     zzWrtConfig   begsr
     *
     C                   eval      line = '<Configuration wsIP="'
     C                                +  %Trim(optwsi)
     C                                +  '" wsPort="'
     C                                +  %TrimL(%editc(optwsp:'P'))
     C                                +  '" driverFieldType="'
     C                                +  %Trim(optdft)
     C                                +  '" routeFieldType="'
     C                                +  %Trim(optrft)
     C                                +  '" capitalizeInput="'
     C                                +  %Trim(optcap)
     C                                +  '" doubleClickDelivery="'
     C                                +  %Trim(optdbl)
     C                                +  '" entryKeyDelivery="'
     C                                +  %Trim(optekd)
     C                                +  '" deliveryAfterReturn="'
     C                                +  %Trim(optdar)
     C                                +  '" includeItemDB="'
     C                                +  %Trim(optidb)
     C                                +  '" breakDownsAllowed="'
     C                                +  %Trim(optbda)
     C                                +  '" genericBreakDownAllowed="'
     C                                +  %Trim(optgbd)
     C                                +  '" preTripQuestions="'
     C                                +  %Trim(optrtq)
     C                                +  '" postTripQuestions="'
     C                                +  %Trim(optotq)
     C                                +  '" creditCardEnabled="'
     C                                +  %Trim(optcce)
     C                                +  '" signatureEnabled="'
     C                                +  %Trim(optsig)
     C                                +  '" printInvoice="'
     C                                +  %Trim(optpiv)
     C                                +  '" sendDataAfterStop="'
     C                                +  %Trim(optsda)
     C                                +  '" saveLoginInfo="'
     C                                +  %Trim(optsli)
     C                                +  '" orderNumberFieldType="'
     C                                +  %Trim(optoft)
     C                                +  '" catchWeightRequired="'
     C                                +  %Trim(optcwr)
     C                                +  '" saveDays="'
     C                                +  %TrimL(%editc(optsvd:'P'))
     C                                +  '" client="'
     C                                +  %Trim(client)
     C                                +  '" clientLoc="'
     C                                +  %Trim(clientloc)
     C                                +  '" envRuntime="'
     C                                +  %Trim(optert)
     C                                +  '" envDevice="'
     C                                +  %Trim(optedv)
     C                                +  '" envOS="'
     C                                +  %Trim(opteos)
     C                                +  '" envScreenWidth="'
     C                                +  %TrimL(%editc(optesw:'P'))
     C                                +  '" envScreenHeight="'
     C                                +  %TrimL(%editc(optesh:'P'))
     C                                +  '" addReturnEnabled="'
     C                                +  %Trim(optare)
640aAC                                +  '" iconDelivery="'
640aAC                                +  %Trim(optidl)
640aAC                                +  '" doubleClickIcons="'
640aAC                                +  %Trim(optdci)
640fAC                                +  '" palletsEnabled="'
640fAC                                +  %Trim(optpal)
640fAC                                +  '" cradleUploadEnabled="'
640fAC                                +  %Trim(optcra)
640hAC                                +  '" bulkItemsEnabled="'
640hAC                                +  %Trim(optbul)
640hAC                                +  '" displayEmptyStop="'
640hAC                                +  %Trim(opteys)
650dAC                                +  '" saveAfterScan="'
650dAC                                +  %Trim(optsas)
650dAC                                +  '" saveDelay="'
650dAC                                +  %TrimL(%editc(optsdl:'P'))
650dAC                                +  '" syncDateTime="'
650dAC                                +  %Trim(optsdt)
650dAC                                +  '" gs1Scanning="'
650dAC                                +  %Trim(optgss)
650dAC                                +  '" gs1Unique="'
650dAC                                +  %Trim(optgsu)
650dAC                                +  '" leftRightKeysEnabled="'
650dAC                                +  %Trim(optlrk)
650dAC                                +  '" scanBeepVolume="'
650dAC                                +  %TrimL(%editc(optsbv:'P'))
650kAC                                +  '" restartAfterGetRoute="'
650kAC                                +  %Trim(optrag)
650kAC                                +  '" restartDaily="'
650kAC                                +  %Trim(optrd)
650kAC                                +  '" restartDailyTime="'
650kAC                                +  %Trim(optrdtDS)
650kAC                                +  '" filterByDepartment="'
650kAC                                +  %Trim(optfbd)
650kAC                                +  '" nonScanReasonPrompt="'
650kAC                                +  %Trim(optnsr)
650kAC                                +  '" readerFocusMode="'
650kAC                                +  %Trim(optrfm)
650kAC                                +  '" readerFocusPosition="'
650kAC                                +  %Trim(optrfp)
650lAC                                +  '" displayStopFlagsBeforeRestart="'
650lAC                                +  %Trim(optdsf)
650lAC                                +  '" emailReceipt="'
650lAC                                +  %Trim(opter)
650lAC                                +  '" receiptEmailFrom="'
650lAC                                +  %Trim(optref)
650lAC                                +  '" receiptEmailSubject="'
650lAC                                +  %Trim(optres)
650lAC                                +  '" useSystemSuspend'
650lAC                                +  'BatteryPowerTimeout="'
650lAC                                +  %Trim(optsbu)
650lAC                                +  '" systemSuspend'
650lAC                                +  'BatteryPowerTimeout="'
650lAC                                +  %TrimL(%editc(optsb:'P'))
650lAC                                +  '" useSystemSuspend'
650lAC                                +  'ExternalPowerTimeout="'
650lAC                                +  %Trim(optseu)
650lAC                                +  '" systemSuspend'
650lAC                                +  'ExternalPowerTimeout="'
650lAC                                +  %TrimL(%editc(optse:'P'))
650lAC                                +  '" useBackLightOff'
650lAC                                +  'BatteryPowerTimeout="'
650lAC                                +  %Trim(optbbu)
650lAC                                +  '" backLightOff'
650lAC                                +  'BatteryPowerTimeout="'
650lAC                                +  %TrimL(%editc(optbb:'P'))
650lAC                                +  '" useBackLightOff'
650lAC                                +  'ExternalPowerTimeout="'
650lAC                                +  %Trim(optbeu)
650lAC                                +  '" backLightOff'
650lAC                                +  'ExternalPowerTimeout="'
650lAC                                +  %TrimL(%editc(optbe:'P'))
     C                                +  '" />'
     C                   eval      len = %len(%trimr(line))
     C                   callp     writeline(fd: %addr(line): len)
     *
     C                   endsr

     *-------------------------------------------------------------------------
     *
     *  ZZWRTDRIVE  Write Driving Estimations records
     *
     C     zzWrtDrive    begsr
     *
650cAC                   eval      $tpgm = 'TR810D  '
650cAC                   exsr      zzstrt
     *
     *  Write start tag Driving Estimations record
     *
     C                   eval      line = '<DrivingEstimations>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Loop through stops array writing a From Stop record for
     *  each stop, along with To Stop records for all other stops.
     *  Example: if stops 1, 2, and 3 are on the route, the first
     *  From Stop record will be for stop 1, followed by To Stop
     *  records for stops 2 and 3.  The next From Stop record
     *  will be for stop 2, followed by To Stop records for
     *  stops 1 and 3.
     *
     C                   eval      stpcnt = ix1
     C                   eval      ix1 = 0
     C                   dow       ix1 < stpcnt
     C                   eval      ix1 = ix1 + 1
     *
     *  Write start tag From Stop record
     *
     C                   eval      line = '<FromStop stopNumber="'
     C                                +  %TrimL(%editc(stops(ix1):'P'))
     C                                +  '">'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Loop through array and write all To Stop records for this stop
     *
     C                   eval      ix2 = 0
     C                   dow       ix2 < stpcnt
     C                   eval      ix2 = ix2 + 1
     c                   if        stops(ix2) = stops(ix1)
640iAC                             and stpcnt <> 1
     c                   iter
     c                   endif
     *
     *  Write To Stop record
     *
     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      directions    $in
     C                   parm      *blanks       $out
     *
     C                   eval      line = '<ToStop stopNumber="'
     C                                +  %TrimL(%editc(stops(ix2):'P'))
     C                                +  '" miles="'
     C                                +  %TrimL(%editc(miles:'P'))
     C                                +  '" estimatedTravelTime="'
     C                                +  %Trim(%char(traveltime))
     C                                +  '.00'
     C                                +  '" directions="'
     C                                +  %Trim($out)
     C                                +  '" />'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     c                   enddo
     *
     *  Write end tag From Stop record
     *
     C                   eval      line = '</FromStop>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     c                   enddo
     *
     *  Write end tag Driving Estimations record
     *
     C                   eval      line = '</DrivingEstimations>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
650cAC                   eval      $tpgm = 'TR810D  '
650cAC                   exsr      zzend
     *
     C                   endsr
     *
     *-------------------------------------------------------------------------
650eA*
650eA*  ZZWRTGTIN   Write GTIN/s for item, if any.
650eA*
650eAC     zzWrtGTIN     begsr
650eA*
     *
     C     keyupc2       setll     upc2
     C                   dou       forevr <> forevr
     C     keyupc2       reade     upc2
     C                   if        %eof(upc2)
     C                   leave
     C                   endif
     *  GTIN must be numbers.
     C                   eval      upc14  = %Subst(upupc:7:14)
     C                   eval      upc18  = %Subst(upupc:3:18)
     C                   eval      *in81 = *off
     C     numbers       check     upc18                                81
     *  IN81 = *off for upc18, GTIN# equals the rightmost 18 chars of upc code.
     C                   if        *in81 = *off
     C                   eval      gtin# = upc18
     C                   else
     C     numbers       check     upc14                                81
     *  IN81 = *off for upc14, GTIN# equals the rightmost 14 chars of upc code.
     C                   if        *in81 = *off
     C                   eval      gtin# = upc14
     C                   endif
     C                   endif
     *
     *  If GTIN# not blank, write record
     *
     C                   if        GTIN# <> *blanks
650jMC                   eval      line = '<GTIN number="'
     C                                +  %Trim(gtin#)
     C                                +  '" hasOpCode="N"'
     C                                +  ' />'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     c                   endif
     *
     c                   enddo
650jA*
650jA*  Write end tag Item record after last GTIN
650jA*
650jAC                   eval      line = '</Item>'
650jAc                   eval      len = %len(%trimr(line))
650jAc                   callp     writeline(fd: %addr(line): len)
     *
     C                   endsr

     *-------------------------------------------------------------------------
     *
     *  ZZWRTITEM   Write item records (non-tote items).
     *
     C     zzWrtItem     begsr
     *
     *  Calc cube, wgt, & pcs for this unique piece# (aka scanID)
     *
     C                   eval      ordp_cub = 0
     C                   eval      ordp_wgt = 0
     C                   eval      ordp_pcs = 0
     C                   eval      ordp_cub = lwucub * orpscn
     C                   eval      ordp_wgt = lwuwgt * orpscn
     C                   eval      ordp_pcs = orpscn
     *
     *  Get PLTSUM12 unload sequence for this item ...
     *  If it's a gen 2 or higher rec, will have to go get the unload
     *  sequence for its merge record
     *
     C                   clear                   psrec
     c                   select
     c                   when      lwgen < 2
     c                   eval      hld_trn  = lwtrn#
     c                   eval      hld_plid = lwpal#
     c     keyps12       chain     pltsum12

     c                   other
     c     keywrklb7     chain     worklbl7
     c                   if        %found(worklbl7)
     c                   eval      hld_trn  = lb7_lwtrn#
     c                   eval      hld_plid = lb7_lwpal#
     c     keyps12       chain     pltsum12
     c                   endif
     c                   endsl
     *
     *  Get PIRITEM data for this item
     *
     C                   exsr      getItem
     *
     *  Move order and customer order number for this item into
     *  string fields
     *
     C                   eval      hld_ohord  = ohord
     C                   eval      hld_ohcord = ohcord
     *
     *  Build string of common Item elements
     C                   exsr      zzBldItemStr
     *
     *  Write Item record
     *
650jAC                   if        gs1item <> 'Y'
     *
650jA*    This is not a gs1 item, close the item element
     C                   eval      line = '<Item '
     C                                +  %Trim(ItemStr)
     C                                +  ' />'
     *
650jAC                   else
650jA*
650jA*    This is a gs1 item, do not close the item element
650jAC                   eval      line = '<Item '
650jAC                                +  %Trim(ItemStr)
650jAC                                +  ' >'
650jA*
650jAC                   endif
     *
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)

     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZWRTRTNCODE  Write Returns Code records
     *
     C     zzWrtRtnCode  begsr
     *
650cAC                   eval      $tpgm = 'TR810F  '
650cAC                   exsr      zzstrt
     *
     *  Write start tag Return Codes record
     *
     C                   eval      line = '<ReturnCodes>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Loop through and write Return Code records
     *
     C     *loval        setll     rtncode
     C                   dou       forevr <> forevr
     C                   read      rtncode
     c                   if        %eof(rtncode)
     C                   leave
     C                   endif
     *
     *  Write Return Code record
     *  Send alpha fields thru CVTTEXT and save them for output.
     *
     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      rncode        $in
     C                   parm      *blanks       $out
     C                   eval      sv_rncode = $out

     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      rndesc        $in
     C                   parm      *blanks       $out
     C                   eval      sv_rndesc = $out

     C                   eval      line = '<ReturnCode code="'
     C                                +  %Trim(sv_rncode)
     C                                +  '" description="'
     C                                +  %Trim(sv_rndesc)
     C                                +  '" />'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     c                   enddo
     *
     *  Write end tag Return Codes record
     *
     C                   eval      line = '</ReturnCodes>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
650cAC                   eval      $tpgm = 'TR810F  '
650cAC                   exsr      zzend
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZWRTSTOP   Write Stop data
     *
     C     zzWrtStop     begsr
     *
     C     keywlbfi      setll     worklbfi
     C                   dou       forevr <> forevr
     C     keywlbfi      reade     worklbfi
     C                   if        %eof(worklbfi)
     C                   leave
     C                   endif
     C                   if        lwtype <> 'O'  and
     C                             lwtype <> 'B'
     C                   iter
     C                   endif
     *
     C                   eval      totstpc = totstpc + lbcube
     C                   eval      totstpw = totstpw + lbswgt
     C                   eval      totstpp = totstpp + lbqpck
     *
     c                   enddo
     *
     *  Write start tag Stop record
     *
     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      ohcnam        $in
     C                   parm      *blanks       $out

     C                   eval      line = '<Stop '
     C                                +  'stopNumber="'
     C                                +  %TrimL(%editc(ohstop:'P'))
     C                                +  '" cube="'
     C                                +  %TrimL(%editc(totstpc:'P'))
     C                                +  '" weight="'
     C                                +  %TrimL(%editc(totstpw:'P'))
     C                                +  '" pieces="'
     C                                +  %TrimL(%editc(totstpp:'P'))
650fAC                                +  '" customerNumber="'
650fAC                                +  %TrimL(%editc(ohcust:'P'))
     C                                +  '" customerName="'
     C                                +  %Trim($out)
     C                                +  '">'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write start tag Delivery Address record
     *
     C                   eval      line = '<DeliveryAddress>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Company Name record
     *
     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      ohcnam        $in
     C                   parm      *blanks       $out
     C                   eval      line = '<companyName>'
     C                                +  %Trim($out)
     C                                +  '</companyName>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Address Line 1 record
     *
     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      ohcad1        $in
     C                   parm      *blanks       $out
     C                   eval      line = '<addressLine1>'
     C                                +  %Trim($out)
     C                                +  '</addressLine1>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Address Line 2 record
     *
     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      ohcad2        $in
     C                   parm      *blanks       $out
     C                   eval      line = '<addressLine2>'
     C                                +  %Trim($out)
     C                                +  '</addressLine2>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write City record
     *
     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      ohccty        $in
     C                   parm      *blanks       $out
     C                   eval      line = '<city>'
     C                                +  %Trim($out)
     C                                +  '</city>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write start tag State Provinces record
     *
     C                   eval      line = '<StateProvinces>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write State record
     *
     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      ohcst         $in
     C                   parm      *blanks       $out
     C                   eval      line = '<state>'
     C                                +  %Trim($out)
     C                                +  '</state>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write end tag Start Provinces record
     *
     C                   eval      line = '</StateProvinces>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Zip Code record
     *
     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      ohczip        $in
     C                   parm      *blanks       $out
     C                   eval      line = '<zipCode>'
     C                                +  %Trim($out)
     C                                +  '</zipCode>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write end tag Delivery Address record
     *
     C                   eval      line = '</DeliveryAddress>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write start tag Contact Person record
     *
     C                   eval      line = '<ContactPerson>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Contact First Name record
     *
     C                   eval      line = '<firstName>'
     C                                +  'X'
     C                                +  '</firstName>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Contact Last Name record
     *
     C                   eval      line = '<lastName>'
     C                                +  'X'
     C                                +  '</lastName>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write end tag Contact Person record
     *
     C                   eval      line = '</ContactPerson>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Phone record
     *
     C                   eval      line = '<phone>'
     C                                +  '800-555-1234'
     C                                +  '</phone>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)

     *  Write start tag Items record
     *
     C                   eval      line = '<Items>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)

     *  Zero stop totals for cube, weight, and pieces.
     *
     C                   eval      totstpc = 0
     C                   eval      totstpw = 0
     C                   eval      totstpp = 0
     *
     C                   endsr

     *------------------------------------------------------------------
     *
     *  ZZWRTSTOPFLG  Write Stop Flag records
     *
     C     zzWrtStopFlg  begsr
     *
650cAC                   eval      $tpgm = 'TR810E  '
650cAC                   exsr      zzstrt
     *
     C                   eval      stpFlgCnt = 0
     *
     *  Loop through and write Stop Flag records
     *
650aDC**   keyStpFlg     setll     ttstpflg
650aMC     keyoh_p       setll     ttstpflg
     C                   dou       forevr <> forevr
650aDC**   keyStpFlg     reade     ttstpflg
650aMC     keyoh_p       reade     ttstpflg
     c                   if        %eof(ttstpflg)
     C                   leave
     C                   endif
     *
     *  Write start tag Stop Flags record when the first stop flag
     *  is read.  If there are no stop flags, do not write the
     *  Stop Flags records.
     *
     C                   eval      stpFlgCnt = stpFlgCnt + 1
     C                   if        stpFlgCnt = 1
     C                   eval      line = '<StopFlags>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     C                   endif
     *
     *  Write Stop Flag record
     *  Send alpha fields thru CVTTEXT and save them for output.
     *
650aDc**                 call      'CVTTEXT'
650aDC**                 parm      '*XML      '  $cmd
650aDC**                 parm      ttftyp        $in
650aDC**                 parm      *blanks       $out
650aDC**                 eval      sv_ttftyp = $out

     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      ttfchr        $in
     C                   parm      *blanks       $out
     C                   eval      sv_ttfchr = $out
650bAC                   if        sv_ttfchr = *blanks
650bAC                   eval      sv_ttfchr = '?'
650bAC                   endif

     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      ttfale        $in
     C                   parm      *blanks       $out
     C                   eval      sv_ttfale = $out
650bAC                   if        sv_ttfale = *blanks
650bAC                   eval      sv_ttfale = '?'
650bAC                   endif

650aDc**                 call      'CVTTEXT'
650aDC**                 parm      '*XML      '  $cmd
650aDC**                 parm      ttfico        $in
650aDC**                 parm      *blanks       $out
650aDC**                 eval      sv_ttfico = $out

650aAc                   call      'CVTTEXT'
650aAC                   parm      '*XML      '  $cmd
650aAC                   parm      ttfdsp        $in
650aAC                   parm      *blanks       $out
650aAC                   eval      sv_ttfdsp = $out
650bAC                   if        sv_ttfdsp = *blanks
650bAC                   eval      sv_ttfdsp = '1'
650bAC                   endif

650aDC**                 eval      line = '<StopFlag stopFlagType="'
650aMC                   eval      line = '<StopFlag stopFlagChar="'
650aDC**                              +  %Trim(sv_ttftyp)
650aDC**                              +  '" stopFlagChar="'
     C                                +  %Trim(sv_ttfchr)
     C                                +  '" stopFlagAlert="'
     C                                +  %Trim(sv_ttfale)
650aDC**                              +  '" stopFlagIconName="'
650aDC**                              +  %Trim(sv_ttfico)
650aAC                                +  '" stopFlagDisplayTime="'
650aAC                                +  %Trim(sv_ttfdsp)
     C                                +  '" stopNumber="'
     C                                +  %TrimL(%editc(ttfstp:'P'))
     C                                +  '" />'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
650aA*  Move on to the next stop/char.
650aA*
650aAC     keyStpFlg     setgt     ttstpflg
     *
     c                   enddo
     *
700aA** Wait and write the end tag Stop Flags record (if there are any
700aA** stop flags) in subr zzWrtStopFlgP
700aA*
700aD** Write end tag Stop Flags record if there are any stop flags.
700aD*
700aDC**                 if        stpFlgCnt > 0
700aDC**                 eval      line = '</StopFlags>'
700aDc**                 eval      len = %len(%trimr(line))
700aDc**                 callp     writeline(fd: %addr(line): len)
700aDC**                 endif
     *
650cAC                   eval      $tpgm = 'TR810E  '
650cAC                   exsr      zzend
     *
     C                   endsr
     *
700aA*------------------------------------------------------------------
700aA*
700aA*  ZZWRTSTOPFLGP  Write predefined stop flags by truck
700aA*                 for each stop
700aA*
700aAC     zzWrtStopFlgP begsr
700aA*
     C                   eval      $tpgm = 'TR810G  '
     C                   exsr      zzstrt
     *
     *  Loop through stops
     *
     C     keyoh_p       setll     ordh9
     C                   dou       forevr <> forevr
     C     keyoh_p       reade     ordh9
     C                   if        %eof(ordh9)
     C                   leave
     C                   endif
     *
     *    Stop should never be blank, but iter if it is
     *
     C                   if        ohstop = 0
     c                   iter
     C                   endif
     *
     *  Write predefined stop flags by truck for each stop
     *
     C     keytrkfl      setll     tttrkflg
     C                   dou       forevr <> forevr
     C     keytrkfl      reade     tttrkflg
     c                   if        %eof(tttrkflg)
     C                   leave
     C                   endif
     *
     *  Write start tag Stop Flags record when the first stop flag
     *  is read, if any.
     *
     C                   eval      stpFlgCnt = stpFlgCnt + 1
     C                   if        stpFlgCnt = 1
     C                   eval      line = '<StopFlags>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     C                   endif
     *
     *  Write Stop Flag record
     *
     C     keyflag       chain     ttflag
     C                   if        not %found(ttflag)
     C                   eval      ttaale = 'Not found'
     C                   endif
     *
     *  Send alpha fields thru CVTTEXT and save them for output.
     *
     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      ttkchr        $in
     C                   parm      *blanks       $out
     C                   eval      sv_ttkchr = $out
     C                   if        sv_ttkchr = *blanks
     C                   eval      sv_ttkchr = '?'
     C                   endif

     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      ttaale        $in
     C                   parm      *blanks       $out
     C                   eval      sv_ttaale = $out
     C                   if        sv_ttaale = *blanks
     C                   eval      sv_ttaale = '?'
     C                   endif

     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      ttkdsp        $in
     C                   parm      *blanks       $out
     C                   eval      sv_ttkdsp = $out
     C                   if        sv_ttkdsp = *blanks
     C                   eval      sv_ttkdsp = '1'
     C                   endif

     C                   eval      line = '<StopFlag stopFlagChar="'
     C                                +  %Trim(sv_ttkchr)
     C                                +  '" stopFlagAlert="'
     C                                +  %Trim(sv_ttaale)
     C                                +  '" stopFlagDisplayTime="'
     C                                +  %Trim(sv_ttkdsp)
     C                                +  '" stopNumber="'
     C                                +  %TrimL(%editc(ohstop:'P'))
     C                                +  '" />'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Move on to the next stop/char.
     *
     c                   enddo
     *
     *  Move on to the next stop.
     *
     C     keywlbfi      setgt     ordh9
     c                   enddo
     *
     *
     *  Write end tag Stop Flags record if there are any stop flags.
     *
     C                   if        stpFlgCnt > 0
     C                   eval      line = '</StopFlags>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     C                   endif
     *
     C                   eval      $tpgm = 'TR810G  '
     C                   exsr      zzend
     *
     C                   endsr
     *
     *------------------------------------------------------------------
     *
640bM*  ZZWRTSUMM  Write Summary, Department Summary, and Total records
     *
     C     zzWrtSumm     begsr
     *
650cAC                   eval      $tpgm = 'TR810C  '
650cAC                   exsr      zzstrt
     *
     *  Write start tag Summary record
     *
     C                   eval      line = '<Summary>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
640bM*  Loop through and write Department Summary records
     *
640bMC     keyoh_p       setll     rtesum
     C                   dou       forevr <> forevr
640bMC     keyoh_p       reade     rtesum
640bMc                   if        %eof(rtesum)
     C                   leave
     C                   endif
640bMc                   if        rspckp <= 0
     C                   iter
     C                   endif
640bMc                   exsr      zzWrtDeptSumm
     *
640bM*  Add department totals to route totals for cube, weight, and pieces.
     *
640bMC                   eval      totrtec = totrtec + rspckc
640bMC                   eval      totrtew = totrtew + rspckw
640bMC                   eval      totrtep = totrtep + rspckp
     *
     c                   enddo
     *
     *  Write Total records
     *
     *  Write start tag Total record
     *
     C                   eval      line = '<Total>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Total Cube record
     *
     C                   eval      line = '<cube>'
     C                                +  %TrimL(%editc(totrtec:'P'))
     C                                +  '</cube>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Total Weight record
     *
     C                   eval      line = '<weight>'
     C                                +  %TrimL(%editc(totrtew:'P'))
     C                                +  '</weight>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Total Pieces record
     *
     C                   eval      line = '<pieces>'
     C                                +  %TrimL(%editc(totrtep:'P'))
     C                                +  '</pieces>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write end tag Total record
     *
     C                   eval      line = '</Total>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write end tag Summary record
     *
     C                   eval      line = '</Summary>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
650cAC                   eval      $tpgm = 'TR810C  '
650cAC                   exsr      zzend
     *
     C                   endsr
     *
     *-----------------------------------------------------------------
     *
     *  ZZWRTTOTE   Write tote records and tote items within the totes
     *
     C     zzWrtTote     begsr

     C     keyord        setll     totehdr2
     C                   dou       forevr <> forevr
     C     keyord        reade     totehdr2
     C                   if        %eof(totehdr2)
     C                   leave
     C                   endif
     *
     *  Move order and customer order number for this tote into
     *  string fields
     *
     C                   eval      hld_ohord  = ohord
     C                   eval      hld_ohcord = ohcord
     *
     *  Tally up cube, wgt, & pcs for this tote by whipping through
     *  LABEL94 for the tote items
     *
     C                   eval      ordp_cub = 0
     C                   eval      ordp_wgt = 0
     C                   eval      ordp_pcs = 0
     C     keywrklb94    setll     label94
     C                   dou       forevr <> forevr
     C     keywrklb94    reade     label94
     C                   if        %eof(label94)
     C                   leave
     C                   endif
     C                   eval      ordp_cub = ordp_cub + lbcube
     C                   eval      ordp_wgt = ordp_wgt + lbswgt
     C                   eval      ordp_pcs = ordp_pcs + lbqpck
     C                   enddo
     *
     *  If all items in this tote have been outed, do not write it, move
     *  on to the next tote.
     *
     C                   if        ordp_pcs = 0
     C                   iter
     C                   endif
     *
     *  Get WORKLBL, ORDP2, PLTSUM12, and PIRITEM data for the tote itself
     *
     C                   clear                   lwrec
     c     tohml#        chain     worklbl
     C                   clear                   orprec2
     c     tohml#        chain     ordp2
     C                   clear                   psrec
     c                   eval      hld_trn  = tohmt#
     c                   eval      hld_plid = tohmpi
     c     keyps12       chain     pltsum12
     C                   exsr      getItem
     *
     *  Build string of common Item elements
     C                   exsr      zzBldItemStr
     *
     *  Write start tag Tote record
     *
     C                   eval      line = '<Tote toteName="'
     C                                +  %Trim(sv_item)
     C                                +  '" '
     C                                +  %Trim(ItemStr)
     C                                +  '>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Loop through worklb94 and write tote item records
     *
     C     keywrklb94    setll     worklb94
     C                   dou       forevr <> forevr
     C     keywrklb94    reade     worklb94
     C                   if        %eof(worklb94)
     C                   leave
     C                   endif
     *
     *  Get ORDP2 data for the tote item
     *
     C                   clear                   orprec2
     c     lwlbl#        chain     ordp2
     c                   if        %found(ordp2)
     C                   eval      ordp_cub = lwucub * orpscn
     C                   eval      ordp_wgt = lwuwgt * orpscn
     C                   eval      ordp_pcs = orpscn
     c                   else
     C                   eval      ordp_pcs = 0
     c                   endif
     *
     *  If this tote item has been outed, do not write it, move on to the
     *  next tote item.
     *
     C                   if        ordp_pcs = 0
     C                   iter
     C                   endif
     *
     *  Get order and customer order number for the tote item,
     *  as all items within the tote may not be from the same order.
     *
     C                   eval      hld_ohord  = 0
     C                   eval      hld_ohcord = 0
     c     keyoh         chain     ordh
     c                   if        %found(ordh)
     C                   eval      hld_ohord  = oh_ohord
     C                   eval      hld_ohcord = oh_ohcord
     c                   endif
     *
     *  Get PIRITEM data for the tote item
     *
     C                   exsr      getItem
     *
     *  Build string of common Item elements
     C                   exsr      zzBldItemStr
     *
     *  Write Item record for tote item
     *
     C                   eval      line = '<Item '
     C                                +  %Trim(ItemStr)
     C                                +  ' />'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     C                   enddo
     *
     *  Write end tag Tote record
     *
     C                   eval      line = '</Tote>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     c                   enddo

     C                   endsr

      /free

       //---------------------------------------------------------------
       //  getcurrstamp  Get current timestamps
       //---------------------------------------------------------------

       begsr getCurrStamp;

         getmicrotime(currstampuc:currstampsys);
         currstamploc = currstampsys + %hours(bfcoffset);

       endsr;

       //---------------------------------------------------------------
       //  getOptions    Get options
       //---------------------------------------------------------------

       begsr getOptions;

       //  get *TRAX options

         keyop.opWhse = $pwhse;
         keyop.opCode = '*TRAX   ';

         chain %kds(keyop) Options;

         if not %found;
650lM      opdta  = ' ';
         else;
650lM      opdta  = opdata;
         endif;

650lA
650lA  //  get *TRAX1 options
650lA
         keyop.opWhse = $pwhse;
         keyop.opCode = '*TRAX1  ';

         chain %kds(keyop) Options;

         if not %found;
           opdta1  = ' ';
         else;
           opdta1  = opdata;
         endif;


650lA
650lA  //  get *TRAX2 options
650lA
         keyop.opWhse = $pwhse;
         keyop.opCode = '*TRAX2  ';

         chain %kds(keyop) Options;

         if not %found;
           opdta2  = ' ';
         else;
           opdta2  = opdata;
         endif;


       //  get *SYSTEM options

         keyop.opWhse = 0;
         keyop.opCode = '*SYSTEM ';

         chain %kds(keyop) Options;

         if not %found;
         opcapc = 'Y';
         opwrncr = 'N';
         oprg1c = 0;
         oprg2c = 0;
         opicwr = 'N';
       endif;

       endsr;

       //---------------------------------------------------------------
       //  setLogTime    Set appropriate log time fields
       //---------------------------------------------------------------

       begsr setLogTime;

         exsr getCurrStamp;

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

       endsr;

       //---------------------------------------------------------------
       //  updateTTLog   Update log
       //---------------------------------------------------------------

       begsr updateTTLog;

650iA    keyttr.ttrWhs = $pwhse;
650iA    keyttr.ttrRti = $prtid;
650iA    ttrser = *blanks;

650iA    chain %kds(keyttr) TTrte;
650iA    ttlSer = ttrSer;

         keyttl.ttlWhse = $pwhse;
         keyttl.ttlRtid = $prtid;
         keyttl.ttlTry  = 1;

         chain %kds(keyttl) TTlog;

         if not %found;
         exsr writeTTLog;
         else;

         ttlStatus = logStatus;
         ttlErrCode = logErrCode;
         ttlErrMsg  = logErrMsg;

         exsr setLogTime;

         update(e) ttlrec;

       endif;
       endsr;

       //---------------------------------------------------------------
       //  writeTTLog   Write log record
       //---------------------------------------------------------------

       begsr writeTTLog;

         clear ttlRec;

         ttlWhse = $pWhse;
         ttlRtid = $prtid;
         ttlRte  = rhrte;
         ttlTry = 1;
         ttlStatus = logStatus;
         ttlFileSnd = sFileSnd;
         ttlErrCode = logErrCode;
         ttlErrMsg  = logErrMsg;

         exsr setLogTime;

         write(e) ttlrec;

       endsr;

      /end-free

     *
     *----------------------------------------------------------------
     *          IFS Procedure API's / Error Handling
     *----------------------------------------------------------------
      /define errno_load_procedure
      /copy qcopysrc,errno_h

     *-------------------------------------------------------------------------
     *  COMPILE TIME TABLES
     *-------------------------------------------------------------------------
**  recval
<?xml version="1.0" encoding="UTF-8" ?>
<route xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:noNamespaceSchemaLocation="http://
