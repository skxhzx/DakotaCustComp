     *----------------------------------------------------------------
     *   Copyright (C) 1999 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  CBI999
     *  13 September, 2001
     *  HNK
     *
     *----------------------------------------------------------------
     *  REVISIONS
     *
     *  10/11/01  HNK  CBIa
     *    Update base slot if it is empty.
CBIbA*  12/27/13  MLB  CBIb
     *    - Enh: Converted pgm to ILE.
CBIcA*  12/27/13  MLB  CBIc
     *    - Fix: Revised pgm to see if slot sent from SAP has any pick
     *      label records that are still open. If yes, bypass slot
     *      delete and write slot to backup file, CBI999HLD.
     *    - If no open pick label rcds are found, but slot has
     *      available qty, bypass slot delete and write slot to
     *      backup file, CBI999HLD.
     *    - Once all import rcds have been processed, process CBI999HLD
     *      rcds at 1=Open status and perform the checks listed above
     *      and if no open pick labels or available qty, then delete
     *      slot and update rcd to 4=Closed status and date/time stamp.
     *    - Added code to purge rcds from CBI999HLD that are older
     *      than 30 days.
CBIdA*  01/15/15  MLB  CBId
     *    - Enh: Revised CBIc mod. Revised to use file PIRITEM1 instead
     *      of ZERO999.  ZERO999 no longer sent from SAP. Per Keith S.
     *      Program will only process items where ITACTV = '99'.
CBIeA*  01/15/15  MLB  CBIe
     *    - Fix: Revised routine ZZPROCCLN to correctly delete records
     *      from CBI999HLD1 that are greater than cutoff. Currently, 30
     *      days.
CBIfA*  01/20/15  MLB  CBIf
     *    - Enh: Revised logic to bypass slots where
     *      SLPICK=Y. Per Mark E. email dated 01/20/2015.
     *
     *----------------------------------------------------------------
     * File Specs
     *
CBIdD*ZERO999   IP   E           K DISK
CBIdMFPIRITEM1  IP   E           K DISK
     FSLOT4     UF   E           K DISK
     FVSLOT1    UF   E           K DISK
CBIcAFCBI999HLD UF A E           K DISK
CBIcAFCBI999HLD1UF   E           K DISK    rename(zrhrec : zrhrec1)
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                SDS
     D  #PROG            *PROC
     D  #JOB                 244    253
     D  #USER                254    263
     D  #JOBN                264    269
     D  #JOBDT               276    281  0
     D  #JOBTM               282    287  0
     *
     *----------------------------------------------------------------
     *
CBIcAD @cvtdt          c                   const('CVTDTE')
CBIcAD $cvtdt          ds
CBIcAD  $cvcmd                 1      8
CBIcAD  $cvprg                 9     18
CBIcAD  $cvd6i                19     24
CBIcAD  $cvd8i                25     32
CBIcAD  $cvd6o                33     38  0
CBIcAD  $cvd8o                39     46  0
CBIcAD  $cvsto                47     64
CBIcAD  $cvrtn                65     72
CBIcAD  $cverm                73    132
CBIcAD  $cvmsg                73     76

     *----------------------------------------------------------------
     * Work Variables
     *----------------------------------------------------------------

CBIcAD Cutoff          s              8  0 inz(0)
CBIcAD OKDelete        s              4    inz('*YES')
CBIcAD Today           s              8  0 inz(0)
CBIcAD Todaytime       s              6  0 inz(0)
     D FOREVR          s              1
     D kystat          s              1

     *----------------------------------------------------------------
     * Main line
     *
     C                   MOVE      *OFF          FOREVR
     *  Define key for SLOT4 file. (Partial Key)
     *
     C     SLKEY         KLIST
CBIdD*                  KFLD                    ZRWHSE
CBIdMC                   KFLD                    ITWHSE
CBIdD*                  KFLD                    ZRWHDP
CBIdMC                   KFLD                    ITWHDP
CBIdD*                  KFLD                    ZRITEM
CBIdMC                   KFLD                    ITITEM
CBIcA*
CBIcAC     keysl4        KLIST
CBIcAC                   KFLD                    ZRHWHSE
CBIcAC                   KFLD                    ZRHWHDP
CBIcAC                   KFLD                    ZRHITEM
CBIcAC                   KFLD                    ZRHDISP
     *
     *  Define key for VSLOT1 file. (Partial Key)
     *
     C     VSKEY         KLIST
     C                   KFLD                    SLWHSE
     C                   KFLD                    SLWHDP
     C                   KFLD                    SLDISP
     *
