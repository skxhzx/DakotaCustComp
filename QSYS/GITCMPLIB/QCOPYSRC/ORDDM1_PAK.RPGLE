      *===================================================================
      *
      *  Name .......... ORDDM1_Pak
      *  Description ... Order Detail Misc. Field 1 - Packer's
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   09/07/06  MLB  5.10
      *     - Created.
      *
510 A *   03/22/07  HNK  5.10a
      *     - Add LSN number field for federal account pick labels.
510bA *   12/29/07  MLB  5.10b
      *     - Enh: Added ber field for federal account pick labels.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm1_pak      ds

     D  pakdm1_base                  40
     D*                                    text('Detail Misc 1 Field')

     D  pakdm1_dstpln                 4    overlay(pakdm1_base:1)
     D*                                    text('Destination Plant')

     D  pakdm1_dststg                 4    overlay(pakdm1_base:5)
     D*                                    text('Destination Storage')

     D  pakdm1_uom                    2    overlay(pakdm1_base:9)
     D*                                    text('Unit of Measure')

     D  pakdm1_lsn                   13    overlay(pakdm1_base:11)
     D*                                    text('LSN number')

     D  pakdm1_lot                    1    overlay(pakdm1_base:24)
     D*                                    text('Capture Lot Code Y/N')

