      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ER390A     Create Work file for task summary by crew
     *  Ginger Andrews
     *  09 December, 2009
     *
     *  Revisions
     *
     *    12/09/09  GJA  5.30
     *      - Created
     *
530a *    07/13/10  GJA  5.30a
     *      - Fix:  EOF statement was incorrect
     *
530b *    08/17/10  GJA  5.30b
     *      - Fix:  Remove replenishments that were skipped.  If task
     *              REPL, REPLTF, REPLRP and quantity is zero do not
     *              process.
640a *    05/12/11  GJA  6.40a
     *      - Enh:  Add client code
710  *    07/25/17  KDE  7.10
     *      - Enh:  Add task code REPLPD for Production Module
     *----------------------------------------------------------------
     *  Custom Client Revisions: Coastal
     *
CSPa *    05/12/11  GJA  CSPa
     *      - Enh:  Omit items BOX05, BOX06, BOX11
     *
     *----------------------------------------------------------------
     *  Custom Client Revision-City Line
     *
CLDa *    10/01/09  GJA  CLDa
     *      - Enh:  incorporate FAB quantity adjustments
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
     Fpirtran   if   e           k disk
     Fpirtran2  if   e           k disk
     F                                     rename(ptrec:ptrec2)
     Fpirtran7  if   e           k disk
     F                                     rename(ptrec:ptrec7)
     Fshift1    if   e           k disk
     Flabel90   if   e           k disk
     Fpiruser1  if   e           k disk
     Fpasstran  if   e           k disk
     Flabeldo   if   e           k disk
     Flabeldo2  if   e           k disk
     F                                     rename(lborec:lborec2)
     Flabeldo3  if   e           k disk
     F                                     rename(lborec:lborec3)
     Fcrew      if   e           k disk
     Ftask      if   e           k disk
CLDaAFpiritem   if   e           k disk
CLDaAFitemfld   if   e           k disk
CLDaAFitemlnk   if   e           k disk
     Fer391     o  a e           k disk
     *****************************************************************
     *----------------------------------------------------------------
     *  Client
      *
CSPaA /COPY QCOPYSRC,ID#COASTAL
CLDaA /COPY QCOPYSRC,ID#CITYLIN
     *----------------------------------------------------------------
     *  Called programs
     *
640aAD @getcl          c                   const('GETCLIENT')
     *----------------------------------------------------------------
     *
     *  Program parameters
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
     D  $litmf                37     51
     D  $ldesc                52     83
     *----------------------------------------------------------------
     *  Variables
     *
     D $tdtetme        s               z
     D $fdtetme        s               z
     D tdtetme         s             26
     D fdtetme         s             26
     D $pemp#          s              5
     D $petim          s              6
     D $pendt          s              8
     D $pfmdt          s              8
     D $pftim          s              6
     D $pvyn           s              1
     D $pwhse          s              3
     D enddte          s              8  0
     D endtim          s              6  0
     D emp#            s              5  0
     D first           s              1
     D forever         s              1
     D frmdte          s              8  0
     D frmtim          s              6  0
     D svemp#          s              5  0
     D shft            s              6
     D svlbl#          s                   like(LBOLBL#)
     D whdp            s              5
     D whse            s              3  0
     *----------------------------------------------------------------
     *
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
     C     *entry        plist
     C                   parm                    $pfmdt            8
     C                   parm                    $pendt            8
     C                   parm                    $pftim            6
     C                   parm                    $petim            6
     C                   parm                    $pvyn             1
     C                   parm                    $pemp#            5
     C                   parm                    $pwhse            3
     C                   parm                    $pcrew            6
     C                   parm                    $pmrg             1
     *
     C                   move      $pfmdt        frmdte
     C                   move      $pendt        enddte
     C                   move      $pftim        frmtim
     C                   move      $petim        endtim
     C                   move      $pemp#        emp#
     C                   move      $pwhse        whse
     *
     *  Main line
     *
     C                   if        first = *off
     C                   exsr      zzinz
     C                   eval      first = *on
     C                   endif
     *  Process pirtran
     *
     C                   dou       forever<>forever
     C                   clear                   oqrec
     *  Employee selection
     *
     C                   if        emp#<>0
     C                   read(n)   pirtran2
     *
     C                   if        not %EOF(pirtran2) and ptemp#=emp#
     C                                                and ptsdte>=frmdte
     C                                                and ptsdte<=enddte
     *
