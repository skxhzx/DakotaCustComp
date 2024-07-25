650aA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PO726     FTP Export closed receiving P.O.'s - Post
     *  09 March 1999
     *  Dave Sommerville
     *
     *  This program should be identical to PO725 except that it uses
     *  the EXPF files that are overridden in PO726CL.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    02/29/96  DAS  2.10
     *      - Recompiled because of new LABEL5 file.
     *
214 A*    06/24/96  DAS
     *      - Added KYGRP2 to key for LABEL5.
     *      - Added redefinition data structure for P.O. number.
     *      - Added check for P.O. type.  If last two characters
     *        are 'TF' then it is a transfer P.O.
     *
218 A*    01/17/97  RH
     *      - Change to use POHDR & PODTL files.
     *      - Write to POHHDR & POHDTL history files.
     *      - Delete POHDR & PODTL records after exported.
221 A*    05/21/97  RH
     *      - Write weight to EXPPOD file.
401 A*    07/11/97  RH
     *      - Only process POHDR records if status = 3, ready to export.
     *      - Remove LABEL5 file, do not check for open transactions.
     *
411 A*    03/09/99  DAS 4.11
     *      - Created this program from PO725.
     *
416 A*    11/20/01  MLB  4.16
     *      - Add support for Super P/O's. Super P/O's will be written
     *        to the p/o history file, but not the export files.
416aA*    07/15/02  MLB  4.16a
     *      - Revised test for Super P/O's.
416bA*    12/18/02  HNK  4.16b
     *      - Add Lumper file.
     *
417 A*    04/10/03  MLB  4.17
     *      - Enh: Add POEXCP to export processing. This will move
     *        receiving exceptions to the exceptions history file.
     *      - Enh: Add EXPFPOE to export processing. This will copy
     *        receiving exceptions to the export exceptions file.
     *
500 A*    01/05/04  RLP  5.00
     *      - CHG: Changing imput method from Primary file to where
     *        it has a READ loop instead of using the RPG cycle.
     *      - Enh: Add logic to make program skip over a PO if there
     *        is a record lock (or any other error) reading POHDR.
     *
510 A*    06/08/06  MLB  5.10
     *      - Enh: Revised program to transfer info from POHDRM into
     *        POHHDRM file.
510aA*    06/08/06  MLB  5.10a
     *      - Fix: Revised 5.00 mod to not read the POHDR file when
     *        a record lock is encountered. Just skip the record.
510bA*    07/12/06  MLB  5.10b
     *      - Enh: Converted program to ILE.
510cA*    07/12/06  MLB  5.10c
     *      - Enh: Added client custom code support to program.
510dA*    07/12/06  MLB  5.10d
     *      - Enh: Revised program to move enddo, leave opcodes for
     *        POHDR read.
510eA*    11/13/06  RH   5.10e
     *      - Enh: Write export date/time to PORCV file.
510fA*    11/20/06  RAH   5.10f
     *      - Enh: Add POHACCP and POHHACCP.
510gA*    01/08/07  RH    5.10b
     *      - Enh: Recompile POHHACCP file key changed.
     *
520 A*    08/15/08  MLB  5.20
     *      - Fix: Revised program to fix "tried to delete rcd
     *        without prior read/chain" error on POHDRM file.
520aA*    12/12/08  MLB  5.20a
     *      - Enh: Revised program to transfer info from PODTLM into
     *        POHDTLM file.
520bA*    02/26/09  MLB  5.20b
     *      - Enh: PODTLM, POHDTLM file updated. Program changed to
     *        update new field.
     *
540 A*    12/21/10  MLB  5.40
     *      - Fix: Revised routine FILPDM to update correct field
     *        name for export time.
640aA*    01/09/12  MLB  6.40a  (Orig 5.20 03/26/08)
     *      - Enh: Re-compiled program for changes to EXPFPOE file
     *        to take effect. Packed numeric fields changed to zoned
     *        decimal. Packed numeric fields do not convert during FTP.
     *
640bA*    05/15/12  LMC   6.40b
     *      - Enh: Added logic to Call HA710 which updates the HACCP
     *             LOG file with export information.
     *             MAKE SURE YOU TAKE THE HA710 PROGRAM TO CLIENT
     *
650aA*    02/19/13  RTR   6.50a
     *      - Enh: Added PO License export file EXPFPOL
     *      - Enh: Revisions to handle partially received PO export
650bA*    04/15/13  RTR   6.50b
     *      - Fix: Changed partial PO export to include call to HA710
650cA*    04/22/13  RTR   6.50c
     *      - Fix: If partial PO export do not update exp dt/tm in PORCV
650dA*    04/25/13  RTR   6.50d
     *      - Enh: Adding User name/number that received PO to EXPFPOL
     *
700 A*    08/24/15  MLB   7.00
     *      - Fix: Revised routine WRTPEL to populate PELWHS.
700bA*    01/30/16  RTR   7.00b
     *      - Fix: Change to skip PORCV records with status ='D'.
700c *    04/13/16  RTR   7.00c
     *      - Fix: LICINFO only has pure qty on license, not UOM qty.
     *        Changed to pull qty for license from LICLOG RCV record.
710a *    09/07/17  RTR   7.10a
     *      - Fix: Per Roxanne, Super PO should be left open and not
     *        deleted.
     *
720a *    08/22/18  LMC  7.20a
     *      - Recompile only - Database change to haccplog
730a *    01/18/19  LMC  7.30a
     *      - Added writing UCI data to EXPFPOL for UCI tracked item.
     *
750 A*    10/28/21  MLB  7.50
     *      - DockVue: Added update of POSTATUS table when PO is exported
     *        to the Host.
     *      - Added 7.50 for DockVue
     *
750a *    03/11/21  RTR  7.50a
     *      - Added timestamp to POEXPQ field.
     *
770aA*   08/27/22  TDC  770a
     *     - Add system option opdckv to control DockVue processing.
     *     - Remove subr ZZUPDDCKVUE to keep the DockVue code
     *       consistent thru all the programs
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jack Palmer
     *
JPFaA*    03/15/07  RH   JPFa
     *      - Revised to not export for MOVEIN PO vendor
     *----------------------------------------------------------------
     *  Client Custom Revisions: Lincoln Poultry
     *
LINaA*    02/15/07  RH   LINa
     *      - Revised to not export for MOVEIN PO vendor
     *----------------------------------------------------------------
     *  Client Custom Revisions: Packer's Provision
     *
PAK A*    07/07/06  MLB  PAK
     *      - Revised program to write export data to file SAPEXP
     *        instead of standard expfxxxx files.
PAKaA*    09/12/06  MLB  PAKa
     *      - Revised program to add file UCICW5 to write out UCI
     *        records with export data.
PAKbA*    09/27/06  MLB  PAKb
     *      - *TEMPORARY* Revised program to change values written
     *        into SAPEXP file for testing. These changes will be
     *        replaced when going live on SAP.
PAKcA*    09/27/06  MLB  PAKc
     *      - Revised program to only write out segment E1EDL26
     *        for catchweight items.
PAKdA*    09/28/06  MLB  PAKd
     *      - Revised program to update field MAND in E1EDL20 and
     *        E1EDL24 segments.
PAKeA*    09/28/06  HNK  PAKe
     *      - Enh: Revised program to change value of MAND.
PAKfA*    09/28/06  HNK  PAKf
     *      - Revised program to add BRGEW and remove GEWEI
     *        Change UOM from CV to CS.
     *        Add MAND for segment 21.
PAKgA*    09/29/06  HNK  PAKg
     *      - Recompiled to match new control segment layout.
     *      - Revised program on how EDL24, EDL26 segments are
     *        written out. Changes made without deleting existing code.
PAKhA*    10/01/06  MLB  PAKh
     *      - Revised program to add line counter for records written to
     *        SAP export file.
PAKzA*    08/16/08  MLB  PAKz
     *      - Revised routine ZZGETPHM to not lock record on chain
     *        to POHDRM file.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greenleaf Produce
     *
GLPaA*    04/25/13  RTR  GLPa
     *      - Added check for user initials to use intead of user id
     *----------------------------------------------------------------
     *  Client Custom Revisions: S.Bertram
     *
SBRaA*    09/02/15  RTR  SBRa
     *      - Right justify PO number going back to Aspen.
SBRbA*    01/02/15  RTR  SBRb
     *      - Enh: Save PO exported counts to POEXPQ.spen.
SBRcA*    03/14/16  RTR  SBRc
     *      - Enh: Populate fields for EXPFPOL.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Farm Boy
     *
FBYaA*    07/05/18  RH   FBYa
     *      - Add automated printing of receiving and PCM reports.
     *        Temp change, will be added as GUI Option in the future.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Southwest Traders
     *
SWTa *    02/21/19  RTR  SWTa
     *      - Warehouse transfers have POHDR City = '999'. They need
     *        to be skipped, do not export these.
SWTbA*    07/28/21  MLB  SWTb
     *      - Enh: Revised pgm to retrieve slot, slot status to be
     *        loaded into EXPFPOL in field PELOCY.
     *      - Added files LICACTIVE,SLOT2 to pgm.
     *
     *----------------------------------------------------------------
     * Indicators
     *
