      *===================================================================
      *
      *  Name .......... C#DESIG
      *  Description ... Dakota realtime interface layout for *DESIG
      *  Created by .... Dave Sommerville
      *
      *===================================================================
      *
      * Revisions
      *
416 A *   01/08/02  DAS  4.16
      *     - Created.
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

     D $desig          ds

     D  $dsver#                       2s 0 Inz(1)
     D  $dscode                       5
     D   $dscodee                     1
     D   $dscodeu                      n
     D  $dsdesc                      30
     D   $dsdesce                     1
     D   $dsdescu                      n
     D  $dstype                       1
     D   $dstypee                     1
     D   $dstypeu                      n