530bAC                   if        ptpcs = 0
530bAC                   if        pttask = 'REPL  '
530bAC                             or pttask = 'REPLTF'
530bAC                             or pttask = 'REPLRP'
710 AC                             or pttask = 'REPLPD'
530bAC                   iter
530bAC                   endif
530bAC                   endif
     *  date/time range
     C                   select
     C                   when      enddte = frmdte
     C                   if        ptsdte = frmdte   and
     C                             ptstim >= frmtim   and
     C                             ptstim <= endtim
     C                   if        ptgrp1 = ' ' or pttask = 'IDLE'
     C                   exsr      zzgettsk
     C                   write     oqrec
     C                   else
     C                   exsr      zzgetlbl
     C                   endif
     C                   endif
     C                   when      enddte <> frmdte
     C                   if        ptsdte = frmdte   and
     C                             ptstim >= frmtim   or
     C                             ptsdte = enddte   and
     C                             ptstim <= endtim   or
     C                             ptsdte > frmdte   and
     C                             ptsdte < enddte    or
     C                             ptsdte = enddte   and
     C                             ptstim <= endtim
     C                   if        ptgrp1 = ' ' or pttask = 'IDLE'
     C                   exsr      zzgettsk
     C                   write     oqrec
     C                   else
     C                   exsr      zzgetlbl
     C                   endif
     C                   endif
     C                   endsl
     C                   else
     C                   if        $pvyn = 'Y'
     C                   exsr      zzupdemp
     C                   endif
     C                   leave
     C                   endif
     C                   endif
     *  Crew selection
     *
     C                   if        $pcrew<>*blanks
     C                   read(n)   pirtran7
     *
     C                   if        not %EOF(pirtran7) and ptcrew=$pcrew
     C                                                and ptsdte>=frmdte
     C                                                and ptsdte<=enddte
     *
530bAC                   if        ptpcs = 0
530bAC                   if        pttask = 'REPL  '
530bAC                             or pttask = 'REPLTF'
530bAC                             or pttask = 'REPLRP'
710 AC                             or pttask = 'REPLPD'
530bAC                   iter
530bAC                   endif
530bAC                   endif
     * date/time range
     C                   select
     C                   when      enddte = frmdte
     C                   if        ptsdte = frmdte   and
     C                             ptstim >= frmtim   and
     C                             ptstim <= endtim
     C                   if        ptgrp1 = ' ' or pttask = 'IDLE'
     C                   exsr      zzgettsk
     C                   write     oqrec
     C                   else
     C                   exsr      zzgetlbl
     C                   endif
     C                   endif
     C                   when      enddte <> frmdte
     C                   if        ptsdte = frmdte   and
     C                             ptstim >= frmtim   or
     C                             ptsdte = enddte   and
     C                             ptstim <= endtim   or
     C                             ptsdte > frmdte   and
     C                             ptsdte < enddte    or
     C                             ptsdte = enddte   and
     C                             ptstim <= endtim
     C                   if        ptgrp1 = ' ' or pttask = 'IDLE'
     C                   exsr      zzgettsk
     C                   write     oqrec
     C                   else
     C                   exsr      zzgetlbl
     C                   endif
     C                   endif
     C                   endsl
     C                   else
     C                   if        $pvyn = 'Y'
     C                   exsr      zzupdcrew
     C                   endif
     C                   leave
     C                   endif
     C                   endif
     C                   enddo
     *
     C                   eval      *INLR=*on
     C                   return
     *****************************************************************
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     C                   eval      first = *off
     C                   eval      forever = *on
     *
