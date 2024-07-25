      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave #203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR640J    Truck build - Print labels
     *  14 March 2011
     *  Jeffrey Jahnke
     *
     *  Revisions
     *
640aA*    03/14/11  JCJ  6.40a
     *      - Created
     *
640bA*    06/30/11  JCJ  6.40b
     *      - Enh: Added label range parms.
     *
640cA*    02/08/12  JCJ  6.40c
     *      - Fix: Change klist keyop2 to use $ptmpl instead of
     *        $ptruk. This will allow undefined zones to print
     *        labels.
     *
640dA*    02/24/12  JCJ  6.40d
     *      - Fix: added other label program to the logic for
     *        extracting the label printing program and label set
     *        name.
     *
650aA*    12/17/13  RTR  6.50a
     *      - Revised to pass whse, rte, rtid to PFILEFTP.
     *
700aA*    11/30/15  JCJ  7.00a
     *      - Revised for pallet label reprint.
700cA*    04/05/16  NLK  7.00c
     *      - Fix: Revised 650a and moved line $prte into $prten at CALL
     *        Blows up when * in $prte like '*AMP*' used at Greenleaf
700dA*    05/27/16  RTR  7.00d
     *      - Fix: Changing route to char to fix mod 650a.
     *
     *----------------------------------------------------------------
     *  Notes
     *
414 A*   - A special label printing program has been created to work
     *     with Zebra type printers. The name of the new program is
     *     "PFMT". To use this program the user would enter the
     *     following for the label program within zone maintenance"
     *
     *                       PFMTxxxxxx
     *
     *     where 'xxxxxx' is the name of the label format to be used.
     *     Menu PIRLF contains the options to work with and define
     *     the label formats.
     *
414aA*   - A special label printing program has been created to write
     *     the label records to a file instead of printing them. The
     *     file that recieves the records is EXPFPLBL. Each route of
     *     labels goes into a separate member. The member is the name
     *     of the host's route.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Chain indicator
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpltsum3   if   e           k disk
     Foptionz   if   e           k disk
     Foptions   if   e           k disk
     Fdevgrpr   uf   e           k disk
     Ftruckh    if   e           k disk
     Fpltsum8   if   e           k disk    rename(psrec:psrec8)
     Fpltsum12  if   e           k disk    rename(psrec:psrec12)
700aAFpltsum15  if   e           k disk    rename(psrec:psrec15)
     Flabel     if   e           k disk
     Frtehed    if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a80             s              1    dim(80)
     D ovr             s             80    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  *PICKLBL  -  Picking label options
     *----------------------------------------------------------------
     * Fields
     *
     *    OPCLVL  -  Qty level for combined labels.
     *    OPCWRB  -  Print combined label warning before.
     *    OPCWRA  -  Print combined label warning after.
     *    OPUWRB  -  Print unit of measure warning before.
     *    OPUWRA  -  Print unit of measure warning after.
     *    OPTEXT  -  Text for last line of label.
     *    OPERR   -  Error label ratio.
     *    OPCWGT  -  Catch weight label ratio.
     *    OPLPGM  -  Picking label program.
     *    OPPDEV  -  Printer device.
     *    OPPFRM  -  Printer form.
640bA*    OPAISL  -  Print aisle change label (Y/N).
640bA*    OPTAXR  -  Include in Tax Right (Y=Yes, N=No).
640bA*    OPCHKR  -  Include in Check Right (Y=Yes, N=No).
640bA*    OPFLBL  -  Reprint from label.
640bA*    OPTLBL  -  Reprint to label.
     *
     * Data structure
     *
     D opdta2          ds
     D  opclvl                 1      3  0 inz(0)
     D  opcwra                 4      4
     D  opcwrb                 5      5
     D  opuwra                 6      6
     D  opuwrb                 7      7
     D  optext                 8     50
     D  operr                 51     52  0 inz(0)
     D  opcwgt                53     54  0 inz(0)
     D  oplpgm                55     64
     D  oppdev                65     74
     D  oppfrm                75     84
