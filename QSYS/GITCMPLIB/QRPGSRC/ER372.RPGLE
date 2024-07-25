      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ER372     Task report for an employee (Summary)
     *  24 March, 2000
     *  Hemant Kapadia
     *
     *  03.24.00  HNK  4.13
     *   Created
     *
     * Note: There was no ER242 program to replace.
     *
     *  Revisions:
     *
     *
600  *  07/22/09   GJA  5.30
     *     -Enh:  Convert to RPGLE, cleaned up and revamped for
     *            suspended transactions
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
     Fer371a    ip   e           k disk
     Ftask      if   e           k disk
     Fpiruser1  if   e           k disk
     Freporte   if   e           k disk
     Fer372pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     D rpd             s             25    dim(4) ctdata perrcd(1)
     D dte             s             22    dim(4) ctdata perrcd(1)
     D mtxt            s             21    dim(2) ctdata perrcd(1)
     D reck            s              7  0 dim(4)
     D lvlk            s              7  0 dim(4)
     *
     D dtot            s              7  2 dim(4)
     D ptot            s              7  0 dim(4)
     D itot            s              7  2 dim(4)
     *
     D a22             s              1    dim(22)
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
     *----------------------------------------------------------------
     *  Date redefinition data structure
     *
     D $pfmdt          ds
     D  $pfmcc                 1      2
     D  $pfmyy                 3      4
     D  $pfmmm                 5      6
     D  $pfmdd                 7      8
     D $ptodt          ds
     D  $ptocc                 1      2
     D  $ptoyy                 3      4
     D  $ptomm                 5      6
     D  $ptodd                 7      8
     *----------------------------------------------------------------
     *  Date redefinition data structure
     *
     D $cmd            s              8
     D $name           s             40
     D $plen           s              3  0
     D $pstr           s             60
     D $rpd            s             20
     D begin           s              1
     D emp#            s              5  0
     D first           s              1
     D l               s              1  0
     D m               s                   like(l)
     D n               s              3  0
     D svtrn#          s                   like(wktrn#)
     D wkprtf          s             10
     D w1dhrs          s              5  2
     D w1ihrs          s              5  2
     D w1trn#          s              7  0
     *
     *----------------------------------------------------------------
     Iwkrec
     I                                          wkemp#        l3
     I                                          wktask        l2
     I                                          wkwhdp        l1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PFMDT  From date (YYYYMMDD)
     *      $PTODT  To date (YYYYMMDD)
     *      $PWHSE  Warehouse number
     *      $PEMP#  Employee number
     *      $PMRG   Include merge pieces Y or N
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pfmdt
     C                   parm                    $ptodt
     C                   parm                    $pwhse            3
     C                   parm                    $pemp#            5
     C                   parm                    $pcrew            6
     C                   parm                    $pdmin            3
     C                   parm                    $pmrg             1
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *   Ignore any task befor BEGDAY Or begining of the shift time,
     *   if BEGDAY is missing in the transaction file.
     *
     *
     C                   eval      begin = *on
     *
     *  Report Heading
     *
     *
     *  Start new page if one of following happened.
     *     - Overflow occurred.
     *
     C                   if        *in90  or
     C                             first = *on
     C                   endif
     *
     *  Init total levels
     *
     *  Level 3 break - EMP#
     *
     C                   if        *inl3
     C                   eval      l = 3
     C                   exsr      zrzero
     C                   exsr      zrfrmt
     C                   exsr      zrhead
     C                   endif
     *
     *  Level 2 break - Task
     *
     C                   if        *inl2
     C                   eval      l = 2
     C                   exsr      zrzero
     *
     *     Get task description.
     *
     C     tkkey         chain     task                               79
     C                   if        *in79
     C                   eval      w1desc = *blanks
     C                   else
     C                   movel     tkdesc        w1desc
     C                   endif
     C                   endif
     *
     *  Level 1 break - Dept code
     *
     C                   if        *inl1
     C                   eval      l = 1
     C                   exsr      zrzero
     C                   endif
     *
     *  Print headings.
     *
     *
     *          *IN92     IFEQ *ON
     *          *INL2     OREQ *ON
     *                    ENDIF
     *
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     * Start date
     C                   if        wksdte <> 0
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      wksdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1sdte = $cvd6o
     C                   else
     C                   eval      w1sdte = 0
     C                   endif
     * End date
     *          WKEDTE    IFNE 0
     *                    MOVE '*CMDMDY '$CVCMD
     *                    MOVE WKEDTE    $CVD8I
     *                    CALL @CVTDT
     *                    PARM           $CVTDT
     *                    Z-ADD$CVD6O    W1EDTE
     *                    ELSE
     *                    Z-ADD0         W1EDTE
     *                    ENDIF
     *
     C                   eval      w1trn# = wktrn#
     C     wkdmin        div(h)    60            w1dhrs
     C     wkimin        div(h)    60            w1ihrs
     *
     *                    WRITEDETAIL1
     *
     *  Accumulate totals
     *
     C                   add       wkpcs         ptot(1)
     C                   if        wktrn# <> svtrn#
     C                   add       w1dhrs        dtot(1)
     C                   add       w1ihrs        itot(1)
     C                   endif
     C                   eval      svtrn# = wktrn#
     *
     *  Increment record counters
     *
     C                   add       1             reck(1)
     C                   add       1             lvlk(1)
     *
     *  Set off top-of-page indicators
     *
     C                   eval      *in92 = *off
     C                   eval      *in91 = *off
     C                   eval      first = *off
     *
     C     skip          tag
     *----------------------------------------------------------------
     *
     * Dept code break
     *
     CL1                 eval      l = 1
     CL1                 exsr      zrroll
     *
     CL1                 if        reck(l) > 0
     CL1                 exsr      zrtotl
     CL1                 write     detail1
     CL1                 write     skip1
     CL1                 endif
     *----------------------------------------------------------------
     *
     * Task break
     *
     CL2                 eval      l = 2
     CL2                 exsr      zrroll
     *
     CL2                 if        reck(l) > 0
     CL2                 endif
     *----------------------------------------------------------------
     *
     * Batch totals
     *
     CLr                 eval      l = 4
     *
     CLr                 if        reck(l) > 0
     CLr                 exsr      zrtotl
     CLr                 write     total1
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
     C     rpkey         klist
     C                   kfld                    wkprtf
     *
     C     tkkey         klist
     C                   kfld                    wktask
     *
     C                   time                    time
     C                   eval      first = *on
     C                   eval      l = 1
     C                   eval      n = 0
     C                   eval      begin = *off
     C                   exsr      zrzero
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrfrmt        begsr
     *
     *   Format report title.
     *
     *  Get report title.
     *
     C                   movel     'ER372PR '    wkprtf
     C                   eval      rptttl = *blanks
     C     rpkey         chain     reporte                            79
     C                   if        not *in79
     C                   movel     erdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
     C                   eval      $plen = 60
     *
     *   Center report title.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   eval      rptttl = $pstr
     *
     *  Format date range
     *
     C                   select
     C                   when      $pfmdt <> *blanks  and
     C                             $ptodt <> *blanks
     C                   movea     dte(1)        a22
     C                   movea     $pfmmm        a22(1)
     C                   movea     $pfmdd        a22(4)
     C                   movea     $pfmyy        a22(7)
     C                   movea     $ptomm        a22(15)
     C                   movea     $ptodd        a22(18)
     C                   movea     $ptoyy        a22(21)
     C                   movea     a22           dterng
     *
     C                   when      $pfmdt <> *blanks
     C                   movea     dte(2)        a22
     C                   movea     $pfmmm        a22(11)
     C                   movea     $pfmdd        a22(14)
     C                   movea     $pfmyy        a22(17)
     C                   movea     a22           dterng
     *
     C                   when      $ptodt <> *blanks
     C                   movea     dte(3)        a22
     C                   movea     $ptomm        a22(11)
     C                   movea     $ptodd        a22(14)
     C                   movea     $ptoyy        a22(17)
     C                   movea     a22           dterng
     *
     C                   other
     C                   movea     dte(4)        dterng
     *
     C                   endsl
     *
     *  Format merge pieces text
     C                   if        $pmrg = 'N'
     C                   move      mtxt(2)       mrgtxt
     C                   else
     C                   move      mtxt(1)       mrgtxt
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
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
     *
     *  Get employee name
     *
     C                   eval      emp# = wkemp#
     C     emp#          chain     piruser1                           79
     *
     C                   eval      $cmd = '*LFM    '
     C                   eval      $name = *blanks
     C                   call      'FRMTNM'
     C                   parm                    $cmd
     C                   parm                    usfnam
     C                   parm                    usinit
     C                   parm                    uslnam
     C                   parm                    $name
     C                   eval      wkname = $name
     C                   write     ephead
     *  Columns
     C                   write     columns
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrroll        begsr
     *
     C     l             add       1             m
     *
     C                   add       1             lvlk(m)
     C                   add       reck(l)       reck(m)
     *
     C                   add       dtot(l)       dtot(m)
     C                   add       ptot(l)       ptot(m)
     C                   add       itot(l)       itot(m)
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrtotl        begsr
     *
     C                   eval      t#dtot = dtot(l)
     C                   eval      t#ptot = ptot(l)
     C                   eval      t#itot = itot(l)
     C                   eval      t#tran = reck(l)
     *
     *
     C                   eval      $rpd = *blanks
     C                   movel     rpd(l)        $rpd
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrzero        begsr
     *
     C                   eval      lvlk(l) = 0
     C                   eval      reck(l) = 0
     *
     C                   eval      dtot(l) = 0
     C                   eval      ptot(l) = 0
     C                   eval      itot(l) = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
**      rpd   Report level descriptions
 * Employee *
 * Task totals *
 ** Department **
 *** Totals
**      dte   Date headings
99/99/99 thru 99/99/99
     From 99/99/99
     Thru 99/99/99

**     mtxt  Merge pieces text
 Merge pieces included
 Merge pieces excluded
