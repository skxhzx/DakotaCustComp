     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  CK365P    Ship check list with Blanks - Print   Packers
     *  23 July, 2007
     *  Roxanne Harrison
     *
     *----------------------------------------------------------------
     *
     *  Program Modification History
     *  Revisions:
     *    07/23/07  RH  5.10
     *      - Created using CK365, Previous comments remain
     *
     *    08/25/03  RH  4.17
     *      - Created using SL401
     *
510 A*    10/08/07  MLB  5.10
     *      - Enh: Added client custom code support.
     *      - Converted to ILE.
     *
PCKa *    07/15/04  HNK PCKa
     *      - Print Customer order #
     *
PCKb *    09/01/04  HNK PCKb
     *      - Print * for CW items and print total quantity
     *
PCKc *    12/30/04  MLB  PCKc
     *      - Print '*Start*' every time transaction number changes on
     *        report heading.
     *      - Added new format ENDTRN to print every time transaction
     *        number changes.
PCKdA*    10/08/07  MLB  PCKd
     *      - Revised to add SAP Delivery Number to new DETAIAL1_PK fmt.
     *      - Add file ORDHM.
     *
PCKeA*    01/14/08  JCJ  PCKe
     *      - Revised to add Lot Code to item detail.
     *      - Add file ORDDL.
     *
PCKfA*    09/17/09  MLB  PCKf
     *      - Fix: Revised program to omit Label records
     *        where WBQALC and WBQPCK = zero and LBSTAT = C.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Not on file/End of file indicator
     *  91        Overflow Indicator
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fck365     ip   e           k disk
     Fwarehs    if   e           k disk
     Freports   if   e           k disk
     Fpiritem   if   e           k disk
     Fitemmsc   if   e           k disk
     Fitemdsc   if   e           k disk
     Fpirtran   if   e           k disk
     Frtehed    if   e           k disk
     Fpltsum2   if   e           k disk
     Fordh      if   e           k disk
PCKdAFordhm     if   e           k disk
PCKeAForddl     if   e           k disk
     Fck365ppr  o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     D reck            s              7  0 dim(4)
     D lvlk            s              7  0 dim(4)
510 A*----------------------------------------------------------------
510 A*  Customer id
510 A*
PCKdA /COPY QCOPYSRC,ID#packers
510 A*
PCKdA*----------------------------------------------------------------
PCKdA*  SAP Export File data structures
PCKdA*
PCKdA /copy qcopysrc,ordhm1_pak
PCKdA /copy qcopysrc,ordhm2_pak
PCKdA /copy qcopysrc,ordhm3_pak
PCKdA /copy qcopysrc,ordhm4_pak
PCKdA /copy qcopysrc,ordhm5_pak
PCKdA*
     *----------------------------------------------------------------
     *  Pallet id data structure
     *
     *    DSPLID  -  Pallet id.
     *    DSPLXX  -  Unused.
     *    DSPLGN  -  Generation.
     *    DSPLRW  -  Pallet row.
     *    DSPLCL  -  Pallet column.
     *    DSPLSQ  -  Sequence number.
     *               Equal to zero     - Only one pallet in this position.
     *               Greater than zero - Multiple pallets in this position.
     *
     *
     D pltid           ds
     D  dsplid                 1      7  0 inz(0)
     D  dsplxx                 1      2  0
     D  dsplgn                 3      3  0
     D  dsplrw                 4      5  0
     D  dsplcl                 6      6  0
     D  dsplsq                 7      7  0
     *
     D msg1            c                   const('*Start Tran*')
     *
     *----------------------------------------------------------------
     D                 ds
     D  dsmisc                 1     20
     D  dssdte                 1      8
     D  dsspcl                 9     11
     D  dsrpck                12     12
     D  dsdoor                13     14
     D  dsmeat                15     15
     *----------------------------------------------------------------
     * Work variables
     *----------------------------------------------------------------
     D $plen           s              3  0
     D $pstr           s             60
     D first           s              1
     D kytype          s              1
     D l               s              1  0
     D m               s                   like(l)
     D n               s              3  0
     D wkprtf          s             10
     D w1brnd          s             10
     D w1desc          s             60
     D w1pdsc          s             15
     D forever         s              1    inz('1')
     *----------------------------------------------------------------
     Ioqrec
     I                                          wbpal#        l1
PCKcAI                                          wbtrn#        l2
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3
     C                   parm                    $prtid            5
     C                   parm                    $ppgm            10
     C                   parm                    $rtncd            8
     *
     *
     *  Report Heading
     *
     *
     C                   if        *in90
     C                             or first = *on
417XXC                             or *inl1
     C                   exsr      zrhead
     C                   endif
     *
     *  Init total levels
     *
     *
     *  Level 1 break - PALLET
     *
     C                   if        *inl1
     C                   eval      l = 1
     C                   exsr      zrzero
     C                   endif
     *
     *  Output Headings
     *
     C                   if        *in91  or
     C                             first = *on  or
     C                             *inl1
     C                   eval      first = *off
     **         *INL1     OREQ '1'
     **         *IN91     IFEQ '1'
     C                   write     rphead
     **                   END
