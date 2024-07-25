500eA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL  60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  GT155     Import Picked Route Goal Times - Post
     *  07 October 2009
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    10/07/09  MLB  5.20
     *      - Created.
     *      - Client custom code support included.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: client name here
     *
ccc A*    mm/dd/yy  iii  ccc
     *      -
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  91        - Overflow indicator - primary report
     *  92        - Overflow indicator - exceptions report
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fimpfgoal  uf   e           k disk
     Fpirtran   if   e           k disk
     Frtehed    if   e           k disk
     Fwarehs    if   e           k disk
     Fgt155pr   o    e             printer oflind(*in91)
     Fgt1551pr  o    e             printer oflind(*in92)
     F                                     usropn
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             30    dim(2) ctdata perrcd(1)
     D rdsc            s             50    dim(1) ctdata perrcd(1)
     D a80             s              1    dim(80)
     D ovrprt          s             80    dim(2) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
     *----------------------------------------------------------------
     *  Constants
     *
     D exchdr          c                   const('- Exceptions')
     *
     *----------------------------------------------------------------
     *  Working variables
     *
     D $pwhse          s              3  0
     D count           s              3  0
     D dummy           s              3  0
     D eofh            s              1
     D excprt          s              1
     D excpr1          s              1
     D forevr          s              1
     D impdte          s              8  0
     D imptim          s              6  0
     D kyrtid          s                   like(rhrtid)
     D len             s              1  0
     D linppg          s              3  0
     D lstrid          s                   like(gilrte)
     D lstrte          s                   like(gilrte)
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
     *      $PCMD   Command - *GOALTIM
     *
     *    Returned Parameters
     *      $PWHS   Warehouse to process.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pwhs            15 5
     *----------------------------------------------------------------
     * Key definitions
     *
     * Transaction file
     *
     C     keypt         klist
     C                   kfld                    giltrn
     *
     * Route header file
     *
     C     keyrh         klist
     C                   kfld                    gilwhs
     C                   kfld                    gilrid
     *
     *----------------------------------------------------------------
     * Main line
     *
     * Get report heading.
     *
     C                   eval      w1head = *blanks
     C                   movel     rdsc(1)       $pstr
     C                   eval      $plen = 50
     *
     C                   call      'CENTER'
     C                   parm                    $pstr            60
     C                   parm                    $plen             3 0
     C                   movel     $pstr         w1head
     *
     *    Create heading for exceptions report.
     *
     C                   eval      $pstr = %trimr(rdsc(1)) + ' ' + exchdr
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         w1hdr1
     C                   eval      *in92 = *on
     C                   eval      prhdr1 = *off
     C                   eval      excprt = *off
     C                   eval      excpr1 = *off
     *
     * Initialize grand total fields
     *
     C                   eval      grdord = 0
     C                   eval      grdlin = 0
     C                   eval      grord1 = *zeros
     C                   eval      grlin1 = *zeros
     C                   eval      preoh = 0
     C                   eval      preod = 0
     *
     * Whip through all the download header records
     *
     C                   eval      lstrte = '@@@@@'
     C                   eval      lstrid = '@@@@@'
     C                   eval      pflag = *off
     C                   eval      eofh = *off
     C                   eval      linppg = 55
     C                   eval      count = 0
     C                   eval      lstwhs = -(1)
     *
     C                   dou       eofh = *on
     *
     C                   read      impfgoal
     C                   if        %eof(impfgoal)
     C                   leave
     C                   endif
     *
     *  Create warehouse heading if necessary.
     *
     C                   if        lstwhs <> gilwhs
     *
     C                   eval      whcode = gilwhs
     C                   eval      $pwhse = gilwhs
     C     whcode        chain     warehs
     C                   if        not %found(warehs)
     C                   eval      whdesc = *blanks
     C                   endif
     *
     C                   eval      $pwhs = whcode
     C                   move      gilwhs        work3a
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
     C                   eval      lstwhs = gilwhs
     C                   eval      pflag = *off
     *
     *    Get exceptions report override if any.
     C                   exsr      opnprt
     C                   endif
     *
     *  Print report heading if necessary.
     *
     C                   eval      prhdr1 = *off
     C                   if        pflag = *off  or
     C                             count >= linppg
     C                   eval      count = 0
     C                   write     head1
     C                   add       3             count
     C                   eval      pflag = *off
     C                   endif
     *
     *  Print route totals when route or route id changes.
     C                   if        gilrte <> lstrte
     C                             or gilrid <> lstrid
     C                   exsr      zrvldrte
     C                   if        rteerr = *on
     C                   exsr      zrprtrte
     C                   iter
     C                   endif
     *
     C                   eval      lstrte = gilrte
     C                   eval      lstrid = gilrid
     C                   endif
     *
     *  Add record to order header file. If an error occurs, assume
     *    it was caused by a duplicate record.
     *
     C                   eval      hedmsg = *blanks
     C                   if        *in49
     C                   eval      hedmsg = desc(1)
     C                   add       1             preoh
     C                   endif
     *
     *    Print order heading
     *
     C                   if        pflag = *off
     C                   write     head2
     C                   add       2             count
     C                   endif
     *
     C                   write     head3
     C                   add       2             count
     *
     C                   if        pflag = *off
     C                   write     head4
     C                   add       2             count
     C                   eval      pflag = *on
     C                   endif
