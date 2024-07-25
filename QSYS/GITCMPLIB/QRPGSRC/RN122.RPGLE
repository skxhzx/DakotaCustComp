600aA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RN122     Customer return whole order - Process
     *  19 June, 2002
     *  Roxanne Harrison
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
416 A*    08/29/02  RH   4.16
     *      - Move 'Y' to impact inventory for whole order.
     *
417 A*    06/06/03  MLB  4.17
     *      - Fix: Revise program to run convert date every time
     *        record is added to returns file. Revised ZZEXCP with
     *        same change for field EXGDTE.
417bA*    02/26/04  RH   4.17b
     *      - Enh: Call RC160 with $RFIFO
500 A*    01/28/05  RH   5.00
     *      - Enh: Create license rec, license = 'R' & original label
     *        to allow whole order put away using license in voice.
     *
520aA*    01/13/09  RH   5.20a
     *      - Fix: Write total catch weight to ORRTN return weight.
520bA*    05/04/09  MLB  5.20b
     *      - Fix: Revised program to receive two new parms, Quick
     *        Returns Y/N and Export Quick Returns Y/N. If Quick
     *        Returns = Y and Export Quick Returns = N, then export
     *        date/time will be set to Return date/time. Entire order
     *        returns were being exported when they should not have
     *        been exported.
530aA*    12/02/09  RH   5.30a
     *      - Enh: Add memo to parms, write to ORRTN file.
     *
600aA*    05/21/09  DAS  6.00a
     *      - Enh: Added dates to RN246/RN246L parms
     *
600bA*    05/21/09  DAS  6.00b
     *      - Revised to condition 520b logic on number of parms sent.
530bA*    11/04/10  RH   5.30b
     *      - Fix: Write default expiration date for date sensitive
     *        items to POMFR.
     *
640 A*    05/04/11  MLB  6.40
     *      - Enh: Added client custom code support to program.
640a *    10/28/11  GJA  6.40a
     *      - Enh:  Added invoice# to parm list.
640b *    09/11/12  RH   6.40b
     *      - Fix:  Shift SSB breakdown item qty to Normal field,
     *        RN250 single item return puts type 'S' return qty
     *        in Normal qty field, programs shift to breakdown field
640c *    12/07/12  LMC  6.40c
     *      - Fix:  Parms added to call to RN246L.
     *
650 A*    03/08/13  MLB  6.50
     *      - Fix: Revised pgm to check if value loaded into exqty > 999
     *        and if yes, then set exqty = 999. Error found at Get
     *        Fresh who stores watermelon in lbs in qty fields.
650a *    04/15/13  GJA  6.50a
     *      - Fix: When whole orders are not being return to stock it 99
     *             was creating the return transaction.
650b *    05/24/13  LMC  6.50b
     *      - Fix: Added chain to disposition file to determine if
     *             inventory should be impacted.
     *             Use the disposition impact inventory field to
     *             determine if putaway is created.
     *             Populate return file impact inventory field based
     *             on the disposition code impact inventory field
     *             instead of always forcing this to a 'Y'.
650c *    05/31/13  LMC  6.50c
     *      - Fix: Change to mod 650b, we will pass *NOSTOCK to
     *             RN246L instead of bypassing the program
650dA*    05/24/13  LMC  6.50d
     *      - Enh: RCVRTN transaction for MRC reporting.
650e *    12/06/12  LMC  6.50e
     *      - Enh:  GS1/UCI Logic.
     *      Added additional parms to pass to rn246l
650f *    07/18/13  LMC  6.50f
     *      - Enh:  PTI Logic.
     *      Added additional parms to pass to rn246l
700a *    01/07/16  LMC  7.00a
     *      - We are setting all directed putaway returns to be done
     *        Manually.
     *        At this time only manual putaway is supported on returns
740a *    06/22/20  LMC  7.40a
     *      - Added parm for $psls - used for packers at this time.
750aA*    06/23/21  LMC  7.50a
     *      - Enh: Added new pltlcns/hldpicklbl parms to send to RN246
750bA*    07/29/21  LMC  7.50b
     *      - Enh: Added call to OR737s for exporting realtime returns
     *        as adjustments.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt Produce
     *
CSP A*    05/04/11  MLB  CSP   P#01041
     *      - Revised program to write out line number into last 5
     *        positions of memo code field, ORRMEM.
     *
     *----------------------------------------------------------------
     *    Client Custom Revisions: Packers730
