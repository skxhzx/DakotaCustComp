     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  SL311     Verified Open Slot Report.
     *  01 September, 1994
     *  Hemant Kapadia
     *
     *  Revisions:
     *  10/15/01 HNK 4.16
     *    - Initialize variable L when L2 breaks.
     *
640a *  02/18/11 GJA 6.40a
     *    - Enh:  Add '*' when slot has virtuals.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions
     *
     *    10/22/08  CBI-JGD
     *      Logic added to report on either all slots or overstock or
     *      both, also, total per department and grand total were     '.
     *      added.                                                    '.
     *
     *    02/22/09  CBIa-JGD
     *      Change SL311 input file to SL311B (invalid virt locs excl)
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
CBIaD*SL311   IP  E           K        DISK
CBIaMFsl311b    ip   e           k disk
     Fwarehs    if   e           k disk
640aAFVSLOT2    if   e           k disk
     Fsl311pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *                   RPD     1   3 30
     D reck            s              7  0 dim(3)
     *----------------------------------------------------------------
     *  General Data structure.
     *
     D ds0             ds
     D  c0def                  1      2
     D  c0actv                 3      4
     D  c0slot                 5     16
640aAD  c0vslt                17     17
     *  Data structure for column 1.
     *
     D ds1             ds                  occurs(50)
     D  c1def                  1      2
     D  c1actv                 3      4
     D  c1slot                 5     16
640aAD  c1vslt                17     17
     *
     *  Data structure for column 2.
     *
     D ds2             ds                  occurs(50)
     D  c2def                  1      2
     D  c2actv                 3      4
     D  c2slot                 5     16
640aAD  c2vslt                17     17
     *
     *  Data structure for column 3.
     *
     D ds3             ds                  occurs(50)
     D  c3def                  1      2
     D  c3actv                 3      4
     D  c3slot                 5     16
640aAD  c3vslt                17     17
     *  Data structure for column 4.
     *
     D ds4             ds                  occurs(50)
     D  c4def                  1      2
     D  c4actv                 3      4
     D  c4slot                 5     16
640aAD  c4vslt                17     17
     *
     *  Data structure for column 5.
     *
     D ds5             ds                  occurs(50)
     D  c5def                  1      2
     D  c5actv                 3      4
     D  c5slot                 5     16
640aAD  c5vslt                17     17
     *----------------------------------------------------------------
     *
     D $perm           ds
     D  xxerm                  1     60
     D  $pmsg                  1      4
     *
     *----------------------------------------------------------------
     * Work Variables
     *----------------------------------------------------------------
     D $llen           s              3  0
     D $lstr           s             60
     D $plen           s              3  0
     D $pstr           s             60
     D cntr            s              6  0
     D cntr2           s              6  0
     D count           s              3  0
     D c1              s              3  0
     D c2              s              3  0
     D c3              s              3  0
     D c4              s              3  0
     D c5              s              3  0
     D first           s              1
     D l               s              1  0
     D m               s                   like(l)
     D reccol          s              3  0
     D recpag          s              3  0
     D savdpt          s              5
     D savdsg          s              5
     D type            s              5
     D x               s              3  0
     *----------------------------------------------------------------
     Ioqrec
     I                                          slwhdp        l2
     I                                          slstyp        l2
     I                                          sldesg        l2
     I                                          slsdef        l1
     *----------------------------------------------------------------
     *
CBI AC     *entry        plist
CBI AC                   parm                    $sltyp            4
CBI A*
CBI A*
     *
     *  Report Heading
     *
     *
CBI AC                   if        first = *on
CBI AC                   eval      savdpt = slwhdp
CBI AC                   eval      savdsg = sldesg
CBI AC                   eval      first = *off
CBI AC                   endif
CBI A*
     *  Start new page if one of following happened.
     *     - Level break occurred.
     *     - Filled page.
     *
     C                   if        *inl2  or
     C                             count = recpag
     C                   exsr      zrfrmt
