     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  SL333     Slot Listing with item/desc- Print.
     *  06 March, 2000
     *  Roxanne Harrison
     *
     *  Revisions:
     *
     *  11/20/01  HNK  4.16
     *   - Recompiled due to change in print file. (Report date added)
     *
610a *  11/04/09  GJA  6.10a
     *   - Enh:  Added license plate to report
530a *  12/17/09  RH   5.30a
     *   - Enh:  Add support for client code.
     *   - Enh:  Print underline for Pick Seq and Type for SGC
640a *  04/19/11  RH   6.40a
     *   - Enh:  Add total available line
640b *  07/22/12  GJA  6.40b
     *   - Enh:  Add LICENSE enter date.  (missed in V6.40 update)
650a *  04/24/11  GJA  6.50a
     *   - Enh:  Add pick slot for researching
650b *  02/12/14  RH   6.50b
     *   - Fix:  Only get pick slot if slot item is not blank
CBIaA*  02/13/18  TDF  Work List 2017038
     *   - TDF: Add "Entered Date" to heading in print file SL333PR
     *
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Graves Menu Maker
GMMaA*    04/01/15  RH   GMMa
     *      - Add to SGC mod to print extra line after detail
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fischer
FFCaA*    10/04/15  RH   FFCa
     *      - Double space detail lines
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
     Fslot1     ip   e           k disk
     Fwarehs    if   e           k disk
     Fpiritem   if   e           k disk
     Fsl333pr   o    e             printer oflind(*in90)
530aA*----------------------------------------------------------------
530aA*  Customer id
530aA*
SGC A /COPY QCOPYSRC,ID#sgc
GMMaA /copy qcopysrc,id#gmm
FFC A /COPY QCOPYSRC,ID#fischer
530aA*
CBIaA /COPY QCOPYSRC,ID#cheney
     *----------------------------------------------------------------
     *  Called programs
     *
640bAD @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
640bAD $cvtdt          ds
640bAD  $cvcmd                 1      8
640bAD  $cvprg                 9     18
640bAD  $cvd6i                19     24
640bAD  $cvd8i                25     32
640bAD  $cvd6o                33     38  0
640bAD  $cvd8o                39     46  0
640bAD  $cvsto                47     64
640bAD  $cvrtn                65     72
640bAD  $cverm                73    132
640bAD  $cvmsg                73     76
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *                   RPD     1   3 30
     D reck            s              7  0 dim(3)
     *----------------------------------------------------------------
     *
     D $perm           ds
     D  xxerm                  1     60
     D  $pmsg                  1      4
     *
610aA*----------------------------------------------------------------
610aA*  DRI parameters
610aA*----------------------------------------------------------------
610aA
610aA /COPY *libl/qcopysrc,C#DRIPARMS

610aA /COPY *libl/qcopysrc,C#SLOT
610aAD savever#        s                   like($slver#)
610aA*----------------------------------------------------------------
610aA*  Program info data structure
610aA*
     D                sds
     D  #prog            *proc
     D  #pgm             *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     * Variables
     *
     D $llen           s              3  0
     D $lstr           s             60
     D $plen           s              3  0
     D $pstr           s             60
610aAD error           s              1
     D first           s              1
     D l               s              1  0
     D m               s                   like(l)
640aAD Taval1          s              7  0
640aAD Taval2          s              5  0
640aAD Taval3          s              5  0
     D type            s              5
     D w1qty           s             10
640aAD w1Tqty          s             15
     *----------------------------------------------------------------
     Islrec
     I                                          slwhse        l1
     I                                          slwhdp        l1
     I                                          slaisl        l1
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
     C                             *in90  or
     C                             *inl1
     C                   exsr      zrhead
     C                   endif
     *
     *
     *  Init total levels
     *
     *
     *  Level 1 break - Whse/Dept/Aisle
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
610aAC                   exsr      clr$slot
610aAC                   eval      $slwhseu = *on
610aAC                   eval      $slwhse  = slwhse
610aAC                   eval      $slwhdpu = *on
610aAC                   eval      $slwhdp  = slwhdp
610aAC                   eval      $sldispu = *on
610aAC                   eval      $sldisp  = sldisp
610aA
610aAC                   eval      $dricommand = '*SLOT'
610aAC                   eval      $drisubcmd  = '%GET'
610aAC                   eval      $drisys2upd = 'D'
610aAC                   exsr      zzzdricop
610aAC                   if        error = *on
610aAC                   eval      error = *off
610bMC                   eval      $saToPos = 0
610aAC                   endif
     *
610aAC                   eval      lcns = $saToLcns
640bA*
640bAC                   if        $slentd <> 0
640bAC                   eval      $cvcmd = '*CMDMDY '
640bAC                   move      $slentd       $cvd8i
640bAC                   call      @cvtdt
640bAC                   parm                    $cvtdt
640bAC                   eval      laentd = $cvd6o
640bAC                   else
640bAC                   eval      laentd = 0
640bAC                   endif
     *
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
640aAC                   add       avail1        Taval1
640aAC                   add       avail2        Taval2
640aAC                   add       avail3        Taval3
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
     *  Get item description.
     *
