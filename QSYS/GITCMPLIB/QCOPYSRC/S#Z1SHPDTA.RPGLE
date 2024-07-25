      *===================================================================
      *
      *  Name .......... S#Z1SHPDTA
      *  Description ... SAP Shipment Header (for pick file to Lucas)
      *  Created by .... Rod Roller
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   03/20/12  RTR  6.40
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     Ds#z1shpdta       ds

     Dsap_z1shpdta                   10    inz('Z2SHIPDATA')
     D*                                    text('SAP Segment')
     Dsap_z1shpdtafil                53
     D*                                    text('Filler Field 01')
     Dsap_dispatchtim                 6
     D*                                    text('Dispatch Time')
     Dsap_auditpct                    3
     D*                                    text('Audit Percent')
     Dsap_drivercode                 10
     D*                                    text('Driver Code')
     Dsap_drivername                 30
     D*                                    text('Driver Name')
     Dsap_trailernumb                10
     D*                                    text('Trailer Number')
     Dsap_shipcust1                  20
     D*                                    text('Shipment Custom 1')
     Dsap_shipcust2                  20
     D*                                    text('Shipment Custom 2')
     Dsap_shipcust3                  20
     D*                                    text('Shipment Custom 3')
     Dsap_shipcust4                  20
     D*                                    text('Shipment Custom 4')
     Dsap_shipcust5                  20
     D*                                    text('Shipment Custom 5')
     D*
