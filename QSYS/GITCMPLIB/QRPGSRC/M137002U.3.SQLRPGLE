      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  M137002u   Purchase Order Receiving - license entry/update
     *  06 November 2017
     *  Lynn McMahon
     *
     *
     *----------------------------------------------------------------
     *  Revisions
     *    11/06/17  LMC  7.10a
     *      - Created
     *      - Copied from M13700u
     *
720aA*    02/01/18  LMC  7.20a
     *      - Fix: need to send puser to close the rcvpo transaction
     *        with the employee correctly.
     *      - Fix: zero savetrn from pirhold record if everything
     *        processes with no errors.
     *
720bA*    03/23/18  LMC  7.20b
     *      - Fix: rcvpo transactions need to have pieces loaded.
     *
SFPaA*    02/22/18  JCJ  SFPa
     *      - Added code for Sea Shore to use prefix 'SFP' for License.
720cA*    04/18/18  LMC  7.20c
     *      - Fix: Move part of 720a fix that zeros savetrn from
     *        zzrcvpoclose to editdone.
720dA*    05/17/18  LMC  7.20d
     *      - Enh: Only write PTI records to the uciinfo file if the
     *        item is setup for pti selection
720eA*    05/25/18  LMC  7.20e
     *      - Fix: Notlive departments were not processing correctly.
720fA*    07/31/18  LMC  7.20f
     *      - Fix: pick slot receiving was not putting the correct
     *        license into the uciinfo summary weight record.
720gA*    10/12/18  LMC  7.20g
     *      - Enh: Additional receiving methods have been created.
     *        4,5 & 6. They all are standard receiving with an addon
     *        for printing labels (aka Box labeler).
     *
720hA*    11/16/18  LMC  7.20h  reserved
     *      - Enh: UCI Tracking
720iA*    11/26/18  LMC  7.20i
     *      - Fix: Mfg Date was being loaded into mfg exp date in
     *        licinfo file.
730aA*    02/13/19  LMC  7.30a
     *      - Fix: pick slot receiving was not putting a license
     *        into the PORCV record.
730bA*    06/05/19  LMC  7.30b
     *      - Fix: Pick slot Receiving on ssb, was not closing
     *        transaction.
730cA*    07/12/19  LMC  7.30c
     *      - Fix: Do not call PO172. will need gui changes to handle
     *        clams the old way. should try to use pcm instead
740aA*    06/29/20  LMC  7.40a
     *      - Enh: Clients using item license plates, and pick slot
     *        receiving, should not get an item license generated.
740bA*    07/07/20  KDE  7.40b
     *      - Enh: Add update to POASN for ASN receipts
     *      - Pass lot and dates to GETASN to select only POASN record
     *        being received
740cA*    07/27/20  LMC  7.40c
     *      - Enh: Allow ICB and ISUPPLY to enter OSS as the license
     *        then replace it with the oss license just created.
     *        Found this mod in po236.
750a *    05/14/21  RTR  7.50a
     *      - DockVue: Added update of POSTATUS table when PO added or
     *        updated.
750b *    07/12/21  LMC  7.50b
     *      - When receiving multiple pallets with one total weight.
     *        We will load the weight into the first license processed
760a *    04/29/22  LMC  760a
     *     - The host system FRESHBYTE requires a lot code.
     *       They tell us the lot code is the po&line number
     *       On a call today 4/29/22 they said the lot# was
     *       8 positions, 6 for po with leading zeros and 2 for line
     *       I am assuming the 2 positions for line# should have a
     *       leading zero also. so po 00030001 300 is po line 1.
760b *    11/08/22  LMC  760b
     *     - Eliminate DDE error when uomcnt = 0
     *
770a *    02/16/23  LMC  770a reserved
     *
770b *    02/24/23  LMC  770b  Send the Lot code to RFMT, parm 27
     *----------------------------------------------------------------
     *  Client Custom Revisions: Get Fresh Sales
     *
GFSaA*    07/24/20  LMC  GFSa  - found in po236 01/14/19 MLB
     *      - Enh: ZZCHK1 to ensure that first character of license
     *        plate begins with G, F or K. Per Shawn S phone call.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Westside
     *
WSFa *    07/24/20  LMC  WSFa  - found in po1236 09/19/16 GJA
     *      - Add check in ZZCHK1 to only allow 7 digit license
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt
     *
CSPaA*    07/27/20  LMC  CSPa  - found in PO236 07/10/19 RH
     *      - When calling DRISLOT with %CRTXDOCK, force aisle
     *        to be 'PC ' if pdspcl = 'XD'.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: FoodPro
     *
FPR A*    07/24/20  LMC  FPRa  - found in po236 07/06/15 RH
     *      - Enh: ZZCHK1 to ensure that first character of license
     *        plate begins with F or R per Carolyn H.
FPRbA*    07/24/20  LMC  FPRb  - found in po236 06/03/19 MLB
     *      - Enh: ZZCHK1 to ensure that first character of license
     *        plate begins with F or R or P. per Eli H.
     *
     *----------------------------------------------------------------
     *  Client Cusotm Revisions: Caribbean Producers
CPJ A*    11/10/22  MLB  CPJ
     *      - Revised pgm to use GLZVALID string when validating license
     *        plate values.
     *      - Added CPJ to GLZ mod.
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   Field position to
     *  21 - 40   Field input error (reverse display)
     *  71        Chain indicator for LICEXST DSP
     *  83        Clear subfile (SFLCLR)
     *  84        Allow subfile to display '+' (SFLEND)
     *  85        Manually set subfile change flag (SFLNXTCHG)
     *  90        View mode (Protect input fields)
     *  91        Change mode (protect key)
     *  92        Too many license pallets requested-External storage
     *  93        No license pallets entered-External storage
     *  95        Protect site code on off site storage window
     *  96        Used to disable F9 off site storage
     *  97        Error message subfile indicator
     *  98        Error on screen (sound buzzer)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fslot1     uf a e           k disk
     F                                     rename(slrec:s1rec)
     F*slot2     uf   e           k disk
     F*                                    rename(slrec:s2rec)
     Fslot3     uf   e           k disk
     F                                     rename(slrec:s3rec)
     Fslot10    if   e           k disk
     F                                     rename(slrec:s10rec)
     FLabel2    if   e           k disk
     F                                     rename(lbrec:record)
     F*License   uf a e           k disk
     FLicense1  uf a e           k disk
     F                                     rename(lirec:lirec1)
     F*podtl     uf   e           k disk
     Fpodtl     uf a e           k disk
     Fpohdr     uf   e           k disk
     F*Label     o  a e           k disk
     FLabel     uf a e           k disk
     F*warehs    if   e           k disk
     Fitemdsc   if   e           k disk
     F*options   if   e           k disk
     Fordd      if   e           k disk
     Fworkoss   uf a e           k disk
700lDF*workoss1  uf   e           k disk
700lAFworkoss2  uf   e           k disk
     F                                     rename(worec:worec1)
     Fporcv     o  a e           k disk
     fhaccpxrf  o  a e             disk
     Fitemadj   o  a e             disk
     Fpirhold   uf a e           k disk
     Fbatctl    o    e           k disk
     Fpocwexcp  uf a e           k disk    Prefix(cw_) rename(exrec:cwexrec)
     Fitmexcp   o    e           k disk
     Fpofifo    o    e           k disk
     Fpomfr1    uf a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D lcns            s             15    dim(500)
     D desc            s             50    dim(12) ctdata perrcd(1)

     d $lparm1         s             48    dim(20)
     D $parms1         s             48    dim(20)
     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#packers
      /copy qcopysrc,id#tpc
      /copy qcopysrc,id#sgc
      /copy qcopysrc,id#saval
      /copy qcopysrc,id#halsey
      /copy qcopysrc,id#glazier
      /copy qcopysrc,id#egf
      /copy qcopysrc,id#royal
      /COPY QCOPYSRC,Id#Coastal
      /COPY QCOPYSRC,Id#Eastlan
      /COPY QCOPYSRC,Id#ICB
      /copy qcopysrc,id#dairyla
      /COPY QCOPYSRC,Id#GFS
      /copy qcopysrc,id#citylin
SFPaA /copy qcopysrc,id#sfp
WSFaA /copy qcopysrc,Id#westsid
740cA /COPY QCOPYSRC,Id#ISupply
FPRaA /copy qcopysrc,Id#fpr
CPJ A /copy qcopysrc,id#cpj
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql


     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS
     *----------------------------------------------------------------
     *  pirhold structures
     *----------------------------------------------------------------
      /copy qcopysrc,C#PIRHLDPO
      /copy qcopysrc,C#PIRHLLCN
740bA /copy qcopysrc,C#PIRHLDAS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#XDOCK
      /COPY *libl/qcopysrc,C#LICINFO
      /COPY *libl/qcopysrc,C#LICHIST
      /COPY *libl/qcopysrc,C#LICENSE
      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#UCIINFO
     D savever#        s                   like($lnver#)

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D lirec         E Ds                  Extname(license)
     D oprec         E Ds                  Extname(options)
     D phrec1        E Ds                  Extname(pohdr)
