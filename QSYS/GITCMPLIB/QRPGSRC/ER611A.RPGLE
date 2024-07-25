      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ER611A    View Summary by User - Process
     *  Hemant Kapadia
     *  18 September, 2001
     *
     *  Revisions
     *
     *    09/04/01  HNK  4.16
     *      - Created
     *
     *  06/10/09  GJA  5.30
     *    - Enh: Converted to RPGLE, cleaned up and revamped for
     *                  suspended transaction
     *
530a *  03/31/10  GJA  5.30a
     *    - Fix: Multitran counter was zero and got divide by zero
     *    - Enh: Add loader
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
     Fer611     ip   e           k disk
     Fshift1    if   e           k disk
     Ftask      if   e           k disk
     Fer611a    o  a e           k disk
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
     D w1dmin          s                   like(wkdmin)
     D w1dsec          s                   like(wkdmin)
     D w2dmin          s                   like(wkdmin)
     D w2dsec          s                   like(wkdmin)
     D w1eqck          s                   like(wkeqck)
     D w1fix           s                   like(wkfix)
     D w1idle          s                   like(wkidle)
     D w1idles         s                   like(wkidle)
     D w1imin          s                   like(wkimin)
     D w1pir           s                   like(wkpir)
     D w1put           s                   like(wkput)
530aAD w1load          s                   like(wkload)
     D w1recv          s                   like(wkrecv)
     D w1repl          s                   like(wkrepl)
     D w1rtnp          s                   like(wkrtn)
     D w1run           s                   like(wkrun)
     D w1strn          s                   like(wkstrn)
     D w1tfr           s                   like(wktfr)
     D w1vrfy          s                   like(wkvrfy)
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
     D dmins           s              5  0
     D dsecs           s              7  0
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
     C                   move      $pfmdt        frmdte
     C                   move      $pendt        enddte
     C                   move      $pbtim        frmtim
     C                   move      $petim        endtim
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
     C                   endif
     *
     C                   select
     *  Idle time
     C                   when      pttask = 'IDLE  '
     C                   exsr      zzstamp
     C                   add       w2dmin        w1idle
     C                   add       w2dsec        w1idles
     *  Runner time
     C                   when      pttask = 'RUNNER'
     C                   exsr      zzstamp
     C                   add       1             w1run
     C                   add       w2dmin        w1dmin
     C                   add       w2dsec        w1dsec
     *  Equipment checkin/out
     C                   when      pttask = 'EQCHK '
     C                   add       1             w1eqck
     C                   add       ptimin        w1imin
530aA*  Loader
     C                   when      pttask = 'LOAD  '
     C                   add       1             w1load
     C                   exsr      zzstamp
     C                   add       w2dmin        w1dmin
     C                   add       w2dsec        w1dsec
     *  Put-away
     C                   when      lbtype = 'P'  and
     C                             lbgrp1 = 'P'  and
     C                             pttask <> 'IDLE  '
     C                   if        lbtrn# <> svtrn#  or
     C                             lbdisp <> svdisp
     C                   add       1             w1put
     C                   exsr      zzstamp
     C                   add       w2dmin        w1dmin
     C                   add       w2dsec        w1dsec
     C                   endif
     *  Customer returns put-away
     C                   when      lbtype = 'P'  and
     C                             lbgrp1 = 'R'  and
     C                             pttask <> 'IDLE  '
     C                   if        lbtrn# <> svtrn#  or
     C                             lbdisp <> svdisp
     C                   add       1             w1rtnp
     C                   exsr      zzstamp
     C                   add       w2dmin        w1dmin
     C                   add       w2dsec        w1dsec
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
     C                   add       w2dmin        w1dmin
     C                   add       w2dsec        w1dsec
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
     C                   add       w2dmin        w1dmin
     C                   add       w2dsec        w1dsec
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
     C                   add       w2dmin        w1dmin
     C                   add       w2dsec        w1dsec
     C                   endif
     *  Verify
     C                   when      pttask = 'VERIFY'  and
     C                             pttask <> 'IDLE  '
     C                   add       ptpcs         w1vrfy
     C                   if        lbtrn# <> svtrn#
     C                   exsr      zzstamp
     C                   add       w2dmin        w1dmin
     C                   add       w2dsec        w1dsec
     C                   endif
     *  Fix - Selection
     C                   when      lbgrp1 = 'S'  and
     C                             lbstyp = 'F'  and
     C                             pttask <> 'IDLE  '
     C                   add       lbqpck        w1fix
     C                   if        lbtrn# <> svtrn#
     C                   exsr      zzstamp
     C                   add       w2dmin        w1dmin
     C                   add       w2dsec        w1dsec
     C                   endif
     *  PIR - Selection
     C                   when      lbgrp1 = 'S'  and
     C                             lbstyp = 'P'  and
     C                             pttask <> 'IDLE  '
     C                   add       lbqpck        w1pir
     C                   if        lbtrn# <> svtrn#
     C                   exsr      zzstamp
     C                   add       w2dmin        w1dmin
     C                   add       w2dsec        w1dsec
     C                   endif
     *  Indirect time
     C                   when      tktype = 'I'
     C                   add       ptimin        w1imin
     C                   endsl
     *
     C                   eval      svtrn# = pttrn#
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
     C     shkey1        klist
     C                   kfld                    ptshft
     C                   kfld                    whdp
     C                   kfld                    ptwhse
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zzinz         begsr
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
530aAC                   if        $pmucnt <> 0
     C                   if        w2dmin <> 0
     C     w2dmin        div       $pmucnt       w2dmin
     C                   endif
     C                   if        w2dsec <> 0
     C     w2dsec        div       $pmucnt       w2dsec
     C                   endif
     C                   endif
530aAC                   endif
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
     C                   eval      wkemp# = ptemp#
     C                   eval      wkfnam = usfnam
     C                   eval      wklnam = uslnam
     C                   eval      wkput = w1put
530aAC                   eval      wkload = w1load
     C                   eval      wkrepl = w1repl
     C                   eval      wktfr = w1tfr
     C                   eval      wkvrfy = w1vrfy
     C                   eval      wkfix = w1fix
     C                   eval      wkpir = w1pir
     C                   eval      wkrun = w1run
     C                   eval      wkidle = w1idle
     C                   eval      wkidles = w1idles
     C                   eval      wkdmin = w1dmin
     C                   eval      wkdsec = w1dsec
     C                   eval      wkimin = w1imin
     C                   eval      wkrtnp = w1rtnp
     C                   eval      wkeqck = w1eqck
     C                   eval      wkbulk = w1bulk
     C                   eval      wkstrn = w1strn
     C                   write     wkrec
     C                   endif
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     C     zzzero        begsr
     C                   eval      w1recv = 0
     C                   eval      w1put = 0
     C                   eval      w1repl = 0
530aAC                   eval      w1load = 0
     C                   eval      w1tfr = 0
     C                   eval      w1vrfy = 0
     C                   eval      w1fix = 0
     C                   eval      w1pir = 0
     C                   eval      w1run = 0
     C                   eval      w1idle = 0
     C                   eval      w1idles = 0
     C                   eval      w1dmin = 0
     C                   eval      w1dsec = 0
     C                   eval      w1imin = 0
     C                   eval      w1rtnp = 0
     C                   eval      w1eqck = 0
     C                   eval      w1bulk = 0
     C                   eval      w1strn = 0
     C                   endsr
