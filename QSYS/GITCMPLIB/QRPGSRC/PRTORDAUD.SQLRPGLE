      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  PRTORDAUD   Print audited orders
     *  19 January 2019
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
730 A*    01/19/19  DAS  7.30
     *      - Created
     *
730aA*    03/27/19  DAS  7.30a
     *      - Fix: Added space between program name and '(' in
     *        the submit command.
730bA*    04/01/19  MLB  7.30b
     *      - Fix: Revised pgm to submit cmd, PRTORDAUD to batch instead
     *        submitting call to PRTORDAUD using hex values for whse
     *        and ordid.  Was causing data decimal errors.
     *        Note: This mod requires QCMDSRC/PRTORDAUD to be installed
     *              with update.
730cA*    04/13/19  DAS  7.30c
     *      - Added debug logic
730dA*    04/13/19  DAS  7.30d
     *      - Added test mode that allows printing any order.
     *      - Added OHSTOP and RHPBAT to url
730eA*    06/12/19  KDE  7.30e
     *      - Added debug stmts to determine why not printing Audit Report
     *      - Added INLLIBL to PRTORDAUD submit to use JOBD library list.
     *        It was using library list from voice which was missing BFCGLOBALF
     *        and that is where MRCRPTRCFG for Report Scheduling exist
     *      - Get PRTORDAUD submit user and jobd from Report Scheduling options
730fA*    07/22/19  KDE  7.30f
     *      - Changed *MRCRPT options record with latest update
740 A*    06/02/20  KDE  7.40
     *      - Changed to include Audit Reason Description for Report
740aA*    06/11/20  KDE  7.40a
     *      - Added Customer number and Name to call to MRC report R02100
750 A*    12/10/21  KDE  7.50
     *      - Added single quotes around Transaction list
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

730cAFbfcdbgflg if   e           k disk    usropn
730cAFbfcdebug  o    e           k disk
730eAFoptions   if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------
     D orderList       s              7  0 dim(100)

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D lbrec         E ds                  extname(label) inz(*EXTDFT)
     D ptrec         E ds                  extname(pirtran) inz(*EXTDFT)
     D ohrec         E ds                  extname(ordh) inz(*EXTDFT)
     D rhrec         E ds                  extname(rtehed) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

730cAd dbgflgExists    s               n
730cAd debug           s               n
730cAd debugAfter      s               n
730cAd debugBefore     s               n
730cAd debugLoc        s              1

     d orderCount      s              3  0
730eAd sbmusr          s             10
730eAd sbmjobd         s             10
730eAd sbmlibl         s             10
730dAd testMode        s               n
740 Ad audReason       s            500

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------

     D/copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d GetOrders       pr

     d ChkOrder        pr
     d  ordId                         7  0

     d ChkPicked       pr
     d  ordId                         7  0

     d PrtOrder        pr
     d  ordId                         7  0

     d SubmitJob       pr

730cAd WrtBeforeDebug  pr
730cAd WrtAfterDebug   pr
730cAd WrtDebugPrt     pr
730cAd WrtDebugError   pr

     *----------------------------------------------------------------
     *  Called program prototypes
     *----------------------------------------------------------------

     D/copy qcopysrc,p.exordh
     D/copy qcopysrc,p.getrpt
     D/copy qcopysrc,p.mrcrptsc
     D/copy qcopysrc,p.qcmdexc

730fA*----------------------------------------------------------------
730fA*  *MRCRPT  -  MRC Report Scheduling Options
730fA*
730fA* Fields
730fA*
730fA*    OPIP    -  IP address for Tomcat Server
730fA*    OPPORT  -  IP Port for Tomcat Server
730fA*    OPDPRT  -  Default Printer (Used when one not supplied)
730fA*    OPGSDV  -  Ghostscript Device
730fA*    OPMUSR  -  Mrc User.  Found on iSeries and in MRC Spring Context
730fA*    OPDBSRC -  MRC Datasource for Report Calling to Use
730fA*    OPINCLDD-  Include Date in IFS filename
730fA*    OPINCLDT-  Include time in IFS filename
730fA*    OPRTDIR -  Include report name in IFS directory Structure
730fA*
730fA*----------------------------------------------------------------
730fA*
730fA* Data structure
730fA*

