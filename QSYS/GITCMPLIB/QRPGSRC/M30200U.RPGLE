      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M28400U    Barcode def maint Update using GENPRC
     *  18 January 2020
     *  Dave Sommerville
     *
     *  Revisions:
     *
740 A*    01/18/20  DAS  7.40
     *      - Created.
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

     Fbardefh   if   e           k disk
     Fbardefd   uf a e           k disk
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

     d dpCombo         s             20    varying
     d mode            s              1

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

     D m30200u         pr                  extpgm('M30200U')
     D  pErrMsg                      99
     D  pSessId                      40
     D  pUser                        10
     D  pDict                        10
     D  pPgm                         10
     D  pObjLoc                      10
     D  pParmStr1                   999
     D  pParmStr2                   999
     D  pParmStr3                   999

     D m30200u         pi
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
     *  AI Defs
     *   Occurance   Code
     *       1       gtin
     *       2       wgtlb
     *       3       wgtkl
     *       4       prodate
     *       5       selldate
     *       6       expdate
     *       7       lot
     *       8       serial
     *----------------------------------------------------------------
     d whse            s              3  0
     d bdhdef#         s              5  0
     d bdhlen          s              3  0

     d aiDef           ds                  occurs(8)
     d   aiCode                       3
     d   aiDesc                      30    varying
     d   aiStart                      3  0
     d   aiLen                        3  0
     d   aiDec                        1  0
     d   aiFmt                        8    varying

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d ConvertField    pr
     d  parmCount                     3  0
     d  parmName                     30    varying
     d  parmValue                   100    varying

     d ExtractParms    pr

     d ExtractParmStr  pr
     d  parmStr                     999    varying

     d WrtBeforeDebug  pr
     d WrtAfterDebug   pr
     d WrtDebugError   pr

     d GetAIDesc       pr            30    varying
     d   code                         3

     d DeleteAIDefs    pr
     d InitAIDefs      pr
     d UpdateAIDefs    pr
     d VerifyAIDefs    pr
     d WriteAIDefs     pr

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

         InitAIDefs();
         ExtractParms();

         // Get out if error

         if pErrMsg <> '';
           WrtDebugError();
           return;
         endif;

         // Error if def# = 0

         if bdhdef# = 0;
           pErrMsg = 'Definition number cannot be zero';
           WrtDebugError();
           return;
         endif;

         // Error if def# < 0

         if bdhdef# < 0;
           pErrMsg = 'Definition number cannot be negative '
                   + '(' + %char(bdhdef#) + ')';
           WrtDebugError();
           return;
         endif;

         // Do processing

         select;

           // Adding ...

           when mode = 'A';

             VerifyAIDefs();
             if pErrMsg <> '';
               WrtDebugError();
               return;
             endif;

             WriteAIDefs();

          // Updating ...

           when mode = 'C' or mode = 'U';

             VerifyAIDefs();
             if pErrMsg <> '';
               WrtDebugError();
               return;
             endif;

             UpdateAIDefs();

           // Deleting ...

           when mode = 'D';

             DeleteAIDefs();

         endsl;

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

     * Local Variables

     d testDate        s               d

      /free

       //pErrMsg = parmName + ' = ' + parmValue;
       //WrtDebugError();
       //pErrMsg = '';

       monitor;

         select;

           when parmName = 'MODE';
             mode = %xlate(xlower: xupper: parmValue);

           when parmName = 'WHSE';
             if parmValue = '';
               parmValue = '0';
             endif;
             whse = %dec(parmValue: 3: 0);

           when parmName = 'BDHDEF#';
             if parmValue = '';
               parmValue = '0';
             endif;
             bdhdef# = %dec(parmValue: 5: 0);

           when parmName = 'BDHLEN';
             if parmValue = '';
               parmValue = '0';
             endif;
             bdhlen = %dec(parmValue: 3: 0);

           when parmName = 'gtinStart';
             if parmValue = '';
               parmValue = '0';
             endif;
             %occur(aiDef) = 1;
             aiStart = %dec(parmValue: 3: 0);

           when parmName = 'gtinLen';
             if parmValue = '';
               parmValue = '0';
             endif;
             %occur(aiDef) = 1;
             aiLen = %dec(parmValue: 3: 0);

           when parmName = 'wgtlbStart';
             if parmValue = '';
               parmValue = '0';
             endif;
             %occur(aiDef) = 2;
             aiStart = %dec(parmValue: 3: 0);

           when parmName = 'wgtlbLen';
             if parmValue = '';
               parmValue = '0';
             endif;
             %occur(aiDef) = 2;
             aiLen = %dec(parmValue: 3: 0);

           when parmName = 'wgtlbDec';
             if parmValue = '';
               parmValue = '0';
             endif;
             %occur(aiDef) = 2;
             aiDec = %dec(parmValue: 1: 0);

           when parmName = 'wgtklStart';
             if parmValue = '';
               parmValue = '0';
             endif;
             %occur(aiDef) = 3;
             aiStart = %dec(parmValue: 3: 0);

           when parmName = 'wgtklLen';
             if parmValue = '';
               parmValue = '0';
             endif;
             %occur(aiDef) = 3;
             aiLen = %dec(parmValue: 3: 0);

           when parmName = 'wgtklDec';
             if parmValue = '';
               parmValue = '0';
             endif;
             %occur(aiDef) = 3;
             aiDec = %dec(parmValue: 1: 0);

           when parmName = 'prodateStart';
             if parmValue = '';
               parmValue = '0';
             endif;
             %occur(aiDef) = 4;
             aiStart = %dec(parmValue: 3: 0);

           when parmName = 'prodateLen';
             if parmValue = '';
               parmValue = '0';
             endif;
             %occur(aiDef) = 4;
             aiLen = %dec(parmValue: 3: 0);

           when parmName = 'prodateFmt';
             %occur(aiDef) = 4;
             aiFmt = parmValue;

           when parmName = 'selldateStart';
             if parmValue = '';
               parmValue = '0';
             endif;
             %occur(aiDef) = 5;
             aiStart = %dec(parmValue: 3: 0);

           when parmName = 'selldateLen';
             if parmValue = '';
               parmValue = '0';
             endif;
             %occur(aiDef) = 5;
             aiLen = %dec(parmValue: 3: 0);

           when parmName = 'selldateFmt';
             %occur(aiDef) = 5;
             aiFmt = parmValue;

           when parmName = 'expdateStart';
             if parmValue = '';
               parmValue = '0';
             endif;
             %occur(aiDef) = 6;
             aiStart = %dec(parmValue: 3: 0);

           when parmName = 'expdateLen';
             if parmValue = '';
               parmValue = '0';
             endif;
             %occur(aiDef) = 6;
             aiLen = %dec(parmValue: 3: 0);

           when parmName = 'expdateFmt';
             %occur(aiDef) = 6;
             aiFmt = parmValue;

           when parmName = 'lotStart';
             if parmValue = '';
               parmValue = '0';
             endif;
             %occur(aiDef) = 7;
             aiStart = %dec(parmValue: 3: 0);

           when parmName = 'lotLen';
             if parmValue = '';
               parmValue = '0';
             endif;
             %occur(aiDef) = 7;
             aiLen = %dec(parmValue: 3: 0);

           when parmName = 'serialStart';
             if parmValue = '';
               parmValue = '0';
             endif;
             %occur(aiDef) = 8;
             aiStart = %dec(parmValue: 3: 0);

           when parmName = 'serialLen';
             if parmValue = '';
               parmValue = '0';
             endif;
             %occur(aiDef) = 8;
             aiLen = %dec(parmValue: 3: 0);

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
     D parmName        s             30    varying
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
     *  DeleteAIDefs   Delete AI Defs
     *----------------------------------------------------------------

     p DeleteAIDefs    b
     d DeleteAIDefs    pi

      /free

       setll (whse: bdhdef#) bardefd;
       dow forever=forever;
         reade (whse: bdhdef#) bardefd;
         if %eof(bardefd);
           leave;
         endif;
         delete(e) bddrec;
         if %error();
           pErrMsg = 'Error deleting AI Code '
                   + %char(bdhdef#) + '/' + GetAIDesc(bddai);
           return;
         endif;
       enddo;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetAIDesc      Get AI Code Name
     *----------------------------------------------------------------

     p GetAIDesc       b
     d GetAIDesc       pi            30    varying
     d   code                         3

     * Local Variables

     d desc            s             30    varying

      /free

       for i = 1 to %elem(aiDef);
         %occur(aiDef) = i;
         if aiCode = code;
           return aiDesc;
         endif;
       endfor;

       return code;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  InitAIDefs     Initialize AI Defs
     *----------------------------------------------------------------

     p InitAIDefs      b
     d InitAIDefs      pi

      /free

       clear *ALL aiDef;

       for i = 1 to %elem(aiDef);
         %occur(aiDef) = i;
         clear aiDef;
         select;
           when i = 1;
             aiCode = '01';
             aiDesc = 'GTIN';
           when i = 2;
             aiCode = '320';
             aiDesc = 'Weight - Pounds';
           when i = 3;
             aiCode = '310';
             aiDesc = 'Weight - Kilograms';
           when i = 4;
             aiCode = '11';
             aiDesc = 'Production Date';
           when i = 5;
             aiCode = '15';
             aiDesc = 'Sell By Date';
           when i = 6;
             aiCode = '17';
             aiDesc = 'Expiration Date';
           when i = 7;
             aiCode = '10';
             aiDesc = 'Lot';
           when i = 8;
             aiCode = '21';
             aiDesc = 'Serial Number';
         endsl;
       endfor;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  UpdateAIDefs   Update AI Defs
     *----------------------------------------------------------------

     p UpdateAIDefs    b
     d UpdateAIDefs    pi

      /free

       for i = 1 to %elem(aiDef);

         %occur(aiDef) = i;

         // See if record already exists

         chain (whse: bdhdef#: aiCode) bardefd;

         // Record exists

         If %found(bardefd);

           // if Start is zero, delete record

           if aiStart = 0;

             delete(e) bddrec;
             if %error();
               pErrMsg = 'Error deleting AI Code '
                       + %char(bdhdef#) + '/' + aiDesc;
               return;
             endif;

           // Otherwise, update record;

           else;

             bddstart = aiStart;
             bddlen = aiLen;
             bdddec = aiDec;
             bddfmt = aiFmt;
             update(e) bddrec;
             if %error();
               pErrMsg = 'Error updating AI Code '
                       + %char(bdhdef#) + '/' + aiDesc;
               return;
             endif;

           endif;

         // Record doesn't exist

         else;

           // Only add record if Start is greater than zero

           if aiStart > 0;

             bddwhse = whse;
             bdddef# = bdhdef#;
             bddai = aiCode;
             bddstart = aiStart;
             bddlen = aiLen;
             bdddec = aiDec;
             bddfmt = aiFmt;
             write(e) bddrec;
             if %error();
               pErrMsg = 'Error writing AI Code '
                       + %char(bdhdef#) + '/' + aiDesc;
               return;
             endif;

           endif;

         endif;

       endfor;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  VerifyAIDefs   Verify AI Defs
     *----------------------------------------------------------------

     p VerifyAIDefs    b
     d VerifyAIDefs    pi

     * Local Variables

     d saveCode        s              3
     d saveDesc        s             30    varying
     d saveStart       s              3  0
     d saveEnd         s              3  0
     d aiEnd           s              3  0
     d fmtLen          s              3  0

      /free

       for i = 1 to %elem(aiDef);

         %occur(aiDef) = i;

         // Start, Length and Decimals cannot be negative
         if aiStart < 0;
           pErrMsg = 'Error on ' + aiDesc + ': '
                   + 'Start cannot be negative ';
           return;
         endif;
         if aiLen < 0;
           pErrMsg = 'Error on ' + aiDesc + ': '
                   + 'Length cannot be negative ';
           return;
         endif;
         if aiDec < 0;
           pErrMsg = 'Error on ' + aiDesc + ': '
                   + 'Decimals cannot be negative ';
           return;
         endif;

         // Nothing else can be defined if Start not entered

         if aiStart = 0;
           if aiLen > 0 or aiDec > 0 or aiFmt <> '';
             pErrMsg = 'Error on ' + aiDesc + ': '
                     + 'Start must be greater than zero '
                     + 'when other values defined';
             return;
           endif;
         endif;

         // If Start defined, length must be defined

         if aiStart > 0 and aiLen = 0;
           pErrMsg = 'Error on ' + aiDesc + ': '
                   + 'Start must be greater than zero '
                   + 'when other values defined';
           return;
         endif;

         // Start cannot be greater than barcode length

         if bdhlen > 0 and aiStart > bdhlen;
           pErrMsg = 'Error on ' + aiDesc + ': '
                   + 'Start is greater than barcode length ';
           return;
         endif;

         // Decimals cannot be greater than AI length

         if aiDec > aiLen;
           pErrMsg = 'Error on ' + aiDesc + ': '
                   + 'Decimals greater than length ';
           return;
         endif;

         // AI end cannot be greater than barcode length

         aiEnd = aiStart + aiLen - 1;
         if bdhlen > 0 and aiEnd > bdhlen;
           pErrMsg = 'Error on ' + aiDesc + ': '
                   + 'End is greater than barcode length ';
           return;
         endif;

         // Date format must be entered for Production date

         if aiCode = '11' and aiStart > 0 and aiFmt = '';
           pErrMsg = 'Error on ' + aiDesc + ': '
                   + 'Date format must be entered';
           return;
         endif;

         // Date format must be entered for Sell By date

         if aiCode = '15' and aiStart > 0 and aiFmt = '';
           pErrMsg = 'Error on ' + aiDesc + ': '
                   + 'Date format must be entered';
           return;
         endif;

         // Date format must be entered for Expiration date

         if aiCode = '17' and aiStart > 0 and aiFmt = '';
           pErrMsg = 'Error on ' + aiDesc + ': '
                   + 'Date format must be entered';
           return;
         endif;

         // Date length must equal format length

         fmtLen = %len(aiFmt);
         if aiCode = '11' or aiCode = '15' or aiCode = '17';
           if aiLen <> fmtLen;
             pErrMsg = 'Error on ' + aiDesc + ': '
                     + 'Date length must equal format length';
             return;
           endif;
         endif;

         // Lot and Serial length must be less than or equal to 20

         if aiCode = '10' or aiCode = '21';
           if aiLen > 20;
             pErrMsg = 'Error on ' + aiDesc + ': '
                     + 'Length must less than or equal to 20';
             return;
           endif;
         endif;

       endfor;

       // Cannot have overlapping From/To positions

       for i = 1 to %elem(aiDef);

         %occur(aiDef) = i;

         if aiStart > 0;

           saveCode = aiCode;
           saveDesc = aiDesc;
           saveStart = aiStart;
           saveEnd = aiStart + aiLen - 1;

           for j = 1 to %elem(aiDef);

             %occur(aiDef) = j;

             if aiCode <> saveCode and aiStart > 0;

               aiEnd = aiStart + aiLen - 1;
               if saveStart >= aiStart and saveStart <= aiEnd;
                 pErrMsg = 'Error on ' + saveDesc + ': '
                         + 'Overlaps ' + aiDesc;
                 return;
               endif;
               if saveEnd >= aiStart and saveEnd <= aiEnd;
                 pErrMsg = 'Error on ' + saveDesc + ': '
                         + 'Overlaps ' + aiDesc;
                 return;
               endif;

             endif;

           endfor;

         endif;

       endfor;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  WriteAIDefs   Write AI Defs
     *----------------------------------------------------------------

     p WriteAIDefs     b
     d WriteAIDefs     pi

      /free

       for i = 1 to %elem(aiDef);

         %occur(aiDef) = i;

         // Only add record if Start is greater than zero

         if aiStart > 0;

           bddwhse = whse;
           bdddef# = bdhdef#;
           bddai = aiCode;
           bddstart = aiStart;
           bddlen = aiLen;
           bdddec = aiDec;
           bddfmt = aiFmt;
           write(e) bddrec;
           if %error();
             pErrMsg = 'Error writing AI Code '
                     + %char(bdhdef#) + '/' + aiDesc;
             return;
           endif;

         endif;

       endfor;

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

