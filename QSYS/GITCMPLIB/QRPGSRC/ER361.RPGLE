      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ER361     Management report for a selector
     *  16 March, 2000
     *  Hemant Kapadia
     *
     *  03.16.00  HNK  4.13
     *   Created
     *
     *  Revisions:
     *
530  *  09/18/09  GJA  5.30
     *    - Converted to RPGLE, cleaned up and revamped for suspended
     *      transactions.
     *
530a *  03/02/10  GJA  5.30a
     *    - Enh:  capture multiple drops per employee/transaction
     *
530b *  08/12/10  RH   5.30b
     *    - Enh:  Add route and route id to report
     *
530c *  08/24/10  GJA  5.30c
     *    - Enh:  add IDLE time
     *
640a *  05/03/11  GJA  6.40a
     *    - Enh:  add custom client code
     *
640b *  11/21/11  GJA  6.40b
     *    - Enh:  Eastland allows for employee to do one transaction
     *            across multiple days
     *----------------------------------------------------------------
     *  Custom Client Revisions:  Crumbley
     *
CPCa *    05/04/11  GJA  CPCa
     *    - Enh:  add goal time
     *
     *----------------------------------------------------------------
     *  Custom Client Revisions:  Eastland
     *
EFCa *    11/23/11  GJA  EFCa
     *    - Enh:  add order number, total order pieces, customer name
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
     Fer361a    ip   e           k disk
     Ftask      if   e           k disk
     Fpiruser1  if   e           k disk
     Freporte   if   e           k disk
     Fmultran1  if   e           k disk
530aAFpasstran  if   e           k disk
530bAFrtehed    if   e           k disk
EFCaAFordd      if   e           k disk
EFCaAFordh      if   e           k disk
EFCaAFlabel90   if   e           k disk
     Fer361pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     D rpd             s             25    dim(5) ctdata perrcd(1)
     D reck            s              7  0 dim(5)
     D lvlk            s              7  0 dim(5)
     D shrt            s              7  0 dim(5)
     *
     D dtot            s              7  2 dim(5)
     D sctot           s              7  2 dim(5)
530cAD dtoti           s              7  2 dim(5)
530cAD sctoti          s              7  2 dim(5)
     D ptot            s              7  0 dim(5)
     D stot            s              7  0 dim(5)
CPCaAD gltot           s              7  3 dim(5)
     *
     D dte             s             22    dim(4) ctdata perrcd(1)
     D tme             s             22    dim(1) ctdata perrcd(1)
530aAD mrg             s             45    dim(1) ctdata perrcd(1)
     D a22             s              1    dim(22)
     *----------------------------------------------------------------
     *  Called programs
     *
     D @multi          c                   const('CHKMULTI')
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
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
640aA*----------------------------------------------------------------
640aA*  Customer id
640aA*
CPCaA /copy qcopysrc,id#cpc
EFCaA /copy qcopysrc,id#eastlan
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
CPCaAD goaltime        s              7  3
530aAD forever         s              1
     D l               s              1  0
     D m               s                   like(l)
     D n               s              3  0
     D svtrn#          s              7  0
     D wkprtf          s             10
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
530cAD dhrsi           s              7  2
530cAD dsecsi          s              5  0
     D svdmin          s              5  0
     D svdsec          s              5  0
640bAD todt            s              8  0
640bAD fmdt            s              8  0
640baD btim            s              6  0
640baD etim            s              6  0
     *----------------------------------------------------------------
     Iwkrec
     I                                          wkwhdp        l4
     I                                          wkzone        l3
     I                                          wktask        l2
     I                                          wktrn#        l1
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
     C                   parm                    $pzndp            1
     C                   parm                    $pbtim            6
     C                   parm                    $petim            6
