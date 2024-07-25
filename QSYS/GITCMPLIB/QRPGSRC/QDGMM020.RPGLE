510cA /COPY *libl/qcopysrc,hspecs
     F*----------------------------------------------------------------
     F*
     F*  QDGMM020  Migrate item/qty to BFC Slot from NDS Slot.
     F*  31 July 2012
     F*  Max Blacknik
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
GMM AF*    07/31/12  MLB  GMM
     F*      - Created.
     F*
GMMaAF*    08/02/12  MLB  GMMa
     F*      - Revised program to add support to create virtual pick slots
     F*        when the base pick slot is already occupied. Per Roxanne.
     F*
GMMbAF*    08/06/12  MLB  GMMb
     F*      - Revised program to only migrate special order slots/item that
     F*        have qty onhand. If item has stk1,2 and 3 all zero. set slot
     F*        status on NDS slot to TZ-Transfer zero.
     F*
GMMcAF*    02/06/13  MLB  GMMc
     F*      - Revised program to set kywhse = 010 for Vinita whse.
     F*
     F*----------------------------------------------------------------
     F*  Notes:
     F*
     F*    This program was created to migrate the item number/qty from
     F*    the NDS slot to the new BFC slot.
     F*
     F*----------------------------------------------------------------
     FSLOT1     UF   E           K DISK    rename(slrec : slrec1)
     F                                     prefix(sL1)
     FVSLOT1    IF   E           K DISK
GMMaAF                                     rename(vsrec : vsrec1)
     FVSLOT2    UF A E           K DISK
     FSLOT2     UF A E           K DISK    rename(slrec : slrec2)
GMMaDF**                                   prefix(sL2)
     FSLOTXRF   IF   E           K DISK
     Fqsysprt   O    F  132        PRINTER OFLIND(*IN90)
GMMaAD count           s              3  0
     Derrorcode        s             20
     Derrmsg           s             60
GMMaAD error           s              1     inz('0')
GMMaAD exist           s              1     inz('0')
GMMaAD flaghs          s              1     inz('0')
GMMaAD forevr          s              1     inz('0')
GMMaAD good1           s              1
GMMaAD I               s              3  0
GMMaAD J               s              3  0
GMMaAD k               s              3  0
GMMaAD kydisp          s                   like(sldisp)
GMMaAD handstack       s              1     inz('0')
GMMaAD newvs           s              1     inz('0')
GMMaAD phactv          s                   like(slactv)
GMMaAD phaisl          s                   like(slaisl)
GMMaAD phbld           s                   like(slbld)
GMMaAD phdesg          s                   like(sldesg)
GMMaAD phdisp          s                   like(sldisp)
GMMaAD phhand          s                   like(slhand)
GMMaAD phloc           s                   like(slloc)
GMMaAD phpseq          s                   like(slpseq)
GMMaAD phrlvl          s                   like(slrlvl)
GMMaAD phsdef          s                   like(slsdef)
GMMaAD phside          s                   like(slside)
GMMaAD phslfd          s                   like(slslfd)
GMMaAD phstyp          s                   like(slstyp)
GMMaAD phwhdp          s                   like(slwhdp)
GMMaAD phwhse          s                   like(slwhse)
GMMaAD $vaisl          s              3
GMMaAD $vloc           s              3  0
GMMaAD $vpick          s              1
GMMaAD $vpseq          s              5  0
GMMaAD $vrlvl          s              2  0
GMMaAD $vstyp          s              1
GMMaAD $vwhdp          s              5
GMMaAD $vwhse          s              3  0
      *
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

GMMaA*----------------------------------------------------------------
GMMaA*  Table and array definitions
GMMaA*----------------------------------------------------------------
GMMaA
GMMaAD a2              s              1    dim(2)
GMMaAD a2n             s              1    dim(2)
GMMaAD hnd             s              2    dim(702)
GMMaAD ltr             s              1    dim(27) ctdata perrcd(27)
     C*
     C                   time                    hmsmdy           12 0
     C                   Move      hmsmdy        rdate             6 0
     C                   movel     hmsmdy        rtime             6 0
     C                   eval      *in90 = '1'

     * Get import date/time.
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        impdte            8 0
     C                   time                    imptim            6 0
