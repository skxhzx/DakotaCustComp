     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     F*
     F*  SD302     Print Check Digit Exceptions Report
     F*
     F*  November 21, 2006
     F*  Randy Haselhorst
     F*
     F*  Revisions:
     F*
510aAF*    12/05/06  JCJ  5.10a
     F*      - Enh: Added from and to dates to recieving parms.
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
     Fsltdgtex  if   e           k disk
     Fwhdept    if   e           k disk
     Fpiruser1  if   e           k disk
     Flabel     if   e           k disk
     Fpiritem   if   e           k disk
     F*
     Fsd302pr   o    e             printer  oflind(*in90)
      *
      *----------------------------------------------------------------
     D keyds           ds
     D  key                    1      1  0

      *----------------------------------------------------------------
      * Variables
      *----------------------------------------------------------------

     D $whse           s              3  0
     D $emp            s              5  0
510aAD $empa           s              5
     D $whsea          s              3
     D forever         s              1
     D $hemp           s              5  0
     D $hdept          s              5
510aAD $dept           s              5
510aAD workdate        s              8  0
510aAD $pfmdt          s              8
510aAD $ptodt          s              8
510aAD ISODate         s               d   datfmt(*iso)
510aAD MDYDate         s               d   datfmt(*mdy)
510aAD $fmdt           s              8
510aAD $todt           s              8
510aAD dterng          s             22
510aAD FmTime          s               t   timfmt(*iso)
510aAD ToTime          s               t   timfmt(*iso)

      *----------------------------------------------------------------
      *
      *  Mainline
      *
      *
     C     *entry        plist
     C                   parm                    $whsea
     C                   parm                    $dept
     C                   parm                    $empa
     C                   parm                    $pfmdt
     C                   parm                    $ptodt
     C*
     C*----------------------------------------------------------------
     C*
     C* Detail Calcs
      *
     C                   dow       not %eof
      *
      * Check for level breaks
      *
     c                   if        sdewhd <> $hdept
     c                   exsr      whdpbreak
     c                   exsr      empbreak
     c                   eval      $hdept = sdewhd
     c                   eval      $hemp  = sdeemp
     c                   else
     c                   if        sdeemp <> $hemp
     c                   exsr      empbreak
     c                   endif
     c                   endif
      *
     c     sdelbl        chain     label
     c                   if        %found
     c     itmkey        chain     piritem
     c                   if        not %found
     c                   eval      itdesc = *blanks
     c                   endif
     c                   else
     c                   eval      itdesc = *blanks
     c                   endif
      *
     C                   exsr      zrdetl
     C   90              exsr      zrhead
     C   90              eval      *in90 = *off
      *
     c                   eval      $hdept = sdewhd
     c                   eval      $hemp  = sdeemp
     C                   read      sltdgtex
     C                   enddo
      *
      *----------------------------------------------------------------
      *
      * Report Totals
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
     c                   move      $whsea        $whse             3 0
     c                   move      $empa         $emp              5 0
      *
     c     deptkey       klist
     c                   kfld                    $whse
     c                   kfld                    sdewhd
     c     itmkey        klist
     c                   kfld                    $whse
     c                   kfld                    lbitem
      *
510aAc                   move      $pfmdt        workdate
510aAc     *ISO          move      workdate      ISOdate
510aAc                   move      ISOdate       MDYdate
510aAc                   move      MDYdate       $fmdt
510aA *
510aAc                   move      $ptodt        workdate
510aAc     *ISO          move      workdate      ISOdate
510aAc                   move      ISOdate       MDYdate
510aAc                   move      MDYdate       $todt
510aA *
510aAc                   eval      dterng = %trim($fmdt) + ' Thru ' +
510aAc                                      %trim($todt)
510aA *
     c                   if        $emp = *zero
     c                   move      '*ALL '       $empa
     c                   endif
      *
     C                   read      sltdgtex
     c                   eval      $hdept = sdewhd
     c                   eval      $hemp  = sdeemp
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
     C                   exsr      whdpbreak
     C                   exsr      empbreak
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
     C*  Print warehouse break line.
     C*
     C     whdpbreak     begsr
     C*
     c     deptkey       chain     whdept
     c                   if        not %found
     c                   move      *blanks       wddesc
     c                   endif
     C*
     C                   write     whdp
     C*
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  Print employee break line.
     C*
     C     empbreak      begsr
     C*
     c     sdeemp        chain     piruser1
     c                   if        not %found
     c                   eval      $empnam = *blanks
     c                   else
     C                   eval      $empnam = %trimr(usfnam) + ' ' + uslnam
     c                   endif
     C*
     C                   write     emp
     C*
     C                   endsr
     C*----------------------------------------------------------------
     c*
     c* Compile time tables
     c*
