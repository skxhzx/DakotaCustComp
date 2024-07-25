500eA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washingont Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OI315     Import FTP orders Ver 6 - Post
     *  14 October 2009
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    10/14/09  MLB  5.20
     *      - Created.
     *
530 A*    11/20/09  MLB  5.30
     *      - Enh: Revised OI2551PR to add format DETAIL 22 which
     *        will print item pack/size on exception report.
530aA*    12/07/09  MLB  5.30a
     *      - Enh: Revised tmpcub, tmpwgt to reference rsordc, rsordw
     *        to prevent field overflow errors on cube, wgt.
530bA*    04/07/10  MLB  5.30b
     *      - Fix: Change to divide ITSWGT by brk qty to calculate wgt
     *        for type 'S' item.
     *
640 A*    07/18/11  MLB  6.40
     *      - Fix: Revised varianble SUBLIN to be 7,0 from 3,0. Orders
     *        greater than 999 lines causes RNQ0103 Variable too small
     *        to hold result error.
710a *    11/17/17  RTR  7.10a
     *      - Enh: Added new stop/drop fields in RTESTP to fillxr.
     *
740 A*    08/26/20  MLB  7.40
     *      - Fix: Revised program to populate RTSSD with contents of
     *        RTSST5. Correction to 7.10a mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Packer's Provision
     *
PAK A*    10/14/09  MLB  PAK
     *      - Chain to CUSTMISC and if customer found, set *SP in
     *        OIHMSC in position 7-9.
PAKaA*    10/15/09  MLB  PAKa
     *      - If OIHRTE is blank, set OIHTYP = W=Willcall.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Eastland Foods
     *