530aAC                   parm                    $pmrg             1
     *----------------------------------------------------------------
     *  Let the show begin .....
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
     *
     *
     *  Level 1 break - DEPT
     *
     C                   if        *inl1
     C                   eval      l = 1
     C                   exsr      zrzero
     C                   endif
     *  Level 3 break - TASK
     *
     C                   if        *inl2
     C                   eval      l = 2
     C                   exsr      zrzero
     *
     *     Get task description.
     *
     C     tkkey         chain     task                               79
     C                   if        *in79
     C                   eval      tkdesc = *blanks
     C                   endif
     C                   endif
     *  Level 2 break - TRAN
     *
     C                   if        *inl3
     C                   eval      l = 3
     C                   exsr      zrzero
     C                   endif
     *  Level 4 break - DEPT
     C                   if        *inl4
     C                   eval      l = 4
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
     *  Accumulate totals
     *
     C                   if        wkwhdp=*blanks
     C                   eval      wkwhdp=wkzone
     C                   endif
     C                   add       wkpcs         ptot(1)
     *  Increment record counters
     C                   if        wkpcs=0  and wkcat = 'SELECT'
     C                   add       1             stot(1)
     C                   endif
     C                   add       1             reck(1)
     C                   add       1             lvlk(1)
     *  Set off top-of-page indicators
     C                   eval      *in92 = *off
     C                   eval      *in91 = *off
     C                   eval      first = *off
     *
     *
     C     skip          tag
     *----------------------------------------------------------------
     * TRAN code break
     *
530bA* Get route
530bACL1                 eval      w1rte = *blanks
530bACL1                 eval      kyrtid = *blanks
530bACL1                 eval      w1rtid = *blanks
530bACL1                 if        wkrtpo <> *blanks
530bACL1                 movel     wkrtpo        kyrtid
530bACL1   rtkey         chain     rtehed
530bACL1                 if        not *in79
530bACL1                 eval      w1rte = rhrte
530bACL1                 eval      w1rtid = kyrtid
530bACL1                 endif
530bACL1                 endif
     * Start date
     CL1                 if        wksdte <> 0
     CL1                 eval      $cvcmd = '*CMDMDY '
     CL1                 move      wksdte        $cvd8i
     CL1                 call      @cvtdt
     CL1                 parm                    $cvtdt
     CL1                 eval      w1sdte = $cvd6o
     CL1                 else
     CL1                 eval      w1sdte = 0
     CL1                 endif
     * End date
     CL1                 if        wkedte <> 0
     CL1                 eval      $cvcmd = '*CMDMDY '
     CL1                 move      wkedte        $cvd8i
     CL1                 call      @cvtdt
     CL1                 parm                    $cvtdt
     CL1                 eval      w1edte = $cvd6o
     CL1                 else
     CL1                 eval      w1edte = 0
     CL1                 endif
     *
     CL1                 eval      w1stim = wkstim
     CL1                 eval      w1etim = wketim
     *
     CL1                 exsr      zzstamp
     CL1                 add       w1dmin        dtot(1)
     CL1                 add       w1dsec        sctot(1)
     *
530aACL1                 exsr      zzdrop
     *
CPCaACL1                 call      'GETGOALTM'
CPCaACL1                 parm                    wkwhse
CPCaACL1                 parm                    wktrn#
CPCaACL1                 parm                    goaltime
CPCaACL1                 if        goaltime <> *zeros
CPCaACL1                 add       goaltime      gltot(1)
CPCaACL1                 endif
     *
530cACL1                 exsr      zzIDLE
     *       SUPRESS PRINT TRANS START/END DETAIL
     CL1                 if        wktrn# = svtrn#
     CL1                 eval      w1sdte = 0
     CL1                 eval      w1stim = 0
     CL1                 eval      w1edte = 0
     CL1                 eval      w1etim = 0
     CL1                 eval      w1dmin = 0
     CL1                 eval      w1dsec = 0
