      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  CLRSAPDTAQ    Clear SAP Qty In/Out data queues
     *  20 January 2020
     *  Dave Sommerville
     *
     *  Revisions
     *
740 A*    01/30/20  DAS  7.40
     *      - Created
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

     D dqwaitSec       s              5  0 inz(5)
     D dqzeroWait      s              5  0 inz(0)
     D dqnameSend      s             10    inz('SAPQTYIN')
     D dqnameRead      s             10    inz('SAPQTYOUT')
     D dqdataSend      s            100
     D dqdataRead      s            500
     D dqlen           s              5  0
     D dqlib           s             10    inz('*LIBL')
     D dqkey           s             40
     D dqkeylen        s              3  0
     D dqorder         s              2
     D dqsenderlen     s              3  0

     D dqsenderinf     ds
     D   dqbytesrtn                   7p 0
     D   dqbytesavl                   7p 0
     D   dqjobname                   10
     D   dquser                      10
     D   dqjobnum                     6
     D   dqcurruser                  10

     d errMsg          s             99    varying
     d dpCombo         s             20    varying
     d whse            s              3  0
     d item            s             15
     d cmd             s             10

     D waitValue       s              2p 0

     d sapQtyOnHand    s              8  3
     d sapQtyOnOrder   s              8  3
     d sapShipDate     s              8  0
     d sapTransCode    s              1
     d sapLastSold     s              8  0
     d sapMoveAvg      s              8  3
     d sapUnrestrict   s              8  3
     d sapDeliverQty   s              8  3
     d sqpQtyBeingRcv  s              8  3

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

     D SAPGetQty       pr                  extpgm('SAPGETQTY')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     D SAPGetQty       pi
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

     d AddAIDefs       pr

     d ConvertField    pr
     d  parmCount                     3  0
     d  parmName                     30    varying
     d  parmValue                   100    varying

     d DQRead          pr

     d DQReadClear     pr

     d DQSend          pr

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

         // Make sure the return data queue is empty

         DQReadClear();

         // Send whse/item to Java program

         if cmd <> '';
           dqdataSend = cmd;
         else;
           dqdataSend = %char(whse) + ',' + %trim(item) + ',' + pSessId;
         endif;

         DQSend();

         if pOutStr = '' and cmd <>'STOP';

           // Get response (JSON string is returned)

           DQRead();

         endif;

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

           when parmName = 'item';
             item = parmValue;

           when parmName = 'cmd';
             cmd = parmValue;

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
     *  DQRead      Read data queue
     *----------------------------------------------------------------

     p DQRead          b
     d DQRead          pi

      /free

         dqkey = pSessId;
         dqkeylen = %len(dqkey);

       monitor;

      /end-free
     C                   call      'QRCVDTAQ'
     C                   parm                    dqnameRead
     C                   parm                    dqlib
     C                   parm      0             dqlen
     C                   parm                    dqdataRead
     C                   parm                    dqwaitSec
     C                   parm      'EQ'          dqorder
     C                   parm                    dqkeylen
     C                   parm                    dqkey
     C                   parm                    dqsenderlen
     C                   parm                    dqsenderinf
      /free

       on-error;
         pOutStr = '{"msg":"RcvDQ Error x"}';
         errmsg = 'Error calling QRCVDTAQ '
                + %trim(dqlib) + ' / ' + %trim(dqnameRead);
         WrtDebugError();
       endmon;

       if dqlen = 0;
         pOutStr = '{"msg":"Timed Out"}';
         errmsg = 'QRCVDTAQ had len=0 (assumed to be time out)';
         WrtDebugError();
       else;
         monitor;
           pOutStr = %subst(dqdataRead: 1: dqlen);
         on-error;
           pOutStr = '{"msg":"RcvDQ Error (len=' + %char(dqlen) + ')"}';
           errmsg = 'Error extracting dqdataRed from QRCVDTAQ '
                  + dqlib + ' / ' + dqnameRead + ' - len=' + %char(dqlen);
           WrtDebugError();
         endmon;
       endif;

      /end-free
     p                 e

     *----------------------------------------------------------------
     *  DQClearRead  Clear Read data queue
     *----------------------------------------------------------------

     p DQReadClear     b
     d DQReadClear     pi

      /free

       dqkey = pSessId;
       dqkeylen = %len(dqkey);


       dow forever = forever;

         monitor;

      /end-free
     C                   call      'QRCVDTAQ'
     C                   parm                    dqnameRead
     C                   parm                    dqlib
     C                   parm      0             dqlen
     C                   parm                    dqdataRead
     C                   parm                    dqzerowait
     C                   parm      'EQ'          dqorder
     C                   parm                    dqkeylen
     C                   parm                    dqkey
     C                   parm                    dqsenderlen
     C                   parm                    dqsenderinf
      /free

         on-error;
         endmon;

         if dqlen > 0;
           iter;
         else;
           leave;
         endif;

       enddo;

      /end-free
     p                 e

     *----------------------------------------------------------------
     *  DQSend      Send data queue
     *----------------------------------------------------------------

     p DQSend          b
     d DQSend          pi

      /free

       monitor;

         dqlen = %len(%trim(dqdataSend));

      /end-free
     C                   call      'QSNDDTAQ'
     C                   parm                    dqnameSend
     C                   parm                    dqlib
     C                   parm                    dqlen
     C                   parm                    dqdataSend
      /free

       on-error;
         pOutStr = '{"msg":"SndDQ Error"}';
         errmsg = 'Error calling QSNDDTAQ ' + dqlib + ' / ' + dqnameSend;
         WrtDebugError();
       endmon;

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

