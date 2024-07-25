      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  GETZONTMP2   Get zone template using route id
     *  23 June 2015
     *  Dave Sommerville
     *
     *  Revisions
     *
700 A*    06/22/15  DAS  7.00
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     Frtehed    if   e           k disk
     Ftruckh    if   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pwhse  Warehouse
     *      $prtid  Route ID
     *
     *    Returned Parameters
     *      $ptrktmpl   Truck template
     *      $pzonetmpl  Zone template
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pWhse            3 0
     C                   parm                    $pRtId            5
     C                   parm                    $pTrkTmpl        10
     C                   parm                    $pZoneTmpl       10

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        $pTrkTmpl = '';
        $pZoneTmpl = '';

        // First get truck template for route.

        chain ($pWhse: $pRtid) rtehed;
        if not %found(rtehed);
          return;
        endif;

        $pTrkTmpl = rhtruk;

        // Now get zone template.

        chain (rhwhse: rhtruk) truckh;
        if %found(truckh);
          $pZoneTmpl = thztmp;
        endif;

        return;

      /end-free