640bAD  opaisl                85     85
640bAD  optaxr                86     86
640bAD  opchkr                87     87
640bAD  opflbl                88     94  0
640bAD  optlbl                95    101  0
     D  optend               117    117
     *----------------------------------------------------------------
     *  *PICKLBA -  Label printing options for the standard pick,
     *              retail, and tote labels.
     *
     *----------------------------------------------------------------
     * Fields
     *
     *    OPLB1   -  Print standard pick label Y/N.   - Standard pick label
     *    OPCU1   -  Use cutter option Y/N.           - Standard pick label
     *    OPLP1   -  Label printing program.          - Standard pick label
     *    OPDV1   -  Printer device.                  - Standard pick label
     *    OPFM1   -  Form.                            - Standard pick label
     *
     *    OPLB2   -  Print retail label Y/N.          - Retail label
     *    OPCU2   -  Use cutter option Y/N.           - Retail label
     *    OPLP2   -  Label printing program.          - Retail label
     *    OPDV2   -  Printer device.                  - Retail label
     *    OPFM2   -  Form.                            - Retail label
     *
     *    OPLB3   -  Print tote label Y/N.            - Tote label
     *    OPCU3   -  Use cutter option Y/N.           - Tote label
     *    OPLP3   -  Label printing program.          - Tote label
     *    OPDV3   -  Printer device.                  - Tote label
     *    OPFM3   -  Form.                            - Tote label
     *
     * Data structure
     *
     D opdta3          ds
     D  oplb1                  1      1
     D  opcu1                  2      2
     D  oplp1                  3     12
     D  opdv1                 13     22
     D  opfm1                 23     32
     D  oplb2                 33     33
     D  opcu2                 34     34
     D  oplp2                 35     44
     D  opdv2                 45     54
     D  opfm2                 55     64
     D  oplb3                 65     65
     D  opcu3                 66     66
     D  oplp3                 67     76
     D  opdv3                 77     86
     D  opfm3                 87     96
     D  opend3               117    117
     *----------------------------------------------------------------
     *  *PICKLBB -  Label printing options for the pick list and
     *               ASN labels and pick list report.
     *
     *----------------------------------------------------------------
     * Fields
     *
     *    OPLB4   -  Print pick list label Y/N.       - Pick list label
     *    OPCU4   -  Use cutter option Y/N.           - Pick list label
     *    OPLP4   -  Label printing program.          - Pick list label
     *    OPDV4   -  Printer device.                  - Pick list label
     *    OPFM4   -  Form.                            - Pick list label
     *
     *    OPLB5   -  Print ASN label Y/N.             - ASN label
     *    OPCU5   -  Use cutter option Y/N.           - ASN label
     *    OPLP5   -  Label printing program.          - ASN label
     *    OPDV5   -  Printer device.                  - ASN label
     *    OPFM5   -  Form.                            - ASN label
     *
     *    OPLB6   -  Print pick list report Y/N.      - Pick list report
     *    OPCU6   -  Use cutter option Y/N.           - Pick list report
     *    OPLP6   -  Label printing program.          - Pick list report
     *    OPDV6   -  Printer device.                  - Pick list report
     *    OPFM6   -  Form.                            - Pick list report
     *
     *    OPLB7   -  Print PICK labels for ZONPKUP 1/2- Pick labels
     *
     * Data structure
     *
     D opdta4          ds
     D  oplb4                  1      1
     D  opcu4                  2      2
     D  oplp4                  3     12
     D  opdv4                 13     22
     D  opfm4                 23     32
     D  oplb5                 33     33
     D  opcu5                 34     34
     D  oplp5                 35     44
     D  opdv5                 45     54
     D  opfm5                 55     64
     D  oplb6                 65     65
     D  opcu6                 66     66
     D  oplp6                 67     76
     D  opdv6                 77     86
     D  opfm6                 87     96
     D  oplb7                 97     97
     D  opend4               117    117
     *----------------------------------------------------------------
     *  *FTP      -  FTP options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPFTP   -  Use FTP for exporting (Y,N)
     *    OPSRVR  -  FTP Server name
     *    OPUSER  -  FTP User id
     *    OPPWD   -  FTP Password
     *
     * Data structure
     *
     D opdata          ds
     D  opftp                  1      1
     D  opsrvr                 2     33
     D  opuser                34     48
     D  oppwd                 49     63
     D  opten2               117    117
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
     *  Variable
     *----------------------------------------------------------------
     D $pwhse          s              3  0
700dDD*$prten          s              5  0
     D @pgm            s              4
     D @pgm2           s              8
     D @set            s              6
     D fiflag          s              1
     D forevr          s              1
     D kycode          s                   like(opzcod)
     D kytype          s                   like(pstype)
     D kyzone          s                   like(opzzon)
     D lstzon          s                   like(psszon)
     D kycod3          s                   like(opzcod)
     D kycod4          s                   like(opzcod)
     D prflag          s              1
     D $ptmpl          s             10
     D @fmt            s              8
     D $xcwt           s              7  2
     D $pszon          s              6
     D wklabel         s              7  0
     D wktran          s              7  0
