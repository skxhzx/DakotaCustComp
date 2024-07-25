640aA /copy qcopysrc,hspecs
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
     *
640aA*    01/21/11  DAS  640a
     *      - IT726S created.
     *      - This does not use OPNQRYF.
     *      - Revised to use staging files EXPSPOH, EXPSPOD, EXPSPOE.
     *      - Packers code stripped out.
     *
640bA*    02/24/11  DAS  640b
     *      - Changed batch type from EXPADJUST to EXPPO.
640cA*    10/10/12  MLB  6.40c
     *      - Added added PEDMS1 thru PEDMS5 fields to EXPSPOD.
     *      - Fields were added for HearnKirkwood. Client needed data
     *        sent in one of the Misc. fields sent back to the Host.
640dA*    10/10/12  MLB  6.40d
     *      - Added added PEHMM1 thru PEHMM5 fields to EXPSPOH.
640eA*    05/15/12  LMC   6.40e
     *      - Enh: Added logic to Call HA710 which updates the HACCP
     *             LOG file with export information.
     *             MAKE SURE YOU TAKE THE HA710 PROGRAM TO CLIENT
     *
650 A*    08/05/13  MLB  6.50
     *      - Enh: Added INFDS to EXPSPOH.
650aA*    02/19/13  RTR   6.50a
     *      - Enh: Revisions to handle partially received PO export
     *
700a *    09/30/16  RTR   7.00a
     *      - Enh: Added PO License export file EXPSPOL
700b *    12/16/16  RTR   7.00b
     *      - Enh: Added Expiration Date to EXPSPOL.
700c *    04/20/17  RTR   7.00c
     *      - Enh: Added Transfers to LICADJ for OSS receipts.
710a *    09/07/17  RTR   7.10a
     *      - Fix: Per Roxanne, Super PO should be left open and not
     *        deleted.
720a *    10/14/18  RTR   7.20a
     *      - Adding extension file EXPSPOX and HACCP fields. Populate
     *        in customer specific mods.
730a *    02/05/19  RTR   7.30a
     *      - Enh: Adding printing of Receiving Report based on
     *        OPTIONINT setting.
730b *    07/23/19  RTR   7.30b
     *      - Enh: Adding EXPSPOLT file for extended license/lot/UCI
     *        receipt information.
730c *    08/21/19  DAS   7.30c
     *      - Enh: Added EXPSPOLT/PELTWGT field.
730d *    08/21/19  LMC/DAS   7.30d
     *      - Enh: When loading PELTDATE it was only looking for
     *        Pack date. Added Prod, Sell By and Exp Dates. If more
     *        than 1 date is in barcode, we will look for Prod, Pack,
     *        Sell By, then Exp. Also, added setting of PELTDATECD.
730e *    10/03/19  LMC   7.30e
     *      - Enh: Adding EXPTRIG for Real Time Export.
730f *    11/06/19  DAS  7.30f
     *      - Simplified logic for not writing PO to export files.
     *      - Revised to always call wrtpel
     *      - Revised wrtpel to not write to EXPSPOLT.
     *      - Revised wrtpel to call wrtpelUCI.
     *      - Revised wrtpelUCI to only write to EXPSPOLT file.
     *      - Fixed wrtpel to work with breakdowns.
     *      - Fixed wrtpel to set weight correctly.
     *      - Revised wrtpel to populate pelrby and pelemp.
     *      - Moved special Greenleaf code for pelrby/pelemp into
     *        wrtpel routine.
     *      - Removed unnecessary code from wrtpelUCI for clarity.
730g *    12/18/19  LMC   7.30g
     *      - Enh: Change RealType to POF for final export.
740a *    06/12/20  RTR   7.40a
     *      - Fix: If warehouse is somehow zero, set to 1.
740b *    10/15/20  RTR   7.40b
     *      - Enh: Added host check, do not create PEL recs for
     *        NECS entree customers.
740c *    06/03/20  RTR  7.40c
     *      - Added call to NetSuite Interface API.
750  *    07/07/21  KDE  7.50
     *      - Change to send partial PO
     *
750aA*    07/22/21  TDC  7.50a
     *      - Correct initialize of quantity fields
     *
750bA*    10/28/21  MLB  7.50b
     *      - DockVue: Added update of POSTATUS table when PO is exported
     *        to the Host.
     *
760aA*    06/01/22  LMC  7.60a
     *      - Clients using host software FRESHBYTE need to have the
     *        lot number send in the host lot code field PELTHSTLOT
     *
760bA*    10/19/22  DAS  7.60b
     *      - Clients using host software FRESHBYTE need to have the
     *        Received qty converted to the smallest Received UOM
     *        when multiple UOM's were Received. Example: If Cases
     *        and Eaches are Received, convert Cases into Eaches.
     *      - Added qcopysrc/hostsystem
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
     *  Client Custom Revisions: Earl's Organic
     *
EOPa *    10/10/18  RTR  EOPa
     *      - Revised to send HACCP fields in EXPSPOX.
EOPb *    10/28/18  RTR  EOPb
     *      - Add to COTa automated printing of recv and PCM reports.
EOPc *    02/28/19  RTR  EOPc
     *      - Fix for multiple HACCP question versions.
EOPd *    11/23/20  RTR  EOPd
     *      - Fix for HACCP responses from green screen receiving.
     *----------------------------------------------------------------
     *  Client Custom Revisions: A&D Foods
     *
ADFa *    12/16/16  RTR  ADFa
     *      - Revised to get country and method from HACCP data.
     *      - Revised to not export MOVEIN vendor ITC.
ADFb *    11/06/19  DAS  ADFb
     *      - Revised SELECT logic to prevent ITC from being written.
ADFc *    12/13/19  LMC  ADFc
     *      - Brand field being loaded with 'NB' was supposed to be
     *        only for A&D.
ADFd *    05/07/21  RTR  ADFd
     *      - Including fix for exp date in EXPSPOL/PELEXP.
ADFe *    05/14/21  RTR  ADFe
     *      - Fix for license weight division, was removed by 730f mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cotati
     *
COTaA*    06/14/18  LMC  COTa
     *      - Add automated printing of receiving and PCM reports.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greco & Sons
GRCaA*    07/10/18  RH   GRCa
     *      - Add to COTa automated printing of recv and PCM reports
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Seashore Fruit & Produce
     *
