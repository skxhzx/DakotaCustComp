      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RT760     Daily Truck Builder Move routes to exported status
     *  12 October, 2007
     *  Jeffrey Jahnke
     *
     *  Notes:
     *      - Change RTEHED records to Status '6' Exported.
     *
     *----------------------------------------------------------------
     *  Revisions
640 A*    01/02/11  MLB  6.40
     *      - Enh: Revised pgm to only run zzpirtran 1 time
     *        based on route type from RTEHED file.
730aA*    01/25/19  MR   7.30a
     *      - Add UPDLBLBTCH program to update EXPSPLBL when route is       order
     *        undone.                                                       order
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: CDI
CDI A*    03/26/12  MLB  CDI
     *      - Revised program to only move routes at status 4=Printed
     *        or greater to 6=Exported status.
CDIaA*    03/25/13  MLB  CDIa
     *      - Revised program to only move routes at status 5=Closed
     *        status to 6=Exported status.
     *      - Revised program to setll using route status 5=Closed
     *        so reduce number of RTEHED rcds needing to be read.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Harbor
HAR A*    02/12/18  MLB  HAR
     *      - Revised program to only move routes at status 4=Printed
     *        or greater to 6=Exported status.
     *      - Added HAR to CDI mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Earl's Organic Produce
EOP A*    05/21/19  MLB  EOP
     *      - Revised program to only move routes at status 5=Closed
     *        status to 6=Exported status.
     *      - Revised program to setll using route status 5=Closed
     *        so reduce number of RTEHED rcds needing to be read.
     *      - Added EOP to CDIa mod.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - EOF for FILES
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Frtehed3   uf   e           k disk
     Fpirtran4  uf   e           k disk
     Flabel13   uf   e           k disk
     Fordh3     uf   e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     D @getcl          c                   const('GETCLIENT')
     D @cvtdt          c                   const('CVTDTE')
      /copy qcopysrc,id#usfcrp
CDI   /copy qcopysrc,id#cdi
HAR   /copy qcopysrc,id#harbor
EOP   /copy qcopysrc,id#eop

     *----------------------------------------------------------------
     *  Working variables
     *
     D today           s              8  0
     D lsttim          s              6  0
     D whse            s              3  0
     D rtpo            s              9
     D $pwhse          s              3
     D pcmd            s              8
     D grp2            s              1
     D forevr          s              1
CDIaAD kyrhstat        s                   like(rhstat)
     *
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

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PPrg   - Program to send message back to.
     *      $Pwhse  - Warehouse to work with.
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse
     *----------------------------------------------------------------
     * Main line
     *
     c                   exsr      zzrtehed
     *
     c                   eval      *inlr = *on
     *----------------------------------------------------------------
     *  zzrtehed - Update RTEHED records to exported
     *
     c     zzrtehed      begsr

CDIaAC                   select
CDIaAC                   when      client = CDI
EOP AC                             or client = EarlsOrganic
CDIaAC                   eval      kyrhstat = '5'
CDIaAC     keyrh_cdi     setll     rtehed3
CDIaA*
HAR AC                   when      client = Harbor
HAR AC                   eval      kyrhstat = '4'
HAR AC     keyrh_har     setll     rtehed3
HAR A*
CDIaAC                   other
CDIaA*
     c     keyrh         setll     rtehed3
CDIaAC                   endsl
CDIaA*
     c     forevr        doweq     forevr
     c     keyrh         reade     rtehed3

     c                   select
     c                   when      %eof(rtehed3)
     c                             or rhstat >= '6'
     c                   leave
CDI A*
CDI A*  Skip routes that are at Open or Built status.
EOP Mc                   when          (client = CDI
EOP AC                             or   client = EarlsOrganic)
CDIaDc*                            and  rhstat < '4'
CDIaMc                             and  rhstat < '5'
HAR Ac                             or  (client = Harbor)
HAR Ac                             and  rhstat < '4'
CDI Ac                   iter
CDI A*
     c                   other
640 M*  Regular & Will Call routes
640 DC*                  eval      grp2 = *blanks
640 Mc                   eval      grp2 = rhtype
     c                   exsr      zzpirtran
     *  Will Call routes
