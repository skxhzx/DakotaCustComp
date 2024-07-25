      *===================================================================
      *
      *  Name .......... S#E1EDL20A
      *  Description ... SAP IDoc Delivery Header - Agar Import
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

     Ds#e1edl20a       ds

     Dsap_e1edl20                    10    inz('E2EDL20003')
     D*                                    text('SAP Segment')
     Dsap_e1edl20fill                53
     D*                                    text('Filler Field 01')
     Dsap_vbeln                      10
     D*                                    text('Sales Dist Doc Num')
     D*
