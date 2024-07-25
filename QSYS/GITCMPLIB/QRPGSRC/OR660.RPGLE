     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  OR660     Pallet summary Report.
     *  26 June, 1997
     *  Hemant Kapadia
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
404 A*    08/26/97   HNK  4.04
     *      - Changed to print pallet number and transaction number.
     *      - Print DETAIL3 record for pack description.
410 A*    12/03/98   RH   4.10
     *      - Recompiled - problem with OR660 file from 404 changes.
414aA*    06/14/00   RH   4.14
     *      - Removed '**' for unload seq and pallet to read easier.
     *
415 A*    02/16/01  DAS  4.15
     *      - Added REPORTS override for OR660PR.
     *
416aA*    04/16/02  HNK  4.16a
     *      - Add dock door number.
     *
416bA*    07/17/02  HNK  4.16b
     *      - Get bulk pick tran #.
     *
417 A*    07/11/03  MLB  4.17
     *      - Revised heading build to use PSPAL# instead of PSUNLD for
     *        pallet number.
417bA*    08/21/03  RH   4.17b
     *      - FIX: Change to use printer entered in option program.
417cA*    09/10/03  RH   4.17c
     *      - ENH: Add extended description to detail3.
     *
500 A*    09/22/05  MLB  5.00
     *      - Enh: Revise program to retrieve separate entry for
     *        *SUMMARY report.
500aA*    05/12/06  JCJ  5.00a
     *      - Enh: Add order number to summary.
     *      - Enh: Soft coded slot heading.
     *
520 A*    02/05/09  CWM/MLB 5.20  01/26  02/03
     *      - Enh: Added support for new extended stop number.
     *        Retrieve stop # in subroutine ZZFGTS and pgm GETSTOP
     *
520a *    01/23/08  CWM  5.20a
     *      - Enh: CVTRPGSRC and RPG4MAX
     *             Commented out User Controlled Print File Open
     *             Commented out all ovrprtf processing coded internal
     *
640a *    07/12/12  GJA  6.40a
     *      - Enh: Add custom client code
     *
650 A*    07/29/14  MLB  6.50
     *      - Fix: Revised pgm to add field LBORD to file key for
     *        file OR660. Pgm was not reporting correct info for
     *        each order on the pallet.
     *
650aA*    05/30/13  RBD  6.50a
     *      - Enh: Added new stop/drop field.  Will print and use
     *        as control break instead of label stop.
     *
720 A*    04/11/18  KDE  7.20
     *      - Enh: Add Pallet Serial number from PLTMISC when Drag Drop 2
     *
720aA*    05/03/18  KDE  7.20a
     *      - Enh: Add indicator to reflect Spun Pallet
     *
720bA*    05/08/18  KDE  7.20b
     *      - Enh: Remove Unload Sequence for Drag Drop 2
     *
720cA*    09/11/18  DAS  7.20c
     *      - Revised to call GetTBType instead of reading
     *        data area dragdrop2 directly.
     *      - Replaced dd2 with tbEnhanced.
     *
730aA*    03/15/19  MR  7.30a
     *      - Added p.exordh and call to exordh for order
     *        numbers greater that 7 in length.
     *
740aA*    08/21/20  JCJ 7.40a
     *      - Added TruckID and DriverID
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
     *  Client Custom Revisions: Eastland
     *
EFCa *    12/09/13  GJA  EFCa
     *      - Enh:  added TOTALZ detail line
     *
EFCb *    12/13/13  GJA  EFCb
     *      - Enh:  80 column
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Get Fresh Sales
     *
GFS A*    03/08/18  MLB  GFS
     *      - Revised pgm to populate new fld, R1TXT with PO: + OHCPO
     *        on DETAIL1 fmt.
     *      - Revised pgm to populate new fld, PSTWARN with data from
     *        ORDDM and write new fmt DETAIL2GFS. Revised to write new
     *        column fmt, COL_GFS.
     *      - Added ORDDM to pgm.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Anderson DuBose
     *
ADCaA*    09/18/18  LMC  ADCa
     *      - Condition scc18 printing on client
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Westside
     *
WST A*    12/04/19  KDE  WST
     *      - Fix: Revised exclude Cube and Weight and write a blank
     *        line after each item
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Caribbean Producers
     *
CPJaA*    08/21/20  JCJ  CPJa
     *      - Enh: Added Truck ID & Driver ID.
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
     For660     ip   e           k disk
     Fwarehs    if   e           k disk
     Frtehed    if   e           k disk
