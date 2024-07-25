     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TB130    Write TOTEBUND records
     *  07 April 2010
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
530 A*    04/07/10  RBD  5.30
     *      - Created.
     *      - Client custom code support included.
640aA*    03/18/12  JCJ  6.40a
     *      - Revised to use TRUCKH to lookup Template code for
     *        Zone references.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
xxx A*    mm/dd/yy  iii  ccc
     *      -
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Flabel     if   e           k disk
     Flabel90   if   e           k disk    prefix(l90_)
     F                                     rename(lbrec:lbrec90)
     Foptionz   if   e           k disk
     Fpltsum3   if   e           k disk
     Fpltsum12  if   e           k disk    prefix(p12_)
     F                                     rename(psrec:psrec12)
     Fzoneg1    if   e           k disk
640aAFtruckh    if   e           k disk
     Ftotebund  o  a e           k disk
     *----------------------------------------------------------------
     *  Customer id
     *
     *
     *----------------------------------------------------------------
     *  Working variables
     *
     D error           s              1
     D kycod1          s                   like(opzcod)
     D today           s              8  0
640aAD $ptruk          s             10
640aAD $ptmpl          s             10
     *----------------------------------------------------------------
     *  Constants
     *
     D forever         c                   const('1')
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
     *  OPTIONZ data structure
     *
     D opzdta          ds
     D  opzend               117    117
     *
     *  *PICK  -  Picking options
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
     *                3 = By descening stop, then slot location.
     *    OPSELM  -  Selection method.
     *                1 = Single pass (By location).
     *                2 = Multiple pass (By stop).
     *    OPSPLT  -  Allow stop to be split across pallets (Y/N).
     *    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
     *    OPNWPL  -  Start new pallet when aisle changes if build method
     *               is 2=Location.
     *    OPFORD  -  Maximun orders per pallet.
     *    OPPTYP  -  Pallet type (P=Pallet, T=Tote, B=Batch).
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
     *    OPPITM  -  Maximum items per pallet.
     *
     * Data structure
     *
     D opdta1          ds
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
     D  oppitm                64     67  0 inz(0)
     D  opend1               117    117
     *----------------------------------------------------------------
     * Data structure
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
     * Main line
     *
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   exsr      zzinz2
     *
     *  Process Pallet Summary file.
     *
     C     keyps3        setll     pltsum3
     C                   dow       forever = forever
     C     keyps3        reade     pltsum3
     *
     C                   if        %eof(pltsum3)
     C                   leave
     C                   endif
     *
     *      Omit pallet records with no transaction assigned
     *      or not gen 1 (only want totes)
     *      or nothing was picked.
     C                   if            pstrn# = 0
     C                              or psgen <> 1
     C                              or pspcs  = 0
     C                   iter
     C                   endif
     *
     *      Get individual tote transactions and write tote and
     *      bundle count record for each tote.
     C                   exsr      getToteTrans
     *
     C                   enddo
     *
     C     bottom        tag
     *
     C                   eval      *inlr = *on
     *
     *----------------------------------------------------------------
     *
     *          Subroutines In Alphabetical Order
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
     *   Define partial key for PLTSUM3 file.
     *
     C     keyps3        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
640aA*
640aA*  Define key for TRUCKH file.
640aA*
640aAC     keyth         klist
640aAC                   kfld                    $pwhse
640aAC                   kfld                    $ptruk
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  GETZONEGRP    Get zone group code.
     *
     C     getZoneGrp    begsr
     *
     C     keyzoneg1     chain     zoneg1
     C                   if        %found(zoneg1)
     C                   eval      tbzong = zgzong
     C                   else
     C                   eval      tbzong = ' '
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETTOTETRANS  Get individual tote transactions.
     *
     C     getToteTrans  begsr
     *
     C     keylb90       setll     label90
     C                   dow       forever = forever
     C     keylb90       reade     label90
     C                   select
     C                   when      %eof(label90)
     C                   leave
     C                   other
     C     l90_lbctr#    chain     label
     C                   if        not %found(label)
     C                   iter
     C                   endif
     *
     *  See if it's a tote and if so, go write the record.
     C     keyps12       chain     pltsum12
     C                   if        not %found(pltsum12)
     C                   goto      endGTT
     C                   endif
640aMC                   move      pstruk        $ptruk
640aAC     keyth         chain     truckh
640aAC                   if        %found(truckh)
640aAC                             and thtype = 'T'
640aAC                   eval      $ptmpl =  thztmp
640aAC                   else
640aAC                   eval      $ptmpl =  $ptruk
640aAC                   endif
     C     pickky        chain     optionz
     C                   if        %found(optionz)
     C                   eval      opdta1 = opzdta
     C                   if        opptyp = 'T'
     C                   exsr      zzUpd
     C                   endif
     C                   endif
     *
     C                   endsl
     C                   enddo
     *
     C     endGTT        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Define partial key for LABEL90 file.
     *
     C     keylb90       klist
     C                   kfld                    $pwhse
     C                   kfld                    pstrn#
     *
     *   Define full key for PLTSUM12 file.
     *
     C     keyps12       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    lbtrn#
     C                   kfld                    lbpal#
     *
     *   Define key for ZONEG1 file.
     *
     C     keyzoneg1     klist
     C                   kfld                    $pwhse
     C                   kfld                    p12_psszon
     *
     *  Define key for pick options.
     *
     C                   eval      kycod1 = '*PICK   '
     C     pickky        klist
     C                   kfld                    kycod1
     C                   kfld                    $pwhse
640aD ***                kfld                    pstruk
64aaMC                   kfld                    $ptmpl
     C                   kfld                    p12_psszon
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Write tote and bundle count record.
     *
     C     zzUpd         begsr
     *
     *  Initialize record
     *
     C                   clear                   tbrec
     *
     *  Get zone group code.
     C                   exsr      getZoneGrp
     *
     *  Move fields into record.
     *
     C                   eval      tbwhse = $pwhse
     C                   eval      tbrtid = $prtid
     C                   eval      tbrte  = $prte
     C                   eval      tbcomp = pscomp
     C                   eval      tbszon = p12_psszon
     C                   eval      tbstop = lbstop
     C                   eval      tbmpl# = psplid
     C                   eval      tbpal# = lbpal#
     C                   eval      tbtrn# = lbtrn#
     C                   eval      tbord  = lbord
     C                   eval      tbqtot = 1
     C                   eval      tbqbun = 0
     C                   eval      tbstat = '1'
     C                   eval      tbgdte = today
     C                   time                    tbgtim
     C                   eval      tbstsd = today
     C                   time                    tbstst
     C                   eval      tbuser = ' '
     *
     C                   write     tbrec
     *
     C                   endsr
