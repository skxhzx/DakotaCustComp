      *===================================================================
      *
      *  Name .......... S#E1EDK01
      *  Description ... SAP General Header data
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

     D s#e1edk01       ds

     D  sap_K01seg                   30    inz('E1EDK01005')
     D*                                    text('SAP Segment')
     D  sap_K01mand                   3
     D*                                    text('Client ID')
     D  sap_K01fil01                 15
     D*                                    text('Filler Field 01')
     D  sap_K01segnum                 7    inz('E1EDK01')
     D*                                    text('Name of table structure')
     D  sap_K01psgnum                 5
     D*                                    text('Seq #')
     D  sap_K01hlevel                 2    inz(' 1')
     D*                                    text('Hierarchy Level')
     D  sap_K01fil02                  3
     D*                                    text('Filler Field 02')
     D  sap_kzabs                     1
     D*                                    text('Order Acknowledgement Req
     D*                                    uired.')
     D  sap_K01fil03                 18
     D*                                    text('Filler Field 03')
     D  sap_zterm                    17
     D*                                    text('Document Number')
     D  sap_K01fil04                 40
     D*                                    text('Filler Field 04')
     D  sap_bsart                     4
     D*                                    text('Document Type ZRTN, ZRTO'
     D*                                    )
     D  sap_belnr                    35
     D*                                    text('IDoc Number')
     D  sap_K01fil05                 72
     D*                                    text('Filler Field 05')
     D  sap_vsart                     2
     D*                                    text('Shipping Conditions')
     D  sap_K01fil06                 32
     D*                                    text('Filler Field 06')
     D  sap_augru                     3
     D*                                    text('Order Reason')
