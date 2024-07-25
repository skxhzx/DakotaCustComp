      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  GETDMDSEL  Get the next assignment for a specific user/employee
     *
     *  08 September 2021
     *  Kenneth Elder
     *
     *  Revisions
     *
750 A*   09/08/21  KDE  7.50
     *     - Created
     *
750aA*   09/30/21  KDE  7.50a
     *     - Specify 0 Warehouse for OPSSYSTEM sql
     *
750bA*   10/21/21  KDE  7.50b
     *     - Change condition used to determine if route is selected
     *
750cA*   10/22/21  KDE  7.50c
     *     - Remove code that lookups suspended transactions
     *
750dA*   11/03/21  KDE  7.50d
     *     - Return error if zero is sent in for *UNDO
     *
750eA*   11/03/21  KDE  7.50e
     *     - Change sorting sequence so all zones with specific
     *       priority are considered instead one zone at a time.
     *       Basically when many routes are released bottom sorted
     *       zones are never being serviced until all above is completed
     *
750fA*   01/25/22  KDE  7.50f
     *     - Change to only compare on slot zone when finding
     *       the next open transaction
     *
760 A*   04/20/22  KDE  7.60
     *     - Enh:  Add multiple pallet logic
     *             Also inserted three new parms.  Since last parm was
     *             50 characters long I inserted to prevent overlap to
     *             to other parms.  OR400 will work with old call list
     *             but updates have to be made to OR400 to support new
     *             parm list
     *     - Enh:  Add option to control whether to assign transactions
     *             that match #pallets on PJ first
     *     -       Add option to ONLY assign transactions that match the
     *             #pallets for the PJ
     *     -       Add option to allow a mix of routes to be assigned to
     *             a multiple pallet jack
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     *
     Fzoneh     if   e           k disk    prefix(z_)
     fpiruser   if   e           k disk

     *----------------------------------------------------------------
     * Notes
     *
     *   This program is called from the order selection processes.
     *   The purpose is to go through defined hiearchy and determine
     *   the next best selection transaction for a given employee
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  SQL record(s)
     *----------------------------------------------------------------

     d zafmt           ds            51
     d   zawhse                       3  0 overlay(zafmt)
     d   zacshft                      6    overlay(zafmt:*next)
     d   zacodetp                     1    overlay(zafmt:*next)
     d   zacode                      10    overlay(zafmt:*next)
     d   zarolecd                    10    overlay(zafmt:*next)
     d   zazonecd                     6    overlay(zafmt:*next)
     d   zazonesub                   10    overlay(zafmt:*next)
     d   zazonelvl                    3  0 overlay(zafmt:*next)
     d   zazonepri                    2  0 overlay(zafmt:*next)

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d cnt             s              3  0
     d fndEmpZone      s               n
     d fndZoneH        s               n
     d fndTrans        s               n
     d optrna          s              1
     d optall          s              1
760 Ad opaepf          s              1
760 Ad opamrt          s              1
     d rteWhse         s              3p 0
     d rteRtid         s              5
750eAd rteComp         s              1
750eAd rteTzon         s              6
750eAd rteGen          s              1  0
750eAd rteSzon         s              6
750eAd rteType         s              1
760 Ad rtePalCnt       s              1  0
760 Ad zonePalCnt      s              1  0
     d rteKeyF         s             50
     d wkcomp          s              1
     d wkgen           s              1  0
     d wktzon          s              6
     d wkszon          s              6
760 Ad wkpalcnt        s              1  0
750eAd hldPri          s              2  0
750eAd firstrec        s               n
750eAd sqlStmtx        s           6000

    Ad/copy qcopysrc,p.gettbtyp
    Ad/copy qcopysrc,p.exrtehed

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d getNxtTrn       pr             7  0
     d  iWhse                         3p 0
     d  iRtid                         5
     d  iComp                         1
     d  iTzon                         6
     d  iGen                          1  0
     d  iSzon                         6
750eAd  iType                         1

     *----------------------------------------------------------------
     *  Parameters
     *  Inout--------------------------
     *  pWhse     -  Warehouse
     *  pUser     -  Reqesting User
     *
     *  Output-------------------------
     *  pTran#    - Transaction Number
     *  pRtnCode  - Return Code
     *  pRtnMsg   - Return Message
     *
     *----------------------------------------------------------------

     d GETDMDSEL       pr                  extpgm('GETDMDSEL')
     d  pCmd                         10    const
     d  pWhse                         3p 0
     d  pUser                        10
     d  pTran#                        7p 0
