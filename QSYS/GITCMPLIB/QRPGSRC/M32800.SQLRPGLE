      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M32800       Replace License
     *  16 June 2021
     *  Lynn McMahon
     *
     *  Revisions:
     *
     *    06/16/21  LMC  7.50
     *      - Created.
     *
770A *    02/24/23  LMC  770a  Send the Lot code to RFMT, parm 27
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
	    d  pwhdp          s              5
	    d  pladisp        s             12
	    d  plaitem        s             15
	    d  plaitype       s              1
	    d  plasitem       s             15
	    d  plasitype      s              1
	    d  placode        s              1
	    d  plaarea        s             15
	    d  plaaisl        s              3
	    d  plaloc         s              3p 0
	    d  plarlvl        s              2p 0
	    d  plahand        s              2
	    d  plabase        s             12
	    d  plapos         s              3p 0
	    d  plaord         s              7p 0
     d  plaseq         s              5p 0
	    d  plalcns        s             15
	    d  plaolcns       s             15
	    d  pnewlcns       s             15
	    d  plaentd        s              8p 0
	    d  plaexpd        s              8p 0
	    d  pexpd8         s              8
	    d  pexpd6         s              6
     D  plaprty        s              1p 0
	    d  pcalc8         s              1
	    d  pcalc9         s              1
     d  plaqty1        s              5p 0
     d  plaqty2        s              5p 0
     d  plaqty3        s              5p 0

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
                 $drisubcmd = '%SETFIFO';
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
         // edits from la830 zzchk4

         if pnewlcns = ' ';
           pmessage = 'New License cannot be blank';
           return;
         endif;
         // new license can not already exist
         if pObjLoc = 'FLDVALID';
           savever# = $liver#;
           clear $license;
           clear $license2;
           $liver# = savever#;

           $liToWHSEU = *on;
           $liToWHSE  = pWHSE;
           $liToLcnsU = *on;
           $liToLcns  = pnewlcns;

           $drisubcmd = '%GETLCNS';
           $dricommand = '*LICENSE';
           $drisys2upd = 'D';
           $driprogram = #pgm;
           $dridata = $license;
           $dridata2 = $license2;

           // Call DRI program.

           driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
                  $drireturn: $drimessage: $dridata: $dridata2);

           $license = $dridata;
           $license2 = $dridata2;
           if $drireturn = '*OK';
             pmessage = 'New License is already used';
             return;
           endif;
         endif;
         if pObjLoc = 'FLDVALID';
           return;
         endif;

         // continue on to update

         // Initialize DRI fields.
         savever# = $liver#;
         clear $license;
         clear $license2;
         $liver# = savever#;

         $liActionU = *on;
         $liAction  = 'RPC';
         $liToDispU = *on;
         $litoDisp  = pladisp;
         $liToItemU = *on;
         $litoItem  = plaitem;
         $liToITypeU = *on;
         $litoItype = plaitype;
         $liToCodeu = *on;
         $litoCode  = placode;
         $liToAislu = *on;
         $litoAisl  = plaaisl;
         $liToLocU = *on;
         $litoLoc   = plaloc;
         $liToRlvlU = *on;
         $litorlvl  = plarlvl;
         $liToHandU = *on;
         $litoHand  = plahand;
         $liToAreaU = *on;
         $litoArea  = plaarea;
         $liToWhdpU = *on;
         $litoWhdp  = pwhdp;
         $liToPosU = *on;
         $litoPos   = plapos;
         $liToOrdU = *on;
         $litoOrd   = plaord;
         $liToSeqU = *on;
         $litoSeq   = plaseq;
         $liToEntDU = *on;
         $litoEntd  = plaentd;
         $liToExpDU = *on;
         $litoExpd  = plaexpd;
         $liToPrtyU = *on;
         $litoPrty = plaprty;
         $liToSITypeU = *on;
         $litoSitype = plasitem;
         $liOLcnsU = *on;
         $liOlcns = plaolcns;
         $liToSItemU = *on;
         $litosItem = plasitem;
         $liToBaseU = *on;
         $litoBase  = plabase;
         $liToWhseU = *on;
         $litoWhse  = pwhse;
         //Setup DRILICENSE Record Delete if License Changed
         $liAQty1U = *on;
         $liaQty1  = -(plaqty1);
         $liaQty2  = -(plaqty2);
         $liaQty3  = -(plaqty3);
         $liToRQty1U = *on;
         $liToRQty1  = 0;
         $liToRQty2  = 0;
         $liToRQty3  = 0;
         $liToLcnsU = *on;
         $litoLcns = plalcns;
         $liFrmOldLcnsU = *on;
         $liFrmOldLcns = pnewlcns;
         $liuser = puser;

         $dricommand = '*LICENSE';
         $drisubcmd  = '%SETLCNS';
         $drisys2upd = 'D';
         $driprogram = #pgm;
         $dridata = $license;
         $dridata2 = $license2;

         // Call DRI program.

         driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
                $drireturn: $drimessage: $dridata: $dridata2);

         $license = $dridata;
         $license2 = $dridata2;

         //Setup Add or Update Record
         savever# = $liver#;
         clear $license;
         clear $license2;
         $liver# = savever#;

         $liActionU = *on;
         $liAction  = 'RPC';
         $liToDispU = *on;
         $litoDisp  = plaDisp;
         $liToItemU = *on;
         $litoItem  = plaItem;
         $liToITypeU = *on;
         $litoItype = plaitype;
         $liToCodeu = *on;
         $litoCode  = placode;
         $liToAislu = *on;
         $litoAisl  = plaaisl;
         $liToLocU = *on;
         $litoLoc   = plaloc;
         $liToRlvlU = *on;
         $litorlvl  = plarlvl;
         $liToHandU = *on;
         $litoHand  = plahand;
         $liToAreaU = *on;
         $litoArea  = plaarea;
         $liToWhdpU = *on;
         $litoWhdp  = pwhdp;
         $liToPosU = *on;
         $litoPos   = plapos;
         $liToOrdU = *on;
         $litoOrd   = plaord;
         $liToSeqU = *on;
         $litoSeq   = plaseq;
         $liToEntDU = *on;
         $litoEntd  = plaentd;
         $liToExpDU = *on;
         $litoExpd  = plaexpd;
         $liToPrtyU = *on;
         $litoPrty = plaprty;
         $liToSITypeU = *on;
         $litoSitype = plasitype;
         $liOLcnsU = *on;
         $liOlcns = plaolcns;
         $liToSItemU = *on;
         $litosItem = plasitem;
         $liToBaseU = *on;
         $litoBase  = plabase;
         $liToWhseU = *on;
         $litoWhse  = pWhse;
         $liAQty1U = *on;
         if pnewlcns = plalcns;
           $liaQty1  = plaqty1 - plaqty1;
           $liaQty2  = plaqty2 - plaqty2;
           $liaQty3  = plaqty3 - plaqty3;
         else;
           $liaQty1  = plaqty1;
           $liaQty2  = plaqty2;
           $liaQty3  = plaqty3;
         endif;
         $liToRQty1U = *on;
         $liToRQty1  = plaQty1;
         $liToRQty2  = plaQty2;
         $liToRQty3  = plaQty3;
         $liToLcnsU = *on;
         $litoLcns = pnewlcns;
         $liFrmOldLcnsU = *on;
         $liFrmOldLcns = plalcns;
         $liuser = puser;

         $dricommand = '*LICENSE';
         $drisubcmd  = '%SETLCNS';
         $drisys2upd = 'D';
         $driprogram = #pgm;
         $dridata = $license;
         $dridata2 = $license2;

         // Call DRI program.

         driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
                $drireturn: $drimessage: $dridata: $dridata2);

         $license = $dridata;
         $license2 = $dridata2;

         select;
           when %error;
             pMessage= 'Error occured calling DRILICENSE '
                     + '('
                     + %trimr(#Job) + '/'
                     + %trimr(#JobNbr) + '/'
                     + %trimr(#user)
                     + ')';
           when $drireturn <> '*OK';
             pMessage= 'Error: ' + %trim($drireturn) + ' - ' + $drimessage;
           other;
             if %subst($drisubcmd:2:1) <> 'V';
               logText = 'dricmd:' + %trimr($dricommand) + ','
                       + 'drisub:' + %trimr(savsubcmd) + ','
                       + 'lawhse:' + %char(pwhse) + ','
                       + 'lalcns:' + %trimr($litolcns);
               wrtsesslog(pSessId: #pgm: dpCombo: pUser: logText);
             endif;
         endsl;

      /free
        // need to print new license
     *
     *  Get receiving options.
     *
      /free
        exec sql select * into :oprec
             from opsrcvlbl
             where opwhse = :pwhse;
        If sqlstt = sqlSuccess;
          OPLPGM = OPLPGM;
          if %subst(oplpgm:1:4) = 'RFMT';
            lblset = %subst(oplpgm: 5 : 6);
            lblpgm = %subst(oplpgm: 1 : 4);
          endif;
        else;
          return;
        endif;
        savever# = $lnver#;
        clear $licinfo;
        clear $licinfo2;
        $lnver# = savever#;

        $lnwhse  = pwhse;
        $lnlcns = plaolcns;
        $lnseq  = 1;
        $dricommand = '*LICINFO';
        $drisubcmd  = '%GET';
        $drisys2upd = 'D';
        $driprogram = #pgm;
        $dridata = $licinfo;
        $dridata2 = $licinfo2;

        // Call DRI program.

        driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
               $drireturn: $drimessage: $dridata: $dridata2);

        $licinfo = $dridata;
        $licinfo2 = $dridata2;
        if $drireturn = '*OK';
        endif;
      /end-free
        // get the pick slot from drislot
     C                   call      'GETPSLT'
     C                   parm                    $scmd             8
     C                   parm      pwhse         pwhse
     C                   parm                    $lnitem
     C                   parm                    woslot
     C                   parm      *blanks       $saisl            3
     C                   parm      *zeros        $sloc             3 0
     C                   parm      *zeros        $srlvl            2 0
     C                   parm      *blanks       $shand            2
     C                   parm                    $srtn             8
      /free
     *
        exsr zztihi;
        today6a = %SUBST (%CHAR($lnaddts):6:2) +
                  %SUBST (%CHAR($lnaddts):9:2) +
                  %SUBST (%CHAR($lnaddts):3:2);
        today6 = %DEC(today6a:6:0);
        // need uom from label
        exec sql select * into :lbrec
             from label
             where lbwhse = :pwhse
               and lblbl# = :$LNRCVLBL#;
        If sqlstt = sqlSuccess;
        else;
          lbucod = ' ';
        endif;

        savever# = $itver#;
        clear $item;
        clear $item2;
        $itver# = savever#;

        $itwhse  = pwhse;
        $ititem  = plaitem;

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
        if $drireturn = '*OK';
        endif;

      /end-free
      * GET ITEM INFORATION FOR LABEL
     C                   call      lblpgm
     C                   parm                    $acmd             8
     C                   parm                    lblset            6
     C                   parm      ' '           $plfmt            8
     C                   parm                    $lnrcvtrn#
     C                   parm                    pwhse
     C                   parm                    pwhdp
     C                   parm                    $astyp            1
     C                   parm                    $adisp           12
     C                   parm      woslot        $apslt
     C                   parm                    $lnrcvqty
     C                   parm                    lbucod
     C                   parm                    wotie             4 0
     C                   parm                    wohi              2 0
     C                   parm                    $lnitem
     C                   parm                    $itdesc
     C                   parm                    $itpdsc
     C                   parm                    $itupc
     C                   parm                    phven
     C                   parm                    $itvit#
     C                   parm                    $lnpo
     C                   parm                    today6
     C                   parm                    $aexpd            6 0
     C                   parm      pprinter      $pdev
     C                   parm                    $pform
     C                   parm                    w2lcns           15
770aAC                   parm      ' '           bBrand           10
770aAC                   parm                    $lnlot
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
                  + 'plalcns:' + %trimr(plalcns) + ', '
                  + 'plaolcns:' + %trimr(plaolcns) + ', '
                  + 'pnewlcns:' + %trimr(pnewlcns) + ', '
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
     *
     *  ZZTIHI   Get use Preferred or 1st tie hi record.
     *
     C     zztihi        begsr
     *
     *  GET TIE HI, PREFERRED OR 1ST RECORD.
     C                   eval      done = *off
     C                   eval      wotie = 0
     C                   eval      wohi = 0
     C                   eval      svtie = 0
     C                   eval      svhi = 0
      /free
         setll (pwhse: $lnitem) itemdef;
         dou done = *on;
           reade (pwhse: $lnitem) itemdef;
           if %eof(itemdef);
             done = *on;
             leave;
           endif;
      /end-free
     C                   if        svtie = 0  and
     C                             svhi = 0
     C                   eval      svtie = idtie
     C                   eval      svhi = idhigh
     C                   endif
     C                   if        idpref = 'Y'
     C                   eval      wotie = idtie
     C                   eval      wohi = idhigh
     C                   eval      done = *on
     C                   endif
     C                   enddo
     C                   if        wotie = 0  and
     C                             wohi = 0
     C                   eval      wotie = svtie
     C                   eval      wohi = svhi
     C                   endif
     *
     c                   if        client = finkle
     C                   eval      *in86 = *on
     C                   else
     C                   eval      *in86 = *off
     C                   endif
     C                   endsr
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

           when parmName = 'LAWHSE';
             if parmValue = '';
               parmValue = '0';
             endif;
             pwhse =  %dec(parmValue: 3: 0);

           when parmName = 'LALCNS';
             plalcns = %trim(parmValue);

           when parmName = 'LAOLCNS';
             plaolcns = %trim(parmValue);

           when parmName = 'LAWHDP';
             pwhdp = %trim(parmValue);

           when parmName = 'LAENTD';
             if parmValue = '';
               parmValue = '0';
             endif;
             plaentd =  %dec(parmValue: 8: 0);

           when parmName = 'LAEXPD';
             if parmValue = '';
               parmValue = '0';
             endif;
             plaexpd =  %dec(parmValue: 8: 0);
             pexpd8= %trim(parmValue);
             pexpd6 = %subst(pexpd8:3:6);


           when parmName = 'LAPRTY';
             if parmValue = '';
               parmValue = '0';
             endif;
             plaprty =  %dec(parmValue: 1: 0);

           when parmName = 'CALCULA009';
             pcalc9 = %trim(parmValue);

           when parmName = 'CALCULA010';
             pnewlcns = %xlate(xlower: xupper: parmValue);

           when parmName = 'LAQTY1';
             if parmValue = '';
               parmValue = '0';
             endif;
             plaqty1= %dec(parmValue: 5: 0);

           when parmName = 'LAQTY2';
             if parmValue = '';
               parmValue = '0';
             endif;
             plaqty2= %dec(parmValue: 5: 0);

           when parmName = 'LAQTY3';
             if parmValue = '';
               parmValue = '0';
             endif;
             plaqty3= %dec(parmValue: 5: 0);

           when parmName = 'LACODE';
             placode= %trim(parmValue);

           when parmName = 'LAAREA';
             plaarea= %trim(parmValue);

           when parmName = 'LADISP';
             pladisp= %trim(parmValue);

           when parmName = 'LAAISL';
             plaaisl= %trim(parmValue);

           when parmName = 'LALOC';
             if parmValue = '';
               parmValue = '0';
             endif;
             plaloc = %dec(parmValue: 3: 0);

           when parmName = 'LARLVL';
             if parmValue = '';
               parmValue = '0';
             endif;
             plarlvl= %dec(parmValue: 2: 0);

           when parmName = 'LAHAND';
             plahand= %trim(parmValue);

           when parmName = 'LABASE';
             plabase= %trim(parmValue);

           when parmName = 'LAPOS';
             if parmValue = '';
               parmValue = '0';
             endif;
             plapos = %dec(parmValue: 3: 0);

           when parmName = 'LAITEM';
             plaitem= %trim(parmValue);

           when parmName = 'LAITYPE';
             plaitype=%trim(parmValue);

           when parmName = 'LASITEM';
             plasitem= %trim(parmValue);

           when parmName = 'LASITYPE';
             plasitype=%trim(parmValue);

           when parmName = 'LAORD';
             if parmValue = '';
               parmValue = '0';
             endif;
             plaord = %dec(parmValue: 7: 0);

           when parmName = 'LASEQ';
             if parmValue = '';
               parmValue = '0';
             endif;
             plaseq = %dec(parmValue: 5: 0);

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
