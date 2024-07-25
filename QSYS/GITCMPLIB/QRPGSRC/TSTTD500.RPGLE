      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  UPD720DSA   Initialize TRKTMPD
     *  15 April 2018
     *  Dave Sommerville
     *
     *  Revisions
     *
720  *    04/15/18  DAS  7.10a
     *      - Created.
     *
     *----------------------------------------------------------------
     *  File Info
     *----------------------------------------------------------------

     Ftrktmpd   if   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d lastWhse        s                   like(ttdwhse)
     d lasttruk        s                   like(ttdtruk)

     D updtruckd       pr                  extpgm('UPDTRUCKD')
     D  pWhse                         3p 0
     D  pTruk                        10

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
       *inlr = *on;

       dow 1 = 1;

         read trktmpd;
         if %eof(trktmpd);
           leave;
         endif;

         if ttdwhse <> lastWhse or ttdtruk <> lastTruk;
           lastWhse = ttdwhse;
           lastTruk = ttdtruk;
           updtruckd (ttdwhse: ttdtruk);
         endif;

       enddo;

       return;
      /end-free

