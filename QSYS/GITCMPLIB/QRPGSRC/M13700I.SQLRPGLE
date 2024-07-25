      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  FM13700I     Purchase Order Receiving License Entry - Init fields
     *  17 July 2014
     *  Lynn McMahon
     *
     *  Revisions:
     *
650 A*    07/17/14  LMC  6.50
     *      - Created.
700aA*    06/07/16  LMC  7.00a
     *      - CW ovr filds were move to pirhold record. Remove D specs
     *      - Fix: RCVPO transactions were not working correctly.
700b *    10/14/16  LMC  7.00b
     *      - Enh: Find the double quotes replace with \".
     *        Then gui will be able to process the json without error.
700c *    11/09/16  LMC  7.00c
     *      - Enh: Removed UPC file spec, file was not being used.
710aA*    09/26/17  LMC  7.10a
     *      - Enh: Allow for a user to select cross dock XD status.
     *        treat the receipt just like if the podtl pdspcl field
     *        was set to XD.
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pPO         Purchase Order
     *      pPOSeq      Sequence
     *      pPOItem     Item
     *
     *    Returned Parameters
     *      pOutStr     JSON output string
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

416 AFslot3     uf   e           k disk
     F                                     rename(slrec:s3rec)
     Foptions   if   e           k disk    rename(oprec:oprec1)
530aAFslot10    if   e           k disk
530aAF                                     rename(slrec:s10rec)

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getclien

     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             50    dim(12) ctdata perrcd(1)
     D a10             s              1    dim(10)
     D a13             s              1    dim(13)
     D $parms1         s             48    dim(20)
     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#saval
      /copy qcopysrc,id#sgc
      /copy qcopysrc,id#dairyla
      /copy qcopysrc,id#glazier
      /copy qcopysrc,id#icb
510aA /copy qcopysrc,id#packers
TPCaA /copy qcopysrc,id#tpc
HSYaA /copy qcopysrc,id#halsey
EGFaA /copy qcopysrc,id#egf
RYLaA /copy qcopysrc,id#royal
CSP A /COPY QCOPYSRC,Id#Coastal
EFCaA /COPY QCOPYSRC,Id#Eastlan
GFS A /COPY QCOPYSRC,Id#GFS
CLDaA /copy qcopysrc,id#citylin

RNZaA*----------------------------------------------------------------
RNZaA*  P/O Detail Misc. /copy mbrs
RNZaA*
RNZaA /copy qcopysrc,podm1_rtx
RNZaA /copy qcopysrc,podm2_rtx
RNZaA /copy qcopysrc,podm3_rtx
RNZaA /copy qcopysrc,podm4_rtx
RNZaA /copy qcopysrc,podm5_rtx
RNZaA*
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D psessid         s             40
     D pWhse           s              3p 0
     D pPo             s              9
     D pPOSeq          s              5p 0
     D pPOItem         s             15
     D  pOutStr        s           1024    varying

     D client          s             10
     D clientloc       s             10

     D*wolbl           s             13
     D*woitem          s             65
     D*wolbls          s             13
     D*wositm          s             65
     D*wodsc1          s             40
     D*wodsc2          s             40
     D*w1um1           s              5
     D*w1um2           s              5
     D*w1um3           s              5
     D errmsg          s             40

      * these were copies from Po232 - delete what isn't needed
     D $ldwgt          s              9  2
     D $lflag          s              1
     D*$lord           s              7  0
     D $lseq           s              5  0
     D $lum1           s              5
     D $lum2           s              5
     D $lum3           s              5
     D $lven           s             11  0
     D $lvitm          s             15
     D $lvnam          s             40
     D $pw1pti         s              4  0
     D $swhse          s                   like(pwhse)
     D $msgf           s             10
     D #bsu1           s              5
     D #bsu2           s              5
     D #bsu3           s              5
     D #msgid          s              7
     D #msgtp          s              7
     D #odesc          s             30
     D #oitem          s             15
     D #opdsc          s             15
     D #osu1           s              5
     D #osu2           s              5
     D #osu3           s              5
     D #oswgt          s              7  2
     D #oswt2          s              7  2
     D #oswt3          s              7  2
     D #otype          s              1
     D #oum1           s              2
     D #oum2           s              2
     D #oum2q          s              3  0
     D #oum3           s              2
     D #oum3q          s              3  0
     D #oven#          s             10  0
     D #sitem          s             15
     D*avgwt1          s              7  2
     D*avgwt2          s              7  2
     D*avgwt3          s              7  2
     D chk4err         s               n
     D ckexdt          s              8  0
     D ckqrc1          s                   like(pdqrc1)
     D clear           s              5  0
     D cmdtkn          s              1
     D CnvWgt          s              9  2
     D comand          s              5  0
     D cwcalc          s              1  0
     D*cwovr           s              1
     D date1           s              8  0
     D date16          s              6  0
     D date2           s              8  0
     D date2o          s              6  0
     D date26          s              6  0
     D*ddcode          s              1
     D done            s              1
     D*dtchk           s              1
     D*dtchk2          s              1
     D*dtchk3          s              1
     D*dtchk4          s              1
     D dtfrmt          s              1  0
     D e               s              2  0
     D*enter           s              5  0
