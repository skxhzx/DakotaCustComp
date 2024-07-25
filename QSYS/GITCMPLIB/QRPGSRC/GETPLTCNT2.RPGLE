      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  GETPLTCNT  Get Pallet Count & orphan count
     *  01 April 2015
     *  Lynn McMahon
     *
     *  Revisions
     *
     *    04/01/15   LMC  7.00a
     *      - Enh: Created - copied from GETPLTCNT
700bA*    05/27/15   LMC  7.00b
     *      - Enh: Moved OPGCDE from position 62 to 76 *PICK.
     *        Moved OPPMTZ from position 68 to 75 *PICK.
700cA*    11/03/15   LMC  7.00c
     *      - Enh: Added summary total for pallet count.
     *----------------------------------------------------------------
     *  Notes
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        Position Cursor
     *  21 - 29   Field Input Error (Reverse Display)
     *  79        Chain Indicator
     *  99        Universal Record Indicator (Very Temporary Usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fzoneh     if   e           k disk
     Fpltsum8   if   e           k disk
     Ftruckh    if   e           k disk
     Foptionz   if   e           k disk
     Fworklbld  if   e           k disk
     Fordh      if   e           k disk
650aA*----------------------------------------------------------------
650aA* Function prototypes.
650aA*----------------------------------------------------------------

650eA /copy qcopysrc,p.getclien
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  OPTIONZ data structure
     *
     *----------------------------------------------------------------
     *  *PICK  -  Picking options
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
     *    OPSTOP  -  Honor *SP/*SW flag (Y=Yes, N=No).
     *    OPGCDE  -  USF Group Code (0-9).
     *    OPPKUP  -  Picked up by (S=Selector, L=Loader).
     *    OPSPAL  -  Merge pallet should only contain
     *               items for single truck pallet (Y=Yes, N=No).
     *    OPPITM  -  Maximum items per pallet.
     *    OPPMTZ  -  USF Option: Allow multi-truck assignments.
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
700bDD* opgcde                62     62
700bMD  opgcde                76     76
     D**oppkup                62     62
     D  opspal                63     63
     D  oppitm                64     67  0 inz(0)
700bDD* oppmtz                68     68
700bMD  oppmtz                75     75
     D  opdend               117    117
650eA*----------------------------------------------------------------
650eA*  Customer id
650eA*----------------------------------------------------------------

650eA /copy qcopysrc,id#usfcrp
     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------
     D count           s              3  0
     D pltcount        s              3  0
     D pltcounto       s              3  0
700cAD totpltcount     s              3  0
     D orphancount     s              3  0
     D kycode          s              8
     D i               s              2  0
     D j               s              2  0
     D $ktmpl          s             10
     D work            s             10
     D workend         s              5p 0
     D pcmd            s              8
     D pwhse           s              3  0
     D ptruk           s             10
     D prte            s              5
     D prtid           s              5
     D psszn           s              6
     D $kpltc          s             30
     D $kophc          s             30
     D pOutStr         s           1024    varying

     D donotcount      s              1
     D dash            s              1    inz('-')
700cAD equal           s              1    inz('=')

650eAD client          s             10
650eAD clientloc       s             10
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pcmd    Command
     *      pWhse   Warehouse
     *      ptruk   Truck
     *      prte    Route
     *      prtid   Route Id
     *      psszn   Zone
     *
     *    Returned Parameters
     *      pOutStr     JSON output string
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    pcmd
     C                   parm                    pwhse
     c                   parm                    ptruk
     c                   parm                    prte
     c                   parm                    prtid
     c                   parm                    psszn
     c                   parm                    pOutStr
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      $kpltc = *blanks
     C                   eval      $kophc = *blanks
     C*                  eval      $kocnt = 0
     C                   eval      i = 1
     C                   eval      j = 1

     C                   select
     C                   when      psszn <> *blanks
     C     zhkey2        setll     zoneh
     C                   other
     C     zhkey         setll     zoneh
     c                   endsl

     C                   dou       %eof(zoneh)

     C                   select
     C                   when      psszn <> *blanks
     C     zhkey2        reade     zoneh
     C                   other
     C     zhkey         reade     zoneh
     C                   endsl

     C                   if        not %eof(zoneh)

     C                   exsr      getpalletjack#
     C                   exsr      getpalletcount

     C                   if        pltcount <> *zeros
     C                             and i <= 28

     c                   if        i > 1
     C                   eval      $kpltc = %replace(dash:$kpltc:i:1)
     C                   eval      i += 1
     c                   endif

     c                   select
     c                   when      psszn = ' '
     c                   eval      work = pscomp + %char(pltcount)
     c                   other
     c                   eval      work = %char(pltcount)
     c                   endsl
     c                   eval      workEnd = %scan(' ': work: 1) -1
     C                   eval      $kpltc = %replace(work:$kpltc:i:workend)
     C                   eval      i += workend
700cAc                   eval      totpltcount = totpltcount + pltcount

     C                   exsr      getorphancount
     C                   endif

     C                   endif
     C                   enddo
700cA * add summary pallet count
700cAC                   if        totpltcount <> *zeros
700cAC                             and i <= 28

700cAc                   if        i > 1
700cAC                   eval      $kpltc = %replace(equal:$kpltc:i:1)
700cAC                   eval      i += 1
700cAc                   endif

700cAc                   eval      work = %char(totpltcount)
700cAC                   eval      $kpltc = %replace(work:$kpltc:i:3)
700cAc                   eval      totpltcount = 0

700cAC                   endif

      /free

        // Put together JSON string

        pOutStr = '{'
                +  '"PCnt":"'  + %trimr($kpltc) + '",'
                +  '"OCnt":"'  + %trimr($kophc) + '"';

        // Close off the JSON string
        pOutStr += '}';

      /end-free

     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *  Getorphancount subroutine
     *
     C     getorphancountbegsr

     C                   select
700bAC                   when      oppmtz <> 'Y'
700bAC                   eval      orphancount = 0
     C                   when      pltcounto <> 0
     C     pltcounto     div       opfpal        count
     C                   mvr                     orphancount
     C                   other
     C                   eval      orphancount = 0
     C                   endsl

     C                   if        orphancount <> *zeros
     C                             and j <= 28

     c                   if        j > 1
     C                   eval      $kophc = %replace(dash:$kophc:j:1)
     C                   eval      j += 1
     c                   endif

     c
     c                   select
     c                   when      psszn = ' '
     c                   eval      work = pscomp + %char(orphancount)
     c                   other
     c                   eval      work = %char(orphancount)
     c                   endsl
     c                   eval      workEnd = %scan(' ': work: 1) -1
     C                   eval      $kophc = %replace(work:$kophc:j:workend)
     C                   eval      j += workend
     C                   endif
     c                   if        client <> usfcrp
     c                   eval      $kophc = ' '
     c                   endif
     C                   endsr

     *----------------------------------------------------------------
     *  GetPalletCount subroutine
     *
     C     getpalletcountbegsr

     C                   eval      pltcount = 0
     C                   eval      pltcounto = 0
     C     pskey         setll     pltsum8
     C                   dou       %eof(pltsum8)
     C     pskey         reade     pltsum8
     C                   if        not %eof(pltsum8)

     C                   if        pspcs = 0
     C                   iter
     C                   endif

     C                   if        psgen > 1
     C                   iter
     C                   endif

     C                   if        pstype <> 'O'
     C                   iter
     C                   endif

     C                   eval      pltcount += 1
     c                   eval      donotcount = ' '
     C                   if        opstop = 'N'
     C                             and psstp1 = psstp2
     C     lwkey         chain     worklbld
     C                   if        %found(worklbld)
     C     orkey         chain     ordh
     C                   if        %found(ordh)
     C                             and %subst(ohmisc:15:3) = '*SW'
     c                   eval      donotcount = 'Y'
     C                   endif
     C                   endif
     C                   endif
     c                   select
     c                   when      psbcnt <> 0
     C                   when      donotcount = 'Y'
     c                   other
     C                   eval      pltcounto += 1
     c                   endsl

     C                   endif
     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  GetPalletJack# subrotine
     *
     C     getpalletjack#begsr

     C                   eval      kycode = '*PICK   '
     C     keyopz        chain     optionz
     C                   if        not %found(optionz)
     C                   eval      opfpal = 1
     C                   eval      oppmtz = 'N'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
      /free
650eA   getclient(client: clientLoc);
      /end-free
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for Zoneh
     *
     C     zhkey         klist
     C                   kfld                    pwhse
     C                   kfld                    $ktmpl
     *
     C     zhkey2        klist
     C                   kfld                    pwhse
     C                   kfld                    $ktmpl
     C                   kfld                    psszn
     *
     *  Define key for Pltsum8
     *
     C     pskey         klist
     C                   kfld                    pwhse
     C                   kfld                    prtid
     C                   kfld                    zhzone
     *
     *  Define key for TRUCKH file.
     *
     C     trkey         klist
     C                   kfld                    pwhse
     C                   kfld                    ptruk
     *
     C     trkey         chain     truckh
     C                   if        %found(truckh) and thtype = 'T'
     C                   eval      $ktmpl =  thztmp
     C                   else
     C                   eval      $ktmpl =  ptruk
     C                   endif
     *
     C     keyopz        klist
     C                   kfld                    kycode
     C                   kfld                    pwhse
     C                   kfld                    $ktmpl
     C                   kfld                    zhzone
     *  Define key for Worklbld
     *
     C     lwkey         klist
     C                   kfld                    pswhse
     C                   kfld                    psrtid
     C                   kfld                    psplid
     *
     *  Define key for ORDH file.
     *
     C     orkey         klist
     C                   kfld                    lwwhse
     C                   kfld                    lword
     C                   endsr
