      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  RH151     Export closed customer orders - Post
     *  27 June 1997
     *  Dave Sommerville
     *  Roxanne Harrison
     *
     *  Created usint OR725
     *
     *  Revisions
     *  Notes
     *      - Recompiled because of new LABEL5 file.
     *      - Added OHTYPE to key for LABEL5.
     *      - Moving OHCORD into OEHORD, OEDORD and OECORD.
     *      - Added update to file EXPORDT.
     *
     *      - Revised to ignore letdown records when checking LABEL5.
     *
404 A*    08/26/97  HNK  4.04
     *      - Revised to loop thru order file for a route.
406 A*    09/25/97  RH   4.06
     *      - Revised to update Export date and time.
409 A*    04/21/98  RH
     *      - Recompiled, files ORDC & EXPORDC changed.
     *      - Move transaction # to OECTRN.
412 A*    08/23/99  RH
     *      - Recompiled, file ORDC changed.
417aA*    07/08/03  RH   4.17a
     *      - Changed to update the emp# and quantity in ORDT and
     *        EXPORDT files.
417bA*    08/04/03  HNK  4.17b
     *      - Fix - There could be more than one label record for a
     *        transaction.  Changed to read LABEL90 file.
510 A*    05/17/07  RBD  5.10
     *      - Added client custom code support to program.
     *      - Added order detail label# export file, EXPORDL.
510aA*    05/18/07  DAS  5.10a
     *      - Added oeldsp and oelpal fields.
510bA*    06/20/07  DAS  5.10b
     *      - Removed ORDL logic. Re: No one is using that file
     *        in this format.
     *
730aA*    01/14/19  RBD  7.30a
     *      - Converted to ILE.
     *      - Added *SYSTEM options.
     *      - Added creation of Trax xml which used to run in RH150A
     *        but was moved in here (and RH155S last year) to ensure
     *        route status has been updated to exported status.
     *
740aA*    11/04/20  RBD  7.40a
     *      - Added *TRAX options. Only create Trax xml at this time
     *        if Trax user AND they do not print Trax invoices.
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
     *RDH    UP  E           K        DISK
     Fordh3     uf   e           k disk
     Fordd      if   e           k disk
     Fordc      if   e           k disk
417aD*RDT    IF  E           K        DISK
417aMFordt      uf   e           k disk
417bA**BEL   IF  E           K        DISK
417aAFpirtran   if   e           k disk
     *ABEL5  IF  E           K        DISK
     Frtehed    uf   e           k disk
417bAFLabel90   if   e           k disk
     F                                     rename(lbrec:lbrec9)
510Bd*ABEL13 IF  E           K        DISK
510Bd*           LBREC                             KRENAMELBREC13
     Fexpordh   o  a e           k disk
     Fexpordd   o  a e           k disk
     Fexpordc   o  a e           k disk
213 AFexpordt   o  a e           k disk
510bD*XPORDL O   E           K        DISK                      A
730aAFttrte     if   e           k disk
730aAFpiruser   if   e           k disk
730aAFoptions   if   e           k disk
     *----------------------------------------------------------------
510 A*  Customer id
510 A*
     D @getcl          c                   const('GETCLIENT')
510 A*
730aD */COPY QCOPYSRC,IL#CHENEY
730aM /COPY QCOPYSRC,Id#CHENEY
510 A*
     *----------------------------------------------------------------
     *  Level breaks
     *
     *HREC
     *                                             OHWHSEL1
     *                                             OHRTE L1
     *                                             OHPBATL1
     *----------------------------------------------------------------
     *  Constants
     *
     D forevr          c                   const('1')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @getpl          c                   const('GETPALLET')
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
     *----------------------------------------------------------------
     *  Variables
     *
     D error           s              1
     D today           s              8  0
730aAD sysWhse         s              3s 0 inz(0)
730aA*----------------------------------------------------------------
730aA*  Prototypes
730aA*----------------------------------------------------------------

730aAD tr810           pr                  extpgm('TR810')
730aA * Input
730aAD   tr8Whse                      3  0 const
730aAD   tr8Rtid                      5    const
730aAD   tr8Emp                       5    const
730aA * Output
730aAD   tr8FileSnd                  30    const
730aAD   tr8Rtn                       8    const
730aAD   tr8Erm                      60    const

     *----------------------------------------------------------------
