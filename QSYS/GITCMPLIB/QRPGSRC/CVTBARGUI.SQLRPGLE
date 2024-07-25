      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  CVTBARGUI   Call CVTBAR using GENFNC
     *  07 April 2020
     *  Dave Sommerville
     *
     *  Revisions:
     *
740 A*    04/07/20  DAS  7.40
     *      - Created.
     *
740aA*    04/23/20  DAS  7.40a
     *      - Set return from CVTBAR to *OK if blank
     *      - Change case on some json fields
740bA*    07/01/20  LMC  7.40b
     *      - We have changed our internal gs1 labels to use AI code
     *        instead of AI code 01.
     *      - If return from cvtbar with $bcgtinsent and $bcai98sent
     *        and the $bcgtin and the th $bcgtin and $bcai98 are the
     *        same value this indicates our internal Ai 98 code which
     *        we will use as the GTIN in our programs
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
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d/copy qcopysrc,C#BARCODE
     d/copy qcopysrc,C#CVTPARMS

     d dbgflgExists    s               n
     d debug           s               n
     d debugAfter      s               n
     d debugBefore     s               n
     d debugLoc        s              1
     d debugId         s              6

     d errMsg          s             99    varying
     d dpCombo         s             20    varying
     d whse            s              3  0
     d barcode         s            100
     d cmd             s              8
     d item            s             15
     d mfr             s             10  0
     d bardebug        s              1

     *----------------------------------------------------------------
     *  JSON Global Variables
     *----------------------------------------------------------------

     D jsonDepth       s              3  0
     d jsonLine        s           3072    varying

     D jsonStack       ds                  occurs(20) Qualified
     D   firstEntry                    n

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

     D CVTBARGUI       pr                  extpgm('CVTBARGUI')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     D CVTBARGUI       pi
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
     *  Called Programs Prototypes
     *----------------------------------------------------------------

     d/copy qcopysrc,p.cvttext

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d CallCVTBAR      pr

     d AddReturnAll    pr

     d AddReturnOne    pr

     d AddReturnDebug  pr

     d ConvertField    pr
     d  parmCount                     3  0
     d  parmName                     30    varying
     d  parmValue                   100    varying

     d ExtractParms    pr

     d ExtractParmStr  pr

     d WrtBeforeDebug  pr
     d WrtAfterDebug   pr
     d WrtDebugError   pr

     d JsonAddArray    pr
     d  arrayValue                  500    const varying

     d JsonAddPair     pr
     d  pairName                    100    const varying
     d  pairValue                   500    const varying

     d JsonEndArray    pr

     d JsonEndObj      pr

     d JsonStartArray  pr
     d  arrayName                   100    const varying

     d JsonStartObj    pr
     d  objName                     100    const varying options(*nopass)

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         errMsg = '';

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
           JsonStartObj();
             JsonAddPair('rtnCode': '*ERROR');
             JsonAddPair('rtnMsg': errMsg);
           JsonEndObj();
           pOutStr = jsonLine;
           WrtDebugError();
           return;
         endif;

         // Do processing

         if bardebug = 'Y';
           debugId = %editc(%dec(%time(): *ISO): 'X');
         endif;

         CallCVTBAR();

         if $cbrtn = '';
           $cbrtn = '*OK';
         endif;

         JsonStartObj();

           JsonAddPair('cmd': cmd);
           JsonAddPair('rtncode': $cbrtn);
           JsonAddPair('rtnmsg': $cberm);

           if bardebug = 'Y';
             JsonAddPair('du': #user);
             JsonAddPair('dj': #job);
             JsonAddPair('dn': #jobnbr);
             JsonAddPair('di': debugId);
           endif;

           if cmd = '*ALL';
             AddReturnAll();
           else;
             AddReturnOne();
           endif;

           if bardebug = 'Y';
             //AddReturnDebug();
           endif;

         JsonEndObj();

         pOutStr = jsonline;

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
     *  CallCVTBAR     Call CVTBAR
     *----------------------------------------------------------------

     p CallCVTBAR      b
     d CallCVTBAR      pi

      /free

         if bardebug = 'Y';
           $cbdsc = 'DEBUG' + debugId;
         else;
           $cbdsc = '';
         endif;

         $cbcmd = cmd;
         $cbbar = barcode;
         $cbven = mfr;
         $cbitem = item;
         $cbkilolbsSent = 'P';
         $cbwhse = whse;

      /end-free

     C                   call      'CVTBAR'
     C                   parm                    $cbcmd
     C                   parm                    $cbbar
     C                   parm                    $cbcod
     C                   parm                    $cbdec
     C                   parm                    $cbdsc
     C                   parm                    $cbpos
     C                   parm                    $cbtyp
     C                   parm                    $cbv1
     C                   parm                    $cbv2
     C                   parm                    $cbrtn
     C                   parm                    $cberm
520aAC                   parm                    $cbven
640aAC                   parm                    $cvtdata
640aAC                   parm                    $cvtdata2
740aAC                   parm                    $cbwhse
740aAC                   parm                    $cbkilolbsSent
740aAC                   parm                    $cbItem

      /free

       $barcode = $cvtdata;
       $barcode2 = $cvtdata2;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  AddReturnAll   Add values for *ALL to return
     *----------------------------------------------------------------

     p AddReturnAll    b
     d AddReturnAll    pi

      /free

       JsonStartArray('results');

         if $bcdef#sent;
           JsonStartObj();
           JsonAddPair('code': '');
           JsonAddPair('dsc': 'User Defined Definition');
           JsonAddPair('val': $bcdef#);
           JsonEndObj();
         endif;

         if $bcssccsent;
           JsonStartObj();
           JsonAddPair('code': '00');
           JsonAddPair('dsc': 'Serial Ship Container Cd(SSCC)');
           JsonAddPair('val': $bcsscc);
           JsonEndObj();
         endif;

         if $bcgtinsent;
           JsonStartObj();
740bA      if $bcgtin = $bcai98;
740bA        JsonAddPair('code': '98');
740bA        JsonAddPair('dsc': 'Internal Trade Item Number(GTIN)');
740bA      else;
             JsonAddPair('code': '01');
             JsonAddPair('dsc': 'Global Trade Item Number(GTIN)');
740bA      endif;
           JsonAddPair('val': $bcgtin);
           JsonEndObj();
         endif;

         if $bclotsent;
           JsonStartObj();
           JsonAddPair('code': '10');
           JsonAddPair('dsc': 'Batch/Lot Number');
           JsonAddPair('val': $bclot);
           JsonEndObj();
         endif;

         if $bcproddsent;
           JsonStartObj();
           JsonAddPair('code': '11');
           JsonAddPair('dsc': 'Production Date (YYMMDD)');
           JsonAddPair('val': %editc($bcprodd:'X'));
           test(de) *ymd $bcprodd;
           if %error;
             JsonAddPair('err': '1');
           endif;
           JsonEndObj();
         endif;

         if $bcpackdsent;
           JsonStartObj();
           JsonAddPair('code': '13');
           JsonAddPair('dsc': 'Packaging Date (YYMMDD) ');
           JsonAddPair('val': %editc($bcpackd:'X'));
           test(de) *ymd $bcpackd;
           if %error;
             JsonAddPair('err': '1');
           endif;
           JsonEndObj();
         endif;

         if $bcslbydsent;
           JsonStartObj();
           JsonAddPair('code': '15');
           JsonAddPair('dsc': 'Sell By Date (YYMMDD)');
           JsonAddPair('val': %editc($bcslbyd:'X'));
           test(de) *ymd $bcslbyd;
           if %error;
             JsonAddPair('err': '1');
           endif;
           JsonEndObj();
         endif;

         if $bcexpdsent;
           JsonStartObj();
           JsonAddPair('code': '17');
           JsonAddPair('dsc': 'Expiration Date (YYMMDD)');
           JsonAddPair('val': %editc($bcexpd:'X'));
           test(de) *ymd $bcexpd;
           if %error;
             JsonAddPair('err': '1');
           endif;
           JsonEndObj();
         endif;

         if $bcser#sent;
           JsonStartObj();
           JsonAddPair('code': '21');
           JsonAddPair('dsc': 'Serial Number');
           JsonAddPair('val': $bcser#);
           JsonEndObj();
         endif;

         if $bcpntkgsent;
           JsonStartObj();
           JsonAddPair('code': '310');
           JsonAddPair('dsc': 'Net Weight, Kilograms');
           JsonAddPair('val': %char($bcpntkg));
           JsonEndObj();
         endif;

         if $bcpntlbsent;
           JsonStartObj();
           JsonAddPair('code': '320');
           JsonAddPair('dsc': 'Net Weight, Pounds');
           JsonAddPair('val': %char($bcpntlb));
           JsonEndObj();
         endif;

         if $bcai91sent;
           JsonStartObj();
           JsonAddPair('code': '91');
           JsonAddPair('dsc': 'Internal Company Code AI91 ');
           JsonAddPair('val': $bcai91);
           JsonEndObj();
         endif;

         if $bcai92sent;
           JsonStartObj();
           JsonAddPair('code': '92');
           JsonAddPair('dsc': 'Internal Company Code AI92 ');
           JsonAddPair('val': $bcai92);
           JsonEndObj();
         endif;

         if $bcai93sent;
           JsonStartObj();
           JsonAddPair('code': '93');
           JsonAddPair('dsc': 'Internal Company Code AI93');
           JsonAddPair('val': $bcai93);
           JsonEndObj();
         endif;

         if $bcai94sent;
           JsonStartObj();
           JsonAddPair('code': '94');
           JsonAddPair('dsc': 'Internal Company Code AI94');
           JsonAddPair('val': $bcai94);
           JsonEndObj();
         endif;

         if $bcai95sent;
           JsonStartObj();
           JsonAddPair('code': '95');
           JsonAddPair('dsc': 'Internal Company Code AI95');
           JsonAddPair('val': $bcai95);
           JsonEndObj();
         endif;

         if $bcai96sent;
           JsonStartObj();
           JsonAddPair('code': '96');
           JsonAddPair('dsc': 'Internal Company Code AI96');
           JsonAddPair('val': $bcai96);
           JsonEndObj();
         endif;

         if $bcai97sent;
           JsonStartObj();
           JsonAddPair('code': '97');
           JsonAddPair('dsc': 'Internal Company Code AI97');
           JsonAddPair('val': $bcai97);
           JsonEndObj();
         endif;

         if $bcai98sent;
740bA      if $bcgtin = $bcai98;
740bA      else;
             JsonStartObj();
             JsonAddPair('code': '98');
             JsonAddPair('dsc': 'Internal Company Code AI98');
             JsonAddPair('val': $bcai98);
             JsonEndObj();
740bA      endif;
         endif;

         if $bcai99sent;
           JsonStartObj();
           JsonAddPair('code': '99');
           JsonAddPair('dsc': 'Internal Company Code AI99');
           JsonAddPair('val': $bcai99);
           JsonEndObj();
         endif;

       JsonEndArray();

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  AddReturnOne   Add single value
     *----------------------------------------------------------------

     p AddReturnOne    b
     d AddReturnOne    pi

      /free

         // Create array of values

       if $cbrtn <> '*OK';
         return;
       endif;

       select;
         when $cbtyp = 1;
           JsonAddPair('value': %char($cbv1));
         when $cbtyp = 2;
           JsonAddPair('value': $cbv2);
       endsl;

       JsonStartArray('results');
       JsonStartObj();

         select;
           when $cbcod = 0;
             JsonAddPair('code': '00');
           when $cbcod < 10;
             JsonAddPair('code': '0'+%char($cbcod));
           other;
             JsonAddPair('code': %char($cbcod));
         endsl;
         JsonAddPair('dsc': $cbdsc);
         select;
           when $cbtyp = 1;
             JsonAddPair('val': %char($cbv1));
           when $cbtyp = 2;
             JsonAddPair('val': $cbv2);
           other;
             JsonAddPair('val': '');
         endsl;

       JsonEndObj();
       JsonEndArray();

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  AddReturnDebug   Add debug records
     *----------------------------------------------------------------

     p AddReturnDebug  b
     d AddReturnDebug  pi

      /free

       SqlStmt = 'select bdvalues '
               + 'from bfcdebug '
               + 'where bdaddjusr = ' + sq + #user + sq + ' '
               +   'and bdaddjob = ' + sq + #job + sq + ' '
               +   'and bdaddnbr = ' + sq + #jobnbr + sq + ' '
               +   'and bdtype = ' + sq + debugId + sq + ' '
               + 'order by bdaddts';

       exec sql prepare debugSel from :SqlStmt;
       exec sql declare debugCsr dynamic scroll cursor for debugSel;
       exec sql open debugCsr;

       JsonStartArray('debug');

       dow forever = forever;

         exec sql
           fetch next from debugCsr into :bdvalues;

         if sqlstt <> sqlSuccess;
           leave;
         endif;

         JsonStartObj();
           JsonAddPair('line': bdvalues);
         JsonEndObj();

       enddo;

       JsonEndArray();

       exec sql close debugCsr;

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

           when parmName = 'whs';
             if parmValue = '';
               parmValue = '0';
             endif;
             whse = %dec(parmValue: 3: 0);

           when parmName = 'fldbar';
             barcode = parmValue;

           when parmName = 'fldcmd';
             cmd = %xlate(xlower: xupper: parmValue);

           when parmName = 'fldmfr';
             if parmValue = '';
               parmValue = '0';
             endif;
             mfr = %dec(parmValue: 10: 0);

           when parmName = 'flditem';
             item = %xlate(xlower: xupper: parmValue);

           when parmName = 'debug';
             bardebug = %xlate(xlower: xupper: parmValue);

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
                  + 'pOutStr:' + %trimr(pOutStr);

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

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  JSON Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  JsonAddArray   Add array value to JSON object
     *----------------------------------------------------------------

     p JsonAddArray    b
     d JsonAddArray    pi
     d  arrayValue                  500    const varying

     * Local Variables

     d  cmd            s             10
     d  valueIn        s            500
     d  valueOut       s            500

      /free

        cmd = '*XML';
        valueIn = arrayValue;
        valueOut = '';
        CvtText(cmd: valueIn: valueOut);

        if jsonStack.firstEntry;
          jsonStack.firstEntry = *off;
        else;
          jsonLine += ',';
        endif;

        jsonLine += dq + %trim(valueOut) + dq + ':';

        return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  JsonAddPair    Add name/value pair to JSON object
     *----------------------------------------------------------------

     p JsonAddPair     b
     d JsonAddPair     pi
     d  pairName                    100    const varying
     d  pairValue                   500    const varying

     * Local Variables

     d  cmd            s             10
     d  valueIn        s            500
     d  valueOut       s            500

      /free

        cmd = '*XML';
        valueIn = pairValue;
        valueOut = '';
        CvtText(cmd: valueIn: valueOut);

        if jsonStack.firstEntry;
          jsonStack.firstEntry = *off;
        else;
          jsonLine += ',';
        endif;

        jsonLine += dq + %trim(pairName) + dq + ':' + dq + %trim(valueOut) + dq;

        return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  JsonEndArray  End JSON array
     *----------------------------------------------------------------

     p JsonEndArray    b
     d JsonEndArray    pi

      /free
        jsonLine += ']';
        jsonDepth -= 1;
        return;
      /end-free

     p                 e

     *----------------------------------------------------------------
     *  JsonEndObj    End JSON object
     *----------------------------------------------------------------

     p JsonEndObj      b
     d JsonEndObj      pi

      /free
        jsonLine += '}';
        jsonDepth -= 1;
        return;
      /end-free

     p                 e

     *----------------------------------------------------------------
     *  JsonStartArray    Start JSON array
     *----------------------------------------------------------------

     p JsonStartArray  b
     d JsonStartArray  pi
     d  arrayName                   100    const varying

     * Local Variables


      /free

        if jsonDepth > 0;
          if jsonStack.firstEntry;
            jsonStack.firstEntry = *off;
          else;
            jsonLine += ',';
          endif;
        endif;

        jsonLine += dq + arrayName + dq + ':[';

        jsonDepth += 1;
        %occur(jsonStack) = jsonDepth;
        jsonStack.firstEntry = *on;

        return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  JsonStartObj   Start JSON object
     *----------------------------------------------------------------

     p JsonStartObj    b
     d JsonStartObj    pi
     d  objName                     100    const varying options(*nopass)

      /free

        if jsonDepth > 0;
          if jsonStack.firstEntry;
            jsonStack.firstEntry = *off;
          else;
            jsonLine += ',';
          endif;
        endif;

        if %parms >= 1;
          jsonLine += dq + %trim(objName) + dq + ':{';
        else;
          jsonLine += '{';
        endif;

        jsonDepth += 1;
        %occur(jsonStack) = jsonDepth;
        jsonStack.firstEntry = *on;

        return;
      /end-free

     p                 e

