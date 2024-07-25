      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PFILE     Truck build picking labels - Export file method
     *  29 August 2000
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
414 A*    08/29/00  DAS  4.14
     *      - Created
     *      - Includes changes made to PLBL40 through 4.13
     *
414aA*    09/13/00  DAS  4.14a
     *      - Field LBECWF added to file EXPFPLBL.
     *      - Revised routine FILLB2 to initialize new field.
     *
530 A*    03/31/10  MLB  5.30
     *      - Fix: Revised program to skip PLTSUM3 records
     *        with zero transaction numbers.
530aA*    05/24/10  MLB  5.30a
     *      - Enh: Revised program to client custom code support.
530bA*    05/24/10  JCJ  5.30b
     *      - Enh: Add *PICKLBA & *PICKLBB.
     *      - Enh: Updated *PICKLBL dspecs
720a *    03/28/18  RTR  7.20a
     *      - Enh: Adding pallet section.
     *
750aA*    08/05/21  MLB  7.50a  ZD# 4897
     *      - Fix: Revised routine PRTXDK to add logic to iter when a
     *        2nd label record was read. This was happening when
     *        a sub was added to the pallet that had the XDK item(s).
     *        Found at Panos Foods.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Chef's Warehouse/Dairyland
     *
DRY A*    12/17/13  RTR  DRY
     *      - Revised program to place UOM fields in last 6 pos of lbepak.
DRYbA*    02/11/14  RTR  DRYb
     *      - Revised to only write one record per order line.
DRYcA*    01/24/17  MLB  DRYc
     *      - Revised DRYb mod to add code to prevent divide by zero
     *        errors when Brkdwn 1 or Brkdwn 2 flag = Y and Brkdwn 1
     *        or Brkdwn 2 qty = 0.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fox River Foods
     *
FRF A*    06/02/10  MLB  FRF
     *      - Revised program to use LABEL32D so pick labels are
     *        sent to Host in correct order. Dept DRY before CLR then
     *        all other depts.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Agar Supply Foods
     *
ASC A*    03/29/12  RTR  ASC
     *      - Added call to Lucas Export process
RFS A*    11/21/12  RTR  RFS
     *      - change to pallet number in export.
RFSaA*    06/19/15  MLB  RFSa
     *      - Revised pgm to use LF, PLTSUM3RP which puts PSTRN# ahead
     *        of PSUNLD. This is needed when Pallet Label Option is set
     *        to S=SidebySide (which is really by column).
RFSb *    01/26/16  RTR  RFSb
     *      - Revised to send *SP/#SP from OHMISC back in LBEPAK.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    The structure of this program is similar to the normal label
     *    printing programs PLBL40 and PFMT. However, instead of
     *    printing labels, a record is written to the export file.
     *
     *    Main differences between printing and writting to a file:
     *
     *      1) No header or summary records are written to the file.
     *      2) An individual record is written for each merge record.
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
RFSaAFpltsum3rp if   e           k disk    rename(psrec : psrec3rp)
     Fpltstp1   if   e           k disk
     FLabel31   if   e           k disk
     FLabel32   if   e           k disk
FRF AFlabel32d  if   e           k disk
DRYbAFlabel93   if   e           k disk    usropn
720aAFlabelps   if   e           k disk
     Foptions   if   e           k disk
530bCFoptionz   if   e           k disk
DRYbAFordh4     if   e           k disk    usropn
DRYbAFordd      if   e           k disk    usropn
DRYbAFpiritem   if   e           k disk    usropn
530bAFtruckh    if   e           k disk
     FLblfmtv   if   e           k disk
     Fexpfplbl  o    e             disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *    General
     *
     D a12             s              1    dim(12)
     D a40             s              1    dim(40)
     D a50             s              1    dim(50)
     D a58             s              1    dim(58)
     D a80             s              1    dim(80)
     *
     *    Input/Output strings
     *
     D sti             s              1    dim(75)
     D sto             s              1    dim(198)
     *
     *    Large Characters
     *
530aA*----------------------------------------------------------------
530aA*  Customer id
530aA*
     D @getcl          c                   const('GETCLIENT')
FRF A /copy qcopysrc,id#FRF
ASC A /copy qcopysrc,id#AGAR
DRY A /copy qcopysrc,id#dairyla
RFS A /copy qcopysrc,id#RFS
530aA*
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
     *
     * Data structure
     *
     D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opten2               117    117
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
     D  dsscub                 3      8  3
     D  dsswgt                 9     15  2
     D  dsspcs                16     19  0
     D  dsscnm                20     59
     *----------------------------------------------------------------
     *  Pallet summary data structure for one set of labels.
     *
     D palsum          ds                  occurs(9)
     D  dsppal                 1      7  0
     D  dspstp                 8      9  0
     D  dspcub                10     15  3
     D  dspwgt                16     22  2
     D  dsppcs                23     25  0
     D  stp                   26     43  0
     D                                     DIM(9)
     D  dsppli                44     50  0
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
     D  dszstp                 1      2  0
     D  dszpcs                 3      7  0
     D  dszitm                 8     22
     D  dszdsc                23     52
     D  dszplt                53     59  0
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
530bA*    OPTAXR  -  Include in Tax Right (Y=Yes, N=No).
530bA*    OPCHKR  -  Include in Check Right (Y=Yes, N=No).
     *
     * Data structure
     *
530bD *** opzdta          ds
530bMD opdta2          ds
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
530bAD  opaisl                85     85
530bAD  optaxr                86     86
530bAD  opchkr                87     87
     D  optend               117    117
     *----------------------------------------------------------------
530bA*  *PICKLBA -  Label printing options for the standard pick,
530bA*              retail, and tote labels.
     *
530bA*     08/12/09  RBD  5.20  P#00219
530bA*       - Added record type *PICKLBA which holds printing info
530bA*         for the standard pick, retail, and tote labels.
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
530bA*  *PICKLBB -  Label printing options for the pick list and
530bA*               ASN labels and pick list report.
     *
530bA*     08/12/09  RBD  5.20  P#00219
530bA*       - Added record type *PICKLBB which holds printing info
530bA*         for the pick list and ASN labels and pick list report.
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
     D  opend4               117    117
