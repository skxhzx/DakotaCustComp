     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IT736     FTP Export item quantities - Post
     *  05 July 1999
     *  Dave Sommerville
     *
     *  This program should be identical to IT735 except that it uses
     *  the EXPFQTY file that is overridden in IT736CL.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
416 A*   12/26/01  DAS  4.16
     *     - Added fields to export file.
     *
417 A*   02/13/04  MLB  4.17
     *     - Enh: Removed check for expired slots. All pick slots
     *       will be exported even if slot is expired.
     *
500 A*   03/15/05  MLB  5.00
     *     - Enh: Added custom client code support to program.
     *
610 A*   05/25/10  MLB  6.10
     *     - Enh: Revised program to skip slots with SLDESG = BFC.
     *       Slots with designation = BFC are internal use slots.
     *
640 A*   08/18/11  MLB  6.40
     *     - Enh: Converted program to ILE.
     *     - Note: All IL#xxxxxxx converted to ID#xxxxxxx.
640aA*   08/18/11  MLB  6.40a  P#01049
     *     - Enh: Added DRI interface program support to pgm.
640bA*   08/18/11  MLB  6.40b  P#01049
     *     - Enh: Added new export file to program, EXPFLCNS which will
     *       be used to export active license info to Host.
     *     - Added LICACTIVE to pgm.
     *     - Added DRI license support to program.
640cA*   09/27/11  MLB  6.40c  P#01049
     *      - Enh: Revised pgm to update 2 new fields. ELAENT - License
     *        Entered Date and ELAEXP - License Expiration Date added
     *        to EXPFLCNS.
640dA*   10/18/11  MLB  6.40d
     *      - Enh: Enhancement to 6.40c mod. Added exception report to
     *        list any items where the slot stock qty and the license
     *        qty's do not match up.
     *      - Added file WAREHS to pgm.
640eA*   10/23/11  MLB  6.40e
     *      - Enh: Enhancement to 6.40d mod. If no license plate records
     *        are found for a slot, call LT001 with cmd FIX to create
     *        *FX license plate for slot/qty. Then reset and re-read
     *        LICACTTIVE5 to send newly created license to Host.
640fA*   01/05/11  MLB  6.40f
     *      - Enh: Added 1 new field to file, EXPFLCNS. Added slot status
     *        end end of record format.
     *
650 A*   12/12/13  MLB  6.50
     *      - Fix: Corrected client custom code for Greenleaf, Coastal
     *        that added support for exporting Alias items.
650aA*   03/21/13  KDE  6.50a
     *      - Enh: Added the ability to have more than one component  tus
     *        item on a Repack Item.  This required a loop and the
     *        moving of some code from the mainline to a subroutine
730a *   01/19/19  RTR  7.30a
     *      - Enh: Added OPTIONINT values for BIR mod to send overflow
     *        and CSP mod to send base for virtuals.
730b *   11/06/18  RTR  7.30b
     *      - Enh: Added file LASTPICK to store previous and only send
     *        changes. Some hosts only use for pick updates. Controlled
     *        via OPTIONINT flag Interfaces|Export Qty|Only Pick Changes.
     *
750 A*   07/19/21  MLB  7.50
     *      - Enh: Added missing 7.30a mods to pgm.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Andrews
     *
AFS A*   04/29/04  MLB  AFS
     *     - Enh: Revised program to allow Alias item types to be
     *       processed ans sent back to host.
     *----------------------------------------------------------------
     *  Client Custom Revisions: BiRite
     *
BIR A*   02/03/05  MLB  BIR
     *     - Enh: Revised program to look for overflow slots if no
     *       pick slots are found for item.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jordanos
     *
JOR A*   12/23/08  MLB  JOR
     *     - Enh: Revised program to skip all pick slots at Zero
     *       status.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Donson's
     *
DON A*   03/15/05  MLB  DON
     *     - Revised GETPCK to remove '-' from slot display when
     *       updating QEDSP1. From: R-26-22 To: R2622.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: USF - Allen Foods
     *
ALN A*   01/10/07  MLB  ALN
     *     - Added USF-Allen to BIR mod listed above.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval
     *
SVLaA*   09/01/09  RH   SVLa
     *     - Enh: Revised program to export type 'S' qty brk qty field
     *       of parent item.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Capitol City Produce
     *
CCP A*   05/10/10  MLB  CCP
     *     - Enh: Revised program to export type 'R' items quantity
     *       onhand converted to full cases. Eaches left over are not
     *       included. Qty is added to parent item full case qty.
     *     - Added file KITCOMP.
CCPaA*   05/10/10  MLB  CCPa
     *     - Enh: Revised program to allow type 'B and 'R' items to
     *       be written into the export file to be used to update the
     *       pick slot info on the Host system.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt Produce
     *
CSP A*   05/25/10  MLB  CSP
     *     - Enh: Revised program to look for overflow slots if no
     *       pick slots are found for item. Per Roxanne. On-Site.
CSPaA*   05/25/10  MLB  CSPa
     *     - Enh: Revised program to send 74-111-1 for items with item
     *       designation of JIT if no slot(s) found for item.
CSPbA*   05/25/10  MLB  CSPb
     *     - Enh: Revised program to send BRKN for pick slot when
     *       item designation is BRKN or slot 63-200-1.
     *     - Added VSLOT1 to program.
CSPcA*   05/26/10  MLB  CSPc
     *     - Enh: Revised program to allow Alias items to be exported.
     *       Send base item pick slot for Alias item.
CSPdA*   08/24/10  MLB  CSPd
     *     - Enh: Revised program to retrieve pick slot for JIT repack
     *       items using call to pgm GETITMFLD.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: European Imports
     *
EI  A*   08/19/11  MLB  EI   p#01049
     *     - Enh: Revised program to build lot code from p/o number and
     *       p/o sequence number and populate ELALOT field.
EIa A*   11/09/11  RH   EIa  # 1056
     *     - Enh: Revised program to call IT736A to export record     d
     *       for orders picked but not exported.                      d
EIb A*   01/22/13  LMC  EIb
     *     - Fix: Exsr ZZEXPLCNS for European Imports only.           d
     *       for orders picked but not exported.                      d
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greenleaf Produce
     *
GLP A*   04/25/13  MLB  GLP
     *     - Enh: Revised program to look for overflow slots if no
     *       pick slots are found for item.
     *     - Added GLP to BIR mod.
GLPaA*   04/25/13  MLB  GLPa
     *     - Enh: Revised program to allow type 'B and 'R' items to
     *       be written into the export file to be used to update the
     *       pick slot info on the Host system.
     *     - Added GLPa to CCPa mod.
GLPbA*   04/25/13  MLB  GLPb
     *     - Enh: Revised program to retrieve base slot for virtual
     *       slots.
     *     - Added GLPb to CSPb mod.
GLPcA*   04/25/13  MLB  GLPc
     *     - Enh: Revised program to allow Alias items to be exported.
     *       Send base item pick slot for Alias item.
     *     - Added GLPc to CSPc mod.
GLPdA*   08/23/13  MLB  GLPd
     *     - Enh: Revised program to retrieve pick slot for ODR repack
     *       items.
     *     - Added GLPd to CSP mod to open KITCOMP file.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cash Wa Distributing
     *
CWD A*   04/26/13  MLB  CWD
     *     - Enh: Revised program to load ITWHDP into QECITM per Scott W.
CWDaA*   04/26/13  MLB  CWDa
     *     - Enh: Revised program to load check digits for first slot
     *       into fields QETI1, QETI2 and QETI3.
     *     - Added files: SLOTDGT, SLOTDGTA to pgm.
CWDbA*   04/26/13  MLB  CWDb
     *     - Enh: Revised program to retrieve base slot for virtual
     *       slots.
     *     - Added CWDb to CSPb mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Get Fresh Sales
     *
GFS A*   02/07/13  MLB  GFS
     *     - Enh: Revised program to receive additional parm, $pcmpid.
     *       Omit all itms that the first character of ITITEM <> $pcmpid.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: SoFo Foods
     *
SOF A*   04/18/09  MLB  SOF
     *     - Enh: Revised program to look for overflow slots if no
     *       pick slots are found for item.
SOFaA*   01/06/14  MLB  SOFa
     *     - Enh: Revised program to omit items where category code
     *       does not match, if $pcat <> *ALL.
     *     - Added ITEMFLD to pgm.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: H&M Wagner
     *
HMWa *   01/19/16  RTR  HMWa
     *     - Enh: Revised program to not export items with zero on-hand.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Presto Foods
     *
PFC A*   05/16/17  MLB  PFC
     *     - Enh: Revised program to allow Alias items to be exported.
     *       Send base item pick slot for Alias item.
     *     - Added PFC to CSPc mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: SGC Foodservice
     *
SGC A*   11/27/16  MLB  SGC
     *     - Enh: Revised program to look for overflow slots if no
     *       pick slots are found for item.
     *     - Added SGC to BIR mod.
SGCaA*   11/27/16  MLB  SGCa
     *     - Enh: Revised program to retrieve base slot for virtual
     *       slots.
     *     - Added SGCa to CSPb mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Southwest Traders
     *
SWTa *   02/20/19  RTR  SWTa
     *     - Enh: If exp date = 0, use entered date plus 3 years.
SWTb *   02/25/19  RTR  SWTb
     *     - Enh: If desination = non-stock, skip item.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
CSPbA*  74        NRF on chain to VSLOT1
     *  79        CHAIN INDICATOR
     *  90        OVERFLOW INDICATOR FOR EXCEPTION REPORT
     *  91        OVERFLOW INDICATOR FOR CATCH WEIGHT REPORT
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpiritem   if   e           k disk
     Fpiritem1  if   e           k disk
     F                                     rename(itrec:itrec1)
IFC  Fpiritem3  if   e           k disk
IFC  F                                     rename(itrec:itrec3) prefix(i3_)
     Fitemqty   if   e           k disk
     Fitemlnk   if   e           k disk
SOFaAFITEMFLD   IF   E           K DISK    usropn
CCP AFkitcomp   if   e           k disk    usropn
640aAFlicactive5if   e           k disk
     Fslot3     if   e           k disk
