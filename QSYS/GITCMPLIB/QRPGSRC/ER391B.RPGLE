      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ER391B    Task Summary by Crew Report - Process 2
     *  Ginger Andrews
     *  22 December, 2009
     *
     *  Revisions
     *
     *    12/22/09  GJA  5.30
     *      - Created
     *
530a *    02/11/10  GJA  5.30a
     *      - Enh:  Create receiving pieces
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
     Fpiruser   ip   e           k disk
     Fporcv3    if   e           k disk
530aAFlabel     if   e           k disk
     Forrtn3    if   e           k disk
     Fer391a    uf a e           k disk
     *----------------------------------------------------------------
     *  Variables
     *
     D $pwhse          s              3  0
     D emply#          s              5  0
     D enddte          s              8  0
     D endtim          s              6  0
     D first           s              1
     D forevr          s              1
     D frmdte          s              8  0
     D frmtim          s              6  0
     *----------------------------------------------------------------
     *  Called programs
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PEMP#
     *      $PCREW
     *      $PFMDT
     *      $PENDT
     *      $PFMTM
     *      $PTOTM
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *
     C     *entry        plist
     C                   parm                    $pwhs             3
     C                   parm                    $pemp#            5
     C                   parm                    $pcrew            6
     C                   parm                    $pfmdt            8
     C                   parm                    $pendt            8
     C                   parm                    $pfmtm            6
     C                   parm                    $ptotm            6
     *
     *  Main line
     *
     *    Note: code moved to *INZSR routine.
     *
     C                   if        emply# > 0  and
     C                             emply# = usemp#
     C                   exsr      zzupd
     C                   eval      *inlr = *on
     C                   goto      skip
     C                   endif
     *
     C                   if        $pcrew > ' '  and
     C                             uscrew = $pcrew
     C                   exsr      zzupd
     C                   endif
     *
     C     skip          tag
     *
     CLr                 return
     *****************************************************************
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     C                   eval      first = *on
     C                   eval      forevr = *off
     C                   move      $pwhs         $pwhse
     C                   move      $pemp#        emply#
     C                   move      $pfmdt        frmdte
     C                   move      $pendt        enddte
     C                   move      $pfmtm        frmtim
     C                   move      $ptotm        endtim
     *
     C     er6key        klist
     C                   kfld                    usemp#
     *
     C     porkey        klist
     C                   kfld                    usemp#
     *
     C     or3aky        klist
     C                   kfld                    $pwhse
     C                   kfld                    uscode
     C                   kfld                    frmdte
     *
     C     or3bky        klist
     C                   kfld                    $pwhse
     C                   kfld                    uscode
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zzrecv        begsr
     *
     C     porkey        setll     porcv3
     C                   dow       forevr = forevr
     C     porkey        reade     porcv3                                 79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   if        pordte < frmdte  or
     C                             pordte > enddte
     C                   iter
     C                   endif
     *
     *    Time range entered by user.
     *
     C                   if        frmtim > 0  or
     C                             endtim > 0
     *
     C                   if        pordte = frmdte  and
     C                             portim < frmtim  or
     C                             pordte = enddte  and
     C                             portim > endtim
     C                   iter
     C                   endif
     C                   endif
     *
     C                   if        poract = 'R'
530aAC     porlbl        chain(n)  label
530aAC                   if        %found
530aAC                   add       lbqpck        wkrecvp
530aAC                   endif
     C                   add       1             wkrecv
     C                   endif
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZRETN  Accumulate total returns generated by a user.
     *
     C     zzretn        begsr
     *
     C                   eval      *in79 = *off
     C     or3aky        setll     orrtn3
     C                   dow       forevr = forevr
     C     or3bky        reade     orrtn3                                 79
     C                   select
     C                   when      *in79
     C                   leave
     *
     C                   when      orrdte < frmdte
     C                   iter
     *
     C                   when      orrdte > enddte
     C                   leave
     *
     *    Time range entered by user.
     *
     C                   when      frmtim > 0  or
     C                             endtim > 0
     *
     C                   if        orrdte = frmdte  and
     C                             orrtim < frmtim  or
     C                             orrdte = enddte  and
     C                             orrtim > endtim
     C                   iter
     C                   else
     C                   add       1             wkrtn
     C                   endif
     *
     C                   endsl
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zzupd         begsr
     C     er6key        chain     er391a                             79
     C                   if        *in79
     C                   clear                   wkrec
     C                   eval      wkemp# = usemp#
     C                   eval      wkfnam = usfnam
     C                   eval      wklnam = uslnam
     C                   exsr      zzrecv
     *    Accumulate total returns generated by user.
     C                   exsr      zzretn
     C                   write     wkrec
     C                   else
     C                   eval      wkemp# = usemp#
     C                   eval      wkfnam = usfnam
     C                   eval      wklnam = uslnam
     C                   exsr      zzrecv
     *    Accumulate total returns generated by user.
     C                   exsr      zzretn
     C                   update    wkrec
     C                   endif
     C                   endsr
     *
