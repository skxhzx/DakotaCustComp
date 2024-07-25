     H Option(*Nodebugio)
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR695   Print Transaction Audit Report
     *  13 April 2004
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    CRTBNDPGM PGM(*) SRCFILE(*) DFTACTGRP(*NO) ACTGRP(QILE)
     *
     *----------------------------------------------------------------
     *  Revisions
     *
417 A*    04/13/04  MLB  4.17
     *      - Created
500 A*    06/14/05  RLP  5.00
     *      - Fix: minor problem with building the command in OPNPRT
     *             was getting error if device = *JOB
     *
520 A*    02/05/09  CWM/MLB 5.20  01/26  02/04
     *      - Fix: Added support for new extended stop number
     *             Retrieve stop# in routine zzfgts pgm GETSTOP
520aA*    02/05/09  HNK  5.20a
     *      - Enh: Added client custom code support.
520bA*    02/04/09  MLB  5.20b
     *      - Fix: Revised PRTBLK routine to print report headings.
520cA*    02/05/09  MLB  5.20c
     *      - Enh: Revised program to add call to GETRPT to retrieve
     *        default printer settings.
520dA*    03/24/09  RBD  5.20d
     *      - Recompiled, OR695PR changed.
520eA*    12/03/08  CWM  5.20e
     *      - Fix: Added Print File Over ride code to work with new
     *      -      report distribution.  Commented out call to QCMDEXC
     *      -      from original process.
     *
520XA*    03/24/09  RH & RBD  5.20X    (removed now SVLb)
     *      - Commented out zzfgts routine for Saval.
530 A*    06/15/10  JCJ  5.30a
     *      - Fix: fixed last record processing in Stop summary. Was
     *             printing wrong stop number.
     *
640 A*    05/01/12  MLB/JCJ  6.40
     *      - Enh: Revised program to read LABEL76 instead of LABEL32
     *        so that labels are printed in pallet number sequence. This
     *        is being done to make it easier for the auditors to check
     *        each pallet since all the items for that pallet will be
     *        listed in sequence.
     *      - Enh: Revised program to retrieve dock door for transaction.
     *
640aA*    05/07/12  RBD  6.40a
     *      - Recompiled, LABEL31 changed.
     *
640bA*    05/15/12  RBD  6.40b
     *      - Fix: reinstated dev and form parms.  Have no idea why, but
     *        rev 520e had deleted them though OR690 is still sending
     *        them ... which was causing new parm for CDIa to be read
     *        as blanks.
     *
650aA*    12/19/13  JCJ  6.50a
     *      - Fix: Added chain to PIRITEM file in Cross Dock SR
650bA*    12/23/13  MLB  6.50b
     *     - Fix: Increased size of CURPAL, PALCNT to 3,0 from 2,0 and
     *       increased nbr of occurrences of PALSUM to 99 from 9.
650cA*    12/26/13  RBD  6.50c
     *     - Recompiled, LABEL76 changed.
710aA*    11/15/17  JCJ  7.10a
     *      - Enh: Added new stop/drop field.
     *
720aA*    09/19/18  DAS  7.20a
     *      - Revised to use PSTYPE='P' for TruckBuilder Enhanced.
     *
730aA*    03/15/19  MR  7.30a
     *      - Added p.exordh and call to exordh for order
     *        numbers greater that 7 in length.
730bA*
     *    09/03/19  KDE 7.30b
     *      - Do not close OR695PR in this program.  It is now controlled
     *        with normal RPG cycle
     *
740aA*    09/10/20  DAS 7.40a
     *      - Revised to set OHAORDA to OHCORD when blank
     *      - Revised OR695PR ...
     *        - Revised BULK and PICK records to use 15-char OHAORDA
     *          instead of 9-char ORDN#.
     *        - Revised stop field in records BULK, PICK, SETSUMD
     *          and ZONSUMD to be 5 digits instead of 3 digits.
     *        - Revised zzfgts to use $pwhse and $prtid.
     *        - Revised prtblk to print PICK instead of BULK.
     *          Re: At some point, BEGBLK stopped being printed and
     *          SETHED2 is printed instead.
740bA*    09/11/20  KDE 7.40b
     *      - Revised to use order from label file for calling EXORDH
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fischer
     *
FSHa *    06/14/10  GJA  FSHa
     *      - Enh: Change LABEL32 to LABEL32F so that report prints
     *             in stop order instead of slot order.
     *
FSHb *    11/22/10  GJA  FSHb
     *      - Fix: When pallet has a sub it was duplicating.  Need
     *             LABEL32t/LABEL33t with join on transaction.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: ISupply
     *
ISPa *    01/26/16  GJA  ISPa
     *      - Enh: Change LABEL32 to LABEL32J so that report prints
     *             in stop order descending instead of slot order.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Eastland
     *
EFCa *    12/12/13  GJA  EFCa
     *      - Enh: Change to print 80 column
     *  *****Must compile with 80
     *----------------------------------------------------------------
     *  Client Custom Revisions: Indianhead Foodservice (IFD)
     *
IFDaA*    02/05/09  HNK  IFDa
     *      - Enh: Print PICKIFD instead of PICK and SETHIFD instead
     *             of SETHED2.
     *
     *----------------------------------------------------------------
SVL A*  Client Custom Revisions: Saval
     *
SVL A*    03/23/09  RBD  SVL
     *      - Enh: Added printing of catchweight entry line/s.
SVLaA*    03/25/09  RH   SVLa
     *      - Enh: Print PICKSVL instead of PICK and SETHSVL instead
     *             of SETHED2.
SVLb *    06/10/10  GJA  SVLb    (was 5.20x)
     *      - Commented out zzfgts routine for Saval.
     *
     *----------------------------------------------------------------
JSL A*  Client Custom Revisions: Julius Silvert
     *
JSLa *    11/06/15  GJA  JSLa
     *      - Enh: Print PICKJSL instead of PICK and SETHJSL instead
     *             of SETHED2 like Saval
JSLb *    11/23/15  GJA  JSLb
     *      - Enh: Change LABEL32 to LABEL32F so that report prints
     *             in stop order instead of slot order.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRY A*    03/19/10  MLB  DRY
     *      - Enh: Added printing of catchweight entry line/s.
     *      - Added DRY to SVL mod.
DRYaA*    03/19/10  MLB  DRYa
     *      - Enh: Print PICKSVL instead of PICK and SETHSVL instead
     *             of SETHED2.
     *      - Added DRY to SVL mod.
DRYbA*    04/30/10  MLB  DRYb
     *      - Enh: Removed Dairyland from SVLa mod. Created new format
     *             PICKDRY and SETHDRY.
DRYcA*    04/30/10  MLB  DRYc
     *      - Enh: Revised program to retrieve Host truck number from
     *             OrdHM2.
     *      - Added file ORDHM2 to program.
DRYdA*    06/20/12  RH   DRYd
     *      - Enh: Replaced Mfg Item # with Slot to print. OR695PR
     *             changed.
     *----------------------------------------------------------------
     *  Client Custom Revisions: InterCounty Bakers
     *
ICBa *    07/13/12  GJA  ICBa
     *      - Print PICKCDI
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Glazier
     *
GFCaA*    05/02/12  JCJ  GFCa
     *      - Added GFC to SVLa mod.
     *
GFCbA*    05/10/12  JCJ  GFCb
     *      - Added stop number processing to cross dock routine.
     *
     *----------------------------------------------------------------
CDIaA*  Client Custom Revisions: Customized Distribution
     *
CDIaA*    05/08/12  RBD  CDIa
     *      - Added parm for route page which is passed back and forth
     *        each time OR690 calls OR695 for a new zone ... will use
     *        route page parm to print the route page number rather
     *        than the trans page number which starts over at 1 for
     *        each zone/report.
     *      - Print SETHDCDI instead of SETHD and add printing of
     *        PICKCDI and LASTCDI.
CDIb *    02/08/13  GJA  CDIb
     *      - Added memo lines at end of report
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: HM Wagner
     *
HMW A*    08/20/12  MLB  HMW
     *      - Revised program to print PICKCDI along with format
     *        PICK to add mfr nbr to audit report.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Hearn Kirkwood
     *
HMWaA*    12/18/13  JCJ  HKWa
     *      - Enh: added code to only print report if transaction has
     *        a customer flagged for Audit.
     *----------------------------------------------------------------
CLD A*  Client Custom Revisions: City Line
     *
CLD A*    12/27/13  RBD  CLD
     *      - Enh: Added printing of catchweight entry line/s.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Sofo Foods
     *
SOF A*    07/24/15  MLB  SOF
     *      - Added 2nd line to print item brand.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Earl's Organic Produce
     *
EOPa *    11/18/20  RTR  EOPa
     *      - Enh: Print PICKEOP instead of PICK and SETHEOP instead
     *             of SETHED2 like Saval
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: A&D Foods
     *