730aA*  *SYSTEM  -  System options.
730aA*----------------------------------------------------------------
730aA*
730aA* Fields
730aA*
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *    OPWRNC  -  Check CW variance during selection closing (N,M,C,B)
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
     *    OPICW   -  Check CW count during selection closing (N,M,C,B)
     *    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
     *    OPRCDY  -  Number of days to keep receiving logs.
     *    OPMPCK  -  Number of days to keep picking logs.
     *    OPRTHS  -  Number of weeks - exported routes to keep.
     *    OPCRHS  -  Number of weeks - exported customer rtns to keep.
     *    OPPOHS  -  Number of weeks - exported p/o's to keep.
     *    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
     *    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
     *    OPTBJQ  -  Run Truck Builder on Job Que (Y,N).
     *    OPISHS  -  Number of weeks to keep history file
     *    OPUCI   -  Use UCI processing (Y,N)
     *    OPWRNCR -  Check CW variance during receiving closing (N,M,C,B)
     *    OPICWR  -  Check CW count during receiving closing (N,M,C,B)
     *    OPTRAX  -  Using TRAX module (Y,N).
     *    OPTAXR  -  Using TAXR module (Y/N).
     *    OPCHKR  -  Using CHKR module (Y/N).
     *    OPVOICE -  Using VOICE module (Y/N).
     *    OPSLOT  -  Print Slot barcode on Pick Label (Y/N).
     *    OPDSPL  -  Display last three digits of license (Y/N).
     *
     * Data structure
     *
     D opdat1          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opicw                 13     13
     D  opmpck                14     14
     D  oprcdy                15     15  0
     D  oppkdy                16     16  0
     D  oprths                17     19  0
     D  opcrhs                20     22  0
     D  oppohs                23     25  0
     D  opiahs                26     28  0
     D  opmshs                29     31  0
     D  optbjq                32     32
     D  opishs                33     35  0
     D  opuci                 36     36
     D  opwrncr               37     37
     D  opicwr                38     38
     D  optrax                39     39
     D  optaxr                40     40
     D  opchkr                41     41
     D  opvoice               42     42
     D  opslot                43     43
     D  opdspl                44     44
     D  opten1               117    117
     *----------------------------------------------------------------
