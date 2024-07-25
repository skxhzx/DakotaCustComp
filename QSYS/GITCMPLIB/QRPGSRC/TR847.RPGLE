      /COPY *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('HTTPAPI')
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  TR847     Update TTRTEEXT and TTSTPEXT files
     *  11 January 2018
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    01/11/18   DAS  7.10
     *      - Created.
     *
     *    02/20/18  DAS  7.20a
     *      - Removed returned pieces from PPH calculation.
     *      - Revised to use current time for route finished time
     *        when finished time is zero.
     *
720b *    04/12/18  MR  7.20b
     *      - Default total stop seconds to 9999999 if total stop
     *        seconds are greater than 9999999.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fttrte     if   e           k disk
     Fttstp     if   e           k disk
     Fttrteext  uf a e           k disk
     Fttstpext  uf a e           k disk

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D forever         s               n   inz(*on)
720bAD chktotsec       s             10s 0

     *----------------------------------------------------------------
     *  Sub-Procedure Prototypes
     *----------------------------------------------------------------

     d CalcSeconds     pr             7p 0
     d  fromTS                         z   const
     d  ToTS                           z   const

     d CreateStamp     pr              z
     d  date                          8s 0 const
     d  time                          6s 0 const

     d ProcessStops    pr

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PRTID  Route ID  (*ALL is allowed)
     *
     *    Returned Parameters
     *      $PRTN   *OK      - Route was processed.
     *              *ERROR   - Error occured
     *
     *----------------------------------------------------------------
     *  Let the show begin .....

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $prtn             8
     C                   parm                    $perm            60

     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------

      /free

        *inlr = *on;
        $prtn = '*OK';
        $perm = '';

        // Read through Routes

        if $pRtid <> '*ALL';
          setll ($pWhse: $pRtid) ttrte;
        endif;

        dou %eof(ttrte);

          if $pRtid = '*ALL';
            read ttrte;
          else;
            reade ($pWhse: $pRtid) ttrte;
          endif;

          if %eof(ttrte);
            leave;
          endif;

          chain (ttrwhs: ttrrti) ttrteext;
          if not %found(ttrteext);
            clear ttrerec;
          endif;

          // Start Finish dates

720aA     select;
720aA       when ttrsrd > 0 and ttrfid > 0;
              ttresrs = CreateStamp(ttrsrd: ttrsrt);
              ttrefis = CreateStamp(ttrfid: ttrfit);
              ttrertesec = CalcSeconds(ttresrs: ttrefis);
720aA
720aA       when ttrsrd > 0 and ttrfid = 0;
720aA         ttresrs = CreateStamp(ttrsrd: ttrsrt);
720aA         ttrefis = %timestamp();
720aA         ttrertesec = CalcSeconds(ttresrs: ttrefis);
720aA
720aA       other;
720aA         ttrertesec = 0;
720aA
720aA     endsl;

          // Current Stop

          clear ttrecurstp;
          clear ttrecurstr;

          // Last Stop

          clear ttrelststp;
          clear ttrelststr;
          clear ttrelstend;
          clear ttrelstsec;

          // Route Totals

          clear ttrestpsec;
          clear ttrecmppcs;
          clear ttrepph;

          // Process Stops for Route

          ProcessStops();

          // Write/Update record

          if not %found(ttrteext);
            ttrewhs = ttrwhs;
            ttrerti = ttrrti;
            write ttrerec;

          else;
            update ttrerec;

          endif;

        enddo;

        return;

      /end-free

     *----------------------------------------------------------------
     *  CalcSeconds   Calculate seconds between timestamps
     *----------------------------------------------------------------

     p CalcSeconds     b
     d CalcSeconds     pi             7p 0
     d  fromTS                         z   const
     d  toTS                           z   const

     *  Local Variables

     d noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')
     D seconds         s              7p 0

      /free

        select;
          when fromTS = noStamp;
            seconds = 0;
          when toTS = noStamp;
            seconds = 0;
          when fromTS > toTS;
            seconds = 0;
          other;
            monitor;
              seconds = %diff(toTS: fromTS: *SECONDS);
            on-error;
              seconds = 0;
            endmon;
        endsl;

        return seconds;

      /end-free

     p CalcSeconds     e

     *----------------------------------------------------------------
     *  CreateStamp   Create timestamp from yyyymmdd and hhmmss
     *----------------------------------------------------------------

     p CreateStamp     b
     d CreateStamp     pi              z
     d  dateIn                        8s 0 const
     d  timeIn                        6s 0 const

     *  Local Variables

     D temp26          s             26
     D stampOut        s               z

     D                 ds
     D  yyyymmdd               1      8s 0
     D    yyyy                 1      4
     D    mm                   5      6
     D    dd                   7      8

     D                 ds
     D  hhmiss                 1      6s 0
     D    hh                   1      2
     D    mi                   3      4
     D    ss                   5      6

      /free

          yyyymmdd = dateIn;
          hhmiss = timeIn;
          temp26 = yyyy + '-' + mm + '-' + dd + '-'
                 + hh + '.' + mi + '.' + ss + '.000000';
          monitor;
            stampOut = %timestamp(temp26);
          on-error;
            clear stampOut;
          endmon;

        return stampOut;

      /end-free

     p CreateStamp     e

     *----------------------------------------------------------------
     * ProcessStops -  Process Stops for Route
     *----------------------------------------------------------------

     p ProcessStops    b
     d ProcessStops    pi

     * Local Variables

     d pcs             s              7  0

      /free

        setll (ttrwhs: ttrrti) ttstp;

        dou %eof(ttstp);

          reade (ttrwhs: ttrrti) ttstp;
          if %eof(ttstp);
            leave;
          endif;

          chain (ttpwhs: ttprti: ttpstp) ttstpext;

          clear ttperec;
          ttpewhs = ttpwhs;
          ttperti = ttprti;
          ttpestp = ttpstp;

          // Stop fields

          ttpesrs = CreateStamp(ttpsrd: ttpsrt);
          ttpefis = CreateStamp(ttpfid: ttpfit);
          ttpesec = CalcSeconds(ttpesrs: ttpefis);
          ttpepcs += ttpqs1 + ttpqs2 + ttpqs3
                  +  ttpqn1 + ttpqn2 + ttpqn3;
720aD     //      +  ttpqc1 + ttpqc2 + ttpqc3;
          if ttpesec > 0;
            ttpepph = ttpepcs / (ttpesec/3600);
          endif;

          // Route fields

          if ttpsrd > 0 and ttpsrt = 0;
            ttrecurstp = ttpstp;
            ttrecurstr = ttpesrs;
          endif;

          if ttpsrd > 0 and ttpsrt > 0;
            ttrelststp = ttpstp;
            ttrelststr = ttpesrs;
            ttrelstend = ttpefis;
            ttrelstsec = ttpesec;
720bA       chktotsec += ttrelstsec;
720bA       if chktotsec > 999999;
720bA          ttrestpsec = 9999999;
720bA       else;
               ttrestpsec += ttrelstsec;
720bA       endif;
            ttrecmppcs += ttpepcs;
            if ttrestpsec > 0;
              ttrepph = ttrecmppcs / (ttrestpsec/3600);
            endif;
          endif;

          // Write/Update record

          if not %found(ttstpext);
            ttpewhs = ttpwhs;
            ttperti = ttprti;
            ttpestp = ttpstp;
            write ttperec;

          else;
            update ttperec;

          endif;

        enddo;



        return;
      /end-free
     p                 e

