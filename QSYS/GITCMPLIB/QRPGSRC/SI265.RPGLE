     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  SI265     FTP StuffIt Import 2 - Post
     *  29 March 2004
     *  Dave Sommerville
     *
     *  Revisions
     *
417 A*    03/29/04  DAS 4.17
     *      - Created
     *
417aA*    04/05/04  DAS 4.17a
     *      - Added check to compare slot and item departments
     *
417bA*    04/09/04  DAS 4.17b
     *      - Revised to create SA, SB and SC slots with slaisl='  S'
     *
417cA*    04/12/04  DAS 4.17c
     *      - Revised to put FIFO date into the Entered date when sent.
     *
417dA*    04/15/04  DAS 4.17d
     *      - Revised to convert FIFO date to YYYMMDD before putting it
     *        into Entered date.
     *
510aA*    03/22/07  MLB  5.10a
     *      - Enh: Revised program to allow Item Type R=Repack item to
     *        be populated into the SLOT file.
     *
     *----------------------------------------------------------------
     *  Custom Revisions
     *
CTY A*    04/01/04  DAS CTY
     *      - Revised to add physical slots on the fly.
     *      - Revised to not allow physical slot M-519-2 to use
     *        virtual handstacks ' A' or 'AA' thru 'AZ' Re: City Line
     *        also has a physical slot M-519-2A, that has multiple
     *        items in it.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fimpfstuf2 if   e           k disk
     Fwarehs    if   e           k disk
     Fpiritem   if   e           k disk
     Foptiond   if   e           k disk
     Fslot2     uf a e           k disk
     Fvslot2    uf a e           k disk
     Fsi265pr   o    e             printer oflind(*in91)
     F*i265err  o    e             disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a2              s              1    dim(2)
     D a2n             s              1    dim(2)
417aDD**esc            s             20    dim(9) ctdata perrcd(1)
417aMD desc            s             20    dim(10) ctdata perrcd(1)
     D rdsc            s             50    dim(1) ctdata perrcd(1)
     D hnd             s              2    dim(702)
     D ltr             s              1    dim(27) ctdata perrcd(27)

     *----------------------------------------------------------------
     *  Varialbles
     *----------------------------------------------------------------

     D $JOBQ           s              1
     D $PWHS           s             15  5
     D $VAISL          s              3
     D $VLOC           s              3  0
     D $VPICK          s              1
     D $VPSEQ          s              5  0
     D $VRLVL          s              2  0
     D $VSTYP          s              1
     D $VWHDP          s              5
     D $VWHSE          s              3  0
     D COUNT           s              3  0
     D ERROR           s              1
     D EXIST           s              1
     D FLAGHS          s              1
     D FOREVR          s              1
     D GOOD1           s              1
     D I               s              2  0
     D IMPDTE          s              8  0
     D IMPTIM          s              6  0
     D J               s              2  0
     D K               s              3  0
     D KYCODE          s                   like(OPDCOD)
     D LEN             s              1  0
     D LINPPG          s              3  0
     D LSTWHD          s              5
     D LSTWHS          s              3  0
     D NEWVS           s              1
     D ODISP           s                   like(SLDISP)
     D PFLAG           s              1
     D PHACTV          s                   like(SLACTV)
     D PHAISL          s                   like(SLAISL)
     D PHBLD           s                   like(SLBLD)
     D PHDESG          s                   like(SLDESG)
     D PHDISP          s                   like(SLDISP)
     D PHHAND          s                   like(SLHAND)
     D PHLOC           s                   like(SLLOC)
     D PHPSEQ          s                   like(SLPSEQ)
     D PHRLVL          s                   like(SLRLVL)
     D PHSDEF          s                   like(SLSDEF)
     D PHSIDE          s                   like(SLSIDE)
     D PHSLFD          s                   like(SLSLFD)
     D PHSTYP          s                   like(SLSTYP)
     D PHWHDP          s                   like(SLWHDP)
     D PHWHSE          s                   like(SLWHSE)
     D POS             s              1  0
     D SSBFLG          s              1
     D SVEXPD          s                   like(SLEXPD)
     D WORK3A          s              3
     D temp6a          s              6

