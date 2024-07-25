      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M23100  Production Measurement edits and Updates
     *  13 Dec 2017
     *  Thomas Bryant
     *
     *  Revisions:
     *
     *    01/13/17  TAB  7.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Working variables
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------
     D parec         E ds                  extname(pbommar) inz(*EXTDFT)
     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------
     D  pMessage       s             99
     D  pSessId        s             40
     D  pUser          s             10
     D  pPgm           s             20
     D  pObjLoc        s             10
     D  pSubCmd        s              1
     D  pWhse          s              3  0
     D  pMFgi          s             15
     D  pMSeq          s              6  0
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D logText         s            100
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
     *      PMAR  fields
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
	    c                   parm                    pMFgi
	    c                   parm                    pMSeq

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pMessage = ' ';

        // Set SQL default parms
          exec sql
            set Option Commit=*none, Dlyprp=*Yes,
                       Closqlcsr = *ENDMOD;


        // Write GLOSESSLOG record
         logText = 'objloc:' + pObjLoc;
         wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);

         select;
           when pObjLoc = 'FLDVALID';
             exsr FldValid;
           other;
             pMessage = 'Invalid object location sent: '
                      + %trim(pObjLoc)
                      + ' (' + %trim(#pgm) +')';
         endsl;

         return;
      /end-free

     *----------------------------------------------------------------
     *  FldValid   Validate fields
     *----------------------------------------------------------------

      /free
       begsr FldValid;

         error = *off;

         Select;

        // Add

           When pSubCmd = 'A';
             ExSR errorcheck;
               If Error;
                 LeaveSR;
               Else;
                 Exsr AddRec;
               EndIf;

        // Update

           When pSubCmd = 'U';
               exsr UpdRec;

           Other;
             pMessage = 'Invalid command sent: ' + pSubCmd
                      + %trim(pSubCmd)
                      + ' (' + %trim(#pgm) +')';
         endsl;

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
     *  UpdRec    Update record
     *----------------------------------------------------------------

      /free
       begsr UpdRec;
       error = *off;

        // Update BOM Marinade file...........
         Exec SQL Update PBOMMAR
              Set PASEQ = :pMSeq
              Where PAWHSE = :pWhse and
                    PAFGI  = :pMFgi;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating BOM Marinade record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'FG(' + %trim(pMFgi) + ') '
                    + 'Seq(' + %trim(%char(pMSeq)) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  AddRec    Add record
     *----------------------------------------------------------------

      /free
       begsr AddRec;

      // Add BOM Marinade record......

         Eval PAWHSE = pWhse;
         Eval PAFGI  = pMFgi;
         Eval PASEQ  = pMSeq;

         Exec SQL Insert into PBOMMAR values(:parec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Adding BOM Marinade record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'FG(' + %trim(pMFgi) + ') '
                    + 'Seq(' + %trim(%char(pMSeq)) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  errorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

           // Check to see if marinade has been selected.

         If pMSeq = 0;
           pMessage = 'You must select a marinade';
           error = *on;
           leavesr;
         EndIf;

       endsr;
      /end-free

