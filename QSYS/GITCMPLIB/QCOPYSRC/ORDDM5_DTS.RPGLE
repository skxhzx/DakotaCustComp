      *===================================================================
      *
      *  Name .......... ORDDM5_DTS
      *  Description ... Order Detail Misc Field 5 - DTS (DataTech IFC)
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   03/08/11  MLB  6.40
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm5_dts      ds

     D  dtsdm5_base                  40
     D*                                    text('Detail Misc 5 Field')
     D  dtsdm5_omsmsg                40    overlay(dtsdm5_base:1)
     D*                                    text('DTS Special Item Msg')
