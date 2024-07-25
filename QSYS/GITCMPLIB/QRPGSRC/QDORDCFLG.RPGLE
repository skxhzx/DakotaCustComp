     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  QDORDCFLG Q&D - Orphan cleanup for ORDCFLG file.
     *                - ORDCFLG wasn't added to rt755 until 9/12/17
     *  12 September 2017
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
710 A*    09/12/17  LMC 7.10
     *      - Created
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fordcflg   uf   e           k disk
     Fpirtran   if   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D error           s              1
     D forevr          s              1
     D len             s              1  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
     *
      /free
        *inlr = *on;
        dow forevr = forevr;
          read ordcflg;
          if %eof(ordcflg);
            leave;
          endif;
          // does the transaction exist in pirtran
          chain (ocftrn) pirtran;
          if %found(pirtran);
          else;
             // no pirtran record - old ordcflg record to delete
            delete ocfrec;
          endif;
        enddo;
      /end-free
     *
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr

     C                   eval      error = *off
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