417c Fitemmsc   if   e           k disk
417cAFoptions   if   e           k disk
417cAFitemdsc   if   e           k disk
720 AFpltMisc   if   e           k disk
720aAftrktmpd   if   e           k disk
CPJaAFordhm2    if   e           k disk    usropn
GFS AForddm     if   e           k disk    usropn
415 D**660PR O   E             90     PRINTER
415 MFor660pr   o    e             printer oflind(*in90)
520aD*                                    USROPN
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
ADCaA /COPY QCOPYSRC,ID#ADC
      /COPY QCOPYSRC,ID#ICB
EFCaA /copy qcopysrc,id#eastlan
WST A /copy qcopysrc,id#westsid
GFS A /copy qcopysrc,id#gfs
CPJaA /copy qcopysrc,id#cpj
GFS A*
GFS A*----------------------------------------------------------------
GFS  *
GFS A /copy qcopysrc,orddm1_gfs
GFS A /copy qcopysrc,orddm2_gfs
GFS A /copy qcopysrc,orddm3_gfs
GFS A /copy qcopysrc,orddm4_gfs
GFS A /copy qcopysrc,orddm5_gfs
GFS A*
GFS A*----------------------------------------------------------------
730aAD/copy qcopysrc,c#stdvar
730aAD/copy qcopysrc,p.exordh
GFS A*----------------------------------------------------------------
     *
     *  Table and array
     *
415 AD a80             s              1    dim(80)
     D ttl             s             40    dim(2) ctdata perrcd(1)
     D rpd             s             25    dim(5) ctdata perrcd(1)
     D reck            s              7  0 dim(5)
     D lvlk            s              7  0 dim(5)
     *
     D qpck            s              5  0 dim(5)
     D cube            s              9  3 dim(5)
     D wght            s              9  2 dim(5)
415 AD ovrprt          s             80    dim(1) ctdata perrcd(1)
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
     *----------------------------------------------------------------
     * Work Variables
     *----------------------------------------------------------------
     D $plen           s              3  0
     D $pstr           s             60
     D cust#           s             11
     D ddoor           s              3
     D first           s              1
     D l               s              1  0
     D lbbat           s              7
     D lstdev          s                   like($dev)
     D lstfrm          s                   like($form)
     D lstwhs          s                   like($whse)
     D m               s                   like(l)
     D ocode           s              8
WST Ad colhd0          s              8
WST Ad colhd1          s              8
WST Ad colhd2          s              8
     D opened          s              1
     D pspal           s              2
     D psunl           s              2
WST Ad t#qpckw         s              7  0
720cAd tbEnhanced      s               n
720cAd tbPalletType    s              1
720cAd tbType          s              1
720cAd tbWhse          s              3  0
     D wktrn#          s              7  0
     D wktype          s              1
740aAD didtxt          s             10    inz('Driver ID:')
740aAD tidtxt          s              9    inz('Truck ID:')
740aAD did             s              8
740aAD tid             s              8

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

720cAd/copy qcopysrc,p.gettbtyp

     *----------------------------------------------------------------
     Ioqrec
     I                                          pscomp        l4
     I                                          psunld        l3
     I                                          psplid        l3
650aDI**                                        lbstop        l2
650aMI                                          rtssd         l2
     I                                          lbseq         l1
     I                                          lbitem        l1
     I                                          lbucod        l1
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $cmd              8
     C                   parm                    $rtype            8
520aD*                  PARM                    $DEV             10
520aD*                  PARM                    $FORM            10
     *----------------------------------------------------------------
720cAc*
720cAc*   Determine if using TruckBUilder Enhanced
720cAc*
720cA /free
720cA    if first = *on;
720cA      tbWhse = pswhse;
720cA      GetTBType(tbWhse: psrtid: tbType);
720cA      if tbType = 'E';
720cA        tbEnhanced = *on;
720cA        tbPalletType = 'P';
720cA      else;
720cA        tbEnhanced = *off;
720cA        tbPalletType = 'O';
720cA      endif;
720cA    endif;
720cA /end-free
     *
     *  Report Heading
     *
     *
     *  Start new page if one of following happened.
     *     - Overflow occurred.
     *
     C                   if        *in90  or
     C                             first = *on
