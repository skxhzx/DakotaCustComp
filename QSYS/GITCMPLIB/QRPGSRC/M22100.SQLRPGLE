      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO)
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M22100  Production Sub Bill of Material Edits and Updates
     *  31 Oct 2016
     *  Thomas Bryant
     *
     *  Revisions:
     *
     *    10/31/16  TAB  7.00
     *      - Created.
710 A*    02/02/17  KDE  7.10
     *      - Added field IPUSEP to Itemprd.  Controls whether
     *        item is used specifically in Finished Good
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     Fitemprd   if   e           k disk
     fpwrkordps if   e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D sbrec         E ds                  extname(pbomsub) inz(*EXTDFT)
     D bmrec         E ds                  extname(pbom) inz(*EXTDFT)

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
	    d  pFgItm         s             15
	    d  pRMItm         s             15
	    d  pAMItm         s             15
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
     D  pPrdq          s              9  4
	    d  pBWO#          s             13
710 Ad  pUsep          s              1

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
	    c                   parm                    pRmitm
	    c                   parm                    pAmitm
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
     c                   parm                    pPrdq
     c                   parm                    pBwo#
710 Ac                   parm                    pUsep

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

         exec sql insert into pbomsub values(:sbrec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'AM(' + %trim(pAMitm) + ') '
                    + 'Seq(' + %trim(%char(pSeq)) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;

        // Create *AUTO generated record in PBOMSUB
         exsr FillRec2;
         exec sql insert into pbomsub values(:sbrec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding *AUTO record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'AM(' + %trim(pAMitm) + ') '
                    + 'Seq(' + %trim(%char(pSeq)) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;
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

         // delete BOM line

         exec sql delete from pbomsub
                  where sbwhse = :pwhse
                    and sbrmi = :prmitm
                    and sbami = :pamitm
                    and sbfgi = :pfgitm;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'AM(' + %trim(pAMItm) + ') '
                    + 'Seq(' + %trim(%char(pSeq)) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
        // Delete *AUTO generated record in PBOMSUB
         exec sql delete from pbomsub
                  where sbwhse = :pwhse
                    and sbrmi = :pamitm
                    and sbami = :prmitm
                    and sbfgi = :pfgitm;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting *AUTO record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'AM(' + %trim(pAMItm) + ') '
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

            // Check to see id alternate item same as primary raw material

         If pAMItm = pRMItm;
           pMessage = 'Substitue item cannot be the same '
                    + 'as Primary Raw material item';
           error = *on;
           leavesr;
         EndIf;

         // Raw material item must exist and be defined as raw material

         chain(n) (pwhse: pamitm) itemprd;
         if not %found(itemprd);
           pMessage = 'Raw material item not defined as '
                    + 'Production item (' + %trim(prmitm) + ')';
           error = *on;
           leavesr;
         endif;
         if ipprdflg <> 'R' and ipprdflg<>'C';
           pMessage = 'Raw material item not defined as a '
                    + 'raw material item (' + %trim(prmitm) + ')';
           error = *on;
           leavesr;
         endif;

         // If production brkdn flag is not on,
         // Then at least one inventory qty must be entered.

         if pPquf <> 'Y';
           if pQtyn=0 and pQty1=0 and pQty2=0;
             pMessage = 'At least one Inventory Quantity must be entered';
             error = *on;
             leavesr;
           endif;
         endif;

         // Production qty must be entered when production brkdwn flag is on

         if pPquf = 'Y';
           if pPrdq=0;
             pMessage = 'Production Breakdown quantity must be entered';
             error = *on;
             leavesr;
           endif;
         endif;

         // Scrap factor cannot exceed .75

         if pScrap > .75;
           pMessage = 'Scrap Factor too high';
           error = *on;
           leavesr;
         endif;

         // issue type must be either C or M

         if pType<>'C' and pType<>'M';
           pMessage = 'Issue Type must be either Controlled or Minmax';
           error = *on;
           leavesr;
         endif;

         // Backflush must be either Yes or No

         if pBckF<>'Y' and pBckF<>'N';
           pMessage = 'Back Flush has improper value';
           error = *on;
           leavesr;
         endif;

         // Validate Effective date

         test(de) *ISO peffd;
         if %error;
           pMessage = 'Effective Date is invalid '
                    + '(' + %char(peffd) + ')';
           error = *on;
           leavesr;
         endif;

         // Validate expiration date

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

	        sbwhse = pwhse;
	        sbseq = pSeq;
	        sbrmi = prmitm;
	        sbfgi = pfgitm;
	        sbami = pamitm;
	        sbscrf = pScrap;
	        sbtype = pType;
	        if pPquf = 'Y';
	          sbprdq = pPrdq;
	          sbpquf = pPquf;
	          sbqtyn = 0;
	          sbqty1 = 0;
	          sbqty2 = 0;
	          sbbckf = 'N';
	        else;
	          sbprdq = 0;
	          sbpquf = 'N';
	          sbqtyn = pqtyn;
	          sbqty1 = pqty1;
	          sbqty2 = pqty2;
	          sbbckf = pBckf;
	        endif;
710 A    sbusep = pUsep;
	        sbeffd = peffd;
	        sbexpd = pexpd;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillRec2  Fill record fields for *AUTO genreated item
     *----------------------------------------------------------------

      /free
       begsr FillRec2;
         Exec SQL select * into :bmrec
                  From pBOM
                  Where bmwhse = :pWhse and
                        bmfgi  = :pFGItm and
                        bmrmi  = :pRMItm;

           If sqlstt = sqlSuccess;
             SBWHSE = pWHSE;
             SBFGI  = pFGItm;
             SBRMI  = pAMItm;
             SBAMI  = pRMItm;
             SBSEQ  = BMSEQ;
             SBQTYN = BMQTYN;
             SBQTY1 = BMQTY1;
             SBQTY2 = BMQTY2;
             SBPRDQ = BMPRDQ;
             SBSCRF = BMSCRF;
             SBTYPE = BMTYPE;
             SBBCKF = BMBCKF;
             SBPQUF = BMPQUF;
             SBUSEP = BMUSEP;
             SBEFFD = BMEFFD;
             SBEXPD = BMEXPD;
             SBWO#  = '*AUTO';
           EndIf;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FldValid   Validate fields
     *----------------------------------------------------------------

      /free
       begsr FldValid;

         error = *off;

         // Validate input

         if pSubCmd <> 'D';
           exsr errorcheck;
           if error;
             leavesr;
           endif;
         endif;

         // See if PBOMSUB record exists for item

         exsr GetRec;

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

         exec sql select * into :sbrec
                  from pbomsub
                  where sbwhse = :pwhse
                    and sbseq = :pseq
                    and sbrmi = :prmitm
                    and sbami = :pamitm
                    and sbfgi = :pfgitm;

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

         exec sql update pbomsub
                  set sbqtyn = :sbqtyn, sbqty1 = :sbqty1,
                      sbqty2 = :sbqty2, sbscrf = :sbscrf,
                      sbtype = :sbtype, sbbckf = :sbbckf,
                      sbeffd = :sbeffd, sbexpd = :sbexpd,
                      sbprdq = :sbprdq, sbpquf = :sbpquf,
                      sbusep = :sbusep
                  where sbwhse = :pwhse
                    and sbseq = :pseq
                    and sbrmi = :prmitm
                    and sbami = :pamitm
                    and sbfgi = :pfgitm;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'FG(' + %trim(pFGItm) + ') '
                    + 'Seq(' + %trim(%char(pSeq)) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free