GMMaA*
GMMaA*   Load handstack array with codes (A..Z, AA..AZ, ...)
GMMaA*
GMMaAC                   eval      k = 0
GMMaAC     1             do        27            i
GMMaA*
GMMaAC     2             do        27            j
GMMaAC                   add       1             k
GMMaAC     ltr(i)        cat       ltr(j)        hnd(k)
GMMaAC                   enddo
GMMaA*
GMMaAC                   enddo
     C*
     C*  Define keys
     C*
     C     SL1key        KLIST
     C                   KFLD                    KYWHSE            3 0
GMMdDC*                  Z-ADD     001           KYWHSE
GMMdMC                   Z-ADD     010           KYWHSE
     C*
     C     xfkey         KLIST
     C                   KFLD                    KYcmpn            3
     C                   KFLD                    KYdivn            3
     C                   KFLD                    KYdptn            3
     C                   KFLD                    KYwhsn            3
     C                   KFLD                    kywhna            3
     C                   KFLD                    kysltn            7
     C                   eval      kycmpn = '1  '
     C                   eval      kydivn = '1  '
     C                   eval      kydptn = '1  '
     C                   eval      kywhsn = '1  '
GMMaA*
GMMaA* Slot2 file
GMMAA*
GMMaAC     keysl2        klist
GMMaAC                   kfld                    sL1slwhse
GMMaAC                   kfld                    sL1slwhdp
GMMaAC                   kfld                    xfdisp
     C*
     C     SL2key        KLIST
     C                   KFLD                    KYWHSE
     C                   KFLD                    sL1slwhdp
     C                   KFLD                    xfdisp
     C*
     C     vs1key        KLIST
     C                   KFLD                    sL1slwhse
     C                   KFLD                    sL1slwhdp
     C                   KFLD                    sL1sldisp
GMMaA*
GMMaA*  VSLOT file
GMMaA*
GMMaAC     keyvs         klist
GMMaAC                   kfld                    sL1slwhse
GMMaAC                   kfld                    sL1slwhdp
GMMaAC                   kfld                    vsdisp
GMMaA*
GMMaAC     ckkey         klist
GMMaAC                   kfld                    sL1slwhse
GMMaAC                   kfld                    sL1slwhdp
GMMaAC                   kfld                    $vdisp
     C*
     C     sl1key        SETLL     slot1
     C                   dow       not %eof(slot1)
     C     sl1key        READE     slot1
     C*
     C                   SELECT
     C                   when      %eof(slot1)
     C                   LEAVE
     C*
     C                   when      sL1slstat <> 'A '
     C                   iter
     C*
     C                   when      sL1sldesg = 'BFC'
     C                   iter
GMMbAC*
GMMbAC                   when         (%subst(sL1sldisp:1:4) = 'KNEW'
GMMbAC                              or %subst(sL1sldisp:1:4) = 'ANEW'
GMMbAC                              or %subst(sL1sldisp:1:4) = 'PNEW'
GMMbAC                              or %subst(sL1sldisp:1:4) = 'QNEW'
GMMbAC                              or %subst(sL1sldisp:1:4) = 'UNEW'
GMMbA*
GMMbAC                              or %subst(sL1sldisp:1:4) = 'ASPC'
GMMbAC                              or %subst(sL1sldisp:1:4) = 'KSPC'
GMMbAC                              or %subst(sL1sldisp:1:4) = 'PSPC'
GMMbAC                              or %subst(sL1sldisp:1:4) = 'QSPC'
GMMbAC                              or %subst(sL1sldisp:1:4) = 'USPC'
GMMbA*
GMMbAC                              or %subst(sL1sldisp:1:5) = 'ASPEC'
GMMbAC                              or %subst(sL1sldisp:1:5) = 'KSPEC'
GMMbAC                              or %subst(sL1sldisp:1:5) = 'QSPEC'
GMMbAC                              or %subst(sL1sldisp:1:5) = 'PSPEC'
GMMbAC                              or %subst(sL1sldisp:1:4) = 'USPEC'
GMMbA*
GMMbAC                              or %subst(sL1sldisp:1:4) = 'AZZZ'
GMMbAC                              or %subst(sL1sldisp:1:4) = 'PZZZ'
GMMbAC                              or %subst(sL1sldisp:1:4) = 'PZZZ'
GMMbAC                              or %subst(sL1sldisp:1:4) = 'UZZZ'
GMMbAC                              or %subst(sL1sldisp:1:4) = 'QZZZ')
GMMbA*
GMMbAC                             and (sL1slstk1 = 0
GMMbAC                             and  sL1slstk2 = 0
GMMbAC                             and  sL1slstk3 = 0)
GMMbAC*
GMMbAC*      Update NDS slot that slot was processed, but zero qty.
GMMbAC                   eval      sL1slstat = 'TZ'
GMMbAC                   update    slrec1
GMMbAC                   iter
     C*
     C*      NDS slot with item number to be moved.
     C                   when          %subst(sL1sldisp:3:1) <> '-'
     C                             and %subst(sL1sldisp:7:1) <> '-'
     C                             and sL1slitem > ' '
     C                             and sL1slpick = 'Y'
     C*
     C                   if        sL1slrsrv = 'V'
     C     vs1key        chain     vslot1
     C                   if        %found(vslot1)
     C                   eval      kysltn = %subst(vspdis:1:7)
