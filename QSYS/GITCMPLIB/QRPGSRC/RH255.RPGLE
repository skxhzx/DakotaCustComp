     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RH255     FTP Will call export closed customer orders - Post
     *  08 Marcy 1999
     *  Dave Sommerville
     *
     *  This program should be identical to RH251 except that it uses
     *  the EXPF files that are overridden in RF255CL.
     *
     *----------------------------------------------------------------
     *  Revisions
409 A*    04/21/98  RH
     *      - Recompiled, files ORDC & EXPORDC changed.
     *      - Move transaction # to OECTRN.
     *
411 A*    03/08/99  DAS 4.11
     *      - Created this program from RH251.
412 A*    08/23/99  RH
     *      - Recompiled, file ORDC changed.
     *
413aA*    04/06/00  MLB  4.13a
     *      - Changed program to update export date/time in the
     *        RTEHED file.
417aA*    07/08/03  RH   4.17a
     *      - Changed to update the emp# and quantity in ORDT and
     *        EXPORDT files.
417bA*    08/04/03  HNK  4.17b
     *      - Fix - There could be more than one label record for a
     *        transaction.  Changed to read LABEL90 file.
     *
510 A*    07/07/06  MLB  5.10
     *      - Enh: Added client custom code support to program.
     *      - Enh: Converted program to ILE.
510bA*    11/02/06  RH   5.10b
     *      - Enh: Use *FEATURE to include stand alone code (500 & 500a)
500 A*    02/08/06  MLB  5.00     (SA)
     *      - Enh: Revised program to add four new files to program:
     *        ORDBOX, ORDEXPDTE, EXPFORDB, EXPFORDE.
500aA*    04/25/06  MLB  5.00a    (SA)
     *      - Fix: Correction to 5.00 mod. Revised routines FILOEB
     *        and FILOEE to load customer order number into files
     *        EXPFORDE and EXPFORDB instead of internal order #.
510cA*    05/16/07  RBD  5.10c
     *      - Added order detail label# export file EXPFORDL.
510dA*    05/18/07  DAS  5.10d
     *      - Added oeldsp and oelpal fields.
510eA*    05/25/07  MLB  5.10e
     *      - Fix: Revised program to load customer order number
     *        into OELORD field.
510fA*    05/29/07  MLB  5.10f
     *      - Fix: Revised program to use LABEL93 instead of LABEL13
     *        to populate EXPFORDL file. Replaced
510gA*    06/20/07  DAS  5.10g
     *      - Added files ORDP, EXPFORDP, WORKLBL
510hA*    06/26/07  DAS  5.10h
     *      - Replaced file ORDP with ORDP1.
     *      - Moved logic for exporte ORDP records into order loop.
     *      - Revised to export all records that are in ORDP file.
510iA*    09/13/07  DAS  5.10i
     *      - Added fields OEPCNT, OEPTTL and OEPSCN.
520 A*    04/07/08  RBD  5.20
     *      - Fix: WORKLBL fields were being written to EXPFORDP file
     *        but there was no chain to WORKLBL, thus the fields were
     *        empty.
520aA*    04/17/08  RBD  5.20a
     *      - Recompiled, file EXPFORDP changed.
     *
530 A*    04/30/10  MLB  5.30
     *      - Fix: Revised program to omit label type A records from
     *        being written into the EXPFORDL file.
530bA*    08/19/10  RH/MLB  5.30b
     *      - Enh: Revised progam to compute unique seq number for
     *        each catchwgt record written into EXPFORDC linked to
     *        a line item on the customer order.  This is being done
     *        because a line item on an order ended up split across
     *        pallets causing wgts to have duplicate sequence numbers.
     *
640 A*    08/27/11  MLB  6.40
     *      - Fix: Revised program to remove STANDA test for ord boxes
     *        and expiration dates being exported to host. Chg to 5.10b
     *        mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Brothers.
     *
CBI A*    05/11/07  MLB  CBI
     *      - Revised program to write export label data to file
     *        EXPFORDL.
CBIaA*    06/13/07  RBD  CBI
     *      - Only write generation 1 labels to EXPFORDL.
CBIbA*    06/20/07  DAS  CBIb
     *      - Reversed above CBI changes.
     *      - Reversed to write out to EXPFORDP file.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Ellenbee-Leggett.
     *
ELL A*    05/25/07  MLB  ELL
     *      - Added ELL to CBI mod.
     *      - Revised program to write export label data to file
     *        EXPFORDL.
ELLaA*    09/28/09  MLB  ELLa
     *      - Revised pgm to disable ELL mod. File no longer needed.
ELLbA*    09/28/09  MLB  ELLb
     *      - Revised program to write out EXPFORDP file.
     *      - Added client to CBIb mod.
ELBcA*    09/28/09  JCJ  ELBc
     *      - send Pallet ID instead of Pallet number in the EXPFORDP
     *        file in field OEPPAL
ELBdA*    10/06/09  MLB  ELBd
     *      - Revised ELBc mod to read LABEL11 file for generation 2
     *        type O records to retrieve truck pallet id to load
     *        into EXPFORDP file.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Packer's Provision
     *
PAK A*    07/21/06  MLB  PAK
     *      - Revised program to write export data to file SAPEXP
     *        instead of standard expfxxxx files.
PAKaA*    09/08/06  MLB  PAKa
     *      - Revised program to add /copy members for Order Hdr misc
     *        fields unique to Packer's.
PAKbA*    09/18/06  MLB  PAKb
     *      - Revised program to add file UCICW6 to write out UCI
     *        records with export data.
PAKcA*    09/27/06  MLB  PAKc
     *      - *TEMPORARY* Revised program to change values written
     *        into SAPEXP file for testing. These changes will be
     *        replaced when going live on SAP.
