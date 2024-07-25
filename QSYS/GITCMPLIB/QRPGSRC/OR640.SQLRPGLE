      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1957
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR640     Truck build - Print labels
     *  24 June 1997
     *  Dave Sommerville
     *  Hemant Kapadia
     *
     *----------------------------------------------------------------
     *  Revisions
     *
402 A*    07/28/97  DAS  4.02
     *      - Added logic to get program of first zone (alphabetically)
     *        when zone is not found in options file.
     *
414 A*    04/12/00  DAS  4.14
     *      - Modified to work with new PFMT label printing program.  )
     *        (See notes below)
414aA*    08/30/00  DAS  4.14a
     *      - Modified to work with new PFILE label printing program. )
     *        (See notes below)
     *
500a *    05/09/05  HNK  5.00a
     *      - Add 4 new parameters to PFMT call.                      )
     *
520 A*    08/20/08  MLB  5.20  P#00133
     *      - Revise program to pass route id to PFILEINZ pgm.
     *
520aA*    06/27/08  HNK  5.20a
     *      - Add support for client ID and call PFMTXXX for CTW.     )
     *
530 A*    01/29/07  DAS  5.30
     *      - Added file DEVGRPR.
     *      - Added code to clear all corresponding records for the
     *        route from DEVGRPR.
     *      - Revised to use TRUCKH to lookup Template code for
     *        Zone references.
     *
530aA*    12/11/09  JCJ  5.30a
     *      - added *PCKLLBA for file optionz to get LBLPGM.
     *      - added *PCKLLBB for file optionz to get LBLPGM.
530bA*    01/19/10  MLB  5.30b
     *      - Revised pgm to change OPZKYB to use $PTMPL instead
     *        $PTRUK field.
     *      - Revised pgm to load $ptmpl into $ptruk on call to
     *        pick list print pgm.
530cA*    09/01/10  JCJ  5.30c
     *      - Removed AFS custom code.  Change was made in pick list
     *        program to handle this processing.
640aA*    02/08/12  JCJ  6.40a
     *      - Fix: Change klist keyop2 to use $ptmpl instead of
     *        $ptruk. This will allow undefined zones to print
     *        labels.
640bA*    02/24/12  JCJ  6.40b
     *      - Fix: added other label program to the logic for
     *        extracting the label printing program and label set
     *        name.
650aA*    12/17/13  RTR  6.50a
     *      - Revised to pass whse, rte, rtid to PFILEFTP.
650bA*    03/18/14  RTR  6.50b
     *      - Revised to handle PFILES for staging label file program.
     *
700aA*    06/09/15  RTR  7.00a
     *      - Fix: If error calling PFILEFTP, retry.
700bA*    09/02/15  MLB  7.00b
     *      - Fix: Revised pgm to bypass PLTSUM rcds when PSTZON, PSPZON
     *        PSSZON are blank and PSTRN# = 0. Was causing EXPFPLBL file
     *        to not be sent via FTP when pgm = PFILE. Found at RFS.
700cA*    04/05/16  NLK  7.00c
     *      - Fix: Revised 650a and moved line $prte into $prten at CALL
     *        Blows up when * in $prte like '*AMP*' used at Greenleaf
700dA*    05/27/16  RTR  7.00d
     *      - Fix: Changing route to char to fix mod 650a.
720aA*    04/16/18  DAS  7.20a
     *      - Revised *INZSR to get dataarea DragDrop2.
     *      - Revised to do 2 loops for DD2. The first loop is for
     *        PSTYPE = 'O' and Gen > 1. The second loop is for
     *        PSTYPE = 'P' and Gen = 1.
720bA*    08/13/18  KDE  720b
     *      - Enh: Added stage batch update that was processing
     *        in PFILES
720cA*    09/11/18  DAS  7.20c
     *      - Revised to call GetTBType instead of reading
     *        data area dragdrop2 directly.
     *      - Replaced dd2 with tbEnhanced.
750aA*    04/01/21  DAS  7.50a
     *      - Revised to set $pwhse before call to GetTBType.
750bA*    06/14/21  MLB  7.50b
     *      - Fix: Revised 7.20b mod to save OPBATID returned on call
     *        from PFILES to be used to update STGBATCH rcd once rte
     *        processing is complete. Found at Nicholas when they added
     *        pick zone that was still going to print labels, but all
     *        other pick zones were doing PFILES processing. New zone
     *        was added at very end causing loss of batchID.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Chef's Warehouse/Dairyland
     *
