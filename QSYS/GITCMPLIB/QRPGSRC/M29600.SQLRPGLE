      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M29600       Add/Delete UCIWORK records - GS1 Labeler
     *  17 July 2019
     *  Lynn McMahon
     *
     *  Revisions:
     *
730 A*    07/17/19  LMC  7.30
     *      - Created.
730aA*    08/23/19  LMC  7.30a
     *      - Fix: Checkdigit logic had a flaw. Simplified the logic.
740aA*    01/21/20  LMC  7.40a
     *      - Enh: Work with gui or rpg programs.
740bAF*    07/01/20  LMC  7.40b
     F*     - We have changed our internal gs1 labels to use AI code 98
     F*       instead of AI code 01.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *  This is an example of a processing program that is called via
     *  the GENPRC SQL Stored Procedure (RPG program PGENPRC).
     *
     *  The parameters are assumed to be strings containing value
     *  pairs, with multiple pairs being separated by a '|', for example:
     *
     *    fieldname1=value|fieldname2=value|fieldname3=value
     *
     *  All that is passed back is pErrMsg. Blank = Successful.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D uiwrec        E ds                  extname(uciwork) inz(*EXTDFT)
     D uprec         E ds                  extname(upc) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------

     D driItemCalled   s               n

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#ITEM
     D savever#        s                   like($itver#)

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
     d extendedMode    s             10    varying
     d aawhse          s              3  0
     d aapo            s              9
     d aaposeq         s              5  0
     d aaitem          s             15
     d aauci           s            100
     d aawgtlbs        s              7  2
     d aaexpdt         s              6  0
     d aamfgdt         s              6  0
     d gs1exp          s              6  0
     d gs1mfg          s              6  0

     D nextChar        s              7
     D nextNum         s              7  0
     D year            s              4  0
     D canitem         s             13  0
     D canitema        s             13
     D itemlen         s              2  0
     D dashpos         s              5p 0

     d wkupc           s             20
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

     D M29600          pr                  extpgm('M29600')
     D  pErrMsg                      99
     D  pSessId                      40
     D  pUser                        10
     D  pDict                        10
     D  pPgm                         10
     D  pObjLoc                      10
     D  pParmStr1                   999
     D  pParmStr2                   999
     D  pParmStr3                   999

     D M29600          pi
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
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D FromStamp       s               z
     D ToStamp         s               z
     D oldeststamp     s               z
     D ts              s               z

     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

     D bfcoffset       s              3  0 inz(0)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.cvtdte
      /copy qcopysrc,p.driitem

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d calcgtin        pr            18

     d ConvertField    pr
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

     d ExtractParms    pr

     d ExtractParmStr  pr
     d  parmStr                     999    varying

     d WrtBeforeDebug  pr
     d WrtAfterDebug   pr
     d WrtDebugError   pr


     D gs1ser#         pr                  extpgm('GS1SER#')
     D   unext                        7  0
     D   uwhse                        3  0 const

     *----------------------------------------------------------------
     *  CVTDTE constant and parameter data structure.
     *----------------------------------------------------------------

     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76

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

         if mode = 'A' and aawgtlbs = 0;
           pErrMsg = 'Weight must be entered';
         endif;
         // Get out if error

         if pErrMsg <> '';
           WrtDebugError();
           return;
         endif;

         // Do processing

         select;
           when mode = 'A';
             extendedMode = 'Add';
             exsr getcurrstamp;
             uiwsess = pSessId;
             uiwwhse = aawhse;
             uiwpo = aapo;
             uiwposeq = aaposeq;
             uiwitem = aaitem;

740aA        if uiwitem<>' ' and %Check(' 0123456789.-':uiwitem)<>0;
740aA          pErrMsg = 'Item# must be numeric for this process';
740aA          return;
740aA        endif;
             // create gtin
             uiwgtin = calcgtin();
             exsr getitem;
             exsr loadupc;
             // create uci
             gs1ser#(nextNum: uiwwhse);
             nextChar = %editc(nextNum:'X');
             uiwserial = %char(year) + 'X' + nextChar;
             uiwwgtlbs = aawgtlbs;
             uiwexpdt = aaexpdt;
             uiwmfgdt = aamfgdt;
             if uiwexpdt <> 0;
               $cvcmd = '*MDYYMD ';
               $cvd6i = %char(uiwexpdt);
               cvtdte ($cvtdt);
               gs1exp  = %int($cvd6o);
             endif;
             if uiwmfgdt <> 0;
               $cvcmd = '*MDYYMD ';
               $cvd6i = %char(uiwmfgdt);
               cvtdte ($cvtdt);
               gs1mfg  = %int($cvd6o);
             endif;
             uiwprint = ' ';
             uiwload = ' ';
             select;
               when gs1mfg <> 0;
740bD            //uiwuci = '01' + uiwgtin +
740bM            uiwuci = '98' + uiwgtin +
                          '11' + %trim(%editc(gs1mfg:'X')) +
                          '3202' + %trim(%editc(uiwwgtlbs:'X')) +
                          '21' + uiwserial;
               when gs1exp <> 0;
740bD            //uiwuci = '01' + uiwgtin +
740bM            uiwuci = '98' + uiwgtin +
                          '17' + %trim(%editc(gs1exp:'X')) +
                          '3202' + %trim(%editc(uiwwgtlbs:'X')) +
                          '21' + uiwserial;
               other;
