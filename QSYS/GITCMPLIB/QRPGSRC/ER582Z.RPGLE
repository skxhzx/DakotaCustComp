      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ER582Z    Crew Activity Report (Zone Detail)
     *  23 May, 2011
     *  Ginger Andrews
     *
     *
     *  Revisions:
     *
     *  05/23/11  GJA  6.40
     *    - Created.
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
     Fer581a1   ip   e           k disk
     Fcrew      if   e           k disk
     Fshift     if   e           k disk
     Fpiruser1  if   e           k disk
     Ftask      if   e           k disk
     Freporte   if   e           k disk
     Fpasstran  if   e           k disk
     Fer582zpr  o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     D rpd             s             25    dim(4) ctdata perrcd(1)
     D reck            s              7  0 dim(4)
     D lvlk            s              7  0 dim(4)
     *
     D dtot            s              7  2 dim(4)
     D sctot           s              7  2 dim(4)
     D ptot            s              7  0 dim(4)
     D stot            s              7  0 dim(4)
     D trtot           s              7  0 dim(4)
     *
     D dte             s             22    dim(4) ctdata perrcd(1)
     D tme             s             22    dim(1) ctdata perrcd(1)
     D a22             s              1    dim(22)
     *----------------------------------------------------------------
     *  Called programs
     *
     D @multi          c                   const('CHKMULTI')
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
     D $rpd            s             20
     D begin           s              1
     D emp#            s              5  0
     D first           s              1
     D l               s              1  0
     D m               s                   like(l)
     D n               s              3  0
     D svtrn#          s                   like(wktrn#)
     D wkprtf          s             10
     D w1dmin          s              4  0
     D w1dsec          s              4  0
     D w1dhrs          s              5  2
     D w1ihrs          s              5  2
     D w1task          s              6
     D w1whdp          s              5
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
     D forever         s              1
     *
     *----------------------------------------------------------------
     Iwkrec
     I*                                         wkemp#        l3
     I*                                         wktask        l2
     I*                                         wkzone        l1
     I                                          wkzone        l3
     I                                          wktask        l2
     I                                          wkemp#        l1
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
     C                   parm                    $pcrew            6
     C                   parm                    $pzndp            1
     C                   parm                    $pbtim            6
     C                   parm                    $petim            6
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
     *  Init total levels
     *
     *  Level 3 break - Zone
     *
     C                   if        *inl3
     C                   eval      l = 3
     C                   exsr      zrzero
     C                   eval      w1whdp = wkwhdp
     C                   eval      w1zone = wkzone
     *
     C                   endif
     *
     *  Level 2 break - TASK
     *
     C                   if        *inl2
     C                   eval      l = 2
     C                   exsr      zrzero
     C                   eval      w1task = wktask
     C                   endif
     *
     *  Level 1 break - Employee
     *
     C                   if        *inl1
     C                   eval      l = 1
     C                   exsr      zrzero
     C                   eval      emp# = wkemp#
     C                   eval      w1emp# = wkemp#
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
     C                   movel     $name         w1name
     C                   endif
     *
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
     C     wkdmin        div(h)    60            w1dhrs
     C     wkimin        div(h)    60            w1ihrs
     *
     *  Accumulate totals
     *
     C                   add       wkpcs         ptot(1)
     C                   add       wkshrt        stot(1)
     C                   if        wktrn# <> svtrn#
     C                   add       1             trtot(1)
     C                   exsr      zzstamp
     C                   add       w1dmin        dtot(1)
     C                   add       w1dsec        sctot(1)
     C                   exsr      zzdrop
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
     * DEPT code break
     *
     CL1                 eval      l = 1
     CL1                 exsr      zrroll
     *
     CL1                 if        reck(l) > 0
     CL1                 add       1             detail            1 0
     CL1                 exsr      zrtotd
     CL1                 write     detail1
     CL1                 endif
     *----------------------------------------------------------------
     *
     * TASK break
     *
     CL2                 eval      l = 2
     CL2                 exsr      zrroll
     *
     CL2                 if        reck(l) > 0
     CL2                 endif
     *----------------------------------------------------------------
     *
     * EMPL break
     *
     CL3                 eval      l = 3
     CL3                 exsr      zrroll
     *
     CL3                 if        reck(l) > 0
     CL3                 exsr      zrtotl
     CL3                 if        detail > 1
     C*3                 write     skip1
     CL3                 write     total1
     C*3                 write     skip1
     CL3                 endif
     CL3                 z-add     0             detail
     CL3                 endif
     *----------------------------------------------------------------
     *
     * Batch totals
     *
     CLR                 if        first=*off
     CLR                 eval      l = 4
     *
     CLR                 if        reck(l) > 0
     C*R                 exsr      zrtotl
     CLR                 write     skip1
     CLR                 if        g#dtot > 0
     CLR   g#ntot        div(h)    g#dtot        g#csph
     CLR                 else
     CLR                 eval      g#csph = 0
     CLR                 endif
     *
     CLR                 if        g#dtot > 0
     CLR   g#trtot       div(h)    g#dtot        g#trph
     CLR                 else
     CLR                 eval      g#trph = 0
     CLR                 endif
     *
     CLR                 if        g#dtot > 0
     CLR   g#reck        div(h)    g#dtot        g#reph
     CLR                 else
     CLR                 eval      g#reph = 0
     CLR                 endif
     CLr                 write     gtotal
     CLr                 write     foot1
     CLr                 endif
     CLr                 else
     CLR                 move      $pcrew        wkcrew
     CLR                 exsr      zrfrmt
     CLR                 exsr      zrhead
     CLr                 write     skip1
     CLr                 write     foot2
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
     C     shkey         klist
     C                   kfld                    uswhse
     C                   kfld                    w1whdp
     C                   kfld                    usshft
     *
     C     passkey       klist
     C                   kfld                    wkemp#
     C                   kfld                    wktrn#
     *
     C     crkey         klist
     C                   kfld                    wkwhse
     C                   kfld                    wkcrew
     *
     C                   eval      w1whdp = *blanks
     C     shkey         chain     shift                              79
     C                   if        *in79
     C                   eval      shstim = 0
     C                   eval      shetim = 0
     C                   endif
     *
     C                   time                    time
     C                   eval      first = *on
     C                   eval      l = 1
     C                   eval      n = 0
     C                   eval      begin = *off
     C                   exsr      zrzero
     C                   if        $pmrg = 'N'
     C                   eval      *in50 = *on
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrfrmt        begsr
     *
     *   Format report title.
     *
     *  Get report title.
     *
     C                   movel     'ER582PR '    wkprtf
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
     C                   write     head2
     *
     *  Get crew code description
     *
     C     crkey         chain     crew                               79
     C                   if        not *in79
     C                   movel     crdesc        wkdesc
     C                   else
     C                   eval      wkdesc = *blanks
     C                   endif
     *
     C                   write     crhead
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
     C                   add       sctot(l)      sctot(m)
     C                   add       ptot(l)       ptot(m)
     C                   add       stot(l)       stot(m)
     C                   add       trtot(l)      trtot(m)
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrtotd        begsr
     *
     C     sctot(l)      div(h)    60            dsecs
     C                   add       dsecs         dtot(l)
     C     dtot(l)       div(h)    60            dhrs
     C                   eval      d#dtot = dhrs
     C                   eval      d#ptot = ptot(l)
     C                   eval      d#trtot = trtot(l)
     C                   eval      d#reck = reck(l)
     C                   eval      d#stot = stot(l)
     C                   eval      d#ntot = ptot(l) - stot(l)
     *
     C                   if        d#dtot > 0
     C     d#ntot        div(h)    d#dtot        d#csph
     C                   else
     C                   eval      d#csph = 0
     C                   endif
     *
     C                   if        d#dtot > 0
     C     d#trtot       div(h)    d#dtot        d#trph
     C                   else
     C                   eval      d#trph = 0
     C                   endif
     *
     C                   if        d#dtot > 0
     C     d#reck        div(h)    d#dtot        d#reph
     C                   else
     C                   eval      d#reph = 0
     C                   endif
     *
     C                   eval      $rpd = *blanks
     C                   movel     rpd(l)        $rpd
     *
     C                   add       d#ptot        t#ptot
     C                   add       d#stot        t#stot
     C                   add       d#ntot        t#ntot
     C                   add       d#dtot        t#dtot
     C                   add       d#trtot       t#trtot
     C                   add       d#reck        t#reck
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrtotl        begsr
     *
     C     sctot(l)      div(h)    60            dsecs
     C                   add       dsecs         dtot(l)
     C     dtot(l)       div(h)    60            dhrs
     C                   eval      t#dtot = dhrs
     C                   eval      t#ptot = ptot(l)
     C                   eval      t#trtot = trtot(l)
     C                   eval      t#reck = reck(l)
     C                   eval      t#stot = stot(l)
     C                   eval      t#ntot = ptot(l) - stot(l)
     *
     C                   if        t#dtot > 0
     C     t#ntot        div(h)    t#dtot        t#csph
     C                   else
     C                   eval      t#csph = 0
     C                   endif
     *
     C                   if        t#dtot > 0
     C     t#trtot       div(h)    t#dtot        t#trph
     C                   else
     C                   eval      t#trph = 0
     C                   endif
     *
     C                   if        t#dtot > 0
     C     t#reck        div(h)    t#dtot        t#reph
     C                   else
     C                   eval      t#reph = 0
     C                   endif
     *
     C                   eval      $rpd = *blanks
     C                   movel     rpd(l)        $rpd
     *
     C                   add       t#ptot        g#ptot
     C                   add       t#stot        g#stot
     C                   add       t#ntot        g#ntot
     C                   add       t#dtot        g#dtot
     C                   add       t#trtot       g#trtot
     C                   add       t#reck        g#reck
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
     C                   eval      stot(l) = 0
     C                   eval      sctot(l) = 0
     C                   eval      trtot(l) = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     * zzdrop:  setup date stamp for drop transaction
     *----------------------------------------------------------------
     *
     C     zzdrop        begsr
     C     passkey       setll     passtran
     C                   dow       forever = forever
     C     passkey       reade     passtran
     C                   if        pastrn#=wktrn# and pasemp#=wkemp#
     C                             and not %EOF(PASSTRAN)
     C                   if        wksdte = passdte and
     C                             wkstim = passtim and
     C                             wkedte = pasedte and
     C                             wketim = pasetim
     C                   else
     *
     C                   select
     C                   when      wksdte = passdte and
     C                             wkstim = passtim
     C                   when      wksdte = passdte and
     C                             wkstim > passtim
     C                   eval      wkstim = passtim
     C                   when      wksdte > passdte
     C                   eval      wksdte = passdte
     C                   eval      wkstim = passtim
     C                   endsl
     *  End date or time is greater
     C                   select
     C                   when      wkedte = pasedte and
     C                             wketim = pasetim
     C                   when      wkedte = pasedte and
     C                             wketim > pasetim
     C                   eval      wketim = pasetim
     C                   when      wkedte < pasedte
     C                   eval      wkedte = pasedte
     C                   eval      wketim = pasetim
     C                   endsl
     *
     C                   if        wksdte <> 0
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      wksdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C*                  eval      w1sdte = $cvd6o
     C                   else
     C*                  eval      w1sdte = 0
     C                   endif
     *
     C                   if        wkedte <> 0
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      wkedte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C*                  eval      w1edte = $cvd6o
     C                   else
     C*                  eval      w1edte = 0
     C                   endif
     *
     C*                  eval      w1etim = pasetim
     C*                  eval      w1stim = passtim
     *
     *
     C                   move      passdte       wksdte
     C                   move      pasedte       wkedte
     C                   move      passtim       wkstim
     C                   move      pasetim       wketim
     C                   exsr      zzstamp
     C                   add       w1dmin        dtot(1)
     C                   add       w1dsec        sctot(1)
     C                   endif
     C                   else
     C                   leave
     C                   endif
     C                   enddo
     *
     C     enddrop       endsr
     *----------------------------------------------------------------
     * zzstamp:  setup date stamp for chain
     *----------------------------------------------------------------
     *
     C     zzstamp       begsr
     *
     *     Get task description.
     *
     C     wktask        chain     task                               79
     C                   if        *in79
     C                   eval      tktype = *blank
     C                   endif
     C                   if        wkedte<>0
     C                   move      wksdte        wksdtec
     C                   move      wkedte        wkedtec
     C                   move      wkstim        wkstimc
     C                   move      wketim        wketimc
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
     C     dsecs         div       60            w1dmin
     C                   mvr                     w1dsec
     C                   if        tktype <> 'I' and wktask <> 'IDLE  '
     * check if transaction has other transaction during the same time
     C                   eval      $pmin = 0
     C                   eval      $psec = 0
     C                   eval      $pmucnt = 0
     C                   call      @multi
     C                   parm                    wkwhse
     C                   parm                    wkemp#
     C                   parm                    wktrn#
     C                   parm                    wksdte
     C                   parm                    wkstim
     C                   parm                    wkedte
     C                   parm                    wketim
     C                   parm                    $pmsg             4
     C                   parm                    $pmin             5 0
     C                   parm                    $psec             5 0
     C                   parm                    $pmucnt           5 0
     C                   if        $Psec <>0 or $Pmin<>0
     C                   if        w1dmin > $pmin
     C                   sub       $pmin         w1dmin
     C                   if        w1dsec > $psec
     C                   sub       $psec         w1dsec
     C                   else
     C                   sub       1             w1dmin
     C                   add       60            w1dsec
     C                   sub       $psec         w1dsec
     C                   endif
     C                   endif
     C                   endif
     C                   if        w1dmin <> 0
     C     w1dmin        div       $pmucnt       w1dmin
     C                   endif
     C                   if        w1dsec <> 0
     C     w1dsec        div       $pmucnt       w1dsec
     C                   endif
     C                   endif
     C                   else
     C                   eval      w1dmin=0
     C                   eval      w1dsec=0
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
**      RPD   Report level descriptions
 * Task totals *
 ** Department **
 *** Totals
**      DTE   Date headings
99/99/99 thru 99/99/99
     From 99/99/99
     Thru 99/99/99

**      TME   TIME headings
99:99:99 thru 99:99:99
