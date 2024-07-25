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
750cA*    02/01/22  KDE  7.50c
     *      - Enh:  Add additional cll for poutstr to increase bytes from
     *        1024 to 3072.  Code is written in such a way where you should
     *        only have to create another callnum.  Currently stops at callnum 3.
     *        If you add a forth it wiill always build out full json in largestr
     *        and then substring out what it should based on callnum. Callnum 1
     *        will send down 1-1024, 2 sends 1025-2048, etc..  Every cycle builds
     *        the full json in largestr and decides if the multiple calls adds to
     *        the json sent down or sends blanks.  Then in R382xx it calls each of
     *        the calculat's to append all into one long json string.  I have this
     *        set where you want to keep largestr 2000 bytes longer than what you send
     *      - When taking this mod you MUST take R38201 or later from MRC
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
750cAd aacallnum       s              1  0
750bDd*aacnt           s              4  0
750bAd aapcs           s              7  0
750bAd aabulkqty       s              5  0
750bAd pos             s              5  0
750cAD currStr         s           2000    varying
750cAD largeStr        s           6000    varying
750cAD startPos        s              5p 0
750cAD endPos          s              5p 0
750cAD outLen          s              5p 0
750cAD maxLen          s              5p 0
750cAD len             s              5p 0
750cAD remainLen       s              5p 0
750cAd full            s               n
750cAd firstRec        s               n

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
           pOutStr = ' ';
           return;
         endif;

750cA    if aaCallNum=0;
750cA      aaCallNum=1;
750cA    endif;

750cA    // Initialize max lengths
750cA    outLen = %size(pOutstr) - 2;
750cA    maxLen = %size(largeStr) - 2;

750cA    // If call size greater than max length, get out

750cA    if (aaCallNum * outLen) > maxLen;
750cA      pOutStr = '';
750cA      return;
750cA    endif;

         // start largestr with basic structure before loop processing
         // which will add all stop information for tag PLTSTR
750cA    largeStr = '{'
                +  '"MPLT":"'  + %char(aaMPLT) + '",'
                +  '"PLTSTR":"';

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

750cA    firstRec = *on;
         dow forever = forever;
            exec sql fetch next from chrte into :aamplt,:aamrte,:aastop,
                                                :aacnam,:aapcs;
            if sqlStt <> '00000';
              leave;
            endif;

750cD       //if rtnPltStr=*blanks;
750cD         //rtnPltStr = '(' + %trim(aamrte) + '/' + %char(aastop) + ')' +
            // when not first record we will space between stops with underscores
750cA       if firstRec = *off;
750cA         currstr += '_____';
750cA       endif;

750cM       currStr += '(' + %trim(aamrte) + '/' + %char(aastop) + ')' +
                        %trim(aacnam);

            // Jakes specific code
JFF A       if client = Jakes;
JFF A         // For Jakes add pieces to end of Stop
750cD         //rtnPltStr = %trim(rtnPltStr) + '_<strong>P:'
JFF A         currStr = %trim(currStr) + '_<strong>P:'
                          + %char(aapcs);
              // get Bulk Quantity on pallet with non Bulk Pick items
              aabulkqty=0;
              exec sql select sum(lwqalc) into :aabulkqty
                          from worklbl as a
                       where a.lwwhse= :aawhse and a.lwrte=:aartid
                         and a.lwpal#=:aaplid and a.lwstop=:aastop
                         and a.lwwhdp='*BULK' and
                    (select count(*) from worklbl as b
                          where b.lwwhse= a.lwwhse and b.lwrte=a.lwrte
                            and b.lwpal#=a.lwpal# and b.lwstop=a.lwstop
                            and b.lwtype='O' and lwwhdp<>'*BULK')>0;
              if aabulkQty>0;
                currStr = %trim(currStr) + '__BA:' + %char(aabulkqty);
              endif;
              // get Bulk Quantity on pallet to itself
              aabulkqty=0;
              exec sql select sum(lwqalc) into :aabulkqty
                          from worklbl as a
                       where a.lwwhse= :aawhse and a.lwrte=:aartid
                         and a.lwpal#=:aaplid and a.lwstop=:aastop
                         and a.lwwhdp='*BULK' and
                    (select count(*) from worklbl as b
                          where b.lwwhse= a.lwwhse and b.lwrte=a.lwrte
                            and b.lwpal#=a.lwpal# and b.lwstop=a.lwstop
                            and b.lwtype='O' and lwwhdp<>'*BULK')=0;
              if aabulkQty>0;
                currStr = %trim(currStr) + '__BP:' + %char(aabulkqty);
              endif;
              currStr = %trim(currStr) + '</strong>';
