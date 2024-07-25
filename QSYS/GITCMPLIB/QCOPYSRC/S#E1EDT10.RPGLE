      *===================================================================
      *
      *  Name .......... S#E1EDT10
      *  Description ... SAP IDoc Date (Shipment)
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

     D s#e1edt10       ds

     Dsap_e1edt10                    10    inz('E2EDT10001')
     D*                                    text('SAP Segment')
     Dsap_e1edt10fill                53
     D*                                    text('Filler Field 01')
     Dsap_qualf_edt10                 3
     D*                                    text('Ship Qualifier')
     Dsap_e1edt10fil2                24
     D*                                    text('Filler Field 02')
     Dsap_ntanf                       8
     D*                                    text('Const for Act Start')
     D*
