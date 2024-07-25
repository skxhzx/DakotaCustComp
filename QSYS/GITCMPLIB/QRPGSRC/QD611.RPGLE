     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  QD611     New product in pick slot and old in overflow
     *  Hemant Kapadia
     *  14 July, 2004
     *
     *  Note: Open query file in CL program restricts to warehouse/
     *        Department/Fixed section and Pick slots records only
     *        for SLOT4 file.
     *
     *
     *  Revisions
     *
     *    08/27/97  HNK 4.04
     *      - Created.
510a *    10/04/06  RH  5.10a
     *      - Enh: Change to print by aisle, edit expiration and entered date
700aA*    08/22/16  JCJ  7.00a
     *      - Enh: Added enter date logic to SR Find.
720aA*    06/25/18  LMC  7.20a
     *      - Fix: overflow slot date were not being converted for
     *        each slot, so it was printing the wrong dates.
     *
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
     Fslot4     ip   e           k disk
     Fslot3     if   e           k disk
     F                                     rename(slrec:record)
     Fpiritem   if   e           k disk
     Fitemdsc   if   e           k disk
     Fqd611pr   o    e             printer oflind(*in90)
     *****************************************************************
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
     *
     D $perm           ds
     D  xxerm                  1     60
     D  $pmsg                  1      4
     *----------------------------------------------------------------
     * Variables
     D count           s              3  0
     D first           s              1
     D forevr          s              1
     D found           s              1
     D kyitem          s                   like(slitem)
     D kypick          s                   like(slpick)
     D kystat          s                   like(slstat)
     D kywhse          s                   like(slwhse)
     D prtlin          s              3  0
     D sventd          s                   like(slentd)
     D svexpd          s                   like(slexpd)
     D svwhdp          s                   like(slwhdp)
     D w1whdp          s                   like(slwhdp)
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *
     *  Key fields
     *
     *
     *          *LIKE     DEFN SLITEM    SVITEM
     *          *LIKE     DEFN SLDISP    SVDISP
     *          *LIKE     DEFN SLPICK    SVPICK
     *
     C     slkey2        klist
     C                   kfld                    kywhse
     C                   kfld                    kyitem
     C                   kfld                    kystat
     ***                  KFLD           KYPICK
     *
     C     itkey         klist
     C                   kfld                    kywhse
     C                   kfld                    svitem
     C     idkey         klist
     C                   kfld                    kywhse
     C                   kfld                    svitem
     *
     *----------------------------------------------------------------
     *
     *  Report Heading
     *
     *
     C                   if        *in90  or
     C                             first = *on
     C                   exsr      zrfrmt
     C                   exsr      zrhead
     C                   endif
     *
     * Find out if the item has more than one slot.
     *
510aD*                    Z-ADD1         KYWHSE
510aMC                   eval      kywhse = slwhse
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'N'
     C                   eval      kyitem = slitem
     C                   eval      sventd = slentd
     C                   eval      svexpd = slexpd
     C                   eval      svitem = slitem
     C                   eval      svpick = slpick
     C                   eval      svdisp = sldisp
     C                   eval      svstk1 = slstk1
     C                   exsr      find
     *
     C                   eval      first = *off
     *
     C     out           tag
     CLr                 write     skip1
     CLr                 write     foot1
     *****************************************************************
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   eval      forevr = *on
     *
     C                   time                    time
     C                   eval      first = *on
     C                   eval      count = 0
     C                   eval      prtlin = 0
     C                   eval      svwhdp = *blanks
     C                   eval      found = *off
     C                   endsr
     *****************************************************************
     *
     *  FIND    Find out if the item has more than one pick slot.
     *
     C     find          begsr
     *
     C                   eval      found = *off
     C     slkey2        setll     slot3                              79
     C                   dow       forevr = forevr
     C     slkey2        reade     slot3                                  79
     C                   if        *in79
     C                   leave
     C                   endif
     *
510aD**         SLRLVL    IFEQ 1
510aMC                   if        slpick = 'Y'
     C                   iter
     C                   endif
     *
     C                   if        slexpd <> 0  and
     C                             slexpd < svexpd
700aAC                             or slexpd = 0
700aAC                             and slentd < sventd

720aAc* Moved this up so it was outside of the if found = *off logic
720aAc* the dates were not being converted for each overlow slot.
720aMC                   if        slentd = 0
720aMC                   eval      w1entd = 0
720aMC                   else
720aMC                   eval      $cvcmd = '*CMDMDY '
720aMC                   move      slentd        $cvd8i
720aMC                   call      @cvtdt
720aMC                   parm                    $cvtdt
720aMC                   eval      w1entd = $cvd6o
720aMC                   endif
720aM*
720aM*   Convert expired date.
720aM*
720aMC                   if        slexpd = 0
720aMC                   eval      w1expd = 0
720aMC                   else
720aMC                   eval      $cvcmd = '*CMDMDY '
720aMC                   move      slexpd        $cvd8i
720aMC                   call      @cvtdt
720aMC                   parm                    $cvtdt
720aMC                   eval      w1expd = $cvd6o
720aMC                   endif
     *
     C                   if        found = *off
     C                   write     skip1
     *
     *
     *
     C     itkey         chain     piritem                            79
     C                   if        *in79
     C                   eval      itdesc = *blanks
     C                   endif
     *
     C     idkey         chain     itemdsc                            79
     C                   if        *in79
     C                   eval      ixdsc2 = *blanks
     C                   endif
     *
     *
     C                   if        sventd = 0
     C                   eval      w2entd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      sventd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w2entd = $cvd6o
     C                   endif
     *
     *   Convert expired date.
     *
     C                   if        svexpd = 0
     C                   eval      w2expd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      svexpd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w2expd = $cvd6o
     C                   endif
     *
     C                   write     detail2
     C                   write     pickds2
     C                   endif
     *
     C                   eval      found = *on
     C                   write     detail1
     C                   endif
     *
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrfrmt        begsr
     *
     C                   endsr
     *****************************************************************
     *
     C     zrhead        begsr
     *
     C                   eval      *in90 = *off
     C                   write     head1
     C                   write     columns
     *
     C                   endsr
