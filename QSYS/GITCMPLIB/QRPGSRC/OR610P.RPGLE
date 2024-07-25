      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR610P     Truck build - Select orders using customer pick slot
     *  11 September 2005
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*    09/11/05  MLB  5.00
     *      -  Created.
500aA*    09/11/05  MLB  5.00a
     *      - Enh: Added support for custom client revisions.
     *
520bA*    02/28/09  DAD  5.20b  P#00150
     *      - Converted to ILE
     *      - Revised to call GETZONE
     *
520cA*    10/05/09  JCJ  5.20c
     *      - Enh: changed to not allow PIR items to be picked as bulk
     *
520dA*    08/18/09  JCJ  5.20d
     *      - Updated *PICK Data Structure
     *
530 A*    11/16/09  JCJ  5.30
     *      - Enh: Recomplied for database change to TRUCKH
     *      - Enh: Add Truck Template logic
     *
530bA*    03/07/10  MLB  5.30b
     *      - Fix: Revised #dbpck to be 3,0 instead of 2,0.
530aA*    04/15/10  MLB  5.30a
     *      - Fix: Revised field used on partial key list, KEYOS1
     *        to use OHORD instead of ODORD.  Was not settting file
     *        pointer correctly on first read.
     *
640 A*    12/20/11  MLB  6.40
     *      - Enh: Added variable, CLIENTLOC on call to GETCLIENT.
     *
720aA*    10/25/18  DAS  7.20a
     *      - Enh: Add fields to GETZONE call.
730aA*    05/31/19  KDE  7.30a
     *      - Enh: Enhance to use DFPICKPSQ to assign PSEQ in WORKLBL
730bA*    12/05/19  DAS  7.30b
     *      - Revised to call PIRLBL#W instead of PIRLBL#
     *      - Added file BFCDEBUG to record error getting next label#.
     *      - Forcing divide by zero to halt program if error.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fischer
     *
FSHa *    03/02/12  GJA  FSHa
     *      -  Fix: Revised program to load SLDISP with value from
     *         OSDISP when no slot found when creating OUT label.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cash Wa
     *
CWD A*    10/28/09  MLB  CWD
     *      -  Fix: Revised program to load SLDISP with value from
     *         OSDISP when no slot found when creating OUT label.
CWDaA*    10/28/09  MLB  CWDa
     *      -  Fix: Revised program to add above mod to routine
     *         PICKRP.
CWDbA*    02/27/12  JCJ  CWDb
     *      - Fix: Load the zone template into the label file instead
     *        of the truck template.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRY A*    04/15/10  MLB  DRY
     *      -  Fix: Revised program to load SLDISP with value from
     *         OSDISP when no slot found when creating OUT label.
     *      -  Added DRY to CWD mod.
DRYaA*    12/20/11  MLB  DRYa
     *      -  Enh: Revised program to retrieve record from slot file
     *         using SLOT12 instead of SLOT2.  Slot12 moves the w/h
     *         department after the slot display field. This was done
     *         to look up the slot without the department code from the
     *         item.  Dairyland has certain items that are in different
     *         departments across their 6 warehouses.
     *      -  Added file SLOT12 to pgm.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: AJ Silberman
     *
SLBaA*    08/21/11  JCJ  SLBa
     *      - Fix: Load the zone template into the label file instead
     *        of the truck template.
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Wholesale
     *
CTWaA*    02/27/12  JCJ  CTWa
     *      - Fix: Load the zone template into the label file instead
     *        of the truck template.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Nicholas & Co.
     *
NCH A*    03/19/12  MLB  NCH
     *      -  Fix: Revised program to load SLDISP with value from
     *         OSDISP when no slot found when creating OUT label.
     *      -  Added NCH to CWD mod.
NCHaA*    03/19/12  MLB  NCHa
     *      -  Fix: Revised program to add above mod to routine
     *         PICKRP.
     *      -  Added NCHa to CWDa mod.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kellys Foods
     *
KFS A*    10/02/12  MLB  KFS
     *      - Fix: Load the zone template into the label file instead
     *        of the truck template.
     *      - Added KFS to CTWa mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Reinhart
     *
RFSaA*    11/19/14  JCJ  RFSa
     *      -  Enh: Revised program to use tie/hi when calculating
     *         pallet cubes for bulk picks.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Panos Foods
     *
PAN A*    08/24/16  MLB  PAN
     *      -  Enh: Revised program to use tie/hi when calculating
     *         pallet cubes for bulk picks.
     *      -  Added PAN to RFSa mod.
PANaA*    08/26/16  MLB  PANa
     *      -  Enh: Revised BULKPK to get out if LEFTQ1 is less than
     *         DSQMAX, qty that will fit on 1 pallet. Only want to build
     *         full pallets that are bulk picks. Otherwise, pick normally.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dilgard
     *
DFF A*    06/17/19  MLB  DFF
     *      -  Fix: Revised program to load SLDISP with value from
     *         OSDISP when no slot found when creating OUT label.
     *      -  Added DFF to CWD mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jake's Finer Foods
     *
JFF A*    03/05/18  MLB  JFF
     *      -  Enh: Revised program to use value in rtxdm1_omwhdp if
     *         value > blanks. Otherwise, use value from ITWHDP to look
     *         up pick slot record. This is needed for PwrWhse Truck-
     *         Builder(r) integration.
     *      -  Added ORDDM to pgm. Requires manual open.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: DiCarlo Foodservice
     *
DIC A*    01/27/21  MLB  DIC
     *      -  Enh: Revised program to use value in rtxdm1_omwhdp if
     *         value > blanks. Otherwise, use value from ITWHDP to look
     *         up pick slot record. This is needed for PwrWhse Truck-
     *         Builder(r) integration.
     *      -  Added ORDDM to pgm. Requires manual open.
     *      -  Added DIC to JFF mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Hillcrest Foodservice
     *
HFI A*    09/24/21  MLB  HFI
     *      -  Enh: Revised program to use value in rtxdm1_omwhdp if
     *         value > blanks. Otherwise, use value from ITWHDP to look
     *         up pick slot record. This is needed for PwrWhse Truck-
     *         Builder(r) integration.
     *      -  Added ORDDM to pgm. Requires manual open.
     *      -  Added HFI to JFF mod.
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
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  71        EOF on read to ORDDS.
     *  79        CHAIN INDICATOR
     *  90        OVERFLOW INDICATOR FOR EXCEPTION REPORT
     *  91        OVERFLOW INDICATOR FOR CATCH WEIGHT REPORT
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fordh2     uf   e           k disk
     Fordd1     uf   e           k disk
JFF AForddm     if   e           k disk    usropn
     Fordds     if   e           k disk
     Fpiritem   if   e           k disk
RFSaAFitemmsc   if   e           k disk
     Fitemdsc   if   e           k disk
     Fitemdef1  if   e           k disk
     Foptionz   if   e           k disk
     Foptions   if   e           k disk
     Ftruckh    if   e           k disk
520bDF*oned2    if   e           k disk
     Fslot2     if   e           k disk
     F                                     rename(slrec:slrec2)
DRYaAFslot12    if   e           k disk    usropn
DRYaAF                                     rename(slrec:slrec12)
     Fpirtrck2  o    e             disk
     Fworklbl   o  a e           k disk
     For610ppr  o    e             printer oflind(*in90)
     F                                     usropn
730bAFbfcdebug  o  a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a40             s              1    dim(40)
     D a80             s              1    dim(80)
     D msg             s             40    dim(5) ctdata perrcd(1)
     D ovrprt          s             80    dim(1) ctdata perrcd(1)
500aA*----------------------------------------------------------------
500aA*  Customer id
500aA*
     D @getcl          c                   const('GETCLIENT')
