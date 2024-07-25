      /copy *libl/qcopysrc,hspecs
650bAH DFTACTGRP(*no)
     *----------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Rese
     *   BFC Software, Inc.
     *----------------------------------------------------------

     *----------------------------------------------------------
     *
     *  M16800      Confirm Closing for Line/Date OK
     *  02 Feb 2015
     *  Kenneth Elder
     *
     *  Revisions:
     *
     *    02/26/15  KDE  6.50
     *      - Created.
700 A*    10/27/15  KDE  7.00
     *      - When clicking close from warning messages change
     *        to force close and not go back through checks
700aA*    12/21/15  KDE  7.00a
     *      - Check for existing WIP for specific Prod. Line
700bA*    01/09/16  KDE  7.00b
     *      - Double check to ensure no open prod slots
700cA*    08/14/16  KDE  7.00c
     *      - Ensure all raw materials with Open production for
     *        selected line and date have a LIN slot for EOD
700dA*    11/22/16  KDE  7.00d
     *      - Change Slot status to "Z" for Zerovfy status if
     *        LIN slot has no inventory, no open Work Orders
     *        and no PWRKORDRU records.
710 A*    02/10/17  KDE  7.10
     *      - Do not change slot status to "Z" if priority
     *        replenishments exist.
710aA*    02/12/17  KDE  7.10a
     *      - Return Json id saying whether line is Multi-Day
     *      - Return Station id for selected line
710bA*    05/19/17  KDE  7.10b
     *      - Call SPRDCOST to spread Material, LAbor and OH cost
710cA*    07/14/17  KDE  7.10c
     *      - Added code to always past current date to Box Breaker
720aA*    10/29/18  KDE  7.20a
     *      - Remove catch weight check for remaining inventories
730 A*    08/26/19  KDE  7.30
     *      - Change Production Replen type from 'D' to 'O'
     *----------------------------------------------------------

      *----------------------------------------------------------
      * File Specs
      *----------------------------------------------------------
     fslot11    if   e           k disk    rename(slrec:slrec11)
     fplined    if   e           k disk    rename(plrec:plrec1)
710aAfscale     if   e           k disk
     fpiritem   if   e           k disk
     fpRemWgt   if   e           k disk
     fprodlog   uf a e           k disk
     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk
710cAfoptions   if   e           k disk

      *----------------------------------------------------------
      *  Program information data structure
      *----------------------------------------------------------

     d*cochkforpysrc,c#pgminfds
      /copy qcopysrc,c#stdvar

      *----------------------------------------------------------
      * Begin C#PGMINFDS - Program information data structure
      *  12/20/02  DAS  4.16  Created
      *  07/12/08  DAS  6.00a
      *    - Added #curruser, #prog, #jobn
      *  03/02/11  MLB  6.40
      *    - Added #parms
      *----------------------------------------------------------

     D pssrflag        s               n

     D                sds
     D  #pgm                   1     10
     D  #prog                  1     10
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #routine              29     36
     D  #parms                37     39
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobnbr              264    269
     D  #jobn                264    269
     D  #jobdate             276    281  0
     D  #jobtime             282    287  0
     D  #curruser            358    367

      *** End C#PGMINFDS ***

      *----------------------------------------------------------
      *  Prototypes
      *----------------------------------------------------------
650aA /copy qcopysrc,p.wrtsessl

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#PROD

      *----------------------------------------------------------
      *  Input Parms
      *----------------------------------------------------------

     D  pSessId        s             40    varying
     D  pUser          s             10    varying
     D  pPgm           s             20    varying
     D  pWhse          s              3p 0
     D  pprdDate       s              8    varying
     D  pLine          s              3p 0
     D  pType          s             13    varying
     D  pClose         s              1    varying
     D  pOutStr        s            512    varying

      *----------------------------------------------------------
      *  Variables
      *----------------------------------------------------------
     *
     d rightStr        s           1024
     D wherelabel      s            300
     DreturnStatus     S             10I 0
     D Ok              c                   0
     D sqlSuccess      c                   '00000'
     D SqlStmt         s           2000    inz(' ')
     D len             s              3  0
     D SkipFirstRead   s               n
     D dbgflgExists    s               n
     D debug           s               n
     d pErr            s            110
     d pReturn         s              5
     d opnCount        s              5  0
     d pDatesql        s              8  0
