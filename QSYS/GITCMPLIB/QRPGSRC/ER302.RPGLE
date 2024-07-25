     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ER302     Employee management report for an employee(Summary)
     *            (RECV)
     *  20 February, 1996
     *  Hemant Kapadia
     *
     *  Revisions:
     *
640a *  11/22/11     GJA     6.40a
     *         -Enh:  Add vendor name, weight, cubes, start/end
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
     Fer3011    ip   e           k disk
640aAFpohhdr    if   e           k disk
640aAFpohdtl    if   e           k disk
640aAFpiritem   if   e           k disk
     Freporte   if   e           k disk
     Fer302pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *                   RPD     1   2 25
     D rpd             s              8    dim(2) ctdata perrcd(1)
     D reck            s              7  0 dim(2)
     D lvlk            s              7  0 dim(2)
     *
     D ptot            s              7  0 dim(2)
     D ctot            s              7  0 dim(2)
     D ttot            s              7  0 dim(2)
     D wtot            s              7  0 dim(2)
     D wtotr           s              7  0 dim(2)
     D ctotr           s              7  0 dim(2)
     *
     D dte             s             22    dim(4) ctdata perrcd(1)
     D a22             s              1    dim(22)
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
     *  Variables
     *
     D $plen           s              3  0
     D $pstr           s             60
     D $rpd            s              8
     D first           s              1
     D l               s              1  0
     D m               s                   like(l)
     D n               s              3  0
     D wkprtf          s             10
     D begdte          s              8  0
     D begtim          s              6  0
     D enddte          s              8  0
     D endtim          s              6  0
     D $tdtetme        s               z
     D $fdtetme        s               z
     D wksdtec         s              8
     D wkedtec         s              8
     D wkstimc         s              6
     D wketimc         s              6
     D tdtetme         s             26
     D fdtetme         s             26
     D dhrs            s              7  2
     D ihrs            s              7  2
     D dmins           s              5  0
     D dsecs           s              5  0
530bAD dhrsi           s              7  2
530bAD dsecsi          s              5  0
     D wkdmin          s              7  2
     D wkdsec          s              5  0
530bAD forever         s              1
     *
     *----------------------------------------------------------------
     Iwkrec
     I                                          wkpo          l1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PFMDT  From date (YYYYMMDD)
     *      $PTODT  To date (YYYYMMDD)
     *      $PWHSE  Warehouse number
     *      $PEMP#  Employee number
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
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *
     *  Report Heading
     *
     *  Get beginning date and time
     *
     C                   if        first = *on
     C                   eval      begdte = wkrdte
     C                   eval      begtim = wkrtim
     C                   eval      enddte = wkrdte
     C                   eval      endtim = wkrtim
     C                   endif
     *
     C                   select
     *
     C                   when      wkrdte < begdte
     C                   eval      begdte = wkrdte
     C                   eval      begtim = wkrtim
     *
     C                   when      wkrdte = begdte and
     C                             wkrtim < begtim
     C                   eval      begtim = wkrtim
     *
     C                   when      wkrdte > enddte
     C                   eval      enddte = wkrdte
     C                   eval      endtim = wkrtim
     *
     C                   when      wkrdte = enddte and
     C                             wkrtim > endtim
     C                   eval      endtim = wkrtim
     C                   endsl
     *
     *  Start new page if one of following happened.
     *     - Overflow occurred.
     *
     C                   if        *in90  or
     C                             first = *on
     C                   exsr      zrfrmt
     C                   exsr      zrhead
     C                   endif
     *
     *  Init total levels
     *
     *  Level 1 break - Date
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
     *
     * Transaction date
     C                   if        wkrdte <> 0
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      wkrdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      gtdate = $cvd6o
     C                   else
     C                   eval      gtdate = 0
     C                   endif
     *
     *  Accumulate totals
     *
     C                   add       wkpcs         wkptot
     C                   add       1             wkttot
     C                   add       wkwgt         powgtr
     C                   add       wkcube        pocber
     C                   if        wkrtim < stime or stime=*zeros
     C                   eval      stime =  wkrtim
     C                   endif
     *
     C                   if        wkrtim > etime or etime=*zeros
     C                   eval      etime = wkrtim
     C                   endif
     *
     *  Increment record counters
     *
     C                   add       1             reck(1)
     C                   add       1             lvlk(1)
     *
     *  Set off top-of-page indicators
     *
     C                   eval      *in91 = *off
     C                   eval      first = *off
     *----------------------------------------------------------------
     *
     * Transaction date break
     *
     CL1                 eval      l = 1
     *
     CL1                 if        reck(l) > 0
     CL1                 exsr      zzinfo
     CL1                 z-add     pocbe         ctot(1)
     CL1                 z-add     powgt         wtot(1)
     CL1                 z-add     wkptot        ptot(1)
     CL1                 z-add     wkttot        ttot(1)
     CL1                 z-add     powgtr        wtotr(1)
     CL1                 z-add     pocber        ctotr(1)
     CL1                 exsr      zrroll
     CL1                 eval      difpcs = ordpcs - rcvpcs
     CL1                 write     detail1
     CL1                 write     skip1
     CL1                 endif
     CL1                 eval      wkptot = *zeros
     CL1                 eval      wkttot = *zeros
     CL1                 eval      stime  = *zeros
     CL1                 eval      etime  = *zeros
     CL1                 eval      ordpcs = *zeros
     CL1                 eval      rcvpcs = *zeros
     CL1                 eval      powgtr = *zeros
     CL1                 eval      pocber = *zeros
     CL1                 eval      powgt  = *zeros
     CL1                 eval      pocbe  = *zeros
     *----------------------------------------------------------------
     *
     * Batch totals
     *
     CLr                 eval      l = 2
     *
     CLr                 if        reck(l) > 0
     CLr                 exsr      zzdte
     CLr                 exsr      zrtotl
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
640aAC     keypo         klist
640aAC                   kfld                    wkwhse
640aAC                   kfld                    wkpo
     *
