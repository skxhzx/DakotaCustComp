      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO)
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M17300  Production Box Breaker
     *  31 Mar 2015
     *  Kenneth Elder
     *
     *  Revisions:
     *
     *    03/31/15  KDE  7.00
     *      - Created.
     *
700aA*    11/04/16  LMC  7.00a
     *      - Enh: UPC file has a database change. Recompile only.
     *
710 A*    03/07/17  KDE  7.10
     *      - Enh: Code change to handle use of I99 UCI
     *      - Fix: Force Weight values from DRIUCIINFO command
     *        when GS1 99I is scanned
710aA*    03/08/17  TAB  7.10a
     *      - Enh: Added new command %CKUCISPLT
     *      - Fix: Removed DRI command %CHKREPLEN
710bA*    03/09/17  KDE  7.10b
     *      - Enh: Update Scale Tran# when creating new Transaction
710bA*    04/13/17  KDE  7.10c
     *      - Fix: Changed SLOT SQL statement to also use SLPICK ='Y'
710dA*    06/12/17  TAB  7.10d
     *      - Fix: Changed UPC file to UPC5 to verify UPC UOM is a
     *             breakdown.
710eA*    06/22/17  KDE  7.10e
     *      - Fix: Make corrections to mod 7.10d
710fA*    07/07/17  TAB  7.10f
     *      - Fix: Reversed 7.10a.
710gA*    07/11/17  KDE  7.10g
     *      - Ehn: Changed to allow non unique UCI's as case
     *        and identify as unique with a new field xxBBSEQ
     *        in both UCIPLSITS and PRDLBHIST files
     *      - Also fix issues with case and brkdwn upc checks
710hA*    07/18/17  KDE  7.10h
     *      - Ehn: Allow Breakdown for items that have NO breakdown
     *        defined.  In this case as customer can receive a case
     *        and only have the breakdown UOM defined and sold.  In
     *        this situation we will just produce labels and no
     *        inventory transactions.  It will still update UCIINFO
     *        and UCISPLITS
     *      - Fix: Not handling bad slot correctly
720aA*    08/16/16  LMC  7.20a  - reserved
     *      - Enh: UCI Tracking.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     fprodlog   uf a e           k disk
     fupc       if   e           k disk
     fpiritem   if   e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D slrec         E ds                  extname(slot) inz(*EXTDFT)
     D pdrec         E ds                  extname(prddate) inz(*EXTDFT)
     D screc         E ds                  extname(scale) inz(*EXTDFT)
     D lhrec         E ds                  extname(prdlbhist) inz(*EXTDFT)
     D usrec         E ds                  extname(ucisplits) inz(*EXTDFT)
720aAD uprecuom      E ds                  extname(upc) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pSessId        s             40    varying
     D  pUser          s             10    varying
     D  pPgm           s             20
     D  pSubCmd        s              1    varying
     D  pWhse          s              3p 0
     D  pStation       s              2    varying
	    d  pUCI           s             50    varying
	    d  pSlot          s             15    varying
	    d  pOutStr        s           1536    varying

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.wrtsessl

     D ucilic#         pr                  extpgm('UCILIC#')
      * Input
     D   unext                       13  0 const
     D   uwhse                        3  0 const

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#LICINFO
      /COPY *libl/qcopysrc,C#LICHIST
      /COPY *libl/qcopysrc,C#LICENSE
      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#UCIINFO

     *----------------------------------------------------------------
     *  Convert Barcode Parms
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#CVTPARMS
      /COPY *libl/qcopysrc,C#BARCODE
720aA*
720aA*----------------------------------------------------------------
720aA*  Called programs
720aA*
720aAD @cvtdt          c                   const('CVTDTE')

720aAD $cvtdt          ds
720aAD  $cvcmd                 1      8
720aAD  $cvprg                 9     18
720aAD  $cvd6i                19     24
720aAD  $cvd8i                25     32
720aAD  $cvd6o                33     38  0
720aAD  $cvd8o                39     46  0
720aAD  $cvsto                47     64
720aAD  $cvrtn                65     72
720aAD  $cverm                73    132
720aAD  $cvmsg                73     76

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $unext          s             13  0
720aAD blank6          s              6
     d ckupc           s             20
