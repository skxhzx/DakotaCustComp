      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL  60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TB300     Palletizer Report ...
     *              Tote and bundle counts and transactions
     *
     *  14 April 2010
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
530 A*    04/14/10  RBD  5.30
     *      - Created.
     *      - Client custom code support included.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Finkle Distributing
     *
FDI A*    04/14/10  RBD  FDI
     *      - Coded to use Finkle's zone groups.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  91        - Overflow indicator - primary report
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fordh      if   e           k disk
     Fpltsum15  if   e           k disk
     Ftotebund2 if   e           k disk
     Ftotebund2Sif   e           k disk    prefix(zo_)
     F                                     rename(tbrec:tbrecZo)
     Ftotebund21if   e           k disk    prefix(tr1_)
     F                                     rename(tbrec:tbrecTr1)
     Ftotebund22if   e           k disk    prefix(tr2_)
     F                                     rename(tbrec:tbrecTr2)
     Ftotebund23if   e           k disk    prefix(tr3_)
     F                                     rename(tbrec:tbrecTr3)
     Ftotebund24if   e           k disk    prefix(tr4_)
     F                                     rename(tbrec:tbrecTr4)
     Ftotebund25if   e           k disk    prefix(tr5_)
     F                                     rename(tbrec:tbrecTr5)
     Ftotebund26if   e           k disk    prefix(tr6_)
     F                                     rename(tbrec:tbrecTr6)
     Fwarehs    if   e           k disk
     Ftb300pr   o    e             printer oflind(*in91)
     F                                     usropn
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a80             s              1    dim(80)
     D ul              s              1    dim(124)
     D L1T             s              5  0 dim(7)
     D L1B             s              5  0 dim(7)
     D LrT             s              5  0 dim(7)
     D LrB             s              5  0 dim(7)
     D trn             s              7  0 dim(6)
     D zg              s              6    dim(5)
     D ovrprt          s             80    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
      /copy qcopysrc,ID#FINKLE
     *----------------------------------------------------------------
     *  Constants
     *
     *----------------------------------------------------------------
     *  Working variables
     *
     D $pwhse          s              3  0
     D atLeast1        s              1
     D count           s              3  0
     D dummy           s              3  0
     D eofh            s              1
     D excprt          s              1
     D excpr1          s              1
     D first           s              1
     D forever         s              1
     D impdte          s              8  0
     D imptim          s              6  0
     D kyzong6         s                   like(tbzong)
     D len             s              1  0
     D linppg          s              3  0
     D lststop         s                   like(tbstop)
     D lstwhs          s              3  0
     D opened          s              1
     D pflag           s              1
     D pos             s              1  0
     D prhdr1          s              1
     D rcdlck          s              1
     D rtcnt           s              3  0
     D skpwrt          s              1
     D sublin          s              3  0
     D today           s              8  0
     D work3a          s              3
     D z               s              1  0
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
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
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PRTID  Route id
     *      $PPLID  Merge pallet id
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $pplid            7 0
     *----------------------------------------------------------------
     * Key definitions
     *
     * Order header file
     *
     C     keyoh         klist
     C                   kfld                    zo_tbwhse
     C                   kfld                    zo_tbord
     *
     * Pallet summary file
     *
     C     keyps15       klist
     C                   kfld                    tbwhse
     C                   kfld                    tbrtid
     C                   kfld                    tbmpl#
     *
     * Tote and bundle count file
     *
     C     keytb2        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    $pplid
     *
     * Tote and bundle count file
     *
     C     keytb2s       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    $pplid
     C                   kfld                    tbstop
     *
     * Tote and bundle count file zone group 1
     *
     C     keytb21       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    $pplid
     C                   kfld                    tbstop
     C                   kfld                    zg(1)
     *
     * Tote and bundle count file zone group 2
     *
     C     keytb22       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    $pplid
     C                   kfld                    tbstop
     C                   kfld                    zg(2)
     *
     * Tote and bundle count file zone group 3
     *
     C     keytb23       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    $pplid
     C                   kfld                    tbstop
     C                   kfld                    zg(3)
     *
     * Tote and bundle count file zone group 4
     *
     C     keytb24       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    $pplid
     C                   kfld                    tbstop
     C                   kfld                    zg(4)
     *
     * Tote and bundle count file zone group 5
     *
     C     keytb25       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    $pplid
     C                   kfld                    tbstop
     C                   kfld                    zg(5)
     *
     * Tote and bundle count file zone group 'Other'.
     *  In other words, if it's not one of the 5 predefined
     *  zone groups, it goes into the 6th bucket, 'Other'.
     *  This key includes zone group.
     *
     C     keytb26       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    $pplid
     C                   kfld                    tbstop
     C                   kfld                    kyzong6
     *  This key does not include zone group.
     C     keytb26x      klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    $pplid
     C                   kfld                    tbstop
     *
     *----------------------------------------------------------------
     * Main line
     *
     *
     * Whip through all totebund records by stop.  At the beginning of each
     * stop, go tally up the total tote and bundle counts by zone group for
     * the stop and print.  Then, read the first transaction of each zone
     * group for the stop and print that line.  Then read the second trans
     * of each zone group for the stop and print that line, etc, etc, until
     * there are no more transactions for the stop.  Then go start all over
     * again with the next stop.
     *
     C     keyTB2        setll     totebund2
     C                   dow       forever = forever
     C     keyTB2        reade     totebund2
     C                   select
     *
     C                   when      %eof(totebund2)
     C                   leave
     *
     C                   other
     *
     *    If first time through get data and print headings
     C                   if        first = *on
     C                   eval      first = *off
     C                   exsr      getHead
     C                   write     head1
     C                   write     undlin
     C                   eval      count = 6
     C                   endif
     *
     *    Whip through all totebund records for the stop and print the total
     *     tote counts and bundle counts for each zone group in the stop.
     C                   exsr      getStopTB
     *      Print report heading if necessary.
     C                   add       5             count
     C                   if        count >= linppg
     C                   write     head1
     C                   write     undlin
     C                   eval      count = 6
     C                   endif
     C                   write     detail1
     *
     *    Now go back through the totebund records and print the transaction
     *     lines.
     C                   exsr      getTrans
     *
     C                   endsl
     *
     *    Move on to the next stop.
     C     keyTB2s       setgt     totebund2
     *
     C                   enddo
     *
     *  Print grand totals
     *
     C                   exsr      prtGrndTot
     *
     *  We are finished so get out
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     C                   parm                    cliloc           10
     *