DRYaA*    12/17/13  RTR  DRYa
     *      - Added Dairyland to FRFb mod.
DRYbA*    02/12/14  RTR  DRYb
     *      - Changed to only run PFILE once for Chef's Whse.
DRYcA*    03/06/14  MLB  DRYc
     *      - Fix: Change to original DRYa mod. Revised routine
     *        ZZPFILE to call pgm, PFILEFTP so that EXPFPLBL file
     *        will be sent to Host.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Wholesale
     *
CTWaA*    02/10/09  RBD  CTWa
     *      - Added call to PFMT with set ZBRCTW.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Finkle Distributing
     *
FDIaA*    02/10/09  RBD  FDIa
     *      - Added call to PFMT with set ZBRFDI.
FDIbA*    04/06/09  MLB  FDIb
     *      - Revised FDIa mod to add code to process OVRPRTF
     *        cmd to direct pick labels to ZEBRA3.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Anderson-Dubose
     *
ADCa *    08/23/17  RTR  ADCa
     *      - Enh: Added client ADC
ADCb *    08/23/17  RTR  ADCb
     *      - Enh: Added external call at end to process data.
     *      - Revised pgm to call ADC pgm, RunJDE/ProdPick. Triggers
     *        routes to be processed that were written to EXPSPLBL.
ADCc *    09/19/19  RTR  ADCc
     *      - Fix: Changed mod ADCb to use old-style program call
     *        instead of prototype call so that program will compile
     *        on other systems.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Andrews
     *
AFSaA*    06/09/10  JCJ  AFSa
     *      - Changed PFMT calling program to PFMTTLA.
AFSbA*    07/28/10  RH   AFSb
     *      - Revised pgm to load truck  into $ptruk on call to
     *        pick list print pgm.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt
     *
CSPaA*    09/01/10  JCJ  CSPa
     *      - Revised pgm to load truck into $ptruk on call to
     *        pick list print pgm.
     *
CSPb *    02/15/11  GJA  CSPb
     *      - Enh:  REFB label processing.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fox River
     *
FRFaA*    06/15/10  JCJ  FRFa
     *      - Added call to PFMT2 to print Pallet Labels
FRFbA*    11/05/10  MLB  FRFb
     *      - Revised program to call pgm PFILE along with PFMT
     *        but not on reprints.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval
     *
SVLaA*    04/13/12  JCJ  SVL
     *      - Added call to PLST40WS.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Agar
     *
ASC A*    04/03/12  RTR  ASC
     *      - Revised to not call PFILEINZ if client = Agar
     *
ASCbA*    06/20/12  RTR  ASCb
     *      - Revised to only call PFILE on first time through program
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Panos
     *
PAN A*    05/19/17  MR   PAN
     *      - Revised to not call PFILES for Panos. For Panos,
     *           PFILES will be called in the export process.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jake's Foods
     *
JFF A*    05/29/18  MLB  JFF
     *      - Revised pgm to call QSNDDTAQ for LTBBPDQQ to send
     *        trigger to wake poller for route to be processed back
     *        to PwrWhse.
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
414aAFoptions   if   e           k disk
530 AFdevgrpr   uf   e           k disk
530 AFtruckh    if   e           k disk
CSPbAFpltsum8   if   e           k disk    rename(psrec:psrec8)
414aA*----------------------------------------------------------------
414aA*  Table and array definitions
414aA*
414aAD a80             s              1    dim(80)
414aAD ovr             s             80    dim(1) ctdata perrcd(1)
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
530aD ***opzdta          ds
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
720bAD  opbatid              100    111
     D  optend               117    117
     *----------------------------------------------------------------
530aA*  *PICKLBA -  Label printing options for the standard pick,
530aA*              retail, and tote labels.
     *
530aA*     08/12/09  RBD  5.20  P#00219
530aA*       - Added record type *PICKLBA which holds printing info
530aA*         for the standard pick, retail, and tote labels.
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
520iA*  *PICKLBB -  Label printing options for the pick list and
520iA*               ASN labels and pick list report.
     *
