      *===================================================================
      *
      *  Name .......... C#ZONEH
      *  Description ... Dakota realtime interface layout for *ZONEH
      *  Created by .... Dave Sommerville
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   09/13/11  DAS  6.40
      *     - Created.
      *
640aA *   04/12/12  DAS  6.40a
      *     - Changed size of zhcomp to 1 instead of 30
      *     - Changed size of opaisl to 1 instead of 3
      *
650aA *   05/06/14  DAS  6.50a
      *     - Changed version to 2
      *     - Added $oplbl
      *
650bA *   02/19/15  DAS  6.50b
      *     - Changed version to 3
      *     - Added $zhfrmtruk, $zhfrmzone.
      *
700aA *   06/02/15  LMC  7.00a
      *     - Changed version to 4
      *     - Added $opmcub, oppmtz, opdddo.
      *
710aA *   06/05/17  LMC  7.10a
      *     - Changed version to 5
      *     - Added $opnbps.
      *
720aA *   06/03/18  DAS  7.20a
      *     - Changed version to 6
      *     - Added $opfwgt, $opfplt, $opbseq
      *
720bA *   09/01/18  DAS  7.20b
      *     - Changed version to 7
      *     - Added $opsstp, $opfplt, $opbseq
730aA *   03/25/19  LMC  7.30a
      *     - $optecb was  defined as 5.0 s/b 5.2
740aA *   05/27/20  DAS  7.40a
      *     - Changed version to 8
      *     - $ozrfzp added
740bA *   08/20/20  KDE  7.40b
      *     - Changed version to 9
      *     - $opicub, $oppisplt, $opmscb, $opmsvh, $opmsvm, $opmsvl,
      *       $opoacb added
      *     - Created $zoneh2 data structure
750 A *   02/18/21  KDE  7.50
      *     - Changed version to 10
      *     - add $oppstuff
750aA *   03/19/21  KDE  7.50a
      *     - Changed version to 11
      *     - add $oppmsp, $oppmstp, $oppmord
750bA *   07/19/21  KDE  7.50b
      *     - Changed version to 12
      *     - add $opoddeven
760aA *   03/28/22  DAS  7.60a
      *     - Changed version to 13
      *     - add $opselm, $oprplto, $oppck1, $opblk1
      *===================================================================
      *
      * Notes
      *
      *   - When adding new fields ...
      *
      *       1) Increment the version number
      *       2) Always add new fields to the end of the layout.
      *       3) Create corresponding indicator field.
      *       4) Create corresponding error indicator field.
      *
416 A *   - Each field should have a corresponding indicator field. This
416 A *     field is used to indicate if the field is being used (sent).
416 A *     The only exceptions are the warehouse and item fields, which
416 A *     must be sent every time. In some cases a single indicator can
      *     be used for a group of fields.
      *
416 A *   - Most fields should have a corresponding error flag field. This
416 A *     field is used to indicate if the field caused an error or a
416 A *     warning. Values are 0 = No error/warning, 1 = Error and
416 A *     2 = Warning.
      *
      *===================================================================

     D $zoneh          ds

760aMD  $zhver#                       2s 0 Inz(13)
     D  $zhwhse                       3  0
     D   $zhwhsee                     1
     D   $zhwhseu                      n
     D  $zhtruk                      10
     D   $zhtruke                     1
     D   $zhtruku                      n
     D  $zhzone                       6
     D   $zhzonee                     1
     D   $zhzoneu                      n
     D  $zhdesc                      30
     D   $zhdesce                     1
     D   $zhdescu                      n
640aDD**$zhcomp                      30
640aMD  $zhcomp                       1
     D   $zhcompe                     1
     D   $zhcompu                      n
     D  $zhpzon                       6
     D   $zhpzone                     1
     D   $zhpzonu                      n
     D  $opfpal                       1  0
     D   $opfpale                     1
     D   $opfpalu                      n
     D  $opfcub                       5  2
     D   $opfcube                     1
     D   $opfcubu                      n
     D  $opfstp                       2  0
     D   $opfstpe                     1
     D   $opfstpu                      n
     D  $opbpck                       3  0
     D   $opbpcke                     1
     D   $opbpcku                      n
     D  $oppbld                       1
     D   $oppblde                     1
     D   $oppbldu                      n
     D  $opnwpl                       1
     D   $opnwple                     1
     D   $opnwplu                      n
     D  $opford                       2  0
     D   $opforde                     1
     D   $opfordu                      n
     D  $opptyp                       1
     D   $opptype                     1
     D   $opptypu                      n