650bAC                   eval      pckslt = *blanks
650aAC                   if        slpick = 'N'
650bAC                             and slitem <> *blanks
650aAC                   eval      $scmd = '*FIRST  '
650aAC                   call      'GETPSLT'
650aAC                   parm                    $scmd             8
650aAC                   parm      slwhse        $swhse            3 0
650aAC                   parm      slitem        $sitem           15
650aAC                   parm      *blanks       woslot           12
650aAC                   parm      *blanks       $saisl            3
650aAC                   parm      *zeros        $sloc             3 0
650aAC                   parm      *zeros        $srlvl            2 0
650aAC                   parm      *blanks       $shand            2
650aAC                   parm      *blanks       $srtn             8
650aA*
650aAC                   if        $srtn = '*OKPICK '
650aAC                   eval      pckslt = woslot
650aAC                   else
650aAC                   eval      pckslt = '*NONE       '
650aAC                   endif
650aAC                   endif
     *
     *  Write detail line.
     *
     C                   write     detail1
SGCaAC                   if        client = sgc or
FFCaAC                             client = fischerfoods or
GMMaAC                             client = menumaker
SGCaAC                   write     skip1
SGCaAC                   endif
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
     * Whse/Dept/Aisle totals
     *
     *
640aACL1                 eval      $pcmd = '*QTY2STR'
640aACL1                 eval      $pqty1 = Taval1
640aACL1                 eval      $pqty2 = Taval2
640aACL1                 eval      $pqty3 = Taval3
640aACL1                 eval      $pqstr = *blanks
640aA*
640aACL1                 call      'CVTQTY'
640aACL1                 parm                    $pcmd             8
640aACL1                 parm                    $pprg            10
640aACL1                 parm                    $pqty1            7 0
640aACL1                 parm                    $pqty2            7 0
640aACL1                 parm                    $pqty3            7 0
640aACL1                 parm                    $pum1             2
640aACL1                 parm                    $pum2             2
640aACL1                 parm                    $pum3             2
640aACL1                 parm                    $pqstr           10
640aACL1                 parm                    $pustr           17
640aACL1                 parm                    $prtn             8
640aACL1                 parm                    $perm
640aA*
640aACL1                 eval      w1tqty = $pqstr
     *
640aACL1                 write     total1
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
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
530aA*
530aA* Get client id.
530aA*
530aAC                   call      'GETCLIENT'
530aAC                   parm                    client           10
530aAC                   parm                    clientloc        10
     *
     *  Define key for main file.
     *
     C     keyit         klist
     C                   kfld                    slwhse
     C                   kfld                    slitem
     *
SGC AC                   if        client = sgc
SGC  C                   eval      *in65 = *on
SGC AC                   else
SGC  C                   eval      *in65 = *off
SGC AC                   endif
     *
CBIaAC                   if        client = Cheney
CBIaAC                   eval      *in38 = *on
CBIaAC                   else
CBIaAC                   eval      *in38 = *off
CBIaAC                   endif
     C                   time                    time
     C                   eval      first = *on
     C                   eval      l = 2
     C                   exsr      zrzero
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrfrmt        begsr
     *
     *   Get warehouse description.
     *
     C                   eval      whse = *blanks
     C                   eval      $pstr = *blanks
     C     slwhse        chain     warehs                             79
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
     *  Format Dept/Section/Aisle
     *
     C                   if        slstyp = 'P'
     C                   eval      type = 'PIR  '
     C                   else
     C                   if        slstyp = 'F'
     C                   eval      type = 'Fixed'
     C                   else
     C                   eval      type = '*None'
     C                   endif
     C                   endif
     C                   eval      p#desc = *blanks
     C     'Type:'       cat       type:1        p#desc
     C     p#desc        cat       'Dept:':2     p#desc
     C     p#desc        cat       slwhdp:1      p#desc
     C     p#desc        cat       'Aisle':2     p#desc
     C     p#desc        cat       ':':0         p#desc
     C                   if        slaisl = *blanks
     C     p#desc        cat       '*NONE':1     p#desc
     C                   else
     C     p#desc        cat       slaisl:1      p#desc
     C                   endif
     C                   movel     p#desc        $lstr
     C                   eval      $llen = 40
     C                   call      'CENTER'
     C                   parm                    $lstr
     C                   parm                    $llen
     C                   movel     $lstr         p#desc
     *
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
640aAC                   eval      taval1 = 0
640aAC                   eval      taval2 = 0
640aAC                   eval      taval3 = 0
     *
     C                   endsr
610aA*----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   endsr


610aA*----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      %error
     C                   eval      error = *on

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   endsl

     C     enddricop     endsr

     *----------------------------------------------------------------
     *
     * Compile time tables
     *
