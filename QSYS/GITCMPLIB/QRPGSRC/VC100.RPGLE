     F********************************************************************
     F*   Copyright (C) 1991 BFC Software, Inc. - All Rights Reserved    *
     F*   BFC Software, Inc.                                             *
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108                           *
     F*   Glen Ellyn, IL  60137                                          *
     F*   (312) 790-8383                                                 *
     F********************************************************************
     F*
     F*  VC100    Vocollect selection program
     F*  Hemant Kapadia
     F*
     F*  Revisions
     F*
     F*    12/12/00  HNK
     F*      - Created
     F*
     F*----------------------------------------------------------------
     F*  File Specs
      *
     FLABEL32   IF   E           K DISK
     FLABEL     UF   E           K DISK
     FPIRTRAN   UF   E           K DISK
     FSLOTID    IF   E           K DISK
     FPIRITEM   IF   E           K DISK
     FORDC      UF A E           K DISK
     FVCLABEL   UF A E           K DISK

     D*--------------------------------------------------------------------
     D                sds
     D  Pgmnam           *Proc

     D*--------------------------------------------------------------------
      * Work fields and parms

     D Forevr          s              1
     D Difpck          s              5  0
     D Difcub          s              9  3
     D Difwgt          s              9  2
     D Difrpl          s              5  0
     D Newpck          s              5  0
     D Newcub          s              9  3
     D Newwgt          s              9  2
     D Newrpl          s              5  0
     D Newseq          s              3  0
     D Today           s              8  0
     D Wktype          s              1
     D Wkrtid          s              5
     D Wkwhse          s              3  0
     D $Ptype          s              8
     D $Plbl#          s              7  0
     D $Ptrn#          s              7  0
     D $Pqpck          s              5  0
     D $Pcwgt          s              7  2
     D*--------------------------------------------------------------------
     *  Called programs
     *
     D @Cvtdt          c                   Const('CVTDTE')
     D*--------------------------------------------------------------------
     *  Called program parameters
     *
     D $Cvtdt          ds
     D $Cvcmd                         8
     D $Cvprg                        10
     D $Cvd6i                         6
     D $Cvd8i                         8
     D $Cvd6o                         6  0
     D $Cvd8o                         8  0
     D $Cvsto                        18
     D $Cvrtn                         8
     D $Cverm                        60
     D $Cvmsg                         4

     C*--------------------------------------------------------------------
      *
      *  Main line
      *
     C     *Entry        PList
     C                   Parm                    $Ptype
     C                   Parm                    $Ptrn#
     C                   Parm                    $Plbl#
     C                   Parm                    $Pqpck
     C                   Parm                    $Pcwgt
      * Verify signon info.
     C                   If        $ptype='SIGNON'
     C                   Exsr      Signon
     C                   Endif

      * Send pick records to Talkman.

     C                   If        $ptype='PICKS'
      * Make sure transaction requested is valid.
     C     ptkey         Chain     Pirtran                            79
     C                   If        *In79  = *On Or Ptgrp1 <> 'S'
     C                   Clear                   Vcrec
     C                   Eval      Vceror = 1
     C                   Eval      Vcerrt = 'Invalid transaction number'
     C                   Eval      Vctrn# = $Ptrn#
     C                   Write     Vcrec
     C                   GoTo      Out
     C                   Endif
     C                   Exsr      Selpck
     C                   Exsr      Selxdk
     C                   Exsr      Selmrg
     C                   Eval      Ptstat = '2'
     C                   Update    Ptrec
     C                   Endif

      * Update pick results.
     C                   If        $Ptype='PICK'
     C                   Exsr      Updpck
     C                   Endif

      * Update catch weight results.
     C                   If        $Ptype='WEIGHT'
     C                   Exsr      Updcwt
     C                   Endif

     C     Out           Tag
     C                   Return

     C*--------------------------------------------------------------------
     C     *Inzsr        BegSr

     C*
     C*  Define partial key for LABEL32 file.
     C*
     C     Keyl32        KList
     C                   Kfld                    Wkwhse
     C                   Kfld                    Wkrtid
     C                   Kfld                    Wktype
     C                   Kfld                    $Ptrn#

     C     Lbkey7        KList
     C                   Kfld                    $Ptrn#
     C                   Kfld                    Wktype

     C     Lbkey         KList
     C                   Kfld                    $Plbl#

     C     Sikey         KList
     C                   Kfld                    Lbwhse
     C                   Kfld                    Lbwhdp
     C                   Kfld                    Lbdisp

     C     Itkey         KList
     C                   Kfld                    Lbwhse
     C                   Kfld                    Lbitem

     C     Ptkey         KList
     C                   Kfld                    $Ptrn#

     C     Ockey         KList
     C                   Kfld                    Wkwhse
     C                   Kfld                    Lbord
     C                   Kfld                    Lbseq
     C                   Kfld                    Lbitem
     C                   Kfld                    Lblbl#

     C     OcNkey        Klist
     C                   Kfld                    Wkwhse
     C                   Kfld                    Lbord
     C                   Kfld                    Lbseq
     C                   Kfld                    Lbitem
     C                   Kfld                    Lblbl#
     C                   Kfld                    NewSeq

     C                   EndSr
     C*--------------------------------------------------------------------
      * selmrg - Send merge records to Talkman.

     C     selmrg        begsr

     C                   clear                   vcrec
     C                   eval      wkrtid = ptrtpo
     C                   eval      wkwhse = ptwhse

      * Process transaction.

     C                   eval      wktype = 'M'
     C     keyl32        setll     label32
