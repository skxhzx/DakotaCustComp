      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  TESTF1     Function test 1 - Pgm for TESTF1 function
     *  11 March 2013
     *  Dave Sommerville
     *
     *  Revisions:
     *
640 A*    03/11/13  DAS  6.50
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fitemqty   if   e           k disk

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse       Warehouse
     *      $pItem       Item number
     *
     *    Returned Parameters
     *      $pQty       -  Quantity
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pWhse            3 0
     C                   parm                    $pItem           15
     C                   parm                    $pQty             7 0

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         chain ($pwhse: $pItem) itemqty;
         if not %found;
           $pQty = 0;
         else;
           $pQty = iqstk1;
         endif;

         return;
      /end-free