760 Dd* pRtnCode                     10
760 Dd* pRtnMsg                      50
760 Ad  pPalCnt                       1p 0
760 Ad  pRtid                         5
760 Ad  pZone                         6
760 Md  pRtnCode                     10
760 Md  pRtnMsg                      50

     d GETDMDSEL       pi
     d  pCmd                         10    const
     d  pWhse                         3p 0
     d  pUser                        10
     d  pTran#                        7p 0
760 Dd* pRtnCode                     10
760 Dd* pRtnMsg                      50
760 Ad  pPalCnt                       1p 0
760 Ad  pRtid                         5
760 Ad  pZone                         6
760 Md  pRtnCode                     10
760 Md  pRtnMsg                      50

     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------

      /free

       pRtnCode = '*OK';
       pRtnMsg = '';

       exsr getopts;

       select;
        when pCmd = '*GET';
          pTran#=0;
760 A     if %parms >=7;
760 A       monitor;
760 A         // set pallet count to passed parm
760 A         wkPalCnt = pPalCnt;
760 A       on-error;
760 A         // if value set failed then force 1
760 A         wkPalCnt = 3;
760 A       endmon;
760 A     else;
760 A       // if no pallet count was passed then force one
760 A       wkPalCnt = 3;
760 A       pRtid=*blanks;
760 A       pZone=*blanks;
760 A     endif;
          exsr getTran;
        when pCmd = '*UNDO';
          exsr undoTran;
        other;
          pRtnCode = '*INVLDCMD';
          pRtnMsg = 'Invalid command ' + pCmd;
       endsl;

       *inlr = *on;
       return;

       //-----------------------------------------------------------------
       // getTran - Get next transaction for employee
       //-----------------------------------------------------------------

       begsr getTran;

       // Validate user/employee sent
       chain (pUser) piruser;
       if not %found(piruser);
         pTran#=0;
         pRtnCode = '*INVLDUSER';
         pRtnMsg = 'User/Employee is not valid';
       endif;

       // Look for employee transaction in status 8.  If found
       // return that specific transaction to resume. After sending
       // back a status 8 OR400 will prompt to ensure they want to
       // work the suspended transaction sent back.  If not, OR400
       // will send another get.  Since OR400 will write an expection
       // when they say they do not want to resume this process will
       // either get the next status 8 or get an open transaction.
750cD  // Decided that GETDMDSEL would always get next available
750cD  // trnsaction and OR400 will then prompt the user if they have
750cD  // a transaction that is status 8 without an exception logged
750cD  // in voexcp.  If the user tells OR400 they want to resume the
750cD  // suspended transaction then OR400 will call getdmdsel again
750cD  // passing *UNDO, the employee and transaction just assigned
750cD  // and getdmdsel *UNDO will remove the employee from PIRTRAN
750cD  //pTran#=0;
750cD  //exec sql select pttrn# into :pTran#
750cD  //         from pirtran1w
750cD  //   where ptwhse=:pWhse and ptemp#=:usemp# and ptstat='8' and
750cD  //    (select count(*) from voexcp where
750cD  //      sxwhse=ptwhse and sxtrn#=pttrn# and
750cD  //      sxerid='SUSPEND')=0
750cD  //     fetch first row only;
760 M  //if sqlstt=sqlSuccess and pTran#<>0;
750cD  //  *inlr=*on;
750cD  //  return;
750cD  //endif;

       // loop thru Zone priorities for employee passed in
        SqlStmt = 'select '
                +   'zawhse, zacshft, zacodetp, zacode, zarolecd, '
                +   'zazonecd, zazonesub, zazonelvl, zazonepri '
                + 'from zoneaap '
                + 'where '
                +   'zawhse = ' + %char(pWhse) + ' '
                +   'and zacshft=' + sq + sq + ' and zacodetp=' + sq + '1'
                +   sq + ' and zacode=' + sq + %trim(pUser) + sq + ' '
                +   'and zaRoleCd=' + sq + '@SELECT' + sq + ' ';

