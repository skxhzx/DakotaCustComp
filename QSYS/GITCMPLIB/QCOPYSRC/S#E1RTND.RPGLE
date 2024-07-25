      *===================================================================
      *
      *  Name .......... S#E1RTND
      *  Description ... SAP Customer Returns Detail
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   02/06/07  MLB  5.10
      *     - Created.
      *
740 A *   08/10/20  MLB  7.40
      *     - Added new field for total catchweight. Needed as part of
      *       Dakota WMS v7.30 upgrade.
740aA *   10/07/20  MLB  7.40a
      *     - Added 2 new fields for BFC return code and disposition code.
      *       Per Ed email dated 10.06.2020.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D s#e1rtnd        ds

     D  sap_segrtnd                   1    inz('D')
     D*                                    text('SAP Segment Detail')
     D  sap_itemnbr                   6
     D*                                    text('SAP Item Number')
     D  sap_matnr                    18
     D*                                    text('SAP Material Number')
     D  sap_rtnqty                   17
     D*                                    text('SAP Return Quantity')
     D  sap_uom                       3
     D*                                    text('SAP Unit of Measure')
     D  sap_partrole                  2    inz('AG')
     D*                                    text('SAP Partner Role')
     D  sap_partnbr                  10
     D*                                    text('SAP Partner Number - Cust#')
     D  sap_charg                    10
     D*                                    text('SAP Batch Number')
     D  sap_rtncode                   3
     D*                                    text('SAP Return Code')
740 AD  sap_rtnwgt                   17
740 AD*                                    text('SAP Return Weight')
740aAD  bfc_rtncode                   2
740aAD*                                    text('BFC Return Code')
740aAD  bfc_dspcode                   5
740aAD*                                    text('BFC Disposition Code')
