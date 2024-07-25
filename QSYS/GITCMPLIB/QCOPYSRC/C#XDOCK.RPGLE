      *===================================================================
      *
      *  Name .......... C#XDOCK
      *  Description ... Dakota realtime interface layout for *XDOCK
      *  Created by .... Dave Sommerville
      *
      *===================================================================
      *
      * Revisions
      *
416 A *   02/08/02  DAS  4.16
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
416 A *     The only exceptions are the warehouse and item fields, which
416 A *     must be sent every time. In some cases a single indicator can
      *     be used for a group of fields.
      *
      *===================================================================

     D $xdock          ds

     D  $xdVer#                       2s 0 Inz(1)
     D  $xdwhse                       3  0
     D   $xdwhsee                     1
     D   $xdwhseu                      n
     D  $xditem                      15
     D   $xditeme                     1
     D   $xditemu                      n
     D  $xdpo                         9
     D   $xdpoe                       1
     D   $xdpou                        n
     D  $xdseq#                       5  0
     D   $xdseq#e                     1
     D   $xdseq#u                      n
     D  $xdqty1                       5  0
     D   $xdqty1e                     1
     D   $xdqtyu                       n
     D  $xdqty2                       3  0
     D   $xdqty2e                     1
     D  $xdqty3                       3  0
     D   $xdqty3e                     1
