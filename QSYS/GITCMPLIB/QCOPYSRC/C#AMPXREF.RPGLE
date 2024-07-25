      *===================================================================
      *
      *  Name .......... C#AMPXREF
      *  Description ... Dakota realtime interface layout for AMPXREF
      *  Created by .... Nancy Koelz
      *
      *===================================================================
      *
      * Revisions
      *
416 A *   04/14/16  NLK  7.00
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

     D $ampxref        ds

     D  $axVer#                       2s 0 Inz(1)
     D  $axwhse                       3  0
     D   $axwhsee                     1
     D  $axcust                      11  0
     D   $axcuste                     1
     D  $axcord                       7  0
     D   $axcorde                     1
     D  $axitem                      15
     D   $axiteme                     1
     D  $axartid                      5
     D   $axartide                    1
     D  $axaord                       7  0
     D   $axaorde                     1
      *
     D  $axdrtid                      5
     D   $axdrtide                    1
     D  $axdtrn#                      7  0
     D   $axdtrn#e                    1
      *
     D  $axby                        10
     D  $axdate                       8  0
     D  $axtime                       6  0