760 A   // if zone code is passed in then add to selection.  This happens
760 A   // when something is assigned and remaining slots exist on the
760 A   // checked out equipment so OR400 request transaction for remaining
760 A   // slot positions but narrows it to the same zone as previously picked
760 A   if pZone <> *blanks;
760 M     SqlStmt = %trim(sqlStmt) + ' and zazonecd=' + sq +
760 M                %trim(pZone) + sq + ' ';
760 A   endif;
760 D           //+   'order by zazonepri,zazonecd';
760 A   SqlStmt = %trim(SqlStmt) + ' order by zazonepri,zazonecd';

        exec sql prepare empZone from :SqlStmt;
        exec sql declare empZon cursor for empZone;
        exec sql open empZon;
        fndEmpZone = *off;
        fndZoneH = *off;
750eA   hldPri   = 0;
750eA   firstrec = *on;
750eA   exsr setRteSql;

        dow forever = forever;

          exec sql fetch next from empZon
                   into :zawhse, :zacshft, :zacodetp, :zacode, :zarolecd,
                        :zazonecd, :zazonesub, :zazonelvl, :zazonepri;

760 M     if sqlstt <> sqlSuccess;
            if not fndEmpZone;
              pTran#=0;
              pRtnCode = '*NOEMPZONE';
              pRtnMsg = 'No Zone found for user';
750eA         leavesr;
            endif;

750eA       // At this point we have read some employee zone
750eA       // priorities and hit eoj on zoneaap.  We should close
750eA       // off the sql statement and see if transaction
750eA       // available.  If so, we should return, otherwise return
750eA       // error code and zero transaction
750eA       sqlStmtx = %trim(sqlStmtx) + ')';
750eA       exsr getTranSeq;
750eA       if pTran# <> 0;
750eA         leavesr;
750eA       endif;

            if not fndTrans and pTran#=0;
760 A         if %parms>=7;
760 A           if pZone<>*blanks;
760 A             // if zone was passed in that indicates a previous
760 A             // transaction was found and we should simply return
760 A             // 0 for transaction and pallet count so OR400 knows
760 A             // to continue with what it received to this point
760 A             pPalCnt = 0;
760 A             pTran# = 0;
760 A             pRtnCode = '*PRVASSN';
760 A             leavesr;
760 A           else;
760 A             // if no zone was passed in this would indicate it
760 A             // found nothing on first call and should return
760 A             // no transaction found
760 A             pTran#=0;
760 A             pRtnCode = '*NOTRANS';
760 M             pRtnMsg = 'No un-assigned transactions found';
760 A             leavesr;
760 A           endif;
760 A         else;
                pTran#=0;
                pRtnCode = '*NOTRANS';
760 M           pRtnMsg = 'No un-assigned transactions found';
750eA           leavesr;
760 A         endif;
            endif;
750eA       // it should never reach here.  This is inside the
750eA       // EOF for reading priority zones for employee X.
750eA       // We have three conditions above that should catch
750eA       // any scenario at EOF time for ZONEAAP, but just in case
750eA       leavesr;
          endif;
          fndEmpZone = *on;

750eA     // setup Zone Priority value on first record
750eA     if firstrec;
750eA       sqlStmtx = %trim(sqlStmtx) + ' and (';
750eA       hldPri = zazonepri;
750eA     endif;
750eA
750eA     // go see if a transaction is available with the zones
750eA     // associated with the previous Zone Priority
750eA     if hldPri <> zaZonePri;
750eA       sqlStmtx = %trim(sqlStmtx) + ')';
750eA       exsr getTranSeq;
750eA       if pTran# <> 0;
750eA         // Leave as soon as a transaction is found
750eA         leavesr;
750eA       endif;
750eA       hldPri = zaZonePri;
750eA       exsr setRteSql;
750eA       sqlStmtx = %trim(sqlStmtx) + ' and (';
750eA       firstrec=*on;
750eA     endif;

