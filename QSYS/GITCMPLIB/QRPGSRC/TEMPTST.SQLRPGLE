417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TEMPTEST
     *  Dave Sommerville
     *----------------------------------------------------------------

     D error           s               n
     D rFDate          s              8  0
     D sFDate          s              8

      /free
        *inlr = *on;

           sFDate = '120709';
           monitor;
             rFDate = %dec(%char(%date(sFDate:*mdy0):*iso0):8:0);    // mmddyy
           on-error;
             error = *on;
           endmon;

           sFDate = '12/07/09';
           monitor;
             rFDate = %dec(%char(%date(sFDate:*mdy/):*iso0):8:0);   // 'mm/dd/yy
           on-error;
             error = *on;
           endmon;

        return;
      /end-free