GMMaAC                   else
GMMaAC                   eval      kysltn = %subst(sL1sldisp:1:7)
     C                   endif
     C*
     C                   else
     C                   eval      kysltn = %subst(sL1sldisp:1:7)
     C                   endif
     C*
     C                   eval      kywhna = %subst(sL1slwhdp:1:3)
     C     xfkey         chain     slotxrf
     C*
     C                   if        not %found(slotxrf)
     C                   eval      xfdisp = ' '
     C                   eval      errorcode = '*NONDSXREF'
     C                   exsr      zzprinterr
     C*
     C*      NDS slot found in Cross-Reference file.
     C                   else
     C*
     C     sl2key        chain     slot2
     C*
     C                   select
     C                   when      not %found(slot2)
     C                   eval      errorcode = '*NOBFCSLOT'
     C                   exsr      zzprinterr
     C                   unlock    slot1
     C                   unlock    slot2
     C                   iter
     C*
     C*      No item assigned to slot. Move item, qty from NDS slot.
GMMaMC                   when      slitem = ' '
     C*
     C*      Put item into New BFC slot.
GMMaMC                   eval      slitem = sL1slitem
GMMaMC                   eval      slstat = 'A '
GMMaMC                   eval      slstk1 = sL1slstk1
GMMaMC                   eval      slstk2 = sL1slstk2
GMMaMC                   eval      slstk3 = sL1slstk3
     C*
     C*------------------------------------------------------------
     C*     This code is TEMPORARY. DELETE for Go Live Run.
     C****               if        slstk1 = 0
     C****                         and slstk2 = 0
     C****                         and slstk3 = 0
     C****               eval      slstk1 = 50
     C****               endif
     C*------------------------------------------------------------
     C*
     C                   update    slrec2
     C*
     C*      Update NDS slot that Transfer completed.
     C                   eval      sL1slstat = 'TF'
     C                   update    slrec1
     C*
GMMaAC*----------------------------------------------
GMMaAC*      New BFC base slot already occupied, create virtual slot.
     C                   other
GMMaAC*
GMMaAC                   unlock    slot2
GMMaAC*
GMMaAC                   exsr      zzmanual
GMMaAC                   if        error = '1'
GMMaDC**                 eval      errorcode = '*BFCSLTNOTAVL'
GMMaDC**                 exsr      zzprinterr
     C                   unlock    slot1
     C                   unlock    slot2
