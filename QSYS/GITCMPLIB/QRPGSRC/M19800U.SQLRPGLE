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
     *  M19800U      Departure Date/Time edit/update
     *  18 November 2015
     *  Lynn McMahon
     *
     *  Revisions:
     *
700 A*    11/18/15  LMC  7.00
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pPO         Purchase Order
     *      pPOSeq      Sequence
     *      pPOItem     Item
     *
     *    Returned Parameters
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fordhm2    uf   e           k disk
     Fordhm     if a e           k disk    rename(hmrec:hm1)
     Fordh3     if   e           k disk
     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

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


     *
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D pMessage        s             99
     D psessid         s             40
     D puser           s             10
     D ppgm            s             10
     D pWhse           s              3p 0
     D pRouteId        s              5
     D pDDate          s             10
     D pDTime          s              4p 0
     D  pOutStr        s           1024    varying

     D client          s             10
     D clientloc       s             10


     *----------------------------------------------------------------
     *  Working variables
     *
     D pos             s              2  0
     D day             s              2
     D yr              s              2
     D wkdate          s              6
     D DepDate         s              6  0
     D keyDate         s              6  0
     D TodayDate       s              6  0
     D fileDate        s              8  0
     D newDateTime     s             12
     *----------------------------------------------------------------
     * Data structure
     *
     *
     *----------------------------------------------------------------
     *  Working fields.
     *

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------
     *  Called programs
     *
     *----------------------------------------------------------------
     *  Called program parameters
     *
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

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
     *------------------------------------------------------------------
     * CLCDUR2 parameters
     *------------------------------------------------------------------

     D $cdcmd          s              8

     D $cddatein       s              8  0
     D $cdtimein       s              6  0

     D $cdyears        s              3  0
     D $cdmonths       s              3  0
     D $cddays         s              3  0
     D $cdhours        s              3  0
     D $cdminutes      s              3  0
     D $cdseconds      s              3  0

     D $cddateOut      s              8  0
     D $cdtimeOut      s              6  0

     *
     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     *----------------------------------------------------------------

     c     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pPgm
     c                   parm                    pWhse
     c                   parm                    pRouteId
     c                   parm                    pDDate
     c                   parm                    pDTime

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;

         exsr edit;
         if pMessage = ' ';
           exsr update;
         endif;


         // Put together JSON string

         pOutStr = '{'
                +  '"Err":"'  + %trimr(pmessage) + '"';

         // Close off the JSON string
         pOutStr += '}';

         if pmessage = ' ';
         endif;
      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

       endsr;

      /end-free

     *----------------------------------------------------------------
     *  Edit     Edit subroutine
     *----------------------------------------------------------------

      /free
       begsr Edit;

         // date comes in as mm/dd/yy
           // need to convert this for edits
           pos = %scan('/':pDDate);
           if pos > 0;
             day = %subst(pDDate:pos+1:2);
             yr  = %subst(pDDate:pos+4:2);
             pDDate = %replace(day:pDDate:pos:2);
             pDDate = %replace(yr:pDDate:pos+2:4);
             wkdate = %trim(pDDate);
             if wkdate <> ' ';
               DepDate= %dec(wkdate:6:0);
             else;
               DepDate = 0;
             endif;
           else;
             DepDate = 0;
           endif;

         // Check for existence of date
         if DepDate = 0;
           pmessage = 'Date Must be Entered';
           leavesr;
         endif;

         // Check for existence of time
         if pDTime = 0;
           pmessage = 'Time Must be Entered';
           leavesr;
         endif;

         // get todays date in ymd
         $cvcmd = '*CURYMD';
         cvtdte($cvtdt);
         todaydate = $cvd6o;

         // convert keyed date from mdy to ymd for edit
         $cvcmd = '*MDYYMD';
         $cvd6i = %char(depdate);
         cvtdte($cvtdt);
         keydate = $cvd6o;

         // is date keyed *le today
         if todaydate > keydate;
           pmessage = 'Date keyed ' + %char(depdate) + ' is prior to today';
           leavesr;
         endif;

         // check for valid time
         if pDTime < 0001 or
            pDTime > 2359;
           pmessage = 'Invalid Time Entered ' + %char(pDTime);
           leavesr;
         endif;
       endsr;

      /end-free


     *----------------------------------------------------------------
     *  Update   Update subroutine
     *----------------------------------------------------------------

      /free
       begsr Update;
         // convert keyed date from mdy to CMD for update
         $cvcmd = '*MDYCMD';
         $cvd6i = %char(depdate);
         cvtdte($cvtdt);
         filedate = $cvd8o;
         newDateTime = %char(filedate) + %editc(pDTime:'X');
         // first check to see if order misc records exist for RouteId
         setll (pWhse: pRouteId) ordhm2;
         if not(%equal);
           // create from ordh
           setll (pWhse: pRouteId) ordh3;
           dow forever = forever;
             reade (pWhse: pRouteId) ordh3;
             if %eof(ordh3);
               leave;
             endif;
             // need to write ordhm records
             // load fields
             hmwhse = ohwhse;
             hmord  = ohord;
             hmrtid = ohrte;
             write hm1;
           enddo;
         endif;
         setll (pWhse: pRouteId) ordhm2;
         dow forever = forever;
           reade (pWhse: pRouteId) ordhm2;
           if %eof(ordhm2);
             leave;
           endif;
           hmmsc4 = %replace(newDateTime:hmmsc4:1:12);
           update hmrec;
         enddo;

       endsr;

      /end-free


