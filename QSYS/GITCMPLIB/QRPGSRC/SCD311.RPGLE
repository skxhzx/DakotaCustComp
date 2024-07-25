      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  SCD311    Slots without Check Digit Report.
     *  04 January, 2001
     *  Kenneth Elder
     *
     *  Revisions:
     *
417 A*    04/15/04  DAS  4.17
     *      - Added parm $PHEAD.
     *      - Added $PHEAD to output headers.
510 A*    09/11/07  RBD  5.10
     *      - Enh: Convert to ILE.
     *        Add logic to accomodate multiple check digits.
     *        Slot/Slotdgt record matches are eliminated in the
     *        the query file SCD311.  Slot/Slotdgta record matches
     *        will be eliminated within this program.
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
     Fscd311    ip   e           k disk
     Fwarehs    if   e           k disk
510 AFslotdgta  if   e           k disk
     Fscd311pr  o    e             printer oflind(*in90)
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
     D  c0slot                 1     12
     D  c0pick                13     13
     *  Data structure for column 1.
     *
     D ds1             ds                  occurs(50)
     D  c1slot                 1     12
     D  c1pick                13     13
     *
     *  Data structure for column 2.
     *
     D ds2             ds                  occurs(50)
     D  c2slot                 1     12
     D  c2pick                13     13
     *
     *  Data structure for column 3.
     *
     D ds3             ds                  occurs(50)
     D  c3slot                 1     12
     D  c3pick                13     13
     *  Data structure for column 4.
     *
     D ds4             ds                  occurs(50)
     D  c4slot                 1     12
     D  c4pick                13     13
     *
     *  Data structure for column 5.
     *
     D ds5             ds                  occurs(50)
     D  c5slot                 1     12
     D  c5pick                13     13
     *----------------------------------------------------------------
     *
     D $perm           ds
     D  xxerm                  1     60
     D  $pmsg                  1      4
     *----------------------------------------------------------------
     *  Variables
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
     D c5              s              3  0
     D first           s              1
     D l               s              1  0
     D m               s                   like(l)
     D reccol          s              3  0
     D recpag          s              3  0
     D type            s              5
     D x               s              3  0
     *----------------------------------------------------------------
     Ioqrec
     I                                          slwhdp        l1
     I                                          slstyp
     I                                          sldesg
     I                                          slsdef
417 A*----------------------------------------------------------------
417 A*  Let the show begin .....
417 A*
417 AC     *entry        plist
417 AC                   parm                    $phead           50
417 A*
417 A*  Main line
417 A*
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
     *  Level 1 break - Dept
     *
     C                   if        *inl1
     C                   eval      l = 1
     C                   exsr      zrzero
     C                   endif
     *
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *  If slot is found in slotdgta, it is not to be printed.
     *
510 AC     sltdky        chain     slotdgta
510 AC                   if        not %found(slotdgta)
     *
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
     *
510 AC                   endif
     *
     *----------------------------------------------------------------
     *
     * Department Totals
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
     CLr                 eval      l = 3
     *
     CLr                 exsr      zrdetl
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
     *  Key List for Slotdgt file
     *
     C     sltdky        klist
     C                   kfld                    slwhse
     C                   kfld                    slwhdp
     C                   kfld                    sldisp
     *
     C                   time                    time
     C                   eval      first = *on
     C                   eval      count = 0
     C                   eval      l = 3
     C                   eval      x = 1
     C                   eval      c1 = 1
     C                   eval      c2 = 1
     C                   eval      c3 = 1
     C                   eval      c4 = 1
     C                   eval      c5 = 1
     C                   eval      reccol = 50
     C                   eval      recpag = 250
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
     C     'Dept:'       cat       slwhdp:1      p#desc
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
     C                   clear                   c0pick
     C                   clear                   c0slot
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
     C                   clear                   c0pick
     C                   clear                   c0slot
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
