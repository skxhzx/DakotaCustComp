      *===================================================================
      *
      *  Name .......... ORDDM1_WAX
      *  Description ... Order Detail Misc. Field 1 - Dynamics AX W/H
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
650 A *   04/25/14  MLB  6.50  P#01163
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm1_wax      ds

     D  waxdm1_base                  40
     D*                                    text('Detail Misc 1 Field')
NCH AD waxdm1_wxbatpk                 1A   overlay(waxdm1_base:1)
NCH AD*                                    text('Dynamics AX WAX Batch Pick Y/N'
NCH AD waxdm1_wxrecid                21A   overlay(waxdm1_base:2)
NCH AD*                                    text('Dynamics AX WAX Record ID')
