      /COPY *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *
     *  TD500      Rebuild truck TRUCKD from TRKTMPD
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

     Ftruckd    uf a e           k disk
     Ftrktmpd   if   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d lastWhse        s                   like(tdwhse)
     d lasttruk        s                   like(tdtruk)
     d forever         s               n

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d wrtTruckD       pr
     d  row                                like(tdrow)
     d  col                           1  0 const
     d  comp                               like(tdcomp)
     d  cube                               like(tdcube)
     d  pick                               like(tdpick)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PTRUK  Truck code
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $ptruk           10

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
       *inlr = *on;

       setll ($pwhse: $ptruk) trktmpd;

       dow forever = forever;

         reade ($pwhse: $ptruk) trktmpd;
         if %eof(trktmpd);
           leave;
         endif;

         // Delete existing records for truck

         if ttdwhse <> lastWhse or ttdtruk <> lastTruk;
           lastWhse = ttdwhse;
           lastTruk = ttdtruk;
           setll (ttdwhse: ttdtruk) truckd;
           dow forever = forever;
             reade (tdwhse: tdtruk) truckd;
             if %eof(truckd);
               leave;
             endif;
             delete tdrec;
           enddo;
         endif;

         WrtTruckD(ttdrow: 1: ttdcomp1: ttdcube1: ttdpick1);
         WrtTruckD(ttdrow: 2: ttdcomp2: ttdcube2: ttdpick2);
         WrtTruckD(ttdrow: 3: ttdcomp3: ttdcube3: ttdpick3);

       enddo;

       return;
      /end-free

     *----------------------------------------------------------------
     *  WrtTruckD       Write TRUCKD record
     *----------------------------------------------------------------

     p WrtTruckD       b
     d WrtTruckD       pi
     d  row                                like(tdrow)
     d  col                           1  0 const
     d  comp                               like(tdcomp)
     d  cube                               like(tdcube)
     d  pick                               like(tdpick)

      /free

       if comp = '' and cube = 0 and pick = 0;
         return;
       endif;

       tdwhse = $pwhse;
       tdtruk = $ptruk;
       tdrow = row;
       tdcol = col;
       tdcomp = comp;
       tdcube = cube;
       tdpick = pick;

       write tdrec;

      /end-free

     p                 e