700aAD wkplid          s              7  0
     *----------------------------------------------------------------
     *  Dakota Client IDs
     *
      /COPY QCOPYSRC,ID#CITYWHO
      /COPY QCOPYSRC,ID#FINKLE
      /COPY QCOPYSRC,ID#ANDREWS
      /COPY QCOPYSRC,ID#COASTAL
     *----------------------------------------------------------------
     *  Customer id
     *
     D                 ds
     D  client                 1     10
     D  cliloc                11     20
     D @getcl          c                   const('GETCLIENT')
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   Command  (*PRINT, *REPRINT)
     *      $PWHSE  Warehouse
     *      $PRTID  Route Id
     *      $PRTE   Route
     *      $PTRUK  Truck
     *      $PSZON  Zone for *REPRINT
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $whse             3
     C                   parm                    $prtid            5
     C                   parm                    $prte             5
     C                   parm                    $ptruk           10
     C                   parm                    $value            7
     C                   parm                    $ptype            1
     C                   parm                    $pflbl            7
     C                   parm                    $ptlbl            7
     C                   move      $whse         $pwhse
700cDC***                move      $prte         $prten
     *----------------------------------------------------------------
     *  Main line
     *
     C                   select
     * by zone
     C                   when      $ptype = 'Z'
     C                   exsr      byzone
     * by transaction
     C                   when      $ptype = 'T'
     C                   exsr      bytran
     * by label
     C                   when      $ptype = 'L'
     C                   exsr      bylabel
700aA* by pallet
700aA*   A = Zone
700aA*   B = Transaction
700aA*   C = Pallet
700aAC                   when      $ptype = 'A'
700aAC                             or $ptype = 'B'
700aAC                             or $ptype = 'C'
700aAC                   exsr      bypallet
     C                   endsl
     *
     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *  byzone  Reprint by zone.
     *
     C     byzone        begsr
     *
     C                   eval      prflag = *off
     C                   eval      fiflag = *off
     C                   eval      $pszon = $value
     *
     *  Loop through pallets in reverse generation order.
     *
     C                   eval      kytype = 'O'
     C                   move      *hival        lstzon
     C     keyps3        setll     pltsum3
     C                   dow       forevr = forevr
     C     keyps3        reade     pltsum3                                79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *    Skip unwanted zones for *REPRINT.
     *
     C                   if        $pcmd = '*REPRINT'
     C                             and $pszon <> '*ALL'
     C                             and psszon <> $pszon
     C                   iter
     C                   endif
     *
     *    Skip duplicate zones.
     *
     C                   if        psszon = lstzon
     C                   iter
     C                   else
     C                   eval      lstzon = psszon
     C                   endif
     *
     *    Get picking options for zone.
     *
     C                   eval      kycode = '*PICKLBL'
     C                   eval      kyzone = psszon
     C                   eval      opdta2 = *blanks
     C     keyopz        chain     optionz                            79
     C                   if        *in79 = *off
     C                   eval      opdta2 = opzdta
     C                   endif
     C                   if        *in79
     C     keyop2        setll     optionz
     C     keyop2        reade     optionz                                78
     C                   if        *in78
     C                   eval      oplpgm = *blanks
640cAC                   else
640cAC                   eval      opdta2 = opzdta
     C                   endif
     C                   endif
     *
     C                   eval      opdta3 = *blanks
     C                   eval      kycod3 = '*PICKLBA'
     C                   eval      OPLP1 = *blanks
     C     opzkya        chain     optionz
     C                   if        %found(optionz)
     C                   eval      opdta3 = opzdta
     C                   eval      oplpgm = OPLP1
     C                   endif
     *
     C                   eval      opdta4 = *blanks
     C                   eval      kycod4 = '*PICKLBB'
     C     opzkyb        chain     optionz
     C                   if        %found(optionz)
     C                   eval      opdta4 = opzdta
     C                   endif
     *
     *      Use original line printer label program (pick list).
     *
     C                   if        oplb6 = 'Y'
     C                   call      oplp6
     C                   parm      '*PRINT  '    cmd
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm                    pscomp
     C                   parm                    pstzon
     C                   parm                    psgen
     C                   parm                    psszon
     C                   parm                    $ptruk
     C                   parm                    $prte
     C                   parm                    opdta2
     C                   endif
