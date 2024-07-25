      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *   This program needs to be created with *NEW and LR must be
     *   set on. This is so the printer file overrides will only
     *   be applied to a single call of the program.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  RTEREPRINT  Reprint Rte - Pgm for SQL procedure of same name
     *  21 January 2014
     *  Dave Sommerville
     *
     *  Revisions:
     *
650 A*    01/21/14  DAS  6.50
     *      - Created.
     *
650a *    03/07/14  DAS  6.50a
     *      - Added pPgm paramters
     *      - Moved pSessId, pUser, pPgm before pWhse.
     *      - Added call to WRTSESSLOG
     *
700a *    06/11/15  LMC  7.00a
     *      - Save and Hold overrides not working.
     *        Input parm field was not being moved as needed.
     *
720  *    09/20/18  KDE  7.20
     *      - Change for Truck Builder Enhanced
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Client Custom Revisions: Anderson Dubose
     *
ADCaA*    09/20/18  KDE   ADCa
     *      - Override printer file for Pallet Summary
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Flabel     if a e           k disk    usropn
     Fpltsum4   if   e           k disk    usropn
     Frptovrdtl uf a e           k disk    usropn
     Frtehed    if   e           k disk    usropn
     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     *  Client id's
     *----------------------------------------------------------------

      /copy qcopysrc,id#citywho
      /copy qcopysrc,id#packers
