610aA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  IT391     Expired items report
     *  27 October, 1994
     *  Dave Sommerville
     *  Hemant Kapadia
     *
     *  Revisions:
     *    08/01/96  RH   2.14
     *      - Display date and option for prev expired items Y,N
414a *    08/25/00  RRH  4.14a
     *      - Recompile, key for IT391 file changed.
415a *    03/26/01  RRH  4.15a
     *      - Add From Date (WOFROM)and parm $TODAY
417a *    09/15/03  RH   4.17a
     *      - Recompile, key to IT391 file changed
     *      - Add buyer # to print out.
     *
610a *    10/12/10  GJA  6.10a
     *      - Converted to RPGLE
700a *    09/16/15  RH   7.00a
     *      - ENH: Display user days for all items, not just mfg item
700b *    10/13/15  RH   7.00b
     *      - ENH: Display Mfg shelf days for all items,
     *      - FIX: Clear L1MFGD after detail 1, was printing previous
     *        line data.
     *
     *----------------------------------------------------------------
     *  Custom Client Revisions:  Glazier
     *
GFCa *    10/12/10  GJA  GFCa
     *      - Enh:  add additional columns
     *              add license tracking to pick slots
GFCb *    04/11/11  GJA  GFCb
     *      - Enh:  Because returns are not updating SLEXPD still
     *              need to get additional columns
     *----------------------------------------------------------------
     *  Client Custom Revisions: H&M Wagner
     *
HMWa *    01/08/17  RH   HMWa
     *      -  Enh: Revised program to print Mfg shelf and user days
     *         for items not mfg dated.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Not on file/End of file indicator
     *  90        Overflow Indicator
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fit391     ip   e           k disk
     Fwarehs    if   e           k disk
GFCaAFitemmsc   if   e           k disk
GFCaAFlicactive1if   e           k disk
     Fit391pr   o    e             printer oflind(*in90)
500zA*----------------------------------------------------------------
500zA*  Customer id
500zA*
HMWaA /COPY QCOPYSRC,ID#hmwagne
     *----------------------------------------------------------------
     *  Table and array definitions
     *
214 AD desc            s             35    dim(2) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Called program
     *
     D @cvtdt          c                   const('CVTDTE')
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
     *
     D $perm           ds
     D  xxerm                  1     60
     D  $pmsg                  1      4
     *----------------------------------------------------------------
     * Variables
GFCaAD expdate         s               d
GFCaAD mfgdate         s               d
GFCaAD mfgdiff         s              3  0
GFCaAD forever         s              1
     D $plen           s              3  0
     D $pstr           s             60
     D first           s              1
     D svbnbr          s              3  0
     D svitem          s             15
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
214 AC                   parm                    $pexp             1
214 AC                   parm                    $nexp             8
415aAC                   parm                    $today            8
     *
     *  Report Heading
     *
     *
     C                   if        *in90  or
     C                             first = '1'
     C                   exsr      zrhead
     C                   endif
     *
     * Detail Calcs
     *
417aA*   Supress buyer# if buyer did not change.
417aAC                   if        imbnbr = svbnbr
417aAC                   eval      w1bnbr = *zeros
417aAC                   else
417aAC                   move      imbnbr        w1bnbr
417aAC                   endif
     *
414aA*   Supress item # if item did not change.
414aAC                   if        slitem = svitem
414aAC                   eval      w1item = *blanks
414aAC                   else
414aAC                   eval      w1item = slitem
414aAC                   endif
     *
     *   Convert entered date.
     *
     C                   if        slentd = 0
     C                   eval      w1entd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      slentd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1entd = $cvd6o
     C                   endif
     *
     *   Convert expired date.
     *
     C                   if        slexpd = 0
     C                   eval      w1expd = 0
700aAC                   eval      w1uday = *zeros
700bAC                   eval      w1mday = *zeros
GFCbAC     keymsc        chain     itemmsc
GFCbAC                   if        %found(itemmsc)
700aAC                   eval      w1uday = imuday
700bAC                   eval      w1mday = immday
GFCbAC                   if        immflg = 'Y'
700bDC*                  eval      w1mday = immday
700aDC*                  eval      w1uday = imuday
700bDC*                  else
700bDC*                  eval      w1mday = *zeros
700aDC*                  eval      w1uday = *zeros
GFCbAC                   endif
HMWaAC                   if        client = hmwagner
HMWaAC                   eval      w1mday = immday
HMWaAC                   eval      w1uday = imuday
HMWaAC                   endif
GFCbAC                   endif
GFCaAC                   eval      w1mfgd = *blanks
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      slexpd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
GFCaAC                   eval      w1expd = $cvd6o
GFCaAC                   eval      expdate = %date(slexpd)
700aAC                   eval      w1uday = *zeros
GFCaAC     keymsc        chain     itemmsc
GFCaAC                   if        %found(itemmsc)
700aAC                   eval      w1uday = imuday
GFCaAC                   if        immflg = 'Y'
GFCaAC                   eval      mfgdiff = immday - imuday
GFCaAC                   eval      mfgdate = expdate - %days(mfgdiff)
GFCaAC     *MDY          move      mfgdate       w1mfgd
GFCaAC                   eval      w1mday = immday
700aDC*                  eval      w1uday = imuday
GFCaAC                   else
GFCaAC                   eval      w1mday = *zeros
700aDC*                  eval      w1uday = *zeros
GFCaAC                   eval      w1mfgd = *blanks
GFCaAC                   endif
HMWaAC                   if        client = hmwagner
HMWaAC                   eval      w1mday = immday
HMWaAC                   eval      w1uday = imuday
HMWaAC                   endif
GFCaAC                   endif
     C                   endif
     *
     *   Calculate available quantities.
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
     *    Create a quantity string to print.
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
     C                   eval      qtavl = $pqstr
     *
     *   Print detail line.
     *
     C                   write     detail1
     *
     *   Check for pick slot and get license
     *
