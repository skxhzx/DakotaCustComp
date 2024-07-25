      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETDOORGUI   Get door for route using GENFNC
     *  29 July 2020
     *  Dave Sommerville
     *
     *  Revisions:
     *
740 A*    07/29/20  DAS  7.40
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *  This program is called via the GENFNC SQL Stored Procedure
     *
     *  The parameters are strings containing value pairs,
     *  with multiple pairs being separated by a '|', for example:
     *
     *    fieldname1=value|fieldname2=value|fieldname3=value
     *
     *  The returned string is status from CHKORDAUD.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Foptions   if   e           k disk
     Fdocmtrx2  if   e           k disk
     Frtecsum1  if   e           k disk
     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------

     D/copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d dbgflgExists    s               n
     d debug           s               n
     d debugAfter      s               n
     d debugBefore     s               n
     d debugLoc        s              1

     d errMsg          s             99    varying
     d dpCombo         s             20    varying

     d whse            s              3  0
     d rtid            s              5

416dA*----------------------------------------------------------------
416dA*  *DOCDOOR -  Dock Door options
416dA*----------------------------------------------------------------
416dA*
416dA* Fields
416dA*
417 M*    OPATYP  -  Dock door assignment. 0=No assigment,1=Auto,2=Manual.
416dA*    OPLTYP  -  Dock door loading. 1=Single door, 2=By Department.
416dA*
416dA* Data structure
416dA*
416dAD opdata          ds
416dAD  opatyp                 1      1
416dAD  opltyp                 2      2

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pParmStr    String of '|' delimited parameters
     *
     *    Returned Parameters
     *      pOutStr     Return string in JSON format
     *
     *----------------------------------------------------------------

     D GetDoorGUI      pr                  extpgm('GETDOORGUI')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     D GetDoorGUI      pi
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d GetDoor         pr

     d GetDoorSingle   pr

     d GetDoorMult     pr

     d ConvertField    pr
     d  parmCount                     3  0
     d  parmName                     30    varying
     d  parmValue                   100    varying

     d ExtractParms    pr

     d ExtractParmStr  pr

     d WrtBeforeDebug  pr
     d WrtAfterDebug   pr
     d WrtDebugError   pr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         errMsg = '';
         pOutStr = '';

         debug = *off;
         debugBefore = *off;
         debugAfter = *off;
         if dbgflgExists;
           chain(e) (#pgm) bfcdbgflg;
           if %found(bfcdbgflg);
             select;
               when bdfflag = 1;
                 debug = *on;
                 debugAfter = *on;
               when bdfflag = 2;
                 debug = *on;
                 debugBefore = *on;
               when bdfflag = 3;
                 debug = *on;
                 debugBefore = *on;
                 debugAfter = *on;
             endsl;
           endif;
         endif;

         // Combine dictionary/program

         dpCombo = %trim(pDict) + '.' + pPgm;

         // Write out 'Before' Debug info

         if debugBefore;
           debugLoc = 'B';
           wrtBeforeDebug();
         endif;

         // Extract parameters from delimited string

         ExtractParms();

         // Get out if error

         if errMsg <> '';
           pOutStr = '{"errMsg":"' + errMsg + '"}';
           WrtDebugError();
           return;
         endif;

         // Do processing
         // Note, we are just passing back value, not a JSON string

         GetDoor();

         // Write out 'After' Debug info

         if debugAfter;
           debugLoc = 'A';
           wrtAfterDebug();
         endif;

         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         open(e) bfcdbgflg;
         if %error;
           dbgflgExists = *off;
         else;
           dbgflgExists = *on;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetDoor    Get door(s) for route (code taken rom M01600)
     *----------------------------------------------------------------

     p GetDoor         b
     d GetDoor         pi

      /free

         chain (whse: '*DOCDOOR') options;
         if not %found(options);
           opatyp = '0';
         endif;

         // See if door has been assigned

         if opltyp = '2';
           GetDoorMult();
         else;
           GetDoorSingle();
         endif;

        return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetDoorSingle   Get single door for route (code taken rom M01600)
     *----------------------------------------------------------------

     p GetDoorSingle   b
     d GetDoorSingle   pi

      /free

         setll (whse: rtId) docmtrx2;
         reade (whse: rtId) docmtrx2;

         if %eof(docmtrx2);
           dmdoor = 0;
         endif;

         if dmdoor = 0;
           pOutStr = 'Not Assigned';
         else;
           //pOutStr = %char(dmdoor) + ' (' + dmatyp + ')';
           pOutStr = %char(dmdoor);
         endif;

        return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetDoorMult   Get multiple doors for route (code taken rom M01600)
     *----------------------------------------------------------------

     p GetDoorMult     b
     d GetDoorMult     pi

     *  Local Variables

     d lastDept        s                   like(rcdrdp)

      /free

         // Loop through RTECSUM records

         lastDept = 'a';
         setll (whse: rtId) rtecsum1;

         dow forever = forever;

           reade (whse: rtId) rtecsum1;

           if %eof(rtecsum1);
             leave;
           endif;

           // Skip duplicate compartment records

           if rcdrdp = lastDept;
             iter;
           endif;

           lastDept = rcdrdp;

           // See if door has been assigned

           setll (whse: rtId: rcdrdp) docmtrx2;
           reade (whse: rtId: rcdrdp) docmtrx2;

           if %eof(docmtrx2);
             dmdoor = 0;
           endif;

           if pOutStr > '';
             pOutStr += ', ';
           endif;

           if dmdoor = 0;
             pOutStr += %trim(rcdrdp) + ' - Not Assigned';
           else;
             pOutStr += %trim(rcdrdp) + ' - '
                     + %char(dmdoor);
                     //+ %char(dmdoor) + ' (' + dmatyp + ')';
           endif;

         enddo;

        return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ConvertField   Convert incoming field to DRI field
     *----------------------------------------------------------------

     p ConvertField    b
     d ConvertField    pi
     d  parmCount                     3  0
     d  parmName                     30    varying
     d  parmValue                   100    varying

      /free

       monitor;

         select;

           when parmName = 'whse';
             if parmValue = '';
               parmValue = '0';
             endif;
             whse = %dec(parmValue: 3: 0);

           when parmName = 'rtid';
             rtid = parmValue;

         endsl;

       on-error;

         errMsg = 'Error extracting parameter '
                + %char(parmCount) + ' '
                + parmName + ' '
                + '(' + parmValue + ')'
                + '('
                + %trimr(#Job) + '/'
                + %trimr(#JobNbr) + '/'
                + %trimr(#user)
                + ')';

       endmon;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ExtractParms   Extract parms from parameter string
     *----------------------------------------------------------------

     p ExtractParms    b
     d ExtractParms    pi

      /free

         // Error if parameter string is blank

         if pParmStr = '';
           errMsg = 'Error: Parameter string is empty '
                  + '('
                  + %trimr(#Job) + '/'
                  + %trimr(#JobNbr) + '/'
                  + %trimr(#user)
                  + ')';
           return;
         endif;

         // Extract parms for string 1

         ExtractParmStr();

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ExtractParmStr   Extract parms from single parameter string
     *----------------------------------------------------------------

     p ExtractParmStr  b
     d ExtractParmStr  pi

     * Local Variables

     D parmCount       s              3  0
     D parmGroup       s            200    varying
     D parmLen         s              5  0
     D parmName        s             30    varying
     D parmStrLen      s              5  0
     D parmValue       s            100    varying
     D pos             s              5  0
     D start           s              5  0

      /free

       // Parameters are separated by '|'

       start = 1;
       parmStrLen = %len(pParmStr);
       parmCount = 0;

       dow start <= parmStrLen;

         // Extract parameter ('fldname=value')

         pos = %scan('|': pParmStr: start);

         parmCount += 1;

         if pos = 0;
           parmGroup = %subst(pParmStr: start);
           start = parmStrLen + 1;
         else;
           parmLen = pos - start;
           parmGroup = %subst(pParmStr: start: parmLen);
           start = pos + 1;
         endif;

         // Extract parameter name

         pos = %scan('=': parmGroup: 1);

         // If no '=' found, invalid group.

         if pos = 0;
           errMsg = 'Error: Invalid parameter group '
                   + %char(parmCount) + ' '
                   + '(' + parmGroup + ')'
                   + '('
                   + %trimr(#Job) + '/'
                   + %trimr(#JobNbr) + '/'
                   + %trimr(#user)
                   + ')';
           leave;
         endif;

         parmName = %subst(parmGroup: 1: pos - 1);

         // Extract parameter value

         parmLen = %len(parmGroup);

         if parmLen = pos;
           parmValue = '';
         else;
           parmValue = %subst(parmGroup: pos + 1);
         endif;

         // Convert extracted value and put into DRI field

         ConvertField(parmCount: parmName: parmValue);
         if errMsg <> '';
           leave;
         endif;

       enddo;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  wrtBeforeDebug  Write out 'Before' debug info
     *----------------------------------------------------------------

     p WrtBeforeDebug  b
     d WrtBeforeDebug  pi

      /free

         bdtype = 'PARMS';

         bdvalues = 'pSessId:' + %trimr(pSessId) + ', '
                  + 'dbgloc:' + %trimr(debugLoc) + ', '
                  + 'pUser:' + %trimr(pUser) + ', '
                  + 'pDict:' + %trimr(pDict) + ', '
                  + 'pPgm:' + %trimr(pPgm) + ', '
                  + 'pOutStr:' + %trimr(pOutStr) + ', '
                  + 'pParm:' + pParmStr;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

         return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  wrtAfterDebug  Write out 'After' debug info
     *----------------------------------------------------------------

     p WrtAfterDebug   b
     d WrtAfterDebug   pi

      /free

         bdtype = 'PARMS';

         bdvalues = 'pSessId:' + %trimr(pSessId) + ', '
                  + 'dbgloc:' + %trimr(debugLoc) + ', '
                  + 'pUser:' + %trimr(pUser) + ', '
                  + 'pDict:' + %trimr(pDict) + ', '
                  + 'pPgm:' + %trimr(pPgm) + ', '
                  + 'pOutStr:' + %trimr(pOutStr) + ', '
                  + 'pParm:' + pParmStr;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

         return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  wrtDebugError  Write out debug error
     *----------------------------------------------------------------

     p WrtDebugError   b
     d WrtDebugError   pi

      /free

         bdtype = 'ERROR';

         bdvalues = errMsg;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

         return;

      /end-free

     p                 e

