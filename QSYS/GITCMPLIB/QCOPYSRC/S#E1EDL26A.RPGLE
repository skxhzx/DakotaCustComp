      *===================================================================
      *
      *  Name .......... S#E1EDL26
      *  Description ... SAP IDoc Delivery Item Addl Data Descriptions
      *  Created by .... Rod Roller
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   04/17/12  RTR  6.40
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D s#e1edl26a      ds

     Dsap_e1edl26                    10    inz('E2EDL26002')
     D*                                    text('SAP Segment')
     Dsap_e1edl26fill                53
     D*                                    text('Filler Field 01')
     Dsap_pstyv                       4
     D*                                    text('Sales doc item cat')
     Dsap_matkl26                     9
     D*                                    text('Material Group')
     Dsap_prodh                      18
     D*                                    text('Product heirarchy')
     Dsap_umvkz                       6
     D*                                    text('Numerator for sales qty')
     Dsap_umvkn                       6
     D*                                    text('Denominator for sales qty')
     D*
