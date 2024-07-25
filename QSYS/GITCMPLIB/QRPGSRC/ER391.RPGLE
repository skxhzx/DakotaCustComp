      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ER391     Task Summary by Crew - Print
     *  09 December, 2009
     *  Ginger Andrews
     *
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
     *  12/09/09  GJA  5.30
     *  - Created
     *
640a *  02/06/11  GJA  6.40a
     *  - Fix:  Add loader pieces per hour and transaction per hour
     *
     *****************************************************************
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
     Fer391a    ip   e           k disk
     Freporte   if   e           k disk
     Fcrew      if   e           k disk
     Fer391pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *                   RPD     1   3 25
     D rpd             s             10    dim(3) ctdata perrcd(1)
     D reck            s              7  0 dim(3)
     D lvlk            s              7  0 dim(3)
     *
     D whd             s              5    dim(99)
     D sec             s              1    dim(99)
     D wds             s              6    dim(99)
     D pcs             s              7  0 dim(99)
     *
     D whdt            s              5    dim(99)
     D pcst            s              7  0 dim(99)
     *
     D ptot            s              9  0 dim(99)
     *
     D dte             s             22    dim(4) ctdata perrcd(1)
     D tme             s             22    dim(1) ctdata perrcd(1)
     D mrg             s             45    dim(1) ctdata perrcd(1)
     D a22             s              1    dim(22)
     *
     *----------------------------------------------------------------
     *ECORD
     *                                             ERSDTEL1
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
     D $pbtim          ds
     D  $pbhrs                 1      2
     D  $pbmin                 3      4
     D  $pbsec                 5      6
     D $petim          ds
     D  $pehrs                 1      2
     D  $pemin                 3      4
     D  $pesec                 5      6
     *----------------------------------------------------------------
     *  Variables
     *
     D $cmd            s              8
     D $name           s             40
     D $plen           s              3  0
     D $pstr           s             60
     D begtim          s              6  0
     D dayolp          s              4
     D enddte          s              8  0
     D endtim          s              6  0
     D first           s              1
     D frmdte          s              8  0
     D i               s              3  0
     D l               s              1  0
     D n               s              3  0
     D tmpwhd          s              5
     D wkprtf          s             10
     D w1wds           s              6
     D w2whdp          s              5
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
     C                   parm                    $pwhse            3
     C                   parm                    $pemp#            5
     C                   parm                    $pcrew            6
     C                   parm                    $pfmdt
     C                   parm                    $ptodt
     C                   parm                    $pbtim
     C                   parm                    $petim
     C                   parm                    $pmrg             1
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *
     *  Report Heading
     *
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
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     C                   eval      $cmd = '*LFM    '
     C                   eval      $name = *blanks
     C                   call      'FRMTNM'
     C                   parm                    $cmd
     C                   parm                    wkfnam
     C                   parm      ' '           wkinit            1
     C                   parm                    wklnam
     C                   parm                    $name
     C                   movel     $name         wkname
     *
     C                   exsr      zrsumr
     *
     C                   exsr      zzperhour
     *
     C                   write     detail1
     *
     C                   write     draw1
     *
     *  Set off top-of-page indicators
     *
     C                   eval      *in92 = *off
     C                   eval      *in91 = *off
     *
     C     skip          tag
     *
     C                   eval      first = *off
     *----------------------------------------------------------------
     *
     * Totals
     *
     CLr                 if        first = *off
     C*r                 exsr      zrsumr
     * Summary totals
     CLr                 write     columns
     CLr                 exsr      zrsumt
     CLr                 exsr      zrtotl
     CLR                 else
     CLR                 exsr      zrfrmt
     CLR                 exsr      zrhead
     CLR                 endif
     * Footer
     CLr                 write     skip1
     CLr                 write     foot1
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
     C     crkey         klist
     C                   kfld                    wkwhse            3 0
     C                   kfld                    wkcrew
     *
     C                   movel     $pcrew        wkcrew
     C                   move      $pwhse        wkwhse
     C     crkey         chain     crew                               79
     C                   if        not *in79
     C                   movel     crdesc        wkdesc
     C                   else
     C                   eval      wkdesc = *blanks
     C                   endif
     *
     C     rpkey         klist
     C                   kfld                    wkprtf
     *
     C                   move      $pbtim        begtim
     C                   move      $petim        endtim
     C                   move      $pfmdt        frmdte
     C                   move      $ptodt        enddte
     C                   movel     $pcrew        wkcrew
     C                   time                    time
     C                   eval      first = *on
     C                   eval      l = 1
     C                   eval      n = 0
     *
     C                   if        $pmrg = 'N'
     C                   eval      mrgtxt = mrg(1)
     C                   else
     C                   eval      mrgtxt = *blanks
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrfrmt        begsr
     *
     *   Format report title.
     *
     *  Get report title.
     *
     C                   movel     'ER391PR '    wkprtf
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
     *  Format TIME range
     *
     C                   eval      a22 = *blanks
     C                   movea     tme(1)        a22
     C                   movea     $pbhrs        a22(1)
     C                   movea     $pbmin        a22(4)
     C                   movea     $pbsec        a22(7)
     C                   movea     $pehrs        a22(15)
     C                   movea     $pemin        a22(18)
     C                   movea     $pesec        a22(21)
     C                   movea     a22           tmerng
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     C                   eval      *in90 = *off
     *
     C                   write     head1
     *  Columns
     C                   write     columns
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zzperhour     begsr
     *
     *  future enhancments
     C*                  eval      wkrecvph = *zeros
     C*                  eval      wkrecvth = *zeros
     C*                  if        wkrecvh > 0
     C*    wkrecvp       div(h)    wkrecvh       wkrecvph
     C*                  if        wkrecv > 0
     C*    wkrecv        div(h)    wkrecvh       wkrecvth
     C*                  endif
     C*                  endif
     C                   eval      wkputph = *zeros
     C                   eval      wkputth = *zeros
     C                   if        wkputh > 0
     C     wkputp        div(h)    wkputh        wkputph
     C                   if        wkput > 0
     C     wkput         div(h)    wkputh        wkputth
     C                   endif
     C                   endif
     C                   eval      wkreplph = *zeros
     C                   eval      wkreplth = *zeros
     C                   if        wkreplh > 0
     C     wkreplp       div(h)    wkreplh       wkreplph
     C                   if        wkrepl > 0
     C     wkrepl        div(h)    wkreplh       wkreplth
     C                   endif
     C                   endif
     C                   eval      wktfrph = *zeros
     C                   eval      wktfrth = *zeros
     C                   if        wktfrh > 0
     C     wktfrp        div(h)    wktfrh        wktfrph
     C                   if        wktfr > 0
     C     wktfr         div(h)    wktfrh        wktfrth
     C                   endif
     C                   endif
     C                   eval      wkvrfyph = *zeros
     C                   eval      wkvrfyth = *zeros
     C                   if        wkvrfyh > 0
     C     wkvrfyp       div(h)    wkvrfyh       wkvrfyph
     C                   if        wkvrfy > 0
     C     wkvrfy        div(h)    wkvrfyh       wkvrfyth
     C                   endif
     C                   endif