CTY AD dashpos         s              2  0
CTY AD loca            s              3
CTY AD lvla            s              1
CTY AD locnotnum       s               n
CTY AD lvlnotnum       s               n
CTY AD notcreated      s               n

417dA*----------------------------------------------------------------
417dA*  Date fields
417dA*----------------------------------------------------------------
417dA
     D datefld         s               d
417dA
417dAD                 ds
     D  fifodate               1      8  0 inz(0)
     D  fifoyear               1      4  0 inz(0)
     D  fifomonth              5      6  0 inz(0)
     D  fifoday                7      8  0 inz(0)

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

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

     *----------------------------------------------------------------
     *  *PICK  -  Picking options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPNXTP  -  Next pallet number.
     *    OPBPCK  -  Bulk pick definition.
     *    OPPCUB  -  Maximum cube for PIR.
     *    OPFPAL  -  Pallets on fixed fork lift.
     *    OPFCUB  -  Maximum cube per fixed pallet.
     *    OPFSTP  -  Maximum stops per fixed pallet.
     *    OPINCL  -  Include PIR in fixed cube.
     *    OPSRCH  -  Number of previous pallets to search for space.
     *    OPFBLD  -  Fixed pallet building method.
     *                1 = By piece without concern for splitting stop.
     *                2 = By stop without splitting stop between plts.
     *    OPPBRK  -  Break pallets by aisle (Y,N).
     *    OPMPUT  -  Manual Put away (Y,N).
     *
     * Data structure
     *
     D opddta          ds
     D  opnxtp                 1      7  0 inz(0)
     D  oppcub                10     14  2 inz(0)
     D  opfpal                15     15  0 inz(0)
     D  opfcub                16     20  2 inz(0)
     D  opincl                22     22
     D  opsrch                23     24  0 inz(0)
     D  opfstp                25     26  0 inz(0)
     D  opfbld                27     27  0 inz(0)
     D  opbpck                28     30  0 inz(0)
     D  oppbrk                31     33
     D  opmput                34     34
     D  opdend               117    117

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

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
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     * Get import date/time.

     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      impdte = $cvd8o
     C                   time                    imptim
     *
     * Get report heading.
     *
     C                   eval      w1head = *blanks
     C                   movel     rdsc(1)       $pstr
     C                   eval      $plen = 50
     *
     C                   call      'CENTER'
     C                   parm                    $pstr            60
     C                   parm                    $plen             3 0
     C                   movel     $pstr         w1head
     *
     * Initialize grand total fields
     *
     C                   eval      grdlin = 0
     C                   eval      noslot = 0
     C                   eval      noitem = 0
     C                   eval      badbrk = 0
     C                   eval      badtyp = 0
     C                   eval      baddte = 0
     C                   eval      notcrt = 0
     C                   eval      notupd = 0
     *
     * Whip through all the download records
     *
     C                   move      *off          pflag
     C                   move      *on           forevr
     C                   eval      linppg = 55
     C                   eval      count = 999
     C                   eval      lstwhs = -(1)
414aAC                   move      '@@@@@'       lstwhd
     *
     C                   dow       forevr = forevr
     *
     C                   read      impfstuf2                              79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   add       1             grdlin
     *
     *  Create warehouse heading if necessary.
     *
     C                   if        lstwhs <> siwhse
     *
     C                   if        lstwhs > 0
     C                   exsr      zzrcal
     C                   endif
     *
     C                   eval      whcode = siwhse
     C     whcode        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     C                   move      siwhse        work3a
     C     ' 0'          check     work3a        pos
     C                   eval      len = 4 - pos
     C     len           subst     work3a:pos    whhead
     C     whhead        cat       '-':1         whhead
     C     whhead        cat       whdesc:1      whhead
     C                   call      'CENTER'
     C                   parm      whhead        $cstr            60
     C                   parm      40            $clen             3 0
     C                   movel     $cstr         whhead
     C                   eval      lstwhs = siwhse
     C                   eval      count = 999
     C                   endif
