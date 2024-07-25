      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO)
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  PREXCM      Clear Runner Exceptions Definition
     *  14 September 2017
     *  Mike Rooker
     *
     *  Revisions:
     *
     *    09/14/17  MR   7.10
     *      - Created.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     F*ITMEXCP1  uf a e           k disk
     F*WORKOPT   uf   e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D exrec         E ds                  extname(itmexcp) inz(*EXTDFT)

     D CVTDTE          PR                  Extpgm('CVTDTE')
     D $CVTDT                       132
     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  pSessId        s             40
     D  pUser          s             10
     D  pDict          s             10
     D  pPgm           s             20
     D  pObjLoc        s             10
     D  pSubCmd        s             10
	    D  pWhse          s              3  0
	    D  pWhdp          s              5
	    D  pStyp          s              1
     D  pItem          S             15
	    D  pGDate         s              8  0
	    D  pGTime         s              6  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d today           s              8  0
     d curtime         s              6  0
     D logText         s            100

     I*----------------------------------------------------------------
     I*  Called program parameters
     I*
     D$cvtdt           DS
     D $cvcmd                  1      8
     D $cvprg                  9     18
     D $cvd6i                 19     24
     D $cvd8i                 25     32
     D $cvd6o                 33     38  0
     D $cvd8o                 39     46  0
     D $cvsto                 47     64
     D $cvrtn                 65     72
     D $cverm                 73    132
     D $cvmsg                 73     76
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
     *      pDict       GUI dictionary
     *      pPgm        GUI program
     *      pObjLoc     External object location
     *      pSubCmd     A=Add, U/C=Update, D=Delete
     *      pWhse       Warehouse
     *      pWhdp       Whse Dept
     *      pStyp       Section Type
     *      pItem       Item
     *      pGDate      Generated Date
     *      pGTime      Generated Time
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
     C                   parm                    pDict
     C                   parm                    pPgm
     C                   parm                    pObjLoc
     C                   parm                    pSubCmd
     C                   parm                    pWhse
650bAC                   parm                    pWhdp
650bAC                   parm                    pStyp
650bAC                   parm                    pItem
650bAC                   parm                    pGDate
650bAC                   parm                    pGTime

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
     *  AfterAct     After action update
     *----------------------------------------------------------------

      /free
       begsr AfterAct;

       error = *off;
       exsr errorCheck;
       if not error;

         exsr GetRec;

         select;
           when pSubCmd = 'U';
             if found;
               exsr UpdRec;
             endif;
           other;
             pMessage = 'Invalid command sent: ' + pSubCmd
                      + %trim(pSubCmd)
                      + ' (' + %trim(#pgm) +')';
         endsl;
       endif;

       endsr;
      /end-free


     *----------------------------------------------------------------
     *  errorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

         if pMessage <> '';
           error = *on;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillRec   Fill record fields
     *----------------------------------------------------------------

      /free
       begsr FillRec;

         // move in only the changable data.

	        //usemp# = pEmpNo;

         //Convert today's date into century format.

                           eval $cvcmd = '*CURCMD ';
                           cvtdte ($cvtdt);
                           eval today = $cvd8o;
                           eval curtime = %dec(%time():*HMS);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FldValid   Validate fields
     *----------------------------------------------------------------

      /free
       begsr FldValid;

         if pSubCmd = 'D';
           leavesr;
         endif;

         exsr errorcheck;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetRec    Get record
     *----------------------------------------------------------------

      /free
       begsr GetRec;

         found = *off;

        exec sql select * into :exrec
                  from itmexcp1
                  where exwhse = :pWhse
                  and   exwhdp = :pWhdp
                  and   exstyp = :pStyp
                  and   exitem = :pItem
                  and   exgdte = :pGDate
                  and   exgtim = :pGTime;

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

         exec sql update itmexcp1
                  set exesta = 4, exuser = :puser,
                  excdte = :today,
                  exctim = :curTime
                  where exwhse = :pWhse
                  and   exwhdp = :pWhdp
                  and   exStyp = :pStyp
                  and   exItem = :pItem
                  and   exGDte = :pGDate
                  and   exGTim = :PGTime;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'ExWhse(' + %trim(%char(pWhse)) + ') '
                    + 'ExWhdp(' + %trim(pwhdp) + ') '
                    + 'ExStyp(' + %trim(pStyp) + ') '
                    + 'ExItem(' + %trim(pItem) + ') '
                    + 'ExGDte(' + %trim(%char(pGDate)) + ') '
                    + 'ExGTim(' + %trim(%char(pGTime)) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
            exec sql delete from workopt
               where wkousr = :pUser and wkopgm = 'EX170A';
         endif;

       endsr;
      /end-free