SFP A*    02/24/23  MLB  SFP
     *      - Revised pgm bypass exporting purchase orders when
     *        vendor number = 37. This p/o is to be used for item
     *        repacks.
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
500 Mfpohdr     uf   e           k disk
510 Afpohdrm    uf   e           k disk
218 Mfpodtl     uf   e           k disk
520aAfpodtlm    uf   e           k disk
417 Afpoexcp    uf   e           k disk
416 Mfpospo     uf   e           k disk
DRYaAflabel     if   e           k disk
640aDf*xpfpoh   o  a e           k disk
640aDf*xpfpod   o  a e           k disk
640aDf*xpfpoe   o  a e           k disk
640aMfexpspoh   o  a e           k disk
650 AF                                     infds(file1ds)
640aMfexpspod   o  a e           k disk
640aMfexpspoe   o  a e           k disk
700aAfexpspol   o  a e           k disk
730bAfexpspolt  o  a e           k disk
700aAfhaccpxrf  if a e           k disk
700aAfhaccplog3 if a e           k disk
700aAflicinfo   if a e           k disk
700 AFlicadj    uf a e           k disk    usropn
720aAfexpspox   o  a e           k disk
417 Afpohexcp   o  a e           k disk
218 Afpohhdr    o  a e           k disk
510 Afpohhdrm   o  a e           k disk
218 Afpohdtl    o  a e           k disk
520aAfpohdtlm   o    e           k disk
730bAfuciinfo2  if   e           k disk
730bAfuciinfoexaif   e           k disk
730bAfitemmsc   if   e           k disk
416bAflumper    uf   e           k disk
HKW Afpomfr     if   e           k disk    usropn
510eAfporcv     uf   e           k disk
510fAfpohaccp   uf   e           k disk
510fAfpohhaccp  o  a e           k disk
COTaAfpiruser   if   e           k disk
COTaAfreports   if   e           k disk
760bAfpiritem   if   e           k disk
730eAfexptrig   o    e           k disk
510cA*----------------------------------------------------------------
510cA*  Customer id
510cA*
760bA /COPY qcopysrc,hostsystem
PAK A /COPY QCOPYSRC,ID#packers
LINaA /COPY QCOPYSRC,ID#lincoln
HKW A /COPY QCOPYSRC,ID#hkw
DRY A /COPY QCOPYSRC,ID#dairyla
EOPaA /copy qcopysrc,id#eop
COTaA /COPY QCOPYSRC,ID#cot
GRCaA /COPY QCOPYSRC,ID#grc
ADFaA /COPY QCOPYSRC,ID#adf
730bA /COPY QCOPYSRC,ID#glp
SFP A /COPY QCOPYSRC,ID#sfp
700aA*
700aA*----------------------------------------------------------------
700aA*  Data Formats
700aA*
700aA /copy *libl/qcopysrc,c#licinfo
730bA /COPY *libl/qcopysrc,C#CVTPARMS
730bA /COPY *libl/qcopysrc,C#BARCODE
DRYaA*
DRYaA*----------------------------------------------------------------
DRYaA*
DRYaA /COPY QCOPYSRC,podm2_dry
640aA
650aA*----------------------------------------------------------------
650aA*  Program info data structure
650aA*
650aA /Copy qcopysrc,c#pgminfds
640aA*----------------------------------------------------------------
640aA*  Parameters
640aA*----------------------------------------------------------------
640aA
640aAD $pWhse          s              3p 0
640aAD $pWhse3A        s              3
510cA*
     *----------------------------------------------------------------
     *  Constants
     *
     d forevr          c                   const('1')
760bDD*freshbyte       c                   const('FRESHBYTE')
510bA*----------------------------------------------------------------
510bA*  Working variables
510bA*
640aAD batId           s             11
520 AD dltpohdrm       s              4    inz('*NO ')
730eAd ExportType      s            117a
640aAD forever         s               n
640aAD haveBatId       s               n
HKW Ad hkwexpdate      s              8  0 inz(0)
740cAd hostopts        s             20a
740cAd hostoptint      s             20a
DRY Ad hrtn            s              8
750bAD nostamp         s               z     inz
760bDd*NetSuite        c                   const('NETSUITE')
650aAD partialpo       s               n
740bAd optHostSys      s             20a
720aAd pcmAns01        s             30a
720aAd pcmAns02        s             30a
720aAd pcmAns03        s             30a
720aAd pcmAns04        s             30a
720aAd pcmAns05        s             30a
720aAd pcmAns06        s             30a
720aAd pcmAns07        s             30a
720aAd pcmAns08        s             30a
720aAd pcmAns09        s             30a
720aAd pcmAns10        s             30a
730aAD optPrtReport    s               n   inz('0')
730eAd RealType        s             10
730eAd RealStatus      s              1
730eAd Realststs       s               z
730eAd Realstsuc       s               z
EOPaAd rcvtime         s              6s 0
EOPaAd rcvuser         s             15a
640aAD rtnCode         s             10
640aAD rtnMessage      s            200
510bAd spo             s              2
640aAD stamp           s               z
640aAD stampUC         s               z
510bAd today           s              8  0
720aAd workText        s             30a
700cAd workAdj1        s             11  0
700cAd workAdj2        s             11  0
700cAd workAisle       s              3a
700cAd workCode        s            117a
ADFaAd workDesc        s             30a
700cAd workDisp        s             12a
ADFaAd workSys         s              1a
640aAD workTran        s              7s 0
640aAD zeroUploadDate  s              8s 0
730fAD writeToExport   s               n
760bAD smallestUOM     s              1s 0
760bAD uomCount        s              1s 0
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
COTaAd @prtpg          c                   const('PO330CL')

640eA*----------------------------------------------------------------
640eA*  Called program parameters
640eA*
640eAD $lparm          ds
640eAD  $lcmd                  1      8
640eAD  $lprg                  9     18
640eAD  $luky                 19     68
640eAD  $lrtn                 69     76
640eAD  $lerm                 77    136
640eAD  $lmsg                 77     80
640eA*
640eA*   Redefine key
640eAD  $lwhse                19     21  0
640eAD  $lpo                  22     30
640aA*----------------------------------------------------------------
640aA*  Standard SQL variables and constants
640aA*----------------------------------------------------------------
640aA
640aA /copy qcopysrc,c#stdsql

640aA*----------------------------------------------------------------
640aA*  Prototypes
640aA*----------------------------------------------------------------
640aA
640aAD GetBatId        pr                  extpgm('GETBATID')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pStatus                      1    const
      * Output
     D   pBatId                      11
     D   pReturn                     10
     D   pMessage                   200

700cA /copy qcopysrc,p.getoptio
740cA* Prototype for NetSuite API Call
740cA /copy *libl/qcopysrc,p.intapins

700cAD getRecId        pr                  extpgm('GETRECID')
700cAD  pWhse                         3s 0 const
700cAD  pFile                        10    const
700cAD  pRecId                       11p 0

700cAD getAdjCode      pr                  extpgm('GETADJCOD')
700cAD  pCode                         2    const
700cAD  pDesc                        30
700cAD  pSys                          1

DRY A*
DRY Ad DryExportPgm    pr                  Extpgm('BFCEPO05C')
DRY Ad* Input
DRY Ad   $hWhsen                      3  0
DRY Ad   $hbatid                     11
DRY Ad   $hflib                      10
DRY Ad* Output
DRY Ad   $hrtn                        8

730aA /copy *libl/qcopysrc,p.getopint

650 A*----------------------------------------------------------------
650 A*  File info data structures
650  *----------------------------------------------------------------
650 A
650 A /COPY qcopysrc,c#file1ds
650 A
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
640aA*      $pWhse  - Warehouse
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

640aAc     *entry        plist
640aAc                   parm                    $pWhse3A
640aA
640aAc                   eval      $pWhse = %dec($pWhse3A: 3: 0)
640aAC                   eval      *inlr = *on

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
640aAC                   eval      haveBatId = *off
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
500 Ac                   endif
510dA*
510dA*      Skip p/o header if record is being used.
500 Ac                   if        *in75
500 Ac                   eval      *in75 = *off
500 Ac                   iter
500 Ac                   endif
     *
401 A*  Skip order if status is not '3' ready for export.
401 A*
640aDc**   phstat        cabne     '3'           bottom
640aMc                   if        phstat <> '3'
650aAc                             and phstat <> '4'
640aAC                   iter
640aAC                   endif

