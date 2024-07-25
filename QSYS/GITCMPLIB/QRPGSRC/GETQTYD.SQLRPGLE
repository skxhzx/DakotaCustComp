      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETQTYD     Get PO Detail line quantity Discrepancy flag
     *  23 June 2016
     *  Lynn McMahon
     *
     *  Revisions:
     *
700 A*    06/23/16  LMC  7.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D pdrec         E Ds                  Extname(podtl)
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
     D  pPo            s              9
     D  pPoSeq         s              5p 0
     D  pQtyd          s              1

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pPO         PO#
     *      pPOSeq      PO Seq#
     *
     *    Returned Parameters
     *      pQtyD       Quantity Discrepancy
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse
     C                   parm                    pPO
     C                   parm                    pPOSeq
     C                   parm                    pQtyD

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        pQtyD = ' ';

         // get quantity discrepancy flag

         exec sql select * into :pdrec
              from podtl
              where pdwhse = :pWhse
                and pdpo   = :pPO
                and pdseq  = :pPOSeq
                fetch first 1 rows only;

         If sqlstt = sqlSuccess;
           // Do the qty order and received match
           Select;
             when pdqor1 <> pdqrc1
              or pdqor2 <> pdqrc2
              or pdqor3 <> pdqrc3;
               pQtyD = 'Y';
             other;
               pQtyD = 'N';
           endsl;
         else;
           pQtyD = 'N';
         endif;

        *inlr = *on;
        return;

      /end-free

