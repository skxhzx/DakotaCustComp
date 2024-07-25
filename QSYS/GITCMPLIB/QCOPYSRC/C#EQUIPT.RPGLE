      *===================================================================
      *
      *  Name .......... C#EQUIPT
      *  Description ... Dakota realtime interface layout for *EQUIPT
      *  Created by .... Dave Sommerville
      *
      *===================================================================
      *
      * Revisions
      *
416 A *   12/20/02  DAS  4.16
      *     - Created.
730aA *   10/14/19  LMC  7.30a
      *     - Added Pick-to-Pallet(p2p) - aka pick-to-light
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

     D $equipt         ds

     D  $etver#                       2s 0 Inz(1)
     D  $etwhse                       3  0
     D   $etwhsee                     1
     D   $etwhseu                      n
     D  $ettrn#                       7  0
     D   $ettrn#e                     1
     D   $ettrn#u                      n
417  D* $etcode                       6
417  D  $etcode                       8
     D   $etcodee                     1
     D   $etcodeu                      n
     D  $etemp#                       5  0
     D   $etemp#e                     1
     D   $etemp#u                      n
     D  $etactv                       1
     D   $etactve                     1
     D   $etactvu                      n
     D  $etotrn                       7  0
     D   $etotrne                     1
     D   $etotrnu                      n
     D  $etoqfl                       1
     D   $etoqfle                     1
     D   $etoqflu                      n
     D  $etoxfl                       1
     D   $etoxfle                     1
     D   $etoxflu                      n
     D  $etodts                        z
     D   $etodtse                     1
     D   $etodtsu                      n
     D  $etousr                      10
     D   $etousre                     1
     D   $etousru                      n
     D  $etojob                      10
     D   $etojobe                     1
     D   $etojobu                      n
     D  $etonbr                       6
     D   $etonbre                     1
     D   $etonbru                      n
     D  $etitrn                       7  0
     D   $etitrne                     1
     D   $etitrnu                      n
     D  $etiqfl                       1
     D   $etiqfle                     1
     D   $etiqflu                      n
     D  $etixfl                       1
     D   $etixfle                     1
     D   $etixflu                      n
     D  $etidts                        z
     D   $etidtse                     1
     D   $etidtsu                      n
     D  $etiusr                      10
     D   $etiusre                     1
     D   $etiusru                      n
     D  $etijob                      10
     D   $etijobe                     1
     D   $etijobu                      n
     D  $etinbr                       6
     D   $etinbre                     1
     D   $etinbru                      n
     D  $etmin                        7  2
     D   $etmine                      1
     D   $etminu                       n
730aAD  $etp2p                         n
730aAD   $etp2pe                      1
730aAD   $etp2pu                       n
