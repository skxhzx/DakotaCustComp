     H/copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  HQ121     Update pick slot qty derived from host
     *  17 April, 2002
     *  Hemant Kapadia
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
     *  04/17/02  HNK
     *   - Created - custom for CBI
     *
     *  07/18/03 HNK CBI
     *   - Update pick slot expiration date if date sensitive item
     *     in the slot.  Set to today's date.
     *
CBIaA*  08/01/03 HNK CBIa
     *   - Update ITEMQTY for each item.
     *
CBIbA*  08/20/03 DAS CBIb
     *   - Revised to set slot expiration date to Today + 1.
     *     Re: Slots were expiring after midnight, thus sending
     *     selectors to overflow slots.
CBIcA*  09/02/03  MLB  CBIc
     *   - Revised to only update slot expiration date when it
     *     is less than new date.
CBIdA*  09/15/03  MLB  CBId
     *   - Revised to not allow pick slot stock quantity to go
     *     negative. Set quantity to zero if new pick slot qty
     *     less than zero.
     *
520 A*  07/15/08  MLB  5.20
     *   - Revised PGM to allow pick slot qty to be set to zero
     *     for CBI only. All other clients, qty must go negative.
     *
520aA*  07/30/09  RBD  5.20a
     *   - Fix:  Wouldn't compile, added copysrc for Cheney.
     *
600aA*    08/24/09  MLB  6.00a  P#00065
     *      - Enh: Revised to call LT001 after each pick slot has been
     *        updated to sychronize licsense plate qty's with slot qtys.
     *
640aA*  03/13/12  LMC  6.40a
     *   - Enh:  convert to ILE
     *           Added logic to create IMPFPCKQ for all clients except
     *           TPC and CBI
     *           Changed SLOT1 from primary to full procedural allows
     *           for an easier flow if TPC and CBI versus other client
650aA*  02/24/14  RH   6.50a
     *           Added 600a coce missed in previous updates
     *
     *----------------------------------------------------------------
TPC  *  CUSTOM CHANGES TPC
TPC A*  10/04/07  RH   TPC
     *   - Add Client code for custom changes.
     *   - Allow pick slot quantity to go negative.
     *   - Do NOT update expiration date in pick slot.
TPCaA*  11/01/07  MLB  TPCa
     *   - Revised program to convert IJQTH1 into Total Eaches
     *     for Type B items and add IJTQH2 to Total Eaches and
     *     clear IJTQH2.
TPCbA*  12/03/07  MLB  TPCb
     *   - Revised program to clear item type (ITTYPE) if item
     *     not found on chain to PIRITEM.
TPCcA*  02/04/08  MLB  TPCc
     *   - Disabled TPCa mod. This mod no longer needed due to
     *     how items are configured on Stanpack. Each items can-
     *     not be defined as cases and eaches. Only Eaches are allowed.
TPCdA*  02/08/08  MLB  TPCd
     *   - Revised program to only update the pick slot for Type B=
     *     Breakdown items. This is being done to correct the qty in
     *     pick slot.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Royal Foodservice
     *
RYL A*  07/25/07  JCJ  RYL
     *   - Bypass repack items - Item type 'R'.
     *     Note: Was 5.10 in previous version.
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
640aDF*slot1     up   e           k disk
     *
640aMFslot1     uf   e           k disk
640aDF*slot3     if   e           k disk
640AMFslot3     if   e           k disk    prefix(s3_)
     F                                     rename(slrec:record)
640aMFimpfpckq  o    e             disk
     Fimpfpqty  if   e           k disk
     Fpiritem   if   e           k disk
     Fwarehs    if   e           k disk
     Fhq121pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *                   RPD     1   3 30
     D reck            s              7  0 dim(3)
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *
CBI AD $cvtdt          ds
CBI AD  $cvcmd                 1      8
CBI AD  $cvprg                 9     18
CBI AD  $cvd6i                19     24
CBI AD  $cvd8i                25     32
CBI AD  $cvd6o                33     38  0
CBI AD  $cvd8o                39     46  0
CBI AD  $cvsto                47     64
CBI AD  $cvrtn                65     72
CBI AD  $cverm                73    132
CBI AD  $cvmsg                73     76
     *----------------------------------------------------------------
     *
     D $perm           ds
     D  xxerm                  1     60
     D  $pmsg                  1      4
     *----------------------------------------------------------------
     *  Program info data structure
     *
