      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  WRTLOG     BFCLOG Logging Program - Basic Info
     *  18 September 2013
     *  Rod Roller
     *
650 A*    09/18/13  RTR  6.50
     *      - Created
     *
     *----------------------------------------------------------------
     *  Notes:
     *
     *    The easiest way to use this program is to create a prototype:
     *    D WrtLog          pr                  extpgm('WRTLOG')
     *    D                               10    const
     *    D                               10    const
     *    D                             1024    const
     *
     *    Then you can call using:
     *    /free
     *      WrtLog('PROGRAM': '*INFO': 'Your message here.');
     *    /end-free
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fbfclog    o  a e           k disk

     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program information data structure
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Program Parms
     *
     D Main            pr                  extpgm('WRTLOG')
     D                               10
     D                               10
     D                             1024
     D Main            pi
     D   pPgm                        10
     D   pType                       10
     D   pText                     1024

     *----------------------------------------------------------------
     * Parameters
     *     pPgm    - Log Program
     *     pType   - Log Type
     *     pText   - Log Text
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

        exsr wrtDebug;

        eval *inlr = *on;

      /end-free

     *----------------------------------------------------------------
     *  wrtDebug  Write debug record
     *
      /free
       begsr wrtDebug;

         blgstrts = %timestamp();
         blgaddts = %timestamp();
         blgaddpgm = pPgm;
         blgaddcusr = #curruser;
         blgaddjusr = #user;
         blgaddjob = #job;
         blgaddnbr = #jobnbr;
         blgtype = pType;
         blgtext = pText;
         write(e) blgrec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *
      /free
        begsr *inzsr;

        endsr;
      /end-free
