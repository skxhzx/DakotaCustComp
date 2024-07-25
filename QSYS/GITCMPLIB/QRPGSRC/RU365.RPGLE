     H option(*NODEBUGIO)
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   Glen Ellyn, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RU365     Runner Pick List - Print
     *  18 May 2004
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
417 A*    05/18/04  MLB  4.17
     *      - Created.
417aA*    09/23/04  MLB  4.17a
     *      - Added flexible custom mod logic.
     *
500 A*    03/31/05  MLB  5.00
     *      - Enh: Revised program to accept new command: *PRTOUT.
     *        "- Outs" will be added to end of report heading.
500aA*    07/10/05  MLB  5.00a
     *      - Enh: Revised program to accept new commands:
     *        *PRTMRG "- Merge" will be added to end of report heading.
     *        *RPNTOUT - Reprint Out Flag Runner report.
     *        *RPNTMRG - Reprint Merge Flag Runner report.
530a *    07/28/10  GJA  5.30a
     *      - Enh: Add employee for original transaction
640a *    02/10/12  LMC  6.40a
     *      - Enh: Added overflow slot information
700a *    01/18/16  GJA  7.00a
     *      - Enh: Only print overflow information when item changes
     *
710a *    07/12/17  TAB  7.10a
     *      - Enh: Added runner flag type in header of report
     *
710aA*    11/15/17  JCJ  7.10a
     *      - Enh: Added new stop/drop field.
     *
710bA*    12/19/17  RBD  7.10b
     *      - Enh: Added printing of potential sub items.
     *
720aA*    02/14/18  RBD  7.20a
     *      - FIX: Blank item sub strings.
720bA*    09/18/18  MLB  7.20b
     *      - Enh: Recompile pgm for change to increase P1STOP to 5,0
     *        from 3,0. Correct MCH1210 Rcver value too small to hold
     *        result. Stop numbers at Colony are 4 digits.
730aA*    09/15/19  RH   7.30a
     *      - ENH: Add Vendor item # to detail
730bA*    09/27/19  RH   7.30b
     *      - FIX: Add RHTRUK to print truck from RTEHED
     *        was only printing truck for Chefs.
730cA*    12/30/19  MLB  7.30c
     *      - Fix: Revised zovrslotinfo to retrieve SLOT2 record to
     *        verify that slot is an active slot when listing overflow
     *        slots for available product. Pgm was incorrectly listing
     *        quarantined slots in error. Found at Chef's Whse.
750aA*    12/21/21 RH    7.50a
     *      - Fix: Revised 730c mod to incude RP status slots.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRYa *    09/09/10  GJA  DRYa
     *      - Added truck number
     *
DRYb *    02/07/22  RBD  DRYb
     *      - Added door number.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: ISupplly
     *
ISPa *    01/26/16  GJA  ISPa
     *      - Take overflow out of report
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jordanos
     *
JDOa *    08/02/16  GJA  JDOa
     *      - Take overflow out of report
     *      - Added new detail line GSCDTL to print additional fields.
JDOb *    08/08/16  RH   JDOb
     *      - Changed to use JORDTL, added sub line
JDOc *    06/29/18  RH   JDOc
     *      - Fix: change breakdown pack description to match pick
     *        label (PFMT JDOc mod)
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Line
     *
CLD A*    09/23/04  MLB  CLD
     *      - Added new detail line CLDDTL to print additional fields.
CLDbA*    09/25/13  RH   CLDb
     *      - Do not print slot info detail line
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greco
     *
GRCaA*    05/02/19  DAS  GRC
     *      - Added new detail line GRCDTL to print additional fields.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Julius Silvert
     *
JSLa *    11/17/15  GJA  JSLa
     *      - Added new detail line CLDDTL to print additional fields.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Bros.
     *
CBI A*    07/08/08  MLB  CBI
     *      - Added new detail line CBIDTL to print additional fields.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: SeaShore
     *
SFPa *    08/15/19  GJA  SFPa
     *      - Added new detail line SFPDTL to print additional fields.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Grocery Supply
     *
GSC A*    01/14/06  JCJ  GSC
     *      - Added new detail line GSCDTL to print additional fields.
GSC1A*    02/10/06  MLB  GSC1
     *      - Added Grocery Supply to CLD mod identified above.
     *      - Revised program to load customer number for printing.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: European Imports
     *
EI  A*    05/10/06  MLB  EI
     *      - Added new detail line EIDTL to print additional fields.
     *      - Added file ORDDM to program with user controlled open.
EIa A*    05/24/06  MLB  EIa
     *      - Added new detail line EIDTL2 to print breakdown u/m
     *        entry field(s).
     *      - Added file OPTIONS to program to retrieve *RUNNER
     *        options.
EIb A*    06/01/06  MLB  EIb
     *      - Revised mod EI to print box number captured during
     *        selection, otherwise print entry line for box nbr.
     *      - Added file ORDBOX to program.
EIc A*    06/02/06  MLB  EIc
     *      - Revised program to write CLD mod that prints customer
     *        order nbr and seq# line on report.
     *      - Created new detail line, EIDTL3 that will print
     *        customer number / name on report.
     *
520 A*    02/05/09  CWM/MLB 5.20  01/29  02/04
     *      - Fix: Added support for new extended stop number
     *             Retrieve stop# in routine zzfgts pgm GETSTOP
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Springfield
     *
