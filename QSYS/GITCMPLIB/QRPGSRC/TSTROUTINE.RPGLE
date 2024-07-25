      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTROUTINE  Test *ROUTINE
     *  18 July 2008
     *  Dave Sommerville
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D                sds
     D  #pgm                   1     10
600aAD  #prog                  1     10
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #routine              29     36
     D  #routine2        *ROUTINE
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobnbr              264    269
600aAD  #jobn                264    269
     D  #jobdate             276    281  0
     D  #jobtime             282    287  0
600aAD  #curruser            358    367

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

         exsr shortsub;
         exsr longsubroutine;
         *inlr = *on;
         return;

       begsr longsubroutine;
         *inlr = *on;
       endsr;

       begsr shortsub;
         *inlr = *on;
       endsr;

      /end-free
