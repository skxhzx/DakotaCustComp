      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  CHKUSAGE     Check slot usage for Directed putaway
     *  20 October 2009
     *  Dave Sommerville
     *
610 A*    10/20/09  DAS  6.10
     *      - Created
     *
640aA*    09/28/12  DAS  6.40a
     *      - Added checking of FIFO information
     *
640bA*    10/07/12  DAS  6.40b
     *      - Rewrote using non-sql to try to increase speed.
     *      - Using LABEL12 to look for open receiving labels.
     *
640cA*    10/09/12  DAS  6.40c
     *      - Wasn't using correct vslot files.
     *      - Wasn't using correct slot field to look up RCV slot.
     *
640dA*    10/11/12  DAS  6.40d
     *      - Revised to make sure lblitem is a slot item.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fslot2     if   e           k disk
640cMFvslot1    if   e           k disk
640cAFvslot2    if   e           k disk
     F                                     rename(vsrec:vsrec2)
     Flabel12   if   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

415aAD forever         s               n
640dAD slotItem        s                   like(slitem)

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
640bA*     pRsrv  - Slot reserve flag
     *     pItem  - Item being received
640aA*     pEntDte- Entered date
640aA*     pExpDte- Expiration date
     *
     *   Return Value:
640bD **    pCube      -  Cube
     *     pPieces    -  Pieces
     *     pRecs      -  Records (slots) found.
     *     pDiffItem  -  Different item found flag (Y,N)
640aA*     pDiffEntd  -  Different entered date found (Y,N)
640aA*     pDiffExpd  -  Different expiration date found (Y,N)
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse             3 0
     C                   parm                    pWhdp             5
     C                   parm                    pDisp            12
640bAC                   parm                    pRsrv             1
     C                   parm                    pItem            15
640aAC                   parm                    pEntDte           8 0
640aAC                   parm                    pExpDte           8 0
640bDC**                 parm                    pCube             9 3
     C                   parm                    pPieces           5 0
     C                   parm                    pRecs             3 0
     C                   parm                    pDiffItem         1
640aAC                   parm                    pDiffEntd         1
640aAC                   parm                    pDiffExpd         1

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

       // Initialize return parms

       pPieces = 0;
       pDiffItem = 'N';
640aA  pDiffEntd = 'N';
640aA  pDiffExpd = 'N';

       // If slot is a Virtual slot, then get base slot.

       if pRsrv = 'V';
640cM    chain (pWhse: pWhdp: pDisp) vslot1;
640cM    if %found(vslot1);
           pDisp = vspdis;
         endif;
       endif;

       // Look for an item in the slot

       chain (pWhse: pWhdp: pDisp) slot2;
       if %found(slot2)
         and slitem <> ' '
         and slstat <> 'V'
         and slstat <> 'Z';
           pPieces += slstk1;
           pRecs += 1;
           if slitem = pItem;
             if pEntDte > 0 and pEntDte <> slentd;
               pDiffEntd = 'Y';
             endif;
             if pExpDte > 0 and pExpDte <> slexpd;
               pDiffExpd = 'Y';
             endif;
           else;
             pDiffItem = 'Y';
           endif;
       endif;

       // Look for virtual slots

640cM  setll (pWhse: pWhdp: pDisp) vslot2;
       dow forever = forever;

640cM    reade (pWhse: pWhdp: pDisp) vslot2;
         if %eof(vslot2);
           leave;
         endif;

         chain (vsWhse: vsWhdp: vsDisp) slot2;
         if %found(slot2)
           and slitem <> ' '
           and slstat <> 'V'
           and slstat <> 'Z';
             pPieces += slstk1;
             pRecs += 1;
             if slitem = pItem;
               if pEntDte > 0 and pEntDte <> slentd;
                 pDiffEntd = 'Y';
               endif;
               if pExpDte > 0 and pExpDte <> slexpd;
                 pDiffExpd = 'Y';
               endif;
             else;
               pDiffItem = 'Y';
             endif;
         endif;

       enddo;

       // Look for RCV slots (open Putaway labels)

       setll (pWhse: 'P': ' ': pWhdp: pDisp) label12;
       dow forever = forever;

         reade (pWhse: 'P': ' ': pWhdp: pDisp) label12;
         if %eof(label12);
           leave;
         endif;

         pPieces += lbqpck;
         pRecs += 1;

640dA    chain (lbwhse: lbwhdp: lbdisp) slot2;
640dA    if %found(slot2);
640dA      slotItem = slitem;
640dA    else;
640dA      slotItem = lbitem;
640dA    endif;

640dM    if slotItem = pItem;
           if pEntDte > 0 and pEntDte <> slentd;
             pDiffEntd = 'Y';
           endif;
           if pExpDte > 0 and pExpDte <> slexpd;
             pDiffExpd = 'Y';
           endif;
         else;
           pDiffItem = 'Y';
         endif;

       enddo;

       return;

      /end-free
