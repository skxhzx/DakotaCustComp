      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  GETOPTINT    Get OPTIONINT Value
     *  19 April 2016
     *  Rod Roller
     *
700  *    04/16/13  RTR  6.50
     *      - Created from UT881
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     foptionint if   e           k disk

     *----------------------------------------------------------------
     * Parameters
     *   Incoming Values:
     *     pType   - Type Key
     *     pCat    - Category Key
     *     pName   - Name Key
     *
     *   Returned Values:
     *     pValT   - Value Type
     *     pValN   - Value Number
     *     pValA   - Value Alpha
     *     pReturn - Return Code
     *
     *----------------------------------------------------------------
     D main            pr                  extpgm('GETOPTINT')
      * Input
     D   pType                       12    const
     D   pCat                        20    const
     D   pName                       20    const
      * Output
     D   pValT                        1
     D   pValN                       15  5
     D   pValA                      100
     D   pReturn                     10

     D main            pi
      * Input
     D   pType                       12    const
     D   pCat                        20    const
     D   pName                       20    const
      * Output
     D   pValT                        1
     D   pValN                       15  5
     D   pValA                      100
     D   pReturn                     10

     *----------------------------------------------------------------
     *  Main Line
     *
      /free

          // Get values from OPTIONINT
          chain (pType: pCat: pName) optionint;
          if %found(optionint);
            pValT = opivalt;
            pValN = opivaln;
            pValA = opivala;
            pReturn = '*OK       ';
          else;
            pValT = *blank;
            pValN = *zero;
            pValA = *blanks;
            pReturn = '*ERROR    ';
          endif;

          *inlr = *on;

      /end-free