ADF A*    02/12/20  MLB  ADF
     *      - Enh: Added printing of catchweight entry line/s.
     *      - Added ADF to SVL mod.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    This program is a copy of PLST40WS. The purpose of this pro-
     *    gram is to allow an individual to audit the selection act-
     *    ivities of another individual. This version will not print any
     *    catchweight information.  Just the items to be selected along
     *    with any zone merges that are part of the run.  This program
     *    will only print information for a single transaction that is
     *    selected by the user.
     *
     *    This program prints on green bar paper instead of labels but
     *    uses the same basic logic as the labels. The biggest
     *    difference is that the layout is not defined in a table. The
     *    printer file defines all of the fields and record formats.
     *
     *    To print all of the labels exactly as they are in the tables,
     *    call this program like this:
     *
     *                      CALL PLBL40 *TEST1
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  70        Condition underline for 'Checked out to' field.
     *  76        NRF on chain to PIRUSER
     *  77        NRF on chain to PIRTRAN
     *  79        Chain indicator
     *  90        Overflow indicator for exception report
     *  91        Overflow indicator for catch weight report
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
SVL AFitemmsc   if   e           k disk
SVL AFpiritem   if   e           k disk
     Fpirtran   if   e           k disk
     Fpiruser1  if   e           k disk
     Fpltsum3   if   e           k disk
     Fpltstp1   if   e           k disk
     FLabel31   if   e           k disk
640 DF*Label32   if   e           k disk
640 MFLabel76   if   e           k disk
FSHaDFLabel32f  if   e           k disk
FSHbMFLabel32t  if   e           k disk
ISPaAFLabel32j  if   e           k disk
     FLabel33   if   e           k disk
FSHbMFLabel33t  if   e           k disk
DRYcAFordhm2    if   e           k disk      usropn
     Foptions   if   e           k disk
     FReports   if   e           k disk
520eDF** or695pr   o    e             printer oflind(*in90)
520eDF**                                     usropn
520eAFor695pr   o    e             printer oflind(*in90)

520aA*----------------------------------------------------------------
520aA*  Client id's for custom mods.
520aA*----------------------------------------------------------------

IFD AD/copy qcopysrc,id#ifd
SVL AD/copy qcopysrc,id#saval
FSHaAD/copy qcopysrc,id#fischer
DRY AD/copy qcopysrc,id#dairyla
EFCaAD/copy qcopysrc,id#eastlan
GFCaAD/copy qcopysrc,id#glazier
CDIaAD/copy qcopysrc,id#cdi
ICBaAD/copy qcopysrc,id#icb
HMW AD/copy qcopysrc,id#hmwagne
HKWaAD/copy qcopysrc,id#hkw
CLD AD/copy qcopysrc,id#citylin
JSLaAD/copy qcopysrc,id#jsl
SOF AD/copy qcopysrc,id#sofo
EOPaAd/copy qcopysrc,id#eop
ISPaAD/copy qcopysrc,id#isupply
ADF AD/copy qcopysrc,id#adf

520aAD client          s             10
520aAD clientloc       s             10

     *----------------------------------------------------------------
730aAD/copy qcopysrc,c#stdvar
730aAD/copy qcopysrc,p.exordh
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *    General
     *
     D a80             s              1    dim(80)
     *
     *    Printer override
     *
     D ovrprt          s             80    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Working Variables
     *
     D $cmd            s              8
     D $name           s             40
     D count           s              5  0
     D curcol          s                   like(pscol)
650bDD*curpal          s              2  0
650bMD curpal          s              3  0
     D currow          s                   like(psrow)
     D curunl          s                   like(psunld)
SVL AD cwgts           s              7  0
     D first           s              1
     D first2          s              1
     D forevr          s              1
     D kyltyp          s                   like(lbtype)
     D kytype          s                   like(pstype)
     D l               s              3  0
     D lbls            s              3  0
     D lcount          s              3  0
     D lincnt          s              3  0
     D lins            s              3  0
     D lmax            s              1  0
     D lstlb#          s                   like(lblbl#)
     D lstpid          s                   like(psplid)
     D lststp          s                   like(lbstop)
     D lstum           s                   like(lbutyp)
     D lstwdp          s                   like(lbwhdp)
     D opened          s              1
     D pal#            s              7  0
650bDD*palcnt          s              2  0
650bMD palcnt          s              3  0
     D remain          s              2  0
CDIaAD rtepag          s              4  0
     D s               s              3  0
720aAd tbEnhanced      s               n
720aAd tbPalletType    s              1
720aAd tbType          s              1
720aAd tbWhse          s              3  0
     D tmpzon          s                   like(psszon)
     D today           s              8  0
     D ttlcub          s              8  3
     D ttlpcs          s              7  0
     D ttlwgt          s              9  2
SVL AD wgts            s              7  0
     D wrkcnt          s              3  0
     D w1name          s             25
     D w1pcub          s              6  3
     D w1pick          s                   like(lbqpck)
     D w1ppcs          s              5  0
     D w1pstp          s              3  0
     D w1pwgt          s              7  2
     D w1qty2          s                   like(lbqpck)
     D w1rcnm          s             30
     D w1rcub          s              6  3
     D w1rpcs          s              5  0
740aDD*w1rstp          s              3  0
     D w1rwgt          s              7  2
     D w1scnm          s             30
CDIbAD w1scpo          s             15
     D w1scub          s              6  3
     D w1spcs          s              5  0
740aDD*w1sstp          s              3  0
     D w1swgt          s              7  2
     D $pdev           s             10
     D $pform          s             10
HKWaAD AuditCustFlag   s              1    inz('N')
     *----------------------------------------------------------------
     *  *SYSTEM  -  System options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *
     * Data structure
     *
     D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opten2               117    117
     *----------------------------------------------------------------
     *  Data structure for label variables.
     *
     D dslbl           ds                  occurs(18)
     D  @var                   1    120
     D  @beg                 121    240
     D  @end                 241    360
     D  @len                 361    480
     *----------------------------------------------------------------
     *  Stop summary data structure for one set of labels.
     *  Maximum of 9 stops on one pallet, for fixed section items.
     *  Maximum of 99 stops on one pallet, for PIR section items.
     *
     D stpsum          ds                  occurs(99)
     D  dssstp                 1      2  0
     D  dsscub                 3      8  3
     D  dsswgt                 9     15  2
     D  dsspcs                16     18  0
     D  dsscnm                19     58
     *----------------------------------------------------------------
     *  Pallet summary data structure for one set of labels.
     *
650bDD*palsum          ds                  occurs(9)
650bMD palsum          ds                  occurs(99)
     D  dsppal                 1      7  0
     D  dspstp                 8      9  0
     D  dspcub                10     15  3
     D  dspwgt                16     22  2
     D  dsppcs                23     25  0
     D  stp                   26     43
     D  dsppli                44     50  0
     *----------------------------------------------------------------
     *  PIR stop summary data structure for route.
     *
     D pirsum          ds                  occurs(99)
     D  dsrstp                 1      2  0
     D  dsrcub                 3      8  3
     D  dsrwgt                 9     15  2
     D  dsrpcs                16     18  0
     D  dsrwdp                19     23
     D  dsrcnm                24     63
     D  dsrflg                64     64
     *----------------------------------------------------------------
SVL A* Catchweight Entry Fields.
SVL AD wgtblank        c                   const('________/____')
     *
SVL AD wgtds           ds
SVL AD p1wgt1                              overlay(wgtds : *next)
SVL AD                                     like(wgtln)
SVL AD p1wgt2                              overlay(wgtds : *next)
SVL AD                                     like(wgtln)
SVL AD p1wgt3                              overlay(wgtds : *next)
SVL AD                                     like(wgtln)
SVL AD p1wgt4                              overlay(wgtds : *next)
SVL AD                                     like(wgtln)
SVL AD p1wgt5                              overlay(wgtds : *next)
SVL AD                                     like(wgtln)
SVL AD p1wgt6                              overlay(wgtds : *next)
SVL AD                                     like(wgtln)
SVL AD p1wgt7                              overlay(wgtds : *next)
SVL AD                                     like(wgtln)
SVL AD*p1wgt8                              overlay(wgtds : *next)
SVL AD*                                    like(wgtln)
SVL AD*p1wgt9                              overlay(wgtds : *next)
SVL AD*                                    like(wgtln)
SVL AD*p1wgt10                             overlay(wgtds : *next)
SVL AD*                                    like(wgtln)
SVL AD*p1wgt11                             overlay(wgtds : *next)
SVL AD*                                    like(wgtln)
SVL AD*p1wgt12                             overlay(wgtds : *next)
SVL AD*                                    like(wgtln)
SVL AD wgtln                         13    overlay(wgtds:1) dim(7)
SVL AD*wgtln                          9    overlay(wgtds:1) dim(12)
     *
     *----------------------------------------------------------------
     *  *PICKLBL  -  Picking label options
     *----------------------------------------------------------------
     *
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
     D opzdta          ds
     D  opclvl                 1      3  0
     D  opcwra                 4      4
     D  opcwrb                 5      5
     D  opuwra                 6      6
     D  opuwrb                 7      7
     D  optext                 8     50
     D  operr                 51     52  0
     D  opcwgt                53     54  0
     D  oplpgm                55     64
     D  oppdev                65     74
     D  oppfrm                75     84
     D  optend               117    117
