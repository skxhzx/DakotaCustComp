      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M23300  Production By-Product Maintenance
     *  01 Feb 2017
     *  Kenneth Elder
     *
     *  Revisions:
     *
     *    02/01/17  KDE  7.10
     *      - Created.
     *
750 A*    02/08/22  KDE  7.50
     *      - Allow By-Product entry against component items
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     FItemprd   if   e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D iyrec         E ds                  extname(itemPrdBP) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  pSessId        s             40
     D  pUser          s             10
     D  pPgm           s             20
     D  pAction        s              1
     D  pWhse          s              3  0
	    d  pRmITm         s             15
	    d  pBpItm         s             15
	    d  pBpDesc        s             60

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

650aAD logText         s            100
     d addseq          s              4  0
     d hldmorp         s              1

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
	    c                   parm                    pRmItm
	    c                   parm                    pBpItm
	    c                   parm                    pBpDesc

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         // Set SQL default parms
         exec sql
           set Option Commit=*none, Dlyprp=*Yes,
                      Closqlcsr = *ENDMOD;

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

         exec sql insert into ItemprdBP values(:iyrec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'RmItem(' + %Trim(pRmItm) + ') '
                    + 'BpItem(' + %Trim(pBpItm) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
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

         exec sql delete from ItemPrdBP
                  where iywhse = :pwhse
                    and iyitem = :pRmITm
                    and iyBpItm = :pBpItm;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'pRmItm(' + %trim(pRmItm) + ') '
                    + 'pBpItm(' + %trim(pBpItm) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ErrorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

         // Ensure By-PRoduct and Primary are not same raw material
         If pBpItm = pRMItm;
           pMessage = 'By-Product cannot be the same item ' +
                      'as Primary Raw material';
           error = *on;
           leavesr;
         EndIf;

         // Check to ensure Warehouse is sent
         If pWhse = *zeros;
           pMessage = 'Warehouse cannot be empty';
           error = *on;
           leavesr;
         EndIf;

         // Check to Item Sent
         If pRmItm = *blanks;
           pMessage = 'Primary raw material must be keyed';
           error = *on;
           leavesr;
         EndIf;

         // Check to ensure By-Product is sent
         If pBpItm = *blanks;
           pMessage = 'By-Product item must be keyed';
           error = *on;
           leavesr;
         EndIf;

         // Check to ensure By-Product item is raw material
         chain (pWhse:pRmItm) itemprd;
750 D    //If not %found(itemprd) or ipprdflg <> 'R';
750 M    If not %found(itemprd) or (ipprdflg <> 'R' and ipprdflg<>'C');
           pMessage = 'Invalid Primary item number';
           error = *on;
           leavesr;
         EndIf;

         // Check to ensure By-Product item is raw material
         chain (pWhse:pBpItm) itemprd;
         If not %found(itemprd) or ipprdflg <> 'R';
           pMessage = 'Invalid By-Product item number';
           pBpDesc = '** INVALID ITEM **';
           error = *on;
           leavesr;
         EndIf;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillRec   Fill record fields
     *----------------------------------------------------------------

      /free
       begsr FillRec;

	        iywhse = pwhse;
         iyitem = pRmItm;
         iybpitm = pBpItm;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FldValid   Validate fields
     *----------------------------------------------------------------

      /free
       begsr FldValid;

         error = *off;

         // Validate input

         if pAction <> 'D';
           exsr errorcheck;
           if error;
             leavesr;
           endif;
         else;
            // put in code to prevent deletes if situation determined
         endif;

         // See if PPrimal record exists for item

         exsr GetRec;

         select;

           // Add

           when pAction = 'A';
             if found;
               pMessage = 'By-PRoduct already exists.';
               error = *on;
               leavesr;
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

         exec sql select * into :iyrec
                  from ItemPrdBP
                  where iywhse = :pwhse
                    and iyitem = :pRmitm
                    and iybpitm = :pBpitm;

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

         exec sql update itemprdbp
                  set iybpitm = :pBpItm
                  where iywhse = :pwhse
                    and iyitem = :pRmItm
                    and iybpitm = :pBpItm;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'pRmitm(' + %trim(pRmitm) + ') '
                    + 'pBpitm(' + %trim(pBpitm) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
         endif;

       endsr;
      /end-free
