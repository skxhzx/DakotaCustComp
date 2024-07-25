      *===================================================================
      *
      *  Name .......... ORDHM2_HAR
      *  Description ... Order Header Misc. Field 1 - Harbor
      *  Created by .... Rod Roller
      *
      *===================================================================
      *
      * Revisions
      *
710   *   05/12/17  RTR  7.10
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ordhm2_har      ds

     D  harhm2_base                  40
     D*                                    text('Header Misc 2 Field')
     D  harhm2_hmoseq                20    overlay(harhm2_base:1)
     D*                                    text('HAR HighJump Order Seq')

