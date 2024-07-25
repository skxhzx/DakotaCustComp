      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ER371     Task report for an employee
     *  24 March, 2000
     *  Hemant Kapadia
     *
     *  03.24.00  HNK  4.13
     *   Created
     *
     * Note: Replaces ER241
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
530  *  07/22/09   GJA  5.30
     *     -Enh:  Convert to RPGLE, cleaned up and revamped for
     *            suspended transactions
     *
530a *  03/02/10  GJA  5.30a
     *    - Enh:  capture multiple drops per employee/transaction
     *
     *
640a *  05/03/11  GJA  6.40a
     *    - Enh:  add custom client code
     *
640b *  07/20/11  GJA  6.40b
     *    - Fix:  not calculating multiple transaction time correctly
     *
640c *  11/21/11  GJA  6.40c
     *    - Enh:  Eastland allows for employee to do one transaction
     *            across multiple days
     *
650 A*  08/04/14  MLB  6.50
     *    - Fix:  Revised pgm to increase size of variables dmin, dsecs,
     *            svdmin, svdsecs to correct MCH1210 - Receiver value
     *            too small to hold result error.
     *
     *----------------------------------------------------------------
     *  Custom client revisions:  Crumbley
     *
CPCa *  05/03/11  GJA  CPCa
     *    - Enh:  add goal time column
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
     Fer371a    ip   e           k disk
     Ftask      if   e           k disk
     Fpiruser1  if   e           k disk
     Freporte   if   e           k disk
530aAFpasstran  if   e           k disk
     Fer371pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     D taskInfo        ds
     D  ztask                              dim(99)
     D  ttask                         6    overlay(ztask : *NEXT)
     D  ttaskd                        7  2 overlay(ztask : *NEXT)
     D  ttaski                        7  2 overlay(ztask : *NEXT)
     D  ttaskp                        7  0 overlay(ztask : *NEXT)
     D  ttasks                        7  0 overlay(ztask : *NEXT)
     D rpd             s             25    dim(5) ctdata perrcd(1)
     D reck            s              7  0 dim(5)
     D lvlk            s              7  0 dim(5)
     *
     D rtot            s              7  0 dim(5)
     D dtot            s              7  2 dim(5)
530aAD sctot           s              7  2 dim(5)
     D ptot            s              7  0 dim(5)
     D itot            s              7  2 dim(5)
     D dte             s             22    dim(4) ctdata perrcd(1)
     D a22             s              1    dim(22)
     *
     D mtxt            s             45    dim(1) ctdata perrcd(1)
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
640aA*----------------------------------------------------------------
640aA*  Customer id
640aA*
CPCaA /copy qcopysrc,id#cpc
     *----------------------------------------------------------------
     *  Variables
     *
     D $cmd            s              8
     D $name           s             40
     D $plen           s              3  0
     D $pstr           s             60
     D $rpd            s             20
     D $tdtetme        s               z
     D $fdtetme        s               z
     D p1sdte          s              8  0
     D p1edte          s              8  0
     D p1stim          s              6  0
     D p1etim          s              6  0
     D svsdte          s              8  0
     D svedte          s              8  0
     D svstim          s              6  0
     D svetim          s              6  0
     D wksdtec         s              8
     D wkedtec         s              8
     D wkstimc         s              6
     D wketimc         s              6
     D tdtetme         s             26
     D fdtetme         s             26
530aAD forever         s              1
     D begin           s              1
     D c               s              2  0
     D dhrs            s              7  2
650 DD*svdmin          s              5  0
650 MD svdmin          s              7  0
650 DD*svdsec          s              5  0
650 MD svdsec          s              7  0
650 DD*dmins           s              5  0
650 MD dmins           s              7  0
650 DD*dsecs           s              5  0
650 MD dsecs           s              7  0
     D emp#            s              5  0
     D first           s              1
     D i               s              2  0
     D ihrs            s              7  2
     D l               s              1  0
     D m               s                   like(l)
     D n               s              3  0
     D svtrn#          s              7  0
     D wkprtf          s             10
CPCaAD goaltime        s              7  3
640cAD todt            s              8  0
640cAD fmdt            s              8  0
640caD btim            s              6  0
640caD etim            s              6  0
     *
     Iwkrec
     I                                          wktrn#        l1
     *----------------------------------------------------------------
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
     C                   parm                    $pbtim
     C                   parm                    $petim
     *----------------------------------------------------------------
     *  Let the show begin .....
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
     C                   exsr      zrfrmt
     C                   exsr      zrhead
     C                   endif
     *
     C                   if        w1trn# <> wktrn#
     C                   z-add     ptot(1)       w1ptot
     C                   z-add     reck(1)       w1reck
530aAC                   exsr      zzdrop
     C                   add       w1dmin        dtot(1)
520aAC                   add       w1dsec        sctot(1)
     C                   add       w1imin        itot(1)
     C                   if        first = *off
     C                   exsr      zsummary
