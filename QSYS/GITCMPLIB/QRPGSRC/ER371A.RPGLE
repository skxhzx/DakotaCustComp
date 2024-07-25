      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ER371A    Populate work file.
     *  17 November, 2000
     *  Hemant Kapadia
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
     *  11.17.00  HNK  4.15
     *   Created
     *
     *  07/22/09  GJA  5.30
     *     -Enh:  Convert to RPGLE, use time range sent in parm
     *            cleaned up and revamped for suspended transactions
640a *  11/21/11  GJA  6.40a
     *     -Fix:  If using SOS entry, transaction could expand over
     *            multiple days.
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
     Fer371     ip   e           k disk
     Fshift     if   e           k disk
     Fpiruser1  if   e           k disk
     Fworklbl   if   e           k disk
     Fer371a    o  a e           k disk
     *----------------------------------------------------------------
     *  Date redefinition data structure
     *
     D $pfmdt          ds
     D  $pfmcc                 1      2
     D  $pfmyy                 3      4
     D  $pfmmm                 5      6
     D  $pfmdd                 7      8
     D $ptodt          ds
     D  $ptocc                 1      2
     D  $ptoyy                 3      4
     D  $ptomm                 5      6
     D  $ptodd                 7      8
     *----------------------------------------------------------------
     *  Variables
     *
     D begin           s              1
     D btim            s              6  0
     D dayolp          s              4
     D emp#            s              5  0
     D etim            s              6  0
     D first           s              1
     D fmdt            s              8  0
     D l               s              1  0
     D n               s              3  0
     D svlbl#          s                   like(lblbl#)
     D todt            s              8  0
     D w1whdp          s              5
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *
     *----------------------------------------------------------------
     Ioqrec
     I                                          ptemp#        l1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PFMDT  From date (YYYYMMDD)
     *      $PTODT  To date (YYYYMMDD)
     *      $PWHSE  Warehouse number
     *      $PEMP#  Employee number
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pfmdt
     C                   parm                    $ptodt
     C                   parm                    $pwhse            3
     C                   parm                    $pcrew            6
     C                   parm                    $pdmin            3
     C                   parm                    $pfmtm            6
     C                   parm                    $ptotm            6
     C                   parm                    $pvyn             1
     C                   parm                    $pzndp            1
     C                   parm                    $ptbd             1
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C                   if        first = *on
     C                   eval      emp# = ptemp#
     C     emp#          chain     piruser1                           79
     C                   if        *in79
     C                   eval      uswhse = 0
     C                   eval      uswhdp = *blanks
     C                   endif
     *
     C                   eval      w1whdp = *blanks
     C                   if        $pfmtm = *blanks
     C     shkey         chain     shift                              79
     C                   if        *in79
     C                   eval      shstim = 0
     C                   eval      shetim = 0
     C                   endif
     C                   else
     C                   move      $pfmtm        shstim
     C                   move      $ptotm        shetim
     C                   endif
     *
     C                   move      $pfmdt        fmdt
     C                   move      shstim        btim
     C                   move      $ptodt        todt
     C                   move      shetim        etim
     *
     *    Time criteria overlaps two days. Use overlap selection.
     C                   if        etim < btim  and
     C                             etim > 0
     C                   eval      dayolp = '*YES'
     C                   else
     C                   eval      dayolp = '*NO '
     C                   endif
     *
     C                   eval      first = *off
     C                   endif
     *
     *  Level 1 break - Employee number
     *
     C                   if        *inl1
     C                   eval      begin = *off
     *
     C                   eval      emp# = ptemp#
     C     emp#          chain     piruser1                           79
     C                   if        *in79
     C                   eval      uswhse = 0
     C                   eval      uswhdp = *blanks
     C                   endif
     C                   endif
     *
     *   Ignore any task befor BEGDAY Or begining of the shift time,
     *   if BEGDAY is missing in the transaction file.
     *
     C                   if        begin = *off  and
     C                             pttask <> 'BEGDAY'  and
     C                             ptstim < shstim
     C                   endif
     *
     C                   eval      begin = *on
     *
     *   Getout if we have gone past the begining shift time on next
     *   day.(Day following the To date entered) If we get out from
     *   here, it means that ENDDAY task was not found for this
     *   employee for the date range.
     *
     C                   select
     *
     C                   when      dayolp = '*YES'
     *    Shift time criteria overlaps two days.
     *    Get out if date/time not in Shift range.
     *
     C                   select
     C                   when      ptsdte = fmdt  and
     C                             ptstim < btim  or
     *
     C                             ptsdte > fmdt  and
     C                             ptsdte < todt  and
     C                             ptstim < btim  and
     C                             ptstim > etim  or
     *
     C                             ptsdte = todt  and
     C                             ptstim > etim
     *
     C                   goto      skip
     *
     C                   endsl
     *
     C                   other
     *
     C                   select
     *
     *    Get out if the start time is not in the Shift date/time range.
     C                   when      btim <> 0  or
     C                             etim <> 0
     *
     C                   select
