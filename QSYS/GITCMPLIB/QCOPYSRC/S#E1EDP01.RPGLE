      *===================================================================
      *
      *  Name .......... S#E1EDP01
      *  Description ... SAP General Item data
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   10/01/06  MLB  5.10
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D s#e1edp01       ds

     D  sap_P01seg                   30    inz('E1EDP01006')
     D*                                    text('SAP Segment')
     D  sap_P01mand                   3
     D*                                    text('Client ID')
     D  sap_P01fil01                 15
     D*                                    text('Filler Field 01')
     D  sap_P01segnum                 7    inz('E1EDP01')
     D*                                    text('Name of table structure')
     D  sap_P01psgnum                 5
     D*                                    text('Seq #')
     D  sap_P01hlevel                 2    inz(' 1')
     D*                                    text('Hierarchy Level')
     D  sap_posex                     6
     D*                                    text('Item Number')
     D  sap_P01fil02                  3
     D*                                    text('Filler Field 02')
     D  sap_P01kzabs                  1
     D*                                    text('Order Acknowledgement Req
     D*                                    uired.')
     D  sap_menge                    15
     D*                                    text('Quantity')
     D  sap_menee                     3
     D*                                    text('Unit of Measure')
     D  sap_P01fil03                103
     D*                                    text('Filler Field 03')
     D  sap_ntgew                    18
     D*                                    text('Net Weight w/decimal(99.99)')
     D  sap_gewei                     3
     D*                                    text('Weight Unit of Measure')
     D  sap_P01fil04                 59
     D*                                    text('Filler Field 04')
     D  sap_abgru                     2
     D*                                    text('Reason for Rejection')
     D  sap_P01fil05                 43
     D*                                    text('Filler Field 05')
     D  sap_bgrew                    18
     D*                                    text('Gross Weight w/decimal(99.99)')
     D  sap_P01fil06                 36
     D*                                    text('Filler Field 06')
     D  sap_werks                     4
     D*                                    text('Plant')
     D  sap_P01fil07                 22
     D*                                    text('Filler Field 07')
     D  sap_route                     6
     D*                                    text('Route')
     D  sap_P01fil08                 40
     D*                                    text('Filler Field 08')
     D  sap_lgort                     4
     D*                                    text('Storage Location')
     D  sap_P01fil09                  7
     D*                                    text('Filler Field 09')
     D  sap_matnr                    35
     D*                                    text('Material Number')