710aDD*eof             s              1
     D*error           s              1
     D exdtj           s              5  0
     D*expd            s              8  0
     D expdj           s              5  0
700aDD*exwgt           s              9  2
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
700aDD*hirng           s              9  2
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
700aDD*KiloLbs         s              1
     D kyitem          s                   like(slitem)
     D kypick          s                   like(slpick)
     D kystat          s                   like(slstat)
     D*lflag           s              1
     D ltstd6          s              6  0
     D ltstd8          s              8  0
     D glzmfd          s              8  0
     D lvskp           s              1
700aDD*lwrng           s              9  2
     D lwvar           s              9  2
     D mfdtj           s              5  0
     D mfgd            s              8  0
     D netdays         s              3  0
     D maxqty          s                   like(pdqrc1)
     D*mexpd           s              8  0
     D*mfgdte          s              8  0
     D nxtscr          s              3
     D ocode           s              8
     D*oaovr           s              1
     D*obovr           s              1
     D*ocovr           s              1
     D*odovr           s              1
     D*oeovr           s              1
     D*ofovr           s              1
     D ovrrid          s              1
     D part            s              1
     D poppcs          s                   like($lpcs)
700aDD*prg1c           s              4  3
700aDD*prg2c           s              4  3
     d pplot           s             20
     d pppti           s              4  0
     D*ptiovr          s              1
     D*ptichk          s              1
     d ptinodate       s              6  0
     D*qtchk           s              1
     D*qtchk1          s              1
     D qtyDiff         s              5  0
     D qtyord          s              5  0
     D qtyord1         s              5  0
     D qtyord2         s              5  0
     D qtyord3         s              5  0
     D qtyrcv          s              5  0
     D qtyrcv1         s              5  0
     D qtyrcv2         s              5  0
     D qtyrcv3         s              5  0
     D rcvpocomplete   s               n
     D rcvUnitWgt      s             11  4
     D recv            s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D*sdesig          s              1
     D*sdqrc1          s              5  0
     D*sdqrc2          s              5  0
     D*sdqrc3          s              5  0
     D ssbflg          s              1
     D stop            s              1
     D*svckq1          s                   like(pdqrc1)
     D svcwen          s              1
     D svcwfr          s              1
     D svcwtp          s              1
     D*svdwgt          s              9  2
     D svexck          s              1
     D*svexdt          s              6  0
     D svhi            s              2  0
     D*svmfdt          s              6  0
     D*svpti           s              4  0
     D svqrc1          s                   like(pdqrc1)
     D svqrc2          s                   like(pdqrc2)
     D svqrc3          s                   like(pdqrc3)
     D svrupc          s              1
     D svtie           s              4  0
     D*svupc           s             50
     D temp10          s             10
     D tmpwgt          s              9  2
     D today           s              8  0
     D todayo          s              6  0
     D todyj           s              5  0
     D*upchk           s              1
     D*upchk2          s              1
     D uxflag          s              1
     D vrfycw          s              1
     D*warn            s              1
     D wgtDiff         s             11  4
     D whse            s              3  0
     D wkmday          s              3  0
     D wkwhse          s                   like(pwhse)
     D woexdt          s              8  0
     D wofifo          s              8  0
     D*woindt          s              8  0
     D womfdt          s              8  0
     D work2           s              2
     D work4           s              4
     D wotcw           s              9  2
     D wrttyp          s              1
     D*wtchk           s              1
     D*w1upc           s                   like(upupc)
     D zmflag          s               n
     D zmsflag         s               n
     D $cstr           s             30
     D wocrcv          s             27
     D w1note          s             15
     D*w1slot          s             12
     D*w1plts          s              5s 0
     D*w1avg           s              1
     D*w1fifo          s              6s 0
     D xddone          s              1
      ******* from po236
     D xdkdri          s              1
     D xdkflg          s              1
     D xdkupd          s              1
     D xqty            s              6  0
     D w1disp          s             12
     D w1qty           s              5  0
     D w1umt           s              1
     D w1xdk           s              1
     D w1uom           s              5
     D rpal            s              3  0
     D savdsp          s             12
