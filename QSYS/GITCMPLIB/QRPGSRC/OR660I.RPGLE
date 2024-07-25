     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1957
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR660I     Pallet Detail Report - IWT.
     *  07 April 2017
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
YHA A*    04/07/17   MLB  YHA
     *      - Created.
     *      - Copy of OR660 rpg.
     *
710aA*    11/15/17  JCJ  7.10a
     *      - Enh: Added new stop/drop field.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Intercounty Bakers
     *
ICBa *    07/12/12  GJA  ICBa
     *      - Revised to not print transaction.  Compile 80 width
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Renzi Foodservice
     *
RNZaA*    03/27/09  MLB  RNZa
     *      - Revised array OVR to use OUTQ instead of DEV on prtf
     *        overrides. Removed parm OUTQ(*DEV).
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: YHata
     *
YHAaA*    01/16/09  RF  YHATA YHAa
     *      - Enh: Add page break for each pallet
YHAbA*    04/03/17  MLB  YHAb
     *      - Enh: Revised pgm to write out different rcd fmts when
     *        $cmd  = *DETAILI - Interwhse transfer report. Pgm
     *        called from OR660ICL via HWT270.
     *      - Added file, ORDC1 to list out c/wgt details for c/wgt itms.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Eastland
     *
EFCa *    12/09/13  GJA  EFCa
     *      - Enh:  added TOTALZ detail line
     *
EFCb *    12/13/13  GJA  EFCb
     *      - Enh:  80 column
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
     For660i    ip   e           k disk
     Fwarehs    if   e           k disk
     Frtehed    if   e           k disk
417c Fitemmsc   if   e           k disk
417cAFoptions   if   e           k disk
417cAFitemdsc   if   e           k disk
YHAbAFordc1     if   e           k disk
415 MFor660ipr  o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
      /COPY QCOPYSRC,ID#ICB
EFCaA /copy qcopysrc,id#eastlan
YHAbA /copy qcopysrc,id#yhata
     *
     *  Table and array
     *
415 AD a80             s              1    dim(80)
YHAbDD*ttl             s             40    dim(2) ctdata perrcd(1)
YHAbMD ttl             s             40    dim(3) ctdata perrcd(1)
YHAbDD*rpd             s             25    dim(5) ctdata perrcd(1)
YHAbMD rpd             s             25    dim(9) ctdata perrcd(1)
     D reck            s              7  0 dim(5)
     D lvlk            s              7  0 dim(5)
     *
     D qpck            s              5  0 dim(5)
     D cube            s              9  3 dim(5)
     D wght            s              9  2 dim(5)
     *
     *----------------------------------------------------------------
     D @unld           c                   const('Unload Seq:')
     D @comp           c                   const('Compartment:')
     D @palt           c                   const('Pallet:')
     D @door           c                   const('Door:')
     *----------------------------------------------------------------
416aA*
416aAD $lparm          ds
416aAD  $lcmd                  1      8
416aAD  $lprg                  9     18
416aAD  $luky                 19     68
416aAD  $lrtn                 69     76
416aAD  $lerm                 77    136
416aAD  $lmsg                 77     80
416aA*
416aA*   Redefine key
416aA*
416aAD  $lwhse                19     21  0
416aAD  $lrtid                22     26
416aAD  $ltrn#                27     33  0
416aAD  $lwhdp                34     38
416aAD  $ldoor                39     41  0
416aA*
     *----------------------------------------------------------------
417cA* Data structure
417cA*
417cAD opdata          ds
417cAD  opstyp                 1      1
417cAD  opwhdp                 2      6
417cAD  opum1                  7      8
417cAD  opdum                  9     23
417cAD  opcum                 24     43
417cAD  opcdiv                44     52  2
417cAD  opcaut                53     53
417cAD  opcwrn                54     54
417cAD  opcrng                55     57  1
417cAD  opwum                 58     72
417cAD  opxdsc                73     73
417cAD  optend               117    117
YHAbA*
YHAbAD wgtdetail       ds
YHAbAD  ycwgt1                 1      7  2
YHAbAD  ycwgt2                 8     14  2
YHAbAD  ycwgt3                15     21  2
YHAbAD  ycwgt4                22     28  2
YHAbAD  ycwgt5                29     35  2
YHAbAD  ycwgt6                36     42  2
YHAbAD  ycwgt7                43     49  2
YHAbAD  ycwgt8                50     56  2
YHAbAD  ycwgt9                57     63  2
YHAbAD  ycwgt10               64     70  2
YHAbAD  ycwgt11               71     77  2
YHAbAD  ycwgt12               78     84  2
YHAbAD  ycwgt13               85     91  2
YHAbA*
     *----------------------------------------------------------------
     * Work Variables
     *----------------------------------------------------------------
     D $plen           s              3  0
     D $pstr           s             60
     D cust#           s             11
     D ddoor           s              3
     D first           s              1