PCKaA*    06/22/20  LMC  PCKa
     *      - Enh: special return logic for packers
PCKbA*    08/22/20  MLB  PCKb
     *      - Enh: Revised pgm to load customer order number into
     *        original invoice number field.
PCKcA*    09/09/20  LMC  PCKc
     *      - Enh: special return logic for packers. Ensure order is
     *        written to orrtn.
     *
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
     Frn122     ip   e           k disk
     FLabel2    if   e           k disk
     Fpiritem   if   e           k disk
     Foptiond   if   e           k disk
500 AFoptions   if   e           k disk
520aAFordc1     if   e           k disk
650bAFrdscode   if   e           k disk
530b FSlot3     if   e           k disk
600aDF*icense   o  a e           k disk
     FLabelnk   o  a e           k disk
     Forrtn     o  a e           k disk
     Fitmexcp   o    e           k disk
530bAFpomfr     o  a e           k disk
PCKaAForrtnm    o    e             disk
PCKaAFORDH      IF   E           K DISK

640 A*----------------------------------------------------------------
640 A*  Customer id
640 A*----------------------------------------------------------------

CSP A /copy qcopysrc,id#coastal
PCKaA /copy qcopysrc,id#packers
PCKaA*----------------------------------------------------------------
PCKaA*  SAP Returns Misc field File data structures
PCKaA*
PCKaA /copy qcopysrc,rmmsc1_pak
PCKaA /copy qcopysrc,rmmsc2_pak
PCKaA /copy qcopysrc,rmmsc3_pak
PCKaA /copy qcopysrc,rmmsc4_pak
PCKaA /copy qcopysrc,rmmsc5_pak
640 A*
     *----------------------------------------------------------------
     *  Table and array
     *
     D a22             s              1    dim(22)
     *
     *----------------------------------------------------------------
     * Data structure
     *
     D opddta          ds
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
     D  opmput                34     34
     D  opdend               117    117
     *
500 A* Data structure
500 A*
500 AD opdata          ds
500 AD  oplpgm                 1     10
500 AD  opupct                11     13  0
500 AD  oppdef                14     14  0
500 AD  oppbld                15     15  0
500 AD  oppact                16     16  0
500 AD  opfdef                17     17  0
500 AD  opfasl                18     18  0
500 AD  opfsid                19     19  0
500 AD  opflvl                20     20  0
500 AD  oppasl                21     21  0
500 AD  oppfrc                22     22
500 AD  opplcn                23     23
500 AD  opcum                 24     43
500 AD  opcdiv                44     52  2
500 AD  opcaut                53     53
500 AD  opcwrn                54     54
500 AD  opcrng                55     57  1
500 AD  opwum                 58     72
500 AD  opxdsc                73     73
500 AD  optend               117    117
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
     *  Called program parameters
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
     *
     D  $lcode                19     20
     *
     D  $ltrn#                19     25  0
     *
     D  $luser                19     28
     *
     D  $lpo                  37     45
     D  $lrq1                 46     50  0 inz(0)
     D  $lrq2                 51     55  0 inz(0)
     D  $lrq3                 56     60  0 inz(0)
     D  $lrpal                61     63  0
     *----------------------------------------------------------------
     *
     *  Called programs
     *
650dAD @crtrcv         c                   const('CRTRCVTRN')
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
     D                 ds
     D  t#date                 1      6  0
     D  month                  1      2  0
     D  day                    3      4  0
     D  year                   5      6  0
     *----------------------------------------------------------------
     *
     *  Variables
     *
     D $crq1           s              5  0
     D $crq2           s              5  0
     D $crq3           s              5  0
     D $lord           s              7  0
     D $pcod#          s              7  0
     D $plod#          s              7  0
     D $pwhse          s              3  0
     D first           s              1
650fAD gtin            s             14
650fAd $pbcProdD       s              6  0
650fAd $pbclot         s             20
     D kycode          s                   like(opdcod)
530b D kystat          s              2
     D lcnflg          s              1
     D ltlcns          s              8
650dAD poppcs          s                   like($lpcs)
650dAD rcvrtncomplete  s               n
     D stop            s              1
     D tlcwgt          s              9  2
     D today           s              8  0