416 AC                   eval      l = 1
     C                   exsr      zrhead
     C                   endif
     *
     *  Init total levels
     *
     *
     *  Level 1 break - Slot type
     *
     C                   if        *inl1
     C                   eval      l = 1
     C                   exsr      zrzero
     C                   endif
     *
     *  Level 2 break - Dept/Section/Desig
     *
     C                   if        *inl2
     C                   eval      l = 2
     C                   exsr      zrzero
     C                   endif
     *
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *
640aAC                   eval      c0vslt = *blanks
     C                   eval      c0def = slsdef
     C                   eval      c0actv = slactv
     C                   eval      c0slot = sldisp
640aAC     vskey         chain     VSLOT2
640aAC                   if        %found(vslot2)
640aAC                   eval      c0vslt = '*'
640aAC                   endif
     *
     *  Store info. from first 50 records into data structure DS1.
     *  Next 50 records into DS2 and then into DS3, and so on to DS9.
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
     *
     C                   when      c3 <= reccol
     C     c3            occur     ds3
     C                   eval      ds3 = ds0
     C                   add       1             c3
     *
     C                   when      c4 <= reccol
     C     c4            occur     ds4
     C                   eval      ds4 = ds0
     C                   add       1             c4
     *
     C                   when      c5 <= reccol
     C     c5            occur     ds5
     C                   eval      ds5 = ds0
     C                   add       1             c5
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
     * Slot type totals
     *
     CL1                 eval      l = 1
     CL1                 exsr      zrroll
     *
     CL1                 if        reck(l) > 0
     **                   WRITESKIP1
     CL1                 exsr      zrtotl
     CL1                 endif
     *----------------------------------------------------------------
     *
     * Dept/Section/Desig
     *
     CL2                 eval      l = 2
     CL2                 exsr      zrroll
     *
     CL2                 if        reck(l) > 0
     **                   WRITESKIP1
     CL2                 exsr      zrtotl
     CL2                 endif
     *----------------------------------------------------------------
     *
     * REPORT TOTALS
     *
     CLr                 eval      l = 3
     *
     CLr                 if        reck(l) > 0
     CLr                 exsr      zrdetl
CBI ACLr                 eval      t#cls = cntr
CBI ACLr                 write     skip1
CBI ACLr                 write     total2
CBI ACLr                 seton                                        21
CBI ACLr                 eval      t#cls = cntr2
CBI ACLr                 write     total2
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
     C                   time                    time
     C                   eval      first = *on
     C                   eval      count = 0
CBI AC                   eval      cntr = 0
CBI AC                   eval      cntr2 = 0
     C                   eval      l = 3
     C                   eval      x = 1
     C                   eval      c1 = 1
     C                   eval      c2 = 1
     C                   eval      c3 = 1
     C                   eval      c4 = 1
     C                   eval      c5 = 1
     C                   eval      reccol = 50
     C                   eval      recpag = 250
CBI AC                   eval      savdpt = *blanks
CBI AC                   eval      savdsg = *blanks
     C                   exsr      zrcler
     C                   exsr      zrzero
CBI AC                   if        $sltyp = 'O'
CBI AC                   seton                                        20
CBI AC                   endif

640aAC     vskey         klist
640aAC                   kfld                    slwhse
640aAC                   kfld                    slwhdp
640aAC                   kfld                    sldisp

     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrfrmt        begsr
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
     *  Format Dept/Section/Desig
     *
     C                   if        slstyp = 'P'
     C                   eval      type = 'PIR  '
     C                   else
     C                   if        slstyp = 'F'
     C                   eval      type = 'Fixed'
     C                   else
     C                   eval      type = '*None'
     C                   endif
     C                   endif
     C                   eval      p#desc = *blanks
     C     'Type:'       cat       type:1        p#desc
     C     p#desc        cat       'Dept:':2     p#desc
CBI D*>         P#DESC    CAT  SLWHDP:1  P#DESC
CBI MC     p#desc        cat       savdpt:1      p#desc
     C     p#desc        cat       'Desg:':2     p#desc
