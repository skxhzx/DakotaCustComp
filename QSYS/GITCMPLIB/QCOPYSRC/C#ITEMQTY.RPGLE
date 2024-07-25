      *===================================================================
      *
      *  Name .......... C#ITEMQTY
      *  Description ... Dakota realtime interface layout for *ITEMQTY
      *  Created by .... Dave Sommerville
      *
      *===================================================================
      *
      * Revisions
      *
416 A *   12/04/01  DAS  4.16
      *     - Created.
      *
416aA *   01/29/02  DAS  4.16a
      *     - Changed version number to 2.
      *     - Added fields $iatrn#, $ialic# and $iatask.
      *
416bA *   06/10/02  DAS  4.16b
      *     - Changed version number to 3.
      *     - Changed $iqlic# to 15 from 7.0.
      *     - Only DRISLOT use this field or the fileds that
      *       follow ($iqtask).
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

     D $itemqty        ds

416bMD  $iqVer#                       2s 0 Inz(3)
     D  $iqwhse                       3  0
     D   $iqwhsee                     1
     D   $iqwhseu                      n
     D  $iqitem                      15
     D   $iqiteme                     1
     D   $iqitemu                      n
     D  $iqumq2                       3  0
     D   $iqumq2u                      n
     D  $iqumq3                       3  0
     D   $iqumq3u                      n
     D  $iqstat                       2
     D   $iqstatu                      n

     D  $iqstk1                       7  0
     D   $iqstke                      1
     D   $iqstku                       n
     D  $iqstk2                       5  0
     D  $iqstk3                       5  0

     D  $iqalc1                       7  0
     D   $iqalce                      1
     D   $iqalcu                       n
     D  $iqalc2                       5  0
     D  $iqalc3                       5  0

     D  $iqhld1                       7  0
     D   $iqhlde                      1
     D   $iqhldu                       n
     D  $iqhld2                       5  0
     D  $iqhld3                       5  0

     D  $iqtri1                       7  0
     D   $iqtrie                      1
     D   $iqtriu                       n
     D  $iqtri2                       5  0
     D  $iqtri3                       5  0

     D  $iqtro1                       7  0
     D   $iqtroe                      1
     D   $iqtrou                       n
     D  $iqtro2                       5  0
     D  $iqtro3                       5  0

     D  $iqord1                       7  0
     D   $iqorde                      1
     D   $iqordu                       n

     D  $iqphy1                       7  0
     D  $iqphy2                       5  0
     D  $iqphy3                       5  0

     D  $iqavl1                       7  0
     D  $iqavl2                       5  0
     D  $iqavl3                       5  0

     D  $iqfix1                       7  0
     D   $iqfixe                      1
     D   $iqfixu                       n
     D  $iqfix2                       5  0
     D  $iqfix3                       5  0

     D  $iqadj1                       7  0
     D   $iqadje                      1
     D   $iqadju                       n
     D  $iqadj2                       5  0
     D  $iqadj3                       5  0

     D  $iqorg1                       7  0
     D   $iqorge                      1
     D   $iqorgu                       n
     D  $iqorg2                       5  0
     D  $iqorg3                       5  0

     D* Version 2 additions

     D  $iqtrn#                       7  0
     D   $iqtrn#u                      n
416bDD**$iqlic#                       7  0
416bMD  $iqlic#                      15
     D   $iqlic#u                      n
     D  $iqtask                       6
     D   $iqtasku                      n
