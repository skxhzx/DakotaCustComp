     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  EX166   RF Selection exception report.
     *  23 March 2006
     *  Roxanne Harrison
     *
     *  Revisions:
     *
500 A*    03/23/06  RH   5.00
     *      - Created using EX156
510aA*    08/08/06  RH   5.10a
     *      - Fix: Change spacing, remove item page break
     *      - Enh: Add slot to report.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Not on file/End of file indicator
     *  91        Overflow Indicator
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fvoexcp    ip   e           k disk
510a Flabel     if   e           k disk
     Fpiritem   if   e           k disk
     Fwarehs    if   e           k disk
     Freports   if   e           k disk
     Fex166pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *
     D reck            s              7  0 dim(3)
     D lvlk            s              7  0 dim(3)
     *
     D cls             s              5  0 dim(3)
     D desc            s             50    dim(6) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D                 ds
     **                                      1  12 EXFDIS
     **                                     13  24 EXTDIS
     D  dspo                   1      9
     D  dslbl                 10     16  0
     D  dsexpd                17     24  0
417c D  dsupc                  1     20
     *----------------------------------------------------------------
     *  Variables
     D $llen           s              3  0
     D $lstr           s             60
     D $plen           s              3  0
     D $pstr           s             60
     D datestamp       s               d
     D dftstamp        s               z
     D fmdt            s              6  0
     D*gendte          s              6  0
     D genodt          s              8
     D hmsmdy          s             12  0
     D l               s              1  0
     D m               s                   like(l)
     D noon            s               t   inz(t'12.00.00')
     D timestamp       s               t
     D todt            s              6  0
     D wkprtf          s             10
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     *
     *
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
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     Isxrec
     I                                          sxesta        l2
     I                                          sxitem        l1
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $from             8
     C                   parm                    $to               8
     *----------------------------------------------------------------
     *
     *  Report Heading
     *
     *
     *  Start new page if one of following happened.
     *     - Level break occurred.
     *     - Filled page.
     *
     C                   if        *in90  or
     C                             *inl1
     C                   exsr      zrzero
510a C                   endif
     *
510a C                   if        *in90
     C                   eval      p#desc = *blanks
     *          'Dept:'   CAT  SXWHDP:1  P#DESC
     *          P#DESC    CAT  'Type:':2 P#DESC
     *          P#DESC    CAT  TYPE:1    P#DESC
     C                   movel     p#desc        $lstr
     C                   eval      $llen = 40
     C                   call      'CENTER'
     C                   parm                    $lstr
     C                   parm                    $llen
     C                   movel     $lstr         p#desc
     *
     C                   exsr      zrhead
     C                   endif
     *
     *  Init total levels
     *
     *
     *  Level 1 break - Item
     *
     C                   if        *inl1
     C                   eval      l = 1
     C                   endif
     *
     *
     *  Output Headings
     *
510a C                   if        *in91
510a C***                if        *in91  or
510a C***                          *inl1
     C                   if        *in91
     C                   write     rphead
     C                   endif
     C                   write     columns
     C                   endif
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *  Convert Generated date
     *
     C*                  eval      $cvcmd = '*CMDMDY '
     C*                  move      cxgdte        $cvd8i
     C*                  call      @cvtdt
     C*                  parm                    $cvtdt
     C*                  eval      gendte = $cvd6o
     C**                 eval      hmsmdy = sxgdts
     C*                  movel     hmsmdy        rtime
     C**                 move      hmsmdy        gendte
     *  Convert datestamp to date/time output fields.
     C                   If        sxgdts <> dftstamp
     C                   move      sxgdts        datestamp
     C                   move      sxgdts        timestamp
     C     *mdy/         movel     datestamp     genodt
     C                   eval      genout = genodt
     C**                 eval      gentim = timestamp
     C                   if        timestamp < noon
     C                   eval      gentim = %subst(%char(timestamp):1:5)
     C                                     + ' am'
     C                   else
     C     timestamp     subdur    12:*H         timestamp
     C                   eval      gentim = %subst(%char(timestamp):1:5)
     C                                     + ' pm'
     C                   endif
     C*                  eval      gendte = datestamp
     C***x               move      datestamp     gendte
     C**                 eval      w1gtim = timestamp
     C                   Else
     C                   eval      genodt = ' '
     C                   eval      gentim = ' '
     C**                 eval      w1gtim = *loval
     C                   endif
     *
     *  Retrieve item description.
     *
     C     itkey         chain     piritem                            79
     C                   if        *in79
     C                   eval      itdesc = *blanks
     C                   endif