CBIaAD                sds
CBIaAD  #prog            *proc
CBIaAD  #job                 244    253
CBIaAD  #user                254    263
CBIaAD  #jobn                264    269
CBIaAD  #jobdt               276    281  0
CBIaAD  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  variables
     *
     D $item           s             15
     D $jtyp           s              1
     D $llen           s              3  0
     D $lmsg           s              4
     D $lprg           s             10
     D $lrtn           s              8
     D $lstr           s             60
     D $plen           s              3  0
     D $pstr           s             60
     D $pwhs           s             15  5
640aAd clqty1          s              7  0 inz
640aAd clqty2          s              7  0 inz
640aAd clqty3          s              7  0 inz
     D first           s              1
     D forevr          s              1
     D l               s              1  0
     D m               s                   like(l)
640aAD svitumq2        s                   like(itumq2)
640aAD svitumq3        s                   like(itumq3)
640aAD svslwhse        s                   like(slwhse)
640aAD svslwhdp        s                   like(slwhdp)
640aAD svslaisl        s                   like(slaisl)
     D today           s              8  0
     D type            s              5
640aAd wkTtlQty        s              7  0 inz
640aAd inTtlQty        s              7  0 inz
640aAd svTtlQty        s              7  0 inz
640aAd wkqty1          s              7  0 inz
640aAd wkqty2          s              7  0 inz
     *
TPC  *----------------------------------------------------------------
TPC A*  Customer Id
TPC AI*
640aD */COPY QCOPYSRC,IL#TPC
640aD */COPY QCOPYSRC,IL#CHENEY
640aM /COPY QCOPYSRC,ID#TPC
640aM /COPY QCOPYSRC,ID#CHENEY
RYL A /copy qcopysrc,id#royal
     *----------------------------------------------------------------
640aDI*slrec
640aDI*                                          slwhse        l1
640aDI*                                          slwhdp        l1
640aDI*                                          slaisl        l1
640aDI*record
640aDI*             slwhse                      s3whse
640aDI*             slwhdp                      s3whdp
640aDI*             slaisl                      s3aisl
640aDI*             slloc                       s3loc
640aDI*             slrlvl                      s3rlvl
640aDI*             slhand                      s3hand
640aDI*             slside                      s3side
640aDI*             slstyp                      s3styp
640aDI*             sldisp                      s3disp
640aDI*             slstat                      s3stat
640aDI*             slsdte                      s3sdte
640aDI*             slstim                      s3stim
640aDI*             slsdef                      s3sdef
640aDI*             sldesg                      s3desg
640aDI*             slactv                      s3actv
640aDI*             slbld                       s3bld
640aDI*             slpick                      s3pick
640aDI*             slpseq                      s3pseq
640aDI*             slprty                      s3prty
640aDI*             slentd                      s3entd
640aDI*             slexpd                      s3expd
640aDI*             slslfd                      s3slfd
640aDI*             slrsrv                      s3rsrv
640aDI*             slitem                      s3item
640aDI*             slstk1                      s3stk1
640aDI*             slstk2                      s3stk2
640aDI*             slstk3                      s3stk3
640aDI*             slalc1                      s3alc1
640aDI*             slalc2                      s3alc2
640aDI*             slalc3                      s3alc3
640aDI*             sltfr1                      s3tfr1
640aDI*             sltfr2                      s3tfr2
640aDI*             sltfr3                      s3tfr3
640aDI*             slpck1                      s3pck1
640aDI*             slpck2                      s3pck2
640aDI*             slpck3                      s3pck3
640aDI*             slrcv1                      s3rcv1
640aDI*             slrcv2                      s3rcv2
640aDI*             slrcv3                      s3rcv3
     *----------------------------------------------------------------
     *
     C     *entry        plist
     C                   parm                    $whdp             5
     C                   parm                    $aisl             3
     *
     *  Report Heading
     *
     *
     *  Start new page if one of following happened.
     *     - Page overflow.
     *
     *  PAGE OVERFLOW