710 Ad station         s              2  0
     d rawItm          s             15
710 Ad recCnt          s              7  0
     D saveVer#        s                   like($slver#)
     d wkError         s               n
     d wkRerr2         s             50

      *----------------------------------------------------------------
      *  Data structure for error message parameters
      *------------------------------------------------------------------
     D $MDT            DS
     D  ERRMSG                 1     50
     D                 DS
     D  $EC                    1      2P 0

      *----------------------------------------------------------
      *  Variables
      *----------------------------------------------------------

     d  pdateNum       s              8  0
700aAd  pWip           s              1
700aAd  wkWipDisp      s             12

      *----------------------------------------------------------
      *  Standard SQL variables and constants
      *----------------------------------------------------------

      *copy qcopysrc,c#stdsql

      *----------------------------------------------------------
      *  SQL record layouts referenced
      *----------------------------------------------------------

     Dslrec          E Ds                  Extname(slot)

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId      Session Id of caller
     *      pUser        User making call
     *      pPgm         Dictionary and Program calling
     *      pWhse        Warehouse
     *      pprdDate     Production Date
     *      pLine        Production Mfg Line
     *      pClose       "Y" to Update and "N" for just checking
     *      pType        Begin, Ending, or Adjust of Inventory
     *
     *    Returned Parameters
610aA*      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
650aAc                   parm                    pSessId
650aAc                   parm                    pUser
650aAc                   parm                    pPgm
     c                   parm                    pWhse
610aAc                   parm                    pprdDate
     c                   parm                    pLine
     c                   parm                    pType
     c                   parm                    pClose
     c                   parm                    pOutStr

      /free

700cA     // Set SQL default parms
700cA     exec sql
700cA       set Option Commit=*none, Dlyprp=*Yes,
700cA                  Closqlcsr = *ENDMOD;

          exsr init;
          pdatesql = 0;
          select;
             when pType = 'DELDATE';
                exsr delDate;
             when pType = 'DATECHK';
                exsr chkforDate;
700aA           exsr chkforWip;
             other;
                exsr chkClose;
          endsl;
          pOutStr = '{'
            +  '"pWhse":"'  + %trim(%char(pWhse)) + '",'
            +  '"pReturn":"'  + %trim(pReturn) + '",'
            +  '"pErr":"'  + %trim(pErr) + '",'
710 A       +  '"pMultiday":"'  + %trim(inDryAge) + '",'
710 A       +  '"pStation":"'  + %char(Station) + '",'
            +  '"pDate":"'  + %trim(%char(pdatesql)) + '",'
700aA       +  '"pWip":"'  + %trim(pWip) + '",'
            +  '"pLine":"'  + %trim(%char(pLine)) + '"}';
          *inlr = *on;
      /end-free

     *----------------------------------------------------------------
     *  cfrmCwgt  Confirm that any remaining inventories for
     *            requested line to be closed have had valid
     *            End of Day catch weights entered for remaining
     *            inventories
     *----------------------------------------------------------------

      /free
       begsr cfrmCwgt;

             // generate SQL to loop through remaining inventory
             // for given mfg line passed in
             SqlStmt='select * ' +
                     'from slot where slwhse=' + %char(pWhse) +
                     ' and slaisl = ' + sq + 'LIN' + sq +
                     ' and slstat = ' + sq + 'PR' + sq +
                     ' and slrlvl = ' + %char(pLine) +
                     ' and slhand <> ' + sq + ' ' + sq +
                     ' and (slstk1 <> 0 or slstk2 <> 0' +
                     ' or slstk3<>0)';

            exec sql PREPARE slt FROM :SqlStmt;
            exec sql DECLARE sltinv SCROLL CURSOR FOR slt;
            exec sql OPEN sltinv;

            exec sql fetch first from sltinv into :slrec;

            dow Sqlstt = sqlSuccess;
               // make sure catch weight items have End of Day Weight
               chain (slwhse:slitem) piritem;
               if %found(piritem) and itcwgt = 'Y';
                  chain (slwhse:slrlvl:slitem:sldisp) premwgt;
                  if not %found(premwgt);
                     pErr = 'Catch Weight item ' + %trim(rwitem) +
                            ' must have End of Day weight entered';
                     pReturn = 'Fatal';
                  else;
                     if rwremwgt = 0;
                        pErr = 'Catch Weight item ' + %trim(rwitem) +
                               ' must have End of Day weight entered';
                     pReturn = 'Fatal';
                     endif;
                  endif;
               endif;
               exec sql fetch next from sltinv into :slrec;
            enddo;
            exec sql close sltinv;

       endsr;

       //---------------------------------------------------------
       // chkClose  -  Check to make sure OK to close
       //---------------------------------------------------------

          begsr chkClose;

             pReturn = ' ';
             pErr = ' ';