416 A*
416 A*    Exception occurred, print on report.
416 A*
416 AC                   select
416 AC                   when      hedmsg > *blanks
416 A*
416 A*    Print exception report page headings.
416 AC                   if        *in92
416 AC                   write     head11                               92
416 AC                   write     head21
416 AC                   endif
416 AC                   write     head31
416 A*    Set on flag that customer heading printed already.
416 AC                   eval      prhdr1 = *on
416 A*
416 AC                   endsl
     *
     *    Initialize order subtotals
     *
     C                   eval      sublin = 0
     C                   eval      subq1 = 0
     C                   eval      subq2 = 0
     C                   eval      subq3 = 0
416 AC                   eval      subq11 = *zeros
416 AC                   eval      subq21 = *zeros
416 AC                   eval      subq31 = *zeros
     *
     *    Whip through all the download detail records
     *
     C                   eval      eofd = *off
416 AC                   eval      excpr1 = *off
     C     oidkey        setll     impfordd
     C                   dou       eofd = *on
     *
     C     oidkey        reade     impfordd                               78
     C                   if        *in78
     C                   eval      eofd = *on
     C                   goto      enddod
     C                   endif
     C                   eval      detmsg = *blanks
     C                   eval      good1 = 'N'
416bAC                   eval      good2 = 'N'
416aAC                   eval      mrgitm = *off
416aAC                   eval      stsmsg = *blanks
     *
     *       If item doesn't exist write error message.
     *
     C     itkey         chain     piritem                            76
     C                   if        *in76
     C                   eval      detmsg = desc(2)
     C                   add       1             noitem
     C                   eval      itdesc = *blanks
     C                   movel     '*****'       itdesc
     C                   else
     *       Check if breakdown qty is allowed using piritem file.
     *       Add rec if qty1, brk qty2 or brk qty3 has good qty.
     C                   exsr      zzbkdn
     *
     *       If qty1, brkdown qty2 or brkdown qty3 has good qty,
     *        add record to order detail file. If an error
     *        occurs, assume was caused by a duplicate record.
     *        Update route summary with detail information.
     *
     C                   if        good1 = 'Y'
416bAC                   exsr      zzxdck
416bAC                   if        good2 = 'Y'
     C                   exsr      fillod
500eA*
500eA*    Only update ORDDM if impfordm was sent.
500eAC                   if        miscupdate = '*YES'
500eAC                   exsr      fillom
500eAC                   endif
416aA*
416aA*    Record was updated in FILLOD.
416aAC                   if        skpwrt = *off
     C                   write     odrec                                49
500eA*
500eA*    Only add to ORDDM if impfordm was sent.
500eAC                   if        miscupdate = '*YES'
500eAC                   write     omrec
500eAC                   if        %error
500eAC                   endif
500eAC                   endif
     C                   if        *in49
     C                   eval      detmsg = desc(1)
     C                   add       1             preod
     C                   endif
416aAC                   endif
     C                   exsr      updsum
416bAC                   endif
     C                   endif
     *
     C                   endif
     *
     *       Print order detail and update subtotals
     *
     C                   exsr      zrhead
     C                   write     detail
     C                   add       1             count
416aA*
416aA*       Print order detail item merge info line.
416aA*
416aAC                   if        mrgrte = *on  and
416aAC                             mrgitm = *on
416aAC                   exsr      zrhead
416aAC                   write     detail2
416aAC                   add       1             count
416aAC                   endif
416aA*
     C                   add       1             sublin
     C                   add       oidq1         subq1
     C                   add       oidq2         subq2
     C                   add       oidq3         subq3
     *
     *       Delete detail record from download file
     *
PAKaA*
PAKaAC                   if        client = packers
PAKaA*       Leave order detail records for extracting p/o's.
PAKaAC                   else
PAKaA*
     C                   delete    oidrec
