      *===================================================================
      *
      *  Name .......... ORDHM2_RTX
      *  Description ... Order Header Misc. Field 2 - RTX (Retalix IFC)
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
520 A *   12/08/08  MLB  5.20
      *     - Created.
520aA *   03/10/09  MLB  5.20a
      *     - Enh: Added Retalix Delivery Date (OOHDTEI)
650 A *   02/21/14  MLB  6.50
      *     - Enh: Added field to store alpha customer number from Retalix
730 A *   08/13/19  MLB  7.30
      *     - Enh: Added field for Bill-to customer number from Retalix.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ordhm2_rtx      ds

     D  rtxhm2_base                  40
     D*                                    text('Header Misc 2 Field')
520aAD  rtxhm2_hmdtei                 8S 0 overlay(rtxhm2_base:1)
520aAD*                                    text('IDS Delivery Date -       -'
520aAD*                                    YYYYMMDD')
650 AD  rtxhm2_ohcusn                10    overlay(rtxhm2_base:9)
650 AD*                                    text('IDS Customer Number')
730 AD rtxhm2_ohbilto                10    overlay(rtxhm2_base:19)
730 AD*                                    text('IDS Bill-to Customer Number')
