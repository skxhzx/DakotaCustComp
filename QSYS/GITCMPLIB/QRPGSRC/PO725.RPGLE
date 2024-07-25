     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PO725     Export closed receiving P.O.'s - Post
     *  14 November, 1994
     *  Dave Sommerville
     *  Hemant Kapadia
     *
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
510aA*    11/14/06  RH   5.10a
     *      - Enh: Convert to ILE
     *      - Enh: Write export date/time to PORCV file.
510bA*    11/20/06  RAH   5.10b
     *      - Enh: Add POHACCP and POHHACCP.
510cA*    01/08/07  RH    5.10c
     *      - Enh: Recompile POHHACCP file key changed.
640aA*    05/15/12  LMC   6.40a
     *      - Enh: Added logic to Call HA710 which updates the HACCP
     *             LOG file with export information.
     *             MAKE SURE YOU TAKE THE HA710 PROGRAM TO CLIENT
     *----------------------------------------------------------------
     * Indicators
     *
417 A*  76        - EOF for POEXCP
218 M*  78        - EOF for POHDR
218 M*  79        - EOF for PODTL
     *
     *----------------------------------------------------------------
     * File Specs
     *
218 MFpohdr     up   e           k disk
218 MFpodtl     uf   e           k disk
417 AFpoexcp    uf   e           k disk
401 D*ABEL5  IF  E           K        DISK
416 MFpospo     uf   e           k disk
     Fexppoh    o  a e           k disk
     Fexppod    o  a e           k disk
417 AFexpfpoe   o  a e           k disk
417 AFpohexcp   o  a e           k disk
218 AFpohhdr    o  a e           k disk
218 AFpohdtl    o  a e           k disk
416bAFLumper    uf   e           k disk
510aAFPorcv     uf   e           k disk
510bAFpohaccp   uf   e           k disk
510bAFpohhaccp  o  a e           k disk
401 D*                                             PHWHSEL1
401 D*                                             PHPO  L1
401 D*           DS
401 D*                                       1   9 PHPO
401 D*                                       8   9 PHPOTF
     *----------------------------------------------------------------
     *  Constants
     *
     D forevr          c                   const('1')
     *----------------------------------------------------------------
     *  Variables
     D spo             s              2
     D today           s              8  0
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
640aA*----------------------------------------------------------------
640aA*  Called program parameters
640aA*
640aAD $lparm          ds
640aAD  $lcmd                  1      8
640aAD  $lprg                  9     18
640aAD  $luky                 19     68
640aAD  $lrtn                 69     76
640aAD  $lerm                 77    136
640aAD  $lmsg                 77     80
640aA*
640aA*   Redefine key
640aAD  $lwhse                19     21  0
640aAD  $lpo                  22     30
     *----------------------------------------------------------------
     *  Level breaks
     *
401 DIphrec
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
     *  Skip order if open transactions exist.
     *
401 D*          OPNFLG    CABEQ*ON       BOTTOM
     *
401 A*  Skip order if status is not '3' ready for export.
401 A*
401 AC     phstat        cabne     '3'           bottom
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
416 A*
416 AC                   movel     phpo          spo
416 AC     keyod         setll     pospo                                  79
416 AC                   select
416 A*    Super P/O found. Remove entries from cross-ref file.
416 AC                   when      *in79  or
416aD*          SPO       ANDEQ'SP'
416aMC                             spo = 'SP'
416 AC                   exsr      zzdlpu
416 A*
416 A*    Process all other P/O's.
416 AC                   other
     C                   exsr      filpeh
     C                   write     pehrec
218 A*
218 A*  Add order header record to history header file.
218 A*
218 AC                   exsr      filphh
218 AC                   write     phhrec
416bAC     lmkey         chain     lumper                             79
416bAC                   if        not *in79
416bAC                   eval      lmhedt = today
416bAC                   time                    lmheti
416bAC                   update    lmrec
416bAC                   endif
416 AC                   endsl
510aA*  Update PORCV records with export date/time.
510a C     keyod         setll     porcv
510a C                   dou       forevr <> forevr
510a C     keyod         reade     porcv                                  78
510a C                   if        *in78
510a C                   leave
510a C                   endif
510a C                   if        poredt = 0
510aAC                   eval      poredt = phhedt
510aAC                   eval      poreti = phheti
510aAC                   update    porrec
510a C                   endif
510a C                   iter
510a C                   enddo
     *
     *  Add order detail records to export detail file.
     *
218 MC     keyod         setll     podtl
     C                   dou       forevr <> forevr
218 MC     keyod         reade     podtl                                  78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   exsr      filped
     C                   write     pedrec
218 A*  Add order detail records to HISTORY detail file.
218 AC                   exsr      filphd
218 AC                   write     phdrec
218 A*  Delete order detail records from PODTL file.
218 AC                   delete    pdrec
     C                   enddo
