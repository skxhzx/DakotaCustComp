      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO)
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  R13000  Update Production Raw Material Summary file
     *  08 Jan 2015
     *  Kenneth Elder
     *
     *  Revisions:
     *
     *    01/08/15  KDE  7.00
     *      - Created.
     *    11/05/15  KDE  7.00a
     *      - Correct the doubling of scrap factor between
     *        M16500 and this program
     *    12/13/15  KDE  7.00b
     *      - Correct normal breakdowns to add scrap to lowest
     *        breakdown level
700cA*    11/15/16  TAB  7.00c
700cA*      - Added code to check wrstat from fril Pkwrkordr
700CA*        for item substitution
700dA*    12/07/16  KDE  7.00d
700dA*      - Changed PRDQTYCONV to use variables from previous
700dA*        record.  Multiple record bills were using wrong values
700eA*    12/13/16  KDE  7.00e
700eA*      - Change the balance text fields to use fixed length.
700eA*        Needed to have min. length for SUBQAVL to work
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     fprmsum    uf a e           k disk
     Fslot3     if   e           k disk
     fplined    if   e           k disk

     *----------------------------------------------------------------
      *  Parameters
     *----------------------------------------------------------------

650aAD  pSessId        s             40    varying
650aAD  pUser          s             10    varying
650aAD  pPgm           s             20    varying
     D  pObjLoc        s             10    varying
     D  pWhse          s              3p 0
     D  pRmItm         s             15    varying
     D  pOutStr        s           1024    varying


650aAD* pSessId        s             40
650aAD* pUser          s             10
650aAD* pPgm           s             20
     D* pObjLoc        s             10
     D* pWhse          s              3p 0
     D* pRmItm         s             15
     D* pOutStr        s           1024

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d avl1            s              9  4
     d avl2            s              9  4
     d avl3            s              9  4
     d BomNegQty       s              5  0
     d BomReq          s              5  0
     d foundBom        s               n
     d hldRm#          s             15