640aAC                   eval      wkloadph = *zeros
640aAC                   eval      wkloadth = *zeros
640aAC                   if        wkloadh > 0
640aAC     wkloadp       div(h)    wkloadh       wkloadph
640aAC                   if        wkload > 0
640aAC     wkload        div(h)    wkloadh       wkloadth
640aAC                   endif
640aAC                   endif
     C                   eval      wkfixph = *zeros
     C                   eval      wkfixth = *zeros
     C                   if        wkfixh > 0
     C     wkfixp        div(h)    wkfixh        wkfixph
     C                   if        wkfix > 0
     C     wkfix         div(h)    wkfixh        wkfixth
     C                   endif
     C                   endif
     C                   eval      wkpirph = *zeros
     C                   eval      wkpirth = *zeros
     C                   if        wkpirh > 0
     C     wkpirp        div(h)    wkpirh        wkpirph
     C                   if        wkpir > 0
     C     wkpir         div(h)    wkpirh        wkpirth
     C                   endif
     C                   endif
     *  future enhancments
     C*                  eval      wkrtnph = *zeros
     C*                  eval      wkrtnth = *zeros
     C*                  if        wkrtnh > 0
     C*    wkrtnp        div(h)    wkrtnh        wkrtnph
     C*                  if        wkrtn > 0
     C*    wkrtn         div(h)    wkrtnh        wkrtnth
     C*                  endif
     C*                  endif
     C                   eval      wkprtnph = *zeros
     C                   eval      wkprtnth = *zeros
     C                   if        wkprtnh > 0
     C     wkprtnp       div(h)    wkprtnh       wkprtnph
     C                   if        wkprtn > 0
     C     wkprtn        div(h)    wkprtnh       wkprtnth
     C                   endif
     C                   endif
     C                   eval      wkstagph = *zeros
     C                   eval      wkstagth = *zeros
     C                   if        wkstagh > 0
     C     wkstagp       div(h)    wkstagh       wkstagph
     C                   if        wkstag > 0
     C     wkstag        div(h)    wkstagh       wkstagth
     C                   endif
     C                   endif
     C                   eval      wkbulkph = *zeros
     C                   eval      wkbulkth = *zeros
     C                   if        wkbulkh > 0
     C     wkbulkp       div(h)    wkbulkh       wkbulkph
     C                   if        wkbulk > 0
     C     wkbulk        div(h)    wkbulkh       wkbulkth
     C                   endif
     C                   endif
     C                   eval      wktotph = *zeros
     C                   eval      wktotth = *zeros
     C                   if        wktoth > 0
     C     wktotp        div(h)    wktoth        wktotph
     C                   if        wktot > 0
     C     wktot         div(h)    wktoth        wktotth
     C                   endif
     C                   endif
     C                   eval      wkdirph = *zeros
     C                   eval      wkdirth = *zeros
     C                   if        wkdirh > 0
     C     wkdirp        div(h)    wkdirh        wkdirph
     C                   if        wkdir > 0
     C     wkdir         div(h)    wkdirh        wkdirth
     C                   endif
     C                   endif
     C                   eval      wkeqckth = *zeros
     C                   if        wkeqck > 0  and wkeqckh > 0
     C     wkeqck        div(h)    wkeqckh       wkeqckth
     C                   endif
     C                   eval      wkidleth = *zeros
     C                   if        wkidle > 0  and wkidleh > 0
     C     wkidle        div(h)    wkidleh       wkidleth
     C                   endif
     C                   eval      wkindth = *zeros
     C                   if        wkind > 0  and wkindh > 0
     C     wkind         div(h)    wkindh        wkindth
     C                   endif
     *
     C                   z-add     wkfixp        wkpickp
     C                   add       wkpirp        wkpickp
     C                   add       wkbulkp       wkpickp
     C                   z-add     wkfix         wkpick
     C                   add       wkpir         wkpick
     C                   add       wkbulk        wkpick
     C                   z-add     wkfixh        wkpickh
     C                   add       wkpirh        wkpickh
     C                   add       wkbulkh       wkpickh
     C                   eval      wkpickph = *zeros
     C                   eval      wkpickth = *zeros
     C                   if        wkpickh > 0
     C     wkpickp       div(h)    wkpickh       wkpickph
     C                   if        wkpick > 0
     C     wkpick        div(h)    wkpickh       wkpickth
     C                   endif
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrsumt        begsr
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrsumr        begsr
     *
     *  future enhancments
     C*                  z-add     wkrecv        wktot
     C*                  add       wkrtn         wktot
     *
     C                   z-add     wkput         wktot
     C                   add       wkrepl        wktot
     C                   add       wktfr         wktot
     C                   add       wkvrfy        wktot
