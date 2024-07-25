      *===================================================================
      *
      *  Name .......... C#PRTYRPL
      *  Description ... Dakota realtime interface layout for *PRTYRPL
      *  Created by .... Dave Sommerville
      *
      *===================================================================
      *
      * Revisions
      *
416 A *   10/30/01  DAS  4.16
      *     - Created.
530aA *   08/02/10  RH   5.30a
      *     - Changed version number to 2.
      *     - Added "Priority repl seq #' field $prseq#
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
      *       4) Create corresponding usage indicator field.
      *
416 A *   - Most fields should have a corresponding error flag field. This
416 A *     field is used to indicate if the field caused an error or a
416 A *     warning. Values are 0 = No error/warning, 1 = Error and
416 A *     2 = Warning.
      *
416 A *   - Each field should have a corresponding indicator field. This
416 A *     field is used to indicate if the field is being used (sent).
      *
      *===================================================================

     D $prtyrpl        ds

530aDD* $prVer#                       2s 0 Inz(1)
530aMD  $prVer#                       2s 0 Inz(2)
     D  $prwhse                       3  0
     D   $prwhsee                     1
     D   $prwhseu                      n
     D  $pritem                      15
     D   $priteme                     1
     D   $pritemu                      n
     D  $prwhdp                       5
     D   $prwhdpe                     1
     D   $prwhdpu                      n
     D  $prslot                      12
     D   $prslote                     1
     D   $prslotu                      n
     D  $prqtyn                       7  0
     D   $prqtyne                     1
     D   $prqtynu                      n
     D  $prqtyw                       7  0
     D   $prqtywe                     1
     D   $prqtywu                      n
     D  $prfill                       1
     D   $prfille                     1
     D   $prfillu                      n
      *---------------------
530aA * Version 2 additions
      *---------------------
      * Priority replenishment seq #
530a D  $prseq#                       5  0
530a D   $prseq#e                     1
530a D   $prseq#u                      n

