     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR630P     Truck build - Pick items Using Customer Pick Slot
     *  11 September 2005
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*    09/11/05  MLB  5.00
     *      -  Created.
500aA*    09/11/05  MLB  5.00a
     *      - Enh: Added client custom code support to program.
     *
600aA*    09/16/05  RLP  6.00a
     *      - Replace /COPY statements for Websmart project.
     *
510bA*    10/16/06  RAH  5.10b
     *      - Enh: Added call to program RU385 to write records into
     *             the RUNNER file.
510cA*    06/26/07  MLB  5.10c
     *      - Fix: Revised program to pass label type to RU385.
510dA*    08/30/07  MLB  5.10d
     *      - Fix: Revised program to retrieve *RUNNER options
     *        to determine whether a OUT label should be flagged.
     *
520 A*    12/06/08  MLB  5.20
     *      - Enh: Added client location support to GETCLIENT pgm
     *        call.
     *
530 A*    11/17/09  JCJ  5.30
     *      - Revised to use TRUCKH to lookup Template code for
     *        Zone references.
     *
650aA*    10/31/13  RBD  6.50a
     *      - Enh: Added Loader Module logic, taken from OR630 revs.
     *        OR630 is for full system clients and OR630P is for outbound
     *        only ... until now we didn't have an outbound only
     *        client who wanted to use the Loader Module.
     *
650bA*    01/20/15  RBD  6.50b
     *      - Recompiled, LDRDETL file changed.
     *
CWD A*    04/26/16  MLB  CWD  P#01349
     *      - Enh: Re-compiled pgm. WORKLBL5 had order id, descending
     *        added to key for tote processing.
     *
720aA*    03/29/18  DAS  7.20a
     *      - Revised *INZSR to get dataarea DragDrop2.
     *      - When using DD2, normal pallets are PLTSUM PSTYPE='P'.
     *        PSTYPE='O' are Location summaries.
     *      - Added file PLTSUM8.
     *      - Revised UPDDIF to update corresponding location records.
     *
720bA*    01/08/19  DAS  7.20b
     *      - Added file PLTSUM14 for PFG.
     *
730aA*    12/05/19  DAS  7.30a
     *      - Revised to call PIRTRN#W instead of PIRTRN#
     *      - Added file BFCDEBUG to record error getting next tran#.
     *      - Forcing divide by zero to halt program if error.
730bA*    12/06/19  DAS  7.30b
     *      - Revised to call GetTBType instead of reading
     *        data area dragdrop2 directly.
     *      - Replaced dd2 with tbEnhanced.
     *
750 A*    04/09/21  MLB  7.50
     *      - Fix: Revised Loader routine to add logic to test pallet
     *        sequence nbr to be <> 0 when TBEnhanced flag is off. If
     *        pallet sequence number = 0 and TBEnhanced flag is on then
     *        bypass the pallet.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Ellenbee-Leggett
     *
ELL A*    06/06/07  MLB  ELL
     *      - Revised program to write out record to Runner file when
     *        pick slot = LATEPROD.
ELLaA*    06/13/07  MLB  ELLa
     *      - Disabled mod ELL above per Mark Morton.
     *
411 A*----------------------------------------------------------------
     *  Client Custom Revisions: USF-Corp
     *
USF A*    06/14/05  MLB  USF
     *      - Using first ten characters of LBDSP2 to contain a label
     *        sequence number to be used by P-Sys. The number starts at
     *        1 for each transaction.
USFaA*    08/16/05  MLB  USFa
     *      - Revised program to call GETBLDC to retrieve group code
     *        that is stored in item build code.
USFbA*    08/18/05  MLB  USFb
     *      - Revised program to add filler character to Group/Load/
     *        Batch/Batch Seq string stored in LBDSP2.
USFcA*    08/22/05  MLB  USFc
     *      - Revised program to reset Batch counter every time Group
     *        code changes.
     *
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cash WA Distributing
     *
CWD A*    12/06/08  MLB  CWD
     *      - Revised program to write out record to Runner file when
     *        pick slot = KD-101-1, KF-101-1 AND KR-101-1
CWDaA*    11/17/10  MLB  CWDa
     *      - Revised program to not write OUT labels to the Runner
     *        module.  Per email from Eric Gab 11-16-2010.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval Foodservices
     *
SVLaA*    09/02/09  GJA  SVL
     *      - Revised program to not create runner records for will call
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:  Dairyland
     *
DRYa *    06/25/10  GJA  DRYa
     *      - Force OPCRTM to always be 'N', this will make sure that
     *        a label prints for all outs.  OPCRTR should always be
     *        'Y' so that voice will create a runner flag when out.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: I Supply
     *
ISYaA*    11/18/09  GJA  ISYa
     *      -  Force OPCRTM to always be 'N', this will make sure that
     *         a label prints for all outs.  OPCRTR should always be
     *         'Y' so that voice will create a runner flag when out
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: PFG
     *
PFGaA*    01/08/19  DAS  PFGa
     *      -  Revised to use PLTSUM14 instead of PLTSUM3 because PFG
     *         wants transactions to be assigned in reverse Stop order
     *         instead of reverse Unload Seq order.
     *
PFGbA*    01/31/19  DAS  PFGb
     *      -  Revised to set PSSTP2 = PSSTP1 when PSSTP2 is zero.
     *         OR620 sets PSSTP2 to zero for *SP pallets. Of course,
     *         that messes up the PFGa change.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kohl Wholesale
     *
KHLaA*    03/19/19  JCJ  KHLa
     *      -  Revised to use PLTSUM14 instead of PLTSUM3 because SWT
     *         wants transactions to be assigned in reverse Stop order
     *         instead of reverse Unload Seq order.
     *
     *----------------------------------------------------------------
     *  Misc Notes
     *
     *    - Each item defined in the PIRITEM file, no matter the type,
     *      must contain its own detail information (ie. Description,
     *      Dimensions, Weight, Tie/Highs, Etc . . .).  This program
     *      will always deal with the Item information for the item
     *      that was sent into the program (the item being received).
     *      In the case of Alias, Contract and Same Slot Breakdown
     *      items the information should be identical to its
     *      corresponding Base item.
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Chain indicator
     *  90        Overflow indicator for exception report
     *  91        Overflow indicator for catch weight report
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpltsum3   uf   e           k disk
PFGaAFpltsum14  uf   e           k disk
PFGaAF                                     rename(psrec:psrec14)
     Fworklbl5  uf   e           k disk
     Foptionz   if   e           k disk
     Foptions   if   e           k disk
     Fpiritem   if   e           k disk
     Fitemdsc   if   e           k disk
     Fworklbl7  uf   e           k disk
     F                                     rename(lwrec:lwrec7)
     Fpltsum4   uf   e           k disk
     F                                     rename(psrec:psrec4)
720aAFpltsum8   uf   e           k disk    prefix(ps8_)
720aAF                                     rename(psrec:psrec8)
     Fpltstp1   uf   e           k disk
     Fcrossdk1  uf   e           k disk
     Fpirslct1  if   e           k disk
     Fordh      if   e           k disk
     Fslot2     if   e           k disk
     FLabel13   uf a e           k disk
     Fordt      o  a e             disk
     Fpirtrck2  o    e             disk
     Fordslct   uf a e           k disk
650aAFLdrhdr    uf a e           k disk
650aAFLdrdetl   uf a e           k disk
     For630ppr  o    e             printer oflind(*in90)
     F                                     usropn
530 AFtruckh    if   e           k disk
730aAFbfcdebug  o  a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a40             s              1    dim(40)
     D a80             s              1    dim(80)
     D msg             s             40    dim(4) ctdata perrcd(1)
     D ovrprt          s             80    dim(1) ctdata perrcd(1)
500aA*----------------------------------------------------------------
500aA*  Customer id
500aA*
     D @getcl          c                   const('GETCLIENT')
500aA*
USF AD/COPY QCOPYSRC,ID#USFCRP
ELL AD/COPY QCOPYSRC,ID#ELLENBE
CWD AD/COPY QCOPYSRC,ID#CASHWA
SVLaAD/COPY QCOPYSRC,ID#SAVAL
DRYaAD/COPY QCOPYSRC,ID#DAIRYLA
ISYaAD/COPY QCOPYSRC,ID#ISUPPLY
PFGaAD/COPY QCOPYSRC,ID#PFG
KHLaAD/copy qcopysrc,id#khl
USF A*
     *----------------------------------------------------------------
     *  General Data structure.
     *
     D ds0             ds
     D  dsrec                  1     30
     D  dslbl#                 1      7  0
     D  dsfpck                 8     12  0
     D  dsfcub                13     21  3
     D  dsfwgt                22     30  2
     *----------------------------------------------------------------
     *  USF Corp - Batch key ds.
     *
     D usfkey          ds
     D  usfgrp                 1      1
     D  usfrte                 2      4
     D  usffil                 5      5  0
     *                                       5   60USFBAT
     D  usfbat                 6      7  0
     *                                       7  100USFSEQ
     D  usfseq                 8     11  0
     D                 ds
     D  hldgrp                 1      1
     *
     *----------------------------------------------------------------
     *  Data structure.
     *
     D ds1             ds                  occurs(50)
     D  ary                    1   1500
     D                                     DIM(30)
     D  lstary              1501   1502  0
     *----------------------------------------------------------------
     *  *PICK  -  Picking options
     *
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPNXTP  -  Next pallet number.
     *    OPBPCK  -  Bulk pick definition.
     *    OPPCUB  -  Maximum cube for PIR.
     *    OPFPAL  -  Pallets on fixed fork lift.
     *    OPFCUB  -  Maximum cube per fixed pallet.
     *    OPFSTP  -  Maximum stops per fixed pallet.
     *    OPINCL  -  Include PIR in fixed cube.
     *    OPSRCH  -  Number of previous pallets to search for space.
     *    OPFBLD  -  Fixed pallet building method.
     *                1 = By piece without concern for splitting stop.
     *                2 = By stop without splitting stop between plts.
     *    OPPBRK  -  Aisle to start new pallet.
     *    OPPBLD  -  Pallet building method.
     *                1 = By stop then slot location.
     *                2 = By slot location then stop.
     *    OPSELM  -  Selection method.
     *                1 = Single pass (By location).
     *                2 = Multiple pass (By stop).
     *    OPSPLT  -  Allow stop to be split across pallets (Y/N).
     *    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
     *
     * Data structure
     *
     D opzdta          ds
     D  opnxtp                 1      7  0 inz(0)
     D  oppcub                10     14  2 inz(0)
     D  opfpal                15     15  0 inz(0)
     D  opfcub                16     20  2 inz(0)
     D  opincl                22     22
     D  opsrch                23     24  0 inz(0)
     D  opfstp                25     26  0 inz(0)
     D  opfbld                27     27  0 inz(0)
     D  opbpck                28     30  0 inz(0)
     D  oppbrk                31     33
     D  oppbld                34     34
     D  opselm                35     35
     D  opsplt                36     36
     D  opbmrg                37     37
     D  opdend               117    117
     *----------------------------------------------------------------
     *  *GENPICK  -  General Picking options
     *
     * Fields
     *
     *    OPERPT  -  Print exception (short) error report (Y,N).
     *    OPELBL  -  Print exception (short) labels (Y,N)
     *    OPRFWC  -  Using RF will call (Y,N).
     *    OPNRSC  -  Number of pallet sections (1-9).
     *    OPHPWC  -  Host pick Will Call (Y/N).
     *
     * Data structure
     *
     D opdta1          ds
     D  operpt                 1      1
     D  opelbl                 2      2
     D  oprfwc                 3      3
     D  opnrsc                 4      4  0
     D  ophpwc                 5      5
     D  optend               117    117
     D opdta2          ds
     D  opstyp                 1      1
     D  opwhdp                 2      6
     D  opum1                  7      8
     D  opdum                  9     23
     D  opcum                 24     43
     D  opcdiv                44     52  2
     D  opcaut                53     53
     D  opcwrn                54     54
     D  opcrng                55     57  1
     D  opwum                 58     72
     D  opxdsc                73     73
