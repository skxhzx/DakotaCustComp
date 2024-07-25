      /COPY *libl/qcopysrc,hspecs
     H dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *  Multilingual Verision
     *  Every screen and message has a corresponding Spanish version.
     *  Any changes must be made to both languages.
     *  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PO201     RF UCI receiving.
     *  27 November 2020
     *  Lynn McMahon
     *
     *  Notes
     *
     *       copied from PO200.
     *       left original screen processing in tact in case it is needed
     *       in the future.
     *
     *       8 X 20 Screens for hand held scanners
     *       UPC code must be right adjusted.
     *       LFLAG on = enter license plate
     *
     *----------------------------------------------------------------
     *  Revisions
     *
740 A*    01/27/20  LMC  7.40
     *      - Created.
740aA*    03/25/20  LMC  7.40a
     *      - Had to cleanup some stuff on screen format
740bA*    04/03/20  LMC  7.40b
     *      - Check for an existing upc entry. before accepting uci.
740cA*    05/11/20  LMC  7.40c
     *      - Enh: Increased uci field from 50 to 70.
     *        Some international barcodes are longer than the
     *        guidelines of 48 characters.
     *      - Check for an existing upc entry. before accepting uci.
740dA*    05/22/20  LMC  7.40d
     *      - Enh: Send Vendor to all calls of CVTBAR so that the
     *        new decipher barcode process works.
740eA*    05/27/20  LMC  7.40e
     *      - Enh: w8dte is a shared field. Only populate the date
     *        if the item date setting match the date extracted from
     *        the uci.
740fA*    05/28/20  LMC  7.40f
     *      - Enh: Allowing 99 labels only on uci receiving.
     *        This will assume the item being received is Normal UOM
740gA*    07/29/20  LMC  7.40g
     *      - Enh: If we encounter an error in zzchklncs load up
     *        error messages and leavesr.
740hA*    08/04/20  LMC  7.40h
     *      - Enh: Added scan count to screen11.
740iA*    08/24/20  LMC  7.40i
     *      - Enh: added cw variance on screen11 process.
740jA*    08/25/20  LMC  7.40i
     *      - Enh: added cw variance on screen11 process.
     *----------------------------------------------------------------
     *    Client Custom Revisions: Packers
