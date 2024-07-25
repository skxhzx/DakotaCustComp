650aA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  SL384     Slots with negative quantity by slot
     *  24 May, 2004
     *  Roxanne Harrison
     *
     *  Revisions:
     *  05/24/04  RH   4.17a
     *   - Created
     *
640a *  06/05/11  GJA  6.40a
     *   - Fix:  When negative normal UOM and positive brk1, show as
     *           negatvie brk1
     *           Converted to RPGLE
640b *  09/27/11  RH   6.40b
     *   - Enh: Add license, remove transfer & receive qty
     *
650a *  08/30/13  RTR  6.50a
     *   - Enh: Changed to also print other items/slots for repack items
     *
650c *  05/05/14  RBD  6.50c
     *   - Enh: Added slot type selection to heading.
     *     Deleted execution of GetSlots in total L2 calcs, only needs
     *     to be called from GetRepack and GetLinked.
     *
710aA*  04/12/17  RBD  7.10a
     *   - Fix: Reinstate call to GetSlots in total L2 calcs.
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
     Fsl381b    ip   e           k disk
     *LOT2   IF  E           K        DISK
     Fwarehs    if   e           k disk
     Fpiritem   if   e           k disk
     Fsl384pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *                   RPD     1   3 30
     D reck            s              7  0 dim(5)
     *----------------------------------------------------------------
     *
     D $perm           ds
     D  xxerm                  1     60
     D  $pmsg                  1      4
640bA*----------------------------------------------------------------
640bA*  DRI parameters
640bA*----------------------------------------------------------------
640bA
640bA /COPY *libl/qcopysrc,C#DRIPARMS

640bA /COPY *libl/qcopysrc,C#SLOT
640bAD savever#        s                   like($slver#)
640bA*----------------------------------------------------------------
640bA*  Program info data structure
640bA*
640bAD                sds
640bAD  #prog            *proc
640bAD  #pgm             *proc
640bAD  #job                 244    253
640bAD  #user                254    263
640bAD  #jobn                264    269
640bAD  #jobdt               276    281  0
640bAD  #jobtm               282    287  0
650aA
650aA*----------------------------------------------------------------
650aA*  Standard variables and constants
650aA*----------------------------------------------------------------
650aA
650aA /copy qcopysrc,c#stdvar
650aA
650aA*----------------------------------------------------------------
650aA*  Standard SQL variables and constants
650aA*----------------------------------------------------------------
650aA
650aA /copy qcopysrc,c#stdsql
650aA
     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D slrec         e ds                  extname(slot) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Variables
     *
650aAD $item           s             15a
650aAD $item1          s             15a
650aAD $item2          s             15a
650aAD $item3          s             15a
     D $plen           s              3  0
     D $pstr           s             60
     D first           s              1
650aAD it2ind          s              5i 0
650aAD it3ind          s              5i 0
650aAD itemtype        s              1a
     D l               s              1  0
     D m               s                   like(l)
650bAD printflag       s               n
650bAD skipflag        s               n
     D svitem          s                   like(wkitem)
     D type            s             11
     D wkumq           s              3  0
     D w1alc           s             10
     D w1avl           s             10
     D w1disp          s             12
     D w1pck           s             10
     D w1rcv           s             10
     D w1stk           s             10
     D w1tfr           s             10
     *
     *----------------------------------------------------------------
     Iwkrec
     I                                          wkwhdp        l4
     I                                          wkstyp        l3
     I                                          wkitem        l1
     I                                          wkdisp        l2
     *----------------------------------------------------------------
650cA*  Let the show begin .....
     *
650cAC     *entry        plist
650cAC                   parm                    $stype            1
     *
     *  Report Heading
     *
     *
     *  Start new page if one of following happened.
     *     - Page overflow.
     *
     *  PAGE OVERFLOW
     *
     C                   if        first = *on  or
     C                             *in90
     C                   exsr      zrhead
     C                   endif
     *
     *  L4 break - DEPARTMENT
     *
     C                   if        *inl4  and
     C                             reck(l) > 0
     C                   exsr      zrhead
     C                   endif
     *
     *  L3 break - Section change.
     *
     C                   if        *inl3
