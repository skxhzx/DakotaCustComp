650aAH OPTION(*NODEBUGIO)
650aAH DFTACTGRP(*NO) ACTGRP(*CALLER)
      *
      *************************************************
     *   Copy of ITP972 change to only print diff >= 5
      *************************************************
     *
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IT972   Item Quantity Compare Report - Print by Whs/Dept/Item
     *  14 March 2013
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *
650a *    03/14/13  RTR  6.50a
     *      - Created from IT971 to leave IT971 unchanged for Glazier
     *      - Base mods combined, custom mods left for future use.
     *      - Glazier mods also left in case they want to use later.
650bA*    03/15/13  MLB  6.50b
     *      - Fix: Revised pgm to loop through IMPFCQTY file looking for
     *        Alias and SameSlotBrkDown items and if found, add the qty
     *        sent with the item, to the parent item.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Glazier Foods
     *
GFCa *    09/30/10  MLB  GFCa
     *      - Revised program to call CHKLIVE to only process items
     *        for active departments.
GFCbA*    05/22/12  GJA  GFCb
     *    - Enh: Revised program to pass warehouse number to pgm, CHKLIVE.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Inter-County Bakers
     *
ICBa *    07/17/12  GJA  ICBa
     *      - Revised program to get PO's not exported to host yet
     *      - Added file PODTL5 to pgm.
ICBbA*    03/28/13  MLB  ICBb
     *      - Revised to convert breakdown percentage to units like
     *       in program HQ245.
     *      - Added ICBb to GMM mod.
ICBcA*    03/28/13  MLB  ICBc
     *      - Revised pgm to roll-up qty for type A, B and S items
     *        into the parent/base item number in the IMPFCQTY file.
     *        HK's Host system does not have any method to identify
     *        between Alias, Breakdown or SSB items.
     *      - Added ICBc to HKW mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Grave's Menu Maker
     *
GMM A*    03/14/13  MLB  GMM
     *      - Revised to convert breakdown percentage to units like
     *       in program HQ245.
GMMaA*    03/28/13  MLB  GMMa
     *      - Revised pgm to roll-up qty for type A, B and S items
     *        into the parent/base item number in the IMPFCQTY file.
     *        HK's Host system does not have any method to identify
     *        between Alias, Breakdown or SSB items.
     *      - Added GMMa to HKW mod.
GMMbA*    03/28/13  MLB  GMMb
     *      - Change to mod GMM. Removed code that converted eaches
     *        for type B items. Just convert eaches and send it back.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Hearn Kirkwood
     *
HKW A*    03/15/13  MLB  HKW
     *      - Revised pgm to roll-up qty for type A, B and S items
     *        into the parent/base item number in the IMPFCQTY file.
     *        HK's Host system does not have any method to identify
     *        between Alias, Breakdown or SSB items.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     * File Specs
     *
650bDF*impfcqty  if   e           k disk
650bMFimpfcqty  uf a e           k disk
     Fitemqty   if   e           k disk
650bAfitemlnk   if   e           k disk
650aAfitemlnk1  if   e           k disk    usropn
650aAf                                     rename(ilrec:ilrec1)
650aAFpiritem1  if   e           k disk
     Fpiritem   if   e           k disk
650aAf                                     prefix(i2)
650aAf                                     rename(itrec:itrec2)
     Freports   if   e           k disk
     Fwarehs    if   e           k disk
     Fslot3     if   e           k disk
ICBaDF*podtl     if   e           k disk
ICBaMFpodtl5    if   e           k disk
     Fit972pr   o    e             printer oflind(*in91)
     *----------------------------------------------------------------
     *  Customer id
     *
GFCaA /copy qcopysrc,id#glazier
ICBaA /copy qcopysrc,id#icb
650aA /copy qcopysrc,id#gmm
650aA /copy qcopysrc,id#gmmvini
650aA /copy qcopysrc,ipqmem_gmm
HKW A /copy qcopysrc,id#hkw
     *
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a30             s              1    dim(30)
     D desc            s             60    dim(2) ctdata perrcd(1)
     *
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

     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
