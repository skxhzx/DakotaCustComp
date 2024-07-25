      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M21800  Production Dynamic BOM Detail Edits and Updates
     *  27 Dec 2016
     *  Thomas Bryant
     *
     *  Revisions:
     *
     *    12/27/16  TAB  7.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     Fitemprd   if   e           k disk
     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D mdrec         E ds                  extname(pmarind) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  SeqNum         S              2  0
     D  pMessage       s             99
     D  pSessId        s             40
     D  pUser          s             10
     D  pPgm           s             20
     D  pObjLoc        s             10
     D  pSubCmd        s              1
     D  pWhse          s              3  0
	    d  pDSeq          s              6  0
	    d  pDigi          s             15
     D  pDQty          s              9  4
     D  pDMSeq         s              3  0

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
     c                   parm                    pObjLoc
     c                   parm                    pSubCmd
     C                   parm                    pWhse
     c                   parm                    pDSeq
     c                   parm                    pDigi
     c                   parm                    pDQty
     c                   parm                    pDMSeq

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pMessage = ' ';

         // Write GLOSESSLOG record
         logText = 'objloc:' + pObjLoc;
         wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);

         select;
           when pObjLoc = 'FLDVALID';
             exsr FldValid;
           when pObjLoc = 'AFTERACT';
             exsr AfterAct;
           other;
             pMessage = 'Invalid object location sent: '
                      + %trim(pObjLoc)
                      + ' (' + %trim(#pgm) +')';
         endsl;

         return;
      /end-free

     *----------------------------------------------------------------
     *  AddRec    Add record
     *----------------------------------------------------------------

      /free
       begsr AddRec;

         error = *off;

           exsr FillRec;

         exec sql insert into pmarind values(:mdrec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'IGI(' + %trim(pDigi) + ') '
                    + 'Seq(' + %char(pdmseq) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AfterAct     After action update
     *----------------------------------------------------------------

      /free
       begsr AfterAct;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DelRec     Delete record
     *----------------------------------------------------------------

      /free
       begsr DelRec;

         error = *off;

        // delete Merinade Detail record

         exec sql delete from pmarind
                  where mdwhse = :pwhse
                    and mdigi = :pdigi
                    and mdseq = :pdseq;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'IGI(' + %trimr(pdigi) + ') '
                    + 'Sq(' + %char(pdseq) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  errorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

        // If user is adding and item is already in file,send back error

         If pSubCmd = 'A'and
            Found = *On;
           pMessage = 'Raw material item already exist '
                    + 'in marinade';
           error = *on;
           leavesr;
         EndIf;
        // Raw material item must exist and be defined as raw material

         chain(n) (pwhse: pdigi) itemprd;
         if not %found(itemprd);
           pMessage = 'Raw material item not defined as '
                    + 'Production item (' + %trim(pdigi) + ')';
           error = *on;
           leavesr;
         endif;
         if ipprdflg <> 'R';
           pMessage = 'Raw material item not defined as a '
                    + 'raw material item (' + %trim(pdigi) + ')';
           error = *on;
           leavesr;
         endif;

        // Check that quantity has been entered.......................
         if pdqty = 0;
           pMessage = 'Measurement quantity must be entere'
                    + 'd';
           error = *on;
           leavesr;
         endif;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillRec   Fill record fields (Non-Instruction record)
     *----------------------------------------------------------------

      /free
       begsr FillRec;

	        mdwhse = pwhse;
	        mdseq  = pdseq;
	        mdigi  = pdigi;
         mdqty  = pdqty;
         mdmseq = pdmseq;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FldValid   Validate fields
     *----------------------------------------------------------------

      /free
       begsr FldValid;

         error = *off;

        // Validate input
           exsr GetRec;

         if pSubCmd <> 'D';
           exsr errorcheck;
           if error;
             leavesr;
           endif;
         endif;

        // See if PBOMVERS record exists for item


         select;

           // Add

           when pSubCmd = 'A';
             if found;
               exsr UpdRec;
             else;
               exsr AddRec;
             endif;

           // Change

           when pSubCmd = 'U' or pSubCmd = 'C';
             if found;
               exsr UpdRec;
             else;
               exsr AddRec;
             endif;

           // Delete

           when pSubCmd = 'D';
             if found;
               exsr DelRec;
             endif;

           other;
             pMessage = 'Invalid command sent: ' + pSubCmd
                      + %trim(pSubCmd)
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

         exec sql select * into :mdrec
                  from pmarind
                  where mdwhse = :pwhse
                    and mdigi  = :pdigi
                    and mdseq  = :pdseq;

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

         exec sql update pmarind
                  set mdqty = :pdqty, mdmseq = :pdmseq
                  where mdwhse = :pwhse
                    and mdigi  = :pdigi
                    and mdseq  = :pdseq
                    and mdmseq = :pdmseq;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'IG(' + %trim(pDigi) + ') '
                    + 'Seq(' + %char(pdseq) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free
