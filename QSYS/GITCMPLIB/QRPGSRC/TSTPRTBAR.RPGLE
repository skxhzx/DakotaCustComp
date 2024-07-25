     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTPRTBAR   Test printing BARCODE
     *  16 September 2014
     *  Dave Sommerville
     *----------------------------------------------------------------

     Fslot1     ip   e           k disk
     Ftstprtbarpo    e             printer

     D count           s              3  0
     D flag            s               n

      /free

        if slstk1 > 0;

          count += 1;

          if count = 1;
            write head1;
            write columns;
          endif;

          // The CODE128 barcode is printing garbage on the bottom right
          // if 1 or more spaces are present.
          // This demonstrates that problem.

          // This theory proved to be wrong. Garbage all the time.

          select;
            when flag;
              val39 = %trim(sldisp) + '............';
              val128 = %trim(sldisp) + '............';
              flag = *off;
            other;
              val39 = sldisp;
              val128 = sldisp;
              flag = *on;
          endsl;

          valpdf = 'Slot ' + %trim(sldisp) + ' '
                 + 'has ' + %char(slstk1) + ' pcs';

         txt39 = val39;
         txt128 = val128;
         txtpdf = valpdf;

          write detail1;
          write detail2;
          write detail3;

          if count = 3;
            write foot1;
            *inlr = *on;
          endif;

        endif;

      /end-free