YHAbAD forevr          s              1    inz('0')
     D l               s              1  0
     D lbbat           s              7
     D m               s                   like(l)
     D ocode           s              8
     D opened          s              1
     D pspal           s              2
     D psunl           s              2
YHAbAD wgtcnt          s              3  0  inz(0)
YHAbAD wgtspace        s              1    inz('0')
     D wktrn#          s              7  0
     D wktype          s              1
YHAbAD y               s              1  0 inz(0)
     *----------------------------------------------------------------
     Ioqrec
     I                                          pscomp        l4
     I                                          psunld        l3
     I                                          psplid        l3
     I                                          lbstop        l2
650 AI                                          lbord         l2
YHAbAI                                          lbwhdp        l1
YHAbAI                                          lbdisp        l1
     I*                                         lbitem        l1
     I*                                         lbucod        l1
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $cmd              8
     C                   parm                    $rtype            8
520aD*                  PARM                    $DEV             10
520aD*                  PARM                    $FORM            10
     *----------------------------------------------------------------
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
     *  Init total levels
     *
     *  Level 1 break - Item
     *
     C                   if        *inl1
     C                   eval      l = 1
     C                   exsr      zrzero
     C                   endif
     *
     *  Level 2 break - Stop
     *
     C                   if        *inl2
     C                   eval      l = 2
     C                   exsr      zrzero
     *
     C                   eval      $cstr = *blanks
     C                   eval      cust# = *blanks
     C                   move      ohcust        $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd             8
     C                   parm                    $cstr            30
     C                   movel     $cstr         cust#
     C                   movel     ohcnam        csname
500aA*
500aA* Left justify order number
500aA*
500aAC                   eval      $cstr = *blanks
500aAC                   eval      ordn# = *blanks
500aAC                   move      ohcord        $cstr
500aAC                   call      'ADJUST'
500aAC                   parm      '*LEFT   '    $ccmd
500aAC                   parm                    $cstr
500aAC                   movel     $cstr         ordn#
520 AC                   exsr      zzfgts
500aAC                   endif
     *
     *  Level 3 break - Pallet ID/Unload sequence
     *
     C                   if        *inl3
     C                   eval      l = 3
     C                   exsr      zrzero
     *
416bAC                   if        pstrn# = 0
416bAC                   eval      wktype = 'B'
416bAC                   eval      wktrn# = 0
416bAC                   call      'GETBLTRN'
416bAC                   parm                    pswhse
416bAC                   parm                    psrtid
416bAC                   parm                    pscomp
416bAC                   parm                    pstzon
416bAC                   parm                    psgen
416bAC                   parm                    psszon
416bAC                   parm                    wktype
416bAC                   parm                    psunld
416bAC                   parm                    psrow
416bAC                   parm                    pscol
416bAC                   parm                    wktrn#
416bAC                   else
416bAC                   eval      wktrn# = lbtrn#
416bAC                   endif
     *
416aA*     Get dock door for the transaction.
416aA*
416aAC                   eval      $lwhse = pswhse
416aAC                   eval      $lrtid = psrtid
416bMC                   eval      $ltrn# = wktrn#
416bD**                   Z-ADDLBTRN#    $LTRN#
416aAC                   eval      $lwhdp = *blanks
416aAC                   eval      $ldoor = 0
416aAC                   call      'DH900'
416aAC                   parm                    $lparm
     *
     C                   eval      p#desc = *blanks
     C     p#desc        cat       '** ':1       p#desc
     C     p#desc        cat       @comp:1       p#desc
     C     p#desc        cat       '-':1         p#desc
     C     p#desc        cat       pscomp:1      p#desc
