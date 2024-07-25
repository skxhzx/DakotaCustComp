      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H bnddir('YAJL')

     *----------------------------------------------------------------
     *   Copyright (C) 2021 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  I31200       Get fields for I31200 - GENFNC
     *  28 August 2021
     *  Dave Sommerville
     *
     *  Revisions:
     *
750 A*    08/28/21  DAS  7.50
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

     *----------------------------------------------------------------
     *  YAJL Header
     *----------------------------------------------------------------

      /copy qcopysrc,yajl_h
     d yajlerr         s            500    varying

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

     d dbgflgExists    s               n
     d debug           s               n
     d debugAfter      s               n
     d debugBefore     s               n
     d debugLoc        s              1

     d errMsg          s             99    varying
     d dpCombo         s             20    varying

     d logts           s             26
     d ts              s               z

     D whereFrom       s             20
     D nxtscr          s             20
     D input           s             50
     D spoken          s             50
     D fFlags          s             15
     D bFlags          s             15
     D trn#            s              7
     D lbl#            s              7
     D slot            s             12
     D logerrmsg       s             50
     D apkver          s             10

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pParmStr    String of '|' delimited parameters
     *                  logts- Log timestamp
     *
     *    Returned Parameters
     *      pOutStr     Return string in JSON format
     *
     *----------------------------------------------------------------

     D I31200          pr                  extpgm('I31200')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     D I31200          pi
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d GetLogRec       pr

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

         // Initialize return variables

         wherefrom = '';
         nxtscr = '';
         input = '';
         fflags = '';
         bflags = '';
         slot = '';
         trn# = '';
         lbl# = '';
         slot = '';
         logerrmsg = '';
         apkver = '';

         // Extract parameters from delimited string

         ExtractParms();

         // Get out if error

         if errMsg <> '';
           logerrmsg = errMsg;
           WrtDebugError();
         else;
           GetLogRec();
         endif;

         // Create JSON string to send back

         yajl_genOpen(*OFF);             // Init unformatted JSON procesing
           yajl_beginObj();              // Begin JSON string

             yajl_addchar('whereFrom': %trim(whereFrom));
             yajl_addchar('nxtscr': %trim(nxtscr));
             yajl_addchar('input': %trim(input));
             yajl_addchar('spoken': %trim(spoken));
             yajl_addchar('fflags': %trim(fFlags));
             yajl_addchar('bflags': %trim(bFlags));
             yajl_addchar('trn': %trim(trn#));
             yajl_addchar('lbl': %trim(lbl#));
             yajl_addchar('slot': %trim(slot));
             yajl_addchar('errmsg': %trim(logerrmsg));
             yajl_addchar('apkver': %trim(apkver));

           yajl_endObj();                 // End entire JSON string
           pOutStr = YAJL_copyBufStr();   // Copy JSON string into parameter
         yajl_genClose();                 // Close and cleanup JSON processing

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
     *  GetLogRec   Get BFCSKTLOG record
     *----------------------------------------------------------------

     p GetLogRec       b
     d GetLogRec       pi

     d pos             s             10i 0
     d pos2            s             10i 0
     d i               s             10i 0
     d slgipInd        s              5i 0
     d slgtypInd       s              5i 0
     d slgbufInd       s              5i 0

     D slgrec        E ds                  extname(bfcsktlog) inz(*EXTDFT)

      /free

        exec sql select slgip, slgtyp, slgbuf
                 into :slgip :slgipInd,
                      :slgtyp :slgtypInd,
                      :slgbuf :slgbufInd
                 from bfcsktlog
                 where slgts = :ts;

        if sqlstt <> sqlSuccess;
          return;
        endif;

             pos = %scan('whereFrom': slgbuf);
             if pos > 0;
               pos += 12;
               pos2 = %scan('"': slgbuf: pos);
               wherefrom = %subst(slgbuf: pos: pos2-pos);
             endif;

             pos = %scan('w1trn': slgbuf);
             if pos > 0;
               pos += 8;
               pos2 = %scan('"': slgbuf: pos);
               trn# = %subst(slgbuf: pos: pos2-pos);
               input = %subst(slgbuf: pos: pos2-pos);
             endif;

             pos = %scan('mtrn': slgbuf);
             if pos > 0;
               pos += 7;
               pos2 = %scan('"': slgbuf: pos);
               input = %subst(slgbuf: pos: pos2-pos);
             endif;

             pos = %scan('slvfyval': slgbuf);
             if pos > 0;
               pos += 11;
               pos2 = %scan('"': slgbuf: pos);
               input = %subst(slgbuf: pos: pos2-pos);
             endif;

             pos = %scan('w6cnt1e': slgbuf);
             if pos > 0;
               pos += 10;
               pos2 = %scan('"': slgbuf: pos);
               input = %subst(slgbuf: pos: pos2-pos);
             endif;

             pos = %scan('w7cwgt': slgbuf);
             if pos > 0;
               pos += 9;
               pos2 = %scan('"': slgbuf: pos);
               input = %subst(slgbuf: pos: pos2-pos);
             endif;

             pos = %scan('f1f24flags': slgbuf);
             if pos > 0 and slgtyp = 'Beg';
               pos += 13;
               for i = 1 to 24;
                 if %subst(slgbuf: pos+i-1: 1) = '1';
                   fflags = %trimr(fflags) + 'Fkey ' + %char(i);
                 endif;
               endfor;
             endif;

             pos = %scan('btnflags': slgbuf);
             if pos > 0 and slgtyp = 'Beg';
               pos += 11;
               for i = 1 to 10;
                 if %subst(slgbuf: pos+i-1: 1) = '1';
                   bflags = %trimr(bflags) + 'Btn ' + %char(i);
                 endif;
               endfor;
             endif;

             pos = %scan('"nxtscr': slgbuf);
             if pos > 0;
               pos += 10;
               pos2 = %scan('"': slgbuf: pos);
               nxtscr = %subst(slgbuf: pos: pos2-pos);
             endif;

             pos = %scan('spoken': slgbuf);
             if pos > 0;
               pos += 9;
               pos2 = %scan('"': slgbuf: pos);
               spoken = %subst(slgbuf: pos: pos2-pos);
             endif;

             pos = %scan('Slot:': slgbuf);
             if pos > 0;
               pos += 6;
               pos2 = %scan('"': slgbuf: pos);
               slot = %subst(slgbuf: pos: pos2-pos);
             endif;

             pos = %scan('errmsg': slgbuf);
             if pos > 0;
               pos += 9;
               pos2 = %scan('"': slgbuf: pos);
               logerrmsg = %subst(slgbuf: pos: pos2-pos);
             endif;

             pos = %scan('apkver': slgbuf);
             if pos > 0;
               pos += 9;
               pos2 = %scan('"': slgbuf: pos);
               apkver = %subst(slgbuf: pos: pos2-pos);
             endif;

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

     d lowParmName     s             30A   varying
     d lowercase       c                   'abcdefghijklmnopqrstuvwxyz'
     d uppercase       c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

      /free

       // Force parm name to lowercase to eliminate case errors

       lowParmName = %xlate(uppercase: lowercase: parmName);

       monitor;

         select;

           when lowParmName = 'logts';
             ts = %timestamp(parmValue);

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
                  + 'pOutStr:' + %trimr(pOutStr) + ', '
                  + 'logts:' + %trimr(logts) + ', '
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