750eA     if not firstrec;
750eA       sqlStmtx = %trim(sqlStmtx) + ' or ';
750eA     endif;

          // Retrieve Truck Zone and Generation for this Zone
          chain (zawhse:zaRoleCd:zazonecd) zoneh;
          if not %found(zoneh);
            iter;
          endif;
          fndZoneH = *on;
          wkgen=z_zhgen;
          if z_zhpzon=*blanks;
            wktzon=zazonecd;
          else;
            wktzon=z_zhpzon;
          endif;
          wkcomp=z_zhcomp;
          if wkcomp=*blanks;
            chain (zawhse:zaRoleCd:z_zhpzon) zoneh;
            wkcomp = z_zhcomp;
          endif;

          // At this point we have determined the employee passed in
          // has at least one Zone Priority defined, and we have determined
          // the Role and Zone associated with that priority exists in the
          // ZoneH file.

          // Now we need to determine what routes have this zone with and
          // which ones are ranked next
750eD     // move above outside of loop and add zone selections
750eD     // so we can sort properly when employee has multiple
750eD     // zones under one priority
750eD     //SqlStmt = 'select '
750eD     //        +   'distinct pswhse, psrtid, rskeyf '
750eD     //        + 'from pltsum, rtehed, rtehedseq '
750eD     //        + 'where '
750eD     //        +   'rswhse = pswhse and rsrtid=psrtid '
750eD     //        +   'and rhwhse = pswhse and rhrtid=psrtid '
750eD     //        +   'and rhstat=' + sq + '4' + sq + ' and pstrn#<>0 ';
750eA     // add selection conditions for the specific zones associated to
750eA     // the zones for this priority sequence
750eA     if firstrec;
750fD       //sqlstmtx = %trim(sqlstmtx) + '(pscomp=';
750fM       sqlstmtx = %trim(sqlstmtx) + '(';
750eA     else;
750fD       //sqlstmtx = %trim(sqlstmtx) + ' (pscomp=';
750fM       sqlstmtx = %trim(sqlstmtx) + ' (';
750eA     endif;
750fD     //sqlstmtx = %trim(sqlstmtx) + sq + %trim(wkcomp) + sq
750fD     //         + ' and pstzon=' + sq + %trim(wktzon) + sq
750fM     sqlstmtx = %trim(sqlstmtx)
750fD        //    + 'pstzon=' + sq + %trim(wktzon) + sq
750eA        //      + ' and psgen=' + %char(wkgen) + ' and psszon=' + sq
750fD        //    + ' and psszon=' + sq
750fM              + 'psszon=' + sq
750eA              + %trim(zazonecd) + sq;
          if zaZoneSub = '1';    // Bulk Pick
750eD       //sqlStmt = %trim(sqlStmt) + ' and pstype=' + sq + 'B' + sq;
750eM       sqlStmtx = %trim(sqlStmtx) + ' and pstype=' + sq + 'B' + sq;
          else;
750eD       //sqlStmt = %trim(sqlStmt) + ' and pstype<>' + sq + 'B' + sq;
750eM       sqlStmtx = %trim(sqlStmtx) + ' and pstype<>' + sq + 'B' + sq;
          endif;

750eA     sqlStmtx = %trim(sqlStmtx) + ')';
750eA     firstrec=*off;

750eA   enddo;

750eA   exec sql close empZon;

750eA   endsr;

750eA  //-----------------------------------------------------------------
750eA  // getTranSeq - Get next transaction based on employee zones and
750eA  //              route sorting
750eA  //-----------------------------------------------------------------

750eA  begsr getTranSeq;

750eA     // At this point there is no need to sort per the Zone
750eA     // Priority in ZONEAAP because we have selected only
750eA     // the specific zones for a specific Priority for the
750eA     // requested user passed in.  The getTran routine reads
750eA     // thru ZONEAAP for the passed in user and build a SQL
750eA     // or each zone within the given Zone Priority, therefore
750eA     // this sql will only be dealing with one group of zone
750eA     // at a time based on the zone priority assigned.  If
750eA     // an employee has one zone for priority 1 it will look
750eA     // at only that zone for an open transaction, if nothing
750eA     // is found it will progress to the next priority such as 2.
750eA     // If 2 has five zones it will consider all five together
750eA     // and read in order of the route sequence and zone code sequence.
750eA     // This should ensure that all zones are processed for a
750eA     // specific route regardless of zone assuming people are
750eA     // active that have those zones in their priorities