650bDC*                  if        wkstyp = 'F'
650bDC*                  eval      wostyp = 'FIXED'
650bDC*                  else
650bDC*                  eval      wostyp = 'PIR  '
650bDC*                  endif
     *
650bAC                   select
650bAC                   when      wkstyp = 'F'
650bAC                   eval      wostyp = 'FIXED'
650bAC                   when      wkstyp = 'P'
650bAC                   eval      wostyp = 'PIR  '
650bAC                   when      wkstyp = 'X'
650bAC                   eval      wostyp = 'XDOCK'
650bAC                   other
650bAC                   eval      wostyp = 'OTHER'
650bAC                   endsl
     *
     C                   write     detail2
     C                   endif
     *
     *  L2 break - Slot change.
     *
     C                   if        *inl2
     C                   eval      *in92 = *on
     C                   eval      w1disp = wkdisp
650bAC                   if        wkstk1 >= 0
650bAC                             and wkstk2 >= 0
650bAC                             and wkstk3 >= 0
650bAC                   eval      printflag = *off
650bAC                   else
650bAC                   eval      printflag = *on
650bAC                   eval      skipflag = *off
650bAC                   endif
     C                   endif
     *
     *
     *  Init total levels
     *
     *
     *  Level 1 break - Item
     *
     C                   if        *inl1
     C                   eval      *in91 = *on
     C                   eval      l = 1
     C                   exsr      zrzero
     C                   endif
     *
650aAC                   if        printflag = *on
650aAC                   exsr      DtlCalcs
650aAC                   endif
     *
     *----------------------------------------------------------------
     *
     * Customer totals
     *
     CL1                 if        reck(l) > 0
     CL1                 eval      l = 1
     CL1                 exsr      zrroll
     CL1                 if        wkitem = svitem
     CL1                 eval      *in92 = *off
     CL1                 endif
650bACL1                 if        printflag = *on
     CL1                 write     detail1
650bACL1                 endif
     CL1                 eval      svitem = wkitem
     CL1                 endif
     *
     *----------------------------------------------------------------
     *
     * ITEM
     *
650aA* Get/Print related items also
650bACL2                 if        printflag = *on
710aMCL2                 exsr      GetSlots
650aACL2                 exsr      GetItems
650bACL2                 endif
     CL2                 eval      l = 2
     CL2                 exsr      zrroll
     CL2                 if        reck(l) > 0
     CL2                 eval      *in92 = *off
650bACL2                 if        skipflag = *off
     CL2                 write     skip1
650bACL2                 eval      skipflag = *on
650bACL2                 endif
     CL2                 endif
     *----------------------------------------------------------------
     *
     * Section
     *
     CL3                 eval      l = 3
     CL3                 exsr      zrroll
     ****       RECK,L    IFGT 0
     ****                 WRITEDETAIL2
     ****                 ENDIF
     *----------------------------------------------------------------
     *
     * DEPARTMENT
     *
     CL4                 eval      l = 4
     CL4                 exsr      zrroll
     ****       RECK,L    IFGT 0
     ****                 EXSR ZRHEAD
     ****                 ENDIF
     *----------------------------------------------------------------
     *
     * REPORT TOTALS
     *
     CLr                 eval      l = 5
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
     *
     *  Define key for main file.
     *
     C     keyit         klist
     C                   kfld                    wkwhse
     C                   kfld                    wkitem
     *
650cAC                   select
650cAC                   when      $stype = 'B'
650cAC                   eval      wktype = 'All Slots'
650cAC                   when      $stype = 'P'
650cAC                   eval      wktype = 'Pick slots only'
650cAC                   when      $stype = 'O'
650cAC                   eval      wktype = 'Overflow slots only'
650cAC                   endsl
     *
     C                   time                    time
     C                   eval      first = *on
     C                   eval      l = 2
     C                   exsr      zrzero
     C                   endsr