SGCaA*    06/03/09  GJA  SGCa
     *      - Added new detail line SGCDTL to print additional fields.
     *      - Added client processing
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: VIP Foodservice
     *
VIP A*    04/25/07  MLB  VIP
     *      - Revised program to retrieve item description for
     *        item# 9999999999 from ORDDM file.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Get Fresh Sales
     *
GFS A*    09/25/13  MLB  GFS
     *      - Revised program to write rcdfmt EIDTL3 that prints
     *        customer number / customer name on report.
     *      - Added GFS to EIc mod. (partial)
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cash Wa
     *
CWD A*    02/04/14  MLB  CWD
     *      - Revised program to write rcdfmt EIDTL3 that prints
     *        customer number / customer name on report.
     *      - Added CWD to GFS mod. (partial)
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: S Bertram
     *
SBR A*    02/01/16  MLB  SBR
     *      - Added new detail line CLDDTL to print additional fields.
     *      - Added customer order nbr and order line nbr to report.
     *      - Added SBR to CLD mod.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
EI  A*  40        Print Exp. Date entry line on report.
EI  A*  41        Print Box Nbr. entry line on report.
     *  79        Not on file/End of file indicator
     *  91        Overflow Indicator
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fru365a    ip   e           k disk
640aAflicactive2if   e           k disk
     Fordh      if   e           k disk
DRYaAFordhm2    if   e           k disk
EI  AForddm     if   e           k disk    usropn
EIa AFoptions   if   e           k disk
EIb AFordbox    if   e           k disk    usropn
     Fpiritem   if   e           k disk
     Fpirtran   if   e           k disk
     Fpiruser1  if   e           k disk
     Freports   if   e           k disk
     Frtehed    if   e           k disk
730cAFslot2     if   e           k disk
     Fwarehs    if   e           k disk
SFPaAFdocmtrx2  if   e           k disk
GSC AFordlbl3   if   e           k disk    usropn
     Fru365pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     D reck            s              7  0 dim(3)
     D lvlk            s              7  0 dim(3)
     D pcs             s              5  0 dim(3)
417 A*----------------------------------------------------------------
417 A*  Customer id
417 A*
417 AD/COPY QCOPYSRC,ID#CITYLIN
CBI AD/COPY QCOPYSRC,ID#CHENEY
GSC AD/COPY QCOPYSRC,ID#GSC
SGCaAD/COPY QCOPYSRC,ID#SGC
EI  AD/COPY QCOPYSRC,ID#EI
DRYaA /COPY QCOPYSRC,ID#Dairyla
VIP AD/COPY QCOPYSRC,ID#VIP
GFS A /COPY QCOPYSRC,ID#GFS
CWD A /COPY QCOPYSRC,ID#Cashwa
ISPaA /COPY QCOPYSRC,ID#ISUPPLY
JSLaA /COPY QCOPYSRC,ID#JSL
SBR A /COPY QCOPYSRC,ID#SBR
JDOaA /copy qcopysrc,id#jordano
GRCaA /copy qcopysrc,id#grc
SFPaA /copy qcopysrc,id#sfp
EIa A*
EIa A*----------------------------------------------------------------
EIa A*  *RUNNER  -  PIR Runner Flag Options
EIa A*----------------------------------------------------------------
EIa A*
EIa A* Fields
EIa A*
EIa A*    OPCRTM  -  Create Manual Runner entries for shorts/outs (Y/N)
EIa A*    OPUPLR  -  Update Label with quantity shorted during manual
EIa A*               flag entry (Y/N)
EIa A*               NOTE: Any change to this field will cause OPUPLV
EIa A*                     in the *VOICE options record to be updated.
EIa A*    OPRPLF  -  Replenish flagged items before print report? (Y/N)
EIa A*               & create Priority Replenishment if necessary.
EIa A*    OPMRGF  -  Create Runner entries for Merge records? (Y/N)
EIa A*    OPCLRF  -  Clear Runner flags if qty still short/out? (Y/N)
EIa A*    OPRNRM  -  Send break message to user when new Runner
EIa A*               task has been assigned. (Y/N)
EIa A*    OPCLSF  -  Update Label quantity at flag close (Y/N).
EIa A*    OPOUTF  -  Create Runner entry after slot marked out. (Y/N)
EIa A*    OPRPCK  -  Print Runner pick list. (Y/N)
EIa A*    OPRLBL  -  Print Runner pick labels. 0=No, 1=full size Zebra
EIa A*               printer, 2=Belt printer
EIa A*    OPRBDU  -  Allow shorts to be filled with breakdown units (Y/N).
EIa A*----------------------------------------------------------------
EIa A* Data structure
EIa A*
EIa AD oprdta          ds
EIa AD  opcrtm                 1      1
EIa AD  opuplr                 2      2
EIa AD  oprplf                 3      3
EIa AD  opmrgf                 4      4
EIa AD  opclrf                 5      5
EIa AD  oprnrm                 6      6
EIa AD  opclsf                 7      7
EIa AD  opoutf                 8      8
EIa AD  oprpck                 9      9
EIa AD  oprlbl                10     10
EIa AD  oprbdu                11     11
EIa AD  optendr              117    117

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
     D  $lwhdp                22     26
     *
     *----------------------------------------------------------------
     * Working variables
JDOcAD charpos         s              3  0
     D cwgts           s              7  0
640aAD forevr          s              1
     D hmsmdy          s             12  0
     D $plen           s              3  0
     D $pstr           s             60
     D l               s              1  0
     D m               s                   like(l)
