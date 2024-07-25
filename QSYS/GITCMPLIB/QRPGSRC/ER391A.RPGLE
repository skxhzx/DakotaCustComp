      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ER391A    Task Summary by Crew - Process
     *  Ginger Andrews
     *  08 December, 2009
     *
     *  Revisions
     *
     *    12/08/09  GJA  5.30
     *      - Created
     *
530a *    03/31/10  GJA  5.30a
     *      - Enh:  Add loader information
     *        Fix:  Validate that crew was entered
640a *    02/06/11  GJA  6.40a
     *      - Fix:  Add loader direct time
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Not on file/End of file indicator
     *  90        Overflow Indicator
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fer391     ip   e           k disk
     Fshift1    if   e           k disk
     Ftask      if   e           k disk
     Fpiruser1  if   e           k disk
     Fer391a    o  a e           k disk
     *****************************************************************
     *----------------------------------------------------------------
     *  Called programs
     *
     D @multi          c                   const('CHKMULTI')
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
     D enddte          s              8  0
     D endtim          s              6  0
     D first           s              1
     D forevr          s              1
     D frmdte          s              8  0
     D frmtim          s              6  0
     D svdisp          s                   like(lbdisp)
     D svdsp2          s                   like(lbdsp2)
     D svitem          s                   like(lbitem)
     D svtask          s                   like(pttask)
     D svtrn#          s                   like(lbtrn#)
     D whdp            s              5
     D w1bulk          s                   like(wkbulk)
     D w1bulkm         s                   like(dmins)
     D w1bulks         s                   like(dsecs)
     D w1bulkp         s                   like(wkbulkp)
     D w1eqck          s                   like(wkeqck)
     D w1eqckm         s                   like(dmins)
     D w1eqcks         s                   like(dsecs)
     D w1fix           s                   like(wkfix)
     D w1fixp          s                   like(wkfixp)
     D w1fixm          s                   like(dmins)
     D w1fixs          s                   like(dsecs)
     D w1idle          s                   like(wkidle)
     D w1idles         s                   like(dsecs)
     D w1idlem         s                   like(dmins)
     D w1ind           s                   like(wkind)
     D w1inds          s                   like(dsecs)
     D w1indm          s                   like(dmins)
     D w1pir           s                   like(wkpir)
     D w1pirp          s                   like(wkpirp)
     D w1pirm          s                   like(dmins)
     D w1pirs          s                   like(dsecs)
     D w1put           s                   like(wkput)
     D w1putp          s                   like(wkputp)
     D w1putm          s                   like(dmins)
     D w1puts          s                   like(dsecs)
     D w1recv          s                   like(wkrecv)
     D w1recvp         s                   like(wkrecvp)
     D w1recvm         s                   like(dmins)
     D w1recvs         s                   like(dsecs)
     D w1repl          s                   like(wkrepl)
     D w1replp         s                   like(wkreplp)
     D w1replm         s                   like(dmins)
     D w1repls         s                   like(dsecs)
     D w1run           s                   like(wkrun)
     D w1runp          s                   like(wkrunp)