COTaAc                   if        client = Cotati or
GRCaAc                             client = Greco
EOPbAc                             or client = EarlsOrganic
730aAc                             or optPrtReport
COTaA*
COTaA*  Auto print receiving and pcm reports.
COTaAc                   movel     'PO330PR '    wkprtf           10
COTaAc     wkprtf        chain     reports                            79
COTaAc     *in79         ifeq      *on
COTaAc                   movel     '*STD'        $pform           10
COTaAc                   movel     '*JOB'        $pdev            10
COTaAc                   else
COTaAc                   if        rpscrn = '2'
COTaAC     #user         Chain     piruser                            79
COTaAC                   if        *in79=*on
COTaAC                   eval      uswhse=1
COTaAC                   eval      usWHDP=*BLANKS
COTaAC                   endif
COTaAc                   call      'GETRPT'
COTaAc                   parm      '*DEVFORM'    $rcmd             8
COTaAC                   PARM      'PO330PR'     $LRPT            10
COTaAC                   PARM      USwhse        $WHSE             3 0
COTaAC                   PARM      ' '           $STYP             1
COTaAC                   PARM      uswhdp        $WHDP             5
COTaAC                   PARM                    $DESC            50
COTaAC                   PARM                    $DEV             10
COTaAC                   PARM                    $FORM            10
COTaAc                   move      $form         $pform
COTaAc                   move      $dev          $pdev
COTaAC                   else
COTaAc                   move      rpform        $pform
COTaAc                   move      rpdev         $pdev
COTaAC                   endif
COTaAc                   endif
COTaA
COTaAc                   move      phwhse        $pwhs             3
COTaAc                   call      @prtpg
COTaAc                   parm                    $pwhs
COTaAc                   parm                    phpo
COTaAc                   parm                    $prtn             8
COTaAc                   parm                    $pdev
COTaAc                   parm                    $pform
COTaA * Now print Haccp log
COTaA * check for new or old haccp
COTaA * check to make sure programs exist or don't do call
COTaAC                   eval      qcmd = 'CHKOBJ '
COTaAC                                  + 'OBJ(HA301) '
COTaAC                                  + 'OBJTYPE(*PGM)'
COTaAC                   call      'QCMDEXC'                            78
COTaAC                   parm                    qcmd            256
COTaAC                   parm      80            qlen             15 5
COTaAc                   if        *in78 = *off
COTaAc                   exsr      PrtLog
COTaAc                   endif
COTaAc                   endif
COTaAc*    endprt        tag

720aA /free
720aA   // Get POH level HAACP info for extension fields
720aA   exsr GetPcmHdr;
720aA /end-free

650aA*
650aA*  Set flag if PO is Partial Export
650aAc                   if        phstat = '4'
650aAc                   eval      partialpo = *on
650aAc                   else
650aAc                   eval      partialpo = *off
650aAc                   endif
640aA
640aA*  Skip transfer PO's
640aA
640aAC                   if        %subst(phpo:8:2) = 'TF'
640aAC                   iter
640aAC                   endif
640aA
640aA*    If first time, get batch id.
640aA*      If error, get out.
640aA
640aAC                   if        not haveBatId
640aAC                   exsr      zzzGetBatId
640aAC                   if        batId = ' '
640aAC                   leave
640aAC                   endif
640aAC                   eval      haveBatId = *on
640aAC                   endif

730fA*  Set flag for writing PO to Export files
730fA
730fA /free
730fA     select;
730fA
730fA       // Don't write Special Order Code BR to export files
730fA       when pdspcl = 'BR';
730fA         writeToExport = *off;
730fA
730fA       // Don't write Lincoln tfr PO to export files
730fA       when client = lincoln and phven = 6090;
730fA         writeToExport = *off;
730fA
730fA       // Don't write A&D Foods MOVEIN PO from vendor ITC
730fA       when client = AandDFoods and phmm1 = 'ITC';
730fA         writeToExport = *off;
730fA
SFP A       // Don't write Seashore Vendor# 37 to export files.
SFP A       when client = Seashore and phven = 37;
SFP A         writeToExport = *off;
730fA
730fA       other;
730fA         writeToExport = *on;
730fA
730fA     endsl;
730fA /end-free
730fA
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
416aMc                             spo = 'SP'
416 Ac                   exsr      zzdlpu
416 A*
416 A*    Process all other P/O's.
416 Ac                   other
640dA*
640dA*    Retrieve P/O Header Misc. file.
640dAc     keyod         chain     pohdrm                             74
640dAC                   if        *in74 = '1'
640dAC                   eval      phmm1 = ' '
640dAC                   eval      phmm2 = ' '
640dAC                   eval      phmm3 = ' '
640dAC                   eval      phmm4 = ' '
640dAC                   eval      phmm5 = ' '
640dAC                   endif
PAK A*
730fDC**                 select
730fD **
730fDC**                 when      client = lincoln
730fD **    Don't write to export file for MOVEIN PO
730fDC**                 if        phven <> 6090
730fDc**                 exsr      filpeh
730fDc**                 write     pehrec
730fDc**                 endif
730fD **
730fDC**                 when      client = AandDFoods
730fD **    Don't write to export file for MOVEIN PO from vendor ITC
730fDC**                 if        phmm1 <> 'ITC'
730fDc**                 if        pdspcl <> 'BR'
730fDc**                 exsr      filpeh
730fDc**                 write     pehrec
730fDc**                 endif
730fDc**                 endif
730fD **
730fDC**                 other
730fD **
730fDc**                 if        pdspcl <> 'BR'
     c*
730fAc                   if        writeToExport
     c                   exsr      filpeh
     c                   write     pehrec
700aAc                   endif
     c
730fDC**                 endsl
     *
730fD ** write records for License export
730fDC**                 select
730fDC**                 when      client = AandDFoods
730fD **    Don't write to export file for MOVEIN PO from vendor ITC
730fDC**                 if        phmm1 <> 'ITC'
730fDc**                 if        pdspcl <> 'BR'
730fD /free
730fD   // is this Item UCI tracked?
730fD   //chain (pdwhse:pditem) itemmsc;
730fD   //if not %found(itemmsc);
730fD   //  clear imrec;
730fD   //endif;
730fD /end-free
730fDc**                 if        imltrk = 'U'
730fDc**                 exsr      wrtpelUCI
730fDc**                 else
730fDc**                 exsr      wrtpel
730fDc**                 endif
730fDc**                 endif
730fDc**                 endif
730fD **
730fDc**                 other
730fDc**                 if        pdspcl <> 'BR'
730fDc**                 exsr      wrtpel
730fDc**                 endif
730fDc**                 endsl
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
640dDc*    keyod         chain     pohdrm                             74
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
650aAc                             and partialpo = *off
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
640cAc     keypdm        chain (n) podtlm
640cAC                   if        not %found(podtlm)
640cAC                   eval      pdmods = ' '
640cAC                   eval      pdmpom = ' '
640cAC                   eval      pdmms1 = ' '
640cAC                   eval      pdmms2 = ' '
HKW AC                   if        client = Hearnkirkwood
HKW AC                   eval      pdmms2 = %replace('00000000':pdmms2:1:8)
HKW AC                   endif
640cAC                   eval      pdmms3 = ' '
640cAC                   eval      pdmms4 = ' '
640cAC                   eval      pdmms5 = ' '
640cAC                   endif
640cA*
HKW AC                   select
HKW AC                   when      client = Hearnkirkwood
HKW A*
HKW A*     Retrieve oldest expiration date for date sensitive items.
HKW AC                   exsr      zzgetexpdate
DRYaA*
DRYaAC                   when      client = Dairyland
DRYaA*     Calculate OSS quantity received.
DRYaAC                   exsr      zzcalcossrcv
DRYaA*
HKW AC                   endsl
HKW A*
730fDC**                 select
730fD **
730fDC**                 when      client = lincoln
730fD **    Don't write to export file for MOVEIN PO
730fDC**                 if        phven <> 6090
730fDc**                 exsr      filped
730fDc**                 write     pedrec
730fDc**                 endif
730fD **
730fDC**                 other
PAK A*
730fAc                   if        writeToExport
     c                   exsr      filped
     c                   write     pedrec
740bAc                   if        (optHostSys <> 'NECS-ENTREE'
740bAc                             and optHostSys <> 'NECS' )
740bAc                             or  client = AandDFoods
730fAc                   exsr      wrtpel
740bAc                   endif
730fAc                   endif
     c
730fDC**                 endsl

