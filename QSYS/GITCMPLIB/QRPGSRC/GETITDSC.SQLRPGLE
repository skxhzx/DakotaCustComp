      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETITDSC    Get item description
     *  18 Jul 2014
     *  Retha Davis
     *
     *  Revisions:
     *
650 A*    07/18/14  RBD  6.50
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fpiritem   if   e           k disk

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
     D  pItem          s             15    varying
     D  pDesc          s             30    varying

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pTran       Item number
     *
     *    Returned Parameters
     *      pItdesc     Item description
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse
     C                   parm                    pItem
     C                   parm                    pDesc

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        pdesc = ' ';

        chain(n) (pWhse: pItem) piritem;
        if %found(piritem);
           pDesc = itdesc;
        else;
           pDesc = '** Invalid Item **';
        endif;

        *inlr = *on;
        return;

      /end-free