414aA*
414aA*  Get options when department changes
414aA*
414aAC                   if        lstwhd <> siwhdp
414aAC                   move      '*PICK   '    kycode
414aAC     keyop         chain     optiond                            79
414aAC                   if        *in79
414aAC                   eval      opmput = 'N'
414aAC                   endif
414aAC                   move      siwhdp        lstwhd
414aAC                   endif
     *
     C                   eval      itdesc = *blanks
     C                   eval      ittype = *blanks
     C                   eval      detmsg = *blanks
     *
     *  If slot doesn't exist write error message.
     *
     C     keysl2        chain(n)  slot2                              76
     C                   if        *in76
CTY AC                   exsr      crtslot
CTY AC                   if        notcreated
     C                   eval      detmsg = desc(1)
     C                   add       1             noslot
     C                   goto      prndtl
CTY AC                   endif
     C                   endif
     *
     *  If item doesn't exist write error message.
     *
     C     keyit         chain     piritem                            76
     C                   if        *in76
     C                   eval      detmsg = desc(2)
     C                   add       1             noitem
     C                   eval      ittype = *blanks
     C                   eval      itdesc = *blanks
     C                   movel     '*****'       itdesc
     C                   goto      prndtl
     C                   endif
     *
     *  If item type not ' ' or 'B' write error message.
510aAC*  and not type 'R' write error message.
     *
     C                   if        ittype <> ' '  and
     C                             ittype <> 'B'
510aAC                             and ittype <> 'R'
     C                   eval      detmsg = desc(4)
     C                   add       1             badtyp
     C                   goto      prndtl
     C                   endif
417aA*
417aA*  If item dept not same as slot dept write error message.
417aA*
417aAC                   if        itwhdp <> siwhdp
417aAC                   eval      detmsg = desc(10)
417aAC                   move      itwhdp        detmsg
417aAC                   add       1             baddpt
417aAC                   goto      prndtl
417aAC                   endif
     *
     *  If invalid mmddyy FIFO date write error message.
     *
     C                   if        sififo > 0
     C                   move      sififo        temp6a
     C     *MDY0         test(de)                temp6a
     C                   if        %error
     C                   eval      detmsg = desc(9)
     C                   add       1             baddte
     C                   goto      prndtl
     C                   endif
417dAC     *MDY0         move      temp6a        datefld
417dAC                   extrct    datefld:*y    fifoyear
417dAC                   extrct    datefld:*m    fifomonth
417dAC                   extrct    datefld:*d    fifoday
     C                   endif
     *
     *  Add rec if qty1, brk qty2 or brk qty3 has good qty.
     *  Check if breakdown qty is allowed using piritem file.
     *  Add rec if qty1, brk qty2 or brk qty3 has good qty.
     *
     C                   move      'N'           good1
     C                   exsr      zzbkdn
     C     good1         cabeq     'N'           prndtl
     *
     *  If doing manual putaway,
     *   Then get actual slot to use for the putaway.
     *
