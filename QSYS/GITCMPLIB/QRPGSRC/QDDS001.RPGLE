640aA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *  QDDS001   Determine special char used in item descriptions
     *  06 August 2018
     *  Dave Sommerville
     *----------------------------------------------------------------
     * File Specs
     *
     Fpiritem   ip   e           k disk

640fA*----------------------------------------------------------------
640fA*  Constants
640fA*----------------------------------------------------------------

650aAD okchar          c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ+
650aAD                                      abcdefghijklmnopqrstuvwxyz+
650aAD                                      0123456789'

     D chkpos          s              3  0
     D chkpos2         s              3  0
     D spclChar        s              1
     D spclStr         s            500    varying inz('A')

      /free
        chkpos = 0;
        dou chkpos = 0 or chkpos + 1 > 30;
          chkpos = %check(okchar:itdesc:chkpos+1);
          if chkpos > 0;
            spclChar = %subst(itdesc:chkpos:1);
            chkpos2 = %scan(spclChar:spclStr:1);
            if chkpos2 = 0;
              spclStr += spclChar;
              ititem = ititem;
            endif;
          endif;
        enddo;
      /end-free
     CLR                 eval      spclStr = spclStr
