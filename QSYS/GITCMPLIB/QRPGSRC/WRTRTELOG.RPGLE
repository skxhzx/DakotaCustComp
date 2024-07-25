      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  WRTRTELOG - Create Global Route Log records
     *
     *  25 March  2013
     *  Jeffrey Jahnke
     *
     *  Revisions
     *
650aA*    03/25/13  JCJ  6.50a
     *      - Created
     *
710aA*    12/30/17  NLK  7.10a (USF 700a)
     *      - Manually open files, leave if error.
     *      - Modified to write log if type 5 coming from CHKIUSE2
     *
720aA*    10/06/18  DAS  7.20a
     *      - Added Type 6, originally for DD420.
     *      - Revised to not write Type 4 rec if no JQ stamp.
     *
730 A*    10/15/19  KDE  7.30
     *      - Do not set lr to keep this open
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Types
     *
     *   1 = Start
     *   2 = Stop
     *   3 = Process total
     *   4 = Grand total (Process plus Jobq)
     *   5 = Info
720aA*   6 = Record minutes only
     *
     *   2=Stop is used for minor steps, like OR610 and OR620.
     *   3=Process is used for major processes, like ALOCBLD.
     *
     *  Tracking Jobq time
     *
     *   When submitting job, call with ...
     *     Type = 1
     *     Group would be Process group, like ALOCBLD.
     *     Subgroup would be JQxxxx, where xxxx is the jobq being used
     *     The id that is passed back needs to be added to the submit
     *
     *   When submitted program start to run, call with ...
     *     Type = 2
     *     Use Group/Subgroup/id from above.
     *
     *
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fglortelog o    e             disk
     Fglortelog1uf   e           k disk    rename(grlrec:grlrc1)
710aAF                                     usropn
     Fglortelog2if   e           k disk    rename(grlrec:grlrc2)
710aAF                                     usropn

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getclien

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------
      /copy qcopysrc,id#usfcorp

     *----------------------------------------------------------------
     *  Data Structures
     *----------------------------------------------------------------

     D                 ds
     D  stamp20                1     20  0
     D  stamp7                14     20  0

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables.
     *----------------------------------------------------------------

     D client          s             10
     D clientloc       s             10
     D durmin          s              7  2
     D $pbrnch         s              2
     D error           s               n
     D forever         s               n
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D  noStamp        s               z   inz(z'0001-01-01-00.00.00.000000')

     D savfts          s               z
     D savfuc          s               z
     D keyfts          s               z
     D keyfuc          s               z
710aAD openglortelog1  s               n
710aAD openglortelog2  s               n

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pwhse     warehouse
     *      $prtid     route id
     *      $pmrid     multi route id
     *      $pgrpid    group id
     *      $pgrpcode  group code
     *      $psubgrp   sub group code
     *      $ptype     type
     *      $pcurusr   current user
     *
     *    Returned Parameters
     *      $PRTN   *ERROR   - Error occurred.
     *              *OK      - No problems encountered.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $pmrid           26
     C                   parm                    $pgrpid           7 0
     C                   parm                    $pgrpcode        10
     C                   parm                    $psubgrp         12
     C                   parm                    $ptype            1
     C                   parm                    $pcurusr         10
     C                   parm                    $ppgm            10
     C                   parm                    $jobqts          26
     C                   parm                    $jobquc          26
720aAC                   parm                    $pmin             7 2

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free
         exsr getcurrstamp;

         getclient(client: clientLoc);
          if client = usfcorp;
            $pbrnch = %trim(clientloc);
          endif;

         // Initialize group id if not sent in.
         // Group Id not implemented yet.

720aD    //if $pgrpid = 0;
720aM    if $pgrpid = 0 and $ptype <> '6';
             stamp20 = %dec(currstampsys);
             $pGrpId = stamp7;
         //$pgrpid = 0;
         endif;

         // Initialize current user if not sent in.

         if $pcurusr = ' ';
           $pcurusr = #curruser;
         endif;

         select;
           when $ptype = '1';
             exsr post1;
           when $ptype = '2';
             exsr post2;
           when $ptype = '3';
             exsr post3;
710aA      when $ptype = '5';
710aA        exsr post5;
720aA      when $ptype = '6';
720aA        exsr post6;
         endsl;

730 D      // *inlr = *on;
730 A      return;

      /end-free

     *----------------------------------------------------------------
     *  fileclose  Close file glortelog1 and glortelog2
     *----------------------------------------------------------------

      /free
