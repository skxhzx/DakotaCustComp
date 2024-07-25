     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RH225  Dakota Voice SA Create Labels
     *  23 Novemnber 2005
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*    11/23/05  MLB  5.00
     *      - Created.
500aA*    01/27/06  MLB  5.00a
     *      - Fix: Revised FILLB to populate LBPSEQ with value from
     *        Slot file. Was loading value from ORDLBL which may be zero
     *        coming from client.
     *
530 A*    10/16/10  MLB  5.30
     *      - Fix: Revised to not allow DSUNLOAD to exceed 99.
     *      - Fix: Revised to not allow DSROW to exceed 99.
530aA*    10/19/10  MLB  5.30a
     *      - Fix: Revised to fillLb routine to load dspalletid
     *        instead of dftpalletid.
530bA*    10/20/10  MLB  5.30b
     *      - Fix: Revised to fillLb routine to load dspalletid
     *        instead of dftpalletid.
     *
640 A*    12/22/11  MLB  6.40
     *      - Fix: Revised routine filllb to correct field names
     *        used for testing brkdwn1, brkdwn2 pick quantities.
640aA*    01/19/12  MLB  6.40a
     *      - Fix: Revised routine filllb to load report date, status
     *        date/time fields when writing out brkdwn1, 2 labels.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Grocery Supply
     *
GSC A*    01/16/06  MLB  GSC
     *      - Revised program to call DK131 to assign Host sent dock dr.
GSCaA*    12/19/06  MLB  GSCa
     *      - Revised program to call DFPICK to assign custom pick sequence
     *        for labels in repack area (dept=7). TD-TL, then TA-TC aisles.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Avalon Foodservice
     *
AVL A*    12/07/11  MLB  AVL
     *      - Revised program to populate the LBLVL2 so that the labels
     *        sort in Retalix print sequence. These changes are being
     *        done to correct sort issues where Dakota Voice sort did
     *        not match sequence for Retalix pick labels.