417 A*
417 A*  Add exception detail records to history exception file.
417 A*
417 AC     keyod         setll     poexcp
417 AC                   dou       forevr <> forevr
417 AC     keyod         reade     poexcp                                 76
417 AC                   select
417 AC                   when      *in76
417 AC                   leave
417 A*
417 AC                   other
417 A*
417 AC                   exsr      filphe
417 AC                   write     pherec
417 A*
417 A*  Add exception detail records to export exceptions file.
417 AC                   exsr      filpoe
417 AC                   write     poerec
417 A*
417 A*  Delete exception detail records from POEXCP file.
417 AC                   delete    perec
417 A*
417 AC                   endsl
     *
417 AC                   enddo
417 A*
     *  Create HACCP history record and delete original.
510bac     keyod         setll     pohaccp
510bac     keyod         reade     pohaccp
510bac                   dow       not %eof
     *
510bac                   exsr      filhaccp
510bac                   write     hahrec
510bac                   delete    harec
     *
510bac     keyod         reade     pohaccp
510bac                   enddo
640aA*
640aA*  Call HA710 to update new haccp log file with export info.
640aAc                   eval      $lcmd = '*EXPORT'
640aAc                   eval      $lwhse = phwhse
640aAc                   eval      $lpo   = phpo
640aAc                   call      'HA710'
640aAc                   parm                    $lparm
     *
     *
     *
218 A*  Delete order header records from POHDR file.
218 AC                   delete    phrec
     *
218 D*  Update  header record with upload date and time.
218 D*
218 D*                    Z-ADDTODAY     PHHUDT
218 D*                    TIME           PHHUTI
218 D*                    UPDATPHHREC
     *
     C     bottom        tag
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
218 M*   Define partial key for PODTL file.
     *
     C     keyod         klist
     C                   kfld                    phwhse
     C                   kfld                    phpo
416bA*
416bA*   Define key for Lumper file.
416bA*
416bAC     lmkey         klist
416bAC                   kfld                    phwhse
416bAC                   kfld                    phpo
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
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILPED  Fill export detail fields.
     *
     C     filped        begsr
     *
     *  Initialize record
     *
     C                   clear                   pedrec
     *
     *  Move fields from order file to export file.
     *
     C                   eval      pedwhs = pdwhse
     C                   eval      pedpo = pdpo
     C                   eval      pedseq = pdseq
     C                   eval      peditm = pditem
     C                   eval      pedvit = pdvitm
     C                   eval      pedspc = pdspcl
     C                   eval      pedq1 = pdqor1
     C                   eval      pedq2 = pdqor2
     C                   eval      pedq3 = pdqor3
     C                   eval      pedqr1 = pdqrc1
     C                   eval      pedqr2 = pdqrc2
     C                   eval      pedqr3 = pdqrc3
221 AC                   eval      pedwgt = pddwgt
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILPEH   Fill export header fields.
     *
     C     filpeh        begsr
     *
     *  Initialize record
     *
     C                   clear                   pehrec
     *
     *  Move fields from order file to export file.
     *
     C                   eval      pehwhs = phwhse
     C                   eval      pehpo = phpo
     C                   eval      pehven = phven
     C                   eval      pehvnm = phvnam
     C                   eval      pehad1 = phvad1
     C                   eval      pehad2 = phvad2
     C                   eval      pehcty = phvcty
     C                   eval      pehst = phvst
     C                   eval      pehzp1 = phvzp1
     C                   eval      pehdte = phdate
     C                   eval      pehtim = phtime
     C                   eval      pehamp = phampm
     *
     C                   endsr
