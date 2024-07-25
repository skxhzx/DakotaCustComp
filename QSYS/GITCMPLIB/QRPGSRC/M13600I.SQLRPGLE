      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  FM13600I     Purchase Order Receiving Entry - Init fields
     *  25 June 2014
     *  Lynn McMahon
     *
     *  Revisions:
     *
650 A*    06/25/14  LMC  6.50
     *      - Created.
     *      - Returns values for displaying correct fields on entry screen
     *
700aA*    10/12/15  LMC  7.00
     *      - Added NDlcns used with UCI receiving
700bA*    01/19/16  LMC  7.00b
     *      - Added extracting uci scanned data
700cA*    02/16/16  LMC  7.00c
     *      - Need to identify fields that should be protected when
     *        UCI receiving and ai codes in scanned barcode.
700dA*    03/15/16  LMC  7.00d
     *      - Only load up dates and protect fields on UCI scan based
     *        on the correct ND(non Display) so only load exp dates if
     *        NDEXPD is blank. same for MFG Date.
     *        prior to this modification, if an expiration date was
     *        in the barcode scanned, but the item was mfg date type
     *        the expiration date extracted was displayed in the MFG
     *        date on the entry form. M1360*
700eA*    04/15/16  LMC  7.00e
     *      - Added logic to check if user is authorized to do pick
     *        slot receiving for city line.
700fA*    04/19/16  LMC  7.00f
     *      - Added logic for metric systen changes.
     *      - reset NDlot if uci scanning and lot found in gs1 barcode.
     *        we will show and store the lot from the gs1 barcode.
700gA*    05/24/16  LMC  7.00g
     *      - Enh - Added to check for Branded Items, send flag back
     *      - Enh - If no pick slot for item - set alwpsr = 'N'
     *      - Enh - Allow upc load.
     *      - CW ovr filds were move to pirhold record. Remove D specs
700h *    06/10/16  LMC  7.00h
     *      - Fix: RCVPO transactions were not working correctly.
     *        Empl was not being populated.
700i *    10/14/16  LMC  7.00i
     *      - Enh: Find the double quotes replace with \".
     *        Then gui will be able to process the json without error.
700j *    10/18/16  LMC  7.00j
     *      - Enh: Set brand non display flag to off if either the
     *        item is setup with a brand flag or if the item is setup
     *        in the itembrd file.
700k *    11/09/16  LMC  7.00k
     *      - Enh: Capture breakdown upc if needed.
710aA*    05/02/17  LMC  7.10a
     *      - Enh: Added logic for new RCVLBL option -
     *        Allow Gui multiple pallet Receiving.
710bA*    09/11/17  LMC  7.10b
     *      - Fix: when processing super po, and upc was scanned
     *        we aren't finding the upc to load, because the PODTLUCI
     *        record in pirhold has the super po number, and we are
     *        checking for the pO#. Need to see if po is on super and
     *        also check for the super po# in the PODTLUCI, if we did
     *        not find a match on the PO.
720a *    11/06/18  LMC  7.20a
     *      - Enh: We are changing the values we replace invalid
     *        characters to a space.
     *      - Enh: Had a client with '\' in description will be
     *        replaced with a space because it causes freemarker error
     *        with the json.
730a *    07/12/19  LMC  7.30a
     *      - Fix: Only show PTI field if the item is setup for PTI
     *        selection.
730b *    08/21/19  LMC  7.30b
     *      - Enh: Don't divide by #oum2q unless there is a value in
     *        there. We don't typically have #oum3q and nothing in
     *        #oum2q. But with new pick to weight setup we allow this.
740  *    06/19/20  KDE  7.40
     *      - Enh: Add support for ASN auto data population
     *      - Reload data when asn/lpn
740a *    07/17/20  LMC  7.40a
     *      - ENH: Adding new receiving option edits.
     *      - Allow pick slot receiving. This was
     *        previously handled by a client modification.
     *        I will leave the client mod, but add the new option so
     *        anyone who needs this going forward will use the new
     *        option and not require a client custom mod.
     *      - Show qty ordered during receiving. Uses NDqord field.
     *        previously handled by a client modification.
     *        I will leave the client mod, but add the new option so
     *        anyone who needs this going forward will use the new
     *        option and not require a client custom mod.
     *      - Allow Outside storage receiving.
740b *    12/30/20  LMC  7.40b
     *      - ENH: disable pick slot recieving if the item on the po
     *        is an ssb item, and the base item has no breakdown uom.
750a *    01/20/21  RTR  7.50a
     *      - Fix: Trap duplicate key error writing to PIRHOLD.
750b *    08/23/21  LMC  7.50b
     *      - Enh: Directed putaway is not allowed for breakdown
     *        Receiving. Will blank out the w1um2/w1um3 fields
     *        This is what causes web platform to protect breakdown.
     *----------------------------------------------------------------
     *  Client Custom Revisions: FoodPro
     *
FPRa *   09/03/20  LMC  FPRa
     *     - Show quantity ordered.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kelly's Foods
     *
KFSa *   02/20/19  LMC  KFSa
     *     - Disable pick slot receiving.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Halsey
     *
HALa *   03/03/20  LMC  HALa
     *     - Disable pick slot receiving.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Southwest Traders
     *
SWTa *   02/10/20  RH   SWTa
     *     - Limit pick slot receiving, add to City Line mod
SWTb *   09/21/21  RH   SWTb
     *     - Remove SWTa mod, can now be limited with option.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt
     *
CSPaA*    07/27/20  LMC  CSPa  - found in po236 07/10/19 RH
     *      - When calling DRISLOT with %CRTXDOCK, force aisle
     *        to be 'PC ' if pdspcl = 'XD'.
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pPO         Purchase Order
     *      pPOSeq      Sequence
     *      pPOItem     Item
700eA*      pUser       User
     *
     *    Returned Parameters
     *      pOutStr     JSON output string
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     Fitemdef   if   e           k disk
     Fdesigsp   if   e           k disk
     Fslot3     if   e           k disk
     F                                     rename(slrec:s3rec)
     Fpirhold   uf a e           k disk    rename(horec:horec1)
700kAFupc1      if   e           k disk


     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D FromStamp       s               z
     D ToStamp         s               z
     D oldeststamp     s               z
     D ts              s               z

     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

     D bfcoffset       s              3  0 inz(0)

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getclien
700bA /copy qcopysrc,p.cvtbar
700bA /copy qcopysrc,p.cvtdte
700eA /copy qcopysrc,p.chklist
700gA /copy qcopysrc,p.GETBRAND

     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D a13             s              1    dim(13)
     D lbl             s             13    dim(4) ctdata perrcd(1)
     D typ             s             10    dim(1) ctdata perrcd(1)
     D cwt             s             27    dim(3) ctdata perrcd(1)
     D $parms1         s             48    dim(20)
     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#birite
      /copy qcopysrc,id#cheney
      /copy qcopysrc,id#finkle
      /copy qcopysrc,id#renzi
      /copy qcopysrc,id#saval
      /copy qcopysrc,id#sgc
      /copy qcopysrc,id#sofo
      /copy qcopysrc,id#yhata
      /copy qcopysrc,id#yhahilo
      /copy qcopysrc,id#jordano
      /copy qcopysrc,id#dairyla
      /copy qcopysrc,id#glazier
      /copy qcopysrc,id#icb
      /COPY QCOPYSRC,Id#Coastal
700eA /COPY QCOPYSRC,ID#CITYLIN
KFSaA /copy qcopysrc,id#kfs
SWTaA /copy qcopysrc,id#swt
HALaA /copy qcopysrc,id#halsey
FPRaA /copy qcopysrc,id#fpr

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
     D pWhse           s              3  0
     D pPo             s              9
     D pPOSeq          s              5  0
     D pPOItem         s             15
700eAD pUser           s             10
     D  pOutStr        s           1024    varying

     D client          s             10
     D clientloc       s             10

     D*wolbl           s             13
     D*woitem          s             65
     D*wolbls          s             13
     D*wositm          s             65
     D*wodsc1          s             40
     D*wodsc2          s             40
     D woslot          s             12
     D*wopdsc          s             15
     D*wotie           s              4s 0
     D*wohi            s              2s 0
     D woqor           s             15
     D woostk          s              1
     D*w1upcd          s             50
     D*w1um1           s              5
     D*w1um2           s              5
     D*w1um3           s              5
     D NDFifo          s              1
     D NDLot           s              1
700aAD NDlcns          s              1
     D NDQord          s              1
     D NDcw            s              1
     D NDcwex          s              1
     D NDexpd          s              1
     D NDMfgd          s              1
     D NDlive          s              1
     D NDpti           s              1
     D NDBrand         s              1
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
     D caltol1         s             11  4
     D caltol2         s             11  4
     D caltol1x100     s             13  4
     D caltol2x100     s             13  4
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
710bDD*eof             s              1
     D*error           s              1
     D exdtj           s              5  0
     D*expd            s              8  0
     D expdj           s              5  0
700gDD*exwgt           s              9  2
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
700gDD*hirng           s              9  2
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
     D*KiloLbs         s              1
     D kyitem          s                   like(slitem)
     D kypick          s                   like(slpick)
     D kystat          s                   like(slstat)
     D*lflag           s              1
     D ltstd6          s              6  0
     D ltstd8          s              8  0
     D glzmfd          s              8  0
     D lvskp           s              1
700gDD*lwrng           s              9  2
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
700gDD*prg1c           s              4  3
700gDD*prg2c           s              4  3
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
     D sdesig          s              1
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
700fAD svopwum         s                   like(opwum)
     D*svmfdt          s              6  0
     D*svpti           s              4  0
     D svqrc1          s                   like(pdqrc1)
     D svqrc2          s                   like(pdqrc2)
     D svqrc3          s                   like(pdqrc3)
     D svrupc          s              1