520aD*                  EXSR      OPNPRT
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
730aA*
730aA* Check if order number is greater than 7 in length.
730aA /free
730aA      exWhse = pswhse;
730aA      ohaord = ohcord;
730aA      exordh ('*GET': exRtnCode: exRtnMsg: exWhse: ohaord:
730aA              ohaaudflg: ohaaudid: ohaaudcmp: ohaaudby: ohaaudts:
730aA             ohaorda: ohacusta);
730aA /end-free
730aAC                   if        ohaorda <> *blanks
730aAC                   movel     ohaorda       ordn#
730aAC                   endif
     *
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
720cMc                   if        not tbEnhanced
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
720bAc                   endif
WST Ac     client        ifeq      westside
WST AC     p#desc        cat       @palt:11      p#desc
WST AC                   else
404 AC     p#desc        cat       @palt:1       p#desc
WST Ac                   endif
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
WST Ac     client        ifne      westside
416aAC     p#desc        cat       '    - ':1    p#desc
416aAC     p#desc        cat       @door:1       p#desc
416aAC     p#desc        cat       ddoor:1       p#desc
WST Ac                   endif
720 Ac*
720 Ac*  Add ADBPLT5 Serial# to p#desc
720 Ac*
720 A /free
720cM     if tbEnhanced;
720 A        chain (pswhse:psrtid:psplid:'ADBSSCC18':0) pltmisc;
720 A        if %found(pltmisc);
720aA           // get truck for whether position is spun
720aA           chain (pswhse:pstruk:psrow) trktmpd;
720aA           if not %found(trktmpd);
720aA              ttdspin1=' ';
720aA              ttdspin2=' ';
720aA              ttdspin3=' ';
720aA           endif;
720aA           select;
720 A              when pscol=1;
720aA                 if ttdspin1 = 'Y';
ADCaA                    if client = adc;
720aA                      p#desc = %trim(p#desc) + '    - SSCC: ' +
720aA                               %trim(pmvalue) + '*SPIN';
ADCaA                    else;
ADCaA                      p#desc = %trim(p#desc) + '    *SPIN';
ADCaA                    endif;
720aA                 else;
ADCaA                    if client = adc;
720aA                      p#desc = %trim(p#desc) + '    - SSCC: '  +
720aA                               %trim(pmvalue);
ADCaA                    else;
ADCaA                      p#desc = %trim(p#desc);
ADCaA                    endif;
720aA                 endif;
720 A              when pscol=2;
720aA                 if ttdspin2 = 'Y';
ADCaA                   if client = adc;
720aA                     p#desc = %trim(p#desc) + '    - SSCC: ' +
720aA                              %trim(pmvalue) + '*SPIN';
ADCaA                   else;
ADCaA                     p#desc = %trim(p#desc) + '    *SPIN';
ADCaA                   endif;
720aA                 else;
ADCaA                   if client = adc;
720aA                     p#desc = %trim(p#desc) + '    - SSCC: '  +
720aA                              %trim(pmvalue);
ADCaA                   else;
ADCaA                     p#desc = %trim(p#desc);
ADCaA                   endif;
720aA                 endif;
720 A              when pscol=3;
720aA                 if ttdspin3 = 'Y';
ADCaA                   if client = adc;
720aA                     p#desc = %trim(p#desc) + '    - SSCC: ' +
720aA                               %trim(pmvalue) + '*SPIN';
ADCaA                   else;
ADCaA                     p#desc = %trim(p#desc) + '    *SPIN';
ADCaA                   endif;
720aA                 else;
ADCaA                   if client = adc;
720aA                     p#desc = %trim(p#desc) + '    - SSCC: '  +
720aA                              %trim(pmvalue);
ADCaA                   else;
ADCaA                     p#desc = %trim(p#desc);
ADCaA                   endif;
720aA                 endif;
720 A           endsl;
720 A        endif;
720 A     endif;
720 A /end-free
720 Ac*
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
     C                   write     head3
     C                   write     head2
     C                   endif
     *
     C                   if        *in92  or
     C                             *inl2
     C                   if        $rtype = '*DETAIL '
GFS A*
GFS AC                   if        client = GetFresh
GFS AC                   eval      r1text = 'PO: '
GFS AC                             + ohcpo
GFS AC                   endif
GFS A*
     C                   write     detail1
     C                   endif
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
     C                   add       lbswgt        wght(1)
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
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     C                   call      @getcl
     C                   parm                    client           10
720 AC                   parm                    clientloc        10
     *
GFS AC                   if        client = GetFresh
GFS AC                   if        not %open(orddm)
GFS AC                   open      orddm
GFS AC                   endif
GFS AC                   endif
     *
CPJaAC                   if        client = cpj
CPJaAC                   if        not %open(ordhm2)
CPJaAC                   open      ordhm2
CPJaAC                   endif
CPJaAC                   endif
CPJaA*
     C                   time                    time
     C                   eval      first = *on
     C                   eval      l = 1
