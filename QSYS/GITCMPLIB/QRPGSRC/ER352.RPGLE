      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ER352     Transaction analysis by task for an employee
     *  28 July, 1999
     *  Hemant Kapadia
     *
     *
     *  Note: Report direct minutes includes IDLE time as follows.
     *                Task      Minutes    Calculate
     *        Start   IDLE         5
     *                PUTAWY       2       5+2+3=10
     *                IDLE         3
     *                PUTAWY       4       4+1=5
     *                IDLE         1
     *                PUTAWY       2       2+4=6
     *                IDLE         4
     *        End     ENDDAY       0
     *----------------------------------------------------------------
     *  Revisions:
     *
     *  07/28/99  HNK  4.12
     *  - Created
     *
530a *  11/17/09  GJA  5.30a
     *  - Converted to RPGLE, cleaned up and revamped for suspended
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
     Fer350     ip   e           k disk
     F                                     rename(errec:record)
     Ftranph    if   e           k disk
     Ftaskdet   if   e           k disk
     Fpiruser1  if   e           k disk
     Fshift     if   e           k disk
     Fcrew      if   e           k disk
     Ftask      if   e           k disk
     Freporte   if   e           k disk
     Fer352pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *                   RPD     1   3 25
     D rpd             s             12    dim(3) ctdata perrcd(1)
     D reck            s              7  0 dim(3)
     D lvlk            s              7  0 dim(3)
     *
     D tds             s             12    dim(99)
     D tsk             s              6    dim(99)
     D whd             s              5    dim(99)
     D sec             s              1    dim(99)
     D dmn             s              5  0 dim(99)
     D imn             s              5  0 dim(99)
     D trn             s              5  0 dim(99)
     D pcs             s              5  0 dim(99)
     D tph             s              5  0 dim(99)
     D pph             s              5  0 dim(99)
     *
     D dtot            s              7  3 dim(3)
     D itot            s              7  3 dim(3)
     D ttot            s              7  0 dim(3)
     D ptot            s              7  0 dim(3)
     *
     D dte             s             22    dim(4) ctdata perrcd(1)
     D tme             s             22    dim(1) ctdata perrcd(1)
530aAD mrg             s             45    dim(1) ctdata perrcd(1)
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
     D $pfmtm          ds
     D  $pbhrs                 1      2
     D  $pbmin                 3      4
     D  $pbsec                 5      6
     D $ptotm          ds
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
     D first           s              1
     D l               s              1  0
     D m               s                   like(l)
     D n               s              3  0
     D p#pcn           s              7  2
     D s#dmn           s              5  0
     D s#imn           s              5  0
     D svtrn#          s                   like(ertrn#)
     D t#dhrs          s              5  3
     D t#dthr          s              7  3
     D t#dir           s              5  0
     D t#dtot          s              7  3
     D t#ihrs          s              5  3
     D t#ithr          s              7  3
     D t#itot          s              7  3
     D t#pcn           s              7  2
     D t#pph           s              7  3
     D t#tph           s              7  3
     D w#pcn           s              7  5
     D wkprtf          s             10
     D w1tds           s             12
     *
     *----------------------------------------------------------------
     Irecord
     I                                          ersdte        l1
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
     C                   parm                    $pfmtm
     C                   parm                    $ptotm
