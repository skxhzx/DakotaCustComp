      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTSESID     Test GETSESID function
     *----------------------------------------------------------------
     D item            s             15
     D sessid          s             40

      /free
        *inlr = *on;

610bA   exec sql select ititem, getsesid()
610bA            into :item, :sessid
610bA            from piritem
610bA            fetch first row only;
610bA
610aA   sqlstt = sqlstt;

        return;
      /end-free
