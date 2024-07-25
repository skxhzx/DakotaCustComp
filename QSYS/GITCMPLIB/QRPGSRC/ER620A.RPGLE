      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ER620A     Create Work file
     *  Ginger Andrews
     *  01 September, 2009
     *
     *  Revisions
     *
     *    09/01/09  GJA  5.30
     *      - Created
     *
530a *    07/13/10  GJA  5.30a
     *      - Fix:  EOF statement was incorrect
     *
     *
640a *    11/28/11  GJA  6.40a
     *      - Fix:  Multiple passtran records for a crew
     *
640b *    10/18/12  LMC  6.40b
     *      ITEMFLD database change - requires recompile.
     *
     *----------------------------------------------------------------
     *  Custom Client Revisions-City Line
CLDa *    10/01/09  GJA  CLDa
     *      - Enh:  incorporate FAB quantity adjustments -------------
     *----------------------------------------------------------------
     *  Custom Client Revisions-Coastal
     *
CSPa *    05/12/11  GJA  CSPa
     *      - Enh:  Omit items BOX05, BOX06, BOX11
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
     Fer620a    o  a e           k disk
CLDaAFpiritem   if   e           k disk
CLDaAFitemfld   if   e           k disk
CLDaAFitemlnk   if   e           k disk
     *****************************************************************
     *----------------------------------------------------------------
     *  Client
     *
CLDaA /COPY QCOPYSRC,ID#CITYLIN
CSPaA /COPY QCOPYSRC,ID#COASTAL
     *----------------------------------------------------------------
     *  Called programs
     *
CLDaAD @getcl          c                   const('GETCLIENT')
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
     *      $PFMDT  From date (YYYYMMDD)
     *      $PENDT  To date (YYYYMMDD)
     *      $PWHSE  Warehouse code
     *      $PEMP#  Employee number
     *      $PCREW  Crew name
     *      $PMRG   Include merge (Y,N)
     *      $PFMTM  From time (HHMMSS)
     *      $PTOTM  To time (HHMMSS)
     *      $PVYN   Voice Module (Y,N)
     *      None
     *
     *----------------------------------------------------------------
     C     *entry        plist
     C                   parm                    $pfmdt            8
     C                   parm                    $pendt            8
     C                   parm                    $pwhse            3
     C                   parm                    $pemp#            5
     C                   parm                    $pcrew            6
     C                   parm                    $mrg              1
     C                   parm                    $pftim            6
     C                   parm                    $petim            6
     C                   parm                    $pvyn             1
     *
     C                   move      $pfmdt        frmdte
     C                   move      $pendt        enddte
     C                   movel     $pftim        frmtim
     C                   movel     $petim        endtim
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
     C                   dou       forever<>forever
     C                   clear                   oqrec
     *  Employee selection
     C                   if        emp#<>0
     C                   read(n)   pirtran2
     *
     C                   if        not %EOF(pirtran2) and ptemp#=emp#
     C                                                and ptsdte>=frmdte
     C                                                and ptsdte<=enddte
     *  date/time range
     C                   select
     C                   when      enddte = frmdte
     C                   if        ptsdte = frmdte   and
     C                             ptstim >= frmtim   and
     C                             ptstim <= endtim
     C                   if        ptgrp1 = ' ' or pttask = 'IDLE'
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
CLDaA*  Get client
CLDaAC                   call      @getcl
CLDaAC                   parm                    client           10
CLDaA* Item Link & Item Fields
CLDaAC     ilkey         klist
CLDaAC                   kfld                    lbwhse
CLDaAC                   kfld                    lbitem
CLDaA* Item Link-base item
CLDaAC     ilkey2        klist
CLDaAC                   kfld                    ilwhse
CLDaAC                   kfld                    ilitm2
CLDaA *
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
     C                   endsr
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
     C                             lbtype = 'M' and $mrg='Y'
CLDaAC                   if        client=cityln
CLDaAC                   exsr      zzcld
CLDaAC                   endif
     C                   if        $PVYN='Y'
     C     lbdokey       chain     labeldo
     C                   if        %found(labeldo)
     C                   if        emp#<>0 and lboemp#=emp#
     C                   eval      lbqshrt=lboqtys
     C                   eval      lbqpck = lboqty
CLDbAC                   if        client=cityln
CLDbAC                   exsr      zzcld
CLDbAC                   endif
     C                   if        ptemp#=lboemp#
640aDC*    passkey       chain     passtran
640aDC*                  if        %found(passtran)
640aDC*                  eval      ptsdte = passdte
640aDC*                  eval      ptstim = passtim
640aDC*                  eval      ptedte = pasedte
640aDC*                  eval      ptetim = pasetim
640aDC*                  eval      ptdmin = pasdmin
640aDC*                  endif
     C                   write     oqrec
     C                   endif
     C                   endif
     C                   else
     C                   eval      lbqshrt=lbqalc-lbqpck
     C                   write     oqrec
     C                   endif
     C                   else
     C                   eval      lbqshrt=lbqalc-lbqpck
     C                   write     oqrec
     C                   endif
     C                   endif
     C                   else
     C                   leave
     C                   endif
     C                   enddo
     C                   endsr
     *
CLDaA*----------------------------------------------------------------
     * zzcld: grab FAB quantity breakdown
     *----------------------------------------------------------------
     *
     C     zzcld         begsr
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
     C                   endsr
     *
     *----------------------------------------------------------------
     * zzstamp:  setup date stamp for chain
     *----------------------------------------------------------------
     *
     C     zzstamp       begsr
     C                   eval      fdtetme=%subst($pfmdt:1:4) + '-' +
     C                             %subst($pfmdt:5:2) + '-' +
     C                             %subst($pfmdt:7:2) + '-' +
     C                             %subst($pftim:1:2) + '.' +
     C                             %subst($pftim:3:2) + '.00.000000'
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
640aDC*****passkey       chain     passtran
640aDC*****              if        %found(passtran)
640aMC     passkey       setll     passtran
640aAC                   dow       forever = forever
640aAC     passkey       reade     passtran
640aMC                   if        pastrn#=lbotrn# and lboemp#=pasemp#
640aAC                             and not %EOF(PASSTRAN)
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
     C                   write     oqrec
     C                   endif
640aAC                   else
640aAC                   leave
640aAC                   endif
640aAC                   enddo
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
530bDC*****passkey       chain     passtran
530bDC*****              if        %found(passtran)
530bMC     passkey       setll     passtran
530bAC                   dow       forever = forever
530bAC     passkey       reade     passtran
530bMC                   if        pastrn#=lbotrn# and lboemp#=pasemp#
530bAC                             and not %EOF(PASSTRAN)
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
     C                   write     oqrec
     C                   endif
640aAC                   else
640aAC                   leave
     C                   endif
640aAC                   enddo
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