730fAd opdata          ds
730fAD  opip                   1     15
730fAD  opport                16     20  0
730fAD  opdprt                21     30
730fAD  opgsdv                31     39
730fAD  opmusr                40     49
730fAd  opcpre                50     52
730fAd  opjobd                53     62
730fAd  opdbsrc               63     92
730fAd  opincldd              93     93
730fAd  opincldt              94     94
730fAd  oprptdir              95     95

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD       *PRTORDER - Print if Order fully picked
     *                  *PRTTRAN  - Print if tran order(s) fully picked
     *      $PJOBQ      Y = Put on jobq
     *      $PWHSE      Warehouse
     *      $PTRANLIST  Transactions (',' delimited list)
     *      $PORDID     Order id
730dA*      $PRTN       *TEST - Put into test mode
     *
     *    Returned Parameters
     *      $PRTN    *OK   - Printed
     *               *NONE - Not an audited order
     *               *NOTPICK - Order not fully picked
     *               *AUDCOMP - Order audit already complete
     *      $PMSG    Return message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd            10
     C                   parm                    $pjobq            1
     C                   parm                    $pwhse            3 0
     C                   parm                    $ptranlist      100
     C                   parm                    $pordid           7 0
     C                   parm                    $prtn            10
     C                   parm                    $pmsg           100

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

       *inlr = *on;

730dA  if $prtn = '*TEST';
730dA    testMode = *on;
730dA  else;
730dA    testMode = *off;
730dA  endif;

       $prtn = '*OK';
       $pmsg = '';

730cA    debug = *off;
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

730cA    // Write out 'Before' Debug info

         if debugBefore;
           debugLoc = 'B';
           wrtBeforeDebug();
         endif;

       // See if we should send this to the jobq

       If $pjobq = 'Y';
         SubmitJob();
         return;
       endif;

       // Get list of orders to work with

       GetOrders();

       for i = 1 to orderCount;

         // Only try printing orders that are auditied and audit still open

730eA      $prtn = '*OK';
           ChkOrder(orderList(i));
730eA      if debugAfter;
730eA        bdvalues = 'proc:' + 'Mainline-After ChkOrder' + ', '
730eA                 + '$pRtn:' + %trim($pRtn) + ', '
730eA                 + 'Ord:' + %char(orderList(i)) + ', '
730eA                 + 'exRtnMsg:' + %trim(exRtnMsg) + ', '
730eA                 + 'exRtnCode:' + %trimr(exRtnCode);
730eA        WrtDebugPrt();
730eA      endif;
           if $prtn <> '*OK';
             iter;
           endif;

         // Order must be completly picked
         // All transactions at Ended status.
         // No outstanding label flags

730dA    if not testMode;
           ChkPicked(orderList(i));
730eA      if debugAfter;
730eA        bdvalues = 'proc:' + 'Mainline-After ChkPicked' + ', '
730eA                 + '$pRtn:' + %trim($pRtn) + ', '
730eA                 + 'Ord:' + %char(orderList(i));
730eA        WrtDebugPrt();
730eA      endif;
           if $prtn <> '*OK';
             iter;
           endif;
730dA    endif;

         // Print order

         PrtOrder(orderList(i));
730eA    if debugAfter;
730eA      bdvalues = 'proc:' + 'Mainline-After PrtOrder' + ', '
730eA               + '$pRtn:' + %trim($pRtn) + ', '
730eA               + 'Ord:' + %char(orderList(i));
730eA      WrtDebugPrt();
730eA    endif;
         if $prtn <> '*OK';
           iter;
         endif;

       endfor;

       return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
730cA  begsr *INZSR;

         open(e) bfcdbgflg;
         if %error;
           dbgflgExists = *off;
         else;
           dbgflgExists = *on;
         endif;