FDI A* Populate zone group headings.
FDI AC                   if        client = Finkle
FDI AC                   eval      zg(1) = 'CHEM  '
FDI AC                   eval      zg(2) = 'GROC  '
FDI AC                   eval      zg(3) = 'CANDY '
FDI AC                   eval      zg(4) = 'TOB   '
FDI AC                   eval      zg(5) = 'CIG   '
FDI AC                   endif
     *
     *  Variables and constants.
     *
     C                   eval      z1hdg = zg(1)
     C                   eval      z2hdg = zg(2)
     C                   eval      z3hdg = zg(3)
     C                   eval      z4hdg = zg(4)
     C                   eval      z5hdg = zg(5)
     C                   eval      forever = *off
     C                   eval      first = *on
     C                   eval      ul = '_'
     C                   movea     ul            unline
     C                   eval      linppg = 55
     C                   eval      count = 0
     *
     * Initialize grand total fields
     C                   eval      lrt    = 0
     C                   eval      lrb    = 0
     C                   eval      c1tb_t = ' '
     C                   eval      c2tb_t = ' '
     C                   eval      c3tb_t = ' '
     C                   eval      c4tb_t = ' '
     C                   eval      c5tb_t = ' '
     C                   eval      c6tb_t = ' '
     C                   eval      c7tb_t = ' '
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     *  Create warehouse heading
     *
     C     $pwhse        chain     warehs
     C                   if        not %found(warehs)
     C                   eval      whdesc = *blanks
     C                   endif
     C                   move      $pwhse        work3a
     C     ' 0'          check     work3a        pos
     C                   if        pos = 0
     C                   eval      pos = 1
     C                   endif
     C                   eval      len = 4 - pos
     C     len           subst     work3a:pos    whhead
     C     whhead        cat       '-':1         whhead
     C     whhead        cat       whdesc:1      whhead
     C                   call      'CENTER'
     C                   parm      whhead        $cstr            60
     C                   parm      40            $clen             3 0
     C                   movel     $cstr         whhead
     *
     *    Get exceptions report override if any.
     C                   exsr      opnprt
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETHEAD   Get heading fields.
     *
     C     getHead       begsr
     *
     C     keyps15       chain     pltsum15
     C                   if        %found(pltsum15)
     C                   eval      w1pal# = %TrimL(%editc(pspal#:'P'))
     C                   eval      w1stp1 = psstp1
     C                   eval      w1stp2 = psstp2
     C                   else
     C                   eval      w1pal# = ' '
     C                   eval      w1stp1 = 0
     C                   eval      w1stp2 = 0
     C                   eval      pstrn# = 0
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETSTOPTB  Get tote and bundle counts for this stop.
     *
     C     getStopTB     begsr
     *
     *    Initialize tote and bundle count arrays.
     C                   eval      L1T = 0
     C                   eval      L1B = 0
     *
     C     keyTB2S       setll     totebund2S
     C                   dow       forever = forever
     C     keyTB2S       reade     totebund2S
     C                   select
     *
     C                   when      %eof(totebund2S)
     C                   leave
     *
     C                   other
     C                   eval      z = 1
     C     zo_tbzong     lookup    zg(z)                                  82
     C                   if        %found
     C                   eval      L1T(z) = L1T(z) + zo_tbqtot
     C                   eval      L1B(z) = L1B(z) + zo_tbqbun
     C                   else
     *    If not a defined zone group, add to 'Other' column
     C                   eval      L1T(6) = L1T(6) + zo_tbqtot
     C                   eval      L1B(6) = L1B(6) + zo_tbqbun
     C                   endif
     *    Total column
     C                   eval      L1T(7) = L1T(7) + zo_tbqtot
     C                   eval      L1B(7) = L1B(7) + zo_tbqbun
     *
     C                   endsl
     *
     C                   enddo
     *
     *   Add stop totals to grand totals.
     C                   eval      LrT = LrT + L1T
     C                   eval      LrB = LrB + L1B
     *
     *   Fill print fields.
     C                   eval      w1stop = zo_tbstop

     C     keyoh         chain     ordh
     C                   if        not %found(ordh)
     C                   eval      ohcust = 0
     C                   eval      ohcnam = ' '
     C                   endif
     C                   eval      ohcusa = %TrimL(%editc(ohcust:'P'))

     C                   eval      c1tb = %TrimL(%editc(L1T(1):'P'))
     C                                  + '/'
     C                                  + %TrimL(%editc(L1B(1):'P'))
     C                   eval      c2tb = %TrimL(%editc(L1T(2):'P'))
     C                                  + '/'
     C                                  + %TrimL(%editc(L1B(2):'P'))
     C                   eval      c3tb = %TrimL(%editc(L1T(3):'P'))
     C                                  + '/'
     C                                  + %TrimL(%editc(L1B(3):'P'))
     C                   eval      c4tb = %TrimL(%editc(L1T(4):'P'))
     C                                  + '/'
     C                                  + %TrimL(%editc(L1B(4):'P'))
     C                   eval      c5tb = %TrimL(%editc(L1T(5):'P'))
     C                                  + '/'
     C                                  + %TrimL(%editc(L1B(5):'P'))
     C                   eval      c6tb = %TrimL(%editc(L1T(6):'P'))
     C                                  + '/'
     C                                  + %TrimL(%editc(L1B(6):'P'))
     C                   eval      c7tb = %TrimL(%editc(L1T(7):'P'))
     C                                  + '/'
     C                                  + %TrimL(%editc(L1B(7):'P'))
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  GETTRANS  Get the first transaction for each zone group and
     *            print a line ... get the second transaction for each
     *            zone group and print a line, etc etc until there are
     *            no more transactions for this stop.
     *
     C     getTrans      begsr
     *
     C     keyTB21       setll     totebund21
     C     keyTB22       setll     totebund22
     C     keyTB23       setll     totebund23
     C     keyTB24       setll     totebund24
     C     keyTB25       setll     totebund25
     C     keyTB26x      setll     totebund26

     C                   dow       forever = forever
     C                   eval      atLeast1 = *off
     C                   eval      trn = 0

     C     keyTB21       reade     totebund21
     C                   if        not %eof(totebund21)
     C                   eval      trn(1) = tr1_tbtrn#
     C                   eval      atLeast1 = *on
     C                   endif
     *
     C     keyTB22       reade     totebund22
     C                   if        not %eof(totebund22)
     C                   eval      trn(2) = tr2_tbtrn#
     C                   eval      atLeast1 = *on
     C                   endif
     *
     C     keyTB23       reade     totebund23
     C                   if        not %eof(totebund23)
     C                   eval      trn(3) = tr3_tbtrn#
     C                   eval      atLeast1 = *on
     C                   endif
     *
     C     keyTB24       reade     totebund24
     C                   if        not %eof(totebund24)
     C                   eval      trn(4) = tr4_tbtrn#
     C                   eval      atLeast1 = *on
     C                   endif
     *
     C     keyTB25       reade     totebund25
     C                   if        not %eof(totebund25)
     C                   eval      trn(5) = tr5_tbtrn#
     C                   eval      atLeast1 = *on
     C                   endif
     *
     C                   dow       forever = forever
     C     keyTB26x      reade     totebund26
     C                   if        %eof(totebund26)
     C                   leave
     C                   else
     C                   eval      z = 1
     C     tr6_tbzong    lookup    zg(z)                                  82
     C                   if        %found
     C                   eval      kyzong6 = tr6_tbzong
     C     keyTB26       setgt     totebund26
     C                   else
     C                   eval      trn(6) = tr6_tbtrn#
     C                   eval      atLeast1 = *on
     C                   leave
     C                   endif
     C                   endif
     C                   enddo
     *
     C                   if        atLeast1 = *on
     *      Print report heading if necessary.
     C                   add       1             count
     C                   if        count >= linppg
     C                   write     head1
     C                   write     undlin
     C                   eval      count = 6
     C                   endif
     C                   exsr      zzFill2
     C                   write     detail2
     *   Clear ohcnam, only one to print it once for each stop.
     C                   eval      ohcnam = ' '
     C                   else
     C                   leave
     C                   endif
     *
     C                   enddo
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  OPNPRT  Open printer file.
     *
     C     opnprt        begsr
     *
     *   Get device and form type for main report.
     *
     C                   call      'GETRPT'
     C                   parm      '*DEVFORM'    $cmd              8
     C                   parm      'TB300PR'     $lrpt            10
     C                   parm                    $pwhse
     C                   parm      *blanks       $styp             1
     C                   parm      *blanks       $whdp             5
     C                   parm                    $desc            50
     C                   parm                    $dev             10
     C                   parm                    $form            10
     C                   if        $dev = *blanks
     C                   movel     '*JOB'        $dev
     C                   endif
     C                   if        $form = *blanks
     C                   movel     '*STD'        $form
     C                   endif
     *
     *      Open printer file.
     *
     C                   if        opened <> *on
     *
     *      If printer already open then close it.
     *
     C                   if        opened = *on
     C                   close     tb300pr
     C                   endif
     *
     *      Override printer file.
     *
     C                   movea     ovrprt(1)     a80
     C                   movea     $dev          a80(38)
     C                   movea     $form         a80(59)
     C                   movea     a80           qcmd
     *
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
     *
     *      Open printer file.
     *
     C                   open      tb300pr
     C                   eval      opened = *on
     *
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  PRTGRNDTOT  Print grand totals.
     *
     C     prtGrndTot    begsr
     *
     C                   if        count >= linppg
     C                   write     head1
     C                   endif
     *
     *   Fill print fields.

     C                   eval      c1tb_t = %TrimL(%editc(LrT(1):'P'))
     C                                    + '/'
     C                                    + %TrimL(%editc(LrB(1):'P'))
     C                   eval      c2tb_t = %TrimL(%editc(LrT(2):'P'))
     C                                    + '/'
     C                                    + %TrimL(%editc(LrB(2):'P'))
     C                   eval      c3tb_t = %TrimL(%editc(LrT(3):'P'))
     C                                    + '/'
     C                                    + %TrimL(%editc(LrB(3):'P'))
     C                   eval      c4tb_t = %TrimL(%editc(LrT(4):'P'))
     C                                    + '/'
     C                                    + %TrimL(%editc(LrB(4):'P'))
     C                   eval      c5tb_t = %TrimL(%editc(LrT(5):'P'))
     C                                    + '/'
     C                                    + %TrimL(%editc(LrB(5):'P'))
     C                   eval      c6tb_t = %TrimL(%editc(LrT(6):'P'))
     C                                    + '/'
     C                                    + %TrimL(%editc(LrB(6):'P'))
     C                   eval      c7tb_t = %TrimL(%editc(LrT(7):'P'))
     C                                    + '/'
     C                                    + %TrimL(%editc(LrB(7):'P'))
     *
     C                   write     grndttl
     C                   write     foot1
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFILL2     Fill detail2 print fields.
     *
     C     zzFill2       begsr
     *
     C                   eval      c1trn = %TrimL(%editc(trn(1):'P'))
     C                   eval      c2trn = %TrimL(%editc(trn(2):'P'))
     C                   eval      c3trn = %TrimL(%editc(trn(3):'P'))
     C                   eval      c4trn = %TrimL(%editc(trn(4):'P'))
     C                   eval      c5trn = %TrimL(%editc(trn(5):'P'))
     C                   eval      c6trn = %TrimL(%editc(trn(6):'P'))
     *
     C                   if        c1trn = '0      '
     C                   eval      c1trn = ' '
     C                   endif
     C                   if        c2trn = '0      '
     C                   eval      c2trn = ' '
     C                   endif
     C                   if        c3trn = '0      '
     C                   eval      c3trn = ' '
     C                   endif
     C                   if        c4trn = '0      '
     C                   eval      c4trn = ' '
     C                   endif
     C                   if        c5trn = '0      '
     C                   eval      c5trn = ' '
     C                   endif
     C                   if        c6trn = '0      '
     C                   eval      c6trn = ' '
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  Compile Time Tables
     *
**   OVRPRTF statment
OVRPRTF FILE(TB300PR) OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