640aAC                   add       wkload        wktot
     C                   add       wkfix         wktot
     C                   add       wkpir         wktot
     C                   add       wkprtn        wktot
     C                   add       wkstag        wktot
     C                   add       wkeqck        wktot
     C                   add       wkbulk        wktot
     C                   add       wkidle        wktot
     C                   add       wkind         wktot
     *
     *  future enhancments
     C*                  z-add     wkrecvp       wktotp
     C*                  add       wkrtnp        wktotp
     *
     C                   z-add     wkputp        wktotp
     C                   add       wkreplp       wktotp
     C                   add       wktfrp        wktotp
     C                   add       wkvrfyp       wktotp
640aAC                   add       wkloadp       wktotp
     C                   add       wkfixp        wktotp
     C                   add       wkpirp        wktotp
     C                   add       wkprtnp       wktotp
     C                   add       wkstagp       wktotp
     C                   add       wkbulkp       wktotp
     *
     *  future enhancments
     C*                  z-add     wkrecvh       wktoth
     C*                  add       wkrtnh        wktoth
     *
     C                   z-add     wkputh        wktoth
     C                   add       wkreplh       wktoth
     C                   add       wktfrh        wktoth
     C                   add       wkvrfyh       wktoth
640aAC                   add       wkloadh       wktoth
     C                   add       wkfixh        wktoth
     C                   add       wkpirh        wktoth
     C                   add       wkprtnh       wktoth
     C                   add       wkstagh       wktoth
     C                   add       wkbulkh       wktoth
     C                   add       wkidleh       wktoth
     C                   add       wkindh        wktoth
     *
     *
     *  future enhancments
     C*                  z-add     wkrecv        wkdir
     C*                  add       wkrtn         wkdir
     *
     C                   z-add     wkput         wkdir
     C                   add       wkrepl        wkdir
     C                   add       wktfr         wkdir
     C                   add       wkvrfy        wkdir
