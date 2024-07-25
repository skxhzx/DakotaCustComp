      *===================================================================
      *
      *  Name .......... C#TRUCKD
      *  Description ... Dakota realtime interface layout for *TRUCKD
      *  Created by .... Dave Sommerville
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   04/22/12  DAS  6.40
      *     - Created.
      *
650 A *   05/01/14  DAS  6.50a
      *     - Added field
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

     D $truckd         ds

650aMD  $tdver#                       2s 0 Inz(2)
     D  $tdwhse                       3  0
     D   $tdwhsee                     1
     D   $tdwhseu                      n
     D  $tdtruk                      10
     D   $tdtruke                     1
     D   $tdtruku                      n
     D  $tdrow                        2  0
     D   $tdrowe                      1
     D   $tdrowu                       n
     D  $tdcol                        1  0
     D   $tdcole                      1
     D   $tdcolu                       n
640aMD  $tdcomp                       1
     D   $tdcompe                     1
     D   $tdcompu                      n
     D  $tdcube                       5  2
     D   $tdcubee                     1
     D   $tdcubeu                      n
     D  $tdpick                       2  0
     D   $tdpicke                     1
     D   $tdpicku                      n

     D* $tdr2c - Rows to create (not in truckd file)

     D  $tdr2c                        2  0
     D   $tdr2ce                      1
     D   $tdr2cu                       n

650aA * Fields added for version 2.

     D* $tdfrmtrk - From Truck for copy, (not in truckd file)

     D  $tdfrmtrk                    10
     D   $tdfrmtrke                   1
     D   $tdfrmtrku                    n