WST A*
WST A* Use indictor 70 to control what Westside is not wanting printed
WST A* on Pallet Summary
WST A*
WST Ac     client        ifeq      westside
WST Ac                   eval      *in70 = *off
WST Ac                   eval      colhd0=*blanks
WST Ac                   eval      colhd1='Pieces'
WST Ac                   eval      colhd2=*blanks
WST Ac                   else
WST Ac                   eval      colhd0='Pieces'
WST Ac                   eval      colhd1='Cube'
WST Ac                   eval      colhd2='Weight'
WST Ac                   eval      *in70 = *on
WST Ac                   endif
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
415 A*----------------------------------------------------------------
415 A*
415 A*  OPNPRT  Open printer file.
415 A*
415 AC     opnprt        begsr
     *
     *   Get device and form type for department.
     *
     C                   if        pswhse <> lstwhs  and
417b C                             $dev = '*JOB'
500 A*
500 A*   Retrieve default printer for Detail report.
500 AC                   if        $rtype = '*DETAIL '
500 AC                   eval      $lrpt = 'OR660PR '
500 AC                   else
500 A*   Retrieve default printer for Summary report.
500 AC                   eval      $lrpt = 'OR660PRS'
500 AC                   endif
500 A*
     C                   call      'GETRPT'
     C                   parm      '*DEVFORM'    $cmd
500 D*                    PARM 'OR660PR' $LRPT  10
500 MC                   parm                    $lrpt            10
     C                   parm      pswhse        $whse             3 0
     C                   parm      ' '           $styp             1
     C                   parm      ' '           $whdp             5
     C                   parm                    $desc            50
     C                   parm                    $dev             10
     C                   parm                    $form            10
     C                   eval      lstwhs = $whse
     C                   endif
     *
     *   Open printer file for department.
     *
     C                   if        opened <> *on  or
     C                             $dev <> lstdev  or
     C                             $form <> lstfrm
     *
     *      If printer already open then close it.
     *
     C                   if        opened = *on
     C                   close     or660pr
     C                   endif
     *
     *      Override printer file.
     *
     *          OVRPRTF FILE(OR660PR) OUTQ(*DEV) DEV($dev)
     *                  FORMTYPE($form)
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
     C                   open      or660pr
     C                   eval      opened = *on
     C                   eval      lstdev = $dev
     C                   eval      lstfrm = $form
     *
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrfrmt        begsr
     *
     *   Format report title.
     *
     C                   if        $rtype = '*SUMMARY'
     C                   eval      title = ttl(1)
     C                   else
     C                   eval      title = ttl(2)
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

CPJaAC                   if        client = cpj
CPJaAC     ohmky         chain     ordhm2
CPJaAC                   if        not %found(ordhm2)
CPJaAC                   eval      tid = ' '
CPJaAC                   eval      did = ' '
CPJaAC                   eval      hmmsc1 = ' '
CPJaAC                   eval      hmmsc2 = ' '
CPJaAC                   eval      hmmsc3 = ' '
CPJaAC                   eval      hmmsc4 = ' '
CPJaAC                   eval      hmmsc5 = ' '
CPJaAC                   else
CPJaAC                   eval      tid = %subst(hmmsc1:1:8)
CPJaAC                   eval      did = %subst(hmmsc2:1:8)
CPJaAC                   endif
CPJaAC                   endif

     C                   eval      batch = *blanks
     C                   eval      $pstr = *blanks
     C     batch         cat       'Route:':1    batch
     C     batch         cat       rhrte:1       batch
CPJaAC                   if        client = cpj
CPJaAC     batch         cat       tidtxt:1      batch
CPJaAC     batch         cat       tid:1         batch
CPJaAC     batch         cat       didtxt:1      batch
CPJaAC     batch         cat       did:1         batch
CPJaAC                   endif
     C                   movel     batch         $pstr
     C                   eval      $plen = 65
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
GFS A*
GFS AC                   when      client = GetFresh
GFS AC                   write     col_gfs
GFS A*
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
     C                   eval      t#qpck = qpck(l)
     C                   eval      t#cube = cube(l)
     C                   eval      t#wght = wght(l)
WST Ac     client        ifeq      westside
WST AC                   eval      t#qpckw= qpck(l)
WST Ac                   endif
     *
     C                   eval      $rpd = rpd(l)
     *
     C                   if        l = 1
     C                   if        $rtype = '*DETAIL '
417c C                   exsr      zzgeti
417cD*                    MOVELITDESC    DESCIT
EFCbAC                   select
EFCbAC                   when      client = Eastland
     C                   write     detail280
     C                   write     detail380
