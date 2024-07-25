      *===================================================================
      *
      *  Name .......... C#SLOT
      *  Description ... Dakota realtime interface layout for *SLOT
      *  Created by .... Dave Sommerville
      *
      *===================================================================
      *
      * Revisions
      *
416 A *   10/10/01  DAS  4.16
      *     - Created.
      *
416aA *   12/14/01  DAS  4.16a
      *     - Changed version number to 2.
      *     - Added "original" qty fields $slorg1,2,3.
      *     - Added verify flag for transfers and letdowns ($slvrfy).
      *
416bA *   01/29/02  DAS  4.16b
      *     - Changed version number to 3.
      *     - Added fields $satrn#, $salic#, $satask and $slcdsp
      *
416cA *   06/10/02  DAS  4.16c
      *     - Changed version number to 4.
      *     - Changed $salic# to 15 from 7.0.
      *
416cA *   06/07/03  DAS  4.17
      *     - Changed version number to 5.
      *     - Added fields $sfvirt and $sfvirtu (Associated Virtuals flag).
      *
416cA *   09/29/03  DAS  4.17a
      *     - Changed version number to 6.
      *     - Added field $sacitem, $saciteme and $sacitemu
      *       (Corresponding item number).
      *
416cA *   10/03/03  DAS  4.17b
      *     - Changed version number to 7.
      *     - Added field $scddgt (check digit) field.
      *
500 A *   01/21/05  DAS  5.00
      *     - Changed version number to 8.
      *     - Added field $saslpos (slot position) field.
      *     - Added field $salcns (license number) field.
      *
600aA *   01/21/09  DAS  6.00a
      *     - Changed version number to 9.
      *     - Added a number of fields to support license tracking.
      *
600bA *   06/10/09  DAS  6.00b
      *     - Changed version number to 10.
      *     - Added $saFrmEmpty field
      *
640aA *   06/02/11  DAS  6.40a
      *     - Changed version number to 11.
      *     - Added $saItmChg field
      *
640bA *   10/17/11  RBD  6.40a
      *     - Changed version number to 12.
      *     - Added $saIMMDAY and $saITFLGD which will be
      *       used with %SETFIFOG.
      *
650aA *   11/19/14  KDE  6.50a
      *     - Changed version number to 13.
      *     - Added Production Module fields
      *
700aA *   12/07/16  DAS  7.00a
      *     - Changed version number to 14.
      *     - Added $saAllowZro flag. When 'Y' will skip zero qty check
      *       in VerifyQty routine.
      *
710 A *   02/13/17  KDE  7.10
      *     - Add field for Dry Age raw material UCI
      *     - Changed version number to 15.
710aA *   07/19/16  LMC  7.10a
      *     - Changed version number to 16.
      *     - Added uci tracking fields for partial movement.
      *
      *===================================================================
      *
      * Notes
      *
      *   - When adding new fields ...
      *
      *       1) Increment the version number
      *       2) Always add new fields to the end of the layout.
      *       3) Create corresponding error indicator field.
      *       3) Create corresponding usage indicator field.
      *
416 A *   - Most fields should have a corresponding error flag field. This
416 A *     field is used to indicate if the field caused an error or a
416 A *     warning. Values are 0 = No error/warning, 1 = Error and
416 A *     2 = Warning.
      *
416 A *   - Each field should have a corresponding indicator field. This
416 A *     field is used to indicate if the field is being used (sent).
416 A *     In some cases a single indicator can be used for a group of
      *     fields.
      *
      *===================================================================

     D $slot           ds