530aAD sv_pdspcl       s              2
     D today6          s              6  0
     d $pcmd           s              8
     D q1lft           s              5  0
     D q2lft           s              5  0
     D q3lft           s              5  0
500cAD $pcode          s             10
500cAD $phhdr          s              1
500cAD $phdtl          s              1
500cAD $phcat          s              1
     D k3pick          s                   like(slpick)
     D k3stat          s                   like(slstat)
     D locatr          s              1
     D need1           s              5  0
     D need2           s              5  0
     D need3           s              5  0
     D pctr            s              3  0
     D posrec          s              4  0
     D ptqty           s              6  0
500 AD #rcvarea        s              6
500 AD #rcvitem        s                   like($ititem)
500 AD #rcvtype        s                   like($ittype)
500 AD #rcvdesc        s                   like($itdesc)
500 AD #rcvpdsc        s                   like($itpdsc)
500 AD #rcvwhdp        s                   like($itwhdp)
500 AD #rcvstyp        s                   like($itstyp)
500 AD #rcvdesg        s                   like($itdesg)
500 AD #rcvum1         s                   like($itum1)
500 AD #rcvflg1        s                   like($itflg1)
500 AD #rcvum2         s                   like($itum2)
500 AD #rcvumq2        s                   like($itumq2)
500 AD #rcvflg2        s                   like($itflg2)
500 AD #rcvum3         s                   like($itum3)
500 AD #rcvumq3        s                   like($itumq3)
510bAD #rcvdday        s                   like($imdday)
510bAD #rcvmday        s                   like($immday)
510bAD #rcvmflg        s                   like($immflg)
510bAD #rcvuday        s                   like($imuday)
500 AD #rcvnrpk        s                   like($imnrpk)
500 AD #rcvflgd        s                   like($itflgd)
500 AD #rcvcube        s                   like($itcube)
500 AD #rcvswgt        s                   like($itswgt)
500 AD #rcvupc         s                   like($itupc)

