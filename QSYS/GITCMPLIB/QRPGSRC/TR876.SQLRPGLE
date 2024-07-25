      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  TR876  Set Trax start date = 20010101 if start date = 0, which
     *         indicates the route was not processed through Trax.
     *         Call from jobscde PIRTRAXDAT daily at the time between
     *         finishing a day's routes and starting a new day, which
     *         typically would match the *LOADER end time.
     *
     *  08 April 2019
     *  Retha Davis
     *
     *  Revisions:
     *
730aA*    04/08/19  RBD  7.30a
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------
     D ttrrec        E Ds                  Extname(ttrte)

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D defaultDate     s              8s 0 inz(20010101)
     D pWhse           s             15  5

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     * Call program prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *
     *    Returned Parameters
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d UpdateRte       pr
     d  whse                          3  0 const

     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;

         UpdateRte(pWhse);

         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  UpdateRte    Update route
     *----------------------------------------------------------------

     p UpdateRte       b
     d UpdateRte       pi
     d  whse                          3  0 const

      /free

         exec sql update ttrte set
                    ttrsrd = :defaultDate
                  where ttrwhs = :whse
                    and ttrsrd = 0;
       return;

      /end-free

     p                 e

