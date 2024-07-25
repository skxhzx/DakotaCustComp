      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  QDFBY004B  Put items in pick slots - 26 fix slot
     *  01 December 2016
     *  Rod Roller
     *
     *  12/01/16  RTR  7.00
     *    - Created.
     *
     *----------------------------------------------------------------
     *  File Specs
     fqdfbyxref3uf   e           k disk    extmbr('TEST26')

     *----------------------------------------------------------------
     *  Standard Variables
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Table and array definitions
     d lower           c                   'abcdefghijklmnopqrstuvwxyz'
     d upper           c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

     *----------------------------------------------------------------
     *  Variables
     d holdDisp1       s             12a

     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *  Main line
      /free

        dou forever <> forever;
          read qdfbyxref3;

          if %eof(qdfbyxref3);
            leave;
          endif;

          if x3disp1 <> *blanks
           and x3disp1 <> holdDisp1;
            holdDisp1 = x3disp1;
          endif;

          x3disp1 = %subst(holdDisp1:1:2) + '-'
                  + %subst(holdDisp1:3:3) + '-'
                  + %subst(holdDisp1:6:1)
                  + x3disp2;
          update x3rec;

        enddo;

        *inlr = *on;
      /end-free