520iA*     08/12/09  RBD  5.20  P#00219
520iA*       - Added record type *PICKLBB which holds printing info
520iA*         for the pick list and ASN labels and pick list report.
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
530aA*    OPLB7   -  Print PICK labels for ZONPKUP 1/2- Pick labels
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
530aAD  oplb7                 97     97
     D  opend4               117    117
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
DRYcAD $prten          s              5  0
     D @pgm            s              4
530aAD @pgm2           s              8
     D @set            s              6
     D fiflag          s              1
ASCbAD asflag          s               n
     D forevr          s              1
     D kycode          s                   like(opzcod)
     D kytype          s                   like(pstype)
     D kyzone          s                   like(opzzon)
     D lstzon          s                   like(psszon)
530aAD kycod3          s                   like(opzcod)
530aAD kycod4          s                   like(opzcod)
DRYbAD pfilerun        s               n
     D prflag          s              1
530 AD $ptmpl          s             10
FRFbAD savopdta2       s                   like(opdta2)
750bAD savopbatid      s                   like(opbatid)
750bAD                                     inz(' ')
720aAD loop            s              1  0
720cAd tbEnhanced      s               n
720cAd tbPalletType    s              1
720cAd tbType          s              1
720cAd tbWhse          s              3  0
650aA*----------------------------------------------------------------
650aA*  Prototypes
650aA*----------------------------------------------------------------
ADCbAD*RunJDE          pr                  extpgm('PROCPICK')
ADCbAD*  pWhse                        3    const

     *----------------------------------------------------------------
     *  Dakota Client IDs
     *
CTWaA /COPY QCOPYSRC,ID#CITYWHO
FDIaA /COPY QCOPYSRC,ID#FINKLE
AFSaA /COPY QCOPYSRC,ID#ANDREWS
CSPaA /COPY QCOPYSRC,ID#COASTAL
FRFaA /COPY QCOPYSRC,ID#FRF
DRYaA /COPY QCOPYSRC,ID#DAIRYLA
SVLaA /COPY QCOPYSRC,ID#SAVAL
PANaA /COPY QCOPYSRC,ID#PAN
ADCaA /copy qcopysrc,id#adc
JFF A /copy qcopysrc,id#jff
     *----------------------------------------------------------------
520aA*  Customer id
520aA*
520aaD                 ds
520aAD  client                 1     10
520aAD  cliloc                11     20
520aAD @getcl          c                   const('GETCLIENT')

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

720cAd/copy qcopysrc,p.gettbtyp

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
     C                   parm                    $pszon            6
     C                   move      $whse         $pwhse
DRYcAC                   if        client = Dairyland
DRYcAC                   move      $prte         $prten
DRYcAC                   endif
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      prflag = *off
414aAC                   eval      fiflag = *off

720aA*  For DD2 we need to do 2 loops through the file
720aA*     The first loop is for PSTYPE='O', Gen > 1 pallets.
720aA*     The second loop is for PSTYPE='P', Gen = 1 pallets.
720aA*     'P' pallets were created with DD2.
720aA
720aAC                   for       loop = 1 to 2
720aA
720aA*    Only do 1 loop if not using DD2
720aA
720cMC                   if        not tbEnhanced and loop = 2
720aAC                   leave
720aAC                   endif
     *
     *  Loop through pallets in reverse generation order.
     *
720cMC                   if        tbEnhanced and loop = 2
720aAC                   eval      kytype = 'P'
720aAC                   else
     C                   eval      kytype = 'O'
720aAC                   endif
     C                   move      *hival        lstzon
     C     keyps3        setll     pltsum3
     C                   dow       forevr = forevr
     C     keyps3        reade     pltsum3                                79
     C                   if        *in79
     C                   leave
     C                   endif
720aA
720aA*    If using DD2, work with gen > 1 first loop, gen = 1 second loop
720aA
720cMC                   if        tbEnhanced and loop = 1 and psgen = 1
720aAC                   iter
720aAC                   endif
720aA
720cMC                   if        tbEnhanced and loop = 2 and psgen > 1
720aAC                   iter
720aAC                   endif
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
700bA*    or skip empty pallet zones.
700bAC                             or  pstzon = ' '
700bAC                             and pspzon = ' '
700bAC                             and psszon = ' '
700bAC                             and pstrn# = 0
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
530aAC                   if        *in79 = *off
530aAC                   eval      opdta2 = opzdta
530aAC                   endif
     C                   if        *in79