640 A*
640 A*----------------------------------------------------------------
640 A*
640 AD $lparm          ds
640 AD  $lcmd                  1      8
640 AD  $lprg                  9     18
640 AD  $luky                 19     68
640 AD  $lrtn                 69     76
640 AD  $lerm                 77    136
640 AD  $lmsg                 77     80
640 A*
640 A*   Redefine key
640 A*
640 AD  $lwhse                19     21  0
640 AD  $lrtid                22     26
640 AD  $ltrn#                27     33  0
640 AD  $lwhdp                34     38
640 AD  $ldoor                39     41  0
640 A*
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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
     *  Called Programs Prototypes
     *----------------------------------------------------------------

720aAd/copy qcopysrc,p.gettbtyp

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   Command
     *              *REPRINT -  Reprint labels as report.
     *              *REPLEN  -  Print potential replenishments.
     *      $PWHSE  Warehouse
     *      $PRTID  Route Id
     *      $PCOMP  Compartment
     *      $PTZON  Truck zone
     *      $PGEN   Generation
     *      $PSZON  Slot zone
     *      $PTRUK  Truck
     *      $PRTE   Route
     *      OPZDTA  Picking label options
     *      $PTRN#  Transaction number for reprints
     *              Batch number for *REPL
     *      $PDEV   Print device
     *      $PFORM  Form type
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
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $pcomp            1
     C                   parm                    $ptzon            6
     C                   parm                    $pgen             1 0
     C                   parm                    $pszon            6
     C                   parm                    $ptruk           10
     C                   parm                    $prte             5
     C                   parm                    opzdta
     C                   parm                    $ptrn#            7 0
520eDC*                  parm                    $pdev            10
520eDC*                  parm                    $pform           10
640bMC                   parm                    $pdev            10
640bMC                   parm                    $pform           10
CDIaAC                   parm                    $ppage            4 0
     *----------------------------------------------------------------
     *  Main line
     *
     * Check to see if this is only a test.
     *
     C                   if        $pcmd = '*TEST1  '
     C                   exsr      test1
     C                   goto      bottom
     C                   endif
     *
CDIaAC                   if        client = cdi
CDIaAC                   eval      rtepag = $ppage
CDIaAC                   endif
     *
     * Open printer file for zone.
     *
520eDC*                  exsr      opnprt
     *
     * Print bulk picks for zone.
     *
     C                   exsr      prtblk
     *
     * Print selection labels for zone.
     *
     *    Note: First the pallet summary records will be read
     *          and the information saved.  Then, when the
     *          transaction number changes, we go and print
     *          the labels for the previous transacton
     *          number (LSTTRN).
     *
     *    Loop through truck pallets for zone.
     *
     C                   eval      first = *on
     *
720aDC**                 eval      kytype = 'O'
720aMC                   eval      kytype = tbPalletType
     C     keyps3        setll     pltsum3
     C                   dou       forevr <> forevr
     C     keyps3        reade     pltsum3                                79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *     Skip pallet if nothing was picked.
     *
     C                   if        pspcs = 0
     C                   iter
     C                   endif
     *
     *     Check Transaction for an audit customer
     *
HKWaAC                   if        $pcmd <> '*REPRINT'
HKWaAC                   if        client = HKW
HKWaAC                   eval      AuditCustFlag = 'N'
HKWaAC     keyl76b       setll     label76
HKWaAC                   dou       %eof(label76)
HKWaAC     keyl76b       reade     label76
HKWaAC                   if        not %eof(label76)
HKWaAC                   if        %subst(ohmisc:11:1) = 'Y'
HKWaAC                   eval      AuditCustFlag = 'Y'
HKWaAC                   leave
HKWaAC                   endif
HKWaAC                   endif
HKWaAC                   enddo

HKWaAC                   if        AuditCustFlag = 'N'
HKWaAC                   iter
HKWaAC                   endif

HKWaAC                   endif
HKWaAC                   endif
     *
     *     First time through initialization.
     *
     C                   if        first = *on
     C                   exsr      zzgtpt
     C                   eval      lsttrn = pstrn#
     C                   eval      palcnt = 0
     C                   eval      first = *off
     C                   endif
640 A*
640 A* Retrieve dock door for transaction.
640 AC                   eval      $lprg  = #prog
640 AC                   eval      $lwhse = $pwhse
640 AC                   eval      $lrtid = $prtid
640 AC                   eval      $ltrn# = lsttrn
640 AC                   eval      $lwhdp = *blanks
640 AC                   eval      $ldoor = 0
640 AC                   call      'DH900'
640 AC                   parm                    $lparm
640 A*
640 AC                   if        client = Dairyland
640 A*      Dairyland is loading host truck# instead.
640 AC                   else
640 AC                   eval      drytrck = 'Door: '
640 AC                                       + %editc($ldoor:'4')
640 AC                   endif
     *
     *     If transaction number changed, go and print the detail
     *       for the previous transaction (LSTTRN).
     *
     C                   if        pstrn# <> lsttrn
     C                   eval      curunl = psunld
     C                   eval      currow = psrow
     C                   eval      curcol = pscol
     C                   exsr      prtsel
     C     keyps         setll     pltsum3
     C                   read      pltsum3                                79
     C                   exsr      zzgtpt
     C                   eval      lsttrn = pstrn#
     C                   eval      palcnt = 0
     C                   endif
     *
     *     Add pallet info to pallet summary data structure.
     *
     C                   add       1             palcnt
     C     palcnt        occur     palsum
     C                   eval      dsppal = pspal#
     C                   z-add     pscube        dspcub
     C                   z-add     psswgt        dspwgt
     C                   z-add     pspcs         dsppcs
     C                   eval      dspstp = 0
     C                   eval      lststp = -(1)
     C                   eval      dsppli = psplid
     C     keyss1        setll     pltstp1
     C                   dow       forevr = forevr
     C     keyss1        reade     pltstp1                                78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   if        pssstp <> lststp
     C                   add       1             dspstp
     C                   eval      lststp = pssstp
     C                   endif
     C                   enddo
     *
     C                   enddo
     *
     *   Print last pallet(s), if any.
     *
     C                   if        palcnt > 0
     C                   exsr      prtsel
     C                   endif
     *
     *   Bye, Bye.
     *
     C     bottom        tag
     *
CDIaA*
CDIaA*   If $ppage = rtepag, which means nothing was printed, skip this
CDIaA*   logic, else a blank page with 'LAST PAGE' will print.
CDIaA*
CDIaAC                   if        client = cdi and $ppage <> rtepag
CDIaAC                   eval      $ppage = rtepag
CDIaAC     keyps         setgt     pltsum3
CDIaAC                   dou       forevr <> forevr
CDIaAC     keyhm2        reade     pltsum3
CDIaAC                   if        %eof
CDIaAC                   write     lastcdi
CDIaAC                   leave
CDIaAC                   endif
CDIaAC                   if        pspcs = 0
CDIaAC                   iter
CDIaAC                   else
CDIaAC                   leave
CDIaAC                   endif
CDIaAC                   enddo
CDIaAC                   endif
     *
     C                   eval      *inlr = *on
     *
     *   Close up shop and return home.
     *
730bDC*r                 if        opened = *on
730bDC*r                 close     or695pr
730bDC*r                 endif
     *
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
520aA
520aA*  Get client id
520aA
520aAC                   call      'GETCLIENT'
520aAC                   parm                    client
520aAC                   parm                    clientloc
520aA
     C                   eval      forevr = *off
     C                   eval      lmax = 1
     C                   eval      lcount = 1
720aAc*
720aAc*   Determine if using TruckBUilder Enhanced
720aAc*
720aA /free
720aA      tbWhse = $pwhse;
720aA      GetTBType(tbWhse: $prtid: tbType);
720aA      if tbType = 'E';
720aA        tbEnhanced = *on;
720aA        tbPalletType = 'P';
720aA      else;
720aA        tbEnhanced = *off;
720aA        tbPalletType = 'O';
720aa      endif;
720aA /end-free
     *
     *  Define key for OPTIONS file.
     *
     C     opkey         klist
     C                   kfld                    opwhse
     C                   kfld                    opcode
     *
SVL A*   Full PIRITEM key
     *
