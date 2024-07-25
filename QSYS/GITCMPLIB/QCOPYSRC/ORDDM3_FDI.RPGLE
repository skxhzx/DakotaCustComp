      *===================================================================
      *
      *  Name .......... ORDDM3_FDI
      *  Description ... Order Detail Misc. Field 3 - Finkle
      *  Created by .... Jeffrey Jahnke
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   02/10/09  JCJ  5.20
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm3_fdi      ds

     D  fdidm3_base                  40
     D*                                    text('Detail Misc 3 Field')

     D  fdidm3_srp                    7P 2 overlay(fdidm3_base:1)
     D*                                    text('Item SRP')

     D  fdidm3_pck                    4S 0 overlay(fdidm3_base:5)
     D*                                    text('Item Pack SRP')
