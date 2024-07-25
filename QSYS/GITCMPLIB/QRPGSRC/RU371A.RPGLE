     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  RU371A    Cleared flags report (by time diff.)
     *  November 9, 2004
     *  Jose Duque
     *
     *  Revisions:
     *
500 A*    05/20/05  MLD  5.00
     *      - Fix: Change size of field rec# to 9,0.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions
     *
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
     Fru371a    ip   e           k disk
     Fwarehs    if   e           k disk
     Fru371apr  o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *  Working variables
     *
     D $plen           s              3  0
     D $pstr           s             60
     D count           s              3  0
     D first           s              1
     D holdit          s             26
     D rec#            s              9  0
     D recpag          s              3  0
     *----------------------------------------------------------------
     *  Data structure To hold flag Open, Print and Close times.
     *
     D                 ds
     D  hldtim                 1      6
     D  hldhr                  1      2
     D  hldmm                  3      4
     D  hldss                  5      6
     *----------------------------------------------------------------
     *
     *  Report Heading
     *
     *
     *  Start new page if one of following happened.
     *     - Level break occurred.
     *     - Filled page.
     *
     *
     C     *entry        plist
     C                   parm                    $sdte6            6
     C                   parm                    $pdte6            6
     *
     *
     C                   if        first = *on
     C                   exsr      zrfrmt
     C                   exsr      zrhead
     C                   eval      first = *off
     C                   endif
     *
     C                   if        count = recpag
     C                   exsr      zrhead
     C                   endif
     *
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *
     C                   if        rustat <> 'D'
     C                   exsr      zrdetl
     C                   endif
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *
     * REPORT TOTALS
     *
     CLr                 if        rec# > 0
     CLr                 write     skip1
     CLr                 write     totflg
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
500 D**                   Z-ADD0         REC#    30
500 MC                   eval      rec# = 0
     C                   eval      count = 0
     C                   eval      recpag = 55
     C                   eval      wtotfl = *zeros
     C                   move      $pdte6        frmdte
     C                   move      $sdte6        todte
     *
     *                    EXSR ZRFRMT
     *                    EXSR ZRHEAD
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
     C     ruwhse        chain     warehs                             79
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
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     C                   eval      *in90 = *off
     *
     *  Print headings for the next page.
     *
     C                   write     head1
     C                   write     columns
     *
     *
     *  Print previous page detail lines.
     *
     C                   eval      count = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrcler        begsr
     *
     *   Initialize all data structures.
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrdetl        begsr
     *
     *
     *          Move flag start,close and diff times to report
     *
     C                   eval      hldhr = %subst(ruodtt:1:2)
     C                   eval      hldmm = %subst(ruodtt:3:2)
     C                   eval      hldss = %subst(ruodtt:5:2)
     C                   move      hldtim        w1strt
     *
     C                   eval      holdit = rucdts
     *
     C                   eval      hldhr = %subst(holdit:12:2)
     C                   eval      hldmm = %subst(holdit:15:2)
     C                   eval      hldss = %subst(holdit:18:2)
     C                   move      hldtim        w1clst
     *
     C                   eval      w1diff = rhshpt
     *
     *          Find type of flag
     *
     C                   eval      w1type = *blanks
     C                   select
     C                   when      rutype = 'N'
     C                   movel     'REPL'        w1type
     *
     C                   when      rutype = 'U'
     C                   movel     'OUT'         w1type
     *
     C                   when      rutype = 'M'
     C                   movel     'MERGE'       w1type
     *
     C                   endsl
     *
     *
     *  Print detail line.
     C                   write     detail1
     C                   add       1             count
     C                   add       1             rec#
     C                   add       1             wtotfl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *
     C     zrtotl        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrzero        begsr
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
