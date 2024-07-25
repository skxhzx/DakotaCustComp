      *===================================================================
      *
      *  Name .......... S#E1EDL20
      *  Description ... SAP Delivery Header
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   07/06/06  MLB  5.10
      *     - Created.
510aA *   09/27/06  MLB  5.10a
      *     - Enh: Added two new fields, VKORG, ROUTE to segment.
510bA *   09/28/06  MLB  5.10b
      *     - Enh: Added new filler fields.
510cA *   09/29/06  HNK  5.10c
      *     - Enh: Added new filler fields, Segment, Name of table,
      *            Seq number.
510dA *   12/06/06  HNK  5.10d
      *     - Enh: Added new filler fields
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D s#e1edl20       ds

510cMD  sap_L20seg                   30    inz('E2EDL20002')
510bDD**sap_L20seg                   10    inz('E1EDL20  ')
     D*                                    text('SAP Segment')
510bAD  sap_L20mand                   3
510bAD*                                    text('Client ID')
510cAD  sap_L20fil01                 15
510cAD*                                    text('Filler Field 01')
510cAD  sap_L20segnum                 7    inz('E1EDL20')
510cAD*                                    text('Name of table structure')
510cAD  sap_L20psgnum                 5
510cAD*                                    text('Seq #')
510cAD  sap_L20hlevel                 2    inz(' 1')
510cAD*                                    text('Hierarchy Level')
     D  sap_vbeln                    10
     D*                                    text('Document Number')
510dAD  sap_L20fil01a                 1
510dAD*                                    text('Filler Field 01a')
     D  sap_vstel                     4
     D*                                    text('Shipping Point')
510aAD  sap_vkorg                     4
510aAD*                                    text('Sales Organization')
510dMD  sap_L20fil02                 64
510MAD*                                    text('Filler Field 02')
510aAD  sap_route                     6
510aAD*                                    text('Route')
510cMD  sap_L20fil03                200
510cMD*                                    text('Filler Field 03')
     D  sap_podat                     8
     D*                                    text('Date of Delivery YYYYMMDD')
     D  sap_potim                     6
     D*                                    text('Confirmation Time HHMMSS')