JFF A       endif;

750cA       if not full;
750cA         exsr append;
750cA       endif;

750cD       //else;
750cD       //  rtnPltStr = %trim(rtnPltStr) +
750bD                 //    ',  (' + %trim(aamrte) + '/' + %char(aastop) + ')' +
750bD                 //    %trim(aacnam);
750cD       //              '_____(' + %trim(aamrte) + '/' + %char(aastop) +
750cD       //              ')' + %trim(aacnam);

750cD       //if client = Jakes;
750cD         // For Jakes add pieces to end of Stop
750cD         //rtnPltStr = %trim(rtnPltStr) + '_<em><strong>P:'
750cD          //           + %char(aapcs) + '</strong></em>';
750cD       //endif;

750cD       //endif;
         enddo;
         exec sql close chrte;

         // after processing all stops you must end json in largestr properly
750cA    largestr += '"}';

         // since the complete json string processes for every call number pass
         // the next few statements determine the beginning and ending portion of
         // largestr to pass down.  Essentially R382xx in MRC calls this process
         // three times currently and passed in callnum 1,2 or 3.  The next few statements
         // and several if's afterwards set startpos and enpos to substring the proper
         // portion of largestr to build a string beyond 1024 bytes that FGENFNC supports.
         // Freemarker is joining the three strings to build the complete json string.
750cA    startPos = ((aaCallNum - 1) *outlen) +1;
750cA    endpos = aaCallNum * outlen;
750cA    if endPos > %len(largeStr);
750cA      endPos = %len(largeStr);
750cA    endif;
750cA
         // if startpos is beyond length of largestr that
         // indicates the calls beyond the previous call number
         // have nothing so we should return blanks
         if startPos > %len(largeStr);
           pOutStr=*blanks;
           return;
         endif;

         // if startpos greater than 1 we need to adjust enpos to
         // get proper characters
         if startPos > 1;
           endPos = (endPos - startPos) + 1;
         endif;

         // Return range for the correct call number
         pOutStr = %subst(largeStr:startPos:endPos);

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

750cA*----------------------------------------------------------------
750cA*  Append    Append to large string
750cA*----------------------------------------------------------------

      /free
750cA  begsr Append;

         firstRec = *off;
         remainLen = maxLen - %len(largeStr) - 2;

         // If everything fits, append previous string

         if (%len(largeStr)+%len(currStr)) <= remainLen;
           dow %scan('&':currStr) > 0;
             currStr = %replace(' ':currStr:%scan('&':currStr));
           enddo;
           largeStr += currStr;
           currStr = '';
           leavesr;
         endif;

         // Otherwise we have overflow condition.

         full = *on;
750cA    largestr += '"}';
750cA    pOutStr = %trim(largeStr);
         return;

750cA  endsr;
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

750cA      when parmName = 'CALLNUM';
750cA        if parmValue = '';
750cA          parmValue = '1';
750cA        endif;
750cA        monitor;
750cA          aacallnum =  %dec(parmValue: 1: 0);
750cA        on-error;
750cA          aacallnum =  1;
750cA        endmon;

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
                  + 'pOutLen:' + %char(%len(pOutStr)) + ', '
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