PCKaA*    06/16/20  LMC  PCKa
     *      - Enh: Do not issue multiple lot warning for vendor 203
     *        Still process and store as if they have taken the
     *        override on multiple lots.
     *      - Enh: For vendor 203 allow user to override lot stored in
     *        LICINFO on screen 9. This is typically protected if the
     *        lot was extracted from the gs1 barcode.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  66        Date Code Decipher check to non display cmd11
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
740aDF*po201fm   cf   e             workstn
740cDF*po20101   cf   e             workstn
740hDF*po20102   cf   e             workstn
740jDF*po20103   cf   e             workstn
740jMFpo20104   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(m16rec:msgk)
     Funmesr    if   e           k disk
     Fpiritem   if   e           k disk
     FLabel2    if   e           k disk
     Fpohdr     uf   e           k disk
     Fpodtl1    if   e           k disk
     F                                     rename(pdrec:record)
     Fpodtl     if   e           k disk
     Fpodtl3    if   e           k disk
     F                                     rename(pdjrec:ptouch)
     Fpodtlm    if   e           k disk
     Fupc       uf a e           k disk
     Fupc1      if   e           k disk    prefix(u1_)
     F                                     rename(uprec:u1rec)
     Fupc4      if   e           k disk
     F                                     rename(uprec:uprec4)
     FLicense   uf a e           k disk
     Foptions   if   e           k disk
     Foptiond   if   e           k disk
     Fitemmsc   if   e           k disk
     Fpoctype   uf a e           k disk
     F*orcv     o  a e           k disk
     Fporcv     uf a e           k disk
     F*omfr     o    e             disk
     Fpomfr1    uf a e             disk
     Fitmexcp   o    e           k disk
     Fpospo     if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             50    dim(8) ctdata perrcd(1)
     D cwt             s              3    dim(2) ctdata perrcd(1)
     D descsp          s             50    dim(8) ctdata perrcd(1)
     D cwtsp           s              3    dim(2) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     D                 ds
     D  dspo                   1      9
     D  dslbl                 10     16  0
     D  dsexpd                17     24  0
     D  dsfdis                 1     12
     D  dstdis                13     24
     *
     *----------------------------------------------------------------
     * Data structure
     *
     *----------------------------------------------------------------
     *  *ITEMMNT  -  Item maintenance options.
     *----------------------------------------------------------------
     *
     *    03/05/97  RH
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
     *    OPXDSC  -  Use extended description (Y/N)
     *    OPHVY   -  Heavy items are greater than or equal to
     *
     * Data structure
     *
     D opdat1          ds
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
     D  opxdsc                73     73
     D  ophvy                 74     75  0 inz(0)
     D  optend1              117    117
     D opdata          ds
     D  optlen               117    117
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
     *    OPWRNC  -  Perform catch weight variance check (Y,N).
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
     *    OPICW   -  Individual catch weight entry (Y,N).
     *    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
     *    OPRCDY  -  Number of days to keep receiving logs.
     *    OPMPCK  -  Number of days to keep picking logs.
     *
     * Data structure
     *
     D sydata          ds
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
     D  sysend               117    117
     *----------------------------------------------------------------
     *  *RCVLBL  -  Receiving options
     *
     *    OPRUPC  -  Prompt user for Retail UPC during receiving? (Y,N)
     *    OPRUPS  -  Allow user to skip Retail UPC scan? (Y,N)
     *    OPRUPF  -  Require Retail UPC on file before receipt? (Y,N)
     *
     *----------------------------------------------------------------
     D rcdata          ds
     D  oplpgm                 1     10
     D  opupct                11     13  0
     D  oppdef                14     14  0
     D  oppbld                15     15  0
     D  oppact                16     16  0
     D  opfdef                17     17  0
     D  opfasl                18     18  0
     D  opfsid                19     19  0
     D  opflvl                20     20  0
     D  oppasl                21     21  0
     D  oppfrc                22     22
     D  opplcn                23     23
     D  oppchm                24     24
     D  oppmix                25     25
     D  opapck                26     26
     D  opfrcm                27     27
     D  opexck                28     28
     D  opcwen                29     29
     D  opcwtp                30     30
     D  opcwfr                31     31
     D  opipck                32     32
     D  oprupc                33     33
     D  oprups                34     34
     D  oprupf                35     35
     D  optend               117    117
     *----------------------------------------------------------------
     *  *PICK  -  Picking options
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
     *    OPPBRK  -  Break pallets by aisle (Y,N).
     *    OPMPUT  -  Manual Put away (Y,N).
     *
     * Data structure
     *
     D opddta          ds
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
     D  opmput                34     34
     D  opdend               117    117
     *----------------------------------------------------------------
     *  Convert Barcode Parms
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#CVTPARMS
      /COPY *libl/qcopysrc,C#BARCODE
     *----------------------------------------------------------------
     *  Name constants
     *
     D valid           c                   const('0123456789 ABCDEFGHI-
     D                                     JKLMNOPQRSTUVWXYZabc-
     D                                     defghijklmnopqrstuvw-
     D                                     xyz')
     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getimuom
      /copy qcopysrc,p.cvtdte
     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------
     D ucilic#         pr                  extpgm('UCILIC#')
      * Input
     D   unext                       13  0 const
     D   uwhse                        3  0 const
     D calcpti         pr                  extpgm('CALCPTI')
      * Input
     D   pGTIN                             like($bcgtin)
     D   pLOT                              like(pplot)
     D   pPackDate                         like($pmfgdt)
     D   pPTI                              like(pppti)

     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @getsi          c                   const('GETSLOTITM')
     **            'FRMTIT'              C         @FMTIT
     D @fmtit          c                   const('FRMTIT2')
     D @crtrcv         c                   const('CRTRCVTRN')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $bparm          ds
     D  $bcmd                  1      8
     D  $bprg                  9     18
     D  $buky                 19     68
     D  $brtn                 69     76
     D  $berm                 77    136
     D  $bmsg                 77     80
     *   Redefine key
     D  $bpo                  19     27
     D  $brcvdt               28     35  0
     D  $bqty                 36     40  0
     D  $bprint               41     50
     D  $bitem                51     65
     D  $buom                 66     67
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
     D  $litem                22     36
     D  $lpo2                 37     45
     D  $lrq1                 46     50  0
     D  $lrq2                 51     55  0
     D  $lrq3                 56     60  0
     D  $lrpal                61     63  0
     D  $llott                64     64
     D  $llict                65     65
     *
     D  $lpo                  22     30
     D  $lline                31     35  0
     D  $lpitm                36     50
     *
     D  $lwhs3                19     21  0
     D  $lpo3                 22     30
     *
     D  $lwhs4                19     20p 0
     D  $lpo4                 21     29
     D  $lseq4                30     32p 0
     D  $litm4                33     47
     *
     D  $llot                 37     37
     D  $lltrk                38     38
     *
     D  $lmfr#                22     32  0
     D  $lmfritem             33     47
     D  $ldakitem             48     62
     *
     *
     *----------------------------------------------------------------
     *  LICHIST - License history (Input Data)
     *
     D $rparm          ds
     D  $rwhse                 1      3  0
     D  $rltrn                 4      7p 0
     D  $racfl                 8      9
     D  $rtrn#                10     13p 0
     D  $rlbl#                14     17p 0
     D  $rlcns                18     32
     D  $rfmlc                33     47
     D  $rorlc                48     62
     D  $rlqy1                63     66p 0
     D  $rlqy2                67     70p 0
     D  $rlqy3                71     74p 0
     D  $raqy1                75     78p 0
     D  $raqy2                79     82p 0
     D  $raqy3                83     86p 0
     D  $rfmcd                87     87
     D  $rfara                88    102
     D  $rfwhd               103    107
     D  $rfasl               108    110
     D  $rfloc               111    113  0
     D  $rflvl               114    115  0
     D  $rfhnd               116    117
     D  $rfslp               118    119p 0
     D  $rtocd               120    120
     D  $rtara               121    135
     D  $rtwhd               136    140
     D  $rtasl               141    143
     D  $rtloc               144    146  0
     D  $rtlvl               147    148  0
     D  $rthnd               149    150
     D  $rtslp               151    152p 0
     D  $rtord               153    156p 0
     D  $rtseq               157    159p 0
     D  $rexcd               160    167
     D  $radts               168    193
     D  $raemp               194    196p 0
     D  $rausr               197    206
     D  $rajob               207    216
     D  $rajbn               217    222
     D  $rcdts               223    248
     D  $rcemp               249    251p 0
     D  $rcusr               252    261
     D  $rcjob               262    271
     D  $rcjbn               272    277
     * Misc. work fields
     D $rdata          ds
     D  $rpo                   1      9
     D  $rseq                 10     12p 0
     D  $ritem                13     27
     D  $rlotc                28     57
     D  $rcwgt                58     62p 2
     *
     D rcv01           c                   const('Receiving')
     D rcv02           c                   const('Dock')
     *----------------------------------------------------------------
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
     *  API programs
     *
     D @apici          c                   const('APICVTITM ')
     D @llptr          c                   const('UPDLLPTRK')
     *----------------------------------------------------------------
     *  Working fields.
     *
     D                 ds
     D  lottrk                 1      4
     D  lictrk                 5      8
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     *                                   P   1   20ERWHSE
     *
     D  erfld                  1     30
     D  erpo                  31     39
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  ermday                 1      2p 0
     D  ermfdt                 3      6p 0
     D  erexdt                 7     10p 0
     D  erltst                11     14p 0
     D  erdday                15     16p 0
     D  eruday                17     18p 0
     *
     D  erused                 1      4p 0
     D  erdisd                 5      6p 0
     D  erusrd                 7      8p 0
     D  ersell                 9     12p 0
     *
     D  ertcwt                 1      5p 2
     D  erlrng                 6     10p 2
     D  erhrng                11     15p 2
     D  errg1c                16     17p 1
     D  errg2c                18     19p 1
     D  erexwt                20     24p 2
     *
     D  ertcw#                 1      3p 0
     D  erqpck                 4      6p 0
     *
     D  erentd                 1      5p 0
     D  ertod                  6     10p 0
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     D #msgsp          c                   const('PIRMSGFSP ')
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
     * Status message(s)
     D sts00           c                   const('Open')
     D sts01           c                   const('Partial receipt')
     D sts02           c                   const('Received in full')
     D sts03           c                   const('Ready for export')
     D sts04           c                   const('Partial export')
     D sts05           c                   const('Import error')

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#LICENSE
      /COPY *libl/qcopysrc,C#UCIINFO
      /COPY *libl/qcopysrc,C#LICINFO
     D savever#        s                   like($itver#)
     *------------------------------------------------------------------
     * CLCDUR2 parameters
     *------------------------------------------------------------------

     D $cdcmd          s              8

     D $cddatein       s              8  0
     D $cdtimein       s              6  0

     D $cdyears        s              3  0
     D $cdmonths       s              3  0
     D $cddays         s              3  0
     D $cdhours        s              3  0
     D $cdminutes      s              3  0
     D $cdseconds      s              3  0

     D $cddateOut      s              8  0
     D $cdtimeOut      s              6  0

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#isupply
      /copy qcopysrc,id#saval
      /copy qcopysrc,id#yhata
      /copy qcopysrc,id#dairyla
PCKaA /copy qcopysrc,id#packers
     *----------------------------------------------------------------
     *  Variables
     *
     D $ldwgt          s              9  2
     D $lflag          s              1
     D $lord           s              7  0
     D $lum1           s              5
     D $lum2           s              5
     D $lum3           s              5
     D $lven           s             11  0
     D $lvitm          s             15
     D $lvnam          s             40
     D $msgf           s             10
     D $posscode       s              1
     D $pw1pti         s              4  0
     D #msgid          s              7
     D #msgtp          s              7
     D #oitem          s             15
     D #oswgt          s              7  2
     D #oswt2          s              7  2
     D #oswt3          s              7  2
     D #otype          s              1
     D #oum1           s              2
     D #oum2           s              2
     D #oum2q          s              3  0
     D #oum3           s              2
     D #oum3q          s              3  0
     D #pgmq           s             10
     D avgwt1          s              7  2
     D avgwt2          s              7  2
     D avgwt3          s              7  2
     D Btype           s              7
     D caltol1         s             11  4
     D caltol2         s             11  4
     D caltol1x100     s             13  4
     D caltol2x100     s             13  4
     D chk4err         s               n
     D ckexdt          s              8  0
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D CnvWgt          s              9  2
     D comand          s              5  0
     D cwcalc          s              1  0
     D cwovr           s              1
     D date1           s              8  0
     D date16          s              6  0
     D date2           s              8  0
     D date2o          s              6  0
     D date26          s              6  0
     D ddcode          s              1
     D digits          c                   const('0123456789')
     D dtchk           s              1
     D dtchk2          s              1
     D dtchk3          s              1
     D dtchk4          s              1
     D dtfrmt          s              1  0
     D e               s              2  0
     D enter           s              5  0
     D eof             s              1
     D errflg          s              1
     D error           s              1
     D exdtj           s              5  0
     D expd            s              8  0
     D expdj           s              5  0
     D exwgt           s              9  2
     D forevr          s              1
     D full            s              1
     D g$date          s              6  0
     D g$dd            s              2  0
     D g$dw            s              1  0
     D g$jd            s              5  0
     D g$jyd           s              7  0
     D g$mm            s              2  0
     D g$mmwk          s              2  0
     D g$wk7           s              7  0
     D g$yy            s              2  0
     D g$yywk          s              3  0
     D g$yyyy          s              4  0
     D gmwksv          s              2  0
     D help            s              5  0
     D hirng           s              9  2
     D hivar           s              9  2
     D hostcw0         s              7  0
     D hostcwa         s              7
     D hostcw2dec      s              7  2
     D hostUnitWgt     s              9  4
     D hvskp           s              1
     D iaflag          s              1
     D iatest          s              1
     D ihrng           s              9  2
     D ihvar           s              9  2
     D ilrng           s              9  2
     D ilvar           s              9  2
     D IMkilolbs       s              1
     D IMUom           s              3
     D j$date          s              6  0
     D j$dd            s              2  0
     D j$jd            s              5  0
     D j$md            s              3  0
     D j$mm            s              2  0
     D j$tst           s              9  9
     D j$x             s              2  0
     D j$yd            s              7  0
     D j$yywk          s              3  0
     D j$yyyy          s              4  0
     D kgs2lbs         c                   2.20462262
     D KiloLbs         s              1
     D kycode          s                   like(opdcod)
     D kyupc           s                   like(upupc)
     D lflag           s              1
     D ltstd6          s              6  0
     D ltstd8          s              8  0
     D lvskp           s              1
     D lwrng           s              9  2
     D lwvar           s              9  2
     D mfdtj           s              5  0
     D mfgd            s              8  0
     D mexpd           s              8  0
     D mfgdte          s              8  0
     D msgk            s              4  0
     D noupc           s              1
     D Needb1          s               n
     D Needb2          s               n
     D Ntype           s              7
     D nxtscr          s              3
     D ocode           s              8
     D oaovr           s              1
     D obovr           s              1
     D ocovr           s              1
     D odovr           s              1
     D oeovr           s              1
     D ofovr           s              1
     D ovrrid          s              1
     D part            s              1
     D poppcs          s                   like($lrq1)
     D prg1c           s              4  3
     D prg2c           s              4  3
     D qtchk           s              1
     D qtyDiff         s              5  0
     D qtyord          s              5  0
     D qtyord1         s              5  0
     D qtyord2         s              5  0
     D qtyord3         s              5  0
     D qtyrcv          s              5  0
     D qtyrcv1         s              5  0
     D qtyrcv2         s              5  0
     D rcvpocomplete   s               n
     D rcvUnitWgt      s              9  4
     D recv            s              1
     D redspl          s              1
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D sdqrc1          s              5  0
     D sdqrc2          s              5  0
     D ssbflg          s              1
     D stop            s              1
     D svcwen          s              1
     D svcwfr          s              1
     D svcwtp          s              1
     D svdwgt          s              7  2
     D svexck          s              1
     D svexdt          s              6  0
     D svmfdt          s              6  0
     D svqrc1          s                   like(pdqrc1)
     D svqrc2          s                   like(pdqrc2)
     D svrupc          s              1
     D svupci          s                   like(pditem)
     D s6upc           s             20
     D s8flag          s              1
     D tmpwgt          s              9  2
     D today           s              8  0
     D todyj           s              5  0
     D uxflag          s              1
     D upcctr          s              3  0
     D vrfycw          s              1
     D warn            s              1
     D wgtDiff         s             11  4
     D wkmday          s              3  0
     D wkwhse          s                   like(w1whse)
     D wobat           s              7  0
     D woexdt          s              8  0
     D wofifo          s              8  0
     D woindt          s              8  0
     D womfdt          s              8  0
     D work2           s              2
     D work4           s              4
     D wotcw           s              9  2
     D Writeb1         s               n
     D Writeb2         s               n
     D wrttyp          s              1
     D wtchk           s              1
     D w8exdt          s              6  0
     D w8mfdt          s              6  0
     D zmflag          s               n
     D zmsflag         s               n
     D $parms1         s             48    dim(20)
     D templcns        s             15
     D lcnsexists      s               n
     D goodlcns        s               n
     D firstuci        s              1
     D difflot         s               n
     D diffexpd        s               n
     D datewarn        s              1
     D dateovr         s              1
     D lastseq         s                   like($lnseq)
     D licinfoupd      s               n
     D lotwarn         s              1
     D lotovr          s              1
     D moretoscan      s              1
     d pplot           s             20
     d pppti           s              4  0
     D saveDATE        s                   like($PMFGDT)
     D saveexpd        s                   like(expd)
     D savelotc        s                   like(w9lotc)
     D savewgt         s                   like(w8dwgt)
     D saveqty         s                   like(sdqrc1)
     D savew1mfdt      s                   like(w8dte)
     D savew1exdt      s                   like(w8dte)
     D savew11uci      s                   like(w11uci)
     D svopwum         s                   like(opwum)
     D uciexists       s               n
     D unexta          s             13
     D UPCwarn         s              1
     D UPCovr          s              1
     D $unext          s             13  0
     D ckupc           s                   like(upupc)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     **     None
     ***    $PLINE  Lines on display (08 or 16).
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     c     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $po               9
     C                   parm                    $poseq            5 0
     C                   parm                    $poitm           15
     C                   parm                    $poitmdsc        65
     C                   parm                    $pxd              2
     C                   parm                    $puci           100
     C                   parm                    w12lcns
     C                   parm                    firstuci
     c                   parm                    $pqty             5 0
     c                   parm                    $pexpdt           6 0
     c                   parm                    $pmfgdt           6 0
     c                   parm                    $plot            20
     c                   parm                    $pwgt            11 3
     c                   parm                    $puomcd           1
     C                   parm                    $po201rtn         8
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     c                   eval      rcvpocomplete = *off
     c                   eval      w1po = $po
     C                   exsr      zzinz2
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
     C     nxtscr        caseq     '04 '         sc4
     C     nxtscr        caseq     '05 '         sc5
     C     nxtscr        caseq     '06 '         sc6
     C     nxtscr        caseq     '07 '         sc7
     C     nxtscr        caseq     '08 '         sc8
     C     nxtscr        caseq     '09 '         sc9
     C     nxtscr        caseq     '10 '         sc10
     C     nxtscr        caseq     '11 '         sc11
     C     nxtscr        caseq     '12 '         sc12
     C     nxtscr        caseq     '13 '         sc13
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     *
     *   check to see if po receipt is completed
     *   if completed update label/transaction with qty information
     *   else just mark them closed. - ended and closed dates
     C                   exsr      zzrcvpoclose
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = *on
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
     C                   if        nxtscr = '01 '
     C                   select
     C                   when      #lline = '16' and e$lng = 'SP'
     C                   exfmt     scrn61sp                             50
     C                   when      #lline = '16' and e$lng = 'EN'
     C                   exfmt     screen61                             50
     C                   when      #lline <> '16' and e$lng = 'SP'
     C                   exfmt     scrn1sp                              50
     C                   when      #lline <> '16' and e$lng = 'EN'
     C                   exfmt     screen1                              50
     C                   endsl
     C                   endif
     C                   if        nxtscr = '02 '
     C                   select
     C                   when      #lline = '16' and e$lng = 'SP'
     C                   exfmt     scrn62sp                             50
     C                   when      #lline = '16' and e$lng = 'EN'
     C                   exfmt     screen62                             50
     C                   when      #lline <> '16' and e$lng = 'SP'
     C                   exfmt     scrn2sp                              50
     C                   when      #lline <> '16' and e$lng = 'EN'
     C                   exfmt     screen2                              50
     C                   endsl
     C                   endif
     C                   if        nxtscr = '03 '
     C                   select
     C                   when      #lline = '16' and e$lng = 'SP'
     C                   exfmt     scrn63sp                             50
     C                   when      #lline = '16' and e$lng = 'EN'
     C                   exfmt     screen63                             50
     C                   when      #lline <> '16' and e$lng = 'SP'
     C                   exfmt     scrn3sp                              50
     C                   when      #lline <> '16' and e$lng = 'EN'
     C                   exfmt     screen3                              50
     C                   endsl
     C                   endif
     C                   if        nxtscr = '04 '
     C                   if        e$lng = 'SP'
     C                   exfmt     scrn4sp                              50
     C                   else
     C                   exfmt     screen4                              50
     C                   endif
     C                   endif
     C                   if        nxtscr = '05 '
     C                   select
     C                   when      #lline = '16' and e$lng = 'SP'
     C                   exfmt     scrn65sp                             50
     C                   when      #lline = '16' and e$lng = 'EN'
     C                   exfmt     screen65                             50
     C                   when      #lline <> '16' and e$lng = 'SP'
     C                   exfmt     scrn5sp                              50
     C                   when      #lline <> '16' and e$lng = 'EN'
     C                   exfmt     screen5                              50
     C                   endsl
     C                   endif
     C                   if        nxtscr = '06 '
     C                   select
     C                   when      #lline = '16' and e$lng = 'SP'
     C                   exfmt     scrn66sp                             50
     C                   when      #lline = '16' and e$lng = 'EN'
     C                   exfmt     screen66                             50
     C                   when      #lline <> '16' and e$lng = 'SP'
     C                   exfmt     scrn6sp                              50
     C                   when      #lline <> '16' and e$lng = 'EN'
     C                   exfmt     screen6                              50
     C                   endsl
     C                   endif
     C                   if        nxtscr = '07 '
     C                   if        e$lng = 'SP'
     C                   exfmt     scrn7sp                              50
     C                   else
     C                   exfmt     screen7                              50
     C                   endif
     C                   endif
     C                   if        nxtscr = '08 '
     C                   select
     C                   when      #lline = '16' and e$lng = 'SP'
     C                   exfmt     scrn68sp                             50
     C                   when      #lline = '16' and e$lng = 'EN'
     C                   exfmt     screen68                             50
     C                   when      #lline <> '16' and e$lng = 'SP'
     C                   exfmt     scrn8sp                              50
     C                   when      #lline <> '16' and e$lng = 'EN'
     C                   exfmt     screen8                              50
     C                   endsl
     C                   endif
     C                   if        nxtscr = '09 '
     C                   select
     C                   when      #lline = '16' and e$lng = 'SP'
     C                   exfmt     scrn69sp                             50
     C                   when      #lline = '16' and e$lng = 'EN'
     C                   exfmt     screen69                             50
     C                   when      #lline <> '16' and e$lng = 'SP'
     C                   exfmt     scrn9sp                              50
     C                   when      #lline <> '16' and e$lng = 'EN'
     C                   exfmt     screen9                              50
     C                   endsl
     C                   endif
     C                   if        nxtscr = '10 '
     C                   select
     C                   when      #lline = '16' and e$lng = 'SP'
     C                   exfmt     screen10                             50
     C                   when      #lline = '16' and e$lng = 'EN'
     C                   exfmt     screen10                             50
     C                   when      #lline <> '16' and e$lng = 'SP'
     C                   exfmt     screen10                             50
     C                   when      #lline <> '16' and e$lng = 'EN'
     C                   exfmt     screen10                             50
     C                   endsl
     C                   endif
     C                   if        nxtscr = '11 '
     C                   select
     C                   when      #lline = '16' and e$lng = 'SP'
     C                   exfmt     SCRN11SP                             50
     C                   when      #lline = '16' and e$lng = 'EN'
     C                   exfmt     screen11                             50
     C                   when      #lline <> '16' and e$lng = 'SP'
     C                   exfmt     SCRN11SP                             50
     C                   when      #lline <> '16' and e$lng = 'EN'
     C                   exfmt     screen11                             50
     C                   endsl
     C                   endif
     C                   if        nxtscr = '12 '
     C                   select
     C                   when      #lline = '16' and e$lng = 'SP'
     C                   exfmt     SCRN12SP                             50
     C                   when      #lline = '16' and e$lng = 'EN'
     C                   exfmt     screen12                             50
     C                   when      #lline <> '16' and e$lng = 'SP'
     C                   exfmt     SCRN12SP                             50
     C                   when      #lline <> '16' and e$lng = 'EN'
     C                   exfmt     screen12                             50
     C                   endsl
     C                   endif
     C                   if        nxtscr = '13 '
     C                   select
     C                   when      #lline = '16' and e$lng = 'SP'
     C                   exfmt     SCRN13SP                             50
     C                   when      #lline = '16' and e$lng = 'EN'
     C                   exfmt     screen13                             50
     C                   when      #lline <> '16' and e$lng = 'SP'
     C                   exfmt     SCRN13SP                             50
     C                   when      #lline <> '16' and e$lng = 'EN'
     C                   exfmt     screen13                             50
     C                   endsl
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       101112
     C                   setoff                                       131415
     C                   setoff                                       161718
     C                   setoff                                       1920
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       303132
     C                   setoff                                       333435
     C                   setoff                                       363738
     C                   setoff                                       3940
     C                   setoff                                       9298
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      redspl = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
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
     C                   if        refrsh = *on
     C                   exsr      zzfil1
     C                   endif
     C                   eval      refrsh = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   if        refrsh = *on
     C                   exsr      zzfil2
     C                   endif
     C                   eval      refrsh = *off
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     C                   if        refrsh = *on
     C                   exsr      zzfil3
     C                   endif
     C                   eval      refrsh = *off
     C                   eval      ovrrid = *off
     c                   eval      expd   = saveexpd
     c                   eval      svdwgt = 0
     c                   eval      w3plt = 1
     c                   select
     c                   when      uputyp = 'N'
     c                   eval      w3qt01 = saveqty
     c                   when      uputyp = '1'
     c                   eval      w3qt02 = saveqty
740iAc                   other
740iAc                   eval      w3qt01 = saveqty
     c                   endsl
     C     end03i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 04 initialization
     *
     C     scr04i        begsr
     C                   eval      nxtscr = '04 '
     C                   if        refrsh = *on
     C                   exsr      zzfil4
     C                   endif
     C                   eval      refrsh = *off
     C     end04i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 05 initialization
     *
     C     scr05i        begsr
     C                   eval      nxtscr = '05 '
     C                   if        refrsh = *on
     C                   eval      woitm# = *blanks
     C                   eval      w4line = 0
     C                   eval      w4item = *blanks
     C                   exsr      zzfil5
     C                   endif
     C                   eval      refrsh = *off
     C     end05i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 06 initialization
     *
     C     scr06i        begsr
     C                   eval      nxtscr = '06 '
     C                   if        refrsh = *on
     C                   eval      w6upc = *blanks
     C                   exsr      zzfil6
     C                   endif
     C                   eval      refrsh = *off
     C     end06i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 07 initialization
     *
     C     scr07i        begsr
     C                   eval      nxtscr = '07 '
     C                   if        refrsh = *on
     C                   eval      w7pctr = 0
     C                   endif
     C                   exsr      zzfil7
     C                   eval      refrsh = *off
     C     end07i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 08 initialization
     *
     C     scr08i        begsr
     C                   eval      nxtscr = '08 '
     C                   if        refrsh = *on
     C                   exsr      zzfil8
     C                   endif
     C                   eval      refrsh = *off
     C* if a new item is selected the overrides need to be reset
     C                   eval      dtchk = *off
     C                   eval      dtchk2 = *off
     C                   eval      dtchk3 = *off
     C                   eval      dtchk4 = *off
     C                   eval      wtchk = *off
     C     end08i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 09 initialization
     *
     C     scr09i        begsr
     C                   eval      nxtscr = '09 '
     C                   if        refrsh = *on
     C                   exsr      zzfil9
     C                   endif
     C                   eval      refrsh = *off
     C     end09i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 10 initialization
     *
     C     scr10i        begsr
     *
     *  This screen will get initiated if receiving options to
     *  capture upc's for breakdown is turned on.
     *
     *  We will display the screen10 if the item has breakdowns
     *  defined, and we do not have a UPC record for the breakdown uom
     *
      /free
        writeb1 = *off;
        writeb2 = *off;
        // breakdown 1 is setup on item
        if itum2 <> ' ';
          Needb1  = *on;
          w10buom = itum2;
          w10btyp = '1';
          // do we have a upc loaded for this breakdown uom
          setll (pdwhse: pditem) upc1;
          dow forevr = forevr;
            reade (pdwhse: pditem) upc1;
            if %eof(upc1);
              leave;
            endif;
            if u1_upuom = itum2;
              needb1  = *off;
              leave;
            endif;
          enddo;
        endif;
        // breakdown 2 is setup on item
        if needb1 = *off;
          if itum2 <> ' ';
            Needb2  = *on;
            w10buom = itum3;
            w10btyp = '2';
            // do we have a upc loaded for this breakdown uom
            setll (pdwhse: pditem) upc1;
            dow forevr = forevr;
              reade (pdwhse: pditem) upc1;
              if %eof(upc1);
                leave;
              endif;
              if u1_upuom = itum3;
                needb2  = *off;
                leave;
              endif;
            enddo;
          endif;
        endif;
        // need to capture a breakdown upc
        if needb1 = *on or needb2 = *on;
          nxtscr = '10 ';
          exsr zzfil10;
        else;
          nxtscr = '03 ';
        endif;
      /end-free
     C     end10i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 11 initialization
     *
     C     scr11i        begsr
     *
     *
     *  note:
     *
     *
      /free
          nxtscr = '11 ';
          exsr zzfil11;
      /end-free
     C     end11i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 12 initialization
     *
     C     scr12i        begsr
     *
     *
     *  note:
     *
     *
      /free
          nxtscr = '12 ';
          exsr zzfil12;
      /end-free
     C     end12i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 13 initialization
     *
     C     scr13i        begsr
     *
     *
     *  note:
     *
     *
      /free
          nxtscr = '13 ';
          exsr zzfil13;
      /end-free
     C     end13i        endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     C                   exsr      scr01i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     c                   exsr      zzrcvpoclose
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr03i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     c                   exsr      zzrcvpoclose
     C                   exsr      scr11i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for other command keys
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     *
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     C     endsc3        endsr
     *----------------------------------------------------------------
     *
     *  SC4  -  Screen 4
     *
     C     sc4           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     *
     C                   eval      refrsh = *off
     *
     *    Lot tracking item. Return to Lot entry screen.
     C                   if        lottrk = '*YES'
     C                   exsr      scr09i
     C                   else
     C                   exsr      scr03i
     C                   endif
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr04i
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     *
     *    Lot tracking item. Return to Lot entry screen.
     C                   if        lottrk = '*YES'
     C                   exsr      scr09i
     C                   else
     C                   exsr      scr03i
     C                   endif
     C                   goto      endsc4
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk4
     C     error         cabeq     *on           endsc4
     C                   exsr      zzupd4
     C     error         cabeq     *on           endsc4
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     C     endsc4        endsr
     *----------------------------------------------------------------
     *
     *  SC5  -  Screen 5
     *
     C     sc5           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc5
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr05i
     C                   goto      endsc5
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scr02i
     C                   goto      endsc5
     C                   endif
     *
     *  Test for other command keys
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd5
     C     cmdtkn        cabeq     *on           endsc5
     C     redspl        cabeq     *on           endsc5
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk5
     C     error         cabeq     *on           endsc5
     C                   exsr      zzupd5
     C     error         cabeq     *on           endsc5
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd5
     C     cmdtkn        cabeq     *on           endsc5
     *
     C     endsc5        endsr
     *----------------------------------------------------------------
     *
     *  SC6  -  Screen 6
     *
     C     sc6           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   exsr      zzrcvpoclose
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc6
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr06i
     C                   goto      endsc6
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      zzrcvpoclose
     C                   exsr      scr05i
     C                   goto      endsc6
     C                   endif
     *
     *  Test for other command keys
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd6
     C     cmdtkn        cabeq     *on           endsc6
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk6
     C     error         cabeq     *on           endsc6
     C                   exsr      zzupd6
     C     error         cabeq     *on           endsc6
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd6
     C     cmdtkn        cabeq     *on           endsc6
     *
     C     endsc6        endsr
     *----------------------------------------------------------------
     *
     *  SC7  -  Screen 7
     *
     C     sc7           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc7
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr07i
     C                   goto      endsc7
     C                   endif
     *
     *  Test for F12 - Previous
     *
     *
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd7
     C     cmdtkn        cabeq     *on           endsc7
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk7
     C     error         cabeq     *on           endsc7
     C                   exsr      zzupd7
     C     error         cabeq     *on           endsc7
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd7
     C     cmdtkn        cabeq     *on           endsc7
     *
     C     endsc7        endsr
     *----------------------------------------------------------------
     *
     *  SC8  -  Screen 8
     *
     C     sc8           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     *
     C                   eval      refrsh = *off
     *
     *    Lot tracking item. Return to Lot entry screen.
     C                   if        lottrk = '*YES'
     C                   exsr      scr09i
     C                   else
     C                   exsr      scr03i
     C                   endif
     C                   goto      endsc8
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr08i
     C                   goto      endsc8
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     *
     *    Lot tracking item. Return to Lot entry screen.
     C                   if        lottrk = '*YES'
     C                   exsr      scr09i
     C                   else
     C                   exsr      scr03i
     C                   endif
     C                   goto      endsc8
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd8
     C     cmdtkn        cabeq     *on           endsc8
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk8
     C     error         cabeq     *on           endsc8
     C                   exsr      zzupd8
     C     error         cabeq     *on           endsc8
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd8
     C     cmdtkn        cabeq     *on           endsc8
     *
     C     endsc8        endsr
     *----------------------------------------------------------------
     *
     *  SC9  -  Screen 9
     *
     C     sc9           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   exsr      scr03i
     C                   goto      endsc9
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr09i
     C                   goto      endsc9
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     C                   exsr      scr03i
     C                   goto      endsc9
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd9
     C     cmdtkn        cabeq     *on           endsc9
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk9
     C     error         cabeq     *on           endsc9
     C                   exsr      zzupd9
     C     error         cabeq     *on           endsc9
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd9
     C     cmdtkn        cabeq     *on           endsc9
     *
     C     endsc9        endsr
     *----------------------------------------------------------------
     *
     *  SC10 -  Screen 10
     *
     C     sc10          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inki
     C                   exsr      scr03i
     C                   goto      endsc10
     C                   endif
     *
     *
     *  Test for other command keys
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd10
     C     cmdtkn        cabeq     *on           endsc10
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk10
     C     error         cabeq     *on           endsc10
     C                   exsr      zzupd10
     C     error         cabeq     *on           endsc10
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd10
     C     cmdtkn        cabeq     *on           endsc10
     *
     C     endsc10       endsr
     *----------------------------------------------------------------
     *
     *  SC11 -  Screen 11
     *
     C     sc11          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkl
     c                   if        GoodLcns = *on
     c                   exsr      scr13i
     c                   else
     c                   eval      $po201rtn = '*CANCEL'
     C                   eval      nxtscr = 'EOJ'
     c                   endif
     C                   goto      endsc11
     C                   endif
     *
     *
     *  Test for other command keys
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd11
     C     cmdtkn        cabeq     *on           endsc11
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk11
     C     error         cabeq     *on           endsc11
     C                   exsr      zzupd11
     C     error         cabeq     *on           endsc11
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd11
     C     cmdtkn        cabeq     *on           endsc11
     *
     C     endsc11       endsr
     *----------------------------------------------------------------
     *
     *  SC12 -  Screen 12
     *
     C     sc12          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkl
     c                   if        GoodLcns = *on
     c                   exsr      scr13i
     c                   else
     c                   eval      $po201rtn = '*CANCEL'
     C                   eval      nxtscr = 'EOJ'
     c                   endif
     C                   goto      endsc12
     C                   endif
     *
     *
     *  Test for other command keys
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd12
     C     cmdtkn        cabeq     *on           endsc12
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk12
     C     error         cabeq     *on           endsc12
     C                   exsr      zzupd12
     C     error         cabeq     *on           endsc12
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd12
     C     cmdtkn        cabeq     *on           endsc12
     *
     C     endsc12       endsr
     *----------------------------------------------------------------
     *
     *  SC13 -  Screen 13
     *
     C     sc13          begsr
     c                   exsr      zzrcvpocheck
     *
     *  Test for F12 - Previous
     *
      /free
        if *inkl;
          nxtscr = '11 ';
          leavesr;
        endif;

      /end-free
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzupdcnl
     c                   if        *inka
     C                   eval      nxtscr = 'EOJ'
     c                   endif
     *
     C     endsc13       endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *  Get client id.

     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10

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
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     * ************ DO NOT USE  -  USE CLCDUR2 INSTEAD **************
     *                                                                   DOC
     C     gtoj$         begsr
     C                   eval      g$date = g$date
     * SPLIT DATE INTO MONTH, DAY, YEAR FIELDS
     C                   if        dtfrmt = 1
     C                   movel     g$date        g$yy
     C                   move      g$date        work4
     C                   movel     work4         g$mm
     C                   move      work4         g$dd
     C                   else
     C                   movel     g$date        g$mm
     C                   move      g$date        work4
     C                   movel     work4         g$dd
     C                   move      work4         g$yy
     C                   endif
     * CREATE 4 DIGIT YEAR
     C                   move      g$yy          g$yyyy
     C                   if        g$yy >= 60
     C                   movel     '19'          g$yyyy
     C                   else
     C                   movel     '20'          g$yyyy
     C                   endif
     C                   eval      g$jd = 0
     C                   eval      g$mmwk = g$mm - 3
     C                   eval      gmwksv = g$mmwk
     C                   if        g$mmwk < 0
     C                   add       12            g$mmwk
     C                   endif
     C                   if        gmwksv <> 0
     C                   eval(h)   g$jd = g$mmwk * 30.6
     C                   endif
     C                   add       g$dd          g$jd
     C     g$yyyy        sub       1900          g$yywk
     C                   if        g$yywk <> 0
     C                   if        gmwksv < 0
     C                   eval      g$yywk = g$yywk - 1
     C                   endif
     C                   endif
     C                   eval      g$jyd = g$yywk * 365.25
     C                   add       g$jyd         g$jd
     C     g$jd          div       7             g$wk7
     C                   mvr                     g$dw
     C                   endsr
     *----------------------------------------------------------------
     *
     * ************ DO NOT USE  -  USE CLCDUR2 INSTEAD **************
     *                                                                   DOC
     C     jtog$         begsr
     C     j$jd          div       365.25        j$yywk
     C     j$jd          div       365.25        j$tst
     C                   if        j$tst = 0
     C                   eval      j$yywk = j$yywk - 1
     C                   endif
     C                   eval      j$yd = j$yywk * 365.25
     C                   eval      j$yd = j$jd - j$yd
     C                   if        j$yd > 306
     C                   add       1             j$yywk
     C                   endif
     C                   eval      j$x = 0
     C                   dou       j$yd <= j$md
     C                   add       1             j$x
     C     j$x           mult(h)   30.6          j$md
     C                   enddo
     C                   eval      j$x = j$x - 1
     C     j$x           mult(h)   30.6          j$md
     C     j$yd          sub       j$md          j$dd
     C     j$x           add       3             j$mm
     C                   if        j$mm > 12
     C                   eval      j$mm = j$mm - 12
     C                   endif
     C     j$yywk        add       1900          j$yyyy
     C                   if        dtfrmt = 1
     C                   move      j$yyyy        work2
     C                   movel     j$mm          work4
     C                   move      j$dd          work4
     C                   movel     work2         j$date
     C                   move      work4         j$date
     C                   else
     C                   move      j$yyyy        work2
     C                   movel     j$mm          work4
     C                   move      j$dd          work4
     C                   move      work2         j$date
     C                   movel     work4         j$date
     C                   endif
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   select
     C                   when      #lline = '16'
     C                   write     m16ctl
     C                   other
     C                   write     msgctl
     C                   endsl
     C                   eval      msgk = *zeros
     C                   select
     C                   when      #lline = '16'
     C                   write     m16clr
     C                   other
     C                   write     msgclr
     C                   endsl
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   select
     C                   when      #lline = '16'
     C                   write     m16ctl
     C                   other
     C                   write     msgctl
     C                   endsl
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
     C                   select
     C                   when      e$lng  = 'SP'
     C                   eval      $msgf  = #msgsp
     C                   other
     C                   eval      $msgf  = #msgf
     C                   endsl
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
     C                   select
     C                   when      #lline = '16'
     C                   write     m16rec
     C                   other
     C                   write     msgrec
     C                   endsl
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
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
     C                   select
     C                   when      #lline = '16'
     C                   write     m16rec
     C                   other
     C                   write     msgrec
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *   PT13019  Warning: Entered catch weight not within +/- range.
     *
     C     zm19          begsr
     C                   eval      #msgid = 'PT13019'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO20001  Warning: Exp date comes before existing date.
     *
     C     zm2001        begsr
     C                   eval      #msgid = 'PO20001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO20022  DOCK number must be entered.
     *
     C     zm022         begsr
     C                   eval      #msgid = 'PO20022'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO20023  UPC number must be entered.
     *
     C     zm023         begsr
     C                   eval      #msgid = 'PO20023'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO20026  Line not in P.O.
     *
     C     zm026         begsr
     C                   eval      #msgid = 'PO20026'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   eval      erpo = wopo
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO20027  Item not on PO.
     *
     C     zm027         begsr
     C                   eval      #msgid = 'PO20027'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO20028  Different UPC entered.
     *
     C     zm028         begsr
     C                   eval      #msgid = 'PO20028'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO20029  UPC not on file.
     *
     C     zm029         begsr
     C                   eval      #msgid = 'PO20029'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO20030  Item or Line must be entered.
     *
     C     zm030         begsr
     C                   eval      #msgid = 'PO20030'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO20031  Item has UPC for vendor.
     *
     C     zm031         begsr
     C                   eval      #msgid = 'PO20031'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO20032  No UPC entered.
     *
     C     zm032         begsr
     C                   eval      #msgid = 'PO20032'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO20033  License # required.
     *
     C     zm033         begsr
     C                   eval      #msgid = 'PO20033'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO20034  License already exists.
     *
     C     zm034         begsr
     C                   eval      #msgid = 'PO20034'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO20035  Multiple items exist for UPC
     *
     C     zm035         begsr
     C                   eval      #msgid = 'PO20035'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO15021  P.O. number must be entered.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'PO15021'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PT13023  Warning: Tot c/w not within +/- range.
     *
     C     zm23          begsr
     C                   eval      #msgid = 'PT13023'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PO23701  Mixed Lots on License.
     *
     C     zm3701        begsr
     C                   eval      #msgid = 'PO23701'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PO23702  Mixed Expiration Dates on License
     *
     C     zm3702        begsr
     C                   eval      #msgid = 'PO23702'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   eval      #msgid = 'PIR7972'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     RC13073  Purchase order does not exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'RC13073'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVEAERRMSG    $MD,1
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
     *   PIR0110  Value must be > 0.
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1005  Value must be 'Y' or 'N'
     *
     C     zm1005        begsr
     C                   eval      #msgid = 'PIR1005'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1008  Date is required.
     *
     C     zm1008        begsr
     C                   eval      #msgid = 'PIR1008'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1009  Date must be > today's date.
     *
     C     zm1009        begsr
     C                   eval      #msgid = 'PIR1009'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13229  Item cannot be accepted.
     *
     C     zm3229        begsr
     C                   eval      #msgid = 'PO13229'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13230  Item cannot be accepted - Exp Date
     *
     C     zm3230        begsr
     C                   eval      #msgid = 'PO13230'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13231  Warning: Exp date comes before existing date.
     *
     C     zm3231        begsr
     C                   eval      #msgid = 'PO13231'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13232  Item cannot be accepted - Calc Exp Date
     *
     C     zm3232        begsr
     C                   eval      #msgid = 'PO13232'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13233  Warning: Calc exp date comes before existing date.
     *
     C     zm3233        begsr
     C                   eval      #msgid = 'PO13233'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13234  CW must be zero when Avg = 'Y' for "First time"
     *
     C     zm3234        begsr
     C                   eval      #msgid = 'PO13234'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13243  Item cannot be accepted. # of days out
     *
     C     zm3243        begsr
     C                   eval      #msgid = 'PO13243'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     TF17201  Warning: Quantity received not equal to ordered.
     *
     C     zm7201        begsr
     C                   eval      #msgid = 'TF17201'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
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
     *----------------------------------------------------------------
     *    PIR1010  Date must be <OR= today's date.
     *
     C     zm1010        begsr
     C                   eval      #msgid = 'PIR1010'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    ZM13250  Item not date sensitive.
     *
     C     zm13250       begsr
     C                   eval      #msgid = 'PO13250'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO21001  Multiple qty entered, Catch wt avg must be 'N'
     *
     C     zm2101        begsr
     C                   eval      #msgid = 'PO21001'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13226  cannot receive an item, if ready for export.
     *
     C     zm3226        begsr
     C                   eval      #msgid = 'PO13226'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13228  Item cannot be accepted.
     *
     C     zm3228        begsr
     C                   eval      #msgid = 'PO13228'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *    Verify warehouse and get description.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = $pwhse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *  P.O. number must be entered.
     *
     C                   if        w1po = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   exsr      zm21
     C                   endif
     *
     *  Verify P.O. number.
     *
     C                   if        w1po <> *blanks
     C                   eval      wopo = w1po
     C     fileky        chain(n)  pohdr                              79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   exsr      zm73
     C                   endif
     C                   endif
     *
     *  Super PO is not allowed.
     *
      /free
        chain ($pwhse: wopo) pospo;
        if %found(pospo);
          error = *on;
          *in21 = *on;
          *in01 = *on;
          select;
            when e$lng = 'SP';
              errmsg = descsp(8);
            other;
              errmsg = desc(8);
          endsl;
          exsr zm0105;
        endif;
      /end-free
     **
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     C                   eval      noupc = *off
     c                   exsr      zzrcvpocheck
     c                   eval      $bcGtinSent = '0'
     *
     *    Confirm Retail UPC on file before continuing with receiving.
     *
     C                   if        svrupc = 'Y'  and
     C                             w2upc > *blanks
     C                   exsr      zzrupc
     C     error         cabeq     *on           endck2
     C                   endif
     *
     *   Cannot receive an item, if the PO is ready for export.
     *
     C                   if        phstat = '3'
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   exsr      zm3226
     C                   goto      endck2
     C                   endif
     *
     *  UPC not entered.
     *
     C                   if        w2upc = *blanks
     C                   eval      noupc = *on
     C                   eval      woupc = *blanks
     C                   endif
     c                   if        w2upc <> *blanks
      * add the conversion of the uci barcode
     C                   eval      $cbcmd = '*ALL    '
     C                   eval      $cbbar = w2upc
     c                   clear                   $barcode
     c                   clear                   $barcode2
     *
     C                   call      'CVTBAR'
     C                   parm                    $cbcmd            8
     C                   parm                    $cbbar          100
     C                   parm                    $cbcod            3 0
     C                   parm                    $cbdec            1 0
     C                   parm                    $cbdsc           30
     C                   parm                    $cbpos            3 0
     C                   parm                    $cbtyp            1 0
     C                   parm                    $cbv1            11 3
     C                   parm                    $cbv2            50
     C                   parm                    $cbrtn            8
     C                   parm                    $cberm           60
740dDC*                  parm      phven         $cbven           10 0
740dMC                   parm      $itven#       $cbven           10 0
     C                   parm                    $cvtdata
     C                   parm                    $cvtdata2
     c                   endif
     c                   if        $cbrtn = '*NOMORE'
740dAc                             or $cbrtn = '*OK'
     c                   eval      $barcode = $cvtdata
     c                   eval      $barcode2 = $cvtdata2
     c                   endif
      * Load UPC
     c                   if        $bcGtinSent
     c                   else
      ** Needed this because all barcodes are not gs1
     c*                  eval      w1upcd = w11uci
     c* if $bcgtinsent is not on we don't know what item this is.
     c* so turn off all the other $bc sent fields, without the item non of
     c* these are valid for our receiving purposes.
     c                   eval      $bcExpDSent = *off
     c                   eval      $bcSlByDSent = *off
     c                   eval      $bcProdDSent = *off
     c                   eval      $bcPackDSent = *off
     c                   eval      $bcPNtLbSent = *off
     c                   eval      $bcLotSent = *off
     c                   endif
      * Load Expiration Date
     c                   select
     c                   when      $bcExpDSent
     C                   move      $bcExpd       $cvd6i
     C                   eval      $cvcmd = '*YMDMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        w8dte
     c                   when      $bcSlByDSent
     C                   move      $bcSlByD      $cvd6i
     C                   eval      $cvcmd = '*YMDMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        w8dte
     c                   endsl
      * Load Manufacturing Date
     c                   if        $bcProdDSent
     C                   move      $bcProdD      $cvd6i
     C                   eval      $cvcmd = '*YMDMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        w8dte
     c                   endif
      * Load Manufacturing Date
     c                   if        $bcPackDSent
     C                   move      $bcPackD      $cvd6i
     C                   eval      $cvcmd = '*YMDMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        w8dte
     c                   endif
      * Load Catch Weight
     c                   if        $bcPNtLbSent
     c                             and $ifrcvmth = '2'
     c                   eval      w8dwgt  = $bcPNtLb
     c                   endif
      * Load Lot
     c                   if        $bcLotSent
     c                   eval      w9lotc  = $bcLot
     c                   eval      *in85 = *on
     c                   endif
     *
     *  UPC code not on file.
     *
     C                   if        w2upc <> *blanks
     C                   eval      $cbcmd = '*UPC    '
     C                   movel     w2upc         $cbbar
     C                   call      'CVTBAR'
     C                   parm                    $cbcmd            8
     C                   parm                    $cbbar          100
     C                   parm                    $cbcod            3 0
     C                   parm                    $cbdec            1 0
     C                   parm                    $cbdsc           30
     C                   parm                    $cbpos            3 0
     C                   parm                    $cbtyp            1 0
     C                   parm                    $cbv1            11 3
     C                   parm                    $cbv2            50
     C                   parm                    $cbrtn            8
     C                   parm                    $cberm           60
740dMC                   parm      $itven#       $cbven           10 0
740dAC                   parm                    $cvtdata
740dAC                   parm                    $cvtdata2
     *
     C                   if        $cbrtn = '*OK'
     C                   eval      w2upc = $cbv2
     C                   endif
     *
     **                   MOVE W2UPC     WOUPC
     C                   movel     w2upc         woupc
     *
     *   Left adjust UPC code for display.
     *
     *R                   MOVEL*BLANKS   $CSTR
     *R                   MOVELW2UPC     $CSTR
     *R                   CALL 'ADJUST'
     *R                   PARM '*LEFT   '$CCMD   8
     *R                   PARM           $CSTR  30
     *R                   MOVEL$CSTR     WOUPC
     *
     *   Right adjust UPC code for file.
     *
     C                   eval      $cstr = *blanks
     C                   movel     w2upc         $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
     **                   MOVE $CSTR     W2UPC
     C                   move      $cstr         kyupc
     *   Check if mulitple items exist for one UPC code.
     *    UPCCTR = 0, error, upc code not found.
     *    UPCCTR = 1, only one upc found, process for item.
     *    UPCCTR > 1, multiple upc found, need to select item.
     C                   eval      upcctr = 0
     c                   eval      svupci = ' '
     C     upckey        setll     upc4
     C                   dow       forevr = forevr
     C     upckey        reade     upc4                                   79
     *
     C                   if        *in79
     C                   leave
     C                   else
     *
     C                   if        svupci <> upitem
     C                   add       1             upcctr
     C                   eval      svupci = upitem
     C                   endif
     *
     C                   endif
     *
     C                   enddo
     *
     *R         UPCKEY    CHAINUPC                  79
     **         UPCKEY    CHAINUPC                 N79
     **         *IN79     IFEQ *ON
     C                   if        upcctr = 0
     *R                   MOVE *ON       ERROR
     *R                   MOVE *ON       *IN29
     *R                   MOVE *ON       *IN09
     *R                   EXSR ZM029
     C                   if        $cbrtn <> '*OK'
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   movel     $cberm        errmsg
     C                   exsr      zm0105
     C                   goto      endck2
     C                   endif
     C                   eval      noupc = *on
     C                   endif
     *   Multiple items exist for UPC
     C                   if        upcctr > 1
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   exsr      zm035
     C                   goto      endck2
     C                   endif
     *
     *
     *   Verify Item exists on PO.
     *
     C                   if        noupc = *off
     C                   eval      woitm# = upitem
     C     podky1        setll     podtl1                             79
     C     podky1        reade     podtl1                                 79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   exsr      zm027
     C                   else
     C                   eval      woline = pdseq
     C                   eval      woitm# = pditem
     C                   endif
     C                   endif
     *
     C                   endif
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     *
     C     zzchk3        begsr
     C                   eval      error = *off
     C                   eval      errflg = *off
     c                   exsr      zzrcvpocheck
     *
     *   Save screen fields.
     *
     C                   eval      sdqrc1 = w3qt01
     C                   eval      sdqrc2 = w3qt02
     *
     C     endck3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK4   Screen 4 error checking.
     *
     C     zzchk4        begsr
     C                   eval      error = *off
     c                   exsr      zzrcvpocheck
     *
     C     endck4        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK5   Screen 5 error checking.
     *
     C     zzchk5        begsr
     C                   eval      error = *off
     C                   eval      errflg = *off
     c                   exsr      zzrcvpocheck
     *
     *    Confirm Retail UPC on file before continuing with receiving.
     *
     C                   if        svrupc = 'Y'  and
     C                             w4line <> 0  or
     C                             svrupc = 'Y'  and
     C                             w4item > *blanks
     C                   exsr      zzrupc
     C     error         cabeq     *on           endck5
     C                   endif
     *
     *  Item # or Line # must be entered.
     *
     C                   if        w4line = 0  and
     C                             w4item = *blanks
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   exsr      zm030
     C                   endif
     *   Verify Line #.
     *
     C                   if        w4line <> 0
     C                   eval      woline = w4line
     C     partky        setll     podtl                              79
     C     partky        reade     podtl                                  79
     C                   if        *in79
     *R                   MOVE WOPO      ERPO
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   exsr      zm026
     C                   else
     C                   eval      woline = pdseq
     C                   eval      woitm# = pditem
     C                   endif
     C                   endif
     *
     *   Verify Item #.
     *
     C                   if        w4item <> *blanks
     *
     *  Call API for item.
     *
     C                   call      @apici
     C                   parm                    w4item
     C                   parm      6             worow             3 0
     C                   parm      7             wocol             3 0
     C                   parm                    @artn             8
     C                   if        @artn = '*REDSPLY'
     *R                   MOVE *ON       REDSPL
     *R                   GOTO ENDCK5
     C                   endif
     *
     C                   eval      woitm# = w4item
     C     podky1        setll     podtl1                             79
     C     podky1        reade     podtl1                                 79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   exsr      zm027
     C                   else
     C                   eval      woline = pdseq
     C                   eval      woitm# = pditem
     C                   endif
     C                   endif
     *
     *
     *
     C     endck5        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK6   Screen 6 error checking.
     *
     C     zzchk6        begsr
     C                   eval      error = *off
     C                   eval      errflg = *off
     c                   exsr      zzrcvpocheck
     *
     C                   eval      $cbcmd = '*UPC    '
     C                   eval      $cbbar = w6upc
     C                   call      'CVTBAR'
     C                   parm                    $cbcmd
     C                   parm                    $cbbar
     C                   parm                    $cbcod
     C                   parm                    $cbdec
     C                   parm                    $cbdsc
     C                   parm                    $cbpos
     C                   parm                    $cbtyp
     C                   parm                    $cbv1
     C                   parm                    $cbv2
     C                   parm                    $cbrtn
     C                   parm                    $cberm
740dMC                   parm      $itven#       $cbven           10 0
740dAC                   parm                    $cvtdata
740dAC                   parm                    $cvtdata2
     *
     C                   if        $cbrtn = '*OK'
     C                   eval      w6upc = $cbv2
     c                   eval      ntype = %trimr($cbdsc)
     C                   endif
     *
     **                   MOVE W6UPC     S6UPC  20
     C                   movel     w6upc         s6upc
     *
     *   Right adjust UPC code.
     *
     C                   eval      $cstr = *blanks
     C                   movel     w6upc         $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     **                   MOVE $CSTR     W6UPC
     C                   move      $cstr         kyupc
     *
     *   Verify UPC.
     *
     C                   if        s6upc <> woupc
     C                   eval      error = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   exsr      zm028
     C                   endif
     *
     *   Verify UPC doesn't exist for item,vendor.
     *
     *R         UPCKY1    CHAINUPC1                 79
     *R         *IN79     IFEQ *OFF
     *R                   MOVE *ON       ERROR
     *R                   MOVE *ON       *IN28
     *R                   MOVE *ON       *IN08
     *R                   EXSR ZM031
     *R                   ENDIF
     *
     C     endck6        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK7   Screen 7 error checking.
     *
     C     zzchk7        begsr
     C                   eval      error = *off
     c                   exsr      zzrcvpocheck
     *
     *  License # must be entered.
     *
     **         W7LCNS    IFEQ 0
     C                   if        w7lcns = *blanks
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   exsr      zm033
     C                   endif
     *
     *  Left justify license.
     C                   eval      $cstr = *blanks
     C                   move      w7lcns        $cstr
     C                   call      'ADJUST'
     *R                   PARM '*LEFT   '$CCMD   8
     C                   parm      '*LEFTNOZ'    $ccmd
     C                   parm                    $cstr
     C                   movel     $cstr         w7lcns
     *
     C                   eval      *in81 = *off
     C     valid         check     w7lcns                                 81
     *
     *  *IN81 = *ON - One of the positions did not have valid value
     *
     C                   if        *in81
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   select
     C                   when      e$lng = 'SP'
     C                   eval      errmsg = descsp(6)
     C                   other
     C                   eval      errmsg = desc(6)
     C                   endsl
     C                   exsr      zm1001
     C                   endif
     *
     *  License # must be unique.
     *
     C     lcnsky        setll     license                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   exsr      zm034
     C                   endif
     *
     C     endck7        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK8   Screen 8 error checking.
     *
     *   OAOVR = Manufacture date override, Caluclated exp date
     *           comes before existing overflow exp date. (PO13233)
     *   OBOVR = Manufacture date override, Manufacture date entered
     *           is greater than today.(PIR1010)
     *   OCOVR = Expiration date override, Expiration date is greater
     *           than allowed # of days out. (PO13243)
     *   ODOVR = Use by date override, Not enough user/dist days to
     *           sell before expiration date (PO13229)
     *   OEOVR = Mfg date override, Not enough user/dist days to
     *           sell before calculated expiration date (PO13228)
     *   OFOVR = Expiration date override, Expiration date entered
     *           comes before existing overflow exp date. (PO13231)
     *   DTCHK, WTCHK Flags are used to force F20 for each test
     *   DTCHK2, DTCHK3, DTCHK4
     *   Values: Flag = 0 Do check.
     *           Flag = 1 Check was done, ok.
     *           Flag = 2 Warning condition.
     *
     C     zzchk8        begsr
     C                   eval      error = *off
     C                   eval      errflg = *off
     c                   exsr      zzrcvpocheck
     C                   eval      w8mfdt = 0
     **                   Z-ADD0         MFGD
     C                   eval      w8exdt = 0
     **                   Z-ADD0         EXPD
     *
     *  Move screen date into correct date check field.
     *
     C                   select
     C                   when      immflg = 'Y'
     C                   eval      w8mfdt = w8dte
     C                   eval      w8exdt = 0
     C                   eval      svexdt = 0
     C                   when      itflgd = 'Y'
     C                   eval      w8exdt = w8dte
     C                   eval      w8mfdt = 0
     C                   eval      svmfdt = 0
     C                   endsl
     *
     *  Verify expiration date.
     *
     C                   if        itflgd = 'Y'  and
     C                             immflg <> 'Y'
     C                   if        w8exdt = 0
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1008
     C                   else
     *  Moved code here to calculate CKEXDT
     *  Verify Expiration date is within parameter (# of days out)     days)
     *  Calculate (Today + # days out)  = CKEXDT                       days)
     *
     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      today         $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      imoday        $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     ckexdt        parm      0             $cddateout
     C                   parm      0             $cdtimeout

     *
     C                   if        w8exdt <> 0
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w8exdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      #msgk = $cvmsg
     C                   goto      enderr
     C                   else
     C                   move      $cvd6o        w8exdt
     C                   eval      $cvcmd = '*MDYCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        expd
     C                   move      $cvd8o        woexdt
     C                   if        expd <= today
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1009
     C                   endif
     *  Code to calculate CKEXDT was moved from here to above.
     *
     *  Verify Use by date.                                            days)
     *  Calculate (Today + Dist Days)  = DATE1                         days)
     *  Calculate  (Use By - User Days) = DATE2                        days)
     *
     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      today         $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      imdday        $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     date1         parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      expd          $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      imuday        $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     date2         parm      0             $cddateout
     C                   parm      0             $cdtimeout
     *
     C                   move      date2         $cvd8i
     C                   eval      $cvcmd = '*CMDMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        date2o
     *
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     ***
     *  Verify Expire date and # of days out                           days)
     *  Allow warning and override                                     days)
     C                   if        expd <> 0     and
     C                             w8exdt <> 0
     C                   if        svexdt <> w8exdt
     C                   eval      dtchk = *off
     C                   eval      ocovr = *off
     C                   endif
     *
     C                   if        dtchk = '2'  and
     C                             ovrrid = *on
     C                   eval      ocovr = *on
     C                   eval      dtchk = *on
     C                   endif
     *
     C                   if        dtchk <> '1'
     C                   eval      dtchk = *on
     *
     *   If EXPD > /CKEXDT - Reject.
     *
     C                   if        expd > ckexdt
     C                   eval      error = *on
     C                   eval      dtchk = '2'
     C                   eval      warn = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   eval      erused = w8exdt
     C                   eval      erdisd = imoday
     C                   exsr      zm3243
     C                   endif
     *
     C     error         cabeq     *on           enderr
     *
     C                   endif
     C                   eval      expd = date2
     C                   endif
     *
     *
     *  Verify Use by date.                                            days)
     *  Change to use DTCHK3 for override                              days)
     **         EXPD      IFNE 0
     C                   if        w8exdt <> 0
     C                   if        svexdt <> w8exdt
     C                   eval      dtchk3 = *off
     C                   endif
     *
     C                   if        dtchk3 = '2'  and
     C                             ovrrid = *on
     C                   eval      odovr = *on
     C                   eval      dtchk3 = *on
     C                   endif
     *
     C                   if        dtchk3 <> '1'
     C                   eval      dtchk3 = *on
     *
     *
     *   If DATE2 <= Date1 - Reject.
     *
     C                   if        date2 <= date1
     C                   eval      error = *on
     C                   eval      dtchk3 = '2'
     C                   eval      warn = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   eval      erused = w8exdt
     C                   eval      erdisd = imdday
     C                   eval      erusrd = imuday
     C                   eval      ersell = date2o
     C                   exsr      zm3229
     C                   endif
     *
     C     error         cabeq     *on           enderr
     *
     C                   endif
     C                   eval      expd = date2
     C                   endif
     *
     *  Change to use DTCHK4 for override                                  )
     C                   if        svmfdt <> w8mfdt  or
     C                             w8mfdt = 0
     C                   eval      dtchk4 = *off
     C                   endif
     *
     C                   if        dtchk4 = '2'  and
     C                             ovrrid = *on
     C                   if        mfgd > today
     C                   eval      obovr = *on
     C                   endif
     C                   if        today > ltstd8
     C                   eval      oeovr = *on
     C                   endif
     C                   eval      dtchk4 = *on
     C                   endif
     *
     C                   if        dtchk4 = '1'
     C                   eval      w8exdt = svexdt
     C                   endif
     *
     C                   if        dtchk4 <> '1'
     C                   eval      dtchk4 = *on
     *
     *  Verify manufacturing date.
     *
     C                   select
     C                   when      immflg = 'Y'
     C                   if        w8mfdt = 0
     C                   eval      error = *on
     C                   eval      dtchk4 = *off
     C                   eval      obovr = *off
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1008
     c                   goto      endck8
     C                   else
     C                   if        w8mfdt <> 0
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w8mfdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      dtchk4 = *off
     C                   eval      obovr = *off
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      #msgk = $cvmsg
     **                   EXSR ZMQMSG
     C                   goto      enderr
     C                   else
     C                   move      $cvd6o        w8mfdt
     C                   eval      $cvcmd = '*MDYCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        mfgd
     C                   if        mfgd > today
     C                   eval      error = *on
     C                   eval      dtchk4 = *off
     C                   eval      obovr = *off
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1010
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     *
     *  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
     *
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w8mfdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        expd

     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      expd          $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      immday        $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C                   parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      $cddateout    $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      imuday        $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     expd          parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      expd          $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        w8exdt

     *
     *  Find the latest acceptable date.: Exp date -Dist days
     *
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w8exdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        ltstd8

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      ltstd8        $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      imdday        $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     ltstd8        parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ltstd8        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        ltstd6

     *
     *   If Today's date is > Latest acceptable date - Reject.
     *
     C                   if        today > ltstd8
     C                   eval      error = *on
     C                   eval      oeovr = *off
     C                   eval      dtchk4 = '2'
     C                   eval      warn = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ermday = immday
     C                   eval      ermfdt = w8mfdt
     C                   eval      erexdt = w8exdt
     C                   eval      erltst = ltstd6
     C                   eval      erdday = imdday
     C                   eval      eruday = imuday
     C                   exsr      zm3228
     C                   endif
     C                   endsl
     *
     C     error         cabeq     *on           enderr
     C                   endif
     *
     *   Check for ealier expiration dates (optional)                  days)
     *
     *     See if we can skip the check.                               days)
     *
     C                   if        w8exdt = 0  or
     C                             svexck <> '2'  and
     C                             svexck <> '3'
     C                   goto      skpxck
     C                   endif
     *
     *     Set warning check flag.                                     days)
     *
     C                   if        svexdt <> w8exdt
     C                   eval      dtchk2 = *off
     C                   eval      oaovr = *off
     C                   eval      ofovr = *off
     C                   endif
     *
     C                   if        dtchk2 = '2'  and
     C                             ovrrid = *on
     C                   if        immflg = 'Y'
     C                   eval      oaovr = *on
     C                   else
     C                   eval      ofovr = *on
     C                   endif
     C                   eval      dtchk2 = *on
     C                   goto      skpxck
     C                   endif
     *
     C     dtchk2        cabeq     '1'           skpxck
     *
     *     Do actual check                                             days)
     *
     C                   eval      dtchk2 = *on
     *
     *       Get date range of overflow slots.
     *
     C                   call      'GETEXPD'
     C                   parm      $pwhse        $swhse            3 0
     C                   parm                    #sitem
     **                   PARM           #BITEM
     C                   parm                    $dfrom            8 0
     C                   parm                    $dto              8 0
     *
     *       If date comes after end of range
     *         Then date can be recevied so skip the rest of the check
     *
     C                   if        expd >= $dto
     C                   goto      skpxck
     C                   endif
     *
     *       Otherwise, see if it's an error or warning.
     *
     *         '1' = Allow Let it go through
     *         '2' = Error (Not Allowed)
     *         '3' = Warning.
     *
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   eval      erentd = expd
     C                   eval      ertod = $dto
     C                   select
     C                   when      svexck = '2'
     C                   eval      dtchk2 = *off
     C                   if        immflg = 'Y'
     C                   exsr      zm3232
     C                   else
     C                   exsr      zm3230
     C                   endif
     C                   when      svexck = '3'
     C                   eval      dtchk2 = '2'
     C                   eval      warn = *on
     C*                  eval      cwovr = *on
     C                   if        immflg = 'Y'
     C                   eval      oaovr = *on
     C                   exsr      zm3233
     C                   else
     C                   eval      ofovr = *on
     C*                  exsr      zm3231
     C                   exsr      zm2001
     C                   endif
     C                   endsl
     *
     C     error         cabeq     *on           enderr
     *
     C     skpxck        tag
     *
     *  See if we need to verify catch weight.
     *
     C     vrfycw        cabeq     *off          skipcw
     *
     *  CW can't be zero if forced entry is selected.
     *
     *    One exception for 'First time only' entry with Avg = 'Y'
     *
     C                   if        svcwfr = 'Y'  and
     C                             w8dwgt = 0
     C                   if        svcwen = '1'  or
     C                             svcwen = '2'  and
     C                             w8avg <> 'Y'
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      errmsg = *blanks
     C                   select
     C                   when      e$lng = 'SP'
     C                   eval      errmsg = descsp(4)
     C                   other
     C                   eval      errmsg = desc(4)
     C                   endsl
     C                   exsr      zm0110
     C                   endif
     C                   endif
     *
     *  Verify Catch weight average  (Y/N).
     *
     C                   if        w8avg <> 'Y'  and
     C                             w8avg <> 'N'
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   eval      errmsg = *blanks
     C                   select
     C                   when      e$lng = 'SP'
     C                   eval      errmsg = descsp(5)
     C                   other
     C                   eval      errmsg = desc(5)
     C                   endsl
     C                   exsr      zm1005
     C                   endif
     *
     *  When 'First time only' entry with Avg = 'Y'
     *    Then catch weight must be zero.
     *
     C                   if        svcwen = '2'  and
     C                             w8avg = 'Y'  and
     C                             w8dwgt <> 0
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm3234
     C                   endif
     *
     *
     *  When more than one qty is entered, catch weight average must be N
     *
     *    One exception for 'First time only' entry with Avg = 'Y'
     *
     C                   select
     C                   when      w3qt01 <> 0  and
     C                             w8avg = 'Y'  and
     C                             svcwen <> '2'
     C                   if        w3qt02 <> 0
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   eval      errmsg = *blanks
     C                   select
     C                   when      e$lng = 'SP'
     C                   eval      errmsg = descsp(5)
     C                   other
     C                   eval      errmsg = desc(5)
     C                   endsl
     C                   exsr      zm2101
     C                   endif
     *
     C                   when      w3qt02 <> 0  and
     C                             w8avg = 'Y'  and
     C                             svcwen <> '2'
     C                   if        w3qt01 <> 0
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   eval      errmsg = *blanks
     C                   select
     C                   when      e$lng = 'SP'
     C                   eval      errmsg = descsp(5)
     C                   other
     C                   eval      errmsg = desc(5)
     C                   endsl
     C                   exsr      zm2101
     C                   endif
     *
     C                   endsl
     *
     *  Skip catch weight variance check when ...
     *    "First time only" entry
     *
     C                   if        svcwen = '2'
     *      Skip variance check once qty has been received for item.
     C                             and (pdqrc1 > 0
     C                             or   pdqrc2 > 0
     C                             or   pdqrc3 > 0)
     C
     C                   goto      skipcw
     C                   endif
     *
     *  Catch weight variance check.
     *
     C                   if        svdwgt <> w8dwgt
     C                   eval      wtchk = *off
     C                   endif
     *
     C                   if        wtchk = '2'  and
     C                             ovrrid = *on
     C                   eval      wtchk = *on
     C                   endif
     *
     C                   if        wtchk <> '1'
     C                   eval      wtchk = *on
     *
     *   If catch weight >0,
     *     Calculate total expected catch weight,
     *     Calculate low/high ranges.
     *
     C                   if        w8dwgt <> 0
     C                   eval      lwvar = 0
     C                   eval      hivar = 0
     C                   eval      lwrng = 0
     C                   eval      hirng = 0
     C                   eval      exwgt = 0
     C                   eval      ilvar = 0
     C                   eval      ihvar = 0
     C                   eval      ilrng = 0
     C                   eval      ihrng = 0
     C                   eval      hostcw0 = 0
     C                   eval      hostcw2dec = 0
     *
     C                   if        w8avg = 'Y'
     C                   eval      exwgt = itswgt
     C*                  eval      wotcw = w8dwgt
     C                   eval      wotcw = savewgt
     C                   else
     C                   if        svcwen = '2'
     C     pdqor1        mult      itswgt        exwgt

     * If specific client, use imported c/w value for variance checking if
     * it's numeric, otherwise, use standard comparison tests.

     C                   eval      hostUnitWgt  = 0
     C                   eval      rcvUnitWgt  = 0

     C                   select
     C                   when      client = Dairyland
     C                   eval      hostcwa = %subst(pdmms1:9:7)
     C     digits        check     hostcwa                                68
     C                   if        *in68 = *off
     C                   eval      hostcw0 = %dec(%subst(pdmms1:9:7):7:0)
     C                   move      hostcw0       hostcw2dec

     C                   eval      qtyord  = 0
     C                   eval      qtyord1 = 0
     C                   eval      qtyord2 = 0
     C                   eval      qtyord3 = 0

     C                   if        pdqor1 > 0
     C                   eval      qtyord1 = pdqor1
     C                   if        itumq2 > 0
     C                   eval      qtyord1 = qtyord1 * itumq2
     C                   endif
     C                   if        itumq3 > 0
     C                   eval      qtyord1 = qtyord1 * itumq3
     C                   endif
     C                   endif

     C                   if        pdqor2 > 0
     C                   eval      qtyord2 = pdqor2
     C                   if        itumq3 > 0
     C                   eval      qtyord2 = qtyord2 * itumq3
     C                   endif
     C                   endif

     C                   if        pdqor3 > 0
     C                   eval      qtyord3 = pdqor3
     C                   endif

     C                   eval      qtyord = qtyord1 + qtyord2 + qtyord3

     C                   eval      exwgt = 0
     C                   eval      qtyrcv = 0
     C                   eval      qtyrcv1 = 0
     C                   eval      qtyrcv2 = 0

     C                   if        w3qt01 > 0
     C                   eval      qtyrcv1 = w3qt01
     C                   if        itumq2 > 0
     C                   eval      qtyrcv1 = qtyrcv1 * itumq2
     C                   endif
     C                   if        itumq3 > 0
     C                   eval      qtyrcv1 = qtyrcv1 * itumq3
     C                   endif
     C                   endif

     C                   if        w3qt02 > 0
     C                   eval      qtyrcv2 = w3qt02
     C                   if        itumq3 > 0
     C                   eval      qtyrcv2 = qtyrcv2 * itumq3
     C                   endif
     C                   endif

     C                   eval      qtyrcv = qtyrcv1 + qtyrcv2

     C                   eval      hostUnitWgt = hostcw2dec / qtyord
     C*                  eval      rcvUnitWgt = w8dwgt / qtyrcv
     C                   eval      rcvUnitWgt = savewgt / qtyrcv
     C                   eval      wgtDiff = hostUnitWgt - rcvUnitWgt
     C                   eval      caltol1 = %abs(wgtDiff) / hostUnitWgt

     C                   if           pdqor2 > 0
     C                             or w3qt02 > 0
     C                   eval      qtyDiff  = qtyord - qtyrcv
     C                   eval      caltol2  = %abs(qtyDiff) / qtyord
     C                   endif

     C                   else
     C     w3qt01        mult      itswgt        exwgt
     C                   endif
     C                   endsl

     C                   else
     C     w3qt01        mult      itswgt        exwgt
     C                   endif
     C*                  eval      wotcw = w8dwgt
     C                   eval      wotcw = savewgt
     C                   endif
     *
     *    Iniz. flag used to skip variance check if = *ON.
     *
     C                   eval      lvskp = *off
     C                   eval      hvskp = *off
     *
     **   Iniz. fields used to hold low/high variance.
     C                   eval      prg1c = 0
     C                   eval      prg2c = 0
     *
     *    Use item variance % if it exists
     *
     C                   if        imrg1c <> 0
     C     imrg1c        div       100           prg1c
     C                   if        imrg1c = 99
     C                   eval      lvskp = *on
     C                   endif
     C                   endif
     *
     C                   if        imrg2c <> 0
     C     imrg2c        div       100           prg2c
     C                   if        imrg2c = 99
     C                   eval      hvskp = *on
     C                   endif
     C                   endif
     *
     C                   if        prg1c = 0
     C     oprg1c        div       100           prg1c
     C                   endif
     C                   if        prg2c = 0
     C     oprg2c        div       100           prg2c
     C                   endif
     *
     *     Don't do following extended weight calcs if you're using
     *     Dairyland's imported c/w method for comparing wgt tolerance.
     C                   select
     C                   when      hostcw2dec = 0
     *
     C                   if        prg1c > 0
     C     exwgt         mult      prg1c         lwvar
     C                   eval      ilvar = itswgt * prg1c
     C                   endif
     C                   eval      lwrng = exwgt - lwvar
     C                   eval      ilrng = itswgt - ilvar
     C                   if        prg2c > 0
     C     exwgt         mult      prg2c         hivar
     C                   eval      ihvar = itswgt * prg2c
     C                   endif
     C     exwgt         add       hivar         hirng
     C     itswgt        add       ihvar         ihrng
     *
     C                   endsl
     C                   endif
     *
     *     Check CW variance if CW > 0
     *
     C                   if        w8dwgt <> 0
     C                   if        hostcw2dec > 0
     *     Use Dairyland's tests for comparing wgt and qty tolerances.
     C                   exsr      zzchkt1
     C                   else
     C                   exsr      zzchkt
     C                   endif
     C                   endif
     C     error         cabeq     *on           enderr
     C                   endif
     *
     C     skipcw        tag
     *
     C     enderr        tag
     *
     *   Save screen fields.
     *
     C                   eval      svdwgt = w8dwgt
     C                   eval      sdqrc1 = w3qt01
     C                   eval      sdqrc2 = w3qt02
     C                   eval      svmfdt = w8mfdt
     C                   eval      svexdt = w8exdt
     *
     C     endck8        endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  ZZCHK9   Screen 9 error checking.
     *
     C     zzchk9        begsr
     C                   eval      error = *off
     c                   exsr      zzrcvpocheck
     *
     *
     C     endck9        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCHK10  Screen 10 error checking.
     *
     C     zzchk10       begsr
     C                   eval      error = *off
     C                   eval      errflg = *off
     c                   exsr      zzrcvpocheck
     *
     C                   eval      $cbcmd = '*UPC    '
     C                   eval      $cbbar = w10upc
     C                   call      'CVTBAR'
     C                   parm                    $cbcmd
     C                   parm                    $cbbar
     C                   parm                    $cbcod
     C                   parm                    $cbdec
     C                   parm                    $cbdsc
     C                   parm                    $cbpos
     C                   parm                    $cbtyp
     C                   parm                    $cbv1
     C                   parm                    $cbv2
     C                   parm                    $cbrtn
     C                   parm                    $cberm
