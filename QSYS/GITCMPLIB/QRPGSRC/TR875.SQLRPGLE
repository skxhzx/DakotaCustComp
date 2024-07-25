      /copy qcopysrc,hspecs
     H Dftactgrp(*No)
      *****************************************************************
      *
      *  To compile:
      *
      *             CRTSQLRPGI PGM(XXX/SQL003RG) SRCFILE(XXX/QRPGLESRC)
      *
      *
      * COMPILING. In order to compile this program you will need
      *            to use options which allow it to work correctly
      *            between machines. These options are---
      *
      *               COMMIT = *NONE
      *               RDB    = Machine name that you will connect to.
      *               DLYPRP = *YES
      *               SQLPKG = The name & library that you want to
      *                        use for the package. This will put the
      *                        package on the RDB machine that you
      *                        specify.
      *****************************************************************
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  TR875   Auto define add-on routes, also update loader header
     *          if an associated route has been started.
     *
     *  17 Feb 2016
     *  Retha Davis
     *
     *  Revisions
     *
700 A*    02/17/16  RBD  7.00
     *      - Created.
     *      - When a route is printed and *LOADER/OPADDO is Y this pgm is
     *        called. If there's a matching host route in RTEHED within
     *        the loader start and end times for the current session of
     *        routes and it doesn't exist in TTMERG, designate the one
     *        found in RTEHED as the parent, the one just printed as the
     *        child and add it to TTMERG. If a match is found and it does
     *        exist in TTMERG, add a record for the printed route as the
     *        child, using the parent route and route id of the record
     *        just found in TTMERG.
     *      - If an associated route has been started in the Loader Mod,
     *        update this route's loader header trailer, start date,
     *        start time, emp# and status.
     *      - Of course the user may still maintain add-ons through Trax
     *        Merge Route Maintenance if desired.
     *
720aA*    08/29/18  RBD  7.20a
     *      - If route departure dates are populated use them rather
     *        than Loader start and end times to determine if there's a
     *        like host route for the same day.
     *
720b *    01/11/19  GJA  7.20b
     *      - Enh:  Add client code.
     *

     *----------------------------------------------------------------
     *  Clients Revisions
     *----------------------------------------------------------------
     *
ISYa *    01/11/19  GJA  ISYa
     *      - Enh:  Merge routes using first 4 characters of route
     *
ISYbA*    06/22/20  RBD  ISYb
     *      - Enh: Ignore loader cycle time for determining add ons,
     *        instead require the parent and add ons be no more than
     *        three days apart.  Don't have to worry about time of day.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Frtehed1   uf a E           k disk
     Fttmerg    uf a E           k disk
     Fldrhdr    uf a E           k disk
     Fpiruser   if   E           k disk
720aAFordhm2    if   E           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.cvtdte
720bA /copy qcopysrc,p.getclien

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d GetCurrStamp    pr
     d UpdLoader       pr
     d WrtAddOns       pr

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D FromStamp       s               z
     D ToStamp         s               z
     D ts              s               z

     D bfcoffset       s              3  0 inz(0)
     D ucOffset        s              3  0

     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Display File Information Data Structure
     *----------------------------------------------------------------

     Dinfo             ds
     D cfkey                 369    369

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     D blanks          s            100    inz(' ')

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Clients
     *----------------------------------------------------------------

ISYaA /copy qcopysrc,ID#ISUPPLY

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $code           s              2    inz(' ')
     D $count          s              8b 0 inz(0)
     D action          s              3
720aAD departDt        s              8  0
720aAD departTm        s              4  0
720aAD pDepartDt       s              8  0
720aAD pDepartTm       s              4  0
     D adj             s              3    inz('ADJ')
     D append1         s              1
     D append5         s              5
     D booleanOn       s              3    inz('1')
720bAD client          s             10
720bAD clientloc       s             10
     D cnt             s             10i 0
     D first           s               n
     D groupby         S            100a   inz(' ')
     D groupfields     S            100a   inz(' ')
     D noParmsPassed   s               n
     D opcode          s              6
     D optiontaken     s             10    inz(' ')
     D orderby         S            100a   inz(' ')
     D orderfield      s             10    inz(' ')
     D orderposition   s              3  0 inz(0)
     D ordqty          s             10  0 inz(0)
     D posfld          s              5    inz(' ')
     D four            s              1    inz('4')
     D six             s              1    inz('6')
     D sortorder1      s             10    inz(' ')
     D sortorder2      s             10    inz(' ')
     D sortorder3      s             10    inz(' ')
     D svlhwhse        s                   like(lhwhse)
     D svlhrte         s                   like(lhrte)
     D svlhrtid        s                   like(lhrtid)
     D svlhtrlr        s                   like(lhtrlr)
     D svlhstrd        s                   like(lhstrd)
     D svlhstrt        s                   like(lhstrt)
     D printflag       s               n
     D yes             s              1    inz('Y')
