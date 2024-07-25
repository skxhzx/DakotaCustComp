      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  CRTSTATTRN  Create STATTRN records
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
     *      - Added file PIRTRANH
     *
     *----------------------------------------------------------------

650aAfpirtran   if   e             disk    infds(file1ds)
650aAfpirtrand  if   e             disk    infds(file2ds)
650bAfpirtranh  if   e             disk    infds(file14ds)
650bAF                                     rename(ptrec:ptrech)

650aA*----------------------------------------------------------------
650aA*  File data data structure
650aA*----------------------------------------------------------------
650aA /copy qcopysrc,c#file1ds
650aA /copy qcopysrc,c#file2ds
650bA /copy qcopysrc,c#file14ds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D*curDate         s              8  0
     D*curTime         s              6  0

     D*$cvtdt          ds
     D* $cvcmd                 1      8
     D* $cvprg                 9     18
     D* $cvd6i                19     24
     D* $cvd8i                25     32
     D* $cvd6o                33     38  0
     D* $cvd8o                39     46  0
     D* $cvsto                47     64
     D* $cvrtn                65     72
     D* $cverm                73    132
     D* $cvmsg                73     76

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

650aDC*                  eval      $cvcmd = '*CURCMD '
650aDC*                  call      'CVTDTE'
650aDC*                  parm                    $cvtdt
650aDC*                  eval      curDate = $cvd8o
650aDC*                  time                    curTime

650aDc*/exec sql
650aDc*+  INSERT into stattrn (stdate,sttime,sttask,stcat,stsub,ststat,
650aDc*+  stfrom,stto,strecs)
650aDc*+  SELECT :curDate,:curTime,pttask,ptcat,ptsub,ptstat,min(ptgdte),
650aDc*+  max(ptgdte),count(*)
650aDc*+  FROM pirtran
650aDc*+  GROUP BY pttask,ptcat,ptsub,ptstat
650aDc*+  ORDER BY pttask,ptcat,ptsub,ptstat
650aDc*/end-exec

650aAc                   call      'GETCLIENT'
650aAc                   parm                    pclient          10
650aAc                   parm                    pclient2         10

650aA /free
650aA   exec sql DELETE from stattrn;

650aA   exec sql
650aA     INSERT into stattrn
650aA       (stclient, stclient2, stlib, stfile, stadded, sttask,
650aA        stcat, stsub, ststat, stfrom, stto, strecs)
650aA     SELECT :pclient, :pclient2, :f1library, :f1filename,
650aA       CURRENT_TIMESTAMP, pttask, ptcat, ptsub,
650aA       ptstat, min(ptgdte), max(ptgdte), count(*)
650aA     FROM pirtran
650aA     GROUP BY pttask,ptcat,ptsub,ptstat
650aA     ORDER BY pttask,ptcat,ptsub,ptstat;

650aA   exec sql
650aA     INSERT into stattrn
650aA       (stclient, stclient2, stlib, stfile, stadded, sttask,
650aA        stcat, stsub, ststat, stfrom, stto, strecs)
650aA     SELECT :pclient, :pclient2, :f2library, :f2filename,
650aA       CURRENT_TIMESTAMP, ptdtask, ' ', ' ',
650aA       ptdstat, min(ptdgdte), max(ptdgdte), count(*)
650aA     FROM pirtrand
650aA     GROUP BY ptdtask,ptdstat
650aA     ORDER BY ptdtask,ptdstat;

650bA   exec sql
650bA     INSERT into stattrn
650bA       (stclient, stclient2, stlib, stfile, stadded, sttask,
650bA        stcat, stsub, ststat, stfrom, stto, strecs)
650bA     SELECT :pclient, :pclient2, :f14library, :f14filename,
650bA       CURRENT_TIMESTAMP, pttask, ptcat, ptsub,
650bA       ptstat, min(ptgdte), max(ptgdte), count(*)
650bA     FROM pirtranh
650bA     GROUP BY pttask,ptcat,ptsub,ptstat
650bA     ORDER BY pttask,ptcat,ptsub,ptstat;

650aM   *inlr = *on;
650aA /end-free
