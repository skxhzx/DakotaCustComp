      *===================================================================
      *
      *  Name .......... C#PIRHLDPO
      *  Description ... PIRHOLD PO detail data file info data structure
      *  Created by .... Lynn McMahon
      *===================================================================
      *
      * Revisions
      *
650aA *   07/09/14  LMC  6.50
      *     - Created.
700aA *   05/25/16  LMC  7.00a
      *     - Added Branded Item
700bA *   06/07/16  LMC  7.00b
      *     - Added CW Ovr fields
      *
      *===================================================================
      *   Type will be PODTL
      *   key field will be PO/POSEQ/ITEM
      *===================================================================

     *----------------------------------------------------------------
     * Begin C#PIRHLDPO  - File information data structure - PIRHOLD DTL
     *----------------------------------------------------------------

     D pirhldpods      ds
     D  oaovr                  1      1
     D  obovr                  2      2
     D  ocovr                  3      3
     D  odovr                  4      4
510e D  oeovr                  5      5
510e D  ofovr                  6      6
     D  ddcode                 7      7
     D  cwovr                  8      8
     D  ptiovr                 9      9
     D  dtchk                 10     10
     D  dtchk2                11     11
     D  dtchk3                12     12
     D  dtchk4                13     13
     D  qtchk                 14     14
     D  qtchk1                15     15
     D  wtchk                 16     16
     D  upchk                 17     17
     D  upchk2                18     18
     D  ptichk                19     19
SGCaAD  svckq1                20     24S 0 INZ(0)
     D  svdwgt                25     33S 2 INZ(0)
     D  svexdt                34     39S 0 INZ(0)
     D  svmfdt                40     45S 0 INZ(0)
650lAD  svpti                 46     49S 0 INZ(0)
     D  svupc                 50     99
     D  sdqrc1               100    104S 0 INZ(0)
     D  sdqrc2               105    109S 0 INZ(0)
     D  sdqrc3               110    114S 0 INZ(0)
     D  w1upcd               115    164
     d  w1qrc1               165    169S 0 INZ(0)
     d  w1qrc2               170    174S 0 INZ(0)
     d  w1qrc3               175    179S 0 INZ(0)
     D  w1plts               180    184s 0 INZ(0)
     d  w1exdt               185    190s 0 INZ(0)
     d  w1mfdt               191    196s 0 INZ(0)
     d  w1pti                197    200s 0 INZ(0)
     d  w1lotc               201    230
     d  w1brand              231    240
     d  w1dwgt               241    249s 2 INZ(0)
     D  w1fifo               250    255s 0 INZ(0)
     D  w1avg                256    256
     D  w1slot               257    268
     D  w1stat               269    270
     D  osscode              271    271
     D  ossprint             272    272
     D  w1um1                273    277
     D  w1um2                278    282
     D  w1um3                283    287
     D  lflag                288    288
     D  $dtosave             289    296s 0 inz(0)
     D  $rexpd               297    304s 0 inz(0)
     D  PSRcvReq             305    305
     D  psrusr               306    306
     D  directed             307    307
     D  wotie                308    311s 0 inz(0)
     D  wohi                 312    313s 0 inz(0)
     D  xdockflg             314    314
     D  kilolbs              315    315
     D* availtouse           315    339
     D* availtouse           340    354
     D  expd                 355    362S 0 INZ(0)
     d  w1twgt               363    371s 2 INZ(0)
     d  avgwt1               372    378s 2 INZ(0)
     d  avgwt2               379    385s 2 INZ(0)
     d  avgwt3               386    392s 2 INZ(0)
     D  woindt               393    400s 0 INZ(0)
     D  w1upc                401    420
     D  $ldecvalue           421    435
     D  mexpd                436    443s 0 INZ(0)
     D  mfgdte               444    451s 0 INZ(0)
     D  $plpn                452    501
     D  nolcns               502    516
     D  savetrn              517    523s 0 INZ(0)
     D  $pgtin               524    537
     D  $pbcProdd            538    543s 0 INZ(0)
     D  $pbclot              544    563
     D  $llott               564    564
     D  $llict               565    565
     D  woitem               566    630
     D  wositm               631    695
     D  wodsc1               696    735
     D  wodsc2               736    775
     D  wolbl                776    788
     D  wolbls               789    801
     D  wopdsc               802    816
     D  ossplates            817    820s 0 inz(0)
     D  ossdev               821    830
     D  $pgslcns             831    845
     D  $lord                846    852s 0 inz(0)
     D  $pmfgdt              853    858s 0 inz(0)
     D  reload               859    859
     D  savew1mfdt           860    865s 0 inz(0)
     D  savew1exdt           866    871s 0 inz(0)
     D  savelotc             872    891
     D  moretoscan           892    892
700aAD  BrandedItm           893    907
700bAD  prg1c                908    911s 3 inz(0)
700bAD  prg2c                912    915s 3 inz(0)
700bAD  exwgt                916    924s 2 inz(0)
700bAD  lwrng                925    933s 2 inz(0)
700bAD  hirng                934    942s 2 inz(0)

     *** End C#FILE15DS ***
