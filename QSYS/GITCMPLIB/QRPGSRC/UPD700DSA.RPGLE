      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  UPD700DSA   Initialize PIRCOLORSH/D files (replaces UPD650DSA)
     *  17 June 2015
     *  Dave Sommerville
     *
     *  Revisions
     *
700  *    06/17/15  DAS  7.00a
     *      - Created.
     *
750  *    10/01/21  KDE  7.50
     *      - Add entries for Mixed Pallet Color
     *
     *----------------------------------------------------------------
     *  File Info
     *----------------------------------------------------------------

     Fwarehs    if   e           k disk
     Fshift     if   e           k disk
     Ftrkcomp   if   e           k disk
     Fddopts    if   e           k disk
     Fpircolorshuf a e           k disk
     Fpircolorsduf a e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d first           s               n
     d code            s                   like(clrdcode)
     d codeLen         s              3  0
     d commaPos        s              3  0
     d comp            s              1
     d i               s              3  0
     d lastWhse        s                   like(tpwhse)

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

         exsr InzSHIFTCLR;
         exsr InzTRKCOMPCLR;

       enddo;

       return;
      /end-free

     *----------------------------------------------------------------
     *  InzSHIFTCLR   Initialize SHIFTCLR file
     *----------------------------------------------------------------

      /free
       begsr InzSHIFTCLR;

         first = *on;
         setll (whcode) shift;

         dow 1=1;

           reade (whcode) shift;
           if %eof(shift);
             leave;
           endif;

           // Create *DEFAULT Header record when warehouse changes.

           if first;
             first = *off;
             clrhwhse = shwhse;
             clrhset = '*DEFAULT';
             clrhtype = 'SHIFT';
             clrhdesc = 'Default Shift colors';
             write(e) clrhrec;

750 A        clrhwhse = shwhse;
750 A        clrhset = '*DEFAULT';
750 A        clrhtype = 'MIX ';
750 A        clrhdesc = 'Mixed Pallet Color';
750 A        write(e) clrhrec;
           endif;

           clrdwhse = shwhse;
           clrdset = '*DEFAULT';
           clrdtype = 'SHIFT';
           clrdcode = shcode;
           clrdcolor = '';
           write(e) clrdrec;

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

         first = *on;
         setll (whcode) trkcomp;

         dow 1=1;

           reade (whcode) trkcomp;
           if %eof(trkcomp);
             leave;
           endif;

           // When warehouse changes ...
           //   - Create *DEFAULT Header record.

           if first;
             first = *off;
             clrhwhse = tpwhse;
             clrhset = '*DEFAULT';
             clrhdesc = 'Default TruckBuilder colors';
             clrhtype = 'COMP';
             write(e) clrhrec;
           endif;

           // Write out missing truck compartment codes

           clrdwhse = tpwhse;
           clrdset = '*DEFAULT';
           clrdtype = 'COMP';
           clrdcode = tpcode;

           // Use color from DDOPTS, if one exists

           exsr GetDDOPTSColor;

           // Use default color for some compartments if not found in DDOPTS.

           if clrdcolor = '';
             select;
               when tpcode = 'D';
                 clrdcolor = '#663300';
               when tpcode = 'F';
                 clrdcolor = '#000066';
               when tpcode = 'R';
                 clrdcolor = '#003300';
             endsl;
           endif;

           write(e) clrdrec;

         enddo;

         // Write out missing AXLE records

           clrdwhse = whcode;
           clrdset = '*DEFAULT';

           clrdtype = 'AXLE';
           clrdcode = 'AX_OK';
           clrdcolor = '#B4DAC7';
           write(e) clrdrec;

           clrdtype = 'AXLE';
           clrdcode = 'AX_WARN';
           clrdcolor = '#F2C319';
           write(e) clrdrec;

           clrdtype = 'AXLE';
           clrdcode = 'AX_OVER';
           clrdcolor = '#EE0000';
           write(e) clrdrec;

         // Write out missing CUBE records

           clrdtype = 'CUBE';
           clrdcode = 'CUBE_MIN';
           clrdcolor = '#008080';
           write(e) clrdrec;

           clrdtype = 'CUBE';
           clrdcode = 'CUBE_MAX';
           clrdcolor = '#800000';
           write(e) clrdrec;

750 A      clrdtype = 'MIX ';
750 A      clrdcode = 'MIXED';
750 A      clrdcolor = '#800000';
750 A      write(e) clrdrec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetDDOPTSColor   Get compartment color from DDOPTS file
     *----------------------------------------------------------------

      /free
       begsr GetDDOPTSColor;

           clrdcolor = '';

           i = 1;
           dou i > 392;
             // Get comma after code
             commaPos = %scan(',': dovalue: i);
             if commaPos = 0;
               leave;
             endif;
             // Get code
             codeLen = commaPos - i;
             code = %subst(dovalue: i: codeLen);
             if code = clrdcode;
               // Get color
               clrdcolor = '#' + %subst(dovalue: commaPos+1: 6);
               leave;
             endif;
             // Position to next code
             i = commaPos + 8;
           enddo;

       endsr;
      /end-free