740dMC                   parm      $itven#       $cbven           10 0
740dAC                   parm                    $cvtdata
740dAC                   parm                    $cvtdata2
     *
     C                   if        $cbrtn = '*OK'
     C                   eval      w10upc = $cbv2
     c                   eval      btype = %trimr($cbdsc)
     C                   endif
     *
     *   Right adjust UPC code.
     *
     C                   eval      $cstr = *blanks
     C                   movel     w10upc        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         kyupc
     *
     C                   if        $cbrtn <> '*OK'
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   movel     $cberm        errmsg
     C                   exsr      zm0105
     C                   goto      endck10
     C                   endif
     C     endck10       endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK11  Screen 11 error checking.
     *
     C     zzchk11       begsr
     C                   eval      error = *off
     C                   eval      errflg = *off
     c                   exsr      zzrcvpocheck
      /free
        if w11uci <> ' ';
          exsr clr$uciinfo;
          $uiWhse = $pwhse;
          $uiuci  = w11uci;
          $uiitem = $poitm;

          $dricommand = '*UCIINFO';
          $drisubcmd  = '%CHKACTV';
          $drisys2upd = 'D';
          chk4err = *on;
          zmflag  = *off;
          exsr zzzdricop;
          // if return is *EXIST seton error
          if $drireturn = '*EXIST';
            error = *on;
            errmsg = 'UCI Barcode';
            exsr zm02;
            *in83 = *on;
            *in84 = *on;
            leavesr;
          endif;
        endif;
        if w11uci = ' ';
          error = *on;
          errmsg = 'Scan UCI';
          exsr zm0105;
          *in83 = *on;
          *in84 = *on;
          leavesr;
        endif;
        // validate upc code if for item
      /end-free
      * add the conversion of the uci barcode
     C                   eval      $cbcmd = '*ALL    '
     C                   eval      $cbbar = w11uci
     c                   clear                   $barcode
     c                   clear                   $barcode2
     *
     C                   call      'CVTBAR'
     C                   parm                    $cbcmd            8
     C                   parm                    $cbbar          100
     C                   parm                    $cbcod            3 0
     C                   parm                    $cbdec            1 0
     C                   parm                    $cbdsc           30
     C                   parm                    $cbpos            3 0
     C                   parm                    $cbtyp            1 0
     C                   parm                    $cbv1            11 3
     C                   parm                    $cbv2            50
     C                   parm                    $cbrtn            8
     C                   parm                    $cberm           60