640aAc                   select
640aAc                   when      client = tpc or client = cheney
640aAc                   dow       forevr = forevr
640aAc                   read      slot1
640aAc                   if        %eof(slot1)
640aAc                   eval      *inlr = *on
640aM* REPORT TOTALS
640aMC                   eval      l = 2
640aA*
640aMC                   if        reck(l) > 0
640aMC                   write     skip1
640aMC                   write     foot1
640aMC                   endif
640aAc                   leave
640aAc                   endif
640aA*
640aA* when saved fields don't match need to do old L1 processing
640aAc                   if        svslwhse <> 0
640aAc                   if        slwhse <> svslwhse or
640aAc                             slwhdp <> svslwhdp or
640aAc                             slaisl <> svslaisl
640aA* Whse/Dept/Aisle totals
640aMC                   eval      l = 1
640aMC                   exsr      zrroll
640aA*
640aAc                   endif
640aAc                   endif
     *
     C                   if        first = *on  or
     C                             *in90  or
640aDC*                            *inl1
640aAc                             slwhse <> svslwhse or
640aAc                             slwhdp <> svslwhdp or
640aAc                             slaisl <> svslaisl
     C                   exsr      zrhead
     C                   endif
     *
     *
     *  Init total levels
     *
     *
     *  Level 1 break - Whse/Dept/Aisle
     *
640aDC*                  if        *inl1
640aAc                   if        slwhse  <> svslwhse or
640aAc                             slwhdp  <> svslwhdp or
640aAc                             slaisl  <> svslaisl
     C                   eval      l = 1
     C                   exsr      zrzero
     C                   endif
     *
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *
     C                   eval      t#disp = sldisp
     C                   eval      t#item = slitem
640aAc                   eval      svslwhse = slwhse
640aAc                   eval      svslwhdp = slwhdp
640aAc                   eval      svslaisl = slaisl
     *
     *  Get item description.
     *
     C     keyit         chain     piritem                            79
     C                   if        *in79
     C                   eval      itdesc = *blanks
TPCbAC                   eval      ittype = *blanks
     C                   endif
RYL AC*
RYL AC*  SKIP Repack items
RYL AC*
RYL AC                   if        client = Royal
RYL A*
RYL AC                   if        ittype = 'R'
RYL AC                   goto      #skip
RYL AC                   endif
RYL A*
RYL AC                   endif
     *
     C                   exsr      oflqty
     C     keyij         chain     impfpqty                           79
     C                   if        *in79
     C                   eval      ijtqh1 = 0
     C                   eval      ijtqh2 = 0
     C                   endif
TPCaA*
TPCaAC                   if        tpc = client
TPCaA*
TPCaA*    If item is Breakdown, convert Cases to Total Eaches.
TPCdA*    Only allow Breakdown items to be updated.
TPCaAC                   if        ittype = 'B'
TPCcD*                    EXSR ZZCVQY
TPCdAC                   else
TPCdA*    Skip updates for all other item types.
TPCdAC                   goto      #skip
TPCaAC                   endif
TPCaA*
TPCaAC                   endif
TPCaA*
     C                   eval      pckqt1 = ijtqh1 - ofqty1
     C                   eval      pckqt2 = ijtqh2 - ofqty2
     *
     *  Write detail line.
     *
     C                   write     detail1
     *
     *  Update pick slot.
     *
TPC AC                   if        client <> tpc
CBI AC                   if        itflgd = 'Y'  and
CBIcAC                             slexpd < today
CBIbD**                   Z-ADDTODAY     SLEXPD
CBIbMC                   eval      slexpd = today1
CBI AC                   endif
TPC AC                   endif
CBIdAC                   if        pckqt1 < 0  and
520 D*          CLIENT    ANDNETPC
520 MC                             client = cheney
CBIdAC                   eval      slstk1 = *zeros
CBIdAC                   else
     C                   z-add     pckqt1        slstk1
CBIdAC                   endif
CBIdAC                   if        pckqt2 < 0  and
520 D*          CLIENT    ANDNETPC
520 MC                             client = cheney
CBIdAC                   eval      slstk2 = *zeros
CBIdAC                   else
     C                   z-add     pckqt2        slstk2
CBIdAC                   endif
     C                   update    slrec
     * Recalculate item qty for slot item
CBIaAC                   eval      $item = slitem
CBIaAC                   exsr      zzrcal
600aA*
600aA*  Synchronize license qtys with slot qtys
600aA*
600aAC                   call      'LT001'
600aAC                   parm      'HQ '         lpactn            3
600aAC                   parm      SLWHSE        lpwhse            3 0
600aAC                   parm      SLWHDP        lpwhdp            5
600aAC                   parm      SLDISP        lpdisp           12
600aAC                   parm      ' '           lpdumy            1
     *
     *  Increment record counters
     *
     C                   add       1             reck(1)
     *
     *  Set off top-of-page indicators
     *
     C                   eval      first = *off
     C                   eval      *in91 = *off