640dA*
640dAC                   select
640dAC                   when      oplb1 = 'Y'
640dAC                   eval      oplpgm = oplp1
640dAC                   when      oplb2 = 'Y'
640dAC                   eval      oplpgm = oplp2
640dAC                   when      oplb3 = 'Y'
640dAC                   eval      oplpgm = oplp3
640dAC                   when      oplb4 = 'Y'
640dAC                   eval      oplpgm = oplp4
640dAC                   endsl
     *
     *    Call picking label program to print labels for zone.
     *
     C                   if        oplpgm <> *blanks
     C                   movel     oplpgm        @pgm
     C                   move      oplpgm        @set
     C                   select
     *
     *      Use special label program.
     *
     C                   when      @pgm = 'PFMT'
     C                             and client = Andrews
     C                   call      'PFMTTLA'
     C                   parm      '*PRINT  '    cmd
     C                   parm                    @set
     C                   parm                    @fmt
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm                    pscomp
     C                   parm                    pstzon
     C                   parm                    psgen
     C                   parm                    psszon
     C                   parm                    $ptruk
     C                   parm                    $prte
     C                   parm                    opdta2
     C                   parm      0             $ptrn#
     C                   parm      0             $plbl#
     C                   parm      0             $pqty
     C                   parm      0             $pcwt
     *
     *      Use special label program.
     *
     C                   when      @pgm = 'PFMT'
     C                   call      'PFMT'
     C                   parm      '*RPRTZN '    cmd               8
     C                   parm                    @set
     C                   parm                    @fmt
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm                    pscomp
     C                   parm                    pstzon
     C                   parm                    psgen
     C                   parm                    psszon
     C                   parm                    $ptruk
     C                   parm                    $prte
     C                   parm                    opdta2
     C                   parm      0             $ptrn#            7 0
     C                   parm      0             $plbl#            7 0
     C                   parm      0             $pqty             5 0
     C                   parm      0             $pcwt             7 2
     *
     *      Use program to write labels to a file.
     *
     C                   when      oplpgm = 'PFILE'
     *
     *        First call to this program, init file member.
     *
     C                   if        $pcmd <> '*REPRINT'
     C                   if        fiflag = *off
     C                   call      'PFILEINZ'
     C                   parm                    $whse
     C                   parm                    $prte
     C                   parm                    $mbr             10
     C                   parm                    $prtid
     C                   exsr      ovrdbf
     C                   eval      fiflag = *on
     C                   endif
     C                   endif
     *
     *        Call program to write labels to file.
     *
     C                   call      oplpgm
     C                   parm      '*PRINT  '    cmd
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm                    pscomp
     C                   parm                    pstzon
     C                   parm                    psgen
     C                   parm                    psszon
     C                   parm                    $ptruk
     C                   parm                    $prte
     C                   parm                    opdta2
     *
     *      Use original line printer label program.
     *
     C                   other
     *
     *      Use original line printer label program.
     *
     C                   if        client = citywholesale
     C                             or client = finkle
     C                   select
     C                   when      client = citywholesale
     C                   eval      @set = 'ZBRCTW'
     C                   when      client = finkle
     C                   eval      @set = 'ZBRFDI'
     C                   endsl
     C                   call      'PFMT'
     C                   parm      '*PRINT  '    cmd
     C                   parm                    @set
     C                   parm                    @fmt
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm                    pscomp
     C                   parm                    pstzon
     C                   parm                    psgen
     C                   parm                    psszon
     C                   parm                    $ptruk
     C                   parm                    $prte
     C                   parm                    opdta2
     C                   parm      0             $ptrn#
     C                   parm      0             $plbl#
     C                   parm      0             $pqty
     C                   parm      0             $pcwt
     C                   endif
     *
     C                   endsl
     C                   endif
     *
     C                   enddo
     * Process Coastal labels for REFB
     C                   if        client = coastalsunbelt
     C                   eval      psszon = 'REFB  '
     *
     *    Get picking options for zone.
     *
     C                   eval      kycode = '*PICKLBL'
     C                   eval      kyzone = 'REF   '
     C                   eval      opdta2 = *blanks
     C     keyopz        chain     optionz                            79
     C                   if        *in79 = *off
     C                   eval      opdta2 = opzdta
     C                   endif
     C     keyps8        chain     pltsum8
     C                   if        %found(pltsum8)
     C                   eval      @set = 'ZBRCSP'
     C                   call      'PFMT'
     C                   parm      '*PRTREFB'    cmd               8
     C                   parm                    @set
     C                   parm                    @fmt
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm                    pscomp
     C                   parm                    pstzon
     C                   parm                    psgen
     C                   parm                    psszon
     C                   parm                    $ptruk
     C                   parm                    $prte
     C                   parm                    opdta2
     C                   parm      0             $ptrn#            7 0
     C                   parm      0             $plbl#            7 0
     C                   parm      0             $pqty             5 0
     C                   parm      0             $pcwt             7 2
     C                   endif
     C                   endif
     *
     *  If export file was created then see if we should FTP it.
     *
     C                   if        oplpgm = 'PFILE'  and
     C                             fiflag = *on  and
     C                             opftp = 'Y'

