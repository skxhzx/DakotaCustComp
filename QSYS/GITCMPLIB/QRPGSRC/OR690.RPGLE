      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave #203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR690     Print Transaction Audit Report
     *  12 April 2004
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
417 A*    04/12/04  MLB  4.17
     *      - Created.
     *
520 A*    02/04/09  MLB  5.20
     *      - Fix: Revised program to look for type B=Bulk picks
     *        before looking for order pallet picks.
     *
520aA*    05/08/09  CWM  5.20a
     *      - Enh: For Report Distribution Changes
     *
530 A*    11/10/09  JCJ  5.30
     *      - Revised to use TRUCKH to lookup Template code for
     *        Zone references.
     *
530aA*    02/17/10  MLB  5.30
     *      - Enh: Revised pgm to add support for zone templates chang
     *        and zone detail enhancements.
     *
640aA*    01/13/12  JCJ  6.40a
     *      - Fix: Commented out call to pick list report.  Pick list
     *        is already printed in OR640.
     *
650aA*    12/18/13  JCJ  6.50a
     *      - Enh: Changed call to OR695 to use $PCMD instead of
     *        *REPRINT.
     *
740 A*    07/02/20  MLB  7.40
     *      - Revised to use KYTYPE='P' for TruckBuilder Enhanced.
     *
     *----------------------------------------------------------------
CDIaA*  Client Custom Revisions: Customized Distribution
     *
CDIaA*    05/15/12  RBD  CDIa
     *      - Added parm to OR695 for route page so that each time
     *        it's called to print another zone, which in effect is
     *        another report, the route page, rather than trans page,
     *        can be printed across zones/reports, rather than
     *        starting over at page 1 for each new zone/report.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Earl's Organic Produce
     *
EOPa *    01/04/21  RTR  EOPa
     *      - Do not run OR695 for Bulk type/zone.
     *----------------------------------------------------------------
     *  Notes
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
530 AFtruckh    if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
EOPaA*----------------------------------------------------------------
EOPaA*  Customer id
EOPaA /copy qcopysrc,id#eop
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
     *
     * Data structure
     *
530aDD*opzdta          ds
530aMD opdta2          ds
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
     D  optend               117    117
530aA*
530aA*----------------------------------------------------------------
530aA*  *PICKLBA -  Label printing options for the standard pick,
530aA*              retail, and tote labels.
530aA*
530aA*     08/12/09  RBD  5.20  P#00219
530aA*       - Added record type *PICKLBA which holds printing info
530aA*         for the standard pick, retail, and tote labels.
530aA*
530aA*----------------------------------------------------------------
530aA* Fields
530aA*
530aA*    OPLB1   -  Print standard pick label Y/N.   - Standard pick label
530aA*    OPCU1   -  Use cutter option Y/N.           - Standard pick label
530aA*    OPLP1   -  Label printing program.          - Standard pick label
530aA*    OPDV1   -  Printer device.                  - Standard pick label
530aA*    OPFM1   -  Form.                            - Standard pick label
530aA*
530aA*    OPLB2   -  Print retail label Y/N.          - Retail label
530aA*    OPCU2   -  Use cutter option Y/N.           - Retail label
530aA*    OPLP2   -  Label printing program.          - Retail label
530aA*    OPDV2   -  Printer device.                  - Retail label
530aA*    OPFM2   -  Form.                            - Retail label
530aA*
530aA*    OPLB3   -  Print tote label Y/N.            - Tote label
530aA*    OPCU3   -  Use cutter option Y/N.           - Tote label
530aA*    OPLP3   -  Label printing program.          - Tote label
530aA*    OPDV3   -  Printer device.                  - Tote label
530aA*    OPFM3   -  Form.                            - Tote label
530aA*
530aA* Data structure
530aA*
530aAD opdta3          ds
530aAD  oplb1                  1      1
530aAD  opcu1                  2      2
530aAD  oplp1                  3     12
530aAD  opdv1                 13     22
530aAD  opfm1                 23     32
530aAD  oplb2                 33     33
530aAD  opcu2                 34     34
530aAD  oplp2                 35     44
530aAD  opdv2                 45     54
530aAD  opfm2                 55     64
530aAD  oplb3                 65     65
530aAD  opcu3                 66     66
530aAD  oplp3                 67     76
530aAD  opdv3                 77     86
530aAD  opfm3                 87     96
530aAD  opend3               117    117
530aA*----------------------------------------------------------------
530aA*  *PICKLBB -  Label printing options for the pick list and
530aA*               ASN labels and pick list report.
530aA*
520iA*     08/12/09  RBD  5.20  P#00219
520iA*       - Added record type *PICKLBB which holds printing info
520iA*         for the pick list and ASN labels and pick list report.
530aA*
530aA*----------------------------------------------------------------
530aA* Fields
530aA*
530aA*    OPLB4   -  Print pick list label Y/N.       - Pick list label
530aA*    OPCU4   -  Use cutter option Y/N.           - Pick list label
530aA*    OPLP4   -  Label printing program.          - Pick list label
530aA*    OPDV4   -  Printer device.                  - Pick list label
530aA*    OPFM4   -  Form.                            - Pick list label
530aA*
530aA*    OPLB5   -  Print ASN label Y/N.             - ASN label
530aA*    OPCU5   -  Use cutter option Y/N.           - ASN label
530aA*    OPLP5   -  Label printing program.          - ASN label
530aA*    OPDV5   -  Printer device.                  - ASN label
530aA*    OPFM5   -  Form.                            - ASN label
530aA*
530aA*    OPLB6   -  Print pick list report Y/N.      - Pick list report
530aA*    OPCU6   -  Use cutter option Y/N.           - Pick list report
530aA*    OPLP6   -  Label printing program.          - Pick list report
530aA*    OPDV6   -  Printer device.                  - Pick list report
530aA*    OPFM6   -  Form.                            - Pick list report
530aA*
530aA*    OPLB7   -  Print PICK labels for ZONPKUP 1/2- Pick labels
530aA*
530aA* Data structure
530aA*
530aAD opdta4          ds
530aAD  oplb4                  1      1
530aAD  opcu4                  2      2
530aAD  oplp4                  3     12
530aAD  opdv4                 13     22
530aAD  opfm4                 23     32
530aAD  oplb5                 33     33
530aAD  opcu5                 34     34
530aAD  oplp5                 35     44
530aAD  opdv5                 45     54
530aAD  opfm5                 55     64
530aAD  oplb6                 65     65
530aAD  opcu6                 66     66
530aAD  oplp6                 67     76
530aAD  opdv6                 77     86
530aAD  opfm6                 87     96
530aAD  oplb7                 97     97
530aAD  opend4               117    117
530aA*
414aA*----------------------------------------------------------------
414aA*  *FTP      -  FTP options
414aA*----------------------------------------------------------------
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
740 A
740 A*----------------------------------------------------------------
740 A*  Called Programs Prototypes
740 A*----------------------------------------------------------------
740 A
740 Ad/copy qcopysrc,p.gettbtyp
740 A
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
530aA*----------------------------------------------------------------
530aA*  Variable
530aA*----------------------------------------------------------------
530aAD @pgm            s              4
530aAD @pgm2           s              8
530aAD kycod3          s                   like(opzcod)
530aAD kycod4          s                   like(opzcod)
740 Ad tbEnhanced      s               n
740 Ad tbPalletType    s              1
740 Ad tbType          s              1
740 Ad tbWhse          s              3  0
530aA*
     *----------------------------------------------------------------
     * Work Variable
     *----------------------------------------------------------------