530aAC                   parm                    $pmrg             1
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
     *  Level 1 break - Date change
     *
     C                   if        *inl1
     C                   eval      l = 1
     C                   exsr      zrzero
     C                   endif
     *
     *  Print headings.
     *
     *
     C                   if        *in91  or
     C                             *inl1
     * Transaction date
     C                   if        ersdte <> 0
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ersdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      gtdate = $cvd6o
     C                   else
     C                   eval      gtdate = 0
     C                   endif
     C                   write     dthead
     C                   endif
     *
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *
     C                   select
     C                   when      ertask <> 'IDLE  '
     *
     C                   exsr      zrfill
     *
     *  Accumulate totals
     *
     *  Note: There could be more than one record for a transaction.
     *        Number of pieces (Qty) comes from label record and hence
     *        it must be added to total for every record.
     *
     C                   if        ertrn# <> svtrn#
     C*                  add       erdmin        dtot(1)
     C*                  add       erimin        itot(1)
     C                   add       1             ttot(1)
     C                   endif
     C                   add       erpcs         ptot(1)
     C                   eval      svtrn# = ertrn#
     *
     *  Increment record counters
     *
     C                   add       1             reck(1)
     C                   add       1             lvlk(1)
     *
     C                   endsl
     *
     *  Set off top-of-page indicators
     *
     C                   eval      *in92 = *off
     C                   eval      *in91 = *off
     C                   eval      first = *off
     *----------------------------------------------------------------
     *
     * Transaction date break
     *
     CL1                 if        first=*on and *inlr=*on
     CL1                 else
     CL1                 eval      l = 1
     CL1                 exsr      zrsumr
     CL1                 write     skip1
     CL1                 write     draw1
     CL1                 exsr      zrtotl
     CL1                 exsr      zrroll
     *
     CL1                 if        reck(l) > 0
     CL1NLR              write     skip1
     CL1                 endif
     CL1                 endif
     *----------------------------------------------------------------
     *
     * Batch totals
     *
     CLr                 eval      l = 2
     *
     CLr                 if        reck(l) = 0
     CLR                 move      $pemp#        emp#              5 0
     CLR   emp#          chain     piruser1                           79
     CLR                 if        not *in79
     CLR                 eval      $cmd = '*LFM    '
     CLR                 eval      $name = *blanks
     CLR                 call      'FRMTNM'
     CLR                 parm                    $cmd
     CLR                 parm                    usfnam
     CLR                 parm                    usinit
     CLR                 parm                    uslnam
     CLR                 parm                    $name
     CLR                 eval      wkname = $name
     CLR                 else
     CLR                 eval      wkname = *blanks
     CLR                 endif
     CLR                 exsr      zrfrmt
     CLR                 write     head1
     CLR                 write     head2
     CLR                 write     ephead
     CLR                 write     columns
     CLr                 write     foot2
     CLr                 else
     CLR                 write     skip1
     CLR                 write     draw1
     CLR                 exsr      zrtotl
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
     *     TASK
     *
     C     tkkey         klist
     C                   kfld                    ertask
     *
     *     TRANPH
     *
     C     tpkeys        klist
     C                   kfld                    ertask
     C                   kfld                    erwhse
     C                   kfld                    erwhdp
     C                   kfld                    erstyp
     *
     *     TRANPH
     *
     C     tpkeyd        klist
     C                   kfld                    ertask
     C                   kfld                    erwhse
     C                   kfld                    erwhdp
     *
     *     TRANPH
     *
     C     tpkeyw        klist
     C                   kfld                    ertask
     C                   kfld                    erwhse
     *
     *  Define full key for TASKDET file.
     *
     C     tdkeys        klist
     C                   kfld                    ertask
     C                   kfld                    erwhse
     C                   kfld                    erwhdp
     C                   kfld                    erstyp
     *
     *     TASKDET
     *
     C     tdkeyd        klist
     C                   kfld                    ertask
     C                   kfld                    erwhse
     C                   kfld                    erwhdp
     *
     *     TASKDET
     *
     C     tdkeyw        klist
     C                   kfld                    ertask
     C                   kfld                    erwhse
     *
     *  Define key for PIRUSEER1 file.
     *
     C     uskey         klist
     C                   kfld                    eremp#
     *
     *  Define key for SHIFT file.
     *
     C     shkey         klist
     C                   kfld                    erwhse
     C                   kfld                    erwhdp
     C                   kfld                    ershft
     *
     *  Define key for CREW file.
     *
     C     crkey         klist
     C                   kfld                    erwhse
     C                   kfld                    ercrew
     *
     C                   time                    time
     C                   eval      first = *on
     C                   eval      l = 1
     C                   eval      n = 0
     C                   exsr      zrzero
