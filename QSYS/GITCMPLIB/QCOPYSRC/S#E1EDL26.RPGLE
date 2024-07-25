      *===================================================================
      *
      *  Name .......... S#E1EDL26
      *  Description ... SAP Delivery Detail Additional Data
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   07/06/06  MLB  5.10
      *     - Created.
510bA *   09/28/06  MLB  5.10b
      *     - Enh: Added new filler fields.
510cA *   09/29/06  HNK  5.10c
      *     - Enh: Added new fields SEGNUM, PSGNUM, HLEVEL and Fillers
      *            changed.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D s#e1edl26       ds

510cMD  sap_L26seg                   30    inz('E2EDL26005')
510cDD**sap_L26seg                   10    inz('E1EDL26  ')
     D*                                    text('SAP Segment - Child')
510cAD  sap_L26mand                   3
510cAD*                                    text('Client ID')
510cAD  sap_L26fil01                 15
510cAD*                                    text('Filler Field 01')
510cAD  sap_L26segnum                 7    inz('E1EDL26')
510cAD*                                    text('Name of table structure')
510cAD  sap_L26psgnum                 5
510cAD*                                    text('Seq #')
510cAD  sap_L26hlevel                 2    inz(' 4')
510cAD*                                    text('Hierarchy Level')
510cMD  sap_L26fil02                 55
510cMD*                                    text('Filler Field 02')
     D  sap_chspl                     1    inz('X')
     D*                                    text('Batch Split Allowed')
510cDD**sap_xchbw                     1
510cDD*                                    text('Batch Split Allowed')
510cDD**sap_koqui                     1
     D*                                    text('Picking is Subject to Confirm')