500 AD #slotitem       s                   like($ititem)
500 AD #slottype       s                   like($ittype)
510 AD #rcvcwgt        s                   like($itcwgt)
700bAD pos             s              2  0
700bAd dblqte          s              1    inz('"')
700bAd rpldblqte       s              2    inz('\"')
RNZaA*----------------------------------------------------------------
RNZaA*  Working variables
RNZaA*
RNZaAD rtxall9item     C                   const('9999999999')
DRYcAD digits          c                   const('0123456789')

      /copy qcopysrc,C#PIRHLDPO
     *----------------------------------------------------------------
     * Data structure
     *
     *    OPRUPC  -  Prompt user for Retail UPC during receiving? (Y,N)
     *    OPRUPS  -  Allow user to skip Retail UPC scan? (Y,N)
     *    OPRUPF  -  Require Retail UPC on file before receipt? (Y,N)
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
     D  optend               117    117
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
     D  opexck                28     28
     D  opcwen                29     29
     D  opcwtp                30     30
     D  opcwfr                31     31
     D  opipck                32     32
     D  oprupc                33     33
     D  oprups                34     34
     D  oprupf                35     35
     *  *SYSTEM  -  System options.
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *****OPWRNC  -  Perform catch weight variance check (Y,N).
     *    OPWRNC  -  Check CW variance in Truck Builder (N,M,C,B)
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
     *****OPICW   -  Individual catch weight entry (Y,N).
     *    OPICW   -  Check CW count in Truck Builder. (N,M,C,B)
     *    OPMPCK  -  Allow multiple pick slots for fixed items (Y/N).
     *    OPRCDY  -  Number of days to keep receiving logs.
     *    OPPKDY  -  Number of days to keep picking logs.
     *    OPRTHS  -  Number of weeks - exported routes to keep.
     *    OPCRHS  -  Number of weeks - exported customer rtns to keep.
     *    OPPOHS  -  Number of weeks - exported p/o's to keep.
     *    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
     *    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
     *    OPTBJQ  -  Run Truck builder on Job Que (Y/N)
     *    OPISHS  -  Number of weeks to keep history file
     *    OPUCI   -
     *    OPWRNCR -  Check CW var during RCV individual Entry
     *    OPICWR  -  Check CW count during RCV individual Entry
     *    OPTRAX  -  Using TRAX module (Y/N).
     *
     D* opepm                  1      1
     D* oprf                   2      2
     D* opcapc                 3      3
     D* opletd                 4      4
     D* opwrnc                 5      5
     D* oprg1c                 6      8  1
     D* oprg2c                 9     11  1
     D* opimpi                12     12
     D* opicw                 13     13
     D* opmpck                14     14
     D* oprcdy                15     15  0
     D* oppkdy                16     16  0
     D* oprths                17     19  0
     D* opcrhs                20     22  0
     D* oppohs                23     25  0
     D* opiahs                26     28  0
     D* opmshs                29     31  0
     D* optbjq                32     32
     D* opishs                33     35  0
     D* opishsa               33     35
     D* opuci                 36     36
     D* opwrncr               37     37
     D* opicwr                38     38
     D* optrax                39     39
610gA*----------------------------------------------------------------
610gA*  *SYSTEM   -  System options.
610gA*----------------------------------------------------------------
610gA*
610gA* Fields
610gA*
610gA*    OPUCI   -  Use UCI processing (Y,N)
610gA*----------------------------------------------------------------
610gA*
610gA* Data structure
610gA*
610gAD opdat4          ds
610hDD**opuci                 33     33
610hMD  opuci                 36     36
610gAD  op4end               117    117
416aA*  *FEATURE  -  PIR Feature options.
416aA*----------------------------------------------------------------
416aA*
416aA* Fields
416aA*
416aA*    OPFEAT  -  PIR Installed feature.
416aA*                 1=Locator system installed.
416aA*                 2=Full system installed.
416aA*                 3=Stand Alone system installed.
416aA*
416aA* Data structure
416aA*
416aAD opdat3          ds
416aAD  opfeat                 1      1
416aAD  op3end               117    117
     *
     *----------------------------------------------------------------
     *  Working fields.
     *
     D                 ds
     D  lottrk                 1      4
     D  lictrk                 5      8

     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  Constants
     D move1           c                   const('MOVEIN PICK')
     D move2           c                   const('MOVEIN OVERFLOW')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @getsi          c                   const('GETSLOTITM')
     D @pwd            c                   const('CHKLIST')
     D @fmtit          c                   const('FRMTIT')
     D @fmti2          c                   const('FRMTIT2')
     D @crtrcv         c                   const('CRTRCVTRN')
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
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *   Redefine key
     D  $lwhse                19     21  0
     D  $litem                22     36
     D  $lpo                  37     45
     D  $lrq1                 46     50  0
     D  $lrq2                 51     55  0
     D  $lrq3                 56     60  0
     D  $lrpal                61     63  0
     D* $llott                64     64
     D* $llict                65     65
     *
     D  $lwhs2                19     21  0
     D  $lwhd2                22     26
     D  $litm2                27     41
     D  $ldisp                42     53
     D  $ldesg                54     58
     D  $lst                  59     60
     D  $lsdef                61     62
     D  $lactv                63     64
     *
     D  $llot                 37     37
     D  $lltrk                38     38
     *
     D  $lmfr#                22     32  0
     D  $lmfritem             33     47
     D  $ldakitem             48     62
     *
     D $mparm          ds
     D  $mcmd                  1      8
     D  $mprg                  9     18
     D  $muky                 19     68
     D  $mrtn                 69     76
     D  $merm                 77    136
     D  $mmsg                 77     80
     *   Redefine key
     D  $mwhs3                19     20p 0
     D  $mpo3                 21     29
     D  $mseq                 30     32p 0
     D  $mitm3                33     47
     D  $mqyr1                48     50p 0
     D  $mqyr2                51     53p 0
     D  $mqyr3                54     56p 0
     D  $mcwte                57     59p 0
     D  $mcwtt                60     64p 2
     D  $mcwta                65     68p 2

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#ITEM
417yA /COPY *libl/qcopysrc,C#XDOCK
     D savever#        s                   like($itver#)
     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D pdrec         E Ds                  Extname(podtl)
     D pdmrec        E Ds                  Extname(podtlm)
     D phrec         E Ds                  Extname(pohdr)
     D oprec         E Ds                  Extname(options)
     D umrec         E Ds                  Extname(unmesr)