640bA*----------------------------------------------------------------
640bA*  clr$slot  Clear $slot data structure fields
640bA*----------------------------------------------------------------
640bA
640bAC     clr$slot      begsr
640bAC                   eval      savever# = $slver#
640bAC                   clear                   $slot
640bAC                   clear                   $slot2
640bAC                   eval      $slver# = savever#
640bAC                   endsr
640bA
640bA
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *
     *  Calculate Qty available (stock + rcv) - (aloc + pick + trans)
     *
     *    Create a quantity string to print.
     *
     C     DtlCalcs      begsr
     C                   call      'SLOTQTY'
     C                   parm                    wkstk1
     C                   parm                    wkstk2
     C                   parm                    wkstk3
     *
     C                   parm                    wkalc1
     C                   parm                    wkalc2
     C                   parm                    wkalc3
     *
     C                   parm                    wktfr1
     C                   parm                    wktfr2
     C                   parm                    wktfr3
     *
     C                   parm                    wkpck1
     C                   parm                    wkpck2
     C                   parm                    wkpck3
     *
     C                   parm                    wkrcv1
     C                   parm                    wkrcv2
     C                   parm                    wkrcv3
     *
     C                   parm                    stock1            5 0
     C                   parm                    stock2            3 0
     C                   parm                    stock3            3 0
     *
     C                   parm                    avail1            5 0
     C                   parm                    avail2            3 0
     C                   parm                    avail3            3 0
     *
     C     keyit         chain     piritem                            79
     C                   if        *in79
     C                   eval      itdesc = *blanks
640aAC                   else
640aA*   If negative normal stock and positive brk1 convert
640aAC                   if        wkstk1 < 0  and
640aAC                             wkstk2 > 0  and
640aAC                             itumq2 <> 0
640aAC     wkstk1        mult      itumq2        wkumq
640aAC     wkumq         add       wkstk2        wkstk2
640aAC                   eval      wkstk1 = 0
640aAC                   endif
640aA*   If negative normal recv and positive brk1 convert
640aAC                   if        wkrcv1 < 0  and
640aAC                             wkrcv2 > 0  and
640aAC                             itumq2 <> 0
640aAC     wkrcv1        mult      itumq2        wkumq
640aAC     wkumq         add       wkrcv2        wkrcv2
640aAC                   eval      wkrcv1 = 0
640aAC                   endif
640aA*   If negative normal alc and positive brk1 convert
640aAC                   if        wkalc1 < 0  and
640aAC                             wkalc2 > 0  and
640aAC                             itumq2 <> 0
640aAC     wkalc1        mult      itumq2        wkumq
640aAC     wkumq         add       wkalc2        wkalc2
640aAC                   eval      wkalc1 = 0
640aAC                   endif
640aA*   If negative normal tfr and positive brk1 convert
640aAC                   if        wktfr1 < 0  and
640aAC                             wktfr2 > 0  and
640aAC                             itumq2 <> 0
640aAC     wktfr1        mult      itumq2        wkumq
640aAC     wkumq         add       wktfr2        wktfr2
640aAC                   eval      wktfr1 = 0
640aAC                   endif
640aA*   If negative normal pck and positive brk1 convert
640aAC                   if        wkpck1 < 0  and
640aAC                             wkpck2 > 0  and
640aAC                             itumq2 <> 0
640aAC     wkpck1        mult      itumq2        wkumq
640aAC     wkumq         add       wkpck2        wkpck2
640aAC                   eval      wkpck1 = 0
640aAC                   endif
     C                   endif
     *
     C                   eval      $pqty1 = avail1
     C                   eval      $pqty2 = avail2
     C                   eval      $pqty3 = avail3
     C                   exsr      zzcqty
     C                   eval      w1avl = $pqstr
     *
     C                   eval      $pqty1 = wkstk1
     C                   eval      $pqty2 = wkstk2
     C                   eval      $pqty3 = wkstk3
     C                   exsr      zzcqty
     C                   eval      w1stk = $pqstr
     *
     C                   eval      $pqty1 = wkrcv1
     C                   eval      $pqty2 = wkrcv2
     C                   eval      $pqty3 = wkrcv3
     C                   exsr      zzcqty
     C                   eval      w1rcv = $pqstr
     *
     C                   eval      $pqty1 = wkalc1
     C                   eval      $pqty2 = wkalc2
     C                   eval      $pqty3 = wkalc3
     C                   exsr      zzcqty
     C                   eval      w1alc = $pqstr
     *
     C                   eval      $pqty1 = wktfr1
     C                   eval      $pqty2 = wktfr2
     C                   eval      $pqty3 = wktfr3
     C                   exsr      zzcqty
     C                   eval      w1tfr = $pqstr
     *
     C                   eval      $pqty1 = wkpck1
     C                   eval      $pqty2 = wkpck2
     C                   eval      $pqty3 = wkpck3
     C                   exsr      zzcqty
     C                   eval      w1pck = $pqstr
