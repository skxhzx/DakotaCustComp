     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     F*
     F*  UI311     Warehouse Quantity UCI Report
     F*
     F*  September 5, 2006
     F*  Randy Haselhorst
     F*
     F*  Revisions:
     F*
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  79        Not on file/End of file indicator
     F*  90        Overflow Indicator
     F*  9X        Top of page and level X continues.
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     Fpiritem   IF   E           K DISK
     Fpiritem1  IF   E           K DISK
     F                                     rename(itrec:record)
      *
     FITEMQTY   IF   E           K DISK
     F*
     FUI311pr   o    e             printer  oflind(*in90)
      *
      *----------------------------------------------------------------
     D keyds           ds
     D  key                    1      1  0

      *----------------------------------------------------------------
      * Variables
      *----------------------------------------------------------------

     D $whse           s              3  0
     D $whsea          s              3
     D forever         s              1

      *----------------------------------------------------------------
      *
      *  Mainline
      *
      *
     C     *entry        plist
     C                   parm                    $whsea
     C                   parm                    $dept             5
     C                   parm                    $item            15
     C                   parm                    $var              1
     C*
     C*----------------------------------------------------------------
     C*
     C* Detail Calcs
     C*
     C                   dow       not %eof
      *
     C                   if        key = 1
     C     key1          reade     piritem
     C                   endif
      *
     C                   if        key = 2
     C     key2          reade     piritem
     C                   endif
      *
     C                   if        key = 3
     C     key3          reade     piritem1
     C                   endif
      *
     C                   if        key = 4
     C     key4          reade     piritem1
     C                   endif
      *
     C                   if        %eof
     C                   goto      $total
     C                   endif
      *
     C                   eval      $item = ititem
      *
     C                   if        key = 1 or key = 3
     C                   if        itcwgt = 'N'
     C                   goto      next
     C                   endif
     C                   endif
      *
     C     key2          chain     itemqty
      *
     C*                  movel     $whse         $whsea
     C                   call      'UCIICNT'
     C                   parm                    $whsea
     C                   parm                    $item
     C                   parm                    $uciqty           5 0
      *
     C                   if        var = 'YES' and
     C                             iqstk1 = $uciqty
     C                   goto      next
     C                   endif
      *
     C                   exsr      zrdetl
     C   90              exsr      zrhead
     C   90              eval      *in90 = *off
      *
     C     next          tag
      *
     C                   enddo
      *
      *----------------------------------------------------------------
      *
      * Report Totals
      *
     C     $total        tag
      *
     C                   if        count > 0
     C                   write     totals
     C                   else
     C                   write     nototal
     C                   endif
      *
     C                   eval      *inlr = *on
      *
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
      *----------------------------------------------------------------
      *
      *  *INZSR  Initialization subrotine
      *
     C     *inzsr        begsr

     C                   move      $whsea        $whse

     C     key1          klist
     C                   kfld                    $whse

     c     key2          klist
     C                   kfld                    $whse
     C                   kfld                    $item

     c     key3          klist
     C                   kfld                    $whse
     C                   kfld                    $dept
      *
     c     key4          klist
     C                   kfld                    $whse
     C                   kfld                    $dept
     C                   kfld                    $item
      *
     C                   if        $dept = '*ALL' and
     C                             $item = '*ALL'
     C                   eval      key = 1
     C     key1          setll     piritem
     C                   endif
      *
     C                   if        $dept <> '*ALL' and
     C                             $item = '*ALL'
     C                   eval      key = 3
     C     key3          setll     piritem1
     C                   endif
      *
     C                   if        $dept = '*ALL' and
     C                             $item <> '*ALL'
     C                   eval      key = 2
     C     key2          setll     piritem
     C                   endif
      *
     C                   if        $dept <> '*ALL' and
     C                             $item <> '*ALL'
     C                   eval      key = 4
     C     key4          setll     piritem1
     C                   endif
      *
     C                   TIME                    TIME
      *
     C                   if        $var = 'Y'
     C                   eval      var = 'YES'
     C                   else
     C                   eval      var = 'NO '
     C                   endif
      *
     C                   exsr      zrhead
     C                   exsr      zrcler
     C                   exsr      zrzero
     C                   exsr      zrfrmt
      *
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C     zrfrmt        begsr
     C*
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C     zrhead        begsr
     C*
     C                   eval      *in90 = *off
     C*
     C*  Print headings for the next page.
     C*
     C                   write     head1
     C                   write     head2
     C                   write     columns
     C*
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C     zrcler        begsr
     C*
     C*   Initialize all data structures.
     C*
     C*
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  Print detail line.
     C*
     C     zrdetl        begsr
     C*
     C                   write     detail1
     C                   eval      count = count + 1
     C*
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*
     C     zrtotl        begsr
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C     zrzero        begsr
     C*
     C                   endsr
     O*----------------------------------------------------------------
     O*
     O* Compile time tables
     O*