PCKdAC                   select
PCKdAC                   when      client = packers
PCKdAC                   if        wbwhse = 001
PCKdAC                   write     columns
PCKdAC                   else
PCKdAC                   write     columns_pk
PCKdAC                   endif
PCKdAC                   other
     C                   write     columns
PCKdAC                   endsl
     C                   endif
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *
     *
PCKfAC                   if            wbqalc = 0
PCKfAC                             and wbqpck = 0
PCKfAC                             and wbstat = 'C'
PCKfAC                   goto      #closedlbl
PCKfAC                   endif
     *
     C     itkey         chain     piritem                            79
     C                   if        *in79
     C                   eval      w1pdsc = *blanks
PCKb C                   eval      itcwgt = *blanks
     C                   else
     C                   eval      w1pdsc = itpdsc
     C                   endif
     *
PCKb C                   if        itcwgt = 'Y'
PCKb C                   eval      w1astr = '*'
PCKb C                   else
PCKb C                   eval      w1astr = *blanks
PCKb C                   endif
     *
     C     itkey         chain     itemdsc                            79
     C                   if        *in79
     C                   eval      w1desc = *blanks
     C                   else
     C     ixdsc1        cat       ixdsc2:0      w1desc
     C                   endif
     *
     C     itkey         chain     itemmsc                            79
     C                   if        *in79
     C                   eval      w1brnd = *blanks
     C                   else
     C                   eval      w1brnd = imbrnd
     C                   endif
PCKa * Customer order #
PCKa C     orkey         chain     ordh                               79
PCKa C                   if        *in79
PCKa C                   eval      w1cord = 0
PCKa C                   else
PCKa C                   eval      w1cord = ohcord
PCKa C                   endif
     * Set OUT label for bold print
     C                   if        wbasl2 = 'OUT'
     C                   eval      *in65 = *on
     C                   else
     C                   eval      *in65 = *off
     C                   endif
PCKdA*
PCKdA*      Get Customer order header misc - For shipment#.
PCKdAC                   select
PCKdAC                   when      client = packers
PCKdAC                   write     skip1
PCKdAC                   if        wbwhse  = 001
PCKdAC                   write     detail
PCKdAC                   exsr      zzlotdtl
PCKdAC                   else
PCKdAC                   exsr      zzgetohm
PCKdAC                   eval      w1dlvy = pakhm1_vblen
PCKdAC                   write     detail_pk
PCKdAC                   exsr      zzlotdtl
PCKdAC                   endif
PCKdA*
PCKdAC                   other
PCKdA*
PCKb C                   write     skip1
     C                   write     detail
PCKdA*
PCKdAC                   endsl
PCKdA*
     *
PCKb C                   add       wbqpck        t#qpck
PCKb C                   add       wbqalc        t#qalc
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
     C
PCKfAC     #closedlbl    tag
     *----------------------------------------------------------------
     *
     * NEW PALLET
     *
     CL1                 eval      l = 1
     CL1                 exsr      zrroll
     *
     CL1                 if        reck(l) > 0
     CL1                 write     skip1
PCKb CL1                 write     total1
     CL1                 endif
PCKcA*----------------------------------------------------------------
PCKcA*
PCKcA* Transaction number is changing. Flag End on report.
PCKcA*
PCKcACL2                 if        reck(l) > 0
PCKcACL2                 write     skip1
PCKcACL2                 write     endtrn
PCKcACL2                 endif
     *----------------------------------------------------------------
     *
     * REPORT TOTALS
     *
     CLr                 eval      l = 3
     CLr                 exsr      zrroll
     *
     CLr                 if        reck(l) > 0
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
510 A*
510 A* Get client id.
510 A*
510 AC                   call      'GETCLIENT'
510 AC                   parm                    client           10
510 AC                   parm                    clientloc        10
510 A*
     *
     C     itkey         klist
     C                   kfld                    wbwhse
     C                   kfld                    wbitem
     *
     C     orkey         klist
     C                   kfld                    wbwhse
     C                   kfld                    wbord
     *
     C     plkey         klist
     C                   kfld                    wbwhse
     C                   kfld                    wbrte
     C                   kfld                    kytype
     C                   kfld                    dsplgn
     C                   kfld                    dsplrw
     C                   kfld                    dsplcl
     *
     *
     C     rtkey         klist
     C                   kfld                    wbwhse
     C                   kfld                    wbrte
     *
     C     rpkey         klist
     C                   kfld                    wkprtf
PCKeA*
PCKeAC     lotkey        klist
PCKeAC                   kfld                    wbwhse
PCKeAC                   kfld                    wbord
PCKeAC                   kfld                    wbseq
PCKeAC                   kfld                    wbitem
PCKeAC                   kfld                    wblbl#
     *
     *   Get report title.
     *
     C                   movel     'CK365PPR'    wkprtf
     C                   eval      rptttl = *blanks
     C                   eval      $pstr = *blanks
     C     rpkey         chain     reports                            79
     C                   if        not *in79
     C                   movel     rpdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
     C                   eval      $plen = 40
     *
     *   Center report title.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         rptttl
     *
     C                   eval      first = *on
     C                   time                    time
     C                   eval      l = 3
     C                   eval      n = 0