640b *
640b *  Get License
640bAC                   exsr      clr$slot
640bAC                   eval      $slwhseu = *on
640bAC                   eval      $slwhse  = wkwhse
640bAC                   eval      $slwhdpu = *on
640bAC                   eval      $slwhdp  = wkwhdp
640bAC                   eval      $sldispu = *on
640bAC                   eval      $sldisp  = wkdisp
640bA
640bAC                   eval      $dricommand = '*SLOT'
640bAC                   eval      $drisubcmd  = '%GET'
640bAC                   eval      $drisys2upd = 'D'
640bAC                   exsr      zzzdricop
640bAC                   if        error = *on
640bAC                   eval      error = *off
640bMC                   eval      $saToPos = 0
640bAC                   endif
640bA*
640bAC                   eval      lcns = $saToLcns
     *
     *  Get item description.
     *
     *  Write detail line.
     *
     *                    WRITEDETAIL1
     *
     *  Increment record counters
     *
     C                   add       1             reck(1)
     *
     *  Set off top-of-page indicators
     *
     C                   eval      first = *off
     C                   eval      *in91 = *off
     C                   endsr
     *
650bA*----------------------------------------------------------------
650bA*    GetItems    Get Related items
650bA*
650bA /free
650bA  begsr GetItems;
650bA
650bA    // Get item type to determine if repack or not
650bA    Exec Sql
650bA      Select ITTYPE into :itemtype
650bA        from PIRITEM
650bA        where ITWHSE = :wkwhse
650bA         and ITITEM = :wkitem;
650bA
650bA    if sqlstt <> sqlSuccess;
650bA      dump(a);
650bA    else;
650bA      if itemtype = 'R';
650bA        exsr GetRepack;
650bA      else;
650bA        exsr GetLinked;
650bA      endif;
650bA    endif;
650bA
650bA  endsr;  // GetItems
650bA /end-free
     *
650aA*----------------------------------------------------------------
650aA*    GetRepack   Get Repack items
650aA*
650aA /free
650aA  begsr GetRepack;
650aA
650aA    // Select all piritem and itemlnk records for the item
650aA    Exec Sql
650aA      declare ItemRangeR cursor for
650aA        Select ITITEM, KCITEM, KCCITM
650aA        from PIRITEM Left Join KITCOMP
650aA         on (ititem = kcitem or ititem = kccitm)
650aA        where ITWHSE = :wkwhse
650aA         and ITITEM = :wkitem
650aA        order by ITITEM;
650aA
650aA    exec sql open ItemRangeR;
650aA    if sqlstt <> sqlSuccess;
650aA      dump(a);
650aA    endif;
650aA
650aA        *in92 = *on;
650aA    dow forever = forever;
650aA
650aA      exec sql fetch next from ItemRangeR
650aA               into :$item1, :$item2:it2ind, :$item3:it3ind;
650aA
650aA      if sqlstt <> sqlSuccess;
650aA        leave;
650aA      endif;
650aA
650aA      if it2ind = 0
650aA       and $item2 <> $item1;
650aA        wkitem = $item2;
650aA        exsr GetSlots;
650aA      endif;
650aA
650aA      if it3ind = 0
650aA       and $item3 <> $item1;
650aA        wkitem = $item3;
650aA        exsr GetSlots;
650aA      endif;
650aA
650aA    enddo;
650aA
650aA    exec sql close ItemRangeR;
650aA
650aA  endsr;  // GetRepack
650aA /end-free
     *