640aAC                   add       wkload        wkdir
     C                   add       wkfix         wkdir
     C                   add       wkpir         wkdir
     C                   add       wkprtn        wkdir
     C                   add       wkstag        wkdir
     C                   add       wkeqck        wkdir
     C                   add       wkbulk        wkdir
     *
     *  future enhancments
     C*                  z-add     wkrecvp       wkdirp
     C*                  add       wkrtnp        wkdirp
     *
     C                   z-add     wkputp        wkdirp
     C                   add       wkreplp       wkdirp
     C                   add       wktfrp        wkdirp
     C                   add       wkvrfyp       wkdirp
640aAC                   add       wkloadp       wkdirp
     C                   add       wkfixp        wkdirp
     C                   add       wkpirp        wkdirp
     C                   add       wkprtnp       wkdirp
     C                   add       wkstagp       wkdirp
     C                   add       wkbulkp       wkdirp
     *
     *  future enhancments
     C*                  z-add     wkrecvh       wkdirh
     C*                  add       wkrtnh        wkdirh
     *
     C                   z-add     wkputh        wkdirh
     C                   add       wkreplh       wkdirh
     C                   add       wktfrh        wkdirh
     C                   add       wkvrfyh       wkdirh
640aAC                   add       wkloadh       wkdirh
     C                   add       wkfixh        wkdirh
     C                   add       wkpirh        wkdirh
     C                   add       wkprtnh       wkdirh
     C                   add       wkstagh       wkdirh
     C                   add       wkbulkh       wkdirh
     *
     C                   add       wkrecv        trecv
     C                   add       wkrtn         trtn
     *  future enhancments
     C*                  add       wkrecvh       trecvh
     C                   add       wkrtnp        trtnp
     C                   add       wkrtnh        trtnh
     *
     C                   add       wkrecvp       trecvp
     C                   add       wkrun         trun
     C                   add       wkrunp        trunp
     C                   add       wkput         tput
     C                   add       wkputp        tputp
     C                   add       wkputh        tputh
     C                   add       wkrepl        trepl
     C                   add       wkreplp       treplp
     C                   add       wkreplh       treplh
     C                   add       wktfr         ttfr
     C                   add       wktfrp        ttfrp
     C                   add       wktfrh        ttfrh
     C                   add       wkvrfy        tvrfy
     C                   add       wkvrfyp       tvrfyp
     C                   add       wkvrfyh       tvrfyh