SVL AC     itkey         klist
SVL AC                   kfld                    $pwhse
SVL AC                   kfld                    lbitem
     *
     *  Define partial key for PLTSUM3 file.
     *
     C     keyps3        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kytype
     C                   kfld                    $pcomp
     C                   kfld                    $ptzon
     C                   kfld                    $pgen
     C                   kfld                    $pszon
     *
     C     keyps         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kytype
     C                   kfld                    $pcomp
     C                   kfld                    $ptzon
     C                   kfld                    $pgen
     C                   kfld                    $pszon
     C                   kfld                    curunl
     C                   kfld                    currow
     C                   kfld                    curcol
     *
     *  Define partial key for PLTSTP1 file.
     *
     C     keyss1        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    psplid
     C                   kfld                    psrow
     C                   kfld                    pscol
     *
     *  Define partial key for LABEL31 file.
     *
     C     keyl31        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kyltyp
     C                   kfld                    psplid
     *
     *  Define partial key for LABEL32 & LABEL34 file.
     *
     C     keyl32        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kyltyp
     C                   kfld                    lsttrn
     *
     *  Define partial key for LABEL33 file.
     *
     C     keyl33        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    lsttrn
     *
     *  Define partial key for LABEL3 file.
     *
     C     keyl3f        klist
     C                   kfld                    $ptrn#
     C                   kfld                    $pwhse
640 A*
640 A*  Define partial key for LABEL76 file.
640 A*
640 AC     keyl76        klist
640 AC                   kfld                    $pwhse
640 AC                   kfld                    $prtid
640 AC                   kfld                    lsttrn
HKWaA*
HKWaAC     keyl76b       klist
HKWaAC                   kfld                    $pwhse
HKWaAC                   kfld                    $prtid
HKWaAC                   kfld                    pstrn#
DRYcA*
DRYcA*  Define full key for ORDHM2 file.
DRYcA*
DRYcAC     keyhm2        klist
DRYcAC                   kfld                    $pwhse
DRYcAC                   kfld                    $prtid
     *
     *  Define key for PIRITEM file. (FOR BROKEN CASE ITEM)
     *
     C     keyib         klist
     C                   kfld                    $pwhse
     C                   kfld                    lbitem
     *
     *  Define key for ITEMLNK file.
     *
     C     keyil         klist
     C                   kfld                    $pwhse
     C                   kfld                    lbitem
     *
     *  Define key for REPORTS file.
     *
     C     Rpkey         Klist
     C                   Kfld                    Wkprtf           10
DRYcA*
DRYcAC                   if        client = Dairyland
DRYcAC                   if        not %open(ordhm2)
DRYcAC                   open      ordhm2
DRYcAC                   endif
DRYcA*
DRYcAC     keyhm2        setll     ordhm2
DRYcAC     keyhm2        reade     ordhm2
DRYCAC                   if        %eof(ordhm2)
DRYcAC                   eval      hmmsc1 = ' '
DRYcAC                   endif
DRYcAC                   eval      drytrck = %subst(hmmsc1:1:10)
DRYcA*
DRYcAC                   endif
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     *  Convert today's date into MM/DD/YY format.
     *
     C                   eval      $cvcmd = '*CURMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     *
     C                   eval      rdate = $cvd6o
     C                   time                    rtime
     C*
     C*   Get report title.
     C*
     C                   MOVEL     'OR695PR   '  WKPRTF
     C                   MOVE      *BLANKS       RPTTTL
     C                   MOVE      *BLANKS       $PSTR
     C     Rpkey         Chain     Reports
     C                   If        %Found
     C                   Movel     RPDESC        $PSTR            60
     C                   Else
     C                   eval      $PSTR = ' '
     C                   Endif
     C                   Z-ADD     40            $Plen             3 0
     C*
     C*   Center report title.
     C*
     C                   CAll      'CENTER'
     C                   Parm                    $Pstr
     C                   Parm                    $Plen
     C                   Movel     $Pstr         Rptttl
     *
     *   Define variables.
SVLa C                   move      *blanks       itvit#
     *
     *   Get system options.
     *
     C                   eval      opwhse = 0
     C                   eval      opcode = '*SYSTEM '
     C     opkey         chain     options                            79
     C                   if        *in79
     C                   eval      opletd = 'Y'
     C                   endif
     *
     *  Get variable information for labels
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETPAL  Get pallet number.
     *
     C     getpal        begsr
     C                   eval      pal# = 0
     C     1             do        palcnt        curpal
     C     curpal        occur     palsum
     C                   if        dsppli = lbpal#
     C                   eval      pal# = dsppal
     C                   endif
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPNPRT  Open printer file.
     *
     C     opnprt        begsr
     *
     *   Open printer file for department.
     *
     C                   if        opened <> *on
     *
     *      If printer already open then close it.
     *
     C                   if        opened = *on
     C                   close     or695pr
     C                   endif
     *
     *      Override printer file.
     *
     *          OVRPRTF FILE(OR695PR) OUTQ(*DEV) DEV(rodev)
     *                  FORMTYPE(roform)
     *
     C                   movea     ovrprt(1)     a80
520cA*
520cAC                   if        $pdev = '*DFT      '
520cAC                   call      'GETRPT'
520cAC                   parm      '*DEVFORM'    $CMD              8
520cAC                   parm      'OR695PR'     $LRPT            10
520cAC                   parm      $pwhse        $whse             3 0
520cAC                   parm      ' '           $styp             1
520cAC                   parm      ' '           $whdp             5
520cAC                   parm                    $desc            50
520cAC     $pdev         parm      ' '           $dev             10
520cAC     $pform        parm      ' '           $form            10
520cAC                   endif
     *
     *    Use printer device selected by user.
     C                   if        $pdev <> '*JOB    '
     C                   movea     $pdev         a80(38)
     C                   else
500 DC*                  movea     '*DEV      '  a80(38)
500 AC                   movea     '*JOB      '  a80(38)
     C                   endif
     *
     *    Use form type selected by user.
     C                   if        $pform <> '*STD    '
     C                   movea     $pform        a80(59)
     C                   else
     C                   movea     '*STD      '  a80(59)
     C                   endif
     *
     C                   movea     a80           qcmd
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
     *
     *      Open printer file.
     *
     C                   open      or695pr
     C                   eval      opened = *on
     *
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PRTBLK  Print bulk pick labels for route/department.
     *
     C     prtblk        begsr
     *
     C                   eval      first = *on
     *
     *  Loop bulk picks for zone.
     *
     *    Revised to only use a pallet id once.
     *
     C                   eval      lstpid = -(1)
     C                   eval      kytype = 'B'
     C     keyps3        setll     pltsum3
     C                   dou       forevr <> forevr
     C     keyps3        reade     pltsum3                                79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   if        psplid = lstpid
     C                   iter
     C                   endif
     C                   eval      lstpid = psplid
     *
     *    Loop through bulk pick labels for pallet.
     *      Note: There should only be one label, but this keeps
     *            the coding consistant with replenishments.
     *
     *      The above statment is false. There can be more than
     *      one bulk pick to a pallet especially if an item didn't
     *      have home slot.
     *
     *      The 413 fix was necessary because the LABEL31 file
     *      is joined to the PLTSUM file only using the pallet
     *      id. When there are multiple bulk picks on a pallet
     *      the LABEL31 ends up with duplicate records. These
     *      dups are created in sequence so we can check the
     *      label number against the last one and skip the
     *      record if they are the same.
     *
520bA*
520bA*   Print header for this set of bulk labels.
520bA*
520bA*
520bA*     Add pallet info to pallet summary data structure.
520bA*
520bAC                   add       1             palcnt
520bAC     palcnt        occur     palsum
520bAC                   eval      dsppal = pspal#
520bAC                   z-add     pscube        dspcub
520bAC                   z-add     psswgt        dspwgt
520bAC                   z-add     pspcs         dsppcs
520bAC                   eval      dspstp = 0
520bAC                   eval      lststp = -(1)
520bAC                   eval      dsppli = psplid
520bAC     keyss1        setll     pltstp1
520bAC                   dow       forevr = forevr
520bAC     keyss1        reade     pltstp1                                78
520bAC                   if        *in78
520bAC                   leave
520bAC                   endif
520bAC                   if        pssstp <> lststp
520bAC                   add       1             dspstp
520bAC                   eval      lststp = pssstp
520bAC                   endif
520bAC                   enddo
520bA*
520bAC                   eval      lsttrn = pstrn#
520bAC                   exsr      setbeg
520bA*
520bAC                   if        first = *on
520bAC                   exsr      zzgtpt
520bAC                   eval      lsttrn = pstrn#
520bAC                   eval      palcnt = 0
520bAC                   eval      first = *off
520bAC                   endif
640 A*
640 A* Retrieve dock door for transaction.
640 AC                   eval      $lprg  = #prog
640 AC                   eval      $lwhse = $pwhse
640 AC                   eval      $lrtid = $prtid
640 AC                   eval      $ltrn# = lsttrn
640 AC                   eval      $lwhdp = *blanks
640 AC                   eval      $ldoor = 0
640 AC                   call      'DH900'
640 AC                   parm                    $lparm
640 A*
640 AC                   if        client = Dairyland
640 A*      Dairyland is loading host truck# instead.
640 AC                   else
640 AC                   eval      drytrck = 'Door: '
640 AC                                       + %editc($ldoor:'4')
640 AC                   endif
520bA*
     C                   eval      lstlb# = -(1)
     C                   eval      kyltyp = 'B'
     C     keyl31        setll     label31
     *
     C                   dou       forevr <> forevr
     *
     C     keyl31        reade     label31                                78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   if        lblbl# = lstlb#
     C                   iter
     C                   endif
     C                   eval      lstlb# = lblbl#
     *
     *       Skip label if nothing was picked.
     *
     C                   if        lbqpck = 0
     C                   iter
     C                   endif
     *
     *       Print beginning bulk pick label.
