      *===================================================================
      *
      *  Name .......... ORDHM1_RTX
      *  Description ... Order Header Misc. Field 1 - RTX (Retalix IFC)
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
520 A *   12/08/08  MLB  5.20
      *     - Created.
      *
      *===================================================================
      *
      * Client Custom Revisions: MJ Kellner
      *
MJK A *   08/29/08  MLB  MJK
      *     - Added three new fields to HMMSC1 for contract order
      *       processing.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ordhm1_rtx      ds

     D  rtxhm1_base                  40
     D*                                    text('Header Misc 1 Field')
MJK AD  rtxhm1_hmkctr                 6    overlay(rtxhm1_base:1)
MJK AD*                                    text('IDS Kellner Contract Number')
MJK AD  rtxhm1_hmpono                20    overlay(rtxhm1_base:7)
MJK AD*                                    text('IDS Customer purchase order')
MJK AD  rtxhm1_hmdted                 8S 0 overlay(rtxhm1_base:27)
MJK AD*                                    text('IDS Kellner Last Due Date -'
MJK AD*                                    YYYYMMDD')