730eA    // get iSeries user and jobd from Report Scheduling
730eA    chain ($pwhse:'*MRCRPT') options;
730eA    if %found(options);
730eA       sbmusr = opmusr;
730eA       sbmjobd = opjobd;
730eA       sbmlibl = '*JOBD';
730eA    else;
730eA       sbmusr = '*CURRENT';
730eA       sbmjobd = '*USRPRF';
730eA       sbmlibl = '*CURRENT';
730eA    endif;
730eA
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetOrders     Get list of orders to process
     *----------------------------------------------------------------

     p GetOrders       b
     d GetOrders       pi

     * Local Variables

     D ordId           s              7  0

      /free

       orderCount = 0;
       clear orderList;

       // When Order Id is sent (*PRTORDER) ...

       if $pCmd = '*PRTORDER';
         orderCount = 1;
         orderList(1) = $pordid;
         return;
       endif;

       // When Transaction list is sent (*PRTTRAN) ...

       // Extract order numbers from transactions

       SqlStmt = 'select distinct lbord '
               + 'from label '
               + 'where lbwhse = ' + %char($pwhse) + ' '
               +   'and lbtrn# in (' + %trim($ptranlist) + ')';

       exec sql prepare trnsel from :SqlStmt;
       exec sql declare trncsr cursor for trnsel;
       exec sql open trncsr;

       dow forever = forever;

         exec sql fetch next from trncsr
                  into :ordId;

         if sqlstt <> sqlSuccess;
           leave;
         endif;

         orderCount += 1;
         orderList(orderCount) = ordId;

       enddo;

       exec sql close trncsr;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ChkPicked        Check order is fully picked
     *----------------------------------------------------------------

     p ChkPicked       b
     d ChkPicked       pi
     d  ordId                         7  0

      /free

        SqlStmt = 'select lbvrfy, ptstat '
                + 'from label '
                + 'left outer join pirtran '
                +   'on ptwhse = lbwhse and pttrn# = lbtrn# '
                + 'where lbwhse = ' + %char($pwhse) + ' '
                +   'and lbord = ' + %char(ordId) + ' '
                +   'and lbtype in (''O'', ''M'', ''B'')';

        exec sql prepare pcksel from :SqlStmt;
        exec sql declare pckcsr cursor for pcksel;
        exec sql open pckcsr;

        dow forever = forever;

          exec sql fetch next from pckcsr
                   into :lbvrfy, :ptstat;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          // Transactions must be at Ended status.
          // If trans is at Closed or Exported, we shouldn't have
          // gotten this far because the audit should be closed.

          if ptstat <> '3';
            $prtn = '*NOTPICK';
            $pmsg = 'Order not printed - '
                  + 'Transaction not ended';
730eA       if debugAfter;
730eA         bdvalues = 'proc:' + 'ChkPicked' + ', '
730eA                  + 'msg:' + 'Order not printed-Trans not ended' + ','
730eA                  + 'whse:' + %char($pWhse) + ', '
730eA                  + 'ordid:' + %char(ordId) + ', '
730eA                  + 'psstat:' + %trim(ptstat);
730eA         WrtDebugPrt();
730eA       endif;
            leave;
          endif;

          // Label record cannot have outstanding flag

          if lbvrfy = 'F' or lbvrfy = 'I';
            $prtn = '*NOTPICK';
            $pmsg = 'Order not printed - '
                  + 'Outstanding label flag';
730eA       if debugAfter;
730eA         bdvalues = 'proc:' + 'ChkPicked' + ', '
730eA                  + 'msg:' + 'Order not printed-Outstanding Flg' + ','
730eA                  + 'whse:' + %char($pWhse) + ', '
730eA                  + 'ordid:' + %char(ordId) + ', '
730eA                  + 'psstat:' + %trim(lbvrfy);
730eA         WrtDebugPrt();
730eA       endif;
            leave;
          endif;

        enddo;

        exec sql close pckcsr;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ChkOrder       Check if order has an audit
     *----------------------------------------------------------------

     p ChkOrder        b
     d ChkOrder        pi
     d  ordId                         7  0

      /free

       exWhse = $pwhse;
       exordh ('*GET': exRtnCode: exRtnMsg: exWhse: ordId:
               ohaaudflg: ohaaudid: ohaaudcmp: ohaaudby);

730dA  if testMode;
730dA    return;
730dA  endif;

       if exRtnCode = '*OK' and ohaaudflg = 'Y';
         if ohaaudcmp = 'Y';
           $prtn = '*AUDCOMP';
           $pmsg = 'Order not printed - '
                 + 'Audit is closed';
730eA      if debugAfter;
730eA        bdvalues = 'proc:' + 'ChkOrder' + ', '
730eA                 + 'msg:' + 'Audit is Closed' + ','
730eA                 + 'audid:' + %char(ohaaudid) + ', '
730eA                 + 'ordid:' + %char(ordId) + ', '
730eA                 + 'exRtnMsg:' + %trim(exRtnMsg) + ', '
730eA                 + 'exRtnCode:' + %trimr(exRtnCode);
730eA        WrtDebugPrt();
730eA      endif;
         endif;
       else;
         $prtn = '*NONE';
         $pmsg = 'Order not printed - '
               + 'Order is not being audited';
       endif;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  PrtOrder       Print order
     *----------------------------------------------------------------

     p PrtOrder        b
     d PrtOrder        pi
     d  ordId                         7  0

     *  Local Variables

     D pgm             s             20
     D url             s           3000
     D email           s           1000
     D orient          s              1
     D grStyp          s              1
     D grWhdp          s              5
     D grDesc          s             50
     D grDev           s             10
     D grForm          s             10

      /free

       pgm = 'BFCDAKOTA.R02100';
       orient = 'P';

       // Get Order information