640aAC     keyit         klist
640aAC                   kfld                    wkwhse
640aAC                   kfld                    phditm
     *
     C                   time                    time
     C                   eval      first = *on
     C                   eval      l = 1
     C                   eval      n = 0
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
     C                   movel     'ER302PR '    wkprtf
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
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     C                   if        not *inl1
     C                   eval      *in91 = *on
     C                   endif
     *
     C                   eval      *in90 = *off
     *
     C                   write     head1
     C                   write     head2
     *
     *  Get employee name
     *
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
     C                   add       ptot(l)       ptot(m)
     C                   add       ttot(l)       ttot(m)
     C                   add       wtot(l)       wtot(m)
     C                   add       ctot(l)       ctot(m)
     C                   add       wtotr(l)      wtotr(m)
     C                   add       ctotr(l)      ctotr(m)
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrtotl        begsr
     *
     C                   eval      t#ptot = ptot(l)
     C                   eval      t#ttot = ttot(l)
     C                   eval      t#wtot = wtot(l)
     C                   eval      t#ctot = ctot(l)
     C                   eval      t#wtotr = wtotr(l)
     C                   eval      t#ctotr = ctotr(l)
     *                    Z-ADDRECK,L    T#RECK
     *
     C                   eval      $rpd = rpd(l)
     *
     C                   write     total1
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrzero        begsr
     *
     C                   eval      lvlk(l) = 0
     C                   eval      reck(l) = 0
     *
     C                   eval      ptot(l) = 0
     C                   eval      ttot(l) = 0
     C                   eval      wtot(l) = 0
     C                   eval      ctot(l) = 0
     C                   eval      wtotr(l) = 0
     C                   eval      ctotr(l) = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zzdte         begsr
     C                   move      begdte        wksdtec
     C                   move      enddte        wkedtec
     C                   move      begtim        wkstimc
     C                   move      endtim        wketimc
     C                   eval      fdtetme=%subst(wksdtec:1:4) + '-' +
     C                             %subst(wksdtec:5:2) + '-' +
     C                             %subst(wksdtec:7:2) + '-' +
     C                             %subst(wkstimc:1:2) + '.' +
     C                             %subst(wkstimc:3:2) + '.'   +
     C                             %subst(wkstimc:5:2) + '.000000'
     C                   eval      tdtetme=%subst(wkedtec:1:4) + '-' +
     C                             %subst(wkedtec:5:2) + '-' +
     C                             %subst(wkedtec:7:2) + '-' +
     C                             %subst(wketimc:1:2) + '.' +
     C                             %subst(wketimc:3:2) + '.' +
     C                             %subst(wketimc:5:2) + '.000000'
     C                   move      tdtetme       $tdtetme
     C                   move      fdtetme       $fdtetme
     C     $tdtetme      subdur    $fdtetme      dmins:*mn
     C     $tdtetme      subdur    $fdtetme      dsecs:*s
     C     dsecs         div       60            wkdmin
     C                   mvr                     wkdsec
     C     wkdsec        div(h)    60            dsecs
     C     wkdmin        div(h)    60            dhrs
     C                   add       dsecs         dhrs
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zzinfo        begsr
     *
     C     keypo         chain     pohhdr
     C                   if        %found(pohhdr)
     *
     C     keypo         setll     pohdtl
     C                   dow       forever = forever
     C     keypo         reade     pohdtl
     C                   if        not %EOF(pohdtl)
     C                   add       phdqo1        ordpcs
     C                   add       phdqr1        rcvpcs
     C     keyit         chain     piritem
     C                   if        %found(piritem)
     C                   eval      powgt += phdqr1 * itswgt
     C                   eval      pocbe += phdqr1 * itcube
     C                   endif
     C                   else
     C                   leave
     C                   endif
     C                   enddo
     *
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
**      RPD   Report level descriptions

 Totals
**      DTE   Date headings
99/99/99 thru 99/99/99
     From 99/99/99
     Thru 99/99/99

