      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M28900U    Close Ouder audit using GENPRC
     *  21 January 2019
     *  Dave Sommerville
     *
     *  Revisions:
     *
730 A*    01/21/19  DAS  7.30
     *      - Created.
730aA*    06/14/19  KDE  7.30a
     *      - Only allow user to close Audit once all transactions
     *        are picked and flags are cleared
     *
730bA*    10/21/19  RBD  7.30b
     *      - Fix: error regarding 'ended' transactions said 'closed',
     *        changed it to say 'picked/ended'.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *  This program is called via the GENPRC SQL Stored Procedure
     *
     *  The parameters are strings containing value pairs,
     *  with multiple pairs being separated by a '|', for example:
     *
     *    fieldname1=value|fieldname2=value|fieldname3=value
     *
     *  All that is passed back is pErrMsg. Blank = Successful.
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

730aA*----------------------------------------------------------------
730aA*  File data data structure
730aA*----------------------------------------------------------------
730aA
730aAD lbrec         E ds                  extname(label) inz(*EXTDFT)
730aAD ptrec         E ds                  extname(pirtran) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

730aAd rtnCode         s             10
     d dbgflgExists    s               n
     d debug           s               n
     d debugAfter      s               n
     d debugBefore     s               n
     d debugLoc        s              1
     d emplFound       s               n

     d dpCombo         s             20    varying
     d mode            s              1
     d whse            s              3  0
     d orderId         s              7  0
     d auditBy         s              5  0
     d auditId         s              5  0
730aA
730aA*----------------------------------------------------------------
730aA*  Standard variables
730aA*----------------------------------------------------------------
730aA
730aAD/copy qcopysrc,c#stdvar
730aA
730aA*----------------------------------------------------------------
730aA*  Standard SQL variables and constants
730aA*----------------------------------------------------------------
730aA
730aA /copy qcopysrc,c#stdsql
730aA
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pObjLoc     External object location called from.
     *      pParmStr1   String of '|' delimited parameters
     *      pParmStr2   String of '|' delimited parameters
     *      pParmStr3   String of '|' delimited parameters
     *
     *    Returned Parameters
     *      pErrMsg     Error message
     *
     *----------------------------------------------------------------

     D m28900u         pr                  extpgm('M28900U')
     D  pErrMsg                      99
     D  pSessId                      40
     D  pUser                        10
     D  pDict                        10
     D  pPgm                         10
     D  pObjLoc                      10
     D  pParmStr1                   999
     D  pParmStr2                   999
     D  pParmStr3                   999

     D m28900u         pi
     D  pErrMsg                      99
     D  pSessId                      40
     D  pUser                        10
     D  pDict                        10
     D  pPgm                         10
     D  pObjLoc                      10
     D  pParmStr1                   999
     D  pParmStr2                   999
     D  pParmStr3                   999

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getempl
      /copy qcopysrc,p.exordh

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------
730aA
730aAd ChkPicked       pr
730aAd  ordId                         7  0

     d ConvertField    pr
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

     d ExtractParms    pr

     d ExtractParmStr  pr
     d  parmStr                     999    varying

     D VfyEmployee     pr              n
     d  emp                           5  0

     d WrtBeforeDebug  pr
     d WrtAfterDebug   pr
     d WrtDebugError   pr


     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pErrMsg = '';

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

         if pErrMsg <> '';
           WrtDebugError();
           return;
         endif;

         // Do processing


         // Verify Audit By employee number

         emplFound = VfyEmployee (auditby);
         if not emplFound;
           pErrMsg = 'Error: Invalid employee #';
           WrtDebugError();
           return;
         endif;

         // Get Audit Id

         exWhse = whse;
         exordh ('*GET': exRtnCode: exRtnMsg: exWhse: orderId:
                 ohaaudflg: ohaaudid: ohaaudcmp: ohaaudby);

         if exRtnCode = '*OK' and ohaaudflg = 'Y';
           if ohaaudcmp = 'Y';
             pErrMsg = 'Order Id ' + %char(orderId) + ' '
                     + 'already closed by emp ' + %char(ohaaudby);
             WrtDebugError();
             return;
           endif;
         else;
           pErrMsg = 'Order Id ' + %char(orderId) + ' '
                   + 'is not being audited';
           WrtDebugError();
           return;
         endif;

         // Make sure Id's match

         if auditId <> ohaaudid;
           pErrMsg = 'Entered audit Id ' + %char(auditId) + ' '
                   + 'does not match audit id for '
                   + 'order id ' + %char(orderId);
           WrtDebugError();
           return;
         endif;