GMMaAC                   iter
GMMaAC*
GMMaAC                   else
GMMaAC*      Virtual pick slot created for item.
GMMaAC*
GMMaAC*      Put item into New BFC slot.
GMMaAC*
GMMaAC     sl2key        chain     slot2
GMMaAC                   if        %found(slot2)
GMMaAC                   eval      slitem = sL1slitem
GMMaAC                   eval      slstat = 'A '
GMMaAC                   if        exist = '0'
GMMaAC                   eval      slstk1 = sL1slstk1
GMMaAC                   eval      slstk2 = sL1slstk2
GMMaAC                   eval      slstk3 = sL1slstk3
GMMaAC                   else
GMMaAC                   eval      slstk1 = slstk1 + sL1slstk1
GMMaAC                   eval      slstk2 = slstk2 + sL1slstk2
GMMaAC                   eval      slstk3 = slstk3 + sL1slstk3
GMMaAC                   endif
GMMaAC*
GMMaAC*------------------------------------------------------------
GMMaAC*     This code is TEMPORARY. DELETE for Go Live Run.
GMMaAC****               if        slstk1 = 0
GMMaAC****                         and slstk2 = 0
GMMaAC****                         and slstk3 = 0
GMMaAC****               eval      slstk1 = 50
GMMaAC****               endif
GMMaAC*------------------------------------------------------------
GMMaAC*
GMMaAC                   update    slrec2
GMMaAC*
GMMaAC*      Update NDS slot that Transfer completed.
GMMaAC                   eval      sL1slstat = 'TF'
GMMaAC                   update    slrec1
GMMaAC*
GMMaAC*
GMMaAC                   endif                                                  Slot2 Chain Endif
GMMaAC*
GMMaAC                   endif                                                  Error Endif
GMMaAC*
     C                   ENDSL                                                  Slot2 Endsl
     C*
     C                   Endif                                                  Slotxref Endif
     C*
     C                   ENDSL                                                  Slot1 Endsl
     C*
     C                   ENDDO                                                  Slot1 Enddo
     C*
     C                   MOVE      *ON           *INLR
     C*