730aDD* $optecb                       5  0
730aMD  $optecb                       5  2
     D   $optecbe                     1
     D   $optecbu                      n
     D  $opticb                       5  2
     D   $opticbe                     1
     D   $opticbu                      n
     D  $optord                       2  0
     D   $optorde                     1
     D   $optordu                      n
     D  $optpcs                       3  0
     D   $optpcse                     1
     D   $optpcsu                      n
     D  $opstop                       1
     D   $opstope                     1
     D   $opstopu                      n
     D  $oppkup                       1
     D   $oppkupe                     1
     D   $oppkupu                      n
     D  $opspal                       1
     D   $opspale                     1
     D   $opspalu                      n
     D  $oppitm                       4  0
     D   $oppitme                     1
     D   $oppitmu                      n
     D  $opclvl                       3  0
     D   $opclvle                     1
     D   $opclvlu                      n
     D  $opcwra                       1
     D   $opcwrae                     1
     D   $opcwrau                      n
     D  $opcwrb                       1
     D   $opcwrbe                     1
     D   $opcwrbu                      n
     D  $opuwra                       1
     D   $opuwrae                     1
     D   $opuwrau                      n
     D  $opuwrb                       1
     D   $opuwrbe                     1
     D   $opuwrbu                      n
     D  $operr                        2  0
     D   $operre                      1
     D   $operru                       n
     D  $opcwgt                       2  0
     D   $opcwgte                     1
     D   $opcwgtu                      n
640aDD**$opaisl                       3
640aMD  $opaisl                       1
     D   $opaisle                     1
     D   $opaislu                      n
     D  $optaxr                       1
     D   $optaxre                     1
     D   $optaxru                      n
     D  $opchkr                       1
     D   $opchkre                     1
     D   $opchkru                      n
     D  $oplb1                        1
     D   $oplb1e                      1
     D   $oplb1u                       n
     D  $opcu1                        1
     D   $opcu1e                      1
     D   $opcu1u                       n
     D  $oplp1                       10
     D   $oplp1e                      1
     D   $oplp1u                       n
     D  $opdv1                       10
     D   $opdv1e                      1
     D   $opdv1u                       n
     D  $opfm1                       10
     D   $opfm1e                      1
     D   $opfm1u                       n
     D  $oplb2                        1
     D   $oplb2e                      1
     D   $oplb2u                       n
     D  $opcu2                        1
     D   $opcu2e                      1
     D   $opcu2u                       n
     D  $oplp2                       10
     D   $oplp2e                      1
     D   $oplp2u                       n
     D  $opdv2                       10
     D   $opdv2e                      1
     D   $opdv2u                       n
     D  $opfm2                       10
     D   $opfm2e                      1
     D   $opfm2u                       n
     D  $oplb3                        1
     D   $oplb3e                      1
     D   $oplb3u                       n
     D  $opcu3                        1
     D   $opcu3e                      1
     D   $opcu3u                       n
     D  $oplp3                       10
     D   $oplp3e                      1
     D   $oplp3u                       n
     D  $opdv3                       10
     D   $opdv3e                      1
     D   $opdv3u                       n
     D  $opfm3                       10
     D   $opfm3e                      1
     D   $opfm3u                       n
     D  $oplb4                        1
     D   $oplb4e                      1
     D   $oplb4u                       n
     D  $opcu4                        1
     D   $opcu4e                      1
     D   $opcu4u                       n
     D  $oplp4                       10
     D   $oplp4e                      1
     D   $oplp4u                       n
     D  $opdv4                       10
     D   $opdv4e                      1
     D   $opdv4u                       n
     D  $opfm4                       10
     D   $opfm4e                      1
     D   $opfm4u                       n
     D  $oplb5                        1
     D   $oplb5e                      1
     D   $oplb5u                       n
     D  $opcu5                        1
     D   $opcu5e                      1
     D   $opcu5u                       n
     D  $oplp5                       10
     D   $oplp5e                      1
     D   $oplp5u                       n
     D  $opdv5                       10
     D   $opdv5e                      1
     D   $opdv5u                       n
     D  $opfm5                       10
     D   $opfm5e                      1
     D   $opfm5u                       n
     D  $oplb6                        1
     D   $oplb6e                      1
     D   $oplb6u                       n
     D  $opcu6                        1
     D   $opcu6e                      1
     D   $opcu6u                       n
     D  $oplp6                       10
     D   $oplp6e                      1
     D   $oplp6u                       n
     D  $opdv6                       10
     D   $opdv6e                      1
     D   $opdv6u                       n
     D  $opfm6                       10
     D   $opfm6e                      1
     D   $opfm6u                       n
     D  $oplb7                        1
     D   $oplb7e                      1
     D   $oplb7u                       n

650aA * Fields added for version 2.
     D  $oplbl                        1
     D   $oplble                      1
     D   $oplblu                       n

650bA * Fields added for version 3.

     D* $zhfrmtrk - From Truck for copy

     D  $zhfrmtruk                   10
     D   $zhfrmtruke                  1
     D   $zhfrmtruku                   n

     D* $zhfrmzone - From Zone for copy

     D  $zhfrmzone                    6
     D   $zhfrmzonee                  1
     D   $zhfrmzoneu                   n

