      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M33000  Maintain Role Efficeincies
     *  02 July 2021
     *  Kenneth Elder
     *
     *  Revisions:
     *
750 A*    07/02/21  KDE  7.50
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *  This is an example of a processing program that is called via
     *  the GENFNC SQL Function (RPG program PGENFNC).
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
     froleusrlvluf a e           k disk

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

     d c               s              2  0
     d dpCombo         s             20    varying
     d errMsg          s             99    varying
     d pCmd            s             10
     d prvpscd1        s              3
     d prvznec1        s             10
     d prvcomp1        s              1
     d prvpscd2        s              3
     d prvznec2        s             10
     d prvcomp2        s              1
     d prvpscd3        s              3
     d prvznec3        s             10
     d prvcomp3        s              1
     d prvpscd4        s              3
     d prvznec4        s             10
     d prvcomp4        s              1
     d prvpscd5        s              3
     d prvznec5        s             10
     d prvcomp5        s              1
     d prvpscd6        s              3
     d prvznec6        s             10
     d prvcomp6        s              1
     d pusr            s             10
     d roleStr         s             60
     d wkpscd          s              3
     d wkznec          s             10
     d wkcomp          s              1

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar
      /copy qcopysrc,c#stdsql
      /copy qcopysrc,p.getempl

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

     D M33000          pr                  extpgm('M33000')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     D M33000          pi
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
740 D      pOutStr = '{"errMsg":"' + errMsg + '"}';
           WrtDebugError();
           return;
         endif;

         select;
         when pCmd = '*UPDROLES';
         // update databse
         roleStr=*blanks;
         c=1;
         dow c < 7;

           select;
             when c = 1;
                 roleStr= prvznec1;
                 wkpscd = prvpscd1;
                 wkznec = prvznec1;
                 wkcomp = prvcomp1;
                 if wkznec <> *blanks and wkcomp=*blanks;
                   errmsg = 'Primary Role specified without an ' +
                            'efficiency rating';
740 D              pOutStr = '{"errMsg":"' + errMsg + '"}';
                   WrtDebugError();
                   return;
                 endif;
             when c = 2;
                 if prvznec2<>*blanks and prvznec1=*blanks;
                   errmsg = 'Role in Secondary 1 cannot be specified ' +
                            'without Primary Role';
740 D              pOutStr = '{"errMsg":"' + errMsg + '"}';
                   WrtDebugError();
                   return;
                 endif;
                 if %scan(prvznec2:roleStr) > 0 and prvznec2<>*blanks;
                   errmsg = 'Role in Secondary 1 is duplicated with ' +
                            'another Role';
740 D              pOutStr = '{"errMsg":"' + errMsg + '"}';
                   WrtDebugError();
                   return;
                 else;
                   %subst(roleStr:11:10) = prvznec2;
                 endif;
                 wkpscd = prvpscd2;
                 wkznec = prvznec2;
                 wkcomp = prvcomp2;
                 if wkznec <> *blanks and wkcomp=*blanks;
                   errmsg = 'Secondary Role 1 specified without an ' +
                            'efficiency rating';
740 D              pOutStr = '{"errMsg":"' + errMsg + '"}';
                   WrtDebugError();
                   return;
                 endif;
             when c = 3;
                 if prvznec3<>*blanks and prvznec2=*blanks;
                   errmsg = 'Role in Secondary 2 cannot be specified ' +
                            'without Secondary 1';
740 D              pOutStr = '{"errMsg":"' + errMsg + '"}';
                   WrtDebugError();
                   return;
                 endif;
                 if %scan(prvznec3:roleStr) > 0 and prvznec3<>*blanks;
                   errmsg = 'Role in Secondary 2 is duplicated with ' +
                            'another Role';
740 D              pOutStr = '{"errMsg":"' + errMsg + '"}';
                   WrtDebugError();
                   return;
                 else;
                   %subst(roleStr:21:10) = prvznec3;
                 endif;
                 wkpscd = prvpscd3;
                 wkznec = prvznec3;
                 wkcomp = prvcomp3;
                 if wkznec <> *blanks and wkcomp=*blanks;
                   errmsg = 'Secondary Role 2 specified without an ' +
                            'efficiency rating';
