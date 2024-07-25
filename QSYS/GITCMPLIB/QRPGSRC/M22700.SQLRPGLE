      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M22700  Production Measurement edits and Updates
     *  21 Dec 2016
     *  Thomas Bryant
     *
     *  Revisions:
     *
     *    12/21/16  TAB  7.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     FPmarinM   UF A E           k disk

     *----------------------------------------------------------------
     *  Working variables
     *----------------------------------------------------------------
     D MeasSeq         S              4  0
     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D merecx        E ds                  extname(pmarinm) inz(*EXTDFT)
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
     D  pMesSq         s              4  0
     D  pMesDs         s             10

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
	    c                   parm                    pMesSq
	    c                   parm                    pMesDs

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
     *  FldValid   Validate fields
     *----------------------------------------------------------------

      /free
       begsr FldValid;

         error = *off;

        // Validate input

         If pSubCmd <> 'D';
           ExSR errorcheck;
           If Error;
             LeaveSR;
           EndIf;
         EndIf;

        // Get Mext available sequence number from PMARINM
         Exsr GetRec;

         Select;

          // Add

           When pSubCmd = 'A';
               Exsr AddRec;

          // Copy/Update

           When pSubCmd = 'U' or pSubCmd = 'C';
               exsr UpdRec;

          // Delete

           When pSubCmd = 'D';
               exsr DelRec;

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
     *  GetRec    Get last sequence number in PBOMVERM file
     *----------------------------------------------------------------

      /free
       begsr GetRec;

          SetLL (pWhse) pmarinm;
          ReadE (pWhse) pmarinm;
            DoU %Eof(pmarinm);
              If %Found(pmarinm);
                MeasSeq = MESEQ;
              EndIF;
            ReadE (pWhse) pmarinm;
            EndDO;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  UpdRec    Update record
     *----------------------------------------------------------------

      /free
       begsr UpdRec;
       error = *off;
         Select;

          // Update Measurment file.............
           When pSubCmd = 'U';
             Chain (pWhse :pMesSq) pmarinm;
             If %Found(pmarinm);
               Eval MEDESC = pMesDs;
               Update(e) merec;
             EndIf;

           If %Error;
             pMessage = 'Error Updating Measurement record: '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Desc(' + %trim(pMesDs) + ') '
                    + 'Seq(' + %trim(%char(pMesSq)) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
           Endif;

           Other;
         EndSL;
       endsr;
      /end-free
     *----------------------------------------------------------------
     *  AddRec    Add record
     *----------------------------------------------------------------

      /free
       begsr AddRec;
         error = *off;

      // Add Measurement record.......

          Eval MEWHSE = pWhse;
          Eval MEDESC = pMesDs;
          Eval MESEQ = (MeasSeq + 1);
          Write(e) merec;

          If %Error;
            pMessage = 'Error Creating Mesurement record: '
                   + 'Whse(' + %char(pWhse) + ') '
                   + 'Desc(' + %trim(pMesDs) + ') '
                   + 'Seq(' + %trim(%char(MeasSeq)) + ') '
                   + 'Pgm(' + %trim(#pgm) +')';
          Endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DelRec     Delete record
     *----------------------------------------------------------------

      /free
       Begsr DelRec;

         error = *off;

        // Delete Measurement record.............

         Exec SQL Delete from pmarinm
                  where mewhse = :pwhse
                    and meseq  = :pMesSq;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting Measurement record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Nm(' + %trim(pMesDs) + ') '
                    + 'Seq(' + %trim(%char(pMesSq)) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  errorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

           // Check to see if Marinade recipe name has been used.
         If pSubCmd = 'A';
         exec sql select * into :merecx
                  from pmarinm
                  where mewhse = :pwhse
                    and medesc = :pMesDs;

         if sqlstt = sqlSuccess;
           pMessage = 'Measurement is currently on file';
           error = *on;
           leavesr;
         Endif;
         EndIf;
           // Check to see if Dynamic Name has been entered.

         If pMesDs = ' ';
           pMessage = 'Measurement must have a name';
           error = *on;
           leavesr;
         EndIf;


       endsr;
      /end-free