760 A     // if route was passed in then only return data for that route.
760 A     // This can happen when using multi-pallet equipment and it
760 A     // first assigns less than full equipment pallet count.  When
760 A     // that happens it returns the route from the assigned pallet
760 A     // and then OR400 calls again with remaining pallet positions
760 A     // and passes back the route id and zone so we only look again
760 A     // for that zone and route.  Pass zone is in previous sql stmt
760 A     // that reads through priority zones for employee.
760 A
760 A     // If the option is set to ignore whether it is the same route
760 A     // or not it will assign other available routes
760 A     if opamrt <> 'Y';
760 A       if %parms >= 8;
760 A         if pRtid <> *blanks;
760 A           sqlStmtx = %trim(sqlStmt) + ' and psRtid=' + %trim(pRtid);
760 A         endif;
760 A       endif;
760 A     endif;
760 A     // If assigning transactions with matching number to
760 A     // pallet kacj number then sort count within route seq
760 A     if opaepf = 'Y';
760 A       sqlStmtx = %trim(sqlStmtx) +
760 A                  ' order by pltcnt desc, rskeyf, psszon';
760 A     else;
            sqlStmtx = %trim(sqlStmtx) +
760 A                  ' order by rskeyf, pltcnt desc, psszon';
760 A     endif;

750eA     exec sql prepare rteOrd from :SqlStmtx;
750eA     exec sql declare rteO cursor for rteOrd;
750eA     exec sql open rteO;
750eA     fndtrans = *off;

750eA     dow forever = forever;

750eA       exec sql fetch next from rteO
750eA              into :rteWhse, :rteRtid, :rteComp, :rteTzon, :rteGen,
760 D                   //:rteSzon, :rtekeyf, :rteType;
760 M                   :rteSzon, :rtekeyf, :rteType, :zonePalCnt;

750eA       if sqlstt <> sqlSuccess;
750eA         leave;
750eA       endif;

750eA       // now that we have a valid zone, and the sequencially next
750eA       // route id via the customers sorting option we call the
750eA       // final process which looks through pltsum for an open transaction.
750eA       // The sub-procedure below will return either a valid open
750eA       // transaction to start the selector on or it will return zero
750eA       // meaning nothing was found
760 A
760 A       monitor;
760 A         if zonePalCnt < 1;
760 A           zonePalCnt = 1;
760 A         endif;
760 A       on-error;
760 A         zonePalCnt=1;
760 A       endmon;
760 A
760 A       monitor;
760 A         if pPalCnt < 1;
760 A           pPalCnt = 1;
760 A         endif;
760 A       on-error;
760 A         pPalcnt = 1;
760 A       endmon;

            // ensure equipment is capable of servicing number of pallets
            if zonePalCnt > pPalCnt;
              zonePalCnt = pPalCnt;
            endif;

           // for each route we first look for highest number of pallets
           // per the equipment and route id being sent.  This assures we
           // send multi-pallet transactions to selectors with that equipment
           // first on the highest ranked routes first
760 A      dow zonePalCnt > 0;
760 A
750eA       pTran# = getNxtTrn(rteWhse:rteRtid:rteComp:rteTzon:rteGen:rteSzon
750eA                                                                :rteType);
760 A       if pTran# = 0;
760 A         zonePalCnt = zonePalCnt - 1;
760 A         iter;
760 A       else;
760 A         leave;
760 A       endif;
760 A      enddo;

750eA       if pTran# = 0;
750eA         iter;
750eA       else;
750eA         leave;
750eA       endif;

750eA     enddo;
750eA     exec sql close rteO;

750eA     if pTran#<>0;
750eA       // leave loop and return if we found a transaction
750eA       fndtrans=*on;
750eA     endif;

750eA   endsr;

        //----------------------------------------------------------
        //  getopts - Get Options for Auto Assign
        //----------------------------------------------------------

        begsr getopts;
760 M       exec sql select optrna, optall, opaepf,opamrt
760 M                 into :optrna, :optall, :opaepf, :opamrt
                 from opssystem
750aA            where opwhse=0;
760 M       if sqlstt <> sqlSuccess;
              optrna='N';
              optall=' ';
760 A         opaepf='N';
760 A         opamrt='N';
            endif;
        endsr;