530bA*----------------------------------------------------------------
530bA*  *PICK  -  Picking options
530bA*
530bA*----------------------------------------------------------------
530bA*
530bA* Fields
530bA*
530bA*    OPNXTP  -  Next pallet number.
530bA*    OPBPCK  -  Bulk pick definition.
530bA*    OPPCUB  -  Maximum cube for PIR.
530bA*    OPFPAL  -  Pallets on fixed fork lift.
530bA*    OPFCUB  -  Maximum cube per fixed pallet.
530bA*    OPFSTP  -  Maximum stops per fixed pallet.
530bA*    OPINCL  -  Include PIR in fixed cube.
530bA*    OPSRCH  -  Number of previous pallets to search for space.
530bA*    OPFBLD  -  Fixed pallet building method.
530bA*                1 = By piece without concern for splitting stop.
530bA*                2 = By stop without splitting stop between plts.
530bA*    OPPBRK  -  Aisle to start new pallet.
530bA*    OPPBLD  -  Pallet building method.
530bA*                1 = By stop then slot location.
530bA*                2 = By slot location then stop.
530bA*                3 = By descening stop, then slot location.
530bA*    OPSELM  -  Selection method.
530bA*                1 = Single pass (By location).
530bA*                2 = Multiple pass (By stop).
530bA*    OPSPLT  -  Allow stop to be split across pallets (Y/N).
530bA*    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
530bA*    OPNWPL  -  Start new pallet when aisle changes if build method
530bA*               is 2=Location.
530bA*    OPFORD  -  Maximun orders per pallet.
530bA*    OPPTYP  -  Pallet type (P=Pallet, T=Tote, B=Batch).
530bA*    OPFTOT  -  Maximum totes per pallet.
530bA*    OPTECB  -  External tote cube.
530bA*    OPTICB  -  Internal tote cube.
530bA*    OPTSTP  -  Maximum stops per tote.
530bA*    OPTPCS  -  Maximum pieces per tote.
530bA*    OPSTOP  -  Honor *SP flag (Y=Yes, N=No).
530bA*    OPGCDE  -  USF Group Code (0-9).
530bA*    OPPKUP  -  Picked up by (S=Selector, L=Loader).
530bA*    OPSPAL  -  Merge pallet should only contain
530bA*               items for single truck pallet (Y=Yes, N=No).
530bA*    OPPITM  -  Maximum items per pallet.
530bA*
530bA* Data structure
530bA*
530bAD opdta1          ds
530bAD  opnxtp                 1      7  0 inz(0)
530bAD  oppcub                10     14  2 inz(0)
530bAD  opfpal                15     15  0 inz(0)
530bAD  opfcub                16     20  2 inz(0)
530bAD  opincl                22     22
530bAD  opsrch                23     24  0 inz(0)
530bAD  opfstp                25     26  0 inz(0)
530bAD  opfbld                27     27  0 inz(0)
530bAD  opbpck                28     30  0 inz(0)
530bAD  oppbrk                31     33
530bAD  oppbld                34     34
530bAD  opselm                35     35
530bAD  opsplt                36     36
530bAD  opbmrg                37     37
530bAD  opnwpl                38     38
530bAD  opford                39     40  0 inz(0)
530bAD  opptyp                41     41
530bAD  opftot                42     43  0 inz(0)
530bAD  optecb                44     48  2 inz(0)
530bAD  opticb                49     53  2 inz(0)
530bAD  optstp                54     55  0 inz(0)
530bAD  optord                56     57  0 inz(0)
530bAD  optpcs                58     60  0 inz(0)
530bAD  opstop                61     61
530bA** Note: Pos 62 is OPGCDE for USF, but OPPKUP for all other clients.
530bAD**opgcde                62     62
530bAD  oppkup                62     62
530bAD  opspal                63     63
530bAD  oppitm                64     67  0 inz(0)
530bAD  opend1               117    117
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
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     * Work Variables
     *----------------------------------------------------------------
     D @pal#           s                   like(pspal#)
     D @qty1           s                   like(w1pick)
     D @qty2           s                   like(w1qty)
     D @var            s              3  0
     D cmbwrd          s              7
     D combo           s              1
     D count           s              5  0
     D curcol          s                   like(pscol)
     D curdte          s              8  0
     D curpal          s              2  0
     D currow          s                   like(psrow)
     D curtim          s              6  0
     D curunl          s                   like(psunld)