740aA*       *** Never executed because first set off above ***
     *
     C                   if        first = *on
     C                   eval      *in81 = *on
     C                   write     begblk
     C                   eval      *in81 = *off
     C                   eval      first = *off
     C                   endif
     *
     *       Print warning for bulk/replenishment combo.
     *
     *       Print bulk label.
     *
740aD**   Following line removed because no longer printing BULK
740aDC**                 eval      w1qty = lbqpck
     C                   movel     lbitem        w1item
520 AC                   eval      w1out = lbasl2
740aD**   Following line removed because no longer printing BULK
740aDC**                 eval      w1um  = lbucod
520 A*
520 AC                   eval      $scmd = '*ORDSTP '
520 MC                   z-add     lbord         $sord
520 AC                   eval      $sDstp = 0
SVLbAC                   if        client = SAVAL
SVLbAC                   eval      wostop = lbstop
SVLbAC                   else
520 DC                   exsr      zzfgts
520 AC                   if         $sstp > 0
520 MC                   eval      wostop = $sstp
740aAC                   eval      hostStop = $sstp
520 AC                   else
520 AC                   eval      wostop = lbstop
740aAC                   eval      hostStop = lbstop
520 AC                   endif
SVLbAC                   endif
730aA *
730aA * Check if order number is greater than 7 in length.
730aAC                   clear                   ordn#
730aAC                   eval      ordn# = %char(ohcord)
730aA /free
730aA      exWhse = pswhse;
740bD      //ohaord = ohcord;
740bM      ohaord = lbord;
730aA      exordh ('*GET': exRtnCode: exRtnMsg: exWhse: ohaord:
730aA              ohaaudflg: ohaaudid: ohaaudcmp: ohaaudby: ohaaudts:
730aA             ohaorda: ohacusta);
730aA /end-free
730aAC                   if        ohaorda <> *blanks
730aAC                   movel     ohaorda       ordn#
730aAC                   endif
520 A*
740aA
740aA*    Change to write PICK because SETHED2 is printed when SETBEG
740aA*    is called and BEGBLK never gets printed
740aA
740aDC**                 write     bulk
740aAC                   write     pick
     C                   if        *in90
     C                   write     begblk2
     C                   eval      *in90 = *off
     C                   endif
     *
740aD**   Following line removed because no longer printing BULK
740aD**   No idea why what this code was used for
740aD**
740aDC**                 if        lbdsp2 <> *blanks
740aDC**                 eval      w1qty = lbqrmn
740aDC**                 endif
     *
     C                   enddo
     *
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PRTSEL  Print normal selection labels for zone.
     *
     C     prtsel        begsr
     *
     *   Print header for this set of selection labels.
     *
     C                   exsr      setbeg
     *
     *   Loop through selection labels for transaction.
     *
     C                   eval      count = 0
     C                   eval      kyltyp = 'O'
FSHaAC                   select
FSHaAC                   when      client = Fischr
FSHbMC     keyl32        setll     label32t                               78
JSLbAC                   when      client = JSilvert
FSHaAC     keyl32        setll     label32f
ISPaAC                   when      client = ISupply
ISPaAC     keyl32        setll     label32j
FSHaAC                   other
640 DC*    keyl32        setll     label32
640 MC     keyl76        setll     label76
FSHaAC                   endsl
     *
     C                   dou       forevr <> forevr
FSHaAC                   select
FSHaAC                   when      client = Fischr
FSHbMC     keyl32        reade     label32t                               78
JSLbAC                   when      client = JSilvert
FSHaAC     keyl32        reade     label32f                               78
ISPaAC                   when      client = ISupply
ISPaAC     keyl32        reade     label32j                               78
FSHaAC                   other
640 DC*    keyl32        reade     label32                                78
640 MC     keyl76        reade     label76                                78
FSHaAC                   endsl
     C                   if        *in78
     C                   leave
     C                   endif
     *
     *     Skip label if cross dock.
     *
     C                   if        lbstyp = 'X'
     C                   iter
     C                   endif
640 A*
640 A*     Skip label if wrong label type.
640 A*
640 AC                   if        lbtype <> kyltyp
640 AC                   iter
640 AC                   endif
     *
     *     Skip label if nothing was picked.
     *
     C                   if        lbqpck = 0
     C                   iter
     C                   endif
     *
     C                   add       1             count
     *
     *     See if we should print the "before" um warning.
     *
     C                   if        lbutyp <> 'N'  and
     C                             opuwrb = 'Y'
     C                   endif
     *
     *     Initialize label fields.
     *
     C                   eval      w1qty2 = lbqpck
     *
     *     Either print a combination label ...
     *
     *        Print one label.
     *
     C                   eval      w1pick = lbqpck
     C                   movel     lbitem        w1item
640 A*
640 AC     itkey         chain     piritem
640 AC                   if        not %found(piritem)
640 AC                   eval      itdesc = *blanks
640 AC                   eval      itpdsc = *blanks
CDIaAC                   eval      itvit# = *blanks
640 AC                   endif
640 A*
SVLa C                   select
SVLa C                   when      client = SAVAL
DRYa C                             or client = Dairyland
GFCa C                             or client = Glazier
JSLaAC                             or client = JSilvert
EOPaAC                             or client = EarlsOrganic
SOF AC                             or client = SofoFoods
     C*    itkey         chain     piritem
     C*                  if        not %found(piritem)
     C*                  eval      w1desc = *blanks
     C*                  eval      w1pack = *blanks
     C*                  else
SVLa C                   movel     itdesc        w1desc
SVLa C                   movel     itpdsc        w1pack
     C*                  endif
     *
SVLa C                   eval      w1brnd = *blanks
SOF AC                   eval      imbrnd = ' '
SVLa C     itkey         chain     itemmsc
SVLa C                   if        %found(itemmsc)
SVLa C                   movel     imbrnd        w1brnd
SVLa C                   endif
SVLa C                   endsl
     C                   eval      w1out = lbasl2
     C                   exsr      zzoflo
520 A*
520 AC                   eval      $scmd = '*ORDSTP '
520 AC                   z-add     lbord         $sOrd
520 AC                   eval      $sDstp = 0
SVLbAC                   if        client = SAVAL
SVLbAC                   eval      wostop = lbstop
SVLbAC                   else
520 AC                   exsr      zzfgts
520 AC                   if         $sstp > 0
520 MC                   eval      wostop = $sstp
740aAC                   eval      hostStop = $sstp
520 AC                   else
520 AC                   eval      wostop = lbstop
740aAC                   eval      hostStop = lbstop
520 AC                   endif
SVLbAC                   endif
520 A*
SVLaAC                   select
IFDaMC                   when      client = IFD
IFDaDC*                  if        client = IFD
IFDaAC                   write     pickifd
SVLaMC                   when      client = SAVAL
GFCaAC                             or client = Glazier
SVLaAC                   write     picksvl
JSLaAC                   when      client = JSilvert
JSLaAC                   write     pickjsl
EOPaAC                   when      client = EarlsOrganic
EOPaAC                   write     pickeop
DRYbAC                   when      client = Dairyland
DRYbAC                   write     pickdry
EFCaAC                   when      client = Eastland
EFCaAC                   write     pick80
SVLaAC                   other
IFDaDC*                  else
730aA *
730aA * Check if order number is greater than 7 in length.
730aAC                   clear                   ordn#
730aAC                   eval      ordn# = %char(ohcord)
730aA /free
730aA      exWhse = pswhse;
740bD      //ohaord = ohcord;
740bM      ohaord = lbord;
730aA      exordh ('*GET': exRtnCode: exRtnMsg: exWhse: ohaord:
730aA              ohaaudflg: ohaaudid: ohaaudcmp: ohaaudby: ohaaudts:
730aA             ohaorda: ohacusta);
730aA /end-free
730aAC                   if        ohaorda <> *blanks
730aAC                   movel     ohaorda       ordn#
730aAC                   endif
     C                   write     pick
