      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M22400  Production Primal Update/Edit
     *  02 Dec 2016
     *  Kenneth Elder
     *
     *  Revisions:
     *
     *    12/02/16  KDE  7.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     Fitemprdps if   e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D psbrec        E ds                  extname(pSubPrimal) inz(*EXTDFT)

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
	    d  pprmYld        s              3  0
	    d  pSubPrim       s             20
	    d  pSubDesc       s             40
     D  psubPct        s              4  3
     D  psubTyp        s              1

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

650aAD logText         s            100
     d recCnt          s              7  0

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
	    c                   parm                    pprmYld
	    c                   parm                    psubPrim
	    c                   parm                    psubDesc
	    c                   parm                    psubPct
	    c                   parm                    psubTyp

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

         exec sql insert into pSubPrimal values(:psbrec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'PPrim(' + %trim(pPrim) + ') '
                    + 'PsubPrim(' + %trim(pSubPrim) + ') '
                    + 'Line(' + %char(pLine) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
            // when Sub-Primal added successfully update
            // status in Primal to reflect if sub-primals
            // fully allocate primal
            exsr primStat;
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

         exec sql delete from pSubPrimal
                  where pswhse = :pwhse
                    and pspcde = :pPrim
                    and psline = :pLine
                    and psscde = :pSubPRim;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'PrmCde(' + %trim(pPrim) + ') '
                    + 'PSubPrim(' + %trim(pSubPrim) + ') '
                    + 'Table(' + %trim(%char(pLine)) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
            // when Sub-Primal deleted successfully update
            // status in Primal to reflect if sub-primals
            // fully allocate primal
            exsr primStat;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  errorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

         // Check to ensure Sub Primal Code exists

         If pSubPrim = *blanks;
           pMessage = 'Sub Primal Code must exist';
           error = *on;
           leavesr;
         EndIf;

         // Ensure Sub Primal Description is included
         if psubDesc = *blanks;
           pMessage = 'Sub Primal Description must exist';
           error = *on;
           leavesr;
         endif;

         // Ensure Primal Pct exist

         if psubPct <= 0;
            pMessage = 'Sub Primal must include percent of Primal';
            error = *on;
            leavesr;
         endif;

         // Yield must exist

         if psubTyp <> 'N' and psubTyp<>'B' and psubTyp<>'W';
            pMessage = 'Sub Primal Type must be B, N, or W';
            error = *on;
            leavesr;
         endif;

         // Make sure SubPrimal not being used before allowing deletion
         if pAction = 'D';
            exec sql select count(*) into :recCnt
                     from ItemPrdps
                   where iswhse=:pwhse and isline=:pline
                     and isscde=:pSubPrim and ispcde=:pPrim;
            if sqlStt = SqlSuccess and recCnt<>0;
               pMessage = 'SubPrimal is actively associated ' +
                          'with Finished Goods.  Cannot Delete';
               error = *on;
               leavesr;
            endif;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillRec   Fill record fields
     *----------------------------------------------------------------

      /free
       begsr FillRec;

	        pswhse = pwhse;
         psline = pLine;
         pspcde = pPrim;
         psscde = pSubPRim;
         pssdsc = psubDesc;
         psspct = psubPct;
         pstype = psubTyp;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FldValid   Validate fields
     *----------------------------------------------------------------

      /free
       begsr FldValid;

         error = *off;

         // Validate input

        // if pAction <> 'D';
           exsr errorcheck;
           if error;
             leavesr;
           endif;
        // endif;

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

         exec sql select * into :psbrec
                  from pSubPrimal
                  where pswhse = :pwhse
                    and psline = :pLine
                    and pspcde = :pPrim
                    and psscde = :psubPrim;

         if sqlstt = sqlSuccess;
           found = *on;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  primStat  Update Primal status based on 100% allocation
     *----------------------------------------------------------------

      /free
       begsr primStat;

          exec sql
               update pPrimal as a
                      set ppstat =
                      case
                          when (select sum(psspct) from pSubPrimal as s
                                where a.ppwhse=s.pswhse and
                                      a.ppline=s.psline and a.pppcde=s.pspcde)
                                >=.98 and
                               (select sum(psspct) from pSubPrimal as s
                                where a.ppwhse=s.pswhse and
                                      a.ppline=s.psline and a.pppcde=s.pspcde)
                                <=1.02 then 'A'
                          else 'I'
                          end;
       Endsr;
      /end-free

     *----------------------------------------------------------------
     *  UpdRec    Update record
     *----------------------------------------------------------------

      /free
       begsr UpdRec;

         error = *off;

         exsr FillRec;

         exec sql update pSubPrimal
                  set pssdsc = :pssdsc, pssPct = :psubPct,
                      psType = :pSubTyp
                  where pswhse = :pwhse
                    and pspcde = :pPrim
                    and psscde = :psubPrim
                    and psline = :pLine;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Prmcde(' + %trim(pPrim) + ') '
                    + 'PSubPrim(' + %trim(pSubPrim) + ') '
                    + 'Pline(' + %trim(%char(pline)) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
            // when Sub-Primal updated successfully update
            // status in Primal to reflect if sub-primals
            // fully allocate primal
            exsr primStat;
         endif;

       endsr;
      /end-free
