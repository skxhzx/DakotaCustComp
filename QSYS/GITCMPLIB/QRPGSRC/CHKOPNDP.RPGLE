      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  CHKOPNDP     Check for open Directed Putaway for slot
     *  10 October 2012
     *  Dave Sommerville
     *
640 A*    10/10/12  DAS  6.40
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *   When an item is assigned to a slot through Directed Putaway,
     *   the item will be put into that slot with a qty of zero. A
     *   Virtual slot will be created if necessary. This slot number
     *   is then put into the LBDSP2 field of the putaway label record.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Flabel12   if   e           k disk
     Fslot2     if   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D forever         s               n

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Parameters
     *
     *   Input:
     *     pWhse  - Warehouse
     *     pWhdp  - Department
     *     pDisp  - Slot display
     *     pItem  - Item being received
     *
     *   Return Value:
     *     pCount     -  Count
     *     pPieces    -  Pieces
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse             3 0
     C                   parm                    pWhdp             5
     C                   parm                    pDisp            12
     C                   parm                    pItem            15
     C                   parm                    pTotal            3 0
     C                   parm                    pItmTtl           3 0
     C                   parm                    pQty1             5 0
     C                   parm                    pQty2             5 0
     C                   parm                    pQty3             5 0

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

       // Initialize return parms

       pTotal = 0;
       pItmTtl = 0;
       pQty1 = 0;
       pQty2 = 0;
       pQty3 = 0;

       // Look for RCV slots (open Putaway labels)

       setll (pWhse: 'P': ' ': pWhdp: pDisp) label12;
       dow forever = forever;

         reade (pWhse: 'P': ' ': pWhdp: pDisp) label12;
         if %eof(label12);
           leave;
         endif;

         pTotal += 1;

         // If item matches, get qty and loop.

         if lbitem = pItem;
           pItmTtl += 1;
           select;
             when lbutyp = 'N';
               pQty1 += lbqpck;
             when lbutyp = '1';
               pQty2 += lbqpck;
             when lbutyp = '2';
               pQty3 += lbqpck;
           endsl;
           iter;
         endif;

         // If the items don't match, it could be because
         // the label record doesn't have the 'slot' item,
         // which would occur if an Alias was received.
         // Therefore, get the corresponding RCV slot.

         // If Item matches, which it should, get qty.

         chain (lbwhse: lbwhdp: lbdisp) slot2;
         if %found(slot2) and slitem = pItem;
           pItmTtl += 1;
           select;
             when lbutyp = 'N';
               pQty1 += lbqpck;
             when lbutyp = '1';
               pQty2 += lbqpck;
             when lbutyp = '2';
               pQty3 += lbqpck;
           endsl;
         endif;

       enddo;

       return;

      /end-free