530aAD w1load          s                   like(wkload)
530aAD w1loadp         s                   like(wkloadp)
530aAD w1loadm         s                   like(dmins)
530aAD w1loads         s                   like(dsecs)
     D w1prtn          s                   like(wkprtn)
     D w1prtnp         s                   like(wkprtnp)
     D w1prtnm         s                   like(dmins)
     D w1prtns         s                   like(dsecs)
     D w1strn          s                   like(wkstrn)
     D w1tfr           s                   like(wktfr)
     D w1tfrp          s                   like(wktfrp)
     D w1tfrm          s                   like(dmins)
     D w1tfrs          s                   like(dsecs)
     D w1vrfy          s                   like(wkvrfy)
     D w1vrfyp         s                   like(wkvrfyp)
     D w1vrfym         s                   like(dmins)
     D w1vrfys         s                   like(dsecs)
     D w1lnam          s                   like(wklnam)
     D w1fnam          s                   like(wkfnam)
     D w2dmin          s              5  0
     D w2dsec          s              5  0
     D $tdtetme        s               z
     D $fdtetme        s               z
     D wksdtec         s              8
     D wkedtec         s              8
     D wkstimc         s              6
     D wketimc         s              6
     D tdtetme         s             26
     D fdtetme         s             26
     D dhrs            s              7  2
     D ihrs            s              7  2
     D dmins           s              7  0
     D dsecs           s              7  0
     D w1dmi           s              5  0
     *----------------------------------------------------------------
     Ioqrec
     I                                          ptemp#        l2
     I                                          pttrn#        l1
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
     *
     C     *entry        plist
     C                   parm                    $pfmdt            8
     C                   parm                    $pendt            8
     C                   parm                    $pbtim            6
     C                   parm                    $petim            6
     C                   parm                    $pmrg             1
     *
     *  Main line
     *
     C                   if        first = *off
     C                   exsr      zzinz
     C                   eval      first = *on
     C                   endif
     *
     C                   if        lbtype = 'M' and $pmrg = 'N'
     C                   goto      skip
     C                   endif
     *
     C                   if        lbgrp1 = 'S'  and
     C                             lbstyp <> 'F'  and
     C                             lbstyp <> 'P'
     C                   eval      lbstyp = 'F'
     C                   endif
     *
     *  Skip records, if not within Shift's time range.
     *
     C                   if        frmtim = 0  and
     C                             endtim = 0
     *
     C                   if        shstim > 0
     *
     C                   if        ptsdte = frmdte  and
     C                             ptstim < shstim
     C                   goto      skip
     C                   endif
     *
     C                   if        ptsdte = enddte  and
     C                             ptstim > shetim
     C                   goto      skip
     C                   endif
     *
     C                   endif
     *
     C                   endif
     *
     *  Bulk Picks
     C                   if        lbtype = 'B'  and
     C                             pttask <> 'IDLE  '
     C                   add       1             w1bulk
     C                   exsr      zzstamp
     C                   add       w2dmin        w1bulkm
     C                   add       w2dsec        w1bulks
     C                   add       lbqpck        w1bulkp
     C                   endif
     *
     C                   select
     *  Runner time
     C                   when      pttask = 'RUNNER'
     C                   exsr      zzstamp
     C                   add       ptpcs         w1runp
     C                   add       1             w1run
     *  Idle time
     C                   when      pttask = 'IDLE  '
     C                   exsr      zzstamp
     C                   add       1             w1idle
     C                   add       w2dmin        w1idlem
     C                   add       w2dsec        w1idles
     *  Equipment checkin/out
     C                   when      pttask = 'EQCHK '
     C                   add       1             w1eqck
     C                   exsr      zzstamp
     C                   add       w2dmin        w1eqckm
     C                   add       w2dsec        w1eqcks