600aAD wolbl#          s              7  0
600aAD woswgt          s              9  2
600aAD woexdt          s              8  0
600aAD wofifo          s              8  0
600aAD woindt          s              8  0
600aAD womfdt          s              8  0
600aAD wodktexpd       s              8  0
740aAD pak9            s              9  0
740aAD pak7            s              7  0
PCKbAD wkinv#          s                   like(orinv#)
750aAD $pw2pti         s              4  0
750aAD pltlcns         s             10
750aAD hldpicklbl      s             10

750bAD batId           s             11
750bAD rtnCodex        s             10
750bAD rtnMessage      s            200
750bAD haveBatId       s               n
750bAD $pWhse3A        s              3
750bAd ExportType      s            117a
750bA*----------------------------------------------------------------
750bA*  Prototypes
750bA*----------------------------------------------------------------
750bA /copy qcopysrc,p.getoptio
750bA /copy *libl/qcopysrc,p.getopint
750bA*----------------------------------------------------------------
750bA* Data structure
750bA*
750bA*----------------------------------------------------------------
750bA*  *RETURNS -  Customer Returns options
750bA*----------------------------------------------------------------
750bA*
750bA* Fields
750bA*
750bA*    OPRQCH  -  Allow changes to return quantity. (Y,N).
750bA*    OPRQEC  -  Allow changes to qty if return exported. (Y/N)
750bA*    OPRFLB  -  Force return label entry. (Y/N)
750bA*    OPREXQ  -  Export Quick returns.(Y/N)
750bA*    OPRULB  -  Use label for putaway.(Y/N)
750bA*    OPPLTL  -  Allow Pallet License.(Y/N)
750bA*    OPREAD  -  Export as adjustments. (Y/N)
750bA*
750bA* Data structure
750bA*
750bAD oprdta          ds
750bAD  oprqch                 1      1
750bAD  oprqec                 2      2
750bAD  oprflb                 3      3
750bAD  oprexq                 4      4
750bAD  oprulb                 5      5
750bAD  opread                 6      6
750bAD  oppltl                 9      9
750bAD  oprend               117    117
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse #
     *      $PRTN   Return
     *      $PLORD  Label order#
     *      $PMPUT  Manual put away
520bA*      $PQCK   Quick Return Y/N
520bA*      $PREXQ  Export Quick Return Y/N
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhs             3
     C                   parm                    $prtn             8
     C                   parm                    $plord            7
     C                   parm                    $pmput            1
     C                   parm                    $pcode            2
     C                   parm                    $pdcde            5
     C                   parm                    $puser           10
     C                   parm                    $pcord            7
     C                   parm                    $pinvf            1
520bAC                   parm                    $pqck             1
520bAC                   parm                    $prexq            1
530aAC                   parm                    $pmemo           30
640aAC                   parm                    $pinv#            9
740aAC                   PARM                    pckorg            4 0
750aAC                   parm                    pltlcns
750aAC                   parm                    hldpicklbl
     C                   move      $pwhs         $pwhse
     C                   move      $plord        $plod#
     C                   move      $pcord        $pcod#
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C                   eval      $lcmd = '*CHANGE '
     C                   eval      $lwhse = $pwhse
     C                   eval      $crq1 = 0
     C                   eval      $crq2 = 0
     C                   eval      $crq3 = 0
     C                   select
     C                   when      lqutyp = 'N'
     C                   eval      $crq1 = lqqpck
     C                   when      lqutyp = '1'
     C                   eval      $crq2 = lqqpck
     C                   when      lqutyp = '2'
     C                   eval      $crq3 = lqqpck
     C                   endsl
650dAc                   eval      rcvrtncomplete = *off
     C                   exsr      zzputo
650dAc                   exsr      zzrcvrtn
     C                   eval      $litem = lqitem
     C                   eval      $lrpal = 1
     * $PCOD# IS CUSTOMER ORDER #
     C                   eval      $lord = $pcod#
500  *
500  * Get license options
500  *
500  C                   exsr      zzlcns
530bA*     If item is date sensitive, get to oldest slot date.
530bAC                   if        itflgd = 'Y'
530bAC                   clear                   pmrec
530bAC                   eval      pmwhse = $pwhse
530bAC                   eval      pmpo = *blanks
530bAC                   eval      pmseq = 0
530bAC                   eval      pmitem = lqitem
530bAC                   eval      pmtrn# = lqtrn#
530bAC                   eval      pmlbl# = lqlbl#
530bAC                   eval      kystat = 'A'
530bAC     partk3        setll     slot3
530bAC     partk3        reade     slot3                                  79
530bAC                   if        *in79
530bAC                   eval      pmexpd = today
530bAC                   else
530bAC                   eval      pmexpd = slexpd
530bAC                   endif
530bAC                   write     pmrec
530bAC                   endif
     *
     * If manual put away,
     *
     C                   if        opmput = 'Y'