700 A        if pClose <> 'Y';
700 A           // first pass thru do edits and return appropriate message
700 A           // if necessary
                exsr chkOpnTrns;
                if pReturn <> 'Fatal' and pClose = 'Y';
                   exsr closeDay;
                endif;
700 A        else;
700 A           // when user is clicking close on message this means they
700 A           // are acnowledging the warning and want to continue to cls
700bA           exsr chkOpnTrns;
700bA           if pReturn <> 'Fatal' and pClose = 'Y';
700 A              exsr closeDay;
700bA              pErr = *blanks;
700bA           endif;
700 A        endif;

          endsr;

700aA  //---------------------------------------------------------
 |     // chkforWip   Check to see if WIP exists for given line
 |     //---------------------------------------------------------
 |
700aA     begsr chkForWip;
 |             exec sql
 |                   select sldisp into :wkWipDisp
 |                     from slot
 |                     where slaisl='WIP' and slhand<>' '
 |                       and slrlvl=:pLine and (slstk1<>0 or
 |                       slstk2<>0 or slstk3<>0)
 |                       fetch first row only;
 |              if sqlStt = '00000';
 |                 pWip = 'Y';
 |              else;
 |                 pWip = 'N';
 |              endif;
 |
700aA     endsr;

       //---------------------------------------------------------
       // chkforDate  Check for open date for passed in Mfg Line
       //---------------------------------------------------------

          begsr chkforDate;

          opnCount = 0;
          exec sql
           select count(*)
            into :opncount
             from prdDate
              where pdwhse = :pwhse and pdline = :pLine
                    and pdstat = 'O';

          if Sqlstt = sqlSuccess;
             select;
             when opncount = 1;
                pErr = ' ';
                pReturn = ' ';
                exec sql               // select valid date to return
                  select pdDate
                    into :pdatesql
                     from prdDate
                       where pdwhse = :pwhse and pdline = :pLine
                             and pdstat = 'O';
             when opncount > 1;
                pErr = 'Multiple Production Dates.  Have the ' +
                       ' planner correct.';
                pReturn = 'Fatal';
             other;
710cA
710cA        // Get Production Options to confirm Box Breaker only
710cA        // If Box Breaker only then use todays date without
710cA        // record being in PRDDATE.  If date setup for Production
710cA        // then use that date
710cA        chain (pWhse:'*PROD') options;
710cA        if %found(options);
710cA           if %subst(opdata:24:1) = 'B';
710cA              // if Box Breaker only then return current date
710cA              pErr = ' ';
710cA              pReturn = ' ';
710aA              pdateSql = %uns(%char(%Date():*Iso0));
710cA              leavesr;
710cA           endif;
710cA        endif;
710cA
             pErr = 'No open Production Date. ' +
                   'Have the planner correct.';
             pReturn = 'Fatal';
             endsl;
          else;
710cA
710cA        // Get Production Options to confirm Box Breaker only
710cA        // If Box Breaker only then use todays date without
710cA        // record being in PRDDATE.  If date setup for Production
710cA        // then use that date
710cA        chain (pWhse:'*PROD') options;
710cA        if %found(options);
710cA           if %subst(opdata:24:1) = 'B';
710cA              // if Box Breaker only then return current date
710cA              pErr = ' ';
710cA              pReturn = ' ';
710aA              pdateSql = %uns(%char(%Date():*Iso0));
710cA              leavesr;
710cA           endif;
710cA        endif;
710cA
             pErr = 'No open Production Date. ' +
                   'Have the planner correct.';
             pReturn = 'Fatal';
          endif;

