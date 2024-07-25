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
     *  M24900U    Slot Maintenance - Change item edit/update
     *  13 September 2017
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
710 A*    09/13/17  LMC  7.10
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

700aAFitemchg   if a e           k disk

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
     D  pFsldept       s              5
     D  pFslitem       s             15
     D  pdisp          s             12
     D  pCWT           s              9  2
     D  pMemo          s             30
     D  pdspcw         s              1
     d  pTItem         s             15
     D  paction        s              1

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
     *      pFslDept    From Slot Department
     *      pdisp       Slot
     *      pFslItem    From Slot Item
     *      pTitem      To Item
     *      pCWT        Catch Weight
     *      pMemo       Memo
     *      pdspcw      Display CW flag
     *      pAction     Action - Edit/Update
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
     C                   parm                    pFslDept
     C                   parm                    pDisp
     C                   parm                    pFslItem
     C                   parm                    pTitem
     C                   parm                    pCWT
     C                   parm                    pMemo
     C                   parm                    pdspcw
     C                   parm                    pAction
     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        pMessage = '';
        error = *off;

        exsr getcurrstamp;

        exsr Edit;
        if error = *off
         and pAction = 'U';
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
         ptitem  = %xlate(xlower: xupper: ptitem);
         getclient(client: clientLoc);


         getUser(puser: e$whse: e$emp#: e$fnam: e$init: e$lnam:
                 e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                 e$bpu: e$lng);

      /end-free

      /free
       endsr;
      /end-free


     *----------------------------------------------------------------
     *  Edit              Edit Change item
     *----------------------------------------------------------------

      /free
       begsr Edit;

        // These edits came from SL252/ZZCHK1

        // New item can't be blank.
        if pTitem = ' ';
          pMessage = 'New Item must be entered';
          error = *on;
          leavesr;
        endif;

        // New item can't be same as old item
        if pTitem = pfslitem;
          pMessage = 'Items cannot be the same';
          error = *on;
          leavesr;
        endif;

        // Validate Item
        savever# = $itver#;
        clear $item;
        clear $item2;

        $itWhse = pwhse;
        $ititem = pTItem;

        $dricommand = '*ITEM';
        $drisubcmd  = '%VERIFY';
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

        // Verify Change
        savever# = $slver#;
        clear $slot;
        clear $slot2;

        $slwhseu = *on;
        $slwhse  = pwhse;
        $slwhdpu = *on;
        $slwhdp = pFslDept;
        $sldispu = *on;
        $sldisp = pDisp;
        $saitemu = *on;
        $saitem  = pTItem;

        $dricommand = '*SLOT';
        $drisubcmd  = '%VFYCHGITM';
        $drisys2upd = 'D';
        $driprogram = #pgm;
        $dridata = $slot;
        $dridata2 = $slot2;

        // Call DRI program.

        driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
               $drireturn: $drimessage: $dridata: $dridata2);

        if $drireturn <> '*OK';
          pMessage = $drimessage;
          error = *on;
          leavesr;
        endif;

        // do I need to display catch weight entry field
        // don't display the catch weight entry messasge when action=U
        if pAction <> 'U';
          if pdspcw = ' ';
            // is new item a Cw item
            if $itcwgt = 'Y';
              pdspcw = 'Y';
              pMessage = 'Enter CW if Needed';
              error = *on;
              leavesr;
            endif;

            // is old item a CW item
            // Validate Item
            savever# = $itver#;
            clear $item;
            clear $item2;

            $itWhse = pwhse;
            $ititem = pfslItem;

            $dricommand = '*ITEM';
            $drisubcmd  = '%GETMAIN';
            $drisys2upd = 'D';
            $driprogram = #pgm;
            $dridata = $item;
            $dridata2 = $item2;

            // Call DRI program.

            driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
                   $drireturn: $drimessage: $dridata: $dridata2);

            $item = $dridata;
            $item2 = $dridata2;

            if $itcwgt = 'Y';
              pdspcw = 'Y';
              pMessage = 'Enter CW if Needed';
              error = *on;
              leavesr;
            endif;
          endif;
        endif;


       endsr;
      /end-free

     *----------------------------------------------------------------
     *  Update            Update Adjusment Data
     *----------------------------------------------------------------

      /free
       begsr Update;

        error = *off;

        savever# = $slver#;
        clear $slot;
        clear $slot2;
        $saemp#U = *on;
        $saemp# = e$emp#;

        $slwhseu = *on;
        $slwhse  = pwhse;
        $slwhdpu = *on;
        $slwhdp = pFslDept;
        $sldispu = *on;
        $sldisp = pdisp;
        $saitemu = *on;
        $saitem  = ptitem;
        $sacwtau = *on;
        $sacwta  = pcwt;

        $sabyu   = *on;
        $saby    = pUser;

        $saActionU = *on;
        $saAction = 'CHG';
        $saETrn#U = *on;
        $saETrn# = 0;
        $saToLcnsU = *on;
        $saToLcns = '*MULTIPLE';
        $saToVrfyU = *on;
        $saToVrfy = 'N';
        $saOLcnsU = *on;
        $saOLcns = '*MULTIPLE';
        $saFrmLcnsU = *on;
        $saFrmLcns = '*MULTIPLE';
        $saItmChgU = *on;
        $saItmChg = 'Y';
        $samemo = pmemo;
        $samemoe = '0';
        $samemou = '1';

        $dricommand = '*SLOT';
        $drisubcmd  = '%CHGITEM';
        $drisys2upd = 'D';
        $driprogram = #pgm;
        $dridata = $slot;
        $dridata2 = $slot2;

        // Call DRI program.

        driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
               $drireturn: $drimessage: $dridata: $dridata2);

        // write change item record
        icwhse = pwhse;
        icfitm = pFslItem;
        ictitm = pTitem;
        chain (icwhse: icfitm: ictitm) itemchg;
        if %found(itemchg);
        else;
          write icrec;
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