500aA*
CWD A /copy qcopysrc,id#cashwa
DRY A /copy qcopysrc,id#dairyla
SLBaA /copy qcopysrc,id#silberm
CTWaA /copy qcopysrc,id#citywho
FSHaA /copy qcopysrc,id#fischer
NCH A /copy qcopysrc,id#nichola
KFS A /copy qcopysrc,id#kfs
RFSaA /copy qcopysrc,id#rfs
PAN A /copy qcopysrc,id#pan
JFF A /copy qcopysrc,id#jff
DFF A /copy qcopysrc,id#dff
DIC A /copy qcopysrc,id#dic
HFI A /copy qcopysrc,id#hfi
500aA*
JFF A*----------------------------------------------------------------
JFF A*  Retalix Custom Import Detail data structures
JFF A*----------------------------------------------------------------
JFF A
JFF A /copy qcopysrc,orddm1_rtx
JFF A /copy qcopysrc,orddm2_rtx
JFF A /copy qcopysrc,orddm3_rtx
JFF A /copy qcopysrc,orddm4_rtx
JFF A /copy qcopysrc,orddm5_rtx
JFF A
     *----------------------------------------------------------------
     *  Tie/High definitions data structure.
     *
     D defs            ds                  occurs(9)
     D  dssdef                 1      2
     D  dstie                  3      6  0
     D  dshigh                 7      8  0
     D  dsqmax                 9     15  0
     D  dsqmin                16     22  0
     D  dsmtch                23     23
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  *PICK  -  Picking options
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
     *                3 = Descending by stop then location.
     *    OPSELM  -  Selection method.
     *                1 = Single pass (By location).
     *                2 = Multiple pass (By stop).
     *    OPSPLT  -  Allow stop to be split across pallets (Y/N).
     *    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
     *    OPNWPL  -  Start new pallet when aisle changes if build method
     *               is 2=Location.
     *    OPFORD  -  Maximu orders per pallet.
     *    OPPTYP  -  Pallet type (P=Pallet, T=Tote, B=Batch).
     *    OPFTOT  -  Maximum totes per pallet.
     *    OPTECB  -  External tote cube.
     *    OPTICB  -  Internal tote cube.
     *    OPTSTP  -  Maximum stops per tote.
     *    OPTORD  -  Maximum orders per tote.
     *    OPTPCS  -  Maximum pieces per tote.
     *    OPSTOP  -  Honor *SP flag (Y=Yes, N=No).
     *    OPGCDE  -  USF Group Code (0-9).
     *    OPPKUP  -  Picked up by (S=Selector, L=Loader).
     *    OPSPAL  -  Merge pallet should only contain
     *               items for single truck pallet (Y=Yes, N=No).
     *    OPPITM  -  Maximum items per pallet.
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
     D  opnwpl                38     38
     D  opford                39     40  0 inz(0)
     D  opptyp                41     41
     D  opftot                42     43  0 inz(0)
     D  optecb                44     48  2 inz(0)
     D  opticb                49     53  2 inz(0)
     D  optstp                54     55  0 inz(0)
     D  optord                56     57  0 inz(0)
     D  optpcs                58     60  0 inz(0)
     D  opstop                61     61
     ** Note: Pos 62 is OPGCDE for USF, but OPPKUP for all other clients.
     D  opgcde                62     62
     D  oppkup                62     62
     D  opspal                63     63
     D  oppitm                64     67  0 inz(0)
     D  opdend               117    117
     *----------------------------------------------------------------
     *  *GENPICK -  General picking options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPERPT  -  Print exception (short) error report (Y,N).
     *    OPELBL  -  Print exception (short) labels (Y,N)
     *    OPRFWC  -  Using RF will call (Y,N).
     *    OPNRSC  -  Number of pallet sections (1-9).
     *    OPHPWC  -  Host pick Will Call (Y/N).
     *    OPMRGA  -  Merge Add-on order(s) with Open Routes.
     *    OPPLSQ  -  Pallet number sequence. 1=Unload seq, 2=Load seq
     *    OPEADJ  -  Close short labels without adjustment (Y,N).
     *    OPNOPK  -  Pick items without pick slot as bulk pick? (Y/N)
     *
     * Data structure
     *
     D opdta1          ds
     D  operpt                 1      1
     D  opelbl                 2      2
     D  oprfwc                 3      3
     D  opnrsc                 4      4  0
     D  ophpwc                 5      5
     D  opmrga                 6      6
     D  opplsq                 7      7
     D  opeadj                 8      8
     D  opnopk                 9      9
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
520bD **---------------------------------------------------------------
520bD** Multiple occurance data structure for zone options
520bD**
520bDD*opts            ds                  occurs(50)
520bDD* #dzone                 1      6
520bDD* #dbpck                 7      9  0
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
     *    TRRORD  -  Restart order number
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
     *    TRZONE  -  Picking zone
     *    TRDT10  -  See defintion for zone pick options.
     *
     * Data structure
     *
     D tr10ds          ds
     D  trzone                 1     10
     D  trdt10                11    150
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
     D tr05            c                   const('QtyOrd:')
     D tr06            c                   const('QtyAlc:')
     D tr07            c                   const('QtyPck:')
     D tr08            c                   const('ExpDate:')
     D tr09            c                   const('Slot bypassed: Produ-
     D                                     ct has expired.')
     D tr10            c                   const('Slot bypassed: No pr-
     D                                     oduct in slot.')
     D tr11            c                   const('Slot bypassed: No pr-
     D                                     oduct available in s-
     D                                     lot.')
     D tr12            c                   const('Warehouse allocation-
     D                                      completed with no e-
     D                                     rrors.')
     D tr13            c                   const('Warehouse allocation-
     D                                      complete with at le-
     D                                     ast one allocation e-
     D                                     xception.')
     D tr14            c                   const('No overflow slots me-
     D                                     t bulk pick criteria-
     D                                     .')
     D tr15            c                   const('Qty remaining not en-
     D                                     ough for bulk pick:')
     D tr16            c                   const('Slot bypassed: Short-
     D                                      qty for bulk pick.')
     D tr17            c                   const('No tie/high availabl-
     D                                     e. Available qty is -
     D                                     one full pallet.')
     D tr18            c                   const('Bulk pick created.')
     D tr19            c                   const('Looking for qty to b-
     D                                     ulk pick.')
     D tr20            c                   const('Key:')
     D tr21            c                   const('QtyAvail:')
     D tr22            c                   const('QtyPicked:')
     D tr23            c                   const('Ck slots w/same date')
     *  Allocation status messages.
     D trerfl          c                   const('*NOTFOUND')
     D tr80            c                   const('Allocated           ')
     D tr81            c                   const('Allocation error    ')
     *----------------------------------------------------------------
     D                 ds
     D  wkoitm                 1     15
     D  wkaisl                 1      3
     D  wkdsh1                 4      4
     D  wkloc                  5      7  0
     D  wkdsh2                 8      8
     D  wkrlvl                 9     10  0
     D  wkhand                11     12
     D  wkbulk                15     15
     *----------------------------------------------------------------
     *  Called programs
     *
     D @getsi          c                   const('GETSLOTITM')
     D @cvtdt          c                   const('CVTDTE')
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
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  Program info data structure
     *
730bA /copy qcopysrc,c#pgminfds
730bDD*               sds
730bDD* #prog            *proc
730bDD* #job                 244    253
730bDD* #user                254    263
730bDD* #jobn                264    269
730bDD* #jobdt               276    281  0
730bDD* #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Variables
     *
530bD *#dbpck                         2  0
530bMD #dbpck                         3  0
     D $msgf           s             10
     D #bitem          s                   like(ititem)
     D #odesc          s                   like(itdesc)
     D #oitem          s                   like(ititem)
     D #opdsc          s                   like(itpdsc)
     D #otype          s              1
     D #sitem          s                   like(ititem)
     D avail1          s              5  0
     D avail2          s              3  0
     D avail3          s              3  0
     D blkpct          s                   like(#dbpck)
     D c#cube          s                   like(itcube)
     D curdef          s              1  0
     D cvt1a           s              1
     D cvt5a           s              5
     D cvt8a           s              8
     D diffq1          s                   like(odqor1)
     D diffq2          s                   like(odqor2)
     D diffq3          s                   like(odqor3)
     D dscln           s             80
     D eofod           s              1
     D eofoh           s              1
     D excpq1          s              5  0
     D excpq2          s              5  0
     D excpq3          s              5  0
     D flgpck          s              1
     D flgtrk          s              1
     D forevr          s              1
     D hmaisl          s                   like(slaisl)
     D hmdisp          s                   like(sldisp)
     D hmhand          s                   like(slhand)
     D hmloc           s                   like(slloc)
     D hmrlvl          s                   like(slrlvl)
     D hmstyp          s                   like(slstyp)
     D hmwhdp          s                   like(slwhdp)
     D hmwhse          s                   like(slwhse)
     D kycode          s                   like(opzcod)
     D kyopen          s              1
     D kyum            s                   like(idum)
     D leftq1          s              5  0
     D leftq2          s              5  0
     D leftq3          s              5  0
     D lstdef          s              1  0
     D lstdev          s                   like($dev)
     D lstfrm          s                   like($form)
     D lstopt          s              2  0
     D lstqty          s                   like(odqor1)
     D lstwhs          s                   like($whse)
     D lwlas2          s              3
     D lwlqav          s              5  0
     D lwltyp          s              1
     D ocode           s              8
     D odflag          s              1
     D ohflag          s              1
     D opened          s              1
     D pckcnt          s              3  0
     D pickq1          s              5  0
     D pickq2          s              5  0
     D pickq3          s              5  0
     D prflag          s              1
     D r               s              3  0
     D remain          s              5  0
     D s#cube          s                   like(itcube)
     D stop            s              1
     D svaisl          s                   like(slaisl)
     D svdisp          s                   like(sldisp)
     D svhand          s                   like(slhand)
     D svloc           s                   like(slloc)
     D svpseq          s                   like(slpseq)
     D svrlvl          s                   like(slrlvl)
     D svstyp          s                   like(slstyp)
     D svwhdp          s                   like(slwhdp)
     D svwhse          s                   like(slwhse)
     D temp30          s             30
     D tmavl1          s                   like(avail1)
     D tmavl2          s                   like(avail2)
     D tmavl3          s                   like(avail3)
     D tmpflg          s              1
     D today           s              8  0
     D trerr           s              1
     D trkey           s             10
     D trnbr           s              4
     D trsq10          s              3  0
     D trsq40          s              3  0
     D trsq50          s              3  0
     D trsubr          s              6
     D ttlpk1          s              5  0
     D ttlpk2          s              5  0
     D ttlpk3          s              5  0
     D updflg          s             10
     D uxflag          s              1
     D xopt            s              2  0
520bDD*zone            s                   like(zdzone)
530 AD $ptmpl          s             10
730bAD pNextLbl#       s             11  0
730bAd nextLbl#        s                   like(lwlbl#)

730bA*----------------------------------------------------------------
730bA*  Prototypes
730bA*----------------------------------------------------------------
730bA
730bA /copy qcopysrc,p.pirlbl#w
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *PICK    - Picking new orders.
     *              *RESTART - Restarting abnormally ended batch.
     *      $PPRG   Program to send messages back to.
     *      $PBAT   Batch number
     *      $PWHSE  Warehouse
     *      $PTRUK  Truck
     *      $POTYP  Order type.
     *      $PRTID  Route id
     *      $PRTE   Route
     *      $PORD   Order
     *
     *    Returned Parameters
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message sent to pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pprg            10
     C                   parm                    $pbat             7 0
     C                   parm                    $pwhse            3 0
     C                   parm                    $ptruk           10
     C                   parm                    $potyp            1
     C                   parm                    $prtid            5
     C                   parm                    $prte             5
     C                   parm                    $pord             7 0
     C                   parm                    $prtn             8
     C                   parm                    $pmsg             4
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      $prtn = *blanks
     *
     *  The program will execute CRTLBL only if UPDFLG is set to
     *  '*NOUPDAT'.  This flag should be custom set if the client
     *  wants to use truck builder without allocating qty on BFC side.
     *
     C                   eval      updflg = *blanks
     C                   if        updflg = '*NOUPDAT'
     C                   exsr      crtlbl
     C                   eval      *inlr = *on
     C                   return
     C                   endif
     *
     *
     * Open printer
     *
     C                   exsr      opnprt
     *
     * Loop through orders for the batch.
     *
     C                   eval      prflag = *off
     C                   eval      ohflag = *off
     C                   eval      eofoh = *off
     C                   dou       eofoh = *on
     C                   exsr      getoh
     C     eofoh         cabeq     *on           endoh
     *
     *    Loop through detail records for order.
     *
     C                   eval      odflag = *off
     C                   eval      eofod = *off
     C                   dou       eofod = *on
     C                   exsr      getod
     C     eofod         cabeq     *on           endod
     *
     *       Initialize exception quantity fields.
     *
     C                   eval      excpq1 = 0
     C                   eval      excpq2 = 0
     C                   eval      excpq3 = 0
     *
     *       Then pick items from slots.
     *
     C     itstyp        caseq     'P'           pickp
     C                   cas                     pickf2
     C                   endcs
     *
     *       Flag detail record as being picked.
     *
     C                   eval      odstat = 'P'
     C                   update    odrec
     *
     C     endod         tag
     C                   enddo
     *
     *    Update header record.
     *
     C                   eval      ohstat = 'P'
     C                   eval      ohsdte = today
     C                   time                    ohstim
     C                   eval      ohpbat = $pbat
     C                   update    ohrec
     *
     C     endoh         tag
     C                   enddo
     *
     * Close up shop and return home.
     *
     C     endpgm        tag
     C                   if        prflag = *on
     C                   write     foot1
     *                    EXSR DUPPRT
     C                   endif
     *
     *  Write out completion message.
     *
     C                   select
     C                   when      $pcmd <> '*OPEN'
     C                   if        trerr = *on
     C                   eval      trnbr = 'TR13'
     C                   eval      trcode = '*PCK050 '
     C                   movel     'MAINLN  '    trsr50
     C                   exsr      zztrck
     C                   else
     C                   eval      trnbr = 'TR12'
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
     C                   endsl
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
640 AC                   parm                    clientloc        10
JFF A*
JFF AC                   if        client = Jakes
DIC AC                             or client = DiCarlo
HFI AC                             or client = Hillcrest
JFF AC                   if        not %open(orddm)
JFF AC                   open      orddm
JFF AC                   endif
JFF AC                   endif
DRYaA*
DRYaA*  Open SLOT12 file.
DRYaAC                   if        client = Dairyland
DRYaA*
DRYaAC                   if        not %open(slot12)
DRYaAC                   open      slot12
DRYaAC                   endif
DRYaA*
DRYaAC                   endif
     *
     *  Initialize tracking key.
     *
     C                   eval      trwhse = $pwhse
     C                   movel(p)  #prog         trpgm
     C                   eval      trjbnr = #jobn
     C                   eval      $cvcmd = '*MDYCMD '
730bMC                   move      #jobdate      $cvd6i
     C                   eval      $cvd8o = *zeros
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      trjbdt = $cvd8o
730bMC                   eval      trjbtm = #jobtime
     C                   eval      trdev = #job
     C                   eval      truser = #user
     C                   eval      trtruk = $ptruk
     C                   eval      trrte = $prte
     C                   eval      trrtid = $prtid
     C                   eval      trpbat = $pbat
     C                   eval      r = *zeros
     C                   eval      trsubr = *blanks
     C                   eval      trkey = *blanks
     C                   eval      trrfld = *blanks
     C                   eval      trsq10 = *zeros
     C                   eval      trsq40 = *zeros
     C                   eval      trsq50 = *zeros
     C                   eval      trnbr = *blanks
     C                   eval      cvt1a = *blanks
     C                   eval      cvt5a = *blanks
     C                   eval      cvt8a = *blanks
     C                   eval      trkey = *blanks
     C                   eval      trerr = *off
     C                   eval      flgpck = *off
     C                   eval      flgtrk = *off
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     '*INZSR  '    trsubr
     C                   exsr      zztrck
     *
     C                   eval      kyopen = 'O'
     *
     *  Define save fields for different item types.
     *
     C                   eval      #otype = *blanks
     *
     *     Define full key for OPTIONS file.
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
JFF A*
JFF A*  Define full key for ORDDM file.
JFF A*
JFF AC     keyom         klist
JFF AC                   kfld                    odwhse
JFF AC                   kfld                    odord
JFF AC                   kfld                    odseq
JFF AC                   kfld                    oditem
     *
     *  Define full key for ORDDS file.
     *
     C     keyos         klist
     C                   kfld                    odwhse
     C                   kfld                    odord
     C                   kfld                    odseq
     C                   kfld                    oditem
JFF A*
JFF A*  Define partal key for ORDDM file.
JFF A*
JFF AC     keyom1        klist
JFF AC                   kfld                    odwhse
JFF AC                   kfld                    ohord
     *
     *  Define partal key for ORDDS file.
     *
     C     keyos1        klist
     C                   kfld                    odwhse
530aDC*                  kfld                    odord
530aMC                   kfld                    ohord
     *
     *  Define partial key for ORDH2 file.
     *
     C     keyoh2        klist
     C                   kfld                    $pwhse
     C                   kfld                    kyopen
     C                   kfld                    $potyp
     C                   kfld                    $prtid
     *
     *  Define partial key for ORDD1 file.
     *
     C     keyod1        klist
     C                   kfld                    $pwhse
     C                   kfld                    ohord
     C                   kfld                    kyopen
     *
     *  Define key for PIRITEM file.
     *
     C     keyit         klist
     C                   kfld                    $pwhse
     C                   kfld                    oditem
     *
     *  Define partial key for ITEMDEF1 file.
     *
     C     keyid1        klist
     C                   kfld                    $pwhse
     C                   kfld                    oditem
     C                   kfld                    kyum
     C                   eval      kyum = 'N'
RFSaA*
RFSaA*  Define key for ITEMMSC file.
RFSaA*
RFSaAC     keyims        klist
RFSaAC                   kfld                    $pwhse
RFSaAC                   kfld                    oditem
     *
     *  Define key for ITEMDEF1 file.
     *
     C     keydef        klist
     C                   kfld                    $pwhse
     C                   kfld                    oditem
     C                   kfld                    kyum
     C                   kfld                    slsdef
     *
     *  Define key for SLOT2 file.
     *
     C     kysl2a        klist
     C                   kfld                    odwhse
     C                   kfld                    itwhdp
     C                   kfld                    osdisp
DRYaA*
DRYaA*  Define key for SLOT12 file.
DRYaA*
DRYaAC     kysl12a       klist
DRYaAC                   kfld                    odwhse
DRYaAC                   kfld                    osdisp
     *
     *  Define partial key for OPTIONS file.
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
530 A ***                kfld                    $ptruk
530 AC                   kfld                    $ptmpl
     *
     *  Define key for truck file.
     *
     C     keyth         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptruk
     *
     *  Define key for zone detail search file.
     *
     C     keyzd2        klist
     C                   kfld                    $pwhse
530 A ***                kfld                    $ptruk
530 AC                   kfld                    $ptmpl
     C                   kfld                    itwhdp
     *
     *  Variables and constants.
     *
     C                   eval      forevr = *off
     C                   eval      pckcnt = 0
     *
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
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
     *
     *    Get general picking options from options file.
     *
     C                   eval      opcode = '*GENPICK'
     C     keyop         chain     options                            79
     C                   eval      opdta1 = opdata
     C                   if        *in79
     C                   eval      operpt = 'Y'
     C                   eval      opelbl = 'N'
     C                   eval      ophpwc = 'N'
     C                   eval      flgpck = *on
     C                   endif
520bDC**
520bDC**   Get zone options and save in data structure.
520bDC**
520bDC**                 eval      kycode = '*PICK   '
520bDC**   keyopz        setll     optionz
520bDC**                 eval      lstopt = 0
520bDC**                 dou       forevr <> forevr
520bDC**   keyopz        reade     optionz                                79
520bDC**                 if        *in79
520bDC**                 leave
520bDC**                 endif
520bDC**
520bDC**      Save options in data structure.
520bDC**
520bDC**                 add       1             lstopt
520bDC**   lstopt        occur     opts
520bDC**                 eval      #dzone = opzzon
520bDC**                 eval      #dbpck = opbpck
520bDC**
520bDC** Write out tracking record.
520bDC**
520bDC**                 eval      trcode = '*PCK010 '
520bDC**                 exsr      zztrck
520bDC**
520bDC**                 enddo
520bDC**
520bDC**      Initialize a "catch all" default.
520bDC**
520bDC**                 add       1             lstopt
520bDC**   lstopt        occur     opts
520bDC**                 eval      #dzone = *blanks
520bDC**                 eval      #dbpck = 999
     *
     *    Get truck information.
     *
     C     keyth         chain     truckh                             79
     C                   if        *in79
     C                   eval      thbulk = 'N'
     C                   eval      flgtrk = *on
     C                   endif
     *
530 AC                   if        %found(truckh)
530 AC                             and thtype = 'T'
530 AC                   eval      $ptmpl = thztmp
530 AC                   else
530 AC                   eval      $ptmpl = $ptruk
530 AC                   endif
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK002 '
     C                   exsr      zztrck
     C                   eval      trcode = '*PCK003 '
     C                   exsr      zztrck
     C                   endsr
     *----------------------------------------------------------------
     *
     *  AVAIL   Calculate available quantities for slot.
     *
     C     avail         begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'AVAIL   '    trsubr
     C                   exsr      zztrck
     *
     *  Force order quantity into available quantity.
     *
     C                   eval      avail1 = odqor1
     C                   z-add     odqor2        avail2
     C                   z-add     odqor3        avail3
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  BULKPK  Bulk pick.
     *
     *      - Bulk pick is determined by the flag sent with the order
     *        detail record. Bulk pick is taken from the slot sent
     *        with the order detail record.
     *
     C     bulkpk        begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'BULKPK  '    trsubr
     C                   exsr      zztrck
     *
     C                   eval      trnbr = 'TR19'
     C                   eval      trsr50 = 'BULKPK'
     C                   eval      trcode = '*PCK050 '
     C                   exsr      zztrck
     *
     *
     C                   eval      s#cube = blkpct
     *
     C                   eval      lstdef = 0
     C                   eval      curdef = 0
     C                   eval      tmpflg = *off
     *
     *   Loop while ....
     *
     *       There is quantity left to be picked
     *       And something was picked last time through.
     *
     C                   eval      lstqty = 0
     *
     C                   dow       leftq1 <> 0  and
     C                             leftq1 <> lstqty
     *
     *   TMPFLG=*ON We did not find any slot that met bulk pick
     *              criteria.
     *
     C                   if        tmpflg = *on
     C                   eval      trnbr = 'TR14'
     C                   eval      trsr50 = 'BULKPK'
     C                   eval      trcode = '*PCK050 '
     C                   exsr      zztrck
     C                   leave
     C                   endif
     *
     C                   eval      lstqty = leftq1
     *
     *     Calculate quantity available in slot.
     *
     C                   exsr      avail
     *
     *     Calculate available cube.
     *
     C     avail1        mult      itcube        c#cube
     *
     *   Get "Normal" Tie/High definitions for item.
     *
RFSaAC                   select
RFSaAC                   when      client = RFS
PAN AC                             or client = Panos
NCSbAC     keyims        chain     itemmsc                            77
     C                   if        not *in77
     C     1             occur     defs
     C                   eval      dssdef = *blanks
     C                   eval      dstie = imtie
     C                   eval      dshigh = imhigh
     C                   select
     C                   when      imtie = 0
     C                   eval      dsqmax = imhigh
     C                   when      imhigh = 0
     C                   eval      dsqmax = imtie
     C                   other
     C                   eval      dsqmax = imtie * imhigh
     C                   endsl
PANaA*
PANaAC                   if        client = Panos
PANaA*       Get out if not at least 1 full pallet qty.
PANaAC                   if           leftq1 < dsqmax
PANaAC                             or dsqmax <= 0
PANaAC                   leave
PANaAC                   endif
PANaAC                   endif
PANaA*
     C                   if        avail1 < dsqmax
     C                   eval      dsqmax = avail1
     C                   endif
     *
     *   If no tie/high defined, then consider qty available as
     *   one full pallet load.
     *
     C                   else
     C                   eval      dsqmax = avail1
     C                   eval      imtie = 0
     C                   eval      imhigh = 0
     C                   eval      dstie = 0
     C                   eval      dshigh = 0
     C                   eval      trnbr = 'TR17'
     C                   eval      trsr50 = 'BULKPK'
     C                   eval      trcode = '*PCK050 '
     C                   exsr      zztrck
     C                   endif
RFSaAC                   other
     C     keydef        chain     itemdef1                           77
     C                   if        not *in77
     C     1             occur     defs
     C                   eval      dssdef = idsdef
     C                   eval      dstie = idtie
     C                   eval      dshigh = idhigh
     C                   select
     C                   when      idtie = 0
     C                   eval      dsqmax = idhigh
     C                   when      idhigh = 0
     C                   eval      dsqmax = idtie
     C                   other
     C                   eval      dsqmax = idtie * idhigh
     C                   endsl
     C                   if        avail1 < dsqmax
     C                   eval      dsqmax = avail1
     C                   endif
     *
     *   If no tie/high defined, then consider qty available as
     *   one full pallet load.
     *
     C                   else
     C                   eval      dsqmax = avail1
     C                   eval      idtie = 0
     C                   eval      idhigh = 0
     C                   eval      dstie = 0
     C                   eval      dshigh = 0
     C                   eval      trnbr = 'TR17'
     C                   eval      trsr50 = 'BULKPK'
     C                   eval      trcode = '*PCK050 '
     C                   exsr      zztrck
     C                   endif
RFSaAC                   endsl
     *
     *       Calculate quantity to pick.
     *
     C                   if        dsqmax <= leftq1
     C                   z-add     dsqmax        pickq1
     C                   eval      remain = 0
     C                   else
     C                   eval      pickq1 = leftq1
     C     dsqmax        sub       leftq1        remain
     C                   endif
     *
     *       Create label for bulk pick.
     *
RFSaAC                   select
PAN MC                   when      (client = rfs
PAN AC                             or client = Panos)
RFSaAC                             and remain <> *zeros
RFSaAC                   leave
RFSaAC                   other
     C                   clear                   lwrec
     C                   eval      lwwhse = slwhse
SLBaAC                   select
SLBaAC                   when      client = silberman
CWDbAC                             or client = cashwa
CTWaAC                             or client = citywho
KFS AC                             or client = kellys
SLBaAC                   eval      lwtruk = $ptmpl
SLBaAC                   other
     C                   eval      lwtruk = $ptruk
SLBaAC                   endsl
     C                   eval      lwwhdp = slwhdp
     C                   eval      lwaisl = slaisl
     C                   eval      lwloc = slloc
     C                   eval      lwrlvl = slrlvl
     C                   eval      lwhand = slhand
     C                   eval      lwpseq = slpseq
     C                   eval      lwstyp = slstyp
     C                   if        lwstyp = 'P'
     C                   eval      lwqryf = 1
     C                   else
     C                   eval      lwqryf = 0
     C                   endif
     C                   eval      lwdisp = sldisp
     C                   eval      lwqavl = avail1
     C                   eval      lwrte = ohrte
     C                   eval      lwstop = ohstop
     C                   eval      lword = ohord
     C                   eval      lwseq = odseq
     C                   eval      lwitem = oditem
     C                   eval      lwpbat = $pbat
     C                   eval      lwutyp = 'N'
     C                   eval      lwucod = itum1
     C                   eval      lwucub = itcube
     C     lwucub        mult      pickq1        lwcube
     C                   eval      lwuwgt = itswgt
     C     lwuwgt        mult      pickq1        lwswgt
     C                   eval      lwqalc = pickq1
     C                   eval      lwqrmn = remain
     C                   eval      lwtie = dstie
     C                   eval      lwhigh = dshigh
     C                   eval      lwgrp1 = 'S'
     C                   eval      lwgrp2 = $potyp
     C                   eval      lwtype = 'B'
     C                   eval      lwstat = 'A'
     C                   eval      lwsdte = today
     C                   time                    lwstim
     C                   eval      lwrdte = today
730bDC**                 call      'PIRLBL#'
730bDC**                 parm                    lwlbl#
730bMC                   exsr      GetNextLbl#
730bMC                   eval      lwlbl# = nextLbl#
     C                   write     lwrec
     *
     *       Reduce quantity left to pick.
     *
     C                   eval      leftq1 = leftq1 - pickq1
     C                   add       pickq1        ttlpk1
     *
     *       Leave slot reading loop.
     *
     C                   eval      trnbr = 'TR18'
     C                   eval      trsr50 = 'BULKPK'
     C                   eval      trcode = '*PCK050 '
     C                   exsr      zztrck
     *
RFSaAC                   endsl
     C                   enddo
     C     endbp         endsr
     *
     *----------------------------------------------------------------
     *
     *  CLRSL   Clear SLOT2 fields when slot not found.
     *
     C     clrsl         begsr
     *
     C                   eval      slwhdp = *blanks
     C                   eval      slaisl = *blanks
     C                   eval      slloc = *zeros
     C                   eval      slrlvl = *zeros
     C                   eval      slhand = *blanks
     C                   eval      slside = *zeros
     C                   eval      sldisp = *blanks
     C                   eval      slstat = *blanks
     C                   eval      slsdte = *zeros
     C                   eval      slstim = *zeros
     C                   eval      slsdef = *blanks
     C                   eval      sldesg = *blanks
     C                   eval      slactv = *blanks
     C                   eval      slbld = *blanks
     C                   eval      slpick = *blanks
     C                   eval      slpseq = *zeros
     C                   eval      slprty = *zeros
     C                   eval      slentd = *zeros
     C                   eval      slexpd = *zeros
     C                   eval      slslfd = *zeros
     C                   eval      slrsrv = *blanks
     C                   eval      slitem = *blanks
     C                   eval      slstk1 = *zeros
     C                   eval      slstk2 = *zeros
     C                   eval      slstk3 = *zeros
     C                   eval      slalc1 = *zeros
     C                   eval      slalc2 = *zeros
     C                   eval      slalc3 = *zeros
     C                   eval      sltfr1 = *zeros
     C                   eval      sltfr2 = *zeros
     C                   eval      sltfr3 = *zeros
     C                   eval      slpck1 = *zeros
     C                   eval      slpck2 = *zeros
     C                   eval      slpck3 = *zeros
     C                   eval      slrcv1 = *zeros
     C                   eval      slrcv2 = *zeros
     C                   eval      slrcv3 = *zeros
     *
     C     endsl         endsr
     *
     *----------------------------------------------------------------
     *
     *  CRTLBL  Create label records - No allocation on BFC side.
     *
     C     crtlbl        begsr
     *
     C     keyoh2        setll     ordh2
     C                   dou       forevr <> forevr
     C     keyoh2        reade     ordh2                                  79
     C                   if        *in79
     C                   leave
     C                   endif
     *    Loop thru detail records and create label records.
     C     keyod1        setll     ordd1
     C                   dou       forevr <> forevr
     C     keyod1        reade     ordd1                                  78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   eval      wkoitm = odoitm
     C                   select
     C                   when      odqor1 > 0
     C                   eval      pickq1 = odqor1
     C                   when      odqor2 > 0
     C                   eval      pickq1 = odqor2
     C                   when      odqor3 > 0
     C                   eval      pickq1 = odqor3
     C                   endsl
     C                   clear                   lwrec
     C                   eval      lwwhse = $pwhse
SLBaAC                   select
SLBaAC                   when      client = silberman
CWDbAC                             or client = cashwa
CTWaAC                             or client = citywho
KFS AC                             or client = kellys
SLBaAC                   eval      lwtruk = $ptmpl
SLBaAC                   other
     C                   eval      lwtruk = $ptruk
SLBaAC                   endsl
     C     keyit         chain     piritem                            79
     C                   if        *in79
     C                   eval      itwhdp = *blanks
     C                   eval      itstyp = *blanks
     C                   eval      itum1 = *blanks
     C                   eval      itcube = 0
     C                   eval      itswgt = 0
     C                   endif
     C                   eval      lwwhdp = itwhdp
     C                   eval      lwseq = odseq
     C                   eval      lwitem = oditem
     C                   eval      lwpbat = $pbat
     C                   eval      lwaisl = wkaisl
     C                   eval      lwloc = wkloc
     C                   eval      lwrlvl = wkrlvl
     C                   eval      lwhand = wkhand
     C                   eval      lwstyp = itstyp
     C                   if        lwstyp = 'P'
     *R                   MOVE '1'       LWVRFY
     C                   move      '1'           lwqryf
     C                   else
     *R                   MOVE '0'       LWVRFY
     C                   move      '0'           lwqryf
     C                   endif
     C                   movel     odoitm        lwdisp
     C                   eval      lwasl2 = '***'
     C                   eval      lwrte = ohrte
     C                   eval      lwstop = ohstop
     C                   eval      lword = ohord
     C                   eval      lwspcl = odspcl
     C                   eval      lwutyp = 'N'
     C                   eval      lwucod = itum1
     C                   eval      lwucub = itcube
     C     lwucub        mult      pickq1        lwcube
     C                   eval      lwuwgt = itswgt
     C     lwuwgt        mult      pickq1        lwswgt
     C                   eval      lwqalc = pickq1
     C                   eval      lwgrp1 = 'S'
     C                   eval      lwgrp2 = $potyp
     C                   eval      lwtype = wkbulk
730bDC**                 call      'PIRLBL#'
730bDC**                 parm                    lwlbl#
730bMC                   exsr      GetNextLbl#
730bMC                   eval      lwlbl# = nextLbl#
     C                   eval      lwstat = 'A'
     C                   eval      lwsdte = today
     C                   time                    lwstim
     C                   eval      lwrdte = today
     C                   write     lwrec
     *
     C                   eval      odstat = 'P'
     C                   update    odrec
     *
     C                   enddo
     *   End detail records loop.
     C                   eval      ohstat = 'P'
     C                   eval      ohsdte = today
     C                   time                    ohstim
     C                   eval      ohpbat = $pbat
     C                   enddo
     *
     C     endlbl        endsr
     *----------------------------------------------------------------
     *
     *  DUPPRT  Dup. printer file.
     *
     C     dupprt        begsr
     *
     *      Duplicate printer file.
     *
     C                   close     or610ppr
     *  DUPPRTCL will execute the DUPSPLF command.
     *
     C                   movel     'OR610PR'     $lfile
     C                   movel     'HEMANT'      $loutq
     C                   movel     '*LAST'       $lspln
     C                   movel     'OR610PPR'    $lnnam
     *
     C                   call      'DUPPRTCL'
     C                   parm                    $lfile           10
     C                   parm                    #jobn
     C                   parm                    #user
     C                   parm                    #job
     C                   parm                    $loutq           10
     C                   parm      '*LIBL'       $lqlib           10
     C                   parm                    $lspln            6
     C                   parm      1             $lcpys            3 0
     C                   parm                    $lnnam           10
     C                   parm      '*NO'         $ldlto            4
     *
     C                   endsr

730bA*----------------------------------------------------------------
730bA*  GetNextLbl#    Get next label number
730bA*----------------------------------------------------------------
730bA
730bAC     getNextLbl#   begsr
      /free

         // Get next label number

         PirLbl#W($pwhse: pNextLbl#);

         // Make sure it isn't too large

         monitor;
           nextLbl# = pNextLbl#;
         on-error;
           nextLbl# = -9;
         endmon;

         // See if there was an error getting label number

         if nextLbl# <= 0;

           // Write message to BFCDEBUG

           bdvalues = 'Error getting lbl# '
                    + '(p' + %char(pNextLbl#) + '/' + %char(nextLbl#) + ') '
                    + 'for '
                    + 'Whse: ' + %char(lwwhse) + ', '
                    + 'Rtid: ' + %trimr(lwrte) + ', '
                    + 'Ord: ' + %char(lword) + ', '
                    + 'Seq: ' + %char(lwseq) + ', '
                    + 'Itm: ' + %trimr(lwitem);
           bdtype = '*ERROR';
           exsr wrtDebug;

           // Force divide by zero error to abnormally end program.

           nextLbl# = 0;
           pNextLbl# = pNextLbl# / nextLbl#;

         endif;

      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETOPT  Get picking options for zone.
     *          This routine is only called when looking for a bulk pick.
     *
     C     getopt        begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'GETOPT  '    trsubr
     C                   exsr      zztrck
     *
     *   Get zone for home slot.
     *
520bAC                   call      'GETZONE'
520bAC                   parm      '*GET'        $zcmd             8
520bAC                   parm      $ptruk        $ztruk           10
520bAC                   parm      ' '           $zrtid            5
520bAC                   parm      ohtype        $zotype           1
520bAC                   parm      slwhse        $zwhse            3 0
520bAC                   parm      slwhdp        $zwhdp            5
520bAC                   parm      sldisp        $zdisp           12
520bAC                   parm      slstyp        $zstyp            1
520bAC                   parm      slaisl        $zaisl            3
520bAC                   parm      slloc         $zloc             3 0
520bAC                   parm      slrlvl        $zrlvl            2 0
520bAC                   parm      slhand        $zhand            2
520bAC                   parm      slitem        $zitem           15
520bAC                   parm      sldesg        $zdesg            5
520bAC                   parm      ' '           $zutyp            1
520bAC                   parm      'N'           $ztote            1
520bAC                   parm      ' '           $zszon            6
520bAC                   parm      ' '           $zpzon            6
520bAC                   parm      ' '           $ztzon            6
520bAC                   parm      ' '           $zcomp            1
520bAC                   parm      0             $zgen             1 0
520bAC                   parm                    opzdta
720aAC                   parm      ohord         $zord             7 0
720aAC                   parm      slactv        $zactv            2
720aAC                   parm      slpick        $zpick            1
520bA
520bAC                   if        $zszon = 'ZZZZZZ'
520bAC                   eval      #dbpck = 999
520bAC                   else
520bAC                   eval      #dbpck = opbpck
520bAC                   endif

520bDC**                 eval      zone = *blanks
520bDC**
520bDC**   keyzd2        setll     zoned2
520bDC**                 dou       forevr <> forevr
520bDC**   keyzd2        reade     zoned2                                 79
520bDC**                 if        *in79
520bDC**                 leave
520bDC**                 endif
520bDC**
520bDC**     See if slot matches criteria.
520bDC**
520bDC**                 select
520bDC**
520bDC**       Location
520bDC**
520bDC**                 when      zdloc1 > 0  or
520bDC**                           zdloc1 > 0
520bDC**
520bDC**                 if        slloc >= zdloc1  and
520bDC**                           slloc <= zdloc2  and
520bDC**                           slaisl = zdaisl  and
520bDC**                           slstyp = zdstyp  and
520bDC**                           slwhdp = zdwhdp
520bDC**                 if        zdrlvl = 0  or
520bDC**                           slrlvl = zdrlvl
520bDC**                 eval      zone = zdzone
520bDC**                 endif
520bDC**                 endif
520bDC**                 iter
520bDC**
520bDC**       Level
520bDC**
520bDC**                 when      zdrlvl > 0
520bDC**
520bDC**                 if        slrlvl = zdrlvl  and
520bDC**                           slaisl = zdaisl  and
520bDC**                           slstyp = zdstyp  and
520bDC**                           slwhdp = zdwhdp
520bDC**                 eval      zone = zdzone
520bDC**                 endif
520bDC**                 iter
520bDC**
520bDC**       Aisle
520bDC**
520bDC**                 when      zdaisl <> *blanks
520bDC**
520bDC**                 if        slaisl = zdaisl  and
520bDC**                           slstyp = zdstyp  and
520bDC**                           slwhdp = zdwhdp
520bDC**                 eval      zone = zdzone
520bDC**                 endif
520bDC**                 iter
520bDC**
520bDC**       Section
520bDC**
520bDC**                 when      zdstyp <> *blank
520bDC**
520bDC**                 if        slstyp = zdstyp  and
520bDC**                           slwhdp = zdwhdp
520bDC**                 eval      zone = zdzone
520bDC**                 endif
520bDC**                 iter
520bDC**
520bDC**       Department
520bDC**
520bDC**                 when      zdwhdp <> *blank
520bDC**
520bDC**                 if        slwhdp = zdwhdp
520bDC**                 eval      zone = zdzone
520bDC**                 endif
520bDC**                 iter
520bDC**
520bDC**                 endsl
520bDC**
520bDC**                 enddo
520bDC**
520bDC**  Go through data structure to find options for department.
520bDC**  If department hasn't changed then there is nothing to do.
520bDC**
520bDC**                 if        zone <> #dzone
520bDC**   1             do        lstopt        xopt
520bDC**   xopt          occur     opts
520bDC**                 if        #dzone = zone
520bDC**                 leave
520bDC**                 endif
520bDC**                 enddo
520bDC**                 endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETOD   Get order detail record.
     *
     C     getod         begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'GETOD   '    trsubr
     C                   exsr      zztrck
     *
     *   If first time, set record pointer.
     *
     C                   if        odflag = *off
     C     keyod1        setll     ordd1
     C     keyos1        setll     ordds
JFF A*
JFF AC                   if        %open(orddm)
JFF AC     keyom1        setll     orddm
JFF AC                   endif
JFF A*
     C                   eval      odflag = *on
     C                   endif
     *
     *   Try to get a 'open' detail record for order.
     *
     C                   eval      stop = *off
     C                   dou       stop = *on  or
     C                             eofod = *on
     C     keyod1        reade     ordd1                                  79
     *
     *   Set flag if there are no more detail records.
     *
     C                   if        *in79
     C                   eval      eofod = *on
     C                   goto      endodl
     C                   endif
     *
     *   Get order detail pick slot record.
     *
     C     keyos         chain     ordds                              71
     C                   if        *in71
     C                   eval      osdisp = *blanks
     C                   eval      osbulk = 'N'
     C                   endif
     *
     *   Get item master record.
     *
     C     keyit         chain     piritem                            79
     C                   if        *in79
     C                   eval      p1msg = msg(1)
     C                   exsr      prterr
     C                   eval      trnbr = 'TR01'
     C                   eval      trcode = '*PCK050 '
     C                   movel     'GETOD   '    trsr50
     C                   exsr      zztrck
     C                   else
     C                   exsr      zzxopt
     C                   eval      dscln = *blanks
     C                   if        uxflag = *off
     C                   movel     itdesc        dscln
     C                   else
     C                   movel     ixdsc1        dscln
     C                   move      ixdsc2        dscln
     C                   endif
520bDC**                 exsr      getopt
     C                   eval      stop = *on
     C                   endif
JFF A*
JFF AC                   if        %open(orddm)
JFF AC     keyom         chain     orddm
JFF AC                   if        not %found(orddm)
JFF AC                   eval      ommsc1 = ' '
JFF AC                   eval      rtxdm1_ompckm = 0
JFF AC                   eval      rtxdm1_omwtiw = 0
JFF AC                   eval      rtxdm1_omcbec = 0
JFF AC                   eval      ommsc2 = ' '
JFF AC                   eval      ommsc3 = ' '
JFF AC                   eval      rtxdm3_omprcs = 0
JFF AC                   eval      rtxdm3_omspkn = 0
JFF AC                   eval      ommsc4 = ' '
JFF AC                   eval      ommsc5 = ' '
JFF AC                   else
JFF AC                   eval      orddm1_rtx = ommsc1
JFF A*      Use dept sent with order. Otherwise, default to dept on item.
JFF AC                   if        rtxdm1_omwhdp > ' '
JFF AC                   eval      itwhdp = rtxdm1_omwhdp
JFF AC                   endif
JFF AC                   eval      orddm2_rtx = ommsc2
JFF AC                   eval      orddm3_rtx = ommsc3
JFF AC                   eval      orddm4_rtx = ommsc4
JFF AC                   eval      orddm5_rtx = ommsc5
JFF AC                   endif
JFF AC                   endif
     *
     *
     *  Save information about item being picked (Item that was ordered)
     *
     C                   eval      #otype = ittype
     C                   eval      #oitem = ititem
     C                   eval      #odesc = itdesc
     C                   eval      #opdsc = itpdsc
     C                   eval      #bitem = ititem
     C                   eval      #sitem = ititem
     C                   eval      #bityp = ittype
     C                   eval      #sityp = ittype
     C                   eval      #bdesc = itdesc
     C                   eval      #bpdsc = itpdsc
     *
     *  If Contract, Alias or SSB item
     *   Then get Base item.
     *
     C                   if        ittype = 'C'  or
     C                             ittype = 'A'  or
     C                             ittype = 'S'
     C                   call      'GETBASE'
     **                   CALL @GETSI
     C                   parm      itwhse        $gwhse            3 0
     C                   parm      ititem        $gitem           15
     C                   parm      ' '           #bitem
     C                   parm                    #bityp            1
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     **                   PARM           #SRTN  10
     **                   PARM           #SMSG  60
     C                   parm                    #bwhdp            5
     C                   parm                    #bstyp            1
     C                   parm                    #bum              2
     C                   parm                    #bum2             2
     C                   parm                    #bumq2            3 0
     C                   parm                    #bum3             2
     C                   parm                    #bumq3            3 0
     C                   parm      ' '           #bcitm           15
     C                   parm                    #bctyp            1
     C                   parm                    #bcdsc           30
     C                   parm                    #bcpds           15
     C                   parm                    #bcwdp            5
     C                   parm                    #bcstp            1
     C                   parm                    #bcum             2
     C                   parm                    #bcum2            2
     C                   parm                    #bcuq2            3 0
     C                   parm                    #bcum3            2
     C                   parm                    #bcuq3            3 0
     C                   parm                    #brtn             8
     C                   endif
     *
     *  If Contract, Alias or SSB item
     *   Then get Base Slot item.
     *
     C                   if        ittype = 'A'  or
     C                             ittype = 'A'  or
     C                             ittype = 'S'
     C                   call      @getsi
     C                   parm      itwhse        $gwhse
     C                   parm      ititem        $gitem
     C                   parm      ' '           #sitem
     C                   parm                    #sityp            1
     C                   parm                    #sdesc           30
     C                   parm                    #spdsc           15
     C                   parm                    #srtn            10
     C                   parm                    #smsg            60
     C                   endif
     C     endodl        tag
     C                   enddo
     *
     *   If a record was found then get quantities.
     *
     C                   if        eofod <> *on
     *
     *      Convert ordered quantity to string for error msg.
     *
     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg
     C                   eval      $cqty1 = odqor1
     C                   eval      $cqty2 = odqor2
     C                   eval      $cqty3 = odqor3
     C                   call      'CVTQTY'
     C                   parm                    $ccmd             8
     C                   parm                    $cprg            10
     C                   parm                    $cqty1            7 0
     C                   parm                    $cqty2            7 0
     C                   parm                    $cqty3            7 0
     C                   parm                    $cum1             2
     C                   parm                    $cum2             2
     C                   parm                    $cum3             2
     C                   parm                    $cqstr           10
     C                   parm                    $custr           17
     C                   parm                    $crtn             8
     C                   parm                    $cerm
     C                   eval      p1qord = $cqstr
     C                   eval      p1qalc = *blanks
     C                   eval      p1qpck = *blanks
     *
     *      Initialize quantities for picking.
     *
     C                   eval      leftq1 = odqor1
     C                   eval      leftq2 = odqor2
     C                   eval      leftq3 = odqor3
     C                   eval      pickq1 = 0
     C                   eval      pickq2 = 0
     C                   eval      pickq3 = 0
     C                   eval      ttlpk1 = 0
     C                   eval      ttlpk2 = 0
     C                   eval      ttlpk3 = 0
     C                   eval      remain = 0
     *
     *  If Same Slot Breakdown Item
     *   Then quantities need to be changed into corresponding
     *        Base breakdown quantities.
     *
     C                   if        ittype = 'S'  or
     C                             ittype = 'A'  and
     C                             #bityp = 'S'
     C                   eval      leftq3 = leftq2
     C                   eval      leftq2 = leftq1
     C                   eval      leftq1 = 0
     C                   endif
     *
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETOH   Get order header record.
     *
     C     getoh         begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'GETOH   '    trsubr
     C                   exsr      zztrck
     *
     *   If first time, set record pointer.
     *
     C                   if        ohflag = *off
     C     keyoh2        setll     ordh2
     C                   eval      ohflag = *on
     C                   endif
     *
     *   Try to get a 'open' header record.
     *
     C     keyoh2        reade     ordh2                                  79
     *
     *   Set flag if there are no more header records.
     *
     C                   if        *in79
     C                   eval      eofoh = *on
     C                   endif
     *
     C                   movel     ohcnam        p1cnam
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
     C                   parm      'OR610PPR'    $lrpt            10
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
     C                   close     or610ppr
     C                   endif
     *
     *      Override printer file.
     *
     *          OVRPRTF FILE(OR610PPR) OUTQ(*DEV) DEV($dev)
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
     C                   open      or610ppr
     C                   eval      opened = *on
     C                   eval      lstdev = $dev
     C                   eval      lstfrm = $form
     *
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PICKF2  Pick fixed item from multiple pick slots
     *
     *  Note:
     *
     *    This routine replaced the PICKF routine.
     *
     *    A fixed item can have more than one pick (home) slot.
     *    First, an attempt is made to pick the item as a bulk
     *    pick. If there is still quantity to be picked, a check
     *    is done to see if the item has any non-expired pick
     *    slots.  If it does not, then the rest of the quanitity
     *    is pick from overflow slots as bulk picks.
     *
     *    If a pick slot(s) exists, the quantity needed is allocated
     *    similarly to PIR allocation - Only the quantity available
     *    in the pick slot can be allocated. If quantity still
     *    remains after the allocation, the remaining quantity is
     *    allocated from the last slot read. Because a general
     *    allocation has already been done, we know that there
     *    should be enough quantity in the warehouse to fill the
     *    quantity that is needed. Letdowns will be determined
     *    when the labels are printed.
     *
     C     pickf2        begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'PICKF2  '    trsubr
     C                   exsr      zztrck
     *
     *  Step 1 -  Get pick slot record sent in with order detail.
     *
     C                   eval      pckcnt = 0
DRYaA*
DRYaAC                   if        client = Dairyland
DRYaAC                             and clientloc = DRYSanFran
DRYaAC     kysl12a       setll     slot12
DRYaAC                   else
DRYaA*
     C     kysl2a        setll     slot2
DRYaAC                   endif
     *
     *
     C                   dow       forevr = forevr
DRYaA*
DRYaAC                   if        client = Dairyland
DRYaAC                             and clientloc = DRYSanFran
DRYaAC     kysl12a       reade     slot12                                 77
DRYaAC                   else
DRYaA*
     C     kysl2a        reade     slot2                                  77
DRYaAC                   endif
DRYaA*
     C                   if        *in77
     *
     *    If picking slot does not exist . . .
     *      Create OUT Label record.
     C                   exsr      pickrp
     C                   leave
     *
     C                   endif
     *
     *    Increment pick slot counter and save slot.
     C                   add       1             pckcnt
     *
     *  Step 2 -  Check for bulk pick for normal quantity.
     *
     *     Customer wants item picked as Bulk Pick.
     C                   if        osbulk = 'Y'
     *
     C                   exsr      getopt
520cAC                   if        $zpzon = *blanks
     C                   eval      blkpct = #dbpck
     C                   eval      hmwhse = slwhse
     C                   eval      hmwhdp = slwhdp
     C                   eval      hmstyp = slstyp
     C                   eval      hmaisl = slaisl
     C                   eval      hmloc = slloc
     C                   eval      hmrlvl = slrlvl
     C                   eval      hmhand = slhand
     C                   eval      hmdisp = sldisp
     *
     C                   exsr      bulkpk
     *
     *     No need to look further, if no quantity left to pick.
     *
     C                   if        leftq1 = 0
     C                             and leftq2 = 0
     C                             and leftq3 = 0
     C                   leave
     C                   endif
520cAC                   endif
     *
     C                   endif
     *
     *  Step 3 -  Allocate remainder of product.
     *
     *      Pick everything from pick slots.
     *
     C                   exsr      pickmp
     *
     C                   leave
     C                   enddo
     *
     C     pckf2e        endsr
     *----------------------------------------------------------------
     *
     *  PICKMP  Pick fixed item from pick slot(s).
     *
     *  Note:  Within this routine, we pick what was ordered for
     *         for each item from the pick slot sent with the item.
     *         No slot allocation is performed.
     *
     C     pickmp        begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'PICKMP  '    trsubr
     C                   exsr      zztrck
     *
     *
     C                   eval      pickq1 = leftq1
     C                   eval      pickq2 = leftq2
     C                   eval      pickq3 = leftq3
     *
     *     If something was picked, create picking label(s).
     *
     C                   if        pickq1 <> 0  or
     C                             pickq2 <> 0  or
     C                             pickq3 <> 0
     C                   eval      lwltyp = 'O'
     C                   eval      lwlqav = 0
     C                   eval      lwlas2 = *blanks
     C                   exsr      post
     C                   eval      leftq1 = leftq1 - pickq1
     C                   eval      leftq2 = leftq2 - pickq2
     C                   eval      leftq3 = leftq3 - pickq3
     C                   add       pickq1        ttlpk1
     C                   add       pickq2        ttlpk2
     C                   add       pickq3        ttlpk3
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PICKP   Pick PIR item.
     *
     *  Note:  There is no allocation in this version. Quantity
     *         ordered is quantity picked from the slot sent along
     *         with the order detail line.
     *
     C     pickp         begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'PICKP   '    trsubr
     C                   exsr      zztrck
     *
     *  Step 1 -  Get pick slot record sent in with order detail.
     *
DRYaA*
DRYaAC                   if        client = Dairyland
DRYaAC                             and clientloc = DRYSanFran
DRYaAC     kysl12a       setll     slot12
DRYaAC                   else
DRYaA*
     C     kysl2a        setll     slot2
DRYaAC                   endif
     *
DRYaAC                   if        client = Dairyland
DRYaAC                             and clientloc = DRYSanFran
DRYaAC     kysl12a       reade     slot12                                 77
DRYaAC                   else
DRYaA*
     C     kysl2a        reade     slot2                                  77
DRYaAC                   endif
DRYaA*
     C                   if        not *in77
     *
     *     Calculate quantity available in slot.
     *
     C                   exsr      avail
     *
     C                   eval      tmavl1 = avail1
     C                   eval      tmavl2 = avail2
     C                   eval      tmavl3 = avail3
     *
     *     Ignore slot if nothing can be picked.
     *
     C                   exsr      pick0
     *
     *     If something was picked create picking label(s).
     *
     C                   if        pickq1 <> 0  or
     C                             pickq2 <> 0  or
     C                             pickq3 <> 0
     C                   eval      lwltyp = 'O'
     C                   eval      lwlqav = 0
     C                   eval      lwlas2 = *blanks
     C                   exsr      post
     C                   eval      leftq1 = leftq1 - pickq1
     C                   eval      leftq2 = leftq2 - pickq2
     C                   eval      leftq3 = leftq3 - pickq3
     C                   add       pickq1        ttlpk1
     C                   add       pickq2        ttlpk2
     C                   add       pickq3        ttlpk3
     C                   endif
     *
     C                   endif
     *
     *     No need to look further, if no quantity left to pick.
     *
     C                   if        leftq1 = 0  and
     C                             leftq2 = 0  and
     C                             leftq3 = 0
     C                   goto      pickpe
     C                   endif
     *
     *   If everything wasn't picked then print an error.
     *
     C                   if        leftq1 <> 0  or
     C                             leftq2 <> 0  or
     C                             leftq3 <> 0
     *
     *      Convert picked quantity to string for error msg.
     *
     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg
     C                   if        ittype = 'S'
     C                   eval      $cqty1 = pickq2
     C                   eval      $cqty2 = pickq3
     C                   eval      $cqty3 = 0
     C                   else
     C                   eval      $cqty1 = pickq1
     C                   eval      $cqty2 = pickq2
     C                   eval      $cqty3 = pickq3
     C                   endif
     C                   call      'CVTQTY'
     C                   parm                    $ccmd
     C                   parm                    $cprg
     C                   parm                    $cqty1
     C                   parm                    $cqty2
     C                   parm                    $cqty3
     C                   parm                    $cum1
     C                   parm                    $cum2
     C                   parm                    $cum3
     C                   parm                    $cqstr
     C                   parm                    $custr
     C                   parm                    $crtn
     C                   parm                    $cerm
     C                   eval      p1qpck = $cqstr
     *
     *      Print error message.
     *
     C                   eval      p1msg = msg(4)
     C                   exsr      prterr
     C                   eval      trnbr = 'TR04'
     C                   eval      trcode = '*PCK050 '
     C                   movel     'PICKP   '    trsr50
     C                   exsr      zztrck
     C                   endif
     *
     *      Create picking exception label(s).
     C                   if        opelbl = 'Y'  and
     C                             ophpwc = 'N'  or
     *
     C                             opelbl = 'Y'  and
     C                             ophpwc = 'Y'  and
     C                             $potyp <> 'W'
     C                   add       leftq1        excpq1
     C                   add       leftq2        excpq2
     C                   add       leftq3        excpq3
     C                   if        excpq1 > 0  or
     C                             excpq2 > 0  or
     C                             excpq3 > 0
     C                   exsr      clrsl
CWD A*
CWD AC                   if        client = CashWa
DRY AC                             or client = Dairyland
FSHaAC                             or client = FischerFoods
NCH AC                             or client = Nicholas
DFF AC                             or client = Dilgard
CWD A*    Load slot sent with order when no slot found.
CWD AC                   if        osdisp > ' '
CWD AC                   eval      sldisp = osdisp
CWD AC                   endif
CWD A*
CWD AC                   endif
CWD A*
     C                   eval      slwhse = itwhse
     C                   eval      slwhdp = itwhdp
     C                   eval      slstyp = itstyp
     C                   eval      pickq1 = excpq1
     C                   eval      pickq2 = excpq2
     C                   eval      pickq3 = excpq3
     C                   eval      lwltyp = 'O'
     C                   eval      lwlqav = 0
     C                   eval      lwlas2 = 'OUT'
     C                   exsr      post
     C                   endif
     C                   endif
     *
     C     pickpe        endsr
     *----------------------------------------------------------------
     *
     *  PICKRP  Pick item without a pick slot.
     *
     *  Note:  We will only come to this routine when the pick slot
     *         sent with the order detail wasn't found in the SLOT2
     *         file. In this case, we'll create an OUT label record
     *         so that the item can be picked, but no slot info will
     *         be available.
     *
     C     pickrp        begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'PICKRP  '    trsubr
     C                   exsr      zztrck
     *
     *   If everything wasn't picked then print an error.
     *
     C                   if        leftq1 <> 0  or
     C                             leftq2 <> 0  or
     C                             leftq3 <> 0
     *
     *      Convert picked quantity to string for error msg.
     *
     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg
     C                   if        ittype = 'S'
     C                   eval      $cqty1 = pickq2
     C                   eval      $cqty2 = pickq3
     C                   eval      $cqty3 = 0
     C                   else
     C                   eval      $cqty1 = pickq1
     C                   eval      $cqty2 = pickq2
     C                   eval      $cqty3 = pickq3
     C                   endif
     C                   call      'CVTQTY'
     C                   parm                    $ccmd
     C                   parm                    $cprg
     C                   parm                    $cqty1
     C                   parm                    $cqty2
     C                   parm                    $cqty3
     C                   parm                    $cum1
     C                   parm                    $cum2
     C                   parm                    $cum3
     C                   parm                    $cqstr
     C                   parm                    $custr
     C                   parm                    $crtn
     C                   parm                    $cerm
     C                   eval      p1qpck = $cqstr
     *
     *      Print error message.
     *
     C                   eval      p1msg = msg(4)
     C                   exsr      prterr
     C                   eval      trnbr = 'TR04'
     C                   eval      trcode = '*PCK050 '
     C                   movel     'PICKRP  '    trsr50
     C                   exsr      zztrck
     C                   endif
     *
     *      Create picking exception label(s).
     C                   if        opelbl = 'Y'  and
     C                             ophpwc = 'N'  or
     *
     C                             opelbl = 'Y'  and
     C                             ophpwc = 'Y'  and
     C                             $potyp <> 'W'
     C                   add       leftq1        excpq1
     C                   add       leftq2        excpq2
     C                   add       leftq3        excpq3
     C                   if        excpq1 > 0  or
     C                             excpq2 > 0  or
     C                             excpq3 > 0
     C                   exsr      clrsl
CWD A*
CWD AC                   if        client = CashWa
DRY AC                             or client = Dairyland
FSHaAC                             or client = FischerFoods
NCHaAC                             or client = Nicholas
DFF AC                             or client = Dilgard
CWD A*    Load slot sent with order when no slot found.
CWD AC                   if        osdisp > ' '
CWD AC                   eval      sldisp = osdisp
CWD AC                   endif
CWD A*
CWD AC                   endif
CWD A*
     C                   eval      slwhse = itwhse
     C                   eval      slwhdp = itwhdp
     C                   eval      slstyp = itstyp
     C                   eval      pickq1 = excpq1
     C                   eval      pickq2 = excpq2
     C                   eval      pickq3 = excpq3
     C                   eval      lwltyp = 'O'
     C                   eval      lwlqav = 0
     C                   eval      lwlas2 = 'OUT'
     C                   exsr      post
     C                   endif
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PICK0   Pick quantity needed.
     *
     C     pick0         begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'PICK0   '    trsubr
     C                   exsr      zztrck
     *
     *     Initialize pick quantities.
     *
     C                   eval      pickq1 = 0
     C                   eval      pickq2 = 0
     C                   eval      pickq3 = 0
     *
     *     Try to pick normal quantity.
     *
     C                   if        leftq1 > 0
     C                   exsr      pick1
     C                   endif
     *
     *     Try to pick breakdown 1 quantity.
     *
     C                   if        leftq2 > 0
     C                   exsr      pick2
     C                   endif
     *
     *     Try to pick breakdown 2 quantity.
     *
     C                   if        leftq3 > 0
     C                   exsr      pick3
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PICK1  Pick normal quantity.
     *
     C     pick1         begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'PICK1   '    trsubr
     C                   exsr      zztrck
     *
     *   If there is enough normal qty available then grab it.
     *     Otherwise, just grab what is available.
     *
     C                   if        leftq1 <= avail1
     C                   eval      pickq1 = leftq1
     C                   else
     C                   eval      pickq1 = avail1
     C                   endif
     *
     C                   eval      avail1 = avail1 - pickq1
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PICK2  Pick breakdown 1 quantity.
     *
     C     pick2         begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'PICK2   '    trsubr
     C                   exsr      zztrck
     *
     *   If there is enough breakdown 1 qty available then grab it.
     *
     C                   select
     C                   when      leftq2 <= avail2
     C                   eval      pickq2 = leftq2
     *
     *   Otherwise try to break a larger unit to get qty needed.
     *
     *     Note: The qty needed will always be less than the qty
     *           in a normal unit.
     *
     C                   other
     *
     *      Try to break a normal unit and grab what's needed.
     *
     C                   select
     C                   when      avail1 > 0
     C                   eval      avail1 = avail1 - 1
     C                   add       itumq2        avail2
     C                   eval      slstk1 = slstk1 - 1
     C                   add       itumq2        slstk2
     C                   eval      pickq2 = leftq2
     *
     *      Otherwise, just grab what is available for breakdown 1.
     *
     C                   other
     C                   eval      pickq2 = avail2
     *
     C                   endsl
     *
     C                   endsl
     *
     C                   sub       pickq2        avail2
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PICK3  Pick breakdown 2 quantity.
     *
     C     pick3         begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'PICK3   '    trsubr
     C                   exsr      zztrck
     *
     *   If there is enough breakdown 2 qty available then grab it.
     *
     C                   select
     C                   when      leftq3 <= avail3
     C                   eval      pickq3 = leftq3
     *
     *   Otherwise try to break a larger unit to get qty needed.
     *
     *     Note: The qty needed will always be less than the qty
     *           in a breakdown 1 unit.
     *
     C                   other
     *
     *      Try to break a breakdown 1 unit and grab what's needed.
     *
     C                   select
     C                   when      avail2 > 0
     C                   eval      avail2 = avail2 - 1
     C                   add       itumq3        avail3
     C                   eval      slstk2 = slstk2 - 1
     C                   add       itumq3        slstk3
     C                   eval      pickq3 = leftq3
     *
     *      Then try to break a normal unit and grab what's needed.
     *
     C                   when      avail1 > 0
     C                   eval      avail1 = avail1 - 1
     C                   add       itumq2        avail2
     C                   eval      slstk1 = slstk1 - 1
     C                   add       itumq2        slstk2
     C                   eval      avail2 = avail2 - 1
     C                   add       itumq3        avail3
     C                   eval      slstk2 = slstk2 - 1
     C                   add       itumq3        slstk3
     C                   eval      pickq3 = leftq3
     *
     *      Otherwise, just grab what is available for breakdown 2.
     *
     C                   other
     C                   eval      pickq3 = avail3
     *
     C                   endsl
     *
     C                   endsl
     *
     C                   sub       pickq3        avail3
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  POST    Post picking labels.
     *
     C     post          begsr
730eA**
730eA**  Get Slot Sequence with new Option and possible soft coding
730eA**
730aAc                   monitor
730eAc                   call      'GETPSEQO'
730eAc                   parm      '*GETPSEQ'    gpscmd            8
730eAc                   parm                    slwhse
730eAc                   parm                    slwhdp
730eAc                   parm                    sldisp
730eAc                   parm      ' '           gpSeqcd           1
730eAc                   parm      0             gpSeq             5 0
730eAc                   parm      ' '           usrDFPICK         1
730aAc                   on-error
730eAc                   eval      gpSeq = slpseq
730aAc                   endmon
730eA*
730eA**  Override SLPSEQ with what GETPSEQO returns
730eA*
730eAc                   eval      slpseq = gpSeq
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'POST    '    trsubr
     C                   exsr      zztrck
     *
     *   Create picking labels - one for each quantity breakdown.
     *
     *      Initialize label fields.
     *
     C                   clear                   lwrec
     C                   eval      lwwhse = slwhse
SLBaAC                   select
SLBaAC                   when      client = silberman
CWDbAC                             or client = cashwa
CTWaAC                             or client = citywho
KFS AC                             or client = kellys
SLBaAC                   eval      lwtruk = $ptmpl
SLBaAC                   other
     C                   eval      lwtruk = $ptruk
SLBaAC                   endsl
     C                   eval      lwwhdp = slwhdp
     C                   eval      lwaisl = slaisl
     C                   eval      lwloc = slloc
     C                   eval      lwrlvl = slrlvl
     C                   eval      lwhand = slhand
     C                   eval      lwpseq = slpseq
     C                   eval      lwstyp = slstyp
     C                   if        lwstyp = 'P'
     C                   eval      lwqryf = 1
     C                   else
     C                   eval      lwqryf = 0
     C                   endif
     C                   eval      lwdisp = sldisp
     C                   eval      lwasl2 = lwlas2
     C                   eval      lwqavl = lwlqav
     C                   eval      lwrte = ohrte
     C                   eval      lwstop = ohstop
     C                   eval      lword = ohord
     C                   eval      lwseq = odseq
     C                   eval      lwitem = oditem
     C                   eval      lwpbat = $pbat
     C                   eval      lwgrp1 = 'S'
     C                   eval      lwgrp2 = ohtype
     C                   eval      lwtype = lwltyp
     C                   eval      lwstat = 'A'
     C                   eval      lwsdte = today
     C                   time                    lwstim
     C                   eval      lwrdte = today
     C                   eval      lwspcl = odspcl
     C                   eval      lwucub = 0
     C                   eval      lwcube = 0
     C                   eval      lwuwgt = 0
     C                   eval      lwswgt = 0
     *
     *      Create label for normal quantity.
     *
     C                   if        pickq1 > 0
     C                   eval      lwutyp = 'N'
     C                   eval      lwucod = itum1
     C                   eval      lwucub = itcube
     C     lwucub        mult      pickq1        lwcube
     C                   eval      lwuwgt = itswgt
     C     lwuwgt        mult      pickq1        lwswgt
     C                   eval      lwqalc = pickq1
730bDC**                 call      'PIRLBL#'
730bDC**                 parm                    lwlbl#
730bMC                   exsr      GetNextLbl#
730bMC                   eval      lwlbl# = nextLbl#
     C                   write     lwrec
     C                   endif
     *
     *      Create label for breakdown 1 quantity.
     *
     C                   if        pickq2 > 0
     C                   eval      lwutyp = *on
     C                   eval      lwucod = itum2
     C                   if        itumq2 <> 0
     C     itcube        div(h)    itumq2        lwucub
     C     lwucub        mult      pickq2        lwcube
     C     itswgt        div(h)    itumq2        lwuwgt
     C     lwuwgt        mult      pickq2        lwswgt
     C                   endif
     C                   eval      lwqalc = pickq2
730bDC**                 call      'PIRLBL#'
730bDC**                 parm                    lwlbl#
730bMC                   exsr      GetNextLbl#
730bMC                   eval      lwlbl# = nextLbl#
     C                   write     lwrec
     C                   endif
     *
     *      Create label for breakdown 2 quantity.
     *
     C                   if        pickq3 > 0
     C                   eval      lwutyp = '2'
     C                   eval      lwucod = itum3
     C                   if        itumq2 <> 0  and
     C                             itumq3 <> 0
     C     itcube        div(h)    itumq2        lwucub
     C     lwucub        div(h)    itumq3        lwucub
     *R         LWCUBE    DIV  ITUMQ3    LWUCUB    H
     C     lwucub        mult      pickq3        lwcube
     C     itswgt        div(h)    itumq2        lwuwgt
     C     lwuwgt        div(h)    itumq3        lwuwgt
     *R         LWSWGT    DIV  ITUMQ3    LWUWGT    H
     C     lwuwgt        mult      pickq3        lwswgt
     C                   endif
     C                   eval      lwqalc = pickq3
730bDC**                 call      'PIRLBL#'
730bDC**                 parm                    lwlbl#
730bMC                   exsr      GetNextLbl#
730bMC                   eval      lwlbl# = nextLbl#
     C                   write     lwrec
     C                   endif
     *
     C     endpst        tag
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
     C                   endsr
730bA*----------------------------------------------------------------
730bA*  wrtDebug    Write out debug record
730bA*----------------------------------------------------------------
730bA
730bA /free
730bA  begsr wrtDebug;

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
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'ZMSMSG  '    trsubr
     C                   exsr      zztrck
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid            7
     C                   parm                    #msgtp            7
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq            10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *     ZZTRCK - Write tracking records to tracking file
     *
     C     zztrck        begsr
     C                   select
     C                   when      trcode = '*PCK001 '
     C                   eval      trpcmd = $pcmd
     C                   eval      trprg = $pprg
     C                   eval      trpbat = $pbat
     C                   eval      trrord = $pord
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
     C                   if        flgpck = *on
     C                   eval      trdata = trerfl
     C                   else
     C                   eval      trdata = opdata
     C                   endif
     C                   eval      trsqnr = *zeros
     C                   write     tr02rec
     *
     C                   when      trcode = '*PCK003 '
     C                   if        flgpck = *on
     C                   eval      trdata = trerfl
     C                   else
     C                   eval      trrows = throws
     C                   eval      trcols = thcols
     C                   eval      trbulk = thbulk
     C                   eval      trbat = thbat
     C                   eval      trdata = tr03ds
     C                   endif
     C                   eval      trsqnr = *zeros
     C                   write     tr03rec
     *
     C                   when      trcode = '*PCK010 '
     C                   add       1             trsq10
     C                   movel     opzzon        trzone
     C                   eval      trdt10 = opzdta
     C                   eval      trdata = tr10ds
     C                   eval      trsqnr = trsq10
     C                   write     tr10rec
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
     *R                   MOVE *ON       TRERR
     C                   add       1             trsq50
     C                   eval      trord = ohord
     C                   eval      trstop = ohstop
     C                   eval      tritem = oditem
     C                   eval      trmsgt = 'S'
     *
     C                   select
     C                   when      trnbr = 'TR01'
     C                   eval      trerr = *on
     C                   eval      trdt50 = msg(1)
     C     trdt50        cat       tr05:2        trdt50
     C                   eval      $ccmd = '*QTY2STR'
     C                   eval      $cqty1 = odqor1
     C                   eval      $cqty2 = odqor2
     C                   eval      $cqty3 = odqor3
     C                   eval      $cqstr = *blanks
     C                   exsr      zzcvqy
     C     trdt50        cat       $cqstr:1      trdt50
     *
     C                   when      trnbr = 'TR03'
     C                   eval      trerr = *on
     C                   eval      trdt50 = msg(3)
     C     trdt50        cat       tr05:2        trdt50
     C     trdt50        cat       p1qord:0      trdt50
     C     trdt50        cat       tr06:2        trdt50
     C     trdt50        cat       p1qalc:0      trdt50
     C     trdt50        cat       tr07:2        trdt50
     C     trdt50        cat       p1qpck:0      trdt50
     *
     C                   when      trnbr = 'TR04'
     C                   eval      trerr = *on
     C                   eval      trdt50 = msg(4)
     C     trdt50        cat       tr05:2        trdt50
     C     trdt50        cat       p1qord:0      trdt50
     C     trdt50        cat       tr06:2        trdt50
     C     trdt50        cat       p1qalc:0      trdt50
     C     trdt50        cat       tr07:2        trdt50
     C     trdt50        cat       p1qpck:0      trdt50
     *
     C                   when      trnbr = 'TR09'
     C                   eval      trdt50 = %trimr(tr09) + ' ' + sldisp
     C     trdt50        cat       tr08:2        trdt50
     C                   move      slexpd        cvt8a
     C     trdt50        cat       cvt8a:0       trdt50
     *
     C                   when      trnbr = 'TR10'
     C                   eval      trdt50 = %trimr(tr10) + ' ' + sldisp
     *
     C                   when      trnbr = 'TR11'
     C                   eval      trdt50 = %trimr(tr11) + ' ' + sldisp
     *
     C                   when      trnbr = 'TR12'
     C                   eval      trord = *zeros
     C                   eval      trstop = *zeros
     C                   eval      tritem = *blanks
     C                   eval      trdt50 = tr12
     *
     C                   when      trnbr = 'TR13'
     C                   eval      trord = *zeros
     C                   eval      trstop = *zeros
     C                   eval      tritem = *blanks
     C                   eval      trdt50 = tr13
     *
     C                   when      trnbr = 'TR14'
     C                   eval      trdt50 = tr14
     *
     C                   when      trnbr = 'TR15'
     C                   eval      trdt50 = tr15
     C                   move      leftq1        cvt5a
     C     trdt50        cat       cvt5a:0       trdt50
     *
     C                   when      trnbr = 'TR16'
     C                   eval      trdt50 = %trimr(tr16) + sldisp
     C     trdt50        cat       tr23:1        trdt50
     *
     C                   when      trnbr = 'TR17'
     C                   eval      trdt50 = %trimr(tr17) + ' ' + sldisp
     C     trdt50        cat(p)    tr21:2        trdt50
     C                   move      avail1        cvt5a
     C     trdt50        cat       cvt5a:0       trdt50
     *
     C                   when      trnbr = 'TR18'
     C                   eval      trdt50 = %trimr(tr18) + ' ' + sldisp
     C     trdt50        cat(p)    tr22:2        trdt50
     C                   move      pickq1        cvt5a
     C     trdt50        cat       cvt5a:0       trdt50
     *
     C                   when      trnbr = 'TR19'
     C                   eval      trdt50 = tr19
     *
     C                   when      trnbr = 'TR20'
     C                   eval      trdt50 = %trimr(tr20) + trkey
     C                   eval      trmsgt = 'D'
     *
     C                   endsl
     C                   eval      trdata = tr50ds
     C                   eval      trmsgn = trnbr
     C                   eval      trsqnr = trsq50
     C                   write     tr50rec
     *
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *     ZZCVQY - Convert receive qty's to string for msg display
     *
     C     zzcvqy        begsr
     C                   call      'CVTQTY'
     C                   parm                    $ccmd
     C                   parm                    $cprg
     C                   parm                    $cqty1
     C                   parm                    $cqty2
     C                   parm                    $cqty3
     C                   parm                    $cum1
     C                   parm                    $cum2
     C                   parm                    $cum3
     C                   parm                    $cqstr
     C                   parm                    $custr
     C                   parm                    $crtn
     C                   parm                    $cerm
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
Item master record not on file.
First item after restarting batch.
Not enough stock available for order.
Slots did not contain enough stock.
No picking slot defined for item.
**   OVRPRTF statment
OVRPRTF FILE(OR610PPR) OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
