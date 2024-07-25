      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  UPD650DSA   Initialize SHIFTCLR and TRKCOMPCLR files
     *  26 August 2014
     *  Dave Sommerville
     *
     *  Revisions
     *
650a *    03/03/15  DAS  6.50a
     *      - Replaced TRKCOMPCLR with PIRCOLORSH/D
     *      - Replaced SHIFTCLR with PIRCOLORSH/D
     *
     *----------------------------------------------------------------
     *  File Info
     *----------------------------------------------------------------

     Fshift     if   e           k disk
     Ftrkcomp   if   e           k disk
     Fddopts    if   e           k disk
650aDF*hiftclr  uf a e           k disk
650aDF*rkcompclruf a e           k disk
650aAFpircolorshuf a e           k disk
650aAFpircolorsduf a e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d codeLen         s              3  0
     d commaPos        s              3  0
     d comp            s              1
     d i               s              3  0
650aAd lastWhse        s                   like(tpwhse)

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
       *inlr = *on;

       exsr InzSHIFTCLR;
       exsr InzTRKCOMPCLR;

       return;
      /end-free

     *----------------------------------------------------------------
     *  InzSHIFTCLR   Initialize SHIFTCLR file
     *----------------------------------------------------------------

      /free
       begsr InzSHIFTCLR;

650aA    lastWhse = -1;

         dow 1=1;

           read shift;
           if %eof(shift);
             leave;
           endif;

650aA      // Create *DEFAULT Header record when warehouse changes.
650aA
650aA      if shwhse <> lastWhse;
650aA        clrhwhse = shwhse;
650aA        clrhset = '*DEFAULT';
650aA        clrhtype = 'SHIFT';
650aA        write(e) clrhrec;
650aA        lastWhse = shwhse;
650aA      endif;

650aM      clrdwhse = shwhse;
650aA      clrdset = '*DEFAULT';
650aA      clrdtype = 'SHIFT';
650aM      clrdcode = shcode;
650aM      clrdcolor = '';
650aM      write(e) clrdrec;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  InzTRKCOMPCLR    Initialize TRKCOMPCLR file
     *----------------------------------------------------------------

      /free
       begsr InzTRKCOMPCLR;

         chain ('BFC_CUSTOM_COLORS') ddopts;
         if not %found(ddopts);
           dovalue = '';
         endif;

650aA    lastWhse = -1;

         dow 1=1;

           read trkcomp;
           if %eof(trkcomp);
             leave;
           endif;

650aA      // When warehouse changes ...
650aA      //   - Create *DEFAULT Header record.
650aA      //   - Create Detail records for all DDOPTS entries.
650aA
650aA      if tpwhse <> lastWhse;
650aA        clrhwhse = tpwhse;
650aA        clrhset = '*DEFAULT';
650aA        clrhtype = 'COMP';
650aA        write(e) clrhrec;
650aA        exsr wrtDDOPTS;
650aA        lastWhse = tpwhse;
650aA      endif;

650aA      // Write out missing truck compartment codes

650aM      clrdwhse = tpwhse;
650aA      clrdset = '*DEFAULT';
650aA      clrdtype = 'COMP';
650aM      clrdcode = tpcode;

           // Default color to value in DDOPTS file

           select;
             when tpcode = 'D';
650aM          clrdcolor = '#663300';
             when tpcode = 'F';
650aM          clrdcolor = '#000066';
             when tpcode = 'R';
650aM          clrdcolor = '#003300';
             other;
650aM          clrdcolor = '';
           endsl;

650aM      write(e) clrdrec;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  WrtDDOPTS        Write out all DDOPTS colors for warehouse
     *----------------------------------------------------------------

      /free
       begsr WrtDDOPTS;

           clrdwhse = tpwhse;
           clrdset = '*DEFAULT';

           i = 1;
           dou i > 392;
             // Get comma after code
             commaPos = %scan(',': dovalue: i);
             if commaPos = 0;
               leave;
             endif;
             // Get code
             codeLen = commaPos - i;
             clrdcode = %subst(dovalue: i: codeLen);
             // Get color
             clrdcolor = '#' + %subst(dovalue: commaPos+1: 6);
             // Write detail record
             if %subst(clrdcode: 1: 2) = 'AX';
               clrdtype = 'AXLE';
             else;
               clrdtype = 'COMP';
             endif;
             write(e) clrdrec;
             // Position to next code
             i = commaPos + 8;
           enddo;

       endsr;
      /end-free