CPCaAC                   if        client = cpc
CPCaAC                   write     detail1c
CPCaAC                   else
     C                   write     detail1
CPCaAC                   endif
     C                   eval      w1mult=' '
     C                   endif
     C                   eval      l = 1
     C                   exsr      zrroll
     C                   exsr      zrzero
     C                   eval      w1trn# = wktrn#
     C                   eval      w1whdp = wkwhdp
     C                   eval      w1task = wktask
     C                   eval      w1zone = wkzone
     C                   eval      p1sdte = wksdte
     C                   eval      p1stim = wkstim
     C                   eval      p1edte = wkedte
     C                   eval      p1etim = wketim
     C                   eval      w1gltm = *zeros
CPCaAC                   if        wktask = 'FIXED '
CPCaAC                   call      'GETGOALTM'
CPCaAC                   parm                    wkwhse
CPCaAC                   parm                    wktrn#
CPCaAC                   parm                    goaltime
CPCaAC                   if        goaltime <> *zeros
CPCaAC                   eval      w1gltm = goaltime
CPCaAC*                  add       goaltime      gltot(1)
CPCaAC                   endif
CPCaAC                   endif
     C                   if        wkimin = 0
     C                   exsr      zzstamp
     C                   else
     C                   eval      w1dmin = 0
     C                   eval      w1dsec = 0
530aAC                   eval      w1dsec = 0
     C                   endif
     C                   eval      w1imin = wkimin
     C                   endif
     *
     C                   add       1             reck(1)
     C                   add       1             lvlk(1)
     C                   eval      *in92 = *off
     *
     C                   eval      *in91 = *off
     C                   eval      first = *off
     *
     *  Accumulate totals
     C                   add       wkpcs         ptot(1)
     *
     *----------------------------------------------------------------
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
     C                   if        wkedte <> 0
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      wkedte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1edte = $cvd6o
     C                   else
     C                   eval      w1edte = 0
     C                   endif
     C                   eval      w1etim = wketim
     C                   eval      w1stim = wkstim
     *
     *
     *
     *----------------------------------------------------------------
     *
     CLR                 if        first = *on
530aACLR                 move      $pemp#        wkemp#
     CLR                 exsr      zrfrmt
     CLR                 exsr      zrhead
     CLR                 write     skip1
     CLR                 write     foot2
     CLR                 write     foot1
     CLR                 else
     Clr                 z-add     ptot(1)       w1ptot
     Clr                 z-add     reck(1)       w1reck
     Clr                 add       w1dmin        dtot(1)
     Clr                 add       w1imin        itot(1)
     CLR                 exsr      zsummary
CPCaACLR                 if        client = cpc
CPCaAClr                 write     detail1c
CPCaACLR                 else
     Clr                 write     detail1
CPCaACLR                 endif
     Clr                 eval      l = 1
     Clr                 exsr      zrroll
     CLR                 exsr      zrtotl
     CLR                 write     foot1
     CLR                 endif
     CLr                 return
     *
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
     C                   time                    time
     *
530aAC     passkey       klist
     C                   kfld                    wkemp#
     C                   kfld                    w1trn#
     C                   eval      first = *on
     C                   eval      l = 1
     C                   eval      n = 0
     C                   eval      begin = *off
     C                   exsr      zrzero
     C                   dou       %EOF(TASK)
     C                   read      task
     C                   eval      c += 1
     C                   eval      ttask(c) = tkcode
     C                   eval      ttaskp(c) = *zeros
     C                   eval      ttaskd(c) = *zeros
     C                   eval      ttaski(c) = *zeros
     C                   eval      ttasks(c) = *zeros
     C                   enddo
640aA *
640aA * Get client id.
640aA *
640aAC                   call      'GETCLIENT'
640aAC                   parm                    client           10

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
     *
     C                   movel     'ER371PR '    wkprtf
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
     *  Format merge pieces text
     C                   if        $pmrg = 'N'
     C                   eval      mrgtxt = mtxt(1)
     C                   else
     C                   eval      mrgtxt = *blanks
     C                   endif
     C                   move      '00'          $pbsec
     C                   move      $pbtim        begtim
     C                   move      '00'          $pesec
     C                   move      $petim        endtim
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     *
     C                   eval      *in90 = *off
     *
     C                   write     head1
     *
     *  Get employee name
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
     C                   write     ephead
     *  Columns
CPCaAC                   if        client = cpc
CPCaAC                   write     columnsc
CPCaAC                   else
     C                   write     columns
CPCaAC                   endif
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
     C*                  add       dtot(l)       dtot(m)
530aAC                   add       sctot(l)      sctot(m)
     C                   add       ptot(l)       ptot(m)
     C*                  add       itot(l)       itot(m)
     C                   add       reck(l)       rtot(m)
     C                   add       w1dmin        dtot(m)
     C                   add       w1imin        itot(m)
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrtotl        begsr
     *
     C                   z-add     2             m