CDIaAD $ppage          s              4  0
     D $pwhse          s              3  0
     D fiflag          s              1
     D forevr          s              1
     D kycode          s                   like(opzcod)
     D kytype          s                   like(pstype)
     D kyzone          s                   like(opzzon)
     D lstzon          s                   like(psszon)
     D prflag          s              1
530 AD $ptmpl          s             10
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
     *      $PDEV   Printer for report
     *      $PFORM  Formtype
CDIaA*      $PPAGE  Route page number
     *
     *    Returned Parameters
CDIaA*      $PPAGE  Route page number
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
     C                   parm                    $pszon            6
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     *
740 DC*                  move      $whse         $pwhse
530 A*
530 A* Get Zone Template Code if Template type is T=Truck
530 A*
640 AC                   move      $whse         $pwhse
530 AC     keyth         chain     truckh
530 AC                   if        %found(truckh) and thtype = 'T'
530 AC                   eval      $ptmpl =  thztmp
530 AC                   else
530 AC                   eval      $ptmpl =  $ptruk
530 AC                   endif
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      prflag = *off
     C                   eval      fiflag = *off
     *
     *  Loop through pallets in reverse generation order.
     *
520 D*                    MOVE 'O'       KYTYPE
EOPaAc                   select
EOPaAc                   when      client = EarlsOrganic
EOPaAc                   eval      kytype = 'O'
EOPaAc                   other
520 MC                   eval      kytype = 'B'
EOPaAc                   endsl
520 AC     #top          tag
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
     C                   if        $pcmd = '*REPRINT'  and
     C                             $pszon <> '*ALL'  and
     C                             psszon <> $pszon
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
530aAC                   eval      opdta2 = *blanks
     C     keyopz        chain     optionz                            79
530 AC                   if        *in79 = *off
530 AC                   eval      opdta2 = opzdta
530 AC                   endif
     C                   if        *in79
     C     keyop2        setll     optionz
     C     keyop2        reade     optionz                                78
     C                   if        *in78
     C                   eval      oplpgm = *blanks
     C                   endif
     C                   endif