600aAC                   eval      wolbl# = lqlbl#
600aAC                   eval      woswgt = lqswgt
530bAC                   if        itflgd = 'Y'
530aMC                   eval      woexdt = pmexpd
600aAC                   eval      wodktexpd = pmexpd
600aAC                   eval      woindt = pmexpd
530aMC                   else
600aAC                   eval      woexdt = 0
600aAC                   eval      wodktexpd = 0
600aAC                   eval      woindt = 0
530aMC                   endif
600aAC                   eval      womfdt = 0
600aAC*                  eval      wodktexpd = 0
600aAC                   eval      wofifo = 0
600aAC*                  eval      woindt = 0
640bAC*  Shift qty for type 'S' item
640bAC                   if        ittype = 'S'
640bAC                   select
640bAC                   when      lqutyp = 'N'
640bAC                   eval      $crq1 = lqqpck
640bAC                   when      lqutyp = '1'
640bAC                   eval      $crq1 = lqqpck
640bAC                   eval      $crq2 = 0
640bAC                   when      lqutyp = '2'
640bAC                   eval      $crq2 = lqqpck
640bAC                   eval      $crq1 = 0
640bAC                   eval      $crq3 = 0
640bAC                   endsl
640bAC                   endif
     C                   eval      $lrq1 = $crq1
     C                   eval      $lrq2 = $crq2
     C                   eval      $lrq3 = $crq3
650dAc                   eval      rcvrtncomplete = *on
650bDC*                  if        $pinvf <> 'N'
650cDC*                  if        rdiinv <> 'N'
650cMc                   if        rdiinv <> 'Y'
650cAc                   eval      $lpo  = '*NOSTOCK'
750aAC                   eval      pltlcns = ' '
650cAc                   endif
     C                   call      'RN246L'
     C                   parm                    $lparm
     C                   parm                    $lord
600aAC                   parm                    wolbl#
600aAC                   parm                    woswgt
600aAC                   parm                    wodktexpd
600aAC                   parm                    woindt
600aAC                   parm                    wofifo
640cAc                   parm      ' '           $ldecvalue       15
640cAC                   parm      0             $lmfgex           8 0
640cAC                   parm      0             $lmfgdt           8 0
650dAC                   parm                    $lsavetrn
650eAC                   parm      ' '           w3lcns           15
650eAC                   parm      ' '           w2lotc           30
650fAC                   parm      ' '           gtin
650fAc                   parm      0             $pbcProdD
650fAc                   parm      ' '           $pbclot
750aAc                   parm      0             $pw2pti
750aAc                   parm                    pltlcns
750aAc                   parm                    hldpicklbl
     C                   if        $lrtn = '*CANCEL '
650dAc                   eval      rcvrtncomplete = *off
     C                   goto      endit1
650dAc                   else
     C                   endif
650cDC*                  endif
     *
     C                   else
     *
416X **                   MOVE LQITEM    $RITEM
650dAc                   eval      rcvrtncomplete = *on
     C                   movel     '*RETURN'     $rcmd
     C                   eval      $rprg = $lprg
     C                   call      'RC160'
     **                   PARM '*RETURN' $RCMD   8
     C                   parm                    $rcmd             8
     C                   parm                    $rprg            10
     C                   parm      '*INTER  '    $rtype            8
     C                   parm                    $pwhse
     C                   parm                    $litem
     C                   parm                    $crq1
     C                   parm                    $crq2
     C                   parm                    $crq3
    D**                   PARM *BLANKS   $RPO    9
     C                   parm                    $rpo              9
     C                   parm      0             $rven            11 0
     C                   parm      *blanks       $rvnam           40
     C                   parm      *blanks       $rvitm           15
     C                   parm                    $pcod#
     C                   parm                    $pcode
     C                   parm                    w1memo           30
     C                   parm                    $rexpd            8 0
