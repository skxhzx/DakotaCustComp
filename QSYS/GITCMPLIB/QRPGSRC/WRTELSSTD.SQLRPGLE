      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  WRTELSSTD  Write Labor Standards for Route
     *
     *  22 November 2021
     *  Kenneth Elder
     *
     *  Revisions
     *
750 A*   11/22/21  KDE  7.50
     *     - Created
     *
760 A*   04/11/22  KDE  7.60
     *     - Add checks to ensure will run without failure
     *     - Only add to ELS files if goal exist
     *
760aA*   05/03/22  KDE  7.60a
     *     - Loop until you find selection trand record in calcstd
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     *
     Frtehed    if   e           k disk
     fpiritem   if   e           k disk
     fpltsum15  if   e           k disk
     fordh3     if   e           k disk
     fordd      if   e           k disk
     flabel8    if   e           k disk
     f                                     prefix(r_)
     flabel7    if   e           k disk
     f                                     prefix(t_)
     fworklbl1  if   e           k disk
     frunner6   if   e           k disk
760 Mfelstds    if   e           k disk    usropn
760 Mfelsstddtl uf a e           k disk    usropn
760 Mfelsstdlog uf a e           k disk    usropn
760 MFbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     * Notes
     *
     *   This program is called from the order import processes
     *   and also from OR605 once a route id moves to Printed.
     *   PT132 will call to update the Close values once the
     *   transaction is closed
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  SQL record(s)
     *----------------------------------------------------------------

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

     D dbgflgExists    s               n
     D debug           s               n
     d cnt             s              3  0
     d fileToUse       s              1
     d commonKey       s             40
     d ordfiles        s               n
     d wrklfile        s               n
     d lblfile         s               n
     d sqrte           s              5
     d hldTask         s              6
     d badReadCnt      s              2  0
     d wkwhdp          s              5
     d wkutyp          s              1

      *  Variable key used for routes at print status or beyond
     d labelkey        ds
     d  lblkey                       40
     d   ilbrte                       5    overlay(lblkey)
     d   ilbtrn#                      7  0 overlay(lblkey:*next)
     d   ilblbl#                      7  0 overlay(lblkey:*next)

      *  Variable key used for routes for open thru built status
     d orderkey        ds
     d  ordkey                       40
     d   iohrtid                      5    overlay(ordkey)
     d   iodord                       7  0 overlay(ordkey:*next)
     d   iodseq                       5  0 overlay(ordkey:*next)
     d   ioditem                     15    overlay(ordkey:*next)
     d   iItmDept                     5    overlay(ordkey:*next)

      *  SQL Data Struction Record to loop through order detail data

     d lsrec           ds            83
     d   sqwhdp                       5    overlay(lsrec)
     d   sqstyp                       1    overlay(lsrec:*next)
     d   sqrtid                       5    overlay(lsrec:*next)
     d   sqord                        7  0 overlay(lsrec:*next)
     d   sqseq                        5  0 overlay(lsrec:*next)
     d   sqitem                      15    overlay(lsrec:*next)
     d   sqqty1                       5  0 overlay(lsrec:*next)
     d   sqqty2                       5  0 overlay(lsrec:*next)
     d   sqqty3                       5  0 overlay(lsrec:*next)
     d   squtyp                       1    overlay(lsrec:*next)
     d   sqtrn#                       7  0 overlay(lsrec:*next)
     d   sqplid                       7  0 overlay(lsrec:*next)
     d   sqltyp                       1    overlay(lsrec:*next)
     d   sqlbl#                       7  0 overlay(lsrec:*next)
     d   sqctr#                       7  0 overlay(lsrec:*next)

    Ad/copy qcopysrc,p.gettbtyp
    Ad/copy qcopysrc,p.exrtehed

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d getSTDval       pr            13p 3
     d  iWhse                         3p 0
     d  iRtid                         5
     d  iWhdp                         5
     d  iStyp                         1
     d  ivarKey                      40

     d stdUpdated      pr            13p 3
     d  iWhse                         3p 0
     d  iRte                          5
     d  iRtid                         5
     d  iWhdp                         5
     d  iStyp                         1
     d  ivarKey                      40
     d  itype                         1
     d  iTrn#                         7s 0

     d calcSTD         pr            13p 5
     d  iWhse                         3p 0
     d  iRtid                         5
     d  iWhdp                         5
     d  iStyp                         1
     d  ilabType                      1
     d  ivarKey                      40

     d wrtDebugParms   pr

     *  used to pause/sleep process for specific period of seconds
     D sleep           pr            10u 0 extproc('sleep')
     D   Interval                    10u 0 value

     *----------------------------------------------------------------
     *  Parameters
     *  Inout--------------------------
     *  pWhse     -  Warehouse
     *  pCmd      -  Command
     *  pRtid     -  Route Id
     *  pTran     -  Transaction
     *  pLabl     -  Label
     *
     *  Output-------------------------
     *  pStd      - Requested Standard
     *  pRtnCode  - Return Code
     *  pRtnMsg   - Return Message
     *
     *----------------------------------------------------------------

     d WRTELSSTD       pr                  extpgm('WRTELSSTD')
     d  pWhse                         3p 0
     d  pCmd                         10    const
     d  pRtid                         5
     d  pWhdp                         5
     d  pStyp                         1
     d  pTran                         7p 0
     d  pStd                         13p 2
     d  pRtnCode                     10
     d  pRtnMsg                      50

     d WRTELSSTD       pi
     d  pWhse                         3p 0
     d  pCmd                         10    const
     d  pRtid                         5
     d  pWhdp                         5
     d  pStyp                         1
     d  pTran                         7p 0
     d  pStd                         13p 2
     d  pRtnCode                     10
     d  pRtnMsg                      50

     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------

      /free

       if dbgflgExists;
         chain(e) (#pgm) bfcdbgflg;
         if %found(bfcdbgflg);
           debug = (bdfflag = 1);
         else;
           debug = *off;
         endif;
       endif;

       pRtnCode = '*OK';
       pRtnMsg = '';
       *inlr = *on;

       select;
        when pCmd = '*GETSTD';
          exsr getStd;
        when pCmd = '*UPDSTD';
          exsr updSTD;
        other;
          pRtnCode = '*INVLDCMD';
          pRtnMsg = 'Invalid command ' + pCmd;
       endsl;

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
760 A*
760 A*   Verify these files exist on this box.  If not then leave
760 A       open(e) elsstddtl;
760 A       if %error;
760 A         return;
760 A       endif;
760 A
760 A       open(e) elsstdlog;
760 A       if %error;
760 A         return;
760 A       endif;
760 A
760 A       open(e) elstds;
760 A       if %error;
760 A         return;
760 A       endif;

       endsr;
      /end-free


       //-----------------------------------------------------------------
       // getSTD - Get Standard for either Route, Transaction or Label
       //-----------------------------------------------------------------

        begsr getSTD;

           // Determine if need standard for label ,trans, or entire route
           pStd=0;
           select;
             when pTran <> 0;
               setll (pTran) label7;
               dow forever = forever;
                 reade (pTran) label7;
                 if %eof(label7);
                   leave;
                 endif;
                 ilbtrn# = t_lbtrn#;
                 pStd = pStd +
                        getSTDval(t_lbwhse:t_lbrte:t_lbwhdp:t_lbstyp:lblkey);
                 return;
               enddo;
             when pRtid <> *blanks;
               chain (pWhse:pRtid) rtehed;
               if not %found(rtehed);
                 pRtnCode = '*INVLDRTE';
                 pRtnMsg = 'Invalid route ' + pRtid;
                 return;
               else;
                 OrdFiles = *off;
                 LblFile = *off;
                 WrkLFile = *off;
                 select;
                   when rhstat<'3';
                     OrdFiles = *on;
                   when rhstat='3';
                     WrkLFile = *on;
                   when rhstat>='4';
                     LblFile = *on;
                 endsl;
               endif;
               select;
                 when OrdFiles;
                   // Use Order files
                   setll (pWhse:pRtid) ordh3;
                   dow forever = forever;
                     reade (pWhse:pRtid) ordh3;
                     if %eof(ordh3);
                       leave;
                     endif;
                     setll (pWhse:ohord) ordd;
                     dow forever = forever;
                       reade (pWhse:ohord) ordd;
                       if %eof(ordd);
                         leave;
                       endif;
                       chain (odwhse:oditem) piritem;
                       if %eof(piritem);
                         itwhdp = ' ';
                         itstyp=' ';
                       endif;
                       iohrtid=ohrte;
                       iodord = odord;
                       iodseq = odseq;
                       ioditem = oditem;
                       pStd = pStd +
                           getSTDval(odwhse:ohrte:itwhdp:itstyp:ordkey);
                     enddo;
                   enddo;
                 when LblFile;
                   // Use Transactions and labels from Label file
                   setll (pWhse:pRtid) label8;
                   dow forever = forever;
                     reade (pWhse:pRtid) label8;
                     if %eof(label8);
                       leave;
                     endif;
                     ilbtrn# = r_l8trn#;
                     pStd = pStd +
                         getSTDval(r_l8whse:r_l8rte:r_l8whdp:r_l8styp:lblkey);
                   enddo;
                   return;
                 when WrkLFile;
                   // Use Transactions and labels from Label file
                   setll (pWhse:pRtid) worklbl1;
                   dow forever = forever;
                     reade (pWhse:pRtid) worklbl1;
                     if %eof(worklbl1);
                       leave;
                     endif;
                     ilbtrn# = lwtrn#;
                     pStd = pStd +
                         getSTDval(lwwhse:lwrte:lwwhdp:lwstyp:lblkey);
                   enddo;
                   return;
               endsl;
             other;
               pRtnCode = '*INVLSTD';
               pRtnMsg = 'Must provide Label, Transaction or Route ' +
                         'for Standard';
           endsl;

        endsr;

       //-----------------------------------------------------------------
       // updSTD - Write/Update Labor Standards
       //-----------------------------------------------------------------

        begsr updSTD;
          // Write/Update ELS Standards file as well as Log file
          if pRtid=*blanks;
              pRtnCode = '*INVRTID';
              pRtnMsg = 'Route Id must be sent';
              return;
          endif;

          chain (pWhse:pRtid) rtehed;
          if %eof(rtehed);
            rhstat='1';
            rhrte = 'INVLD';
          endif;

          // Remove any records from ELS Standard Details with prior
          // Route Status
          exec sql delete from elsstddtl
                  where edwhse=:pWhse and edrtid=:pRtid and edstat<:rhstat;

          // Build looping sql based on parms passed and status
          // Route Id

          // Build SQL
          select;
            when rhstat='1';  // Open Order
              wkutyp = 'N';
              select;
                when odqor1 <> 0;
                  wkutyp='N';
                when odqor2 <> 0;
                  wkutyp='1';
                other;
                  wkutyp='2';
              endsl;
              sqlstmt = 'select itwhdp,itstyp,ohrte,odord,odseq,oditem,' +
                        'odqor1,odqor2,odqor3,' + sq + wkutyp +  sq + ',0,0,' +
                        sq + sq + ',0,0 from ordd,ordh,piritem '    +
                        ' where odwhse=' + %char(pWhse) + ' and ohrte=' +
                        sq + %trim(pRtid) + sq + ' and ohwhse=ohwhse '  +
                        'and odord=ohord and odwhse=itwhse and oditem=ititem' +
                        ' order by itwhdp,itstyp,ohord,odseq,oditem';
                        fileToUse = 'O';
            when rhstat='3';  // Work Label
              sqlstmt = 'select lwwhdp,lwstyp,lwrte,lword,lwseq,' +
                        'lwitem,lwqalc,0,0,lwutyp,0,lwpal#,lwtype,lwlbl#,' +
                        'lwctr# from worklbl ' +
                        ' where lwwhse=' + %char(pWhse) + ' and lwrte=' +
                        sq + %trim(pRtid) + sq +
                        ' order by lwwhdp,lwstyp,lword,lwseq,lwitem';
                        fileToUse = 'W';
            when rhstat>='4'; // Printer status and Beyond
              sqlstmt = 'select lbwhdp,lbstyp,lbrte,lbord,lbseq,' +
                        'lbitem,lbqpck,0,0,lbutyp,lbtrn#,lbpal#,lbtype,' +
                        'lblbl#,lbctr# from label' +
                        ' where lbwhse=' + %char(pWhse) + ' and lbrte=' +
                        sq + %trim(pRtid) + sq + ' and lbtrn#>0';
                        fileToUse = 'L';

              if pTran <> 0;
                sqlStmt = %trim(sqlStmt) + ' and lbtrn#=' + %char(pTran);
              endif;

              sqlStmt = %trim(sqlStmt) + ' order by lbwhdp,lbstyp,lbtrn#';
          endsl;

          exec sql PREPARE ls FROM :SqlStmt;
          exec sql DECLARE lbstd SCROLL CURSOR FOR ls;
          exec sql OPEN lbstd;

          dow forever = forever;
            exec sql fetch next from lbstd into :lsrec;
            if sqlstt <> '00000';
              leave;
            endif;

            // Skip labels with no quantity
            if sqqty1=0 and sqqty2=0 and sqqty3=0;
              iter;
            endif;

            // setup key based on status
            select;
              when fileToUse = 'O';    // Open ORder files
                iohrtid = sqrtid;
                sqrte = rhrte;
                iodord = sqord;
                iodseq = sqseq;
                ioditem = sqitem;
                commonKey = ordkey;
              when fileToUse = 'W';    // Worklbl
                sqrte = rhrte;
                ilbrte = sqrtid;
                ilbtrn# = sqtrn#;
                ilblbl# = sqlbl#;
                commonKey = lblkey;
              when fileToUse = 'L';    // Label
                sqrte = rhrte;
                ilbrte = sqrtid;
                ilbtrn# = sqtrn#;
                ilblbl# = sqlbl#;
                commonKey = lblkey;
            endsl;

            pStd = pStd +
            stdUpdated(pwhse:sqrte:sqrtid:sqwhdp:sqstyp:commonkey:
                       fileToUse:sqtrn#);
            // When at Open Order status and just processed a PIR pick
            // send back through with section type "F" to simulate merge
            // so we project merge goal hours at open order time
            if fileToUse = 'O';
              if sqstyp = 'P' and hldtask='PIR';
                sqstyp = 'M';
                commonkey = %trim(commonkey) + 'M';
                stdUpdated(pwhse:sqrte:sqrtid:sqwhdp:sqstyp:commonkey:
                           fileToUse:sqtrn#);
              endif;
            endif;

          enddo;

          // if Route status is 5 then update all transactions for
          // route to status 5 in Goals file
          if rhstat='5';
            exec sql update elsstddtl set edstat='5'
                    where edwhse=:pWhse and edrtid=:pRtid;
          endif;

          return;

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
     *  getSTDval - Get Standard value for specific Label or Order/Seq
     *----------------------------------------------------------------

     p getSTDval       b

     * Local Files

     Felsstddtl if   e           k disk
     Frtehed    if   e           k disk

     d getSTDval       pi            13p 3
     d  iWhse                         3p 0
     d  iRtid                         5
     d  iWhdp                         5
     d  iStyp                         1
     d  ivarKey                      40

     * Local File Data Structures

     d elsrec          ds                  likerec(edrec: *input)
     d rterec          ds                  likerec(rhrec: *input)

     * Local Variables
     d wkSTDval        s             13p 5

      *
      *   Get Standard for passed in dynamic key
      *

      /free

           // Get route status
           chain (iWhse:iRtid) rtehed rterec;
           if %eof(rtehed);
             rterec.rhstat='1';
           endif;

           wkSTDval=0;
           // Read record from ELSSTDDTL
           chain (iWhse:iRtid:iWhdp:iStyp:rterec.rhstat:ivarKey)
                                                elsstddtl elsrec;
           if %found(elsstddtl);
              wkSTDval = elsrec.edsgoal + elsrec.edrgoal;
           endif;
           return wkSTDval;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  stdUpdated - Update/Write ELS Standards file and Log file
     *----------------------------------------------------------------

     p stdUpdated      b

     * Local Files

     Felsstddtl uf a e           k disk
     Felsstdlog uf a e           k disk

     d stdUpdated      pi            13p 3
     d  iWhse                         3p 0
     d  iRte                          5
     d  iRtid                         5
     d  iWhdp                         5
     d  iStyp                         1
     d  ivarKey                      40
     d  ilabType                      1
     d  iTran                         7s 0

     * Local File Data Structures

     d elsdin          ds                  likerec(edrec: *input)
     d elsdout         ds                  likerec(edrec: *output)
     d elslogO         ds                  likerec(egrec: *output)

     * Local Variables
     d wkSTDval        s             13p 5

      *
      *   Write/Update ELS Standards file along with Log
      *

      /free

           // go Calculate Standard
           wkSTDval = calcSTD (iWhse:iRtid:iWhdp:iStyp:iLabType:ivarKey);

           // update the specific goal time
           chain (iWhse:iRtid:iWhdp:iStyp:rhstat:ivarKey)
                                          elsstddtl elsdin;
           if %found(elsstddtl);
              delete edrec;
            endif;

            // add record
            elsdout.edwhse = iwhse;
            elsdout.edrte = iRte;
            elsdout.edrtid = iRtid;
            elsdout.edwhdp = iWhdp;
            elsdout.edstyp = istyp;
            elsdout.edstat = rhstat;
            elsdout.eddkey = ivarKey;
            // get number of seconds by multiplying goal
            // by 3600 (60 minutes in hour/60 seconds per minute)
            eval(h) elsdout.edsgoal = wkSTDval * 3600;
            elsdout.edtscrt = %timestamp();
              elsdout.edpgmcrt = #pgm;
              elsdout.edjobcrt = #job;
              elsdout.edusrcrt = #user;
              // set additional fields based on status of route
              elsdout.edtask = hldTask;
              elsdout.edlabl = sqlbl#;
              elsdout.edordid = sqord;
              elsdout.edordseq = sqseq;
              elsdout.edorditm = sqitem;
              elsdout.edsqty1 = sqqty1;
              elsdout.edsqty2 = sqqty2;
              elsdout.edsqty3 = sqqty3;
              select;
                when rhstat = '1';
                  elsdout.edtran = *zeros;
                  elsdout.edordid=iodord;
                  elsdout.edordseq=iodseq;
                  elsdout.edorditm=ioditem;
                when rhstat = '3';
                  elsdout.edtran = *zeros;
                when rhstat >= '4';
                  elsdout.edtran = ilbtrn#;
              endsl;
              elsdout.edrqty1 = 0;
              elsdout.edrqty2 = 0;
              elsdout.edrqty3 = 0;
              elsdout.edrgoal = 0;
              // if runner is present and runner found some of
              // the shipped quantity we should breakout
              // ** put in if to only do when rhstat > 4
              chain (pWhse:sqlbl#) runner6;
              if %found(runner6);
                // since runner was found we should modify selector
                // quantities and selector goals and add remainder
                // to runner quantities and runner goals
                if ruqyfd <> 0;
                  if sqqty1 <> 0;
                    // if runner "found quantity" exists we should should
                    // portion of shipped quantity as selector and runner
                    // as runner as well as dividing up the goal properly
                    elsdout.edrgoal = (elsdout.edsgoal / sqqty1) * ruqyfd;
                    elsdout.edrqty1 = ruqyfd;
                    elsdout.edsgoal = elsdout.edsgoal - elsdout.edrgoal;
                    elsdout.edsqty1 = elsdout.edsqty1 - ruqyfd;
                    if elsdout.edsgoal < 0;
                      elsdout.edsgoal = 0;
                    endif;
                    if elsdout.edsqty1 < 0;
                      elsdout.edsqty1 = 0;
                    endif;
                  else;
                    // should not get this far with zero qty but just in case
                    elsdout.edrgoal = 0;
                    elsdout.edsgoal = 0;
                  endif;
                else;
                  // since no runner was found we should zero runner goal
                  elsdout.edrgoal = 0;
                endif;
              else;
              endif;
760 A         if elsdout.edrgoal<>0 or elsdout.edsgoal<>0;
                write edrec elsdout;
760 A         endif;

              // write log record.  All phases of standards are removed
              // up until closing.  At closing the final data is written
              // but these log records remain from beginning to end
              elslogo.egwhse = iwhse;
              elslogo.egrte = iRte;
              elslogo.egrtid = iRtid;
              elslogo.egwhdp = iWhdp;
              elslogo.egstyp = istyp;
              elslogo.egstat = rhstat;
              elslogo.egdkey = ivarKey;
              elslogo.egtscrt = %timestamp();
              elslogo.egpgmcrt = #pgm;
              elslogo.egjobcrt = #job;
              elslogo.egusrcrt = #user;
              elslogo.egtask = hldTask;
              elslogo.eglabl = sqlbl#;
              elslogo.egordid = sqord;
              elslogo.egordseq = sqseq;
              elslogo.egorditm = sqitem;
              elslogo.egsgoal = elsdout.edsgoal;
              elslogo.egrgoal = elsdout.edrgoal;
              elslogo.egsqty1 = elsdout.edsqty1;
              elslogo.egsqty2 = elsdout.edsqty2;
              elslogo.egsqty3 = elsdout.edsqty3;
              elslogo.egrqty1 = elsdout.edrqty1;
              elslogo.egrqty2 = elsdout.edrqty2;
              elslogo.egrqty3 = elsdout.edrqty3;
              select;
                when rhstat = '1';
                  elslogo.egtran = *zeros;
                  elslogo.egordid=iodord;
                  elslogo.egordseq=iodseq;
                  elslogo.egorditm=ioditem;
                when rhstat = '3';
                  elslogo.egtran = *zeros;
                when rhstat >= '4';
                  elslogo.egtran = ilbtrn#;
              endsl;
760 A         if elslogo.egrgoal<>0 or elslogo.egsgoal<>0;
                write egrec elslogo;
760 A         endif;

           return wkSTDval;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  calcSTD - Calculate goal/Standard
     *----------------------------------------------------------------

     p calcSTD         b

     * Local Files

     fpirtrand  if   e           k disk
     fpiritem   if   e           k disk
     felstds    if   e           k disk
     frtehed    if   e           k disk

     d calcSTD         pi            13p 5
     d  iWhse                         3p 0
     d  iRtid                         5
     d  iWhdp                         5
     d  iStyp                         1
     d  ilabType                      1
     d  ivarKey                      40

     * Local File Data Structures

     d elsgoal         ds                  likerec(elsrec: *input)
     d trand           ds                  likerec(ptdrec: *input)
     d rteh            ds                  likerec(rhrec: *input)
     d itm             ds                  likerec(itrec: *input)

     * Local Variables
     d wkGoal          s             13p 5
     d wkstdp          s              8p 4
     d wkumq2          s              3  0
     d wkumq3          s              3  0
     d wkTask          s              6
     d pph             s               n
     d goodRead        c                   00000

      *
      *   Calculate Standard and return
      *

      /free

           wkgoal = 0;
           // get goal time for task
           select;
             when rhstat='1';
               // with order files we will assume Fixed
               // Standard for Fixed and PIR for PIR
               // A "M" is sent back afer processing a
               // PIR item making the assumption we will
               // process the PIR stage, then PIR merge.
               // "M" will be tacked on end of commonkey
               // to force an additional record for merge time
               if iStyp='F' or iStyp='M';
                 hldTask = 'FIXED';
                 if iStyp='M';
                   iStyp='P';
                 endif;
                 chain ('FIXED':iWhse:iWhdp:iStyp) elstds elsgoal;
               else;
                 chain ('PIR':iWhse:iWhdp:iStyp) elstds elsgoal;
                 hldTask = 'PIR';
               endif;
               if %found(elstds);
                 if elsgoal.elpph <> 0;
                   pph = *on;
                   wkstdp = elsgoal.elpph;
                 else;
                   pph = *off;
                   wkstdp = elsgoal.eltph;
                 endif;
                 if pph;
                   // calculate goal time per pieces
                   // get breakdown quantities per a case
                   // since order quantities can be placed for
                   // case quantity or breakdown 1 or 2 quantity
                   chain (iWhse:sqItem) piritem itm;
                   if not %found(piritem);
                     wkumq2=1;
                     wkumq3=1;
                   else;
                     if itm.itumq2<>0;
                       wkumq2=itm.itumq2;
                     else;
                       wkumq2=1;
                     endif;
                     if itm.itumq3<>0;
                       wkumq3=itm.itumq3;
                     else;
                       wkumq3=1;
                     endif;
                   endif;
                   wkgoal = (sqqty1+(sqqty2/wkumq2)+(sqqty3/(wkumq3*wkumq2)));
                   if wkstdp = 0;
                     wkgoal = 0;
                   else;
                     wkgoal = wkgoal / wkstdp;
                   endif;
                   return wkgoal;
                 else;
                   // calculate seconds as goal.  We see what one transaction would take
                   // by dividing by transactions per hour standard.  This equates to a
                   // percentage of an hour.  When returned it is multiplied by 3600 to
                   // get the goal time in seconds
                   wkgoal = (1/wkstdp);
                 endif;
                 return wkgoal;
               else;
                 wkgoal = 0;
               endif;
               return wkgoal;
             when rhstat='3';
               // Determine what Standard to use.  Allocate and Build has
               // not generated transactions so we will make some assumptions
               // based on combination of Department/Section Type/Fixed-PIR-Bulk
               // get goal for specific task
               chain (iWhse:sqItem) piritem itm;
               if not %found(piritem);
                 iItmDept = 'DRY';
               else;
                 iItmDept = itm.itwhdp;
               endif;
               // get pallet to determine if PIR
               setll (iWhse:iRtid:sqplid) pltsum15;
               reade (iWhse:iRtid:sqplid) pltsum15;
               if not %equal(pltsum15);
                 psgen = 1;
               endif;
               select;
                 when iWhdp = '*BULK';
                   wkTask = 'BULKF';
                 when psgen = 2;
                   wkTask = 'PIR';
                 other;
                   wkTask = 'FIXED';
               endsl;
               hldTask = wkTask;
               // allows user to key different standard for merge pieces
               // on generation one pallet
               select;
                 when psgen = 1 and sqltyp = 'M';
                   exec sql select itwhdp into :wkWhdp
                         from piritem where lwitem=:sqitem;
                   if sqlstt='00000';
                     iWhdp = wkwhdp;
                   endif;
                   iStyp = 'P';
               endsl;
               chain (wkTask:iWhse:iItmDept:iStyp) elstds elsgoal;
               if %found(elstds);
                 if elsgoal.elpph <> 0;
                   pph = *on;
                   wkstdp = elsgoal.elpph;
                 else;
                   pph = *off;
                   wkstdp = elsgoal.eltph;
                 endif;
                 if pph;
                   // get breakdown quantities per a case
                   // since order quantities can be placed for
                   // case quantity or breakdown 1 or 2 quantity
                   if not %found(piritem);
                     wkumq2=1;
                     wkumq3=1;
                   else;
                     if itm.itumq2<>0;
                       wkumq2=itm.itumq2;
                     else;
                       wkumq2=1;
                     endif;
                     if itm.itumq3<>0;
                       wkumq3=itm.itumq3;
                     else;
                       wkumq3=1;
                     endif;
                   endif;
                   // Pieces per Hour
                   select;
                     when squtyp = 'N';
                       // normal case quantity.  Just use goal as stated
                       if wkstdp <> 0;
                         wkgoal = sqqty1 / wkstdp;
                       endif;
                     when squtyp = '1';
                       // breakdown one quantity.  Calculate what percentage
                       // of goal
                       if (wkstdp * (sqqty1 / wkumq2)) <> 0;
                         wkgoal = (sqqty1 / wkumq2) / wkstdp;
                       endif;
                     other;
                       // breakdown two quantity
                       if (wkstdp* (sqqty1 / (wkumq2*wkumq3))) <> 0;
                         wkgoal =  (sqqty1 / (wkumq2*wkumq3)) / wkstdp;
                       endif;
                   endsl;
                   return wkgoal;
                 else;
                   // calculate seconds as goal.  We see what one transaction would take
                   // by dividing by transactions per hour standard.  This equates to a
                   // percentage of an hour.  When returned it is multiplied by 3600 to
                   // get the goal time in seconds
                   wkgoal = (1/wkstdp);
                   return wkgoal;
                 endif;
               else;
                 // no goal was found in ELSTDS so return 0
                 return 0;
               endif;
               // get info from LABEL
             when rhstat>='4';
               // get Transaction to get Task
               hldTask = 'INVALD';
               badReadCnt = 0;
               // Since WRTTRAND can physically delete a transaction and rewrite it
               // with after updates we put this program in a loop ensuring the set lower
               // and read equal gets a good read.  If for any reason the read fails
               // we delay one second, and try again.  It will try up to 20 times and
               // then write INVALD as Task at that point which should bring attention
               // because of the task and no goal time, but this would only happen if
               // wrttrand keeps a lock or does not rewrite the record within 20 seconds
               dow forever = forever;
                 setll(e) (sqtrn#) pirtrand;
                 reade(e) (sqtrn#) pirtrand trand;
                 if %status <> goodRead;
                   sleep(1);
                   badReadCnt = badReadCnt + 1;
                   if badReadCnt > 20;
                     leave;
                   else;
                     iter;
                   endif;
760aA            else;
760aA              if trand.ptdstat<'0' and trand.ptdstat>'4';
760aA               iter;
760aA              endif;
                 endif;
                 leave;
               enddo;
               if %equal(pirtrand);
                 hldTask = trand.ptdtask;
                 // get pallet to determine if PIR
                 setll (iWhse:iRtid:sqplid) pltsum15;
                 reade (iWhse:iRtid:sqplid) pltsum15;
                 if not %equal(pltsum15);
                   psgen = 1;
                 endif;
                 select;
                   // allows user to key different standard for merge pieces
                   // on generation one pallet
                   when psgen = 1 and sqltyp = 'M';
                     exec sql select lbwhdp into :wkWhdp
                           from label where lblbl#=:sqctr#;
                     if sqlstt='00000';
                       iWhdp = wkwhdp;
                     endif;
                     iStyp = 'P';
                   when psgen = 2;
                     // generation 2 indicates PIR/Merge Transaction
                     hldTask = 'PIR';
                 endsl;
                 // get goal for specific task
                 chain (hldTask:iWhse:iWhdp:iStyp) elstds elsgoal;
                 if %found(elstds);
                   if elsgoal.elpph <> 0;
                     pph = *on;
                     wkstdp = elsgoal.elpph;
                   else;
                     pph = *off;
                     wkstdp = elsgoal.eltph;
                   endif;
                   if pph;
                      // get breakdown quantities per a case
                      // since order quantities can be placed for
                      // case quantity or breakdown 1 or 2 quantity
                      chain (iWhse:sqItem) piritem itm;
                      if not %found(piritem);
                        wkumq2=1;
                        wkumq3=1;
                      else;
                        if itm.itumq2<>0;
                          wkumq2=itm.itumq2;
                        else;
                          wkumq2=1;
                        endif;
                        if itm.itumq3<>0;
                          wkumq3=itm.itumq3;
                        else;
                          wkumq3=1;
                        endif;
                      endif;
                      // Pieces per Hour
                      select;
                       when squtyp = 'N';
                         // normal case quantity.  Just use goal as stated
                         if wkstdp <> 0;
                           wkgoal = sqqty1 / wkstdp;
                         endif;
                       when squtyp = '1';
                         // breakdown one quantity.  Calculate what percentage
                         // of goal
                         if (wkstdp* (sqqty1 / wkumq2)) <> 0;
760 M                      wkgoal = (sqqty1 + (sqqty2 / wkumq2)) / wkstdp;
                         endif;
                       other;
                         // breakdown two quantity
                         if (wkstdp* (sqqty1 / (wkumq2*wkumq3))) <> 0;
760 M                      wkgoal =  (sqqty1 + (sqqty2/wkumq2) +
760 M                                  (sqqty3/(wkumq2*wkumq3)) / wkstdp);
                         endif;
                      endsl;
                     return wkgoal;
                   else;
                     // calculate seconds as goal.  We see what one transaction would take
                     // by dividing by transactions per hour standard.  This equates to a
                     // percentage of an hour.  When returned it is multiplied by 3600 to
                     // get the goal time in seconds
                     wkgoal = (1/wkstdp);
                   endif;
                   return wkgoal;
                 else;
                   // no goal was found in ELSTDS so return 0
                   return 0;
                 endif;
               else;
                 if debug;
                   wrtDebugParms();
                 endif;
                 return 0;    // Invalid Transaction
               endif;
             other;
               return 0;    // Invalid Route Status
           endsl;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  wrtDebugParms  Write out debug parm record
     *----------------------------------------------------------------

     p wrtDebugParms   b
     d wrtDebugParms   pi

      /free

         bdtype = 'PARMS';

         bdvalues = 'pWhse:' + %char(pWhse) + ', '
                  + 'pCmd:' + %trimr(pCmd) + ', '
                  + 'pRtid:' + %trimr(pRtid) + ', '
                  + 'pTran:' + %char(pTran) + ', '
                  + 'sqTrn#:' + %char(sqTrn#) + ', '
                  + 'sqlbl#:' + %char(sqlbl#) + ', '
                  + 'sqctr#:' + %char(sqctr#) + ', '
                  + 'filestatus:' + %char(%status) + ', '
                  + 'sqltyp:' + %trimr(sqltyp);

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

      /end-free

     p                 e