CBIdAC                   select
CBIdAC                   when      itactv = '99'
CBIdA*
     C     SLKEY         SETLL     SLOT4
     C                   DOW       FOREVR = FOREVR
     C     SLKEY         READE     SLOT4                                  79
     C                   IF        *IN79
     C                   LEAVE
     C                   ENDIF
CBIfA*
CBIfA*      Bypass items assigned to Pick slot.
CBIfAC                   if           slpick = 'Y'
CBIfAC                   iter
CBIfAC                   endif
CBIcA*
CBIcAC                   eval      okdelete = '*YES'
CBIcA*
CBIcA*      Check for open label records against slot.
CBIcAC                   exsr      zzckopn
CBIcAC                   select
CBIcAC                   when      okdelete = '*YES'
CBIcAC                   exsr      zzavail
CBIcAC                   if        okdelete = '*NO '
CBIcAC                   exsr      zzupdhold
CBIcAC                   iter
CBIcAC                   endif
CBIcA*
CBIcA*      Open label records found, write slot/item into hold file.
CBIcAC                   when      okdelete = '*NO '
CBIcAC                   exsr      zzupdhold
CBIcAC                   iter
CBIcA*
CBIcAC                   endsl
CBIcA*
     C                   IF        SLRSRV = 'V'
     C                   EXSR      ZZDEL
     C                   DELETE    SLREC
CBIaAC                   ELSE
CBIaAC                   MOVE      *BLANKS       SLITEM
CBIaAC                   MOVE      'V '          SLSTAT
CBIaAC                   Z-ADD     0             SLSTK1
CBIaAC                   Z-ADD     0             SLSTK2
CBIaAC                   Z-ADD     0             SLSTK3
CBIaAC                   Z-ADD     0             SLALC1
CBIaAC                   Z-ADD     0             SLALC2
CBIaAC                   Z-ADD     0             SLALC3
CBIaAC                   Z-ADD     0             SLPCK1
CBIaAC                   Z-ADD     0             SLPCK2
CBIaAC                   Z-ADD     0             SLPCK3
CBIaAC                   Z-ADD     0             SLTFR1
CBIaAC                   Z-ADD     0             SLTFR2
CBIaAC                   Z-ADD     0             SLTFR3
CBIaAC                   Z-ADD     0             SLRCV1
CBIaAC                   Z-ADD     0             SLRCV2
CBIaAC                   Z-ADD     0             SLRCV3
CBIaAC                   UPDATE    SLREC
     C                   ENDIF
     C                   ENDDO
     *
CBIdAC                   endsl
     *
CBIcA*      Process open records in Hold file to delete slots.
CBIcACLR                 exsr      zzprochld
CBIcA*
CBIcA*      Delete closed records in Hold file older > 30 days.
CBIcACLR                 exsr      zzproccln
CBIcA*
     CLR                 RETURN