AVLaA*    01/18/12  MLB  AVLa
     *      - Revised program to load label type into LBTYPE from ORDLBL
     *        record. This is being done so that catchwgts are not captured
     *        when processing merge labels.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Chain Indicator
     *  98        Error on screen (Sound Buzzer)
     *  99        Universal Record Indicator (Very Temporary Usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Frtehed3   uf   e           k disk
     F                                     rename(rhrec:rhrec3)
     Fdocdoor   if   e           k disk
     Flabel     uf a e           k disk
     Foptions   if   e           k disk
     Fordd      uf   e           k disk
     Fordh      if   e           k disk
     Fordh3     uf   e           k disk
     F                                     rename(ohrec:ohrec3)
     FordlbL1   uf   e           k disk
     Fpiritem   if   e           k disk
     Fpirtran   uf a e           k disk
     Fpltsum    uf a e           k disk
     Fpltstp1   uf a e           k disk
     Frtecsum   uf a e           k disk
     Fslot2     if   e           k disk
     Fbatctl    o    e           k disk
     FordLt     o    e             disk
     Frunner    o    e           k disk
     *----------------------------------------------------------------
     *  Customer id
     *
GSC AD/copy qcopysrc,id#gsc
JTD AD/copy qcopysrc,id#jtd
AVL AD/copy qcopysrc,id#avalon
     *----------------------------------------------------------------
     *  Called programs
     *
     D @getsi          c                   const('GETSLOTITM')
     D @cvtdt          c                   const('CVTDTE')
     *
     *----------------------------------------------------------------
     *  *RUNNER  -  PIR Runner Flag Options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPCRTM  -  Create Manual Runner entries for shorts/outs (Y/N)
     *    OPUPLR  -  Update Label with quantity shorted during manual
     *               flag entry (Y/N)
     *               NOTE: Any change to this field will cause OPUPLV
     *                     in the *VOICE options record to be updated.
     *    OPRPLF  -  Replenish flagged items before print report? (Y/N)
     *               & create Priority Replenishment if necessary.
     *    OPMRGF  -  Create Runner entries for Merge records? (Y/N)
     *    OPCLRF  -  Clear Runner flags if qty still short/out? (Y/N)
     *    OPRNRM  -  Send break message to user when new Runner
     *               task has been assigned. (Y/N)
     *    OPCLSF  -  Update Label quantity at flag close (Y/N).
     *    OPOUTF  -  Create Runner entry after slot marked out. (Y/N)
     *    OPRPCK  -  Print Runner pick list. (Y/N)
     *    OPRLBL  -  Print Runner pick labels. 0=No, 1=full size Zebra
     *               printer, 2=Belt printer
     *
     * Data structure
     *
     D oprdata         ds
     D  opcrtm                 1      1
     D  opuplr                 2      2
     D  oprplf                 3      3
     D  opmrgf                 4      4
     D  opclrf                 5      5
     D  oprnrm                 6      6
     D  opclsf                 7      7
     D  opoutf                 8      8
     D  oprpck                 9      9
     D  oprlbl                10     10
     D  optend               117    117

     *----------------------------------------------------------------
     *  Pallet ID Data Structure
     *----------------------------------------------------------------

     D dspltidds       ds
     D   dsunused              1      2  0
     D   dsgen                 3      3  0
     D   dsrow                 4      5  0
     D   dscol                 6      6  0
     D   dsseq                 7      7  0
     D   dspalletid            1      7  0
     D   dsunload      s                   like(psunld)
     D                                     inz(0)

     *----------------------------------------------------------------
     *  Date Conversion Variables
     *----------------------------------------------------------------

     D $cvtdt          ds
     D   $cvcmd                1      8
     D   $cvprg                9     18
     D   $cvd6i               19     24
     D   $cvd8i               25     32
     D   $cvd6o               33     38  0
     D   $cvd8o               39     46  0
     D   $cvsto               47     64
     D   $cvrtn               65     72
     D   $cverm               73    132
     D   $cvmsg               73     76
AVL A*
AVL A*----------------------------------------------------------------
AVL A*  Re-mapped file fields.
AVL A*
AVL A /copy qcopysrc,alhtn_rtx
AVLaA /copy qcopysrc,alhfl1_rtx
AVLaA /copy qcopysrc,alhfl2_rtx
AVLaA /copy qcopysrc,alhfl3_rtx
AVLaA /copy qcopysrc,alhfl4_rtx
AVLaA /copy qcopysrc,alhfl5_rtx
     *
     *----------------------------------------------------------------
     *  Order Label Host Field Re-Definition DS's.
     *
     D Hostfld2ds      ds
     D  aldockdoor                    2s 0
     D                                     inz(0)
     *----------------------------------------------------------------
     *  Working Variables.
     *
     D #bitem          s                   like(ititem)
     D #odesc          s                   like(itdesc)
     D #oitem          s                   like(ititem)
     D #opdsc          s                   like(itpdsc)
     D #otype          s              1
     D #sitem          s                   like(ititem)
     D avail1          s              5  0
     D avail2          s              3  0
     D avail3          s              3  0
530bAD avl_cube        s                   like(ptcube)
530bAD avl_pcs         s                   like(ptpcs)
530bAD avl_wgt         s                   like(ptswgt)
     D c#cube          s                   like(itcube)
     D curdef          s              1  0
     D cvt1a           s              1
     D cvt5a           s              5
     D cvt8a           s              8
     D dftpalletid     s                   like(lbpal#)
     D                                     inz(0010111)
     D dftpallet#      s                   like(pspal#)
     D diffq2          s                   like(odqor2)
     D diffq3          s                   like(odqor3)
     D dscln           s             80
     D eofod           s              1
     D eofoh           s              1
     D excpq1          s              5  0
     D excpq2          s              5  0
     D excpq3          s              5  0
     D flgpck          s              1
     D flgtrk          s              1
     D forever         s              1
     D kyopen          s              1
     D kyplid          s                   like(psplid)
     D newtrn#         s                   like(pttrn#)
     D ocode           s              8
     D odflag          s              1
     D ohflag          s              1
     D opened          s              1
     D outflag         s              4    inz('*NO ')
     D pckcnt          s              3  0
     D pickq1          s              5  0
     D pickq2          s              5  0
     D pickq3          s              5  0
     D prflag          s              1
     D r               s              3  0
     D remain          s              5  0
     D s#cube          s                   like(itcube)
     D stop            s              1
     D stop1           s                   like(psstp1)
     D stop2           s                   like(psstp2)
     D svaisl          s                   like(slaisl)
     D svdisp          s                   like(sldisp)
     D svdoor          s                   like(dddoor)
     D svhand          s                   like(slhand)
     D svloc           s                   like(slloc)
     D svpseq          s                   like(slpseq)
     D svpallet#       s                   like(pspal#)
     D svrlvl          s                   like(slrlvl)
     D svstop          s                   like(lbstop)
     D svstop1         s                   like(lbstop)
     D svstop2         s                   like(lbstop)
     D svstyp          s                   like(slstyp)
     D svwhdp          s                   like(slwhdp)
     D svwhse          s                   like(slwhse)
     D stop_cube       s                   like(ptcube)
     D stop_pcs        s                   like(ptpcs)
     D stop_wgt        s                   like(ptswgt)
     D total_cube      s                   like(ptcube)
     D total_pcs       s                   like(ptpcs)
     D total_wgt       s                   like(ptswgt)
     D rte_cube        s                   like(ptcube)
     D rte_pcs         s                   like(ptpcs)
     D rte_wgt         s                   like(ptswgt)
     *----------------------------------------------------------------
     D kydisp          s                   like(sldisp)
     D kyitem          s                   like(slitem)
     D kyrow           s                   like(psrow )
     D kycol           s                   like(pscol )
     D kyrtid          s                   like(rhrtid)
     D kybsq           s                   like(pssbsq)
     D kystat          s                   like(rhstat)
     D kystop          s                   like(pssstp)
     D kytype          s                   like(rhtype)
     D kywhdp          s                   like(slwhdp)
     D kywhse          s                   like(rhwhse)
     D pickstamp       s               z
     D pickdate        s              8  0
     D picktime        s              6  0
     D sv_host_tran#   s                   like(alhtr#)
     D sv_disp         s                   like(sldisp)
     D sv_item         s                   like(slitem)

GSC A*----------------------------------------------------------------
GSC A*  Program parameters
GSC A*----------------------------------------------------------------
GSC A
GSC AD $lparm          ds
GSC AD  $lcmd                  1      8
GSC AD  $lprg                  9     18
GSC AD  $luky                 19     68
GSC AD  $lrtn                 69     76
GSC AD  $lerm                 77    136
GSC AD  $lmsg                 77     80
GSC A*
GSC A*   Redefine key
GSC A*
GSC AD  $lwhse                19     21  0
GSC AD  $lhdte                22     29  0
GSC AD  $lhtim                30     35  0
GSC AD  $lpass                36     38  0
GSC AD  $ldoor                39     41  0
GSC AD  $lwhdp                42     46
GSC AD  $lrtid                47     51
GSC AD  $lrtec                52     56P 3
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PTYPE  Order Type
     *      $PRTID  Route id to process.
     *      $PRTN   Return code
     *
     *    Returned Parameters
     *      $RTNCD  *OK      - Labels created successfully
     *              *ERROR   - Error creating labels
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $ptype            1
     C                   parm                    $prtid            5
     C                   parm                    $prtn             8
     *----------------------------------------------------------------
     *  Main line
     *
     *  Find Open route just imported.
     *
     C                   eval      kywhse = $pwhse
     C                   select
     *    Route being processed is Stand-Alone route w/Host labels,
     *    treat route as Normal route.
     C                   when      $ptype = 'A'
     C                   eval      kytype = ' '
     C                   other
     C                   eval      kytype = $ptype
     C                   endsl
     C                   eval      kystat = *on
     C                   eval      kyrtid = $prtid
     *
     C     keyrh3        setll     rtehed3
     C     keyrh3        reade     rtehed3
     *
     C                   if        not %eof(rtehed3)
     C     keyoh3        setll     ordh3
     C                   dow       not %eof(ordh3)
     C     keyoh3        reade     ordh3
     *
     *    Update order detail, set to Picked.
     C     keyod         setll     ordd
     C                   dow       not %eof(ordd)
     C     keyod         reade     ordd
     C                   if        not %eof(ordd)
     C                   exsr      fillod
     C                   exsr      updod
     C                   endif
     C                   enddo
     *
     *    Update order status, date on order header, set to Picked.
     C                   if        not %eof(ordh3)
     C                   exsr      filloh3
     C                   exsr      updoh3
     C                   endif
     *
     C                   enddo
     *
     *     - Get new batch number.
     *
     C                   call      'PIRBAT#'
     C                   parm                    $PBAT             7 0
     *
     *     - Create batch control record.
     *
     C                   eval      btbat# = $pbat
     C                   eval      btwhse = $pwhse
     C                   eval      bttype = $ptype
     C                   eval      btstat = '3'
     C                   eval      btrte  = $prtid
     C                   eval      btstrd = pickdate
     C                   eval      btstrt = picktime
     C                   eval      btstrb = #user
     C                   write     btrec
     *
     *     Update Route Header Built/Pick date/time and status.
     C                   eval      rhpbat = btbat#
     C                   eval      rhbldd = pickdate
     C                   eval      rhbldt = picktime
     C                   eval      rhprtd = pickdate
     C                   eval      rhprtt = picktime
     C                   eval      rhstsd = pickdate
     C                   eval      rhstst = picktime
     C                   eval      rhstat = '4'
     C                   update    rhrec3
     *
     *  Get Runner options.
     *
     C                   exsr      getrunopt
     *
     *     Create LABEL records for Truck Builder.
     C                   exsr      crtlabels
GSC A*
GSC A*     Assign Host sent dock door.
GSC AC                   if        client = gsc
GSC AC                   exsr      Upddockdr
GSCaA*
GSCaA*     Assign custom pick sequences.
GSCaAC                   call      'DFPICK'
GSCaAC                   parm                    $pwhse
GSCaAC                   parm                    $prtid
GSCaA*
GSC AC                   endif
     *
     C                   endif
     *
     C                   Eval      *inlr = *on
     *
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     C                   call      'GETCLIENT'
     C                   parm      *blanks       Client           10
     *
     C                   eval      forever = *on
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      pickdate = $cvd8o
     C                   time                    picktime
     C                   time                    pickstamp
     *
     *  Define full key for DOCDOOR
     *
     C     *like         define    dddoor        kydoor
     C     keydd         klist
     C                   kfld                    kywhse
     C                   kfld                    kydoor
     *
     *  Define partial key for OPTIONS
     *
     C     keyop         klist
     C                   kfld                    kywhse
     C                   kfld                    opcode
     *
     *  Define partial key for ORDD
     *
     C     keyod         klist
     C                   kfld                    ohwhse
     C                   kfld                    ohord
     *
     *  Define full key for ORDH
     *
     C     keyoh         klist
     C                   kfld                    $pwhse
     C                   kfld                    alord
     *
     *  Define full key for ORDH3
     *
     C     keyoh3        klist
     C                   kfld                    kywhse
     C                   kfld                    kyrtid
     *
     *  Define partial key for ORDLBL1
     *
     C     keyaL1        klist
     C                   kfld                    kywhse
     C                   kfld                    kyrtid
     *
     *  Define full key for PIRITEM
     *
     C     keyit         klist
     C                   kfld                    kywhse
     C                   kfld                    kyitem
     *
     *  Define full key for PLTSTP1
     *
     C     keypss        klist
     C                   kfld                    kywhse
     C                   kfld                    kyrtid
     C                   kfld                    kyplid
     C                   kfld                    kyrow
     C                   kfld                    kycol
     C                   kfld                    kystop
     C                   kfld                    kybsq
     *
     *  Define full key for RTECSUM
     *
     C     keyrc         klist
     C                   kfld                    kywhse
     C                   kfld                    kyrtid
     C                   kfld                    pscomp
     *
     *  Define partial key for RTEHED3.
     *
     C     keyrh3        klist
     C                   kfld                    kywhse
     C                   kfld                    kystat
     C                   kfld                    kytype
     C                   kfld                    kyrtid
     *
     *  Define full key for SLOT2
     *
     C     keysL2        klist
     C                   kfld                    kywhse
     C                   kfld                    kywhdp
     C                   kfld                    kydisp
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  CRTLABELS   Create LABEL file records from Host Label info.
     *
     C     crtlabels     begsr
     *
     C                   eval      sv_host_tran# = *loval
     C                   eval      svstop        = *loval
     C                   eval      svstop1       = 0
     C                   eval      svstop2       = 0
     C                   eval      dftpallet#    = 0
     C                   eval      svpallet#     = 0
     C                   eval      dspalletid    = dftpalletid
     C                   eval      dsunload      = 1
     C                   eval      outflag       = '*NO '
     C     keyaL1        setll     ordlbL1
     C                   dow       not %eof(ordlbL1)
     C     keyaL1        reade     ordlbL1
     *
     *    Update BFC transaction with piece counts.
     C                   if        %eof(ordlbL1)
     C                             and sv_host_tran# > 0
     C                   exsr      Crtpltsum
     C                   exsr      Crtrtecsum
     C                   exsr      Updtran
     *
     *    Update BFC Pallet stop summary file.
     C                   eval      kyplid = dspalletid
     C                   eval      kyrow  = dsrow
     C                   eval      kycol  = dscol
     C                   eval      kystop = svstop
     C                   eval      kybsq  = 0
     C                   exsr      getpss
     C                   exsr      fillpss
     C                   exsr      Updpss
     C                   endif
     *
     *
     C                   if        not %eof(ordlbL1)
AVL A*
AVL AC                   if        client = Avalon
AVL AC                   eval      alhtn_rtx = alhtrn
AVL AC                   endif
AVL A*
AVLaA*
AVLaAC                   if        client = Avalon
AVLaAC                   eval      alhfl1_rtx = alhfl1
AVLaAC                   endif
     *
     *    Get BFC item number.
     C                   if        sv_item <> alitem
     C                   eval      kyitem = alitem
     C                   exsr      getitem
     C                   eval      sv_item = alitem
     C                   endif
     *
     C                   if        sv_disp <> aldisp
     C                   eval      kywhdp = itwhdp
     C                   eval      kydisp = aldisp
     C                   eval      outflag= '*NO '
     C                   exsr      getsl2
     C                   eval      sv_disp = aldisp
     C                   endif
     *
     *    Get Host transaction number changed.
     C                   if        sv_host_tran# <> alhtr#
     *
     *    Update BFC internal transaction number totals.
     C                   if        sv_host_tran# > 0
     C                   exsr      Crtpltsum
     C                   exsr      Crtrtecsum
     C                   exsr      Updtran
     *    Update BFC Pallet stop summary file.
     C                   eval      kyplid = dspalletid
     C                   eval      kyrow  = dsrow
     C                   eval      kycol  = dscol
     C                   eval      kystop = svstop
     C                   eval      kybsq  = 0
     C                   exsr      getpss
     C                   exsr      fillpss
     C                   exsr      Updpss
     *
     *    Calculate new Pallet ID.
     C                   exsr      calcpallet
     C                   endif
     *
     *    Get new BFC internal transaction number.
     C                   exsr      gettran
     *
     *    Create new BFC internal transaction number.
     C                   exsr      crttran
     *
     *    Create Dakota / Host transaction cross-reference.
     C                   exsr      crttrnxref
     *
     C                   eval      sv_host_tran# = alhtr#
     *
JTD AC                   select
JTD AC                   when      client = gsc
     C                   eval      hostfld2ds = alhfl2
     C                   eval      svdoor     = aldockdoor
JTD AC                   when      client = jtdavenport
JTD AC                   eval      hostfld2ds = alhtrn
JTD AC                   eval      svdoor     = aldockdoor
JTD AC                   endsl
     *
     *   Host assigned pallet number.
     C                   if        alpal# > 0
     C                   eval      svpallet# = alpal#
     C                   else
     *
     *   Dakota assigned pallet number.
     C                   eval      dftpallet# = dftpallet# + 1
     C                   eval      alpal#     = dftpallet#
     C                   endif
     C                   eval      svpallet#  = alpal#
     C                   endif
     *
     *    Retrieve customer stop number from order header.
     C                   exsr      getoh
     *
     *    Update BFC Pallet stop summary file.
     C                   if        svstop <> ohstop
     C                   if        svstop > 0
     C                   eval      kyplid = dspalletid
     C                   eval      kyrow  = dsrow
     C                   eval      kycol  = dscol
     C                   eval      kystop = svstop
     C                   eval      kybsq  = 0
     C                   exsr      getpss
     C                   exsr      fillpss
     C                   exsr      Updpss
     C                   endif
     C                   eval      svstop = ohstop
     *
     *    Update stop range for Pallet Summary file.
     C                   if           ohstop < svstop1
     C                             or svstop1 = 0
     C                   eval      svstop1 = ohstop
     C                   endif
     *
     C                   if        ohstop > svstop2
     C                   eval      svstop2 = ohstop
     C                   endif
     *
     C                   endif
     *
     *    Fill LABEL fields and write record.
     C                   exsr      fillLB
     *
     *    Update ORDLBL file with Dakota tran/label nbrs.
     C                   eval      altrn# = lbtrn#
     C                   eval      allbl# = lblbl#
     C                   update    alrec
     *
     C                   endif
     *
     C                   enddo
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  CRTPLTSUM   Create PLTSUM file records.
     *
     C     crtpltsum     begsr
     *
     C                   clear                   psrec
     *
     C                   eval      pswhse = kywhse
     C                   eval      psrtid = $prtid
     C                   eval      psplid = dspalletid
     C                   eval      pscomp = 'D'
     C                   eval      pstzon = 'DFTZON'
     C                   eval      psszon = 'DFTZON'
     C                   eval      psgen  = dsgen
     C                   eval      pstruk = 'DFTTRUCK'
     C                   eval      psunld = dsunload
     C                   eval      psrow  = dsrow
     C                   eval      pscol  = dscol
     C                   eval      psmaxc = 999.99
     C                   eval      pspal# = svpallet#
     C                   eval      psstp1 = svstop1
     C                   eval      psstp2 = svstop2
     C                   eval      pstype = 'O'
     C                   eval      psbcnt = 0
     C                   eval      psflag = '0'
     C                   eval      pslbl# = 0
     C                   eval      pstrn# = lbtrn#
     *
     C                   eval      pspcs  = pspcs  + total_pcs
     C                   eval      pscube = pscube + total_cube
     C                   eval      psswgt = psswgt + total_wgt
     *
     C                   write     psrec
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  CRTRTECSUM  Create RTECSUM file records.
     *
     C     crtrtecsum    begsr
     *
     C                   eval      kydoor = svdoor
     C     keydd         chain     docdoor
     C                   if        not %found(docdoor)
     C                   clear                   ddwhdp
     C                   endif
     *
     C     keyrc         chain     rtecsum
     C                   if        not %found(rtecsum)
     C                   clear                   rcrec
     C
     C                   eval      rcwhse = $pwhse
     C                   eval      rcrtid = $prtid
     C                   eval      rcdrdp = ddwhdp
     C                   eval      rccomp = pscomp
     C
     C                   endif
     C
     C                   eval      rcpckp = rcpckp + total_pcs
     C                   eval      rcpckc = rcpckc + total_cube
     C                   eval      rcpckw = rcpckw + total_wgt
     *
     C                   if        not %found(rtecsum)
     C                   write     rcrec
     C                   else
     C                   update    rcrec
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  CRTRUNNER   Create RUNNER file record when slot not found.
     *
     C     crtrunner     begsr
     *
     C                   clear                   rurec
     *
     C                   eval      ruwhse = lbwhse
     C                   eval      rutype = 'N'
     C                   eval      ruwhdp = lbwhdp
     C                   eval      rulbl# = lblbl#
     C                   eval      ruotrn = lbtrn#
     C                   eval      rudisp = lbdisp
     C                   eval      ruoqys = lbqpck
     C                   eval      ruqyso = lbqpck
     C                   eval      rustat = 'O'
     C                   eval      ruodts = pickstamp
     *
     C                   write     rurec
     C                   if        %error
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  CRTTRAN   Create PIRTRAN file record.
     *
     C     crttran       begsr
     *
     C                   call      'ADJTRAN2'
     C                   parm      '*CREATE '    @pcmd            10
     C                   parm      #prog         @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      newtrn#       @ptrn#            7 0
     C                   parm      'FIXED '      @ptask            6
     C                   parm      alwhse        @pwhse            3 0
     C                   parm      itwhdp        @pwhdp            5
     C                   parm      itstyp        @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      1             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      $prtid        @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      'S'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      pickdate      @pdate            8 0
     C                   parm      picktime      @ptime            6 0
     C                   parm      #user         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  CRTTRNXREF   Create Dakota/Host Transaction cross-reference.
     *
     C     crttrnxref    begsr
     *
     C                   clear                   otrec
     C                   eval      otwhse = $pwhse
     C                   eval      othtr# = alhtr#
     C                   eval      ottrn# = newtrn#
     C*
     C                   write     otrec
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  CALCPALLET   Calculate next Pallet ID.
     *
     C     calcpallet    begsr
     *
     C                   eval      dscol = dscol + 1
     C                   if        dscol >= 3
530 AC                   if        dsrow < 99
     C                   eval      dsrow = dsrow + 1
530 AC                   endif
     C                   eval      dscol = 1
     C                   endif
     *
530 AC                   if        dsunload < 99
     C                   eval      dsunload = dsunload + 1
530 AC                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  FILLLB   Populate LABEL detail fields.
     *
     C     fillLB        begsr
     *
     C                   clear                   lbrec
     *
     C                   eval      lbwhse = alwhse
     C                   eval      lbwhdp = itwhdp
     C                   eval      lbseq  = alseq
     C                   eval      lbitem = alitem
     C                   eval      lbpbat = rhpbat
     C                   if        alaisl > ' '
     C                   eval      lbdisp = aldisp
     C                   eval      lbaisl = alaisl
500aAC                   eval      lbpseq = alpsq#
     C                   eval      lbloc  = alloc
     C                   eval      lbrlvl = alrlvl
     C                   eval      lbhand = alhand
     C                   else
     C                   eval      lbdisp = sldisp
     C                   eval      lbaisl = slaisl
500aAC                   eval      lbpseq = slpseq
     C                   eval      lbloc  = slloc
     C                   eval      lbrlvl = slrlvl
     C                   eval      lbhand = slhand
     C                   endif
     *
     *    Slot sent with item is invalid. Flag item as Out.
     C                   if        outflag = '*YES'
     C                   eval      lbdisp = aldisp
     C                   eval      lbasl2 = 'OUT'
     *    Create Runner entries is activated.
     C                   if        opcrtm = 'Y'
     C                   eval      lbvrfy = 'F'
     C                   endif
     C                   endif
     *
500aDC*                  eval      lbpseq = alpsq#
     C                   eval      lbstyp = slstyp
     C                   if        lbstyp = 'P'
     C                   eval      lbqryf = 1
     C                   else
     C                   eval      lbqryf = 0
     C                   endif
     C                   eval      lbrte  = $prtid
     C                   eval      lbstop = ohstop
     C                   eval      lbord  = alord
     C                   eval      lbgrp1 = 'S'
AVLaA*
AVLaAC                   if        client = Avalon
AVLaAC                   eval      lbtype = rtxalh1_lbtype
AVLaAC                   if        lbtype = ' '
AVLaAC                   eval      lbtype = 'O'
AVLaAC                   endif
AVLaA*
AVLaAC                   else
AVLaA*
     C                   eval      lbtype = 'O'
AVLaAC                   endif
AVLaA*
530aDC*                  eval      lbpal# = dftpalletid
530aMC                   eval      lbpal# = dspalletid
     C                   eval      lbtrn# = newtrn#
     C                   eval      lbstat = 'P'
     *
     *      Create label for normal quantity.
     C                   if        alqpk1 > 0
     C                   eval      lbutyp = 'N'
     C                   eval      lbucod = itum1
     C                   eval      lbucub = itcube
     C                   eval      lbcube = lbucub * alqpk1
     C                   eval      lbuwgt = itswgt
     C                   eval      lbswgt = lbuwgt * alqpk1
     C                   eval      lbqalc = alqpk1
     C                   eval      lbqpck = alqpk1
     *
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     *
     C                   eval      lbsdte = pickdate
     C                   eval      lbstim = picktime
     C                   eval      lbrdte = pickdate
     *
     C                   write     lbrec
     *
     C                   exsr      LBtotal
     *
     *    Slot sent with item is invalid. Flag item as Out.
     C                   if            outflag = '*YES'
     C                             and opcrtm = 'Y'
     C                   exsr      Crtrunner
     C                   endif
     *
     C                   endif
     *
     *      Create label for breakdown 1 quantity.
640 DC*                  if        pickq2 > 0
640 MC                   if        alqpk2 > 0
     C                   eval      lbutyp = '1'
     C                   eval      lbucod = itum2
     C                   if        itumq2 <> 0
     C                   eval (h)  lbucub = itcube / itumq2
     C                   eval      lbcube = lbucub * alqpk2
     *
     C                   eval (h)  lbuwgt = itswgt / itumq2
     C                   eval      lbswgt = lbuwgt * alqpk2
     C                   endif
     *
     C                   eval      lbqalc = alqpk2
     C                   eval      lbqpck = alqpk2
     *
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
640aA*
640aAC                   eval      lbsdte = pickdate
640aAC                   eval      lbstim = picktime
640aAC                   eval      lbrdte = pickdate
     *
     C                   write     lbrec
     *
     C                   exsr      lbtotal
     *
     *    Slot sent with item is invalid. Flag item as Out.
     C                   if            outflag = '*YES'
     C                             and opcrtm = 'Y'
     C                   exsr      Crtrunner
     C                   endif
     *
     C                   endif
     *
     *      Create label for breakdown 2 quantity.
     *
640 DC*                  if        pickq3 > 0
640 MC                   if        alqpk3 > 0
     C                   eval      lbutyp = '2'
     C                   eval      lbucod = itum3
     C                   if        itumq2 <> 0  and
     C                             itumq3 <> 0
     C                   eval (h)  lbucub = itcube / itumq2
     C                   eval (h)  lbucub = lbucub / itumq3
     C                   eval      lbcube = lbucub * alqpk3
     *
     C                   eval (h)  lbuwgt = itswgt / itumq2
     C                   eval (h)  lbuwgt = lbuwgt / itumq3
     C                   eval      lbswgt = lbuwgt * alqpk3
     C                   endif
     *
     C                   eval      lbqalc = alqpk3
     C                   eval      lbqpck = alqpk3
     *
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
640aA*
640aAC                   eval      lbsdte = pickdate
640aAC                   eval      lbstim = picktime
640aAC                   eval      lbrdte = pickdate
     *
     C                   write     lbrec
     *
     *    Accumulate transaction / stop totals.
     C                   exsr      LBtotal
     *
     *    Slot sent with item is invalid. Flag item as Out.
     C                   if            outflag = '*YES'
     C                             and opcrtm = 'Y'
     C                   exsr      Crtrunner
     C                   endif
     *
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  FILLOD   Update Order Detail record to mark as Picked.
     *
     C     fillod        begsr
     *
     C                   eval      odstat = 'P'
     *
     C*                  eval      odqpk1 = odqor1
     C*                  eval      odqpk2 = odqor2
     C*                  eval      odqpk3 = odqor3
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  FILLPSS   Update Pallet Stop Summary record.
     *
     C     fillpss       begsr
     *
     C                   select
     C                   when      not %found(pltstp1)
     C                   clear                   pssrec
     C                   eval      psswhs = kywhse
     C                   eval      pssrid = kyrtid
     C                   eval      pssrow = kyrow
     C                   eval      psscol = kycol
     C                   eval      psspli = kyplid
     C                   eval      pssbsq = kybsq
     C                   eval      pssstp = kystop
     C                   endsl
     *
530bAC                   eval      avl_pcs = 99999 - psspcs
530bAC                   if        stop_pcs > avl_pcs
530bAC                   eval      psspcs = 99999
530bAC                   else
     C                   eval      psspcs = psspcs + stop_pcs
530bAC                   endif
530bA*
530bAC                   eval      avl_cube = 9999.999 - psscub
530bAC                   if        stop_cube > avl_cube
530bAC                   eval      psspcs = 9999.999
530bAC                   else
     C                   eval      psscub = psscub + stop_cube
530bAC                   endif
530bA*
530bAC                   eval      avl_wgt = 9999999.99 - pssswt
530bAC                   if        stop_wgt > avl_wgt
530bAC                   eval      pssswt = 9999999.99
530bAC                   else
     C                   eval      pssswt = pssswt + stop_wgt
530bAC                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  FILLOH3   Update Order Header record to mark as Picked.
     *
     C     filloh3       begsr
     *
     C                   eval      ohstat = 'P'
     C                   eval      ohsdte = pickdate
     C                   eval      ohstim = picktime
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  GETITEM   Get Dakota Item Master record.
     *
     C     getitem       begsr
     *
     *   Get item master record.
     *
     C     keyit         chain     piritem
     C                   if        Not %found(piritem)
     C                   eval      itwhdp = *blanks
     C                   eval      ittype = *blanks
     C                   eval      itdesc = *blanks
     C                   eval      itstyp = *blanks
     C                   eval      itumq2 = *zeros
     C                   eval      itumq3 = *zeros
     C                   endif
     *
     *  Save information about item being picked (Item that was ordered)
     *
     C                   eval      #otype = ittype
     C                   eval      #oitem = ititem
     C                   eval      #odesc = itdesc
     C                   eval      #opdsc = itpdsc
     C                   eval      #bitem = ititem
     C                   eval      #sitem = ititem
     C                   eval      #bityp = ittype
     C                   eval      #sityp = ittype
     C                   eval      #bdesc = itdesc
     C                   eval      #bpdsc = itpdsc
     *
     *  If Contract, Alias or SSB item
     *   Then get Base item.
     *
     C                   if        ittype = 'C'  or
     C                             ittype = 'A'  or
     C                             ittype = 'S'
     C                   call      'GETBASE'
     C                   parm      itwhse        $gwhse            3 0
     C                   parm      ititem        $gitem           15
     C                   parm      ' '           #bitem
     C                   parm                    #bityp            1
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     C                   parm                    #bwhdp            5
     C                   parm                    #bstyp            1
     C                   parm                    #bum              2
     C                   parm                    #bum2             2
     C                   parm                    #bumq2            3 0
     C                   parm                    #bum3             2
     C                   parm                    #bumq3            3 0
     C                   parm      ' '           #bcitm           15
     C                   parm                    #bctyp            1
     C                   parm                    #bcdsc           30
     C                   parm                    #bcpds           15
     C                   parm                    #bcwdp            5
     C                   parm                    #bcstp            1
     C                   parm                    #bcum             2
     C                   parm                    #bcum2            2
     C                   parm                    #bcuq2            3 0
     C                   parm                    #bcum3            2
     C                   parm                    #bcuq3            3 0
     C                   parm                    #brtn             8
     C                   endif
     *
     *  If Contract, Alias or SSB item
     *   Then get Base Slot item.
     *
     C                   if        ittype = 'A'  or
     C                             ittype = 'A'  or
     C                             ittype = 'S'
     C                   call      @getsi
     C                   parm      itwhse        $gwhse
     C                   parm      ititem        $gitem
     C                   parm      ' '           #sitem
     C                   parm                    #sityp            1
     C                   parm                    #sdesc           30
     C                   parm                    #spdsc           15
     C                   parm                    #srtn            10
     C                   parm                    #smsg            60
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  GETOH     Get Dakota Customer Order Header.
     *
     C     getoh         begsr
     *
     *   Get customer order header.
     *
     C     keyoh         chain     ordh
     C                   if        not %found(ordh)
     C                   eval      ohstop = 0
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  GETRUNOPT   Get Runner options record.
     *
     C     getrunopt     begsr
     *
     *   Get Runner options.
     *
     C                   eval      opcode = '*RUNNER'
     C     keyop         chain     options
     C                   if        not %found(options)
     C                   eval      opcrtm = 'N'
     C                   else
     C                   eval      oprdata = opdata
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  GETSL2    Get Dakota Slot record.
     *
     C     getsl2        begsr
     *
     C     keysL2        chain     slot2
     C                   if        not %found(slot2)
     C                   eval      outflag= '*YES'
     C                   eval      slwhse = *zeros
     C                   eval      slwhdp = *blanks
     C                   eval      slaisl = *blanks
     C                   eval      slloc  = *zeros
     C                   eval      slrlvl = *zeros
     C                   eval      slhand = *blanks
     C                   eval      slstyp = *blanks
     C                   eval      slpseq = *zeros
     C                   eval      sldisp = *blanks
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  GETPSS   Get Dakota Pallet stop summary record.
     *
     C     getpss        begsr
     *
     C     keypss        chain     pltstp1
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  GETTRAN   Get new Dakota Transaction number.
     *
     C     gettran       begsr
     *
     C                   call      'PIRTRN#'
     C                   parm                    newtrn#
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  LBtotal   Accumulate totals for current Transaction.
     *
     C     LBtotal       begsr
     *
     *    Accumulate totals for current stop.
     C                   eval      stop_pcs  = stop_pcs + lbqpck
     C                   eval      stop_cube = stop_cube + lbcube
     C                   eval      stop_wgt  = stop_wgt + lbswgt
     *
     *    Accumulate totals for current transaction.
     C                   eval      total_pcs  = total_pcs + lbqpck
     C                   eval      total_cube = total_cube + lbcube
     C                   eval      total_wgt  = total_wgt + lbswgt
     *
     *    Accumulate totals for Route.
     C                   eval      rte_pcs  = rte_pcs + lbqpck
     C                   eval      rte_cube = rte_cube + lbcube
     C                   eval      rte_wgt  = rte_wgt + lbswgt
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  UPDOD   Update Order Detail record.
     *
     C     updod         begsr
     *
     C                   update    odrec
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  UPDOH3   Update Order Header record.
     *
     C     updoh3        begsr
     *
     C                   update    ohrec3
     *
     C                   endsr
GSC A*
GSC A*----------------------------------------------------------------
GSC A*
GSC A*  UPDDOCKDR  Update dock matrix with Host sent dock door.
GSC A*
GSC AC     upddockdr     begsr
GSC A*
GSC AC                   eval      $lcmd  = '*NEWDOOR'
GSC AC                   eval      $lprg  = #prog
GSC AC                   eval      $lwhse = $pwhse
GSC AC                   eval      $lhdte = pickdate
GSC AC                   eval      $lhtim = picktime
GSC AC                   eval      $lpass = 0
GSC AC                   eval      $ldoor = aldockdoor
GSC AC                   eval      $lwhdp = ' '
GSC AC                   eval      $lrtid = $prtid
GSC AC                   eval      $lrtec = rte_cube
GSC A*
GSC AC                   call      'DK131'
GSC AC                   parm                    $lparm
GSC A*
GSC AC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  UPDPSS   Update Pallet Stop Summary file.
     *
     C     updpss        begsr
     *
     C                   select
     C                   when      not %found(pltstp1)
     C                   write     pssrec
     *
     C                   other
     C                   update    pssrec
     *
     C                   endsl
     *
     *    Reset stop counters.
     C                   clear                   stop_pcs
     C                   clear                   stop_cube
     C                   clear                   stop_wgt
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  UPDTRAN   Update Dakota Transaction record with counts.
     *
     C     updtran       begsr
     *
     C                   call      'ADJTRAN2'
     C                   parm      '*INCTTL '    @pcmd            10
     C                   parm      #prog         @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      lbtrn#        @ptrn#            7 0
     C                   parm      'FIXED '      @ptask            6
     C                   parm      alwhse        @pwhse            3 0
     C                   parm                    @pwhdp            5
     C                   parm                    @pstyp            1
     C                   parm      total_cube    @pcube            9 3
     C                   parm      total_wgt     @pswgt            9 2
     C                   parm      total_pcs     @ppcs             5 0
     C                   parm      1             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      $prtid        @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      'S'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
     C                   parm      ' '           @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
     *
     *    Reset total counters.
     C                   clear                   total_pcs
     C                   clear                   total_cube
     C                   clear                   total_wgt
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
