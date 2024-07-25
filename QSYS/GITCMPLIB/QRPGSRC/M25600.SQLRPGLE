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
     *  M25600     Add/Delete ItemSub from Gui
     *  09 November  2017
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
710 A*    11/09/17  LMC  7.10
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
     D saveVer#        s                   like($itver#)
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
     D  pItem          s             15
     D  pCust          s             11  0
     D  psubitem       s             15
     D  paction        s              1

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

700aAD isurec        e ds                  extname(itemsub)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pMessage    Message
     *      pUser       User
     *      pPgm        Program
     *      pWhse       Warehouse
     *      pItem       Item
     *      pCust       Customer
     *      pSubItem    Sub Item
     *      pAction     Action - Add/Delete
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
     C                   parm                    pItem
     C                   parm                    pCust
     C                   parm                    pSubItem
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
         pitem  = %xlate(xlower: xupper: pitem);
         psubitem  = %xlate(xlower: xupper: psubitem);
         getclient(client: clientLoc);


         getUser(puser: e$whse: e$emp#: e$fnam: e$init: e$lnam:
                 e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                 e$bpu: e$lng);

      /end-free

      /free
       endsr;
      /end-free


     *----------------------------------------------------------------
     *  Edit              Edit validation
     *----------------------------------------------------------------

      /free
       begsr Edit;

        // make sure the sub item is valid

        select;
          when psubitem = ' ';
          when psubitem = '*NOSUB';
          other;
            $itwhse   = pwhse;
            $ititem   = psubitem;

            $dricommand = '*ITEM';
            $drisubcmd  = '%GETMAIN';
            $drisys2upd = 'D';
            $driprogram = #pgm;
            $dridata = $item;
            $dridata2 = $item2;

            // Call DRI program.

            driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
                   $drireturn: $drimessage: $dridata: $dridata2);

            if $drireturn <> '*OK' and paction = 'A';
              pMessage = $drimessage;
              error = *on;
              leavesr;
            endif;
        endsl;
        // check if entry already exist in itemsub
        if paction = 'A';
          exec sql select * into :isurec
               from itemsub
               where isuwhse = :pwhse
                 and isuitem = :pitem
                 and isucust = :pcust
                 and isuisub = :psubitem;
          If sqlstt = sqlSuccess;
            pMessage = 'Item Substitute already exist';
            error = *on;
            leavesr;
          else;
          endif;
        endif;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  Update            Add/Delete Itemsub record
     *----------------------------------------------------------------

      /free
       begsr Update;

        error = *off;

        select;
          when paction = 'A';
            isuts   = CurrStampsys;
            exec sql insert into itemsub
                 values(:pwhse,
                        :pitem,
                        :pcust,
                        :psubitem,
                        :isuts);
          when paction = 'D';
            exec sql delete
                 from itemsub
                 where isuwhse = :pwhse
                   and isuitem = :pitem
                   and isucust = :pcust
                   and isuisub = :psubitem;
            If sqlstt = sqlSuccess;
            else;
            endif;
          other;
        endsl;

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