CBI AC                   if        slwhdp <> savdpt
CBI AC     p#desc        cat       savdsg:1      p#desc
CBI AC                   else
     C                   if        sldesg = *blanks
     C     p#desc        cat       '*NONE':1     p#desc
     C                   else
     C     p#desc        cat       sldesg:1      p#desc
     C                   endif
CBI AC                   endif
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
     *  Print previous page detail lines.
     *
     C                   if        reck(l) > 0
     C                   exsr      zrdetl
     C                   eval      count = 0
     C                   endif
     *
     C                   if        not *inl2
     C                   eval      *in92 = *on
     C                   endif
     *
     C                   if        not *inl1
     C                   eval      *in91 = *on
     C                   endif
     *
     C                   eval      *in90 = *off
     *
     C                   write     head1
     C                   write     head2
     C                   write     columns
CBI A*
CBI AC                   if        *inlr <> *on
CBI A*----------------------------------------------------------------
CBI AC                   if        savdpt <> *blanks  and
CBI AC                             slwhdp <> savdpt
CBI AC                   eval      t#cls = cntr
CBI AC                   write     skip1
CBI AC                   write     skip1
CBI AC                   write     skip1
CBI AC                   write     total2
CBI AC                   eval      cntr = *zeros
CBI AC                   eval      savdpt = slwhdp
CBI AC                   eval      savdsg = sldesg
CBI AC                   exsr      zrfrmt
CBI AC                   write     head1
CBI AC                   write     head2
CBI AC                   write     columns
CBI AC                   endif
CBI AC                   endif
CBI A*----------------------------------------------------------------
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrcler        begsr
     *
     *   Initialize all data structures.
     *
     C                   clear                   c0def
     C                   clear                   c0actv
     C                   clear                   c0slot
640aAC                   clear                   c0vslt
     C     1             do        reccol        x
     C     x             occur     ds1
     C                   eval      ds1 = ds0
     C     x             occur     ds2
     C                   eval      ds2 = ds0
     C     x             occur     ds3
     C                   eval      ds3 = ds0
     C     x             occur     ds4
     C                   eval      ds4 = ds0
     C     x             occur     ds5
     C                   eval      ds5 = ds0
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrdetl        begsr
     *  Print detail line.
     C                   clear                   c0def
     C                   clear                   c0actv
     C                   clear                   c0slot
640aAC                   clear                   c0vslt
     C     1             do        reccol        x
     C     x             occur     ds1
     C     x             occur     ds2
     C     x             occur     ds3
     C     x             occur     ds4
     C     x             occur     ds5
     C                   write     detail1
     C                   eval      ds1 = ds0
     C                   eval      ds2 = ds0
     C                   eval      ds3 = ds0
     C                   eval      ds4 = ds0
     C                   eval      ds5 = ds0
     C                   enddo
     *
CBI A*
CBI AC                   add       c1            cntr
CBI AC                   add       c1            cntr2
CBI AC                   add       c2            cntr
CBI AC                   add       c2            cntr2
CBI AC                   add       c3            cntr
CBI AC                   add       c3            cntr2
CBI AC                   add       c4            cntr
CBI AC                   add       c4            cntr2
CBI AC                   add       c5            cntr
CBI AC                   add       c5            cntr2
CBI AC                   eval      cntr = cntr - 5
CBI AC                   eval      cntr2 = cntr2 - 5
CBI A*
     *  Initialize record counters for each columns.
     *
     C                   eval      c1 = 1
     C                   eval      c2 = 1
     C                   eval      c3 = 1
     C                   eval      c4 = 1
     C                   eval      c5 = 1
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
     *                    ADD  CLS,L     CLS,M
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrtotl        begsr
     *
     *                    Z-ADDCLS,L     T#CLS
     *                    MOVE TYPE      T#DESC
     *
     *                    MOVE RPD,L     $RPD
     C                   if        l = 1
     *                    WRITETOTAL1
     C                   endif
     *
     C                   if        l = 2
     *                    WRITETOTAL2
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrzero        begsr
     *
     *                    Z-ADD0         LVLK,L
     C                   eval      reck(l) = 0
     *
     *                    Z-ADD0         CLS,L
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