700cA*  If rte has '*' chg move to eval using %char
700dDC***                move      $prte         $prten

     *
     *      Close label program.
     *
     C                   call      oplpgm
     C                   parm      '*CLOSE  '    cmd
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm                    pscomp
     C                   parm                    pstzon
     C                   parm                    psgen
     C                   parm                    psszon
     C                   parm                    $ptruk
     C                   parm                    $prte
     C                   parm                    opdta2
     *
     *      Call program to FTP file.
     *
     C                   call      'PFILEFTP'
     C                   parm                    $mbr
650aAC                   parm                    $pwhse
700dDC***                parm                    $prten
700dMC                   parm                    $prte
650aAC                   parm                    $prtid
     C                   endif
     *
     *  Loop through DEVGRPR file and delete records for route.
     *
     C     keyddr        setll     devgrpr
     C                   dow       forevr = forevr
     C     keyddr        reade     devgrpr                                79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   delete    ddrrec
     C                   enddo
     C                   endsr

     *----------------------------------------------------------------
     *  bytran  Reprint by transaction.
     *
     C     bytran        begsr

     C     keyrh         chain     rtehed
     C                   eval      wktran = %dec($value:7:0)
     C                   eval      lbtrn# = wktran
     C     keyps12a      chain     pltsum12

     *  Get picking options for zone.

     C                   eval      kycode = '*PICKLBL'
     C     keyopz1       chain     optionz
     C                   if        %found(optionz)
     C                   eval      opdta2 = opzdta
     C                   endif
510 MC                   if        not %found(optionz)
     C     keyopz2       setll     optionz
     C     keyopz2       reade     optionz
     C                   if        %eof
     C                   eval      opclvl = 999
     C                   eval      opcwrb = 'N'
     C                   eval      opcwra = 'N'
     C                   eval      opuwrb = 'N'
     C                   eval      opuwra = 'N'
     C                   eval      optext = ' '
     C                   eval      operr  = 0
     C                   eval      opcwgt = 0
     C                   eval      oplpgm = ' '
     C                   eval      oppdev = ' '
     C                   eval      oppfrm = ' '
     C                   endif
     C                   endif

     C                   call      'PFMT'
     C                   parm      '*PRTTRN'     cmd
     C                   parm                    @set
     C                   parm                    @fmt
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm                    pscomp
     C                   parm                    pstzon
     C                   parm                    psgen
     C                   parm                    psszon
     C                   parm                    rhtruk
     C                   parm                    rhrte
     C                   parm                    opdta2
     C                   parm                    lbtrn#
     C                   parm                    lblbl#
     C                   parm                    lbqpck
     C                   parm      0             $xcwt

     C                   endsr

     *----------------------------------------------------------------
     *  bylabel Reprint by zone.
     *
     C     bylabel       begsr

     C     keyrh         chain     rtehed
     C                   eval      wklabel = %dec($value:7:0)
     C     wklabel       chain     label
     C     keyps12       chain     pltsum12

     *  Get picking options for zone.

     C                   eval      kycode = '*PICKLBL'
     C     keyopz1       chain     optionz
     C                   if        %found(optionz)
     C                   eval      opdta2 = opzdta
     C                   endif
