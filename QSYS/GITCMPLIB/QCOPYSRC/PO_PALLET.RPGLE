      *===================================================================
      *
      *  Name .......... PO_PALLET
      *  Description ... POASN Purchase Order Pallet record
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
      *   This is used to map BiRite's ASN Purchase Order pallet record.
      *
      *===================================================================

     Dpo_pallet        ds

     Dpo_recidpallet                 10    inz('PALLET')
     D*                                    text('POASN record id')
     Dpo_lpn                         10
     D*                                    text('Pallet LPN number')
     Dpo_fill1pallet                492
     D*                                    text('Filler field 1')
