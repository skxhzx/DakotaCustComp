      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  GETOPTIONS   Get Options Record
     *  25 September 2013
     *  Rod Roller
     *
650  *    09/25/13  RTR  6.50
     *      - Created from UT881
650a *    03/15/15  RTR  6.50a
     *      - Fix: changed default length to account for position.
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

          // Convert or default length
          monitor;
            lennum = %dec(pLen:3:0);
          on-error;
650aD  //   lennum = 117;
650aM       lennum = 118 - posnum;
          endmon;

         endsr;
      /end-free