CSPbAFvslot1    if   e           k disk
416 AFitemdef   if   e           k disk
416 AFslotdef   if   e           k disk
CWDaAFslotdgt   if   e           k disk    usropn
CWDaAFslotdgta  if   e           k disk    usropn
CCP D*EXPFQTY O   E           K        DISK                      A
CCP MFexpfqty   uf a e           k disk
640bAFexpflcns  uf a e           k disk
640dAFwarehs    if   e           k disk
640dAFit736pr   o    e             printer oflind(*in90)
640dAF                                     usropn
730bAflastpick  uf a e           k disk
640aA
640aA*----------------------------------------------------------------
640aA*  DRI parameters
640aA*----------------------------------------------------------------
640aA
640aA /COPY *libl/qcopysrc,C#DRIPARMS
640aA
640aA*----------------------------------------------------------------
640aA*  Data Formats
640aA*----------------------------------------------------------------
640aA
640aA /COPY *libl/qcopysrc,C#ITEM
640aA /COPY *libl/qcopysrc,C#SLOT
640aA /COPY *libl/qcopysrc,C#LICENSE
640aA /COPY *libl/qcopysrc,C#LICINFO
640aA
500 A*----------------------------------------------------------------
500 A*  Client id's for custom mods.
500 A*----------------------------------------------------------------
500 AD/COPY QCOPYSRC,ID#DONSONS
BIR A /COPY QCOPYSRC,ID#BIRITE
ALN AD/COPY QCOPYSRC,ID#ALLEN
SVLaA /COPY QCOPYSRC,ID#SAVAL
CCP A /COPY QCOPYSRC,ID#CAPITOL
CSP A /COPY QCOPYSRC,ID#COASTAL
EI AA /COPY QCOPYSRC,ID#EI
GLP A /COPY QCOPYSRC,ID#GLP
CWD A /COPY QCOPYSRC,ID#CASHWA
GFS A /COPY QCOPYSRC,ID#GFS
JOR A /COPY QCOPYSRC,ID#JORDANO
AFS A /COPY QCOPYSRC,ID#ANDREWS
SOF A /COPY QCOPYSRC,ID#SOFO
HMWaA /COPY QCOPYSRC,ID#HMWAGNE
PFC A /COPY QCOPYSRC,ID#PFC
SGC A /COPY QCOPYSRC,ID#SGC
SWTaA /copy qcopysrc,id#swt
500 AD                 ds
500 AD  client                 1     10
     D @getcl          c                   const('GETCLIENT')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @itmfl          c                   const('GETITEMFLD')
730bA /copy *libl/qcopysrc,p.getopint

DON A*----------------------------------------------------------------
DON A*  Working variables
DON A*
640aAD chk4err         s               n
640aAD error           s               n
750 Ad optExpLcns      s               n
640aAD zmsflag         s               n
640aAD savever#        s                   like($slver#)
640dAD SltQty          s              7  0 inz
640dAD LicQty          s              7  0 inz
640eAD nbrlicense      s              7  0 inz
GLPdAD repackalias     s              1    inz('0')
640eAD tryonce         s              1    inz('0')
640dAD wkqty           s                   like(slstk1)
DON AD                 ds
DON AD  aisle                  1      1
DON AD  loc                    2      3
DON AD  lvlhnd                 4      5
DON AD  donslt                 1      5
CCP AD                 ds
CCP AD  extqty                 1      7  0
CCP AD  whlcas                 8     14  0

650aAdsavExpF          ds
650aAd savwhse                             like(qewhse)
650aAd savitem                             like(qeitem)
650aAd savtype                             like(qetype)
650aAd savbitm                             like(qebitm)
650aAd savcitm                             like(qecitm)
650aAd savrflg                             like(qerflg)
650aAd savstk1                             like(qestk1)
650aAd savstk2                             like(qestk2)
650aAd savstk3                             like(qestk3)
650aAd savdsp1                             like(qedsp1)
650aAd savdsp2                             like(qedsp2)
650aAd savdsp3                             like(qedsp3)
650aAd savdate                             like(qedate)
650aAd savtime                             like(qetime)
650aAd savcube                             like(qecube)
650aAd savsdf1                             like(qesdf1)
650aAd savpal1                             like(qepal1)
650aAd savpos1                             like(qepos1)
650aAd savti1                              like(qeti1)
650aAd savhi1                              like(qehi1)
650aAd savsdf2                             like(qesdf2)
650aAd savpal2                             like(qepal2)
650aAd savpos2                             like(qepos2)
650aAd savti2                              like(qeti2)
650aAd savhi2                              like(qehi2)
650aAd savsdf3                             like(qesdf3)
650aAd savpal3                             like(qepal3)
650aAd savpos3                             like(qepos3)
650aAd savti3                              like(qeti3)
650aAd savhi3                              like(qehi3)
DON A*----------------------------------------------------------------
     *  Called program parameters
     *
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
640 A*----------------------------------------------------------------
640 A*  Working variables
640 A*
640 AD $pwhse          s              3  0
640 AD forevr          s              1
640 AD kyitem          s                   like(slitem)
640 AD kypick          s                   like(slpick)
640 AD kystat          s                   like(slstat)
640 AD opnkit          s              1
730aAD optOverflow     s               n
730aAD optSendBase     s               n
730bAd optPickOnly     s               n
730bAd pickChange      s               n
650aAD multicount      s              4  0
640 AD scount          s              1  0
640 AD today           s              8  0
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #pgm             *proc
     D  #prog            *proc
     D  #job                 244    253
     D  #jobn                244    253
     D  #user                254    263
     D  #curruser            254    263
     D  #jobnbr              264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $WHSE   Warehouse
     *      $WHDP   Warehouse department or *ALL
     *      $SECTN  Section type (F,P,B)
     *      $PINCL  Include Contract items (Y,N)
     *      $PRFLG  Reduce Base item qty by corresponding Contract
     *              item qtys (Y,N)
GFS A*      $PCMPID Get Fresh Company Id code. Select only items
GFS A*              where ititem:1:1 = $pcmpid.
SOFaA*      $PCAT   Category Code or *ALL
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhs             3
     C                   parm                    $pwhdp            5
     C                   parm                    $pstyp            1
     C                   parm                    $pincl            1
     C                   parm                    $prflg            1
GFS AC                   parm                    $pcmpid           1
SOFaAC                   PARM                    $pcat            10
640dDC*                  move      $pwhs         $pwhse
     *----------------------------------------------------------------
     *  Main line
     *
     *  Set beginning limits on appropriate file.
     *
     C                   if        $pwhdp = '*ALL'
     C     keyitw        setll     piritem
     C                   else
     C     keyitd        setll     piritem1
     C                   endif
     *
     *  Loop through item records.
     *
     C                   dou       forevr <> forevr
     C                   if        $pwhdp = '*ALL'
     C     keyitw        reade     piritem                                77
     C                   else
     C     keyitd        reade     piritem1                               77
     C                   endif
     *
     *    Get out if EOF or Department doesn't match.
     *
     C                   if        *in77  or
     C                             $pwhdp <> '*ALL'  and
     C                             itwhdp <> $pwhdp
     C                   leave
     C                   endif
GFS A*
GFS AC                   if        client = getfresh
GFS A*      Bypass all items that do not match company id.
GFS AC                   if        %parms >= 6
GFS AC                             and %subst(ititem:1:1) <> $pcmpid
GFS AC                   iter
GFS AC                   endif
GFS A*
GFS AC                   endif
SWTbA*
SWTbA*     Skip non-stock items for Southwest Traders
SWTbAC                   if        client = SWT
SWTbAC                             and itdesg = 'NSTK*'
SWTbAC                   iter
SWTbAC                   endif
     *
     *    Accept or Reject based on section type.
     *
     C                   if        $pstyp = 'F'  and
     C                             itstyp <> 'F'  or
     C                             $pstyp = 'P'  and
     C                             itstyp <> 'P'
     C                   iter
     C                   endif
     *
     *    Accept or Reject based on item type.
     *
     C                   if        ittype = 'A'  and
CSPcDC*                            client <> coastl  or
GLPcMC                             (client <> coastl and
PFC AC                              client <> prestofoods and
GLPcAC                              client <> greenleaf)  or
CSPcA*
     C                             ittype = 'C'  and
     C                             $pincl <> 'Y'
     C                   iter
     C                   endif
SVLa *    Skip type'S' items, qty will be included with parent item.
SVLa *
SVLa C                   if        client = saval  and
SVLa C                             ittype = 'S'
SVLa C                   iter
SVLa C                   endif
SOFaAC*
SOFaAC                   if        client = Sofofoods
SOFaAC*
SOFaAC     keyif         chain     itemfld
SOFaAC                   if        not %found(itemfld)
SOFaAC                   eval      ifcat = ' '
SOFaAC                   endif
SOFaAC*
SOFaAC*      If Category code doesn't match, get next item.
SOFaAC                   if            %parms >= 7
SOFaAC                             and $pcat <> '*ALL'
SOFaAC                             and ifcat <> $pcat
SOFaAC                   iter
SOFaAC                   endif
SOFaAC*
SOFaAC                   endif
     *
     *    Record accepted for Export.
     *
     C                   clear                   qerec
     C                   eval      qewhse = itwhse
     C                   eval      qeitem = ititem
     C                   eval      qetype = ittype
416 AC                   eval      qecube = itcube
640dAC                   if        itumq2 <= 0
640dAC                   eval      itumq2 = 1
640dAC                   endif
640dAC                   if        itumq3 <= 0
640dAC                   eval      itumq3 = 1
640dAC                   endif
     *
     *    Get corresponding base item.
     *
     C                   clear                   ilitm2
     C                   clear                   ilitm3
     C                   if        ittype <> ' '
650aAC                              and ittype <> 'R'
     C     keyil         chain     itemlnk                            78
     C                   if        *in78
     C                   clear                   ilitm2
     C                   clear                   ilitm3
     C                   endif
     C                   endif
     C                   eval      qebitm = ilitm2
