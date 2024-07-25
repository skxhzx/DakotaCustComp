      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO)
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  SCLEM   Production Scale Table Maintenance
     *  30 May 2014
     *  Kenneth Elder
     *
     *  Revisions:
     *
640 A*    05/30/14  KDE  6.50
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

650aAFplined    if   e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D screc         E ds                  extname(scale) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
650aAD  pSessId        s             40
650aAD  pUser          s             10
650aAD  pPgm           s             20
     D  pObjLoc        s             10
     D  pSubCmd        s             10
     D  pWhse          s              3  0
	    d  prsta          s              2
	    d  prid           s             15
	    d  prport         s              5  0
	    d  prprtn         s             10
	    d  prdemo         s              1
	    d  prmfgno        s              3  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

650aAD logText         s            100
     d portOK          s               n
     d counter         s              5  0

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

413bA*----------------------------------------------------------------
413bA*  Scale Record
413bA*----------------------------------------------------------------
413bA*
413bA* Fields
413bA*
413bA*    scwhse  -  Warehouse
414dA*    scsta   -  Scale Station
416hA*    scid    -  Scale ID
416hA*    scport  -  Scale TCPIP Port used for communication
417aA*    scuser  -  MRC user logged in when scale in use
417aA*    sclitm  -  Item last produced when scale being used
500nA*    sccust  -  Current customer when scale being used
500nA*    scordn  -  Not currently used.  Will pass Sales Order if needed
510aA*    scweght -  Last weight scanned if scale being used
640hA*    sctare  -  Last Tare if scale being used
510aA*    scwuom  -  Last UOM if scale being used
640hA*    scstat  -  Current status of scale
640hA*    scprtn  -  Defined iSeries Printer Queue for scale
640hA*    sctype  -  User selects either A for Automatic or M for Manual
640hA*    scdest  -  User selects either P for Par Stock or C for Customer
640hA*    sclblc  -  Current label count when scale being used
640hA*    sclstc  -  Last GS1 serial number generated when being used
640hA*    scpts   -  Ping time stamp to know if still communicating
640hA*    scmfgno -  Manufacturing Line Number as defined in PLINED
640hA*    scwo    -  Work Order Number associated to last label
640hA*    scdemo  -  If Y (yes) then this port uses tcpip server for scale
640hA*    scdemowgt  Weight last scanned using demo buttons
640hA*    scdemouom  Based on whether production setting uses lbs or kg
413bA*

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

650aA /copy qcopysrc,p.wrtsessl

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
650aA*      pSessId     Session Id
650aA*      pUser       GUI User
650aA*      pPgm        GUI dictionary.program
     *      pObjLoc     External object location
     *      pSubCmd     A=Add, U/C=Update, D=Delete
     *      pWhse       Warehouse
     *      Scale fields
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
650aAC                   parm                    pSessId
650aAC                   parm                    pUser
650aAC                   parm                    pPgm
     C                   parm                    pObjLoc
     C                   parm                    pSubCmd
     C                   parm                    pWhse
	    c                   parm                    prsta
	    c                   parm                    prid
	    c                   parm                    prport
	    c                   parm                    prprtn
	    c                   parm                    prdemo
     c                   parm                    prmfgno

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
500sA
      /free

         *inlr = *on;
         pMessage = ' ';

650aA    // Write GLOSESSLOG record
650aA    logText = 'objloc:' + pObjLoc;
650aA    wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);

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

         exec sql insert into scale values(:screc);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Station(' + %trim(scsta) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
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
           when pSubCmd = 'A';
             if found;
               exsr UpdRec;
             else;
               exsr AddRec;
             endif;
           when pSubCmd = 'U' or pSubCmd = 'C';
             if found;
               exsr UpdRec;
             else;
               exsr AddRec;
             endif;
           when pSubCmd = 'D';
             if found;
               exsr DelRec;
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
     *  DelRec    Delete record
     *----------------------------------------------------------------

      /free
       begsr DelRec;

         error = *off;

         exec sql delete from scale
                  where scsta = :prsta
                    and scwhse = :pWhse;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Station(' + %trim(scsta) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  errorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

          exsr chkPort;
          // check to make sure ip port is unique
          if not portOK and psubcmd <> 'D';
             pMessage = 'TCPIP Port must be unique';
             error = *on;
          endif;

          // check to make sure mfg line number is valid
          chain (pwhse:prmfgno) plined;
          if not %found(plined) and psubcmd <> 'D';
             pMessage = 'Please enter a valid Mfg Line Number';
             error = *on;
          endif;

          // station cannot be empty
          if (prsta = '' or prsta='00') and psubcmd <> 'D';
             pMessage = 'Station cannot be blank or zero';
             error = *on;
          endif;

          // Station ID must be either name or ip address
          if prid = '' and psubcmd <> 'D';
             pMessage = 'Scale ID must either be valid DNS' +
                           ' name or valid IP address';
             error = *on;
          endif;

          // port must represent valid ip port that scale is communicating
          if prport = 0 and psubcmd <> 'D';
             pMessage = 'Port must be a matching IP port that the ' +
                         'respective Scale is communicating';
             error = *on;
          endif;

          // enter a valid iSeries printer queue that this scale will
          // print labels
          if prprtn = '' and psubcmd <> 'D';
             pMessage = 'Printer must be valid iSeries print queue';
             error = *on;
          else;
      /end-free

     C                   call(e)   'CHKFOROUTQ'
     C                   parm                    prprtn
     C                   parm                    prtnerr          10

      /free
             if prtnerr = 'INVALID' and psubcmd <> 'D';
                pMessage = 'Printer must be valid iSeries print queue';
                error = *on;
             endif;

          endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillRec   Fill record fields
     *----------------------------------------------------------------

      /free
       begsr FillRec;

         // move in only the changable data.  Remaining data is maintained
         // by socket processes when scale connects and operates

	        scwhse = pWhse;
	        scid = prid;
	        scsta = prsta;
	        scport = prport;
	        scprtn = prprtn;
	        scdemo = prdemo;
	        scmfgno = prmfgno;

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

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetRec    Get record
     *----------------------------------------------------------------

      /free
       begsr GetRec;

         found = *off;

         exec sql select * into :screc
                  from scale
                  where scsta = :prsta
                    and scwhse = :pWhse;

         if sqlstt = sqlSuccess;
           found = *on;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ChkPort   Ensure that IP Port being requested is not already
     *            being used on another scale
     *----------------------------------------------------------------

      /free
       begsr chkPort;

         portOK = *off;

         exec sql select count(*) into :counter
                  from scale
                  where scport = :prport
                    and scwhse = :pWhse
                    and scsta <> :prsta;

         if sqlstt = sqlSuccess;
           // if some other scale is using this port an error is thrown
           if counter <> 0;
              // if port found on other scales return error
              portOK = *off;
           else;
              // if port not found on other scale, no error
              portOK = *on;
           endif;
         else;
           // if record not found it is OK to use
           portOK = *on;
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

         exec sql update scale
                  set scid = :prid, scport = :prport,
                      scprtn = :prprtn, scdemo = :prdemo,
                      scmfgno = :prmfgno
                  where scsta = :prsta
                    and scwhse = :pWhse;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Station(' + %trim(scsta) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free