740dDC*                  parm      phven         $cbven           10 0
740dMC                   parm      $itven#       $cbven           10 0
     C                   parm                    $cvtdata
     C                   parm                    $cvtdata2
     c                   if        $cbrtn = '*NOMORE'
740dAc                             or $cbrtn = '*OK'
     c                   eval      $barcode = $cvtdata
     c                   eval      $barcode2 = $cvtdata2
     c                   move      $bcgtin       ckupc
     c                   endif
      /free
        if $BCAI99SENT = *off;
          chain ($pwhse: ckupc: $poitm) upc4;
          if not %found(upc4);
            uputyp = ' ';
740bA       error = *on;
740bA       errmsg = 'Invalid UPC  - go back and load UPC';
740bA       exsr zm0105;
740bA       leavesr;
          endif;
        endif;
      /end-free
      /free
        // when date sensitive and date is missing
        *in84 = *on;
        select;
          when $immflg = 'Y' and $bcProdDSent;
          when $immflg = 'Y' and $bcPackDSent;
          when $itflgd = 'Y' and $bcExpDSent;
          when $itflgd = 'Y' and $bcSlByDSent;

          when $immflg = 'Y' and
               moretoscan= ' '  and
               w11dte = 0 and
               not $bcProdDSent and
               not $bcPackDSent;
            wodte = 'Mfg Date';
            *in84 = *off;
            error = *on;
            errmsg = 'Enter Date';
            *in06 = *on;
            exsr zm0105;
          when $itflgd = 'Y' and
               moretoscan= ' '  and
               w11dte = 0 and
               not $bcExpDSent  and
               not $bcSlByDSent;
            error = *on;
            errmsg = 'Enter Date';
            *in06 = *on;
            exsr zm0105;
            wodte = 'Exp Date';
            *in84 = *off;
        endsl;
        // when cw and weight is missing
        *in83 = *on;
        Select;
          when $itcwgt = 'Y' and $bcPNtkgSent;
          when $itcwgt = 'Y' and $bcPNtLbSent;
          when $itcwgt = 'Y' and w11dwgt = 0;
            *in83 = *off;
            error = *on;
            errmsg = 'Enter Wgt';
            *in09 = *on;
            exsr zm0105;
        endsl;

        // now edit date if entered
        Select;
          when $itflgd = 'Y' and w11dte <> 0;
            $cvcmd = '*MDYYMD';
            $cvd6i = %char(w11dte);
            cvtdte($cvtdt);
            if $cvrtn = '*PGMQ   ';
              error = *on;
              errmsg = 'Invalid Date';
              *in06 = *on;
              *in84 = *off;
              exsr zm0105;
            else;
              $pmfgdt = $cvd6o;
            endif;
        endsl;
        Select;
          when $itcwgt = 'Y' and w11dwgt <> 0;
        endsl;
740iA   if $BCPNTLBSENT  = *off and $BCPNTkgSENT  = *off;
740jD     //eval w8dwgt = w11dwgt;
740jM     w8dwgt = w11dwgt / 100;
740iA     eval w8avg = 'N';
740iA     eval w3qt01 = 1;
740iA     exsr zzchk11w;
740iA     if error = *on;
740iA       eval *in83 = *off;
740iA       if *in86 = *off;
740iA         eval *in84 = *off;
740iA       else;
740iA         eval *in06 = *off;
740iA       endif;
740iA     endif;
740iA   endif;
      /end-free
     *
      * Load Expiration Date
     c                   select
     c                   when      $bcExpDSent
     c                   eval      $pexpdt = $bcExpD
     c                   when      $bcSlByDSent
     c                   eval      $pexpdt = $bcSlByD
     c                   endsl
      * Load Manufacturing Date
     c                   if        $bcProdDSent
     c                   eval      $pmfgdt = $bcProdD
     c                   endif
      * Load Manufacturing Date
     c                   if        $bcPackDSent
     c                   eval      $pmfgdt = $bcPackD
     c                   endif
      * Load Lot
     c                   if        $bcLotSent
     c                   endif
      * Load Catch Weight
     c                   select
     C                   when      svopwum = 'KGS'
     C                             or svopwum = 'kgs'
     C                             or svopwum = 'Kgs'
     c                   if        $bcPNtkgSent
     c                   eval      $pwgt  = $bcPNtkg
     c                   eval      *in87 = *on
     C                   exsr      zzcnvwgt
     c                   endif
     C                   other
     c                   if        $bcPNtLbSent
     c                   eval      $pwgt  = $bcPNtLb
     c                   eval      *in87 = *on
     C                   exsr      zzcnvwgt
     c                   endif
     c                   if        w11dwgt <> 0
740jDc*                  eval      $pwgt  = w11dwgt
740jMc                   eval      $pwgt  = w11dwgt /100
     c                   eval      *in87 = *on
     C                   exsr      zzcnvwgt
     c                   endif
     c                   endsl
      /free
        if w11uci <> ' '
           and w12lcns <> ' '
           and moretoscan= *on;
PCKaA     Select;
PCKaA       when $itven# = 203 and $bclot <> savelotc
PCKaA            and $bcai99sent = *off;
PCKaA         Difflot = *on;
PCKaA         Lotovr = *on;
PCKaA       other;
              if $bclot <> savelotc and lotovr = *off
                 and $bcai99sent = *off;
                error = *on;
                warn = *on;
                lotwarn = *on;
                exsr zm3701;
              endif;
PCKaA     Endsl;
        endif;
        if w11uci <> ' '
           and w12lcns <> ' '
           and moretoscan= *on;
          select;
            when $pmfgdt = savedate and $IMMFLG = 'Y';
            when $pexpdt = savedate and $itflgd = 'Y';
            when $pmfgdt <> savedate and dateovr = *off and $IMMFLG = 'Y'
             and $bcai99sent = *off;
            error = *on;
            warn = *on;
            datewarn = *on;
            exsr zm3702;
            when $pexpdt <> savedate and dateovr = *off and $itflgd = 'Y'
             and $bcai99sent = *off;
            error = *on;
            warn = *on;
            datewarn = *on;
            exsr zm3702;
          endsl;
        endif;
      /end-free
     C     endck11       endsr
740iA*
740iA*  ZZCHK11W  Screen 11 used for validating 99i label weight
740iA*
740iA*
740iAC     zzchk11w      begsr
740iAC                   eval      error = *off
740iAC                   eval      errflg = *off
740iAc                   exsr      zzrcvpocheck
740iA*
740iA*
740iA*  See if we need to verify catch weight.
740iA*
740iAC     vrfycw        cabeq     *off          skipcww
740iA*
740iA*  CW can't be zero if forced entry is selected.
740iA*
740iA*    One exception for 'First time only' entry with Avg = 'Y'
740iA*
740iAC                   if        svcwfr = 'Y'  and
740iAC                             w8dwgt = 0
740iAC                   if        svcwen = '1'  or
740iAC                             svcwen = '2'  and
740iAC                             w8avg <> 'Y'
740iAC                   eval      error = *on
740iAC                   eval      *in29 = *on
740iAC                   eval      *in09 = *on
740iAC                   eval      errmsg = *blanks
740iAC                   select
740iAC                   when      e$lng = 'SP'
740iAC                   eval      errmsg = descsp(4)
740iAC                   other
740iAC                   eval      errmsg = desc(4)
740iAC                   endsl
740iAC                   exsr      zm0110
740iAC                   endif
740iAC                   endif
740iA*
740iA*  Verify Catch weight average  (Y/N).
740iA*
740iAC                   if        w8avg <> 'Y'  and
740iAC                             w8avg <> 'N'
740iAC                   eval      error = *on
740iAC                   eval      *in32 = *on
740iAC                   eval      *in12 = *on
740iAC                   eval      errmsg = *blanks
740iAC                   select
740iAC                   when      e$lng = 'SP'
740iAC                   eval      errmsg = descsp(5)
740iAC                   other
740iAC                   eval      errmsg = desc(5)
740iAC                   endsl
740iAC                   exsr      zm1005
740iAC                   endif
740iA*
740iA*  When 'First time only' entry with Avg = 'Y'
740iA*    Then catch weight must be zero.
740iA*
740iAC                   if        svcwen = '2'  and
740iAC                             w8avg = 'Y'  and
740iAC                             w8dwgt <> 0
740iAC                   eval      error = *on
740iAC                   eval      *in29 = *on
740iAC                   eval      *in09 = *on
740iAC                   eval      errmsg = *blanks
740iAC                   exsr      zm3234
740iAC                   endif
740iA*
740iA*
740iA*  When more than one qty is entered, catch weight average must be N
740iA*
740iA*    One exception for 'First time only' entry with Avg = 'Y'
740iA*
740iAC                   select
740iAC                   when      w3qt01 <> 0  and
740iAC                             w8avg = 'Y'  and
740iAC                             svcwen <> '2'
740iAC                   if        w3qt02 <> 0
740iAC                   eval      error = *on
740iAC                   eval      *in32 = *on
740iAC                   eval      *in12 = *on
740iAC                   eval      errmsg = *blanks
740iAC                   select
740iAC                   when      e$lng = 'SP'
740iAC                   eval      errmsg = descsp(5)
740iAC                   other
740iAC                   eval      errmsg = desc(5)
740iAC                   endsl
740iAC                   exsr      zm2101
740iAC                   endif
740iA*
740iAC                   when      w3qt02 <> 0  and
740iAC                             w8avg = 'Y'  and
740iAC                             svcwen <> '2'
740iAC                   if        w3qt01 <> 0
740iAC                   eval      error = *on
740iAC                   eval      *in32 = *on
740iAC                   eval      *in12 = *on
740iAC                   eval      errmsg = *blanks
740iAC                   select
740iAC                   when      e$lng = 'SP'
740iAC                   eval      errmsg = descsp(5)
740iAC                   other
740iAC                   eval      errmsg = desc(5)
740iAC                   endsl
740iAC                   exsr      zm2101
740iAC                   endif
740iA*
740iAC                   endsl
740iA*
740iA*  Skip catch weight variance check when ...
740iA*    "First time only" entry
740iA*
740iAC                   if        svcwen = '2'
740iA*      Skip variance check once qty has been received for item.
740iAC                             and (pdqrc1 > 0
740iAC                             or   pdqrc2 > 0
740iAC                             or   pdqrc3 > 0)
740iAC
740iAC                   goto      skipcww
740iAC                   endif
740iA*
740iA*  Catch weight variance check.
740iA*
740iAC                   if        svdwgt <> w8dwgt
740iAC                   eval      wtchk = *off
740iAC                   endif
740iA*
740iAC                   if        wtchk = '2'  and
740iAC                             ovrrid = *on
740iAC                   eval      wtchk = *on
740iAC                   endif
740iA*
740iAC                   if        wtchk <> '1'
740iAC                   eval      wtchk = *on
740iA*
740iA*   If catch weight >0,
740iA*     Calculate total expected catch weight,
740iA*     Calculate low/high ranges.
740iA*
740iAC                   if        w8dwgt <> 0
740iAC                   eval      lwvar = 0
740iAC                   eval      hivar = 0
740iAC                   eval      lwrng = 0
740iAC                   eval      hirng = 0
740iAC                   eval      exwgt = 0
740iAC                   eval      ilvar = 0
740iAC                   eval      ihvar = 0
740iAC                   eval      ilrng = 0
740iAC                   eval      ihrng = 0
740iAC                   eval      hostcw0 = 0
740iAC                   eval      hostcw2dec = 0
740iA*
740iAC                   if        w8avg = 'Y'
740iAC                   eval      exwgt = itswgt
740iAC*                  eval      wotcw = w8dwgt
740iAc                   if        nxtscr = '11 '
740iAc                   eval      wotcw = w8dwgt
740iAc                   else
740iAC                   eval      wotcw = savewgt
740iAc                   endif
740iAC                   else
740iAC                   if        svcwen = '2'
740iAC     pdqor1        mult      itswgt        exwgt
740iA
740iA* If specific client, use imported c/w value for variance checking if
740iA* it's numeric, otherwise, use standard comparison tests.

740iAC                   eval      hostUnitWgt  = 0
740iAC                   eval      rcvUnitWgt  = 0
740iA
740iAC                   select
740iAC                   when      client = Dairyland
740iAC                   eval      hostcwa = %subst(pdmms1:9:7)
740iAC     digits        check     hostcwa                                68
740iAC                   if        *in68 = *off
740iAC                   eval      hostcw0 = %dec(%subst(pdmms1:9:7):7:0)
740iAC                   move      hostcw0       hostcw2dec
740iA
740iAC                   eval      qtyord  = 0
740iAC                   eval      qtyord1 = 0
740iAC                   eval      qtyord2 = 0
740iAC                   eval      qtyord3 = 0
740iA
740iAC                   if        pdqor1 > 0
740iAC                   eval      qtyord1 = pdqor1
740iAC                   if        itumq2 > 0
740iAC                   eval      qtyord1 = qtyord1 * itumq2
740iAC                   endif
740iAC                   if        itumq3 > 0
740iAC                   eval      qtyord1 = qtyord1 * itumq3
740iAC                   endif
740iAC                   endif
740iA
740iAC                   if        pdqor2 > 0
740iAC                   eval      qtyord2 = pdqor2
740iAC                   if        itumq3 > 0
740iAC                   eval      qtyord2 = qtyord2 * itumq3
740iAC                   endif
740iAC                   endif
740iA
740iAC                   if        pdqor3 > 0
740iAC                   eval      qtyord3 = pdqor3
740iAC                   endif
740iA
740iAC                   eval      qtyord = qtyord1 + qtyord2 + qtyord3
740iA
740iAC                   eval      exwgt = 0
740iAC                   eval      qtyrcv = 0
740iAC                   eval      qtyrcv1 = 0
740iAC                   eval      qtyrcv2 = 0
740iA
740iAC                   if        w3qt01 > 0
740iAC                   eval      qtyrcv1 = w3qt01
740iAC                   if        itumq2 > 0
740iAC                   eval      qtyrcv1 = qtyrcv1 * itumq2
740iAC                   endif
740iAC                   if        itumq3 > 0
740iAC                   eval      qtyrcv1 = qtyrcv1 * itumq3
740iAC                   endif
740iAC                   endif
740iA
740iAC                   if        w3qt02 > 0
740iAC                   eval      qtyrcv2 = w3qt02
740iAC                   if        itumq3 > 0
740iAC                   eval      qtyrcv2 = qtyrcv2 * itumq3
740iAC                   endif
740iAC                   endif
740iA
740iAC                   eval      qtyrcv = qtyrcv1 + qtyrcv2
740iA
740iAC                   eval      hostUnitWgt = hostcw2dec / qtyord
740iAC*                  eval      rcvUnitWgt = w8dwgt / qtyrcv
740iAC                   eval      rcvUnitWgt = savewgt / qtyrcv
740iAC                   eval      wgtDiff = hostUnitWgt - rcvUnitWgt
740iAC                   eval      caltol1 = %abs(wgtDiff) / hostUnitWgt
740iA
740iAC                   if           pdqor2 > 0
740iAC                             or w3qt02 > 0
740iAC                   eval      qtyDiff  = qtyord - qtyrcv
740iAC                   eval      caltol2  = %abs(qtyDiff) / qtyord
740iAC                   endif
740iA
740iAC                   else
740iAC     w3qt01        mult      itswgt        exwgt
740iAC                   endif
740iAC                   endsl
740iA
740iAC                   else
740iAC     w3qt01        mult      itswgt        exwgt
740iAC                   endif
740iAC*                  eval      wotcw = w8dwgt
740iAc                   if        nxtscr = '11 '
740iAc                   eval      wotcw = w8dwgt
740iAc                   else
740iAC                   eval      wotcw = savewgt
740iAc                   endif
740iAC                   endif
740iA*
740iA*    Iniz. flag used to skip variance check if = *ON.
740iA*
740iAC                   eval      lvskp = *off
740iAC                   eval      hvskp = *off
740iA*
740iA**   Iniz. fields used to hold low/high variance.
740iAC                   eval      prg1c = 0
740iAC                   eval      prg2c = 0
740iA*
740iA*    Use item variance % if it exists
740iA*
740iAC                   if        imrg1c <> 0
740iAC     imrg1c        div       100           prg1c
740iAC                   if        imrg1c = 99
740iAC                   eval      lvskp = *on
740iAC                   endif
740iAC                   endif
740iA*
740iAC                   if        imrg2c <> 0
740iAC     imrg2c        div       100           prg2c
740iAC                   if        imrg2c = 99
740iAC                   eval      hvskp = *on
740iAC                   endif
740iAC                   endif
740iA*
740iAC                   if        prg1c = 0
740iAC     oprg1c        div       100           prg1c
740iAC                   endif
740iAC                   if        prg2c = 0
740iAC     oprg2c        div       100           prg2c
740iAC                   endif
740iA*
740iA*     Don't do following extended weight calcs if you're using
740iA*     Dairyland's imported c/w method for comparing wgt tolerance.
740iAC                   select
740iAC                   when      hostcw2dec = 0
740iA*
740iAC                   if        prg1c > 0
740iAC     exwgt         mult      prg1c         lwvar
740iAC                   eval      ilvar = itswgt * prg1c
740iAC                   endif
740iAC                   eval      lwrng = exwgt - lwvar
740iAC                   eval      ilrng = itswgt - ilvar
740iAC                   if        prg2c > 0
740iAC     exwgt         mult      prg2c         hivar
740iAC                   eval      ihvar = itswgt * prg2c
740iAC                   endif
740iAC     exwgt         add       hivar         hirng
740iAC     itswgt        add       ihvar         ihrng
740iA*
740iAC                   endsl
740iAC                   endif
740iA*
740iA*     Check CW variance if CW > 0
740iA*
740iAC                   if        w8dwgt <> 0
740iAC                   if        hostcw2dec > 0
740iA*     Use Dairyland's tests for comparing wgt and qty tolerances.
740iAC                   exsr      zzchkt1
740iAC                   else
740iAC                   exsr      zzchkt
740iAC                   endif
740iAC                   endif
740iAC     error         cabeq     *on           enderrw
740iAC                   endif
740iA*
740iAC     skipcww       tag
740iA*
740iAC     enderrw       tag
740iA*
740iA*   Save screen fields.
740iA*
740iAC                   eval      svdwgt = w8dwgt
740iAC                   eval      sdqrc1 = w3qt01
740iAC                   eval      sdqrc2 = w3qt02
740iAC                   eval      svmfdt = w8mfdt
740iAC                   eval      svexdt = w8exdt
740iA*
740iAC     endck11w      endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK12  Screen 12 error checking.
     *
     C     zzchk12       begsr
     C                   eval      error = *off
     C                   eval      errflg = *off
     c                   exsr      zzrcvpocheck
     *
     *  Make sure license doesn't already exist if first scan
     *
     c                   if        w12lcns <> ' '
     c                             and $pxd <> 'XD'
     c                   exsr      zzchklcns
     c                   endif
     *
     *  Make sure license is scanned on first scan
     *
     c                   if        w12lcns = ' '
     C                   eval      error = *on
     C                   eval      *in35 = *on
     C                   eval      *in15 = *on
     c                   eval      errmsg = desc(6)
     c                   exsr      zm0105
     c                   endif
     *
     C     endck12       endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK13  Screen 13 error checking.
     *
     C     zzchk13       begsr
     C                   eval      error = *off
     C                   eval      errflg = *off
     c                   exsr      zzrcvpocheck
     *
     C     endck13       endsr
     *----------------------------------------------------------------
     *
     *  ZZCHKLCNS  Check for active license
     *
     C     zzchklcns     begsr
     C                   eval      lcnsExists = *off
     C*                  eval      ossLcns = *off

     *  See if license exists in licactive file.

     C                   exsr      clr$license
     C                   eval      $liToLcnsU = *on
     c                   if        $pxd = ' '
     C                   eval      $liToLcns = w12lcns
     c                   else
     C                   eval      $liToLcns = templcns
     c                   endif
     C                   eval      $dricommand = '*LICENSE'
     C                   eval      $drisubcmd  = '%GETLCNS'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmflag  = *off
     C                   exsr      zzzdricop
     C                   if        $drireturn = '*OK'
     C                             and $liToAisl =  'OSS'
     C                             or $drireturn = 'INVLDLCNS'
     C*                  if        error
     C                   eval      lcnsExists = *off
     C                   eval      error = *off
     *
     *  Check LICLOG before accepting this license
     *
     C                   exsr      clr$license
     C                   eval      $liToLcnsU = *on
     c                   if        $pxd = ' '
     C                   eval      $liToLcns = w12lcns
     c                   else
     C                   eval      $liToLcns = templcns
     c                   endif
     C                   eval      $liOLcnsU = *on
     c                   if        $pxd = ' '
     C                   eval      $liOLcns = w12lcns
     c                   else
     C                   eval      $liToLcns = templcns
     c                   endif
     C                   eval      $dricommand = '*LICENSE'
     C                   eval      $drisubcmd  = '%GETINFO'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   exsr      zzzdricop
     c* if we get an ok on the return this means it exist - don't use
     C                   if        $drireturn = '*OK'
     C                             and $liToAisl <> 'OSS'
     C                   eval      lcnsExists = *on
     C                   eval      error = *on
     C                   eval      *in15 = *on
     c                   eval      errmsg= desc(6)
     c                   exsr      zm02
