      *===================================================================
      *
      *  Name .......... S#E1EDL24
      *  Description ... SAP Delivery Detail
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   07/06/06  MLB  5.10
      *     - Created.
510aA *   09/27/06  MLB  5.10a
      *     - Enh: Removed 'LB' default from sap_gewei.
510bA *   09/28/06  MLB  5.10b
      *     - Enh: Added new filler fields.
510cA *   09/28/06  MLB  5.10b
      *     - Enh: Added new field for Gross weight BRGEW.
      *            Remove GEWEI
510dA *   09/29/06  HNK  5.10d
      *     - Enh: Added new fields SEGNUM, PSGNUM, HLEVEL and Fillers
      *            changed.
510eM *   12/06/06  HNK  5.10e
      *     - Enh: Changed filler length.
510fM *   02/02/07  HNK  5.10f
      *     - Enh: Add GEWEI field.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D s#e1edl24       ds

510dMD  sap_L24seg                   30    inz('E2EDL24004')
510dDD**sap_L24seg                   10    inz('E1EDL24  ')
510dMD*                                    text('SAP Segment - Child')
510bAD  sap_L24mand                   3
510bAD*                                    text('Client ID')
510dAD  sap_L24fil01                 15
510dAD*                                    text('Filler Field 01')
510dAD  sap_L24segnum                 7    inz('E1EDL24')
510dAD*                                    text('Name of table structure')
510dAD  sap_L24psgnum                 5
510dAD*                                    text('Seq #')
510dAD  sap_L24hlevel                 2    inz(' 3')
510dAD*                                    text('Hierarchy Level')
     D  sap_posnr                     6
     D*                                    text('Item Number')
     D  sap_matnr                    18
     D*                                    text('Material Number')
510eMD  sap_L24fil02                117
510eMD**sap_L24fil02                116
510dMD*                                    text('Filler Field 02')
     D  sap_lgort                     4
     D*                                    text('Storage Location')
     D  sap_charg                    10
     D*                                    text('Batch Number')
510eMD  sap_L24fil03                 21
510eMD**sap_L24fil03                 22
510dMD*                                    text('Filler Field 03')
     D  sap_lfimg                    15
     D*                                    text('Actual Qty Delivered')
510dMD  sap_L24fil04                  1
510dMD*                                    text('Filler Field 04')
     D  sap_vrkme                     3
     D*                                    text('Sales Unit')
     D  sap_lgmng                    15
     D*                                    text('Actual Qty In-Stock Keeping')
     D  sap_meins                     3
     D*                                    text('Base Unit of Measure')
     D  sap_ntgew                    15
     D*                                    text('Net Weight w/decimal(99.99)')
510aDD* sap_gewei                     3    inz('LB ')
510bDD* sap_gewei                     3
     D*                                    text('Weight Unit')
510b D  sap_brgew                    15
     D*                                    text('Gross Weight w/decimal(99.99)')
510f D  sap_gewei                     3    inz('   ')
510f D*                                    text('Weight UOM')