640aA*  Get client
640aAC                   call      @getcl
640aAC                   parm                    client           10
640aA*
     C                   eval      whdp = *blanks
     * SHIFT
     C     shkey1        klist
     C                   kfld                    shft
     C                   kfld                    whdp
     C                   kfld                    whse
     * CREW
     C     crkey         klist
     C                   kfld                    whse
     C                   kfld                    $pcrew
     * TASK
     C     tkkey         klist
     C                   kfld                    pttask
     * PIRTRAN2
     C     pt2key1       klist
     C                   kfld                    emp#
     *
     C     pt2key2       klist
     C                   kfld                    emp#
     C                   kfld                    enddte
     *
     C     pt2key3       klist
     C                   kfld                    emp#
     C                   kfld                    enddte
     C                   kfld                    endtim
     *
     * PIRTRAN7
     C     pt7key1       klist
     C                   kfld                    $pcrew
     *
     C     pt7key2       klist
     C                   kfld                    $pcrew
     C                   kfld                    enddte
     *
     C     pt7key3       klist
     C                   kfld                    $pcrew
     C                   kfld                    enddte
     C                   kfld                    endtim
     *
     * LABEL90
     C     lb90key       klist
     C                   kfld                    ptwhse
     C                   kfld                    pttrn#
     C     lb90key2      klist
     C                   kfld                    lbowhse
     C                   kfld                    lbotrn#
     C                   kfld                    lbolbl#
     * LABELdo
     C     lbdokey       klist
     C                   kfld                    lblbl#
     C                   kfld                    lbtrn#
     * LABELdo2
     C     lbdokey2      klist
     C                   kfld                    emp#
     C                   kfld                    $fdtetme
     * LABELdo3
     C     lbdokey3      klist
     C                   kfld                    $pcrew
     C                   kfld                    $fdtetme
     * PASSTRAN
     C     passkey       klist
     C                   kfld                    lboemp#
     C                   kfld                    lbotrn#
CLDaA* Item Link & Item Fields
CLDaAC     ilkey         klist
CLDaAC                   kfld                    lbwhse
CLDaAC                   kfld                    lbitem
CLDaA* Item Link-base item
CLDaAC     ilkey2        klist
CLDaAC                   kfld                    ilwhse
CLDaAC                   kfld                    ilitm2
CLDaA*
     C                   endsr
CLDaA*----------------------------------------------------------------
CLDaA* zzcld: grab FAB quantity breakdown
CLDaA*----------------------------------------------------------------
     *
CLDaAC     zzcld         begsr
     C     ilkey         chain     itemlnk
     C                   if        %found(itemlnk)
     C     ilkey2        chain     itemfld
     C                   if        %found(itemfld) and
     C                             ifcat='FAB       '
     C     ilkey2        chain(n)  piritem
     C                   if        %found(piritem)
     C                   if        lbqpck <= itumQ2 and itumq2 >0
     C                   z-add     1             lbqpck
     C                   else
     C                   if        lbqpck > itumQ2 and itumq2 >0
     C                   eval      lbqpck = lbqpck/itumq2
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
CLDaAC                   endsr
     *
     *----------------------------------------------------------------
     *
     C     zzinz         begsr
     C                   exsr      zzshift
     C                   select
     C                   when      emp#<>0
     C     pt2key3       setll     pirtran2
     C                   when      $pcrew<>*blanks
     C     pt7key3       setll     pirtran7
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *  zzshift:  if no time range, get shift range
     C     zzshift       begsr
     *
     *  If time not entered, get shift time range.
     *
     C                   select
     *
     *  Employee selection, get time range
     C                   when      emp# <> 0
     C     emp#          chain     piruser1
     C                   if        %found(piruser1)
     C                   eval      shft=usshft
     C                   eval      whdp=uswhdp
     C                   endif
     C                   if        frmtim = 0  and
     C                             endtim = 0
     C     shkey1        chain     shift1
     C                   if        %found(shift1)
     C                   eval      frmtim = shstim
     C                   eval      endtim = shetim
     C                   else
     C                   eval      whdp = *blanks
     C     shkey1        chain     shift1
     C                   if        %found(shift1)
     C                   eval      frmtim = shstim
     C                   eval      endtim = shetim
     C                   else
     C                   eval      frmtim = *zeros
     C                   eval      endtim = *zeros
     C                   endif
     C                   endif
     C                   endif
     *
     *  Crew selection, get time range
     *
     C                   when      $pcrew <> *blanks
     C     crkey         chain     crew
     C                   if        %found(crew)
     C                   eval      shft=crshft
     C                   else
     C                   eval      shft=crshft
     C                   endif
     C                   if        frmtim = 0  and
     C                             endtim = 0
     C     shkey1        chain     shift1
     C                   if        %found(shift1)
     C                   eval      frmtim = shstim
     C                   eval      endtim = shetim
     C                   else
     C                   eval      whdp = *blanks
     C     shkey1        chain     shift1
     C                   if        %found(shift1)
     C                   eval      frmtim = shstim
     C                   eval      endtim = shetim
     C                   else
     C                   eval      frmtim = *zeros
     C                   eval      endtim = *zeros
     C                   endif
     C                   endif
     C                   endif
     C                   endsl
     C                   endsr
     *
     *----------------------------------------------------------------
     * zzgetlbl:  get label date for work file
     *----------------------------------------------------------------
     *
     C     zzgetlbl      begsr
     C     lb90key       setll     label90
     C                   dow       forever = forever
     C                   read      label90
     C                   if        not %EOF(LABEL90) and pttrn#=lbtrn#