SVLaAC                   endsl
IFDaAC*                  endif
IFDaA*
CDIaAC                   select
CDIaAC                   when      client = CDI
HMW AC                             or client = HMWagner
CDIaAC                   write     pickcdi
CDIaAC                   add       1             lincnt
ICBaAC                   when      client = icb
ICBaAC                   write     pickcdi
SOF A*
SOF AC                   when      client = SofoFoods
SOF AC                   write     picksof
SOF AC                   add       1             lincnt
SOF A*
CDIaAC                   other
CDIaAC                   endsl

     C                   add       1             lincnt
     C                   if        *in90
     C                   eval      lincnt = 0
CDIaAC                   select
CDIaAC                   when      client = CDI
CDIaAC                   eval      rtepag = rtepag + 1
CDIaAC                   write     sethdcdi
EFCaAC                   when      client = Eastland
EFCaAC                   write     sethd80
CDIaAC                   other
     C                   write     sethd
CDIaAC                   endsl
IFDaA*
SVLaAC                   select
SVLaAC                   when      client = IFD
IFDaAC*                  if        client = IFD
IFDaAC                   write     sethifd
SVLaAC                   when      client = SAVAL
GFCaAC                             or client = Glazier
SVLaAC                   write     sethsvl
JSLaAC                   when      client = JSilvert
JSLaAC                   write     sethjsl
EOPaAC                   when      client = EarlsOrganic
EOPaAC                   write     setheop
DRYbAC                   when      client = Dairyland
DRYbAC                   write     sethdry
EFCaAC                   when      client = Eastland
EFCaAC                   write     sethed280
SVLaAC                   other
IFDaAC*                  else
     C                   write     sethed2
IFDaAC*                  endif
SVLaAC                   endsl
IFDaA*
     C                   add       3             lincnt
     C                   eval      *in90 = *off
     C                   endif
     *
     *
SVL A*   If Saval, print catchweight entry line/s.
     *
SVL AC                   if        client = saval
DRY AC                             or client = Dairyland
GFCaAC                             or client = Glazier
CLD AC                             or client = Cityline
JSLaAC                             or client = JSilvert
ADF AC                             or client = AandDFoods
SVL AC                   exsr      zrcwgt
SVL AC                   endif
     *
     C                   enddo
     *
     *   Print summary for this set of selection labels.
     *
     C                   exsr      setend
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PRTXDK  Print cross dock labels.
     *
     C     prtxdk        begsr
     *
     *
     *   Loop through selection labels for transaction.
     *
     C                   eval      count = 0
     C                   eval      kyltyp = 'O'
     *
     C                   if        $pgen = 1
640 DC*    keyl32        setll     label32
640 MC     keyl76        setll     label76
     C                   else
640 DC*    keyl32        setll     label32
640 MC     keyl76        setll     label76
     C                   endif
     *
     C                   dou       forevr <> forevr
     C                   if        $pgen = 1
640 DC*    keyl32        reade     label32                                78
640 MC     keyl76        reade     label76                                78
     C                   else
640 DC*    keyl32        reade     label32                                78
640 MC     keyl76        reade     label76                                78
     C                   endif
     C                   if        *in78
     C                   leave
     C                   endif
     *
     *     Skip label if not cross dock.
     *
     C                   if        lbstyp <> 'X'
     C                   iter
     C                   endif
640 A*
640 A*     Skip label if wrong label type.
640 A*
640 AC                   if        lbtype <> kyltyp
640 AC                   iter
640 AC                   endif
     *
     *     Skip label if nothing was picked.
     *
     C                   if        lbqpck = 0
     C                   iter
     C                   endif
     *
     C                   add       1             count
650aA*
650aAC     itkey         chain     piritem
650aAC                   if        not %found(piritem)
650aAC                   eval      itdesc = *blanks
650aAC                   eval      itpdsc = *blanks
650aAC                   eval      itvit# = *blanks
650aAC                   endif
650aA*
SVLa C                   select
SVLa C                   when      client = SAVAL
DRYa C                             or client = Dairyland
GFCa C                             or client = Glazier
JSLaAC                             or client = JSilvert
EOPaAC                             or client = EarlsOrganic
640 AC                   eval      itdesc = *blanks
640 AC                   eval      itpdsc = *blanks
CDIaAC                   eval      itvit# = *blanks
640 AC     itkey         chain     piritem
640 AC                   if        %found(piritem)
GFCaAC                   movel     itdesc        w1desc
GFCaAC                   movel     itpdsc        w1pack
640 AC                   endif
640 A*
SVLa C                   eval      w1brnd = *blanks
JSLaAC                   eval      imbrnd = *blanks
SVLa C     itkey         chain     itemmsc
SVLa C                   if        %found(itemmsc)
SVLa C                   movel     imbrnd        w1brnd
SVLa C                   endif
SVLa C                   endsl
     *
     *   Print warning "Cross dock labels next".
     *
     C                   if        count = 1
     C                   write     xdck
     C                   endif
     *
     *     See if we should print the "before" um warning.
     *
     C                   if        lbutyp <> 'N'  and
     C                             opuwrb = 'Y'
     C                   endif
     *
     *     Initialize label fields.
     *
     C                   eval      w1qty2 = lbqpck
     *
     *        Print one label.
     *
     C                   eval      w1pick = lbqpck
     C                   movel     lbitem        w1item
     C                   if        lbasl2 = 'OUT'
     C                   eval      w1out = 'OUT'
     C                   else
     C                   move      '   '         w1out
     C                   endif
     C                   exsr      zzoflo
640bA*
640bAC                   eval      $scmd = '*ORDSTP '
640bAC                   z-add     lbord         $sOrd
640bAC                   eval      $sDstp = 0
640bAC                   if        client = SAVAL
640bAC                   eval      wostop = lbstop
640bAC                   else
640bAC                   exsr      zzfgts
640bAC                   if         $sstp > 0
640bAC                   eval      wostop = $sstp
740aAC                   eval      hostStop = $sstp
640bAC                   else
640bAC                   eval      wostop = lbstop
740aAC                   eval      hostStop = lbstop
640bAC                   endif
640bAC                   endif
IFDaA*
SVLaAC                   select
SVLaAC                   when      client = IFD
IFDaAC*                  if        client = IFD
IFDaAC                   write     pickifd
SVLaAC                   when      client = SAVAL
DRYaAC                             or client = Dairyland
GFCaAC                             or client = Glazier
IFDaAC                   write     picksvl
JSLaAC                   when      client = JSilvert
JSLaAC                   write     pickjsl
EOPaAC                   when      client = EarlsOrganic
EOPaAC                   write     pickeop
IFDaAC*                  else
SVLaAC                   other
     C                   write     pick
IFDaAC*                  endif
SVLaAC                   endsl
IFDaA*
CDIaAC                   select
CDIaAC                   when      client = CDI
HMW AC                             or client = HMWagner
CDIaAC                   write     pickcdi
CDIaAC                   add       1             lincnt
ICBaAC                   when      client = icb
ICBaAC                   write     pickcdi
SOF A*
SOF AC                   when      client = SofoFoods
SOF AC                   write     picksof
SOF AC                   add       1             lincnt
SOF A*
CDIaAC                   other
CDIaAC                   endsl

     C                   add       1             lincnt
     C                   if        *in90
     C                   eval      lincnt = 0
CDIaAC                   select
CDIaAC                   when      client = CDI
CDIaAC                   eval      rtepag = rtepag + 1
CDIaAC                   write     sethdcdi
EFCaAC                   when      client = Eastland
EFCaAC                   write     sethd80
CDIaAC                   other
     C                   write     sethd
CDIaAC                   endsl
EFCaAC                   select
EFCaAC                   when      client = Eastland
EFCaAC                   write     sethed280
EFCaAC                   other
     C                   write     sethed2
EFCaAC                   endsl
     C                   add       3             lincnt
     C                   eval      *in90 = *off
     C                   endif
     *
SVL A*   If Saval, print catchweight entry line/s.
     *
SVL AC                   if        client = saval
DRY AC                             or client = Dairyland
GFCaAC                             or client = Glazier
CLD AC                             or client = Cityline
JSLaAC                             or client = JSilvert
ADF AC                             or client = AandDFoods
SVL AC                   exsr      zrcwgt
SVL AC                   endif
     *
     C                   enddo
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SETBEG  Start new set of labels.
     *
     C     setbeg        begsr
     *
     *   Print set header label.
     *
     C                   eval      lincnt = 0
     C                   eval      lbtrn# = lsttrn
     C                   eval      w1trn# = lbtrn#
     C                   eval      *in81 = *on
CDIaAC                   select
CDIaAC                   when      client = CDI
CDIaAC                   eval      rtepag = rtepag + 1
CDIaAC                   write     sethdcdi
EFCaAC                   when      client = Eastland
EFCaAC                   write     sethd80
CDIaAC                   other
     C                   write     sethd
