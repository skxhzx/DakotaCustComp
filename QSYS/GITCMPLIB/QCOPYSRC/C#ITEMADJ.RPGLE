      *===================================================================
      *
      *  Name .......... C#ITEMADJ
      *  Description ... Dakota realtime interface layout for *ITEMADJ
      *  Created by .... Dave Sommerville
      *
      *===================================================================
      *
      * Revisions
      *
416 A *   10/10/01  DAS  4.16
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

     D $itemadj        ds

     D  $iaVer#                       2s 0 Inz(1)
     D  $iawhse                       3  0
     D   $iawhsee                     1
     D  $iaitem                      15
     D   $iaiteme                     1
     D  $iawhdp                       5
     D   $iawhdpe                     1
     D  $iaslot                      12
     D   $iaslote                     1
     D  $iaqty1                       5  0
     D   $iaqty1e                     1
     D  $iaqty2                       5  0
     D   $iaqty2e                     1
     D  $iaqty3                       5  0
     D   $iaqty3e                     1
     D  $iacwta                       9  2
     D   $iacwtae                     1
     D  $iacode                       2
     D   $iacodee                     1
     D  $iamemo                      30
     D   $iamemoe                     1
     D  $iaby                        10
     D  $iadate                       8  0
     D  $iatime                       6  0
