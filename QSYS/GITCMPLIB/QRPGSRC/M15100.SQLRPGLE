      /copy *libl/qcopysrc,hspecs
     h DFTACTGRP(*NO)
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M15100  Production MFG Bill of Material Edits and Updates
     *  12 Aug 2014
     *  Kenneth Elder
     *
     *  Revisions:
     *
     *    08/12/14  KDE  6.50
     *      - Created.
700 A*    11/10/16  KDE  7.00
     *      - Allow up to 99 percent waste
710 A*    02/02/17  KDE  7.10
     *      - Add field BMUSEP to control whether item on BOM is
     *        used directly in FG versus something like packing
710aA*    02/09/17  TAB  7.10a
     *      - Add new check for component item when adding to
     *        the BOM.
720 A*    04/06/18  KDE  7.20
     *      - Add logic to reflect scrap facotr on BOM as Yield to
     *        user instead of scrap but store as scrap
720aA*    01/03/19  KDE  7.20a
     *      - Add logic to prevent recursive bill of material entries
730aA*    01/18/19  KDE  7.30a
     *      - Allow 100% Yield versus .9999
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     Fitemprd   if   e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

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
	    d  pArr3w         s             15    dim(500)
	    d  pArr3c         s            500    dim(100)
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
710 Ad  pUsep          s              1
     D  pPrdq          s              9  4
     d  pSearchVal     s           5000

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

650aAD logText         s            100
720 AD  wkQtyn         s              5  0
720 AD  wkQty1         s              3  0
720 AD  wkQty2         s              3  0
720aAd  bCmd           s              2
720aAd  bWhse          s              3
720aAd  bRtnMsg        s            100
     d  barr           s             15    dim(100)
     d  barr2          s             15    dim(100)
     d  bacntr         s              3    inz('000')
     d  bacntr2        s              3    inz('000')
     d  blcntr         s              3    inz('000')
     d  wfgitm         s            100

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

     * Call to BOM Procedures
     d* pCompontWo     PR         65000
     d*  pwhse                        3
     d*  pFinGood                    15
     d*  pCmd                         1
     d*  parr1                       15    dim(100)
     d*  parr2                       15    dim(100)
     d*  pcntr                        3
     d*  pcntr2                       3
     d*  pLevel                       3
720aAd pcompwo         pr                  extpgm('PCOMPWO')
720aAd  parm1                         3
720aAd  parm2                         2
720aAd  parm3                       100
720aAd  parm4                        15
720aAd  parm5                       100
720aAd  parm6                        15    dim(500)
720aAd  parm7                       500    dim(100)

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
710 Ac                   parm                    pUsep
     c                   parm                    pPrdq

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

