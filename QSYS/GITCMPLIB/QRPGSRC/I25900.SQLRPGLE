      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  I25900      Truckbuilder Wave Inquiry Functions
     *  09 February 2020
     *  Kenneth Elder
     *
     *  Revisions:
     *
720 A*    02/09/20  KDE  7.40
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

     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk
     ftbwaved   if   e           k disk
     ftbwerrlog if   e           k disk

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

     d awhse           s              3
     d dbgflgExists    s               n
     d debug           s               n
     d debugAfter      s               n
     d debugBefore     s               n
     d debugLoc        s              1

     d errExist        s               n
     d errMsg          s             99    varying
     d dpCombo         s             20    varying
730aMd inWaveId        s             15
     d inCmd           s             10
     d inWHse          s              3  0
     d color           s             10
     d rtelist         s            500
     d rtecnt          s              5  0
     d rteerr          s              5  0
     d preturn         s             10
     d wactive         s               n
     d outRtnCode      s             10
     d outRtnMsg       s            100
     d $command        s            512a

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

     D I25900          pr                  extpgm('I25900')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     D I25900          pi
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     D ub500           pr                  extpgm('UB500')
     D  iWhse                         3

     D chkwavjob       pr                  extpgm('CHKWAVJOB')
     D  ijob                         10
     D  iuser                        10
     D  ijobnbr                       6
     D  ireturn                      10

     *----------------------------------------------------------------
     * Prototype for QCMDEXC
     *----------------------------------------------------------------
     D Exc_Cmd         PR                  extpgm('QCMDEXC')
     D  command                     200A   const
     D  length                       15P 5 const

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.chkordau

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
           pOutStr = '{"errMsg":"' + errMsg + '",';
           pOutStr = %trim(pOutstr) + '"color":"' + ' ' + '",';
           pOutStr = %trim(pOutstr) + '"rtecnt":"' + '0' + '",';
           pOutStr = %trim(pOutstr) + '"rteerr":"' + '0' + '",';
           pOutStr = %trim(pOutstr) + '"wactive":"' + 'N' + '"}';
           WrtDebugError();
           return;
         endif;

         // Do processing

         select;
           when inCmd='RTELIST';
             setll (inWhse:inWaveId) tbwaved;
             reade (inWhse:inWaveid) tbwaved;
             rtelist = *blanks;
             rtecnt =*zeros;
             rteerr =*zeros;
             wactive=*off;
             dow not %eof(tbwaved);
               rtelist = %trim(rtelist) + '  ' + %trim(twdrte) + '/' +
                         %trim(twdrtid);
               rtecnt=rtecnt+1;
               setll (twdwhs:twdid:twdrte:twdrtid) tbwerrlog;
               reade (twdwhs:twdid:twdrte:twdrtid) tbwerrlog;
               if %equal(tbwerrlog);
                 rteerr=rteerr+1;
               else;
                 if rteerr=0;
                   setll (twdwhs:twdid:' ':' ') tbwerrlog;
                   reade (twdwhs:twdid:' ':' ') tbwerrlog;
                   if %equal(tbwerrlog);
                     rteerr=rteerr+1;
                   endif;
                 endif;
               endif;
               // call process to determine if wave active
               if twdsbmjob<>*blanks and twdsbmuser<>*blanks and
                  twdsbmjobn<>*blanks and not wactive;
                  chkwavjob(twdsbmjob:twdsbmuser:twdsbmjobn:preturn);
                  if preturn='*EXIST';
                    wactive=*on;
                  endif;
               endif;
               reade (inWhse:inWaveid) tbwaved;
             enddo;
             pOutStr = '{"rtelist":"' + %trim(rtelist) + '",';

             // Determine if error or not and send back color
             errExist=*off;
             setll (inWhse:inWaveId) tbwerrlog;
             reade (inWhse:inWaveid) tbwerrlog;
             if not %eof(tbwerrlog) and %equal(tbwerrlog);
               errExist=*on;
             endif;

             // if no Err Log records look to ensure status
             // made it to CMPLT.  If not flag as error when not active
             if not errExist;
               setll (inWhse:inWaveId) tbwaved;
               reade (inWhse:inWaveid) tbwaved;
               dow not %eof(tbwaved) and %equal(tbwaved);
                 if twdsts<>'CMPLT' and not wactive;
                   errExist=*on;
                   leave;
                 endif;
                 reade (inWhse:inWaveid) tbwaved;
               enddo;
             endif;

             // add processing flag
             if wactive;
                pOutStr = %trim(pOutstr) + '"wactive":"' + 'Y' + '",';
             else;
                pOutStr = %trim(pOutstr) + '"wactive":"' + 'N' + '",';
             endif;

             // add color based on errors or no errors
             if errExist;
               pOutStr = %trim(pOutstr) + '"color":"' + 'red' + '",';
             else;
               if wactive;
                 pOutStr = %trim(pOutstr) + '"color":"' + 'yellow' + '",';
               else;
                 pOutStr = %trim(pOutstr) + '"color":"' + 'lightgreen' + '",';
               endif;
             endif;

             // Add total count of routes for Wave
             pOutStr = %trim(pOutstr) + '"rtecnt":"' + %char(rtecnt) + '",';
             // Add total count of routes for Wave in error
             pOutStr = %trim(pOutstr) + '"rteerr":"' + %char(rteerr) + '"}';

           // Export Trucks and Dock Doors
           when inCmd='*FTP';
             monitor;
               aWhse=%editc(inWhse:'X');
               $command = 'SBMJOB CMD(CALL PGM(UB500) PARM(' + sq + aWhse + sq
                          + ')) JOBQ(QSYSNOMAX)';
               Exc_Cmd(%trim($command): %len(%trim($command)));
               pOutStr = '{"errMsg":"FTP Successful"}';
             on-error;
               pOutStr = '{"errMsg":"Submit for FTP(UB500) failed"}';
             endmon;
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
     d  parmValue                   100    varying

      /free

       monitor;

         select;

           when parmName = 'whs';
             if parmValue = '';
               parmValue = '0';
             endif;
             inWhse =  %dec(parmValue: 3: 0);

           when parmName = 'waveid';
             inWaveid = %xlate(xlower: xupper: parmValue);

           when parmName = 'cmd';
             inCmd = %xlate(xlower: xupper: parmValue);

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

