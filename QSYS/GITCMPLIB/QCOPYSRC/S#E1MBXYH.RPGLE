      *===================================================================
      *
      *  Name .......... S#E1MBXYH
      *  Description ... SAP Goods Movement Header
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   07/06/06  MLB  5.10
      *     - Created.
510cA *   09/29/06  HNK  5.10c
      *     - Enh: Added new filler fields, Segment, Name of table,
      *            Seq number.
510dA *   10/05/06  HNK  5.10d
      *     - Enh: Change filler to 9. Per Nato.
510eA *   12/04/06  HNK  5.10e
      *     - Enh: Add new filler.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D s#e1mbxyh       ds

510cMD  sap_segxyh                   30    inz('E2MBXYH002')
     D*                                    text('SAP Segment')
510cAD  sap_XYHmand                   3
510cAD*                                    text('Client ID')
510cAD  sap_XYHfil01                 15
510cAD*                                    text('Filler Field 01')
510cAD  sap_Xyhsegnum                 7    inz('E1MBXYH')
510cAD*                                    text('Name of table structure')
510cAD  sap_Xyhpsgnum                 5
510aAD*                                    text('Seq #')
510eAD  sap_XYHfil01a                 1
510eAD*                                    text('Filler')
510cAD  sap_XYHhlevel                 2    inz(' 1')
510cAD*                                    text('Hierarchy Level')
510eMD  sap_bldat                     8
510eMD*                                    text('Date YYYYMMDD')
510eDD* sap_XYHfil02                  9
510eDD*                                    text('Filler Field 02')
     D  sap_budat                     8
     D*                                    text('Date YYYYMMDD')
510cAD  sap_XYHfil03                 67
510cAD*                                    text('Filler Field 03')
     D  sap_tcode                    20    inz('MIGO')
     D*                                    text('ABAP Prog Current TCode')
     D  sap_usnam                    12
     D*                                    text('User Name/User ID')
