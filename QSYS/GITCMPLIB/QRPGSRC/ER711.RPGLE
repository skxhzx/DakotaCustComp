      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ER711    Current selection by crew - create work file
     *  Ginger Andrews
     *  28 December, 2010
     *
     *  Revisions
     *
     *    12/28/10  GJA  6.40
     *      - Created
     *
640a *    08/12/11  GJA  6.40a
     *      - Enh:  Added route and route ID to screen
     *
     *----------------------------------------------------------------
     *  Custom Client Revision
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
     Fpirtran7  if   e           k disk
     Fpiruser1  if   e           k disk
     Fcrew      if   e           k disk
     Fshift1    if   e           k disk
     Flabeldo1  if   e           k disk
     Flabel90   if   e           k disk
     Fer711     uf a e           k disk
     *****************************************************************
     *----------------------------------------------------------------
     *  Client
      *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @getcl          c                   const('GETCLIENT')
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
     D dte_iso         s               D   datfmt(*ISO)
     D dte_iso2        s               D   datfmt(*ISO)
     D dte             s              8  0
     D forever         s              1
     D frmdte          s              8  0
     D frmtim          s              6  0
     D tim             s              6  0
     D todte           s              8  0
     D totim           s              6  0
     D whse            s              3  0
     D whdp            s              5
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
     C                   parm                    $pwhse            3
     C                   parm                    $pcrew            6
     C                   parm                    $pdte             8
     *
     C                   move      $pdte         dte
     C                   move      $pwhse        whse
     *
     *  Main line
     *
     * Get date and time range from crew
     C                   exsr      zzrange
     *
     C     pt7key3       setll     pirtran7
     *
     *  Process pirtran
     *
     C                   dou       forever<>forever
     *  Crew selection
     *
     C                   read(n)   pirtran7
     *
     C                   if        not %EOF(pirtran7) and ptcrew=$pcrew
     C                   if        ptsdte = frmdte and ptstim >= frmtim or
     C                             ptsdte = todte and ptstim <= totim
     C                   if        ptcat = 'SELECT'
     C     ptemp#        chain     er711
     C                   if        %found(er711)
     C                   if        ptstat = '2'
     C                   exsr      curpieces
640aAC                   movel     ptrtpo        wkrtid
     C                   eval      wkctrn = pttrn#
     C                   eval      wkcpcs = ptpcs
     C                   else
     C                   add       1             wkdtrn
     C                   add       ptpcs         wkdpcs
     C                   exsr      getnonv
     C                   endif
     C                   update    wkrec
     C                   else
     C                   eval      wkemp# = ptemp#
     C     ptemp#        chain     piruser1
     C                   if        %found(piruser1)
     C                   eval      wkfnam = usfnam
     C                   eval      wklnam = uslnam
     C                   else
     C                   eval      wkfnam = *blanks
     C                   eval      wklnam = *blanks
     C                   endif
     C                   if        ptstat = '2'
     C                   exsr      curpieces
640aAC                   movel     ptrtpo        wkrtid
     C                   eval      wkctrn = pttrn#
     C                   eval      wkcpcs = ptpcs
     C                   else
     C                   add       1             wkdtrn
     C                   add       ptpcs         wkdpcs
     C                   endif
     C                   write     wkrec
     C                   endif
     C                   endif
     C                   eval      wkctrn = *zero
     C                   eval      wkcpcs = *zero
     C                   eval      wkdtrn = *zero
     C                   eval      wkdpcs = *zero
     C                   eval      wknvpc = *zero
     C                   eval      wktpcs = *zero
640aAC                   eval      wkrtid = *blanks
640aAC                   eval      wkrte  = *blanks
     C                   else
     C                   leave
     C                   endif
     C                   else
     C                   leave
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
     C                   eval      forever = *on
     *
     *  Get client
     C                   call      @getcl
     C                   parm                    client           10
     *
     * PIRTRAN7
     C     pt7key3       klist
     C                   kfld                    $pcrew
     C                   kfld                    todte
     C                   kfld                    totim
     *
     * CREW
     C     crwkey        klist
     C                   kfld                    whse
     C                   kfld                    $pcrew
     * Shift
     C     sftkey1       klist
     C                   kfld                    crshft
     C                   kfld                    whdp
     C                   kfld                    whse
     * Label90
     C     keylbl90      klist
     C                   kfld                    ptwhse
     C                   kfld                    pttrn#
     *
     C                   endsr
     *****************************************************************
     *
     *  curpieces - get current pieces selected
     *
     C     curpieces     begsr
     *
     *  Set LABELDO to transaction
     C     pttrn#        setll     labeldo1
     *
     C                   dou       forever<>forever
     *
     C                   read(n)   labeldo1
     C                   if        not %EOF(labeldo1) and lbotrn#=pttrn#
     C                   eval      wktpcs += lboqty - lboqtys
     C                   else
     C                   leave
     C                   endif
     C                   enddo
     *
     C                   endsr
     *****************************************************************
     *
     *  getnonv   - get none voiced labels
     *
     C     getnonv       begsr
     *
     *  Set LABEL90 to transaction
     C     keylbl90      setll     label90
     *
     C                   dou       forever<>forever
     *
     C                   read(n)   label90
     C                   if        not %EOF(label90) and lbtrn#=pttrn#
     C                   if        lbvrfy <> 'T' and lbtype = 'O'
     C                   eval      wknvpc += lbqpck
     C                   endif
     C                   else
     C                   leave
     C                   endif
     C                   enddo
     *
     C                   endsr
     *****************************************************************
     *
     *  zzrange Check for shift going over current date
     *
     C     zzrange       begsr
     *
     C                   eval      whdp = *blanks
     C                   time                    tim
     *
     C     crwkey        chain     crew
     C                   if        %found(crew)
     C     sftkey1       chain     shift1
     C                   if        %found(shift1)
     C                   if        shetim < shstim
     * shift crosses 2 days
     C     *ISO          move      dte           dte_iso
     C                   if        tim < shstim
     C                   eval      todte = dte
     C     dte_iso       subdur    1:*D          dte_iso2
     C     *ISO          move      dte_iso2      dte
     C                   eval      frmdte = dte
     C                   eval      frmtim = shstim
     C                   eval      totim = shetim
     C                   else
     C                   eval      frmdte = dte
     C     dte_iso       adddur    1:*D          dte_iso2
     C     *ISO          move      dte_iso2      dte
     C                   eval      todte = dte
     C                   eval      frmtim = shstim
     C                   eval      totim = shetim
     C                   endif
     C                   else
     C                   eval      frmdte = dte
     C                   eval      todte = dte
     C                   eval      frmtim = shstim
     C                   eval      totim = shetim
     C                   endif
     C                   endif
     C                   endif
     C                   endsr
