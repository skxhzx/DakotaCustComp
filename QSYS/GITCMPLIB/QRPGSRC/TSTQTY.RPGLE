      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTQTY   Test building qty
     *  26 January 2009
     *  Dave Sommerville
     *----------------------------------------------------------------

     D temp10          s             10
     D qty1            s              5  0
     D qty2            s              5  0
     D qty3            s              5  0

      /free
         qty1 = -5;
         qty2 = 2;
         qty3 = 3;

         temp10 = %trim(%editc(qty1:'P'));

         if qty2 <> 0;
           temp10 = %trim(temp10) + '.'
                  + %trim(%editc(qty2:'P'));
         endif;

         if qty3 <> 0;
           temp10 = %trim(temp10) + '.'
                  + %trim(%editc(qty3:'P'));
         endif;

         *inlr = *on;
      /end-free
