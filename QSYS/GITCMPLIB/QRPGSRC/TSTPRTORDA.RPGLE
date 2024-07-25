      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTPRTORDA   Test PRTORDAUD
     *  19 January 2019
     *  Dave Sommerville
     *----------------------------------------------------------------

     d whse            s              3  0
     d jobq            s              1
     d ordId           s              7  0
     d tranList        s            100
     d rtn             s             10
     d msg             s            100

     D/copy qcopysrc,p.prtordau

     C     *entry        plist
     C                   parm                    $pwhse           15 5
     C                   parm                    $pordid          15 5

      /free

       if %parms = 2;
         whse = $pwhse;
         ordId = $pordid;
       else;
         whse = 900;
         ordId = 1;
       endif;

       jobq = 'N';
       rtn = '*TEST';
       prtordaud ('*PRTORDER': jobq: whse: '': ordId: rtn: msg);

       if %parms = 0;
         rtn = '*TEST';
         tranList = '1234,2001';
         prtordaud ('*PRTTRAN': jobq: whse: tranList: 0: rtn: msg);
       endif;

       *inlr = *on;

      /end-free