530aAC                   if        $pmrg = 'N'
530aAC                   eval      mrgtxt = mrg(1)
530aAC                   else
530aAC                   eval      mrgtxt = *blanks
530aAC                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrfill        begsr
     *
     C     tkkey         chain     task                               79
     C                   if        not *in79
     *
     C                   select
     C                   when      tktlvl = 'S'
     *   Transaction per Hr.
     C     tpkeys        chain     tranph                             79
     C                   if        *in79
     C                   eval      tpstph = 0
     C                   endif
     *  Get standards PCS/HR
     C     tdkeys        chain     taskdet                            79
     C                   if        *in79
     C                   eval      tdstdp = 0
     C                   endif
     *
     C                   when      tktlvl = 'D'
     *   Transaction per Hr.
     C     tpkeyd        setll     tranph
     C     tpkeyd        reade     tranph                                 79
     C                   if        *in79
     C                   eval      tpstph = 0
     C                   endif
     *  Get standards PCS/HR
     C     tdkeyd        setll     taskdet
     C     tdkeyd        reade     taskdet                                79
     C                   if        *in79
     C                   eval      tdstdp = 0
     C                   endif
     *
     C                   when      tktlvl = 'W'
     *   Transaction per Hr.
     C     tpkeyw        setll     tranph
     C     tpkeyw        reade     tranph                                 79
     C                   if        *in79
     C                   eval      tpstph = 0
     C                   endif
     *  Get standards PCS/HR
     C     tdkeyw        setll     taskdet
     C     tdkeyw        reade     taskdet                                79
     C                   if        *in79
     C                   eval      tdstdp = 0
     C                   endif
     *
     C                   endsl
     *
     C                   else
     *
     C                   eval      tpstph = 0
     C                   eval      tdstdp = 0
     C                   endif
     *
     *   Fill arrays for summary report.
     *
     C                   eval      w1tds = *zeros
     C     ertask        cat       erwhdp:0      w1tds
     C     w1tds         cat       erstyp:0      w1tds
     C                   eval      n = 1
     C     w1tds         lookup    tds(n)                                 81
     *  Found
     C                   if        *in81
     C                   if        ertrn# <> svtrn#
     C                   add       erdmin        dmn(n)
     C                   add       erimin        imn(n)
     C                   add       1             trn(n)
     C                   endif
     C                   add       erpcs         pcs(n)
     *
     C                   else
     *  Not found
     C     *blanks       lookup    tsk(n)                                 82
     C                   if        *in82
     C                   eval      tds(n) = w1tds
     C                   eval      tsk(n) = ertask
     C                   eval      whd(n) = erwhdp
     C                   eval      sec(n) = erstyp
     C                   eval      dmn(n) = erdmin
     C                   eval      imn(n) = erimin
     C                   eval      trn(n) = 1
     C                   eval      pcs(n) = erpcs
     C                   eval      tph(n) = tpstph
     C                   eval      pph(n) = tdstdp
     C                   endif
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
     C                   movel     'ER352PR '    wkprtf
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
     C                   move      $pfmtm        fmtm              6 0
     C                   move      $ptotm        totm              6 0
     *
     C                   time                    time
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
     C     uskey         chain     piruser1                           79
     C                   if        not *in79
     C                   eval      $cmd = '*LFM    '
     C                   eval      $name = *blanks
     C                   call      'FRMTNM'
     C                   parm                    $cmd
     C                   parm                    usfnam
     C                   parm                    usinit
     C                   parm                    uslnam
     C                   parm                    $name
     C                   eval      wkname = $name
     C                   else
     C                   eval      wkname = *blanks
     C                   endif
     *
     C     shkey         chain     shift                              79
     C                   if        not *in79
     C                   movel     shdesc        wkshft
     C                   else
     C                   eval      wkshft = *blanks
     C                   endif
     *
     C     crkey         chain     crew                               79
     C                   if        not *in79
     C                   movel     crdesc        wkcrew
     C                   else
     C                   eval      wkcrew = *blanks
     C                   endif
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
     C                   eval      m = l + 1
     *
     C                   add       1             lvlk(m)
     C                   add       reck(l)       reck(m)
     *
     C                   add       dtot(l)       dtot(m)
     C                   add       itot(l)       itot(m)
     C                   add       ttot(l)       ttot(m)
     C                   add       ptot(l)       ptot(m)
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrsumr        begsr
     *
     C                   do        99            n
     C                   if        tsk(n) <> *blanks
     C                   eval      s#whd = whd(n)
     C                   eval      s#tsk = tsk(n)
     C                   eval      s#dmn = dmn(n)
     C                   eval      s#imn = imn(n)
     C                   eval      s#trn = trn(n)
     C                   eval      s#pcs = pcs(n)
     C                   eval      s#tph = tph(n)
     C                   eval      s#pph = pph(n)
     C                   if        s#imn > 0
     C     s#imn         div(h)    60            t#ihrs
     C                   else
     C                   eval      t#ihrs = 0
     C                   endif
     C                   if        s#dmn > 0
     C     s#dmn         div(h)    60            t#dhrs
     C                   else
     C                   eval      t#dhrs = 0
     C                   endif
     * Calculate Tran/Hr and Pcs/Hr (Total Thru-put)
     C                   if        t#dhrs > 0
     C     s#trn         div(h)    t#dhrs        t#tph
     C     s#pcs         div(h)    t#dhrs        t#pph
     C                   else
     C                   eval      t#tph = 0
     C                   eval      t#pph = 0
     C                   endif
     *
     C                   if        s#tph > 0
     C     t#tph         div(h)    s#tph         w#pcn
     C                   else
     C                   eval      w#pcn = 0
     C                   endif
     *
     C                   eval      tphpcn = w#pcn * 100
     *
     * If a task is not tracked by TPH, then S#PCN will be 0
     *          S#PCN     IFEQ 0
     *
     * If a task is tracked by PPH .....
     *
     *
     C                   if        s#pph > 0
     C     t#pph         div(h)    s#pph         w#pcn
     C                   else
     C                   eval      w#pcn = 0
     C                   endif
     *
     C                   eval      pphpcn = w#pcn * 100
     *
     *
     C                   write     sumar1
     * Accumulate % for all direct task to find average at total time
     C                   if        s#dmn > 0
     C                   add       tphpcn        t#pcn
     C                   add       pphpcn        p#pcn
     C                   add       1             t#dir
     C                   endif
     *
     C*                  add       t#dhrs        t#dthr
     C*                  add       t#ihrs        t#ithr
     C                   add       t#dhrs        dtot(1)
     C                   add       t#ihrs        itot(1)
     *
     C                   endif
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrtotl        begsr
     *
     C                   eval      t#dtot = dtot(l)
     C                   eval      t#itot = itot(l)
     C                   eval      t#ttot = ttot(l)
     C                   eval      t#ptot = ptot(l)
     *
     *                    Z-ADDRECK,L    T#RECK
     *
     C                   move      rpd(l)        $rpd
     *
     C                   if        t#dir > 0
     C     t#pcn         div       t#dir         a#tcnt
     C     p#pcn         div       t#dir         a#pcnt
     C                   endif
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
     C                   eval      dtot(l) = 0
     C                   eval      itot(l) = 0
     C                   eval      ttot(l) = 0
     C                   eval      ptot(l) = 0
     *
     C                   eval      t#pcn = 0
     C                   eval      p#pcn = 0
     C                   eval      t#dir = 0
     C                   eval      a#tcnt = 0
     C                   eval      a#pcnt = 0
     C                   eval      t#dthr = 0
     C                   eval      t#ithr = 0
     *
     C                   clear                   tds
     C                   clear                   tsk
     C                   clear                   whd
     C                   clear                   sec
     C                   clear                   dmn
     C                   clear                   imn
     C                   clear                   trn
     C                   clear                   pcs
     C                   clear                   tph
     C                   clear                   pph
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
**      RPD   Report level descriptions
 * Date:
 ** Total:
 *** Totals:
**      DTE   Date headings
99/99/99 thru 99/99/99
     From 99/99/99
     Thru 99/99/99

**      TME   TIME headings
99:99:99 thru 99:99:99
**      MRG   Merge records info
**Pieces Do Not Include Merge Pickup Pieces**