710aMD  $slVer#                       2s 0 Inz(16)
     D  $slwhse                       3  0
     D   $slwhsee                     1
     D   $slwhseu                      n
     D  $slwhdp                       5
     D   $slwhdpe                     1
     D   $slwhdpu                      n
     D  $slaisl                       3
     D   $slaisle                     1
     D   $slaislu                      n
     D  $slloc                        3  0
     D   $slloce                      1
     D   $sllocu                       n
     D  $slrlvl                       2  0
     D   $slrlvle                     1
     D   $slrlvlu                      n
     D  $slhand                       2
     D   $slhande                     1
     D   $slhandu                      n
     D  $slside                       1  0
     D   $slsidee                     1
     D   $slsideu                      n
     D  $slstyp                       1
     D   $slstype                     1
     D   $slstypu                      n
     D  $sldisp                      12
     D   $sldispe                     1
     D   $sldispu                      n
     D  $slstat                       2
     D   $slstate                     1
     D   $slstatu                      n
     D  $slsdte                       8  0
     D   $slsdtee                     1
     D   $slsdteu                      n
     D  $slstim                       6  0
     D   $slstime                     1
     D   $slstimu                      n
     D  $slsdef                       2
     D   $slsdefe                     1
     D   $slsdefu                      n
     D  $sldesg                       5
     D   $sldesge                     1
     D   $sldesgu                      n
     D  $slactv                       2
     D   $slactve                     1
     D   $slactvu                      n
     D  $slbld                        2
     D   $slblde                      1
     D   $slbldu                       n
     D  $slpick                       1
     D   $slpicke                     1
     D   $slpicku                      n
     D  $slpseq                       5  0
     D   $slpseqe                     1
     D   $slpsequ                      n
     D  $slprty                       1  0
     D   $slprtye                     1
     D   $slprtyu                      n
     D  $slentd                       8  0
     D   $slentde                     1
     D   $slentdu                      n
     D  $slexpd                       8  0
     D   $slexpde                     1
     D   $slexpdu                      n
     D  $slslfd                       8  0
     D   $slslfde                     1
     D   $slslfdu                      n
     D  $slrsrv                       1
     D   $slrsrve                     1
     D   $slrsrvu                      n
     D  $slitem                      15
     D   $sliteme                     1
     D   $slitemu                      n
     D  $slstk1                       5  0
     D  $slstk2                       3  0
     D  $slstk3                       3  0
     D  $slalc1                       5  0
     D  $slalc2                       3  0
     D  $slalc3                       3  0
     D  $sltfr1                       5  0
     D  $sltfr2                       3  0
     D  $sltfr3                       3  0
     D  $slpck1                       5  0
     D  $slpck2                       3  0
     D  $slpck3                       3  0
     D  $slrcv1                       5  0
     D  $slrcv2                       3  0
     D  $slrcv3                       3  0
     D  $slphy1                       5  0
     D  $slphy2                       3  0
     D  $slphy3                       3  0
     D  $slavl1                       5  0
     D  $slavl2                       3  0
     D  $slavl3                       3  0
     D  $sladj1                       5  0
     D  $sladj2                       3  0
     D  $sladj3                       3  0

      *---------------------
      * Version 2 additions
      *---------------------

      * Adjustment item

     D  $saitem                      15
     D   $saiteme                     1
     D   $saitemu                      n

      * Adjustment qty

     D  $saqty1                       5  0
     D   $saqty1e                     1
     D   $saqtyu                       n
     D  $saqty2                       5  0
     D   $saqty2e                     1
     D  $saqty3                       5  0
     D   $saqty3e                     1

      * Original bucket qty
      *   - Used to remove qty from Rcv/Tfr/Pck/Alc buckets.

     D  $saorg1                       5  0
     D   $saorg1e                     1
     D   $saorgu                       n
     D  $saorg2                       3  0
     D   $saorg2e                     1
     D  $saorg3                       3  0
     D   $saorg3e                     1

      * Adjustment weight

     D  $sacwta                       9  2
     D   $sacwtae                     1
     D   $sacwtau                      n

      * Adjustment code

     D  $sacode                       2
     D   $sacodee                     1
     D   $sacodeu                      n

      * Adjustment memo

     D  $samemo                      30
     D   $samemoe                     1
     D   $samemou                      n

      * Adjusted By

     D  $saby                        10
     D   $sabyu                        n

      * Adjustment date

     D  $sadate                       8  0
     D   $sadateu                      n

      * Adjustment time

     D  $satime                       6  0
     D   $satimeu                      n

      * From license verified.

     D  $saFrmVrfy                    1
     D   $saFrmVrfyU                   n

      *---------------------
      * Version 3 additions
      *---------------------

      * Transaction #

     D  $satrn#                       7  0
     D   $satrn#u                      n
416cDD**$salic#                       7  0

      * From license number

416cMD  $saFrmLcns                   15
     D   $saFrmLcnsU                   n

      * Task

     D  $satask                       6
     D   $satasku                      n

      * Corresponding slot
      *   - Area code sent for STG/RCV slots.
      *   - Returns base slot.

     D  $sacdsp                      12
     D   $sacdspu                      n

      *---------------------
417 A * Version 5 additions
      *---------------------

      * Associated virtual slot flag

     D  $sfvirt                       1
     D   $sfvirtu                      n

      *---------------------
417a D* Version 6 additions
      *---------------------

      * Correcponding item
      *  - Sent when item is changed.

     D  $sacitem                     15
     D   $saciteme                    1
     D   $sacitemu                     n

      *---------------------
417aA * Version 7 additions
      *---------------------

      * Slot check digit

     D  $scddgt                       3  0
     D   $scddgte                     1
     D   $scddgtu                      n

      *---------------------
500 A * Version 8 additions
      *---------------------

     D $slot2          ds

      * To slot position

     D  $saToPos                      3  0
     D   $saToPose                    1
     D   $saToPosu                     n

      * To license number

     D  $saToLcns                    15
     D   $saToLcnse                   1
     D   $saToLcnsu                    n

      *---------------------