510dA*----------------------------------------------------------------
510dA*  *RUNNER  -  PIR Runner Flag Options
510dA*----------------------------------------------------------------
510dA*
510dA* Fields
510dA*
510dA*    OPCRTM  -  Create Manual Runner entries for shorts/outs (Y/N)
510dA*    OPUPLR  -  Update Label with quantity shorted during manual
510dA*               flag entry (Y/N)
510dA*               NOTE: Any change to this field will cause OPUPLV
510dA*                     in the *VOICE options record to be updated.
510dA*    OPRPLF  -  Replenish flagged items before print report? (Y/N)
510dA*               & create Priority Replenishment if necessary.
510dA*    OPMRGF  -  Create Runner entries for Merge records? (Y/N)
510dA*    OPCLRF  -  Clear Runner flags if qty still short/out? (Y/N)
510dA*    OPRNRM  -  Send break message to user when new Runner
510dA*               task has been assigned. (Y/N)
510dA*    OPCLSF  -  Update Label quantity at flag close (Y/N).
510dA*    OPOUTF  -  Create Runner entry after slot marked out. (Y/N)
510dA*    OPRPCK  -  Print Runner pick list. (Y/N)
510dA*    OPRLBL  -  Print Runner pick labels. 0=No, 1=full size Zebra
510dA*               printer, 2=Belt printer
650aA*    OPRBDU  -  Allow shorts to be filled with breakdown units (Y/N).
650aA*    OPRSCN  -  Scan tran# or label# to start pick.
650aA*                 1=tran#, 2=label#.
650aA*    OPRVFS  -  Verify pick slot, Y/N.
650aA*    OPRVFQ  -  Verify qty found, Y/N.
650aA*    OPRLOA  -  Using loader module, Y/N.
510dA*
510dA* Data structure
510dA*
510dAD opdtar          ds
510dAD  opcrtm                 1      1
510dAD  opuplr                 2      2
510dAD  oprplf                 3      3
510dAD  opmrgf                 4      4
510dAD  opclrf                 5      5
510dAD  oprnrm                 6      6
510dAD  opclsf                 7      7
510dAD  opoutf                 8      8
510dAD  oprpck                 9      9
510dAD  oprlbl                10     10
650aAD  oprbdu                11     11
650aAD  oprscn                12     12
650aAD  oprvfs                13     13
650aAD  oprvfq                14     14
650aAD  oprloa                15     15
510dAD  optenr               117    117
510dA*
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     *----------------------------------------------------------------
     *
     * The following data structures are for capturing picking
     * tracking info.
     *
     *----------------------------------------------------------------
     *  *PCK001   -  Picking Batch detail info
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    TRPCMD  -  Program processing option
     *    TRPPRG  -  Calling program
     *    TROTYP  -  Order type
     *    TRRORD  -  Restart Order number
     *    TRPKST  -  Picking status
     *    TRFLPK  -  Picking options error flag (0=Rcd found, 1=Missing)
     *    TRFLTK  -  Truck options error flag (0=Rcd found, 1=Missing)
     *
     * Data structure
     *
     D tr01ds          ds
     D  trpcmd                 1      8
     D  trprg                  9     18
     D  trotyp                19     19
     D  trrord                20     26  0
     D  trpkst                27     46
     D  trflpk                47     47
     D  trfltk                48     48
     D  trdt01                 1    150
     *----------------------------------------------------------------
     *  *PCK002  -  General Picking options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    Note: See general picking options definition.
     *
     * Data structure
     *
     D tr02ds          ds
     D  trdt02                 1    150
     *----------------------------------------------------------------
     *  *PCK003  -  Truck Header info
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    TRROWS -  Row in trailer
     *    TRCOLS -  Column in trailer
     *    TRBULK -  Allow bulk picks (Y/N)
     *    TRBAT  -  Allow batch picks (Y/N)
     *
     * Data structure
     *
     D tr03ds          ds
     D  trrows                 1      2  0
     D  trcols                 3      3  0
     D  trbulk                 4      4
     D  trbat                  5      5
     D  trdt03                 1    150
     *----------------------------------------------------------------
     *  *PCK010  -  Zone pick options definition.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    TRDT10  -  See defintion for zone pick options.
     *
     * Data structure
     *
     D tr10ds          ds
     D  trdt10                 1    150
     *----------------------------------------------------------------
     *  *PCK040  -  Subroutines entered
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    TRSUBR  -  Subroutines entered.
     *
     * Data structure
     *
     D tr40ds          ds
     D  trr                    1    150
     D                                     DIM(25)
     D  trrfld                 1    150
     *----------------------------------------------------------------
     *  *PCK050  -  Tracking message(s)
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    TRSR50  -  Subroutine sending message
     *    TRDT50  -  Tracking message(s)
     *
     * Data structure
     *
     D tr50ds          ds
     D  trsr50                 1     10
     D  trdt50                11    150
     *----------------------------------------------------------------
     *  Tracking messages
     *----------------------------------------------------------------
     D tr05            c                   const('Item master record n-
     D                                     ot on file.')
     D tr06            c                   const('Picking options not -
     D                                     found for zone.')
     D tr07            c                   const('QtyAlc1:')
     D tr08            c                   const('QtyAlc2:')
     D tr09            c                   const('QtyAlc3:')
     D tr10            c                   const('QtyPck1:')
     D tr11            c                   const('QtyPck2:')
     D tr12            c                   const('QtyPck3:')
     D tr13            c                   const('Dept:')
     D tr14            c                   const('Slot:')
     *  Picking status messages.
     D trerfl          c                   const('*NOTFOUND')
     D tr15            c                   const('Warehouse picking co-
     D                                     mpleted with no erro-
     D                                     rs.')
     D tr16            c                   const('Warehouse picking co-
     D                                     mpleted with at leas-
     D                                     t one picking except-
     D                                     ion.')
     D tr80            c                   const('Picked              ')
     D tr81            c                   const('Picking error       ')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @addtr          c                   const('ADDSTDTRN')
     D @getsi          c                   const('GETSLOTITM')
     D @cvtdt          c                   const('CVTDTE')
     D @usrms          c                   const('USRMSG')
     *----------------------------------------------------------------
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
     *----------------------------------------------------------------
     *  Program info data structure
     *
730aA /copy qcopysrc,c#pgminfds
730aDD*               sds
730aDD* #prog            *proc
730aDD* #job                 244    253
730aDD* #user                254    263
730aDD* #jobn                264    269
730aDD* #jobdt               276    281  0
730aDD* #jobtm               282    287  0
     *----------------------------------------------------------------
     * Work variables
     *----------------------------------------------------------------
530 AD $ptmpl          s             10
650aAD plpos1          s              1  0
720aA*----------------------------------------------------------------
720aA*  Pallet id data structure
720aA*
720aA*    DSPLID  -  Pallet id.
720aA*    DSPLXX  -  Unused.
720aA*    DSPLGN  -  Generation.
720aA*    DSPLRW  -  Pallet row.
720aA*    DSPLCL  -  Pallet column.
720aA*    DSPLSQ  -  Sequence number.
720aA*               Equal to zero     - Only one pallet in this position.
720aA*               Greater than zero - Multiple pallets in this position.
720aA*
720aA*
720aAD pltid           ds
720aAD  dsplid                 1      7  0 inz(0)
720aAD  dsplxx                 1      2  0
720aAD  dsplgn                 3      3  0
720aAD  dsplrw                 4      5  0
720aAD  dsplcl                 6      6  0
720aAD  dsplsq                 7      7  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D $laisl          s                   like(slaisl)
     D $ldisp          s                   like(sldisp)
     D $lhand          s                   like(slhand)
     D $lloc           s                   like(slloc)
     D $lrlvl          s                   like(slrlvl)
     D $mcord          s              7
     D $msgdt          s            128
     D $muser          s             10
     D $pjob           s             10
     D $puser          s             10
     D blkpcs          s              5  0
     D curpal          s                   like(lwpal#)
     D curtrn          s                   like(lwtrn#)
     D curtyp          s              2
     D cvt5a           s              5
     D cvt8a           s              8
     D difcub          s                   like(lwcube)
     D difflg          s              1
     D diff1           s                   like(lwqalc)
     D diff2           s                   like(lwqalc)
     D diff3           s                   like(lwqalc)
     D diflft          s                   like(lwqpck)
     D difpck          s                   like(lwqpck)
     D difwgt          s                   like(lwswgt)
     D dscln           s             80
     D first           s              1
     D flgpck          s              1
     D flgtrk          s              1
     D forevr          s              1
     D kycode          s                   like(opzcod)
     D kydflt          s                   like(stdflt)
     D kylbl#          s                   like(lwlbl#)
     D kyltyp          s                   like(lwtype)
     D kyndte          s                   like(osndte)
     D kyntim          s                   like(osntim)
     D kyord           s                   like(osord)
     D kyplid          s                   like(psplid)
     D kyprty          s                   like(osprty)
     D kystat          s                   like(osstat)
     D kytype          s                   like(pstype)
     D kyuser          s                   like(osuser)
     D kyzone          s                   like(opzzon)
     D lslcto          s                   like(slctor)
     D lsrte           s                   like(lwrte)
     D lstcmp          s                   like(pscomp)
     D lstdev          s                   like($dev)
     D lstfrm          s                   like($form)
     D lstitm          s                   like(lwitem)
     D lstmlt          s              3  0
     D lsttrn          s              7  0
     D lstwdp          s                   like(lwwhdp)
     D lstwhs          s                   like($whse)
     D lstzon          s                   like(psszon)
     D lzone           s                   like(psszon)
     D nwfcub          s                   like(difcub)
     D nwfpck          s                   like(difpck)
     D nwfwgt          s                   like(difwgt)
     D obflag          s              1
     D ocode           s              8
     D opened          s              1
     D pcount          s              3  0
     D picked          s              5  0
     D pltpcs          s              5  0
     D prflag          s              1
     D r               s              3  0
     D rplflg          s              1
     D slctor          s                   like(stuser)
     D svfcub          s                   like(difcub)
     D svfpck          s                   like(difpck)
     D svfwgt          s                   like(difwgt)
     D temp30          s             30
     D today           s              8  0
     D trerr           s              1
     D trkey           s             10
     D trnbr           s              4
     D trnqty          s              7  0
     D trntyp          s              8
     D trsq10          s              5  0
     D trsq40          s              5  0
     D trsq50          s              5  0
     D trsubr          s              6
     D ttlcub          s                   like(@pcube)
     D ttlpcs          s                   like(@ppcs)
     D ttlwgt          s                   like(@pswgt)
     D uxflag          s              1
     D x               s              3  0
     D y               s              3  0
     D z               s              3  0
     D zone            s                   like(psszon)
730aAD pttrn#          s                   like(lwtrn#)
730aAD pNextTrn#       s             11  0
730aAd nextTrn#        s                   like(lwlbl#)
720bAd tbEnhanced      s               n
720bAd tbPalletType    s              1
720bAd tbType          s              1
720bAd tbWhse          s              3  0

730aA*----------------------------------------------------------------
730aA*  Prototypes
730aA*----------------------------------------------------------------
730aA
730aA /copy qcopysrc,p.pirtrn#w
730bAd/copy qcopysrc,p.gettbtyp

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------
     *
     *    Input Parameters
     *      $PBAT   Batch number
     *      $PWHSE  Warehouse
     *      $POTYP  Order type
     *      $PRTID  Route
     *      $PRTID  Route id
     *      $PTRUK  Truck
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pbat             7 0
     C                   parm                    $pwhse            3 0
     C                   parm                    $potyp            1
     C                   parm                    $prte             5
     C                   parm                    $prtid            5
     C                   parm                    $ptruk           10
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      prflag = *off
     *
     * Open printer
     *
     C                   exsr      opnprt
     *
     *  Work with bulk picks first.
     *
     C                   eval      kytype = 'B'
     C     keyps3        setll     pltsum3
     C                   dow       forevr = forevr
     C     keyps3        reade     pltsum3                                79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     C                   eval      kyplid = psplid
     *  Get zone selector for RF will call
     C                   if        $potyp = 'W'  and
     C                             prodt = '*RF     '  and
     C                             oprfwc = 'Y'
     C                   exsr      getsct
     C                   endif
     C                   exsr      pickb
     *
     C                   enddo
     *
     *  Now work with normal picks.
     *
     C                   eval      difflg = *off
730bDC**                 eval      kytype = 'O'
730bMC                   eval      kytype = tbPalletType
     C                   eval      pcount = 0
     C                   eval      curtrn = 0
     C                   eval      curpal = 0
     C                   move      *hival        lstcmp
     C                   move      *hival        lstzon
     C                   if        client = usfcrp
     C                   eval      lsttrn = -(1)
     C                   endif

KHLaAC                   select
PFGaAC                   when      client = pfg
KHLaAC                             or client = kohl
PFGbAC                   exsr      fillstp2
PFGaAC     keyps3        setll     pltsum14
PFGaAC                   other
     C     keyps3        setll     pltsum3
PFGaAC                   endsl

     C                   dow       forevr = forevr

KHLaAC                   select
PFGaAC                   when      client = pfg
KHLaAC                             or client = kohl
PFGaAC     keyps3        reade     pltsum14                               79
PFGaAC                   other
     C     keyps3        reade     pltsum3                                79
PFGaAC                   endsl

     C                   if        *in79
     C                   leave
     C                   endif
     *
     *    Loop if nothing on pallet.
     *
     C                   if        pspcs = 0
     C                   iter
     C                   endif
     *
     *    Loop if pallet only contains bulk picks.
     *
720x *****              EXSR      CHK4OB
     C                   if        obflag = *on
     C                   iter
     C                   endif
     *
     C                   eval      kyplid = psplid
     *
     *    Get picking options for zone.
     *
     C                   if        psszon <> lstzon
     C                   eval      kyzone = psszon
     C                   exsr      getopt
     C                   eval      lstzon = psszon
     C                   eval      pcount = 0
     *  Get zone selector for RF will call
     C                   if        $potyp = 'W'  and
     C                             prodt = '*RF     '  and
     C                             oprfwc = 'Y'
     C                   exsr      getsct
     C                   endif
     C                   endif
     *
     *    Increment pallet count.
     *
     C                   if        pcount >= opfpal
     C                   eval      pcount = 1
     C                   else
     C                   add       1             pcount
     C                   endif
     *
     *    Get transaction number for pallet.
     *
     C                   if        pstrn# <> 0
     C                   eval      trntyp = '*EXIST  '
     C                   eval      curtrn = pstrn#
     C                   else
     C                   if        pcount = 1
     C                   eval      trntyp = '*NEW    '
     C                   exsr      newtrn
     C                   endif
     C                   endif
     *
     *    Start USF Seq# over for each tran.
     *
     C                   if        client = usfcrp
     *
     C                   if        curtrn <> lsttrn
     C                   eval      lsttrn = curtrn
     C                   movel     $prte         usfrte
     C                   eval      usffil = *zeros
     *    Force Group to W when processing Will-Call orders.
     C                   if        $potyp = 'W'
     C                   eval      usfgrp = 'W'
     C                   else
     C                   eval      usfgrp = '@'
     C                   endif
     C                   add       1             usfbat
     C                   eval      usfseq = 0
     C                   endif
     *
     C                   endif
     *
     *    Update pallet with transaction number.
     *
     C                   eval      pstrn# = curtrn
PFGaAC                   if        client = pfg
PFGaAC                   update    psrec14
PFGaAC                   else
     C                   update    psrec
PFGaAC                   endif
     *
     *    Pick items for pallet.
     *
     C                   exsr      pick
     *
     C                   enddo
     *
     *  Write out last transaction.
     *
     C                   if        curtrn <> 0
     C                   exsr      wrttrn
     *  Write selector for RF will call
     C                   if        $potyp = 'W'  and
     C                             prodt = '*RF     '  and
     C                             oprfwc = 'Y'
     C                   eval      lslcto = slctor
     C                   eval      lzone = zone
     C                   exsr      wrtsct
     C                   exsr      sndusr
     C                   endif
     C                   endif
     *
     *    Update files with any allocated vs. picked differences.
     *
     C                   if        difflg = *on
     C                   exsr      upddif
     C                   endif
     *
650aA*    Update loader module files only if client is using loader module.
650aAC                   if        oprloa = 'Y'
650aAC                   exsr      createloader
650aAC                   endif
     *
     *    Copy records from WORKLBL to LABEL file.
     *
     C                   exsr      lw2lb
     *
     * Close up shop and return home.
     *
     C                   if        prflag = *on
     C                   write     foot1
     C                   endif
     *
     *  Write out completion message.
     *
     C                   if        trerr = *on
     C                   eval      trnbr = 'TR16'
     C                   eval      trcode = '*PCK050 '
     C                   movel     'MAINLN  '    trsr50
     C                   exsr      zztrck
     C                   else
     C                   eval      trnbr = 'TR15'
     C                   eval      trcode = '*PCK050 '
     C                   movel     'MAINLN  '    trsr50
     C                   exsr      zztrck
     C                   endif
     *
     *  Write out tracking record, force out contents of array.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'EXIT    '    trsubr
     C                   eval      r = 32
     C                   exsr      zztrck
     *
     *    Write out tracking record *PCK001.
     *
     C                   eval      trcode = '*PCK001 '
     C                   exsr      zztrck
     *
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
500aA*
500aA* Get client id.
500aA*
500aAC                   call      @getcl
500aAC                   parm                    client           10
520 AC                   parm                    cliloc           10
730bAc*
730bAc*   Determine if using TruckBUilder Enhanced
730bAc*
730bA /free
730bA      tbWhse = $pwhse;
730bA      GetTBType(tbWhse: $prtid: tbType);
730bA      if tbType = 'E';
730bA        tbEnhanced = *on;
730bA        tbPalletType = 'P';
730bA      else;
730bA        tbEnhanced = *off;
730bA        tbPalletType = 'O';
730bA      endif;
730bA /end-free
     *
     *  Initialize tracking key.
     *
     C                   eval      trwhse = $pwhse
     C                   movel(p)  #prog         trpgm
     C                   eval      trjbnr = #jobn
     C                   eval      $cvcmd = '*MDYCMD '
730aMC                   move      #jobdate      $cvd6i
     C                   eval      $cvd8o = *zeros
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      trjbdt = $cvd8o
730aMC                   eval      trjbtm = #jobtime
     C                   eval      trdev = #job
     C                   eval      truser = #user
     C                   eval      trtruk = $ptruk
     C                   eval      trrte = $prte
     C                   eval      trrtid = $prtid
     C                   eval      trpbat = $pbat
     C                   eval      r = *zeros
     C                   eval      trsubr = *blanks
     C                   eval      trrfld = *blanks
     C                   eval      trnqty = *zeros
     C                   eval      trsq10 = *zeros
     C                   eval      trsq40 = *zeros
     C                   eval      trsq50 = *zeros
     C                   eval      trnbr = *blanks
     C                   eval      cvt5a = *blanks
     C                   eval      cvt8a = *blanks
     C                   eval      trkey = *blanks
     C                   eval      trerr = *off
     C                   eval      flgpck = *off
     C                   eval      flgtrk = *off
     C                   eval      rplflg = *off
     *
     C                   if        client = usfcrp
     C                   eval      usfbat = *zeros
     C                   eval      usfseq = *zeros
     C                   eval      hldgrp = '@'
     C                   endif
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     '*INZSR  '    trsubr
     C                   exsr      zztrck
     C                   eval      forevr = *off
     *
     *  Define key for CROSSDK1 file.
     *
     C     keycd1        klist
     C                   kfld                    lwwhse
     C                   kfld                    lword
     C                   kfld                    lwseq
     *
     *  Define partial key for WORKLBL5 file.
     *
     C     keylw         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
     *  Define partial key for WORKLBL5 file.
     *
     C     keylw5        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kyplid
     *R                   KFLD           PSPLID
     *
     *  Define partial key for WORKLBL7 file.
     *
     C     keylw7        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kylbl#
     *
     *  Define partial key for PLTSUM3 file.
     *
     C     keyps3        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kytype
     *
     *  Define key for PLTSUM4 file.
     *
     C     keyps4        klist
     C                   kfld                    lwtrn#
     *
     *  Define key for PLTSTP file.
     *
     C     keypss        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    psplid
     C                   kfld                    psrow
     C                   kfld                    pscol
     C                   kfld                    lwstop
     C                   kfld                    psbcnt
     *
     *  Define partial key for PLTSTP1 file.
     *
     C     keyss1        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    psplid
     *
     *  Define partial key for options file.
     *
     C     keyop         klist
     C                   kfld                    $pwhse
     C                   kfld                    opcode
     *
     *  Define partial key for options file.
     *
     C     keyopz        klist
     C                   kfld                    kycode
     C                   kfld                    $pwhse
530 D***                kfld                    $ptruk
530 MC                   kfld                    $ptmpl
     C                   kfld                    kyzone
     *
     *     OPTIONS
     *
     C     opkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    ocode
     *
     *     Extended item description
     *
     C     idkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    ititem
     *
     *  Define key for SLOT2 file.
     *
     C     keysl2        klist
     C                   kfld                    $pwhse
     C                   kfld                    lwwhdp
     C                   kfld                    lwdisp
     *
     *  Define key for PIRITEM file.
     *
     C     keyit         klist
     C                   kfld                    $pwhse
     C                   kfld                    lwitem
     *
     *  Define key for PIRSLCT1 file.
     *
     C     keysct        klist
     C                   kfld                    $pwhse
     C                   kfld                    pstruk
     C                   kfld                    psszon
     *
     *  Define key for ORDH file.
     *
     C     keyodh        klist
     C                   kfld                    $pwhse
     C                   kfld                    lword
     *
     *  Define key for ORDSLCT  file.
     *
     C     kyosct        klist
     C                   kfld                    $pwhse
     C                   kfld                    kyuser
     C                   kfld                    kystat
     C                   kfld                    kyprty
     C                   kfld                    kyndte
     C                   kfld                    kyntim
     C                   kfld                    kyord
530 A*
530 A*  Define key for TRUCKH file.
530 A*
530 AC     keyth         klist
530 AC                   kfld                    $pwhse
530 AC                   kfld                    $ptruk
     *
650aA*  Define LDRHDR file key.
     *
650aAC     lhdrky        klist
650aAC                   kfld                    $pwhse
650aAC                   kfld                    $prte
650aAC                   kfld                    $prtid
     *
650aA*  Define LDRDETL file partial key.
     *
650aAC     ldtlky        klist
650aAC                   kfld                    $pwhse
650aAC                   kfld                    $prte
650aAC                   kfld                    $prtid
650aAC                   kfld                    psplid
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C     *dtaara       define    product       prodt             8
     *
     *  Get product level from data area.
     *
     C                   in        prodt
     *
     *  Create report heading.
     *
     *    Start with batch number ...
     *
     C                   time                    time
     C                   move      $pbat         temp30
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $acmd             8
     C                   parm                    temp30
     C     'BATCH:'      cat       temp30:1      hedln2
     *
     *    Then add warehouse ...
     *
     *R         'WARE'    CAT  'HOUSE:':0HEDLN2    P
     C     hedln2        cat       'WARE':2      hedln2
     C     hedln2        cat       'HOUSE:':0    hedln2
     C                   eval      temp30 = *blanks
     C                   move      $pwhse        temp30
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $acmd
     C                   parm                    temp30
     C     hedln2        cat       temp30:1      hedln2
     *
     *    Finish with route.
     *
     C     hedln2        cat       'ROUTE:':2    hedln2
     C     hedln2        cat       $prte:1       hedln2
     *
     *    Center it so it will look pretty.
     *
     C                   call      'CENTER'
     C                   parm                    hedln2
     C                   parm      60            $clen             3 0
530 A*
530 A* Get Zone Template Code if Template type is T=Truck
530 A*
530 AC     keyth         chain     truckh
530 AC                   if        %found(truckh)
530 AC                             and thtype = 'T'
530 AC                   eval      $ptmpl =  thztmp
530 AC                   else
530 AC                   eval      $ptmpl =  $ptruk
530 AC                   endif
510dA*
510dA*   Get *RUNNER options record.
510dA*
510dAC                   eval      opcode = '*RUNNER '
510dAC     keyop         chain     options                            79
510dAC                   eval      opdtar = opdata
510dAC                   if        *in79
510dAC                   eval      opcrtm = 'N'
510dAC                   eval      opmrgf = 'N'
510dAC                   eval      opuplr = 'N'
510dAC                   endif
     *
ISYa *   Force option "Create manual runner entries shorts/out" to
     *       always be set to "N" so OUT labels will print
ISYaAC                   if        client = isupply  or
DRYaAC                             client = dairyl
ISYaAC                   eval      opcrtm = 'N'
ISYaAC                   endif
     *
     *
     *   Get general picking options from options file.
     *
     C                   eval      opcode = '*GENPICK'
     C     keyop         chain     options                            79
     C                   eval      opdta1 = opdata
     C                   if        *in79
     C                   eval      operpt = 'Y'
     C                   eval      opelbl = 'N'
     C                   move      '1'           opnrsc
     C                   eval      ophpwc = 'N'
     C                   eval      flgpck = *on
     C                   endif
     *
     *   Define variables.
     *
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK002 '
     C                   exsr      zztrck
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CHK4OB  Check for only bulk picks on pallet.
     *
     C     chk4ob        begsr
     C                   eval      obflag = *off
     *
     C                   eval      pltpcs = 0
     C                   eval      blkpcs = 0
     *
     C     keyss1        setll     pltstp1
     C                   dow       forevr = forevr
     *
     C                   read(n)   pltstp1                                79
     C                   if        *in79  or
     C                             psswhs <> pswhse  or
     C                             pssrid <> psrtid  or
     C                             pssrow <> psrow  or
     C                             psscol <> pscol
     C                   leave
     C                   endif
     *
     C                   if        pssbsq = 0
     C                   add       psspcs        pltpcs
     C                   else
     C                   add       psspcs        blkpcs
     C                   endif
     *
     C                   enddo
     *
     C                   if        blkpcs > 0  and
     C                             pltpcs = blkpcs
     C                   eval      obflag = *on
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
650aA*
650aA*  CREATELOADER  Whip through PLTSUM and go create loader recs.
650aA*
650aAC     createloader  begsr
     *
730bDC**                 eval      kytype = 'O'
730bAC                   eval      kytype = tbPalletType
     C     keyps3        setll     pltsum3
     C                   dow       forevr = forevr
     C     keyps3        reade     pltsum3                                79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *    Loop if nothing on pallet.
     *
     C                   if        pspcs = 0
     C                   iter
     C                   endif
     *
     *    Update loader module files.
     *
     C                   exsr      loader
     *
     C                   enddo
     *
     C                   endsr

PFGbA*----------------------------------------------------------------
PFGbA*
PFGbA*  FillSTP2   Set PSSTP2 = PSSTP1 when PSSTP2 = 0 and PSSTP1 > 0
PFGbA*             This is only called when using PLTSUM14, which
PFGbA*             has a key that uses PSSSTP2/PSSTP1/PSUNLD.
PFGbA*
PFGbAC     fillstp2      begsr
      /free

        setll ($pwhse: $prtid: 'O') pltsum14;

        dow forevr = forevr;

          reade ($pwhse: $prtid: 'O') pltsum14;
          if %eof(pltsum14);
            leave;
          endif;

          // only want to work with gen 1 records

          if psgen <> 1;
            iter;
          endif;

          // only work with psstp2 = 0

          if psstp2 > 0;
            iter;
          endif;

          // only need to do update if psstp1 has a value

          if psstp1 = 0;
            iter;
          endif;

          // set psstp2 to psstp1
          // didn't come across any other programs that used
          // psstp2=0 to identify a *sp pallet. so we should be ok.

          psstp2 = psstp1;
          update psrec14;

        enddo;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *
     *  GETITM  Get item record.
     *
     C     getitm        begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'GETITM  '    trsubr
     C                   exsr      zztrck
     *
     C                   if        lwitem <> lstitm
     C     keyit         chain     piritem                            78
     C                   if        *in78
     C                   eval      ittype = *blanks
     C                   eval      itumq2 = 0
     C                   eval      itumq3 = 0
     C                   eval      trnbr = 'TR05'
     C                   eval      trcode = '*PCK050 '
     C                   movel     'GETITM  '    trsr50
     C                   exsr      zztrck
     C                   endif
     C                   exsr      zzxopt
     C                   eval      dscln = *blanks
     C                   if        uxflag = *off
     C                   movel     itdesc        dscln
     C                   else
     C                   movel     ixdsc1        dscln
     C                   move      ixdsc2        dscln
     C                   endif
     C                   eval      #bitem = lwitem
     C                   eval      #bityp = ittype
     C                   eval      #bdesc = itdesc
     C                   eval      #bpdsc = itpdsc
     *
     *     If Contract, Alias or SSB item
     *       Then get Base item.
     *
     C                   if        ittype = 'C'  or
     C                             ittype = 'A'  or
     C                             ittype = 'S'
     C                   call      @getsi
     C                   parm      itwhse        $gwhse            3 0
     C                   parm      ititem        $gitem           15
     C                   parm      ' '           #bitem           15
     C                   parm                    #bityp            1
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     C                   parm                    #srtn            10
     C                   parm                    #smsg            60
     C                   endif
     C                   eval      lstitm = lwitem
     C                   endif
     *
     C                   endsr

730aA*----------------------------------------------------------------
730aA*  GetNextTrn#    Get next label number
730aA*----------------------------------------------------------------
730aA
730aAC     getNextTrn#   begsr
      /free

         // Get next label number

         PirTrn#W($pwhse: pNextTrn#);

         // Make sure it isn't too large

         monitor;
           nextTrn# = pNextTrn#;
         on-error;
           nextTrn# = -9;
         endmon;

         // See if there was an error getting label number

         if nextTrn# <= 0;

           // Write message to BFCDEBUG

           bdvalues = 'Error getting lbl# '
                    + '(p' + %char(pNextTrn#) + '/' + %char(nextTrn#) + ') '
                    + 'for '
                    + 'Whse: ' + %char($pwhse) + ', '
                    + 'Rtid: ' + %trimr($prtid);
           bdtype = '*ERROR';
           exsr wrtDebug;

           // Force divide by zero error to abnormally end program.

           nextTrn# = 0;
           pNextTrn# = pNextTrn# / nextTrn#;

         endif;

      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETOPT  Get picking options for zone.
     *
     C     getopt        begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'GETOPT  '    trsubr
     C                   exsr      zztrck
     *
     C                   eval      kycode = '*PICK   '
     C     keyopz        chain     optionz                            79
     C                   if        *in79
     C                   eval      opfpal = 1
     C                   eval      opfcub = 64
     C                   eval      opfstp = 99
     C                   eval      oppbld = *on
     C                   eval      trnbr = 'TR06'
     C                   eval      trcode = '*PCK050 '
     C                   movel     'GETOPT  '    trsr50
     C                   exsr      zztrck
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETSCT  Get selector for zone.
     *
     C     getsct        begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'GETSCT  '    trsubr
     C                   exsr      zztrck
     *
     C                   eval      kydflt = 'Y'
     C                   eval      lslcto = slctor
     C                   eval      lzone = zone
     C     keysct        setll     pirslct1
     C     nxtsct        tag
     C     keysct        reade     pirslct1                               79
     C                   if        not *in79
     C                   eval      slctor = stuser
     C                   eval      zone = stzone
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
650aA*
650aA*  LOADER  Create truck loader records.
650aA*
650aAC     loader        begsr
650aA*
     *  Only write or update loader header and detail recs for
     *  pallets whose pallet id ends in 0.
     *
     C                   move      psplid        plpos1
750 A*       Bypass Std TB pallet if p1pos1 <> zero.
     C                   if        plpos1 <> 0
750 AC                             and TbEnhanced = '0'
750 A*
750 A*       Bypass TB Prime pallet if p1pos1 is zero.
750 AC                             or plpos1 = 0
750 AC                             and TbEnhanced = '1'
750 A*
     C                   goto      endldr
     C                   endif
     *
     C                   if        $potyp = 'W'
     C                   goto      brkrs
     C                   endif
     *
     *=======------ Truck Builder Pallet Info Starts Here -----=======
     C     lhdrky        chain     ldrhdr                             79
     *
     C                   if        *in79
     C                   clear                   lhrec
     C                   eval      lhwhse = $pwhse
     C                   eval      lhrte = $prte
     C                   eval      lhrtid = $prtid
     C                   eval      lhstat = *on
     *
     C                   write     lhrec
     C                   endif
     *
     *  If parent Zone
     C                   if        pspzon <> *blanks
     C                   goto      endldr
     C                   endif
     *
     C     ldtlky        chain     ldrdetl
     C                   if        %found
     C                   goto      endldr
     C                   endif
     *
     C                   clear                   lddrec
     *
     C                   eval      ldwhse = $pwhse
     C                   eval      ldrte = $prte
     C                   eval      ldplid = psplid
     C                   eval      ldrtid = $prtid
     C                   eval      ldtrkz = pstzon
     C                   eval      ldldsq = psunld
     C                   eval      ldcube = pscube
     C                   eval      ldpcs = pspcs
     C                   eval      ldstp1 = psstp1
     C                   eval      ldstp2 = psstp2
     *
     C                   write     lddrec
     *
     C                   goto      endldr
     *
     *=======---- Breakers Pallet Info Loading Starts Here ----=======
     C     brkrs         tag
     C     lhdrky        chain     ldrhdr                             79
     C                   if        *in79
     *
     C                   eval      lhwhse = $pwhse
     C                   eval      lhrte = $prte
     C                   eval      lhrtid = $prtid
     C                   eval      lhstat = *on
     *
     C                   write     lhrec
     C                   endif
     *
     *  If parent Zone
     C                   if        pspzon <> *blanks
     C                   goto      endldr
     C                   endif
     *
     C                   if        pspcs <> *zeros
     *
     C     ldtlky        chain     ldrdetl
     C                   if        %found
     C                   goto      endldr
     C                   endif
     *
     C                   clear                   lddrec
     *
     C                   eval      ldwhse = $pwhse
     C                   eval      ldrte = $prte
     C                   eval      ldrtid = $prtid
     *
     C                   eval      ldplid = psplid
     C                   eval      ldtrkz = pstzon
     C                   eval      ldldsq = psunld
     C                   eval      ldcube = pscube
     C                   eval      ldpcs = pspcs
     C                   eval      ldstp1 = psstp1
     C                   eval      ldstp2 = psstp2
     *
     C                   write     lddrec
     C                   endif
     *
     C     endldr        endsr
     *----------------------------------------------------------------
     *
     *  LW2LB   Work label record to normal label record.
     *
     C     lw2lb         begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'LW2LB   '    trsubr
     C                   exsr      zztrck
     *
     *  Loop through label records for route.
     *
     C     keylw         setll     worklbl5
     C                   dou       forevr <> forevr
     C     keylw         reade     worklbl5                               78
     C                   if        *in78
     C                   leave
     C                   endif
     *
     *     Copy fields.
     *
     C                   eval      lbwhse = lwwhse
     C                   eval      lbwhdp = lwwhdp
     C                   eval      lbseq = lwseq
     C                   eval      lbitem = lwitem
     C                   eval      lbpbat = lwpbat
     C                   eval      lbaisl = lwaisl
     C                   eval      lbloc = lwloc
     C                   eval      lbrlvl = lwrlvl
     C                   eval      lbhand = lwhand
     C                   eval      lbpseq = lwpseq
     C                   eval      lbstyp = lwstyp
     C                   eval      lbqryf = lwqryf
     C                   eval      lbdisp = lwdisp
     C                   eval      lbqavl = lwqavl
     C                   eval      lbwhs2 = lwwhs2
     C                   eval      lbwhd2 = lwwhd2
     C                   eval      lbasl2 = lwasl2
     C                   eval      lbloc2 = lwloc2
     C                   eval      lblvl2 = lwlvl2
     C                   eval      lbhnd2 = lwhnd2
     C                   eval      lbdsp2 = lwdsp2
     C                   eval      lbrte = lwrte
     C                   eval      lbstop = lwstop
     C                   eval      lbord = lword
     C                   eval      lbspcl = lwspcl
     C                   eval      lbpo = lwpo
     C                   eval      lbutyp = lwutyp
     C                   eval      lbucod = lwucod
     C                   eval      lbucub = lwucub
     C                   eval      lbcube = lwcube
     C                   eval      lbuwgt = lwuwgt
     C                   eval      lbswgt = lwswgt
     C                   eval      lbqalc = lwqalc
     C                   eval      lbqrmn = lwqrmn
     C                   eval      lbqpck = lwqpck
     C                   eval      lbtie = lwtie
     C                   eval      lbhigh = lwhigh
     C                   eval      lbgrp1 = lwgrp1
     C                   eval      lbgrp2 = lwgrp2
     C                   eval      lbtype = lwtype
     C                   eval      lblbl# = lwlbl#
     C                   eval      lbpal# = lwpal#
     C                   eval      lbtrn# = lwtrn#
     C                   eval      lbctr# = lwctr#
     C                   eval      lbstat = lwstat
     C                   eval      lbprty = lwprty
     C                   eval      lbsdte = lwsdte
     C                   eval      lbstim = lwstim
     C                   eval      lbrdte = lwrdte
     C                   eval      lbvrfy = lwvrfy
     *
     *     Set LBVRFY to '0' if nothing was picked.
     *         and LBSTAT to 'C'.
     *
     C                   if        lbqpck = 0  and
     C                             lbasl2 <> '***'  and
     C                             lbasl2 <> 'OUT'
     C                   eval      lbvrfy = *off
     C                   eval      lbstat = 'C'
     C                   endif
510bA*
510bA*     Set LBVRFY to 'F' when processing OUT label.
510bA*
SVLaAC                   if        client = saval  and
SVLaAC                             $potyp <> 'W'  or
SVLaAC                             client <> saval
510dA*     Runner options set to allow OUT's to be flagged.
510dAC                   if        opcrtm = 'Y'
510dA*
510dA*     Flag label records that aren't Merge records.
510dAC                   if        opmrgf = 'N'  and
510dAC                             lbtype <> 'M'  or
510dA*     or Flag all label records.
510dAC                             opmrgf = 'Y'
510dA*
510bAC                   if        lbasl2 = 'OUT'  and
CWDaAC                             client <> cashwa  or
ELL A*
ELL A*     Flag label for Ellenbee's Late Produce.
ELL A**         CLIENT    OREQ ELLENB
ELL A**         LWDISP    ANDEQ'LATEPROD'
ELL A*
CWD A*
CWD A*    Flag cross-dock items coming from different w/h.
CWD AC                             client = cashwa  and
CWD AC                             lwdisp = 'KD-101-1'  and
CWD AC                             lwtype <> 'M'  or
CWD A*
CWD AC                             client = cashwa  and
CWD AC                             lwdisp = 'KF-101-1'  and
CWD AC                             lwtype <> 'M'  or
CWD A*
CWD AC                             client = cashwa  and
CWD AC                             lwdisp = 'KR-101-1'  and
CWD AC                             lwtype <> 'M'
CWD A*
510bAC                   eval      lbvrfy = 'F'
510bAC                   endif
SVLaA*
SVLaAC                   endif
510dA*
510dAC                   endif
510dA*
510dAC                   endif
     *
     *     Create label record.
     *
     C                   write     lbrec
     *
     *     Update status of work record.
     *
     C                   eval      lwstat = 'X'
     C                   eval      lwsdte = today
     C                   time                    lwstim
     C                   update    lwrec
     *
510bA*     Write records to RUNNER file.
     *
510dA*     Runner options set to allow OUT's to be flagged.
510dAC                   if        opcrtm = 'Y'
510dA*
510bA*     Flag label records that aren't Merge records.
510dAC                   if        opmrgf = 'N'  and
510dAC                             lbtype <> 'M'  or
510bA*     or Flag all label records.
510dAC                             opmrgf = 'Y'
510dA*
510bAC                   if        lbasl2 = 'OUT'  and
CWDaAC                             client <> cashwa  or
ELL A*
ELL A*     Flag label for Ellenbee's Late Produce.
ELL A**         CLIENT    OREQ ELLENB
ELL A**         LBDISP    ANDEQ'LATEPROD'
ELL A*
CWD A*
CWD A*    Flag cross-dock items coming from different w/h.
CWD AC                             client = cashwa  and
CWD AC                             lwdisp = 'KD-101-1'  and
CWD AC                             lwtype <> 'M'  or
CWD A*
CWD AC                             client = cashwa  and
CWD AC                             lwdisp = 'KF-101-1'  and
CWD AC                             lwtype <> 'M'  or
CWD A*
CWD AC                             client = cashwa  and
CWD AC                             lwdisp = 'KR-101-1'  and
CWD AC                             lwtype <> 'M'
CWD A*
SVLaAC                   if        client = saval  and
SVLaAC                             $potyp <> 'W'  or
SVLaAC                             client <> saval
510bAC                   call      'RU385'
510bAC                   parm      '*ADD    '    $cmd
510bAC                   parm                    lbwhse
510bAC                   parm                    lbwhdp
510bAC                   parm                    lblbl#
510bAC                   parm                    lbtrn#
510bAC                   parm                    lbdisp
510bAC                   parm                    lbqalc
510cAC                   parm                    lbtype
SVLaAC                   endif
510bAC                   endif
510dA*
510dAC                   endif
510dA*
510dAC                   endif
     *
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  NEWTRN   Get new transaction number.
     *
     C     newtrn        begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'NEWTRN  '    trsubr
     C                   exsr      zztrck
     *
     *  Write out current transaction.
     *
     C                   if        curtrn <> 0
     C                   exsr      wrttrn
     *  Write selector for RF will call
     C                   if        $potyp = 'W'  and
     C                             prodt = '*RF     '  and
     C                             oprfwc = 'Y'
     C                   exsr      wrtsct
     C                   exsr      sndusr
     C                   endif
     C                   endif
     *
     *  Get new transaction number.
     *
730aDC**                 call      'PIRTRN#'
730aDC**                 parm                    curtrn
730aMC                   exsr      GetNextTrn#
730aMC                   eval      curtrn = nextTrn#
     *
     *  Inizialize transaction totals.
     *
     C                   eval      ttlcub = 0
     C                   eval      ttlwgt = 0
     C                   eval      ttlpcs = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPNPRT  Open printer file.
     *
     C     opnprt        begsr
     *
     *   Get device and form type for department.
     *
     C                   if        $pwhse <> lstwhs
     C                   call      'GETRPT'
     C                   parm      '*DEVFORM'    $cmd              8
     C                   parm      'OR630PPR'    $lrpt            10
     C                   parm      $pwhse        $whse             3 0
     C                   parm      ' '           $styp             1
     C                   parm      ' '           $whdp             5
     C                   parm                    $desc            50
     C                   parm                    $dev             10
     C                   parm                    $form            10
     C                   eval      lstwhs = $whse
     C                   endif
     *
     *   Open printer file for department.
     *
     C                   if        opened <> *on  or
     C                             $dev <> lstdev  or
     C                             $form <> lstfrm
     *
     *      If printer already open then close it.
     *
     C                   if        opened = *on
     C                   close     or630ppr
     C                   endif
     *
     *      Override printer file.
     *
     *          OVRPRTF FILE(OR630PPR) OUTQ(*DEV) DEV($dev)
     *                  FORMTYPE($form)
     *          NOTE: Ending array positions for $DEV 39, $FORM 60 are 1
     *                greater than standard code. This is due to the
     *                extra character in the printer file name.
     *
     C                   movea     ovrprt(1)     a80
     C                   movea     $dev          a80(39)
     C                   movea     $form         a80(60)
     C                   movea     a80           qcmd
     *
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
     *
     *      Open printer file.
     *
     C                   open      or630ppr
     C                   eval      opened = *on
     C                   eval      lstdev = $dev
     C                   eval      lstfrm = $form
     *
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PCKFIX   Pick fixed section item.
     *
     *    Note: Since customer sends pick slot for each item, no slot
     *          allocation is performed. Whatever quantity is ordered
     *          by the customer is what is allocated and labels printed.
     *
     C     pckfix        begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'PCKFIX  '    trsubr
     C                   exsr      zztrck
     *
     C                   eval      diff1 = 0
     C                   eval      diff2 = 0
     C                   eval      diff3 = 0
     *
     *   Pick everything.
     *
     C                   eval      lwqpck = lwqalc
     *
     *  Update label record.
     *
     *
     C                   eval      lwtrn# = curtrn
     C                   eval      lwstat = 'P'
     C                   eval      lwsdte = today
     C                   time                    lwstim
     C                   update    lwrec
     *
     *   Add transaction number to order detail transaction file.
     *
     C                   exsr      wrtodt
     *
     *  Update transaction totals.
     *
     C                   add       lwcube        ttlcub
     C                   add       lwswgt        ttlwgt
     C                   add       lwqpck        ttlpcs
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PCKMRG   Pick merge records.
     *
     *     Note: Merge records only get added to the pallet's transaction.
     *           The slot qty's are not adjusted.
     *
     *
     C     pckmrg        begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'PCKMRG  '    trsubr
     C                   exsr      zztrck
     *
     *     Update label record.
     *
     C                   eval      lwqpck = lwqalc
     C                   eval      lwtrn# = curtrn
     C                   eval      lwstat = 'P'
     C                   eval      lwsdte = today
     C                   time                    lwstim
     C                   update    lwrec
     *
     *   Add transaction number to order detail transaction file.
     *
     C                   exsr      wrtodt
     *
     *     Update transaction totals.
     *
     C                   add       lwcube        ttlcub
     C                   add       lwswgt        ttlwgt
     C                   add       lwqpck        ttlpcs
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PCKPIR   Pick PIR section item.
     *
     *     Note: With a PIR section item the allocation and breakdown
     *           checks were done at allocation time.  A special order
     *           item, whether it is a Fixed or PIR item, is always
     *           treated as a PIR item.
     *
     *
     C     pckpir        begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'PCKPIR  '    trsubr
     C                   exsr      zztrck
     *
     *     Update label record.
     *
     C                   eval      lwqpck = lwqalc
     C                   eval      lwtrn# = curtrn
     C                   eval      lwstat = 'P'
     C                   eval      lwsdte = today
     C                   time                    lwstim
     C                   update    lwrec
     *
     *   Add transaction number and label numbers to cross dock file.
     *
     C                   if        lwstyp = 'X'
     C     keycd1        chain     crossdk1                           77
     C                   if        not *in77
     C                   eval      cdort# = lwtrn#
     C                   eval      cdorl# = lwlbl#
     C                   update    cdrec
     C                   endif
     C                   endif
     *
     *   Add transaction number to order detail transaction file.
     *
     C                   exsr      wrtodt
     *
     *     Update transaction totals.
     *
     C                   add       lwcube        ttlcub
     C                   add       lwswgt        ttlwgt
     C                   add       lwqpck        ttlpcs
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PICK     Pick non-bulk pallets.
     *
     C     pick          begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'PICK    '    trsubr
     C                   exsr      zztrck
     *
     C                   eval      first = *on
     C                   eval      lstitm = *blanks
     C                   eval      curtyp = *blanks
     *
     *  Loop through pick labels for pallet.
     *
     C     keylw5        setll     worklbl5
     *
     C                   dou       forevr <> forevr
     *
     C     keylw5        reade     worklbl5                               78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   eval      lstwdp = lwwhdp
     *
     *     Only work with normal and merge records.
     *
     C                   if        lwtype <> 'O'  and
     C                             lwtype <> 'M'
     C                   iter
     C                   endif
     *
     *     Ignore labels that have already been picked.
     *
     C                   if        lwstat = 'P'  or
     C                             lwstat = 'X'
     C                   iter
     C                   endif
     *
     *     Get slot record.
     *
     C                   if        lwtype <> 'M'  and
     C                             lwasl2 <> 'OUT'  and
     C                             lwasl2 <> '***'
     C                   eval      picked = 0
     C     keysl2        chain     slot2                              7778
     C                   if        *in77
     C                   eval      p1msg = msg(1)
     C                   exsr      prterr
     C                   eval      trnbr = 'TR01'
     C                   eval      trcode = '*PCK050 '
     C                   movel     'PICK    '    trsr50
     C                   exsr      zztrck
     C                   iter
     C                   endif
     C                   if        *in78
     C                   eval      p1msg = msg(2)
     C                   exsr      prterr
     C                   eval      trnbr = 'TR02'
     C                   eval      trcode = '*PCK050 '
     C                   movel     'PICK    '    trsr50
     C                   exsr      zztrck
     C                   iter
     C                   endif
     C                   endif
     *
     *     Increment USF batch seq. number and put into LWDSP2
     *
     C                   if        client = usfcrp
     *
     *    Force Group to W when processing Will-Call orders.
     C                   if        $potyp = 'W'
     C                   eval      usfgrp = 'W'
     C                   else
     *    Retrieve group code from item build code.
     C                   call      'GETBLDC'
     C                   parm                    lwwhse
     C                   parm                    lwitem
     C                   parm      '  '          $pbld             2
     C                   parm                    $prtn             8
     *
     C                   movel     $pbld         usfgrp
     *
     *    Start USF Batch Number over each time Group changes.
     C                   if        usfgrp <> hldgrp  and
     C                             lwtype <> 'M'
     C                   eval      usfbat = 1
     C                   eval      hldgrp = usfgrp
     C                   endif
     *
     C                   endif
     *
     C                   add       1             usfseq
     C                   eval      lwdsp2 = usfkey
     *
     C                   endif
     *
     *     Execute routine to pick product.
     *
     C                   select
     *
     *       Merge record.
     *
     C                   when      lwtype = 'M'
     C                   eval      curtyp = 'FP'
     C                   exsr      pckmrg
     *
     *       PIR section pick.
     *
     C                   when      lwstyp = 'P'
     C                   eval      curtyp = 'PP'
     C                   exsr      pckpir
     *
     *       Fixed section pick - Normal.
     *
     C                   when      lwstyp = 'F'  and
     C                             lwspcl = *blanks  and
     C                             lwasl2 <> '***'
     C                   eval      curtyp = 'FP'
     C                   exsr      pckfix
     *
     *       Fixed section pick - Special order.
     *
     C                   when      lwstyp = 'F'  and
     C                             lwspcl <> *blanks
     C                   eval      curtyp = 'FP'
     C                   exsr      pckpir
     *
     *       Cross dock pick -
     *
     C                   when      lwstyp = 'X'  and
     C                             lwspcl <> *blanks
     C                   eval      curtyp = 'FP'
     C                   exsr      pckpir
     *
     *       Missing section
     *
     C                   when      lwstyp = ' '  and
     C                             lwasl2 <> '***'
     C                   eval      curtyp = 'FP'
     C                   exsr      pckfix
     *
     C                   endsl
     *
     C                   enddo
     *
     *       Update replenishment with pallet #.
     *
     C                   eval      kyplid = 0
     C                   exsr      updrpl
     C                   eval      kyplid = psplid
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PICKB   Pick bulk pick item.
     *
     *    Note: It is assumed that bulk picks are "normal" quantities.
     *          Also, each bulk pick gets a unique tran# and pallet #.
     *
     C     pickb         begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'PICKB   '    trsubr
     C                   exsr      zztrck
     *
     *  Loop through bulk labels for pallet.
     *
     C     keylw5        setll     worklbl5
     *
     C                   dou       forevr <> forevr
     *
     C     keylw5        reade     worklbl5                               78
     C                   if        *in78
     C                   leave
     C                   endif
     *
     *     Only work with bulk pick records.
     *
     C                   if        lwtype <> 'B'
     C                   iter
     C                   endif
     *
     *     Ignore labels that have already been picked.
     *
     C                   if        lwstat = 'P'  or
     C                             lwstat = 'X'
     C                   iter
     C                   endif
     *
     *     Increment USF batch seq. number and put into LWDSP2
     *
     C                   if        client = usfcrp
     *
     *    Force Group to W when processing Will-Call orders.
     C                   if        $potyp = 'W'
     C                   eval      usfgrp = 'W'
     C                   else
     *    Retrieve group code from item build code.
     C                   call      'GETBLDC'
     C                   parm                    lwwhse
     C                   parm                    lwitem
     C                   parm      '  '          $pbld
     C                   parm                    $prtn
     *
     C                   movel     $pbld         usfgrp
     *
     *    Start USF Batch Number over each time Group changes.
     C                   if        usfgrp <> hldgrp  and
     C                             lwtype <> 'M'
     C                   eval      usfbat = 1
     C                   eval      hldgrp = usfgrp
     C                   endif
     *
     C                   endif
     *
     C                   add       1             usfseq
     C                   eval      lwdsp2 = usfkey
     *
     C                   endif
     *
     *     Get slot record.
     *
     C     keysl2        chain     slot2                              7778
     C                   if        *in77
     C                   eval      p1msg = msg(1)
     C                   exsr      prterr
     C                   eval      trnbr = 'TR01'
     C                   eval      trcode = '*PCK050 '
     C                   movel     'PICKB   '    trsr50
     C                   exsr      zztrck
     C                   iter
     C                   endif
     C                   if        *in78
     C                   eval      p1msg = msg(2)
     C                   exsr      prterr
     C                   eval      trnbr = 'TR02'
     C                   eval      trcode = '*PCK050 '
     C                   movel     'PICKB   '    trsr50
     C                   exsr      zztrck
     C                   iter
     C                   endif
     *
     *    Get item information.
     *
     C                   exsr      getitm
     *
     *  Create transaction record.
     *
730aDC**                 call      'PIRTRN#'
730aDC**                 parm                    pttrn#            7 0
730aMC                   exsr      GetNextTrn#
730aMC                   eval      pttrn# = nextTrn#
     C                   select
     C                   when      lwqrmn = 0
     C                   eval      @ptask = 'BULKF '
     C                   when      trnqty > 0  and
     C                             rplflg = *on
     C                   eval      @ptask = 'BULKR '
     C                   other
     C                   eval      @ptask = 'BULKP '
     C                   eval      trnqty = 0
     C                   endsl
     *
     C                   call      @addtr
     C                   parm      '*CREATE '    @pcmd             8
     C                   parm                    #job
     C                   parm      pttrn#        @ptrn#            7 0
     C                   parm                    @ptask            6
     C                   parm      lwwhse        @pwhse            3 0
     C                   parm      lwwhdp        @pwhdp            5
     C                   parm      lwstyp        @pstyp            1
     C                   parm      lwcube        @pcube            9 3
     C                   parm      lwswgt        @pswgt            9 2
     C                   parm      lwqalc        @ppcs             5 0
     C                   parm      1             @paisl            5 0
     C                   parm      1             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      $prtid        @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      'S'           @pgrp1            1
     C                   parm      $potyp        @pgrp2            1
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
     *
     *  Write selector for RF will call
     C                   if        $potyp = 'W'  and
     C                             prodt = '*RF     '  and
     C                             oprfwc = 'Y'
     C                   exsr      wrtsct
     C                   exsr      sndusr
     C                   endif
     *
     *  Update label record.
     *
     C                   if        rplflg = *on
     C                   eval      lwwhs2 = lwwhse
     C                   eval      lwwhd2 = lwwhdp
     C                   eval      lwasl2 = $laisl
     C                   eval      lwloc2 = $lloc
     C                   eval      lwlvl2 = $lrlvl
     C                   eval      lwhnd2 = $lhand
     C                   eval      lwdsp2 = $ldisp
     C                   else
     C                   eval      lwwhs2 = 0
     C                   eval      lwwhd2 = *blanks
     C                   eval      lwasl2 = *blanks
     C                   eval      lwloc2 = 0
     C                   eval      lwlvl2 = 0
     C                   eval      lwhnd2 = *blanks
     *
     C                   if        client = usfcrp
     *    Do nothing....
     C                   else
     C                   eval      lwdsp2 = *blanks
     C                   endif
     *
     C                   endif
     C                   eval      lwqpck = lwqalc
     C                   z-add     trnqty        lwqrmn
     C                   eval      lwtrn# = pttrn#
     C                   eval      lwstat = 'P'
     C                   eval      lwsdte = today
     C                   time                    lwstim
     C                   update    lwrec
     *
     *   Add transaction number to order detail transaction file.
     *
     C                   exsr      wrtodt
     *
     C                   enddo
     *
     *       Update replenishment with pallet #.
     *
     C                   eval      kyplid = 0
     C                   exsr      updrpl
     C                   eval      kyplid = psplid
     *
     *   Update pallet with transaction number.
     *
     *   Note: It is assumed that there is only one bulk pick label
     *         record for each bulk pick pallet summary record.
     *
     C                   eval      pstrn# = pttrn#
     C                   update    psrec
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PRTERR  Print error exception.
     *
     C     prterr        begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'PRTERR  '    trsubr
     C                   exsr      zztrck
     C                   if        operpt <> 'N'  and
     C                             ophpwc = 'N'  or
     *
     C                             operpt <> 'N'  and
     C                             ophpwc = 'Y'  and
     C                             $potyp <> 'W'
     *
     *  See if we should printer header.
     *
     C                   if        prflag <> *on  or
     C                             *in90
     C                   write     head1
     C                   if        *in90
     C                   write     head2
     C                   endif
     C                   write     columns
     C                   eval      prflag = *on
     C                   eval      *in90 = *off
     C                   endif
     *
     *   Print detail line.
     *
     C                   write     detail1
     C                   write     detail2
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SNDUSR  Notify user Will Call is ready to pick.
     *
     C     sndusr        begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'SNDUSR  '    trsubr
     C                   exsr      zztrck
     *
     C                   eval      $muser = osuser
     C                   movel     msg(4)        $msgdt
     C                   eval      $puser = #user
     C                   eval      $pjob = #job
     *R                   Z-ADDOSCORD    $MCORD  70
     C                   move      oscord        $mcord
     C                   call      @usrms
     C                   parm                    $muser
     C                   parm                    $msgdt
     C                   parm                    $puser
     C                   parm                    $pjob
     C                   parm                    $mcord
     *
     C     kyosct        chain     ordslct                            77
     C                   if        not *in77
     C                   eval      osstat = '2'
     C                   update    osrec
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  UNALOC  Unallocate quantity from ITEMQTY file.
     *
     *    Revised to unallocate from Base item when item ordered
     *    is an Alias or Same Slot Breakdown item.
     *
     C     unaloc        begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'UNALOC  '    trsubr
     C                   exsr      zztrck
     *
     C                   eval      $acmd = '*UNALLOC'
     C                   eval      $aprg = #prog
     C                   eval      $atype = '*BATCH  '
     C                   eval      $awhse = $pwhse
     C                   if        ittype = 'A'  or
     C                             ittype = 'S'
     C                   eval      $aitem = #bitem
     C                   else
     C                   eval      $aitem = lwitem
     C                   endif
     C                   eval      $aqty1 = diff1
     C                   eval      $aqty2 = diff2
     C                   eval      $aqty3 = diff3
     *
     C                   call      'ADJQTY'
     C                   parm                    $acmd
     C                   parm                    $aprg            10
     C                   parm                    $atype            8
     C                   parm                    $awhse            3 0
     C                   parm                    $aitem           15
     C                   parm                    $aqty1            7 0
     C                   parm                    $aqty2            7 0
     C                   parm                    $aqty3            7 0
     C                   parm                    $artq1            7 0
     C                   parm                    $artq2            7 0
     C                   parm                    $artq3            7 0
     C                   parm                    $artn             8
     C                   parm                    $aerm
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  UPDDIF  Update files with allocated vs. picked differences.
     *
     C     upddif        begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'UPDDIF  '    trsubr
     C                   exsr      zztrck
     *
     *  Loop through label records for route.
     *
     C     keylw         setll     worklbl5
     C                   dou       forevr <> forevr
     C     keylw         reade     worklbl5                               79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *     Ignore record if type is not 'O' or no difference.
     *      or if label is 'OUT' record.
     *
     C                   if        lwtype <> 'O'  and
     C                             lwqalc = lwqpck  or
     C                             lwasl2 = '***'  or
     C                             $potyp = 'W'  and
     C                             ophpwc = 'Y'
     C                   iter
     C                   endif
     *
     *     Calculate differences.
     *
     *
     C                   eval      difpck = lwqalc - lwqpck
     C     difpck        mult      lwucub        difcub
     C     difpck        mult      lwuwgt        difwgt
     *
     *     Update corresponding PLTSUM and PLTSTP records.
     *
     C     keyps4        setll     pltsum4
     C                   dou       forevr <> forevr
     C     keyps4        reade     pltsum4                                78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   if        lwpal# <> psplid
     C                   iter
     C                   endif
     *
     C                   eval      kyplid = psplid
     C                   eval      pspcs = pspcs - difpck
     C                   sub       difcub        pscube
     C                   eval      psswgt = psswgt - difwgt
     C                   update    psrec4
720aA*
720aA*       Update corresponding PLTSUM/PLTSTP DD2 Location records
720aA*
720aA /free
730bA    if tbEnhanced;
720aA      dsplid = psplid;
720aA      if dsplsq > 0;
720aA        dsplsq = 0;
720aA        chain (lwwhse: lwrte: lwszon: dsplid: 'O') pltsum8;
720aA        if %found(pltsum8);
720aa          ps8_pspcs -= difpck;
720aA          ps8_pscube -= difcub;
720aA          ps8_psswgt -= difwgt;
720aA          update psrec8;
720aA        endif;
720aA        chain (lwwhse: lwrte: dsplid: psrow: pscol: lwstop: 0) pltstp1;
720aA        if %found(pltstp1);
720aa          psspcs -= difpck;
720aA          psscub -= difcub;
720aA          pssswt -= difwgt;
720aA          update psrec8;
720aA        endif;
720aA      endif;
720aA    endif;
720aa /end-free
     *
     C     keypss        chain     pltstp1                            77
     C                   if        *in77 <> *on
     C                   eval      psspcs = psspcs - difpck
     C                   sub       difcub        psscub
     C                   eval      pssswt = pssswt - difwgt
     C                   update    pssrec
     C                   endif
     *
     C                   enddo
     *
     *
     C     1             occur     ds1
     C                   eval      dslbl# = lwlbl#
     C                   eval      dsfpck = difpck
     C                   eval      dsfcub = difcub
     C                   eval      dsfwgt = difwgt
     C                   move      dsrec         ary(1)
     C                   eval      lstary = 1
     C                   eval      lstmlt = 1
     *
     C     1             do        lstmlt        x
     C     x             occur     ds1
     *
     C     1             do        lstary        y
     C                   move      ary(y)        dsrec
     C                   eval      kylbl# = dslbl#
     C                   eval      svfpck = dsfpck
     C                   eval      svfcub = dsfcub
     C                   eval      svfwgt = dsfwgt
     *
     C     x             add       1             lstmlt
     C     lstmlt        occur     ds1
     C                   eval      lstary = 0
     C                   eval      ary = *blanks
     *
     *     Update corresponding merge label records.
     *
     C                   eval      diflft = svfpck
     *
     C     keylw7        setll     worklbl7
     C                   dow       forevr = forevr
     C     keylw7        reade     worklbl7                               78
     C                   if        *in78
     C                   leave
     C                   endif
     *
     C                   if        diflft = 0
     C                   leave
     C                   endif
     *
     C                   if        lwqpck >= svfpck
     C                   eval      nwfpck = svfpck
     C                   eval      nwfcub = svfcub
     C                   eval      nwfwgt = svfwgt
     C                   eval      lwqpck = lwqpck - svfpck
     C                   eval      lwcube = lwcube - svfcub
     C                   eval      lwswgt = lwswgt - svfwgt
     C                   eval      diflft = 0
     C                   else
     C                   eval      nwfpck = lwqpck
     C                   eval      nwfcub = lwcube
     C                   eval      nwfwgt = lwswgt
     C                   eval      svfpck = svfpck - lwqpck
     C                   eval      svfcub = svfcub - lwcube
     C                   eval      svfwgt = svfwgt - lwswgt
     C                   eval      lwqpck = 0
     C                   eval      lwcube = 0
     C                   eval      lwswgt = 0
     C                   eval      diflft = diflft - nwfpck
     C                   endif
     *
     C                   update    lwrec7
     *
     *        Update corresponding PLTSUM and PLTSTP records.
     *
     C     keyps4        setll     pltsum4
     C                   dou       forevr <> forevr
     C     keyps4        reade     pltsum4                                78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   if        lwpal# <> psplid
     C                   iter
     C                   endif
     *
     C                   eval      kyplid = psplid
     C                   eval      pspcs = pspcs - nwfpck
     C                   sub       nwfcub        pscube
     C                   eval      psswgt = psswgt - nwfwgt
     C                   update    psrec4
720aA*
720aA*       Update corresponding PLTSUM/PLTSTP DD2 Location records
720aA*
720aA /free
730bA    if tbEnhanced;
720aA      dsplid = psplid;
720aA      if dsplsq > 0;
720aA        dsplsq = 0;
720aA        chain (lwwhse: lwrte: lwszon: dsplid: 'O') pltsum8;
720aA        if %found(pltsum8);
720aa          ps8_pspcs -= nwfpck;
720aA          ps8_pscube -= nwfcub;
720aA          ps8_psswgt -= nwfwgt;
720aA          update psrec8;
720aA        endif;
720aA        chain (lwwhse: lwrte: dsplid: psrow: pscol: lwstop: 0) pltstp1;
720aA        if %found(pltstp1);
720aa          psspcs -= nwfpck;
720aA          psscub -= nwfcub;
720aA          pssswt -= nwfwgt;
720aA          update psrec8;
720aA        endif;
720aA      endif;
720aA    endif;
720aa /end-free
     *
     C     keypss        chain     pltstp1                            77
     C                   if        *in77 <> *on
     C                   eval      psspcs = psspcs - nwfpck
     C                   sub       nwfcub        psscub
     C                   eval      pssswt = pssswt - nwfwgt
     C                   update    pssrec
     C                   endif
     *
     C                   enddo
     *
     C                   eval      dslbl# = lwlbl#
     C                   eval      dsfpck = nwfpck
     C                   eval      dsfcub = nwfcub
     C                   eval      dsfwgt = nwfwgt
     C                   add       1             lstary
     C                   eval      z = lstary
     C                   move      dsrec         ary(z)
     *
     C                   enddo
     *
     C     x             occur     ds1
     *
     C                   enddo
     *
     C                   enddo
     *
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  UPDRPL  Update pallet # in WORKLBL8 replenishments if pallet was 0.
     *
     C     updrpl        begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'UPDRPL  '    trsubr
     C                   exsr      zztrck
     *
     *
     *  Loop through labels for pallet# = 0.
     *
     C     keylw5        setll     label13
     *
     C                   dou       forevr <> forevr
     *
     C     keylw5        reade     label13                                78
     C                   if        *in78
     C                   leave
     C                   endif
     *
     *     Only work with replenishment records.
     *
     C                   if        lbtype <> 'R'
     C                   iter
     C                   endif
     *
     *     Update worklbl record with pallet #
     *
     C                   call      'OR636'
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm                    lbitem
     C                   parm      0             $lpal#            7 0
     C                   parm      ' '           $lrtn             8
     *
     *
     *      Update pallet # and repeat loop.
     *
     C                   eval      lbpal# = $lpal#
     C                   update    lbrec
     *
     C                   enddo
     *
     C                   endsr
730aA*----------------------------------------------------------------
730aA*  wrtDebug    Write out debug record
730aA*----------------------------------------------------------------
730bA
730aA /free
730aA  begsr wrtDebug;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  WRTODT  Write out order detail transaction record.
     *
     C     wrtodt        begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'WRTODT  '    trsubr
     C                   exsr      zztrck
     C                   eval      otwhse = lwwhse
     C                   eval      otord = lword
     C                   eval      otseq = lwseq
     C                   eval      otitem = lwitem
     C                   eval      ottrn# = lwtrn#
     C                   eval      otlbl# = lwlbl#
     C                   eval      otemp# = 0
     C                   eval      otpck1 = 0
     C                   eval      otpck2 = 0
     C                   eval      otpck3 = 0
     C                   write     otrec                                49
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  WRTSCT  Write out order selector record for RF will call.
     *
     C     wrtsct        begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'WRTSCT  '    trsubr
     C                   exsr      zztrck
     C     keyodh        chain     ordh                               76
     C                   if        not *in76
     C                   eval      oscord = ohcord
     C                   else
     C                   eval      oscord = 0
     C                   endif
     *
     C                   eval      oswhse = $pwhse
     C                   eval      osrte = lwrte
     C                   eval      ostruk = $ptruk
     C                   eval      osotyp = $potyp
     C                   eval      osord = lword
     C                   eval      ostran = @ptrn#
     C                   eval      oszone = lzone
     C                   eval      osuser = lslcto
     C                   eval      osstat = *on
     C                   eval      osprty = 0
     C                   eval      osndte = today
     C                   time                    osntim
     C                   write     osrec                                49
     *
     C                   eval      kyuser = osuser
     C                   eval      kystat = osstat
     C                   eval      kyprty = osprty
     C                   eval      kyndte = osndte
     C                   eval      kyntim = osntim
     C                   eval      kyord = osord
     C                   endsr
     *----------------------------------------------------------------
     *
     *  WRTTRN  Write out current transaction.
     *
     C     wrttrn        begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'WRTTRN  '    trsubr
     C                   exsr      zztrck
     *
     C                   select
     C                   when      curtyp = 'PP'
     C                   eval      @ptask = 'PIR   '
     C                   eval      @pstyp = 'P'
     C                   other
     C                   eval      @ptask = 'FIXED '
     C                   eval      @pstyp = 'F'
     C                   endsl
     *
     C                   call      @addtr
     C                   parm      '*CREATE '    @pcmd
     C                   parm                    #job
     C                   parm      curtrn        @ptrn#
     C                   parm                    @ptask
     C                   parm      $pwhse        @pwhse
     C                   parm      lstwdp        @pwhdp
     C                   parm                    @pstyp
     C                   parm      ttlcub        @pcube
     C                   parm      ttlwgt        @pswgt
     C                   parm      ttlpcs        @ppcs
     C                   parm      0             @paisl
     C                   parm      0             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      ' '           @prte
     C                   parm      $prtid        @ppo
     C                   parm      'S'           @pgrp1
     C                   parm      $potyp        @pgrp2
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     C                   endsr
     *----------------------------------------------------------------
     *     ZZTRCK - Write tracking records to tracking file
     *
     C     zztrck        begsr
     C                   select
     C                   when      trcode = '*PCK001 '
     C                   movel     '*PICK'       trpcmd
     C                   eval      trprg = *blanks
     C                   eval      trpbat = $pbat
     C                   eval      trotyp = $potyp
     C                   eval      trrtid = $prtid
     C                   select
     C                   when      trerr = *off
     C                   eval      trpkst = tr80
     C                   when      trerr = *on
     C                   eval      trpkst = tr81
     C                   endsl
     C                   eval      trflpk = flgpck
     C                   eval      trfltk = flgtrk
     C                   eval      trdata = tr01ds
     C                   eval      trsqnr = *zeros
     C                   write     tr01rec
     *
     C                   when      trcode = '*PCK002 '
     C                   eval      trdata = opdata
     C                   eval      trsqnr = *zeros
     C                   write     tr02rec
     *
     C                   when      trcode = '*PCK040 '
     C                   add       1             r
     *    Array is full, add to file and then reset array.
     C                   if        r > 25
     C                   add       1             trsq40
     C                   eval      trsqnr = trsq40
     C                   eval      trdata = tr40ds
     C                   write     tr40rec
     C                   eval      trrfld = *blanks
     C                   eval      r = 1
     C                   endif
     C                   eval      trr(r) = trsubr
     *
     C                   when      trcode = '*PCK050 '
     C                   add       1             trsq50
     *
     C     keyodh        chain     ordh                               76
     C                   if        *in76
     C                   eval      ohord = *zeros
     C                   endif
     *
     C                   eval      trord = ohord
     C                   eval      trstop = ohstop
     C                   eval      tritem = lwitem
     C                   eval      trmsgt = 'S'
     *
     C                   select
     C                   when      trnbr = 'TR01'
     C                   eval      trerr = *on
     C                   eval      trdt50 = msg(1)
     C     trdt50        cat       tr13:2        trdt50
     C     trdt50        cat       lwwhdp:1      trdt50
     C     trdt50        cat       tr14:2        trdt50
     C     trdt50        cat       lwdisp:1      trdt50
     *
     C                   when      trnbr = 'TR02'
     C                   eval      trerr = *on
     C                   eval      trdt50 = msg(2)
     C     trdt50        cat       tr13:2        trdt50
     C     trdt50        cat       lwwhdp:1      trdt50
     C     trdt50        cat       tr14:2        trdt50
     C     trdt50        cat       lwdisp:1      trdt50
     *
     C                   when      trnbr = 'TR31'
     C                   eval      trerr = *on
     C                   eval      trdt50 = msg(3)
     C     trdt50        cat       tr07:2        trdt50
     C                   move      lwqalc        cvt5a
     C     trdt50        cat       cvt5a:1       trdt50
     C     trdt50        cat       tr10:2        trdt50
     C                   move      lwqpck        cvt5a
     C     trdt50        cat       cvt5a:1       trdt50
     *
     C                   when      trnbr = 'TR32'
     C                   eval      trdt50 = msg(3)
     C     trdt50        cat       tr08:2        trdt50
     C                   move      lwqalc        cvt5a
     C     trdt50        cat       cvt5a:1       trdt50
     C     trdt50        cat       tr11:2        trdt50
     C                   move      lwqpck        cvt5a
     C     trdt50        cat       cvt5a:1       trdt50
     *
     C                   when      trnbr = 'TR33'
     C                   eval      trdt50 = msg(3)
     C     trdt50        cat       tr09:2        trdt50
     C                   move      lwqalc        cvt5a
     C     trdt50        cat       cvt5a:1       trdt50
     C     trdt50        cat       tr12:2        trdt50
     C                   move      lwqpck        cvt5a
     C     trdt50        cat       cvt5a:1       trdt50
     *
     C                   when      trnbr = 'TR05'
     C                   eval      trdt50 = tr05
     C                   select
     C                   when      lwutyp = 'N'
     C     trdt50        cat       tr07:2        trdt50
     C                   when      lwutyp = '1'
     C     trdt50        cat       tr08:2        trdt50
     C                   when      lwutyp = '2'
     C     trdt50        cat       tr09:2        trdt50
     C                   endsl
     C                   move      lwqalc        cvt5a
     C     trdt50        cat       cvt5a:1       trdt50
     *
     C                   when      trnbr = 'TR15'
     C                   eval      trord = *zeros
     C                   eval      trstop = *zeros
     C                   eval      tritem = *blanks
     C                   eval      trdt50 = tr15
     *
     C                   when      trnbr = 'TR16'
     C                   eval      trord = *zeros
     C                   eval      trstop = *zeros
     C                   eval      tritem = *blanks
     C                   eval      trdt50 = tr16
     *
     C                   endsl
     *
     C                   eval      trdata = tr50ds
     C                   eval      trmsgn = trnbr
     C                   eval      trsqnr = trsq50
     C                   write     tr50rec
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZXOPT   Get use extended description option
     *
     C     zzxopt        begsr
     *
     *   Get extended description option.
     C                   eval      uxflag = *off
     C                   eval      ocode = '*ITEMMNT'
     *
     C     opkey         chain     options                            79
     C                   if        not *in79
     C                   move      opdata        opdta2
     C                   if        opxdsc = 'Y'
     C                   eval      uxflag = *on
     C                   endif
     C                   endif
     *
     C                   if        uxflag = *on
     C     idkey         chain     itemdsc                            79
     C                   if        *in79
     C                   eval      ixdsc1 = *blanks
     C                   eval      ixdsc2 = *blanks
     C                   endif
     C                   endif
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**   Error messages
Slot does not exist.
Slot record was locked.
Not enough stock available.
Will call ready to pick.
**   OVRPRTF statment
OVRPRTF FILE(OR630PPR) OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
