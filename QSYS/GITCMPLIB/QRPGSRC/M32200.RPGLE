      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2021 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M32200       Gui Item - change pick slot
     *  08 February  2021
     *  Lynn McMahon
     *
     *  Revisions:
     *
     *    02/08/21  LMC  7.50
     *      - Created.
     *
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     FLOCSLOG   O    E           K DISK    usropn
CBIdAFtihighsnd uf a e           k disk    usropn
     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

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
	    d  pTdisp         s             12
	    d  pFdisp         s             12
	    d  pwhdp          s              5
     D  pSubCmd        s             10

     D #fromslwhdp     s                   like($slwhdp)
     D #fromsldisp     s                   like($sldisp)
     D #fromslaisl     s                   like($slaisl)
     D #fromslloc      s                   like($slloc)
     D #fromslpseq     s                   like($slpseq)
     D #fromslrlvl     s                   like($slrlvl)
     D #fromslhand     s                   like($slhand)
     D #fromslstat     s                   like($slstat)
     D #fromslpick     s                   like($slpick)
     D #fromslstyp     s                   like($slstyp)
     D #fromslitem     s                   like($slitem)
     D #fromslavl1     s                   like($slavl1)
     D #fromslavl2     s                   like($slavl2)
     D #fromslavl3     s                   like($slavl3)
     D #fromToLcns     s                   like($saToLcns)
     D #fromToPos      s                   like($satopos)
     D #fromOLcns      s                   like($saOLcns)

     D #toslwhdp       s                   like($slwhdp)
     D #tosldisp       s                   like($sldisp)
     D #toslaisl       s                   like($slaisl)
     D #toslloc        s                   like($slloc)
     D #toslrlvl       s                   like($slrlvl)
     D #toslhand       s                   like($slhand)
     D #toslstat       s                   like($slstat)
     D #toslpick       s                   like($slpick)
     D #toslitem       s                   like($slitem)

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

     D client          s             10
     D clientloc       s             10

     D $CVTDT          DS
     D  $CVCMD                 1      8
     D  $CVPRG                 9     18
     D  $CVD6I                19     24
     D  $CVD8I                25     32
     D  $CVD6O                33     38  0
     D  $CVD8O                39     46  0
     D  $CVSTO                47     64
     D  $CVRTN                65     72
     D  $CVERM                73    132
     D  $CVMSG                73     76

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pSubCmd      DRI subcommand without '%'.
     *      pObjLoc      External object location called from.
     *      pparmstr1    Parm String
     *      pparmstr2    parm string
     *      pparmstr3    parm string
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
     D  pPgm           s             10
     D  pObjLoc        s             10
     D  pparmStr1      s            999
     D  pparmStr2      s            999
     D  pparmStr3      s            999

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.dricop
      /copy qcopysrc,p.getuser
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

CBIa  /copy qcopysrc,id#cheney
     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT
     D saveVer#        s                   like($slver#)

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
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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

	       pitem = %xlate(xlower: xupper: pitem);
	       puser = %xlate(xlower: xupper: puser);
	       ptdisp = %xlate(xlower: xupper: ptdisp);
	       pfdisp = %xlate(xlower: xupper: pfdisp);

        exsr zzedit;
        if pMessage = ' ';
          exsr zzupd;
        endif;


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
                  + 'pWhdp:' + %trimr(pWhdp) + ', '
                  + 'pfdisp:' + %trimr(pfdisp) + ', '
                  + 'ptdisp:' + %trimr(ptdisp) + ', '
                  + 'pItem:' + %trimr(pItem) + ', '
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
     *  zzedit         Do Edits
     *----------------------------------------------------------------

      /free
       begsr zzedit;

         pMessage = ' ';

