      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ER421     Populate work file
     *  03 October, 2000
     *  Hemant Kapadia
     *
     *  10.03.00  HNK  4.14
     *   Created
     *
     *  Note: Report direct minutes includes IDLE time as follows.
     *                Task      Minutes    Calculate
     *        Start   IDLE         5
     *                PUTAWY       2       5+2+3=10
     *                IDLE         3
     *                PUTAWY       4       4+1=5
     *                IDLE         1
     *                PUTAWY       2       2+4=6
     *                IDLE         4
     *        End     ENDDAY       0
     *
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
     *  07/22/09   GJA  5.30
     *     -Enh:  Convert to RPGLE, cleaned up and revamped for       f
     *             suspended transactions
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  77        Chain WORKLBL file indicator
     *  79        Not on file/End of file indicator
     *  90        Overflow Indicator
     *  9X        Top of page and level X continues.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fer421     ip   e           k disk
     Ftask      if   e           k disk
     Fer4221    uf   e           k disk
     F                                     rename(errec:errec1)
     Fer422     uf a e           k disk
     Fworklbl   if   e           k disk
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *
     *----------------------------------------------------------------
     *QREC
     *                                             PTEMP#L1
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
     D etim            s              6  0
     D first           s              1
     D fmdt            s              8  0
     D l               s              1  0
     D n               s              3  0
     D newtrn          s              1
     D svidle          s                   like(erdmin)
     D svtrn#          s                   like(ertrn#)
     D todt            s              8  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PFMDT  From date (YYYYMMDD)
     *      $PTODT  To date (YYYYMMDD)
     *      $PWHSE  Warehouse number
     *      $PBTIM  Begin time
     *      $PETIM  End time
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
     C                   parm                    $pbtim            6
     C                   parm                    $petim            6
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C                   select
     C                   when      first = *on
     C                   move      $pfmdt        fmdt
     C                   move      $pbtim        btim
     C                   move      $ptodt        todt
     C                   move      $petim        etim
     *
     *    Time criteria overlaps two days. Use overlap selection.
     C                   if        fmdt = todt  and
     C                             etim = 0
     C                   eval      dayolp = '*YES'
     C                   else
     C                   eval      dayolp = '*NO '
     C                   endif
     C                   endsl
     *
     *
     *  Getout if the beginning time of the transaction is less than
     *  the starting time on the start date entered.
     *
     C                   select
     *
     C                   when      dayolp = '*YES'
     *    User entered time criteria that overlaps two days.
     *    Get out if date/time not in range entered by the user.
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
     *    User entered time criteria. Get out if the start time
     *    is not in the date/time range entered by the user.
     C                   when      btim <> 0  or
     C                             etim <> 0
     *
     C                   select
     C                   when      ptsdte = fmdt  and
     C                             ptstim < btim  or
     *
     C                             ptsdte = todt  and
     C                             ptstim > etim
     *
     C                   goto      skip
     *
     C                   endsl
     C                   endsl
     C                   endsl
     *
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     C                   eval      newtrn = *off
     *
     C     pttask        chain     task                               79
     *
     C     key22         chain     er422                              79
     *
     C                   if        *in79
     C                   eval      ertrn# = pttrn#
     C                   eval      erstat = ptstat
     C                   eval      ertask = pttask
     C                   eval      ercat = ptcat
     C                   eval      ersub = ptsub
     C                   eval      erwhse = ptwhse
     C                   eval      erwhdp = lbwhdp
     C                   if        ptcat = 'SELECT'
     C     lblbl#        chain     worklbl                            77
     C                   if        not *in77
     C                   movel     lwszon        erwhdp
     C                   endif
     C                   endif
     C                   if        lbstyp > ' '
     C                   eval      erstyp = lbstyp
     C                   else
     C                   eval      erstyp = ptstyp
     C                   endif
     C                   eval      ershft = ptshft
     C                   eval      ercrew = ptcrew
     C                   eval      eremp# = ptemp#
     C                   eval      ercube = lbcube
     C                   eval      erswgt = lbswgt
     C                   eval      erpcs = lbqpck
     C                   eval      eraisl = ptaisl
     C                   eval      erqty1 = ptqty1
     C                   eval      erqty2 = ptqty2
     C                   eval      erqty3 = ptqty3
     C                   eval      ergdte = ptgdte
     C                   eval      ergtim = ptgtim
     C                   eval      ersdte = ptsdte
     C                   eval      erstim = ptstim
     C                   eval      eredte = ptedte
     C                   eval      eretim = ptetim
     C                   eval      eretyp = ptetyp
     C                   eval      ercdte = ptcdte
     C                   eval      erctim = ptctim
     C                   eval      errdte = ptrdte
     C                   eval      errtpo = ptrtpo
     C                   eval      ergrp1 = ptgrp1
     C                   eval      ergrp2 = ptgrp2
     C                   eval      newtrn = *on
     C                   endif
     *
     C                   select
     * Idle task - Save the time to be added to the next direct task.
     C                   when      pttask = 'IDLE'
     C                   add       ptdmin        svidle
     C                   if        newtrn = *on
     C                   eval      erdmin = ptdmin
     C                   write     errec
     C                   else
     C                   add       lbcube        ercube
     C                   add       lbswgt        erswgt
     C                   add       lbqpck        erpcs
530aDC*                  add       ptdmin        erdmin
     C                   update    errec
     C                   endif
     * Direct task other than 'IDLE' - Add idle time from the previous
     *                                 'IDLE' task to this task.
     C                   when      pttask <> 'IDLE'  and
     C                             tktype <> 'I'
     C                   add       svidle        ptdmin
     C                   if        newtrn = *on
     C                   eval      svidle = 0
     C                   eval      svtrn# = pttrn#
     C                   eval      erdmin = ptdmin
     C                   write     errec
     C                   else
     C                   add       lbcube        ercube
     C                   add       lbswgt        erswgt
     C                   add       lbqpck        erpcs
530aDC*                  add       ptdmin        erdmin
     C                   update    errec
     C                   endif
     *
     * Indirect task - add the idle time to the previous direct task.
     C                   when      pttask <> 'IDLE'  and
     C                             tktype = 'I'
     *
     C                   if        newtrn = *on
     C                   eval      erimin = ptimin
     C                   write     errec
     C                   else
     C                   add       ptimin        erimin
     C                   update    errec
     C                   endif
     *
     C                   endsl
     *
     *
     *  Set off top-of-page indicators
     *
     C                   eval      first = *off
     *
     C     skip          tag
     *
     CLr   svtrn#        chain     er4221                             79
     CLr                 if        not *in79
     CLr                 add       svidle        erdmin
     CLr                 update    errec1
     CLr                 endif
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
     C                   eval      svidle = 0
     C                   eval      svtrn# = 0
     *
     *  Define key for ER422 file.
     *
     C     key22         klist
     C                   kfld                    ptemp#
     C                   kfld                    ptsdte
     C                   kfld                    ptstim
     *
     C                   eval      first = *on
     C                   eval      l = 1
     C                   eval      n = 0
     C                   eval      begin = *off
     C                   endsr
