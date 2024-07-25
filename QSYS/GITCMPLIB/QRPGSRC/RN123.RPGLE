     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  RN123     Customer return whole order - Process Auto Put away
     *  09 November, 2004
     *  Roxanne Harrison
     *
     *  Revisions:
     *    11/09/04  RH   5.0
     *      - Created.
640aA*    06/07/12  LMC  6.40a
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
     *
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
     Frn123     ip   e           k disk
     Fpiritem   if   e           k disk
     Fpirtran   uf   e           k disk
     Fslot2     uf a e           k disk
     Fvslot2    o  a e           k disk
     FLabel     o  a e           k disk
     Forrtn     o  a e           k disk
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *
     D a22             s              1    dim(22)
     D a2              s              1    dim(2)
     D a2n             s              1    dim(2)
     D hnd             s              2    dim(702)
     D ltr             s              1    dim(27) ctdata perrcd(27)
     *
     *
     *----------------------------------------------------------------
     * Data structure
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     *
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
640aA*----------------------------------------------------------------
640aA*  Prototypes
640aA*----------------------------------------------------------------
640aA
640aAD wrttran1        pr                  extpgm('WRTTRAN1')
640aA * Input
640aAD   ppcmd                        8
640aAD   ppwait                       2  0
640aAD   ppwhse                       3  0
640aAD   pptran#                      7  0
640aAD   ppfromdate                   8  0
640aAD   pptodate                     8  0
640aAD   ppemp#                       5  0
     *----------------------------------------------------------------
     *  Called program parameters
     *
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
     D  $litem                22     36
     *
     D  $lcode                19     20
     *
     D  $ltrn#                19     25  0
     *
     D  $luser                19     28
     *
     D  $lpo                  37     45
     D  $lrq1                 46     50  0 inz(0)
     D  $lrq2                 51     55  0 inz(0)
     D  $lrq3                 56     60  0 inz(0)
     D  $lrpal                61     63  0
     *----------------------------------------------------------------
     *
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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
     D                 ds
     D  t#date                 1      6  0
     D  month                  1      2  0
     D  day                    3      4  0
     D  year                   5      6  0
     D @adjt2          c                   const('ADJTRAN2')
     *----------------------------------------------------------------
     D @dslot          c                   const('DCK-101-1')
     *----------------------------------------------------------------
     *  Variables
     D $crq1           s              5  0
     D $crq2           s              5  0
     D $crq3           s              5  0
     D $lord           s              7  0
     D $pbat#          s              7  0
     D $pcod#          s              7  0
     D $plod#          s              7  0
     D $pwhse          s              3  0
     D $vaisl          s              3
     D $vloc           s              3  0
     D $vpick          s              1
     D $vpseq          s              5  0
     D $vrlvl          s              2  0
     D $vstyp          s              1
     D $vwhdp          s              5
     D $vwhse          s              3  0
     D error           s              1
     D first           s              1
     D flaghs          s              1
     D i               s              2  0
     D j               s              2  0
     D k               s              3  0
     D newvs           s              1
     D odisp           s                   like(sldisp)
     D phactv          s                   like(slactv)
     D phaisl          s                   like(slaisl)
     D phbld           s                   like(slbld)
     D phdesg          s                   like(sldesg)
     D phdisp          s                   like(sldisp)
     D phhand          s                   like(slhand)
     D phloc           s                   like(slloc)
     D phpseq          s                   like(slpseq)
     D phrlvl          s                   like(slrlvl)
     D phsdef          s                   like(slsdef)
     D phside          s                   like(slside)
     D phslfd          s                   like(slslfd)
     D phstat          s                   like(slstat)
     D phstyp          s                   like(slstyp)
     D phwhdp          s                   like(slwhdp)
     D phwhse          s                   like(slwhse)
     D svdisp          s                   like(sldisp)
     D svexpd          s                   like(slexpd)
     D svitem          s                   like($aitem)
     D tlcube          s             11  3
     D tlpcs           s              7  0
     D tlswgt          s             11  2
     D tmpflg          s              1
     D today           s              8  0
     D trndte          s              8  0
     D trntim          s              6  0
     D wotosl          s             12