CWD A*
CWD AC                   if        client = Cashwa
CWD AC                   eval      qecitm = itwhdp
CWD AC                   else
CWD A*
     C                   eval      qecitm = ilitm3
CWD AC                   endif
CWD A*
GLPdAC                   if        client = Greenleaf
GLPdA*
GLPdAC                   eval      repackalias = '0'
GLPdAC                   if        ittype = 'A'
GLPdAC     keyit3glp     chain     piritem3
GLPdAC                   if            %found(piritem3)
GLPdAC                             and i3_ittype = 'R'
GLPdA*      Turn on flag to use ODR slot lookup routine.
GLPdAC                   eval      repackalias = '1'
GLPdAC                   endif
GLPdA*
GLPdAC                   endif
GLPdA*
GLPdAC                   endif
GLPdA*
     *
     *  Get item stock quantity.
     *
     C                   exsr      getqty
     *
     *  Get pick slots for item (max of 3)
     *
     C                   exsr      getpck
     *
     *  Add export record
     *
CCPaA*
CCPaAC                   if        client = capcty
GLPaAC                             or client = Greenleaf
CCPaA*
GLPaAC                   if        client = Capcty
GLPaA*
CCPaAC                   select
CCPaA*     Brkdwn item being processed.
CCPaAC                   when      ittype = 'B'  or
CCPaA*     Repack item being processed.
CCPaAC                             ittype = 'R'
CCPaA*     Do not allow any qty info to be sent to Host.
CCPaA*     Quantity is included in Parent Item Case qty.
CCPaAC                   eval      qestk1 = *zeros
CCPaAC                   eval      qestk2 = *zeros
CCPaAC                   eval      qestk3 = *zeros
CCPaAC                   endsl
CCPaA*
GLPaAC                   endif
CCPaA*
CCPaAC                   endif
CCPaA*
HMWaAC                   select
HMWaAC                   when      client = HMWagner
HMWaAC                             and qestk1 = *zeros
HMWaAC                             and qestk2 = *zeros
HMWaAC                             and qestk3 = *zeros
HMWaAC                   other
HMWaAC*
     C                   eval      qedate = today
     C                   time                    qetime
730bA /free
730bA   // Only send changes if option set
730bA   if optPickOnly;
730bA     exsr zzPickChange;
730bA     if not pickChange;
730bA       iter;
730bA     endif;
730bA   endif;
730bA /end-free
     C                   write     qerec                                79
HMWaAC*
HMWaAC                   endsl
640bA*
640bA*      Export active license info / lot code into to Host.
EIbA c                   if        client = EI
750 Ac                             or optExpLcns
640bAC                   exsr      zzexplcns
EIbA c                   endif
CCP A*
650aA*  The following Capitol code was moved to routine zzUpConvert
650aDC*                  if        client = capcty
650aD*
650aDC*                  select
650aD*     Add Brkdwn Qty into Parent Case Qty.
650aDC*                  when      ittype = 'B'  or
650aD*     Add Repack Qty into Parent Case Qty.
650aDC*                            ittype = 'R'
650aD*
650aD*     Retrieve Parent Item Qty record.
650aDC*    kyqeb         chain     expfqty                            79
650aDC*                  if        *in79
650aDC*                  eval      qeitem = qebitm
650aDC*                  eval      qebitm = *blanks
650aDC*                  eval      qetype = *blanks
650aDC*                  eval      qedate = today
650aDC*                  time                    qetime
650aDC*                  z-add     whlcas        qestk1
650aDC*                  write     qerec                                79
650aDC*                  else
650aDC*    qestk1        add       whlcas        qestk1
650aDC*                  update    qerec
650aDC*                  endif
650aD*
650aDC*                  endsl
650aD*
650aDC*                  endif
     *
     C                   enddo
EIa A*
EIa AC                   if        client = EI
EIa AC                   call      'IT736A'
EIa AC                   parm      $pwhse        $whse             3 0
EIa AC                   endif
EIa A*
     *
640daC                   if        %open(it736pr)
640dA*
640daC                   if        *in90 = '1'
640dAC                   write     head1
640dAC                   write     columns
640dAC                   endif
640dAC                   write     foot1
640dA*
640dAC                   endif
640dA*
     C                   eval      *inlr = *on
     C                   return
     *
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
500 A*
500 A*  Get client id
500 A*
500 AC                   call      @getcl
500 AC                   parm                    client
500 A*
SOFaAC                   if        client = Sofofoods
SOFaAC                   if        not %open(itemfld)
SOFaAC                   open      itemfld
SOFaAC                   endif
SOFaAC                   endif
     *
     *  Define key for PIRITEM file.
     *
     C     keyitw        klist
     C                   kfld                    $pwhse
     *
     *  Define key for PIRITEM1 file.
     *
     C     keyitd        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
IFC A*
IFC A*  Define key for PIRITEM3 file.
IFC A*
IFC AC     keyit3        klist
IFC AC                   kfld                    kyitem
IFC AC                   kfld                    itwhse
GLPdA*
GLPdAC     keyit3glp     klist
GLPdAC                   kfld                    qebitm
GLPdAC                   kfld                    $pwhse
     *
     *  Define key for ITEMQTY file.
     *
     C     keyiq         klist
     C                   kfld                    itwhse
     C                   kfld                    kyitem
     *
     *  Define key for ITEMLNK file.
     *
     C     keyil         klist
     C                   kfld                    itwhse
     C                   kfld                    ititem
IFC AC     keyil3        klist
IFC AC                   kfld                    itwhse
IFC AC                   kfld                    kyitem
SOFaAC*
SOFaAC*  Define key for ITEMFLD file.
SOFaAC*
SOFaAC     keyif         KLIST
SOFaAC                   KFLD                    itwhse
SOFaAC                   KFLD                    ititem
CCP A*
CCP A*  Define key for EXPFQTY file.
CCP A*
CCP AC     kyqeb         klist
CCP AC                   kfld                    $pwhse
CCP AC                   kfld                    qebitm
640bAC     keyla5        klist
640bAC                   kfld                    slwhse
640bAC                   kfld                    slwhdp
640bAC                   kfld                    sldisp
640bAC                   kfld                    slitem
CCP A*
CCP A*  Define key for KITCOMP file.
CCP A*
CCP AC     keykc         klist
CCP AC                   kfld                    $pwhse
CCP AC                   kfld                    ititem
     *
     *  Define partial key for SLOT3 file.
     *
     C     keysl3        klist
     C                   kfld                    itwhse
     C                   kfld                    kyitem
     C                   kfld                    kystat
     C                   kfld                    kypick
640bAC     keysl3p       klist
640bAC                   kfld                    itwhse
640bAC                   kfld                    kyitem
CSPbA*
CSPbA*  Define full key for VSLOT1 file.
CSPbA*
CSPbAC     keyvs1        klist
CSPbAC                   kfld                    itwhse
CSPbAC                   kfld                    slwhdp
CSPbAC                   kfld                    sldisp
416 A*
416 A*  Define key for SLOTDEF file.
416 A*
416 AC     keysd         klist
416 AC                   kfld                    slwhse
416 AC                   kfld                    slsdef
CWDaA*
CWDaA*  Define key for SLOTDGT/SLOTDGTA files.
CWDaA*
CWDaAC     keyscd        klist
CWDaAC                   kfld                    slwhse
CWDaAC                   kfld                    slwhdp
CWDaAC                   kfld                    sldisp
416 A*
416 A*  Define key for ITEMDEF file.
416 A*
416 AC     keyid         klist
416 AC                   kfld                    slwhse
416 AC                   kfld                    slitem
416 AC                   kfld                    slsdef
640dA*
640dA*   Get warehouse description.
640dA*
640daC                   move      $pwhs         $pwhse
640dAC     $pwhse        chain     warehs
640dAC                   if        not %found(warehs)
640dAC                   eval      whdesc = ' '
640dAC                   endif
640dAC                   eval      $pstr = %editc($pwhse:'X')
640dAC                             + ' - '
640daC                             + whdesc
640dAC                   eval      $plen = 60
640dA*
640dA*   Center warehouse description.
640dA*
640dAC                   call      'CENTER'
640dAC                   parm                    $pstr            60
640dAC                   parm                    $plen             3 0
640dAC                   eval      hedln2 = $pstr
640dA*
640dA*  Retrieve today's date.
640dA*
640dAc                   eval      $cvcmd = '*CURMDY '
640dAc                   call      @cvtdt
640dAc                   parm                    $cvtdt
640dAc                   eval      rdate = $cvd6o
640dAC                   time                    rtime
640aA*
640aA*   Get default values for the user.
640aA*
640aAC                   call      'GETUSER'
640aAC                   parm                    #curruser
640aAC                   parm      0             #whse             3 0
640aAC                   parm      0             #emp#             5 0
640aAC                   parm                    #fnam            15
640aAC                   parm                    #init             1
640aAC                   parm                    #lnam            20
640aAC                   parm                    #whdp             5
640aAC                   parm                    #styp             1
640aAC                   parm                    #shft             6
640aAC                   parm                    #crew             6
640aAC                   parm      0             #nhrs             3 1
640aAC                   parm                    #rtn              8
CWDaA*
CWDaAC                   if        client = Cashwa
CWDaA*
CWDaAC                   if        not %open(slotdgt)
CWDaAC                   open      slotdgt
CWDaAC                   endif
CWDaA*
CWDaAC                   if        not %open(slotdgta)
CWDaAC                   open      slotdgta
CWDaAC                   endif
CWDaA*
CWDaAC                   endif
     *
     *  Variables and constants.
     *
     C                   eval      forevr = *off
CCP A*
CCP AC                   eval      opnkit = *off
CCP AC                   if        client = capcty
GLPdAC                             or client = Greenleaf
CCP A*
CCP AC                   if        opnkit = '0'
CCP AC                   open      kitcomp
CCP AC                   eval      opnkit = *on
CCP AC                   endif
CCP A*
CCP AC                   endif
CCP A*
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
730aA /free
730aA   // Get Option to see if overflow when no pick.
730aA   optint.type = 'Interface   ';
730aA   optint.cat  = 'Export ItemQty      ';
730aA   optint.name = 'Overflow if no Pick ';
730aA   GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
730aA             optint.valn: optint.vala: optint.return);
730aA   if optint.return = '*OK'
730aA    and optint.vala = 'Y';
730aA     optOverflow = *on;
730bA   else;
730bA     optOverflow = *off;
730aA   endif;