700dA  //  Flag Slot with "Z" status when no inventory, no open
700dA  //  Work Orders and No previous production produced.
700dA
700dA          chain (pwhse:pLine) plined;
700dA          if not %found(plined);
700dA             inRcvAisl = 'LIN';
710aA          else;
710aA             // if Line/Table is a Multi-Day area setup current
710aA             // date as Production Date if one does not exist.
710aA             // If one exist return that date.
710aA             if indryage = 'Y';
710aA                pdateSql = %uns(%char(%Date():*Iso0));
710aA                pReturn=*blanks;
710aA                pErr=*blanks;
710aA                // if todays date has already been closed for this
710aA                // line please return message stating such
710aA                recCnt = *zeros;
710aA                exec sql select count(*) into :recCnt
710aA                                from prdDate
710aA                     where pdwhse=:pWhse and pdline=:pline
710aA                       and (pdstat='C' or pdstat='D')
710aA                       and pddate = :pdateSql;
710aA                if sqlStt = sqlSuccess and recCnt<>0;
710aA                   exec sql insert into prdDate
710aA                           (PDWHSE, PDLINE, PDDATE, PDSTAT)
710aA                     values(:pWhse,:pLine,:pdateSql,'O');
710aA                   leavesr;
710aA                endif;
710aA                // attempt to add current date for Multi-Day line.
710aA                exec sql select pddate into :pDateSql
710aA                                from prdDate
710aA                     where pdwhse=:pWhse and pdline=:pline
710aA                       and pdstat='O';
710aA                if sqlStt <> sqlSuccess;
710aA                   exec sql insert into prdDate
710aA                           (PDWHSE, PDLINE, PDDATE, PDSTAT)
710aA                     values(:pWhse,:pLine,:pdateSql,'O');
710aA                endif;
710aA                leavesr;
710aA             endif;
700dA          endif;
700dA
700dA          setll (pwhse:inRcvAisl) slot11;
700dA          reade (pwhse:inRcvAisl) slot11;
700dA
700dA          dow not %eof(slot11);
700dA             if slhand<>' ' and slstk1=0 and slstk2=0
710 D     //         and slstk3=0;
710 A                and slstk3=0 and slrlvl=pline;
700dA                // Do not remove if any unclosed or undeleted
700dA                // Work Orders.  Also leave open if any
700dA                // Production produced.
710 A                recCnt = 0;
700dA                exec Sql select count(*) into :recCnt
710 A                          from pWrkOrdr
710 D             //          set wrstat = wrstat
700dA                         where wrwhse=:slwhse and
700dA                           writem=:slitem and
700dA                           wrstat not in('C','D');
700dA                // if sqlStt equals zeros it means open work
700dA                // orders exist and we should not close slot
700dA                if sqlStt <> '00000' or recCnt=0;
700dA                   // Do not remove if any unclosed or undeleted
700dA                   // Open Production.
710 A                   recCnt = 0;
710 D          //       exec Sql update pWrkordru
710 A                   exec Sql select count(*) into :recCnt
710 D          //                set urstat = urstat
710 A                            from pWrkOrdru
700dA                            where urwhse=:slwhse and
700dA                              urrmi=:slitem and
700dA                              urstat not in('C','D');
700dA                   // if sqlStt equals zeros it means open
700dA                   // Production and must remain open
700dA                   if sqlStt <> '00000' or recCnt=0;
710 A                      recCnt = 0;
710 A                      exec sql select count(*) into :recCnt
710 A                               from PrplFil
710 A                               where pritem=:slitem and
710 A                                     prwhse=:slwhse and
710 A                                     prtlvl=:pLine and
730 D                                     //prrplt='D' and prflag<>'D'
730 M                                     prrplt='O' and prflag<>'D'
710 A                                 and prtail = :inRcvAisl;
710 A                      // Finally, if replenishments are found for
710 A                      // Production do not change status on LIN slot
710 A                      // to a Z.
710 A                      if sqlStt <> '00000' or recCnt = 0;
700dA                            exec sql
700dA                            update slot set slstat='Z'
700dA                                   where slwhse = :pwhse and
700dA                                         slwhdp = :slwhdp and
700dA                                         sldisp = :sldisp;
700dA                      endif;
700dA                   endif;
700dA                endif;
700dA             endif;
700dA             reade (pwhse:inRcvAisl) slot11;
700dA          enddo;
700dA
700cA  //  Ensure that all unused Raw Materials records for given
700cA  //  Date and Line have LIN-101 slots to ensure they are
700cA  //  processed for End of Day
700cA
700cA          SqlStmt='select distinct urrmi ' +
700cA                 'from pWrkOrdru, pWrkOrd ' +
700cA                 'where  ' + %char(pWhse) +
700cA                 ' =urwhse and urwo# = wowo# ' +
700cA                 ' and urwhse = wowhse ' +
700cA                 ' and urstat = ' + sq + 'O' + sq +
700cA                 ' and urprddte = ' + %char(pdateSql) +
700cA                 ' and womfgno = ' + %char(pLine);
700cA
700cA          exec sql Prepare Prdsl from :Sqlstmt;
700cA          exec sql Declare ProdDy scroll cursor for Prdsl;
700cA          exec sql Open ProdDy;
700cA          exec sql Fetch first from ProdDy into :RawItm;
700cA
700cA          dow sqlstt = sqlsuccess;
700cA
700cA             exsr getmin;     // ensure LIN-101 slot exists
700cA             exec sql Fetch Next from ProdDy into :RawItm;
700cA
700cA          enddo;
700cA          exec sql Close ProdDy;

          endsr;

       //---------------------------------------------------------
       // chkOpnTrns  Check for Open Production transactions
       //---------------------------------------------------------

          begsr chkOpnTrns;

