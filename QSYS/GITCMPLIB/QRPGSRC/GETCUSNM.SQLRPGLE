      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETCUSNM    Get customer name
     *  12 Apr 2016
     *  Retha Davis
     *
     *  Revisions:
     *
700 A*    04/12/16  RBD  7.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fordh      if   e           k disk

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     d true            c                   *on
     d false           c                   *off

      *----------------------------------------------------------
      *  Input Parms
      *----------------------------------------------------------

     D  pWhse          s              3p 0
     D  pRteId         s              5    varying
     D  pStop          s              2p 0
     D  pCusNm         s             40    varying

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pRteId      Route Id
     *      pStop       Stop
     *
     *    Returned Parameters
     *      pCusNm      Customer name
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse
     C                   parm                    pRteId
     C                   parm                    pStop
     C                   parm                    pCusNm

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        pCusNm = ' ';

         exec sql select ohwhse, ohrte, ohstop, ohcnam
                  into :pWhse, :pRteId, :pStop, :pCusNm
                  from ordh
                  where ohwhse = :pWhse
                    and ohrte  = :pRteId
                    and ohstop = :pStop
                  fetch first 1 rows only;

         if sqlstt <> sqlSuccess;
           pCusNm = '** Customer name not found **';
         endif;

        *inlr = *on;
        return;

      /end-free