402 AC     keyop2        setll     optionz
402 AC     keyop2        reade     optionz                                78
402 AC                   if        *in78
     C                   eval      oplpgm = *blanks
640cAC                   else
640cAC                   eval      opdta2 = opzdta
402 AC                   endif
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
530aA*
530aA*      Use original line printer label program.
530aA*
530aAC                   if        oplb6 = 'Y'
530cD ***                if        client <> Andrews
530cD ***                eval      $ptruk = $ptmpl
530cD ***                endif
530aAC                   call      oplp6
530aAC                   parm      '*PRINT  '    cmd
530aAC                   parm                    $pwhse
530aAC                   parm                    $prtid
530aAC                   parm                    pscomp
530aAC                   parm                    pstzon
530aAC                   parm                    psgen
530aAC                   parm                    psszon
530aAC                   parm                    $ptruk
530aAC                   parm                    $prte
530aAC                   parm                    opdta2
530aAC                   endif
640bA*
640bAC                   select
640bAC                   when      oplb1 = 'Y'
640bAC                   eval      oplpgm = oplp1
640bAC                   when      oplb2 = 'Y'
640bAC                   eval      oplpgm = oplp2
640bAC                   when      oplb3 = 'Y'
640bAC                   eval      oplpgm = oplp3
640bAC                   when      oplb4 = 'Y'
640bAC                   eval      oplpgm = oplp4
640bAC                   endsl
     *
     *    Call picking label program to print labels for zone.
     *
     C                   if        oplpgm <> *blanks