218 A*----------------------------------------------------------------
218 A*
218 A*  FILPHD  Fill history detail fields.
218 A*
218 AC     filphd        begsr
218 A*
218 A*  Initialize record
218 A*
218 AC                   clear                   pedrec
218 A*
218 A*  Move fields from order file to po history detail file.
218 A*
218 AC                   eval      phdwhs = pdwhse
218 AC                   eval      phdpo = pdpo
218 AC                   eval      phdseq = pdseq
218 AC                   eval      phditm = pditem
218 AC                   eval      phdvit = pdvitm
218 AC                   eval      phdspc = pdspcl
218 AC                   eval      phdqo1 = pdqor1
218 AC                   eval      phdqo2 = pdqor2
218 AC                   eval      phdqo3 = pdqor3
218 AC                   eval      phdqr1 = pdqrc1
218 AC                   eval      phdqr2 = pdqrc2
218 AC                   eval      phdqr3 = pdqrc3
218 AC                   eval      phdwgt = pddwgt
218 AC                   eval      phdedt = phhedt
218 AC                   eval      phdeti = phheti
218 A*
218 AC                   endsr
417 A*
417 A*----------------------------------------------------------------
417 A*
417 A*  FILPHE  Fill history receiving exception detail file.
417 A*
417 AC     filphe        begsr
417 A*
417 A*  Initialize record
417 A*
417 AC                   clear                   pherec
417 A*
417 A*  Move fields from exception file to po history exception file
417 A*
417 AC                   eval      phewhs = pewhse
417 AC                   eval      phepo = pepo
417 AC                   eval      pheseq = peseq
417 AC                   eval      pheitm = peitem
417 AC                   eval      phecod = pecode
417 AC                   eval      pheqy1 = peqex1
417 AC                   eval      pheqy2 = peqex2
417 AC                   eval      pheqy3 = peqex3
417 AC                   eval      pheusr = peuser
417 AC                   eval      phedev = pedev
417 AC                   eval      pheemp = peemp
417 A*
417 AC                   eval      pheedt = phhedt
417 AC                   eval      pheeti = phheti
417 A*
417 AC                   endsr
417 A*
218 A*----------------------------------------------------------------
218 A*
218 A*  FILPHH   Fill history header fields.
218 A*
218 AC     filphh        begsr
218 A*
218 A*  Initialize record
218 A*
218 AC                   clear                   phhrec
218 A*
218 A*  Move fields from PO Header file to PO Header history file.
218 A*
218 AC                   eval      phhwhs = phwhse
218 AC                   eval      phhpo = phpo
218 AC                   eval      phhven = phven
218 AC                   eval      phhvna = phvnam
218 AC                   eval      phhva1 = phvad1
218 AC                   eval      phhva2 = phvad2
218 AC                   eval      phhvct = phvcty
218 AC                   eval      phhvst = phvst
218 AC                   eval      phhvzp = phvzp1
218 AC                   eval      phhdte = phdate
218 AC                   eval      phhtim = phtime
218 AC                   eval      phhamp = phampm
218 AC                   eval      phhudt = phudte
218 AC                   eval      phhuti = phutim
218 AC                   eval      phhedt = today
218 AC                   time                    phheti
218 A*
218 AC                   endsr
417 A*
417 A*----------------------------------------------------------------
417 A*
417 A*  FILPOE  Fill export receiving exception detail fields.
417 A*
417 AC     filpoe        begsr
417 A*
417 A*  Initialize record
417 A*
417 AC                   clear                   poerec
417 A*
417 A*  Move fields from exception file to po export exception file
417 A*
417 AC                   eval      poewhs = pewhse
417 AC                   eval      poepo = pepo
417 AC                   eval      poeseq = peseq
417 AC                   eval      poeitm = peitem
417 AC                   eval      poecod = pecode
417 AC                   eval      poeqe1 = peqex1
417 AC                   eval      poeqe2 = peqex2
417 AC                   eval      poeqe3 = peqex3
417 AC                   eval      poeusr = peuser
417 AC                   eval      poedev = pedev
417 AC                   eval      poeemp = peemp
417 A*
417 AC                   endsr
     *----------------------------------------------------------------
     *
     *  FILHACCP  Fill HACCP history fields.
     *
510bac     filhaccp      begsr
     *
     *  Initialize record
     *
510bac                   clear                   hahrec
     *
     *  Move fields from POHACCP to POHHACCP
     *
510bac                   eval      HAHWHSE = HAWHSE
510bac                   eval      HAHPO = HAPO
510bac                   eval      HAHSEQ = HASEQ
510bac                   eval      HAHITEM = HAITEM
510bac                   eval      HAHEST# = HAEST#
510bac                   eval      HAHTKSL = HATKSL
510bac                   eval      HAHPRDA = HAPRDA
510bac                   eval      HAHPRDT = HAPRDT
510bac                   eval      HAHRSRQ = HARSRQ
510bac                   eval      HAHRSDL = HARSDL
510bac                   eval      HAHTTRR = HATTRR
510bac                   eval      HAHTTMD = HATTMD
510bac                   eval      HAHTTNS = HATTNS
510bac                   eval      HAHPTRT = HAPTRT
510bac                   eval      HAHPTRM = HAPTRM
510bac                   eval      HAHPTRB = HAPTRB
510bac                   eval      HAHPTMT = HAPTMT
510bac                   eval      HAHPTMM = HAPTMM
510bac                   eval      HAHPTMB = HAPTMB
510bac                   eval      HAHPTNT = HAPTNT
510bac                   eval      HAHPTNM = HAPTNM
510bac                   eval      HAHPTNB = HAPTNB
510bac                   eval      HAHLDCN = HALDCN
510bac                   eval      HAHINSP = HAINSP
510bac                   eval      hahedt = phhedt
510bac                   eval      haheti = phheti
     *
510bac                   endsr
     *
     *----------------------------------------------------------------
416 A*
416 A*  ZZDLPU   Delete Super P/O cross-ref entries.
416 A*
416 AC     zzdlpu        begsr
416 A*
416 AC     keyod         setll     pospo
416 AC                   dow       forevr = forevr
416 AC     keyod         reade     pospo                                  79
416 AC                   select
416 AC                   when      *in79
416 AC                   leave
416 A*
416 AC                   other
416 AC                   delete    purec
416 AC                   endsl
416 AC                   enddo
416 A*
510bac     keyod         chain     pohaccp                            77
510bac                   if        %found
510bac                   delete    harec
510bac                   endif
416 A*
416 AC                   endsr
