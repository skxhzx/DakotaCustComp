      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  R36900SR    Print route item notes via scheduled reports
     *  05 August 2020
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
740 A*    08/05/20  DAS  7.40
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk
     Foptions   if   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d dbgflgExists    s               n
     d debug           s               n
     d debugAfter      s               n
     d debugBefore     s               n
     d debugLoc        s              1

     d sbmusr          s             10
     d sbmjobd         s             10
     d sbmlibl         s             10

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------

     D/copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d PrtItemNotes    pr

     d WrtBeforeDebug  pr
     d WrtAfterDebug   pr
     d WrtDebugPrt     pr
     d WrtDebugError   pr

     *----------------------------------------------------------------
     *  Called program prototypes
     *----------------------------------------------------------------

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
     *      $PWHSE      Warehouse
     *      $PRTID      Route Id
     *
     *    Returned Parameters
     *      $PRTN    *OK   - Printed
     *               *ERROR
     *      $PMSG    Return message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $prtn            10
     C                   parm                    $pmsg           100

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

       *inlr = *on;

       $prtn = '*OK';
               $pmsg = '';

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

       // Write out 'Before' Debug info

       if debugBefore;
         debugLoc = 'B';
         wrtBeforeDebug();
       endif;

       // Print item notes for route

       PrtItemNotes();

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
730cA  begsr *INZSR;

         open(e) bfcdbgflg;
         if %error;
           dbgflgExists = *off;
         else;
           dbgflgExists = *on;
         endif;

         // get iSeries user and jobd from Report Scheduling
         chain ($pwhse:'*MRCRPT') options;
         if %found(options);
            sbmusr = opmusr;
            sbmjobd = opjobd;
            sbmlibl = '*JOBD';
         else;
            sbmusr = '*CURRENT';
            sbmjobd = '*USRPRF';
            sbmlibl = '*CURRENT';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  PrtItemNotes   Print item notes
     *----------------------------------------------------------------

     p PrtItemNotes    b
     d PrtItemNotes    pi

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

       pgm = 'BFCREPORTS.R36900';
       orient = 'P';

       // Get Report information

       getrpt ('*DEVFORM': 'R36900': $pwhse: grStyp: grWhdp:
               grDesc: grDev: grForm);

       // Format URL
       // Note: pdf fields are genreated by MRCRPTSCH program

       url = '&OUTFMT=11'
           + '&D_DETAIL=1'
           + '&R001=' + %trim($prtid)
           + '&rtndta=0';

       // Call program to print report

       monitor;
         mrcrptsch ($pwhse: pgm: url: email: grDev: orient);
         if debugAfter;
           bdvalues = 'pg:' + %trimr(pgm) + ', '
                    + 'msg:' + 'Good Call to MRCRPTSCH' + ','
                    + 'em:' + %trim(email) + ', '
                    + 'dv:' + %trim(grdev) + ', '
                    + 'or:' + %trim(orient) + ', '
                    + 'url:' + %trimr(url);
           WrtDebugPrt();
         endif;
       on-error;
         $prtn = '*ERROR';
         $pmsg = 'Route item notes not printed - '
               + 'Error calling MRCRPTSCH';
         WrtDebugError();
         if debugAfter;
           bdvalues = 'proc:' + 'PrtItemNotes' + ', '
                    + 'msg:' + 'Error Calling MRCRPTSCH' + ','
                    + 'Status Code:' + %char(%status) + ', '
                    + 'whse:' + %char($pWhse) + ', '
                    + 'rtid:' + %trim($pRtid) + ', '
                    + 'pgm:' + %trim(pgm) + ', '
                    + 'url:' + %trim(url) + ','
                    + 'email:' + %trim(email) + ', '
                    + 'pgm:' + %trim(grDev) + ', '
                    + 'pgm:' + %trim(orient);
           WrtDebugPrt();
         endif;
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

         bdvalues = 'dbgloc:' + %trimr(debugLoc) + ', '
                  + 'pwhs:' + %char($pwhse) + ', '
                  + 'prtid:' + %trimr($prtid);

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

         bdvalues = 'dbgloc:' + %trimr(debugLoc) + ', '
                  + 'pwhs:' + %char($pwhse) + ', '
                  + 'prtid:' + %trimr($prtid) + ', '
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