TPCdAC     #skip         tag
640aAc                   enddo
640aA*
640aA*  All other NDS clients
640aA*
640aAc                   other
640aAc                   dow       forevr = forevr
640aAc                   read      impfpqty
640aAc                   if        %eof(impfpqty)
640aAc                   eval      *inlr = *on
640aA* REPORT TOTALS
640aAC                   eval      l = 2
640aA*
640aAC                   if        reck(l) > 0
640aAC                   write     skip1
640aAC                   write     foot1
640aAC                   endif
640aAc                   leave
640aAc                   endif
640aA*
640aA*  Report Heading
640aAC                   if        first = *on  or
640aAC                             *in90
640aAC                   exsr      zrhead1
640aAC                   endif
640aA*
640aA*----------------------------------------------------------------
640aA*
640aA* Detail Calcs
640aA*
640aA*  Get item description.
640aA*
640aAC     keyit1        chain     piritem                            79
640aAC                   if        *in79
640aAC                   eval      itdesc = *blanks
640aAC                   eval      ittype = *blanks
640aAC                   endif
640aA*
640aAC                   exsr      clcqty
640aA*
640aA*  Write detail line.
640aA*
640aAC                   write     detail11
640aA*
640aA*  Increment record counters
640aA*
640aAC                   add       1             reck(1)
640aA*
640aA*  Set off top-of-page indicators
640aA*
640aAC                   eval      first = *off
640aAC                   eval      *in91 = *off
640aA* if no variance in qty don't write impfpckq record
640aAc                   if        wkTtlQty = inTtlQty
640aAc                   iter
640aAc                   endif
640aA*
640aA*  write impfpckq record
640aA*
640aA
640aAc                   eval      ipqwhd = ' '
640aAc                   eval      ipqdsp = ' '
640aAc                   eval      ipqwhs = ijwhse
640aAc                   eval      ipqitm = ijitem
640aAc                   eval      ipqadj = 'MV'
640aAc                   eval      ipqmem = ' '
640aAc                   eval      ipqsof = 'Y'
640aAC                   write     ipqrec
640aAc                   enddo
640aAc                   endsl
     *----------------------------------------------------------------
     *
     * Whse/Dept/Aisle totals
     *
640aDC*L1                 eval      l = 1
640aDC*L1                 exsr      zrroll
     *
     *----------------------------------------------------------------
     *
     * REPORT TOTALS
     *
640aDC*Lr                 eval      l = 2
     *
640aDC*Lr                 if        reck(l) > 0
640aDC*Lr                 write     skip1
640aDC*Lr                 write     foot1
640aDC*Lr                 endif
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
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
     *  Define key for main file.
     *
     C     keyit         klist
     C                   kfld                    slwhse
     C                   kfld                    slitem
640aA*
640aA*  Define key for piritem
640aA*
640aAC     keyit1        klist
640aAC                   kfld                    ijwhse
640aAC                   kfld                    ijitem
     *
     *  Define partial key for SLOT3 file.
     *
     C     keysl3        klist
     C                   kfld                    slwhse
     C                   kfld                    slitem
640aA*
640aA*  Define partial key for SLOT3 file.
640aA*
640aAC     keysl3i       klist
640aAC                   kfld                    ijwhse
640aAC                   kfld                    ijitem
     *
     *  Define key for IMPFPQTY FILE.
     *
     C     keyij         klist
     C                   kfld                    slwhse
     C                   kfld                    t#item
     *
     *
     *  Convert today's date into century format.
     *
CBI AC                   eval      $cvcmd = '*CURCMD '
CBI AC                   call      @cvtdt
CBI AC                   parm                    $cvtdt
CBI AC                   eval      today = $cvd8o
     C                   time                    time
