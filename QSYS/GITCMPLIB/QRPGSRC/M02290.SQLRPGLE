      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO)
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M02290  Thomas Item Maintenance (test)
     *  23 Aug 2016
     *  Thomas Bryant
     *
     *  Revisions:
     *
     *    08/23/16  TAB  7.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     FWareHs    if   e           k disk
     f**premwgt   uf a e           k disk
     F**slot11    if   e           k disk
     f**prodlog   uf a e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D pdrec         E ds                  extname(prddate) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Data Structures for SQL Statements (External Files)
     *----------------------------------------------------------------
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
	    d  pItem          s             15
     D  pSecT          s              1
	    d  pWhseD         s              5
     D  pCatW          s              1

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.wrtsessl

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#SLOT

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d error           s               n
     d errmsg          s             50
650aAD logText         s            100
     d opnCount        s              5  0
     D saveVer#        s                   like($slver#)
     d wkError         s               n
     d wkRerr2         s             50

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       GUI User
     *      pPgm        GUI dictionary.program
     *      pWhse       Warehouse
     *      PItem       Item Number
     *      PSecT       Section Type
     *      PWhseD      Warehouse Dept
     *      PCatW       Catch Weight
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
	    c                   parm                    pItem
	    c                   parm                    pSecT
	    c                   parm                    pWhseD
	    c                   parm                    pCatW

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

             If not Error;
             exsr AfterAct;
             EndIf;

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
       // begsr AddRec;

         // Edits have passed and we will now add a record for a specific
         // Mfg Line for a specific Production Date

        //   pdwhse = pWhse;
        //   pdLine = pLine;
        //   pddate = pprdDate;
        //   pdStat = 'O';

        //   exec sql insert into prdDate values(:pdrec);

        //   if sqlstt <> sqlSuccess;
        //     pMessage = 'Error adding record: '
        //              + 'Sqlstt(' + sqlstt + ') '
         //            + 'Whse(' + %char(pWhse) + ') '
         //            + 'Line(' + %trim(%char(pLine)) + ') '
         //            + 'Date(' + %trim(%char(pprdDate)) + ') '
         //            + 'Pgm(' + %trim(#pgm) +')';
         // else;
         //    exsr crtBinvLog;
         // endif;

         // endsr;
      /end-free

     *----------------------------------------------------------------
     *  AfterAct     After action update
     *----------------------------------------------------------------

      /free
       begsr AfterAct;

       error = *off;
       exsr errorCheck;
       if not error;
        //  exsr AddRec;
       endif;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  errorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

         // Check to verify a valid Warehouse has been entered

             Chain (pWhse) WareHs;
                   If Not %Found(WareHs);
                      Error = *On;
                      pMessage = 'Invalid Warehouse, Please correct';
                   EndIf;

          // yesterday
          //   if pprdDate < %Dec(%Date() - %Days(1): *iso);
          //      error = *on;
          //      pMessage = 'The date cannot be less than yesterday';
          //   endif;

          // Make sure Mfg Line has no current open record
          // opnCount = 0;
          // exec sql
          //  select count(*)
          //   into :opncount
          //    from prdDate
          //     where pdwhse = :pwhse and pdline = :pLine
          //           and pdstat = 'O';

          // if opnCount <> 0;
          //    error = *on;
          //    pMessage = 'You can have only 1 open date per Mfg Line.';
          // endif;

          endsr;
      /end-free

     *----------------------------------------------------------------
     *  FldValid   Validate fields
     *----------------------------------------------------------------

      /free
       begsr FldValid;

         exsr errorcheck;

       endsr;
      /end-free

