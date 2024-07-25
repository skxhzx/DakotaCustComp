      *===================================================================
      *
      *  Name .......... ORDDM2_HAR
      *  Description ... Order Detail Misc. Field 2 - Harbor
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   09/10/07  MLB  5.10
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm2_har      ds

     D  hardm2_base                  40
     D*                                    text('Detail Misc 2 Field')
     D  hardm2_ovrds1                40    overlay(hardm2_base:1)
     D*                                    text('Voice override desc. 1')