ADCaA /copy qcopysrc,id#adc

     D client          s             10
     D clientLoc       s             10

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D authorized      s               n
     D debug           s               n
     D dbgflgExists    s               n
     D error           s               n
     D forever         s               n
     D fromTran        s                   like(lbtrn#)
     D GUIPgm          s             20
650aAD logText         s            100
     D nextSeq         s                   like(rdseq)
     D prtFile         s             10
     D prtText         s             30
     D toTran          s                   like(lbtrn#)
     D zeroUsed        s               n
720bAd tbEnhanced      s               n
720bAd tbPalletType    s              1
720bAd tbType          s              1
720bAd tbWhse          s              3  0

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

720bAd/copy qcopysrc,p.gettbtyp

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

650aA /copy qcopysrc,p.chkiuse2
650aA /copy qcopysrc,p.wrtsessl

     D GetClient       pr                  extpgm('GETCLIENT')
     D  client                       10
     D  clientLoc                    10

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
650aM*      pSessId     Session Id
650aM*      pUser       User
650aA*      pPgm        Calling dictionary.pgm
     *      pWhse       Warehouse
     *      pRtid       Route id
     *      pLblZon     Reprint zone (N,Y)
     *      pLblZonVal  Reprint zone value
     *      pLblTrn     Reprint transaction (N,Y)
     *      pLblTrnVal1 Reprint transaction value 1
     *      pLblTrnVal2 Reprint transaction value 2
     *      pLblNum     Reprint lbl# (N,Y)
     *      pLblNumVal1 Reprint lbl# value 1
     *      pLblNumVal2 Reprint lbl# value 2
     *      pTrkSum     Reprint truck summary (N,Y,O)
     *      pTrkPltDtl  Reprint truck pallet detail (N,Y,O)
     *      pTrkPltSum  Reprint truck pallet summary (N,Y,O)
     *      pTrnAudit   Reprint tran audit (N,Y,O)
     *      pTrnAuditVal1  Reprint tran audit value 1
     *      pCWSum      Reprint catchweight summary (N,Y,O)
     *      pDevice     Override device
     *      pOutQue     Override output queue
     *      pOutLib     Override output queue library
     *      pForm       Override form type
     *      pDrawer     Override drawer
     *      pCopies     Override copies
     *      pLPI        Override LPI
     *      pCPI        Override CPI
     *      pSave       Override Save (Y,N)
     *      pHold       Override Hold (Y,N)
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage         99
650aMC                   parm                    pSessId          40
650aMC                   parm                    pUser            10
650aMC                   parm                    pPgm             20
     C                   parm                    pWhse             3 0
     C                   parm                    pRtid             5
     C                   parm                    pLblZon           1
     C                   parm                    pLblZonVal        6
     C                   parm                    pLblTrn           1
     C                   parm                    pLblTrnVal1       7 0
     C                   parm                    pLblTrnVal2       7 0
     C                   parm                    pLblNum           1
     C                   parm                    pLblNumVal1       7 0
     C                   parm                    pLblNumVal2       7 0
     C                   parm                    pTrkSum           1
     C                   parm                    pTrkPltDtl        1
     C                   parm                    pTrkPltSum        1
     C                   parm                    pTrnAudit         1
     C                   parm                    pTrnAuditVal1     7 0
     C                   parm                    pCWSum            1
     C                   parm                    pDevice          10
     C                   parm                    pOutQue          10
     C                   parm                    pOutLib          10
     C                   parm                    pForm            10
     C                   parm                    pDrawer           7
     C                   parm                    pCopies           2 0
     C                   parm                    pLPI              5
     C                   parm                    pCPI              5
     C                   parm                    pSave             1
     C                   parm                    pHold             1

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pMessage = ' ';

650aA    // Write GLOSESSLOG record
650aA
650aA    logText = 'whs:' + %char(pWhse) + ','
650aA            + 'rtid:' + %trim(pRtid);
650aA    wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);

         if dbgflgExists;
           chain(e) (#pgm) bfcdbgflg;
           if %found(bfcdbgflg);
             debug = (bdfflag = 1);
           else;
             debug = *off;
           endif;
         endif;

         // Check if user authorized to do reprinting

         $copt = 'ALL';
         exsr ChkUserAuth;
         if not authorized;
           pMessage = 'Not authorized to reprint (chklist)';
           return;
         endif;

         // Get route information

         exsr getrtehed;
         if error;
           return;
         endif;

         // City Wholesale always wants a custom pallet report printed
         // regardless of what options are chosen. This mimics OR645CL.

         if client = citywholesale;
           exsr ReprintPalletDtlCW;
           if error;
             return;
           endif;
         endif;

         // Call reprint routines

         exsr ReprintLabelZone;
         if error;
           return;
         endif;

         exsr ReprintLabelTran;
         if error;
           return;
         endif;

         exsr ReprintLabelNum;
         if error;
           return;
         endif;

         exsr ReprintTruckSum;
         if error;
           return;
         endif;

         exsr ReprintPalletDtl;
         if error;
           return;
         endif;

         exsr ReprintPalletSum;
         if error;
           return;
         endif;

         exsr ReprintTranAudit;
         if error;
           return;
         endif;

         exsr ReprintCWSum;
         if error;
           return;
         endif;

         return;
      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *inzsr;

         // Get client id

         getclient(client: clientLoc);

         // See if BFCDBGFLG file exists

         open(e) bfcdbgflg;
         if %error;
           dbgflgExists = *off;
         else;
           dbgflgExists = *on;
         endif;
720bA
720bA  // Determine if using TruckBUilder Enhanced
720bA
720bA      GetTBType(pWhse: pRtid: tbType);
720bA      if tbType = 'E';
720bA        tbEnhanced = *on;
720bA        tbPalletType = 'P';
720bA      else;
720bA        tbEnhanced = *off;
720bA        tbPalletType = 'O';
720bA      endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ChkUserAuth   Check user authorization
     *----------------------------------------------------------------

      /free
       begsr ChkUserAuth;

         authorized = *on;

         // Only do check for City Wholesale

         if client <> citywholesale;
           leavesr;
         endif;

      /end-free

CTWaAC                   call      'CHKLIST'
CTWaAC                   parm      'OR645'       $cpgm            10
CTWaAC                   parm                    $copt            20
CTWaAC                   parm      pUser         $cuser           10
CTWaAC                   parm      ' '           $crtn            10
CTWaAC                   if        $crtn = '*NO'
CTWaAC                   eval      authorized = *off
CTWaAC                   endif

      /free
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetRteHed   Get RTEHED record
     *----------------------------------------------------------------

      /free
       begsr GetRteHed;

         error = *off;

         // Open rtehed file

         exsr OpenRTEHED;
         if error;
           leavesr;
         endif;

         // Get rtehed record

         chain(e) (pWhse: pRtid) rtehed;

         if not %found;
             error = *on;
             pMessage = 'Route not found '
                      + '('
                      + %Trim(%editc(pWhse:'Z'))
                      + '/'
                      + %Trim(pRtid)
                      + ')';
             leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  OpenLABEL     Open LABEL file
     *----------------------------------------------------------------

      /free
       begsr OpenLABEL;

         error = *off;

         // Open label file

         if not %open(label);
             open(e) label;
             if %error;
                 error = *on;
                 pMessage = 'Error occured trying to '
                          + 'open file LABEL in pgm '
                          + #pgm;
                 leavesr;
             endif;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  OpenPLTSUM4   Open PLTSUM4 file
     *----------------------------------------------------------------

      /free
       begsr OpenPLTSUM4;

         error = *off;

         // Open pltsum4 file

         if not %open(pltsum4);
             open(e) pltsum4;
             if %error;
                 error = *on;
                 pMessage = 'Error occured trying to '
                          + 'open file PLTSUM4 in pgm '
                          + #pgm;
                 leavesr;
             endif;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  OpenRPTOVRDTL   Open RPTOVRDTL file
     *----------------------------------------------------------------

      /free
       begsr OpenRPTOVRDTL;

         error = *off;

         // Open rptovrdtl file

         if not %open(rptovrdtl);
             open(e) rptovrdtl;
             if %error;
                 error = *on;
                 pMessage = 'Error occured trying to '
                          + 'open file RPTOVRDTL in pgm '
                          + #pgm;
                 leavesr;
             endif;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  OpenRTEHED    Open RTEHED file
     *----------------------------------------------------------------

      /free
       begsr OpenRTEHED;

         error = *off;

         // Open rtehed file

         if not %open(rtehed);
             open(e) rtehed;
             if %error;
                 error = *on;
                 pMessage = 'Error occured trying to '
                          + 'open file RTEHED in pgm '
                          + #pgm;
                 leavesr;
             endif;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ReprintCWSum   Reprint catch weight summary
     *----------------------------------------------------------------

      /free
       begsr ReprintCWSum;

         // Get out if not requested

         if pCWSum <> 'Y' and pCWSum <> 'O';
           leavesr;
         endif;

         // Get out if not authorized

         $copt = 'CATCHWGT';
         exsr ChkUserAuth;
         if not authorized;
           error = *on;
           pMessage = 'Not authorized to reprint '
                    + 'catch weight summary (chklist)';
           leavesr;
         endif;

         // Create override if requested.

         if pCWSum = 'O';
           prtFile = 'OR660CPR';
           prtText = 'Catch Weight Summary';
           exsr WrtOverride;
           if error;
             leavesr;
           endif;
         endif;

         // Call program to do reprint

         $whse  = %editc(pWhse:'X');

         select;

           when client = packers;

             if pDevice <> ' ';
               $pdev = pDevice;
             else;
               $pdev = '*JOB';
             endif;

             if pForm <> ' ';
               $pform = pForm;
             else;
               $pform = '*STD';
             endif;

      /end-free
     C                   call      'OR661CL'
     C                   parm      '*REPRINT'    $pcmd             8
     C                   parm      ' '           $type             8
     C                   parm                    $whse             3
     C                   parm      pRtid         $prtid            5
     C                   parm      ' '           $prtn             8
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm      '0000000'     $ptrn             7
      /free

           other;

      /end-free
     C                   call      'OR660CCL'
     C                   parm      '*REPRINT'    $pcmd             8
     C                   parm      ' '           $type             8
     C                   parm                    $whse             3
     C                   parm      pRtid         $prtid            5
     C                   parm      ' '           $prtn             8
     C                   parm      ' '           $povr             1
      /free

         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ReprintLabelNum    Reprint labels for label number range
     *----------------------------------------------------------------

      /free
       begsr ReprintLabelNum;

         // Get out if not requested

         if pLblNum <> 'Y';
           leavesr;
         endif;

         // Get out if not authorized

         $copt = 'LABELS';
         exsr ChkUserAuth;
         if not authorized;
           error = *on;
           pMessage = 'Not authorized to reprint labels (chklist)';
           leavesr;
         endif;

         // Take care of a zero entry

         select;
           when pLblNumVal1 = 0;
             pLblNumVal1 = pLblNumVal2;
           when pLblNumVal2 = 0;
             pLblNumVal2 = pLblNumVal1;
         endsl;

         // Labels must be from same transaction

         if pLblNumVal1 <> pLblNumVal2;

             // Open LABEL file

             exsr OpenLABEL;
             if error;
               leavesr;
             endif;

             // Get transaction for From label

             chain (pLblNumVal1) label;
             if not %found;
               error = *on;
               pMessage = 'Label number ' + %char(pLblNumVal1) + ' '
                        + 'not found';
               leavesr;
             endif;
             fromTran = lbtrn#;

             // Get transaction for To label

             chain (pLblNumVal2) label;
             if not %found;
               error = *on;
               pMessage = 'Label number ' + %char(pLblNumVal2) + ' '
                        + 'not found';
               leavesr;
             endif;
             toTran = lbtrn#;

             // Error if transactions don't match

             if fromTran <> toTran;
               error = *on;
               pMessage = 'Label numbers must be on same transaction';
               leavesr;
             endif;

         endif;

         // Call program to do reprint

         $whse  = %editc(pWhse:'X');

         if pLblNumVal1 <= pLblNumVal2;
           $pflbl = %editc(pLblNumVal1:'X');
           $ptlbl = %editc(pLblNumVal2:'X');
         else;
           $pflbl = %editc(pLblNumVal2:'X');
           $ptlbl = %editc(pLblNumVal1:'X');
         endif;

      /end-free
     C                   call      'OR640J'
     C                   parm      '*REPRINT'    $pcmd             8
     C                   parm                    $whse             3
     C                   parm      pRtid         $prtid            5
     C                   parm      rhrte         $prte             5
     C                   parm      rhtruk        $ptruk           10
     C                   parm      $pflbl        $value            7
     C                   parm      'L'           $ptype            1
     C                   parm                    $pflbl            7
     C                   parm                    $ptlbl            7
      /free

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ReprintLabelTran   Reprint labels for transaction
     *----------------------------------------------------------------

      /free
       begsr ReprintLabelTran;

         // Get out if not requested

         if pLblTrn <> 'Y';
           leavesr;
         endif;

         // Get out if not authorized

         $copt = 'LABELS';
         exsr ChkUserAuth;
         if not authorized;
           error = *on;
           pMessage = 'Not authorized to reprint labels (chklist)';
           leavesr;
         endif;

         // Call program to do reprint
         // Field pLblTrnVal2 is not used at this time

         $whse  = %editc(pWhse:'X');
         $value = %editc(pLblTrnVal1:'X');

      /end-free
     C                   call      'OR640J'
     C                   parm      '*REPRINT'    $pcmd             8
     C                   parm                    $whse             3
     C                   parm      pRtid         $prtid            5
     C                   parm      rhrte         $prte             5
     C                   parm      rhtruk        $ptruk           10
     C                   parm                    $value            7
     C                   parm      'T'           $ptype            1
     C                   parm      ' '           $pflbl            7
     C                   parm      ' '           $ptlbl            7
      /free

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ReprintLabelZone   Reprint labels for zone
     *----------------------------------------------------------------

      /free
       begsr ReprintLabelZone;

         // Get out if not requested

         if pLblZon <> 'Y';
           leavesr;
         endif;

         // Get out if not authorized

         $copt = 'LABELS';
         exsr ChkUserAuth;
         if not authorized;
           error = *on;
           pMessage = 'Not authorized to reprint labels (chklist)';
           leavesr;
         endif;

         // Call program to do reprint

         $whse  = %editc(pWhse:'X');

      /end-free
     C                   call      'OR640J'
     C                   parm      '*REPRINT'    $pcmd             8
     C                   parm                    $whse             3
     C                   parm      pRtid         $prtid            5
     C                   parm      rhrte         $prte             5
     C                   parm      rhtruk        $ptruk           10
     C                   parm      pLblZonVal    $value            7
     C                   parm      'Z'           $ptype            1
     C                   parm      ' '           $pflbl            7
     C                   parm      ' '           $ptlbl            7
      /free

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ReprintPalletDtl   Reprint truck pallet detail
     *----------------------------------------------------------------

      /free
       begsr ReprintPalletDtl;

         bdValues = 'Start ReprintPalletDtl - ' + pTrkPltDtl;
         exsr WrtDebug;

         // Get out if not requested

         if pTrkPltDtl <> 'Y' and pTrkPltDtl <> 'O';
           leavesr;
         endif;

         // Get out if not authorized

         $copt = 'TRUCK';
         exsr ChkUserAuth;
         if not authorized;
           error = *on;
           pMessage = 'Not authorized to reprint '
                    + 'truck pallet detail (chklist)';
           leavesr;
         endif;

         // Create override if requested.

         if pTrkPltDtl = 'O';
           bdValues = 'Create override';
           exsr WrtDebug;
           prtFile = 'OR660PR';
           prtText = 'Pallet Detail';
           exsr WrtOverride;
           if error;
             leavesr;
           endif;
         endif;

         // Call program to do reprint

         bdValues = 'Call OR660CL';
         exsr WrtDebug;

         $whse  = %editc(pWhse:'X');

      /end-free
     C                   call      'OR660CL'
     C                   parm      '*REPRINT'    $pcmd             8
     C                   parm      '*DETAIL'     $type             8
     C                   parm                    $whse             3
     C                   parm      pRtid         $prtid            5
     C                   parm      ' '           $prtn             8
     C                   parm      ' '           $povr             1
      /free

         bdValues = 'Return from OR660CL - ' + $prtn;
         exsr WrtDebug;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ReprintPalletDtlCW   Reprint City Wholesale custom pallet detail
     *----------------------------------------------------------------

      /free
       begsr ReprintPalletDtlCW;

         // OR640CL is hard coded to NOT work with printer file override.

         // Call program to do reprint

         $whse  = %editc(pWhse:'X');

      /end-free
     C                   call      'OR660CLCTW'
     C                   parm      '*REPRINT'    $pcmd             8
     C                   parm      '*DETAIL'     $type             8
     C                   parm                    $whse             3
     C                   parm      pRtid         $prtid            5
     C                   parm      ' '           $prtn             8
     C                   parm      ' '           $povr             1
      /free

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ReprintPalletSum   Reprint truck pallet summary
     *----------------------------------------------------------------

      /free
       begsr ReprintPalletSum;

         // Get out if not requested

         if pTrkPltSum <> 'Y' and pTrkPltSum <> 'O';
           leavesr;
         endif;

         // Get out if not authorized

         $copt = 'TRUCK';
         exsr ChkUserAuth;
         if not authorized;
           error = *on;
           pMessage = 'Not authorized to reprint '
                    + 'truck pallet summary (chklist)';
           leavesr;
         endif;

         // Create override if requested.

         if pTrkPltSum = 'O';
           prtFile = 'OR660PRS';
           prtText = 'Pallet Summary';
           exsr WrtOverride;
           if error;
             leavesr;
           endif;
         endif;

         // Call program to do reprint

         $whse  = %editc(pWhse:'X');

      /end-free
     C                   call      'OR660CL'
     C                   parm      '*REPRINT'    $pcmd             8
     C                   parm      '*SUMMARY'    $type             8
     C                   parm                    $whse             3
     C                   parm      pRtid         $prtid            5
     C                   parm      ' '           $prtn             8
     C                   parm      ' '           $povr             1
      /free

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ReprintTranAudit   Reprint transaction audit
     *----------------------------------------------------------------

      /free
       begsr ReprintTranAudit;

         // Get out if not requested

         if pTrnAudit <> 'Y' and pTrnAudit <> 'O';
           leavesr;
         endif;

         // Get out if not authorized

         $copt = 'AUDIT';
         exsr ChkUserAuth;
         if not authorized;
           error = *on;
           pMessage = 'Not authorized to reprint '
                    + 'transaction audit (chklist)';
           leavesr;
         endif;

         // Open PLTSUM4 file

         exsr OpenPLTSUM4;
         if error;
           leavesr;
         endif;

         // Create override if requested.

         if pTrnAudit = 'O';
           prtFile = 'OR695PR';
           prtText = 'Transaction Audit';
           exsr WrtOverride;
           if error;
             leavesr;
           endif;
         endif;

         // Call program to do reprint

         $bwhse  = %editc(pWhse:'X');
         $btrn# = %editc(pTrnAuditVal1:'X');

         chain (pTrnAuditVal1) pltsum4;
         if not %found(pltsum4);
           psszon = ' ';
         endif;

      /end-free
     C                   call      'OR690CL'
     C                   parm      '*REPRINT'    $bcmd             8
     C                   parm                    $bwhse            3
     C                   parm      pRtid         $brtid            5
     C                   parm      rhrte         $brte             5
     C                   parm                    $btrn#            7
     C                   parm      rhtruk        $btruk           10
     C                   parm      psszon        $bzone            6
     C                   parm      ' '           $bdev            10
     C                   parm      ' '           $bform           10
     C                   parm      ' '           $brtn             8

      /free

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ReprintTruckSum    Reprint truck summary
     *----------------------------------------------------------------

      /free
       begsr ReprintTruckSum;

         // Get out if not requested

         if pTrkSum <> 'Y' and pTrkSum <> 'O';
           leavesr;
         endif;

         // Create override if requested.

         if pTrkSum = 'O';
720 A    // Determine correct version of PAllet Summary Printer File
720 A      select;
ADCaA        when client = andersondubose;
ADCaA          prtFile = 'PS312PR';
ADCcA          prtText = 'Truck Summary (3 column)';
720 A        when tbEnhanced;
720 A          prtFile = 'PS314PR';
720 A          prtText = 'Truck Summary (4 column)';
720 A        other;
               prtFile = 'PS311PR';
               prtText = 'Truck Summary';
720 A      endsl;
           exsr WrtOverride;
           if error;
             leavesr;
           endif;
         endif;

         // Call program to do reprint

         $whse  = %editc(pWhse:'X');

      /end-free
     C                   call      'PS310CL'
     C                   parm                    $whse             3
     C                   parm      pRtid         $prtid            5
     C                   parm      ' '           $prtn             8
     C                   parm      ' '           $povr             1
      /free

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  WrtDebug  Write out debug record
     *----------------------------------------------------------------

      /free
       begsr WrtDebug;

         bdtype = 'INFO';

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
     *  WrtOverride     Write printer file override record
     *----------------------------------------------------------------

      /free
       begsr WrtOverride;

         error = *off;

         // Open RPTOVRDTL file

         exsr OpenRPTOVRDTL;
         if error;
           leavesr;
         endif;

         // Get sequence number to use

         nextSeq = 1;
         zeroUsed = *off;

         setll (prtFile) rptovrdtl;

         dow forever = forever;

           reade (prtFile) rptovrdtl;
           if %eof(rptovrdtl);
             leave;
           endif;

           // Flag if zero sequence exists

           if rdseq = 0;
             zeroUsed = *on;
             iter;
           endif;

           // If seq greater than expected seq
           // Then we have found an unused seq so get out

           if rdseq > nextSeq;
             leave;
           endif;

           // If seq = 999 and zero was used,
           // Then throw error and get out.

           if rdseq = 999 and zeroUsed;
             error = *on;
             pMessage = 'Error: Cannot create override for '
                      + %trimr(prtText) + ' - No seq numbers '
                      + '(RPTOVRDTL/' + %trimr(prtFile) + ') '
                      + '(' + %trimr(#pgm) + ')';
             leavesr;
           endif;

           // If seq = 999 and zero was not used,
           // Then use seq zero.

           if rdseq = 999;
             nextSeq = 0;
             leave;
           endif;

           // Otherwise, keep looking for unused seq number

           nextSeq = rdseq + 1;

         enddo;

         // Initialize record

         clear rdrec;

         rdone = 'Y';
         rdprf = prtFile;
         rdseq = nextSeq;

         if pDevice <> ' ';
           rddev = pDevice;
           rdOvr = %trimr(rdOvr) + ' DEV(' + %trimr(pDevice) + ')';
         endif;

         if pLPI <> ' ';
           rdlpi = pLPI;
           rdOvr = %trimr(rdOvr) + ' LPI(' + %trimr(pLPI) + ')';
         endif;

         if pCPI <> ' ';
           rdcpi = pCPI;
           rdOvr = %trimr(rdOvr) + ' CPI(' + %trimr(pCPI) + ')';
         endif;

         if pForm <> ' ';
           rdfrm = pForm;
           rdOvr = %trimr(rdOvr) + ' FORMTYPE(' + %trimr(pForm) + ')';
         endif;

         if pCopies <> 0;
           rdcps = %char(pCopies);
           rdOvr = %trimr(rdOvr) + ' COPIES(' + %trimr(rdcps) + ')';
         endif;

         if pOutQue <> ' ';
           rdoq  = pOutQue;
           rdlb  = pOutLib;
           if pOutLib = ' ' or pOutLib = '*LIBL';
             rdOvr = %trimr(rdOvr) + ' OUTQ(' + %trimr(pOutQue) + ')';
           else;
             rdOvr = %trimr(rdOvr) + ' OUTQ(' + %trimr(pOutLib)
                   +  '/' + %trimr(pOutQue) + ')';
           endif;
         endif;

         if pDrawer <> ' ';
           rddw  = pDrawer;
           rdOvr = %trimr(rdOvr) + ' DRAWER(' + %trimr(pDrawer) + ')';
         endif;

         if pSave <> ' ';
700aA      rdsv  = pSave;
           select;
             when rdsv = 'Y';
               rdsv = '*YES';
             other;
               rdsv = '*NO';
           endsl;
           rdOvr = %trimr(rdOvr) + ' SAVE(' + %trimr(rdsv) + ')';
         endif;

         if pHold <> ' ';
700aA      rdhd  = pHold;
           select;
             when rdhd = 'Y';
               rdhd = '*YES';
             other;
               rdhd = '*NO';
           endsl;
           rdOvr = %trimr(rdOvr) + ' HOLD(' + %trimr(rdhd) + ')';
         endif;

         // If override is blank, get out.

         if rdOvr = '';
           leavesr;
         endif;

         // Otherwise, add OVRPRTF to the command

         rdOvr = 'OVRPRTF FILE(' + %trimr(rdprf) + ') ' + rdOvr;

         bdValues = 'Write RPTOVRDTL - '
                  + %trim(rdprf) + '-' + %char(rdseq) + ' - ' + rdovr;
         exsr WrtDebug;

         // And add record;

         write(e) rdrec;

         if %error;
           error = *on;
           pMessage = 'Error: Cannot create override for '
                    + %trimr(prtText) + ' - Write error '
                    + '(RPTOVRDTL/' + %trimr(prtFile)
                    + '/' + %char(nextSeq) + ') '
                    + '(' + %trimr(#pgm) + ')';
           leavesr;
         endif;

       endsr;
      /end-free
