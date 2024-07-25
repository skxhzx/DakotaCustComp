      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  CHKORDAUD   Check for audited orders
     *  19 January 2019
     *  Dave Sommerville
     *
     *  Revisions
     *
730 A*    01/19/19  DAS  7.30
     *      - Created
     *
730aA*    01/23/19  DAS  7.30
     *     - Revised to used Distinct instead of Group By / Order By.
     *     - Added check by pallet id
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fordh3     if   e           k disk

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

     d ChkRoute        pr
     d ChkTran         pr
     d ChkOrder        pr
730aAd ChkPallet       pr

     *----------------------------------------------------------------
     *  Called program prototypes
     *----------------------------------------------------------------

     D/copy qcopysrc,p.exordh

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
730aM*      $PCMD    *ROUTE, *TRAN, *ORDER, *PALLET
     *      $PWHSE   Warehouse
     *      $PRTID   Route Id
     *      $PTRAN   Transaction
     *      $PORDID  Order id
730aA*      $PPLTID  Pallet id
     *
     *    Returned Parameters
     *      $PRTN    *NONE - Route/Tran/Order does not contain audit.
     *               *OPEN - Contains audit - at least 1 open.
     *               *CLOSED - Contains audit - all are closed.
     *      $PMSG    Return message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $ptran            7 0
     C                   parm                    $pordid           7 0
730aAC                   parm                    $ppltid           7 0
     C                   parm                    $prtn            10
     C                   parm                    $pmsg           100

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

       *inlr = *on;
       $prtn = '*NONE';
       $pmsg = '';

       select;
         when $pcmd = '*ROUTE';
           ChkRoute();
         when $pcmd = '*TRAN';
           ChkTran();
         when $pcmd = '*ORDER';
           ChkOrder();
730aA    when $pcmd = '*PALLET';
730aA      ChkPallet();
       endsl;

       return;

      /end-free

     *----------------------------------------------------------------
     *  ChkRoute       Check if route has an audit
     *----------------------------------------------------------------

     p ChkRoute        b
     d ChkRoute        pi

      /free

       // Loop through orders for the route

       setll ($pwhse: $prtid) ordh3;

       dow forever = forever;

         reade ($pwhse: $prtid) ordh3;
         if %eof(ordh3);
           leave;
         endif;

         exWhse = $pwhse;
         exordh ('*GET': exRtnCode: exRtnMsg: exWhse: ohord:
                 ohaaudflg: ohaaudid: ohaaudcmp: ohaaudby);

         if exRtnCode = '*OK' and ohaaudflg = 'Y';
           select;
             when ohaaudcmp = 'Y';
               $prtn = '*CLOSED';
             other;
               $prtn = '*OPEN';
               leave;
           endsl;
         endif;

       enddo;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ChkTran        Check if tansaction has an audit
     *----------------------------------------------------------------

     p ChkTran         b
     d ChkTran         pi

      /free

730aD   //SqlStmt = 'select lbord '
730aD   //        + 'from label '
730aD   //        + 'where lbwhse = ' + %char($pwhse) + ' '
730aD   //        +   'and lbtrn# = ' + %char($ptran) + ' '
730aD   //        + 'group by lbord '
730aD   //        + 'order by lbord ';

730aM   SqlStmt = 'select distinct lbord '
730aM           + 'from label '
730aM           + 'where lbwhse = ' + %char($pwhse) + ' '
730aM           +   'and lbtrn# = ' + %char($ptran);

        exec sql prepare trnsel from :SqlStmt;
        exec sql declare trncsr cursor for trnsel;
        exec sql open trncsr;

        dow forever = forever;

          exec sql fetch next from trncsr
                   into :ohord;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          exWhse = $pwhse;
          exordh ('*GET': exRtnCode: exRtnMsg: exWhse: ohord:
                  ohaaudflg: ohaaudid: ohaaudcmp: ohaaudby);

          if exRtnCode = '*OK' and ohaaudflg = 'Y';
            select;
              when ohaaudcmp = 'Y';
                $prtn = '*CLOSED';
              other;
                $prtn = '*OPEN';
                leave;
            endsl;
          endif;

        enddo;

        exec sql close trncsr;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ChkOrder       Check if order has an audit
     *----------------------------------------------------------------

     p ChkOrder        b
     d ChkOrder        pi

      /free

       exWhse = $pwhse;
       exordh ('*GET': exRtnCode: exRtnMsg: exWhse: $pordid:
               ohaaudflg: ohaaudid: ohaaudcmp: ohaaudby);

       if exRtnCode = '*OK' and ohaaudflg = 'Y';
         select;
           when ohaaudcmp = 'Y';
             $prtn = '*CLOSED';
           other;
             $prtn = '*OPEN';
         endsl;
       endif;

      /end-free

     p                 e

730aA*----------------------------------------------------------------
730aA*  ChkPallet      Check if pallet has an audit
730aA*----------------------------------------------------------------
730aA
730aAp ChkPallet       b
     d ChkPallet       pi

      /free

        SqlStmt = 'select distinct lbord '
                + 'from label '
                + 'where lbwhse = ' + %char($pwhse) + ' '
                +   'and lbrte = ' + %trim($prtid) + ' '
                +   'and lbpal# = ' + %char($ppltid);

        exec sql prepare pltsel from :SqlStmt;
        exec sql declare pltcsr cursor for pltsel;
        exec sql open pltcsr;

        dow forever = forever;

          exec sql fetch next from pltcsr
                   into :ohord;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          exWhse = $pwhse;
          exordh ('*GET': exRtnCode: exRtnMsg: exWhse: ohord:
                  ohaaudflg: ohaaudid: ohaaudcmp: ohaaudby);

          if exRtnCode = '*OK' and ohaaudflg = 'Y';
            select;
              when ohaaudcmp = 'Y';
                $prtn = '*CLOSED';
              other;
                $prtn = '*OPEN';
                leave;
            endsl;
          endif;

        enddo;

        exec sql close pltcsr;

      /end-free

     p                 e