710aAD svmplt          s              1
     D svtie           s              4  0
     D*svupc           s             50
700bAd savepokey       s                   like(pokey)
700bAd savehotype      s                   like(hotype)
     D temp10          s             10
     D tmprotectwgt    s              9  2
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
     d xdock           s             10
     d PSRcv           s             20
     d dput            s             20
     d rUCI            s             20
     d*xdockflg        s              1
     d PSRcvFlg        s              1
     d rUCIFlg         s              1
     D zmflag          s               n
     D zmsflag         s               n
     D $cstr           s             30
     D wocrcv          s             27
     D w1note          s             15
     D*w1slot          s             12
     D*w1plts          s              5s 0
     D*w1avg           s              1
     D*w1fifo          s              6s 0
     D ALWDecipher     s              1
700eAD ALWPSR          s              1
740aAD ALWOSS          s              1
700eAD chklistrtn      s             10
700eAD chkpgm          s             10
700eAD option          s             20
     D pokey           s             50

700cAD protectmfdt     s              1
700cAD protectexdt     s              1
700cAD protectwgt      s              1
700cAD protectlot      s              1
740 AD protectqty      s              1
700gAD pBrand          s              1
700gAD bCmd            s             10
700gAD bBrand          s             10
700gAD bBranditm       s             15
700gAD bBrandFlg       s              1
700iAD pos             s              2  0
700iAd dblqte          s              1    inz('"')
720aAd backslash       s              1    inz('\')
720add*rpldblqte       s              2    inz('\"')
720aMd rplspace        s              2    inz(' ')
700kAD Needb1          s               n
700kAD Needb2          s               n
700kAD NeedBrkdwn      s              1
700kAD Writeb1         s               n
700kAD Writeb2         s               n
700kAD w1buom1         s              2
700kAd w1buom2         s              2
700kAd w1bupc1         s             75
700kAd w1bupc2         s             75
RNZaA*----------------------------------------------------------------
RNZaA*  Working variables
RNZaA*
RNZaAD rtxall9item     C                   const('9999999999')
DRYcAD digits          c                   const('0123456789')

      /copy qcopysrc,C#PIRHLDPO
700bA /copy qcopysrc,C#PIRHLDUC
740 A /copy qcopysrc,C#PIRHLDAS
     *----------------------------------------------------------------
     * Data structure
     *
     *    OPRUPC  -  Prompt user for Retail UPC during receiving? (Y,N)
     *    OPRUPS  -  Allow user to skip Retail UPC scan? (Y,N)
     *    OPRUPF  -  Require Retail UPC on file before receipt? (Y,N)
710aA*    OPMPLT  -  Allow Gui Multiple Pallet Receiving (Y/N)        (Y/N)
740aA*    OPPEXP  -  Allow Partial Export in gui Receiving  (Y,N)     (Y/N)
740aA*    OPLOTR  -  Lot required if lot item               (Y,N)     (Y/N)
740aA*    OPPSRA  -  Allow Pick slot receiving              (Y,L,N)   (Y/N)
740aA*    OPPLTD  -  DO NOT USE, USE OPMPLT INSTEAD                   (Y/N)
740aA*    OPOSSA  -  Allow offsite storage receipt          (Y,N)     (Y/N)
740aA*    OPSQTO  -  Show qty ordered during receiving      (Y,N)     (Y/N)
740aA*    OPBRKA  -  Allow breakdown qty to be received     (Y,N)     (Y/N)
740aA*    OPEXPE  -  Expiration date Error or Warning       (E,W)     (Y/N)
740aA*    OPSPN1  -  Spin pallet for license placement      (Y,N)     (Y/N)
740aA*    OPSPN2  -  Spin pallet length                               (Y/N)
740aA*    OPSPN3  -  Spin pallet text                                 (Y/N)
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
740aAD optionrec1      ds
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
710aAD  opmplt                37     37
740aAD  oppexp                38     38
740aAD  oplotr                39     39
740aAD  oppsra                40     40
740aAD  oppltd                41     41
740aAD  opossa                42     42
740aAD  opsqto                43     43
740aAD  opbrka                44     44
740aAD  opexpe                45     45
740aAD  opspn1                46     46
740aAD  opspn2                47     49  0
740aAD  opspn3                50     59
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
     D optiondrec      ds
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
     *
     *
     *----------------------------------------------------------------
     *  Working fields.
     *
     D                 ds
     D  lottrk                 1      4
     D  lictrk                 5      8

     D $cerm           ds
     D  xcerm                  1     60
     D* $cmsg                  1      4
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
700bA /COPY *libl/qcopysrc,C#BARCODE
700bA /COPY *libl/qcopysrc,C#CVTPARMS
     D savever#        s                   like($itver#)
     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D pdrec         E Ds                  Extname(podtl)
     D pdmrec        E Ds                  Extname(podtlm)
     D phrec         E Ds                  Extname(pohdr)
     D oprec         E Ds                  Extname(options)
     D umrec         E Ds                  Extname(unmesr)
700kDD*uprec         E Ds                  Extname(upc)
     D horec         E Ds                  Extname(pirhold)
740 AD asnrec        E Ds                  Extname(pirhold)
     d                                     prefix(a_)
     D ossrec        E Ds                  Extname(ossloc)
     D porec         E Ds                  Extname(popsr)
     D opdrec        E Ds                  Extname(optiond)
     D mdrec         E Ds                  Extname(mfrdate)
700jAD ibrec         E Ds                  Extname(itembrd)
710bAD purec         E Ds                  Extname(pospo)
     *----------------------------------------------------------------

     c     *entry        plist
     C                   parm                    pSessId
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pPOSeq
     c                   parm                    pPOItem
700eAc                   parm                    puser
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;

         pUser = %xlate(xlower: xupper: pUser);

         woslot = ' ';
         wotie  = 0;
         wohi   = 0;
         woqor  = ' ';
         woostk = ' ';
         exsr zzinz2;
         if $lsavetrn = 0;
           exsr zzrcvpocreate;
           savetrn = $lsavetrn;
           // create pirhold record
           hotype = 'PODTL';
           pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X')) + %trim(pPOItem);
           chain (psessid: hotype: pokey) pirhold;
           //hodata = pirhldpods;
           if %found(pirhold);
             hodata = pirhldpods;
             update horec1;
           else;
700bA        // if we are writing new record - check for uci extracted data
700bA      savepokey = pokey;
700bA      savehotype = hotype;
700bA      pokey = %trim(pPO);
700bA      exec sql select * into :horec
700bA         from pirhold
700bA         where hosess = :psessid
700bA           and hotype = 'PODTLUCI'
700bA           and hokey  = :pokey;
700bA        If sqlstt = sqlSuccess;
700bA          pirhlducds = hodata;
700bA          // now I have uci scanned - extract info
700bA          exsr extractuci;
700gA          // adding ability to load upc file from scan
700gA          if uciNotFound = 'Y';
700gA            w1upcd = uciscanned;
700gA            svupc  = uciscanned;
700gA            if $bcgtinsent;
700gA              w1upc = $bcgtin;
700gA            else;
700gA              w1upc = uciscanned;
700gA            endif;
700gA          endif;
700bA        else;
710bA          // now check for super po record
710bA          exec sql select * into :purec
710bA             from pospo
710bA             where puwhse = :pwhse
710bA               and pupo  = :ppo;
710bA          If sqlstt = sqlSuccess;
710bA            exec sql select * into :horec
710bA                from pirhold
710bA               where hosess = :psessid
710bA                 and hotype = 'PODTLUCI'
710bA                 and hokey  = :puspo;
710bA            If sqlstt = sqlSuccess;
710bA              pirhlducds = hodata;
710bA              // now I have uci scanned - extract info
710bA              exsr extractuci;
710bA              // adding ability to load upc file from scan
710bA              if uciNotFound = 'Y';
710bA                w1upcd = uciscanned;
710bA                svupc  = uciscanned;
710bA                if $bcgtinsent;
710bA                  w1upc = $bcgtin;
710bA                else;
710bA                  w1upc = uciscanned;
710bA                endif;
710bA              endif;
710bA            endif;
710bA          endif;
700bA        endif;
700bA        pokey = savepokey;
700bA        hotype = savehotype;
             exsr chkforAsn;
             //   end
             exsr getcurrstamp;
             hoaddts = currstampsys;
             hoadduc = currstampuc;
             hosess = psessid;
             hokey = pokey;
             hodata = pirhldpods;
750aD      //write horec1;
750aM        write(e) horec1;
           endif;
         else;
740 A      if $plpn<>*blanks;
740 A        exsr chkforasn;
740 A      endif;
           exsr zzrcvpocheck;
         endif;

         // see if the decifer program files have data
         ALWDecipher = ' ';
         // check mfrdate
         exec sql select * into :mdrec
              from mfrdate
              fetch first row only;
         if sqlstt = sqlSuccess;
           ALWDecipher = 'Y';
         endif;

700eA    // City line security on pick slot receiving
700eA    ALWPSR = ' ';
740aA    Select;
740aA      when oppsra = 'N';
740aA        alwpsr = 'N';
740aA      other;
KFSaA        if client = Kellys
HALaA        or client = Halsey;
KFSaA          alwpsr = 'N';
KFSaA        endif;
700eA        If client = cityline or
740aA           oppsra = 'L';
SWTbD    //     oppsra = 'L' or
SWTbD    //     client = SWT;
700eA          chkpgm = 'PO110A';
700eA          option = '52';
700eA          chklist(chkpgm: %trim(option): puser: chklistrtn);
700eA          if chklistrtn = '*NO ';
700eA            alwpsr = 'N';
700eA          endif;
700eA        endif;
740aA    endsl;
700gA    // if an item does not have a pick slot assigned, we will
700gA    // not allow the user to choose pick slot receiving.
700gA    if woslot = '*NONE*';
700gA      alwpsr = 'N';
700gA    endif;
740bA    // if ssb item and no breakdown uom will not allow psr
740bA    if $ittype = 'S' and $itum2 = ' ';
740bA      alwpsr = 'N';
740bA    endif;

740aA    // set allow oss receiving
740aA    select;
740aA      when opossa = 'N';
740aA        alwoss = 'N';
740aA      other;
740aA        alwoss = ' ';
740aA    endsl;
700iA    // let's check for our double quotes and replace
700iA    // woitem
700iA    pos = %scan(dblqte: woitem);
700iA    dow pos > 0;
720aD       //woitem = %replace(rpldblqte: woitem: pos: %len(dblqte)) ;
720aM       woitem = %replace(rplspace: woitem: pos: %len(dblqte)) ;
720aD       //if (pos+%len(rpldblqte) > %len(woitem));
720aM       if (pos+%len(rplspace) > %len(woitem));
700iA          pos = 0;
700iA       else;
720aD         //pos = %scan(dblqte: woitem: pos+%len(rpldblqte));
720aM         pos = %scan(dblqte: woitem: pos+%len(rplspace));
700iA       endif;
700iA    enddo;
700iA    // wositm
700iA    pos = %scan(dblqte: wositm);
700iA    dow pos > 0;
720aD      //wositm = %replace(rpldblqte: wositm: pos: %len(dblqte)) ;
720aM       wositm = %replace(rplspace: wositm: pos: %len(dblqte)) ;
720aD       //if (pos+%len(rpldblqte) > %len(wositm));
720aM       if (pos+%len(rplspace) > %len(wositm));
700iA          pos = 0;
700iA       else;
720aD          //pos = %scan(dblqte: wositm: pos+%len(rpldblqte));
720aM          pos = %scan(dblqte: wositm: pos+%len(rplspace));
700iA       endif;
700iA    enddo;
700iA    // wodsc1
700iA    pos = %scan(dblqte: wodsc1);
700iA    dow pos > 0;
720aD       //wodsc1 = %replace(rpldblqte: wodsc1: pos: %len(dblqte)) ;
720aM       wodsc1 = %replace(rplspace: wodsc1: pos: %len(dblqte)) ;
720aD       //if (pos+%len(rpldblqte) > %len(wodsc1));
720aM       if (pos+%len(rplspace) > %len(wodsc1));
700iA          pos = 0;
700iA       else;
720aD          //pos = %scan(dblqte: wodsc1: pos+%len(rpldblqte));
720aM          pos = %scan(dblqte: wodsc1: pos+%len(rplspace));
700iA       endif;
700iA    enddo;
700iA    // wodsc2
700iA    pos = %scan(dblqte: wodsc2);
700iA    dow pos > 0;
720dA       //wodsc2 = %replace(rpldblqte: wodsc2: pos: %len(dblqte)) ;
720aM       wodsc2 = %replace(rplspace: wodsc2: pos: %len(dblqte)) ;
720aD       //if (pos+%len(rpldblqte) > %len(wodsc2));
720aM       if (pos+%len(rplspace) > %len(wodsc2));
700iA          pos = 0;
700iA       else;
720aD          //pos = %scan(dblqte: wodsc2: pos+%len(rpldblqte));
720aM          pos = %scan(dblqte: wodsc2: pos+%len(rplspace));
700iA       endif;
700iA    enddo;
700iA    // wopdsc
700iA    pos = %scan(dblqte: wopdsc);
700iA    dow pos > 0;
720ad       //wopdsc = %replace(rpldblqte: wopdsc: pos: %len(dblqte)) ;
720aM       wopdsc = %replace(rplspace: wopdsc: pos: %len(dblqte)) ;
720aD       //if (pos+%len(rpldblqte) > %len(wopdsc));
720aM       if (pos+%len(rplspace) > %len(wopdsc));
700iA          pos = 0;
700iA       else;
720aD          //pos = %scan(dblqte: wopdsc: pos+%len(rpldblqte));
720aM          pos = %scan(dblqte: wopdsc: pos+%len(rplspace));
700iA       endif;
700iA    enddo;

720aA    // let's check for '\' and replace
720aA    // woitem
720aA    pos = %scan(backslash: woitem);
720aA    dow pos > 0;
720aA       woitem = %replace(rplspace: woitem: pos: %len(backslash)) ;
720aA       if (pos+%len(rplspace) > %len(woitem));
720aA          pos = 0;
720aA       else;
720aA         pos = %scan(backslash: woitem: pos+%len(rplspace));
720aA       endif;
720aA    enddo;
720aA    // wositm
720aA    pos = %scan(backslash: wositm);
720aA    dow pos > 0;
720aA       wositm = %replace(rplspace: wositm: pos: %len(backslash)) ;
720aA       if (pos+%len(rplspace) > %len(wositm));
720aA          pos = 0;
720aA       else;
720aA          pos = %scan(backslash: wositm: pos+%len(rplspace));
720aA       endif;
720aA    enddo;
720aA    // wodsc1
720aA    pos = %scan(backslash: wodsc1);
720aA    dow pos > 0;
720aA       wodsc1 = %replace(rplspace: wodsc1: pos: %len(backslash)) ;
720aA       if (pos+%len(rplspace) > %len(wodsc1));
720aA          pos = 0;
720aA       else;
720aA          pos = %scan(backslash: wodsc1: pos+%len(rplspace));
720aA       endif;
720aA    enddo;
720aA    // wodsc2
720aA    pos = %scan(backslash: wodsc2);
720aA    dow pos > 0;
720aA       wodsc2 = %replace(rplspace: wodsc2: pos: %len(backslash)) ;
720aA       if (pos+%len(rplspace) > %len(wodsc2));
720aA          pos = 0;
720aA       else;
720aA          pos = %scan(backslash: wodsc2: pos+%len(rplspace));
720aA       endif;
720aA    enddo;
720aA    // wopdsc
720aA    pos = %scan(dblqte: wopdsc);
720aA    dow pos > 0;
720aA       wopdsc = %replace(rplspace: wopdsc: pos: %len(backslash)) ;
720aA       if (pos+%len(rplspace) > %len(wopdsc));
720aA          pos = 0;
720aA       else;
720aA          pos = %scan(backslash: wopdsc: pos+%len(rplspace));
720aA       endif;
720aA    enddo;

700kA    // do we need to get breakdwon upc codes?
700kA   writeb1 = *off;
700kA   writeb2 = *off;
700kA   w1buom1 = ' ';
700kA   w1bupc1 = ' ';
700kA   w1buom2 = ' ';
700kA   w1bupc2 = ' ';
700kA   // breakdown 1 is setup on item
700kA   if $itum2 <> ' ';
700kA     Needb1  = *on;
700kA     // do we have a upc loaded for this breakdown uom
700kA     setll (pwhse: ppoitem) upc1;
700kA     dow forevr = forevr;
700kA       reade (pwhse: ppoitem) upc1;
700kA       if %eof(upc1);
700kA         leave;
700kA       endif;
700kA       if upuom = $itum2;
700kA         needb1  = *off;
700kA         leave;
700kA       endif;
700kA     enddo;
700kA   endif;
700kA   // breakdown 2 is setup on item
700kA   if $itum3 <> ' ';
700kA     Needb2  = *on;
700kA     // do we have a upc loaded for this breakdown uom
700kA     setll (pwhse: ppoitem) upc1;
700kA     dow forevr = forevr;
700kA       reade (pwhse: ppoitem) upc1;
700kA       if %eof(upc1);
700kA         leave;
700kA       endif;
700kA       if upuom = $itum3;
700kA         needb2  = *off;
700kA         leave;
700kA       endif;
700kA     enddo;
700kA   endif;
700kA   if needb1 = *on or needb2 = *on;
700kA     needbrkdwn = 'Y';
700kA   else;
700kA     needbrkdwn = 'N';
700kA   endif;
         // Put together JSON string

         pOutStr = '{'
                +  '"Err":"'  + %trimr(Errmsg) + '",'
                +  '"NDFifo":"'  + %trimr(NDFifo) + '",'
                +  '"NDQord":"'  + %trimr(NDQord) + '",'
                +  '"NDcw":"'  + %trimr(NDcw) + '",'
                +  '"NDcwex":"'  + %trimr(NDcwex) + '",'
                +  '"NDexpd":"'  + %trimr(NDexpd) + '",'
                +  '"NDmfgd":"'  + %trimr(NDmfgd) + '",'
                +  '"NDlive":"'  + %trimr(NDlive) + '",'
                +  '"NDLot":"'  + %trimr(NDLot) + '",'
700aA           +  '"NDlcns":"'  + %trimr(NDlcns) + '",'
                +  '"NDpti":"'  + %trimr(NDpti) + '",'
                +  '"NDBrand":"'  + %trimr(NDBrand) + '",'
                +  '"wocrcv":"'  + %trimr(wocrcv) + '",'
                +  '"w1avg":"'  + %trimr(w1avg) + '",'
                +  '"woslot":"'  + %trimr(woslot) + '",'
                +  '"woostk":"'  + %trimr(woostk) + '",'
                +  '"wolbl":"'  + %trimr(wolbl) + '",'
                +  '"woitem":"'  + %trimr(woitem) + '",'
                +  '"w1fifo":"'  + %char(w1fifo) + '",'
                +  '"w1plts":"'  + %char(w1plts) + '",'
                +  '"w1note":"'  + %trimr(w1note) + '",'
                +  '"wositm":"'  + %trimr(wositm) + '",'
                +  '"wodsc1":"'  + %trimr(wodsc1) + '",'
                +  '"wodsc2":"'  + %trimr(wodsc2) + '",'
                +  '"wopdsc":"'  + %trimr(wopdsc) + '",'
                +  '"woqor":"'  + %trimr(woqor) + '",'
                +  '"w1um1":"'  + %trimr(w1um1) + '",'
                +  '"w1um2":"'  + %trimr(w1um2) + '",'
                +  '"w1um3":"'  + %trimr(w1um3) + '",'
                +  '"wotie":"'  + %char(wotie) + '",'
                +  '"wohi":"'  + %char(wohi) + '",'
                +  '"wolbls":"'  + %trimr(wolbls) + '",'
                +  '"xdock":"'  + %trimr(xdock) + '",'
                +  '"xdockF":"'  + %trimr(xdockflg) + '",'
                +  '"PSRcv":"'  + %trimr(psrcv) + '",'
                +  '"PSRcvF":"'  + %trimr(psrcvFlg) + '",'
                +  '"Dput":"'  + %trimr(dput) + '",'
                +  '"DputF":"'  + %trimr(directed) + '",'
                +  '"rUCI":"'  + %trimr(rUCI) + '",'
                +  '"rUCIF":"'  + %trimr(rUCIFlg) + '",'
                +  '"ossdev":"'  + %trimr(osdev) + '",'
                +  '"decipher":"'  + %trimr(alwdecipher) + '",'
                +  '"allowpsr":"'  + %trimr(alwpsr) + '",'
740aA           +  '"allowoss":"'  + %trimr(alwoss) + '",'
                +  '"Pmfdt":"'  + %trimr(protectmfdt) + '",'
                +  '"Pexdt":"'  + %trimr(protectexdt) + '",'
                +  '"Pwgt":"'  + %trimr(protectwgt) + '",'
                +  '"Plot":"'  + %trimr(protectlot) + '",'
                +  '"Pqty":"'  + %trimr(protectqty) + '",'
700gA           +  '"Brand":"'  + %trimr(pBrand) + '",'
700gA           +  '"GTINUPC":"'  + %trimr(w1UPC) + '",'
700kA           +  '"NeedBrk":"'  + %trimr(NeedBrkdwn) + '",'
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
     *
     *  ZZUOM    Get Unit Of Measure Normal, Breakdown1, Breakdown2.
     *           copied from PO232
     *
     C     zzuom         begsr
     *
     *   Get Unit of Measures.
     *     *IN94=Protect & non-display breakdown1 unit of measure
     *     *IN93=Protect & non-display breakdown2 unit of measure
     *
     *
214 AC                   eval      *in94 = *off
214 AC                   eval      *in93 = *off
     C                   eval      wolbl = ' '
     C                   eval      woitem = ' '
     C                   eval      wodsc1 = ' '
     C                   eval      wodsc2 = ' '
     *
     C                   eval      ssbflg = *off
     C                   eval      wolbls = ' '
     C                   eval      wositm = ' '
     C                   eval      w1um1 = ' '
     C                   eval      w1um2 = ' '
     C                   eval      w1um3 = ' '
     *
      * add dri to get data from itemfld
      /free
            exsr clr$item;

            $itWhse = pwhse;
            $ititem = pPoItem;

            $dricommand = '*ITEM';
            $drisubcmd  = '%GETALL';
            $drisys2upd = 'D';
            chk4err = *on;
            zmflag  = *off;
            exsr zzzdricop;
            if error = *on;
              $ifucicde = ' ';
              $ifrcvmth = ' ';
              $ifbrdflg = ' ';
            endif;
            if $ifbrdflg = 'Y';
              NDBrand = ' ';
            else;
              NDBrand = 'Y';
            endif;
700jA       if NDBrand = 'Y';
700jA         // if brand flag is non display check the itembrd file
700jA         // if found in itembrd - turn off non display flag
700jA         exec sql select * into :ibrec
700jA               from itembrd
700jA               where ibwhse = :$itWhse and ibitem = :$itItem
700jA              fetch first row only;

700jA         if sqlstt = sqlSuccess;
                NDBrand = ' ';
700jA         endif;
700jA       endif;
730aD       //if $ifsltmth = '3' or
730aD          //$ifucicde <> '1'and $ifrcvmth <> '2';
730aM       if $ifsltmth = '3';
              *in73 = *off;
              NDpti = ' ';
            else;
              *in73 = *on;
              NDpti = 'Y';
            endif;
700aA       if $ifrcvmth <> '2';
700aA         NDlcns = 'Y';
700aA         rUCI = ' ';
700aA         rUCIFlg = ' ';
700aA       else;
700aA         w1plts = 1;
700aA         w1qrc1 = 1;
700aA         rUCI = 'UCI Receiving';
700aA         rUCIFlg = 'Y';
700aA       endif;
      /end-free
     C*    ittkey        chain     piritem                            75
     C                   if        error = *on
214 AC                   eval      *in94 = *on
214 AC                   eval      *in93 = *on
     C                   eval      $itdesc = *blanks
     C                   eval      $itpdsc = *blanks
     C                   eval      $itcwgt = 'N'
     C                   eval      wopdsc = *blanks
     C                   eval      wolbl = lbl(4)
     c                   eval      woitem = '* * INVALID ITEM * *'
     C*                  movel     desc(8)       woitem
     C     '-'           cat       woitem:1      woitem
     C     pPOItem       cat       woitem:1      woitem
     C                   goto      enduom
     C                   else
     C*
     C                   if        client = Renzi
     C                             or client = Finkle
     C                             or client = SoFo
     C                   if        pditem = rtxall9item
     C                   eval      $itwhdp = rtxdm1_dnwhdp
     C                   eval      $itdesc = pdmods
     C                   eval      $itcwgt = rtxdm1_dncwcd
     C                   eval      $itswgt = rtxdm1_dnwtiw
     C                   eval      $itcube = rtxdm1_dncbec
     C                   endif
     C                   endif
     C*
     C                   eval      wopdsc = $itpdsc
     C                   exsr      zztihi
     *
     *  Save information about selected item (Item that was sent in)
     *
     C                   eval      #oven# = $itven#
     C                   eval      #otype = $ittype
700gAc                   if        BrandedItm <> ' '
700gAC                   eval      #oitem = BrandedItm
700gAc                   else
     C                   eval      #oitem = $ititem
700gAc                   endif
     C                   eval      #odesc = $itdesc
     C                   eval      #opdsc = $itpdsc
     C                   eval      #oswgt = $itswgt
     C                   eval      #oum1 = $itum1
     C                   eval      #oum2 = $itum2
     C                   eval      #oum2q = $itumq2
     C                   eval      #oswt2 = 0
     C                   if        #oum2q <> 0
     C     $itswgt       div(h)    #oum2q        #oswt2
     C                   endif
     C                   eval      #oum3 = $itum3
     C                   eval      #oum3q = $itumq3
     C                   eval      #oswt3 = 0
     C                   if        #oum3q <> 0
730bAc                             and #oum2q <> 0
     C     $itswgt       div(h)    #oum2q        #oswt3
     C     #oswt3        div(h)    #oum3q        #oswt3
     C                   endif
     *
     C                   if        client = Renzi
     *   Force standard-wgt catchwgt to non-catchwgt.
     C                   if        $itcwgt = 'S'
     C                   eval      $itcwgt = 'N'
     C                   endif
     *
     C                   endif
     *
     *   Get short UOM descriptions for selected item.
     *
     C                   eval      #osu1 = *blanks
     C                   eval      #osu2 = *blanks
     C                   eval      #osu3 = *blanks
     *
      /free
         if $itum1 <> *blanks;
           exec sql select * into :umrec
              from unmesr
              where umcode = :$itum1;

           If sqlstt = sqlSuccess;
             #osu1 = umshrt;
           else;
             #osu1 = %trim($itum1);
           endif;
         endif;

740aA    // if allow breakdown to be received is no we will leave
740aA    // fields #osu2 and #osu3 blank.
740aA    if opbrka = 'N';
740aA    else;
         if $itum2 <> *blanks;
           exec sql select * into :umrec
              from unmesr
              where umcode = :$itum2;

           If sqlstt = sqlSuccess;
             #osu2 = umshrt;
           else;
             #osu2 = %trim($itum2);
           endif;
         endif;

         if $itum3 <> *blanks;
           exec sql select * into :umrec
              from unmesr
              where umcode = :$itum3;

           If sqlstt = sqlSuccess;
             #osu3 = umshrt;
           else;
             #osu3 = %trim($itum3);
           endif;
         endif;
740aA    endif;
      /end-free
     *
     *   Initialize base information.
     *
     C                   eval      #bitem = $ititem
     C                   eval      #sitem = $ititem
     C                   eval      #bityp = $ittype
     C                   eval      #bdesc = $itdesc
     C                   eval      #bpdsc = $itpdsc
     C                   eval      #bum1 = $itum1
     C                   eval      #bum2 = $itum2
     C                   eval      #bum3 = $itum3
     C                   eval      #bsu1 = #osu1
     C                   eval      #bsu2 = #osu2
     C                   eval      #bsu3 = #osu3
     *
     *   Get SSB item, if one exists
     *
     C                   if        $ittype = ' '
     C                   call      'GETSSB'
     C                   parm      $itwhse       $gwhse            3 0
     C                   parm      $ititem       $gitem           15
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
     C                   eval      #bityp = 'S'
     C                   endif
     C                   endif
     *
     *  If selected item is a Contract, Alias, SSB or Breakdown item . . .
     *    Then get corresponding Base item.
     *
     C                   if        $ittype = 'C'  or
     C                             $ittype = 'A'  or
     C                             $ittype = 'S'  or
     C                             $ittype = 'B'
     C                   call      'GETBASE'
     C                   parm      $itwhse       $gwhse
     C                   parm      $ititem       $gitem
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
     C                   parm      $itwhse       $gwhse
     C                   parm      $ititem       $gitem
     C                   parm      ' '           #sitem           15
     C                   parm                    #sityp            1
     C                   parm                    #sdesc           30
     C                   parm                    #spdsc           15
     C                   parm                    #srtn            10
     C                   parm                    #smsg            60
     *
     *   Get short UOM descriptions for base item.
     *
      /free
         if #bum1 <> #oum1;
           exec sql select * into :umrec
              from unmesr
              where umcode = :#bum1;

           If sqlstt = sqlSuccess;
             #bsu1 = umshrt;
           else;
             #bsu1 = %trim(#bum1);
           endif;
         endif;

         if #bum2 <> #oum2;
           exec sql select * into :umrec
              from unmesr
              where umcode = :#bum2;

           If sqlstt = sqlSuccess;
             #bsu2 = umshrt;
           else;
             #bsu2 = %trim(#bum2);
           endif;
         endif;

         if #bum3 <> #oum3;
           exec sql select * into :umrec
              from unmesr
              where umcode = :#bum3;

           If sqlstt = sqlSuccess;
             #bsu3 = umshrt;
           else;
             #bsu3 = %trim(#bum3);
           endif;
         endif;
      /end-free

     *
     *   Set indicators to protect breakdown quantities.
     *
     C                   if        $itflg1 = 'N'  and
     C                             ssbflg = *off
214 AC                   eval      *in94 = *on
     C                   endif
     C                   if        $itflg2 = 'N'  and
     C                             ssbflg = *off  or
     C                             $itflg2 = 'N'  and
     C                             ssbflg = *on  and
     C                             $itum3 = *blanks
214 AC                   eval      *in93 = *on
     C                   endif
     *
     *   When dealing with an SSB item, the quantity is actually
     *   received into the "normal" screen quantity. If a third
     *   breakdown is allowed, then that will be received into the
     *   breakdown 1 quantity on the screen. The second breakdown
     *   screen quantity is always protected for an SSB item.
     *
     C                   if        $ittype = 'S'  and
     C                             $itflg2 = 'Y'
     C                   eval      *in94 = *off
     c                   else
     c                   if        $ittype = 'S'
     c                   eval      *in94 = *on
     c                   endif
     C                   endif
     *
     C                   if        $ittype = 'S'
415fAC                   eval      *in93 = *on
     C                   endif
     *
     *   Create label for selected item
     *
     *     If selected item is a SSB item . . .
     *        Then display the breakdown 1 UOM.
     *        Otherwise use the normal UOM.
     *
     *     Note: Except for the description, the SSB fields
     *           should be identical to its Base item's fields.
     *
     C                   movea     lbl(1)        a13
     C                   if        #otype = 'S'
     C                   movea     #osu2         a13(7)
     C                   else
     C                   movea     #osu1         a13(7)
     C                   endif
     C                   movea     a13           wolbl
     C     wolbl         cat       ')':0         wolbl
     C                   move      ':'           wolbl
     *
     *   Create description for selected item
     *
     C                   movea     typ(1)        a10
     C                   movea     #otype        a10(8)
     C                   movea     a10           temp10
     *
     C     #oitem        cat       temp10:1      woitem
     C     woitem        cat       '-':1         woitem
     C     woitem        cat       #odesc:1      woitem
     *
     *   Create label and description for corresponding item.
     *
     C                   select
     *
     *     If selected item is a Base item . . .
     *        Then display its corresponding SSB item (if any)
     *        Otherwise display nothing.
     *
     C                   when      #otype = ' '
     C                   if        #bityp = 'S'
     C                   movea     lbl(3)        a13
     C                   movea     #bsu2         a13(6)
     C                   movea     a13           wolbls
     C     wolbls        cat       ')':0         wolbls
     C                   move      ':'           wolbls
     *
     C                   movea     typ(1)        a10
     C                   movea     #bityp        a10(8)
     C                   movea     a10           temp10
     *
     C     #sitem        cat       temp10:1      wositm
     C     wositm        cat       '-':1         wositm
     C     wositm        cat       #bdesc:1      wositm
     C                   endif
     *
     *     If selected item is a Breakdown item . . .
     *        Then display its corresponding Base item.
     *             Note: UOM is not applicable in this situation.
     *
     C                   when      #otype = 'B'
     C                   movea     lbl(2)        a13
     C                   movea     'N/A'         a13(7)
     C                   movea     a13           wolbls
     C     wolbls        cat       ')':0         wolbls
     C                   move      ':'           wolbls
     *
     C                   movea     typ(1)        a10
     C                   movea     #bityp        a10(8)
     C                   movea     a10           temp10
     *
     C     #sitem        cat       temp10:1      wositm
     C     wositm        cat       '-':1         wositm
     C     wositm        cat       #bdesc:1      wositm
     *
     *     Otherwise . . .
     *        Then display its corresponding Base item w/UOM.
     *             Note: UOM of Base should match UOM of selected item.
     *
     C                   other
     C                   movea     lbl(2)        a13
     C                   movea     #bsu1         a13(7)
     C                   movea     a13           wolbls
     C     wolbls        cat       ')':0         wolbls
     C                   move      ':'           wolbls
     *
     C                   movea     typ(1)        a10
     C                   movea     #bityp        a10(8)
     C                   movea     a10           temp10
     *
     C     #sitem        cat       temp10:1      wositm
     C     wositm        cat       '-':1         wositm
     C     wositm        cat       #bdesc:1      wositm
     *
     C                   endsl
     *
     *   Determine item number going into slot.
     *
     C                   if        #otype = ' '  or
     C                             #otype = 'B'
     C                   eval      #sitem = #oitem
     C                   endif
     *
     *   Get extend description headings if being used.
     *
     C                   if        uxflag = *off
     C                   else
     C*    idkey         chain     itemdsc                            79
     C*                  if        not *in79
     C*
     C*                  if        $ixitem <> ' '
     C                   if        client = Renzi
     C                             or client = Finkle
     C                             or client = SoFo
     C                   if        pditem = rtxall9item
     C                   eval      $ixdsc1 = pdmods
     C                   endif
     C                   endif
     C*
     C                   eval      wodsc1 = $ixdsc1
     C                   eval      wodsc2 = $ixdsc2
     C*                  endif
     C                   endif
     *
     *   Initialize unit of measure names for quantity fields.
     *
     C                   if        #otype = 'S'
     C                   eval      w1um1 = #osu2
     C                   else
     C                   eval      w1um1 = #osu1
     C                   endif
     *
     C                   if        not *in94
     C                   if        #otype = 'S'
     C                   eval      w1um2 = #osu3
     C                   else
     C                   eval      w1um2 = #osu2
     C                   endif
     C                   endif
     *
     C                   if        not *in93
     C                   eval      w1um3 = #osu3
     C                   endif
     *
     *   Determine if this item should be put away into warehouse.
     *   An '*' in last position of designation says that the item
     *   will NOT be put away into the warehouse.
     *
     C                   move      $itdesg       iatest
     C                   if        iatest = '*'
     C                   eval      iaflag = *on
     C                   eval      *in64 = *off
     C                   else
     C                   eval      iaflag = *off
     C                   eval      *in64 = *on
     C                   endif

     *  ... Or department isn't live (this overrides iaflag).

     C                   call      'CHKLIVE'
     C                   parm      pwhse         $swhse
     C                   parm                    $itwhdp
     C                   parm                    livestat          8

     C                   if        livestat = '*NOTLIVE'
     C*                  eval      *in65 = *off
     c                   eval      NDLive = ' '
     C                   eval      iaflag = *off
     C                   eval      *in64 = *on
     C                   else
     C*                  eval      *in65 = *on
     c                   eval      NDLive = 'Y'
     C                   endif
     *
     *    The following EndIf is for statment *IN75 IFEQ *ON, which
     *    comes after the chain to PIRITEM.
     *
     C                   endif
     C     enduom        endsr
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
     *  ZZTIHI   Get use Preferred or 1st tie hi record.
     *
     C     zztihi        begsr
     *
     *  GET TIE HI, PREFERRED OR 1ST RECORD.
     C                   eval      done = *off
     C                   eval      wotie = 0
     C                   eval      wohi = 0
     C                   eval      svtie = 0
     C                   eval      svhi = 0
      /free
         setll (pwhse: pPOItem) itemdef;
         dou done = *on;
           reade (pwhse: pPOItem) itemdef;
           if %eof(itemdef);
             done = *on;
             leave;
           endif;
      /end-free
     C*    partk2        setll     itemdef
     C*                  dou       done = *on
     C*    partk2        reade     idrec                                  79
     C*                  if        *in79
     C*                  eval      done = *on
     C*                  else
     C                   if        svtie = 0  and
     C                             svhi = 0
     C                   eval      svtie = idtie
     C                   eval      svhi = idhigh
     C                   endif
     C                   if        idpref = 'Y'
     C                   eval      wotie = idtie
     C                   eval      wohi = idhigh
     C                   eval      done = *on
     C                   endif
     C*                  endif
     C                   enddo
     C                   if        wotie = 0  and
     C                             wohi = 0
     C                   eval      wotie = svtie
     C                   eval      wohi = svhi
     C                   endif
     *
     c                   if        client = finkle
     C                   eval      *in86 = *on
     C                   else
     C                   eval      *in86 = *off
     C                   endif
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
     C                   parm                    $lsavetrn         7 0
     C                   parm                    pPO
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
     *   get pirhold record
     *
      /free
           pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X')) + %trim(pPOItem);
           exec sql select * into :horec
              from pirhold
              where hosess = :psessid
                and hotype = 'PODTL'
                and hokey  = :pokey;
             If sqlstt = sqlSuccess;
               pirhldpods = hodata;
               $lsavetrn = savetrn;
             else;
               $lsavetrn = 0;
               savetrn = 0;
             endif;
      /end-free
     *
     *   Initialize error subfile
     *
     *
     C                   setoff                                       kckl
     C                   eval      dtchk = *off
     C                   eval      dtchk2 = *off
     C                   eval      dtchk3 = *off
     C                   eval      dtchk4 = *off
     C                   eval      qtchk = *off
     C                   eval      qtchk1 = *off
     C                   eval      wtchk = *off
     C                   eval      upchk = *off
     C                   eval      upchk2 = *off
     C                   eval      expd = 0
     *   Look for Branded Items.
700gA /free
700gA    // look for Branded Items
700gA    bCmd = '*GETFLAG';
700gA    bBrand = ' ';
700gA    bBrandItm = ' ';
700gA    bBrandFlg = ' ';
700gA    GetBranded(bCmd: pwhse: ppoItem: bBrand: bBrandItm: bBrandFlg);

700gA      pBrand = bBrandFlg;
700gA /end-free
     *   Set Non Display FIFO flag.
      /free
         NDFifo = ' ';
         exec sql select * into :phrec
              from pohdr
              where phwhse = :pWhse
                and phpo   = :pPO;

           If sqlstt = sqlSuccess;
             select;
               when phvnam = 'MOVEIN' or
                    phvnam = move1  or
                    phvnam = move2;
                 NDFifo = ' ';
               other;
                 NDFifo = 'Y';
             endsl;
           endif;
      /end-free
     *
     *   Remove any existing catchweight entry records.
     C                   exsr      zzdlcw
     *
     C                   eval      lflag = *off
     C                   exsr      zzxopt
     C                   exsr      zzlcns
     *
      /free
        ocode = '*SYSTEM ';
        wkwhse = 0;
        exec sql select * into :oprec
             from options
             where opwhse = :wkwhse
               and opcode = :ocode;

        If sqlstt = sqlSuccess;
          optionrec = opdata;
        else;
          opcapc = 'Y';
          opwrnc = 'N';
          oprg1c = 0;
          oprg2c = 0;
          opicw = 'N';
        endif;
      /end-free
     *
     *   Select first screen to display.
     *
     C                   eval      w1upcd = *blanks
      * temporarily taken out until mrc scanning installed
     C*                  if        $pupc <> *blanks
     C*                  eval      *in92 = *on
     *
     *    Left adjust UPC for better and easier viewing.
     C*                  move(p)   $pupc         $cstr
     C*                  call      'ADJUST'
     C*                  parm      '*LEFTNOZ'    $ccmd
     C*                  parm                    $cstr
     C*                  movel     $cstr         w1upcd
     C*                  endif
     *
     C                   movel     w1upcd        w1upc
     *
     C                   exsr      scr01i
     *
     *    Confirm Retail UPC on file before continuing with receiving.
     *
      ****** this was marked out temporary for first round mrc
     C                   if        svrupc = 'Y'
     C*                  exsr      zzrupc
     C     error         cabeq     *on           endinz
     C                   endif
     *
      // get the outside storage print device
      /free
        exec sql select * into :ossrec
           from ossloc
           where oswhdp = :$itwhdp;

        If sqlstt = sqlSuccess;
        else;
          osdev = '*JOB';
        endif;
         //endif;
      /end-free
     C     endinz        endsr
     *----------------------------------------------------------------
     *
     *  ZZDLCW   Delete catchweight entry records.
     *
     C     zzdlcw        begsr
     *
     C                   eval      $mwhs3 = pwhse
     C                   eval      $mpo3 = pPO
     C                   eval      $mseq = pPOSeq
     C                   call      'DELTMPCW'
     C                   parm                    $mparm
     *
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
             where opwhse = :pWhse
               and opcode = :ocode;

        If sqlstt = sqlSuccess;
          optionrec = opdata;
          if opxdsc = 'Y';
            uxflag = *on;
          endif;
700fA     // We will set the default for lbs/kgs from the option file
700fA     // save the field for later use
700fA     svopwum = opwum;
700fA     select;
700fA       when opwum = 'KGS'
700fA        or opwum = 'kgs'
700fA        or opwum = 'Kgs';
700fA         KiloLbs = 'K';
700fA       other;
700fA         KiloLbs = 'P';
700fA     endsl;
        endif;
      /end-free
     *
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
710aAC                   eval      svmplt = 'Y'
      /free
        ocode = '*RCVLBL ';
        wkwhse = pwhse;
        exec sql select * into :oprec
             from options
             where opwhse = :wkwhse
               and opcode = :ocode;

        if client = Dairyland;
          opcwen = '2';
          opcwtp = '2';
          opcwfr = 'Y';
        endif;
        If sqlstt = sqlSuccess;
740aD     //optionrec = opdata;
740aM     optionrec1= opdata;
          if opplcn = 'Y';
            lflag = *on;
          endif;
          svexck = opexck;
          svcwen = opcwen;
          svcwtp = opcwtp;
          svcwfr = opcwfr;
          svrupc = oprupc;
710aA     if opmplt = ' ';
710aA       svmplt = 'Y';
710aA     else;
710aA       svmplt = opmplt;
710aA     endif;
        endif;
      /end-free
     *
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
     C*                  eval      nxtscr = '01 '
     *    For Jordano's ...
     *  Position cursor to QTY field.

     C                   if        client = jordanos
     C                             or client = icb
     C                   eval      *in01 = *on
     C                   endif
     *
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget1
     C                   exsr      zzfil1
     C                   eval      ovrrid = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.
     *
      /free
         exec sql select * into :pdrec
              from podtl
              where pdwhse = :pWhse
                and pdpo   = :pPO
                and pdseq  = :pPOSeq
                and pditem = :pPOItem;
           If sqlstt = sqlSuccess;
           else;
             error = *on;
             errmsg = 'Po Sequence does not exist';
             return;
           endif;
      /end-free
RNZaAC                   if           client = Renzi
FKL AC                             or client = Finkle
SOF AC                             or client = SoFo
DRYcAC                             or client = Dairyland
RNZaAC*      Retrieve P/O Detail Misc. record.
RNZaAC                   if        pditem = rtxall9item
DRYcAC                             or client = Dairyland
RNZaAC                   exsr      zzgtpdm
RNZaAC                   endif
RNZaAC                   endif
     C*
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *    Default FIFO entered date if entry is allowed.
     C*                  if        not *in89
     c                   if        NDFifo = ' '
     C                   move      today         $cvd8i
     C                   eval      $cvcmd = '*CMDMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        todayo
     *
     C                   eval      w1fifo = todayo
     C                   else
     C                   eval      w1fifo = 0
     C                   endif
     *    Retrieve Item Lot/license plate tracking info.
     C                   eval      $lcmd = *blanks
     C                   eval      $lprg = #prog
     C                   eval      $lwhse = pwhse
     C                   eval      $litem = pPOItem
     *    Protect,non-display lot code entry field.
     c                   eval      NDLot = 'Y'
     C                   call      'GETLLP'
     C                   parm                    $lparm
     *
     C                   select
     *    Lot/license plate tracking values found.
     C                   when      $lrtn = '*OK     '
     C                   if        $llot = 'Y'
      * temp removed until uci mrc receiving installed
     c*                            or $plot <> ' '
     C                   eval      lottrk = '*YES'
     *    Display lot code entry field.
     C*                  eval      *in88 = *off
     c                   eval      NDLot = ' '
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
     C                   eval      w1plts = 0
710aA /free
710aA   if svmplt = 'N';
710aA     w1plts = 1;
710aA   endif;
710aA /end-free
     C                   if        client = saval
     C                   eval      w1plts = 1
     C                   endif
     C                   eval      w1avg = 'N'
     C                   eval      iatest = *blanks
     C                   eval      iaflag = *off
     *
     *   Get Unit of measure fields
     *
     C                   eval      w1um1 = *blanks
     C                   eval      w1um2 = *blanks
     C                   eval      w1um3 = *blanks
     C                   exsr      zzuom
     *
      /free
        // setup cross dock for json
        xdock = ' ';
        xdockflg = ' ';
CSPaD   //if client = CoastalSunbelt and $itdesg = 'JIT'
CSPaM   if client = CoastalSunbelt and ($itdesg = 'JIT' or $itdesg ='PC')
         or pdspcl = 'XD';
          xdock = 'Cross-Dock';
          xdockflg = 'Y';
        endif;
        // setup Pick Slot receiving information
        // Xdock receiving override pick slot, so pick slot would not be
        // set if the detail line was a cross dock. Cross Dock Wins.
        dput = ' ';
        directed = ' ';
        PSRcv = ' ';
        PSRcvFlg = ' ';
        PSRcvReq = ' ';
        if xdock = ' ';
          PSRcv = 'Pick Slot Receiving';
          // is the vendor setup to have all items pick slot received
          exec sql select * into :porec
               from popsr
               where powhse = :pWhse
                 and poven   = :phven
                 and poitem  = ' ';

          If sqlstt = sqlSuccess;
            PSRcvFlg = 'Y';
            PSRcvReq = 'Y';
          else;
            // is the item setup to always be pick slot received
            exec sql select * into :porec
                 from popsr
                 where powhse = :pWhse
                   and poitem  = :pPOItem
                   and poven   = 0;

            If sqlstt = sqlSuccess;
              PSRcvFlg = 'Y';
              PSRcvReq = 'Y';
            else;
              // is the item for this vendor setup to be pick slot received
              exec sql select * into :porec
                   from popsr
                   where powhse = :pWhse
                     and poitem  = :pPOItem
                     and poven   = :phven;
              If sqlstt = sqlSuccess;
                PSRcvFlg = 'Y';
                PSRcvReq = 'Y';
              endif;
            endif;
          endif;
          // directed putaway - pick slot rcv overrides directed putaway
          if PSRcvReq =' ';
            // get put away option
            ocode = '*PICK   ';
            wkwhse = pwhse;
            exec sql select * into :opdrec
                 from optiond
                 where opdwhs = :wkwhse
                   and opdwdp = :$itwhdp
                   and opdcod = :ocode;

            If sqlstt = sqlSuccess;
              optiondrec = opddta;
            else;
              opmput = 'N';
            endif;
            if opmput = 'N';
              dput = 'Directed Putaway';
              directed = 'Y';
750bA         w1um2 = ' ';
750bA         w1um3 = ' ';
            endif;
          endif;
        endif;
      /end-free
     C                   if        client = cheney
     C     $itdesg       chain     desigsp                            79
     C                   if        *in79 = *off
     C                   eval      sdesig = *on
     C                   else
     C                   eval      sdesig = *off
     C                   eval      dsscde = *blanks
     C                   endif
     C                   endif
     C                   if        client = yhata
FPRaAc                             or client = foodpro
740aAc                             or opsqto = 'Y'
     C*                  eval      *in63 = *off
     C                   eval      ndqord = ' '
     C*   Convert quantity to string.
     C                   eval      $ccmd = '*QTY2STR'
     C                   eval      $cprg = #prog
     C                   eval      $cqty1 = pdqor1
     C                   eval      $cqty2 = pdqor2
     C                   eval      $cqty3 = pdqor3
     C                   exsr      zzcvqy
     C                   eval      woqor = $cqstr
     C*
     C                   else
     C*                  eval      *in63 = *on
     C                   eval      ndqord = 'Y'
     C                   eval      woqor = *blanks
     C                   endif
     *
     *   Enable/Disable catch weight fields.
     *
     C                   eval      vrfycw = *off
     C*                  eval      *in82 = *off
     c                   eval      ndcw = ' '
     *
     *     First, see if catch weight entry is allowed.
     *
     C                   if        ($itcwgt <> 'Y'  and
     C                              $itcwgt <> 'S') or
     C                             svcwen = '3'
     C*                  eval      *in95 = *on
     c                   eval      ndcw = 'Y'
     C                   eval      vrfycw = *off
     C                   else
     C*                  eval      *in95 = *off
     c                   eval      ndcw = ' '
     C                   eval      vrfycw = *on
     C                   endif
     *
     *     Then see if we should block entry ...
     *       because catch weight previously entered.
     *
     C                   if        svcwen = '2'  and
     C                             pddwgt <> 0
     C*                  eval      *in82 = *on
     c                   eval      ndcw = 'Y'
     C*                  eval      *in95 = *on
     C                   eval      vrfycw = *off
     C                   endif
     *
     *     Then see what value is to be entered (1=Choice,2=Ttl,3=Avg)
     *
     C                   select
     C                   when      svcwtp = '2'
     C*                  eval      *in81 = *on
     C                   eval      ndcwex= 'Y'
     C                   eval      w1avg = 'N'
     C                   eval      wocrcv = cwt(2)
     C                   when      svcwtp = '3'
     C*                  eval      *in81 = *on
     C                   eval      ndcwex= 'Y'
     C                   eval      w1avg = 'Y'
     C                   eval      wocrcv = cwt(3)
     C                   other
     C                   eval      *in81 = *off
     C                   eval      ndcwex= ' '
     C                   eval      w1avg = 'N'
     C                   eval      wocrcv = cwt(1)
     C                   endsl
     *
     *   Enable/Disable expiration date fields.
     *
     C                   if        $itflgd <> 'Y'
     C*                  eval      *in96 = *on
     C                   eval      NDExpd = 'Y'
     C                   else
     C*                  eval      *in96 = *off
     C                   eval      NDExpd = ' '
     C                   endif
     *
     *   Get the picking slot for the item.
     *
     C                   if        $itstyp = 'P'
     C                   eval      $scmd = '*LAST'
     C                   else
     C                   eval      $scmd = '*FIRST'
     C                   endif
     C                   call      'GETPSLT'
     C                   parm                    $scmd             8
     C                   parm      $itwhse       $swhse
     C                   parm                    #sitem
     C                   parm                    woslot
     C                   parm      *blanks       $saisl            3
     C                   parm      *zeros        $sloc             3 0
     C                   parm      *zeros        $srlvl            2 0
     C                   parm      *blanks       $shand            2
     C                   parm                    $srtn             8
     *
     * Try to display Special Designation slot.
     C                   select
     C                   when      Client = cheney
     C                   if        woslot = '*NONE*  ' and
     C                             sdesig = *on
     C                   eval      woslot = dssdsp
     C                   endif
     C                   endsl
     *
     C                   eval      w1slot = *blanks
     *  See if any stock in overflow slot.
     *
     C                   eval      wOostk = 'N'
     C                   move      'A '          kystat
     C                   eval      kypick = 'N'
      /free
        setll (pwhse: $ititem: kystat: kypick) slot3;
        dow forevr = forevr;
          reade (pwhse: $ititem: kystat: kypick) slot3;
          if %eof(slot3);
            leave;
          endif;

      /end-free
     C*    keys3         setll     slot3
     C*                  dow       forevr = forevr
     C*    keys3         reade     slot3                                  79
     *
     C*                  if        *in79
     C*                  leave
     C*                  endif
     *
     C                   if        sldesg = 'BFC'
     C                   iter
     C                   endif
     *
     C*                  if        not *in79
     C                   if        slstk1 > 0  or
     C                             slstk2 > 0  or
     C                             slstk3 > 0
     C                   eval      wOostk = 'Y'
     C                   leave
     C                   endif
     C*                  endif
     C                   enddo
     *
     *   Enable Mfg date and disable Exp date, if Mfg date flag = 'Y'
     *
     C*    imkey         chain     itemmsc                            79
     C*                  if        not *in79  and
     C                   if        $immflg = 'Y'
     C*                  eval      *in87 = *off
     C*                  eval      *in96 = *on
     C                   eval      NDMfgd = ' '
     C                   eval      NDExpd = 'Y'
     C                   else
     C                   eval      *in87 = *on
     C                   eval      NDMfgd = 'Y'
     C                   endif
     C*                  if        *in79
     C*                  eval      immflg = 'N'
     C*                  endif
      * This was marked out for first go at receiving in mrc
      * load up fields from gs1 incoming information
      * Expiration Date
     c*                  If        not *in96
     c*                  if        $pexpdt > 0
     C*                  move      $pexpdt       $cvd6i
     C*                  eval      $cvcmd = '*YMDMDY '
     C*                  call      @cvtdt
     C*                  parm                    $cvtdt
     C*                  move      $cvd6o        w1exdt
     c*                  endif
     c*                  endif
      * Manufacturing Date
     c*                  If        immflg = 'Y'
     c*                  if        $pmfgdt > 0
     C*                  move      $pmfgdt       $cvd6i
     C*                  eval      $cvcmd = '*YMDMDY '
     C*                  call      @cvtdt
     C*                  parm                    $cvtdt
     C*                  move      $cvd6o        w1mfdt
     c*                  endif
     c*                  endif
      * Lot
     c*                  If        lottrk = '*YES'
     c*                  if        $pLot <> ' '
     c*                  eval      w1lotc = $plot
     c*                  endif
     c*                  endif
      * Catch Weight
     c*                  If        vrfycw = *on
     c*                  if        $pwgt > 0
     c*                  eval      w1dwgt = $pwgt
     c*                  endif
     c*                  endif
      * Quantity
     c*                  if        $pqty > 0
     c*                  eval      w1qrc1 = $pqty
     c*                  endif
      * # of Pallets
     c*                  if        $p#pall > 0
     c*                  eval      w1plts = $p#pall
     c*                  endif
      * OSS Receiving
      /free
          w1note = ' ';
        // temporarily taken out until oss receiving mrc installed
        //if $posscode <> ' ';
          //w1note = 'OSS Receiving';
        //endif;
      /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *     ZZCVQY - Convert receive qty's to string for msg display
     *
     C     zzcvqy        begsr
     C                   call      'CVTQTY'
     C                   parm                    $ccmd             8
     C                   parm                    $cprg            10
     C                   parm                    $cqty1            7 0
     C                   parm                    $cqty2            7 0
     C                   parm                    $cqty3            7 0
     C                   parm                    $cum1             2
     C                   parm                    $cum2             2
     C                   parm                    $cum3             2
     C                   parm                    $cqstr           10
     C                   parm                    $custr           17
     C                   parm                    $crtn             8
     C                   parm                    $cerm
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGTPDM  Get P/O Detail Misc. file
     *
     C     ZZGTPDM       Begsr
     C*
      /free
         exec sql select * into :pdmrec
              from podtlm
              where pdmwhs = :pWhse
                and pdmpo  = :pPO
                and pdmseq = :pPOSeq
                and pdmitm = :pPOItem;
           If sqlstt = sqlSuccess;
             podm1_rtx = pdmms1;
             podm2_rtx = pdmms2;
             podm3_rtx = pdmms3;
             podm4_rtx = pdmms4;
             podm5_rtx = pdmms5;
           else;
             pdmitm = ' ';
             pdmpom = ' ';
             pdmods = ' ';
             pdmms1 = ' ';
             pdmms2 = ' ';
             pdmms3 = ' ';
             pdmms4 = ' ';
             pdmms5 = ' ';
             podm1_rtx = ' ';
             rtxdm1_dnpckm = 0;
             rtxdm1_dniaov = 'N';
             rtxdm1_dncwcd = 'N';
             rtxdm1_dnwtiw = 0;
             rtxdm1_dncbec = 0;
             podm2_rtx = ' ';
             podm3_rtx = ' ';
             podm4_rtx = ' ';
             podm5_rtx = ' ';
           endif;
      /end-free
     C*
     C                   Endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C                   eval      forevr = *on
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     *R                   MOVE #PROG     $PPRG
     C                   eval      $cvprg = #prog
     C*                  eval      #pgmq = #prog
      ***** Code taken out for initial mrc receiving
      * determine if mfr decipher is available to client
     c*                  eval      $lcmd = '*OPEN'
     c*                  call      'MF200'                              66
     C*                  parm                    $lparm
     C*                  parm      0             $lexpdat          6 0
     C*                  parm      0             $lmfrdat          6 0
     C*                  parm                    $lupc            20
     C*                  parm      ' '           $ldecvalue       15
     C                   endsr
     C*
650dA*----------------------------------------------------------------
650dA*
650dA*  ZZRCVPOCREATE  Create receiver transaction.
650dA*
650dAC     zzrcvpocreate begsr
650dA*
650dA*     clear the return field used in po236
650dA*
650dAc                   eval      $lrtn = ' '
650dAC                   call      @crtrcv
650dAC                   parm      '*PO'         $lcmdr           10
650dAC                   parm      '*CREATE'     $lsubcmd         10
650dAC                   parm      pwhse         @lwhse            3 0
650dAC                   parm      0             $lpcs             5 0
650dAC                   parm      0             $lpallets         5 0
650dAC                   parm      0             $lsavetrn         7 0
650dAC                   parm                    ppo
650dAC                   parm      $itstyp       $litstyp          1
650dAC                   parm      $itwhdp       $litwhdp          5
650dAC*                  parm      '0'           $lcomplete        1
650dAC                   parm                    $lrtnr           10
700hAC                   parm                    puser            10
650dA*
650dAC                   endsr
     *----------------------------------------------------------------
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

      /free
       begsr getCurrStamp;

         getmicrotime(currstampuc:currstampsys);
         currstamploc = currstampsys + %hours(bfcoffset);

       endsr;
      /end-free
700bA*----------------------------------------------------------------
700bA*  extractuci    Extract uci data using CVTBAR
700bA*----------------------------------------------------------------
700bA
700bA /free
700bA  begsr extractuci;
700bA   $cbcmd = '*ALL    ';
700bA   $cbbar = uciscanned;
700fA   $cbwhse = pwhse;
700bA   clear $barcode;
700bA   clear $barcode2;
700bA   cvtbar('*ALL': uciscanned:
700bA        $cbcod: $cbdec: $cbdsc: $cbpos: $cbtyp: $cbv1: $cbv2:
700fM        $cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: $cbwhse:
740 A        $cbkilolbssent: $cbitem);
700fD        //$cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2);
700bA   $barcode = $cvtdata;
700bA   $barcode2 = $cvtdata2;
700cA   protectmfdt = 'N';
700cA   protectexdt = 'N';
700cA   protectwgt = 'N';
700cA   protectlot = 'N';
700bA   // Gtin found
700bA   if $bcGtinSent
740 A      or $pLpn<>*blanks;
700bA     reload = 'Y';
700bA   else;
700bA     $bcExpDSent = *off;
700bA     $bcProdDSent = *off;
700bA     $bcPNtLbSent = *off;
700bA     $bcLotSent = *off;
700bA   endif;
700bA   // convert dates into mmddyy format.
700bA   if $bcProdDSent and $bcProdD <> 0;
700dA     if ndmfgd = ' ';
700bA       $cvcmd = '*YMDMDY';
700bA       $cvd6i = %char($bcProdD);
700bA       cvtdte($cvtdt);
700bA       svmfdt = $cvd6o;
700cA       if $ifrcvmth = '2';
700cA         protectmfdt = 'Y';
700cA       endif;
700dA     endif;
700bA   endif;
700bA   if $bcPackDSent and $bcPackD <> 0;
700dA     if ndmfgd = ' ';
700bA       $cvcmd = '*YMDMDY';
700bA       $cvd6i = %char($bcPackD);
700bA       cvtdte($cvtdt);
700bA       svmfdt = $cvd6o;
700cA       if $ifrcvmth = '2';
700cA         protectmfdt = 'Y';
700cA       endif;
700dA     endif;
700bA   endif;
700bA   if $bcSlByDSent and $bcSlByD <> 0;
700dA     if ndexpd = ' ';
700bA       $cvcmd = '*YMDMDY';
700bA       $cvd6i = %char($bcSlByD);
700bA       cvtdte($cvtdt);
700bA       svexdt = $cvd6o;
700cA       if $ifrcvmth = '2';
700cA         protectexdt = 'Y';
700cA       endif;
700dA     endif;
700bA   endif;
700bA   if $bcExpDSent and $bcExpD <> 0;
700dA     if ndexpd = ' ';
700bA       $cvcmd = '*YMDMDY';
700bA       $cvd6i = %char($bcExpD);
700bA       cvtdte($cvtdt);
700bA       svexdt  = $cvd6o;
700cA       if $ifrcvmth = '2';
700cA         protectexdt = 'Y';
700cA       endif;
700dA     endif;
700bA   endif;
700bA   // load catch weight
700fA   select;
700fA     when svopwum = 'KGS'
700fA      or svopwum = 'kgs'
700fA      or svopwum = 'Kgs';
700fA       if $bcPNtkgSent
700fA          and $ifrcvmth = '2';
700fA         w1dwgt = $bcPNtkg;
700fA         protectwgt = 'Y';
700fA         NDcwex = 'Y';
700fA       endif;
700fA     other;
700bA       if $bcPNtLbSent
700bA          and $ifrcvmth = '2';
700bA         w1dwgt  = $bcPNtLb;
700cA         protectwgt = 'Y';
700fA         NDcwex = 'Y';
700bA       endif;
700fA   endsl;
700bA   // load Lot
700bA   if $bcLotSent;
700bA     w1lotc  = $bcLot;
700cA     if $ifrcvmth = '2';
700cA       protectlot = 'Y';
700fA       NDlot = ' ';
700cA     endif;
700bA   endif;

700bA  endsr;
700bA /end-free
740 A*----------------------------------------------------------------
740 A*  chkforAsn    Check for, and update PODTL record with ASN data
740 A*----------------------------------------------------------------
740 A
740 A /free
740 A  begsr chkforAsn;
740 A    protectqty = 'N';
740 A    savepokey = pokey;
740 A    savehotype = hotype;
740 A    pokey = %trim(pPO) + %editc(pPoSeq:'X') + %trim(pPoItem);
740 A    exec sql select * into :asnrec
740 A       from pirhold
740 A       where hosess = :psessid
740 A         and hotype = 'PODTLASN'
740 A         and hokey  = :pokey;
740 A      If sqlstt = sqlSuccess;
700aA        //NDlcns = ' ';     // blank for UCI Receiving
740 A        //rUCIFlg = ' ';    // Y for UCI Receiving
740 A        reload = 'Y';     // Causes R14600 call from M136xx to update values on screen
740 A        pirhldasds = a_hodata;
740 A        // force 1 pallet for auto load
740 A        w1plts=1;
740 A        // load proper quantity
740 A        select;
740 A          when $itum1 = phuom and phuom<>*blanks;
740 A            w1qrc1=phqtyr;
740 A          when $itum2 = phuom and phuom<>*blanks;
740 A            w1qrc2=phqtyr;
740 A          when $itum3 = phuom and phuom<>*blanks;
740 A            w1qrc3=phqtyr;
740 A          other;
740 A            w1qrc1=phqtyr;
740 A        endsl;
740 A        // Load LPN for ASN receiving
740 A        $pLpn = phlpn;
740 A        // convert dates into mmddyy format.
740 A        if $immflg='N';
740 A          // load Exp Date if exist
740 A          $cvcmd = '*YMDMDY';
740 A          $cvd6i = %char(phexpd);
740 A          cvtdte($cvtdt);
740 A          svexdt  = $cvd6o;
740 A          ndmfgd='Y';
740 A          ndexpd=' ';
740 A        else;
740 A          // load Mfg Date if exist
740 A          $cvcmd = '*YMDMDY';
740 A          $cvd6i = %char(phmfgd);
740 A          cvtdte($cvtdt);
740 A          svmfdt  = $cvd6o;
740 A          ndexpd='Y';
740 A          ndmfgd=' ';
740 A        endif;
740 A        // load catch weight
740 A        if phwgt<>0;
740 A         w1dwgt  = phwgt;
740 A         //protectwgt = 'Y';
740 A         NDcwex = ' ';
              NDcw=' ';
740 A       endif;
740 A       // load Lot
740 A       if phlot<>*blanks;
740 A         w1lotc  = phlot;
740 A         //protectlot = 'Y';
740 A         NDlot = ' ';
740 A       endif;
740 A       // Load quantity from asn
740 A       // Come back and use a passed uom to determine value
700aA       rUCI = 'ASN Receiving';
740 A   endif;
740 A   pokey=savepokey;
740 A   hotype=savehotype;
740 A
740 A  endsr;
740 A /end-free
**
Item (
Base (
SSB (
Item  . . . .
**
(Type ' ')
**
Catch weight (Ttl or Avg)
Catch weight (Total)
Catch weight (Average)