510 A*  74        - NRF for POHDRM
500 A*  75        - ERR for POHDR
417 A*  76        - EOF for POEXCP
416 A*  77        - Super P/O found.
218 M*  78        - EOF for PODTL
218 M*  79        - EOF for POSPO
     *
     *----------------------------------------------------------------
     * File Specs
     *
500 D*OHDR   UP  E           K        DISK
500 Mfpohdr     uf   e           k disk
510 Afpohdrm    uf   e           k disk
218 Mfpodtl     uf   e           k disk
520aAfpodtlm    uf   e           k disk
417 Afpoexcp    uf   e           k disk
401 D*ABEL5  IF  E           K        DISK
416 Mfpospo     uf   e           k disk
PAK AFpiritem   if   e           k disk
PAK AFsapexp    uf a e           k disk    usropn
PAKaAFucicw5    uf   e           k disk    usropn
     fexpfpoh   o  a e           k disk
     fexpfpod   o  a e           k disk
417 Afexpfpoe   o  a e           k disk
650aAfexpfpol   o  a e           k disk
650aAfhaccpxrf  if a e           k disk
650aAfhaccplog3 if a e           k disk
SWTbAflicactive if   e           k disk    usropn
650aAflicinfo   if a e           k disk
417 Afpohexcp   o  a e           k disk
218 Afpohhdr    o  a e           k disk
510 Afpohhdrm   o  a e           k disk
218 Afpohdtl    o  a e           k disk
520aAfpohdtlm   o    e           k disk
416bAflumper    uf   e           k disk
510eAfporcv     uf   e           k disk
510fAfpohaccp   uf   e           k disk
SBRbAfpoexpq    uf a e           k disk
SBRbAfpoexpl    uf a e           k disk
510fAfpohhaccp  o  a e           k disk
FBYaAfpiruser   if   e           k disk
FBYaAfreports   if   e           k disk
SWTbAfslot2     if   e           k disk    usropn
730aAfuciinfo2  if   e           k disk
730aAfuciinfoexaif   e           k disk
730aAfitemmsc   if   e           k disk
770aA*----------------------------------------------------------------
770aA*  System options
770aA*----------------------------------------------------------------
770aAd sysoptrec     E Ds                  Extname(options)
770aA *
770aA* Data structure
770aA*
770aAd sysoptions      ds
770aAd  opepm                  1      1
770aAd  oprf                   2      2
770aAd  opcapc                 3      3
770aAd  opletd                 4      4
770aAd  opwrnc                 5      5
770aAd  oprg1c                 6      8  1
770aAd  oprg2c                 9     11  1
770aAd  opimpi                12     12
770aAd  opicw                 13     13
770aAd  opmpck                14     14
770aAd  oprcdy                15     15  0
770aAd  oppkdy                16     16  0
770aAd  oprths                17     19  0
770aAd  opcrhs                20     22  0
770aAd  oppohs                23     25  0
770aAd  opiahs                26     28  0
770aAd  opmshs                29     31  0
770aAd  optbjq                32     32
770aAd  opishs                33     35  0
770aAd  opuci                 36     36
770aAd  opwrncr               37     37
770aAd  opicwr                38     38
770aAd  optrax                39     39
770aAd  optaxr                40     40
770aAd  opchkr                41     41
770aAd  opvoice               42     42
770aAd  opslot                43     43
770aAd  opdspl                44     44
770aAd  optbpm                45     45
770aAd  opsrte                46     46
770aAd  optrna                47     47
770aAd  opsrta                48     48
770aAd  optall                49     49
770aAd  opdckv                50     50
770aAd  opaepf                51     51
770aAd  opaepo                52     52
770aAd  opamrt                53     53
770aAd  sysoptend            117    117
770aA*----------------------------------------------------------------
770aA*  Variables
770aA*
770aAd dockvue         s               n   inz('0')
770aAd ocode           s              8
     *----------------------------------------------------------------
     *  Level breaks
     *
500 D*HREC
401 D*                                             PHWHSEL1
401 D*                                             PHPO  L1
401 D*           DS
401 D*                                       1   9 PHPO
401 D*                                       8   9 PHPOTF
510cA*----------------------------------------------------------------
510cA*  Customer id
510cA*
PAK A /COPY QCOPYSRC,ID#packers
LINaA /COPY QCOPYSRC,ID#lincoln
JPFaA /COPY QCOPYSRC,ID#palmer
GLPaA /COPY QCOPYSRC,ID#glp
SBRaA /COPY QCOPYSRC,ID#sbr
FBYaA /COPY QCOPYSRC,ID#fby
SWTaA /copy qcopysrc,id#swt
650aA*
650aA*----------------------------------------------------------------
650aA*  Data Formats
650aA*
650aA /COPY *libl/qcopysrc,C#LICINFO
650aA*----------------------------------------------------------------
650aA*  Program info data structure
650aA*
650aA /Copy qcopysrc,c#pgminfds
510cA*
700cA*----------------------------------------------------------------
700cA*  Standard SQL variables and constants
700cA*
700cA /copy qcopysrc,c#stdsql
700cA
PAK A*----------------------------------------------------------------
PAK A*  SAP Export File data structures
PAK A*
PAK A /copy qcopysrc,s#edidc40
PAK A /copy qcopysrc,s#e1edl20
PAK A /copy qcopysrc,s#e1edl21
PAK A /copy qcopysrc,s#e1edl24
PAK A /copy qcopysrc,s#e1edl26
PAK A*
     *----------------------------------------------------------------
     *  Constants
     *
     d forevr          c                   const('1')
510bA*----------------------------------------------------------------
510bA*  Working variables
510bA*
520 AD dltpohdrm       s              4    inz('*NO ')
PAK AD expdate         s              8  0
PAK AD exptime         s              6  0
PAK AD loopcount       s              7  0
750 AD nostamp         s               z     inz
650aAD partialpo       s               n
PAKaAD sapcntrl        s              4    inz('*NO ')
PAK AD sapcount        s              7  0
PAKgAD sapposnbr       s              7  0
PAKhAD sappsgnum       s              5  0
510bAd spo             s              2
510bAd today           s              8  0
750aAD stamp           s               z
750aAD stampUC         s               z
     *----------------------------------------------------------------
     *  Called programs
     *
     d @cvtdt          c                   const('CVTDTE')
     d $cvtdt          ds
     d  $cvcmd                 1      8
     d  $cvprg                 9     18
     d  $cvd6i                19     24
     d  $cvd8i                25     32
     d  $cvd6o                33     38  0
     d  $cvd8o                39     46  0
     d  $cvsto                47     64
     d  $cvrtn                65     72
     d  $cverm                73    132
     d  $cvmsg                73     76
FBYaAd @prtpg          c                   const('PO330CL')
640bA*----------------------------------------------------------------
640bA*  Called program parameters
640bA*
640bAD $lparm          ds
640bAD  $lcmd                  1      8
640bAD  $lprg                  9     18
640bAD  $luky                 19     68
640bAD  $lrtn                 69     76
640bAD  $lerm                 77    136
640bAD  $lmsg                 77     80
640bA*
640bA*   Redefine key
640bAD  $lwhse                19     21  0
640bAD  $lpo                  22     30
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     * Level break check
     *
401 D*  See if there are any open transactions for the route.
401 D*
401 D*  L1      PHPOTF    IFEQ 'TF'
401 D*  L1                MOVE 'T'       KYGRP2
401 D*                    ELSE
401 D*  L1                MOVE ' '       KYGRP2
401 D*                    ENDIF
401 D*  L1      KEYLB5    SETLLLABEL5                   50
401 D*  L1                MOVE *IN50     OPNFLG  1
     *----------------------------------------------------------------
     * Main line
     *
     *  Skip order if error on reading PO header.
     *
500 Ac                   dou       forevr <> forevr
500 Ac                   read      pohdr                                7579
510dA*
510dA*      Exit after all p/o records have been read.
500 Ac                   if        *in79
500 Ac                   eval      *inlr = *on
510dAc                   leave
510dD*                  goto      bottom
500 Ac                   endif
510dA*
510dA*      Skip p/o header if record is being used.
500 Ac                   if        *in75
500 Ac                   eval      *in75 = *off
510aD*                    READ POHDR               N    79
500 Ac                   iter
500 Ac                   endif
510dD*                  leave
510dD*                  enddo
     *
     *
     *  Skip order if open transactions exist.
     *
401 D*          OPNFLG    CABEQ*ON       BOTTOM
     *
