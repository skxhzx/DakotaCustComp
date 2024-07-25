      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO)
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M16000  Production Item Maintenance
     *  30 Oct 2014
     *  Kenneth Elder
     *
     *  Revisions:
     *
     *    10/30/14  KDE  6.50
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     Fpiritem   uf   e           k disk
     Fitemmsc   if   e           k disk
     Fplined    if   e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D iprec         E ds                  extname(itemprd) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  pSessId        s             40
     D  pUser          s             10
     D  pPgm           s             20
     D  pObjLoc        s             10
     D  pSubCmd        s              1
     D  pWhse          s              3  0
	    d  pItem          s             15
	    d  pItmTyp        s              1
     D  pLine          s              3  0
	    d  pPrdTyp        s              1
	    d  pBdUOM1        s              2
     D  pBdQty1        s              3  0
	    d  pBdUOM2        s              2
     D  pBdQty2        s              3  0
	    d  pPUOM          s              2
     D  pPRDQ          s              9  4
     D  pBrkR          s              1

     *----------------------------------------------------------------
     *  Date Convert/Check data
     *
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
     *  Variables
     *----------------------------------------------------------------

650aAD logText         s            100
     D saveVer#        s              2s 0
     d wkError         s               n
     d wkRerr2         s             50

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

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.wrtsessl

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       GUI User
     *      pPgm        GUI dictionary.program
     *      pWhse       Warehouse
     *      ITEMPRD     fields
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pPgm
     c                   parm                    pObjLoc
     c                   parm                    pSubCmd
     C                   parm                    pWhse
	    c                   parm                    pItem
	    c                   parm                    pItmTyp
	    c                   parm                    pLine
	    c                   parm                    pPrdTyp
	    c                   parm                    pBDUOM1
	    c                   parm                    pBDQty1
	    c                   parm                    pBDUOM2
	    c                   parm                    pBDQty2
	    c                   parm                    pPUOM
	    c                   parm                    pPRDQ
	    c                   parm                    pBrkR

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         // Set SQL default parms
         exec sql
           set Option Commit=*none, Dlyprp=*Yes,
                      Closqlcsr = *ENDMOD;

         *inlr = *on;
         pMessage = ' ';

         // Write GLOSESSLOG record
         logText = 'objloc:' + pObjLoc;
         wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);

         select;
           when pObjLoc = 'FLDVALID';
             exsr FldValid;
           when pObjLoc = 'AFTERACT';
             exsr AfterAct;
           other;
             pMessage = 'Invalid object location sent: '
                      + %trim(pObjLoc)
                      + ' (' + %trim(#pgm) +')';
         endsl;

         return;
      /end-free

     *----------------------------------------------------------------
     *  AddRec    Add record
     *----------------------------------------------------------------

      /free
       begsr AddRec;

         error = *off;
         exsr FillRec;

         exec sql insert into itemprd values(:iprec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Item(' + %trim(pItem) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
            // update item master uom and bd qtys
            chain (pwhse: pitem) piritem;
            if %found(piritem);
              itum2 = pbduom1;
              itumq2 = pbdqty1;
              itum3 = pbduom2;
              itumq3 = pbdqty2;
              update itrec;
            else;
              unlock piritem;
            endif;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AfterAct     After action update
     *----------------------------------------------------------------

      /free
       begsr AfterAct;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DelRec - Delete record
     *----------------------------------------------------------------

      /free
       begsr DelRec;

         error = *off;

         // delete suggestion record

         exec sql delete from itemprd
                  where ipwhse = :pwhse
                    and ipitem = :pitem;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Item(' + %trim(pItem) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  errorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

         // Error if Add and item exists in ITEMPRD

         if pSubCmd = 'A' and found;
            pMessage = 'Item already defined as Production item '
                     + '(' + %trim(pitem) + ')';
            error = *on;
            leavesr;
         endif;

         // Item must exist in PIRITEM

         chain(n) (pwhse:pitem) piritem;
         if not %found(piritem);
            pMessage = 'Item does not exist (' + %trim(pitem) + ')';
            error = *on;
            leavesr;
         endif;

         // UOM 1 and Qty must exist in pairs

         if pbduom1 <> ' ' and pbdqty1 = 0;
            pMessage = 'Breakdown 1 UOM invalid without quantity';
            error = *on;
            leavesr;
         endif;

         if pbduom1 = ' ' and pbdqty1 <> 0;
            pMessage = 'Breakdown Qty 1 quantity invalid without UOM';
            error = *on;
            leavesr;
         endif;

         if pbdqty1 < 0;
            pMessage = 'Breakdown 1 quantity must be greater than zero';
            error = *on;
            leavesr;
         endif;

         // UOM 2 and Qty must exist in pairs

         if pbduom2 <> ' ' and pbdqty2 = 0;
            pMessage = 'Breakdown 2 UOM invalid without quantity';
            error = *on;
            leavesr;
         endif;

         if pbduom2 = ' ' and pbdqty2 <> 0;
            pMessage = 'Breakdown Qty 2 quantity invalid without UOM';
            error = *on;
            leavesr;
         endif;
710
710      if (pbduom2 <> ' ' or pbdqty2 <> 0) and
710          (pbduom1 = *blanks or pbdqty2=0);
710         pMessage = 'Breakdown 1 must exist to define Breakdown 2';
710         error = *on;
710         leavesr;
710      endif;

         if pbdqty2 < 0;
            pMessage = 'Breakdown 2 quantity must be greater than zero';
            error = *on;
            leavesr;
         endif;

         // Item type must be either (F) FG or (R) RM

710bD    // if pItmTyp <> 'F' and pItmTyp <> 'R';
710bD    //   pMessage = 'Production Item Type must be either be '
710bD    //            + 'Finished Good or Raw Material';
710bA    if pItmTyp <> 'F' and pItmTyp <> 'R' and pItmtyp <> 'C';
710bA       pMessage = 'Production Item Type must be either be '
710bA                + 'Finished Good, Raw Material or Component';
            error = *on;
            leavesr;
         endif;

         // mfg line number must be valid for finished good item

         if pItmTyp = 'F';
           chain (pwhse:pline) plined;
           if not %found(plined);
             pMessage = 'Mfg Line must be valid';
             error = *on;
             leavesr;
           endif;
         endif;

         // Validate production category for finished good item

         if pItmTyp = 'F';
           if pPrdTyp <> 'M' and pPrdTyp <> 'P';
             pMessage = 'Production Category must be either be '
                      + 'Meat or Produce';
             error = *on;
             leavesr;
           endif;
         endif;

         // Ensure that raw material changes are not allowed while
         // active work orders exist.

         if pItmTyp = 'R';

            exec sql update pWrkOrdr set wrwhse=:pWhse
                            where wrwhse=:pWhse and
                                  writem = :pItem
                                  and wrstat<>'C' and wrstat<>'D';
            if sqlStt = '00000';
               pMessage = 'Changes cannot be made to the Raw Material ' +
                          'while active Work Orders exist.';
               error = *on;
               leavesr;
            endif;

         endif;

         // Prod UOM and Qty must exist in pairs

         if pPUOM <> ' ' and pPRDQ = 0;
            pMessage = 'Production Brkdn UOM invalid without quantity';
            error = *on;
            leavesr;
         endif;

         if pPUOM = ' ' and pPRDQ <> 0;
            pMessage = 'Production Brkdn quantity invalid without UOM';
            error = *on;
            leavesr;
         endif;

         if pPRDQ < 0;
            pMessage = 'Production quantity must be greater than zero';
            error = *on;
            leavesr;
         endif;

         // Prod UOM cannot be same as Dakota UOM's

         if pPUOM <> '';
           if pPUOM = itum1
             or  pPUOM = pbdUom1
             or  pPUOM = pbdUom2;
                pMessage = 'Production Brkdn UOM cannot be the same as  '
                         + 'a Inventory UOM';
                error = *on;
                leavesr;
           endif;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillRec   Fill record fields
     *----------------------------------------------------------------

      /free
       begsr FillRec;

	        ipwhse = pwhse;
	        ipitem = pitem;
	        ipprdflg = pitmtyp;
	        select;
	          when ipprdflg = 'F';
	            ipmfgno = pline;
             ipmorp = pprdtyp;
             ippuom = ppuom;
             ipprdq = pprdq;
             ipbrkr = pbrkr;
	          when ipprdflg = 'R';
	            ipmfgno = 0;
             ipmorp = '';
             ipbrkr = pbrkr;
             ippuom = ppuom;
             ipprdq = pprdq;
	        endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FldValid   Validate fields
     *----------------------------------------------------------------

      /free
       begsr FldValid;

         // See if ITEMPRD record exists for item

         exsr GetRec;

         error = *off;

         // Validate input

         exsr errorcheck;
         if error;
           leavesr;
         endif;

         select;

           // Add

           when pSubCmd = 'A';
             if found;
               exsr UpdRec;
             else;
               exsr AddRec;
             endif;

           // Change

           when pSubCmd = 'U' or pSubCmd = 'C';
             if found;
               exsr UpdRec;
             else;
               exsr AddRec;
             endif;

           // Delete

           when pSubCmd = 'D';
             if found;
               exsr DelRec;
             endif;

           other;
             pMessage = 'Invalid command sent: ' + pSubCmd
                      + %trim(pSubCmd)
                      + ' (' + %trim(#pgm) +')';
         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetRec    Get record
     *----------------------------------------------------------------

      /free
       begsr GetRec;

         found = *off;

         exec sql select * into :iprec
                  from itemprd
                  where ipwhse = :pwhse
                    and ipitem = :pitem;

         if sqlstt = sqlSuccess;
           found = *on;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  UpdRec    Update record
     *----------------------------------------------------------------

      /free
       begsr UpdRec;

         error = *off;

         exsr FillRec;

         exec sql update itemprd
                  set ipprdflg = :ipprdflg, ipmfgno = :ipmfgno,
                      ipmorp = :ipmorp, ippuom = :ippuom,
                      ipprdq = :ipprdq, ipbrkr = :ipbrkr
                  where ipwhse = :pwhse
                    and ipitem = :pitem;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Item(' + %trim(pItem) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
            // update item master uom and bd qtys
            chain (pwhse: pitem) piritem;
            if %found(piritem);
               itum2 = pbduom1;
               itumq2 = pbdqty1;
               itum3 = pbduom2;
               itumq3 = pbdqty2;
               update itrec;
            else;
               unlock piritem;
            endif;
         endif;

       endsr;
      /end-free
