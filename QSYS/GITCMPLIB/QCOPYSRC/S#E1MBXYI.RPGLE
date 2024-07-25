      *===================================================================
      *
      *  Name .......... S#E1MBXYI
      *  Description ... SAP Goods Movement Detail
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   07/06/06  MLB  5.10
      *     - Created.
510aA *   09/30/06  HNK  5.10a
      *     - Enh: Added new filler fields, Segment, Name of table,
      *            Seq number.
510bA *   10/05/06  HNK  5.10b
      *     - Enh: Changed filler to 2.
510cA *   10/25/06  MLB  5.10c
      *     - Enh: Revised segment layout per Alex S.
510dA *   12/01/06  HNK  5.10d
      *     - Enh: Add filler
510eA *   12/02/06  HNK  5.10e
      *     - Enh: Add field for CW and UOM
510fA *   12/15/06  MLB  5.10f
      *     - Enh: Add reason code field, two new filler fields.
510gA *   01/22/07  HNK  5.10g
      *     - Enh: Add SGTXT and WBS element per Ernesto email.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D s#e1mbxyi       ds

510aAD  sap_segxyi                   30    inz('E2MBXYI002')
     D*                                    text('SAP Segment - Child')
510aAD  sap_XYImand                   3
510aAD*                                    text('Client ID')
510aAD  sap_XYIfil01                 15
510aAD*                                    text('Filler Field 01')
510aAD  sap_Xyisegnum                 7    inz('E1MBXYI')
510aAD*                                    text('Name of table structure')
510aAD  sap_Xyipsgnum                 5
510aAD*                                    text('Seq #')
510bAD  sap_XYIfil01a                 1
510bAD*                                    text('Filler Field 01a')
510aAD  sap_Xyihlevel                 2    inz(' 2')
510aAD*                                    text('Hierarchy Level')
510bAD  sap_XYIfil02                  1
510bAD*                                    text('Filler Field 02')
     D  sap_xstobi                    1
     D*                                    text('Flag: Reverse Posting')
     D  sap_matnri                   18
     D*                                    text('Material Number')
     D  sap_werksi                    4
     D*                                    text('Plant')
     D  sap_lgorti                    4
     D*                                    text('Storage Location')
     D  sap_chargi                   10
     D*                                    text('Batch Number')
     D  sap_bwarti                    3
     D*                                    text('Movement Type')
     D  sap_insmki                    1
     D*                                    text('Stock Type')
     D  sap_sobkzi                    1
     D*                                    text('Special Stock Indicator')
510aAD  sap_XYIfil03                 42
510aAD*                                    text('Filler Field 03')
510aAD  sap_waers                     5
510aAD*                                    text('Currency Format')
510aAD  sap_dmbtr                    15
510aAD*                                    text('Extended Cost')
510aAD  sap_XYIfil04                 10
510aAD*                                    text('Filler Field 04')
     D  sap_erfmgi                   15
     D*                                    text('Qty in Unit of Entry')
     D  sap_erfmei                    3
     D*                                    text('Unit of Entry')
510e D  sap_bpmngi                   15
510e D*                                    text('Catch Weight')
510e D  sap_bprmei                    3
510e D*                                    text('Unit of Measure')
510e D  sap_XYIfil05                 10
510aAD*                                    text('Filler Field 05')
510g D  sap_ebelp                     5
     D*                                    text('Item Position')
510g D  sap_XYIfil06                  1
510g D**sap_XYIfil06                 89
510aAD*                                    text('Filler Field 06')
510g D  sap_sgtxt                    50
510g D*                                    text('Item Text')
510g D  sap_XYIfil06a                37
510aAD*                                    text('Filler Field 06a')
510g D  sap_kostli                   10
     D*                                    text('Cost Center')
510aAD  sap_XYIfil07                 65
510aAD*                                    text('Filler Field 07')
     D  sap_umlgoi                    4
     D*                                    text('Receiving/Issuing Storage Loc')
     D  sap_umchai                   10
     D*                                    text('Receiving/Issuing Batch')
510aAD  sap_XYIfil08                  2
510aAD*                                    text('Filler Field 08')
     D  sap_lgnumi                    3
     D*                                    text('Warehouse')
510fDD* sap_XYIfil09                 51
510fMD  sap_XYIfil09                 13
510aAD*                                    text('Filler Field 09')
510fAD  sap_rsncodi                   4
510aAD*                                    text('Reason Code')
510fAD  sap_XYIfil10                 34
510aAD*                                    text('Filler Field 10')
     D  sap_prctr                    10
     D*                                    text('Profit Center')
510g D  sap_wbselei                   8
510g D*                                    text('WBS Element')
510gMD  sap_XYIfil11                219
510aAD**sap_XYIfil11                227
510aAD*                                    text('Filler Field 11')
     D  sap_vbelni                   10
     D*                                    text('Delivery Number')
