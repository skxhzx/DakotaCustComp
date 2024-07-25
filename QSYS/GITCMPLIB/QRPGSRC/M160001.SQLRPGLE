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
700 A*    01/09/17  KDE  7.00
     *      - Changed to prevent orphan records between UOM on item master
     *        and Primal/SubPrimal definitions
710 A*    01/20/17  KDE  7.10
     *      - Prevent changes to Raw Materials while active work orders
     *        exist.  Also prevent user from eliminating an UOM that
     *        is used on any BOM
710 A*    02/02/17  KDE  7.10a
     *      - Added field IPUSEP to ITemprd.
     *
710bA*    02/09/17  TAB  7.10b
     *      - Added new item type of Component
     *      - Added logic for Mfg Shelf Life Dates to ITEMPRD
     *      - Added logic for Multiple Production Days Required
     *
750 A*    02/11/22  KDE  7.50
     *      - Added code to prevent changing item from FG to RM when
     *        Bill of Material exist
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRYaA*    05/01/17  KDE  DRYa
     *      - Revised Expiration Calculation routine to send zero
     *        as Expiration date when Mfg Shelf Life Days is either
DRYbA*        zero or Mfg Shelf Life Days is less than combination
     *        of User and Distribution days
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     Fpiritem   uf   e           k disk
     Fitemmsc   if   e           k disk
     Fplined    if   e           k disk
750 AfpBom      if   e           k disk
700 AfpPrimal   if   e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D iprec         E ds                  extname(itemprd) inz(*EXTDFT)
700 AD isrec         E ds                  extname(ItemPRdPs) inz(*EXTDFT)

DRYaA *----------------------------------------------------------------
DRYaA *  Customer id
DRYaA *----------------------------------------------------------------

DRYaA /copy qcopysrc,ID#DAIRYLA

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
710 AD  pUsep          s              1
710 AD  pMday          s              3  0
710bAD  pMulti         s              1

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
710 Ac                   parm                    pUsep
710bAc                   parm                    pMday
710bAc                   parm                    pMulti
DRYaAC*
DRYaAC                   call      'GETCLIENT'
DRYaAC                   parm                    client           10
DRYaAC                   parm                    clientloc        10

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

DRYaA    // Allow Dairyland to specify zeros for Mfg Shelf Life Days
DRYaA    // for PRoduction which will allow for Zero Expiration Date
DRYaA    if client <> 'DAIRYLAND' and pSubCmd<>'D';
710bA       chain(n) (pwhse: pitem) piritem;
710bA       // If item is "C" or "F" type and Date sensitive it must
710bA       // have value greater than zero and greater than user days
710bA       if (pItmTyp='F' or pItmTyp='C') and itflgd='Y'
710bA             and pMday = *zeros;
710bA          pMessage = 'You must specify Mfg Shelf Life Days '
710bA                   + 'for date sensitive item';
710bA          error = *on;
710bA          leavesr;
710bA       endif;
DRYaA    endif;

710bA    // If date sensitive item ype and Date sensitive it must
710bA    // have value greater than zero and greater than user days
710bA    chain (pWhse:pItem) itemmsc;
710bA    if (pItmTyp='F' or pItmTyp='C') and
710bA          pMday <> *zeros and (imuday+imdday) >= pMday;
710bA       pMessage = 'Mfg Shelf Days(' + %char(pMday) + ') must exceed '
710bA                + 'User/Dist Days(' + %char(imuday+imdday) +
                     ') to proceed';
710bA       error = *on;
710bA       leavesr;
710bA    endif;

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

710bD    // if pItmTyp = 'F';
710bA    if pItmTyp = 'F' or pItmTyp = 'C';
           chain (pwhse:pline) plined;
           if not %found(plined);
             pMessage = 'Mfg Line must be valid';
             error = *on;
             leavesr;
           endif;
         endif;

         // Validate production category for finished good item

710bD    // if pItmTyp = 'F';
710bA    if pItmTyp = 'F' or pItmTyp = 'C';
           if pPrdTyp <> 'M' and pPrdTyp <> 'P';
             pMessage = 'Production Category must be either be '
                      + 'Meat or Produce';
             error = *on;
             leavesr;
           endif;
         endif;

         // Ensure that raw material changes are not allowed while
         // active work orders exist.

710bD    // if pItmTyp = 'R';
710bA    if pItmTyp = 'R' or pItmTyp = 'C';

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

         if pPUOM <> '' and pSubCmd<>'D';
           if pPUOM = itum1
             or  pPUOM = pbdUom1
             or  pPUOM = pbdUom2;
                pMessage = 'Production Brkdn UOM cannot be the same as  '
                         + 'a Inventory UOM';
                error = *on;
                leavesr;
           endif;
         endif;