PAKdA*    09/27/06  MLB  PAKd
     *      - Revised program to only write out segment E1EDL26
     *        for catchweight items.
PAKeA*    09/28/06  MLB  PAKe
     *      - Revised program to update field MAND in E1EDL20,
     *        E1EDL21 and E1EDL24 segments.
PAKfA*    09/28/06  MLB  PAKf
     *      - Revised program to add BRGEW and remove GEWEI
     *        Change UOM from CV to CS.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cash Wa
     *
CWD A*    12/15/09  MLB  CWD
     *      - Added CWD to CBI mod.
     *      - Revised program to write export label data to file
     *        EXPFORDL.
CWDaA*    12/27/17  MLB  CWDa  P#01833
     *      - Revised pgm to populate EXPFORDP file.
     *      - Needed as part of mods to export data to Host for use
     *        with off-truck delivery system.
CWDbA*    01/05/18  MLB  CWDb  P#01833
     *      - Revised routine FILOEP to load $PRTID into OEPWGT.
     *      - Needed as part of mods to export data to Host for use
     *        with off-truck delivery system.
     *
HAR A*----------------------------------------------------------------
HAR A*  Client Custom Revisions: Harbor
HAR A*
HARaA*    04/02/08  DAS  HAR
     *      - Revised program to write out EXPFORDP file.
HARbA*    04/08/08  RBD  HARb
     *      - Fix: Add Harbor to open of WORKLBL.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fox River Foods
     *
FRF A*    04/30/10  MLB  FRF
     *      - Revised program to write export label data to file
     *        EXPFORDL.
     *----------------------------------------------------------------
     *  Client Custom Revisions: European Imports
EI  A*    08/24/07  RBD  EI
     *      - Revised to populate EXPFORDH/oehczp, zip code field,
     *        with user id that closed the route.
EIb A*    06/21/12  RH   EIb
     *      - Revised program to write export label data to file
     *        EXPFORDL (see FRF mod)
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Avalon Foodservice
     *
AVL A*    11/11/11  MLB  AVL
     *      - Revised pgm to populate OEHPBT with OHORD for processing
     *        in pgm, HRH160 Export to Retalix Pwr Whse.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Glazier Foods
     *
GLZ A*    03/02/12  MLB  GLZ
     *      - Revised program to load order id into field, OEHPBT
     *        for use in H&S interface pgm, HRH157. Needed to retrieve
     *        H&S ship date from ORDHM file.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Y.Hata
     *
YHA A*    11/11/13  MLB  YHA  P#001146
     *      - Revised program to write out EXPFORDP file.
     *      - Added YHA to CBIb mod.
YHAaA*    11/11/13  MLB  YHAa
     *      - Revised program to load order id into field, OEHPBT
     *        for use in H&S interface pgm, HRH157. Needed to retrieve
     *        H&S ship date from ORDHM file.
     *      - Added YHAa to GLZ mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: FoodPro
     *
FPR A*    03/02/16  MLB  FPR
     *      - Revised program to load order id into field, OEHPBT
     *        for use in RTX interface pgm, HRH156. Needed to retrieve
     *        RTX ship date from ORDHM file.
     *      - Added FPR to GLZ mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Sofo Foods
     *
SOFaA*    04/01/15  MLB  SOFa
     *      - Revised program to load order id into field, OEHPBT
     *        for use in H&S interface pgm, HRH156. Needed to retrieve
     *        IDS ship date from ORDHM file.
     *      - Added SOFa to GLZ mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Graves Menu Maker
     *
GMMaA*    02/13/19  MLB  GMMa
     *      - Revised program to load order id into field, OEHPBT
     *        for use in P/E interface pgm, HRH157. Needed to retrieve
     *        P/E ship date from ORDHM file.
     *      - Added GMMa to GLZ mod.
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
PAK AFordhm     if   e           k disk
     Fordd      if   e           k disk
     Fordc      if   e           k disk
417aD*RDT    IF  E           K        DISK
417aMFordt      uf   e           k disk
510hMFordp1     if   e           k disk    usropn
500 AFordbox    if   e           k disk
500 AFordexpdte if   e           k disk
417bA**BEL   IF  E           K        DISK
PAK AFpiritem   if   e           k disk
417aAFpirtran   if   e           k disk
     *ABEL5  IF  E           K        DISK
ELBdAFlabel11   if   e           k disk    usropn
417bAFLabel90   if   e           k disk
     F                                     rename(lbrec:lbrec9)
510fMFlabel93   if   e           k disk
510fMF                                     rename(lbrec:lbrec93)
510fAF                                     usropn
     Frtehed    uf   e           k disk
PAK AFsapexp    uf a e           k disk    usropn
PAKbAFucicw6    if   e           k disk    usropn
CBIaAFpltsum4   if   e           k disk    usropn
EI  AFpirtrck4  if   e           k disk
     Fexpfordh  o  a e           k disk
     Fexpfordd  o  a e           k disk
