      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
      *----------------------------------------------------------
      *   Copyright (C) 2014 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  M16100H       Get Next Super PO#
      *  03 November 2014
      *  Lynn McMahon
      *
      *  Revisions:
      *
650 A *    11/03/14  LMC  6.50
      *      - Created.
      *
      *----------------------------------------------------------

      *----------------------------------------------------------
      * File Specs
      *----------------------------------------------------------

      *----------------------------------------------------------
      *  Program information data structure
      *----------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pWhse          s              3p 0
     D  pOutStr        s            512    varying

     *----------------------------------------------------------
     *  Variables
     *----------------------------------------------------------

     D  pPO            s              9

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse        Warehouse
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pOutStr
     c*                  parm                    pPO

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        pOutStr = ' ';
        //pPO = ' ';
      /end-free
      *    Retrieve next Super P/O number.
     C                   call      'PIRSPO#'
     C                   parm                    spo#              7 0
     C
      /free
        pPO  = 'SP' + %trim(%editc(spo#:'X'));
         // Put together JSON string

         pOutStr = '{'
                +  '"spo":"'  + %trimr(pPO) + '"';

         // Close off the JSON string
         pOutStr += '}';
        *inlr = *on;

      /end-free

      *----------------------------------------------------------
      *  *INZSR   Initialization subroutine
      *----------------------------------------------------------

      /free
        begsr *INZSR;

        endsr;

      /end-free