414 AC                   movel     oplpgm        @pgm
414 AC                   move      oplpgm        @set
414 AC                   select
AFSaA*
AFSaA*      Use special label program.
AFSaA*
AFSaAC                   when      @pgm = 'PFMT'
AFSaAC                             and client = Andrews
AFSaAC                   call      'PFMTTLA'
AFSaAC                   parm      '*PRINT  '    cmd
AFSaAC                   parm                    @set
AFSaAC                   parm                    @fmt
AFSaAC                   parm                    $pwhse
AFSaAC                   parm                    $prtid
AFSaAC                   parm                    pscomp
AFSaAC                   parm                    pstzon
AFSaAC                   parm                    psgen
AFSaAC                   parm                    psszon
AFSaAC                   parm                    $ptruk
AFSaAC                   parm                    $prte
AFSaAC                   parm                    opdta2
AFSaAC                   parm      0             $ptrn#
AFSaAC                   parm      0             $plbl#
AFSaAC                   parm      0             $pqty
AFSaAC                   parm      0             $pcwt
414 A*
414 A*      Use special label program.
414 A*
414 AC                   when      @pgm = 'PFMT'
FRFbA*
FRFbAC                   if        client = FRF
FRFbAC                   eval      savopdta2 = opdta2
FRFbAC                   endif
FRFbA*
700aAC                   eval      cmd = '*PRINT'
700aAC                   if        $pcmd = '*REPRINT'
700aAC                   eval      cmd = $pcmd
700aAC                   endif
700aA*
414 AC                   call      'PFMT'
700aMC                   parm                    cmd               8
700aD ***                parm      '*PRINT  '    cmd               8
414 AC                   parm                    @set
414 AC                   parm                    @fmt              8
414 AC                   parm                    $pwhse
414 AC                   parm                    $prtid
414 AC                   parm                    pscomp
414 AC                   parm                    pstzon
414 AC                   parm                    psgen
414 AC                   parm                    psszon
414 AC                   parm                    $ptruk
414 AC                   parm                    $prte
530aD ***                parm                    opzdta
530aMC                   parm                    opdta2
500a C                   parm      0             $ptrn#            7 0
500a C                   parm      0             $plbl#            7 0
500a C                   parm      0             $pqty             5 0
500a C                   parm      0             $pcwt             7 2
FRFbA*
FRFbAC                   if        client = FRF
DRYaAC                             or client = dairyland
FRFbA*
FRFbAC                   if        $pcmd <> '*REPRINT'
DRYbAC                             and pfilerun = *off
FRFbAC                   exsr      zzpfile
FRFbAC                   endif
FRFbA*
FRFbAC                   endif
414aA*
414aA*      Use program to write labels to a file.
414aA*
414aAC                   when      oplpgm = 'PFILE'
414aA*
414aA*        First call to this program, init file member.
414aA*
530bAC                   if        $pcmd <> '*REPRINT'
414aAC                   if        fiflag = *off
ASC AC                   if        client <> 'AGAR'
414aAC                   call      'PFILEINZ'
414aAC                   parm                    $whse
414aAC                   parm                    $prte
414aAC                   parm                    $mbr             10
520 AC                   parm                    $prtid
414aAC                   exsr      ovrdbf
414aAC                   eval      fiflag = *on
ASC AC                   endif
414aAC                   endif
530bAC                   endif
414aA*
414aA*        Call program to write labels to file.
414aA*
ASCbAC                   if        client <> 'AGAR'
DRYbAC                             and client <> dairyland
414aAC                   call      oplpgm
414aAC                   parm      '*PRINT  '    cmd
414aAC                   parm                    $pwhse
414aAC                   parm                    $prtid
414aAC                   parm                    pscomp
414aAC                   parm                    pstzon
414aAC                   parm                    psgen
414aAC                   parm                    psszon
414aAC                   parm                    $ptruk
414aAC                   parm                    $prte
530aD ***                parm                    opzdta
530aMC                   parm                    opdta2
ASCbA*
ASCbAC                   else
ASCbAC                   if        asflag = *off
ASCbA*
ASCbAC                   call      oplpgm
ASCbAC                   parm      '*PRINT  '    cmd
ASCbAC                   parm                    $pwhse
ASCbAC                   parm                    $prtid
ASCbAC                   parm                    pscomp
ASCbAC                   parm                    pstzon
ASCbAC                   parm                    psgen
ASCbAC                   parm                    psszon
ASCbAC                   parm                    $ptruk
ASCbAC                   parm                    $prte
ASCbAC                   parm                    opdta2
ASCbA*
ASCbAC                   eval      asflag = *on
ASCbAC                   endif
ASCbAC                   endif
FRFaAC                   if        client = frf
FRFaAC                   call      'PFMT2'
FRFaAC                   parm      '*PRINT  '    cmd               8
FRFaAC                   parm                    @set
FRFaAC                   parm                    @fmt              8
FRFaAC                   parm                    $pwhse
FRFaAC                   parm                    $prtid
FRFaAC                   parm                    pscomp
FRFaAC                   parm                    pstzon
FRFaAC                   parm                    psgen
FRFaAC                   parm                    psszon
FRFaAC                   parm                    $ptruk
FRFaAC                   parm                    $prte
FRFaAC                   parm                    opdta2
FRFaAC                   parm      0             $ptrn#            7 0
FRFaAC                   parm      0             $plbl#            7 0
FRFaAC                   parm      0             $pqty             5 0
FRFaAC                   parm      0             $pcwt             7 2
FRFaAC                   endif
650bA*
650bA*      Use program to write labels to staging file.
650bA*
650bAC                   when      oplpgm = 'PFILES'
650bA*
650bA*        Call program to write labels to file.
650bA*
PANaAC                   if        client <> panos
650bAC                   call      oplpgm
650bAC                   parm      '*PRINT  '    cmd
650bAC                   parm                    $pwhse
650bAC                   parm                    $prtid
650bAC                   parm                    pscomp
650bAC                   parm                    pstzon
650bAC                   parm                    psgen
650bAC                   parm                    psszon
650bAC                   parm                    $ptruk
650bAC                   parm                    $prte
650bAC                   parm                    opdta2
750bA*
750bA*      Save batchID for closing at pgm end.
750bAC                   if            opbatid > ' '
750bAC                             and savopbatid = ' '
750bAC                   eval      savopbatid = opbatid
750bAC                   endif
750bA*
PANaAC                   endif
414 A*
414 A*      Use original line printer label program.
414 A*
414 AC                   other
414 A*
414 A*      Use original line printer label program.
414 A*
530aD ***                call      oplpgm
530aD ***                parm      '*PRINT  '    cmd
530aD ***                parm                    $pwhse
530aD ***                parm                    $prtid
530aD ***                parm                    pscomp
530aD ***                parm                    pstzon
530aD ***                parm                    psgen
530aD ***                parm                    psszon
530aD ***                parm                    $ptruk
530aD ***                parm                    $prte
530aD ***                parm                    opzdta
530aD ***                parm                    opdta2