530bDF*xpfordc  o  a e           k disk
530bMFexpfordc  uf a e           k disk
213 AFexpfordt  o  a e           k disk
500 AFexpfordb  o  a e           k disk
500 AFexpforde  o  a e           k disk
510cAFexpfordl  o  a e           k disk
510gAFexpfordp  o  a e           k disk    usropn
510b Foptions   if   e           k disk
510g Fworklbl   if   e           k disk    usropn
510 A*----------------------------------------------------------------
510 A*  Customer id
510 A*
PAK A /COPY QCOPYSRC,ID#packers
CBI A /COPY QCOPYSRC,ID#cheney
ELL A /COPY QCOPYSRC,ID#ellenbe
CWD A /COPY QCOPYSRC,ID#Cashwa
HARaA /COPY QCOPYSRC,ID#harbor
FRF A /COPY QCOPYSRC,ID#FRF
EI  A /COPY QCOPYSRC,ID#EI
AVL A /COPY QCOPYSRC,ID#Avalon
GLZ A /COPY QCOPYSRC,ID#glazier
YHA A /COPY QCOPYSRC,ID#Yhata
FPR A /COPY QCOPYSRC,ID#FPR
SOF A /COPY QCOPYSRC,ID#Sofo
GMMaA /COPY QCOPYSRC,ID#Gmm
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
510b *
510b * Data structure
510b *
510bA*----------------------------------------------------------------
510bA*  *FEATURE  -  PIR Feature options.
510bA*----------------------------------------------------------------
415dA*
415dA* Fields
415dA*
415dA*    OPFEAT  -  PIR Installed feature.
415dA*
415dA* Data structure
415dA*
415dAD ftropt          ds
415dAD  opfeat                 1      1
415dAD  ftrend               117    117
PAKaA*
PAKaA*----------------------------------------------------------------
PAKaA*  SAP Header Misc. File data structures
PAKaA*
PAKaA /copy qcopysrc,ordhm1_pak
PAKaA /copy qcopysrc,ordhm2_pak
PAKaA /copy qcopysrc,ordhm3_pak
PAKaA /copy qcopysrc,ordhm4_pak
PAKaA /copy qcopysrc,ordhm5_pak
PAK A*
PAK A*----------------------------------------------------------------
PAK A*  SAP Export File data structures
PAK A*
PAK A /copy qcopysrc,s#edidc40
PAK A /copy qcopysrc,s#e1edl20
PAK A /copy qcopysrc,s#e1edl21
PAK A /copy qcopysrc,s#e1edl24
PAK A /copy qcopysrc,s#e1edl26
PAK A*
510 A*----------------------------------------------------------------
510 A*  Working variables
510 A*
     D error           s              1
PAK AD expdate         s              8  0
PAK AD exptime         s              6  0
PAK AD loopcount       s              7  0
530bAD hldordseq#      s              5  0 inz(*loval)
530bAD newseq          s              5  0
PAKbAD sapcntrl        s              4    inz('*NO ')
PAK AD sapcount        s              7  0
510bAD standa          s              1
     D today           s              8  0
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
PAK AC                   select
PAK AC                   when      client = packers
PAK A*
PAKbAC                   if        sapcntrl = '*NO '
PAK A*  Populate SAP Control Record and write to export file.
PAK AC                   exsr      sapcontrol
PAK AC                   exsr      sapwrite
PAKbAC                   eval      sapcntrl = '*YES'
PAK AC                   endif
PAKbA*
PAK A*      Get BFC Order Header Misc. file.
PAK AC                   exsr      zzgethm
PAK A*      Create SAP Header Rcd format for export file.
PAK AC                   exsr      sapheader
PAK A*      Write SAP Header Rcd format for export file.
PAK AC                   exsr      sapwrite
PAK A*      Create SAP Header Additional Data Rcd format for export file.
PAK AC                   exsr      saphdradd
PAK A*      Write SAP Header Rcd format for export file.
PAK AC                   exsr      sapwrite
PAK AC                   other
PAK A*
     C                   exsr      filoeh
     C                   write     oehrec
PAK AC                   endsl
     *
     *  Add order detail records to export detail file.
     *
     C     keyod         setll     ordd
     C                   dou       forevr <> forevr
     C     keyod         reade     ordd                                   78
     C                   if        *in78
PAK A*
PAK AC                   select
PAK AC                   when      client = packers
PAK A*      Create SAP Detail Additional Data Rcd format for export file.
PAKdAC                   if        itcwgt = 'Y'
PAK AC                   exsr      sapdtladd
PAK A*      Write SAP Detail Rcd format for export file.
PAK AC                   exsr      sapwrite
PAKdAC                   endif
PAK AC                   endsl
PAK A*
     C                   leave
     C                   endif
PAK A*
PAK AC                   select
PAK AC                   when      client = packers
PAKbA*
PAKbAC                   evalr     kyord = %trimr(%editc(ohord:'X'))
PAKbAC     keyuci6       setll     ucicw6
PAKbA*
PAK A*
PAK A*      Get BFC Item master file.
PAK AC                   exsr      zzgetit
PAK A*      Is item a catchweighted item?
PAK AC                   if        itcwgt = 'Y'
PAK A*      Need to loop for as many as were picked.
PAK AC                   if        odqpk2 <> 0
PAK AC                   eval      loopcount = odqpk2
PAK AC                   else
PAK AC                   eval      loopcount = odqpk1
PAK AC                   endif
PAK AC                   else
PAK A*      Item a non-catchweighted item.
PAK AC                   eval      loopcount = 1
PAK AC                   endif
PAK A*      We must loop at least once for every line item.
PAK AC                   if        loopcount <= 0
PAK AC                   eval      loopcount = 1
PAK AC                   endif
PAK A*
PAK A*      Create SAP Detail Rcd format for export file.
PAK AC                   eval      sapcount = 0
PAK AC                   dow       sapcount < loopcount
PAK AC                             and loopcount > 0
PAKbA*
PAKbA*      Is item a catchweighted item?
PAKbAC                   if        itcwgt = 'Y'
PAKbAC     keyuci6       reade     ucicw6
PAKbAC                   if        %eof(ucicw6)
PAKbAC                   eval      ucinbr = ' '
PAKbAC                   eval      uciwgt = 0
PAKbAC                   endif
PAKbAC                   endif
PAKbA*
PAK AC                   eval      sapcount = sapcount + 1
PAK AC                   exsr      sapdetail
PAK A*      Write SAP Detail Rcd format for export file.
PAK AC                   exsr      sapwrite
PAKdA*
PAKdA*      Create SAP Detail Additional Data Rcd format for export file.
PAKdAC                   if        itcwgt = 'Y'
PAKdAC                   exsr      sapdtladd
PAKdA*      Write SAP Detail Rcd format for export file.
PAKdAC                   exsr      sapwrite
PAKdAC                   endif
PAKdA*
PAK AC                   enddo
PAK A*
PAK AC                   other
PAK A*
     C                   exsr      filoed
     C                   write     oedrec