530cACL1                 eval      w1imin = 0
530cACL1                 eval      w1isec = 0
     CL1                 endif
     CL1                 z-add     stot(1)       w1qtysa
     CL1                 z-add     ptot(1)       w1ptot
     CL1                 z-add     reck(1)       w1reck
CPCaACL1                 z-add     gltot(1)      w1gltm
     *
     CL1                 if        first=*on and *inlr=*on
     CL1                 else
EFCaACL1                 if        client = eastland
EFCaACL1                 exsr      zzEFCinfo
EFCaACL1                 write     detailEFC
EFCaACL1                 else
CPCaACL1                 if        client = cpc
CPCaACL1                 write     detail1c
CPCaACL1                 else
     CL1                 write     detail1
CPCaACL1                 endif
EFCaACL1                 endif
     CL1                 endif
     CL1                 eval      w1mult = ' '
     CL1                 eval      svtrn# = wktrn#
     *
     *  Accumulate totals
     *
     *
     CL1                 eval      l = 1
     CL1                 exsr      zrroll
     *----------------------------------------------------------------
     * TASK break
     *
     CL2                 eval      l = 2
     CL2                 exsr      zrroll
     *
     CL2                 if        reck(l) > 0
     CL2                 exsr      zrtotl
     CL2                 write     skip1
     CL2                 write     skip1
     CL2                 endif
     *
     *----------------------------------------------------------------
     * Zone break
     *
     CL3                 eval      l = 3
     CL3                 exsr      zrroll
     *
     CL3                 if        reck(l) > 0
     CL3                 if        $pzndp = 'Z'
     CL3                 exsr      zrtotl
     CL3                 endif
     CL3                 write     skip1
     CL3                 endif
     *----------------------------------------------------------------
     * Department Break
     *
     CL4                 if        wkwhdp<>*blanks
     CL4                 eval      l = 4
     CL4                 exsr      zrroll
     *
     CL4                 if        reck(l) > 0
     CL4                 exsr      zrtotl
     CL4                 write     skip1
     CL4                 endif
     CL4                 endif
     *----------------------------------------------------------------
     * Batch totals
     *
     CLR                 if        first = *off
     CLR                 eval      l = 5
     *
     CLR                 if        reck(l) > 0
     CLR                 exsr      zrtotl
     CLR                 write     skip1
     CLR                 write     foot1
     CLR                 endif
     CLR                 else
530aACLR                 move      $pemp#        wkemp#
     CLR                 exsr      zrfrmt
     CLR                 exsr      zrhead
     CLR                 write     skip1
     CLR                 write     foot2
     CLR                 write     foot1
     CLR                 endif
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     C     rpkey         klist
     C                   kfld                    wkprtf
     *
530bAC     rtkey         klist
530bAC                   kfld                    wkwhse
530bAC                   kfld                    kyrtid            5
     *
     C     tkkey         klist
     C                   kfld                    wktask
     *
     C     shkey         klist
     C                   kfld                    uswhse
     C                   kfld                    w1whdp
     C                   kfld                    usshft
     *
530aAC     passkey       klist
     C                   kfld                    wkemp#
     C                   kfld                    wktrn#
     *
     C     keyord        klist
     C                   kfld                    wkwhse
     C                   kfld                    lbord
     *
     C     keylb90       klist
     C                   kfld                    wkwhse
     C                   kfld                    wktrn#
     *
     C                   move      $pemp#        emp#
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
     C                   eval      w1whdp = *blanks
     *
     C                   time                    time
     C                   eval      first = *on
     C                   eval      svtrn# = 0
     C                   eval      l = 1
     C                   eval      n = 0
     C                   eval      begin = *off
     C                   exsr      zrzero
