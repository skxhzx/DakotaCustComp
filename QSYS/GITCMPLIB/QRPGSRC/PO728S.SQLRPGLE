730 A /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PO728S    Stage Export RTI - P.O.'s
     *  12 December 2019
     *  Lynn McMahon
     *
     *  This program was initially copied from po726s.
     *  leaving client custom mods at this time.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    12/12/19  LMC  7.30
     *      - Created.
     *      - real time logic for sending partial export
     *        information for each license received.
     *
740a *    06/03/20  RTR  7.40a
     *      - Added call to NetSuite Interface API.
     *
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
     *  Client Custom Revisions: Hearn Kirkwood
     *
HKW A*    10/10/12  MLB  HKW
     *      - Revised pgm to send back oldest expiration date for date
     *        sensitive items. Expiration date will go in Misc 2, positions
     *        1 - 8.
     *      - Added file, POMFR to pgm.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRY A*    08/05/13  MLB  DRY
     *      - Revised pgm to call Host export program, BFCEPO05C to send
     *        exported p/o's to Host JDEdwards system.
     *      - Added /copy mbr, C#FILE1DS to retrieve files library to
     *        pass to Host pgm, along with whse number.
DRYaA*    07/23/17  MLB  DRYa
     *      - Revised pgm to calculate quantity received into OSS-Off-
     *        site Storage and load OSS slot code into PEDMS2 in position
     *        1 - 4 and OSS Received Qty in position 5-11 w/zero decimals
     *        Per Hemant K email.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: A&D Foods
     *
ADFa *    12/16/16  RTR  ADFa
     *      - Revised to get country and method from HACCP data.
     *      - Revised to not export MOVEIN vendor ITC.
ADFb *    11/06/19  DAS  ADFb
     *      - Revised SELECT logic to prevent ITC from being written.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  74        - NRF for POHDRM
     *  75        - ERR for POHDR
     *  76        - EOF for POEXCP
     *  77        - Super P/O found.
     *  78        - EOF for PODTL
     *  79        - EOF for POSPO
     *
     *----------------------------------------------------------------
     * File Specs
     *
     fpohdr     uf   e           k disk
     fpohdrm    uf   e           k disk
     fpodtl     uf   e           k disk
     fpodtlm    uf   e           k disk
     fpoexcp    uf   e           k disk
     fpospo     uf   e           k disk
     flabelw    if   e           k disk
     fexpspoh   o  a e           k disk
     F                                     infds(file1ds)
     fexpspod   o  a e           k disk
     fexpspoe   o  a e           k disk
     fexpspol   o  a e           k disk
     fexpspolt  o  a e           k disk
     fhaccpxrf  if a e           k disk
     fhaccplog3 if a e           k disk
     flicinfo   if a e           k disk
     Flicadj    uf a e           k disk    usropn
     fexpspox   o  a e           k disk
     fpohexcp   o  a e           k disk
     fpohhdr    o  a e           k disk
     fpohhdrm   o  a e           k disk
     fpohdtl    o  a e           k disk
     fpohdtlm   o    e           k disk
     fuciinfo2  if   e           k disk
     fuciinfoexaif   e           k disk
     fitemmsc   if   e           k disk
     flumper    uf   e           k disk
HKW Afpomfr     if   e           k disk    usropn
     fporcv     uf   e           k disk
     fpohaccp   uf   e           k disk
     fpohhaccp  o  a e           k disk
     fexptrig   o    e           k disk
740aAfoptions   if   e           k disk
     *----------------------------------------------------------------
     *  Customer id
     *
PAK A /COPY QCOPYSRC,ID#packers
LINaA /COPY QCOPYSRC,ID#lincoln
HKW A /COPY QCOPYSRC,ID#hkw
DRY A /COPY QCOPYSRC,ID#dairyla
ADFaA /COPY QCOPYSRC,ID#adf
      /COPY QCOPYSRC,ID#glp
     *
     *----------------------------------------------------------------
     *  Data Formats
     *
      /copy *libl/qcopysrc,c#licinfo
      /COPY *libl/qcopysrc,C#CVTPARMS
      /COPY *libl/qcopysrc,C#BARCODE