530aA*
530aAC                   eval      opdta3 = *blanks
530aAC                   eval      kycod3 = '*PICKLBA'
530aAC                   eval      OPLP1 = *blanks
530aAC     opzkya        chain     optionz
530aAC                   if        %found(optionz)
530aAC                   eval      opdta3 = opzdta
530aAC                   eval      oplpgm = OPLP1
530aAC                   endif
530aA*
530aAC                   eval      opdta4 = *blanks
530aAC                   eval      kycod4 = '*PICKLBB'
530aAC     opzkyb        chain     optionz
530aAC                   if        %found(optionz)
530aAC                   eval      opdta4 = opzdta
530aAC                   endif
640aD*
640aD*      Use original line printer label program.
640aD*
640aD ***                if        oplb6 = 'Y'
640aD ***                call      oplp6
640aD ***                parm      '*PRINT  '    cmd
640aD ***                parm                    $pwhse
640aD ***                parm                    $prtid
640aD ***                parm                    pscomp
640aD ***                parm                    pstzon
640aD ***                parm                    psgen
640aD ***                parm                    psszon
640aD ***                parm                    $ptruk
640aD ***                parm                    $prte
640aD ***                parm                    opdta2
640aD ***                endif
     *
     *    Call picking label program to print labels for zone.
     *
     C                   if        oplpgm <> *blanks
     *
     *      Use original line printer label program.
     *
520AAC                   eval      $once = *blanks
520AAC                   eval      wkpctr = 1
520AAC                   eval      $len = 1024
520AA*
520AAC                   dou       wkpctr = 0
520AAC                   call      'RPT120'
520AAC                   parm      'OR695PR'     $prtf            10
520AAC                   parm                    wkpctr           15 5
520AAC                   parm                    $cmd           1024
520AAC                   parm                    $once             1
520AAC                   if        wkpctr <> 0
520AAC     wkpctr        add       1             wkpctr
520AAC                   call      'QCMDEXC'
520AAC                   parm                    $cmd
520AAC                   parm                    $len             15 5
520AA*
     C                   call      'OR695'
650aD ***                parm      '*REPRINT'    cmd               8
650aMC                   parm                    $pcmd
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm                    pscomp
     C                   parm                    pstzon
     C                   parm                    psgen
     C                   parm                    psszon
     C                   parm                    $ptruk
     C                   parm                    $prte
530aD ***                parm                    opzdta
530aMC                   PARM                    opdta2
     C                   parm      0             $ptrn             7 0
     C                   parm                    $pdev
     C                   parm                    $pform
CDIaAC                   parm                    $ppage
520AAC                   endif
520AA*
520AAC                   if        $once = 'Y'
520AAC                   eval      wkpctr = *zeros
520AAC                   endif
520AA*
520AAC                   enddo
     *
     C                   endif
     *
     C                   enddo
520 A*
520 A*    Bulk picks processed, process order picks next.
520 AC                   if        kytype = 'B'
740 DC*                  eval      kytype = 'O'
740 MC                   eval      kytype = tbPalletType
520 AC                   goto      #top
520 AC                   endif
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
     C                   eval      forevr = *off
740 AC                   move      $whse         $pwhse
510bA*
510bA* Get client id.
510bA*
510bAC                   call      'GETCLIENT'
510bAC                   parm                    client           10
510bAC                   parm                    clientloc        10
     *
     *  Define partial key for PLTSUM3 file.
     *
     C     keyps3        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kytype
     *
     *  Define partial key for options file.
     *
     C     keyopz        klist
     C                   kfld                    kycode
     C                   kfld                    $pwhse
530 D ***                kfld                    $ptruk
530 MC                   kfld                    $ptmpl
     C                   kfld                    kyzone
530aA*
530aAC     opzkya        klist
530aAC                   kfld                    kycod3
530aAC                   kfld                    $pwhse
640 D ***                kfld                    $ptruk
640 MC                   kfld                    $ptmpl
530aAC                   kfld                    kyzone
530aA*
530aAC     opzkyb        klist
530aAC                   kfld                    kycod4
530aAC                   kfld                    $pwhse
640 D ***                kfld                    $ptruk
640 MC                   kfld                    $ptmpl
530aAC                   kfld                    kyzone
     *
     *  Define partial key for options file.
     *
     C     keyop2        klist
     C                   kfld                    kycode
     C                   kfld                    $pwhse
530cD ***                kfld                    $ptruk
530cMC                   kfld                    $ptmpl
     *
     *  Define key for options file.
     *
     C     keyop         klist
     C                   kfld                    opwhse
     C                   kfld                    opcode
530 A*
530 A*  Define key for TRUCKH file.
530 A*
530 AC     keyth         klist
530 AC                   kfld                    $pwhse
530 AC                   kfld                    $ptruk
740 Ac*
740 Ac*   Determine if using TruckBUilder Enhanced
740 Ac*
740 A /free
740 A      tbWhse = $pwhse;
740 A      GetTBType(tbWhse: $prtid: tbType);
740 A      if tbType = 'E';
740 A        tbEnhanced = *on;
740 A        tbPalletType = 'P';
740 A      else;
740 A        tbEnhanced = *off;
740 A        tbPalletType = 'O';
740 a      endif;
740 A /end-free
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
CDIaAC                   eval      $ppage = 0
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