710aA  begsr fileClose;

         if %open(glortelog1);
           close(e) glortelog1;
           if %error;
             error = *on;
           endif;
         endif;

         if %open(glortelog2);
           close(e) glortelog2;
           if %error;
             error = *on;
           endif;
         endif;


       endsr;
      /end-free

     *----------------------------------------------------------------
     *  fileopenG1   Open file glortelog1
     *----------------------------------------------------------------

      /free
710aA  begsr fileOpenG1;

         if not %open(glortelog1);
           open(e) glortelog1;
           if %error;
             error = *on;
           endif;
         endif;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  fileopenG2   Open file glortelog2
     *----------------------------------------------------------------

      /free
710aA  begsr fileOpenG2;

         if not %open(glortelog2);
           open(e) glortelog2;
           if %error;
             error = *on;
           endif;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     * SR Post1 - Post type 1 record
     *----------------------------------------------------------------

      /free
       begsr post1;

          // Write new record

          clear grlrec;

          grlwhse = $pwhse;
          if client = usfcorp;
            grlbrnch = %trim(clientloc);
          endif;
          grlrtid = $prtid;
          grlmrid = $pmrid;
          grlgrpid = $pgrpid;
          grlgrpcode = $pgrpcode;
          grlsubgrp = $psubgrp;
          grltype = $ptype;
          grlstat = 1;

          grlfts = currstampsys;
          grlfuc = currstampuc;

          grladdts = currstampsys;
          grladduc = currstampuc;
          grlcurusr = $pcurusr;
          grlpgm = $ppgm;
          grljobusr = #user;
          grljob = #job;
          grljobnbr = #jobnbr;

          write grlrec;

          $jobqts = %char(noStamp);
          $jobquc = %char(noStamp);
         if %subst($psubgrp:1:2) = 'JQ';
          $jobqts = %char(currstampsys);
          $jobquc = %char(currstampuc);
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     * SR Post2 - Post type 2 record
     *----------------------------------------------------------------

      /free
       begsr post2;

710aA    // Open glortelog1 file
710aA
710aA    exsr fileOpenG1;
710aA    if error;
710aA        leavesr;
710aA    endif;

          // Get corresponding type 1 record.

          chain ($pwhse: $pbrnch: $prtid: $pmrid: $pgrpid: $pgrpcode: $psubgrp)
                glortelog1;
          if %found(glortelog1);
            grlstat = 0;
            savfts = grlfts;
            savfuc = grlfuc;
            update grlrc1;
          else;
            savfts = nostamp;
            savfuc = nostamp;
          endif;

          // Write new record

          clear grlrec;

          grlwhse = $pwhse;
          if client = usfcorp;
            grlbrnch = %trim(clientloc);
          endif;
          grlrtid = $prtid;
          grlmrid = $pmrid;
          grlgrpid = $pgrpid;
          grlgrpcode = $pgrpcode;
          grlsubgrp = $psubgrp;
          grltype = $ptype;
          grlstat = 0;

          grlfts = savfts;
          grlfuc = savfuc;
          grltts = currstampsys;
          grltuc = currstampuc;

          grladdts = currstampsys;
          grladduc = currstampuc;
          grlcurusr = $pcurusr;
          grlpgm = $ppgm;
          grljobusr = #user;
          grljob = #job;
          grljobnbr = #jobnbr;

          durmin = durmints(%len(durmin):grlfts:grltts);
          grltim = durmin;

          write grlrec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     * SR Post3 - Post type 3 record
     *----------------------------------------------------------------

      /free
       begsr post3;

710aA    // Open glortelog1 file
710aA
710aA    exsr fileOpenG1;
710aA    if error;
710aA        leavesr;
710aA    endif;

          // Get corresponding type 1 record.

          $psubgrp = *blanks;
          chain ($pwhse: $pbrnch: $prtid: $pmrid: $pgrpid: $pgrpcode: $psubgrp)
                glortelog1;
          if %found(glortelog1);
            grlstat = 0;
            savfts = grlfts;
            savfuc = grlfuc;
            update grlrc1;
          else;
            savfts = nostamp;
            savfuc = nostamp;
          endif;

          // Write new record

          clear grlrec;

          grlwhse = $pwhse;
          if client = usfcorp;
            grlbrnch = %trim(clientloc);
          endif;
          grlrtid = $prtid;
          grlmrid = $pmrid;
          grlgrpid = $pgrpid;
          grlgrpcode = $pgrpcode;
          grlsubgrp = *blanks;
          grltype = '3';
          grlstat = 0;

          grlfts = savfts;
          grlfuc = savfuc;
          grltts = currstampsys;
          grltuc = currstampuc;

          grladdts = currstampsys;
          grladduc = currstampuc;
          grlcurusr = $pcurusr;
          grlpgm = $ppgm;
          grljobusr = #user;
          grljob = #job;
          grljobnbr = #jobnbr;

          durmin = durmints(%len(durmin):grlfts:grltts);
          grltim = durmin;

          write grlrec;

          // Now write type 4 record.

          exsr post4;

       endsr;
      /end-free

     *----------------------------------------------------------------
     * SR Post4 - Post type 4 record
     *----------------------------------------------------------------

      /free
       begsr post4;