JDOcAD strnglen        s              3  0
     D wgts            s              7  0
     D wkprtf          s             10
710bAD $iCmd           s             10
710bAD $iSubItm        s             15
710bAD $iRtn           s              8
710bAD $iErm           s             60
710bAD $iStr           s             72
VIP A*----------------------------------------------------------------
VIP A*  Re-definition of ORDDM Misc 1 - 5 fields.
VIP A*
VIP AD/copy qcopysrc,orddm1_vip
VIP A*
CBI  *----------------------------------------------------------------
CBI  *  Re-definition of OHMISC field.
CBI  *
CBI  D                 ds
CBI  D  ohdoor                13     14
JDObAD  ohsub                 20     20
CBI  D  ohmisc                 1     20
     *----------------------------------------------------------------
     * Catchweight Entry Fields.
     D Cwgthdr         c                   const('Catch weights')
     D wgtblank        c                   const('_____/___')
     *
     D wgtds           ds
     D p1wgt1                              overlay(wgtds : *next)
     D                                     like(wgtln)
     D p1wgt2                              overlay(wgtds : *next)
     D                                     like(wgtln)
     D p1wgt3                              overlay(wgtds : *next)
     D                                     like(wgtln)
     D p1wgt4                              overlay(wgtds : *next)
     D                                     like(wgtln)
     D p1wgt5                              overlay(wgtds : *next)
     D                                     like(wgtln)
     D p1wgt6                              overlay(wgtds : *next)
     D                                     like(wgtln)
     D wgtln                          9    overlay(wgtds:1) dim(6)
     *
     *----------------------------------------------------------------
     Ioqrec
     I                                          ruwhse        l2
     I                                          ruwhdp        l1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *PRINT   - Print Runner Pick List
500 A*              *PRTOUT  - Print Runner Pick List - Outs
500aA*              *PRTMRG  - Print Runner Pick List - Merge
     *              *REPRINT - Re-Print Runner Pick List
500aA*              *RPNTOUT - Re-Print Runner Pick List - Outs
500aA*              *RPNTMRG - Re-Print Runner Pick List - Merge
     *      $PWHSE  Warehouse number
     *      $PTRN#  Transaction number assigned to runner task
     *
     *    Returned Parameters
     *      *None
     *
     *----------------------------------------------------------------
     *
     C     *ENTRY        PLIST
     C                   parm                    $pcmd             8
     C                   parm                    $pwhse            3 0
     C                   parm                    $ptrn#            7 0
     *
     *  Report Heading
     *
     *
     C                   if        *in90  or
     C                             *inl1
     C                   exsr      zrzero
     *
     *
710aAC                   Eval      FGTYPE = *Blanks
710aAC                   Select
710aAC                   When      RUTYPE = 'U'
710aAC                   Eval      FGTYPE = 'OUT'
710aAC                   When      RUTYPE = 'B'
710aAC                   Eval      FGTYPE = 'BXB'
710aAC                   When      RUTYPE = 'R'
710aAC                   Eval      FGTYPE = 'RPL'
710aAC                   When      RUTYPE = 'M'
710aAC                   Eval      FGTYPE = 'MRG'
710aAC                   EndSL

     C                   exsr      zrhead
     C                   endif
     *
     *  Init total levels
     *
     *
     *  Level 1 break - Department
     *
     C                   if        *inl1
     C                   eval      l = 1
     *
     *         Get department description.
     *
     C                   eval      $lcmd  = '*VERIFY '
     C                   eval      $lwhse = ruwhse
     C                   eval      $lwhdp = ruwhdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                             or $lrtn = '*PGMQ   '
     *
     C                   endif
     C                   eval      p1whdp = ruwhdp
     C                   movel     $lerm         p1whds
     C                   endif
     *
     *  Output Headings
     *
     C                   if        *in91  or
     C                             *inl1
     C                   write     L1dept                               90
     C                   endif
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *
     *  Get Customer Route number.
     C     rhkey         chain     rtehed
     C                   if        not %found(rtehed)
     C                   eval      rhrte  = ' '
730bAC                   eval      tknbr  = *blanks
730bAC                   else
730bAC                   eval      tknbr  = rhtruk
     C                   endif
     *
     *  Get Customer Order number.
     C     ohkey         chain     ordh
     C                   if        not %found(ordh)
     C                   eval      ohcord = 0
710bAC                   eval      ohcust = 0
CBI AC                   if        client = cheney
CBI AC                   eval      ohmisc = ' '
CBI AC                   endif
     C                   endif
     *
     *  Get Item Master record.
     *
     C     itkey         chain     piritem
     C                   if        not %found(piritem)
     C                   eval      itdesc = ' '
     C                   eval      itpdsc = ' '
730aAC                   eval      itvit# = ' '
     C                   eval      itcwgt = 'N'
EIa AC                   eval      itflg1 = 'N'
EIa AC                   eval      itflg2 = 'N'
     C                   endif
     *
     *  Load detail line print fields - 1st detail line
700aAC                   eval      *in95 = *off
700aAC                   if        p1disp <> lbdisp
700aAC                   eval      *in95 = *on
700aAC                   endif
     C                   eval      p1disp = lbdisp
     C                   eval      p1item = lbitem
     C                   eval      p1desc = itdesc
     C                   eval      p1qyso = ruqyso
     C                   eval      p1ucod = lbucod
     *
     *  Load detail line print fields - 2nd detail line
     C                   eval      p1rte  = rhrte
