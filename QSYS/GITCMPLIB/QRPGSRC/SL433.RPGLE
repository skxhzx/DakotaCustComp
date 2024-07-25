     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  SL433     Slot Listing by item - Print.
     *  27 October, 2009
     *  Roxanne Harrison
     *
     *  Revisions:
     *
     *  10/27/09  RH   5.30
     *   - Created using SL333
530b *  01/04/10  RH   5.30b
     *   - Fix: Move expiration date to W1EXPD, was not updated.
     *
700aA*    11/03/16  LMC  7.00a
     *      - Enh: UPC file has a database change. Recompile only.
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
     Fslot1     ip   e           k disk    rename(slrec:sirec) prefix(si)
     Fslot3     if   e           k disk
     Fwarehs    if   e           k disk
     Fpiritem   if   e           k disk
     Fupc1      if   e           k disk
     Fsl433pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *                   RPD     1   3 30
     D reck            s              7  0 dim(3)
     *----------------------------------------------------------------
     * Variables
     D $llen           s              3  0
     D $lstr           s             60
     D $plen           s              3  0
     D $pstr           s             60
     D first           s              1
     D l               s              1  0
     D m               s                   like(l)
     D stop            s              1
     D type            s              5
     D w1qty           s             10
     D*wolin           s             10
     D wolin           c                   const('__________')
     *----------------------------------------------------------------
     *
     D $perm           ds
     D  xxerm                  1     60
     D  $pmsg                  1      4
     *
     *----------------------------------------------------------------
530b *  Called programs
530b D @cvtdt          c                   const('CVTDTE')
530b *----------------------------------------------------------------
     *
530b D $cvtdt          ds
530b D  $cvcmd                 1      8
530b D  $cvprg                 9     18
530b D  $cvd6i                19     24
530b D  $cvd8i                25     32
530b D  $cvd6o                33     38  0
530b D  $cvd8o                39     46  0
530b D  $cvsto                47     64
530b D  $cvrtn                65     72
530b D  $cverm                73    132
530b D  $cvmsg                73     76
     *----------------------------------------------------------------
     Isirec
     I                                          sislwhse      l1
     I                                          sislwhdp      l1
     I                                          sislitem      l1
     *----------------------------------------------------------------
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
     C**                           *in90  or
     C**                           *inl1
     *
     C                   eval      l = 1
     C                   exsr      zrzero
     C                   exsr      zrhead
     C                   endif
     *
     *
     *  Init total levels
     *
     *
     *  Level 1 break - Whse/Dept/Aisle
     *
     C                   if        *inl1
     *  Get item description.
     *
     C                   eval      *in11 = *off
     C                   eval      *in12 = *off
     C                   eval      *in13 = *off
     C     keyit         chain     piritem                            79
     C                   if        *in79
     C                   eval      ititem = *blanks
     C                   eval      itdesc = *blanks
     C                   eval      itpdsc = *blanks
     C                   else
     C                   if        itum1 <> *blanks
     C                   eval      *in11 = *on
     C                   eval      woln1 = wolin
     C                   endif
     C                   if        itum2 <> *blanks
     C                   eval      *in12 = *on
     C                   eval      woln2 = wolin
     C                   endif
     C                   if        itcwgt = 'Y'
     C                   eval      *in13 = *on
     C                   eval      woln3 = wolin
     C                   endif
     C                   endif
     *  Get UPC code
     *
     C     keyit         setll     upc1                               79
     C     keyit         reade     upc1                                   79
     C                   if        *in79
     C                   eval      upupc = *blanks
     C                   endif
     C                   eval      *in61 = *on
     C                   write     detail1
     C*                  eval      *in61 = *off
     *  Increment record counters
     *
     C                   add       1             reck(1)
     *
     C**                 eval      l = 1
     C**                 exsr      zrzero
     C                   endif
     *
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     C     keyit         setll     slot3
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     keyit         reade     slot3                                  79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   if        slpick = 'Y'
     C                   eval      *in10 = *on
     C                   else
     C                   eval      *in10 = *off
     C                   endif