414bAC                   move      *off          newvs
     C                   if        opmput = 'Y'
     C                   exsr      zzman
     C     error         cabeq     *on           prndtl
     C                   endif
     *
     *  Update slot record.
     *
     C                   exsr      zzupd
     *
     *  Print detail and update subtotals
     *
     C     prndtl        tag
     C                   if        detmsg <> *blanks
     C                   exsr      zrhead
     C                   write     detail
     C**                 write     serec
     C                   add       1             count
     C                   endif
     *
     C                   enddo
     *
     *  Print order grand totals
     *
     C                   exsr      zrhead
     C                   write     grndttl
     *
     *  Update ItemQty totals
     *
     C                   if        lstwhs > 0
     C                   exsr      zzrcal
     C                   endif
     *
     *  We are finished so get out
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   eval      error = *off
     C                   eval      exist = *off
     C                   eval      newvs = *off
     *
     * Key definitions
     *
     * Item file
     *
     C     keyit         klist
     C                   kfld                    siwhse
     C                   kfld                    siitem
     *
     * Slot2 file
     *
     C     keysl2        klist
     C                   kfld                    siwhse
     C                   kfld                    siwhdp
     C                   kfld                    sidisp
     *
     *  OPTIOND file
     *
     C     keyop         klist
     C                   kfld                    kycode
     C                   kfld                    siwhse
     C                   kfld                    siwhdp
     *
     *  VSLOT file
     *
     C     keyvs         klist
     C                   kfld                    siwhse
     C                   kfld                    siwhdp
     C                   kfld                    vsdisp
     *
     C     ckkey         klist
     C                   kfld                    siwhse
     C                   kfld                    siwhdp
     C                   kfld                    $vdisp
     *
     *  Define variables
     *
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
     C                   eval      $lprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILLSL  Fill order detail fields.
     *
     C     fillsl        begsr
     *
     *  Move fields from download file to purchase order header fields
     *
     C                   eval      slitem = siitem
     C                   eval      slstk1 = siqty1
     C                   if        itflg1 = 'Y'
     C                   z-add     siqty2        slstk2
     C                   else
     C                   eval      slstk2 = 0
     C                   endif
     C                   if        itflg2 = 'Y'
     C                   z-add     siqty3        slstk3
     C                   else
     C                   eval      slstk3 = 0
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZBKDN  Check breakdown quanties.
     *
     C     zzbkdn        begsr
     *
     C                   if        siqty1 = 0  and
     C                             siqty2 = 0  and
     C                             siqty3 = 0
     C                   move      'Y'           good1
     C                   goto      endbkd
     C                   endif
     *
     C                   exsr      zzssb
     *
     C                   if        siqty2 <> 0  and
     C                             itflg1 <> 'Y'  and
     C                             ssbflg = *off
     C                   eval      detmsg = desc(3)
     C                   add       1             badbrk
     C                   endif
     *
     C                   if        siqty3 <> 0  and
     C                             itflg2 <> 'Y'  and
     C                             ssbflg = *off
     C                   eval      detmsg = desc(3)
     C                   add       1             badbrk
     C                   endif
     *
     C                   if        siqty1 <> 0
     C                   move      'Y'           good1
     C                   else
     C                   if        siqty2 <> 0  and
     C                             itflg1 = 'Y'  or
     C                             siqty2 <> 0  and
     C                             ssbflg = *on
     C                   move      'Y'           good1
     C                   else
     C                   if        siqty3 <> 0  and
     C                             itflg2 = 'Y'  or
     C                             siqty3 <> 0  and
     C                             ssbflg = *on
     C                   move      'Y'           good1
     C                   endif
     C                   endif
     C                   endif
     *
     C     endbkd        endsr
     *----------------------------------------------------------------
     *
     *  ZZCKNS   Use reg slot or get new Vslot.
     *
     C     zzckns        begsr