750eA   //----------------------------------------------------------
750eA   //  setRteSql - Set basic Route Ordered SQL
750eA   //----------------------------------------------------------

750eA   begsr setRteSql;

750eA   // Setup base sql to pull info in order by route sequence
750eA   // per the selected zones within specific zone priority for
750eA   // the requested employee passed in.  The purpose covers where
750eA   // an employee could have five zones  all ranked as priority 2.
750eA   // this will end up building a sql that determines the highest
750eA   // ranking transaction for all the zones in that priority seq.
750eA   SqlStmtx= 'select '
750eA           +   'distinct pswhse, psrtid, pscomp, pstzon,'
750eA           +   'psgen,psszon,rskeyf,pstype,'
760 A           +   'maxpltcnt(pswhse,psrtid,psszon,psgen,pstype) as pltcnt '
750eA           + 'from pltsum, rtehed, rtehedseq '
750eA           + 'where '
750eA           +   'rswhse = pswhse and rsrtid=psrtid '
750eA           +   'and rhwhse = pswhse and rhrtid=psrtid '
750eA           +   'and rhstat=' + sq + '4' + sq + ' and pstrn#<>0 ';
750eA   endsr;

        //----------------------------------------------------------
        //  undoTran - UnAssign employee for specific transaction
        //----------------------------------------------------------

        begsr undoTran;
750dA       // Return error if zero sent to undo
750dA       if pTran#=0;
750cA         pRtnCode = '*UNDOZERO';
750cA         pRtnMsg = 'Zero Tran is invalid for UNDO';
750cA         return;
750dA       endif;
            exec sql update pirtran set ptemp#=0
                 where pttrn#=:pTran#;