417b C                   parm      0             $rfifo            8 0
     C                   parm                    w1dev            10
     C                   parm                    w1form           10
     C                   parm                    w1slot           12
     C                   parm      0             $rseq             5 0
     C                   parm                    $rrpck            1
     C                   parm                    $rplbl            1
     C                   parm      0             $rdwgt            9 2
     C                   parm                    $rrq1             5 0
     C                   parm                    $rrq2             5 0
     C                   parm                    $rrq3             5 0
     C                   parm                    $rrpal            3 0
     C                   parm                    $rrtn             8
     C                   parm                    $rmsg             4
     *
     *   What happened with putaway?
     *
     C                   select
     *
     *      Error occured.
     *
     C                   when      $rrtn = '*PGMQ   '
     **                   MOVE *ON       ERROR
650dAc                   eval      rcvrtncomplete = *off
     C                   goto      endit1
     *
     *      Enter license if LCNFLG is on.                            .
     *
     C                   other
     *
     C                   endsl
     *
     C                   endif
     *      Write to label link file for label #.                     .
     *
     C                   exsr      zzulnk
600aD **     Write to license file, license = 'R' & original label#    .
600aD **
600aDC**                 eval      liwhse = $pwhse
600aDC**                 movel     'R'           ltlcns
600aDC**                 move      lqlbl#        ltlcns
600aDC**                 movel     ltlcns        lilcns
600aDC**                 eval      litrn# = lbtrn#
600aDC**                 write     lirec
500  *
     *      Write exception record to notify inventory control.       .
     C                   if        $pinvf = 'Y'
     **                   MOVE LQITEM    KYITEM
     C                   eval      exitem = lqitem
     C                   eval      excitm = *blanks
     C                   eval      exerid = 'INVCTRL'
     C                   exsr      zzexcp
     C                   endif
520a *      Total catch weight if exists in order file, ORDC          .
520a C                   exsr      zztcwt
520a *
     *      Product put away. Write history record and display message.
     C                   clear                   orrec
     C                   eval      orwhse = $pwhse
     C                   eval      ortrn# = lqtrn#
     *                    Z-ADD$PORD     ORORD
     C                   if        opmput = 'Y'
     C                   eval      orord = $pcod#
     C                   eval      orpbat = $lord
     C                   else
     C                   eval      orord = $lord
     C                   eval      orpbat = $pcod#
     C                   endif
     C                   eval      oritem = lqitem
     C                   eval      orqty1 = $crq1
     C                   eval      orqty2 = $crq2
     C                   eval      orqty3 = $crq3
    D*                    Z-ADDLQUWGT    ORCWTR
520aD*                    Z-ADD0         ORCWTR
520a C                   eval      orcwtr = tlcwgt
417 A*    Retrieve current date.
417 AC                   eval      $cvcmd = '*CURCMD '
417 AC                   call      @cvtdt
417 AC                   parm                    $cvtdt
417 D*                    Z-ADDTODAY     ORRDTE
417 MC                   eval      orrdte = $cvd8o
     C                   time                    orrtim
     C                   eval      orrusr = $puser
     C                   eval      ortype = ' '
     C                   eval      ortrn# = lqtrn#
     C                   eval      orcitm = *blanks
     C                   eval      orrcod = $pcode
     C                   eval      ordcod = $pdcde
416 D*                    MOVE *BLANKS   ORIINV
650bDC*                  eval      oriinv = 'Y'
650bMC                   eval      oriinv = rdiinv
     C                   eval      orolb# = lqlbl#
640aDC*                  eval      orinv# = *blanks
640aMC                   eval      orinv# = $pinv#
PCKbA*
PCKbAC                   if        client = pack730
PCKbAC                   if        $pinv# = ' '
PCKbAC                   eval      wkinv# = %trim(%editc(orord : '4'))
PCKbAC***                eval      orinv# = $pinv#
PCKbAC                   eval      orinv# = %replace(wkinv# : orinv#:4:9)
PCKbAC                   endif
PCKbAC                   endif
CSP A*
CSP AC                   if        client = CoastalSunbelt
CSP AC                   movel     $pmemo        orrmem
CSP AC                   eval      orrmem =
CSP AC                               %replace(%editc(lqseq:'X'):orrmem:26:5)
CSP AC                   else
CSP A*
530aAC                   movel     $pmemo        orrmem
     C                   move      'WHOLE OD'    orrmem
CSP AC                   endif
CSP A*
     C                   eval      orslot = *blanks