CTWaAC                   if        client = citywholesale
FDIaAC                             or client = finkle
SVLaAC                             or client = saval
CTWaAC                   select
CTWaAC                   when      client = citywholesale
CTWaAC                   eval      @set = 'ZBRCTW'
FDIaAC                   when      client = finkle
FDIaAC                   eval      @set = 'ZBRFDI'
SVLaAC                   when      client = saval
SVLaAC                   eval      @set = 'ZBRSVL'
CTWaAC                   endsl
CTWaAC                   call      'PFMT'
CTWaAC                   parm      '*PRINT  '    cmd
CTWaAC                   parm                    @set
CTWaAC                   parm                    @fmt
CTWaAC                   parm                    $pwhse
CTWaAC                   parm                    $prtid
CTWaAC                   parm                    pscomp
CTWaAC                   parm                    pstzon
CTWaAC                   parm                    psgen
CTWaAC                   parm                    psszon
CTWaAC                   parm                    $ptruk
CTWaAC                   parm                    $prte
530aD ***                parm                    opzdta
530aMC                   parm                    opdta2
CTWaAC                   parm      0             $ptrn#
CTWaAC                   parm      0             $plbl#
CTWaAC                   parm      0             $pqty
CTWaAC                   parm      0             $pcwt
CTWaAC                   endif
     *
414 AC                   endsl
     C                   endif
     *
     C                   enddo
720aA*
720aA* End of DD2 loop
720aA*
720aAC                   endfor

CSPbA* Process Coastal labels for REFB
CSPbAC                   if        client = coastalsunbelt
CSPbAC                   eval      psszon = 'REFB  '
CSPbA*
CSPbA*    Get picking options for zone.
CSPbA*
CSPbAC                   eval      kycode = '*PICKLBL'
CSPbAC                   eval      kyzone = 'REF   '
CSPbAC                   eval      opdta2 = *blanks
CSPbAC     keyopz        chain     optionz                            79
CS0aAC                   if        *in79 = *off
CS0aAC                   eval      opdta2 = opzdta
CS0aAC                   endif
CSPbAC     keyps8        chain     pltsum8
CSPbAC                   if        %found(pltsum8)
CSPbAC                   eval      @set = 'ZBRCSP'
CSPbAC                   call      'PFMT'
CSPbAC                   parm      '*PRTREFB'    cmd               8
CSPbAC                   parm                    @set
CSPbAC                   parm                    @fmt              8
CSPbAC                   parm                    $pwhse
CSPbAC                   parm                    $prtid
CSPbAC                   parm                    pscomp
CSPbAC                   parm                    pstzon
CSPbAC                   parm                    psgen
CSPbAC                   parm                    psszon
CSPbAC                   parm                    $ptruk
CSPbAC                   parm                    $prte
CSPbAC                   parm                    opdta2
CSPbAC                   parm      0             $ptrn#            7 0
CSPbAC                   parm      0             $plbl#            7 0
CSPbAC                   parm      0             $pqty             5 0
CSPbAC                   parm      0             $pcwt             7 2
CSPbAC                   endif
CSPbAC                   endif
414aA*
414aA*  If export file was created then see if we should FTP it.
414aA*
414aAC                   if        oplpgm = 'PFILE'  and
414aAC                             fiflag = *on  and
414aAC                             opftp = 'Y'

700cA*  If rte has '*' chg move to eval using %char
700dDC***                move      $prte         $prten

