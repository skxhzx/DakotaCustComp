530 A /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  IT341     Unslotted items report
     *  01 September, 1994
     *  Hemant Kapadia
     *
     *  Revisions:
530  *    11/17/10   GJA   5.30
     *      - Converted to RPGLE
530a *    11/17/10   GJA   5.30a
     *      - Enh:  Add client code processing
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Custom Client Revisions:  Glazier
GFCa *    11/17/10   GJA   GFCa
     *      - Enh:  Only show items with a quantity
GFCb *    11/17/10   GJA   GFCb
     *      - Enh:  Check to make sure there is no PO quantity
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
     Fit341     ip   e           k disk
     Fwarehs    if   e           k disk
GFCaAFitemqty   if   e           k disk
GFCbAFpodtl5    if   e           k disk
     Fit341pr   o    e             printer oflind(*in90)
530aA*------------------------------------------------------------------
530aA*  Client id's for custom mods.
530aA*------------------------------------------------------------------
GFCaA /copy qcopysrc,id#glazier
530aAD client          s             10
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *                   RPD     1   3 30
     D reck            s              7  0 dim(3)
     *----------------------------------------------------------------
     *
     *  Variables
     *
     D $plen           s              3  0
     D $pstr           s             60
     D count           s              3  0
     D c1              s              3  0
     D c2              s              3  0
     D c3              s              3  0
     D first           s              1
     D l               s              1  0
     D m               s                   like(l)
     D reccol          s              3  0
     D recpag          s              3  0
     D x               s              3  0
     *----------------------------------------------------------------
     *  General Data structure.
     *
     D ds0             ds
     D  c0item                 1     15
     D  c0desc                16     40
     *  Data structure for column 1.
     *
     D ds1             ds                  occurs(50)
     D  c1item                 1     15
     D  c1desc                16     40
     *
     *  Data structure for column 2.
     *
     D ds2             ds                  occurs(50)
     D  c2item                 1     15
     D  c2desc                16     40
     *
     *  Data structure for column 3.
     *
     D ds3             ds                  occurs(50)
     D  c3item                 1     15
     D  c3desc                16     40
     *----------------------------------------------------------------
     *
     D $perm           ds
     D  xxerm                  1     60
     D  $pmsg                  1      4
     *
     *----------------------------------------------------------------
     Ioqrec
     I                                          itwhdp        l1
     I                                          itstyp        l1
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
     *  Level 1 break - Slot type
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
GFCaAC                   if        client = glazier
GFCaAC     itkey         chain     itemqty
GFCaAC                   if        not %found(itemqty) or
GFCaAC                             iqstk1 = 0 and
GFCaAC                             iqstk2 = 0 and
GFCaAC                             iqstk3 = 0
GFCbAC     pokey         chain     podtl5
GFCbAC                   if        not %found(podtl5)
GFCbAC                   goto      noprint
GFCbAC                   endif
GFCaAC                   endif
GFCaAC                   endif
     *
     C                   eval      c0item = ititem
     C                   movel     itdesc        c0desc
     *
     *  Store info. from first 50 records into data structure DS1.
     *  Next 50 records into DS2 and then into DS3.
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
GFCaAC     noprint       tag
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
530aA*  Get client id

530aAC                   call      'GETCLIENT'
530aAC                   parm                    client

GFCaA*  ITEMQTY

GFCaAC     itkey         klist
GFCaAC                   kfld                    itwhse
GFCaAC                   kfld                    ititem

GFCbA*  PODTL5

GFCbAC     pokey         klist
GFCbAC                   kfld                    itwhse
GFCbAC                   kfld                    ititem
     C                   time                    time
     C                   eval      first = *on
     C                   eval      count = 0
     C                   eval      l = 3
     C                   eval      x = 1
     C                   eval      c1 = 1
     C                   eval      c2 = 1
     C                   eval      c3 = 1
     C                   eval      reccol = 50
     C                   eval      recpag = 150
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
     C     itwhse        chain     warehs                             79
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
     *  Format department/section.
     *
     C                   eval      type = *blanks
     C     itwhdp        cat       '/':0         type
     C                   if        itstyp = 'P'
     C     type          cat       'PIR':0       type
     C                   else
     C     type          cat       'FIXED':0     type
     C                   endif
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
     *  Print headings for the next page.
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
     C                   clear                   c0item
     C                   clear                   c0desc
     C     1             do        reccol        x
     C     x             occur     ds1
     C                   eval      ds1 = ds0
     C     x             occur     ds2
     C                   eval      ds2 = ds0
     C     x             occur     ds3
     C                   eval      ds3 = ds0
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrdetl        begsr
     *  Print detail line.
     C                   clear                   c0item
     C                   clear                   c0desc
     C     1             do        reccol        x
     C     x             occur     ds1
     C     x             occur     ds2
     C     x             occur     ds3
     C                   write     detail1
     C                   eval      ds1 = ds0
     C                   eval      ds2 = ds0
     C                   eval      ds3 = ds0
     C                   enddo
     *
     *  Initialize record counters for each columns.
     *
     C                   eval      c1 = 1
     C                   eval      c2 = 1
     C                   eval      c3 = 1
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