414aAC                   move      *off          newvs
     C                   move      *on           error
     C     keysl2        chain(n)  slot2                              79
     C                   if        not *in79
     C                   if        slitem = *blanks
     C                   move      *off          error
     C                   goto      endckn
     C                   else
     *
     *   Get out if physical slot already uses both
     *   positions of handstack field.
     *
     C                   movea     slhand        a2
     C                   if        a2(1) <> ' '
     C                   goto      endckn
     C                   endif
     *
     *   Set handstack flag for later use.
     *
     C                   if        slhand <> ' '
     C                   move      *on           flaghs
     C                   else
     C                   move      *off          flaghs
     C                   endif
     *
     * SAVE PHYSICAL SLOT FIELDS
     *
     C                   eval      phwhse = slwhse
     C                   move      slwhdp        phwhdp
     C                   move      slaisl        phaisl
     C                   eval      phloc = slloc
     C                   eval      phrlvl = slrlvl
     C                   move      slhand        phhand
     C                   eval      phside = slside
     C                   move      slstyp        phstyp
     C                   move      sldisp        phdisp
     C                   move      slsdef        phsdef
     C                   move      sldesg        phdesg
     C                   eval      phpseq = slpseq
     C                   move      slactv        phactv
     C                   move      slbld         phbld
     C                   z-add     slslfd        phslfd
     ***
     C                   eval      $vpseq = slpseq
     C                   eval      $vdisp = *blanks
     C                   eval      k = 0
     C                   eval      $vwhse = slwhse
     C                   move      slwhdp        $vwhdp
     C                   move      slaisl        $vaisl
     C                   eval      $vloc = slloc
     C                   eval      $vrlvl = slrlvl
     C                   eval      $vhand = *blanks
     C                   move      slstyp        $vstyp
     C                   z-add     slpseq        $vpseq
     C                   eval      $vdisp = *blanks
     C                   move      slpick        $vpick
     *
     *** Loop & increment handstack to find new v-slot to create.
     *
414cD**         K         DOWLE720
414cMC                   dow       k < 702
     C                   add       1             k
CTY A*
CTY A*     If slot is M-519-2, then do not allow handstacks ' A'
CTY A*     and 'AA' thru 'AZ' to be used.
CTY A*
CTY AC                   if        sidisp = 'M-519-2'
CTY AC                   if        hnd(k) = ' A'
CTY AC                             or (hnd(k) >= 'AA' and hnd(k) <= 'AZ')
CTY AC                   iter
CTY AC                   endif
CTY AC                   endif
     *
     *     If physical slot had handstack then limit hs we can use.
     *
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
     C                   move      *on           newvs
     C                   move      *off          error
     C                   eval      sidisp = $vdisp
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
     *  ZZCKSL   Check if item exists in reg or V slot
     *
     C     zzcksl        begsr
     C     keysl2        chain(n)  slot2                              79
     C                   if        not *in79  and
     C                             slitem = siitem
     C                   move      *on           exist
     C                   goto      endcks
     C                   else
     C     keysl2        setll     vslot2
     C     nxt1          tag
     C     keysl2        reade     vslot2                                 78
     C                   if        not *in78
     C     keyvs         chain(n)  slot2                              79
     C                   if        not *in79  and
     C                             slitem = siitem
     C                   move      *on           exist
     C                   eval      sidisp = sldisp
     C                   goto      endcks
     C                   else
     C                   goto      nxt1
     C                   endif
     C                   endif
     C                   endif
     *
     C     endcks        endsr
     *----------------------------------------------------------------
     *
     *  ZZMAN    Get slot to use for manual putaway.
     *
     C     zzman         begsr
     C                   move      *off          error