640aAD wrtpcmd         s             10
640aAD wrtpwait        s              2  0
640aAD wrtpwhse        s              3  0
640aAD wrtptran#       s                   like(pttrn#)
640aAD wrtpfrmdate     s              8  0
640aAD wrtptodate      s              8  0
640aAd wrtpemp#        s                   like(ptemp#)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse #
     *      $PRTN   Return
     *      $PLORD  Label order#
     *      $PMPUT  Manual put away
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhs             3
     C                   parm                    $prtn             8
     C                   parm                    $plord            7
     C                   parm                    $pmput            1
     C                   parm                    $pcode            2
     C                   parm                    $pdcde            5
     C                   parm                    $puser           10
     C                   parm                    $pcord            7
     C                   parm                    $pinvf            1
     C                   parm                    $pbat             7
     C                   move      $pwhs         $pwhse
     C                   move      $plord        $plod#
     C                   move      $pcord        $pcod#
     C                   move      $pbat         $pbat#
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C                   eval      $lcmd = '*CHANGE '
     C                   eval      $lwhse = $pwhse
     C                   eval      $crq1 = 0
     C                   eval      $crq2 = 0
     C                   eval      $crq3 = 0
     C                   select
     C                   when      lqutyp = 'N'
     C                   eval      $crq1 = lqqpck
     C                   when      lqutyp = '1'
     C                   eval      $crq2 = lqqpck
     C                   when      lqutyp = '2'
     C                   eval      $crq3 = lqqpck
     C                   endsl
     C                   eval      $litem = lqitem
     C                   eval      $lrpal = 1
     * $PCOD# IS CUSTOMER ORDER #
     C                   eval      $lord = $pcod#
     * Get item info.
     C                   exsr      zzgeti
     * Get 1st pick slot or overflow
     C                   eval      $gcmd = '*FIRST  '
     C                   eval      $gwhse = $pwhse
     C                   call      'GETPSLT'
     C                   parm                    $gcmd             8
     C                   parm                    $gwhse            3 0
     C                   parm      #bitem        $gitem           15
     C                   parm      *blanks       $gslot           12
     C                   parm      *blanks       $gaisl            3
     C                   parm      *zeros        $gloc             3 0
     C                   parm      *zeros        $grlvl            2 0
     C                   parm      *blanks       $ghand            2
     C                   parm      *blanks       $grtn             8
     *
     C                   select
     C                   when      $grtn = '*OKPICK '
     C                   eval      wotosl = $gslot
     C                   other
     C                   movel     @dslot        wotosl
     C                   eval      $gaisl = 'DCK'
     C                   eval      $gloc = 101
     C                   eval      $grlvl = 1
     C                   eval      $ghand = *blanks
     C                   endsl
     * Create label and transaction for Auto put away
     C                   exsr      zzusub
     * Update slot with return quantity
     C                   exsr      zzuslt
     *      Product put away. Write return record                     .
     C                   clear                   orrec
     C                   eval      orwhse = $pwhse
     C                   eval      ortrn# = lqtrn#
     *
     C                   eval      orord = $pcod#
     C                   eval      orpbat = $pbat#
     C                   eval      oritem = lqitem
     C                   eval      orqty1 = $crq1
     C                   eval      orqty2 = $crq2
     C                   eval      orqty3 = $crq3
     C                   eval      orcwtr = 0
     C                   eval      orrdte = today
     C                   time                    orrtim
     C                   eval      orrusr = $puser
     C                   eval      ortype = 'A'
     C                   eval      ortrn# = lqtrn#
     C                   eval      orcitm = *blanks
     C                   eval      orrcod = $pcode
     C                   eval      ordcod = $pdcde
     C                   eval      oriinv = 'Y'
     C                   eval      orolb# = lqlbl#
     C                   eval      orinv# = *blanks
     C                   move      'WHOLE OD'    orrmem
     C                   eval      orslot = *blanks
     C                   eval      oroord = lqord
     C                   eval      orwhol = 'Y'
     C                   write     orrec
     *
     *
     *
     C     endit1        tag
     CLr                 exsr      zzclst
     CLr                 return
     *
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
     C                   eval      first = *on
     C                   eval      error = *off
     C                   eval      $cvprg = #prog
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     *
     C     itkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    lqitem
     *
     C     partk2        klist
     C                   kfld                    $lord
     C                   kfld                    $pwhse
     *
     C     tokey         klist
     C                   kfld                    lqwhse
     C                   kfld                    lqwhdp
     C                   kfld                    wotosl
     *
     C     ckkey         klist
     C                   kfld                    lqwhse
     C                   kfld                    lqwhdp
     C                   kfld                    $vdisp
     *
     *
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   exsr      zzinz2
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     C                   eval      tlcube = *zeros
     C                   eval      tlswgt = *zeros
     C                   eval      tlpcs = *zeros
     C                   eval      trndte = *zeros
     C                   eval      trntim = *zeros
     *
     *   Load handstack array with codes (A..Z, AA..AZ, ...)
     *
     C                   eval      k = 0
     C     1             do        27            i
     C     2             do        27            j
     C                   add       1             k
     C     ltr(i)        cat       ltr(j)        hnd(k)
     C                   enddo
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCKDS   Use reg slot or get new Vslot.
     *
     C     zzckds        begsr
     C                   eval      error = *on
     C                   eval      newvs = *off
     C     tokey         chain(n)  slot2                              79
     C                   if        not *in79
     C                   if        slitem = *blanks
     C                   eval      error = *off
     C                   goto      endckn
     C                   else
     *   DOCK SLOT SHOULD NOT BE A PICK SLOT.
     *   Get out if physical slot is a pick slot so we do not
     *   create virtual pick slots.
     C                   if        slpick = 'Y'
     C                   eval      error = *on
     C                   goto      endckn
     C                   endif
     *   Get out if physical slot already uses both
     *   positions of handstack field.
     C                   movea     slhand        a2
     C                   if        a2(1) <> ' '
     C                   goto      endckn
     C                   endif
     *   Set handstack flag for later use.
     C                   if        slhand <> ' '
     C                   eval      flaghs = *on
     C                   else
     C                   eval      flaghs = *off
     C                   endif
     * SAVE PHYSICAL SLOT FIELDS
     C                   eval      phwhse = slwhse
     C                   eval      phwhdp = slwhdp
     C                   eval      phstat = slstat
     C                   eval      phaisl = slaisl
     C                   eval      phloc = slloc
     C                   eval      phrlvl = slrlvl
     C                   eval      phhand = slhand
     C                   eval      phside = slside
     C                   eval      phstyp = slstyp
     C                   eval      phdisp = sldisp
     C                   eval      phsdef = slsdef
     C                   eval      phdesg = sldesg
     C                   eval      phpseq = slpseq
     C                   eval      phactv = slactv
     C                   eval      phbld = slbld
     C                   eval      phslfd = slslfd
     ***
     C                   eval      $vpseq = slpseq
     C                   eval      $vdisp = *blanks
     C                   eval      k = 0
     C                   eval      $vwhse = slwhse
     C                   eval      $vwhdp = slwhdp
     C                   eval      $vaisl = slaisl
     C                   eval      $vloc = slloc
     C                   eval      $vrlvl = slrlvl
     C                   eval      $vhand = *blanks
     C                   eval      $vstyp = slstyp
     C                   eval      $vpseq = slpseq
     C                   eval      $vdisp = *blanks
     C                   eval      $vpick = slpick
     *** Loop & increment handstack to find new v-slot to create.
     C                   dow       k < 702
     C                   add       1             k
     *     If physical slot had handstack then limit hs we can use.
     C                   if        flaghs = *on
     C                   movea     hnd(k)        a2n
     C                   if        a2n(1) <> a2(2)
     C                   iter
     C                   endif
     C                   endif
     C                   eval      $vhand = hnd(k)
     C                   call      'FRMTVS'
     C                   parm                    phdisp
     C                   parm                    flaghs
     C                   parm                    $vhand            2
     C                   parm                    $vdisp           12
     *
     C     ckkey         chain(n)  slot2                              79
     C                   if        *in79
     C                   eval      newvs = *on
     C                   eval      error = *off
     C                   eval      wotosl = $vdisp
     C                   leave
     C                   else
     C                   iter
     C                   endif
     C                   enddo
     C                   endif
     C                   endif
     *
     C     endckn        endsr
     *----------------------------------------------------------------
     *
     *  ZZCLST   Close trans, update totals and emp#
     *
     C     zzclst        begsr
     *    - Update totals in trans.
     *
     C                   call      @adjt2
     C                   parm      '*INCTTL '    @pcmd
     C                   parm      #job          @pprg
     C                   parm      '*INTER  '    @ptype
     C                   parm      pttrn#        @ptrn#
     C                   parm      'PUTRTN'      @ptask
     C                   parm      $pwhse        @pwhse
     C                   parm      *blanks       @pwhdp
     C                   parm      lqstyp        @pstyp
     C                   parm      tlcube        @pcube
     C                   parm      tlswgt        @pswgt
     C                   parm      tlpcs         @ppcs
     C                   parm      0             @paisl
     C                   parm      0             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      ' '           @prte
     C                   parm      ' '           @ppo
     C                   parm      'R'           @pgrp1
     C                   parm      ' '           @pgrp2
     C                   parm      0             @pdate
     C                   parm      0             @ptime
     C                   parm      #user         @puser
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *  Close transaction
     C                   call      @adjt2
     C                   parm      '*CLOSE  '    @pcmd
     C                   parm      #job          @pprg
     C                   parm      '*INTER  '    @ptype
     C                   parm      pttrn#        @ptrn#
     C                   parm      'PUTRTN'      @ptask
     C                   parm      $pwhse        @pwhse
     C                   parm      *blanks       @pwhdp
     C                   parm      lqstyp        @pstyp
     C                   parm      0             @pcube
     C                   parm      0             @pswgt
     C                   parm      0             @ppcs
     C                   parm      0             @paisl
     C                   parm      0             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      lqrte         @prte
     C                   parm      ' '           @ppo
     C                   parm      'R'           @pgrp1
     C                   parm      ' '           @pgrp2
     C                   parm      0             @pdate
     C                   parm      0             @ptime
     C                   parm      #user         @puser
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     *    - Remove shift, crew, emp# for transaction
     C     @ptrn#        chain     pirtran                            77
     C                   if        not *in77
     C                   eval      ptstat = '4'
     C                   eval      ptsdte = today
     C                   time                    ptstim
     C                   eval      ptedte = today
     C                   time                    ptetim
     C                   eval      ptcdte = today
     C                   time                    ptctim
     C                   eval      ptshft = *blanks
     C                   eval      ptcrew = *blanks
     C                   eval      ptemp# = 0
     C                   update    ptrec                                77
     C                   if        *in77
     *R                   MOVE *ON       ERROR
     ***                  EXSR ZM72
     C                   endif