510a *
510a *  Retrieve item description.
510a *
510a C     lbkey         chain     label                              79
510a C                   if        *in79
510a C                   eval      lbdisp = *blanks
510a C                   endif
     *
     *  Setup error description for printing.
     *
     C                   select
     C                   when      sxerid = 'SKPLCN '
     C                   movel     desc(3)       errmsg
     *
     C                   when      sxerid = 'SKPUPC '
     C                   movel     desc(4)       errmsg
     *
     C                   when      sxerid = 'SHORTS '
     C                   movel     desc(5)       errmsg
     *
     C                   when      sxerid = 'SHORTM '
     C                   movel     desc(6)       errmsg
     *
     C                   other
     C                   movel(p)  sxerid        errmsg
     C                   endsl
     *
     *
     *
     *  Write detail line
     *
     C                   write     detail1
     *
     *  Accumulate totals
     *
     C                   add       1             cls(1)
     *
     *  Increment record counters
     *
     C                   add       1             reck(1)
     C                   add       1             lvlk(1)
     *
     *  Set off top-of-page indicators
     *
     C                   eval      *in92 = *off
     C                   eval      *in91 = *off
     *----------------------------------------------------------------
     *
     * Slot type totals
     *
     CL1                 eval      l = 1
     CL1                 exsr      zrroll
     *
     CL1                 if        reck(l) > 0
     CL1                 write     skip1
     CL1                 exsr      zrtotl
     CL1                 endif
     *----------------------------------------------------------------
     *
     * REPORT TOTALS
     *
     CLr                 eval      l = 3
     *
     CLr                 if        reck(l) > 0
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
     C                   eval      dftstamp = *loval
     *
     C     rpkey         klist
     C                   kfld                    wkprtf
     *
     C     itkey         klist
     C                   kfld                    sxwhse
     C                   kfld                    sxitem
     *
501b C     lbkey         klist
501b C                   kfld                    sxlbl#
     *
     *
     *
     *   Get report title.
     *
     C                   movel     'EX166PR '    wkprtf
     C                   eval      rptttl = *blanks
     C                   eval      $pstr = *blanks
     C     rpkey         chain     reports                            79
     C                   if        not *in79
     C                   movel     rpdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
     C                   eval      $plen = 40
     *
     *   Center report title.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         rptttl
     *
     *
     *   Convert dates to MMDDYY format.
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   eval      $cvd8i = $from
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      fmdt = $cvd6o
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   eval      $cvd8i = $to
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      todt = $cvd6o
     *
     *
     C                   eval      $cvprg = #prog
     *
     C                   eval      l = 3
510a C                   eval      *in90 = *on
     C                   exsr      zrzero
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrfrmt        begsr
     *
     *   Get warehouse description.
     *
     C                   eval      whse = *blanks
     C                   eval      $pstr = *blanks
     C     sxwhse        chain     warehs                             79
     C                   if        not *in79
     C                   movel     whdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
     C                   eval      $plen = 30
     *
     *   Center warehouse description.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         whse
     *
     C                   eval      p#desc = *blanks
     *          'Dept:'   CAT  EXWHDP:1  P#DESC
     *          P#DESC    CAT  'Type:':2 P#DESC
     *          P#DESC    CAT  TYPE:1    P#DESC
     C                   movel     p#desc        $lstr
     C                   eval      $llen = 40
     C                   call      'CENTER'
     C                   parm                    $lstr
     C                   parm                    $llen
     C                   movel     $lstr         p#desc
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     *
     C                   if        not *inl1
     C                   eval      *in91 = *on
     C                   endif
     *
     C                   eval      *in90 = *off
     C                   exsr      zrfrmt
     *
     C                   write     head1
     C                   write     head2
510a C                   write     columns
     *                    WRITECOLUMNS
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
     C                   add       cls(l)        cls(m)
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrtotl        begsr
     *
     C                   eval      t#cls = cls(l)
     C                   eval      t#desc = *blanks
     C     sxitem        cat       '/':1         t#desc
     *          T#DESC    CAT  TYPE:1    T#DESC
     *
     C                   if        l = 1
     C                   write     total1
510a C                   write     skip1
     C                   endif
     *
     C                   if        l = 2
     C                   write     total2
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
     C                   eval      cls(l) = 0
     *
     *    Setup heading for either open/closed exceptions.
     C                   select
     C                   when      sxesta = '1 '
     C                   movel     desc(1)       p#stat
     *
     C                   when      sxesta = '4 '
     C                   movel     desc(2)       p#stat
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
** Descriptions
            Open Exceptions
             Closed Exceptions
License scan skipped
UPC scan skipped
Short selection
Short merge