414aAC                   move      *off          exist
     *
     *  Check if item already exists in the base slot
     *    or in a corresponding virtual slot.
     *
     C                   exsr      zzcksl
     *
     *  If item doesn't already exist in the slot,
     *    Then try to get a new virtual slot number for it.
     *
     C                   if        exist = *off
     C                   exsr      zzckns
     C                   if        error = *on
     C                   eval      detmsg = desc(5)
     C                   add       1             notcrt
     C                   goto      endman
     C                   endif
     C                   endif
     C     endman        endsr
     *----------------------------------------------------------------
     *
     *  ZZRCAL   Recalculate item quantity from slots.
     *
     C     zzrcal        begsr
     C                   move      *off          error
     *
     * Recalculate item qty.
     C                   eval      $pwhs = lstwhs
     C                   move      'Y'           $jobq
     C                   call      'UT812'
     C                   parm                    $pwhs
     C                   parm      '*ALL    '    $item            15
     C                   parm                    $jobq
     C                   parm                    $lprg
     C                   parm                    $lrtn
     C                   parm                    $lmsg
     *
     C     endcal        endsr
     *----------------------------------------------------------------
     *
     *  ZZSSB   Check for SSB item.
     *
     C     zzssb         begsr
     *
     *   Get SSB item, if one exists
     *
     C                   move      *off          ssbflg
     C                   if        ittype = ' '
     C                   call      'GETSSB'
     C                   parm      itwhse        $gwhse            3 0
     C                   parm      ititem        $gitem           15
     C                   parm      ' '           #bitem           15
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     C                   parm                    #bwhdp            5
     C                   parm                    #bstyp            1
     C                   parm                    #bum              2
     C                   parm                    #bum2             2
     C                   parm                    #bumq2            3 0
     C                   parm                    #bum3             2
     C                   parm                    #bumq3            3 0
     C                   parm                    #brtn             8
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update slot file
     *
     C     zzupd         begsr
     C                   move      *off          error
     *
     *   Update record.
     *
     *  Create new slot record
     *  $V = from Physical slot when virtual was checked
     *  PH = from saved from physical slot when virtual was checked
     *  SV = saved from 'FROM' slot.
     *  SL = saved from 'FROM' slot.
     C                   if        newvs = *on
     C                   eval      slwhse = $vwhse
     C                   move      $vwhdp        slwhdp
     C                   eval      slstat = 'A '
     C                   move      $vaisl        slaisl
     C                   eval      slloc = $vloc
     C                   eval      slrlvl = $vrlvl
     C                   eval      slhand = $vhand
     C                   eval      slside = phside
     C                   move      $vstyp        slstyp
     C                   eval      sldisp = $vdisp
     C                   move      phsdef        slsdef
     C                   move      phdesg        sldesg
     C                   move      phactv        slactv
     C                   move      phbld         slbld
     C                   eval      slpseq = $vpseq
     C                   eval      slslfd = 0
     C                   eval      slrsrv = 'V'
     C                   eval      slexpd = svexpd
     C                   eval      slprty = 0
417cAC                   if        sififo > 0
417dDC**                 eval      slentd = sififo
417dMC                   eval      slentd = fifodate
417cAC                   else
     C                   eval      slentd = impdte
417cAC                   endif
     C                   eval      slsdte = impdte
     C                   eval      slstim = imptim
     C                   eval      slitem = siitem
     C                   eval      slstk1 = siqty1
     C                   if        itflg1 = 'Y'
     C                   z-add     siqty2        slstk2
     C                   else
     C                   eval      slstk2 = 0
     C                   endif
     C                   if        itflg2 = 'Y'
     C                   z-add     siqty3        slstk3
     C                   else
     C                   eval      slstk3 = 0
     C                   endif
     *
     C                   write     slrec                                79
     C                   if        *in79
     C                   move      *on           error
414aD**                   MOVE DESC,5    DETMSG
414aMC                   eval      detmsg = desc(7)
     C                   add       1             notcrt
     C                   goto      endupd
     C                   endif
     C                   add       1             sltcrt
     *
     *  create vslot record.
     *
     C                   eval      vswhse = $vwhse
     C                   move      $vwhdp        vswhdp
     C                   move      $vaisl        vsaisl
     C                   eval      vsloc = $vloc
     C                   eval      vsrlvl = $vrlvl
     C                   eval      vshand = $vhand
     C                   eval      vsdisp = $vdisp
     C                   move      phdisp        vspdis
     C                   eval      vscdte = impdte
     C                   eval      vsctim = imptim
     C                   add       1             vsctim
     C                   write     vsrec                                79
     C                   if        *in79
     C                   move      *on           error
