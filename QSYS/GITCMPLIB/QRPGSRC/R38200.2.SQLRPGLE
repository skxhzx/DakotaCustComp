      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  R38500  Return string with Route/Stops for each Pallet
     *  06 June 2021
     *  Kenneth Elder
     *
     *  Revisions:
     *
750 A*    06/06/21  KDE  7.50
     *      - Created.
     *
750aA*    09/22/21  KDE  7.50a
     *      - Enh:  Change where it runs correctly for Super Route or
     *        normal route
     *
750bA*    01/26/22  KDE  7.50b
     *      - Enh:  Change to get pieces for stop instead of doing count
     *        in sql.  Also bring change down from Chefs never brought back.
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
     Frtehed    if   e           k disk

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
     d aawhse          s              3  0
     d aartid          s              5
     d aaplid          s              7  0
     d aamplt          s              7  0
     d aamrte          s              5
     d aastop          s              5  0
     d aacnam          s             40
750bDd*aacnt           s              4  0
750bAd aapcs           s              7  0
750bAd pos             s              5  0
     d rtnPltStr       s           1000

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar
      /copy qcopysrc,c#stdsql
      /copy qcopysrc,p.getempl

JFF A*----------------------------------------------------------------
JFF A*  Customer id
JFF A*----------------------------------------------------------------

JFF A /copy qcopysrc,id#jff

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

     D r38200          pr                  extpgm('R38200')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     D r38200          pi
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
740 D      //pOutStr = '{"errMsg":"' + errMsg + '"}';
740 M      pOutStr = ' ';
           WrtDebugError();
           return;
         endif;

750aA    // Determine if Super Route
750aA    chain (aawhse:aartid) rtehed;
750aA    if not %found;
750aA      rhrte=*blanks;
750aA    endif;
         // Build comma delimited string with what Route and Stops exist on
         // passed pallet
750aA    if %subst(rhrte:1:3)='#SR';
          sqlStmt =
750bD      //'select pspal#,sromrte,rtsst5,ohcnam,count(*) from rtehed,pltsum,' +
750bM    'select pspal#,sromrte,rtsst5,ohcnam,sum(lwqalc) from rtehed,pltsum,' +
              'worklbl,srord,ordh,rtestp where rhrtid=' + sq + %trim(aartid) +
              sq + ' and psplid=' + %char(aaplid)  + ' and ' +
              'substring(rhrte,1,3)=' + sq + '#SR' + sq + ' and ' +
              'rhwhse=pswhse and psrtid=rhrtid and psgen in(1,7) and pstype=' +
              sq + 'P' + sq + ' and lwwhse=rhwhse and lwrte=psrtid and psplid='
              + 'lwpal# and srowhs=rhwhse and srosrtid=rhrtid and ' +
              'sromordid=lword ' +
             ' and ohwhse=rhwhse and ohrte=rhrtid and ohord=lword and  ' +
             'rtswhs=rhwhse and rtsrid=rhrtid and rtsord=lword' +
             ' and rtsstp=lwstop' +
             ' group by pspal#,sromrte,rtsst5,ohcnam' +
             ' order by pspal#,sromrte,rtsst5,ohcnam';
750aA    else;
750aA     sqlStmt =
750aA      'select pspal#,rhrte,rtsst5,ohcnam,sum(lwqalc) from rtehed,pltsum,' +
750aA         'worklbl,ordh,rtestp where rhrtid=' + sq + %trim(aartid) +
750aA         sq + ' and psplid=' + %char(aaplid)  + ' and ' +
750aA         'rhwhse=pswhse and psrtid=rhrtid and psgen in(1,7) and pstype=' +
750aA         sq + 'P' + sq + ' and lwwhse=rhwhse and lwrte=psrtid and psplid='
750aA         + 'lwpal# and ' +
750aA        'ohwhse=rhwhse and ohrte=rhrtid and ohord=lword and  ' +
750aA        'rtswhs=rhwhse and rtsrid=rhrtid and rtsord=lword' +
750aA        ' and rtsstp=lwstop' +
750aA        ' group by pspal#,rhrte,rtsst5,ohcnam' +
750aA        ' order by pspal#,rhrte,rtsst5,ohcnam';
750aA    endif;


         exec sql PREPARE cr FROM :SqlStmt;
         exec sql DECLARE chrte SCROLL CURSOR FOR cr;
         exec sql OPEN chrte;

         rtnPltStr=*blanks;
         dow forever = forever;
            exec sql fetch next from chrte into :aamplt,:aamrte,:aastop,
                                                :aacnam,:aapcs;
            if sqlStt <> '00000';
              leave;
            endif;

            if rtnPltStr=*blanks;
              rtnPltStr = '(' + %trim(aamrte) + '/' + %char(aastop) + ')' +
                          %trim(aacnam);

JFF A       if client = Jakes;
JFF A         // For Jakes add pieces to end of Stop
JFF A         rtnPltStr = %trim(rtnPltStr) + '_<em><strong>P:'
                          + %char(aapcs) + '</strong></em>';
JFF A       endif;

            else;
              rtnPltStr = %trim(rtnPltStr) +
750bD                 //    ',  (' + %trim(aamrte) + '/' + %char(aastop) + ')' +
750bD                 //    %trim(aacnam);
750bM                     '_____(' + %trim(aamrte) + '/' + %char(aastop) +
750bM                     ')' + %trim(aacnam);

JFF A       if client = Jakes;
JFF A         // For Jakes add pieces to end of Stop
JFF A         rtnPltStr = %trim(rtnPltStr) + '_<em><strong>P:'
                          + %char(aapcs) + '</strong></em>';
JFF A       endif;

            endif;
         enddo;
         exec sql close chrte;

         // Format name and send back

         pOutStr = '{'
                +  '"MPLT":"'  + %char(aaMPLT) + '",'
                +  '"PLTSTR":"'  + %trim(rtnPltStr) + '"}';

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
JFF A /end-free
JFF A
JFF A* Get client id.
JFF A
JFF AC                   call      'GETCLIENT'
JFF AC                   parm                    client           10
JFF AC                   parm                    clientloc        10
JFF A /free

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
             aawhse =  %dec(parmValue: 3: 0);

           when parmName = 'RTEID';
             aartid =  parmValue;

           when parmName = 'PLID';
             if parmValue = '';
               parmValue = '0';
             endif;
             aaplid =  %dec(parmValue: 7: 0);

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