PAKaAC                   endif
PAKaA*
416 A*
416 A*       Exception occurred, print on report.
416 AC                   select
416 AC                   when      detmsg > *blanks
416 A*
416 A*    Turn on flag to indicate at least one exception printed.
416 A*    Print grand totals when complete.
416 AC                   eval      excprt = *on
416 A*    Turn on flag to indicate at least one exception printed.
416 A*    Print sub totals when complete.
416 AC                   eval      excpr1 = *on
416 A*
416 AC                   add       oidq1         subq11
416 AC                   add       oidq2         subq21
416 AC                   add       oidq3         subq31
416 A*
416 A*    Print exception report page headings.
416 AC                   if        *in92
416 AC                   write     head11                               92
416 AC                   write     head21
416 AC                   write     head31
416 AC                   write     head41
416 AC                   eval      prhdr1 = *on
416 AC                   endif
416 A*
416 A*    Print exception report Customer info and headings.
416 AC                   if        prhdr1 = *off
416 AC                   write     head31                               92
416 AC                   eval      prhdr1 = *on
416 AC                   endif
416 A*
416 A*    Print exception report page headings.
416 AC                   if        *in92
416 AC                   write     head11                               92
416 AC                   write     head21
416 AC                   write     head31
416 AC                   write     head41
416 AC                   endif
416 A*
416 AC                   write     detail1                              92
416 AC                   add       1             grlin1
416 A*
416 AC                   endsl
     *
     C     enddod        tag
     C                   enddo
     *
     *    Print order subtotals and update grand totals
     **                   EXSR ZRHEAD
     C                   write     subttl
     C                   add       3             count
     C                   add       1             grdord
     C                   add       sublin        grdlin
416 A*
416 A*    Print Order exception subtotals.
416 AC                   if        excpr1 = *on
416 AC                   add       1             grord1
416 AC                   if        *in92
416 AC                   write     head11                               92
416 AC                   write     head21
416 AC                   write     head31
416 AC                   write     head41
416 AC                   endif
416 AC                   write     subttl1                              92
416 AC                   endif
     *
     *  Delete header record from download file
     *
PAKaA*
PAKaAC                   if        client = packers
PAKaA*       Leave order header records for extracting p/o's.
PAKaAC                   else
PAKaA*
     C                   delete    oihrec
PAKaAC                   endif
PAKaA*
     *
     C     enddoh        tag
     C                   enddo
     *
     *  Print order grand totals
     *
     C                   if        pflag = *on
     C                   if        count >= linppg
     C                   write     head1
     C                   endif
     C                   write     grndttl
     C                   endif
