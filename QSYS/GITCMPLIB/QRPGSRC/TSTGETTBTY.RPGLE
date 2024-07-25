      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  TSTGETTBTY   Test GETTBTYPE
     *  21 February 2021
     *  Dave Sommerville
     *
     *----------------------------------------------------------------

     d tbtype          s              1
     d whse            s              3  0
     d msg             s             32

      /copy qcopysrc,p.gettbtyp

     C     *entry        plist
     C                   parm                    $pwhse           15 5
     C                   parm                    $prtid            5

      /free
         whse = $pwhse;
         GetTBType(whse: $prtid: tbType);
         msg = 'tbType=' + tbtype;
         dsply msg;
         *inlr = *on;

      /end-free

