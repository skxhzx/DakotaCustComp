      /copy *libl/qcopysrc,hspecs
650bAH DFTACTGRP(*no)
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M165002  Production Work Order Planning
     *  15 Spt 2017
     *  Kenneth Elder
     *
     *  Revisions:
     *
     *    06/14/17  TAB  7.10
     *      - Created.
710aA*    09/13/17  KDE  7.10a
     *      - Update PIRTRANP with current Work Order number for Employee
710bA*    09/15/17  KDE  7.10b
     *      - Pass in current Labor Trans
720 A*    01/20/18  KDE  7.20
     *      - Call DRIPROD command *AUTOWP to generate WIP
     *        Work ORders if BOM calls for WIP items
720aA*    10/16/18  KDE  7.20a
     *      - Only return open UnReleased Work Order if of the
     *        same Work Order Type
720bA*    10/27/18  KDE  7.20b
     *      - Add customer number to Unreleased WO error
730bA*     01/30/19  KDE  7.30b
     *       - Enh: Recompile due to PWRKORD change
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     FpWrkOrd   uf a e           k disk
     FpLined    if   e           k disk
     Fitemprd   if   e           k disk
     Fitemprd1  if   e           k disk    rename(iprec:r_iprec)
     f                                     prefix(r_)
     Fitemqty   if   e           k disk
     Fpbom      if   e           k disk
     fpRmSum    if   e           k disk
     fpiritem   if   e           k disk
     Fslot3     if   e           k disk

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

650aAD  pMessage       s             99    varying
650aAD  pSessId        s             40    varying
650aAD  pUser          s             10    varying
650aAD  pPgm           s             20    varying
     D  pObjLoc        s             10    varying
     D  pSubCmd        s              1
     D  pWhse          s              3p 0
     D  pFgItm         s             15    varying
     D  pWo#           s             13    varying
     D  pLine          s              3p 0
     D  pPriorty       s              2p 0
     D  pDest          s              1
     D  pMakeQty       s              4p 0
     d  pCust          s             11  0
     d  pCord          s              7  0
     d  pCustWo        s             15    varying
     D  pButchMsg      s            200    varying
     D  pPackMsg       s            200    varying
     D  pShipMsg       s            200    varying
710 Ad  pPrim          s             20    varying
710 Ad  pSubPrim       s             20    varying
710 Ad  pPrimary       s              3    varying
710bAd  pMultiDy       s              1    varying
710bAd  pMsgOnly       s              1    varying
710bAd  pTrans         s              7  0

650aAD* pMessage       s             99
650aAD* pSessId        s             40
650aAD* pUser          s             10
650aAD* pPgm           s             20
     D* pObjLoc        s             10
     D* pSubCmd        s              1
     D* pWhse          s              3p 0
     D* pFgItm         s             15
     D* pWo#           s             13
     D* pLine          s              3p 0
     D* pPriorty       s              2p 0
     D* pDest          s              1
     D* pMakeQty       s              4p 0
     d* pCust          s             11  0
     d* pCord          s              7  0
     d* pCustWo        s             15
     D* pButchMsg      s            200
     D* pPackMsg       s            200
     D* pShipMsg       s            200
710 Ad* pPrim          s             20
710 Ad* pSubPrim       s             20
710 Ad* pPrimary       s              3
710bAd* pMultiDy       s              1
710bAd* pMsgOnly       s              1
710bAd* pTrans         s              7  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

650aAD logText         s            100
     d NetDif          s              5  0
     d Newqtyn         s              5  0
     d pDatesql        s              8  0
     d opnCount        s              5  0
710aAd curtrn#         s              7  0
     d Newqty1         s              5  0
     d Newqty2         s              5  0
     d NewPrdq         s              9  4
710aAd linechar        s              4
     d newStat         s              1
     d prdSlot         s             12
     d pOutStr         s           1024    varying
     d pRmItm          s             15    varying
     d reqExt          s              5  0
     d rmExists        s               n
     D saveVer#        s                   like($ppver#)
710aAD sqlWo#          s             13
     d wkError         s               n
     d wkRerr2         s             50
