      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RC180   RF Receive Item without a PO
     *  16 May 2014
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    8 X 20 screens for hand held scanners
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650 A*    05/16/14  RBD  6.50
     *      - Created for City Line, Quote #1207, cloned from PO200.
     *        This pgm allows a user to receive an item just as in normal
     *        PO receiving, but without having a PO.
     *      - Written as standard, with no custom code, so all clients
     *        may use it.
     *      - Some pohdr and screen format fields are still referenced
     *        in this pgm in calls to other pgms, etc, but are no longer
     *        defined because I removed pohdr and some screen formats.
     *        Remember, this pgm was cloned from PO200.  So I've redefined
     *        these fields by prefixing them with $$.
720aA*    08/13/18  LMC  7.20a
     *      - Fixed - when and invalid date was entered no error
     *        message was displayed.                                  mal
720bA*    12/13/18  LMC  7.20b
     *      - Enh - Add ability to scan UCI.
730aA*    07/18/19  HR   7.30a
     *      - Fixed - Allow breakdown qty keyed without Normal UOM
     *        Fix Breakdown UOM check to use correct fields           mal
730bA*    09/30/19  LMC  7.30b
     *      - Fixed - Devide by zero on straight total.
730cA*    11/21/19  LMC  7.30c
     *      - Fixed - upc check
730dA*    11/21/19  LMC  7.30d
     *      - Item number was not being editted
730eA*    11/22/19  LMC  7.30e
     *      - Provide an accruate message when upc is not found
740aA*    03/30/20  LMC  7.40a
     *      - Enh: Edits for # of days out should not apply for
     *        Manufacturer dated items. Only if Expiration date
     *        is entered.
740b *    05/22/20  LMC  7.40b
     *      - Enh: Send Vendor to all calls of CVTBAR so that the
     *        new decipher barcode process works.
740c *    08/27/20  LMC  7.40c
     *      - Enh: Added lot number for entry to screen3.
740d *    12/03/20  LMC  7.40d
     *      - Enh: CVTBAR dec data error, due to mod 740b.
740e *    12/10/20  LMC  7.40e
     *      - Enh: Extract data from GS1 and load up screen fields
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
DRYaA*    09/23/19  LMC  DRYa
     *      - Revised to Send $lflag = *off to po236 to generate item
     *        license labels.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Sunrise Food Service
SUNaA*    09/01/20  LMC  SUNa
     *      - Require lot number on lot items.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Natalie's Juice Company
NOJaA*    09/01/20  LMC  NOJa
     *      - Require lot number on lot items.
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
720bdF*rc180fm   cf   e             workstn
740cDF*rc18001   cf   e             workstn
740cMFrc18002   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Funmesr    if   e           k disk
     Fpiritem   if   e           k disk
     FLabel2    if   e           k disk
     Foptions   if   e           k disk
     Foptiond   if   e           k disk
     Fitemmsc   if   e           k disk
     Fitmexcp   o    e           k disk
720bAFupc       if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
730aDD*desc            s             50    dim(7) ctdata perrcd(1)
730aMD desc            s             50    dim(8) ctdata perrcd(1)
     D cwt             s              3    dim(2) ctdata perrcd(1)
730dA*----------------------------------------------------------------
730dA*  DRI parameters
730dA*----------------------------------------------------------------

730dA /COPY *libl/qcopysrc,C#DRIPARMS

730dA*----------------------------------------------------------------
730dA*  Data Formats
730dA*----------------------------------------------------------------

