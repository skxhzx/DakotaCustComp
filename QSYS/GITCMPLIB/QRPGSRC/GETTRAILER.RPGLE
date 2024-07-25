      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETTRAILER  Get trailer
     *  23 June 2015
     *  Dave Sommerville
     *
     *  Revisions:
     *
700 A*    06/23/15  DAS  7.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Frtehed    if   e           k disk
     Frtetrailerif   e           k disk
     Ftruckt    if   e           k disk

     *----------------------------------------------------------------
     *  Parms
     *----------------------------------------------------------------

     D  pWhse          s              3p 0
     D  pRtid          s              5
     D  pTrailer       s              8

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pRtid       Route id
     *
     *    Returned Parameters
     *      pTrailer    Trailer
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse
     C                   parm                    pRtid
     C                   parm                    pTrailer

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        pTrailer = '';

        // First try RTETRAILER file.

        chain  (pWhse: pRtId) rtetrailer;
        if %found(rtetrailer) and rttcode <> '';
          pTrailer = rttcode;
          return;
        endif;

        // Otherwise, get default for truck.

        chain  (pWhse: pRtId) rtehed;
        if not %found(rtehed);
          return;
        endif;

        chain  (pWhse: rhtruk) truckt;
        if %found(truckt);
          pTrailer = tttrlr;
        endif;

        return;

      /end-free