530aAC                   if        $pmrg = 'N'
530aAC                   eval      mrgtxt = mrg(1)
530aAC                   else
530aAC                   eval      mrgtxt = *blanks
530aAC                   endif
640aA *
640aA * Get client id.
640aA *
640aAC                   call      'GETCLIENT'
640aAC                   parm                    client           10
640aA *
640baC                   move      $pfmdt        fmdt
640baC                   move      $pbtim        btim
640baC                   move      $ptodt        todt
640baC                   move      $petim        etim
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrfrmt        begsr
     *
     *   Format report title.
     *
     *  Get report title.
     C                   movel     'ER361PR '    wkprtf
     C                   eval      rptttl = *blanks
     C     rpkey         chain     reporte                            79
     C                   if        not *in79
     C                   movel     erdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
     C                   eval      $plen = 60
     *   Center report title.
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   eval      rptttl = $pstr
     *  Format date range
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
     *  Format TIME range
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
     C                   if        not *inl3
     C                   eval      *in93 = *on
     C                   endif
     *
     C                   if        not *inl2
     C                   eval      *in92 = *on
     C                   endif
     *
     C                   if        not *inl4
     C                   eval      *in91 = *on
     C                   endif
     *
     C                   eval      *in90 = *off
     *
     C                   write     head1
     C                   write     head2
     *  Get employee name
     C                   write     ephead
     *  Columns
EFCaAC                   if        client = eastland
EFCaAC                   write     columnsEFC
EFCaAC                   else
CPCaAC                   if        client = cpc
CPCaAC                   write     columnsc
CPCaAC                   else
     C                   write     columns
CPCaAC                   endif
EFCaAC                   endif
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
530cAC                   add       dtoti(l)      dtoti(m)
530cAC                   add       sctoti(l)     sctoti(m)
     C                   add       ptot(l)       ptot(m)
     C                   add       stot(l)       stot(m)
CPCaAC                   add       gltot(l)      gltot(m)
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrtotl        begsr
     *
415 AC     sctot(l)      div(h)    60            dsecs
415 AC                   add       dsecs         dtot(l)
415 AC     dtot(l)       div(h)    60            dhrs
530cAC     sctoti(l)     div(h)    60            dsecsi
415 AC                   add       dsecsi        dtoti(l)
415 AC     dtoti(l)      div(h)    60            dhrsi
     C                   eval      t#ctot = reck(l)
     C                   eval      t#dtot = dhrs
530cAC                   eval      t#itot = dhrsi
     C                   eval      t#ptot = ptot(l)
     C                   eval      t#stot = stot(l)
CPCaAC                   eval      t#gltot = gltot(l)
     *                    Z-ADDRECK,L    T#RECK
     C                   eval      $rpd = *blanks
     C                   movel     rpd(l)        $rpd
     *
     C                   if        l<> 4
EFCaAC                   if        client = eastland
EFCaAC                   write     total1efc
EFCaAC                   else
CPCaAC                   if        client = cpc
CPCaAC                   write     total1c
CPCaAC                   else
     C                   write     total1
CPCaAC                   endif
EFCaAC                   endif
     *
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrzero        begsr
     *
     C                   eval      lvlk(l) = 0
     C                   eval      reck(l) = 0
     *
     C                   eval      sctot(l) = 0
     C                   eval      dtot(l) = 0
530cAC                   eval      sctoti(l) = 0
530cAC                   eval      dtoti(l) = 0
     C                   eval      ptot(l) = 0
     C                   eval      stot(l) = 0
     C                   eval      shrt(l) = 0
CPCaAC                   eval      gltot(l) = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     * zzdrop:  setup date stamp for drop transaction
     *----------------------------------------------------------------
     *
530aAC     zzdrop        begsr
     C     passkey       setll     passtran
     C                   dow       forever = forever
     C     passkey       reade     passtran
     C                   if        pastrn#=wktrn# and pasemp#=wkemp#
     C                             and not %EOF(PASSTRAN)
