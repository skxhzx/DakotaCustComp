      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ER331     Print Put-away/Returns transactions
     *  Hemant Kapadia
     *  02 July, 1999
     *
     *  7.2.99  HNK  4.11
     *  - Created
     *
     *  Revisions
     *
530  *  09/19/09  GJA  5.30
     *    - Converted to RPGLE, cleaned up and revamped for suspended.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Not on file/End of file indicator
     *  90        Overflow Indicator
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fer331     ip   e           k disk
     Fwarehs    if   e           k disk
     Fpiruser1  if   e           k disk
     Freporte   if   e           k disk
     Fer331pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *                   RPD     1   3 30
     D reck            s              7  0 dim(3)
     D lvlk            s              7  0 dim(3)
     D a22             s              1    dim(22)
     D dte             s             22    dim(4) ctdata perrcd(1)
     D tme             s             22    dim(1) ctdata perrcd(1)
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
     D $pfmtm          ds
     D  $pbhrs                 1      2
     D  $pbmin                 3      4
     D  $pbsec                 5      6
     D $ptotm          ds
     D  $pehrs                 1      2
     D  $pemin                 3      4
     D  $pesec                 5      6
     *----------------------------------------------------------------
     *  Variables
     *
     D $cmd            s              8
     D $name           s             40
     D $plen           s              3  0
     D $pstr           s             60
     D count           s              3  0
     D l               s              1  0
     D m               s                   like(l)
     D min             s              7  0
     D pck             s              7  0
     D svtrn#          s                   like(pttrn#)
     D whse            s             50
     D wkprtf          s             10
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      $PWHSE  Warehouse code
     *      $PEMP#  Employee number
     *      $PFMDT  From date (YYYYMMDD)
     *      $PTODT  To date (YYYYMMDD)
     *      $PFMTM  From time (HHMMSS)
     *      $PTOTM  To time (HHMMSS)
     *
     *----------------------------------------------------------------
     Ioqrec
     I                                          ptemp#        l1
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3
     C                   parm                    $pemp#            5
     C                   parm                    $pfmdt
     C                   parm                    $ptodt
     C                   parm                    $pfmtm            6
     C                   parm                    $ptotm            6
     *
     *----------------------------------------------------------------
     *
     *  Report Heading
     *
     *
     C                   if        *in90  or
     C                             *inl1
     C                   exsr      zrzero
     C                   exsr      zrhead
     C                   endif
     *
     *  Init total levels
     *
     *  Level 1 break - Slot type/Department
     *
     C                   if        *inl1
     C                   eval      l = 1
     C                   endif
     *
     *  Output Headings
     *
     C                   if        *in91  or
     C                             *inl1
     *
     C     ptemp#        chain     piruser1                           79
     C                   if        not *in79
     C                   eval      $cmd = '*LFM    '
     C                   eval      $name = *blanks
     C                   call      'FRMTNM'
     C                   parm                    $cmd
     C                   parm                    usfnam
     C                   parm                    usinit
     C                   parm                    uslnam
     C                   parm                    $name
     C                   eval      wkname = $name
     C                   else
     C                   eval      wkname = *blanks
     C                   endif
     *
     C                   write     ephead
     *
     C                   write     columns
     C                   endif
     *----------------------------------------------------------------
     * Detail Calcs
     *
     *  Write detail line
     *
     C                   select
     C                   when      ptsdte = fmdt and
     C                             ptstim < totm or
     C                             ptsdte = todt and
     C                             ptetim > totm
     C                   goto      skip
     C                   endsl
     * If task is 'PUTEMP'... continue....
     C                   if        pttask = 'PUTEMP'  or
     C                             pttask = 'PUTRTN'
     *
     C                   if        ptsdte > 0
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptsdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1sdte = $cvd6o
     C                   else
     C                   eval      w1sdte = 0
     C                   endif
     C                   eval      w1stim = ptstim
     *
     C                   if        ptedte > 0
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptedte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1edte = $cvd6o
     C                   else
     C                   eval      w1edte = 0
     C                   endif
     C                   eval      w1etim = ptetim
     *
     C                   write     detail1
     *
     *  Increment record counters
     *
     C                   add       1             count
     C                   add       1             reck(1)
     C                   add       1             lvlk(1)
     C                   add       lbqpck        pck