740gAc                   leavesr
     C                   endif

     *
     *  Check LICINFO before accepting this license
     *
     C                   exsr      clr$licinfo
     C                   eval      $lnwhse   = $pwhse
     c                   if        $pxd = ' '
     C                   eval      $lnlcns   = w12lcns
     c                   else
     C                   eval      $lnlcns   = templcns
     c                   endif
     C                   eval      $dricommand = '*LICINFO'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   exsr      zzzdricop
     c* if we get an ok on the return this means it exist - don't use
     C                   if        $drireturn = '*OK'
     C                             and $liToAisl <> 'OSS'
     C                   eval      lcnsExists = *on
     C                   eval      error = *on
     C                   eval      *in15 = *on
     c                   eval      errmsg= desc(6)
     c                   exsr      zm02
     C                   endif

     C                   leavesr
     C                   else
     C                   eval      lcnsExists = *on
     C                   eval      error = *on
     C                   eval      *in15 = *on
     c                   eval      errmsg= desc(6)
     c                   exsr      zm02
     C                   endif


     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHKT   Screen 3 error check totals
     *
     C     zzchkt        begsr
     C**                 eval      error = *off
     *
     *     Compare total catchweight to expected catchweight
     *
     C                   if        lvskp = *off  and
     C                             wotcw < lwrng
     C                   eval      error = *on
     C                   eval      wtchk = '2'
     C                   eval      warn = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = wotcw
     C                   eval      erlrng = lwrng
     C                   if        hvskp = *on
     C                   eval      erhrng = 0
     C                   else
     C                   eval      erhrng = hirng
     C                   endif
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   eval      erexwt = exwgt
     C                   select
     C                   when      client = Dairyland
     C                   exsr      zm23
     C                   other
     C                   exsr      zm19
     C                   endsl
     C                   endif
     *
     C                   if        hvskp = *off  and
     C                             wotcw > hirng
     C                   eval      error = *on
     C                   eval      wtchk = '2'
     C                   eval      warn = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = wotcw
     C                   if        lvskp = *on
     C                   eval      erlrng = 0
     C                   else
     C                   eval      erlrng = lwrng
     C                   endif
     C                   eval      erhrng = hirng
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   eval      erexwt = exwgt
     C                   select
     C                   when      client = Dairyland
     C                   exsr      zm23
     C                   other
     C                   exsr      zm19
     C                   endsl
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHKT1  Screen 8 error checks:
     *           1. Compare imported cw to entered cw.
     *           2. Compare ordered qty to received qty.
     *
     C     zzchkt1       begsr
     *
     C                   if        hvskp = *off
     C                             and caltol1 >= prg2c
     C                   eval      error = *on
     C                   eval      wtchk = '2'
     C                   eval      warn = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   eval      caltol1x100 = caltol1 * 100
     C                   eval      errg2c = prg2c * 100

     C                   eval      errmsg = 'Wgt tol% '
     C                                      + %triml(%editc(caltol1x100:'3'))
     C                                      + ' >= var% '
     C                                      + %triml(%editc(errg2c:'3'))
     C                   exsr      zm0105
     C                   goto      endckt1
     C                   endif

     C                   if        hvskp = *off
     C                             and caltol2 >= prg2c
     C                   eval      error = *on
     C                   eval      wtchk = '2'
     C                   eval      warn = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   eval      caltol2x100 = caltol2 * 100
     C                   eval      errg2c = prg2c * 100

     C                   eval      errmsg = 'Qty tol% '
     C                                      + %triml(%editc(caltol2x100:'3'))
     C                                      + ' >= var% '
     C                                      + %triml(%editc(errg2c:'3'))
     C                   exsr      zm0105
     C                   goto      endckt1
     C                   endif

     C     endckt1       endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm2
     C                   endif
     *
     *  Test for F8 - Mark/UnMark for export
     *
     C                   if        *inkh
     C                   eval      cmdtkn = *on
     C                   eval      $lwhs3 = $pwhse
     C                   eval      $lpo3 = wopo
     C                   eval      $lcmd = '*MRKUNM '
     C                   eval      $lrtn = *blanks
     C                   call      'PO111'
     C                   parm                    $lparm
     C                   if        $lrtn = '*PGMQ'
     C                   eval      error = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   eval      refrsh = *on
     C     fileky        chain(n)  pohdr                              79
     C                   exsr      scr02i
     C                   endif
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
     C                   eval      cmdtkn = *off
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm3
     C                   endif
     *
     *      F07 - Mark line as touched (X)
     C                   if        *inkg
     C                   if        client = saval
     C                   eval      woyes = '9'
     C                   else
     C                   eval      woyes = 'N'
     C                   endif
     *
     C                   if        woyes = 'N' or
     C                             woyes = '9'
     C                   exfmt     verify
     C                   endif
     C                   if        woyes = 'Y' or
     C                             woyes = '1'
     **
     **
     *   Read PORCV.  If not found then add...
     C     partky        setll     porcv
     C     partky        reade     porcv                                  55
     C                   if        *in55
     C                   eval      porwhs = pdwhse
     C                   eval      porpo = pdpo
     C                   eval      porseq = pdseq
     *
     C                   move      #jobdt        $cvd6i
     C                   eval      $cvcmd = '*MDYCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      pordte = $cvd8o
     C**** #jobdt        mult      10000.01      wrkdte
     C**** 20000000      add       wrkdte        pordte
     C                   eval      portim = #jobtm
     C                   eval      porusr = #user
     C                   eval      poremp = $emp#
     C                   eval      portrn = 0
     **                   Z-ADD0         PORLIC
     C                   eval      porlic = *blanks
     C                   eval      porlbl = 0
     C                   eval      poract = 'X'
     C                   eval      poredt = 0
     C                   eval      poreti = 0
     C                   write     porrec
     C                   else
     *    Release lock if record found.
     C                   unlock    porcv
     C                   endif
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   endif
     C                   endif
     *
     *      F20 - Accept Warning.
     *      F10 - Accept Warning.
     *
     C                   if        *inku  or
     C                             *inkj
     C                   eval      ovrrid = *on
     C                   else
     C                   eval      ovrrid = *off
     C                   endif
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     **     F20 - Accept Warning.
     **
     **         *INKU     IFEQ *ON
     **                   MOVE *ON       OVRRID
     **                   ENDIF
     *
     C                   endif
     C     endcm3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD4   User defined command keys for screen 4.
     *
     C     zzcmd4        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm4
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm4        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD5   User defined command keys for screen 5.
     *
     C     zzcmd5        begsr
     C                   eval      cmdtkn = *off
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     *     Line #.
     *
     C                   when      row# = 5  and
     C                             #lline <> '16'  or
     C                             row# = 8  and
     C                             #lline = '16'
     *R                   MOVE *ON       *IN12
     **                   MOVE '*LOOKUP '$LCMD
     C                   if        #lline = '16'
     C                   eval      $lcmd = '*SELEC16'
     C                   else
     C                   eval      $lcmd = '*SELECT '
     C                   endif
     C                   eval      $lwhse = $pwhse
     C                   eval      $lpo = wopo
     C                   eval      $lline = 0
     C                   eval      $lpitm = *blanks
     C                   call      'PO910'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w4line = $lline
     C                   eval      w4item = $lpitm
     C                   endif
     *
     *     Item #.
     *
     C                   when      row# = 6  and
     C                             #lline <> '16'  or
     C                             row# = 10  and
     C                             #lline = '16'
     *R                   MOVE *ON       *IN12
     **                   MOVE '*LOOKUP '$LCMD
     C                   if        #lline = '16'
     C                   eval      $lcmd = '*SELEC16'
     C                   else
     C                   eval      $lcmd = '*SELECT '
     C                   endif
     C                   eval      $lwhse = $pwhse
     C                   eval      $lpo = wopo
     C                   eval      $lline = 0
     C                   eval      $lpitm = *blanks
     C                   call      'PO920'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w4line = $lline
     C                   eval      w4item = $lpitm
     C                   endif
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm5
     C                   endif
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm5        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD6   User defined command keys for screen 6.
     *
     C     zzcmd6        begsr
     C                   eval      cmdtkn = *off
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm6
     C                   endif
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm6        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD7   User defined command keys for screen 7.
     *
     C     zzcmd7        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm7
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm7        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD8   User defined command keys for screen 8.
     *
     C     zzcmd8        begsr
     C                   eval      cmdtkn = *off
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *      F7 - kilograms/Pounds toggle
     *
740aDC*                  if        *inkg and *in86 = *off
740aMC                   if        *inkg and *in87 = *off
     C                   eval      cmdtkn = *on
     C                   if        KiloLbs = 'P'
     C                   eval      KiloLbs = 'K'
     C                   eval      dspuom  = 'Kgs'
     c                   eval      *in67 = *off
     C                   else
     C                   eval      KiloLbs = 'P'
     C                   eval      dspuom  = 'Lbs'
     c                   eval      *in67 = *on
     C                   endif
     C                   goto      endcm8
     C                   endif
     *
     *      F20 - Accept Warning.
     *      F10 - Accept Warning.
     *
     * If specific client, do not allow override for c/w difference.
     *
     C                   if        (*inku or *inkj) and
     C                             wtchk = '2' and
     C                             client = Dairyland
     C                   eval      cmdtkn = *on
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(7)       errmsg
     C                   exsr      zm0105
     C                   goto      endcm8
     C                   endif
     *
     C                   if        *inku  or
     C                             *inkj
     C                   eval      ovrrid = *on
     C                   else
     C                   eval      ovrrid = *off
     C                   endif
     *      F11 - Manufacturer code decipher
     *
     c                   if        *inkk and *in87 = *off
      * f11 is only valid on date sensitive items
     c                   If        itflgd = 'Y' or immflg = 'Y'
     c                   eval      $lmfr#    = phven
     c                   eval      $lmfritem = pdvitm
     c                   eval      $ldakitem = pditem
     c                   eval      $lupc     = w2upc
     c                   eval      ddcode = *off
     c*                  call      'MF200'
     c                   call      'MF200'                              66
     C                   parm                    $lparm
     C                   parm      0             $lexpdat          6 0
     C                   parm      0             $lmfrdat          6 0
     C                   parm                    $lupc            20
     C                   parm      ' '           $ldecvalue       15
     c                   else
     c                   exsr      zm13250
     c                   endif
      * Set ddcode if date returned is invalid
     c                   if        $lrtn <> *blanks and $lrtn <> 'OK'
     c                   select
     c                   when      $lexpdat = 0 and $lmfrdat = 0
     c                   eval      ddcode = *on

     c                   when      $lexpdat <> 0
     c                   eval      $cvcmd = '*MDYEDT'
     c                   move      $lexpdat      $cvd6i
     c                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      ddcode= *on
     c                   endif

     c                   when      $lmfrdat <> 0
     c                   eval      $cvcmd = '*MDYEDT'
     c                   move      $lmfrdat      $cvd6i
     c                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      ddcode= *on
     c                   endif
     c                   other
     c
     c                   endsl
     c                   endif
     c                   exsr      zzmfrdates
     C                   if        wodte = 'Mfr date'
     C                   eval      w8dte  = $lmfrdat
     c                   endif
     C                   if        wodte = 'Exp date'
     C                   eval      w8dte = $lexpdat
     C                   endif
     c                   endif
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm8        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD9   User defined command keys for screen 9.
     *
     C     zzcmd9        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     *
     C                   endif
     *
     C     endcm9        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD10  User defined command keys for screen 10.
     *
     C     zzcmd10       begsr
     C                   eval      cmdtkn = *off
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm10
     C                   endif
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm10       endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD11  User defined command keys for screen 11.
     *
     C     zzcmd11       begsr
     C                   eval      cmdtkn = *off
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm11
     C                   endif
     *
     *
     *      F2  - Complete License.
      *
     C                   if        *inkb
     c                   exsr      zzrcvpocheck
     c                   if        saveqty > 0
     C                   eval      cmdtkn = *on
     c                   eval      nxtscr = '03 '
     c                   exsr      scr03i
     c                   endif
     C                   endif
     C                   endif
     *
     *      F7 - kilograms/Pounds toggle
     *
     C                   if        *inkg
     c                   eval      *in09 = *on
     C                   eval      cmdtkn = *on
     C                   if        KiloLbs = 'P'
     C                   eval      KiloLbs = 'K'
     C                   eval      dspuom  = 'Kgs'
     c                   eval      *in67 = *off
     C                   else
     C                   eval      KiloLbs = 'P'
     C                   eval      dspuom  = 'Lbs'
     c                   eval      *in67 = *on
     C                   endif
     C                   goto      endcm11
     C                   endif
     *
     *      F10 - Accept Warning.
     *
     C                   if        *inkj
     c                   if        lotwarn= *on
     c                   eval      difflot = *on
     c                   eval      lotovr = *on
     c                   endif
     c                   if        datewarn = *on
     c                   eval      diffexpd = *on
     c                   eval      dateovr = *on
     c                   endif
     C                   endif
