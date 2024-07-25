      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H bnddir('QC2LE')

     *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  AUTOTFR     Auto Transfer for Negative XDK slots
     *  03 July 2019
     *  Lynn McMahon
     *
     *  Revisions
     *
730 A*    07/03/19  LMC  7.30
     *      - Created
     *
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')


     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     FworkUsr3  uf a e           k disk

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT
     D saveVer#        s                   like($itver#)
     D to$Slot         ds                  likeds($slot)
     D to$Slot2        ds                  likeds($slot2)
     D frm$Slot        ds                  likeds($slot)
     D frm$Slot2       ds                  likeds($slot2)
     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------

     D/copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D curlic#         s                   like($tlic#)
     D curtrn#         s              7  0
     D partial         s               n
     D $partime        s               Z
     D wkType          s              3    INZ('TFR')
     D rtnToOrig       s               n
     D skipLT210       s               n
     D tfroutflag      s               n
     D tfr2usrDate     s              8  0
     D tfr2usrTime     s              6  0
     D Ypickslot       s               n
     d #TOSLAISL       s                   like($slaisl)
     d #TOSLHAND       s                   like($slhand)
     d #TOSLLOC        s                   like($slloc)
     d #TOSLRLVL       s                   like($slrlvl)
     d #TOSLSTAT       s                   like($slstat)
     d #TOSLPICK       s                   like($slpick)
     D tocwgt          s                   like($itcwgt)
     D todisp          s             12
     D toitem          s             15
     D toqty1          s                   like($slstk1)
     D toqty2          s                   like($slstk1)
     D toqty3          s                   like($slstk1)
     D towhdp          s              5
     D*#frombasesldsp  s                   like($sldisp)
     D*#fromslwhdp     s                   like($slwhdp)
     D*#fromslstyp     s                   like($slstyp)
     D*#fromsldisp     s                   like($sldisp)
     D*#fromslaisl     s                   like($slaisl)
     D*#fromslloc      s                   like($slloc)
     D*#fromslpseq     s                   like($slpseq)
     D*#fromslrlvl     s                   like($slrlvl)
     D*#fromslhand     s                   like($slhand)
     D*#fromslstat     s                   like($slstat)
     D*#fromslrsrv     s                   like($slrsrv)
     D*#fromslentd     s                   like($slentd)
     D*#fromslexpd     s                   like($slexpd)
     D*#fromslslfd     s                   like($slslfd)
     D*#fromslactv     s                   like($slactv)
     D*#fromslbld      s                   like($slbld)
     D*#fromslpick     s                   like($slpick)
     D*#fromslitem     s                   like($slitem)
     D*#fromslsdef     s                   like($slsdef)
     D*#fromslpos      s                   like($slpos)
     D*#fromslvirt     s                   like($sfvirt)
     D*#fromslstk1     s                   like($slstk1)
     D*#fromslstk2     s                   like($slstk2)
     D*#fromslstk3     s                   like($slstk3)
     D*#fromslalc1     s                   like($slalc1)
     D*#fromslalc2     s                   like($slalc2)
     D*#fromslalc3     s                   like($slalc3)
     D*#fromsltfr1     s                   like($sltfr1)
     D*#fromsltfr2     s                   like($sltfr2)
     D*#fromsltfr3     s                   like($sltfr3)
     D*#fromslpck1     s                   like($slpck1)
     D*#fromslpck2     s                   like($slpck2)
     D*#fromslpck3     s                   like($slpck3)
     D*#fromslrcv1     s                   like($slrcv1)
     D*#fromslrcv2     s                   like($slrcv2)
     D*#fromslrcv3     s                   like($slrcv3)
     D*#fromslphy1     s                   like($slphy1)
     D*#fromslphy2     s                   like($slphy2)
     D*#fromslphy3     s                   like($slphy3)
     D*#fromslavl1     s                   like($slavl1)
     D*#fromslavl2     s                   like($slavl2)
     D*#fromslavl3     s                   like($slavl3)
     D*#fromToLcns     s                   like($saToLcns)
     D*#fromToPos      s                   like($saToPos)
     D*#fromOLcns      s                   like($saOLcns)
     D today           s              8  0
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
     D $ttoslot        s             12
     D $tpartime       s               Z
     D $tUCI           s            100

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z

     D bfcoffset       s              3  0 inz(0)
     D ucOffset        s              3  0

     *----------------------------------------------------------------
     *  LT210 parameters
     *----------------------------------------------------------------

     D  $tcmd          s              8
     D  $tprogram      s             10
     D  $ttype         s              3
     D  $thead         s             20
     D  $twhse         s              3  0
     D  $titem         s             15
     D  $titemdsc      s             65
     D  $twhdp         s              5
     D  $tslot         s             12
     D  $tslotpos      s              3  0
     D  $templ#        s              5  0
     D  $ttran#        s              7  0
     D  $tlic#         s             15
     D  $tnewlic#      s             15
     D  $tqty1         s              5  0
     D  $tqty2         s              3  0
     D  $tqty3         s              3  0
     D  $tnorm1        s              5  0
     D  $tnorm2        s              3  0
     D  $tnorm3        s              3  0
     D  $tpartial      s               n
     D  $tpulled       s              3  0
     D  $tinslot       s              1
     D  $tsamepos      s              1
     D  $tdiffpos      s              1
     D  $tpsplit       s              1
     D  $tinlic#       s             15
     D  $toutlic#      s             15
     D  $tnexttask     s             10
     D  $treturn       s              8
     D  $terrmsg       s             60
     D  $tmsgid        s              4

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------

     D driItemCalled   s               n
     D driSlotCalled   s               n

     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $lcode                19     20
     D  $lwhseu               19     21  0
     D  $litemu               22     36
     D  $lcodeu               37     38
     D  $w1type               39     39
     D  w1qt01                40     44  0
     D  w1qt02                45     47  0
     D  w1qt03                48     50  0
     D  w1cwtr                51     59  2
     D  $ldate                60     64p 0
     D  $ltime                65     68p 0
     D  $lwhseTfr             19     21  0
     D  $lwhdpTfr             22     26
     D  $ldispTfr             27     38
     D  $ldispTfrTo           39     50
     D  $luomTfr              51     51
     D  $llcnsTfr             54     68
     *----------------------------------------------------------------
     *  Called program prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.exordh
      /copy qcopysrc,p.driitem
      /copy qcopysrc,p.drislot
      /copy qcopysrc,p.getuser
      /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD     *CLRNEGAVL, *CLRNEG, *QTY(FUTURE), *LCNS(FUTURE)
     *      $PWHSE    Warehouse
     *      $PDEPT    Department
     *      $PFRMSLOT (*PICK = Get Pick slot for to slot item)
     *      $PFRMLCNS Only used with *LCNS
     *      $PTOSLOT  To Slot
     *      $PTFRQTY1
     *      $PTFRQTY2
     *      $PTFRQTY3
     *
     *    Returned Parameters
     *      *none
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd            10
     C                   parm                    $pwhse            3 0
     C                   parm                    $pdept            5
     C                   parm                    $pfrmslot        12
     C                   parm                    $pfrmlcns        15
     C                   parm                    $ptoslot         12
     C                   parm                    $PTFRQTY1         5 0
     C                   parm                    $PTFRQTY2         5 0
     C                   parm                    $PTFRQTY3         5 0

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

       *inlr = *on;
       getUser(#curruser: e$whse: e$emp#: e$fnam: e$init: e$lnam:
               e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
               e$bpu: e$lng);

       select;
         when $pcmd = '*CLRNEGAVL';
           exsr ClrNegAvl;
         when $pcmd = '*CLRNEG';
         when $pcmd = '*QTY';
         when $pcmd = '*LCNS';
       endsl;

       return;

      /end-free

     *----------------------------------------------------------------
     *  getpick  Get pick slot.
     *----------------------------------------------------------------

     c     getpick       begsr
     *
     *  Does the item have a pick slot
     *
     C                   eval      $scmd = '*FRSTPCK'
     C                   call      'GETPSLT'
     C                   parm                    $scmd             8
     C                   parm      $pwhse        $swhse            3 0
     C                   parm      $slitem       #sitem           15
     C                   parm                    woslot           12
     C                   parm      *blanks       $saisl            3
     C                   parm      *zeros        $sloc             3 0
     C                   parm      *zeros        $srlvl            2 0
     C                   parm      *blanks       $shand            2
     C                   parm                    $srtn             8
     c                   endsr

     *----------------------------------------------------------------
     *  ClrNegAvl      Check if route has an audit
     *----------------------------------------------------------------

     c     clrnegavl     begsr


      /free

       // Check to make sure to slot exists with a negative qty
       exsr getToSlot;
       if not error;
         if $slstk1 > 0 or $slstk2 > 0 or $slstk3 >0;
           return;
         endif;
         // item cannot be a uci tracked item.
         exsr getitem;
         if not error;
           if $imltrk = 'U';
             return;
           endif;
         else;
           return;
         endif;
       else;
         return;
       endif;
       // get pick slot if from slot = *PICK
       if $pfrmslot  = '*PICK';
         exsr getpick;

         if $SRTN = '*OKPICK ';
           to$Slot  = $slot;
           to$Slot2 = $slot2;
           exsr getFromSlot;
           // from slot must exist and must contain to slot item
           if not error;
             frm$Slot  = $slot;
             frm$Slot2 = $slot2;
             if to$slot.$slitem <> $slitem;
               return;
             endif;
             // from slot must have available qty available
             if $ptfrqty1  > frm$slot.$slavl1  or
                $ptfrqty2  > frm$slot.$slavl2  or
                $ptfrqty3  > frm$slot.$slavl3;
               return;
             endif;
           else;
             return;
           endif;
         else;
           return;
         endif;
       else;
       endif;
       // qty should be transferred in fefo order
       // progran should attempt to bring the to stock qty to zero

       exsr zztfr;

      /end-free

     c                   endsr



     *----------------------------------------------------------------
     *  getToSlot  Get to slot info.
     *----------------------------------------------------------------

     c     gettoslot     begsr
      /free

         error = *off;

         savever# = $slver#;
         clear $slot;
         $slver# = savever#;

         $slwhse = $pwhse;
         $slwhdp = $pdept;
         $sldisp = $ptoslot;
         $dridata = $slot;
         $dridata2 = $slot2;

         driSlotCalled = *on;
         driSlot('%GET': $pprogram: $drireturn: $drimessage:
                         $dridata: $dridata2);

         $slot = $dridata;
         $slot2= $dridata2;

         select;
           when %error;
             error = *on;
           when $drireturn <> '*OK';
             error = *on;
         endsl;

      /end-free

     c                   endsr
     *----------------------------------------------------------------
     *  getFromSlot  Get From slot info.
     *----------------------------------------------------------------

     c     getfromslot   begsr
      /free

         error = *off;

         savever# = $slver#;
         clear $slot;
         $slver# = savever#;

         $slwhse = $pwhse;
         $slwhdp = $pdept;
         $sldisp = woslot;
         $dridata = $slot;
         $dridata2 = $slot2;

         driSlotCalled = *on;
         driSlot('%GET': $pprogram: $drireturn: $drimessage:
                         $dridata: $dridata2);

         $slot = $dridata;
         $slot2= $dridata2;

         select;
           when %error;
             error = *on;
           when $drireturn <> '*OK';
             error = *on;
         endsl;

      /end-free

     c                   endsr
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

         $itwhse = $pwhse;
         $ititem = $slitem;
         $dridata = $item;
         $dridata2 = $item2;

         driItemCalled = *on;
         driItem('%GETMAIN': $pprogram: $drireturn: $drimessage:
                  $dridata: $dridata2);

         $item = $dridata;
         $item2 = $dridata2;

         select;
           when %error;
             error = *on;
           when $drireturn <> '*OK';
             error = *on;
         endsl;

      /end-free
     c                   endsr

     *----------------------------------------------------------------
     *  usr2put  Move from user slot to to slot
     *----------------------------------------------------------------

     c     usr2put       begsr
      /free

        error = *off;

        savever# = $slver#;
        clear $slot;
        clear $slot2;
        $slver# = savever#;

        $slwhseu  = *on;
        $slwhse   = $pwhse;
        $slwhdpu  = *on;
        $slwhdp   = $pdept;
        $sldispu  = *on;
        $sldisp   = to$slot.$sldisp;
        $slentdu  = *on;
        $slentd   = frm$slot.$slentd;
        $slexpdu  = *on;
        $slexpd   = frm$slot.$slexpd;
        $saitemu  = *on;
        $saitem   = $ititem;
        $saqtyu   = *on;
        $saqty1   = w1qt01;
        $saqty2   = w1qt02;
        $saqty3   = w1qt03;
        $sacitemu = *on;
        $sacitem  = frm$slot.$slitem;
        $sacdspu  = *on;
        $sacwhdu = *on;
        $sacwhd  = wuUsrWhdp;
        $sacdsp   = wuUsrDisp;
        $saToPosu = *on;
        $saToPos  = $tslotpos;
        $saActionU = *on;
        $saAction = 'TFR';
        $saTrn#U = *on;
        $saTrn# = curtrn#;
        $saETrn#U = *on;
        $saETrn# = 0;
        $saToLcnsU = *on;
        $saToLcns = $tinlic#;
        $saToPosU = *on;
        $saToPos = $tslotpos;
        $saToVrfyU = *on;
        $saToVrfy = 'N';
        $saToCodeu = *on;
        $saToCode = 'S';
        $saToAreaU = *on;
        $saToArea = 'Slot';
        $saFrmLcnsU = *on;
        $saFrmLcns = $toutlic#;
        $saOLcnsU = *on;
        $saOLcns = wuPulolcns;
        $sapullwhdpu = *on;
        $sapullwhdp  = wuPulWhdp;
        $sapulldispu = *on;
        $sapulldisp  = wuPulDisp;
        $sapullbaseu = *on;
        $sapullbase  = wuPulBase;
        $sapulllcnsu = *on;
        $sapulllcns  = wuPulLcns;
        if rtnToOrig = *on;
          $saexcdU = *on;
          $saexcd  = 'RTNORIG';
        endif;
        if $tpartial = *on;
          $saUCIts = $tpartime;
          $saUCItsU = *on;
        endif;
         $dridata = $slot;
         $dridata2 = $slot2;

         driSlotCalled = *on;
         driSlot('%USR2PUT': $pprogram: $drireturn: $drimessage:
                  $dridata: $dridata2);

         $slot = $dridata;
         $slot2 = $dridata2;

         select;
           when %error;
             error = *on;
           when $drireturn <> '*OK';
             error = *on;
         endsl;

      /end-free

     c                   endsr
     *----------------------------------------------------------------
     *  setstat    Set stat of slot.
     *----------------------------------------------------------------

     c     setstat       begsr
      /free

        error = *off;

        savever# = $slver#;
        clear $slot;
        clear $slot2;
        $slver# = savever#;

        $slwhseu  = *on;
        $slwhse   = $pwhse;
        $slwhdpu  = *on;
        $slwhdp   = frm$slot.$slwhdp;
        $sldispu  = *on;
        $sldisp   = frm$slot.$sldisp;
        $slitemu  = *on;
        $slitem   = frm$slot.$slitem;
        $slstatu  = *off;
        $slstat   = frm$slot.$slstat;

        $dridata = $slot;
        $dridata2 = $slot2;

        driSlotCalled = *on;
        driSlot('%SETSTAT': $pprogram: $drireturn: $drimessage:
                 $dridata: $dridata2);

        $slot = $dridata;
        $slot2 = $dridata2;

        select;
          when %error;
            error = *on;
          when $drireturn <> '*OK';
            error = *on;
        endsl;

      /end-free

     c                   endsr
     *----------------------------------------------------------------
     *
     *  ZZTFR    Initiate the transfer for UCI tracking.
     *
     c     zztfr         begsr
      /free
        $lcmd = '*CHANGE ';
        $lwhseTfr = $pwhse;
        $lwhdpTfr = $pdept;
        $ldispTfr = frm$Slot.$sldisp;
        $ldispTfrTo = to$Slot.$sldisp;
        // transfer to the usr slot
        error = *off;
        *in59 = *off;
      /end-free
     *
     *  Set partial quantity flag.
     *
     *
      /free
        if frm$Slot.$slstk1 = $ptfrqty1 and
           frm$Slot.$slstk2 = $ptfrqty2 and
           frm$Slot.$slstk3 = $ptfrqty3;
          partial = *off;
        else;
          partial = *on;
        endif;
      /end-free

     *  License plate tracking item. Update to show in transit.

      /free
        exsr zzzclr$lt210;
        $tcmd  = '*PULTRAN';
        $tlic# = FRM$SLOT2.$SATOLCNS;
        $tnewlic# = FRM$SLOT2.$SATOLCNS;
        $twhse    = $pwhse;
        $titem    = frm$Slot.$slitem;
        $titemdsc = $itdesc;
        $tpartial = partial;
        w1qt01 = $ptfrqty1;
        w1qt02 = $ptfrqty2;
        w1qt03 = $ptfrqty3;
        $tqty1    = w1qt01;
        $tqty2    = w1qt02;
        $tqty3    = w1qt03;
        $tnorm1   = w1qt01;
        $tnorm2   = w1qt02;
        $tnorm3   = w1qt03;
        $tuci = ' ';

        exsr zzzcall$lt210;

        if $treturn <> '*OK';
        endif;

        curlic# = $tinlic#;
      /end-free

     *  Use DRI interface to update From slot.
     *    Note: The $sl info was retrieved in ZZGET1.

      /free
        savever# = $slver#;
        clear $slot;
        clear $slot2;
        $slver# = savever#;

        $slwhseu  = *on;
        $slwhse   = $pwhse;
        $slwhdpu  = *on;
        $slwhdp   = $pdept;
        $sldispu  = *on;
        $sldisp   = frm$Slot.$sldisp;
        $saitemu  = *on;
        $saitem   = $ititem;
        $saqtyu   = *on;
        $saqty1   = w1qt01;
        $saqty2   = w1qt02;
        $saqty3   = w1qt03;
        $sacitemu = *on;
        $sacitem  = $ititem;

        $satasku = *on;
        $satask  = 'TFRMOV';

        $saActionU = *on;
        $saAction = 'TFR';
        $saTrn#U = *on;
        $saTrn# = curtrn#;
        $saETrn#U = *on;
        $saETrn# = 0;
        $saToLcnsU = *on;
        $saToLcns = $tinlic#;
        $saToPosU = *on;
        $saToPos = $tslotpos;
        $saToVrfyU = *on;
        $saToVrfy = 'N';
        $saToCodeu = *on;
        $saToCode = 'U';
        $saToAreaU = *on;
        $saToArea = 'User';
        $saFrmLcnsU = *on;
        $saFrmLcns = $toutlic#;
        $saOLcnsU = *on;
        $saOLcns = wuPulolcns;

        $dridata = $slot;
        $dridata2 = $slot2;

        driSlotCalled = *on;
        if frm$slot.$slpick = 'Y'
           and frm$slot.$slitem = $ititem;
          Ypickslot   = *on;
        endif;
        driSlot('%TFR2USR': $pprogram: $drireturn: $drimessage:
                 $dridata: $dridata2);

        $slot = $dridata;
        $slot2 = $dridata2;

        if error;
          return;
        endif;
        tfr2usrDate = today;
        tfr2usrTime = %Dec(%Time():*ISO);
        tfroutflag = *on;
        curlic# = $saToLcns;
        $tinlic# = $saToLcns;
      /end-free

     *  Override $saFrmEmpty for an empty Pick slot.
     *  Re: We want to ask a user if the slot is empty just in case he is
     *  moving the item to another Pick slot and we are allow to auto verify.

      /free
        if Ypickslot   = *on
           and partial = *off;
          $saFrmEmpty = 'Y';
        endif;
      /end-free
     *
     *  Create work record.
     *
      /free
        exsr zzwrkadd;
      /end-free

     *    Then tell user to put back an pulled pallets.
     *         and move on to the putaway process.

      /free
        exsr zzzclr$lt210;
        $tcmd  = '*PULRTN';
        $twhse = $pwhse;
        $twhdp = frm$slot.$slwhdp;
        $tslot = frm$slot.$sldisp;
        $titem = frm$slot.$slitem;
        $titemdsc = $itdesc;
        $tlic# = $saToLcns;
        exsr zzzcall$lt210;
        if $treturn <> '*OK';
        endif;
        error = *off;
        toqty1 = w1qt01;
        toqty2 = w1qt02;
        toqty3 = w1qt03;
      /end-free

     *    Determine if we are returning qty to original slot.

      /free
        if $pdept = wuPulWhdp
           and $ptoslot = wuPulDisp
           and $ititem = wuPulItem;
          rtnToOrig = *on;
        else;
          rtnToOrig = *off;
        endif;
      /end-free

     *    Call license tracking for putaway - Before update
     *    Only call when not returning to original slot.

      /free
        select;
          when rtnToOrig = *on;
            $tinlic# = wuPulLcns;
            $tslotpos = wuPulPos;
            $toutlic# = wuUsrLcns;
          other;
            if not skipLT210;
              exsr zzzclr$lt210;
              $tcmd = '*PUTAWYB';
              $tlic# = wuUsrLcns;
              $tpartial = partial;
              $twhse  = $pwhse;
              $twhdp  = $pdept;
              $tslot  = to$slot.$sldisp;
              $titem  = $ititem;
              $titemdsc = $itdesc;
              $tqty1  = toqty1;
              $tqty2  = w1qt02;
              $tqty3  = w1qt03;
              $tnorm1 = toqty1;
              $tnorm2 = w1qt02;
              $tnorm3 = w1qt03;
              $tuci = ' ';
              exsr  zzzcall$lt210;
              if $treturn <> '*OK';
                return;
              endif;
            endif;

        endsl;
      /end-free

     *  Use DRI interface to tfr qty from USR slot to To slot.

      /free
        exsr usr2put;
        if error;
          return;
        endif;
      /end-free

     *  Update #TO slot info in case item was put into a virtual slot.

      /free
        #toslhand = $slhand;
        $ptoslot  = $sldisp;
        #toslstat = $slstat;
      /end-free

     *    Call license tracking for putaway - After update
     *      Values are left over from "Before" call.

      /free
        $tcmd  = '*PUTAWYA';
        $twhdp = $pdept;
        $tslot = $ptoslot;
        exsr zzzcall$lt210;
        if $treturn <> '*OK';
        endif;
        if Ypickslot = *on
           and $slpick = 'Y'
           and $slstat <> 'RP'
           and $slstyp = 'F';
          exsr setstat;
          Ypickslot = *off;
          if $drireturn = 'NOTZROSTAT';
            error = *off;
          endif;
        endif;
        Ypickslot = *off;
      /end-free

     *  Create label(s), create extra trans, close trans.

      /free
        //exsr zzcrtl;
      /end-free

     *  Delete work record
      /free
        exsr zzwrkdel;
      /end-free

     c                   endsr
     *----------------------------------------------------------------
     *  ZZZCLR$LT210  -  Clear LT210 parameters.
     *----------------------------------------------------------------

     c     ZZZCLR$LT210  begsr

      /free
        clear $tcmd;
        clear $tprogram;
        clear $ttype;
        clear $thead;
        clear $twhse;
        clear $titem;
        clear $titemdsc;
        clear $twhdp;
        clear $tslot;
        clear $tslotpos;
        clear $templ#;
        clear $ttran#;
        clear $tlic#;
        clear $tnewlic#;
        clear $tqty1;
        clear $tqty2;
        clear $tqty3;
        clear $tnorm1;
        clear $tnorm2;
        clear $tnorm3;
        clear $tpartial;
        clear $tpulled;
        clear $tinslot;
        clear $tsamepos;
        clear $tdiffpos;
        clear $tpsplit;
        clear $tinlic#;
        clear $toutlic#;
        clear $tnexttask;
        clear $treturn;
        clear $terrmsg;
        clear $tmsgid;
        clear $ttoslot;
        clear $tpartime;
        clear $tUCI;
      /end-free

     c                   endsr

     *----------------------------------------------------------------
     *  ZZZCALL$LT210  -  CALL LT210.
     *----------------------------------------------------------------

     c     ZZZCALL$LT210 begsr

     C                   call      'LT210'
     C                   parm                    $tcmd
     C                   parm      #prog         $tprogram
     C                   parm      'ADJ'         $ttype
     C                   parm      'Adjustment'  $thead
     C                   parm                    $twhse
     C                   parm                    $titem
     C                   parm                    $titemdsc
     C                   parm                    $twhdp
     C                   parm                    $tslot
     C                   parm                    $tslotpos
     C                   parm      e$emp#        $templ#
     C                   parm                    $ttran#
     C                   parm                    $tlic#
     C                   parm                    $tnewlic#
     C                   parm                    $tqty1
     C                   parm                    $tqty2
     C                   parm                    $tqty3
     C                   parm                    $tnorm1
     C                   parm                    $tnorm2
     C                   parm                    $tnorm3
     C                   parm                    $tpartial
     C                   parm                    $tpulled
     C                   parm                    $tinslot
     C                   parm                    $tsamepos
     C                   parm                    $tdiffpos
     C                   parm                    $tpsplit
     C                   parm                    $tinlic#
     C                   parm                    $toutlic#
     C                   parm                    $tnexttask
     C                   parm                    $treturn
     C                   parm                    $terrmsg
     C                   parm                    $tmsgid
     C                   parm                    $ttoslot
     C                   parm                    $tpartime
     C                   parm                    $tUCI

     c                   endsr

     *----------------------------------------------------------------
     *  zzwrkadd   Add record to work file for user.
     *----------------------------------------------------------------

     c     zzwrkadd      begsr
      /free
        exsr zzgetcurrstamp;
        clear wuRec;

        wutrn# = curtrn#;
        wuwhse = $pwhse;
        wuscannbr = FRM$SLOT2.$SATOLCNS;
        wuscantype = 'P';
        wupulwhdp = frm$slot.$slwhdp;
        wupulbase = frm$slot.$sacdsp;
        wupuldisp = frm$slot.$sldisp;
        wupulitem = frm$slot.$slitem;
        wupullcns = FRM$SLOT2.$SATOLCNS;
        wupulolcns = frm$slot2.$saolcns;
        wupulvfy   = $saFrmEmpty;

        wuUsrWhdp = $slwhdp;
        wuUsrDisp = $sldisp;
        wuNewItem = frm$slot.$slitem;

        wuRemQty1 = w1qt01;
        wuRemQty2 = w1qt02;
        wuRemQty3 = w1qt03;

        wuPullCns = $toutlic#;
        wuUsrLcns = $tinlic#;

        wuRecType = 'TFR';
        wuaddts  = currstampsys;
        wuadduc  = currstampuc;
        wuaddpgm = #pgm;
        wuaddemp = e$emp#;
        wuaddeusr = #curruser;
        wuaddjusr = #user;
        wuaddjob = #job;
        wuaddnbr = #jobnbr;

        write wuRec;

      /end-free
     c                   endsr

     *----------------------------------------------------------------
     *  zzwrkdel   Delete work file record
     *----------------------------------------------------------------

     c     zzwrkdel      begsr
      /free
        chain (wktype: e$emp#: $pwhse:
               $pdept: frm$slot.$sldisp) workusr3;
        if %found(workusr3);
          delete wuRec;
        endif;
      /end-free
     c                   endsr

     *----------------------------------------------------------------
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

     C     zzgetcurrstampbegsr

     C                   callp     getmicrotime(currstampuc:currstampsys)
     C     currstampsys  adddur    bfcoffset:*H  currstamploc

     C                   endsr