530aAC                   if        pttrn#<>svtrn#
     C                   add       ptdmin        min
530aAC                   eval      svtrn#=pttrn#
     C                   else
     C                   eval      min=0
530aAC                   endif
     C                   endif
     C     skip          tag
     *
     *  Set off top-of-page indicators
     *
     C                   eval      *in91 = *off
     *----------------------------------------------------------------
     *
     * Slot type/Department totals
     *
     CL1                 eval      l = 1
     CL1                 exsr      zrroll
530aACL1                 eval      trnmin = min
530aACL1                 eval      trnpck = pck
     CL1                 eval      trncnt = count
     CL1NLR              write     total1
     CL1                 eval      count = 0
     *
     *----------------------------------------------------------------
     *
     * REPORT TOTALS
     *
     CLR                 eval      l = 2
     *
     CLR                 if        reck(l) = 0
     CLR                 move      $pemp#        emp#              5 0
     CLR   emp#          chain     piruser1                           79
     CLR                 if        not *in79
     CLR                 eval      $cmd = '*LFM    '
     CLR                 eval      $name = *blanks
     CLR                 call      'FRMTNM'
     CLR                 parm                    $cmd
     CLR                 parm                    usfnam
     CLR                 parm                    usinit
     CLR                 parm                    uslnam
     CLR                 parm                    $name
     CLR                 eval      wkname = $name
     CLR                 else
     CLR                 eval      wkname = *blanks
     CLR                 endif
     CLR                 exsr      zrhead
     CLR                 write     ephead
     CLR                 write     columns
     CLR                 write     foot2
     CLR                 endif
     CLR                 write     skip1
     CLR                 write     total1
     CLR                 write     foot1
     CLR                 return
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
     *   Get report title.
     *
     C                   movel     'ER331PR '    wkprtf
     C                   eval      rptttl = *blanks
     C                   eval      $pstr = *blanks
     C     rpkey         chain     reporte                            79
     C                   if        not *in79
     C                   movel     erdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
     C                   eval      $plen = 40
     *   Center report title.
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         rptttl
     *  Format date range
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
     C                   move      $pfmdt        fmdt              6 0
     C                   move      $ptodt        todt              6 0
     C                   move      $pfmtm        fmtm              6 0
     C                   move      $ptotm        totm              6 0
     *
     C                   time                    time
     *  Format TIME range
     C                   eval      a22 = *blanks
     C                   movea     tme(1)        a22
     C                   movea     $pbhrs        a22(1)
     C                   movea     $pbmin        a22(4)
     C                   movea     $pbsec        a22(7)
     C                   movea     $pehrs        a22(15)
     C                   movea     $pemin        a22(18)
     C                   movea     $pesec        a22(21)
     C                   movea     a22           tmerng
     C                   eval      count = 0
     C                   eval      l = 2
     C                   exsr      zrzero
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     C                   if        not *inl1
     C                   eval      *in91 = *on
     C                   endif
     *
     C                   eval      *in90 = *off
     *   Get warehouse description.
     C                   eval      whse = *blanks
     C                   eval      $pstr = *blanks
     C                   move      $pwhse        pwhse             3 0
     C     pwhse         chain     warehs                             79
     C                   if        not *in79
     C                   movel     whdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
     C                   eval      $plen = 30
     *   Center warehouse description.
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         whse
     *
     C                   write     head1
     C                   write     head2
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrroll        begsr
     *
     C     l             add       1             m
     *
     C                   add       1             lvlk(m)
     C                   add       reck(l)       reck(m)
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrtotl        begsr
     *
     C                   if        l = 1
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrzero        begsr
     *
     C                   eval      lvlk(l) = 0
     C                   eval      reck(l) = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
**      DTE   Date headings
99/99/99 thru 99/99/99
     From 99/99/99
     Thru 99/99/99

**      TME   TIME headings
99:99:99 thru 99:99:99
