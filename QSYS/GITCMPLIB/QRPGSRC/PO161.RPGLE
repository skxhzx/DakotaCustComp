     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PO161     PO Quantity List
     *  Roxanne Harrison
     *  24 March 1998  Created - V4.09
     *
     *  Revisions
416aA*    08/07/02  RH   4.16
     *      - Added license # to detail print.
416bA*    08/14/02  RH   4.16
     *      - Change to not print quantity with license#
     *
417 A*    08/22/03  MLB  4.17
     *      - Fix: Headings not printing on page overflow.
     *
640a *    01/02/12  GJA  6.40a
     *      - Enh: Add expiration date
     *             Converted to RPGLE
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Not on file/End of file indicator
     *  90        Overflow Indicator
417 A*  91        Print continuation line on headings
417 A*  92        Headings printed. Print detail 1 line.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpohdr     ip   e           k disk
     Fpodtl     if   e           k disk
     Fpiritem   if   e           k disk
     Fwarehs    if   e           k disk
416a FLabel10   if   e           k disk
416a Fpirtran   if   e           k disk
416a FLicense1  if   e           k disk
640a Flicactive if   e           k disk
     Freports   if   e           k disk
     Fpo161pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *                   RPD     1   3 30
     D reck            s              7  0 dim(3)
     D lvlk            s              7  0 dim(3)
     *----------------------------------------------------------------
     *
     *  Variables
     *
     D $plen           s              3  0
     D $pstr           s             60
     D count           s              3  0
     D eof             s              1
     D l               s              1  0
     D lqty1           s              5  0
     D lqty2           s              5  0
     D lqty3           s              5  0
     D m               s                   like(l)
     D wkprtf          s             10
     *
     *----------------------------------------------------------------
     Iphrec
     I                                          phwhse        l1
     I                                          phpo          l1
     *----------------------------------------------------------------
     *
     *  Key fields
     *
     *
     * P.O. Header file -
     *
     C     pohkey        klist
     C                   kfld                    phwhse
     C                   kfld                    phpo
     *
     * P.O. Detail file - Partial key
     *
     C     podkey        klist
     C                   kfld                    phwhse
     C                   kfld                    phpo
     *
     *  Key for PIRITEM file
     C     itmkey        klist
     C                   kfld                    pdwhse
     C                   kfld                    pditem
     *
416a *  Key for LABEL10 file
416a C     lblkey        klist
416a C                   kfld                    pdwhse
416a C                   kfld                    pdpo
416a C                   kfld                    pdseq
416a C                   kfld                    pditem
     *
416a *  Key for PIRTRAN file
416a C     trnkey        klist
416a C                   kfld                    lbtrn#
     *
416a *  Key for LICENSE file
416a C     lcnkey        klist
416a C                   kfld                    ptwhse
416a C                   kfld                    pttrn#
     *
640a *  Key for LICACTIVE file
640a C     lakey         klist
640a C                   kfld                    liwhse
640a C                   kfld                    lilcns
     *
     *----------------------------------------------------------------
     *
     *  Report Heading
     *
     *
     C                   if        *in90  or
     C                             *inl1
     C                   exsr      zrzero
     C                   eval      p#desc = *blanks
     C                   move      phpo          p#desc
     *          TYPE      CAT  '/':0     P#DESC
     *          P#DESC    CAT  ITWHDP:0  P#DESC
     C                   exsr      zrhead
     C                   endif
     *
     *  Init total levels
     *
     *
     *  Level 1 break - Warehouse/PO
     *
     C                   if        *inl1
     C                   eval      l = 1
     C                   endif
     *
     *  Output Headings
     *
     C                   if        *in91  or
     C                             *inl1
     C                   if        *in91
     C                   write     rphead
     C                   endif
     C                   write     columns
     C                   endif
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *
     *  Write detail line
     *
     C     podkey        setll     podtl                              79
     C                   eval      count = 0
     C                   seton                                        61
     C                   move      *in79         eof
     *
     C                   dow       eof = *off
     C     podkey        reade     podtl                                  79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   add       1             count
     C     itmkey        chain     piritem                            78
     C                   if        *in78
     C                   eval      itdesc = *blanks
     C                   endif
     *
