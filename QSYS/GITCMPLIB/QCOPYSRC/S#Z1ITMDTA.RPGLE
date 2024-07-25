      *===================================================================
      *
      *  Name .......... S#Z1ITMDTA
      *  Description ... SAP Delivery Item (for pick file to Lucas)
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

     Ds#z1itmdta       ds

     Dsap_z1itmdta                   10    inz('Z2ITEMDATA')
     D*                                    text('SAP Segment')
     Dsap_z1itmdtafil                53
     D*                                    text('Filler Field 01')
     Dsap_picksection                15
     D*                                    text('Pick Section')
     Dsap_itemcube                    5
     D*                                    text('Item Cube')
     Dsap_catchwgtflg                 1
     D*                                    text('Catchweight Flag')
     Dsap_enfcatchwgt                 1
     D*                                    text('Enforce Catchweight')
     Dsap_pctabswgtfl                 1
     D*                                    text('Pct Abs Weight Flag')
     Dsap_minweight                   8
     D*                                    text('Min Weight')
     Dsap_maxweight                   8
     D*                                    text('Max Weight')
     Dsap_absminwgt                   8
     D*                                    text('Abs Min Weight')
     Dsap_absmaxwgt                   8
     D*                                    text('Abs Max Weight')
     Dsap_avgwgt                      8
     D*                                    text('Avg Weight')
     Dsap_expdatflg                   1
     D*                                    text('Exp Date Flag')
     Dsap_enfexpdat                   1
     D*                                    text('Enf Exp Date Flg')
     Dsap_expdatfmt                   1
     D*                                    text('Exp Date Format')
     Dsap_daystoexp                   3
     D*                                    text('Days To Expiration')
     Dsap_upcflag                     1
     D*                                    text('UPC Flag')
     Dsap_upcchkfrq                   4
     D*                                    text('UPC Chk Freq')
     Dsap_itemprice                   9
     D*                                    text('Item Price')
     Dsap_upc1                       20
     D*                                    text('UPC 1')
     Dsap_upc2                       20
     D*                                    text('UPC 2')
     Dsap_upc3                       20
     D*                                    text('UPC 3')
     Dsap_vendcode                   20
     D*                                    text('Vendor Code')
     Dsap_paksizdsc                  15
     D*                                    text('Pack Size Desc')
     Dsap_pirpick                     1
     D*                                    text('PIR Pick')
     Dsap_isflow                      1
     D*                                    text('IS Flow')
     Dsap_itemcust1                  20
     D*                                    text('Item Custom 1')
     Dsap_itemcust2                  20
     D*                                    text('Item Custom 2')
     Dsap_itemcust3                  20
     D*                                    text('Item Custom 3')
     Dsap_itemcust4                  20
     D*                                    text('Item Custom 4')
     Dsap_itemcust5                  20
     D*                                    text('Item Custom 5')
     D*