720aD     //exsr cfrmCwgt;
          // perform other checks if catch weight items were OK
          if pErr = ' ';

          // look for any open production transaction for
          // production date.  User MUST close these
          // transactions before they can close a date
          exec sql
           select count(*)
            into :opncount
             from pWrkOrdRu,pWrkOrd
              where urwhse = :pwhse and urprddte = :pdatenum
                    and urwhse = wowhse and urwo# = wowo#
                    and womfgno = :pLine and urstat = 'O';

          if Sqlstt = sqlSuccess;
             if opnCount <> 0;
                pErr = %char(opnCount) + ' Open Production Trans ' +
                      'still remain.  You must perform End of ' +
                      'day before closing';
                pReturn = 'Fatal';
             endif;
          endif;

          // Look for any remaining inventory in Production
          // PAR or Customer Specific slots.  If exists, user
          // must either putaway in warehouse or pick to order
          // before being allowed to close
          if pErr = ' ' and pReturn = ' ';
             exec sql
              select count(*)
               into :opncount
                from slot
                 where slwhse = :pwhse and (slaisl = 'PAR' or slaisl='PRD')
                    and slrlvl = :pline and slstat='PR'
                    and slhand<> ' ' and (slstk1<>0 or
                    slstk2<>0 or slstk3<>0);

             if Sqlstt = sqlSuccess;
                if opnCount > 0;
                   pErr = %char(opnCount) + ' Open PAR or PRD (Custo' +
700 A                 'mer Specific) slots w/inventory.  Warning only ' +
700 A                 'but remember to process.';
                   pReturn = 'Warn ';
                endif;
             endif;
          endif;

          // Look for any remaining inventory in Mfg Line
          // and warn user before they close.  They will be
          // given the opportunity to close or return and adjust
          if pErr = ' ' and pReturn = ' ';
             exec sql
              select count(*)
               into :opncount
                from slot
                 where slwhse = :pwhse and (slaisl = 'LIN' or slaisl='WIP')
                    and slrlvl = :pline and slstat='PR'
                    and slhand<> ' ' and (slstk1<>0 or
                    slstk2<>0 or slstk3<>0);

             if Sqlstt = sqlSuccess;
                if opnCount > 0;
                   pErr = %char(opnCount) + ' Open LIN or WIP slots ' +
                      'remain for this Mfg Line.  Return and ' +
                      'adjust, or close as ending inventory';
                   pReturn = 'Warn ';
                endif;
             endif;
          endif;

          endif;    // catch weight items OK

          endsr;

       //---------------------------------------------------------
       // closeDay   Close Production Day
       //---------------------------------------------------------

          begsr closeDay;

             // At this point we have confirmed no open production
             // for the day resides in file pWrkOrdRu and we have
             // warned the user if open inventory remains and they
             // decided to close the day with that inventory

             if pline < 1;
                pline=1;
             endif;

