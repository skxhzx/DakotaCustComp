      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M28800       Gui Item Maintenance repack
     *  24 November  2020
     *  Lynn McMahon
     *
     *  Revisions:
     *
     *    11/24/20  LMC  7.40
     *      - Created.
     *
     *
     *
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk
     Fkititem   if   e           k disk
     Fvslot1    if   e           k disk
     Fslot2     if   e           k disk

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *
     * Data structure
     *
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D dbgflgExists    s               n
     D debug           s               n
     D dpCombo         s             20
     D logText         s            100
     D savsubcmd       s                   like($drisubcmd)
     D uxflag          s              1
     D kywhse          s                   like(pwhse)
     D  pWhse          s              3p 0
	    d  pitem          s             15
	    d  poday          s              3p 0
     D  PAEITEM        S             15
     D  PAESITM2       S             15
     D  PAESDISP       s             12
     D  PAESQTY1       s              3p 0
     D  PAESUM1        s              2
     D  PAESQTY2       s              3p 0
     D  PAESUM2        s              2
     D  PAESQTY3       s              3p 0
     D  PAESUM3        s              2
     D  PAERPTP        s              1
     D  PAEDISP        s             12
     D  pSubCmd        s             10
     d  pkirptp        s              1
     d  pkidisp        s             12
     d  pkiqty1        s              3p 0
     d hldrsrv         s                   like(slrsrv)

     D client          s             10
     D clientloc       s             10
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pObjLoc      External object location called from.
     *      pParmStr1   String of '|' delimited parameters
     *      pParmStr2   String of '|' delimited parameters
     *      pParmStr3   String of '|' delimited parameters
     *
     *    Returned Parameters
     *      pmessage     Error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  pSessId        s             40
     D  pUser          s             10
     D  pDict          s             10
     D  pPgm           s             20
     D  pObjLoc        s             10
     D  pparmStr1      s            999
     D  pparmStr2      s            999
     D  pparmStr3      s            999


     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------

     D driItemCalled   s               n
     D driSlotCalled   s               n


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.dricop
      /copy qcopysrc,p.driitem
      /copy qcopysrc,p.drislot
      /copy qcopysrc,p.wrtsessl
      /copy qcopysrc,p.getclien

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS
      /COPY *libl/qcopysrc,C#DRIPARMP

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#dairyla
MRTaA /copy qcopysrc,id#MRT
GRCaA /copy qcopysrc,id#grc
     *
     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT
     D saveVer#        s                   like($itver#)
     D sv$Item         ds                  likeds($item)
     D sv$Item2        ds                  likeds($item2)
     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------

     D/copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d ConvertField    pr
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

     d ExtractParms    pr

     d ExtractParmStr  pr
     d  parmStr                     999    varying

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pDict
     C                   parm                    pPgm
     C                   parm                    pObjLoc
     C                   parm                    pparmStr1
     C                   parm                    pparmStr2
     C                   parm                    pparmStr3
      /free

	        pitem = %xlate(xlower: xupper: pitem);
	        //pmitem = %xlate(xlower: xupper: pmitem);
	        //pcitem = %xlate(xlower: xupper: pcitem);
         if dbgflgExists;
           chain(e) (#pgm) bfcdbgflg;
           if %found(bfcdbgflg);
             debug = (bdfflag = 1);
           else;
             debug = *off;
           endif;
         endif;

         // Combine dictionary/program

         dpCombo = %trim(pDict) + '.' + pPgm;

         *inlr = *on;
         pMessage= ' ';

        // Extract parameters from delimited string

        ExtractParms();

         // Determine DRI subcommand to use.

         select;
           when pObjLoc = 'FLDVALID';
             exsr edit;
         endsl;

         // Write debug record if flag is on.

         if debug;
           exsr wrtDebugParms;
         endif;

         // If an error occurs outside of FLDVALID,
         //   write a record to the debug log, regardless of flag.
         // We don't do this for FLDVALID because the calling program
         // will catch it and display the error.


         if pObjLoc <> 'FLDVALID' and pMessage<> ' ';
           if not debug;
             exsr wrtDebugParms;
           endif;
           exsr wrtDebugError;
         endif;

         if driItemCalled;
           driItem('%CLOSE': $pprogram: $drireturn: $drimessage:
                    $dridata: $dridata2);
         endif;
         if driSlotCalled;
           driSlot('%CLOSE': $pprogram: $drireturn: $drimessage:
                    $dridata: $dridata2);
         endif;
         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         getclient(client: clientLoc);
         open(e) bfcdbgflg;
         if %error;
           dbgflgExists = *off;
         else;
           dbgflgExists = *on;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  wrtDebugParms  Write out debug parm record
     *----------------------------------------------------------------

      /free
       begsr wrtDebugParms;

         bdtype = 'PARMS';

         bdvalues = 'pSessId:' + %trimr(pSessId) + ', '
                  + 'pUser:' + %trimr(pUser) + ', '
                  + 'pDict:' + %trimr(pDict) + ', '
                  + 'pPgm:' + %trimr(pPgm) + ', '
                  + 'pWhse:' + %char(pWhse) + ', '
                  + 'pObjLoc:' + %trimr(pObjLoc) + ', '
                  + 'pSubCmd:' + %trimr(pSubCmd) + ', '
                  + 'pAESITM2:' + %trimr(pAESITM2) + ', '
                  + 'pMessage:' + %trimr(pMessage);

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
     *  wrtDebugError  Write out debug error
     *----------------------------------------------------------------

      /free
       begsr wrtDebugError;

         bdtype = 'ERROR';

         bdvalues = pMessage;

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
     C     edit          begsr



     *  Verify Item exist
      /free
        exsr getitem;
      /end-free
     c
     *  Verify Slot for Output definition first
      /free
        if PAESITM2 <>' ' and
           error = *off;
          if pAESQTY2>0 and $itum2 = ' ' or
             pAESQTY3>0 and $itum3 = ' ';
            error= *on;
            PMESSAGE  = 'Qty not valid without parent UOM';
          endif;
        endif;
      /end-free
     *
     *   verify that On-Demand Slot for parent actually has item in it
     *
      /free
        if error = *off and paesdisp <> ' ';
          savever# = $slver#;
          clear $slot;
          clear $slot2;
          $slver# = savever#;

          $slwhseu = *on;
          $slwhse  = pwhse;
          $slwhdpu = *on;
          $slwhdp  = $itwhdp;
          $sldispu = *on;
          // if Merit Foods be sure to send base slot and return
          // virtual since they use virtual slots for case ODR slot
          if client = Merit;
            chain (pwhse:$itwhdp:paesdisp) vslot1;
            if %found(vslot1);
              $sldisp = vspdis;
            else;
              $sldisp  = paesdisp;
            endif;
          else;
            $sldisp = paesdisp;
          endif;
          $saitemu = *on;
          $saitem  = PAESITM2;
          $dridata = $slot;
          $dridata2 = $slot2;
          driSlotCalled = *on;
          drislot('%VFYINSLOT': $pprogram: $drireturn: $drimessage:
                  $dridata: $dridata2);
          if client = Merit and $drireturn = 'ITMFOUND';
            paesdisp = $sldisp;
          endif;

          // do not enforce on-demand exist rule if parent item is an
          // on-demand item.  The virtual probably will not exist.
          chain (pwhse:PAESITM2) kititem;
          if not %found(kititem)
             or (%found and kirptp <> '2');
            if $drireturn = 'ITMFOUND';
              chain (pwhse:$slwhdp:paesdisp) slot2;
              if client = Merit
                 or client = Greco;
                hldrsrv = slrsrv;
                slrsrv = ' ';
              endif;
              //  Slot found but ensure it is acceptable slot
              if sldesg = 'BFC' or slaisl='RCV' or
                 slaisl='STG' or slaisl='OSS' or slaisl='RTN'
                 or slstat<>'RP' or slrsrv='V'
                 or slaisl='USR';
                error = *on;
                pmessage = 'Slot not valid';
              else;
                error = *off;
              endif;
              if client = Merit
                 or client = Greco;
                slrsrv = hldrsrv;
              endif;
            else;
              // see if repack item exist in parent slot
              //  before throwing error
              savever# = $slver#;
              clear $slot;
              clear $slot2;
              $slver# = savever#;

              $slwhseu = *on;
              $slwhse  = pwhse;
              $slwhdpu = *on;
              $slwhdp  = $itwhdp;
              $sldispu = *on;
              // if Merit Foods be sure to send base slot and return
              // virtual since they use virtual slots for case ODR slot
              if client = Merit;
                chain (pwhse:$itwhdp:paesdisp) vslot1;
                if %found(vslot1);
                   $sldisp = vspdis;
                else;
                   $sldisp  = paesdisp;
                endif;
              endif;
              $saitemu = *on;
              $saitem  = PAESITM2;
              $dridata = $slot;
              $dridata2 = $slot2;
              driSlotCalled = *on;
              drislot('%VFYINSLOT': $pprogram: $drireturn: $drimessage:
                  $dridata: $dridata2);
              if $drireturn <> 'ITMFOUND';
                error = *on;
                pmessage = 'Item not in slot';
              endif;
            endif;
          else;
            if client = Merit and  $drireturn = 'ITMFOUND';
              paesdisp = $sldisp;
            endif;
            chain (pwhse:$slwhdp:paesdisp) slot2;
            if not %found;
              error = *on;
              pmessage = 'Slot not valid';
            else;
              if client = Merit
                 or client = Greco;
                hldrsrv = slrsrv;
                slrsrv = ' ';
              endif;
              //  Slot found but ensure it is acceptable slot
              if sldesg = 'BFC' or slaisl='RCV' or slaisl='RTN' or
                 slaisl='STG' or slaisl='OSS' or slaisl='USR           '
                 or slstat<>'RP' or slrsrv='V';
                error = *on;
                pmessage = 'Slot not valid';
              endif;
              if client = Merit
                 or client = Greco;
                slrsrv = hldrsrv;
              endif;
            endif;
          endif;
        endif;
      /end-free
     *
     *  Only allow on-demand pick slot for type 2
     *
      /free
        if error = *off;
          if paerptp ='1' and paesdisp<>' '
             and paesitm2<>' ';
            error = *on;
            pmessage = 'On-Demand only valid for Repack Type 2';
          endif;
        endif;
      /end-free
     *
     *  Only allow work order type to have a repack item as parent
     *
      /free
        if error = *off;
          pmessage = ' ';
          if paerptp = '1' and $ittype='R'
             and paesitm2 <> ' ';
            error = *on;
            pmessage ='Repack items only valid with On-Demand Repacks';
          else;
          endif;
        endif;
      /end-free
     *
     *  Do not allow recursive items.  The same repack item cannot be
     *  be listed on that item as a parent item
     *
      /free
        if error = *off;
          pmessage = ' ';
          if paeitem = paesitm2;
            error = *on;
            pmessage = 'Recursive item not allowed';
          endif;
        endif;
      /end-free
     *
     *  make sure on-demand pick slot is only allowed with type 2
     *
     *
     *  make sure on-demand pick slot is entered for type 2
     *
      /free
        if error = *off;
          pMessage = ' ';
          if pAERPTP='2' and paesdisp=' ';
            error = *on;
            pMessage ='On-Demand Slot must be entered for Repack Type 2';
          endif;
        endif;
      /end-free
     *
     *  make sure a qty is assocaited with at least one uom on output
     *
      /free
        if error = *off;
          if pAESQTY1=0 and pAESQTY2=0 and pAESQTY3 = 0
             and paesitm2<>' ';
            error = *on;
            pMessage ='Qty required for at least one UOM';
          endif;
        endif;
      /end-free
     *
     *  make at least one component item entered
     *
     c***                if        error = *off
     c***                eval      errmsg = ' '
     c***                if        recno=0 and w1citm2 = ' '
     *
     C***                eval      error = *on
     C***                eval      *in35 = *on
     C***                eval      *in15 = *on
     C***                eval      errmsg = err(7)
     c***                exsr      zm0105
     *
     C***                endif
     C***                endif
     *
     C     endck1        endsr

     *----------------------------------------------------------------
     *  getItem  Get item info.
     *----------------------------------------------------------------

     c     getitem       begsr

      /free
         error = *off;

         savever# = $itver#;
         clear $item;
         clear $item2;
         $itver# = savever#;

         $itwhse = pwhse;
         $ititem = paesitm2;
         $dridata = $item;
         $dridata2 = $item2;

         driItemCalled = *on;
         driItem('%GETMAIN': $pprogram: $drireturn: $drimessage:
                  $dridata: $dridata2);

         $item = $dridata;
         $item2 = $dridata2;

         sv$item = $item;
         sv$item2 = $item2;

         select;
           when %error;
             error = *on;
           when $drireturn <> '*OK';
             error = *on;
             pmessage = $drimessage;
         endsl;

      /end-free
     c                   endsr
     *----------------------------------------------------------------
     *  ConvertField   Convert incoming field to DRI field
     *----------------------------------------------------------------

     p ConvertField    b
     d ConvertField    pi
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

      /free

       monitor;

         select;

           when parmName = 'MODE';
             pSubCmd = %xlate(xlower: xupper: parmValue);

           when parmName = 'AEWHSE';
             if parmValue = '';
               parmValue = '0';
             endif;
             pwhse =  %dec(parmValue: 3: 0);

           when parmName = 'AESITM2';
             pAESITM2 = %trim(parmValue);
	            pAESITM2 = %xlate(xlower: xupper: paesitm2);

           when parmName = 'AESDISP';
             pAESDISP = %trim(parmValue);
	            pAESDISP = %xlate(xlower: xupper: paesdisp);

           when parmName = 'AESQTY1';
             if parmValue = '';
               parmValue = '0';
             endif;
             pAESQTY1 =  %dec(parmValue: 3: 0);

           when parmName = 'AESQTY2';
             if parmValue = '';
               parmValue = '0';
             endif;
             pAESQTY2 =  %dec(parmValue: 3: 0);

           when parmName = 'AESQTY3';
             if parmValue = '';
               parmValue = '0';
             endif;
             pAESQTY3 =  %dec(parmValue: 3: 0);

           when parmName = 'CALCULA008';
             pAEITEM = %trim(parmValue);
	            pAEITEM = %xlate(xlower: xupper: paeitem);

           when parmName = 'CALCULA009';
             pAERPTP = %trim(parmValue);

           when parmName = 'CALCULA010';
             pAEDISP = %trim(parmValue);
	            pAEDISP = %xlate(xlower: xupper: paedisp);


         endsl;

       on-error;

         pMessage = 'Error extracting parameter '
                  + %char(parmCount) + ' '
                  + parmName + ' '
                  + '(' + parmValue + ')'
                  + '('
                  + %trimr(#Job) + '/'
                  + %trimr(#JobNbr) + '/'
                  + %trimr(#user)
                  + ')';

       endmon;

       return;

      /end-free

     p                 e
     *----------------------------------------------------------------
     *  ExtractParms   Extract parms from parameter string
     *----------------------------------------------------------------

     p ExtractParms    b
     d ExtractParms    pi

     * Local Variables

     d parmStr         s            999    varying

      /free

         // Error if first parameter string is blank

         if pParmStr1 = '';
           pMessage = 'Error: Parameter string is empty '
                    + '('
                    + %trimr(#Job) + '/'
                    + %trimr(#JobNbr) + '/'
                    + %trimr(#user)
                    + ')';
           return;
         endif;

         // Extract parms for string 1

         parmStr = %trim(pParmStr1);
         ExtractParmStr(parmStr);

         if pMessage <> '';
           return;
         endif;

         // Extract parms for string 2

         parmStr = %trim(pParmStr2);
         ExtractParmStr(parmStr);

         if pMessage <> '';
           return;
         endif;

         // Extract parms for string 3

         parmStr = %trim(pParmStr3);
         ExtractParmStr(parmStr);

         if pMessage <> '';
           return;
         endif;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ExtractParmStr   Extract parms from single parameter string
     *----------------------------------------------------------------

     p ExtractParmStr  b
     d ExtractParmStr  pi
     d  parmStr                     999    varying

     * Local Variables

     D parmCount       s              3  0
     D parmGroup       s            200    varying
     D parmLen         s              5  0
     D parmName        s             10    varying
     D parmStrLen      s              5  0
     D parmValue       s            100    varying
     D pos             s              5  0
     D start           s              5  0

      /free

       // Parameters are separated by '|'

       start = 1;
       parmStrLen = %len(parmStr);
       parmCount = 0;

       dow start <= parmStrLen;

         // Extract parameter ('fldname=value')

         pos = %scan('|': parmStr: start);

         parmCount += 1;

         if pos = 0;
           parmGroup = %subst(parmStr: start);
           start = parmStrLen + 1;
         else;
           parmLen = pos - start;
           parmGroup = %subst(parmStr: start: parmLen);
           start = pos + 1;
         endif;

         // Extract parameter name

         pos = %scan('=': parmGroup: 1);

         // If no '=' found, invalid group.

         if pos = 0;
           pMessage = 'Error: Invalid parameter group '
                    + %char(parmCount) + ' '
                    + '(' + parmGroup + ')'
                    + '('
                    + %trimr(#Job) + '/'
                    + %trimr(#JobNbr) + '/'
                    + %trimr(#user)
                    + ')';
           leave;
         endif;

         parmName = %subst(parmGroup: 1: pos - 1);

         // Extract parameter value

         parmLen = %len(parmGroup);

         if parmLen = pos;
           parmValue = '';
         else;
           parmValue = %subst(parmGroup: pos + 1);
         endif;

         // Convert extracted value and put into DRI field

         ConvertField(parmCount: parmName: parmValue);
         if pMessage <> '';
           leave;
         endif;

       enddo;

       return;

      /end-free

     p                 e