CBIbA*
CBIbA*  Add 1 to today's date.
CBIbA*
     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cmd              8
     C                   parm      today         $datei            8 0
     C                   parm      0             $timei            6 0
     C                   parm      0             $years            3 0
     C                   parm      0             $month            3 0
     C                   parm      1             $days             3 0
     C                   parm      0             $hours            3 0
     C                   parm      0             $min              3 0
     C                   parm      0             $sec              3 0
     C                   parm      0             today1            8 0
     C                   parm      0             $timeo            6 0
     *
     C                   eval      first = *on
     C                   eval      forevr = *on
     C                   eval      l = 2
     C                   exsr      zrzero
     C                   endsr
640aA*----------------------------------------------------------------
640aA*
640aAC     clcqty        begsr
640aA*
640aAC                   eval      clqty1 = 0
640aAC                   eval      clqty2 = 0
640aAC                   eval      clqty2 = 0
640aAC                   eval      ipqqp1 = 0
640aAC                   eval      ipqqp2 = 0
640aAC                   eval      ipqqp3 = 0
640aAC                   eval      wkqty1 = 0
640aAC                   eval      wkqty2 = 0
640aA
640aAC     keysl3i       setll     slot3
640aAC                   dow       forevr = *on
640aAC     keysl3i       reade     slot3                                  79
640aAC                   if        *in79
640aAC                   leave
640aAC                   endif
640aA*
640aAc                   eval      clqty1 = clqty1 + s3_slstk1
640aAc                   eval      clqty2 = clqty2 + s3_slstk2
640aAc                   eval      clqty3 = clqty3 + s3_slstk3
640aA*
640aAC                   enddo
640aA* convert qty to lowest uom
640aA*    Set Brkdwn 1 qty for conversion calcs below.
640aAC                   eval      svitumq2 = itumq2
640aAC                   if        itumq2 <= 0
640aAC                   eval      itumq2 = 1
640aAC                   endif
640aA
640aA*    Set Brkdwn 2 qty for conversion calcs below.
640aAC                   eval      svitumq3 = itumq3
640aAC                   if        itumq3 <= 0
640aAC                   eval      itumq3 = 1
640aAC                   endif
640aa
640aAC                   eval      wkTtlQty = (clqty1 * itumq2 * itumq3)
640aAC                                      + (clqty2 * itumq3)
640aAC                                      +  clqty3
640aA*
640aA*
640aA*    Convert imported qty's to lowest form.
640aAC                   eval      inTtlqty = (ijtqh1 * itumq2 * itumq3)
640aAC                                      + (ijtqh2 * itumq3)
640aA*    now convert imported qty back up
640aA* determine adjust qty fields
     c                   select
640aAc                   when      wkTtlQty = inTtlQty
640aAc                   eval      ipqqp1 = 0
640aAc                   eval      ipqqp2 = 0
640aAc                   eval      ipqqp3 = 0
640aAC                   other
640aA
640aAc                   if        svitumq2 = 0
640aAc                   eval      wkqty2 = 0
640aAc                   eval      wkqty1 = inttlqty
640aAc                   else
640aAc                   eval      svttlqty  = inttlqty
640aAc                   eval      wkqty2 = svttlqty
640aAc                   eval      wkqty1 = 0
640aAc                   dow       svitumq2 > 0 and svttlqty >= svitumq2
640aAc                   eval      wkqty2 = wkqty2 - svitumq2
640aAc                   eval      svttlqty = svttlqty - svitumq2
640aAc                   eval      wkqty1 = wkqty1 + 1
640aAc                   enddo
640aAc                   endif
640aAc                   eval      ipqqp1 = clqty1 - wkqty1
640aAc                   eval      ipqqp2 = clqty2 - wkqty2
640aAc                   eval      ipqqp3 = 0
640aAc                   endsl
640aAC                   endsr
640aA
     *----------------------------------------------------------------
     *
     C     oflqty        begsr
     *
     C                   eval      ofqty1 = 0
     C                   eval      ofqty2 = 0
     C     keysl3        setll     slot3
     C                   dow       forevr = *on
     C     keysl3        reade     slot3                                  79
     C                   if        *in79
     C                   leave
     C                   endif
640aDC*                  if        s3pick = 'Y'
640aMC                   if        s3_slpick = 'Y'
     C                   iter
     C                   endif
     *