710 Ad wkSeq           s              5  0
     d wkstat          s                   like(wostat)

     *  Division result and remainder data structure

     d divresult       ds
     d  result                        9  4
     d   intresult                    5  0 overlay(result)
     d   intdec                       4  0 overlay(result:*next)

     *  Division Prd Qty remainder data structure

     d divPrdQty       ds
     d  PrdQty                        9  4
     d   intPrdQty                    5  0 overlay(PrdQty)
     d   intPrdqtyD                   4  0 overlay(PrdQty:*next)

     *----------------------------------------------------------------
     *  Production Work Order Data Structure
     *----------------------------------------------------------------
     D wkwo#           ds
     D  wkwodate               1      8
     D  wkwoseq                9     13  0

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

     Dwrout            ds            39
     D wrwhseq                        3p 0
     D writemq                       13
     D wrqtynq                        4p 0
     D wrqty1q                        4p 0
     D wrqty2q                        4p 0
     D wrPRDqq                        9p 4
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
     C                   parm                    pMessage
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pPgm
     c                   parm                    pObjLoc
     c                   parm                    pSubCmd
     C                   parm                    pWhse
	    c                   parm                    pFgitm
	    c                   parm                    pWo#
	    c                   parm                    pLine
	    c                   parm                    pPriorty
	    c                   parm                    pDest
     c                   parm                    pMakeQty
     c                   parm                    pButchMsg
     c                   parm                    pPackMsg
     c                   parm                    pShipMsg
     c                   parm                    pCust
     c                   parm                    pCord
     c                   parm                    pCustWo
710 Ac                   parm                    pPrim
710 Ac                   parm                    pSubPrim
710 Ac                   parm                    pPrimary
710bAc                   parm                    pMultiDy
710bAc                   parm                    pMsgOnly
710bAc                   parm                    pTrans

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pMessage = ' ';

         // Write GLOSESSLOG record
         logText = 'objloc:' + pObjLoc;
         wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);

         select;
             when pObjLoc = 'FLDVALID';
710bD    //  exsr FldValid;
710bD    //  when pObjLoc = 'AFTERACT';
             select;
                when pSubCmd = 'U'      // update from M16500 single maint
                    or pSubCmd = 'A';
                     If pMsgOnly <> 'Y';
710bA                  exsr FldValid;
                     EndIf;
710bA              if not error;
                      exsr UpdWo;
710bA              endif;
                when pSubCmd = 'Y';    // update from M16400 Update Grid
710bA              exsr FldValid;
710bA              if not error;
                      exsr UpdRmUsage;