730aA    // Ensure all transactions and flags are closed
730aA    rtnCode = '*OK';
730aA    ChkPicked(orderId);
730aA    if rtnCode <> '*OK';
730aA      return;
730aA    endif;

         // Close Audit

         ohaaudcmp = 'Y';
         ohaaudts = %timestamp();
         exordh ('*CHANGE': exRtnCode: exRtnMsg: exWhse: orderId:
                 ohaaudflg: ohaaudid: ohaaudcmp: auditBy: ohaaudts);

         if exRtnCode = '*ERROR';
           pErrMsg = 'Error: Audit Id ' + %char(auditId) + ' '
                   + 'not closed - ' + %trim(exRtnMsg);
           WrtDebugError();
           return;
         endif;

         pErrMsg = 'Audit Id ' + %char(auditId) + ' '
                 + 'closed successfully for '
                 + 'order id ' + %char(orderId);

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

730aA*----------------------------------------------------------------
730aA*  ChkPicked        Check order is fully picked
730aA*----------------------------------------------------------------
730aA
730aAp ChkPicked       b
730aAd ChkPicked       pi
730aAd  ordId                         7  0
730aA
730aA /free
730aA
730aA   SqlStmt = 'select lbvrfy, ptstat '
730aA           + 'from label '
730aA           + 'left outer join pirtran '
730aA           +   'on ptwhse = lbwhse and pttrn# = lbtrn# '
730aA           + 'where lbwhse = ' + %char(whse) + ' '
730aA           +   'and lbord = ' + %char(ordId) + ' '
730aA           +   'and lbtype in (''O'', ''M'', ''B'')';
730aA
730aA   exec sql prepare pcksel from :SqlStmt;
730aA   exec sql declare pckcsr cursor for pcksel;
730aA   exec sql open pckcsr;
730aA
730aA   dow forever = forever;
730aA
730aA     exec sql fetch next from pckcsr
730aA              into :lbvrfy, :ptstat;
730aA
730aA     if sqlstt <> sqlSuccess;
730aA       leave;
730aA     endif;
730aA
730aA     // Transactions must be at Ended status.
730aA     // If trans is at Closed or Exported, we shouldn't have
730aA     // gotten this far because the audit should be closed.
730aA
730aA     if ptstat <> '3';
730aA       rtnCode = '*NOTPICK';
730aA       pErrMsg = 'All transactions must be '
730bD       //      + 'closed to Complete Audit';
730bM               + 'picked/ended to Complete Audit';
730aA       leave;
730aA     endif;
730aA
730aA     // Label record cannot have outstanding flag
730aA
730aA     if lbvrfy = 'F' or lbvrfy = 'I';
730aA       rtnCode = '*NOTPICK';
730aA       pErrMsg = 'All flags must be '
730aA               + 'cleared to Complete Audit';
730aA       leave;
730aA     endif;
730aA
730aA   enddo;
730aA
730aA   exec sql close pckcsr;
730aA
730aA /end-free
730aA
730aAp                 e

     *----------------------------------------------------------------
     *  ConvertField   Convert incoming field to DRI field
     *----------------------------------------------------------------

     p ConvertField    b
     d ConvertField    pi
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

     * Local Variables

     d testDate        s               d

      /free

       monitor;

         select;

           when parmName = 'MODE';
             mode = %xlate(xlower: xupper: parmValue);

           when parmName = 'WHSE';
             if parmValue = '';
               parmValue = '0';
             endif;
             whse = %dec(parmValue: 3: 0);

           when parmName = 'OHAORD';
             if parmValue = '';
               parmValue = '0';
             endif;
             orderId = %dec(parmValue: 7: 0);

           when parmName = 'OHAAUDID';
             if parmValue = '';
               parmValue = '0';
             endif;
             auditId = %dec(parmValue: 5: 0);

           when parmName = 'OHAAUDBY';
             if parmValue = '';
               parmValue = '0';
             endif;
             auditBy = %dec(parmValue: 5: 0);

         endsl;

       on-error;

         pErrMsg = 'Error extracting parameter '
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

     * Local Variables

     d parmStr         s            999    varying

      /free

         // Error if first parameter string is blank

         if pParmStr1 = '';
           pErrMsg = 'Error: Parameter string is empty '
                   + '('
                   + %trimr(#Job) + '/'
                   + %trimr(#JobNbr) + '/'
                   + %trimr(#user)
                   + ')';
           return;
         endif;

         // Extract parms for string 1

         parmStr = %trim(pParmStr1);
         ExtractParmStr(parmStr);

         if pErrMsg <> '';
           return;
         endif;

         // Extract parms for string 2

         parmStr = %trim(pParmStr2);
         ExtractParmStr(parmStr);

         if pErrMsg <> '';
           return;
         endif;

         // Extract parms for string 3

         parmStr = %trim(pParmStr3);
         ExtractParmStr(parmStr);

         if pErrMsg <> '';
           return;
         endif;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ExtractParmStr   Extract parms from single parameter string
     *----------------------------------------------------------------

     p ExtractParmStr  b
     d ExtractParmStr  pi
     d  parmStr                     999    varying

     * Local Variables

     D parmCount       s              3  0
     D parmGroup       s            200    varying
     D parmLen         s              5  0
     D parmName        s             10    varying
     D parmStrLen      s              5  0
     D parmValue       s            100    varying
     D pos             s              5  0
     D start           s              5  0

      /free

       // Parameters are separated by '|'

       start = 1;
       parmStrLen = %len(parmStr);
       parmCount = 0;

       dow start <= parmStrLen;

         // Extract parameter ('fldname=value')

         pos = %scan('|': parmStr: start);

         parmCount += 1;

         if pos = 0;
           parmGroup = %subst(parmStr: start);
           start = parmStrLen + 1;
         else;
           parmLen = pos - start;
           parmGroup = %subst(parmStr: start: parmLen);
           start = pos + 1;
         endif;

         // Extract parameter name

         pos = %scan('=': parmGroup: 1);

         // If no '=' found, invalid group.

         if pos = 0;
           pErrMsg = 'Error: Invalid parameter group '
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
         if pErrMsg <> '';
           leave;
         endif;

       enddo;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  VfyEmployee  Verify employee number
     *----------------------------------------------------------------

     p VfyEmployee     b
     d VfyEmployee     pi              n
     d  emp                           5  0

     * Local variables

     d e$whse          s              3  0
     d e$user          s             10
     d e$fnam          s             15
     d e$init          s              1
     d e$lnam          s             20
     d e$whdp          s              5
     d e$styp          s              1
     d e$shft          s              6
     d e$crew          s              6
     d e$nhrs          s              3  1
     d e$rtn           s              8
     d e$bpu           s              1
     d e$lng           s              2
     d e$email         s              1
     d e$pics          s              1

      /free

         // Get employee info

         monitor;
           getEmpl(emp: e$whse: e$user: e$fnam: e$init: e$lnam:
                   e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                   e$bpu: e$lng: e$email: e$pics);
         on-error;
           return *off;
         endmon;

         if e$rtn = '*ERROR';
           return *off;
         endif;

       return *on;

      /end-free

     p VfyEmployee     e

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
                  + 'pObjLoc:' + %trimr(pObjLoc) + ', '
                  + 'pParm1:' + pParmStr1;

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
                  + 'pObjLoc:' + %trimr(pObjLoc) + ', '
                  + 'pParm1:' + pParmStr1 + ','
                  + 'pErrMsg:' + %trimr(pErrMsg);

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

         bdvalues = pErrMsg;

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

