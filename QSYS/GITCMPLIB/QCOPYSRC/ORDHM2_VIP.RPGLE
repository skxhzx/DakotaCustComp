      *===================================================================
      *
      *  Name .......... ORDHM2_VIP
      *  Description ... Order Header Misc. Field 2 - VIP
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   04/03/07  MLB  5.10
      *     - Created.
      *
640aA *   05/08/12  MLB  6.40
      *     - Enh: Added field to store customer number if not all numeric
      *       characters.
      *
      *===================================================================
      *
      * Client Custom Revisions: Y.Hata
      *
YHT A *   10/13/08  MLB  YHT
      *     - Added three new fields to HMMSC2.
650 A *   12/31/13  MLB  6.50
      *     - Enh: Added Retalix Delivery Date (OOHDTEI)
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ordhm2_vip      ds

     D  viphm2_base                  40
     D*                                    text('Header Misc 2 Field')
YHT AD  viphm2_hmtknb                 3    overlay(viphm2_base:1)
YHT AD*                                    text('IDS Truck Number')
YHT AD  viphm2_hmtran                15    overlay(viphm2_base:4)
YHT AD*                                    text('IDS Trailer Number')
YHT AD  viphm2_fdnavy                 1    overlay(viphm2_base:19)
YHT AD*                                    text('Print Navy Label (P=Yes)')
640 ADviphm2_ohcusn                  10    overlay(viphm2_base:20)
640 AD*                                    text('IDS Customer Number')
650 AD  viphm2_hmdtei                 8S 0 overlay(viphm2_base:30)
650 AD*                                    text('IDS Delivery Date -       -'
650 AD*                                    YYYYMMDD')