650aA*----------------------------------------------------------------
650aA*  Sub Procedure Prototypes
650aA*----------------------------------------------------------------
650aA
650aAd prCvtBrkQty     pr
650aAd  gbrkpct                       7s 3 const
650aAd  gipqqp1                       7s 0
650aAd  gipqqp2                       7s 0
650aAd  gadjitm                      15a
650aA
     *
     *----------------------------------------------------------------
     *  Working Variables
     *
     D addflg          s              1
     D chgflg          s              1
     D count           s              3  0
     D error           s              1
     D first           s              1
     D forever         s              1
650aAd gBrkPct         s              7s 3
650aAd gIpqQp1         s              7s 0
650aAd gIpqQp2         s              7s 0
650aAd gAdjItm         s             15a
     D grdord          s              5  0
     D k3pick          s              1
     D k3stat          s              2
     D len             s              1  0
     D linppg          s              3  0
     D pflag           s              1
     D pos             s              1  0
650aAd svUmq2          s                   like(itumq2)
650aAd svUmq3          s                   like(itumq3)
650bAd svItem          s                   like(icitem)
HKW Ad svStk1          s                   like(iqstk1)
HKW Ad svStk2          s                   like(iqstk2)
HKW Ad svStk3          s                   like(iqstk3)
650bAd svTqh1          s                   like(ictqh1)
650bAd svTqh2          s                   like(ictqh2)
650bAd svTqh3          s                   like(ictqh3)
     D whs#            s              3  0
     D work3a          s              3
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $CMD    *EXCPTN - Print only exceptions
     *      $WHSE   Warehouse
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $whse             3
     *
     * Main line
     *
650bA* Look for Alias or SSB items, and add qty to parent item.
650bAC                   exsr      zzrollupHost
650bA*
     * Whip through all the Item records
     *
     C                   eval      first = *on
650aDC**   whs#          setll     itemqty
650aMC     whs#          setll     piritem1
     C                   dow       forever = forever
     *
650aDC**   whs#          reade     itemqty
650aMC     whs#          reade     piritem1
     C*                  eval      error = *off
650aDC**                 if        %eof(itemqty)
650aMC                   if        %eof(piritem1)
     C                   leave
     C                   endif
HKW A*
HKW AC                   if        client = Hearnkirkwood
GMMaAC                             or client = Menumaker
ICBcAC                             or client = ICB
HKW A*
HKW A*      Bypass non-regular items types.
HKW AC                   if           ittype = 'A'
HKW AC                             or ittype = 'B'
HKW AC                             or ittype = 'S'
HKW AC                   iter
HKW AC                   endif
HKW A*
HKW AC                   endif
HKW A*
     *
     *  First time through
     *
     C                   if        first = *on
650aAC                   eval      h1dept = itwhdp
     C                   exsr      zzinz2
     C                   eval      first = *off
     C                   endif
     *
     *  Get item quantity
     *
650aAC     keyit         chain     itemqty
650aAC                   if        not %found(itemqty)
650aAC                   eval      iqstk1 = 0
650aAC                   eval      iqstk2 = 0
650aAC                   eval      iqstk3 = 0
650aAC                   endif
HKW A*
HKW AC                   if        client = Hearnkirkwood
GMMaAC                             or client = Menumaker
ICBcAC                             or client = ICB
HKW A*
HKW A*      Add up Alias, Breakdown or SSB item qty's.
HKW AC                   exsr      zzrollupWMS
HKW A*
HKW AC                   endif
HKW A*
     *
     *  Get matching import quantity record
     *
650bDC*    keyit         chain     impfcqty
650bMC     keyit         chain (n) impfcqty
     C                   if        not %found(impfcqty)
     C                   eval      ictqh1 = 0
     C                   eval      ictqh2 = 0
     C                   eval      ictqh3 = 0
     C                   endif
