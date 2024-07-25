     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, Il 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  SL351     Unverified zero slot with virtual slots info
     *  01 September, 1999
     *  Hemant Kapadia
     *
     *----------------------------------------------------------------
     *  Revisions:
     *   09/01/99  HNK  4.12
     *     - Created
500  *   12/01/04  RH  5.00
     *     - Changed to use SL351A work file to list all related slots
510a *   11/29/07  RH  5.10a
     *     - Enh: Add item # and description for zero item.
     *
640  *   10/24/12  MLB  6.40
     *     - Enh: Converted program to ILE
     *     - Added client custom code support.
640b *   10/24/12  RH   6.40b
     *     - Enh: Add license, remove transfer & receive qty
650a *   08/02/13  RH   6.50a
     *     - Enh: Add extra line before Detail2 in SL351PR
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
500 MFsl351a    ip   e           k disk
500 D*L351   IP  E           K        DISK
     Fslot2     if   e           k disk
     Fwarehs    if   e           k disk
     Fpiritem   if   e           k disk
     Fsl351pr   o    e             printer oflind(*in90)
640 A*----------------------------------------------------------------
640 A*  Customer id
640 A*
640 AD @getcl          c                   const('GETCLIENT')
640 A*
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *                   RPD     1   3 30
     D reck            s              7  0 dim(3)
     *----------------------------------------------------------------
     *  Working variable(s)
     *
     D $plen           s              3  0
     D $pstr           s             60
640bAD error           s              1
     D first           s              1
     D l               s              1  0
     D m               s                   like(l)
     D type            s             11
     D w1qty           s             10
     *----------------------------------------------------------------
     *
     D $perm           ds
     D  xxerm                  1     60
     D  $pmsg                  1      4
     *
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
     *----------------------------------------------------------------
500 D*QREC
500 D*             SLWHSE                          OQWHSE
500 D*             SLWHDP                          OQWHDP
500 D*             SLSTYP                          OQSTYP
500 D*             SLDISP                          OQDISP
500 D*             SLSTAT                          OQSTAT
500 D*             VSDISP                          OQVDSP
500 D*                                             OQDISPL1
500 MIwkrec
500 MI              wkwhse                      oqwhse
500 MI              wkwhdp                      oqwhdp
500 MI              wkstyp                      oqstyp
500 MI              wkdisp                      oqdisp
500 MI              wkstat                      oqstat
500 MI              wkrdsp                      oqrdsp
500 MI              wkrsrv                      oqrsrv
500 MI                                          oqdisp        l1
     *----------------------------------------------------------------
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
     *  Level 1 break - Customer
     *
     C                   if        *inl1
