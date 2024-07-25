      *===================================================================
      *
      *  Name .......... C#PIRTRAN
      *  Description ... Dakota realtime interface layout for *PIRTRAN
      *  Created by .... Dave Sommerville
      *
      *===================================================================
      *
      * Revisions
      *
600 A *   11/14/08  DAS  6.00
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

     D $pirtran        ds

     D  $ptver#                       2s 0 Inz(1)
     D  $pttrn#                       7  0
     D   $pttrn#E                     1
     D   $pttrn#U                      n
     D  $ptstat                       1
     D   $ptstatE                     1
     D   $ptstatU                      n
     D  $pttask                       6
     D   $pttaskE                     1
     D   $pttaskU                      n
     D  $ptcat                        6
     D   $ptcatE                      1
     D   $ptcatU                       n
     D  $ptsub                        6
     D   $ptsubE                      1
     D   $ptsubU                       n
     D  $ptwhse                       3  0
     D   $ptwhseE                     1
     D   $ptwhseU                      n
     D  $ptwhdp                       5
     D   $ptwhdpE                     1
     D   $ptwhdpU                      n
     D  $ptstyp                       1
     D   $ptstypE                     1
     D   $ptstypU                      n
     D  $ptshft                       6
     D   $ptshftE                     1
     D   $ptshftU                      n
     D  $ptcrew                       6
     D   $ptcrewE                     1
     D   $ptcrewU                      n
     D  $ptemp#                       5  0
     D   $ptemp#E                     1
     D   $ptemp#U                      n
     D  $ptcube                       9  3
     D   $ptcubeE                     1
     D   $ptcubeU                      n
     D  $ptswgt                       9  2
     D   $ptswgtE                     1
     D   $ptswgtU                      n
     D  $ptpcs                        5  0
     D   $ptpcsE                      1
     D   $ptpcsU                       n
     D  $ptaisl                       5  0
     D   $ptaislE                     1
     D   $ptaislU                      n
     D  $ptqty1                       5  0
     D   $ptqty1E                     1
     D   $ptqty1U                      n
     D  $ptqty2                       5  0
     D   $ptqty2E                     1
     D   $ptqty2U                      n
     D  $ptqty3                       5  0
     D   $ptqty3E                     1
     D   $ptqty3U                      n
     D  $ptgdte                       8  0
     D   $ptgdteE                     1
     D   $ptgdteU                      n
     D  $ptgtim                       6  0
     D   $ptgtimE                     1
     D   $ptgtimU                      n
     D  $ptsdte                       8  0
     D   $ptsdteE                     1
     D   $ptsdteU                      n
     D  $ptstim                       6  0
     D   $ptstimE                     1
     D   $ptstimU                      n
     D  $ptedte                       8  0
     D   $ptedteE                     1
     D   $ptedteU                      n
     D  $ptetim                       6  0
     D   $ptetimE                     1
     D   $ptetimU                      n
     D  $ptcdte                       8  0
     D   $ptcdteE                     1
     D   $ptcdteU                      n
     D  $ptctim                       6  0
     D   $ptctimE                     1
     D   $ptctimU                      n
     D  $ptrdte                       8  0
     D   $ptrdteE                     1
     D   $ptrdteU                      n
     D  $ptdmin                       5  0
     D   $ptdminE                     1
     D   $ptdminU                      n
     D  $ptimin                       5  0
     D   $ptiminE                     1
     D   $ptiminU                      n
     D  $ptrtpo                       9
     D   $ptrtpoE                     1
     D   $ptrtpoU                      n
     D  $ptgrp1                       1
     D   $ptgrp1E                     1
     D   $ptgrp1U                      n
     D  $ptgrp2                       1
     D   $ptgrp2E                     1
     D   $ptgrp2U                      n
