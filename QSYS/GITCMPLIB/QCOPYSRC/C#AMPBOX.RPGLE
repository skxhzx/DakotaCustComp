      *===================================================================
      *
      *  Name .......... C#AMPBOX
      *  Description ... Dakota realtime interface layout for AMPBOX
      *  Created by .... Nancy Koelz (madel ITEMADJ)
      *
      *===================================================================
      *
      * Revisions
      *
      *   04/04/16  NLK  7.00
      *     - Created.
700aA *   06/14/16  NLK  7.00a
      *     - Increased BOX# from 3.0 to 5.0
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

     D $ampbox         ds

     D  $abxVer#                      2s 0 Inz(1)
     D  $abxwhse                      3  0
     D   $abxwhsee                    1
700aMD  $abxbox#                      5  0
     D   $abxbox#e                    1
     D  $abxboxid                     7  0
     D   $abxboxide                   1
     D  $abxatrn#                     7  0
     D   $abxatrn#e                   1
     D  $abxacust                    11  0
     D   $abxacuste                   1
     D  $abxaddts                    26
     D   $abxaddtse                   1
      *
     D  $abxby                       10
     D  $abxdate                      8  0
     D  $abxtime                      6  0
