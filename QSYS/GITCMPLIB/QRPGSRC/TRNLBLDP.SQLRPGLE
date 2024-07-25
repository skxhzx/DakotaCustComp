417cA /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  TRNLBLDP    Set disabled flag for tran/label
     *  31 May 2012
     *  Dave Sommerville
     *
     *  Revisions:
     *
640 A*    05/31/12  DAS  6.40
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

520aAd*disabled        c                   'disabled="disabled"'
520aAd disabled        c                   '" disabled="disabled'
520aAd true            c                   *on
520aAd false           c                   *off

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

530aAd DisableLabel    pr              n
530aAd DisableTran     pr              n

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pTran       Transaction number
     *      pLabel      Label number
     *
     *    Returned Parameters
     *      pDisable    Set to 'disabled=disabled' if transaction not
     *                  allowed to be closed, or label Pick qty not
     *                  allowed to be changed. Otherwise set to blank.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pWhse            3 0
     C                   parm                    $pTran            7 0
     C                   parm                    $pLabel           7 0
     C                   parm                    $pDisabled       20

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        $pDisabled = ' ';

        select;

          when $pLabel > 0;

            if DisableLabel();
              $pDisabled = disabled;
            endif;

          when $pTran > 0;

            if DisableTran();
              $pDisabled = disabled;
            endif;

        endsl;

         *inlr = *on;
         return;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      Sub Procedures
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  DisableLabel   See if label Pick qty should be disabled
     *----------------------------------------------------------------

     p DisableLabel    b
     d DisableLabel    pi              n

     *  Local Variables

     D type            s              1
     D vrfy            s              1

      /free

        exec sql select lbtype,lbvrfy into :type,:vrfy
                 from label
640qA            where lbwhse = :$pWhse
640qM              and lbtrn# = :$pTran
640qM              and lblbl# = :$pLabel
                 fetch first 1 rows only;

        if sqlstt <> sqlSuccess;
          return false;
        endif;

        // Pick qty cannot be changed for a Merge record

        if type = 'M';
          return true;
        endif;

        // Pick qty cannot be changed if a Runner flag exists

        if vrfy = 'F' or vrfy = 'I';
          return true;
        endif;

        return false;
      /end-free

     p DisableLabel    e

     *----------------------------------------------------------------
     *  DisableTran    See if trans should be disabled from closing
     *----------------------------------------------------------------

     p DisableTran     b
     d DisableTran     pi              n

     *  Local Variables

     D vrfy            s              1

      /free

        // Transaction cannot be closed if a Runner flag exists.

        exec sql select lbvrfy into :vrfy
                 from label
640qA            where lbwhse = :$pWhse
640qM              and lbtrn# = :$pTran
640qM              and lbvrfy in ('F','I')
                 fetch first 1 rows only;

        if sqlstt = sqlSuccess;
          return true;
        endif;

        return false;
      /end-free

     p DisableTran     e