B001 C     forevr        doune     forevr
     C     keyl32        reade     label32                                79

     C                   if        *in79 = *on
     C                   leave
     C                   endif
      * Skip label if nothing to pick.
     C                   if        lbqpck = 0
     C                   iter
     C                   endif

     C                   eval      vceror = 0
     C                   eval      vcerrt = ' '
     C                   eval      vctrn# = lbtrn#
     C                   eval      vcstop = lbstop
     C                   eval      vcaisl = lbaisl
     C                   eval      vcloc  = lbloc
     C                   eval      vcdisp = lbdisp
     C                   eval      vcqpck = lbqalc
     C                   eval      vccnum = 2
      * Get slot ID.
     C     sikey         chain     slotid                             79
     C                   if        *in79=*off
     C                   eval      vcslid = siid
     C                   else
     C                   eval      vcslid = 0
     C                   endif
      * Get item info.
     C     itkey         chain     piritem                            79
     C                   if        *in79=*off
     C                   eval      vcdesc = itdesc
     C                   eval      vcsize = ' '
     C                   eval      vcpack = itpdsc
     C                   eval      vcitem = lbitem
     C                   eval      vcmfgc = itvit#
     C                   eval      vcupc  = itupc
     C                   eval      vcuwgt = itswgt
      *    Unit of measure.
     C                   if        lbutyp = 'N'
     C                   eval      vcuflg = '1'
     C                   endif
      *    Unit of measure.
     C                   if        lbutyp = '1'
     C                   eval      vcuflg = '0'
     C                   endif
      *    Catch weight flag.
     C                   if        itcwgt = 'Y'
     C                   eval      vccflg = '1'
     C                   else
     C                   eval      vccflg = '0'
     C                   endif

     C                   endif
     C                   eval      vccwgt = 0
     C                   eval      vcctol = 10
     C                   eval      vclbl# = lblbl#
     C                   eval      vcpal# = lbpal#
     C                   eval      vcstat = 'n'
     C                   write     vcrec

     C                   enddo

     C     endmrg        endsr
     C*--------------------------------------------------------------------
      * selpck - Send pick records to Talkman.

     C     selpck        begsr

     C                   clear                   vcrec
     C                   eval      wkrtid = ptrtpo
     C                   eval      wkwhse = ptwhse

      * Process transaction.

     C                   eval      wktype = 'O'
     C     keyl32        setll     label32
B001 C     forevr        doune     forevr
     C     keyl32        reade     label32                                79

     C                   if        *in79 = *on
     C                   leave
     C                   endif
      * Skip label if cross dock.
     C                   if        lbstyp = 'X'
     C                   iter
     C                   endif
      * Skip label if nothing to pick.
     C                   if        lbqpck = 0
     C                   iter
     C                   endif

     C                   eval      vceror = 0
     C                   eval      vcerrt = ' '
     C                   eval      vctrn# = lbtrn#
     C                   eval      vcstop = lbstop
     C                   eval      vcaisl = lbaisl
     C                   eval      vcloc  = lbloc
     C                   eval      vcdisp = lbdisp
     C                   eval      vcqpck = lbqalc
     C                   eval      vccnum = 2
      * Get slot ID.
     C     sikey         chain     slotid                             79
     C                   if        *in79=*off
     C                   eval      vcslid = siid
     C                   else
     C                   eval      vcslid = 0
     C                   endif
      * Get item info.
     C     itkey         chain     piritem                            79
     C                   if        *in79=*off
     C                   eval      vcdesc = itdesc
     C                   eval      vcsize = ' '
     C                   eval      vcpack = itpdsc
     C                   eval      vcitem = lbitem
     C                   eval      vcmfgc = itvit#
     C                   eval      vcupc  = itupc
     C                   eval      vcuwgt = itswgt
      *    Unit of measure.
     C                   if        lbutyp = 'N'
     C                   eval      vcuflg = '1'
     C                   endif
      *    Unit of measure.
     C                   if        lbutyp = '1'
     C                   eval      vcuflg = '0'
     C                   endif
      *    Catch weight flag.
     C                   if        itcwgt = 'Y'
     C                   eval      vccflg = '1'
     C                   else
     C                   eval      vccflg = '0'
     C                   endif

     C                   endif
     C                   eval      vccwgt = 0
     C                   eval      vcctol = 10
     C                   eval      vclbl# = lblbl#
     C                   eval      vcpal# = lbpal#
     C                   eval      vcstat = 'n'
     C                   write     vcrec

     C                   enddo

     C     endsel        endsr
     C*--------------------------------------------------------------------
      * selxdk - Send xdk records to Talkman.

     C     selxdk        begsr

     C                   clear                   vcrec
     C                   eval      wkrtid = ptrtpo
     C                   eval      wkwhse = ptwhse

      * Process transaction.

     C                   eval      wktype = 'O'
     C     keyl32        setll     label32
