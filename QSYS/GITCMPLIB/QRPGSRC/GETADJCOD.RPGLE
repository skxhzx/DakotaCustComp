      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  GETADJCOD    Get ADJCODE and ADJMISC values
     *  27 March 2015
     *  Rod Roller
     *
700  *    03/27/15  RTR  7.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fadjcode   if   e           k disk
     Fadjmisc   if   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d whsenum         s              3s 0

     *----------------------------------------------------------------
     * Parameters
     *
     *     pCode  - Adjustment Code
     *     pDesc  - Description
     *     pSys   - System to Update
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pCode             2
     C                   parm                    pDesc            30
     C                   parm                    pSys              1

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

          // Get flags from OPTIONS
          chain (pCode) adjcode;
          if %found(adjcode);
            pDesc = addesc;
          else;
            pDesc = *blank;
          endif;

          // Get flags from OPTIONS
          chain (pCode) adjmisc;
          if %found(adjmisc);
            pSys = admsys;
          else;
            pSys = *blank;
          endif;

          *inlr = *on;

      /end-free
     *
     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *
      /free
        begsr *inzsr;

         endsr;
      /end-free