640aAc                   exsr      zzwrttrand
     C                   endif
     *
     C     endcls        endsr
     *----------------------------------------------------------------
     *
     *  ZZGETI   Get item information.
     *
     C     zzgeti        begsr
     C                   eval      error = *off
     C     itkey         chain     piritem                            79
     C                   if        *in79
     C                   eval      ittype = *blanks
     C                   endif
     *
     *  Save information about item being received (Item that was ordered)
     *
     C                   eval      #bitem = lqitem
     *
     *  If Contract, Alias or SSB Item
     *   Then verify Base item exists.
     *
     C                   if        ittype = 'C'  or
     C                             ittype = 'A'  or
     C                             ittype = 'S'
     *
     C                   call      'GETBASE'
     C                   parm      lqwhse        $gwhse
     C                   parm      lqitem        $gitem
     C                   parm      ' '           #bitem           15
     C                   parm                    #bityp            1
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     C                   parm                    #bwhdp            5
     C                   parm                    #bstyp            1
     C                   parm                    #bum              2
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
     C                   parm                    #bcum             2
     C                   parm                    #bcum2            2
     C                   parm                    #bcuq2            3 0
     C                   parm                    #bcum3            2
     C                   parm                    #bcuq3            3 0
     C                   parm                    #brtn             8
     *
     C                   endif
     *
     C     endgti        endsr
     *----------------------------------------------------------------
     *
     *  ZZUSLT   Update Slot records.
     *
     C     zzuslt        begsr
     C                   eval      error = *off
     *   Update the "To Slot" record.
     *
     C     tokey         chain     slot2                              79
     C                   if        *in79
     C                   clear                   slrec
     C                   eval      slstat = 'V '
     C                   select
     C                   when      lqutyp = 'N'
     C                   add       lqqpck        slstk1
     C                   when      lqutyp = '1'
     C                   add       lqqpck        slstk2
     C                   other
     C                   add       lqqpck        slstk3
     C                   endsl
     C                   else
     C                   if        slstk1 = 0  and
     C                             slstk2 = 0  and
     C                             slstk3 = 0  and
     C                             slrcv1 = 0  and
     C                             slrcv2 = 0  and
     C                             slrcv3 = 0
     C                   eval      slentd = today
     C                   endif
     C                   select
     C                   when      lqutyp = 'N'
     C                   add       lqqpck        slstk1
     C                   when      lqutyp = '1'
     C                   add       lqqpck        slstk2
     C                   other
     C                   add       lqqpck        slstk2
     C                   endsl
     C                   endif
     **
     C                   if        slstat = 'Z '  or
     C                             slstat = 'V '
     C                   eval      slstat = 'A '
     C                   eval      slentd = today
     C                   eval      slsdte = today
     C                   time                    slstim
     C                   eval      slprty = 0
     C                   endif
     C                   eval      slitem = lqitem
     *     There is no expiration date available for Re-do Returns.
     *
     *     Don't allow zero entered date.
     *
     C                   if        slentd = 0
     C                   eval      slentd = today
     C                   endif
     *  Set priority for a return put into a non fix pick slot.
     *  Set priority for a return put into non-reserved pick slot.
     C                   if        slpick = 'Y'  and
     C                             slrsrv <> 'Y'
     C                   eval      slprty = -(9)
     C                   endif
     *
     *  Create new slot record
     *  $V = from Physical slot when virtual was checked
     *  PH = from saved from physical slot when virtual was checked
     *  SV = saved from 'FROM' slot.
     *  SL = saved from 'FROM' slot.
     C                   if        newvs = *on
     C                   eval      slwhse = $vwhse
     C                   eval      slwhdp = $vwhdp
     C                   if        phstat <> 'Z '  and
     C                             phstat <> 'V '
     C                   eval      slstat = phstat
     C                   else
     C                   eval      slstat = 'A '
     C                   endif
     C                   eval      slaisl = $vaisl
     C                   eval      slloc = $vloc
     C                   eval      slrlvl = $vrlvl
     C                   eval      slhand = $vhand
     C                   eval      slside = phside
     C                   eval      slstyp = $vstyp
     C                   eval      sldisp = $vdisp
     C                   eval      slsdef = phsdef
     C                   eval      sldesg = phdesg
     C                   eval      slactv = phactv
     C                   eval      slbld = phbld
     C                   eval      slpick = $vpick
     C                   eval      slpseq = $vpseq
     C                   eval      slslfd = 0
     C                   eval      slrsrv = 'V'
     C                   eval      slentd = today
     C                   eval      slexpd = svexpd
     C                   eval      slsdte = today
     C                   time                    slstim
     C                   write     slrec                                79
     C                   if        *in79
     C                   eval      error = *on
     **                   EXSR ZM71
     C                   goto      endslt
     C                   endif
     *  create vslot record.
     C                   eval      vswhse = $vwhse
     C                   eval      vswhdp = $vwhdp
     C                   eval      vsaisl = $vaisl
     C                   eval      vsloc = $vloc
     C                   eval      vsrlvl = $vrlvl
     C                   eval      vshand = $vhand
     C                   eval      vsdisp = $vdisp
     C                   eval      vspdis = phdisp
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      vscdte = $cvd8o
     C                   time                    vsctim
     C                   add       1             vsctim
     C                   write     vsrec                                79
     C                   if        *in79
     C                   eval      error = *on
     **                   EXSR ZM71
     C                   goto      endslt
     C                   endif
     ***
     C                   else
     *** Update slot record
     C                   update    slrec                                79
     C                   if        *in79
     C                   eval      error = *on
     ***                  EXSR ZM72
     C                   goto      endslt
     C                   endif
     C                   endif
     *
     *     Update warehouse qty by qty put away.
     *
     C                   eval      $acmd = '*STOCK  '
     C                   eval      $aprg = #prog
     C                   eval      $atype = '*INTER  '
     C                   eval      $awhse = lqwhse
     C                   eval      $aitem = lqitem
     *
     C                   eval      $aqty1 = 0
     C                   eval      $aqty2 = 0
     C                   eval      $aqty3 = 0
     C                   select
     C                   when      lqutyp = 'N'
     C                   eval      $aqty1 = lqqpck
     C                   when      lqutyp = '1'
     C                   eval      $aqty2 = lqqpck
     C                   when      lqutyp = '2'
     C                   eval      $aqty3 = lqqpck
     C                   endsl
     C                   exsr      zzwhse
     *
     *   Update the LABEL record with slot.
     *
     *
     C     endslt        endsr
     *----------------------------------------------------------------
     *
     *  ZZUSUB   Create label and trans records
     *
     C     zzusub        begsr
     C                   eval      error = *off
     *
     C                   eval      @pgrp1 = 'R'
     *
     *
     *  Get batch number for labels.
     *