PAK AC                   endsl
PAK A*
     C                   enddo
     *
     *  Add order catch weight records to export catch weight file.
     *
PAK AC                   select
PAK AC                   when      client = packers
PAK A*      For Packer's, do nothing.
PAK AC                   other
PAK A*
530bAC*
530bAC*  Delete all entries from EXPFORDC to ensure no duplicate wgts.
530bAC                   exsr      zzdelw
530bAC                   eval      newseq     = 0
530bAC                   eval      hldordseq# = *loval
530bA*
     C     keyod         setll     ordc
     C                   dou       forevr <> forevr
     C     keyod         reade     ordc                                   78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   exsr      filoec
     C                   write     oecrec
     C                   enddo
PAK A*
PAK AC                   endsl
PAK A*
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
417bD**                   Z-ADDLBQPCK    OTPCK1
417aAC                   endif
417aAC                   if        lbutyp = '1'
417bMC                   add       lbqpck        otpck2
417bD**                   Z-ADDLBQPCK    OTPCK2
417aAC                   endif
417aAC                   if        lbutyp = '2'
417bMC                   add       lbqpck        otpck3
417bD**                   Z-ADDLBQPCK    OTPCK3
417aAC                   endif
     *
417aAC                   endif
     *
417bAC                   enddo
417aAC                   update    otrec
PAK A*
PAK AC                   select
PAK AC                   when      client = packers
PAK A*      For Packer's, do nothing.
PAK AC                   other
PAK A*
213 AC                   exsr      filoet
213 AC                   write     oetrec
PAK A*
PAK AC                   endsl
PAK A*
213 AC                   enddo
500 A*
500 A*  Add order detail box code rcds to export box code file.
500 A*  Stand Alone
640 DC*                  if        standa = *on
500 AC     keyod         setll     ordbox
500 AC                   dou       forevr <> forevr
500 AC     keyod         reade     ordbox
500 AC                   select
500 AC                   when      %eof(ordbox)
500 AC                   leave
500 AC                   other
500aAC     keyob         chain     ordd
500aAC                   if        not %found(ordd)
500aAC                   eval      odor2 = 0
500aAC                   endif
500 AC                   exsr      filoeb
500 AC                   write     oebrec
500 AC                   endsl
500 AC                   enddo
500 A*
500 A*  Add order detail exp. date rcds to export exp. dates file.
500 A*
500 AC     keyod         setll     ordexpdte
500 AC                   dou       forevr <> forevr
500 AC     keyod         reade     ordexpdte
500 AC                   select
500 AC                   when      %eof(ordexpdte)
500 AC                   leave
500 AC                   other
500aAC     keyoe         chain     ordd
500aAC                   if        not %found(ordd)
500aAC                   eval      odor2 = 0
500aAC                   endif
500 AC                   exsr      filoee
500 AC                   write     oeerec
500 AC                   endsl
500 AC                   enddo
640 DC*                  endif
     *
510cA*  Add label recs to order detail label# export file
FRF DC*                  goto      #skipexpL
CBIbDC**                 if        client = cheney
ELLaDC*                  if        client = ellenbe
FRF AC                   if        client = FRF
CWD AC                             or client = Cashwa
EIb AC                             or client = EI
510fMC     keylb93       setll     label93
510cAC                   dou       forevr <> forevr
510fMC     keylb93       reade     label93

510cAC                   select
510fMC                   when      %eof(label93)
510cAC                   leave

530 A*  Skip any adjustment label records linked to the route.
530 AC                   when      lbtype = 'A'
530 AC                   iter
530 A
510cAC                   other
510fDC*    keylb13       chain     ordd
510fDC*                  if        not %found(ordd)
510fDC*                  eval      odseq = 0
510fDC*                  endif
CBIbDC**                 if        client = cheney
CBIbDC**   keypsum4      chain     pltsum4
CBIbDC**                 if        not %found(pltsum4) or
CBIbDC**                           psgen <> 1
CBIbDC**                 iter
CBIbDC**                 endif
CBIbDC**                 endif
510cAC                   exsr      filoel
510cAC                   write     oelrec
510cAC                   endsl
510cAC                   enddo
FRF AC                   endif
ELLaAC     #skipexpL     tag
510ha*
510hA*  Add order detail piece rcds to export piece file.
510hA*
CBIbAC                   if        client = cheney
HARaAC                             or client = harbor
ELLbAC                             or client = Ellenbee
YHA AC                             or client = YHata
CWDaAC                             or client = CashWa
510hAC     keyod         setll     ordp1
510hAC                   dou       forevr <> forevr
510hAC     keyod         reade     ordp1
510hAC                   select
510hAC                   when      %eof(ordp1)
510hAC                   leave
510hAC                   other
520 AC     orplbl        chain     worklbl
520 AC                   if        not %found
520 AC                   eval      lwtype = ' '
520 AC                   eval      lwdisp = ' '
520 AC                   eval      lwtrn# = 0
520 AC                   eval      lwutyp = ' '
520 AC                   eval      lwpal# = 0
ELBdAC                   eval      lwgen  = 0
520 AC                   endif
ELBdA*
ELBdAC                   if        client = Ellenbee
ELBdA*
ELBdAC                   if            lwgen = 2
ELBdAC                             and lwtype = 'O'
ELBdA*
ELBdA*      Retrieve Truck Pallet ID for child zone items.
ELBdAC                   eval      lbpal# = 0
ELBdAC     orplbl        setll     label11
ELBdAC                   dow       forevr = forevr
ELBdAC     orplbl        reade     label11
ELBdAC                   if        %eof(label11)
ELBdAC                   leave
ELBdAC                   endif
ELBdA*
ELBdA*      Found truck pallet id in merge label.
ELBdAC                   if        lbwhse = oepwhs
ELBdAC                             and lbrte = orprid
ELBdAC                   eval      lwpal# = lbpal#
ELBdAC                   leave
ELBdAC                   endif
ELBdA*
ELBdAC                   enddo
ELBdA*
ELBdAC                   endif
ELBdA*
ELBdAC                   endif
ELBdA*
510hAC                   exsr      filoep
510hAC                   write     oeprec
510hAC                   endsl
510hAC                   enddo
CBIbAC                   endif
     *
     C     keyoh         chain     rtehed                             78
     C                   if        not *in78
     C                   eval      rhstat = '6'
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      rhstsd = $cvd8o
     C                   time                    rhstst
