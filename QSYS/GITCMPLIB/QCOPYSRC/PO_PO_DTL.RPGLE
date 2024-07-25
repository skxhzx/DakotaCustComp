      *===================================================================
      *
      *  Name .......... PO_PO_DTL
      *  Description ... POASN Purchase Order Detail record
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
      *   This is used to map BiRite's ASN Purchase Order detail record.
      *
      *===================================================================

     Dpo_po_dtl        ds

     Dpo_recidpo_dtl                 10    inz('PO_DTL')
     D*                                    text('POASN record id')
     Dpo_line#                        4
     D*                                    text('Line number')
     Dpo_buyerSKU                    20
     D*                                    text('Buyer SKU/item')
     Dpo_fill1po_dtl                 20
     D*                                    text('Filler field 1')
     Dpo_upc                         14
     D*                                    text('UPC')
     Dpo_fill2po_dtl                102
     D*                                    text('Filler field 2')
     Dpo_qty                         10  0
     D*                                    text('Qty shipped')
     Dpo_fill3po_dtl                 12
     D*                                    text('Filler field 3')
     Dpo_netwgt                      10  3
     D*                                    text('Net weight')
     Dpo_fill4po_dtl                310
     D*                                    text('Filler field 4')
