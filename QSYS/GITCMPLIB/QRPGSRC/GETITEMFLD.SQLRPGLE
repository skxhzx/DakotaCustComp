      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  GETITEMFLD   Get ITEMFLD fields
     *  11 March 2009
     *  Dave Sommerville
     *
520 A*    03/11/09  DAS  5.20
     *      - Created
     *
520aA*    10/20/09  DAS  5.20a
     *      - Changed file to be input only.
     *
610aA*    08/17/10  DAS  6.10a
     *      - Added field IFODRSLOT.
     *
610bA*    10/01/10  DAS  6.10b
     *      - Converted to SQL
     *      - Revised to handle old and new record formats.
     *
640a *    10/18/12  LMC  6.40a
     *      ITEMFLD database change - requires recompile.
     *
650a *    03/22/13  KDE  6.50a
     *      Get on-demand slot from kititem
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

520aDF*temfld   uf a e           k disk
610bDF*temfld   if   e           k disk
650aAfkititem   if   e           k disk

610bA*----------------------------------------------------------------
610bA*  File data data structure
610bA*----------------------------------------------------------------
610bA
610bAD ifrec         E ds                  extname(itemfld) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

610bA*----------------------------------------------------------------
610bA*  Standard SQL variables and constants
610bA*----------------------------------------------------------------
610bA
610bA /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Parameters
     *   Parameters:
     *     pWhse  - Warehouse
     *     pItem  - Item
     *
     *   Return Value:
     *     pCat       -  Category
     *     pCaseOvf   -  Case Overflow flag
610aA*     pODRSlot   -  On-Demand Repack slot
     *
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse             3 0
     C                   parm                    pItem            15
     C                   parm                    pCat             10
     C                   parm                    pCaseOvf          1
610aAC                   parm                    pODRSlot         12

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

       // Initialize return parms

        if %parms >= 3;
          pCat = ' ';
        endif;

        if %parms >= 4;
          pCaseOvf = 'N';
        endif;

610aA   if %parms >= 5;
610aA     pODRSlot = ' ';
610aA   endif;

       // Get ITEMFLD record

610bD   //chain (pWhse: pItem) itemfld;

610bD   //if %found(itemfld);

610bA   select;
610bA     when %parms < 5;
610bA       exsr Get520Record;
610aA     other;
610bA       exsr GetCurRecord;
610bA   endsl;

610bA   if error;
610bA     return;
610bA   endif;

         if %parms >= 3;
           pCat = ifcat;
         endif;

         if %parms >= 4;
           pCaseOvf = ifCaseOvf;
         endif;

610aA    if %parms >= 5;
610aA      pODRSlot = ifODRSlot;
610aA    endif;

610bD  //endif;

       return;

      /end-free

     *----------------------------------------------------------------
     *  GetCurRecord - Get current record format
     *----------------------------------------------------------------

      /free
       begsr GetCurRecord;

         error = *off;

         exec sql select * into :ifrec
                  from itemfld
                  where ifwhse = :pWhse and ifitem = :pItem;

         // If a column is not found, try getting previous record version.

         if sqlstt = sqlUndefColumn;
           exsr Get520Record;
           leavesr;
         endif;

         // If a different error, then get out.

         if sqlstt <> sqlSuccess;
            error = *on;
650aA      // if ITEMFLD record not found look for KITITEM for ODRS
650aA      chain (pwhse:pitem) kititem;
650aA      if not %found(kititem);
             leavesr;
650aA      else;
650aA        ifodrslot = kidisp;
650aA      endif;
650aA    else;
650aA      // Even if ITEMFLD record found we should now retrieve
650aA      //  ODRS from KITITEM
650aA      chain (pwhse:pitem) kititem;
650aA      if not %found(kititem);
650aA      else;
650aA        ifodrslot = kidisp;
650aA      endif;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  Get520Record - Get 5.20 record format
     *----------------------------------------------------------------

      /free
       begsr Get520Record;

         error = *off;

         exec sql select ifwhse, ifitem, ifcat, ifcaseovf
                  into :ifwhse, :ifitem, :ifcat, :ifcaseovf
                  from itemfld
                  where ifwhse = :pWhse and ifitem = :pItem;

         if sqlstt <> sqlSuccess;
           error = *on;
           leavesr;
         endif;

       endsr;
      /end-free
