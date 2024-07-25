      *===================================================================
      *
      *  Name .......... PO_PO_HDR
      *  Description ... POASN Purchase Order Header record
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
      *   This is used to map BiRite's ASN Purchase Order header record.
      *
      *===================================================================

     Dpo_po_hdr        ds

     Dpo_recidpo_hdr                 10    inz('PO_HDR')
     D*                                    text('POASN record id')
     Dpo_fill1po_hdr                  2
     D*                                    text('Filler field 1')
     Dpo_po#                         22
     D*                                    text('PO number')
     Dpo_fill2po_hdr                478
     D*                                    text('Filler field 2')