730aA   // Get Option to see if to send base for virtuals.
730aA   optint.type = 'Interface   ';
730aA   optint.cat  = 'Export ItemQty      ';
730aA   optint.name = 'Send Base if Virtual';
730aA   GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
730aA             optint.valn: optint.vala: optint.return);
730aA   if optint.return = '*OK'
730aA    and optint.vala = 'Y';
730aA     optSendBase = *on;
730bA   else;
730bA     optSendBase = *off;
730aA   endif;

730bA   // Get option for only pick slot changes
730bA   optint.type = 'Interface   ';
730bA   optint.cat  = 'Export ItemQty      ';
730bA   optint.name = 'Only Pick Changes   ';
730bA   GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
730bA             optint.valn: optint.vala: optint.return);
730bA   if optint.return = '*OK'
730bA    and optint.vala = 'Y';
730bA     optPickOnly = *on;
730bA   else;
730bA     optPickOnly = *off;
730bA   endif;
750 A   //
750 A   // Get Option to Export Licenses
750 A   optint.type = 'Interface   ';
750 A   optint.cat  = 'Export ItemQty      ';
750 A   optint.name = 'Export Licenses     ';
750 A   GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
750 A             optint.valn: optint.vala: optint.return);
750 A   if optint.return = '*OK'
750 A    and optint.vala = 'Y';
750 A     optExpLcns = *on;
750 A   else;
750 A     optExpLcns = *off;
750 A   endif;
730bA /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETPCK  Get pick slots for item (max of 3)
     *
     C     getpck        begsr
     C                   eval      scount = 0
     *
     *  If Contract or SSB item
     *   Then use Base item to look for slots
     *   Otherwise use record item
     *
     C                   if        ittype = 'C'  or
     C                             ittype = 'S'  or
