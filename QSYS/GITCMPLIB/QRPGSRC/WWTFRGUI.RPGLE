      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  WWTFRGUI    Call WWTFR using GENFNC
     *  19 May 2020
     *  Dave Sommerville
     *
     *  Revisions:
     *
740 A*    05/19/20  DAS  7.40
     *      - Created.
     *
740aA*    06/11/20  DAS  7.40a
     *      - Fix: Revised to send TO whs to WWTFR instead of FROM whs
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

     d/copy qcopysrc,C#CVTPARMS

     d dbgflgExists    s               n
     d debug           s               n
     d debugAfter      s               n
     d debugBefore     s               n
     d debugLoc        s              1
     d debugId         s              6

     d errMsg          s             99    varying
     d dpCombo         s             20    varying
740aDd*whse            s              3  0
740aMd whse            s              3s 0
     d cmd             s             10
     d fromAisle       s              3
     d fromLoc         s              3s 0
     d fromWhse        s              3s 0
     D wwrtn           s             10
     D wwmsg           s             99    varying
     D user            s             10

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

     D WWTFRGUI        pr                  extpgm('WWTFRGUI')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     D WWTFRGUI        pi
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
     d/copy qcopysrc,p.wwtfr

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

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

         debugId = %editc(%dec(%time(): *ISO): 'X');
         wwmsg = 'DEBUG' + debugId;
         user = pUser;

740aD    //WWTFR(cmd: fromAisle: fromLoc: fromWhse: user: wwrtn: wwmsg);
740aM    WWTFR(cmd: fromAisle: fromLoc: whse: user: wwrtn: wwmsg);

         JsonStartObj();

           JsonAddPair('cmd': cmd);
           JsonAddPair('rtncode': wwrtn);
           JsonAddPair('rtnmsg': wwmsg);

           if wwrtn = '*ERRORLOG';
             JsonAddPair('du': #user);
             JsonAddPair('dj': #job);
             JsonAddPair('dn': #jobnbr);
             JsonAddPair('di': debugId);
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

           when parmName = 'cmd';
             cmd = %xlate(xlower: xupper: parmValue);

           when parmName = 'fldfromwhs';
             if parmValue = '';
               parmValue = '0';
             endif;
             fromWhse = %dec(parmValue: 3: 0);

           when parmName = 'asl';
             fromAisle = parmValue;

           when parmName = 'loc';
             if parmValue = '';
               parmValue = '0';
             endif;
             fromLoc = %dec(parmValue: 3: 0);

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

