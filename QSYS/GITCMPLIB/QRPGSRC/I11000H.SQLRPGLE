      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  FI11000H     Purchase Order Receiving Quanity Difference
     *  28 October 2014
     *  Lynn McMahon
     *
     *  Revisions:
     *
650 A*    10/28/14  LMC  6.50
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

     D Touch           s              1

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D pdjrec        E Ds                  Extname(podtl3) prefix(x_)
     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pWhse          s              3p 0
     D  pPO            s              9
     D  pPOseq         s              5p 0
     D  pPOitem        s             15
     D  pOutStr        s           1024    varying

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pPO         Purchase Order
     *
     *    Returned Parameters
     *      pOutStr     JSON output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pPOseq
     c                   parm                    pPOitem
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;

         // get touched flag

         exec sql select * into :pdjrec
              from podtl3
              where pdwhse = :pWhse
                and pdpo   = :pPO
650cA           and pdseq  = :pPOSeq
650cA           and pditem = :pPOitem
650cA           and poredt = 0
                fetch first 1 rows only;

650cA    If sqlstt = sqlSuccess;
650cA      touch = 'Y';
650cA    else;
650cA      touch = ' ';
650cA    endif;
         // Put together JSON string
         pOutStr = '{'
                +  '"Touch":"'  + %trimr(Touch) + '"';

         // Close off the JSON string
         pOutStr += '}';

        return;
      /end-free