GMMaA*----------------------------------------------------------------
GMMaA*
GMMaA*  ZZMANUAL    Get slot to use for manual putaway.
GMMaA*
GMMaAC     zzmanual      begsr
GMMaAC                   eval      error = *off
GMMaAC                   eval      exist = *off
GMMaAC                   eval      newvs = *off
GMMaA*
GMMaA*  Check if item already exists in the base slot
GMMaA*    or in a corresponding virtual slot.
GMMaA*
GMMaAC                   exsr      zzcksl
GMMaA*
GMMaA*  If item doesn't already exist in the slot,
GMMaA*    Then try to get a new virtual slot number for it.
GMMaA*
GMMaAC                   if        exist = *off
GMMaAC                   exsr      zzckns
GMMaAC                   if        error = *on
GMMaAC                   eval      errorcode = '*VRTCRTFAIL'
GMMaAC                   exsr      zzprinterr
GMMaAC                   goto      endman
GMMaAC                   else
GMMaA*
GMMaA*
GMMaA*  Create new slot record
GMMaA*  $V = from Physical slot when virtual was checked
GMMaA*  PH = from saved from physical slot when virtual was checked
GMMaA*  SV = saved from 'FROM' slot.
GMMaA*  SL = saved from 'FROM' slot.
GMMaAC                   if        newvs = *on
GMMaA*
GMMaAC                   clear                   slrec2
GMMaA*
GMMaAC                   eval      slwhse = $vwhse
GMMaAC                   eval      slwhdp = $vwhdp
GMMaAC                   eval      slstat = 'A '
GMMaAC                   eval      slaisl = $vaisl
GMMaAC                   eval      slloc  = $vloc
GMMaAC                   eval      slrlvl = $vrlvl
GMMaAC                   eval      slhand = $vhand
GMMaAC                   eval      slside = phside
GMMaAC                   eval      slstyp = $vstyp
GMMaAC                   eval      sldisp = $vdisp
GMMaAC                   eval      slsdef = phsdef
GMMaAC                   eval      sldesg = phdesg
GMMaAC                   eval      slactv = phactv
GMMaAC                   eval      slbld  = phbld
GMMaAC                   eval      slpseq = $vpseq
GMMaAC                   eval      slprty = 0
GMMaAC
GMMaAC                   eval      slslfd = 0
GMMaAC                   eval      slpick = $vpick
GMMaAC                   eval      slrsrv = 'V'
GMMaAC                   eval      slexpd = 0
GMMaAC
GMMaAC                   eval      slsdte = impdte
GMMaAC                   eval      slstim = imptim
GMMaAC                   eval      slstk1 = 0
GMMaAC                   eval      slstk2 = 0
GMMaAC                   eval      slstk3 = 0
GMMaA*
GMMaAC                   write     slrec2                               79
GMMaAC                   if        *in79
GMMaAC                   eval      error = *on
GMMaAC                   eval      errorcode = '*VRTCRTFAIL'
GMMaAC                   exsr      zzprinterr
GMMaAC                   goto      endman
GMMaAC                   endif
GMMaA*
GMMaA*  create vslot record.
GMMaA*
GMMaAC                   eval      vswhse = $vwhse
GMMaAC                   eval      vswhdp = $vwhdp
GMMaAC                   eval      vsaisl = $vaisl
GMMaAC                   eval      vsloc  = $vloc
GMMaAC                   eval      vsrlvl = $vrlvl
GMMaAC                   eval      vshand = $vhand
GMMaAC                   eval      vsdisp = $vdisp
GMMaAC                   eval      vspdis = phdisp
GMMaAC                   eval      vscdte = impdte
GMMaAC                   eval      vsctim = imptim
GMMaAC                   add       1             vsctim
GMMaAC                   write     vsrec                                79
GMMaAC                   if        *in79
GMMaAC                   eval      error = *on
GMMaAC                   eval      errorcode = '*VRTCRTFAIL'
GMMaAC                   exsr      zzprinterr
GMMaAC                   goto      endman
GMMaAC                   endif
GMMaA***
GMMaAC                   endif
GMMaA***
GMMaA*
GMMaAC                   endif
GMMaA*
GMMaAC                   endif
GMMaA*
GMMaAC     endman        endsr
GMMaA*
GMMaA*----------------------------------------------------------------
GMMaA*
GMMaA*  ZZCKSL   Check if item exists in reg or V slot
GMMaA*
GMMaAC     zzcksl        begsr
GMMaAC     keysl2        chain(n)  slot2                              79
GMMaAC                   if        not *in79  and
GMMaAC                             slitem = sL1slitem
GMMaAC                   eval      exist = *on
GMMaAC                   goto      endcks
GMMaAC                   else
GMMaAC     keysl2        setll     vslot2
GMMaAC     nxt1          tag
GMMaAC     keysl2        reade     vslot2                                 78
GMMaAC                   if        not *in78
GMMaAC     keyvs         chain(n)  slot2                              79
GMMaAC                   if        not *in79  and
GMMaAC                             slitem = sL1slitem
GMMaAC                   eval      exist = *on
GMMaAC                   eval      xfdisp = sldisp
GMMaAC                   goto      endcks
GMMaAC                   else
GMMaAC                   goto      nxt1
GMMaAC                   endif
GMMaAC                   endif
GMMaAC                   endif
GMMaA*
GMMaAC     endcks        endsr
GMMaA
GMMaA*----------------------------------------------------------------
GMMaA*
GMMaA*  ZZCKNS   Use reg slot or get new Vslot.
GMMaA*
GMMaAC     zzckns        begsr
GMMaAC                   eval      newvs = *off
GMMaAC                   eval      error = *on
GMMaAC     keysl2        chain(n)  slot2                              79
GMMaAC                   if        not *in79
GMMaAC                   if        slitem = *blanks
GMMaAC                   eval      error = *off
GMMaAC                   goto      endckn
GMMaAC                   else
GMMaA*
GMMaA*   Get out if physical slot already uses both
GMMaA*   positions of handstack field.
GMMaA*
GMMaAC                   movea     slhand        a2
GMMaAC                   if        a2(1) <> ' '
GMMaAC                   goto      endckn
GMMaAC                   endif
GMMaA*
GMMaA*   Set handstack flag for later use.
GMMaA*
GMMaAC                   if        slhand <> ' '
GMMaAC                   eval      flaghs = *on
GMMaAC                   else
GMMaAC                   eval      flaghs = *off
GMMaAC                   endif
GMMaA*
GMMaA* SAVE PHYSICAL SLOT FIELDS
GMMaA*
GMMaAC                   eval      phwhse = slwhse
GMMaAC                   eval      phwhdp = slwhdp
GMMaAC                   eval      phaisl = slaisl
GMMaAC                   eval      phloc  = slloc
GMMaAC                   eval      phrlvl = slrlvl
GMMaAC                   eval      phhand = slhand
GMMaAC                   eval      phside = slside
GMMaAC                   eval      phstyp = slstyp
GMMaAC                   eval      phdisp = sldisp
GMMaAC                   eval      phsdef = slsdef
GMMaAC                   eval      phdesg = sldesg
GMMaAC                   eval      phpseq = slpseq
GMMaAC                   eval      phactv = slactv
GMMaAC                   eval      phbld  = slbld
GMMaAC                   eval      phslfd = slslfd
GMMaA***
GMMaAC                   eval      $vpseq = slpseq
GMMaAC                   eval      $vdisp = *blanks
GMMaAC                   eval      k = 0
GMMaA*
GMMaAC                   eval      $vwhse = slwhse
GMMaAC                   eval      $vwhdp = slwhdp
GMMaAC                   eval      $vaisl = slaisl
GMMaAC                   eval      $vloc  = slloc
GMMaAC                   eval      $vrlvl = slrlvl
GMMaAC                   eval      $vhand = *blanks
GMMaAC                   eval      $vstyp = slstyp
GMMaAC                   eval      $vpseq = slpseq
GMMaAC                   eval      $vdisp = *blanks
GMMaAC                   eval      $vpick = slpick
GMMaA*
GMMaA*** Loop & increment handstack to find new v-slot to create.
GMMaA*
GMMaAC                   dow       k < 702
GMMaAC                   add       1             k
GMMaA*
GMMaA*     If physical slot had handstack then limit hs we can use.
GMMaA*
GMMaAC                   if        flaghs = *on
GMMaAC                   movea     hnd(k)        a2n
GMMaAC                   if        a2n(1) <> a2(2)
GMMaAC                   iter
GMMaAC                   endif
GMMaAC                   endif
GMMaAC                   eval      $vhand = hnd(k)
GMMaAC                   call      'FRMTVS'
GMMaAC                   parm                    phdisp
GMMaAC                   parm                    flaghs
GMMaAC                   parm                    $vhand            2
GMMaAC                   parm                    $vdisp           12
GMMaA*
GMMaAC     ckkey         setll     slot2                                  79
GMMaAC                   if        not *in79
GMMaAC                   eval      newvs = *on
GMMaAC                   eval      error = *off
GMMaAC                   eval      xfdisp = $vdisp
GMMaAC                   leave
GMMaAC                   else
GMMaAC                   iter
GMMaAC                   endif
GMMaAC                   enddo
GMMaAC                   endif
GMMaAC                   endif
GMMaA*
GMMaAC     endckn        endsr
     C*
     C*
     C*----------------------------------------------------------------
     C     ZZPRINTERR    BEGSR
     C                   IF        *IN90 = '1'
     C                   except    HEAD1
     C                   eval      *in90 = '0'
     C                   ENDIF
     C*
     C                   select
     C                   when      errorcode = '*NONDSXREF'
     C                   eval      errmsg = 'NDS Slot Not in XRef'
     C*
     C                   when      errorcode = '*NOBFCSLOT'
     C                   eval      errmsg = 'BFC Slot Not Found'
     C*
     C                   when      errorcode = '*BFCSLTNOTAVL'
     C                   eval      errmsg = 'BFC Slot Not Available'
