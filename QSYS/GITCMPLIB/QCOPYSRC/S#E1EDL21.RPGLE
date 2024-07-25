      *===================================================================
      *
      *  Name .......... S#E1EDL21
      *  Description ... SAP Delivery Header Additional Data
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   07/06/06  MLB  5.10
      *     - Created.
510aA *   09/27/06  MLB  5.10a
      *     - Enh: Added new field to segment, TRSPG.
510bA *   09/28/06  MLB  5.10b
      *     - Enh: Added new filler fields.
510cA *   09/28/06  MLB  5.10c
      *     - Enh: Added new field MAND
510dA *   09/29/06  HNK  5.10d
      *     - Enh: Added new fields SEGNUM, PSGNUM, HLEVEL and Fillers
      *            changed.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D s#e1edl21       ds

510dMD  sap_L21seg                   30    inz('E2EDL21003')
510dMD**sap_L21seg                   10    inz('E1EDL21  ')
510bMD*                                    text('SAP Segment - Child')
510cAD  sap_L21mand                   3
510cAD*                                    text('Client ID')
510dAD  sap_L21fil01                 15
510dAD*                                    text('Filler Field 01')
510dAD  sap_L21segnum                 7    inz('E1EDL21')
510dAD*                                    text('Name of table structure')
510dAD  sap_L21psgnum                 5
510dAD*                                    text('Seq #')
510dAD  sap_L21hlevel                 2    inz(' 2')
510dAD*                                    text('Hierarchy Level')
510dAD  sap_L21fil02                  1
510dAD*                                    text('Filler Field 02')
     D  sap_lfart                     4
     D*                                    text('Delivery Type')
510dDD**sap_trspg                     2
510dDD*                                    text('Shipment Blocking Reason')