CSPaAc                   if        client = CoastalSunbelt
CSPaAc                   if        lbitem = 'BOX05          ' or
CSPaAc                             lbitem = 'BOX06          ' or
CSPaAc                             lbitem = 'BOX11          '
CSPaAc                   iter
CSPaAc                   endif
CSPaAc                   endif
     C                   if        lbtype <> 'M' or
     C                             lbtype = 'M' and $pmrg='Y'
     C                   if        $pcrew <> *blanks
     C     ptemp#        chain     piruser1
     C                   if        not %found(piruser1)
     C                   eval      uslnam=*blanks
     C                   eval      usfnam=*blanks
     C                   endif
     C                   endif
     C                   if        lbgrp1 = 'S' and lbtype<>'F'
     C                             and lbtype <> 'B' and lbtype<>'P'
     C                   eval      lbtype = 'F'
     C                   endif
CLDaAC                   if        client=cityln
CLDaAC                   exsr      zzcld
CLDaAC                   endif
     C                   if        $PVYN='Y'
     C     lbdokey       chain     labeldo
     C                   if        %found(labeldo)
     C                   if        emp#<>0 and lboemp#=emp#  or
     C                             $pcrew<>*blanks and lbocrew=$pcrew
     C                   eval      lbqshrt=lboqtys
     C                   eval      lbqpck = lboqty
     C                   if        ptemp#=lboemp#
     C     passkey       chain     passtran
     C                   if        %found(passtran)
     C                   eval      ptsdte = passdte
     C                   eval      ptstim = passtim
     C                   eval      ptedte = pasedte
     C                   eval      ptetim = pasetim
     C                   eval      ptdmin = pasdmin
     C                   endif
     C                   exsr      zzgettsk
     C                   write     oqrec
     C                   endif
     C                   endif
     C                   else
     C                   eval      lbqshrt=lbqalc-lbqpck
     C                   exsr      zzgettsk
     C                   write     oqrec
     C                   endif
     C                   else
     C                   eval      lbqshrt=lbqalc-lbqpck
     C                   exsr      zzgettsk
     C                   write     oqrec
     C                   endif
     C                   endif
     C                   else
     C                   leave
     C                   endif
     C                   enddo
     C                   endsr
     *
     *----------------------------------------------------------------
     * zzgettsk: grab task detail
     *----------------------------------------------------------------
     *
     C     zzgettsk      begsr
     C     tkkey         chain     task
     C                   if        not %found(task)
     C                   eval      tktype = ' '
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     * zzstamp:  setup date stamp for chain
     *----------------------------------------------------------------
     *
     C     zzstamp       begsr
     C                   eval      fdtetme=%subst($pfmdt:1:4) + '-' +
     C                             %subst($pfmdt:5:2) + '-' +
     C                             %subst($pfmdt:7:2) + '-' +
     C                             %subst($pftim:1:2) + '.' +
     C                             %subst($pftim:3:2) + '.' +
     C                             %subst($pftim:5:2) + '.000000'
     C                   eval      tdtetme=%subst($pendt:1:4) + '-' +
     C                             %subst($pendt:5:2) + '-' +
     C                             %subst($pendt:7:2) + '-' +
     C                             %subst($petim:1:2) + '.' +
     C                             %subst($petim:3:2) + '.00.999999'
     C                   move      tdtetme       $tdtetme
     C                   move      fdtetme       $fdtetme
     C                   endsr
     *
     *----------------------------------------------------------------
     * zzupdemp: grab any drop
     *----------------------------------------------------------------
     *
     C     zzupdemp      begsr
     C                   exsr      zzstamp
     C     lbdokey2      setll     labeldo2
     C                   dow       forever = forever
     C                   read(n)   labeldo2
     C                   if        not %EOF(labeldo2) and
     C                             lboaddts>=$fdtetme and
     C                             lboaddts<=$tdtetme and
     C                             lboemp#=emp#
     C                   if        svlbl#<>lbolbl#
     C     lbotrn#       chain     pirtran
     C                   if        %found(pirtran)
     C                   if        ptemp#<>emp#
     C                   eval      lbqshrt=lboqtys
     C                   eval      lbqpck = lboqty
     C                   eval      ptemp# = lboemp#
     C     passkey       chain     passtran
     C                   if        %found(passtran)
     C                   eval      ptsdte = passdte
     C                   eval      ptstim = passtim
     C                   eval      ptedte = pasedte
     C                   eval      ptetim = pasetim
     C                   eval      ptdmin = pasdmin
     C     lb90key2      chain     label90
     C                   if        %found(label90)
     C     ptemp#        chain     piruser1
     C                   if        not %found(piruser1)
     C                   eval      uslnam=*blanks
     C                   eval      usfnam=*blanks
     C                   endif
     C                   exsr      zzgettsk
     C                   write     oqrec
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   else
     C                   leave
     C                   endif
     C                   eval      svlbl#=lbolbl#
     C                   enddo
     C                   endsr
     *
     *
     *----------------------------------------------------------------
     * zzupdcrew: grab any drop
     *----------------------------------------------------------------
     *
     C     zzupdcrew     begsr
     C                   exsr      zzstamp
     C     lbdokey3      setll     labeldo3
     C                   dow       forever = forever
     C                   read(n)   labeldo3