720aA /free
720aA   // After Detail custom processing
720aA   select;
EOPaA     when client = EarlsOrganic;
EOPaA       exec sql select min(porusr), min(portim)
EOPaA                  into :rcvuser, :rcvtime
EOPaA                  from porcv
EOPaA                 where porpo = :pedpo
EOPaA                   and poremp < 99000
EOPaA                   and poract = 'R';
EOPaA       if sqlstt = sqlsuccess;
EOPaA         exec sql select trim(usfnam) || substr(uslnam,1,1)
EOPaA                    into :pcmAns01
EOPaA                    from piruser
EOPaA                   where uscode = :rcvuser;
EOPaA         pcmAns02 = %subst(%editc(rcvtime:'X'):1:2) + ':'
EOPaA                  + %subst(%editc(rcvtime:'X'):3:2);
EOPaA       else;
EOPaA         pcmAns01 = *blanks;
EOPaA         pcmAns02 = '00:00';
EOPaA       endif;
EOPaA       exsr filpex;
EOPaA       write pexrec;
720aA   endsl;
720aA /end-free
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
LINaA*
LINaAC                   when      client = lincoln
LINaA*      Don't write to export file for MOVEIN PO
LINaAC                   if        phven <> 6090
LINaAc                   exsr      filpoe
LINaAc                   write     poerec
LINaAc                   endif
LINaA*
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
640eA*
640eA*  Call HA710 to update new haccp log file with export info.
640eAc                   eval      $lcmd = '*EXPORT'
640eAc                   eval      $lwhse = phwhse
640eAc                   eval      $lpo   = phpo
640eAc                   call      'HA710'
640eAc                   parm                    $lparm
650aAc                   select
650aA*  If partial export, change status back to 1.
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
750bA*
750bAc                   eval      phstat = '4'
750bAC                   exsr      zzupddckvue
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
640aA /free
640aA
640aA    if haveBatId;
640aA      exsr zzzEnd;
DRY A
DRY A      if client = Dairyland;
DRY A        if sqlstt = sqlSuccess;
DRY A          callp(e) DryExportPgm($pwhse:batid:f1library:hrtn);
DRY A        endif;
DRY A      endif;
DRY A
730eA      // Is this real time staging
730eA      GetOptions(%editc(0:'X'):
730eA                 '*FTP': '001': '001': ExportType);
730eA      if ExportType = 'R';
730gD        //RealType = 'PO';
730gA        RealType = 'POF';
730eA        RealStatus = 'R';
730eA        exsr zzzGetStamps;
730eA        Realststs  = stamp;
730eA        Realstsuc  = stampuc;
730eA        exec sql
730eA         insert into exptrig
730eA         values (:$pWhse,:RealType,:batid,:RealStatus,
730eA                 :Realststs,:Realstsuc,:Realststs,:Realstsuc);
730eA
730eA      endif;
640aA    endif;
640aA
640aA /end-free
     *
     c     bottom        tag
     *----------------------------------------------------------------
     *
     *          Subroutines In Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     c     *inzsr        begsr
510cA*
510cA* Get client id.
510cA*
510cAc                   call      'GETCLIENT'
510cAc                   parm                    client           10
510cAc                   parm                    clientloc        10
740bAc                   parm                    clientinit        3
740bAc                   parm                    clienthost       10
     *
218 M*   Define partial key for PODTL file.
     *
     c     keyod         klist
     c                   kfld                    phwhse
     c                   kfld                    phpo
640cA*
640cA*   Define full key for PODTLM file.
640cA*
640cAc     keypdm        klist
640cAc                   kfld                    pdwhse
640cAc                   kfld                    pdpo
640cAc                   kfld                    pdseq
640cAc                   kfld                    pditem
HKW A*
HKW A*   Define full key for POMFR file.
HKW A*
HKW Ac     keypm         klist
HKW Ac                   kfld                    pdwhse
HKW Ac                   kfld                    pdpo
HKW Ac                   kfld                    pdseq
HKW Ac                   kfld                    pditem
700aA*
700aA*   Define partial key for PORCV file.
700aA*
700aAc     keyrcv        klist
700aAc                   kfld                    pdwhse
700aAc                   kfld                    pdpo
700aAc                   kfld                    pdseq
700aA*
700aA*   Define unique key for HACCPLOG file.
700aA*
700aAc     keyhcp        klist
700aAc                   kfld                    hxwhse
700aAc                   kfld                    hxpo
700aAc                   kfld                    hxposeq
700aAc                   kfld                    hxseq#
700aA*
700aA*   Define unique key for LICINFO file.
700aA*
700aAc     keylic        klist
700aAc                   kfld                    porwhs
700aAc                   kfld                    porlic
700aAc                   kfld                    lnseq
DRYaA*
DRYaA*   Define full key for PORCV file.
DRYaA*
DRYaAc     keypor        klist
DRYaAc                   kfld                    pdwhse
DRYaAc                   kfld                    pdpo
DRYaAc                   kfld                    pdseq
DRYaAc                   kfld                    phhedt
DRYaAc                   kfld                    phheti
416bA*
416bA*   Define key for Lumper file.
416bA*
416bAc     lmkey         klist
416bAc                   kfld                    phwhse
416bAc                   kfld                    phpo
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
     *
740cA /free
740cA *  Get Host ERP from OPTIONS
740cA    GetOptions(%editc(0:'X'):
740cA                 '*HOST': '001': '010': ExportType);
740cA    hostopts = ExportType;
740cA *  Get Host ERP from OPTIONINT
740cA   // Get debug flag
740cA   optint.type = 'Interface   ';
740cA   optint.cat  = 'General Options     ';
740cA   optint.name = 'Host ERP System     ';
740cA   GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
740cA             optint.valn: optint.vala: optint.return);
740cA   if optint.return = '*OK';
740cA     hostoptint = optint.vala;
740cA   else;
740cA     hostoptint = '*NONE';
740cA   endif;
740cA
730aA /free
730aA   // Get Option to see if overflow when no pick.
730aA   optint.type = 'Interface   ';
730aA   optint.cat  = 'Export POs          ';
730aA   optint.name = 'Print Receiving Rept';
730aA   GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
730aA             optint.valn: optint.vala: optint.return);
730aA   if optint.return = '*OK'
730aA    and optint.vala = 'Y';
730aA     optPrtReport = *on;
730eA   else;
730eA     optPrtReport = *off;
730aA   endif;
730aA /end-free
740bA /free
740bA   // Get Host ERP system name.
740bA   optint.type = 'Interface   ';
740bA   optint.cat  = 'General Options     ';
740bA   optint.name = 'Host ERP System     ';
740bA   GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
740bA             optint.valn: optint.vala: optint.return);
740bA   if optint.return = '*OK';
740bA     optHostSys = optint.vala;
740bA   else;
740bA     optHostSys = clienthost;
740bA   endif;
740bA /end-free
     *
     c                   endsr