640bAC                   if        passdte >= fmdt and passdte <= todt
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
     C                             wketim < pasetim
     C                   eval      wketim = pasetim
     C                   when      wkedte > pasedte
     C                   eval      wkedte = pasedte
     C                   eval      wketim = pasetim
     C                   endsl
     *
     C                   if        wksdte <> 0
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      wksdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1sdte = $cvd6o
     C                   else
     C                   eval      w1sdte = 0
     C                   endif
     *
     C                   if        wkedte <> 0
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      wkedte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1edte = $cvd6o
     C                   else
     C                   eval      w1edte = 0
     C                   endif
     *
     C                   eval      w1etim = wketim
     C                   eval      w1stim = wkstim
     *
     C                   z-add     w1dmin        svdmin
     C                   z-add     w1dsec        svdsec
     *
     C                   move      passdte       wksdte
     C                   move      pasedte       wkedte
     C                   move      passtim       wkstim
     C                   move      pasetim       wketim
     C                   exsr      zzstamp
     C                   add       w1dmin        dtot(1)
     C                   add       w1dsec        sctot(1)
     C     svdmin        add       w1dmin        w1dmin
     C     svdsec        add       w1dsec        w1dsec
     C                   if        w1dsec>59
     C                   sub       60            w1dsec
     C                   add       1             w1dmin
     C                   endif
     C                   endif
640bAC                   endif
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
     C                   move      '*'           w1mult
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
     *
     *----------------------------------------------------------------
     * zzIDLE:  get Idle time associated with selection
     *----------------------------------------------------------------
     *
     C     zzIDLE        begsr
     *
     *
     C                   if        wksdtei <> 0 and wkedtei <> 0
     C                   z-add     w1dmin        svdmin
     C                   z-add     w1dsec        svdsec
     C                   if        wksdtei <> 0
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      wksdtei       $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      wksdte = $cvd6o
     C                   else
     C                   eval      wksdte = 0
     C                   endif
     *
     C                   if        wkedtei <> 0
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      wkedtei       $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      wkedte = $cvd6o
     C                   else
     C                   eval      wkedte = 0
     C                   endif
     *
     C                   z-add     w1dmin        svdmin
     C                   z-add     w1dsec        svdsec
     *
     C                   move      wksdtei       wksdte
     C                   move      wkedtei       wkedte
     C                   move      wkstimi       wkstim
     C                   move      wketimi       wketim
     C                   exsr      zzstamp
     C                   add       w1dmin        dtoti(1)
     C                   add       w1dsec        sctoti(1)
     C                   eval      w1imin = w1dmin
     C                   eval      w1isec = w1dsec
     C                   if        w1isec>59
     C                   sub       60            w1isec
     C                   add       1             w1imin
     C                   endif
     *
     C                   z-add     svdmin        w1dmin
     C                   z-add     svdsec        w1dsec
     C                   else
     C                   eval      w1isec = 0
     C                   eval      w1imin = 0
     C                   endif
     *
     C     endidle       endsr
     *
EFCaA*----------------------------------------------------------------
EFCaA* zzEFCinfo:  Get additional information for print line
EFCaA*----------------------------------------------------------------
     *
     C     zzEFCinfo     begsr
     *
     C                   eval      ordpcs = *zeros
     *
     C     keylb90       chain     label90
     C                   if        %found(label90)
     C     keyord        chain     ordh
     C                   if        %found(ordh)
     C     keyord        setll     ordd
     C                   dow       forever = forever
     C     keyord        reade     ordd
     C                   if        not %EOF(ordd)
     C                   add       odqor1        ordpcs
     C                   else
     C                   leave
     C                   endif
     C                   enddo
     C                   endif
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
**      RPD   Report level descriptions

 ** Task **
 ** Zone/Department **
 * Department *
 *** Totals
**      DTE   Date headings
99/99/99 thru 99/99/99
     From 99/99/99
     Thru 99/99/99

**      TME   TIME headings
99:99:99 thru 99:99:99
**      MRG   Merge records info
**Pieces Do Not Include Merge Pickup Pieces**
