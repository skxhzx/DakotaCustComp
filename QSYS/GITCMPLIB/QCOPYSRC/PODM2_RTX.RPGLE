      *===================================================================
      *
      *  Name .......... PODM2_RTX
      *  Description ... P/O Detail Misc. Field 2 - RTX (Retalix IFC)
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
520 A *   02/25/09  MLB  5.20
      *     - Created.
      *
      *===================================================================
      *
      * Client Custom Revisions: BiRite Foodservice
      *
BIRbA *   11/19/10  MLB  BIRb  P#01027
      *     - Added two new fields to PDMMS2 for Fabricated meat
      *       item processing.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D podm2_rtx       ds

     D  rtxdn2_base                  40
     D*                                    text('Detail Misc 2 Field')
BIRbAD  rtxdn2_omfbmt                 1A   overlay(rtxdn2_base:1)
BIRbAD*                                    text('IDS BiRite Fabricated Meat-'
BIRbAD*                                    Item Y/N')
BIRbAD  rtxdn2_omqyoa                 7P 0 overlay(rtxdn2_base:2)
BIRbAD*                                    text('IDS BiRite Actual Qty Ord-'
BIRbAD*                                    ered - Only when omfbmt=Y')