530aAC     sctot(m)      div(h)    60            dsecs
530aAC                   add       dsecs         dtot(m)
     C     dtot(m)       div(h)    60            dhrs
     C     itot(m)       div(h)    60            ihrs
     C                   eval      t#dtoth = dhrs
     C                   eval      t#itoth = ihrs
     C                   eval      t#rtot = rtot(m)
     C                   eval      t#dtot = dtot(m)
     C                   eval      t#ptot = ptot(m)
     C                   eval      t#itot = itot(m)
     *
     *                    Z-ADDRECK,L    T#RECK
     *
     C*                  eval      $rpd = *blanks
     C*                  movel     rpd(l)        $rpd
     *
     C                   write     total1
     C                   write     total2
     C                   write     summry1
     *
     C                   eval      i=1
     C                   dou       ttask(i)=*blanks
     C                   if        ttaskp(i)<>0 or ttaski(i)<>0
     C                             or ttaskd(i)<>0 or ttasks(i)<>0
     C                   eval      td = ttask(i)
     C                   eval      tdp = ttaskp(i)
530aAC     ttasks(i)     div(h)    60            dsecs
530aAC                   add       dsecs         ttaskd(i)
     C                   eval      tdd = ttaskd(i)
     C                   eval      tdi = ttaski(i)
     C                   write     summry2
     C                   endif
     C                   eval      i +=1
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrzero        begsr
     *
     C                   eval      lvlk(l) = 0
     C                   eval      reck(l) = 0
     *
     C                   eval      rtot(l) = 0
     C                   eval      dtot(l) = 0
     C                   eval      sctot(l) = 0
     C                   eval      ptot(l) = 0
     C                   eval      itot(l) = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zsummary      begsr
     *
     C                   eval      i= 1
     C     w1task        lookup    ttask(i)                               26
     C                   if        %equal
     C                   eval      ttaskp(i) += ptot(1)
530aAC*    sctot(1)      div(h)    60            dsecs
530aAC*                  add       dsecs         dtot(1)
     C                   eval      ttasks(i) += sctot(1)
     C                   eval      ttaskd(i) += dtot(1)
     C                   eval      ttaski(i) += itot(1)
     C                   endif
     *
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
     C                   if        pastrn#=w1trn# and pasemp#=wkemp#
     C                             and not %EOF(PASSTRAN)
640bAC                   if        passdte >= fmdt and passdte <= todt
     C                   if        p1sdte = passdte and
     C                             p1stim = passtim and
     C                             p1edte = pasedte and
     C                             p1etim = pasetim
     C                   else
     *
     C                   select
     C                   when      p1sdte = passdte and
     C                             p1stim = passtim
     C                   when      p1sdte = passdte and
     C                             p1stim > passtim
     C                   eval      w1stim = passtim
     C                   when      p1sdte > passdte
     C                   eval      w1sdte = passdte
     *
     C                   if        w1sdte <> 0
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      w1sdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1sdte = $cvd6o
     C                   else
     C                   eval      w1sdte = 0
     C                   endif
     C                   eval      w1stim = passtim
     C                   endsl
     *  End date or time is greater
     C                   select
     C                   when      p1edte = pasedte and
     C                             p1etim = pasetim
     C                   when      p1edte = pasedte and
     C                             p1etim < pasetim
     C                   eval      w1etim = pasetim
     C                   when      p1edte > pasedte
     C                   eval      w1edte = pasedte
     C                   if        w1edte <> 0
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      w1edte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1edte = $cvd6o
     C                   eval      w1etim = pasetim
     C                   else
     C                   eval      w1edte = 0
     C                   endif
     *
     C                   endsl
     *
     C                   move      wksdte        svsdte
     C                   move      wkedte        svedte
     C                   move      wkstim        svstim
     C                   move      wketim        svetim
     *
     C                   z-add     w1dmin        svdmin
     C                   z-add     w1dsec        svdsec
     *
     C                   move      passdte       wksdte
     C                   move      pasedte       wkedte
     C                   move      passtim       wkstim
     C                   move      pasetim       wketim
     *
     C                   exsr      zzstamp
     *
     C                   move      svsdte        wksdte
     C                   move      svedte        wkedte
     C                   move      svstim        wkstim
     C                   move      svetim        wketim
     *
     C*                  add       w1dmin        dtot(1)
     C*                  add       w1dsec        sctot(1)
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
     *
     *     Get task description.
     *
     C     wktask        chain     task                               79
     C                   if        *in79
     C                   eval      tktype = *blank
     C                   endif
     C                   if        wkedte<>0
     C                   eval      w1mult = ' '
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
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
**      RPD   Report level descriptions
 * Transaction *
 ** Dept totals **
 *** Task totals***
 **** Task totals****
 ***** Totals
**      DTE   Date headings
99/99/99 thru 99/99/99
     From 99/99/99
     Thru 99/99/99

**  Merge pieces text                       510bA
**Pieces Do Not Include Merge Pickup Pieces**