700hAD pdrecBrd      E Ds                  Extname(podtl) prefix(BR_)
700lAD osrecck       E Ds                  Extname(workoss) prefix(os_)
720hAD uprecuom      E ds                  extname(upc) inz(*EXTDFT)
     *----------------------------------------------------------------
     *  Program parameters
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     D* $pwhse                19     21  0
     D* $pitem                22     36
     D* $ppo                  37     45
     D* $prq1                 46     50  0
     D* $prq2                 51     55  0
     D* $prq3                 56     60  0
     D* $prpal                61     63  0
     D* $plott                64     64
     D* $plict                65     65

     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D                 ds
     D  dspo                   1      9
     D  dslbl                 10     16  0
     D  dsexpd                17     24  0
     D  dsfdis                 1     12
     D  dstdis                13     24
     *  Extra parameters not part of data structure.

     D*$pindt          s              8  0
     D $pfifo          s              8  0

     D $p1parms1       ds
     D  $p1whse                1      3
     D  $p1po                  4     12
     D  $p1poseq              13     17
     D  $p1qstseq             18     22
     D  $p1uctime                      Z
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
     D  $ltype                81     88
     *
     *   Redefine key
     *
     D  $lstat                19     20
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     D  $lrack                22     26
     *
     D  $lbld                 19     20
     *
     D  $lrte                 22     26
     D  $lpo                  27     35
     D  $ltrn#                36     42  0
     *   for Haccp
     D  $llevel               22     25
     D  $llicense             26     40
     D  $lhpo                 41     49
     D  $lhseq                50     54  0
     D  $lhtype               55     57
     *
     D $mparm          ds
     D  $mcmd                  1      8
     D  $mprg                  9     18
     D  $muky                 19     68
     D  $mrtn                 69     76
     D  $merm                 77    136
     D  $mmsg                 77     80
     D  $mtype                81     88
     *
     D  $mwhs2                19     20P 0
     D  $mpo2                 21     29
     D  $mseq                 30     32P 0
     D  $mitem                33     47
     D  $mqyr1                48     50P 0
     D  $mqyr2                51     53P 0
     D  $mqyr3                54     56P 0
     D  $mcwte                57     59P 0
     D  $mcwtt                60     64P 2
     D  $mcwta                65     68P 2
     *   Redefine key
     D  $mwhs3                19     20p 0
     D  $mpo3                 21     29
     D  $mitm3                33     47

     D rcv01           c                   const('Receiving')
     D rcv02           c                   const('Dock')
     D Clams           c                   const('CLAMS     ')
     D Shucked         c                   const('SHUCKED   ')
     *----------------------------------------------------------------
     *  Name constants
     *
     D valid           c                   const('0123456789 ABCDEFGHI-
     D                                     JKLMNOPQRSTUVWXYZabc-
     D                                     defghijklmnopqrstuvw-
     D                                     xyz')
     *
     D GLZvalid        c                   const('0123456789 ABCDEFGHI-
     D                                     JKLMNOPQRSTUVWXYZabc-
     D                                     defghijklmnopqrstuvw-
     D                                     xyz-')
     D SGCvalid        c                   const('0123456789')
WSFa D WSFvalid        c                   const('0123456789')
760a D freshbyte       c                   const('FRESHBYTE')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
     D @fmti2          c                   const('FRMTIT2')
     D @addtr          c                   const('ADDSTDTRN')
     D @crtrcv         c                   const('CRTRCVTRN')
     D @uci            c                   const('CW130')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D*$cvtdt          ds
     D* $cvcmd                 1      8
     D* $cvprg                 9     18
     D* $cvd6i                19     24
     D* $cvd8i                25     32
     D* $cvd6o                33     38  0
     D* $cvd8o                39     46  0
     D* $cvsto                47     64
     D* $cvrtn                65     72
     D* $cverm                73    132
     D* $cvmsg                73     76
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  erqty1                 1      4p 0
     D  erqty2                 5      8p 0
     D  eruom                  9     13
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
     * Data structure
     *
     D*opdata          ds
     D optionrec       ds
     D  opstyp                 1      1
     D  opwhdp                 2      6
     D  opum1                  7      8
     D  opdum                  9     23
     D  opcum                 24     43
     D  opcdiv                44     52  2
     D  opcaut                53     53
     D  opcwrn                54     54
     D  opcrng                55     57  1
     D  opwum                 58     72
     D  opxdsc                73     73
     *  Receiving options.
     D  oplpgm                 1     10
     *
     *  OPUPCT was changed to have 2 decimal positions.
     *
     D  opupct                11     13  2
     D  oppdef                14     14  0
     D  oppbld                15     15  0
     D  oppact                16     16  0
     D  opfdef                17     17  0
     D  opfasl                18     18  0
     D  opfsid                19     19  0
     D  opflvl                20     20  0
     D  oppasl                21     21  0
     D  oppfrc                22     22
     D  optend               117    117
     *----------------------------------------------------------------
     *  *SYSTEM   -  System options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPUCI   -  Use UCI processing (Y,N)
     *----------------------------------------------------------------
     *
     * Data structure
     *
     D opdat4          ds
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
     D  opishsa               33     35
     D  opuci                 36     36
     D  opwrncr               37     37
     D  opicwr                38     38
     D  optrax                39     39
     D  op4end               117    117
     *  *FEATURE  -  PIR Feature options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPFEAT  -  PIR Installed feature.
     *                 1=Locator system installed.
     *                 2=Full system installed.
     *                 3=Stand Alone system installed.
     *
     * Data structure
     *
     D opdat3          ds
     D  opfeat                 1      1
     D  op3end               117    117
     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z

     D bfcoffset       s              3  0 inz(0)
     *----------------------------------------------------------------
     *  Program info data structure
     *
      /COPY *libl/qcopysrc,C#PGMINFDS
     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.cvtdte
700hA /copy qcopysrc,p.GETBRAND
     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------
     D ha410           pr                  extpgm('HA410')
      * Input
     D   pparm                       80
     D   pparm1                      48    dim(20)
     D calcpti         pr                  extpgm('CALCPTI')
      * Input
     D   pGTIN                             like($pgtin)
     D   pLOT                              like(pplot)
     D   pPackDate                         like($pbcProdD)
     D   pPTI                              like(pppti)
     D ucilic#         pr                  extpgm('UCILIC#')
      * Input
     D   unext                       13  0 const
     D   uwhse                        3  0 const

     D r13200          pr                  extpgm('R13200')
     D  pSessId                      40
     D  pWhse                         3p 0
     D  pPo                           9
     D  pPOSeq                        5  0
     D  pPOItem                      15
710aAD  pProgram                     20
     D  pOutStr                    1024

     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *
     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4
     D chklcns         ds
     D  chkoss2                1      2
     D  chk7lcns               1      7
     D  chk8lcns               8     15
WSFaAD WSFlcns         ds
WSFaAD  WSF99I                 1      3
WSFaAD  WSF7lcns               1      7
WSFaAD  WSF8lcns               8     15
     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *
     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10
     D $vstat          s                   like($slstat)
     *----------------------------------------------------------------
     *  Variables
     *
     D $adisp          s             12
     D $apslt          s             12
     D $astyp          s              1
     D $ewhdp          s              5
     D $msgf           s             10
     D $unext          s             13  0
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
720hAD blank6          s              6
     D blklcn          s             15
     D ck4err          s              1
     D ckexdt          s              8  0
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D curtime         s              6  0
     D dummy           s              3  0
     D e               s              2  0
     D enter           s              5  0
     D error           s               n
700iDD*exwgt           s              9  2
     D extstgFlag      s               n
750bAD firstLcns       s               n
     D forevr          s              1
     D full            s              1
     D gs1seqqty       s              5  0
     D help            s              5  0
     D hxwhse          s              3  0
     D hxpo            s              9
     D hxposeq         s              5  0
     D hxseq#          s              5  0
     D hxadduc         s               z
     D hxlcns          s             15
     D i               s              3  0
     D j               s              2  0
     D icbLcns         s               n
     D icbOlcn         s             15
     D k               s                   like($lnrcvqty)
     D k1aisl          s                   like(slaisl)
     D k3pick          s                   like(slpick)
     D k3stat          s                   like(slstat)
     D kystat          s                   like(slstat)
     D l               s              3  0
770bAD lblLot          s             30
700iAD lblpgm          s                   like(oplpgm)
     D lcnsExists      s               n
     D locatr          s              1
     D lowumq2         s                   like($itumq2)
     D lowumq3         s                   like($itumq3)
     D lwtqty          s              7  0
     D msgk            s              4  0
     D need1           s              5  0
     D need2           s              5  0
     D need3           s              5  0
     D newlbl#         s                   like(lblbl#)
     D noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')
     D nxtrec          s              5  0
     D nxtscr          s              3
     D ocode           s              8
     D ossLcns         s               n
     D part            s              1
     D pctr            s              3  0
     D pllStampSys     s               z
     D pllStampUc      s               z
     D poppcs          s                   like(@ppcs)
700iDD*prg1c           s              4  3
700iDD*prg2c           s              4  3
     D posrec          s              4  0
     D ptqty           s              6  0
     d pplot           s             20
     d pppti           s              4  0
     D q1lft           s              5  0
     D q2lft           s              5  0
     D q3lft           s              5  0
     D rcvdday         s              3
     D rcvmday         s              3
     D rcvuday         s              3
     D rcvpocomplete   s               n
     D reccnt          s              4  0
     D recno           s              4  0
     D recv            s              1
     D redspl          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D rpal            s              3  0
     D savdsp          s             12
     D sclear          s              1
     D sflrec          s              5  0
     D stop            s              1
     D sv_pdspcl       s              2
     D tmpflg          s              1
     D tmploc          s              3  0
     D today           s              8  0
     D today6          s              6  0
     D totqty          s              6  0
     D t1qty           s              6  0
     D t2qty           s              6  0
     D t3qty           s              6  0
     D unexta          s             13
     D uxflag          s              1
     D warn            s              1
     D wkwhse          s              3  0
     D wofifo          s              8  0
720hAD workupc         s                   like(upupc)
     D wtlqty          s              7  0
     D x               s              5  0
     D xdkdri          s              1
     D xdkflg          s              1
     D xdkupd          s              1
     D xqty            s              6  0
     D xx              s              5  0
     D zmflag          s               n
     D zmsflag         s               n
     D*$pcmd           s              8
     D*$prtn           s              8
     D $phdte          s              8  0
     D $phloc          s             20
     D $pcert          s             20
     D $pcode          s             10
     D $phhdr          s              1
     D $phdtl          s              1
     D $phcat          s              1
     D sav$pcmd        s              8
     D $plbl#          s              7  0
     D $plic#          s             15
     D $pqty           s              5  0
     D $pprt           s             10
     D $pform          s             10
     D @pttrn#         s              7  0
     D $p1qty          s              6  0
     D $p2qty          s              6  0
     D $p3qty          s              6  0
     D $pwhs           s              3s 0
740bAd wkMfgDt         s              6  0
740bAd wkExpDt         s              6  0

     D currtimestamp   s               z

     D #rcvarea        s              6
     D #rcvitem        s                   like($ititem)
     D #rcvtype        s                   like($ittype)
     D #rcvdesc        s                   like($itdesc)
     D #rcvpdsc        s                   like($itpdsc)
     D #rcvwhdp        s                   like($itwhdp)
     D #rcvstyp        s                   like($itstyp)
     D #rcvdesg        s                   like($itdesg)
     D #rcvum1         s                   like($itum1)
     D #rcvflg1        s                   like($itflg1)
     D #rcvum2         s                   like($itum2)
     D #rcvumq2        s                   like($itumq2)
     D #rcvflg2        s                   like($itflg2)
     D #rcvum3         s                   like($itum3)
     D #rcvumq3        s                   like($itumq3)
     D #rcvdday        s                   like($imdday)
     D #rcvmday        s                   like($immday)
     D #rcvmflg        s                   like($immflg)
     D #rcvuday        s                   like($imuday)
     D #rcvnrpk        s                   like($imnrpk)
     D #rcvflgd        s                   like($itflgd)
     D #rcvcube        s                   like($itcube)
     D #rcvswgt        s                   like($itswgt)
     D #rcvupc         s                   like($itupc)

     D #slotitem       s                   like($ititem)
     D #slottype       s                   like($ittype)
     D #rcvcwgt        s                   like($itcwgt)


     D client          s             10
     D clientloc       s             10
760aAD clientint       s              3
760aAD clienthost      s             10

     D pMessage        s             99
     D psessid         s             40
     D puser           s             10
     D ppgm            s             20
     D pwhse           s              3  0
     D ppo             s              9
     D pposeq          s              5  0
     D ppoitem         s             15
     D w1lcns          s             15
     D w1qty           s              5  0
     D w1uom           s              5
     D w1umt           s              1
     D w1xdk           s              1
     D pdone           s              1
700bAD paction         s              1
710a D pprinter        s             10
     D dlabel          s              7  0
     D dtrn            s              7  0
     D pokey           s             50

     d $pdev           s             10

     D whse            s              3p 0
     D PO              s              9
     D POSeq           s              5p 0
     D POItem          s             15
     D PJSON           s           1024
     D session         s             40
710aAD ppgm1           s             20

     D forever         s               n

     D opt             s              1
     D val             s            400    varying
     D delimiter       s              1    varying
     D comp            s              1
     D d               s              5p 0
     D donBeg          s              5p 0
     D donEnd          s              5p 0
     D donLen          s              5p 0
     D donPos          s              5p 0
     D valBeg          s              5p 0
     D valEnd          s              5p 0
     D valLen          s              5p 0
     D valPos          s              5p 0

700cAD LicenseCnt      s              5p 0
700kAD UOMCnt          s              3p 0
700hAD BrandReq        s              1
700hAD NewSeq#         s                   like(pdseq)
700hAD bCmd            s             10
700hAD bBrand          s             10
700hAD bBranditm       s             15
700hAD bBrandFlg       s              1
700iAD pitem           s                   like(ppoitem)
720bAD totpcs          s              5p 0
     *----------------------------------------------------------------
     *  CVTDTE constant and parameter data structure.
     *----------------------------------------------------------------

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
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist

     C                   parm                    pMessage
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pPgm
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pPOSeq
     c                   parm                    pPOItem
     c                   parm                    w1lcns
     c                   parm                    w1qty
     c                   parm                    w1uom
     c                   parm                    pdone
700bAc                   parm                    paction
     c                   parm                    dlabel
     c                   parm                    dtrn
     c                   parm                    pprinter
     *
     C     po172p        plist
     C                   parm                    $parms
     C                   parm                    pposeq
     C                   parm                    $phdte
     C                   parm                    $phloc
     C                   parm                    $pcert
     C                   parm                    $pprt
     C                   parm                    $pform
     C                   parm                    $saToLcns
     *
     C     tagfmtP       plist
     C                   parm                    $pcmd
     C                   parm      pwhse         $pwhs
     C                   parm                    ppo
     C                   parm                    pposeq
     C                   parm                    ppoitem
     C                   parm                    #rcvdesc
     C                   parm      $LNLCNS       $plic#
     C                   parm                    $pqty
     C                   parm                    $phdte
     C                   parm                    $phloc
     C                   parm                    $pcert
     C                   parm                    $plbl#
     C                   parm                    $pprt
     C                   parm                    $pform
     *----------------------------------------------------------------
     *  Main line
     *
      /free
        *inlr = *on;
        puser = %xlate(xlower: xupper: puser);
        w1lcns = %xlate(xlower: xupper: w1lcns);
        pprinter = %xlate(xlower: xupper: pprinter);
        // Get hold data
        hotype = 'PODTL';
        //pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X'));
700gA   select;
700gA     when pdone = 'U';
700gA       pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X')) + %trim(pPOItem)
700gA             + 'UCIHOLD';
700gA     other;
            pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X')) + %trim(pPOItem);
700gA   endsl;
        chain(n) (psessid: hotype: pokey) pirhold;
        if %found(pirhold);
          pirhldpods = hodata;
        else;
        endif;

740bA   // Get ASN hold data if lpn exist
740bA   if $pLpn <> *blanks;
740bA     hotype = 'PODTLASN';
740bA     pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X')) + %trim(pPOItem);
740bA     chain(n) (psessid: hotype: pokey) pirhold;
740bA     if %found(pirhold);
740bA       pirhldasds = hodata;
740bA     else;
740bA       phmfgd=0;
740bA       phexpd=0;
740bA     endif;
740bA   endif;

        exsr zzinz2;

        select;
          // if a license was entered do edits before completion
          when pdone = 'Y' and w1lcns <> ' ';
          // do final check on qty and pallet totals
700gD     //when pdone = 'Y';
700gM     when pdone = 'Y' or pdone = 'U';
            exsr editdone;
700lA       if error = *off;
700lA         // Do some clean up before leaving.
700lA         exsr zzwodltjob;
700lA       endif;
          // otherwise edit/process the license just entered
          other;
            exsr edit;
        endsl;

      /end-free
     *
     *
     *   Do some clean up before leaving.
     *
700lDC*                  exsr      zzwodltjob
     C                   return
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  Edit -  Edit
     *
     C     edit          begsr
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endedit
     C                   exsr      zzupd1
      /free
        // if user is done do final edits and post
        if opt = 'Y';
          exsr EditDone;
        endif;
      /end-free
     C     error         cabeq     *on           endedit
     *
     *
     *
     *  Everything went fine so get out of program.
     *
     *
     C     endedit       endsr
     *----------------------------------------------------------------
     *
     *  EditDone - Do final edits
     *
     C     editdone      begsr
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchkdone
     C     error         cabeq     *on           endeditdone
     C                   exsr      zzupddone
     C     error         cabeq     *on           endeditdone
     *
700jAC                   exsr      zzrcvpoclose
720cA /free
720cA   hotype = 'PODTL';
720cA   pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X')) + %trim(pPOItem);
720cA   chain (psessid: hotype: pokey) pirhold;
720cA   if %found(pirhold);
720cA     pirhldpods = hodata;
720cA     savetrn = 0;
720cA     hodata = pirhldpods;
720cA     update horec;
720cA   else;
720cA   endif;
720cA /end-free
     C     endeditdone   endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
      /free
        // call user added initialization routine.
        exsr zzinz;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------



     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   endsr
     *----------------------------------------------------------------
     *      0105s
     *
     C     zm0105s       begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0201  Code must be entered for create.
     *
     C     zm01          begsr
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   endsr
     *----------------------------------------------------------------
     *    PO20033  License # required.
     *
     C     zm033         begsr
     C                   eval      #msgid = 'PO20033'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    PO20034  License already exists.
     *
     C     zm034         begsr
     C                   eval      #msgid = 'PO20034'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    PO23601  Total qty must equal total qty received.
     *
     C     zm036         begsr
     C                   eval      #msgid = 'PO23601'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7871  Error in writing a record.
     *
     C     zm7871        begsr
     C                   eval      #msgid = 'PIR7871'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7872  Error in updating a record.
     *
     C     zm7872        begsr
     C                   eval      #msgid = 'PIR7872'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   eval      #msgid = 'PIR7972'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7973  Slot record does not exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Slot record is locked.
     *
     C     zm74          begsr
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0113  Field 1 must be greater than or equal to field 2.
     *
     C     zm0113        begsr
     C                   eval      #msgid = 'PIR0113'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   endsr
     *----------------------------------------------------------------
     *   IT11021  Invalid item type entered.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'IT11021'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
      /free
700bA   if paction = 'D';
700bA     leavesr;
700bA   endif;
        error = *off;
        exsr zzrcvpocheck;

        totqty = 0;
        t1qty = 0;
        t2qty = 0;
        t3qty = 0;

        lcns = *blanks;
        eruom = *blanks;

        // set cross dock indicators.
        if w1xdk = 'Y';
          *in69 = *on;
        else;
          *in69 = *off;
        endif;
      /end-free
     *
     *  Only do checks for non-cross dock records.
     *
     C                   if        w1xdk <> 'Y'
     *
700iD*  Only do checks if license option is used.
700iDC*moved down        if        lflag = *on
     *
     *  Qty must be entered.
      /free
        if w1qty = 0;
          pMessage = 'Qty Must be entered';
          error = *on;
          return;
        endif;
      /end-free
     *
     *  Qty can't be greater than qty received
      /free
        select;
          when w1uom = w1um1 and w1qty > w1qrc1
           or  w1uom = w1um2 and w1qty > w1qrc2
           or  w1uom = w1um3 and w1qty > w1qrc3;
            pMessage = 'Qty Must Match Received Qty';
            error = *on;
            return;
        endsl;
      /end-free
     *
     *  Total qty for uom can't exceed received qty
      /free
        totqty = 0;

        // get the previously entered licenses for accumulated qty
700cA   LicenseCnt = 1;
700kA   UOMCnt = 0;
        hotype = 'POLCNS';
        setll (psessid: hotype) pirhold;
        dow not %eof(pirhold);
          reade (psessid: hotype) pirhold;
          if %eof(pirhold);
            leave;
          endif;
          pirhllcnds = hodata;
700bA     // exclude the license being updated
700bA     if hokey = w1lcns;
700bA       iter;
700bA     endif;
          if h1uom = w1uom;
            totqty = totqty + h1qty;
          else;
            iter;
          endif;
700cA     LicenseCnt = LicenseCnt + 1;
        enddo;
        select;
          when w1uom = w1um1 and w1qrc1 < (totqty + w1qty)
           or  w1uom = w1um2 and w1qrc2 < (totqty + w1qty)
           or  w1uom = w1um3 and w1qrc3 < (totqty + w1qty);
            pMessage = w1uom +' Qty is greater than '+ w1uom + ' received';
            error = *on;
            return;
700cA     when w1uom = w1um1 and w1qrc1 <= (totqty + w1qty)
700cA      and w1plts <> LicenseCnt
700cA      or  w1uom = w1um2 and w1qrc2 <= (totqty + w1qty)
700cA      and w1plts <> LicenseCnt
700cA      or  w1uom = w1um3 and w1qrc3 <= (totqty + w1qty)
700cA      and w1plts <> LicenseCnt;
700cA       pMessage = 'Number of pallets does not match pallets received';
700cA       error = *on;
700cA       return;
        endsl;
      /end-free
700iM*  Only do checks if license option is used.
700iMC                   if        lflag = *on
     *
     *  License # must be entered if a qty is entered.
      /free
        if w1qty <> 0  and
           w1lcns = *blanks;
          pMessage = 'License must be entered';
          error = *on;
          return;
        endif;
      /end-free
     *
     *  Left justify license.
     C                   eval      $cstr = *blanks
     C                   move      w1lcns        $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFTNOZ'    $ccmd             8
     C                   parm                    $cstr            30
     C                   movel     $cstr         w1lcns
     *
     C                   eval      *in81 = *off
     C                   select
     C                   when      client = glazier
CPJ AC                             or client = cpj
     C     GLZvalid      check     w1lcns                                 81
     C                   other
     C     valid         check     w1lcns                                 81
     C                   endsl
     *
     *  *IN81 = *ON - One of the positions did not have valid value
     *
      /free
        if *in81;
          pMessage = 'Invalid Value for License';
          error = *on;
          return;
        endif;
      /end-free
     *
     *  If springfield verify license is 7 numeric long
     *
     C                   if        client = sgc
     C                   eval      chklcns = w1lcns
     C                   if        chkoss2 <> 'OS'
     C     SGCvalid      check     chk7lcns                               81
      /free
        if *in81 or chk8lcns<>*blanks;
          pMessage = 'Invalid Value for License';
          error = *on;
          return;
        endif;
      /end-free
     C                   endif
     C                   endif
WSFaA*
WSFaAC                   if        client = WestSide
WSFaAC                   eval      WSFlcns = w1lcns
WSFaAC                   if        WSF99I  <> 'OS'
WSFaAC     WSFvalid      check     WSF7lcns                               81
WSFaAC                   if        *in81 or WSF8lcns<>*blanks
WSFaAC                   eval      error = *on
WSFaAC                   eval      pMessage =  'Invalid Value for License'
WSFaAc                   return
WSFaAC                   endif
WSFaAC                   endif
WSFaAC                   endif
     *
     *  If Get Fresh, verify license begins with 'G'.
     *
      /free
        if client = getfresh;
          if %subst(w1lcns:1:1) <> 'G'
GFSaA        and %subst(w1lcns:1:1) <> 'F'
GFSaA        and %subst(w1lcns:1:1) <> 'K';
            pMessage = 'Invalid Value for License';
          error = *on;
            return;
          endif;
        endif;
      /end-free
     *
FPRa *
FPRa *  If Food Pro, verify license begins with 'F' or 'R'
FPRa *
FPRaAC                   if        client = FoodPro
FPRaA*
FPRaAC                   if        %subst(w1lcns:1:1) <> 'F' and
FPRaAC                             %subst(w1lcns:1:1) <> 'R'
FPRbAC                             and %subst(w1lcns:1:1) <> 'P'
FPRaAC                   eval      error = *on
FPRaAC                   eval      pMessage = 'Invalid Value for License'
     C                   return
FPRaAC                   eval      errmsg = desc(10)
FPRaAC                   endif
FPRaA*
FPRaAC                   endif
     *  ICB - Default license if F9 was taken for OSS license.
      /free
        select;
          when client = icb or
740cA          client = isupply;
740cD       //if w1lcns = 'OSS' and icblcns = *on;
740cD         //w1lcns = icbolcn;
            if w1lcns = 'OSS' and ossprint = 'Y';
              w1lcns = ' ';
            endif;
740cD       //if w1lcns = 'OSS' and icblcns = *off;
740cD         //pMessage = 'License Exist';
740cD         //error = *on;
740cD         //return;
740cD      //endif;
        endsl;
      /end-free
     C                   if        w1lcns <> *blanks
700bAc                             and paction = 'A'
      /free
        // License # must be unique
        exec sql select * into :lirec
           from license
           where lilcns = :w1lcns;
        If sqlstt = sqlSuccess;
          pMessage = 'License already exists';
          error = *on;
          return;
        endif;

      /end-free
     *
     *  Check LICLOG before accepting this license
     *
      /free
        if error = *off;
          exsr clr$license;
          $liToLcnsU = *on;
          $liToLcns = w1lcns;
          $liOLcnsU = *on;
          $liOLcns = w1lcns;
          $dricommand = '*LICENSE';
          $drisubcmd  = '%GETINFO';
          $drisys2upd = 'D';
          ck4err = *off;
          exsr zzzdricop;
          // ok on the return means it exist - don't use
          if $drireturn = '*OK' and $liToAisl <> 'OSS';
            pMessage = 'License already exists';
            error = *on;
            return;
          endif;
        endif;
      /end-free

710bA*
710bA*  Check LICINFO before accepting this license
710bA*
710bA /free
710bA   if error = *off;
710bA     exsr clr$licinfo;
710bA     $lnwhse  = pwhse;
710bA     $lnlcns = w1lcns;
710bA     $dricommand = '*LICINFO';
710bA     $drisubcmd  = '%GET';
710bA     $drisys2upd = 'D';
710bA     ck4err = *off;
710bA     exsr zzzdricop;
710bA     // if it exist don't allow to use.
710bA     if $drireturn = '*OK';
710bA       error = *on;
710bA       pMessage = 'License already exists';
710bA       return;
710bA     endif;
710bA   endif;
710bA /end-free
     *  If license found in licactive,
     *    then it must be an unused oss license.

      /free
        exsr zzchkoss;
        if lcnsExists and not ossLcns;
          pMessage = 'License ('
                   + %trim(w1lcns)
                   + ') already used';
          error = *on;
          return;
        endif;
      /end-free

     *  'OS' license must exist in LICACTIVE file.
     *  It would have been created with F9 label printing.
     *  If it doesn't exist then user probably backed out after
     *  printing, then got back in and is trying to use it.

      /free
        if %subst(w1lcns:1:2) = 'OS'
           and not lcnsExists;
          pMessage = 'Old OSS tag ('
                   + %trim(w1lcns)
                   + '), toss and print new one';
          error = *on;
          return;
        endif;
      /end-free

     *
     *     Verify user hasn't scanned same license# multiple times.
     *
      * this will check against the pirhold file
      * records are written there as they are scanned from Gui
        // check pirhold file to make sure user has not scanned license
      /free
        hotype = 'POLCNS';
        pokey = w1lcns;
        chain(n) (psessid: hotype: pokey) pirhold;
        if %found(pirhold);
          pMessage = 'License already exists';
          error = *on;
          return;
        endif;
      /end-free
     C                   endif
     C                   endif
     *
     C                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  ZZCHKdone final edits when user says they are done
     *
     C     zzchkdone     begsr
      /free
        error = *off;
        exsr zzrcvpocheck;

        totqty = 0;
        t1qty = 0;
        t2qty = 0;
        t3qty = 0;

        // get the previously entered licenses for accumulated qty
700cA   LicenseCnt = 0;
700kA   UOMCnt = 0;
        hotype = 'POLCNS';
        setll (psessid: hotype) pirhold;
        dow not %eof(pirhold);
          reade (psessid: hotype) pirhold;
          if %eof(pirhold);
            leave;
          endif;
700cA     LicenseCnt = LicenseCnt + 1;
          pirhllcnds = hodata;
          totqty = totqty + h1qty;
          reccnt = reccnt + 1;
          select;
            when h1umt = 'N';
              t1qty = t1qty + h1qty;
            when h1umt = '1';
              t2qty = t2qty + h1qty;
            other;
              t3qty = t3qty + h1qty;
          endsl;
        enddo;
700kA   // determine UOMCnt value
700kA   if w1qrc1 > 0;
700kA     UOMCnt = UOMCnt + 1;
700kA   endif;
700kA   if w1qrc2 > 0;
700kA     UOMCnt = UOMCnt + 1;
700kA   endif;
700kA   if w1qrc3 > 0;
700kA     UOMCnt = UOMCnt + 1;
700kA   endif;
        select;
760bA      when UOMCnt = 0;
760bA       pMessage = 'UOMCnt cannot be 0';
760bA       error = *on;
760bA       return;

700kD      //when LicenseCnt <> w1plts
700cA      when (LicenseCnt/UOMCnt) <> w1plts
700eA           and PSRcvReq <> 'Y' and psrusr <> 'Y';
700cA       pMessage = 'License Count must equal pallets Received';
700cA       error = *on;
700cA       return;
          // Break2 uom
          when t3qty <> w1qrc3
730bA          and PSRcvReq <> 'Y' and psrusr <> 'Y';
            pMessage = 'Total Qty must equal qty Received';
            error = *on;
            return;
          // break1 uom
          when t2qty <> w1qrc2
730bA          and PSRcvReq <> 'Y' and psrusr <> 'Y';
            pMessage = 'Total Qty must equal qty Received';
            error = *on;
            return;
          // Normal Uom
          when t1qty <> w1qrc1
730bA          and PSRcvReq <> 'Y' and psrusr <> 'Y';
            pMessage = 'Total Qty must equal qty Received';
            error = *on;
            return;
          // Total Qty
          when totqty <> ptqty
730bA          and PSRcvReq <> 'Y' and psrusr <> 'Y';
            pMessage = 'Total Qty must equal qty Received';
            error = *on;
            return;
        endsl;

        // Quantities entered must equal total quantity
        // Total UOM - changed to use lowest UOM qty for compare.
        if #rcvumq2 = 0;
          lowumq2 = 1;
        else;
          lowumq2 = #rcvumq2;
        endif;
        if #rcvumq3 = 0;
          lowumq3 = 1;
        else;
          lowumq3 = #rcvumq3;
        endif;
        lwtqty = (t1qty * lowumq2 * lowumq3)
               + (t2qty * lowumq3)
               + t3qty;
        wtlqty = (w1qrc1 * lowumq2 * lowumq3                           )
               + (w1qrc2 * lowumq3)
               + w1qrc3;

        select;
          when lwtqty <> wtlqty
730bA          and PSRcvReq <> 'Y' and psrusr <> 'Y';
            pMessage = 'Total Qty must equal qty Received';
            error = *on;
            return;
        endsl;
      /end-free
     *
     C     endckdone     endsr
     *----------------------------------------------------------------
     *
     *  ZZCHKOSS   Check if license is an OSS license
     *
     C     zzchkoss      begsr
     C                   eval      lcnsExists = *off
     C                   eval      ossLcns = *off

     *  See if license exists in licactive file.

     C                   exsr      clr$license
     C                   eval      $liToLcnsU = *on
700bDC*                  eval      $liToLcns = hokey
700lA * When opt = Y we are processing the pirhold records
700lA * otherwise we are editting the licenses as they are entered.
700lAc                   if        opt = 'Y'
700lAC                   eval      $liToLcns = hokey
700lAC                   else
700bMC                   eval      $liToLcns = w1lcns
700lAC                   endif
     C                   eval      $dricommand = '*LICENSE'
     C                   eval      $drisubcmd  = '%GETLCNS'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      zmflag  = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      lcnsExists = *off
     C                   eval      error = *off
     C                   leavesr
     C                   else
     C                   eval      lcnsExists = *on
     C                   endif

     *  Now see if it is an unused oss license.

     C                   if        $liToAisl <> 'OSS'
     C                             or $liToCode <> 'D'
     C                             or $liToItem <> ppoitem
     C                             or $liToRQty1 <> 0
     C                             or $liToRQty2 <> 0
     C                             or $liToRQty3 <> 0
     C                   eval      ossLcns = *off
     C                   else
     C                   eval      ossLcns = *on
     C                   endif

     C                   endsr
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *
     *  ZZCRXD   Use DRISLOT with %CRTXDOCK to get existing cross
     *           dock slot or create new one.
     *
     C     zzcrxd        begsr
     *
     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #rcvwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = savdsp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = #rcvitem
     C                   eval      $slaislu = *on
710cAc                   eval      $slexpd = $rexpd
710cAc                   eval      $slexpdu = *on
     C                   if        client = CoastalSunbelt
     C                             and sv_pdspcl = 'XD'
CSPaAC                   if        $itdesg = 'PC'
CSPaAC                   eval      $slaisl = ' PC'
CSPaAC                   else
     C                   eval      $slaisl = 'JIT'
CSPaAC                   endif
     C                   else
     C                   eval      $slaisl  = 'XDK'
     C                   endif
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd = '%CRTXDOCK'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error = *on
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT3   Get default values for add.
     *
     C     zzdft3        begsr
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZEXTSTGNEW  New Oss Receiving
     *
     C     zzextstgnew   begsr
     C                   eval      $ewhdp = #rcvwhdp
     C                   eval      ossdev = '*JOB'
     C*                  eval      w3stg  = osscode
     C                   eval      ossplates = 1

     *  Springfield setup defaults for screen

     *  May need to use the setup of w3dev for sgc - come back
     C                   if        client = sgc
     *  Protect stage field
     C                   eval      *in95 = *on
     C                   if        $ewhdp = 'DRY  '
     C                   eval      ossdev = 'LP8'
     C                   else
     C                   eval      ossdev = 'LP7'
     C                   endif
     C                   endif

     *  Eastland setup defaults for screen

     C                   if        client = eastland
     *  Protect stage field
     C                   eval      *in95 = *on
     C                   if        $ewhdp = 'CB   '
     C                   else
     C                   endif
     C                   endif

     *  Process

     C                   dow       forevr = forevr

     C                   eval      *in92 = *off
     C                   eval      *in93 = *off
     C                   eval      *in94 = *off
     C                   eval      *in95 = *off

     *     No errors, create slots

     C                   eval      extstgFlag = *on
     C                   for       i = 1 to ossplates
     C                   exsr      zzextstg2New
     C                   eval      icblcns = *off
     C                   eval      icbolcn = *blanks
     C                   if        error
     C                   leave
     C                   endif
     C                   if        client = icb
740cAc                             or client = isupply
     C                   eval      icbolcn = hokey
     C                   eval      icblcns = *on
     C                   endif
     C                   endfor
     C                   leave

     C                   enddo

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZEXTSTG2New  Create OSS slot
     *
     C     zzextstg2New  begsr

     *  Set #rcvarea to apppropriate OSS area.

     C                   select

     C                   when      client = sgc
     C                             and osscode = 'K'
     C                   eval      #rcvarea = 'KANSAS'

     C                   when      client = sgc
     C                             and osscode = 'W'
     C                   eval      #rcvarea = 'WILLOW'

     C                   when      client = eastland
     C                             and osscode = 'G'
     C                   eval      #rcvarea = 'CGEN'

     C                   when      client = eastland
     C                             and osscode = 'F'
     C                   eval      #rcvarea = 'CFROZ'

     C                   other
     C                   eval      #rcvarea = osscode

     C                   endsl

     *  Initialize slot fields

     c*                  eval      wklic = w1lcns
     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #rcvwhdp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = #rcvitem
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = ' '
     C                   eval      $slstatu = *on
     C                   eval      $slstat  = w1stat
     C                   eval      $slstypu = *on
     C                   eval      $slstyp = #rcvstyp
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd = $rexpd
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = #rcvitem

     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = 0
     C                   eval      $saqty2 = 0
     C                   eval      $saqty3 = 0

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'OSS'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = 0
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saLbl#U = *on
     C                   eval      $saLbl# = 0
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = 1
     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'N'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'D'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = #rcvarea

     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = hokey
     C                   eval      $saOLcnsU = *on
     C                   eval      $saOLcns = hokey

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%OSSIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      zmflag  = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   leavesr
     C                   endif

     *  Create workoss record

     C                   eval      wowhse  = $slwhse
     C                   eval      wowhdp  = $slwhdp
     C                   eval      wodisp  = $sldisp
     C                   eval      wolcns  = hokey
     C                   eval      woaddts   = %timestamp()
     C                   eval      woaddcusr = puser
     C                   eval      woaddjob  = #job
     C                   eval      woaddnbr  = #jobnbr
700lAC                   eval      wosess    = pSessId
     C                   write(e)  worec

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *
     *   Move qtys
     *
     C                   eval      rpal = w1plts
     *
     *   Increment # of Pallets if multiple units of measure received.
     *
     C                   eval      pctr = 0
     C                   if        w1qrc1 <> 0
     C                   add       1             pctr
     C                   endif
     C                   if        w1qrc2 <> 0
     C                   add       1             pctr
     C                   endif
     C                   if        w1qrc3 <> 0
     C                   add       1             pctr
     C                   endif
     C                   if        pctr > 0
     C                   eval      pctr = pctr - 1
     C                   add       pctr          rpal
     C                   endif
     *   Allow license field entry and display.
     *
     C                   eval      xdkflg = *off
     C                   If        pdspcl = 'XD'
710eAc                             or w1stat = 'XD'
     C                   if        xdkflg = *off
     C                   exsr      zzpxdk
     C                   eval      xdkflg = *on
     C                   endif
     c                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr

      * get item category

     C                   call      'GETICAT'
     C                   parm      pwhse         $pwhs
     C                   parm                    ppoitem
     C                   parm                    $pcode
     C                   parm                    $phhdr
     C                   parm                    $phdtl
     C                   parm                    $phcat

     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr

      /free
760aD   //getclient(client: clientLoc);
760aM   getclient(client: clientLoc: clientint: clienthost);
      /end-free
     *  Define key for LABEL2  file.
     *
409 AC     lbkey         klist
409 MC                   kfld                    $lord
409 AC                   kfld                    pwhse
     *
     *  Define key for CrossDk2 file.
     *
     C     keycd2        klist
     C                   kfld                    pwhse
     C                   kfld                    ppo
     C                   kfld                    pposeq
     *
     *  Define key for slot10 file.
     *
     C     keys10        klist
     C                   kfld                    pwhse
     C                   kfld                    ppoitem
     C                   kfld                    kystat
     *
     *  Define partial key for SLOT3 file.
     *
     C     keys3b        klist
     C                   kfld                    pwhse
     C                   kfld                    ppoitem
     C                   kfld                    k3stat
     *
     *  Define partial key for SLOT3 file.
     *
     C     keys3         klist
     C                   kfld                    pwhse
     C                   kfld                    ppoitem
     C                   kfld                    k3stat
     C                   kfld                    k3pick
     *
     *  Define partial key for WORKOSS1 file.
     *
     C     keywo1        klist
     C                   kfld                    puser
     C                   kfld                    #job
     C                   kfld                    #jobnbr
     *
     *  Variables and constants.
     *
     C                   eval      forevr = *off
     *  Get Feature option.
      /free
        ocode = '*FEATURE';
        exec sql select * into :oprec
             from options
             where opwhse = :pwhse
               and opcode = :ocode;

        If sqlstt = sqlSuccess;
          opdat3 = opdata;
        else;
          opfeat = '2';
        endif;
        if opfeat = '1';
          locatr = *on;
        else;
          locatr = *off;
        endif;
      /end-free
     *  Get System option.
      /free
        ocode = '*SYSTEM ';
        wkwhse = 0;
        exec sql select * into :oprec
             from options
             where opwhse = :wkwhse
               and opcode = :ocode;

        If sqlstt = sqlSuccess;
          opdat4 = opdata;
        else;
          opuci = 'N';
        endif;

        $lprg = #pgm;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
      /free
        // get current date in century format
        $cvcmd = '*CURCMD';
        cvtdte($cvtdt);
        today = $cvd8o;

        // convert todays date into mmddyy format.
        $cvcmd = '*CURMDY';
        cvtdte($cvtdt);
        today6 = $cvd6o;

        // Initialize quatity left.
        q1lft = w1qrc1;
        q2lft = w1qrc2;
        q3lft = w1qrc3;

        // Initialize variables
        need1 = 0;
        need2 = 0;
        need3 = 0;
        pctr = 0;
        l = *zeros;
        lcns = *blanks;

        // Get total quantity
        ptqty = w1qrc1 + w1qrc2 + w1qrc3;
        // grab po header file
        exec sql select * into :phrec1
           from pohdr
           where phwhse = :pwhse
             and phpo   = :pPo;

      /end-free

     *
     *   Save PDSPCL.  If it's 'XD', it's a cross dock item.
     *
      /free
        sv_pdspcl = ' ';
        chain(n) (pwhse: ppo: pposeq: ppoitem) podtl;

        if %found(podtl);
          if client = dairyland;
            sv_pdspcl = ' ';
          else;
            sv_pdspcl = pdspcl;
          endif;
        endif;
710eA   if w1stat = 'XD';
710eA       sv_pdspcl = 'XD';
710eA   endif;
      /end-free
     *
     *   Get item description.
     *
     C*                  exsr      zzxopt
     *

     *  Use DRI interface to get item.

     C                   exsr      clr$item
     C                   eval      $itwhse  = pwhse
     C                   eval      $ititem  = ppoitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETALL'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   clear                   #rcvitem
     C                   clear                   #rcvtype
     C                   clear                   #rcvdesc
     C                   clear                   #rcvpdsc
     C                   clear                   #rcvwhdp
     C                   clear                   #rcvstyp
     C                   clear                   #rcvdesg
     C                   clear                   #rcvum1
     C                   clear                   #rcvflg1
     C                   clear                   #rcvum2
     C                   clear                   #rcvumq2
     C                   clear                   #rcvflg2
     C                   clear                   #rcvum3
     C                   clear                   #rcvumq3
     C                   clear                   #rcvnrpk
     C                   clear                   #rcvmflg
     C                   clear                   #rcvdday
     C                   clear                   #rcvmday
     C                   clear                   #rcvuday
     C                   clear                   #rcvflgd
     C                   clear                   #rcvcube
     C                   clear                   #rcvswgt
     C                   clear                   #slotitem
     C                   clear                   #slottype
     C                   clear                   #rcvcwgt
     C                   goto      enditm
     C                   endif

     *       If this item has a designation code of JIT, populate
     *       pdspcl and sv_pdspcl with 'XD' so that it will be
     *       updated and treated as a cross dock item.
     C                   if        client = CoastalSunbelt
CSPaDC*                            and $itdesg = 'JIT  '
CSPaMC                             and ($itdesg = 'JIT  ' or $itdesg = 'PC')
     C                   eval      pdspcl = 'XD'
     C                   eval      sv_pdspcl = 'XD'
     C                   endif

700hA * check for branded item
700hA /free
700hA   BrandReq = ' ';
700hA   bCmd = '*GETFLAG';
700hA   bBrand = ' ';
700hA   bBrandItm = ' ';
700hA   bBrandFlg = ' ';
700hA   GetBranded(bCmd: pwhse: ppoItem: bBrand: bBrandItm: bBrandFlg) ;
700hA     BrandReq = bBrandFlg;
700hA /end-free

700hAc                   If        BrandReq = 'Y'
700hAC                   eval      #rcvitem = BrandedItm
700hAc                   else
     C                   eval      #rcvitem = $ititem
700hAc                   endif
     C                   eval      #rcvtype = $ittype
     C                   eval      #rcvdesc = $itdesc
     C                   eval      #rcvpdsc = $itpdsc
     C                   eval      #rcvwhdp = $itwhdp
     C                   eval      #rcvstyp = $itstyp
     C                   eval      #rcvdesg = $itdesg
     C                   eval      #rcvum1  = $itum1
     C                   eval      #rcvflg1 = $itflg1
     C                   eval      #rcvum2  = $itum2
     C                   eval      #rcvumq2 = $itumq2
     C                   eval      #rcvflg2 = $itflg2
     C                   eval      #rcvum3  = $itum3
     C                   eval      #rcvumq3 = $itumq3
     C                   eval      #rcvnrpk = $imnrpk
     C                   eval      #rcvmflg = $immflg
     C                   eval      #rcvdday = $imdday
     C                   eval      #rcvmday = $immday
     C                   eval      #rcvuday = $imuday
     C                   eval      #rcvflgd = $itflgd
     C                   eval      #rcvcube = $itcube
     C                   eval      #rcvswgt = $itswgt
     C                   eval      #rcvcwgt = $itcwgt

     *  Halsey - Get item pick slot to display.
710dDC*                  if        client = halsey
710dDC*                            or client = egf
     C                   eval      k3stat = 'A '
     C                   eval      k3pick = 'Y'
     C     keys3         setll     slot3
     C     keys3         reade(n)  slot3                                  79
     C                   if        not *in79
     C                   move      sldisp        wodsc2
710dAC                   move      sldisp        $apslt
     C                   endif
710dDC*                  endif

     *  Use DRI interface to get Slot item.

     C                   exsr      clr$item
     C                   eval      $itwhse  = pwhse
     C                   eval      $ititem  = ppoitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETSLOT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   clear                   #slotitem
     C                   clear                   #slottype
     C                   endif

     C                   eval      #slotitem = $ititem
     C                   eval      #slottype = $ittype
     *
     C     enditm        tag
     *
     *  Get receiving options.
     *
      /free
        ocode = '*RCVLBL ';
        wkwhse = pwhse;
        exec sql select * into :oprec
             from options
             where opwhse = :wkwhse
               and opcode = :ocode;
        If sqlstt = sqlSuccess;
          optionrec = opdata;
        else;
          error = *on;
          pMessage = 'No Receiving options';
          return;
        endif;
      /end-free
     *
     *
     *    Get User's employee number to be written to PORCV file
     *    if any records are flagged as touched.
     *
     C                   call      'GETUSER'
     C                   parm      puser         $code            10
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
     *
     *
     *   Select first screen to display.
     *
     c                   exsr      zzget1
     c                   exsr      zzfil1
     *

     *  Get live status for item's department.

     C                   call      'CHKLIVE'
720eDC*                  parm      pwhse         $pwhs
720eMC                   parm      pwhse         whse
     C                   parm                    #rcvwhdp
     C                   parm                    livestat          8

     *  If department is not live, then post and get out.
     *  Or, if cross dock item, then post and get out.

      *  this is handled by the mainline
     C                   if        livestat = '*NOTLIVE'
     C                             or sv_pdspcl = 'XD'
     C                   endif

     C     endint        endsr

     *----------------------------------------------------------------
     *  ZZLICINFONew Update New format of LICINFO
     *----------------------------------------------------------------

      /free
        begsr zzlicinfonew;

          // first I need to deal with the cross dock licinfo and uciinfo
          if $pgslcns <> ' ' and h1xdk = 'Y';
            exsr zzxdktemplcns;
          endif;
700dA     // check for temporaty T license for detail CW in uciinfo
700dA       exsr zzcwtemplcns;
          // Write out standard license information
          exsr clr$licinfo;
          $lnwhse  = pwhse;
          select;
            when directed = 'Y';
              $lnlcns  = hokey;
            when PSRcvReq = 'Y';
              $lnlcns  = lilcns;
            when psrusr = 'Y';
              $lnlcns  = lilcns;
            other;
            $lnlcns  = $saToLcns;
          endsl;
          $lnseq = 1;

          // $PGSLCNS SHOULD BE POPULATED IF CALL FROM THE UCI/GSI RECEIVING
          // Need to get existing record so we don't overlay lnseqqty
          if $pgslcns <> ' ';
          $dricommand = '*LICINFO';
          $drisubcmd  = '%GET';
          $drisys2upd = 'D';
          ck4err = *on;
          exsr zzzdricop;
          endif;
          if error;
            gs1seqqty = 0;
          else;
            gs1seqqty = $lnseqqty;
          endif;

          exsr clr$licinfo;
          $lnwhse  = pwhse;
          select;
            when directed = 'Y';
              $lnlcns  = hokey;
            when PSRcvReq = 'Y';
              $lnlcns  = lilcns;
            when psrusr = 'Y';
              $lnlcns  = lilcns;
            other;
            $lnlcns  = $saToLcns;
          endsl;

          $lnseq = 1;
          $lnpo = ppo;
          $lnposeq = pposeq;
720gD     //if $ifrcvmth = ' ' or $ifrcvmth = '1';
720gM     if $ifrcvmth = ' ' or $ifrcvmth = '1' or
720gA        $ifrcvmth = '4' or $ifrcvmth = '5' or
720gA        $ifrcvmth = '6';
            $lnseqqty = h1qty;
          else;
            $lnseqqty = gs1seqqty;
          endif;
700hA     if BrandReq = 'Y';
700hA       $lnitem = BrandedItm;
700hA     else;
            $lnitem = ppoitem;
700hA     endif;
          // LNRCVTYP notes
          // 1 = Manual quantity (original method)
          // 2 = Manual quantity with initial GS1 scan
          // 3 = UCI using Mfg GS1 barcodes
          // 4 = UCI using Internal GS1 barcodes (start with 99)
          // 5 = ASN file

          select;
            when $plpn <> ' ';
              $lnrcvtyp = '5';
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
          if directed = 'Y'
             or PSRcvReq = 'Y'
             or psrusr = 'Y';
            $lnrcvtrn# = h1trn;
            $lnrcvlbl# = h1lbl;
          else;
            $lnrcvtrn# = pttrn#;
            $lnrcvlbl# = lblbl#;
          endif;
          $lnrcvqty = h1qty;

          if woindt > 0;
            $lnentdate = woindt;
          endif;

          if w1fifo > 0;
            $lnenttype = '*FIFODT';
          else;
            if #rcvflgd = 'Y';
              select;
                when #rcvuday > 0 or
                     #rcvdday > 0;
                  if #rcvmflg = 'Y';
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

            $lndateflag = #rcvflgd;
            $lnmfgflag = #rcvmflg;

            $lnmfgdays = #rcvmday;
            $lnusrdays = #rcvuday;
            $lndstdays = #rcvdday;
          endif;

720iD     //$lnmfgdate = $pmfgdt;
720iM     $lnmfgdate = mfgdte;

720iD     //if mfgdte > 0;
720iD       //$lnmfgexp = mfgdte;
720iM     if mexpd  > 0;
720iM       $lnmfgexp = mexpd;
          endif;

          if w1fifo > 0;
            $lnfifodate = w1fifo;
          endif;

          if $rexpd > 0;
            $lnexpdate = $rexpd;
          endif;

          // Decipher Code
          if $ldecvalue > ' ';
            $lnmfgcode = $ldecvalue;
          endif;

750bA     // Only load these fields on the first license
750bA     if firstLcns = *off;
            $lnttllbs = w1twgt;

            if h1umt = 'N' and avgwt1 > 0
               or h1umt = '1' and avgwt2 > 0
               or h1umt = '2' and avgwt3 > 0;
              select;
                when h1umt = '1';
                  $lnavglbs = avgwt2;
                when h1umt = '2';
                  $lnavglbs = avgwt3;
                other;
                  $lnavglbs = avgwt1;
              endsl;
            endif;
750bA       firstLcns = *on;
750bA     endif;

          if W1lotc <> ' ';
            $lnlot = W1lotc;
          endif;

760aA     if clienthost = freshbyte;
760aA       $lnlot = %subst(pdpo:1:6) +
760aA                %subst(%EditC(pdseq:'X'):3:3);
760aA     endif;

          if W1brand <> ' ';
            $lnbrand = W1brand;
          endif;

         // Clam and Shucked information.
          if $pcode = Clams
             or $pcode = Shucked;

            if $phdte > 0;
              $lnhrvdate = $phdte;
            endif;

            if $phloc <> ' ';
              $lnhrvloc = $phloc;
            endif;

            if $pcert <> ' ';
              $lnhrvcert = $pcert;
            endif;
          endif;

          if $pgslcns = ' ';
            // calculate the PTI.
            if $pbclot <> ' ' and $pgtin <> ' ';
              pplot  = %subst($pbclot: 1 : 20);
              if w1pti = 0;
                calcpti ($pgtin: pplot: $pbcProdD: pppti);
              else;
                pppti = w1pti;
              endif;
              if pppti > 0
720dA            and $ifsltmth = '3';
                $lnlotPTI4 = %editc(pppti:'X');
                $lnlotPTI2 = %Subst(%EditC(pppti:'X'):3:2);
                k = 0;
                if $ifrcvmth <> '2';
                  dou k = $lnrcvqty;
                    k = k + 1;
                    exsr clr$uciinfo;
                    $uiWhse = pwhse;
                    $uiItem = ppoitem;
                    $uiuci = %trim(%editc(pppti:'X'));
                    ucilic#($unext: pwhse);
                    unexta = %editc($unext:'X');
                    $uiuciLcns = 'P:' + unexta;
                    if directed = 'Y'
                       or PSRcvReq = 'Y'
                       or psrusr = 'Y';
                      $uiLcns = hokey;
                    else;
                      $uiLcns = $saToLcns;
                    endif;
                    $uiseq = 1;
                    $uiSerial = ' ';
                    // weight is calculated as average
                    if h1umt = 'N' and avgwt1 > 0
                      or h1umt = '1' and avgwt2 > 0
                      or h1umt = '2' and avgwt3 > 0;
                      select;
                        when h1umt = '1';
                          $uiwgtlbs = avgwt2;
                        when h1umt = '2';
                          $uiwgtlbs = avgwt3;
                        other;
                          $uiwgtlbs = avgwt1;
                      endsl;
                    endif;
                    $uiSelTrn# = 0;
                    $uiSelLbl# = 0;
                    $uiSelOrd = 0;
                    $uiSelSeq = 0;
                    $uiSelCSeq = 0;
                    $uiSelTrax = ' ';
                    $uiCrtBy = '1';
720hA               if $pgtin = *blanks;
720hA                  $uiaGtin = 0;
720hA               else;
720hA                  $uiaGtin  = %DEC($pgtin:14:0);
720hA               endif;
720hA               workupc = blank6 + $pgtin;
720hA               uputyp     = 'N';
720hA               exec sql select * into :uprecuom
720hA                      from upc
720hA                      where upwhse = :pwhse
720hA                        and upITEM = :ppoitem
720hA                        and upupc  = :workupc
720hA                      fetch first row only;
720hA               $uiaUTyp  = uputyp;
720hA               $uiaSlUTyp = uputyp;
720hA               $uiaLot   = $pbclot;
720hA               $uiaExpD  = $lnexpdate;
720hA               $uiaEntD  = today;

                    $dricommand = '*UCIINFO';
                    $drisubcmd  = '%ADD';
                    $drisys2upd = 'D';
                    ck4err = *on;
                    zmflag  = *off;
                    exsr zzzdricop;
                  enddo;
                endif;
              endif;
            endif;

          endif;
          $dricommand = '*LICINFO';
          // $PGSLCNS SHOULD BE POPULATED IF CALL FROM THE UCI/GSI RECEIVING
          if $pgslcns = ' ';
            $drisubcmd  = '%ADDS';
          else;
            $drisubcmd  = '%CHANGES';
          endif;
          $drisys2upd = 'D';
          ck4err = *on;
          exsr zzzdricop;
          if error;
          endif;

        endsr;
      /end-free
     *----------------------------------------------------------------
NOTES*  ZZPOASN     Update poasn file
     *----------------------------------------------------------------

      *   THIS IS FOR LATER
     C     zzpoasn       begsr
      * check to make sure programs exist or don't allow this command
740bM * Un comment everything in this routine.  The other 740b mods
740bM *  done as we normally would
     c                   eval      qcmd = 'CHKOBJ '
     c                                  + 'OBJ(GETASN) '
     c                                  + 'OBJTYPE(*PGM)'
     C                   call      'QCMDEXC'                            78
     C                   parm                    qcmd            256
     C                   parm      80            qlen             15 5
     c                   if        *in78 = *off
     c                   if        $plpn <> *blanks
     c                   eval      $ascmd = '*PUTLCNS'
740bA /free
740bA       // flip date around for GETASN
740bA       monitor;
740bA         wkmfgdt = phmfgd;
740bA       on-error;
740bA         wkmfgdt=0;
740bA       endmon;
740bA
740bA       monitor;
740bA         wkexpdt = phexpd;
740bA       on-error;
740bA         wkexpdt=0;
740bA       endmon;
740bA
740bA       if PSRcvReq = 'Y'
740bA         or psrusr = 'Y';
740bA         $aslcns = lilcns;
740bA       else;
740bA         $aslcns = $saToLcns;
740bA       endif;
740bA
740bA /end-free
     c                   call      'GETASN'
     c                   parm                    $ascmd            8
     c                   parm      ' '           $asrtn            8
     c                   parm      pwhse         $aswhse           3 0
     c                   parm      ppo           $aspo             9
     c                   parm      $plpn         $asLPN           50
740bDc*                  parm      $saToLcns     $aslcns          15
740bMc                   parm                    $aslcns          15
740bDc*                  parm      $plotc        $aslot           20
740bMc                   parm      w1lotc        $aslot           20
     c                   parm      ppoitem       $asitem          15
740bDc*                  parm      $pseq         $asseq            5 0
740bMc                   parm      pposeq        $asseq            5 0
     c                   parm      0             $asqty            8 0
740bDc*                  parm      0             $asmfgdt          6 0
740bDc*                  parm      0             $asexpdt          6 0
740bMc                   parm      wkmfgdt       $asmfgdt          6 0
740bMc                   parm      wkexpdt       $asexpdt          6 0
     c                   parm      0             $aswgt           11 3
     c                   endif
     c                   endif
     C                   endsr
     *
     *----------------------------------------------------------------
     *
NOTES*  ZZPRDLBL   Produce label creation
     *
      ****** this will be addressed later in the project
     C     zzprdlbl      begsr
     C*****              eval      w4dev  = '*JOB'
     C*****              eval      w4lqty = ptqty

     *  Process window to produce license plates for external storage

     C*****              dow       forevr = forevr
     C*****              exfmt     Wprdlbl
     C*****              if        *inkl = *on
     C*****              leave
     C*****              endif

     C*****              eval      *in94 = *off

     *     Number of labels cannot be zero

     C*****              if        w4lqty = 0
     C*****              eval      *in94 = *on
     C*****              iter
     C*****              endif

     *     No errors, print labels

     *  Print label

     C*****              eval      $plfmt = 'PRODUCE'
     C*****              if        client = saval
     C*****              eval      $plset = 'ZBRSVL'
     C*****              else
     C*****              eval      $plset = 'PLBL40'
     C*****              endif
      *testing purpose
     C*****              eval      $plset = 'ZBRSVL'
      *
     C*****              if        w4dev <> '*JOB'
     C*****              eval      $pdev  = w4dev
     C*****              endif
     C*****              eval      sav$pcmd = $pcmd

     C*****              for       i = 1 to w4lqty

     C*****              call      'PRTLBL'
     C*****              parm      '*PRODUCE'    $pcmd             8
     C*****              parm                    $plset            6
     C*****              parm                    $plfmt            8
     C*****              parm      pwhse         $plwhse           3 0
     C*****              parm                    $pwhsd           30
     C*****              parm                    $slwhdp
     C*****              parm                    $sldisp
     C*****              parm                    $pdispa           1
     C*****              parm                    $pdispb          11
     C*****              parm                    $pchkd1           3
     C*****              parm                    $pchkd2           3
     C*****              parm                    $pchkd3           3
     C*****              parm                    w1lcns           15
     C*****              parm                    $plcn2           15
     C*****              parm                    $ititem
     C*****              parm                    $pbrnd           10
     C*****              parm                    $itpdsc          15
     C*****              parm                    $itdesc          30
     C*****              parm      ppo           $ptxt1           30
     C*****              parm                    $ptxt2           30
     C*****              parm                    $ptxt3           30
     C*****              parm                    $ptrailr          8
     C*****              parm                    $psize            3
     C*****              parm                    $pdev            10
     C*****              parm                    $pform           10
     C*****              parm                    $pexpda           8
     C*****              parm                    $pindta           8
     C*****              endfor
     C*****              leave

     C*****              enddo

     C*****              call      'PRTLBL'
     C*****              parm      '*PRODEND'    $pcmd
     C*****              parm                    $plset
     C*****              parm                    $plfmt
     C*****              parm      pwhse         $plwhse
     C*****              parm                    $pwhsd
     C*****              parm                    $slwhdp
     C*****              parm                    $sldisp
     C*****              parm                    $pdispa
     C*****              parm                    $pdispb
     C*****              parm                    $pchkd1
     C*****              parm                    $pchkd2
     C*****              parm                    $pchkd3
     C*****              parm                    w1lcns
     C*****              parm                    $plcn2
     C*****              parm                    $ititem
     C*****              parm                    $pbrnd
     C*****              parm                    $itpdsc
     C*****              parm                    $itdesc
     C*****              parm      ppo           $ptxt1
     C*****              parm                    $ptxt2
     C*****              parm                    $ptxt3
     C*****              parm                    $ptrailr
     C*****              parm                    $psize
     C*****              parm                    $pdev
     C*****              parm                    $pform
     C*****              parm                    $pexpda
     C*****              parm                    $pindta
     C*****              eval      $pcmd = sav$pcmd

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPXDK  Try to put item into cross dock slots.
     *
     C     zzpxdk        begsr
     *
     *  P.O. detail info must have been sent to program.
     *
     C     pposeq        cabeq     0             endpx
     *
     *   See if host is providing an xdock quantity.
     *
     C                   eval      xdkdri = *off
     C                   exsr      zzzx2d
     C                   eval      $dricommand = '*XDOCK'
     C                   eval      $drisubcmd  = '*GETQTY'
     C                   exsr      zzzdricop
     C                   if        $xdqty1 > 0  or
     C                             $xdqty2 > 0  or
     C                             $xdqty3 > 0
     C                   eval      xdkdri = *on
     C                   exsr      zzpxdr
     C                   goto      endpx
     C                   endif
     *
     *  Loop through any cross dock records for line item.
     *
     C                   eval      xdkupd = *off
     *  If this is not a cross dock item, get out.
     C                   if        sv_pdspcl <> 'XD'
     C                   goto      endpx
     C                   else
     *
     *  Get slot assigned to cross dock item.
     *
     C                   eval      kystat = 'XD'
     C     keys10        chain     slot10
710cA * We want to set the need quantites based on the quantites
710cA * sent in. And get out.
710cDC*                  if        not %found(slot10)
     C                   eval      need1 = w1qrc1
     C                   eval      need2 = w1qrc2
     C                   eval      need3 = w1qrc3
     C                   goto      endpx
710cDC*                  endif
     *
     *  Calculate qty still needed.
     *
     *  Call program to calculate available slot quantities.
     *
     C                   call      'SLOTQTY'
     C                   parm                    slstk1
     C                   parm                    slstk2
     C                   parm                    slstk3
     *
     C                   parm                    slalc1
     C                   parm                    slalc2
     C                   parm                    slalc3
     *
     C                   parm                    sltfr1
     C                   parm                    sltfr2
     C                   parm                    sltfr3
     *
     C                   parm                    slpck1
     C                   parm                    slpck2
     C                   parm                    slpck3
     *
     C                   parm                    slrcv1
     C                   parm                    slrcv2
     C                   parm                    slrcv3
     *
     C                   parm                    stock1            5 0
     C                   parm                    stock2            3 0
     C                   parm                    stock3            3 0
     *
     C                   parm                    avail1            5 0
     C                   parm                    avail2            3 0
     C                   parm                    avail3            3 0
     *
     *   With cross docks, quantity is needed if the available qty
     *   is negative.  Cross dock slots are the only slots that allow
     *   the available quantity to go negative.
     *
     C                   if        avail1 >= 0
     C                   eval      need1 = 0
     C                   else
     C                   eval      need1 = -(avail1)
     C                   endif
     C                   if        avail2 >= 0
     C                   eval      need2 = 0
     C                   else
     C                   eval      need2 = -(avail2)
     C                   endif
     C                   if        avail3 >= 0
     C                   eval      need3 = 0
     C                   else
     C                   eval      need3 = -(avail3)
     C                   endif
     *
     *   For TPC, set needed quantity to qty received.
     *   For SGC, set needed quantity to qty received.
     *   For RYL, set needed quantity to qty received.
     *   Re: We want everything to go into XDK slot.
     *   Change of plans: do this for EVERYONE now.
     *
     C                   eval      need1 = q1lft
     C                   eval      need2 = q2lft
     C                   eval      need3 = q3lft
     *
     *   Get out if nothing needed.
     *
     C                   if        need1 = 0  and
     C                             need2 = 0  and
     C                             need3 = 0
     C                   goto      endpx
     C                   endif
     *
     *   Make sure breakdown qty's are not greater than unit of
     *   measure quantity.
     *
     C                   dow       need3 >= #rcvumq3  and
     C                             #rcvumq3 <> 0
     C                   eval      need3 = need3 - #rcvumq3
     C                   add       1             need2
     C                   enddo
     *
     C                   dow       need2 >= #rcvumq2  and
     C                             #rcvumq2 <> 0
     C                   eval      need2 = need2 - #rcvumq2
     C                   add       1             need1
     C                   enddo
     *
     *   Receive needed quantity.
     *   If breakdown quantity is needed and a corresponding breakdown
     *   qty is being received, then take it.
     *   If breakdown quantity is needed but a corresponding breakdown
     *   qty is not being received, then increase the qty needed by
     *   the next larger breakdown by 1. We don't want the receivers
     *   to breakdown boxes.  That job is left for the selectors.
     *
     C                   if        need3 > 0
     C                   select
     C                   when      q3lft = 0
     C                   add       1             need2
     C                   eval      need3 = 0
     C                   when      need3 <= q3lft
     C                   eval      q3lft = q3lft - need3
     C                   other
     C                   add       1             need2
     C                   eval      need3 = 0
     C                   endsl
     C                   endif
     *
     C                   if        need2 > 0
     C                   select
     C                   when      q2lft = 0
     C                   add       1             need1
     C                   eval      need2 = 0
     C                   when      need2 <= q2lft
     C                   eval      q2lft = q2lft - need2
     C                   other
     C                   add       1             need1
     C                   eval      need2 = 0
     C                   endsl
     C                   endif
     *
     C                   if        need1 > 0
     C                   select
     C                   when      need1 <= q1lft
     C                   eval      q1lft = q1lft - need1
     C                   other
     C                   endsl
     C                   endif
     *
     *
     *   Save info for final post.
     *
     C                   eval      savdsp = sldisp
     *
     *   Update slot record.
     *
     C                   eval      xdkupd = *on
     *
     C                   endif
     *
     *
     C     endpx         endsr
     *----------------------------------------------------------------
     *
     *  ZZPXDR  Crossdocking using Dakota Realtime Interface.
     *
     C     zzpxdr        begsr
     C                   eval      xdkupd = *off
     *
     *   Calculate quantity needed.
     *
     C                   if        $xdqty1 > q1lft
     C                   eval      need1 = q1lft
     C                   else
     C                   eval      need1 = $xdqty1
     C                   endif
     C                   if        $xdqty2 > q2lft
     C                   eval      need2 = q2lft
     C                   else
     C                   eval      need2 = $xdqty2
     C                   endif
     C                   if        $xdqty3 > q3lft
     C                   eval      need3 = q3lft
     C                   else
     C                   eval      need3 = $xdqty3
     C                   endif
     *
     C                   eval      xdkupd = *on
     C                   eval      savdsp = 'XDK'
     *
     C                   eval      q1lft = q1lft - need1
     C                   eval      q2lft = q2lft - need2
     C                   eval      q3lft = q3lft - need3
     *
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
     C                   parm      pwhse         @lwhse            3 0
     C                   parm      0             $lpcs             5 0
     C                   parm      0             $lpallets         5 0
700jMC                   parm      savetrn       $lsavetrn         7 0
     C                   parm                    ppo
     C                   parm      $itstyp       $litstyp          1
     C                   parm      $itwhdp       $litwhdp          5
     C                   parm                    $lrtnr           10
     C                   endsr
700jA*----------------------------------------------------------------
700jA*
700jA*  ZZRCVPOCLOSE  Close RCVPO transaction.
700jA*
700jAC     zzrcvpoclose  begsr
700jA
720bA /free
720bA    totpcs = w1qrc1 + w1qrc2 + w1qrc3;
720bA /end-free
720bAC                   call      @crtrcv
720bAC                   parm      '*PO'         $lcmdr           10
720bAC                   parm      '*COMPLETE'   $lsubcmd         10
720bAC                   parm      pwhse         @lwhse            3 0
720bMC                   parm      totpcs        $lpcs             5 0
720bAC                   parm      w1plts        $lpallets         5 0
720bAC                   parm      savetrn       $lsavetrn         7 0
720bAC                   parm                    $ppo              9
720bAC                   parm      $itstyp       $litstyp          1
720bAC                   parm      $itwhdp       $litwhdp          5
720bAC                   parm                    $lrtnr           10
720bAC                   parm                    puser            10
700jA
720bDC*                  call      @crtrcv
720bDC*                  parm      '*PO'         $lcmdr           10
720bDC*                  parm      '*CLOSE'      $lsubcmd         10
720bDC*                  parm      pwhse         @lwhse            3 0
720bDC*                  parm      0             $lpcs             5 0
720bDC*                  parm      0             $lpallets         5 0
720bDC*                  parm      savetrn       $lsavetrn         7 0
720bDC*                  parm                    $ppo              9
720bDC*                  parm      $itstyp       $litstyp          1
720bDC*                  parm      $itwhdp       $litwhdp          5
720bDC*                  parm                    $lrtnr           10
720bDC*                  parm                    puser            10

700jAC                   endsr
     *----------------------------------------------------------------
     *  ZZXDKTEMPLCNS Replace licinfo & uciinfo temp lcns with xdk license
     *----------------------------------------------------------------

      /free
        begsr zzxdktemplcns;
        // records that have a temporary license from gs1 scanning.
        // will need to get the temp license record data, then replace the
        // licinfo with the same data but real license.
        // must loop to process all the licinfo seq#
        // Let's handle the uciinfo file first
           dou $drireturn = '*DONE';
            exsr clr$uciinfo;

            $uiWhse = pwhse;
            $uilcns = $pgslcns;

            $dricommand = '*UCIINFO';
700dD       //$drisubcmd  = '%GETALL';
700dM       $drisubcmd  = '%GET1UCI';
            $drisys2upd = 'D';
            ck4err = *on;
            zmflag  = *off;
            exsr zzzdricop;
            if error;
            endif;
            if $drireturn <> '*DONE';

              // replace - which will add a new record
              $uilcns = $satolcns;
720hA         $uiAlcns = $satolcns;
720hA         $uiAolcns = $satolcns;

              $dricommand = '*UCIINFO';
              $drisubcmd  = '%REPLACE';
              $drisys2upd = 'D';
              ck4err = *on;
              zmflag  = *off;
              exsr zzzdricop;
              if error;
              endif;
            // now delete the originals

            $uilcns = $pgslcns;
720hA       $uiAlcns = $pgslcns;
720hA       $uiAolcns = $pgslcns;

            $dricommand = '*UCIINFO';
            $drisubcmd  = '%DELETE1';
            $drisys2upd = 'D';
            ck4err = *on;
            zmflag  = *off;
            exsr zzzdricop;
            if error;
            endif;
            endif;
          enddo;

        // Now let's handle the replacement of the licinfo records

        for j = 1 to 99;
        exsr clr$licinfo;

        // Get the temp license record
        $lnwhse  = pwhse;
        $lnlcns  = $pgsLcns;
        $lnseq = j;

        $dricommand = '*LICINFO';
        $drisubcmd  = '%GET';
        $drisys2upd = 'D';
        ck4err = *on;
        exsr zzzdricop;
        if error;
          leave;
        endif;

        // Replace with new license - this will actually write a new record
        // With the data from the temporary record
        $lnlcns  = $satolcns;

        $dricommand = '*LICINFO';
        $drisubcmd  = '%REPLACE';
        $drisys2upd = 'D';
        ck4err = *on;
        exsr zzzdricop;
        if error;
        endif;

        endfor;
        // Now delete the temporary gs1/uci xdock
        exsr clr$licinfo;
        $lnwhse  = pwhse;
        $lnlcns  = $pgslcns;

        $dricommand = '*LICINFO';
        $drisubcmd  = '%DELETEALL';
        $drisys2upd = 'D';
        ck4err = *on;
        exsr zzzdricop;
        if error;
        endif;

        endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  ZZUHDR   Update HDR record.
     *
     C     zzuhdr        begsr
      /free
        error = *off;
        full = *on;
        part = *off;
        recv = *off;
        setll (pwhse: ppo) podtl;
        dow not %eof(podtl);
          reade (pwhse: ppo) podtl;
          if not %eof(podtl);
            if pdqrc1 < pdqor1;
              part = *on;
              full = *off;
            endif;
            if pdqrc2 < pdqor2;
              part = *on;
              full = *off;
            endif;
            if pdqrc3 < pdqor3;
              part = *on;
              full = *off;
            endif;
            if pdqrc1 > 0;
              recv = *on;
            endif;
            if pdqrc2 > 0;
              recv = *on;
            endif;
            if pdqrc3 > 0;
              recv = *on;
            endif;
          endif;
        enddo;

        if recv = *off;
          full = *off;
          part = *off;
        endif;

        chain (pwhse:ppo) pohdr;
        if %found(pohdr);
          if part = *on;
            phstat = *on;
          endif;
          if full = *on;
            phstat = '2';
          endif;
          if part = *off  and
             full = *off;
            phstat = *off;
          endif;
          update phrec;
750aA /free
750aA   // Set status for DockVue
750aA   exec sql update postatus
750aA               set posstat = 'X',
750aA                   posupdts = current_timestamp
750aA             where poswhs = :phwhse
750aA               and pospo = :phpo;
750aA /end-free
        endif;
        // Remove any existing catchweight entry records.
        if $itcwgt = 'Y'
           or $itcwgt = 'S';
          exsr zzdlcw;
        endif;
      /end-free
     *
     C     endhdr        endsr
     *----------------------------------------------------------------
     *
     *  ZZDLCW   Delete catchweight entry records.
     *
     C     zzdlcw        begsr
     *
     C                   eval      $mwhs3 = pwhse
     C                   eval      $mpo3 = ppo
     C                   eval      $mseq = pposeq
     C                   call      'DELTMPCW'
     C                   parm                    $mparm
NOTES *************** this will need to be addressed later
NOTESc*                  exsr      zzuci
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUSUB   Update using subfile records.
     *
     C     zzusub        begsr
     C                   eval      error = *off

     *
     *  This code is not executed on directed putaway
     *  This code is not executed on pick slot receiving
     *
     c                   if        directed <> 'Y'
     c                             and PSRcvReq <> 'Y'
     c                             and psrusr <> 'Y'
     *
     *  Get batch number for labels.
     *
     C                   call      'PIRBAT#'
     C                   parm      *zeros        $pbat             7 0
     *
     *     - Create batch control record.
     *
     C                   eval      btbat# = $pbat
     C                   eval      btwhse = pwhse
     C                   eval      bttype = '*RCV    '
     C                   eval      btstat = ' '
     C                   eval      btrte = ' '
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      btstrd = $cvd8o
     C                   time                    btstrt
     C                   eval      btstrb = #user
     C                   write     btrec
     *
     *  End of this code is not executed on directed putaway
     *
     c                   endif
     *
     *   read the pirhold records
     *
      /free
        // get the previously entered licenses for accumulated qty
        hotype = 'POLCNS';
        setll (psessid: hotype) pirhold;
        dow not %eof(pirhold);
          reade (psessid: hotype) pirhold;
          if %eof(pirhold);
            leave;
          endif;
          pirhllcnds = hodata;
      /end-free
     *
     *
     *  This code is not executed on directed putaway
     *  This code is not executed on pick slot receiving
     *
     c                   if        directed <> 'Y'
     c                             and PSRcvReq <> 'Y'
     c                             and psrusr <> 'Y'
     C                   eval      @pgrp1 = 'P'

     *     If dept not live, then calculate qty for pallet.
     *     Or, if cross dock item.

     C                   if        livestat = '*NOTLIVE'
     C                             and h1qty = 0
     C                             or h1xdk = 'Y'
     C                             and h1qty = 0
     C     w1qrc1        div       reccnt        h1qty
     C                   mvr                     remain            5 0
     C                   if        sflrec = reccnt
     C                   eval      h1qty = h1qty + remain
     C                   endif
     C                   endif
     * This is new oss processing
700lDc*                  if        osscode <> ' '
700lMc                   if        osscode <> ' '  and ossprint = ' '
     c                   exsr      zzextstgnew
     c                   endif
     *
     *     Get transaction and label numbers
     *     This needs to be done so they can be sent to drislot.
     *
     C                   call      'PIRTRN#'
     C                   parm                    pttrn#            7 0

     C                   call      'PIRLBL#'
     C                   parm                    newlbl#
     *
     *     Update slot for cross dock records.
     *     OR, Put license into RCV slot.
     *
     C                   if        h1xdk = 'Y'
     C                   exsr      zzuxdk
     C                   else
700lDc*                  if        lflag  = *off
700lAc                   if        lflag  = *off and ossprint <> 'Y'
SFPaAc                   select
SFPaAc                   when      client = seashore
SFPaAc                   eval      hokey = 'SFP' + %editc(pttrn#:'X')
SFPaAc                   other
700iAc                   eval      hokey = 'R' + %editc(pttrn#:'X')
SFPaAc                   endsl
700iAc                   endif
     C                   exsr      zzurcvSlot
     C                   if        error
     C                   goto      endusub
     C                   endif
     C                   endif
     ***********************************************
     *
     *    - Create transaction record.
     *    - Create label record for each quantity type.
     *
     C                   eval      tmpflg = *off
     *
     *        Create label record for Normal qty.
     *
     C                   clear                   lbrec
     C                   eval      lbwhse = pwhse
     C                   eval      lbwhdp = #rcvwhdp
     C                   eval      lbpseq = 0
     C                   eval      lbqryf = 0
     C                   eval      lbaisl = $slaisl
     C                   eval      lbloc = $slloc
     C                   eval      lbrlvl = $slrlvl
     C                   eval      lbhand = $slhand
     C                   eval      lbstyp = $slstyp
     C                   eval      lbdisp = $sldisp
     C                   movel     '*MANUAL'     lbdsp2
700hAc                   if        BrandReq = 'Y'
700hAC                   eval      lbitem = BrandedItm
700hAc                   else
     C                   eval      lbitem = ppoitem
700hAc                   endif
     C                   eval      lbseq = pposeq
     C                   eval      lbpbat = $pbat
     C                   eval      lbpo = ppo
     C                   eval      lbord = $lord
     C                   eval      lbqalc = h1qty
     C                   eval      lbqpck = h1qty
     C                   eval      lbtie = 0
     C                   eval      lbhigh = 0
     *        Create label record for Normal qty.
     C                   if        h1umt = 'N'  and
     C                             #rcvtype <> 'S'
     C                   eval      lbutyp = 'N'
     C                   eval      lbucod = #rcvum1
     C                   eval      lbucub = #rcvcube
     C     lbucub        mult      h1qty         lbcube
     C                   eval      lbuwgt = #rcvswgt
     C     lbuwgt        mult      h1qty         lbswgt
     C                   endif
     *
     *        Create label record for breakdown 1 qty.
     *
     C                   if        h1umt = '1'  and #rcvtype <> 'S'
     C                             or h1umt = 'N'  and #rcvtype = 'S'
     C                   eval      lbutyp = h1umt
     C                   eval      lbucod = #rcvum2
     C                   if        #rcvumq2 <> 0
     C     #rcvcube      div(h)    #rcvumq2      lbucub
     C     lbucub        mult      h1qty         lbcube
     C     #rcvswgt      div(h)    #rcvumq2      lbuwgt
     C     lbuwgt        mult      h1qty         lbswgt
     C                   endif
     C                   endif
     *
     *        Create label record for breakdown 2 qty.
     *
     C                   if        h1umt = '2'  and #rcvtype <> 'S'
     C                             or h1umt = '1'  and #rcvtype = 'S'
     C                   eval      lbutyp = h1umt
     C                   eval      lbucod = #rcvum3
     C                   if        #rcvumq2 <> 0  and
     C                             #rcvumq3 <> 0
     C     #rcvcube      div(h)    #rcvumq2      lbucub
     C     lbcube        div(h)    #rcvumq3      lbucub
     C     lbucub        mult      h1qty         lbcube
     C     #rcvswgt      div(h)    #rcvumq2      lbuwgt
     C     lbswgt        div(h)    #rcvumq3      lbuwgt
     C     lbuwgt        mult      h1qty         lbswgt
     C                   endif
     C                   endif
     *
     C                   eval      lbtrn# = pttrn#
     C                   eval      lblbl# = newlbl#
     C                   eval      lbgrp1 = @pgrp1
     C                   eval      lbgrp2 = @pgrp2
     C                   eval      lbtype = 'P'
     C                   eval      lbstat = 'P'

     *    If dept not live, then set status to Closed.

     C                   if        livestat = '*NOTLIVE'
     C                             or osslcns
     C                             or h1xdk = 'Y'
     C                   eval      lbstat = 'C'
     C                   endif

     C                   eval      lbsdte = today
     C                   time                    lbstim
     C                   eval      lbrdte = today
     C                   if        h1xdk = 'Y'
710cDC*                  eval      lbaisl = slaisl
710cDC*                  eval      lbloc = slloc
710cDC*                  eval      lbrlvl = slrlvl
710cDC*                  eval      lbhand = slhand
710cDC*                  eval      lbpseq = slpseq
710cdC*                  eval      lbstyp = slstyp
710cDC*                  eval      lbdisp = sldisp
     C                   eval      lbdsp2 = *blanks
     C                   eval      lbasl2 = 'XDK'
710cAC* these fields were not being loaded correct
710cMC                   eval      lbaisl = $slaisl
710cMC                   eval      lbloc = $slloc
710cMC                   eval      lbrlvl = $slrlvl
710cMC                   eval      lbhand = $slhand
710cMC                   eval      lbpseq = $slpseq
710cMC                   eval      lbstyp = $slstyp
710cMC                   eval      lbdisp = $sldisp
     C                   endif
     C                   write     lbrec
     *
     *         Print label.
     *          ... only if dept is live.
     *
     C                   if        lflag = *off
     C                             and livestat = '*LIVE'
     C                   eval      $acmd = '*LABEL  '
     C                   eval      $atie = 0
     C                   eval      $ahigh = 0
     C                   eval      $aqty = h1qty
710dDC*                  eval      $apslt = *blanks
     C                   eval      $adisp = *blanks
     C                   eval      $astyp = *blanks
     C                   eval      $aum = lbucod
700lAC                   eval      $osslcns = hokey
     C                   if        $rexpd = 0
     C                   eval      $aexpd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      $rexpd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      $aexpd = $cvd6o
     C                   endif
     *
700iA /free
700iA   if Brandeditm <> ' ';
700iA     pitem = BrandedItm;
700iA   else;
700iA     pitem = ppoItem;
700iA   endif;
700iA   // parse out the program name and label set name
700iA   if %subst(oplpgm:1:4) = 'RFMT';
700iA     lblset = %subst(oplpgm: 5 : 6);
700iA     lblpgm = %subst(oplpgm: 1 : 4);
700iA /end-free
700pA * check for branded item
700pA /free
700pA   BrandReq = ' ';
700pA   bCmd = '*GET4BITM';
700pA   bBrand = ' ';
700pA   bBrandItm = BrandedItm;
700pA   bBrandFlg = ' ';
700pA   GetBranded(bCmd: pwhse: ppoItem: bBrand: bBrandItm: bBrandFlg) ;
700pA     BrandReq = bBrandFlg;
700pA /end-free
740aA /free
740aA   if PSRcvReq = 'Y' or
740aA      psrusr = 'Y';
740aA   else;
770bA     // build a lot field to send for the label
770bA     lblLot = ' ';
770bA     if W1lotc <> ' ';
770bA       lblLot = W1lotc;
770bA     endif;

770bA     if clienthost = freshbyte;
770bA       lblLot = %subst(pdpo:1:6) +
770bA                %subst(%EditC(pdseq:'X'):3:3);
770bA     endif;

740aA /end-free
700iAC                   call      lblpgm
700iAC                   parm                    $acmd             8
700iAC                   parm                    lblset            6
700iAC                   parm      ' '           $plfmt            8
700iAC                   parm                    pttrn#
700iAC                   parm                    pwhse
700iAC                   parm                    #rcvwhdp
700iAC                   parm                    $astyp
700iAC                   parm                    $adisp
700iAC                   parm                    $apslt
700iAC                   parm                    $aqty             5 0
700iAC                   parm                    $aum              2
700oMC                   parm      wotie         $atie             4 0
700oMC                   parm      wohi          $ahigh            2 0
700iAC                   parm                    pitem
700iAC                   parm                    #rcvdesc
700iAC                   parm                    #rcvpdsc
700iAC                   parm                    #rcvupc
700iAC                   parm                    phven
700iAC                   parm                    pdvitm
700iAC                   parm                    ppo
700iAC                   parm                    today6
700iAC                   parm                    $aexpd            6 0
710aAC                   parm      pprinter      $pdev
700iAC                   parm                    $pform
700lAC                   parm                    $osslcns         15
700oAC                   parm                    bBrand
770bAC                   parm                    lblLot
740aAc                   endif
700iA /free
700iA   else;
700iA /end-free
     C                   call      oplpgm
     C                   parm                    $acmd             8
     C                   parm                    pttrn#
     C                   parm      pwhse         $pwhs
     C                   parm                    #rcvwhdp
     C                   parm                    $astyp
     C                   parm                    $adisp
     C                   parm                    $apslt
     C                   parm                    $aqty             5 0
     C                   parm                    $aum              2
     C                   parm                    $atie             4 0
     C                   parm                    $ahigh            2 0
     C                   parm                    ppoitem
     C                   parm                    #rcvdesc
     C                   parm                    #rcvpdsc
     C                   parm                    #rcvupc
     C                   parm                    phven
     C                   parm                    pdvitm
     C                   parm                    ppo
     C                   parm                    today6
     C                   parm                    $aexpd            6 0
     C                   parm                    $pdev
     C                   parm                    $pform
700iA /free
700iA   endif;
700iA /end-free
     C                   endif
     *
     *        Create transaction record.
     *
     C                   if        h1xdk = 'Y'
     C                   eval      @pwhdp = slwhdp
     C                   eval      @pstyp = slstyp
     C                   else
     C                   eval      @pwhdp = #rcvwhdp
     C                   eval      @pstyp = #rcvstyp
     C                   endif
     *
     C                   call      @addtr
     C                   parm      '*CREATE '    @pcmd             8
     C                   parm                    #job
     C                   parm      pttrn#        @ptrn#            7 0
     C                   parm      'PUTEMP'      @ptask            6
     C                   parm      pwhse         @pwhse            3 0
     C                   parm                    @pwhdp            5
     C                   parm                    @pstyp            1
     C                   parm      lbcube        @pcube            9 3
     C                   parm      lbswgt        @pswgt            9 2
     C                   parm      lbqpck        @ppcs             5 0
     C                   parm      1             @paisl            5 0
     C                   parm      1             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ppo           @ppo              9
     C                   parm      'P'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     *         If dept not live, then close transaction.

     C                   if        livestat = '*NOTLIVE'
     C                             or osslcns
     C                             or h1xdk = 'Y'
     C                   call      @addtr
     C                   parm      '*CLOSE  '    @pcmd             8
     C                   parm                    #job
     C                   parm      pttrn#        @ptrn#            7 0
     C                   parm      'PUTEMP'      @ptask            6
     C                   parm      pwhse         @pwhse            3 0
     C                   parm                    @pwhdp            5
     C                   parm                    @pstyp            1
     C                   parm      lbcube        @pcube            9 3
     C                   parm      lbswgt        @pswgt            9 2
     C                   parm      lbqpck        @ppcs             5 0
     C                   parm      1             @paisl            5 0
     C                   parm      1             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ppo           @ppo              9
     C                   parm      'P'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
     C                   endif
     *
     c                   endif
     *
     *  End of code not executed on directed putaway/pick slot rcv
     *
     *
     *  Only executed on directed putaway
     *  or Pick slot receiving
     *
      /free
        if directed = 'Y'
           or PSRcvReq = 'Y'
           or psrusr = 'Y';
700iA     if lflag  = *off;
SFPaA       select;
SFPaA         when client = seashore;
SFPaA           hokey = 'SFP' + %editc(h1trn:'X');
SFPaA         other;
700iA           hokey = 'R' + %editc(h1trn:'X');
SFPaA       endsl;
700iA     endif;
          chain (pwhse: h1trn) license1;
        endif;
      /end-free
NOTES ***** this code will need to be replaced in GUI
      * Code moved to here to allow entry for each license.
     C                   Eval      $phdte = *Zeros
     C                   Eval      $phloc = *Blanks
     C                   Eval      $pcert = *Blanks
     *
     C                   if        $pcode = Clams
     C                             or $pcode = Shucked
730cDC*                  dow       $phdte = 0
730cDC*                            or $phloc = ' '
730cDC*                            or $pcert = ' '
730cDC*                  eval      sav$pcmd = $pcmd
730cDC*                  eval      $pcmd = '*ITEM'
730cDC*                  call      'PO172'       po172P
730cDC*                  eval      $pcmd = sav$pcmd
730cDC*                  enddo
     C                   endif
     *    Update licinfo.

     C                   exsr      zzlicinfonew
      ** This needs to still be addressed
      * new haccp cross ref added
      /free
         hxlcns = $lnlcns;
         for xx = 1 to 20;
           $p1parms1 = $parms1(xx);
             if $p1po <> ' ';
               hxwhse =  %dec($p1whse:3:0);
               hxPO = $p1po;
               hxPOSeq = %dec($p1poseq:5:0);
               hxseq# = %dec($p1qstseq:5:0);
               hxadduc = $p1uctime;
               write hxrec;
             endif;
         endfor;
      /end-free
     *    Directed  or pick slot receving Only
     c                   if        directed = 'Y'
     c                             or PSRcvReq = 'Y'
     c                             or psrusr = 'Y'
610aA*
610aA*     Update license number
610aA*
610aAC                   exsr      clr$license
600dAC                   eval      $liToLcnsU = *on
     c                   if        directed = 'Y'
600eAC                   eval      $liToLcns = hokey
600eAC                   eval      $liOLcns = hokey
     c                   else
600eAC                   eval      $liToLcns = lilcns
600eAC                   eval      $liOLcns = lilcns
     c                   endif
600dAC                   eval      $liOLcnsU = *on
600dAC                   eval      $liFrmOldLcnsU = *on
600eAC                   eval      $liFrmOldLcns = lilcns
600rAC                   eval      $liActionU = *on
600rAC                   eval      $liAction = 'DPT'
600rAC                   eval      $liActionU = *on
600rAC                   eval      $liAction = 'DPT'
     C                   eval      $liLbl#U = *on
     C                   eval      $liLbl# = h1lbl
     C                   eval      $liTrn#U = *on
     C                   eval      $liTrn# = h1trn
600rAC                   eval      $liETrn#U = *on
600rAC                   eval      $liETrn# = 0

600dAC                   eval      $dricommand = '*LICENSE'
600dAC                   eval      $drisubcmd  = '%CHGDP'
600dAC                   eval      $drisys2upd = 'D'
600dAC                   eval      ck4err = *off
600dAC                   exsr      zzzdricop
600dAC                   if        error
600dAC                   endif
     c                   endif
     *    Update POASN

     C                   exsr      zzpoasn

     * Print clam tags

     C                   if        $pcode = Clams and livestat = '*LIVE'
     C                   eval      $pqty = h1Qty
730cDC*                  call      'TAGFMT'      tagfmtP
     C                   endIf

     c                   if        directed = 'Y'
     *     Initialize record fields before trying to add or update.
     *
     C                   eval      liwhse = pwhse
416a C                   eval      lilcns = hokey
     C                   eval      litrn# = h1trn
     c                   endif
     *
     *      Add record to PORCV to mark as touched/received.
     *
     C                   exsr      zzurcv
      /free
        // pick slot receiving will close label and transaction
        if PSRcvReq = 'Y'
           or psrusr = 'Y';
          chain (h1lbl) label;
          if %found(label);
            lbstat = 'C';
            update lbrec;
          endif;
      /end-free
     C                   call      @addtr
     C                   parm      '*CLOSE  '    @pcmd             8
     C                   parm                    #job
     C                   parm      h1trn         @ptrn#            7 0
     C                   parm      'PUTEMP'      @ptask            6
     C                   parm      pwhse         @pwhse            3 0
     C                   parm                    @pwhdp            5
     C                   parm                    @pstyp            1
     C                   parm      lbcube        @pcube            9 3
     C                   parm      lbswgt        @pswgt            9 2
     C                   parm      lbqpck        @ppcs             5 0
     C                   parm      1             @paisl            5 0
     C                   parm      1             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ppo           @ppo              9
     C                   parm      'P'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
     c                   endif
     c
      * Begin Haccp Detail License Processing
      /free
        $lwhse = pwhse;
        $lcmd = '*PODTL  ';
        $llevel = 'RCVL';
        $llicense = hokey;
        $lhpo = ppo;
        $lhseq = pposeq;
        $lhtype = ' ';
        // this needs to be addressed in MRC
        ////ha410($lparm:$lparm1);
      /end-free
      * End Haccp Detail License Processing

     *  Process putaway for external storage
     *
     *  Create license record.
     *
710cDC*                  if        h1xdk <> 'Y'
710cDC*                            and livestat = '*LIVE'
710cMC                   if        livestat = '*LIVE'
710cAc                   if        w1xdk = 'Y'
710cAc                   eval      hokey  = $satolcns
710cAc                   endif
      /free
        if directed <> 'Y'
           and PSRcvReq <> 'Y'
           and psrusr <> 'Y';
          exec sql select * into :lirec
             from license
             where lilcns = :hokey;
          If sqlstt = sqlSuccess;
          else;
            exec sql insert into license
                 values(:pwhse,
                        :hokey,
                        :pttrn#);
          endif;
        else;
          if %found(license1);
            update lirec1;
          endif;
        endif;
      /end-free
     *
     C                   endif
     C                   enddo
     *
     *   Flush labels out of spool file.
     *
     C                   if        lflag = *off
     C                   eval      $acmd = '*FLUSH  '
700iA /free
700iA   if Brandeditm <> ' ';
700iA     pitem = Brandeditm;
700iA   else;
700iA     pitem = ppoItem;
700iA   endif;
700iA   // parse out the program name and label set name
700iA   if %subst(oplpgm:1:4) = 'RFMT';
700iA     lblset = %subst(oplpgm: 5 : 6);
700iA     lblpgm = %subst(oplpgm: 1 : 4);
700iA /end-free
740aA /free
740aA   if PSRcvReq = 'Y' or
740aA      psrusr = 'Y';
740aA   else;
770bA     // build a lot field to send for the label
770bA     lblLot = ' ';
770bA     if W1lotc <> ' ';
770bA       lblLot = W1lotc;
770bA     endif;

770bA     if clienthost = freshbyte;
770bA       lblLot = %subst(pdpo:1:6) +
770bA                %subst(%EditC(pdseq:'X'):3:3);
770bA     endif;
740aA /end-free
700iAC                   call      lblpgm
700iAC                   parm                    $acmd
700iAC                   parm      ' '           lblset            6
700iAC                   parm      ' '           $plfmt            8
700iAC                   parm                    pttrn#
700iAC                   parm                    pwhse
700iAC                   parm                    #rcvwhdp
700iAC                   parm                    $astyp
700iAC                   parm                    $adisp
700iAC                   parm                    $apslt
700iAC                   parm                    $aqty
700iAC                   parm                    $aum
700iAC                   parm                    $atie
700iAC                   parm                    $ahigh
700iAC                   parm                    pitem
700iAC                   parm                    #rcvdesc
700iAC                   parm                    #rcvpdsc
700iAC                   parm                    #rcvupc
700iAC                   parm                    phven
700iAC                   parm                    pdvitm
700iAC                   parm                    ppo
700iAC                   parm                    today6
700iAC                   parm                    $aexpd
710aAC                   parm      pprinter      $pdev
700iAC                   parm                    $pform
700lAC                   parm                    $osslcns
770bAC                   parm      ' '           bBrand
770bAC                   parm                    lblLot
740aAc                   endif
700iA /free
700iA   else;
700iA /end-free
     C                   call      oplpgm
     C                   parm                    $acmd
     C                   parm                    pttrn#
     C                   parm                    pwhse
     C                   parm                    #rcvwhdp
     C                   parm                    $astyp
     C                   parm                    $adisp
     C                   parm                    $apslt
     C                   parm                    $aqty
     C                   parm                    $aum
     C                   parm                    $atie
     C                   parm                    $ahigh
     C                   parm                    ppoitem
     C                   parm                    #rcvdesc
     C                   parm                    #rcvpdsc
     C                   parm                    #rcvupc
     C                   parm                    phven
     C                   parm                    pdvitm
     C                   parm                    ppo
     C                   parm                    today6
     C                   parm                    $aexpd
     C                   parm                    $pdev
     C                   parm                    $pform
700iA /free
700iA   endif;
700iA /end-free
     C                   endif
     *
     *
     *        Update PO detail record.
     *
      /free
        select;
          // directed and pick slot receiving already have the podtl file
          // updated in the call to RC160.
          when directed = 'Y';
          when PSRcvReq = 'Y';
          when psrusr = 'Y';
          other;
            chain (pwhse:ppo:pposeq:ppoitem) podtl;
            if %found(podtl);
              pdqrc1 = pdqrc1 + w1qrc1;
              pdqrc2 = pdqrc2 + w1qrc2;
              pdqrc3 = pdqrc3 + w1qrc3;
              pddwgt = pddwgt + w1twgt;
              update pdrec;
            endif;
700hA       if BrandReq = 'Y';
700hA         exec sql select * into :pdrecbrd
700hA             from podtl
700hA             where pdwhse = :pWhse
700hA               and pdpo   = :pPO
700hA               and pditem = :BrandedItm
700hA            fetch first 1 rows only;
700hA         If sqlstt = sqlSuccess;
700hA           // update existing record
700hA           chain (pwhse:ppo:BR_pdseq:BrandedItm) podtl;
700hA           if %found(podtl);
700hA             pdqrc1 = pdqrc1 + w1qrc1;
700hA             pdqrc2 = pdqrc2 + w1qrc2;
700hA             pdqrc3 = pdqrc3 + w1qrc3;
700hA             pddwgt = pddwgt + w1twgt;
700hA             pdqor1 = pdqor1 + w1qrc1;
700hA             pdqor2 = pdqor2 + w1qrc2;
700hA             pdqor3 = pdqor3 + w1qrc3;
700hA             update pdrec;
700hA           endif;
700hA         else;
700hA           // need to find seq# to add
700hA           NewSeq# = 99999;
700hA           dow forever = forever;
700hA             exec sql select * into :pdrecbrd
700hA                 from podtl
700hA                 where pdwhse = :pWhse
700hA                   and pdpo   = :pPO
700hA                   and pdseq = :NewSeq#
700hA                fetch first 1 rows only;
700hA             If sqlstt = sqlSuccess;
700hA               NewSeq# = NewSeq# - 1;
700hA             else;
700hA               // load fields and write podtl
700hA               pdwhse = pwhse;
700hA               pdpo   = ppo;
700hA               pdseq  = NewSeq#;
700hA               pditem = BrandedItm;
700hA               pdspcl = 'BR';
700hA               pdqrc1 = w1qrc1;
700hA               pdqrc2 = w1qrc2;
700hA               pdqrc3 = w1qrc3;
700hA               pddwgt = w1twgt;
700hA               pdqor1 = w1qrc1;
700hA               pdqor2 = w1qrc2;
700hA               pdqor3 = w1qrc3;
700hA               write  pdrec;
700hA               leave;
700hA             endif;
700hA           enddo;
700hA         endif;
700hA       endif;
        endsl;
      /end-free
     C                   eval      $prtn = '*OK     '
      * already have $lord on directed and pick slot receiving
     c                   if        directed <> 'Y'
     c                             and PSRcvReq <> 'Y'
     c                             and psrusr <> 'Y'
     C                   eval      $lord = $pbat
     c                   endif
     C                   eval      errmsg = %trim(%editc(ptqty:'P'))
     C                                    + ' received of '
     C                                    + ppoitem
     C                   if        livestat = '*NOTLIVE'
     C                   eval      errmsg = %trim(errmsg)
     C                                    + ' in non-live department'
     C                   endif
     C*                  enddo
     C     endusub       endsr
     *----------------------------------------------------------------
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

      /free
       begsr getCurrStamp;

         getmicrotime(currstampuc:currstampsys);
         currstamploc = currstampsys + %hours(bfcoffset);

       endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  ZZUPD1   This routine writes the license records to pirhold
     *
     C     zzupd1        begsr
     *
      /free
         hotype = 'POLCNS';
700lA    Select;
700lA    When w1lcns = ' ' and ossprint = 'Y';
700lA      // need to get the OSS plates that were printed
700lA       exec sql select * into :osrecck
700lA       from workoss
700lA       where WOLCNS not in
700lA         (select HOKEY from PIRHOLD)
700lA            fetch first 1 rows only;
700lA      pokey = os_wolcns;
700lA      w1lcns= os_wolcns;
700lA    When w1lcns = ' ';
700lD    //if w1lcns = ' ';
700nA      exsr getcurrstamp;
700iA      pokey = %char(%time())
700iA            + '.'
700nM            + %char(%SUBDT(currstampsys:*MS));
700nD            //+ %char(%SUBDT(%timestamp:*MS));
700lD    //else;
700lA    other;
           pokey = w1lcns;
700lD    //endif;
700lA    Endsl;
         chain (psessid: hotype: pokey) pirhold;
         h1qty = w1qty;
         h1uom = w1uom;
700fA    h1item = ppoitem;
700fA    h1pcmdone = ' ';
         select;
           when h1uom = w1um1;
             h1umt = 'N';
           when h1uom = w1um2;
             h1umt = '1';
           when h1uom = w1um3;
             h1umt = '2';
         endsl;
         // load label/tran data for directed
         if directed = 'Y';
           h1lbl = dlabel;
           h1trn = dtrn;
         endif;
         hodata = pirhllcnds;
700bD    //if %found(pirhold);
700bM    if %found(pirhold) and paction = 'A';
           error = *on;
           pmessage = 'License is already in file';
           return;
         else;
           exsr getcurrstamp;
           hoaddts = currstampsys;
           hoadduc = currstampuc;
700bA      Select;
700bA        when paction = 'A';
               hosess = psessid;
               hokey = pokey;
               write horec;
700bA        when paction = 'U';
700bA          update horec;
700bA        when paction = 'D';
700bA          Delete horec;
700bA      endsl;
         endif;
      /end-free
     *
      /free
         PJSON  = ' ';
         session = %trim(psessid);
         whse    = pWhse;
         PO      = %trim(pPO);
         PoSeq   = pPOseq;
         POItem  = %trim(pPOItem);
710aA    ppgm1   = 'ISERIES';
        // lets check to see if the user has scanned all licenses
         r13200(session :
                 whse :
                 PO :
                 POseq :
                 POItem :
710aA            Ppgm1 :
                 PJSON);
         exsr ProcessJSON;
      /end-free

     C     endup1        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPdone done update po
     *
     C     zzupddone     begsr
     C                   eval      error = *off
     *
     *  Update detail first.
     *
     C                   if        reccnt > 0
     C                   exsr      zzusub
     C     error         cabeq     *on           endupdone
     C                   endif

     * this part of the update came from po232 after the call to po236
     *
     *    Write records to POMFR file.
     *    Note: RC160 returns batch number in $RORD field which is
     *          used as first part of the LBKEY.
     *
     C                   if        w1mfdt <> 0  or
     C                             w1exdt <> 0
     C     lbkey         setll     label2
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     lbkey         reade(n)  label2                                 79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C     lblbl#        chain     pomfr1                             78
     C                   eval      pmwhse = pwhse
     C                   eval      pmpo = ppo
     C                   eval      pmseq = pposeq
700hAc                   if        BrandReq = 'Y'
700hAC                   eval      pmitem = BrandedItm
700hAc                   else
     C                   eval      pmitem = ppoitem
700hAc                   endif
     C                   eval      pmexpd = $rexpd
     C                   if        w1mfdt <> 0
     C                   move      w1mfdt        $cvd6i
     C                   eval      $cvcmd = '*MDYCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      pmmfgd = $cvd8o
     C                   else
     C                   eval      pmmfgd = 0
     C                   endif
     C                   eval      pmtrn# = lbtrn#
     C                   eval      pmlbl# = lblbl#
     C                   if        *in78  = *off
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
     C                   eval      dsexpd = $dtosave
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
     C                   select
     C                   when      ocovr = *on
     C                   eval      dsexpd = ckexdt
     C                   other
     C                   eval      dsexpd = $dtosave
     C                   endsl
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
      **** end of w1mfdt, w1exdt if statement
     * catch weight override exception
     C                   if        cwovr = *on
     C     lbkey         setll     label2
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     lbkey         reade(n)  label2                                 79
     C                   if        *in79
     C                   eval      stop = *on
     c                   leave
     C                   else
     C                   if        lbqpck > 999
     C                   eval      exqty = 999
     C                   else
     C                   z-add     lbqpck        exqty
     C                   endif
     C                   endif
     *
     C                   eval      exwhse = lbwhse
     C                   eval      exwhdp = lbwhdp
     C                   eval      exstyp = lbstyp
     C                   eval      exitem = lbitem
     C                   eval      dspo = lbpo
     C                   eval      dslbl = lblbl#
     C                   eval      dsexpd = 0
     C                   eval      exfdis = dsfdis
     C                   eval      extdis = dstdis
     C                   eval      exgdte = lbsdte
     C                   eval      exgtim = lbstim
     *
     C                   eval      extask = 'RCV'
     C                   eval      exgby = #user
     C                   select
     C                   when      cwovr = *on
     C                   eval      exerid = 'CW-OVR '
     C                   endsl
     C                   eval      exesta = '1 '
     C                   write     exrec
      * load new file pocwexcp
      /free
        cw_exwhse = lbwhse;
        cw_expo = lbpo;
        cw_exseq = lbseq;
        cw_exitem = lbitem;
        cw_extrn# = lbtrn#;
        cw_exlbl# = lblbl#;
        cw_exwgt = W1DWGT;
        cw_exgdte = lbsdte;
        cw_exgtim = lbstim;
        cw_exrg1c = prg1c * 100;
        cw_exrg2c = prg2c * 100;
700iA   cw_exrngl = lwrng;
700iA   cw_exrngh = hirng;
        cw_exswgt = exwgt;
        select;
          when $imrg1c > 0;
            cw_exrg1w = 'I';
          when oprg1c > 0;
            cw_exrg1w = 'S';
          other;
            cw_exrg1w = 'P';
        endsl;
        select;
          when $imrg2c > 0;
            cw_exrg2w = 'I';
          when oprg2c > 0;
            cw_exrg2w = 'S';
          other;
            cw_exrg2w = 'P';
        endsl;
          write cwexrec;
      /end-free
     C                   enddo
     C                   eval      cwovr = *off
     *
     C                   endif
      *****end of catch weight override
     *
     *    Write records to POFIFO file.
     C                   if        w1fifo <> 0
     C     lbkey         setll     label2
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     lbkey         reade(n)  label2                                 79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     *
     C                   move      w1fifo        $cvd6i
     C                   eval      $cvcmd = '*MDYCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        wofifo
     C                   eval      pffifo = wofifo
     C                   eval      pflbl# = lblbl#
     C                   write     pfrec
     C                   endif
     C                   enddo
     C                   endif
     *
     *   Move key values to parameters
     *
     C     jmpup1        tag
     C*                  eval      $pseq = pdseq
     C*                  eval      $pitem = pditem

     c                   exsr      zzuhdr

     C     endupdone     endsr
     *
     *---------------------------------------------------------------
     *
     *  zzurcvOSS    Put license into OSS slot
     *
     C     zzurcvOSS     begsr

     *  Put license into a OSS slot

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #rcvwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = $liToDisp
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = #rcvitem

     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = 0
     C                   eval      $saqty2 = 0
     C                   eval      $saqty3 = 0
     C                   select
     C                   when      h1umt = 'N'
     C                   eval      $saqty1 = h1qty
     C                   when      h1umt = '1'
     C                   eval      $saqty2 = h1qty
     C                   when      h1umt = '2'
     C                   eval      $saqty3 = h1qty
     C                   endsl

     C                   eval      $sacwtau = *on
     C                   eval      $sacwta  = 0
     C                   eval      $sacodeu = *on
     C                   eval      $sacode  = '@@'
     C                   eval      $samemou = *on
     C                   eval      $samemo  = ' '
     C                   eval      $sabyu   = *on
     C                   eval      $saby    = puser

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'OSS'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = pttrn#
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saLbl#U = *on
     C                   eval      $saLbl# = newlbl#
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = 1
     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = hokey
     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'Y'
     C                   eval      $saOLcnsU = *on
     C                   eval      $saOLcns = hokey

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%ADJUSTOSS'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      zmflag  = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif
      /free
        // delete workoss record for license                           e
        exec sql delete from workoss
                 where wowhse = :pWhse
                   and wolcns  = :hokey;
      /end-free

     C                   endsr
     *---------------------------------------------------------------
     *
     *  zzurcvSlot   Put license into RCV slot
     *
     C     zzurcvSlot    begsr

     *  Only do update for live departments.

     C                   if        livestat <> '*LIVE'
     C                   exsr      clr$slot
     C                   leavesr
     C                   endif

     *  Call different routine when putting into an
     *  Outside Storage Slot.

     C                   exsr      zzchkoss
     c                   if        osscode <> ' '
     c                   eval      ossLcns = *on
     c                   endif
     C                   if        ossLcns
     C                   exsr      zzurcvOSS
     C                   leavesr
     C                   endif

     *  Put license into a RCV slot

     C                   eval      #rcvArea = 'DOCK'

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #rcvwhdp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = #rcvitem
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = ' '
     C                   eval      $slstatu = *on
     C                   eval      $slstat  = w1stat
     C                   eval      $slstypu = *on
     C                   eval      $slstyp = #rcvstyp
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd = $rexpd
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = #rcvitem

     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = 0
     C                   eval      $saqty2 = 0
     C                   eval      $saqty3 = 0
     C                   select
     C                   when      h1umt = 'N'
     C                   eval      $saqty1 = h1qty
     C                   when      h1umt = '1'
     C                   eval      $saqty2 = h1qty
     C                   when      h1umt = '2'
     C                   eval      $saqty3 = h1qty
     C                   endsl

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'RCV'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = pttrn#
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saLbl#U = *on
     C                   eval      $saLbl# = newlbl#
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = 1
     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = hokey
     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'Y'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'D'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = #rcvarea
     C                   eval      $saOLcnsU = *on
     C                   eval      $saOLcns = hokey

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%RCVIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      zmflag  = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   goto      endurcvslot
     C                   endif

     *  Create item adjustment record for item received without PO

     C                   time                    curtime
      /free
         if $pcmd = '*NONE   ';
           iawhse = $slwhse;
           iaitem = $slitem;
           iadate = today;
           iatime = curtime;
           iaby   = puser;
           iawhdp = $slwhdp;
           iadisp = $sldisp;
           iacwta = w1twgt;
           iaqty1 = w1qrc1;
           iaqty2 = w1qrc2;
           iaqty3 = w1qrc3;
           iaudte = 0;
           iautim = 0;
           select;
             when client = cityline;
               iacode = '4 ';
             other;
               iacode = 'Z9';
           endsl;
           iamemo = 'RC180:Item received without PO';
           write iarec;
         endif;
      /end-free

     C     endurcvslot   endsr
     *---------------------------------------------------------------
     *
     *  ZZURCV   Update PORCV file.
     *
     C     zzurcv        begsr
     *
     *   Add record to PORCV.
     *
     C                   eval      porwhs = pwhse
     C                   eval      porpo = ppo
     C                   eval      porseq = pposeq
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     *  Convert today's date into MMDDYY format.
     *
     C                   eval      $cvcmd = '*CURMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today6 = $cvd6o
      *
     C                   eval      pordte = today
     C                   time                    portim
     C                   eval      porusr = puser
     C                   eval      pordev = #job
     C                   eval      poremp = $emp#
     c                   if        directed = 'Y'
     c                             or PSRcvReq = 'Y'
     c                             or psrusr = 'Y'
     C                   eval      portrn = h1trn
     C                   eval      porlbl = h1lbl
     c                   else
     C                   eval      portrn = pttrn#
     C                   eval      porlbl = lblbl#
     c                   endif
730aA /free
730aA   select;
730aA     when directed = 'Y';
730aA       porlic   = hokey;
730aA     when PSRcvReq = 'Y';
730aA       porlic   = lilcns;
730aA     when psrusr = 'Y';
730aA       porlic   = lilcns;
730aA     other;
730aA       porlic   = hokey;
730fA   endsl;
730aA /end-free
730aDC*                  eval      porlic = hokey
     C                   eval      poract = 'R'
     C                   eval      poredt = 0
     C                   eval      poreti = 0
     C                   write     porrec                               49
     C                   endsr
     *--------------------T-------------------------------------------
     *
     *  ZZUXDK  Update slot for cross dock.
     *
     C     zzuxdk        begsr
     *
     *  P.O. detail info must have been sent to program.
     *
     C     pposeq        cabeq     0             endux
     *
     *  Initialize quantities.
     *
     C                   eval      q1lft = 0
     C                   eval      q2lft = 0
     C                   eval      q3lft = 0
     C                   eval      need1 = 0
     C                   eval      need2 = 0
     C                   eval      need3 = 0
     *
     *   See if host is providing an xdock quantity.
     *
     C                   if        xdkdri = *on
     C                   if        locatr = *on
     C                   exsr      zzuxlc
     C                   else
     C                   exsr      zzuxfl
     C                   endif
     C                   goto      endux
     C                   endif
     *
     *  If this is not a cross dock item, get out.
     C                   if        sv_pdspcl <> 'XD'
     C                   goto      endux
     C                   endif
     *
     *  Use DRISLOT with %CRTXDOCK to get existing cross dock slot or
     *  create new one.
     *
     C                   exsr      zzcrxd
     *
     *  Get slot assigned to cross dock item.
     *
     *
     *  Calculate qty still needed.
     C                   if        h1umt = 'N'
     C                   eval      q1lft = h1qty
     C                   else
     C                   if        h1umt = '1'
     C                   eval      q2lft = h1qty
     C                   else
     C                   if        h1umt = '2'
     C                   eval      q3lft = h1qty
     C                   endif
     C                   endif
     C                   endif
     *
     *  Most of the remaining code in this subr no longer applies since
     *  we are now receiving all of the qty into the slot using DRISLOT
     *  with %ADJUSTOSS.  So rather than comment out tons of code, skip
     *  over what is no longer needed.
     *
     C                   goto      skip1
     *
     *  Call program to calculate available slot quantities.
     *
     C                   call      'SLOTQTY'
     C                   parm                    slstk1
     C                   parm                    slstk2
     C                   parm                    slstk3
     *
     C                   parm                    slalc1
     C                   parm                    slalc2
     C                   parm                    slalc3
     *
     C                   parm                    sltfr1
     C                   parm                    sltfr2
     C                   parm                    sltfr3
     *
     C                   parm                    slpck1
     C                   parm                    slpck2
     C                   parm                    slpck3
     *
     C                   parm                    slrcv1
     C                   parm                    slrcv2
     C                   parm                    slrcv3
     *
     C                   parm                    stock1
     C                   parm                    stock2
     C                   parm                    stock3
     *
     C                   parm                    avail1
     C                   parm                    avail2
     C                   parm                    avail3
     *
     *   With cross docks, quantity is needed if the available qty
     *   is negative.  Cross dock slots are the only slots that allow
     *   the available quantity to go negative.
     *
     C                   if        avail1 >= 0
     C                   eval      need1 = 0
     C                   else
     C                   eval      need1 = -(avail1)
     C                   endif
     C                   if        avail2 >= 0
     C                   eval      need2 = 0
     C                   else
     C                   eval      need2 = -(avail2)
     C                   endif
     C                   if        avail3 >= 0
     C                   eval      need3 = 0
     C                   else
     C                   eval      need3 = -(avail3)
     C                   endif

     C     skip1         tag

     *   We want everything received for an 'XD' to go into
     *   the cross dock slot.
     C                   eval      need1 = q1lft
     C                   eval      need2 = q2lft
     C                   eval      need3 = q3lft
     *
     *   Get out if nothing needed.
     *
     C                   if        need1 = 0  and
     C                             need2 = 0  and
     C                             need3 = 0
     C                   goto      endux
     C                   endif
     *
     *   Make sure breakdown qty's are not greater than unit of
     *   measure quantity.
     *
     C                   dow       need3 >= #rcvumq3  and
     C                             #rcvumq3 <> 0
     C                   eval      need3 = need3 - #rcvumq3
     C                   add       1             need2
     C                   enddo
     *
     C                   dow       need2 >= #rcvumq2  and
     C                             #rcvumq2 <> 0
     C                   eval      need2 = need2 - #rcvumq2
     C                   add       1             need1
     C                   enddo
     *
     *   Receive needed quantity.
     *   If breakdown quantity is needed and a corresponding breakdown
     *   qty is not being received, then take it.
     *   If breakdown quantity is needed but a corresponding breakdown
     *   qty is not being received, then increase the qty needed by
     *   the next larger breakdown by 1. We don't want the receivers
     *   to breakdown boxes.  That job is left for the selectors.
     *
     C                   if        need3 > 0
     C                   select
     C                   when      q3lft = 0
     C                   add       1             need2
     C                   when      need3 <= q3lft
     C                   z-add     need3         slrcv3
     C                   eval      q3lft = q3lft - need3
     C                   other
     C                   z-add     q3lft         slrcv3
     C                   eval      q3lft = 0
     C                   add       1             need2
     C                   endsl
     C                   endif
     *
     C                   if        need2 > 0
     C                   select
     C                   when      q2lft = 0
     C                   add       1             need1
     C                   when      need2 <= q2lft
     C                   z-add     need2         slrcv2
     C                   eval      q2lft = q2lft - need2
     C                   other
     C                   z-add     q2lft         slrcv2
     C                   eval      q2lft = 0
     C                   add       1             need1
     C                   endsl
     C                   endif
     *
     C                   if        need1 > 0
     C                   select
     C                   when      need1 <= q1lft
     C                   eval      slrcv1 = need1
     C                   eval      q1lft = q1lft - need1
     C                   other
     C                   eval      slrcv1 = q1lft
     C                   eval      q1lft = 0
     C                   endsl
     C                   endif
     *
     *   Skip some more code ......
     C                   goto      skip2
     *
     *   Update slot record.
     *
     C                   move      today         slsdte
     C                   time                    slstim
     C                   move      today         slentd
     C                   eval      slexpd = $rexpd
     C                   eval      slprty = 0
     C                   eval      xdkupd = *on

     C     skip2         tag

     *  Adjust qty into XDK slot

     C                   eval      $slwhseu = *on
     C                   eval      $slwhdpu = *on
     C                   eval      $sldispu = *on
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = $slitem

     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = 0
     C                   eval      $saqty2 = 0
     C                   eval      $saqty3 = 0
     C                   select
     C                   when      h1umt = 'N'
     C                   eval      $saqty1 = h1qty
     C                   when      h1umt = '1'
     C                   eval      $saqty2 = h1qty
     C                   when      h1umt = '2'
     C                   eval      $saqty3 = h1qty
     C                   endsl

     C                   eval      $sacwtau = *on
     C                   eval      $sacwta  = 0
     C                   eval      $sacodeu = *on
     C                   eval      $sacode  = '@@'
     C                   eval      $samemou = *on
     C                   eval      $samemo  = ' '
     C                   eval      $sabyu   = *on
     C                   eval      $saby    = puser

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'XDK'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = pttrn#
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saLbl#U = *on
     C                   eval      $saLbl# = newlbl#
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = 1
     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = '*XD'
     C                                       + %editc(pttrn#:'X')
710cAc                   eval      hokey  = $saToLcns
     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'Y'
     C                   eval      $saFrmLcnsU = *on
     C                   eval      $saFrmLcns = $saToLcns
     C                   eval      $saOLcnsU = *on
     C                   eval      $saOLcns = $saToLcns

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%ADJUSTOSS'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      zmflag  = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif
     *
     C     endux         endsr
     *----------------------------------------------------------------
     *
     *  ZZUXFL  DRI crossdocking for full system.
     *
     C     zzuxfl        begsr
     C                   eval      xdkupd = *off
     *
     *   Calculate quantity needed.
     *
     C                   if        h1umt = 'N'
     C                   eval      q1lft = h1qty
     C                   eval      need1 = h1qty
     C                   else
     C                   if        h1umt = '1'
     C                   eval      q2lft = h1qty
     C                   eval      need2 = h1qty
     C                   else
     C                   if        h1umt = '2'
     C                   eval      q3lft = h1qty
     C                   eval      need3 = h1qty
     C                   endif
     C                   endif
     C                   endif
     *
     *  See if xdock slot exists
     *
     *     Note: When program is updated to work directly with
     *           DRI interface, this can be replaced with %GETXDOCK.
     *
     C                   eval      k3stat = 'XD'
     C     keys3b        setll     slot3
     C                   dow       forevr = forevr
     C                   read      slot3                                  79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *    Double verify that slot is an xdock slot in same department.
     *
     C                   if        slaisl <> 'XDK'  or
     C                             slwhdp <> #rcvwhdp
     C                   iter
     C                   endif
     *
     *    XDock slot found for item. Update receiving.
     *
     C                   add       need1         slrcv1
     C                   add       need2         slrcv2
     C                   add       need3         slrcv3
     C                   move      today         slsdte
     C                   time                    slstim
     C                   move      today         slentd
     C                   eval      slexpd = $rexpd
     C                   eval      slprty = 0
     C                   update    s3rec
     *
     C                   exsr      zzzs2d
     C                   eval      $saitemu = *on
     C                   eval      $saitem = slitem
     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = need1
     C                   eval      $saqty2 = need2
     C                   eval      $saqty3 = need3
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%RECEIVE'
     C                   eval      $drireturn  = '*NOUPDATE*'
     C                   eval      ck4err = *off
     C                   exsr      zzzdricop
     *
     C                   if        $drireturn = '*OK'
     C                   goto      savxdr
     C                   endif
     *
     C                   leave
     *
     C                   enddo
     *
     *  XDock slot not found for item. Create one.
     *
     *     Note: When program is updated to work directly with
     *           DRI interface, this can be replaced with %CRTXDOCK.
     *
     *    Find next available XDK slot to use.
     *
     C                   exsr      zzcrxd
     *
     C                   exsr      zzzs2d
     C                   exsr      zzzfs1
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%ADD' + 'XDOCK'
     C                   eval      $drireturn  = '*NOUPDATE*'
     C                   eval      ck4err = *off
     C                   exsr      zzzdricop
     *
     C                   if        $drireturn <> '*OK'
     C                   goto      endxfl
     C                   endif
     *
     C                   exsr      zzzs2d
     C                   eval      $saitemu = *on
     C                   eval      $saitem = slitem
     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = need1
     C                   eval      $saqty2 = need2
     C                   eval      $saqty3 = need3
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%RECEIVE'
     C                   eval      $drireturn  = '*NOUPDATE*'
     C                   eval      ck4err = *off
     C                   exsr      zzzdricop
     *
     C                   if        $drireturn <> '*OK'
     C                   goto      endxfl
     C                   endif
     *
     *   Save info for final post.
     *
     C     savxdr        tag
     C                   eval      xdkupd = *on
     *
     *   Tell host quantity received into xdock slot.
     *
     C                   exsr      zzzx2d
     C                   eval      $xdqty1 = need1
     C                   z-add     need2         $xdqty2
     C                   z-add     need3         $xdqty3
     C                   eval      $dricommand = '*XDOCK'
     C                   eval      $drisubcmd  = '*RECEIVE'
     C                   exsr      zzzdricop
     *
     C     endxfl        endsr
     *----------------------------------------------------------------
     *
     *  ZZUXLC  DRI crossdocking for Locator system.
     *
     C     zzuxlc        begsr
     C                   eval      xdkupd = *off
     *
     *   Calculate quantity needed.
     *
     C                   if        h1umt = 'N'
     C                   eval      q1lft = h1qty
     C                   eval      need1 = h1qty
     C                   else
     C                   if        h1umt = '1'
     C                   eval      q2lft = h1qty
     C                   eval      need2 = h1qty
     C                   else
     C                   if        h1umt = '2'
     C                   eval      q3lft = h1qty
     C                   eval      need3 = h1qty
     C                   endif
     C                   endif
     C                   endif
     *
     *  Put crossdock into first pick slot for item.
     *
     C                   eval      k3stat = 'A '
     C                   eval      k3pick = 'Y'
     C     keys3         setll     slot3
     C     keys3         reade(n)  slot3                                  79
     *
     *    If it doesn't exist, throw error.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*NOTENGH'
     C                   goto      endxlc
     C                   endif
     *
     *    Otherwise, update slot.
     *
     *      Add crossdock qty to receive quantity.
     *
     C                   add       need1         slrcv1
     C                   add       need2         slrcv2
     C                   add       need3         slrcv3
     *
     *      Update entered date if necessary.
     *
     C                   if        slentd = 0  or
     C                             slstk1 = 0  and
     C                             slstk2 = 0  and
     C                             slstk3 = 0  and
     C                             slalc1 = 0  and
     C                             slalc2 = 0  and
     C                             slalc3 = 0  and
     C                             sltfr1 = 0  and
     C                             sltfr2 = 0  and
     C                             sltfr3 = 0  and
     C                             slpck1 = 0  and
     C                             slpck2 = 0  and
     C                             slpck3 = 0  and
     C                             slrcv1 = 0  and
     C                             slrcv2 = 0  and
     C                             slrcv3 = 0
     C                   move      today         slentd
     C                   eval      slexpd = 0
     C                   endif
     *
     *      Update expiration date if necessary.
     *
     C                   if        slexpd = 0  or
     C                             $rexpd < slexpd
     C                   eval      slexpd = $rexpd
     C                   endif
     *
     *      Update record.
     *
     C                   update    s3rec
     *
     C                   exsr      zzzs2d
     C                   eval      $saitemu = *on
     C                   eval      $saitem = slitem
     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = need1
     C                   eval      $saqty2 = need2
     C                   eval      $saqty3 = need3
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%RECEIVE'
     C                   eval      $drireturn  = '*NOUPDATE*'
     C                   eval      ck4err = *off
     C                   exsr      zzzdricop
     *
     *
     *   Tell host quantity received into xdock slot.
     *
     C                   exsr      zzzx2d
     C                   eval      $xdqty1 = need1
     C                   z-add     need2         $xdqty2
     C                   z-add     need3         $xdqty3
     C                   eval      $dricommand = '*XDOCK'
     C                   eval      $drisubcmd  = '*RECEIVE'
     C                   exsr      zzzdricop
     *
     C     endxlc        endsr
     *----------------------------------------------------------------
     *
     *  ZZWODLTJOB     Delete WORKOSS records for current job
     *
     C     zzWoDltJob    begsr

700lA /free
700lA   setll (pSessid: pUser) workoss2;
700lA   dow forevr = forevr;
700lA   reade (pSessid: pUser) workoss2;
700lA   if %eof(workoss2);
700lA     leave;
700lA   endif;
700lA /end-free
700lDC*    keywo1        setll     workoss1

700lDC*                  dow       forevr = forevr
700lDC*    keywo1        reade     workoss1
700lDC*                  if        %eof(workoss1)
700lDC*                  leave
700lDC*                  endif


     *    Delete oss slot that was created.

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = wowhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = wowhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = wodisp

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'OSS'
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%DELETEX'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *off
     C                   eval      zmflag  = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     *    Delete workoss record.

700lDC*                  delete(e) workoss1
700lMC                   delete(e) workoss2

     C                   enddo

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZXOPT   Get use extended description option
     *
     C     zzxopt        begsr
     *
     *   Get extended description option.
      /free
        uxflag = *off;
        ocode = '*ITEMMNT';
        exec sql select * into :oprec
             from options
             where opwhse = :pwhse
               and opcode = :ocode;

        If sqlstt = sqlSuccess;
          optionrec = opdata;
          if opxdsc = 'Y';
            uxflag = *on;
          endif;
        endif;
      /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *     ZZZFS1 - Fill data structure slot fields for Add.
     *
     C     zzzfs1        begsr
     *
     C                   eval      $slwhseu = *on
     C                   eval      $slwhdpu = *on
     C                   eval      $sldispu = *on
     C                   eval      $slaislu = *on
     C                   eval      $sllocu  = *on
     C                   eval      $slrlvlu = *on
     C                   eval      $slhandu = *on
     C                   eval      $slsideu = *on
     C                   eval      $slstypu = *on
     C                   eval      $slstatu = *on
     C                   eval      $slsdteu = *on
     C                   eval      $slstimu = *on
     C                   eval      $slpicku = *on
     C                   eval      $slpsequ = *on
     C                   eval      $slexpdu = *on
     C                   eval      $slrsrvu = *on
     C                   eval      $slitemu = *on
     *
     C                   endsr
     *----------------------------------------------------------------
     *     ZZZS2D - Copy slot fields into data structure fields.
     *
     C     zzzs2d        begsr
     *
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse = slwhse
     *
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp = slwhdp
     *
     C                   eval      $sldispu = *on
     C                   eval      $sldisp = sldisp
     *
     C                   eval      $slaislu = *on
     C                   eval      $slaisl = slaisl
     *
     C                   eval      $sllocu = *on
     C                   eval      $slloc = slloc
     *
     C                   eval      $slrlvlu = *on
     C                   eval      $slrlvl = slrlvl
     *
     C                   eval      $slhandu = *on
     C                   eval      $slhand = slhand
     *
     C                   eval      $slsideu = *off
     C                   eval      $slside = slside
     *
     C                   eval      $slstypu = *off
     C                   eval      $slstyp = slstyp
     *
     C                   eval      $slstatu = *off
     C                   eval      $slstat = slstat
     *
     C                   eval      $slsdteu = *off
     C                   eval      $slsdte = slsdte
     *
     C                   eval      $slstimu = *off
     C                   eval      $slstim = slstim
     *
     C                   eval      $slsdefu = *off
     C                   eval      $slsdef = slsdef
     *
     C                   eval      $sldesgu = *off
     C                   eval      $sldesg = sldesg
     *
     C                   eval      $slactvu = *off
     C                   eval      $slactv = slactv
     *
     C                   eval      $slbldu = *off
     C                   eval      $slbld = slbld
     *
     C                   eval      $slpicku = *off
     C                   eval      $slpick = slpick
     *
     C                   eval      $slpsequ = *off
     C                   eval      $slpseq = slpseq
     *
     C                   eval      $slprtyu = *off
     C                   eval      $slprty = slprty
     *
     C                   eval      $slentdu = *off
     C                   eval      $slentd = slentd
     *
     C                   eval      $slexpdu = *off
     C                   eval      $slexpd = slexpd
     *
     C                   eval      $slslfdu = *off
     C                   eval      $slslfd = slslfd
     *
     C                   eval      $slrsrvu = *off
     C                   eval      $slrsrv = slrsrv
     *
     C                   eval      $slitemu = *off
     C                   eval      $slitem = slitem
     *
     C                   eval      $slstk1 = slstk1
     C                   eval      $slstk2 = slstk2
     C                   eval      $slstk3 = slstk3
     C                   eval      $slalc1 = slalc1
     C                   eval      $slalc2 = slalc2
     C                   eval      $slalc3 = slalc3
     C                   eval      $sltfr1 = sltfr1
     C                   eval      $sltfr2 = sltfr2
     C                   eval      $sltfr3 = sltfr3
     C                   eval      $slpck1 = slpck1
     C                   eval      $slpck2 = slpck2
     C                   eval      $slpck3 = slpck3
     C                   eval      $slrcv1 = slrcv1
     C                   eval      $slrcv2 = slrcv2
     C                   eval      $slrcv3 = slrcv3
     C                   eval      $slphy1 = 0
     C                   eval      $slphy2 = 0
     C                   eval      $slphy3 = 0
     C                   eval      $slavl1 = 0
     C                   eval      $slavl2 = 0
     C                   eval      $slavl3 = 0
     C                   eval      $sladj1 = 0
     C                   eval      $sladj2 = 0
     C                   eval      $sladj3 = 0
     *
     C                   eval      $saitemu = *off
     C                   eval      $saitem = *blanks
     *
     C                   eval      $saqtyu = *off
     C                   eval      $saqty1 = 0
     C                   eval      $saqty2 = 0
     C                   eval      $saqty3 = 0
     *
     C                   eval      $saorgu = *off
     C                   eval      $saorg1 = 0
     C                   eval      $saorg2 = 0
     C                   eval      $saorg3 = 0
     *
     C                   eval      $sacwtau = *off
     C                   eval      $sacwta = 0
     *
     C                   eval      $sacodeu = *off
     C                   eval      $sacode = *blanks
     *
     C                   eval      $samemou = *off
     C                   eval      $samemo = *blanks
     *
     C                   eval      $sabyu = *off
     C                   eval      $saby = *blanks
     *
     C                   eval      $sadateu = *off
     C                   eval      $sadate = 0
     *
     C                   eval      $satimeu = *off
     C                   eval      $satime = 0
     *
     C                   eval      $saFrmVrfyu = *off
     C                   eval      $saFrmVrfy = *blanks
     *
     C                   eval      $satrn#u = *off
     C                   eval      $satrn# = 0
     *
     C                   eval      $saFrmLcnsu = *off
     C                   eval      $saFrmLcns = *blanks
     *
     C                   eval      $satasku = *off
     C                   eval      $satask = *blanks
     *
     C                   eval      $sacdspu = *off
     C                   eval      $sacdsp = *blanks
     *
     C                   endsr
     *----------------------------------------------------------------
     *     ZZZX2D - Copy xdock fields into data structure fields.
     *
     C     zzzx2d        begsr
     *
     C                   eval      $xdwhseu = *on
     C                   eval      $xdwhse = pwhse
     *
     C                   eval      $xditemu = *on
     C                   eval      $xditem = ppoitem
     *
     C                   eval      $xdpou = *on
     C                   eval      $xdpo = ppo
     *
     C                   eval      $xdseq#u = *on
     C                   move      pposeq        $xdseq#
     *
     C                   eval      $xdqtyu = *off
     C                   eval      $xdqty1 = 0
     C                   eval      $xdqty2 = 0
     C                   eval      $xdqty3 = 0
     *
     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

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
     C                   eval      $liuser = puser
     C                   eval      $lipgm  = #pgm
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobnbr
     C                   eval      $liTowhse = pwhse
     C                   eval      $liTowhseu = *on
     C                   endsr

     *----------------------------------------------------------------
     *  clr$lichist  Clear $lichist data structure fields
     *----------------------------------------------------------------

     C     clr$lichist   begsr
     C                   eval      savever# = $lrver#
     C                   clear                   $lichist
     C                   eval      $lrver# = savever#
     C                   eval      $lremp# = $emp#
     C                   eval      $lruser = puser
     C                   eval      $lrpgm  = #pgm
     C                   eval      $lrjob  = #job
     C                   eval      $lrjobn = #jobnbr
     C                   eval      $lrwhse = pwhse
     C                   eval      $lrwhseu = *on
     C                   endsr

     *----------------------------------------------------------------
     *  clr$licinfo  Clear $licinfo data structure fields
     *----------------------------------------------------------------

     C     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
     C                   clear                   $licinfo2
     C                   eval      $lnver# = savever#

     C                   eval      $lnuser = puser
     C                   eval      $lnemp# = $emp#
     C                   eval      $lnpgm  = #pgm
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobnbr

     C                   endsr

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = $emp#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$uciinfo  Clear $uciinfo data structure fields
     *----------------------------------------------------------------

     C     clr$uciinfo   begsr
     C                   eval      savever# = $uiver#
     C                   clear                   $uciinfo
720hAC                   clear                   $uciinfo2
     C                   eval      $uiver# = savever#
     C                   eval      $uiaddemp = $emp#
     C                   eval      $uiaddusr = puser
     C                   eval      $uiaddpgm  = #pgm
     C                   eval      $uiaddjob  = #job
     C                   eval      $uiaddnbr = #jobnbr
     C                   endsr

     *----------------------------------------------------------------
     *  ProcessJSON   Process JSON string
     *----------------------------------------------------------------

      /free
       begsr ProcessJSON;

         if %len(pJSON) = 0;
           leavesr;
         endif;

         d = 1;
         dow forever = forever;

           // Get Done value

           donPos = %scan('"EntDone"': pJSON: d);
           // if findone not found check for entdone
           if donPos = 0;
             leave;
           endif;

           // Calculate beginning of done   code

           donBeg = donPos + 11;

           // Get end of done   code

           donEnd = %scan('",': pJSON: donBeg);
           if donEnd = 0;
             leave;
           endif;

           // Calculate length of option code

           donLen = donEnd - donBeg;

           // Get done   code

           opt = %subst(pJSON: donBeg: donLen);
           leave;

           d = valEnd;

         enddo;


       endsr;
      /end-free
700dA*----------------------------------------------------------------
700dA*  ZZCWTEMPLCNS Replace CW uciinfo temp lcns with new or xdk license
700dA*----------------------------------------------------------------

700dA /free
700dA   begsr zzcwtemplcns;
700dA   // M19200* now writes uciinfo records with a temp license.
700dA   // PO232 writes a single total CW uciinfo when UCI receiving is
700dA   // not being used.                                             the
700dA     // first check to see if we have CW uciinfo records to update
700dA     exsr clr$uciinfo;
700dA     $uiWhse = pwhse;
700dA     $uiLcns = 'T' + ppo + %editc(pposeq:'X');
700dA     $dricommand = '*UCIINFO';
700dA     $drisubcmd  = '%GETLICREC';
700dA     $drisys2upd = 'D';
700dA     ck4err = *on;
700dA     zmflag  = *off;
700dA     exsr zzzdricop;
700dA     if error = *on;
700dA       leavesr;
700dA     endif;
700dA      dou $drireturn = '*DONE';
700dA       exsr clr$uciinfo;

700dA       $uiWhse = pwhse;
700dA       $uiLcns = 'T' + ppo + %editc(pposeq:'X');

700dA       $dricommand = '*UCIINFO';
700dA       $drisubcmd  = '%GET1UCI';
700dA       $drisys2upd = 'D';
700dA       ck4err = *on;
700dA       zmflag  = *off;
700dA       exsr zzzdricop;
700dA       if error;
700dA       endif;
700dA       if $drireturn <> '*DONE';

700dA         // replace - which will add a new record
720fA         select;
720fA           when directed = 'Y';
720fA             $uilcns  = hokey;
720hA             $uiAlcns  = hokey;
720hA             $uiAolcns  = hokey;
720fA           when PSRcvReq = 'Y';
720fA             $uilcns  = lilcns;
720hA             $uiAlcns  = lilcns;
720hA             $uiAolcns  = lilcns;
720fA           when psrusr = 'Y';
720fA             $uilcns  = lilcns;
720hA             $uiAlcns  = lilcns;
720hA             $uiAolcns  = lilcns;
720fA           other;
720fA             $uilcns  = $saToLcns;
720hA             $uiAlcns  = $saToLcns;
720hA             $uiAolcns  = $saToLcns;
720fA         endsl;
720fD         //$uilcns = $satolcns;
700dA         $uiselcseq = 0;
700hA         if BrandReq = 'Y';
700hA           $uiitem = BrandedItm;
700hA         endif;

700dA         $dricommand = '*UCIINFO';
700dA         $drisubcmd  = '%REPLACE';
700dA         $drisys2upd = 'D';
700dA         ck4err = *on;
700dA         zmflag  = *off;
700dA         exsr zzzdricop;
700dA         if error;
700dA         endif;
700dA       // now delete the originals

700dA       $uiLcns = 'T' + ppo + %editc(pposeq:'X');

700dA       $dricommand = '*UCIINFO';
700dA       $drisubcmd  = '%DELETE1';
700dA       $drisys2upd = 'D';
700dA       ck4err = *on;
700dA       zmflag  = *off;
700dA       exsr zzzdricop;
700dA       if error;
700dA       endif;
700dA       endif;
700dA     enddo;

700dA   endsr;
700dA /end-free

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*XDOCK'
     C                   eval      $dridata = $xdock
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
     C                   eval      $dridata2 = $licinfo2
     C                   when      $dricommand = '*LICHIST'
     C                   eval      $dridata = $lichist
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $dridata = $license
     C                   eval      $dridata2 = $license2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $dridata = $uciinfo
720hAC                   eval      $dridata2 = $uciinfo2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                             or $dricommand = '*LICENSE'
     C                             or $dricommand = '*LICINFO'
720hAC                             or $dricommand = '*UCIINFO'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      %error and ck4err = *on
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #pgm
     C                   select
     C                   when      zmsflag
     C*                  exsr      zm0105s
     C                   when      zmflag
     C*                  exsr      zm0105
     C                   endsl

     C                   when      $drireturn <> '*OK' and ck4err = *on
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*XDOCK'
     C                   eval      $xdock = $dridata
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
     C                   eval      $licinfo2 = $dridata2
     C                   when      $dricommand = '*LICHIST'
     C                   eval      $lichist = $dridata
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $license = $dridata
     C                   eval      $license2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $uciinfo = $dridata
720hAC                   eval      $uciinfo2 = $dridata2
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      ck4err = *off
     C     enddricop     endsr

     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Aisle
Start From
Starting Level
Detail record
Starting Number
Current Maximum Level
Future Maximum Level
Racks on One Side
Duplicate license numbers found
license number
Status
Status, cannot be A, V, or Z
