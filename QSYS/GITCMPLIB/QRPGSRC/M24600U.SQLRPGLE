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
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  M24600U    Cycle Count Adjustment Update
     *  17 August 2017
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
710 A*    08/17/17  LMC  7.10
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     * Clients
     *----------------------------------------------------------------

     D client          s             10
     D clientloc       s             10

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
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.cvtcase
      /copy qcopysrc,p.dricop
      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getuser
     *----------------------------------------------------------------
     * DRI Parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT
     D saveVer#        s                   like($slver#)
     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D error           s               n
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
     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds


     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  puser          s             10
     D  ppgm           s             10
     D  pwhse          s              3  0
     D  pdept          s              5
     D  pitem          s             15
     D  pdisp          s             12
     D  ptype          s              1
     D  padjcd         s              2
     D  padjuom        s              1
     D  padjqty        s              5  0
     D  padjwgt        s              9  2

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pMessage    Message
     *      pUser       User
     *      pPgm        Program
     *      pWhse       Warehouse
     *      pDept       Department
     *      pItem       Item
     *      pDisp       Slot Display
     *      pType       Adjustment Type - Increase/Decrease
     *      pAdjCd      Adjustment Code
     *      pAdjUOM     Adjustment UOM
     *      pAdjQty     Adjustment Quantity
     *      pAdjWgt     Adjustment Weight
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pUser
     C                   parm                    pPgm
     C                   parm                    pWhse
     C                   parm                    pDept
     C                   parm                    pItem
     C                   parm                    pDisp
     C                   parm                    pType
     C                   parm                    pAdjCd
     C                   parm                    pAdjUOM
     C                   parm                    pAdjQty
     C                   parm                    pAdjWgt

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        pMessage = '';
        error = *off;

        exsr getcurrstamp;

        exsr Edit;
        if error = *off;
          exsr Update;
        endif;

        return;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *Inzsr  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         // Convert fields to uppercase

         puser   = %xlate(xlower: xupper: puser);
         ppgm    = %xlate(xlower: xupper: ppgm);
         getclient(client: clientLoc);


         getUser(puser: e$whse: e$emp#: e$fnam: e$init: e$lnam:
                 e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                 e$bpu: e$lng);

      /end-free

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
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

      /free
       begsr getCurrStamp;

         getmicrotime(currstampuc:currstampsys);
         currstamploc = currstampsys + %hours(bfcoffset);

       endsr;
      /end-free