520 AC                   exsr      zzfgts
520 AC                   if         $sstp > 0
520 AC                   eval      p1stop = $sstp
520 AC                   else
     C                   eval      p1stop = lbstop
520 AC                   endif
JDOcA*
JDOcA*      Normal item, picked Eaches. Convert item pack to 1.
JDOcA*
JDOcAC                   select
JDOcAC                   when      client = Jordanos
JDOcAC                   if        ittype = ' '
JDOcAC                             and lbutyp <> 'N'
JDOcAC                   eval      charpos = 0
JDOcAC     '/'           scan      itpdsc        charpos
JDOcAC                   if        charpos > 0
JDOcAC                   eval      strnglen= 16 - charpos
JDOcAC                   eval      itpdsc = '1'
JDOcAC                               + %subst(itpdsc:charpos:strnglen)
JDOcAC                   endif
JDOcAC                   endif
JDOcAC                   endsl
JDOcA*
     C                   eval      p1lbl# = rulbl#
     C                   eval      p1pdsc = itpdsc
730aAC                   eval      p1vit# = itvit#
     C                   eval      p1trn# = ruotrn
CLD  *
CLD  *  Load City Line Detail line fields - 3rd detail line.
CLD AC                   if        Client = Cityline
GSC1AC                             or Client = GSC
EIc AC                             or Client = EI
JSLaAC                             or Client = JSilvert
SBR AC                             or Client = SBertram
JDOaAC                             or Client = Jordanos
SFPaAC                             or Client = SFP
CLD AC                   eval      p1cord = ohcord
CLD AC                   eval      p1seq  = lbseq
CLD AC                   endif
SFPaA*
SFPaA*  Load SeaShore Detail line fields - Dock Door
SFPaAC                   if        Client = SFP
DRYbAC                             or client = Dairyland
SFPaAC     dckey         chain     docmtrx2
SFPaAC                   if        not %found(docmtrx2)
SFPaAC                   eval      dmdoor = *zeros
SFPaAC                   endif
SFPaAC                   endif
CBI  *
CBI  *  Load Cheney Bros. Detail line fields - 3rd detail line.
CBI AC                   if        Client = Cheney
CBI AC                   eval      p1door = ohdoor
CBI AC                   endif
JDOb *  Load Jordano's Sub
JDObAC                   if        Client = Jordanos
JDObAC                   eval      p1sub = ohsub
JDObAC                   endif
GSC A*
GSC A*  Load Grocery Supply Company. Detail line fields.
GSC AC                   if        Client = GSC
JDOaAC                             or Client = Jordanos
SFPaAC                             or Client = SFP
GSC AC     orkey         chain     ordlbl3
GSC AC                   if        not %found(ordlbl3)
GSC AC                   eval      alhtr# = *zeros
GSC AC                   endif
GSC AC                   eval      p1htr# = alhtr#
GSC AC                   eval      p1htr# = alhtr#
GSC1DC*                  eval      p1cord = ohcord
GSC1AC                   eval      p1cust = ohcust
GSC AC                   eval      p1cnam = ohcnam
GSC AC                   endif
EI  A*
EI  A*  Load European Imports. Detail line fields.
EI  AC                   if        Client = EI
EI  A*
EI  AC     omkey         chain     orddm
EI  AC                   if        not %found(orddm)
EI  AC                   eval      omcbox = 'N'
EI  AC                   eval      omcexp = 'N'
EI  AC                   endif
EIb A*
EIb A*      Retrieve Box Nbr captured during picking.
EIb AC     obkey         chain     ordbox
EIb AC                   if        not %found(ordbox)
EIb AC                   eval      obbox# = 0
EIb AC                   endif
EIb A*
EI  A*      Print Exp Date entry line.
EI  AC                   If        omcexp = 'Y'
EI  AC                   eval      *in40 = *on
EI  AC                   else
EI  AC                   eval      *in40 = *off
EI  AC                   endif
EI  A*      Print Box Nbr entry line.
EI  AC                   If        omcbox = 'Y'
EIb A*
EI  AC                   eval      *in41 = *on
EIb A*        If box nbr already captured, print on report.
EIb AC                   if        %found(ordbox)
EIb AC                   eval      p1box# = %trim(%editc(obbox#:'3'))
EIb AC                   else
EIb AC                   eval      p1box# = ' '
EIb AC                   endif
EIb A*
EI  AC                   else
EI  AC                   eval      *in41 = *off
EIb AC                   eval      p1box# = ' '
EI  AC                   endif
EI  A*
EI  AC                   endif
VIP AC                   if        Client = VIP
VIP AC                   exsr      zzgetom
VIP A*
VIP A*      Load item# 9999999999 description/pack size.
VIP AC                   if        Client = VIP
VIP AC                   if        lbitem = '9999999999'
VIP AC                   eval      p1desc = omodsc
VIP AC                   eval      p1pdsc = vipdm1_ompdsc
VIP AC                   endif
VIP AC                   endif
VIP A*
VIP AC                   endif
     *
     *  Check for page overflow.
     *
     C                   if        *in90 = *on
     C                   exsr      zrhead
     C                   write     L1dept                               90
     C                   endif
     *
530aAC     ruotrn        chain     pirtran
530aAC                   if        not %found(pirtran)
530aAC                   eval      ptemp# = 0
530aAC                   endif
     *