530aA*  Loader
530aAC                   when      pttask = 'LOAD  '
530aAC                   add       1             w1load
530aAC                   exsr      zzstamp
530aAC                   add       w2dmin        w1loadm
530aAC                   add       w2dsec        w1loads
530aAC                   add       ptpcs         w1loadp
     *  Verify
     C                   when      pttask = 'VERIFY'
     C                   add       1             w1vrfy
     C                   exsr      zzstamp
     C                   add       w2dmin        w1vrfym
     C                   add       w2dsec        w1vrfys
     C                   add       ptpcs         w1vrfyp
     *  Put-away
     C                   when      lbtype = 'P'  and
     C                             lbgrp1 = 'P'  and
     C                             pttask <> 'IDLE  '
     C                   if        lbtrn# <> svtrn#  or
     C                             lbdisp <> svdisp
     C                   add       1             w1put
     C                   exsr      zzstamp
     C                   add       w2dmin        w1putm
     C                   add       w2dsec        w1puts
     C                   add       lbqpck        w1putp
     C                   endif
     *  Customer returns put-away
     C                   when      lbtype = 'P'  and
     C                             lbgrp1 = 'R'  and
     C                             pttask <> 'IDLE  '
     C                   if        lbtrn# <> svtrn#  or
     C                             lbdisp <> svdisp
     C                   add       1             w1prtn
     C                   exsr      zzstamp
     C                   add       w2dmin        w1prtnm
     C                   add       w2dsec        w1prtns
     C                   add       lbqpck        w1prtnp
     C                   endif
     *
     *  Replenishment transfers
     C                   when      lbtype = 'R'  and
     C                             lbgrp1 = 'L'  and
     C                             pttask = 'REPLTF'
     C                   if        lbtrn# <> svtrn#
     C                   if        lbdisp = svdisp  and
     C                             lbdsp2 = svdsp2  and
     C                             lbitem = svitem  and
     C                             svtask = 'REPLTF'
     C                   else
     C                   if        ptpcs > 0
     C                   add       1             w1repl
     C                   endif
     C                   exsr      zzstamp
     C                   add       w2dmin        w1replm
     C                   add       w2dsec        w1repls
     C                   add       lbqpck        w1replp
     C                   endif
     C                   endif
     *
     *  Replenishment
     C                   when      lbtype = 'R'  and
     C                             lbgrp1 = 'L'  and
     C                             pttask <> 'IDLE  '
     C                   if        lbtrn# <> svtrn#  or
     C                             lbdisp <> svdisp
     C                   if        ptpcs > 0
     C                   add       1             w1repl
     C                   endif
     C                   exsr      zzstamp
     C                   add       w2dmin        w1replm
     C                   add       w2dsec        w1repls
     C                   add       lbqpck        w1replp
     C                   endif
     *  Transfer
     C                   when      lbtype = 'T'  and
     C                             lbgrp2 = 'A'  and
     C                             pttask <> 'IDLE  '
     C                   if        lbtrn# <> svtrn#  or
     C                             lbdisp <> svdisp
     C                   if        ptpcs > 0
     C                   add       1             w1tfr
     C                   endif
     C                   exsr      zzstamp
     C                   add       w2dmin        w1tfrm
     C                   add       w2dsec        w1tfrs
     C                   add       lbqpck        w1tfrp
     C                   endif
     *  Fix - Selection
     C                   when      lbgrp1 = 'S'  and
     C                             lbstyp = 'F'  and
     C                             lbtype <> 'B'  and
     C                             pttask <> 'IDLE  '
     C                   add       lbqpck        w1fixp
     C                   if        lbtrn# <> svtrn#
     C                   add       1             w1fix
     C                   exsr      zzstamp
     C                   add       w2dmin        w1fixm
     C                   add       w2dsec        w1fixs
     C                   endif
     *  PIR - Selection
     C                   when      lbgrp1 = 'S'  and
     C                             lbstyp = 'P'  and
     C                             lbtype <> 'B'  and
     C                             pttask <> 'IDLE  '
     C                   add       lbqpck        w1pirp
     C                   if        lbtrn# <> svtrn#
     C                   add       1             w1pir
     C                   exsr      zzstamp
     C                   add       w2dmin        w1pirm
     C                   add       w2dsec        w1pirs
     C                   endif
     *  Indirect time
     C                   when      tktype = 'I'
     C                   add       1             w1ind
     C                   exsr      zzstamp
     C                   add       w2dmin        w1indm
     C                   add       w2dsec        w1inds
     C                   endsl
     *
     C                   eval      svtrn# = lbtrn#
     C                   eval      svdisp = lbdisp
     C                   eval      svdsp2 = lbdsp2
     C                   eval      svitem = lbitem
     C                   eval      svtask = pttask
     *
     C     skip          tag
     *
     *****************************************************************
     *
     CL1                 if        ptgrp1 = 'S'  and
     C                             pttask <> 'IDLE  '
     CL1                 add       1             w1strn
     CL1                 endif
     *
     CL2                 exsr      zzupd
     CL2                 exsr      zzzero
     CLr                 return
     *****************************************************************
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     C                   eval      first = *off
     C                   eval      forevr = *off
     C                   eval      svtrn# = 0
     C                   eval      svdisp = *blanks
     C                   eval      svdsp2 = *blanks
     C                   eval      svitem = *blanks
     C                   eval      svtask = *blanks
     *
     C                   eval      whdp = *blanks
     *
     C     shkey1        klist
     C                   kfld                    ptshft
     C                   kfld                    whdp
     C                   kfld                    ptwhse
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zzinz         begsr
     *
     C                   move      $pfmdt        frmdte
     C                   move      $pendt        enddte
     C                   move      $pbtim        frmtim
     C                   move      $petim        endtim
     *
     C     shkey1        chain     shift1                             79
     C                   if        *in79
     C                   eval      shstim = 0
     C                   eval      shetim = 0
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     * zzstamp:  setup date stamp for chain
     *----------------------------------------------------------------
     *
     C     zzstamp       begsr
     *
     *     Get task type
     *
     C     pttask        chain     task                               79
     C                   if        *in79
     C                   eval      tktype = *blank
     C                   endif
     C                   if        ptedte<>0
     C                   move      ptsdte        wksdtec
     C                   move      ptedte        wkedtec
     C                   move      ptstim        wkstimc
     C                   move      ptetim        wketimc
     C                   eval      fdtetme=%subst(wksdtec:1:4) + '-' +
     C                             %subst(wksdtec:5:2) + '-' +
     C                             %subst(wksdtec:7:2) + '-' +
     C                             %subst(wkstimc:1:2) + '.' +
     C                             %subst(wkstimc:3:2) + '.'   +
     C                             %subst(wkstimc:5:2) + '.000000'
     C                   eval      tdtetme=%subst(wkedtec:1:4) + '-' +
     C                             %subst(wkedtec:5:2) + '-' +
     C                             %subst(wkedtec:7:2) + '-' +
     C                             %subst(wketimc:1:2) + '.' +
     C                             %subst(wketimc:3:2) + '.' +
     C                             %subst(wketimc:5:2) + '.000000'
     C                   move      tdtetme       $tdtetme
     C                   move      fdtetme       $fdtetme
     C     $tdtetme      subdur    $fdtetme      dmins:*mn
     C     $tdtetme      subdur    $fdtetme      dsecs:*s
     C     dsecs         div       60            w2dmin
     C                   mvr                     w2dsec
     C                   if        tktype <> 'I' and pttask <> 'IDLE  '
     * check if transaction has other transaction during the same time
     C                   eval      $pmin = 0
     C                   eval      $psec = 0
     C                   eval      $pmucnt = 0
     C                   call      @multi
     C                   parm                    ptwhse
     C                   parm                    ptemp#
     C                   parm                    pttrn#
     C                   parm                    ptsdte
     C                   parm                    ptstim
     C                   parm                    ptedte
     C                   parm                    ptetim
     C                   parm                    $pmsg             4
     C                   parm                    $pmin             5 0
     C                   parm                    $psec             5 0
     C                   parm                    $pmucnt           5 0
     C                   if        $Psec <>0 or $Pmin<>0
     C                   if        w2dmin > $pmin
     C                   sub       $pmin         w2dmin
     C                   if        w2dsec > $psec
     C                   sub       $psec         w2dsec
     C                   else
     C                   sub       1             w2dmin
     C                   add       60            w2dsec
     C                   sub       $psec         w2dsec
     C                   endif
     C                   endif
     C                   endif
     C                   if        w2dmin <> 0 and $pmucnt <> 0