416aA*
416aA*    Remove NEW Order Header if no items attached.
416aAC                   if        mrgord = *on
416aAC                   exsr      zzcko1
416aAC                   endif
416aA*
416aA*    Remove NEW Route Header if no orders attached.
416aAC                   if        mrgrte = *on
416aAC                   exsr      zzckr1
416aAC                   endif
416 A*
416 A*    Print exception grand totals.
416 AC                   if        excprt = *on
416 AC                   if        *in92
416 AC                   write     head11                               92
416 AC                   endif
416 AC                   write     grndttl1
416 AC                   endif
416 A*
PAKaA*
PAKaAC                   if        client = packers
PAKaA*
PAKaA*    Check if any orders need to be imported as purchase orders.
PAKaAC                   eval      $pimppo = import_po
PAKaA*
PAKaAC                   endif
PAKaA*
     *
     *  We are finished so get out
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
416aA*
416aA*  *INZSR  Initialization subroutine
416aA*
416aAC     *inzsr        begsr
500dA*
500dA* Get client id.
500dA*
500dAC                   call      @getcl
500dAC                   parm                    client           10
500dAC                   parm                    cliloc           10
510 A*
510 A* Open IMPFORDHM file.
510 AC                   if        opnimpordhm <> *on
510 AC                   open      impfordhm                            67
510 AC                   if        *in67 = *off
510 AC                   eval      opnimpordhm = *on
510 AC                   eval      mischdrupd = '*YES'
510 AC                   else
510 AC                   eval      mischdrupd = '*NO '
510 AC                   endif
510 AC                   endif
510 A*
510 A* Open ORDHM file if import file was sent.
510 AC                   if            opnordhm <> *on
510 AC                             and mischdrupd ='*YES'
510 AC                   open      ordhm                                67
510 AC                   if        *in67 = *off
510 AC                   eval      opnordhm   = *on
510 AC                   eval      mischdrupd = '*YES'
510 AC                   else
510 AC                   eval      mischdrupd = '*NO '
510 AC                   endif
510 AC                   endif
500eA*
500eA* Open IMPFORDM file.
500eAC                   if        opnimpordm <> *on
500eAC                   open      impfordm                             68
500eAC                   if        *in68 = *off
500eAC                   eval      opnimpordm = *on
500eAC                   eval      miscupdate = '*YES'
500eAC                   else
500eAC                   eval      miscupdate = '*NO '
500eAC                   endif
500eAC                   endif
500eA*
500eM* Open ORDDM file if import file was sent.
500eAC                   if            opnordm <> *on
500eAC                             and miscupdate ='*YES'
500eMC                   open      orddm                                68
500eAC                   if        *in68 = *off
500eAC                   eval      opnordm    = *on
500eAC                   eval      miscupdate = '*YES'
500eAC                   else
500eAC                   eval      miscupdate = '*NO '
500eAC                   endif
500eAC                   endif
PAK A*
PAK A* Open ORDDM file if import file was sent.
PAK AC                   if        client = packers
PAK AC                   if        not %open(custmisc)
PAK AC                   open      custmisc
PAK AC                   endif
PAK AC                   endif
520bA*
520bA* CROSSDK  Cross Dock - Full key
520bAC     cdkey         klist
520bAC                   kfld                    slwhse
520bAC                   kfld                    slwhdp
520bAC                   kfld                    sldisp
416bA*
416bA* IMPFORDH Download order header file - Partial key
416bAC     oihkey        klist
416bAC                   kfld                    $pwhse
416bAC                   kfld                    $ptype
510 A*
510 A* IMPFORDHM  Download order header misc - full key
510 aC     oihmkey       klist
510 AC                   kfld                    oihwhs
510 AC                   kfld                    oihord
500eA*
500eA* IMPFORDM  Download order detail misc - full key
500eaC     oimkey        klist
500eAC                   kfld                    oidwhs
500eAC                   kfld                    oidord
500eAC                   kfld                    oidseq
500eAC                   kfld                    oiditm
PAK A*
PAK A* CUSTMISC   BFC Dakota Customer Master - Misc. - Full Key
PAK AC     csmkey        klist
PAK AC                   kfld                    oihwhs
PAK AC                   kfld                    oihcus
416aA*
416aA* ORDH Order header file - Partial key
416aA*
416aAC     ohkey         klist
416aAC                   kfld                    $pwhse
416aAC                   kfld                    neword
416aA*
416aA* ORDH4 Order header file - Full key  (NEW Route)
416aA*
416aAC     oh3key        klist
416aAC                   kfld                    $pwhse
416aAC                   kfld                    newrte
416aA*
416aA* ORDH4 Order header file - Full key  (Open Route)
416aA*
416aAC     oh5key        klist
416aAC                   kfld                    $pwhse
416aAC                   kfld                    opnrte
416aAC                   kfld                    oihord
510 A*
510 A* ORDHM Order header misc. file - Full key
510 A*
510 AC     *like         define    hmord         kyord
510 AC     hmkey         klist
510 AC                   kfld                    $pwhse
510 AC                   kfld                    kyord
416aA*
416aA* ORDD Order detail file - Partial key
416aA*
416aAC     odkey         klist
416aAC                   kfld                    $pwhse
416aAC                   kfld                    neword
416aA*
416aA* ORDD1 Order detail file - Full key
416aA*
416aAC                   eval      kystat = 'O'
416aAC     od1key        klist
416aAC                   kfld                    $pwhse
416aAC                   kfld                    opnord
416aAC                   kfld                    kystat
416aAC                   kfld                    oidseq
416aAC                   kfld                    oiditm
416aAC     od2key        klist
416aAC                   kfld                    $pwhse
416aAC                   kfld                    neword
500eA*
500eA* ORDDM  Order detail misc. file - Full key
500eA*
500eAC     omkey         klist
500eAC                   kfld                    odwhse
500eAC                   kfld                    odord
500eAC                   kfld                    odseq
500eAC                   kfld                    oditem
416aA*
416aA* OPTIONS Options file - Full key
416aA*
416aAC     opkey         klist
416aAC                   kfld                    opwhse
416aAC                   kfld                    opcode
416bA*
416bA* PODTL1 PO DETAIL file
416bA*
416bAC     keypd1        klist
416bAC                   kfld                    $pwhse
416bAC                   kfld                    oidpo
416bAC                   kfld                    oiditm
416aA*
416aA* RTEHED1 - Route header file - Partial key
416aA*
416aAC     rh1key        klist
416aAC                   kfld                    $pwhse
416aAC                   kfld                    oihrte
416aA*
416aA* RTEHED1 - Route header file - Full key
416aAC     rh2key        klist
416aAC                   kfld                    $pwhse
416aAC                   kfld                    newrtc
416aAC                   kfld                    newrte
417aA*
417aA* RTEHED1 - Route header file - Full key
417aAC     rh3key        klist
417aAC                   kfld                    $pwhse
417aAC                   kfld                    lstrte
417aAC                   kfld                    lstrid
416bA*
416bA* SLOT1 file
416bAC     keysl1        klist
416bAC                   kfld                    $pwhse
416bAC                   kfld                    itwhdp
416bAC                   kfld                    kyaisl
416bA*
416bA* SLOT4 file
416bAC     keysl4        klist
416bAC                   kfld                    $pwhse
416bAC                   kfld                    itwhdp
416bAC                   kfld                    oiditm
416bAC                   kfld                    kydisp
520aA*
520aA* SLOT11 file
520aAC     keysl11       klist
520aAC                   kfld                    $pwhse
520aAC                   kfld                    kyaisl
416aA*
416aA*  Variables and constants.
416aA*
416aAC                   eval      forevr = *off
416aAC                   eval      mrgrte = *off
416aAC                   eval      mrgord = *off
416aAC                   eval      mrgitm = *off
416aAC                   eval      wrgsts = *off
416aAC                   eval      rcdlck = *off
416aAC                   eval      skpwrt = *off
416aA*
416bA*  Convert today's date into century format.
416bA*
416bAC                   eval      $cvcmd = '*CURCMD '
416bAC                   call      @cvtdt
416bAC                   parm                    $cvtdt
416bAC                   eval      today = $cvd8o
416bA*
416aAC                   endsr
416aA*----------------------------------------------------------------
     *
     *  FILLOD  Fill order detail fields.
     *
     C     fillod        begsr