640aDC*                  add       s3stk1        ofqty1
640aDC*                  add       s3stk2        ofqty2
640aMC                   add       s3_slstk1     ofqty1
640aMC                   add       s3_slstk2     ofqty2
     *
     C                   enddo
     *
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
640aA*----------------------------------------------------------------
640aA*
640aAC     zrfrmt1       begsr
640aA*
640aA*   Get warehouse description.
640aA*
640aAC                   eval      whse = *blanks
640aAC                   eval      $pstr = *blanks
640aAC     ijwhse        chain     warehs                             79
640aAC                   if        not *in79
640aAC                   movel     whdesc        $pstr
640aAC                   else
640aAC                   eval      $pstr = *blanks
640aAC                   endif
640aAC                   eval      $plen = 30
640aA*
640aA*   Center warehouse description.
640aA*
640aAC                   call      'CENTER'
640aAC                   parm                    $pstr
640aAC                   parm                    $plen
640aAC                   movel     $pstr         whse
640aAC                   endsr
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
640aAc                   if        slwhse <> svslwhse or
640aAc                             slwhdp <> svslwhdp or
640aAc                             slaisl <> svslaisl
640aDC*                  if        *inl1
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
640aA*----------------------------------------------------------------
640aA*
640aAC     zrhead1       begsr
640aA*
640aAc                   if        first = *on
640aAC                   exsr      zrfrmt1
640aAC                   else
640aAC                   eval      *in91 = *on
640aAC                   endif
640aA*
640aAC                   eval      *in90 = *off
640aA*
640aAC                   write     head11
640aAC                   write     head2
640aAC                   write     columns1
640aA*
640aAC                   endsr
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
CBIaA*  ZZRCAL   Recalculate item quantity from slots.
     *
CBIaAC     zzrcal        begsr
     *
     * Recalculate item qty.
     C                   eval      $pwhs = slwhse
     C                   eval      $jtyp = *off
     C                   eval      $lprg = #prog
     C                   eval      $lrtn = *blanks
     C                   eval      $lmsg = *blanks
     C                   call      'UT812'
     C                   parm                    $pwhs
     C                   parm                    $item
     C                   parm                    $jtyp
     C                   parm                    $lprg
     C                   parm                    $lrtn
     C                   parm                    $lmsg
     *
CBIaAC     endcal        endsr
TPCaA*
TPCaA*----------------------------------------------------------------
TPCaA*
TPCaA*  ZZCVQY   Convert Total Cases to Total Eaches.
TPCaA*
TPCaAC     zzcvqy        begsr
TPCaA*
TPCaA*     Convert total cases into total eaches for
TPCaA*     Breakdown items.
TPCaAC                   select
TPCaAC                   when      ittype = 'B'
TPCaA*
TPCaAC                   call      'GETBASE'
TPCaAC                   parm      itwhse        $gwhse            3 0
TPCaAC                   parm      ititem        $gitem           15
TPCaAC                   parm      ' '           #bitem           15
TPCaAC                   parm      ' '           #bityp            1
TPCaAC                   parm      ' '           #bdesc           30
TPCaAC                   parm      ' '           #bpdsc           15
TPCaAC                   parm      ' '           #bwhdp            5
TPCaAC                   parm      ' '           #bstyp            1
TPCaAC                   parm      ' '           #bum              2
TPCaAC                   parm      ' '           #bum2             2
TPCaAC                   parm      0             #bumq2            3 0
TPCaAC                   parm      ' '           #bum3             2
TPCaAC                   parm      0             #bumq3            3 0
TPCaAC                   parm      ' '           #bcitm           15
TPCaAC                   parm      ' '           #bctyp            1
TPCaAC                   parm      ' '           #bcdsc           30
TPCaAC                   parm      ' '           #bcpds           15
TPCaAC                   parm      ' '           #bcwdp            5
TPCaAC                   parm      ' '           #bcstp            1
TPCaAC                   parm      ' '           #bcum             2
TPCaAC                   parm      ' '           #bcum2            2
TPCaAC                   parm      0             #bcuq2            3 0
TPCaAC                   parm      ' '           #bcum3            2
TPCaAC                   parm      0             #bcuq3            3 0
TPCaAC                   parm      ' '           #brtn             8
TPCaA*
TPCaAC                   if        #bumq2 > 0
TPCaAC     #bumq2        mult      ijtqh1        ijtqh1
TPCaAC                   endif
TPCaAC                   add       ijtqh2        ijtqh1
TPCaAC                   eval      ijtqh2 = *zeros
TPCaA*
TPCaAC                   endsl
TPCaA*
TPCaAC     endcvq        endsr
TPCaA*
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
