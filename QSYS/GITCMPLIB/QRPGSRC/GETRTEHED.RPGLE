      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  GETRTEHED   Get RTEHED fields
     *  25 January 2016
     *  Rod Roller
     *
700  *    01/25/16  RTR  7.00
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     frtehed    if   e           k disk

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Parameters
     *   Parameters:
     *     pWhse  - Warehouse
     *     prtid  - Route ID
     *
     *   Return Value:
     *     prtnam     -  Route Name
     *     prttyp     -  Route Type
     *     prtsts     -  Route Status
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse             3 0
     C                   parm                    prtid             5
     C                   parm                    prtnam            5
     C                   parm                    prttyp            1
     C                   parm                    prtsts            1

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

       // Initialize return parms

        if %parms >= 3;
          prtnam = '     ';
        endif;

        if %parms >= 4;
          prttyp = ' ';
        endif;

        if %parms >= 5;
          prtsts = ' ';
        endif;

       // Get RTEHED record

        chain (pWhse: prtid) rtehed;

        if %found(rtehed);

        if error;
          return;
        endif;

         if %parms >= 3;
           prtnam = rhrte;
         endif;

         if %parms >= 4;
           prttyp = rhtype;
         endif;

         if %parms >= 5;
           prtsts = rhstat;
         endif;

       endif;

       return;

      /end-free

