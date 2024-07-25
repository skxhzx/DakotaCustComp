      *===================================================================
      *
      *  Name .......... S#Z1DELDTA
      *  Description ... SAP Delivery Header (for pick file to Lucas)
      *  Created by .... Rod Roller
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   04/20/12  RTR  6.40
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     Ds#z1deldta       ds

     Dsap_z1deldta                   10    inz('Z2DELIVDAT')
     D*                                    text('SAP Segment')
     Dsap_z1deldtafil                53
     D*                                    text('Filler')
     Dsap_palletstop                  1
     D*                                    text('Pallet Stop Y/N')
     Dsap_delivcust1                 20
     D*                                    text('Delivery Custom 1')
     Dsap_delivcust2                 20
     D*                                    text('Delivery Custom 2')
     Dsap_delivcust3                 20
     D*                                    text('Delivery Custom 3')
     Dsap_delivcust4                 20
     D*                                    text('Delivery Custom 4')
     Dsap_delivcust5                 20
     D*                                    text('Delivery Custom 5')
     D*