710bA        $ppwhseu = *on;
710bA        $ppWhse = pWhse;
710bA        $pplnenou = *on;
710bA        $pplneno = pLine;
710bA        $ppuser = pUser;
710bA        $ppuseru = *on;
710bA        $ppExpdtu = *on;
710bA        $ppExpdt = %dec(pprdDate:8:0);
710bA
710bA        $dricommand = '*PROD';
710bA        $drisubcmd = '%SPRDCOST';
710bA        $drisys2upd = 'D';
710bA        exsr zzDriCop;

             exec sql
                  update prdDate
                   set pdstat = 'C'
                   where pdwhse = :pWhse
                     and pdline = :pLine
                     and pddate = :pdatenum;

             // change status for production priority replenishments
             // so warehouse cannot perform until next production date
             // opened for this mfg line
             exec sql
                  update prplfil
                   set prflag = '*'
                   where prwhse = :pWhse
                     and prtlvl = :pLine
                     and prtail = 'LIN'
                     and prflag = 'S';

          exsr crtEinvLog;

          endsr;
      /end-free

     *----------------------------------------------------------------
     *  crtEinvLog  Create Ending Inventory Log entries when
     *              Production date closed for Mfg Line
     *----------------------------------------------------------------

      /free
       begsr crtEinvLog;

          // loop through Slot file at the time Production is closed.
          // Create an Ending inventory balance record in the
          // Production Log for any LIN (Raw Material Line) Inventories
          // or WIP (Work in Process Line) Inventories for that
          // selected Mfg Line.

          chain (pWhse:pLine) plined;
          if %found(plined);
             // loop slot looking for Mfg Line inventory
             setll (pWhse:inRcvAisl) slot11;
             reade (pWhse:inRcvAisl) slot11;
             dow %equal(slot11) and not %eof(slot11);
                if slhand<>' ' and (slstk1<>0 or slstk2<>0 or slstk3<>0)
                   and slstat='PR';
                   exsr wrtProdLog;   // generate beginning inv log record
                endif;
                reade (pWhse:inRcvAisl) slot11;
             enddo;

             // loop slot looking for Mfg Wip inventory
             setll (pWhse:inWipAisl) slot11;
             reade (pWhse:inWipAisl) slot11;
             dow %equal(slot11) and not %eof(slot11);
                if slhand<>' ' and (slstk1<>0 or slstk2<>0 or slstk3<>0)
                   and slstat='PR';
                   exsr wrtProdLog;   // generate beginning inv log record
                endif;
                reade (pWhse:inWipAisl) slot11;
             enddo;
          else;
             // this should not happen, but just in case
             pErr = 'Mfg Line invalid';
          endif;

       endsr;

       //---------------------------------------------------------
       // delDate  Check to make sure Delete is OK then delete Date
       //---------------------------------------------------------

          begsr delDate;