730bA*----------------------------------------------------------------
730bA*  ConvertUCI Convert the UCI
730bA*----------------------------------------------------------------
730bA
730bAC     ConvertUCI    begsr
730bAC                   eval      $cbcmd = '*ALL    '
730bAC                   eval      $cbbar = uiuci
730bAc                   clear                   $barcode
730bAc                   clear                   $barcode2
730bAc                   clear                   $cvtdata
730bAc                   clear                   $cvtdata2
730bA*
730bAC                   call      'CVTBAR'
730bAC                   parm                    $cbcmd            8
730bAC                   parm                    $cbbar          100
730bAC                   parm                    $cbcod            3 0
730bAC                   parm                    $cbdec            1 0
730bAC                   parm                    $cbdsc           30
730bAC                   parm                    $cbpos            3 0
730bAC                   parm                    $cbtyp            1 0
730bAC                   parm                    $cbv1            11 3
730bAC                   parm                    $cbv2            50
730bAC                   parm                    $cbrtn            8
730bAC                   parm                    $cberm           60
730bAC                   parm                    $cbven           10 0
730bAC                   parm                    $cvtdata
730bAC                   parm                    $cvtdata2
730bAC                   parm      uiwhse        $cbwhse
730bAc                   eval      $barcode = $cvtdata
730bAc                   eval      $barcode2 = $cvtdata2
730bAC                   endsr
760bA*----------------------------------------------------------------
760bA*
760bA*  DownRcvQty  Convert Rcvd qtys down to smalles UOM
760bA*
760bA*    Input:  rcvdQty1, rcvdQty2, rcvdQty3
760bA*    Output: newRcvdQty1, newRcvdQty2, newRcvdQty3
760bA*
760bA*    The FreshByte Host does not allow multiple Received
760bA*    UOM's. For example, 10 Cases and 5 Eaches.
760bA*    Therefore, when multiple UOM's are Received, we
760bA*    need to convert qtys to the smallest Recieved UOM.
760bA*    For the above example, we would need to convert the
760bA*    10 Cases into Eaches.
760bA*
760bA*----------------------------------------------------------------
760bA
760bAc     DownRcvQty    begsr
      /free

         // See if multiple UOM's were Received

         smallestUOM = 0;
         uomCount = 0;

         if pedqr1<>0;
           smallestUOM = 1;
           uomCount += 1;
         endif;

         if pedqr2<>0;
           smallestUOM = 2;
           uomCount += 1;
         endif;

         if pedqr3<>0;
           smallestUOM = 3;
           uomCount += 1;
         endif;

         // If multiple UOM's not Received, return

         if uomCount < 2;
           leavesr;
         endif;

         // Otherwise ...

         // Get item record for brkdn qty's

         chain (pdwhse: pditem) piritem;
         if not %found(piritem);
           clear itrec;
           itumq2 = 1;
           itumq3 = 1;
         endif;

         // Convert qty's down to smallest Rcvd UOM

         select;

           when smallestUOM = 2;
             pedqr2 += pedqr1 * itumq2;
             pedqr1 = 0;

           when smallestUOM = 3;
             pedqr3 += pedqr1 * itumq2 * itumq3;
             pedqr3 += pedqr2 * itumq3;
             pedqr2 = 0;
             pedqr1 = 0;

         endsl;

      /end-free
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
     c                   eval      pedpo = pdpo
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

640aAC                   exsr      zzzGetStamps
640aAC                   eval      pedbatid = batId
640aAC                   eval      pedstatus = 'R'
640aAC                   eval      pedststs = stamp
640aAC                   eval      pedstsuc = stampuc
640aAC                   eval      pedaddts = stamp
640aAC                   eval      pedadduc = stampuc
640cA*
640cA*      Load Header misc. fields.
640cAC                   eval      pedms1 = pdmms1
640cAC                   eval      pedms2 = pdmms2
HKW AC                   if        client = Hearnkirkwood
HKW AC                   eval      pedms2 = %replace(%editc(hkwexpdate:'X')
HKW AC                                      :pedms2:1:8)
HKW AC                   endif
DRYaA*
DRYaAC                   if        client = Dairyland
DRYaAC                   eval      pedms2 = podm2_dry
DRYaAC                   endif
DRYaA*
640cAC                   eval      pedms3 = pdmms3
640cAC                   eval      pedms4 = pdmms4
640cAC                   eval      pedms5 = pdmms5
     *
760bA /free
760bA
760bA    // Extra logic for FreshByte Host system
760bA
760bA    if clienthost = freshbyte;
760bA      exsr DownRcvQty;
760bA    endif;
760bA
760bA /end-free
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
650aAc                   if        partialpo
650aAc                   eval      pehamp = 'U'
650aAc                   else
     c                   eval      pehamp = phampm
650aAc                   endif

640aAC                   exsr      zzzGetStamps
640aAC                   eval      pehbatid = batId
640aAC                   eval      pehstatus = 'R'
640aAC                   eval      pehststs = stamp
640aAC                   eval      pehstsuc = stampuc
640aAC                   eval      pehaddts = stamp
640aAC                   eval      pehadduc = stampuc
640dA*
640dA*      Load Header misc. fields.
640dAC                   eval      pehmm1 = phmm1
640dAC                   eval      pehmm2 = phmm2
640dAC                   eval      pehmm3 = phmm3
640dAC                   eval      pehmm4 = phmm4
640dAC                   eval      pehmm5 = phmm5
     *
     c                   endsr
720aA*----------------------------------------------------------------
720aA*
720aA*  FILPEX  Fill export extension fields.
720aA*
720aAc     filpex        begsr
720aA*
720aA*  Initialize record
720aA*
720aAc                   clear                   pexrec
720aA*
720aA*  Move fields from order file to export file.
720aA*
720aAc                   eval      pexwhs = pedwhs
720aAc                   eval      pexpo = pedpo
720aAc                   eval      pexseq = pedseq
720aAc                   eval      pexitm = peditm
720aA
720aAC                   eval      pexbatid = pedbatid
720aAC                   eval      pexstatus = pedstatus
720aAC                   eval      pexststs = pedststs
720aAC                   eval      pexstsuc = pedstsuc
720aAC                   eval      pexaddts = pedaddts
720aAC                   eval      pexadduc = pedadduc
720aA
720aAC                   eval      pexpcm01 = %triml(pcmAns01)
720aAC                   eval      pexpcm02 = %triml(pcmAns02)
720aAC                   eval      pexpcm03 = %triml(pcmAns03)
720aAC                   eval      pexpcm04 = %triml(pcmAns04)
720aAC                   eval      pexpcm05 = %triml(pcmAns05)
720aAC                   eval      pexpcm06 = %triml(pcmAns06)
720aAC                   eval      pexpcm07 = %triml(pcmAns07)
720aAC                   eval      pexpcm08 = %triml(pcmAns08)
720aAC                   eval      pexpcm09 = %triml(pcmAns09)
720aAC                   eval      pexpcm10 = %triml(pcmAns10)
720aA
720aAc                   endsr
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

640aAC                   exsr      zzzGetStamps
640aAC                   eval      poebatid = batId
640aAC                   eval      poestatus = 'R'
640aAC                   eval      poeststs = stamp
640aAC                   eval      poestsuc = stampuc
640aAC                   eval      poeaddts = stamp
640aAC                   eval      poeadduc = stampuc
417 A*
417 Ac                   endsr
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
700aA*
720aA*----------------------------------------------------------------
720aA*  GetPcmHdr      Get PCM Header level info
720aA*
720aA /free
720aA   begsr GetPcmHdr;
720aA
720aA   select;

EOPaA    when client = EarlsOrganic;
EOPaA     // get question 1 answer from haccplog
EOPaA     exec sql select hldata into :workText from haccplog
EOPdM               where hlpo = :phpo
EOPaA                 and hllevl = 'RCVI' and hlseq# = 1
EOPcA                 and hlobsolete <> 'Y'
EOPcA               order by hladdts desc
EOPcA               fetch first row only;
EOPaA     if sqlstt <> sqlsuccess;
EOPaA       pcmAns06 = '0';
EOPaA     else;
EOPaA       if workText = 'Yes';
EOPaA         pcmAns06 = '1';
EOPaA       else;
EOPaA         pcmAns06 = '0';
EOPaA       endif;
EOPaA     endif;
EOPaA     // get question 5 answer from haccplog
EOPaA     exec sql select hldata into :workText from haccplog
EOPdm               where hlpo = :phpo
EOPaA                 and hllevl = 'RCVI' and hlseq# = 5
EOPcA                 and hlobsolete <> 'Y'
EOPcA               order by hladdts desc
EOPcA               fetch first row only;
EOPaA     if sqlstt <> sqlsuccess;
EOPaA       pcmAns07 = *blanks;
EOPaA     else;
EOPaA       pcmAns07 = workText;
EOPaA     endif;
EOPaA     // get question 6 answer from haccplog
EOPaA     exec sql select hldata into :workText from haccplog
EOPdm               where hlpo = :phpo
EOPaA                 and hllevl = 'RCVI' and hlseq# = 6
EOPcA                 and hlobsolete <> 'Y'
EOPcA               order by hladdts desc
EOPcA               fetch first row only;
EOPaA     if sqlstt <> sqlsuccess;
EOPaA       pcmAns03 = *blanks;
EOPaA     else;
EOPaA       pcmAns03 = workText;
EOPaA     endif;
EOPaA     // get question 7 answer from haccplog
EOPaA     exec sql select hldata into :workText from haccplog
EOPdm               where hlpo = :phpo
EOPaA                 and hllevl = 'RCVI' and hlseq# = 7
EOPcA                 and hlobsolete <> 'Y'
EOPcA               order by hladdts desc
EOPcA               fetch first row only;
EOPaA     if sqlstt <> sqlsuccess;
EOPaA       pcmAns04 = *blanks;
EOPaA     else;
EOPaA       pcmAns04 = workText;
EOPaA     endif;
EOPaA     // get question 8 answer from haccplog
EOPaA     exec sql select hldata into :workText from haccplog
EOPdm               where hlpo = :phpo
EOPaA                 and hllevl = 'RCVI' and hlseq# = 8
EOPcA                 and hlobsolete <> 'Y'
EOPcA               order by hladdts desc
EOPcA               fetch first row only;
EOPaA     if sqlstt <> sqlsuccess;
EOPaA       pcmAns05 = *blanks;
EOPaA     else;
EOPaA       pcmAns05 = workText;
EOPaA     endif;
EOPaA     if %subst(pcmAns05:2:1) = ',';
EOPaA       pcmAns05 = %subst(pcmAns05:1:1) + %subst(pcmAns05:3:28);
EOPaA     endif;
EOPaA     // get question 9 answer from haccplog
EOPaA     exec sql select hldata into :workText from haccplog
EOPdm               where hlpo = :phpo
EOPaA                 and hllevl = 'RCVI' and hlseq# = 11
EOPcA                 and hlobsolete <> 'Y'
EOPcA               order by hladdts desc
EOPcA               fetch first row only;
EOPaA     if sqlstt <> sqlsuccess;
EOPaA       pcmAns08 = *blanks;
EOPaA     else;
EOPaA       pcmAns08 = workText;
EOPaA     endif;

