      *===================================================================
      *
      *  Name .......... ORDDM1_CSP
      *  Description ... Order Detail Misc. Field 1 - Coastal Sunbelt
      *                  Produce.
      *  Created by .... Jeffrey Jahnke
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   11/01/11  JCJ  6.40
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm1_csp      ds

     D  cspdm1_base                  40
     D*                                    text('Detail Misc 1 Field')

     Dcspdm1_upc                     17    overlay(cspdm1_base:1)
     D*                                    text('Customer UPC code')
