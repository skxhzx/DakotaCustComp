      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M28400U    Customer audit maint using GENPRC
     *  06 December 2018
     *  Dave Sommerville
     *
     *  Revisions:
     *
720 A*    12/06/18  DAS  7.20
     *      - Created.
     *
740 A*    04/28/20  KDE  7.40
     *      - Changed to use alpha numeric customer to allow non numeric
     *        customer to use Audit process
     *
740aA*    05/20/20  KDE  7.40a
     *      - Add field to maintain reason for audit
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *  Overrode length of ParmValue to 500 in this one program.
     *  This is because user can send 500 bytes of Audit Description
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

     Fcustmast  uf a e           k disk
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

     D m28400u         pr                  extpgm('M28400U')
     D  pErrMsg                      99
     D  pSessId                      40
     D  pUser                        10
     D  pDict                        10
     D  pPgm                         10
     D  pObjLoc                      10
     D  pParmStr1                   999
     D  pParmStr2                   999
     D  pParmStr3                   999

     D m28400u         pi
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

      /copy qcopysrc,p.excustma
     d cmacur          ds                  likeds(cmarec)

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d ConvertField    pr
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   500    varying

     d ExtractParms    pr

     d ExtractParmStr  pr
     d  parmStr                     999    varying

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

         exWhse = cmawhse;

         select;

           // When Adding, set audit flag to Y

           when mode = 'A';

             cmaaudflg = 'Y';

             // Get current record values first.
             // Note, this is overkill, but done as a best practice.

             excustmast('*GET': exRtnCode: exRtnMsg: exWhse:
                        cmacust: cmacur.cmaaudflg: cmacur.cmaaudexpd:
740aA                   cmacur.cmspflg: cmacur.cmaudr);

             select;

               // Update record if found

               when exRtnCode = '*OK';

                 excustmast('*CHANGE': exRtnCode: exRtnMsg: exWhse:
                            cmacust: cmaaudflg: cmaaudexpd:
740aA                       cmspflg: cmaudr);

               // Otherwise, add record (and create CUSTMAST if necessary)

               other;

                 excustmast('*ADD': exRtnCode: exRtnMsg: exWhse:
                            cmacust: cmaaudflg: cmaaudexpd:
740aA                       cmspflg: cmaudr);

                 // Create CUSTMAST if necessary

                 chain (cmawhse: cmacust) custmast;
                 if not %found(custmast);
                   clear custrec;
                   cmwhse = cmawhse;
                   cmcust = cmacust;
                   cmname = 'Create by M28400U';
                   cmstat = 'A';
                   cmaddts = %timestamp();
                   cmupdts = cmaddts;
                   cmjob = #job;
                   cmuser = #curruser;
                   cmjobnbr = #jobnbr;
                   write(e) custrec;
                endif;

             endsl;

          // Updating only changes date
          // (Only records with audit = Y are displayed to user)

           when mode = 'C' or mode = 'U';

             cmaaudflg = 'Y';

             // Get current record values first.
             // Note, this is overkill, but done as a best practice.

             excustmast('*GET': exRtnCode: exRtnMsg: exWhse:
                        cmacust: cmacur.cmaaudflg: cmacur.cmaaudexpd:
740aA                   cmacur.cmspflg: cmacur.cmaudr);

             select;

               // Update record if found

               when exRtnCode = '*OK';

                 excustmast('*CHANGE': exRtnCode: exRtnMsg: exWhse:
                            cmacust: cmaaudflg: cmaaudexpd:
740aA                       cmspflg: cmaudr);

               // Otherwise, add record

               other;

               excustmast('*ADD': exRtnCode: exRtnMsg: exWhse:
                          cmacust: cmaaudflg: cmaaudexpd:
740aA                       cmspflg: cmaudr);

             endsl;

           // Deleting only changes audit to N and clears date

           when mode = 'D';

             // Get current record values first.
             // Note, this is overkill, but done as a best practice.

             excustmast('*GET': exRtnCode: exRtnMsg: exWhse:
                        cmacust: cmacur.cmaaudflg: cmacur.cmaaudexpd:
740aA                   cmacur.cmspflg: cmacur.cmaudr);

             // Update record if found

             if exRtnCode = '*OK';

                 cmaaudflg = 'N';
                 cmaaudexpd = 0;
740aA            cmaudr = ' ';
740aA            cmspflg = 'N';

                 excustmast('*CHANGE': exRtnCode: exRtnMsg: exWhse:
                            cmacust: cmaaudflg: cmaaudexpd:
740aA                       cmspflg: cmaudr);

             endif;

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
     d  parmName                     10    varying
     d  parmValue                   500    varying

     * Local Variables

     d testDate        s               d

      /free

       monitor;

         select;

           when parmName = 'MODE';
             mode = %xlate(xlower: xupper: parmValue);

740aA      when parmName = 'CMAUDR';
740aA        cmaudr = parmValue;
740 A        if cmaudr = *blanks;
740 A          pErrMsg = 'Audit Reason cannot be blank';
740 A          return;
740 A        endif;

           when parmName = 'CMWHSE';
             if parmValue = '';
               parmValue = '0';
             endif;
             cmawhse = %dec(parmValue: 3: 0);

740 D      //when parmName = 'CMCUST';
740 M      when parmName = 'CALCULA008';
             if parmValue = '';
               parmValue = '0';
             endif;
740 D        //cmacust = %dec(parmValue: 11: 0);
740 A        cmcusta = %trim(parmValue);
740 A        exec sql select cmcust into :cmacust
740 A                   from custmast
740 A                where cmwhse=:cmawhse and cmcusta=:cmcusta;
740 A        if sqlstt <> '00000';
740 A          monitor;
740 M            cmacust = %dec(%trim(parmValue): 11: 0);
740 A          on-error;
740 A            pErrMsg = 'Customer Number(' + %trim(parmValue) + ') invalid';
740 A            return;
740 A          endmon;
740 A        else;
740 A        endif;

           when parmName = 'CMAAUDEXPD';
             if parmValue = '';
               parmValue = '0';
             endif;
             cmaaudexpd = %dec(parmValue: 8: 0);
             monitor;
               if cmaaudexpd <> 0;
                 testDate = %date(cmaaudexpd:*iso);
               endif;
             on-error;
               pErrMsg = 'Invalid date (' + parmValue + ')';
               return;
             endmon;

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
     D parmGroup       s            600    varying
     D parmLen         s              5  0
     D parmName        s             10    varying
     D parmStrLen      s              5  0
     D parmValue       s            500    varying
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