700dA     chain (pwhse:pLine) plined;
          opnCount = 0;
          exec sql
           select count(*)
            into :opncount
             from pWrkOrdRu,pWrkOrd
              where urwhse = wowhse and urwo# = wowo#
                    and urwhse = :pwhse and womfgno = :pLine
                    and urprddte = :pdateNum and urstat<>'D';

          if Sqlstt = sqlSuccess;
             select;
             when opncount > 0 and indryage<>'Y';
                pErr = 'Activity exist.  Cannot delete.';
                pReturn = 'Fatal ';
             other;
                opnCount = 0;
                exec sql
                 select count(*)
                  into :opncount
                  from prodlog
                  where plwhse = :pwhse and plline = :pLine
                       and plprddte = :pDateNum and plAction<>'BIV';
                if (Sqlstt = sqlSuccess and opncount = 0)
                   or indryage='Y';
                   pErr = ' ';
                   pReturn = ' ';
                   exec sql delete from prdDate
                       where pdwhse = :pwhse and pdline = :pLine
                         and pddate = :pDateNum;
                else;
                pReturn = 'Fatal';
                   pErr = 'Activity Exists. Cannot delete.';
                endif;
             endsl;
          else;
             opnCount = 0;
             exec sql
              select count(*)
               into :opncount
               from prodlog
               where plwhse = :pwhse and plline = :pLine
                    and plprddte = :pDateNum and plAction<>'BIV';
             if (Sqlstt = sqlSuccess and opncount = 0)
                 or indryage='Y';
                pErr = ' ';
                pReturn = ' ';
                exec sql delete from prdDate
                   where pdwhse = :pwhse and pdline = :pLine;
             else;
                pReturn = 'Fatal';
                pErr = 'Activity Exists. Cannot delete.';
             endif;
          endif;

          endsr;

       //---------------------------------------------------------
       // getmin - This routine will call DRIPROD and verify that
       //          the passed raw material has a LIN-101 slot for
       //          any raw material used in production for given
       //          date and mfg line.  The LIN-101 slot must exist
       //          for EOD to record usage and waste.
       //---------------------------------------------------------
       begsr getmin;

                savever# = $ppver#;
                clear $pprod;
                clear $pprod2;
                $ppver# = savever#;

                if pline <> 0;
                   chain (pwhse:pLine) plined;
                   if %found(plined);
                      $ppdesc = indesc;
                      $pprcvau = *on;
                      $pprcva = inrcvaisl;
                   endif;
                endif;

                if rawitm <> '';
                   chain (pwhse:rawitm) piritem;
                   if %found(piritem);
                      $ppwhdpu = *on;
                      $ppwhdp  = itwhdp;
                      $ppitemu = *on;
                      $ppitem  = ititem;
                   endif;
                endif;

                $ppwhseu = *on;
                $ppwhse  = pwhse;
                $pplnenou = *on;
                $pplneno = pLine;
                $ppuser = pUser;
                $ppuseru = *on;

                $dricommand = '*PROD';
                $drisubcmd = '%GETMIN';
                $drisys2upd = 'D';
                exsr zzDriCop;

                // do not really care of an error.  Just running
                // to confirm exist.  This code will add if not
                // there and return with error code stating it
                // exists if it is there.

       endsr;

       // Init  -  Do some one time things
       //---------------------------------------------------------

          begsr Init;

             pdatenum=0;
             Monitor;
               pdatenum = %dec(pprdDate:8:0);
             on-error 105;
             Endmon;

             pErr = ' ';
             open(e) bfcdbgflg;
             if %error;
               dbgflgExists = *off;
             else;
               dbgflgExists = *on;
             endif;

             if dbgflgExists;
               chain(e) (#pgm) bfcdbgflg;
               if %found(bfcdbgflg);
                 debug = (bdfflag = 1);
               else;
                 debug = *off;
               endif;
             endif;

710 A       // get first active scale for given line
710 A       exec sql select scsta into :station
710 A                  from scale
710 A                where scwhse=:pwhse and scmfgno=:pline
710 A                fetch first row only;

        endsr;
      /end-free

      *----------------------------------------------------------
      *  wrtDebugParms  Write out debug parm record
      *----------------------------------------------------------

      /free
       begsr wrtDebugParms;

         bdtype = 'PARMS';

         bdvalues = '&pprdDate = ' + pprdDate
                  + '&pUser=' + %trimr(pUser)
                  + '&pLine=' + %trimr(%char(pLine))
                  + '&pType=' + %trimr(pType)
                  + '&pOut=' + %trimr(pOutStr);

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  wrtProdLog   Write Beginning Inventory Production Log Entry
     *----------------------------------------------------------------

      /free
       begsr WrtProdLog;

          // have SQL delete record if one already exist for this
          // mfg line, item, slot, and production date and warehouse
          exec sql delete from ProdLog
               where plwhse = :pWhse and plitem = :slitem
                 and plline = :slrlvl and plaction = 'EIV'
                 and pldisp = :sldisp and plprddte = :pDateNum;

650qA    // create Production Log entry
650qA
650qA    plwhse = slwhse;
650qA    plitem = slitem;
650qA    plfgitm = ' ';
650qA
650qA    plaction = 'EIV';
         // call DRISLOT to get license for slot
         savever# = $slver#;
         clear $slot;
         clear $slot2;
         $slver# = savever#;

      // Move fields to slot data structure for quantity adjustment

         $slwhseu = *on;
         $slwhse  = slwhse;

         $slwhdpu = *on;
         $slwhdp = slwhdp;
         $sldispu = *on;
         $sldisp = sldisp;
         $saOLcnsu = *on;

650gA    $dricommand = '*SLOT';
650gA    $drisubcmd  = '%GET';
650gA    $drisys2upd = 'D';
         exsr zzDriCop2;

         if wkError;
            plFlcns = ' ';
            plTlcns = ' ';
         else;
650qA       plFLCNs = $saOlcns;
650qA       plTlcns = $saTolcns;
         endif;
650qA
650qA    plline = slrlvl;
650qA
650qA    plprdDte = pDateNum;
650qA
650qA    pldisp = sldisp;
650qA
650qA    plgs1 = '';
650qA
650qA    plqtyn = slstk1;
650qA    plqty1 = slstk2;
650qA    plqty2 = slstk3;
650qA
         // get end of day weight stored in file pRemWgt.  Maintained
         // in End of Day, MRC M145xx, calls RMQTY and CSLTQTY
         // Next production date opened for this line will pull in
         // this weight for this line and item if the quantities still
         // match.  It will also delete the record from pREMWgt
         chain (pwhse:slrlvl:slitem:sldisp) pRemWgt;
         if %found(pRemWgt);
            plweght = rwremwgt;
         else;
650qA       plweght = 0;
         endif;
650qA
650qA    plbfcwo = ' ';   // BFC work order number.
650qA
650qA    pltare = 0;
650qA
650qA    plpgm = #pgm;
650qA    pluser = #user;
650qA    pljob = #job;
650qA
650qA    pllsts = ' ';
650qA
650qA    plCUSTWO = ' ';
650qA
650qA    pltrn# = 0;
650qA
650qA    pllbl# = 0;
650qA
650qA    plcts = %timestamp();
650qA    pldtetim = %subst(%char(plcts):1:4) +
650qA               %subst(%char(plcts):6:2) +
650qA               %subst(%char(plcts):9:2) +
650qA               %subst(%char(plcts):12:2) +
650qA               %subst(%char(plcts):15:2) +
650qA               %subst(%char(plcts):18:2);
650qA    write plrec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzdricop  Call DRICOP
     *----------------------------------------------------------------

     c     zzDriCop      begsr
     *
     c                   eval      wkError = *off
     *
     c                   select
     *
     c                   when      $dricommand = '*PROD'
     c                   eval      $dridata = $pprod
     c                   eval      $dridata2 = $pprod2

     c                   endsl
     *
     c                   select
     *
     c                   when      $dricommand = '*PROD'
     c                   call(e)   'DRICOP'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata
     c                   parm                    $dridata2

     c                   other
     c                   call(e)   'DRICOP'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata

     c                   endsl

     c                   select

     c                   when      %error
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif
     c                   eval      errmsg    = 'Error occured on call to '
     c                                       + 'DRICOP'
     c                                       + '/' + %trim($drisubcmd)
     c                                       + ' from ' + #prog

     c                   when      $drireturn <> '*OK'
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif

     c                   endsl

     c                   select
     c                   when      $dricommand = '*PROD'
     c                   eval      $pprod = $dridata
     c                   eval      $pprod2 = $dridata2
     c                   endsl

     c                   endsr
     *----------------------------------------------------------------
     *  zzdricop2  Call DRICOP
     *----------------------------------------------------------------

     c     zzDriCop2     begsr
     *
     c                   eval      wkError = *off
     *
     c                   select
     *
     c                   when      $dricommand = '*SLOT'
     c                   eval      $dridata = $slot
     c                   eval      $dridata2 = $slot2

     c                   endsl
     *
     c                   select
     *
     c                   when      $dricommand = '*SLOT'
     c                   call(e)   'DRICOP2'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata
     c                   parm                    $dridata2
     *
     c                   other
     c                   call(e)   'DRICOP2'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata

     c                   endsl

     c                   select

     c                   when      %error
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif
     c                   eval      errmsg    = 'Error occured on call to '
     c                                       + 'DRICOP'
     c                                       + '/' + %trim($drisubcmd)
     c                                       + ' from ' + #prog

     c                   when      $drireturn <> '*OK'
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif

     c                   endsl

     c                   select
     c                   when      $dricommand = '*SLOT'
     c                   eval      $slot = $dridata
     c                   eval      $slot2 = $dridata2
     c                   endsl

     c                   endsr