600aA * Version 9 additions
      *---------------------

      * To License verified by user

     D  $saToVrfy                     1
     D   $saToVrfyE                   1
     D   $saToVrfyU                    n

      * Original license number

     D  $saOLcns                     15
     D   $saOLcnse                    1
     D   $saOLcnsu                     n

      * Employee #

     D  $saemp#                       5  0
     D   $saemp#e                     1
     D   $saemp#u                      n

      * Corresponding dept (i.e., USR dept)

     D  $sacwhd                       5
     D   $sacwhde                     1
     D   $sacwhdu                      n

      * Action code

     D  $saAction                     3
     D   $saActionE                   1
     D   $saActionU                    n

      * Employee Transaction number

     D  $saETrn#                      7  0
     D   $saETrn#E                    1
     D   $saETrn#U                     n

      * Label number

     D  $saLbl#                       7  0
     D   $saLbl#E                     1
     D   $saLbl#U                      n

      * To Location code

     D  $saToCode                     1
     D   $saToCodeE                   1
     D   $saToCodeU                    n

      * To Location area

     D  $saToArea                    15
     D   $saToAreaE                   1
     D   $saToAreaU                    n

      * To Customer order number

     D  $saToOrd                      7  0
     D   $saToOrdE                    1
     D   $saToOrdU                     n

      * To Customer order seq number

     D  $saToSeq                      5  0
     D   $saToSeqE                    1
     D   $saToSeqU                     n

      * Pulled license number

     D  $saPullLcns                  15
     D   $saPullLcnse                 1
     D   $saPullLcnsu                  n

      * Pulled department

     D  $saPullWhdp                   5
     D   $saPullWhdpe                 1
     D   $saPullWhdpu                  n

      * Pulled slot

     D  $saPullDisp                  12
     D   $saPullDispe                 1
     D   $saPullDispu                  n

      * Pulled base slot

     D  $saPullBase                  12
     D   $saPullBasee                 1
     D   $saPullBaseu                  n

      * License exception code

     D  $saExcd                       8
     D   $saExcdE                     1
     D   $saExcdU                      n

      *---------------------
600bA * Version 10 additions
      *---------------------

      * From slot empty flag

     D  $saFrmEmpty                   1
     D   $saFrmEmptyu                  n

      *---------------------
640aA * Version 11 additions
      *---------------------

      * Item Change flag for Transfer

     D  $saItmChg                     1
     D   $saItmChgu                    n

      *---------------------
640bA * Version 12 additions
      *---------------------

      * Item Mfg Shelf Life Days

     D  $saIMMDAY                     3s 0
     D   $saIMMDAYu                    n

      * Item Date Sensitve Flag

     D  $saITFLGD                     1
     D   $saITFLGDu                    n

      *---------------------
640bA * Version 13 additions
      * Production Module Additions
      *---------------------

      * Mfg Line Number

     D  $saMfgLne                     3  0
     D   $saMfgLnee                   1
     D   $saMfgLneu                    n

      * GS1 Data

     D  $saGs1                       50
     D   $saGs1e                      1
     D   $saGs1u                       n

      * Serial Number

     D  $saSer#                      20
     D   $saSer#e                     1
     D   $saSer#u                      n

      * Prod. Secondary Item Number

     D  $saPrdSItm                   15
     D   $saPrdSItme                  1
     D   $saPrdSItmu                   n

      * Prod. Catch Weight/Scanned Weight

     D  $saPrdWgt                     9s 3
     D   $saPrdWgte                   1
     D   $saPrdWgtu                    n

      * Prod. Tare Weight

     D  $saTareWgt                    9s 3
     D   $saTareWgte                  1
     D   $saTareWgtu                   n

      * Prod. Customer Number

     D  $saPrdCust                   11  0
     D   $saPrdCuste                  1
     D   $saPrdCustu                   n

      * Prod. Station ID

     D  $saPrdSta                     2
     D   $saPrdStae                   1
     D   $saPrdStau                    n

      * Prod. UOM

     D  $saPrdUom                     2
     D   $saPrdUome                   1
     D   $saPrdUomu                    n

      * Prod. Work Order Number

     D  $saPrdWo                     13
     D   $saPrdWoe                    1
     D   $saPrdWou                     n

      *---------------------
700aA * Version 14 additions
      *---------------------

      * Allow Zero Flag (Y = skip zero qty check in VerifyQty)

     D  $saAllowZero                  1
     D   $saAllowZrou                  n

      *---------------------
710 A * Version 15 additions
      *---------------------

      * Raw MAterial UCI for Dry Production (Production Module)
     D  $saRmUci                    100
     D   $saRmUcie                    1
     D   $saRmUciU                     n
      *---------------------
710aA * Version 16 additions
      * UCI Tracking Additions
      *---------------------
      * UCI Tracking Time Stamp for Partial Movement

     D  $saUCIts                       Z
     D   $saUCItse                    1
     D   $saUCItsu                     n

      * UCI Tracking for type of adjustment scanning

     D  $saUCItype                    2
     D   $saUCItypee                  1
     D   $saUCItypeu                   n