416aAC                   eval      skpwrt = *off
416aA*
416aA*    Route & order at Open status. Check if item already on order.
416aA*    If yes, then compute difference between import qty's and order
416aA*    qty's. Then update order with import qty.
416aAC                   select
416aAC                   when      mrgrte = *on  and
416aAC                             mrgord = *on  and
416aAC                             wrgsts = *off
416aA*
416aAC                   eval      rcdlck = *on
416aAC                   exsr      zzgtod
416aAC                   eval      rcdlck = *off
416aA*
416aAC                   select
416aAC                   when      not *in75  and
416aAC                             oiditm = oditem
416aA*
416aA*    Calculate change in quantity to update RTESUM file.
416aAC                   eval      difqy1 = oidq1 - odqor1
416aAC                   eval      difqy2 = oidq2 - oidq2
416aAC                   eval      difqy3 = oidq3 - oidq3
416aA*
416aAC                   eval      odqor1 = oidq1
416aAC                   if        itflg1 = 'Y'
416aAC                   eval      odqor2 = oidq2
416aAC                   endif
416aAC                   if        itflg2 = 'Y'
416aAC                   eval      odqor3 = oidq3
416aAC                   endif
416aAC                   update    odrec1
416aA*    Load print field for report.
416aAC                   move      odord         prtord
416aAC                   move      sts03         stsmsg
416aAC                   eval      mrgitm = *on
416aAC                   eval      skpwrt = *on
416aAC                   goto      endlod
416aAC                   endsl
416aA*
416aAC                   endsl
     *
     *  Initialize record
     *
     C                   clear                   odrec
     *
     *  Move fields from download file to purchase order header fields
     *
     C                   eval      odwhse = oidwhs
416aA*
416aA*    Open route found, Open order not found or at wrong status.
416aA*    Create order under current Open route.
416aAC                   select
416aAC                   when      mrgrte = *on  and
416aAC                             mrgord = *off  and
416aAC                             wrgsts = *off  or
416aA*
416aAC                             mrgrte = *on  and
416aAC                             mrgord = *off  and
416aAC                             wrgsts = *on
416aAC                   eval      odord = neword
416aAC                   move      sts02         stsmsg
416aA*
416aA*    Open route found, Open order found.
416aA*    Add item to current Open order.
416aAC                   when      mrgrte = *on  and
416aAC                             mrgord = *on  and
416aAC                             wrgsts = *off
416aAC                   eval      odord = opnord
416aAC                   move      sts01         stsmsg
416aA*
416aAC                   other
     C                   eval      odord = ohord
416aAC                   endsl
416aA*    Load print field for report.
416aAC                   move      odord         prtord
416aA*
     C                   eval      odseq = oidseq
     C                   eval      oditem = oiditm
     C                   eval      odqor1 = oidq1
416aAC                   eval      difqy1 = oidq1
     C                   if        itflg1 = 'Y'
     C                   eval      odqor2 = oidq2
416aAC                   eval      difqy2 = oidq2
     C                   else
     C                   eval      odqor2 = 0
416aAC                   eval      difqy2 = 0
     C                   endif
     C                   if        itflg2 = 'Y'
     C                   eval      odqor3 = oidq3
416aAC                   eval      difqy3 = oidq3
     C                   else
     C                   eval      odqor3 = 0
416aAC                   eval      difqy3 = 0
     C                   endif
     C                   eval      odwh2 = oidwh2
     C                   eval      odor2 = oidor2
     C                   eval      odoitm = oidoit
     C                   eval      odspcl = oidspc
     C                   eval      odstat = 'O'
416aAC                   eval      mrgitm = *on
416aA*
416aAC     endlod        tag
     *
     C                   endsr