GFS A*
GFS AC                   when      client = GetFresh
GFS AC                   write     detail2gfs
GFS A*
EFCbAC                   other
     C                   write     detail2
404 AC                   write     detail3
EFCbAC                   endsl
     C                   endif
     C                   endif
     *
     C                   if        l = 2
     C                   if        $rtype = '*DETAIL '
     C                   write     skip1
     C                   write     totald
     C                   else
EFCbAC                   select
EFCbAC                   when      client = Eastland
EFCbAC                   write     total180
ICBaAC                   when      client = icb
ICBaAC                   write     total1icb
EFCbAC                   other
WST Ac     client        ifeq      westside
WST Ac                   eval      t#qpckw=t#qpck
WST Ac                   endif
     C                   write     total1
WST Ac     client        ifeq      westside
WST Ac                   write     skip1
WST Ac                   endif
EFCbAC                   endsl
     C                   endif
     C                   endif
     *
     C                   if        l = 3
ICBaAC                   if        client = icb
ICBaAC                   write     total2icb
ICBaAC                   else
     C                   write     skip1
     C                   write     total2
ICBaAC                   endif
     C                   endif
     *
     C                   if        l = 4
ICBaAC                   if        client = icb
ICBaAC                   write     total3icb
ICBaAC                   else
     C                   write     skip1
     C                   write     total3
ICBaAC                   endif
     C                   endif
     *
     C                   if        l = 5
     C                   write     skip1
ICBaAC                   if        client = icb
ICBaAC                   write     total4icb
ICBaAC                   else
     C                   write     total4
ICBaAC                   endif
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
650aAC                   parm                    $sdrop            3
650aAC                   parm                    $sextd           30
650aAC                   parm                    $ssd              9
520 A*
520 AC                   if        $sstp > 0
650aDC**                 move      $sstp         dspstp
650aMC                   move      $ssd          dspstp
520 AC                   else
650aDC**                 eval      dspstp = lbstop
650aMC                   move      lbstop        dspstp
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
417cAC     opkey         chain     options                            79
417cAC                   if        *in79
417cAC                   eval      opxdsc = 'N'
417cAC                   endif
     *
417cAC                   if        opxdsc = 'Y'
417cAC     idkey         chain     itemdsc                            79
417cAC                   if        not *in79
417cAC                   eval      desci1 = ixdsc1
417cAC                   eval      desci2 = ixdsc2
417cAC                   endif
417cAC                   else
417cAC                   movel     itdesc        desci1
417cAC                   endif
     *
417c C     idkey         chain     itemmsc                            79
417c C                   if        *in79
417c C                   eval      brand = *blanks
417c C                   else
417c C                   eval      brand = imbrnd
417c C                   endif
GFS A*
GFS AC                   if        client = GetFresh
GFS AC     omkey         chain     orddm
GFS AC                   if        not %found(orddm)
GFS AC                   eval      ommsc1 = ' '
GFS AC                   eval      ommsc2 = ' '
GFS AC                   eval      ommsc3 = ' '
GFS AC                   eval      ommsc4 = ' '
GFS AC                   eval      ommsc5 = ' '
GFS AC                   else
GFS AC                   eval      orddm1_gfs = ommsc1
GFS AC                   eval      orddm2_gfs = ommsc2
GFS AC                   eval      orddm3_gfs = ommsc3
GFS AC                   eval      orddm4_gfs = ommsc4
GFS AC                   eval      orddm5_gfs = ommsc5
GFS AC                   endif
GFS AC                   eval      pcprtno  = gfsdm1_omcprtno
GFS AC                   endif
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
417cA*
417cA*     EXTENDED ITEM DESCRIPTION
417cA*
417bAC     idkey         klist
417cAC                   kfld                    lbwhse
417cAC                   kfld                    lbitem
GFS A*
GFS A*     Order detail misc.
GFS A*
GFS AC     omkey         klist
GFS AC                   kfld                    lbwhse
GFS AC                   kfld                    lbord
GFS AC                   kfld                    lbseq
GFS AC                   kfld                    lbitem
CPJaA*
CPJaA*     Order header misc.
CPJaA*
CPJaAC     ohmky         klist
CPJaAC                   kfld                    pswhse
CPJaAC                   kfld                    psrtid
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
**      TTL   Report title descriptions
Truck Pallet Summary Report
Truck Pallet Detail Report
**      RPD   Report level descriptions

 * Stop totals *
 ** Pallet totals **
 *** Compartment totals ***
 **** Totals ****
**   OVRPRTF statment
OVRPRTF FILE(OR660PR)           OUTQ(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
