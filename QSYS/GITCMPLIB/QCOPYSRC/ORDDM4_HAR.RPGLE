      *===================================================================
      *
      *  Name .......... ORDDM4_HAR
      *  Description ... Order Detail Misc. Field 4 - Harbor
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

     D orddm4_har      ds

     D  hardm4_base                  40
     D*                                    text('Detail Misc 4 Field')
     D  hardm4_chkdgt                 3    overlay(hardm4_base:1)
     D*                                    text('Voice check digit')
