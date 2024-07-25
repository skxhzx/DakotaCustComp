      *===================================================================
      *
      *  Name .......... S#E1EDT20
      *  Description ... SAP General Header data
      *  Created by .... Rod Roller
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   03/08/12  RTR  6.40
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D s#e1edt20       ds

     D sap_e1edt20                   10    inz('E2EDT20001')
     D*                                    text('SAP Segment')
     D sap_e1edt20fil                53
     D*                                    text('Filler Field 01')
     D sap_tknum                     10
     D*                                    text('Shipment Number')
     D sap_shtyp                      4
     D*                                    text('Shipment Type')
     D sap_abfer                      1
     D*                                    text('Shipment Completion')
     D sap_abwst                      1
     D*                                    text('Processing Control')
     D sap_bfart                      1
     D*                                    text('Service Level')
     D sap_vsart                      2
     D*                                    text('Shipping Type')
     D sap_laufk                      1
     D*                                    text('Leg Indicator')
     D sap_vsbed                      2
     D*                                    text('Shipping Conditions')
     D sap_route                      6
     D*                                    text('Shipment Route')
     D sap_signi                     20
     D*                                    text('Container ID')
     D sap_exti1                     20
     D*                                    text('External Id 1')
     D sap_exti2                     20
     D*                                    text('External Id 2')
     D sap_tpbez                     20
     D*                                    text('Desc of Shipment')
     D sap_sttrg                      1
     D*                                    text('Overall Trans Status')
     D sap_pkstk                      1
     D*                                    text('Ship Cntns Hndl Sts')
     D sap_dtmeg                      3
     D*                                    text('UoW for Trans Planning')
     D sap_dtmev                      3
     D*                                    text('Vol Unit for Trans Planning')
     D sap_distz                     15
     D*                                    text('Distance')
     D sap_medst                      3
     D*                                    text('UoM for Distance')
     D sap_fahzt                      7
     D*                                    text('Travel Time Btw Two Locs')
     D sap_geszt                      7
     D*                                    text('Total Travel Time Two Locs')
     D sap_meizt                      3
     D*                                    text('UoM for Travel Times')
     D sap_fbsta                      1
     D*                                    text('Stat of Ship Cost Calc')
     D sap_fbgst                      1
     D*                                    text('Overall Stat of Ship Cost')
     D sap_arsta                      1
     D*                                    text('Stat of ship Cost Stlmnt')
     D sap_argst                      1
     D*                                    text('Total Stat of Cost Stlmnt')
     D sap_sterm_done                 1
     D*                                    text('Leg Determination Compl')
     D sap_vse_frk                    1
     D*                                    text('Handling Unit Data Referred')
     D sap_kkalsm                     6
     D*                                    text('Pricing Proc in Shp Hdr')
     D sap_sdabw                      4
     D*                                    text('Special Proc Indicator')
     D sap_frkrl                      1
     D*                                    text('Ship Costs Relevance')
     D sap_gesztd                    12
     D*                                    text('Planned Time of Transp')
     D sap_fahztd                    12
     D*                                    text('Planned Dur of Transp')
     D sap_gesztda                   12
     D*                                    text('Act Time of Shipment')
     D sap_fahztda                   12
     D*                                    text('Act Time for Transp')
     D sap_warztd                    12
     D*                                    text('Plan Wait Time of Ship')
     D sap_warztda                   12
     D*                                    text('Curr Wait Time of Ship')
     D*
