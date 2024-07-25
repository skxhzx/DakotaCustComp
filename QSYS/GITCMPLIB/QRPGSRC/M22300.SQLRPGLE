      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M22300  Production Primal Update/Edit
     *  01 Dec 2016
     *  Kenneth Elder
     *
     *  Revisions:
     *
     *    12/01/16  KDE  7.00
     *      - Created.
720 A*    07/11/18  KDE  7.20
     *      - Fix:  Add check to make sure no sub-pirmal definitions exist
     *        before allowing delete of Primal
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     FpLined    if   e           k disk
     FItemprd   if   e           k disk
720 AFpSubPrimalif   e           k disk
     FpirItem   if   e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D prmrec        E ds                  extname(pPrimal) inz(*EXTDFT)
     D isrec         E ds                  extname(ItemPRdPs) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  pSessId        s             40
     D  pUser          s             10
     D  pPgm           s             20
     D  pAction        s              1
     D  pWhse          s              3  0
	    d  pPrim          s             20
	    d  pLine          s              3  0
	    d  pDesc          s             40
     D  pFactor        s              6  2
     D  pFacUom        s              2
     D  pYield         s              3  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

650aAD logText         s            100

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar
     D Up              C                   CONST('ABCDEFGHIJKLMNOPQRST+
     D                                     UVWXYZ')
     D Low             C                   CONST('abcdefghijklmnopqrst+
     D                                     uvwxyz')


     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.wrtsessl

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       GUI User
     *      pPgm        GUI dictionary.program
     *      pWhse       Warehouse
     *      PBOM  fields
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pPgm
     C                   parm                    pAction
     C                   parm                    pWhse
	    c                   parm                    pPrim
	    c                   parm                    pLine
	    c                   parm                    pDesc
	    c                   parm                    pFactor
	    c                   parm                    pFacUom
	    c                   parm                    pYield

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pMessage = ' ';

         // Write GLOSESSLOG record
         logText = 'objloc:' + pAction;
         wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);

         //  Validates entries and then update if no errors found
         exsr FldValid;

         return;
      /end-free

     *----------------------------------------------------------------
     *  AddRec    Add record
     *----------------------------------------------------------------

      /free
       begsr AddRec;

         error = *off;

         exsr FillRec;

         exec sql insert into pPrimal values(:prmrec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Prmcde(' + %trim(pPrim) + ') '
                    + 'Line(' + %char(pLine) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DelRec     Delete record
     *----------------------------------------------------------------

      /free
       begsr DelRec;

         error = *off;

         // delete BOM line

         exec sql delete from pPrimal
                  where ppwhse = :pwhse
                    and pppcde = :pPrim
                    and ppline = :pLine;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'PrmCde(' + %trim(pPrim) + ') '
                    + 'Table(' + %trim(%char(pLine)) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  errorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

720 A    // if delete ensure no sub-primal definition exist
720 A    setll (pWhse:pLine:pPrim) pSubPrimal;
720 A    reade (pWhse:pLine:pPrim) pSubPrimal;
720 A    if %equal(pSubPrimal);
720 A       pMessage = 'All Sub-Primal definitions must be purged first';
720 A       error = *on;
720 A       leavesr;
720 A    endif;
         // Check to ensure Primal Code exists

         If pPrim = *blanks;
           pMessage = 'Primal Code must exist';
           error = *on;
           leavesr;
         EndIf;

         // Validate Production Table/Line

         chain(n) (pwhse: pLine) plined;
         if not %found(plined);
           pMessage = 'Production Table Code not valid '
                    + 'Production table (' + %char(pLine) + ')';
           error = *on;
           leavesr;
         endif;

         // Ensure Primal Description is included
         if pDesc = *blanks;
           pMessage = 'Primal Description must exist';
           error = *on;
           leavesr;
         endif;

         // Ensure Weight exists

         if pFactor <= 0;
            pMessage = 'Primal must include typical weight';
            error = *on;
            leavesr;
         endif;

         if pFacUom = ' ';
            pMessage = 'UOM factor cannot be blank';
            error = *on;
            leavesr;
         endif;

         // Yield must exist

         if pYield <= *zeros;
            pMessage = 'Yield must exists';
            error = *on;
            leavesr;
         endif;

         // If the Factor UOM is changed on the Primal ensure
         // no associations to BOM raw materials exist without
         // that UOM.  This is used in qty calculations
          SqlStmt = 'Select * from itemprdps' +
                 ' where iswhse = ' + %char(pWhse) +
                 ' and isline = ' + %char(pLine) +
                 ' and ispcde = ' + sq + pPrim + sq;

           exec sql PREPARE subPrim FROM :SqlStmt;
           exec sql DECLARE ItemPrdPs SCROLL CURSOR FOR subPrim;
           exec sql OPEN ItemPrdPs;

           exec sql
            fetch first from ItemPrdps into :isrec;
            dow sqlstt = '00000';
               chain (isWhse:isrmi) Itemprd;
               if not %found(Itemprd);
                  ippuom = *blanks;
               endif;
               chain (isWhse:isrmi) pirItem;
               if not %found(pirITem);
                  itum1 = *blanks;
                  itum2 = *blanks;
                  itum3 = *blanks;
               endif;
            // if primal has size uom then make sure it matches one
            // of the uom's defined on the raw material
            if pFactor <> 9999.99 and
               pfacuom <> itum1 and pfacuom <> itum2 and
               pfacuom <> itum3 and pfacuom <> ippuom;
               pMessage = 'The Factor Uom is not defined on ' +
                          'some of BOM raw materials associated to this ' +
                          'primal.  Correct BOMs';
               error = *on;
               leavesr;
            endif;
               exec sql
                fetch next from ItemPrdps into :isrec;
            enddo;
           exec sql Close ItemPrdPs;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillRec   Fill record fields
     *----------------------------------------------------------------

      /free
       begsr FillRec;

	        ppwhse = pwhse;
         ppline = pLine;
         pppcde = pPrim;
         pppdsc = pDesc;
         pptypfac = pfactor;
         ppfacuom = pFacUom;
         pptypyld = pYield;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FldValid   Validate fields
     *----------------------------------------------------------------

      /free
       begsr FldValid;

         error = *off;

         // Validate input

720 D    // if pAction <> 'D';
           exsr errorcheck;
           if error;
             leavesr;
           endif;
720 D    // endif;

         // See if PPrimal record exists for item

         exsr GetRec;

         select;

           // Add

           when pAction = 'A';
             if found;
               exsr UpdRec;
             else;
               exsr AddRec;
             endif;

           // Change

           when pAction = 'U' or pAction = 'C';
             if found;
               exsr UpdRec;
             else;
               exsr AddRec;
             endif;

           // Delete

           when pAction = 'D';
             if found;
               exsr DelRec;
             endif;

           other;
             pMessage = 'Invalid command sent: ' + pAction
                      + %trim(pAction)
                      + ' (' + %trim(#pgm) +')';
         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetRec    Get record
     *----------------------------------------------------------------

      /free
       begsr GetRec;

         found = *off;

         exec sql select * into :prmrec
                  from pPrimal
                  where ppwhse = :pwhse
                    and ppline = :pLine
                    and pppcde = :pPrim;

         if sqlstt = sqlSuccess;
           found = *on;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  UpdRec    Update record
     *----------------------------------------------------------------

      /free
       begsr UpdRec;

         error = *off;

         exsr FillRec;

         exec sql update pPrimal
                  set pppdsc = :pDesc, ppLine = :pLine,
                      pptypfac = :pFactor, pptypyld = :pYield,
                      ppfacuom = :pFacUom
                  where ppwhse = :pwhse
                    and pppcde = :pPrim
                    and ppline = :pLine;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Prmcde(' + %trim(pPrim) + ') '
                    + 'Pline(' + %trim(%char(pline)) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free