GMMaAC*
GMMaAC                   when      errorcode = '*VRTCRTFAIL'
GMMaAC                   eval      errmsg = 'Failed to Create Vrt Slot'
     C*
     C                   endsl
     C*
     C                   except    DETAIL1
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     OQSYSPRT   E            HEAD1          1  2
     O                                            8 'QDGMM020'
     O                                           76 'NDS to BFC Slot Migration '
     O                                           89 'Exceptions   '
     O                                          127 'Page'
     O                       PAGE               132
     O*
     O          E            HEAD1          1
     O                       RDATE         Y      8
     O                       RTIME               18 '  :  :  '
     O*
     O          E            HEAD1          1
     O                                           12 'Warehouse : '
     O                       KYWHSE        4     15
     O          E            HEAD1          1
     O                                          132 ' '
     O          E            HEAD1          0
     O                                            6 '______'
     O                                           18 '___________'
     O                                           30 '________'
     O                                           51 '___________________'
     O                                           69 '________'
     O                                           79 '________'
     O                                           89 '________'
     O                                           99 '________'
     O                                          107 '_____'
     O                                          121 '________'
     O                                          132 '________'
     O          E            HEAD1          1
     O                                            6 'Whdp  '
     O                                           20 'NDS Slot '
     O                                           34 'BFC Slot '
     O                                           40 'Item#'
     O                                          105 'Error Message'
     O          E            DETAIL1     1  1
     O                       sL1slwhdp            5
     O                       sL1sldisp           20
     O                       xfdisp              34
     O                       sL1slitem           51
     O                       errmsg             132
** LTR
 ABCDEFGHIJKLMNOPQRSTUVWXYZ
