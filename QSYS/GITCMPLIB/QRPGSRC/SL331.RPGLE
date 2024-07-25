     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  SL331     Slot Listing - Print.
     *  20 March, 1996
     *  Hemant Kapadia/Roxanne Harrison
     *
     *  Revisions:
     *
     *  12/02/12  LMC  6.40
     *   - Converted to ILE
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
     Fslot1     ip   e           k disk
     Fwarehs    if   e           k disk
     Fsl331pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *                   RPD     1   3 30
     D reck            s              7  0 dim(2)
     *----------------------------------------------------------------
     *  General Data structure.
     *
     D ds0             ds
     *                                       1   2 C0DEF
     *                                       3   4 C0ACTV
     *                                       5  16 C0SLOT
     D  c0slot                 1     12
     D  c0pseq                13     17  0
     D  c0def                 18     19
     D  c0pick                20     20
     *  Data structure for column 1.
     *
     D ds1             ds                  occurs(50)
     D  c1slot                 1     12
     D  c1pseq                13     17  0
     D  c1def                 18     19
     D  c1pick                20     20
     *
     *  Data structure for column 2.
     *
     D ds2             ds                  occurs(50)
     D  c2slot                 1     12
     D  c2pseq                13     17  0
     D  c2def                 18     19
     D  c2pick                20     20
     *
     *  Data structure for column 3.
     *
     D ds3             ds                  occurs(50)
     D  c3slot                 1     12
     D  c3pseq                13     17  0
     D  c3def                 18     19
     D  c3pick                20     20
     *  Data structure for column 4.
     *
     D ds4             ds                  occurs(50)
     D  c4slot                 1     12
     D  c4pseq                13     17  0
     D  c4def                 18     19
     D  c4pick                20     20
     *
     *  Data structure for column 5.
     *
    D*S5         DS                         50
     *                                       1   2 C5DEF
     *                                       3   4 C5ACTV
     *                                       5  16 C5SLOT
     *----------------------------------------------------------------
     *
     D $perm           ds
     D  xxerm                  1     60
     D  $pmsg                  1      4
     *----------------------------------------------------------------
     * Variables
     *
     D $llen           s              3  0
     D $lstr           s             60
     D $plen           s              3  0
     D $pstr           s             60
     D count           s              3  0
     D c1              s              3  0
     D c2              s              3  0
     D c3              s              3  0
     D c4              s              3  0
     D first           s              1
     D l               s              1  0
     D m               s                   like(l)
     D reccol          s              3  0
     D recpag          s              3  0
     D type            s              5
     D x               s              3  0
     *
     *----------------------------------------------------------------
     Islrec
     I                                          slwhse        l1
     I                                          slwhdp        l1
     I                                          slaisl        l1
     *----------------------------------------------------------------
     *
     *  Report Heading
     *
     *
     *  Start new page if one of following happened.
     *     - Level break occurred.
     *     - Filled page.
     *
     C                   if        *inl1  or
     C                             count = recpag
     C                   exsr      zrfrmt
     C                   exsr      zrhead
     C                   endif
     *
     *  Init total levels
     *
     *
     *  Level 1 break - Warehouse #/Dept/Aisle
     *
     C                   if        *inl1
     C                   eval      l = 1
     C                   exsr      zrzero
     C                   endif
     *
     *
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *
     C                   eval      c0def = slsdef
     C                   move      slpseq        c0pseq
     C                   eval      c0slot = sldisp
     C                   eval      c0pick = slpick
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
     *          C5        WHLE RECCOL
     *          C5        OCUR DS5
     *                    MOVE DS0       DS5
     *                    ADD  1         C5
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
     * Whse/Dept/Aisle
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
     * REPORT TOTALS
     *
     CLr                 eval      l = 2
     *
     CLr                 if        reck(l) > 0
     CLr                 exsr      zrdetl
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
     C                   eval      l = 2
     C                   eval      x = 1
     C                   eval      c1 = 1
     C                   eval      c2 = 1
     C                   eval      c3 = 1
     C                   eval      c4 = 1
     *                    Z-ADD1         C5      30
     C                   eval      reccol = 50
     C                   eval      recpag = 200
     *                    Z-ADD250       RECPAG  30
     C                   exsr      zrcler
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
     *  Format Dept/Section/Aisle
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
     C     p#desc        cat       slwhdp:1      p#desc
     C     p#desc        cat       'Aisle':2     p#desc
     C     p#desc        cat       ':':0         p#desc
     C                   if        slaisl = *blanks
     C     p#desc        cat       '*NONE':1     p#desc
     C                   else
     C     p#desc        cat       slaisl:1      p#desc
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
     *  Print previous page detail lines.
     *
     C                   if        reck(l) > 0
     C                   exsr      zrdetl
     C                   eval      count = 0
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
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrcler        begsr
     *
     *   Initialize all data structures.
     *
     *                    CLEARC0DEF
     *                    CLEARC0ACTV
     *                    CLEARC0SLOT
     C                   clear                   c0def
     C                   clear                   c0pseq
     C                   clear                   c0slot
     C                   clear                   c0pick
     C     1             do        reccol        x
     C     x             occur     ds1
     C                   eval      ds1 = ds0
     C     x             occur     ds2
     C                   eval      ds2 = ds0
     C     x             occur     ds3
     C                   eval      ds3 = ds0
     C     x             occur     ds4
     C                   eval      ds4 = ds0
     *          X         OCUR DS5
     *                    MOVE DS0       DS5
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrdetl        begsr
     *  Print detail line.
     *                    CLEARC0DEF
     *                    CLEARC0ACTV
     *                    CLEARC0SLOT
     C                   clear                   c0def
     C                   clear                   c0pseq
     C                   clear                   c0slot
     C                   clear                   c0pick
     C     1             do        reccol        x
     C     x             occur     ds1
     C     x             occur     ds2
     C     x             occur     ds3
     C     x             occur     ds4
     *          X         OCUR DS5
     C                   write     detail1
     C                   eval      ds1 = ds0
     C                   eval      ds2 = ds0
     C                   eval      ds3 = ds0
     C                   eval      ds4 = ds0
     *                    MOVE DS0       DS5
     C                   enddo
     *
     *  Initialize record counters for each columns.
     *
     C                   eval      c1 = 1
     C                   eval      c2 = 1
     C                   eval      c3 = 1
     C                   eval      c4 = 1
     *                    Z-ADD1         C5
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