740 D              pOutStr = '{"errMsg":"' + errMsg + '"}';
                   WrtDebugError();
                   return;
                 endif;
             when c = 4;
                 if prvznec4<>*blanks and prvznec3=*blanks;
                   errmsg = 'Role in Secondary 3 cannot be specified ' +
                            'without Secondary 2';
740 D              pOutStr = '{"errMsg":"' + errMsg + '"}';
                   WrtDebugError();
                   return;
                 endif;
                 if %scan(prvznec4:roleStr) > 0 and prvznec4<>*blanks;
                   errmsg = 'Role in Secondary 3 is duplicated with ' +
                            'another Role';
740 D              pOutStr = '{"errMsg":"' + errMsg + '"}';
                   WrtDebugError();
                   return;
                 else;
                   %subst(roleStr:31:10) = prvznec4;
                 endif;
                 wkpscd = prvpscd4;
                 wkznec = prvznec4;
                 wkcomp = prvcomp4;
                 if wkznec <> *blanks and wkcomp=*blanks;
                   errmsg = 'Secondary Role 3 specified without an ' +
                            'efficiency rating';
740 D              pOutStr = '{"errMsg":"' + errMsg + '"}';
                   WrtDebugError();
                   return;
                 endif;
             when c = 5;
                 if prvznec5<>*blanks and prvznec4=*blanks;
                   errmsg = 'Role in Secondary 4 cannot be specified ' +
                            'without Secondary 3';
740 D              pOutStr = '{"errMsg":"' + errMsg + '"}';
                   WrtDebugError();
                   return;
                 endif;
                 if %scan(prvznec5:roleStr) > 0 and prvznec5<>*blanks;
                   errmsg = 'Role in Secondary 4 is duplicated with ' +
                            'another Role';
740 D              pOutStr = '{"errMsg":"' + errMsg + '"}';
                   WrtDebugError();
                   return;
                 else;
                   %subst(roleStr:41:10) = prvznec5;
                 endif;
                 wkpscd = prvpscd5;
                 wkznec = prvznec5;
                 wkcomp = prvcomp5;
                 if wkznec <> *blanks and wkcomp=*blanks;
                   errmsg = 'Secondary Role 4 specified without an ' +
                            'efficiency rating';
740 D              pOutStr = '{"errMsg":"' + errMsg + '"}';
                   WrtDebugError();
                   return;
                 endif;
             when c = 6;
                 if prvznec6<>*blanks and prvznec5=*blanks;
                   errmsg = 'Role in Secondary 5 cannot be specified ' +
                            'without Secondary 4';
740 D              pOutStr = '{"errMsg":"' + errMsg + '"}';
                   WrtDebugError();
                   return;
                 endif;
                 if %scan(prvznec6:roleStr) > 0 and prvznec6<>*blanks;
                   errmsg = 'Role in Secondary 5 is duplicated with ' +
                            'another Role';
740 D              pOutStr = '{"errMsg":"' + errMsg + '"}';
                   WrtDebugError();
                   return;
                 else;
                   %subst(roleStr:51:10) = prvznec6;
                 endif;
                 wkpscd = prvpscd6;
                 wkznec = prvznec6;
                 wkcomp = prvcomp6;
                 if wkznec <> *blanks and wkcomp=*blanks;
                   errmsg = 'Secondary Role 5 specified without an ' +
                            'efficiency rating';