GMM A*
GMM AC                   if        client = Menumaker
ICBbAC                             or client = ICB
GMM AC                   select
    AC                   when      ictqh2 > 0
GMM A*
GMM AC                   eval      gAdjItm = icitem
GMM AC                   eval      gBrkPct = ictqh2 * .001
GMM AC                   eval      gIpqQp1 = ictqh1
GMM AC                   eval      gIpqQp2 = ictqh2
GMM A /free
GMM A     prCvtBrkQTy(gBrkPct: gIpqQp1: gIpqQp2: gAdjItm);
GMM A /end-free
GMM AC                   eval      ictqh1 = gIpqQp1
GMM AC                   eval      ictqh2 = gIpqQp2
GMM A*
GMM AC                   endsl
GMM A*
GMM AC                   endif
ICBaA*
ICBaAC                   if        client = ICB
ICBaA*      Add open p/o qty to Host On-hand qty.
ICBaAC                   exsr      zzaddpoqty
ICBaAC                   endif
     *
     *  Calculate differences between host and Dakota qty's
     *  If no differences, don't print
     *
     C                   exsr      zzcalc
     C                   if        diff1 = 0 and diff2 = 0
     C                             and diff3 = 0
     C                   goto      skipiq
     C                   endif
     *
     *  Get pick slot
     *
     C                   eval      k3pick = 'Y'
     C                   eval      k3stat = 'A '
     C     keysl         chain     slot3
     C                   if        not %found(slot3)
     C                   eval      sldisp = *blanks
     C                   endif
     *
     *  Write detail
     *
     C                   if        *in91 = '1'
650aAC                             or itwhdp <> h1dept
650aAC                   eval      h1dept = itwhdp
     C                   write     head1                                91
     C                   endif
     *
DWWA C                   if        diff1 > 4
DWWa C                   write     detail                               91
DWWA C                   endif
     *
     C     skipiq        tag
     C                   enddo
     *
     * Whip through the import item records and print those with no
     * match to itemqty
     *
     C                   eval      first = *on
     C     whs#          setll     impfcqty
     C                   dow       forever = forever
     *
650bDC*    whs#          reade     impfcqty
650bMC     whs#          reade (n) impfcqty
     C                   eval      error = *off
     C                   if        %eof(impfcqty)
     C                   leave
     C                   endif
     *
     *  First time through
     *
     C                   if        first = *on
     C                   exsr      zzinz3
     C                   eval      first = *off
     C                   endif
     *
     *  Look for matching itemqty record, if not found, print exception
     *
     C     keyiq         chain     itemqty
     C                   if        not %found(itemqty)
     C                   if        *in91 = '1'
     C                   write     head2                                91
     C                   endif
     C                   write     detail2                              91
     C                   endif
     *
     C                   enddo
     *
     *  Print grand totals
     *
     C                   if        *in91 = *on
     C                   write     head1                                91
     C                   endif
     C                   write     foot1                                91
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
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
650aA*
650aAC                   if        not %open(itemlnk1)
650aAC                   open      itemlnk1
650aAC                   endif
     *
     *  Variables and constants.
     *
     C                   eval      forever = *off
     *
     *  Convert today's date into MMDDYY format.
     *
     C                   eval      $cvcmd = '*CURMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      rdate = $cvd6o
     C                   time                    rtime
     *
     C                   eval      $lprg = #prog
     C                   move      $whse         whs#
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCALC   Calculate differences between host and Dakota qty's
     *
     C     zzcalc        begsr
     *
     C                   eval      diff1 = ictqh1 - iqstk1
     C                   eval      diff2 = ictqh2 - iqstk2
     C                   eval      diff3 = ictqh3 - iqstk3
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
650bA*
650bA*  Define full key for IMPFCQTY file.
650bA*
650bAC     keyic         klist
650bAC                   kfld                    whs#
650bAC                   kfld                    ilitm2
650bA*
650bAC     keyicreset    klist
650bAC                   kfld                    whs#
650bAC                   kfld                    svitem
     *
     *  Define key for piritem and import qty files.
     *
     C     keyit         klist
     C                   kfld                    whs#
     C                   kfld                    ititem
