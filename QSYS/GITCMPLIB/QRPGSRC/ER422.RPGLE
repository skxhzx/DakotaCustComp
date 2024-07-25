      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ER422     Total thru-put
     *  03 October, 2000
     *  Hemant Kapadia
     *
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
     *  10/03/00  HNK  4.14
     *  - Created
     *
     *  07/22/09   GJA  5.30
     *     -Enh:  Convert to RPGLE, cleaned up and revamped for
     *               suspended transactions
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Not on file/End of file indicator
     *  90        Overflow Indicator
     *  9X        Top of page and level X continues.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fer4222    ip   e           k disk
     F                                     rename(errec:errec1)
     Freporte   if   e           k disk
     Fer422pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *                   RPD     1   3 25
     D rpd             s             10    dim(3) ctdata perrcd(1)
     D reck            s              7  0 dim(3)
     D lvlk            s              7  0 dim(3)
     *
     D whd             s              5    dim(99)
     D sec             s              1    dim(99)
     D wds             s             12    dim(99)
     D pcs             s              7  0 dim(99)
     D tsk             s              6    dim(99)
     D hrs             s              7  2 dim(99)
     D pch             s              7  2 dim(99)
     *
     D whdt            s              5    dim(99)
     D pcst            s              7  0 dim(99)
     D hrst            s              9  2 dim(99)
     D pcht            s              9  2 dim(99)
     *
     D ptot            s              9  0 dim(99)
     D htot            s              9  2 dim(99)
     *
     D dte             s             22    dim(4) ctdata perrcd(1)
     D tme             s             22    dim(1) ctdata perrcd(1)
     D a22             s              1    dim(22)
530aAD mrg             s             45    dim(1) ctdata perrcd(1)
     *
     *----------------------------------------------------------------
     *ECORD
     *                                             ERSDTEL1
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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
     *  Date redefinition data structure
     *
     D $pfmdt          ds
     D  $pfmcc                 1      2
     D  $pfmyy                 3      4
     D  $pfmmm                 5      6
     D  $pfmdd                 7      8
     D $ptodt          ds
     D  $ptocc                 1      2
     D  $ptoyy                 3      4
     D  $ptomm                 5      6
     D  $ptodd                 7      8
     D $pbtim          ds
     D  $pbhrs                 1      2
     D  $pbmin                 3      4
     D  $pbsec                 5      6
     D $petim          ds
     D  $pehrs                 1      2
     D  $pemin                 3      4
     D  $pesec                 5      6
     *----------------------------------------------------------------
     *  Variables
     *
     D $plen           s              3  0
     D $pstr           s             60
     D begtim          s              6  0
     D endtim          s              6  0
     D first           s              1
     D hours           s              7  2
     D i               s              3  0
     D l               s              1  0
     D n               s              3  0
     D tmpwhd          s              5
     D wkprtf          s             10
     D w1wds           s             12
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PFMDT  From date (YYYYMMDD)
     *      $PTODT  To date (YYYYMMDD)
     *      $PWHSE  Warehouse number
     *      $PEMP#  Employee number
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pfmdt
     C                   parm                    $ptodt
     C                   parm                    $pwhse            3
     C                   parm                    $pbtim
     C                   parm                    $petim
530aAC                   parm                    $pmrg             1
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *
     *  Report Heading
     *
     *
     *  Start new page if one of following happened.
     *     - Overflow occurred.
     *
     C                   if        *in90  or
     C                             first = *on
     C                   exsr      zrfrmt
     C                   exsr      zrhead
     C                   endif
     *
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *
     C                   select
     C                   when      ertask <> 'IDLE  '
     *
     *  Accumulate totals
     *
     C     erdmin        div(h)    60            hours
     C                   eval      w1wds = *blanks
     C     erwhdp        cat       erstyp:0      w1wds
     C     w1wds         cat       ertask:0      w1wds
     C                   eval      n = 1
     C     w1wds         lookup    wds(n)                                 81
     *  Found
     C                   if        *in81
     C                   add       erpcs         pcs(n)
     C                   add       hours         hrs(n)
     C                   if        hrs(n) > 0
     C     pcs(n)        div       hrs(n)        pch(n)
     C                   endif
     *
     C                   else
     *  Not found
     C     *blanks       lookup    wds(n)                                 82
     C                   if        *in82
     C                   eval      wds(n) = w1wds
     C                   eval      whd(n) = erwhdp
     C                   eval      sec(n) = erstyp
     C                   eval      tsk(n) = ertask
     C                   eval      pcs(n) = erpcs
     C                   eval      hrs(n) = hours
     C                   if        hrs(n) > 0
     C     pcs(n)        div       hrs(n)        pch(n)
     C                   endif
     C                   endif
     C                   endif
     *
     C                   add       erpcs         ptot(1)
     C                   add       hours         htot(1)
     *
     *  Increment record counters
     *
     C                   add       1             reck(1)
     C                   add       1             lvlk(1)
     *
     C                   endsl
     *
     *  Set off top-of-page indicators
     *
     C                   eval      *in92 = *off
     C                   eval      *in91 = *off
     C                   eval      first = *off
     *----------------------------------------------------------------
     *
     * Totals
     *
     *    Headings not printed yet.
     CLr                 if        first = *on
     CLr                 exsr      zrfrmt
     CLr                 exsr      zrhead
     * Footer
     CLr                 write     skip1
     CLr                 write     foot2
     CLr                 write     foot1
     CLr                 else
     *
     CLr                 exsr      zrsumr
     CLr                 exsr      zrtotl
     * Summary totals
     CLr                 write     smhead
     CLr                 exsr      zrsumt
     CLr                 exsr      zrtotl
     * Footer
     CLr                 write     skip1
     CLr                 write     foot1
     CLr                 endif
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     C     rpkey         klist
     C                   kfld                    wkprtf
     *
     C                   move      $pbtim        begtim
     C                   move      $petim        endtim
     C                   time                    time
     C                   eval      first = *on
     C                   eval      l = 1
     C                   eval      n = 0
     C                   exsr      zrzero
