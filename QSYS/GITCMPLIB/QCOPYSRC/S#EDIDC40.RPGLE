      *===================================================================
      *
      *  Name .......... S#EDI_DC40
      *  Description ... SAP Control Record
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   07/05/06  MLB  5.10
      *     - Created.
510aA *   09/27/06  MLB  5.10a
      *     - Enh: Changed MESTYP to ZDESADV from DESADV.
510bA *   09/27/06  MLB  5.10b
      *     - Enh: Added new fields, fillers to segment layout.
510cA *   09/28/06  HNK  5.10c
      *     - Enh: Added new fields, fillers to segment layout.
510dA *   11/30/06  HNK  5.10d
      *     - Enh: Change default values.
510eA *   12/03/06  HNK  5.10e
      *     - Enh: Change idoc and message type to blanks.  This value
      *            is set in the respective program.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D s#edi_dc40      ds

510bMD  sap_segdc40                  10    inz('EDI_DC40  ')
     D*                                    text('SAP Segment')
     D  sap_mand                      3
     D*                                    text('Client ID')
     D  sap_docnum                   16
     D*                                    text('IDoc Number')
510cMD  sap_docrel                    4    inz('640 ')
510bAD*                                    text('IDoc Release')
     D  sap_status                    2    inz('64')
     D*                                    text('IDoc Status')
510c D  sap_direct                    1
510c D*                                    text('Direction 2=In, 1=Out)
510cAD  sap_filler01                  3
510cAD*                                    text('Filler Field 01')
510eMD  sap_idoctyp                  30    inz('        ')
     D*                                    text('IDoc Type')
510cAD  sap_filler02                 30
510cAD*                                    text('Filler Field 02')
510eMD  sap_mestype                  30    inz('      ')
     D*                                    text('Message Type')
510cMD  sap_filler03                 19
510bAD*                                    text('Filler Field 03')
     D  sap_sndport                  10
     D*                                    text('Sender Port')
     D  sap_sndpart                   2    inz('LS')
     D*                                    text('Partner Type of Sender')
510cAD  sap_filler04                  2
510cAD*                                    text('Filler Field 04')
     D  sap_sndprn                   10
     D*                                    text('Partner Number of Sender')
510cMD  sap_filler05                 91
510cMD*                                    text('Filler Field 05')
     D  sap_rcvport                  10
     D*                                    text('Receiving Port')
     D  sap_rcvpart                   2    inz('LS')
     D*                                    text('Partner Type of Receiver')
510cAD  sap_filler06                  2
510cAD*                                    text('Filler Field 05')
     D  sap_rcvprn                   10
     D*                                    text('Partner Number of Receiver')
510cMD  sap_filler07                 91
510cMD*                                    text('Filler Field 07')
     D  sap_crtdate                   8
     D*                                    text('Creation Date YYYYMMDD')