650bAC     itkey         klist
650bAC                   kfld                    whs#
650bAC                   kfld                    icitem
650aA*
650aA* Define Full key for PIRITEM file
650aA*
650aAc     keyitcvt      klist
650aAc                   kfld                    whs#
650aAc                   kfld                    gAdjItm
650aA*
650aA* ITEMLINK1 Partial file key
650aA*
650aAc     keyil1        klist
650aAc                   kfld                    whs#
650aAc                   kfld                    icitem
HKW Ac     keyil1a       klist
HKW Ac                   kfld                    whs#
HKW Ac                   kfld                    ilitem
ICBaA*
ICBaA*  Define partial key for PODTL5 file.
ICBaA*
ICBaAC     keypd         klist
ICBaAC                   kfld                    whs#
ICBaAC                   kfld                    ititem
     *
     *  Define key for slot file.
     *
     C     keysl         klist
     C                   kfld                    whs#
     C                   kfld                    ititem
     C                   kfld                    k3stat
     C                   kfld                    k3pick
     *
     * Get report heading.
     *
     C                   eval      w1head = *blanks
     C                   movel     'IT972PR'     rpprtf
     C     rpprtf        chain     reports                            79
     C                   if        not *in79
     C                   movel     rpdesc        $pstr
     C                   else
     C                   eval      $pstr = desc(1)
     C                   endif
     C                   eval      $plen = 60
     *
     C                   call      'CENTER'
     C                   parm                    $pstr            60
     C                   parm                    $plen             3 0
     C                   movel     $pstr         w1head
     *
     *   Get warehouse description.
     *
     C     whs#          chain     warehs
     C                   if        not %found(warehs)
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *   Create warehouse heading.
     *
     C                   move      whs#          work3a
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
     *   Write headings
     *
     C                   write     head1
     *
     *   Get options.
     *
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ3   Program initialization. Called from main line.
     *
     C     zzinz3        begsr
     *
     *  Define key for item quantity file.
     *
     C     keyiq         klist
     C                   kfld                    whs#
     C                   kfld                    icitem
     *
     * Get report heading.
     *
     C                   eval      w2head = *blanks
     C                   eval      $pstr = desc(2)
     C                   eval      $plen = 60
     *
     C                   call      'CENTER'
     C                   parm                    $pstr            60
     C                   parm                    $plen             3 0
     C                   movel     $pstr         w2head
     *
     *   Write headings
     *
     C                   write     head2
     *
     *   Get options.
     *
     *
     C                   endsr