740 D  //exec sql select ohcord, ohstop, ohrte, rhrte, rhpbat
740 D  //         into :ohcord, :ohstop, :ohrte, :rhrte, :rhpbat
740AD  //exec sql select ohcord, ohstop, ohrte, ohcust, rhrte, rhpbat
740AD  //         into :ohcord, :ohstop, :ohrte, :ohcust, :rhrte, :rhpbat
740aM  exec sql select ohcord, ohstop, ohrte, ohcust, ohcnam, rhrte, rhpbat
740aM           into :ohcord, :ohstop, :ohrte, :ohcust, :ohcnam, :rhrte, :rhpbat
                from ordh
                left outer join rtehed
                  on rhwhse = ohwhse and rhrtid = ohrte
                where ohwhse = :$pwhse
                  and ohord = :ordId;

       if sqlstt <> sqlSuccess;
         $prtn = '*NOTFOUND';
         $pmsg = 'Order not printed - '
               + 'Error getting Order Header';
730cA    WrtDebugError();
         return;
       endif;

       // Get Report information

       getrpt ('*DEVFORM': 'R02100': $pwhse: grStyp: grWhdp:
               grDesc: grDev: grForm);

       // Format URL
       // Note: pdf fields are genreated by MRCRPTSCH program

740 A  // Get Customer Audit Reason if it exist
740 A  audReason=*blanks;
740 A  exec sql select cmaudr into :audReason
740 A             from custmastxa
740 A       where cmawhse=:$pWhse and cmacust=:ohcust
740 A         fetch first row only;

       url = '&OUTFMT=11'
           + '&D_DETAIL=1'
           + '&OHWHSE=' + %char($pwhse)
           + '&OHORD=' + %char(ordId)
           + '&OHCORD=' + %char(ohcord)
740aA      + '&OHCUST=' + %char(ohcust)
740aA      + '&OHCNAM=' + %trim(ohcnam)
           + '&OHRTE=' + %trim(ohrte)
730dA      + '&OHSTOP=' + %char(ohstop)
           + '&AID=' + %char(ohaaudid)
           + '&RHRTE=' + %trim(rhrte)
730dA      + '&RHPBAT=' + %char(rhpbat)
740 A      + '&AUDREASON=' + %trim(audReason)
730dA      + '&TEST=' + testMode
           + '&rtndta=0';

       // Call program to print report

       monitor;
         mrcrptsch ($pwhse: pgm: url: email: grDev: orient);
730cA    if debugAfter;
           bdvalues = 'pg:' + %trimr(pgm) + ', '
730eA               + 'msg:' + 'Good Call to MRCRPTSCH' + ','
                    + 'em:' + %trim(email) + ', '
                    + 'dv:' + %trim(grdev) + ', '
                    + 'or:' + %trim(orient) + ', '
                    + 'url:' + %trimr(url);
           WrtDebugPrt();
         endif;
       on-error;
         $prtn = '*ERROR';
         $pmsg = 'Order not printed - '
               + 'Error calling MRCRPTSCH';
730cA    WrtDebugError();
730eA    if debugAfter;
730eA      bdvalues = 'proc:' + 'PrtOrder' + ', '
730eA               + 'msg:' + 'Error Calling MRCRPTSCH' + ','
730eA               + 'Status Code:' + %char(%status) + ', '
730eA               + 'whse:' + %char($pWhse) + ', '
730eA               + 'pgm:' + %trim(pgm) + ', '
730eA               + 'url:' + %trim(url) + ','
730eA               + 'email:' + %trim(email) + ', '
730eA               + 'pgm:' + %trim(grDev) + ', '
730eA               + 'pgm:' + %trim(orient);
730eA      WrtDebugPrt();
730eA    endif;
       endmon;

      /end-free
     p                 e

     *----------------------------------------------------------------
     *  SubmitJob      Sumbit program to Jobq
     *----------------------------------------------------------------

     p SubmitJob       b
     d SubmitJob       pi

     *  Local Variables

     D cmd             s           3000    varying

      /free

730dA    if testMode;
730dA      $prtn = '*TEST';
730dA    else;
730dA      $prtn = '';
730dA    endif;

         cmd = 'sbmjob '
             +   'cmd('
