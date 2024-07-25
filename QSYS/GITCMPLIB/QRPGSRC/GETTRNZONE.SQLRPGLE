417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETTRNZONE  Get transaction zone - Pgm for GETTRNZON function
     *  25 May 2012
     *  Dave Sommerville
     *
     *  Revisions:
     *
640 A*    05/25/12  DAS  6.40
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
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse       Warehouse
     *      $pRteId      Route Id
     *      $pTran       Transaction
     *
     *    Returned Parameters
     *      $pZone      -  Zone code
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pWhse            3 0
     C                   parm                    $pRteId           9
     C                   parm                    $pTran            7 0
     C                   parm                    $pZone            6

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        exec sql select lwszon into :$pZone
                 from worklbl
640qA            where lwwhse = :$pWhse
640qA              and lwrte  = :$pRteId
640qM              and lwtrn# = :$pTran
                 fetch first 1 rows only;

        if sqlstt <> sqlSuccess or $pZone = ' ';
          $pZone = ' ';
        endif;

         *inlr = *on;
         return;
      /end-free