CSPcA*
650 DC*                            (client = coastl  and
650 MC                             (client = coastl  or
PFC AC                              client = prestofoods or
GLPcAC                             client = Greenleaf)  and
CSPcAC                             ittype = 'A'
CSPcA*
     C                   eval      kyitem = ilitm2
     C                   else
     C                   eval      kyitem = ititem
     C                   endif
CSPdA*
CSPdAC                   if        client = coastl
CSPdA*
CSPdA*  If item is JIT repack item, load slot returned with item.
CSPdAC                   if        ittype = 'R'
CSPdAC                   call      @itmfl
CSPdAC                   parm      $pwhse        rwhse             3 0
CSPdAC                   parm      kyitem        ritem            15
CSPdAC                   parm      ' '           rcat             10
CSPdAC                   parm      ' '           rcasof            1
CSPdAC                   parm      *blanks       rodrsl           12
CSPdAC                   if        rodrsl > ' '
CSPdAC                   eval      qedsp1 = rodrsl
CSPdAC                   eval      scount = 1
CSPdAC                   goto      #csp
CSPdAC                   endif
CSPdA*
CSPdAC                   endif
CSPdA*
CSPdAC                   endif
IFCaA*   If Alias item, get type for base item.
IFCa C                   if        client = andrews
IFCa C                             or client = birite
IFCa C                             or client = jordanos
IFCa C                   if        ittype = 'A'
IFCa C     keyit3        chain     piritem3                           76
IFCa C                   if        *in76
IFCa C                   eval      i3_ittype = *blanks
IFCa C                   endif
IFCa C                   endif
IFCaA*   If base item for Alias is SSB, get base item for SSB.
IFCa C                   if        i3_ittype = 'S'
IFCa C     keyil3        chain     itemlnk                            78
IFCa C                   if        *in78
IFCa C                   clear                   ilitm2
IFCa C                   clear                   ilitm3
IFCa C                   else
IFCa C                   eval      kyitem = ilitm2
IFCa C                   endif
IFCa C                   endif
     *
IFCa1C                   endif
     *
     *   Loop through picking slots for base item.
     *
GLPdAC                   if        client = greenleaf
GLPdA*
GLPdAC                   if           ittype = 'R'
GLPdAC                             or repackalias = '1'
GLPdAC                   exsr      getodr
GLPdAC                   else
GLPdA*
GLPdAC                   eval      kystat = 'A '
GLPdAC                   endif
GLPdA*
GLPdAC                   else
GLPdA*
     C                   eval      kystat = 'A '
GLPdAC                   endif
GLPdA*
     C                   eval      kypick = 'Y'
     C     keysl3        setll     slot3
     C                   dou       forevr <> forevr
     C     keysl3        reade     slot3                                  77
     C                   if        *in77
     C                   leave
     C                   endif
     *
     *     Ignore slot if past expiration date.
     *
     C                   if        slexpd <> 0  and
     C                             slexpd < today
417 D*R                   ITER
     C                   endif
JOR A*
JOR A*     Ignore slots not at Active status.
JOR  C                   if        client = jordanos
JOR AC                             and slstat = 'Z '
JOR AC                   iter
JOR AC                   endif
610 A*
610 A*     Ignore Internal Use Only slots with designation = BFC.
610 AC                   if        sldesg = 'BFC'
610 AC                   iter
610 AC                   endif
416 A*
416 A*     Get slot definition information.
416 A*
416 AC     keysd         chain     slotdef                            77
416 AC                   if        *in77
416 AC                   clear                   sdpal
416 AC                   clear                   sdpos
416 AC                   endif
416 A*
416 A*     Get item tie/high information.
416 A*
416 AC     keyid         chain     itemdef                            77
416 AC                   if        *in77
416 AC                   clear                   idtie
416 AC                   clear                   idhigh
416 AC                   endif
     *
     *     Add to item's slots
     *
     C                   add       1             scount
     C                   select
     C                   when      scount = 1
DON AC                   if        client = donsons
DON AC                   eval      aisle = *blanks
DON AC                   eval      loc = *blanks
DON AC                   eval      lvlhnd = *blanks
DON AC                   eval      aisle = %subst(sldisp:1:1)
DON AC                   eval      loc = %subst(sldisp:3:2)
DON AC                   eval      lvlhnd = %subst(sldisp:6:2)
DON AC                   eval      qedsp1 = %trimr(aisle) + loc
DON AC     qedsp1        cat       lvlhnd:0      qedsp1
DON A*
DON AC                   else
CSPbA*
CSPbAC                   if        client = coastl
GLPbAC                             or client = Greenleaf
CWDbAC                             or client = Cashwa
SGCaAC                             or client = SGC
730aAC                             or OptSendBase = *on
CSPbA*     Retrieve base slot to send to Host.
CSPbAC                   if        slrsrv = 'V'
CSPbAC     keyvs1        chain     vslot1                             74
CSPbAC                   if        not *in74
CSPbAC                   eval      sldisp = vspdis
CSPbAC                   endif
CSPbAC                   endif
CSPbAC                   endif
CSPbA*
CWDaAC                   if        client = Cashwa
CWDaA*
CWDaAC     keyscd        chain     slotdgt
CWDaAC                   if        not %found(slotdgt)
CWDaAC                   eval      scddgt = 0
CWDaAC                   endif
CWDaA*
CWDaAC     keyscd        chain     slotdgta
CWDaAC                   if        not %found(slotdgta)
CWDaAC                   eval      scddgt2 = 0
CWDaAC                   eval      scddgt3 = 0
CWDaAC                   endif
CWDaA*
     C                   endif
CWDaA*
     C                   eval      qedsp1 = sldisp
DON AC                   endif
416 AC                   eval      qesdf1 = slsdef
CWDaA*
CWDaAC                   if        client = Cashwa
CWDaAC                   eval      qeti1 = scddgt
CWDaAC                   eval      qeti2 = scddgt2
CWDaAC                   eval      qeti3 = scddgt3
CWDaAC                   else
CWDaA*
416 AC                   eval      qeti1 = idtie
CWDaAC                   endif
CWDaA*
416 AC                   eval      qehi1 = idhigh
416 AC                   eval      qepos1 = sdpos
416 AC                   eval      qepal1 = sdpal
     C                   when      scount = 2
CSPbA*
CSPbAC                   if        client = coastl
GLPbAC                             or client = Greenleaf
CWDbAC                             or client = Cashwa
SGCaAC                             or client = SGC
730aAC                             or OptSendBase = *on
CSPbA*     Retrieve base slot to send to Host.
CSPbAC                   if        slrsrv = 'V'
CSPbAC     keyvs1        chain     vslot1                             74
CSPbAC                   if        not *in74
CSPbAC                   eval      sldisp = vspdis
CSPbAC                   endif
CSPbAC                   endif
CSPbAC                   endif
CSPbA*
     C                   eval      qedsp2 = sldisp
416 AC                   eval      qesdf2 = slsdef
CWDaA*
CWDaAC                   if        client = Cashwa
CWDaA*      Check digits loaded in Seq 1 for this field.
CWDaAC                   else
CWDaA*
416 AC                   eval      qeti2 = idtie
CWDaAC                   endif
CWDaA*
416 AC                   eval      qehi2 = idhigh
416 AC                   eval      qepos2 = sdpos
416 AC                   eval      qepal2 = sdpal
     C                   when      scount = 3
CSPbA*
CSPbAC                   if        client = coastl
GLPbAC                             or client = Greenleaf
CWDbAC                             or client = Cashwa
SGCaAC                             or client = SGC
730aAC                             or OptSendBase = *on
CSPbA*     Retrieve base slot to send to Host.
CSPbAC                   if        slrsrv = 'V'
CSPbAC     keyvs1        chain     vslot1                             74
CSPbAC                   if        not *in74
CSPbAC                   eval      sldisp = vspdis
CSPbAC                   endif
CSPbAC                   endif
CSPbAC                   endif
CSPbA*
     C                   eval      qedsp3 = sldisp
416 AC                   eval      qesdf3 = slsdef
CWDaA*
CWDaAC                   if        client = Cashwa
CWDaA*      Check digits loaded in Seq 1 for this field.
CWDaAC                   else
CWDaA*
416 AC                   eval      qeti3 = idtie
CWDaAC                   endif
CWDaA*
416 AC                   eval      qehi3 = idhigh
416 AC                   eval      qepos3 = sdpos
416 AC                   eval      qepal3 = sdpal
     C                   leave
     C                   endsl
     *
     C                   enddo
BIR A*
BIR AC                   if        client = birite  or
ALN AC                             client = allen  or
CSP AC                             client = coastl
GLP AC                             or client = greenleaf
SOF AC                             or client = sofo
SGC AC                             or client = sgc
730aAC                             or optOverflow = *on
BIR A*
BIR A*    Look for overflow slots when no pick slot(s) found.
BIR AC                   if        scount = 0
BIR AC                   eval      kystat = 'A '
BIR AC                   eval      kypick = 'N'
BIR AC     keysl3        setll     slot3
BIR AC                   dou       forevr <> forevr
BIR AC     keysl3        reade     slot3                                  77
BIR AC                   if        *in77
BIR AC                   leave
BIR AC                   endif
610 A*
610 A*     Ignore Internal Use Only slots with designation = BFC.
610 AC                   if        sldesg = 'BFC'
610 AC                   iter
610 AC                   endif
BIR A*
BIR A*     Get slot definition information.
BIR A*
BIR AC     keysd         chain     slotdef                            77
BIR AC                   if        *in77
BIR AC                   clear                   sdpal
BIR AC                   clear                   sdpos
BIR AC                   endif
BIR A*
BIR A*     Get item tie/high information.
BIR A*
BIR AC     keyid         chain     itemdef                            77
BIR AC                   if        *in77
BIR AC                   clear                   idtie
BIR AC                   clear                   idhigh
BIR AC                   endif
BIR A*
BIR A*     Add to item's slots
BIR A*
BIR AC                   add       1             scount
BIR AC                   select
BIR AC                   when      scount = 1
CSPbA*
CSPbAC                   if        client = coastl
GLPbAC                             or client = greenleaf
CWDbAC                             or client = Cashwa
SGCaAC                             or client = SGC
730aAC                             or OptSendBase = *on
CSPbA*     Retrieve base slot to send to Host.
CSPbAC                   if        slrsrv = 'V'
CSPbAC     keyvs1        chain     vslot1                             74
CSPbAC                   if        not *in74
CSPbAC                   eval      sldisp = vspdis
CSPbAC                   endif
CSPbAC                   endif
CSPbAC                   endif
CSPbA*
BIR AC                   eval      qedsp1 = sldisp
BIR AC                   eval      qesdf1 = slsdef
CWDaA*
CWDaAC                   if        client = Cashwa
CWDaAC                   eval      qeti1 = 0
CWDaAC                   else
CWDaA*
BIR AC                   eval      qeti1 = idtie
CWDaAC                   endif
CWDaA*
BIR AC                   eval      qehi1 = idhigh
BIR AC                   eval      qepos1 = sdpos
BIR AC                   eval      qepal1 = sdpal
BIR AC                   when      scount = 2
CSPbA*
CSPbAC                   if        client = coastl
GLPbAC                             or client = greenleaf
CWDbAC                             or client = Cashwa
SGCaAC                             or client = SGC
730aAC                             or OptSendBase = *on
CSPbA*     Retrieve base slot to send to Host.
CSPbAC                   if        slrsrv = 'V'
CSPbAC     keyvs1        chain     vslot1                             74
CSPbAC                   if        not *in74
CSPbAC                   eval      sldisp = vspdis
CSPbAC                   endif
CSPbAC                   endif
CSPbAC                   endif
CSPbA*
BIR AC                   eval      qedsp2 = sldisp
BIR AC                   eval      qesdf2 = slsdef
CWDaA*
CWDaAC                   if        client = Cashwa
CWDaAC                   eval      qeti2 = 0
CWDaAC                   else
CWDaA*
BIR AC                   eval      qeti2 = idtie
CWDaAC                   endif
CWDaA*
BIR AC                   eval      qehi2 = idhigh
BIR AC                   eval      qepos2 = sdpos
BIR AC                   eval      qepal2 = sdpal
BIR AC                   when      scount = 3
CSPbA*
CSPbAC                   if        client = coastl
GLPbAC                             or client = greenleaf
CWDbAC                             or client = Cashwa
SGCaAC                             or client = SGC
730aAC                             or OptSendBase = *on
CSPbA*     Retrieve base slot to send to Host.
CSPbAC                   if        slrsrv = 'V'
CSPbAC     keyvs1        chain     vslot1                             74
CSPbAC                   if        not *in74
CSPbAC                   eval      sldisp = vspdis
CSPbAC                   endif
CSPbAC                   endif
CSPbAC                   endif
CSPbA*
BIR AC                   eval      qedsp3 = sldisp
BIR AC                   eval      qesdf3 = slsdef
CWDaA*
CWDaAC                   if        client = Cashwa
CWDaAC                   eval      qeti3 = 0
CWDaAC                   else
CWDaA*
BIR AC                   eval      qeti3 = idtie
CWDaAC                   endif
CWDaA*
BIR AC                   eval      qehi3 = idhigh
BIR AC                   eval      qepos3 = sdpos
BIR AC                   eval      qepal3 = sdpal
BIR AC                   leave
BIR AC                   endsl
BIR A*
BIR AC                   enddo
BIR AC                   endif
BIR AC                   endif
CSPaA*
CSPdAC     #csp          tag
CSPaAC                   if        client = coastl
CSPaA*
CSPaAC                   if        itdesg = 'JIT  '  and
CSPaAC                             scount = 0
CSPaAC                   eval      qedsp1 = '74-111-1'
CSPaAC                   endif
CSPbA*
CSPbAC                   if        qedsp1 = '63-200-1'  or
CSPbAC                             qedsp2 = '63-200-1'  or
CSPbAC                             qedsp3 = '63-200-1'  or
CSPbAC                             itdesg = 'BRKN  '
CSPbAC                   eval      qedsp1 = 'BRKN'
CSPbAC                   eval      qedsp2 = *blanks
CSPbAC                   eval      qedsp3 = *blanks
CSPbAC                   endif
CSPbA*
CSPbAC                   endif
CSPbA*
     *
     C                   endsr
GLPdA*
GLPdA*----------------------------------------------------------------
GLPdA*
GLPdA*  GETODR  Get ODR Slot for Repack item.
GLPdA*
GLPdAC     getodr        begsr
GLPdA*
GLPdA*      See if active pick slot found for ODR item.
GLPdAC                   eval      kypick = 'Y'
GLPdAC                   eval      kystat = 'A '
GLPdAC     keysl3        setll     slot3
GLPdAC                   if        %equal(slot3)
GLPdAC                   leavesr
GLPdAC                   endif
GLPdA*
GLPdAC                   if        repackalias = '1'
GLPdAC                   eval      kyitem = ilitm2
GLPdAC                   endif
GLPdAC     keyil3        chain     kitcomp
GLPdAC                   eval      kyitem = kccitm
GLPdAC                   eval      kystat = 'RP'
GLPdAC                   eval      kypick = 'Y'
GLPdAC                   dou       forevr <> forevr
GLPdAC     keysl3        setll     slot3
GLPdAC                   select
GLPdA*      ODR Slot not found. See if active pick slot found.
GLPdAC                   when      not %equal(slot3)
GLPdAC                   eval      kystat = 'A '
GLPdAC     keysl3        setll     slot3
GLPdAC                   if        %equal(slot3)
GLPdAC                   leave
GLPdAC                   endif
GLPdA*
GLPdA*      ODR Slot not found. Move to next level to look for ODR.
GLPdAC     keyil3        chain     kitcomp
GLPdAC                   if        not %found(kitcomp)
GLPdAC                   eval      kcitem = ' '
GLPdAC                   eval      kccitm = ' '
GLPdAC                   eval      kystat = 'A '
GLPdAC                   leave
GLPdAC                   else
GLPdA*
GLPdA*      Next parent found. Check if item has RP slot.
GLPdAC                   eval      kystat = 'RP'
GLPdAC                   eval      kyitem = kccitm
GLPdAC                   endif
GLPdA*
GLPdA*      ODR Slot found. Now get out.
GLPdAC                   when      %equal(slot3)
GLPdAC                   leave
GLPdA*
GLPdAC                   endsl
GLPdA*
GLPdAC                   enddo
GLPdA*
GLPdAC                   endsr
GLPdA*
     *----------------------------------------------------------------
     *
     *  GETQTY  Get quantity for item
     *
     C     getqty        begsr
     *
     *  If SSB item
     *   Then get qty for Base item
     *   Otherwise use record item and check for existance of SSB item.
     *
     C                   if        ittype = 'S'
     C                   eval      kyitem = ilitm2
     C                   else
     C                   eval      kyitem = ititem
     C                   call      'CHKSSB'
     C                   parm      itwhse        $gwhse            3 0
     C                   parm      ititem        $gitem           15
     C                   parm                    $gexst            1
     C                   endif
     *
     *  Get stock quantity for item.
     *
     C     keyiq         chain     itemqty                            79
     C     *in79         cabeq     *on           endqty
     *
     C                   select
     *
     *      Same Slot Breakdown item uses the bkdn 1 & 2
     *      of the Base item's quantities.
     *
     C                   when      ittype = 'S'
     C                   eval      qestk1 = iqstk2
     C                   eval      qestk2 = iqstk3
     *
     *     For Saval, send type 'S' item quantity with parent item.
SVLa C                   when      client = saval  and
SVLa C                             $gexst = 'Y'
SVLa C                   z-add     iqstk1        qestk1
SVLa C                   eval      qestk2 = iqstk2
CCP A*
CCP A*     For Capitol City, send type 'B' item qty with parent item.
CCP AC                   when      client = capcty  and
CCP AC                             ittype = 'B'  or
CCP A*     For Capitol City, send type 'R' item qty with parent item.
CCP AC                             client = capcty  and
CCP AC                             ittype = 'R'
CCP AC                   exsr      zzcvqy
     *
     *      If an item has a Same Slot Breakdown item
     *       then use only the Normal quantity.
     *
     C                   when      $gexst = 'Y'
     C                   z-add     iqstk1        qestk1
     *
     *      Otherwise take quantities as they are.
     *
     C                   other
     C                   z-add     iqstk1        qestk1
     C                   eval      qestk2 = iqstk2
     C                   eval      qestk3 = iqstk3
     *
     C                   endsl
     *
     *  Reduce qty by corresponding Contract qty's if that
     *    is what the user wants.
     *
     C                   if        $pincl = 'Y'  and
     C                             $prflg = 'Y'
     *
     C                   call      'GETCON'
     C                   parm      itwhse        $gwhse
     C                   parm      ititem        $gitem
     C                   parm                    $gcnt             3 0
     C                   parm                    $gqty1            5 0
     C                   parm                    $gqty2            5 0
     C                   parm                    $gqty3            5 0
     *
     C                   if        $gcnt > 0
     C                   eval      qerflg = 'Y'
     *
     C                   if        qestk1 > $gqty1
     C                   eval      qestk1 = qestk1 - $gqty1
     C                   else
     C                   eval      qestk1 = 0
     C                   endif
     *
     C                   if        qestk2 > $gqty2
     C                   eval      qestk2 = qestk2 - $gqty2
     C                   else
     C                   eval      qestk2 = 0
     C                   endif
     *
     C                   if        qestk3 > $gqty3
     C                   eval      qestk3 = qestk3 - $gqty3
     C                   else
     C                   eval      qestk3 = 0
     C                   endif
     *
     C                   endif
     *
     C                   endif
     *
     C     endqty        endsr
CCP A*----------------------------------------------------------------
CCP A*
CCP A*  ZZCVQY  Convert Brkdown/Repack Item Qty into Parent Item Case Qty
CCP A*
CCP AC     zzcvqy        begsr
CCP A*
CCP A*     Retrieve base item number info for qty conversions.
650aAc                   eval      multicount = 0
CCP AC                   if        ittype = 'B'
650aDC*                            ittype = 'R'
CCP AC                   call      'GETBASE'
CCP AC                   parm      $pwhse        $gwhse
CCP AC                   parm      ititem        $gitem
CCP AC                   parm      ' '           #bitem           15
CCP AC                   parm                    #bityp            1
CCP AC                   parm                    #bdesc           30
CCP AC                   parm                    #bpdsc           15
CCP AC                   parm                    #bwhdp            5
CCP AC                   parm                    #bstyp            1
CCP AC                   parm                    #bum1             2
CCP AC                   parm                    #bum2             2
CCP AC                   parm                    #bumq2            3 0
CCP AC                   parm                    #bum3             2
CCP AC                   parm                    #bumq3            3 0
CCP AC                   parm      ' '           #bcitm           15
CCP AC                   parm                    #bctyp            1
CCP AC                   parm                    #bcdsc           30
CCP AC                   parm                    #bcpds           15
CCP AC                   parm                    #bcwdp            5
CCP AC                   parm                    #bcstp            1
CCP AC                   parm                    #bcum1            2
CCP AC                   parm                    #bcum2            2
CCP AC                   parm                    #bcuq2            3 0
CCP AC                   parm                    #bcum3            2
CCP AC                   parm                    #bcuq3            3 0
CCP AC                   parm                    #brtn             8
CCP AC                   endif
CCP A*
CCP AC                   select
CCP A*     Up-convert Breakdown Qty into Parent Case qty.
CCP AC                   when      ittype = 'B'
CCP A*
CCP AC                   if        #bumq2 > 0
CCP AC     iqstk1        div(h)    #bumq2        whlcas
CCP AC                   else
CCP AC                   eval      whlcas = *zeros
CCP AC                   endif
650aAc                   exsr      zzUpConvert
CCP A*
CCP A*
CCP A*     Up-convert Repack Qty into Parent Case qty.
CCP AC                   when      ittype = 'R'
650aA*     Loop Kitcomp for the possibility of multiple parent items
650aA*       for each Repack Item
CCP A*     Retrieve the repack parent conversion factor.
650aAC     keykc         setll     kitcomp
650aDC*    keykc         chain     kitcomp                            79
650aAC     keykc         reade     kitcomp                                79
650aDC*                  if        *in79
650aDC*                  eval      kcqty1 = *zeros
650aDC*                  eval      kcqty2 = *zeros
650aDC*                  eval      kcqty3 = *zeros
650aDC*                  endif
650aA*
650aAC                   dow       not *in79
650aA*
650aAC                   call      'GETBASE'
650aAC                   parm      $pwhse        $gwhse
650aAC                   parm      ititem        $gitem
650aAC                   parm      kccitm        #bitem           15
650aAC                   parm                    #bityp            1
650aAC                   parm                    #bdesc           30
650aAC                   parm                    #bpdsc           15
650aAC                   parm                    #bwhdp            5
650aAC                   parm                    #bstyp            1
650aAC                   parm                    #bum1             2
650aAC                   parm                    #bum2             2
650aAC                   parm                    #bumq2            3 0
650aAC                   parm                    #bum3             2
650aAC                   parm                    #bumq3            3 0
650aAC                   parm      ' '           #bcitm           15
650aAC                   parm                    #bctyp            1
650aAC                   parm                    #bcdsc           30
650aAC                   parm                    #bcpds           15
650aAC                   parm                    #bcwdp            5
650aAC                   parm                    #bcstp            1
650aAC                   parm                    #bcum1            2
650aAC                   parm                    #bcum2            2
650aAC                   parm                    #bcuq2            3 0
650aAC                   parm                    #bcum3            2
650aAC                   parm                    #bcuq3            3 0
650aAC                   parm                    #brtn             8
CCP A*
CCP A*     Convert qty onhand into
650aAc                   eval      qebitm = kccitm
650aAc                   eval      qecitm = ' '
CCP AC     iqstk1        mult      kcqty2        extqty
CCP AC                   if        #bumq2 > 0
CCP AC     extqty        div(h)    #bumq2        whlcas
CCP AC                   else
CCP AC                   eval      whlcas = *zeros
CCP AC                   endif
650aAc                   exsr      zzUpConvert
650aAC     keykc         reade     kitcomp                                79
650aAC                   enddo
650aA*  if more than one repack item existed show parent as *KIT
650aAc                   if        multicount > 1
650aAc                   eval      qebitm = '*KIT'
650aAc                   endif
CCP A*
CCP AC                   endsl
CCP A*
CCP AC     endcvq        endsr
650aA*
650aA*----------------------------------------------------------------
650aA*
650aA*  ZZUpConvert  Up Convert to Parent qty/item for Capitol Repack Qty
650aA*    and Breakdown items
650aA*
650aAC     zzUpConvert   begsr
650aA*     Save Repack information before parent update/add
650aAc                   exsr      SavEXPFValues
650aA*     Retrieve Parent Item Qty record.
650aAc                   eval      multicount = multicount + 1
650aAC     kyqeb         chain     expfqty                            79
650aAC                   if        *in79
650aAC                   eval      qeitem = qebitm
650aAC                   eval      qebitm = *blanks
650aAC                   eval      qetype = *blanks
650aAC                   eval      qedate = today
650aAC                   time                    qetime
650aAC                   z-add     whlcas        qestk1
650aAC                   write     qerec                                79
650aAC                   else
650aAC     qestk1        add       whlcas        qestk1
650aAC                   update    qerec
650aAC                   endif
650aA*     Return Repack information to record for update/add
650aAc                   exsr      rstEXPFValues
650aAC                   endsr
650aA*
650aA*----------------------------------------------------------------
650aA*
650aA*  savEXPFValues  -  Save current Repack item record values
650aA*                     prior to parent update
650aA*
650aAC     savEXPFValues begsr
650aAc                   eval      savwhse = qewhse
650aAc                   eval      savitem = qeitem
650aAc                   eval      savtype = qetype
650aAc                   eval      savbitm = qebitm
650aAc                   eval      savcitm = qecitm
650aAc                   eval      savrflg = qerflg
650aAc                   eval      savstk1 = qestk1
650aAc                   eval      savstk2 = qestk2
650aAc                   eval      savstk3 = qestk3
650aAc                   eval      savdsp1 = qedsp1
650aAc                   eval      savdsp2 = qedsp2
650aAc                   eval      savdsp3 = qedsp3
650aAc                   eval      savdate = qedate
650aAc                   eval      savtime = qetime
650aAc                   eval      savcube = qecube
650aAc                   eval      savsdf1 = qesdf1
650aAc                   eval      savpal1 = qepal1
650aAc                   eval      savpos1 = qepos1
650aAc                   eval      savti1 = qeti1
650aAc                   eval      savhi1 = qehi1
650aAc                   eval      savsdf2 = qesdf2
650aAc                   eval      savpal2 = qepal2
650aAc                   eval      savpos2 = qepos2
650aAc                   eval      savti2 = qeti2
650aAc                   eval      savhi2 = qehi2
650aAc                   eval      savsdf3 = qesdf3
650aAc                   eval      savpal3 = qepal3
650aAc                   eval      savpos3 = qepos3
650aAc                   eval      savti3 = qeti3
650aAc                   eval      savhi3 = qehi3
650aAc                   endsr
650aA*
650aA*----------------------------------------------------------------
650aA*
650aA*  rstEXPFValues  -  Restore Repack record values
650aA*                     after parent update
650aA*
650aAC     rstEXPFValues begsr
650aAc                   eval      qewhse  = savwhse
650aAc                   eval      qeitem  = savitem
650aAc                   eval      qetype  = savtype
650aAc                   eval      qebitm  = savbitm
650aAc                   eval      qecitm  = savcitm
650aAc                   eval      qerflg  = savrflg
650aAc                   eval      qestk1  = savstk1
650aAc                   eval      qestk2  = savstk2
650aAc                   eval      qestk3  = savstk3
650aAc                   eval      qedsp1  = savdsp1
650aAc                   eval      qedsp2  = savdsp2
650aAc                   eval      qedsp3  = savdsp3
650aAc                   eval      qedate  = savdate
650aAc                   eval      qetime  = savtime
650aAc                   eval      qecube  = savcube
650aAc                   eval      qesdf1 = savsdf1
650aAc                   eval      qepal1 = savpal1
650aAc                   eval      qepos1 = savpos1
650aAc                   eval      qeti1 = savti1
650aAc                   eval      qehi1 = savhi1
650aAc                   eval      qesdf2 = savsdf2
650aAc                   eval      qepal2 = savpal2
650aAc                   eval      qepos2 = savpos2
650aAc                   eval      qeti2 = savti2
650aAc                   eval      qehi2 = savhi2
650aAc                   eval      qesdf3 = savsdf3
650aAc                   eval      qepal3 = savpal3
650aAc                   eval      qepos3 = savpos3
650aAc                   eval      qeti3 = savti3
650aAc                   eval      qehi3 = savhi3
650aAc                   endsr
640bA*
640bA*----------------------------------------------------------------
640bA*
640bA*  ZZEXPLCNS  Export active license info / lot codes to Host.
640bA*
640bAC     zzexplcns     begsr
640bA*
640bAC     keysl3p       setll     slot3
640bAC                   dou       forevr <> forevr
640bAC     keysl3p       reade     slot3
640bAC                   if        %eof(slot3)
640bAC                   leave
640bAC                   endif
640bA*
640bA*      Ignore slots at Zero status.
640bAC                   if        slstat = 'Z '
640bAC                   iter
640bAC                   endif
640bA*
640dAC                   eval      tllic1 = 0
640dAC                   eval      tllic2 = 0
640dAC                   eval      tllic3 = 0
640dAC                   eval      nbrlicense = 0
640dAC                   eval      tryonce    = '0'
640dA*
640bAC     keyla5        setll     licactive5
640bAC                   dou       forevr <> forevr
640bAC     keyla5        reade     licactive5
640bAC                   if        %eof(licactive5)
640eA*
640eAC                   select
640eAC                   when          nbrlicense = 0
640eAC                             and tryonce = '0'
640eA*      Try to fix missing license plate.
640eAC                   call(e)   'LT001'
640eAC                   parm      'FIX'         lpAction          3
640eAC                   parm      slwhse        lpWhse            3 0
640eAC                   parm      slwhdp        lpWhdp            5
640eAC                   parm      sldisp        lpDisp           12
640eAC                   parm      ' '           lpDummy           1
640eA*      Re-position pointer and attempt to re-read license file.
640eAC     keyla5        setll     licactive5
640eAC                   eval      tryonce = '1'
640eAC                   iter
640eA*
640eAC                   other
640dA
640dA*      Print exception report if slot and license qty's don't match.
640dAC                   eval      SltQty = (slstk1 * itumq2 * itumq3)
640dAC                                      + (slstk2 * itumq3)
640dAC                                      +  slstk3
640dAC                   eval      LicQty = (tllic1 * itumq2 * itumq3)
640dAC                                      + (tllic2 * itumq3)
640dAC                                      +  tllic3
640dAC                   if        SltQty <> LicQty
640dAC                   eval      ermsg1 = 'Slot/Lic qty mismatch'
640dAC                   exsr      zzprterr
640dAC                   endif
640dA*
640eAC                   endsl
640eA*
640bAC                   leave
640bAC                   endif
640eA
640eA*  Count number of active licenses.
640eAC                   eval      nbrlicense = nbrlicense + 1
640bA
640bA*  Get receiving information  - PO & Seq & Lot Code
640bA
640bAC                   exsr      clr$licinfo
640bA
640bAC                   eval      $lnemp#   = 0
640bAC                   eval      $lnuser   = #user
640bAC                   eval      $lnpgm    = #prog
640bAC                   eval      $lnjob    = #job
640bAC                   eval      $lnjobnbr = #jobn
640bA
640bAC                   eval      $lnwhse  = itwhse
640bAC                   eval      $lntype  = 'P'
640bAC                   eval      $lnlcns  = laOLcns
640bA
640bA*     PO number
640bA
640bAC                   eval      $lncodeu(1) = *on
640bAC                   eval      $lncode(1)  = '*PO'
640bAC                   eval      $lncseq(1)  = 1
640bA
640bA*     PO Seq number
640bA
640bAC                   eval      $lncodeu(2) = *on
640bAC                   eval      $lncode(2)  = '*POSEQ'
640bAC                   eval      $lncseq(2)  = 1
640bA
640bA*     Lot Code
640bA
640bAC                   eval      $lncodeu(3) = *on
640bAC                   eval      $lncode(3)  = '*LOT'
640bAC                   eval      $lncseq(3)  = 1
640bA
640bAC                   eval      $dricommand = '*LICINFO'
640bAC                   eval      $drisubcmd  = '%GET'
640bAC                   eval      $drisys2upd = 'D'
640bAC                   eval      chk4err     = *on
640bAC                   exsr      zzzdricop
640bAC                   if        error
640bAC                   endif
640bA
640bA*  Now process the return information and load export file fields.
640bA
640bAC                   eval      elawhs = itwhse
640bAC                   eval      elawhd = slwhdp
640bAC                   eval      elastp = slstyp
640bAC                   eval      elaasl = slaisl
640bAC                   eval      elaloc = slloc
640bAC                   eval      elalvl = slrlvl
640bAC                   eval      elahnd = slhand
640bAC                   eval      eladsp = sldisp
640bAC                   eval      elaitm = slitem
640bAC                   evalr     elaqt1 = %trimr(%editc(laQty1:'L'))
640bAC                   evalr     elaqt2 = %trimr(%editc(laQty2:'L'))
640bAC                   evalr     elaqt3 = %trimr(%editc(laQty3:'L'))
640dA*
640dAC                   eval      tllic1 = tllic1 + laQty1
640dAC                   eval      tllic2 = tllic2 + laQty2
640dAC                   eval      tllic3 = tllic3 + laQty3
640dA*
640bAC                   eval      elalcn = lalcns
640bAC                   eval      elaolc = laOLcns
640cAC                   eval      elaent = laentd
SWTaAC                   if        client = SWT
SWTaAC                             and laexpd = 0
SWTaAC                   eval      elaexp = laentd + 30000
SWTaAC                   else
640cAC                   eval      elaexp = laexpd
SWTaAC                   endif
640bA
640bA*     PO number
640bA
640bAC                   if        $lncodee(1) = $driok
640bAC                             and $lnvalchr(1) <> ' '
640bAC                   eval      elapo = %trim($lnvalchr(1))
640bAC                   else
640bAC                   if        %subst($liOLcns:1:3) = '*RT'
640bAC                   eval      elapo = '<return>'
640bAC                   else
640bAC                   eval      elapo = ' '
640bAC                   endif
640bAC                   endif
640bA
640bA*     PO Seq number
640bA
640bAC                   if        $lncodee(2) = $driok
640bAC                             and $lnvalnum(2) <> 0
640bAC                   eval      elapos = $lnvalnum(2)
640bAC                   else
640bAC                   eval      elapos = 0
640bAC                   endif
640bA
640bA*     Lot Code
640bA
EI  A*
EI  AC                   if        client = EI
EI  AC                   eval      elalot = %trim(elapo) +
EI  AC                                      %trim(%editc(elapos:'X'))
EI  AC                   else
EI  A*
640bAC                   if        $lncodee(3) = $driok
640bAC                             and $lnvalchr(3) <> ' '
640bAC                   eval      elalot = $lnvalchr(3)
640bAC                   else
640bAC                   eval      elalot = ' '
640bAC                   endif
EI  AC                   endif
EI  A*
640bA*
640bAC                   eval      eladsg = sldesg
640bAC                   eval      elapck = slpick
640fAC                   eval      elasts = slstat
640bA*
640bAC                   write (e) elarec
640bA*
640bAC                   enddo
640bA*
640bAC                   enddo
640bA*
640bAC     endexplcns    endsr
640dA*
730bA*----------------------------------------------------------------
730bA*  zzPickChange   Check for Pick Slot Change
730bA*----------------------------------------------------------------
730bA /free
730bA   begsr zzPickChange;
730bA     pickChange = *off;
730bA     chain (qewhse: qeitem) lastpick;
730bA     select;
730bA       when %found(lastpick)
730bA        and qedsp1 <> lpdisp;
730bA         lpdisp = qedsp1;
730bA         lpststs = %timestamp();
730bA         update lprec;
730bA         pickChange = *on;
730bA       when not %found(lastpick);
730bA         lpwhse = qewhse;
730bA         lpitem = qeitem;
730bA         lpdisp = qedsp1;
730bA         lpststs = %timestamp();
730bA         write lprec;
730bA         pickChange = *on;
730bA     endsl;
730bA   endsr;
730bA /end-free

640dA*----------------------------------------------------------------
640dA*
640dA*  ZZPRTERR  Print exception report when slot/license qty's don't match.
640dA*
640dAC     zzprterr      begsr
640dA*
640dAC                   if        not %open(it736pr)
640dAC                   exsr      zzprtovr
640dAC                   open      it736pr
640dAC                   eval      *in90 = '1'
640dAC                   endif
640dA*
640dAC                   if        *in90 = '1'
640dAC                   write     head1
640dAC                   write     columns
640dAC                   eval      *in90 = '0'
640dAC                   endif
640dA*
640dA*   Convert Quantity into Master/Case/Each as needed.
640dAC                   select
640dAC                   when          itflg2 = 'Y'
640dAC                             and itumq3 > 0
640dA*      Item sold as master/case/each only.
640dAC                   eval      slstk1 = SltQty / (itumq2 * itumq3)
640dAC                   eval      wkqty  = SltQty - (slstk1*(itumq2 * itumq3))
640dAC                   eval      slstk2 = wkqty / itumq3
640dAC                   eval      slstk3 = wkqty - (slstk2 * itumq3)
640dA*
640dA*
640dAC                   when          itflg1 = 'Y'
640dAC                             and itumq2 > 0
640dA*      Item sold as case/each only.
640dAC                   eval      slstk1 = SltQty / itumq2
640dAC                   eval      slstk2 = SltQty - (slstk1 * itumq2)
640dAC*
640dAC                   other
640dA*      Item sold as case only.
640dAC                   eval      slstk1 = SltQty
640dAC                   eval      slstk2 = 0
640dAC                   eval      slstk3 = 0
640dAC                   endsl
640dA*
640dAC                   write     detail1                              90
640dA*
640dAC                   eval      tllic1 = 0
640dAC                   eval      tllic2 = 0
640dAC                   eval      tllic3 = 0
640dA*
640dAC     keyla5        setll     licactive5
640dAC                   dou       forevr <> forevr
640dAC     keyla5        reade     licactive5
640bAC                   if        %eof(licactive5)
640dA
640dA*      Print exception license totals.
640dAC                   if        *in90 = '1'
640dAC                   write     head1
640dAC                   write     columns
640dAC                   eval      *in90 = '0'
640dAC                   endif
640dA*
640dAC                   write     total1                               90
640dA*
640dAC                   leave
640dAC                   endif
640dA*
640dAC                   eval      tllic1 = tllic1 + laQty1
640dAC                   eval      tllic2 = tllic2 + laQty2
640dAC                   eval      tllic3 = tllic3 + laQty3
640dA*
600dA*   Convert license qty to lowest form.
640dAC                   eval      LicQty = (laqty1 * itumq2 * itumq3)
640dAC                                      + (laqty2 * itumq3)
640dAC                                      +  laqty3
640dA*
640dA*   Convert Quantity into Master/Case/Each as needed.
640dAC                   select
640dAC                   when          itflg2 = 'Y'
640dAC                             and itumq3 > 0
640dA*      Item sold as master/case/each only.
640dAC                   eval      laqty1 = LicQty / (itumq2 * itumq3)
640dAC                   eval      wkqty  = LicQty - (laqty1*(itumq2 * itumq3))
640dAC                   eval      laqty2 = wkqty / itumq3
640dAC                   eval      laqty3 = wkqty - (laqty2 * itumq3)
640dA*
640dA*
640dAC                   when          itflg1 = 'Y'
640dAC                             and itumq2 > 0
640dA*      Item sold as case/each only.
640dAC                   eval      laqty1 = LicQty / itumq2
640dAC                   eval      laqty2 = LicQty - (laqty1 * itumq2)
640dAC*
640dAC                   other
640dA*      Item sold as case only.
640dAC                   eval      laqty1 = LicQty
640dAC                   eval      laqty2 = 0
640dAC                   eval      laqty3 = 0
640dAC                   endsl
640dA*
640dAC                   if        *in90 = '1'
640dAC                   write     head1
640dAC                   write     columns
640dAC                   write     detail1
640dAC                   eval      *in90 = '0'
640dAC                   endif
640dA*
640dAC                   write     detail2                              90
640dA*
640dAC                   enddo
640dA*
640dAC     endprterr     endsr
640dA*
640dA*----------------------------------------------------------------
640dA*
640dA*  ZZPRTOVR  Process printer file override
640dA*
640dAC     zzprtovr      begsr
640dA*
640dAC                   call      'GETRPT'
640dAC                   parm      '*DEVFORM'    $cmd              8
640dAC                   parm      'IT736PR'     $lrpt            10
640dAC                   parm      $pwhse        $whse             3 0
640dAC                   parm      ' '           $styp             1
640dAC                   parm      ' '           $whdp             5
640dAC                   parm                    $desc            50
640dAC                   parm                    $dev             10
640dAC                   parm                    $form            10
640dA*
640dAC                   if        $dev = ' '
640dAC                   eval      $dev = '*JOB'
640dAC                   endif
640dA*
640dAC                   if        $form = ' '
640dAC                   eval      $form = '*STD'
640dAC                   endif
640dA*
640dA*      Override printer file.
640dA*
640dA*          OVRPRTF FILE(OR630PR) OUTQ(*DEV) DEV($dev)
640dA*                  FORMTYPE($form)
640dA*
640dAC                   eval      qcmd = 'OVRPRTF FILE(IT736PR) '
640dAC                             + 'OUTQ('
640dAC                             + $DEV
640dAC                             + ') '
640dAC                             + 'FORMTYPE('
640dAC                             + $form
640dAC                             + ')'
640dA*
640dAC                   call      'QCMDEXC'
640dAC                   parm                    qcmd             80
640dAC                   parm      80            qlen             15 5
640dA*
640dAC     endprtovr     endsr
640bA*
640aA*----------------------------------------------------------------
640aA*----------------------------------------------------------------
640aA*                     DRI Subroutines
640aA*----------------------------------------------------------------
640aA*----------------------------------------------------------------
640aA
640aA*----------------------------------------------------------------
640aA*  clr$item  Clear $item data structure fields
640aA*----------------------------------------------------------------
640aA
640aAC     clr$item      begsr
640aAC                   eval      savever# = $itver#
640aAC                   clear                   $item
640aAC                   clear                   $item2
640aAC                   eval      $itver# = savever#
640aAC                   endsr
640aA
640aA*----------------------------------------------------------------
640aA*  clr$license  Clear $license data structure fields
640aA*----------------------------------------------------------------
640aA
640aAC     clr$license   begsr
640aAC                   eval      savever# = $liver#
640aAC                   clear                   $license
640aAC                   eval      $liver# = savever#
640aAC                   eval      $liemp# = 0
640aAC                   eval      $liuser = #curruser
640aAC                   eval      $lipgm  = #pgm
640aAC                   eval      $lijob  = #job
640aAC                   eval      $lijobn = #jobnbr
640aAC                   eval      $liTowhse = $pwhse
640aAC                   eval      $liTowhseu = *on
640aAC                   endsr
640aA
640aA*----------------------------------------------------------------
640aA*  clr$licinfo  Clear $licinfo data structure fields
640aA*----------------------------------------------------------------
640aA
640aAC     clr$licinfo   begsr
640aAC                   eval      savever# = $lnver#
640aAC                   clear                   $licinfo
640aAC                   eval      $lnver# = savever#
640aA
640aAC                   eval      $lnuser = #user
640aAC                   eval      $lnpgm  = #prog
640aAC                   eval      $lnjob  = #job
640aAC                   eval      $lnjobnbr = #jobn
640aA
640aAC                   endsr
640aA
640aA*----------------------------------------------------------------
640aA*  clr$slot  Clear $slot data structure fields
640aA*----------------------------------------------------------------
640aA
640aAC     clr$slot      begsr
640aAC                   eval      savever# = $slver#
640aAC                   clear                   $slot
640aAC                   clear                   $slot2
640aAC                   eval      $slver# = savever#
640aAC                   eval      $saemp#U = *on
640aAC                   eval      $saemp# = #emp#
640aAC                   endsr
640aA
640aA
640aA*----------------------------------------------------------------
640aA*  zzzdricop  Call DRICOP
640aA*----------------------------------------------------------------
640aA
640aAC     zzzdricop     begsr
640aAC                   eval      error = *off
640aA
640aAC                   select
640aAC                   when      $dricommand = '*SLOT'
640aAC                   eval      $dridata  = $slot
640aAC                   eval      $dridata2 = $slot2
640aAC                   when      $dricommand = '*ITEM'
640aAC                   eval      $dridata  = $item
640aAC                   eval      $dridata2 = $item2
640aAC                   when      $dricommand = '*LICENSE'
640aAC                   eval      $dridata  = $license
640aAC                   eval      $dridata2 = $license2
640aAC                   when      $dricommand = '*LICINFO'
640aAC                   eval      $dridata = $licinfo
640aAC                   endsl
640aA
640aAC                   select
640aA
640aAC                   when         $dricommand = '*ITEM'
640aAC                             or $dricommand = '*SLOT'
640aAC                             or $dricommand = '*LICENSE'
640aAC                   call(e)   'DRICOP'
640aAC                   parm                    $dricommand
640aAC                   parm                    $drisubcmd
640aAC                   parm                    $drisys2upd
640aAC                   parm      #prog         $driprogram
640aAC                   parm      ' '           $drireturn
640aAC                   parm      ' '           $drimessage
640aAC                   parm                    $dridata
640aAC                   parm                    $dridata2
640aA
640aAC                   other
640aAC                   call(e)   'DRICOP'
640aAC                   parm                    $dricommand
640aAC                   parm                    $drisubcmd
640aAC                   parm                    $drisys2upd
640aAC                   parm      #prog         $driprogram
640aAC                   parm      ' '           $drireturn
640aAC                   parm      ' '           $drimessage
640aAC                   parm                    $dridata
640aA
640aAC                   endsl
640aA
640aAC                   select
640aA
640aAC                   when      %error
640aAC                   eval      error = *on
640aAC*                  eval      errmsg    = 'Error occured on call to '
640aAC*                                      + 'DRICOP'
640aAC*                                      + '/' + %trim($drisubcmd)
640aAC*                                      + ' from ' + #prog
640aAC*                  if        zmsflag
640aAC*                  exsr      zm0105s
640aAC*                  else
640aAC*                  exsr      zm0105
640aAC*                  endif
640aA
640aAC                   when      $drireturn <> '*OK'
640aAC                   eval      error = *on
640aAC*                  if        zmsflag
640aAC*                  exsr      zm0001s
640aAC*                  else
640aAC*                  exsr      zm0001
640aAC*                  exsr      zzerrind
640aAC*                  endif
640aA
640aAC                   endsl
640aA
640aAC                   select
640aAC                   when      $dricommand = '*SLOT'
640aAC                   eval      $slot  = $dridata
640aAC                   eval      $slot2 = $dridata2
640aAC                   when      $dricommand = '*ITEM'
640aAC                   eval      $item  = $dridata
640aAC                   eval      $item2 = $dridata2
640aAC                   when      $dricommand = '*LICENSE'
640aAC                   eval      $license  = $dridata
640aAC                   eval      $license2 = $dridata2
640aAC                   when      $dricommand = '*LICINFO'
640aAC                   eval      $licinfo = $dridata
640aAC                   endsl
640aA
640aAC                   eval      zmsflag = *off
640aAC     enddricop     endsr