710bA              endif;
                other;
             endsl;
           other;
             pMessage = 'Invalid object location sent: '
                      + %trim(pObjLoc)
                      + ' (' + %trim(#pgm) +')';
         endsl;

         return;
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
     *  chkForWo   Check for matching Work Order
     *----------------------------------------------------------------

     C     chkForWo      begsr
      /free

                savever# = $ppver#;
                $ppver# = savever#;

        // returns matching Work Order number or *NF for not found in
        // $ppWo#

                $ppSessIdu = *on;
                $ppSessid  = pSessId;
                $ppwhseu = *on;
                $ppwhse  = pwhse;
                $ppitemu = *on;
                $ppitem  = pFgItm;
                $ppuser = #User;
                $ppuseru = *on;
                $ppdest = pdest;
                $ppdestu = *on;
                $ppcust = pcust;
                $ppcustu = *on;
                $ppcustwo = pcustwo;
                $ppcustwou = *on;
                $ppCord = pCord;
                $ppCordu = *on;
                $pplneno = pLine;
                $pplnenou = *on;
                $ppWo# = pWo#;
                $ppWo#u = *on;

                $dricommand = '*PROD';
                $drisubcmd = '%CHKFORWO';
                $drisys2upd = 'D';
                exsr zzDriCop;
                if wkerror or $driReturn <> '*OK';
                   pMessage = $driMessage;
                endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  crtProdWO  Create Production Work Order calling DRIPROD
     *----------------------------------------------------------------

     C     crtProdWO     begsr
      /free

                savever# = $ppver#;
                $ppver# = savever#;

                $ppSessIdu = *on;
                $ppSessid  = pSessId;
                $ppwhseu = *on;
                $ppwhse  = pwhse;
                $ppitemu = *on;
                $ppitem  = pFgItm;
                $ppuser = #User;
                $ppuseru = *on;
                $ppdest = pdest;
                $ppdestu = *on;
                $ppcust = pcust;
                $ppcustu = *on;
                $ppcustwo = pcustwo;
                $ppcustwou = *on;
                $ppcord = pCord;
                $ppCordu = *on;
                $ppmake = pMakeQty;
                $ppmakeu = *on;
                $pplneno = pLine;
                $pplnenou = *on;
                $pporig = 'P';       // Origination in Planning
                $pporigu = *on;
                $ppstat = 'P';       // Status is Planning
                $ppstatu = *on;
                $pprmavl = 'Y';
                $pprmavlu = *on;
                $ppprio = pPriorty;
                $pppriou = *on;
                $ppWo# = wkwo#;
                $ppWo#u = *on;
710 A           $ppPrim = pPrim;
710 A           $ppPrimu = *on;
710 A           $ppSubPrim = pSubPrim;
710 A           $ppSubPrimu = *on;
710 A           $ppPrimary = pPrimary;
710 A           $ppPrimaryu = *on;
710bA           $ppMultiDy = pMultiDy;
710bA           $ppMultiDyu = *on;

                $dricommand = '*PROD';
                $drisubcmd = '%CRTPRODWO';
                $drisys2upd = 'D';
                exsr zzDriCop;
                if wkerror or $driReturn <> '*OK';
710bA              error = *on;
                   pMessage = $driMessage;
720 A           else;
720 A              $drisubcmd = '%AUTOWP';
720 A              exsr zzDriCop;
                endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  errorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

         // Item must exists and be defined as a Finished Good

         chain(n) (pwhse: pFgItm) itemprd;
         if not %found(itemprd);
           pMessage = 'Finished Good item not defined as '
                    + 'Production item (' + %trim(pFgItm) + ')';
           error = *on;
           leavesr;
         endif;
710aD  //if ipprdflg <> 'F';
710aA    if ipprdflg <> 'F' and ipprdflg<>'C';
           pMessage = 'Item not defined as a '
                    + 'Finished Good item (' + %trim(pFgItm) + ')';
           error = *on;
           leavesr;
         endif;

         // Destination must be P(PAR), C(Customer), or W(WIP)

         if pDest<>'P' and pDest<>'C' and pDest<>'W';
           pMessage = 'Destination must be either P(Par), '
                    + 'C(Customer), or W(Wip)';
           error = *on;
           leavesr;
         endif;

         // Make Quantity cannot be less than zero

         if pMakeQty < 0;
           pMessage = 'Make Quantity cannot be less than '
                    + 'Zero !!!';
           error = *on;
           leavesr;
         endif;

710aA    // Return an error if changing Mfg Line to a line that already
710aA    // has an existing unreleased Work Order for this Mfg Line
710bA    // Ignore this check if a MultiDay line option selected
         // or Message fields only are being updated.
710bA    if pMultiDy <> 'Y';
710aA       sqlWo# = *blanks;
710aA       exec sql select wowo# into :sqlWo#
710aA                from pWrkOrd
710aA                 where wowhse=:pWhse and woitem=:pFgItm
710aA                   and woMfgno=:pLine and not
710aA                   wostat in('W','C','D','R')
710aA                   and wowo# <> :pWo#
720aA                   and wotype = :pDest
720aA                   and wocust = :pCust
710aA               fetch first row only;
710aA       if sqlStt = sqlSuccess and sqlWo# <> *blanks;
710aA         pMessage = 'UnReleased Work Order(' + %trim(sqlWo#)
710aA                   + ') already exists for selected Finished '
710aA                   + 'Good.';
710aA          error = *on;
710aA          leavesr;
710aA       endif;
710bA    endif;

         // Make sure this is a *CREATE request

       //if pWo# <> '*CREATE';
       //  pMessage = 'This process is only valid for the '
       //           + 'CREATION of a Work Order';
       //  error = *on;
       //  leavesr;
       //endif;

         // MSG Line must exists
710bA   // do not perform this check if MultiDay Line

710bA    if pMultiDy <> 'Y';
            chain(n) (pwhse: pLine) plined;
            if not %found(plined);
              pMessage = 'MFG Line must exists '
                       + '(' + %trim(%char(inwhse)) + ')';
              error = *on;
              leavesr;
            endif;
710bA    endif;

710 A    // Ensure that selected Primal exist
710 A
         if pPrim <> *blanks; // if primal blank allow pass
710 A    exec sql update pPrimal set ppWhse=ppWhse
710 A             where ppWhse=:pWhse and ppLine = :pLine
710 A               and pppcde = :pPrim and ppStat='A';
710 A    if sqlStt <> '00000';
710 A      pMessage = 'Selected Primal (' + %trim(pPrim) +
710 A                ') is not valid.  Please correct';
710 A      error = *on;
710 A      leavesr;
710 A    endif;
710 A
710 A    // Ensure that selected SubPrimal exist
710 A
710 A    exec sql update pSubPrimal set psWhse=psWhse
710 A             where psWhse=:pWhse and psLine = :pLine
710 A               and pspcde = :pPrim and psScde=:pSubPrim;
710 A    if sqlStt <> '00000';
710 A      pMessage = 'Selected SubPrimal (' + %trim(pSubPrim) +
710 A                ') is not valid.  Please correct';
710 A      error = *on;
710 A      leavesr;
710 A    endif;
710 A
710 A    // Ensure that selected Primal/SubPRimal exist for the finished good
710 A
710 A    if pPrimary = 'P';
710 A       exec sql update itemprdps set isWhse=isWhse
710 A                where isWhse=:pWhse and isLine = :pLine
710 A                  and ispcde = :pPrim and isScde=:pSubPrim
710 A                  and isitem = :pFgItm and isprimary='Y';
710 A    else;
710 A       // convert sequence and check for it
710 A       monitor;
              wkseq = %len(%trim(pPrimary));
              select;
                 when wkseq = 1;
                    pPrimary = '00' + %trim(pPRimary);
                 when wkseq = 2;
                    pPrimary = '0' + %trim(pPRimary);
                 when wkseq = 3;
              endsl;
710 A         wkseq = %dec(pPrimary:3:0);
710 A       on-error 105;
710 A         wkseq = 0;
710 A         pMessage = 'SubPrimal Sequence did not convert '
710 A                  + 'properly';
710 A         error = *on;
710 A         leavesr;
710 A       endmon;
710 A
710 A       exec sql update itemprdps set isWhse=isWhse
710 A                where isWhse=:pWhse and isLine = :pLine
710 A                  and ispcde = :pPrim and isScde=:pSubPrim
710 A                  and isitem = :pFgItm and isseq=:wkseq;
710 A    endif;
710 A    if sqlStt <> '00000';
710 A      pMessage = 'Primal/SubPirmal PRimary or Sequence '
710 A               + 'not found for this finished good';
710 A      error = *on;
710 A      leavesr;
710 A    endif;
710 A    endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FldValid   Validate fields
     *----------------------------------------------------------------

      /free
       begsr FldValid;

         error = *off;

         // Validate input

         if pSubCmd <> 'D';
           exsr errorcheck;
           if error;
             leavesr;
           endif;
         endif;

         // ensure that mfg line has valid production date
         exsr chkForDate;

       endsr;
      /end-free

       //---------------------------------------------------------
       // chkforDate  Check for open date for passed in Mfg Line
       //---------------------------------------------------------

      /free
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
                exec sql               // select valid date to return
                  select pdDate
                    into :pdatesql
                     from prdDate
                       where pdwhse = :pwhse and pdline = :pLine
                             and pdstat = 'O';
             when opncount > 1;
                error = *on;
                pMessage = 'No Production Date exists for Mfg Line';
             other;
                error = *on;
                pMessage = 'No Production Date exists for Mfg Line';
             endsl;
          else;
             error = *on;
             pMessage = 'No Production Date exists for Mfg Line';
          endif;

          endsr;
      /end-free

     *----------------------------------------------------------------
     *  getNxtPWO   Get Production Work Order Number
     *----------------------------------------------------------------

     C     getNxtPWO     begsr
      /free

                savever# = $ppver#;
                $ppver# = savever#;
                wkwo# = '*err';

        // get next available Work Order Number

                $ppSessIdu = *on;
                $ppSessid  = pSessId;
                $ppwhseu = *on;
                $ppwhse  = pwhse;
                $ppuser = #User;
                $ppuseru = *on;

                $dricommand = '*PROD';
                $drisubcmd = '%GETNXTWO';
                $drisys2upd = 'D';
                exsr zzDriCop;
                if wkerror or $driReturn <> '*OK';
                   pMessage = $driMessage;
                else;
                   wkwo# = $ppwo#;
                endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  getPrdSlt   Get Production Line Inventory Slot
     *----------------------------------------------------------------

      /free

          begsr getPrdSlt;

                savever# = $ppver#;
                $ppver# = savever#;

        // get mfg line number

                if pLine <> 0;
                   chain (pwhse:pLine) plined;
                   if %found(plined);
                      prdSlot = ' ';
                      $ppdesc = indesc;
                      $pprcvau = *on;
                      $pprcva = inrcvaisl;
                   endif;
                endif;

             // reading raw material item
                if bmrmi <> '';
                   chain (pwhse:bmrmi) piritem;
                   if %found(piritem);
                      $ppwhdpu = *on;
                      $ppwhdp  = itwhdp;
                      $ppitemu = *on;
                      $ppitem  = ititem;
                   endif;
                endif;

                $ppSessIdu = *on;
                $ppSessid  = pSessId;
                $ppwhseu = *on;
                $ppwhse  = pwhse;
                $pplnenou = *on;
                $pplneno = pLine;
                $ppuser = #User;
                $ppuseru = *on;

                $dricommand = '*PROD';
                $drisubcmd = '%GETMIN';
                $drisys2upd = 'D';
                exsr zzDriCop;
               if wkerror or ($driReturn <> '*OK' and $driReturn<>'INSLOT');
                   pMessage = $driMessage;
                else;
                   prdSlot = $pprcvar;
                // call replenishment process
      /end-free
510aA
     c                   endif

     c                   endsr

     *----------------------------------------------------------------
     *  updProdWO  Update Production Work Order calling DRIPROD
     *----------------------------------------------------------------

     C     updProdWO     begsr
      /free

                savever# = $ppver#;
                $ppver# = savever#;

                $ppSessIdu = *on;
                $ppSessid  = pSessId;
                $ppwhseu = *on;
                $ppwhse  = pwhse;
                $ppwo#u = *on;
                $ppwo#  = $ppwo#;
                $ppitemu = *on;
                $ppitem  = pFgItm;
                $ppuser = #User;
                $ppuseru = *on;
                $ppdest = pdest;
                $ppdestu = *on;
                $ppcust = pcust;
                $ppcustu = *on;
                $ppcustwo = pcustwo;
                $ppcustwou = *on;
                $ppcord = pcord;
                $ppcordu = *on;
                $ppmake = pMakeQty;
                $ppmakeu = *on;
                $pplneno = pLine;
                $pplnenou = *on;
                $ppstat = 'P';       // Status is Planning
                $ppstatu = *on;
                $ppprio = pPriorty;
                $pppriou = *on;
710 A           $ppPrim = pPrim;
710 A           $ppPrimu = *on;
710 A           $ppSubPrim = pSubPrim;
710 A           $ppSubPrimu = *on;
710 A           $ppPrimary = pPrimary;
710 A           $ppPrimaryu = *on;
710bA           $ppMultiDy = pMultiDy;
710bA           $ppMultiDyu = *on;

                $dricommand = '*PROD';
                $drisubcmd = '%UPDPRODWO';
                $drisys2upd = 'D';
                exsr zzDriCop;
                if wkerror or $driReturn <> '*OK';
710bA              error = *on;
                   pMessage = $driMessage;
720 A           else;
720 A              $drisubcmd = '%AUTOWP';
720 A              exsr zzDriCop;
                endif;

      /end-free
     C                   endsr


     *----------------------------------------------------------------
     *  updRMUsage  Update the Raw Material Usage after qty changes
     *----------------------------------------------------------------

     C     updRMUsage    begsr
      /free

                savever# = $ppver#;
                $ppver# = savever#;

                $ppSessIdu = *on;
                $ppSessid  = pSessId;
                $ppwhseu = *on;
                $ppwhse  = pwhse;
                $ppwo#u = *on;
                $ppwo#  = pwo#;
                $ppitemu = *on;
                $ppitem  = pFgItm;
                $ppuser = #User;
                $ppuseru = *on;
                $ppdest = pdest;
                $ppdestu = *on;
                $ppcust = pcust;
                $ppcustu = *on;
                $ppcustwo = pcustwo;
                $ppcustwou = *on;
                $ppcord = pcord;
                $ppcordu = *on;
                $ppmake = pMakeQty;
                $ppmakeu = *on;
                $pplneno = pLine;
                $pplnenou = *on;
                $ppstat = 'P';       // Status is Planning
                $ppstatu = *on;
                $ppprio = pPriorty;
                $pppriou = *on;

                $dricommand = '*PROD';
                $drisubcmd = '%UPDRMUSE';
                $drisys2upd = 'D';
                exsr zzDriCop;
                if wkerror or $driReturn <> '*OK';
710bA              error = *on;
                   pMessage = $driMessage;
                endif;

      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *  UpdWo    Add or Update Work Order
     *----------------------------------------------------------------

      /free
       begsr UpdWo;

          If pMsgOnly <> 'Y';
          exsr chkforwo;   // calls DRIPROD to check  for Work Order

          // if no Work Order found for Customer/Type combination
          // then get next valid Work Order Number
          if $ppWo# = '*NF';
             exsr GetNxtPWO; // for new Work Order next WO number
             exsr crtProdWO;
710aA        exsr updPirtranP; // update after add since wo not known before
             if %len($ppItem) >=3;
             if %subst($ppItem:1:3)<>'WIP';
             exec sql
               update pWrkOrd
               set wobutchmsg = :pbutchmsg,
                   wopackmsg = :ppackmsg,
                   woshipmsg = :pshipmsg
                   where wowhse = :$ppwhse and wowo# = :$ppwo#;
             endif;
             endif;
          else;
             exsr updProdWO;
             exec sql
               update pWrkOrd
               set wobutchmsg = :pbutchmsg,
                   wopackmsg = :ppackmsg,
                   woshipmsg = :pshipmsg
                   where wowhse = :$ppwhse and wowo# = :$ppwo#;
          endif;

          Else;
          exec sql
               update pWrkOrd
               set wobutchmsg = :pbutchmsg,
                   wopackmsg = :ppackmsg,
                   woshipmsg = :pshipmsg
                   where wowhse = :pwhse and wowo# = :pwo#;
          EndIf;

       endsr;
      /end-free

710aA*----------------------------------------------------------------
710aA*  updPirTranp  Update Work Order and Mfg Line if for Labor Trans
710aA*----------------------------------------------------------------
710aA
710aA /free
710aA  begsr updPirTranp;
710aA
710bA            if pTrans=*zeros;
710bA               leavesr;
710bA            endif;
710bA
710aA            pUser = %xlate(Low: Up: pUser);
710aA            linechar = %editc($ppLneno:'X');
710aA            exec sql update pirtranp as a set ppwo#=:$ppWo#,
710aA                                  ppLine=:linechar
710aA                     where a.ppwhse=:pWhse and a.pptrn#=:pTrans;
710aA
710aA  endsr;
710aA /end-free

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