650bA*
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZROLLUPHOST   Roll-up Qty's sent for Alias or SSB items into Parent.
650bA*
650bAC     zzrollupHost  begsr
650bA*
650bAC     whs#          setll     impfcqty
650bAC                   dow       forever = forever
650bAC     whs#          reade     impfcqty
650bAC                   if        %eof(impfcqty)
650bAC                   leave
650bAC                   endif
650bA*
650bAC     itkey         chain     piritem
650bAC                   select
HKW AC                   when      %found(piritem)
HKW AC                             and client = Hearnkirkwood
HKW AC                             and i2ittype = ' '
HKW A*      Wrong item type, read next record.
HKW A*      Allow type A, B or S items to be processed.
HKW AC                   iter
HKW A*
HKW AC                   when      %found(piritem)
HKW AC                             and client = Hearnkirkwood
HKW AC                             and (i2ittype = 'A'
HKW AC                               or i2ittype = 'B'
HKW AC                               or i2ittype = 'S')
HKW A*      Allow type A, B or S items to be processed.
HKW A*
650bA*      Wrong item type, read next record.
650bAC                   when      %found(piritem)
650bAC                             and i2ittype <> 'A'
650bAC                             and i2ittype <> 'S'
650bA*      Wrong item type, read next record.
650bAC                   iter
650bAC                   endsl
650bA*
650bA*      Retrieve parent/base item number.
650bAC     keyil1        chain     itemlnk
650bAC                   if        %found(itemlnk)
650bA*
650bA*      Found Alias or SSB item, proceed to roll-up qty.
650bAC                   eval      svitem = icitem
650bAC                   eval      svtqh1 = ictqh1
650bAC                   eval      svtqh2 = ictqh2
650bAC                   eval      svtqh3 = ictqh3
650bA*
650bAC                   delete    icrec
650bA*
650bA*      Find parent/base item and update saved qty's.
650bAC     keyic         chain     impfcqty
650bAC                   if        %found(impfcqty)
650bAC                   select
650bAC                   when         i2ittype = 'S'
HKW AC                             or i2ittype = 'B'
650bAC                   eval      ictqh2 = ictqh2 + svtqh1
650bAC                   other
650bAC                   eval      ictqh1 = ictqh1 + svtqh1
650bAC                   eval      ictqh2 = ictqh2 + svtqh2
650bAC                   eval      ictqh3 = ictqh3 + svtqh3
650bAC                   endsl
650bAC                   update    icrec
650bA*
650bAC                   else
650bA*
650bA*      Parent/base item not in import file. Add record.
650bAC                   eval      icwhse = whs#
650bAC                   eval      icitem = ilitm2
650bAC                   select
650bAC                   when         i2ittype = 'S'
HKW AC                             or i2ittype = 'B'
650bAC                   eval      ictqh1 = 0
650bAC                   eval      ictqh2 = svtqh1
650bAC                   eval      ictqh3 = 0
650bAC                   other
650bAC                   eval      ictqh1 = svtqh1
650bAC                   eval      ictqh2 = svtqh2
650bAC                   eval      ictqh3 = svtqh3
650bAC                   endsl
650bA*
650bAC                   write     icrec
650bAC                   endif                                                  Endif-Chain impfcqty
650bA*
650bA*      Re-position file pointer to next item, not parent.
650bAC     keyicreset    setgt     impfcqty
650bA*
650bAC                   endif                                                  Endif-Chain itemlnk
650bA*
650bAC                   enddo
650bA*
650bAC                   endsr
HKW A*
HKW A*----------------------------------------------------------------
HKW A*
HKW A*  ZZROLLUPWMS   Roll-up Qty's sent for Breakdown or SSB items into Parent.
HKW A*
HKW AC     zzrollupWms   begsr
HKW A*
HKW AC                   eval      svitem = iqitem
HKW AC                   eval      svstk1 = iqstk1
HKW AC                   eval      svstk2 = iqstk2
HKW AC                   eval      svstk3 = iqstk3
HKW AC     keyit         setll     itemlnk1
HKW AC                   dow       forever = forever
HKW AC     keyit         reade     itemlnk1
HKW AC                   if        %eof(itemlnk1)
HKW AC                   leave
HKW AC                   endif
HKW A*
HKW AC     keyil1a       chain     piritem
HKW AC                   select
HKW AC                   when      %found(piritem)
HKW AC                             and (i2ittype = 'A'
HKW AC                              or  i2ittype = 'S')
HKW A*      Wrong item type, read next record.
HKW AC                   iter
HKW A*
HKW A*      Breakdown item, roll-up qty to parent/base item.
HKW AC                   when      %found(piritem)
HKW AC                             and i2ittype = 'B'
HKW A*
HKW A*      Retrieve parent/base item number.
HKW AC     keyil1a       chain     itemqty
HKW AC                   if        %found(itemqty)
HKW AC                   eval      svstk2 = svstk2 + iqstk1
HKW AC                   endif
HKW AC                   endsl
HKW A*
HKW AC                   enddo
HKW A*
HKW AC                   eval      iqitem = svitem
HKW AC                   eval      iqstk1 = svstk1
HKW AC                   eval      iqstk2 = svstk2
HKW AC                   eval      iqstk3 = svstk3
HKW A*
HKW AC                   endsr
ICBaA*
ICBaA*----------------------------------------------------------------
ICBaA*
ICBaA*  ZZADDPOQTY   Add open p/o qty to Host On-Hand Qty.
ICBaA*
ICBaAC     zzaddpoqty    begsr
ICBaA*
ICBaAC     keypd         setll     podtl5
ICBaAC                   dow       forever = forever
ICBaAC     keypd         reade     podtl5
ICBaAC                   select
ICBaAC                   when      %eof(podtl5)
ICBaAC                   leave
ICBaAC
ICBaAC                   other
ICBaAC
ICBaAC                   eval      ictqh1 = ictqh1 + pdqrc1
ICBaAC                   eval      ictqh2 = ictqh2 + pdqrc2
ICBaAC                   eval      ictqh3 = ictqh3 + pdqrc3
ICBaAC                   endsl
ICBaAC
ICBaAC                   enddo
ICBaA*
ICBaAC                   endsr
GMM A*
GMM A*----------------------------------------------------------------
GMM A*
GMM A*  prCvtBrkQty - Convert brkdwn percentage into eaches qty.
GMM AA*
GMM Ap prCvtBrkQty     b
GMM Ad  prCvtBrkQty    pi
GMM Ad   gBrkPct                      7s 3 const
GMM Ad   gIpqQp1                      7s 0
GMM Ad   gIpqQp2                      7s 0
GMM Ad   gAdjItm                     15a
GMM A*
GMM AC                   eval      svumq2 = itumq2
GMM AC                   eval      svumq3 = itumq3
GMM A*
GMM A*      Find Eaches item number for Parent/Base item.
GMM AC     keyil1        setll     itemlnk1
GMM AC     keyil1        reade     itemlnk1
GMM AC                   if        %eof(itemlnk1)
GMM AC                   eval      gAdjItm = icitem
GMM AC                   else
GMM AC                   eval      gAdjItm = ilitem
GMM AC                   endif
GMM A*
GMM A*      Retrieve each item number to determine Item Type (ITTYPE)
GMM AC     keyitcvt      chain     piritem
GMM AC                   select
GMM AC                   when      not %found(piritem)
GMM AC                   eval      i2ittype = ' '
GMM AC                   eval      i2itum2  = ' '
GMM AC                   eval      i2itum3  = ' '
GMM AC                   eval      i2itumq2 = 0
GMM AC                   eval      i2itumq3 = 0
GMM A*
GMMbDC*                  when      i2ittype = 'B'
GMMbD*      Qty needs to be posted to type B item nbr.
GMMbD*
GMMbD*      Convert percentage into eaches qty.
GMMbDC*                  eval (h)  gIpqQp2 = gBrkPct * svumq2
GMMbD*      Convert cases qty into eaches qty plus eaches.
GMMbDC*                  eval      gIpqQp1 = (gIpqQp1 * svumq2) + gIpqQp2
GMMbDC*                  eval      gIpqQP2 = 0
GMM A*
GMM AC                   other
GMM A*      Replace original item number for all other item types.
GMM AC                   eval      gAdjItm = icitem
GMM AC                   eval (h)  gIpqQp2 = gBrkPct * svumq2
GMM AC                   endsl
GMM A*
GMM Ac                   return
GMM A*
GMM Ap prCvtBrkQty     e
     *
     *----------------------------------------------------------------*********
     *
     *  Compile Time Tables
     *
**
Item Quantity Compare Report
Item Quantity Compare Report: Host Items Not Found On Dakota