401 A*  Skip order if status is not '3' ready for export.
401 A*
650aDc**   phstat        cabne     '3'           bottom
650aMc                   if        phstat <> '3'
650aAc                             and phstat <> '4'
650aAc                   goto      bottom
650aAc                   endif
FBYaAc                   if        client = farmboy
FBYaA*
FBYaA*  Auto print receiving and pcm reports.
FBYaAc                   movel     'PO330PR '    wkprtf           10
FBYaAc     wkprtf        chain     reports                            79
FBYaAc     *in79         ifeq      *on
FBYaAc                   movel     '*STD'        $pform           10
FBYaAc                   movel     '*JOB'        $pdev            10
FBYaAc                   else
FBYaAc                   if        rpscrn = '2'
FBYaAC     #user         Chain     piruser                            79
FBYaAC                   if        *in79=*on
FBYaAC                   eval      uswhse=1
FBYaAC                   eval      usWHDP=*BLANKS
FBYaAC                   endif
FBYaAc                   call      'GETRPT'
FBYaAc                   parm      '*DEVFORM'    $rcmd             8
FBYaAC                   PARM      'PO330PR'     $LRPT            10
FBYaAC                   PARM      USwhse        $WHSE             3 0
FBYaAC                   PARM      ' '           $STYP             1
FBYaAC                   PARM      uswhdp        $WHDP             5
FBYaAC                   PARM                    $DESC            50
FBYaAC                   PARM                    $DEV             10
FBYaAC                   PARM                    $FORM            10
FBYaAc                   move      $form         $pform
FBYaAc                   move      $dev          $pdev
FBYaAC                   else
FBYaAc                   move      rpform        $pform
FBYaAc                   move      rpdev         $pdev
FBYaAC                   endif
FBYaAc                   endif
FBYaA
FBYaAc                   move      phwhse        $pwhs             3
FBYaAc                   call      @prtpg
FBYaAc                   parm                    $pwhs
FBYaAc                   parm                    phpo
FBYaAc                   parm                    $prtn             8
FBYaAc                   parm                    $pdev
FBYaAc                   parm                    $pform
FBYaA * Now print Haccp log
FBYaA * check for new or old haccp
FBYaA * check to make sure programs exist or don't do call
FBYaAC                   eval      qcmd = 'CHKOBJ '
FBYaAC                                  + 'OBJ(HA301) '
FBYaAC                                  + 'OBJTYPE(*PGM)'
FBYaAC                   call      'QCMDEXC'                            78
FBYaAC                   parm                    qcmd            256
FBYaAC                   parm      80            qlen             15 5
FBYaAc                   if        *in78 = *off
FBYaAc                   exsr      PrtLog
FBYaAc                   endif
FBYaAc                   endif
FBYaAc*    endprt        tag

650aA*
650aA*  Set flag if PO is Partial Export
650aAc                   if        phstat = '4'
650aAc                   eval      partialpo = *on
650aAc                   else
650aAc                   eval      partialpo = *off
650aAc                   endif
     *
     *  Add order header record to export header file.
     *
416 A*    Test p/o selected for export is a Super P/O. This
416 A*    will be determined by a two part test. First, if the
416 A*    first two characters of the P/O begin with "SP" and we
416 A*    find the P/O in the Super P/O cross ref file.
416 A*    Note: Only individual P/O's are written into the
416 A*          export header and detail files. Super P/O's
416 A*          only have a header and no detail records.
520 A*
520 Ac                   eval      dltpohdrm = '*NO '
416 A*
416 Ac                   movel     phpo          spo
416 Ac     keyod         setll     pospo                                  77
416 Ac                   select
416 A*    Super P/O found. Remove entries from cross-ref file.
416 Ac                   when      *in77  or
416aD*          SPO       ANDEQ'SP'
416aMc                             spo = 'SP'
416 Ac                   exsr      zzdlpu
416 A*
416 A*    Process all other P/O's.
416 Ac                   other
PAK A*
PAK AC                   select
PAK AC                   when      client = packers
PAK A*
PAK AC                   if        sapcntrl = '*NO '
PAK A*  Populate SAP Control Record and write to export file.
PAK AC                   exsr      sapcontrol
PAK AC                   exsr      sapwrite
PAKaAC                   eval      sapcntrl = '*YES'
PAK AC                   endif
PAKaA*
PAK A*      Get BFC P/O Header Misc. file.
PAK AC                   exsr      zzgetphm
PAK A*      Create SAP Header Rcd format for export file.
PAK AC                   exsr      sapheader
PAK A*      Write SAP Header Rcd format for export file.
PAK AC                   exsr      sapwrite
PAK A*      Create SAP Header Additional Data Rcd format for export file.
PAK AC                   exsr      saphdradd
PAK A*      Write SAP Header Rcd format for export file.
PAK AC                   exsr      sapwrite
LINaA*
LINaAC                   when      client = lincoln
LINaA*     Don't write to export file for MOVEIN PO
LINaAC                   if        phven <> 6090
LINa c                   exsr      filpeh
LINa c                   write     pehrec
LINa c                   endif
JPFaA*
JPFaAC                   when      client = palmer
JPFaA*     Don't write to export file for MOVEIN PO
JPFaAC                   if        phven <> 999
JPFa c                   exsr      filpeh
JPFa c                   write     pehrec
JPFa c                   endif
LINaA*
SWTaAC                   when      client = SWT
SWTaA*     Don't write to export file for Transfer PO
SWTaAC                   if        phvcty <>'999  '
SWTa c                   exsr      filpeh
SWTa c                   write     pehrec
SWTa c                   endif
SWTaA*
PAK AC                   other
PAK A*
     c                   exsr      filpeh
     c                   write     pehrec
PAK AC                   endsl
218 A*
218 A*  Add order header record to history header file.
218 A*
218 Ac                   exsr      filphh
650aAc                   if        not partialpo
218 Ac                   write     phhrec
650aAc                   endif                                                  not partialpo
510 A*
510 A*  Add order header record to history header file.
510 A*
510 Ac     keyod         chain     pohdrm                             74
510 Ac                   if        not *in74
520 Ac                   eval      dltpohdrm = '*YES'
510 Ac                   exsr      filphm
650aAc                   if        not partialpo
510 Ac                   write     phhmrc
650aAc                   endif                                                  not partialpo
510 Ac                   endif
510 A*
416bAc     lmkey         chain     lumper                             79
416bAc                   if        not *in79
416bAc                   eval      lmhedt = today
416bAc                   time                    lmheti
416bAc                   update    lmrec
416bAc                   endif
416 Ac                   endsl
510eA*  Update PORCV records with export date/time.
510e c     keyod         setll     porcv
510e c                   dou       forevr <> forevr
510e c     keyod         reade     porcv                                  78
510e c                   if        *in78
510e c                   leave
510e c                   endif
510e c                   if        poredt = 0
650cAc                             and partialpo = *off
510eAc                   eval      poredt = phhedt
510eAc                   eval      poreti = phheti
510eAc                   update    porrec
510e c                   endif
510e c                   iter
510e c                   enddo
     *
     *  Add order detail records to export detail file.
     *
218 Mc     keyod         setll     podtl
     c                   dou       forevr <> forevr
218 Mc     keyod         reade     podtl                                  78
     c                   if        *in78
     c                   leave
     c                   endif
PAK A*
PAK AC                   select
PAK AC                   when      client = packers
PAK A*
PAK A*      Get BFC Item master file.
PAK AC                   exsr      zzgetit
PAKgA*
PAK AC                   exsr      sapdetail
PAK A*      Write SAP Detail Rcd format for export file.
PAK AC                   exsr      sapwrite
PAKgA*
PAKgA*      Is item a catchweighted item? Write out UCI records.
PAKgAC                   if        itcwgt = 'Y'
PAKgA*
PAKgA*      Need to loop for as many as were received.
PAKgAC                   if        pdqrc2 <> 0
PAKgAC                   eval      loopcount = pdqrc2
PAKgAC                   else
PAKgAC                   eval      loopcount = pdqrc1
PAKgAC                   endif
PAKgA*
PAKgA*      We must loop at least once for every line item.
PAKgAC                   if        loopcount < 0
PAKgAC                   eval      loopcount = loopcount * -1
PAKgAC                   endif
PAKgA*
PAKgA*      Create SAP Detail UCI Rcd format for export file.
PAKgAC                   eval      sapcount = 0
PAKgAC     keyuci5       setll     ucicw5
PAKgAC                   dow       sapcount < loopcount
PAKgAC                             and loopcount > 0
PAKgA*
PAKgAC     keyuci5       reade     ucicw5
PAKgAC                   if        %eof(ucicw5)
PAKgAC                   eval      ucinbr = ' '
PAKgAC                   eval      uciwgt = 0
PAKgAC                   else
PAKgAC                   eval      uciped = expdate
PAKgAC                   eval      ucipet = exptime
PAKgAC                   update    ucirec
PAKgAC                   endif
PAKcA*
PAKcAC                   if        sapcount = 0
PAKcA*      Write SAP Addtl. Detail Rcd only once for item.
PAKcAC                   exsr      sapdtladd
PAKcA*      Write SAP Detail Rcd format for export file.
PAKcAC                   exsr      sapwrite
PAKcAC                   endif
PAKgA*
PAKcAC                   exsr      sapdtluci
PAKcA*      Write SAP Detail Rcd format for export file.
PAKcAC                   exsr      sapwrite
PAKgA*
PAKgAC                   eval      sapcount = sapcount + 1
PAKgA*
PAKgAC                   enddo
PAK A*
PAKgAC                   endif
PAK A*
LINaAC                   when      client = lincoln
LINaA*     Don't write to export file for MOVEIN PO
LINaAC                   if        phven <> 6090
LINa c                   exsr      filped
SBRbA*
SBRbAc                   if        client = SBertram
SBRbAc                   exsr      filpex
SBRbAc                   endif
SBRbA*
LINa c                   write     pedrec
LINa c                   endif
LINaA*
JPFaAC                   when      client = palmer
JPFaA*     Don't write to export file for MOVEIN PO
JPFaAC                   if        phven <> 999
JPFa c                   exsr      filped
JPFa c                   write     pedrec
JPFa c                   endif
JPFaA*
SWTaAC                   when      client = SWT
SWTaA*     Don't write to export file for MOVEIN PO
SWTaAC                   if        phvcty <>'999  '
SWTa c                   exsr      filped
SWTa c                   write     pedrec
SWTa c                   endif
SWTaA*
PAK AC                   other
PAK A*
     c                   exsr      filped
     c                   write     pedrec