414aD*          P#DESC    CAT  ' ** - ':1P#DESC
414aMC     p#desc        cat       '    - ':1    p#desc
     C     p#desc        cat       @unld:1       p#desc
     C                   eval      $cstr = *blanks
     C                   move      psunld        $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd
     C                   parm                    $cstr
     C                   movel     $cstr         psunl
     C     p#desc        cat       psunl:1       p#desc
414aD*          P#DESC    CAT  ' ** - ':1P#DESC
414aMC     p#desc        cat       '    - ':1    p#desc
404 AC     p#desc        cat       @palt:1       p#desc
417 D*          P#DESC    CAT  PSUNL:1   P#DESC
417 AC                   move(p)   pspal#        $cstr
417 AC                   call      'ADJUST'
417 AC                   parm      '*LEFT   '    $ccmd
417 AC                   parm                    $cstr
417 AC                   movel     $cstr         pspal
417 MC     p#desc        cat       pspal:1       p#desc
     *
416aAC                   eval      $cstr = *blanks
416aAC                   move      $ldoor        $cstr
416aAC                   call      'ADJUST'
416aAC                   parm      '*LEFT   '    $ccmd
416aAC                   parm                    $cstr
416aAC                   movel     $cstr         ddoor
416aAC     p#desc        cat       '    - ':1    p#desc
416aAC     p#desc        cat       @door:1       p#desc
416aAC     p#desc        cat       ddoor:1       p#desc
YHAbA*
YHAbAC                   if        client = YHata
YHAbAC                             and $rtype = '*DETAILI'
YHAbAC                   eval      p#desc = %trim(p#desc)
YHAbAC                                      + '    Tran# '
YHAbAC                                      + %editc(pstrn# : '4')
YHAbAC                   endif
YHAbA*
     C                   endif
     *
     *  Level 4 break - Compartment
     *
     C                   if        *inl4
     C                   eval      l = 4
     C                   exsr      zrzero
     C                   endif
     *
     *  Print headings.
     *
     C                   if        *in93  or
     C                             *inl3
     C                   write     head2
     C                   endif
     *
     C                   if        *in92  or
     C                             *inl2
     C                   if        $rtype = '*DETAIL '
     C                   write     detail1
     C                   endif
YHAbA*
YHAbAC                   if        $rtype = '*DETAILI'
YHAbAC                   write     detail1yha
YHAbAC                   endif
YHAbA*
     C                   endif
     *
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *  Accumulate totals
     *
     C                   add       lbqpck        qpck(1)
     C                   add       lbcube        cube(1)
YHAbA*
YHAbAC                   if        itcwgt = 'Y'
YHAbAC                   exsr      zztotcwgt
YHAbAC                   add       t#wght        wght(1)
YHAbAC                   else
YHAbA*
     C                   add       lbswgt        wght(1)
YHAbAC                   eval      t#wght = lbswgt
YHAbAC                   endif
     *
     *  Increment record counters
     *
     C                   add       1             reck(1)
     C                   add       1             lvlk(1)
     *
     *  Set off top-of-page indicators
     *
     C                   eval      *in94 = *off
     C                   eval      *in93 = *off
     C                   eval      *in92 = *off
     C                   eval      *in91 = *off
     C                   eval      first = *off
     *----------------------------------------------------------------
     *
     * Item totals
     *
     CL1                 eval      l = 1
     CL1                 exsr      zrroll
     *
     CL1                 if        reck(l) > 0
410 ACL1                 if        *in90
410 ACL1                 exsr      zrhead
410 ACL1                 endif
     CL1                 exsr      zrtotl
     CL1                 endif
     *----------------------------------------------------------------
     *
     * Stop totals
     *
     CL2                 eval      l = 2
     CL2                 exsr      zrroll
     *
     CL2                 if        reck(l) > 0
410 ACL2                 if        *in90
410 ACL2                 exsr      zrhead
410 ACL2                 endif
     CL2                 exsr      zrtotl
     CL2                 endif
     *----------------------------------------------------------------
     *
     * Pallet totals
     *
     CL3                 eval      l = 3
     CL3                 exsr      zrroll
     *
     CL3                 if        reck(l) > 0
410 ACL3                 if        *in90
410 ACL3                 exsr      zrhead
410 ACL3                 endif
     CL3                 exsr      zrtotl
YHAaACL3   *in90         ifeq      *OFF
YHAaACL3   *inl4         andne     *on
YHAaACL3   $rtype        andeq     '*DETAIL '
YHAbA*
YHAbACL3   *in90         oreq      *OFF
YHAbACL3   *inl4         andne     *on
YHAbACL3   $rtype        andeq     '*DETAILI'
YHAbA*
YHAaACL3                 write     head1
YHAaACL3                 write     columnyha
YHAaACL3                 endif
     CL3                 endif
     *----------------------------------------------------------------
     *
     * Department totals
     *
     CL4                 eval      l = 4
     CL4                 exsr      zrroll
     *
     CL4                 if        reck(l) > 0
410 ACL4                 if        *in90
410 ACL4                 exsr      zrhead
410 ACL4                 endif
     CL4                 exsr      zrtotl
YHAaACL4   *in90         ifeq      *OFF
YHAaACL4   $rtype        andeq     '*DETAIL '
YHAbA*
YHAbACL4   *in90         oreq      *OFF
YHAbACL4   $rtype        andeq     '*DETAILI'
YHAbA*
YHAaACL4                 write     head1
YHAaACL4                 write     columnyha
YHAaACL4                 endif
     CL4                 endif
     *----------------------------------------------------------------
     *
     * Batch totals
     *
     CLr                 eval      l = 5
     *
     CLr                 if        reck(l) > 0
410 ACLr                 if        *in90
410 ACLr                 exsr      zrhead
410 ACLr                 endif
     CLr                 exsr      zrtotl
     CLr                 write     foot1
     CLr                 endif
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
     C                   call      @getcl
     C                   parm                    client           10
     *
     C                   time                    time
     C                   eval      first = *on
     C                   eval      l = 1
500 A* Determine Heading
500 AC                   select
500 AC                   when      $rtype = '*SUMMARY'
500 AC*                  eval      fldttl = *blanks
500 AC                   when      $rtype = '*DETAIL '
500 AC*                  eval      fldttl = ' Slot  '
500 AC                   other
500 AC*                  eval      fldttl = *blanks
500 AC                   endsl
     C                   exsr      zrzero
417cAC                   exsr      zzinz
415 A*
415 A*  Variables and constants.
415 A*
     *
     C                   endsr
YHAbA*
YHAbA*----------------------------------------------------------------
YHAbA*
YHAbAC     zztotcwgt     begsr
YHAbA*
YHAbA*   Calculate c/wgt total for weighted item.
YHAbA*
YHAbAC                   eval      t#wght = 0
YHAbAC     ockey         setll     ordc1
YHAbAC                   dow       forevr = forevr
YHAbAC     ockey         reade     ordc1
YHAbAC                   if        %eof(ordc1)
YHAbAC                   leave
YHAbAC                   endif
YHAbA*
YHAbAC                   eval      t#wght = t#wght + occwgt
YHAbA*
YHAbAC                   enddo
YHAbA*
YHAbAC                   endsr
YHAbA*
YHAbA*----------------------------------------------------------------
YHAbA*
YHAbAC     zzprtcwgt     begsr
YHAbA*
YHAbA*   Print c/wgt details for weighted items.
YHAbA*
YHAbAC                   eval      wgtspace = '0'
YHAbAC                   eval      wgtcnt = 0
YHAbAC                   clear                   wgtdetail
YHAbAC     ockey         setll     ordc1
YHAbAC                   dow       forevr = forevr
YHAbAC     ockey         reade     ordc1
YHAbAC                   if        %eof(ordc1)
YHAbA*
YHAbAC                   if        wgtcnt > 0
YHAbAC                   if        *in90 = '1'
YHAbAC                   exsr      zrhead
YHAbAC                   endif
YHAbAC                   write     cwgtdtl                              90
YHAbAC                   endif
YHAbA*
YHAbAC                   leave
YHAbAC                   endif
YHAbA*
YHAbAC                   if        wgtspace = '0'
YHAbAC                   write     skip1
YHAbAC                   eval      wgtspace = '1'
YHAbAC                   endif
YHAbA*
YHAbAC                   add       1             wgtcnt
YHAbAC                   select
YHAbAC                   when      wgtcnt = 1
YHAbAC                   eval      ycwgt1 = occwgt
YHAbA*
YHAbAC                   when      wgtcnt = 2
YHAbAC                   eval      ycwgt2 = occwgt
YHAbA*
YHAbAC                   when      wgtcnt = 3
YHAbAC                   eval      ycwgt3 = occwgt
YHAbA*
YHAbAC                   when      wgtcnt = 4
YHAbAC                   eval      ycwgt4 = occwgt
YHAbA*
YHAbAC                   when      wgtcnt = 5
YHAbAC                   eval      ycwgt5 = occwgt
YHAbA*
YHAbAC                   when      wgtcnt = 6
YHAbAC                   eval      ycwgt6 = occwgt
YHAbA*
YHAbAC                   when      wgtcnt = 7
YHAbAC                   eval      ycwgt7 = occwgt
YHAbAC                   if        *in90
YHAbAC                   exsr      zrhead
YHAbAC                   endif
YHAbA*
YHAbAC                   if        *in90 = '1'
YHAbAC                   exsr      zrhead
YHAbAC                   endif
YHAbAC                   write     cwgtdtl                              90
YHAbAC                   clear                   wgtcnt
YHAbAC                   clear                   wgtdetail
YHAbA*
YHAbAC**                 when      wgtcnt = 8
YHAbAC**                 eval      ycwgt8 = occwgt
YHAbA*
YHAbAC**                 when      wgtcnt = 9
YHAbAC**                 eval      ycwgt9 = occwgt
YHAbA*
YHAbAC**                 when      wgtcnt = 10
YHAbAC**                 eval      ycwgt10 = occwgt
YHAbA*
YHAbAC**                 when      wgtcnt = 11
YHAbAC**                 eval      ycwgt11 = occwgt
YHAbAC**                 if        *in90
YHAbAC**                 exsr      zrhead
YHAbAC**                 endif
YHAbA*
YHAbAC**                 if        *in90 = '1'
YHAbAC**                 exsr      zrhead
YHAbAC**                 endif
YHAbAC**                 write     cwgtdtl                              90
YHAbAC**                 clear                   wgtcnt
YHAbAC**                 clear                   wgtdetail
YHAbA*
YHAbAC**                 when      wgtcnt = 12
YHAbAC**                 eval      ycwgt12 = occwgt
YHAbA*
YHAbAC**                 when      wgtcnt = 13
YHAbAC**                 eval      ycwgt13 = occwgt
YHAbAC**                 if        *in90
YHAbAC**                 exsr      zrhead
YHAbAC**                 endif
YHAbA*
YHAbAC**                 if        *in90 = '1'
YHAbAC**                 exsr      zrhead
YHAbAC**                 endif
YHAbAC**                 write     cwgtdtl                              90
YHAbAC**                 clear                   wgtcnt
YHAbAC**                 clear                   wgtdetail
YHAbAC                   endsl
YHAbA*
YHAbAC                   enddo
YHAbA*
YHAbAC                   endsr
YHAbA*
     *----------------------------------------------------------------
     *
     C     zrfrmt        begsr
     *
     *   Format report title.
     *
     C                   if        $rtype = '*SUMMARY'
     C                   eval      title = ttl(1)
     C                   else
YHAbA*
YHAbAC                   if            client = YHata
YHAbAC                             and $rtype = '*DETAILI'
YHAbAC                   eval      title = ttl(3)
YHAbAC                   else
YHAbA*
     C                   eval      title = ttl(2)
YHAbAC                   endif
YHAbA*
     C                   endif
     C                   movel     title         $pstr
     C                   eval      $plen = 40
     *
     *   Center report title.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         title
     *
     *   Get warehouse description.
     *
     C                   eval      whse = *blanks
     C                   eval      $pstr = *blanks
     C     lbwhse        chain     warehs                             79
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
     *                    MOVE *BLANKS   $CSTR
     *                    MOVE *BLANKS   LBBAT
     *                    MOVE LBPBAT    $CSTR
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd
     C                   parm                    $cstr
     C                   movel     $cstr         lbbat
     *
     *   Format Route number.
     *
     C     rtkey         klist
     C                   kfld                    pswhse
     C                   kfld                    psrtid
     C     rtkey         chain     rtehed                             79
     C                   if        *in79
     C                   eval      rhrte = *blanks
     C                   endif
     C                   eval      batch = *blanks
     C                   eval      $pstr = *blanks
     C     batch         cat       'Route:':1    batch
     C     batch         cat       rhrte:1       batch
     C                   movel     batch         $pstr
     C                   eval      $plen = 30
     *
     *   Center batch/route description.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         batch
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     C                   if        not *inl4
     C                   eval      *in94 = *on
     C                   endif
     *
     C                   if        not *inl3
     C                   eval      *in93 = *on
     C                   endif
     *
     C                   if        not *inl2
     C                   eval      *in92 = *on
     C                   endif
     *
     C                   if        not *inl1
     C                   eval      *in91 = *on
     C                   endif
     *
     C                   eval      *in90 = *off
     *
     C                   write     head1
EFCbAC                   select
EFCbAC                   when      client = Eastland
EFCbAC                   write     columns80
YHAbA*
YHAbAC                   when          client = YHata
YHAbAC                             and $rtype = '*DETAILI'
YHAbAC                   write     columnyha
YHAbA*
EFCbAC                   other
     C                   write     columns
EFCbAC                   endsl
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
     C                   add       qpck(l)       qpck(m)
     C                   add       cube(l)       cube(m)
     C                   add       wght(l)       wght(m)
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrtotl        begsr
     *
YHAbAC                   eval      t#qalc = lbqalc
     C                   eval      t#qpck = qpck(l)
     C                   eval      t#cube = cube(l)
YHAbAC                   if        l > 1
     C                   eval      t#wght = wght(l)
YHAbAC                   endif
     *
YHAbAC                   if        $rtype = '*DETAILI'
YHAbAC                             and l > 1
YHAbAC                   eval      y    = l + 4
YHAbAC                   eval      $rpd = rpd(y)
YHAbAC                   else
YHAbA*
     C                   eval      $rpd = rpd(l)
YHAbAC                   endif
     *
     C                   if        l = 1
     C                   if        $rtype = '*DETAIL '
YHAbAC                             or $rtype = '*DETAILI'
417c C                   exsr      zzgeti
417cD*                    MOVELITDESC    DESCIT
EFCbAC                   select
EFCbAC                   when      client = Eastland
     C                   write     detail280
     C                   write     detail380
YHAbA*
YHAbAC                   when          client = Yhata
YHAbAC                             and $rtype = '*DETAILI'
YHAbAC                   write     skip1
YHAbAC                   if        itcwgt = 'Y'
YHAbAC                   exsr      zztotcwgt
YHAbAC                   endif
YHAbAC                   write     detail2yha
YHAbAC                   if        itcwgt = 'Y'
YHAbAC                   exsr      zzprtcwgt
YHAbAC                   endif
YHAbA*
EFCbAC                   other
     C                   write     detail2
404 AC                   write     detail3
EFCbAC                   endsl
     C                   endif
     C                   endif
     *
     C                   if        l = 2
     C                   if        $rtype = '*DETAIL '
YHAbAC                             or $rtype = '*DETAILI'
     C                   write     skip1
YHAbA*
YHAbAC                   if            client = Yhata
YHAbAC                             and $rtype = '*DETAILI'
YHAbAC                   write     totaldyha
YHAbAC                   else
YHAbA*
     C                   write     totald
YHAbAC                   endif
YHAbA*
     C                   else
EFCbAC                   select
EFCbAC                   when      client = Eastland
EFCbAC                   write     total180
ICBaAC                   when      client = icb
ICBaAC                   write     total1icb
EFCbAC                   other
     C                   write     total1
EFCbAC                   endsl
     C                   endif
     C                   endif
     *
     C                   if        l = 3
YHAbAC                   select
YHAbMC                   when      client = icb
ICBaAC                   write     total2icb
YHAbA*
YHAbAC                   when          client = Yhata
YHAbAC                             and $rtype = '*DETAILI'
YHAbAC                   write     skip1
YHAbAC                   write     total2yha
YHAbA*
YHAbMC                   other
     C                   write     skip1
     C                   write     total2
YHAbMC                   endsl
     C                   endif
     *
     C                   if        l = 4
YHAbAC                   select
YHAbMC                   when      client = icb
ICBaAC                   write     total3icb
YHAbA*
YHAbAC                   when          client = Yhata
YHAbAC                             and $rtype = '*DETAILI'
YHAbAC                   write     skip1
YHAbAC                   write     total3yha
YHAbA*
YHAbMC                   other
     C                   write     skip1
     C                   write     total3
YHAbMC                   endsl
     C                   endif
     *
     C                   if        l = 5
     C                   write     skip1
YHAbAC                   select
YHAbMC                   when      client = icb
ICBaAC                   write     total4icb
YHAbA*
YHAbAC                   when          client = Yhata
YHAbAC                             and $rtype = '*DETAILI'
YHAbAC                   write     total4yha
YHAbA*
YHAbMC                   other
     C                   write     total4
YHAbMC                   endsl
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrzero        begsr
     *
     C                   eval      lvlk(l) = 0
     C                   eval      reck(l) = 0
     *
     *                    Z-ADD0         CLS,L
     C                   eval      qpck(l) = 0
     C                   eval      cube(l) = 0
     C                   eval      wght(l) = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
520 A*  ZZFGTS   Get Host Stop Number
520 A*
520 AC     zzfgts        begsr
520 A*
520 A*    Get Stop From RTESTP
520 A*
520 AC                   call      'GETSTOP'
520 MC                   parm      '*ORDSTP '    $scmd             8
520 MC                   parm      lbwhse        $swhse            3 0
520 MC                   parm      lbrte         $srtid            5
520 MC                   parm      lbord         $sord             7 0
520 MC                   parm      0             $sdstp            2 0
520 MC                   parm                    $sstp             5 0
710aAc                   parm                    $pDdrop           3
710aAc                   parm                    $pDextd          30
710aAc                   parm                    $pDsd             9
520 A*
520 AC                   if        $sstp > 0
520 MC                   move      $sstp         dspstp
520 AC                   else
520 AC                   eval      dspstp = lbstop
520 AC                   endif
520 A*
520 AC                   endsr
     *----------------------------------------------------------------
417c *
417c C     zzgeti        begsr
417c *
417cAC                   eval      desci1 = *blanks
417cAC                   eval      desci2 = *blanks
417cAC                   eval      ocode = '*ITEMMNT'
417cAC     opkey         chain     options
417cAC                   if        not %found(options)
417cAC                   eval      opxdsc = 'N'
417cAC                   endif
     *
417cAC                   if        opxdsc = 'Y'
417cAC     idkey         chain     itemdsc
417cAC                   if        %found(itemdsc)
417cAC                   eval      desci1 = ixdsc1
417cAC                   eval      desci2 = ixdsc2
417cAC                   endif
417cAC                   else
417cAC                   movel     itdesc        desci1
417cAC                   endif
     *
417c C     idkey         chain     itemmsc
417c C                   if        not %found(itemmsc)
417c C                   eval      brand = *blanks
417c C                   else
417c C                   eval      brand = imbrnd
417c C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
417cA*     OPTIONS
417cA*
417cAC     opkey         klist
417cAC                   kfld                    lbwhse
417cAC                   kfld                    ocode
YHAbA*
YHAbA*    Catchweight Details
YHAbAC     ockey         klist
YHAbAC                   kfld                    lbwhse
YHAbAC                   kfld                    lblbl#
417cA*
417cA*     Extended Item Description
417cA*
417bAC     idkey         klist
417cAC                   kfld                    lbwhse
417cAC                   kfld                    lbitem
     *
     C                   endsr
     *----------------------------------------------------------------

     * Compile time tables
     *
**      TTL   Report title descriptions
Truck Pallet Summary Report
Truck Pallet Detail Report
IWT Pallet Detail Report
**      RPD   Report level descriptions

 * Stop totals *
 ** Pallet totals **
 *** Compartment totals ***
 **** Totals ****
* Stop totals *
**Plt totals **
*** Comp ttl***
****Totals ****
