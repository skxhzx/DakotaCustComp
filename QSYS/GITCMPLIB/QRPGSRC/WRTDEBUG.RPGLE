      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  WRTDEBUG   Debug Logger
     *  18 September 2013
     *  Rod Roller
     *
650 A*    09/18/13  RTR  6.50
     *      - Created
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fbfcdebug  o  a e           k disk

     *----------------------------------------------------------------
     *  Standard variables and constants
     *
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program information data structure
     *
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *

     *----------------------------------------------------------------
     * Constants
     *

     *----------------------------------------------------------------
     * Called Programs
     *
     *----------------------------------------------------------------
     * Program Parms
     *
     D Main            pr                  extpgm('WRTDEBUG')
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

         bdaddts = %timestamp();
         bdaddpgm = pPgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;
         bdtype = pType;
         bdvalues = pText;
         write(e) bdrec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *
      /free
        begsr *inzsr;

        endsr;
      /end-free
