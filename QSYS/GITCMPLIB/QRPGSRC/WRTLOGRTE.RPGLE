      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  WRTLOGRTE  BFCLOG Logging Program - Route Info
     *  14 August 2015
     *  Rod Roller
     *
700  *    08/14/15  RTR  7.00
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
     *    D                                3    const
     *    D                                5    const
     *
     *    Then you can call using:
     *    /free
     *      WrtLog(<program>: '*INFO': 'Your message here.': <whs>: <rteid>);
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
     D                                3
     D                                5
     D Main            pi
     D   pPgm                        10
     D   pType                       10
     D   pText                     1024
     D   pWhsa                        3
     D   pRtid                        5

     *----------------------------------------------------------------
     * Parameters
     *     pPgm    - Log Program
     *     pType   - Log Type
     *     pText   - Log Text
     *     pWhsa   - Warehouse alpha
     *     pRtid   - Route ID
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
         monitor;
           blgwhse = %dec(pWhsa:3:0);
         on-error;
           blgwhse = 0;
         endmon;
         blgrtid = pRtid;
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
