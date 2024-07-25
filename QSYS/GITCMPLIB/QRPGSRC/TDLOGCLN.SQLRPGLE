      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     * Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     * BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  TDLOGCLN   WRTTRAND log file cleanup
     *  Dave Sommerville
     *  18 February 2012
     *
     *  Revisions
     *
     *    02/18/12  DAS  6.40
     *      - Created.
     *
     *----------------------------------------------------------------

     *------------------------------------------------------------------
     * Misc defs ...
     *------------------------------------------------------------------

     D $phist2keep     s              4  2
     D stamp           s               z

     D                 ds
     D  dayshours              1      4
     D  days                   1      2  0
     D  hours                  3      4  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $phist2keep  Number of Days.Hours to keep.
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $phist2keep

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     *  Extract hours and minutes to keep.

     C                   move      $phist2keep   dayshours

     *  Calculate oldest date/time to keep.

     C                   time                    stamp
     C                   subdur    days:*D       stamp
     C                   subdur    hours:*H      stamp

     *  Delete records

     C/EXEC SQL
     C+  delete
500 MC+  from   logtrand
500 MC+  where  ltdttlbeg < :stamp
     C/END-EXEC

     C                   eval      *inlr = *on
     C                   return
