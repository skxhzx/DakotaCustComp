      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  IT974   Item Quantity Compare Report - Print by Diff Abs Val
     *  24 November 2014
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *
650  *    11/24/14  RTR  6.50
     *      - Created from IT972 to print file created from IT972.
650b *    01/20/15  RTR  6.50b
     *      - Removed test for all zero differences, and added count.
650c *    01/21/15  RTR  6.50c
     *      - Rewrote using RPG file handling instead of SQL.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     * File Specs
     *
650cAFit972f    if   e           k disk
     Freports   if   e           k disk
     Fwarehs    if   e           k disk
     Fit974pr   o    e             printer oflind(*in91)
     *----------------------------------------------------------------
     *  Customer id
     *
      /copy qcopysrc,id#pfc

     *----------------------------------------------------------------
     *  Standard variables and constants
     *
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             60    dim(1) ctdata perrcd(1)
     D comprec       e ds                  extname(it972f) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Working Variables
     *
     D count           s              3  0
     D first           s              1
     D len             s              1  0
     D linppg          s              3  0
     D pflag           s              1
     D pos             s              1  0
     D whs#            s              3  0
     D work3a          s              3
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $stamp  Timestamp to print
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     D main            pr                  extpgm('IT974')
     D   pwhse                        3
     D   pstamp                      26

     D main            pi
     D   pwhse                        3
     D   pstamp                      26
     *----------------------------------------------------------------
     *
     *  Let the show begin .....
     *
     * Main line
     *
      /free

        // Select records to print
        exec Sql
          declare items cursor for
            select * from it972f
             where addts = :pstamp
             order by difsrt desc, diff2 desc, ititem;

        exec sql open items;
        if sqlstt <> sqlSuccess;
        endif;
650bA   reccnt = 0;

        dow forever = forever;

          // Read next slot record.
          exec sql fetch next from items
                         into :comprec;

          // If no more, you are done.
          if sqlstt <> sqlSuccess;
            leave;
          endif;

          // First time through
          if first = *on;
            exsr zzinz2;
            first = *off;
          endif;

650bA   //if diff1 = 0 and diff2 = 0 and diff3 = 0;
650bA   //  iter;
650bA   //endif;

          // Write detail
          if *in91 = *on;
            write head1;
            *in91 = *off;
          endif;

          iqitem = ititem;
          write detail;
650bA     reccnt = reccnt + 1;

        enddo;

        // Print grand totals
        if *in91 = *on;
          write head1;
        endif;
        write foot1;

        // We are finished so get out
        exec sql close items;
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
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     *
     *  Variables and constants.
     *
     C                   eval      forever = *off
     C                   eval      first = *on
     C                   move      pwhse         whs#
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     * Get report heading.
     *
     C                   eval      rdate = %dec(%char(%date():*mdy0):6:0)
     C                   eval      rtime = %dec(%char(%time():*hms0):6:0)
     C                   eval      w1head = *blanks
     C                   movel     'IT974PR'     rpprtf
     C     rpprtf        chain     reports                            79
     C                   if        not *in79
     C                   movel     rpdesc        $pstr
     C                   else
     C                   eval      $pstr = desc(1)
     C                   endif
     C                   eval      $plen = 60
     *
     C                   call      'CENTER'
     C                   parm                    $pstr            60
     C                   parm                    $plen             3 0
     C                   movel     $pstr         w1head
     *
     *   Get warehouse description.
     *
     C     whs#          chain     warehs
     C                   if        not %found(warehs)
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *   Create warehouse heading.
     *
     C                   move      whs#          work3a
     C     ' 0'          check     work3a        pos
     C                   if        pos = 0
     C                   eval      pos = 1
     C                   endif
     C                   eval      len = 4 - pos
     C     len           subst     work3a:pos    whhead
     C     whhead        cat       '-':1         whhead
     C     whhead        cat       whdesc:1      whhead
     C                   call      'CENTER'
     C                   parm      whhead        $cstr            60
     C                   parm      40            $clen             3 0
     C                   movel     $cstr         whhead
     *
     *   Write headings
     *
     C                   write     head1
     *
     *   Get options.
     *
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *  Compile Time Tables
**
Item Quantity Compare Report