700cDD*uprec         E Ds                  Extname(upc)
     D horec         E Ds                  Extname(pirhold)
     *----------------------------------------------------------------

     c     *entry        plist
     C                   parm                    pSessId
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pPOSeq
     c                   parm                    pPOItem
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;

         exsr zzinz2;
700aD    //exsr zzrcvpocheck;
700bA    // let's check for our double quotes and replace
700bA    // woitem
700bA    pos = %scan(dblqte: woitem);
700bA    dow pos > 0;
700bA       woitem = %replace(rpldblqte: woitem: pos: %len(dblqte)) ;
700bA       if (pos+%len(rpldblqte) > %len(woitem));
700bA          pos = 0;
700bA       else;
700bA          pos = %scan(dblqte: woitem: pos+%len(rpldblqte));
700bA       endif;
700bA    enddo;
700bA    // wodsc1
700bA    pos = %scan(dblqte: wodsc1);
700bA    dow pos > 0;
700bA       wodsc1 = %replace(rpldblqte: wodsc1: pos: %len(dblqte)) ;
700bA       if (pos+%len(rpldblqte) > %len(wodsc1));
700bA          pos = 0;
700bA       else;
700bA          pos = %scan(dblqte: wodsc1: pos+%len(rpldblqte));
700bA       endif;
700bA    enddo;
700bA    // wodsc2
700bA    pos = %scan(dblqte: wodsc2);
700bA    dow pos > 0;
700bA       wodsc2 = %replace(rpldblqte: wodsc2: pos: %len(dblqte)) ;
700bA       if (pos+%len(rpldblqte) > %len(wodsc2));
700bA          pos = 0;
700bA       else;
700bA          pos = %scan(dblqte: wodsc2: pos+%len(rpldblqte));
700bA       endif;
700bA    enddo;

         // Put together JSON string

         pOutStr = '{'
                +  '"Err":"'  + %trimr(Errmsg) + '",'
                +  '"wocrcv":"'  + %trimr(wocrcv) + '",'
                +  '"wolbl":"'  + %trimr(wolbl) + '",'
                +  '"woitem":"'  + %trimr(woitem) + '",'
                +  '"w1plts":"'  + %char(w1plts) + '",'
                +  '"w1note":"'  + %trimr(w1note) + '",'
                +  '"wositm":"'  + %trimr(wositm) + '",'
                +  '"wodsc1":"'  + %trimr(wodsc1) + '",'
                +  '"wodsc2":"'  + %trimr(wodsc2) + '",'
                +  '"w1um1":"'  + %trimr(w1um1) + '",'
                +  '"w1um2":"'  + %trimr(w1um2) + '",'
                +  '"w1um3":"'  + %trimr(w1um3) + '",'
                +  '"w1qrc1":"'  + %char(w1qrc1) + '",'
                +  '"w1qrc2":"'  + %char(w1qrc2) + '",'
                +  '"w1qrc3":"'  + %char(w1qrc3) + '",'
                +  '"wolbls":"'  + %trimr(wolbls) + '",'
                +  '"done":"'  + %trimr(xddone) + '",'
                +  '"dept":"'  + %trimr($itwhdp) + '"';

         // Close off the JSON string
         pOutStr += '}';

      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;


         getclient(client: clientLoc);
         exsr zzinz;

       endsr;

      /end-free

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
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
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

     C                   when      chk4err and %error
     C                   eval      error = *on

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr
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
700aMC                   parm      savetrn       $lsavetrn         7 0
     C                   parm                    $ppo              9
     C                   parm      $itstyp       $litstyp          1
     C                   parm      $itwhdp       $litwhdp          5
     C                   parm                    $lrtnr           10
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *  Convert today's date into century format.
     *  Move from ZZINZ to get date each time.
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *  Convert today's date into MMDDYY format.
     C                   eval      $cvcmd = '*CURMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today6 = $cvd6o
     *
      /free
         hokey = %trim(pPO) + %trim(%editc(pPOSeq:'X')) + %trim(pPOItem);
         exec sql select * into :horec
              from pirhold
              where hosess = :pSessId
                and hokey  = :hokey
                and hotype = 'PODTL';
           If sqlstt = sqlSuccess;
               pirhldpods = hodata;
           else;
             error = *on;
             errmsg = 'NO Entry found to apply License';
             return;
           endif;

      /end-free
     *  Initialize quantity left.
     *
     C                   eval      q1lft = w1qrc1
     C                   eval      q2lft = w1qrc2
     C                   eval      q3lft = w1qrc3
     *
     *  Initialize variables.
     *
     C                   eval      need1 = 0
     C                   eval      need2 = 0
     C                   eval      need3 = 0
     C                   eval      pctr = 0
     C*                  eval      l = *zeros
     C*                  eval      lcns = *blanks
     *
     *   Get total quantity
     C                   eval      ptqty = w1qrc1
     C                   add       w1qrc2        ptqty
     C                   add       w1qrc3        ptqty
     *
     *   Move PO
     *
     C*                  eval      w1po = ppo
     *
     *   Save PDSPCL.  If it's 'XD', it's a cross dock item.
     *
     C                   eval      sv_pdspcl = ' '
      /free
         exec sql select * into :pdrec
              from podtl
              where pdwhse = :pWhse
                and pdpo   = :pPO
                and pdseq  = :pPOSeq
                and pditem = :pPOItem;
           If sqlstt = sqlSuccess;

             if client = dairyland;
               sv_pdspcl = ' ';
             else;
               sv_pdspcl = pdspcl;
             endif;
           else;
           endif;
