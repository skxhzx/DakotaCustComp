      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  I26400      Po PCM Verification
     *  16 April 2020
     *  Lynn McMahon
     *
     *  Revisions:
     *
740 A*    04/16/20  LMC  7.40
     *      - Created.
740aA*    06/05/20  LMC  7.40a
     *      - Added PCM follow-up logic
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
     Fpohhdr    if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------
      /copy qcopysrc,p.CHKPCM

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d CreateTS        pr              z
     d  date                          8p 0 const
     d  time                          6p 0 const

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
     d aawhse          s              3s 0
     d aapo            s              9
     d aadatetime      s             15
     d aadate          s              8  0
740aAd aalevl          s              9
     d aatime          s              6  0
     d aaneedpcm       s              1
     d aapcmvfy        s              1
     D pcmcmd          s              8
     D pcmlvl          s              4
     D pcmsup          s              1
     D pcmtyp          s              3
     D pentpcm         s              1
     D pcmseq          s              5  0
     D pcmitm          s             15
     D pohdrexpdtts    s               z
     D pohdrtoexpdtts  s               z
     D pohdrfrexpdtts  s               z
     D verified        s              1

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  files
     *----------------------------------------------------------------

     D hlrec         e ds                  extname(haccplog)
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

     D I26400          pr                  extpgm('I26400')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     D I26400          pi
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

         Select;
           when cmd = '*POVFY';
             pcmcmd = cmd;
             pcmlvl = 'RCVV';
             pcmitm = aadatetime;
             CHKPCM(pcmcmd: aawhse: pcmlvl: pcmtyp:
                    aapo: pcmseq: pcmsup: pcmitm: pentpcm);

             poutstr = pentpcm;
740aA      when cmd = '*POFU';
740aA        pcmcmd = cmd;
740aA        pcmlvl = aalevl;
740aA        pcmitm = aadatetime;
740aA        CHKPCM(pcmcmd: aawhse: pcmlvl: pcmtyp:
740aA               aapo: pcmseq: pcmsup: pcmitm: pentpcm);

740aA        poutstr = pentpcm;
           when cmd = '*PRVEX';
             // need to get  the last exported date.
             // this will be used to filter what is shown in the view pcm
             setll (aawhse: aapo: aadate: aatime) pohhdr;
             readpe (aawhse: aapo) pohhdr;
             if %found(pohhdr);
               pohdrexpdtts = CreateTS(phhedt: phheti);
               poutstr = %char(pohdrexpdtts);
             endif;
           when cmd = '*VERIFIED';
             verified = ' ';
             // need to see if we have multiple exports of a po
             setgt (aawhse: aapo: aadate: aatime) pohhdr;
             reade  (aawhse: aapo) pohhdr;
             if not %eof(pohhdr);
               // do we have verification
               pohdrtoexpdtts = CreateTS(phhedt: phheti);
               pohdrfrexpdtts = CreateTS(aadate: aatime);
               exec sql select * into :hlrec
                    from haccplog
                    where hlwhse = :aawhse
                    and hlpo   = :aapo
                    and hllevl = 'RCVV'
                    and hladdts > :pohdrfrexpdtts
                    and hladdts > :pohdrtoexpdtts
                  fetch first row only;
               if sqlstt = sqlSuccess;
                 verified = 'Y';
               endif;
             else;
               // do we have verification
               pohdrfrexpdtts = CreateTS(aadate: aatime);
               exec sql select * into :hlrec
                    from haccplog
                    where hlwhse = :aawhse
                    and hlpo   = :aapo
                    and hllevl = 'RCVV'
                    and hladdts > :pohdrfrexpdtts
                  fetch first row only;
               if sqlstt = sqlSuccess;
                 verified = 'Y';
               endif;
             endif;
             poutstr = verified;

           other;
               poutstr = ' ';
         Endsl;
         //pOutStr = '{'
         //        +    '"user":"' + pUser + '",'
         //        +    '"combo":"' + dpCombo + '",'
         //        +    '"cmd":"' + %trim(cmd) + '",'
         //        +    '"po":"' + %trim(aapo) + '",'
         //        +    '"show":"' + %trim(aaneedpcm) + '",'
         //        +    '"whs":"' + %char(aawhse) + '"'
         //        + '}';

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

740aA      when parmName = 'levl';
740aA        aalevl = %xlate(xlower: xupper: parmValue);
740aA
           when parmName = 'whs';
             if parmValue = '';
               parmValue = '0';
             endif;
             aawhse =  %dec(parmValue: 3: 0);

           when parmName = 'dttm';
             aadatetime = %xlate(xlower: xupper: parmValue);

           when parmName = 'date';
             if parmValue = '';
               parmValue = '0';
             endif;
             aadate =  %dec(parmValue: 8: 0);

           when parmName = 'time';
             if parmValue = '';
               parmValue = '0';
             endif;
             aatime =  %dec(parmValue: 6: 0);

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

     *----------------------------------------------------------------
     *  CreateTS   Create timestamp from Date/Time
     *----------------------------------------------------------------

     p CreateTS        b
     d CreateTS        pi              z
     d  date                          8p 0 const
     d  time                          6p 0 const

     *  Local Variables

     D stamp           s               z
     D temp26          s             26

     D                 ds
     D  yyyymmdd               1      8s 0
     D    yyyy                 1      4
     D    mm                   5      6
     D    dd                   7      8

     D                 ds
     D  hhmiss                 1      6s 0
     D    hh                   1      2
     D    mi                   3      4
     D    ss                   5      6


      /free

        clear stamp;

        if date = 0;
          return stamp;
        endif;

        yyyymmdd = date;
        hhmiss = time;
        temp26 = yyyy + '-' + mm + '-' + dd + '-'
               + hh + '.' + mi + '.' + ss + '.000000';

        monitor;
          stamp = %timestamp(temp26);
        on-error;
          clear stamp;
        endmon;

        return stamp;

      /end-free

     p CreateTS        e

