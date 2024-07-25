      *===================================================================
      *
      *  Name .......... ORDDM5_RTX
      *  Description ... Order Detail Misc Field 5 - RTX (Retalix IFC)
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
520 A *   12/08/08  MLB  5.20
      *     - Created.
520aA *   03/10/09  MLB  5.20a
      *     - Enh: Added
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm5_rtx      ds

     D  rtxdm5_base                  40
     D*                                    text('Detail Misc 5 Field')
     D  rtxdm5_omsmsg                40    overlay(rtxdm5_base:1)
     D*                                    text('IDS Special Item Msg')