640aDC                   when      ptsdte >= fmdt  and
640aDC                             ptsdte <= todt  and
640aDC                             ptstim < btim  or
640aD*
640aDC                             ptsdte >= fmdt  and
640aDC                             ptsdte <= todt  and
640aDC                             ptstim > etim
640aMC                   when      ptsdte <  fmdt  or
640aMC                             ptsdte >  todt  or
640aM*
640aMC                             ptsdte =  fmdt  and
640aMC                             ptstim < btim  or
640aM*
640aMC                             ptsdte =  todt  and
640aMC                             ptstim > etim
     *
     C                   goto      skip
     *
     C                   endsl
     C                   endsl
     C                   endsl
     *   Skip OUT label adjustment records
     C                   if        lbtype='A'
     C                   goto      skip
     C                   endif
     *
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     C                   eval      wktrn# = pttrn#
     C                   eval      wkstat = ptstat
     C                   eval      wktask = pttask
     C                   eval      wkcat = ptcat
     C                   eval      wksub = ptsub
     C                   eval      wkwhse = ptwhse
     C                   eval      wkwhdp = ptwhdp
     C                   if        lbstyp = ' '
     C                   eval      wkstyp = ptstyp
     C                   else
     C                   eval      wkstyp = lbstyp
     C                   endif
     C                   eval      wkshft = ptshft
     C                   eval      wkcrew = ptcrew
     C                   eval      wkemp# = ptemp#
     C                   eval      wkcube = lbcube
     C                   eval      wkswgt = lbswgt
     C                   eval      wkaisl = ptaisl
     C                   eval      wkqty1 = ptqty1
     C                   eval      wkqty2 = ptqty2
     C                   eval      wkqty3 = ptqty3
     C                   eval      wkgdte = ptgdte
     C                   eval      wkgtim = ptgtim
     C                   eval      wksdte = ptsdte
     C                   eval      wkstim = ptstim
     C                   eval      wkedte = ptedte
     C                   eval      wketim = ptetim
     C                   eval      wketyp = ptetyp
     C                   eval      wkcdte = ptcdte
     C                   eval      wkctim = ptctim
     C                   eval      wkrdte = ptrdte
     C                   eval      wkdmin = ptdmin
     C                   eval      wkimin = ptimin
     C                   eval      wkrtpo = ptrtpo
     C                   eval      wkgrp1 = ptgrp1
     C                   eval      wkgrp2 = ptgrp2
     C                   if        $pzndp = 'Z'  and
     C                             ptcat = 'SELECT'
     C     lblbl#        chain     worklbl                            77
     C                   if        not *in77
     C                   movel     lwszon        wkzone
     C                   endif
     C                   endif
     C                   if        lbstyp = ' '
     C                   eval      wkstyp = ptstyp
     C                   else
     C                   eval      wkstyp = lbstyp
     C                   endif
     C                   if        pttask = 'RUNNER'
     C                   eval      wkpcs  = ptpcs
     C                   else
     C                   eval      wkpcs  = lbqpck
     C                   endif
     C                   eval      wkqtysa  = lbqalc - lbqpck
     C                   if        pasemp# <> 0 and $ptbd = 'Y'
     C                   eval      wkdmin = pasdmin
     C                   eval      wkemp# = pasemp#
     C                   eval      wksdte = passdte
     C                   eval      wkstim = passtim
     C                   eval      wkedte = pasedte
     C                   eval      wketim = pasetim
     C                   endif
     C                   if        $pvyn = 'Y' and lboemp# <> 0
     C                   eval      wkpcs   = lboqty
     C                   eval      wkqtysa  = lboqtys
     C                   eval      wkemp# = lboemp#
     C                   eval      wkcrew = lbocrew
     C                   endif
     C                   if        svlbl#<>lblbl# or lblbl#=0
     C                   write     wkrec
     C                   clear                   wkrec
     C                   endif
     C                   eval      svlbl#=lblbl#
     *
     *
     *  Set off top-of-page indicators
     *
     C                   eval      first = *off
     *
     C     skip          tag
     *
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
     C     shkey         klist
     C                   kfld                    uswhse
     C                   kfld                    w1whdp
     C                   kfld                    usshft
     *
     C                   eval      first = *on
     C                   eval      l = 1
     C                   eval      n = 0
     C                   eval      begin = *off
     C                   endsr
