      /copy qcopysrc,hspecs
     h dftactgrp(*NO) actgrp(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  IT983S   Staging Item Quantity Comparison - GUI By License
     *  October 22, 2019
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *
730  *    10/22/19  RTR  7.30
     *      - Created from IT982S, mods removed since it is large change.
740a *    05/14/20  RTR  7.40a
     *      - Change to exclude false zero licenses from host.
750a *    07/10/21  DAS  7.50a
     *      - Revised to update text when match with LICACTIVE in
     *        first pass.
     *      - Revised text being written in second pass.
     *
     *----------------------------------------------------------------
     * File Specs
     *
     fimpscqtyl1uf a e           k disk    prefix(erp_)
     fpiritem   if   e           k disk
     flicactive if   e           k disk
     fit981lic  o  a e           k disk
     *----------------------------------------------------------------
     *  Customer ids
     *----------------------------------------------------------------
     *  Program info data structure
      /copy qcopysrc,c#pgminfds
     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy qcopysrc,c#stdvar
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
      /copy qcopysrc,c#stdsql
     *----------------------------------------------------------------
     *  Called Program Prototypes
      /copy qcopysrc,p.qcmdexc

     *----------------------------------------------------------------
     *  Working Variables
     d clen            s             15p 5
     d cmd             s           3000a
     d foundlic        s               n
     d len             s              1p 0
     d reccnt          s              6s 0
     d txtcnt          s            200a
     d savts           s               z
     d whs#            s              3  0
     d work3a          s              3
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $whse   Warehouse
     *      $batch  Batch ID
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     c     *entry        plist
     c                   parm                    $whse             3
     c                   parm                    $batch           11
     *
     * Main line
     *
      /free

        // Whip through all the active license records
        setll (whs#: ' ') licactive;
        dow forever = forever;
          reade (whs#) licactive;
          error = *off;
          if %eof(licactive);
            leave;
          endif;

          // Get matching import license record
          chain (whs#: $batch: lalcns) impscqtyl1;
          if not %found(impscqtyl1);
            erp_icitem = *blanks;
            erp_ictqh1 = 0;
            erp_ictqh2 = 0;
            erp_ictqh3 = 0;
            foundlic = *off;
          else;
            foundlic = *on;
          endif;

750aA     erp_ictext = 'LICACTIVE match (' + %trim(laitem) + ')';

          // Calculate differences between host and Dakota qtys
          exsr zzcalc;

          // Write detail
          if difsrt <> 0;

            // Get item info
            chain (lawhse: laitem) piritem;
            if not %found();
              itdesc = '*** Item not found ***';
              ittype = *blanks;
            endif;

            crwhse = lawhse;
            critem = erp_icitem;
            crwhdp = lawhdp;
            crdesc = itdesc;
            crdisp = ladisp;
            crbatch = $batch;
            craddts = savts;
            ictqh1 = erp_ictqh1;
            ictqh2 = erp_ictqh2;
            ictqh3 = erp_ictqh3;
            crtype = ittype;
            crstatus = *blanks;
            crlcns = lalcns;
            crlitem = laitem;
740aA       // if host has different item and no qty, skip difference.
740aA       if critem <> crlitem
740aA        and ictqh1 = 0 and ictqh2 = 0 and ictqh1 = 0;
740aA         erp_ictext = 'Host ghost license.';
740aA       else;
              write wkrec;
              reccnt = reccnt + 1;
              erp_ictext = 'Difference found.';
740aA       endif;
          endif;
          erp_icstatus = 'S';
          if foundlic;
            update icrec;
          endif;
        enddo;

        // Whip through the remaining import records
        setll (whs#: $batch) impscqtyl1;
        dow forever = forever;
          reade (whs#: $batch) impscqtyl1;
          error = *off;
          if %eof(impscqtyl1);
            leave;
          endif;

          // Skip processed records
          if erp_icstatus <> 'R';
            iter;
          endif;

          // Look for matching licactive record, if not found, write
          chain (whs#: erp_iclcns) licactive;
750aA     erp_ictext = 'License found in LICACTIVE - Do nothing';
          if not %found(licactive);
750aA       erp_ictext = 'License not in Dakota - Host qty zero';
            laqty1 = 0;
            laqty2 = 0;
            laqty3 = 0;
            exsr zzcalc;
            if difsrt <> 0;
              crwhse = erp_icwhse;
              critem = erp_icitem;
              crwhdp = *blanks;
              crdesc = '*** Item not found ***';
              crdisp = *blanks;
              ictqh1 = erp_ictqh1;
              ictqh2 = erp_ictqh2;
              ictqh3 = erp_ictqh3;
              craddts = savts;
              crtype = *blanks;
              crstatus = *blanks;
              crlcns = erp_iclcns;
              crlitem = *blanks;
              write wkrec;
              reccnt = reccnt + 1;
750aA         erp_ictext = 'License not in Dakota.';
            endif;
          endif;
750aD     //erp_ictext = 'License not in Dakota.';
          erp_icstatus = 'S';
          update icrec;
        enddo;

        // All done, mark records as processed.
        exec sql
          update stgbatch
          set sbstatus = 'S',
              sbtext   = 'Comparison report has been generated.',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone,
              sbendts  = current_timestamp,
              sbenduc  = current_timestamp - current_timezone
          where sbwhse = :$whse
            and sbbatid = :$batch;

        if sqlstt <> sqlSuccess;   // send error message
          cmd = 'SNDMSG MSG('+ sq + 'ERROR: IT981S Comparison Report '
              + sqlstt + ' in staging batch ID ' + $batch
              + sq + ') TOUSR(*SYSOPR)';
          clen = %len(cmd);
          qcmdexc(cmd: clen);
        else;
         txtcnt = %char(reccnt) + ' differences found.';
         exec sql
          update it981idx
             set cxtext = :txtcnt
           where cxbatch = :$batch;
        endif;

        *inlr = *on;

      /end-free
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     c     *inzsr        begsr
     *
     * Get client id.
     *
     c                   call      'GETCLIENT'
     c                   parm                    client           10
     c                   parm                    clientloc        10
     *
     c                   monitor
     c                   eval      whs# = %dec($whse: 3: 0)
     c                   on-error
     c                   eval      error = *on
     c                   endmon
     *
     c                   eval      savts = %timestamp()
     *
      /free
        exec sql
          insert into it981idx
            values (:$whse,:$batch,:savts,'Processing...');
      /end-free
     *
     c                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCALC   Calculate differences between host and Dakota qty's
     *
     c     zzcalc        begsr
     *
     c                   eval      diff1 = erp_ictqh1 - laqty1
     c                   eval      diff2 = erp_ictqh2 - laqty2
     c                   eval      diff3 = erp_ictqh3 - laqty3
     *
     c                   if        diff1 < 0
     c                   eval      difsrt = (diff1 * -1)
     c                   else
     c                   eval      difsrt = diff1
     c                   endif
     c                   if        diff2 < 0
     c                   eval      difsrt = difsrt + (diff2 * -1)
     c                   else
     c                   eval      difsrt = difsrt + diff2
     c                   endif
     c                   if        diff3 < 0
     c                   eval      difsrt = difsrt + (diff3 * -1)
     c                   else
     c                   eval      difsrt = difsrt + diff3
     c                   endif
     *
     c                   endsr
     *
