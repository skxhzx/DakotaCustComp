      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  R33300      GS1 Weight Labels
     *  02 July 2019
     *  Lynn McMahon
     *
     *  Revisions:
     *
730 A*    07/02/19  LMC  7.30
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *  The parameter is assumed to be a string containing value
     *  pairs, with multiple pairs being separated by a '|', for example:
     *
     *    fieldname1=value|fieldname2=value|fieldname3=value
     *
     *  The returned string is assumed to be in JSON format.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

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
     d cmd             s             10
     d aawhse          s              3  0
     d aalabel         s              7  0
     d aaPO            s              9
     d aaposeq         s              5  0
     d aaitem          s             15
     d total_wgt       s              7  2
     d count_wgt       s              5  0
     d MyfieldNull     s              5i 0

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  files
     *----------------------------------------------------------------

     D uiwrec        E Ds                  Extname(uciwork)
     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------


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

     D R33300          pr                  extpgm('R33300')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     D R33300          pi
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

     d ConvertField    pr
     d  parmCount                     3  0
     d  parmName                     10    varying
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

         // **** FOR TESTING ****
         debugAfter = *on;

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

         exec sql select sum(UIwWGTLBS) into :total_wgt:MyfieldNull
                 from uciwork
                 where uiwwhse = :aawhse
                   and uiwprint <> 'Y'
                   and uiwpo = :aapo
                   and uiwposeq = :aaposeq
                   and uiwitem = :aaitem
                   and uiwsess = :pSessId;

         exec sql select count(*) into :count_wgt
                  from uciwork
                 where uiwwhse = :aawhse
                   and uiwpo = :aapo
                   and uiwprint <> 'Y'
                   and uiwposeq = :aaposeq
                   and uiwitem = :aaitem
                   and uiwsess = :pSessId;

         pOutStr = '{'
                 +    '"user":"' + pUser + '",'
                 +    '"combo":"' + dpCombo + '",'
                 +    '"cmd":"' + %trim(cmd) + '",'
                 +    '"totwgt":"' + %char(total_wgt) + '",'
                 +    '"cntwgt":"' + %char(count_wgt) + '",'
                 +    '"whs":"' + %char(aawhse) + '"'
                 + '}';

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
     d  parmName                     10    varying
     d  parmValue                   100    varying

      /free

       monitor;

         select;

           when parmName = 'cmd';
             cmd = %xlate(xlower: xupper: parmValue);

           when parmName = 'po';
             aapo = %xlate(xlower: xupper: parmValue);

           when parmName = 'item';
             aaitem = %xlate(xlower: xupper: parmValue);

           when parmName = 'whs';
             if parmValue = '';
               parmValue = '0';
             endif;
             aawhse =  %dec(parmValue: 3: 0);

           when parmName = 'poseq';
             if parmValue = '';
               parmValue = '0';
             endif;
             aaposeq =  %dec(parmValue: 5: 0);

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
     D parmName        s             10    varying
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

