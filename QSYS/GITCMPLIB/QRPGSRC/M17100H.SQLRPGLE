      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
      *----------------------------------------------------------
      *   Copyright (C) 2015 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  M17100H     PO Receiving - Delete transaction Header
      *  17 March 2015
      *  Lynn McMahon
      *
      *  Revisions:
      *
650 A *    03/17/15  LMC  6.50
      *      - Created.
     *      - Returns value field for displaying on list.
700a  *    06/06/16  LMC  7.00a
      *      - Enh - Added to check for Branded Items, send flag back
700b  *    12/07/16  LMC  7.00b
      *      - Enh - Don't allow delete if slot/label items don't match
      *        This can occur when the department on the item is
      *        changed prior to the putaway.
710a  *    10/20/17  LMC  7.10a
      *      - Enh - 700b, doesn't work for alias items, it ends up
      *        showing dpt chg, when it is not. Change this to compare
      *        the lbwhdp to the itwhdp.
      *----------------------------------------------------------

      *----------------------------------------------------------
      * File Specs
      *----------------------------------------------------------


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getpales
      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.chklist
      /copy qcopysrc,p.cvtcase
700aA /copy qcopysrc,p.GETBRAND
     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     D cvt2Upper       pr           500
     D  zIn                         500    const

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pWhse          s              3p 0
     D  pLabel         s              7p 0
     D  pUser          s             10
     D  pOutStr        s            512    varying

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

650eA*----------------------------------------------------------------
650eA*  Customer id
650eA*----------------------------------------------------------------

650eA /copy qcopysrc,id#coastal
650eA /COPY QCOPYSRC,ID#SAVAL
650eA /COPY QCOPYSRC,ID#GFS
650eA /COPY QCOPYSRC,ID#EGF
650eA /COPY QCOPYSRC,ID#CITYLIN
650eA /COPY QCOPYSRC,ID#PACKERS
650eA /COPY QCOPYSRC,ID#JORDANO
650eA /COPY QCOPYSRC,ID#GLAZIER

     *----------------------------------------------------------
     *  Variables
     *----------------------------------------------------------

     D AllowDelete     s              1
700bAD DeleteMsg       s             15
     D chklistrtn      s             10
     D count           s              5p 0
700bAD chk4err         s               n
700bAD zmflag          s               n
700bAD zmsflag         s               n


     D client          s             10
     D clientloc       s             10

700aAD pBrand          s              1
700aAD bCmd            s             10
700aAD bBrand          s             10
700aAD bParentitm      s             15
700aAD bBranditm       s             15
700aAD bBrandFlg       s              1
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

700bA*----------------------------------------------------------------
700bA*  DRI parameters
700bA*----------------------------------------------------------------
700bA /COPY *libl/qcopysrc,C#DRIPARMS

700bA*----------------------------------------------------------------
700bA*  Data Formats
700bA*----------------------------------------------------------------
700bA /COPY *libl/qcopysrc,C#SLOT
710aA /COPY *libl/qcopysrc,C#ITEM
700bAD savever#        s                   like($slver#)
     *----------------------------------------------------------------
     *  files
     *----------------------------------------------------------------

     D phrec         E Ds                  Extname(pohdr)
     D lbrec         E Ds                  Extname(label)
     D ptrec         E Ds                  Extname(pirtran)


     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse        Warehouse
     *      pLabel       Label#
     *      pUser        User
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pLabel
     c                   parm                    pUser
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        pUser  = cvt2Upper(pUser);
        allowdelete = 'Y';
700bA   deletemsg = ' ';
        pOutStr = ' ';
        // check to see if deleting the transaction is allowed
        exec sql select * into :lbrec
             from label
             where lbwhse = :pWhse
               and lblbl# = :pLabel;

        If sqlstt <> sqlSuccess;
          return;
        endif;

        // if po is marked for export - cannot delete
        exec sql select * into :phrec
             from pohdr
             where phwhse = :lbwhse
               and phpo   = :lbpo;

        If sqlstt =  sqlSuccess;
          if phstat = '3';
            allowdelete = 'N';
          endif;
        endif;

        // is department live
        $crtn = '*LIVE   ';
      /end-free
     C                   call      'CHKLIVE'
     C                   parm      lbwhse        $cwhse            3 0
     C                   parm      lbwhdp        $cwhdp            5
     C                   parm      *blanks       $crtn             8
      /free
        // if dept is *notlive and lbqpck = 0 or lbstat = 'C' and *live
        if $crtn = '*LIVE   ' and lbstat = 'C'
           or $crtn = '*NOTLIVE' and lbqpck= 0;
          allowdelete = 'N';
        endif;
        // if transaction is started and *LIVE department
        exec sql select * into :ptrec
             from pirtran
             where ptwhse = :lbwhse
               and pttrn# = :lbtrn#;

        If sqlstt =  sqlSuccess;
          if ptstat <> '1';
            allowdelete = 'N';
          endif;
        endif;

700bA   // need a check if item dept does not match slot dept
700bA   // this was causing po144 to error on putmsg
710aA   exsr clr$item;
710aA   $itwhse = lbwhse;
710aA   $ititem = lbitem;

710aA   $dricommand = '*ITEM';
710aA   $drisubcmd  = '%GETMAIN';
710aA   $drisys2upd = 'D';
710aA   chk4err = *on;
710aA   zmflag  = *off;
710aA   exsr zzzdricop;

        // REMOVE THIS CODE IT DOESN'T WORK FOR ALIAS