710aA    // Open glortelog2 file
710aA
710aA    exsr fileOpenG2;
710aA    if error;
710aA        leavesr;
710aA    endif;

          // Get corresponding type 1 jobq record.

          $psubgrp = *blanks;

          if $jobqts = *blanks;
            keyfts = noStamp;
720aA       leavesr;
          endif;

          if $jobquc = *blanks;
            keyfuc = noStamp;
          endif;

          keyfts = %timestamp($jobqts);
          keyfuc = %timestamp($jobquc);

          chain ($pwhse: $pbrnch: $prtid: $pgrpid: $pgrpcode: keyfts: keyfuc)
                glortelog2;
          if %found(glortelog2);
            savfts = grlfts;
            savfuc = grlfuc;
          endif;

          // Write new record

          clear grlrec;

          grlwhse = $pwhse;
          if client = usfcorp;
            grlbrnch = %trim(clientloc);
          endif;
          grlrtid = $prtid;
          grlmrid = $pmrid;
          grlgrpid = $pgrpid;
          grlgrpcode = $pgrpcode;
          grlsubgrp = *blanks;
          grltype = '4';
          grlstat = 0;

          grlfts = savfts;
          grlfuc = savfuc;
          grltts = currstampsys;
          grltuc = currstampuc;

          grladdts = currstampsys;
          grladduc = currstampuc;
          grlcurusr = $pcurusr;
          grlpgm = $ppgm;
          grljobusr = #user;
          grljob = #job;
          grljobnbr = #jobnbr;

          durmin = durmints(%len(durmin):grlfts:grltts);
          grltim = durmin;

          write grlrec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     * SR Post5 - Post type 5 record
     *----------------------------------------------------------------

      /free
710aA  begsr post5;

          // Write new record

          clear grlrec;

          grlwhse = $pwhse;
          if client = usfcorp;
            grlbrnch = %trim(clientloc);
          endif;
          grlrtid = $prtid;
          grlmrid = $pmrid;
          grlgrpid = $pgrpid;
          grlgrpcode = $pgrpcode;
          grlsubgrp = $psubgrp;
          grltype = $ptype;
          grlstat = 1;

          grlfts = currstampsys;
          grlfuc = currstampuc;

          grladdts = currstampsys;
          grladduc = currstampuc;
          grlcurusr = $pcurusr;
          grlpgm = $ppgm;
          grljobusr = #user;
          grljob = #job;
          grljobnbr = #jobnbr;

          write grlrec;

       endsr;
      /end-free

720aA*----------------------------------------------------------------
720aA* SR Post6 - Post type 6 record
720aA*----------------------------------------------------------------
720aA
720aA /free
720aA  begsr post6;

          // Write new record

          clear grlrec;

          grlwhse = $pwhse;
          if client = usfcorp;
            grlbrnch = %trim(clientloc);
          endif;
          grlrtid = $prtid;
          grlmrid = $pmrid;
          grlgrpid = $pgrpid;
          grlgrpcode = $pgrpcode;
          grlsubgrp = $psubgrp;
          grltype = $ptype;
          grlstat = 1;

          grlfts = nostamp;
          grlfuc = nostamp;
          grltts = nostamp;
          grltuc = nostamp;

          grladdts = currstampsys;
          grladduc = currstampuc;
          grlcurusr = $pcurusr;
          grlpgm = $ppgm;
          grljobusr = #user;
          grljob = #job;
          grljobnbr = #jobnbr;

          grltim = $pmin;

          write grlrec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

      /free
       begsr getCurrStamp;

         getmicrotime(currstampuc:currstampsys);

       endsr;
      /end-free