DRYaA*
DRYaA*----------------------------------------------------------------
DRYaA*
DRYaA /COPY QCOPYSRC,podm2_dry

     *----------------------------------------------------------------
     *  Program info data structure
     *
      /Copy qcopysrc,c#pgminfds
     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D $pWhse          s              3p 0
     D $pWhse3A        s              3
     d $pLicense       s             15
     d $pCommand       s             10
     *
     *----------------------------------------------------------------
     *  Constants
     *
     d forevr          c                   const('1')
     *----------------------------------------------------------------
     *  Working variables
     *
     D batId           s             11
     D dltpohdrm       s              4    inz('*NO ')
     d ExportType      s            117a
     D forever         s               n
     D haveBatId       s               n
HKW Ad hkwexpdate      s              8  0 inz(0)
740aAd hostopts        s             20a
740aAd hostoptint      s             20a
DRY Ad hrtn            s              8
740aAd NetSuite        c                   const('NETSUITE')
     D partialpo       s               n
     D optPrtReport    s               n   inz('0')
     d RealType        s             10
     d RealStatus      s              1
     d Realststs       s               z
     d Realstsuc       s               z
     D rtnCode         s             10
     D rtnMessage      s            200
     d spo             s              2
     D stamp           s               z
     D stampUC         s               z
740aAd sysWhse         s              3s 0 inz(0)
     d today           s              8  0
     d workAdj1        s             11  0
     d workAdj2        s             11  0
     d workAisle       s              3a
     d workCode        s            117a
ADFaAd workDesc        s             30a
     d workDisp        s             12a
ADFaAd workSys         s              1a
     D workTran        s              7s 0
     D zeroUploadDate  s              8s 0
     D writeToExport   s               n
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
     D  $lwhse                19     21  0
     D  $lpo                  22     30
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D GetBatId        pr                  extpgm('GETBATID')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pStatus                      1    const
      * Output
     D   pBatId                      11
     D   pReturn                     10
     D   pMessage                   200

      /copy qcopysrc,p.getoptio

     D getRecId        pr                  extpgm('GETRECID')
     D  pWhse                         3s 0 const
     D  pFile                        10    const
     D  pRecId                       11p 0

     D getAdjCode      pr                  extpgm('GETADJCOD')
     D  pCode                         2    const
     D  pDesc                        30
     D  pSys                          1

DRY A*
DRY Ad DryExportPgm    pr                  Extpgm('BFCEPO05C')
DRY Ad* Input
DRY Ad   $hWhsen                      3  0
DRY Ad   $hbatid                     11
DRY Ad   $hflib                      10
DRY Ad* Output
DRY Ad   $hrtn                        8

      /copy *libl/qcopysrc,p.getopint