417 D*                    WRITEDETAIL1
417 MC                   write     detail1                              90
417 A*
417 AC                   if        *in90
417 AC                   write     head1
417 AC                   write     head2
417 AC                   if        *in91
417 AC                   write     rphead
417 AC                   endif
417 AC                   write     columns
417 AC                   eval      *in90 = *off
417 AC                   eval      *in92 = *on
417 AC                   endif
     *
416a C     lblkey        setll     label10                            77
416a C                   dow       not *in77
416a C     lblkey        reade     label10                                77
416a C                   if        not *in77
416a C     trnkey        chain     pirtran                            76
416a C                   if        not *in76
416a C     lcnkey        chain     license1                           75
416a C                   if        not *in75
416a C                   eval      lqty1 = 0
416a C                   eval      lqty2 = 0
416a C                   eval      lqty3 = 0
416a C                   if        lbutyp = 'N'
416a C                   eval      lqty1 = lbqpck
416a C                   endif
416a C                   if        lbutyp = '1'
416a C                   eval      lqty2 = lbqpck
416a C                   endif
416a C                   if        lbutyp = '2'
416a C                   eval      lqty3 = lbqpck
416a C                   endif
     *
     *  Get expiration date.
     *
640aAC                   eval      expd = *blanks
640aAC                   if        lilcns <> ' ' and itflgd = 'Y'
640aAC     lakey         chain     licactive
640aAC                   if        %found(licactive)
640aAC                   eval      expd = %char(
640aAC                                      %date(laexpd:*iso)
640aAC                                      :*mdy/)
640aAC                   endif
640aAC                   endif
417 A*
417 AC                   if        *in90
417 AC                   write     head1
417 AC                   write     head2
417 AC                   if        *in91
417 AC                   write     rphead
417 AC                   endif
417 AC                   write     columns
417 AC                   write     detail1                              90
417 AC                   eval      *in90 = *off
417 AC                   eval      *in92 = *off
417 AC                   endif
417 A*
417 A*    Detail 1 line overflowed. Headings already printed.
417 A*    Reprint detail 1 line for license plate(s).
417 AC                   if        *in92
417 AC                   write     detail1
417 AC                   eval      *in92 = *off
417 AC                   endif
417 A*
417 D*                    WRITEDETAIL2
417 MC                   write     detail2                              90
416a C                   endif
416a C                   endif
416a C                   endif
416a C                   enddo
     *
     C                   endif
     C                   enddo
     *
     *  Increment record counters
     *
     C                   add       1             reck(1)
     C                   add       1             lvlk(1)
     *
     *  Set off top-of-page indicators
     *
     C                   eval      *in91 = *off
     C     skip          tag
     *----------------------------------------------------------------
     *
     * Warehouse/PO
     *
     CL1                 eval      l = 1
     CL1                 exsr      zrroll
     *
     *----------------------------------------------------------------
     *
     * REPORT TOTALS
     *
     CLr                 eval      l = 2
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
     *
     C     rpkey         klist
     C                   kfld                    wkprtf
     *
     *   Get report title.
     *
     C                   movel     'PO161PR '    wkprtf
     C                   eval      rptttl = *blanks
     C                   eval      $pstr = *blanks
     C     rpkey         chain     reports                            79
     C                   if        not *in79
     C                   movel     rpdesc        $pstr
     C                   else
     C                   move      'PO Qtys'     $pstr
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
     C                   time                    time
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
     *
     *   Get warehouse description.
     *
     C                   eval      whse = *blanks
     C                   eval      $pstr = *blanks
     C     phwhse        chain     warehs                             79
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
     *                    WRITETOTAL1
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