CBIcA
CBIcA*-------------------------------------------------------------------
CBIcA*  ZZCKOPN     Check for open labels against slot.
CBIcA*-------------------------------------------------------------------
CBIcA
CBIcAC     zzckopn       BegSr
CBIcA*
CBIcAC                   call      'OPNSQTY'
CBIcAC                   parm      slwhse        $pwhse            3 0
CBIcAC                   parm      slwhdp        $pwhdp            5
CBIcAC                   parm      sldisp        $pdisp           12
CBIcA*
CBIcAC                   parm      0             $palc1            5 0
CBIcAC                   parm      0             $palc2            3 0
CBIcAC                   parm      0             $palc3            3 0
CBIcA*
CBIcAC                   parm      0             $ptfr1            5 0
CBIcAC                   parm      0             $ptfr2            3 0
CBIcAC                   parm      0             $ptfr3            3 0
CBIcA*
CBIcAC                   parm      0             $ppck1            5 0
CBIcAC                   parm      0             $ppck2            3 0
CBIcAC                   parm      0             $ppck3            3 0
CBIcA*
CBIcAC                   parm      0             $prcv1            5 0
CBIcAC                   parm      0             $prcv2            3 0
CBIcAC                   parm      0             $prcv3            3 0
CBIcA*
CBIcAC                   parm      0             $punk1            5 0
CBIcAC                   parm      0             $punk2            3 0
CBIcAC                   parm      0             $punk3            3 0
CBIcA*
CBIcAC                   if           $palc1 <> 0
CBIcAC                             or $palc2 <> 0
CBIcAC                             or $palc3 <> 0
CBIcA*
CBIcAC                             or $ptfr1 <> 0
CBIcAC                             or $ptfr2 <> 0
CBIcAC                             or $ptfr3 <> 0
CBIcA*
CBIcAC                             or $ppck1 <> 0
CBIcAC                             or $ppck2 <> 0
CBIcAC                             or $ppck3 <> 0
CBIcA*
CBIcAC                             or $prcv1 <> 0
CBIcAC                             or $prcv2 <> 0
CBIcAC                             or $prcv3 <> 0
CBIcA*
CBIcAC                             or $punk1 <> 0
CBIcAC                             or $punk2 <> 0
CBIcAC                             or $punk3 <> 0
CBIcAC                   eval      okdelete = '*NO '
CBIcAC                   Endif
CBIcA*
CBIcAC                   EndSr
CBIcA
CBIcA*-------------------------------------------------------------------
CBIcA*  ZZAVAIL     Check for available qty in slot.
CBIcA*-------------------------------------------------------------------
CBIcA
CBIcAC     zzavail       BegSr
CBIcA*
CBIcAC                   CALL      'CCQTY'
CBIcAC                   parm                    slwhse
CBIcAC                   parm                    slitem
CBIcAC                   parm                    slstyp
CBIcAC                   parm                    slwhdp
CBIcAC                   parm                    slaisl
CBIcAC                   parm                    slpseq
CBIcAC                   parm                    slrlvl
CBIcAC                   parm                    slhand
CBIcA*
CBIcAC                   PARM                    $lpck1            5 0
CBIcAC                   PARM                    $lpck2            3 0
CBIcAC                   PARM                    $lpck3            3 0
CBIcA*
CBIcAC                   PARM                    $lalc1            5 0
CBIcAC                   PARM                    $lalc2            3 0
CBIcAC                   PARM                    $lalc3            3 0
CBIcA*
CBIcAC                   CALL      'SLOTQTY'
CBIcAC                   PARM                    SLSTK1
CBIcAC                   PARM                    SLSTK2
CBIcAC                   PARM                    SLSTK3
CBIcA*
CBIcAC                   PARM                    SLALC1
CBIcAC                   PARM                    SLALC2
CBIcAC                   PARM                    SLALC3
CBIcA*
CBIcAC                   PARM                    SLTFR1
CBIcAC                   PARM                    SLTFR2
CBIcAC                   PARM                    SLTFR3
CBIcA*
CBIcAC                   PARM                    SLPCK1
CBIcAC                   PARM                    SLPCK2
CBIcAC                   PARM                    SLPCK3
CBIcA*
CBIcAC                   PARM                    SLRCV1
CBIcAC                   PARM                    SLRCV2
CBIcAC                   PARM                    SLRCV3
CBIcA*
CBIcAC                   PARM                    STOCK1            5 0
CBIcAC                   PARM                    STOCK2            3 0
CBIcAC                   PARM                    STOCK3            3 0
CBIcA*
CBIcAC                   PARM                    AVAIL1            5 0
CBIcAC                   PARM                    AVAIL2            3 0
CBIcAC                   PARM                    AVAIL3            3 0
CBIcA*
CBIcA*
CBIcA*  Increase available by Container/cruise pick/allocate quantity.
CBIcAC                   ADD       $LPCK1        STOCK1
CBIcAC                   ADD       $LPCK2        STOCK2
CBIcAC                   ADD       $LPCK3        STOCK3
CBIcA*
CBIcAC     AVAIL1        ADD       $LPCK1        AVAIL1
CBIcAC     AVAIL2        ADD       $LPCK2        AVAIL2
CBIcAC     AVAIL3        ADD       $LPCK3        AVAIL3
CBIcA*
CBIcAC     AVAIL1        ADD       $LALC1        AVAIL1
CBIcAC     AVAIL2        ADD       $LALC2        AVAIL2
CBIcAC     AVAIL3        ADD       $LALC3        AVAIL3
CBIcA*
CBIcA*
CBIcAC                   if           avail1 <> 0
CBIcAC                             or avail2 <> 0
CBIcAC                             or avail3 <> 0
CBIcAC                   eval      okdelete = '*NO '
CBIcAC                   Endif
CBIcA*
CBIcAC                   EndSr
CBIcA*
CBIcA*-------------------------------------------------------------------
CBIcA*  ZZUPDHOLD    Update Hold File.
CBIcA*-------------------------------------------------------------------
CBIcA
CBIcAC     zzupdhold     BegSr
CBIcA*
CBIcA*      Check for existing closed whse/whdp/disp/item rcd on file.
CBIcAC                   eval      kystat = '4'
CBIcAC     keyzrh        setll     cbi999hld
CBIcAC                   if        %equal(cbi999hld)
CBIcAC     keyzrh        chain     cbi999hld
CBIcAC                   if        %found(cbi999hld)
CBIcAC                   eval      zrhstat = '1'
CBIcAC                   eval      zrhsdte = today
CBIcAC                   eval      zrhstim = todaytime
CBIcAC                   update    zrhrec
CBIcAC                   endif
CBIcA*
CBIcA*      No existing closed rcd found, check for open rcd on file.
CBIcAC                   else
CBIcAC                   eval      kystat = '1'
CBIcAC     keyzrh        setll     cbi999hld
CBIcAC                   if        %equal(cbi999hld)
CBIcA*      Rcd already on file, nothing to do.
CBIcAC                   else
CBIcA*
CBIcA*      Add new rcd to file.
CBIcAC                   eval      zrhwhse = slwhse
CBIcAC                   eval      zrhwhdp = slwhdp
CBIcAC                   eval      zrhdisp = sldisp
CBIcAC                   eval      zrhitem = slitem
CBIcAC                   eval      zrhstat = '1'
CBIcAC                   eval      zrhsdte = today
CBIcAC                   eval      zrhstim = todaytime
CBIcAC                   write (e) zrhrec
CBIcAC                   endif
CBIcA*
CBIcAC                   endif
CBIcA*
CBIcAC                   EndSr
CBIcA*
     *****************************************************************
     C     ZZDEL         BEGSR
     *
     C     VSKEY         SETLL     VSLOT1
     C                   DOW       FOREVR = FOREVR
     C     VSKEY         READE     VSLOT1                                 79
     C                   IF        *IN79
     C                   LEAVE
     C                   ENDIF
     C                   DELETE    VSREC
     C                   ENDDO
     C                   ENDSR