414aD**                   MOVE DESC,5    DETMSG
414aMC                   eval      detmsg = desc(8)
     C                   add       1             notcrt
     C                   goto      endupd
     C                   endif
     ***
     C                   else
     *
     *** Update slot record
     *
     C     keysl2        chain     slot2                              79
     *
     C                   if        not *in79
     *
     C                   eval      slitem = siitem
     C                   if        slstat = 'V '  or
     C                             slstat = 'Z '
     C                   eval      slstat = 'A '
     C                   endif
     C                   eval      slstk1 = siqty1
     C                   if        itflg1 = 'Y'
     C                   z-add     siqty2        slstk2
     C                   else
     C                   eval      slstk2 = 0
     C                   endif
     C                   if        itflg2 = 'Y'
     C                   z-add     siqty3        slstk3
     C                   else
     C                   eval      slstk3 = 0
     C                   endif
     *
417cAC                   if        sififo > 0
417dDC**                 eval      slentd = sififo
417dMC                   eval      slentd = fifodate
417cAC                   else
     C                   eval      slentd = impdte
417cAC                   endif
     C                   eval      slsdte = impdte
     C                   eval      slstim = imptim
     C                   update    slrec                                79
     C                   if        *in79
     C                   move      *on           error
     C                   eval      detmsg = desc(6)
     C                   add       1             notupd
     C                   endif
     C                   add       1             sltupd
     C                   endif
     C                   endif
     *
     C     endupd        endsr
     *----------------------------------------------------------------
     *
     *  ZRHEAD   Print report headings.
     *
     C     zrhead        begsr
     *
     C                   if        count >= linppg
     C                   seton                                        81
     C                   eval      count = 0
     C                   write     head1
     C                   add       2             count
     C                   setoff                                       81
     C                   endif
     *
     C                   endsr