520bA*
520bA*     Quick return = Yes and No Export Quick Return.
600bAC                   if        %parms >= 11
520bAC                   if        $pqck = 'Y'  and
520bAC                             $prexq = 'N'
520bAC                   eval      orudte = orrdte
520bAC                   eval      orutim = orrtim
520bAC                   endif
600bAC                   endif
520bA*
     C                   eval      oroord = lqord
     C                   eval      orwhol = 'Y'
PCKaA /free
PCKcD   //if client = pack730;
PCKcD     //if $pinvf = 'N';
PCKcD       //oroord = 0;
PCKcD     //endif;
PCKcD   //endif;
PCKaA /end-free
     C                   write     orrec
PCKaA *  Write orrtnm, record.

PCKaA /free
PCKaA   if client = pack730;
PCKaA /end-free
PCKaAc                   eval      rmwhse = $pwhse
PCKaAc                   eval      rmord  = $pcod#
PCKaAc                   eval      rmitem = lqitem
PCKaMc                   eval      rmrdte = orrdte
PCKaMc                   eval      rmrtim = orrtim
PCKaAc                   eval      rmpbat = orpbat
PCKaAc                   eval      rmtrn# = lqtrn#
PCKaAc                   eval      rmrcod = $pcode
PCKaAc                   eval      rmdcod = $pdcde
PCKaAc                   eval      rmudte = *zeros
PCKaAc                   eval      rmutim = *zeros
PCKaAc                   eval      pak9 = $pcod#
PCKaMc                   eval      pakrm1_delv = %editc(pak9:'X')
PCKaAc                   eval      pak7 = lqord
PCKaAc                   eval      pakrm1_ordid = %editc(pak7:'X')
PCKaA /free
PCKaA   chain ($pwhse: lqord) ordh;
PCKaA   if not %found(ordh);
PCKaA     ohmisc = ' ';
PCKaA   endif;
PCKaA /end-free
PCKaA /free
PCKaA     select;
PCKaA       when %subst(ohmisc:17:4) = '0002';
PCKaA         pakrm1_vkorg = '2100';
PCKaA       other;
PCKaA         pakrm1_vkorg = %char(pckorg);
PCKaA     endsl;
PCKaA   endif;
PCKaA /end-free
PCKaAc                   eval      rmmsc1 = pakrm1_base
PCKaAc                   eval      rmmsc2 = *blanks
PCKaAc                   eval      rmmsc3 = *blanks
PCKaAc                   eval      rmmsc4 = *blanks
PCKaAc                   eval      rmmsc5 = *blanks

PCKaAc                   write     rmrec
650dAC                   exsr      zzrcvrtncheck
650dAC                   exsr      zzrcvrtnclose
650dAc                   eval      rcvrtncomplete = *off
650dAc                   eval      $lsavetrn = 0
     *
     *
     *
     C     endit1        tag
750bA*   Get use generic license option.
750bACLR                 eval      lcnflg = *off
750bACLR                 eval      kycode = '*RETURNS'
750bA*
750bACLR   opkey         chain     options                            79
750bACLR                 if        not *in79
750bACLR                 EVAL      OPRDTA = OPDATA
750bACLR                 endif
750bA /free
750bA      GetOptions(%editc(0:'X'):
750bA                 '*FTP': '001': '001': ExportType);
750bA /end-free
750bACLR                 if        opread = 'Y' and ExportType = 'R'
750bAcLR                 eval      $pWhse3A  = %editc($pwhse:'X')
750bACLR                 call      'OR737S'
750bACLR                 parm                    $pWhse3a
750bACLR                 parm                    BatId
750bACLR                 parm                    rtnCodex
750bACLR                 parm                    rtnMessage
750dACLR                 if        BatId <> *blank
750bACLR                 eval      haveBatId = *on
750bACLR                 endif
750bACLR                 endif
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
640 A*
640 A* Get client id.
640 A*
640 AC                   call      'GETCLIENT'
640 AC                   parm                    client           10
640 AC                   parm                    clientloc        10
     *
     C                   eval      first = *on
     C                   eval      $cvprg = #prog
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZEXCP Write item exception record to file.
     *
     C     zzexcp        begsr
     *
     *    Write an item exception record for item.
     *
     C     itkey         chain     piritem                            79
     C                   if        not *in79
     C                   eval      exwhdp = itwhdp
     C                   eval      exstyp = itstyp
     C                   else
     C                   eval      exwhdp = *blanks
     C                   eval      exstyp = *blanks
     C                   endif
     C                   eval      exwhse = $pwhse
     **                   Z-ADDW1WHSE    EXWHSE
     **                   MOVE W1ITEM    EXITEM
     **                   MOVE W3CITM    EXCITM
     **                   Z-ADDW1QTY1    EXQTY
     **                   Z-ADDW1QTY2    EXQTY2
     **                   Z-ADDW1QTY3    EXQTY3