730dA /COPY *libl/qcopysrc,C#ITEM
730dAD savever#        s                   like($itver#)

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
     *  Name constants
     *
     D valid           c                   const('0123456789 ABCDEFGHI-
     D                                     JKLMNOPQRSTUVWXYZabc-
     D                                     defghijklmnopqrstuvw-
     D                                     xyz')
720bA*----------------------------------------------------------------
720bA*  Convert Barcode Parms
720bA*----------------------------------------------------------------

720bA /COPY *libl/qcopysrc,C#CVTPARMS
720bA /COPY *libl/qcopysrc,C#BARCODE
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @getsi          c                   const('GETSLOTITM')
     D @fmtit          c                   const('FRMTIT2')
     D @crtrcv         c                   const('CRTRCVTRN')
     *----------------------------------------------------------------
     *  Called program parameters
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

DRYaA /copy qcopysrc,id#dairyla
SUNaA /copy qcopysrc,id#sun
NOJaA /copy qcopysrc,id#noj
     *----------------------------------------------------------------
     *  Variables
     *
     D $$phven         s             11  0
     D $$phvnam        s             40
     D $$wohome        s             12
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
730dAD chk4err         s               n
     D ckexdt          s              8  0
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D cwcalc          s              1  0
     D cwovr           s              1
     D date1           s              8  0
     D date16          s              6  0
     D date2           s              8  0
     D date2o          s              6  0
     D date26          s              6  0
     D ddcode          s              1
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
     D hvskp           s              1
     D iaflag          s              1
     D iatest          s              1
     D ihrng           s              9  2
     D ihvar           s              9  2
     D ilrng           s              9  2
     D ilvar           s              9  2
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
     D kycode          s                   like(opdcod)
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
     D recv            s              1
     D redspl          s              1
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D ssbflg          s              1
     D stop            s              1
     D svcwen          s              1
     D svcwfr          s              1
     D svcwtp          s              1
     D svdwgt          s              7  2
     D svexck          s              1
     D svexdt          s              6  0
     D svmfdt          s              6  0
     D svrupc          s              1
     D s6upc           s             20
     D s3flag          s              1
     D tmpwgt          s              9  2
     D today           s              8  0
     D todyj           s              5  0
     D upcctr          s              3  0
     D vrfycw          s              1
     D warn            s              1
     D wkmday          s              3  0
     D wkwhse          s                   like(w1whse)
     D w1whse          s              3  0
     D wobat           s              7  0
     D woexdt          s              8  0
     D wofifo          s              8  0
     D woindt          s              8  0
     D womfdt          s              8  0
     D work2           s              2
     D work4           s              4
     D wotcw           s              9  2
     D wtchk           s              1
     D w3exdt          s              6  0
     D w3mfdt          s              6  0
     D $parms1         s             48    dim(20)
720bAD workupc         s                   like(upupc)
730dAD zmflag          s               n
730dAD zmsflag         s               n
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr

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
     C                   exfmt     screen1                              50
     C                   endif
     C                   if        nxtscr = '02 '
     C                   exfmt     screen2                              50
     C                   endif
     C                   if        nxtscr = '03 '
     C                   exfmt     screen3                              50
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
     C                   eval      w1item = *blanks
720bAC                   eval      w1uci  = *blanks
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
     C     end03i        endsr
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
     C                   eval      refrsh = *off
     C                   exsr      scr02i
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
     C                   eval      refrsh = *off
     C                   exsr      scr02i
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
     C                   eval      $msgf  = #msgf
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
     C                   write     msgrec
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *----------------------------------------------------------------
730dA *    DRI0001  Local system caused error
730dA*----------------------------------------------------------------

730dAC     zm0001        begsr
730dAC                   if        %subst($drimessage:1:2) = 'H:'
730dAC                   move      'DRI0002'     #msgid
730dAC                   eval      $drimessage = %subst($drimessage:3)
730dAC                   else
730dAC                   move      'DRI0001'     #msgid
730dAC                   endif
730dAC                   eval      #msgtp = '*DIAG'
730dAC                   eval      #msgdt = $drimessage + $drireturn
730dAC                                    + $dricommand + $drisubcmd
730dAC                   exsr      zmpmsg
730dAC                   endsr
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
     *    PO20030  Item or Line must be entered.
     *
     C     zm030         begsr
     C                   eval      #msgid = 'PO20030'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
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
720aA*----------------------------------------------------------------
720aA*      PIR1007  Invalid date entered.
720aA*----------------------------------------------------------------

720aA /free
720aA  begsr zm1007;

720aA    #msgid = 'PIR1007';
720aA    #msgtp = '*DIAG  ';
720aA    #msgdt = errmsg;
720aA    exsr zmpmsg;

720aA  endsr;
720aA /end-free

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
     *
     C                   eval      error = *off
     C                   eval      errflg = *off
720bAC                   if        w1uci <> ' '
720bA * add the conversion of the uci barcode
720bAC                   eval      $cbcmd = '*ALL    '
720bAC                   eval      $cbbar = w1uci
720bAc                   clear                   $barcode
720bAc                   clear                   $barcode2
720bA*
720bAC                   call      'CVTBAR'
720bAC                   parm                    $cbcmd            8
720bAC                   parm                    $cbbar          100
720bAC                   parm                    $cbcod            3 0
720bAC                   parm                    $cbdec            1 0
720bAC                   parm                    $cbdsc           30
720bAC                   parm                    $cbpos            3 0
720bAC                   parm                    $cbtyp            1 0
720bAC                   parm                    $cbv1            11 3
720bAC                   parm                    $cbv2            50
720bAC                   parm                    $cbrtn            8
720bAC                   parm                    $cberm           60
740bDC*                  parm                    $cbven           10 0
740dDC*                  parm      $itven#       $cbven           10 0
740dMC                   parm                    $cbven           10 0
720bAC                   parm                    $cvtdata
720bAC                   parm                    $cvtdata2
720bAc                   if        $cbrtn = '*NOMORE'
740bAc                             or $cbrtn = '*OK'
720bAc                   eval      $barcode = $cvtdata
720bAc                   eval      $barcode2 = $cvtdata2
720bac                   else
720bAC                   eval      $cbcmd = '*UPC    '
720bAC                   eval      $cbbar = w1uci
720bAc                   clear                   $barcode
720bAc                   clear                   $barcode2
720bA*
720bAC                   call      'CVTBAR'
720bAC                   parm                    $cbcmd            8
720bAC                   parm                    $cbbar          100
720bAC                   parm                    $cbcod            3 0
720bAC                   parm                    $cbdec            1 0
720bAC                   parm                    $cbdsc           30
720bAC                   parm                    $cbpos            3 0
720bAC                   parm                    $cbtyp            1 0
720bAC                   parm                    $cbv1            11 3
720bAC                   parm                    $cbv2            50
720bAC                   parm                    $cbrtn            8
720bAC                   parm                    $cberm           60
740bDC*                  parm                    $cbven           10 0
740dDC*                  parm      $itven#       $cbven           10 0
740dMC                   parm                    $cbven           10 0
720bAC                   parm                    $cvtdata
720bAC                   parm                    $cvtdata2
720bAc                   if        $cbrtn = '*NOMORE'
740bAc                             or $cbrtn = '*OK'
720bAc                   endif
720bAc                   endif
720bA * Load UPC
720bAc                   if        $bcGtinSent
720bA /free
720bA   workupc = '      ' + $bcgtin;
720bA   chain (w1whse: workupc) upc;
720bA   if %found(upc);
720bA     w1item = upitem;
720bA   endif;
720bA /end-free
720bAc                   endif
730cDc*                  if        $cbrtn = '*OK'
730cMc                   if        $cbrtn <> '*INVALID'
730cA*
730cA*   Right adjust UPC code for file.
730cA*
730cAC                   eval      $cstr = *blanks
730cAC                   movel     $cbv2         $cstr
730cAC                   call      'ADJUST'
730cAC                   parm      '*RIGHT  '    $ccmd             8
730cAC                   parm                    $cstr            30
730cAC                   move      $cstr         workupc
720bA /free
730cD   //workupc = '      ' + $cbv2;
720bA   chain (w1whse: workupc) upc;
720bA   if %found(upc);
720bA     w1item = upitem;
720bA   endif;
720bA /end-free
720bAc                   endif
720bA
730eA /free
730eA   if w1uci <> ' ' and w1item = ' ';
730eA     error = *on;
730eA     errmsg = 'UPC not on file.';
730eA     *in28 = *on;
730eA     *in08 = *on;
730eA     exsr zm0105;
730eA     leavesr;
730eA   endif;
730eA /end-free
720bAc                   endif
720bAc                   eval      w1uci = ' '
     *
     *  Item # must be entered.
     *
     C                   if        w1item = *blanks
     C                   eval      error = *on
730dAc                   eval      errmsg = 'Item or UCI must be entered'
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
730dDC*                  exsr      zm030
730dMC                   exsr      zm0105
     C                   endif
     *
     *   Verify Item #.
     *
     C                   if        w1item <> *blanks
     *
     *  Call API for item.
     *
     C                   call      @apici
     C                   parm                    w1item
     C                   parm      6             worow             3 0
     C                   parm      7             wocol             3 0
     C                   parm                    @artn             8
     C                   if        @artn = '*REDSPLY'
     C                   endif
     *
730dA * add dri to get data from itemfld
730dA /free
730dA   exsr clr$item;

730dA   $itWhse = w1whse;
730dA   $ititem = w1item;

730dA   $dricommand = '*ITEM';
730dA   $drisubcmd  = '%GETALL';
730dA   $drisys2upd = 'D';
730dA   chk4err = *on;
730dA   zmflag  = *off;
730dA   exsr zzzdricop;
730dA   if error = *on;
730dA     errmsg = $drimessage;
730dA     exsr zm0105;
730dA   endif;
730dA /end-free
     C                   eval      woitm# = w1item
     *
     C                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     C                   eval      errflg = *off
     *
     *  Verify normal quantity.
     *
730aMC                   if        w2qt01 < 0  or
730aDC**                 if        w2qt01 < 1  or
     C                             w2qt01 > 99999
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       erfld
     C                   movel     '1'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
     *
     *  Verify breakdown 1 unit of measure quantity.
     *
730aMC                   if        w2qt02 < 0  or
730aDC**                 if        w2qt01 < 0  or
     C                             w2qt02 > 99999
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(2)       erfld
     C                   movel     '1'           erfrom
     C                   movel     '0'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
730aA*
730aA*  Verify at least 1 qty entered.
730aA*
730aaC                   if        w2qt01 = 0  and
730aAC                             w2qt02 = 0
730aAC                   eval      error = *on
730aAC                   eval      *in24 = *on
730aAC                   eval      *in04 = *on
730aAC                   eval      errmsg = *blanks
730aAC                   eval      errmsg = desc(8)
730aAC                   exsr      zm0110
730aAC                   endif
     *
     *  Verify # of Pallets.
     *
     C                   if        opmput = 'Y'  and
     C                             w2plt <= 0
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(3)       erfld
     C                   movel     '1'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
     *
DRYaA /free
DRYaA     if client = DAIRYLAND and w2plt <> 1;
DRYaA       errmsg = 'Pallets must be 1';
DRYaA       error = *on;
DRYaA       *in26 = *on;
DRYaA       *in06 = *on;
DRYaA       exsr zm0105;
DRYaA     endif;
DRYaA /end-free
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
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
     C     zzchk3        begsr
     C                   eval      error = *off
     C                   eval      errflg = *off
     C                   eval      w3mfdt = 0
     C                   eval      w3exdt = 0
     *
     *  Move screen date into correct date check field.
     *
     C                   select
     C                   when      immflg = 'Y'
     C                   eval      w3mfdt = w3dte
     C                   eval      w3exdt = 0
     C                   eval      svexdt = 0
     C                   when      itflgd = 'Y'
     C                   eval      w3exdt = w3dte
     C                   eval      w3mfdt = 0
     C                   eval      svmfdt = 0
     C                   endsl
SUNaA*
SUNaA*  Lot is required.
SUNaA*
SUNaA
SUNaA /free
SUNaA   Select;
SUNaA     when client = sunrise and $imlot = 'Y'
NOJaA     or client = natalies and $imlot = 'Y';
SUNaA       if w3lot = ' ';
SUNaA         error = *on;
SUNaA         *in23 = *on;
SUNaA         *in03 = *on;
SUNaA         errmsg = *blanks;
SUNaA         errmsg = 'Lot is required';
SUNaA         exsr zm0105;
SUNaA         leavesr;
SUNaA       endif;
SUNaA     other;
SUNaA   endsl;
SUNaA /end-free
     *
     *  Verify expiration date.
     *
     C                   if        itflgd = 'Y'  and
     C                             immflg <> 'Y'
     C                   if        w3exdt = 0
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

     C                   if        w3exdt <> 0
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w3exdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      #msgk = $cvmsg
720aAC                   exsr      zm1007
     C                   goto      enderr
     C                   else
     C                   move      $cvd6o        w3exdt
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
     *  Verify Use by date.
     *  Calculate (Today + Dist Days)  = DATE1
     *  Calculate  (Use By - User Days) = DATE2
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
     *
     *  Verify Expire date and # of days out
     *  Allow warning and override
     C                   if        expd <> 0     and
     C                             w3exdt <> 0
     C                   if        svexdt <> w3exdt
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
740aAC                             and $immflg <> 'Y'
     C                   eval      error = *on
     C                   eval      dtchk = '2'
     C                   eval      warn = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   eval      erused = w3exdt
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
     *  Verify Use by date.
     *  Change to use DTCHK3 for override
     C                   if        w3exdt <> 0
     C                   if        svexdt <> w3exdt
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
     *   If DATE2 <= Date1 - Reject.
     *
     C                   if        date2 <= date1
     C                   eval      error = *on
     C                   eval      dtchk3 = '2'
     C                   eval      warn = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   eval      erused = w3exdt
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
     C                   if        svmfdt <> w3mfdt  or
     C                             w3mfdt = 0
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
     C                   eval      w3exdt = svexdt
     C                   endif
     *
     C                   if        dtchk4 <> '1'
     C                   eval      dtchk4 = *on
     *
     *  Verify manufacturing date.
     *
     C                   select
     C                   when      immflg = 'Y'
     C                   if        w3mfdt = 0
     C                   eval      error = *on
     C                   eval      dtchk4 = *off
     C                   eval      obovr = *off
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1008
     c                   goto      endck3
     C                   else
     C                   if        w3mfdt <> 0
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w3mfdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      dtchk4 = *off
     C                   eval      obovr = *off
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      #msgk = $cvmsg
     C                   goto      enderr
     C                   else
     C                   move      $cvd6o        w3mfdt
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
     C                   move      w3mfdt        $cvd6i
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
     C                   move      $cvd6o        w3exdt
     *
     *  Find the latest acceptable date: Exp date -Dist days
     *
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w3exdt        $cvd6i
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
     C                   eval      ermfdt = w3mfdt
     C                   eval      erexdt = w3exdt
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
     *   Check for ealier expiration dates (optional)
     *
     *     See if we can skip the check.
     *
     C                   if        w3exdt = 0  or
     C                             svexck <> '2'  and
     C                             svexck <> '3'
     C                   goto      skpxck
     C                   endif
     *
     *     Set warning check flag.
     *
     C                   if        svexdt <> w3exdt
     C                   eval      dtchk2 = *off
     C                   eval      oaovr = *off
     C                   eval      ofovr = *off
     C                   endif
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
     C                   parm      w1whse        $swhse            3 0
     C                   parm                    #sitem
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
     C                   if        immflg = 'Y'
     C                   eval      oaovr = *on
     C                   exsr      zm3233
     C                   else
     C                   eval      ofovr = *on
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
     C                             w3dwgt = 0
     C                   if        svcwen = '1'  or
     C                             svcwen = '2'  and
     C                             w3avg <> 'Y'
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(4)
     C                   exsr      zm0110
     C                   endif
     C                   endif
     *
     *  Verify Catch weight average  (Y/N).
     *
     C                   if        w3avg <> 'Y'  and
     C                             w3avg <> 'N'
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(5)
     C                   exsr      zm1005
     C                   endif
     *
     *  When 'First time only' entry with Avg = 'Y'
     *    Then catch weight must be zero.
     *
     C                   if        svcwen = '2'  and
     C                             w3avg = 'Y'  and
     C                             w3dwgt <> 0
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm3234
     C                   endif
     *
     *  When more than one qty is entered, catch weight average must be N
     *
     *    One exception for 'First time only' entry with Avg = 'Y'
     *
     C                   select
     C                   when      w2qt01 <> 0  and
     C                             w3avg = 'Y'  and
     C                             svcwen <> '2'
     C                   if        w2qt02 <> 0
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(5)
     C                   exsr      zm2101
     C                   endif
     *
     C                   when      w2qt02 <> 0  and
     C                             w3avg = 'Y'  and
     C                             svcwen <> '2'
     C                   if        w2qt01 <> 0
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(5)
     C                   exsr      zm2101
     C                   endif
     *
     C                   endsl
     *
     *  Catch weight variance check.
     *
     C                   if        svdwgt <> w3dwgt
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
     C                   if        w3dwgt <> 0
     C                   eval      lwvar = 0
     C                   eval      hivar = 0
     C                   eval      lwrng = 0
     C                   eval      hirng = 0
     C                   eval      exwgt = 0
     C                   eval      ilvar = 0
     C                   eval      ihvar = 0
     C                   eval      ilrng = 0
     C                   eval      ihrng = 0
     *
     C                   if        w3avg = 'Y'
     C                   eval      exwgt = itswgt
     C                   eval      wotcw = w3dwgt
     C                   else
     C     w2qt01        mult      itswgt        exwgt
     C                   eval      wotcw = w3dwgt
     C                   endif
     *
     *    Init flag used to skip variance check if = *ON.
     *
     C                   eval      lvskp = *off
     C                   eval      hvskp = *off
     *
     *    Init fields used to hold low/high variance.
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
     C                   endif
     *
     *     Check CW variance if CW > 0
     *
     C                   if        w3dwgt <> 0
     C                   exsr      zzchkt
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
     C                   eval      svdwgt = w3dwgt
     C                   eval      svmfdt = w3mfdt
     C                   eval      svexdt = w3exdt
     *
     C     endck3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHKT   Screen 3 error check totals
     *
     C     zzchkt        begsr
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
     C                   exsr      zm19
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
     C                   exsr      zm19
     C                   endif
     *
     C                   endsr
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
     *      F10 - Accept Warning.
     *
     C                   if        *inku  or
     C                             *inkj
     C                   eval      ovrrid = *on
     C                   else
     C                   eval      ovrrid = *off
     C                   endif
     *
     *      F11 - Manufacturer code decipher
     *
     c                   if        *inkk
      * f11 is only valid on date sensitive items
     c                   If        itflgd = 'Y' or immflg = 'Y'
     c                   eval      $ldakitem = w1item
     c                   eval      $lupc     = ' '
     c                   eval      ddcode = *off
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
     C                   eval      w3dte  = $lmfrdat
     c                   endif
     C                   if        wodte = 'Exp date'
     C                   eval      w3dte = $lexpdat
     C                   endif
     c                   endif
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm3        endsr
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
     C                   eval      w1whse = #whse
     *
     C                   eval      w1item = *blanks
720bAC                   eval      w1uci  = *blanks
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     *   Get item master fields
     *
     C                   exsr      zzgeti
     *
     *   Get Unit of measure fields
     *
     C                   eval      woum1 = *blanks
     C                   eval      woum2 = *blanks
     C                   exsr      zzuom
     C                   eval      w2qt01 = 0
     C                   eval      w2qt02 = 0
     C                   eval      w2plt = 0
DRYaA /free
DRYaA     if client = DAIRYLAND;
DRYaA       w2plt = 1;
DRYaA     endif;
DRYaA /end-free
     *
     *    Retrieve Item Lot/license plate tracking info.
     C                   eval      $lcmd = *blanks
     C                   eval      $lprg = #prog
     C                   eval      $lwhse = w1whse
     C                   eval      $litem = w1item
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
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     *
     C                   eval      w3dte = 0
     C                   eval      w3dwgt = 0
     C                   eval      w3avg = 'N'
     C                   eval      mfgd = 0
     C                   eval      expd = 0
     C                   eval      svmfdt = 0
     C                   eval      svexdt = 0
     C                   eval      dtchk = *off
     C                   eval      woexdt = 0
     C                   eval      woindt = 0
740cAc                   eval      w3lot = ' '
740eAc                   if        $bclot <> ' '
740eAc                   eval      w3lot = $bclot
740eAc                   endif
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
     *     Then see what value is to be entered (1=Choice,2=Ttl,3=Avg)
     *
     C                   select
     C                   when      svcwtp = '2'
     C                   eval      *in81 = *on
     C                   eval      w3avg = 'N'
     C                   eval      wocrcv = cwt(1)
     C                   when      svcwtp = '3'
     C                   eval      *in81 = *on
     C                   eval      w3avg = 'Y'
     C                   eval      wocrcv = cwt(2)
     C                   other
     C                   eval      *in81 = *off
     C                   eval      w3avg = 'N'
     C                   eval      wocrcv = cwt(2)
     C                   endsl
     *
     *   Initialize date fields.
     *
     C                   select
     C                   when      immflg = 'Y'
     C                   eval      wodte = 'Mfr date'
     C                   eval      *in94 = *off
740eAc** Production Date
740eAC                   if        $bcprodd <> 0
740eAC                   eval      $cvcmd = '*YMDMDY '
740eAC                   move      $bcprodd      $cvd6i
740eAC                   call      @cvtdt
740eAC                   parm                    $cvtdt
740eAC                   if        $cvrtn = '*PGMQ   '
740eAC                   else
740eAC                   move      $cvd6o        w3dte
740eAc                   endif
740eAc                   endif
740eAc** Pack Date
740eAC                   if        $bcpackd <> 0
740eAC                   eval      $cvcmd = '*YMDMDY '
740eAC                   move      $bcpackd      $cvd6i
740eAC                   call      @cvtdt
740eAC                   parm                    $cvtdt
740eAC                   if        $cvrtn = '*PGMQ   '
740eAC                   else
740eAC                   move      $cvd6o        w3dte
740eAc                   endif
740eAc                   endif
     C                   when      itflgd = 'Y'
     C                   eval      wodte = 'Exp date'
     C                   eval      *in94 = *off
740eAc** Sell By
740eAC                   if        $bcslbyd <> 0
740eAC                   eval      $cvcmd = '*YMDMDY '
740eAC                   move      $bcslbyd      $cvd6i
740eAC                   call      @cvtdt
740eAC                   parm                    $cvtdt
740eAC                   if        $cvrtn = '*PGMQ   '
740eAC                   else
740eAC                   move      $cvd6o        w3dte
740eAc                   endif
740eAc                   endif
740eAc** Expiration Date
740eAC                   if        $bcexpd  <> 0
740eAC                   eval      $cvcmd = '*YMDMDY '
740eAC                   move      $bcexpd       $cvd6i
740eAC                   call      @cvtdt
740eAC                   parm                    $cvtdt
740eAC                   if        $cvrtn = '*PGMQ   '
740eAC                   else
740eAC                   move      $cvd6o        w3dte
740eAc                   endif
740eAc                   endif
     C                   other
     C                   eval      wodte = *blanks
     C                   eval      *in94 = *on
     C                   endsl
740cA*
740cA*   Initialize date fields.
740cA*
740cA /free
740cA   if $imlot = 'Y';
740cA     *in92 = *off;
740cA   else;
740cA     *in92 = *on;
740cA   endif;
740cA /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGETI   Get item description and pack description.
     *
     C     zzgeti        begsr
     *
     *   Get item
     *
     C                   eval      woitem = *blanks
     C     itkey         chain     piritem                            79
     C                   if        *in79
     C                   eval      itdesc = *blanks
     C                   eval      itpdsc = *blanks
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   exsr      zm030
     C                   goto      endgeti
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
     *   Set screen 3 (date/weight) flag.
     *
     C                   if        itflgd = 'Y'  or
740cAc                             imlot = 'Y'  or
     C                             immflg = 'Y'
     C                   eval      s3flag = *on
     C                   else
     C                   eval      s3flag = *off
     C                   endif
     *
     C                   if        itcwgt = 'Y'
     C                   if        svcwen = '1'  or
     C                             svcwen = '2'
     C                   eval      s3flag = *on
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
     C                   parm                    #sitem
     C                   parm                    $$wohome
     C                   parm      *blanks       $saisl            3
     C                   parm      *zeros        $sloc             3 0
     C                   parm      *zeros        $srlvl            2 0
     C                   parm      *blanks       $shand            2
     C                   parm                    $srtn             8
     *
     C     endgeti       endsr
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
     *  Define key for PIRITEM file.
     *
     C     itkey         klist
     C                   kfld                    w1whse
     C                   kfld                    woitm#
     *
     *  Define key for LABEL2  file.
     *
     C     lbkey         klist
     C                   kfld                    $rord
     C                   kfld                    w1whse
     *
     *     OPTIONS
     *
     C     opkey         klist
     C                   kfld                    wkwhse
     C                   kfld                    ocode
     *
     *  Define key for OPTIOND.
     *
     C     opkey2        klist
     C                   kfld                    kycode
     C                   kfld                    w1whse
     C                   kfld                    itwhdp
     C                   eval      kycode = '*PICK   '
     *
     *  Define key for ITEMMSC file.
     *
     C     imkey         klist
     C                   kfld                    itwhse
     C                   kfld                    ititem
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
     C                   eval      wkwhse = #whse
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
     C                   setoff                                       kckl
     C                   eval      dtchk = *off
     C                   eval      dtchk2 = *off
     C                   eval      dtchk3 = *off
     C                   eval      dtchk4 = *off
     C                   eval      wtchk = *off
     *
     *   Get screen size being used.
     *
     C                   call      'PIRRFSCR'
     C                   parm      '*GET'        #lcmd             8
     C                   parm                    #lline            2
     C                   parm                    #lcol             3
     *
     C                   call      'RC160'
     C                   parm      '*OPEN   '    $rcmd             8
     C                   parm                    $rprg            10
     C                   parm      '*INTER  '    $rtype            8
     C                   parm                    w1whse            3 0
     C                   parm                    woitm#           15
     C                   parm                    w2qt01
     C                   parm      0             w2qt02            5 0
     C                   parm      0             w2qt03            5 0
     C                   parm      ' '           wopo              9
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
     C                   eval      lflag = *off
     C                   eval      refrsh = *on
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
     C                   exsr      scr01i
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
     C                   eval      wkwhse = w1whse
     *
     C     opkey         chain     options                            79
     C                   if        not *in79
     C                   eval      rcdata = opdata
DRYaA /free
DRYaA   Select;
DRYaA     when client = DAIRYLAND;
DRYaA       lflag = *off;
DRYaA     other;
DRYaA /end-free
     C                   if        opplcn = 'Y'
     C                   eval      lflag = *on
     C                   endif
DRYaA /free
DRYaA   endsl;
DRYaA /end-free
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
     C                   parm                    w1whse
     C                   parm                    woitm#
     C                   parm                    w2qt01
     C                   parm                    w2qt02
     C                   parm      0             w2qt03
     C                   parm      ' '           wopo
     C                   parm                    w1ven
     C                   parm                    $$phvnam
     C                   parm                    w1item
     C                   parm      0             $rord
     C                   parm      *blanks       $rrcod
     C                   parm      *blanks       $rrmem
     C                   parm      expd          $rexpd
     C                   parm      0             $rfifo
     C                   parm                    w1dev
     C                   parm                    w1form
     C                   parm      *blanks       $rslot
     C                   parm      0             woline            5 0
     C                   parm                    $rrpck
     C                   parm                    $rplbl
     C                   parm                    w3twgt
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
     C                   eval      $lflag = lflag
     C                   if        lflag = *off
     C                   eval      $lcmd = '*LICONLY'
     C                   else
     C                   eval      $lcmd = '*CHANGE '
     C                   endif
     C                   eval      $lwhse = w1whse
     C                   eval      $lpo2 = *blanks
     C                   eval      $litem = woitm#
     C                   eval      $lrq1 = w2qt01
     C                   eval      $lrq2 = w2qt02
     C                   eval      $lrq3 = 0
     C                   eval      $lrpal = w2plt
     C                   eval      $lum1 = woum1
     C                   eval      $lum2 = woum2
     C                   eval      $lum3 = *blanks
     C                   eval      $lord = $rord
     C                   eval      $lven = $$phven
     C                   eval      $lvnam = $$phvnam
     C                   eval      $lvitm = w1item
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
     C                   eval      $ldwgt = w3twgt
     *
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
740cDC*                  parm                    $llotc           30
740cMC                   parm      w3lot         $llotc           30
     C                   parm                    womfdt
     C                   parm      0             wofifo
     C                   parm      ' '           woupc            20
     c                   parm                    $ldecvalue
     C                   parm      mexpd         $lmfgex           8 0
     C                   parm      mfgdte        $lmfgdt           8 0
     c                   parm      ' '           $plpn            50
     c                   parm      ' '           $pgslcns         15
     c                   parm      ' '           $pbrand          10
     c                   parm                    $parms1
     C                   parm                    $lsavetrn
     c                   parm                    $pgtin           14
     c                   parm                    $pbcProdD         6 0
     c                   parm                    $pbclot          20
     c                   parm      0             $pw1pti
     *
     C     lbkey         setll     label2
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     lbkey         reade     label2                                 79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   if        immflg = 'Y'
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
     C                   endif
     C                   enddo
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
     C                   eval      $lcmd = '*NONE   '
     C                   eval      $lwhse = w1whse
     C                   eval      $lpo2 = *blanks
     C                   eval      $litem = woitm#
     C                   eval      $lrq1 = w2qt01
     C                   eval      $lrq2 = w2qt02
     C                   eval      $lrq3 = 0
     C                   eval      $lrpal = w2plt
     C                   eval      $lum1 = woum1
     C                   eval      $lum2 = woum2
     C                   eval      $lum3 = *blanks
     C                   eval      $lord = $rord
     C                   eval      $lven = $$phven
     C                   eval      $lvnam = $$phvnam
     C                   eval      $lvitm = w1item
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
     C                   when      w3mfdt <> 0
     C                   eval      woindt = womfdt
     C                   other
     C                   eval      woindt = woexdt
     C                   endsl
     *
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
     C                   parm                    w3twgt
     C                   parm                    avgwt1
     C                   parm                    avgwt2
     C                   parm                    avgwt3
740cDC*                  parm      ' '           w9lotc           30
740cMC                   parm      w3lot         w9lotc           30
     C                   parm                    woindt
     C                   parm                    wofifo
     C                   parm      ' '           woupc
     c                   parm                    $ldecvalue
     C                   parm      mexpd         $lmfgex           8 0
     C                   parm      mfgdte        $lmfgdt           8 0
     c                   parm      ' '           $plpn            50
     c                   parm      ' '           $pgslcns         15
     c                   parm      ' '           $pbrand          10
     c                   parm                    $parms1
     C                   parm                    $lsavetrn         7 0
     C                   parm                    $pgtin           14
     c                   parm                    $pbcProdD
     c                   parm                    $pbclot
     c                   parm      0             $pw1pti
     C                   parm                    $posscode         1
     *
     C     $lrtn         cabeq     '*EXIT'       endpdm
     C     $lrtn         cabeq     '*CANCEL'     endpdm
     *
     C                   if        $lrtn = '*OK     '
     c                   eval      $ldecvalue  = ' '
     c                   eval      $lmfgex = 0
     c                   eval      $lmfgdt = 0
     c                   eval      mexpd     = 0
     c                   eval      mfgdte   = 0
     C                   if        w3mfdt <> 0  or
     C                             w3exdt <> 0
     C                   eval      $rord = $lord
     C     lbkey         setll     label2
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     lbkey         reade     label2                                 79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
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
     C                   parm                    w1whse
     C                   parm                    woitm#
     C                   parm                    w2qt01
     C                   parm                    w2qt02
     C                   parm      0             w2qt03
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
     C                   parm                    w3twgt            9 2
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
     C                   parm      immday        $cddays
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
     C                   eval      wkmday = immday

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

     c                   when      w3mfdt > 0 and itflgd = 'Y'
     *
     *  Calculate Mfg Exp    date.(Mfg date + Mfg Shelf life days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w3mfdt        $cvd6i
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
     C                   parm      immday        $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     mexpd         parm      0             $cddateout
     C                   parm      0             $cdtimeout

     c                   when      w3exdt > 0

     *
     *  Calculate Mfg date.(Mfg exp date - Mfg Shelf life days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w3exdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        mexpd
     C                   eval      wkmday = immday

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

     *  See if we need to get date or weight.
     *
     C                   if        s3flag = *on
     C                   exsr      scr03i
     C                   goto      endup2
     C                   endif
     *
     C                   eval      vrfycw = *off
     C                   exsr      zzzcw
     *
     *
     C                   eval      w3twgt = 0
     C                   eval      w3mfdt = 0
     C                   eval      mfgd = 0
     C                   eval      w3exdt = 0
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
     C     error         cabeq     *on           endup2
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     *
     *     Manual putaway
     *
     C                   when      opmput = 'Y'
     C                   exsr      zzpman
     C     error         cabeq     *on           endup2
     C     $lrtn         cabeq     '*EXIT'       endup2
     C     $lrtn         cabeq     '*CANCEL'     endup2
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     *
     *     Or Directed Putaway
     *
     C                   other
     C                   exsr      zzpdir
     C     error         cabeq     *on           endup2
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     *
     C                   endsl
     *
     C     endup2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update for screen 3.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     c                   if        $ldecvalue = ' '
     c                   exsr      zzmfrdates
     c                   endif
     *
     C                   exsr      zzzcw
     C                   if        immflg = 'Y'
     *
     *  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w3mfdt        $cvd6i
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
     C                   move      $cvd6o        w3exdt

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
     C                   exsr      scr01i
     *
     *     Or Directed Putaway
     *
     C                   other
     C                   exsr      zzpdir
     C     error         cabeq     *on           endup3
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     *
     C                   endsl
     *
     C     endup3        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZZCW    Calculate catch weight
     *
     *
     *  Action Table
     *
     *   VRFYCW  SVCWEN  SVCWTP  W3AVG  POCTYP  Action
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
     C                   eval      w3twgt = 0
     C                   eval      avgwt1 = 0
     C                   eval      avgwt2 = 0
     C                   eval      avgwt3 = 0
     C                   eval      cwcalc = 0
     *
     *   Determine what needs to be done based on table.
     *
     C                   select
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '1'  and
     C                             svcwtp = '1'  and
     C                             w3avg = 'N'
     C                   eval      cwcalc = 1
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '1'  and
     C                             svcwtp = '1'  and
     C                             w3avg = 'Y'
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
     C                             w3avg = 'N'
     C                   eval      cwcalc = 1
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '2'  and
     C                             svcwtp = '1'  and
     C                             w3avg = 'Y'
     C                   eval      cwcalc = 3
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '2'  and
     C                             svcwtp = '2'
     C                   eval      cwcalc = 1
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '2'  and
     C                             svcwtp = '3'
     *
     C                   when      vrfycw = *off  and
     C                             svcwen = '1'
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
     C                   eval      w3twgt = w3dwgt
730bAc                   if        w2qt01 > 0
     C     w3dwgt        div       w2qt01        avgwt1
730bAc                   endif
     *
     *     Entered quantity * Entered weight.
     *
     C                   when      cwcalc = 2
     C     w3dwgt        mult      w2qt01        w3twgt
     C                   z-add     w3dwgt        avgwt1
     *
     *     Entered quantity * Item weight.
     *
     C                   when      cwcalc = 3
     *
     *       Normal qty for non-SSB items.
     *
     C                   if        w2qt01 > 0  and
     C                             #otype <> 'S'
     C     #oswgt        mult      w2qt01        w3twgt
     C                   eval      avgwt1 = #oswgt
     C                   endif
     *
     *       Normal qty for SSB items.
     *
     C                   if        w2qt01 > 0  and
     C                             #otype = 'S'
     C     #oswt2        mult      w2qt01        w3twgt
     C                   eval      avgwt1 = #oswt2
     C                   endif
     *
     *       Brk1 qty for non-SSB items.
     *
     C                   if        w2qt02 > 0  and
     C                             #otype <> 'S'
     C     #oswt2        mult      w2qt02        tmpwgt
     C                   add       tmpwgt        w3twgt
     C                   eval      avgwt2 = #oswt2
     C                   endif
     *
     *       Brk1 qty for SSB items.
     *
     C                   if        w2qt02 > 0  and
     C                             #otype = 'S'
     C     #oswt3        mult      w2qt02        tmpwgt
     C                   add       tmpwgt        w3twgt
     C                   eval      avgwt2 = #oswt3
     C                   endif
     *
     C                   endsl
     *
     C                   endsr
730dA*----------------------------------------------------------------
730dA*  clr$item  Clear $item data structure fields
730dA*----------------------------------------------------------------

730dAC     clr$item      begsr
730dAC                   eval      savever# = $itver#
730dAC                   clear                   $item
730dAC                   clear                   $item2
730dAC                   eval      $itver# = savever#
730dAC                   endsr

730dA*----------------------------------------------------------------
730dA*  zzzdricop  Call DRICOP
730dA*----------------------------------------------------------------

730dAC     zzzdricop     begsr
730dAC                   eval      error = *off

730dAC                   select
730dAC                   when      $dricommand = '*ITEM'
730dAC                   eval      $dridata = $item
730dAC                   eval      $dridata2 = $item2
730dAC                   endsl

730dAC                   select

730dAC                   when      $dricommand = '*ITEM'
730dAC                   call(e)   'DRICOP'
730dAC                   parm                    $dricommand
730dAC                   parm                    $drisubcmd
730dAC                   parm                    $drisys2upd
730dAC                   parm      #prog         $driprogram
730dAC                   parm      ' '           $drireturn
730dAC                   parm      ' '           $drimessage
730dAC                   parm                    $dridata
730dAC                   parm                    $dridata2
730dA
730dAC                   other
730dAC                   call(e)   'DRICOP'
730dAC                   parm                    $dricommand
730dAC                   parm                    $drisubcmd
730dAC                   parm                    $drisys2upd
730dAC                   parm      #prog         $driprogram
730dAC                   parm      ' '           $drireturn
730dAC                   parm      ' '           $drimessage
730dAC                   parm                    $dridata
730dA
730dAC                   endsl

730dAC                   select

730dAC                   when      chk4err and %error
730dAC                   eval      error = *on
730dAC                   eval      errmsg    = 'Error occured on call to '
730dAC                                       + 'DRICOP'
730dAC                                       + '/' + %trim($drisubcmd)
730dAC                                       + ' from ' + #prog
730dAC                   exsr      zm0105

730dAC                   when      $drireturn <> '*OK'
730dAC                   eval      error = *on
730dAc                   if        zmflag
730dAC                   exsr      zm0001
730dAc                   endif

730dAC                   endsl

730dAC                   select
730dAC                   when      $dricommand = '*ITEM'
730dAC                   eval      $item = $dridata
730dAC                   eval      $item2 = $dridata2
730dAC                   endsl

730dAC                   eval      zmsflag = *off
730dAC     enddricop     endsr

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
**
Ttl
Avg