740gD            //uiwuci = '01' + uiwgtin +
740gM            uiwuci = '98' + uiwgtin +
                          '3202' + %trim(%editc(uiwwgtlbs:'X')) +
                          '21' + uiwserial;
             endsl;
             exec sql insert into uciwork values(:uiwrec);
740aA        if ppgm  = 'GS122';
740aA          perrmsg = uiwuci;
740aA        endif;
           when mode = 'C' or mode = 'U';
             extendedMode = 'Update';
           when mode = 'D';
             extendedMode = 'Delete';
             exec sql delete from uciwork
                where uiwuci = :aauci;
           other;
             extendedMode = mode;
         endsl;

         //pErrMsg = 'Hello ' + pUser + ', '
                 //+ 'you are calling from ' + dpCombo + ' '
           //pErrmsg =  extendedMode + ' mode ';
                 //+ 'with warehouse ' + %char(aawhse);

         // Write out 'After' Debug info

         if debugAfter;
           debugLoc = 'A';
           wrtAfterDebug();
         endif;

         if driItemCalled;
           driItem('%CLOSE': $pprogram: $drireturn: $drimessage:
                    $dridata: $dridata2);
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
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

      /free
       begsr getCurrStamp;

         getmicrotime(currstampuc:currstampsys);
         currstamploc = currstampsys + %hours(bfcoffset);
         year = %subdt(currstampsys:*Y);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  GETITEM - Get Item.
     *
     *----------------------------------------------------------------
      /free
       begsr getitem;

         error = *off;

         savever# = $itver#;
         clear $item;
         clear $item2;
         $itver# = savever#;

         $itWhse = aawhse;
         $ititem = aaitem;
         $dridata = $item;
         $dridata2 = $item2;

         driItemCalled = *on;
         driItem('%GETALL ': $pprogram: $drireturn: $drimessage:
                  $dridata: $dridata2);
         $item = $dridata;
         $item2 = $dridata2;


       endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  LoadUPC - Load the UPC if needed
     *
     *----------------------------------------------------------------
      /free
       begsr LoadUPC;

         // does the upc exist
         wkupc = '      ' + uiwgtin;
         exec sql select * into :uprec
              from upc
              where upwhse = :aawhse
                and upupc = :wkupc
                and upitem = :aaitem
                and upuom  = :$itum1
              fetch first row only;
         if sqlstt <> sqlSuccess;
           upwhse = aawhse;
           upitem = aaitem;
           upupc = wkupc;
           upven = 0;
           upvnam = ' ';
           upvitm = ' ';
           upbran = ' ';
           upuom = $itum1;
           uputyp = 'N';
           upctyp = '3';
           exec sql insert into upc values(:uprec);
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

           when parmName = 'MODE';
             mode = %xlate(xlower: xupper: parmValue);

           when parmName = 'UIWWHSE';
             if parmValue = '';
               parmValue = '0';
             endif;
             aawhse =  %dec(parmValue: 3: 0);

           when parmName = 'UIWPO';
             aapo = %xlate(xlower: xupper: parmValue);

           when parmName = 'UIWPOSEQ';
             if parmValue = '';
               parmValue = '0';
             endif;
             aaposeq =  %dec(parmValue: 5: 0);

           when parmName = 'UIWITEM';
             aaitem = %xlate(xlower: xupper: parmValue);

           when parmName = 'UIWUCI';
             aauci = %xlate(xlower: xupper: parmValue);

           when parmName = 'UIWWGTLBS';
             if parmValue = '';
               parmValue = '0';
             endif;
             aawgtlbs =  %dec(parmValue: 7: 2);

           when parmName = 'UIWEXPDT';
             if parmValue = '';
               parmValue = '0';
             endif;
             aaexpdt =  %dec(parmValue: 6: 0);

           when parmName = 'UIWMFGDT';
             if parmValue = '';
               parmValue = '0';
             endif;
             aamfgdt =  %dec(parmValue: 6: 0);



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
     D parmName        s             10    varying
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

     *----------------------------------------------------------------
     *  calcgtin    Used to generate the check digit for the gtin
     *----------------------------------------------------------------

     p calcgtin        b
     d calcgtin        pi            18

     * Local Variables
     d  chkdgt         s              1  0
     d  digitsSum      s              5  0
     d  instring       s             14
     d  lp             s              2  0

      /free

         // Build 14 character string.  Position 14 is 0 since it will
         // be passed in a check digit calculated.

         // extract item without the - and whse
         dashpos = %scan('-': aaitem: 1);
         if dashpos = 0;
           canitem = %dec(aaitem:13:0);
         else;
           itemlen = dashpos -1;
           canitema = %subst(aaitem: 1: itemLen);
           canitem = %dec(canitema:13:0);
         endif;
         inString = %trim(inString) + %editc(canitem:'X') + '0';

         lp = 1;
         dow lp < 15;
           // for odd number digits multiply number by 3 nd add to sum
           digitsSum = digitsSum + (%dec(%subst(inString:lp:1):1:0))*3;
           lp = lp + 1;
           // for even number digits simply add digit to sum
           digitsSum = digitsSum + %dec(%subst(inString:lp:1):1:0);
           lp = lp +1;
         enddo;
730aA    if %rem(digitsSum:10) = 0;
730aA      chkDgt = 0;
730aA    else;
730aD      //chkDgt = %rem((10-%rem(digitsSum:10)-1):9)+1;
730aM      chkDgt = 10-%rem(digitsSum:10);
730aA    endif;
         inString = %subst(inString:1:13) + %char(chkDgt);

         return inString;

      /end-free

     p calcgtin        e

