      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M30100 -  Maintain Route Notes via GUI Truckbuilder
     *  16 September 2019
     *  Kenneth Elder
     *
     *  Revisions:
     *
730 A*    09/16/19  KDE  7.30
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk
     Frtenote   uf a e           k disk

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

     d errMsg          s             99
     d dpCombo         s             20    varying
     d cmd             s             10
     d whse            s              3  0
     d rteid           s              5
     d noteMsg0        s             75
     d noteMsg1        s             75
     d noteMsg2        s             75
     d noteMsg3        s             75
     d noteMsg4        s             75
     d noteMsg5        s             75
     d noteMsg6        s             75
     d noteMsg7        s             75
     d noteMsg8        s             75
     d noteMsg9        s             75
     d wrtNote         s             75
     d wrteNote        s               n
     d noteRtn         s            750
     d nextLine        s              3  0
     d byteCount       s              4  0
     d sessid          s             40
     D cr              c                   x'0D'
     D lf              c                   x'25'
     d crlf            c                   x'0D0A'

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

     D r33100          pr                  extpgm('R33100')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     D r33100          pi
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
         errMsg = ' ';

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

         pOutStr = '{'
                 +    '"errMsg":"' + errMsg + '"'
                 + '}';

         // Get out if error

         if errMsg <> '';
           pOutStr = '{"errMsg":"' + errMsg + '"}';
           WrtDebugError();
           return;
         endif;

         sessid = pSessid;
         if cmd='*GETNOTES';
            exsr getNotes;
         else;
            exsr updNotes;
         endif;

         pOutStr = '{'
                 +    '"errMsg":"' + errMsg + '",'
                 +    '"rteNotes":"' + noteRtn + '"'
                 + '}';

         // Write out 'After' Debug info

         if debugAfter;
           debugLoc = 'A';
           wrtAfterDebug();
         endif;

         return;

      /end-free

     *----------------------------------------------------------------
     *  *GETNOTES  -  Get Notes to populate maintenance screen
     *----------------------------------------------------------------

      /free
       begsr getNotes;

          noteRtn = *blanks;
          // loop through Route Notes and create return message variable
          setll (whse:rteid) rtenote;
          reade (whse:rteid) rtenote;

          dow not %eof(rtenote) and %equal(rtenote);
             noteRtn = %trim(noteRtn) + rnnote + '\r\n';
             reade (whse:rteid) rtenote;
          enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  *UPDNOTES  -  Update notes passed from GUI program M301xx
     *----------------------------------------------------------------

      /free
       begsr updNotes;
         // delete current message first
         exec sql delete from rtenote where rnwhse=:whse and rnrtid=:rteid;
         // Convert all the line feeds and carraige returns to ebcdic
         // now loop thru noteMsg and write out 75 character records
         nextline = 1;
         wrtNote = noteMsg0;
         exsr writeNote;
         nextline = 2;
         wrtNote = noteMsg1;
         exsr writeNote;
         nextline = 3;
         wrtNote = noteMsg2;
         exsr writeNote;
         nextline = 4;
         wrtNote = noteMsg3;
         exsr writeNote;
         nextline = 5;
         wrtNote = noteMsg4;
         exsr writeNote;
         nextline = 6;
         wrtNote = noteMsg5;
         exsr writeNote;
         nextline = 7;
         wrtNote = noteMsg6;
         exsr writeNote;
         nextline = 8;
         wrtNote = noteMsg7;
         exsr writeNote;
         nextline = 9;
         wrtNote = noteMsg8;
         exsr writeNote;
         nextline = 10;
         wrtNote = noteMsg9;
         exsr writeNote;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  WriteNote  -  Write Route Note passed in
     *----------------------------------------------------------------

      /free
       begsr writeNote;
         wrteNote=*on;
         // only print if line or line after has text
         select;
           when nextLine=1;
             if notemsg0=*blanks and notemsg1=*blanks and notemsg2=*blanks
                and notemsg3=*blanks and notemsg4=*blanks and notemsg5=*blanks
                and notemsg6=*blanks and notemsg7=*blanks and notemsg8=*blanks
                and notemsg9=*blanks;
                wrteNote=*off;
             endif;
           when nextLine=2;
             if notemsg1=*blanks and notemsg2=*blanks
                and notemsg3=*blanks and notemsg4=*blanks and notemsg5=*blanks
                and notemsg6=*blanks and notemsg7=*blanks and notemsg8=*blanks
                and notemsg9=*blanks;
                wrteNote=*off;
             endif;
           when nextLine=3;
             if notemsg2=*blanks
                and notemsg3=*blanks and notemsg4=*blanks and notemsg5=*blanks
                and notemsg6=*blanks and notemsg7=*blanks and notemsg8=*blanks
                and notemsg9=*blanks;
                wrteNote=*off;
             endif;
           when nextLine=4;
             if notemsg3=*blanks and notemsg4=*blanks and notemsg5=*blanks
                and notemsg6=*blanks and notemsg7=*blanks and notemsg8=*blanks
                and notemsg9=*blanks;
                wrteNote=*off;
             endif;
           when nextLine=5;
             if notemsg4=*blanks and notemsg5=*blanks
                and notemsg6=*blanks and notemsg7=*blanks and notemsg8=*blanks
                and notemsg9=*blanks;
                wrteNote=*off;
             endif;
           when nextLine=6;
             if notemsg5=*blanks
                and notemsg6=*blanks and notemsg7=*blanks and notemsg8=*blanks
                and notemsg9=*blanks;
                wrteNote=*off;
             endif;
           when nextLine=7;
             if notemsg6=*blanks and notemsg7=*blanks and notemsg8=*blanks
                and notemsg9=*blanks;
                wrteNote=*off;
             endif;
           when nextLine=8;
             if notemsg7=*blanks and notemsg8=*blanks
                and notemsg9=*blanks;
                wrteNote=*off;
             endif;
           when nextLine=9;
             if notemsg8=*blanks
                and notemsg9=*blanks;
                wrteNote=*off;
             endif;
           when nextLine=10;
             if notemsg9=*blanks;
                wrteNote=*off;
             endif;
         endsl;

         // Write if needed
         if wrteNote;
           rnwhse=whse;
           rnrtid=rteid;
           rnline=nextLine;
           rnnote=wrtNote;
           rnaddts=%timestamp;
           rnaddusr=#curruser;
           rnaddjob=#job;
           rnaddnbr=#jobnbr;
           rnchgts=%timestamp;
           rnchgusr=#curruser;
           rnchgjob=#job;
           rnchgnbr=#jobnbr;
           write rnrec;
         endif;
       endsr;
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

           when parmName = 'WHS';
             if parmValue = '';
               parmValue = '0';
             endif;
             whse =  %dec(parmValue: 3: 0);

           when parmName = 'CMD';
             cmd = %trim(parmValue);

           when parmName = 'RTEID';
             rteid = %trim(parmValue);

           when parmName = 'NOTES0';
             notemsg0 = %trim(parmValue);

           when parmName = 'NOTES1';
             notemsg1 = %trim(parmValue);

           when parmName = 'NOTES2';
             notemsg2 = %trim(parmValue);

           when parmName = 'NOTES3';
             notemsg3 = %trim(parmValue);

           when parmName = 'NOTES4';
             notemsg4 = %trim(parmValue);

           when parmName = 'NOTES5';
             notemsg5 = %trim(parmValue);

           when parmName = 'NOTES6';
             notemsg6 = %trim(parmValue);

           when parmName = 'NOTES7';
             notemsg7 = %trim(parmValue);

           when parmName = 'NOTES8';
             notemsg8 = %trim(parmValue);

           when parmName = 'NOTES9';
             notemsg9 = %trim(parmValue);

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