413aAC                   eval      rhexpd = $cvd8o
413aAC                   eval      rhexpt = rhstst
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
510 A*
510 A* Get client id.
510 A*
510 AC                   call      'GETCLIENT'
510 AC                   parm                    client           10
510 AC                   parm                    clientloc        10
510 A*
     *
     *   Define partial key for ORDD file.
     *
     C     keyod         klist
     C                   kfld                    ohwhse
     C                   kfld                    ohord
530bA*
530bA*   Define partial key for EXPFORDC file.
530bA*
530bAC     keyoec2       klist
530bAC                   kfld                    ocwhse
530bAC                   kfld                    ohcord
PAK A*
PAK A*   Define full key for ORDHM file.
PAK A*
PAK AC     keyhm         klist
PAK AC                   kfld                    ohwhse
PAK AC                   kfld                    ohord
PAKbA*
PAKbA*   Define partial key for UCICW6 file.
PAKbA*
PAKbAC     *like         define    uciout        kyord
PAKbAC     keyuci6       klist
PAKbAC                   kfld                    ohwhse
PAKbAC                   kfld                    kyord
PAKbAC                   kfld                    odseq
PAKbAC                   kfld                    oditem
PAK A*
PAK A*   Define full key for PIRITEM file.
PAK A*
PAK AC     keyit         klist
PAK AC                   kfld                    odwhse
PAK AC                   kfld                    oditem
     *
     *   Define  key for ORDH3 file.
     *
     C     keyoh         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
500aA*
500aA*   Define full key for ORDD file.
500aA*
500aAC     keyob         klist
500aAC                   kfld                    obwhse
500aAC                   kfld                    obord
500aAC                   kfld                    obseq#
500aAC                   kfld                    obitem
500aA*
500aA*   Define full key for ORDD file.
500aA*
500aAC     keyoe         klist
500aAC                   kfld                    oewhse
500aAC                   kfld                    oeord
500aAC                   kfld                    oeseq#
500aAC                   kfld                    oeitem
     *
EI  A*   Define key for PIRTRCK4 file.
EI  A*
EI  AC     keyptrck4     klist
EI  AC                   kfld                    $pwhse
EI  AC                   kfld                    $prtid
EI  AC                   kfld                    $prte
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
510fM*   Define partial key for LABEL93 file.
     *
510fMC     keylb93       klist
510fMC                   kfld                    ohwhse
510fMC                   kfld                    ohord
510fDC*                  kfld                    lbseq
510fDC*                  kfld                    lbitem
510fA*
CBIaA*   Define full key for PLTSUM4 file.
     *
CBIaMC     keypsum4      klist
CBIaMC                   kfld                    lbtrn#
510fA*
510fA*    Open client-specific files.
CBIbDC**                 if        client = Cheney
CBIbMC                   if        client = Ellenbe
FRF AC                             or client = FRF
CWD AC                             or client = Cashwa
EIb AC                             or client = EI
510fA*
510fAC                   if        not %open(label93)
510fAC                   open      label93
510fAC                   endif
ELBdAC                   if        not %open(label11)
ELBdAC                   open      label11
ELBdAC                   endif
510fA*
510fAC                   endif
510b *
CBIbMC                   if        client = Cheney
CBIbMC                   if        %open(pltsum4)
CBIaAC                   open      pltsum4
CBIaAC                   endif
CBIbAC                   endif
     *
CBIbAC                   if        client = Cheney
HARaAC                             or client = harbor
ELLbAC                             or client = Ellenbee
YHA AC                             or client = YHata
CWDaAC                             or client = CashWa
CBIbAC                   if        not %open(ordp1)
CBIbAC                   open      ordp1
CBIbAC                   if        not %open(expfordp)
CBIbAC                   open      expfordp
CBIbAC                   endif
CBIbAC                   endif
CBIbAC                   endif
     *
CBIbAC                   if        client = Cheney
HARbAC                             or client = Harbor
ELLbAC                             or client = Ellenbee
YHA AC                             or client = YHata
CWDaAC                             or client = CashWa
CBIbAC                   if        not %open(worklbl)
CBIbAC                   open      worklbl
CBIbAC                   endif
CBIbAC                   endif
510b *
510b *  Define partial key for OPTIONS file.
510b *
510b C     keyop         klist
510b C                   kfld                    $pwhse
510b C                   kfld                    opcode
510b *    Get Feature options from options file.
510b C                   eval      opcode = '*FEATURE'
510b C     keyop         chain     options                            79
510b C                   eval      ftropt = opdata
510b C                   if        *in79
510b C                   eval      opfeat = '2'
510b C                   endif
510b C                   if        opfeat = '3'
510b C                   eval      standa = *on
510b C                   else
510b C                   eval      standa = *off
510b C                   endif
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
PAK A*
PAK A* Open EXPSAP Export File for Packer's.
PAK AC                   eval      expdate = today
PAK AC                   time                    exptime
PAKbA*
PAK AC                   if        client = packers
PAKbA*
PAK AC                   if        not %open(sapexp)
PAK AC                   open      sapexp
PAK AC                   endif
PAKbA*
PAKbA* Open UCICW6 UCI Catchweight file for Packer's.
PAKbAC                   if        not %open(ucicw6)
PAKbAC                   open      ucicw6
PAKbAC                   endif
PAKbA*
PAK AC                   endif
     *
     C                   endsr