710aA      if w1stat = 'XD';
710aA          sv_pdspcl = 'XD';
710aA      endif;
      /end-free
     *
     *   Get item description.
     *
     C                   exsr      zzxopt
     *
     C                   eval      woitem = *blanks
     C                   eval      wodsc1 = *blanks
     C                   eval      wodsc2 = *blanks

     *  Use DRI interface to get item.

     C                   exsr      clr$item
     C                   eval      $itwhse  = pwhse
     C                   eval      $ititem  = ppoitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETALL'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err= *on
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
     *
     *       updated and treated as a cross dock item.
     C                   if        client = CoastalSunbelt
     C                             and $itdesg = 'JIT  '
     C                   eval      pdspcl = 'XD'
     C                   eval      sv_pdspcl = 'XD'
     C                   endif

     C                   eval      #rcvitem = $ititem
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

     C                   if        uxflag = '0'
     C                   eval      $iitem = ppoitem
     C                   eval      $idesc = $itdesc
     C                   eval      $ipdsc = $itpdsc
     C                   eval      $istr = *blanks
     C*                  if        $pprg = 'PO200'
     C                   if         $pcmd = '*NONE   '
     C                   call      @fmti2
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   else
     C                   call      @fmtit
     C                   parm                    $iitem
     C                   parm                    $idesc
     C                   parm                    $ipdsc
     C                   parm                    $istr
     C                   endif
     C                   movel     $istr         woitem
     C                   else
     C                   movel     ppoitem       woitem
     C                   eval      wodsc1 = $ixdsc1
     C                   eval      wodsc2 = $ixdsc2
     C                   endif
     *  Halsey - Get item pick slot to display.
     C                   if        client = halsey
     C                             or client = egf
     C                   eval      k3stat = 'A '
     C                   eval      k3pick = 'Y'
      /free
        setll (pwhse: $ititem: kystat: kypick) slot3;
        reade(n) (pwhse: $ititem: kystat: kypick) slot3;
        if not %eof(slot3);
      /end-free
     C                   move      sldisp        wodsc2
     C                   endif
     C                   endif

     *  Use DRI interface to get Slot item.

     C                   exsr      clr$item
     C                   eval      $itwhse  = pwhse
     C                   eval      $ititem  = ppoitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETSLOT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err= *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   clear                   #slotitem
     C                   clear                   #slottype
     C                   endif

     C                   eval      #slotitem = $ititem
     C                   eval      #slottype = $ittype
     *
     C     enditm        tag
     *    Get User's employee number to be written to PORCV file
     *    if any records are flagged as touched.
     *
     C                   call      'GETUSER'
     C                   parm      #curruser     $code            10
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
     *   Select first screen to display.
     *
     C                   exsr      scr01i

     *  Get live status for item's department.

     C                   call      'CHKLIVE'
     C                   parm      pwhse         $pwhs             3 0
     C                   parm                    #rcvwhdp
     C                   parm                    livestat          8

     *  If department is not live, then post and get out.
     *  Or, if cross dock item, then post and get out.

     C                   if        livestat = '*NOTLIVE'
     C                             or sv_pdspcl = 'XD'
      *****temporary - this will call the update program - not done in init
     C*                  exsr      zzupd1
     C*                  if        error = *off
     C*                  eval      nxtscr = 'EOJ'
     C*                  endif
     C                   endif
     C     endinz        endsr
     *----------------------------------------------------------------
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
             where opwhse = :pWhse
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
     *
     *     Screen initialization and wrap-up routines
     *
     *----------------------------------------------------------------
     *
     *  Screen 01 initialization
     *
     C     scr01i        begsr
     C                   exsr      zzget1
     C                   exsr      zzfil1
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
      * get item category

     C*                  call      'GETICAT'
     C*                  parm                    pwhse
     C*                  parm                    ppoitem
     C*                  parm                    $pcode
     C*                  parm                    $phhdr
     C*                  parm                    $phdtl
     C*                  parm                    $phcat
     C*
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *   Move PO
     *
     C*                  eval      w1po = ppo
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
     C                   eval      savdsp = *blanks
     C     1             do        rpal          x
      ***** temporary mark out - first round mrc