710aD   //exsr clr$slot;
710aD   //$slWhse = lbwhse;
710aD   //$slwhdp = lbwhdp;
710aD   //$sldisp = lbdisp;

710aD   //$dricommand = '*SLOT';
710aD   //$drisubcmd  = '%GET';
710aD   //$drisys2upd = 'D';
710aD   //chk4err = *on;
710aD   //zmflag  = *off;
710aD   //exsr zzzdricop;
710aA   if lbwhdp <> $itwhdp and ptstat = '1';
710aD   //if lbitem <> $slitem and ptstat = '1';
700bA     allowdelete = 'N';
700bA     deletemsg = 'Dpt Chg';
700bA   endif;

700aA    // See if the item in label is a parent Item for Branding
700aA    bCmd = '*GETFLAG';
700aA    bBrand = ' ';
700aA    bParentitm = lbitem;
700aA    bBrandItm = ' ';
700aA    bBrandFlg = ' ';
700aA    GetBranded(bCmd: pwhse: bParentitm: bBrand:
700aA               bBrandItm: bBrandFlg);

700aA    pBrand = bBrandFlg;
700aA    if bBrandflg = ' ';
700aA      // See if the item in label is a Branded Item
700aA      bCmd = '*GET4BITM';
700aA      bBrand = ' ';
700aA      bParentitm = ' ';
700aA      bBrandItm = lbitem;
700aA      bBrandFlg = ' ';
700aA      GetBranded(bCmd: pwhse: bParentitm: bBrand:
700aA                 bBrandItm: bBrandFlg);

700aA      pBrand = bBrandFlg;

700aA    endif;
        // Put together JSON string

         pOutStr = '{'
700aA           +  '"Brand":"'  + %trimr(pBrand) + '",'
700bA           +  '"DLTMSG":"'  + %trimr(DeleteMsg) + '",'
                +  '"ALWDLT":"'  + %trimr(allowdelete) + '"';

         // Close off the JSON string
         pOutStr += '}';

          *inlr = *on;

      /end-free

700bA*----------------------------------------------------------------
700bA*  clr$slot  Clear $slot data structure fields
700bA*----------------------------------------------------------------
700bA
700bAC     clr$slot      begsr
700bAC                   eval      savever# = $slver#
700bAC                   clear                   $slot
700bAC                   clear                   $slot2
700bAC                   eval      $slver# = savever#
700bAC                   endsr


710aA*----------------------------------------------------------------
710aA*  clr$item  Clear $item data structure fields
710aA*----------------------------------------------------------------

710aAC     clr$item      begsr
710aAC                   eval      savever# = $itver#
710aAC                   clear                   $item
710aAC                   clear                   $item2
710aAC                   eval      $itver# = savever#
710aAC                   endsr

700bA*----------------------------------------------------------------
700bA*  zzzdricop  Call DRICOP
700bA*----------------------------------------------------------------

700bAC     zzzdricop     begsr
700bAC                   eval      error = *off
700bA
700bAC                   select
700bAC                   when      $dricommand = '*SLOT'
700bAC                   eval      $dridata = $slot
700bAC                   eval      $dridata2 = $slot2
710aAC                   when      $dricommand = '*ITEM'
710aAC                   eval      $dridata = $item
710aAC                   eval      $dridata2 = $item2
700bAC                   endsl

700bAC                   if        $dricommand = '*SLOT'
710aAC                             or $dricommand = '*ITEM'
700bAC                   call(e)   'DRICOP'
700bAC                   parm                    $dricommand
700bAC                   parm                    $drisubcmd
700bAC                   parm                    $drisys2upd
700bAC                   parm      #pgm          $driprogram
700bAC                   parm      ' '           $drireturn
700bAC                   parm      ' '           $drimessage
700bAC                   parm                    $dridata
700bAC                   parm                    $dridata2
700bAC                   else
700bAC                   call(e)   'DRICOP'
700bAC                   parm                    $dricommand
700bAC                   parm                    $drisubcmd
700bAC                   parm                    $drisys2upd
700bAC                   parm      #pgm          $driprogram
700bAC                   parm      ' '           $drireturn
700bAC                   parm      ' '           $drimessage
700bAC                   parm                    $dridata
700bAC                   endif

700bAC                   select

700bAC                   when      chk4err and %error
700bAC                   eval      error = *on
700bA
700bAC                   when      chk4err and $drireturn <> '*OK'
700bAC                   eval      error = *on

700bAC                   endsl

700bAC                   select
700bAC                   when      $dricommand = '*SLOT'
700bAC                   eval      $slot = $dridata
700bAC                   eval      $slot2 = $dridata2
710aAC                   when      $dricommand = '*ITEM'
710aAC                   eval      $item = $dridata
710aAC                   eval      $item2 = $dridata2
700bAC                   endsl

700bAC                   eval      zmflag = *off
700bAC                   eval      zmsflag = *off
700bAC                   eval      chk4err = *off
700bAC     enddricop     endsr
      *----------------------------------------------------------
      *  *INZSR   Initialization subroutine
      *----------------------------------------------------------

      /free
        begsr *INZSR;

650eA     getclient(client: clientLoc);
        endsr;

      /end-free

     *----------------------------------------------------------------
     *  cvt2Upper  Convert to upper case
     *----------------------------------------------------------------

     p cvt2Upper       b
     d cvt2Upper       pi           500
     d  sIn                         500    const

     * Local variables

     d  sOut           s            500

      /free

         cvtCase('*LOW2UPR': sIn: sOut);
         return sOut;

      /end-free
     p cvt2Upper       e