CBIcA*
CBIcA*-------------------------------------------------------------------
CBIcA*  ZZPROCHLD    Process Hold file for slots to purge.
CBIcA*-------------------------------------------------------------------
CBIcA
CBIcAC     zzprochld     BegSr
CBIcA*
CBIcAC                   eval      kystat = '1'
CBIcAC     keyzrh2       setll     cbi999hld1
CBIcAC                   dow       forevr = forevr
CBIcAC     keyzrh2       reade     cbi999hld1
CBIcAC                   if        %eof(cbi999hld1)
CBIcAC                   leave
CBIcAC                   endif
CBIcA*
CBIcAC     keysl4        chain     slot4
CBIcAC                   if        not %found(slot4)
CBIcA*      Slot/Item not found, update hold rcd to closed.
CBIcAC                   eval      zrhstat = '4'
CBIcAC                   eval      zrhsdte = today
CBIcAC                   eval      zrhstim = todaytime
CBIcAC                   update    zrhrec1
CBIcA*
CBIcAC                   iter
CBIcAC                   endif
CBIcA*
CBIcAC                   eval      okdelete = '*YES'
CBIcA*
CBIcA*      Check for open label records against slot.
CBIcAC                   exsr      zzckopn
CBIcAC                   select
CBIcAC                   when      okdelete = '*YES'
CBIcAC                   exsr      zzavail
CBIcAC                   if        okdelete = '*NO '
CBIcAC                   unlock    slot4
CBIcAC                   iter
CBIcA*
CBIcAC                   else
CBIcA*
CBIcAC                   if        SLRSRV = 'V'
CBIcAC                   EXSR      ZZDEL
CBIcAC                   DELETE    SLREC
CBIcA*
CBIcAC                   ELSE
CBIcAC                   MOVE      *BLANKS       SLITEM
CBIcAC                   MOVE      'V '          SLSTAT
CBIcAC                   Z-ADD     0             SLSTK1
CBIcAC                   Z-ADD     0             SLSTK2
CBIcAC                   Z-ADD     0             SLSTK3
CBIcAC                   Z-ADD     0             SLALC1
CBIcAC                   Z-ADD     0             SLALC2
CBIcAC                   Z-ADD     0             SLALC3
CBIcAC                   Z-ADD     0             SLPCK1
CBIcAC                   Z-ADD     0             SLPCK2
CBIcAC                   Z-ADD     0             SLPCK3
CBIcAC                   Z-ADD     0             SLTFR1
CBIcAC                   Z-ADD     0             SLTFR2
CBIcAC                   Z-ADD     0             SLTFR3
CBIcAC                   Z-ADD     0             SLRCV1
CBIcAC                   Z-ADD     0             SLRCV2
CBIcAC                   Z-ADD     0             SLRCV3
CBIcAC                   UPDATE    SLREC
CBIcAC                   ENDIF
CBIcA*
CBIcAC                   endif
CBIcA*
CBIcA*      Open label records found, check next rcd.
CBIcAC                   when      okdelete = '*NO '
CBIcAC                   unlock    slot4
CBIcAC                   iter
CBIcA*
CBIcAC                   endsl
CBIcA*
CBIcAC                   enddo
CBIcA*
CBIcAC                   EndSr
CBIcA*
CBIcA*-------------------------------------------------------------------
CBIcA*  ZZPROCCLN    Process Hold file for recods to purge.
CBIcA*-------------------------------------------------------------------
CBIcA
CBIcAC     zzproccln     BegSr
CBIcA*
CBIcAC                   eval      kystat = '4'
CBIcAC     keyzrh3       setgt     cbi999hld1
CBIcAC                   dow       forevr = forevr
CBIeD*    zrwhse        reade     cbi999hld1
CBIeMC     keyzrh3p      readpe    cbi999hld1
CBIcAC                   if        %eof(cbi999hld1)
CBIcAC                   leave
CBIcAC                   endif
CBIcA*
CBIcA*      Delete rcds from Hold file older than cutoff date.
CBIeAC                   if        zrhsdte < cutoff
CBIcAC                   delete    zrhrec1
CBIeAC                   endif
CBIcAC                   enddo
CBIcA*
CBIcAC                   EndSr
CBIcA
CBIcA*-------------------------------------------------------------------
CBIcA*  *InzSR     Program initialization subroutine.
CBIcA*-------------------------------------------------------------------
CBIcA
CBIcAC     *InzSR        BegSr
CBIcA*
CBIcAC     keyzrh        klist
CBIcAC                   kfld                    slwhse
CBIcAC                   kfld                    kystat
CBIcAC                   kfld                    slwhdp
CBIcAC                   kfld                    sldisp
CBIcAC                   kfld                    slitem
CBIcA*
CBIcAC     keyzrh2       klist
CBIdD*                  kfld                    zrwhse
CBIdMC                   kfld                    itwhse
CBIcAC                   kfld                    kystat
CBIcA*
CBIcAC     keyzrh3       klist
CBIdD*                  kfld                    zrwhse
CBIdMC                   kfld                    itwhse
CBIcAC                   kfld                    kystat
CBIcAC                   kfld                    cutoff
CBIdAC     keyzrh3p      klist
CBIdAC                   kfld                    itwhse
CBIdAC                   kfld                    kystat
CBIcA*
CBIcAC                   Eval      $Cvcmd = '*CURCMD '
CBIcAC                   Call      @Cvtdt
CBIcAC                   Parm                    $Cvtdt
CBIcAC                   eval      Today = $Cvd8o
CBIcAC                   time                    Todaytime
CBIcA*
CBIcA*  Subtract 30 from today's date. To be used with file purge.
CBIcA*
CBIcAC                   CALL      'CLCDUR2'
CBIcAC                   PARM      '*SUB'        $cmd              8
CBIcAC                   PARM      today         $datei            8 0
CBIcAC                   PARM      0             $timei            6 0
CBIcAC                   PARM      0             $years            3 0
CBIcAC                   PARM      0             $month            3 0
CBIcAC                   PARM      30            $days             3 0
CBIcAC                   PARM      0             $hours            3 0
CBIcAC                   PARM      0             $min              3 0
CBIcAC                   PARM      0             $sec              3 0
CBIcAC                   PARM      0             today1            8 0
CBIcAC                   PARM      0             $timeo            6 0
CBIcAC                   eval      cutoff = today1
CBIcA*
CBIcAC                   Endsr
CBIcA