CBIdA   // open custom files
CBIdA
CBIdA   if client = cheney;
CBIdA
CBIdA     if not %open(tihighsnd);
CBIdA       open(e)   tihighsnd;
CBIdA       if %error;
CBIdA         pMessage = 'Cannot change slot - '
CBIdA                   + 'Cannot open file TIHIGHSND';
CBIdA         leavesr;
CBIdA       endif;
CBIdA     endif;
CBIdA
CBIdA     if not %open(locslog);
CBIdA       open(e)   locslog;
CBIdA       if %error;
CBIdA         pMessage = 'Cannot change slot - '
CBIdA                    + 'Cannot open file TIHIGHSND';
CBIdA         leavesr;
CBIdA       endif;
CBIdA     endif;
CBIdA
CBIdA   endif;
     *
     *    Get User's employee number
     *
        // get user employee number
        e$whse = 0;
        e$emp# = 0;
        e$fnam = ' ';
        e$init = ' ';
        e$lnam = ' ';
        e$whdp = ' ';
        e$styp = ' ';
        e$shft = ' ';
        e$crew = ' ';
        e$nhrs = 0;
        e$rtn  = ' ';
        e$lng  = ' ';
        e$bpu  = ' ';
        getUser(puser: e$whse: e$emp#: e$fnam: e$init: e$lnam:
                e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                e$bpu: e$lng);

        // get from slot

        savever# = $slver#;
        clear $slot;
        clear $slot2;
        $slver# = savever#;

        $slwhseu = *on;
        $slwhse  = pwhse;
        $slwhdpu = *on;
        $slwhdp  = pwhdp;
        $sldispu = *on;
        $sldisp  = pfdisp;

        $dricommand = '*SLOT';
        $drisubcmd  = '%GET';
        $drisys2upd = 'D';
        $driprogram = #pgm;
        $dridata = $slot;
        $dridata2 = $slot2;

        // Call DRI program.
        driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
               $drireturn: $drimessage: $dridata: $dridata2);

        $slot = $dridata;
        $slot2 = $dridata2;

        // from slot is not pick slot
        if $slpick <> 'Y';
          pMessage = 'Cannot change slot - '
                   + 'Original slot is not a Pick slot';
          leavesr;
        endif;

        // from slot has no item
        if $slitem = ' ';
          pMessage = 'Cannot change slot - '
                   + 'Slot does not contain item';
          leavesr;
        endif;

        // from slot is not status 'A'
        if $slstat <> 'A';
          pMessage = 'Cannot change slot - '
                   + 'Slot status is not "A"';
          leavesr;
        endif;

        // from slot has qty
        if $slstk1 <> 0 or
           $slstk2 <> 0 or
           $slstk3 <> 0 or
           $slalc1 <> 0 or
           $slalc2 <> 0 or
           $slalc3 <> 0 or
           $sltfr1 <> 0 or
           $sltfr2 <> 0 or
           $sltfr3 <> 0 or
           $slpck1 <> 0 or
           $slpck2 <> 0 or
           $slpck3 <> 0 or
           $slrcv1 <> 0 or
           $slrcv2 <> 0 or
           $slrcv3 <> 0;
          pMessage = 'Cannot change slot - '
                   + 'Slot has quantity';
          leavesr;
        endif;

        // save from information
        #fromslwhdp = $slwhdp;
        #fromslstyp = $slstyp;
        #fromsldisp = $sldisp;
        #fromslaisl = $slaisl;
        #fromslloc  = $slloc;
        #fromslpseq = $slpseq;
        #fromslrlvl = $slrlvl;
        #fromslhand = $slhand;
        #fromslstat = $slstat;
        #fromslpick = $slpick;
        #fromslitem = $slitem;
        #fromslavl1 = $slavl1;
        #fromslavl2 = $slavl2;
        #fromslavl3 = $slavl3;

        // new slot must exist
        if ptdisp = *blanks;
          pMessage = 'New slot cannot be blank';
          leavesr;
        endif;
        // new slot can't be same as old slot
        if ptdisp = pfdisp;
          pMessage = 'New slot cannot be same as old slot';
          leavesr;
        endif;

        // get new slot
        savever# = $slver#;
        clear $slot;
        clear $slot2;
        $slver# = savever#;

        $slwhseu = *on;
        $slwhse  = pwhse;
        $slwhdpu = *on;
        $slwhdp  = pwhdp;
        $sldispu = *on;
        $sldisp  = ptdisp;

        $dricommand = '*SLOT';
        $drisubcmd  = '%GET';
        $drisys2upd = 'D';
        $driprogram = #pgm;
        $dridata = $slot;
        $dridata2 = $slot2;

        // Call DRI program.
        driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
               $drireturn: $drimessage: $dridata: $dridata2);

        $slot = $dridata;
        $slot2 = $dridata2;

        // new slot is not a pick slot
        if $slpick <> 'Y';
          pMessage = 'Cannot change slot - '
                      + 'New slot is not a Pick slot';
          leavesr;
        endif;

        // new slot is not status 'V'
        if $slstat <> 'V';
          pMessage = 'Cannot change slot - '
                      + 'New slot is not status "V"';
          leavesr;
        endif;

        #toslwhdp = $slwhdp;
        #tosldisp = $sldisp;
        #toslaisl = $slaisl;
        #toslloc  = $slloc;
        #toslrlvl = $slrlvl;
        #toslhand = $slhand;
        #toslpick = $slpick;
        #toslstat = $slstat;

        // verify from slot change
        savever# = $slver#;
        clear $slot;
        clear $slot2;
        $slver# = savever#;
        $slwhseu = *on;
        $slwhse  = pwhse;
        $slwhdpu = *on;
        $slwhdp = #fromslwhdp;
        $sldispu = *on;
        $sldisp = #fromsldisp;
        $slaislu = *on;
        $slaisl  = #fromslaisl;
        $sllocu  = *on;
        $slloc   = #fromslloc;
        $slrlvlu = *on;
        $slrlvl  = #fromslrlvl;
        $slhandu = *on;
        $slhand  = #fromslhand;
        $slitemu = *on;
        $slitem  = ' ';
        $slstatu = *on;
        $slstat  = 'Z';

        $dricommand = '*SLOT';
        $drisubcmd  = '%VERIFYCHG';
        $drisys2upd = 'D';
        $driprogram = #pgm;
        $dridata = $slot;
        $dridata2 = $slot2;

        // Call DRI program.
        driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
               $drireturn: $drimessage: $dridata: $dridata2);

        $slot = $dridata;
        $slot2 = $dridata2;
        if $drireturn <> '*OK';
          pMessage = $drimessage;
          leavesr;
        endif;

        // Verify New slot change. Ignore too many pick slot error.
        savever# = $slver#;
        clear $slot;
        clear $slot2;
        $slver# = savever#;

        $slwhseu = *on;
        $slwhse  = pwhse;
        $slwhdpu = *on;
        $slwhdp = #toslwhdp;
        $sldispu = *on;
        $sldisp = #tosldisp;
        $slaislu = *on;
        $slaisl  = #toslaisl;
        $sllocu  = *on;
        $slloc   = #toslloc;
        $slrlvlu = *on;
        $slrlvl  = #toslrlvl;
        $slhandu = *on;
        $slhand  = #toslhand;
        $slitemu = *on;
        $slitem  = #fromslitem;
        $slstatu = *on;
        $slstat  = 'A';

        $dricommand = '*SLOT';
        $drisubcmd  = '%VERIFYCHG';
        $drisys2upd = 'D';
        $driprogram = #pgm;
        $dridata = $slot;
        $dridata2 = $slot2;

        // Call DRI program.
        driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
               $drireturn: $drimessage: $dridata: $dridata2);

        $slot = $dridata;
        $slot2 = $dridata2;
        if $drireturn <> '*OK'
           and $drireturn <> 'PCKOVRFLW';
          pMessage = $drimessage;
          leavesr;
        endif;


       endsr;
      /end-free
     *----------------------------------------------------------------
     *  zzupd          update slots
     *----------------------------------------------------------------

      /free
       begsr zzupd;

        // Take item out of From slot
        savever# = $slver#;
        clear $slot;
        clear $slot2;
        $slver# = savever#;
        $slwhseu = *on;
        $slwhse  = pwhse;
        $slwhdpu = *on;
        $slwhdp = #fromslwhdp;
        $sldispu = *on;
        $sldisp = #fromsldisp;
        $slaislu = *on;
        $slaisl  = #fromslaisl;
        $sllocu  = *on;
        $slloc   = #fromslloc;
        $slrlvlu = *on;
        $slrlvl  = #fromslrlvl;
        $slhandu = *on;
        $slhand  = #fromslhand;
        $slitemu = *on;
        $slitem  = ' ';
        $slstatu = *on;
        $slstat  = 'Z';

        $dricommand = '*SLOT';
        $drisubcmd  = '%CHANGE';
        $drisys2upd = 'D';
        $driprogram = #pgm;
        $dridata = $slot;
        $dridata2 = $slot2;

        // Call DRI program.
        driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
               $drireturn: $drimessage: $dridata: $dridata2);

        $slot = $dridata;
        $slot2 = $dridata2;
        if $drireturn <> '*OK';
          pMessage = $drimessage;
          leavesr;
        endif;

        // Put item into new slot
        savever# = $slver#;
        clear $slot;
        clear $slot2;
        $slver# = savever#;
        $slwhseu = *on;
        $slwhse  = pwhse;
        $slwhdpu = *on;
        $slwhdp = #toslwhdp;
        $sldispu = *on;
        $sldisp = #tosldisp;
        $slaislu = *on;
        $slaisl  = #toslaisl;
        $sllocu  = *on;
        $slloc   = #toslloc;
        $slrlvlu = *on;
        $slrlvl  = #toslrlvl;
        $slhandu = *on;
        $slhand  = #toslhand;
        $slitemu = *on;
        $slitem  = #fromslitem;
        $slstatu = *on;
        $slstat  = 'A';
        $dricommand = '*SLOT';
        $drisubcmd  = '%CHANGE';
        $drisys2upd = 'D';
        $driprogram = #pgm;
        $dridata = $slot;
        $dridata2 = $slot2;

        // Call DRI program.
        driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
               $drireturn: $drimessage: $dridata: $dridata2);

        $slot = $dridata;
        $slot2 = $dridata2;
        if $drireturn <> '*OK';
          pMessage = $drimessage;
          leavesr;
        endif;