530aAC                   if        $pmrg = 'N'
530aAC                   eval      mrgtxt = mrg(1)
530aAC                   else
530aAC                   eval      mrgtxt = *blanks
530aAC                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrfrmt        begsr
     *
     *   Format report title.
     *
     *  Get report title.
     *
     C                   movel     'ER422PR '    wkprtf
     C                   eval      rptttl = *blanks
     C     rpkey         chain     reporte                            79
     C                   if        not *in79
     C                   movel     erdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
     C                   eval      $plen = 60
     *
     *   Center report title.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   eval      rptttl = $pstr
     *
     *  Format date range
     *
     C                   select
     C                   when      $pfmdt <> *blanks  and
     C                             $ptodt <> *blanks
     C                   movea     dte(1)        a22
     C                   movea     $pfmmm        a22(1)
     C                   movea     $pfmdd        a22(4)
     C                   movea     $pfmyy        a22(7)
     C                   movea     $ptomm        a22(15)
     C                   movea     $ptodd        a22(18)
     C                   movea     $ptoyy        a22(21)
     C                   movea     a22           dterng
     *
     C                   when      $pfmdt <> *blanks
     C                   movea     dte(2)        a22
     C                   movea     $pfmmm        a22(11)
     C                   movea     $pfmdd        a22(14)
     C                   movea     $pfmyy        a22(17)
     C                   movea     a22           dterng
     *
     C                   when      $ptodt <> *blanks
     C                   movea     dte(3)        a22
     C                   movea     $ptomm        a22(11)
     C                   movea     $ptodd        a22(14)
     C                   movea     $ptoyy        a22(17)
     C                   movea     a22           dterng
     *
     C                   other
     C                   movea     dte(4)        dterng
     *
     C                   endsl
     *
     *  Format TIME range
     *
     C                   eval      a22 = *blanks
     C                   movea     tme(1)        a22
     C                   movea     $pbhrs        a22(1)
     C                   movea     $pbmin        a22(4)
     C                   movea     $pbsec        a22(7)
     C                   movea     $pehrs        a22(15)
     C                   movea     $pemin        a22(18)
     C                   movea     $pesec        a22(21)
     C                   movea     a22           tmerng
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     C                   eval      *in90 = *off
     *
     C                   write     head1
     C                   write     head2
     *  Columns
     C                   write     columns
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrsumr        begsr
     *
     C                   do        99            n
     C                   if        whd(n) <> *blanks
     C                   eval      s#whdp = whd(n)
     C                   eval      s#styp = sec(n)
     C                   eval      s#task = tsk(n)
     C                   eval      s#pcs = pcs(n)
     C                   eval      s#hrs = hrs(n)
     C                   eval      s#pcph = pch(n)
     C                   write     sumar1
     C                   endif
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrsumt        begsr
     *
     C                   eval      i = 1
     C                   do        99            i
     C                   eval      tmpwhd = whd(i)
     C                   eval      n = 1
     C     tmpwhd        lookup    whdt(n)                                81
     *  Found
     C                   if        *in81
     C                   add       pcs(i)        pcst(n)
     C                   add       hrs(i)        hrst(n)
     C                   if        hrst(n) > 0
     C     pcst(n)       div       hrst(n)       pcht(n)
     C                   endif
     *
     C                   else
     *  Not found
     C     *blanks       lookup    whdt(n)                                82
     C                   if        *in82
     C                   eval      whdt(n) = whd(i)
     C                   eval      pcst(n) = pcs(i)
     C                   eval      hrst(n) = hrs(i)
     C                   if        hrst(n) > 0
     C     pcst(n)       div       hrst(n)       pcht(n)
     C                   endif
     C                   endif
     C                   endif
     C                   enddo
     *
     C                   eval      n = 0
     C                   do        99            n
     C                   if        whdt(n) <> *blanks
     C                   eval      s#whdp = whdt(n)
     C                   eval      s#styp = *blanks
     C                   eval      s#task = *blanks
     C                   eval      s#pcs = pcst(n)
     C                   z-add     hrst(n)       s#hrs
     C                   z-add     pcht(n)       s#pcph
     C                   write     sumar1
     C                   endif
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrtotl        begsr
     *
     C                   eval      t#ptot = ptot(1)
     C                   eval      t#htot = htot(1)
     C                   if        t#htot > 0
     C     t#ptot        div       t#htot        t#ctot
     C                   endif
     C                   move      rpd(1)        $rpd
     *
     C                   write     total1
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrzero        begsr
     *
     C                   clear                   whd
     C                   clear                   sec
     C                   clear                   pcs
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
**      RPD   Report level descriptions
 * Total:
 ** Date totals **
 *** Totals
**      DTE   Date headings
99/99/99 thru 99/99/99
     From 99/99/99
     Thru 99/99/99

**      TME   TIME headings
99:99:99 thru 99:99:99
**      MRG   Merge records info
**Pieces Do Not Include Merge Pickup Pieces**