CDIaAC                   endsl
     C                   add       2             lincnt
     C                   eval      *in81 = *off
     *
     *   Print pallet summary.
     *
EFCaAC                   select
EFCaAC                   when      client = Eastland
EFCaAC                   write     pltsumh80
EFCaAC                   other
     C                   write     pltsumh
EFCaAC                   endsl
     C                   add       1             lincnt
     C     1             do        palcnt        curpal
     C     curpal        occur     palsum
     C                   eval      w1pal# = dsppal
     C                   eval      w1pstp = dspstp
     C                   eval      w1pcub = dspcub
     C                   eval      w1pwgt = dspwgt
     C                   eval      w1ppcs = dsppcs
     C                   write     pltsumd
     C                   add       1             lincnt
     C                   enddo
     *
SVLaAC                   select
SVLaAC                   when      client = IFD
IFDaAC*                  if        client = IFD
IFDaAC                   write     sethifd
IFDaAC*                  else
SVLaAC                   when      client = SAVAL
GFCaAC                             or client = Glazier
SVLaAC                   write     sethsvl
JSLaAC                   when      client = JSilvert
JSLaAC                   write     sethjsl
EOPaAC                   when      client = EarlsOrganic
EOPaAC                   write     setheop
EFCaAC                   when      client = Eastland
EFCaAC                   write     sethed280
DRYbAC                   when      client = Dairyland
DRYbAC                   write     sethdry
SVLaAC                   other
     C                   write     sethed2
IFDaAC*                  endif
SVLaAC                   endsl
     C                   add       1             lincnt
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SETEND  End set of labels.
     *
     C     setend        begsr
     *
     *   Print cross dock labels.
     *
     C                   exsr      prtxdk
     *
     *   Print discrepancy labels.
     *
     C                   if        operr <> 0
     C     count         div       operr         lbls
     C                   mvr                     remain
     C                   if        remain <> 0
     C                   add       1             lbls
     C                   endif
     C     1             do        lbls
     C                   enddo
     C                   endif
     *
     *   Print merge summary(s) for transaction.
     *
     *     Loop through selection labels for transaction.
     *
     C                   eval      first2 = *on
     C                   eval      kyltyp = 'M'
     C                   eval      s = 0
     *
     C                   if        $pgen = 1
640 DC*    keyl32        setll     label32
640 MC     keyl76        setll     label76
     C                   else
640 DC*    keyl32        setll     label32
640 MC     keyl76        setll     label76
     C                   endif
     *
     C                   dou       forevr <> forevr
     C                   if        $pgen = 1
640 DC*    keyl32        reade     label32                                78
640 MC     keyl76        reade     label76                                78
     C                   else
640 DC*    keyl32        reade     label32                                78
640 MC     keyl76        reade     label76                                78
     C                   endif
     C                   if        *in78
     C                   leave
     C                   endif
640 A*
640 A*     Skip label if wrong label type.
640 A*
640 AC                   if        lbtype <> kyltyp
640 AC                   iter
640 AC                   endif
     *
     *       Put together zone from label fields.
     *
     C                   movel     lbwhdp        tmpzon
     C                   move      lbstyp        tmpzon
     *
     C                   movel     lbitem        w1item
     *
     *       First time through initialization.
     *
     C                   if        first2 = *on
     C                   eval      lstzon = tmpzon
     C                   eval      w1rstp = lbstop
     C                   exsr      getpal
     C                   eval      w1pal# = pal#
     C                   write     zonsumh
     C                   eval      ttlcub = 0
     C                   eval      ttlwgt = 0
     C                   eval      ttlpcs = 0
     C                   eval      w1rcub = 0
     C                   eval      w1rwgt = 0
     C                   eval      w1rpcs = 0
     C                   eval      s = 0
     C                   eval      first2 = *off
     C                   endif
     *
     *       When zone or stop changes, print detail line.
     *
     C                   exsr      getpal
     C                   eval      w1pal# = pal#
     *
     *       When zone changes, print summary totals.
     *
     C                   if        tmpzon <> lstzon
     C                   eval      ttlcub = 0
     C                   eval      ttlwgt = 0
     C                   eval      ttlpcs = 0
     C                   eval      s = 0
     C                   eval      lstzon = tmpzon
     C                   write     zonsumh
     C                   endif
     *
     *       Update summary amounts for stop.
     *
     C                   eval      w1rcub = lbcube
     C                   z-add     lbswgt        w1rwgt
     C                   eval      w1rpcs = lbqpck
     C                   movel     ohcnam        w1rcnm
     *
     *       Print detail line.
     *
     C                   exsr      getpal
     C                   eval      w1pal# = pal#
     C                   eval      w1rstp = lbstop
     C                   add       1             s
     C                   if        s > 9
     C                   eval      s = 1
     C                   endif
     C                   eval      ix = %trimr(lbitem) + ' ' + '-'
     C                   eval      ix = %trimr(ix) + ' ' + itdesc
     C                   if        *in90
     C                   eval      lincnt = 0
CDIaAC                   select
CDIaAC                   when      client = CDI
CDIaAC                   eval      rtepag = rtepag + 1
CDIaAC                   write     sethdcdi
EFCaAC                   when      client = Eastland
EFCaAC                   write     sethd80
CDIaAC                   other
     C                   write     sethd
CDIaAC                   endsl
     C                   write     zonsumh
     C                   eval      *in90 = *off
     C                   endif
520 A*
520 AC                   eval      $scmd = '*PLTSTP '
520 MC                   z-add     w1rstp        $sDstp
520 AC                   eval      $sord = 0
SVLbAC                   if        client = SAVAL
SVLbAC                   eval      w1rstp = $sstp
SVLbAC                   else
520 AC                   exsr      zzfgts
520 AC                   if        $sstp > 0
520 AC                   eval      w1rstp = $sstp
520 AC                   endif
SVLbAC                   endif
520 A*
     C                   write     zonsumd
     C                   add       w1rcub        ttlcub
     C                   add       w1rwgt        ttlwgt
     C                   add       w1rpcs        ttlpcs
     *
     C                   enddo
     *
     *     Force printing of label.
     *
     C                   if        s > 0  and
     C                             s < 9
     C                   endif
     *
     *     Print header label.
     *
     C                   write     setsumh
     *
     *     Loop through all labels for transaction.
     *
     C                   eval      first2 = *on
FSHbAC                   select
FSHbAC                   when      client = Fischr
FSHbAC     keyl33        setll     label33t
FSHbAC                   other
     C     keyl33        setll     label33
FSHbAC                   endsl
     *
     C                   dou       forevr <> forevr
FSHbAC                   select
FSHbAC                   when      client = Fischr
FSHbAC     keyl33        reade     label33t                               78
FSHbAC                   other
     C     keyl33        reade     label33                                78
FSHbAC                   endsl
     C                   if        *in78
     C                   leave
     C                   endif
     *
     *       First time through initialization.
     *
     C                   if        first2 = *on
     C                   eval      w1sstp = lbstop
     C                   eval      w1scub = 0
     C                   eval      w1swgt = 0
     C                   eval      w1spcs = 0
     C                   eval      w1scnm = *blanks
CDIbAC                   eval      w1scpo = *blanks
     C                   eval      ttlcub = 0
     C                   eval      ttlwgt = 0
     C                   eval      ttlpcs = 0
     C                   eval      s = 0
     C                   eval      first2 = *off
     C                   endif
     *
     *       When stop changes, print detail line.
     *
     C                   if        lbstop <> w1sstp
     C                   add       1             s
     C                   if        s > 9
     C                   eval      s = 1
     C                   endif
     C                   if        *in90
     C                   eval      lincnt = 0
CDIaAC                   select
CDIaAC                   when      client = CDI
CDIaAC                   eval      rtepag = rtepag + 1
CDIaAC                   write     sethdcdi
EFCaAC                   when      client = Eastland
EFCaAC                   write     sethd80
CDIaAC                   other
     C                   write     sethd
CDIaAC                   endsl
     C                   write     setsumh
     C                   eval      *in90 = *off
     C                   endif
520 A*
520 AC                   eval      $scmd = '*PLTSTP '
520 MC                   z-add     w1sstp        $sDstp
520 AC                   eval      $sord = 0
SVLbAC                   if        client = SAVAL
SVLbAC                   eval      w1sstp = $sstp
SVLbAC                   else
520 AC                   exsr      zzfgts
520 AC                   if        $sstp > 0
520 AC                   eval      w1sstp = $sstp
520 AC                   endif
SVLbAC                   endif
520 A*
     C                   write     setsumd
     C                   add       w1scub        ttlcub
     C                   add       w1swgt        ttlwgt
     C                   add       w1spcs        ttlpcs
     C                   eval      w1scub = 0
     C                   eval      w1swgt = 0
     C                   eval      w1spcs = 0
     C                   eval      w1sstp = lbstop
     C                   endif
     *
     *       Update summary amounts for stop.
     *
     C                   add       lbcube        w1scub
     C                   add       lbswgt        w1swgt
     C                   add       lbqpck        w1spcs
     C                   movel     ohcnam        w1scnm
