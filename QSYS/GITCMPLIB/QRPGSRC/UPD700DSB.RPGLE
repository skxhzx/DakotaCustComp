      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  UPD700DSB   Add QPRINT/NOPRINTER to DEVGRPH
     *  08 September 2015
     *  Dave Sommerville
     *
     *  Revisions
     *
700  *    09/08/15  DAS  7.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Info
     *----------------------------------------------------------------

     Fwarehs    if   e           k disk
     Fdevgrph   if a e           k disk

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
       *inlr = *on;

       dow 1=1;

         read warehs;
         if %eof(warehs);
           leave;
         endif;

         dvhwhs = whcode;
         dvhgrp = 'QPRINT';
         dvhdsc = 'QPRINT Device';
         write(e) dvrec;

         dvhgrp = 'NOPRINTER';
         dvhdsc = 'No Printer Device';
         write(e) dvrec;

       enddo;

       return;
      /end-free