PCKcA*
PCKcAC                   eval      hldtrn = -1
PCKcA*
     C                   exsr      zrzero
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrfill        begsr
PCKcA*
PCKcA*  Init header field to ID start page for new Transaction.
PCKcAC                   if        wbtrn# <> hldtrn
PCKcAC                   eval      w1sflg = msg1
PCKcAC                   eval      hldtrn = wbtrn#
PCKcAC                   else
PCKcaC                   eval      w1sflg = *blanks
PCKcAC                   endif
     *
     *  Get info to fill HEAD2 fields.
     *
     C     wbtrn#        chain     pirtran                            79
     C                   if        *in79
     C                   eval      w1emp = 0
     C                   else
     C                   eval      w1emp = ptemp#
     C                   endif
     *
     C                   eval      w1dpt = wbwhdp
     C                   eval      w1trn = wbtrn#
     *
     C     rtkey         chain     rtehed                             79
     C                   if        *in79
     C                   eval      w1rte = *blanks
     C                   else
     C                   eval      w1rte = rhrte
     C                   endif
     *
     C                   eval      kytype = 'O'
     C                   eval      dsplid = wbpal#
     C     plkey         chain     pltsum2                            79
     C                   if        *in79
     C                   eval      w1plt = 0
     C                   else
     C                   eval      w1plt = pspal#
     C                   endif
     *
     C     orkey         chain     ordh                               79
     C                   if        *in79
     C                   eval      w1door = 0
     C                   else
     C                   eval      dsmisc = ohmisc
     C                   move      dsdoor        w1door
     C                   endif
     *
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
     *   Get warehouse description.
     *
     C                   eval      whse = *blanks
     C                   eval      $pstr = *blanks
     C     wbwhse        chain     warehs                             79
     C                   if        not *in79
     C                   movel     whdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
     C                   eval      $plen = 30
     *
     *   Center warehouse description.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         whse
     *
     C                   write     head1
     C                   exsr      zrfill
     C                   write     head2
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
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrzero        begsr
     *
     C                   eval      lvlk(l) = 0
     C                   eval      reck(l) = 0
PCKb C                   eval      t#qpck = 0
PCKb C                   eval      t#qalc = 0
     *
     C                   endsr
PCKdA*
PCKdA*----------------------------------------------------------------
PCKdA*
PCKdA*  ZZGETOHM   Get Dakota Customer Order Header Misc.
PCKdA*
PCKdAC     zzgetohm      begsr
PCKdA*
PCKdAC     orkey         chain     ordhm
PCKdAC                   if        not %found(ordhm)
PCKdAC                   eval      hmord  = 0
PCKdAC                   eval      hmmsc1 = ' '
PCKdAC                   eval      hmmsc2 = ' '
PCKdAC                   eval      hmmsc3 = ' '
PCKdAC                   eval      hmmsc4 = ' '
PCKdAC                   eval      hmmsc5 = ' '
PCKdAC                   endif
PCKdA*
PCKdA*
PCKdAC                   select
PCKdAC                   when      client = packers
PCKdAC                   eval      pakhm1_base = hmmsc1
PCKdAC                   if        not %found(ordhm)
PCKdAC                   eval      pakhm1_slsorg = '0000'
PCKdAC                   endif
PCKdAC                   eval      pakhm2_base = hmmsc2
PCKdAC                   eval      pakhm3_base = hmmsc3
PCKdAC                   eval      pakhm4_base = hmmsc4
PCKdAC                   eval      pakhm5_base = hmmsc5
PCKdAC                   endsl
PCKdA*
PCKdAC                   endsr
PCKdA*
PCKeA*----------------------------------------------------------------
PCKeA*
PCKeA*  ZZLOTDTL   Get Lot code detail
PCKeA*
PCKeAC     zzlotdtl      begsr
PCKeA*
PCKeAC     lotkey        setll     orddl
PCKeAC                   dow       forever = forever
PCKeA*
PCKeAC                   eval      w1lota = *blanks
PCKeAC                   eval      w1lotb = *blanks
PCKeAC     lotkey        reade     orddl
PCKeAC                   if        not %eof(orddl)
PCKeAC                   eval      w1lota = odllot
PCKeAC                   endif
PCKeA*
PCKeAC                   if        not %eof(orddl)
PCKeAC     lotkey        reade     orddl
PCKeAC                   if        not %eof(orddl)
PCKeAC                   eval      w1lotb = odllot
PCKeAC                   endif
PCKeAC                   endif
PCKeA*
PCKeAC                   if        w1lota <> *blanks
PCKeAC                   write     detail_lot
PCKeAC                   endif
PCKeA*
PCKeAC                   if        %eof(orddl)
PCKeAC                   leave
PCKeAC                   endif
PCKeA*
PCKeAC                   enddo
PCKeA*
PCKeAC                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