740aA*  *TRAX  -  TRAX options
740aA*----------------------------------------------------------------
740aA*
740aA* Fields
740aA*
740aA*    OPTHST  -  Days to keep TRAX export data (1-999)
740aA*    OPTSLI  -  Save log info
740aA*    OPTCWR  -  Catch weight required
740aA*    OPTOFT  -  Order number field type
740aA*    OPTDFT  -  Driver field type
740aA*    OPTRFT  -  Route field type
740aA*    OPTCAP  -  Capitalize input
740aA*    OPTDBL  -  Double click delivery
740aA*    OPTEKD  -  Entry key delivery
740aA*    OPTDAR  -  Delivery after return
740aA*    OPTIDB  -  Include item data base
740aA*    OPTBDA  -  Breakdowns allowed
740aA*    OPTGBD  -  Generic breakdown allowed
740aA*    OPTRTQ  -  Pre-trip questions
740aA*    OPTOTQ  -  Post-trip questions
740aA*    OPTCCE  -  Credit card enabled
740aA*    OPTSIG  -  Signature enabled
740aA*    OPTPIV  -  Print invoice
740aA*    OPTSDA  -  Send data after stop
740aA*    OPTWSP  -  Ws port
740aA*    OPTWSI  -  Ws IP
740aA*    OPTSVD  -  Save days
740aA*    OPTERT  -  Environment run time
740aA*    OPTEDV  -  Environment device
740aA*    OPTEOS  -  Environment OS
740aA*    OPTESW  -  Environment screen width
740aA*    OPTESH  -  Environment screen height
740aA*    OPTARE  -  Add return enabled
740aA*    OPTIDL  -  Icon delivery
740aA*    OPTDCI  -  Double click icons
740aA*    OPTPAL  -  Pallets enabled
740aA*    OPTCRA  -  Cradle upload enabled
740aA*    OPTDRV  -  Driver assigned before download
740aA*    OPTBUL  -  Bulk items enabled
740aA*    OPTEYS  -  Display empty stops
740aA*    OPTSAS  -  Save after scan
740aA*    OPTSDL  -  Save delay
740aA*    OPTSDT  -  Sync date and time
740aA*    OPTLRK  -  Left/right keys enabled
740aA*    OPTGSS  -  GS1 scanning
740aA*    OPTGSU  -  GS1 unique
740aA*    OPTSBV  -  Scan beep volume
740aA*    OPTRAG  -  Restart after get route.
740aA*    OPTRD   -  Restart daily.
740aA*    OPTRDT  -  Restart daily time.
740aA*    OPTRFP  -  Reader focus position.
740aA*    OPTRFM  -  Reader focus mode.
740aA*    OPTNSR  -  Non scan reason prompt.
740aA*    OPTFBD  -  Filter by department.
740aA*    OPTDSF  -  Display stop flags before restart.
740aA*    OPTSOR  -  Sort items by compartment Y/N.
740aA*    OPTODE  -  Customer on site delivery enable Y/N.
740aA*    OPTODP  -  Customer on site delivery verification period, 5-60.
740aA*    OPTONT  -  On truck picking Y/N.
740aA*    OPTOTP  -  Override truck picking Y/N.
740aA*    OPTNSB  -  No signee button on signature screen Y/N.
740aA*    OPTRAXINV - 1 = Print all invoices
740aA*                2 = Print pristine invoices only
740aA*                3 = Print non-pristine invoices only
740aA*                9 = Print no invoices
740aA*
740aA* Data structure
740aA*
740aAD opdat2          ds
740aAD  opthst                 1      3  0
740aAD  optsli                 4      4
740aAD  optcwr                 5      5
740aAD  optoft                 6      6
740aAD  optdft                 7      7
740aAD  optrft                 8      8
740aAD  optcap                 9      9
740aAD  optdbl                10     10
740aAD  optekd                11     11
740aAD  optdar                12     12
740aAD  optidb                13     13
740aAD  optbda                14     14
740aAD  optgbd                15     15
740aAD  optrtq                16     16
740aAD  optotq                17     17
740aAD  optcce                18     18
740aAD  optsig                19     19
740aAD  optpiv                20     20
740aAD  optsda                21     21
740aAD  optwsp                22     26  0
740aAD  optwsi                27     41
740aAD  optsvd                42     43  0
740aAD  optert                44     47
740aAD  optedv                48     57
740aAD  opteos                58     67
740aAD  optesw                68     71  0
740aAD  optesh                72     75  0
740aAD  optare                76     76
740aAD  optidl                77     77
740aAD  optdci                78     78
740aAD  optpal                79     79
740aAD  optcra                80     80
740aAD  optdrv                81     81
740aAD  optbul                82     82
740aAD  opteys                83     83
740aAD  optsas                84     84
740aAD  optsdl                85     86  0
740aAD  optsdt                87     87
740aAD  optlrk                88     88
740aAD  optgss                89     89
740aAD  optgsu                90     90
740aAD  optsbv                91     91  0
740aAD  optrag                92     92
740aAD  optrd                 93     93
740aAD  optrdt                94     97  0
740aAD  optrfp                98     98
740aAD  optrfm                99     99
740aAD  optnsr               100    100
740aAD  optfbd               101    101
740aAD  optdsf               102    102
740aAD  optsor               103    103
740aAD  optode               104    104
740aAD  optodp               105    106  0
740aAD  optont               107    107
740aAD  optotp               108    108
740aAD  optnsb               109    109
740aAD  optraxinv            110    110
740aAD  opten2               117    117

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
     * Level break check
     *
     *  See if there are any open transactions for the route.
     *
217 A*    If an open transaction exists, make sure it isn't a letdown.
     *
222 D*  L1      KEYLB5    SETLLLABEL5                   50
217 A*  L1      *IN50     IFEQ *ON
217 A*                    MOVE *OFF      *IN50
217 A*                    MOVE *OFF      *IN79
217 A*          *IN79     DOUEQ*ON
217 A*          KEYLB5    READELABEL5                   79
217 A*          *IN79     IFEQ *OFF
217 A*          P5TASK    ANDNE'REPL'
217 A*          P5TASK    ANDNE'REPLBK'
217 A*                    MOVE *ON       *IN50
217 A*                    LEAVE
217 A*                    ENDIF
217 A*                    ENDDO
217 A*                    ENDIF
222 D*  L1                MOVE *IN50     OPNFLG  1
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
     *
     *  Get order header record.
     *