750 A    // Cannot change to R Raw MAterial if BOM exists
750 A    if pItmTyp = 'R';
750 A      setll (pWhse:pItem) pbom;
750 A      reade (pWhse:pItem) pBom;
750 A      if %equal(pBom);
750 A        pMessage = 'BOM must be removed before changing to a  '
750 A                 + 'Raw Material type';
750 A        error = *on;
750 A        leavesr;
750 A      endif;
750 A    endif;
700 A
700 A    // If raw material then ensure that no Primal/SubPrimal definitions
700 A    // exist where the Factor UOM on the Primal definition is not represent
700 A    // on the Item master under one of the UOM's
700 A    if pItmTyp = 'R';
700 A       SqlStmt = 'Select * from itemprdps' +
700 A               ' where iswhse = ' + %char(pWhse) +
700 A               ' and isrmi = ' + sq + pItem + sq;
700 A
700 A      exec sql PREPARE subPrim FROM :SqlStmt;
700 A      exec sql DECLARE ItemPrdPs SCROLL CURSOR FOR subPrim;
700 A      exec sql OPEN ItemPrdPs;
700 A
700 A      exec sql
700 A       fetch first from ItemPrdps into :isrec;
700 A       dow sqlstt = '00000';
700 A          chain (iswhse:isline:ispcde) pPrimal;
700 A          if not %found(pPrimal);
700 A             ppFacUom = *blanks;
700 A          endif;
700 A          // if primal has size uom then make sure it matches one
700 A          // of the uom's defined on the raw material
700 A          if pptypfac <> 9999.99      // overrides Primal/SubPrimal definit
700 A             and ppfacuom <> itum1 and ppfacuom <> pBDUom1 and
700 A             ppfacuom <> pBDUom2 and ppfacuom <> pPUOM;
700 A             pMessage = 'Primal definitions exist without ' +
700 A                     'the Factor UOM matching at least one of ' +
700 A                     'the item UOMs';
700 A             error = *on;
700 A             leavesr;
700 A          endif;
700 A          exec sql
700 A           fetch next from ItemPrdps into :isrec;
700 A       enddo;
700 A      exec sql Close ItemPrdPs;
700 A    endif;

710 A     // prevent user from eliminating a UOM that is used on active BOM's.
710 A     // In order to eliminate the BOMs will have to be changed to no
710 A     // longer include this BOM.  Also ensure no active Work Orders
710 A
710 A     // 710bD  if pItmTyp = 'R';  // Raw MAterial
710bA     if pItmTyp = 'R' or pItmTyp = 'C';  // Raw MAterial or Component
710 A      exec sql update pbom set bmwhse=bmwhse
710 A           where bmwhse=:pWhse and bmrmi=:pItem
710 A             and ((bmqty1<>0 and :pbdqty1=0) or
710 A                  (bmqty2<>0 and :pbdqty2=0) or
710 A                  (bmprdq<>0 and :pPrdq=0));
710 A
710 A      if sqlStt = '00000';
710 A       pMessage = 'UOM currently being used on Active BOMS.  Please' +
710 A                  ' correct and come back to process change';
710 A       error = *on;
710 A       leavesr;
710 A      else;
710 A         // If no boms are using changed item UOMs confirm no
710 A         // no Active Work Orders are using as well
710 A         exec sql update pwrkOrdr set wrwhse=wrwhse
710 A              where wrwhse=:pWhse and writem=:pItem
710 A                and wrstat<>'C' and wrstat<>'D'
710 A                and ((wrqty1<>0 and :pbdqty1=0) or
710 A                     (wrqty2<>0 and :pbdqty2=0) or
710 A                     (wrprdq<>0 and :pbdqty2=0));
710 A
710 A         if sqlStt = '00000';
710 A            pMessage = 'UOM currently being used on Active Work Orders.' +
710 A                     ' Come back to change once closed.';
710 A            error = *on;
710 A            leavesr;
710 A         endif;
710 A      endif;
710 A     endif;
710 A
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
710bA        ipmday = pMday;
710bA        ipmulti= pmulti;
	          when ipprdflg = 'R';
	            ipmfgno = 0;
             ipmorp = '';
             ipbrkr = pbrkr;
710 A        ipusep = pUsep;
             ippuom = ppuom;
             ipprdq = pprdq;
710bA        ipMday = *zeros;
710bA      when ipprdflg = 'C';
710bA        ipmfgno = pline;
710bA        ipmorp = pprdtyp;
710bA        ippuom = ppuom;
710bA        ipprdq = pprdq;
710bA        ipbrkr = pbrkr;
710bA        ipusep = pUsep;
710bA        ippuom = ppuom;
710bA        ipprdq = pprdq;
710bA        ipmulti= pmulti;
710bA        ipmday = pMday;
	        endsl;

710bA    if itflgd<>'Y';
710bA       ipmday=*zeros;
710bA    endif;

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
                      ipprdq = :ipprdq, ipbrkr = :ipbrkr,
710 A                 ipusep = :ipusep, ipmday = :ipmday,
710bA                 ipmulti = :ipmulti
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
