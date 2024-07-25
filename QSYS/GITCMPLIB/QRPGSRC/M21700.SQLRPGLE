      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M21700  Production Dynamic BOM Detail Edits and Updates
     *  07 Dec 2016
     *  Thomas Bryant
     *
     *  Revisions:
     *
     *    12/07/16  TAB  7.00
     *      - Created.
710 A*    02/03/17  KDE  7.10
     *      - Added field PXUSEP to pBomVers to allow user to specify
     *        whether item is specically used for finised good versus
     *        something like packing materials
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     Fitemprd   if   e           k disk
     Fpbomvers1 uf   e           k disk    Rename(pxrec:pxrecu)
     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D pxrec         E ds                  extname(pbomvers) inz(*EXTDFT)
     D phrec         E ds                  extname(pbomverh) inz(*EXTDFT)

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
	    d  pFgItm         s             15
	    d  pAltNm         s             45
	    d  pRMItm         s             15
     D  pSeq           s              4  0
     D  pQtyn          s              5  0
     D  pQty1          s              3  0
     D  pQty2          s              3  0
     D  pScrap         s              5  4
	    d  pType          s              1
	    d  pBckF          s              1
	    d  pEffD          s              8  0
	    d  pExpD          s              8  0
	    d  pPquf          s              1
	    d  pUsep          s              1
     D  pPrdq          s              9  4

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
	    c                   parm                    pFgitm
	    c                   parm                    pAltNm
	    c                   parm                    pRmitm
	    c                   parm                    pSeq
	    c                   parm                    pQtyn
	    c                   parm                    pQty1
     c                   parm                    pQty2
     c                   parm                    pScrap
     c                   parm                    pType
     c                   parm                    pBckF
     c                   parm                    pEffD
     c                   parm                    pExpD
     c                   parm                    pPquf
     c                   parm                    pUsep
     c                   parm                    pPrdq

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
             ExSR ReSeq;
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

         exec sql insert into pbomvers values(:pxrec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'FG(' + %trim(pFGitm) + ') '
                    + 'Nam(' + %trim(paltnm) + ') '
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
     *  ReSeq  (Resequence detail lines in PBOMVERS file
     *----------------------------------------------------------------

      /free
       BegSr ReSeq;
         Eval SeqNum = 0;

        // SetLL on file PBOMVERS and loop thru

         SetLL (pWhse :pFGItm :phaSeq) Pbomvers1;

            DoW Forever = Forever;
              ReadE (pWhse :pFGItm :phaSeq) Pbomvers1;
              If %Eof(Pbomvers1);
                Leave;
              Else;
                SeqNum = (SeqNum + 1);
                Eval pxSeq = SeqNum;
                Update pxrecu;
              EndIf;
            EndDo;
       EndSR;
      /end-free

     *----------------------------------------------------------------
     *  DelRec     Delete record
     *----------------------------------------------------------------

      /free
       begsr DelRec;

         error = *off;

        // delete Dynamic detail record

         exec sql delete from pbomvers
                  where pxwhse = :pwhse
                    and pxfgi = :pfgitm
                    and pxaltn = :paltnm
                    and pxrmi = :prmitm;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Nam(' + %trimr(paltnm) + ') '
                    + 'RM(' + %trim(pRMItm) + ') '
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
                    + 'on Dynamic BOM (' + %trim(prmitm) + ')';
           error = *on;
           leavesr;
         EndIf;
        // Raw material item must exist and be defined as raw material

         chain(n) (pwhse: prmitm) itemprd;
         if not %found(itemprd);
           pMessage = 'Raw material item not defined as '
                    + 'Production item (' + %trim(prmitm) + ')';
           error = *on;
           leavesr;
         endif;
         if ipprdflg <> 'R';
           pMessage = 'Raw material item not defined as a '
                    + 'raw material item (' + %trim(prmitm) + ')';
           error = *on;
           leavesr;
         endif;

        // If production brkdn flag is not on,
        // Then at least one inventory qty must be entered.

         if pPquf <> 'Y';
           if pQtyn=0 and pQty1=0 and pQty2=0;
             pMessage = 'At least one Inventory Quantity must be entered';
             error = *on;
             leavesr;
           endif;
         endif;

        // Production qty must be entered when production brkdwn flag is on

         if pPquf = 'Y';
           if pPrdq=0;
             pMessage = 'Production Breakdown quantity must be entered';
             error = *on;
             leavesr;
           endif;
         endif;

        // Scrap factor cannot exceed .75

         if pScrap > .75;
           pMessage = 'Scrap Factor too high';
           error = *on;
           leavesr;
         endif;

        // issue type must be either C or M

         if pType<>'C' and pType<>'M';
           pMessage = 'Issue Type must be either Controlled or Minmax';
           error = *on;
           leavesr;
         endif;

        // Backflush must be either Yes or No

         if pBckF<>'Y' and pBckF<>'N';
           pMessage = 'Back Flush has improper value';
           error = *on;
           leavesr;
         endif;

        // Validate Effective date

         test(de) *ISO peffd;
         if %error;
           pMessage = 'Effective Date is invalid '
                    + '(' + %char(peffd) + ')';
           error = *on;
           leavesr;
         endif;

        // Validate expiration date

         test(de) *ISO pexpd;
         if %error;
           pMessage = 'Expiration Date is invalid '
                    + '(' + %char(pexpd) + ')';
           error = *on;
           leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillRec   Fill record fields
     *----------------------------------------------------------------

      /free
       begsr FillRec;

         exec sql select * into :phrec
                  from pbomverh
                  where phwhse = :pwhse
                    and phfgi  = :pfgitm
                    and phaltn = :paltnm;

         if sqlstt = sqlSuccess;
           found = *on;
         endif;

	        pxwhse = pwhse;
	        pxrmi = prmitm;
	        pxfgi = pfgitm;
	        pxaSeq = phaseq;
         pxseq = 99;
         pxaltn = phaltn;
	        pxscrf = pScrap;
	        pxtype = pType;
	        if pPquf = 'Y';
	          pxprdq = pPrdq;
	          pxpquf = pPquf;
	          pxqtyn = 0;
	          pxqty1 = 0;
	          pxqty2 = 0;
	          pxbckf = 'N';
	        else;
	          pxprdq = 0;
	          pxpquf = 'N';
	          pxqtyn = pqtyn;
	          pxqty1 = pqty1;
	          pxqty2 = pqty2;
	          pxbckf = pBckf;
	        endif;
710 A    pxUsep = pUsep;
	        pxeffd = peffd;
	        pxexpd = pexpd;

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

         exec sql select * into :pxrec
                  from pbomvers
                  where pxwhse = :pwhse
                    and pxfgi  = :pfgitm
                    and pxaltn = :paltnm
                    and pxrmi  = :prmitm;

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

         exec sql update pbomvers
                  set pxqtyn = :pxqtyn, pxqty1 = :pxqty1,
                      pxqty2 = :pxqty2, pxscrf = :pxscrf,
                      pxtype = :pxtype, pxbckf = :pxbckf,
                      pxeffd = :pxeffd, pxexpd = :pxexpd,
                      pxprdq = :pxprdq, pxpquf = :pxpquf,
710 A                 pxusep = :pxusep
                  where pxwhse = :pwhse
                    and pxfgi  = :pfgitm
                    and pxaltn = :paltnm
                    and pxrmi  = :prmitm;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'FG(' + %trim(pFGItm) + ') '
                    + 'Seq(' + %trim(paltNm) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free
