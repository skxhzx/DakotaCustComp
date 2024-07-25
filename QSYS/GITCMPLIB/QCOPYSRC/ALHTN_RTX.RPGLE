      *===================================================================
      *
      *  Name .......... ALHTN_RTX
      *  Description ... Host Tracking Number - Retalix Pwr Whse
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   11/14/11  MLB  6.40
      *     - Created.
640aA *   12/07/11  MLB  6.40a
      *     - Enh: Added new field to ALHTN field for S/O Line Selection
      *       zone. To be used as LBWHDP in LABEL file.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D alhtn_rtx       ds

     D  rtxhtn_base                  40
     D*                                    text('Host Tracking Number Field')

     Drtx_aluow                       9    overlay(rtxhtn_base:1)
     D*                                    text('Full Retalix Unit of Work')
     Drtx_alcid                       9    overlay(rtxhtn_base:10)
     D*                                    text('Retalix Carton ID')
     Drtx_allbl                       3    overlay(rtxhtn_base:19)
     D*                                    text('Retalix Label Nbr')
     Drtx_alsobo                      3    overlay(rtxhtn_base:22)
     D*                                    text('Retalix S/O Backorder Nbr')
     Drtx_alsz                        2    overlay(rtxhtn_base:25)
     D*                                    text('Retalix S/O Selection Zone')