404 D*          KEYOH     CHAINORDH3                79
404 AC     keyoh         setll     ordh3
404 AC                   dou       forevr <> forevr
404 AC     keyoh         reade     ordh3                                  79
404 A*
     C                   if        *in79
404 AC                   leave
404 D*                    MOVE '*ERROR  '$PRTN
404 D*                    GOTO BOTTOM
     C                   endif
     *
222 D*  Skip order if open transactions exist.
     *
222 D*          OPNFLG    CABEQ*ON       BOTTOM
     *
     *  Add order header record to export header file.
     *
     C                   exsr      filoeh
     C                   write     oehrec
     *
     *  Add order detail records to export detail file.
     *
     C     keyod         setll     ordd
     C                   dou       forevr <> forevr
     C     keyod         reade     ordd                                   78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   exsr      filoed
     C                   write     oedrec
     C                   enddo
     *
     *  Add order catch weight records to export catch weight file.
     *
     C     keyod         setll     ordc
     C                   dou       forevr <> forevr
     C     keyod         reade     ordc                                   78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   exsr      filoec
     C                   write     oecrec
     C                   enddo
213 A*
213 A*  Add order detail transaction recs to export file.
213 A*
213 AC     keyod         setll     ordt
213 AC                   dou       forevr <> forevr
213 AC     keyod         reade     ordt                                   78
213 AC                   if        *in78
213 AC                   leave
213 AC                   endif
417aA*  Get employee # for ORDT and export file.
417aAC     ottrn#        chain     pirtran                            77
417aAC                   if        not *in77
417a C                   eval      otemp# = ptemp#
417aAC                   endif
417aA*  Get quantity for ORDT and export file.
417bA**         OTLBL#    CHAINLABEL                77
     *
417bAC     keylb9        setll     label90
417bAC                   dow       forevr = forevr
417bAC     keylb9        reade     label90                                77
     *
417bAC                   if        *in77
417bAC                   leave
417bAC                   endif
     *
417aAC                   if        not *in77
     *
417bAC                   if        lbtype <> 'O'  and
417bAC                             lbtype <> 'M'
417bAC                   iter
417bAC                   endif
     *
417bAC                   if        lbitem <> otitem  or
417bAC                             lbord <> otord  or
417bAC                             lbseq <> otseq
417bAC                   iter
417bAC                   endif
     *
417aAC                   if        lbutyp = 'N'
417bMC                   add       lbqpck        otpck1
417b **                   Z-ADDLBQPCK    OTPCK1
417aAC                   endif
417aAC                   if        lbutyp = '1'
417bMC                   add       lbqpck        otpck2
417b **                   Z-ADDLBQPCK    OTPCK2
417aAC                   endif
417aAC                   if        lbutyp = '2'
417bMC                   add       lbqpck        otpck3
417b **                   Z-ADDLBQPCK    OTPCK3
417aAC                   endif
     *
417aAC                   endif
     *
417bAC                   enddo
417aAC                   update    otrec
213 AC                   exsr      filoet
213 AC                   write     oetrec
213 AC                   enddo
     *
510bD**Add label recs to order detail label# export file
510bD**
510bD**         CLIENT    IFEQ CHENEY
510bD**         KEYOH     SETLLLABEL13
510bD**         FOREVR    DOUNEFOREVR
510bD**         KEYOH     READELABEL13                  77
510bD**
510bD**                   SELEC
510bD**         *IN77     WHEQ *ON
510bD**                   LEAVE
510bD**
510bD**                   OTHER
510bD**                   Z-ADD0         ODSEQ
510bD**         KEYL13    CHAINORDD                 77
510bD**                   EXSR FILOEL
510bD**                   WRITEOELREC
510bD**                   ENDSL
510bD**                   ENDDO
510bD**                   ENDIF
510bD**
     C     keyoh         chain     rtehed                             78
     C                   if        not *in78
     C                   eval      rhstat = '6'
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      rhstsd = $cvd8o
     C                   time                    rhstst
406 AC                   eval      rhexpd = $cvd8o
406 AC                   time                    rhexpt
     C                   update    rhrec
     C                   endif
     *
     *
     *  Update order header record with upload date and time.
     *
     C                   eval      ohstat = 'C'
     C                   eval      ohsdte = today
     C                   time                    ohstim
     C                   eval      ohudte = ohsdte
     C                   eval      ohutim = ohstim
     C                   update    ohrec
     *
