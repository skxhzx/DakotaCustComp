      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  I13600       Get Slot Physical Quantity
     *  20 Septembr 2017
     *  Lynn McMahon
     *
     *  Revisions:
     *
710 A*    09/20/17  LMC  7.10
     *      - Created.
750aA*    01/28/21  LMC  7.50a
     *      - implement qty rounding logic same as in sl810 mod 720
     *      - added call  to driitem
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pUser       User
     *      pPgm        Program
     *      pWhse       Warehouse
     *      pDept       Department
     *      pdisp       Slot
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

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
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  files
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.dricop
      /copy qcopysrc,p.getuser

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  puser          s             10
     D  ppgm           s             10
     D  pwhse          s              3  0
     D  pdept          s              5
     D  pdisp          s             12
     D  pOutStr        s           1024    varying
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D client          s             10
     D clientloc       s             10

     D forevr          s               n

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

750aAd Newqtyn         s              5  0
750aAd Newqty1         s              9  0
750aAd Newqty2         s              9  0
     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#SLOT
750aA /COPY *libl/qcopysrc,C#item
     D savever#        s                   like($slver#)

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     *----------------------------------------------------------------

     c     *entry        plist
     C                   parm                    pUser
     C                   parm                    pPgm
     C                   parm                    pWhse
     C                   parm                    pDept
     C                   parm                    pDisp
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;
        pOutStr = ' ';
        // get physical qty from drislot

        savever# = $slver#;
        clear $slot;
        clear $slot2;

        $slwhseu = *on;
        $slwhse  = pwhse;
        $slwhdpu = *on;
        $slwhdp = pDept;
        $sldispu = *on;
        $sldisp = pDisp;

        $dricommand = '*SLOT';
        $drisubcmd  = '%GET2';
        $drisys2upd = 'D';
        $driprogram = #pgm;
        $dridata = $slot;
        $dridata2 = $slot2;

        // Call DRI program.

        driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
               $drireturn: $drimessage: $dridata: $dridata2);

        $slot = $dridata;
        $slot2 = $dridata2;

750aA   // get item

750aA   savever# = $slver#;
750aA   clear $item;
750aA   clear $item2;

750aA   $itwhse  = pwhse;
750aA   $itwhdpu = *on;
750aA   $itwhdp = pDept;
750aA   $ititem = $slitem;

750aA   $dricommand = '*ITEM';
750aA   $drisubcmd  = '%GETALL';
750aA   $drisys2upd = 'D';
750aA   $driprogram = #pgm;
750aA   $dridata = $item;
750aA   $dridata2 = $item2;
750aA
750aA   // Call DRI program.

750aA   driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
750aA          $drireturn: $drimessage: $dridata: $dridata2);

750aA   $item = $dridata;
750aA   $item2 = $dridata2;
750aA   exsr zzrollup;
         // Put together JSON string

         pOutStr = '{'
750aA           +  '"slstk1":"'  + %char($slstk1) + '",'
750aA           +  '"slstk2":"'  + %char($slstk2) + '",'
750aA           +  '"slstk3":"'  + %char($slstk3) + '",'
750aA           +  '"slalc1":"'  + %char($slalc1) + '",'
750aA           +  '"slalc2":"'  + %char($slalc2) + '",'
750aA           +  '"slalc3":"'  + %char($slalc3) + '",'
750aA           +  '"slpck1":"'  + %char($slpck1) + '",'
750aA           +  '"slpck2":"'  + %char($slpck2) + '",'
750aA           +  '"slpck3":"'  + %char($slpck3) + '",'
750aA           +  '"sltfr1":"'  + %char($sltfr1) + '",'
750aA           +  '"sltfr2":"'  + %char($sltfr2) + '",'
750aA           +  '"sltfr3":"'  + %char($sltfr3) + '",'
750aA           +  '"slrcv1":"'  + %char($slrcv1) + '",'
750aA           +  '"slrcv2":"'  + %char($slrcv2) + '",'
750aA           +  '"slrcv3":"'  + %char($slrcv3) + '",'
750aA           +  '"slavl1":"'  + %char($slavl1) + '",'
750aA           +  '"slavl2":"'  + %char($slavl2) + '",'
750aA           +  '"slavl3":"'  + %char($slavl3) + '",'
                +  '"slphy1":"'  + %char($slphy1) + '",'
                +  '"slphy2":"'  + %editc($slphy2:'Z') + '",'
                +  '"slphy3":"'  + %editc($slphy3:'Z') + '"';

         // Close off the JSON string
         pOutStr += '}';

      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         getclient(client: clientLoc);

       endsr;

      /end-free

     *
     *----------------------------------------------------------------
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

      /free
       begsr getCurrStamp;

         getmicrotime(currstampuc:currstampsys);
         currstamploc = currstampsys + %hours(bfcoffset);

       endsr;
      /end-free
