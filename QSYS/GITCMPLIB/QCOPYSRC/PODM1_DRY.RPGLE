      *===================================================================
      *
      *  Name .......... PODM1_DRY
      *  Description ... P/O Detail Misc. Field 1 - Dairyland Interface
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
650 A *   08/28/13  MLB  6.50
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D podm1_dry       ds

     D  drydm1_base                  40
     D*                                    text('Detail Misc 1 Field')
     D  drydm1_soxid                  8    overlay(drydm1_base:1)
     D*                                    text('SOX Batch Identifier')
     D  drydm1_shpwgt                 7    overlay(drydm1_base:9)
     D*                                    text('Host Item Ship Weight')
