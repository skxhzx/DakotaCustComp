     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  HC321     HACCP History Report.
     *  23 April, 2008
     *  Roxanne Harrison
     *
     *----------------------------------------------------------------
     *  Revisions:
     *  04/23/08  RH   5.20
     *   - Created using HC311
     *
530 A*  01/23/10  MLB  5.30
     *   - Enh: Revised program to receive from/to date range
     *     to be printed on headings, if entered.
     *
640aA*  02/14/12  LMC  6.40a
     *   - Enh: Added Vendor Name and Number to report.
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
     Fhc321     ip   e           k disk
     Fwarehs    if   e           k disk
     Fpiritem   if   e           k disk
640aAFpohhdr    if   e           k disk
     FLoadcnd   if   e           k disk
     Fhc321pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *                   RPD     1   3 30
     D reck            s              7  0 dim(3)
     *
530 A*----------------------------------------------------------------
530 A*  Called programs
530 A*
530 AD @cvtdt          c                   const('CVTDTE')
530 AD $cvtdt          ds
530 AD  $cvcmd                 1      8
530 AD  $cvprg                 9     18
530 AD  $cvd6i                19     24
530 AD  $cvd8i                25     32
530 AD  $cvd6o                33     38  0
530 AD  $cvd8o                39     46  0
530 AD  $cvsto                47     64
530 AD  $cvrtn                65     72
530 AD  $cverm                73    132
530 AD  $cvmsg                73     76
530 A*
530 A*----------------------------------------------------------------
530 A*  Program info data structure
530 A*
530 AD                sds
530 AD  #prog            *proc
530 AD  #job                 244    253
530 AD  #user                254    263
530 AD  #jobn                264    269
530 AD  #jobdt               276    281  0
530 AD  #jobtm               282    287  0
530 A*
     *----------------------------------------------------------------
     *
     D $perm           ds
     D  xxerm                  1     60
     D  $pmsg                  1      4
     *  Variables
     D $plen           s              3  0
     D $pstr           s             60
     D first           s              1
     D l               s              1  0
     D m               s                   like(l)
530 A*----------------------------------------------------------------
530 A*  Parameters
530 A*
530 A*    Input Parameters
530 A*      $PPO     Purchase order number
530 A*               If blank, then date range selected.
530 A*      $PFRMDTE From date YYYYMMDD
530 A*      $PTODTE  To date YYYYMMDD
530 A*
530 A*    Returned Parameters
530 A*      None
530 A*
     *----------------------------------------------------------------
530 A*
530 AC     *entry        plist
530 AC                   parm                    $ppo              9
530 AC                   parm                    $pfrmdte          8
530 AC                   parm                    $ptodte           8
     *
     *  Report Heading
     *
     *
     *  Start new page if one of following happened.
     *     - Page overflow.
     *
     *  PAGE OVERFLOW
     *
     C                   if        first = *on  or
     C                             *in90
     C                   exsr      zrhead
     C                   endif
     *
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *
     *  Get item description.
     *
     C     keyit         chain     piritem                            79
     C                   if        *in79
     C                   eval      w1desc = *blanks
     C                   endif
     *
     *  Get load condition description.
     *
     C     keyld         chain     loadcnd                            79
     C                   if        *in79
     C                   eval      w1ldcn = *blanks
     C                   else
     C                   movel     lcdesc        w1ldcn
     C                   endif
640aA*
640aA*  Get Vendor Number and Name.
640aA*
640aAC     keypo         chain     pohhdr                             79
640aAC                   if        *in79
640aAC                   eval      phhvna = *blanks
640aAc                   eval      phhven = 0
640aAC                   endif
     *
     *  Write detail line.
     *
     C                   movel     hahitem       w1item
     C                   movel     hahinsp       w1rcby
     C                   write     detail1
     *
     *  Write detail2line.
     *
     C                   if        hahttrr <> 0  or
     C                             hahttmd <> 0  or
     C                             hahttns <> 0  or
     C                             hahptrt <> 0  or
     C                             hahptrm <> 0  or
     C                             hahptrb <> 0  or
     C                             hahptmt <> 0  or
     C                             hahptmm <> 0  or
     C                             hahptmb <> 0  or
     C                             hahptnt <> 0  or
     C                             hahptnm <> 0  or
     C                             hahptnb <> 0
     C                   write     detail2
     C                   endif
     *
     *  Increment record counters
     *
     C                   add       1             reck(1)
     *
     *  Set off top-of-page indicators
     *
     C                   eval      first = *off
     C                   eval      *in91 = *off
     *----------------------------------------------------------------
     *
     * REPORT TOTALS
     *
     CLr                 eval      l = 1
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
530 M*  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     *  Define key for PIRITEM file.
     *
     C     keyit         klist
     C                   kfld                    hahwhse
     C                   kfld                    hahitem
640aA*
640aA*  Define key for POHHDR file.
640aA*
640aAC     keypo         klist
640aAC                   kfld                    hahwhse
640aAC                   kfld                    hahpo
     *
     *  Define key for LOADCND file.
     *
     C     keyld         klist
     C                   kfld                    hahldcn
     *
530 AC                   if        $ppo = ' '
530 AC                   eval      $cvprg = #prog
530 A*
530 A*      Convert From Date to print format.
530 AC                   eval      $cvcmd = '*CMDMDY '
530 AC                   move      $pfrmdte      $cvd8i
530 AC                   call      @cvtdt
530 AC                   parm                    $cvtdt
530 AC                   eval      w1frmdt = $cvd6o
530 A*
530 A*      Convert To Date to print format.
530 AC                   move      $ptodte       $cvd8i
530 AC                   call      @cvtdt
530 AC                   parm                    $cvtdt
530 AC                   eval      w1todt = $cvd6o
530 A*
530 AC                   endif
530 A*
     C                   time                    time
     C                   eval      first = *on
     C                   eval      l = 1
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
     C     hahwhse       chain     warehs                             79
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
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     C                   exsr      zrfrmt
     *
     C                   eval      *in90 = *off
     *
     C                   write     head1
530 AC                   if        $ppo = ' '
530 AC                   write     head1a
530 AC                   endif
     C                   write     columns
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrroll        begsr
     *
     C     l             add       1             m
     *
     C                   add       reck(l)       reck(m)
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrzero        begsr
     *
     C                   eval      reck(l) = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