650 A*
650 AC                   if        $lrq1 > 999
650 AC                   eval      exqty = 999
650 AC                   else
650 A*
     C                   z-add     $lrq1         exqty
650 AC                   endif
650 A*
     C                   z-add     $lrq2         exqty2
     C                   z-add     $lrq3         exqty3
     C                   eval      exfdis = *blanks
     C                   eval      extdis = *blanks
     C                   eval      extask = 'PUTRTN'
     **                   MOVE 'MISPICK' EXERID
417 A*    Retrieve current date.
417 AC                   eval      $cvcmd = '*CURCMD '
417 AC                   call      @cvtdt
417 AC                   parm                    $cvtdt
417 D*R                   Z-ADDTODAY     EXGDTE
417 MC                   eval      exgdte = $cvd8o
     C                   time                    exgtim
     C                   eval      exgby = #user
     C                   eval      exesta = '1 '
     C                   write     exrec
     *
     C     endexc        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     *
     C     itkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    lqitem
     *
     C     partk2        klist
     C                   kfld                    $lord
     C                   kfld                    $pwhse
530b *
530b C     partk3        klist
530b C                   kfld                    $pwhse
530b C                   kfld                    lqitem
530b C                   kfld                    kystat
     *
     C     opkey2        klist
     C                   kfld                    kycode
     C                   kfld                    itwhse
     C                   kfld                    itwhdp
     C                   eval      kycode = '*PICK   '
500 A*
500 AC     opkey         klist
500 AC                   kfld                    $pwhse
500 AC                   kfld                    kycode
520a *
520a C     ockey         klist
520a C                   kfld                    $pwhse
520a C                   kfld                    lqlbl#
     *
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
650bA*
650bA*  Detemine impact inventory based on disposition code sent in.
650bA*
650bA /free
650bA    chain ($pdcde) rdscode;
650bA    if %found(rdscode);
650bA    else;
650bA      rdiinv = 'N';
650bA    endif;
650bA /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
500 A*  ZZLCNS   Get use generic license option
     *
500 AC     zzlcns        begsr
     *
500 A*   Get use generic license option.
500 AC                   eval      lcnflg = *off
500 AC                   eval      kycode = '*RCVLBL '
     *
500 AC     opkey         chain     options                            79
500 AC                   if        not *in79
500 AC                   if        opplcn = 'Y'
500 AC                   eval      lcnflg = *on
500 AC                   endif
500 AC                   endif
     *
500 AC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZPUTO   Get Put away option.
     *             Directed or Manual put away
     *
     C     zzputo        begsr
     *
     C     itkey         chain     piritem                            79
     C                   if        not *in79
     C                   eval      kycode = '*PICK   '
     C     opkey2        chain     optiond                            79
     C                   if        *in79
     C                   eval      opmput = 'N'
     C                   endif
700aAc* Directed returns is not supported.
700aAc                   eval      opmput = 'Y'
     C                   endif
     *
     C                   endsr
650dA*----------------------------------------------------------------
650dA*
650dA*  ZZRCVRTNCHECK check for started RCVRTN Transaction
650dA*
650dAC     zzrcvrtncheck begsr
650dA*
650dA*  See if RCVRTN transaction is status 2 - start new if needed
650dA*
650dAc                   move      $pcord        $rtnord
650dAC                   call      @crtrcv
650dAC                   parm      '*RETURN'     $lcmdr           10
650dAC                   parm      '*CHECK '     $lsubcmd         10
650dAC                   parm      itwhse        @lwhse            3 0
650dAC                   parm      0             $lpcs             5 0
650dAC                   parm      0             $lpallets         5 0
650dAC                   parm                    $lsavetrn         7 0
650dAC                   parm                    $rtnord           9
650dAC                   parm      itstyp        $litstyp          1
650dAC                   parm      itwhdp        $litwhdp          5
650dAC                   parm                    $lrtnr           10
650dAC                   endsr
650dA*----------------------------------------------------------------
650dA*
650dA*  ZZRCVRTN Create receiver transaction.
650dA*
650dAC     zzrcvrtn      begsr
650dA*
650dA*     clear the return field used in po236
650dA*
650dAc                   eval      $lrtn = ' '
650dAc                   move      $pcord        $rtnord
650dAC                   call      @crtrcv
650dAC                   parm      '*RETURN'     $lcmdr           10
650dAC                   parm      '*CREATE'     $lsubcmd         10
650dAC                   parm      itwhse        @lwhse            3 0
650dAC                   parm      0             $lpcs             5 0
650dAC                   parm      0             $lpallets         5 0
650dAC                   parm                    $lsavetrn         7 0
650dAC                   parm                    $rtnord           9
650dAC                   parm      itstyp        $litstyp          1
650dAC                   parm      itwhdp        $litwhdp          5
650dAC                   parm                    $lrtnr           10
650dA*
650dAC                   endsr
650dA*----------------------------------------------------------------
650dA*
650dA*  ZZRCVRTNCLOSE  Close RCVRTN transaction.
650dA*
650dAC     zzrcvrtnclose begsr
650dAc                   if        rcvrtncomplete