B001 C     forevr        doune     forevr
     C     keyl32        reade     label32                                79

     C                   if        *in79 = *on
     C                   leave
     C                   endif
      * Skip label if NOT cross dock.
     C                   if        lbstyp <> 'X'
     C                   iter
     C                   endif
      * Skip label if nothing to pick.
     C                   if        lbqpck = 0
     C                   iter
     C                   endif

     C                   eval      vceror = 0
     C                   eval      vcerrt = ' '
     C                   eval      vctrn# = lbtrn#
     C                   eval      vcstop = lbstop
     C                   eval      vcaisl = lbaisl
     C                   eval      vcloc  = lbloc
     C                   eval      vcdisp = lbdisp
     C                   eval      vcqpck = lbqalc
     C                   eval      vccnum = 2
      * Get slot ID.
     C     sikey         chain     slotid                             79
     C                   if        *in79=*off
     C                   eval      vcslid = siid
     C                   else
     C                   eval      vcslid = 0
     C                   endif
      * Get item info.
     C     itkey         chain     piritem                            79
     C                   if        *in79=*off
     C                   eval      vcdesc = itdesc
     C                   eval      vcsize = ' '
     C                   eval      vcpack = itpdsc
     C                   eval      vcitem = lbitem
     C                   eval      vcmfgc = itvit#
     C                   eval      vcupc  = itupc
     C                   eval      vcuwgt = itswgt
      *    Unit of measure.
     C                   if        lbutyp = 'N'
     C                   eval      vcuflg = '1'
     C                   endif
      *    Unit of measure.
     C                   if        lbutyp = '1'
     C                   eval      vcuflg = '0'
     C                   endif
      *    Catch weight flag.
     C                   if        itcwgt = 'Y'
     C                   eval      vccflg = '1'
     C                   else
     C                   eval      vccflg = '0'
     C                   endif

     C                   endif
     C                   eval      vccwgt = 0
     C                   eval      vcctol = 10
     C                   eval      vclbl# = lblbl#
     C                   eval      vcpal# = lbpal#
     C                   eval      vcstat = 'n'
     C                   write     vcrec

     C                   enddo

     C     endxdk        endsr
     C*--------------------------------------------------------------------
      * Signon

     C     Signon        begsr


     C     endson        endsr
     C*--------------------------------------------------------------------
      * Updcwt - Update Catch weight results

     C     Updcwt        BegSr

     C     lbkey         chain     label                              79

     C     Ockey         SetGt     Ordc
     C     Ockey         ReadPe(n) Ordc                                   79

     C                   If        *in79 = *on
     C                   Eval      Ocseq = 0
     C                   EndIf
     C                   Eval      NewSeq = OcSeq + 1

     C                   Clear                   OcRec
     C     OcNkey        Chain     Ordc                               79
     C                   If        *In79 = *On
     C                   Eval      OcWhse = LbWhse
     C                   Eval      OcOrd  = LbOrd
     C                   Eval      OcSeq# = LbSeq
     C                   Eval      OcItem = LbItem
     C                   Eval      OcSeq  = NewSeq
     C                   Eval      Occwgt = $Pcwgt
     C                   Eval      OcTran = LbTrn#
     C                   Eval      OcLbl# = LbLbl#
     C                   Write     OcRec
     C                   Else
     C                   Eval      OcTran = LbTrn#
     C                   Eval      Occwgt = $Pcwgt
     C                   Update    OcRec
     C                   Endif

     C     Endcwt        EndSr
     C*--------------------------------------------------------------------
      * updpck - Update Pick results

     C     updpck        begsr

     C     lbkey         chain     label                              79
     C                   if        *in79  = *off
     C                   eval      lbqpck = $pqpck
     C                   eval      lbstat = 'C'
     C*  Calculate qty, cube and weight.
     C                   eval      newpck = $pqpck
     C                   eval      newcub = lbucub * newpck
     C                   eval      newwgt = lbuwgt * newpck
     C*  Difference in qty, cube and weight.
     C                   eval      difpck = lbqpck - newpck
     C                   eval      difcub = lbcube - newcub
     C                   eval      difwgt = lbswgt - newwgt
     C                   eval      difrpl = lbqrmn - newrpl

     C**                 if        lbstat = 'C' and difpck = 0
     C**                 unlock    label
     C**                 goto      endupd
     C**                 endif

     C                   if        difpck <> 0
     C                   eval      lbqpck = newpck
     C                   eval      lbcube = newcub
     C                   eval      lbswgt = newwgt
     C                   endif

     C                   if        difrpl <> 0
     C                   eval      lbqrmn = newrpl
     C                   endif
     C*
     C*  Convert today's date into century format.
     C*
     C                   move      '*CURCMD '    $cvcmd
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   z-add     $cvd8o        today
     C                   z-add     today         lbsdte
     C                   time                    lbstim
     C                   update    lbrec
     C                   endif

     C     endupd        endsr