720aA   endsl;
720aA
720aA   endsr; //  GetPcmHdr
720aA /end-free
700aA*----------------------------------------------------------------
700aA*
700aA*  WRTPEL  Write license export fields.
700aA*
700aAc     wrtpel        begsr

700aA*
700aA*  Initialize record
700aA*
700aAc                   clear                   pelrec
700aA*
700aA*  Move fields from license file to export file.
700aA*
700aAc                   eval      pelwhs = pdwhse
700aAc                   eval      pelpo = pdpo
700aAc                   eval      pelseq = pdseq
700aAc                   eval      pelitm = pditem
700aAc                   eval      pelbatid = batid
700aAC                   eval      pelstatus = 'R'
700aAC                   eval      pelststs = stamp
700aAC                   eval      pelstsuc = stampuc
700aAC                   eval      peladdts = stamp
700aAC                   eval      peladduc = stampuc
730fD **
730fD ** Move fields from license file to EXPSPOLT file.
730fD **
730fDc**                 eval      peltwhs = pdwhse
730fDc**                 eval      peltpo = pdpo
730fDc**                 eval      peltseq = pdseq
730fDc**                 eval      peltitm = pditem
730fDc**                 eval      peltbatid = batid
730fDC**                 eval      peltstatus = 'R'
730fDC**                 eval      peltststs = stamp
730fDC**                 eval      peltstsuc = stampuc
730fDC**                 eval      peltaddts = stamp
730fDC**                 eval      peltadduc = stampuc
700aA*
700aA*  Read receipt detail and write license records
700aAc     keyrcv        setll     porcv
700aA*
700aAc                   dou       forevr <> forevr
700aAc     keyrcv        reade     porcv                                  78
700aAc                   if        *in78
700aAc                   leave
700aAc                   endif
710aA*
710aAc                   if        poract = 'D'
710aAc                   iter
710aAc                   endif
700aA*
700aAC                   eval      pellic = porlic
730fDC**                 eval      pelthstlot = porlic
730fDC**                 eval      peltlcns = porlic
750aAC                   eval      pelqt1 = 0
750aAC                   eval      pelqt2 = 0
750aAC                   eval      pelqt3 = 0
730fA
730fA*  Get Receiver information
730fA
730fAC                   eval      pelrby = porusr
730fAC                   eval      pelemp = poremp
730fA
730fA*  Special user processing for Greanleaf
730fA
730fAC                   if        client = Greenleaf
730fA
730fAC                   call      'GETUSER'
730fAC                   parm                    porusr
730fAC                   parm      0             #whse             3 0
730fAC                   parm      0             #emp#             5 0
730fAC                   parm                    #fnam            15
730fAC                   parm                    #init             1
730fAC                   parm                    #lnam            20
730fAC                   parm                    #whdp             5
730fAC                   parm                    #styp             1
730fAC                   parm                    #shft             6
730fAC                   parm                    #crew             6
730fAC                   parm      0             #nhrs             3 1
730fAC                   parm                    #rtn              8
730fA
730fAC                   if        #rtn = '*OK'
730fAC                             and %subst(#lnam:18:3) <> *blanks
730fAC                   eval      pelrby = %subst(#lnam:18:3)
730fAC                   endif
730fA
730fAC                   endif
730fA
730fA /free
730fA
730fA   // Get label record
730fA
730fA   chain (porlbl) label;
730fA
730fA   if not %found(label);
730fA     lbutyp = 'N';
730fA   endif;
730fA
730fA /end-free

700aA*
700aA*  Get License Information
700aA*
700aAC                   eval      lnseq = 1
700aAC     keylic        chain     licinfo
700aA*
700aAC                   if        %found(licinfo)
700aAC                   eval      pellot = lnlot
730fAC                   select
730fAC                   when      lbutyp = 'N'
700aAC                   eval      pelqt1 = lnrcvqty
730fAC                   when      lbutyp = '1'
700aAC                   eval      pelqt2 = lnrcvqty
730fAC                   when      lbutyp = '2'
700aAC                   eval      pelqt3 = lnrcvqty
730fAC                   endsl
760bA /free
760bA
760bA    // Extra logic for FreshByte Host system
760bA    // Convert qty's down to smallest Rcvd UOM
760bA    // See routine DownRcvQty for explanation.
760bA    // Fields used were set in routine DownRcvQty, which is
760bA    // called from filped, which is called from mainline
760bA    // before this routine is called.
760bA
760bA    if clienthost = freshbyte;
760bA
760bA      select;
760bA
760bA        when uomCount > 1 and smallestUOM = 2;
760bA          pelqt2 += pelqt1 * itumq2;
760bA          pelqt1 = 0;
760bA
760bA        when uomCount > 1 and smallestUOM = 3;
760bA          pelqt3 += pelqt1 * itumq2 * itumq3;
760bA          pelqt3 += pelqt2 * itumq3;
760bA          pelqt2 = 0;
760bA          pelqt1 = 0;
760bA
760bA      endsl;
760bA
760bA    endif;
760bA
760bA /end-free
730fDC**                 eval      peltqty1 = pelqt1
730fDC**                 eval      peltqty2 = pelqt2
730fDC**                 eval      peltqty3 = pelqt3
730fDC**                 eval      peltlbl = lnrcvlbl#
730fDC**                 eval      pelttrn = lnrcvtrn#
730fAC**                 if        lnrcvqty = pedqr1
700aAC                   eval      pelwgt = lnttllbs
730fAC**                 else
730fAC**                 eval      pelwgt = (lnttllbs / pedqr1) * lnrcvqty
730fAC**                 endif
730fAC**                 eval      peltwgt = pelwgt
700aAC**                 eval      pelbrd = lnbrand
ADFcAc                   select
ADFcAC                   when      client = AandDFoods
ADFeAC                   eval      pelwgt = (lnttllbs / pedqr1) * lnrcvqty
710aAC                   eval      pelbrd = 'NB'
ADFcAc                   other
ADFcAC                   eval      pelbrd = lnbrand
ADFcAc                   endsl
700bA /free
700fD     //if lnMfgExp = 0 and lnExpDate > 0;
700fD     //  lnMfgExp = lnExpDate;
700fD     //endif;
700bA     //pelexp = lnMfgExp;
700bA     //pelexp = lnEntDate;
ADFdA       if lnExpDate = 0;
ADFdA         pelexp = lnMfgExp;
ADFdA       else;
ADFdA         pelexp = lnExpDate;
ADFdA       endif;
700bA /end-free
700aAC                   else
730bAC**  else license not found
700aAC                   eval      pellot = *blanks
700aAC                   eval      pelqt1 = 0
700aAC                   eval      pelqt2 = 0
700aAC                   eval      pelqt3 = 0
700aAC                   eval      pelwgt = 0
700aAC                   eval      pelbrd = *blanks
700bAC                   eval      pelexp = 0
700bAC                   eval      lnaddusr = *blanks
730fDC**                 eval      peltlot = *blanks
730bAC                   eval      lnaddusr = *blanks
730fAC                   eval      lnentdate = 0
730fAC                   eval      lnenttype = ''
700bAC                   endif
700xA
700aA*
700aA*  Get COOL info from HACCP files
700aAC                   eval      peloco = *blanks
700aAC                   eval      pelost = *blanks
700aAC                   eval      pelocy = *blanks
700aA*
700aAC     porlic        setll     hxrec
700aAC     porlic        reade     hxrec
700aA*
700aAC                   dow       not %eof()
700aAC     keyhcp        chain     hlrec
700aAC                   if        %found(haccplog3)
700aAC                   select
700aAC                   when      hlseq# = 1
700aAC                   eval      peloco = hldata
700aAC                   when      hlseq# = 2
700aAC                   eval      pelost = hldata
700aAC                   when      hlseq# = 3
700aAC                   eval      pelocy = hldata
700aAC                   endsl
700aAc                   endif
700aAC     porlic        reade     hxrec
700aAc                   enddo
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
700aA*
700aA*  Write license record
700aAc                   write     pelrec

730bA*  Write EXPSPOLT records
730fAc**                 write     peltrec
730fAc                   exsr      wrtpelUCI
700cA*
700cA*  Check license location, if OSS write putaway transfer to LICADJ
700cA*
700cA /free
700cA     exec sql select laaisl,ladisp,laloc,larlvl,lahand,lawhdp
700cA               into :workAisle,:workDisp,:adjloc,:adjrlvl,:adjhand,:adjwhdp
700cA                from licactive
700cA               where lalcns = :pellic;
700cA     if sqlstt = sqlsuccess
700cA      and workAisle = 'OSS';
700cA
700cA       // If file not open, open it.
700cA       if not %open(licadj);
700cA         open LicAdj;
700cA       endif;
700cA
700cA       // Get unique adjustment record id.
700cA       GetRecId(pelwhs: 'LICADJ': workadj1);
700cA     //GetRecId(pelwhs: 'LICADJ': workadj2);
700cA
700cA       // Get transfer adj code default if none provided.
700cA     //GetOptions(%editc(pelwhs:'X'): '*ADJUST': '003': '002': workCode);
700cA       workCode = 'TL';
700cA       // Get adjustment code description/system.
700cA       GetAdjCode(workCode: workDesc: workSys);
700cA
700cA       adjwhs = pelwhs;
700cA       adjnbr = %char(workAdj1);
700cA       adjparent = *blank;
700cA       adjcode = workcode;
700cA       adjcsys = workSys;
700cA       adjitem = pelitm;
700cA       adjaqty1 = -1 * pelqt1;
700cA       adjaqty2 = -1 * pelqt2;
700cA       adjaqty3 = -1 * pelqt3;
700cA       adjcqta = -1 * pelwgt;
700cA     //adjwhdp = *blank;
700cA       adjdisp = *blank;
700cA       adjaisl = workAisle;
700cA     //adjloc = *zero;
700cA     //adjrlvl = *zero;
700cA     //adjhand = *blank;
700cA       adjstat = 'A';
700cA       adjmemo = %char(workAdj2);
700cA       adjlcns = pellic;
700cA       adjaddts = %timestamp();
700cA       adjadduc = %timestamp();
700cA       adjaddcpgm = #pgm;
700cA       adjaddjpgm = #pgm;
700cA       adjaddemp = *zero;
700cA       adjaddcusr = #curruser;
700cA       adjaddjusr = #user;
700cA       adjaddjob = #job;
700cA       adjaddnbr = #jobnbr;
700cA       adjexpflag = *blank;
700cA       adjdrislot = *blank;
700cA       adjdrilic = *blank;
700cA     //write adjrec;
700cA
700cA     //adjnbr = %char(workAdj2);
700cA     //adjparent = %char(workAdj1);
700cA       adjdisp = workDisp;
700cA       adjaqty1 = pelqt1;
700cA       adjaqty2 = pelqt2;
700cA       adjaqty3 = pelqt3;
700cA       adjcqta = pelwgt;
700cA       write adjrec;
700cA
700cA     endif;
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
700cA*
700aAc                   enddo
700aA*
700aAc                   endsr
700aA*
730bA*----------------------------------------------------------------
730bA*
730bA*  WRTPELUCI  Write license export fields - UCI
730bA*
730bAc     wrtpelUCI     begsr

730fA /free
730fA
730fA   // Initialize LT fields
730fA
730fA   clear peltrec;
730fA
730fA   peltwhs = pelwhs;
730fA   peltpo = pelpo;
730fA   peltseq = pelseq;
730fA   peltitm = pelitm;
730fA   peltbatid = pelbatid;
730fA   peltstatus = pelstatus;
730fA   peltststs = pelststs;
730fA   peltstsuc = pelstsuc;
730fA   peltaddts = peladdts;
730fA   peltadduc = peladduc;
730fA
760aA   // host freshbyte sends the lot from licinfo
760aA   if clienthost = freshbyte;
76aAA     pelthstlot = lnlot;
760aA   else;
730fA     pelthstlot = pellic;
760aA   endif;
730fA   peltlcns = pellic;
730fA   peltqty1 = pelqt1;
730fA   peltqty2 = pelqt2;
730fA   peltqty3 = pelqt3;
730fA   peltwgt = pelwgt;
730fA   peltlbl = lnrcvlbl#;
730fA   pelttrn = lnrcvtrn#;
730fA   peltlot = pellot;
730fA
730fA   // Note, the following fields are not named correctly in
        // EXPSPOLT. They have same names as in EXPSPOL.
        // Thus, we comment them out here.
730fA   //peltbrd = pelbrd;
730fA   //peltoco = peloco;
730fA   //peltost = pelost;
730fA   //peltocy = pelocy;
730fA   //peltrby = pelrby;
730fA   //peltemp = pelemp;
730fA
730fA   if lnentdate > 0;
730fA     monitor;
730fA       peltdate = %dec(%char(%date(lnentdate:*iso):*ymd0):6:0);
730fA       peltdatenm = %subst(lnenttype: 1: 4);
730fA       peltdatecd = '';
730fA     on-error;
730fA     endmon;
730fA   endif;
730fA
730fA   // Get tracking level
730fA
730fA   chain (pdwhse: pditem) itemmsc;
730fA   if not %found(itemmsc);
730fA     imltrk = '';
730fA   endif;
730fA
730fA   // For non-UCI tracking, write out license info
730fA   // Values set in calling routing WRTPEL.
730fA
730fA   if imltrk <> 'U';
730bA     write peltrec;
730fA     leavesr;
730fA   endif;
730fA
730fA   // Otherwise, write UCI recs
730fA
730bA   setll (pdwhse :porlic) uciinfo2;
730bA
730bA   dow forevr = forevr;
730bA
730bA     reade (pdwhse: porlic) uciinfo2;
730bA     if %eof(uciinfo2);
730bA       leave;
730bA     endif;
730bA
730bA     // now get the extension file for the rest of the data
730bA
730bA     chain (UIADDTS: UIUCILCNS: UILCNS) uciinfoexa;
730bA     if not %found(uciinfoexa);
730bA       clear UIAREC;
730bA     endif;
730bA
730bA     select;
760aA       when clienthost = freshbyte;
760aA         pelthstlot = lnlot;
730bA       when uiserial <> ' ';
730bA         PELTHSTLOT = uiserial;
730bA       when uialot <> ' ';
730bA         PELTHSTLOT = uialot;
730bA       when %subst(uiuci:1:3) = '99I';
730bA         PELTHSTLOT =uiuci;
730bA       other;
730fD         //pellic = uilcns;
730fA         pelthstlot = uilcns;
730bA     endsl;
730bA
730fD     //pellot = uialot;
730bA     peltlot = uialot;
730bA
730bA     select;
730bA       when uiautyp = 'N';
730fD         //pelqt1 = 1;
730bA         peltqty1 = 1;
730bA       when uiautyp = '1';
730fD         //pelqt2 = 1;
730bA         peltqty2 = 1;
730bA       when uiautyp = '2';
730fD         //pelqt3 = 1;
730bA         peltqty3 = 1;
730bA       other;
730fD         //pelqt1 = 1;
730bA         peltqty1 = 1;
730bA     endsl;
730bA
730fD     //pelwgt = uiwgtlbs;
730cA     peltwgt = uiwgtlbs;
730bA
730bA     exsr ConvertUCI;
730dA     Select;
730dA       when $bcProdDSent;
730dA         peltdate = $bcProdD;
730dA         peltdatecd = '11';
730fA         peltdatenm = 'PROD';
730dM       when $bcPackDSent;
730bA         peltdate = $bcPackD;
730dA         peltdatecd = '13';
730fA         peltdatenm = 'PACK';
730dA       when $bcSlByDSent;
730dA         peltdate = $bcSlByD;
730dA         peltdatecd = '15';
730fA         peltdatenm = 'BEST';
730dA       when $bcExpDSent;
730dA         peltdate = $bcExpD;
730dA         peltdatecd = '17';
730fA         peltdatenm = 'EXP';
730dA     Endsl;
730bA
730bA     peltlcns = uilcns;
730bA     peltuci = uiuci;
730bA     peltuciseq = uiseq;
730bA     peltgtin = %char(uiagtin);
730bA     peltserial = uiserial;
730bA     pelttrn = uiseltrn#;
730bA
730fA     write peltrec;
730fA
730fA   enddo;
730fA
730bA /end-free
730bAc                   endsr
730bA*
COTaAC*----------------------------------------------------------------
COTaAC*
COTaAC*  PrtLog   Print the haccp log
COTaAC*
COTaAc     PrtLog        begsr
COTaAC*
COTaAc                   if        *in78 = *off
COTaAc                   call      'HA301'
COTaAc                   parm      ' '           $hacmd            8
COTaAc                   parm      phwhse        $hawhse           3 0
COTaAc                   parm      phpo          $lhapo            9
COTaAc                   parm      ' '           $lhaitem         15
COTaAc                   parm                    $hanew            1
COTaAc                   if         $hanew = '1'
COTaAc                   call      'HA300'
COTaAc                   parm      '*PRINT'      $hacmd            8
COTaAc                   parm      phwhse        $hawhse15        15 5
COTaAc                   parm      phpo          $lhapo            9
COTaAc                   parm      ' '           $lhaitem         15
COTaAc                   parm      ' '           $levl             4
COTaAc                   parm                    $dev             10
COTaAc                   else
COTaAc                   endif
COTaAc                   else
COTaAc                   eval      *in78 = *off
COTaAc                   endif
COTaAc                   endsr
DRYaA*
DRYaA*----------------------------------------------------------------
DRYaA*
DRYaA*  ZZCALCOSSRCV   Calculate OSS Quantity Received on p/o line item
DRYaA*
DRYaAc     zzcalcossrcv  begsr
DRYaA*
DRYaAC                   eval      drydm2_osstype = ' '
DRYaAC                   eval      drydm2_ossrcv1 = 0
DRYaAC                   eval      drydm2_ossrcv2 = 0
DRYaAC                   eval      drydm2_ossrcv3 = 0
DRYaA*
DRYaAC     keypor        setll     porcv
DRYaAC                   dow       forevr = forevr
DRYaAC     keypor        reade (n) porcv
DRYaAC                   if        %eof(porcv)
DRYaAC                   leave
DRYaAC                   endif
DRYaA*
DRYaAC     porlbl        chain     label
DRYaAC                   if        %found(label)
DRYaA*
DRYaAC                   if        %subst(lbdisp:1:3) = 'OSS'
DRYaA*
DRYaA*       Set OSS Type on first label only.
DRYaAC                   if        drydm2_osstype = ' '
DRYaAC                   eval      drydm2_osstype = %subst(lbdisp:1:4)
DRYaAC                   endif
DRYaA*
DRYaAC                   select
DRYaAC                   when      lbutyp = 'N'
DRYaAC                   eval      drydm2_ossrcv1 = drydm2_ossrcv1 + lbqpck
DRYaAC                   when      lbutyp = '1'
DRYaAC                   eval      drydm2_ossrcv2 = drydm2_ossrcv2 + lbqpck
DRYaAC                   when      lbutyp = '2'
DRYaAC                   eval      drydm2_ossrcv3 = drydm2_ossrcv3 + lbqpck
DRYaAC                   endsl
DRYaA*
DRYaAC                   endif
DRYaA*
DRYaAC                   endif
DRYaA*
DRYaAC                   enddo
DRYaA*
DRYaAc                   endsr
750 A*----------------------------------------------------------------
750 A*
750 A*  ZZUPDDCKVUE   Update DockVue P/O Status Table.
750 A*
750 Ac     zzupddckvue   begsr
750 A*
750 A /free
750 A   // Set status for DockVue
750 A   exec sql insert into postatus
750 A            values (:phwhse, :phpo, :phstat,
750 A                    current_timestamp, :nostamp);
750 A*
750 A   if sqlstate <> '00000';
750 A   exec sql update postatus
750 A               set posstat = :phstat,
750 A                   posupdts = current_timestamp
750 A             where poswhs = :phwhse
750 A               and pospo = :phpo;
750 A   endif;
750 A*
750 A /end-free
750 A*
750 Ac                   endsr
417 A*
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
HKW A*
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

640aA*----------------------------------------------------------------
640aA*  zzzGetBatId    Get batch id
640aA*----------------------------------------------------------------
640aA
640aAc     zzzGetBatId   begsr
      /free

740aA   if $pWhse = 0;
740aA     $pWhse = 1;
740aA   endif;

        monitor;
640bM     GetBatId($pWhse: 'EXPPO': 'W':
                   batId: rtnCode: rtnMessage);
        on-error;
          clear batId;
          clear rtnCode;
          clear rtnMessage;
        endmon;

      /end-free
     c                   endsr

640aA*----------------------------------------------------------------
640aA*  zzzGetStamps   Get timestamps
640aA*----------------------------------------------------------------
640aA
640aAc     zzzGetStamps  begsr
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

640aA*----------------------------------------------------------------
640aA*  zzzEnd     End processing
640aA*----------------------------------------------------------------
640aA
640aAc     zzzEnd        begsr
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

740cA   if (hostopts = NetSuite
740cA    or hostoptint = NetSuite
740cA    or clienthost = NetSuite)
740cA    and BatID <> *blanks;
740cA     ApiNS.Whse = %editc($pwhse:'X');
740cA     ApiNS.Batch = BatId;
750 A     if partialPo;
740cA       ApiNS.Type = 'EXPPO     ';
750 A     else;
740cA       ApiNS.Type = 'EXPPOF    ';
750 A     endif;
740cA     IntApiNS(ApiNS.Whse: ApiNS.Batch: ApiNS.Type:
740cA              ApiNS.Ret: ApiNS.Msg);
740cA     if ApiNS.Ret <> '*OK';
740cA     endif;
740cA   endif;

      /end-free
     c                   endsr
