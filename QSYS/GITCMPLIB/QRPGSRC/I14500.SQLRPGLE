      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  FI14500H     Uci receiving -  Totals
     *  02 March 2016
     *  Lynn McMahon
     *
     *  Revisions:
     *
700 A*    03/02/16  LMC  7.00
     *      - Created.
     *      - Returns value field for displaying on list.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar


     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D Qty             s              6s 0
     D Wgt             s             10s 2

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D uirec         E Ds                  Extname(uciinfo)
     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pWhse          s              3p 0
     D  pLcns          s             15
     D  pOutStr        s           1024    varying

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pLcns       License
     *
     *    Returned Parameters
     *      pOutStr     JSON output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    plcns
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;

        // Get uci scanned totals
        Qty = 0;
        Wgt = 0;

        exec sql select count(*), sum(UIWGTLBS)
                 into :qty,
                      :wgt
                 from uciinfo
              where uiwhse = :pWhse
                and uilcns = :plcns;
           If sqlstt = sqlSuccess;
           endif;

         // Put together JSON string

         pOutStr = '{'
                +  '"Qty":"'  + %char(Qty) + '",'
                +  '"Wgt":"'  + %char(Wgt) + '"';

         // Close off the JSON string
         pOutStr += '}';

        return;
      /end-free