640aAC                   add       wkload        tload
640aAC                   add       wkloadp       tloadp
640aAC                   add       wkloadh       tloadh
     C                   add       wkfix         tfix
     C                   add       wkfixp        tfixp
     C                   add       wkfixh        tfixh
     C                   add       wkpir         tpir
     C                   add       wkpirp        tpirp
     C                   add       wkpirh        tpirh
     C                   add       wkprtn        tprtn
     C                   add       wkprtnp       tprtnp
     C                   add       wkprtnh       tprtnh
     C                   add       wkstag        tstag
     C                   add       wkstagp       tstagp
     C                   add       wkstagh       tstagh
     C                   add       wkeqck        teqck
     C                   add       wkeqckh       teqckh
     C                   add       wkbulk        tbulk
     C                   add       wkbulkp       tbulkp
     C                   add       wkbulkh       tbulkh
     C                   add       wkidle        tidle
     C                   add       wkidleh       tidleh
     C                   add       wkind         tind
     C                   add       wkindh        tindh
     C                   add       wktoth        ttoth
     C                   add       wktot         ttot
     C                   add       wktotp        ttotp
     C                   add       wkdirh        tdirh
     C                   add       wkdir         tdir
     C                   add       wkdirp        tdirp
     C                   add       wkpick        tpick
     C                   add       wkpickp       tpickp
     C                   add       wkpickh       tpickh
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrtotl        begsr
     *
     *  future enhancments
     C*                  if        trecvh > 0
     C*    trecvp        div(h)    trecvh        trecvph
     C*                  if        trecv > 0
     C*    trecv         div(h)    trecvh        trecvth
     C*                  endif
     C*                  endif
     *
     *
     C                   if        tputh > 0
     C     tputp         div(h)    tputh         tputph
     C                   if        tput > 0
     C     tput          div(h)    tputh         tputth
     C                   endif
     C                   endif
     C                   if        treplh > 0
     C     treplp        div(h)    treplh        treplph
     C                   if        trepl > 0
     C     trepl         div(h)    treplh        treplth
     C                   endif
     C                   endif
     C                   if        ttfrh > 0
     C     ttfrp         div(h)    ttfrh         ttfrph
     C                   if        ttfr > 0
     C     ttfr          div(h)    ttfrh         ttfrth
     C                   endif
     C                   endif
     C                   if        tvrfyh > 0
     C     tvrfyp        div(h)    tvrfyh        tvrfyph
     C                   if        tvrfy > 0
     C     tvrfy         div(h)    tvrfyh        tvrfyth
     C                   endif
     C                   endif
640aAC                   if        tloadh > 0
640aAC     tloadp        div(h)    tloadh        tloadph
640aAC                   if        tload > 0
640aAC     tload         div(h)    tloadh        tloadth
640aAC                   endif
640aAC                   endif
     C                   if        tfixh > 0
     C     tfixp         div(h)    tfixh         tfixph
     C                   if        tfix > 0
     C     tfix          div(h)    tfixh         tfixth
     C                   endif
     C                   endif
     C                   if        tpirh > 0
     C     tpirp         div(h)    tpirh         tpirph
     C                   if        tpir > 0
     C     tpir          div(h)    tpirh         tpirth
     C                   endif
     C                   endif
     *
     *  future enhancments
     C*                  if        trtnh > 0
     C*    trtnp         div(h)    trtnh         trtnph
     C*                  if        trtn > 0
     C*    trtn          div(h)    trtnh         trtnth
     C*                  endif
     C*                  endif
     C                   if        tprtnh > 0
     C     tprtnp        div(h)    tprtnh        tprtnph
     C                   if        tprtn > 0
     C     tprtn         div(h)    tprtnh        tprtnth
     C                   endif
     C                   endif
     C                   if        tstagh > 0
     C     tstagp        div(h)    tstagh        tstagph
     C                   if        tstag > 0
     C     tstag         div(h)    tstagh        tstagth
     C                   endif
     C                   endif
     C                   if        tbulkh > 0
     C     tbulkp        div(h)    tbulkh        tbulkph
     C                   if        tbulk > 0
     C     tbulk         div(h)    tbulkh        tbulkth
     C                   endif
     C                   endif
     C                   if        tdirh > 0
     C     tdirp         div(h)    tdirh         tdirph
     C                   if        tdir > 0
     C     tdir          div(h)    tdirh         tdirth
     C                   endif
     C                   endif
     C                   if        teqck > 0  and teqckh > 0
     C     teqck         div(h)    teqckh        teqckth
     C                   endif
     C                   if        tidle > 0  and tidleh > 0
     C     tidle         div(h)    tidleh        tidleth
     C                   endif
     C                   if        tind > 0  and tindh > 0
     C     tind          div(h)    tindh         tindth
     C                   endif
     C                   if        ttoth > 0
     C     ttotp         div(h)    ttoth         ttotph
     C                   if        ttot > 0
     C     ttot          div(h)    ttoth         ttotth
     C                   endif
     C                   endif
     C                   if        tpickh > 0
     C     tpickp        div(h)    tpickh        tpickph
     C                   if        tpick > 0
     C     tpick         div(h)    tpickh        tpickth
     C                   endif
     C                   endif
     C                   write     total1
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrzero        begsr
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
**      RPD   Report level descriptions
 * Total:
 ** Date totals **
 *** Totals
**      DTE   Date headings
99/99/99 thru 99/99/99
     From 99/99/99
     Thru 99/99/99

**      TME   TIME headings
99:99:99 thru 99:99:99
**      MRG   Merge records info
**Pieces Do Not Include Merge Pickup Pieces**
