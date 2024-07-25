      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  CRTSTATLBL  Create STATLBL records for LABEL
     *  04 April 2008
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    04/04/08  DAS  5.20
     *      - Created.
     *
650aA*    06/05/14  RTR  6.50a
     *      - Added fields for PIRCLIENT/PIRCLIENT2.
     *      - Added fields for library/file.
     *      - Changed run date/time to timestamp.
     *      - Delete old records first, no history wanted at this time.
     *
650bA*    01/02/15  DAS  6.50b
     *      - Added file LABELH
     *
     *----------------------------------------------------------------

650aAflabel     if   e             disk    infds(file1ds)
650bAflabelh    if   e             disk    infds(file2ds)
650bAF                                     rename(lbrec:lbrech)

650aA*----------------------------------------------------------------
650aA*  File data data structure
650aA*----------------------------------------------------------------
650aA /copy qcopysrc,c#file1ds
650bA /copy qcopysrc,c#file2ds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

650aDD*curDate         s              8  0
650aDD*curTime         s              6  0

650aDD*$cvtdt          ds
650aDD* $cvcmd                 1      8
650aDD* $cvprg                 9     18
650aDD* $cvd6i                19     24
650aDD* $cvd8i                25     32
650aDD* $cvd6o                33     38  0
650aDD* $cvd8o                39     46  0
650aDD* $cvsto                47     64
650aDD* $cvrtn                65     72
650aDD* $cverm                73    132
650aDD* $cvmsg                73     76

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

650aDD*                  eval      $cvcmd = '*CURCMD '
650aDD*                  call      'CVTDTE'
650aDD*                  parm                    $cvtdt
650aDD*                  eval      curDate = $cvd8o
650aDD*                  time                    curTime

650aDc*/exec sql
650aDc*+  INSERT into statlbl (stdate,sttime,sttype,stgrp1,stgrp2,ststat,
650aDc*+  stfrom,stto,strecs)
650aDc*+  SELECT :curDate,:curTime,lbtype,lbgrp1,lbgrp2,lbstat,min(lbrdte),
650aDc*+  max(lbrdte),count(*)
650aDc*+  FROM label
650aDc*+  GROUP BY lbtype,lbgrp1,lbgrp2,lbstat
650aDc*+  ORDER BY lbtype,lbgrp1,lbgrp2,lbstat
650aDc*/end-exec

650aAc                   call      'GETCLIENT'
650aAc                   parm                    pclient          10
650aAc                   parm                    pclient2         10

650aA /free
650aA   exec sql DELETE from statlbl;

650aA   exec sql
650aA     INSERT into statlbl
650aA       (stclient, stclient2, stlib, stfile, stadded, sttype,
650aA        stgrp1, stgrp2, ststat, stfrom, stto, strecs)
650aA     SELECT :pclient, :pclient2, :f1library, :f1filename,
650aA       CURRENT_TIMESTAMP, lbtype, lbgrp1, lbgrp2,
650aA       lbstat, min(lbrdte), max(lbrdte), count(*)
650aA     FROM label
650aA     GROUP BY lbtype,lbgrp1,lbgrp2,lbstat
650aA     ORDER BY lbtype,lbgrp1,lbgrp2,lbstat;

650bA   exec sql
650bA     INSERT into statlbl
650bA       (stclient, stclient2, stlib, stfile, stadded, sttype,
650bA        stgrp1, stgrp2, ststat, stfrom, stto, strecs)
650bA     SELECT :pclient, :pclient2, :f2library, :f2filename,
650bA       CURRENT_TIMESTAMP, lbtype, lbgrp1, lbgrp2,
650bA       lbstat, min(lbrdte), max(lbrdte), count(*)
650bA     FROM labelh
650bA     GROUP BY lbtype,lbgrp1,lbgrp2,lbstat
650bA     ORDER BY lbtype,lbgrp1,lbgrp2,lbstat;

        *inlr = *on;
650aA /end-free