X    C                   if        first = *on
     *        Innitialize totals.
     C                   add       0             tlpcs
     C                   add       0             tlcube
     C                   add       0             tlswgt
     *
     *
     *  Create one transaction for order, one label for each RECORD
     *  Transactions and label records will be created closed.
     *
     C     nxtl1         tag
     *        Get transaction number.
     *
     C                   call      'PIRTRN#'
     C                   parm                    pttrn#            7 0
     *    - Create transaction record.
     *        Create transaction record.       PULLED FROM RN246L
     * new code for create
     C                   eval      @pwhdp = lqwhdp
     C                   eval      @pstyp = lqstyp
     *
     C                   call      @adjt2
     C                   parm      '*CRTSTRT'    @pcmd            10
     C                   parm      #job          @pprg            10
     C                   parm      '*INTER  '    @ptype            8
     C                   parm      pttrn#        @ptrn#            7 0
     C                   parm      'PUTRTN'      @ptask            6
     C                   parm      $pwhse        @pwhse            3 0
     C                   parm      *blanks       @pwhdp            5
     C                   parm      lqstyp        @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      1             @paisl            5 0
     C                   parm      1             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      'R'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
     C                   parm      #user         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
     *
     C                   eval      first = *off
     C                   endif
     *    - Create label record for each quantity type.
     *
     C                   eval      tmpflg = *off
     *        Create label record.
     *
     C                   clear                   lbrec
     C                   eval      lbwhse = lqwhse
     C                   eval      lbwhdp = lqwhdp
     C                   if        $grtn <> '*OKPICK '
     ** NEED TO GET SLOT FOR BASE DOCK SLOT
     C                   exsr      zzckds
     C                   eval      lbaisl = *blanks
     C                   eval      lbloc = 0
     C                   eval      lbrlvl = 0
     C                   eval      lbhand = *blanks
     C                   if        newvs = *on
     C                   eval      lbaisl = $vaisl
     C                   eval      lbloc = $vloc
     C                   eval      lbrlvl = $vrlvl
     C                   eval      lbhand = $vhand
     C                   else
     C                   eval      lbaisl = $gaisl
     C                   eval      lbloc = $gloc
     C                   eval      lbrlvl = $grlvl
     C                   eval      lbhand = $ghand
     C                   endif
     C                   else
     C                   eval      lbaisl = $gaisl
     C                   eval      lbloc = $gloc
     C                   eval      lbrlvl = $grlvl
     C                   eval      lbhand = $ghand
     C                   endif
     C                   eval      lbpseq = 0
     C                   eval      lbstyp = lqstyp
     C                   eval      lbqryf = 0
     C                   eval      lbdisp = wotosl
     C                   movel     '*MANUAL'     lbdsp2
     C                   eval      lbitem = lqitem
     C                   eval      lbseq = 0
     C                   eval      lbpbat = $pbat#
     C                   eval      lbpo = lqpo
     C                   eval      lbord = lqord
     C                   eval      lbqalc = lqqpck
     C                   eval      lbqpck = lqqpck
     C                   eval      lbtie = 0
     C                   eval      lbhigh = 0
     C                   eval      lbutyp = lqutyp
     C                   eval      lbucod = lqucod
     C                   eval      lbucub = lqucub
     C                   eval      lbcube = lqcube
     C                   eval      lbuwgt = lquwgt
     C                   eval      lbswgt = lqswgt
     *
     C                   eval      lbtrn# = pttrn#
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   eval      lbgrp1 = @pgrp1
     C                   eval      lbgrp2 = @pgrp2
     C                   eval      lbtype = 'P'
     C                   eval      lbstat = 'C'
     C                   eval      lbsdte = today
     C                   time                    lbstim
     C                   eval      lbrdte = today
     C                   write     lbrec
     *
     *        Increment trans pcs/weight/cube
     C                   add       lqqpck        tlpcs
     C                   add       lqcube        tlcube
     C                   add       lqswgt        tlswgt
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZWHSE   Update warehouse quantities.
     *
     C     zzwhse        begsr
     *
     C                   eval      svitem = $aitem
     *
     *    If Alias item or Same Slot Breakdown item
     *      Then DO NOT update quantity of label item.
     *
     C                   if        ittype <> 'A'  and
     C                             ittype <> 'S'
     C                   call      'ADJQTY'
     C                   parm                    $acmd             8
     C                   parm                    $aprg            10
     C                   parm                    $atype            8
     C                   parm                    $awhse            3 0
     C                   parm                    $aitem           15
     C                   parm                    $aqty1            7 0
     C                   parm                    $aqty2            7 0
     C                   parm                    $aqty3            7 0
     C                   parm                    $artq1            7 0
     C                   parm                    $artq2            7 0
     C                   parm                    $artq3            7 0
     C                   parm                    $artn             8
     C                   parm                    $aerm
     C                   if        $artn = '*PGMQ   '
     C                   eval      error = *on
