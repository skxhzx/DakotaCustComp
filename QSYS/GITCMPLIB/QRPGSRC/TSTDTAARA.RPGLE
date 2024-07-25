      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTDTAARA   Test /free data area
     *  26 January 2009
     *  Dave Sommerville
     *----------------------------------------------------------------


     D temp15          s             15
     D pirllp#         s              7  0 dtaara

      /free
         in *lock pirllp#;
         temp15 = '*NT' + %editc(pirllp#:'X');
         pirllp# += 1;
         out pirllp#;
         in  pirllp#;
         *inlr = *on;
      /end-free