510a *  Get item # and description
510a C     slkeyp        chain     slot2                              79
510a C                   if        not *in79
510a C     keyit         chain     piritem                            78
510a C                   if        *in78
510a C                   eval      itdesc = *blanks
510a C                   endif
510a C                   else
510a C                   eval      slitem = *blanks
510a C                   eval      itdesc = *blanks
510a C                   endif
     C                   write     detail2
     C                   endif
     *
     *
     *  Init total levels
     *
     *
     *  Level 1 break - Customer
     *
     C                   if        *inl1
     C                   eval      l = 1
     C                   exsr      zrzero
     C                   endif
     *
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     * GET DETAILS FOR VIRTUAL SLOT
     *
     C     slkey         chain     slot2                              79
     C                   if        *in79
     C                   eval      slstk1 = 0
     C                   eval      slstk2 = 0
     C                   eval      slstk3 = 0
     C                   eval      slalc1 = 0
     C                   eval      slalc2 = 0
     C                   eval      slalc3 = 0
     C                   eval      sltfr1 = 0
     C                   eval      sltfr2 = 0
     C                   eval      sltfr3 = 0
     C                   eval      slpck1 = 0
     C                   eval      slpck2 = 0
     C                   eval      slpck3 = 0
     C                   eval      slrcv1 = 0
     C                   eval      slrcv2 = 0
     C                   eval      slrcv3 = 0
     C                   eval      slitem = *blanks
     C                   endif
     *
     *  Calculate Qty available (stock + rcv) - (aloc + pick + trans)
     *
     *    Create a quantity string to print.
     *
     C                   call      'SLOTQTY'
     C                   parm                    slstk1
     C                   parm                    slstk2
     C                   parm                    slstk3
     *
     C                   parm                    slalc1
     C                   parm                    slalc2
     C                   parm                    slalc3
     *
     C                   parm                    sltfr1
     C                   parm                    sltfr2
     C                   parm                    sltfr3
     *
     C                   parm                    slpck1
     C                   parm                    slpck2
     C                   parm                    slpck3
     *
     C                   parm                    slrcv1
     C                   parm                    slrcv2
     C                   parm                    slrcv3
     *
     C                   parm                    stock1            5 0
     C                   parm                    stock2            3 0
     C                   parm                    stock3            3 0
     *
     C                   parm                    avail1            5 0
     C                   parm                    avail2            3 0
     C                   parm                    avail3            3 0
     *
     C                   eval      $pcmd = '*QTY2STR'
     C                   eval      $pqty1 = avail1
     C                   eval      $pqty2 = avail2
     C                   eval      $pqty3 = avail3
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
     C                   eval      w1qty = $pqstr
     *
640b *
640b *  Get License
640bAC                   exsr      clr$slot
640bAC                   eval      $slwhseu = *on
640bAC                   eval      $slwhse  = slwhse
640bAC                   eval      $slwhdpu = *on
640bAC                   eval      $slwhdp  = slwhdp
640bAC                   eval      $sldispu = *on
640bAC                   eval      $sldisp  = sldisp
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
     *
     *
     *  Get item description.
     *
     C     keyit         chain     piritem                            79
     C                   if        *in79
     C                   eval      itdesc = *blanks
     C                   endif
     *
     *  Write detail line.
     *
     C                   write     detail1
     *
     *  Increment record counters
     *
     C                   add       1             reck(1)
     *
     *  Set off top-of-page indicators
     *
     C                   eval      first = *off
     C                   eval      *in91 = *off
     *----------------------------------------------------------------
     *
     * Customer totals
     *
     CL1                 eval      l = 1
     CL1                 exsr      zrroll
     *
     *----------------------------------------------------------------
     *
     * REPORT TOTALS
     *
     CLr                 eval      l = 2
     *
     CLr                 if        reck(l) > 0
     CLr                 write     skip1
     CLr                 write     foot1
     CLr                 endif
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
640 A*
640 A* Get client id.
640 A*
640 AC                   call      @getcl
640 AC                   parm                    client           10
640 AC                   parm                    clientloc        10
640 A*
     *
     *  Define key for main file.
     *
     C     keyit         klist
     C                   kfld                    slwhse
     C                   kfld                    slitem
     *
500 D** Define key for SLOT file. (USE VIRTUAL SLOT NUMBER)
500 M*  Define key for SLOT file. (USE RELATED SLOT NUMBER)
     *
     C     slkey         klist
     C                   kfld                    oqwhse
     C                   kfld                    oqwhdp
500 MC                   kfld                    oqrdsp
500 D*R                   KFLD           OQVDSP
     *
510a *  Define key for SLOT file. (USE PHYSICAL SLOT NUMBER)
510a *
510a C     slkeyp        klist
510a C                   kfld                    oqwhse
510a C                   kfld                    oqwhdp
500a C                   kfld                    oqdisp
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
     C     zrfrmt        begsr
     *
     *   Get warehouse description.
     *
     C                   eval      whse = *blanks
     C                   eval      $pstr = *blanks
     C     oqwhse        chain     warehs                             79
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
     C     oqwhdp        cat       '/':0         type
     C                   if        oqstyp = 'P'
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
