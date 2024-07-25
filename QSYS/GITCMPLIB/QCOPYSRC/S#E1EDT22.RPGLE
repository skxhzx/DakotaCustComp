      *===================================================================
      *
      *  Name .......... S#E1EDT22
      *  Description ... SAP IDoc Shipment Descriptions
      *  Created by .... Rod Roller
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   03/09/12  RTR  6.40
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D s#e1edt22       ds

     Dsap_e1edt22                    10    inz('E2EDT22000')
     D*                                    text('SAP Segment')
     Dsap_e1edt22fill                53
     D*                                    text('Filler Field 01')
     D  sap_shtyp_bez                20
     D*                                    text('Description')
     D  sap_bfart_bez                20
     D*                                    text('Description')
     D  sap_vsart_bez                20
     D*                                    text('Desc. of Shipping Type')
     D  sap_laufk_bez                20
     D*                                    text('Description')
     D  sap_vsbez_bez                20
     D*                                    text('Description')
     D  sap_route_bez                40
     D*                                    text('Description')
     D  sap_sttrg_bez                20
     D*                                    text('Description')
     D  sap_fbsta_bez                25
     D*                                    text('Desc. stat calc cost')
     D  sap_bfgst_bez                25
     D*                                    text('Overall stat calc cost')
     D  sap_arsta_bez                25
     D*                                    text('Desc. stat cost settle')
     D  sap_argst_bez                25
     D*                                    text('Desc. overall cost settle')
     D*