740aA* Prototype for NetSuite API Call
740aA /copy *libl/qcopysrc,p.intapins

     *----------------------------------------------------------------
     *  File info data structures
     *----------------------------------------------------------------

      /COPY qcopysrc,c#file1ds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse  - Warehouse
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    $pWhse3A
     c                   parm                    $pLicense
     c                   parm                    $pCommand

     c                   eval      $pWhse = %dec($pWhse3A: 3: 0)
     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
      /free
        haveBatId = *off;
        // Is this real time staging
        GetOptions(%editc(0:'X'):
                   '*FTP': '001': '001': ExportType);
        if ExportType <> 'R';
          return;
        endif;

        // what po/poseq am I processing
        lnseq = 1;
        chain ($pWhse: $pLicense: lnseq) licinfo;
        if not %found(licinfo);
          return;
        endif;

        // now grab the label record because we need to know what uom
        // was received
        chain (lnwhse: lnrcvlbl#) labelw;
        if not %found(labelw);
          lbutyp = 'N';
        endif;

        // Skip Transfer Po's
        if %subst(lnpo:8:2) = 'TF';
          return;
        endif;

        chain ($pwhse: lnpo) pohdr;
        if not %found(pohdr);
          return;
        endif;
        // set flag to partial export
        partialpo = *on;
        // get batch id
        if not haveBatId;
          exsr zzzGetBatId;
          if batId = ' ';
            return;
          endif;
          haveBatId = *on;
        endif;

        // Set Flag for writing PO to Export Files
        select;

          // Don't write Lincoln tfr PO to export files
          when client = lincoln and phven = 6090;
            writeToExport = *off;

          // Don't write A&D Foods MOVEIN PO from vendor ITC
          when client = AandDFoods and phmm1 = 'ITC';
            writeToExport = *off;

          other;
            writeToExport = *on;

        endsl;

        dltpohdrm = '*NO ';
        chain (phwhse: phpo) pohdrm;
        if not %found(pohdrm);
          phmm1 = ' ';
          phmm2 = ' ';
          phmm3 = ' ';
          phmm4 = ' ';
          phmm5 = ' ';
        endif;

        if writeToExport;
          exsr filpeh;
          write pehrec;
        endif;

        // Add order detail records to export detail file
        chain ($pwhse: phpo: lnposeq) podtl;
        if not %found(podtl);
          return;
        endif;
        chain (pdwhse: pdpo: pdseq: pditem) podtlm;
        if not %found(podtlm);
          pdmods = ' ';
          pdmpom = ' ';
          pdmms1 = ' ';
          pdmms2 = ' ';
HKW A     if client = Hearnkirkwood;
HKW A       pdmms2 = %replace('00000000':pdmms2:1:8);
HKW A     endif;
          pdmms3 = ' ';
          pdmms4 = ' ';
          pdmms5 = ' ';
        endif;

HKW A   select;
HKW A     when client = Hearnkirkwood;
HKW A       // Retrieve oldest expiration date for date sensitive items
HKW A       exsr zzgetexpdate;
HKW A   endsl;

        if writeToExport;
          exsr filped;
          write pedrec;
          exsr wrtpel;
        endif;

        setll (pdwhse: pdpo: pdseq: pditem) poexcp;
        dou forevr <> forevr;
          reade (pdwhse: pdpo: pdseq: pditem) poexcp;
          if %eof(poexcp);
            leave;
          endif;

          if writeToExport = *on;
            exsr filpoe;
            write poerec;
          endif;

        enddo;

         if haveBatId;
           exsr zzzEnd;
DRY A
DRY A      if client = Dairyland;
DRY A        if sqlstt = sqlSuccess;
DRY A          callp(e) DryExportPgm($pwhse:batid:f1library:hrtn);
DRY A        endif;
DRY A      endif;
DRY A
           if ExportType = 'R';
             RealType = 'PO';
             RealStatus = 'R';
             exsr zzzGetStamps;
             Realststs  = stamp;
             Realstsuc  = stampuc;
             exec sql
              insert into exptrig
              values (:$pWhse,:RealType,:batid,:RealStatus,
                      :Realststs,:Realstsuc,:Realststs,:Realstsuc);

           endif;
         endif;

      /end-free
     *
     *----------------------------------------------------------------
     *
     *          Subroutines In Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     c     *inzsr        begsr
     *
     * Get client id.
     *
     c                   call      'GETCLIENT'
     c                   parm                    client           10
     c                   parm                    clientloc        10
740aAc                   parm                    clientinit        3
740aAc                   parm                    clienthost       10
     *
HKW A*
HKW A*   Define full key for POMFR file.
HKW A*
HKW Ac     keypm         klist
HKW Ac                   kfld                    pdwhse
HKW Ac                   kfld                    pdpo
HKW Ac                   kfld                    pdseq
HKW Ac                   kfld                    pditem
     *
     *   Define partial key for PORCV file.
     *
     c     keyrcv        klist
     c                   kfld                    pdwhse
     c                   kfld                    pdpo
     c                   kfld                    pdseq
     *
     *   Define unique key for HACCPLOG file.
     *
     c     keyhcp        klist
     c                   kfld                    hxwhse
     c                   kfld                    hxpo
     c                   kfld                    hxposeq
     c                   kfld                    hxseq#
HKW A*
HKW AC                   if        client = Hearnkirkwood
HKW A*
HKW AC                   if        not %open(pomfr)
HKW AC                   open      pomfr
HKW AC                   endif
HKW A*
HKW AC                   endif
     *
     *  Convert today's date into century format.
     *
     c                   eval      $cvcmd = '*CURCMD '
     c                   call      @cvtdt
     c                   parm                    $cvtdt
     c                   eval      today = $cvd8o
740aA*
740aA*  Define partial key for OPTIONS file.
740aA*
740aAC     keyop         klist
740aAC                   kfld                    $pwhse
740aAC                   kfld                    opcode
740aA*
740aA*  Define partial key for OPTIONS file.
740aA*
740aAC     keyopSys      klist
740aAC                   kfld                    sysWhse
740aAC                   kfld                    opcode
740aA /free
740aA*  Get Host ERP from OPTIONS
740aAc                   eval      opwhse = 1
740aAc                   eval      opcode = '*HOST   '
740aAc     keyop         chain     options
740aAc                   if        not %found(options)
740aAc                   eval      hostopts = '*NONE'
740aAc                   else
740aAc                   movel     opdata        hostopts
740aAc                   endif
740aA *  Get Host ERP from OPTIONINT
740aA /free
740aA   // Get debug flag
740aA   optint.type = 'Interface   ';
740aA   optint.cat  = 'General Options     ';
740aA   optint.name = 'Host ERP System     ';
740aA   GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
740aA             optint.valn: optint.vala: optint.return);
740aA   if optint.return = '*OK';
740aA     hostoptint = optint.vala;
740aA   else;
740aA     hostoptint = '*NONE';
740aA   endif;
740aA
        // Get Option to see if overflow when no pick.
        optint.type = 'Interface   ';
        optint.cat  = 'Export POs          ';
        optint.name = 'Print Receiving Rept';
        GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
                  optint.valn: optint.vala: optint.return);
        if optint.return = '*OK'
         and optint.vala = 'Y';
          optPrtReport = *on;
        else;
          optPrtReport = *off;
        endif;
      /end-free
     *
     c                   endsr
     *----------------------------------------------------------------
     *  ConvertUCI Convert the UCI
     *----------------------------------------------------------------

     C     ConvertUCI    begsr
     C                   eval      $cbcmd = '*ALL    '
     C                   eval      $cbbar = uiuci
     c                   clear                   $barcode
     c                   clear                   $barcode2
     c                   clear                   $cvtdata
     c                   clear                   $cvtdata2
     *
     C                   call      'CVTBAR'
     C                   parm                    $cbcmd            8
     C                   parm                    $cbbar          100
     C                   parm                    $cbcod            3 0
     C                   parm                    $cbdec            1 0
     C                   parm                    $cbdsc           30
     C                   parm                    $cbpos            3 0
     C                   parm                    $cbtyp            1 0
     C                   parm                    $cbv1            11 3
     C                   parm                    $cbv2            50
     C                   parm                    $cbrtn            8
     C                   parm                    $cberm           60
     C                   parm                    $cbven           10 0
     C                   parm                    $cvtdata
     C                   parm                    $cvtdata2
     C                   parm      uiwhse        $cbwhse
     c                   eval      $barcode = $cvtdata
     c                   eval      $barcode2 = $cvtdata2
     C                   endsr
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
     c                   eval      pedpo = pdpo
     c                   eval      pedseq = pdseq
     c                   eval      peditm = pditem
     c                   eval      pedvit = pdvitm
     c                   eval      pedspc = pdspcl
     c                   eval      pedq1 = pdqor1
     c                   eval      pedq2 = pdqor2
     c                   eval      pedq3 = pdqor3
     c                   Select
     c                   when      $pCommand = 'Delete'
     C                   select
     C                   when      lbutyp = 'N'
     C                   eval      pedqr1 = lnrcvqty * -1
     C                   when      lbutyp = '1'
     C                   eval      pedqr2 = lnrcvqty * -1
     C                   when      lbutyp = '2'
     C                   eval      pedqr3 = lnrcvqty * -1
     C                   endsl
     c                   eval      pedwgt = LNTTLLBS * -1
     c                   other
     C                   select
     C                   when      lbutyp = 'N'
     C                   eval      pedqr1 = lnrcvqty
     C                   when      lbutyp = '1'
     C                   eval      pedqr2 = lnrcvqty
     C                   when      lbutyp = '2'
     C                   eval      pedqr3 = lnrcvqty
     C                   endsl
     c                   eval      pedwgt = LNTTLLBS
     c                   endsl

     C                   exsr      zzzGetStamps
     C                   eval      pedbatid = batId
     C                   eval      pedstatus = 'R'
     C                   eval      pedststs = stamp
     C                   eval      pedstsuc = stampuc
     C                   eval      pedaddts = stamp
     C                   eval      pedadduc = stampuc
     *
     *      Load Header misc. fields.
     C                   eval      pedms1 = pdmms1
     C                   eval      pedms2 = pdmms2