404 AC                   enddo
404 A*
     C     bottom        tag

730aA /free
730aA   if optrax = 'Y'
740aA    and optraxinv = '9';
730aA     exsr wrtTraxXml;
730aA   endif;
730aA /end-free

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
510 A* Get client id.
510 A*
510 AC                   call      @getcl
510 AC                   parm                    client           10
510 A*
     *
     *   Define partial key for ORDD file.
     *
     C     keyod         klist
     C                   kfld                    ohwhse
     C                   kfld                    ohord
     *
     *   Define  key for ORDH3 file.
     *
     C     keyoh         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
222 D*   Define partial key for LABEL5 file.
     *
222 D*R         *LIKE     DEFN L5PO      KYPO
     *R                   MOVE *BLANKS   KYPO
     *R         KEYLB5    KLIST
     *R                   KFLD           OHWHSE
213 A*R                   KFLD           OHTYPE
     *R                   KFLD           OHRTE
     *R                   KFLD           KYPO
     *R                   KFLD           OHPBAT
     *
417bA*   Define partial key for LABEL90 file.
     *
417bAC     keylb9        klist
417bAC                   kfld                    otwhse
417bAC                   kfld                    ottrn#
     *
510 A*   Define partial key for LABEL13 file.
     *
510 AC     keyl13        klist
510 AC                   kfld                    lbwhse
510 AC                   kfld                    lbord
510 AC                   kfld                    lbseq
510 AC                   kfld                    lbitem

730aA*  Define partial key for OPTIONS file.
730aA*
730aAC     keyopSys      klist
730aAC                   kfld                    sysWhse
730aAC                   kfld                    opcode
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
730aA*   Get *SYSTEM options from options file.
730aA*
730aAC                   eval      opcode = '*SYSTEM '
730aAC     keyopSys      chain     options
730aAC                   if        not %found(options)
730aAC                   eval      optrax = 'N'
730aAC                   else
730aAC                   eval      opdat1 = opdata
730aAC                   endif

740aA*   Get *TRAX options from options file.
740aA*
740aAC                   eval      sysWhse = $pwhse
740aAC                   eval      opcode = '*TRAX   '
740aAC     keyopSys      chain     options
740aAC                   if        not %found(options)
740aAC                   eval      optraxinv = '9'
740aAC                   else
740aAC                   eval      opdat2 = opdata
740aAC                   endif

     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILOEC  Fill export detail catch weight fields.
     *
     C     filoec        begsr
     *
     *  Initialize record
     *
     C                   clear                   oecrec
     *
     *  Move fields from order file to export file.
     *
     C                   eval      oecwhs = ocwhse
213 D*                    Z-ADDOCORD     OECORD
213 MC                   eval      oecord = oehord
     C                   eval      oecsq# = ocseq#
     C                   eval      oecitm = ocitem
     C                   eval      oecseq = ocseq
409 AC                   eval      oectrn = octran
     C                   eval      oecwgt = occwgt
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILOED  Fill export detail fields.
     *
     C     filoed        begsr
     *
     *  Initialize record
     *
     C                   clear                   oedrec
     *
     *  Move fields from order file to export file.
     *
     C                   eval      oedwhs = odwhse
213 D*                    Z-ADDODORD     OEDORD
213 MC                   eval      oedord = oehord
     C                   eval      oedseq = odseq
     C                   eval      oeditm = oditem
     C                   eval      oedq1 = odqor1
     C                   eval      oedq2 = odqor2
     C                   eval      oedq3 = odqor3
     C                   eval      oedwh2 = odwh2
     C                   eval      oedor2 = odor2
     C                   eval      oedoit = odoitm
     C                   eval      oedqp1 = odqpk1
     C                   eval      oedqp2 = odqpk2
     C                   eval      oedqp3 = odqpk3
     C                   eval      oedspc = odspcl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILOEH   Fill export header fields.
     *
     C     filoeh        begsr
     *
     *  Initialize record
     *
     C                   clear                   oehrec
     *
     *  Move fields from order file to export file.
     *
     C                   eval      oehwhs = ohwhse
213 D*                    Z-ADDOHORD     OEHORD
213 MC                   eval      oehord = ohcord
     C                   eval      oehtyp = ohtype
     C                   eval      oehcpo = ohcpo
     C                   eval      oehcus = ohcust
     C                   eval      oehcnm = ohcnam
     C                   eval      oehca1 = ohcad1
     C                   eval      oehca2 = ohcad2
     C                   eval      oehcct = ohccty
     C                   eval      oehcst = ohcst
     C                   eval      oehczp = ohczip