640 Dc*                  eval      grp2 = 'W'
640 Dc*                  exsr      zzpirtran
     *  Labels
     c                   exsr      zzlabel
     *  Orders
     c                   exsr      zzordh

     c                   eval      rhstat = '6'
     c                   time                    rhstst
     c                   if        rhstst < lsttim
     c                   exsr      zzzdte
     c                   endif
     c                   eval      rhstsd = today
     c                   eval      rhexpd = rhimpd
     c                   eval      rhexpt = rhimpt
     c                   update    rhrec

730aA*  Update EXPSPLBL record to 'S' status.

730aAC                   call      'UPDLBLBTCH'
730aAC                   parm      'RT760'       pcmd
730aAC                   parm                    whse
730aAC                   parm                    rhRtId

     c                   endsl

     c                   enddo

     c                   endsr
     *----------------------------------------------------------------
     *  zzpirtran - Update PIRTRAN records to closed
     *
     c     zzpirtran     begsr

     c                   eval      rtpo = rhrtid

     c     keytr         setll     pirtran4
     c     forevr        doweq     forevr
     c     keytr         reade     pirtran4

     c                   select
     c                   when      %eof(pirtran4)
     c                   leave
     c                   other
     c                   if        ptstat <> '4'
     c                   eval      ptstat = '4'
     c                   time                    ptctim
     c                   if        ptctim < lsttim
     c                   exsr      zzzdte
     c                   endif
     c                   eval      ptcdte = today
     c                   update    ptrec
     c                   endif
     c                   endsl

     c                   enddo

     c                   endsr
     *----------------------------------------------------------------
     *  zzlabel - Update PIRTRAN records to closed
     *
     c     zzlabel       begsr

     c     keylb         setll     label13
     c     forevr        doweq     forevr
     c     keylb         reade     label13

     c                   select
     c                   when      %eof(label13)
     c                   leave
     c                   other
     c                   if        lbstat <>'C'
     c                   eval      lbstat = 'C'
     c                   time                    lbstim
     c                   if        lbstim < lsttim
     c                   exsr      zzzdte
     c                   endif
     c                   eval      lbsdte = today
     c                   update    lbrec
     c                   endif
     c                   endsl

     c                   enddo

     c                   endsr
     *----------------------------------------------------------------
     *  zzordh - Update ORDH records to closed
     *
     c     zzordh        begsr

     c     keyoh         setll     ordh3
     c     forevr        doweq     forevr
     c     keyoh         reade     ordh3

     c                   select
     c                   when      %eof(ordh3)
     c                   leave
     c                   other
     c                   if        ohstat <> 'C'
     c                   eval      ohstat = 'C'
     c                   time                    ohstim
     c                   if        ohstim < lsttim
     c                   exsr      zzzdte
     c                   endif
     c                   eval      ohsdte = today
     c                   eval      ohudte = ohsdte
     c                   eval      ohutim = ohstim
     c                   update    ohrec
     c                   endif
     c                   endsl

     c                   enddo

     c                   endsr
     *----------------------------------------------------------------
     *
     *  ZZZDTE   Get date.
     *
     C     zzzdte        begsr
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     C                   time                    lsttim
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     *   Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     C                   parm                    cliloc           10
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ   Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C                   eval      whse = %dec($pwhse:3:0)
     C                   exsr      zzzdte
     *
     *  Define key for RTEHED.
     *
     C     keyrh         klist
     C                   kfld                    whse
CDIaA*
CDIaAC     keyrh_cdi     klist
CDIaAC                   kfld                    whse
CDIaAC                   kfld                    kyrhstat
HAR A*
HAR AC     keyrh_har     klist
HAR AC                   kfld                    whse
HAGR C                   kfld                    kyrhstat
     *
     *  Define key for PIRTRAN4.
     *
     C     keytr         klist
     C                   kfld                    whse
     C                   kfld                    grp2
     C                   kfld                    rtpo
     *
     *  Define key for LABEL8.
     *
     C     keylb         klist
     C                   kfld                    whse
     C                   kfld                    rhrtid
     *
     *  Define key for ORDH3.
     *
     C     keyoh         klist
     C                   kfld                    whse
     C                   kfld                    rhrtid

     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
