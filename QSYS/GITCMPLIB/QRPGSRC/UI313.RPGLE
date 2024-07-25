     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     F*
     F*  UI313     Warehouse UCI Exception Report
     F*
     F*  September 12, 2006
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
     Fuiiexcp   uf   e           k disk
     F*
     FUI313pr   o    e             printer  oflind(*in90)
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
     C*
     C*----------------------------------------------------------------
     C*
     C* Detail Calcs
     C*
     C                   dow       not %eof
      *
     C                   read      uiiexcp
      *
     C                   if        %eof
     C                   goto      $total
     C                   endif
      *
     c                   if        uiesta = '1' or
     c                             uiesta = '2'
      *
     C                   exsr      zrdetl
     C   90              exsr      zrhead
     C   90              eval      *in90 = *off
      *
     C                   eval      uiesta = '2'
     c                   update    uierec
      *
     c                   endif
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

      *
     C                   time                    time
      *
     C                   exsr      zrhead
      *
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
     C*  Print detail line.
     C*
     C     zrdetl        begsr
     C*
     C                   write     detail1
     C                   eval      count = count + 1
     C*
     C                   endsr
     C*----------------------------------------------------------------
     O*
     O* Compile time tables
     O*