500eA*----------------------------------------------------------------
500eA*
500eA*  FILLOM  Fill order detail misc file fields.
500eA*
500eAC     filloM        begsr
500eA*
500eAC     oimkey        chain     impfordm
500eAC                   if        not %found(impfordm)
500fDC*                  clear                   oimrec
500fAC                   eval      oimdsc = ' '
500fAC                   eval      oimpds = 'N'
500fAC                   eval      oimrds = 'N'
500fAC                   eval      oimbox = 'N'
500fAC                   eval      oimexp = 'N'
500fAC                   eval      oimms1 = ' '
500fAC                   eval      oimms2 = ' '
500fAC                   eval      oimms3 = ' '
500fAC                   eval      oimms4 = ' '
500fAC                   eval      oimms5 = ' '
500eAC                   endif
500eA*
500eA*    Route & order at Open status. Check if item already on order.
500eA*    If yes, then compute difference between import qty's and order
500eA*    qty's. Then update order with import qty.
500eAC                   select
500eAC                   when      mrgrte = *on  and
500eAC                             mrgord = *on  and
500eAC                             wrgsts = *off
500eA*
500eAC                   eval      rcdlck = *on
500eAC                   exsr      zzgtom
500eAC                   eval      rcdlck = *off
500eA*
500eAC                   select
500eAC                   when      %found(orddm) and
500eAC                             oiditm = oditem
500eA*
PAKbAC                   select
PAKbAC                   when      client = packers
PAKbAC                   eval      omodsc = ' '
PAKbAC                   other
PAKbA*
500eAC                   eval      omodsc = oimdsc
PAKbAC                   endsl
PAKbA*
500eAC                   eval      ompdsc = oimpds
500eAC                   eval      omrdsc = oimrds
500eAC                   eval      omcbox = oimbox
500eAC                   eval      omcexp = oimexp
PAKbA*
PAKbAC                   select
PAKbAC                   when      client = packers
PAKbAC                   eval      ommsc1 = oimdsc
PAKbAC                   other
PAKbA*
500eAC                   eval      ommsc1 = oimms1
PAKbAC                   endsl
PAKbA*
500eAC                   eval      ommsc2 = oimms2
500eAC                   eval      ommsc3 = oimms3
500eAC                   eval      ommsc4 = oimms4
500eAC                   eval      ommsc5 = oimms5
500eAC                   update    omrec
500eA*
500eAC                   goto      endlodm
500eAC                   endsl
500eA*
500eAC                   endsl
500eA*
500eA*  Initialize record
500eA*
500eAC                   clear                   omrec
500eA*
500eA*  Move fields from download file to order detail misc file fields.
500eA*
500eAC                   eval      omwhse = oidwhs
500eA*
500eA*    Open route found, Open order not found or at wrong status.
500eA*    Create order under current Open route.
500eAC                   select
500eAC                   when      mrgrte = *on  and
500eAC                             mrgord = *off  and
500eAC                             wrgsts = *off  or
500eA*
500eAC                             mrgrte = *on  and
500eAC                             mrgord = *off  and
500eAC                             wrgsts = *on
500eAC                   eval      omord = neword
500eA*
500eA*    Open route found, Open order found.
500eA*    Add item to current Open order.
500eAC                   when      mrgrte = *on  and
500eAC                             mrgord = *on  and
500eAC                             wrgsts = *off
500eAC                   eval      omord = opnord
500eA*
500eAC                   other
500eAC                   eval      omord = ohord
500eAC                   endsl
500eA*
500eAC                   eval      omseq  = oidseq
500eAC                   eval      omitem = oiditm
500eAC                   eval      omodsc = oimdsc
500eAC                   eval      ompdsc = oimpds
500eAC                   eval      omrdsc = oimrds
500eAC                   eval      omcbox = oimbox
500eAC                   eval      omcexp = oimexp
500eAC                   eval      ommsc1 = oimms1
500eAC                   eval      ommsc2 = oimms2
500eAC                   eval      ommsc3 = oimms3
500eAC                   eval      ommsc4 = oimms4
500eAC                   eval      ommsc5 = oimms5
500eA*
500eAC     endlodm       tag
500eA*
500eAC                   endsr
     *----------------------------------------------------------------
     *
     *  FILLOH   Fill order header fields.
     *
     C     filloh        begsr
     *
     *  Initialize record
     *
     C                   clear                   ohrec
     *
     *  Move fields from download file to purchase order header fields
     *
     C                   eval      ohwhse = oihwhs
     C                   call      'PIRORD#'
     C                   parm      ohwhse        $owhse            3 0
     C     ohord         parm      0             $oord             7 0
416aAC                   eval      neword = ohord
     C                   eval      ohtype = oihtyp
     C                   eval      ohcord = oihord
     C                   eval      ohcpo = oihcpo
     C                   eval      ohcust = oihcus
     C                   eval      ohcnam = oihcnm
     C                   eval      ohcad1 = oihca1
     C                   eval      ohcad2 = oihca2
     C                   eval      ohccty = oihcct
     C                   eval      ohcst = oihcst
     C                   eval      ohczip = oihczp
416aA*
416aA*    Open route found, Open order NOT found.
416aA*    Add Order to current Open Route.
416aAC                   select
416aAC                   when      mrgrte = *on  and
416aAC                             mrgord = *off  and
416aAC                             wrgsts = *off
416aAC                   eval      ohrte = opnrte
416aA*
416aAC                   other
     C                   eval      ohrte = rhrtid
416aAC                   endsl
416aA*    Load print field for report.
416aAC                   eval      prtrte = ohrte
     C                   eval      ohstop = oihstp
     **                   MOVE OIHTRK    OHTRUK
     C                   eval      ohtruk = $ptruk
     C                   eval      ohmisc = oihmsc
     C                   eval      ohstat = 'O'
     C                   eval      ohsdte = impdte
     C                   eval      ohstim = imptim
     *
     C                   endsr