CBIbA   //Create an update log record
CBIbA   if client = cheney;
CBIbA     EXSR ZZLOG;
CBIbA   endif;

       endsr;
      /end-free
CBIbAC*----------------------------------------------------------------
CBIbAC*
CBIbAC*  ZZLOG  Log the info of the item location change being done.
CBIbAC*
CBIbAC     ZZLOG         BEGSR
CBIbAC*
CBIdA*  Define key for TIHIGHSND file.
CBIdA*
CBIdAC     tisndkey      klist
CBIdAC                   kfld                    pwhse
CBIdAC                   kfld                    #fromslitem
      *
CBIbAC                   CLEAR                   LOCREC
CBIbAC                   Z-ADD     pwhse         LOCWHS
CBIbAC                   MOVE      #fromslwhdp   LOCDPT
CBIbDC                   MOVE      #fromslitem   LOCITM
CBIbMC                   MOVE      #fromsldisp   LOCFRM
CBIbAC                   MOVE      #tosldisp     LOCTO
CBIbAC*    Get todays date.
CBIbAC                   MOVE      '*CURCMD '    $CVCMD
CBIbACSR                 CALL      @CVTDT
CBIbACSR                 PARM                    $CVTDT
CBIbAC                   Z-ADD     $CVD8O        LOCDTE
CBIbAC                   TIME                    LOCTIM
CBIbAC                   MOVE      #curruser     LOCUSR
CBIbAC                   Z-ADD     e$emp#        LOCEMP
CBIbAC*
CBIbAC                   WRITE     LOCREC
CBIbAC*
CBIdAC     tisndkey      chain     tihighsnd                          79
CBIdAC                   eval      snwhse = pwhse
CBIdAC                   eval      snitem = #fromslitem
CBIdAC                   eval      sntie  = *zeros
CBIdAC                   eval      snhigh = *zeros
CBIdAC                   eval      snsdef = *blanks
CBIdAC                   eval      snsend = 'N'
CBIdAC                   if        *in79 = *off
CBIdAC                   update    sndrec
CBIdAC                   else
CBIdAC                   write     sndrec
CBIdAC                   endif
CBIbAC*
CBIbAC     ENDLOG        ENDSR
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

           when parmName = 'CALCULA005';
             if parmValue = '';
               parmValue = '0';
             endif;
             pwhse =  %dec(parmValue: 3: 0);

           when parmName = 'CALCULA008';
             pitem = %trim(parmValue);

           when parmName = 'CALCULA006';
             pwhdp = %trim(parmValue);

           when parmName = 'GFA12_01';
             ptdisp = %trim(parmValue);

           when parmName = 'CALCULA007';
             pfdisp = %trim(parmValue);


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