700aA * Fields added for version 4.
     D* $opmcub   - minimum cube per pallet
     D  $opmcub                       5  2
     D   $opmcube                     1
     D   $opmcubu                      n

     D* $oppmtz   - Allow multi-truck assignments(USF only)
     D  $oppmtz                       1
     D   $oppmtze                     1
     D   $oppmtzu                      n

     D* $opdddo   - Dock door drop off order(USF only)
     D  $opdddo                       1
     D   $opdddoe                     1
     D   $opdddou                      n

710aA * Fields added for version 5.
     D* $opnbps   - Number of Pallet Sections.
     D  $opnbps                       1  0
     D   $opnbpse                     1
     D   $opnbpsu                      n

720aA * Fields added for version 6.
     D* $opfwgt   - Maximum pallet weight
     D  $opfwgt                       4  0
     D   $opfwgte                     1
     D   $opfwgtu                      n

     D* $opfplt   - Pallet code
     D  $opfplt                       6
     D   $opfplte                     1
     D   $opfpltu                      n

     D* $opbseq   - Build Sequence
     D  $opbseq                       2  0
     D   $opbseqe                     1
     D   $opbsequ                      n

720bA * Fields added for version 7.
     D* $opsstp   - Maximum stops per section
     D  $opsstp                       2  0
     D   $opsstpe                     1
     D   $opsstpu                      n

740aAD* $ozrfzp   - RF Zone Pickup
     D  $ozrfzp                       1
     D   $ozrfzpe                     1
     D   $ozrfzpu                      n
740bA * Fields added for version 9.
     D* $opicub   - Ideal Cube
     D  $opicub                       5  2
     D   $opicube                     1
     D   $opicubu                      n
     D* $oppisplt - Prevent Item Split
     D  $oppisplt                     1
     D   $oppisplte                   1
     D   $oppispltu                    n
     D* $opmscb   - Allow merging with Stops cube < this value
     D  $opmscb                       2  0
     D   $opmscbe                     1
     D   $opmscbu                      n
     D* $opmsvh   - When merging above, stop can be highest pallet
     D  $opmsvh                       1
     D   $opmsvhe                     1
     D   $opmsvhu                      n


      *  Add to add second data structure

     D $zoneh2         ds

     D* $opmsvm   - When merging above, stop can be middle pallet
     D  $opmsvm                       1
     D   $opmsvme                     1
     D   $opmsvmu                      n
     D* $opmsvl   - When merging above, stop can be lowest pallet
     D  $opmsvl                       1
     D   $opmsvle                     1
     D   $opmsvlu                      n
     D* $opoacb   - When Overflow pallet, put on Truck when cube less than this
     D  $opoacb                       5  2
     D   $opoacbe                     1
     D   $opoacbu                      n
     D* $opzplt   - Zone Pallet Type
     D  $opzplt                       1
     D   $opzplte                     1
     D   $opzpltu                      n
     D* $opbplt   - Bulk Pallet Type
     D  $opbplt                       1
     D   $opbplte                     1
     D   $opbpltu                      n
     D* $oppstuff - Either split pallet when max cube (M) or stuff (S) empty
     D  $oppstuff                     1
     D   $oppstuffe                   1
     D   $oppstuffu                    n
     D* $oppmsp - Prevent manual merging of *SP pallets
     D  $oppmsp                       1
     D   $oppmspe                     1
     D   $oppmspu                      n
     D* $oppmstp - Prevent manual exceeding of max Stops
     D  $oppmstp                      1
     D   $oppmstpe                    1
     D   $oppmstpu                     n
     D* $oppmord - Prevent manual exceeding of max Orders
     D  $oppmord                      1
     D   $oppmorde                    1
     D   $oppmordu                     n
     D* $opoddeven - Odd/Even Area Assignment for Multi-Site Routes (US Foods)
     D  $opoddeven                    1
     D   $opoddevene                  1
     D   $opoddevenu                   n
760aA * Fields added for version 13
760aAD* $opselm - Selection Method 1=Single pass by loc, 2=Multi pass by stop
760aAD  $opselm                       1
760aAD   $opselme                     1
760aAD   $opselmu                      n
760aAD* $oprplto - Pallet label override
760aAD  $oprplto                      1
760aAD   $oprpltoe                    1
760aAD   $oprpltou                     n
760aAD* $oppck1 - Suppress desktop printing for Pick label
760aAD  $oppck1                       1
760aAD   $oppck1e                     1
760aAD   $oppck1u                      n
760aAD* $opblk1 - Suppress desktop printing for Bulk label
760aAD  $opblk1                       1
760aAD   $opblk1e                     1
760aAD   $opblk1u                      n