EFCa *    05/24/13  RTR  EFCa
     *      - Enh: Allow zero qty detail records for Eastland.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    This program assumes that there is only one route for one
     *    warehouse OR only one order in the member.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  61        - Special order (Customer # > 0)
     *  67        - Open of IMPFORDHM6 or ORDDHM failed.
     *  68        - Open of IMPFORDDM6 or ORDDM failed.
     *  78        - EOF for IMPFORDD6
     *  79        - EOF for IMPFORDH6
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fimpfordh6 uf   e           k disk
     Fimpfordhm6uf   e           k disk    usropn
     Fimpfordd6 uf   e           k disk
     Fimpforddm6uf   e           k disk    usropn
     Fcustmisc  if   e           k disk    usropn
     Fwarehs    if   e           k disk
     Fpiritem   if   e           k disk
     Fslot1     uf a e           k disk
     Fslot4     uf   e           k disk
     F                                     rename(slrec:slrec4)
     Fslot11    uf   e           k disk
     F                                     rename(slrec:slrec11)
     Frtesum    uf a e           k disk
     Fordh4     if   e           k disk
     F                                     rename(ohrec:ohrec4)
     Fordd1     uf   e           k disk
     F                                     rename(odrec:odrec1)
     Foptions   if   e           k disk
     Fpodtl1    if   e           k disk
     Frtehed1   uf   e           k disk
     F                                     rename(rhrec:rhrec1)
     Frtehed    o  a e           k disk
     Fordh      uf a e           k disk
     Fordhm     uf a e           k disk    usropn
     F*crossdk   o  a e           k disk
     Fcrossdk   uf a e           k disk
     Fordd      o  a e           k disk
     Forddm     uf a e           k disk    usropn
     Frtestp    o  a e           k disk
     Foi315pr   o    e             printer oflind(*in91)
     F                                     usropn
     Foi3151pr  o    e             printer oflind(*in92)
     F                                     usropn
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             20    dim(6) ctdata perrcd(1)
     D rdsc            s             50    dim(1) ctdata perrcd(1)
     D a80             s              1    dim(80)
     D ovrprt          s             80    dim(2) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
PAK A /COPY QCOPYSRC,ID#PACKERS
EFCaA /copy qcopysrc,id#eastlan
     *
     *----------------------------------------------------------------
     *  *GENPICK -  General picking options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPERPT  -  Print exception (short) error report (Y,N).
     *    OPELBL  -  Print exception (short) labels (Y,N)
     *    OPRFWC  -  Using RF will call (Y,N).
     *    OPNRSC  -  Number of pallet sections (1-9).
     *    OPHPWC  -  Host pick Will Call (Y/N).
     *    OPMRGA  -  Merge Add-on order(s) with Open Routes.
     *    OPPLSQ  -  Pallet number sequence. 1=Unload seq, 2=Load seq
     *
     * Data structure
     *
     D opdata          ds
     D  operpt                 1      1
     D  opelbl                 2      2
     D  oprfwc                 3      3
     D  opnrsc                 4      4  0
     D  ophpwc                 5      5
     D  opmrga                 6      6
     D  opplsq                 7      7
     D  optend               117    117
     *----------------------------------------------------------------
     *  Re-definition field(s)
     *
     D                 ds
     D  oihmec                13     15
     D  oihmsc                 1     20
     D                 ds
     D  ohmemc                13     15
     D  ohmisc                 1     20
     *----------------------------------------------------------------
     *  Constants
     *
     D exchdr          c                   const('- Exceptions')
     D sts01           c                   const('** Added to existing-
     D                                      Open Order. ')
     D sts02           c                   const('** New Order Added t-
     D                                     o Open Route.')
     D sts03           c                   const('** Upd''d on existin-
     D                                     g Open Order.')
     *
     *----------------------------------------------------------------
     *  Working variables
     *
     D $pwhse          s              3  0
     D count           s              3  0
     D difqy1          s                   like(odqor1)
     D difqy2          s                   like(odqor2)
     D difqy3          s                   like(odqor3)
     D dummy           s              3  0
     D eofd            s              1
     D eofh            s              1
     D excprt          s              1
     D excpr1          s              1
     D forevr          s              1
     D good1           s              1
     D good2           s              1
     D impdte          s              8  0
     D imptim          s              6  0
     D kyaisl          s                   like(slaisl)
     D kydisp          s                   like(sldisp)
     D kyrtid          s                   like(rhrtid)
     D kystat          s                   like(odstat)
     D kywhdp          s                   like(itwhdp)
     D len             s              1  0
     D linppg          s              3  0
     D lstrid          s                   like(oihrte)
     D lstrte          s                   like(oihrte)
     D lstwhs          s              3  0
     D mischdrupd      s              4    inz('*NO ')
     D miscupdate      s              4    inz('*NO ')
     D mrgitm          s              1
     D mrgord          s              1
     D mrgrte          s              1
     D neword          s                   like(ohord)
     D newrtc          s                   like(rhrte)
     D newrte          s                   like(rhrtid)
     D opened          s              1
     D opnorc          s                   like(ohord)
     D opnord          s                   like(ohord)
     D opnrtc          s                   like(rhrte)
     D opnrte          s                   like(rhrtid)
     D opnimpordhm     s              1    inz('0')
     D opnordhm        s              1    inz('0')
     D opnimporddm     s              1    inz('0')
     D opnorddm        s              1    inz('0')
     D pflag           s              1
     D pos             s              1  0
     D prhdr1          s              1
     D rcdlck          s              1
     D rtcnt           s              3  0
     D skpwrt          s              1
640 DD*sublin          s              3  0
640 MD sublin          s              7  0
     D subq1           s              7  0
     D subq2           s              7  0
     D subq3           s              7  0
530aDD*tmpcub          s                   like(itcube)
530aMD tmpcub          s                   like(rsordc)
     D tmploc          s              3  0
530aDD*tmpwgt          s                   like(itswgt)
530aMD tmpwgt          s                   like(rsordw)
     D today           s              8  0
     D work3a          s              3
     D wrgsts          s              1
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
     *      $PTYPE  Order types to process.
     *              ' ' - Normal
     *              'T' - Transfer
     *              'W' - Will Call
     *              'S' - Single
     *
     *    Returned Parameters
     *      $PWHS   Warehouse to process.
     *      $PTRUK  Truck code.
     *      $PRT01  Route id assigned to will call order.
     *      $PRT02  Route id assigned to will call order.
     *      $PRT03  Route id assigned to will call order.
     *      $PRT04  Route id assigned to will call order.
     *      $PRT05  Route id assigned to will call order.
     *      $PRT06  Route id assigned to will call order.
     *      $PRT07  Route id assigned to will call order.
     *      $PRT08  Route id assigned to will call order.
     *      $PRT09  Route id assigned to will call order.
     *      $PRT10  Route id assigned to will call order.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $ptype            1
     C                   parm                    $pwhs            15 5
     C                   parm                    $ptruk           10
     C                   parm                    $prt01            5
     C                   parm                    $prt02            5
     C                   parm                    $prt03            5
     C                   parm                    $prt04            5
     C                   parm                    $prt05            5
     C                   parm                    $prt06            5
     C                   parm                    $prt07            5
     C                   parm                    $prt08            5
     C                   parm                    $prt09            5
     C                   parm                    $prt10            5
     C                   parm                    $pimppo           4
     *----------------------------------------------------------------
     * Key definitions
     *
     * Download order detail file - Partial key
     *
     C     oidkey        klist
     C                   kfld                    oihwhs
     C                   kfld                    oihdiv
     C                   kfld                    oihord
     *
     * Item file
     *
     C     itkey         klist
     C                   kfld                    oidwhs
     C                   kfld                    oiditm
     *
     * Route summary file
     *
     C     keyrs         klist
     C                   kfld                    rhwhse
     C                   kfld                    kyrtid
     C                   kfld                    kywhdp
     *----------------------------------------------------------------
     * Main line
     *
     * Initialize route id's
     *
     C                   eval      $prt01 = *blanks
     C                   eval      $prt02 = *blanks
     C                   eval      $prt03 = *blanks
     C                   eval      $prt04 = *blanks
     C                   eval      $prt05 = *blanks
     C                   eval      $prt06 = *blanks
     C                   eval      $prt07 = *blanks
     C                   eval      $prt08 = *blanks
     C                   eval      $prt09 = *blanks
     C                   eval      $prt10 = *blanks
     C                   eval      rtcnt = 0
     *
     * Get import date/time.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      impdte = $cvd8o
     C                   time                    imptim
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
     C                   eval      noitem = 0
     C                   eval      badbrk = 0
     *
     * Whip through all the download header records
     *
     C                   eval      lstrte = '@@@@@'
     C                   eval      lstrid = '@@@@@'
     *
     C                   eval      pflag = *off
     C                   eval      eofh = *off
     C                   eval      linppg = 55
     C                   eval      count = 0
     C                   eval      lstwhs = -(1)
     *
     C                   dou       eofh = *on
     C                   exsr      updrte
     *
     C                   read      impfordh6                              79
     C                   if        *in79
     C                   eval      eofh = *on
     *
     *  When route changes, resquence stops in RTESTP file.
     C                   if        lstrte <> '@@@@@'
     C                   exsr      reseqstp
     C                   endif
     *
     C                   goto      enddoh
     C                   endif
     *
PAK AC                   if        client = packers
PAK A*
PAKaA*      If route is blank, order sent is Will-Call order.
PAKaAC                   if        oihrte = ' '
PAKaAC                   eval      oihtyp = 'W'
PAKaAC                   endif
PAK A*
PAK A*      See if customer is in Customer Misc file.
PAK AC     csmkey        chain     custmisc
PAK AC                   if        %found(custmisc)
PAK AC                   Eval      oihmsc = %Replace('*SP': oihmsc:7:3)
PAK AC                   endif
PAK A*
PAK AC                   endif
     *
     *  Create warehouse heading if necessary.
     *
     C                   if        lstwhs <> oihwhs
     *
     C                   eval      whcode = oihwhs
     C                   eval      $pwhse = oihwhs
     C     whcode        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     * Delete all status 'Z' XDK slots.
     *
     C                   exsr      zzzdelxdk
     *
     *    Retrieve General Pick options for warehouse.
     *    This applies to only Regular orders.
     *
     C                   select
     C                   when      $ptype = ' '
     C                   eval      opwhse = oihwhs
     C                   eval      opcode = '*GENPICK'
     C     opkey         chain     options                            7978
     C                   if        *in79
     C                   eval      opmrga = 'N'
     C                   endif
     *
     *    Force Allow Merge orders to Yes for 'S' orders.
     *
     C                   when      $ptype = 'S'
     C                   eval      opmrga = 'Y'
     *
     *    All other order types, force Allow Merge orders to No
     *
     C                   other
     C                   eval      opmrga = 'N'
     C                   endsl
     *
     C                   eval      $pwhs = whcode
     C                   move      oihwhs        work3a
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
     C                   eval      lstwhs = oihwhs
     C                   eval      pflag = *off
     *    Get exceptions report override if any.
     C                   exsr      opnprt
     C                   endif
     *
     *    Print report heading if necessary.
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
     *  Add record to route header file when route changes.
     *     or when processing 'S' orders.
     *
     C                   if        oihrte <> lstrte
     *
     C                   eval      mrgrte = *off
     C                   eval      newrte = *blanks
     C                   eval      newrtc = *blanks
     *
     *  Merge order(s) into Open routes allowed.
     *  Check if Route still at Open status.
     *
     C                   if        opmrga = 'Y'  and
     C                             $ptype = ' '
     C                   exsr      zzckr1
     C                   exsr      zzckrt
     C                   endif
520aA*
520aA*  When route changes, resquence stops in RTESTP file.
520aAC                   if        lstrte <> '@@@@@'
520aAC                   exsr      reseqstp
520aAC                   endif
     *
     C                   exsr      fillrh
     C                   write     rhrec                                49
     C                   eval      lstrte = oihrte
     C                   endif
     *
     *    Add record to order header file. If an error occurs, assume
     *    it was caused by a duplicate record.
     *
     C                   eval      hedmsg = *blanks
     *
     *    Route allows Add-on orders to be merged with existing Open orders.
     *    Check if order header still at Open status.
     *
     C                   eval      mrgord = *off
     C                   eval      wrgsts = *off
     C                   eval      opnord = *zeros
     C                   eval      opnorc = *zeros
     C                   if        mrgrte = *on
     C                   exsr      zzcko1
     C                   exsr      zzckor
     C                   endif
     *
     C                   exsr      filloh
     *
     *    Only update ORDHM if impfordhm6 was sent.
     C                   if        mischdrupd = '*YES'
     C                   exsr      fillhm
     C                   endif
     *
     C                   write     ohrec                                49
520aA*
520aA*    Fill Route Extended Stop file
520aAC                   exsr      fillxr
520aAC                   write (e) rtsrec
520aAC                   if        %error
520aAC                   endif
520aA*
     *
     *    Only add to ORDDM if impforddm was sent.
     C                   if        mischdrupd = '*YES'
     C                             and %found(impfordhm6)
     C                   write     hmrec
     C                   if        %error
     C                   endif
     C                   endif
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
     *
     *    Exception occurred, print on report.
     *
     C                   select
     C                   when      hedmsg > *blanks
     *
     *    Print exception report page headings.
     C                   if        *in92
     C                   write     head11                               92
     C                   write     head21
     C                   endif
     C                   write     head31
     *    Set on flag that customer heading printed already.
     C                   eval      prhdr1 = *on
     *
     C                   endsl
     *
     *    Initialize order subtotals
     *
     C                   eval      sublin = 0
     C                   eval      subq1 = 0
     C                   eval      subq2 = 0
     C                   eval      subq3 = 0
     C                   eval      subq11 = *zeros
     C                   eval      subq21 = *zeros
     C                   eval      subq31 = *zeros
     *
     *    Whip through all the download detail records
     *
     C                   eval      eofd = *off
     C                   eval      excpr1 = *off
     C     oidkey        setll     impfordd6
     C                   dou       eofd = *on
     *
     C     oidkey        reade     impfordd6                              78
     C                   if        *in78
     C                   eval      eofd = *on
     C                   goto      enddod
     C                   endif
     C                   eval      detmsg = *blanks
     C                   eval      good1 = 'N'
     C                   eval      good2 = 'N'
     C                   eval      mrgitm = *off
     C                   eval      stsmsg = *blanks
     *
     *       If item doesn't exist write error message.
     *
     C     itkey         chain     piritem                            76
     C                   if        *in76
     C                   eval      detmsg = desc(2)
     C                   add       1             noitem
     C                   eval      itdesc = *blanks
530 AC                   eval      itpdsc = *blanks
     C                   movel     '*****'       itdesc
     C                   else
     *       Check if breakdown qty is allowed using piritem file.
     *       Add rec if qty1, brk qty2 or brk qty3 has good qty.
     C                   exsr      zzbkdn
     *       For Eastland, write detail no matter what.
EFCaAC                   if        client = eastland
EFCaAC                   eval      good1 = 'Y'
EFCaAC                   endif
     *
     *       If qty1, brkdown qty2 or brkdown qty3 has good qty,
     *        add record to order detail file. If an error
     *        occurs, assume was caused by a duplicate record.
     *        Update route summary with detail information.
     *
     C                   if        good1 = 'Y'
     C                   exsr      zzxdck
     C                   if        good2 = 'Y'
     C                   exsr      fillod
     *
     *    Only update ORDDM if impforddm was sent.
     C                   if        miscupdate = '*YES'
     C                   exsr      fillom
     C                   endif
     *
     *    Record was updated in FILLOD.
     C                   if        skpwrt = *off
     C                   write     odrec                                49
     *
     *    Only add to ORDDM if impforddm was sent.
     C                   if        miscupdate = '*YES'
     C                   write     omrec
     C                   if        %error
     C                   endif
     C                   endif
     C                   if        *in49
     C                   eval      detmsg = desc(1)
     C                   add       1             preod
     C                   endif
     C                   endif
     C                   exsr      updsum
     C                   endif
     C                   endif
     *
     C                   endif
     *
     *       Print order detail and update subtotals
     *
     C                   exsr      zrhead
     C                   write     detail
     C                   add       1             count
     *
     *       Print order detail item merge info line.
     *
     C                   if        mrgrte = *on  and
     C                             mrgitm = *on
     C                   exsr      zrhead
     C                   write     detail2
     C                   add       1             count
     C                   endif
     *
     C                   add       1             sublin
     C                   add       oidq1         subq1
     C                   add       oidq2         subq2
     C                   add       oidq3         subq3
     *
     *       Delete detail record from download file
     *
     *
     C                   if        client = packers
     *       Leave order detail records for extracting p/o's.
     C                   else
     *
     C                   delete    oidrec
     C                   endif
     *
     *
     *       Exception occurred, print on report.
     C                   select
     C                   when      detmsg > *blanks
     *
     *    Turn on flag to indicate at least one exception printed.
     *    Print grand totals when complete.
     C                   eval      excprt = *on
     *    Turn on flag to indicate at least one exception printed.
     *    Print sub totals when complete.
     C                   eval      excpr1 = *on
     *
     C                   add       oidq1         subq11
     C                   add       oidq2         subq21
     C                   add       oidq3         subq31
     *
     *    Print exception report page headings.
     C                   if        *in92
     C                   write     head11                               92
     C                   write     head21
     C                   write     head31
     C                   write     head41
     C                   eval      prhdr1 = *on
     C                   endif
     *
     *    Print exception report Customer info and headings.
     C                   if        prhdr1 = *off
     C                   write     head31                               92
     C                   eval      prhdr1 = *on
     C                   endif
     *
     *    Print exception report page headings.
     C                   if        *in92
     C                   write     head11                               92
     C                   write     head21
     C                   write     head31
     C                   write     head41
     C                   endif
     *
     C                   write     detail1                              92
     C                   add       1             grlin1
530 A*
530 A*    Print exception report page headings.
530 AC                   if        itpdsc > ' '
530 A*
530 AC                   if        *in92
530 AC                   write     head11                               92
530 AC                   write     head21
530 AC                   write     head31
530 AC                   write     head41
530 AC                   endif
530 AC                   write     detail22                             92
530 AC                   add       1             grlin1
530 A*
530 AC                   endif
     *
     C                   endsl
     *
     C     enddod        tag
     C                   enddo
     *
     *    Print order subtotals and update grand totals
     *
     C                   write     subttl
     C                   add       3             count
     C                   add       1             grdord
     C                   add       sublin        grdlin
     *
     *    Print Order exception subtotals.
     C                   if        excpr1 = *on
     C                   add       1             grord1
     C                   if        *in92
     C                   write     head11                               92
     C                   write     head21
     C                   write     head31
     C                   write     head41
     C                   endif
     C                   write     subttl1                              92
     C                   endif
     *
     *  Delete header record from download file
     *
     *
     C                   if        client = packers
     *       Leave order header records for extracting p/o's.
     C                   else
     *
     C                   delete    oihrec
     C                   endif
     *
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
     *
     *    Remove NEW Order Header if no items attached.
     C                   if        mrgord = *on
     C                   exsr      zzcko1
     C                   endif
     *
     *    Remove NEW Route Header if no orders attached.
     C                   if        mrgrte = *on
     C                   exsr      zzckr1
     C                   endif
     *
     *    Print exception grand totals.
     C                   if        excprt = *on
     C                   if        *in92
     C                   write     head11                               92
     C                   endif
     C                   write     grndttl1
     C                   endif
     *
     *  We are finished so get out
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
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
     * Open IMPFORDHM6 file.
     C                   if        opnimpordhm <> *on
     C                   open      impfordhm6                           67
     C                   if        *in67 = *off
     C                   eval      opnimpordhm = *on
     C                   eval      mischdrupd = '*YES'
     C                   else
     C                   eval      mischdrupd = '*NO '
     C                   endif
     C                   endif
     *
     * Open ORDHM file if import file was sent.
     C                   if            opnordhm <> *on
     C                             and mischdrupd ='*YES'
     C                   open      ordhm                                67
     C                   if        *in67 = *off
     C                   eval      opnordhm   = *on
     C                   eval      mischdrupd = '*YES'
     C                   else
     C                   eval      mischdrupd = '*NO '
     C                   endif
     C                   endif
     *
     * Open IMPFORDDM file.
     C                   if        opnimporddm <> *on
     C                   open      impforddm6                           68
     C                   if        *in68 = *off
     C                   eval      opnimporddm = *on
     C                   eval      miscupdate  = '*YES'
     C                   else
     C                   eval      miscupdate = '*NO '
     C                   endif
     C                   endif
     *
     * Open ORDDM file if import file was sent.
     C                   if            opnorddm <> *on
     C                             and miscupdate ='*YES'
     C                   open      orddm                                68
     C                   if        *in68 = *off
     C                   eval      opnorddm   = *on
     C                   eval      miscupdate = '*YES'
     C                   else
     C                   eval      miscupdate = '*NO '
     C                   endif
     C                   endif
     *
     * Open ORDDM file if import file was sent.
     C                   if        client = packers
     C                   if        not %open(custmisc)
     C                   open      custmisc
     C                   endif
     C                   endif
     *
     * CROSSDK  Cross Dock - Full key
     C     cdkey         klist
     C                   kfld                    slwhse
     C                   kfld                    slwhdp
     C                   kfld                    sldisp
     *
     * IMPFORDH6 Download order header file - Partial key
     C     oihkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptype
     *
     * IMPFORDHM6  Download order header misc - full key
     C     oihmkey       klist
     C                   kfld                    oihwhs
     C                   kfld                    oihdiv
     C                   kfld                    oihord
     *
     * IMPFORDDM6  Download order detail misc - full key
     C     oimkey        klist
     C                   kfld                    oidwhs
     C                   kfld                    oiddiv
     C                   kfld                    oidord
     C                   kfld                    oidseq
     C                   kfld                    oiditm
     *
     * CUSTMISC   BFC Dakota Customer Master - Misc. - Full Key
     C     csmkey        klist
     C                   kfld                    oihwhs
     C                   kfld                    oihcus
     *
     * ORDH Order header file - Partial key
     *
     C     ohkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    neword
     *
     * ORDH4 Order header file - Full key  (NEW Route)
     *
     C     oh3key        klist
     C                   kfld                    $pwhse
     C                   kfld                    newrte
     *
     * ORDH4 Order header file - Full key  (Open Route)
     *
     C     oh5key        klist
     C                   kfld                    $pwhse
     C                   kfld                    opnrte
     C                   kfld                    oihord
     *
     * ORDHM Order header misc. file - Full key
     *
     C     *like         define    hmord         kyord
     C     hmkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    kyord
     *
     * ORDD Order detail file - Partial key
     *
     C     odkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    neword
     *
     * ORDD1 Order detail file - Full key
     *
     C                   eval      kystat = 'O'
     C     od1key        klist
     C                   kfld                    $pwhse
     C                   kfld                    opnord
     C                   kfld                    kystat
     C                   kfld                    oidseq
     C                   kfld                    oiditm
     C     od2key        klist
     C                   kfld                    $pwhse
     C                   kfld                    neword
     *
     * ORDDM  Order detail misc. file - Full key
     *
     C     omkey         klist
     C                   kfld                    odwhse
     C                   kfld                    odord
     C                   kfld                    odseq
     C                   kfld                    oditem
     *
     * OPTIONS Options file - Full key
     *
     C     opkey         klist
     C                   kfld                    opwhse
     C                   kfld                    opcode
     *
     * PODTL1 PO DETAIL file
     *
     C     keypd1        klist
     C                   kfld                    $pwhse
     C                   kfld                    oidpo
     C                   kfld                    oiditm
     *
     * RTEHED1 - Route header file - Partial key
     *
     C     rh1key        klist
     C                   kfld                    $pwhse
     C                   kfld                    oihrte
     *
     * RTEHED1 - Route header file - Full key
     C     rh2key        klist
     C                   kfld                    $pwhse
     C                   kfld                    newrtc
     C                   kfld                    newrte
     *
     * RTEHED1 - Route header file - Full key
     C     rh3key        klist
     C                   kfld                    $pwhse
     C                   kfld                    lstrte
     C                   kfld                    lstrid
     *
     * SLOT1 file
     C     keysl1        klist
     C                   kfld                    $pwhse
     C                   kfld                    itwhdp
     C                   kfld                    kyaisl
     *
     * SLOT4 file
     C     keysl4        klist
     C                   kfld                    $pwhse
     C                   kfld                    itwhdp
     C                   kfld                    oiditm
     C                   kfld                    kydisp
     *
     * SLOT11 file
     C     keysl11       klist
     C                   kfld                    $pwhse
     C                   kfld                    kyaisl
     *
     *  Variables and constants.
     *
     C                   eval      forevr = *off
     C                   eval      mrgrte = *off
     C                   eval      mrgord = *off
     C                   eval      mrgitm = *off
     C                   eval      wrgsts = *off
     C                   eval      rcdlck = *off
     C                   eval      skpwrt = *off
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILLOD  Fill order detail fields.
     *
     C     fillod        begsr
     C                   eval      skpwrt = *off
     *
     *    Route & order at Open status. Check if item already on order.
     *    If yes, then compute difference between import qty's and order
     *    qty's. Then update order with import qty.
     C                   select
     C                   when      mrgrte = *on  and
     C                             mrgord = *on  and
     C                             wrgsts = *off
     *
     C                   eval      rcdlck = *on
     C                   exsr      zzgtod
     C                   eval      rcdlck = *off
     *
     C                   select
     C                   when      not *in75  and
     C                             oiditm = oditem
     *
     *    Calculate change in quantity to update RTESUM file.
     C                   eval      difqy1 = oidq1 - odqor1
     C                   eval      difqy2 = oidq2 - oidq2
     C                   eval      difqy3 = oidq3 - oidq3
     *
     C                   eval      odqor1 = oidq1
     C                   if        itflg1 = 'Y'
     C                   eval      odqor2 = oidq2
     C                   endif
     C                   if        itflg2 = 'Y'
     C                   eval      odqor3 = oidq3
     C                   endif
     C                   update    odrec1
     *    Load print field for report.
     C                   move      odord         prtord
     C                   move      sts03         stsmsg
     C                   eval      mrgitm = *on
     C                   eval      skpwrt = *on
     C                   goto      endlod
     C                   endsl
     *
     C                   endsl
     *
     *  Initialize record
     *
     C                   clear                   odrec
     *
     *  Move fields from download file to purchase order header fields
     *
     C                   eval      odwhse = oidwhs
     *
     *    Open route found, Open order not found or at wrong status.
     *    Create order under current Open route.
     C                   select
     C                   when      mrgrte = *on  and
     C                             mrgord = *off  and
     C                             wrgsts = *off  or
     *
     C                             mrgrte = *on  and
     C                             mrgord = *off  and
     C                             wrgsts = *on
     C                   eval      odord = neword
     C                   move      sts02         stsmsg
     *
     *    Open route found, Open order found.
     *    Add item to current Open order.
     C                   when      mrgrte = *on  and
     C                             mrgord = *on  and
     C                             wrgsts = *off
     C                   eval      odord = opnord
     C                   move      sts01         stsmsg
     *
     C                   other
     C                   eval      odord = ohord
     C                   endsl
     *    Load print field for report.
     C                   move      odord         prtord
     *
     C                   eval      odseq = oidseq
     C                   eval      oditem = oiditm
     C                   eval      odqor1 = oidq1
     C                   eval      difqy1 = oidq1
     C                   if        itflg1 = 'Y'
     C                   eval      odqor2 = oidq2
     C                   eval      difqy2 = oidq2
     C                   else
     C                   eval      odqor2 = 0
     C                   eval      difqy2 = 0
     C                   endif
     C                   if        itflg2 = 'Y'
     C                   eval      odqor3 = oidq3
     C                   eval      difqy3 = oidq3
     C                   else
     C                   eval      odqor3 = 0
     C                   eval      difqy3 = 0
     C                   endif
     C                   eval      odwh2 = oidwh2
     C                   eval      odor2 = oidor2
     C                   eval      odoitm = oidoit
     C                   eval      odspcl = oidspc
     C                   eval      odstat = 'O'
     C                   eval      mrgitm = *on
     *
     C     endlod        tag
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILLOM  Fill order detail misc file fields.
     *
     C     filloM        begsr
     *
     C     oimkey        chain     impforddm6
     C                   if        not %found(impforddm6)
     C*                  clear                   oimrec
     C                   eval      oimdsc = ' '
     C                   eval      oimpds = 'N'
     C                   eval      oimrds = 'N'
     C                   eval      oimbox = 'N'
     C                   eval      oimexp = 'N'
     C                   eval      oimms1 = ' '
     C                   eval      oimms2 = ' '
     C                   eval      oimms3 = ' '
     C                   eval      oimms4 = ' '
     C                   eval      oimms5 = ' '
     C                   endif
     *
     *    Route & order at Open status. Check if item already on order.
     *    If yes, then compute difference between import qty's and order
     *    qty's. Then update order with import qty.
     C                   select
     C                   when      mrgrte = *on  and
     C                             mrgord = *on  and
     C                             wrgsts = *off
     *
     C                   eval      rcdlck = *on
     C                   exsr      zzgtom
     C                   eval      rcdlck = *off
     *
     C                   select
     C                   when      %found(orddm) and
     C                             oiditm = oditem
     *
     C                   select
     C                   when      client = packers
     C                   eval      omodsc = ' '
     C                   other
     *
     C                   eval      omodsc = oimdsc
     C                   endsl
     *
     C                   eval      ompdsc = oimpds
     C                   eval      omrdsc = oimrds
     C                   eval      omcbox = oimbox
     C                   eval      omcexp = oimexp
     *
     C                   select
     C                   when      client = packers
     C                   eval      ommsc1 = oimdsc
     C                   other
     *
     C                   eval      ommsc1 = oimms1
     C                   endsl
     *
     C                   eval      ommsc2 = oimms2
     C                   eval      ommsc3 = oimms3
     C                   eval      ommsc4 = oimms4
     C                   eval      ommsc5 = oimms5
     C                   update    omrec
     *
     C                   goto      endlodm
     C                   endsl
     *
     C                   endsl
     *
     *  Initialize record
     *
     C                   clear                   omrec
     *
     *  Move fields from download file to order detail misc file fields.
     *
     C                   eval      omwhse = oidwhs
     *
     *    Open route found, Open order not found or at wrong status.
     *    Create order under current Open route.
     C                   select
     C                   when      mrgrte = *on  and
     C                             mrgord = *off  and
     C                             wrgsts = *off  or
     *
     C                             mrgrte = *on  and
     C                             mrgord = *off  and
     C                             wrgsts = *on
     C                   eval      omord = neword
     *
     *    Open route found, Open order found.
     *    Add item to current Open order.
     C                   when      mrgrte = *on  and
     C                             mrgord = *on  and
     C                             wrgsts = *off
     C                   eval      omord = opnord
     *
     C                   other
     C                   eval      omord = ohord
     C                   endsl
     *
     C                   eval      omseq  = oidseq
     C                   eval      omitem = oiditm
     C                   eval      omodsc = oimdsc
     C                   eval      ompdsc = oimpds
     C                   eval      omrdsc = oimrds
     C                   eval      omcbox = oimbox
     C                   eval      omcexp = oimexp
     C                   eval      ommsc1 = oimms1
     C                   eval      ommsc2 = oimms2
     C                   eval      ommsc3 = oimms3
     C                   eval      ommsc4 = oimms4
     C                   eval      ommsc5 = oimms5
     *
     C     endlodm       tag
     *
     C                   endsr
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
     C                   eval      neword = ohord
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
     *
     *    Open route found, Open order NOT found.
     *    Add Order to current Open Route.
     C                   select
     C                   when      mrgrte = *on  and
     C                             mrgord = *off  and
     C                             wrgsts = *off
     C                   eval      ohrte = opnrte
     *
     C                   other
     C                   eval      ohrte = rhrtid
     C                   endsl
     *    Load print field for report.
     C                   eval      prtrte = ohrte
     *
     *      Set stops to zero. OI300 will compute a sequential
     *      stop number to be populated into this field.
     C                   eval      ohstop = 0
     *
     C                   eval      ohtruk = $ptruk
     C                   eval      ohmisc = oihmsc
     C                   eval      ohstat = 'O'
     C                   eval      ohsdte = impdte
     C                   eval      ohstim = imptim
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILLHM  Fill order header misc file fields.
     *
     C     fillHM        begsr
     *
     C     oihmkey       chain     impfordhm6
     C                   if        not %found(impfordhm6)
     C                   eval      ohmms1 = ' '
     C                   eval      ohmms2 = ' '
     C                   eval      ohmms3 = ' '
     C                   eval      ohmms4 = ' '
     C                   eval      ohmms5 = ' '
     C                   endif
     *
     C                   select
     *    Open route found, Open order found.
     *    Retrieve Open Order Header Misc. file
     C                   when      mrgrte = *on  and
     C                             mrgord = *on  and
     C                             wrgsts = *off
     C                   eval      kyord = opnord
     *
     C                   other
     C                   eval      kyord = neword
     C                   endsl
     *
     C                   eval      rcdlck = *on
     C                   exsr      zzgethm
     C                   eval      rcdlck = *off
     *
     C                   select
     C                   when      %found(ordhm)
     *
     C                   select
     *    Open route found, Open order found.
     *    Leave route ID untouched.
     C                   when      mrgrte = *on  and
     C                             mrgord = *on  and
     C                             wrgsts = *off
     *
     *    Open route found, Open order NOT found.
     *    Add Order to current Open Route.
     C                   when      mrgrte = *on  and
     C                             mrgord = *off  and
     C                             wrgsts = *off
     C                   eval      hmrtid = opnrte
     C                   other
     C                   eval      hmrtid = rhrtid
     C                   endsl
     *
     C                   eval      hmmsc1 = ohmms1
     C                   eval      hmmsc2 = ohmms2
     C                   eval      hmmsc3 = ohmms3
     C                   eval      hmmsc4 = ohmms4
     C                   eval      hmmsc5 = ohmms5
     C                   update    hmrec
     *
     C                   goto      endlodhm
     *
     C                   endsl
     *
     *  Initialize record
     *
     C                   clear                   hmrec
     *
     *  Move fields from download file to order detail misc file fields.
     *
     C                   eval      hmwhse = oihwhs
     C                   eval      hmord = neword
     C                   select
     *
     *    Open route found, Open order NOT found.
     *    Add Order to current Open Route.
     C                   when      mrgrte = *on  and
     C                             mrgord = *off  and
     C                             wrgsts = *off
     C                   eval      hmrtid = newrte
     *
     C                   other
     C                   eval      hmrtid = rhrtid
     C                   endsl
     *
     C                   eval      hmmsc1 = ohmms1
     C                   eval      hmmsc2 = ohmms2
     C                   eval      hmmsc3 = ohmms3
     C                   eval      hmmsc4 = ohmms4
     C                   eval      hmmsc5 = ohmms5
     *
     C     endlodhm      tag
     *
     C                   endsr
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
     C                   eval      lstrid = rhrtid
     *
     C                   add       1             rtcnt
     C                   select
     C                   when      rtcnt = 1
     C                   eval      $prt01 = rhrtid
     C                   when      rtcnt = 2
     C                   eval      $prt02 = rhrtid
     C                   when      rtcnt = 3
     C                   eval      $prt03 = rhrtid
     C                   when      rtcnt = 4
     C                   eval      $prt04 = rhrtid
     C                   when      rtcnt = 5
     C                   eval      $prt05 = rhrtid
     C                   when      rtcnt = 6
     C                   eval      $prt06 = rhrtid
     C                   when      rtcnt = 7
     C                   eval      $prt07 = rhrtid
     C                   when      rtcnt = 8
     C                   eval      $prt08 = rhrtid
     C                   when      rtcnt = 9
     C                   eval      $prt09 = rhrtid
     C                   when      rtcnt = 10
     C                   eval      $prt10 = rhrtid
     C                   endsl
     C                   eval      newrte = rhrtid
     C                   if        $ptype = 'W'  and
     *
     C                             oihrte = *blanks
     C                   eval      rhrte = rhrtid
     C                   else
     C                   eval      rhrte = oihrte
     C                   endif
     C                   eval      newrtc = oihrte
     C                   eval      rhtype = oihtyp
     C                   if        $ptype = 'W'  and
     C                             oihtrk = *blanks
     *
     C                   eval      rhtruk = *blanks
     C                   movel     'WILLCALL'    rhtruk
     C                   else
     C                   eval      rhtruk = oihtrk
     C                   endif
     *
     C                   eval      $ptruk = rhtruk
     C                   eval      rhstat = *on
     C                   eval      rhstsd = impdte
     C                   eval      rhstst = imptim
     C                   eval      rhimpd = impdte
     C                   eval      rhimpt = imptim
     C                   eval      rhrptd = impdte
     *
     C                   endsr
520aA*
520aA*----------------------------------------------------------------
520aA*
520aA*  FILLXR   Fill Stop Xref File RTESTP
520aA*
520aAC     fillxr        begsr
520aA*
520aA*  Initialize record
520aA*
520aAc                   clear                   rtsRec
520aA*
520aAc                   eval      rtswhs = ohWhse
520aAc                   eval      rtsrid = ohRte
520aAc                   eval      rtsord = ohord
520aAc                   eval      rtsstp = 0
520aAc                   eval      rtsst5 = oihest
710aAc                   eval      rtsdrop = *blanks
710aAc                   eval      rtsextd = *blanks
740 Dc*                  eval      rtssd  = *blanks
740 Mc                   eval      rtssd = %editc(oihest : 'X')
520aA*
520aAc                   endsr
520aA*
520aA*----------------------------------------------------------------
520aA*
520aA*  RESEQSTP   Call pgm to Re-Sequence ORDH file
520aA*
520aAC     reseqstp      begsr
520aA*
520aA*  Resequence stops in ORDH to make them unique.
520aA*
520aAc                   call      'OI300'
520aAc                   parm                    rhwhse
520aAc                   parm                    lstrid
520aA*
520aAc                   endsr
520aA*
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
     C                   parm      'OI3151PR'    $lrpt            10
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
     C                   close     oi3151pr
     C                   close     oi315pr
     C                   endif
     *
     *      Override printer file.
     *
     *          OVRPRTF FILE(OI3151PR) OUTQ(*DEV) DEV($dev)
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
     C                   parm      'OI315PR '    $lrpt
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
     *          OVRPRTF FILE(OI315PR) OUTQ(*DEV) DEV($dev)
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
     C                   open      oi3151pr
     C                   open      oi315pr
     C                   eval      opened = *on
     *
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  UPDRTE   Update route with automatically assigned truck.
     *
     C     updrte        begsr
     *
     *  If first time throught, then get out.
     *
     C     lstrte        cabeq     '@@@@@'       endupr
     *
     *  Get route header record.
     *
     C     rh3key        chain     rtehed1                            73
     C                   if        *in73
     C                   goto      endupr
     C                   endif
     *
     *  If truck already defined, get out.
     *
     C                   if        rhtruk <> *blanks
     C                   unlock    rtehed1
     C                   goto      endupr
     C                   endif
     *
     *  Call program to automatically assign truck.
     *
     C                   call      'OI260'
     C                   parm                    rhwhse
     C                   parm                    rhrtid
     C                   parm                    rhtruk
     C                   parm                    $xrtn             8
     C                   parm      '*DFLT  '     $xcmd             8
     C                   if        $xrtn = '*OK'
     C                   update    rhrec1
     C                   else
     C                   unlock    rtehed1
     C                   endif
     *
     C     endupr        endsr
     *----------------------------------------------------------------
     *
     *  UPDSUM   Update route summary file with detail record.
     *
     C     updsum        begsr
     *
     *  Define work fields
     *
     *
     *  Try to get existing summary records for department.
     *
     C                   select
     *    Update route summary for Open route when Open Order
     *    found and at correct status.
     C                   when      mrgrte = *on  and
     C                             mrgord = *on  and
     C                             wrgsts = *off  and
     C                             mrgitm = *on  or
     *
     *    Update route summary for Open route when Open Order
     *    NOT found and at correct status.
     C                             mrgrte = *on  and
     C                             mrgord = *off  and
     C                             wrgsts = *off  and
     C                             mrgitm = *on
     C                   eval      kyrtid = opnrte
     *
     C                   other
     C                   eval      kyrtid = newrte
     C                   endsl
     *
     *     Determine department to use.
     *
     C                   eval      kywhdp = itwhdp
     *
     C     keyrs         chain     rtesum                             77
     *
     *     Record does not exist - Initialize fields.
     *
     C                   if        *in77
     C                   eval      rswhse = rhwhse
     C                   eval      rsrtid = kyrtid
     C                   eval      rswhdp = kywhdp
     C                   eval      rsordc = 0
     C                   eval      rsordw = 0
     C                   eval      rsordp = 0
     C                   eval      rspckc = 0
     C                   eval      rspckw = 0
     C                   eval      rspckp = 0
     C                   endif
     *
     *     Update department totals.
     *
     *     Get base item for alias item.
     C                   eval      #bityp = *blanks
     C                   if        ittype = 'A'
     C                   call      'GETBASE'
     C                   parm      itwhse        $gwhse            3 0
     C                   parm      ititem        $gitem           15
     C                   parm      ' '           #bitem           15
     C                   parm                    #bityp            1
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     C                   parm                    #bwhdp            5
     C                   parm                    #bstyp            1
     C                   parm                    #bum1             2
     C                   parm                    #bum2             2
     C                   parm                    #bumq2            3 0
     C                   parm                    #bum3             2
     C                   parm                    #bumq3            3 0
     C                   parm      ' '           #bcitm           15
     C                   parm                    #bctyp            1
     C                   parm                    #bcdsc           30
     C                   parm                    #bcpds           15
     C                   parm                    #bcwdp            5
     C                   parm                    #bcstp            1
     C                   parm                    #bcum1            2
     C                   parm                    #bcum2            2
     C                   parm                    #bcuq2            3 0
     C                   parm                    #bcum3            2
     C                   parm                    #bcuq3            3 0
     C                   parm                    #brtn             8
     C                   endif
     *
     C                   add       difqy1        rsordp
     C                   if        #bityp = 'S'  or
     C                             ittype = 'S'
     C                   if        itumq2 <= 0
     C                   eval      tmpcub = tmpcub * difqy1
530bAC                   eval      tmpwgt = tmpwgt * difqy1
     C                   else
     C     itcube        div(h)    itumq2        tmpcub
530bAC     itswgt        div(h)    itumq2        tmpwgt
     C                   eval      tmpcub = tmpcub * difqy1
530bAC                   eval      tmpwgt = tmpwgt * difqy1
     C                   endif
     C                   else
     C                   eval      tmpcub = itcube * difqy1
530bAC                   eval      tmpwgt = itswgt * difqy1
     C                   endif
     *
     C                   add       tmpcub        rsordc
530bDC*                  eval      tmpwgt = itswgt * difqy1
     C                   add       tmpwgt        rsordw
     *
     C                   add       difqy2        rsordp
     C                   if        difqy2 <> 0  and
     C                             itumq2 > 0
     C     itcube        div(h)    itumq2        tmpcub
     C                   eval      tmpcub = tmpcub * difqy2
     C                   add       tmpcub        rsordc
     C     itswgt        div(h)    itumq2        tmpwgt
     C                   eval      tmpwgt = tmpwgt * difqy2
     C                   add       tmpwgt        rsordw
     C                   endif
     *
     C                   add       difqy3        rsordp
     C                   if        difqy3 <> 0  and
     C                             itumq3 > 0
     C     itcube        div(h)    itumq3        tmpcub
     C                   eval      tmpcub = tmpcub * difqy3
     C                   add       tmpcub        rsordc
     C     itswgt        div(h)    itumq3        tmpwgt
     C                   eval      tmpwgt = tmpwgt * difqy3
     C                   add       tmpwgt        rsordw
     C                   endif
     *
     *     Add/Update summary record.
     *
     C                   if        *in77
     C                   write     rsrec
     C                   else
     C                   update    rsrec
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZBKDN  Check breakdown quanties.
     *
     C     zzbkdn        begsr
     C                   if        oidq2 <> 0  and
     C                             itflg1 <> 'Y'
     C                   eval      detmsg = desc(3)
     C                   add       1             badbrk
     C                   endif
     *
     C                   if        oidq3 <> 0  and
     C                             itflg2 <> 'Y'
     C                   eval      detmsg = desc(3)
     C                   add       1             badbrk
     C                   endif
     *
     *  Move fields from download file to purchase order header fields
     *
     C                   if        oidq1 <> 0
     C                   eval      good1 = 'Y'
     C                   else
     C                   if        oidq2 <> 0  and
     C                             itflg1 = 'Y'
     C                   eval      good1 = 'Y'
     C                   else
     C                   if        oidq3 <> 0  and
     C                             itflg2 = 'Y'
     C                   eval      good1 = 'Y'
     C                   endif
     C                   endif
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCKRT  Check if route still at Open Status.
     *
     C     zzckrt        begsr
     *
     *    Position past last route, then read backward to get last route.
     *    If Regular route and status is Open, then allow orders to be
     *    merged to existing route.
     *
     *    NOTE: If we find the route that is being merged in,
     *          and the route is at Open status, we will leave the
     *          route header record locked till the merge is com-
     *          plete or we process a new route.  Leaving the record
     *          locked will prevent anyone from Allocating the route
     *          while we are importing new orders.
     *
     C     rh1key        setgt     rtehed1
     C     rh1key        readpe    rtehed1                                73
     C                   select
     C                   when      not *in73  and
     C                             rhtype = ' '  and
     C                             rhstat = '1'
     C                   eval      mrgrte = *on
     C                   eval      opnrte = rhrtid
     C                   eval      opnrtc = rhrte
     *
     C                   other
     C                   eval      mrgrte = *off
     C                   unlock    rtehed1
     *
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCKR1  Check if NEW route has any orders attached.
     *
     C     zzckr1        begsr
     *
     *    Check to see if any orders attached to NEW Route Header.
     *    If none found, then Delete NEW Route Header record.
     C     oh3key        setll     ordh4                                  77
     C                   if        not *in77
     C     rh2key        chain     rtehed1                            73
     C                   if        not *in73
     C                   delete    rhrec1
     C                   endif
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCKOR  Check if order header still at Open status.
     *
     C     zzckor        begsr
     *
     C     oh5key        setll     ordh4
     C                   dow       forevr = forevr
     C     oh5key        reade     ordh4
     C                   select
     C                   when      %eof(ordh4)
     C                   eval      wrgsts = *on
     *
     C                   leave
     *
     *    In order to merge an order being imported, the following have
     *    to match: Must be the same type, existing order must be open,
     *    same customer.
     C                   when      not %eof(ordh4)
     C                             and oihtyp = ' '
     C                             and ohtype = ' '
     C                             and ohstat = 'O'
     C                             and client <> Packers
     *
     C                             or client = Packers
     C                             and not %eof(ordh4)
     C                             and oihtyp = ' '
     C                             and ohtype = ' '
     C                             and ohstat = 'O'
     C                             and %subst(oihmsc:17:4) =
     C                                 %subst(ohmisc:17:4)
     C                   eval      mrgord = *on
     C                   eval      opnord = ohord
     C                   eval      opnorc = ohcord
     C                   leave
     *
     C                   other
     C                   iter
     *
     C                   endsl
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCKO1  Check if NEW order header has items attached.
     *
     C     zzcko1        begsr
     *
     *    Check to see if any Items attached to NEW Order Header.
     *    If none found, then Delete NEW Order Header record.
     C     odkey         setll     ordd1                                  75
     C                   if        not *in75
     C     ohkey         chain     ordh                               74
     C                   if        not *in74
     C                   delete    ohrec
     C                   endif
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGETHM   Get order header misc. file rcd. (with/without) record lock.
     *
     C     zzgethm       begsr
     *
     C                   select
     C                   when      rcdlck = *off
     C     hmkey         chain(n)  ordhm
     *
     C                   when      rcdlck = *on
     C     hmkey         chain     ordhm
     *
     C                   endsl
     *
     *    Order header misc. record not found. Clear misc fields.
     C                   if        not %found(ordhm)
     C                   eval      hmmsc1 = ' '
     C                   eval      hmmsc2 = ' '
     C                   eval      hmmsc3 = ' '
     C                   eval      hmmsc4 = ' '
     C                   eval      hmmsc5 = ' '
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGTOD  Get order detail record. (with/without) record lock.
     *
     C     zzgtod        begsr
     *
     C                   select
     C                   when      rcdlck = *off
     C     od1key        chain(n)  ordd1                              75
     *
     C                   when      rcdlck = *on
     C     od1key        chain     ordd1                              75
     *
     C                   endsl
     *
     *    Order detail line item not found. Clear qty fields.
     C                   if        *in75
     C                   eval      odqor1 = *zeros
     C                   eval      odqor2 = *zeros
     C                   eval      odqor3 = *zeros
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGTOM  Get order detail misc. file rcd. (with/without) record lock.
     *
     C     zzgtom        begsr
     *
     C                   select
     C                   when      rcdlck = *off
     C     omkey         chain(n)  orddm
     *
     C                   when      rcdlck = *on
     C     omkey         chain     orddm
     *
     C                   endsl
     *
     *    Order detail line item not found. Clear misc fields.
     C                   if        not %found(orddm)
     C                   eval      omodsc = ' '
     C                   eval      ompdsc = 'N'
     C                   eval      ompdsc = 'N'
     C                   eval      omrdsc = 'N'
     C                   eval      omcbox = 'N'
     C                   eval      omcexp = 'N'
     C                   eval      ommsc1 = ' '
     C                   eval      ommsc2 = ' '
     C                   eval      ommsc3 = ' '
     C                   eval      ommsc4 = ' '
     C                   eval      ommsc5 = ' '
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZXDCK  Attach cross dock item to PO detail line.
     *
     C     zzxdck        begsr
     *
     *    Retrieve Open item order detail line
     C                   if        mrgrte = *on  and
     C                             mrgord = *on
     C                   eval      rcdlck = *off
     C                   exsr      zzgtod
     C                   endif
     *
     *    If we find this item on an existing Open Order and the codes
     *    don't match or this is a cross dock item, force item to New
     *    Route, New Order.
     C                   if        mrgrte = *on  and
     C                             mrgord = *on  and
     C                             *in75  and
     C                             oidspc <> odspcl  or
     *
     C                             oidspc = 'XD'
     C                   eval      wrgsts = *on
     C                   endif
     *
     * Only work with cross dock items.
     C                   if        oidspc <> 'XD'
     C                   eval      good2 = 'Y'
     C                   goto      endxd
     C                   endif
     * Loop through P.O. detail records looking for item.
     C     keypd1        setll     podtl1
     C                   dow       forevr = forevr
     C     keypd1        reade     podtl1                                 79
     * Error if none found.
     C                   if        *in79
     C                   eval      pdseq = 0
     C                   eval      pdpo = oidpo
     C                   endif
     * If cross dock slot record exists, update
     C                   movel     'XDK'         kydisp
     C     keysl4        setll     slot4
     C                   dow       forevr = forevr
     C                   read      slot4                                  79
     C                   if        not *in79  and
     C                             slstat = 'XD'  and
     C                             slwhse = $pwhse  and
     C                             slwhdp = itwhdp  and
     C                             slitem = oiditm  and
     C                             slaisl = 'XDK'
     * Pre-allocate product in case receiving is done before picking.
     C                   add       oidq1         slalc1
     C                   if        itflg1 = 'Y'
     C                   add       oidq2         slalc2
     C                   endif
     C                   if        itflg2 = 'Y'
     C                   add       oidq3         slalc3
     C                   endif
     C                   update    slrec4
     C                   goto      addxdk
     C                   else
     C                   unlock    slot4
     C                   leave
     C                   endif
     C                   enddo
     * Create cross dock slot record.
     C                   eval      tmploc = 1
     C                   eval      kyaisl = 'XDK'
     C     keysl1        setll     slot1
     C                   dow       forevr = forevr
     C     keysl1        reade(n)  slot1                                  79
     C                   if        *in79  or
     C                             slloc > tmploc
     C                   leave
     C                   endif
     C     slloc         add       1             tmploc
     C                   enddo
     *
     C                   clear                   slrec
     C                   eval      slwhse = oidwhs
     C                   eval      slwhdp = itwhdp
     C                   eval      slaisl = 'XDK'
     C                   eval      slloc = tmploc
     C                   eval      slrlvl = 1
     C                   eval      slhand = *blanks
     C                   eval      slstyp = 'X'
     C                   eval      slpseq = tmploc
     C                   eval      slitem = oiditm
     *
     C                   eval      slstat = oidspc
     C                   eval      slsdte = today
     C                   time                    slstim
     C                   eval      slpick = 'N'
     C                   eval      slrsrv = 'N'
     * Format display slot.
     C                   call      'FRMTSL'
     C                   parm                    slwhse
     C                   parm                    slwhdp
     C                   parm                    slaisl
     C                   parm                    slloc
     C                   parm                    slrlvl
     C                   parm                    slhand
     C                   parm                    slstyp
     C                   parm                    slpseq
     C                   parm                    sldisp
     * Pre-allocate product in case receiving is done before picking.
     C                   eval      slalc1 = oidq1
     C                   if        itflg1 = 'Y'
     C                   z-add     oidq2         slalc2
     C                   endif
     C                   if        itflg2 = 'Y'
     C                   z-add     oidq3         slalc3
     C                   endif
     * Add record
     C     slloc         div       2             dummy
     C                   mvr                     slside
     C                   if        slside < 0
     C                   eval      slside = -(slside)
     C                   endif
     C                   write     slrec                                77
     * Error if slot not created.
     C                   if        *in77
     C                   eval      detmsg = desc(5)
     C                   add       1             badpo
     C                   leave
     C                   endif
     * Create cross dock record.
     C     addxdk        tag
     C                   eval      cdwhse = slwhse
     C                   eval      cdwhdp = slwhdp
     C                   eval      cdslot = sldisp
     C                   eval      cdord = ohord
     C                   eval      cdorsq = oidseq
     C                   eval      cdort# = 0
     C                   eval      cdorl# = 0
     C                   eval      cdpo = pdpo
     C                   eval      cdposq = pdseq
     C                   eval      cdpot# = 0
     C                   eval      cdpol# = 0
     C                   write     cdrec                                79
     C                   if        *in79
     C                   eval      detmsg = desc(6)
     C                   add       1             badpo
     C                   else
     C                   eval      good2 = 'Y'
     C                   endif
     C                   leave
     C                   enddo
     *
     C     endxd         endsr
     *----------------------------------------------------------------
     *
     *  ZZXDELXDK   Delete status 'Z' XDK slots
     *
     C     zzzDelXDK     begsr

     C                   eval      kyaisl = 'XDK'
     C     keysl11       setll     slot11
     C                   dow       forevr = forevr
     C     keysl11       reade     slot11
     C                   if        %eof
     C                   leave
     C                   endif
     C                   if        slstat = 'Z'
     C                   delete    slrec11
     *
     *      Delete matching record from Cross Dock file.
     C     cdkey         setll     crossdk
     C                   dow       forevr = forevr
     C     cdkey         reade     crossdk
     C                   if        %eof(crossdk)
     C                   leave
     C                   endif
     C
     C                   delete    cdrec
     C                   enddo
     *
     C                   endif
     C                   enddo

     C                   endsr
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
     *  COMPILE TIME TABLES
     *
**
*EXIST*
*INVALID ITEM*
*BREAKDOWN INVALID*
*INVALID X-DOCK PO*
*XDK SLOT ERROR*
*NO XDK REC CREATED*
**
Import FTP Orders
**   OVRPRTF statment
OVRPRTF FILE(OI3151PR)           OUTQ(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
OVRPRTF FILE(OI315PR)           OUTQ(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
