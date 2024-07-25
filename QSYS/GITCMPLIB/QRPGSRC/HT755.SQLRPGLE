     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2004')

     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  HT755     Remove Daily Hit Records - Post
     *  Dave Sommerville
     *  19 August 2004
     *
     *  Revisions
     *
416 A*    08/19/04  DAS  4.17
     *      - Created.
720aA*    08/29/18  LMC  7.20a
     *      - Fix: Purging based on the week, removes the current
     *        years data and does not keep the number of weeks the
     *        client has set in daily hits history options.
     *
750aA*    01/28/21  RBD  7.50a
     *      - Added purge of DLYHIT file.
     *
     *----------------------------------------------------------------

     *------------------------------------------------------------------
     * Variables
     *------------------------------------------------------------------

     D datefld         s               d
720aAD shiftDOW        s              1s 0
720aAD shiftWeek       s              2s 0
720aAD shiftSunday     s              8s 0
720aAD sundaydate      s               d
750aAD shiftSunday6    s              6s 0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pwhse        Warhouse
     *      $pdate        Oldest date to keep.
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $ppgm            10
416aAC                   parm                    $pwhsea           3
416aAC                   parm                    $pdatea           8

416aAC                   move      $pwhsea       $pwhse            3 0
416aAC                   move      $pdatea       $pdate            8 0
     C     *ISO          move      $pdate        datefld
720aA /free
720aA   exec sql set :shiftWeek = week(:datefld),
720aA                :shiftDOW  = dayofweek(:datefld);

720aA   sundayDate = datefld - %days(shiftDOW-1);
720aA   shiftsunday = %dec(%char(sundaydate:*iso0):8:0);
750aA   shiftsunday6 = %dec(%char(sundaydate:*ymd0):6:0);
720aA /end-free

     *----------------------------------------------------------------
     *  Delete records
     *----------------------------------------------------------------

     C/EXEC SQL
     C+  delete
     C+  from   dlyhits
720aDC*+  where  htwhse = :$pwhse and htweek < week(:datefld)
720aMC+  where  htwhse = :$pwhse and  htbegdte < :shiftsunday
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     C/EXEC SQL
     C+  delete
     C+  from   dlyhitr
720aDC*+  where  hrwhse = :$pwhse and hrweek < week(:datefld)
720aMC+  where  hrwhse = :$pwhse and  hrbegdte < :shiftsunday
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     C/EXEC SQL
     C+  delete
     C+  from   dlyzror
720aDC*+  where  hzwhse = :$pwhse and hzweek < week(:datefld)
720aMC+  where  hzwhse = :$pwhse and  hzbegdte < :shiftsunday
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

750aAC/EXEC SQL
750aAC+  delete
750aAC+  from   dlyhit
750aAC+  where  htwhse = :$pwhse and  htshftday < :shiftsunday6
750aAC/END-EXEC
750aAC                   if        sqlstt <> '00000'
750aAC                   endif

     C                   eval      *inlr = *on
     C                   return