PAK AC                   endsl
     *
650aA*  write records for License export
730aA /free
730aA   // is this Item UCI tracked?
730aA   chain (pdwhse:pditem) itemmsc;
730aA   if not %found(itemmsc);
730aA     clear imrec;
730aA   endif;
730aA /end-free
730aAc                   if        imltrk = 'U'
730aAc                   exsr      wrtpelUCI
730aAc                   else
650aAc                   exsr      wrtpel
730aAc                   endif
     *
218 A*  Add order detail records to HISTORY detail file.
650aAc                   if        not partialpo
218 Ac                   exsr      filphd
218 Ac                   write     phdrec
218 A*  Delete order detail records from PODTL file.
218 Ac                   delete    pdrec
650aAc                   endif                                                  not partialpo
     c                   enddo
520aA*
520aA*  Add p/o detail misc. records to history p/o detail misc file.
520aA*
650aAc                   if        not partialpo
520aAc     keyod         setll     podtlm
520aAc                   dou       forevr <> forevr
520aAc     keyod         reade     podtlm
520aAc                   select
520aAc                   when      %eof(podtlm)
520aAc                   leave
520aA*
520aAc                   other
520aA*
520aAc                   exsr      filpdm
520aAc                   write     phdmrc
520aA*
520aA*  Delete p/o detail misc. records from PODTLM file.
520aAc                   delete    pdmrec
520aA*
520aAc                   endsl
520aA*
520aAc                   enddo
650aAc                   endif                                                  not partialpo
520aA*
417 A*
417 A*  Add exception detail records to history exception file.
417 A*
650aAc                   if        not partialpo
417 Ac     keyod         setll     poexcp
417 Ac                   dou       forevr <> forevr
417 Ac     keyod         reade     poexcp                                 76
417 Ac                   select
417 Ac                   when      *in76
417 Ac                   leave
417 A*
417 Ac                   other
417 A*
417 Ac                   exsr      filphe
417 Ac                   write     pherec
417 A*
417 A*  Add exception detail records to export exceptions file.
PAK AC                   select
PAK AC                   when      client = packers
PAK A*      Don't write exceptions to export file.
LINaA*
LINaAC                   when      client = lincoln
LINaA*      Don't write to export file for MOVEIN PO
LINaAC                   if        phven <> 6090
LINaAc                   exsr      filpoe
LINaAc                   write     poerec
LINaAc                   endif
LINaA*
JPFaA*
JPFaAC                   when      client = palmer
JPFaA*      Don't write to export file for MOVEIN PO
JPFaAC                   if        phven <> 999
JPFaAc                   exsr      filpoe
JPFaAc                   write     poerec
JPFaAc                   endif
JPFaA*
SWTaAC                   when      client = SWT
SWTaA*      Don't write to export file for Transfer PO
SWTaAC                   if        phvcty <>'999  '
SWTaAc                   exsr      filpoe
SWTaAc                   write     poerec
SWTaAc                   endif
SWTaA*
PAK AC                   other
PAK A*
417 Ac                   exsr      filpoe
417 Ac                   write     poerec
PAK AC                   endsl
417 A*
417 A*  Delete exception detail records from POEXCP file.
417 Ac                   delete    perec
417 A*
417 Ac                   endsl
417 A*
417 Ac                   enddo
650aAc                   endif                                                  not partialpo
417 A*
     *  Create HACCP history record and delete original.
650aAc                   if        not partialpo
510fac     keyod         setll     pohaccp
510fac     keyod         reade     pohaccp
510fac                   dow       not %eof
     *
510fac                   exsr      filhaccp
510fac                   write     hahrec
510fac                   delete    harec
     *
510fac     keyod         reade     pohaccp
510fac                   enddo
650bAc                   endif                                                  not partialpo
640bA*
640bA*  Call HA710 to update new haccp log file with export info.
640bAc                   eval      $lcmd = '*EXPORT'
640bAc                   eval      $lwhse = phwhse
640bAc                   eval      $lpo   = phpo
640bAc                   call      'HA710'
640bAc                   parm                    $lparm
650aAc**                 endif                                                  not partialpo
     *
650aAc                   select
218 A*  If partial export, change status back to 1.
650aAc                   when      partialpo
650aAc                   eval      phstat = '1'
650aAc                   update    phrec
650aA*
710aA*  If Super PO, change status back to 0.
710aAc                   when      *in77
710aAc                   eval      phstat = '0'
710aAc                   update    phrec
710aA*
650aAc                   other
218 A*  Delete order header records from POHDR file.
218 Ac                   delete    phrec
750 A*
750 Ac                   eval      phstat = '4'
770aA*
770aA /free
770aA   // Set status for DockVue
770aA   if dockvue;
770aA     exec sql insert into postatus
770aA              values (:phwhse, :phpo, :phstat,
770aA                      current_timestamp, :nostamp);
770aA*
770aA     if sqlstate <> sqlSuccess;
770aA       exec sql update postatus
770aA                   set posstat = :phstat,
770aA                       posupdts = current_timestamp
770aA               where poswhs = :phwhse
770aA                 and pospo = :phpo;
770aA     endif;
770aA   endif;
770a *
770aA /end-free
510 A*
510 A*  Delete order header misc. record from POHDRM file.
520 DC*                  if        not *in74
520 MC                   if        dltpohdrm = '*YES'
510 Ac                   delete    phmrec
510 Ac                   endif
650aA*
650aAc                   endsl
510dA*
510dAc                   enddo
     *
218 D*  Update  header record with upload date and time.
218 D*
218 D*                    Z-ADDTODAY     PHHUDT
218 D*                    TIME           PHHUTI
218 D*                    UPDATPHHREC
     *
     c     bottom        tag
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     c     *inzsr        begsr
510cA*
510cA* Get client id.
510cA*
510cAc                   call      'GETCLIENT'
510cAc                   parm                    client           10
510cAc                   parm                    clientloc        10
510cA*
PAK A*
PAK A*   Define full key for POHDRM file
PAK A*
PAK AC     keyphm        klist
PAK AC                   kfld                    phwhse
PAK AC                   kfld                    phpo
SBRbA*
SBRbA*   Define full key for POEXPQ file.
SBRbA*
SBRbAC     keypex        klist
SBRbAC                   kfld                    pdwhse
SBRbAC                   kfld                    pdpo
SBRbAC                   kfld                    pdseq
SBRbAC                   kfld                    pditem
SBRbAC     keypxl        klist
SBRbAC                   kfld                    porwhs
SBRbAC                   kfld                    porpo
SBRbAC                   kfld                    porlic
PAK A*
PAK A*   Define full key for PIRITEM file.
PAK A*
PAK AC     keyit         klist
PAK AC                   kfld                    pdwhse
PAK AC                   kfld                    pditem
     *
218 M*   Define partial key for PODTL file.
     *
     c     keyod         klist
     c                   kfld                    phwhse
     c                   kfld                    phpo
650aA*
650aA*   Define partial key for PORCV file.
650aA*
650aAc     keyrcv        klist
650aAc                   kfld                    pdwhse
650aAc                   kfld                    pdpo
650aAc                   kfld                    pdseq
650aA*
650aA*   Define unique key for HACCPLOG file.
650aA*
650aAc     keyhcp        klist
650aAc                   kfld                    hxwhse
650aAc                   kfld                    hxpo
650aAc                   kfld                    hxposeq
650aAc                   kfld                    hxseq#
650aA*
650aA*   Define unique key for LICINFO file.
650aA*
650aAc     keylic        klist
650aAc                   kfld                    porwhs
650aAc                   kfld                    porlic
650aAc                   kfld                    lnseq
416bA*
416bA*   Define key for Lumper file.
416bA*
416bAc     lmkey         klist
416bAc                   kfld                    phwhse
416bAc                   kfld                    phpo
SWTbA*
SWTbA*   Define key for LICACTIVE file.
SWTbA*
SWTbAc     keyla         klist
SWTbAc                   kfld                    porwhs
SWTbAc                   kfld                    porlic
SWTbA*
SWTbA*   Define key for SLOT2 file.
SWTbA*
SWTbAc     keysl2        klist
SWTbAc                   kfld                    porwhs
SWTbAc                   kfld                    lawhdp
SWTbAc                   kfld                    ladisp
PAKaA*
PAKaA*   Define partial key for UCICW5 file.
PAKaA*
PAKaAC     *like         define    uciped        kyuciped
PAKaAC     *like         define    ucipet        kyucipet
PAKaAC     keyuci5       klist
PAKaAC                   kfld                    phwhse
PAKaAC                   kfld                    phpo
PAKaAC                   kfld                    kyuciped
PAKaAC                   kfld                    kyucipet
PAKaAC                   kfld                    pdseq
PAKaAC                   kfld                    pditem
     *
     *   Define partial key for LABEL5 file.
     *