750aA *----------------------------------------------------------------
750aA *  ZZROLLUP      Rollup Breakdown Quantities
750aA *----------------------------------------------------------------
750aA
750aAC     zzrollup      begsr
750aA
750aA /free
750aA   // Ensure everything rolled correctly with Breakdowns
750aA   // Stock Quantity first
750aA      if $slstk2<>0 or $slstk3<>0;
750aA        select;
750aA         when $slstk3 <> 0;
750aA    //First, take to lowest level quantity based on breakdowns
750aA            newqty2 = (($slstk1 * $itumq2 * $itumq3) +
750aA                       ($slstk2 * $itumq3) +
750aA                        $slstk3);
750aA            newqty1=*zeros;
750aA            newqtyn=*zeros;
750aA         when $slstk2 <> 0;
750aA            newqty1 = (($slstk1 * $itumq2) +
750aA                        $slstk2);
750aA            newqtyn=*zeros;
750aA        endsl;
750aA   //Next, roll back up with breakdown structure
750aA        exsr zzupQty;
750aA        $slstk1 = newqtyn;
750aA        $slstk2 = newqty1;
750aA        $slstk3 = newqty2;
750aA      endif;
750aA   // Allocated Quantity next
750aA      if $slalc2<>0 or $slalc3<>0;
750aA        select;
750aA         when $slalc3 <> 0;
750aA    //First, take to lowest level quantity based on breakdowns
750aA            newqty2 = (($slalc1 * $itumq2 * $itumq3) +
750aA                       ($slalc2 * $itumq3) +
750aA                        $slalc3);
750aA            newqty1=*zeros;
750aA            newqtyn=*zeros;
750aA         when $slalc2 <> 0;
750aA            newqty1 = (($slalc1 * $itumq2) +
750aA                        $slalc2);
750aA            newqtyn=*zeros;
750aA        endsl;
750aA   //Next, roll back up with breakdown structure
750aA        exsr zzupQty;
750aA        $slalc1 = newqtyn;
750aA        $slalc2 = newqty1;
750aA        $slalc3 = newqty2;
750aA      endif;
750aA   // Then Rcv Quantity
750aA      if $slrcv2<>0 or $slrcv3<>0;
750aA        select;
750aA         when $slrcv3 <> 0;
750aA    //First, take to lowest level quantity based on breakdowns
750aA            newqty2 = (($slrcv1 * $itumq2 * $itumq3) +
750aA                       ($slrcv2 * $itumq3) +
750aA                        $slrcv3);
750aA            newqty1=*zeros;
750aA            newqtyn=*zeros;
750aA         when $slrcv2 <> 0;
750aA            newqty1 = (($slrcv1 * $itumq2) +
750aA                        $slrcv2);
750aA            newqtyn=*zeros;
750aA        endsl;
750aA   //Next, roll back up with breakdown structure
750aA        exsr zzupQty;
750aA        $slrcv1 = newqtyn;
750aA        $slrcv2 = newqty1;
750aA        $slrcv3 = newqty2;
750aA      endif;
750aA   // Lastly, Available Quantity
750aA      if $slpck2<>0 or $slpck3<>0;
750aA        select;
750aA         when $slpck3 <> 0;
750aA    //First, take to lowest level quantity based on breakdowns
750aA            newqty2 = (($slpck1 * $itumq2 * $itumq3) +
750aA                       ($slpck2 * $itumq3) +
750aA                        $slpck3);
750aA            newqty1=*zeros;
750aA            newqtyn=*zeros;
750aA         when $slpck2 <> 0;
750aA            newqty1 = (($slpck1 * $itumq2) +
750aA                        $slpck2);
750aA            newqtyn=*zeros;
750aA        endsl;
750aA   //Next, roll back up with breakdown structure
750aA        exsr zzupQty;
750aA        $slpck1 = newqtyn;
750aA        $slpck2 = newqty1;
750aA        $slpck3 = newqty2;
750aA      endif;
750aA /end-free
750aAC                   endsr
750aA
750aA *----------------------------------------------------------------
750aA *  ZZUPQTY       Up quantity
750aA *----------------------------------------------------------------
750aA
750aAC     zzupqty       begsr
750aA
750aA /free
750aA       // check for negative quantities
750aA       *in49=*off;
750aA       if newqtyn<0;
750aA          *in49=*on;
750aA          newqtyn = %abs(newqtyn);
750aA       endif;
750aA       if newqty1<0;
750aA          *in49=*on;
750aA          newqty1 = %abs(newqty1);
750aA       endif;
750aA       if newqty2<0;
750aA          *in49=*on;
750aA          newqty2 = %abs(newqty2);
750aA       endif;
750aA /end-free
750aA
750aAC                   dow       $itumq3 > 0 and +
750aAC                               newqty2 >= $itumq3
750aAC                   eval      newqty2 -= $itumq3
750aAC                   eval      newqty1 += 1
750aAC                   enddo
750aA
750aAC                   dow       $itumq2 > 0 and +
750aAC                               newqty1 >= $itumq2
750aAC                   eval      newqty1 -= $itumq2
750aAc                   eval      newqtyn += 1
750aAC                   enddo
750aA
750aA /free
750aA                    if *in49;
750aA                       newqtyn = newqtyn * -1;
750aA                       newqty1 = newqty1 * -1;
750aA                       newqty2 = newqty2 * -1;
750aA                    endif;
750aA /end-free
750aA
750aAC                   endsr
