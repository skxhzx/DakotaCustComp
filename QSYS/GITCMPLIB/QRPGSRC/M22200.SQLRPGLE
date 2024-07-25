      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M22200  Production Dynamic BOM Edits and Updates
     *  31 Oct 2016
     *  Thomas Bryant
     *
     *  Revisions:
     *
     *    12/01/16  TAB  7.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     FPbomverh  UF A E           k disk
     FPbomvers  UF A E           k disk
     FPbom      IF   E           k disk

     *----------------------------------------------------------------
     *  Working variables
     *----------------------------------------------------------------
     D AlterSeq        S              6  0
     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D phrecx        E ds                  extname(pbomverh) inz(*EXTDFT)
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
	    d  pALtNm         s             45
	    d  pFgItm         s             15
     D  pAltSq         s              6  0

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
	    c                   parm                    pAltNm
	    c                   parm                    pFgitm
	    c                   parm                    pAltSq

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

        // Get Mext available sequence number from PBOMVERH
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
     *  GetRec    Get last sequence number in PBOMVERH file
     *----------------------------------------------------------------

      /free
       begsr GetRec;

          SetLL (pWhse :pFGItm) pbomverh;
          ReadE (pWhse :pFGItm) pbomverh;
            DoU %Eof(pbomverh);
              If %Found(pbomverh);
                AlterSeq = PHASEQ;
              EndIF;
            ReadE (pWhse :pFGItm) pbomverh;
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

          // Create copy of Dynamic BOM.................
           When pSubCmd = 'C';
             Chain (pWhse :pFGItm :AlterSeq) pbomverh;
             If %Found(pbomverh);
               Eval PHASEQ = (AlterSeq +1);
               Eval PHALTN = pAltNm + ' ' + '(Copy)';
               Write(e) phrec;

               SetLL (pWhse :pFGItm :AlterSeq) pbomvers;
                 Reade (pWhse :pFGItm : AlterSeq) pbomvers;
               DoU %Eof(pbomvers);
                If %Found(pbomvers);
                 Eval PXALTN = pAltNm + ' ' + '(Copy)';
                 Eval PXASEQ = (AlterSeq +1);
                 Write(e) pxrec;
                EndIf;
                 Reade (pWhse :pFGItm : AlterSeq) pbomvers;
               EndDo;
             EndIf;

           If %Error;
             pMessage = 'Error Copying Dynamic BOM: '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'FG(' + %trim(pFGItm) + ') '
                    + 'AltN(' + %trim(pAltNm) + ') '
                    + 'Seq(' + %trim(%char(AlterSeq)) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
           Endif;
          // Update Dynamic BOM.................
           When pSubCmd = 'U';
             Chain (pWhse :pFGItm :pAltSq) pbomverh;
             If %Found(pbomverh);
               Eval PHALTN = pAltNm;
               Update(e) phrec;

               SetLL (pWhse :pFGItm :pAltSq) pbomvers;
                 Reade (pWhse :pFGItm : pAltSq) pbomvers;
               DoU %Eof(pbomvers);
                If %Found(pbomvers);
                 Eval PXALTN = pAltNm;
                 Update(e) pxrec;
                EndIf;
                 Reade (pWhse :pFGItm : pAltSq) pbomvers;
               EndDo;
             EndIf;

           If %Error;
             pMessage = 'Error Updating Dynamic BOM: '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'FG(' + %trim(pFGItm) + ') '
                    + 'AltN(' + %trim(pAltNm) + ') '
                    + 'Seq(' + %trim(%char(pAltSq)) + ') '
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

      // Add Dynamic BOM Header..........

          Eval PHWHSE = pWhse;
          Eval PHFGI  = pFgItm;
          Eval PHALTN = pAltNm;
          Eval PHASEQ = (AlterSeq + 1);
          Write(e) phrec;

      // Add Dynamic BOM Detail....(Standard BOM)
          SetLL (pWhse :pFGItm) PBom;
            ReadE (pWhse :pFGItm) PBom;

          DoU %Eof(PBom);
            Eval PXWHSE = BMWHSE;
            Eval PXFGI  = BMFGI;
            Eval PXASEQ = PHASEQ;
            Eval PXSEQ  = BMSEQ;
            Eval PXRMI  = BMRMI;
            Eval PXALTN = pAltNm;
            Eval PXQTYN = BMQTYN;
            Eval PXQTY1 = BMQTY1;
            Eval PXQTY2 = BMQTY2;
            Eval PXPRDQ = BMPRDQ;
            Eval PXSCRF = BMSCRF;
            Eval PXTYPE = BMTYPE;
            Eval PXBCKF = BMBCKF;
            Eval PXPQUF = BMPQUF;
            Eval PXUSEP = BMUSEP;
            Eval PXEFFD = BMEFFD;
            Eval PXEXPD = BMEXPD;
            Write(e) pxrec;
            ReadE (pWhse :pFGItm) PBom;
          EndDo;

          If %Error;
            pMessage = 'Error Creating Dynamic BOM: '
                   + 'Whse(' + %char(pWhse) + ') '
                   + 'FG(' + %trim(pFGItm) + ') '
                   + 'AltN(' + %trim(pAltNm) + ') '
                   + 'Seq(' + %trim(%char(AlterSeq)) + ') '
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

        // Delete Dynamic BOM Header.............

         Exec SQL Delete from pbomverh
                  where phwhse = :pwhse
                    and phfgi  = :pfgitm
                    and phaltn = :pAltnm
                    and phaseq = :pAltSq;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting Dynamic Header: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Nm(' + %trim(pAltNm) + ') '
                    + 'Seq(' + %trim(%char(pAltSq)) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
        // Delete Dynamic BOM Detail records
         Exec SQL Delete from pbomvers
                  where pxwhse = :pwhse
                    and pxfgi  = :pfgitm
                    and pxaltn = :pAltNm
                    and pxaseq = :pAltSq;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting Dynamic Detail: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Nm(' + %trim(pAltNm) + ') '
                    + 'Seq(' + %trim(%char(pAltSq)) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  errorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

           // Check to see if Dynamic Name has been used.
         If pSubCmd = 'A';
         exec sql select * into :phrecx
                  from pbomverh
                  where phwhse = :pwhse
                    and phfgi  = :pfgitm
                    and phaltn = :paltnm;

         if sqlstt = sqlSuccess;
           pMessage = 'Name is on a currently active Dynamic '
                    + 'BOM';
           error = *on;
           leavesr;
         Endif;
         EndIf;
           // Check to see if Dynamic Name has been entered.

         If pAltNm = ' ';
           pMessage = 'Name must be entered for Dynamic '
                    + 'BOM';
           error = *on;
           leavesr;
         EndIf;

       endsr;
      /end-free