530bA*  Convert expiration date.
530bAC                   if        slexpd > 0
530bAC                   eval      $cvcmd = '*CMDMDY '
530bAC                   move      slexpd        $cvd8i
530bAC                   call      @cvtdt
530bAC                   parm                    $cvtdt
530bAC                   eval      w1expd = $cvd6o
530bAC                   else
530bAC                   eval      w1expd = 0
530bAC                   endif
     *
     *  Calculate Qty available (stock + rcv) - (aloc + pick + trans)
     *
     *    Create a quantity string to print.
     *
     C                   call      'SLOTQTY'
     C                   parm                    slstk1
     C                   parm                    slstk2
     C                   parm                    slstk3
     *
     C                   parm                    slalc1
     C                   parm                    slalc2
     C                   parm                    slalc3
     *
     C                   parm                    sltfr1
     C                   parm                    sltfr2
     C                   parm                    sltfr3
     *
     C                   parm                    slpck1
     C                   parm                    slpck2
     C                   parm                    slpck3
     *
     C                   parm                    slrcv1
     C                   parm                    slrcv2
     C                   parm                    slrcv3
     *
     C                   parm                    stock1            5 0
     C                   parm                    stock2            3 0
     C                   parm                    stock3            3 0
     *
     C                   parm                    avail1            5 0
     C                   parm                    avail2            3 0
     C                   parm                    avail3            3 0
     *
     C                   eval      $pcmd = '*QTY2STR'
     C                   eval      $pqty1 = avail1
     C                   eval      $pqty2 = avail2
     C                   eval      $pqty3 = avail3
     C                   eval      $pqstr = *blanks
     *
     C                   call      'CVTQTY'
     C                   parm                    $pcmd             8
     C                   parm                    $pprg            10
     C                   parm                    $pqty1            7 0
     C                   parm                    $pqty2            7 0
     C                   parm                    $pqty3            7 0
     C                   parm                    $pum1             2
     C                   parm                    $pum2             2
     C                   parm                    $pum3             2
     C                   parm                    $pqstr           10
     C                   parm                    $pustr           17
     C                   parm                    $prtn             8
     C                   parm                    $perm
     *
     C                   eval      w1qty = $pqstr
     *
     *
     *
     *
     *  Write detail line.
     *
     C                   write     detail2
     C                   eval      *in61 = *off
     *
     *  Increment record counters
     *
     C                   add       1             reck(1)
     *
     *  Set off top-of-page indicators
     *
     C                   eval      first = *off
     C                   eval      *in91 = *off
     C                   Endif
     C                   enddo
     *----------------------------------------------------------------
     *
     * Whse/Dept/Aisle totals
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
     *  Define key for main file.
     *
     C     keyit         klist
     C                   kfld                    sislwhse
     C                   kfld                    sislitem
     *
     C                   time                    time
     C                   eval      first = *on
     C                   eval      l = 2
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
     C     sislwhse      chain     warehs                             79
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
     *  Format Dept/Aisle
     *
     C                   eval      p#desc = *blanks
     C     'Dept:'       cat       sislwhdp:1    p#desc
     C     p#desc        cat       'Aisle':2     p#desc
     C     p#desc        cat       ':':0         p#desc
     C                   if        sislaisl = *blanks
     C     p#desc        cat       '*NONE':1     p#desc
     C                   else
     C     p#desc        cat       sislaisl:1    p#desc
     C                   endif
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
     C                   if        *inl1
     C                   exsr      zrfrmt
     C                   else
     C                   eval      *in91 = *on
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
     C     zrroll        begsr
     *
     C     l             add       1             m
     *
     *                    ADD  1         LVLK,M
     C                   add       reck(l)       reck(m)
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrzero        begsr
     *
     *                    Z-ADD0         LVLK,L
     C                   eval      reck(l) = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