DRYaAC                   if        client = Dairyland
DRYaAC*   Retrieve Dairyland truck number.
DRYaAC     rhkey         chain     ordhm2
DRYaAC                   if        not %found(ordhm2)
DRYaAC                   eval      hmmsc1 = ' '
DRYaAC                   endif
DRYaAC                   eval      tknbr = %subst(hmmsc1:1:5)
DRYaAC                   endif
530aA*
530aA*   Get employee name assigned to transaction.
530aAC     ptemp#        chain     Piruser1
530aAC                   if        %found(Piruser1)
530aAC                   eval      p2empn = %trim(%editc(ptemp#:'4')) +
530aAC                             ' - ' + %trim(usfnam) +
530aAC                             ' ' + %trim(uslnam)
530aAC                   else
530aAC                   eval      p2empn = *blanks
530aAC                   endif
     *
     *
     *  Write detail line
     *
     C                   write     detail1
GRCaA*
GRCaA*  Write Greco detail
GRCaAC                   if        Client = Greco
GRCaAC                   eval      p1cord = ohcord
GRCaAC                   eval      p1txt55 = %char(ohcust) + ' ' + ohcnam
GRCaA*
GRCaAC                   if        *in90 = *on
GRCaAC                   exsr      zrhead
GRCaAC                   write     L1dept                               90
GRCaAC                   endif
GRCaAC                   write     GRCDTL                               90
GRCaA*
GRCaAC                   endif
GFS A*
GFS A*  Write European Imports Detail 3 for Get Fresh Sales
GFS AC                   if        Client = Getfresh
CWD AC                             or Client = Cashwa
GFS AC                   eval      p1cust = ohcust
GFS AC                   eval      p1cnam = ohcnam
GFS A*
GFS AC                   if        *in90 = *on
GFS AC                   exsr      zrhead
GFS AC                   write     L1dept                               90
GFS AC                   endif
GFS AC                   write     EIDtl3                               90
GFS A*
GFS AC                   endif
GFS A*
SFPaA *  Write Seashore Detail.
SFPaAC                   if        Client = SFP
SFPaAC                   if        *in90 = *on
SFPaAC                   exsr      zrhead
SFPaAC                   write     L1dept
SFPaAC                   endif
SFPaAC                   write     clddtl
SFPaAC                   if        *in90 = *on
SFPaAC                   exsr      zrhead
SFPaAC                   write     L1dept
SFPaAC                   endif
SFPaAC                   write     sfpdtl
SFPaAC                   endif

DRYbA*  Write Dairyland dock door.
DRYbAC                   if        client = Dairyland
DRYbAC                   if        *in90 = *on
DRYbAC                   exsr      zrhead
DRYbAC                   write     L1dept
DRYbAC                   endif
DRYbAC                   write     drydtl
DRYbAC                   endif

700aAc                   if        *in95
CLDbAC                   if        Client <> Cityline
ISPaAc                             and client <> ISupply
JDOaAc                             and client <> Jordanos
640aAc                   exsr      zovrslotinfo
ISPaAc                   endif
700aAc                   endif
EIa A*
EIa A*  Write European Imports Detail 2.
EIa AC                   if        Client = EI
EIa A*
EIa A*    Allow breakdown qty(s) to be entered for shorts.
EIa AC                   if        oprbdu = 'Y'
EIa A*
EIa A*      Ordered full unit - and -
EIa A*        Print breakdown 1 is allowed.
EIa AC                   if        lbutyp = 'N'
EIa AC                             and itflg1 = 'Y'
EIa AC                   eval      p1ucod = itum2
EIa AC                   exsr      zrbrkdwn
EIa AC                   endif
EIa A*      Ordered full unit - and -
EIa A*        Print breakdown 2 is allowed.
EIa AC                   if        lbutyp = 'N'
EIa AC                             and itflg1 = 'Y'
EIa AC                             and itflg2 = 'Y'
EIa A*      Ordered Breakdown 1 unit - and -
EIa A*        Print breakdown 2 is allowed.
EIa AC                             or lbutyp = '1'
EIa AC                             and itflg2 = 'Y'
EIa AC                   eval      p1ucod = itum3
EIa AC                   exsr      zrbrkdwn
EIa AC                   endif
EIa AC                   endif
EIa A*
EIa AC                   endif
CLD A*
CLD A*  Write City Line Detail.
CLD AC                   if        Client = Cityline
GSC1AC                             or Client = GSC
EIc AC                             or Client = EI
JSLaAC                             or Client = JSilvert
SBR AC                             or Client = SBertram
CLD AC                   if        *in90 = *on
CLD AC                   exsr      zrhead
CLD AC                   write     L1dept                               90
CLD AC                   endif
CLD AC                   write     clddtl                               90
CLD AC                   endif
EIc A*
SGCaA*  Write Springfield Detail.
SGCaAC                   if        Client = SGC
SGCa C                   if        *in90 = *on
SGCa C                   exsr      zrhead
SGCa C                   write     L1dept                               90
SGCa C                   endif
SGCa C     ruotrn        chain     pirtran
SGCa C                   if        not %found(pirtran)
SGCa C                   eval      ptemp# = 0
SGCa C                   endif
SGCa *
SGCa *   Get employee name assigned to transaction.
SGCa C     ptemp#        chain     Piruser1
SGCa C                   if        not %found(Piruser1)
SGCa C                   eval      uscode = ' '
SGCa C                   eval      usfnam = ' '
SGCa C                   eval      uslnam = ' '
SGCa C                   endif
SGCa *
SGCa C                   eval      sgcnm = %trim(%editc(ptemp#:'4')) +
SGCa C                             ' - ' + %trim(usfnam) +
SGCa C                             ' ' + %trim(uslnam)
SGCa C                   write     sgcdtl                               90
SGCa C                   endif
EIc A*
EIc A*  Write European Imports Detail 3.
EIc AC                   if        Client = EI
CWD AC                             or Client = Cashwa
EIc AC                   eval      p1cust = ohcust
EIc AC                   eval      p1cnam = ohcnam
EIc A*
EIc AC                   if        *in90 = *on
EIc AC                   exsr      zrhead
EIc AC                   write     L1dept                               90
EIc AC                   endif
EIc AC                   write     EIDtl3                               90
EIc A*
EIc AC                   endif
CBI A*
CBI A*  Write Cheney Bros. Detail.
CBI AC                   if        Client = Cheney
CBI AC                   if        *in90 = *on
CBI AC                   exsr      zrhead
CBI AC                   write     L1dept                               90
CBI AC                   endif
CBI AC                   write     cbidtl                               90
CBI AC                   endif
GSC A*
GSC A*  Write Grocery Supply Company Detail.
GSC AC                   if        Client = GSC
JDObDC*                            or Client = Jordanos
GSC AC                   if        *in90 = *on
GSC AC                   exsr      zrhead
GSC AC                   write     L1dept                               90
GSC AC                   endif
GSC AC                   write     gscdtl                               90
GSC AC                   endif
JDObA*  Write Jordano's Detail.
JDObAC                   if        Client = Jordanos
JDObAC                   if        *in90 = *on
JDObAC                   exsr      zrhead
JDObAC                   write     L1dept                               90
JDObAC                   endif
JDObAC                   write     jdodtl                               90
JDObAC                   endif
EI  A*
EI  A*  Write Grocery Supply Company Detail.
EI  AC                   if        Client = EI
EI  AC                   if        *in90 = *on
EI  AC                   exsr      zrhead
EI  AC                   write     L1dept                               90
EI  AC                   endif
EI  AC                   write     eidtl                                90
EI  AC                   endif

710bA*    Get string of item subs
710bA
710bAC                   eval      $iCmd = '*GETSTRING'
720aAC                   eval      $iStr = ' '
720aAC                   eval      p1subs = ' '
710bAC                   call      'GETITEMSUB'
710bAC                   parm                    $iCmd
710bAC                   parm                    $pWhse
710bAC                   parm                    lbitem
710bAC                   parm                    ohcust
710bAC                   parm                    $iSubItm
710bAC                   parm                    $iRtn
710bAC                   parm                    $iErm
710bAC                   parm                    $iStr
710bAC                   if        $iRtn <> '*ERROR'
710bAC                   eval      p1Subs = $iStr
710bAC                   write     subDtl
710bAC                   endif
     *
     *  If catchweight item, print weight entry boxes.
     *
     C                   if        itcwgt = 'Y'
     C                   exsr      zrcwgt
     C                   endif
     *
     *  Accumulate totals
     *
     C                   add       ruqyso        pcs(1)
     *
     *  Increment record counters
     *
     C                   add       1             reck(1)
     C                   add       1             lvlk(1)
     *
     *  Set off top-of-page indicators
     *
     C                   eval      *in92 = *off
     C                   eval      *in91 = *off
     *----------------------------------------------------------------
     *
     * Department totals
     *
     CL1                 eval      l = 1
     CL1                 exsr      zrroll
     *
     CL1                 if        reck(l) > 0
     CL1                 if        *in90 = *on
     CL1                 exsr      zrhead
     CL1                 endif
     CL1                 write     skip1
     CL1                 exsr      zrtotl
     CL1                 endif
     *----------------------------------------------------------------
     *
     * REPORT TOTALS
     *
     CLr                 eval      l = 2
     *
     CLr                 if        reck(l) > 0
     CLr                 if        *in90 = *on
     CLr                 exsr      zrhead
     CLr                 endif
     CLr                 write     skip1
     CLr                 exsr      zrtotl
     CLr                 write     foot1
     CLr                 endif
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
417 A*
417 AC                   call      'GETCLIENT'
417 AC                   parm      *blanks       Client           10
     *
     *   Full PIRITEM key
     *
     C     itkey         klist
     C                   kfld                    ruwhse
     C                   kfld                    lbitem
SFPaA *
SFPaAC     dckey         klist
SFPaAC                   kfld                    lbwhse
SFPaAC                   kfld                    lbrte
EIa A*
EIa A*  Define key for OPTIONS file.
EIa A*
EIa AC     opkey         klist
EIa AC                   kfld                    $pwhse
EIa AC                   kfld                    opcode
     *
     *   Full REPORTS key
     C     rpkey         klist
     C                   kfld                    wkprtf
     *
     *   Full RTEHED key
     C     rhkey         klist
     C                   kfld                    ruwhse
     C                   kfld                    lbrte
730cA*
730cA*   Full SLOT2 key
730cA*
730cAC     slkey2        klist
730cAC                   kfld                    ruwhse
730cAC                   kfld                    lawhdp
730cAC                   kfld                    ladisp
     *
     *   Full ORDH key
     C     ohkey         klist
     C                   kfld                    ruwhse
     C                   kfld                    lbord
GSC A*
GSC A*   Partial ORDLBL3 Key
GSC AC     orkey         klist
GSC AC                   kfld                    ruwhse
GSC AC                   kfld                    ruotrn
EI  A*
EI  A*   Full ORDDM key
EI  AC     omkey         klist
EI  AC                   kfld                    ruwhse
EI  AC                   kfld                    lbord
EI  AC                   kfld                    lbseq
EI  AC                   kfld                    lbitem
EIb A*
EIb A*   Full ORDBOX key
EIb AC     obkey         klist
EIb AC                   kfld                    ruwhse
EIb AC                   kfld                    lbord
EIb AC                   kfld                    lbseq
EIb AC                   kfld                    lbitem
EIb AC                   kfld                    lblbl#
     *
     *   Get report title.
     *
     C                   movel     'RU365PR '    wkprtf
     C     rpkey         chain     reports
     C                   if        %found
     C                   movel     rpdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
500 A*
500 A*   Update title when printing Outs report.
500aA*   and Merge report.
500aAC                   select
500 AC                   when      $pcmd = '*PRTOUT'
500aAC                             or $pcmd = '*RPNTOUT'
500 AC                   eval      $pstr = %trim($pstr) + '- Outs'
500aA*
500aAC                   when      $pcmd = '*PRTMRG'
500aAC                             or $pcmd = '*RPNTMRG'
500aAC                   eval      $pstr = %trim($pstr) + '- Merge'
500aAC                   endsl
500 A*
     C                   eval      $plen = 40
     *
     *   Center report title.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         rptttl
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs
     C                   if        %found
500aDC*                  movel     whdesc        $pstr
500aMC                   movel (p) whdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
500 DC*                  eval      $plen = 30
500 MC                   eval      $plen = 40
     *
     *   Center warehouse description.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         whse
     *
     C     $ptrn#        chain     pirtran
     C                   if        not %found(pirtran)
     C                   eval      ptemp# = 0
     C                   endif
     C                   eval      tran#  = $ptrn#
     *
     *   Get employee name assigned to transaction.
     C     ptemp#        chain     Piruser1
     C                   if        not %found(Piruser1)
     C                   eval      uscode = ' '
     C                   eval      usfnam = ' '
     C                   eval      uslnam = ' '
     C                   endif
     *
     C                   eval      empnm = %trim(%editc(ptemp#:'4')) +
     C                             ' - ' + %trim(usfnam) +
     C                             ' ' + %trim(uslnam)
     *
     C                   eval      *in90 = *on
     C                   time                    hmsmdy
     C                   movel     hmsmdy        rtime
     C                   move      hmsmdy        rdate
     *
     C                   if        $pcmd = '*REPRINT'
500aAC                             or $pcmd = '*RPNTOUT'
500aAC                             or $pcmd = '*RPNTMRG'
     C                   eval      reprnt = '*Reprint*'
     C                   endif
     *
     C                   eval      l = 3
     C                   exsr      zrzero
     *
GSC AC                   if        client = GSC
JDOAAC                             OR client = Jordanos
SFPaAC                             OR client = SFP
GSC AC                   if        not %open(ordlbl3)
GSC AC                   open      ordlbl3
GSC AC                   endif
GSC AC                   endif
     *
EI  AC                   if        client = EI
VIP AC                             or client = VIP
EI  AC                   if        not %open(orddm)
EI  AC                   open      orddm
EI  AC                   endif
VIP AC                   endif
VIP AC                   if        client = EI
EIb AC                   if        not %open(ordbox)
EIb AC                   open      ordbox
EIb AC                   endif
EI  AC                   endif
EIa A*
EIa A*      Retrieve *RUNNER options record.
EIa AC                   exsr      zzgetruop

     C                   endsr
640aA*
640aA*----------------------------------------------------------------
640aA*
640aA* Print Breakdown u/m entry line.
640aA*
640aAC     zovrslotinfo  begsr
640aAc     itkey         setll     licactive2
640aA
640aAC                   dow       forevr = forevr
640aAC     itkey         reade     licactive2
640aAC                   if        %eof(licactive2)
640aAC                   leave
640aAC                   endif
640aA* Does license have inventory
640aAc                   Select
640aAc                   when      laqty1 > 0   or
640aAc                             laqty2 > 0   or
640aAc                             laqty3 > 0
640aA*
730cA* Skip printing if slot not found or slot not active.
730cAC     slkey2        chain     slot2
730cAC                   if        not %found(slot2)
730cAC                              or %found(slot2)
730cAC                             and slstat <> 'A '
750aAC                             and slstat <> 'RP'
730cAC                   iter
730cAC                   endif
730cA*
640aAC                   eval      $lcmd = '*QTY2STR'
640aAC                   eval      $lqty1 = laqty1
640aAC                   eval      $lqty2 = laqty2
640aAC                   eval      $lqty3 = laqty3
640aAC                   eval      $lqstr = *blanks
640aA*
640aAC                   call      'CVTQTY'
640aAC                   parm                    $lcmd
640aAC                   parm                    $lprg
640aAC                   parm                    $lqty1            7 0
640aAC                   parm                    $lqty2            7 0
640aAC                   parm                    $lqty3            7 0
640aAC                   parm                    $lum1             2
640aAC                   parm                    $lum2             2
640aAC                   parm                    $lum3             2
640aAC                   parm                    $lqstr           10
640aAC                   parm                    $lustr           17
640aAC                   parm                    $lrtn
640aAC                   parm                    $lerm
640aA*
640aAC                   eval      slotinv = $lqstr
640aAc
640aAc                   write     slotinfo
640aAc                   endsl
640aA
640aAc                   enddo
640aA*
640aAC                   endsr
EIa A*
EIa A*----------------------------------------------------------------
EIa A*
EIa A* Print Breakdown u/m entry line.
EIa A*
EIa AC     zrbrkdwn      begsr
EIa A*
EIa AC                   if        *in90 = *on
EIa AC                   exsr      zrhead
EIa AC                   write     L1dept                               90
EIa AC                   endif
EIa AC                   write     eidtl2                               90
EIa A*
EIa AC                   endsr
     *
     *----------------------------------------------------------------
     *
     * Print Catchweight entry boxes based on qty we are short/out.
     *
     C     zrcwgt        begsr
     *
     C                   eval      cwgts = ruqyso
     C                   eval      wgtln = ' '
     *
     *   Initialize print field with heading.
     C                   eval      p1wgttxt = cwgthdr
     C                   eval      wgts  = 0
     *
     C                   dou       cwgts = 0
     *
     C                   eval      wgts = wgts + 1
     C                   eval      wgtln(wgts) = wgtblank
     *
     *   Catchweight line has been filled. Print line.
     C                   if        wgts = 6
     *
     *   Page overflow. Print headings.
     C                   if        *in90 = *on
     C                   exsr      zrhead
     C                   write     l1dept                               90
     C                   endif
     *
     C                   write     catwgt1                              90
     *   Clear array pointer.
     C                   eval      wgts = 0
     *   Clear line heading.
     C                   eval      p1wgttxt = ' '
     *   Clear weight line array.
     C                   eval      wgtln    = ' '
     C                   endif
     *
     C                   eval      cwgts = cwgts - 1
     *
     C                   enddo
     *
     *   Partial line left to print.
     C                   if        wgts > 0
     *
     *   Page overflow on.
     C                   if        *in90 = *on
     C                   exsr      zrhead
     C                   write     l1dept                               90
     C                   endif
     *
     C                   write     catwgt1                              90
     C                   endif
     *
     *   Add blank line after catchwgt line.
     C                   write     skip1                                90
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     C                   if        not *inl1
     C                   eval      *in91 = *on
     C                   endif
     *
     C                   eval      *in90 = *off
     C                   write     head1                                90
     C                   write     head2                                90
     C                   write     columns                              90
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrroll        begsr
     *
     C     l             add       1             m
     *
     C                   add       1             lvlk(m)
     C                   add       reck(l)       reck(m)
     *
     C                   add       pcs(l)        pcs(m)
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrtotl        begsr
     *
     *
     C                   if        l = 1
     C                   eval      t1qyso = pcs(l)
     C                   write     total1                               90
     C                   endif
     *
     C                   if        l = 2
     C                   eval      t2qyso = pcs(l)
     C                   write     total2
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrzero        begsr
     *
     C                   eval      lvlk(l) = 0
     C                   eval      reck(l) = 0
     *
     C                   eval      pcs(l) = 0
     *
     C                   endsr
     C*----------------------------------------------------------------
     C*
520 AC*  ZZFGTS   Get Host Stop Number
520 AC*
520 AC     ZZFGTS        BEGSR
520 AC*
520 AC*    Get Stop From RTESTP
520 AC*
520 AC                   CALL      'GETSTOP'
520 MC                   PARM      '*ORDSTP '    $SCMD             8
520 MC                   PARM      RUWHSE        $SWHSE            3 0
520 MC                   PARM      LBRTE         $SRTID            5
520 MC                   PARM      LBORD         $sord             7 0
520 MC                   PARM      0             $SDSTP            2 0
520 MC                   PARM                    $sSTP             5 0
710aAc                   parm                    $pDdrop           3
710aAc                   parm                    $pDextd          30
710aAc                   parm                    $pDsd             9
520 AC*
520 AC                   ENDSR
VIP A*
VIP A*----------------------------------------------------------------
VIP A*
VIP A*  ZZGETOM  Get Order Detail Misc. record.
VIP A*
VIP AC     zzgetom       begsr
VIP A*
EI  AC     omkey         chain     orddm
EI  AC                   if        not %found(orddm)
VIP AC                   eval      omodsc = ' '
EI  AC                   eval      omcbox = 'N'
EI  AC                   eval      omcexp = 'N'
VIP AC                   select
VIP AC                   when      client = VIP
VIP AC                   eval      vipdm1_base   = ' '
VIP AC                   eval      vipdm1_ompckm = 0
VIP AC                   eval      vipdm1_omwtiw = 0
VIP AC                   eval      vipdm1_omcbec = 0
VIP AC                   endsl
VIP A*
VIP AC                   else
VIP A*
VIP AC                   select
VIP AC                   when      client = VIP
VIP AC                   eval      vipdm1_base = ommsc1
VIP AC                   endsl
EI  AC                   endif
VIP A*
VIP AC                   endsr
EIa A*
EIa A*----------------------------------------------------------------
EIa A*
EIa A*  ZZGETRUOP  Get Runner Options record.
EIa A*
EIa AC     zzgetruop     begsr
EIa A*
EIa AC                   eval      opcode = '*RUNNER '
EIa A*
EIa AC     opkey         chain     options
EIa AC                   if        not %found(options)
EIa AC                   eval      oprbdu = 'N'
EIa AC                   else
EIa AC                   movel     opdata        oprdta
EIa AC                   endif
EIa A*
EIa AC                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
