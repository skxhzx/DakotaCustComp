      *===================================================================
      *
      *  Name .......... C#ATP
      *  Description ... Dakota realtime interface layout for APT
      *  Created by .... Rod Roller
      *
      *===================================================================
      *
      * Revisions
      *
750 A *   01/05/22  MLB  7.50
      *     - Enh: Added new fields needed for Returns processing.
      *     - Changed Version to 2 from 1.
      *
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
      *   - Each field should have a corresponding indicator field. This
      *     field is used to indicate if the field is being used (sent).
      *     The only exceptions are the warehouse and item fields, which
      *     must be sent every time. In some cases a single indicator can
      *     be used for a group of fields.
      *
      *   - Most fields should have a corresponding error flag field. This
      *     field is used to indicate if the field caused an error or a
      *     warning. Values are 0 = No error/warning, 1 = Error and
      *     2 = Warning.
      *
      *===================================================================

     D $aptds          ds

750 DD* $apVer#                       2s 0 Inz(1)
750 MD  $apVer#                       2s 0 Inz(2)
     D  $apuser                      10
     D  $apjob                       10
     D  $apjobn                       6

     D  $apwhse                       3  0
     D   $apwhsee                     1
     D   $apwhseu                      n
     D  $aplbl#                       7  0
     D   $aplbl#e                     1
     D   $aplbl#u                      n
     D  $aptrn#                       7  0
     D   $aptrn#e                     1
     D   $aptrn#u                      n
     D  $aprteid                      5
     D   $aprteide                    1
     D   $aprteidu                     n
     D  $aprte                        5
     D   $aprtee                      1
     D   $aprteu                       n
     D  $apemp#                       5  0
     D   $apemp#e                     1
     D   $apemp#u                      n
     D  $aplocation                  20
     D  $aploctype                    1    overlay($aplocation:13)
     D   $aplocatione                 1
     D   $aplocationu                  n
     D  $apseq#                       5  0
     D   $apseq#e                     1
     D   $apseq#u                      n
750 A
750 AD  $apitem                      15
750 AD   $apiteme                     1
750 AD   $apitemu                      n
750 AD  $apord                        7  0
750 AD   $aporde                      1
750 AD   $apordu                       n
750 AD  $aprdte                       8  0
750 AD   $aprdtee                     1
750 AD   $aprdteu                      n
750 AD  $aprtim                       6  0
750 AD   $aprtime                     1
750 AD   $aprtimu                      n
750 AD  $aprcod                       2
750 AD   $aprcode                     1
750 AD   $aprcodu                      n
750 AD  $appbat                       7  0
750 AD   $appbate                     1
750 AD   $appbatu                      n