414aA*
414aA*      Close label program.
414aA*
414aAC                   call      oplpgm
414aAC                   parm      '*CLOSE  '    cmd
414aAC                   parm                    $pwhse
414aAC                   parm                    $prtid
414aAC                   parm                    pscomp
414aAC                   parm                    pstzon
414aAC                   parm                    psgen
414aAC                   parm                    psszon
414aAC                   parm                    $ptruk
414aAC                   parm                    $prte
530aD ***                parm                    opzdta
530aMC                   parm                    opdta2
414aA*
414aA*      Call program to FTP file.
414aA*
700aA*      Retry if error with call to PFILEFTP.
700aA*
700aAC                   dow       forevr = forevr
700aA*
700aAC                   monitor
414aAC                   call      'PFILEFTP'
414aAC                   parm                    $mbr
650aAC                   parm                    $pwhse
700dDC***                parm                    $prten
700dMC                   parm                    $prte
650aAC                   parm                    $prtid
700aAC                   on-error
700aAC                   iter
700aAC                   endmon
700aA*
700aAC                   leave
700aAC                   enddo
414aAC                   endif
650bA*
650bA*      Close label program.
650bA*
650bAC                   if        oplpgm = 'PFILES'
PANaAC                   if        client <> panos
650bAC                   call      oplpgm
650bAC                   parm      '*CLOSE  '    cmd
650bAC                   parm                    $pwhse
650bAC                   parm                    $prtid
650bAC                   parm                    pscomp
650bAC                   parm                    pstzon
650bAC                   parm                    psgen
650bAC                   parm                    psszon
650bAC                   parm                    $ptruk
650bAC                   parm                    $prte
650bAC                   parm                    opdta2
PANaAC                   endif
650bAC                   endif
530 A*
530 A*  Loop through DEVGRPR file and delete records for route.
530 A*
530 AC     keyddr        setll     devgrpr
530 AC                   dow       forevr = forevr
530 AC     keyddr        reade     devgrpr                                79
530 AC                   if        *in79
530 AC                   leave
530 AC                   endif
530 AC                   delete    ddrrec
530 AC                   enddo
     *
ADCbA
ADCbA /free
720bA   // Update stage batch header here instead of pfiles
750bD   //if opBatid <> *blanks;
750bM     if savopBatid <> *blanks;
720bA       exec sql
720bA        update stgbatch
720bA        set sbstatus = 'R',
720bA            sbtext   = ' ',
720bA            sbststs  = current_timestamp,
720bA            sbstsuc  = current_timestamp - current_timezone
720bA        where sbwhse = :$pWhse
750bM          and sbbatid = :savopbatId;
750bD   //     and sbbatid = :opbatId;
720bA     endif;
ADCbA   // If Anderson-DuBose, run JDE process
ADCcD   //if client = adc;
ADCcD   //  RunJDE(%editc($pwhse:'X'));
ADCcD   //endif;
ADCbA /end-free
ADCcMc                   if        client = adc
ADCcMc                   monitor
ADCcMc                   call      'PROCPICK'
ADCcMc                   parm                    $whse
ADCcMc                   on-error
ADCcMC                   endmon
ADCcMc                   endif
     *
JFF AC                   if        client = Jakes
JFF A*       Send entry to dtaq to wake up poller to pick up route.
JFF AC                   call      'QSNDDTAQ'
JFF AC                   parm      'LTBBPDQQ'    dqqun            10
JFF AC                   parm      '*LIBL'       dqlib            10
JFF AC                   parm      9             dqlen             5 0
JFF AC                   parm      *BLANKS       dspa              9
JFF A
JFF AC                   endif
JFF A*
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
750aAC                   move      $whse         $pwhse
520aA*
520aA* Get client id.
520aA*
520aAC                   call      @getcl
520aAC                   parm                    client
520aAC                   parm                    cliloc
520aA*
720cAc*
720cAc*   Determine if using TruckBUilder Enhanced
720cAc*
720cA /free
720cA      tbWhse = $pwhse;
720cA      GetTBType(tbWhse: $prtid: tbType);
720cA      if tbType = 'E';
720cA        tbEnhanced = *on;
720cA        tbPalletType = 'P';
720cA      else;
720cA        tbEnhanced = *off;
720cA        tbPalletType = 'O';
720cA      endif;
720cA /end-free

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
CSPbAC     keyps8        klist
CSPbAC                   kfld                    $pwhse
CSPbAC                   kfld                    $prtid
CSPbAC                   kfld                    psszon
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
520bAC                   kfld                    $ptmpl
530aAC                   kfld                    kyzone
530aA*
530aAC     opzkyb        klist
530aAC                   kfld                    kycod4
530aAC                   kfld                    $pwhse
530bDC*                  kfld                    $ptruk
530bAC                   kfld                    $ptmpl
530aAC                   kfld                    kyzone
402 A*
402 A*  Define partial key for options file.
402 A*
402 AC     keyop2        klist
402 AC                   kfld                    kycode
402 AC                   kfld                    $pwhse
640aD ***                kfld                    $ptruk
640aMC                   kfld                    $ptmpl
414 A*
414 A*  Define key for options file.
414 A*
414 AC     keyop         klist
414 AC                   kfld                    opwhse
414 AC                   kfld                    opcode
530 A*
530 A*  Define partial key for DEVGRPR file.
530 A*
530 AC     keyddr        klist
530 AC                   kfld                    $pwhse
530 AC                   kfld                    $prtid
530 A*
530 A*  Define key for TRUCKH file.
530 A*
530 AC     keyth         klist
530 AC                   kfld                    $pwhse
530 AC                   kfld                    $ptruk
414 A*
414 A*   Get FTP options from options file.
414 A*
414 AC                   eval      opwhse = 0
414 AC                   eval      opcode = '*FTP    '
414 AC     keyop         chain     options                            79
414 AC                   if        *in79
414 AC                   eval      opftp = 'N'
414 AC                   endif
530 A*
530 A* Get Zone Template Code if Template type is T=Truck
530 A*
750aDC**                 move      $whse         $pwhse
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
     C                   eval      kycode = '*PICKLBL'
     C     keyopz        chain     optionz                            79
     C                   if        *in79
     C                   eval      oplpgm = *blanks
     C                   endif
     *
     C                   endsr
