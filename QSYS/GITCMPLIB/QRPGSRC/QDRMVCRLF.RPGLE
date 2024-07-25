      /copy qcopysrc,hspecs
     *---------------------------------------------------------------*
     *   QDRMVCRLF   Remove CRLF from item desctiptions
     *   16 November 2012
     *   Dave Sommerville
     *---------------------------------------------------------------*
     *---------------------------------------------------------------*
     *   Revisions:
650  *   01/10/13  MLB  6.50
     *     - Fix: Added file, ORDDS to crlf cleanup.
     *     - Fix: Added files WORKLBL, LABEL to crlf cleanup.
     *     - Fix: Added file, RUNNER to crlf cleanup.
650a *   01/10/13  MLB  6.50a
     *     - Fix: Added file, SLOT to crlf cleanup.
     *---------------------------------------------------------------*

     Fpiritem   uf   e           k disk
650 AFordds     uf   e           k disk
650 AFlabel     uf   e           k disk
650 AFworklbl   uf   e           k disk
650 AFrunner    uf   e           k disk
650aAFslot      uf   e             disk

     D crlf            c                   const(x'0D25')
     D spaces          c                   const('  ')
     D forever         s               n   inz(*on)
     D newDesc         s                   like(itdesc)
     D newPDsc         s                   like(itpdsc)
650 AD newDisp         s                   like(osdisp)

      /free
         *inlr = *on;

         dow forever = forever;
           read piritem;
           if %eof(piritem);
             leave;
           endif;
           newDesc = %xlate(crlf: spaces: itdesc);
           newPDsc = %xlate(crlf: spaces: itpdsc);
           if newDesc <> itdesc or newPDsc <> itpdsc;
             itdesc = newDesc;
             itpdsc = newPDsc;
             update itrec;
           endif;
         enddo;

         dow forever = forever;
           read ordds;
           if %eof(ordds);
             leave;
           endif;
           newDisp = %xlate(crlf: spaces: osdisp);
           if newDisp <> osdisp;
             osdisp = newDisp;
             update osrec;
           endif;
         enddo;

         dow forever = forever;
           read worklbl;
           if %eof(worklbl);
             leave;
           endif;
           newdisp = %xlate(crlf: spaces: lwdisp);
           if newDisp <> lwdisp;
             lwdisp = newDisp;
             update lwrec;
           endif;
         enddo;

         dow forever = forever;
           read label;
           if %eof(label);
             leave;
           endif;
           newdisp = %xlate(crlf: spaces: lbdisp);
           if newDisp <> lbdisp;
             lbdisp = newDisp;
             update lbrec;
           endif;
         enddo;

         dow forever = forever;
           read runner;
           if %eof(runner);
             leave;
           endif;
           newdisp = %xlate(crlf: spaces: rudisp);
           if newDisp <> rudisp;
             rudisp = newDisp;
             update rurec;
           endif;
         enddo;

         dow forever = forever;
           read slot;
           if %eof(slot);
             leave;
           endif;
           newdisp = %xlate(crlf: spaces: sldisp);
           if newDisp <> sldisp;
             sldisp = newDisp;
             update slrec;
           endif;
         enddo;

      /end-free
