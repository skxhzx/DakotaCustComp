      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  R26200   Slots with Negative Quantities - get JSON info
     *  31 August 2017
     *  Mike Rooker
     *
     *  Revisions
     *
     *    08/31/17  MR  7.10
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     Fslot2     if   e           k disk
     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------
     D pWhse           s              3  0
     D pWhdp           s              5
     D pDisp           s             12
     D pItstyp         s              1
     D pItumq2         s              3  0
     D pOutStr         s           1024    varying
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #pgm             *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

720 A*----------------------------------------------------------------
720 A*  Customer id
720 A*----------------------------------------------------------------
720 A
720 A /copy qcopysrc,id#citylin

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------
     D WKStk1          s              5  0
     D WKStk2          s              3  0
     D WKStk3          s              3  0
     D WKAlc1          s              5  0
     D WKAlc2          s              3  0
     D WKAlc3          s              3  0
     D WKTfr1          s              5  0
     D WKTfr2          s              3  0
     D WKTfr3          s              3  0
     D WKPck1          s              5  0
     D WKPck2          s              3  0
     D WKPck3          s              3  0
     D WKRcv1          s              5  0
     D WKRcv2          s              3  0
     D WKRcv3          s              3  0
     D wkumq           s              3  0
     D error           s              1
     D w1alc           s             10
     D w1pck           s             10
     D w1qty           s             10
     D w1rcv           s             10
     D w1stk           s             10
     D w1tfr           s             10
     D w1styp          s              5
     D w1lcns          s             15
     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

      /COPY *libl/qcopysrc,C#SLOT
     D savever#        s                   like($slver#)
     *----------------------------------------------------------------
     *  Data Structures
     *----------------------------------------------------------------
     D $perm           ds
     D  xxerm                  1     60
     D  $pmsg                  1      4
     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse        Warehouse
     *      pWhdp        Whse Dept
     *      pDisp        Slot Display
     *      pItstyp      Section Type
     *      pItumq1      Breakdown 1 UM Qty
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pWhdp
     c                   parm                    pDisp
     c                   parm                    pItstyp
     c                   parm                    pItumq2
     c                   parm                    pOutStr
     *
     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free
        chain (pwhse:pwhdp:pdisp) slot2;
        if %found;
            eval wkstk1 = slstk1;
            eval wkstk2 = slstk2;
            eval wkstk3 = slstk3;
            eval wkalc1 = slalc1;
            eval wkalc2 = slalc2;
            eval wkalc3 = slalc3;
            eval wktfr1 = sltfr1;
            eval wktfr2 = sltfr2;
            eval wktfr3 = sltfr3;
            eval wkpck1 = slpck1;
            eval wkpck2 = slpck2;
            eval wkpck3 = slpck3;
            eval wkrcv1 = slrcv1;
            eval wkrcv2 = slrcv2;
            eval wkrcv3 = slrcv3;
            exsr calcQty;
        endif;

        // Build JSON string to return

        pOutStr = '{'
           +  '"w1Qty":"'+ %trim(w1qty)+'",'
           +  '"w1Stk":"'+ %trim(w1stk)+'",'
           +  '"w1Alc":"'+ %trim(w1alc)+'",'
           +  '"w1Pck":"'+ %trim(%trim(w1pck))+'",'
           +  '"w1Tfr":"'+ %trim(%trim(w1tfr))+'",'
           +  '"w1Rcv":"'+ %trim(%trim(w1rcv))+'",'
           +  '"w1Styp":"'+ %trim(%trim(w1styp))+'",'
720 M      +  '"w1Lcns":"'+ %trim(w1Lcns)+'",'
720 A      +  '"w1client":"'+ %trim(client)+'"';
        // Close it off

        pOutStr = %trimr(pOutStr) + '}';

        return;
      /end-free

     *----------------------------------------------------------------
     *  *CalcQty - Create Quantity String to View
     *----------------------------------------------------------------
     *    Create a quantity string to print.
     *
     C     CalcQty       Begsr
     C                   call      'SLOTQTY'
     C                   parm                    wkstk1
     C                   parm                    wkstk2
     C                   parm                    wkstk3
     *
     C                   parm                    wkalc1
     C                   parm                    wkalc2
     C                   parm                    wkalc3
     *
     C                   parm                    wktfr1
     C                   parm                    wktfr2
     C                   parm                    wktfr3
     *
     C                   parm                    wkpck1
     C                   parm                    wkpck2
     C                   parm                    wkpck3
     *
     C                   parm                    wkrcv1
     C                   parm                    wkrcv2
     C                   parm                    wkrcv3
     *
     C                   parm                    stock1            5 0
     C                   parm                    stock2            3 0
     C                   parm                    stock3            3 0
     *
     C                   parm                    avail1            5 0
     C                   parm                    avail2            3 0
     C                   parm                    avail3            3 0
     *