X    ***                  MOVE $AMSG     #MSGK
     ***                  EXSR ZMQMSG
     C                   endif
     C                   endif
     *
     *  If Alias or SSB item
     *   Then update Base item warehouse quantity.
     *
     C                   if        ittype = 'A'  or
     C                             ittype = 'S'
     C                   eval      $aitem = #bitem
     C                   call      'ADJQTY'
     C                   parm                    $acmd
     C                   parm                    $aprg
     C                   parm                    $atype
     C                   parm                    $awhse
     C                   parm                    $aitem
     C                   parm                    $aqty1
     C                   parm                    $aqty2
     C                   parm                    $aqty3
     C                   parm                    $artq1
     C                   parm                    $artq2
     C                   parm                    $artq3
     C                   parm                    $artn
     C                   parm                    $aerm
     C                   if        $artn = '*PGMQ   '
     C                   eval      error = *on
X    ***                  MOVE $AMSG     #MSGK
     ***                  EXSR ZMQMSG
     C                   endif
     C                   endif
     *
     *  If Contract item and *STOCK or *UNSTOCK
     *   Then update Base item warehouse quantity.
     *    and allocate/unallocate Base item warehouse quantity.
     *
     *  Note: The *UNALLOC command does not effect the Contract
     *        item's Base item Allocated quantities.
     *
     C                   if        ittype = 'C'
     C                   if        $acmd <> '*UNALLOC'
     C                   eval      $aitem = #bitem
     C                   call      'ADJQTY'
     C                   parm                    $acmd
     C                   parm                    $aprg
     C                   parm                    $atype
     C                   parm                    $awhse
     C                   parm                    $aitem
     C                   parm                    $aqty1
     C                   parm                    $aqty2
     C                   parm                    $aqty3
     C                   parm                    $artq1
     C                   parm                    $artq2
     C                   parm                    $artq3
     C                   parm                    $artn
     C                   parm                    $aerm
     C                   if        $artn = '*PGMQ   '
     C                   eval      error = *on