FRFbA*
FRFbA*----------------------------------------------------------------
FRFbA*
FRFbA*  ZZPFILE  Call Export Pick Label processing program.
FRFbA*
FRFbAC     zzpfile       begsr
FRFbA*
FRFbAC                   if        fiflag = *off
FRFbAC                   call      'PFILEINZ'
FRFbAC                   parm                    $whse
FRFbAC                   parm                    $prte
FRFbAC                   parm                    $mbr             10
FRFbAC                   parm                    $prtid
FRFbAC                   exsr      ovrdbf
FRFbAC                   eval      fiflag = *on
FRFbAC                   endif
FRFbA*
FRFbA*        Call program to write labels to file.
FRFbA*
FRFbAC                   call      'PFILE'
FRFbAC                   parm      '*PRINT  '    cmd
FRFbAC                   parm                    $pwhse
FRFbAC                   parm                    $prtid
FRFbAC                   parm                    pscomp
FRFbAC                   parm                    pstzon
FRFbAC                   parm                    psgen
FRFbAC                   parm                    psszon
FRFbAC                   parm                    $ptruk
FRFbAC                   parm                    $prte
FRFbAC                   parm                    savopdta2
DRYcAC                   parm      0             $ptrn#            7 0
FRFbA*
DRYbAC                   eval      pfilerun = *on
DRYcA*
DRYcAC                   if        client = dairyland
DRYcA*
DRYcA*      Close label program.
DRYcAC                   call      'PFILE'
DRYcAC                   parm      '*CLOSE  '    cmd
DRYcAC                   parm                    $pwhse
DRYcAC                   parm                    $prtid
DRYcAC                   parm                    pscomp
DRYcAC                   parm                    pstzon
DRYcAC                   parm                    psgen
DRYcAC                   parm                    psszon
DRYcAC                   parm                    $ptruk
DRYcAC                   parm                    $prte
DRYcAC                   parm                    opdta2
DRYcAC                   parm      0             $ptrn#            7 0
DRYcA*
DRYcAC                   eval      qcmd = 'DLTOVR FILE(EXPFPLBL)'
DRYcAC                   call      'QCMDEXC'
DRYcAC                   parm                    qcmd
DRYcAC                   parm      80            qlen
DRYcA*
DRYcAC                   call      'PFILEFTP'
DRYcAC                   parm                    $mbr
DRYcAC                   parm                    $pwhse
DRYcAC                   parm                    $prten
DRYcAC                   parm                    $prtid
DRYcAC                   endif
DRYbA*
FRFbAC                   endsr
FRFbA*
414aA*----------------------------------------------------------------
414aA*
414aA*  OVRDBF  Override export file.
414aA*
414aAC     ovrdbf        begsr
414aA*
414aA*      Override database file.
414aA*
414aA*          OVRDBF FILE(EXPFPLBL) MBR(XXXXXXXXXX)
414aA*
414aAC                   movea     ovr(1)        a80
414aAC                   movea     $mbr          a80(27)
414aAC                   movea     a80           qcmd
414aAC                   call      'QCMDEXC'
414aAC                   parm                    qcmd             80
414aAC                   parm      80            qlen             15 5
414aA*
414aAC                   endsr
**   OVRDBF statment
OVRDBF FILE(EXPFPLBL) MBR(XXXXXXXXXX)
