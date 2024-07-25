      *===================================================================
      *
      *  Name .......... S#E1EDK02
      *  Description ... SAP Handling Unit Item Delivery
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

     D s#e1edk02       ds

     D  sap_K02seg                   30    inz('E1EDK02')
     D*                                    text('SAP Segment')
     D  sap_K02mand                   3
     D*                                    text('Client ID')
     D  sap_K02fil01                 15
     D*                                    text('Filler Field 01')
     D  sap_K02segnum                 7    inz('E1EDK02')
     D*                                    text('Name of table structure')
     D  sap_K02psgnum                 5
     D*                                    text('Seq #')
     D  sap_K02hlevel                 2    inz(' 2')
     D*                                    text('Hierarchy Level')
     D  sap_K02qual                   3    inz('66')
     D*                                    text('Qualifier Reference Doc')
     D  sap_K02belnr                 35
     D*                                    text('IDoc Number')