CTY A*----------------------------------------------------------------
CTY A*  crtslot  Try and create physical slot.
CTY A*----------------------------------------------------------------
CTY A
CTY AC     crtslot       begsr
     C                   eval      notcreated = *off
     C                   clear                   slrec

     *  Extract location and level. Test if they are numeric.

     C                   eval      locnotnum = *off
     C                   eval      lvlnotnum = *off
     C                   eval      dashpos = 0
     C                   eval      loca  = ' '
     C                   eval      lvla  = ' '

     C                   if        %subst(sidisp:2:1) = '-'
     C                             and %subst(sidisp:6:1) = '-'
     C                   eval      dashpos = 2
     C                   eval      slaisl = '  ' + %subst(sidisp:1:1)
     C                   eval      loca  = %subst(sidisp:3:3)
     C                   move      loca          slloc
     C                   eval      lvla  = %subst(sidisp:7:1)
     C                   move      lvla          slrlvl
     C                   eval      slhand  = ' ' + %subst(sidisp:8:1)
     C                   endif

     C                   if        %subst(sidisp:3:1) = '-'
     C                             and %subst(sidisp:7:1) = '-'
     C                   eval      slaisl = ' ' + %subst(sidisp:1:2)
     C                   eval      loca  = %subst(sidisp:4:3)
     C                   move      loca          slloc
     C                   eval      lvla  = %subst(sidisp:8:1)
     C                   move      lvla          slrlvl
     C                   eval      slhand  = ' ' + %subst(sidisp:9:1)
     C                   eval      dashpos = 3
     C                   endif

     C                   testn                   loca                 50
     C                   if        *in50 = *off
     C                   eval      locnotnum = *on
     C                   endif

     C                   testn                   lvla                 50
     C                   if        *in50 = *off
     C                   eval      lvlnotnum = *on
     C                   endif

     *  See if slot meets criteria for allowing it to be created.

     C                   select

     *    Allow creation of known special slots.

     C                   when      sidisp = 'N-400-SP'
     C                   eval      slwhdp = siwhdp
     C                   eval      slaisl = '  N'
     C                   eval      slloc  = 400
     C                   eval      slrlvl = 1
     C                   eval      slhand = ' '
     C                   eval      sldisp = sidisp

     C                   when      sidisp = 'MISC'
     C                   eval      slwhdp = 'DRY'
     C                   eval      slaisl = '  Z'
     C                   eval      slloc  = 2
     C                   eval      slrlvl = 1
     C                   eval      slhand = ' '
     C                   eval      sldisp = sidisp

     C                   when      sidisp = 'PIR'
     C                   eval      slwhdp = 'DRY'
     C                   eval      slaisl = '  Z'
     C                   eval      slloc  = 3
     C                   eval      slrlvl = 1
     C                   eval      slhand = ' '
     C                   eval      sldisp = sidisp

     C                   when      sidisp = 'SILVRAK'
     C                   eval      slwhdp = 'DRY'
     C                   eval      slaisl = '  Z'
     C                   eval      slloc  = 4
     C                   eval      slrlvl = 1
     C                   eval      slhand = ' '
     C                   eval      sldisp = sidisp

     C                   when      sidisp = 'Z'
     C                   eval      slwhdp = 'DRY'
     C                   eval      slaisl = '  Z'
     C                   eval      slloc  = 1
     C                   eval      slrlvl = 1
     C                   eval      slhand = ' '
     C                   eval      sldisp = sidisp

     *    If non-special slot doesn't have hypens, then don't add it.

     C                   when      dashpos = 0
     C                   eval      notcreated = *on
     C                   goto      endcreate

     *    Don't all creation if department is unknown.

     C                   when      siwhdp <> 'DRY'
     C                             and siwhdp <> 'REF'
     C                             and siwhdp <> 'FRZ'
     C                   eval      notcreated = *on
     C                   goto      endcreate

     *    If location or level is not numeric, then don't add.

     C                   when      locnotnum or lvlnotnum
     C                   eval      notcreated = *on
     C                   goto      endcreate

     *    Otherwise, slot is ok to be created.

     C                   other
     C                   eval      slwhdp = siwhdp
     C                   eval      sldisp = sidisp

     C                   endsl

     *  Try and create the slot.

     C                   eval      slwhse = siwhse
     C                   eval      slpseq = slloc
     C                   eval      slstat = 'A'
     C                   eval      slrsrv = 'Y'
     C                   eval      slsdef = 'XX'
     C                   eval      slpick = 'Y'

     C                   select

     C                   when      slaisl >= '  A' and slaisl <= '  D'
     C**                 eval      slwhdp = 'DRY'
     C                   eval      slstyp = 'F'

     C                   when      slaisl >= '  E' and slaisl <= '  H'
     C**                 eval      slwhdp = 'DRY'
     C                   eval      slstyp = 'P'

     C                   when      slaisl >= '  J' and slaisl <= '  P'
     C**                 eval      slwhdp = 'REF'
     C                   eval      slstyp = 'F'

     C                   when      slaisl >= '  R' and slaisl <= '  T'
     C**                 eval      slwhdp = 'FRZ'
     C                   eval      slstyp = 'F'

     C                   when      slaisl >= '  U' and slaisl <= '  Y'
     C**                 eval      slwhdp = 'FRZ'
     C                   eval      slstyp = 'P'

     C                   when      slaisl >= ' PA' and slaisl <= ' PZ'
     C**                 eval      slwhdp = 'REF'
     C                   eval      slstyp = 'F'

     C                   when      slaisl >= ' SA' and slaisl <= ' SZ'
     C**                 eval      slwhdp = 'FRZ'
     C                   eval      slstyp = 'F'
417bAC                   eval      slaisl = '  S'

     C                   other
     C**                 eval      slwhdp = 'DRY'
     C                   eval      slstyp = 'F'

     C                   endsl

     C                   write     slrec                                79


     C     endcreate     endsr
     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
**
*INVALID SLOT*
*INVALID ITEM*
*BREAKDOWN INVALID*
*INVALID ITEM TYPE*
*CAN'T CREATE VS/1*
*SLOT NOT UPDATED*
*CAN'T CREATE VS/2*
*CAN'T CREATE VS/3*
*INVALID FIFO DATE*
*DEPT MISMATCH*
**
FTP StuffIt Import
**
 ABCDEFGHIJKLMNOPQRSTUVWXYZ