222 D*R                   MOVE OHRTE     OEHRTE
222 MC                   eval      oehrte = $prte
     C                   eval      oehstp = ohstop
     C                   eval      oehtrk = ohtruk
     C                   eval      oehmis = ohmisc
     C                   eval      oehpbt = ohpbat
     C                   eval      oehdte = ohsdte
     C                   eval      oehtim = ohstim
     *
     C                   endsr
510bD*----------------------------------------------------------------
510bD*
510bD*  FILOEL  Fill order detail label# export file fields.
510bD*
510bD**         FILOEL    BEGSR
510bD**
510bD** Initialize record
510bD**
510bD**                   CLEAROELREC
510bD**
510bD** Move fields from label file to export file.
510bD**
510bD**                   Z-ADDLBWHSE    OELWHS
510bD**                   Z-ADDLBORD     OELORD
510bD**                   Z-ADDODSEQ     OELSQ#
510bD**                   MOVE LBITEM    OELITM
510bD**                   Z-ADDLBLBL#    OELLBL
510bD**                   MOVE LBTYPE    OELTYP
510bD**                   MOVE LBDISP    OELDSP
510bD**                   Z-ADDLBTRN#    OELTRN
510bD**                   MOVE LBUTYP    OELUMT
510bD**                   Z-ADDLBQALC    OELALC
510bD**                   Z-ADDLBQPCK    OELPCK
510bD**
510bD**                   CALL @GETPL
510bD**                   PARM LBWHSE    $GWHSE  30
510bD**                   PARM LBRTE     $GRTID  5
510bD**                   PARM 'O'       $GTYPE  1
510bD**                   PARM LBPAL#    $GPLID  70
510bD**                   PARM 0         $GPAL#  70
510bD**                   PARM ' '       $GTZON  6
510bD**                   PARM ' '       $GPZON  6
510bD**                   PARM ' '       $GSZON  6
510bD**                   PARM ' '       $GCOMP  1
510bD**                   PARM 0         $GGEN   10
510bD**                   PARM ' '       $GTRUK 10
510bD**                   PARM 0         $GUNLD  20
510bD**                   PARM 0         $GROW   20
510bD**                   PARM 0         $GCOL   10
510bD**                   PARM 0         $GSTP1  20
510bD**                   PARM 0         $GSTP2  20
510bD**                   PARM 0         $GPCS   50
510bD**                   PARM 0         $GCUBE  73
510bD**                   PARM 0         $GSWGT  92
510bD**                   PARM 0         $GBCNT  10
510bD**                   PARM ' '       $GFLAG  1
510bD**                   PARM 0         $GLBL#  70
510bD**                   PARM 0         $GTRN#  70
510bD**                   PARM ' '       $GRTN   8
510bD**
510bD**                   Z-ADD$GPAL#    OELPAL
510bD**
510bD**                   ENDSR
213 A*----------------------------------------------------------------
213 A*
213 A*  FILOET  Fill export detail transaction fields.
213 A*
213 AC     filoet        begsr
213 A*
213 A*  Initialize record
213 A*
213 AC                   clear                   oetrec
213 A*
213 A*  Move fields from order file to export file.
213 A*
213 AC                   eval      oetwhs = otwhse
213 AC                   eval      oetord = oehord
213 AC                   eval      oetseq = otseq
213 AC                   eval      oetitm = otitem
213 AC                   eval      oettrn = ottrn#
417aAC                   eval      oetemp = otemp#
417aAC                   eval      oetpk1 = otpck1
417aAC                   eval      oetpk2 = otpck2
417aAC                   eval      oetpk3 = otpck3
213 A*
213 AC                   endsr

730aA*----------------------------------------------------------------
730aA*  wrtTraxXml  Write Trax xml
730aA
      /free
        begsr wrtTraxXml;

          usemp# = 0;
          chain ($pwhse: $prtid) ttrte;
          if %found(ttrte);
            chain (ttrusr) piruser;
          endif;
          tr810($pwhse: $prtid: %editc(usemp#:'X'): '': '': '');

        endsr;
      /end-free

730aA*----------------------------------------------------------------
