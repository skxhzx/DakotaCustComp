      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
      *----------------------------------------------------------
      *   Copyright (C) 2016 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  GetBranded  Get Branded Item Information
      *  26 May 2016
      *  Lynn McMahon
      *
      *  Revisions:
      *
700 A *    05/26/16  LMC  7.00
      *      - Created.
700aA *    10/26/16  LMC/JJ  7.00a
      *      - Bring back brand flag on getflag command.
      *      - Will be used to print on smart license plates.
      *
      *----------------------------------------------------------

      *----------------------------------------------------------
      * File Specs
      *----------------------------------------------------------

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      *----------------------------------------------------------
      *  Program information data structure
      *----------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pCommand       s             10
     D  pWhse          s              3p 0
     D  pPItem         s             15
     D  pBBrand        s             10
     D  pBItem         s             15
     D  pBrandFlag     s              1

     *
     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------
     *  Variables
     *----------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Command Notes
     *----------------------------------------------------------------
     *      *GETFLAG          If item is setup in ITEMBRD - flag = Y
     *
     *      *GET4BITM         Get for Branded Item

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D ibrec         e ds                  extname(itembrd)

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pCommand     Command
     *      pWhse        Warehouse
     *      pPItem       Parent Item
     *      pBBrand      Brand
     *      pBItem       Branded Item
     *      pBrandFlag   Branded Item Flag
     *
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pCommand
     c                   parm                    pWhse
     c                   parm                    pPItem
     c                   parm                    pBBrand
     c                   parm                    pBItem
     c                   parm                    pBrandFlag

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

         Select;
           When pCommand = '*GETFLAG';
             exec sql select * into :ibrec
                 from itembrd
                 where ibwhse = :pWhse
                   and ibitem = :pPItem
                 fetch first 1 rows only;

             If sqlstt = sqlSuccess;
               pBrandFlag = 'Y';
700aA          pBbrand = ibbrnd;
             else;
               pBrandFlag = ' ';
700aA          pBbrand = ' ';
             endif;

           When pCommand = '*GET4BITM';
             exec sql select * into :ibrec
                 from itembrd
                 where ibwhse = :pWhse
                   and ibbitm = :pBItem;

             If sqlstt = sqlSuccess;
               pBBrand = ibbrnd;
               pPItem  = ibitem;
               pBrandFlag = 'Y';
             endif;
         endsl;
      /end-free
      *----------------------------------------------------------
      *  *INZSR   Initialization subroutine
      *----------------------------------------------------------

      /free
          begsr *INZSR;


           endsr;

      /end-free