510 MC                   if        not %found(optionz)
     C     keyopz2       setll     optionz
     C     keyopz2       reade     optionz
     C                   if        %eof
     C                   eval      opclvl = 999
     C                   eval      opcwrb = 'N'
     C                   eval      opcwra = 'N'
     C                   eval      opuwrb = 'N'
     C                   eval      opuwra = 'N'
     C                   eval      optext = ' '
     C                   eval      operr  = 0
     C                   eval      opcwgt = 0
     C                   eval      oplpgm = ' '
     C                   eval      oppdev = ' '
     C                   eval      oppfrm = ' '
     C                   endif
     C                   endif

640bAC                   eval      opflbl  = %dec($pflbl:7:0)
640bAC                   eval      optlbl  = %dec($ptlbl:7:0)

     C                   call      'PFMT'
     C                   parm      '*RPRTLB'     cmd
     C                   parm                    @set
     C                   parm                    @fmt
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm                    pscomp
     C                   parm                    pstzon
     C                   parm                    psgen
     C                   parm                    psszon
     C                   parm                    rhtruk
     C                   parm                    rhrte
     C                   parm                    opdta2
     C                   parm                    lbtrn#
     C                   parm                    lblbl#
     C                   parm                    lbqpck
     C                   parm      0             $xcwt

     C                   endsr

     *----------------------------------------------------------------
     *  bypallet Reprint by zone.
     *
700aA*   A = Zone
700aA*   B = Transaction
700aA*   C = Pallet

700aAC     bypallet      begsr

     C                   select
     C                   when      $value = '*ALL'
     *
     C                   eval      $pszon = $value
     *
     *  Loop through pallets in reverse generation order.
     *
     C                   eval      kytype = 'O'
     C                   move      *hival        lstzon
     C     keyps3        setll     pltsum3
     C                   dow       forevr = forevr
     C     keyps3        reade     pltsum3
     C                   if        %eof(pltsum3)
     C                   leave
     C                   endif
     *
     *    Skip unwanted zones for *REPRINT.
     *
     C                   if        $pcmd = '*REPRINT'
     C                             and $pszon <> '*ALL'
     C                             and psszon <> $pszon
     C                   iter
     C                   endif
     *
     *    Skip duplicate zones.
     *
     C                   if        psszon = lstzon
     C                   iter
     C                   else
     C                   eval      lstzon = psszon
     C                   endif
     *
     *    Get picking options for zone.
     *
     C                   eval      kycode = '*PICKLBL'
     C                   eval      kyzone = psszon
     C                   eval      opdta2 = *blanks
     C     keyopz        chain     optionz
     C                   if        %found(optionz)
     C                   eval      opdta2 = opzdta
     C                   endif
     C                   if        not %found(optionz)
     C     keyop2        setll     optionz
     C     keyop2        reade     optionz                                78
     C                   if        *in78
     C                   eval      oplpgm = *blanks
