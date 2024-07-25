      /COPY *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *
     *  UPDTRUCKD  Rebuild truck TRUCKD from TRKTMPD
     *  15 April 2018
     *  Dave Sommerville
     *
     *  Revisions
     *
720  *    04/15/18  DAS  7.10a
     *      - Created.
     *
720a *    09/07/18  LMC  7.20a
     *      - Enh: Adding logic to handle up to 9 columns.
     *
     *----------------------------------------------------------------
     *  File Info
     *----------------------------------------------------------------

     Ftruckd    uf a e           k disk
     Ftrktmpd   if   e           k disk
720aAFtruckc    if   e           k disk

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

720aA  // get number of columns being used from TRUCKC
720aA  chain ($pwhse: $ptruk) truckc;
720aA  if not %found(truckc);
720aA    tccols = 2;
720aA  endif;
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
             reade (ttdwhse: ttdtruk) truckd;
             if %eof(truckd);
               leave;
             endif;
             delete tdrec;
           enddo;
         endif;

         WrtTruckD(ttdrow: 1: ttdcomp1: ttdcube1: ttdpick1);
         WrtTruckD(ttdrow: 2: ttdcomp2: ttdcube2: ttdpick2);
720aA    if tccols >= 3;
           WrtTruckD(ttdrow: 3: ttdcomp3: ttdcube3: ttdpick3);
720aA    else;
720aA      ttdcomp3 = ' ';
720aA      ttdcube3 = 0;
720aA      ttdpick3 = 0;
720aA      WrtTruckD(ttdrow: 3: ttdcomp3: ttdcube3: ttdpick3);
720aA    endif;
720aA    if tccols >= 4;
720aA      WrtTruckD(ttdrow: 4: ttdcomp4: ttdcube4: ttdpick4);
720aA    else;
720aA      ttdcomp4 = ' ';
720aA      ttdcube4 = 0;
720aA      ttdpick4 = 0;
720aA      WrtTruckD(ttdrow: 4: ttdcomp4: ttdcube4: ttdpick4);
720aA    endif;
720aA    if tccols >= 5;
720aA      WrtTruckD(ttdrow: 5: ttdcomp5: ttdcube5: ttdpick5);
720aA    else;
720aA      ttdcomp5 = ' ';
720aA      ttdcube5 = 0;
720aA      ttdpick5 = 0;
720aA      WrtTruckD(ttdrow: 5: ttdcomp5: ttdcube5: ttdpick5);
720aA    endif;
720aA    if tccols >= 6;
720aA      WrtTruckD(ttdrow: 6: ttdcomp6: ttdcube6: ttdpick6);
720aA    else;
720aA      ttdcomp6 = ' ';
720aA      ttdcube6 = 0;
720aA      ttdpick6 = 0;
720aA      WrtTruckD(ttdrow: 6: ttdcomp6: ttdcube6: ttdpick6);
720aA    endif;
720aA    if tccols >= 7;
720aA      WrtTruckD(ttdrow: 7: ttdcomp7: ttdcube7: ttdpick7);
720aA    else;
720aA      ttdcomp7 = ' ';
720aA      ttdcube7 = 0;
720aA      ttdpick7 = 0;
720aA      WrtTruckD(ttdrow: 7: ttdcomp7: ttdcube7: ttdpick7);
720aA    endif;
720aA    if tccols >= 8;
720aA      WrtTruckD(ttdrow: 8: ttdcomp8: ttdcube8: ttdpick8);
720aA    else;
720aA      ttdcomp8 = ' ';
720aA      ttdcube8 = 0;
720aA      ttdpick8 = 0;
720aA      WrtTruckD(ttdrow: 8: ttdcomp8: ttdcube8: ttdpick8);
720aA    endif;
720aA    if tccols >= 9;
720aA      WrtTruckD(ttdrow: 9: ttdcomp9: ttdcube9: ttdpick9);
720aA    else;
720aA      ttdcomp9 = ' ';
720aA      ttdcube9 = 0;
720aA      ttdpick9 = 0;
720aA      WrtTruckD(ttdrow: 9: ttdcomp9: ttdcube9: ttdpick9);
720aA    endif;

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