401 D*R         *LIKE     DEFN L5RTE     KYRTE
401 D*R         *LIKE     DEFN L5GRP2    KYGRP2
401 D*R         *LIKE     DEFN L5PBAT    KYPBAT
401 D*R                   MOVE *ZEROS    KYRTE
401 D*R                   MOVE *ZEROS    KYPBAT
401 D*R         KEYLB5    KLIST
401 D*R                   KFLD           PHWHSE
401 D*R                   KFLD           KYGRP2
401 D*R                   KFLD           KYRTE
401 D*R                   KFLD           PHPO
401 D*R                   KFLD           KYPBAT
     *
     *  Convert today's date into century format.
     *
     c                   eval      $cvcmd = '*CURCMD '
     c                   call      @cvtdt
     c                   parm                    $cvtdt
     c                   eval      today = $cvd8o
PAK A*
PAK A* Open EXPSAP Export File for Packer's.
PAK AC                   eval      expdate = today
PAK AC                   time                    exptime
PAK A*
PAK AC                   if        client = packers
PAK AC                   if        not %open(sapexp)
PAK AC                   open      sapexp
PAK AC                   endif
PAKaA*
PAKaA* Open UCICW5 UCI Catchweight file for Packer's.
PAKaAC                   if        not %open(ucicw5)
PAKaAC                   open      ucicw5
PAKaAC                   endif
PAK AC                   endif
SWTbA*
SWTbA* Open Licactive for license location info.
SWTbAC                   if        client = swt
SWTbAC                   if        not %open(licactive)
SWTbAC                   open      licactive
SWTbAC                   endif
SWTbAC                   endif
SWTbA*
SWTbA* Open Slot2 for Slot status info.
SWTbAC                   if        client = swt
SWTbAC                   if        not %open(slot2)
SWTbAC                   open      slot2
SWTbAC                   endif
SWTbAC                   endif
     *
770aA
770aA*  Get System options
770aA /free
770aA   ocode = '*SYSTEM ';
770aA   exec sql select * into :sysoptrec
770aA              from options
770aA             where opwhse = 0
770aA               and opcode = :ocode;
770aA
770aA   If sqlstt = sqlSuccess;
770aA     sysoptions = opdata;
770aA   else;
770aA     opdckv = 'N';
770aA   endif;
770aA
770aA   If opdckv = 'Y';
770aA     dockvue = *on;
770aA   else;
770aA     dockvue = *off;
770aA   endif;
770aA
     *
     c                   endsr
     *----------------------------------------------------------------
     *
     *  FILPED  Fill export detail fields.
     *
     c     filped        begsr
     *
     *  Initialize record
     *
     c                   clear                   pedrec
     *
     *  Move fields from order file to export file.
     *
     c                   eval      pedwhs = pdwhse
SBRaAc                   select
SBRaAc                   when      client = sbertram
SBRaAc                   evalr     pedpo = %trim(pdpo)
SBRaAc                   other
     c                   eval      pedpo = pdpo
SBRaAc                   endsl
     c                   eval      pedseq = pdseq
     c                   eval      peditm = pditem
     c                   eval      pedvit = pdvitm
     c                   eval      pedspc = pdspcl
     c                   eval      pedq1 = pdqor1
     c                   eval      pedq2 = pdqor2
     c                   eval      pedq3 = pdqor3
     c                   eval      pedqr1 = pdqrc1
     c                   eval      pedqr2 = pdqrc2
     c                   eval      pedqr3 = pdqrc3
221 Ac                   eval      pedwgt = pddwgt
     *
     c                   endsr
     *----------------------------------------------------------------
     *
     *  FILPEH   Fill export header fields.
     *
     c     filpeh        begsr
     *
     *  Initialize record
     *
     c                   clear                   pehrec
     *
     *  Move fields from order file to export file.
     *
     c                   eval      pehwhs = phwhse
SBRaAc                   select
SBRaAc                   when      client = sbertram
SBRaAc                   evalr     pehpo = %trim(phpo)
SBRaAc                   other
     c                   eval      pehpo = phpo
SBRaAc                   endsl
     c                   eval      pehven = phven
     c                   eval      pehvnm = phvnam
     c                   eval      pehad1 = phvad1
     c                   eval      pehad2 = phvad2
     c                   eval      pehcty = phvcty
     c                   eval      pehst = phvst
     c                   eval      pehzp1 = phvzp1
     c                   eval      pehdte = phdate
     c                   eval      pehtim = phtime
     *
650aAc                   if        partialpo
650aAc                   eval      pehamp = 'U'
650aAc                   else
     c                   eval      pehamp = phampm
650aAc                   endif
     *
     c                   endsr