530aMC     w2dmin        div       $pmucnt       w2dmin
     C                   endif
     C                   if        w2dsec <> 0 and $pmucnt <> 0
530aMC     w2dsec        div       $pmucnt       w2dsec
     C                   endif
     C                   endif
     C                   else
     C                   eval      w2dmin=0
     C                   eval      w2dsec=0
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zzupd         begsr
     *
     C                   if        ptemp# > 0
     C                   clear                   wkrec
     C     ptemp#        chain     piruser1
     C                   if        %found(piruser1)
     C                   eval      wklnam = uslnam
     C                   eval      wkfnam = usfnam
     C                   else
     C                   eval      wklnam = *blanks
     C                   eval      wkfnam = *blanks
     C                   endif
     C                   eval      wkemp# = ptemp#
     C                   eval      wkrun = w1run
     C                   eval      wkrunp = w1runp
     C                   eval      wkput = w1put
     C                   eval      wkputp = w1putp
     C     w1puts        div(h)    60            w1dmi
     C     w1dmi         add       w1putm        dmins
     C     dmins         div(h)    60            wkputh
     C                   eval      wkrepl = w1repl
     C                   eval      wkreplp = w1replp
     C     w1repls       div(h)    60            w1dmi
     C     w1dmi         add       w1replm       dmins
     C     dmins         div(h)    60            wkreplh
     C                   eval      wktfr = w1tfr
     C                   eval      wktfrp = w1tfrp
     C     w1tfrs        div(h)    60            w1dmi
     C     w1dmi         add       w1tfrm        dmins
     C     dmins         div(h)    60            wktfrh
     C                   eval      wkvrfy = w1vrfy
     C                   eval      wkvrfyp = w1vrfyp
     C     w1vrfys       div(h)    60            w1dmi
     C     w1dmi         add       w1vrfym       dmins
     C     dmins         div(h)    60            wkvrfyh
