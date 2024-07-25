      *===================================================================
      *
      *  Name .......... S#E1RTNH
      *  Description ... SAP Customer Returns Header
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   02/06/07  MLB  5.10
      *     - Created.
PAK A *   08/06/20  MLB  PAK
      *     - Revised sap_refdoc to be 11 characters so that field has
      *       leading zero + 3 blanks then host order number, left just-
      *       ified.
      *       Per Edson email dated 08.06.2020.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D s#e1rtnh        ds

     D  sap_segrtnh                   1    inz('H')
     D*                                    text('SAP Segment Header')
     D  sap_doctype                   4    inz('ZRTN')
     D*                                    text('SAP Document Type')
     D  sap_vkorg                     4
     D*                                    text('SAP Sales Organization')
     D  sap_district                  2    inz('10')
     D*                                    text('SAP District')
     D  sap_division                  2    inz('00')
     D*                                    text('SAP Division')
PAK AD  sap_filler1                   1    inz('0')
PAK AD*                                    text('SAP Filler 1')
     D  sap_refdoc                   10
     D*                                    text('SAP Reference Doc (Inv#)')
