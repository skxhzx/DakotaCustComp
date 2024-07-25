      *===================================================================
      *
      *  Name .......... S#E1EDT18
      *  Description ... SAP IDoc Control (Shipment)
      *  Created by .... Rod Roller
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   03/12/12  RTR  6.40
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D s#e1edt18       ds

     D sap_e1edt18                   10    inz('E2EDT18   ')
     D*                                    text('SAP Segment')
     D sap_e1edt18fil                53
     D*                                    text('Filler Field 01')
     D sap_qualf                      3
     D*                                    text('Qualifier Control Ship')
     D sap_param                     20
     D*                                    text('Qualifier Control Params')
     D*
