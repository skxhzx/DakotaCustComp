      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave #203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RH156     FTP Export closed customer orders - Lucas Export
     *  March 27, 2012
     *  Rod Roller
     *
     *  This program is a heavily modified version of RH155 to only
     *  write export records to Agar/Lucas Export file.
     *
     *----------------------------------------------------------------
     *  Revisions
     *  Notes
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  78        - EOF for ORDH
     *  79        - EOF for ORDD
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fordh3     if   e           k disk
     Fordhm     if   e           k disk
     Fordd      if   e           k disk
     Forddm     if   e           k disk
     Fordc      if   e           k disk
     Fordt      if   e           k disk
     Fordbox    if   e           k disk
     Fordexpdte if   e           k disk
     Fpiritem   if   e           k disk
     Fitemext1  if   e           k disk
     Fpirtran   if   e           k disk
     Frtehed    if   e           k disk
     Fpltsum15  if   e           k disk
     Flabel90   if   e           k disk
     F                                     rename(lbrec:lbrec9)
     Foptions   if   e           k disk
     Flucasexpf o  a e           k disk    usropn
     *----------------------------------------------------------------
     *  Customer id
     *
      /copy qcopysrc,id#agar
     *
     *----------------------------------------------------------------
     *  Working variables
     *
     D error           s              1
     D expdate         s              8  0
     D exptime         s              6  0
     D today           s              8  0
     d loadwhse        s              3a   inz('306')
     d wrkpal          s              8s 0
     d savaisle        s              3a
     d savbay          s              3s 0
     d savslot         s              2s 0
     d worktrans       s              7s 0
     d workpal         s              7s 0
     d workrow         s              2s 0
     d workcol         s              1s 0
     d workqpck        s              5s 0
     *----------------------------------------------------------------
     *  Constants
     *
     D forevr          c                   const('1')
     D editw2          c                   '0  '
     D editw7          c                   '0       '
     D editw8          c                   '0        '
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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
     *
     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------
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
     D  $lrtid                22     26
     D  $ltrn#                27     33  0
     D  $lwhdp                34     38
     D  $ldoor                39     41  0
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PRTID  Route ID
     *      $PRTE   Route
     *
     *    Returned Parameters
     *      $PRTN   *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $prte             5
     C                   parm                    $prtn             8
     *
     * Main line
     *
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     *
     *  Skip if not Agar.
     C                   if        client <> agar
     C                   goto      bottom
     C                   endif
     *
     *  Get order Header record.
     *
     C     keyoh         setll     ordh3
     C                   dou       forevr <> forevr
     C     keyoh         reade     ordh3                                  79
     C                   if        *in79
     C                   leave
     C                   endif                                                  if *in79
     *
     *  Get Order Header Misc. record.
     C                   exsr      zzgethm
     *
     *  Get Route Header record.
     C                   exsr      zzgetrh
     *
     *  Process Order Detail records.
     *
     C     keyod         setll     ordd
     C                   dou       forevr <> forevr
     C     keyod         reade     ordd                                   78
     C                   if        *in78
     C                   leave
     C                   endif                                                  if *in78
     *
     *  Get Order Detail Misc. record.
     C                   exsr      zzgetdm
     *
     *  Get Item Master record.
     C                   exsr      zzgetit
     *
     *  Get Item Extension record.
     C                   exsr      zzgetim
     *
     *  Process Order Transaction records.
     *
     C     keyot         setll     ordt
     C                   dou       forevr <> forevr
     C     keyot         reade     ordt                                   77
     C                   if        *in77
     C                   leave
     C                   endif                                                  if *in77
     *
     *  Get Label record.
     C                   exsr      zzgetlb
     *
     *  Get Dock Door.
     C                   exsr      zzdockdoor
     *
     *  Get Transaction record.
     C                   exsr      zzgetpt
     *
     *  Get Pallet Summary record.
     C                   exsr      zzgetps
     *
     *  Create Agar Lucas export detail record.
     C                   exsr      lucasdtl
     *
     C                   enddo                                                  ordt loop
     *
     C                   enddo                                                  ordd loop
     *
     C                   enddo                                                  ordh loop
     *
     C     bottom        tag
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     *
     *   Define partial key for ORDD file.
     *
     C     keyod         klist
     C                   kfld                    ohwhse
     C                   kfld                    ohord
     *
     *   Define partial key for ORDT file.
     *
     C     keyot         klist
     C                   kfld                    odwhse
     C                   kfld                    odord
     C                   kfld                    odseq
     C                   kfld                    oditem
     *
     *   Define full key for ORDHM file.
     *
     C     keyhm         klist
     C                   kfld                    ohwhse
     C                   kfld                    ohord
     *
     *   Define full key for ORDDM file.
     *
     C     keydm         klist
     C                   kfld                    odwhse
     C                   kfld                    odord
     C                   kfld                    odseq
     C                   kfld                    oditem
     *
     *   Define full key for PIRITEM file.
     *
     C     keyit         klist
     C                   kfld                    odwhse
     C                   kfld                    oditem
     *
     *   Define full key for ITEMEXT file.
     *
     C     keyim         klist
     C                   kfld                    odwhse
     C                   kfld                    oditem
     *
     *   Define full key for LABEL90 file.
     *
     C     keylb         klist
     C                   kfld                    otwhse
     C                   kfld                    ottrn#
     C                   kfld                    otlbl#
     *
     *   Define  key for ORDH3 file.
     *
     C     keyoh         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
     *   Define partial key for LABEL90 file.
     *
     C     keylb9        klist
     C                   kfld                    otwhse
     C                   kfld                    ottrn#
     *
     *  Define partial key for OPTIONS file.
     *
     C     keyop         klist
     C                   kfld                    $pwhse
     C                   kfld                    opcode
     *
     *   Define full key for PLTSUM4 file.
     *
     C     keyps         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbrte
     C                   kfld                    lbpal#
     *
     *   Define full key for RTEHED file.
     *
     C     keyrh         klist
     C                   kfld                    ohwhse
     C                   kfld                    ohrte
     *
     *    Open client-specific files.
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   eval      expdate = today
     C                   time                    exptime
     *
     * Open EXPSAP Export File for Agar/Lucas.
     *
     C                   if        client = agar
     C                             and not %open(lucasexpf)
     C                   open      lucasexpf
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  LUCASDTL      Write Lucas Detail Record
     *
     C     lucasdtl      begsr
     *
     C                   eval      lexrecid = %subst(ommsc1:11:6)
     C                   eval      lexroute = rhrte
     C                   eval      lexstop  = %char(ohstop)
     C                   eval      lexshpdt = %subst(hmmsc4:33:8)
     C                   eval      lexdsptm = %subst(hmmsc4:1:6)
     C                   eval      lexwktyp = *blanks
     C                   eval      lexassgn = %char(lbtrn#)
     C                   eval      lexcusno = %char(ohcust)
     C                   eval      lexcusna = ohcnam
     C                   eval      lexaddr1 = ohcad1
     C                   eval      lexaddr2 = ohcad2
     C                   eval      lexcity  = ohccty
     C                   eval      lexstate = ohcst
     C                   eval      lexzipcd = ohczip
     C                   eval      lexcntry = %subst(hmmsc4:30:3)
     C                   eval      lexcnti1 = %subst(hmmsc2:1:10)
     C                   eval      lexcnti2 = %subst(hmmsc2:11:10)
     C                   eval      lexaudpc = %subst(hmmsc4:7:3)
     C                   eval      lexornum = %subst(ommsc1:1:10)
     C                   eval      lexpksel = itwhdp
     C                   eval      lexwhse  = loadwhse
     C                   eval      lexchkst = *blanks
     C                   eval      lexseqnm = *blanks
     C                   eval      lexitmnm = ititem
      *
     C                   eval      xlatecmd = '*SPCL2SPC'
     C                   eval      xlatein = itdesc
     C                   call      'VOXLATE'
     C                   parm                    xlatecmd         10
     C                   parm                    xlatein         500
     C                   parm                    xlateout        500
     C                   eval      lexitdsc = xlateout
      *
     C                   eval      lexitcub = %char(itcube)
     C                   if        itcwgt = 'Y'
     C                   eval      lexcapcw = '1'
     C                   else
     C                   eval      lexcapcw = '0'
     C                   endif
     C                   eval      lexenfcw = %subst(ikmsc1:1:1)
     C                   eval      lexpawgt = %subst(ikmsc1:2:1)
     C                   eval      lexexpdt = %subst(ikmsc1:33:1)
     C                   eval      lexenfdt = %subst(ikmsc1:34:1)
     C                   eval      lexexpdf = %subst(ikmsc1:35:1)
     C                   eval      lexdyexp = %subst(ikmsc1:36:3)
     C                   eval      lexupcfl = %subst(ikmsc1:39:1)
      *
     C                   eval      lexupccf = %subst(ikmsc2:1:4)
     C                   eval      lexitmpr = %subst(ikmsc2:5:9)
     C                   eval      lexupc1  = %subst(ikmsc2:14:20)
      *
     C                   eval      lexupc2  = %subst(ikmsc3:1:20)
     C                   eval      lexupc3  = %subst(ikmsc3:21:20)
      *
     C                   eval      lexminwg = %subst(ommsc4:1:8)
     C                   eval      lexmaxwg = %subst(ommsc4:9:8)
     C                   eval      lexamnwg = %subst(ommsc4:17:8)
     C                   eval      lexamxwg = %subst(ommsc4:25:8)
     C                   eval      lexavgwg = %subst(ommsc4:33:8)
      *
     C                   eval      xlatecmd = '*SPCL2SPC'
     C                   eval      xlatein = %subst(ommsc2:1:25)
     C                   call      'VOXLATE'
     C                   parm                    xlatecmd         10
     C                   parm                    xlatein         500
     C                   parm                    xlateout        500
     C                   eval      lexcommd = xlateout
      *
     C                   eval      lexvndcd = %subst(ikmsc4:1:20)
     C                   eval      lexpcksz = itpdsc
     C                   if        odqor2 > 0
     C                   eval      lexqtyor = %char(lbqpck)
     C                   eval      lexuom   = itum2
     C                   if        lexuom   = *blank
     C                   eval      lexuom   = 'PC'
     C                   endif
     C                   else
     C                   eval      lexqtyor = %char(lbqpck)
     C                   eval      lexuom   = itum1
     C                   if        lexuom   = *blank
     C                   eval      lexuom   = 'CS'
     C                   endif
     C                   endif
     C                   eval      lexlbelb = %char(lblbl#)
     C                   eval      lexdrvcd = %subst(hmmsc4:10:10)
     C                   eval      lexdrvnm = %subst(hmmsc3:1:30)
     C                   eval      lextrlnm = %subst(hmmsc4:20:10)
     C                   eval      lexdokdr = %char($ldoor)
     C                   eval      lexpirpk = %subst(ikmsc2:34:1)
     C                   eval      lexrtnam = %subst(hmmsc1:1:25)
     C                   eval      lexascub = %char(%inth(ptcube))
     C                   eval      lexisflw = %subst(ikmsc2:35:1)
     C                   eval      lexlbzon = psszon
     C                   eval      lexlbtyp = pstype
     C                   eval      lexlbmrg = psszon
     C                   eval      lexlbcmp = pscomp
     C                   eval      lexlbctr = %char(lbctr#)
     *
     *  only write recs with no corresponding label
     C                   if        lbctr# = 0
     *
     C                   if        psgen = 1
     C                   eval      lexlbztp = 'Truck'
     C                   eval      worktrans = lbtrn#
     *
     **** Computed pallet must match PS311, if changed change PS311 also
     C                   eval      wrkpal = (%dec(rhrtid:5:0)*1000)
     C                             + (psrow*10) + pscol
     C                   eval      lexlbepl = %trim(%editw(wrkpal:editw8))
     *
     C                   eval      lexaisle = %subst(ommsc3:1:2)
     C                   eval      lexbay   = %subst(ommsc3:3:2)
     C                   eval      lexslot  = %subst(ommsc3:5:2)
     C                   write     lucexpr
     *
     C                   else
     *
     *  handle multiple pics for merge records
      /free
         // get trans numbers from non-merge picks
         Exec sql Declare C1 Cursor For
                    Select LBTRN#, LBQPCK
                      from LABEL
                     where LBCTR# = :lblbl#;
         Exec sql Open C1;

         Exec sql Fetch C1 into :worktrans, :workqpck;
         dow SQLSTT = '00000';
           lexassgn = %char(worktrans);

           // get pallet info from non-merge pallet
           Exec sql Select PSPAL#, PSROW, PSCOL
                      into :workpal, :workrow, :workcol
                      from PLTSUM
                     where PSTRN# = :worktrans;
           if SQLSTT = '00000';
             pspal# = workpal;
             psrow = workrow;
             pscol = workcol;
           endif;

           lexlbztp = 'Stage';
           lexqtyor = %char(workqpck);

           // Computed pallet must match PS311, if changed change PS311 also
           wrkpal = (%dec(rhrtid:5:0)*1000) + (psrow*10) + pscol;
           lexlbepl = %trim(%editw(wrkpal:editw8));

           lexaisle = %subst(ommsc3:1:2);
           lexbay   = %subst(ommsc3:3:2);
           lexslot  = %subst(ommsc3:5:2);
           write lucexpr;

           Exec sql Fetch C1 into :worktrans, :workqpck;
         enddo;

         Exec sql Close C1;

      /end-free
     C                   endif                                                  psgen = 1
     C                   endif                                                  lbctr# = 0
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZDOCKDOOR Get Dock Door.
     *
     c     zzdockdoor    begsr
     *
     C                   eval      $lwhse = lbwhse
     C                   eval      $lrtid = lbrte
     C                   eval      $ltrn# = lbtrn#
     C                   eval      $lwhdp = lbwhdp
     C                   eval      $ldoor = 0
     C                   call      'DH900'
     C                   parm                    $lparm
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGETDM    Get Order Detail Misc. file.
     *
     C     zzgetdm       begsr
     *
     C     keydm         chain     orddm
     C                   if        not %found(orddm)
     C                   eval      ommsc1 = *blanks
     C                   eval      ommsc2 = *blanks
     C                   eval      ommsc3 = *blanks
     C                   eval      ommsc4 = *blanks
     C                   eval      ommsc5 = *blanks
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGETHM    Get Order Header Misc. file.
     *
     C     zzgethm       begsr
     *
     C     keyhm         chain     ordhm
     C                   if        not %found(ordhm)
     C                   eval      hmmsc1 = *blanks
     C                   eval      hmmsc2 = *blanks
     C                   eval      hmmsc3 = *blanks
     C                   eval      hmmsc4 = *blanks
     C                   eval      hmmsc5 = *blanks
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGETIM    Get Item Misc. record.
     *
     c     zzgetim       begsr
     *
     C     keyim         chain     itemext1
     C                   if        not %found(itemext1)
     C                   eval      ikmsc1 = *blanks
     C                   eval      ikmsc2 = *blanks
     C                   eval      ikmsc3 = *blanks
     C                   eval      ikmsc4 = *blanks
     C                   eval      ikmsc5 = *blanks
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGETIT    Get Item Master file.
     *
     C     zzgetit       begsr
     *
     C     keyit         chain     piritem
     C                   if        not %found(piritem)
     C                   eval      itum1  = *blanks
     C                   eval      itumq2 = 0
     C                   eval      itum2  = *blanks
     C                   eval      itflg1 = 'N'
     C                   eval      itumq3 = 0
     C                   eval      itflg2 = 'N'
     C                   eval      itcwgt = 'N'
     C                   eval      itswgt = 0
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGETLB    Get Label record.
     *
     c     zzgetlb       begsr
     *
     C     keylb         chain     label90
     C                   if        not %found(label90)
     C                   eval      lblbl# = 0
     C                   eval      lbpal# = 0
     C                   eval      lbtrn# = 0
     C                   eval      lbdisp = *blanks
     C                   eval      lbcube = 0
     C                   eval      lbqpck = 0
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGETRH    Get Route Header record.
     *
     c     zzgetrh       begsr
     *
     C     keyrh         chain     rtehed
     C                   if        not %found(rtehed)
     C                   eval      rhrte  = 'ERROR'
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGETPS    Get Pallet Summary record.
     *
     c     zzgetps       begsr
     *
     C     keyps         chain     pltsum15
     C                   if        not %found(pltsum15)
     C                   eval      pscomp = *blank
     C                   eval      psszon = *blank
     C                   eval      pstype = *blank
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGETPT    Get Transaction record.
     *
     c     zzgetpt       begsr
     *
     C     lbtrn#        chain     pirtran
     C                   if        not %found(pirtran)
     C                   eval      ptcube = 0
     C                   endif
     *
     C                   endsr
     *
