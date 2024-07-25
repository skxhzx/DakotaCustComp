      *===================================================================
      *
      *  Name .......... PO_LOT_DTL
      *  Description ... POASN Purchase Order Lot record
      *  Created by .... Retha Davis
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   08/07/12  RBD  6.40
      *     - Created.  Originally written for BiRite.
      *
      *===================================================================
      *
      * Notes
      *   This is used to map BiRite's ASN Purchase Order lot record.
      *
      *===================================================================

     Dpo_lot_dtl       ds

     Dpo_recidlot_dtl                10    inz('LOT_DTL')
     D*                                    text('POASN record id')
     Dpo_fill1lot_dtl                30
     D*                                    text('Filler field 1')
     Dpo_lot#                        30
     D*                                    text('Lot number')
     Dpo_fill2lot_dtl                 9
     D*                                    text('Filler field 2')
     Dpo_mfrdate                      8  0
     D*                                    text('Mfr date')
     Dpo_expdate                      8  0
     D*                                    text('Exp date')
     Dpo_fill3lot_dtl               417
     D*                                    text('Filler field 3')
