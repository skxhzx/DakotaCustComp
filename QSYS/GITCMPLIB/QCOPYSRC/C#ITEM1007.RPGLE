      *===================================================================
      *
      *  Name .......... C#ITEM
      *  Description ... Dakota realtime interface layout for *ITEM
      *  Created by .... Dave Sommerville
      *
      *===================================================================
      *
      * Revisions
      *
416 A *   09/28/01  DAS  4.16
      *     - Created.
      *
416aA *   10/11/01  DAS  4.16a
      *     - Added error flag fields.
      *
416aA *   04/08/03  DAS  4.16b
      *     - Set version to 2.
      *     - Added ITEMMSC fields.
      *
417 A *   06/11/03  DAS  4.17
      *     - Set version to 3.
      *     - Split into two data structures because we exceeded the
      *       512-character data parameter limit.
      *     - All fields added in version 2 were moved into new DS.
      *
500 A *   11/03/05  DAS  5.00
      *     - Set version to 4.
      *     - Added ITEMFLD IFCAT field.
      *
510 A *   02/14/07  TLJ  5.10
      *     - Set version to 5.
      *     - Added KITCOMP fields: KCQTY1,KCQTY2,KCQTY3
      *
520aA *   03/10/09  DAS  5.20a
      *     - Set version to 6.
      *     - Added ITEMFLD IFCASEOVF field.
      *
610aA *   08/17/10  DAS  6.10a
      *     - Set version to 7.
      *     - Added ITEMFLD IFODRSLOT (on-demand repack slot) field.
      *
640aA *   09/18/12  LMC  6.40a
      *     - Set version to 8.
      *     - Added ITEMFLD IFUCICDE,IFRCVMTH,IFSLTMTH,IFBRDFLG.
      *
650aA *   02/20/13  KDE  6.50a
      *     - Set version to 9.
      *     - Changed KCQTY1 from length of 3 to length of 5
      *     - Added KCDISP to KITCOMP.  Move On-Demand Slot to Kitcomp
      *     - Added KITITEM fields: KIRPTP,KIDISP,KIQTY1,
      *             KIQTY2,KIQTY3
      *
      *===================================================================
      *
      * Notes
      *
416 A *   - When adding new fields ...
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

     D $Item           ds

640aMD  $itVer#                       2s 0 Inz(8)
     D  $itwhse                       3  0
     D   $itwhsee                     1
     D  $ititem                      15
     D   $ititeme                     1
     D  $itmitem                     15
     D   $itmiteme                    1
     D   $itmitemu                     n
     D  $itcitem                     15
     D   $itciteme                    1
     D   $itcitemu                     n

      *  PirItem file fields
     D  $ittype                       1
     D   $ittypee                     1
     D   $ittypeu                      n
     D  $itdesc                      30
     D   $itdesce                     1
     D   $itdescu                      n
     D  $itstyp                       1
     D   $itstype                     1
     D   $itstypu                      n
     D  $itwhdp                       5
     D   $itwhdpe                     1
     D   $itwhdpu                      n
     D  $itdesg                       5
     D   $itdesge                     1
     D   $itdesgu                      n
     D  $itactv                       2
     D   $itactve                     1
     D   $itactvu                      n
     D  $itupc                       15
     D   $itupce                      1
     D   $itupcu                       n
     D  $itbld                        2
     D   $itblde                      1
     D   $itbldu                       n
     D  $itven#                      10  0
     D   $itven#e                     1
     D   $itven#u                      n
     D  $itvit#                      15
     D   $itvit#e                     1
     D   $itvit#u                      n
     D  $itpdsc                      15
     D   $itpdsce                     1
     D   $itpdscu                      n
     D  $itum1                        2
     D   $itum1e                      1
     D   $itum1u                       n
     D  $itum2                        2
     D   $itum2e                      1
     D   $itum2u                       n
     D  $itumq2                       3  0
     D   $itumq2e                     1
     D   $itumq2u                      n
     D  $itflg1                       1
     D   $itflg1e                     1
     D   $itflg1u                      n
     D  $itum3                        2
     D   $itum3e                      1
     D   $itum3u                       n
     D  $itumq3                       3  0
     D   $itumq3e                     1
     D   $itumq3u                      n
     D  $itflg2                       1
     D   $itflg2e                     1
     D   $itflg2u                      n
     D  $itulen                       5  2
     D   $itulene                     1
     D   $itulenu                      n
     D  $ituwdt                       5  2
     D   $ituwdte                     1
     D   $ituwdtu                      n
     D  $ituhgt                       5  2
     D   $ituhgte                     1
     D   $ituhgtu                      n
     D  $itcube                       7  3
     D   $itcubee                     1
     D   $itcubeu                      n
     D  $itswgt                       7  2
     D   $itswgte                     1
     D   $itswgtu                      n
     D  $itcwgt                       1
     D   $itcwgte                     1
     D   $itcwgtu                      n
     D  $itreor                       5  0
     D   $itreore                     1
     D   $itreoru                      n
     D  $itrepl                       5  0
     D   $itreple                     1
     D   $itreplu                      n
     D  $itrcvd                       8  0
     D   $itrcvde                     1
     D   $itrcvdu                      n
     D  $itflgd                       1
     D   $itflgde                     1
     D   $itflgdu                      n
     D  $itflgb                       1
     D   $itflgbe                     1
     D   $itflgbu                      n
     D  $itslif                       3  0
     D   $itslife                     1
     D   $itslifu                      n
     D  $itnday                       3  0
     D   $itndaye                     1
     D   $itndayu                      n

      * ItemDef file fields
     D  $idsdef                       2    dim(5)
     D   $idsdefe                     1    dim(5)
     D   $idsdefu                      n   dim(5)
     D  $idtie                        4s 0 dim(5)
     D   $idtiee                      1    dim(5)
     D  $idhigh                       2s 0 dim(5)
     D   $idhighe                     1    dim(5)
     D  $idum                         1    dim(5)
     D   $idume                       1    dim(5)
     D  $idpref                       1    dim(5)
     D   $idprefe                     1    dim(5)

      * ItemDsc file fields
     D  $ixdsc1                      40
     D   $ixdsc1e                     1
     D   $ixdsc1u                      n
     D  $ixdsc2                      40
     D   $ixdsc2e                     1
     D   $ixdsc2u                      n

      * ItemMsc file fields
     D  $imtie                        4s 0
     D   $imtiee                      1
     D   $imtieu                       n
     D  $imhigh                       2s 0
     D   $imhighe                     1
     D   $imhighu                      n
     D  $immflg                       1
     D   $immflge                     1
     D   $immflgu                      n
     D  $imdday                       3  0
     D   $imddaye                     1
     D   $imddayu                      n
     D  $imuday                       3  0
     D   $imudaye                     1
     D   $imudayu                      n
     D  $immday                       3  0
     D   $immdaye                     1
     D   $immdayu                      n
     D  $imwrnc                       1
     D   $imwrnce                     1
     D   $imwrncu                      n
     D  $imrg1c                       3  1
     D   $imrg1ce                     1
     D   $imrg1cu                      n
     D  $imrg2c                       3  1
     D   $imrg2ce                     1
     D   $imrg2cu                      n
     D  $imapck                       1
     D   $imapcke                     1
     D   $imapcku                      n
     D  $imnrpk                       3  0
     D   $imnrpke                     1
     D   $imnrpku                      n