ISYaADpRte4            s              5

     *----------------------------------------------------------------
     *  CVTDTE constant and parameter data structure.
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

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d  pWhse          s              3  0
     D  pRte           s              5
     D  pRtid          s              5
     d  pPassedRtTm    s              6  0
     d  pStime         s              6  0
     d  pEtime         s              6  0
     D  pRtn           s             10

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pRte        Route
     *      pRtid       Route Id
     *      pPassedRtTm Route printed time
     *      pStime      Current session route start time
     *      pEtime      Current session route end time
     *
     *    Returned Parameters
     *      pRtn        *ADDON    - add-on route
     *                  *NOTADDON - not an add-on route
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse
     c                   parm                    pRte
     C                   parm                    pRtid
     C                   parm                    pPassedRtTm
     C                   parm                    pStime
     C                   parm                    pEtime
     C                   parm                    pRtn

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        *inlr = *on;
        pRtn = '*NOTADDON ';

        exsr zzinz2;

        // Write add-on if you find a matching host route for the current
        // routes session
        wrtAddOns();

        // If this is an add-on go see if an associated route has been
        // started in Loader, and if so update loader header for this route
        if pRtn = '*ADDON    ';
          updLoader();
        endif;

        return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr *inzsr;

720bA  GetClient(client: clientLoc);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
      /free
       begsr zzinz2;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetCurrStamp  Get current timestamps
     *----------------------------------------------------------------

     p GetCurrStamp    b
     d GetCurrStamp    pi

      /free

         getmicrotime(currstampuc:currstampsys);
         ucOffset = %diff(currstampuc: currstampsys: *HOURS);
         currstamploc = currstampsys + %hours(bfcoffset);

      /end-free

     p GetCurrStamp    e

     *----------------------------------------------------------------
     *  WrtAddOns   If there's a matching host route in RTEHED within
     *              the loader start and end times for the current
     *              session of routes and it doesn't exist in TTMERG,
     *              designate the one found in RTEHED as the parent,
     *              the one just printed as the child and add it to
     *              TTMERG. If a match is found and it does exist in
     *              TTMERG, add a record for the printed route as the
     *              child, using the parent route and route id of the
     *              record just found in TTMERG.
     *
     *----------------------------------------------------------------

     p WrtAddOns       b
     d WrtAddOns       pi

      /free
        error = *off;

720aA   // Get departure date and time for imported route, if there is one
720aA   chain (pWhse: pRtid) ordhm2;
720aA      if %found and %check('0123456789' : %subst(hmmsc4:1:12)) = 0;
720aA        pDepartDt = %dec(%subst(hmmsc4:1:8):8:0);
720aA        pDepartTm = %dec(%subst(hmmsc4:9:4):4:0);

720aA      else;

720aA        pDepartDt = 0;
720aA        pDepartTm = 0;

720aA      endif;

        // Look for matching host route

ISYaA   if client = isupply;
ISYaA     pRte4 = %subst(pRte:1:4);
ISYaA     SqlStmt = 'select '
ISYaA           +   'rhwhse, rhrte, rhrtid, rhprtd, '
ISYaA           +   'rhprtt, rhstat '
ISYaA           + 'from rtehed1 '
ISYaA           + 'where rhwhse = ' + %char(pWhse)
ISYaA           +   ' and substring(rhrte,1,4) = ' + sq + (pRte4) + sq
ISYaA           +   ' and rhrtid <> ' + sq + (pRtid) + sq
ISYaA           +   ' and rhstat >= ' + sq + %trim(four) + sq
ISYaA           +   ' and rhstat <= ' + sq + %trim(six) + sq;
ISYaA   else;
          SqlStmt = 'select '
                +   'rhwhse, rhrte, rhrtid, rhprtd, '
                +   'rhprtt, rhstat '
                + 'from rtehed1 '
                + 'where rhwhse = ' + %char(pWhse)
                +   ' and rhrte = ' + sq + (pRte) + sq
                +   ' and rhrtid <> ' + sq + (pRtid) + sq
                +   ' and rhstat >= ' + sq + %trim(four) + sq
                +   ' and rhstat <= ' + sq + %trim(six) + sq;
ISYaA   endif;

        exec sql prepare rtesel from :SqlStmt;
        exec sql declare rtecsr cursor for rtesel;
        exec sql open rtecsr;

        dow forever = forever;

          exec sql fetch next from rtecsr
                   into :rhwhse, :rhrte, :rhrtid, :rhprtd,
                        :rhprtt, :rhstat;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