X    ***                  MOVE $AMSG     #MSGK
     ***                  EXSR ZMQMSG
     C                   endif
     C                   endif
     *
     C                   if        $acmd = '*STOCK  '  or
     C                             $acmd = '*UNSTOCK'
     C                   if        $acmd = '*STOCK  '
     C                   eval      $acmd = '*ALLOC  '
     C                   else
     C                   eval      $acmd = '*UNALLOC'
     C                   endif
     C                   eval      $aitem = #bitem
     C                   call      'ADJQTY'
     C                   parm                    $acmd
     C                   parm                    $aprg
     C                   parm                    $atype
     C                   parm                    $awhse
     C                   parm                    $aitem
     C                   parm                    $aqty1
     C                   parm                    $aqty2
     C                   parm                    $aqty3
     C                   parm                    $artq1
     C                   parm                    $artq2
     C                   parm                    $artq3
     C                   parm                    $artn
     C                   parm                    $aerm
     C                   if        $artn = '*PGMQ   '
     C                   eval      error = *on
X    ***                  MOVE $AMSG     #MSGK
     ***                  EXSR ZMQMSG
     C                   endif
     C                   endif
     C                   endif
     *
     C                   eval      $aitem = svitem
     C                   endsr
640aA*----------------------------------------------------------------*********
640aA*
640aA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640aA*
640aA /free
640aA   begsr zzwrttrand;
640aA     wrtpcmd = '*ONETRAN';
640aA     wrtpwait = 0;
640aA     wrtpwhse = ptwhse;
640aA     wrtptran# = pttrn#;
640aA     wrtpfrmdate = 0;
640aA     wrtptodate = 0;
640aA     wrtpemp# = 0;
640aA
640aA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640aA               wrtpfrmdate: wrtptodate: wrtpemp#);
640aA   endsr;
640aA /end-free
     *
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
**
 ABCDEFGHIJKLMNOPQRSTUVWXYZ