510 A*----------------------------------------------------------------
510 A*
510 A*  FILLHM  Fill order header misc file fields.
510 A*
510 AC     fillHM        begsr
510 A*
510 AC     oihmkey       chain     impfordhm
510 AC                   if        not %found(impfordhm)
510 AC                   eval      ohmms1 = ' '
510 AC                   eval      ohmms2 = ' '
510 AC                   eval      ohmms3 = ' '
510 AC                   eval      ohmms4 = ' '
510 AC                   eval      ohmms5 = ' '
510 AC                   endif
510 A*
PAKaAC                   if        client = packers
PAKaA*
PAKaA*      This order needs to be imported as a purchase order.
PAKaAC                   if        %subst(ohmms1:23:4) = 'ZPLF'
PAKcAC                             and (oihwhs = 200 or oihwhs = 300 or
PAKcAC                                  oihwhs = 310)
PAKaAC                   eval      import_po = '*YES'
PAKaAC                   endif
PAKaA*
PAKaAC                   endif
PAKaA*
510 AC                   select
510 A*    Open route found, Open order found.
510 A*    Retrieve Open Order Header Misc. file
510 AC                   when      mrgrte = *on  and
510 AC                             mrgord = *on  and
510 AC                             wrgsts = *off
510 AC                   eval      kyord = opnord
510 A*
510 AC                   other
510 AC                   eval      kyord = neword
510 AC                   endsl
510 A*
510 AC                   eval      rcdlck = *on
510 AC                   exsr      zzgethm
510 AC                   eval      rcdlck = *off
510 A*
510 AC                   select
510 AC                   when      %found(ordhm)
510 A*
510 AC                   select
510 A*    Open route found, Open order found.
510 A*    Leave route ID untouched.
510 AC                   when      mrgrte = *on  and
510 AC                             mrgord = *on  and
510 AC                             wrgsts = *off
510 A*
510 A*    Open route found, Open order NOT found.
510 A*    Add Order to current Open Route.
510 AC                   when      mrgrte = *on  and
510 AC                             mrgord = *off  and
510 AC                             wrgsts = *off
510 AC                   eval      hmrtid = opnrte
510 AC                   other
510 AC                   eval      hmrtid = rhrtid
510 AC                   endsl
510 A*
510 AC                   eval      hmmsc1 = ohmms1
510 AC                   eval      hmmsc2 = ohmms2
510 AC                   eval      hmmsc3 = ohmms3
510 AC                   eval      hmmsc4 = ohmms4
510 AC                   eval      hmmsc5 = ohmms5
510 AC                   update    hmrec
510 A*
510 AC                   goto      endlodhm
510 A*
510 AC                   endsl
510 A*
510 A*  Initialize record
510 A*
510 AC                   clear                   hmrec
510 A*
510 A*  Move fields from download file to order detail misc file fields.
510 A*
510 AC                   eval      hmwhse = oihwhs
510 AC                   eval      hmord = neword
510 AC                   select
510 A*
510 A*    Open route found, Open order NOT found.
510 A*    Add Order to current Open Route.
510 AC                   when      mrgrte = *on  and
510 AC                             mrgord = *off  and
510 AC                             wrgsts = *off
510 AC                   eval      hmrtid = newrte
510 A*
510 AC                   other
510 AC                   eval      hmrtid = rhrtid
510 AC                   endsl
510 A*
510 AC                   eval      hmmsc1 = ohmms1
510 AC                   eval      hmmsc2 = ohmms2
510 AC                   eval      hmmsc3 = ohmms3
510 AC                   eval      hmmsc4 = ohmms4
510 AC                   eval      hmmsc5 = ohmms5
510 A*
510 AC     endlodhm      tag
510 A*
510 AC                   endsr
     *----------------------------------------------------------------
     *
     *  FILLRH   Fill route header fields.
     *
     C     fillrh        begsr
     *
     *  Initialize record
     *
     C                   clear                   rhrec
     *
     *  Update fields.
     *
     C                   eval      rhwhse = oihwhs
     C                   call      'PIRRTE#'
     C                   parm      rhwhse        $rwhse            3 0
     C                   parm      ' '           rhrtid
