      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)

     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  WWTFR    Warehouse to warehouse transfer
     *  08 May 2020
     *  Dave Sommerville
     *
     *  Revisions:
     *
740 A*    05/08/20  DAS  7.40
     *      - Created.
     *
750aA*    11/17/21  LMC  7.50a
     *      - Revised to not log error when copying licinfo if it
     *        already exists, multiple transfer from same original
     *        license cause sqlstt = 23505 error. Do not consider
     *        this an error. 23505 = sqlDupRecd
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D gwwrec        E ds                  extname(glowwtfr) inz(*EXTDFT)
     D larec         E ds                  extname(licactive) inz(*EXTDFT)
     D lnrec         E ds                  extname(licinfo) inz(*EXTDFT)
     D uirec         E ds                  extname(uciinfo) inz(*EXTDFT)
     D uiarec        E ds                  extname(uciinfoexa) inz(*EXTDFT)
     D itrec         E ds                  extname(piritem) inz(*EXTDFT)
     D slrec         E ds                  extname(slot) inz(*EXTDFT)
     D bdrec         E ds                  extname(bfcdebug) inz(*EXTDFT)
     D bdfrec        E ds                  extname(bfcdbgflg) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT
     D saveVer#        s                   like($slver#)
     D bfr$Slot        ds                  likeds($slot)
     D bfr$Slot2       ds                  likeds($slot2)

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
     *  Tracking variables
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,c#trackvar

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d errMsg          s             99    varying
     D chk4err         s               n
     D zmsflag         s               n
     D wrtDebug        s               n
     d debugMsg        s           1024    varying
     D inError         s              5  0
     D inSuccess       s              5  0
     D outError        s              5  0
     D outSuccess      s              5  0
     D copyError       s              5  0
     D itemError       s              5  0
     D qcmdexcCmd      s           3000    varying
     D toWhse          s                   like(pWhse)

     d dbgflgExists    s               n
     d debug           s               n
     d debugAfter      s               n
     d debugBefore     s               n
     d debugLoc        s              1

     D e$whse          s              3  0
     D e$emp#          s              5  0
     D e$fnam          s             15
     D e$init          s              1
     D e$lnam          s             20
     D e$whdp          s              5
     D e$styp          s              1
     D e$shft          s              6
     D e$crew          s              6
     D e$nhrs          s              3  1
     D e$rtn           s              8
     D e$bpu           s              1
     D e$lng           s              2

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pCmd        *CHKTFR - See if aisle/loc is in GLOWWTFR. Return *YES/*NO
     *                  *MOVEALL - Move aisle/loc licenses from FROM whse to TO whse
     *                  *TFRIN - Sent after item is transferred into slot
     *                  *TFROUT - Sent after item is transferred out of slot
     *                  *RESETOPEN - Try resetting status to Open
     *                  *VFYTFRIN - Sent during transfer in checks
     *      pAisle      Slot Aisle
     *      pLoc        Slot Location
     *
     *    Returned Parameters
     *      pRtnCode    Return code
     *      pRtnMsg     Return message
     *
     *----------------------------------------------------------------

     D WWTFR           pr                  extpgm('WWTFR')
     D  pCmd                         10    CONST
     D  pAisle                        3
     D  pLoc                          3s 0
     D  pWhse                         3s 0
     D  pUser                        10
     D  pRtnCode                     10
     D  pRtnMsg                      99    VARYING

     D WWTFR           pi
     D  pCmd                         10    CONST
     D  pAisle                        3
     D  pLoc                          3s 0
     D  pWhse                         3s 0
     D  pUser                        10
     D  pRtnCode                     10
     D  pRtnMsg                      99    VARYING

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.cvttext
      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.bfclibl
      /copy qcopysrc,p.qcmdexc
      /copy qcopysrc,p.getuser

     D ucilic#         pr                  extpgm('UCILIC#')
     D   unext                       13  0
     D   uwhse                        3  0 const

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d AdjustIn        pr

     d AdjustOut       pr

     d CheckTfr        pr

     d CopyLICINFO     pr
     d  lib                          10
     d  whse                          3s 0
     d  lcns                         15

     d CopyUCIINFO     pr
     d  lib                          10
     d  whse                          3s 0
     d  lcns                         15

     d CopyUCIINFOEXA  pr
     d  lib                          10
     d  whse                          3s 0
     d  addts                          z
     d  ucilcns                      15
     d  lcns                         15
     d  newaddts                       z
     d  newucilcns                   15

     d GetCurrStamp    pr

     d GetEnvironment  pr             1

     d GetFilesLib     pr            10

     d GetItem         pr
     d  whse                               like($itwhse)
     d  item                               like($ititem)

     d GetLibList      pr          2750    varying

     d GetWeight       pr             9  2
     d  whse                               like($slwhse)

     d MoveAll         pr

     d OpenStatus      pr

     d TfrIn           pr

     d TfrOut          pr

     d VerifyMoveAll   pr

     d VerifyTfrIn     pr

     d clr$item        pr

     d clr$slot        pr

     d zzzdricop       pr

     d WrtBeforeDebug  pr

     d WrtAfterDebug   pr

     d WrtDebugMsg     pr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;

         wrtDebug = *off;
         if %len(pRtnMsg) = 11 and %subst(pRtnMsg: 1: 5) = 'DEBUG';
           wrtDebug = *on;
           bdtype = %subst(pRtnMsg: 6: 6);
         endif;

         debug = *off;
         debugBefore = *off;
         debugAfter = *off;

         exec sql select *
                  into :bdfrec
                  from bfcdbgflg
                  where bdfpgm = :#pgm;

         if sqlstt = sqlSuccess;
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

         // Write out 'Before' Debug info

         if debugBefore;
           debugLoc = 'B';
           wrtBeforeDebug();
         endif;

         // Initialize return parms

         pRtnCode = '*OK';
         pRtnMsg ='';

         // Initialize user if necessary

         if pUser = '';
           pUser = #curruser;
         endif;
         getUser(pUser: e$whse: e$emp#: e$fnam: e$init: e$lnam:
                 e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                 e$bpu: e$lng);

         // Set To warehouse for readability

         toWhse = pWhse;

         // Process command

         select;

           // See if Slot is a WW Tfr slot
           // Called from Dakota transfer pgm

           when pCmd = '*CHKTFR';
             CheckTfr();

           // Move items from FROM whs to TO whse
           // Called from GUI WW Tfr Maint program

           when pCmd = '*MOVEALL';
             VerifyMoveAll();
             if pRtnCode = '*OK';
               MoveAll();
             endif;

           // Transferring item into a WW Tfr slot
           // Called from transfer program

           when pCmd = '*TFRIN';
             TfrIn();

           // Transferring item out of a WW Tfr slot
           // Called from transfer program

           when pCmd = '*TFROUT';
             TfrOut();

           // Attempt to set WW Tfr status to Open
           // Called from GUI WW Tfr Maint program

           when pCmd = '*RESETOPEN';
             OpenStatus();

           // Do Tfr In verifications

           when pCmd = '*VFYTFRIN';
             VerifyTfrIn();

         endsl;

         // Write out 'After' Debug info

         if debugAfter;
           debugLoc = 'A';
           wrtAfterDebug();
         endif;

         return;

      /end-free

     *----------------------------------------------------------------
     *  AdjustIn   Adjust into TO warehouse
     *----------------------------------------------------------------

     p AdjustIn        b
     d AdjustIn        pi

     * Local Variables

     D ind             s              2b 0

      /free

       inSuccess = 0;
       inError = 0;

       // Make sure adjustment code exists
       // Library list set to TO library list before call this routine

       exec sql insert into adjcode (adcode, addesc)
                  values('WW', 'Whse to Whse Transfer');


       exec sql insert into adjmisc (admcod, admsys)
                  values('WW', 'B');

       // Loop through FROM LICACTIVE for aisle/loc

       SqlStmt = 'select * '
               + 'from ' + %trim(gwwfromlib) + '/licactive '
               + 'where lawhse=' + %char(gwwfromwhs) + ' '
               +   'and laaisl=' + sq + pAisle + sq + ' '
               +   'and laloc=' + %char(pLoc);

       exec sql prepare adjinsel from :SqlStmt;
       exec sql declare adjincsr dynamic scroll cursor for adjinsel;
       exec sql open adjincsr;

       dow forever = forever;

         exec sql fetch next from adjincsr into :larec;

         if sqlstt <> sqlSuccess;
           leave;
         endif;

         // First we need to create the slot to use in the TO whse

         clr$slot();
         $slwhseu = *on;
         $slwhse  = toWhse;
         $slwhdpu = *on;
         $slwhdp  = lawhdp;
         $sldispu = *on;
         $sldisp = labase;
         $slstatu = *on;
         $slstat = 'A';

         $slentdu = *on;
         $slentd  = laentd;
         $slexpdu = *on;
         $slexpd  = laexpd;

         $saitemu = *on;
         $saitem  = laitem;
         $saqtyu = *on;
         $saqty1 = 0;
         $saqty2 = 0;
         $saqty3 = 0;
         $saAllowZrou = *on;
         $saAllowZero = 'Y';

         $saActionU = *on;
         $saAction = 'PUT';
         $sabyu = *on;
         $saby = pUser;

         //$saETrn#U = *on;
         //$saETrn# = 0;
         $saToLcnsU = *on;
         $saToLcns = lalcns;
         $saToVrfyU = *on;
         $saToVrfy = 'Y';
         $saToCodeu = *on;
         $saToCode = 'S';
         $saToAreaU = *on;
         $saToArea = 'Slot';
         $saOLcnsU = *on;
         $saOLcns = laolcns;

         $dricommand = '*SLOT';
         $drisubcmd  = '%QTY2PUT0';
         $drisys2upd = 'D';
         chk4err = *on;
         zmsflag = *off;
         zzzdricop();
         if error;
           error = *off;
           inError += 1;
           if wrtDebug;
             debugMsg = 'Error creatng slot '
                      + 'for item ' + %trim($saitem) + ' '
                      + 'license ' + %trim(lalcns) + ', '
                      + 'in whse ' + %char($slwhse) + ', '
                      + 'base slot ' + %trim($slwhdp) + ', '
                      + %trim($sldisp) + ', '
                      + 'Rtn: ' + %trim($drireturn) +', '
                      + 'Msg: ' + %trim(errmsg);
             WrtDebugMsg();
           endif;
           iter;
         endif;

         // Then we adjust the quantity into the slot

         $saActionU = *on;
         $saAction = 'ADJ';

         $saqtyu = *on;
         $saqty1 = laqty1;
         $saqty2 = laqty2;
         $saqty3 = laqty3;
         $saAllowZrou = *off;
         $saAllowZero = '';

         $sacwtau = *on;
         $sacwta = GetWeight($slwhse);
         $sacodeu = *on;
         $sacode = 'WW';
         $samemou = *on;
         $samemo = 'Whse-to-Whse Transfer';

         $dricommand = '*SLOT';
         $drisubcmd  = '%ADJUST';
         $drisys2upd = 'D';
         chk4err = *on;
         zmsflag = *off;
         zzzdricop();
         if error;
           error = *off;
           inError += 1;
           if wrtDebug;
             debugMsg = 'Error adjusting qty into '
                      + 'whse ' + %char($slwhse) + ', '
                      + 'slot ' + %trim($slwhdp) + ', '
                      + %trim($sldisp) + ', '
                      + 'license ' + %trim(lalcns) + ', '
                      + 'item ' + %trim($saitem) + ', '
                      + 'Rtn: ' + %trim($drireturn) +', '
                      + 'Msg: ' + %trim(errmsg);
             WrtDebugMsg();
           endif;
         else;
           inSuccess += 1;
         endif;

       enddo;

       exec sql close adjincsr;

       // Close DRISLOT

       clr$slot();
       $dricommand = '*SLOT';
       $drisubcmd  = '%CLOSE';
       $drisys2upd = 'D';
       chk4err = *off;
       zmsflag = *off;
       zzzdricop();

       // Close DRIITEM

       clr$slot();
       $dricommand = '*ITEM';
       $drisubcmd  = '%CLOSE';
       $drisys2upd = 'D';
       chk4err = *off;
       zmsflag = *off;
       zzzdricop();

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  AdjustOut  Adjust out of FROM warehouse
     *----------------------------------------------------------------

     p AdjustOut       b
     d AdjustOut       pi

     * Local Variables

     D ind             s              2b 0

      /free

       outSuccess = 0;
       outError = 0;

       // Make sure adjustment code exists
       // Library list set to FROM library list before call this routine

       exec sql insert into adjcode (adcode, addesc)
                  values('WW', 'Whse to Whse Transfer');


       exec sql insert into adjmisc (admcod, admsys)
                  values('WW', 'B');

       // Loop through FROM LICACTIVE for aisle/loc

       SqlStmt = 'select * '
               + 'from ' + %trim(gwwfromlib) + '/licactive '
               + 'where lawhse=' + %char(gwwfromwhs) + ' '
               +   'and laaisl=' + sq + pAisle + sq + ' '
               +   'and laloc=' + %char(pLoc);

       exec sql prepare adjoutsel from :SqlStmt;
       exec sql declare adjoutcsr dynamic scroll cursor for adjoutsel;
       exec sql open adjoutcsr;

       dow forever = forever;

         exec sql fetch next from adjoutcsr into :larec;

         if sqlstt <> sqlSuccess;
           leave;
         endif;

         // Adjust qty out of FROM slot

         clr$slot();
         $slwhseu = *on;
         $slwhse  = lawhse;
         $slwhdpu = *on;
         $slwhdp  = lawhdp;
         $sldispu = *on;
         $sldisp = ladisp;

         $saitemu = *on;
         $saitem  = laitem;
         $saqtyu = *on;
         $saqty1 = -(laqty1);
         $saqty2 = -(laqty2);
         $saqty3 = -(laqty3);

         $saActionU = *on;
         $saAction = 'ADJ';

         $sacwtau = *on;
         $sacwta = -(GetWeight($slwhse));
         $sacodeu = *on;
         $sacode = 'WW';
         $samemou = *on;
         $samemo = 'Whse-to-Whse Transfer';

         $dricommand = '*SLOT';
         $drisubcmd  = '%ADJUST';
         $drisys2upd = 'D';
         chk4err = *on;
         zmsflag = *off;
         zzzdricop();
         if error;
           error = *off;
           outError += 1;
           if wrtDebug;
             debugMsg = 'Error adjusting qty out of '
                      + 'whse ' + %char($slwhse) + ', '
                      + 'slot ' + %trim($slwhdp) + ', '
                      + %trim($sldisp) + ', '
                      + 'license ' + %trim(lalcns) + ', '
                      + 'item ' + %trim($saitem) + ', '
                      + 'Rtn: ' + %trim($drireturn) +', '
                      + 'Msg: ' + %trim(errmsg);
             WrtDebugMsg();
           endif;
         else;
           outSuccess += 1;
         endif;

       enddo;

       exec sql close adjoutcsr;

       // Close DRISLOT

       clr$slot();
       $dricommand = '*SLOT';
       $drisubcmd  = '%CLOSE';
       $drisys2upd = 'D';
       chk4err = *off;
       zmsflag = *off;
       zzzdricop();

       // Close DRIITEM

       clr$slot();
       $dricommand = '*ITEM';
       $drisubcmd  = '%CLOSE';
       $drisys2upd = 'D';
       chk4err = *off;
       zmsflag = *off;
       zzzdricop();

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  CheckTfr     Check if aisle/loc is in GLOWWTFR
     *----------------------------------------------------------------

     p CheckTfr        b
     d CheckTfr        pi

     * Local Variables

     D envCode         s              1
     D ind             s              2b 0

      /free

       // Get environment type

       envCode = GetEnvironment();

       // Lookup Aisle/Loc in global file

       exec sql select *
                into :gwwrec :ind
                from glowwtfr
                where gwwenv = :envCode
                  and gwwaisl = :pAisle
                  and gwwloc = :pLoc;

       if sqlstt <> sqlSuccess;
         pRtnCode = '*NO';
       else;
         pRtnCode = '*YES';
       endif;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  CopyLICINFO   Copy LICINFO record
     *----------------------------------------------------------------

     p CopyLICINFO     b
     d CopyLICINFO     pi
     d  lib                          10
     d  whse                          3s 0
     d  lcns                         15

     * Local Variables

     D ind             s              2b 0

      /free

       // Library list set to TO library list before call this routine

       // Loop through FROM LICINFO records for license

       SqlStmt = 'select * '
               + 'from ' + %trim(lib) + '/licinfo '
               + 'where lnwhse=' + %char(whse) + ' '
               +   'and lnlcns=' + sq + %trimr(lcns) + sq + ' ';

       exec sql prepare lnsel from :SqlStmt;
       exec sql declare lncsr dynamic scroll cursor for lnsel;
       exec sql open lncsr;

       dow forever = forever;

         exec sql fetch next from lncsr into :lnrec :ind;

         if sqlstt <> sqlSuccess;
           leave;
         endif;

         // Write record to TO LICINFO file

         lnwhse = toWhse;
         exec sql insert into licinfo values(:lnrec);

750aM    if sqlstt <> sqlSuccess
750aA       and sqlstt <> sqlDupRecd;
           copyError += 1;
           if wrtDebug;
             debugMsg = 'Error copying LICINFO '
                      + 'for license ' + %trim(lnlcns) + ', '
                      + 'item ' + %trim(lnitem) + ', '
                      + 'sqlstt: ' + %trim(sqlstt);
             WrtDebugMsg();
           endif;
         endif;

       enddo;

       exec sql close lncsr;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  CopyUCIINFO   Copy UCIINFO record
     *----------------------------------------------------------------

     p CopyUCIINFO     b
     d CopyUCIINFO     pi
     d  lib                          10
     d  whse                          3s 0
     d  lcns                         15

     * Local Variables

     D ind             s              2b 0
     D saveucilcns     s                   like(uiucilcns)
     D nextnum         s             13  0
     D nextchar        s             13

      /free

       // Library list set to TO library list before call this routine

       // Loop through FROM UCIINFO records for license

       SqlStmt = 'select * '
               + 'from ' + %trim(lib) + '/uciinfo '
               + 'where uiwhse=' + %char(whse) + ' '
               +   'and uilcns=' + sq + %trimr(lcns) + sq + ' ';

       exec sql prepare uisel from :SqlStmt;
       exec sql declare uicsr dynamic scroll cursor for uisel;
       exec sql open uicsr;

       dow forever = forever;

         exec sql fetch next from uicsr into :uirec :ind;

         if sqlstt <> sqlSuccess;
           leave;
         endif;

         // Update some fields before adding record

         saveucilcns = uiucilcns;

         uiwhse = toWhse;
         ucilic#(nextNum: uiwhse);
         nextChar = %editc(nextNum:'X');
         uiuciLcns = 'U:' + nextChar;

         GetCurrStamp();

         uiaddts = currstampsys;
         uiadduc = currstampuc;
         uiaddpgm = #pgm;
         uiaddemp = e$emp#;
         uiaddusr = #user;
         uiaddjob = #job;
         uiaddnbr = #jobnbr;

         uichgts = currstampsys;
         uichguc = currstampuc;
         uichgpgm = #pgm;
         uichgemp = e$emp#;
         uichgusr = #user;
         uichgjob = #job;
         uichgnbr = #jobnbr;

         // Write record to TO UCIINFO file

         exec sql insert into uciinfo values(:uirec);

         if sqlstt <> sqlSuccess;
           copyError += 1;
           if wrtDebug;
             debugMsg = 'Error copying UCIINFO '
                      + 'from uiucilcns ' + %trim(saveucilcns) + ' '
                      + 'to uiucilcns ' + %trim(uiucilcns) + ', '
                      + 'for license ' + %trim(uilcns) + ', '
                      + 'item ' + %trim(uiitem) + ', '
                      + 'sqlstt: ' + %trim(sqlstt);
             WrtDebugMsg();
           endif;
         endif;

         // Copy UCIINFOEXA records

         CopyUCIINFOEXA(lib: whse: uiaddts: saveucilcns: uilcns:
                        uiaddts: uiucilcns);

       enddo;

       exec sql close uicsr;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  CopyUCIINFOEXA   Copy UCIINFOEXA record
     *----------------------------------------------------------------

     p CopyUCIINFOEXA  b
     d CopyUCIINFOEXA  pi
     d  lib                          10
     d  whse                          3s 0
     d  addts                          z
     d  ucilcns                      15
     d  lcns                         15
     d  newaddts                       z
     d  newucilcns                   15

     * Local Variables

     D ind             s              2b 0

      /free

       // Library list set to TO library list before call this routine

       // Loop through FROM UCIINFOEXA records for UCI License

       SqlStmt = 'select * '
               + 'from ' + %trim(lib) + '/uciinfoexa '
               + 'where uiaaddts=' + %char(addts) + ' '
               +   'and uiaucilcns=' + sq + %trimr(ucilcns) + sq + ' '
               +   'and uialcns=' + sq + %trimr(lcns) + sq + ' ';

       exec sql prepare uiasel from :SqlStmt;
       exec sql declare uiacsr dynamic scroll cursor for uiasel;
       exec sql open uiacsr;

       dow forever = forever;

         exec sql fetch next from uiacsr into :uiarec :ind;

         if sqlstt <> sqlSuccess;
           leave;
         endif;

         // Update some fields before adding record

         uiaaddts = newaddts;
         uiuciLcns = newucilcns;

         // Write record to TO UCIINFOEXA file

         exec sql insert into uciinfoexa values(:uiarec);

         if sqlstt <> sqlSuccess;
           copyError += 1;
           if wrtDebug;
             debugMsg = 'Error copying UCIINFOEXA '
                      + 'from uiaucilcns ' + %trim(ucilcns) + ' '
                      + 'from uiaadts ' + %char(addts) + ' '
                      + 'to uiaucilcns ' + %trim(newucilcns) + ', '
                      + 'to uiaadts ' + %char(newaddts) + ' '
                      + 'for license ' + %trim(lcns) + ', '
                      + 'sqlstt: ' + %trim(sqlstt);
             WrtDebugMsg();
           endif;
         endif;

       enddo;

       exec sql close uiacsr;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetCurrStamp  Get current timestamps
     *----------------------------------------------------------------

     p GetCurrStamp    b
     d GetCurrStamp    pi

      /free
         getmicrotime(currstampuc:currstampsys);
      /end-free

     p GetCurrStamp    e

     *----------------------------------------------------------------
     *  GetEnvironment  Get Environment (P=Production, T=Test)
     *----------------------------------------------------------------

     p GetEnvironment  b
     d GetEnvironment  pi             1

     * Local Variables

     D envCode         s              1

     C                   call      'GETENV'
     C                   parm                    envCode

      /free

       return envCode;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetFilesLib     Get files library
     *----------------------------------------------------------------

     p GetFilesLib     b
     d GetFilesLib     pi            10

     * Local Variables

     D lib             s             10

     C                   call      'GETFILELIB'
     C                   parm                    lib

      /free

       return lib;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetItem    Get Item
     *----------------------------------------------------------------

     p GetItem         b
     d GetItem         pi
     d  whse                               like($itwhse)
     d  item                               like($ititem)

      /free

       clr$item();
       $itwhse  = whse;
       $ititem  = item;

       $dricommand = '*ITEM';
       $drisubcmd  = '%GETMAIN';
       $drisys2upd = 'D';
       chk4err = *on;
       zmsflag = *off;
       zzzdricop();
       if error;
         error = *off;
         $itcwgt = 'N';
         itemError += 1;
         if wrtDebug;
           debugMsg = 'Error getting item '
                    + %char($itwhse) + ', ' + %trim($ititem) + ', '
                    + 'Rtn: ' + %trim($drireturn) +', '
                    + 'Msg: ' + %trim(errmsg);
           WrtDebugMsg();
         endif;
       endif;

       if $imltrk <> tlow
         and $imltrk <> tmedium
         and $imltrk <> thigh
         and $imltrk <> tUCI;
           $imltrk = tLow;
       endif;

      /end-free
     p                 e

     *----------------------------------------------------------------
     *  GetLibList      Get library list
     *----------------------------------------------------------------

     p GetLibList      b
     d GetLibList      pi          2750    varying

     * Local Variables

     D libList         s           2750

     C                   call      'GETLIBL250'
     C                   parm                    liblist

      /free

       return %trim(liblist);

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetWeight     Get weight
     *----------------------------------------------------------------

     p GetWeight       b
     d GetWeight       pi             9  2
     d  whse                               like($slwhse)

     * Local Variables

     D wgt             s              9  2

      /free

       // The 'la' fields will always be FROM information

       // The warehouse being passed in will be
       //    the TO whse when called from AdjustIn
       //    the FROM whse when call from AdjustOut

       // The library list will be
       //    the TO list when called from AdjustIn
       //    the FROM list when called from AdjustOut

       // Get item info using sent in whse

       GetItem(whse: laitem);

       // If not a catchweight item, return 0

       if $itcwgt <> 'Y';
         return 0;
       endif;

       // If not UCI tracked, return calculated weight

       if $imltrk <> tUCI;

         wgt = laqty1 * $itswgt;

         if laqty2 > 0 and $itumq2 > 0;
           wgt += laqty2 * ($itswgt/$itumq2);
         endif;

         if laqty3 > 0 and $itumq2 > 0 and $itumq3 > 0;
           wgt += laqty3 * ($itswgt/($itumq2*$itumq3));
         endif;

         return wgt;

       endif;

       // Otherwise, calculate weight from UCIINFO
       // CopyUCIInfo has already been done, so we can use library list

       exec sql select sum(uiwgtlbs)
                  into :wgt
                from uciinfo
                where uiwhse = :whse
                  and uilcns = :lalcns;

       if sqlstt <> sqlSuccess;
         wgt = 0;
       endif;

       return wgt;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  MoveAll    Move all licenses for aisle/loc
     *----------------------------------------------------------------

     p MoveAll         b
     d MoveAll         pi

     * Local Variables

     D envCode         s              1
     D ind             s              2b 0
     D toFilesLib      s             10
     D count           s              5  0
     D rtnFlag         s               n
     D tempLibl        s           2750    varying

     D                 DS
     D toLibl                      2750
     D  toLiblAry                    11    DIM(250) OVERLAY(toLibl)
     D fromLibl                    2750
     D  fromLiblAry                  11    DIM(250) OVERLAY(fromLibl)

      /free

       // This is only called when signed into TO whse.
       // Therefore the library is the TO list at this time

       envCode = GetEnvironment();
       toFilesLib = GetFilesLib();
       toLibl = GetLibList();

       // Lookup Aisle/Loc in global file

       exec sql select *
                into :gwwrec :ind
                from glowwtfr
                where gwwenv = :envCode
                  and gwwaisl = :pAisle
                  and gwwloc = :pLoc;

       // Error if aisle/loc doesn't exist

       if sqlstt <> sqlSuccess;
         pRtnCode = '*ERROR';
         pRtnMsg = 'Error: Transfer definition for aisle/loc ('
                 + paisle + '/' + %char(pLoc) + ') '
                 + 'does not exist';
         return;
       endif;

       // Update GLOWWTFR rec to Processing

       GetCurrStamp();

        exec sql update glowwtfr
                 set gwwstat = '4',
                     gwwtowhs = :toWhse,
                     gwwtolib = :toFilesLib,
                     gwwststs = :currstampsys,
                     gwwstsuc = :currstampuc,
                     gwwcurusr = :#curruser,
                     gwwjobusr = :#user,
                     gwwjob = :#job,
                     gwwjobnbr = :#jobnbr
                 where gwwenv = :envCode
                   and gwwaisl = :pAisle
                   and gwwloc = :pLoc;

       // Loop through FROM LICACTIVE for aisle/loc

       SqlStmt = 'select * '
               + 'from ' + %trim(gwwfromlib) + '/licactive '
               + 'where lawhse=' + %char(gwwfromwhs) + ' '
               +   'and laaisl=' + sq + pAisle + sq + ' '
               +   'and laloc=' + %char(pLoc);

       exec sql prepare lasel from :SqlStmt;
       exec sql declare lacsr dynamic scroll cursor for lasel;
       exec sql open lacsr;

       dow forever = forever;

         exec sql fetch next from lacsr into :larec;

         if sqlstt <> sqlSuccess;
           leave;
         endif;

         // Copy LICINFO

         if laolcns <> '';
           CopyLICINFO(gwwfromlib: gwwfromwhs: laolcns);
         endif;

         if lalcns <> laolcns;
           CopyLICINFO(gwwfromlib: gwwfromwhs: lalcns);
         endif;

         // Copy UCIINFO

         CopyUCIINFO(gwwfromlib: gwwfromwhs: lalcns);

       enddo;

       exec sql close lacsr;

       // Adjust into TO warehouse
       // Library list is the TO list at this time

       AdjustIn();

       // Call RCLRSC to close files left open

       qcmdexcCmd = 'RCLRSC LVL(*CALLER)';
       monitor;
         qcmdexc(%trim(qcmdexcCmd): %len(%trim(qcmdexcCmd)));
       on-error;
       endmon;

       // Adjust out of FROM warehouse

       // Change library list to FROM list before proceeding

       fromLibl = gwwfrmlibl;
       rtnFlag = SetLibL(fromLiblAry: llUsrLibl);
       tempLibl = GetLibList();
       if tempLibl <> gwwfrmlibl;
         debugMsg = 'Error setting FROM library list. '
                  + 'No Out Adj done. '
                  + 'Successful In Adj: ' + %char(inSuccess) + ', '
                  + 'Unsuccessful In Adj: ' + %char(inError) + ', '
                  + 'Copy errors: ' + %char(copyError) + ', '
                  + 'Item errors: ' + %char(itemError);
         WrtDebugMsg();
         debugMsg = 'gwwfrmlibl: ' + gwwfrmlibl;
         WrtDebugMsg();
         debugMsg = 'templibl: ' + tempLibl;
         WrtDebugMsg();
         pRtnCode = '*ERRORLOG';
         pRtnMsg = 'Error setting FROM library list. '
                 + 'No Out Adj done. See BFCDEBUG messages for more detail.';
         return;
       endif;

       AdjustOut();

       // Call RCLRSC to close files left open

       qcmdexcCmd = 'RCLRSC LVL(*CALLER)';
       monitor;
         qcmdexc(%trim(qcmdexcCmd): %len(%trim(qcmdexcCmd)));
       on-error;
       endmon;

       // Restore original TO library list

       rtnFlag = SetLibL(toLiblAry: llUsrLibl);
       tempLibl = GetLibList();

       if inError > 0 or outError > 0 or copyError > 0 or itemError > 0;
         debugMsg = 'Move completed with erors. '
                  + 'Successful In Adj: ' + %char(inSuccess) + ', '
                  + 'Unsuccessful In Adj: ' + %char(inError) + ', '
                  + 'Successful Out Adj: ' + %char(outSuccess) + ', '
                  + 'Unsuccessful Out Adj: ' + %char(outError) + ', '
                  + 'Copy errors: ' + %char(copyError) + ', '
                  + 'Item errors: ' + %char(itemError);
         WrtDebugMsg();
         pRtnCode = '*ERRORLOG';
         pRtnMsg = 'Move completed with erors. '
                 + 'See BFCDEBUG messages for more details. ';

         GetCurrStamp();
         exec sql update glowwtfr
                set gwwstat = 'E',
                    gwwststs = :currstampsys,
                    gwwstsuc = :currstampuc,
                    gwwcurusr = :#curruser,
                    gwwjobusr = :#user,
                    gwwjob = :#job,
                    gwwjobnbr = :#jobnbr
                where gwwenv = :envCode
                  and gwwaisl = :pAisle
                  and gwwloc = :pLoc;

         if sqlstt <> sqlSuccess;
           debugMsg = 'Error updating GLOWWTFR status to E. '
                    + 'SQTSTT = ' + sqlstt;
           WrtDebugMsg();
         endif;

       else;
         pRtnCode = '*OK';
         pRtnMsg = 'Move completed successfully. '
                 + 'Successful In Adj: ' + %char(inSuccess) + ', '
                 + 'Successful Out Adj: ' + %char(outSuccess);

         GetCurrStamp();
         exec sql update glowwtfr
                set gwwstat = '1',
                    gwwfromlib = '',
                    gwwfromwhs = 0,
                    gwwfrmlibl = '',
                    gwwtowhs = 0,
                    gwwtolib = '',
                    gwwststs = :currstampsys,
                    gwwstsuc = :currstampuc,
                    gwwcurusr = :#curruser,
                    gwwjobusr = :#user,
                    gwwjob = :#job,
                    gwwjobnbr = :#jobnbr
                where gwwenv = :envCode
                  and gwwaisl = :pAisle
                  and gwwloc = :pLoc;

         if sqlstt <> sqlSuccess;
           debugMsg = 'Error updating GLOWWTFR status to 1. '
                    + 'SQTSTT = ' + sqlstt;
           WrtDebugMsg();
         endif;

       endif;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  OpenStatus   Try to set status to Open
     *
     *    This will set the status to Open if no items exist in the
     *    FROM warehouse aisle/loc.
     *
     *----------------------------------------------------------------

     p OpenStatus      b
     d OpenStatus      pi

     * Local Variables

     D count           s              5p 0
     D countInd        s              2b 0
     D envCode         s              1

      /free

       // Get environment type

       envCode = GetEnvironment();

       // Lookup Aisle/Loc in global file

       exec sql select *
                into :gwwrec :countInd
                from glowwtfr
                where gwwenv = :envCode
                  and gwwaisl = :pAisle
                  and gwwloc = :pLoc;

       // Get out if no global tfr rec found

       if sqlstt <> sqlSuccess;
         pRtnCode = '*ERROR';
         pRtnMsg = 'Error ('+sqlstt+'): Transfer definition for aisle/loc ('
                 + paisle + '/' + %char(pLoc) + ') '
                 + 'does not exist';
         return;
       endif;

       // Check if already at Open status

       if gwwstat = '1';
         pRtnCode = '*ERROR';
         pRtnMsg = 'Already at Open status';
         return;
       endif;

       // Lookup Aisle/Loc in Slot file

       sqlStmt = 'select count(*) '
               + 'from ' + %trim(gwwfromlib) + '/slot '
               + 'where slwhse=' + %char(gwwfromwhs) + ' '
               +   'and slaisl=' + sq + pAisle + sq + ' '
               +   'and slloc=' + %char(pLoc) + ' '
               +   'and slstat=' + sq + 'A' + sq;

       exec sql prepare opnsel from :SqlStmt;
       exec sql declare opncsr dynamic scroll cursor for opnsel;
       exec sql open opncsr;
       exec sql fetch next from opncsr into :count :countind;
       exec sql close opncsr;

       // If error, we will leave global rec alone

       if sqlstt <> sqlSuccess;
         pRtnCode = '*ERROR';
         pRtnMsg = 'Error ('+sqlstt+') retrieving slot count for Transfer FROM '
                 + 'aisle/loc (' + paisle + '/' + %char(pLoc) + ') ';
         debugMsg = sqlstmt;
         WrtDebugMsg();
         return;
       endif;

       // If tfr slots exist, leave global rec alone

       if count > 0;
         pRtnCode = '*ERROR';
         pRtnMsg = %char(count) + ' transfer slots still exist '
                 + 'in FROM warehouse for '
                 + 'aisle/loc (' + paisle + '/' + %char(pLoc) + ') ';
         return;
       endif;

       // Otherwise, set to open

       GetCurrStamp();

       exec sql update glowwtfr
                set gwwstat = '1',
                    gwwfromwhs = 0,
                    gwwfromlib = '',
                    gwwfrmlibl = '',
                    gwwtowhs = 0,
                    gwwtolib = '',
                    gwwststs = :currstampsys,
                    gwwstsuc = :currstampuc,
                    gwwcurusr = :#curruser,
                    gwwjobusr = :#user,
                    gwwjob = :#job,
                    gwwjobnbr = :#jobnbr
                where gwwenv = :envCode
                  and gwwaisl = :pAisle
                  and gwwloc = :pLoc;

       if sqlstt <> sqlSuccess;
         pRtnCode = '*ERROR';
         pRtnMsg = 'Error updating GLOWWTFR status to 1. '
                 + 'SQTSTT = ' + sqlstt;
       else;
         pRtnCode = '*OK';
         pRtnMsg = 'Status reset to Open';
       endif;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  TfrIn     Update status from Open to Loading
     *
     *    The *TFRIN command is sent after the transfer program has
     *    put the item into the slot. Therefore, it is assumeed that
     *    the transfer program has already sent *VFYTFRIN.
     *
     *    In the unlikely event the status is not Open, we will not
     *    update the record.
     *
     *----------------------------------------------------------------

     p TfrIn           b
     d TfrIn           pi

     * Local Variables

     D envCode         s              1

      /free

       // Get environment type

       envCode = GetEnvironment();

       // Lookup Aisle/Loc in global file

       SqlStmt = 'select * '
               + 'from glowwtfr '
               + 'where gwwenv=' + sq + envCode + sq  + ' '
               +   'and gwwaisl=' + sq + pAisle + sq + ' '
               +   'and gwwloc='+ %char(pLoc) + ' '
               + 'for update of gwwstat,gwwfromwhs,gwwfromlib,gwwfrmlibl,'
               +      'gwwststs,gwwstsuc,gwwcurusr,gwwjobusr,gwwjob,gwwjobnbr';

        exec sql prepare updinsel from :SqlStmt;
        exec sql declare updincsr dynamic scroll cursor for updinsel;
        exec sql open updincsr;

        dow forever = forever;

          exec sql fetch next from updincsr
                   into :gwwrec;

          // If error, assume doesn't exist, so get out.

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          // Get out if status not Open

          if gwwstat <> '1';
            leave;
          endif;

          // Set to In-Use

          gwwfromlib = GetFilesLib();
          gwwfrmlibl = GetLibList();

          GetCurrStamp();

          exec sql update glowwtfr set
                     gwwstat    = '2',
                     gwwfromwhs = :pWhse,
                     gwwfromlib = :gwwfromlib,
                     gwwfrmlibl = :gwwfrmlibl,
                     gwwststs   = :currstampsys,
                     gwwstsuc   = :currstampuc,
                     gwwcurusr  = :#curruser,
                     gwwjobusr  = :#user,
                     gwwjob     = :#job,
                     gwwjobnbr  = :#jobnbr
                   where current of updincsr;

          if sqlstt <> sqlSuccess;
            debugMsg = 'Error updating GLOWWTFR status to 2. '
                     + 'SQTSTT = ' + sqlstt;
            WrtDebugMsg();
          endif;

          leave;

        enddo;

        exec sql close updincsr;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  TfrOut    Do TFROUT checks
     *
     *    The *TFROUT command is sent after the transfer program has
     *    removed an item from a slot. If item is removed from a
     *    transfer aisle/loc, check if any more items exist in the
     *    transfer aisle/loc. If not, set status to Open.
     *
     *----------------------------------------------------------------

     p TfrOut          b
     d TfrOut          pi

     * Local Variables

     D count           s              5p 0
     D countInd        s              2b 0
     D envCode         s              1

      /free

       // Get environment type

       envCode = GetEnvironment();

       // Lookup Aisle/Loc in global file

       exec sql select count(*)
                into :count :countInd
                from glowwtfr
                where gwwenv = :envCode
                  and gwwaisl = :pAisle
                  and gwwloc = :pLoc;

       // Get out if no global tfr rec found

       if sqlstt <> sqlSuccess or count = 0;
         return;
       endif;

       // Lookup Aisle/Loc in Slot file

       exec sql select count(*)
                into :count :countInd
                from slot
                where slwhse = :pWhse
                  and slaisl = :pAisle
                  and slloc = :pLoc
                  and slstat = 'A';

       // If error, we will leave global rec alone

       if sqlstt <> sqlSuccess;
        return;
       endif;

       // If tfr slots exist, leave global rec alone

       if count > 0;
         return;
       endif;

       // Otherwise, set to open

       GetCurrStamp();

       exec sql update glowwtfr
                set gwwstat = '1',
                    gwwfromwhs = 0,
                    gwwfromlib = '',
                    gwwfrmlibl = '',
                    gwwtowhs = 0,
                    gwwtolib = '',
                    gwwststs = :currstampsys,
                    gwwstsuc = :currstampuc,
                    gwwcurusr = :#curruser,
                    gwwjobusr = :#user,
                    gwwjob = :#job,
                    gwwjobnbr = :#jobnbr
                where gwwenv = :envCode
                  and gwwaisl = :pAisle
                  and gwwloc = :pLoc;

       if sqlstt <> sqlSuccess;
         debugMsg = 'Error updating GLOWWTFR status to 1. '
                  + 'SQTSTT = ' + sqlstt;
         WrtDebugMsg();
       endif;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  VerifyMoveAll    Move all licenses for aisle/loc
     *----------------------------------------------------------------

     p VerifyMoveAll   b
     d VerifyMoveAll   pi

     * Local Variables

     D envCode         s              1
     D ind             s              2b 0
     D itind           s              2b 0
     D slind           s              2b 0
     D toFilesLib      s             10
     D count           s              5  0

      /free

       // Get environment type

       envCode = GetEnvironment();

       // Lookup Aisle/Loc in global file

       exec sql select *
                into :gwwrec :ind
                from glowwtfr
                where gwwenv = :envCode
                  and gwwaisl = :pAisle
                  and gwwloc = :pLoc;

       // Error if aisle/loc doesn't exist

       if sqlstt <> sqlSuccess;
         pRtnCode = '*ERROR';
         pRtnMsg = 'Error: Transfer definition for aisle/loc ('
                 + paisle + '/' + %char(pLoc) + ') '
                 + 'does not exist';
         if debug;
           debugMsg = pRtnMsg;
           WrtDebugMsg();
         endif;
         return;
       endif;

       // Error if status is not In-Use

       if gwwstat <> '2';
         pRtnCode = '*ERROR';
         pRtnMsg = 'Error: Status is not In-Use (' + gwwstat + ')';
         return;
       endif;

       // FROM/TO warehouse and library cannot be same

       toFilesLib = GetFilesLib();

       if debug;
         debugMsg = 'env=' + envCode + ', '
                  + 'fromWhse=' +  %char(gwwfromwhs) + ', '
                  + 'fromLib=' +  %trim(gwwfromlib) + ', '
                  + 'toWhse=' +  %char(toWhse) + ', '
                  + 'tolib=' + toFilesLib;
         WrtDebugMsg();
       endif;

       if gwwfromwhs = toWhse and gwwfromlib = toFilesLib;
         pRtnCode = '*ERROR';
         pRtnMsg = 'Error: CheckIn whse cannot be same as originating whse '
                 + '(' + %char(toWhse) + '/' + %trim(toFilesLib) + ' - '
                 + %char(gwwfromwhs) + '/' + %trim(gwwfromlib) + ')';
         if debug;
           debugMsg = pRtnMsg;
           WrtDebugMsg();
         endif;
         return;
       endif;

       // Lookup Aisle/Loc in FROM Slot file

       SqlStmt = 'select count(*) '
               + 'from ' + %trim(gwwfromlib) + '/slot '
               + 'where slwhse=' + %char(gwwfromwhs) + ' '
               +   'and slaisl=' + sq + pAisle + sq + ' '
               +   'and slloc=' + %char(pLoc) + ' '
               +   'and slstat=' + sq + 'A' + sq;

        exec sql prepare sql1sel from :SqlStmt;
        exec sql declare sql1csr dynamic scroll cursor for sql1sel;
        exec sql open sql1csr;

        exec sql fetch next from sql1csr
                 into :count;

       // Error if no slots exist in FROM warehouse

       if sqlstt <> sqlSuccess or count = 0;
         pRtnCode = '*ERROR';
         pRtnMsg = 'Error: Tfr slots for '
                 + paisle + '-' + %char(pLoc) + ' '
                 + 'not found in FROM whse ' + %char(gwwfromwhs);
         if debug;
           debugMsg = pRtnMsg;
           WrtDebugMsg();
         endif;
         exec sql close sql1csr;
         return;
       endif;

       exec sql close sql1csr;

       // Loop through FROM LICACTIVE for aisle/loc
       // Make sure all items and base slots exist in TO warehouse

       SqlStmt = 'select lawhdp, labase, laitem, ititem, sldisp '
               + 'from ' + %trim(gwwfromlib) + '/licactive '
               + 'left outer join ' + %trim(toFilesLib) + '/piritem '
               +   'on itwhse=' + %char(toWhse) + ' and ititem=laitem '
               + 'left outer join ' + %trim(toFilesLib) + '/slot '
               +   'on slwhse=' + %char(toWhse) + ' '
               +      'and slwhdp=lawhdp and sldisp=labase '
               + 'where lawhse=' + %char(gwwfromwhs) + ' '
               +   'and laaisl=' + sq + pAisle + sq + ' '
               +   'and laloc=' + %char(pLoc);

       exec sql prepare sql2sel from :SqlStmt;
       exec sql declare sql2csr dynamic scroll cursor for sql2sel;
       exec sql open sql2csr;

       dow forever = forever;

         exec sql fetch next from sql2csr into :lawhdp, :labase, :laitem,
                                               :ititem :itind, :sldisp :slind;

         if sqlstt <> sqlSuccess;
           leave;
         endif;

         // Make sure item exists in To warehouse

         if itind <> 0;
           pRtnCode = '*ERROR';
           pRtnMsg = 'Error: Tfr item '
                   + %trim(laitem) + ' '
                   + 'not found in TO whse ' + %char(toWhse) + ', '
                   + toFilesLib;
           if debug;
             debugMsg = pRtnMsg;
             WrtDebugMsg();
           endif;
           leave;
         endif;

         // Make sure base slot exists in To warehouse

         if slind <> 0;
           pRtnCode = '*ERROR';
           pRtnMsg = 'Error: Tfr slot '
                   + %trim(lawhdp) + '/' + %trim(labase) + ' '
                   + 'not found in TO whse ' + %char(toWhse) + ', '
                   + toFilesLib;
           if debug;
             debugMsg = pRtnMsg;
             WrtDebugMsg();
           endif;
           leave;
         endif;

       enddo;

       exec sql close sql2csr;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  VerifyTfrIn    Verify a transfer into a Tfr slot
     *----------------------------------------------------------------

     p VerifyTfrIn     b
     d VerifyTfrIn     pi

     * Local Variables

     D envCode         s              1
     D fileLib         s             10
     D ind             s              2b 0

      /free

       // Get environment type

       envCode = GetEnvironment();

       // Lookup Aisle/Loc in global file

       exec sql select *
                into :gwwrec :ind
                from glowwtfr
                where gwwenv = :envCode
                  and gwwaisl = :pAisle
                  and gwwloc = :pLoc;

       // If error, assume doesn't exist, so get out.

       if sqlstt <> sqlSuccess;
         return;
       endif;

       // If status is Open, slot can be used, so leave.

       if gwwstat = '1';
         return;
       endif;

       // Error if status is In-Transit

       if gwwstat = '3';
         pRtnCode = '*ERROR';
         pRtnMsg = 'Cannot use ' + %trim(pAisle) + '-' + %char(pLoc)
                 + ' - Status is In-Transit';
         return;
       endif;

       // Error if status is Processing

       if gwwstat = '4';
         pRtnCode = '*ERROR';
         pRtnMsg = 'Cannot use ' + %trim(pAisle) + '-' + %char(pLoc)
                 + ' - Status is Processing';
         return;
       endif;

       // Get file library

       fileLib = GetFilesLib();

       // Error if status is In-Use but file lib doesn't match

       if gwwstat = '2' and gwwfromlib <> fileLib;
         pRtnCode = '*ERROR';
         pRtnMsg = 'Cannot use ' + %trim(pAisle) + '-' + %char(pLoc)
                  + ' - In-Use at diff whse';
         return;
       endif;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     p clr$item        b
     d clr$item        pi

     C                   eval      savever# = $slver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = e$emp#

     p                 e

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     p clr$slot        b
     d clr$slot        pi

     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = e$emp#

     p                 e

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     p zzzdricop       b
     d zzzdricop       pi

     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   endsl

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2

     C                   select

     C                   when      chk4err and %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C                   eval      errmsg = $drimessage

     C                   endsl

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off

     p                 e

     *----------------------------------------------------------------
     *  wrtBeforeDebug  Write out 'Before' debug info
     *----------------------------------------------------------------

     p WrtBeforeDebug  b
     d WrtBeforeDebug  pi

     * Local Variables

     D saveType        s                   like(bdtype)

      /free

         saveType = bdtype;

         bdtype = 'PARMS';

         bdvalues = 'pCmd: ' + %trimr(pCmd) + ', '
                  + 'pAisle: ' + %trim(pAisle) + ', '
                  + 'pLoc: ' + %char(pLoc) + ', '
                  + 'pWhse: ' + %char(pWhse) + ', '
                  + 'pUser: ' + %trim(pUser) + ', '
                  + 'pRtnCode: ' + %trim(pRtnCode) + ', '
                  + 'pRtnMsg: ' + %trim(pRtnMsg);

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         exec sql insert into bfcdebug values(:bdrec);

         bdtype = saveType;

         return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  wrtAfterDebug  Write out 'After' debug info
     *----------------------------------------------------------------

     p WrtAfterDebug   b
     d WrtAfterDebug   pi

     * Local Variables

     D saveType        s                   like(bdtype)

      /free

         saveType = bdtype;

         bdtype = 'PARMS';

         bdvalues = 'pCmd: ' + %trimr(pCmd) + ', '
                  + 'pAisle: ' + %trim(pAisle) + ', '
                  + 'pLoc: ' + %char(pLoc) + ', '
                  + 'pWhse: ' + %char(pWhse) + ', '
                  + 'pUser: ' + %trim(pUser) + ', '
                  + 'pRtnCode: ' + %trim(pRtnCode) + ', '
                  + 'pRtnMsg: ' + %trim(pRtnMsg);

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         exec sql insert into bfcdebug values(:bdrec);

         bdtype = saveType;

         return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  wrtDebugMsg    Write out debug message
     *----------------------------------------------------------------

     p WrtDebugMsg     b
     d WrtDebugMsg     pi

      /free

         bdvalues = debugMsg;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = pUser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         exec sql insert into bfcdebug values(:bdrec);

         return;

      /end-free

     p                 e

