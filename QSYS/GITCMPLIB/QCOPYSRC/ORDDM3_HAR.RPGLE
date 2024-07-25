      *===================================================================
      *
      *  Name .......... ORDDM3_HAR
      *  Description ... Order Detail Misc. Field 3 - Harbor
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

     D orddm3_har      ds

     D  hardm3_base                  40
     D*                                    text('Detail Misc 3 Field')
     D  hardm3_ovrds2                40    overlay(hardm3_base:1)
     D*                                    text('Voice override desc. 2')
