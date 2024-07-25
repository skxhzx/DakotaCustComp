      /Copy qcopysrc,hspecs
     H dftactgrp(*NO)
     H actgrp('OR400')
      *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *   (BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR402     RF UCI Selection change Order Selection
     *  26 August 2019
     *  Lynn McMahon
     *
     *  Notes
     *       Created using OR400.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
730 A*    08/26/19  LMC  7.30
     *      - Created
740aA*    08/14/20  LMC  7.40a
     *      - Clean the w6cnt1 and w6wgt1 fields when a new label
     *        is entered.
740bA*    11/10/20  MLB  7.40b  ZD# 2924
     *     - Enh:  Recompiled pgm for changes in /copy book,
     *       ROSLVFYLBL. Ref 7.40 mod. Correct MCH1210-Rcver value too
     *       small to hold result error. Found at Big Apple.
     *     - Recompile pgms: VOSELECT, OR400 with this change.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     H bnddir('QC2LE':'QUSAPIBD':'BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *
     For402fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     FLicense   if   e           k disk
     Foptions   if   e           k disk
     Fpiritem   if   e           k disk
     Fitemmsc   if   e           k disk
     Fpirtran   if   e           k disk
     Frtehed    uf   e           k disk
     Fpirtran4  if   e           k disk    rename(ptrec:record)
     Fordh      if   e           k disk    rename(ohrec:orec)
     Fordh3     if   e           k disk
     Fbfcsktlog o    e           k disk
     Fupc5      if   e           k disk
     Fordp      if   e           k disk
     Flabel     if   e           k disk
     funmesr    if   e           k disk
     *----------------------------------------------------------------
     *  Client id's for custom mods.
     *----------------------------------------------------------------

      /copy qcopysrc,id#birite
      /copy qcopysrc,id#cdi
      /copy qcopysrc,id#cashwa
      /copy qcopysrc,id#cheney
      /copy qcopysrc,id#cheneyo
      /copy qcopysrc,id#cheneyr
      /copy qcopysrc,id#citylin
      /copy qcopysrc,id#dairyla
      /copy qcopysrc,id#westsid
      /copy qcopysrc,id#glp
      /copy qcopysrc,id#gsc
      /copy qcopysrc,id#ei
      /copy qcopysrc,id#harbor
      /copy qcopysrc,id#andrews
      /copy qcopysrc,id#saval
      /copy qcopysrc,id#isupply
      /copy qcopysrc,id#packers
      /copy qcopysrc,id#vip
      /copy qcopysrc,id#sgc
      /copy qcopysrc,id#ellenbe
      /copy qcopysrc,id#royal
      /copy qcopysrc,id#tpc
      /copy qcopysrc,id#citywho
      /copy qcopysrc,id#yhata
      /copy qcopysrc,id#ifd
      /copy qcopysrc,id#mjkelln
      /copy qcopysrc,id#renzi
      /copy qcopysrc,id#finkle
      /copy qcopysrc,id#palmer
      /copy qcopysrc,id#sofo
      /copy qcopysrc,id#frf
      /copy qcopysrc,id#capitol
      /copy qcopysrc,id#coastal
      /copy qcopysrc,id#jtd
      /copy qcopysrc,id#dierks
      /copy qcopysrc,id#silberm
      /copy qcopysrc,id#cpc
      /copy qcopysrc,id#avalon
      /copy qcopysrc,id#gmm
      /copy qcopysrc,id#hmwagne
      /copy qcopysrc,id#gfs
      /copy qcopysrc,id#pfc
      /copy qcopysrc,id#fpr
      /copy qcopysrc,id#wil
      /copy qcopysrc,id#pan
      /copy qcopysrc,id#jordano
      /copy qcopysrc,id#adf
      /copy qcopysrc,id#khl
      /copy qcopysrc,id#cot
      /copy qcopysrc,id#cfi
      /copy qcopysrc,id#grc
      /copy qcopysrc,id#acc
      /copy qcopysrc,id#mrt
      /copy qcopysrc,id#mqs
      /copy qcopysrc,id#eop
      /copy qcopysrc,id#swt
     D client          s             10

     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a2n             s              1    dim(2)
     D a10             s              1    dim(10)
     D desc            s             50    dim(15) ctdata perrcd(1)
     D em              s             50    dim(2) ctdata perrcd(1)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getstop
      /copy qcopysrc,p.umlabel

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#BARCODE
      /COPY *libl/qcopysrc,C#UCIINFO
      /Copy qcopysrc,p.getimuom
     D savever#        s                   like($itver#)
     *----------------------------------------------------------------
     *  Talkman record formats
     *----------------------------------------------------------------

      /Copy qcopysrc,r#header
      /Copy qcopysrc,rislassign
      /Copy qcopysrc,rislbeday
      /Copy qcopysrc,rislbox
      /Copy qcopysrc,rislchk4lb
      /Copy qcopysrc,rislchk4uf
      /Copy qcopysrc,rislclose
      /Copy qcopysrc,rislcomplt
      /Copy qcopysrc,rislcompl2
      /Copy qcopysrc,rislexpdte
      /Copy qcopysrc,rislgetcw
      /Copy qcopysrc,rislindtsk
      /Copy qcopysrc,rislnomcw
      /Copy qcopysrc,rislpckuci
      /Copy qcopysrc,rislpick
      /Copy qcopysrc,rislpickch
      /Copy qcopysrc,rislpicks
      /Copy qcopysrc,rislprtlbl
      /Copy qcopysrc,rislresett
      /Copy qcopysrc,rislresetu
      /Copy qcopysrc,rislresetw
      /Copy qcopysrc,rislscancw
      /Copy qcopysrc,rislsignof
      /Copy qcopysrc,rislsignon
      /Copy qcopysrc,rislsignrf
      /Copy qcopysrc,rislskipcw
      /Copy qcopysrc,rislsurvey
      /Copy qcopysrc,rislsuspnd
      /Copy qcopysrc,risltestcw
      /Copy qcopysrc,rislvfylbl
      /Copy qcopysrc,rislvfylic
      /Copy qcopysrc,rislvfyprt
      /Copy qcopysrc,rislvfyslt
      /Copy qcopysrc,rislvfyupc
      /Copy qcopysrc,rislvfyupu
      /Copy qcopysrc,rislweight

      /Copy qcopysrc,roslassign
      /Copy qcopysrc,roslbeday
      /Copy qcopysrc,roslbox
      /Copy qcopysrc,roslchk4lb
      /Copy qcopysrc,roslchk4uf
      /Copy qcopysrc,roslclose
      /Copy qcopysrc,roslcomplt
      /Copy qcopysrc,roslcompl2
      /Copy qcopysrc,roslexpdte
      /Copy qcopysrc,roslgetcw
      /Copy qcopysrc,roslnomcw
      /Copy qcopysrc,roslpick
      /Copy qcopysrc,roslindtsk
      /Copy qcopysrc,roslpickch
      /Copy qcopysrc,roslpicks
      /Copy qcopysrc,roslpckuci
      /Copy qcopysrc,roslprtlbl
      /Copy qcopysrc,roslresett
      /Copy qcopysrc,roslresetu
      /Copy qcopysrc,roslresetw
      /Copy qcopysrc,roslscancw
      /Copy qcopysrc,roslsignof
      /Copy qcopysrc,roslsignon
      /Copy qcopysrc,roslsignrf
      /Copy qcopysrc,roslskipcw
      /Copy qcopysrc,roslsurvey
      /Copy qcopysrc,roslsuspnd
      /Copy qcopysrc,rosltestcw
      /Copy qcopysrc,roslvfylbl
      /Copy qcopysrc,roslvfylic
      /Copy qcopysrc,roslvfyprt
      /Copy qcopysrc,roslvfyslt
      /Copy qcopysrc,roslvfyupc
      /Copy qcopysrc,roslvfyupu
      /Copy qcopysrc,roslweight

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
     *  Redefinition data structures
     *
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     *----------------------------------------------------------------
     * Data structure
     *
     D opdata          ds
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
     D  optend               117    117
     *
     D wkrtpo          ds
     D  wkrtid                 1      5
     D  wkppo                  6      9
     *
     *----------------------------------------------------------------
     *  TE130 Key Data Structure
     *----------------------------------------------------------------

     D $te130          ds
     D  $tlen                  1     50
     D  $temp#                 1      5  0
     D  $tstat                 6      6

     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
     D @adjtr          c                   const('ADJTRAN  ')
     D @adjt2          c                   const('ADJTRAN2')
     D @adjtd          c                   const('ADJTSKDET')
     D @addtr          c                   const('ADDSTDTRN')
     D @cvtbar         c                   const('CVTBAR')
     D @cvtbarsel      c                   const('CVTBARSEL')
     D @itmfl          c                   const('GETITEMFLD')
     D @pckrt          c                   const('CALPCKRTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
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
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     *
     D  $lrte                 22     26
     D  $lpo                  27     35
     D  $ltrn#                36     42  0
     *
     D  $ltrn1                19     25  0
     *
     D  $lcat                 19     24
     D  $ltktype              25     25
     D  $lcode                26     31
     *
      *
     D $prtky          ds
     D  $len50                 1    100
     D  $kwhse                 1      3  0
     D  $krte                  4      8
     D  $krtid                 9     13
     D  $ktruk                14     23
     D  $kstat                24     24
     D  $ktype                25     25
      *
     D  $whdp                  4      8
     D  $pitem                 9     23
     D  $newsl                24     35
     D  $disp                 36     47
     D  $lbl#                 48     51p 0
     D  $trn#                 52     55p 0
     D  $bat#                 56     59p 0
     D  $blkq                 60     62p 0
     D  $oblkq                63     65p 0
     D  $task                 66     71
     D  $prg                  72     81
     D  $ActualSlot           82     82
      *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     D  $ptype                81     88
     D  $pmput                89     89
     D  $plbl                 90     96  0
     D  $pqpck                97    101  0
     D  $pwarn               102    102
      *
      *   Redefine key
      *
     D  $pwhse                19     21  0
     D  $prte                 22     26
     D  $ppo                  27     35
     D  $ptrn#                36     42  0
     D  $puow#                60     68
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsukey                 1     50
     D  ukwhse                 1      3  0 inz(0)
     D  ukrte                  4      8
     D  ukpo                   9     17
     D  uktrn#                18     24  0 inz(0)
     D  ukguiuser             25     34    inz(' ')

     *
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
     D currstamp       s               z
     *----------------------------------------------------------------
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     *                                   P   1   20ERWHSE
     *
     D  erfld                  1     30
     *
     D  ertrn#                 1      4p 0
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
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     D #msgfc          c                   const('QCPFMSG   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  API programs
     *
     D @apics          c                   const('APICVTSLT ')
     *
     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------
     D editw11         c                   '0           '
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D $msgf           s             10
     D #job#           s              6  0
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D first2          s              1
     D first6          s              1
     D first6a         s              1
     D first18         s              1
     D first19         s              1
     D morelb          s              1
     D chk4err         s               n
     D clear           s              5  0
     D close           s              1
     D combo           s               n
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D curtime         s               z
     D cwgt            s              7  2
     D DonewithWgt     s               n
     D e               s              2  0
     D exwgt           s              9  2
     D first           s              1
     D forevr          s              1
     D foundWL         s              1
     D foundWLabel     s              1
     D help            s              5  0
     D hirng           s              9  2
     D hivar           s              9  2
     D hostStop        s              5  0
     D hvskp           s              1
     D ihvar           s              9  2
     D ilvar           s              9  2
     D ihrng           s              9  2
     D ilrng           s              9  2
     D itmdsc          s             70
     D kygrp2          s                   like(ptgrp2)
     D kyrtpo          s                   like(ptrtpo)
     D kylcns          s                   like(lilcns)
     D kywhse          s                   like(liwhse)
     D lblwgt          s              7  2
     D lflag           s              1
     D lstlic          s                   like(lilcns)
     D lvskp           s              1
     D lwrng           s              9  2
     D lwvar           s              9  2
     D msgk            s              4  0
     D nxtscr          s              3
     D ocode           s              8
     D otaisl          s              5  0
     D otcube          s              9  3
     D otgrp1          s              1
     D otgrp2          s              1
     D otpcs           s              5  0
     D otpo            s              9
     D otqty1          s              5  0
     D otqty2          s              5  0
     D otqty3          s              5  0
     D otstyp          s              1
     D otswgt          s              9  2
     D otwhdp          s              5
     D ovrrid          s              1
     D prg1c           s              4  3
     D prg2c           s              4  3
     D putflg          s              1
     D redspl          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D*savupc          s                   like(w4upcd)
     D sclear          s              1
     D stpflg          s              1
     D svdisp          s                   like(lbdisp)
     D svqpck          s                   like(lbqpck)
     D t#task          s              6
     D temp5           s              5
     D today           s              8  0
     D traxYN          s              1
     D trndte          s              8  0
     D trntim          s              6  0
     D ttlcub          s                   like($slasocube)
     D ttllic          s              3  0
     D ttlpcs          s                   like($slasopieces)
     D ttlwgt          s                   like($slasoweight)
     D type            s              3
     D ucicnt          s                   like(lbqpck)
     D ufinfl          s              1
     D usestr          s              4
     D wdpflg          s              1
     D wkcode          s              8
     D wkwhse          s                   like(liwhse)
     D Wktype          s              1    inz('O')
     D wtchk           s              1
     D zdesc           s             30
     D $pdqlib         s             10
     D $pdqnameout     s             10
     D $pdqkey         s             36
     D $pcominfo       s             25
     D $pheader        s            512
     D $pfields        s           2048
     D $prtnfields     s           2048
     D w2lbl           s              7  0
     D w6lbl           s              7  0
     D w6albl          s              7  0
     D w6aval          s              7  0
     D w18lbl          s              7  0
     D w19lbl          s              7  0
     D zmflag          s               n
     D zmsflag         s               n
     D KiloLbs         s              1
     D BegKiloLbs      s              1
     D kgs2lbs         c                   2.20462262
     D CnvWgt          s              9  2
     D IMUOM           s              3
     D wwgt            s             11  3
     D wgt             s             11  3
     D whereFrom       s              3
     D reccycle        s              2  0
     D multitran       s               n
     D kystat          s              1
     D kyent           s              1
     D count           s              5  0
     D wklabel         s             10
     D upcyes          s               n
     D zonepickup      s               n
     D firstzonepick   s               n
      ** temporary until added to genpick
     D opeqpj          s              1
     D opeqpt          s              6
     D w17trn#         s              7  0
     D w17lbl#         s              7  0
     D w17stop         s                   like($slvlostop)
     D w17item         s             15
     D WLUserChoice    s               n
     D FirstMslot      s               n
     D W6WGT1          S              6  2
     D W6WGT2          S              6  2
     D Pick2lbs        s              6  2

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  *GENPICK -  General picking options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPERPT  -  Print exception (short) error report (Y,N).
     *    OPELBL  -  Print exception (short) labels (Y,N)
     *    OPRFWC  -  Using RF will call (Y,N)
     *    OPNRSC  -  Number of pallet sections (1-9)
     *    OPHPWC  -  Host pick Will Call  (Y,N).
     *    OPMRGA  -  Merge Add-on order(s) with Open Routes.
     *    OPPLSQ  -  Pallet number sequence. 1=Unload, 2=Load.
     *    OPEADJ  -  Close short labels without adjustment (Y,N)
     *    OPNOPK  -  Pick items without pick slots as bulk picks? (Y,N)
      *    OPGPK1  -  <Not Used / Available>
      *    OPGPK2  -  <Not Used / Available>
      *               task has been assigned. (Y/N)
      *    OPJITR  -  Create JIT Letdown or JIT Replenishment
      *                 0=None. No replenishments are created.
      *                 1=Letdowns are created during Truck Builder
      *                   Pick/Print processing.
      *                 2=Priority Replenishments are created during
      *                   Truck Builder Pick/Print processing.
      *                 3=JIT Letdowns created when transaction is
      *                   checked out.
      *                 4=JIT Priority Replenishments created when
      *                   transaction is checked out.
      *    OPPSET  -  Print separate set summary label for each pallet.
      *    OPRFUC  -  RF Pick Verify item with UPC.
      *    OPRFLC  -  RF Pick Verify item with license.
      *    OPUSF1  -  USF Option: Allow merge items for stop to be split.
      *               across truck pallets.
     *    OPRFSL  -  RF Pick Verify slot (Y,N)
     *               Y=Yes
     *               N=No
     *               C=Scan Check Digit
     *               E=Enter to Continue
     *    OPRFQT  -  RF Pick Allow Qty Entry (Y,N)
     *    OPRFQTO -     With Quantity Over (if RF Pick Allow Qty Entry = Y)
     *    OPRFCS  -  RF Pick Allow Change Slot (Y,N)
     *    OPRFPM  -  RF Pick Method
     *               1=Manual
     *               2=Directed
     *    OPRFUI  -  Scan individual UPC for each unit.
     *    OPRFZP  -  Zone Pickup
     *    OPRFUW  -  Auto load weight from individual UPC
     *
     * Data structure
     *
     D opdat2          ds
     D  operpt                 1      1
     D  opelbl                 2      2
     D  oprfwc                 3      3
     D  opnrsc                 4      4
     D  ophpwc                 5      5
     D  opmrga                 6      6
     D  opplsq                 7      7
     D  opeadj                 8      8
     D  opnopk                 9      9
     D  opjitr                12     12
     D  oppset                13     13
     D  oprfuc                14     14
     D  oprflc                15     15
     D  opusf1                16     16
     D  oprfsl                17     17
     D  oprfqt                21     21
     D  oprfcs                22     22
     D  oprUSF                23     26
     D  oprfqto               27     29  0
     D  oprfpm                30     30
     D  oprfui                32     32
     D  oprfzp                33     33
     D  oprfuw                34     34
     D  opten2               117    117
     *----------------------------------------------------------------
     I*  *SYSTEM  -  System options.
     I*
     I* Fields
     I*
     I*    OPEPM   -  Using EPM module (Y,N).
     I*    OPRF    -  Using RF module (Y,N).
     I*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     I*    OPLETD  -  Print letdown labels (Y,N).
     I*    OPWRNC  -  Perform catch weight variance check (Y,N).
     I*    OPRG1C  -  Catch weight low variance percentage.
     I*    OPRG2C  -  Catch weight high variance percentage.
     I*    OPIMPI  -  Import item fields from host.(Y,N).
     I*    OPICW   -  Individual catch weight entry (Y,N).
     *
     * Data structure
     *
     D opdat3          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opicw                 13     13
     D  opten3               117    117
     *----------------------------------------------------------------
     *  *VOICE  -  PIR Voice options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPINCP  -  Include pack description (Y/N)
     *    OPCRTR  -  Create RUNNER entries for shorts/outs (Y/N)
     *    OPUPLV  -  Update Label with quantity picked during Voice
     *               selection (Y/N)
     *               NOTE: Any change to this field will cause OPUPLR
     *                     in the *RUNNER options record to be updated.
     *    OPVMRG  -  Create Runner entries for Merge records? (Y/N)
     *    OPFOUT  -  Create Runner entry after slot marked out. (Y/N)
     *    OPFRPL  -  Replenish flagged items before print report? (Y/N)
     *               & create Priority Replenishment if necessary.
     *    OPVMLT  -  Allow multiple transaction (Y/N)
     *    OPVSPN  -  Speak pallet number (Y/N)
     *    OPVSPZ  -  Speak pallet zone (Y/N)
     *    OPVSLW  -  Speak large quantity warning (Y/N)
     *    OPVCEP  -  Speak unit of measure change warning (Y/N)
     *    OPVSSN  -  Speak stop number (Y/N)
     *    OPVCPZ  -  Confirm pallet zone (Y/N)
     *    OPESTP  -  Extended stop number length (2-5)
     *
     * Data structure
     *
     *----------------------------------------------------------------

     D opvdta          ds
     D  opincp                 1      1
     D  opcrtr                 2      2
     D  opuplv                 3      3
     D  opvmrg                 4      4
     D  opoutf                 5      5
     D  opfrpl                 6      6
     D  opvmlt                 7      7
     D  opvspn                 8      8
     D  opvspz                 9      9
     D  opvslw                10     10
     D  opvcep                11     11
     D  opvssn                12     12
     D  opvcpz                13     13
     D  opestp                14     14
     D  opvend               117    117

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
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
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
     C     nxtscr        caseq     '02A'         sc2a
     C     nxtscr        caseq     '02B'         sc2b
     C     nxtscr        caseq     '02C'         sc2c
     C     nxtscr        caseq     '02D'         sc2d
     C     nxtscr        caseq     '03 '         sc03
     C     nxtscr        caseq     '04 '         sc04
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   eval      *inlr = *on
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
     C                   if        nxtscr = '02A'
     C                   exfmt     screen2a                             50
     C                   endif
     C                   if        nxtscr = '02B'
     C                   exfmt     screen2b                             50
     C                   endif
     C                   if        nxtscr = '02C'
     C                   exfmt     screen2c                             50
     C                   endif
     C                   if        nxtscr = '02D'
     C                   exfmt     screen2d                             50
     C                   endif
     C                   if        nxtscr = '03 '
     C                   exfmt     screen3                              50
     C                   endif
     C                   if        nxtscr = '04 '
     C                   exfmt     screen4                              50
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
     C                   setoff                                       3334
     C                   setoff                                       363738
     C                   setoff                                       3940
     *
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
     *---------------------------------------------------------------
     *
     *  Screen 01 initialization
     *
     C     scr01i        begsr
     C                   eval      nxtscr = '01 '
     C                   exsr      zzfil1
     C     end01i        endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  Screen 02a initialization
     *
     C     scr02ai       begsr
     C                   eval      nxtscr = '02A'
     C                   exsr      zzfil2a
     C     end02ai       endsr
     *----------------------------------------------------------------
     *
     *  Screen 02b initialization
     *
     C     scr02bi       begsr
     C                   eval      nxtscr = '02B'
     C                   exsr      zzfil2b
     C     end02bi       endsr
     *----------------------------------------------------------------
     *
     *  Screen 02c initialization
     *
     C     scr02ci       begsr
     C                   eval      nxtscr = '02C'
     C                   exsr      zzfil2c
     C     end02ci       endsr
     *----------------------------------------------------------------
     *
     *  Screen 02d initialization
     *
     C     scr02di       begsr
     C                   eval      nxtscr = '02D'
     C                   exsr      zzfil2d
     C     end02di       endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     C                   exsr      zzfil03
     C     end03i        endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  Screen 04  initialization
     *
     C     scr04i        begsr
     C                   eval      nxtscr = '04 '
     C                   exsr      zzfil04
     C     end04i        endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
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
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *
     *  Test for F12 - EOJ
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
     *----------------------------------------------------------------
     *
     *  SC2a -  Screen 2a
     *
     C     sc2a          begsr
     *
     *  Test for F3 - Exit
     *
     C*                  if        *inkc
     C*                  eval      nxtscr = 'EOJ'
     C*                  goto      endsc2a
     C*                  endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr02ai
     C                   goto      endsc2a
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C*                  exsr      scr01i
     C                   goto      endsc2a
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd2a
     C     cmdtkn        cabeq     *on           endsc2a
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2a
     C     error         cabeq     *on           endsc2a
     C                   exsr      zzupd2a
     C     error         cabeq     *on           endsc2a
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2a
     C     cmdtkn        cabeq     *on           endsc2a
     *
     C     endsc2a       endsr
     *----------------------------------------------------------------
     *
     *  SC2b -  Screen 2b
     *
     C     sc2b          begsr
     *
     *  Test for F3 - Exit
     *
     C*                  if        *inkc
     C*                  eval      nxtscr = 'EOJ'
     C*                  goto      endsc2b
     C*                  endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr02bi
     C                   goto      endsc2b
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C*                  exsr      scr01i
     C                   goto      endsc2b
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd2b
     C     cmdtkn        cabeq     *on           endsc2b
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2b
     C     error         cabeq     *on           endsc2b
     C                   exsr      zzupd2b
     C     error         cabeq     *on           endsc2b
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2b
     C     cmdtkn        cabeq     *on           endsc2b
     *
     C     endsc2b       endsr
     *----------------------------------------------------------------
     *
     *  SC2c -  Screen 2c
     *
     C     sc2c          begsr
     *
     *  Test for F3 - Exit
     *
     C*                  if        *inkc
     C*                  eval      nxtscr = 'EOJ'
     C*                  goto      endsc2c
     C*                  endif
     *
     *  Test for F5 - Refresh
     *
     C*                  if        *inke
     C*                  exsr      scr02ci
     C*                  goto      endsc2c
     C*                  endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = '02A'
     C                   goto      endsc2c
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd2c
     C     cmdtkn        cabeq     *on           endsc2c
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2c
     C     error         cabeq     *on           endsc2c
     C                   exsr      zzupd2c
     C     error         cabeq     *on           endsc2c
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2c
     C     cmdtkn        cabeq     *on           endsc2c
     *
     C     endsc2c       endsr
     *----------------------------------------------------------------
     *
     *  SC2d -  Screen 2d
     *
     C     sc2d          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     c                   eval      nxtscr = '02A'
     C                   goto      endsc2d
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd2d
     C     cmdtkn        cabeq     *on           endsc2d
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2d
     C     error         cabeq     *on           endsc2d
     C                   exsr      zzupd2d
     C     error         cabeq     *on           endsc2d
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2d
     C     cmdtkn        cabeq     *on           endsc2d
     *
     C     endsc2d       endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  SC03 -  Screen 03
     *
     C     sc03          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc03
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr03i
     C                   goto      endsc03
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc03
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd03
     C     cmdtkn        cabeq     *on           endsc03
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk03
     C     error         cabeq     *on           endsc03
     C                   exsr      zzupd03
     C     error         cabeq     *on           endsc03
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd03
     C     cmdtkn        cabeq     *on           endsc03
     *
     C                   eval      nxtscr = 'EOJ'
     C     endsc03       endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  SC04 -  Screen 04
     *
     C     sc04          begsr
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk04
     C     error         cabeq     *on           endsc04
     C                   exsr      zzupd04
     C     error         cabeq     *on           endsc04
     *
     c     endsc04       tag
     c                   exsr      zsclr
     C                   endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     * Get client id

     C                   call      'GETCLIENT'
     C                   parm                    client
     *
     *  Initialize special keys
     *
     C*                  eval      enter = 0
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
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------*********
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
     *    ZMPCPF  Add CPF message record to subfile
     *
     C     zmpcpf        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgfc
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
     *      6401  Multi trans, end using task entry.
     *
     C     zm6401        begsr
     C                   eval      #msgid = 'PT64001'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   eval      $rtn = '*PGMQ   '
     C                   endsr
     *----------------------------------------------------------------
     *      6403  Flags exists, can not close this transaction.
     *
     C     zm6403        begsr
     C                   eval      #msgid = 'PT64003'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   eval      $rtn = '*PGMQ   '
     C                   endsr
     *----------------------------------------------------------------
     *   CPF9898  Generic error message
     *
     C     zm9898        begsr
     C                   eval      #msgid = 'CPF9898'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpcpf
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
     *     PIR7979  Record does not exist.
     *
     C     zm7979        begsr
     C                   eval      #msgid = 'PIR7979'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   LP11022  Invalid license number.
     *
     C     zm1022        begsr
     C                   eval      #msgid = 'LP11022'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   RC20001  Invalid slot entered.(TO)
     *
     C     zm2001        begsr
     C                   eval      #msgid = 'RC20001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   RC20002 Transaction is closed.
     *
     C     zm2002        begsr
     C                   eval      #msgid = 'RC20002'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   RC20003 Quantity must be > 0.
     *
     C     zm2003        begsr
     C                   eval      #msgid = 'RC20003'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   RC20004 Quantity can't be > quantity to put away.
     *
     C     zm2004        begsr
     C                   eval      #msgid = 'RC20004'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
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
     *      0110  Number must be > 0
     *
     C     zm0110        begsr
     C                   move      'PIR0110'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0204  Enter only one value.
     *
     C     zm0204        begsr
     C                   eval      #msgid = 'PIR0204'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0205  Must enter one value.
     *
     C     zm0205        begsr
     C                   eval      #msgid = 'PIR0205'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
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
     *     IT15204  Virtual slot could not be created.
     *
     C     zm1524        begsr
     C                   eval      #msgid = 'IT15204'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PT13021  Warning: Entered catch wt not within +/- range.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'PT13021'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     Smaller message for new rf selection device
     *
     C     zm21Small     begsr
     c** per Hemant we need shorter messages
     c                   eval      errmsg = 'Warning: ' +
     c                                       %char(ertcwt) +
     c                                       ' is not within ' +
     c                                       %char(erlrng) + ' / ' +
     C                                       %char(erhrng)
     C                   exsr      zm9898
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
     *   PIR9908  &1 currently inuse. &2 in progress.
     *
     C     zm9908        begsr
     C                   eval      #msgid = 'PIR9908'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md(1) = errmsg
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0105  ZZZZZZ
     *
     C     zms105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   eval      $rtn = '*PGMQ   '
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  Verify label is still open lbstat = 'P'
     *
     C                   time                    curtime
      /free
        if w1lbl#b = ' ' and w1uci = ' ';
          error = *on;
          *in23 = *on;
          *in03 = *on;
          errmsg = 'Scan a label or UCI';
          exsr zm9898;
          leavesr;
        endif;
        $hdrtimestamp = %char(curtime);
        if w1lbl#b <> ' ';
          $pbarcode = w1lbl#b;
          exsr zztraxlbl;
          w2lbl = $plbl#;
          chain (w2lbl) label;
          if %found(label);
            if lbstat = 'C';
              error = *on;
              *in23 = *on;
              *in03 = *on;
              errmsg = 'Label is already closed';
              exsr zm9898;
              leavesr;
            endif;
          else;
            error = *on;
            *in23 = *on;
            *in03 = *on;
            errmsg = 'Label is not found';
            exsr zm9898;
            leavesr;
          endif;
        endif;

        if w1uci <> ' ';
          exsr clr$uciinfo;
          $uiwhse = w1whse;
          $uiuci  = w1uci;
          $dricommand = '*UCIINFO';
          $drisubcmd  = '*GET4LBL';
          $drisys2upd = 'D';
          exsr zzzdricop;
          if $drireturn = '*OK';
            chain ($UISELLBL#) label;
            if %found(label);
              if lbstat = 'C';
                error = *on;
                *in23 = *on;
                *in03 = *on;
                errmsg = 'Label is already closed';
                exsr zm9898;
                leavesr;
              endif;
            else;
              error = *on;
              *in23 = *on;
              *in03 = *on;
              errmsg = 'Label is not found';
              exsr zm9898;
              leavesr;
            endif;
          else;
            error = *on;
            *in23 = *on;
            *in03 = *on;
            errmsg = 'Label is not found';
            exsr zm9898;
            leavesr;
          endif;
        endif;
        monitor;
        umWhse = lbwhse;
        umlabel('*GET': umRtnCode: umRtnMsg:
                 umWhse: lblbl#:
                 umFlexPickFlag:
                 lbualq1: lbualu1: lbualq2: lbualu2: lbualq3: lbualu3);
        on-error;
          umRtnCode = '*ERROR';
        endmon;

        if umRtnCode = '*OK';
          select;
            when umFlexPickFlag = 'P2W';
              pick2lbs = lbualq1;
            when umFlexPickFlag = 'PAQ';
          endsl;
        endif;

        exsr zzgeti;
        if $ifsltmth <> '2';
          error = *on;
          *in23 = *on;
          *in03 = *on;
          errmsg = 'Item is not UCI Selection';
          exsr zm9898;
          leavesr;
        endif;
      /end-free
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  ZZCHK2a  Screen 2a error checking.
     *
     C     zzchk2a       begsr
     C                   eval      error = *off

     *    Check for I99 uci

     C                   call      'CVTBAR'
     C                   parm      '*ALL'        $cbcmd            8
     C                   parm      w6uci         $cbbar          100
     C                   parm                    $cbcod            3 0
     C                   parm                    $cbdec            1 0
     C                   parm                    $cbdsc           30
     C                   parm                    $cbpos            3 0
     C                   parm                    $cbtyp            1 0
     C                   parm                    $cbv1            11 3
     C                   parm                    $cbv2            50
     C                   parm                    $cbrtn            8
     C                   parm                    $cberm           60
     C                   parm                    $cbven           10 0
     C                   parm                    $cvtdata        256
     C                   parm                    $cvtdata2       256

     c                   eval      $barcode = $cvtdata
     c                   eval      $barcode2 = $cvtdata2

     *  Verify UPC UOM is the correct UOM being picked.
     * Fill r#header ds
     c                   if        not $bcai99sent
     C                   eval      $hdrcommand = 'vfyupcuom'
     C                   time                    curtime
     C                   eval      $hdrtimestamp = %char(curtime)
     C                   eval      $slvuuitman#  = #job
     C                   eval      $slvuuilbl#  = lblbl#
     C                   eval      $slvuuivalue = w6uci
     C                   eval      $pheader = $header
     C                   eval      $pfields = $slvfyupuin
     C                   exsr      writelog
     C                   call      'VOSELECT'
     C                   parm      '*none'       $pdqlib
     C                   parm      '*none'       $pdqnameout
     C                   parm      '*none'       $pdqkey
     C                   parm                    $pheader
     C                   parm                    $pfields
     C                   parm                    $prtnfields
     C                   eval      $slvfyupuout = $prtnfields
     *
     C                   if        $slvuuoerrnum   <> 0
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = $slvuuoerrtxt
     C                   exsr      zm9898
     C                   goto      endck2a
     C                   endif
     C                   endif
     *
     *
     *  Verify UCI is for item scanned on label from SCreen1
     * Fill r#header ds
     C                   eval      $hdrcommand = 'pickuci'
     C                   time                    curtime
     C                   eval      $hdrtimestamp = %char(curtime)
     C                   eval      $slpuitman# = #job
     C                   eval      $slpuitrn# = lbtrn#
     C                   eval      $slpuilbl# = lblbl#
     C                   eval      $slpuistop = lbstop
     C                   eval      $slpuiitem = lbitem
     C                   eval      $slpuislot = lbdisp
     C                   eval      $slpuiuci = w6uci
     C                   eval      $pheader = $header
     C                   eval      $pfields = $slpickuciin
     C                   exsr      writelog
     C                   call      'VOSELECT'
     C                   parm      '*none'       $pdqlib
     C                   parm      '*none'       $pdqnameout
     C                   parm      '*none'       $pdqkey
     C                   parm                    $pheader
     C                   parm                    $pfields
     C                   parm                    $prtnfields
     C                   eval      $slpckuciout   = $prtnfields
     *
     C                   if        $slpuoerrnum > 0
      /free
        //if w6cnt2 = 1 and ufinfl = *on;
          //if w6cnt1 = 1;
            //w6cnt1 = w6cnt1 - 1;
          //endif;
          //leavesr;
        //endif;
      /end-free
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = $slpuoerrtext
     C                   exsr      zm9898
     C                   goto      endck2a
     C                   endif

     C     endck2a       endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2b  Screen 2b error checking.
     *
     C     zzchk2b       begsr
     C                   eval      error = *off

     *    Check for I99 uci

     C                   call      'CVTBAR'
     C                   parm      '*ALL'        $cbcmd            8
     C                   parm      w6uci         $cbbar          100
     C                   parm                    $cbcod            3 0
     C                   parm                    $cbdec            1 0
     C                   parm                    $cbdsc           30
     C                   parm                    $cbpos            3 0
     C                   parm                    $cbtyp            1 0
     C                   parm                    $cbv1            11 3
     C                   parm                    $cbv2            50
     C                   parm                    $cbrtn            8
     C                   parm                    $cberm           60
     C                   parm                    $cbven           10 0
     C                   parm                    $cvtdata
     C                   parm                    $cvtdata2

     c                   eval      $barcode = $cvtdata
     c                   eval      $barcode2 = $cvtdata2

     *  Verify UPC UOM is the correct UOM being picked.
     * Fill r#header ds
     c                   if        not $bcai99sent
     C                   eval      $hdrcommand = 'vfyupcuom'
     C                   time                    curtime
     C                   eval      $hdrtimestamp = %char(curtime)
     C                   eval      $slvuuitman#  = #job
     C                   eval      $slvuuilbl#  = lblbl#
     C                   eval      $slvuuivalue = w6uci
     C                   eval      $pheader = $header
     C                   eval      $pfields = $slvfyupuin
     C                   exsr      writelog
     C                   call      'VOSELECT'
     C                   parm      '*none'       $pdqlib
     C                   parm      '*none'       $pdqnameout
     C                   parm      '*none'       $pdqkey
     C                   parm                    $pheader
     C                   parm                    $pfields
     C                   parm                    $prtnfields
     C                   eval      $slvfyupuout = $prtnfields
     *
     C                   if        $slvuuoerrnum   <> 0
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = $slvuuoerrtxt
     C                   exsr      zm9898
     C                   goto      endck2b
     C                   endif
     C                   endif
     *
     *
     *  Verify UCI is for item scanned on label from SCreen2
     * Fill r#header ds
     C                   eval      $hdrcommand = 'pickuci'
     C                   time                    curtime
     C                   eval      $hdrtimestamp = %char(curtime)
     C                   eval      $slpuitman# = #job
     C                   eval      $slpuitrn# = lbtrn#
     C                   eval      $slpuilbl# = lblbl#
     C                   eval      $slpuistop = lbstop
     C                   eval      $slpuiitem = lbitem
     C                   eval      $slpuislot = lbdisp
     C                   eval      $slpuiuci = w6uci
     C                   eval      $pheader = $header
     C                   eval      $pfields = $slpickuciin
     C                   exsr      writelog
     C                   call      'VOSELECT'
     C                   parm      '*none'       $pdqlib
     C                   parm      '*none'       $pdqnameout
     C                   parm      '*none'       $pdqkey
     C                   parm                    $pheader
     C                   parm                    $pfields
     C                   parm                    $prtnfields
     C                   eval      $slpckuciout   = $prtnfields
     *
     C                   if        $slpuoerrnum > 0
      /free
        //if w6cnt2 = 1 and ufinfl = *on;
          //if w6cnt1 = 1;
            //w6cnt1 = w6cnt1 - 1;
          //endif;
          //leavesr;
        //endif;
      /end-free
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = $slpuoerrtext
     C                   exsr      zm9898
     C                   goto      endck2b
     C                   endif

     C     endck2b       endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2c  Screen 2c error checking.
     *
     C     zzchk2c       begsr
     C                   eval      error = *off

     *    Check for I99 uci

     C                   call      'CVTBAR'
     C                   parm      '*ALL'        $cbcmd            8
     C                   parm      w6uci         $cbbar          100
     C                   parm                    $cbcod            3 0
     C                   parm                    $cbdec            1 0
     C                   parm                    $cbdsc           30
     C                   parm                    $cbpos            3 0
     C                   parm                    $cbtyp            1 0
     C                   parm                    $cbv1            11 3
     C                   parm                    $cbv2            50
     C                   parm                    $cbrtn            8
     C                   parm                    $cberm           60
     C                   parm                    $cbven           10 0
     C                   parm                    $cvtdata
     C                   parm                    $cvtdata2

     c                   eval      $barcode = $cvtdata
     c                   eval      $barcode2 = $cvtdata2

     *  Verify UPC UOM is the correct UOM being picked.
     * Fill r#header ds
     c                   if        not $bcai99sent
     C                   eval      $hdrcommand = 'vfyupcuom'
     C                   time                    curtime
     C                   eval      $hdrtimestamp = %char(curtime)
     C                   eval      $slvuuitman#  = #job
     C                   eval      $slvuuilbl#  = lblbl#
     C                   eval      $slvuuivalue = w6uci
     C                   eval      $pheader = $header
     C                   eval      $pfields = $slvfyupuin
     C                   exsr      writelog
     C                   call      'VOSELECT'
     C                   parm      '*none'       $pdqlib
     C                   parm      '*none'       $pdqnameout
     C                   parm      '*none'       $pdqkey
     C                   parm                    $pheader
     C                   parm                    $pfields
     C                   parm                    $prtnfields
     C                   eval      $slvfyupuout = $prtnfields
     *
     C                   if        $slvuuoerrnum   <> 0
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = $slvuuoerrtxt
     C                   exsr      zm9898
     C                   goto      endck2c
     C                   endif
     C                   endif
     *
     *
     *  Verify UCI is for item scanned on label from SCreen2
     * Fill r#header ds
     C                   eval      $hdrcommand = 'unpickuci'
     C                   time                    curtime
     C                   eval      $hdrtimestamp = %char(curtime)
     C                   eval      $slpuitman# = #job
     C                   eval      $slpuitrn# = lbtrn#
     C                   eval      $slpuilbl# = lblbl#
     C                   eval      $slpuistop = lbstop
     C                   eval      $slpuiitem = lbitem
     C                   eval      $slpuislot = lbdisp
     C                   eval      $slpuiuci = w6uci
     C                   eval      $pheader = $header
     C                   eval      $pfields = $slpickuciin
     C                   exsr      writelog
     C                   call      'VOSELECT'
     C                   parm      '*none'       $pdqlib
     C                   parm      '*none'       $pdqnameout
     C                   parm      '*none'       $pdqkey
     C                   parm                    $pheader
     C                   parm                    $pfields
     C                   parm                    $prtnfields
     C                   eval      $slpckuciout   = $prtnfields
     *
     C                   if        $slpuoerrnum > 0
      /free
        //if w6cnt2 = 1 and ufinfl = *on;
          //if w6cnt1 = 1;
            //w6cnt1 = w6cnt1 - 1;
          //endif;
          //leavesr;
        //endif;
      /end-free
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = $slpuoerrtext
     C                   exsr      zm9898
     C                   goto      endck2c
     C                   endif

     C     endck2c       endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2d  Screen 2d error checking.
     *
     C     zzchk2d       begsr
     C                   eval      error = *off

     *    Check for I99 uci

     C                   call      'CVTBAR'
     C                   parm      '*ALL'        $cbcmd            8
     C                   parm      w6uci         $cbbar          100
     C                   parm                    $cbcod            3 0
     C                   parm                    $cbdec            1 0
     C                   parm                    $cbdsc           30
     C                   parm                    $cbpos            3 0
     C                   parm                    $cbtyp            1 0
     C                   parm                    $cbv1            11 3
     C                   parm                    $cbv2            50
     C                   parm                    $cbrtn            8
     C                   parm                    $cberm           60
     C                   parm                    $cbven           10 0
     C                   parm                    $cvtdata
     C                   parm                    $cvtdata2

     c                   eval      $barcode = $cvtdata
     c                   eval      $barcode2 = $cvtdata2

     *  Verify UPC UOM is the correct UOM being picked.
     * Fill r#header ds
     c                   if        not $bcai99sent
     C                   eval      $hdrcommand = 'vfyupcuom'
     C                   time                    curtime
     C                   eval      $hdrtimestamp = %char(curtime)
     C                   eval      $slvuuitman#  = #job
     C                   eval      $slvuuilbl#  = lblbl#
     C                   eval      $slvuuivalue = w6uci
     C                   eval      $pheader = $header
     C                   eval      $pfields = $slvfyupuin
     C                   exsr      writelog
     C                   call      'VOSELECT'
     C                   parm      '*none'       $pdqlib
     C                   parm      '*none'       $pdqnameout
     C                   parm      '*none'       $pdqkey
     C                   parm                    $pheader
     C                   parm                    $pfields
     C                   parm                    $prtnfields
     C                   eval      $slvfyupuout = $prtnfields
     *
     C                   if        $slvuuoerrnum   <> 0
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = $slvuuoerrtxt
     C                   exsr      zm9898
     C                   goto      endck2d
     C                   endif
     C                   endif
     *
     *
     *  Verify UCI is for item scanned on label from SCreen2
     * Fill r#header ds
     C                   eval      $hdrcommand = 'unpickuci'
     C                   time                    curtime
     C                   eval      $hdrtimestamp = %char(curtime)
     C                   eval      $slpuitman# = #job
     C                   eval      $slpuitrn# = lbtrn#
     C                   eval      $slpuilbl# = lblbl#
     C                   eval      $slpuistop = lbstop
     C                   eval      $slpuiitem = lbitem
     C                   eval      $slpuislot = lbdisp
     C                   eval      $slpuiuci = w6uci
     C                   eval      $pheader = $header
     C                   eval      $pfields = $slpickuciin
     C                   exsr      writelog
     C                   call      'VOSELECT'
     C                   parm      '*none'       $pdqlib
     C                   parm      '*none'       $pdqnameout
     C                   parm      '*none'       $pdqkey
     C                   parm                    $pheader
     C                   parm                    $pfields
     C                   parm                    $prtnfields
     C                   eval      $slpckuciout   = $prtnfields
     *
     C                   if        $slpuoerrnum > 0
      /free
        //if w6cnt2 = 1 and ufinfl = *on;
          //if w6cnt1 = 1;
            //w6cnt1 = w6cnt1 - 1;
          //endif;
          //leavesr;
        //endif;
      /end-free
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = $slpuoerrtext
     C                   exsr      zm9898
     C                   goto      endck2d
     C                   endif

     C     endck2d       endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  ZZCHK03  Screen 03 error checking.
     *
     C     zzchk03       begsr
     C                   eval      error = *off
     C     endck03       endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  ZZCHK04  Screen 04 error checking.
     *
     C     zzchk04       begsr
     C                   eval      error = *off
     *
     *
     *   Make sure that the answer is Y/N.
     C                   if        cdone<> 'Y' and cdone<> 'N'
     C                   eval      error = *on
     C                   eval      errmsg = ' '
     C                   exsr      zm1005
     C                   goto      endck04
     C                   endif
     *
     *   pick qty can't exceed lbqalc qty unless it is a special pick
     *
      /free
        if cdone = 'Y';
          select;
            when umFlexPickFlag = 'P2W';
            when umFlexPickFlag = 'PAQ';
            other;
              if w6cnt1 > lbqalc;
                error = *on;
                errmsg = 'Pick Qty cannot exceed order qty';
                exsr zm0105;
                leavesr;
              endif;
            endsl;
        endif;
      /end-free
     C*
     C     endck04       endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '

     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  ZZCMD2a  User defined command keys for screen 2a.
     *
     C     zzcmd2a       begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4  - Delete
     *
     C                   if        *inkd
     c                   eval      wherefrom = nxtscr
     C                   exsr      scr02di
     C                   eval      cmdtkn = *on
     C                   goto      endcm2a
     C                   endif
     *
     *  Test for F6  - Done
     *
     C                   if        *inkf
     c                   eval      wherefrom = nxtscr
     C                   exsr      scr04i
     C                   eval      cmdtkn = *on
     C                   goto      endcm2a
     C                   endif
     *
     *  Test for F10 - Short
     *
     C                   if        *inkj
     C                   endif
     C                   endif
     *
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2a       endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2b  User defined command keys for screen 2b.
     *
     C     zzcmd2b       begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4  - Delete
     *
     C                   if        *inkd
     c                   eval      wherefrom = nxtscr
     C                   exsr      scr02ci
     C                   eval      cmdtkn = *on
     C                   goto      endcm2b
     C                   endif
     *
     *  Test for F6  - Done
     *
     C                   if        *inkf
     c                   eval      wherefrom = nxtscr
     C                   exsr      scr04i
     C                   eval      cmdtkn = *on
     C                   goto      endcm2b
     C                   endif
     *
     *  Test for F10 - Short
     *
     C                   if        *inkj
     C                   endif
     C                   endif
     *
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2b       endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2c  User defined command keys for screen 2c.
     *
     C     zzcmd2c       begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F6  - Done
     *
     C                   if        *inkf
     c                   eval      wherefrom = nxtscr
     C                   exsr      scr04i
     C                   eval      cmdtkn = *on
     C                   goto      endcm2c
     C                   endif
     *
     *  Test for F10 - Short
     *
     C                   if        *inkj
     C                   endif
     C                   endif
     *
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2c       endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2d  User defined command keys for screen 2d.
     *
     C     zzcmd2d       begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F6  - Done
     *
     C                   if        *inkf
     c                   eval      wherefrom = nxtscr
     C                   exsr      scr04i
     C                   eval      cmdtkn = *on
     C                   goto      endcm2d
     C                   endif
     C                   endif
     *
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2d       endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  ZZCMD03  User defined command keys for screen 03.
     *
     C     zzcmd03       begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm03       endsr
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   z-add     0             w2lbl
     C                   eval      w1lbl#b = *blanks
     C                   eval      w1uci = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  ZZFIL2a  Fill screen 2a fields with info from file.
     *
     C     zzfil2a       begsr
      /free
         if first6 = *off;
           w6cnt1 = ucicnt;
           w6cnt2 = lbqalc;
         endif;
         w6uci   = ' ';
         exsr getuomdesc;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2b  Fill screen 2b fields with info from file.
     *
     C     zzfil2b       begsr
      /free

        if first6 = *off;
          w6cnt1 = ucicnt;
          w6wgt1 = lblwgt;
          w6cnt2 = lbqalc;
          w6wgt2 = Pick2lbs;
        endif;
        w6uci   = ' ';
        w6uom = 'Lbs';
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2c  Fill screen 2c fields with info from file.
     *
     C     zzfil2c       begsr
     C                   if        first6 = *off
     C                   eval      w6cnt1 = ucicnt
     C                   eval      w6wgt1 = lblwgt
     c                   endif
     C                   eval      w6cnt2 = 99999
     c*** temp hard code until I know where I will get weight
     C                   eval      w6wgt2 = Pick2lbs
     C                   eval      w6uci   = ' '
     c                   exsr      getuomdesc
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2d  Fill screen 2d fields with info from file.
     *
     C     zzfil2d       begsr
      /free
        if first6 = *off;
          w6cnt1 = ucicnt;
          w6cnt2 = lbqalc;
        endif;
        w6uci   = ' ';
        exsr getuomdesc;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  ZZFIL03  Fill screen 03 fields with info from file.
     *
     C     zzfil03       begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL04  Fill screen 04 fields with info from file.
     *
     C     zzfil04       begsr
     c                   eval      cdone= 'N'
     C                   endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  ZZCWGT   Calculate catch weight variance values.
     *
     C     zzcwgt        begsr
     *
     *  If verify catch weight = yes
     *   Calculate total expected catch weight,
     *   Calculate low/high ranges.
     C                   if        opwrnc = 'M' or
     C                             opwrnc = 'B'
     C                   z-add     0             lwvar
     C                   z-add     0             hivar
     C                   z-add     0             lwrng
     C                   z-add     0             hirng
     C                   z-add     0             exwgt
     C                   z-add     0             ilvar
     C                   z-add     0             ihvar
     C                   z-add     0             ilrng
     C                   z-add     0             ihrng
     c                   if        nxtscr = '17'
     c                             and WLUserChoice = *on
     C     $slgwoqty     mult      $slgwouwgt    exwgt
     c                   else
     C     $slvlopickqty mult      $slvlouwgt    exwgt
     c                   endif
     *   Iniz flag used to skip variance check if = *ON.
     C                   eval      lvskp = *off
     C                   eval      hvskp = *off
     *   Use item variance % if it exists.
     C     imkey         chain     itemmsc                            79
     C                   if        *in79 = *off
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
     c                   if        nxtscr = '17'
     c                             and WLUserChoice = *on
     C     $slgwouwgt    mult      prg1c         ilvar
     c                   else
     C     $slvlouwgt    mult      prg1c         ilvar
     c                   endif
     C*    lbuwgt        mult      prg1c         ilvar
     C                   endif
     C     exwgt         sub       lwvar         lwrng
     c                   if        nxtscr = '17'
     c                             and WLUserChoice = *on
     C     $slgwouwgt    sub       ilvar         ilrng
     c                   else
     C     $slvlouwgt    sub       ilvar         ilrng
     c                   endif
     C                   if        prg2c > 0
     C     exwgt         mult      prg2c         hivar
     c                   if        nxtscr = '17'
     c                             and WLUserChoice = *on
     C     $slgwouwgt    mult      prg2c         ihvar
     c                   else
     C     $slvlouwgt    mult      prg2c         ihvar
     c                   endif
     C*    lbuwgt        mult      prg2c         ihvar
     C                   endif
     C     exwgt         add       hivar         hirng
     c                   if        nxtscr = '17'
     c                             and WLUserChoice = *on
     C     $slgwouwgt    add       ihvar         ihrng
     c                   else
     C     $slvlouwgt    add       ihvar         ihrng
     c                   endif
     *
     C                   if        KiloLbs = 'P'
     C                   Eval      *in31 = *on
     C                   else
     C                   Eval      *in31 = *off
     C                   endif
     *
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGETI   Get item description and pack description.
     *
     C     zzgeti        begsr
     *
      * add dri to get data from itemfld
      /free
        exsr clr$item;

        $itWhse = w1whse;
        $ititem = lbitem;

        $dricommand = '*ITEM';
        $drisubcmd  = '%GETALL';
        $drisys2upd = 'D';
        chk4err = *on;
        zmflag  = *off;
        exsr zzzdricop;
        if error = *on;
          $ifucicde = ' ';
          $ifrcvmth = ' ';
          $ifsltmth = ' ';
          ittype = *blanks;
          itdesc = *blanks;
          itpdsc = *blanks;
          $ittype = *blanks;
          $itdesc = *blanks;
          $itpdsc = *blanks;
        endif;
      /end-free
     *
     C                   eval      itmdsc = *blanks
     C                   eval      $iitem = $ititem
     C                   eval      $idesc = $itdesc
     C                   eval      $ipdsc = $itpdsc
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   eval      itmdsc = $istr
     C                   eval      woitem = itmdsc
     *
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define flags
     *
     C                   eval      forevr = *off
     C                   eval      found = *off
     C                   eval      first = *off
     C                   eval      first2 = *off
     C                   eval      first6 = *off
     C                   eval      first6a = *off
     C                   eval      first18 = *off
     C                   eval      first19 = *off
     C                   eval      WLUserChoice = *off
     *
     *
     *  Define misc variables
     *
     C                   eval      ttllic = 0
     C                   eval      traxYN = 'N'
     *
     *  Define keys
     *
     *
     *     ITEMMSC file -
     *
     C     imkey         klist
     C                   kfld                    w1whse
     C                   kfld                    $slvloitem
     *     LICENSE file - Partial
     C     likey         klist
     C                   kfld                    kywhse
     C                   kfld                    kylcns
     *
     *
     *     PIRITEM file.
     *
     C     keyit         klist
     C                   kfld                    w1whse
     C                   kfld                    $slvloitem
     *
     *     ORDERH  file
     *
     C     orkey         klist
     C                   kfld                    w1whse
     C                   kfld                    lbord
     *
     *     OPTIONS file
     *
     C     opkey         klist
     C                   kfld                    w1whse
     C                   kfld                    ocode
     *
     C     opkeys        klist
     C                   kfld                    wkwhse
     C                   kfld                    wkcode
     *
     *  Define partial key for RTEHED file.
     *
     C     keyrh         klist
     C                   kfld                    kywhse
     C                   kfld                    $krtid
     *
     *  Define key for ORDH file.
     *
     C     keyoh         klist
     C                   kfld                    $kwhse
     C                   kfld                    $krtid
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    $kwhse
     C                   kfld                    $ktype
     C                   kfld                    kyrtpo
     *
     *
     *
     *  Define key for UPC5 file.
     *
     C     upcky         klist
     C                   kfld                    w1whse
     C                   kfld                    $slvloitem
     C                   kfld                    lbutyp
     C                   kfld                    lbucod
     *
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     **
     *
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr

     * Get User information.

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

     C                   if        $rtn = '*ERROR'
     C                   exsr      scr03i
     C                   goto      endinz2
     C                   endif

     C                   eval      w1whse = $whse
     **
     **  Get Slot Sequence with new Option and possible soft coding
     **
     c                   eval      gpscmd = '*ISSOFT'
     c                   monitor
     c                   call      'GETPSEQO'
     c                   parm                    gpscmd            8
     c                   parm                    $pwhse
     c                   parm      ' '           gpswhdp           5
     c                   parm      ' '           gpsdisp          12
     c                   parm      ' '           gpsSeqcd          1
     c                   parm      0             gpsSeq            5 0
     c                   parm      ' '           usrDFPICK         1
     c                   on-error
     c                   eval      usrDFPICK = 'N'
     c                   endmon

     * Fill r#header ds

     C     onagain       tag
     C                   eval      $hdrcommand = 'signonrf'
     C                   eval      $hdrfuncid  = 6
     C                   move      #jobn         #job#
     C                   eval      $hdrserial# = #job#
     C                   eval      $hdrempl#   = $emp#
     C                   time                    curtime
     C                   eval      $hdrtimestamp = %char(curtime)
     C                   eval      $glofuncpgm = 'VOSELECT'
     C                   eval      $glousercode = #user
     C                   eval      $glowhse = $whse
     C                   eval      $glodept = *blanks
     C                   eval      $hdripaddr = #job
     C                   eval      $hdrportl = 0
     C                   eval      $hdrportc = 0
     C                   eval      $hdrjobname = #job
     C                   move      #jobn         $hdrjobnumber
     C*                  eval      $hdrjobnumber = #jobn
     C                   eval      $hdrjobuser = #user
     C                   eval      $slsritman# = #job
     C                   eval      $slsriuser = #user
     c                   if        client = kohl
     c                             or client = swt
     c                   eval      opeqpj = 'Y'
     c                   eval      opeqpt = 'PJACK '
     c                   endif
     c                   if        opeqpj = 'Y'
     c                   eval      $slsriopeqpj = '1'
     c                   eval      $slsriopeqpt = opeqpt
     c                   endif
     C                   eval      $pheader = $header
     C                   eval      $pfields = $slsignrfin
     C                   exsr      writelog
     C                   call      'VOSELECT'
     C                   parm      '*none'       $pdqlib
     C                   parm      '*none'       $pdqnameout
     C                   parm      '*none'       $pdqkey
     C                   parm                    $pheader
     C                   parm                    $pfields
     C                   parm                    $prtnfields
     C                   eval      $slsignrfout = $prtnfields
     c                   if        $slsroerrnum = 17
     c                             or $slsroerrnum = 54
     c                   CALL      'EQ410CL'
     C                   goto      onagain
     c                   endif
     C                   if        $slsroerrnum <> 0
     C                   exsr      scr03i
     C                   goto      endinz2
     C                   endif

     C                   eval      trndte = *zeros
     C                   eval      trntim = *zeros
     C                   eval      usestr = '*NO '
     C                   exsr      zzoptn

     C                   exsr      scr01i

     C     endinz2       endsr
     *
     *
     *----------------------------------------------------------------
     *
     *  ZZNXT    Update and get next screen
     *
     C     zznxt         begsr
     *
     C                   select
     C                   when         *inkf and umFlexPickFlag = 'P2W'
     C                   eval      error = *off
     *  will be calling pt132 passing the same parms as we do in
     * M11400u which is used by gui, to change the pick qty
     C                   eval      error = *off
     c                   eval      uktrn# = lbtrn#
     c                   eval      $pcmd = '*UPDSLBL'
     C                   eval      $ptype = '*BATCH'
     C                   eval      $prtn = 'TEXT'
     C                   eval      $plbl  = lblbl#
     C                   eval      $pqpck = w6cnt1
     c                   eval      ukwhse = w1whse
      *
     C                   eval      $puky = dsukey
     C                   call      'PT132'
     C                   parm                    $parms
     c                   exsr      scr01i
     *
     C                   when         *inkf and umFlexPickFlag = ' '
     *  will be calling pt132 passing the same parms as we do in
     * M11400u which is used by gui, to change the pick qty
     C                   eval      error = *off
     c                   eval      uktrn# = lbtrn#
     c                   eval      $pcmd = '*UPDSLBL'
     C                   eval      $ptype = '*BATCH'
     C                   eval      $prtn = 'TEXT'
     C                   eval      $plbl  = lblbl#
     C                   eval      $pqpck = w6cnt1
     c                   eval      ukwhse = w1whse
      *
     C                   eval      $puky = dsukey
     C                   call      'PT132'
     C                   parm                    $parms
     c                   exsr      scr01i
     c
     *
     *
     C                   other
     *   Display SC2 to scan next label.
     c                   select
     C                   when      nxtscr = '02A'
     C                   exsr      scr02ai
     C                   when      nxtscr = '02B'
     C                   exsr      scr02bi
     C                   when      nxtscr = '02C'
     C                   exsr      scr02ci
     C                   when      nxtscr = '02D'
     C                   exsr      scr02di
     c                   other
     C                   exsr      scr01i
     C                   endsl
     C                   endsl
     *
     *
     C     endnxt        endsr
     *----------------------------------------------------------------
     *
     *  ZZOPTN   Get options
     *
     C     zzoptn        begsr
     *
     *  GetVoiceOpt  Get voice options.
     *
     C                   Eval      ocode  = '*VOICE'
     C     OpKey         Chain     Options
     C                   if        %found
     C                   eval      opvdta = opdata
     C                   else
     C                   eval      opincp = 'Y'
     C                   eval      opcrtr = 'N'
     C                   eval      opuplv = 'N'
     C                   eval      opvmrg = 'N'
     C                   eval      opoutf = 'N'
     C                   eval      opfrpl = 'N'
     C                   eval      opvmlt = 'N'
     C                   eval      opvspn = 'N'
     C                   eval      opvspz = 'N'
     C                   eval      opvslw = 'N'
     C                   eval      opvcep = 'N'
     C                   eval      opvssn = 'N'
     C                   eval      opvcpz = 'N'
     C                   eval      opestp = 'N'
     C                   endif
     *
     *   Get General Picking options
     C                   eval      ocode = '*GENPICK'
     *
     C     opkey         chain     options                            79
     C                   if        *in79
     C                   eval      oprfuc = 'N'
     C                   eval      oprflc = 'N'
     C                   eval      oprfsl = 'Y'
     C                   else
     C                   eval      opdat2 = opdata
     C                   endif
     C                   if        oprfcs = 'Y'
     c                   eval      *in49 = *off
     C                   else
     c                   eval      *in49 = *on
     c                   endif
     C                   if        oprfpm = '2'
     c                   eval      *in62 = *on
     C                   else
     c                   eval      *in62 = *off
     c                   endif
     *
     *
     *   Get catch wt options.
     C                   eval      wkcode = '*SYSTEM '
     C                   eval      wkwhse = 0
     *
     C     opkeys        chain     options                            79
     C                   if        *in79
     C                   eval      opcapc = 'Y'
     C                   eval      opwrnc = 'N'
     C                   eval      oprg1c = 0
     C                   eval      oprg2c = 0
     C                   eval      opicw  = 'N'
     C                   else
     C                   eval      opdat3 = opdata
     C                   endif
     C*
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     *  Need to get the pick count and weight from the uciinfo file
     *  in case a user was able to scan to add or delete but program
     *  had an abnormal end before the label record got updated.
     *  Otherwise you could have uciinfo records scanned to a tran/label
     *  that don't match with the totals in label record. And they would
     *  have no way to put them back in sync.
     *  By doing this, and forcing the user to tell  us when they are done
     *  the label file will match the uciinfo file.

      /free
        savever# = $uiver#;
        clear $uciinfo;
        clear $uciinfo2;
        $uiver# = savever#;

        // setup some data to pass to driuciinfo
        $uisellbl# = lblbl#;

        $uiwhse = lbwhse;
        $uiitem = lbitem;

        $dridata = $uciinfo;
        $dridata2 = $uciinfo2;
        $dricommand = '*UCIINFO';
        $drisubcmd  = '*CNT4LBL';
        exsr zzzdricop;
        //driUCICalled = *on;
        //driuciinfo('%CNT4LBL': $pprogram: $drireturn: $drimessage:
                    //$dridata: $dridata2);
        // message will have the count
        ucicnt  = %dec($drimessage:5:0);
      /end-free


     *  which screen
      /free
        select;
          when umFlexPickFlag = 'P2W';
            savever# = $uiver#;
            clear $uciinfo;
            clear $uciinfo2;
            $uiver# = savever#;

            // setup some data to pass to driuciinfo
            $uiwhse = lbwhse;
            $uisellbl# = lblbl#;
            $uiseltrn# = lbtrn#;

740aA       w6wgt1 = 0;
740aA       first6 = *off;
            $dridata = $uciinfo;
            $dridata2 = $uciinfo2;
            $dricommand = '*UCIINFO';
            $drisubcmd  = '*WGT4LBL';
            exsr zzzdricop;
            if $drireturn = '*LBLWGT';
              lblwgt = %dec($drimessage:7:0) * .01;
            endif;
            exsr scr02bi;
          when umFlexPickFlag = 'PAQ';
          other;
740aA       w6cnt1 = 0;
740aA       first6 = *off;
            exsr scr02ai;
          endsl;
      /end-free
     *
     C     endup1        endsr
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------*********
     *
     *  ZZUPD2a  Update for screen 2a.
     *
     C     zzupd2a       begsr
     C                   eval      error = *off
     C                   eval      first6 = *on
     *  Scan to pallet
     C                   add       1             w6cnt1
     *  Catch weight item
     C                   exsr      zznxt
     *
     *
     C     endup2a       endsr
     *----------------------------------------------------------------*********
     *
     *  ZZUPD2b  Update for screen 2b.
     *
     C     zzupd2b       begsr
     C                   eval      error = *off
     C                   eval      first6 = *on
     *  Scan to pallet
     C                   add       1             w6cnt1
     C                   add       $BCPNTLB      w6wgt1
     C                   exsr      zznxt
     *
     C     endup2b       endsr
     *----------------------------------------------------------------*********
     *
     *  ZZUPD2c  Update for screen 2c.
     *
     C     zzupd2c       begsr
     C                   eval      error = *off
     C                   eval      first6 = *on
     *  Scan to pallet
     C                   sub       1             w6cnt1
     C                   sub       $BCPNTLB      w6wgt1
     C                   exsr      zznxt
     *
     C     endup2c       endsr
     *----------------------------------------------------------------*********
     *
     *  ZZUPD2d  Update for screen 2d.
     *
     C     zzupd2d       begsr
     C                   eval      error = *off
     C                   eval      first6 = *on
     *  Scan to pallet
     C                   sub       1             w6cnt1
     C                   sub       $BCPNTLB      w6wgt1
     C                   exsr      zznxt
     *
     C     endup2d       endsr
     *----------------------------------------------------------------*********
     *----------------------------------------------------------------*********
     *
     *  ZZUPD03  Update for screen 03
     *
     C     zzupd03       begsr
     C                   eval      error  = *off
     c     endup03       endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD04  Update for screen 04.
     *
     C     zzupd04       begsr
     C                   eval      error = *off
     c
     *
     *   Display screen to scan label.
     *
      /free
        select;
          when cdone = 'Y';
            select;
              when wherefrom = '02A'
                or wherefrom = '02B'
                or wherefrom = '02C'
                or wherefrom = '02D';
                *inkf = *on;
                cmdtkn = *on;
                exsr zznxt;
            endsl;
          other;
            nxtscr = wherefrom;
        endsl;
      /end-free
     *
     C     endup04       endsr
     *----------------------------------------------------------------
     *
     *  WriteLog    Write log record
     *
     C     writelog      begsr

     C                   exsr      getcurrstamp

     C                   eval      SlgTyp = 'Rcv'
     C                   eval      SlgBuf = %trim($hdrcommand) + '/'
     C                                    + $pfields

     C                   eval      slgts     = currstamploc
     C                   eval      slgucs    = currstampuc
     C                   eval      slguser   = #user
     C                   eval      slgjob    = #job
     C                   eval      slgjobnbr = #jobn

     C                   eval      slgsk2 = 0
     C                   eval      SlgIP  = #job
     C                   eval      SlgPortL = 0
     C                   eval      SlgPortC = 0
     C                   select
     C                   when      slgtyp = 'Sel'
     C                             or slgtyp = 'Opn'
     C                             or slgtyp = 'Rcv'
     C                   eval      slgid  = ' '
     C                   other
     C******             eval      slgid  = tmansnum
     C                   endsl
     C                   write     slgrec
     C
     C                   endsr

     *----------------------------------------------------------------
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

     C     getcurrstamp  begsr

     C                   callp     getmicrotime(currstampuc:currstampsys)
     C     currstampsys  adddur    bfcoffset:*H  currstamploc

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZTRAXLBL  Convert TRAX label
     C     zztraxlbl     begsr
     C                   move      w1whse        $pwhseb
     C                   call      @cvtbarsel
     C                   parm                    $pwhseb           3
     C                   parm                    $pbarcode        15
     C                   parm                    $plbl#            7 0
     C                   parm                    $prtid            5
     C                   parm                    $punq#            5
     C                   parm                    $preturn          8
     C                   parm                    $perrmsg         60
     C                   if        $preturn = '*OK'
     C                   else
     C*                  eval      error = *on
     C*                  eval      *in22 = *on
     C*                  movel     desc(2)       errmsg
     C*                  exsr      zm0110
     C                   endif
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
     C                   eval      $uiver# = savever#
     C                   eval      $uiaddemp = $emp#
     C                   eval      $uiaddusr = #user
     C                   eval      $uiaddpgm  = #prog
     C                   eval      $uiaddjob  = #jobn
     C                   eval      $uichgemp = $emp#
     C                   eval      $uichgusr = #user
     C                   eval      $uichgpgm  = #prog
     C                   eval      $uichgjob  = #job
     C                   eval      $uichgnbr = #jobn
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
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $dridata = $uciinfo
     C                   eval      $dridata2 = $uciinfo2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
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
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $uciinfo = $dridata
     C                   eval      $uciinfo2 = $dridata2
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr
     *----------------------------------------------------------------
     *
     *  ZZCNVWGT  Setup converted weight field.
     *
     C     zzcnvwgt      begsr
     *
     *
     * If item options is setup as kgs and user enters kgs no conversion
     * If item options is setup as kgs and user enters lbs need conversion
     * If item options is setup as lbs and user enters lbs no conversion
     * If item options is setup as lbs and user enters kgs need conversion
      /free
        select;
          when Begkilolbs = 'K';
            if KiloLbs = 'K';
              eval wwgt = wgt;
            else;
              eval(h) wwgt = wgt / kgs2lbs;
            endif;
          other;
            if KiloLbs = 'K';
              eval(h) wwgt = wgt * kgs2lbs;
            else;
              eval wwgt = wgt;
            endif;
        endsl;
      /end-free

     C                   endsr
     *----------------------------------------------------------------
     *
     *  GetUOMDesc  Get the unit of measure description
     *
     C     getuomdesc    begsr
      /free
        w6uom = ' ';
        chain (lbucod) unmesr;
        if %found(unmesr);
          w6uom = umshrt;
        endif;
      /end-free
     C                   endsr
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Trans started, can not cancel
Label rec not for transaction
Wrong slot scanned
Trans not found
No zone found
Trans not open
Wrong upc scanned
item dept not allowed
Not enough avail Inv.
Invalid qty
Invalid Check Digit
Slot can not be empty
Weights already entered.
Wrong Label.
Bulk not allowed.
**  EM - Error message
Not allowed Export at this time.
Route already exported to Host.