RFSaAD curtrn          s                   like(pstrn#)
     D first           s              1
     D first2          s              1
     D forevr          s              1
     D kyltyp          s                   like(lbtype)
     D kytype          s                   like(pstype)
     D kyvnum          s                   like(lfvnum)
     D lbls            s              3  0
     D lstlb#          s                   like(lblbl#)
     D lstpid          s                   like(psplid)
     D lststp          s                   like(lbstop)
     D lsttrn          s                   like(lbtrn#)
     D lstum           s                   like(lbutyp)
     D lstwdp          s                   like(lbwhdp)
     D lstzon          s                   like(psszon)
     D maxsti          s              2  0
     D maxsto          s              3  0
     D outwrd          s              3
     D pal#            s              7  0
     D palcnt          s              2  0
     D prtflg          s              1
     D remain          s              2  0
     D shdcnt          s              3  0
     D ssdcnt          s              3  0
     D ssocur          s              3  0
     D stpcnt          s              2  0
720aAD sectionId       s              2a
720aAD sectionCnt      s              5s 0
     D tmpzon          s                   like(psszon)
     D today           s              8  0
     D totwrd          s              3
     D w1pal#          s                   like(lbpal#)
     D w1pick          s                   like(lbqpck)
     D w1qty           s                   like(lbqpck)
     D w1qty2          s                   like(lbqpck)
     D x1              s              3  0
     D y1              s              3  0
     D zontyp          s              5
     D zpdcnt          s              3  0
     D zpocur          s              3  0
530bAD kycod1          s                   like(opzcod)
530bAD kycod3          s                   like(opzcod)
530bAD kycod4          s                   like(opzcod)
530bAD $ptmpl          s             10
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   Command
     *              *TEST1   -  Print test labels - no merge.
     *              *TEST2   -  Print test labels - merge sample data.
     *              *REPLEN  -  Print potential replenishments.
     *              *CLOSE   -  Close program with *INLR.
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
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
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
     *----------------------------------------------------------------
     *  Main line
     *
     *  See if we are only closing the program.
     *
     C                   if        $pcmd = '*CLOSE  '
     C                   goto      bottom
     C                   endif
ASC A*
ASC A*  Run Agar Lucas Export.
ASC A*
ASC AC                   if        client = agar
ASC AC***                if        $pcmd = '*CLOSE  '
ASC A*
ASC AC                   call      'RH156CL'
ASC AC                   parm                    $pwhse
ASC AC                   parm                    $prtid
ASC AC                   parm                    $prte
ASC A*
ASC AC***                endif
ASC AC                   endif
DRYbA*
DRYbA*  Branch based on customer
DRYbA*
DRYbAC                   select
DRYbAC                   when      client = Dairyland
DRYbAC                   exsr      ExpDairy
DRYbA*
DRYbAC                   other
530bA*
530bA*  Get zone options.
530bA*

530bA*  PCKLBL
530bAC                   eval      opdta2 = opzdta
530bA*
530bAC                   eval      kycod1 = '*PICK   '
530bAC                   eval      opptyp = *blanks
530bAC     opzkey        chain     optionz
530bAC                   if        %found(optionz)
530bAC                   eval      opdta1 = opzdta
530bAC                   endif
530bA*
530bAC                   eval      opdta3 = *blanks
530bAC                   eval      kycod3 = '*PICKLBA'
530bAC     opzkya        chain     optionz
530bAC                   if        %found(optionz)
530bAC                   eval      opdta3 = opzdta
530bAC                   endif
530bA*
530bA* do not print standard pick labels
530bA*
530bAC                   if        oplb1 = 'N'
530bA ***                goto      bottom
530bAC                   endif
530bA*
530bAC                   eval      kycod4 = '*PICKLBB'
530bAC                   eval      opdta4 = *blanks
530bAC     opzkyb        chain     optionz
530bAC                   if        %found(optionz)
530bAC                   eval      opdta4 = opzdta
530bAC                   endif
     *
     *  Get current date and time.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdte = $cvd8o
     C                   time                    curtim
     *
     * Count detail lines of summary labels.
     *
     C                   exsr      cntshd
     C                   exsr      cntssd
     C                   exsr      cntzpd
     *
     * Check to see if this is only a test.
     *
     C                   if        $pcmd = '*TEST1  '  or
     C                             $pcmd = '*TEST2  '
     C                   exsr      test1
     C                   goto      bottom
     C                   endif
     *
     * Print zone heading label.
     *
     C                   exsr      lblzhd
     *
     * Print potential replenishments
     *
     C                   if        $pcmd = '*REPLEN '
     C                   if        opletd = 'Y'
     C                   exsr      prtprp
     C                   endif
     C                   goto      bottom
     C                   endif
     *
     * Print letdowns for zone.
     *
     C                   if        opletd = 'Y'
     C                   exsr      prtrpl
     C                   endif
     *
     * Print bulk picks for zone.
     *
     C                   exsr      prtblk
     *
     * Print selection labels for zone.
     *
     *    Note: First the pallet summary records will be read
     *          and the information saved.  Then, when the
     *          transaction number changes, we go and print
     *          the labels for the previous transacton
     *          number (LSTTRN).
     *
     *    Loop through truck pallets for zone.
     *
     C                   eval      first = *on
     C                   eval      palcnt = 0
     *
     C                   eval      kytype = 'O'
RFSaA*
RFSaAC                   select
RFSaAC                   when      client = RFS
RFSaAC     keyps3        setll     pltsum3rp
RFSaAC                   other
RFSaA*
     C     keyps3        setll     pltsum3
RFSaAC                   endsl
RFSaA*
     C                   dou       forevr <> forevr
RFSaA*
RFSaAC                   select
RFSaAC                   when      client = RFS
RFSaAC     keyps3        reade     pltsum3rp                              79
RFSaAC                   other
RFSaA*
     C     keyps3        reade     pltsum3                                79
RFSaAC                   endsl
RFSaA*
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *     Skip pallet if nothing was picked.
     *
     C                   if        pspcs = 0  or
530 AC                             pstrn# = 0
     C                   iter
     C                   endif
     *
     *     First time through initialization.
     *
     C                   if        first = *on
     C                   eval      lsttrn = pstrn#
     C                   eval      palcnt = 0
     C                   eval      first = *off
     C                   endif
     *
     *     If transaction number changed, go and print the detail
     *       for the previous transaction (LSTTRN).
     *
     C                   if        pstrn# <> lsttrn
RFSaAC                   eval      curtrn = pstrn#
     C                   eval      curunl = psunld
     C                   eval      currow = psrow
     C                   eval      curcol = pscol
     C                   exsr      prtsel
RFSaA*
RFSaAC                   select
RFSaAC                   when      client = RFS
RFSaAC     keyps3rp      setll     pltsum3rp
     C                   read      pltsum3rp                              79
RFSaAC                   other
RFSaA*
     C     keyps         setll     pltsum3
     C                   read      pltsum3                                79
RFSaAC                   endsl
RFSaA*
     C                   eval      lsttrn = pstrn#
     C                   eval      palcnt = 0
     C                   endif
     *
     *     Add pallet info to pallet summary data structure.
     *
     C                   add       1             palcnt
     C     palcnt        occur     palsum
     *
RFS AC*                  if        client = rfs
RFS AC*                  eval      dsppal = palcnt
RFS AC*                  else
     C                   eval      dsppal = pspal#
RFS AC*                  endif
     C                   z-add     pscube        dspcub
     C                   z-add     psswgt        dspwgt
     C                   z-add     pspcs         dsppcs
     C                   eval      dspstp = 0
     C                   eval      lststp = -(1)
     C                   eval      dsppli = psplid
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
     C                   enddo
     *
     C                   enddo
     *
     *   Print last pallet(s), if any.
     *
     C                   if        palcnt > 0
     C                   exsr      prtsel
     C                   endif
     *
DRYbAC                   endsl
     *
     *   Bye, Bye.
     *
     C     bottom        tag
     C                   if        $pcmd = '*CLOSE  '
     C                   eval      *inlr = *on
     C                   else
     C                   return
     C                   endif
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
530aA*
530aA* Get client id.
530aA*
530aAC                   call      @getcl
530aAC                   parm                    client           10
530aAC                   parm                    cliloc           10
530aA*
     C                   eval      forevr = *off
     C                   eval      maxsti = 75
     C                   eval      maxsto = 198
     *
     *  Define key for OPTIONS file.
     *
     C     opkey         klist
     C                   kfld                    opwhse
     C                   kfld                    opcode
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
RFSaA*
RFSaAC     keyps3rp      klist
RFSaAC                   kfld                    $pwhse
RFSaAC                   kfld                    $prtid
RFSaAC                   kfld                    kytype
RFSaAC                   kfld                    $pcomp
RFSaAC                   kfld                    $ptzon
RFSaAC                   kfld                    $pgen
RFSaAC                   kfld                    $pszon
RFSaAC                   kfld                    curtrn
RFSaAC                   kfld                    curunl
RFSaAC                   kfld                    currow
RFSaAC                   kfld                    curcol
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
     *  Define partial key for LABEL33 file.
     *
     C     keyl33        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    lsttrn
     *
     *  Define partial key for LABEL3 file.
     *
     C     keyl3f        klist
     C                   kfld                    $ptrn#
     C                   kfld                    $pwhse
     *
     *  Define key for LBLFMTV file.
     *
     C     keylfv        klist
     C                   kfld                    kyvnum
530bA*
530bA*  Define key for pick options.
530bA*
530bAC     opzkey        klist
530bAC                   kfld                    kycod1
530bAC                   kfld                    $pwhse
530bD ***                kfld                    $ptruk
530bMC                   kfld                    $ptmpl
530bAC                   kfld                    $pszon
530bA*
530bAC     opzkya        klist
530bAC                   kfld                    kycod3
530bAC                   kfld                    $pwhse
530bD ***                kfld                    $ptruk
530bMC                   kfld                    $ptmpl
530bAC                   kfld                    $pszon
     *
530bAC     opzkyb        klist
530bAC                   kfld                    kycod4
530bAC                   kfld                    $pwhse
530bD ***                kfld                    $ptruk
530bMC                   kfld                    $ptmpl
530bAC                   kfld                    $pszon
530bA*
530bA*  Define key for TRUCKH file.
530bA*
530bAC     trkey         klist
530bAC                   kfld                    $pwhse
530bAC                   kfld                    $ptruk
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     *   Define variables.
     *
     *
     *  Get system options.
     *
     C                   eval      opwhse = 0
     C                   eval      opcode = '*SYSTEM '
     C     opkey         chain     options                            79
     C                   if        *in79
     C                   eval      opletd = 'Y'
     C                   endif
     *
     *   Initialize sequence number for transaction.
     *
     C                   eval      lbeseq = 0
530bA*
530bA* Get Zone Template Code if Template type is T=Truck
530bA*
530bAC     trkey         chain     truckh
530bAC                   if        %found(truckh) and thtype = 'T'
530bAC                   eval      $ptmpl =  thztmp
530bAC                   else
530bAC                   eval      $ptmpl =  $ptruk
530bAC                   endif
     *
DRYbA* Open files for Dairyland
DRYbAC                   if        client = dairyland
DRYbA*
DRYbAC                   if        not %open(ordh4)
DRYbAC                   open      ordh4
DRYbAC                   endif
DRYbAC                   if        not %open(ordd)
DRYbAC                   open      ordd
DRYbAC                   endif
DRYbAC                   if        not %open(piritem)
DRYbAC                   open      piritem
DRYbAC                   endif
DRYbAC                   if        not %open(label93)
DRYbAC                   open      label93
DRYbAC                   endif
DRYbA*
DRYbAC                   endif
DRYbA*
DRYbA*   Define partial key for ORDD file.
DRYbAC     keyod         klist
DRYbAC                   kfld                    ohwhse
DRYbAC                   kfld                    ohord
DRYbA*
DRYbA*   Define partial key for ORDH file.
DRYbAC     keyoh         klist
DRYbAC                   kfld                    $pwhse
DRYbAC                   kfld                    $prtid
DRYbA*
DRYbA*   Define partial key for PIRITEM file.
DRYbAC     keyit         klist
DRYbAC                   kfld                    $pwhse
DRYbAC                   kfld                    oditem
DRYbA*
DRYbA*   Define partial key for LABEL93 file.
DRYbAC     key93         klist
DRYbAC                   kfld                    $pwhse
DRYbAC                   kfld                    odord
DRYbAC                   kfld                    oditem
DRYbA*
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CRTSTP  Create stop numbers.
     *
     C     crtstp        begsr
     C                   endsr
DRYbA*----------------------------------------------------------------
DRYbA*
DRYbA*  EXPDAIRY   Export for Dairyland.
DRYbA*
DRYbAC     ExpDairy      begsr
DRYbA*
DRYbAC     keyoh         setll     ordh4
DRYbAC                   dou       forevr <> forevr
DRYbAC     keyoh         reade     ordh4
DRYbAC                   if        %eof(ordh4)
DRYbAC                   leave
DRYbAC                   endif
DRYbA*
DRYbAC     keyod         setll     ordd
DRYbAC                   dou       forevr <> forevr
DRYbAC     keyod         reade     ordd
DRYbAC                   if        %eof(ordd)
DRYbAC                   leave
DRYbAC                   endif
DRYbA*
DRYbAC     keyit         chain     piritem
DRYbAC                   if        not %found(piritem)
DRYbAC                   eval      itwhdp = *blanks
DRYbAC                   eval      ittype = *blanks
DRYbAC                   eval      itdesc = *blanks
DRYbAC                   eval      itpdsc = *blanks
DRYbAC                   eval      itcwgt = 'N'
DRYbAC                   endif
DRYbA*
DRYbAC     key93         setll     label93
DRYbAC                   dou       forevr <> forevr
DRYbAC     key93         reade     label93
DRYbAC                   select
DRYbAC                   when      %eof(label93)
DRYbAC                   eval      lbdisp = *blanks
DRYbAC                   leave
DRYbAC                   when      lbtype = 'O'
DRYbAC                             or lbtype = 'B'
DRYbAC                   leave
DRYbAC                   endsl
DRYbAC                   enddo
DRYbA*
DRYbAC                   eval      $cvcmd = '*CURCMD '
DRYbAC                   call      @cvtdt
DRYbAC                   parm                    $cvtdt
DRYbAC                   eval      curdte = $cvd8o
DRYbAC                   time                    curtim
DRYbA*
DRYbA*   Build export record
DRYbA*
DRYbAC                   eval      lbewhs = $pwhse
DRYbAC                   eval      lberid = $prtid
DRYbAC                   eval      lbezon = *blanks                             per spec
DRYbAC                   eval      lbetyp = *blanks                             per spec
DRYbAC                   eval      lbetr# = 0                                   per spec
DRYbAC                   eval      lbewhd = itwhdp
DRYbAC                   eval      lbeslt = lbdisp
DRYbAC                   eval      lbeitm = oditem
DRYbAC                   eval      lbeitp = ittype
DRYbAC                   eval      lbedsc = itdesc
DRYbAC                   eval      lbepak = itpdsc
DRYbAC                   eval      lbeutp = lbutyp
DRYbAC                   eval      lbeucd = lbucod
DRYbAC                   eval      lbecwf = itcwgt
DRYbAC                   eval      lberte = $prte
DRYbAC                   eval      lbeord = ohcord
DRYbAC                   eval      lbedsq = odseq
DRYbAC                   eval      lbecus = ohcust
DRYbAC                   eval      lbestp = ohstop
DRYbAC                   eval      lbeztp = *blanks                             per spec
DRYbAC                   eval      lbemzn = *blanks                             per spec
DRYbAC                   eval      lbeout = *blanks                             per spec
DRYbAC                   eval      lbecom = *blanks                             per spec
DRYbAC                   eval      lbepl# = lbpal#
DRYbAC                   eval      lbelb# = 0                                   per spec
DRYbAC                   eval      lbedte = curdte
DRYbAC                   eval      lbetim = curtim
DRYbA*
DRYbAC                   select
DRYbAC                   when      odqor1 > 0
DRYbAC                   eval      lbeqty = odqor1
DRYbAC                   eval      lbecub = itcube * odqor1
DRYbAC                   eval      lbewgt = itswgt * odqor1
DRYbA*
DRYbAC                   when      odqor2 > 0
DRYbAC                   eval      lbeqty = odqor2
DRYcA*
DRYcAC                   if        itumq2 > 0
DRYbAC                   eval      lbecub = (itcube / itumq2) * odqor2
DRYbAC                   eval      lbewgt = (itswgt / itumq2) * odqor2
DRYcAC                   else
DRYcA*
DRYcAC                   eval      lbecub = itcube * odqor2
DRYcAC                   eval      lbewgt = itswgt * odqor2
DRYcAC                   endif
DRYbA*
DRYbAC                   when      odqor3 > 0
DRYbAC                   eval      lbeqty = odqor3
DRYcA*
DRYcAC                   if        itumq2 > 0 and itumq3 > 0
DRYbAC                   eval      lbecub =
DRYbAC                               (itcube / (itumq2 * itumq3)) * odqor3
DRYbAC                   eval      lbewgt =
DRYbAC                               (itswgt / (itumq2 * itumq3)) * odqor3
DRYcAC                   else
DRYcA*
DRYcAC                   eval      lbecub = itcube * odqor3
DRYcAC                   eval      lbewgt = itswgt * odqor3
DRYcAC                   endif
DRYbA*
DRYbAC                   endsl
DRYbA*
DRYbAC                   add       1             lbeseq
DRYbAC                   exsr      print
DRYbA*
DRYbAC                   enddo
DRYbAC                   enddo
DRYbA*
DRYbAC                   endsr
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
     *----------------------------------------------------------------
     *
     *  INITSS  Initialize data structure for stop summary
     *
     C     initss        begsr
     C     1             do        ssdcnt        ssocur
     C     ssocur        occur     stpsum
     C                   eval      dssstp = 0
     C                   eval      dsspcs = 0
     C                   eval      dsscub = 0
     C                   eval      dsswgt = 0
     C                   eval      dsscnm = *blanks
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
     C                   enddo
     C                   eval      zpocur = 1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PRINT   Output string to printer.
     *
     C     print         begsr
     C                   eval      prtflg = *off
     C                   write     lberec
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PRTBLK  Print bulk pick labels for route/department.
     *
     C     prtblk        begsr
     C                   eval      tmpzon = *blanks
     *
     C                   eval      first = *on
     *
     *  Loop bulk picks for zone.
     *
     *    Revised to only use a pallet id once.
     *
     C                   eval      lstpid = -(1)
     C                   eval      kytype = 'B'
     C     keyps3        setll     pltsum3
     C                   dou       forevr <> forevr
     C     keyps3        reade     pltsum3                                79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   if        psplid = lstpid  or
530 AC                             pstrn# = 0
     C                   iter
     C                   endif
     C                   eval      lstpid = psplid
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
     *
     *       Print beginning bulk pick label.
     *
     C                   if        first = *on
     ***                  WRITEBEGBULK
     C                   exsr      lblbbk
     C                   eval      first = *off
     C                   endif
     *
     *       Print warning for bulk/replenishment combo.
     *
     *
     *       Print bulk label.
     *
     C                   eval      w1qty = lbqpck
     C                   exsr      crtstp
     ***                  WRITESETHEAD
     ***                  WRITEBULK
     *****                EXSR LBLSHD
     *****                EXSR ZZFILL
     *****                EXSR PRINT
     C                   exsr      lblblk
     *
     *       Print replenishment label if necessary.
     *
     C                   if        lbdsp2 <> *blanks
     C                   eval      w1qty = lbqrmn
     ***                  WRITETRANSFER
     C                   exsr      lblrp1
     C                   endif
     *
     C                   enddo
     *
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PRTPRP  Print potential replenishment labels.
     *
     C     prtprp        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PRTRPL  Print replenishment labels for zone
     *
     C     prtrpl        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PRTSEL  Print normal selection labels for zone.
     *
     C     prtsel        begsr
     C                   eval      tmpzon = *blanks
     *
     *   Print header for this set of selection labels.
     *
     C                   exsr      setbeg
     *
     *   Loop through selection labels for transaction.
     *
     C                   eval      count = 0
     C                   eval      kyltyp = 'O'
     C                   if        $pgen = 1
     *R         KEYL32    SETLLLABEL34
FRF A*
FRF AC                   select
FRF AC                   when      client = FRF
FRF AC     keyl32        setll     label32d
FRF AC                   other
     C     keyl32        setll     label32
FRF AC                   endsl
FRF A*
     C                   else
FRF A*
FRF AC                   select
FRF AC                   when      client = FRF
FRF AC     keyl32        setll     label32d
FRF AC                   other
     C     keyl32        setll     label32
FRF AC                   endsl
FRF A*
     C                   endif
     *
     C                   dou       forevr <> forevr
     C                   if        $pgen = 1
     *R         KEYL32    READELABEL34                  78
FRF A*
FRF AC                   select
FRF AC                   when      client = FRF
FRF AC     keyl32        reade     label32d                               78
FRF AC                   other
     C     keyl32        reade     label32                                78
FRF AC                   endsl
FRF A*
     C                   else
FRF A*
FRF AC                   select
FRF AC                   when      client = FRF
FRF AC     keyl32        reade     label32d                               78
FRF AC                   other
     C     keyl32        reade     label32                                78
FRF AC                   endsl
FRF A*
     C                   endif
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
     *
     C                   add       1             count
     *
     *     See if we should print the "before" um warning.
     *
     C                   if        lbutyp <> 'N'  and
     C                             opuwrb = 'Y'
     ***                  WRITEWARNUMB
     C                   exsr      lblumb
     C                   endif
     *
     *     Initialize label fields.
     *
     C                   eval      w1qty2 = lbqpck
     C                   exsr      crtstp
     *
     *     Force combo label for writing to file
     *
     C                   eval      opclvl = 0
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
     ***                  WRITEWARNCMBB
     C                   exsr      lblcmb
     C                   endif
     *
     *        Print one label.
     *
     C                   eval      w1pick = lbqpck
     ***                  WRITEPICK
     C                   exsr      lblpck
     *
     *        See if we should print the "after" combo warning.
     *
     C                   if        opcwra = 'Y'
     ***                  WRITEWARNCMBA
     C                   exsr      lblcma
     C                   endif
     *
     C                   other
     *
     *     Or print individual labels.
     *
     C                   eval      combo = *off
     C     1             do        lbqpck        w1pick
     ***                  WRITEPICK
     C                   exsr      lblpck
     C                   enddo
     *
     C                   endsl
     *
     *     See if we should print the "after" um warning.
     *
     C                   if        lbutyp <> 'N'  and
     C                             opuwra = 'Y'
     ***                  WRITEWARNUMA
     C                   exsr      lbluma
     C                   endif
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
     C     1             do        lbls
     ***                  WRITECATCHWGT
     C                   exsr      lblcwt
     C                   enddo
     C                   endif
     *
     C                   enddo
     *
     *   Print summary for this set of selection labels.
     *
     C                   exsr      setend
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PRTXDK  Print cross dock labels.
     *
     C     prtxdk        begsr
     C                   eval      tmpzon = 'XDOCK '
     *
     *
     *   Loop through selection labels for transaction.
     *
     C                   eval      count = 0
     C                   eval      kyltyp = 'O'
750aAC                   eval      lstlb# = -(1)
     *
     C                   if        $pgen = 1
     *R         KEYL32    SETLLLABEL34
FRF A*
FRF AC                   select
FRF AC                   when      client = FRF
FRF AC     keyl32        setll     label32d
FRF AC                   other
     C     keyl32        setll     label32
FRF AC                   endsl
FRF A*
     C                   else
FRF A*
FRF AC                   select
FRF AC                   when      client = FRF
FRF AC     keyl32        setll     label32d
FRF AC                   other
     C     keyl32        setll     label32
FRF AC                   endsl
FRF A*
     C                   endif
     *
     C                   dou       forevr <> forevr
     C                   if        $pgen = 1
     *R         KEYL32    READELABEL34                  78
FRF A*
FRF AC                   select
FRF AC                   when      client = FRF
FRF AC     keyl32        reade     label32d                               78
FRF AC                   other
     C     keyl32        reade     label32                                78
FRF AC                   endsl
FRF A*
     C                   else
FRF A*
FRF AC                   select
FRF AC                   when      client = FRF
FRF AC     keyl32        reade     label32d                               78
FRF AC                   other
     C     keyl32        reade     label32                                78
FRF AC                   endsl
FRF A*
     C                   endif
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
750aA*
750aA*     There could be more than one PLTSUM rec for the same pallet,
750aA*     but with a different pstrn#, causing LABEL rec to be read
750aA*     twice in the joined logical LABEL32, so make sure the lblbl#
750aA*     is not equal to the lstlb# before printing.
750aA*
750aAC                   if        lblbl# = lstlb#
750aAC                   iter
750aAC                   endif
750aAC                   eval      lstlb# = lblbl#
     *
     *     Skip label if nothing was picked.
     *
     C                   if        lbqpck = 0
     C                   iter
     C                   endif
     *
     C                   add       1             count
     *
     *   Print warning "Cross dock labels next".
     *
     C                   if        count = 1
     C                   exsr      lblxdb
     C                   endif
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
     C                   exsr      crtstp
     *
     *     Force combo label for writing to file
     *
     C                   eval      opclvl = 0
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
     C                   eval      w1pick = lbqpck
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
     C                   eval      combo = *off
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
     *     Print catch weight labels.
     *
     C                   if        itcwgt = 'Y'  and
     C                             opcwgt <> 0
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
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SETEND  End set of labels.
     *
     C     setend        begsr
     *
     *   Print cross dock labels.
     *
     C                   exsr      prtxdk
     *
     *   Print discrepancy labels.
     *
     *     *** Not when writing to file ***
     *
     *
     *   Print merge summary(s) for transaction.
     *
     *     Loop through selection labels for transaction.
     *
     C                   eval      first2 = *on
     C                   eval      kyltyp = 'M'
     *
     C                   if        $pgen = 1
     **         KEYL32    SETLLLABEL34
FRF A*
FRF AC                   select
FRF AC                   when      client = FRF
FRF AC     keyl32        setll     label32d
FRF AC                   other
     C     keyl32        setll     label32
FRF AC                   endsl
FRF A*
     C                   else
FRF A*
FRF AC                   select
FRF AC                   when      client = FRF
FRF AC     keyl32        setll     label32d
FRF AC                   other
     C     keyl32        setll     label32
FRF AC                   endsl
FRF A*
     C                   endif
     *
     C                   dou       forevr <> forevr
     C                   if        $pgen = 1
     **         KEYL32    READELABEL34                  78
FRF A*
FRF AC                   select
FRF AC                   when      client = FRF
FRF AC     keyl32        reade     label32d                               78
FRF AC                   other
     C     keyl32        reade     label32                                78
FRF AC                   endsl
FRF A*
     C                   else
FRF A*
FRF AC                   select
FRF AC                   when      client = FRF
FRF AC     keyl32        reade     label32d                               78
FRF AC                   other
     C     keyl32        reade     label32                                78
FRF AC                   endsl
FRF A*
     C                   endif
     C                   if        *in78
     C                   leave
     C                   endif
     *
     *       Put together zone from label fields.
     *
     C                   movel     lbwhdp        tmpzon
     C                   move      lbstyp        tmpzon
     *
     C                   exsr      lblzpd
     *
     C                   enddo
     *
     *   Print set summary for transaction.
     *
     *     *** Nothing to do when writing to file ***
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
     *  CNTSHD  Count set header detail lines.
     *
     C     cntshd        begsr
     *
     C                   eval      shdcnt = 0
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
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CNTZPD  Count set zone pickup detail lines.
     *
     C     cntzpd        begsr
     *
     C                   eval      zpdcnt = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILCHR  Fill character variable.
     *
     C     filchr        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILLB1  Process script for single label format.
     *
     C     fillb1        begsr
     *
     *   Standard variables
     *
     C                   eval      @var = 0
     C                   exsr      fillb2
     *
     C                   eval      @var = 2
     C                   exsr      fillb2
     *
     C                   eval      @var = 3
     C                   exsr      fillb2
     *
     C                   eval      @var = 10
     C                   exsr      fillb2
     *
     C                   eval      @var = 11
     C                   exsr      fillb2
     *
     C                   eval      @var = 12
     C                   exsr      fillb2
     *
     C                   eval      @var = 13
     C                   exsr      fillb2
     *
     C                   eval      @var = 15
     C                   exsr      fillb2
     *
     C                   eval      @var = 16
     C                   exsr      fillb2
     *
     C                   eval      @var = 17
     C                   exsr      fillb2
     *
     C                   eval      @var = 18
     C                   exsr      fillb2
     *
     C                   eval      @var = 19
     C                   exsr      fillb2
     *
     C                   eval      @var = 26
     C                   exsr      fillb2
     *
     C                   eval      @var = 35
     C                   exsr      fillb2
     *
     C                   eval      @var = 43
     C                   exsr      fillb2
     *
     C                   eval      @var = 44
     C                   exsr      fillb2
     *
     C                   eval      @var = 45
     C                   exsr      fillb2
     *
     C                   eval      @var = 57
     C                   exsr      fillb2
     *
     *   Non-Standard variables
     *
     C                   eval      @var = 999
     C                   exsr      fillb2
     *
     *   Write record
     *
     C                   add       1             lbeseq
     C                   eval      lbedte = curdte
     C                   eval      lbetim = curtim
720aA
720aAC                   eval      lbepls = *blanks
720aAC                   if        lbhnd2 = '*P'
720aAC                   exsr      PrtSections
720aAC                   else
720aA
     C                   exsr      print
720aA
720aAC                   endif
720aA
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILLB2  Added variable to ouput string.
     *
     C     fillb2        begsr
     *
     C                   if        $pcmd = '*TEST2  '
     C                   eval      kyvnum = @var
     C     keylfv        chain     lblfmtv                            78
     C     *in78         cabeq     *on           endfi2
     C                   endif
     *
     C                   select
     C                   when      @var = 0
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbestp
     C                   else
     C                   eval      lbestp = lbstop
     C                   endif
     *
     C                   when      @var = 1
     *
     C                   when      @var = 2
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbewhs
     C                   else
     C                   eval      lbewhs = $pwhse
     C                   endif
     *
     C                   when      @var = 3
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbecom
     C                   else
     C                   eval      lbecom = $pcomp
     C                   endif
     *
     C                   when      @var = 4
     *
     C                   when      @var = 5
     *
     C                   when      @var = 6
     *
     C                   when      @var = 7
     *
     C                   when      @var = 8
     *
     C                   when      @var = 9
     *
     C                   when      @var = 10
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbetr#
     C                   else
     C                   eval      lbetr# = lbtrn#
     C                   endif
     *
     C                   when      @var = 11
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbeslt
     C                   else
     C                   eval      lbeslt = lbdisp
     C                   endif
     *
     C                   when      @var = 12
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbeqty
     C                   else
     C                   eval      lbeqty = @qty2
     C                   endif
     *
     C                   when      @var = 13
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbeucd
     C                   else
     C                   eval      lbeucd = lbucod
     C                   endif
     *
     C                   when      @var = 14
     *
     C                   when      @var = 15
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbepak
     C                   else
     C                   eval      lbepak = itpdsc
RFSbAC                   select
RFSbDC**                 if        client = dairyland
RFSbMC                   when      client = dairyland
DRY AC                   eval      %subst(lbepak:10:2) = itum1
DRY AC                   eval      %subst(lbepak:12:2) = itum2
DRY AC                   eval      %subst(lbepak:14:2) = itum3
RFSbAC                   when      client = rfs
RFSbAC                   eval      lbepak = *blanks
RFSbAC                   if        %subst(ohmisc:7:3) = '*SP'
RFSbAC                             or %subst(ohmisc:7:3) = '#SP'
RFSbAC                   eval      lbepak = 'Y'
RFSbAC                   endif
RFSbDC**                 endif
RFSbMC                   endsl
     C                   endif
     *
     C                   when      @var = 16
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbedsc
     C                   else
     C                   eval      lbedsc = itdesc
     C                   endif
     *
     C                   when      @var = 17
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbeitm
     C                   else
     C                   eval      lbeitm = lbitem
     C                   endif
     *
     C                   when      @var = 18
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbeord
     C                   else
     C                   eval      lbeord = ohcord
     C                   endif
     *
     C                   when      @var = 19
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbecus
     C                   else
     C                   eval      lbecus = ohcust
     C                   endif
     *
     C                   when      @var = 20
     *
     C                   when      @var = 21
     *
     C                   when      @var = 22
     *
     C                   when      @var = 23
     *
     C                   when      @var = 24
     *
     C                   when      @var = 25
     *
     C                   when      @var = 26
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbepl#
     C                   else
     C                   eval      lbepl# = @pal#
     C                   endif
     *
     C                   when      @var = 27
     *
     C                   when      @var = 28
     *
     C                   when      @var = 29
     *
     C                   when      @var = 30
     *
     C                   when      @var = 31
     *
     C                   when      @var = 32
     *
     C                   when      @var = 33
     *
     C                   when      @var = 34
     *
     C                   when      @var = 35
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbezon
     C                   else
     C                   eval      lbezon = $pszon
     C                   endif
     *
     C                   when      @var = 36
     *
     C                   when      @var = 37
     *
     C                   when      @var = 38
     *
     C                   when      @var = 39
     *
     C                   when      @var = 40
     *
     C                   when      @var = 41
     *
     C                   when      @var = 42
     *
     C                   when      @var = 43
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lberte
     C                   else
     C                   eval      lberte = $prte
     C                   endif
     *
     C                   when      @var = 44
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbeztp
     C                   else
     C                   eval      lbeztp = zontyp
     C                   endif
     *
     C                   when      @var = 45
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbeout
     C                   else
     C                   eval      lbeout = outwrd
     C                   endif
     *
     C                   when      @var = 46
     *
     C                   when      @var = 47
     *
     C                   when      @var = 48
     *
     C                   when      @var = 49
     *
     C                   when      @var = 50
     *
     C                   when      @var = 51
     *
     C                   when      @var = 52
     *
     C                   when      @var = 53
     *
     C                   when      @var = 54
     *
     C                   when      @var = 55
     *
     C                   when      @var = 56
     *
     C                   when      @var = 57
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbelb#
     C                   else
     C                   eval      lbelb# = lblbl#
     C                   endif
     *
     C                   when      @var = 58
     *
     C                   when      @var = 82
     *
     C                   when      @var = 999
     C                   if        $pcmd = '*TEST2  '
     C                   eval      lbemzn = 'MERGE '
     C                   eval      lbedsq = 1
     C                   eval      lbeitp = 'X'
     C                   eval      lberid = '12345'
     C                   eval      lbetyp = 'O'
     C                   eval      lbewhd = 'DEPT '
     C                   eval      lbeutp = 'N'
     C                   eval      lbecub = 12.3
     C                   eval      lbewgt = 5.67
414aAC                   eval      lbecwf = 'N'
     C                   else
     C                   eval      lbemzn = tmpzon
     C                   z-add     lbseq         lbedsq
     C                   eval      lbeitp = ittype
     C                   eval      lberid = lbrte
     C                   eval      lbetyp = lbtype
     C                   eval      lbewhd = lbwhdp
     C                   eval      lbeutp = lbutyp
     C                   eval      lbecub = lbcube
     C                   eval      lbewgt = lbswgt
414aAC                   eval      lbecwf = itcwgt
     C                   endif
     *
     C                   endsl
     *
     C     endfi2        endsr
     *----------------------------------------------------------------
     *
     *  FILNUM  Fill numeric variable.
     *
     C     filnum        begsr
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
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLBLK  Bulk pick labels.
     *
     C     lblblk        begsr
     C                   eval      stpcnt = 0
     C                   eval      @qty2 = w1qty
     C                   eval      @pal# = pspal#
     C                   exsr      fillb1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLCWT  Catch weight labels.
     *
     C     lblcwt        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLCMB  Combined label is next.
     *
     C     lblcmb        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLCMA  Combined label is before.
     *
     C     lblcma        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLDIS  Discrepancies label.
     *
     C     lbldis        begsr
     C                   endsr
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
     C                   eval      stpcnt = 0
     C                   exsr      getpal
     C                   eval      @pal# = pal#
     C                   if        combo = *off
     C                   eval      @qty1 = w1pick
     C                   eval      @qty2 = w1qty2
     C                   eval      totwrd = ' of'
     C                   move      '       '     cmbwrd
     C                   else
     C                   eval      @qty1 = 0
     C                   eval      @qty2 = w1qty2
     C                   eval      totwrd = 'TOT'
     C                   eval      cmbwrd = '(COMBO)'
     C                   endif
     C                   if        lbasl2 = 'OUT'
     C                   eval      outwrd = 'OUT'
     C                   else
     C                   move      '   '         outwrd
     C                   endif
     C                   exsr      fillb1
     C                   eval      combo = *off
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLZPD  Zone pickup detail line.
     *
     C     lblzpd        begsr
     C                   eval      lbwhdp = *blanks
     C                   exsr      lblzps
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLZPH  Zone pickup header line.
     *
     C     lblzph        begsr
     C                   endsr
414bA*----------------------------------------------------------------
414bA*
414bA*  LBLZPS  Zone pickup individual selection labels
414bA*
414baC     lblzps        begsr
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
     C                   exsr      crtstp
     *
     *     Force combo label for writing to file
     *
     C                   eval      opclvl = 0
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
     C                   eval      w1pick = lbqpck
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
     C                   eval      combo = *off
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
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLRP2  Replenishment/Letdown - Breakdown.
     *
     C     lblrp2        begsr
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
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLSSD  Set summary detail lines.
     *
     C     lblssd        begsr
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
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLUMB  Unit of measure change is next.
     *
     C     lblumb        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLZHD  Zone header label.
     *
     C     lblzhd        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLXDB  Cross dock labels are next.
     *
     C     lblxdb        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PrtSections   Print records for Pallet Sections
     *
720aA /free
720aA   begsr PrtSections;
720aA     setll (lbwhse: lblbl#: 1) labelps;
720aA     reade (lbwhse: lblbl#) labelps;
720aA     sectionId = lsscid;
720aA     sectionCnt = 0;
720aA
720aA     dou %eof(labelps);
720aA       sectionCnt = sectionCnt + 1;
720aA       if lsscid <> sectionId;
720aA         // new section, write record for previous section
720aA         lbepls = sectionId;
720aA         lbeqty = sectionCnt;
720aA         exsr print;
720aA         // reset section/count
720aA         sectionId = lsscid;
720aA         sectionCnt = 0;
720aA       endif;
720aA       reade (lbwhse: lblbl#) labelps;
720aA     enddo;
720aA
720aA     // write record for last section
720aA     lbepls = sectionId;
720aA     lbeqty = sectionCnt;
720aA     exsr print;
720aA
720aA   endsr;  // PrtSections
720aA /end-free
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
     C                   exsr      lblpck
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
