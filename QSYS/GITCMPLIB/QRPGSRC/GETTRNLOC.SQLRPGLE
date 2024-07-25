417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETTRNLOC   Get transaction location - Pgm for GETTRNLOC function
     *  07 October 2013
     *  Dave Sommerville
     *
     *  Revisions:
     *
650 A*    10/07/13  DAS  6.50
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fpirtran   if   e           k disk
     Flabel     if   e           k disk
     Flabel71   if   e           k disk
     Flabeldo1  if   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D forever         s               n
     D slotsPck        s              5  0
     D slotsRem        s              5  0
     D nrmLblPck       s              5  0
     D nrmLblRem       s              7  0
     D nrmPcsPck       s              5  0
     D nrmPcsRem       s              7  0
     D mrgLblPck       s              5  0
     D mrgLblRem       s              7  0
     D mrgPcsPck       s              5  0
     D mrgPcsRem       s              7  0
     D ttlLblPck       s              5  0
     D ttlLblRem       s              7  0
     D ttlPcsPck       s              5  0
     D ttlPcsRem       s              7  0

     D kyCurTS         s               z
     D lastDisp        s                    like(lbdisp)

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse       Warehouse
     *      $pTran       Transaction
     *
     *    Returned Parameters
     *      $pJSON      -  Return JSON string
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * JSON string
     *
     *    "loc"      - Slot location or "Unknown"
     *    "whdp"     - Department of location
     *    "zone"     - Selection zone of location
     *    "slotsPck" - Slots picked
     *    "slotsRem" - Slots remaining
     *    "nrmLblPck - Normal labels picked
     *    "nrmLblRem - Normal labels remaining
     *    "nrmPcsPck - Normal pieces picked
     *    "nrmPcsRem - Normal pieces remaining
     *    "mrgLblPck - Merge labels picked
     *    "mrgLblRem - Merge labels remaining
     *    "mrgPcsPck - Merge pieces picked
     *    "mrgPcsRem - Merge pieces remaining
     *    "ttlLblPck - Total labels picked
     *    "ttlLblRem - Total labels remaining
     *    "ttlPcsPck - Total pieces picked
     *    "ttlPcsRem - Total pieces remaining
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pWhse            3 0
     C                   parm                    $pTran            7 0
     C                   parm                    $pJSON          512

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        // Get transaction record

        chain ($pTran) pirtran;
        if not %found(pirtran);
          $pJSON = '{"loc":"Unknown"}';
          return;
        endif;

        // No location for IDLE transactions

        if pttask = 'IDLE';
          $pJSON = '{"loc":"Unknown"}';
          return;
        endif;

        // No location for IDLE transactions

        select;
          when ptcat <> 'SELECT';
            exsr GetNonSelectLoc;
          when %subst(pttask:1:4) = 'BULK';
            exsr GetSelectBulkLoc;
          other;
            exsr GetSelectLoc;
        endsl;

        *inlr = *on;
        return;
      /end-free

     *----------------------------------------------------------------
     *  GetNonSelectLoc  Get non-selection location
     *----------------------------------------------------------------

      /free
       begsr GetNonSelectLoc;

         setll (pttrn#) label71;
         reade (pttrn#) label71;
         if %eof(label71);
          $pJSON = '{"loc":"Unknown"}';
         else;
          $pJSON = '{"loc":"' + %trimr(lbdisp) + '"'
                 + ',"whdp":"' + %trimr(lbwhdp) + '"'
                 + ',"ttlpcsrem":' + %char(lbqpck)
                 + '}';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetSelectBulkLoc    Get Bulk selection location
     *----------------------------------------------------------------

      /free
       begsr GetSelectBulkLoc;

         setll (pttrn#) label71;
         reade (pttrn#) label71;
         if %eof(label71);
          $pJSON = '{"loc":"Unknown"}';
         else;
          $pJSON = '{"loc":"' + %trimr(lbdisp) + '"'
                 + ',"whdp":"' + %trimr(lbwhdp) + '"'
                 + ',"ttlpcsrem":' + %char(lbqpck)
                 + '}';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetSelectLoc     Get selection location
     *----------------------------------------------------------------

      /free
       begsr GetSelectLoc;

         // Try to get last location from LABELDO file

         kyCurTS = %timestamp();

         setgt (pttrn#: kyCurTS) labeldo1;
         readpe (pttrn#) labeldo1;
         if %eof(labeldo1);
           $pJSON = '{"loc":"Unknown"';
         else;
           chain (lbolbl#) label;
           if not %found(label);
             $pJSON = '{"loc":"Unknown"';
            else;
             $pJSON = '{"loc":"' + %trimr(lbdisp) + '"'
                    + ',"whdp":"' + %trimr(lbwhdp) + '"';
           endif;
         endif;

         // Calculate details

         slotsPck = 0;
         slotsRem = 0;
         nrmLblPck = 0;
         nrmLblRem = 0;
         nrmPcsPck = 0;
         nrmPcsRem = 0;
         mrgLblPck = 0;
         mrgLblRem = 0;
         mrgPcsPck = 0;
         mrgPcsRem = 0;
         ttlLblPck = 0;
         ttlLblRem = 0;
         ttlPcsPck = 0;
         ttlPcsRem = 0;
         lastDisp = ' ';

         setll (pttrn#) label71;
         dow forever = forever;

           reade (pttrn#) label71;

           if %eof(label71);
             leave;
           endif;

           // Only read O and M records.

           if lbtype <> 'O'
             and lbtype <> 'M';
               iter;
           endif;

           select;

             when lbvrfy = ' ';

               ttlLblRem += 1;
               ttlPcsRem += lbqpck;
               if lbdisp <> lastDisp;
                 slotsRem += 1;
                 lastDisp = lbdisp;
               endif;
               if lbtype = 'M';
                 mrgLblRem += 1;
                 mrgPcsRem += lbqpck;
               else;
                 nrmLblRem += 1;
                 nrmPcsRem += lbqpck;
               endif;

             other;

               ttlLblPck += 1;
               ttlPcsPck += lbqpck;
               if lbdisp <> lastDisp;
                 slotsPck += 1;
                 lastDisp = lbdisp;
               endif;
               if lbtype = 'M';
                 mrgLblPck += 1;
                 mrgPcsPck += lbqpck;
               else;
                 nrmLblPck += 1;
                 nrmPcsPck += lbqpck;
               endif;

             endsl;

         enddo;

         // Add calculations to JSON string

         if ttlLblPck > 0;
           $pJSON = %trimr($pJSON)
                  + ',"slotsPck":' + %char(slotsPck)
                  + ',"slotsRem":' + %char(slotsRem)
                  + ',"nrmLblPck":' + %char(nrmLblPck)
                  + ',"nrmLblRem":' + %char(nrmLblRem)
                  + ',"nrmPcsPck":' + %char(nrmPcsPck)
                  + ',"nrmPcsRem":' + %char(nrmPcsRem)
                  + ',"mrgLblPck":' + %char(mrgLblPck)
                  + ',"mrgLblRem":' + %char(mrgLblRem)
                  + ',"mrgPcsPck":' + %char(mrgPcsPck)
                  + ',"mrgPcsRem":' + %char(mrgPcsRem)
                  + ',"ttlLblPck":' + %char(ttlLblPck)
                  + ',"ttlLblRem":' + %char(ttlLblRem)
                  + ',"ttlPcsPck":' + %char(ttlPcsPck)
                  + ',"ttlPcsRem":' + %char(ttlPcsRem);
         endif;

         // Close JSON string

         $pJSON = %trimr($pJSON) + '}';

       endsr;
      /end-free