640aAC                   eval      wkload = w1load
640aAC                   eval      wkloadp = w1loadp
640aAC     w1loads       div(h)    60            w1dmi
640aAC     w1dmi         add       w1loadm       dmins
640aAC     dmins         div(h)    60            wkloadh
     C                   eval      wkfix = w1fix
     C                   eval      wkfixp = w1fixp
     C     w1fixs        div(h)    60            w1dmi
     C     w1dmi         add       w1fixm        dmins
     C     dmins         div(h)    60            wkfixh
     C                   eval      wkpir = w1pir
     C                   eval      wkpirp = w1pirp
     C     w1pirs        div(h)    60            w1dmi
     C     w1dmi         add       w1pirm        dmins
     C     dmins         div(h)    60            wkpirh
     * PRTN
     C                   eval      wkprtn = w1prtn
     C                   eval      wkprtnp = w1prtnp
     C     w1prtns       div(h)    60            w1dmi
     C     w1dmi         add       w1prtnm       dmins
     C     dmins         div(h)    60            wkprtnh
     * EQCK
     C                   eval      wkeqck = w1eqck
     C     w1eqcks       div(h)    60            w1dmi
     C     w1dmi         add       w1eqckm       dmins
     C     dmins         div(h)    60            wkeqckh
     * BULK
     C                   eval      wkbulk = w1bulk
     C                   eval      wkbulkp = w1bulkp
     C     w1bulks       div(h)    60            w1dmi
     C     w1dmi         add       w1bulkm       dmins
     C     dmins         div(h)    60            wkbulkh
     * IDLE hours
     C                   eval      wkidle = w1idle
     C     w1idles       div(h)    60            w1dmi
     C     w1dmi         add       w1idlem       dmins
     C     dmins         div(h)    60            wkidleH
     * Indirect hours
     C                   eval      wkind = w1ind
     C     w1inds        div(h)    60            w1dmi
     C     w1dmi         add       w1indm        dmins
     C     dmins         div(h)    60            wkindH
     C                   eval      wkstrn = w1strn
     C                   write     wkrec
     C                   endif
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     C     zzzero        begsr
     C                   eval      w1recv = 0
     C                   eval      w1recvp = 0
     C                   eval      w1recvm = 0
     C                   eval      w1recvs = 0
     C                   eval      w1run = 0
     C                   eval      w1runp = 0
     C                   eval      w1put = 0
     C                   eval      w1putp = 0
     C                   eval      w1putm = 0
     C                   eval      w1puts = 0
     C                   eval      w1repl = 0
     C                   eval      w1replp = 0
     C                   eval      w1replm = 0
     C                   eval      w1repls = 0
     C                   eval      w1tfr = 0
     C                   eval      w1tfrp = 0
     C                   eval      w1tfrm = 0
     C                   eval      w1tfrs = 0
     C                   eval      w1vrfy = 0
     C                   eval      w1vrfyp = 0
     C                   eval      w1vrfym = 0
     C                   eval      w1vrfys = 0
640aAC                   eval      w1load = 0
640aAC                   eval      w1loadp = 0
640aAC                   eval      w1loadm = 0
640aAC                   eval      w1loads = 0
     C                   eval      w1fix = 0
     C                   eval      w1fixp = 0
     C                   eval      w1fixm = 0
     C                   eval      w1fixs = 0
     C                   eval      w1pir = 0
     C                   eval      w1pirp = 0
     C                   eval      w1pirm = 0
     C                   eval      w1pirs = 0
     C                   eval      w1idle = 0
     C                   eval      w1idlem = 0
     C                   eval      w1idles = 0
     C                   eval      w1ind = 0
     C                   eval      w1indm = 0
     C                   eval      w1inds = 0
     C                   eval      w1prtn = 0
     C                   eval      w1prtnp = 0
     C                   eval      w1prtnm = 0
     C                   eval      w1prtns = 0
     C                   eval      w1eqck = 0
     C                   eval      w1eqckm = 0
     C                   eval      w1eqcks = 0
     C                   eval      w1bulk = 0
     C                   eval      w1bulkp = 0
     C                   eval      w1bulkm = 0
     C                   eval      w1bulks = 0
     C                   eval      w1strn = 0
     C                   endsr