710dAd ckupc2          s             20
     d error           s               n
     d errmsg          s             50
     D forevr          s              1
650aAD logText         s            100
     d nextseq         s              2  0
     d nopick          s               n
     d opnCount        s              5  0
     d pDesc           s             40
     D pExpDte         s              6  0
     d pItem           s             15
     d pLcns           s             12
     D pLot            s             20
     D pPckDte         s              6  0
     D pPrdDte         s              6  0
     D pSellby         s              6  0
710gAd pUCISearch      s             20
710gAd pCaseSeq        s              5  0
710gAd uCaseSeq        s              5  0
     D pSerial         s             20
     D pWgt            s              9  3
     D pMessage        s             99
     D saveVer#        s                   like($slver#)
     d sq              c                   const(x'7D')
720aAD today           s              8  0
     D unexta          s             13
     d wkError         s               n
     d wkRerr2         s             50
720aAD workupc         s                   like(upupc)
710dAD UPumcd          S              1    Inz('1')

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       GUI User
     *      pPgm        GUI dictionary.program
     *      pWhse       Warehouse
     *      pStation    Scale Station
     *      PLine       Mfg Line
     *      PprdDate    Production Date
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
     c                   parm                    pSubCmd
     C                   parm                    pWhse
     C                   parm                    pStation
	    c                   parm                    pUCI
	    c                   parm                    pSlot
	    c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         exsr init;
         pMessage = ' ';

         // Write GLOSESSLOG record
         logText = 'objloc: function';
         wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);

         exsr AfterAct;

          // Put together JSON string
          pOutStr = '{'
                 +  '"uci":"'  + %trimr(puci) + '",'
                 +  '"desc":"'  + %trim(pdesc) + '",'
                 +  '"serial":"'  + %trim(pSerial) + '",'
                 +  '"wgt":"'  + %trim(%char(pWgt)) + '",'
                 +  '"lot":"'  + %trim(plot) + '",'
                 +  '"pTrn":"'  + %trim(%char(@pTrn#)) + '",'
710gA            +  '"pCaseSeq":"'  + %trim(%char(pCaseSeq)) + '",'
                 +  '"prddte":"'  + %trim(%char(pPrdDte)) + '",'
                 +  '"pckdte":"'  + %trim(%char(pPckDte)) + '",'
                 +  '"sellby":"'  + %trim(%char(pSellby)) + '",'
                 +  '"expdte":"'  + %trim(%char(pexpdte)) + '",'
                 +  '"pmessage":"'  + %trim(pMessage) + '",'
                 +  '"pLcns":"'  + %trim(pLcns) + '",'
                 +  '"pSlot":"'  + %trim(pSlot) + '",'
                 +  '"item":"'  + %trim(pitem) + '"'
                 + '}';

         return;
      /end-free

     *----------------------------------------------------------------
     *  init    Initial Data
     *----------------------------------------------------------------

     C     init          begsr
     *
     *   Get default values for the user.
     *
     C                   call      'GETUSER'
     C                   parm      pUser         $code            10
     C                   parm                    #whse             3 0
     C                   parm                    $emp#             5 0
     C                   parm                    #fnam            15
     C                   parm                    #init             1
     C                   parm                    #lnam            20
     C                   parm                    #whdp             5
     C                   parm                    #styp             1
     C                   parm                    #shft             6
     C                   parm                    #crew             6
     C                   parm      0             #nhrs             3 1
     C                   parm                    #rtn              8
720aA*
720aA*  Convert today's date into century format.
720aA*
720aAC                   eval      $cvcmd = '*CURCMD '
720aAC                   call      @cvtdt
720aAC                   parm                    $cvtdt
720aAC                   eval      today = $cvd8o
      /free
            // get scale record passed in
                  exec sql
                   select * into :screc
                    from scale
                     where scsta = :pStation;
      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  clr$licinfo  Clear $licinfo data structure fields
     *----------------------------------------------------------------

     C     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
     C                   clear                   $licinfo2
     C                   eval      $lnver# = savever#

     C                   eval      $lnuser = #user
     C                   eval      $lnemp# = $emp#
     C                   eval      $lnpgm  = #prog
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobn

     C                   endsr
     *----------------------------------------------------------------
     *  clr$uciinfo  Clear $uciinfo data structure fields
     *----------------------------------------------------------------

     C     clr$uciinfo   begsr
     C                   eval      savever# = $uiver#
     C                   clear                   $uciinfo
720aAC                   clear                   $uciinfo
     C                   eval      $uiver# = savever#
     C                   eval      $uiaddemp = $emp#
     C                   eval      $uiaddusr = $code
     C                   eval      $uiaddpgm  = #prog
     C                   eval      $uiaddjob  = #job
     C                   eval      $uiaddnbr = #jobn
     C                   endsr

     *----------------------------------------------------------------
     *  AfterAct     After action update
     *----------------------------------------------------------------

      /free
       begsr AfterAct;

       error = *off;
       exsr errorCheck;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  confirmQty  This routine confirms that Quantity exists in given
     *              Mfg Line in order to generate breakdown quantities
     *----------------------------------------------------------------

     C     confirmQty    begsr
     *
     * confirm quantity exists in slot file
     *
      /free
            // get scale record passed in
                  exec sql
                   select * into :screc
                    from scale
                     where scsta = :pStation;

            // confirm stock exists in line for breakdown
                   exec sql
                    select * into :slrec
                     from slot
                      where slwhse = :scwhse and slitem = :upitem
                            and slrlvl = :scmfgno and slstk1 <> 0
                            and slaisl = 'LIN' and slloc = '101'
                            fetch first row only;
                   if sqlstt = '00000';
                      // if item qty found update scale and move forward
                      pSlot = sldisp;
                   else;
                      pSlot = *blanks;
                      error = *on;
                      pMessage = 'Item ' + %trim(upitem) +
                                 ' has no case quantity in slot ' +
                                 'LIN-101-' + %char(scmfgno);
                   endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  errorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;
        // Make sure slot is passed
        if pSlot = *blanks;
           if pSubCmd = 'L';
              pMessage = 'License cannot be blank';
           else;
              pMessage = 'Slot cannot be blank';
           endif;
           error = *on;
        endif;

        // if slot is scanned then verify slot and return item
        if pSlot <> '*NOPICK' and scbblcns <> '*HUMAN';
            exec sql
             select *
             into :slrec
             from Slot
710cD   //     where sldisp = :pSlot and slwhse = :pWhse;
710cM          where sldisp = :pSlot and slwhse = :pWhse and slpick = 'Y';
           if sqlStt <> '00000';
              pmessage = 'Slot ' + %trim(pSlot) +
                         ' is invalid.  Please re-enter';
              error=*on;
           else;
              if slpick <> 'Y';
                 pmessage = 'Scanned slot must be a pick slot';
                 error = *on;
              endif;

              if slstat <> 'A ';
                 pmessage = 'Scanned slot not at proper status';
                 error = *on;
              endif;

              if slitem = '';
                 pmessage = 'Scanned slot has no item assigned';
                 error = *on;
              endif;

               if not error;
                  chain (slwhse:slitem) piritem;
                  pitem = ititem;
                  pdesc = itdesc;
               endif;

              // get oldest license from pick slot
              savever# = $slver#;
              clear $slot;
              clear $slot2;
              $slver# = savever#;
              $saOLcnsu = *on;
              $saToLcnsu = *on;
              $slwhseu = *on;
              $slwhse  = pwhse;
              $slwhdpu = *on;
              $slwhdp  = itwhdp;
              $slitemu = *on;
              $slitem  = ititem;
              $sldispu = *on;
              $sldisp  = pSlot;
650gA         $dricommand = '*SLOT';
650gA         $drisubcmd  = '%GET';
650gA         $drisys2upd = 'D';
              exsr zzzDriCop;
              if $drireturn='*OK' or $drireturn=*blanks;
                 if $saToLcns <> *blanks;
                    pLcns = $saToLcns;
                 else;
                    pLcns = $saOLcns;
                 endif;
              else;
                // license not found for slot entered
                 pLcns = '*NONE';
                 pMessage = $drimessage;
                 error = *on;
              endif;
           endif;
        endif;  // Configured to generate in Mfg Area instead Pick
        if pSubCmd <>'S' and pSubCmd <>'L';
        // only allow UCI that has not been used
        if %trim(pUCI) <> '';
           exsr clr$uciinfo;

           $uiWhse = pwhse;
           $uiuci  = puci;
710fA      $uiitem = ititem;

710fM      $dricommand = '*UCIINFO';
710fM      $drisubcmd  = '%CHKREPLEN';
710fD   // $dricommand = '*UCIINFO';
710fD   // $drisubcmd  = '%CKUCISPLT';
           $drisys2upd = 'D';
           exsr zzzdricop;
           // if return is *EXIST this means it has been used
           select;

              when $drireturn = '*EXIST';
                error = *on;
                pMessage = 'UCI already been used.  Please scan un-used UCI';

              // this means it exists and not used.  good to go
710fD         // when $drireturn = '*OK';
710fA         when $drireturn = '*OKUPD';
              // insert Barcode breakout code to return UCI values
              error = *off;
              exsr cvtBarcode;
              if not error;
                 // generate transaction to record labor for this bd
                 if sctran = 0;
                    exsr zzzcrtTran; // only if transaction zero
                 else;
                    @pTrn# = sctran;
                 endif;
                 nextseq = 1;
                 dow forevr = forevr;
                    exsr clr$licinfo;

                    $lnwhse  = pwhse;
                    $lnlcns  = $uilcns;
                    $lnseq  = nextseq;

                    $dricommand = '*LICINFO';
                    $drisubcmd  = '%GET';
                    $drisys2upd = 'D';
                    exsr zzzdricop;
                    if error;
                    // Update scale with next sequence
                       exec sql update scale
                        set scbbseq = :nextseq
                            where scsta = :pstation;
                       leave;
                    else;
                       // add one to nextseq and check next sequence
                       if nextseq = 99;
                          error = *on;
                          pMessage = 'No available License Seq. Numbers';
                          leave;
                       else;
                          nextseq = nextseq + 1;
                       endif;
                    endif;
                 enddo;
710gA            exsr zzGetBxbSq;
              endif;
              when $drireturn = '*OKADD';
              // insert Barcode breakout code to return UCI values
              error = *off;
              exsr cvtBarcode;
              if not error;
                 exsr crtCaseUCI; // scanned UCI was not found in UCIINFO
710hA            if error = *on;
710hA               leavesr;
710hA            endif;
                 if sctran = 0;
                    exsr zzzcrtTran; // only if transaction zero
                 else;
                    @pTrn# = sctran;
                 endif;
710gA            exsr zzGetBxbSq;
              endif;
              other;
                error = *on;
                pMessage = $drimessage;
           endsl;
        else;
           // if UCI is blank return error
           $drireturn = 'BLKUCI';
           pMessage = 'UCI cannot be blank';
           error = *on;
        endif;

          // get case item and make sure breakdown one exists
          if not error;
          savever# = $itver#;
          clear $item;
          clear $item2;
          $itver# = savever#;

          $itwhse = upwhse;
          $ititem = upitem;
          $dricommand = '*ITEM';
          $drisubcmd  = '%GETMAIN';
          $drisys2upd = 'D';
          exsr zzzdricop;
          if $drireturn <> '*OK';
             pMessage = $drimessage;
             error = *on;
          else;
710gA        // Item MUST be setup as either UCI Unique or UCI non Unique
710gA        if not error;
710gA           if $ifucicde <> '2' and $ifucicde <> '3' and
710gA              $ifucicde <> '4' and $ifucicde <> '5';
710gA              pMessage = 'Item ' + %trim($uiitem) +
710gA                       ' must be defined as UCI Unique ' +
710gA                       'or UCI non-Unique';
710gA              error = *on;
710gA           endif;
710gA        endif;
710hD        // ensure item is defined with breakdown 1
710hD   //   if not error;
710hD   //      if $itum2 =' ';
710hD   //         pMessage = 'Item ' + %trim($uiitem) +
710hD   //                 ' has no Breakdown 1 defined';
710hD   //         error = *on;
710hD   //      endif;
710hD   //   endif;
          endif;
          endif;
        endif;

        // if human readable license enter make sure it is not already
        // defined
        if pSubCmd = 'L';
           exsr clr$licinfo;

           $lnwhse  = pwhse;
           $lnlcns  = pSlot;
           $lnseq  = 1;

           $dricommand = '*LICINFO';
           $drisubcmd  = '%GET';
           $drisys2upd = 'D';
           exsr zzzdricop;
           if not error;
              error = *on;
              pMessage = 'License already exists.  Please re-enter';
           endif;
        endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  crtCaseUCI  Case UCI scanned to Start Box Breaker not found
     *              Most likely not UCI received so we should add
     *----------------------------------------------------------------

     C     crtCaseUCI    begsr
     *
     * if breaking down from pick slot then get license from line slot
     *
      /free
        // get oldest license from pick slot
        if nopick;
           savever# = $slver#;
           clear $slot;
           clear $slot2;
           $slver# = savever#;
           $saOLcnsu = *on;
           $saToLcnsu = *on;
           $slwhseu = *on;
           $slwhse  = pwhse;
           $slwhdpu = *on;
           $slwhdp  = itwhdp;
           $slitemu = *on;
           $slitem  = ititem;
           $sldispu = *on;
           $sldisp  = pSlot;
           $dricommand = '*SLOT';
           $drisubcmd  = '%GET';
           $drisys2upd = 'D';
           exsr zzzDriCop;
           if $drireturn='*OK' or $drireturn=*blanks;
              if $saToLcns <> *blanks;
                 pLcns = $saToLcns;
              else;
                 pLcns = $saOLcns;
              endif;
           else;
              // license not found for slot entered
              pLcns = '*NONE';
              pMessage = $drimessage;
              error = *on;
              leavesr;
           endif;
        endif;
      /end-free
     *
     * update sequence number for UCI Info and License Info
     *
      /free
            exec sql update scale
                     set scbbseq = 2
                     where scstat = :pstation;
      /end-free
     *
     * add record to uci file
     *
      /free

        exsr clr$uciinfo;
        $uiWhse = pwhse;
        $uiItem = ititem;
        $uiuci = pUCI;
        ucilic#($unext: pwhse);
        unexta = %editc($unext:'X');
        $uiuciLcns = 'U:' + unexta;
        $uiLcns = pLcns;
        $uiseq=1;
        $uiSerial = pSerial;
        $uiwgtlbs = pWgt;
        $uiWgtKgs = 0;
        $uiSelTrn# = 0;
        $uiSelLbl# = 0;
        $uiSelOrd = 0;
        $uiSelSeq = 0;
        $uiSelCSeq = 0;
        $uiSelTrax = ' ';
        $uiCrtBy = 'A';
720aA   if $bcgtin = *blanks;
720aA      $uiaGtin = 0;
720aA   else;
720aA      $uiaGtin  = %DEC($bcGTin:14:0);
720aA   endif;
720aA   workupc = blank6 + $bcgtin;
720aA   uputyp     = 'N';
720aA   exec sql select * into :uprecuom
720aA            from upc
720aA            where upwhse = :pwhse
720aA              and upITEM = :ititem
720aA              and upupc  = :workupc
720aA            fetch first row only;
720aA   $uiaUTyp  = uputyp;
720aA   $uiaSlUTyp = uputyp;
720aA   $uiaLot   = $bclot;
720aA   $uiaExpD  = $bcexpd;
720aA   $uiaEntD  = today;

720aA   // Lets add some more stuff for tracking
720aA   $uiaction = 'RCV';
720aA   $uiaolcns = $uilcns;
720aA   $uialcns = $uilcns;
720aA   $uiaoseq = $uiseq;
720aA   $uiscan = 'Y';

        $dricommand = '*UCIINFO';
        $drisubcmd  = '%ADD';
        $drisys2upd = 'D';
        exsr zzzdricop;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  cvtBarCode  Convert Bar Code for ALL AI information
     *----------------------------------------------------------------

     C     cvtBarcode    begsr
     c                   eval      nopick = *off
      * add the conversion of the UCI barcode
     C                   eval      $cbcmd = '*ALL    '
     C                   eval      $cbbar = pUCI
     c                   clear                   $barcode
     c                   clear                   $barcode2
     *
     C                   call      'CVTBAR'
     C                   parm                    $cbcmd            8
     C                   parm                    $cbbar          100
     C                   parm                    $cbcod            3 0
     C                   parm                    $cbdec            1 0
     C                   parm                    $cbdsc           30
     C                   parm                    $cbpos            3 0
     C                   parm                    $cbtyp            1 0
     C                   parm                    $cbv1            11 3
     C                   parm                    $cbv2            50
     C                   parm                    $cbrtn            8
     C                   parm                    $cberm           60
     C                   parm                    $cbven           10 0
     C                   parm                    $cvtdata
     C                   parm                    $cvtdata2
     c                   eval      $barcode = $cvtdata
     c                   eval      $barcode2 = $cvtdata2
     * if gtin not found, error for invalid barcode scanned
     c                   if        not $bcGtinSent
     c                             and not $bcai99sent
     c                   eval      error = *on
     C                   eval      pMessage = 'Invalid Barcode Scanned. '
     C                             + 'Scan GS1 barcode.'
     c                   else
      *  Save original Case scan in ckupc2 for later verification
     c                   movel     $bcGtin       ckupc2
      *  right adjust Case UCI to use in sql below to verify breakdown
      *  UCI exists for Box Breaker to use
710gAC                   movel     $bcgtin       $CSTR
710gAC                   call      'ADJUST'
710gAC                   parm      '*RIGHT  '    $CCMD             8
710gAC                   parm                    $CSTR            30
710gAc                   move      $cstr         pucisearch

710gA *  Get Breakdown Upc from query below if it exists
710gA *  otherwise the value will be blank
710gA /free
710gA
710gA         ckupc = *blanks;
710gA         exec sql select upupc into :ckupc
710gA          from upc as bd
710gA            left join piritem as itm
710gA              on bd.upwhse=itm.itwhse and bd.upitem=itm.ititem
710gA           where bd.uputyp='1' and bd.upuom=itm.itum2
710gA            and (select count(*) from upc as cas where
710gA              cas.upwhse=:pWhse and cas.upupc=
710gA                :pUCISearch and bd.upitem=cas.upitem)<>0
710gA            fetch first row only;
710gA

710gA  // if a gs199 label was scanned we should get the weight associated
710dA                    if $bcai99sent;
710 A                       select;
710 A                       when $uiwgtlbs <> *zeros;
710 A                          $bcPNtLbSent = *on;
710 A                          $bcPNtLb = $uiwgtlbs;
710 A                       when $uiwgtkgs <> *zeros;
710 A                          $bcPNtKgSent = *on;
710 A                          $bcPNtKg = $uiwgtkgs;
710 A                       other;
710 A                          $bcPNtKgSent = *off;
710 A                          $bcPNtKg = *zeros;
710 A                          $bcPNtLbSent = *off;
710 A                          $bcPNtLb = *zeros;
710 A                       endsl;
710dA                    endif;
710 A
710 A /end-free
     c                   endif
710dA* -----------------------------------------------------------------------
710dA* This code was added to check that the user has scanned a vailid case
710dA* UCI, originally this was checked up above, but now we are checking here
710dA* because the above code was changed to check for s breakdown UPC........
710dA /free
710dA                    if $bcGtinSent;
710dA                       $bcgtin = %trim(ckupc2);
710dA                       Clear $cstr;
710dA /end-free
710dAC                   movel     $bcgtin       $CSTR
710dAC                   call      'ADJUST'
710dAC                   parm      '*RIGHT  '    $CCMD             8
710dAC                   parm                    $CSTR            30
710dAc                   move      $cstr         ckupc2

710dA* Now lets check the UPC file for case UOM, like we used to..........
710dA /free
710eA     chain (pWhse: ckupc2) upc;
710dA       if Not %found(upc);
710dA          error = *on;
710dA          pMessage = 'GTIN ' + %trim(ckupc2) + ' associated' +
710dA                     ' with the UCI is not defined';
710dA          else;
710dA          If uputyp <>'N';
710dA             error = *on;
710dA             pMessage = 'Not a case UCI..Please re-enter';
710dA          EndIf;
710dA       EndIf;
710dA /end-free
710dAc                   endif
710dA* -----------------------------------------------------------------------
      * Load Expiration Date
      /free
                         if $bcExpDSent;
                           test(de) *ymd $bcExpD;
                           if %error();
                              error = *on;
                              pMessage = 'GS1 Expiration date invalid';
                           else;
                              pPrdDte=%dec(%date($bcExpD: *ymd): *mdy);
                           endif;
                         endif;
      /end-free
      * Load Sell by Date
      /free
                         if $bcSlByDSent;
                           test(de) *ymd $bcSlByD;
                           if %error();
                              error = *on;
                              pMessage = 'GS1 Sales By Date invalid';
                           else;
                              pPrdDte=%dec(%date($bcSlByD: *ymd): *mdy);
                           endif;
                         endif;
      /end-free
      * Load Manufacturing Date
      /free
                         if $bcProdDSent;
                           test(de) *ymd $bcProdd;
                           if %error();
                              error = *on;
                              pMessage = 'GS1 Production Date (11) invalid';
                           else;
                              pPrdDte=%dec(%date($bcProdd: *ymd): *mdy);
                           endif;
                         endif;
      /end-free
      * Load Packing Date
      /free
                         if $bcPackDSent;
                           test(de) *ymd $bcPackd;
                           if %error();
                              error = *on;
                              pMessage = 'GS1 Pack Date invalid';
                           else;
                              pPrdDte=%dec(%date($bcPackd: *ymd): *mdy);
                           endif;
                         endif;
      /end-free
      * Load Lot
     c                   if        $bcLotSent
     c                   eval      plot   = $bcLot
     c                   else
     c                   eval      plot = *blanks
     c                   endif
      * Load Serial #
     c                   if        $bcSer#Sent
     c                   eval      pSerial   = $bcSer#
     c                   else
     c                   eval      pSerial = *blanks
     c                   endif
     * Verify Breakdown UPC and also ensure stock exists for new breakdown
      /free
         if not error;
710gA      // if ckupc was found further up in sql statement
710gA      // it means it found a breakdown.  otherwise it will
710gA      // throw error below
710gA      if ckupc <> *blanks;
           // get item master
710eA        chain (pWhse:upitem) piritem;
             if %found(piritem);
                pItem = ititem;
                pDesc = itdesc;
                if pSlot = '*NOPICK' or scbblcns='*HUMAN';
                  nopick = *on;
                  exec sql
                    select * into :usrec
                     from ucisplits
                       where usgs1c = :puci and uswhse = :pwhse
                             fetch first row only;
                    if sqlstt <> '00000' or scbblcns='*HUMAN';
                       // if no ucisplits record found confirm case quantity
                       // exists for scanned uci, otherwise it will return them
                       // to the existing uci info to change, add to or cancel
                       exsr ConfirmQty;
                    endif;
                endif;
             else;
                pMessage = 'Item ' + %trim(upitem) + ' associated' +
                           ' with the UCI is invalid';
                error = *on;
             endif;   // item found in piritem
           else;
710hA         chain (pWhse:upitem) piritem;
710hA         pitem=upitem;
710hA         if itum2 <> *blanks;
710dA            pMessage = 'Item associated' +
710eA                       ' with the UCI has no breakdown UPC';
                 error = *on;
710hA         endif;
           endif;   // if ckupc not blanks (means breakdown UPC exists)
         endif;   // if not error
      /end-free
      * Load Catch Weight
     c                   if        not error
     c                   if        $bcPNtLbSent
     c                   eval      pwgt  = $bcPNtLb
     c                   else
     c                   eval      error = *on
     c                   eval      pmessage = 'Weight MUST exist ' +
     c                             'in scanned UCI'
     c                   endif
     c                   endif
     C                   endsr

     *----------------------------------------------------------------
     *  ZZZCRTTRAN   Create transaction
     *----------------------------------------------------------------

     C     zzzcrttran    begsr

     C                   eval      @pcmd = '*CRTSTRT'

     C                   call      'ADJTRAN2'
     C                   parm                    @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      0             @ptrn#            7 0
     C                   parm      'BXBRK'       @ptask            6
     C                   parm      pWhse         @pwhse            3 0
     C                   parm      itwhdp        @pwhdp            5
     C                   parm      itstyp        @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      ' '           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
     C                   parm      pUser         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
710bA /free
710bA           exec sql update scale
710bA            set sctran = :@pTrn#
710bA                where scsta = :pstation;
710bA           sctran = @ptrn#;
710bA /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
     C                   eval      $dridata2 = $licinfo2
     C                   when      $dricommand = '*LICHIST'
     C                   eval      $dridata = $lichist
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $dridata = $license
     C                   eval      $dridata2 = $license2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $dridata = $uciinfo
     C*                  eval      $dridata2 = $uciinfo2
720aMC                   eval      $dridata2 = $uciinfo2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                             or $dricommand = '*LICENSE'
     C                             or $dricommand = '*LICINFO'
720aAC                             or $dricommand = '*UCIINFO'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     c                   endsl

     C                   if        $drireturn <> '*OK'
     C                   eval      error = *on
     c                   endif

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
     C                   eval      $licinfo2 = $dridata2
     C                   when      $dricommand = '*LICHIST'
     C                   eval      $lichist = $dridata
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $license = $dridata
     C                   eval      $license2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $uciinfo = $dridata
     C*                  eval      $uciinfo2 = $dridata2
720aMC                   eval      $uciinfo2 = $dridata2
     C                   endsl

     C     enddricop     endsr
710gA
710gA*----------------------------------------------------------------
710gA*  ZZGETBXBSQ   Get Box Breaker Sequence for Case UCI in case
710gA*               non unique
710gA*----------------------------------------------------------------
710gA
710gAC     zzGetBxbSq    begsr
710gA /free
710gA    // look for existing match in UCIPLITS for Case UCI
710gA    // return the greatest case sequence number
710gA    exec sql select usbxbsq into :pCaseSeq
710gA             from UCISPLITS
710gA               where uswhse=:pWhse and
710gA                     usgs1c=:pUCI
710gA                 order by usbxbsq desc
710gA                 fetch first row only;
710gA
710gA    if sqlStt = sqlSuccess;
710gA       // if ucisplits record was found this means it has
710gA       // been used and we should look to see if *UNASSIGNED
710gA       // record exists.  If one exists we should add one to
710gA       // existing sequence, otherwise use one found since not
710gA       // completed properly
710gA       uCaseSeq = *zeros;
710gA       exec sql select usbxbsq into :uCaseSeq
710gA                from UCISPLITS
710gA                  where uswhse=:pWhse and
710gA                        usgs1c=:pUCI and
710gA                        usbxbsq=:pCaseSeq and
710gA                        usgs1b='*UNASSIGNED'
710gA                     fetch first row only;
710gA       if sqlstt = sqlSuccess;
710gA          // when *unassigned found case was completed and sequence
710gA          // should be bumped up one for next scan of non-unique case
710gA          pCaseSeq = uCaseSeq + 1;
710gA       else;
710gA          // since no unassigned record found this means case was not
710gA          // completed and the original case found will be returned to
710gA          // complete
710gA       endif;
710gA    else;
710gA       // if not ucisplits record found for scanned case we should
710gA       // return case number 1 as starting case to breakdown
710gA       pCaseSeq = 1;
710gA    endif;
710gA
710gA /end-free
710gAC                   endsr
