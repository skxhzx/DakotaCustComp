      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  FM19800      Route Departure Date/Time - Init fields
     *  09 November 2015
     *  Lynn McMahon
     *
     *  Revisions:
     *
700 A*    11/09/15  LMC  7.00
     *      - Created.
     *      - Returns values for displaying correct fields on entry screen
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSession    Session
     *      pWhse       Warehouse
     *      pRouteId    Route Id
     *
     *    Returned Parameters
     *      pOutStr     JSON output string
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D FromStamp       s               z
     D ToStamp         s               z
     D oldeststamp     s               z
     D ts              s               z

     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

     D bfcoffset       s              3  0 inz(0)

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.cvtdte

     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D psessid         s             40
     D pWhse           s              3  0
     D pRouteId        s              5
     D  pOutStr        s           1024    varying

     D client          s             10
     D clientloc       s             10

     D errmsg          s             40

     *----------------------------------------------------------------
     * Data structure
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Working fields.
     *----------------------------------------------------------------

     D deldate         s              8  0
     D deltime         s              4  0
     D mdydate         s              6  0

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
     *
     *

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D hmrec         E Ds                  Extname(ordhm2)
     *----------------------------------------------------------------

     c     *entry        plist
     C                   parm                    pSessId
     c                   parm                    pWhse
     c                   parm                    pRouteId
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;

         exsr GetDepartureInfo;


         // Put together JSON string

         pOutStr = '{'
                +  '"Err":"'  + %trimr(Errmsg) + '",'
                +  '"DelDate":"'  + %trim(%editc(mdydate:'Y')) + '",'
                +  '"DelTime":"'  + %editc(deltime:'X') + '"';

         // Close off the JSON string
         pOutStr += '}';

      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         getclient(client: clientLoc);

       endsr;

      /end-free

     *----------------------------------------------------------------
     *  GetDepartureInfo   - Get Departure date/time
     *----------------------------------------------------------------
      /free
       begsr GetDepartureInfo;
         exec sql select * into :hmrec
              from ordhm2
              where hmwhse = :pWhse
                and hmrtid = :pRouteid
              fetch first row only;

         If sqlstt = sqlSuccess;
           // Departure date and time

           //Initialize dates and times if departure date/time not numeric
           if %check('0123456789' : %subst(hmmsc4:1:12)) <> 0;
             deldate = 0;
             deltime = 0;

           else;

           //  Convert alpha date and time to numeric
             deldate = %dec(%subst(hmmsc4:1:8):8:0);
             deltime = %dec(%subst(hmmsc4:9:4):4:0);
             //deltime = deltime * 100;

           endif;
         else;
            deldate = 0;
            deltime = 0;
         endif;

         // convert date to ymd
         if deldate <> 0;
           $cvcmd = '*CMDMDY';
           $cvd8i = %char(deldate);
           cvtdte($cvtdt);
           mdydate = $cvd6o;
         else;
           mdydate = 0;
         endif;
       endsr;

      /end-free