760 M       if sqlstt <> sqlSuccess;
              pRtnCode = '*UNDOFAIL';
              pRtnMsg = 'Undo failed';
            endif;
        endsr;

      /end-free

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

      /free
       begsr *pssr;

         // Make sure we don't get caught in an infinite loop

         if pssrflag;
           *inlr = *on;
           return;
         endif;

         pssrflag = *on;

         //  Send message back to calling program

         dump(a);

         pRtnCode = '*ERROR';
         pRtnMsg = 'PSSR: ' + %trim(#pgm) + ' (' + %char(#stmt) + ') '
                 + #status + ' - ' + %trim(#pgmmsg);

         *inlr = *on;
         return;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getNxtTrn - Get NExt Transaction for requesting employee
     *----------------------------------------------------------------

     p getNxtTrn       b

     * Local Files

     Fpltsum3   uf   e           k disk
     Fpirtran   uf   e           k disk

     d getNxtTrn       pi             7  0
     d  iWhse                         3p 0
     d  iRtid                         5
     d  iComp                         1
     d  iTzon                         6
     d  iGen                          1  0
     d  iSzon                         6
     d  iType                         1

     * Local File Data Structures

     d pltrec          ds                  likerec(psrec: *input)
     d trnrecin        ds                  likerec(ptrec: *input)
     d trnrecout       ds                  likerec(ptrec: *output)

     * Local Variables

     d rtnTran         s              7  0
     d tbEnhanced      s               n
     d tbPalletType    s              1
     d tbType          s              1
     d wkrtid          s              5
     d wktbtype        s              1
     d wkardypp        s              1
     d wkaasn          s              1
760 Ad wkwhse          s              3  0
760 Ad wktrn#          s              7  0

      *
      *   Determine if using TruckBUilder Enhanced
      *

      /free
           GetTBType(iWhse: iRtid: tbType);
           if tbType = 'E';
             tbEnhanced = *on;
             tbPalletType = 'P';
           else;
             tbEnhanced = *off;
             tbPalletType = 'O';
           endif;

750eD      //if iGen <> 1;
750eM      if iGen <> 1 and iGen <> 7;
             tbPalletType = 'O';
           endif;

750eD      //if %trim(zaZoneSub) = '1';      // Bulk Pick
750eM      if iType = 'B';      // Bulk Pick
             if tbPAlletType = 'O';
               iGen = 1;
             else;
               iGen = 7;
             endif;
             tbPalletType = 'B';
           endif;

           // Now to set the key for pltsum and read for available
           // transactions
           setll (iWhse:iRtid:tbPalletType:iComp:iTzon:iGen:iSzon) pltsum3;

           dow forever = forever;

             reade (iWhse:iRtid:tbPAlletType:iComp:iTzon:iGen:iSzon)
                         pltsum3 pltrec;
             if %eof(pltsum3);
               rtnTran = 0;
               return rtnTran;
             endif;

             // skip pallet if nothing was picked
             if pltrec.pspcs=0;
               iter;
             endif;

             // Skip pallet if tran#=0 and pallet contain bulk pick.
             // In that case we assume that the pallet only contains
             // a bulk pick and was not assigned a trans# in OR630
             if pltrec.pstrn#=0;
               iter;
             endif;

            // When option turned on for Selected Routes Only we
            // should only process selected routes
            exWhse = pltrec.pswhse;
            wkRtid = pltrec.psrtid;
            wktbtype = *blanks;
            wkardypp = *blanks;
            wkaasn = *blanks;
            exrtehed('*GET': exRtnCode: exRtnMsg: exWhse: wkrtid: wktbtype:
                                wkardypp: wkaasn);
            if exRtnCode <> '*OK';
              wkaasn='N';
            endif;

            // if auto tran is off then skip.  It should never reach this call stack
            // if no but have this here in case
            if optrna='N';
              iter;
            endif;

            // If selected routes only are on and this route is not selected
            // then skip
750bD       //if optall='S' and wkaasn='N';
750bA       if optall='S' and wkaasn<>'Y';
              iter;
            endif;

760 A       // if pallet count sent in we need to determine number
760 A       // of pallets on this transaction and skip if it exceeds
760 A       // pallet jack being used
760 A       if %parms>=7;
760 A         wkwhse=pltrec.pswhse;
760 A         wktrn#=pltrec.pstrn#;
760 A         exec sql select count(*) into :rtePalCnt
760 A                     from pltsum
760 A            where pswhse=:wkwhse and pstrn#=:wktrn#;
760 A
760 A         // skip if this transaction requires more pallets than
760 A         // checked out equipment allows.  zonePalCnt starts at
760 A         // what is passed in and it loops down to 1 until it
760 A         // either fines a match or ends up returning no transaction
760 A         // found.
760 A
760 A         // if option "opaepf" is set to Yes then we will loop through
760 A         // all selected zones and routes until we find a match for the
760 A         // number of pallets per the pallet jack being used.  It will
760 A         // make it here to search through all routes to find matching
760 A         // pallet count.  If it finds no transactions with passed count
760 A         // it will reduce the pallet count down to one looking for a match.
760 A         // This is controlled in GETTRANSEQ. The value zonePAlCnt starts with
760 A         // what is passed in and reduced by one each time and placed in
760 A         // zonePalCnt.
760 A         if opaepf='Y' and rtePalCnt <> zonePalCnt;
760 A           iter;
760 A         endif;
760 A
760 A         if rtePalCnt > wkPalCnt;
760 A           iter;
760 A         endif;
760 A       endif;
760 A
             // ensure status is "1" and no employee assigned
             chain (pltrec.pstrn#) pirtran trnrecin;
             if not %found(pirtran);
               unlock pltsum3;
             else;
               trnrecout = trnrecin;
               if trnrecin.ptstat='1' and trnrecin.ptemp#=0;
                 rtntran = trnrecin.pttrn#;
                 trnrecout.ptemp#=usemp#;
                 update ptrec trnrecout;
                 unlock pltsum3;
760 A            if %parms >=7;
760 A              // reduce passed in pallet count for transaction selected
760 A              monitor;
760 A                pPalCnt = pPalCnt - rtePalCnt;
760 A                if pPalCnt < 0;
760 A                  pPalCnt = 0;
760 A                endif;
760 A              on-error;
760 A                pPalCnt = 0;
760 A              endmon;
760 A              if pltrec.psgen <> 2;
760 A                pRtid = pltrec.psrtid;
760 A              else;
760 A                pRtid = *blanks;
760 A              endif;
760 A              pZone = pltrec.psszon;
760 A            endif;
                 return rtnTran;
               else;
                 unlock pltsum3;
                 unlock pirtran;
               endif;
             endif;

           enddo;

      /end-free

     p                 e