GFCaAC     keylic        setll     licactive1
GFCaAC                   dow       forever = forever
GFCaAC     keylic        reade     licactive1
GFCaAC                   if        not %EOF(licactive1)
700bAC                   eval      l1mfgd = *blanks
700bAC                   eval      l1expd = *zeros
GFCaAC                   if        laexpd <> 0
GFCaAC                   if        immflg = 'Y'
GFCaAC                   eval      expdate = %date(laexpd)
GFCaAC                   eval      mfgdate = expdate - %days(mfgdiff)
GFCaAC     *MDY          move      mfgdate       l1mfgd
GFCaAC                   else
GFCaAC                   eval      l1mfgd = *blanks
GFCaAC                   endif
GFCbAC                   eval      $cvcmd = '*CMDMDY '
GFCbAC                   move      laexpd        $cvd8i
GFCbAC                   call      @cvtdt
GFCbAC                   parm                    $cvtdt
GFCbAC                   eval      l1expd = $cvd6o
GFCaAC                   else
GFCaAC                   eval      l1expd = *zeros
GFCaAC                   endif
GFCaAC                   eval      l1lcns = lalcns
GFCbAC                   if        laentd <> 0
GFCbAC                   eval      $cvcmd = '*CMDMDY '
GFCbAC                   move      laentd        $cvd8i
GFCbAC                   call      @cvtdt
GFCbAC                   parm                    $cvtdt
GFCbAC                   eval      l1entd = $cvd6o
GFCbAC                   else
GFCbAC                   eval      l1entd = *zeros
GFCbAC                   endif
     *
     *    Create a quantity string to print.
     *
     C                   eval      $pcmd = '*QTY2STR'
     C                   eval      $pqty1 = laqty1
     C                   eval      $pqty2 = laqty2
     C                   eval      $pqty3 = laqty3
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
     C                   eval      lqtavl = $pqstr
     *
     C                   write     detail2
GFCaAC                   else
GFCaAC                   leave
GFCaAC                   endif
GFCaAC                   enddo
417a C                   eval      svbnbr = imbnbr
     C                   eval      svitem = slitem
     C                   eval      first = *off
     *
     CLr                 write     skip1
     CLr                 write     foot1
     *****************************************************************
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
500zA*
500zA* Get client id.
500zA*
500zAC     *dtaara       define    pirclient     client           10
500zAC                   in        client
     *
     *
GFCaAC     keymsc        klist
GFCaAC                   kfld                    slwhse
GFCaAC                   kfld                    slitem
     *
GFCaAC     keylic        klist
GFCaAC                   kfld                    slwhse
GFCaAC                   kfld                    slwhdp
GFCaAC                   kfld                    sldisp
GFCaAC                   kfld                    slitem
     *
     C                   time                    time
     C                   eval      first = *on
214 A*
214 AC                   if        $pexp = 'Y'
214 AC                   eval      woprev = desc(1)
214 AC                   else
214 AC                   eval      woprev = desc(2)
214 AC                   endif
214 A*
214 AC                   eval      $cvcmd = '*CMDMDY '
214 AC                   eval      $cvd8i = $nexp
214 AC                   call      @cvtdt
214 AC                   parm                    $cvtdt
214 AC                   eval      wodate = $cvd6o
415aA*
415aAC                   eval      $cvcmd = '*CMDMDY '
415aAC                   eval      $cvd8i = $today
415aAC                   call      @cvtdt
415aAC                   parm                    $cvtdt
415aAC                   eval      wofrom = $cvd6o
     *
417aAC                   eval      svbnbr = 0
414aAC                   eval      svitem = *blanks
     C                   endsr
     *****************************************************************
     *
     C     zrhead        begsr
     *
     C                   eval      *in90 = *off
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
     C                   write     head1
     C                   write     columns
     *
     C                   endsr
     *
     *  Compile time tables
     *
**
Include previously expired items
Exclude previously expired items
