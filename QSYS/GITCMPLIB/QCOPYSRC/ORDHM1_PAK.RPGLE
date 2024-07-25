      *===================================================================
      *
      *  Name .......... ORDHM1_Pak
      *  Description ... Order Header Misc. Field 1 - Packer's
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

     D ordhm1_pak      ds

     D  pakhm1_base                  40
     D*                                    text('Header Misc 1 Field')

     D  pakhm1_plant                  4    overlay(pakhm1_base:1)
     D*                                    text('Plant Number')

     D  pakhm1_vblen                  9    overlay(pakhm1_base:5)
     D*                                    text('Delivery Number')

     D  pakhm1_slsshp                11    overlay(pakhm1_base:14)
     D*                                    text('Sales Org+Ship Number')

     D  pakhm1_slsorg                 4    overlay(pakhm1_base:25)
     D*                                    text('Sales Organization')

     D  pakhm1_dstpln                 4    overlay(pakhm1_base:29)
     D*                                    text('Destination Plant')

     D  pakhm1_dlvryt                 4    overlay(pakhm1_base:33)
     D*                                    text('Delivery Type')

     D  pakhm1_dststg                 4    overlay(pakhm1_base:37)
     D*                                    text('Destination Storage')
