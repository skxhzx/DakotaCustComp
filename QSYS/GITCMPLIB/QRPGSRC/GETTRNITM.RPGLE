417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETTRNITM   Get transaction item - Pgm for GETTRNITM function
     *  17 August 2014
     *  Dave Sommerville
     *
     *  Revisions:
     *
650 A*    08/17/14  DAS  6.50
     *      - Created.
720aA*    12/04/18  LMC  7.20
     *      - Enh: Do not return item on a selection task. If the
     *        LBPAL# > 0, We assume selection task. return blank item.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Flabel7    if   e           k disk
     Fpiritem   if   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D ttlPcsRem       s              7  0

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D $pCmd           s              4    varying
     D $pWhse          s              3  0
     D $pTran          s              7  0
     D $pOutStr        s             50    varying

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pCmd        ITEM, DESC, BOTH
     *      $pWhse       Warehouse
     *      $pTran       Transaction
     *
     *    Returned Parameters
     *      $pOutStr     Return string
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pCmd
     C                   parm                    $pWhse
     C                   parm                    $pTran
     C                   parm                    $pOutStr

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;
        $pOutStr = '';

        // If transaciton is zero, get out

        if $pTran = 0;
          return;
        endif;

        // Get first label for transaction

        setll ($pTran) label7;
        reade ($pTran) label7;
        if %eof(label7);
          return;
        endif;

720aA   // If LBPAL# > 0 - Selection, get out

720aA   if lbpal# > 0;
720aA     return;
720aA   endif;

        // If we only want the item, get out

        if $pCmd = 'ITEM';
          $pOutStr = lbitem;
          return;
        endif;

        // Get item description

        chain (lbwhse: lbitem) piritem;
        if not %found(piritem);
          ititem = lbitem;
          itdesc = '';
        endif;

        if $pCmd = 'DESC';
          if itdesc = '';
            $pOutStr = lbitem;
          else;
            $pOutStr = %trimr(itdesc);
          endif;
        else;
          if itdesc = '';
            $pOutStr = lbitem;
          else;
            $pOutStr = %trimr(ititem) + ' - ' + %trimr(itdesc);
          endif;
        endif;

        return;
      /end-free