500 A*----------------------------------------------------------------
500 A*
500 A*  FILOEB  Fill export detail box code fields.
500 A*
500 AC     filoeb        begsr
500 A*
500 A*  Initialize record
500 A*
500 AC                   clear                   oebrec
500 A*
500 A*  Move fields from order detail box file to export file.
500 A*
500 AC                   eval      oebwhs = obwhse
500aDC*                  eval      oebord = obord
500aMC                   eval      oebord = oehord
500aA*
500aA*    Send Host actual sequence number if sent.
500aAC                   if        odor2 > 0
500aAC                   eval      oebsq# = odor2
500aAC                   else
500 AC                   eval      oebsq# = obseq#
500aAC                   endif
580 AC                   eval      oebitm = obitem
500 AC                   eval      oebtrn = obtran
500 AC                   eval      oeblbl = oblbl#
500 AC                   eval      oebbox = obbox#
500 A*
500 AC                   endsr
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
530bA*      Reset catchwgt sequence counter when order line# changes.
530bAC                   if        hldordseq# <> ocseq#
530bAC                   eval      newseq     = 0
530bAC                   eval      hldordseq# = ocseq#
530bAC                   endif
530bA*
530bAC                   eval      newseq = newseq + 1
530bAC                   if        newseq > 999
530bAC                   eval      newseq = 999
530bAC                   endif
530bAC                   eval      oecseq = newseq
530bA*
530bDC*                  eval      oecseq = ocseq
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
500 A*----------------------------------------------------------------
500 A*
500 A*  FILOEE  Fill export detail exp. date fields.
500 A*
500 AC     filoee        begsr
500 A*
500 A*  Initialize record
500 A*
500 AC                   clear                   oeerec
500 A*
500 A*  Move fields from order detail exp date file to export file.
500 A*
500 AC                   eval      oeewhs = oewhse
500aDC*                  eval      oeeord = oeord
500aMC                   eval      oeeord = oehord
500aA*
500aA*    Send Host actual sequence number if sent.
500aAC                   if        odor2 > 0
500aAC                   eval      oeesq# = odor2
500aAC                   else
500 AC                   eval      oeesq# = oeseq#
500aAC                   endif
580 AC                   eval      oeeitm = oeitem
500 AC                   eval      oeetrn = oetran
500 AC                   eval      oeelbl = oelbl#
500 AC                   eval      oeedte = oedate
500 A*
500 AC                   endsr
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
AVL A*
AVL AC                   select
AVL AC                   when      client = Avalon
AVL AC                   eval      oehpbt = ohord
GLZ A*
GLZ AC                   when      client = Glazier
YHAaAC                             or client = YHata
FPR AC                             or client = FoodPro
SOFaAC                             or client = Sofofoods
GMMaAC                             or client = Menumaker
GLZ AC                   eval      oehpbt = ohord
GLZ A*
AVL AC                   other
AVL A*
     C                   eval      oehpbt = ohpbat
AVL AC                   endsl
AVL A*
     C                   eval      oehdte = ohsdte
     C                   eval      oehtim = ohstim
     *
EI  A*  Under certain conditions, load user id into zip code field.
EI  A*
EI  AC                   if        client = EI
EI  AC     keyptrck4     chain     pirtrck4
EI  AC                   if        %found
EI  AC                   eval      oehczp = truser
EI  AC                   endif
EI  AC                   endif
     *
     C                   endsr
