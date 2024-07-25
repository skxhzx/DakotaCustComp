      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  UPD720DSA   Initialize TRKTMPD
     *  15 April 2018
     *  Dave Sommerville
     *
     *  Revisions
     *
720  *    04/15/18  DAS  7.20
     *      - Created.
     *
720aA*    08/11/18  DAS  7.20a
     *      - Added TRUCKC file
     *
     *----------------------------------------------------------------
     *  File Info
     *----------------------------------------------------------------

     Ftruckd    if   e           k disk
     Ftrktmpd   uf a e           k disk
     Ftruckc    uf a e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d lastWhse        s                   like(tdwhse)
     d lasttruk        s                   like(tdtruk)

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
       *inlr = *on;

       dow 1=1;

         read truckd;
         if %eof(truckd);
           leave;
         endif;

         // Delete existing records for truck

         if tdwhse <> lastWhse or tdtruk <> lastTruk;
           lastWhse = tdwhse;
           lastTruk = tdtruk;
           setll (tdwhse: tdtruk) trktmpd;
           dow 1 = 1;
             reade (tdwhse: tdtruk) trktmpd;
             if %eof(trktmpd);
               leave;
             endif;
             delete ttdrec;
           enddo;
           chain (tdwhse: tdtruk) truckc;
           if %found(truckc);
             delete tcrec;
           endif;
         endif;

         chain (tdwhse: tdtruk: tdrow) trktmpd;

         if not %found(trktmpd);
           clear ttdrec;
           ttdwhse = tdwhse;
           ttdtruk = tdtruk;
           ttdrow = tdrow;
         endif;

         select;
           when tdcol = 1;
             ttdcomp1 = tdcomp;
             ttdcube1 = tdcube;
             ttdpick1 = tdpick;
           when tdcol = 2;
             ttdcomp2 = tdcomp;
             ttdcube2 = tdcube;
             ttdpick2 = tdpick;
           when tdcol = 3;
             ttdcomp3 = tdcomp;
             ttdcube3 = tdcube;
             ttdpick3 = tdpick;
         endsl;

         if tdcol > tccols;
           tccols = tdcol;
         endif;

         if not %found(trktmpd);
           write ttdrec;
         else;
           update ttdrec;
         endif;

         chain (ttdwhse: ttdtruk) truckc;
         if not %found(truckc);
           tcwhse = ttdwhse;
           tctruk = ttdtruk;
           tccols = tdcol;
           write tcrec;
         else;
           if tdcol > tccols;
             tccols = tdcol;
           endif;
           update tcrec;
         endif;

       enddo;

       return;
      /end-free