417 AD $Item2          ds

416bA * Fields added for version 2.
     D  $imnslt                       1
     D   $imnslte                     1
     D   $imnsltu                      n
     D  $imxdck                       1
     D   $imxdcke                     1
     D   $imxdcku                      n
     D  $imbnbr                       3  0
     D   $imbnbre                     1
     D   $imbnbru                      n
     D  $imbnam                      40
     D   $imbname                     1
     D   $imbnamu                      n
     D  $imvnam                      40
     D   $imvname                     1
     D   $imvnamu                      n
     D  $imbrnd                      10
     D   $imbrnde                     1
     D   $imbrndu                      n
     D  $imlot                        1
     D   $imlote                      1
     D   $imlotu                       n
     D  $imltrk                       1
     D   $imltrke                     1
     D   $imltrku                      n
     D  $imoday                       3  0
     D   $imodaye                     1
     D   $imodayu                      n

500 A * Fields added for version 3.
     D  $ifcat                       10
     D   $ifcate                      1
     D   $ifcatu                       n

510 A * Fields added for version 5.
650dA * $kcqty1                       3  0
650cAD  $kcqty1                       5  0
     D   $kcqty1e                     1
     D   $kcqty1u                      n
     D  $kcqty2                       3  0
     D   $kcqty2e                     1
     D   $kcqty2u                      n
     D  $kcqty3                       3  0
     D   $kcqty3e                     1
     D   $kcqty3u                      n

520aA * Fields added for version 6.
     D  $ifcaseovf                    1
     D   $ifcaseovfe                  1
     D   $ifcaseovfu                   n

610aA * Fields added for version 7.
     D  $ifodrslot                   12
     D   $ifodrslote                  1
     D   $ifodrslotu                   n

640aA * Fields added for version 8.
     D  $ifucicde                     1
     D   $ifucicdee                   1
     D   $ifucicdeu                    n
     D  $ifrcvmth                     1
     D   $ifrcvmthe                   1
     D   $ifrcvmthu                    n
     D  $ifsltmth                     1
     D   $ifsltmthe                   1
     D   $ifsltmthu                    n
     D  $ifbrdflg                     1
     D   $ifbrdflge                   1
     D   $ifbrdflgu                    n

650aA * Fields added for version 9.
650aAD  $kidisp                      12
650aAD   $kidispe                     1
650aAD   $kidispu                      n
650aAD  $kirptp                       1
650aAD   $kirptpe                     1
650aAD   $kirptpu                      n
650aAD  $kiqty1                       3  0
650aAD   $kiqty1e                     1
650aAD   $kiqty1u                      n
650aAD  $kiqty2                       3  0
650aAD   $kiqty2e                     1
650aAD   $kiqty2u                      n
650aAD  $kiqty3                       3  0
650aAD   $kiqty3e                     1
650aAD   $kiqty3u                      n
650cAD  $kcdisp                      12
650aAD   $kcdispe                     1
650aAD   $kcdispu                      n