CDIbAC                   movel     ohcpo         w1scpo
     *
     C                   enddo
     *
     *     Print last stop and totals.
     *
     C                   if        first2 = *off
     *
     *       Detail line.
     *
     C                   add       1             s
     C                   if        s > 9
     C                   eval      s = 1
     C                   endif
     C                   if        *in90
     C                   eval      lincnt = 0
CDIaAC                   select
CDIaAC                   when      client = CDI
CDIaAC                   eval      rtepag = rtepag + 1
CDIaAC                   write     sethdcdi
EFCaAC                   when      client = Eastland
EFCaAC                   write     sethd80
CDIaAC                   other
     C                   write     sethd
CDIaAC                   endsl
     C                   write     setsumh
     C                   eval      *in90 = *off
     C                   endif
530 A*
530 AC                   eval      $scmd = '*PLTSTP '
530 AC                   z-add     w1sstp        $sDstp
530 AC                   eval      $sord = 0
SVLbAC                   if        client = SAVAL
SVLbAC                   eval      w1sstp = $sstp
SVLbAC                   else
530 AC                   exsr      zzfgts
530 AC                   if        $sstp > 0
530 AC                   eval      w1sstp = $sstp
530 AC                   endif
SVLbAC                   endif
530 A*
     C                   write     setsumd
     C                   add       w1scub        ttlcub
     C                   add       w1swgt        ttlwgt
     C                   add       w1spcs        ttlpcs
     *
     *       Summary totals.
     *
     C                   if        s = 9
     C                   eval      s = 1
     C                   else
     C                   add       1             s
     C                   endif
     C                   eval      l = s
     C                   write     setsuml
     *
     C                   if        s = 9
     C                   eval      s = 1
     C                   else
     C                   add       1             s
     C                   endif
     C                   eval      l = s
     C                   write     setsumt
     C                   endif
     *
     *
     *  End of transaction, force print.
     *
     C                   eval      lcount = lmax
     C                   write     setfoot
CDIbAC                   if        client = cdi
     C                   write     cdifoot
CDIbAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  TEST1   Test 1 - Print label definitions
     *
     C     test1         begsr
     *
     C                   eval      oppdev = *blanks
     C                   movel     'LABELS'      oppdev
     C                   eval      oppfrm = *blanks
     C                   movel     '*STD'        oppfrm
520eDC*                  exsr      opnprt
     *
     C                   endsr
     *----------------------------------------------------------------
     *
SVL A*  zrcwgt - Print catchweight entry line/s based on qty picked.
     *
SVL AC     zrcwgt        begsr
 |   *
     *  Get Item Master record.
     *
     C     itkey         chain     piritem
     C                   if        not %found(piritem)
     C                             or itcwgt <> 'Y'
     C                   goto      endzrcw
     C                   endif
     *
     C                   eval      cwgts = lbqpck
     C                   eval      wgtln = ' '
     C                   eval      wgts  = 0
     *
     C                   dou       cwgts = 0
     C                   eval      wgts = wgts + 1
     C                   eval      wgtln(wgts) = wgtblank
     *
     *   Catchweight line has been filled. Print line.
     C                   if        wgts = 7
     C**                 if        wgts = 12
     *
     *   Page overflow. Print headings.
     C                   add       1             lincnt
     C                   if        *in90
     C                   eval      lincnt = 0
CDIaAC                   select
CDIaAC                   when      client = CDI
CDIaAC                   eval      rtepag = rtepag + 1
CDIaAC                   write     sethdcdi
EFCaAC                   when      client = Eastland
EFCaAC                   write     sethd80
EFCaAC                   write     sethed280
CDIaAC                   other
     C                   write     sethd
     C                   write     sethed2
CDIaAC                   endsl
     C                   add       3             lincnt
     C                   eval      *in90 = *off
     C                   endif
     *
     C                   write     catwgt1                              90
     *
     *   Clear array pointer.
     C                   eval      wgts = 0
     *   Clear weight line array.
     C                   eval      wgtln    = ' '
     C                   endif
     *
     C                   eval      cwgts = cwgts - 1
     C                   enddo
     *
     *   Partial line left to print.
     C                   if        wgts > 0
     *
     *   Page overflow on.
     C                   add       1             lincnt
     C                   if        *in90
     C                   eval      lincnt = 0
CDIaAC                   select
CDIaAC                   when      client = CDI
CDIaAC                   eval      rtepag = rtepag + 1
CDIaAC                   write     sethdcdi
     C                   write     sethed2
EFCaAC                   when      client = Eastland
EFCaAC                   write     sethd80
EFCaAC                   write     sethed280
CDIaAC                   other
     C                   write     sethd
     C                   write     sethed2
CDIaAC                   endsl
     C                   add       3             lincnt
     C                   eval      *in90 = *off
     C                   endif
     *
     C                   write     catwgt1                              90
     C                   endif
     *
     *   Add blank line after catchwgt line.
     C                   write     skip1                                90
     *
     C     endzrcw       endsr
     *
     *----------------------------------------------------------------
     C*
520 AC*  ZZFGTS   Get Host Stop Number
520 AC*
520 AC     ZZFGTS        BEGSR
520 AC*
520 AC*    Get Stop From RTESTP
520 AC*
520 AC                   CALL      'GETSTOP'
520 MC                   PARM                    $SCMD             8
740aDC**                 PARM      PSWHSE        $SWHSE            3 0
740aDC**                 PARM      PSRTID        $SRTID            5
740aMC                   PARM      $pwhse        $SWHSE            3 0
740aMC                   PARM      $prtid        $SRTID            5
520 MC                   PARM                    $SORD             7 0
520 MC                   PARM                    $SDSTP            2 0
520 MC                   PARM                    $SSTP             5 0
710aAc                   parm                    $pDdrop           3
710aAc                   parm                    $pDextd          30
710aAc                   parm                    $pDsd             9
520 AC*
520 AC                   ENDSR
     *----------------------------------------------------------------
     *
     *  ZZGTPT  Get transaction number
     *
     C     zzgtpt        begsr
     *
     C     pstrn#        chain     pirtran                            77
     C                   if        *in77
     C                   eval      ptemp# = *zeros
     C                   endif
     *
     *    Transaction checked out to someone.
     *    - Get user name for employee number.
     *
     C                   if        ptemp# > 0
     C                   eval      *in70  = *off
     *
     C     ptemp#        chain     piruser1                           76
     C                   if        *in76
     C                   eval      usfnam = *blanks
     C                   eval      usinit = *blanks
     C                   eval      uslnam = *blanks
     C                   endif
     *
     *    - Format user name into proper format.
     C                   eval      $cmd = '*FML    '
     C                   eval      $name = *blanks
     C                   call      'FRMTNM'
     C                   parm                    $cmd
     C                   parm                    usfnam
     C                   parm                    usinit            1
     C                   parm                    uslnam
     C                   parm                    $name
     *
     C                   eval      w1user = %editc(ptemp#:'X') + ' ' +$name
     *
     *    Transaction not checked out to anyone. Clear name field.
     *    Ind 70=Underline on report.
     C                   else
     C                   eval      *in70  = *on
     C                   eval      w1user = *blanks
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZOFLO  Page Overflow
     *
     C     zzoflo        begsr
     C                   eval      wrkcnt = 0
     C                   eval      lins = 0
     *  Add CW lines to be printed to line count.
     C                   eval      wrkcnt = lincnt + lins
     *  Go to next page, if total count >= 27.
     C                   if        wrkcnt >= 27
     C                   eval      *in90 = *on
     C                   eval      lincnt = 0
CDIaAC                   select
CDIaAC                   when      client = CDI
CDIaAC                   eval      rtepag = rtepag + 1
CDIaAC                   write     sethdcdi
EFCaAC                   when      client = Eastland
EFCaAC                   write     sethd80
CDIaAC                   other
     C                   write     sethd
CDIaAC                   endsl
SVLa C                   select
IFDaA*
IFDaAC                   when      client = IFD
IFDaAC                   write     sethifd
SVLaAC                   when      client = SAVAL
DRYaAC                             or client = Dairyland
GFCaAC                             or client = Glazier
SVLaAC                   write     sethsvl
JSLaAC                   when      client = JSilvert
JSLaAC                   write     sethjsl
EOPaAC                   when      client = EarlsOrganic
EOPaAC                   write     setheop
IFDaAC                   other
     C                   write     sethed2
IFDaAC                   endsl
IFDaA*
     C                   eval      *in90 = *off
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**   OVRPRTF statment
OVRPRTF FILE(OR695PR) OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
