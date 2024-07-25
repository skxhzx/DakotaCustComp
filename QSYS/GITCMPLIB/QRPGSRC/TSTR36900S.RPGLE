      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTR36900S   Test R36900SR
     *  05 August 2020
     *  Dave Sommerville
     *----------------------------------------------------------------

     d whse            s              3  0
     d rtn             s             10
     d msg             s            100

     D/copy qcopysrc,p.R36900SR

     C     *entry        plist
     C                   parm                    $pwhse           15 5
     C                   parm                    rtid              5

      /free

       *inlr = *on;

       if %parms <> 2;
         dsply 'CALL R36900SR (whs rtid)';
         return;
       endif;

       whse = $pwhse;

       r36900sr (whse: rtid: rtn: msg);

      /end-free

