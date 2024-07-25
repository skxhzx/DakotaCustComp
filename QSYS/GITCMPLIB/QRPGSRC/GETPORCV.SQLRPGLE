      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETPORCV    Get PO Detail line touched flag
     *  29 January 2016
     *  Lynn McMahon
     *
     *  Revisions:
     *
700 A*    01/29/16  LMC  7.00
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

     D pdjrec        E Ds                  Extname(podtl3) prefix(x_)
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
     D  pTouch         s              1

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
     *      pTouch      Touched Flag
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse
     C                   parm                    pPO
     C                   parm                    pPOSeq
     C                   parm                    pTouch

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        pTouch = ' ';

         // get touched flag

         exec sql select * into :pdjrec
              from podtl3
              where pdwhse = :pWhse
                and pdpo   = :pPO
                and pdseq  = :pPOSeq
                and poredt = 0
                fetch first 1 rows only;

         If sqlstt = sqlSuccess;
           pTouch = 'Y';
         else;
           pTouch = 'N';
         endif;

        *inlr = *on;
        return;

      /end-free