650aAD logText         s            100
     d Newqtyn         s              5  0
     d Newqty1         s              5  0
     d Newqty2         s              5  0
     d NewPrdq         s              9  4
     d newQtyNeg       s               n
     d pMessage        s             99
     d prdSlot         s             12
     D saveVer#        s                   like($ppver#)
     d totdmdq         s              5  0
     d totqtyn         s              5  0
     d totqty1         s              5  0
     d totqty2         s              5  0
     d totprdq         s              9  4
     D wherelabel      s            300
     d wkError         s               n
     d wkRerr2         s             50
     d wkrmdp          s              9  4
     d wkstat          s              1
     d wkqty2          s              5  0
     d wkumq2          s              3  0
     d wkumq3          s              3  0
     d woFound         s               n
     d wrkfgitm        s             15
     d wrkqty          s              5  0
     d wrkwhse         s              3  0
     d wrkwo#          s             13

     *  Division result and remainder data structure

     d divresult       ds
     d  result                        9  4
     d   intresult                    5  0 overlay(result)
     d   intdec                       4  0 overlay(result:*next)

     *  Raw Material SQL Data Struction Record

     d rmsum           ds           121
     d   sqitem                      15    overlay(rmsum)
     d   sqfgi                       15    overlay(rmsum:*next)
     d   sqmake                       4  0 overlay(rmsum:*next)
     d   sqqtyp                       4  0 overlay(rmsum:*next)
     d   sqrmavl                      1    overlay(rmsum:*next)
     d   sqwost                       1    overlay(rmsum:*next)
     d   sqqtyn                       4  0 overlay(rmsum:*next)
     d   sqqty1                       4  0 overlay(rmsum:*next)
     d   sqqty2                       4  0 overlay(rmsum:*next)
     d   sqprdq                       9  4 overlay(rmsum:*next)
     d   sqscrf                       5  4 overlay(rmsum:*next)
     d   sqprimal                     1    overlay(rmsum:*next)
     d   sqsubprme                    2  0 overlay(rmsum:*next)
     d   sqwrst                       1    overlay(rmsum:*next)
     d   sqdesc                      30    overlay(rmsum:*next)
     d   squm2                        2    overlay(rmsum:*next)
     d   squmq2                       3  0 overlay(rmsum:*next)
     d   squm3                        2    overlay(rmsum:*next)
     d   squmq3                       3  0 overlay(rmsum:*next)
     d   sqpuom                       2    overlay(rmsum:*next)
     d   sqippq                       9  4 overlay(rmsum:*next)

     *  Raw Material SQL Data Struction Previous Record

     d rmsump          ds           121
     d   strmsump                    15    overlay(rmsump)
     d   sqfgip                      15    overlay(rmsump:*next)
     d   sqmakep                      4  0 overlay(rmsump:*next)
     d   sqqtypp                      4  0 overlay(rmsump:*next)
     d   sqrmavlp                     1    overlay(rmsump:*next)
     d   sqwostp                      1    overlay(rmsump:*next)
     d   sqqtynp                      4  0 overlay(rmsump:*next)
     d   sqqty1p                      4  0 overlay(rmsump:*next)
     d   sqqty2p                      4  0 overlay(rmsump:*next)
     d   sqprdqp                      9  4 overlay(rmsump:*next)
     d   sqscrfp                      5  4 overlay(rmsump:*next)
     d   sqprimalp                    1    overlay(rmsump:*next)
     d   sqsubprmep                   2  0 overlay(rmsump:*next)
     d   sqwrstp                      1    overlay(rmsump:*next)
     d   sqdescp                     30    overlay(rmsump:*next)
     d   squm2p                       2    overlay(rmsump:*next)
     d   squmq2p                      3  0 overlay(rmsump:*next)
     d   squm3p                       2    overlay(rmsump:*next)
     d   squmq3p                      3  0 overlay(rmsump:*next)
     d   sqpuomp                      2    overlay(rmsump:*next)
     d   sqippqp                      9  4 overlay(rmsump:*next)

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar
     D Up              C                   CONST('ABCDEFGHIJKLMNOPQRST+
     D                                     UVWXYZ')
     D Low             C                   CONST('abcdefghijklmnopqrst+
     D                                     uvwxyz')


     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.wrtsessl
      /COPY *libl/qcopysrc,C#PROD
      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       GUI User
     *      pPgm        GUI dictionary.program
     *      pWhse       Warehouse
     *      Planning fields
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pPgm
     c                   parm                    pObjLoc
     C                   parm                    pWhse
	    c                   parm                    pRmItm
     C                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pMessage = '*OK';

         // Write GLOSESSLOG record
         logText = 'objloc:' + pObjLoc;
         wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);

         select;
           when pObjLoc = 'AFTERACT';
             exsr dltRecords;
             exsr addRecords;
           other;
        endsl;

        pOutStr = '{'
          +  '"pWhse":"'  + %trim(%char(pWhse)) + '",'
          +  '"pMessage":"'  + %trim(pMessage) + '"}';

         return;
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
         $preturn = 'U:' + #status;
         $pmessage = 'U:'
                   + %trim(#pgm)
                   + '('
                   + %trim(%editc(#stmt:'Z'))
                   + ')-'
                   + #pgmmsg;
         pOutStr = '{'
                   +  '"pWhse":"'  + %trim(%char(pWhse)) + '",'
                   +  '"pMessage":"'  + %trim(pMessage) + '"}';
         *inlr = *on;
         return;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  accumTotals  Accumulate totals for each record
     *----------------------------------------------------------------

      /free
       begsr accumTotals;

          totdmdq = totdmdq + (sqmake - sqqtyp);
          totqtyn = totqtyn + sqqtyn;
          totqty1 = totqty1 + sqqty1;
          totqty2 = totqty2 + sqqty2;
          totprdq = totprdq + sqprdq;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  accumInv  Accumulate Inventory totals for Raw Material
     *----------------------------------------------------------------

      /free

       begsr accumInv;

          // get Production line inventory aisle
          setll (pwhse) plined;
          reade (pwhse) plined;
          if not %equal(plined);
             inRcvAisl = 'LIN';
          endif;

          // get available inventory
          avl1=0;
          avl2=0;
          avl3=0;
          setll (pWhse:hldRm#) slot3;
          reade (pWhse:hldRm#) slot3;
          dow not %eof(slot3);
             if slstat = 'A ' or slaisl = inRcvAisl;
                exsr avail;  // add to available stock from warehouse
                avl1 += avail1;
                avl2 += avail2;
                avl3 += avail3;
             endif;
             reade (pWhse:hldRm#) slot3;
          enddo;

          // up total available inventory to highest uom
          newqtyn = avl1;
          newqty1 = avl2;
          newqty2 = avl3;
          exsr zzupqty;

          // build proper inventory field based on breakdown definition
          select;
           when squm3p <> ' ';
700eM       smavlq=%char(newqtyn) + '.' + %subst(%editw(newqty1:'0     '):4:3) +
700eM                    '.' + %subst(%editw(newqty2:'0     '):4:3);
          when squm2p <> ' ';
700eM      smavlq = %char(newqtyn) + '.' + %subst(%editw(newqty1:'0     '):4:3);
             other;
700eM           smavlq = %char(newqtyn) + '.000';
          endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  addRecords  Add records to Raw Material Summary file
     *----------------------------------------------------------------

      /free
       begsr addRecords;

          sqlStmt = 'Select writem,wrfgi,womake,woqtyp,' +
                    'wormavl,wostat,wrqtyn,wrqty1,' +
                    'wrqty2,wrprdq,wrscrf,wrprimal,' +
                    'wrsubprme,wrstat,itdesc,itum2,' +
                    'itumq2,itum3,itumq3,ippuom,ipprdq';
          sqlStmt = %trim(sqlStmt) + ' from ' +
                    'pwrkOrd, pWrkOrdr, pirItem, itemprd ';

          // build joins in Where Clause
          wherelabel = 'where wowhse=wrwhse' +
                       ' and wowo#=wrwo# ' +
                       ' and wrwhse = itwhse ' +
                       ' and writem = ititem' +
                       ' and itwhse = ipwhse ' +
                       ' and ititem = ipitem ';

          // append normal selections to where clause
          wherelabel = %trim(wherelabel) +
                       ' and wrwhse = ' + %char(pWhse) +
          //           ' and wormavl = ' + sq + 'N' + sq +
                       ' and wostat <> ' + sq + 'C' + sq +
                       ' and wostat <> ' + sq + 'D' + sq +
700cA                  ' and wrstat <> ' + sq + 'C' + sq +
700cA                  ' and wrstat <> ' + sq + 'D' + sq;

          if pRmItm <> '';
             // if item was sent then include in selection
             wherelabel = %trim(wherelabel) +
                         ' and writem = ' + sq + pRmItm + sq;
          endif;

          // append join information and data selection to select
          sqlStmt = %trim(sqlStmt) + ' ' +
                     %trim(whereLabel);

          // append order by to select clause
          sqlStmt = %trim(sqlStmt) + ' order by wrwhse,writem,itdesc';

          exec sql PREPARE sel FROM :SqlStmt;
          exec sql DECLARE RMSummary SCROLL CURSOR FOR SEL;
          exec sql OPEN RMSummary;
          exec sql
            fetch next from RMSummary into :rmsum;

          if sqlstt = '00000';
            hldRm# = sqItem;
            dow sqlstt = '00000';
               if hldRm# <> sqItem;
                  exsr AccumInv;
                  exsr writerecs;
               endif;
               rmsump = rmsum;
               exsr AccumTotals;
               exec sql
                 fetch next from RMSummary into :rmsum;
            enddo;

            // create record for last summary if one exists
            if totdmdq <>0 or totqtyn<>0 or totqty1<>0
                           or totqty2<>0 or totprdq<>0;
               exsr accumInv;
               exsr writerecs;
            endif;

          else;
             if sqlstt = '02000';   // eof..no records
                // no records exist
                pMessage = 'No Raw Materials short based on current ';
                pMessage = %trim(pMessage) + ' planning';
             else;
                // return error that SQL failed
                pMessage = 'SQL error ' + sqlstt + ' occurred.  No Updates';
             endif;
          endif;
          exec sql CLOSE RMSummary;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  AVAIL   Calculate available quantities for slot.
     *
     *----------------------------------------------------------------
     C     avail         begsr
     *
     *  Call program to calculate availabe slot quantities.
     *
     C                   call      'SLOTQTY'
     C                   parm                    slstk1
     C                   parm                    slstk2
     C                   parm                    slstk3
     *
     C                   parm                    slalc1
     C                   parm                    slalc2
     C                   parm                    slalc3
     *
     C                   parm                    sltfr1
     C                   parm                    sltfr2
     C                   parm                    sltfr3
     *
     C                   parm                    slpck1
     C                   parm                    slpck2
     C                   parm                    slpck3
     *
     C                   parm                    slrcv1
     C                   parm                    slrcv2
     C                   parm                    slrcv3
     *
     C                   parm                    stock1            5 0
     C                   parm                    stock2            3 0
     C                   parm                    stock3            3 0
     *
     C                   parm                    avail1            5 0
     C                   parm                    avail2            3 0
     C                   parm                    avail3            3 0

     *  Call program to get open Directed Putaway quantity.

     C                   call      'CHKOPNDP'
     C                   parm      slwhse        dWhse             3 0
     C                   parm      slwhdp        dWhdp             5
     C                   parm      sldisp        dDisp            12
     C                   parm      slitem        dItem            15
     C                   parm                    dTotal            3 0
     C                   parm                    dItmTtl           3 0
     C                   parm                    dQty1             5 0
     C                   parm                    dQty2             5 0
     C                   parm                    dQty3             5 0

     C                   eval      avail1 += dQty1
     C                   eval      avail2 += dQty2
     C                   eval      avail3 += dQty3

     *  Set negative quantities to zero

     C                   if        avail1 < 0
     C                   eval      avail1 = 0
     C                   endif
     C                   if        avail2 < 0
     C                   eval      avail2 = 0
     C                   endif
     C                   if        avail3 < 0
     C                   eval      avail3 = 0
     C                   endif
     C                   endsr

     *----------------------------------------------------------------
     *  bomReduction  -  Determine how many FG to reduce to
     *                   eliminate negative raw material inventory
     *----------------------------------------------------------------

      /free

       begsr bomReduction;

          // determine number of finished goods must reduce by work
          // order to eliminate raw material negative
          if %trim(smavlp) = '';
             smavlp = '      .0000';
          endif;
          if %trim(smreqp) = '';
             smreqp = '      .0000';
          endif;

          if sqippqp <> 0;
             if (%dec(smavlp:9:0) - %dec(smreqp:9:0)) < 0;
                wkrmdp = %dec(smavlp:9:0) - %dec(smreqp:9:0);
                smreduce = %abs(wkrmdp);
             else;
                smreduce = 0;
             endif;
          else;              // normal inventory breakdown item
          // bomreq = ((bmQtyn * squmq2p * squmq3p) +
          //           (bmqty1 * squmq3p) +
          //            bmqty2);
          // if bomreq = 0;
          //    bomreq = 1;
          // endif;
             smreduce = bomnegqty;
          endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  dltRecords  Delete records for this Session if exists
     *----------------------------------------------------------------

      /free

       begsr dltRecords;


          if pRmItm <> '';
             // if item was sent delete only that raw material
             exec sql delete from PRMSUM
                  where smSessid = :pSessId and smitem = :pRmItm;
          else;
             exec sql delete from PRMSUM
                  where smSessid = :pSessId;
          endif;

       endsr;

      /end-free

     *----------------------------------------------------------------
     *  formatReq  Format Required Raw Materials Total
     *----------------------------------------------------------------

      /free

       begsr formatReq;

          // if planned in production quantity convert to warehouse qty
          if totprdq <> 0;
             eval(h) totprdq = ((totprdq)*(1+sqscrfp));
             exsr prdqtyConv;
          else;
             // add scrap factor to requirements
700b         // roll to lowest level, add scrap and
700b         // roll back up to highest uom
700b         if squmq3p=*zeros;
700b            squmq3p=1;
700b         endif;
700b         if squmq2p=*zeros;
700b            squmq2p=1;
700b         endif;
700b         eval wkqty2 = totqtyn*squmq2p*squmq3p;
700b         eval wkqty2 = wkqty2 + totqty1*squmq3p;
700b         eval wkqty2 = wkqty2 + totqty2;
700b         eval totqtyn=*zeros;
700b         eval totqty1=*zeros;
700b         eval totqty2=wkqty2*(1+sqscrfp);
700b    //   eval(h) totqtyn = ((totqtyn)*(1+sqscrfp));
700b    //   eval(h) totqty1 = ((totqty1)*(1+sqscrfp));
700b    //   eval(h) totqty2 = ((totqty2)*(1+sqscrfp));
          endif;


          // up required totals to highest uom
          newqtyn = totqtyn;
          newqty1 = totqty1;
          newqty2 = totqty2;
          exsr zzupqty;

          // build proper required field based on breakdown definition
          select;
           when squm3p <> ' ';
700eM      smreqq=%char(newqtyn) + '.' + %subst(%editw(newqty1:'0     '):4:3) +
700eM                   '.' + %subst(%editw(newqty2:'0     '):4:3);
           when squm2p <> ' ';
700eM       smreqq=%char(newqtyn) + '.' + %subst(%editw(newqty1:'0     '):4:3);
             other;
700eM           smreqq = %char(newqtyn) + '.000';
          endsl;

          // raw materials requirements in production uom terms
          if sqippqp <> 0;
             smreqp = %editc(totprdq:'P');
          else;
             smreqp = '      .0000';
          endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  formatRem  Format Remaining Inventory Total
     *----------------------------------------------------------------

      /free

       begsr formatRem;

          newqtyneg = *off;
          smRmdq = ' ';
          select;
             when squmq3p <> 0;
                newqty2 = ((avl1*squmq2p*squmq3p) +
                     (avl2*squmq3p) +
                     avl3) -
                    ((totqtyn*squmq2p*squmq3p) +
                     (totqty1*squmq3p) +
                     totqty2);
                if sqippqp <> 0;
                  smavlp=%editc(((avl1*squmq2p*squmq3p)+(avl2*squmq3p)+avl3)
                           * (sqippqp / (squmq2p*squmq3p)):'P');
                else;
                  smavlp = '      .0000';
                endif;
                if newqty2 < 0;
                   newqtyneg = *on;
                   newqty2 = %abs(newqty2);
                   bomnegqty = newqty2;
                   exsr bomreduction;
                else;
                   newqtyneg = *off;
                endif;
                newqty1 = 0;
                newqtyn = 0;
                exsr zzupqty;
             when squmq2p <> 0;
                newqty1 = ((avl1*squmq2p) + avl2) -
                          ((totqtyn*squmq2p) + totqty1);
                if sqippqp <> 0;
                   smavlp = %editc(((avl1*squmq2p) + avl2)
                              * (sqippqp / squmq2p):'P');
                else;
                   smavlp = '      .0000';
                endif;
                if newqty1 < 0;
                   newqtyneg = *on;
                   newqty1 = %abs(newqty1);
                   bomnegqty = newqty2;
                   exsr bomreduction;
                else;
                   newqtyneg = *off;
                endif;
                newqty2 = 0;
                newqtyn = 0;
                exsr zzupqty;
             other;
                if sqippqp <> 0;
                   smavlp = %editc((avl1 * sqippqp):'P');
                else;
                   smavlp = '      .0000';
                endif;
                newqtyn = avl1 - totqtyn;
                exsr bomReduction;
          endsl;

          // build proper Remaining inv. field on breakdown definition
          if newqtyNeg;
             smrmdq = '-';
          endif;

          select;
             when squm3p <> ' ';
                smrmdq = %trim(smrmdq) +
700eM             %char(newqtyn) + '.' + %subst(%editw(newqty1:'0     '):4:3) +
700eM                    '.' + %subst(%editw(newqty2:'0     '):4:3);
             when squm2p <> ' ';
                smrmdq = %trim(smrmdq) +
700eM             %char(newqtyn) + '.' + %subst(%editw(newqty1:'0     '):4:3);
             other;
700eM           smrmdq = %char(newqtyn) + '.000';
          endsl;
          if sqippqp <> 0;
             if %dec(smreqp:9:0) <> 0;
                wkrmdp = %dec(smavlp:9:0) - %dec(smreqp:9:0);
             endif;
             smrmdp = %editc(wkrmdp:'P');
          else;
             smrmdp = '      .0000';
          endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  PrdQtyConv - Convert Production Quantity to Dakota Quantity
     *----------------------------------------------------------------

      /free
       begsr PrdQtyConv;

          // when an item is planned via Production Quantity this
          // this routine is called to convert Production quantity
          // breakdown to the lowest level of normal Dakota breakdown.
          if sqIpPqp <> 0;
             // convert to lowest unit of measure per the
             // normal Dakota breakdowns
             select;
                when squmq3p<>0 and squmq2p<>0;
                   eval(h) result = sqIpPqp / (squmq3p*squmq2p);
                   select;
                     when result > 0;
                        eval(h) totqty2 = totqty2 + (totPrdq / result)+.49;
                     when result < 0;
                        eval(h) totqty2 = totqty2 + (totPrdq / result)-.49;
                   endsl;
                when squmq2p<>0;
                   eval(h) result = sqIpPqp / squmq2p;
                   select;
                     when result > 0;
                        eval(h) totqty1 = totqty1 + (totPrdq / result)+.49;
                     when result < 0;
                        eval(h) totqty1 = totqty1 + (totPrdq / result)-.49;
                   endsl;
                other;
                   select;
                     when totPrdq > 0;
700dD          //      eval(h) totqtyn = totqtyn + (totPrdq / sqIpPq)+.49;
700dA                  eval(h) totqtyn = totqtyn + (totPrdq / sqIpPqp)+.49;
                     when totPrdq < 0;
700dD         //       eval(h) totqtyn = totqtyn + (totPrdq / sqIpPq)-.49;
700dA                  eval(h) totqtyn = totqtyn + (totPrdq / sqIpPqp)-.49;
                   endsl;
             endsl;
          endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  writeRecs  Write session records for Production Raw Materials
     *----------------------------------------------------------------

      /free

       begsr writerecs;

          // format required quantity field
          exsr formatreq;
          // calculate and format remaining inventory field
          exsr formatrem;
          // define fields for summary raw material record
          smSessid = pSessId;
          smWhse = pWhse;
          smItem = hldRm#;
          smdmdq = totdmdq;
          smprodq = '      .0000';
          smbaseq = '0.000';
          smspsize = *zeros;
          smgrpts = %timestamp();
          write smrec;

          // initialize total fields for next item
          hldRm# = sqitem;
          totdmdq=0;
          totqtyn=0;
          totqty1=0;
          totqty2=0;
          totprdq=0;

       endsr;

      /end-free

     *----------------------------------------------------------------
     *  ZZUPQTY       Up quantity
     *----------------------------------------------------------------

     C     zzupqty       begsr

     C                   dow       squmq3p > 0 and +
     C                               newqty2 >= squmq3p
     C                   eval      newqty2 -= squmq3p
     C                   eval      newqty1 += 1
     C                   enddo

     C                   dow       squmq2p > 0 and +
     C                               newqty1 >= squmq2p
     C                   eval      newqty1 -= squmq2p
     c                   eval      newqtyn += 1
     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  zzdriCop   Call DRICOP
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
     c                   eval      pMessage  = 'Error occured on call to '
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