720aA     // If imported route has a departure date see if the like
720aA     // route does too and if they match you've got an add on,
720aA     // otherwise use loader date and times
720aA     if pDepartDt <> 0;
720aA       chain (rhwhse: rhrtid) ordhm2;
720aA       if %found and %check('0123456789' : %subst(hmmsc4:1:12)) = 0;
720aA         departDt = %dec(%subst(hmmsc4:1:8):8:0);
720aA         departTm = %dec(%subst(hmmsc4:9:4):4:0);

720aA       else;

720aA         departDt = 0;
720aA         departTm = 0;

720aA       endif;
720aA     endif;

          select;

720aA       // Incoming route and like route have same departure date
720aA       // so this means you have a legit add on
720aA       when pDepartDt <> 0 and pDepartDt = departDt;

ISYbA       when client = isupply;
ISYbA         if rhprtd < %dec(%char(%date() - %Days(3):*ISO0):8:0);
ISYbA           iter;
ISYbA         endif;

720aA       // If you got this far you've got to use Loader date and time
            // Incoming route printed time is >= the start time
            // so you only have to deal with today's date

            when pPassedRtTm >= pStime;

              // Matching route not printed today, keep looking
              if rhprtd < %dec(%date():*iso);
                iter;
              endif;
              // Matching route printed before start time, keep looking
              if rhprtd = %dec(%date():*iso) and rhprtt < pStime;
                iter;
              endif;


            // Incoming route printed time is < the start time
            // so you have to deal with today's date and yesterday's

            other;

              // Matching route was printed before yesterday, keep looking
              if rhprtd < %Dec(%Date() - %Days(1): *iso);
                iter;
              endif;

              // Matching route printed before yesterday's start time,
              // keep looking
              if rhprtd = %Dec(%Date() - %Days(1): *iso)
                 and rhprtt < pStime;
                  iter;
              endif;

          endsl;

          // Does the rtehed route already exist in the add-ons file ?
          exec sql select ttmwhs, ttmprt, ttmpri
                   into :ttmwhs, :ttmprt, :ttmpri
                   from ttmerg
                   where ttmwhs = :rhwhse
                     and ttmprt = :rhrte
                     and ttmpri = :rhrtid
                     or  ttmwhs = :rhwhse
                     and ttmcrt = :rhrte
                     and ttmcri = :rhrtid;

          // If the rtehed route already exists in the add-ons file,
          // add the printed route as a child, using the parent route
          // and route id of the record found in the add-ons file ...
          // the parent route id may or may not be the same as the matching
          // route found in RTEHED
          if sqlstt = sqlSuccess;
            exec sql insert into ttmerg
                 values(:pWhse, :ttmprt, :ttmpri, :prte, :prtid);
                 If sqlstt = sqlSuccess;
                 endif;

          else;

            // If the rtehed route does not already exist in the add-ons file,
            // add the printed route as the child and the RTEHED route as the
            // parent of the child

            exec sql insert into ttmerg
                 values(:pWhse, :rhrte, :rhrtid, :prte, :prtid);
                 If sqlstt = sqlSuccess;
                 endif;

          endif;

          pRtn = '*ADDON    ';

          // All done, you've written the add-on record
          leave;

          enddo;

        exec sql close rtecsr;

      /end-free

     p WrtAddOns       e

     *----------------------------------------------------------------
     *  UpdLoader   If an associated route has been started in the
     *              Loader Mod, update this route's loader header
     *              trailer, start date, start time, emp# and status.
     *
     *----------------------------------------------------------------

     p UpdLoader       b
     d UpdLoader       pi

      /free
        error = *off;

           exec sql select lhwhse, lhrte, lhrtid, lhtrlr, lhstrd, lhstrt
                     into :svlhwhse, :svlhrte, :svlhrtid, :svlhtrlr,
                          :svlhstrd, :svlhstrt
                from ldrhdr
                where lhwhse = :pWhse
                  and lhrte  = :pRte
                  and lhrtid <> :pRtid
                  and lhtrlr <> ' '
                fetch first row only;

           if sqlstt = sqlSuccess;
             chain (pWhse: pRte: pRtid) ldrhdr;
             if %found;
               lhtrlr = svlhtrlr;
               lhstrd = svlhstrd;
               lhstrt = svlhstrt;
               lhstat = '2';
               chain (#user) piruser;
               if %found;
                 lhemp# = usemp#;
               endif;
               update lhrec;
             endif;
           endif;

      /end-free

     p UpdLoader       e

     *----------------------------------------------------------------