650dAc                   select
650dAc                   when      opmput <> 'Y'
650dAc                   eval      $lpallets = $rrpal
650dAc                   select
650dAc                   when      $rrq1 > 0
650dAc                   eval      poppcs = $rrq1
650dAc                   when      $rrq2 > 0
650dAc                   eval      poppcs = $rrq2
650dAc                   when      $rrq3 > 0
650dAc                   eval      poppcs = $rrq3
650dAc                   endsl

650dAc                   other
650dAc                   eval      $lpallets = $lrpal
650dAc                   select
650dAc                   when      $lrq1 > 0
650dAc                   eval      poppcs = $lrq1
650dAc                   when      $lrq2 > 0
650dAc                   eval      poppcs = $lrq2
650dAc                   when      $lrq3 > 0
650dAc                   eval      poppcs = $lrq3
650dAc                   endsl
650dAc                   endsl

650dAC                   call      @crtrcv
650dAC                   parm      '*RETURN'     $lcmdr           10
650dAC                   parm      '*COMPLETE'   $lsubcmd         10
650dAC                   parm      itwhse        @lwhse            3 0
650dAC                   parm      poppcs        $lpcs             5 0
650dAC                   parm                    $lpallets         5 0
650dAC                   parm                    $lsavetrn         7 0
650dAC                   parm                    $rtnord           9
650dAC                   parm      itstyp        $litstyp          1
650dAC                   parm      itwhdp        $litwhdp          5
650dAC                   parm                    $lrtnr           10
650dA
650dAc                   else
650dA
650dAC                   call      @crtrcv
650dAC                   parm      '*RETURN'     $lcmdr           10
650dAC                   parm      '*CLOSE'      $lsubcmd         10
650dAC                   parm      itwhse        @lwhse            3 0
650dAC                   parm      0             $lpcs             5 0
650dAC                   parm      0             $lpallets         5 0
650dAC                   parm                    $lsavetrn         7 0
650dAC                   parm                    $rtnord           9
650dAC                   parm      itstyp        $litstyp          1
650dAC                   parm      itwhdp        $litwhdp          5
650dAC                   parm                    $lrtnr           10

650dAc                   endif
650dAC                   endsr
520a *----------------------------------------------------------------
520a *
520a *  ZZTCWT   Total catch weight returned for whole order
520a *
520a C     zztcwt        begsr
520a C                   eval      tlcwgt = 0
520a C     ockey         setll     ordc1
520a C                   eval      stop = *off
520a C                   dou       stop = *on
520a C     ockey         reade     ordc1                                  79
520a C                   if        *in79
520a C                   eval      stop = *on
520a C                   else
520a C                   add       occwgt        tlcwgt
520a C                   iter
520a C                   endif
520a C                   enddo
520a C                   endsr
520a *
     *----------------------------------------------------------------
     *
     *  ZZULNK   Update for LABELNK FILE
     *
     C     zzulnk        begsr
     *
     *
     *      Write to label link file if Label # was entered.          .
     *
     C     partk2        setll     label2
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     partk2        reade     label2                                 79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   eval      lllblo = lqlbl#
     C                   eval      lllbl# = lblbl#
     C                   eval      lltrn# = lbtrn#
     C                   eval      llqpck = lbqpck
     C                   eval      llucod = lbucod
     C                   write     llrec
     C                   endif
     C                   enddo
     C     endlnk        endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
