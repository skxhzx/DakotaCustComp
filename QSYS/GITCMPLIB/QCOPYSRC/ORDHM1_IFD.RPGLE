      *===================================================================
      *
      *  Name .......... ORDHM1_IFD
      *  Description ... Order Header Misc. Field 1 - IFD
      *  Created by .... Jeffrey Jahnke
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   01/12/09  JCJ  5.20
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ordhm1_ifd      ds

     D  ifdhm1_base                  40
     D*                                    text('Header Misc 1 Field')
     D  ifdhm1_opfcub                 5  2 overlay(ifdhm1_base:1)
     D*                                    text('Maximum cube per pallet')