730bM        +      'PRTORDAUD pcmd(' +
730bM                    %trim($pcmd) + ') ' +
730bM                    'pjobq(N) ' +
730bM                    'pwhse(' + %char($pwhse) + ') '  +
750 D                    //'ptranlst(' + %trim($ptranlist) + ') ' +
750 M                    'ptranlst(''' + %trim($ptranlist) + ''') ' +
730bM                    'pordid(' + %char($pordid) + ') ' +
730dM                    'prtn(' + sq + %trim($prtn) + sq + ') ' +
730bM                    'pmsg( )) ' +
730eA        //  'log(4 00 *SECLVL) ' +
730eA            'inllibl(' + %trim(sbmlibl) + ') ' +
730eA            'jobd(' + %trim(sbmjobd) + ') ' +
730eA            'user(' + %trim(sbmusr) + ') ' +
730bM            'jobq(QSYSNOMAX) ' +
730bM            'job(PRTORDAUD)';
730bD        //+      'CALL PRTORDAUD ('
730bD        //+         sq + %trim($pcmd) + sq + ' '
730bD        //+         sq + 'N' + sq + ' '
730bD        //+         'X' + sq + %char($pwhse) + 'F' + sq + ' '
730bD        //+         sq + %trim($ptranlist)+ sq  + ' '
730bD        //+         'X' + sq + %char($pordid) + 'F' + sq + ' '
730bD        //+         sq + sq + ' '
730bD        //+         sq + sq
730bD        //+      ')'
730bD        //+   ') '
730bD        //+ 'jobq(QSYSNOMAX) '
730bD        //+ 'job(PRTORDAUD)';

         // Submit command

         monitor;
           qcmdexc(cmd: %len(cmd));
730eA      if debugAfter;
730eA        bdvalues = 'proc:' + 'SubmitJob' + ', '
730eA                 + 'msg:' + 'Job Submit Success' + ','
730eA                 + 'Status Code:' + %char(%status) + ', '
730eA                 + 'sbmjob:' + %trim(cmd);
730eA        WrtDebugPrt();
730eA      endif;
         on-error;
           $prtn = '*JOBQERR';
730cA      WrtDebugError();
730eA      if debugAfter;
730eA        bdvalues = 'proc:' + 'SubmitJob' + ', '
730eA                 + 'msg:' + 'Job Submit Issues' + ','
730eA                 + 'sbmjob:' + %trim(cmd);
730eA        WrtDebugPrt();
730eA      endif;
           dump(a);
         endmon;

      /end-free
     p                 e

     *----------------------------------------------------------------
     *  wrtBeforeDebug  Write out 'Before' debug info
     *----------------------------------------------------------------

730cAp WrtBeforeDebug  b
     d WrtBeforeDebug  pi

      /free

         bdtype = 'PARMS';

         bdvalues = 'pcmd:' + %trimr($pcmd) + ', '
                  + 'dbgloc:' + %trimr(debugLoc) + ', '
                  + 'pjobq:' + $pjobq + ', '
                  + 'pwhs:' + %char($pwhse) + ', '
                  + 'plist:' + %trimr($ptranlist) + ', '
                  + 'pord:' + %char($pordid);

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

730cAp WrtAfterDebug   b
     d WrtAfterDebug   pi

      /free

         bdtype = 'PARMS';

         bdvalues = 'pcmd:' + %trimr($pcmd) + ', '
                  + 'dbgloc:' + %trimr(debugLoc) + ', '
                  + 'pjobq:' + $pjobq + ', '
                  + 'pwhs:' + %char($pwhse) + ', '
                  + 'plist:' + %trimr($ptranlist) + ', '
                  + 'pord:' + %char($pordid) + ', '
                  + 'prtn:' + %trimr($prtn) + ', '
                  + 'pmsg:' + %trimr($pmsg);

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
     *  wrtDebugPrt    Write out debug Print line
     *----------------------------------------------------------------

730cAp WrtDebugPrt     b
     d WrtDebugPrt     pi

     *  Local Variables

     D savevalues      s           1024

      /free

         if not debugBefore;
           savevalues = bdValues;
           debugLoc = 'B';
           wrtBeforeDebug();
           bdValues = savevalues;
         endif;

         bdtype = 'INFO';

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

730cAp WrtDebugError   b
     d WrtDebugError   pi

      /free

         if not debugBefore;
           debugLoc = 'B';
           wrtBeforeDebug();
         endif;

         bdtype = 'ERROR';

         bdvalues = %trim($prtn) + '-' + $pmsg;

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

