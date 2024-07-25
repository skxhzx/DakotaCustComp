      *===================================================================
      *
      *  Name .......... S#E1EDL24
      *  Description ... SAP IDoc Delivery Item
      *  Created by .... Rod Roller
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   03/14/12  RTR  6.40
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *   This version of E1EDL20 was created to map the Agar SAP Input
      *   format which is slightly different than other versions used for
      *   exports.
      *
      *===================================================================

     Ds#e1edl24a       ds

     Dsap_e1edl24                    10    inz('E2EDL24007')
     D*                                    text('SAP Segment')
     Dsap_e1edl24fill                53
     D*                                    text('Filler Field 01')
     D sap_posnr                      6
     D*                                    text('Item Number')
     D sap_matnr                     18
     D*                                    text('Material Number')
     D sap_matwa                     18
     D*                                    text('Material Entered')
     D sap_arktx                     40
     D*                                    text('Text for Item')
     D sap_orktx                     40
     D*                                    text('Desc of Material')
     D sap_sugrd                      4
     D*                                    text('Reason for Substitution')
     D sap_sudru                      1
     D*                                    text('Orig Entry Printed')
     D sap_matkl                      9
     D*                                    text('Material Group')
     D sap_werks                      4
     D*                                    text('Plant')
     D sap_lgort                      4
     D*                                    text('Storage Location')
     D sap_charg                     10
     D*                                    text('Batch Number')
     D sap_kdmat                     22
     D*                                    text('Mat Belong Cust')
     D sap_lfimg                     15
     D*                                    text('Act Quan Delivered')
     D sap_vrkme                      3
     D*                                    text('Sales Unit')
     D sap_lgmng                     15
     D*                                    text('Quan Del Stock Units')
     D sap_meins                      3
     D*                                    text('Base UoM')
     D sap_ntgew                     15
     D*                                    text('Net Weight')
     D sap_brgew                     15
     D*                                    text('Gross Weight')
     D sap_gewei                      3
     D*                                    text('Weight Unit')
     D sap_volum                     15
     D*                                    text('Volume')
     D sap_voleh                      3
     D*                                    text('Volume Unit')
     D sap_lgpbe                     10
     D*                                    text('Storage Bin')
     D sap_hipos                      6
     D*                                    text('Superior Item Hier')
     D sap_hievw                      1
     D*                                    text('Use of Hierarchy Item')
     D sap_ladgr                      4
     D*                                    text('Loading Group')
     D sap_tragr                      4
     D*                                    text('Transportation Group')
     D sap_vkgrp                      3
     D*                                    text('Sales Group')
     D sap_vtweg                      2
     D*                                    text('Distribution Channel')
     D sap_spart                      2
     D*                                    text('Division')
     D sap_grkor                      3
     D*                                    text('Delivery Group')
     D sap_ean11                     18
     D*                                    text('International Art Num')
     D sap_sernr                      8
     D*                                    text('BOM Explosion Number')
     D sap_aeskd                     17
     D*                                    text('Cust Eng Chg Status')
     D sap_empst                     25
     D*                                    text('Receiving Point')
     D sap_mfrgr                      8
     D*                                    text('Material Freight Grp')
     D sap_vbrst                     14
     D*                                    text('Cust Point of Consump')
     D sap_labnk                     17
     D*                                    text('Cust Num Forecast')
     D sap_abrdt                      8
     D*                                    text('Delivery Schedule Date')
     D sap_mfrpn                     40
     D*                                    text('Manuf Part Number')
     D sap_mfrnr                     10
     D*                                    text('Number of Manuf')
     D sap_abrvw                      3
     D*                                    text('Usage Indicator')
     D sap_kdmat35                   35
     D*                                    text('Material Belong Cust')
     D sap_kannr                     35
     D*                                    text('Kanban Seq Num')
     D sap_posex                      6
     D*                                    text('Ext Item Num')
     D sap_lieffz                    17
     D*                                    text('Cum Qty for Del')
     D sap_usr01                     35
     D*                                    text('Addl Data 1')
     D sap_usr02                     35
     D*                                    text('Addl Data 2')
     D sap_usr03                     35
     D*                                    text('Addl Data 3')
     D sap_usr04                     10
     D*                                    text('Addl Data 4')
     D sap_usr05                     10
     D*                                    text('Addl Data 5')
     D sap_matnr_exte                40
     D*                                    text('Material Number')
     D sap_matnr_vers                10
     D*                                    text('Version Number')
     D sap_matnr_guid                32
     D*                                    text('Ext GUID')
     D sap_matwa_exte                40
     D*                                    text('Material Ent')
     D sap_matwa_vers                10
     D*                                    text('Version Number')
     D sap_matwa_guid                32
     D*                                    text('Ext GUID')
     D sap_zudat                     20
     D*                                    text('Addl Data')
     D sap_vfdat                      8
     D*                                    text('Shelf Life Exp')
     D sap_rma_number                20
     D*                                    text('Ret Mat Auth')
     D sap_rma_comple                 1
     D*                                    text('RMA Comp Ind')
     D sap_expiry_d24                16
     D*                                    text('End of Date Valid')
     D sap_vgbel                     10
     D*                                    text('Doc Num Ref Doc')
     D sap_vgpos                      6
     D*                                    text('Item NUm Ref Item')
     D sap_follow_up                  7
     D*                                    text('Follow Up Code')
     D sap_ormng                     15
     D*                                    text('Orig Qty Del Item')
     D sap_compl                      1
     D*                                    text('Closing Ind')
     D sap_hold                       1
     D*                                    text('Inb Del Item')
     D sap_max_err                    1
     D*                                    text('Max Err Type')
     D sap_lichn                     15
     D*                                    text('Vend Batch Num')
     D sap_recipient                  1
     D*                                    text('Created by Receip')
     D sap_expiry_dat                16
     D*                                    text('Beg Date of valid')
     D*
