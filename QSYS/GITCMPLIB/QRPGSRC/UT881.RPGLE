      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  UT881      Phrase routines
     *  15 February 2013
     *  Rod Roller
     *
650 A*    02/15/13  RTR  6.50
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Foptions   if   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d whsenum         s              3s 0
     d posnum          s              3s 0
     D lennum          s              3s 0

     *----------------------------------------------------------------
     * Parameters
     *   Incoming Values:
     *     pWhse  - Warehouse
     *     pCode  - Code Key
     *     pPos   - field start
     *     pLen   - field length
     *
     *   Returned Values:
     *     pvalue - field value
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse             3
     C                   parm                    pCode             8
     C                   parm                    pPos              3
     C                   parm                    pLen              3
     C                   parm                    pValue          117

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

          // Get flags from OPTIONS
          chain (whsenum: pCode) options;
          if %found(options);
            pValue = %subst(opdata: posnum: lennum);
          else;
            pvalue = '*ERROR';
          endif;

          *inlr = *on;

      /end-free
     *
     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *
      /free
        begsr *inzsr;

          // Convert or default whse
          monitor;
            whsenum = %dec(pWhse:3:0);
          on-error;
            Whsenum = 0;
          endmon;

          // Convert or default position
          monitor;
            posnum = %dec(pPos:3:0);
          on-error;
            posnum = 1;
          endmon;

          // Convert or default lenght
          monitor;
            lennum = %dec(pLen:3:0);
          on-error;
            lennum = 117;
          endmon;

         endsr;
      /end-free
