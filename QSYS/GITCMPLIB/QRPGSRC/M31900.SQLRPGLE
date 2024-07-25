      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2021 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M31900      Item adjustment
     *  30 December 2021
     *  Lynn McMahon
     *
     *  Revisions:
     *
     *    12/30/21  LMC  7.50
     *      - Created.
     *
750aA*    01/26/22  LMC  7.50a
     *      - Fix:  Don't trim adjustment code, some clients have
     *        code like ' 1'
     *
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     F*options   if   e           k disk
     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk
     Fitemdef   if   e           k disk

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D FromStamp       s               z
     D ToStamp         s               z
     D oldeststamp     s               z
     D ts              s               z

     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

     D bfcoffset       s              3  0 inz(0)

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D oprec         E Ds                  Extname(opsrcvlbl)
     D lbrec         E Ds                  Extname(label)
     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#finkle
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
	    d  pdept          s              5
	    d  pdisp          s             12
	    d  pitem          s             15
	    d  ptype          s              1
	    d  padjcd         s              2
	    d  padjuom        s              1
	    d  padjqty        s              5p 0
	    d  padjwgt        s              9p 2
	    d  pmemo          s             30

     D workdte         s              6  0
     D today           s              8  0
     D  pSubCmd        s             10
     D client          s             10
     D clientloc       s             10
     D e$whse          s              3  0
     D e$emp#          s              5  0
     D e$fnam          s             15
     D e$init          s              1
     D e$lnam          s             20
     D e$whdp          s              5
     D e$styp          s              1
     D e$shft          s              6
     D e$crew          s              6
     D e$nhrs          s              3  1
     D e$rtn           s              8
     D e$bpu           s              1
     D e$lng           s              2

     D $apslt          s             12
     d $pdev           s             10
     D $pform          s             10
     D nxtrpcl#        s              7  0
     D woslot          s             12
     D phven           s             11  0
     D pprinter        s             10
     D lblpgm          s                   like(oplpgm)
     D done            s              1
     D svhi            s              2  0
     D svtie           s              4  0
     D today6          s              6  0
     D today6a         s              6

     D error           s               n
     D forevr          s               n
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pObjLoc     External object location called from.
     *      pparm1      parm string 1
     *      pparm2      parm string 2
     *      pparm3      parm string 3
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
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.dricop
      /copy qcopysrc,p.wrtsessl
      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.cvtdte
      /copy qcopysrc,p.getuser
      /copy qcopysrc,p.cvtcase
      /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS
      /COPY *libl/qcopysrc,C#DRIPARMP

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#dairyla
     D*----------------------------------------------------------------
     D*  Called program
     D*
     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#license
      /COPY *libl/qcopysrc,C#item
      /COPY *libl/qcopysrc,C#slot
      /COPY *libl/qcopysrc,C#LICINFO
     D saveVer#        s                   like($liver#)
     D drilicense      s               n   inz(*off)

     *----------------------------------------------------------------
     *  CVTDTE constant and parameter data structure.
     *----------------------------------------------------------------

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

         $drisubcmd = ' ';
         pSubCmd = %xlate(xlower: xupper: pSubCmd);
         select;
           when pSubCmd = 'A';
             select;
               when pObjLoc = 'FLDVALID';
                 $drisubcmd = '%VERIFYADD';
               when pObjLoc = 'AFTERACT';
                 //$drisubcmd = '%ADD';
             endsl;
           when pSubCmd = 'C' or pSubCmd = 'U';
             select;
               when pObjLoc = 'FLDVALID';
                 //$drisubcmd = '%VERIFYCHG';
               when pObjLoc = 'AFTERACT';
             endsl;
           when pSubCmd = 'D';
             select;
               when pObjLoc = 'FLDVALID';
                 $drisubcmd = '%VERIFYDEL';
               when pObjLoc = 'AFTERACT';
                 //$drisubcmd = '%DELETE';
             endsl;
           other;
             $drisubcmd = '%' + pSubCmd;
         endsl;

        exsr getcurrstamp;
         exsr edit;


         if error = *off;
           exsr Update;
         endif;
         return;
      /free
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

         $drisubcmd = '%CLOSE';
         // Call DRI program.

         driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
                $drireturn: $drimessage: $dridata: $dridata2);
         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         puser   = %xlate(xlower: xupper: puser);
         ppgm    = %xlate(xlower: xupper: ppgm);
         getclient(client: clientLoc);
         open(e) bfcdbgflg;
         if %error;
           dbgflgExists = *off;
         else;
           dbgflgExists = *on;
         endif;
         $cvprg = #prog;
         $cvcmd = '*CURCMD ';
         cvtdte ($cvtdt);
         today = $cvd8o;

         getUser(puser: e$whse: e$emp#: e$fnam: e$init: e$lnam:
                 e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                 e$bpu: e$lng);
      /free
        getclient(client: clientLoc);
      /free
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  Edit              Edit Adjusment Data
     *----------------------------------------------------------------

      /free
       begsr Edit;

        // type must be sent
        if pType = ' ';
          pMessage = 'Increase or Decrease must be selected';
          error = *on;
          leavesr;
        endif;

        // Adjustment Qty must be greater than 0
        if pAdjQty <= 0;
          pMessage = 'Adjustment Qty must be Greater than 0';
          error = *on;
          leavesr;
        endif;

        // Adjustment Qty cannot be greater than 999 on Breakdown adj
        if pAdjUOM = '1' or pAdjUOM = '2';
          if pAdjQty > 999;
            pMessage = 'Adjustment Qty cannot be Greater than 999';
            error = *on;
            leavesr;
          endif;
        endif;

        // Adjustmenet Code must be selected
        if pAdjCd = ' ';
          pMessage = 'Adjustment Code must be selected';
          error = *on;
          leavesr;
        endif;

        // Get the item to see if CW edit needs to be performed
        savever# = $itver#;
        clear $item;
        clear $item2;

        $itWhse = pwhse;
        $ititem = pItem;

        $dricommand = '*ITEM';
        $drisubcmd  = '%GETALL';
        $drisys2upd = 'D';
        $driprogram = #pgm;
        $dridata = $item;
        $dridata2 = $item2;

        // Call DRI program.

        driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
               $drireturn: $drimessage: $dridata: $dridata2);

        $item = $dridata;
        $item2 = $dridata2;

        if $drireturn <> '*OK';
          pMessage = $drimessage;
          error = *on;
          leavesr;
        endif;
        // catch weight?
        if $itcwgt = 'Y';
          // Catch Weight Adjustment must be greater than 0
          if pAdjWgt <= 0;
            pMessage = 'Catch Weight Adj must be Greater than 0';
            error = *on;
            leavesr;
          endif;
        endif;

        // Let send it to drislot for verification
        savever# = $slver#;
        clear $slot;
        clear $slot2;

        $slwhseu = *on;
        $slwhse  = pwhse;

        $slwhdpu = *on;
        $slwhdp  = pdept;

        $sldispu = *on;
        $sldisp  = pdisp;

        $saitemu = *on;
        $saitem  = pitem;

        $saqtyu  = *on;
        select;
          when padjuom = 'N';
            if ptype = 'I';
              $saqty1  = padjqty;
            else;
              $saqty1  = padjqty * -1;
            endif;
              $saqty2  = 0;
              $saqty3  = 0;
          when padjuom = '1';
            $saqty1  = 0;
            if ptype = 'I';
              $saqty2  = padjqty;
            else;
              $saqty2  = padjqty * -1;
            endif;
            $saqty3  = 0;
          when padjuom = '2';
            $saqty1  = 0;
            $saqty2  = 0;
            if ptype = 'I';
              $saqty3  = padjqty;
            else;
              $saqty3  = padjqty * -1;
            endif;
        endsl;

        $sacwtau = *on;
        if ptype = 'I';
          $sacwta  = padjwgt;
        else;
          $sacwta  = padjwgt * -1;
        endif;

        $sacodeu = *on;
        $sacode  = padjcd;

        $samemou = *on;
        $samemo  = pmemo;

        $sabyu   = *on;
        $saby    = pUser;

        $saActionU = *on;
        $saAction = 'ADJ';
        $saETrn#U = *on;
        $saETrn# = 0;

        $dricommand = '*SLOT';
        $drisys2upd = 'D';
        $driprogram = #pgm;
        $drisubcmd  = '%VERIFY';
        $dridata = $slot;
        $dridata2 = $slot2;

        // Call DRI program.

        driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
               $drireturn: $drimessage: $dridata: $dridata2);

        $slot = $dridata;
        $slot2 = $dridata2;

        if $drireturn <> '*OK';
          pMessage = $drimessage;
          error = *on;
        endif;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

      /free
       begsr getCurrStamp;

         getmicrotime(currstampuc:currstampsys);
         currstamploc = currstampsys + %hours(bfcoffset);

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  Update            Update Adjusment Data
     *----------------------------------------------------------------

      /free
       begsr Update;

        // Let send it to drislot for the actual adjustment process
        savever# = $slver#;
        clear $slot;
        clear $slot2;

        $slwhseu = *on;
        $slwhse  = pwhse;

        $slwhdpu = *on;
        $slwhdp  = pdept;

        $sldispu = *on;
        $sldisp  = pdisp;

        $saitemu = *on;
        $saitem  = pitem;

        $saqtyu  = *on;
        select;
          when padjuom = 'N';
            if ptype = 'I';
              $saqty1  = padjqty;
            else;
              $saqty1  = padjqty * -1;
            endif;
              $saqty2  = 0;
              $saqty3  = 0;
          when padjuom = '1';
            $saqty1  = 0;
            if ptype = 'I';
              $saqty2  = padjqty;
            else;
              $saqty2  = padjqty * -1;
            endif;
            $saqty3  = 0;
          when padjuom = '2';
            $saqty1  = 0;
            $saqty2  = 0;
            if ptype = 'I';
              $saqty3  = padjqty;
            else;
              $saqty3  = padjqty * -1;
            endif;
        endsl;

        $sacwtau = *on;
        if ptype = 'I';
          $sacwta  = padjwgt;
        else;
          $sacwta  = padjwgt * -1;
        endif;

        $sacodeu = *on;
        $sacode  = padjcd;

        $samemou = *on;
        $samemo  = pmemo;

        $sabyu   = *on;
        $saby    = pUser;

        $saActionU = *on;
        $saAction = 'ADJ';
        $saETrn#U = *on;
        $saETrn# = 0;

        $saemp#U = *on;
        $saemp#  = e$emp#;

        $dricommand = '*SLOT';
        $drisys2upd = 'D';
        $driprogram = #pgm;
        $drisubcmd  = '%ADJUST';
        $dridata = $slot;
        $dridata2 = $slot2;

        // Call DRI program.

        driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
               $drireturn: $drimessage: $dridata: $dridata2);

        $slot = $dridata;
        $slot2 = $dridata2;

        if $drireturn <> '*OK';
          pMessage = $drimessage;
          error = *on;
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
                  + 'pdept:' + %trimr(pdept) + ', '
                  + 'pitem:' + %trimr(pitem) + ', '
                  + 'pdisp:' + %trimr(pdisp) + ', '
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

           when parmName = 'CALCULA008';
             if parmValue = '';
               parmValue = '0';
             endif;
             pwhse =  %dec(parmValue: 3: 0);

           when parmName = 'CALCULA009';
             pdept = %trim(parmValue);

           when parmName = 'CALCULA004';
             pitem  = %trim(parmValue);

           when parmName = 'CALCULA010';
             pdisp  = %trim(parmValue);

           when parmName = 'GFA01_01';
             ptype   =%trim(parmValue);

           when parmName = 'GFA02_01';
750aD        //padjcd  =%trim(parmValue);
750aM        padjcd  =parmValue;

           when parmName = 'GFA01_02';
             padjuom =%trim(parmValue);

           when parmName = 'GFN050_01';
             if parmValue = '';
               parmValue = '0';
             endif;
             padjqty= %dec(parmValue: 5: 0);

           when parmName = 'GFN092_01';
             if parmValue = '';
               parmValue = '0';
             endif;
             padjwgt= %dec(parmValue: 9: 2);

           when parmName = 'GFA30_01';
             pmemo   =%trim(parmValue);

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