700 A    // set SQL options in case not set at compile time
700 A    exec sql
700 A      set Option Commit=*none, Dlyprp=*Yes,
700 A                 Closqlcsr = *ENDMOD;

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

         exec sql insert into pbom values(:bmrec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'FG(' + %trim(pFGitm) + ') '
                    + 'Seq(' + %trim(%char(pSeq)) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;
         if pmessage = *blanks
            and psubcmd = 'A';
720aA       bWhse = %char(pWhse);
            bcmd = 'BA';
            parr3w = *blanks;
            parr3c = *blanks;
            bRtnMsg = *blanks;
            wFgItm = pFgItm;
720aA       pcompwo (bWhse:bcmd:wFgItm:pRmItm:bRtnMsg:parr3w:parr3c);
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

         exec sql delete from pbom
                  where bmwhse = :pwhse
                    and bmseq = :pseq
                    and bmrmi = :prmitm
                    and bmfgi = :pfgitm;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'FG(' + %trim(pFGItm) + ') '
                    + 'Seq(' + %trim(%char(pSeq)) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;
         if pmessage = *blanks;
720aA       bWhse = %char(pWhse);
            bcmd = 'BD';
            parr3w = *blanks;
            parr3c = *blanks;
            bRtnMsg = *blanks;
            wFgItm = pFgItm;
720aA       pcompwo (bWhse:bcmd:wFgItm:pRmItm:bRtnMsg:parr3w:parr3c);
         endif;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  errorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

         // Raw material item must exist and be defined as raw material

         chain(n) (pwhse: prmitm) itemprd;
         if not %found(itemprd);
           pMessage = 'Raw material item not defined as '
                    + 'Production item (' + %trim(prmitm) + ')';
           error = *on;
           leavesr;
         endif;

710aD    // if ipprdflg <> 'R';
710aA    if ipprdflg <> 'R' and ipprdflg <> 'C';
710aD       //   pMessage = 'Raw material item not defined as a '
710aD       //            + 'raw material item (' + %trim(prmitm) + ')';
710aA          pMessage = 'Item (' + %trim(prmitm) + ') ' + 'not defined as a '
710aA                   + 'raw material or component item';
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

730aD    // Yield cannot exceed .9999
730aA    // Yield cannot exceed 1.0000

730aD    //if pScrap > .9999;
730aA    if pScrap > 1.0000;
730aD      //pMessage = 'Yield cannot exceed .9999';
730aA      pMessage = 'Yield cannot exceed 1.0000';
           error = *on;
           leavesr;
         endif;

700 M    // Yield cannot be zero

700 A    if pScrap = 0;
           pMessage = 'Yield cannot be zero';
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

720aA    // Ensure no recursive calls within BOMS for reference fg/component
         if pSubCmd = 'A';
720aA       bCmd='BI';
720aA       bWhse = %char(pWhse);
            parr3w = *blanks;
            parr3c = *blanks;
            bRtnMsg = *blanks;
720aA       //pMessage = %trim(%subst(pCompontWo(bWhse:pFgItm:bCmd:
720aA       //           barr:barr2:bacntr:bacntr2:blcntr):1:99));
720aA       bRtnMsg = *blanks;
            wFgItm = pFgItm;
720aA       pcompwo (bWhse:bcmd:wFgItm:pRmItm:bRtnMsg:parr3w:parr3c);
720aA       pMessage = %subst(bRtnMsg:1:99);
720aA       if %subst(pMessage:1:6) = '*ERROR';
720aA         pMessage = %trim(%subst(pMessage:10:89));
720aA         error = *on;
720aA         leavesr;
720AA       ELSE;
720aA         pMessage=*blanks;
720aA       endif;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillRec   Fill record fields
     *----------------------------------------------------------------

      /free
       begsr FillRec;

	        bmwhse = pwhse;
	        bmseq = pSeq;
	        bmrmi = prmitm;
	        bmfgi = pfgitm;
720 D    //bmscrf = pScrap;
	        bmtype = pType;
	        if pPquf = 'Y';
	          bmprdq = pPrdq;
	          bmpquf = pPquf;
	          bmqtyn = 0;
	          bmqty1 = 0;
	          bmqty2 = 0;
	          bmbckf = 'N';
720 A      if pScrap = *zeros;
720 A         bmscrf = *zeros;
720 A      else;
720 A         // Scrap factor is passed as Yield and we store as Scrap
720 A         bmscrf = ((bmprdq / pScrap) / bmprdq) - 1;
720 A      endif;
	        else;
	          bmprdq = 0;
	          bmpquf = 'N';
	          bmqtyn = pqtyn;
	          bmqty1 = pqty1;
	          bmqty2 = pqty2;
	          bmbckf = pBckf;
720 A      if pScrap = *zeros;
720 A         bmscrf = *zeros;
720 A      else;
720 A         if pQtyn = *zeros;
720 A            wkQtyn = 1;
720 A         else;
720 A            wkQtyn = pQtyn;
720 A         endif;
720 A         if pQty1 = *zeros;
720 A            wkQty1 = 1;
720 A         else;
720 A            wkQty1 = pQty1;
720 A         endif;
720 A         if pQty2 = *zeros;
720 A            wkQty2 = 1;
720 A         else;
720 A            wkQty2 = pQty2;
720 A         endif;
720 A         // Scrap factor is passed as Yield and we store as Scrap
720 A         bmscrf = (((wkQtyn*wkqty1*wkqty2)/pScrap) /
720 A                    (wkQtyn*wkQty1*wkQty2)) -1;
720 A      endif;
	        endif;
710 A    bmusep = pUsep;
	        bmeffd = peffd;
	        bmexpd = pexpd;

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

         // See if PBOM record exists for item

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

         exec sql select * into :bmrec
                  from pbom
                  where bmwhse = :pwhse
                    and bmseq = :pseq
                    and bmfgi = :pfgitm;

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

         exec sql update pbom
                  set bmqtyn = :bmqtyn, bmqty1 = :bmqty1,
                      bmqty2 = :bmqty2, bmscrf = :bmscrf,
                      bmtype = :bmtype, bmbckf = :bmbckf,
                      bmeffd = :bmeffd, bmexpd = :bmexpd,
                      bmprdq = :bmprdq, bmpquf = :bmpquf,
710 A                 bmusep = :bmusep
                  where bmwhse = :pwhse
                    and bmseq = :pseq
                    and bmfgi = :pfgitm;

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