218 A*----------------------------------------------------------------
218 A*
218 A*  FILPHD  Fill history detail fields.
218 A*
218 Ac     filphd        begsr
218 A*
218 A*  Initialize record
218 A*
218 Ac                   clear                   pedrec
218 A*
218 A*  Move fields from order file to po history detail file.
218 A*
218 Ac                   eval      phdwhs = pdwhse
218 Ac                   eval      phdpo = pdpo
218 Ac                   eval      phdseq = pdseq
218 Ac                   eval      phditm = pditem
218 Ac                   eval      phdvit = pdvitm
218 Ac                   eval      phdspc = pdspcl
218 Ac                   eval      phdqo1 = pdqor1
218 Ac                   eval      phdqo2 = pdqor2
218 Ac                   eval      phdqo3 = pdqor3
218 Ac                   eval      phdqr1 = pdqrc1
218 Ac                   eval      phdqr2 = pdqrc2
218 Ac                   eval      phdqr3 = pdqrc3
218 Ac                   eval      phdwgt = pddwgt
218 Ac                   eval      phdedt = phhedt
218 Ac                   eval      phdeti = phheti
218 A*
218 Ac                   endsr
417 A*
417 A*----------------------------------------------------------------
417 A*
417 A*  FILPHE  Fill history receiving exception detail file.
417 A*
417 Ac     filphe        begsr
417 A*
417 A*  Initialize record
417 A*
417 Ac                   clear                   pherec
417 A*
417 A*  Move fields from exception file to po history exception file
417 A*
417 Ac                   eval      phewhs = pewhse
417 Ac                   eval      phepo = pepo
417 Ac                   eval      pheseq = peseq
417 Ac                   eval      pheitm = peitem
417 Ac                   eval      phecod = pecode
417 Ac                   eval      pheqy1 = peqex1
417 Ac                   eval      pheqy2 = peqex2
417 Ac                   eval      pheqy3 = peqex3
417 Ac                   eval      pheusr = peuser
417 Ac                   eval      phedev = pedev
417 Ac                   eval      pheemp = peemp
417 A*
417 Ac                   eval      pheedt = phhedt
417 Ac                   eval      pheeti = phheti
417 A*
417 Ac                   endsr
417 A*
218 A*----------------------------------------------------------------
218 A*
218 A*  FILPHH   Fill history header fields.
218 A*
218 Ac     filphh        begsr
218 A*
218 A*  Initialize record
218 A*
218 Ac                   clear                   phhrec
218 A*
218 A*  Move fields from PO Header file to PO Header history file.
218 A*
218 Ac                   eval      phhwhs = phwhse
218 Ac                   eval      phhpo = phpo
218 Ac                   eval      phhven = phven
218 Ac                   eval      phhvna = phvnam
218 Ac                   eval      phhva1 = phvad1
218 Ac                   eval      phhva2 = phvad2
218 Ac                   eval      phhvct = phvcty
218 Ac                   eval      phhvst = phvst
218 Ac                   eval      phhvzp = phvzp1
218 Ac                   eval      phhdte = phdate
218 Ac                   eval      phhtim = phtime
218 Ac                   eval      phhamp = phampm
218 Ac                   eval      phhudt = phudte
218 Ac                   eval      phhuti = phutim
218 Ac                   eval      phhedt = today
218 Ac                   time                    phheti
218 A*
218 Ac                   endsr
510 A*
510 A*----------------------------------------------------------------
510 A*
510 A*  FILPHM   Fill history header misc. fields.
510 A*
510 Ac     filphm        begsr
510 A*
510 A*  Initialize record
510 A*
510 Ac                   clear                   phhmrc
510 A*
510 A*  Move flds from PO Hdr Misc. file to PO Hdr Misc. history
510 A*
510 Ac                   eval      phhmwh = phwhse
510 Ac                   eval      phhmpo = phpo
510 Ac                   eval      phhmm1 = phmm1
510 Ac                   eval      phhmm2 = phmm2
510 Ac                   eval      phhmm3 = phmm3
510 Ac                   eval      phhmm4 = phmm4
510 Ac                   eval      phhmm5 = phmm5
510 Ac                   eval      phhmed = phhedt
510 Ac                   eval      phhmet = phheti
510 A*
510 Ac                   endsr
520aA*
520aA*----------------------------------------------------------------
520aA*
520aA*  FILPDM   Fill history detail misc. fields.
520aA*
520aAc     filpdm        begsr
520aA*
520aA*  Initialize record
520aA*
520aAc                   clear                   phdmrc
520aA*
520aA*  Move flds from PO Hdr Misc. file to PO Hdr Misc. history
520aA*
520aAc                   eval      phdmwh = pdmwhs
520aAc                   eval      phdmpo = pdmpo
520aAc                   eval      phdmsq = pdmseq
520aAc                   eval      phdmit = pdmitm
520cAc                   eval      phdmod = pdmods
520aAc                   eval      phdmpm = pdmpom
520aAc                   eval      phdms1 = pdmms1
520aAc                   eval      phdms2 = pdmms2
520aAc                   eval      phdms3 = pdmms3
520aAc                   eval      phdms4 = pdmms4
520aAc                   eval      phdms5 = pdmms5
520aAc                   eval      phdmed = phhedt
540 Dc*                  eval      phhmet = phheti
540 Mc                   eval      phdmet = phheti
520aA*
520aAc                   endsr
417 A*
SBRbA*----------------------------------------------------------------
SBRbA*
SBRbA*  FILPEX  Fill export quanity fields.
SBRbA*
SBRbAc     filpex        begsr
SBRbA*
SBRbA*  Initialize record
SBRbA*
SBRbAc                   clear                   pxrec
750aAc                   exsr      zzzGetStamps
SBRbA*
SBRbA*  Move fields from order file to export file.
SBRbA*
SBRbAc     keypex        chain     poexpq
SBRbAc                   if        %found(poexpq)
SBRbAc                   eval      pedqr1 = pedqr1 - pxqex1
SBRbAc                   eval      pedqr2 = pedqr2 - pxqex2
SBRbAc                   eval      pedqr3 = pedqr3 - pxqex3
SBRbAc                   eval      pedwgt = pedwgt - pxqwgt
SBRbAc                   eval      pxqex1 = pedqr1 + pxqex1
SBRbAc                   eval      pxqex2 = pedqr2 + pxqex2
SBRbAc                   eval      pxqex3 = pedqr3 + pxqex3
SBRbAc                   eval      pxqwgt = pedwgt + pxqwgt
750aAc                   eval      pxupdts = stamp
SBRbAc                   update    pxrec
SBRbA*
SBRbAc                   else
SBRbAc                   eval      pxwhse = pdwhse
SBRbAc                   eval      pxpo   = pdpo
SBRbAc                   eval      pxseq  = pdseq
SBRbAc                   eval      pxitem = pditem
SBRbAc                   eval      pxqex1 = pedqr1
SBRbAc                   eval      pxqex2 = pedqr2
SBRbAc                   eval      pxqex3 = pedqr3
SBRbAc                   eval      pxqwgt = pedwgt
750aAc                   eval      pxupdts = stamp
SBRbAc                   write     pxrec
SBRbAc                   endif
SBRbA*
SBRbAc                   endsr
417 A*----------------------------------------------------------------
417 A*
417 A*  FILPOE  Fill export receiving exception detail fields.
417 A*
417 Ac     filpoe        begsr
417 A*
417 A*  Initialize record
417 A*
417 Ac                   clear                   poerec
417 A*
417 A*  Move fields from exception file to po export exception file
417 A*
417 Ac                   eval      poewhs = pewhse
417 Ac                   eval      poepo = pepo
417 Ac                   eval      poeseq = peseq
417 Ac                   eval      poeitm = peitem
417 Ac                   eval      poecod = pecode
417 Ac                   eval      poeqe1 = peqex1
417 Ac                   eval      poeqe2 = peqex2
417 Ac                   eval      poeqe3 = peqex3
417 Ac                   eval      poeusr = peuser
417 Ac                   eval      poedev = pedev
417 Ac                   eval      poeemp = peemp
417 A*
417 Ac                   endsr
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
PAKeMC                   eval      sap_mand    = '220'
PAKeDC**                 eval      sap_mand    = '210'
PAK AC                   endsl
PAK A*
PAK AC                   eval      sap_docnum  = %editc(expdate:'X') +
PAK AC                                           %editc(exptime:'X')
PAK A*
PAK AC                   eval      sap_direct  = '2'
PAK A*
PAKbDC*                  eval      sap_rcvport = 'A000000008'
PAKbMC                   eval      sap_rcvport = 'LSMW      '
PAKbDC*                  eval      sap_rcvprn  = 'PPBFC210'
PAKbMC                   eval      sap_rcvprn  = 'DEVCLNT220'
PAK A*
PAKbDC*                  eval      sap_sndport = 'A000000008'
PAKbMC                   eval      sap_sndport = 'LSMW      '
PAKbAC                   eval      sap_sndprn  = 'DEVCLNT220'
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
PAKdAC                   eval      sap_L24mand = sap_mand
PAKhAC                   eval      sappsgnum = sappsgnum + 1
PAKhAC                   eval      sap_L24psgnum = %editc(sappsgnum:'3')
PAK A*
PAKgAC                   evalr     sap_posnr = %trimr(%editc(pdseq:'3'))
PAK A*
PAK AC                   eval      sap_matnr = ' ' + pditem
PAK AC                   eval      sap_lgort = %subst(phmm1:34:4)
PAK A*
PAK A*      Customer received eaches.
PAK AC                   if        pdqrc2 <> 0
PAKgAC                   evalr     sap_lfimg = %trimr(%editc(pdqrc2:'3'))
PAKfAC                   eval      sap_vrkme = 'EA'
PAK AC                   evalr     sap_lgmng = sap_lfimg
PAK AC                   eval      sap_meins = 'EA'
PAK AC                   else
PAK A*      Customer received cases.
PAKgAC                   evalr     sap_lfimg = %trimr(%editc(pdqrc1:'3'))
PAKgAC                   eval      sap_vrkme = 'CV'
PAK AC                   evalr     sap_lgmng = sap_lfimg
PAKgMC                   eval      sap_meins = 'CV'
PAK AC                   endif
PAK A*
PAK MC                   evalr     sap_ntgew = ' '
PAKfAC                   evalr     sap_brgew = ' '
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
PAKhAC                   eval      sappsgnum = sappsgnum + 1
PAKhAC                   eval      sap_L26psgnum = %editc(sappsgnum:'3')
PAK A*
PAK A*      Load record format into export file field.
PAK AC                   eval      spdata      = s#e1edl26
PAK AC                   endsr
PAKgA*----------------------------------------------------------------
PAKgA*
PAKgA*  SAPDTLUCI    Populate SAP Detail UCI Record.
PAKgA*
PAKgAC     sapdtluci     begsr
PAKgA*
PAKgAC                   reset                   s#e1edl24
PAKgA*
PAKgAC                   eval      sap_L24mand = sap_mand
PAKhAC                   eval      sappsgnum = sappsgnum + 1
PAKhAC                   eval      sap_L24psgnum = %editc(sappsgnum:'3')
PAKgA*
PAKgAC                   eval      sapposnbr = 900000 + pdseq
PAKgAC                   evalr     sap_posnr = %trimr(%editc(sapposnbr:'4'))
PAKgAC                   eval      sap_matnr = ' ' + pditem
PAKgAC                   eval      sap_lgort = %subst(phmm1:34:4)
PAKgA*
PAKgAC                   eval      sap_charg = ucinbr
PAKgA*
PAKgA*      Customer received eaches.
PAKgAC                   if        pdqrc2 <> 0
PAKgAC                   evalr     sap_lfimg = %trimr('1')
PAKgAC                   eval      sap_vrkme = 'EA'
PAKgAC                   evalr     sap_lgmng = sap_lfimg
PAKgAC                   eval      sap_meins = 'EA'
PAKgAC                   else
PAKgA*      Customer received cases.
PAKgAC                   evalr     sap_lfimg = %trimr('1')
PAKgAC                   eval      sap_vrkme = 'CV'
PAKgAC                   evalr     sap_lgmng = sap_lfimg
PAKgAC                   eval      sap_meins = 'CV'
PAKgAC                   endif
PAKgA*
PAKgA*      Use actual catchweight.
PAKgAC                   evalr     sap_ntgew = %trimr(%editc(uciwgt:'3'))
PAKgAC                   evalr     sap_brgew = %trimr(%editc(uciwgt:'3'))
PAKgA*
PAKgA*      Load record format into export file field.
PAKgAC                   eval      spdata      = s#e1edl24
PAKgAC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  SAPHEADER    Populate SAP Header Record.
PAK A*
PAK AC     sapheader     begsr
PAK A*
PAK AC                   reset                   s#e1edl20
PAK A*
PAKdAC                   eval      sap_L20mand = sap_mand
PAKhAC                   eval      sappsgnum = sappsgnum + 1
PAKhAC                   eval      sap_L20psgnum = %editc(sappsgnum:'3')
PAKhA*
PAKdMC                   evalr     sap_vbeln = %trimr(phpo)
PAK AC                   eval      sap_vstel = %subst(phmm2:1:4)
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
PAKfAC                   eval      sap_L21mand = sap_mand
PAKhAC                   eval      sappsgnum = sappsgnum + 1
PAKhAC                   eval      sap_L21psgnum = %editc(sappsgnum:'3')
PAKhA*
PAKbDC*                  eval      sap_lfart = 'ZPEL'
PAKbMC                   eval      sap_lfart = 'EL  '
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
650aA*----------------------------------------------------------------
650aA*
650aA*  WRTPEL  Write license export fields.
650aA*
650aAc     wrtpel        begsr
650aA*
650aA*  Initialize record
650aA*
650aAc                   clear                   pelrec
650aA*
650aA*  Move fields from license file to export file.
650aA*
700 Dc*                  eval      pedwhs = pdwhse
700 Mc                   eval      pelwhs = pdwhse
650aAc                   eval      pelpo = pdpo
650aAc                   eval      pelseq = pdseq
650aAc                   eval      pelitm = pditem
650aA*
650aA*  Read receipt detail and write license records
650aAc     keyrcv        setll     porcv
650aA*
650aAc                   dou       forevr <> forevr
650aAc     keyrcv        reade     porcv                                  78
650aAc                   if        *in78
650aAc                   leave
650aAc                   endif
700bA*
700bA*  Skip if license was deleted
700cA*    or only touched.
700bAc                   if        poract = 'D'
700cAc                             or poract = 'X'
700bAc                   iter
700bAc                   endif
700bAc                   if        poract = 'D'
700bAc                   iter
700bAc                   endif
SWTbA*
SWTbAc                   if        client = SWt
SWTbAc                             and porlic <> *blanks
SWTbAc                             and poredt = phhedt
SWTbAc                             and poreti = phheti
SWTbA*    Retrieve license and current slot for license.
SWTbAC     keyla         setll     licactive
SWTbAC     keyla         reade     licactive
SWTbAC                   if        %eof(licactive)
SWTbAC                   eval      lawhdp = ' '
SWTbAC                   eval      ladisp = ' '
SWTbAC                   endif
SWTbA*
SWTbAC     keysl2        chain     slot2
SWTbAC                   if        not %found(slot2)
SWTbAC                   eval      slstat = ' '
SWTbAC                   endif
SWTbA*
SWTbAC                   endif
SBRbA*
SBRbAc                   if        client = SBertram
SBRbAc                             and porlic <> *blanks
SBRbAc     keypxl        chain     poexpl
SBRbAc                   if        %found(poexpl)
SBRbAc                   iter
SBRbAc                   else
SBRbAc                   eval      pxlwhs = porwhs
SBRbAc                   eval      pxlpo  = porpo
SBRbAc                   eval      pxlseq = porseq
SBRbAc                   eval      pxlitm = pditem
SBRbAc                   eval      pxllic = porlic
SBRbAc                   write     pxlrec
SBRbAc                   endif
SBRbAc                   endif
650aA*
650aAC                   eval      pellic = porlic
650aA*
650aA*  Get License Information
650aA*
650aAC                   eval      lnseq = 1
650aAC     keylic        chain     licinfo
650aA*
650aAC                   if        %found(licinfo)
650aAC                   eval      pellot = lnlot
700cDC*                  eval      pelqt1 = lnrcvqty
700cDC*                  eval      pelqt2 = 0
700cDC*                  eval      pelqt3 = 0
650aAC                   eval      pelbrd = lnbrand
700cA /free
700cA   exec sql select llaqty1, llaqty2, llaqty3
700cA              into :pelqt1, :pelqt2, :pelqt3
700cA              from liclog
700cA             where llwhse = :porwhs
700cA               and lllcns = :porlic
700cA               and llaction = 'RCV';
700cA     if sqlstt <> sqlsuccess;
700cA       pelqt1 = lnrcvqty;
700cA       pelqt2 = 0;
700cA       pelqt3 = 0;
700cA     endif;
700cA /end-free
650aAC                   else
SBRcAc                   if        client = SBertram
SBRcAc                             and poract = 'R'
SBRcAC                   eval      pellot = *blanks
SBRcAC                   eval      pelqt1 = pdqrc1
SBRcAC                   eval      pelqt2 = pdqrc2
SBRcAC                   eval      pelqt3 = pdqrc3
SBRcAC                   eval      pelbrd = *blanks
SBRcAC                   eval      lnaddusr = *blanks
SBRcAC                   else
650aAC                   eval      pellot = *blanks
650aAC                   eval      pelqt1 = 0
650aAC                   eval      pelqt2 = 0
650aAC                   eval      pelqt3 = 0
650aAC                   eval      pelbrd = *blanks
650dAC                   eval      lnaddusr = *blanks
SBRcAC                   endif
650aAC                   endif
GLPaA*
GLPaAC                   if        client = Greenleaf
GLPaA*
GLPaA*      Retrieve user number from PIR User table.
GLPaAC                   eval      #buyerid = lnaddusr
GLPaAC                   call      'GETUSER'
GLPaAC                   parm                    #buyerid         10
GLPaAC                   parm      0             #whse             3 0
GLPaAC                   parm      0             #emp#             5 0
GLPaAC                   parm                    #fnam            15
GLPaAC                   parm                    #init             1
GLPaAC                   parm                    #lnam            20
GLPaAC                   parm                    #whdp             5
GLPaAC                   parm                    #styp             1
GLPaAC                   parm                    #shft             6
GLPaAC                   parm                    #crew             6
GLPaAC                   parm      0             #nhrs             3 1
GLPaAC                   parm                    #rtn              8
GLPaA*      Update user ID for item.
GLPaAC                   if        #rtn = '*OK'
GLPaA*
GLPaAC                   if        %subst(#lnam:18:3) = *blanks
GLPaAC                   eval      pelrby = lnaddusr
GLPaAC                   else
GLPaAC                   eval      pelrby = %subst(#lnam:18:3)
GLPaAC                   endif
GLPaAC                   eval      pelemp = #emp#
GLPaA*
GLPaAC                   else
GLPaAC                   eval      pelrby = lnaddusr
GLPaAC                   eval      pelemp = 0
GLPaAC                   endif
GLPaA*
GLPaAC                   endif
GLPaA*
650aA*
650aA*  Get COOL info from HACCP files
650aAC                   eval      peloco = *blanks
650aAC                   eval      pelost = *blanks
650aAC                   eval      pelocy = *blanks
650aA*
650aAC     porlic        setll     hxrec
650aAC     porlic        reade     hxrec
650aA*
650aAC                   dow       not %eof()
650aAC     keyhcp        chain     hlrec
650aAC                   if        %found(haccplog3)
650aAC                   select
650aAC                   when      hlseq# = 1
650aAC                   eval      peloco = hldata
650aAC                   when      hlseq# = 2
650aAC                   eval      pelost = hldata
650aAC                   when      hlseq# = 3
650aAC                   eval      pelocy = hldata
650aAC                   endsl
650aAc                   endif
650aAC     porlic        reade     hxrec
650aAc                   enddo
SWTbA*
SWTbA*    Send slot info for license in COOL County field.
SWTbAC                   if        client = SWT
SWTbAc                             and porlic <> *blanks
SWTbAc                             and poredt = phhedt
SWTbAc                             and poreti = phheti
SWTbAC                   eval      pelocy = ladisp
SWTbAC                   eval      pelocy = %replace(slstat:pelocy:13:2)
SWTbAC                   endif
650aA*
650aA*  Write license record
650aAc                   write     pelrec
650aAc                   enddo
650aA*
650aAc                   endsr
650aA*
730aA*----------------------------------------------------------------
730aA*
730aA*  WRTPELUCI  Write license export fields - UCI
730aA*
730aAc     wrtpelUCI     begsr
730aA*
730aA*  Initialize record
730aA*
730aAc                   clear                   pelrec
730aA*
730aA*  Move fields from license file to export file.
730aA*
730AAc                   eval      pelwhs = pdwhse
730AAc                   eval      pelpo = pdpo
730aAc                   eval      pelseq = pdseq
730aAc                   eval      pelitm = pditem
730aA*
730aA*  Read receipt detail and write license records
730aAc     keyrcv        setll     porcv
730aA*
730aAc                   dou       forevr <> forevr
730aAc     keyrcv        reade     porcv                                  78
730aAc                   if        *in78
730aAc                   leave
730aAc                   endif
730aA*
730aA*  Skip if license was deleted
730aAc                   if        poract = 'D'
730aAc                   iter
730aAc                   endif
730aA*
SWTbAc                   if        client = SWt
SWTbAc                             and porlic <> *blanks
SWTbAc                             and poredt = phhedt
SWTbAc                             and poreti = phheti
SWTbA*    Retrieve license and current slot for license.
SWTbAC     keyla         setll     licactive
SWTbAC     keyla         reade     licactive
SWTbAC                   if        %eof(licactive)
SWTbAC                   eval      lawhdp = ' '
SWTbAC                   eval      ladisp = ' '
SWTbAC                   endif
SWTbA*
SWTbAC     keysl2        chain     slot2
SWTbAC                   if        not %found(slot2)
SWTbAC                   eval      slstat = ' '
SWTbAC                   endif
SWTbA*
SWTbAC                   endif
730aA
730aA*
730aA*  Get uci data
730aA*
730aA /free
730aA   setll (pdwhse:porlic) uciinfo2;
730aA   dow forevr = forevr;
730aA     reade (pdwhse:porlic) uciinfo2;
730aA     if %eof(uciinfo2);
730aA       leave;
730aA     endif;
730aA     // now get the extension file for the rest of the data
730aA     chain (UIADDTS:UIUCILCNS:UILCNS) uciinfoexa;
730aA     if not %found(uciinfoexa);
730aA       clear UIAREC;
730aA     endif;
730aA
730aA     select;
730aA       when uiserial <> ' ';
730aA         pellic = uiserial;
730aA       when uialot <> ' ';
730aA         pellic = uialot;
730aA       when %subst(uiuci:1:3) = '99I';
730aA         pellic = uiuci;
730aA       other;
730aA         pellic = uilcns;
730aA     endsl;
730aA     pellot = uialot;
730aA     select;
730aA       when uiautyp = 'N';
730aA         pelqt1 = 1;
730aA       when uiautyp = '1';
730aA         pelqt2 = 1;
730aA       when uiautyp = '2';
730aA         pelqt3 = 1;
730aA       other;
730aA         pelqt1 = 1;
730aA     endsl;
730aA /end-free
730aA*
730aA*  Get License Information
730aA*
730aAC                   eval      lnseq = 1
730aAC     keylic        chain     licinfo
730aA*
730aAC                   if        %found(licinfo)
730aAC                   eval      pelbrd = lnbrand
730aAC                   else
730aAC                   eval      pelbrd = *blanks
730aAC                   eval      lnaddusr = *blanks
730aAC                   endif
730aA*
730aAC                   if        client = Greenleaf
730aA*
730aA*      Retrieve user number from PIR User table.
730aAC                   eval      #buyerid = lnaddusr
730aAC                   call      'GETUSER'
730aAC                   parm                    #buyerid         10
730aAC                   parm      0             #whse             3 0
730aAC                   parm      0             #emp#             5 0
730aAC                   parm                    #fnam            15
730aAC                   parm                    #init             1
730aAC                   parm                    #lnam            20
730aAC                   parm                    #whdp             5
730aAC                   parm                    #styp             1
730aAC                   parm                    #shft             6
730aAC                   parm                    #crew             6
730aAC                   parm      0             #nhrs             3 1
730aAC                   parm                    #rtn              8
730aA*      Update user ID for item.
730aAC                   if        #rtn = '*OK'
730aA*
730aAC                   if        %subst(#lnam:18:3) = *blanks
730aAC                   eval      pelrby = lnaddusr
730aAC                   else
730aAC                   eval      pelrby = %subst(#lnam:18:3)
730aAC                   endif
730aAC                   eval      pelemp = #emp#
730aA*
730aAC                   else
730aAC                   eval      pelrby = lnaddusr
730aAC                   eval      pelemp = 0
730aAC                   endif
730aA*
730aAC                   endif
730aA*
730aA*
730aA*  Get COOL info from HACCP files
730aAC                   eval      peloco = *blanks
730aAC                   eval      pelost = *blanks
730aAC                   eval      pelocy = *blanks
730aA*
730aAC     porlic        setll     hxrec
730aAC     porlic        reade     hxrec
730aA*
730aAC                   dow       not %eof()
730aAC     keyhcp        chain     hlrec
730aAC                   if        %found(haccplog3)
730aAC                   select
730aAC                   when      hlseq# = 1
730aAC                   eval      peloco = hldata
730aAC                   when      hlseq# = 2
730aAC                   eval      pelost = hldata
730aAC                   when      hlseq# = 3
730aAC                   eval      pelocy = hldata
730aAC                   endsl
730aAc                   endif
730aAC     porlic        reade     hxrec
730aAc                   enddo
SWTbA*
SWTbA*    Send slot info for license in COOL County field.
SWTbAC                   if        client = SWT
SWTbAc                             and porlic <> *blanks
SWTbAc                             and poredt = phhedt
SWTbAc                             and poreti = phheti
SWTbAC                   eval      pelocy = ladisp
SWTbAC                   eval      pelocy = %replace(slstat:pelocy:13:2)
SWTbAC                   endif
730aA*
730aA*  Write license record
730aAc                   write     pelrec
730aA /free
730aA   enddo;
730aA /end-free
730aAc                   enddo
730aA*
730aAc                   endsr
730aA*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  ZZGETPHM    Get P/O Header Misc. file.
PAK A*
PAK AC     zzgetphm      begsr
PAK A*
PAKzDC*    keyphm        chain     pohdrm
PAKzMC     keyphm        chain (n) pohdrm
PAK AC                   if        not %found(pohdrm)
PAK AC                   eval      phmm1 = ' '
PAK AC                   eval      phmm2 = ' '
PAK AC                   eval      phmm3 = ' '
PAK AC                   eval      phmm4 = ' '
PAK AC                   eval      phmm5 = ' '
PAK AC                   endif
PAK A*
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
     *----------------------------------------------------------------
     *
     *  FILHACCP  Fill HACCP history fields.
     *
510fac     filhaccp      begsr
     *
     *  Initialize record
     *
510fac                   clear                   hahrec
     *
     *  Move fields from POHACCP to POHHACCP
     *
510fac                   eval      hahwhse = hawhse
510fac                   eval      hahpo = hapo
510fac                   eval      hahseq = haseq
510fac                   eval      hahitem = haitem
510fac                   eval      hahest# = haest#
510fac                   eval      hahtksl = hatksl
510fac                   eval      hahprda = haprda
510fac                   eval      hahprdt = haprdt
510fac                   eval      hahrsrq = harsrq
510fac                   eval      hahrsdl = harsdl
510fac                   eval      hahttrr = hattrr
510fac                   eval      hahttmd = hattmd
510fac                   eval      hahttns = hattns
510fac                   eval      hahptrt = haptrt
510fac                   eval      hahptrm = haptrm
510fac                   eval      hahptrb = haptrb
510fac                   eval      hahptmt = haptmt
510fac                   eval      hahptmm = haptmm
510fac                   eval      hahptmb = haptmb
510fac                   eval      hahptnt = haptnt
510fac                   eval      hahptnm = haptnm
510fac                   eval      hahptnb = haptnb
510fac                   eval      hahldcn = haldcn
510fac                   eval      hahinsp = hainsp
510fac                   eval      hahedt = phhedt
510fac                   eval      haheti = phheti
     *
510fac                   endsr
417 A*
FBYaAC*----------------------------------------------------------------
FBYaAC*
FBYaAC*  PrtLog   Print the haccp log
FBYaAC*
FBYaAc     PrtLog        begsr
FBYaAC*
FBYaAc                   if        *in78 = *off
FBYaAc                   call      'HA301'
FBYaAc                   parm      ' '           $hacmd            8
FBYaAc                   parm      phwhse        $hawhse           3 0
FBYaAc                   parm      phpo          $lhapo            9
FBYaAc                   parm      ' '           $lhaitem         15
FBYaAc                   parm                    $hanew            1
FBYaAc                   if         $hanew = '1'
FBYaAc                   call      'HA300'
FBYaAc                   parm      '*PRINT'      $hacmd            8
FBYaAc                   parm      phwhse        $hawhse15        15 5
FBYaAc                   parm      phpo          $lhapo            9
FBYaAc                   parm      ' '           $lhaitem         15
FBYaAc                   parm      ' '           $levl             4
FBYaAc                   parm                    $dev             10
FBYaAc                   else
FBYaAc                   endif
FBYaAc                   else
FBYaAc                   eval      *in78 = *off
FBYaAc                   endif
FBYaAc                   endsr
416 A*----------------------------------------------------------------
416 A*
416 A*  ZZDLPU   Delete Super P/O cross-ref entries.
416 A*
416 Ac     zzdlpu        begsr
416 A*
416 Ac     keyod         setll     pospo
416 Ac                   dow       forevr = forevr
416 Ac     keyod         reade     pospo                                  79
416 Ac                   select
416 Ac                   when      *in79
416 Ac                   leave
416 A*
416 Ac                   other
416 Ac                   delete    purec
416 Ac                   endsl
416 Ac                   enddo
416 A*
710aDc**   keyod         chain     pohaccp                            77
710aMc     keyod         chain     pohaccp
510fac                   if        %found
510fac                   delete    harec
510fac                   endif
416 A*
416 Ac                   endsr
416 A*
750aA*----------------------------------------------------------------
750aA*  zzzGetStamps   Get timestamps
750aA*----------------------------------------------------------------
750aA /free
750aA   begsr zzzGetStamps;
750aA
750aA     exec sql
750aA       values (current_timestamp,
750aA               current_timestamp-current_timezone)
750aA       into :stamp, :stampUC;
750aA
750aA     if sqlstt <> sqlSuccess;
750aA       clear stamp;
750aA       clear stampUC;
750aA     endif;
750aA
750aA   endsr;
750aA /end-free