417aAC                   eval      lstrid = rhrtid
416dD**                   MOVE RHRTID    $PRTID
416dAC                   add       1             rtcnt
416dAC                   select
416dAC                   when      rtcnt = 1
416dAC                   eval      $prt01 = rhrtid
416dAC                   when      rtcnt = 2
416dAC                   eval      $prt02 = rhrtid
416dAC                   when      rtcnt = 3
416dAC                   eval      $prt03 = rhrtid
416dAC                   when      rtcnt = 4
416dAC                   eval      $prt04 = rhrtid
416dAC                   when      rtcnt = 5
416dAC                   eval      $prt05 = rhrtid
416dAC                   when      rtcnt = 6
416dAC                   eval      $prt06 = rhrtid
416dAC                   when      rtcnt = 7
416dAC                   eval      $prt07 = rhrtid
416dAC                   when      rtcnt = 8
416dAC                   eval      $prt08 = rhrtid
416dAC                   when      rtcnt = 9
416dAC                   eval      $prt09 = rhrtid
416dAC                   when      rtcnt = 10
416dAC                   eval      $prt10 = rhrtid
416dAC                   endsl
416aAC                   eval      newrte = rhrtid
414 AC                   if        $ptype = 'W'  and
417 D*R         RHRTE     ANDEQ*BLANKS
417 MC                             oihrte = *blanks
414 AC                   eval      rhrte = rhrtid
414 AC                   else
     C                   eval      rhrte = oihrte
414 AC                   endif
416aAC                   eval      newrtc = oihrte
     C                   eval      rhtype = oihtyp
414 AC                   if        $ptype = 'W'  and
416eMC                             oihtrk = *blanks
416eD**         RHTRUK    ANDEQ*BLANKS
414 AC                   eval      rhtruk = *blanks
414 AC                   movel     'WILLCALL'    rhtruk
414 AC                   else
     C                   eval      rhtruk = oihtrk
414 AC                   endif
414 D**                   MOVE OIHTRK    $PTRUK
414 MC                   eval      $ptruk = rhtruk
     C                   eval      rhstat = *on
     C                   eval      rhstsd = impdte
     C                   eval      rhstst = imptim
     C                   eval      rhimpd = impdte
     C                   eval      rhimpt = imptim
     C                   eval      rhrptd = impdte
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  OPNPRT  Open printer file.
     *
     C     opnprt        begsr
     *
     *   Get device and form type for department.
     *
     C                   call      'GETRPT'
     C                   parm      '*DEVFORM'    $cmd              8
     C                   parm      'GT1551PR'    $lrpt            10
     C                   parm      lstwhs        $whse             3 0
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
     *   Open printer file for department.
     *
     C                   if        opened <> *on
     *
     *      If printer already open then close it.
     *
     C                   if        opened = *on
     C                   close     GT1551pr
     C                   close     GT155pr
     C                   endif
     *
     *      Override printer file.
     *
     *          OVRPRTF FILE(GT1551PR) OUTQ(*DEV) DEV($dev)
     *                  FORMTYPE($form)
     *        NOTE: Ending array positions for $DEV 39, $FORM 60 are one
     *              greater than standard code. This is due to the
     *              extra character in the printer file name.
     *
     C                   movea     ovrprt(1)     a80
     C                   movea     $dev          a80(39)
     C                   movea     $form         a80(60)
     C                   movea     a80           qcmd
     *
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
     *
     *   Get device and form type for main report.
     *
     C                   call      'GETRPT'
     C                   parm      '*DEVFORM'    $cmd
     C                   parm      'GT1551PR'    $lrpt
     C                   parm      lstwhs        $whse
     C                   parm      *blanks       $styp
     C                   parm      *blanks       $whdp
     C                   parm                    $desc
     C                   parm                    $dev
     C                   parm                    $form
     C                   if        $dev = *blanks
     C                   movel     '*JOB'        $dev
     C                   endif
     C                   if        $form = *blanks
     C                   movel     '*STD'        $form
     C                   endif
     *
     *      Override printer file.
     *
     *          OVRPRTF FILE(GT155PR) OUTQ(*DEV) DEV($dev)
     *                  FORMTYPE($form)
     *
     C                   movea     ovrprt(2)     a80
     C                   movea     $dev          a80(38)
     C                   movea     $form         a80(59)
     C                   movea     a80           qcmd
     *
     C                   call      'QCMDEXC'
     C                   parm                    qcmd
     C                   parm      80            qlen
     *
     *      Open printer file.
     *
     C                   open      gt1551pr
     C                   open      gt155pr
     C                   eval      opened = *on
     *
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZRVLDRTE    Validate Route being imported.
     *
     C     zrvldrte      begsr
     *
     C                   eval      rteerr = *off
     *
     C     keyrh         chain     rtehed
     C                   select
     C                   when      not %found(rtehed)
     C                             or rhstat > '6'
     C                   eval      rteerr = *on
     C                   endsl
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZRHEAD   Print report headings.
     *
     C     zrhead        begsr
     *
     C                   if        count >= linppg
     C                   seton                                        81
     C                   eval      count = 0
     C                   write     head1
     C                   add       3             count
     C                   write     head2
     C                   add       2             count
     C                   write     head3
     C                   add       2             count
     C                   write     head4
     C                   add       2             count
     C                   setoff                                       81
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile Time Tables
     *
**
*Route not on file*
*Invalid Transaction*
**
Import Picked Route Goal Times
**   OVRPRTF statment
OVRPRTF FILE(GT155PR)           OUTQ(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
OVRPRTF FILE(GT1551PR)          OUTQ(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