510cA*----------------------------------------------------------------
510cA*
510cA*  FILOEL  Fill order detail label# export file.
510cA*
510cAC     filoel        begsr
510cA*
510cA*  Initialize record
510cA*
510cAC                   clear                   oelrec
510cA*
510cA*  Move fields from label file to export file.
510cA*
510cAC                   eval      oelwhs = lbwhse
510eDC*                  eval      oelord = lbord
510eMC                   eval      oelord = oehord
510fMC                   eval      oelsq# = lbseq
510cAC                   eval      oelitm = lbitem
510cAC                   eval      oellbl = lblbl#
510cAC                   eval      oeltyp = lbtype
510dAC                   eval      oeldsp = lbdisp
510cAC                   eval      oeltrn = lbtrn#
510cAC                   eval      oelumt = lbutyp
510cAC                   eval      oelalc = lbqalc
510cAC                   eval      oelpck = lbqpck
510dA*
510dAC                   call      'GETPALLET'
510dAC                   parm      lbwhse        $gwhse            3 0
510dAC                   parm      lbrte         $grtid            5
510dAC                   parm      'O'           $gtype            1
510dAC                   parm      lbpal#        $gplid            7 0
510dAC                   parm                    $gpal#            7 0
510dAC                   parm                    $gtzon            6
510dAC                   parm                    $gpzon            6
510dAC                   parm                    $gszon            6
510dAC                   parm                    $gcomp            1
510dAC                   parm                    $ggen             1 0
510dAC                   parm                    $gtruk           10
510dAC                   parm                    $gunld            2 0
510dAC                   parm                    $grow             2 0
510dAC                   parm                    $gcol             1 0
510dAC                   parm                    $gstp1            2 0
510dAC                   parm                    $gstp2            2 0
510dAC                   parm                    $gpcs             5 0
510dAC                   parm                    $gcube            7 3
510dAC                   parm                    $gswgt            9 2
510dAC                   parm                    $gbcnt            1 0
510dAC                   parm                    $gflag            1
510dAC                   parm                    $glbl#            7 0
510dAC                   parm                    $gtrn#            7 0
510dAC                   parm                    $greturn          8
510dA*
510dAC                   eval      oelpal = $gpal#
510cA*
510cAC                   endsr
510gA*----------------------------------------------------------------
510gA*
510gA*  FILOEP  Fill order detail piece seq# export file.
510gA*
510gAC     filoep        begsr
510gA*
510gA*  Initialize record
510gA*
510gAC                   clear                   oeprec
510gA*
510gA*  Move fields from label file to export file.
510gA*
510gAC                   eval      oepwhs = orpwhs
510hMC                   eval      oepord = oehord
510gMC                   eval      oepsq# = orpsq#
510gAC                   eval      oepitm = orpitm
510gAC                   eval      oepup# = orpup#
510gAC                   eval      oeplbl = orplbl
510gAC                   eval      oeptyp = lwtype
510gAC                   eval      oepdsp = lwdisp
510gAC                   eval      oeptrn = lwtrn#
510gAC                   eval      oepumt = lwutyp
510gAC                   eval      oepseq = orpseq
CWDbA*
CWDbAC                   if        client = CashWa
CWDbA*       Send route id for use with off-truck delivery pgm.
CWDbAC                   eval      oepwgt = %dec($prtid:7:2)
CWDbAC                   else
CWDbA*
510gAC                   eval      oepwgt = orpwgt
CWDbAC                   endif
CWDbA*
510iAC                   eval      oepcnt = orpcnt
510iAC                   eval      oepttl = orpttl
510iAC                   eval      oepscn = orpscn
510gA*
ELBcAC                   if        client = ellenbe
ELBcAC                   eval      oeppal = lwpal#
ELBcAC                   else
510gAC                   call      'GETPALLET'
510gAC                   parm      orpwhs        $gwhse            3 0
510gAC                   parm      orprid        $grtid            5
510gAC                   parm      'O'           $gtype            1
510gAC                   parm      lwpal#        $gplid            7 0
510gAC                   parm                    $gpal#            7 0
510gAC                   parm                    $gtzon            6
510gAC                   parm                    $gpzon            6
510gAC                   parm                    $gszon            6
510gAC                   parm                    $gcomp            1
510gAC                   parm                    $ggen             1 0
510gAC                   parm                    $gtruk           10
510gAC                   parm                    $gunld            2 0
510gAC                   parm                    $grow             2 0
510gAC                   parm                    $gcol             1 0
510gAC                   parm                    $gstp1            2 0
510gAC                   parm                    $gstp2            2 0
510gAC                   parm                    $gpcs             5 0
510gAC                   parm                    $gcube            7 3
510gAC                   parm                    $gswgt            9 2
510gAC                   parm                    $gbcnt            1 0
510gAC                   parm                    $gflag            1
510gAC                   parm                    $glbl#            7 0
510gAC                   parm                    $gtrn#            7 0
510gAC                   parm                    $greturn          8
510gA*
510gAC                   eval      oeppal = $gpal#
ELBcAC                   endif
510gA*
510gAC                   endsr
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
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  SAPCONTROL    Populate SAP Control Record and add to export file.
PAK A*
PAK AC     sapcontrol    begsr
PAK A*
PAK AC                   reset                   s#edi_dc40
PAK A*
PAK AC                   select
PAK AC                   when      client = packers
PAKeDC*                  eval      sap_mand    = '210'
PAKeMC                   eval      sap_mand    = '220'
PAK AC                   endsl
PAK A*
PAK AC                   eval      sap_docnum  = %editc(expdate:'X') +
PAK AC                                           %editc(exptime:'X')
PAK A*
PAK AC                   eval      sap_direct  = '2'
PAK A*
PAKcDC*                  eval      sap_rcvport = 'A000000008'
PAKcMC                   eval      sap_rcvport = 'LSMW      '
PAKcDC*                  eval      sap_rcvprn  = 'PPBFC210'
PAKcMC                   eval      sap_rcvprn  = 'DEVCLNT220'
PAK A*
PAKcDC*                  eval      sap_sndport = 'A000000008'
PAKcMC                   eval      sap_sndport = 'LSMW      '
PAKcAC                   eval      sap_sndprn  = 'DEVCLNT220'
PAK A*
PAK AC                   eval      sap_crtdate = %editc(expdate:'X')
PAK A*
PAK A*      Load record format into export file field.
PAK AC                   eval      spdata      = s#edi_dc40
PAK A*
PAK AC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  SAPDETAIL    Populate SAP Detail Record.
PAK A*
PAK AC     sapdetail     begsr
PAK A*
PAK AC                   reset                   s#e1edl24
PAK A*
PAKeAC                   eval      sap_L24mand = sap_mand
PAK AC                   if        sapcount = 1
PAK AC                   evalr     sap_posnr = %trimr(%editc(odseq:'4'))
PAK AC                   else
PAK AC                   eval      sap_posnr = ' '
PAK AC                   endif
PAK AC                   eval      sap_matnr = oditem
PAKaDC*                  eval      sap_lgort = %subst(hmmsc2:1:4)
PAKaMC                   eval      sap_lgort = pakhm1_dststg
PAKbA*
PAKbAC                   if        itcwgt   = 'Y'
PAKbAC                   eval      sap_charg = ucinbr
PAKbAC                   endif
PAKbA*
PAK A*      Customer ordered eaches.
PAK AC                   if        odqpk2 <> 0
PAK AC                   evalr     sap_lfimg = %trimr(%editc(odqpk2:'4'))
PAKfAC                   eval      sap_vrkme = 'EA'
PAK AC                   evalr     sap_lgmng = sap_lfimg
PAK AC                   eval      sap_meins = 'EA'
PAK AC                   else
PAK A*      Customer ordered cases.
PAK AC                   evalr     sap_lfimg = %trimr(%editc(odqpk1:'4'))
PAKfAC                   eval      sap_vrkme = 'CS'
PAK AC                   evalr     sap_lgmng = sap_lfimg
PAKfDC*                  eval      sap_meins = 'CV'
PAKfMC                   eval      sap_meins = 'CS'
PAK AC                   endif
PAKbA*
PAKbA*      Use actual catchweight otherwise use item ship weight.
PAKbAC                   if        itcwgt   = 'Y'
PAKbMC                   evalr     sap_ntgew = %trimr(%editc(uciwgt:'4'))
PAKfDC*                  evalr     sap_gewei = 'LB '
PAKfAC                   evalr     sap_brgew = %trimr(%editc(uciwgt:'4'))
PAKbAC                   else
PAKcDC*                  evalr     sap_ntgew = %trimr(%editc(itswgt:'4'))
PAKcMC                   evalr     sap_ntgew = ' '
PAKfDC*                  evalr     sap_gewei = '   '
PAKfAC                   evalr     sap_brgew = ' '
PAKbAC                   endif
PAK A*
PAK A*      Load record format into export file field.
PAK AC                   eval      spdata      = s#e1edl24
PAK AC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  SAPDTLADD    Populate SAP Detail Additional Data Record.
PAK A*
PAK AC     sapdtladd     begsr
PAK A*
PAK AC                   reset                   s#e1edl26
PAK A*
PAK A*
PAK A*      Load record format into export file field.
PAK AC                   eval      spdata      = s#e1edl26
PAK AC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  SAPHEADER    Populate SAP Header Record.
PAK A*
PAK AC     sapheader     begsr
PAK A*
PAK AC                   reset                   s#e1edl20
PAK A*
PAKeAC                   eval      sap_L20mand = sap_mand
PAKeMC                   evalr     sap_vbeln = %trimr(%subst(hmmsc5:1:9))
PAKaDC*                  eval      sap_vstel = %subst(hmmsc1:19:4)
PAKaMC                   eval      sap_vstel = pakhm2_dstshp
PAK AC                   eval      sap_podat = %editc(expdate:'X')
PAK AC                   eval      sap_potim = %editc(exptime:'X')
PAK A*
PAK A*      Load record format into export file field.
PAK AC                   eval      spdata    = s#e1edl20
PAK A*
PAK AC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  SAPHDRADD    Populate SAP Header Additional Data Record.
PAK A*
PAK AC     saphdradd     begsr
PAK A*
PAK AC                   reset                   s#e1edl21
PAK A*
PAKeAC                   eval      sap_L21mand = sap_mand
PAK AC                   eval      sap_lfart = %subst(hmmsc1:23:4)
PAK A*
PAK A*      Load record format into export file field.
PAK AC                   eval      spdata    = s#e1edl21
PAK A*
PAK AC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  SAPWRITE   Write record to SAP Export file.
PAK A*
PAK AC     sapwrite      begsr
PAK A*
PAK AC                   write     sapxrec
PAK AC                   if        %error
PAK AC                   endif
PAK A*
PAK AC                   endsr
PAK A*
530bA*----------------------------------------------------------------
530bA*
530bA*  ZZDELW   Delete any weifhts left over from previous export found
530bA*           in EXPFORDC file.
530bA*
530bAC     zzdelw        begsr
530bAC     keyoec2       setll     expfordc
530bAC                   dou       forevr <> forevr
530bAC     keyoec2       reade     expfordc                               76
530bA*
530b C                   if        *in76
530bAC                   leave
530bAC                   endif
530bA*
530bAC                   delete    oecrec
530b C                   enddo
530b C                   eval      *in76 = *off
530bA*
530b C                   endsr
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  ZZGETHM    Get Order Header Misc. file.
PAK A*
PAK AC     zzgethm       begsr
PAK A*
PAK AC     keyhm         chain     ordhm
PAK AC                   if        not %found(ordhm)
PAK AC                   eval      hmmsc1 = ' '
PAK AC                   eval      hmmsc2 = ' '
PAK AC                   eval      hmmsc3 = ' '
PAK AC                   eval      hmmsc4 = ' '
PAK AC                   eval      hmmsc5 = ' '
PAK AC                   endif
PAK A*
PAKaAC                   select
PAKaAC                   when      client = packers
PAKaAC                   eval      pakhm1_base = hmmsc1
PAKaAC                   eval      pakhm2_base = hmmsc2
PAKaAC                   eval      pakhm3_base = hmmsc3
PAKaAC                   eval      pakhm4_base = hmmsc4
PAKaAC                   eval      pakhm5_base = hmmsc5
PAKaAC                   endsl
PAKaA*
PAK AC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  ZZGETIT    Get Item Master file.
PAK A*
PAK AC     zzgetit       begsr
PAK A*
PAK AC     keyit         chain     piritem
PAK AC                   if        not %found(piritem)
PAK AC                   eval      itum1  = '  '
PAK AC                   eval      itumq2 = 0
PAK AC                   eval      itum2  = '  '
PAK AC                   eval      itflg1 = 'N'
PAK AC                   eval      itumq3 = 0
PAK AC                   eval      itflg2 = 'N'
PAK AC                   eval      itcwgt = 'N'
PAK AC                   eval      itswgt = 0
PAK AC                   endif
PAK A*
PAK AC                   endsr
