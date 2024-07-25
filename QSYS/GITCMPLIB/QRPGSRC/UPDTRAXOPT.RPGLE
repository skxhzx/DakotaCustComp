     H fixnbr(*ZONED)
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  UPDTRAXOPT  Initialize blank OPTIONS/*TRAX fields by warehouse
650aA*              Initialize blank OPTIONS/*TRAX1 fields by warehouse
650aA*              Initialize blank OPTIONS/*TRAX2 fields by warehouse
     *
     *  04 November 2013
     *  Retha Davis
     *
     *  Revisions
     *
650 A*    11/04/13  RBD  6.50
     *      - Created.
     *      - Note: h spec fixnbr parm forces dec data errors to
     *        be ignored. If a numeric field comes in as blank it
     *        just means it's never been initialized or entered so
     *        we just want to set it to its default value.
     *
650aA*    03/13/14  RBD  6.50a
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
720aA*    02/01/18  RBD  7.20a
     *      - Added *TRAX2 options:
     *          Create version 1.2 xml, Y/N.
     *          Create version 2.0 xml, Y/N.
     *          Main IFS directory.
     *          IFS user.
     *
730aA*    12/30/19  RBD  7.30a
     *      - Added options.
     *
760aA*    04/25/22  RBD  7.60a
     *      - Set *TRAX/optraxinv to '9' if blank.
     *      - Set *TRAX2/optsyg to 'N' if blank.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fwarehs    if   e           k disk
     Foptions   uf a e           k disk
     *----------------------------------------------------------------
     *  *TRAX  -  TRAX options
     *----------------------------------------------------------------
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
650aA*    OPTDSF  -  Display stop flags before restart.
730aA*    OPTSOR  -  Sort items by compartment Y/N.
730aA*    OPTODE  -  Customer on site delivery enable Y/N.
730aA*    OPTODP  -  Customer on site delivery verification period, 5-60.
730aA*    OPTONT  -  On truck picking Y/N.
730aA*    OPTOTP  -  Override truck picking Y/N.
730aA*    OPTNSB  -  No signee button on signature screen Y/N.
760aA*    OPTRAXINV - 1 = Print all invoices
760aA*                2 = Print pristine invoices only
760aA*                3 = Print non-pristine invoices only
760aA*                9 = Print no invoices
     *
     * Data structure
     *
     D opdata          ds
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
650aAD  optdsf               102    102
730aAD  optsor               103    103
730aAD  optode               104    104
730aAD  optodp               105    106  0
730aAD  optont               107    107
730aAD  optotp               108    108
730aAD  optnsb               109    109
760aAD  optraxinv            110    110
     D  optend               117    117
650aA*----------------------------------------------------------------
650aA*  *TRAX1    -  More TRAX options
650aA*----------------------------------------------------------------
650aA*
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
650aA*----------------------------------------------------------------
650aA*  *TRAX2  -  More TRAX options
650aA*----------------------------------------------------------------
650aA*
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
720aA*    OPTV12  -  Default = N.  Y = create V1.2 xml.
720aA*    OPTV20  -  Default = N.  Y = create V2.0 xml.
720aA*    OPTDIR  -  IFS main directory
720aA*    OPTIU   -  IFS user
730aA*    OPTOSIG -  Create Customer Order Signatures (Default = N)
730aA*               OPTOSG add for compatability with OPTIONSDS
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
760aA*    OPTSYG  -  Sygic Truck Integration Y/N.
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
720aAD  optv12                18     18
720aAD  optv20                19     19
720aAD  optdir                20     39
720aAD  optiu                 40     49
730aAD  optosg                50     50
730aAD  optosig               50     50
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
760aAD  optsyg               116    116
     D  opten2               117    117
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
730aAD opdta3          ds
730aAD  opturl                 1     60
730aAD  opten3               117    117
     *----------------------------------------------------------------
     * Variables
     *
     d forever         s               n
     D kycode          s                   like(opcode)
     *----------------------------------------------------------------
     *  Main line

      /free

         // Initialize blank *TRAX fields

        kycode = '*TRAX';

        setll *loval warehs;
        dow forever = forever;
          read warehs;
          if %eof(warehs);
            leave;
          endif;

          chain (whcode:kycode) options;

          if opthst = 0;
            opthst = 31;
          endif;
          if optsli = ' ';
            optsli = 'Y';
          endif;
          if optcwr = ' ';
            optcwr = 'N';
          endif;
          if optoft = ' ';
            optoft = 'N';
          endif;
          if optdft = ' ';
            optdft = 'N';
          endif;
          if optrft = ' ';
            optrft = 'N';
          endif;
          if optcap = ' ';
            optcap = 'Y';
          endif;
          if optdbl = ' ';
            optdbl = 'N';
          endif;
          if optekd = ' ';
            optekd = 'Y';
          endif;
          if optdar = ' ';
            optdar = 'Y';
          endif;
          if optidb = ' ';
            optidb = 'N';
          endif;
          if optbda = ' ';
            optbda = 'N';
          endif;
          if optgbd = ' ';
            optgbd = 'N';
          endif;
          if optrtq = ' ';
            optrtq = 'N';
          endif;
          if optotq = ' ';
            optotq = 'N';
          endif;
          if optcce = ' ';
            optcce = 'N';
          endif;
          if optsig = ' ';
            optsig = 'N';
          endif;
          if optpiv = ' ';
            optpiv = 'N';
          endif;
          if optsda = ' ';
            optsda = 'N';
          endif;
          if optwsp = 0;
            optwsp = 7070;
          endif;
          if optsvd = 0;
            optsvd = 5;
          endif;
          if optert = ' ';
            optert = 'PROD';
          endif;
          if optedv = ' ';
            optedv = 'MC75';
          endif;
          if opteos = ' ';
            opteos = 'WM6';
          endif;
          if optesw = 0;
            optesw = 480;
          endif;
          if optesh = 0;
            optesh = 640;
          endif;
          if optare = ' ';
            optare = 'Y';
          endif;
          if optidl = ' ';
            optidl = 'N';
          endif;
          if optdci = ' ';
            optdci = 'Y';
          endif;
          if optpal = ' ';
            optpal = 'N';
          endif;
          if optcra = ' ';
            optcra = 'N';
          endif;
          if optdrv = ' ';
            optdrv = 'N';
          endif;
          if optbul = ' ';
            optbul = 'Y';
          endif;
          if opteys = ' ';
            opteys = 'Y';
          endif;
          if optsas = ' ';
            optsas = 'Y';
          endif;
          if optsdl = 0;
            optsdl = 10;
          endif;
          if optsdt = ' ';
            optsdt = 'N';
          endif;
          if optlrk = ' ';
            optlrk = 'Y';
          endif;
          if optgss = ' ';
            optgss = 'N';
          endif;
          if optgsu = ' ';
            optgsu = 'N';
          endif;
          if optsbv = 0;
            optsbv = 3;
          endif;
          if optrag = ' ';
            optrag = 'Y';
          endif;
          if optrd  = ' ';
            optrd  = 'N';
          endif;
          if optrdt = 0;
            optrdt = 0330;
          endif;
          if optrfp = ' ';
            optrfp = 'F';
          endif;
          if optrfm = ' ';
            optrfm = 'A';
          endif;
          if optnsr = ' ';
            optnsr = 'N';
          endif;
          if optfbd = ' ';
            optfbd = 'N';
          endif;
650aA     if optdsf = ' ';
650aA       optdsf = 'N';
650aA     endif;
730aA     if optsor = ' ';
730aA       optsor = 'Y';
730aA     endif;
730aA     if optode = ' ';
730aA       optode = 'N';
730aA     endif;
730aA     if optodp = 0;
730aA       optodp = 30;
730aA     endif;
730aA     if optont = ' ';
730aA       optont = 'N';
730aA     endif;
730aA     if optotp = ' ';
730aA       optotp = 'N';
730aA     endif;
730aA     if optnsb = ' ';
730aA       optnsb = 'Y';
730aA     endif;
760aA     if optraxinv = ' ';
760aA       optraxinv = '9';
760aA     endif;

          if not %found(options);
            opwhse = whcode;
            opcode = kycode;
            write oprec;
          else;
            update oprec;
          endif;

        enddo;
650aA
650aA    // Initialize blank *TRAX1 fields
650aA
        kycode = '*TRAX1';

        setll *loval warehs;
        dow forever = forever;
          read warehs;
          if %eof(warehs);
            leave;
          endif;

          chain (whcode:kycode) options;
          if %found;
            opdta1 = opdata;
          else;
            opdta1 = *blanks;
          endif;

          if opter = ' ';
            opter = 'N';
          endif;

650aA     if optref = ' ';
650aA       optref = 'trax@DoNotReply.com';
650aA     endif;

650aA     if optres = ' ';
650aA       optres = 'TraxPODSystemReceipt';
650aA     endif;

          opdata = opdta1;

          if not %found(options);
            opwhse = whcode;
            opcode = kycode;
            write oprec;
          else;
            update oprec;
          endif;

        enddo;

650aA
650aA    // Initialize blank *TRAX2 fields
650aA

        kycode = '*TRAX2';

        setll *loval warehs;
        dow forever = forever;
          read warehs;
          if %eof(warehs);
            leave;
          endif;

          chain (whcode:kycode) options;
          if %found;
            opdta2 = opdata;
          else;
            opdta2 = *blanks;
          endif;

          if optsbu = ' ';
            optsbu = 'Y';
            optsb  = 5;
          endif;

          if optseu = ' ';
            optseu = 'Y';
            optse  = 30;
          endif;

          if optbbu = ' ';
            optbbu = 'Y';
            optbb  = 60;
          endif;

          if optbeu = ' ';
            optbeu = 'Y';
            optbe  = 5;
          endif;

720aA     if optv12 = ' ';
720aA       optv12 = 'N';
720aA     endif;

720aA     if optv20 = ' ';
720aA       optv20 = 'Y';
720aA     endif;

720aA     if optdir = ' ';
720aA       optdir = 'BFCTrax';
720aA     endif;

720aA     if optiu = ' ';
720aA       optiu = 'BFCTRAX';
720aA     endif;

730aA     if optosig = ' ';
730aA       optosig = 'N';
730aA     endif;

730aA     if optsvl = ' ';
730aA       optsvl = 'Y';
730aA     endif;

730aA     if optssp = ' ';
730aA       optssp = 'Y';
730aA     endif;

730aA     if optsss = ' ';
730aA       optsss = 'Y';
730aA     endif;

730aA     if optsst = ' ';
730aA       optsst = 'Y';
730aA     endif;

730aA     if optmul = ' ';
730aA       optmul = 'Y';
730aA     endif;

730aA     if optkpl = ' ';
730aA       optkpl = 'N';
730aA     endif;

730aA     if optshl = ' ';
730aA       optshl = 'Y';
730aA     endif;

730aA     if optprt = ' ';
730aA       optprt = 'N';
730aA     endif;

730aA     if optspk = ' ';
730aA       optspk = 'Y';
730aA     endif;

730aA     if optgps = ' ';
730aA       optgps = 'Y';
730aA     endif;

730aA     if optmin = 0;
730aA       optmin = 10;
730aA     endif;

730aA     if optmet = 0;
730aA       optmet = 400;
730aA     endif;

730aA     if optpwd = ' ';
730aA       optpwd = '4564546C365A646167';
730aA     endif;

730aA     if optoff = 0;
730aA       optoff = 15;
730aA     endif;

730aA     if optaut = ' ';
730aA       optaut = 'N';
730aA     endif;

730aA     if optph1 = 0;
730aA       optph1 = 5555555555;
730aA     endif;

730aA     if optph2 = 0;
730aA       optph2 = 4444444444;
730aA     endif;

730aA     if optcam = ' ';
730aA       optcam = 'N';
730aA     endif;

730aA     if optdil = ' ';
730aA       optdil = 'Y';
730aA     endif;

730aA     if optdip = ' ';
730aA       optdip = 'Y';
730aA     endif;

760aA     if optsyg = ' ';
760aA       optsyg = 'N';
760aA     endif;

          opdata = opdta2;

          if not %found(options);
            opwhse = whcode;
            opcode = kycode;
            write oprec;
          else;
            update oprec;
          endif;

        enddo;


730aA
730aA    // Initialize blank *TRAX3 fields
730aA

730aA   kycode = '*TRAX3';

730aA   setll *loval warehs;
730aA   dow forever = forever;
730aA     read warehs;
730aA     if %eof(warehs);
730aA       leave;
730aA     endif;

730aA     chain (whcode:kycode) options;
730aA     if %found;
730aA       opdta3 = opdata;
730aA     else;
730aA       opdta3 = *blanks;
730aA     endif;

730aA     if opturl = ' ';
730aA       opturl = 'http://';
730aA     endif;

730aA     opdata = opdta3;

730aA     if not %found(options);
730aA       opwhse = whcode;
730aA       opcode = kycode;
730aA       write oprec;
730aA     else;
730aA       update oprec;
730aA     endif;

730aA   enddo;


        *inlr = *on;
      /end-free