740 D              pOutStr = '{"errMsg":"' + errMsg + '"}';
                   WrtDebugError();
                   return;
                 endif;
           endsl;

           chain (pUsr:wkpscd:wkznec) roleusrlvl;

           rvuser = pUsr;
           rvpscd = wkpscd;
           rvznec = wkznec;
           rvcomp = wkcomp;

           if %found(roleusrlvl);
             // update record
             update rvrec;
           else;
             // create record
             if wkpscd<>*blanks and wkznec<>*blanks;
               write rvrec;
             else;
               // If role is blank see if Primary/Secondary
               // record exists and delete
               chain (pUsr:wkpscd) roleusrlvl;
               if %found(roleusrlvl);
                 delete rvrec;
               endif;
             endif;
           endif;
           c=c+1;
         enddo;

         when pCmd = '*LOADDATA';

           pOutStr = '{'
                   +  '"datasent":"'  + 'YES' + '"';
           setll (pUsr) roleusrlvl;
           dow forever=forever;
             reade (pUsr) roleusrlvl;
             if %eof(roleusrlvl) or not %equal(roleusrlvl);
               // terminate json string and leave;
               leave;
             endif;
             select;
               when rvpscd = 'P00';
                 pOutStr = pOutstr +  ',"GFA10_01":"'  + %trim(rvznec) + '",' +
                                      '"GFA01_01":"'  +%trim(rvcomp) + '"';
               when rvpscd = 'S01';
                 pOutStr = pOutstr +  ',"GFA10_02":"'  + %trim(rvznec) + '",' +
                                      '"GFA01_02":"'  + %trim(rvcomp) + '"';
               when rvpscd = 'S02';
                 pOutStr = pOutstr +  ',"GFA10_03":"'  + %trim(rvznec) + '",' +
                                      '"GFA01_03":"'  + %trim(rvcomp) + '"';
               when rvpscd = 'S03';
                 pOutStr = pOutstr +  ',"GFA10_04":"'  + %trim(rvznec) + '",' +
                                      '"GFA01_04":"'  + %trim(rvcomp) + '"';
               when rvpscd = 'S04';
                 pOutStr = pOutstr +  ',"GFA10_05":"'  + %trim(rvznec) + '",' +
                                      '"GFA01_05":"'  + %trim(rvcomp) + '"';
               when rvpscd = 'S05';
                 pOutStr = pOutstr +  ',"GFA10_06":"'  + %trim(rvznec) + '",' +
                                      '"GFA01_06":"'  + %trim(rvcomp) + '"}';
             endsl;
           enddo;
           pOutStr = %trim(pOutStr) + '}';
           return;

         endsl;

         pOutStr = '{'
                +  '"errmsg":"'  + 'OK' + '"}';

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

           when parmName = 'CMD';
             pCmd =  parmValue;

           when parmName = 'USR';
             pUsr =  parmValue;

         // Primary Role Data
           when parmName = 'GFA03_01';
             prvpscd1 =  parmValue;

           when parmName = 'GFA10_01';
             prvznec1 =  parmValue;

           when parmName = 'GFA01_01';
             prvcomp1 =  parmValue;

         // Secondary 1 Role Data
           when parmName = 'GFA03_02';
             prvpscd2 =  parmValue;

           when parmName = 'GFA10_02';
             prvznec2 =  parmValue;

           when parmName = 'GFA01_02';
             prvcomp2 =  parmValue;

         // Secondary 2 Role Data
           when parmName = 'GFA03_03';
             prvpscd3 =  parmValue;

           when parmName = 'GFA10_03';
             prvznec3 =  parmValue;

           when parmName = 'GFA01_03';
             prvcomp3 =  parmValue;

         // Secondary 3 Role Data
           when parmName = 'GFA03_04';
             prvpscd4 =  parmValue;

           when parmName = 'GFA10_04';
             prvznec4 =  parmValue;

           when parmName = 'GFA01_04';
             prvcomp4 =  parmValue;

         // Secondary 4 Role Data
           when parmName = 'GFA03_05';
             prvpscd5 =  parmValue;

           when parmName = 'GFA10_05';
             prvznec5 =  parmValue;

           when parmName = 'GFA01_05';
             prvcomp5 =  parmValue;

         // Secondary 5 Role Data
           when parmName = 'GFA03_06';
             prvpscd6 =  parmValue;

           when parmName = 'GFA10_06';
             prvznec6 =  parmValue;

           when parmName = 'GFA01_06';
             prvcomp6 =  parmValue;

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