HKW AC                   if        client = Hearnkirkwood
HKW AC                   eval      pedms2 = %replace(%editc(hkwexpdate:'X')
HKW AC                                      :pedms2:1:8)
HKW AC                   endif
DRYaA*
DRYaAC                   if        client = Dairyland
DRYaAC                   eval      pedms2 = podm2_dry
DRYaAC                   endif
DRYaA*
     C                   eval      pedms3 = pdmms3
     C                   eval      pedms4 = pdmms4
     C                   eval      pedms5 = pdmms5
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
     c                   eval      pehpo = phpo
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
     c                   if        partialpo
     c                   eval      pehamp = 'U'
     c                   else
     c                   eval      pehamp = phampm
     c                   endif

     C                   exsr      zzzGetStamps
     C                   eval      pehbatid = batId
     C                   eval      pehstatus = 'R'
     C                   eval      pehststs = stamp
     C                   eval      pehstsuc = stampuc
     C                   eval      pehaddts = stamp
     C                   eval      pehadduc = stampuc
     *
     *      Load Header misc. fields.
     C                   eval      pehmm1 = phmm1
     C                   eval      pehmm2 = phmm2
     C                   eval      pehmm3 = phmm3
     C                   eval      pehmm4 = phmm4
     C                   eval      pehmm5 = phmm5
     *
     c                   endsr
     *----------------------------------------------------------------
     *
     *  FILPOE  Fill export receiving exception detail fields.
     *
     c     filpoe        begsr
     *
     *  Initialize record
     *
     c                   clear                   poerec
     *
     *  Move fields from exception file to po export exception file
     *
     c                   eval      poewhs = pewhse
     c                   eval      poepo = pepo
     c                   eval      poeseq = peseq
     c                   eval      poeitm = peitem
     c                   eval      poecod = pecode
     c                   eval      poeqe1 = peqex1
     c                   eval      poeqe2 = peqex2
     c                   eval      poeqe3 = peqex3
     c                   eval      poeusr = peuser
     c                   eval      poedev = pedev
     c                   eval      poeemp = peemp

     C                   exsr      zzzGetStamps
     C                   eval      poebatid = batId
     C                   eval      poestatus = 'R'
     C                   eval      poeststs = stamp
     C                   eval      poestsuc = stampuc
     C                   eval      poeaddts = stamp
     C                   eval      poeadduc = stampuc
     *
     c                   endsr
     *----------------------------------------------------------------
     *
     *  WRTPEL  Write license export fields.
     *
     c     wrtpel        begsr

     *
     *  Initialize record
     *
     c                   clear                   pelrec
     *
     *  Move fields from license file to export file.
     *
     c                   eval      pelwhs = pdwhse
     c                   eval      pelpo = pdpo
     c                   eval      pelseq = pdseq
     c                   eval      pelitm = pditem
     c                   eval      pelbatid = batid
     C                   eval      pelstatus = 'R'
     C                   eval      pelststs = stamp
     C                   eval      pelstsuc = stampuc
     C                   eval      peladdts = stamp
     C                   eval      peladduc = stampuc
     *
     *
     *
     C                   eval      pellic = $plicense

     *  Get Receiver information

     C                   eval      pelrby = LNADDUSR
     C                   eval      pelemp = LNADDEMP

     *  Special user processing for Greanleaf

     C                   if        client = Greenleaf

     C                   call      'GETUSER'
     C                   parm                    LNADDusr
     C                   parm      0             #whse             3 0
     C                   parm      0             #emp#             5 0
     C                   parm                    #fnam            15
     C                   parm                    #init             1
     C                   parm                    #lnam            20
     C                   parm                    #whdp             5
     C                   parm                    #styp             1
     C                   parm                    #shft             6
     C                   parm                    #crew             6
     C                   parm      0             #nhrs             3 1
     C                   parm                    #rtn              8

     C                   if        #rtn = '*OK'
     C                             and %subst(#lnam:18:3) <> *blanks
     C                   eval      pelrby = %subst(#lnam:18:3)
     C                   endif

     C                   endif

     *
     C                   eval      pellot = lnlot
     c                   Select
     c                   when      $pCommand = 'Delete'
     C                   select
     C                   when      lbutyp = 'N'
     C                   eval      pelqt1 = lnrcvqty * -1
     C                   when      lbutyp = '1'
     C                   eval      pelqt2 = lnrcvqty * -1
     C                   when      lbutyp = '2'
     C                   eval      pelqt3 = lnrcvqty * -1
     C                   endsl
     C                   eval      pelwgt = lnttllbs * -1
     c                   other
     C                   select
     C                   when      lbutyp = 'N'
     C                   eval      pelqt1 = lnrcvqty
     C                   when      lbutyp = '1'
     C                   eval      pelqt2 = lnrcvqty
     C                   when      lbutyp = '2'
     C                   eval      pelqt3 = lnrcvqty
     C                   endsl
     C                   eval      pelwgt = lnttllbs
     C                   endsl
     c                   select
     C                   when      client = AandDFoods
     C                   eval      pelbrd = 'NB'
     c                   other
     C                   eval      pelbrd = lnbrand
     c                   endsl
      /free
            pelexp = lnEntDate;
      /end-free

     *
     *  Get COOL info from HACCP files
     C                   eval      peloco = *blanks
     C                   eval      pelost = *blanks
     C                   eval      pelocy = *blanks
     *
     C     porlic        setll     hxrec
     C     porlic        reade     hxrec
     *
     C                   dow       not %eof()
     C     keyhcp        chain     hlrec
     C                   if        %found(haccplog3)
     C                   select
     C                   when      hlseq# = 1
     C                   eval      peloco = hldata
     C                   when      hlseq# = 2
     C                   eval      pelost = hldata
     C                   when      hlseq# = 3
     C                   eval      pelocy = hldata
     C                   endsl
     c                   endif
     C     porlic        reade     hxrec
     c                   enddo
ADFaA
ADFaA /free
ADFaA   workDesc = *blanks;
ADFaA   select;
ADFaA     when client = AandDFoods;
ADFaA     // get country from haccplog
ADFaA     exec sql select max(hvdesc) into :workDesc
ADFaA                from haccplog, haccpv
ADFaA               where hlwhse = hvwhse
ADFaA                 and hlseq# = hvseq#
ADFaA                 and hllevl = hvlevl
ADFaA                 and hlvsq# = hvvsq#
ADFaA                 and hlpo = :pelpo
ADFaA                 and hlposeq = :pelseq
ADFaA                 and hlpcmd = '*PORCV'
ADFaA                 and hlseq# = 6;
ADFaA     if sqlstt <> sqlsuccess;
ADFaA       peloco = *blanks;
ADFaA     else;
ADFaA       peloco = workDesc;
ADFaA     endif;
ADFaA     // get method from haccplog
ADFaA     exec sql select max(hvdesc) into :workDesc
ADFaA                from haccplog, haccpv
ADFaA               where hlwhse = hvwhse
ADFaA                 and hlseq# = hvseq#
ADFaA                 and hllevl = hvlevl
ADFaA                 and hlvsq# = hvvsq#
ADFaA                 and hlpo = :pelpo
ADFaA                 and hlposeq = :pelseq
ADFaA                 and hlpcmd = '*PORCV'
ADFaA                 and hlseq# = 7;
ADFaA     if sqlstt <> sqlsuccess;
ADFaA       pelost = *blanks;
ADFaA     else;
ADFaA       pelost = workDesc;
ADFaA     endif;
ADFaA   endsl;
ADFaA /end-free
     *
     *  Write license record
     c                   write     pelrec

     *  Write EXPSPOLT records
     c                   exsr      wrtpelUCI
     *
     *  Check license location, if OSS write putaway transfer to LICADJ
     *
      /free
          exec sql select laaisl,ladisp,laloc,larlvl,lahand,lawhdp
                    into :workAisle,:workDisp,:adjloc,:adjrlvl,:adjhand,:adjwhdp
                     from licactive
                    where lalcns = :pellic;
          if sqlstt = sqlsuccess
           and workAisle = 'OSS';

            // If file not open, open it.
            if not %open(licadj);
              open LicAdj;
            endif;

            // Get unique adjustment record id.
            GetRecId(pelwhs: 'LICADJ': workadj1);
          //GetRecId(pelwhs: 'LICADJ': workadj2);

            // Get transfer adj code default if none provided.
          //GetOptions(%editc(pelwhs:'X'): '*ADJUST': '003': '002': workCode);
            workCode = 'TL';
            // Get adjustment code description/system.
            GetAdjCode(workCode: workDesc: workSys);

            adjwhs = pelwhs;
            adjnbr = %char(workAdj1);
            adjparent = *blank;
            adjcode = workcode;
            adjcsys = workSys;
            adjitem = pelitm;
            adjaqty1 = -1 * pelqt1;
            adjaqty2 = -1 * pelqt2;
            adjaqty3 = -1 * pelqt3;
            adjcqta = -1 * pelwgt;
            adjdisp = *blank;
            adjaisl = workAisle;
            adjstat = 'A';
            adjmemo = %char(workAdj2);
            adjlcns = pellic;
            adjaddts = %timestamp();
            adjadduc = %timestamp();
            adjaddcpgm = #pgm;
            adjaddjpgm = #pgm;
            adjaddemp = *zero;
            adjaddcusr = #curruser;
            adjaddjusr = #user;
            adjaddjob = #job;
            adjaddnbr = #jobnbr;
            adjexpflag = *blank;
            adjdrislot = *blank;
            adjdrilic = *blank;

            adjdisp = workDisp;
            adjaqty1 = pelqt1;
            adjaqty2 = pelqt2;
            adjaqty3 = pelqt3;
            adjcqta = pelwgt;
            write adjrec;

          endif;
ADFaA
ADFaA     // Find if putaway or transferred and reset liclog export
ADFaA     // this will resend adjustment location record
ADFaA     exec sql select max(lltrn#) into :workTran
ADFaA                from liclog
ADFaA               where lllcns = :pellic
ADFaA                 and (llaction='PUT' or llaction='TFR')
ADFaA                 and llcode <>'U';
ADFaA     if sqlstt <> sqlsuccess;
ADFaA       workTran = 0;
ADFaA     else;
ADFaA       exec sql update liclog
ADFaA                   set llexpflag = ' '
ADFaA                 where lllcns = :pellic
ADFaA                   and lltrn# = :workTran
ADFaA                   and (llaction='PUT' or llaction='TFR')
ADFaA                   and llcode <>'U';
ADFaA     endif;
ADFaA
ADFaA /end-free
     *
     c                   endsr
     *
     *----------------------------------------------------------------
     *
     *  WRTPELUCI  Write license export fields - UCI
     *
     c     wrtpelUCI     begsr

      /free

        // Initialize LT fields

        clear peltrec;

        peltwhs = pelwhs;
        peltpo = pelpo;
        peltseq = pelseq;
        peltitm = pelitm;
        peltbatid = pelbatid;
        peltstatus = pelstatus;
        peltststs = pelststs;
        peltstsuc = pelstsuc;
        peltaddts = peladdts;
        peltadduc = peladduc;

        pelthstlot = pellic;
        peltlcns = pellic;
        peltqty1 = pelqt1;
        peltqty2 = pelqt2;
        peltqty3 = pelqt3;
        peltwgt = pelwgt;
        peltlbl = lnrcvlbl#;
        pelttrn = lnrcvtrn#;
        peltlot = pellot;

        // Note, the following fields are not named correctly in
        // EXPSPOLT. They have same names as in EXPSPOL.
        // Thus, we comment them out here.
        //peltbrd = pelbrd;
        //peltoco = peloco;
        //peltost = pelost;
        //peltocy = pelocy;
        //peltrby = pelrby;
        //peltemp = pelemp;

        if lnentdate > 0;
          monitor;
            peltdate = %dec(%char(%date(lnentdate:*iso):*ymd0):6:0);
            peltdatenm = %subst(lnenttype: 1: 4);
            peltdatecd = '';
          on-error;
          endmon;
        endif;

        // Get tracking level

        chain (pdwhse: pditem) itemmsc;
        if not %found(itemmsc);
          imltrk = '';
        endif;

        // For non-UCI tracking, write out license info
        // Values set in calling routing WRTPEL.

        if imltrk <> 'U';
          write peltrec;
          leavesr;
        endif;

        // Otherwise, write UCI recs

        setll (pdwhse :porlic) uciinfo2;

        dow forevr = forevr;

          reade (pdwhse: porlic) uciinfo2;
          if %eof(uciinfo2);
            leave;
          endif;

          // now get the extension file for the rest of the data

          chain (UIADDTS: UIUCILCNS: UILCNS) uciinfoexa;
          if not %found(uciinfoexa);
            clear UIAREC;
          endif;

          select;
            when uiserial <> ' ';
              PELTHSTLOT = uiserial;
            when uialot <> ' ';
              PELTHSTLOT = uialot;
            when %subst(uiuci:1:3) = '99I';
              PELTHSTLOT =uiuci;
            other;
              //pellic = uilcns;
              pelthstlot = uilcns;
          endsl;

          //pellot = uialot;
          peltlot = uialot;

          select;
            when uiautyp = 'N';
              //pelqt1 = 1;
              peltqty1 = 1;
            when uiautyp = '1';
              //pelqt2 = 1;
              peltqty2 = 1;
            when uiautyp = '2';
              //pelqt3 = 1;
              peltqty3 = 1;
            other;
              //pelqt1 = 1;
              peltqty1 = 1;
          endsl;

          //pelwgt = uiwgtlbs;
          peltwgt = uiwgtlbs;

          exsr ConvertUCI;
          Select;
            when $bcProdDSent;
              peltdate = $bcProdD;
              peltdatecd = '11';
              peltdatenm = 'PROD';
            when $bcPackDSent;
              peltdate = $bcPackD;
              peltdatecd = '13';
              peltdatenm = 'PACK';
            when $bcSlByDSent;
              peltdate = $bcSlByD;
              peltdatecd = '15';
              peltdatenm = 'BEST';
            when $bcExpDSent;
              peltdate = $bcExpD;
              peltdatecd = '17';
              peltdatenm = 'EXP';
          Endsl;

          peltlcns = uilcns;
          peltuci = uiuci;
          peltuciseq = uiseq;
          peltgtin = %char(uiagtin);
          peltserial = uiserial;
          pelttrn = uiseltrn#;

          write peltrec;

        enddo;

      /end-free
     c                   endsr
DRYaA*
HKW A*----------------------------------------------------------------
HKW A*
HKW A*  ZZGETEXPDATE   Retrieve oldest expiration date for po detail item
HKW A*
HKW Ac     zzgetexpdate  begsr
HKW A*
HKW AC                   eval      hkwexpdate = 0
HKW AC     keypm         setll     pomfr
HKW AC                   dow       forevr = forevr
HKW AC     keypm         reade     pomfr
HKW AC                   select
HKW AC                   when      %eof(pomfr)
HKW AC                   leave
HKW AC                   when      hkwexpdate = 0
HKW AC                   eval      hkwexpdate = pmexpd
HKW A*           Find oldest expiration date to send to Host.
HKW AC                   when      pmexpd < hkwexpdate
HKW AC                   eval      hkwexpdate = pmexpd
HKW AC                   endsl
HKW A*
HKW AC                   enddo
HKW A*
HKW Ac                   endsr

     *----------------------------------------------------------------
     *  zzzGetBatId    Get batch id
     *----------------------------------------------------------------

     c     zzzGetBatId   begsr
      /free

        monitor;
          GetBatId($pWhse: 'EXPPO': 'W':
                   batId: rtnCode: rtnMessage);
        on-error;
          clear batId;
          clear rtnCode;
          clear rtnMessage;
        endmon;

      /end-free
     c                   endsr

     *----------------------------------------------------------------
     *  zzzGetStamps   Get timestamps
     *----------------------------------------------------------------

     c     zzzGetStamps  begsr
      /free

        exec sql
          values (current_timestamp,
                  current_timestamp-current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

      /end-free
     c                   endsr

     *----------------------------------------------------------------
     *  zzzEnd     End processing
     *----------------------------------------------------------------

     c     zzzEnd        begsr
      /free

        exec sql
          update stgbatch
          set sbstatus = 'R',
              sbtext   = ' ',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :batId;

        if sqlstt <> sqlSuccess;
        endif;

740aA   if (hostopts = NetSuite
740aA    or hostoptint = NetSuite
740aA    or clienthost = NetSuite)
740aA    and BatID <> *blanks;
740aA     ApiNS.Whse = %editc($pwhse:'X');
740aA     ApiNS.Batch = BatId;
740aA     ApiNS.Type = 'EXPPO     ';
740aA     IntApiNS(ApiNS.Whse: ApiNS.Batch: ApiNS.Type:
740aA              ApiNS.Ret: ApiNS.Msg);
740aA     if ApiNS.Ret <> '*OK';
740aA     endif;
740aA   endif;

      /end-free
     c                   endsr
