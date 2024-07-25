      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  IT118  Generate ODR Repack Slot
     *  September 20 2018
     *  Kenneth Elder
     *
     *  Revisions
     *
720  *   09/20/18  KDE  7.20
     *     - Created - Originally called from DRIITEM Merit Only
     *
     *----------------------------------------------------------------
     *  File Specs
MRTaAfvslot1    if   e           k disk

     *----------------------------------------------------------------
     *  Standard Variables
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL Variables
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Client id's for custom mods.
     *----------------------------------------------------------------

MRTaA /copy qcopysrc,id#mrt

500aAD client          s             10

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS
      /COPY *libl/qcopysrc,C#DRIPARMP
     D savesubcmd      s                   like($psubcmd)
416dAD savesubcmd2     s                   like($psubcmd)

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

610aA /COPY *libl/qcopysrc,C#Slot

     D saveVer#        s                   like($slver#)

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcount         s              3p 0
     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10
     D $vsdesc         s              5

     *----------------------------------------------------------------
     *  Variables
     d recCnt          s              5  0
     d baseODRSlot     s             12
610aAD drislot         s               n
640aMD main2err        s               n
640aMD main2callerr    s               n
640aMD main2rtnerr     s               n

     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *  Main line

     c     *entry        plist
     c                   parm                    pWhse            15 5
     c                   parm                    pWhdp             5
     c                   parm                    pItem            15
     c                   parm                    pDisp            12
      /free
           exsr updSlot;
           *inlr=*on;
           return;
      /end-free

MRTaA*----------------------------------------------------------------
MRTaA*  UPDSLOT  Update Slot File if virtual pick
MRTaA*----------------------------------------------------------------
MRTaAC     updSlot       begsr
MRTaA /free
MRTaA              recCnt = *zeros;
MRTaA              exec sql select count(*) into :recCnt
MRTaA                       from slot3
MRTaA                     where slwhse=:pWhse and
MRTaA                           slwhdp=:pwhdp and
MRTaA                           slitem=:pitem and
MRTaA                           slstat='A ' and slpick='Y';
MRTaA              if recCnt <> *zeros;
MRTaA                 // do nothing since pick found on actual
MRTaA                 // Repack item
MRTaA              else;
MRTaA                 baseODRSlot = pdisp;
MRTaA                 // when found see if virtual or base
MRTaA                 chain (pwhse:pwhdp:baseODRSlot) vslot1;
MRTaA                 if %found(vslot1);
MRTaA                    baseODRSlot = vspdis;
MRTaA                 endif;
MRTaA
MRTaA              // Call DRISLOT to create Virtual Pick Slot
MRTaA
MRTaA                 if baseODRSlot <> *blanks;
MRTaA                   exsr clr$slot;
MRTaA                   $slwhseu = *on;
MRTaA                   $slwhse  = pwhse;
MRTaA                   $slwhdpu = *on;
MRTaA                   $slwhdp  = pwhdp;
MRTaA                   $sldispu = *on;
MRTaA                   $sldisp  = baseODRSlot;
MRTaA                   $slitemu = *on;
MRTaA                   $slitem  = pitem;
MRTaA                   $dricommand = 'DRISLOT';
MRTaA                   $drisubcmd = '%CRTVPICK';
MRTaA                   $drisys2upd = 'D';
MRTaA                   exsr zzzdrimain2;
MRTaA                   if $drireturn = 'VRTPCKCRT';
MRTaA                      // make sure repack virtual is stat A
MRTaA                      exec sql update slot2 set slstat='A'
MRTaA                               where slwhse=:$slwhse and
MRTaA                                     sldisp=:$sldisp and
MRTaA                                     slwhdp=:$slwhdp and
MRTaA                                     slitem=:$slitem;
MRTaA                   endif;
MRTaA                 endif;
MRTaA              endif;
MRTaA /end-free
MRTaAC                   endsr

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   endsr
     *----------------------------------------------------------------
640aM*  zzzdrimain2  Call DRIMAIN2
     *----------------------------------------------------------------

640aDC**   zzzdrimain3   begsr
640aMC     zzzdrimain2   begsr
640aMC                   eval      main2err = *off
640aMC                   eval      main2callerr = *off
640aMC                   eval      main2rtnerr = *off

     C                   select
     C                   when      $dricommand = 'DRISLOT'
     C                   eval      drislot = *on
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   endsl

     C                   if        $dricommand = 'DRISLOT'
640aDC**                 call(e)   'DRIMAIN3'
640aMC                   call(e)   'DRIMAIN2'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
640aDC**                 call(e)   'DRIMAIN3'
640aMC                   call(e)   'DRIMAIN2'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      %error
640aMC                   eval      main2err = *on
640aMC                   eval      main2callerr = *on
     C                   eval      $drireturn  = 'CALLERROR'
     C                   eval      $drimessage = 'Error occured on call to '
640aMC                                         + 'DRIMAIN2'
     C                                         + '/' + %trim($drisubcmd)
     C                                         + ' from ' + $pprogram

     C                   when      $drireturn <> '*OK'
640aMC                   eval      main2err = *on
640aMC                   eval      main2rtnerr = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = 'DRISLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   endsl

     C     enddricop     endsr
