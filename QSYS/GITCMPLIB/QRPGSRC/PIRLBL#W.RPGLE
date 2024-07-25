730aA /copy qcopysrc,hspecs
     *****************************************************************
     *   DO NOT INSTALL THIS VERSION AT PFG
     *****************************************************************

     *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  PIRLBL#W    Get next PIR label number for warehouse
     *  04 December 2019
     *  Dave Sommerville
     *
     *  Revisions
     *
730  *   12/05/19  DAS  7.30
     *     - Created
     *
730aA*   12/08/19  DAS  7.30a
     *     - Temporary revision until all programs changed to call
     *       this program instead of PIRLBL#.
     *     - Revised to call PIRLBL# and get return.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File specs
     *----------------------------------------------------------------

     fLabelw    if   e           k disk
     fworklblw  if   e           k disk

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     d kylbl#          s                   like(lblbl#)
     d forever         s               n   inz(*ON)
     d gWhse           s              3s 0
     d gFile           s             10
     d gRecId          s             11p 0
     d gRtnCode        s             10

     *----------------------------------------------------------------
     *  Called program prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.getrecid

     *----------------------------------------------------------------
     *
     *  Subprogram parameters
     *
     *    Input Parameters
     *      $whse   Warehouse
     *
     *    Returned Parameters
     *      $nxtnm  Next unused label #
     *              Defined at 11.0 for future use.
     *              GETRECID controls max digits used.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Main Line
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $whse             3 0
     C                   parm                    $nxtnm           11 0
730aA
730aA*  Temp code until all programs changed to call this program.
730aA
730aAC                   call      'PIRLBL#'
730aAC                   parm                    nxtlbl#           7 0
730aAC                   eval      $nxtnm = nxtlbl#
730aAC                   eval      *inlr = *on
730aAC                   return

      /free

          *inlr = *on;

          // Get next unused label #
          // We are assuming we will find one.

          dow forever;

            GetRecId($whse: 'LABEL': gRecId: gRtnCode);

            // If error occured, return -1

            if gRtnCode <> '*OK';
              $nxtnm = -1;
              leave;
            endif;

            // Protect agains gRecId being too large

            monitor;
              kylbl# = gRecId;
            on-error;
              $nxtnm = -2;
              leave;
            endmon;

            // See if it already exists in LABEL file

            setll ($whse: kylbl#) labelw;
            if %equal(labelw);
              iter;
            endif;

            // See if it already exists in WORKLBL file

            setll ($whse: kylbl#) worklblw;
            if %equal(worklblw);
              iter;
            endif;

            // We have a winner

            $nxtnm = gRecId;
            leave;

          enddo;

          return;

      /end-free