640gAc*                  if        $pgslcns <> ' '
640gAc*                  eval      w1lcns = $pgslcns
640gAc*                  endif
     C                   if        xdkflg = *off
     C                   exsr      zzpxdk
     C                   eval      xdkflg = *on
     C                   endif
     C                   eval      w1disp = *blanks
     C                   eval      w1xdk = *blanks
     *
     C                   select
     C                   when      need3 > 0
     C                   eval      w1disp = savdsp
     C                   eval      w1xdk = 'Y'
     C                   eval      w1qty = need3
     C                   eval      w1umt = '2'
     C                   if        client <> tpc
     C                             and client <> sgc
     C                             and client <> royal
     C                   endif
     C                   eval      need3 = 0
     *
     C                   when      need2 > 0
     C                   eval      w1disp = savdsp
     C                   eval      w1xdk = 'Y'
     C                   eval      w1qty = need2
     C                   eval      w1umt = *on
     C                   if        client <> tpc
     C                             and client <> sgc
     C                             and client <> royal
     C                   endif
     C                   eval      need2 = 0
     *
     C                   when      need1 > 0
     C                   eval      w1disp = savdsp
     C                   eval      w1xdk = 'Y'
     C                   eval      w1qty = need1
     C                   eval      w1umt = 'N'
     C                   if        client <> tpc
     C                             and client <> sgc
     C                             and client <> royal
     C                   endif
     C                   eval      need1 = 0
     *
     C                   when      pctr > 0
     C                   if        q3lft <> 0
     C                   eval      w1qty = q3lft
     C                   eval      q3lft = 0
     C                   eval      w1umt = '2'
     C                   eval      pctr = pctr - 1
     C                   else
     C                   if        q2lft <> 0
     C                   eval      w1qty = q2lft
     C                   eval      q2lft = 0
     C                   eval      w1umt = *on
     C                   eval      pctr = pctr - 1
     C                   else
     C                   eval      w1umt = 'N'
     C                   eval      pctr = 0
     C                   eval      rpal = rpal - 1
     C                   endif
     C                   endif
     *
     C                   other
     *
     *    Only 2nd breakdown qty received. Use brkdn 2 u/m.
     C                   select
     C                   when      w1qrc3 > 0  and
     C                             w1qrc2 = 0  and
     C                             w1qrc1 = 0
     C                   eval      w1umt = '2'
     *
     *    Only 1st breakdown qty received. Use brkdn 1 u/m.
     C                   when      w1qrc2 > 0  and
     C                             w1qrc3 = 0  and
     C                             w1qrc1 = 0
     C                   eval      w1umt = *on
     *
     *    Only case qty received. Use case u/m.
     C                   other
     C                   eval      w1umt = 'N'
     C                   endsl
     C                   endsl
     *
     *
     C                   if        w1xdk = 'Y'
     C                   eval      *in69 = *on
     C                   else
     C                   eval      *in69 = *off
     C                   endif
     *
     C                   select
     C                   when      w1umt = '1'
     C                   eval      w1uom = w1um2
     *
     C                   when      w1umt = '2'
     C                   eval      w1uom = w1um3
     *
     C                   other
     C                   eval      w1uom = w1um1
     C                   endsl

     *    If qty is 0 and only a single pallet is being received,
     *      Then we assume that we are receiving 1 pallet of normal qty
     *           and set the subfile qty to the total qty being received

     C                   eval      *in13 = *off
     C                   eval      *in12 = *off
     C                   if        w1qty = 0 and w1plts = 1
     C                   eval      w1qty = w1qrc1
     C                   eval      *in13 = *on
     c                   else
     c                   eval      *in12 = *on
     C                   endif

     *
     C                   enddo
     C                   eval      posrec = 1
     C                   eval      w1stat = *blank
      * OSS Receiving
      /free
          w1note = ' ';
          *in96 = '0';
        if osscode <> ' ';
          w1note = 'OSS Receiving';
          *in96 = '1';
        endif;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *
     *     OPTIONS
     C     opkey         klist
     C                   kfld                    pwhse
     C                   kfld                    ocode
     C                   eval      forevr = *off
     *
     *  Get Feature option.
     *
     C                   eval      ocode = '*FEATURE'
     C     opkey         chain     options                            79
     C                   if        *in79
     C                   eval      opfeat = '2'
     C                   else
     C                   eval      opdat3 = opdata
     C                   endif
     C                   if        opfeat = '1'
     C                   eval      locatr = *on
     C                   else
     C                   eval      locatr = *off
     C                   endif
     *
     *  Get System option.
     *
     C                   eval      ocode = '*SYSTEM '
     C     opkey         chain     options                            79
     C                   if        *in79
     C                   eval      opuci  = 'N'
     C                   else
     C                   eval      opdat4 = opdata
     C                   endif
     *
     C                   eval      $lprg = #pgm

      *************
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   eval      $cvprg = #prog
     C                   endsr
     C*
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
      /free
        chain (pwhse: ppoitem: kystat) slot10;
      /end-free
     C                   if        not %found(slot10)
     C                   eval      need1 = w1qrc1
     C                   eval      need2 = w1qrc2
     C                   eval      need3 = w1qrc3
     C                   goto      endpx
     C                   endif
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
     **                   ITER
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
     *   Get out if when nothing left.
     *
     *
     C                   endif
     *
     *
     C     endpx         endsr
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
     C                   eval      $xdpo = $ppo
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
