     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  TM311     Truck layout
     *  23 June, 1997
     *  Hemant Kapadia
     *
     *  Revisions:
     *
650a *  05/31/13   GJA   6.50a
     *       Enh:  Add truck description
     *
650b *  11/02/14   GJA   6.50b
     *       Enh:  Allow output to be portrait
700a *  03/17/15   GJA   7.00a
     *       Enh:  Allow summary at bottom
720aA*  12/06/18   GJA   7.20a
     *       Enh:  Recompile because of printer file change.
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
     Ftruckd    ip   e           k disk
650aAFtruckh    if   e           k disk
     Fwarehs    if   e           k disk
700aAFtrkcomp   if   e           k disk
     Ftm311pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *                   RPD     1   3 30
     D reck            s              7  0 dim(3)
     *
     *  Arrays for summary
700aAD COMP            S              1    DIM(99)
700aAD NUM             S              2  0 DIM(99)
700aAD CUB             S              7  3 DIM(99)
     *----------------------------------------------------------------
     *  General Data structure.
     *
     D ds0             ds
     D  c0comp                 1      1
     D  c0cube                 2      6  2
     D  c0pick                 7      8  0
     *  Data structure for column 1.
     *
     D ds1             ds                  occurs(50)
     D  c1comp                 1      1
     D  c1cube                 2      6  2
     D  c1pick                 7      8  0
     *
     *  Data structure for column 2.
     *
     D ds2             ds                  occurs(50)
     D  c2comp                 1      1
     D  c2cube                 2      6  2
     D  c2pick                 7      8  0
     *
     *PARM       DS
     *                                       1   30$WHSE
     *----------------------------------------------------------------
     *
     D $perm           ds
     D  xxerm                  1     60
     D  $pmsg                  1      4
     *  Variables
     *
     D $plen           s              3  0
     D $pstr           s             60
     D count           s              3  0
     D c1              s              3  0
     D c2              s              3  0
     D first           s              1
     D l               s              1  0
     D reccol          s              3  0
     D recpag          s              3  0
     D x               s              3  0
     *----------------------------------------------------------------
     *
     C     *entry        plist
     *                    PARM           $PARM
     C                   parm                    $whse             3 0
     C                   parm                    $ptruk           10
     *
     *  Report Heading
     *
     *
     *  Start new page if one of following happened.
     *     - Filled page.
     *
     C                   if        count = recpag
     C                   exsr      zrfrmt
     C                   exsr      zrhead
     C                   endif
     *
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *
     *    Create a quantity string to print.
     *
     C                   eval      first = *off
     *
     C                   eval      c0comp = tdcomp
     C                   eval      c0cube = tdcube
     C                   eval      c0pick = tdpick
     *
700aAC                   exsr      zzsum
     *
     *  Store info. from first record into data structure DS1.
     *  Next record into DS2.
     *
     C                   select
     C                   when      c1 <= reccol
     C     c1            occur     ds1
     C                   eval      ds1 = ds0
     C                   add       1             c1
     *
     C                   when      c2 <= reccol
     C     c2            occur     ds2
     C                   eval      ds2 = ds0
     C                   add       1             c2
     C                   exsr      zrdetl
     C                   endsl
     *
     C                   add       1             count
     *
     *
     *  Accumulate totals
     *                    ADD  1         CLS,1
     *
     *  Increment record counters
     *
     C                   add       1             reck(1)
     *
     *  Set off top-of-page indicators
     *
     C                   eval      *in91 = *off
     *----------------------------------------------------------------
     *
     * REPORT TOTALS
     *
     CLr                 if        c1 > reccol  and
     C                             c2 <= reccol
     CLr                 exsr      zrdetl
     CLr                 endif
     CLr                 exsr      zrtotl
     CLr                 write     skip1
     CLr                 write     foot1
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
     *  TRUCKH key list
650aAC     keyth         klist
650aAC                   kfld                    $whse
650aAC                   kfld                    $ptruk
     *
700aAC     keytc         klist
700aAC                   kfld                    $whse
700aAC                   kfld                    tcomp
     *
     C                   time                    time
     C                   eval      first = *on
     C                   eval      count = 0
     C                   eval      l = 3
     C                   eval      x = 1
     C                   eval      c1 = 1
     C                   eval      c2 = 1
     C                   eval      reccol = 1
650bDC***                eval      recpag = 24
650bMC                   eval      recpag = 30
     C                   exsr      zrcler
     C                   exsr      zrzero
     C                   exsr      zrfrmt
     C                   exsr      zrhead
     C                   endsr
     *----------------------------------------------------------------
700aA*  ZZSUM - summary totals
     C     zzsum         begsr
      *
     C                   Z-ADD     1             N                 3 0
     C     TDCOMP        LOOKUP    COMP(N)                                81
     C*  Found
     C                   if        *IN81=*ON
     C                   add       tdcube        cub(n)
     C                   add       1             num(n)
     C                   else
     C     *BLANKS       LOOKUP    comp(N)                                82
     C                   if        *in82=*on
     C                   movel     tdcomp        comp(N)
     C                   add       tdcube        cub(n)
     C                   add       1             num(n)
     C                   endif
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrfrmt        begsr
     *
     *   Get warehouse description.
     *
     C                   eval      whse = *blanks
     C                   eval      $pstr = *blanks
     C     $whse         chain(n)  warehs                             79
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
     *  Format truck
     *
     C                   eval      truck = *blanks
     C                   eval      truck = $ptruk
650aA*
650aAC                   eval      trkdesc = *blanks
650aAC     keyth         chain     truckh                             79
650aAC                   if        not *in79
650aAC                   eval      trkdesc = thdesc
650aAC                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     *  Print previous page detail lines.
     *
     C                   if        reck(l) > 0
     C                   exsr      zrdetl
     C                   eval      count = 0
     C                   endif
     *
     C                   eval      *in90 = *off
     *
     C                   write     head1
     C                   write     head2
     C                   write     columns
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrcler        begsr
     *
     *   Initialize all data structures.
     *
     C                   clear                   c0comp
     C                   clear                   c0cube
     C                   clear                   c0pick
     C     1             do        reccol        x
     C     x             occur     ds1
     C                   eval      ds1 = ds0
     C     x             occur     ds2
     C                   eval      ds2 = ds0
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrdetl        begsr
     *  Print detail line.
     C                   clear                   c0comp
     C                   clear                   c0cube
     C                   clear                   c0pick
     C     1             do        reccol        x
     C     x             occur     ds1
     C     x             occur     ds2
     C                   write     detail1
     C                   eval      ds1 = ds0
     C                   eval      ds2 = ds0
     C                   enddo
     *
     C                   write     dash1
     C                   write     dash2
     *
     *  Initialize record counters for each columns.
     *
     C                   eval      c1 = 1
     C                   eval      c2 = 1
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrtotl        begsr
     *
700aAC     n             downe     0
700aAC                   eval      tcomp = comp(n)
700aAC                   eval      tcube = cub(n)
700aAC                   eval      tnum = num(n)
700aAC     keytc         chain     trkcomp
700aAC                   if        not %found(trkcomp)
700aAC                   eval      tpdesc = *blanks
700aAC                   endif
700aAC                   write     total1
700aAC                   eval      gcube = cub(n) + gcube
700aAC                   eval      gnum = num(n) + gnum
700aAC                   eval      n= n-1
700aAC                   enddo
     *
     C*                  if        l = 2
700aAC                   write     skip1
700aAC                   write     total2
     C*                  endif
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
