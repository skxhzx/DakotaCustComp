      *===================================================================
      *
      *  Name .......... C#PIRITEM
      *  Description ... Dakota realtime interface layout for PIRITEM
      *  Created by .... Nancy Koelz
      *
      *===================================================================
      *
      * Revisions
      *
416 A *   04/21/16  NLK  7.00
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
      *
416 A *   - Most fields should have a corresponding error flag field. This
416 A *     field is used to indicate if the field caused an error or a
416 A *     warning. Values are 0 = No error/warning, 1 = Error and
416 A *     2 = Warning.
      *
      *===================================================================

     D $piritem        ds

     D  $itVer#                       2s 0 Inz(1)
     D  $itwhse                       3  0
     D   $itwhsee                     1
     D  $ititem                      15
     D   $ititeme                     1
     D  $ittype                       1
     D   $ittypee                     1
     D  $itdesc                      30
     D   $itdesce                     1
      *
     D  $itby                        10
     D  $itdate                       8  0
     D  $ittime                       6  0