650aA*----------------------------------------------------------------
650aA*    GetLinked   Get Linked items
650aA*
650aA /free
650aA  begsr GetLinked;
650aA
650aA    // Select all piritem and itemlnk records for the item
650aA    Exec Sql
650aA      declare ItemRange cursor for
650aA        Select ITITEM, ILITEM, ILITM2
650aA        from PIRITEM Left Join ITEMLNK
650aA         on (ititem = ilitem or ititem = ilitm2)
650aA        where ITWHSE = :wkwhse
650aA         and ITITEM = :wkitem
650aA        order by ITITEM;
650aA
650aA    exec sql open ItemRange;
650aA    if sqlstt <> sqlSuccess;
650aA      dump(a);
650aA    endif;
650aA
650aA        *in92 = *on;
650aA    dow forever = forever;
650aA
650aA      exec sql fetch next from ItemRange
650aA               into :$item1, :$item2:it2ind, :$item3:it3ind;
650aA
650aA      if sqlstt <> sqlSuccess;
650aA        leave;
650aA      endif;
650aA
650aA      if it2ind = 0
650aA       and $item2 <> $item1;
650aA        wkitem = $item2;
650aA        exsr GetSlots;
650aA      endif;
650aA
650aA      if it3ind = 0
650aA       and $item3 <> $item1;
650aA        wkitem = $item3;
650aA        exsr GetSlots;
650aA      endif;
650aA
650aA    enddo;
650aA
650aA    exec sql close ItemRange;
650aA
650aA  endsr;  // GetLinked
650aA /end-free
650aA*
650aA*----------------------------------------------------------------
650aA*    GetSlots    Get Slots for items
650aA*
650aA /free
650aA  begsr GetSlots;
650aA
650aA    // Select all slots for the item
650aA    exec sql
650aA      declare SlotList cursor for
650aA        Select * from SLOT
650aA        where SLWHSE = :wkwhse
650aA         and SLITEM = :wkitem
650bA         and SLDISP <> :wkdisp
650bA        order by SLDISP, SLITEM;
650aA
650aA    exec sql open SlotList;
650aA    if sqlstt <> sqlSuccess;
650aA      dump(a);
650aA    endif;
650aA
650aA    *in92 = *on;
650aA    dow forever = forever;
650aA
650aA      exec sql fetch next from SlotList into :slrec;
650aA
650aA      if sqlstt <> sqlSuccess;
650aA        leave;
650aA      endif;
650aA
650aA      WKWHSE = SLWHSE;
650aA      WKWHDP = SLWHDP;
650aA      WKAISL = SLAISL;
650aA      WKLOC  = SLLOC;
650aA      WKRLVL = SLRLVL;
650aA      WKHAND = SLHAND;
650aA      WKSIDE = SLSIDE;
650aA      WKSTYP = SLSTYP;
650aA      WKDISP = SLDISP;
650aA      WKSTAT = SLSTAT;
650aA      WKSDTE = SLSDTE;
650aA      WKSTIM = SLSTIM;
650aA      WKSDEF = SLSDEF;
650aA      WKDESG = SLDESG;
650aA      WKACTV = SLACTV;
650aA      WKBLD  = SLBLD;
650aA      WKPICK = SLPICK;
650aA      WKPSEQ = SLPSEQ;
650aA      WKPRTY = SLPRTY;
650aA      WKENTD = SLENTD;
650aA      WKEXPD = SLEXPD;
650aA      WKSLFD = SLSLFD;
650aA      WKRSRV = SLRSRV;
650aA      WKITEM = SLITEM;
650aA      WKSTK1 = SLSTK1;
650aA      WKSTK2 = SLSTK2;
650aA      WKSTK3 = SLSTK3;
650aA      WKALC1 = SLALC1;
650aA      WKALC2 = SLALC2;
650aA      WKALC3 = SLALC3;
650aA      WKTFR1 = SLTFR1;
650aA      WKTFR2 = SLTFR2;
650aA      WKTFR3 = SLTFR3;
650aA      WKPCK1 = SLPCK1;
650aA      WKPCK2 = SLPCK2;
650aA      WKPCK3 = SLPCK3;
650aA      WKRCV1 = SLRCV1;
650aA      WKRCV2 = SLRCV2;
650aA      WKRCV3 = SLRCV3;
650aA      exsr DtlCalcs;
650aA      write detail1;           // print linked parent/child item
650aA      *in92 = *off;
650aA
650aA    enddo;
650aA
650aA    exec sql close SlotList;
650aA
650aA  endsr;  // GetSlots
650aA /end-free
     *
     *----------------------------------------------------------------
     *
     C     zrfrmt        begsr
     *
     *   Get warehouse description.
     *
     C                   eval      whse = *blanks
     C                   eval      $pstr = *blanks
     C     wkwhse        chain     warehs                             79
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
     *  Format department/section.
     *
     C                   eval      type = *blanks
     C     wkwhdp        cat       '/':0         type
     C                   if        wkstyp = 'P'
     C     type          cat       'PIR':0       type
     C                   else
     C     type          cat       'FIXED':0     type
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     C                   if        *inl1
     C                   exsr      zrfrmt
     C                   else
     C                   eval      *in91 = *on
     C                   endif
     *
     C                   eval      *in90 = *off
     *
     C                   write     head1
     C                   write     head2
     C                   write     columns
     *