710aD*   If negative normal stock and positive brk1 convert
710aDC*                  if        wkstk1 < 0  and
710aDC*                            wkstk2 > 0  and
710aDC*                            pitumq2 <> 0
710aDC*    wkstk1        mult      pitumq2       wkumq
710aDC*    wkumq         add       wkstk2        wkstk2
710aDC*                  eval      wkstk1 = 0
710aDC*                  endif
710aD*   If negative normal recv and positive brk1 convert
710aDC*                  if        wkrcv1 < 0  and
710aDC*                            wkrcv2 > 0  and
710aDC*                            pitumq2 <> 0
710aDC*    wkrcv1        mult      pitumq2       wkumq
710aDC*    wkumq         add       wkrcv2        wkrcv2
710aDC*                 eval      wkrcv1 = 0
710aDC*                  endif
710aD*   If negative normal alc and positive brk1 convert
710aDC*                  if        wkalc1 < 0  and
710aDC*                            wkalc2 > 0  and
710aDC*                            pitumq2 <> 0
710aDC*    wkalc1        mult      pitumq2       wkumq
710aDC*    wkumq         add       wkalc2        wkalc2
710aDC*                  eval      wkalc1 = 0
710aDC*                  endif
710aD*   If negative normal tfr and positive brk1 convert
710aDC*                  if        wktfr1 < 0  and
710aDC*                            wktfr2 > 0  and
710aDC*                            pitumq2 <> 0
710aDC*    wktfr1        mult      pitumq2       wkumq
710aDC*    wkumq         add       wktfr2        wktfr2
710aDC*                  eval      wktfr1 = 0
710aDC*                  endif
710aD*   If negative normal pck and positive brk1 convert
710aDC*                  if        wkpck1 < 0  and
710aDC*                            wkpck2 > 0  and
710aDC*                            pitumq2 <> 0
710aDC*    wkpck1        mult      pitumq2       wkumq
710aDC*    wkumq         add       wkpck2        wkpck2
710aDC*                  eval      wkpck1 = 0
710aDC*                  endif
     C*                  endif
     *
     C                   eval      $pcmd = '*QTY2STR'
     C                   eval      $pqty1 = avail1
     C                   eval      $pqty2 = avail2
     C                   eval      $pqty3 = avail3
     C                   eval      $pqstr = *blanks
     *
     C                   exsr      zzcqty
     C                   eval      w1qty = $pqstr
     *
     C                   eval      $pqty1 = wkstk1
     C                   eval      $pqty2 = wkstk2
     C                   eval      $pqty3 = wkstk3
     C                   exsr      zzcqty
     C                   eval      w1stk = $pqstr
     *
     C                   eval      $pqty1 = wkrcv1
     C                   eval      $pqty2 = wkrcv2
     C                   eval      $pqty3 = wkrcv3
     C                   exsr      zzcqty
     C                   eval      w1rcv = $pqstr
     *
     C                   eval      $pqty1 = wkalc1
     C                   eval      $pqty2 = wkalc2
     C                   eval      $pqty3 = wkalc3
     C                   exsr      zzcqty
     C                   eval      w1alc = $pqstr
     *
     C                   eval      $pqty1 = wktfr1
     C                   eval      $pqty2 = wktfr2
     C                   eval      $pqty3 = wktfr3
     C                   exsr      zzcqty
     C                   eval      w1tfr = $pqstr
     *
     C                   eval      $pqty1 = wkpck1
     C                   eval      $pqty2 = wkpck2
     C                   eval      $pqty3 = wkpck3
     C                   exsr      zzcqty
     C                   eval      w1pck = $pqstr
     *
     *
     *  Get License
     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = pwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = pdisp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error = *on
     C                   eval      error = *off
     C                   eval      $saToPos = 0
     C                   endif
     *
     C                   eval      w1lcns = $saToLcns
     *
     C                   select
     C                   when      pitstyp = 'P'
     C                   eval      w1styp = 'PIR  '
     *
     C                   when      pitstyp = 'F'
     C                   eval      w1styp = 'FIXED'
     *
     C                   other
     C                   eval      w1styp = *blanks
     C                   endsl
     *
     **                   MOVE OQVDSP    W1VDSP
     C*                  eval      w1item = wkitem
     **                   MOVE OQSTAT    W1STAT
     C*                  eval      w1disp = wkdisp
     C*
     C                   endsr

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
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      %error
     C                   eval      error = *on

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   endsl

     C     enddricop     endsr
     *----------------------------------------------------------------
     *
     C     zzcqty        begsr
     *
     C                   eval      $pcmd = '*QTY2STR'
     *                    Z-ADDAVAIL1    $PQTY1
     *                    Z-ADDAVAIL2    $PQTY2
     *                    Z-ADDAVAIL3    $PQTY3
     C                   eval      $pqstr = *blanks
     *
     C                   call      'CVTQTY'
     C                   parm                    $pcmd             8
     C                   parm                    $pprg            10
     C                   parm                    $pqty1            7 0
     C                   parm                    $pqty2            7 0
     C                   parm                    $pqty3            7 0
     C                   parm                    $pum1             2
     C                   parm                    $pum2             2
     C                   parm                    $pum3             2
     C                   parm                    $pqstr           10
     C                   parm                    $pustr           17
     C                   parm                    $prtn             8
     C                   parm                    $perm
     *
     *                    MOVE $PQSTR    W1QTY  10
     *
     C                   endsr
     *----------------------------------------------------------------
     *  *Inzsr  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

      /end-free
720 A
720 A* Get client id.
720 A
720 AC                   call      'GETCLIENT'
720 AC                   parm                    client           10
      /free

       endsr;
      /end-free
