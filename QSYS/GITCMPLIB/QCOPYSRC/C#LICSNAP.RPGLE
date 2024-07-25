      *===================================================================
      *
      *  Name .......... C#LICSNAP
      *  Description ... Dakota realtime interface layout for *LICSNAP
      *  Created by .... Rod Roller
      *
      *===================================================================
      *
      * Revisions
      *
660 A *   01/20/14  RTR  6.60
      *     - Created.
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

     D $licsnap        ds                  inz
     D  $lssver#                      2s 0 Inz(1)

      * Warehouse

     D  $lssWhse                      3  0
     D   $lssWhseE                    1
     D   $lssWhseU                     n

      * License

     D  $lssLcns                     15a
     D   $lssLcnsE                    1
     D   $lssLcnsU                     n

      * Add Timestamp

     D  $lssAddUC                      z
     D   $lssAddUCE                   1
     D   $lssAddUCU                    n