650bAC                   eval      first = *off
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrroll        begsr
     *
     C     l             add       1             m
     *
     *                    ADD  1         LVLK,M
     C                   add       reck(l)       reck(m)
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrzero        begsr
     *
     *                    Z-ADD0         LVLK,L
     C                   eval      reck(l) = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zzcqty        begsr
     *
     C                   eval      $pcmd = '*QTY2STR'
     *                    Z-ADDAVAIL1    $PQTY1
     *                    Z-ADDAVAIL2    $PQTY2
     *                    Z-ADDAVAIL3    $PQTY3
     C                   eval      $pqstr = *blanks
     *
     C                   call      'CVTQTY'
     C                   parm                    $pcmd             8
     C                   parm                    $pprg            10
     C                   parm                    $pqty1            7 0
     C                   parm                    $pqty2            7 0
     C                   parm                    $pqty3            7 0
     C                   parm                    $pum1             2
     C                   parm                    $pum2             2
     C                   parm                    $pum3             2
     C                   parm                    $pqstr           10
     C                   parm                    $pustr           17
     C                   parm                    $prtn             8
     C                   parm                    $perm
     *
     *                    MOVE $PQSTR    W1QTY  10
     *
     C                   endsr
640bA*----------------------------------------------------------------
640bA*  zzzdricop  Call DRICOP
640bA*----------------------------------------------------------------
640bA
640bAC     zzzdricop     begsr
640bAC                   eval      error = *off
640bA
640bAC                   select
640bAC                   when      $dricommand = '*SLOT'
640bAC                   eval      $dridata = $slot
640bAC                   eval      $dridata2 = $slot2
640bAC                   endsl
640bA
640bAC                   if        $dricommand = '*ITEM'
640bAC                             or $dricommand = '*SLOT'
640bAC                   call(e)   'DRICOP'
640bAC                   parm                    $dricommand
640bAC                   parm                    $drisubcmd
640bAC                   parm                    $drisys2upd
640bAC                   parm      #pgm          $driprogram
640bAC                   parm      ' '           $drireturn
640bAC                   parm      ' '           $drimessage
640bAC                   parm                    $dridata
640bAC                   parm                    $dridata2
640bAC                   else
640bAC                   call(e)   'DRICOP'
640bAC                   parm                    $dricommand
640bAC                   parm                    $drisubcmd
640bAC                   parm                    $drisys2upd
640bAC                   parm      #pgm          $driprogram
640bAC                   parm      ' '           $drireturn
640bAC                   parm      ' '           $drimessage
640bAC                   parm                    $dridata
640bAC                   endif
640bA
640bAC                   select
640bA
640bAC                   when      %error
640bAC                   eval      error = *on
640bA
640bAC                   when      $drireturn <> '*OK'
640bAC                   eval      error = *on
640bA
640bAC                   endsl
640bA
640bAC                   select
640bAC                   when      $dricommand = '*SLOT'
640bAC                   eval      $slot = $dridata
640bAC                   eval      $slot2 = $dridata2
640bAC                   endsl
640bA
640bAC     enddricop     endsr
640bA
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
