      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M13500U      Purchase Order Receiving Add Detail Entry - Edit
     *  23 June 2016
     *  Lynn McMahon
     *
     *  Revisions:
     *
700 A*    06/23/16  LMC  7.00
     *      - Created.
     *      - Returns Error Message                                   reen
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pPO         Purchase Order
     *      pPOSeq      Sequence
     *      pPOItem     Item
     *
     *    Returned Parameters
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
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.GETBRAND

     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------


     *
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D pMessage        s             99
     D psessid         s             40
     D puser           s             10
     D pDict           s             10
     D ppgm            s             20
     D pWhse           s              3p 0
     D pPo             s              9
     D pPOSeq          s              5p 0
     D pPOItem         s             15

     D client          s             10
     D clientloc       s             10

     D bCmd            s             10
     D bBrand          s             10
     D bParentitm      s             15
     D bBranditm       s             15
     D bBrandFlg       s              1

     D chk4err         s               n
     D zmflag          s               n
     D zmsflag         s               n
     *----------------------------------------------------------------
     *  Working fields.
     *

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------
     *  Called programs
     *
     *----------------------------------------------------------------
     *  Called program parameters
     *

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
      /COPY *libl/qcopysrc,C#ITEM
     D savever#        s                   like($itver#)
     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *
     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D pdrec         E Ds                  Extname(podtl)
     *----------------------------------------------------------------

     c     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pDict
     C                   parm                    pPgm
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pPOSeq
     c                   parm                    pPOItem

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;

        puser = %xlate(xlower: xupper: puser);
        pPOItem = %xlate(xlower: xupper: pPOItem);
        // Check to see if seq# already exist

        exec sql select * into :pdrec
             from podtl
             where pdwhse = :pWhse
               and pdpo   = :pPO
               and pdseq  = :pPOSeq;
        If sqlstt = sqlSuccess;
          pMessage = 'Seq# Already Exist';
          return;
        endif;
        // Make sure item entered is valid and not a branded item

        exsr clr$item;

        $itWhse = pwhse;
        $ititem = pPoItem;

        $dricommand = '*ITEM';
        $drisubcmd  = '%GETALL';
        $drisys2upd = 'D';
        chk4err = *on;
        zmflag  = *off;
        exsr zzzdricop;
        if error = *on;
          pMessage = 'Invalid Item';
          return;
        endif;
        // Make sure Item is not a Branded item # - they can only be
        // Added by the receiving program if product/brand is received
        bCmd = '*GET4BITM';
        bBrand = ' ';
        bParentItm = ' ';
        bBrandItm = pPoItem;
        bBrandFlg = ' ';
        if ppoItem <> ' ';
          GetBranded(bCmd: pwhse: bParentItm: bBrand:
                     bBrandItm: bBrandFlg);
        if bParentItm <> ' ';
          pMessage = 'Invalid Item';
          return;
        endif;
        endif;

      /end-free
     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         getclient(client: clientLoc);

       endsr;

      /end-free

     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr


     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
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

     C                   when      chk4err and %error
     C                   eval      error = *on

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr
