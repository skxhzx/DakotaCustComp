      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  OR630B    Truck build - Loader merge build
     *  13 June 2009
     *  Jeffrey Jahnke
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520aA*    07/20/09  jj   5.20a
     *      -  bypass bulk pick records in worklblinit sr.
     *
530 A*    11/17/09  JCJ  5.30
     *      - Revised to use TRUCKH to lookup Template code for
     *        Zone references.
     *
640aA*    03/06/12  JCJ  6.40a
     *      - Ignore Tote Zones.
     *
CWD A*    04/26/16  MLB  CWD  P#01349
     *      - Enh: Re-compiled pgm. WORKLBL5 had order id, descending
     *        added to key for tote processing.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Client xxx
     *
     *    xx/xx/xx  xxx  x.xx
     *      -  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpltstp1   uf a e           k disk
     Fpltsum1   if a e           k disk
     F                                     rename(psrec:psrec1)
     Fpltsum6   uf   e           k disk
     F                                     rename(psrec:psrec6) Prefix(A)
     Fpltsum12  uf   e           k disk
     F                                     rename(psrec:psrec12) Prefix(C)
     Fpltsum3   if   e           k disk
     F                                     rename(psrec:psrec3) Prefix(F)
     Fworklbl   uf   e           k disk
     F                                     rename(lwrec:lwrec0) Prefix(B)
     Fworklbl2  uf   e           k disk
     F                                     rename(lwrec:lwrec2) Prefix(D)
     Fworklbl5a if   e           k disk
     F                                     rename(lwrec:lwrec5)
     Fworklbl6  if   e           k disk
     F                                     rename(lwrec:lwrec6) Prefix(E)
     Foptionz   if   e           k disk
     Fworkzon1  if   e           k disk
     Fzoneh     if   e           k disk
530 AFtruckh    if   e           k disk

     *----------------------------------------------------------------
     *  Client ID
     *
     D @getcl          c                   const('GETCLIENT')
     *
    A* client source entries go here.
    A /COPY QCOPYSRC,ID#RENZI

     *----------------------------------------------------------------
    A* Constants
     D tsinz           c                   const('0001-01-01-00.00.00.-
     D                                     000000')

     *----------------------------------------------------------------
     *  *PICK  -  Picking options
     *
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPNXTP  -  Next pallet number.
     *    OPBPCK  -  Bulk pick definition.
     *    OPPCUB  -  Maximum cube for PIR.
     *    OPFPAL  -  Pallets on fixed fork lift.
     *    OPFCUB  -  Maximum cube per fixed pallet.
     *    OPFSTP  -  Maximum stops per fixed pallet.
     *    OPINCL  -  Include PIR in fixed cube.
     *    OPSRCH  -  Number of previous pallets to search for space.
     *    OPFBLD  -  Fixed pallet building method.
     *                1 = By piece without concern for splitting stop.
     *                2 = By stop without splitting stop between plts.
     *    OPPBRK  -  Aisle to start new pallet.
     *    OPPBLD  -  Pallet building method.
     *                1 = By stop then slot location.
     *                2 = By slot location then stop.
     *    OPSELM  -  Selection method.
     *                1 = Single pass (By location).
     *                2 = Multiple pass (By stop).
     *    OPSPLT  -  Allow stop to be split across pallets (Y/N).
     *    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
     *    OPNWPL  -  Start new pallet when aisle changes if build method
     *               is 2=Location.
     *    OPFORD  -  Maximun orders per pallet.
     *    OPPTYP  -  Pallet type (P=Pallet, T=Tote).
     *    OPFTOT  -  Maximum totes per pallet.
     *    OPTECB  -  External tote cube.
     *    OPTICB  -  Internal tote cube.
     *    OPTSTP  -  Maximum stops per tote.
     *    OPTPCS  -  Maximum pieces per tote.
     *    OPSTOP  -  Honor *SP flag (Y=Yes, N=No).
     *    OPGCDE  -  USF Group Code (0-9).
     *    OPPKUP  -  Picked up by (S=Selector, L=Loader).
     *    OPSPAL  -  Merge pallet should only contain
     *               items for single truck pallet (Y=Yes, N=No).
     *
     * Data structure
     *
     D opzdta          ds
     D  opnxtp                 1      7  0 inz(0)
     D  oppcub                10     14  2 inz(0)
     D  opfpal                15     15  0 inz(0)
     D  opfcub                16     20  2 inz(0)
     D  opincl                22     22
     D  opsrch                23     24  0 inz(0)
     D  opfstp                25     26  0 inz(0)
     D  opfbld                27     27  0 inz(0)
     D  opbpck                28     30  0 inz(0)
     D  oppbrk                31     33
     D  oppbld                34     34
     D  opselm                35     35
     D  opsplt                36     36
     D  opbmrg                37     37
     D  opnwpl                38     38
     D  opford                39     40  0 inz(0)
     D  opptyp                41     41
     D  opftot                42     43  0 inz(0)
     D  optecb                44     48  2 inz(0)
     D  opticb                49     53  2 inz(0)
     D  optstp                54     55  0 inz(0)
     D  optord                56     57  0 inz(0)
     D  optpcs                58     60  0 inz(0)
     D  opstop                61     61
     ** Note: Pos 62 is OPGCDE for USF, but OPPKUP for all other clients.
     D**opgcde                62     62
     D  oppkup                62     62
     D  opspal                63     63
     D  opdend               117    117

     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')

     *----------------------------------------------------------------
     *  Called program parameters
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
     *  Pallet id data structure
     *
     *    DSPLID  -  Pallet id.
     *    DSPLXX  -  Unused.
     *    DSPLGN  -  Generation.
     *    DSPLRW  -  Pallet row.
     *    DSPLCL  -  Pallet column.
     *    DSPLSQ  -  Sequence number.
     *               Equal to zero     - Only one pallet in this position.
     *               Greater than zero - Multiple pallets in this position.
     *
     *
     D pltid           ds
     D  dsplid                 1      7  0 inz(0)
     D  dsplxx                 1      2  0
     D  dsplgn                 3      3  0
     D  dsplrw                 4      5  0
     D  dsplcl                 6      6  0
     D  dsplsq                 7      7  0

     *----------------------------------------------------------------
     * Work variables
     *----------------------------------------------------------------
     D today           s              8  0
     D tran            s              7  0
     D lstcl2          s              2  0
     D i               s              1  0
     D forevr          s              1
     D postn2          s              1
     D first1          s              1
     D lblflg          s              1
     D first           s              1
     D done            s               n
     D kycode          s                   like(opzcod)
     D kytype          s                   like(pstype)
     D kyunld          s                   like(psunld)
     D kyptyp          s                   like(lwtype)
     D kymtyp          s                   like(lwtype)
     D kyzone          s                   like(opzzon)
     D kycol           s                   like(pscol)
     D kyrow           s                   like(psrow)
     D mrgzon          s                   like(opzzon)
     D lstrw2          s                   like(psrow)
     D lstul2          s                   like(pspal#)
     D lastlwpal#      s                   like(pspal#)
     D curMaxPltCube   s                   like(opfcub)
     D parentzone      s                   like(zhpzon)
     D lststp          s                   like(psstp1)
     D ttlcub          s                   like(psscub)
     D ttlpcs          s                   like(psspcs)
     D ttlwgt          s                   like(pssswt)
530 AD $ptmpl          s             10

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PRTID  Route id
     *      $PTRUK  Truck
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $ptruk           10
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      kytype = 'O'
     C     keyps3        setll     pltsum3
     C                   dow       forevr = forevr
     C     keyps3        reade     pltsum3                                79
     C                   if        *in79
     C                   leave
     C                   endif
     *
520aA*  Bypass bulk pick records
     *
520aAC                   if        fpsbcnt <> *zeros
520aAC                   iter
520aAC                   endif
     *
     *  GETOPT  Get picking options for zone.
     *
     C                   exsr      getopt

     C                   if        oppkup = 'L'
     C                             and opspal = 'Y'
640aAC                             and opptyp <>'T'
     C                   eval      mrgzon = fpsszon
     C                   exsr      pltsumpurge
     C                   exsr      worklblinit
     C                   exsr      loader
     C                   endif
     C     keyps3a       setgt     pltsum3
     C                   enddo
     *
     C                   eval      *inlr = *on
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
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     *
     *  Define partial key for WRKLBL2 file.
     *
     C     keylw2        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    fpscomp
     C                   kfld                    fpstzon
     C                   kfld                    fpsgen
     C                   kfld                    fpsszon
     *
     C                   eval      kymtyp = 'M'
     C     keylw5        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kymtyp
     *
     *  Define partial key for WORKLBL6 file.
     *
     C     keylw6        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    psplid
     *
     *  Define full key for PLTSUM1 file.
     *
     C                   eval      kyptyp = 'O'
     C     keyps         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    zwcomp
     C                   kfld                    zwtzon
     C                   kfld                    zwgen
     C                   kfld                    zwszon
     C                   kfld                    kyptyp
     C                   kfld                    kyunld
     C                   kfld                    kyrow
     C                   kfld                    kycol
     *
     *  Define partial key for PLTSUM1 file.
     *
     C     keyps1        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    zwcomp
     C                   kfld                    zwtzon
     C                   kfld                    zwgen
     C                   kfld                    zwszon
     C                   kfld                    kyptyp
     *
     *  Define partial key for PLTSUM2 file.
     *
     C     keyps6        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    fpsszon
     *
     C     keyps12       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    tran
     C                   kfld                    psplid
     *
     *  Define partial key for PLTSTP1 file.
     *
     C     keypt2        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    fpsplid
     *
     C     keypt2a       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    psplid
     C                   kfld                    pssrow
     C                   kfld                    psscol
     C                   kfld                    pssstp
     C                   kfld                    pssbsq
     *
     *  Define partial key for PLTSUM3 file.
     *
     C     keyps3        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kytype
     *
     C     keyps3a       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kytype
     C                   kfld                    fpscomp
     C                   kfld                    fpstzon
     C                   kfld                    fpsgen
     C                   kfld                    fpsszon
     *
     *  Define partial key for options file.
     *
     C     keyopz        klist
     C                   kfld                    kycode
     C                   kfld                    $pwhse
530 D ***                kfld                    $ptruk
530 MC                   kfld                    $ptmpl
     C                   kfld                    kyzone
     *
     *  Define  key for ZONEH file.
     *
     C     keyzh         klist
     C                   kfld                    $pwhse
530 D ***                kfld                    $ptruk
530 MC                   kfld                    $ptmpl
     C                   kfld                    kyzone
     *
     *  Define key for WORKZON1 file.
     *
     C     keyzw1        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    mrgzon
530 A*
530 A*  Define key for TRUCKH file.
530 A*
530 AC     keyth         klist
530 AC                   kfld                    $pwhse
530 AC                   kfld                    $ptruk
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
530 A*
530 A* Get Zone Template Code if Template type is T=Truck
530 A*
530 AC     keyth         chain     truckh
530 AC                   if        %found(truckh)
530 AC                             and thtype = 'T'
530 AC                   eval      $ptmpl =  thztmp
530 AC                   else
530 AC                   eval      $ptmpl =  $ptruk
530 AC                   endif
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  GETOPT  Get picking options for zone.
     *
     C     getopt        begsr
     *
     C                   eval      kycode = '*PICK   '
     C                   eval      kyzone = fpsszon
     C     keyopz        chain     optionz
     C                   if        not %found(optionz)
     C                   eval      opfpal = 1
     C                   eval      opfcub = 64
     C                   eval      opfstp = 99
     C                   eval      oppbld = *on
     C                   eval      oppkup = *blanks
     C                   eval      opspal = 'N'
     C                   endif
     *
     C                   eval      curMaxPltCube    = opfcub
     *
     C                   eval      parentzone = *blanks
     C     keyzh         chain     zoneh
     C                   if        %found(zoneh)
     C                             and oppkup = 'L'
     C                             and opspal = 'Y'
     C                   eval      parentzone = zhpzon
     C                   endif
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  PltstpPurge  Delete existing pallet stop summary records.
     *
     C     PltstpPurge   begsr
     *
     C     keypt2        setll     pltstp1
     C                   dow       forevr = forevr
     C     keypt2        reade     pltstp1                                78
     C                   if        %eof(pltstp1)
     C                   leave
     C                   else
     C                   delete    pssrec
     C                   endif
     C                   enddo
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  PltsumPurge  Delete existing pallet summary records.
     *
     C     PltsumPurge   begsr
     *
     *  Delete existing pallet records.
     *
     C     keyps6        setll     pltsum6
     C                   dow       forevr = forevr
     C     keyps6        reade     pltsum6
     C                   if        %eof(pltsum6)
     C                   leave
     C                   else
520aA*
520aAC                   if        apstype <> 'O'
520aAC                   iter
520aAC                   endif
520aA*
520aAC                   if        apsbcnt <> *zeros
520aAC                   iter
520aAC                   endif
520aA*
     C                   delete    psrec6
     C                   exsr      pltstppurge
     C                   endif
     C                   enddo
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  worklblinit  Initialize worklbl for zone.
     *
     C     worklblinit   begsr
     *
     *  clear ZWPAL#
     *
     C     keylw2        setll     worklbl2
     C                   dow       forevr = forevr
     C     keylw2        reade     worklbl2
     C                   if        %eof(worklbl2)
     C                   leave
     C                   endif
520aA*
520aAC                   if        dlwtype <> 'M'
520aAC                   iter
520aAC                   endif
520aA*
520aAC                   if        dlwwhdp =  '*BULK'
520aAC                   iter
520aAC                   endif
520aA*
     C                   eval      Dlwpal# = 0
     C                   update    lwrec2
     C                   enddo
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  loader
     *
     C     loader        begsr
     *
     C     keylw5        setll     worklbl5a
     C                   dow       forevr = forevr
     C     keylw5        reade     worklbl5a
     C                   if        %eof(worklbl5a)
     C                   leave
     C                   endif

     C                   if        lwtype <> 'M'
     C                   iter
     C                   endif

     C                   if        lwszon <> parentzone
     C                   iter
     C                   endif

     C                   if        mrgzon <> %trim(lwwhdp) + %trim(lwstyp)
     C                   iter
     C                   endif

     C                   if        lwpal# <> lastlwpal#
     C     keyzw1        chain     workzon1
     C                   exsr      getplt
     C                   endif

     C     lwctr#        chain     worklbl
     C                   if        %found(worklbl)
     C                   eval      Blwpal# = psplid
     C                   update    lwrec0
     C                   exsr      stpsum

     C     keyps12       chain     pltsum12
     C                   if        %found(pltsum12)
     C                   add       lwqalc        cpspcs
     C                   add       lwcube        cpscube
     C                   add       lwswgt        cpsswgt
     C                   update    psrec12
     C                   endif
     C                   endif

     C                   enddo

     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETPLT  Get pallet.
     *
     C     getplt        begsr
     *
     C                   dow       forevr = forevr
     *
     C                   if        lwpal# <> lastlwpal#
     C                   eval      lastlwpal# = lwpal#
     C                   eval      dsplid = lwpal#
     C                   eval      kyrow = dsplrw
     C                   eval      kycol = dsplcl
     C     keyps         setll     pltsum1
     C                   endif
     *
     *   Get next pallet.
     *
     C     keyps1        reade     pltsum1
     *
     *     If one doesn't exist, create it then loop around and get it.
     *
     C                   if        %eof(pltsum1)
     C                   exsr      crtplt
     C                   if        done
     C                   leave
     C                   endif
     C                   endif

     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CRTPLT  Create new pallet.
     *
     C     crtplt        begsr
     *
     *      Add new row.
     *
     C                   clear                   psrec1
     C                   eval      pswhse = $pwhse
     C                   eval      psrtid = $prtid
     C                   eval      pstruk = $ptruk
     C                   eval      pstzon = zwtzon
     C                   eval      pspzon = zwpzon
     C                   eval      psszon = zwszon
     C                   eval      pscomp = zwcomp
     C                   eval      psgen = zwgen
     C                   eval      pscol = kycol
     C                   eval      psrow = kyrow

     C                   eval      psmaxc = curMaxPltCube
     C                   eval      psunld = 0
     C                   eval      pspal# = psunld

     *    Child pallets are always sequenced sequentially.

     C                   if        zwgen > 1
     C                   eval      lstul2 = lstul2 + 1
     C                   eval      pspal# = lstul2
     C                   endif

     C                   eval      pstype = 'O'
     C                   eval      psbcnt = 0
     C                   eval      psflag = *on
     C                   eval      pspcs = 0
     C                   eval      pscube = 0
     C                   eval      psswgt = 0
     C                   eval      psstp1 = 0
     C                   eval      psstp2 = 0
     *
     C                   eval      dsplsq = 0
     C                   eval      dsplcl = pscol
     C                   eval      dsplrw = psrow
     C                   eval      dsplgn = psgen
     C                   eval      dsplxx = 0
     C                   eval      psplid = dsplid
     *
     C                   eval      done = *off
     *
     C                   for       i = 1 to 9
     C     keyps12       chain     pltsum12
     C                   if        not %found(pltsum12)
     C                   write     psrec1
     C                   eval      done = *on
     C                   leave
     C                   else
     C                   eval      psplid = psplid + 1
     C                   endif
     C                   endfor
     *
     C                   eval      kyunld = psunld
     C                   eval      kyrow = psrow
     C                   eval      kycol = pscol
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  STPSUM  Create stop summary records for truck pallets.
     *
     C     stpsum        begsr
     *
     *        Initialize stop summary fields with pallet info.
     *
     C                   eval      psswhs = pswhse
     C                   eval      pssrid = psrtid
     C                   eval      pssrow = psrow
     C                   eval      psscol = pscol
     C                   eval      psspli = psplid
     C                   eval      dsplid = psplid
     C                   eval      pssbsq = dsplsq
     *
     *        Loop through label records for pallet.
     *
     C                   eval      first = *on
     C                   eval      lblflg = *off
     C                   eval      ttlcub = 0
     C                   eval      ttlwgt = 0
     C                   eval      ttlpcs = 0
     C     keylw6        setll     worklbl6
     C                   dow       forevr = forevr
     C     keylw6        reade     worklbl6                               78
     C                   if        *in78
     C                   leave
     C                   endif
     *
     *          First time through initialization.
     *
     C                   if        first = *on
     C                   eval      first = *off
     C                   eval      lststp = elwstop
     C                   endif
     *
     *          Create stop summary record when stop changes.
     *
     C                   if        elwstop <> lststp
     *
     C                   eval      pssstp = lststp
     C     keypt2a       chain     pltstp1
     C                   if        %found(pltstp1)
     C                   eval      psspcs = ttlpcs
     C                   eval      psscub = ttlcub
     C                   eval      pssswt = ttlwgt
     C                   update    pssrec
     C                   else
     C                   write     pssrec
     C                   endif

     C                   eval      lststp = elwstop
     C                   eval      lblflg = *off
     C                   eval      ttlcub = 0
     C                   eval      ttlwgt = 0
     C                   eval      ttlpcs = 0
     C                   endif
     *
     *          Add label amounts to totals.
     *
     C                   eval      lblflg = *on
     C                   add       elwcube       ttlcub
     C                   add       elwswgt       ttlwgt
     C                   add       elwqalc       ttlpcs
     *
     C                   enddo
     *
     *       Create last stop summary record for pallet.
     *
     C                   if        lblflg = *on
     *
     C                   eval      pssstp = lststp
     C                   eval      psspcs = ttlpcs
     C                   eval      psscub = ttlcub
     C                   eval      pssswt = ttlwgt
     C     keypt2a       chain     pltstp1
     C                   if        %found(pltstp1)
     C                   eval      psspcs = ttlpcs
     C                   eval      psscub = ttlcub
     C                   eval      pssswt = ttlwgt
     C                   update    pssrec
     C                   else
     C                   write     pssrec
     C                   endif
     C                   endif
     *
     C                   endsr
