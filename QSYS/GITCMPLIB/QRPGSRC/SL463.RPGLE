      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  SL463     Slot Statistics Summary - Print
     *  02 May 2013
     *  Retha Davis
     *
     *  Revisions
     *
650 A*    05/02/13  RBD 6.50
     *      - Created for Dierks Waukesha.
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
     Fsl461     ip   e           k disk
     Fwarehs    if   e           k disk
     Freports   if   e           k disk
     Fsl463pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     D hyp             s              1    dim(132)
     D reck            s              7  0 dim(5)
     D lvlk            s              7  0 dim(5)
     D pasg            s              6  0 dim(5)
     D puna            s              6  0 dim(5)
     D ptot            s              6  0 dim(5)
     D rusd            s              6  0 dim(5)
     D rava            s              6  0 dim(5)
     D rtot            s              6  0 dim(5)
     D tot             s              6  0 dim(5)
     *
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     D $plen           s              3  0
     D $pstr           s             60
     D first           s              1
     D l               s              1  0
     D m               s                   like(l)
     D n               s              3  0
     D wkprtf          s             10
     D w1dst           s              8
     *----------------------------------------------------------------
     *
     *  Variables
     *
     D section         s              5
     *----------------------------------------------------------------
     Ioqrec
     I                                          slsdef        l1
     I                                          slstyp        l2
     I                                          slwhdp        l3
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *  Report Heading
     *
     C                   if        *in90
     C                             or first = *on
     C                   exsr      zrhead
     C                   endif
     *
     *  Init total levels
     *
     *  Level 1 break - Slot type
     *
     C                   if        *inl1
     C                   eval      l = 1
     C                   exsr      zrzero
     C                   endif
     *
     *  Level 2 break - Section type
     *
     C                   if        *inl2
     C                   eval      l = 2
     C                   exsr      zrzero
     C                   endif
     *
     *  Level 3 break - Department
     *
     C                   if        *inl3
     C                   eval      l = 3
     C                   exsr      zrzero
     C                   endif
     *
     *  Output Headings
     *
     C                   if        *in91  or
     C                             first = *on
     C                   eval      first = *off
     C                   write     columns
     C                   endif
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *  Accumulate totals
     *
     C                   exsr      zrfill
     *
     *  Increment record counters
     *
     C                   add       1             reck(1)
     C                   add       1             lvlk(1)
     *
     *  Set off top-of-page indicators
     *
     C                   eval      *in91 = *off
     *----------------------------------------------------------------
     *
     * Slot type/aisle totals
     *
     CL1                 eval      l = 1
     CL1                 exsr      zrroll
     CL1                 eval(h)   capcub = (sdlen*sdwdth*sdhgt)/1728
     *
     CL1                 if        reck(l) > 0
     C*1                 write     skip1
     CL1                 exsr      zrtotl
     CL1                 endif
     *----------------------------------------------------------------
     *
     * Section totals
     *
     CL2                 eval      l = 2
     CL2                 exsr      zrroll
     *
     CL2                 if        reck(l) > 0
     C*2                 write     skip1
     CL2                 exsr      zrtotl
     CL2                 endif
     *----------------------------------------------------------------
     *
     * Department totals
     *
     CL3                 eval      l = 3
     CL3                 exsr      zrroll
     *
     CL3                 if        reck(l) > 0
     C*3                 write     skip1
     CL3                 exsr      zrtotl
     CL3                 write     hyplin
     CL3                 endif
     *----------------------------------------------------------------
     *
     * REPORT TOTALS
     *
     CLR                 eval      l = 4
     CLR                 exsr      zrroll
     *
     CLR                 if        reck(l) > 0
     CLR                 exsr      zrtotl
     C*R                 write     skip1
     CLR                 write     grdtot
     CLR                 write     foot1
     CLR                 endif
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
     C                   movel     'SL463PR '    wkprtf
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
     *   Line of hyphens.
     *
     C                   eval      hyp = '_'
     C                   movea     hyp           hyphen
     *
     C                   eval      first = *on
     C                   time                    time
     C                   eval      l = 4
     C                   eval      n = 0
     C                   exsr      zrzero
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrfill        begsr
     *
     *   Increment counters for the slot columns
     *
     C                   eval      n = 1
     C                   eval      tot(n) = tot(n) + 1
     *
     C                   select
     *
     C                   when      slpick = 'Y'
     C                   eval      ptot(n) = ptot(n) + 1
     C                   if        slstat = 'A'
     C                   eval      pasg(n) = pasg(n) + 1
     C                   else
     C                   eval      puna(n) = puna(n) + 1
     C                   endif
     *
     C                   when      slpick = 'N'
     C                   eval      rtot(n) = rtot(n) + 1
     C                   if        (slstk1 + slstk2 + slstk3) > 0
     C                   eval      rusd(n) = rusd(n) + 1
     C                   else
     C                   eval      rava(n) = rava(n) + 1
     C                   endif
     *
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     C                   if        *inl1 = *off
     C                   eval      *in91 = *on
     C                   endif
     *
     C                   eval      *in90 = *off
     *
     *   Get warehouse description.
     *
     C                   eval      whse = *blanks
     C                   eval      $pstr = *blanks
     C     slwhse        chain     warehs                             79
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
     C                   write     head1
     C                   if        first = *off
     C                   write     columns
     C                   endif
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
     C                   add       pasg(l)       pasg(m)
     C                   add       puna(l)       puna(m)
     C                   add       ptot(l)       ptot(m)
     C                   add       rusd(l)       rusd(m)
     C                   add       rava(l)       rava(m)
     C                   add       rtot(l)       rtot(m)
     C                   add       tot(l)        tot(m)
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrtotl        begsr
     *
     C                   select
     C                   when      slstyp = 'F'
     C                   eval      section = 'FIXED'
     C                   when      slstyp = 'P'
     C                   eval      section = 'PIR  '
     C                   other
     C                   eval      section = '     '
     C                   endsl
     *
     C                   eval      t#pasg = pasg(l)
     C                   eval      t#puna = puna(l)
     C                   eval      t#ptot = ptot(l)
     C                   eval      t#rusd = rusd(l)
     C                   eval      t#rava = rava(l)
     C                   eval      t#rtot = rtot(l)
     C                   eval      t#tot  = tot(l)
     *
     C                   select
     C                   when      l = 1
     C                   eval      depsec = %trim(slwhdp) + ' ' + %trim(section)
     C                   write     total1
     C                   when      l = 2
     C                   eval      dstot = %trim(slwhdp) + ' ' + %trim(section) +
     C                             + ' TOTALS'
     C                   write     total2
     C                   when      l = 3
     C                   eval      deptot = %trim(slwhdp) + ' TOTALS'
     C                   write     total3
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrzero        begsr
     *
     C                   eval      lvlk(l) = 0
     C                   eval      reck(l) = 0
     *
     C                   eval      pasg(l) = 0
     C                   eval      puna(l) = 0
     C                   eval      ptot(l) = 0
     C                   eval      rusd(l) = 0
     C                   eval      rava(l) = 0
     C                   eval      rtot(l) = 0
     C                   eval      tot(l)  = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