640cAC                   else
640cAC                   eval      opdta2 = opzdta
     C                   endif
     C                   endif
     *
     C                   eval      opdta3 = *blanks
     C                   eval      kycod3 = '*PICKLBA'
     C                   eval      OPLP1 = *blanks
     C     opzkya        chain     optionz
     C                   if        %found(optionz)
     C                   eval      opdta3 = opzdta
     C                   eval      oplpgm = OPLP1
     C                   endif
     *
     C                   eval      opdta4 = *blanks
     C                   eval      kycod4 = '*PICKLBB'
     C     opzkyb        chain     optionz
     C                   if        %found(optionz)
     C                   eval      opdta4 = opzdta
     C                   endif
     *
     *    Call picking label program to print labels for zone.
     *
     C                   if        oplpgm <> *blanks
     C                   movel     oplpgm        @pgm
     C                   move      oplpgm        @set
     C                   endif
     *
     * Print all Big Pallet labels by Zone
     *
     C                   call      'PFMT'
     C                   parm      '*RPRTP1 '    cmd
     C                   parm                    @set
     C                   parm      'BIGPAL'      @fmt
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm                    pscomp
     C                   parm                    pstzon
     C                   parm                    psgen
     C                   parm                    psszon
     C                   parm                    $ptruk
     C                   parm                    $prte
     C                   parm                    opdta2
     C                   parm      0             $ptrn#
     C                   parm      0             $plbl#
     C                   parm      0             $pqty
     C                   parm      0             $pcwt
     *
     C                   enddo

     C                   when      $ptype = 'A'
     *
     *    Get picking options for zone.
     *
     C                   eval      kycode = '*PICKLBL'
     C                   eval      $pszon = $value
     C                   eval      kyzone = $value
     C                   eval      opdta2 = *blanks
     C     keyopz        chain     optionz                            79
     C                   if        *in79 = *off
     C                   eval      opdta2 = opzdta
     C                   endif
     *
     C                   eval      opdta3 = *blanks
     C                   eval      kycod3 = '*PICKLBA'
     C                   eval      OPLP1 = *blanks
     C     opzkya        chain     optionz
     C                   if        %found(optionz)
     C                   eval      opdta3 = opzdta
     C                   eval      oplpgm = OPLP1
     C                   endif
     *
     C                   eval      opdta4 = *blanks
     C                   eval      kycod4 = '*PICKLBB'
     C     opzkyb        chain     optionz
     C                   if        %found(optionz)
     C                   eval      opdta4 = opzdta
     C                   endif
     *
     *    Call picking label program to print labels for zone.
     *
     C                   if        oplpgm <> *blanks
     C                   movel     oplpgm        @pgm
     C                   move      oplpgm        @set
     C                   endif

     C     keyrh         chain     rtehed
     C     keyps8a       chain     pltsum8

     C                   call      'PFMT'
     C                   parm      '*RPRTP1'     cmd
     C                   parm                    @set
     C                   parm      'BIGPAL'      @fmt
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm                    pscomp
     C                   parm                    pstzon
     C                   parm                    psgen
     C                   parm                    psszon
     C                   parm                    rhtruk
     C                   parm                    rhrte
     C                   parm                    opdta2
     C                   parm                    lbtrn#
     C                   parm                    lblbl#
     C                   parm                    lbqpck
     C                   parm      0             $xcwt

     C                   when      $ptype = 'B'

     C                   eval      wktran = %dec($value:7:0)
     C                   eval      lbtrn# = wktran
     C     keyps12a      chain     pltsum12

     *  Get picking options for zone.

     C                   eval      kycode = '*PICKLBL'
     C     keyopz1       chain     optionz
     C                   if        %found(optionz)
     C                   eval      opdta2 = opzdta
     C                   endif
510 MC                   if        not %found(optionz)
     C     keyopz2       setll     optionz
     C     keyopz2       reade     optionz
     C                   if        %eof
     C                   eval      opclvl = 999
     C                   eval      opcwrb = 'N'
     C                   eval      opcwra = 'N'
     C                   eval      opuwrb = 'N'
     C                   eval      opuwra = 'N'
     C                   eval      optext = ' '
     C                   eval      operr  = 0
     C                   eval      opcwgt = 0
     C                   eval      oplpgm = ' '
     C                   eval      oppdev = ' '
     C                   eval      oppfrm = ' '
     C                   endif
     C                   endif
     *
     C     keyrh         chain     rtehed

     C                   if        oplpgm <> *blanks
     C                   movel     oplpgm        @pgm
     C                   move      oplpgm        @set
     C                   endif

     C                   call      'PFMT'
     C                   parm      '*RPRTP2'     cmd
     C                   parm                    @set
     C                   parm      'BIGPAL'      @fmt
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm                    pscomp
     C                   parm                    pstzon
     C                   parm                    psgen
     C                   parm                    psszon
     C                   parm                    rhtruk
     C                   parm                    rhrte
     C                   parm                    opdta2
     C                   parm      wktran        lbtrn#
     C                   parm                    lblbl#
     C                   parm                    lbqpck
     C                   parm      0             $xcwt

     C                   when      $ptype = 'C'
     *
     *    Get picking options for zone.
     *
     C                   eval      wkplid = %dec($value:7:0)
     C     keyps15       chain     pltsum15

     C                   eval      kycode = '*PICKLBL'
     C                   eval      $pszon = psszon
     C                   eval      kyzone = psszon
     C                   eval      opdta2 = *blanks
     C     keyopz        chain     optionz                            79
     C                   if        *in79 = *off
     C                   eval      opdta2 = opzdta
     C                   endif
     *
     C                   eval      opdta3 = *blanks
     C                   eval      kycod3 = '*PICKLBA'
     C                   eval      OPLP1 = *blanks
     C     opzkya        chain     optionz
     C                   if        %found(optionz)
     C                   eval      opdta3 = opzdta
     C                   eval      oplpgm = OPLP1
     C                   endif
     *
     C                   eval      opdta4 = *blanks
     C                   eval      kycod4 = '*PICKLBB'
     C     opzkyb        chain     optionz
     C                   if        %found(optionz)
     C                   eval      opdta4 = opzdta
     C                   endif
     *
     C                   if        oplpgm <> *blanks
     C                   movel     oplpgm        @pgm
     C                   move      oplpgm        @set
     C                   endif

     C     keyrh         chain     rtehed

     C                   call      'PFMT'
     C                   parm      '*RPRTP3'     cmd
     C                   parm                    @set
     C                   parm      'BIGPAL'      @fmt
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm                    pscomp
     C                   parm                    pstzon
     C                   parm                    psgen
     C                   parm                    psszon
     C                   parm                    rhtruk
     C                   parm                    rhrte
     C                   parm                    opdta2
     C                   parm      wkplid        lbtrn#
     C                   parm                    lblbl#
     C                   parm                    lbqpck
     C                   parm      0             $xcwt
     C                   endsl

     C                   endsr
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
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client
     C                   parm                    cliloc
     *
     C                   eval      forevr = *off
     *
     *  Define partial key for PLTSUM3 file.
     *
     C     keyps3        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kytype
     *
     *  Define partial key for PLTSUM8 file.
     *
     C     keyps8        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    psszon
     *
     C     keyps8a       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    $pszon
     *
     *  Define partial key for PLTSUM12 file.
     *
     C     keyps12       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    lbtrn#
     *
     *  Define partial key for PLTSUM12 file.
     *
     C     keyps12a      klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    wktran