740iAC                   if        *inku  or
740iAC                             *inkj
740iAC                   eval      ovrrid = *on
740iAC                   else
740iAC                   eval      ovrrid = *off
740iAC                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm11       endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD12  User defined command keys for screen 12.
     *
     C     zzcmd12       begsr
     C                   eval      cmdtkn = *off
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm12
     C                   endif
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm12       endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD13  User defined command keys for screen 13.
     *
     C     zzcmd13       begsr
     C                   eval      cmdtkn = *off
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm13
     C                   endif
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm13       endsr
     *----------------------------------------------------------------
     *
     *  ZZCNVWGT  Setup converted weight field.
     *
     C     zzcnvwgt      begsr
     *
     *    If in kilograms mode, convert into pounds for processing.
     *
     * If item options is setup as kgs and user enters kgs no conversion
     * If item options is setup as kgs and user enters lbs need conversion
     * If item options is setup as lbs and user enters lbs no conversion
     * If item options is setup as lbs and user enters kgs need conversion
      /free
        select;
          when IMkilolbs = 'K';
            if KiloLbs = 'K';
              eval cnvwgt = $pwgt;
            else;
              eval(h) cnvwgt = $pwgt / kgs2lbs;
            endif;
          other;
            if KiloLbs = 'K';
              eval(h) cnvwgt = $pwgt  * kgs2lbs;
            else;
              eval cnvwgt = $pwgt;
            endif;
        endsl;
      /end-free

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     *
     C                   eval      $pwhse = #whse
     *
     C                   eval      w1po = *blanks
     **                   Z-ADD0         W1DOCK
     *
     *   Get Item Maintenance options.
     *
      /free
         //wkwhse = $pwhse;
         getimuom(#whse: IMkilolbs: IMUom);
         select;
           when IMkilolbs = 'K';
             KiloLbs = 'K';
             dspuom  = IMUom;
             *in67 = *off;
           other;
             kiloLbs = 'P';
             dspuom  = 'Lbs';
             *in67 = *on;
         endsl;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     C                   eval      wopo = w1po
     C                   eval      w2upc = *blanks
     C                   exsr      zztrcv
     C                   select
     C                   when      phstat = '0'
     C                   eval      wostat = sts00
     C                   when      phstat = '1'
     C                   eval      wostat = sts01
     C                   when      phstat = '2'
     C                   eval      wostat = sts02
     C                   when      phstat = '3'
     C                   eval      wostat = sts03
     C                   when      phstat = '4'
     C                   eval      wostat = sts04
     C                   when      phstat = '5'
     C                   eval      wostat = sts05
     C                   other
     C                   eval      wostat = *blanks
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     *
     *
     c                   eval      woitm# = $uiItem
     C     podky1        setll     podtl1                               79
     C     nxtd          tag
     C     podky1        reade     podtl1                               7879
     C                   if        not *in79
     *
     C                   if        woline = 0
     C                   eval      woline = pdseq
     C                   else
     C     pdseq         cabne     woline        nxtd
     C                   endif
     *
     C                   else
     C                   eval      woline = 0
     C                   endif
     *
     C                   eval      woord1 = pdqor1
     C                   z-add     pdqor2        woord2
     *
     *   Item description and pack description.
     *
     C                   exsr      zzgeti
     c                   if        $lsavetrn = 0
     c                   exsr      zzrcvpo
     c                   else
     c                   exsr      zzrcvpocheck
     c                   endif
     *
     *   Get Unit of measure fields
     C                   eval      woum1 = *blanks
     C                   eval      woum2 = *blanks
     C                   exsr      zzuom
     **         WOUM2     IFEQ *BLANKS
     **                   MOVE *ON       *IN92
     **                   ELSE
     **                   MOVE *OFF      *IN92
     **                   ENDIF
     C                   eval      w3qt01 = 0
     C                   eval      w3qt02 = 0
     C                   eval      w3plt = 0
     C                   if        client = saval
     C                   eval      w3plt = 1
     C                   endif
     C                   eval      sdqrc1 = 0
     C                   eval      sdqrc2 = 0
     **                   Z-ADD0         W3EXDT
     **                   Z-ADD0         W3DWGT
     **                   MOVE 'N'       W3AVG
     *
     **         ITCWGT    IFNE 'Y'
     **                   MOVE *ON       *IN99
     **                   ELSE
     **                   MOVE *OFF      *IN99
     **                   ENDIF
     **         ITFLGD    IFNE 'Y'
     **                   MOVE *ON       *IN96
     **                   ELSE
     **                   MOVE *OFF      *IN96
     **                   ENDIF
     *
     *    Retrieve Item Lot/license plate tracking info.
     C                   eval      $lcmd = *blanks
     C                   eval      $lprg = #prog
     C                   eval      $lwhse = $pwhse
     C                   eval      $litem = pditem
     C                   call      'GETLLP'
     C                   parm                    $lparm
     *
     C                   select
     *    Lot/license plate tracking values found.
     C                   when      $lrtn = '*OK     '
     C                   if        $llot = 'Y'
     C                   eval      lottrk = '*YES'
     C                   else
     C                   eval      lottrk = '*NO '
     C                   endif
     C                   if        $lltrk = 'Y'
     C                   eval      lictrk = '*YES'
     C                   else
     C                   eval      lictrk = '*NO '
     C                   endif
     C                   other
     C                   eval      lottrk = '*NO '
     C                   eval      lictrk = '*NO '
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL4   Fill screen 4 fields with info from file.
     *
     C     zzfil4        begsr
     C                   eval      woqt01 = $rrq1
     C                   eval      woqt02 = $rrq2
     C                   eval      woplet = $rrpal
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL5   Fill screen 5 fields with info from file.
     *
     C     zzfil5        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL6   Fill screen 6 fields with info from file.
     *
     C     zzfil6        begsr
     *
     *   Item description and pack description.
     C                   exsr      zzgeti
     c                   if        $lsavetrn = 0
     c                   exsr      zzrcvpo
     c                   else
     c                   exsr      zzrcvpocheck
     c                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL7   Fill screen 7 fields with info from file.
     *
     C     zzfil7        begsr
     C                   eval      wobat = $rord
     C                   eval      w7pal = $rrpal
     **                   Z-ADD0         W7LCNS
     C                   eval      w7lcns = *blanks
     C                   if        w7pctr = 0
     C     partk2        setll     label2
     C                   endif
     C     partk2        reade     label2                               7879
     C                   if        not *in79
     C                   eval      w7tie = lbtie
     C                   eval      w7hi = lbhigh
     C                   add       1             w7pctr
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL8   Fill screen 3 fields with info from file.
     *
     C     zzfil8        begsr
     *
     C                   if           client = Dairyland
     C                   exsr      zzgtpdm
     C                   endif
     *
     c                   if        *in86 = *off
     C                   eval      w8dte = 0
     c                   endif
     C                   eval      w8avg = 'N'
     c                   if        *in87 = *off
     C                   eval      w8dwgt = 0
     c                   else
     c                   eval      w8dwgt = savewgt
     c                   endif
     C                   eval      mfgd = 0
     C                   eval      expd = 0
     C                   eval      svmfdt = 0
     C                   eval      svexdt = 0
     C                   eval      dtchk = *off
     C                   eval      woexdt = 0
     C                   eval      woindt = 0
     *
     *   Set indicator to display/non-display weight fields.
     *
     C                   eval      vrfycw = *off
     C                   eval      *in82 = *off
     *
     *     First, see if catch weight entry is allowed.
     *
     C                   if        itcwgt <> 'Y'  or
     C                             svcwen = '3'
     C                   eval      *in93 = *on
     C                   eval      vrfycw = *off
     C                   else
     C                   eval      *in93 = *off
     C                   eval      vrfycw = *on
     C                   endif
     *
     *     Then see if we should block entry ...
     *       because catch weight previously entered.
     *
     C                   if        svcwen = '2'  and
     C                             pddwgt <> 0
     C                   eval      *in82 = *on
     C                   eval      *in93 = *on
     C                   eval      vrfycw = *off
     C                   endif
     *
     *     Then see what value is to be entered (1=Choice,2=Ttl,3=Avg)
     *
     C                   select
     C                   when      svcwtp = '2'
     C                   eval      *in81 = *on
     C                   eval      w8avg = 'N'
     C                   eval      wocrcv = cwt(1)
     C                   when      svcwtp = '3'
     C                   eval      *in81 = *on
     C                   eval      w8avg = 'Y'
     C                   eval      wocrcv = cwt(2)
     C                   other
     C                   eval      *in81 = *off
     C                   eval      w8avg = 'N'
     C                   eval      wocrcv = cwt(2)
     C                   endsl
     *
     *   Initialize date fields.
     *
     C                   select
     C                   when      immflg = 'Y'
     C                   eval      wodte = 'Mfr date'
     C                   eval      *in94 = *off
     C                   when      itflgd = 'Y'
     C                   eval      wodte = 'Exp date'
     C                   eval      *in94 = *off
     C                   other
     C                   eval      wodte = *blanks
     C                   eval      *in94 = *on
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil9        begsr
     *
     c                   if        *in85 = *off
     C                   eval      w9lotc = *blanks
     c                   else
     c                   eval      w9lotc = savelotc
     c                   endif
PCKaA /free
PCKaA   // Allow lot to be overriden for vendor 203
PCKaA   if client = Pack730 and $itven# = 203;
PCKaA     *in85 = *off;
PCKaA   endif;
PCKaA /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL10  Fill screen 10 fields with info from file.
     *
     C     zzfil10       begsr
     *
     c                   eval      w10upc = ' '
      * do we already have breakdown upc loaded?
     c                   if        $lsavetrn = 0
     c                   exsr      zzrcvpo
     c                   else
     c                   exsr      zzrcvpocheck
     c                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL11  Fill screen 11 fields with info from file.
     *
     C     zzfil11       begsr
     *
      /free
        //w12lcns = ' ';
        wopo = $po;
        woline = $poseq;
        woitem = $poitmdsc;
740hA   woposq = wopo + '/' + %char(woline);
        nextfirst = 'Scan next Uci';
        select;
          when $puci =  ' ' and moretoscan = ' ';
            nextfirst = 'Scan first Uci';
        endsl;
        w11uci = $puci;
        wopo = $po;
        if $lsavetrn = 0;
          exsr zzrcvpo;
        else;
          exsr zzrcvpocheck;
        endif;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL12  Fill screen 12 fields with info from file.
     *
     C     zzfil12       begsr
     *
      /free
        w12lcns = ' ';
        wopo = $po;
        woline = $poseq;
        woitem = $poitmdsc;
        if $lsavetrn = 0;
          exsr zzrcvpo;
        else;
          exsr zzrcvpocheck;
        endif;
      /end-free
     c                   if        $pexpdt > 0
740eAc                   if        $itflgd = 'Y' and $immflg <> 'Y'
     C                   move      $pexpdt       $cvd6i
     C                   eval      $cvcmd = '*YMDMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        w8dte
     C                   eval      *in86 = *on
     C                   move      $cvd6o        $cvd6i
     C                   eval      $cvcmd = '*MDYCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        expd
     C                   move      $cvd8o        woexdt
740eAc                   endif
     c                   endif
     c                   If        $immflg = 'Y'
     c                   if        $pmfgdt > 0
     C                   move      $pmfgdt       $cvd6i
     C                   eval      $cvcmd = '*YMDMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        w8dte
     C                   eval      *in86 = *on
     c                   endif
     c                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL13  Fill screen 13 fields with info from file.
     *
     C     zzfil13       begsr
     *
     c                   eval      w13lcns = w12lcns
      * do we already have breakdown upc loaded?
     c                   if        $lsavetrn = 0
     c                   exsr      zzrcvpo
     c                   else
     c                   exsr      zzrcvpocheck
     c                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGETI   Get item description and pack description.
     *
     C     zzgeti        begsr
     *
     *   Get item
     *
      * add dri to get data from itemfld
      /free
            exsr clr$item;

            $itWhse = $pwhse;
            $ititem = $poitm;

            $dricommand = '*ITEM';
            $drisubcmd  = '%GETALL';
            $drisys2upd = 'D';
            chk4err = *on;
            zmflag  = *off;
            exsr zzzdricop;
            if error = *on;
              $ifucicde = '1';
              $ifrcvmth = '1';
              $ifbrdflg = ' ';
            endif;
      /end-free
     C                   eval      woitem = *blanks
740iAc                   if        woitm# = ' '
740iAc                   eval      woitm# = $poitm
740iAc                   endif
     C     itkey         chain     piritem                            79
     C                   if        *in79
     C                   eval      itdesc = *blanks
     C                   eval      itpdsc = *blanks
     C                   endif
     *
     *  Save information about selected item (Item that was sent in)
     *
     C                   eval      #otype = ittype
     C                   eval      #oitem = ititem
     C                   eval      #oswgt = itswgt
     C                   eval      #oum1 = itum1
     C                   eval      #oum2 = itum2
     C                   eval      #oum2q = itumq2
     C                   eval      #oswt2 = 0
     C                   if        #oum2q <> 0
     C     itswgt        div(h)    #oum2q        #oswt2
     C                   endif
     C                   eval      #oum3 = itum3
     C                   eval      #oum3q = itumq3
     C                   eval      #oswt3 = 0
     C                   if        #oum3q <> 0
     C     itswgt        div(h)    #oum2q        #oswt3
     C     #oswt3        div(h)    #oum3q        #oswt3
     C                   endif
     *
     *   Format item description
     *
     C                   eval      $iitem = woitm#
     C                   eval      $idesc = itdesc
     C                   eval      $ipdsc = itpdsc
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   movel     $istr         woitem
     *
     *   Get SSB item, if one exists
     *
     C                   eval      ssbflg = *off
     C                   if        ittype = ' '
     C                   call      'GETSSB'
     C                   parm      itwhse        $gwhse            3 0
     C                   parm      ititem        $gitem           15
     C                   parm      ' '           #bitem           15
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     C                   parm                    #bwhdp            5
     C                   parm                    #bstyp            1
     C                   parm                    #bum              2
     C                   parm                    #bum2             2
     C                   parm                    #bumq2            3 0
     C                   parm                    #bum3             2
     C                   parm                    #bumq3            3 0
     C                   parm                    #brtn             8
     *
     C                   if        #brtn = '*FOUND  '
     C                   eval      ssbflg = *on
     C                   endif
     C                   endif
     *
     *   See if item is an FS-WMS item or not.
     *
     C                   move      itdesg        iatest
     C                   if        iatest = '*'
     C                   eval      iaflag = *on
     C                   eval      *in64 = *off
     C                   else
     C                   eval      iaflag = *off
     C                   eval      *in64 = *on
     C                   endif

     *  ... Or department isn't live (this overrides iaflag).

     C                   call      'CHKLIVE'
     C                   parm      itwhse        $swhse
     C                   parm                    itwhdp
     C                   parm                    livestat          8

     C                   if        livestat = '*NOTLIVE'
     C                   eval      *in65 = *off
     C                   eval      iaflag = *off
     C                   eval      *in64 = *on
     C                   else
     C                   eval      *in65 = *on
     C                   endif
     *
     *   Get putaway option (Directed or Manual)
     *
     C                   eval      kycode = '*PICK   '
     C     opkey2        chain     optiond                            79
     C                   if        *in79
     C                   eval      opmput = 'N'
     C                   endif
     *
     *   Initialize indicator that displays pallet field.
     *
     C                   if        opmput = 'Y'
     C                   eval      *in96 = *off
     C                   else
     C                   eval      *in96 = *on
     C                   endif
     *
     *   Get ITEMMSC record for item.
     *
     C     imkey         chain     itemmsc                            79
     C                   if        *in79
     C                   eval      immflg = 'N'
     C                   eval      imdday = 0
     C                   eval      imuday = 0
     C                   eval      immday = 0
     C                   eval      imrg1c = 0
     C                   eval      imrg2c = 0
     C                   endif
     *
     *   Set screen 8 (date/weight) flag.
     *
     **         ITCWGT    IFEQ 'Y'
     **         ITFLGD    OREQ 'Y'
     C                   if        itflgd = 'Y'  or
     C                             immflg = 'Y'
     C                   eval      s8flag = *on
     C                   else
     C                   eval      s8flag = *off
     C                   endif
     *
     C                   if        itcwgt = 'Y'
     C                   if        svcwen = '1'  or
     C                             svcwen = '2'  and
     C                             pddwgt = 0
     C                   eval      s8flag = *on
     C                   endif
     C                   endif
     *
     *  If selected item is a Contract, Alias, SSB item .              . .
     *    Then get corresponding Base item.
     *
     C                   eval      #bitem = ititem
     C                   eval      #sitem = ititem
     C                   if        ittype = 'C'  or
     C                             ittype = 'A'  or
     C                             ittype = 'S'
     C                   call      'GETBASE'
     C                   parm      itwhse        $gwhse
     C                   parm      ititem        $gitem
     C                   parm      ' '           #bitem
     C                   parm                    #bityp            1
     C                   parm                    #bdesc
     C                   parm                    #bpdsc
     C                   parm                    #bwhdp
     C                   parm                    #bstyp
     C                   parm                    #bum1             2
     C                   parm                    #bum2
     C                   parm                    #bumq2
     C                   parm                    #bum3
     C                   parm                    #bumq3
     C                   parm      ' '           #bcitm           15
     C                   parm                    #bctyp            1
     C                   parm                    #bcdsc           30
     C                   parm                    #bcpds           15
     C                   parm                    #bcwdp            5
     C                   parm                    #bcstp            1
     C                   parm                    #bcum1            2
     C                   parm                    #bcum2            2
     C                   parm                    #bcuq2            3 0
     C                   parm                    #bcum3            2
     C                   parm                    #bcuq3            3 0
     C                   parm                    #brtn
     C                   endif
     *   Get slot item.
     C                   call      @getsi
     C                   parm      itwhse        $gwhse
     C                   parm      ititem        $gitem
     C                   parm      ' '           #sitem           15
     C                   parm                    #sityp            1
     C                   parm                    #sdesc           30
     C                   parm                    #spdsc           15
     C                   parm                    #srtn            10
     C                   parm                    #smsg            60
     *
     *   Get the picking slot for the item.
     *
     C                   if        itstyp = 'P'
     C                   eval      $scmd = '*LAST'
     C                   else
     C                   eval      $scmd = '*FIRST'
     C                   endif
     C                   call      'GETPSLT'
     C                   parm                    $scmd             8
     C                   parm      itwhse        $swhse
     **                   PARM           ITITEM
     **                   PARM           #BITEM
     C                   parm                    #sitem
     C                   parm                    wohome
     C                   parm      *blanks       $saisl            3
     C                   parm      *zeros        $sloc             3 0
     C                   parm      *zeros        $srlvl            2 0
     C                   parm      *blanks       $shand            2
     C                   parm                    $srtn             8
     *
     *   Get preferred tie/high.
     *
     C                   call      'GETPTIHI'
     C                   parm      itwhse        prfwhs            3 0
     C                   parm                    ititem
     C                   parm                    prfti             4 0
     C                   parm                    prfhi             2 0
     C                   parm                    prfth             7
     C                   parm                    $lrtn
     C                   eval      wotihi = prfth
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGTPDM  Get P/O Detail Misc. file
     *
     C     ZZGTPDM       Begsr
     C*
     C*    fileky        chain     podtlm
     C     podkey        chain     podtlm
     C                   if        not %found(podtlm)
     C                   eval      pdmms1 = ' '
     C                   endif
     *
     C                   Endsr
     *----------------------------------------------------------------
     *  ZZLICINFOCAN  User cancelled - licinfo needs to be deleted
     *----------------------------------------------------------------

      /free
        begsr zzlicinfocan;

          exsr clr$licinfo;

          $lnwhse  = $pwhse;
          if $pxd = ' ';
            $lnlcns  = w13lcns;
          else;
            $lnlcns  = templcns;
          endif;

          $dricommand = '*LICINFO';
          $drisubcmd  = '%DELETEALL';
          $drisys2upd = 'D';
          chk4err = *on;
          exsr zzzdricop;
          if error = *on;
          endif;

        endsr;
      /end-free
     *----------------------------------------------------------------
     *  ZZLICINFOCHK  Check to see if licinfo exist for this lcnslot/exp
     *----------------------------------------------------------------

      /free
        begsr zzlicinfochk;

          Lastseq  = 1;
          dow forevr = forevr;

          exsr clr$licinfo;

          $lnwhse  = $pwhse;
          if $pxd = ' ';
            $lnlcns  = w12lcns;
          else;
            $lnlcns  = templcns;
          endif;
          $lnseq  = lastseq + 1;

          $dricommand = '*LICINFO';
          $drisubcmd  = '%GET';
          $drisys2upd = 'D';
          chk4err = *on;
          exsr zzzdricop;
          if error = *on;
            leave;
          else;
            // compare lot and date fields
            if $lnlot = $bclot and
               $lnexpdate = expd;
              // add qty and weight, update licinfo
              $lnttllbs = $lnttllbs + $pwgt;
              $lnseqqty = $lnseqqty + 1;
              $dricommand = '*LICINFO';
              $drisubcmd  = '%CHANGES';
              $drisys2upd = 'D';
              chk4err = *on;
              exsr zzzdricop;
              licinfoupd = *on;
              leave;
            endif;
            eval lastseq = lastseq + 1;
          endif;

        enddo;
        endsr;
      /end-free
     *----------------------------------------------------------------
     *  ZZLICINFOSEQ  Used to get the current lnseqqty for accumulator
     *----------------------------------------------------------------

      /free
        begsr zzlicinfoseq;

          exsr clr$licinfo;

          $lnwhse  = $pwhse;
          if $pxd = ' ';
            $lnlcns  = w12lcns;
          else;
            $lnlcns  = templcns;
          endif;
          $lnseq  = 1;

          $dricommand = '*LICINFO';
          $drisubcmd  = '%GET';
          $drisys2upd = 'D';
          chk4err = *on;
          exsr zzzdricop;
          if error = *on;
          else;
            // accumulate the lnseqqty field
            $lnseqqty = $lnseqqty + 1;
            $dricommand = '*LICINFO';
            $drisubcmd  = '%CHANGES';
            $drisys2upd = 'D';
            chk4err = *on;
            exsr zzzdricop;
            licinfoupd = *on;
          endif;

        endsr;
      /end-free
     *----------------------------------------------------------------
     *  ZZLICINFONew Update New format of LICINFO
     *----------------------------------------------------------------

      /free
        begsr zzlicinfonew;

          // Write out standard license information
          exsr clr$licinfo;

          $lnwhse  = $pwhse;
          if $pxd = ' ';
            $lnlcns  = w12lcns;
          else;
            $lnlcns  = templcns;
          endif;

          if difflot or diffexpd;
            $lnseq = lastseq + 1;
            $lnseqqty = $lnseqqty + 1;
            $lnttllbs = $pwgt;
          else;
            $lnseq = 1;
            $lnseqqty = 1;
          endif;
          $lnpo = $po;
          $lnposeq = $poseq;
          $lnitem = $poitm;
          // LNRCVTYP notes
          // 1 = Manual quantity (original method)
          // 2 = Manual quantity with initial GS1 scan
          // 3 = UCI using Mfg GS1 barcodes
          // 4 = UCI using Internal GS1 barcodes (start with 99)
          // 5 = ASN file

          select;
            when $ifucicde = ' ';
              $lnrcvtyp = '1';
            when $ifucicde = '1';
              $lnrcvtyp = '1';
            when $ifucicde = '2';
              $lnrcvtyp = '3';
            when $ifucicde = '3';
              $lnrcvtyp = '4';
            // don't know exactly what 2 will represent
          endsl;
          $lnrcvtrn# = 0;
          $lnrcvlbl# = 0;

          select;
            //when w1fifo <> 0;
              //$lnentdate = wofifo;
            when w8dte  <> 0 and $immflg = 'Y';
              $lnentdate = womfdt;
            when w8dte  <> 0 and $immflg <>'Y' and $itflgd = 'Y';
              $lnentdate = woexdt;
            other;
          endsl;

          if wofifo > 0;
            $lnenttype = '*FIFODT';
          else;
            if $itflgd = 'Y';
              select;
                when $imuday > 0 or
                     $imdday > 0;
                  if $immflg = 'Y';
                    $lnenttype = '*MFGDTE';
                  else;
                    $lnenttype = '*USEDTE';
                  endif;
                other;
                  $lnenttype = '*EXPDTE';
              endsl;
            else;
              $lnenttype = '*ENTDTE';
            endif;

            $lndateflag = $itflgd;
            $lnmfgflag = $immflg;

            $lnmfgdays = $immday;
            $lnusrdays = $imuday;
            $lndstdays = $imdday;
          endif;

          $lnmfgdate = womfdt;

          if mexpd > 0;
            $lnmfgexp = mexpd;
          endif;

          if wofifo > 0;
            $lnfifodate = wofifo;
          endif;

          if expd > 0;
            $lnexpdate = expd;
          endif;

          if $ldecvalue > ' ';
            $lnmfgcode = $ldecvalue;
          endif;

          $lnavglbs = 0;

          if $bclot <> ' ';
            $lnlot = $bclot;
          endif;

          //if w1brand <> ' ';
            $lnbrand = ' ';
          //endif;

            // calculate the PTI.
            if $bclot <> ' ' and $bcgtinsent;
              pplot  = %subst($bclot: 1 : 20);
              calcpti ($bcgtin: pplot: $pmfgdt: pppti);
              if pppti > 0;
                $lnlotPTI4 = %editc(pppti:'X');
                $lnlotPTI2 = %Subst(%EditC(pppti:'X'):3:2);
              endif;
            endif;

          $dricommand = '*LICINFO';
          $drisubcmd  = '%ADDS';
          $drisys2upd = 'D';
          chk4err = *on;
          exsr zzzdricop;
          if error = *on;
          endif;

        endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  ZZUCI    Write UCI data
     *
     C     zzuci         begsr
     c                   if        $ldecvalue = ' '
     c                   exsr      zzmfrdates
     c                   endif
     C                   if        $immflg = 'Y'
     *
     *  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w8dte         $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        expd
     C                   move      $cvd8o        womfdt


     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      expd          $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $immday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C                   parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      $cddateout    $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $imuday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     expd          parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      expd          $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C****               move      $cvd6o        w8dte

     *
     C                   endif
     * add records to uci file
     *
     *    Get User's employee number to be written to PORCV file
     *    if any records are flagged as touched.
     *
     C*                  eval      $code = #user
     C*                  eval      $whse = *zeros
     C*                  eval      $emp# = *zeros
     C*                  eval      $fnam = *blanks
     C*                  eval      $init = *blanks
     C*                  eval      $lnam = *blanks
     C*                  eval      $whdp = *blanks
     C*                  eval      $styp = *blanks
     C*                  eval      $shft = *blanks
     C*                  eval      $crew = *blanks
     C*                  eval      $nhrs = 0
     C*                  eval      $rtn = *blanks
     C*                  call      'GETUSER'
     C*                  parm                    $code
     C*                  parm                    $whse
     C*                  parm                    $emp#
     C*                  parm                    $fnam
     C*                  parm                    $init
     C*                  parm                    $lnam
     C*                  parm                    $whdp
     C*                  parm                    $styp
     C*                  parm                    $shft
     C*                  parm                    $crew
     C*                  parm                    $nhrs
     C*                  parm                    $rtn
      /free
        // need to determine if the licinfo record already exist for
        // this lcns/lot/exp date - keep checking until we find a match
        // or no more licinfo records exist - if no match and no licinfo
        // exist need to write the next available seq# to licinfo.
        // if licinfo record exist - just update the qty and the weight
        select;
          when moretoscan = *on and difflot = *on  or
               moretoscan = *on and diffexpd = *on;
            exsr zzlicinfochk;
          when moretoscan = *on and difflot <> *on and diffexpd <> *on;
            exsr zzlicinfoseq;
        endsl;

        if licinfoupd <> *on and difflot = *on or
           licinfoupd <> *on and diffexpd = *on or
           moretoscan <> *on;
          exsr zzlicinfonew;
        endif;

        exsr clr$uciinfo;
        $uiWhse = $pwhse;
        $uiItem = $poitm;
        $uiuci = w11uci;
        ucilic#($unext: $pwhse);
        unexta = %editc($unext:'X');
        $uiuciLcns = 'U:' + unexta;
        if $pxd = ' ';
          $uiLcns = w12lcns;
        else;
          $uiLcns = templcns;
        endif;
        if difflot = *on or
          diffexpd = *on;
          $uiseq = $lnseq;
        else;
          $uiseq = 1;
        endif;
        $uiSerial = $bcSer#;
        if $bcgtin = *blanks;
           $uiaGTin = 0;
        else;
           $uiaGtin   = %DEC($bcgtin:14:0);
        endif;
740fA   if $bcai99sent and saveqty = 0;
740fA     uputyp = 'N';
740fA   endif;
        $uiaLot    = $bclot;
        $uiaUTyp   = uputyp;
        $uiaSlUTyp = uputyp;
        if saveexpd = 0;
           $uiaExpD   = expd;
        else;
           $uiaExpD = saveexpd;
        endif;
        $uiaEntD   = today;
        // if user entered weight use that/ if uci had weight use that
        // 700e metric changes
        select;
          //when w1dwgt > 0;
          when w11dwgt > 0 and kilolbs = 'P';
740jD       //$uiwgtlbs = w11dwgt;
740jM       $uiwgtlbs = w11dwgt / 100;
          when $bcPNtLbSent = *on;
            $uiwgtlbs = $bcPNtLb;
          other;
            $uiwgtlbs = 0;
        endsl;
        // Weight KG  - only if uci barcode contained KG
        // 700e metric changes - if item options weight uom = kgs
        select;
          when svopwum = 'KGS'
           or  svopwum = 'kgs'
           or  svopwum = 'Kgs';
            select;
              when w11dwgt > 0 and kilolbs = 'K';
740jD           //$uiwgtkgs = w11dwgt;
740jM           $uiwgtkgs = w11dwgt / 100;
              when w11dwgt > 0 and kilolbs = 'P';
                $uiwgtkgs = cnvwgt;
              when $bcPNtkgSent = *on;
                $uiwgtkgs = $bcPNtkg;
              other;
                $uiwgtkgs = 0;
            endsl;
          other;
            if $bcPNtKgSent = *on;
              $uiWgtKgs = $bcPntKg;
            else;
              $uiWgtKgs = 0;
            endif;
        endsl;
        $uiSelTrn# = 0;
        $uiSelLbl# = 0;
        $uiSelOrd = 0;
        $uiSelSeq = 0;
        $uiSelCSeq = 0;
        $uiSelTrax = ' ';
        $uiCrtBy = '1';

        // Lets add some more stuff for tracking
        $uiaction = 'RCV';
        $uiaolcns = $uilcns;
        $uialcns = $uilcns;
        $uiaoseq = $uiseq;
        $uiscan = 'Y';

        $dricommand = '*UCIINFO';
        $drisubcmd  = '%ADD';
        $drisys2upd = 'D';
        chk4err = *on;
        zmflag  = *off;
        exsr zzzdricop;
        if error = *on;
          uciExists = *on;
          error = *on;
          errmsg= 'UCI Barcode';
          exsr zm02;
          leavesr;
        else;
          UciExists = *off;
          error = *off;
740hA     scan = scan + 1;
        endif;

        // save the values from the first scan to be used for the license
        if moretoscan <> *on;
          if $immflg = 'Y';
            savew1mfdt = w8dte;
          endif;
          if $itflgd = 'Y' and $immflg <> 'Y';
            savew1exdt = w8dte;
          endif;
          select;
            when $pmfgdt <> 0;
              savedate = $pmfgdt;
            when $pexpdt <> 0;
              savedate = $pexpdt;
            other;
              savedate = 0;
          endsl;

          saveexpd = expd;
          savelotc = $bcLot;
          if $bclotSent;
            *in85 = *on;
          endif;

        endif;
        //savewgt  = savewgt + w11dwgt;
        savewgt  = savewgt + cnvwgt;
        saveqty  = saveqty + 1;
        // scan some more uci barcodes
        // save first scanned lot and dates
        moretoscan = *on;
740fA   nextfirst = 'Scan next Uci';
        *in80 = *on;
        nxtscr = '11 ';
        $puci = ' ';
        w11uci = ' ';
        savew11uci = ' ';
        ovrrid = *off;
        difflot = *off;
        diffexpd = *off;
        lotwarn = *off;
        UPCwarn = *off;
        datewarn = *off;
        lotovr  = *off;
        UPCovr  = *off;
        dateovr  = *off;
        licinfoupd = *off;
        w11dte = 0;
        w11dwgt = 0;
740iA   wtchk = *off;

      /end-free
     c
     C     enduci        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      forevr = *on
     C                   eval      redspl = *off
     C                   eval      $rprg = #prog
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     *
     *  Define partial key for item tie/high definition file.
     *
     C     partk2        klist
     C                   kfld                    wobat
     C                   kfld                    $pwhse
     *
     *  Define key for POHDR file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    wopo
     *
     *  Define key for PODTL file.
     *
     C     podkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    wopo
     C                   kfld                    woline
     C                   kfld                    woitm#
     *  Define partial key for PODTL file.
     *
     C     partky        klist
     C                   kfld                    $pwhse
     C                   kfld                    wopo
     C                   kfld                    woline
     *
     *  Define partial key for PODTL file.
     *
     C     prtdky        klist
     C                   kfld                    $pwhse
     C                   kfld                    wopo
     *
     *  Define key for PODTL1 file.
     *
     C     podky1        klist
     C                   kfld                    $pwhse
     C                   kfld                    wopo
     C                   kfld                    woitm#
     *
     *  Define key for UPC file.
     *
     C     upckey        klist
     C                   kfld                    $pwhse
     C                   kfld                    kyupc
     **                   KFLD           W2UPC
     *
     *  Define key for UPC1 file.
     *
     C     upcky1        klist
     C                   kfld                    $pwhse
     C                   kfld                    woitm#
     C                   kfld                    phven
     *
     *  Define key for PIRITEM file.
     *
     C     itkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    woitm#
     *
     *  Define key for LICENSE file.
     *
     C     lcnsky        klist
     C                   kfld                    $pwhse
     C                   kfld                    w7lcns
     *
     *     OPTIONS
     *
     C     opkey         klist
     *                    KFLD           W1WHSE
     C                   kfld                    wkwhse
     C                   kfld                    ocode
     *
     *  Define key for OPTIOND.
     *
     C     opkey2        klist
     C                   kfld                    kycode
     C                   kfld                    $pwhse
     C                   kfld                    itwhdp
     C                   eval      kycode = '*PICK   '
     *
     *  Define key for LABEL2  file.
     *
     C     lbkey         klist
     C                   kfld                    $rord
     C                   kfld                    $pwhse
     *
     *  Define key for ITEMMSC file.
     *
     C     imkey         klist
     C                   kfld                    itwhse
     C                   kfld                    ititem
     *
     *  Define full key for PODTL3 file.
     *
     C     detlky        klist
     C                   kfld                    pdwhse
     C                   kfld                    pdpo
     C                   kfld                    pdseq
     *
     *  Define key for POCTYPE file.
     *
     C     keypoc        klist
     C                   kfld                    $pwhse
     C                   kfld                    wopo
     C                   kfld                    woline
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   eval      #pgmq = #prog
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C                   parm      0             #whse
     *
     C                   eval      $pwhse = #whse
     *
      * determine if mfr decipher is available to client
     c                   eval      $lcmd = '*OPEN'
     c                   call      'MF200'                              66
     C                   parm                    $lparm
     C                   parm      0             $lexpdat          6 0
     C                   parm      0             $lmfrdat          6 0
     C                   parm                    $lupc            20
     C                   parm      ' '           $ldecvalue       15
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
740hAc                   eval      scan = 0
     C                   exsr      zzgeti
     C                   setoff                                       kckl
     C                   eval      dtchk = *off
     C                   eval      dtchk2 = *off
     C                   eval      dtchk3 = *off
     C                   eval      dtchk4 = *off
     C                   eval      qtchk = *off
     C                   eval      wtchk = *off
     *
     *   Get screen size being used.
     *
     C                   call      'PIRRFSCR'
     C                   parm      '*GET'        #lcmd             8
     C                   parm                    #lline            2
     C                   parm                    #lcol             3
     *  Not anymore ---> Force to 16 line version for ISupply.
     *  Force to 8 line version for ISupply.
     C                   if        client = isupply
     C**                 eval      #lline = '16'
     C                   eval      #lline = '08'
     C                   eval      #lcol = '020'
     C                   Endif
     *
     C                   call      'RC160'
     C                   parm      '*OPEN   '    $rcmd             8
     C                   parm                    $rprg            10
     C                   parm      '*INTER  '    $rtype            8
     C                   parm                    $pwhse            3 0
     C                   parm                    woitm#           15
     C                   parm                    w3qt01
     C                   parm      0             w3qt02            5 0
     *R                   PARM           W3QT02
     C                   parm      0             w3qt03            5 0
     C                   parm                    wopo
     C                   parm                    w1ven            11 0
     C                   parm                    w1vnam           40
     C                   parm                    w2vitm           15
     C                   parm      0             $rord             7 0
     C                   parm      *blanks       $rrcod            2
     C                   parm      *blanks       $rrmem           30
     C                   parm                    $rexpd            8 0
     C                   parm      0             $rfifo            8 0
     C                   parm                    w1dev            10
     C                   parm                    w1form           10
     C                   parm                    $rslot           12
     C                   parm      0             $rseq
     C                   parm                    $rrpck            1
     C                   parm                    $rplbl            1
     C                   parm                    w3twgt            9 2
     C                   parm                    $rrq1             5 0
     C                   parm                    $rrq2             5 0
     C                   parm                    $rrq3             5 0
     C                   parm                    $rrpal            3 0
     C                   parm                    $rrtn             8
     C                   parm                    $rmsg             4
     *
     *R                   MOVE *ON       LFLAG   1
     C                   eval      lflag = *off
     C                   eval      refrsh = *on
     **                   EXSR ZZLCNS
     C                   exsr      zzxopt
     C                   eval      ocode = '*SYSTEM '
     C                   eval      wkwhse = 0
     C     opkey         chain     options                            79
     C                   eval      sydata = opdata
     C                   if        *in79
     C                   eval      opcapc = 'Y'
     C                   eval      opwrnc = 'N'
     C                   eval      oprg1c = 0
     C                   eval      oprg2c = 0
     C                   eval      opicw = 'N'
     C                   endif
     *
     *   Get Item Maintenance options.
     *
      /free
         //wkwhse = $pwhse;
         getimuom(#whse: IMkilolbs: IMUom);
         select;
           when IMkilolbs = 'K';
             KiloLbs = 'K';
             dspuom  = IMUom;
             *in67 = *off;
           other;
             kiloLbs = 'P';
             dspuom  = 'Lbs';
             *in67 = *on;
         endsl;
      /end-free
     C                   exsr      zzlcns
     *
     *    Get User's employee number to be written to PORCV file
     *    if any records are flagged as touched.
     *
     C                   call      'GETUSER'
     C                   parm      #user         $code            10
     C                   parm      0             $whse             3 0
     C                   parm      0             $emp#             5 0
     C                   parm      *blanks       $fnam            15
     C                   parm      *blanks       $init             1
     C                   parm      *blanks       $lnam            20
     C                   parm      *blanks       $whdp             5
     C                   parm      *blanks       $styp             1
     C                   parm      *blanks       $shft             6
     C                   parm      *blanks       $crew             6
     C                   parm      0             $nhrs             3 1
     C                   parm      *blanks       $rtn              8
     C                   parm                    e$bpu             1
     C                   parm                    e$lng             2
     C                   if        $rtn <> '*OK'
     C                   eval      e$lng = 'EN'
     C                   endif
     c                   exsr      zzfil11
     c                   exsr      zzchk11
     c                   if        error = *on
     c                   eval      nxtscr = '11 '
     c                   eval      $puci = ' '
     c                   else
     C                   exsr      scr12i
     c                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZLCNS   Get use generic license option
     *
     C     zzlcns        begsr
     *
     *   Get use generic license option.
     C                   eval      lflag = *off
     C                   eval      svexck = *on
     C                   eval      svcwen = *on
     C                   eval      svcwtp = *on
     C                   eval      svcwfr = 'N'
     C                   eval      svrupc = 'N'
     C                   eval      ocode = '*RCVLBL '
     C                   eval      wkwhse = $pwhse
     *
     C     opkey         chain     options                            79
     C                   if        not *in79
     C                   eval      rcdata = opdata
     C                   if        opplcn = 'Y'
     C                   eval      lflag = *on
     C                   endif
     C                   if        client = Dairyland
     C                   eval      opcwen = '2'
     C                   eval      opcwtp = '2'
     C                   eval      opcwfr = 'Y'
     C                   endif
     C                   eval      svexck = opexck
     C                   eval      svcwen = opcwen
     C                   eval      svcwtp = opcwtp
     C                   eval      svcwfr = opcwfr
     C                   eval      svrupc = oprupc
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZPDIR   Directed putaway
     *
     C     zzpdir        begsr
     *
     C                   call      'RC160'
     C                   parm      '*RECEIVE'    $rcmd
     C                   parm                    $rprg
     C                   parm      '*INTER  '    $rtype
     C                   parm                    $pwhse
     C                   parm                    woitm#
     C                   parm                    w3qt01
     C                   parm                    w3qt02
     C                   parm      0             w3qt03
     C                   parm                    wopo
     C                   parm                    w1ven
     C                   parm                    phvnam
     C                   parm                    pdvitm
     C                   parm      0             $rord
     C                   parm      *blanks       $rrcod
     C                   parm      *blanks       $rrmem
     C                   parm      expd          $rexpd
     C                   parm      0             $rfifo
     C                   parm                    w1dev
     C                   parm                    w1form
     C                   parm      *blanks       $rslot
     C                   parm                    woline
     C                   parm                    $rrpck
     C                   parm                    $rplbl
     C                   parm                    w8twgt
     C                   parm                    $rrq1
     C                   parm                    $rrq2
     C                   parm                    $rrq3
     C                   parm                    $rrpal
     C                   parm                    $rrtn
     C                   parm                    $rmsg
     *
     C                   if        $rrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      #msgk = $rmsg
     C                   exsr      zmqmsg
     C                   goto      endpdr
     C                   endif
     *
     **                   ADD  $RRQ1     $PRSQT
     **                   ADD  $RRQ2     $PRSQT
     **                   ADD  $RRQ3     $PRSQT
     *
     C**                 if        lflag = *on
     C                   eval      $lflag = lflag
     C                   if        lflag = *off
     C                   eval      $lcmd = '*LICONLY'
     C                   else
     C                   eval      $lcmd = '*CHANGE '
     C                   endif
     C                   eval      $lwhse = $pwhse
     C                   eval      $lpo2 = w1po
     C                   eval      $litem = woitm#
     C                   eval      $lrq1 = w3qt01
     C                   eval      $lrq2 = w3qt02
     C                   eval      $lrq3 = 0
     C                   eval      $lrpal = w3plt
     C                   eval      $lum1 = woum1
     C                   eval      $lum2 = woum2
     C                   eval      $lum3 = *blanks
     C                   eval      $lord = $rord
     C                   eval      $lven = phven
     C                   eval      $lvnam = phvnam
     C                   eval      $lvitm = pdvitm
     *
     *    Lot tracking item - Pass single char flag to license entry pgm
     C                   if        lottrk = '*YES'
     C                   eval      $llott = 'Y'
     C                   else
     C                   eval      $llott = 'N'
     C                   endif
     *    Lic.tracking item - Pass single char flag to license entry pgm
     C                   if        lictrk = '*YES'
     C                   eval      $llict = 'Y'
     C                   else
     C                   eval      $llict = 'N'
     C                   endif
     *
     C                   eval      $lseq = pdseq
     C                   eval      $ldwgt = w8twgt
     C                   eval      $llotc = w9lotc
     *
      ** do we need to print box labels
      ** 4 and 6 print normal uom labels
     c                   if        $ifrcvmth = '4' and $lrq1 > 0 or
     c                             $ifrcvmth = '6' and $lrq1 > 0
     c                   eval      $bpo = $lpo
     c                   eval      $brcvdt = today
     c                   eval      $bqty = $lrq1
     c                   eval      $bprint = '*JOB'
     c                   eval      $bitem = $litem
     c                   eval      $buom =  $lum1
     c                   call      'PO250'
     C                   parm                    $bparm
     c                   endif
      **
      ** 5 and 6 print breakdown1 uom labels
     c                   if        $ifrcvmth = '5' and $lum2 <> ' ' and
     c                             $itflg1 = 'Y' or
     c                             $ifrcvmth = '6' and $lum2 <> ' ' and
     c                             $itflg1 = 'Y'
     c                   eval      $bpo = $lpo
     c                   eval      $brcvdt = today
     c                   if        $lrq1 <> 0
     c                   eval      $bqty = ($lrq1 * $itumq2) + $lrq2
     c                   else
     c                   eval      $bqty = $lrq2
     c                   endif
     c                   eval      $bprint = '*JOB'
     c                   eval      $bitem = $litem
     c                   eval      $buom =  $lum2
     c                   call      'PO250'
     C                   parm                    $bparm
     c                   endif
      **
      ** 5 and 6 print breakdown2 uom labels
     c                   if        $ifrcvmth = '5' and $lum3 <> ' ' and
     c                             $itflg2 = 'Y' or
     c                             $ifrcvmth = '6' and $lum3 <> ' ' and
     c                             $itflg2 = 'Y'
     c                   eval      $bpo = $lpo
     c                   eval      $brcvdt = today
     c                   if        $lrq1 <> 0 or $lrq2 <> 0
     c                   eval      $bqty = ($lrq1 * $itumq2 * $itumq3)
     c                                   + ($lrq2 * $itumq3) + $lrq3
     c                   else
     c                   eval      $bqty = $lrq3
     c                   endif
     c                   eval      $bprint = '*JOB'
     c                   eval      $bitem = $litem
     c                   eval      $buom =  $lum3
     c                   call      'PO250'
     C                   parm                    $bparm
     c                   endif
      **
     C                   call      'PO136'
     C                   parm                    $lparm
     C                   parm                    $lum1
     C                   parm                    $lum2
     C                   parm                    $lum3
     C                   parm                    $lord
     C                   parm                    $lflag            1
     C                   parm                    $lseq             5 0
     C                   parm                    $lven
     C                   parm                    $lvnam
     C                   parm                    $lvitm
     C                   parm      expd          $rexpd
     C                   parm                    $pdev
     C                   parm                    $pform
     C                   parm                    $ldwgt            9 2
     C                   parm                    avgwt1
     C                   parm                    avgwt2
     C                   parm                    avgwt3
     C                   parm                    $llotc           30
     C                   parm                    womfdt
     C                   parm      0             wofifo
     C                   parm                    woupc
     c                   parm                    $ldecvalue
     C                   parm      mexpd         $lmfgex           8 0
     C                   parm      mfgdte        $lmfgdt           8 0
     c                   parm      ' '           $plpn            50
     c                   parm      w12lcns       $pgslcns         15
     c                   parm      ' '           $pbrand          10
     c                   parm                    $parms1
     C                   parm                    $lsavetrn
     c                   parm                    $pgtin           14
     c                   parm      $pmfgdt       $pbcProdD         6 0
     c                   parm                    $pbclot          20
     c                   parm      0             $pw1pti
     C**                 endif
     C                   if        $lrtn = '*OK     '
     c                   eval      rcvpocomplete = *on
     C                   endif
     *
     *    Write records to POMFR file.
     *    Note: RC160 returns batch number in $RORD field which is
     *          used as first part of the LBKEY.
     *
     C     lbkey         setll     label2
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     lbkey         reade     label2                                 79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   if        immflg = 'Y'
     C     lblbl#        chain     pomfr1                             78
     C                   eval      pmwhse = lbwhse
     C                   eval      pmpo = lbpo
     C                   eval      pmseq = lbseq
     C                   eval      pmitem = lbitem
     C                   eval      pmexpd = $rexpd
     C                   eval      pmmfgd = mfgd
     C                   eval      pmtrn# = lbtrn#
     C                   eval      pmlbl# = lblbl#
     C                   if        not *in78
     C                   update    pmrec
     C                   else
     C                   write     pmrec
     C                   endif
     *
     *      Write record to item exception file for date override.
     *
      * add additional exception if date decipher error
     c                   if        ddcode = *on
     C                   eval      exerid = 'DD-CODE'
     C                   eval      exwhse = lbwhse
     C                   eval      exwhdp = lbwhdp
     C                   eval      exstyp = lbstyp
     C                   eval      exitem = lbitem
     C                   eval      dspo = lbpo
     C                   eval      dslbl = lblbl#
     C                   eval      dsexpd = $dto
     C                   eval      exfdis = dsfdis
     C                   eval      extdis = dstdis
     C                   eval      exgdte = lbsdte
     C                   eval      exgtim = lbstim
     C                   eval      exqty = 0
     C                   eval      extask = 'RCV'
     C                   eval      exgby = #user
     C                   eval      exesta = '1 '
     C                   write     exrec
     C                   eval      ddcode = *off
     c                   endif
     C                   if        cwovr = *on  or
     C                             odovr = *on
     C                   eval      exwhse = lbwhse
     C                   eval      exwhdp = lbwhdp
     C                   eval      exstyp = lbstyp
     C                   eval      exitem = lbitem
     C                   eval      dspo = lbpo
     C                   eval      dslbl = lblbl#
     C                   eval      dsexpd = $dto
     C                   eval      exfdis = dsfdis
     C                   eval      extdis = dstdis
     C                   eval      exgdte = lbsdte
     C                   eval      exgtim = lbstim
     *
     C                   if        lbqpck > 999
     C                   eval      exqty = 999
     C                   else
     *
     C                   z-add     lbqpck        exqty
     C                   endif
     *
     C                   eval      extask = 'RCV'
     C                   eval      exgby = #user
     C                   if        odovr = *on
     ***                  MOVEL'DAYSOVR' EXERID
     C                   eval      exerid = 'EXPDOVR'
     C                   else
     C                   eval      exerid = 'EXPDOVR'
     C                   endif
     C                   eval      exesta = '1 '
     C                   write     exrec
     C                   eval      odovr = *off
     C                   endif
     *
     C                   endif
     C                   if        lflag = *off
     C                   exsr      zzurcv
     C                   endif
     C                   endif
     C                   enddo
     *
     C                   exsr      zzuhdr
     c                   if        rcvpocomplete = *on
     c                   exsr      zzrcvpoclose
     c                   eval      rcvpocomplete = *off
     c                   eval      $lsavetrn = 0
     c                   endif
     *
     C     endpdr        endsr
     *----------------------------------------------------------------
     *
     *  ZZPMAN   Manual putaway
     *
     C     zzpman        begsr
     *
     *   Enter qty per pallet and license.
     *
     C                   eval      $lflag = lflag
     C                   eval      $lcmd = '*CHANGE '
     C                   eval      $lwhse = $pwhse
     C                   eval      $lpo2 = w1po
     C                   eval      $litem = woitm#
     C                   eval      $lrq1 = w3qt01
     C                   eval      $lrq2 = w3qt02
     C                   eval      $lrq3 = 0
     C                   eval      $lrpal = w3plt
     C                   eval      $lum1 = woum1
     C                   eval      $lum2 = woum2
     C                   eval      $lum3 = *blanks
     C                   eval      $lord = $rord
     C                   eval      $lseq = pdseq
     C                   eval      $lven = phven
     C                   eval      $lvnam = phvnam
     C                   eval      $lvitm = pdvitm
     C                   eval      $ldwgt = 0
     *
     *    Lot tracking item - Pass single char flag to license entry pgm
     C                   if        lottrk = '*YES'
     C                   eval      $llott = 'Y'
     C                   else
     C                   eval      $llott = 'N'
     C                   endif
     *    Lic.tracking item - Pass single char flag to license entry pgm
     C                   if        lictrk = '*YES'
     C                   eval      $llict = 'Y'
     C                   else
     C                   eval      $llict = 'N'
     C                   endif
     C                   eval      wofifo = 0
     * Move mfg or expire or fifo date to keyed in date field
     * to send to PO236
     C                   eval      woindt = 0
     C                   select
     C                   when      wofifo <> 0
     C                   eval      woindt = wofifo
     C                   when      w8mfdt <> 0
     C                   eval      woindt = womfdt
     C                   other
     C                   eval      woindt = woexdt
     C                   endsl
     *
      ** do we need to print box labels
      ** 4 and 6 print normal uom labels
     c                   if        $ifrcvmth = '4' and $lrq1 > 0 or
     c                             $ifrcvmth = '6' and $lrq1 > 0
     c                   eval      $bpo = $lpo
     c                   eval      $brcvdt = today
     c                   eval      $bqty = $lrq1
     c                   eval      $bprint = '*JOB'
     c                   eval      $bitem = $litem
     c                   eval      $buom =  $lum1
     c                   call      'PO250'
     C                   parm                    $bparm
     c                   endif
      **
      ** 5 and 6 print breakdown1 uom labels
     c                   if        $ifrcvmth = '5' and $lum2 <> ' ' and
     c                             $itflg1 = 'Y' or
     c                             $ifrcvmth = '6' and $lum2 <> ' ' and
     c                             $itflg1 = 'Y'
     c                   eval      $bpo = $lpo
     c                   eval      $brcvdt = today
     c                   if        $lrq1 <> 0
     c                   eval      $bqty = ($lrq1 * $itumq2) + $lrq2
     c                   else
     c                   eval      $bqty = $lrq2
     c                   endif
     c                   eval      $bprint = '*JOB'
     c                   eval      $bitem = $litem
     c                   eval      $buom =  $lum2
     c                   call      'PO250'
     C                   parm                    $bparm
     c                   endif
      **
      ** 5 and 6 print breakdown2 uom labels
     c                   if        $ifrcvmth = '5' and $lum3 <> ' ' and
     c                             $itflg2 = 'Y' or
     c                             $ifrcvmth = '6' and $lum3 <> ' ' and
     c                             $itflg2 = 'Y'
     c                   eval      $bpo = $lpo
     c                   eval      $brcvdt = today
     c                   if        $lrq1 <> 0 or $lrq2 <> 0
     c                   eval      $bqty = ($lrq1 * $itumq2 * $itumq3)
     c                                   + ($lrq2 * $itumq3) + $lrq3
     c                   else
     c                   eval      $bqty = $lrq3
     c                   endif
     c                   eval      $bprint = '*JOB'
     c                   eval      $bitem = $litem
     c                   eval      $buom =  $lum3
     c                   call      'PO250'
     C                   parm                    $bparm
     c                   endif
      **
     C                   call      'PO236'
     C                   parm                    $lparm
     C                   parm                    $lum1
     C                   parm                    $lum2
     C                   parm                    $lum3
     C                   parm                    $lord
     C                   parm                    $lflag
     C                   parm                    $lseq
     C                   parm                    $lven
     C                   parm                    $lvnam
     C                   parm                    $lvitm
     C                   parm      expd          $rexpd
     C                   parm                    $pdev
     C                   parm                    $pform
     C                   parm                    w8twgt
     C                   parm                    avgwt1
     C                   parm                    avgwt2
     C                   parm                    avgwt3
     C                   parm                    w9lotc
     C*                  parm                    womfdt
     C                   parm                    woindt
     C*                  parm      0             wofifo
     C                   parm                    wofifo
     C                   parm                    woupc
     c                   parm                    $ldecvalue
     C                   parm      mexpd         $lmfgex           8 0
     C                   parm      mfgdte        $lmfgdt           8 0
     c                   parm      ' '           $plpn            50
     c                   parm      w12lcns       $pgslcns         15
     c                   parm      ' '           $pbrand          10
     c                   parm                    $parms1
     C                   parm                    $lsavetrn         7 0
     C                   parm                    $pgtin           14
     c                   parm      $pmfgdt       $pbcProdD
     c                   parm                    $pbclot
     c                   parm      0             $pw1pti
     c                   parm      ' '           $posscode
     *
     C     $lrtn         cabeq     '*EXIT'       endpdm
     C     $lrtn         cabeq     '*CANCEL'     endpdm
     *
     *    Write records to POMFR file.
     *    Note: RC160 returns batch number in $RORD field which is
     *          used as first part of the LBKEY.
     *
     C                   if        $lrtn = '*OK     '
     c                   eval      $ldecvalue  = ' '
     c                   eval      $lmfgex = 0
     c                   eval      $lmfgdt = 0
     c                   eval      mexpd     = 0
     c                   eval      mfgdte   = 0
     c                   eval      rcvpocomplete = *on
     C                   if        w8mfdt <> 0  or
     C                             w8exdt <> 0
     C                   eval      $rord = $lord
     C     lbkey         setll     label2
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     lbkey         reade     label2                                 79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C     lblbl#        chain     pomfr1                             78
     C                   eval      pmwhse = lbwhse
     C                   eval      pmpo = lbpo
     C                   eval      pmseq = lbseq
     C                   eval      pmitem = lbitem
     C                   eval      pmexpd = expd
     C                   eval      pmmfgd = mfgd
     C                   eval      pmtrn# = lbtrn#
     C                   eval      pmlbl# = lblbl#
     C                   if        not *in78
     C                   update    pmrec
     C                   else
     C                   write     pmrec
     C                   endif
     *
     *      Write record to item exception file for date override.
     *
      * add additional exception if date decipher error
     c                   if        ddcode = *on
     C                   eval      exerid = 'DD-CODE'
     C                   eval      exwhse = lbwhse
     C                   eval      exwhdp = lbwhdp
     C                   eval      exstyp = lbstyp
     C                   eval      exitem = lbitem
     C                   eval      dspo = lbpo
     C                   eval      dslbl = lblbl#
     C                   eval      dsexpd = $dto
     C                   eval      exfdis = dsfdis
     C                   eval      extdis = dstdis
     C                   eval      exgdte = lbsdte
     C                   eval      exgtim = lbstim
     C                   eval      exqty = 0
     C                   eval      extask = 'RCV'
     C                   eval      exgby = #user
     C                   eval      exesta = '1 '
     C                   write     exrec
     C                   eval      ddcode = *off
     c                   endif
     C                   if        oaovr = *on  or
     C                             obovr = *on  or
     C                             ocovr = *on  or
     C                             odovr = *on  or
     C                             oeovr = *on  or
     C                             ofovr = *on
     C                   eval      exwhse = lbwhse
     C                   eval      exwhdp = lbwhdp
     C                   eval      exstyp = lbstyp
     C                   eval      exitem = lbitem
     C                   eval      dspo = lbpo
     C                   eval      dslbl = lblbl#
     C                   eval      dsexpd = $dto
     C                   eval      exfdis = dsfdis
     C                   eval      extdis = dstdis
     C                   eval      exgdte = lbsdte
     C                   eval      exgtim = lbstim
     C                   eval      exqty = 0
     C                   eval      extask = 'RCV'
     C                   eval      exgby = #user
     C                   select
     C                   when      oaovr = *on
     C                   eval      exerid = 'OA-DOVR'
     C                   when      obovr = *on
     C                   eval      exerid = 'OB-DOVR'
     C                   when      ocovr = *on
     C                   eval      exerid = 'OC-DOVR'
     C                   when      odovr = *on
     C                   eval      exerid = 'OD-DOVR'
     C                   when      oeovr = *on
     C                   eval      exerid = 'OE-DOVR'
     C                   when      ofovr = *on
     C                   eval      exerid = 'OF-DOVR'
     C                   other
     C                   eval      exerid = 'EXPDOVR'
     C                   endsl
     C                   eval      exesta = '1 '
     C                   write     exrec
     C                   eval      oaovr = *off
     C                   eval      obovr = *off
     C                   eval      ocovr = *off
     C                   eval      odovr = *off
     C                   eval      oeovr = *off
     C                   eval      ofovr = *off
     C                   endif
     *
     C                   endif
     C                   enddo
     C                   endif
     C                   endif
     *
     C                   exsr      zzuhdr
     c                   if        rcvpocomplete = *on
     c                   exsr      zzrcvpoclose
     c                   endif
     *
     C     endpdm        endsr
     *----------------------------------------------------------------
     *
     *  ZZPNON   Receive Non-FS-WMS item.
     *
     C     zzpnon        begsr
     *
     C                   call      'RC161'
     C                   parm      '*RECEIVE'    $rcmd
     C                   parm                    $rprg
     C                   parm      '*INTER  '    $rtype
     C                   parm                    $pwhse
     C                   parm                    woitm#
     C                   parm                    w3qt01
     C                   parm                    w3qt02
     C                   parm      0             w3qt03
     C                   parm      wopo          $rpo
     C                   parm                    $rven            11 0
     C                   parm                    $rvnam           40
     C                   parm                    w2vitm
     C                   parm      0             $rord
     C                   parm      *blanks       $rrcod
     C                   parm      *blanks       $rrmem
     C                   parm      expd          $rexpd
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm      *blanks       $rslot
     C                   parm      woline        $rseq
     C                   parm                    $rrpck
     C                   parm                    $rplbl
     C                   parm                    w8twgt            9 2
     C                   parm                    $rrq1
     C                   parm                    $rrq2
     C                   parm                    $rrq3
     C                   parm                    $rrpal
     C                   parm                    $rrtn
     C                   parm                    $rmsg
     *
     C                   if        $rrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   goto      endpnn
     C                   eval      #msgk = $rmsg
     C                   exsr      zmqmsg
     C                   endif
     *
     C     endpnn        endsr
     *----------------------------------------------------------------
     *
     *  ZZmfrdates  Set manufactures dates
     *
     C     zzmfrdates    begsr
     c                   select
     c                   when      $lmfrdat > 0 and $ldecvalue > ' '
     *
     *  Calculate Mfg Exp    date.(Mfg date + Mfg Shelf life days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      $lmfrdat      $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        mfgdte

     *  Create mfg expiration date mfgdate + mfg shelf life days

     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      mfgdte        $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $immday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     mexpd         parm      0             $cddateout
     C                   parm      0             $cdtimeout

     *
     *  Calculate Mfg date if mfg exp date is entered
     *
     c                   when      $lexpdat > 0 and $ldecvalue > ' '

     *
     *  Calculate Mfg date.(Mfg exp date - Mfg Shelf life days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      $lexpdat      $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        mexpd
     C                   eval      wkmday = $immday
     *  Use By date -1 to be used as mfg shelf life days
     C                   if        client = yhata
     C                   if        $immday = 0
     C                             and $imoday > 0
     C                   eval      wkmday = $imoday - 1
     C                   endif
     C                   endif

     *  Create mfg date - date mfg exp date - mfg shelf life days

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      mexpd         $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      wkmday        $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     mfgdte        parm      0             $cddateout
     C                   parm      0             $cdtimeout

     c                   if        wkmday = 0
     c                   eval      mfgdte = 0
     c                   endif

     c                   when      $pmfgdt > 0 and $itflgd = 'Y'
     *
     *  Calculate Mfg Exp    date.(Mfg date + Mfg Shelf life days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w8dte         $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        mfgdte

     *  Create mfg expiration date mfgdate + mfg shelf life days

     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      mfgdte        $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $immday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     mexpd         parm      0             $cddateout
     C                   parm      0             $cdtimeout

     c                   when      w8exdt > 0

     *
     *  Calculate Mfg date.(Mfg exp date - Mfg Shelf life days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w8exdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        mexpd
     C                   eval      wkmday = $immday
     *  Use By date -1 to be used as mfg shelf life days
     C                   if        client = yhata
     C                   if        $immday = 0
     C                             and $imoday > 0
     C                   eval      wkmday = $imoday - 1
     C                   endif
     C                   endif

     *  Create mfg date - date mfg exp date - mfg shelf life days

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      mexpd         $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      wkmday        $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     mfgdte        parm      0             $cddateout
     C                   parm      0             $cdtimeout

     c                   if        wkmday = 0
     c                   eval      mfgdte = 0
     c                   endif

     c                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZRCVPOCHECK check for started RCVPO Transaction
     *
     C     zzrcvpocheck  begsr
     *
     *  See if RCVPO transaction is status 2 - start new if needed
     *
     C                   call      @crtrcv
     C                   parm      '*PO'         $lcmdr           10
     C                   parm      '*CHECK '     $lsubcmd         10
     C                   parm      pdwhse        @lwhse            3 0
     C                   parm      0             $lpcs             5 0
     C                   parm      0             $lpallets         5 0
     C                   parm                    $lsavetrn         7 0
     C                   parm                    w1po
     C                   parm      itstyp        $litstyp          1
     C                   parm      itwhdp        $litwhdp          5
     C                   parm                    $lrtnr           10
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZRCVPO  Create receiver transaction.
     *
     C     zzrcvpo       begsr
     *
     *     clear the return field used in po236
     *
     c                   eval      $lrtn = ' '
     C                   call      @crtrcv
     C                   parm      '*PO'         $lcmdr           10
     C                   parm      '*CREATE'     $lsubcmd         10
     C                   parm      pdwhse        @lwhse            3 0
     C                   parm      0             $lpcs             5 0
     C                   parm      0             $lpallets         5 0
     C                   parm                    $lsavetrn         7 0
     C                   parm                    w1po
     C                   parm      itstyp        $litstyp          1
     C                   parm      itwhdp        $litwhdp          5
     C                   parm                    $lrtnr           10
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZRCVPOCLOSE  Close RCVPO transaction.
     *
     C     zzrcvpoclose  begsr
     c                   if        rcvpocomplete

     c                   select
     c                   when      $lrq1 > 0
     c                   eval      poppcs = $lrq1
     c                   when      $lrq2 > 0
     c                   eval      poppcs = $lrq2
     c                   when      $lrq3 > 0
     c                   eval      poppcs = $lrq3
     c                   endsl
     C                   call      @crtrcv
     C                   parm      '*PO'         $lcmdr           10
     C                   parm      '*COMPLETE'   $lsubcmd         10
     C                   parm      pdwhse        @lwhse            3 0
     C                   parm      poppcs        $lpcs             5 0
     C                   parm      $lrpal        $lpallets         5 0
     C                   parm                    $lsavetrn         7 0
     C                   parm                    w1po
     C                   parm      itstyp        $litstyp          1
     C                   parm      itwhdp        $litwhdp          5
     C                   parm                    $lrtnr           10

     c                   else

     C                   call      @crtrcv
     C                   parm      '*PO'         $lcmdr           10
     C                   parm      '*CLOSE'      $lsubcmd         10
     C                   parm      pdwhse        @lwhse            3 0
     C                   parm      0             $lpcs             5 0
     C                   parm      0             $lpallets         5 0
     C                   parm                    $lsavetrn         7 0
     C                   parm                    w1po
     C                   parm      itstyp        $litstyp          1
     C                   parm      itwhdp        $litwhdp          5
     C                   parm                    $lrtnr           10
     c                   endif
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZRUPC   Verify Retail UPC on file for item.
     *
     C     zzrupc        begsr
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhs4 = pdwhse
     C                   eval      $lpo4 = pdpo
     C                   eval      $lseq4 = pdseq
     C                   eval      $litm4 = pditem
     *
     C                   call      'PO245'
     C                   parm                    $lparm
     *
     C                   select
     C                   when      $lrtn = '*EXIT   '  or
     C                             $lrtn = '*CANCEL '
     C                   eval      error = *on
     *
     C                   endsl
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZTRCV   Calculate total qty received for PO
     *
     C     zztrcv        begsr
     *
     C                   eval      wolord = 0
     C                   eval      wolrcv = 0
     C                   eval      wopord = 0
     C                   eval      woprcv = 0
     *
     *  Loop through all detail lines for PO
     *
     C     fileky        setll     record
     C                   dow       forevr = forevr
     C     fileky        reade     record                                 79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *    Increment Lines Ordered/Received(Marked)
     *
     C                   add       1             wolord
     C     detlky        chain     podtl3                             78
     C                   if        not *in78
     C                   add       1             wolrcv
     C                   endif
     *
     *    Increment Pieces Ordered/Received
     *
     C                   add       pdqor1        wopord
     C                   add       pdqor2        wopord
     C                   add       pdqor3        wopord
     C                   add       pdqrc1        woprcv
     C                   add       pdqrc2        woprcv
     C                   add       pdqrc3        woprcv
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUHDR   Update HDR record.
     *
     C     zzuhdr        begsr
     C                   eval      error = *off
     C                   eval      part = *off
     C                   eval      full = *on
     C                   eval      recv = *off
     C     prtdky        setll     podtl                              79
     C                   move      *in79         eof
     C                   dow       eof = *off
     C     prtdky        reade     podtl                                  79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   if        pdqrc1 < pdqor1
     C                   eval      part = *on
     C                   eval      full = *off
     C                   endif
     *
     C                   if        pdqrc2 < pdqor2
     C                   eval      part = *on
     C                   eval      full = *off
     C                   endif
     *
     C                   if        pdqrc3 < pdqor3
     C                   eval      part = *on
     C                   eval      full = *off
     C                   endif
     *
     C                   if        pdqrc1 > 0
     C                   eval      recv = *on
     C                   endif
     *
     C                   if        pdqrc2 > 0
     C                   eval      recv = *on
     C                   endif
     *
     C                   if        pdqrc3 > 0
     C                   eval      recv = *on
     C                   endif
     C                   endif
     *
     C                   enddo
     *
     C                   if        recv = *off
     C                   eval      full = *off
     C                   eval      part = *off
     C                   endif
     *
     C     fileky        chain     pohdr                              79
     C                   if        not *in79
     C                   if        part = *on
     C                   eval      phstat = *on
     C                   endif
     C                   if        full = *on
     C                   eval      phstat = '2'
     C                   endif
     C                   if        part = *off  and
     C                             full = *off
     C                   eval      phstat = *off
     C                   endif
     C                   update    phrec
     C                   endif
     *
     C     endhdr        endsr
     *
     *---------------------------------------------------------------
     *
     *  ZZURCV   Update PORCV file.
     *
     C     zzurcv        begsr
     *
     *   Add record to PORCV.
     *
     C                   eval      porwhs = lbwhse
     C                   eval      porpo = lbpo
     C                   eval      porseq = lbseq
     C                   eval      pordte = today
     C                   time                    portim
     C                   eval      porusr = #user
     C                   eval      pordev = #job
     C                   eval      poremp = $emp#
     C                   eval      portrn = lbtrn#
     C                   eval      porlic = *blanks
     C                   eval      porlbl = lblbl#
     C                   eval      poract = 'R'
     C                   eval      poredt = 0
     C                   eval      poreti = 0
     C                   write     porrec                               49
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUOM    Get Unit Of Measure Normal, Breakdown1, Breakdown2.
     *
     *    *IN95=Protect & non-display breakdown1 unit of measure
     *
     C     zzuom         begsr
     *
     *   Determine which UOM's are needed.
     *
     C                   if        itflg1 = 'Y'  or
     C                             ssbflg = *on
     C                   eval      *in95 = *off
     C                   else
     C                   eval      *in95 = *on
     C                   endif
     *
     *   Get Unit of Measures.
     *
     *
     *
     C                   if        ittype = 'S'
     C     itum2         chain     unmesr                             75
     C                   else
     C     itum1         chain     unmesr                             75
     C                   endif
     C                   if        not *in75
     C                   movel     umcode        woum1
     C                   else
     C                   eval      woum1 = *blanks
     C                   endif
     *
     C                   eval      woum2 = *blanks
     C                   if        itflg1 = 'Y'  or
     C                             ssbflg = *on  or
     C                             ittype = 'S'  and
     C                             itumq3 > 0
     C                   if        ittype = 'S'
     C     itum3         chain     unmesr                             75
     C                   else
     C     itum2         chain     unmesr                             75
     C                   endif
     C                   if        not *in75
     C                   movel     umcode        woum2
     C                   else
     C                   eval      woum2 = *blanks
     C                   endif
     C                   endif
     *
     C     enduom        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     C                   exsr      zzlcns
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
     C                   if        noupc = *on
     C                   eval      error = *on
     C                   if        woupc = *blanks
     C                   exsr      zm032
     C                   else
     C                   exsr      zm029
     C                   endif
     C                   exsr      scr05i
     C                   else
     C                   exsr      scr03i
     C                   endif
     C     endup2        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update for screen 3.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     c                   if        *in85 = *off
     c                   eval      w9lotc = ' '
     c                   endif
     *
     *    If lot tracking item, display screen to capture lot code.
     *
     C                   if        lottrk = '*YES'
     C                   exsr      scr09i
     C                   goto      endup3
     C                   endif
     *
     *  See if we need to get date or weight.
     *
     C                   if        s8flag = *on
     C                   exsr      scr08i
     C                   goto      endup3
     C                   endif
     *
     C                   eval      vrfycw = *off
     C                   exsr      zzzcw
     *
     *
     C                   eval      w3twgt = 0
     C                   eval      w8mfdt = 0
     C                   eval      mfgd = 0
     C                   eval      w8exdt = 0
     C                   eval      expd = 0
     *
     *   What is done next depends on receiving method being used.
     *
     C                   select
     *
     *     Non-FS-WMS item receiving.
     *
     C                   when      iaflag = *on
     C                   exsr      zzpnon
     C     error         cabeq     *on           endup3
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     *
     *     Manual putaway
     *
     C                   when      opmput = 'Y'
     C                   exsr      zzpman
     C     error         cabeq     *on           endup3
     C     $lrtn         cabeq     '*EXIT'       endup3
     C     $lrtn         cabeq     '*CANCEL'     endup3
     C                   eval      refrsh = *on
     c                   eval      nxtscr = 'EOJ'
     C*                  exsr      scr02i
     *
     *     Or Directed Putaway
     *
     C                   other
     C                   exsr      zzpdir
     C     error         cabeq     *on           endup3
     C                   if        lflag = *off
     C                   exsr      scr04i
     C                   else
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   endif
     *
     C                   endsl
     *
     C     endup3        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD4   Update for screen 4.
     *
     C     zzupd4        begsr
     C                   exsr      zzuhdr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     *
     C     endup4        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD5   Update for screen 5.
     *
     C     zzupd5        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     C                   if        woupc = *blanks
     C                   exsr      scr03i
     C                   else
     C                   exsr      scr06i
     C                   endif
     *
     C     endup5        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD6   Update for screen 6.
     *
     C     zzupd6        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
     C                   eval      upwhse = $pwhse
     C                   eval      upitem = woitm#
     C                   eval      upupc = kyupc
     C                   eval      upven = phven
     C                   eval      upvnam = phvnam
     C                   eval      upvitm = pdvitm
     C                   eval      upbran = *blanks
      * load new upc fields
      /free
        upuom = itum1;
        uputyp = 'N';
        Select;
          when ntype = 'UPC-12';
            upctyp = '1';
          when ntype = 'EAN-13';
            upctyp = '2';
          when ntype = 'GTIN';
            upctyp = '3';
          when ntype = 'SCC-14';
            upctyp = '4';
          when ntype = 'SSCC-18';
            upctyp = '5';
        endsl;
      /end-free
     *
     *   Add record
     *
     C                   write     uprec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endup6
     C                   endif
     C                   exsr      scr03i
     *
     C     endup6        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD7   Update for screen 7.
     *
     C     zzupd7        begsr
     C                   eval      error = *off
     C                   eval      liwhse = $pwhse
     C                   eval      lilcns = w7lcns
     C                   eval      litrn# = lbtrn#
     *
     *   Add record
     *
     C                   write     lirec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   endif
     C                   if        w7pctr <> w7pal
     C                   exsr      scr07i
     C                   else
     C                   exsr      zzuhdr
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   endif
     *
     C     endup7        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD8   Update for screen 8.
     *
     C     zzupd8        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     c                   if        $ldecvalue = ' '
     c                   exsr      zzmfrdates
     c                   endif
     *
     C                   exsr      zzzcw
     *
     C                   if        immflg = 'Y'
     *
     *  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w8mfdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        expd
     C                   move      $cvd8o        womfdt

     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      expd          $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      immday        $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C                   parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      $cddateout    $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      imuday        $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     expd          parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      expd          $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        w8exdt

     C                   endif
     *
     *   What is done next depends on receiving method being used.
     *
     C                   select
     *
     *     Non-FS-WMS item receiving.
     *
     C                   when      iaflag = *on
     C                   exsr      zzpnon
     C     error         cabeq     *on           endup8
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     *
     *     Manual putaway
     *
     C                   when      opmput = 'Y'
     C                   exsr      zzpman
     C     error         cabeq     *on           endup8
     C     $lrtn         cabeq     '*EXIT'       endup8
     C     $lrtn         cabeq     '*CANCEL'     endup8
     C                   eval      refrsh = *on
     c                   eval      nxtscr = 'EOJ'
     *
     *     Or Directed Putaway
     *
     C                   other
     C                   exsr      zzpdir
     C     error         cabeq     *on           endup8
     C                   if        lflag = *off
     c                   eval      nxtscr = 'EOJ'
     C*                  exsr      scr04i
     C                   else
     C                   eval      refrsh = *on
     c                   eval      nxtscr = 'EOJ'
     C*                  exsr      scr02i
     C                   endif
     *
     C                   endsl
     *
     C     endup8        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD9   Update for screen 9.
     *
     C     zzupd9        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
     *  See if we need to get date or weight.
     *
     C                   if        s8flag = *on
     C                   exsr      scr08i
     C                   goto      endup9
     C                   endif
     *
     C                   eval      vrfycw = *off
     C                   exsr      zzzcw
     *
     C                   eval      w3twgt = 0
     C                   eval      w8mfdt = 0
     C                   eval      mfgd = 0
     C                   eval      w8exdt = 0
     C                   eval      expd = 0
     *
     *   What is done next depends on receiving method being used.
     *
     C                   select
     *
     *     Non-FS-WMS item receiving.
     *
     C                   when      iaflag = *on
     C                   exsr      zzpnon
     C     error         cabeq     *on           endup9
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     *
     *     Manual putaway
     *
     C                   when      opmput = 'Y'
     C                   exsr      zzpman
     C     error         cabeq     *on           endup9
     C     $lrtn         cabeq     '*EXIT'       endup9
     C     $lrtn         cabeq     '*CANCEL'     endup9
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     *
     *     Or Directed Putaway
     *
     C                   other
     C                   exsr      zzpdir
     C     error         cabeq     *on           endup9
     C                   if        lflag = *off
     C                   exsr      scr04i
     C                   else
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   endif
     *
     C                   endsl
     *
     C     endup9        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD10  Update for screen 10.
     *
     C     zzupd10       begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
     C                   eval      upwhse = $pwhse
     C                   eval      upitem = woitm#
     C                   eval      upupc = kyupc
     C                   eval      upven = phven
     C                   eval      upvnam = phvnam
     C                   eval      upvitm = pdvitm
     C                   eval      upbran = *blanks
      * load new upc fields
      /free
        upuom = w10buom;
        uputyp = w10btyp;
        Select;
          when btype = 'UPC-12';
            upctyp = '1';
          when btype = 'EAN-13';
            upctyp = '2';
          when btype = 'GTIN';
            upctyp = '3';
          when btype = 'SCC-14';
            upctyp = '4';
          when btype = 'SSCC-18';
            upctyp = '5';
        endsl;
      /end-free
     *
     *   Add record
     *
     C                   write     uprec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endup10
     C                   endif

      * this needs to be based on if we are done with breakdowns
     C                   if        $ifrcvmth = '3' and ittype = ' '
     c                   exsr      scr10i
     c                   endif
     *
     C     endup10       endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD11  Update for screen 11.
     *
     C     zzupd11       begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     c                   if        w12lcns = ' '
     c                   exsr      scr12i
     c                   else
     c                   exsr      zzuci
     c                   endif
     *
     C     endup11       endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD12  Update for screen 12.
     *
     C     zzupd12       begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     c                   eval      GoodLcns = *on

     c                   exsr      zzupd11
     *
     C     endup12       endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD13  Update for screen 13.
     *
     C     zzupd13       begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on

     *
     C     endup13       endsr
     *----------------------------------------------------------------
     *
     *  ZZUPDCnl Delete scanned records
     *
     C     zzupdCnl      begsr
     C                   eval      error = *off
     *   Remove any LICUCI records
      /free
        if moretoscan = *on;
          if *inka;
            // Delete LICINFO Records
            exsr zzlicinfocan;

            exsr clr$uciinfo;

            // warehouse
            $uiWhse = $pwhse;

            // License
            if $pxd = ' ';
              $uiLcns = w13lcns;
            else;
              $uiLcns = templcns;
            endif;

            $dricommand = '*UCIINFO';
            $drisubcmd  = '%CANCEL';
            $drisys2upd = 'D';
            chk4err = *on;
            zmflag  = *off;
            exsr zzzdricop;
            if error = *on;
            endif;
            moretoscan = *off;
            $puci = ' ';
            w11uci = ' ';
            w13lcns = ' ';
            templcns = ' ';
            ovrrid = *off;
            $pexpdt = 0;
            $pwgt = 0;
            $pmfgdt = 0;
            $plot = ' ';
            saveqty = 0;
            svdwgt = 0;
            savewgt= 0;
          endif;
        endif;

      /end-free
     *
     *   Move key values to parameters
     *
     C     endupCnl      endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZXOPT   Get use extended description option
     *
     C     zzxopt        begsr
     *
     *   Get extended description option.
     C                   eval      uxflag = *off
     C                   eval      ocode = '*ITEMMNT'
     C                   eval      wkwhse = $pwhse
     *
     C     opkey         chain     options                            79
     C                   if        not *in79
     c                   eval      opdat1 = opdata
     C                   if        opxdsc = 'Y'
     C                   eval      uxflag = *on
     C                   endif
     *    We will set the default for lbs/kgs from the option file
      /free
        // save the field for later use, the opdata field gets changed
        svopwum = opwum;
        select;
          when opwum = 'KGS'
           or opwum = 'kgs'
           or opwum = 'Kgs';
            KiloLbs = 'K';
            dspuom  = opwum;
          other;
            KiloLbs = 'P';
            dspuom  = 'Lbs';
        endsl;
      /end-free
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZZCW    Calculate catch weight
     *
     *
     *  Action Table
     *
     *   VRFYCW  SVCWEN  SVCWTP  W8AVG  POCTYP  Action
     *   ------  ------  ------  -----  ------  --------------------
     *     Y       1       1       N       -    CW = Calc1
     *
     *     Y       1       1       Y       -    CW = Calc2
     *
     *     Y       1       2       -       -    CW = Calc1
     *
     *     Y       1       3       -       -    CW = Calc2
     *
     *     Y       2       1       N       -    CW = Calc1
     *                                          Write POCTYP = 'T'
     *
     *     Y       2       1       Y       -    CW = Calc3
     *                                          Write POCTYP = 'A'
     *
     *     Y       2       2       -       -    CW = Calc1
     *                                          Write POCTYP = 'T'
     *
     *     Y       2       3       -       -    Not allowed
     *
     *     N       1       -       -       -    Not allowed
     *
     *     N       2       -       -       T    None
     *
     *     N       2       -       -       A    CW = Calc3
     *
     *     N       3       -       -       -    None
     *
     *  Keys:
     *
     *   SVCWEN - 1=Every time, 2=First time only, 3=Never
     *   SVCWTP - 1=Choice, 2=Total, 3=Average
     *   Calc1  - Entered weight
     *   Calc2  - Qty * Entered weight
     *   Calc3  - Qty * Item weight
     *
     *----------------------------------------------------------------
     C     zzzcw         begsr
     *
     C                   eval      w8twgt = 0
     C                   eval      avgwt1 = 0
     C                   eval      avgwt2 = 0
     C                   eval      avgwt3 = 0
     C                   eval      cwcalc = 0
     C                   eval      wrttyp = ' '
     *
     *   Get POCTYPE record.
     *
     C                   if        svcwen = '2'
     C     keypoc        chain     poctype                            79
     C                   if        *in79
     C                   eval      poctyp = 'T'
     C                   endif
     C                   endif
     *
     *   Determine what needs to be done based on table.
     *
     C                   select
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '1'  and
     C                             svcwtp = '1'  and
     C                             w8avg = 'N'
     C                   eval      cwcalc = 1
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '1'  and
     C                             svcwtp = '1'  and
     C                             w8avg = 'Y'
     C                   eval      cwcalc = 2
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '1'  and
     C                             svcwtp = '2'
     C                   eval      cwcalc = 1
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '1'  and
     C                             svcwtp = '3'
     C                   eval      cwcalc = 2
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '2'  and
     C                             svcwtp = '1'  and
     C                             w8avg = 'N'
     C                   eval      cwcalc = 1
     C                   eval      wrttyp = 'T'
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '2'  and
     C                             svcwtp = '1'  and
     C                             w8avg = 'Y'
     C                   eval      cwcalc = 3
     C                   eval      wrttyp = 'A'
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '2'  and
     C                             svcwtp = '2'
     C                   eval      cwcalc = 1
     C                   eval      wrttyp = 'T'
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '2'  and
     C                             svcwtp = '3'
     *
     C                   when      vrfycw = *off  and
     C                             svcwen = '1'
     *
     C                   when      vrfycw = *off  and
     C                             svcwen = '2'  and
     C                             poctyp = 'T'
     *
     C                   when      vrfycw = *off  and
     C                             svcwen = '2'  and
     C                             poctyp = 'A'
     C                   eval      cwcalc = 3
     *
     C                   when      vrfycw = *off  and
     C                             svcwen = '3'
     *
     C                   endsl
     *
     *   Calculate catch weight.
     *
     C                   select
     *
     *     Straight total.
     *
     C                   when      cwcalc = 1
     C                   eval      w8twgt = savewgt
     C     savewgt       div       w3qt01        avgwt1
     *
     *     Entered quantity * Entered weight.
     *
     C                   when      cwcalc = 2
     C     savewgt       mult      w3qt01        w8twgt
     C                   z-add     savewgt       avgwt1
     *
     *     Entered quantity * Item weight.
     *
     C                   when      cwcalc = 3
     *
     *       Normal qty for non-SSB items.
     *
     C                   if        w3qt01 > 0  and
     C                             #otype <> 'S'
     C     #oswgt        mult      w3qt01        w8twgt
     C                   eval      avgwt1 = #oswgt
     C                   endif
     *
     *       Normal qty for SSB items.
     *
     C                   if        w3qt01 > 0  and
     C                             #otype = 'S'
     C     #oswt2        mult      w3qt01        w8twgt
     C                   eval      avgwt1 = #oswt2
     C                   endif
     *
     *       Brk1 qty for non-SSB items.
     *
     C                   if        w3qt02 > 0  and
     C                             #otype <> 'S'
     C     #oswt2        mult      w3qt02        tmpwgt
     C                   add       tmpwgt        w8twgt
     C                   eval      avgwt2 = #oswt2
     C                   endif
     *
     *       Brk1 qty for SSB items.
     *
     C                   if        w3qt02 > 0  and
     C                             #otype = 'S'
     C     #oswt3        mult      w3qt02        tmpwgt
     C                   add       tmpwgt        w8twgt
     C                   eval      avgwt2 = #oswt3
     C                   endif
     *
     C                   endsl
     *
     *   Write POCTYPE record.
     *
     C                   if        wrttyp <> ' '
     C     keypoc        chain     poctype                            79
     C                   if        not *in79
     C                   eval      poctyp = wrttyp
     C                   update    pocrec
     C                   else
     C                   eval      pocwhs = $pwhse
     C                   eval      pocpo = wopo
     C                   eval      pocseq = woline
     C                   eval      poctyp = wrttyp
     C                   write     pocrec                               78
     C                   endif
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$license  Clear $license data structure fields
     *----------------------------------------------------------------

     C     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C                   eval      $liemp# = $emp#
     C                   eval      $liuser = #user
     C                   eval      $lipgm  = #prog
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobn
     C                   eval      $liTowhse = $pwhse
     C                   eval      $liTowhseu = *on
     C                   endsr
     *----------------------------------------------------------------
     *  clr$licinfo  Clear $licinfo data structure fields
     *----------------------------------------------------------------

     C     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
     C                   clear                   $licinfo2
     C                   eval      $lnver# = savever#

     C                   eval      $lnuser = #user
     C                   eval      $lnemp# = $emp#
     C                   eval      $lnpgm  = #prog
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobn

     C                   endsr
     *----------------------------------------------------------------
     *  clr$uciinfo  Clear $uciinfo data structure fields
     *----------------------------------------------------------------

     C     clr$uciinfo   begsr
     C                   eval      savever# = $uiver#
     C                   clear                   $uciinfo
     C                   clear                   $uciinfo2
     C                   eval      $uiver# = savever#
     C                   eval      $uiaddemp = $emp#
     C                   eval      $uiaddusr = #user
     C                   eval      $uiaddpgm  = #prog
     C                   eval      $uiaddjob  = #job
     C                   eval      $uiaddnbr = #jobn
     C                   endsr
     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
     C                   eval      $dridata2 = $licinfo2
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $dridata = $license
     C                   eval      $dridata2 = $license2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $dridata = $uciinfo
     C                   eval      $dridata2 = $uciinfo2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*LICENSE'
     C                             or $dricommand = '*LICINFO'
     C                             or $dricommand = '*UCIINFO'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      chk4err and %error
     C                   eval      error = *on

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
     C                   eval      $licinfo2 = $dridata2
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $license = $dridata
     C                   eval      $license2 = $dridata2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $uciinfo = $dridata
     C                   eval      $uciinfo2 = $dridata2
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Normal quantity
Breakdown 1 quantity
Number of pallets
Average
Catch weight
license number
No CW override
Super Po Not Allowed
**
Ttl
Avg
** Descsp
Ctd. normal
Romper 1 cantidad
Numero de paletas
Promedio
CW
numero de licencia
anular no peso
Super Po Not Allowed
**
Ttl
Prm
