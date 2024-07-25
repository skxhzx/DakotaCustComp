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
750dA*   11/03/21  KDE  7.50ed
     *     - Return error if zero is sent in for *UNDO
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
     d rteWhse         s              3p 0
     d rteRtid         s              5
     d rteKeyF         s             50
     d wkcomp          s              1
     d wkgen           s              1  0
     d wktzon          s              6
     d wkszon          s              6

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
     d  pRtnCode                     10
     d  pRtnMsg                      50

     d GETDMDSEL       pi
     d  pCmd                         10    const
     d  pWhse                         3p 0
     d  pUser                        10
     d  pTran#                        7p 0
     d  pRtnCode                     10
     d  pRtnMsg                      50

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
750cD  //if sqlstt='00000' and pTran#<>0;
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
                +   'and zaRoleCd=' + sq + '@SELECT' + sq + ' '
                +   'order by zazonepri,zazonecd';

        exec sql prepare empZone from :SqlStmt;
        exec sql declare empZon cursor for empZone;
        exec sql open empZon;
        fndEmpZone = *off;
        fndZoneH = *off;

        dow forever = forever;

          exec sql fetch next from empZon
                   into :zawhse, :zacshft, :zacodetp, :zacode, :zarolecd,
                        :zazonecd, :zazonesub, :zazonelvl, :zazonepri;

          if sqlstt = sqlNoMoreData;
            if not fndEmpZone;
              pTran#=0;
              pRtnCode = '*NOEMPZONE';
              pRtnMsg = 'No Zone found for user';
            endif;
            if not fndTrans and pTran#=0;
              pTran#=0;
              pRtnCode = '*NOTRANS';
              pRtnMsg = 'No unassigned transactions found';
            endif;
            leave;
          endif;
          fndEmpZone = *on;

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
          SqlStmt = 'select '
                  +   'distinct pswhse, psrtid, rskeyf '
                  + 'from pltsum, rtehed, rtehedseq '
                  + 'where '
                  +   'rswhse = pswhse and rsrtid=psrtid '
                  +   'and rhwhse = pswhse and rhrtid=psrtid '
                  +   'and rhstat=' + sq + '4' + sq + ' and pstrn#<>0 ';
          if zaZoneSub = '1';    // Bulk Pick
            sqlStmt = %trim(sqlStmt) + ' and pstype=' + sq + 'B' + sq;
          else;
            sqlStmt = %trim(sqlStmt) + ' and pstype<>' + sq + 'B' + sq;
          endif;

          sqlStmt = %trim(sqlStmt) + ' order by rskeyf';

          exec sql prepare rteOrd from :SqlStmt;
          exec sql declare rteO cursor for rteOrd;
          exec sql open rteO;
          fndtrans = *off;

          dow forever = forever;

            exec sql fetch next from rteO
                   into :rteWhse, :rteRtid, :rteKeyF;

            if sqlstt = sqlNoMoreData;
              leave;
            endif;

            // now that we have a valid zone, and the sequencially next
            // route id via the customers sorting option we call the
            // final process which looks through pltsum for an open transaction.
            // The sub-procedure below will return either a valid open
            // transaction to start the selector on or it will return zero
            // meaning nothing was found
            pTran# = getNxtTrn(rteWhse:rteRtid:wkComp:wkTzon:wkGen:zazonecd);
            if pTran# = 0;
              iter;
            else;
              leave;
            endif;

          enddo;
          exec sql close rteO;

          if pTran#<>0;
            // leave loop and return if we found a transaction
            fndtrans=*on;
            leave;
          endif;

        enddo;
        exec sql close empZon;

        endsr;

        //----------------------------------------------------------
        //  getopts - Get Options for Auto Assign
        //----------------------------------------------------------

        begsr getopts;
            exec sql select optrna, optall into :optrna, :optall
                 from opssystem
750aA            where opwhse=0;
            if sqlstt <> '00000';
              optrna='N';
              optall=' ';
            endif;
        endsr;

      /end-free

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
            if sqlstt <> '00000';
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

           if iGen <> 1;
             tbPalletType = 'O';
           endif;

           if %trim(zaZoneSub) = '1';      // Bulk Pick
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
                 return rtnTran;
               else;
                 unlock pltsum3;
                 unlock pirtran;
               endif;
             endif;

           enddo;

      /end-free

     p                 e