700aA*
700aA*  Define key for PLTSUM15 file.
700aA*
700aAC     keyps15       klist
700aAC                   kfld                    $pwhse
700aAC                   kfld                    $prtid
700aAC                   kfld                    wkplid
     *
     *  Define partial key for options file.
     *
     C     keyopz        klist
     C                   kfld                    kycode
     C                   kfld                    $pwhse
     C                   kfld                    $ptmpl
     C                   kfld                    kyzone
     *
     C     opzkya        klist
     C                   kfld                    kycod3
     C                   kfld                    $pwhse
     C                   kfld                    $ptmpl
     C                   kfld                    kyzone
     *
     C     opzkyb        klist
     C                   kfld                    kycod4
     C                   kfld                    $pwhse
     C                   kfld                    $ptmpl
     C                   kfld                    kyzone
     *
     *  Define partial key for options file.
     *
     C     keyop2        klist
     C                   kfld                    kycode
     C                   kfld                    $pwhse
640cD ***                kfld                    $ptruk
640cMC                   kfld                    $ptmpl
     *
     *  Define key for options file.
     *
     C     keyop         klist
     C                   kfld                    opwhse
     C                   kfld                    opcode
     *
     *  Define partial key for DEVGRPR file.
     *
     C     keyddr        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
     *  Define key for TRUCKH file.
     *
     C     keyth         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptruk

     C     keyrh         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid

     *    OPTIONZ file.

     C     keyopz1       klist
     C                   kfld                    kycode
     C                   kfld                    pswhse
640 MC                   kfld                    $ptmpl
     C                   kfld                    psszon
     C
     C     keyopz2       klist
     C                   kfld                    kycode
     C                   kfld                    pswhse
640 MC                   kfld                    $ptmpl
     *
     *   Get FTP options from options file.
     *
     C                   eval      opwhse = 0
     C                   eval      opcode = '*FTP    '
     C     keyop         chain     options                            79
     C                   if        *in79
     C                   eval      opftp = 'N'
     C                   endif
     *
     * Get Zone Template Code if Template type is T=Truck
     *
     C                   move      $whse         $pwhse
     C     keyth         chain     truckh
     C                   if        %found(truckh)
     C                             and thtype = 'T'
     C                   eval      $ptmpl =  thztmp
     C                   else
     C                   eval      $ptmpl =  $ptruk
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETOPT  Get picking options for zone.
     *
     C     getopt        begsr
     *
     C                   eval      kycode = '*PICKLBL'
     C     keyopz        chain     optionz                            79
     C                   if        *in79
     C                   eval      oplpgm = *blanks
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OVRDBF  Override export file.
     *
     C     ovrdbf        begsr
     *
     *      Override database file.
     *
     *          OVRDBF FILE(EXPFPLBL) MBR(XXXXXXXXXX)
     *
     C                   movea     ovr(1)        a80
     C                   movea     $mbr          a80(27)
     C                   movea     a80           qcmd
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
     *
     C                   endsr
**   OVRDBF statment
OVRDBF FILE(EXPFPLBL) MBR(XXXXXXXXXX)