530aDC*****              if        not %EOF(labeldo2) and
530aMC                   if        not %EOF(labeldo3) and
     C                             lboaddts>=$fdtetme and
     C                             lboaddts<=$tdtetme and
     C                             lbocrew=$pcrew
     C                   if        svlbl#<>lbolbl#
     C     lbotrn#       chain     pirtran
     C                   if        %found(pirtran)
     C                   if        ptemp#<>lboemp#
     C                   eval      lbqshrt=lboqtys
     C                   eval      lbqpck = lboqty
     C                   eval      ptemp# = lboemp#
     C     passkey       chain     passtran
     C                   if        %found(passtran)
     C                   eval      ptsdte = passdte
     C                   eval      ptstim = passtim
     C                   eval      ptedte = pasedte
     C                   eval      ptetim = pasetim
     C                   eval      ptdmin = pasdmin
     C     lb90key2      chain     label90
     C                   if        %found(label90)
     C     ptemp#        chain     piruser1
     C                   if        not %found(piruser1)
     C                   eval      uslnam=*blanks
     C                   eval      usfnam=*blanks
     C                   endif
     C                   exsr      zzgettsk
     C                   write     oqrec
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   else
     C                   leave
     C                   endif
     C                   eval      svlbl#=lbolbl#
     C                   enddo
     C                   endsr
     *
