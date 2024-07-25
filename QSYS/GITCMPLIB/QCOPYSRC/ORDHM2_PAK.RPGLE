      *===================================================================
      *
      *  Name .......... ORDHM2_PAK
      *  Description ... Order Header Misc. Field 2 - Packer's
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   09/07/06  MLB  5.10
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ordhm2_pak      ds

     D  pakhm2_base                  40
     D*                                    text('Header Misc 2 Field')

     D  pakhm2_dstshp                 4    overlay(pakhm2_base:1)
     D*                                    text('Destination Shipping Point')
