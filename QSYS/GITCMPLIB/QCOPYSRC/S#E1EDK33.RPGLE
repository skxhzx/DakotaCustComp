      *===================================================================
      *
      *  Name .......... S#E1EDK33
      *  Description ... SAP IDoc Shipment Stage
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
      *
      *===================================================================

     D s#e1edk33       ds

     Dsap_e1edk33                    10    inz('E2EDK33001')
     D*                                    text('SAP Segment')
     Dsap_e1edk33fill                53
     D*                                    text('Filler Field 01')
     D sap_tsnum                      4
     D*                                    text('Stage of Trans Num')
     D*
