      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     ****   THIS PROGRAM REQUIRES V7M0 OR LATER
     ****   RE: Defines files within subprocedures
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  DD420     DragDrop 2.0 - Drop
     *  5 April 2018
     *  Dave Sommerville
     *
     *
     *  Revisions
     *
720aA*    05/18/18  DAS  7.20a
     *      - Added code to change compartment if a single pallet
     *        exists in the location with a different compartment.
     *
720bA*    05/19/18  DAS  7.20b
     *      - Added REPLAY
     *
720cA*    05/24/18  DAS  7.20c
     *      - Renamed GetDropStop to CrtParentRecs
     *      - Revised to set dddmaxc for pallet to zone max cube.
     *
720dA*    06/01/18  KDE  7.20d
     *      - Added functionality to Rebuild Truck on the fly
     *
720eA*   06/04/18  DAS  7.20e
     *     - Added Weight warning at pallet level.
     *
720fA*   06/07/18  DAS  7.20f
     *     - Added file worklbl11.
     *     - Revised how CombineSplit routine checks for remaining split.
     *
720gA*   06/07/18  DAS  7.20g
     *    - Revised Rebuild logic to send back command to refresh truck.
     *
720hA*   06/12/18  DAS  7.20h
     *     - Revised CrtParentRecs to honor new pallet per order option
     *
720iA*   06/25/18  DAS  7.20i
     *     - Revised ClearDDTREC to get new stamp
     *
720jA*   10/02/18  DAS  7.20j
     *     - Added GLORTELOG logging
     *     - Added command GUITIMES.
     *
730 A*   10/15/19  KDE  7.30
     *     - Do not set lr to keep open for future calls
     *
730aA*   10/27/19  DAS  7.30a
     *     - Revised to initialize locCount and locList.
     *
740 A*   02/24/20  KDE  7.40
     *     - Revised to prevent DDE for Max Zone Weight
     *
740aA*   04/07/20  KDE  7.40a
     *     - Revised to search for other open overflow unload sequences
     *       when 99 is reached to prevent value to small error
     *
740bA*   06/27/20  DAS  7.40b
     *     - Revised to prevent multiple jobs from working on the
     *       same route simultaneously.
     *
740cA*   06/27/20  DAS  7.40c
     *     - Revised drop error message to start with 'Error dropping
     *       on Location Row x Column y - '
     *
740dA*   06/27/20  DAS  7.40d
     *    - Fixed IF statement in GetDropInfo when creating error
     *      message for a record not found.
     *
740eA*   07/22/20  KDE  7.40e
     *     - Add ability to override to history files for dddetail and
     *       ddtask.  Once routes get to pick and print they are moved
     *       to history files
     *     - Had to make exceptions for mainline IO, SQL IO, and
     *       subprocedure IO.  Program uses labels dddfile and ddtfile
     *       to control whether using live or history
     *
740fA*   08/26/20  DAS  7.40f
     *     - Revised to ignore Max Stops on a pallet. This was done by
     *       revising GetMaxPltStops to always return zero.
     *
740gA*   12/29/20  DAS  7.40g
     *     - Revised PLTSTP SQL statement in the hope that IBM will
     *       chose LF PLTSTP1 instead of recommending a different index.
     *
750 A*   03/23/21  KDE  7.50
     *     - Integrate new options for merging unlike zones on same pallet
     *     - Add icons for spinning pallets and merging unlike zones
     *     - New SQL file DDWRKFLDS was introduced to keep track of
     *       location spins and merging of unlike zones
     *
750aA*   05/10/21  KDE  7.50a
     *     - Revised SQL to get Stop range to only consider generation 1
     *
750bA*   05/13/21  KDE  7.50b
     *     - Fix:  SQL where clause error with 750a mod
     *
750cA*   07/29/21  DAS  7.50c
     *     - Fix:  When creating a new overflow pallet, revised
     *       routine GetDropInfo to populate PLTSUM fields PSPAL#
     *       and PSFLAG.
     *
750dA*   10/26/21  KDE  7.50d
     *     - Fix:  When dragging stop and two different zones under
     *       stop it was not flagging as unlike merge zones
     *
750eA*   11/11/21  KDE  7.50e
     *     - Fix:  Not always undoing unlike zones properly
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     * Replay is used for replaying the drops a user took. REPLAY
     * creates a REPLAY task, which consist of the tasks for creating
     * the original truck, which comes from DDDETAIL DDDSNAP=1.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

740eDF*ddtask    uf a e           k disk
740eDF*ddtask1   if   e           k disk    rename(ddtrec: ddtrec2)
740eMFddtask    uf a e           k disk    usropn extfile(ddtfile)
740eMFddtask1   if   e           k disk    rename(ddtrec: ddtrec2) usropn
740eAf                                     extfile(ddtfile)
740eDF*dddetail  uf   e           k disk
740eDF*dddetail1 uf a e           k disk    rename(dddrec: dddrec1)
740eDF*dddetail3 if   e           k disk    rename(dddrec: dddrec3)
740eDF*dddetail4 uf   e           k disk    rename(dddrec: dddrec4)
740eMFdddetail  uf   e           k disk    usropn extfile (dddfile)
740eMFdddetail1 uf a e           k disk    rename(dddrec: dddrec1) usropn
740eAf                                     extfile(dddfile)
740eMFdddetail3 if   e           k disk    rename(dddrec: dddrec3) usropn
740eAf                                     extfile(dddfile)
740eMFdddetail4 uf   e           k disk    rename(dddrec: dddrec4) usropn
740eAf                                     extfile(dddfile)
     Fworklbl   uf a e           k disk
     Fworklblg  uf   e           k disk    rename(lwrec: lwrecg) prefix(lwg_)
720fAFworklbl11 if   e           k disk    rename(lwrec: lwrec11) prefix(lw11_)
     Fpltstp1   uf a e           k disk
     Fpltsum2   uf a e           k disk
     Fworklbl6  if   e           k disk    rename(lwrec: lwrec6)
     Foptionz   if   e           k disk
740bAFddlock    uf a e           k disk
750 Afddopts    if   e           k disk

     *----------------------------------------------------------------
     *  File Record Data Structures
     *----------------------------------------------------------------

     d dragId          ds                  likerec(dddrec: *input)
     d dropSent        ds                  likerec(dddrec: *input)
     d dropLoc         ds                  likerec(dddrec: *input)
     d dropPlt         ds                  likerec(dddrec: *input)
     d dropStp         ds                  likerec(dddrec: *input)

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

ADCaA /copy qcopysrc,id#adc

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  DD2 Level Constants (if used in SQL stmt, must be defined as variable)
     *----------------------------------------------------------------

     D GROUPLVL        c                   0
     D LOCATIONLVL     s              1  0 inz(1)
     D PALLETLVL       c                   2
     D PLTSECTLVL      c                   3
     D STOPLVL         s              1  0 inz(4)
     D ITEMLVL         c                   5
     D TOTEITEMLVL     c                   6

     *----------------------------------------------------------------
     *  Working variables
     *----------------------------------------------------------------
740eAD cmd             s           3000    varying
740eAd ddtfile         s             10
740eAd dddfile         s             10
740aAd inRtnCode       s             10
740aAd inRtnMsg        s             60
750eAd RCTzon          s                   like(dddtzon)

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D bfcoffset       s              3  0 inz(0)
     D ucOffset        s              3  0

     *----------------------------------------------------------------
     *  Global Variables
     *----------------------------------------------------------------
740eAd dddLive         s               n
740eAd ddtLive         s               n
     d errmsg          s            500    varying
740cAd dropStr         s            100    varying
     D gTaskGrp        s                   like(ddttaskgrp)
     d gRtnStr         s          65535    varying
     d gDropFound      s               n
     d dragCount       s              5  0
     d droppedOnLoc    s               n
     d droppedOnPlt    s               n
     d locCount        s              5  0
740aAd lastUnldSeq     s              2  0
     d passThruMsg     s               n
     D client          s             10
     D clientloc       s             10
     D gSplitPcs       s                   like(dddpcs)
     D gSplitCube      s                   like(dddcube)
     D gSplitWgt       s                   like(dddwgt)
     D newOvfDrop      s               n
     D gSavedComp      s                   like(dddcomp)
     D gSavedTZon      s                   like(dddtzon)
     D gSavedPZon      s                   like(dddpzon)
     D gSavedSZon      s                   like(dddszon)
750 AD gSavedid        s                   like(dddid)
720dAD gReturn         s              8
720dAD gErrMsg         s             80
720dAD gRtid           s              5
720hAD gCurOPTIONZ     s                   like(dddtzon)
750 Ad saveMergeOpt    s              1
750 Ad zoneMergeOpt    s              1
750 Ad zoneDiffer      s               n
750 Ad wrkspin         s             10
750 AD wrkmrg          s             10
750 AD wrkrtid         s              5
750 Ad wrkrow          s              3  0
750 Ad wrkcol          s              2  0
750 Ad wrkcomp         s                   like(dddcomp)
750 Ad wrktzon         s                   like(dddtzon)
750 Ad wrkpzon         s                   like(dddpzon)
750 Ad wrkszon         s                   like(dddszon)
750 Ad alwSameLocDrp   s               n
750 Ad dragDroppltsm   s               n
     d cntFlgs         s              3  0

     *----------------------------------------------------------------
     *  Drag List
     *----------------------------------------------------------------
     D dragList        DS                  occurs(100) qualified
     D  level                              like(dddlevel)
     D  id                                 like(dddid)

     *----------------------------------------------------------------
     *  Location list
     *----------------------------------------------------------------
     D locList         DS                  occurs(100) qualified
     D  group                              like(dddgroup)
     D  row                                like(dddrow)
     D  col                                like(dddcol)
     D  id                                 like(dddid)

     *----------------------------------------------------------------
     *  JSON Global Variables
     *----------------------------------------------------------------

     D jsonDepth       s              3  0
     d jsonLine        s           3072    varying

     D jsonStack       ds                  occurs(20) Qualified
     D   firstEntry                    n
     *----------------------------------------------------------------
     *  Pallet id data structure
     *
     *    DSPLID  -  Pallet id.
     *    DSPLXX  -  Unused.
     *    DSPLGN  -  Generation.
     *    DSPLRW  -  Pallet row.
     *    DSPLCL  -  Pallet column.
     *    DSPLSQ  -  Sequence number.
     *               Equal to zero     - Only one pallet in this position.
     *               Greater than zero - Multiple pallets in this position.
     *
     *
     D pltid           ds
     D  dsplid                 1      7  0 inz(0)
     D  dsplxx                 1      2  0
     D  dsplgn                 3      3  0
     D  dsplrw                 4      5  0
     D  dsplcl                 6      6  0
     D  dsplsq                 7      7  0

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
400 A*    OPPBLD  -  Pallet building method.
400 A*                1 = By stop then slot location.
400 A*                2 = By slot location then stop.
417bA*                3 = Descending by stop then location.
400 A*    OPSELM  -  Selection method.
400 A*                1 = Single pass (By location).
400 A*                2 = Multiple pass (By stop).
400 A*    OPSPLT  -  Allow stop to be split across pallets (Y/N).
400 A*    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
417dA*    OPNWPL  -  Start new pallet when aisle changes if build method
417dA*               is 2=Location.
500iM*    OPFORD  -  Maximum orders per pallet.
500eM*    OPPTYP  -  Pallet type (P=Pallet, T-Tote).
500cA*    OPFTOT  -  Maximum totes per pallet
500dA*    OPTECB  -  External tote cube.
500dA*    OPTICB  -  Internal tote cube.
500dA*    OPTSTP  -  Maximum stops per tote.
500dA*    OPTORD  -  Maximum orders per tote.
500eA*    OPFPCS  -  Maximum pieces per fixed pallet.
650bM*    OPSTOP  -  Honor *DP/*SP flag (Y=Yes, N=No).
520eA*    OPGCDE  -  USF Group Code (0-9).
520eA*    OPPKUP  -  Picked up by (S=Selector, L=Loader).
520eA*    OPSPAL  -  Merge pallet should only contain
520eA*               items for single truck pallet (Y=Yes, N=No).
520eA*    OPPITM  -  Maximum items per pallet.
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
400 AD  oppbld                34     34
400 AD  opselm                35     35
400 AD  opsplt                36     36
400 AD  opbmrg                37     37
417dAD  opnwpl                38     38
500dAD  opford                39     40  0
500cMD  opptyp                41     41
500dAD  opftot                42     43  0
500dAD  optecb                44     48  2
500dAD  opticb                49     53  2
500dAD  optstp                54     55  0
500dAD  optord                56     57  0
500dAD  optpcs                58     60  0
510nAD  opstop                61     61
520 A** Note: Pos 62 is OPGCDE for USF, but OPPKUP for all other clients.
700aD ** OPGCDE moved to pos 76 as of 700
700aDD**opgcde                62     62
520eAD  oppkup                62     62
520eAD  opspal                63     63
520eAD  oppitm                64     67  0 inz(0)
650aAD  oplbl                 68     68
700aAD  opdddo                69     69
700aAD  opmcub                70     74  2 inz(0)
700aAD  wkmcub                70     74
700aAD  oppmtz                75     75
700aAD  opgcde                76     76
710aAD  opnbps                77     77  0 inz(0)
720aAD  opfwgt                78     81  0 inz(0)
720eAD  opfwgtalpha           78     81
720aAD  opfplt                82     87
720aAD  opbseq                88     89  0 inz(0)
     D  opdend               117    117

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

750 Ad addMrgFlgs      pr
750 Ad  indddrec                                 likerec(dddrec: *input)

     d CombineSplit    pr

     d ClearDDTREC     pr

     d ClearRouteLock  pr

720cMd CrtParentRecs   pr
720cAd  truckTemplate                      const like(lwtruk)
     d  indddrec                           const likerec(dddrec: *input)

750 Ad ddPltSame       pr              n

     d DoDrop          pr

720jAd DoGUITimes      pr

     d DoLevel         pr

     d DoSwap          pr

720dAd DoReBuild       pr

     d DoRefresh       pr

720bAd DoReplay        pr

     d GetPSBCNT       pr             1  0
     d  row                                like(psrow)
     d  col                                like(pscol)

     d GetDropInfo     pr

     d GetDragList     pr

     d GetMaxPltStops  pr             2s 0
720cAd  truckTemplate                      const like(lwtruk)
     d  zone                               const like(dddtzon)

     d GetStopRange    pr
     d  level                              const like(dddlevel)
     d  row                                const like(dddrow)
     d  col                                const like(dddcol)
     d  plid                               const like(dddplid)
     d  stp1                               like(psstp1)
     d  stp2                               like(psstp2)

     d GetStopsOnPlt   pr             2s 0
     d  group                              const like(dddgroup)
     d  row                                const like(dddrow)
     d  col                                const like(dddcol)
     d  plid                               const like(dddplid)

     d GetTaskGrp      pr

720cAd GetZoneMaxCube  pr             5s 2
720cAd  truckTemplate                      const like(lwtruk)
720cAd  zone                               const like(dddtzon)

720eAd GetZoneMaxWgt   pr             4s 0
720eAd  truckTemplate                      const like(lwtruk)
720eAd  zone                               const like(dddtzon)

720hAd GetOPTIONZ      pr
720hAd  truckTemplate                      const like(lwtruk)
720hAd  zone                               const like(dddtzon)

720hAd GetZoneOrdOpt   pr             1
720hAd  truckTemplate                      const like(lwtruk)
720hAd  zone                               const like(dddtzon)

     d ProcessDragIds  pr

     d ProcessDrag1    pr
     d  dragLevel                          like(dddlevel)
     d  indddrec                           const likerec(dddrec: *input)

     d ProcessDrag2    pr
     d  dragLevel                          like(dddlevel)
     d  indddrec                           const likerec(dddrec: *input)
     d  rtnPcs                             like(dddpcs)
     d  rtnCube                            like(dddcube)
     d  rtnWgt                             like(dddwgt)
     d  palletDeleted                  n

     d ProcessDrag4    pr
     d  dragLevel                          like(dddlevel)
     d  indddrec                           const likerec(dddrec: *input)
     d  rtnPcs                             like(dddpcs)
     d  rtnCube                            like(dddcube)
     d  rtnWgt                             like(dddwgt)

     d ProcessDrag5    pr
     d  dragLevel                          like(dddlevel)
     d  indddrec                           const likerec(dddrec: *input)
     d  rtnPcs                             like(dddpcs)
     d  rtnCube                            like(dddcube)
     d  rtnWgt                             like(dddwgt)

     d rmvPwrkFlds     pr
     d  iid                                like(dddid)

     d SetRouteLock    pr

710bAd UpdateLocComp   pr

     d WriteError      pr

     d WriteRequest    pr

     d WriteDropTasks  pr

750 Ad SpinUnspin      pr

     d GetCurrStamp    pr

720dAd rebuildrte      pr                  extpgm('REBUILDRTE')
720dAd  iwhse                         3  0
720dAd  irtid                         5
720dAd  ireturn                       8
720dAd  iMsg                         80

720jAd WriteRteLog     pr
720jAd ddSubGrp                      12    const
720jAd ddType                         1    const

720jAd WriteRteLog6    pr
720jAd ddSubGrp                      12    const
720jAd ddMin                          7  2

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
     d/copy qcopysrc,p.cvttext
     d/copy qcopysrc,p.dricop
     d/copy qcopysrc,p.bfcdteti
     d/copy qcopysrc,p.dd410
     d/copy qcopysrc,p.dd430
     d/copy qcopysrc,p.pirlbl#
     d/copy qcopysrc,p.or627
720jAd/copy qcopysrc,p.wrtrtelg
740aAd/copy qcopysrc,p.dd2dtamo
740aAD/copy qcopysrc,p.qcmdexc
750 Ad/copy qcopysrc,p.ddwrkflds

     *----------------------------------------------------------------
     *  Parameters
     *
     *  Input
     *    pCmd     - DROP, SPLIT, SWAP, LEVEL, REFRESH
     *    pWhse    - Warehouse
     *    pRtid    - Route id
     *    pDropId  - Drop Id
     *    pDragIds - Id's being dragged and dropped
     *    pSessId  - GUI Session Id
     *    pUser    - GUI User
     *    pDict    - GUI Dictionary
     *    pPgm     - GUI Program
     *
     *  Output
     *    pJSON    - JSON return string  (MRC limits fields to 2000 char)
     *               {"tasks":...} string will be returned if no more
     *                  than 2000 characters.
     *               {"taskgrp":"number"} returned if larger than
     *                 2000 characters. Pgm will get task from file.
     *               {"error":"msg"} returned if error occured.
     *----------------------------------------------------------------

     D DD420           pr                  extpgm('DD420')
     D  pCmd                         10    varying
     D  pWhse                         3p 0
     D  pRtid                         5    varying
     D  pDropId                      20    varying
     D  pDragIds                   2000    varying
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pJSON                      2000    varying

     D DD420           pi
     D  pCmd                         10    varying
     D  pWhse                         3p 0
     D  pRtid                         5    varying
     D  pDropId                      20    varying
     D  pDragIds                   2000    varying
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pJSON                      2000    varying

     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------

      /free
730 D  // *inlr = *on;
       error = *off;
       passThruMsg = *off;

       // Get timestamp to apply to records

       GetCurrStamp();

740eA  // Open DD files pointed to Live or History
740eA  exsr opnDDfiles;

       // Get Task group to use for route

       GetTaskGrp();

750 A  // Generate Task list to update Spin Icon/Image if clicked
750 A  if pCmd='SPIN' or pCmd='UNSPIN';
750 A     SpinUnSpin();
750 A     pJSON = gRtnStr;
750 A     return;
750 A  endif;

720jA  // Start logging for some commands
720jA
720jA    if pCmd = 'SPLIT'
720jA       or pCmd = 'SWAP'
720jA       or pCmd = 'DROP'
720jA       or pCmd = 'LEVEL'
720jA       or pCmd = 'REFRESH'
720jA       or pCmd = 'REBUILD';
720jA
720jA         WriteRteLog ('': '1');       // Start Task Group
720jA         WriteRteLog ('DD420': '1');  // Start this program
720jA
720jA    endif;

       // Write drop request to DDTASK

       WriteRequest();

       // Get Drop info

720dD  //if pCmd <> 'REFRESH' and pCmd <> 'REPLAY';
720dM  if pCmd <> 'REFRESH' and pCmd <> 'REPLAY' and pCmd <> 'REBUILD'
720jA    and pCmd <> 'GUITIMES';

740bA      // Set lock for route so 2 programs can't
740bA      // work on it simultaneously.
740bA
740bA      SetRouteLock();
740bA      if error;
740bA        WriteError();
740bA        pJSON = '{"error":"' + errmsg
740bA              + ' (' + %trimr(#pgm) + '/' +%trimr(#job) + '/'
740bA              + %trimr(#jobn) + '/' + %trimr(#curruser) + ')"}';
740bA        return;
740bA      endif;

           GetDropInfo();
           if error;
             WriteError();
             pJSON = '{"error":"' + errmsg
                   + ' (' + %trimr(#pgm) + '/' +%trimr(#job) + '/'
                   + %trimr(#jobn) + '/' + %trimr(#curruser) + ')"}';
740bA        ClearRouteLock();
             return;
           endif;

       endif;

       // Execute command

       select;

         when pCmd = 'SPLIT';
           DoDrop();

         when pCmd = 'SWAP';
           DoSwap();

         when pCmd = 'DROP';
           DoDrop();

750 A    when pCmd = 'DROPU';
750 A      // Undo Merge of unlike Zones
750 A      // Force new option to not allow merging of unlike zones
750 A      // to force apart when clicking icon to undo previous merge
750 A      zoneMergeOpt = 'N';
750 A      DoDrop();
750 A      zoneMergeOpt = saveMergeOpt;

         when pCmd = 'LEVEL';
           DoLevel();

         when pCmd = 'REFRESH';
           DoRefresh();

720dA    when pCmd = 'REBUILD';
720dA      DoRebuild();

720bA    when pCmd = 'REPLAY';
720bA      DoReplay();

720jA    when pCmd = 'GUITIMES';
720jA      DoGUITimes();

       endsl;

       if error;
         WriteError();
        if not passThruMsg;
           pJSON = '{"error":"' + errmsg
                 + ' (' + %trimr(#pgm) + '/' +%trimr(#job) + '/'
                 + %trimr(#jobn) + '/' + %trimr(#curruser) + ')"}';
         endif;

740bA    ClearRouteLock();
         return;
       endif;

720jA  // End logging for some commands
720jA
720jA    if pCmd = 'SPLIT'
720jA       or pCmd = 'SWAP'
720jA       or pCmd = 'DROP'
720jA       or pCmd = 'LEVEL'
720jA       or pCmd = 'REFRESH'
720jA       or pCmd = 'REBUILD';
720jA
720jA         WriteRteLog ('DD420': '2');  // End this program
720jA
720jA    endif;

740bA    // Clear route lock

750 A  if pCmd <> 'REFRESH' and pCmd <> 'REPLAY' and pCmd <> 'REBUILD'
750 A    and pCmd <> 'GUITIMES';
740bA    ClearRouteLock();
750 A  endif;

730 A    return;

      /end-free

     *----------------------------------------------------------------
     *  *Inzsr  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         getclient(client: clientLoc);
740eA    dddLive=*off;
740eA    ddtLive=*off;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

      /free
       begsr *pssr;

         // Make sure we don't get caught in an infinite loop

         if pssrflag;
730 D      // *inlr = *on;
           return;
         endif;

         pssrflag = *on;

         //  Send message back to calling program

         dump(a);

         pJSON = '{"error":" Unexpected error occured - '
               + 'PSSR: ' + %trim(#pgm) + ' (stmt ' + %char(#stmt) + ') '
               + #status + ' - ' + %trim(#pgmmsg)
               + ' (' + %trimr(#pgm) + '/' +%trimr(#job) + '/'
               + %trimr(#jobn) + '/' + %trimr(#curruser) + ')"}';

730 D    // *inlr = *on;
         return;

       endsr;
      /end-free

740eA *----------------------------------------------------------
740eA *  opnDDfiles - Open DD files pointed to live or history
740eA *----------------------------------------------------------
740eA
740eA /free
740eA
740eA  begsr opnDDfiles;
740eA
750 A    // Retrieve option for unlike zone merging
750 A    // N - unlike Zone merging not allowed
750 A    // S - Keep separate by default - This option will place
750 A    //     unlike zones on the same position but in separate
750 A    //     pallet id and the user will have to manually merge
750 A    // M - Merge by Default - This option will automatically
750 A    //     merge unlike zones in the first pallet if dropped
750 A    //     on the location, and the specific pallet if dropped
750 A    //     on a specific pallet
750 A    chain ('BFC_MERGE_ZONES_SINGLE_PALLET') ddopts;
750 A    if not %found(ddopts);
750 A      zoneMergeOpt = 'N';
750 A    else;
750 A      zoneMergeOpt = %trim(doValue);
750 A    endif;
750 A    saveMergeOpt = zoneMergeOpt;

740eA    // check for DDDETAIL data location
740eA    dd2dtamove('*DTALOCDDD': inRtnCode: inRtnMsg: pWhse: pRtid);
         // first if section with the If dddLive will close the DDDETAIL
         // handlers if last transaction was live and current is history
         // or last was history and current is live.  This block is identified
         // with red lettered Begin Close and End Close
        // Begin Close DDDETAIL
740eA    if dddLive;
740eA      if inRtnCode = 'LIVE';
740eA        // if route found in live and dddLive indicator is set from
740eA        // previous execution then dddetail live files are open.
740eA        // we should simply leave
740eA        //leavesr;
740eA      else;
740eA        // since dddLive is on and current route processing is not
740eA        // in live we should simply close the files to be reopened
             dddfile='DDDETAIL';
740eA        if %open(dddetail);
740eA           close dddetail;
740eA        endif;
             dddfile='DDDETAIL1';
740eA        if %open(dddetail1);
740eA           close dddetail1;
740aA        endif;
             dddfile='DDDETAIL3';
740eA        if %open(dddetail3);
740eA           close dddetail3;
740eA        endif;
             dddfile='DDDETAIL4';
740eA        if %open(dddetail4);
740eA           close dddetail4;
740aA        endif;
740eA      endif;
740eA    else;  // This else means last route processed was in history
740eA      if inRtnCode = 'LIVE';
740eA        // if route found in live and dddLive indicator is off from
740eA        // previous execution then dddetail history files are open.
740eA        // We should close and end overrides
740eA        // since dddLive is on and current route processing is not
740eA        // in live we should simply close the files to be reopened
             dddfile='DDDETAILH';
740eA        if %open(dddetail);
740eA           close dddetail;
740eA        endif;
             dddfile='DDDETAILH1';
740eA        if %open(dddetail1);
740eA           close dddetail1;
740aA        endif;
             dddfile='DDDETAILH3';
740eA        if %open(dddetail3);
740eA           close dddetail3;
740eA        endif;
             dddfile='DDDETAILH4';
740eA        if %open(dddetail4);
740eA           close dddetail4;
740aA        endif;
740eA      else;
740eA        // since this route is in History and the last route
740eA        // was in History we do not need to close and reopen
740eA        //leavesr;
740eA      endif;
740eA    endif;
        // End Close DDDETAIL
740eA    // Since the Handler should be closed now, we will reopen
740eA    // pointing to either Live or History based on current route
740eA    // This is identified as Red Begin Open and Red End Open
        // Begin Open DDDETAIL
740eA    if inRtnCode = 'LIVE';
740eA      dddLive = *on;
740eA      // will simply open without override since in live files
           dddfile='DDDETAIL';
740eA      if not %open(dddetail);
740eA         open dddetail;
740eA      endif;
           dddfile='DDDETAIL1';
740eA      if not %open(dddetail1);
740eA         open dddetail1;
740aA      endif;
           dddfile='DDDETAIL3';
740eA      if not %open(dddetail3);
740eA         open dddetail3;
740eA      endif;
           dddfile='DDDETAIL4';
740eA      if not %open(dddetail4);
740eA         open dddetail4;
740aA      endif;
740eA    else;
740eA      // when not found in live we will override to history
740eA      // files and then open for use
740eA      dddLive = *off;
           dddfile='DDDETAILH';
740eA      if not %open(dddetail);
740eA         open dddetail;
740eA      endif;
           dddfile='DDDETAILH1';
740eA      if not %open(dddetail1);
740eA         open dddetail1;
740aA      endif;
           dddfile='DDDETAILH3';
740eA      if not %open(dddetail3);
740eA         open dddetail3;
740eA      endif;
           dddfile='DDDETAILH4';
740eA      if not %open(dddetail4);
740eA         open dddetail4;
740aA      endif;
740eA    endif;
        // End Open DDDETAIL
740eA    // check for DDTASK data location
740eA    dd2dtamove('*DTALOCDDT': inRtnCode: inRtnMsg: pWhse: pRtid);
740eA    // Same logic as above for DDDETAIL. First if block denoted
740eA    // with red Begin Close and End Close to close ddtask files
740eA    // if flipping between live and history
        // Begin Close DDTASK
740eA    if ddtLive;
740eA      if inRtnCode = 'LIVE';
740eA        // if route found in live and ddtLive indicator is set from
740eA        // previous execution then dddetail live files are open.
740eA        // we should simply leave
740eA        //leavesr;
740eA      else;
740eA        // since ddtLive is on and current route processing is not
740eA        // in live we should simply close the files to be reopened
             ddtfile='DDTASK';
740eA        if %open(ddtask);
740eA           close ddtask;
740eA        endif;
             ddtfile='DDTASK1';
740eA        if %open(ddtask1);
740eA           close ddtask1;
740aA        endif;
740eA      endif;
740eA    else;  // This else means last route processed was in history
740eA      if inRtnCode = 'LIVE';
740eA        // if route found in live and ddtLive indicator is off from
740eA        // previous execution then dddetail history files are open.
740eA        // We should close and end overrides
740eA        // since ddtLive is on and current route processing is not
740eA        // in live we should simply close the files to be reopened
             ddtfile='DDTASKH';
740eA        if %open(ddtask);
740eA           close ddtask;
740eA        endif;
             ddtfile='DDTASKH1';
740eA        if %open(ddtask1);
740eA           close ddtask1;
740aA        endif;
740eA      else;
740eA        // since this route is in History and the last route
740eA        // was in History we do not need to close and reopen
740eA        //leavesr;
740eA      endif;
740eA    endif;
        // End Close DDTASK
740eA    // Again, like DDDETAIL above this next section which has Begin Open
740eA    // in Red and End Open in red will point to ddtask or ddtaskh based on
740eA    // current route.
        // Begin Open DDTASK
740eA    if inRtnCode = 'LIVE';
740eA      ddtLive = *on;
740eA      // will simply open without override since in live files
           ddtfile = 'DDTASK';
740eA      if not %open(ddtask);
740eA         open ddtask;
740eA      endif;
           ddtfile = 'DDTASK1';
740eA      if not %open(ddtask1);
740eA         open ddtask1;
740aA      endif;
740eA    else;
740eA      ddtLive = *off;
740eA      // when not found in live we will override to history
740eA      // files and then open for use
740eA      ddtfile = 'DDTASKH';
740eA      if not %open(ddtask);
740eA        open ddtask;
740eA      endif;
740eA      ddtfile = 'DDTASKH1';
740eA      if not %open(ddtask1);
740eA        open ddtask1;
740eA      endif;
740eA    endif;
        // End Open DDTASK

740eA    // Now that all dddetail and ddtask handlers are open and pointed to the
740eA    // proper live or history files lets set the external file label field to
740eA    // DDDETAIL1 which is used by all the DRAG/DROP sub procedures.  Currently
740eA    // if you remove the readonly=Y parm once a route makes past built you can still
740eA    // Drag and Drop.  To keep this as possible I had to work out a solution for
740eA    // the sub-procedures to point to history when need be.
740eA    if inRtnCode='LIVE';
740eA      dddfile='DDDETAIL1';
740eA    else;
740eA      dddfile='DDDETAILH1';
740eA    endif;
740eA  endsr;
740eA
740eA /end-free
740eA

     *----------------------------------------------------------------
     *  CombineSplit    Try to combine split  (based on PS162, PS162M
     *----------------------------------------------------------------

     p CombineSplit    b
     d CombineSplit    pi

     * Local Variables

     d count           s              1  0
720fAd splitCount      s              1  0
     d ttlCube         s                   like(lwcube)
     d ttlswgt         s                   like(lwswgt)
     d ttlqalc         s                   like(lwqalc)
     d ttlqpck         s                   like(lwqpck)
     d minlbl#         s                   like(lwlbl#)
     d first           s               n

      /free

       first = *on;
       ttlcube = 0;
       ttlswgt = 0;
       ttlqalc = 0;
       ttlqpck = 0;
       count = 0;
       minlbl# = 0;
720fA  splitCount = 0;
720fA
720fA  // First count how many split labels exist for sent in label.
720fA  // If greater than 2, then we want to leave split flag on
720fA  // after records combined.
720fA  // Logic taken from DD410/ChkItemSplit.
720fA
720fA  setll (lwwhse: lwrte: lword: lwseq: lwitem: lwtype) worklbl11;
720fA
720fA  dow forever = forever;
720fA
720fA    reade (lwwhse: lwrte: lword: lwseq: lwitem: lwtype) worklbl11;
720fA
720fA    if %eof(worklbl11);
720fA      leave;
720fA    endif;
720fA
720fA    // Doing extra checks instead of creating new LF
720fA
720fA    if lw11_lwdisp <> lwdisp
720fA      or lw11_lwctr# <> lwctr#
720fA      or lw11_lwasl2 <> lwasl2
720fA      or lw11_lwutyp <> lwutyp;
720fA        iter;
720fA    endif;
720fA
720fA    splitCount += 1;
720fA
720fA    if splitCount > 2;
720fA      leave;
720fA    endif;
720fA
720fA  enddo;

       // Look for records to combine
       // WORKLBL record was retreived in call routine, ProcessDrag5

       setll (lwwhse: lwrte: lwpal#: lwitem: lwseq: lword:
              lwdisp: lwctr#: lwasl2: lwutyp) worklblg;

       dow forever = forever;

         reade(n) (lwwhse: lwrte: lwpal#: lwitem: lwseq: lword:
                   lwdisp: lwctr#: lwasl2: lwutyp) worklblg;

         if %eof(worklblg);
           leave;
         endif;

         count += 1;

         if lwg_lwlbl# < minlbl# or first;
           minlbl# = lwg_lwlbl#;
           first = *off;
         endif;

         ttlcube += lwg_lwcube;
         ttlswgt += lwg_lwswgt;
         ttlqalc += lwg_lwqalc;
         ttlqpck += lwg_lwqpck;

       enddo;

       // Get out if there is nothing to combine

       if count <= 1;
         return;
       endif;

       // Loop through the records again, this time updating/deleting them.

       setll (lwwhse: lwrte: lwpal#: lwitem: lwseq: lword:
              lwdisp: lwctr#: lwasl2: lwutyp) worklblg;

       dow forever = forever;

         reade (lwwhse: lwrte: lwpal#: lwitem: lwseq: lword:
                   lwdisp: lwctr#: lwasl2: lwutyp) worklblg;

         if %eof(worklblg);
           leave;
         endif;

         if lwg_lwlbl# = minlbl#;

           lwg_lwcube = ttlcube;
           lwg_lwswgt = ttlswgt;
           lwg_lwqalc = ttlqalc;
           lwg_lwqpck = ttlqpck;
           update lwrecg;

           chain (lwg_lwwhse: lwg_lwrte: 0: lwg_lwlbl#) dddetail4;
           if %found(dddetail4);
             dddcube = ttlcube;
             dddwgt = ttlswgt;
             dddpcs = ttlqalc;
720fA        if splitCount <= 2;
               ddditmsplt = 0;
             endif;
720fA        update dddrec4;
           endif;

         else;

           chain (lwg_lwwhse: lwg_lwrte: 0: lwg_lwlbl#) dddetail4;
           if %found(dddetail4);
             delete dddrec4;
           endif;

           delete lwrecg;

         endif;

       enddo;

720fD  // Last of all, see label is still a split
720fD  // Removed because it wasn't correct.
720fD  // Using new method above.
720fD
720fD  //count = 0;
720fD
720fD  //setll (lwwhse: lwrte: lwpal#: lwitem: lwseq: lword:
720fD  //       lwdisp: lwctr#: lwasl2: lwutyp) worklblg;
720fD
720fD  //dow forever = forever;
720fD
720fD  //  reade(n) (lwwhse: lwrte: lwpal#: lwitem: lwseq: lword:
720fD  //            lwdisp: lwctr#: lwasl2: lwutyp) worklblg;
720fD
720fD  //  if %eof(worklblg);
720fD  //    leave;
720fD  //  endif;
720fD
720fD  //  count += 1;
720fD
720fD  //  if count > 1;
720fD  //    chain (lwg_lwwhse: lwg_lwrte: 0: lwg_lwlbl#) dddetail4;
720fD  //    if %found(dddetail4);
720fD  //      ddditmsplt = 1;
720fD  //      update dddrec4;
720fD  //   endif;
720fD  //    leave;
720fD  //  endif;
720fD
720fD  //enddo;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ClearDDTREC     Clear DDTREC Fields
     *----------------------------------------------------------------

     p ClearDDTREC     b
     d ClearDDTREC     pi

      /free

720iA  GetCurrStamp();
       clear ddtrec;

       ddtaddpgm = #pgm;
       ddtaddts = currstampsys;
       ddtadduc = currstampuc;
       if pUser = '';
         ddtaddusr = #curruser;
       else;
         ddtaddusr = pUser;
       endif;
       ddtaddusrj = #curruser;
       ddtaddjob = #job;
       ddtaddnbr = #jobnbr;
       ddtsessid = pSessId;

      /end-free

     p                 e

740bA*----------------------------------------------------------------
740bA*  ClearRouteLock   Clear route lock
740bA*----------------------------------------------------------------
740bA
740bAp ClearRouteLock  b
     d ClearRouteLock  pi

      /free

       // Clear lock by deleting record.
       // Record should have been locked durint set

       delete(e) ddlrec;

       if %error;
       endif;

      /end-free

     p                 e

     *----------------------------------------------------------------
720cM*  crtParentRecs    Create parent recs for drop (DDDETAIL/PLTSUM/PLTSTP)
     *----------------------------------------------------------------

720cMp CrtParentRecs   b

     * Local Files

740eDF*dddetail1 uf a e           k disk
740eMFdddetail1 uf a e           k disk    extfile(dddfile)

720cMd CrtParentRecs   pi
720cAd  truckTemplate                      const like(lwtruk)
     d  indddrec                           const likerec(dddrec: *input)

     * Local File Data Structures

     d locdddrecin     ds                  likerec(dddrec: *input)
     d locdddrecout    ds                  likerec(dddrec: *output)
     d inddditem       ds                  likerec(dddrec: *input)

     * Local Variables

     d havePallet      s               n
     d haveStop        s               n
     d unusedBCNT      s              1  0
     d maxPalletStops  s              2s 0
     d stopsOnPallet   s              2s 0
720hAd honorOrdOpt     s               n

      /free

ADCaA  if client = andersondubose;
720hA    honorOrdOpt = *on;
ADCaA  endif;

       // To start with, we are always just dropping on a location
       // Future will will allow dropping directly on pallet.

       // Initialize drop info

       dropStp = dropSent;

       havePallet = *off;
       haveStop = *off;

       // Loop through Stop records looking for record with a
       // matching Stop and Zone. Depending on Zone option
       // look for mathing order number.

       setll (pWhse: pRtid: 0: dropSent.dddgroup: 4:
              dropSent.dddrow: dropSent.dddcol) dddetail1;

       dow forever = forever;

         reade(n) (pWhse: pRtid: 0: dropSent.dddgroup: 4:
                   dropSent.dddrow: dropSent.dddcol) dddetail1 locdddrecin;

         if %eof(dddetail1);
           leave;
         endif;
750 A
750 A    // Skip if doing un-merge of unlike zones and
750 A    // from/to pallet id are the same.  gSavedId
750 A    // represents the dragged id and the locdddrecin.dddpid
750 A    // represents the pallet id for specific stop being read.
750 A    // this prevents it from simply dropping back on same
750 A    // pallet it was merged on
750 A    if pCmd = 'DROPU';
750 A      if locdddrecin.dddpid = gsavedid;
750 A        iter;
750 A      endif;
750 A    endif;

750 A    // skip like pallet id's.  gsavedId represents pallet
750 A    // id from what the user dragged.  dddpid is the parent
750 A    // id of each stop read in this loop.  reade above is reading
750 A    // type 4 records which are stops.  It only performs this when
750 A    // allow same location drop is on and dragid equal stops pallet id
750 A    if alwSameLocDrp and gsavedId = locdddrecin.dddpid;
750 A      iter;
750 A    endif;

750 A    // when dropped on pallet id we should look to add to specific
750 A    // pallet id.  If dropped on pallet id the parm pDropId will begin
750 A    // with 'pl'.  We do not want to put this dragged item back on
750 A    // the same pallet we dragged it from. This is only enforced
750 A    // when all the dragids and dropid exist on the same row/col
750 A    if %subst(pDropId:1:2)='pl' and dragDropPltsm;
750 A      if pDropId <> locdddrecin.dddpid;
750 A        iter;
750 A      endif;
750 A    endif;

         // Skip if zone doesn't match

         if locdddrecin.dddtzon <> indddrec.dddtzon
750eA       and locdddrecin.dddTzon <> RCTzon;
750 A      // when zones are different we now act different based on
750 A      // the new merg unlike zones setting.  When set to N for not
750 A      // allowed we turn zoneDiffer off and iter meaning this
750 A      // stop is not usable for this dragged item.  This setting
750 A      // performs and acts as the functionality prior to this option.
750 A      // It simply creates a separate pallet id in same position for
750 A      // different zones.  When set to "S" it will act the same as
750 A      // "N" on the initial merge from one zone to another, but then
750 A      // allows the user to manually merge id's from the second pallet
750 A      // position into another in that location.  Lastly, when set to
750 A      // "M" the system will automatically merge unlike zones into the
750 A      // pallet or location based on where the user drops.  The user can
750 A      // then undo by clicking an newicon for multi-zone lines.
750 A
750 A      // ** zoneDiffer variable is used to determine if a record for this
750 A      // id should be added to ddwrkflds.  This file is used in dd410 and dd420
750 A      // to determine if the merge icon should be displayed to undo the merges
750 A
750 A      select;
750 A        when zoneMergeOpt = 'N';
750 A          // no merging of pallets allowed
750 A          zoneDiffer = *off;
               iter;
750 A        when zoneMergeOpt = 'S';
750 A          // still separate from automatic perspective
750 A          // but identify
750 A          zoneDiffer = *off;
750 A          iter;
750 A        when zoneMergeOpt = 'M';
750 A          // automatically merge pallets
750 A          zoneDiffer = *on;
750 A      endsl;
         endif;

         // Skip if stop doesn't match

         if locdddrecin.dddstop <> indddrec.dddstop;
           iter;
         endif;

720hA    // Skip if only 1 order per pallet and order doesn't match
720hA
720hA    if honorOrdOpt;
720hA      if GetZoneOrdOpt(truckTemplate: locdddrecin.dddtzon) = 'Y';
720hA        if locdddrecin.dddord <> indddrec.dddord;
720hA          iter;
720hA        endif;
720hA      endif;
720hA    endif;

         // We have a pallet containing the zone/stop we can drop on.

         havePallet = *on;
         haveStop = *on;

         dropStp = locdddrecin;
750 A    // set dropPlt with actual pallet id.  Prior code was setting dropPlt
750 A    // with the dropstp and we needed pallet id to be represented in dddid
750 A    // in the dropPlt structure
750 A    setll (pWhse: pRtid: 0: dropSent.dddgroup: 2:
750 A           dropSent.dddrow: dropSent.dddcol: locdddrecin.dddplid)
750 A                      dddetail1;
750 A
750 A      reade(n) (pWhse: pRtid: 0: dropSent.dddgroup: 2:
750 A             dropSent.dddrow: dropSent.dddcol: locdddrecin.dddplid)
750 A                      dddetail1 locdddrecin;
         dropPlt = locdddrecin;
750 A    locdddrecin = dropStp;
         leave;

       enddo;

       // If we didn't find a matching Stop record above, look for an existing
       // pallet record we can merge our label onto.
       // If only 1 order per pallet is being enforced, then we can skip looking
       // at pallet records and move onto creating a new pallet for the order.

720hD  //if not havePallet;
720hM  if not havePallet and not honorOrdOpt;

         setll (pWhse: pRtid: 0: dropSent.dddgroup: 2:
                dropSent.dddrow: dropSent.dddcol) dddetail1;

         dow forever = forever;

           reade(n) (pWhse: pRtid: 0: dropSent.dddgroup: 2:
                  dropSent.dddrow: dropSent.dddcol) dddetail1 locdddrecin;

           if %eof(dddetail1);
             leave;
           endif;
750 A
750 A      // Skip if doing un-merge of unlike zones and
750 A      // from/to pallet id are the same
750 A      // refer to stop loop above for more detail explanation
750 A      if pCmd = 'DROPU';
750 A        if locdddrecin.dddid = gsavedid;
750 A          iter;
750 A        endif;
750 A      endif;

750 A    // Skip if dragged pallet id and dropped pallet id match
750 A    // refer to stop loop above for more detail explanation
750 A    if alwSameLocDrp and gsavedid = locdddrecin.dddid;
750 A      iter;
750 A    endif;

750 A    // when dropped on pallet id we should look to add to specific
750 A    // pallet id
750 A    // refer to stop loop above for more detail explanation
750 A    if %subst(pDropId:1:2)='pl' and dragDropPltsm;
750 A      if pDropId <> locdddrecin.dddid;
750 A        iter;
750 A      endif;
750 A    endif;

           // Skip if zone doesn't match
750 A      // refer to stop loop above for more detail explanation

           if locdddrecin.dddtzon <> indddrec.dddtzon;
750 A        select;
750 A          when zoneMergeOpt = 'N';
750 A            // no merging of pallets allowed
750 A            zoneDiffer = *off;
                 iter;
750 A          when zoneMergeOpt = 'S';
750 A            // still separate from automatic perspective
750 A            // but identify
750 A            zoneDiffer = *off;
750 A            iter;
750 A          when zoneMergeOpt = 'M';
750 A            // automatically merge pallets
750 A            zoneDiffer = *on;
750 A        endsl;
           endif;

           // Skip if *SP flags don't match

           if locdddrecin.dddspflag <> indddrec.dddspflag;
             iter;
           endif;

           // skip if *SP flag and Stops don't match

           if indddrec.dddspflag = 1 and locdddrecin.dddstop<>indddrec.dddstop;
             iter;
           endif;

           // See if any more Stops allowed on pallet

           maxPalletStops = GetMaxPltStops(truckTemplate: locdddrecin.dddtzon);

           if maxPalletStops > 0 and maxPalletStops < 99;
             stopsOnPallet = GetStopsOnPlt(locdddrecin.dddgroup:
                                          locdddrecin.dddrow:
                                          locdddrecin.dddcol:
                                           locdddrecin.dddplid);

             if stopsOnPallet >= maxPalletStops;
               iter;
             endif;

           endif;

           havePallet = *on;
           dropPlt = locdddrecin;
750 A      wrkcomp = indddrec.dddcomp;
750 A      wrktzon = indddrec.dddtzon;
750 A      wrkpzon = indddrec.dddpzon;
750 A      wrkszon = indddrec.dddszon;
           leave;

         enddo;

       endif;

       // Create pallet if necessary

       if not havePallet;

         // Get PLTSUM summary location record

         chain (pWhse: pRtid: 'O':
                dropSent.dddgen: dropSent.dddrow: dropSent.dddcol) pltsum2;
         if not %found(pltsum2);
           error = *on;
740cA      errmsg = dropStr;
740cM      errmsg += 'PLTSUM summary record not found for '
                  + 'row ' + %char(dropSent.dddrow) + ', '
                  + 'col ' + %char(dropSent.dddcol) + ', '
                  + 'id ' + dropSent.dddid;
           return;
         endif;

         // Error if no more room in the location

         if psbcnt = 9;
           error = *on;
740cD      //errmsg += 'Error trying to add pallet to location '
740cD      //       + 'row ' + %char(dropSent.dddrow) + ' '
740cD      //       + 'col ' + %char(dropSent.dddcol) + ', '
740cA      errmsg = dropStr
                  + 'location already has the maximum of 9 pallets.';
750 A      unlock pltsum2;
           return;
         endif;

         // Get an unused PSBCNT

         unusedBCNT = GetPSBCNT (psrow: pscol);

         if unusedBCNT = 0;
           error = *on;
740cD      //errmsg += 'Error trying to add pallet to location '
740cD      //       + 'row ' + %char(dropSent.dddrow) + ' '
740cD      //       + 'col ' + %char(dropSent.dddcol) + ', '
740cA      errmsg = dropStr
                  + 'location already has the maximum of 9 pallets.';
           return;
         endif;

         // Increase pallet count

         psbcnt += 1;
         update psrec;

         // Create PLTSUM pallet record

         pstype = 'P';
         psbcnt = unusedBCNT;
         dsplid = psplid;
         dsplgn = 1;
         dsplrw = psrow;
         dsplcl = pscol;
         dsplsq = psbcnt;
         psplid = dsplid;
750 D    //pscomp = indddrec.dddcomp;
750 D    //pstzon = indddrec.dddtzon;
750 D    //pspzon = indddrec.dddpzon;
750 D    //psszon = indddrec.dddszon;
750 A    if wrkcomp = *blanks;
750 M      wrkcomp = indddrec.dddcomp;
750 M      wrktzon = indddrec.dddtzon;
750 M      wrkpzon = indddrec.dddpzon;
750 M      wrkszon = indddrec.dddszon;
750 A    endif;
750 M    pscomp = wrkcomp;
750 M    pstzon = wrktzon;
750 M    pspzon = wrkpzon;
750 M    psszon = wrkszon;

720cA    psmaxc = GetZoneMaxCube(truckTemplate: pstzon);
         pspcs  = 0;
         pscube = 0;
         psswgt = 0;

         write psrec;

         // Create DDDETAIL pallet record

         locdddrecout = dropLoc;
         locdddrecout.dddlevel = PALLETLVL;
         locdddrecout.dddpid = locdddrecout.dddid;
         locdddrecout.dddid = 'plid' + %char(psplid);
         locdddrecout.dddplid = psplid;
750 D    //locdddrecout.dddcomp = indddrec.dddcomp;
750 D    //locdddrecout.dddtzon = indddrec.dddtzon;
750 D    //locdddrecout.dddpzon = indddrec.dddpzon;
750 D    //locdddrecout.dddszon = indddrec.dddszon;
750 M    locdddrecout.dddcomp = wrkcomp;
750 M    locdddrecout.dddtzon = wrktzon;
750 M    locdddrecout.dddpzon = wrkpzon;
750 M    locdddrecout.dddszon = wrkszon;
720cA    locdddrecout.dddmaxc = psmaxc;
         locdddrecout.dddpcs = 0;
         locdddrecout.dddcube = 0;
         locdddrecout.dddwgt = 0;
740 A    monitor;
720eA      locdddrecout.dddmaxw = GetZoneMaxWgt(truckTemplate: pstzon);
740 A    on-error;
740 A      locdddrecout.dddmaxw = *zeros;
740 A    endmon;

         write dddrec locdddrecout;

         dropPlt = locdddrecout;

       endif;

       // Create stop if necessary

       if not haveStop;

         locdddrecout = dropPlt;
         locdddrecout.dddlevel = STOPLVL;
         locdddrecout.dddpid = locdddrecout.dddid;
         locdddrecout.dddid = 's' + %char(indddrec.dddstop)
                            + 'p' + %char(dropPlt.dddplid);
         locdddrecout.dddstop = indddrec.dddstop;
         locdddrecout.dddhststp = indddrec.dddhststp;
         locdddrecout.dddstp1 = indddrec.dddstop;
         locdddrecout.dddstp2 = indddrec.dddstop;
         locdddrecout.DDDORD = indddrec.DDDORD;
750 A    if wrkcomp = *blanks;
750 M      wrkcomp = indddrec.dddcomp;
750 M      wrktzon = indddrec.dddtzon;
750 M      wrkpzon = indddrec.dddpzon;
750 M      wrkszon = indddrec.dddszon;
750 A    endif;
750 D    //locdddrecout.dddcomp = indddrec.dddcomp;
750 D    //locdddrecout.dddtzon = indddrec.dddtzon;
750 D    //locdddrecout.dddpzon = indddrec.dddpzon;
750 D    //locdddrecout.dddszon = indddrec.dddszon;
750 M    locdddrecout.dddcomp = wrkcomp;
750 M    locdddrecout.dddtzon = wrktzon;
750 M    locdddrecout.dddpzon = wrkpzon;
750 M    locdddrecout.dddszon = wrkszon;
720cA    locdddrecout.dddmaxc = 0;
         locdddrecout.dddpcs = 0;
         locdddrecout.dddcube = 0;
         locdddrecout.dddwgt = 0;
720eA    locdddrecout.dddmaxw = 0;

         write dddrec locdddrecout;

         dropStp = locdddrecout;

       endif;

      /end-free

     p                 e

750 A*----------------------------------------------------------------
750 A*  addMrgFlgs - Add merge data flags to DDWRKFLGS
750 A*----------------------------------------------------------------
750 A
750 Ap addMrgFlgs      b
750 A
750 Ad addMrgFlgs      pi
750 Ad  indddrec                                 likerec(dddrec: *input)
750 A
750 A /free
750 A    // write record to dd work file with extra fields if necessary
750 A    if zoneDiffer;
750 A      wrkspin = *blanks;
750 A      wrkmrg= *blanks;
750 A      wrkrow= *zeros;
750 A      wrkcol= *zeros;
750 A      // get record for this dd2 route id and rec type id
750 A      exWhse = pWhse;
750 A      wrkRtid= pRtid;
750 A      ddwrkflds ('*GET': exRtnCode: exRtnMsg: exWhse: wrkRtid:
750 A                  indddrec.dddsnap: indddrec.dddid: wrkrow:
750 A                  wrkcol: wrkmrg: wrkspin);
750 A
750 A      if exRtnCode = '*OK';
750 A        // when record was found then update flags
750 A        ddwrkflds ('*CHANGE': exRtnCode: exRtnMsg: exWhse: wrkRtid:
750 A                    indddrec.dddsnap: indddrec.dddid: indddrec.dddrow:
750 A                    indddrec.dddcol: wrkmrg: wrkspin);
750 A      else;
750 A        // perform insert when not found
750 A        wrkspin = 'N';
750 A        wrkmrg='Y';
750 A        ddwrkflds ('*ADD': exRtnCode: exRtnMsg: exWhse: wrkRtid:
750 A                    indddrec.dddsnap: indddrec.dddid: indddrec.dddrow:
750 A                    indddrec.dddcol: wrkmrg: wrkspin);
750 A      endif;
750 A    endif;
750 A
750 A /end-free
750 Ap                 e
750 A
750 A*----------------------------------------------------------------
750 A*  ddPltSame - Return flag indicating whether same location
750 A*              for all drag ids and drop id
750 A*----------------------------------------------------------------
750 A
750 Ap ddPltSame       b
750 Ad ddPltSame       pi              n
750 A
750 Ad locdddrec       ds                  likerec(dddrec: *input)
750 Ad pltsame         s               n
750 Ad wrkid           s                   like(dddid)
750 Ad i               s              5  0
750 A
750 A /free
750 A
750 A        pltsame = *on;
750 A        if %subst(pDropId:1:2) <> 'pl';
750 A          // if not dropping onto a pallet we are not concerned
750 A          pltsame = *off;
750 A          return pltsame;
750 A        endif;
750 A
750 A        // now we know the drop id is a pallet so we will loop
750 A        // thru each of the dragids and determine if any live
750 A        // on another row/col.  If so we will turn off the pltsame
750 A        // and return
750 A
750 A        for i = 1 to dragcount;
750 A
750 A          %occur(dragList) = i;
750 A
750 A          wrkid = dragList.id;
750 A          setll (pWhse: pRtid: 0: wrkid) dddetail;
750 A
750 A          dow forever = forever;
750 A            reade (pWhse: pRtid: 0: wrkid) dddetail locdddrec;
750 A            if not %equal(dddetail) or %eof(dddetail);
750 A              return pltsame;
750 A            endif;
750 A
750 A            // if dragid is location then ensure the location id
750 A            // equals the parent id of the dropped pallet since
750 A            // we do not make it here unless we are dropping on pallet
750 A            if %subst(locdddrec.dddid:1:1)='l';
750 A              if locdddrec.dddid <> dropplt.dddpid;
750 A                // as soon as we encounter a different
750 A                // location we should return with pallet same off
750 A                pltsame=*off;
750 A                return pltsame;
750 A              else;
750 A                // since this was a location and it matches the location
750 A                // of the parent id of the dropped on pallet we should
750 A                // leave do loop and look at next drag id
750 A                leave;
750 A              endif;
750 A            endif;
750 A
750 A            if %subst(locdddrec.dddid:1:2)='pl';
750 A              if locdddrec.dddpid <> dropplt.dddpid;
750 A                // as soon as we encounter a different
750 A                // location we should return with pallet same off
750 A                pltsame=*off;
750 A                return pltsame;
750 A              else;
750 A                // since this was a pallet and it is on same location
750 A                // leave loop.  We are only wanting to turn off pltsame
750 A                // if we encounter different locations for any drag ids
750 A                leave;
750 A              endif;
750 A            else;
750 A              // if not a pallet we should setll for parent id and read next
750 A              wrkid = locdddrec.dddpid;
750 A              setll (pWhse: pRtid: 0: wrkid) dddetail;
750 A            endif;
750 A
750 A          enddo;
750 A
750 A        endfor;
750 A
750 A        return pltsame;
750 A
750 A /end-free
750 Ap                 e

     *----------------------------------------------------------------
     *  DoDrop     Process Drop
     *----------------------------------------------------------------

     p DoDrop          b
     d DoDrop          pi


      /free

720jA  WriteRteLog ('PROCESS': '1');   // Start logging Processing

       // Get list of drag id's

       GetDragList();
       if dragCount = 0;
         error = *on;
740cA    errmsg = dropStr;
740cM    errmsg += 'Nothing selected for dragging';
         return;
       endif;

       // Special checks for SPLIT

       if pCmd = 'SPLIT';

         // Only 2 entries allowed for a SPLIT

         if pCmd = 'SPLIT' and dragCount > 2;
           error = *on;
740cA      errmsg = dropStr;
740cM      errmsg += 'More than 1 item selected for a split '
                  + '(' + %trimr(pDragIds) + ')';
           return;
         endif;

         // For a SPLIT, second entry must be a number

         %occur(dragList) = 2;
         monitor;
           gSplitPcs = %dec(dragList.id: 5: 0);
         on-error;
           error = *on;
740cA      errmsg = dropStr;
740cM      errmsg += 'Invalid split quantity sent '
                  + '(' + %trimr(dragList.id) + ')'
                  + '(' + %trimr(pDragIds) + ')';
           return;
         endmon;

         // Set dragList count to 1

         dragCount = 1;

       endif;

       // Process drag id's

       ProcessDragIds();
       if error;
         return;
       endif;

       // Update Location Compartments

       UpdateLocComp();

720jA  WriteRteLog ('PROCESS': '2');   // End logging Processing

       // Create tasks for rebuilding locations

       WriteDropTasks();
       if error;
         return;
       endif;

       // See if we can return the JSON string for the changes
       // or if we send and instruction to get the JSON string from the file.

       if %len(gRtnStr) > 2000;
720jD    //pJSON = '{"taskgrp":"' + %char(gTaskGrp) + '"}';
720jM    pJSON = '{"grpid":"' + %char(gTaskGrp) + '",'
               + '"taskgrp":"' + %char(gTaskGrp) + '"}';
       else;
         pJSON = gRtnStr;
       endif;

      /end-free

     p                 e

720jA*----------------------------------------------------------------
720jA*  DoGUITimes   Process GUI Times
720jA*----------------------------------------------------------------
720jA
720jAp DoGUITimes      b
     d DoGUITimes      pi

     * Local Variables

     d millisec        s              7  0
     d min             s              7  2
     d count           s              1  0
     d ddSubGrp        s             12

      /free

       millisec = 0;
       min = 0;

       GetDragList();

       for count = 1 to dragCount;

         %occur(dragList) = count;
         monitor;
           select;
             when count = 1;
               monitor;
                 gTaskGrp = %dec(dragList.id: 7: 2);
               on-error;
                 gTaskGrp = 0;
               endmon;
             when count = 2;
               ddSubGrp = dragList.id;
             when count = 3;
               monitor;
                 millisec = %dec(dragList.id: 7: 0);
                 min = (millisec / 1000) / 60;
               on-error;
                 min = 0;
               endmon;
           endsl;
         on-error;
         endmon;

       endfor;

720jA  WriteRteLog6 (ddSubGrp: min);

       pJSON = '{"guitimes":"ok"}';

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  DoLevel    Process Level
     *----------------------------------------------------------------

     p DoLevel         b
     d DoLevel         pi

      /free

720jA  WriteRteLog ('PROCESS': '1');   // Start logging Process

       GetDragList();

       if dragCount < 2;
         error = *on;
         errmsg = 'Must select 2 pallets for leveling '
                + '(' + %trimr(pDragIds) + ')';
         return;
       endif;

       if dragCount > 2;
         error = *on;
         errmsg = 'Only 2 pallets can be selected for leveling '
                + '(' + %trimr(pDragIds) + ')';
         return;
       endif;

720jA  WriteRteLog ('PROCESS': '2');   // End logging Process


      /end-free

     p                 e

     *----------------------------------------------------------------
     *  DoSwap     Process Swap
     *----------------------------------------------------------------

     p DoSwap          b
     d DoSwap          pi

      /free

720jA  WriteRteLog ('PROCESS': '1');   // Start logging Process

       GetDragList();

       if dragCount < 2;
         error = *on;
         errmsg = 'Must select 2 pallets or locations for swapping '
                + '(' + %trimr(pDragIds) + ')';
         return;
       endif;

       if dragCount > 2;
         error = *on;
         errmsg = 'Only 2 pallets or locations can be selected for swapping '
                + '(' + %trimr(pDragIds) + ')';
         return;
       endif;

720jA  WriteRteLog ('PROCESS': '2');   // Start logging Process


      /end-free

     p                 e

     *----------------------------------------------------------------
     *  DoRefresh    Process Refresh
     *----------------------------------------------------------------

     p DoRefresh       b
     d DoRefresh       pi

     * Local Variables

     D pRtnCode        s             10
     D pRtnMsg         s            100
     d pRtnStr         s          65535    varying

      /free

720jA  WriteRteLog ('DD410': '1');   // Start logging DD410

       // Rebuild DDDETAIL for route

       dd410('*RBLDTRUCK': pWhse: pRtid: '': 0: 0:
             pUser: pSessId: pDict: pPgm: pRtnCode: pRtnMsg);
       if pRtnCode = '*ERROR';
         pJSON = '{"error":"' + %trim(pRtnMsg)
               + ' (' + #pgm+'/'+#job+'/'+#jobn+'/'+#curruser + ')"}';
         passThruMsg = *on;
         return;
       endif;

720jA  WriteRteLog ('DD410': '2');   // End logging DD410

720jA  WriteRteLog ('DD430': '1');   // Start logging DD430

       // Rebuild group zero Truck tasks
       // If too slow, will need to revise to rebuild locations

       dd430('RBLDTRUCK': '': pWhse: pRtid:
             pUser: pSessId: pDict: pPgm: pRtnCode: pRtnMsg: pRtnStr);
       if pRtnCode = '*ERROR';
         pJSON = '{"error":"' + pRtnStr
               + ' (' + #pgm+'/'+#job+'/'+#jobn+'/'+#curruser + ')"}';
         passThruMsg = *on;
        return;
       endif;

720jA  WriteRteLog ('DD430': '2');   // End logging Processing

       // Send back command to refresh from file

720jD  //pJSON = '{"refresh":"0"}';
720jM  pJSON = '{"grpid":"' + %char(gTaskGrp) + '","refresh":"0"}';

      /end-free

     p                 e

720dA*----------------------------------------------------------------
720dA*  DoRebuild    Process Rebuild
720dA*----------------------------------------------------------------

720dAp DoRebuild       b
720dAd DoRebuild       pi

720dA* Local Variables

720dAD pRtnCode        s             10
720dAD pRtnMsg         s            100
720dAd pRtnStr         s          65535    varying

720dA /free

720jA  WriteRteLog ('REBUILDRTE': '1');   // Start logging Rebuild

720dA  // Call REBUILDRTE used in DD1
       gErrMsg=*blanks;
       gReturn=*blanks;
       gRtid=pRtid;
720dA  RebuildRte(pWhse:gRtid:gReturn:gErrMsg);
720gD  //pRtnCode = gReturn;
720gD  //pRtnMsg = gErrMsg;

720gA  if gReturn <> '*OK';
720gA    pJSON = '{"error":"' + %trim(gErrMsg)
720gA          + ' (' + #pgm+'/'+#job+'/'+#jobn+'/'+#curruser + ')"}';
720gA    passThruMsg = *on;
720gA  else;
720jD    //pJSON = '{"refresh":"0"}';
720jM    pJSON = '{"grpid":"' + %char(gTaskGrp) + '","refresh":"0"}';
720gA  endif;

720jA  WriteRteLog ('REBUILDRTE': '2');   // Start logging Rebuild

720dA /end-free

720dAp                 e

720bA*----------------------------------------------------------------
720bA*  DoReplay     Process Replay
720bA*----------------------------------------------------------------
720bA
720bAp DoReplay        b
720bAd DoReplay        pi

     * Local Variables

     D pRtnCode        s             10
     D pRtnMsg         s            100
     d pRtnStr         s          65535    varying
     d maxGroup        s              5i 0

      /free

       dd430('RBLDREPLAY': '': pWhse: pRtid:
             pUser: pSessId: pDict: pPgm: pRtnCode: pRtnMsg: pRtnStr);
       if pRtnCode = '*ERROR';
         pJSON = '{"error":"' + pRtnStr
               + ' (' + #pgm+'/'+#job+'/'+#jobn+'/'+#curruser + ')"}';
         passThruMsg = *on;
        return;
       endif;

740eD  //exec sql select max(ddttaskgrp) into :maxGroup
740eD  //         from ddtask
740eD  //         where ddtwhse = :pWhse
740eD  //           and ddtrtid = :pRtid
740eD  //           and ddttype = 'DDTASKS';
740eA  // Change to dynamic query to control file name
740eA  if inRtnCode = 'LIVE';
740eA    ddtfile = 'DDTASK';
740eA  else;
740eA    ddtfile = 'DDTASKH';
740eA  endif;
740eA  sqlstmt = 'select max(ddttaskgrp) from ' + %trim(ddtfile) +
740eA            ' where ddtwhse=' + %char(pwhse) + ' and ' +
740eA            'ddtrtid=' + sq + %trim(prtid) + sq +
740eA            ' and ddttype=' + sq + 'DDTASKS' + sq;
740eA  exec sql PREPARE mg FROM :SqlStmt;
740eA  exec sql DECLARE mxgrp SCROLL CURSOR FOR mg;
740eA  exec sql OPEN mxgrp;
740eA  exec sql fetch first from mxgrp into :maxGroup;

       if sqlstt <> sqlSuccess;
         maxGroup = 0;
       endif;

740eA  exec sql close mxgrp;

       // Send back command to refresh from replay

       pJSON = '{"replay":"' + %char(maxGroup) + '"}';

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetPSBCNT        Get an unused PSBCNT for row/col
     *----------------------------------------------------------------

     p GetPSBCNT       b

     * Local Files

     Fpltsum2   if   e           k disk

     d GetPSBCNT       pi             1  0
     d  row                                like(psrow)
     d  col                                like(pscol)

     * Local File Data Structures

     d locps2rec       ds                  likerec(psrec: *input)

     * Local Variables

     d  unusedBCNT     s              1  0
     d  unusedFlags    s              9

      /free

       unusedBCNT = 0;
       unusedFlags = '000000000';

       // Read through all P recs and check off BCNT's

       setll (pWhse: pRtid: 'P': 1: row: col) pltsum2;

       dow forever = forever;

         reade (pWhse: pRtid: 'P': 1: row: col) pltsum2  locps2rec;

         if %eof(pltsum2);
           leave;
         endif;

         if psbcnt > 0;
           %subst(unusedFlags: locps2rec.psbcnt: 1) = '1';
         endif;

       enddo;

       // Get unused BCNT

       unusedBCNT = %scan('0': unusedFlags);

       return unusedBCNT;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetDragList      Extract drag id's into a list
     *----------------------------------------------------------------

     p GetDragList     b
     d GetDragList     pi

     * Local Variables

     d  pos            s              5  0
     d  start          s              5  0
     d  dragIdsLen     s              5  0
     d  idLen          s              5  0

      /free

       // Drag Id's are separated by '|'

       start = 1;
       dragIdsLen = %len(%trimr(pDragIds));
       dragCount = 0;

       dow start <= dragIdsLen;


         pos = %scan('|': pDragIds: start);

         select;

           when pos > 0;
             idLen = pos - start;
             dragCount += 1;
             %occur(dragList) = dragCount;
             dragList.id = %subst(pDragIds: start: idLen);
             start = pos + 1;

           when pos = 0;
             idLen = %len(%trimr(pDragIds)) - start + 1;
             dragCount += 1;
             %occur(dragList) = dragCount;
             dragList.id = %subst(pDragIds: start: idLen);
             leave;

           other;
             leave;

         endsl;

       enddo;


      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetDropInfo     Get record for drop id and its location record
     *----------------------------------------------------------------

     p GetDropInfo     b
     d GetDropInfo     pi

      /free

       droppedOnLoc = *off;
       droppedOnPlt = *off;
       newOvfDrop = *off;

       clear dropSent;
       clear dropLoc;
       clear dropPlt;
730aA  clear locCount;
730aA  clear locList;

       // Convert locations starting with 'm' to starting wtih 'l'.

       if %subst(pDropId: 1: 1) = 'm';
         %subst(pDropId: 1: 1) = 'l';
       endif;

       // If dropping on catch-all Overflow pallet,
       // create new PLTSUM and DDDETAIL records for it.

       if pDropId = 'grpO' or pDropId = 'olr0c0';

         // Get unused Overflow pallet

         setgt (pWhse: pRtid: 'O': 1) pltsum2;
         readpe(n) (pWhse: pRtid: 'O': 1) pltsum2;
         if psunld <= 70;
           psrow += 1;
           pscol = 1;
           psunld = 71;
         else;
740aA      if psunld < 99;
             psunld += 1;
740aA      else;
740aA        // since high of 99 used check to see if lower seq. available
740aA        lastUnldSeq = psunld;
740aA        dow forever = forever;
740aA          readpe(n) (pWhse: pRtid: 'O': 1) pltsum2;
740aA          if psunld < 71 and lastUnldSeq < 71;
740aA            // return message stating no room remains in Overflow
740cD            //errmsg = 'Overflow FULL';
740cM            errmsg = dropStr + 'Overflow is Full';
740aA            error=*on;
740aA            return;
740aA          endif;
740aA          if (lastUnLdSeq - psunld) > 1;
740aA            psunld = lastUnldSeq - 1;
740aA            // confirm this unload sequence not found
740aA            exec sql select psunld into :psunld
740aA                      from pltsum2
740aA                where pswhse=:pWhse and psrtid=:pRtid
740aA                  and psgen=1 and psunld=:psunld and
740aA                    (pstype='P' or pstype='O')
740aA                    fetch first row only;
740aA            if sqlstt = '00000';
740aA              // if found then keep reading
740aA            else;
740aA              // otherwise leave, we found an open unload sequence
740aA              // between 71 and 99
740aA              leave;
740aA            endif;
740aA          endif;
740aA          if psunld < lastUnldSeq;
740aA            lastUnldSeq = psunld;
740aA          endif;
740aA        enddo;
740aA      endif;
           if pscol < 9;
             pscol += 1;
           else;
             psrow += 1;
             pscol = 1;
           endif;
         endif;
740aA    // Ensure Row/Column not already in overflow in dddetail
740aA    if psunld > 70;
740aA      setll (pWhse:pRtid:0:'O':LOCATIONLVL:psRow:psCol) dddetail1;
740aA      dow forever=forever;
740aA        reade (pWhse:pRtid:0:'O':LOCATIONLVL:psRow:psCol) dddetail1;
740aA        if %equal(dddetail1) and not %eof(dddetail1);
740aA          if pscol < 9;
740aA            pscol += 1;
740aA          else;
740aA            psrow += 1;
740aA            pscol = 1;
740aA          endif;
740aA        else;
740aA          // we have a unique row and column
740aA          leave;
740aA        endif;
740aA     enddo;
740aA    endif;

         // Create pallet id

         clear pltid;
         dsplgn = 1;
         dsplrw = psrow;
         dsplcl = pscol;
         psplid = dsplid;

750cD    //pspal# = 0;
750cD    pspal# = psunld;
         psstp1 = 0;
         psstp2 = 0;
         pspcs = 0;
         pscube = 0;
         psswgt = 0;
         psbcnt = 0;
750cD    //psflag = '';
750cD    psflag = '1';
         pslbl# = 0;
         pstrn# = 0;
         pscomp = '';
         pstzon = '';
         pspzon = '';
         psszon = '';

         // All other fields come from record read above

         write psrec;

         // Create DDDETAIL Location record;

         clear dddrec;
         dddwhse = pWhse;
         dddrtid = pRtid;
         dddsnap = 0;
         dddid = 'olr' + %char(psrow) + 'c' + %char(pscol);
         dddpid = 'or0c0';
         dddgroup = 'O';
         dddlevel = LOCATIONLVL;
         dddrow = psrow;
         dddcol = pscol;
         dddgen = psgen;
         ddduseq = psunld;

         write dddrec1;

         newOvfDrop = *on;

       endif;

       // Get DDDETAIL record for drop id

       if pDropId = 'grpO' or pDropId = 'olr0c0';
         chain(n) (pWhse:  prtid: 0: dddid) dddetail dropSent;
       else;
         chain(n) (pWhse:  prtid: 0: pDropId) dddetail dropSent;
       endif;

       // Get out if drop id not found

       if not %found(dddetail);
         error = *on;
740dM    //if pDropId = 'ovfloc';
740dM    if pDropId = 'grpO' or pDropId = 'olr0c0';
740cA      errmsg = dropStr;
740cM      errmsg += 'Record not found for drop id olr0c0';
         else;
740cA      errmsg = dropStr;
740cM      errmsg += 'Record not found for drop id ' + pDropId;
         endif;
         return;
       endif;

       // Save sent drop information

       if dropSent.dddlevel = PALLETLVL;
         droppedOnPlt = *on;
         dropPlt = dropSent;
         chain(n) (pWhse:  prtid: 0: dropSent.dddpid) dddetail dropLoc;
         if not %found(dddetail);
           error = *on;
740cA      errmsg = dropStr;
740cM      errmsg += 'Record not found for drop location ' + dropSent.dddpid;
           return;
         endif;
       else;
         droppedOnLoc = *on;
         dropLoc = dropSent;
       endif;

       // Add location to list for rebuilding

       locCount += 1;
       %occur(locList) = locCount;
       locList.group = dropLoc.dddgroup;
       locList.row = dropLoc.dddrow;
       locList.col = dropLoc.dddcol;
       locList.id  = dropLoc.dddid;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetMaxPltStops   Get maximum number of pallets allowed on Stop
     *----------------------------------------------------------------

     p GetMaxPltStops  b
     d GetMaxPltStops  pi             2s 0
720cAd  truckTemplate                      const like(lwtruk)
     d  zone                               const like(dddtzon)

      /free

740fA  // No longer checking Maximum Stops for a pallet.
740fA  // User is allowed to put as many Stops on a pallet as he wants.
740fA
740fA  return 0;

720cM  chain ('*PICK': pWhse: truckTemplate: zone) optionz;
       If not %found(optionz);
         opfstp = 99;
       endif;

       return opfstp;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetStopRange   Get Stop range
     *----------------------------------------------------------------

     p GetStopRange    b
     d GetStopRange    pi
     d  level                              const like(dddlevel)
     d  row                                const like(dddrow)
     d  col                                const like(dddcol)
     d  plid                               const like(dddplid)
     d  stp1                               like(psstp1)
     d  stp2                               like(psstp2)

     * Local Variables

     d  minStop        s              5i 0
     d  maxStop        s              5i 0


      /free

       stp1 = 0;
       stp2 = 0;
       minStop = 0;
       maxStop = 0;

       select;
         when level = LOCATIONLVL;

           exec sql select min(pssstp), max(pssstp) into :minStop, :maxStop
750aD               //from pltstp
750aM               from pltstp,pltsum
                   where psswhs = :pWhse
                     and pssrid = :pRtid
                     and pssrow = :row
                     and psscol = :col
750aA                and psswhs=pswhse and psspli=psplid
750bA                //and pssrid=psplid and psgen=1 and pstype='O';
750aA                and pssrid=psrtid and psgen=1;

           if sqlstt <> sqlSuccess;
             minStop = 0;
             maxStop = 0;
           endif;

         when level = PALLETLVL;

           exec sql select min(pssstp), max(pssstp) into :minStop, :maxStop
750aD               //from pltstp
750aM               from pltstp,pltsum
                   where psswhs = :pWhse
                     and pssrid = :pRtid
740gM                and psspli = :plid
                     and pssrow = :row
                     and psscol = :col
740gD              //  and psspli = :plid;
750aA                and psswhs=pswhse and psspli=psplid
750bA                //and pssrid=psplid and psgen=1 and pstype='O';
750bM                and pssrid=psrtid and psgen=1;

           if sqlstt <> sqlSuccess;
             minStop = 0;
             maxStop = 0;
           endif;

       endsl;

       stp1 = minStop;
       stp2 = maxStop;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetStopsOnPlt   Get number of stops on pallet
     *----------------------------------------------------------------

     p GetStopsOnPlt   b
     d GetStopsOnPlt   pi             2s 0
     d  group                              const like(dddgroup)
     d  row                                const like(dddrow)
     d  col                                const like(dddcol)
     d  plid                               const like(dddplid)

     * Local Variables

     d  stopCount      s              5i 0
     d  returnCount    s              2s 0

      /free

       // Note, this will not work if level 3 pallet sections are being used.
       // If a stop was on 2 pallet sections, it would be counted as 2 stops.

740eD  //exec sql select count(*) into :stopCount
740eD  //         from dddetail
740eD  //        where dddWhse = :pWhse
740eD  //          and dddrtid = :pRtid
740eD  //          and dddsnap = 0
740eD  //          and dddgroup = :group
740eD  //          and dddlevel = :STOPLVL
740eD  //          and dddrow = :row
740eD  //          and dddcol = :col
740eD  //          and dddplid = :plid;
740eA  // Change to dynamic query to control file name
740eA  if inRtnCode = 'LIVE';
740eA    dddfile = 'DDDETAIL';
740eA  else;
740eA    dddfile = 'DDDETAILH';
740eA  endif;
740eA  sqlstmt = 'select count(*) from' + %trim(dddfile) +
740eA            ' where dddwhse=' + %char(pwhse) + ' and ' +
740eA            'dddrtid=' + sq + %trim(prtid) + sq +
740eA            ' and dddsnap=0 and dddgroup=' + sq + %trim(group) + sq +
740eA            ' and dddlevl=' + %char(stoplvl) + ' and ' +
740eA            'dddrow=' + %char(row) + ' and dddcol=' + %char(col) +
740eA            ' and dddplid=' + %char(plid);
740eA  exec sql PREPARE sc FROM :SqlStmt;
740eA  exec sql DECLARE stpcn SCROLL CURSOR FOR sc;
740eA  exec sql OPEN stpcn;
740eA  exec sql fetch first from stpcn into :stopCount;

       if sqlstt <> sqlSuccess;
         stopCount = 99;
       endif;

740eA  exec sql CLOSE stpcn;

       if stopCount > 99;
         returnCount = 99;
       else;
         returnCount = stopCount;
       endif;

       return returnCount;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetTaskGrp    Get task group number to use for route
     *----------------------------------------------------------------

     p GetTaskGrp      b
     d GetTaskGrp      pi

      /free

       // ddtask1 - whse, rtid, ddtaskgrp, ddtype, ddseq

       setgt (pWhse: pRtid) ddtask1;
       readpe (pWhse: pRtid) ddtask1;
       if %eof(ddtask1);
         gTaskGrp = 1;
       else;
         if ddttaskgrp = 99999;
           gTaskGrp = ddttaskgrp;
         else;
           gTaskGrp = ddttaskgrp + 1;
         endif;
       endif;

      /end-free

     p                 e

720cA*----------------------------------------------------------------
720cA*  GetZoneMaxCube   Get maximum cube for zone
720cA*----------------------------------------------------------------
720cA
720cAp GetZoneMaxCube  b
720cAd GetZoneMaxCube  pi             5s 2
     d  truckTemplate                      const like(lwtruk)
     d  zone                               const like(dddtzon)

      /free

       if zone <> gCurOPTIONZ;
         GetOPTIONZ(truckTemplate: zone);
       endif;

       return opfcub;

      /end-free

     p                 e

720eA*----------------------------------------------------------------
720eA*  GetZoneMaxWgt    Get maximum weight for zone
720eA*----------------------------------------------------------------
720eA
720eAp GetZoneMaxWgt   b
720eAd GetZoneMaxWgt   pi             4s 0
     d  truckTemplate                      const like(lwtruk)
     d  zone                               const like(dddtzon)

      /free

       if zone <> gCurOPTIONZ;
         GetOPTIONZ(truckTemplate: zone);
       endif;

       return opfwgt;

      /end-free

     p                 e

720hA*----------------------------------------------------------------
720hA*  GetOPTIONZ       Get OPTIONZ record
720hA*----------------------------------------------------------------
720hA
720hAp GetOPTIONZ      b
720hAd GetOPTIONZ      pi
     d  truckTemplate                      const like(lwtruk)
     d  zone                               const like(dddtzon)

      /free

       if zone = gCurOPTIONZ;
         return;
       endif;

       gCurOPTIONZ = zone;

       chain ('*PICK': pWhse: truckTemplate: zone) optionz;
       If not %found(optionz);
         opfcub = 999;
         opfstp = 99;
         opford = 99;
         opfwgt = 0;
       endif;

       if opfwgtalpha = ' ';
         opfwgt = 0;
       endif;

      /end-free

     p                 e

720hA*----------------------------------------------------------------
720hA*  GetZoneOrdOpt    Get pallet per order option for zone
720hA*----------------------------------------------------------------
720hA
720hAp GetZoneOrdOpt   b
720hAd GetZoneOrdOpt   pi             1
     d  truckTemplate                      const like(lwtruk)
     d  zone                               const like(dddtzon)

      /free

       if zone <> gCurOPTIONZ;
         GetOPTIONZ(truckTemplate: zone);
       endif;

       if opford = 1;
         return 'Y';
       else;
         return 'N';
       endif;

      /end-free

     p                 e

750 A*----------------------------------------------------------------
750 A*  rmvPwrkFlds   Remove any extra flags from ddwrkflds
750 A*----------------------------------------------------------------

750 Ap rmvPwrkFlds     b
750 Ad rmvPwrkFlds     pi
750 Ad  pid                                like(dddid)

750 A* Local Variables

750 Ad  locdddrec      ds                  likerec(dddrec: *input)
750 Ad  wrkid          s                   like(dddid)
750 Ad  wrkgen         s                   like(psgen)

750 A /free

750 A    // Do not delete if more merges exist.  This is ran from the respective
750 A    // ProcessDrag procedure and the respective stop would have already been
750 A    // purged if it goes to zero.  For a stop we check to see if more than one
750 A    // truck zone is represented after the drag process.  If so we simply return
750 A    // becuase the merge icon will still need to be in place.
750 A    select;
750 A      when %subst(pid:1:1)='l';          // Label/Item
750 A        // for label/item allow it to fall to pallet query below to make
750 A        // sure pallet record in ddwrkflds is cleaned up if no mix zones remain
750 A      when %subst(pid:1:1)='s';          // Stop
750 A        cntFlgs=0;
750 A        exec sql select count(*) into :cntFlgs from
750 A                (select dddtzon,count(*) from dddetail
750 A                   where dddwhse=:pWhse and dddrtid=:pRtid and
750 A                         dddsnap=0 and dddpid=(select dddid from dddetail
750 A                   where dddwhse=:pWhse and dddrtid=:pRtid and
750 A                         dddsnap=0 and dddid=:pid)  group by dddtzon);
750 A        if cntFlgs > 1;
750 A          return;
750 A        endif;
750 A      when %subst(pid:1:2)='pl';          // pallet
750 A        // for pallet
750 A      other;
750 A        // we should simply return on any id other than a stop.  The stop and pallet
750 A        // are the only two ids with the icon to undo a unlike zone merge.  A stop
750 A        // would be removed with the sql below where it deletes using wrkid.
750 A        // Pallet would be removed with final sql below.
750 A        return;
750 A    endsl;
750 A
750 A    wrkid = pid;
750 A    // get the row and column from ddwrkflds for further use below.
750 A    // if this id is not found in ddwrkflds then return
750 A    if %subst(wrkid:1:1) = 's';    // process next sql's for stop id only
750 A      exec sql select ddwrow,ddwcol,dddgen into :wrkrow, :wrkcol, :wrkgen
750 A                    from ddwrkflds, dddetail
750 A              where ddwwhse=:pWhse and ddwrtid=:pRtid and
750 A                    ddwsnap=0 and ddwid=:pid and
750 A                 ddwwhse=dddwhse and ddwrtid=dddrtid and
750 A                 ddwsnap=dddsnap and ddwid=dddid;
750 A      if sqlstt <> '00000';
750 A        // if no record exist for this id we should return
750 A        return;
750 A      endif;
750 A
750 A      // at this point we know this is a stop id, it exists in
750 A      // ddwrkflds, there is only one zone remaining, and that
750 A      // one zone matches the labels zones found in that location
750 A      // in pltsum2
750 A      exec sql delete from ddWrkFlds
750 A               where ddwwhse=:pWhse and ddwrtid=:pRtid and
750 A                     ddwsnap=0 and ddwid=:wrkid and
750 A              (select pstzon from pltsum2 where pswhse=:pWhse
750 A                and psrtid=:pRtid and pstype='O' and psgen=:wrkgen and
750 A                    psrow=:wrkrow and pscol=:wrkcol)
750 A               =(select distinct(dddtzon) from dddetail
750 A                 where dddwhse=:pWhse and dddrtid=:pRtid and
750 A                       dddsnap=0 and dddpid=:wrkid);
750 A    endif;   // no label/item
750 A
750 A    // since we purged a stop just above this sql will check to
750 A    // see if any pallet record exist in ddwrkflds which has no
750 A    // supporting stop records any longer and purge if necessary
750 A    exec sql delete from ddwrkflds as pl
750 A             where substring(ddwid,1,2)='pl' and
750 A             pl.ddwrow=:wrkrow and pl.ddwcol=:wrkcol and
750 A             (select count(*) from ddwrkflds as stp
750 A             where pl.ddwwhse=stp.ddwwhse and pl.ddwrtid=stp.ddwrtid
750 A             and pl.ddwsnap=stp.ddwsnap and pl.ddwrow=stp.ddwrow and
750 A             pl.ddwcol=stp.ddwcol and substring(stp.ddwid,1,1)='s'
750 A             )=0;
750 A /end-free
750 Ap                 e

     *----------------------------------------------------------------
     *  ProcessDragIds   Process Drag Ids
     *----------------------------------------------------------------

     p ProcessDragIds  b
     d ProcessDragIds  pi

     * Local Variables

     d  locdddrec      ds                  likerec(dddrec: *input)
     d  i              s              5  0
     d  pos            s              5  0
     d  start          s              5  0
     d  dragIdsLen     s              5  0
     d  idLen          s              5  0
     d  id             s             20
     d  pcs            s                   like(dddpcs)
     d  cube           s                   like(dddcube)
     d  wgt            s                   like(dddwgt)
     d  palletDeleted  s               n
     d  diffGroupds    s               n
     d  ttlpcs         s                   like(dddpcs)
     d  ttlcube        s                   like(dddcube)
     d  ttlwgt         s                   like(dddwgt)

      /free


750 A  // zoneDiffer used to determine if more than one zone exist
750 A  // on specific pallet id on specific location
750 A  zoneDiffer = *off;
750 A  dragDropPltsm = ddPltSame();

       // Make sure drag id's are not being dropped onto their own location
       // For a SPLIT, id must be an item.

       for i = 1 to dragCount;

         %occur(dragList) = i;

         chain(n) (pWhse:  prtid: 0: dragList.id) dddetail locdddrec;
         if not %found(dddetail);
           error = *on;
740cA      errmsg = dropStr;
740cM      errmsg += 'Record not found for dragged id ' + dragList.id;
           return;
         endif;

750 A    // set Allow Same Location Drop flag to control whether user can
750 A    // drag different zones to different zones without receiving error
750 A    // cannot make this move
750 A    alwSameLocDrp = *off;
750 A    if (zoneMergeOpt='S' or zoneMergeOpt='M') and
750 A        locdddrec.dddtzon <> dropSent.dddTzon;
750 A      alwSameLocDrp = *on;
750 A    endif;

         if locdddrec.dddgroup = dropLoc.dddgroup
750 A      and locdddrec.dddrow = dropLoc.dddrow
750 A      and locdddrec.DDDCOL = dropLoc.dddcol
750 A      // do not display this message if performing an undo
750 A      // of a merge of unlike zones, or user not allowed
750 A      // to perform Same Location Drop
750 A      and pCmd <> 'DROPU' and not alwSameLocDrp;
             error = *on;
740cA        errmsg = dropStr;
740cM        errmsg += 'Not allowed to drop on selected location '
                    +'(' + %trimr(dragList.id) + ')';
             return;
         endif;

         if pCmd = 'SPLIT' and locdddrec.dddlevel <> ITEMLVL;
             error = *on;
740cA        errmsg = dropStr;
740cM        errmsg += 'Split not allowed for a';
             select;
               when locdddrec.dddlevel = GROUPLVL;
                 errmsg += ' group';
               when locdddrec.dddlevel = LOCATIONLVL;
                 errmsg += ' location';
               when locdddrec.dddlevel = PALLETLVL;
                 errmsg += ' pallet';
               when locdddrec.dddlevel = PLTSECTLVL;
                 errmsg += ' pallet section';
               when locdddrec.dddlevel = STOPLVL;
                 errmsg += ' stop';
               when locdddrec.dddlevel = TOTEITEMLVL;
                 errmsg += ' tote item';
               other;
                 errmsg += ' non-item';
             endsl;
             errmsg += ' (' + %trimr(dragList.id) + ')';
             return;
         endif;

       endfor;

       for i = 1 to dragCount;

         %occur(dragList) = i;

         chain(n) (pWhse:  prtid: 0: dragList.id) dddetail locdddrec;
         if not %found(dddetail);
           iter;
         endif;

         dragId = locdddrec;

750 A    // loop through dragList and determine if all the draglist id's
750 A    // are on the same row/col as the dropid.  This is used in CRTPARENT
750 A    // to determine if we should iter when finding the same pallet that
750 A    // we dragged from when merging onto another zone manually

         ProcessDrag1 (locdddrec.dddlevel: locdddrec);

         if error;
           return;
         endif;

       endfor;

       // Once everything has been processed, update pallet numbers

       or627(pWhse: pRtid);
750 A  zoneMergeOpt = saveMergeOpt;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ProcessDrag1    Process Dragged location (Lvl 1) record
     *----------------------------------------------------------------

     p ProcessDrag1    b

     * Local Files

740eDF*dddetail1 uf   e           k disk
740eMFdddetail1 uf   e           k disk    extfile(dddfile)

     d ProcessDrag1    pi
     d  dragLevel                          like(dddlevel)
     d  indddrec                           const likerec(dddrec: *input)

     * Local File Data Structures

     d locdddrec       ds                  likerec(dddrec: *input)

     * Local Variables

     d  i              s              5  0
     d pcs             s                   like(dddpcs)
     d cube            s                   like(dddcube)
     d wgt             s                   like(dddwgt)
     d palletDeleted   s               n
     d exists          s               n
     d minStop         s                   like(psstp1)
     d maxStop         s                   like(psstp2)
     d ttlPcs          s                   like(dddpcs)
     d ttlCube         s                   like(dddcube)
     d ttlWgt          s                   like(dddwgt)

      /free

       ttlPcs = 0;
       ttlCube = 0;
       ttlWgt = 0;

       // Get location (Lvl 1) record

       setll (pWhse: pRtid: 0: indddrec.dddgroup: LOCATIONLVL:
              indddrec.dddrow: indddrec.dddcol) dddetail1;

       dow forever = forever;

         reade (pWhse: pRtid: 0: indddrec.dddgroup: LOCATIONLVL:
                indddrec.dddrow: indddrec.dddcol) dddetail1 locdddrec;

         if %eof(dddetail1);
           leave;
         endif;

750eA    RCTzon = indddrec.dddtzon;
750 A    // If from and to location are the same force zoneMergeOpt to allow merges
750 A    if pCmd<>'DROPU';
750 A      if locdddrec.dddid = dropLoc.dddid;
750 A        zoneMergeOpt = 'M';
750 A      endif;
750 A    endif;

         // Process pallet for location

         ProcessDrag2 (dragLevel: locdddrec: pcs: cube: wgt: palletDeleted);
750 A    if zoneDiffer;
750 A      addMrgFlgs(dropplt);
750 A    endif;

         if error;
           unlock dddetail1;
           return;
         endif;

         // Update totals to pass back

         ttlPcs += pcs;
         ttlCube += cube;
         ttlWgt += wgt;

         // Add location to list for rebuilding

         exists = *off;
         for i = 1 to locCount;
           %occur(locList) = i;
           if locList.id = locdddrec.dddid;
             exists = *on;
             leave;
           endif;
         endfor;
         if not exists;
           locCount += 1;
           %occur(locList) = locCount;
           locList.group = locdddrec.dddgroup;
           locList.row = locdddrec.dddrow;
           locList.col = locdddrec.dddcol;
           locList.id = locdddrec.dddid;
         endif;

         // Reduce totals

         if pcs > locdddrec.dddpcs;
           locdddrec.dddpcs = 0;
         else;
           locdddrec.dddpcs -= pcs;
         endif;

         if cube > locdddrec.dddcube;
           locdddrec.dddpcs = 0;
         else;
           locdddrec.dddcube -= cube;
         endif;

         if wgt > locdddrec.dddwgt;
           locdddrec.dddpcs = 0;
         else;
           locdddrec.dddwgt -= wgt;
         endif;

         // Reduce DDDETAIL location record
         // Delete location overflow record when empty

         if locdddrec.dddpcs = 0 and locdddrec.dddgroup = 'O';
           delete dddrec;
         else;
           GetStopRange(locdddrec.dddlevel: locdddrec.dddrow: locdddrec.dddcol:
                       locdddrec.dddplid: minStop: maxStop);
           locdddrec.dddstp1 = minStop;
           locdddrec.dddstp2 = maxStop;
           update dddrec locdddrec;
         endif;

         // Reduce dragged PLTSUM location summary record
         // Delete PLTSUM overflow location record when empty

         chain (pWhse: pRtid: 'O':
                locdddrec.dddgen: locdddrec.dddrow: locdddrec.dddcol) pltsum2;
         if %found(pltsum2);
           pspcs -= pcs;
           pscube -= cube;
           psswgt -= wgt;
           if palletDeleted;
             psbcnt -= 1;
           endif;
           if pspcs <= 0 and locdddrec.dddgroup = 'O';
             delete psrec;
           else;
             psstp1 = locdddrec.dddstp1;
             psstp2 = locdddrec.dddstp2;
             update psrec;
           endif;
         endif;

         // Increase drop PLTSUM location summary record

         chain (pWhse: pRtid: 'O':
                dropStp.dddgen: dropStp.dddrow: dropStp.dddcol) pltsum2;
         if %found(pltsum2);
           pspcs += pcs;
           pscube += cube;
           psswgt += wgt;
           if pstzon = '';
             pscomp = gSavedComp;
             pstzon = gSavedTZon;
             pspzon = gSavedPZon;
             psszon = gSavedSZon;
           endif;
           GetStopRange(locdddrec.dddlevel: psrow: pscol: psplid:
                        psstp1: psstp2);
           update psrec;
         endif;

       enddo;

       // If new overflow drop, update compartment and zones

       if newOvfDrop;

         setll (pWhse: pRtid: 0: dropLoc.dddgroup: LOCATIONLVL:
                dropLoc.dddrow: dropLoc.dddcol) dddetail1;

         reade (pWhse: pRtid: 0: dropLoc.dddgroup: LOCATIONLVL:
                dropLoc.dddrow: dropLoc.dddcol) dddetail1 locdddrec;

         if not %eof(dddetail1);
           locdddrec.dddcomp = gSavedComp;
           locdddrec.dddtzon = gSavedTZon;
           locdddrec.dddpzon = gSavedPZon;
           locdddrec.dddszon = gSavedSZon;
           update dddrec locdddrec;
         endif;

       endif;

       // Done processing pallet for location
       // If we didn't drag to different group, we're done

       if locdddrec.dddgroup = dropLoc.dddgroup;
         return;
       endif;

       // Otherwise, update group totals

       // Update drag group

       setll (pWhse: pRtid: 0: locdddrec.dddgroup: 0) dddetail1;
       reade (pWhse: pRtid: 0: locdddrec.dddgroup: 0) dddetail1 locdddrec;

       if not %eof(dddetail1);

         if ttlpcs > locdddrec.dddpcs;
           locdddrec.dddpcs = 0;
         else;
           locdddrec.dddpcs -= ttlpcs;
         endif;

         if ttlcube > locdddrec.dddcube;
           locdddrec.dddpcs = 0;
         else;
           locdddrec.dddcube -= ttlcube;
         endif;

         if ttlwgt > locdddrec.dddwgt;
           locdddrec.dddpcs = 0;
         else;
           locdddrec.dddwgt -= ttlwgt;
         endif;

         update dddrec locdddrec;

       endif;

       // Update drop group

       setll (pWhse: pRtid: 0: dropLoc.dddgroup: 0) dddetail1;
       reade (pWhse: pRtid: 0: dropLoc.dddgroup: 0) dddetail1 locdddrec;

       if not %eof(dddetail1);
         locdddrec.dddpcs += ttlpcs;
         locdddrec.dddcube += ttlcube;
         locdddrec.dddwgt += ttlwgt;
         update dddrec locdddrec;
       endif;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ProcessDrag2    Process Dragged pallet (Lvl 2) record(s)
     *----------------------------------------------------------------

     p ProcessDrag2    b

     * Local Files

740eDF*dddetail1 uf   e           k disk
740eMFdddetail1 uf   e           k disk    extfile(dddfile)

     d ProcessDrag2    pi
     d  dragLevel                          like(dddlevel)
     d  indddrec                           const likerec(dddrec: *input)
     d  rtnPcs                             like(dddpcs)
     d  rtnCube                            like(dddcube)
     d  rtnWgt                             like(dddwgt)
     d  palletDeleted                  n

     * Local File Data Structures

     d locdddrec       ds                  likerec(dddrec: *input)

     * Local Variables

     d pcs             s                   like(dddpcs)
     d cube            s                   like(dddcube)
     d wgt             s                   like(dddwgt)
     d minStop         s                   like(psstp1)
     d maxStop         s                   like(psstp2)
     d first           s               n
750 Ad  wrkid          s                   like(dddid)

      /free

       first = *on;

       rtnPcs = 0;
       rtnCube = 0;
       rtnWgt = 0;

       // Loop through pallet (lvl 2) records for location
       // Only work with specific pallet if dragLevel is 2+

       if dragLevel >= PALLETLVL;
         setll (pWhse: pRtid: 0: indddrec.dddgroup: PALLETLVL:
                indddrec.dddrow: indddrec.dddcol:
                dragId.dddplid) dddetail1;
       else;
         setll (pWhse: pRtid: 0: indddrec.dddgroup: PALLETLVL:
                indddrec.dddrow: indddrec.dddcol) dddetail1;
       endif;

       dow forever = forever;

         if dragLevel >= PALLETLVL;
           reade (pWhse: pRtid: 0: indddrec.dddgroup: PALLETLVL:
                  indddrec.dddrow: indddrec.dddcol:
                  dragId.dddplid) dddetail1 locdddrec;
         else;
           reade (pWhse: pRtid: 0: indddrec.dddgroup: PALLETLVL:
                  indddrec.dddrow: indddrec.dddcol) dddetail1 locdddrec;
         endif;

         if %eof(dddetail1);
           leave;
         endif;

         if first;
           first = *off;
           gSavedComp = locdddrec.dddcomp;
           gSavedTZon = locdddrec.dddtzon;
           gSavedPZon = locdddrec.dddpzon;
           gSavedSZon = locdddrec.dddszon;
750 A      gSavedid   = locdddrec.dddid;
         endif;

         // Process stops for pallet
         // Not using level 3 (pallet section) at this time

         ProcessDrag4 (dragLevel: locdddrec: pcs: cube: wgt);

         if error;
           unlock dddetail1;
           return;
         endif;

         // Update totals to pass back

         rtnPcs += pcs;
         rtnCube += cube;
         rtnWgt += wgt;

         // Reduce totals

         if pcs > locdddrec.dddpcs;
           locdddrec.dddpcs = 0;
         else;
           locdddrec.dddpcs -= pcs;
         endif;

         if cube > locdddrec.dddcube;
           locdddrec.dddcube = 0;
         else;
           locdddrec.dddcube -= cube;
         endif;

         if wgt > locdddrec.dddwgt;
           locdddrec.dddwgt = 0;
         else;
           locdddrec.dddwgt -= wgt;
         endif;

         // Reduce DDDETAIL pallet record
         // Delete pallet record when empty

         if locdddrec.dddpcs = 0;
750 A      // Delete Extra Flags record if it exist
750 A      exWhse = pWhse;
750 A      wrkRtid= pRtid;
750 A      wrkmrg = ' ';
750 A      wrkspin = ' ';
750 A      wrkrow = locdddrec.dddrow;
750 A      wrkcol = locdddrec.dddcol;
750 A      wrkid = locdddrec.dddid;
750 A      ddwrkflds ('*DELETE': exRtnCode: exRtnMsg: exWhse: wrkRtid:
750 A                  locdddrec.dddsnap: wrkid: wrkrow:
750 A                  wrkcol: wrkmrg: wrkspin);
           delete dddrec;
         else;
750 A      rmvPwrkFlds(locdddrec.dddid);
           GetStopRange(locdddrec.dddlevel: locdddrec.dddrow: locdddrec.dddcol:
                       locdddrec.dddplid: minStop: maxStop);
           locdddrec.dddstp1 = minStop;
           locdddrec.dddstp2 = maxStop;
           update dddrec locdddrec;
         endif;

         // Reduce dragged PLTSUM pallet record, delete when empty

         setll (pWhse: pRtid: 'P':
                locdddrec.dddgen: locdddrec.dddrow: locdddrec.dddcol) pltsum2;
         dow forever = forever;
           reade (pWhse: pRtid: 'P':
                  locdddrec.dddgen: locdddrec.dddrow: locdddrec.dddcol) pltsum2;
           if %eof(pltsum2);
             leave;
           endif;
           if psplid <> locdddrec.dddplid;
             iter;
           endif;
           pspcs -= pcs;
           pscube -= cube;
           psswgt -= wgt;
           if pspcs <= 0;
             delete psrec;
             palletDeleted = *on;
           else;
             psstp1 = locdddrec.dddstp1;
             psstp2 = locdddrec.dddstp2;
             update psrec;
             palletDeleted = *off;
           endif;
         enddo;


         // Increase drop PLTSUM pallet record

         setll (pWhse: pRtid: 'P':
                dropStp.dddgen: dropStp.dddrow: dropStp.dddcol) pltsum2;
         dow forever = forever;
           reade (pWhse: pRtid: 'P':
                 dropStp.dddgen: dropStp.dddrow: dropStp.dddcol) pltsum2;
           if %eof(pltsum2);
             leave;
           endif;
           if psplid <> dropStp.dddplid;
             iter;
           endif;
           pspcs += pcs;
           pscube += cube;
           psswgt += wgt;
           GetStopRange(locdddrec.dddlevel: psrow: pscol: psplid:
                        psstp1: psstp2);
           update psrec;
         enddo;

       enddo;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ProcessDrag4    Process Dragged stop (Lvl 4) record(s)
     *----------------------------------------------------------------

     p ProcessDrag4    b

     * Local Files

740eDF*dddetail1 uf   e           k disk
740eMFdddetail1 uf   e           k disk    extfile(dddfile)

     d ProcessDrag4    pi
     d  dragLevel                          like(dddlevel)
     d  indddrec                           const likerec(dddrec: *input)
     d  rtnPcs                             like(dddpcs)
     d  rtnCube                            like(dddcube)
     d  rtnWgt                             like(dddwgt)
750 Ad  wrkid          s                   like(dddid)

     * Local File Data Structures

     d locdddrec       ds                  likerec(dddrec: *input)

     * Local Variables

     d pcs             s                   like(dddpcs)
     d cube            s                   like(dddcube)
     d wgt             s                   like(dddwgt)

      /free

       rtnPcs = 0;
       rtnCube = 0;
       rtnWgt = 0;

       // Loop through stop (lvl 4) records for pallet
       // Only work with specific pallet if dragLevel is 4+

       if dragLevel >= STOPLVL;
         setll (pWhse: pRtid: 0: indddrec.dddgroup: STOPLVL:
                indddrec.dddrow: indddrec.dddcol:
                indddrec.dddplid: indddrec.dddpltsct:
                dragId.dddstop: dragId.ddddrop) dddetail1;
       else;
         setll (pWhse: pRtid: 0: indddrec.dddgroup: STOPLVL:
                indddrec.dddrow: indddrec.dddcol:
                indddrec.dddplid) dddetail1;
       endif;

       dow forever = forever;

         if dragLevel >= STOPLVL;
           reade (pWhse: pRtid: 0: indddrec.dddgroup: STOPLVL:
                  indddrec.dddrow: indddrec.dddcol:
                  indddrec.dddplid: indddrec.dddpltsct:
                  dragId.dddstop: dragId.ddddrop) dddetail1 locdddrec;
         else;
           reade (pWhse: pRtid: 0: indddrec.dddgroup: STOPLVL:
                  indddrec.dddrow: indddrec.dddcol:
                  indddrec.dddplid) dddetail1 locdddrec;
         endif;

         if %eof(dddetail1);
           leave;
         endif;

         // Process items for stop

         ProcessDrag5 (dragLevel: locdddrec: pcs: cube: wgt);
         if error;
           unlock dddetail1;
           return;
         endif;

         // Note: Call to DD410 will update dddstpsplt flag

         // Update level totals to pass back

         rtnPcs += pcs;
         rtnCube += cube;
         rtnWgt += wgt;

         // Reduce totals

         if pcs > locdddrec.dddpcs;
           locdddrec.dddpcs = 0;
         else;
           locdddrec.dddpcs -= pcs;
         endif;

         if cube > locdddrec.dddcube;
           locdddrec.dddcube = 0;
         else;
           locdddrec.dddcube -= cube;
         endif;

         if wgt > locdddrec.dddwgt;
           locdddrec.dddwgt = 0;
         else;
           locdddrec.dddwgt -= wgt;
         endif;

         // Reduce DDDETAIL stop record
         // Delete stop record when empty

         if locdddrec.dddpcs = 0;
750 A      // Delete Extra Flags record if it exist
750 A      exWhse = pWhse;
750 A      wrkRtid= pRtid;
750 A      wrkmrg = ' ';
750 A      wrkspin = ' ';
750 A      wrkrow = locdddrec.dddrow;
750 A      wrkcol = locdddrec.dddcol;
750 A      wrkid = locdddrec.dddid;
750 A      ddwrkflds ('*DELETE': exRtnCode: exRtnMsg: exWhse: wrkRtid:
750 A                  locdddrec.dddsnap: wrkid: wrkrow:
750 A                  wrkcol: wrkmrg: wrkspin);
           delete dddrec;
         else;
           //if pCmd = 'SPLIT';
           //  locdddrec.dddstpsplt = 1;
           //endif;
750 A      rmvPwrkFlds(locdddrec.dddid);
           update dddrec locdddrec;
         endif;

         // Reduce dragged pallet PLTSTP rec

         dsplid = locdddrec.dddplid;

         chain (pWhse: pRtid: locdddrec.dddplid: locdddrec.dddrow:
                locdddrec.dddcol: locdddrec.dddstop: dsplsq) pltstp1;


         if %found(pltstp1);

           psspcs -= pcs;
           psscub -= cube;
           pssswt -= wgt;

           // Delete record when empty

           if psspcs <= 0;
             delete pssrec;
           else;
             update pssrec;
           endif;

         endif;


         // Reduce dragged location PLTSTP rec

         dsplid = locdddrec.dddplid;
         dsplsq = 0;

         chain (pWhse: pRtid: dsplid: locdddrec.dddrow:
                locdddrec.dddcol: locdddrec.dddstop: dsplsq) pltstp1;


         if %found(pltstp1);

           psspcs -= pcs;
           psscub -= cube;
           pssswt -= wgt;

           // Delete record when empty

           if psspcs <= 0;
             delete pssrec;
           else;
             update pssrec;
           endif;

         endif;

750 A    // Apply Merge icon if differe zones merged on stop
750 A    if zoneDiffer;
750 A      addMrgFlgs(dropStp);
750 A    endif;

         // Increase drop pallet PLTSTP rec, create if not found

         dsplid = dropStp.dddplid;

         chain (pWhse: pRtid: dropStp.dddplid: dropStp.dddrow:
                dropStp.dddcol: dropStp.dddstop: dsplsq) pltstp1;

         if not %found(pltstp1);

           psswhs = pWhse;
           pssrid = pRtid;
           pssrow = dropStp.dddrow;
           psscol = dropStp.dddcol;
           pssstp = dropStp.dddstop;
           psspli = dropStp.dddplid;
           pssbsq = dsplsq;
           psspcs = pcs;
           psscub = cube;
           pssswt = wgt;
           write pssrec;

         else;

           psspcs += pcs;
           psscub += cube;
           pssswt += wgt;
           update pssrec;

         endif;

         // Increase drop location PLTSTP rec, create if not found

         dsplid = dropStp.dddplid;
         dsplsq = 0;

         chain (pWhse: pRtid: dsplid: dropStp.dddrow:
                dropStp.dddcol: dropStp.dddstop: dsplsq) pltstp1;

         if not %found(pltstp1);

           psswhs = pWhse;
           pssrid = pRtid;
           pssrow = dropStp.dddrow;
           psscol = dropStp.dddcol;
           pssstp = dropStp.dddstop;
           psspli = dsplid;
           pssbsq = dsplsq;
           psspcs = pcs;
           psscub = cube;
           pssswt = wgt;
           write pssrec;

         else;

           psspcs += pcs;
           psscub += cube;
           pssswt += wgt;
           update pssrec;

         endif;


       enddo;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ProcessDrag5    Process Dragged item (Lvl 5) record(s)
     *----------------------------------------------------------------

     p ProcessDrag5    b

     * Local Files

740eDF*dddetail1 uf a e           k disk
740eMFdddetail1 uf a e           k disk    extfile(dddfile)

     d ProcessDrag5    pi
     d  dragLevel                          like(dddlevel)
     d  indddrec                           const likerec(dddrec: *input)
     d  rtnPcs                             like(dddpcs)
     d  rtnCube                            like(dddcube)
     d  rtnWgt                             like(dddwgt)

     * Local File Data Structures

     d locdddrec       ds                  likerec(dddrec: *input)
     d locdddrecout    ds                  likerec(dddrec: *output)

     * Local Variables

     d pcs             s                   like(dddpcs)
     d cube            s                   like(dddcube)
     d wgt             s                   like(dddwgt)
     d first           s               n
750dAd lastTzon        s              6


      /free

       rtnPcs = 0;
       rtnCube = 0;
       rtnWgt = 0;

       first = *on;

       // Loop through item (lvl 5) records for stop
       // Only work with specific pallet if dragLevel is 5+

       if dragLevel >= ITEMLVL;
         setll (pWhse: pRtid: 0: indddrec.dddgroup: ITEMLVL:
                indddrec.dddrow: indddrec.dddcol:
                indddrec.dddplid: indddrec.dddpltsct:
                indddrec.dddstop: indddrec.ddddrop:
                dragId.DDDITMTYP: dragId.DDDLBLTOT:
                dragId.DDDLBLITM) dddetail1;
       else;
         setll (pWhse: pRtid: 0: indddrec.dddgroup: ITEMLVL:
                indddrec.dddrow: indddrec.dddcol:
                indddrec.dddplid: indddrec.dddpltsct:
                indddrec.dddstop: indddrec.ddddrop) dddetail1;
       endif;

       dow forever = forever;

         if dragLevel >= ITEMLVL;
           reade (pWhse: pRtid: 0: indddrec.dddgroup: ITEMLVL:
                  indddrec.dddrow: indddrec.dddcol:
                  indddrec.dddplid: indddrec.dddpltsct:
                  indddrec.dddstop: indddrec.ddddrop:
                  dragId.DDDITMTYP: dragId.DDDLBLTOT:
                  dragId.DDDLBLITM) dddetail1 locdddrec;
         else;
           reade (pWhse: pRtid: 0: indddrec.dddgroup: ITEMLVL:
                  indddrec.dddrow: indddrec.dddcol:
                  indddrec.dddplid: indddrec.dddpltsct:
                  indddrec.dddstop: indddrec.ddddrop) dddetail1 locdddrec;
         endif;

         if %eof(dddetail1);
           leave;
         endif;

         // Make sure WORKLBL record exists

         chain(n) (locdddrec.dddlblitm) worklbl;

         if not %found(worklbl);
           error = *on;
740cA      errmsg = dropStr;
740cM      errmsg += 'WORKLBL record not found for '
                  + 'label ' + %char(locdddrec.dddlblitm) + ', '
                  + 'id ' + dropSent.dddid;
           unlock dddetail1;
           return;
         endif;

         // Update totals to pass back

         if pCmd = 'SPLIT';
           gSplitCube = gSplitPcs * lwucub;
           gSplitWgt = gSplitPcs * lwuwgt;
           rtnPcs += gSplitPcs;
           rtnCube += gSplitCube;
           rtnWgt += gSplitWgt;
         else;
           rtnPcs += locdddrec.dddpcs;
           rtnCube += locdddrec.dddcube;
           rtnWgt += locdddrec.dddwgt;
         endif;

750 A    //if pCmd='DROPU';
750 A      wrkcomp = locdddrec.dddcomp;
750 A      wrktzon = locdddrec.dddtzon;
750 A      wrkpzon = locdddrec.dddpzon;
750 A      wrkszon = locdddrec.dddszon;
750 A    //endif;

         // Make sure parent records exist for drop area
         // This will create any necessary DDDETAIL/PLTSUM/PLTSTP records

         if first;
           first = *off;
750eD      //lastTzon = lwtzon;
720cM      CrtParentRecs(lwtruk: locdddrec);
           if error;
             unlock dddetail1;
             return;
           endif;
750dA    else;
750eD      //if lwtzon <> lastTzon
750eM      if lwtzon <> RCTzon
750eA        and zoneDiffer = *off;
750eD        //lastTzon = lwtzon;
750dA        // ** zoneDiffer variable is used to determine if a record for this
750dA        // id should be added to ddwrkflds.  This file is used in dd410 and dd420
750dA        // to determine if the merge icon should be displayed to undo the merges
750dA
750dA        select;
750dA          when zoneMergeOpt = 'N';
750dA            // no merging of pallets allowed
750dA            zoneDiffer = *off;
750dA          when zoneMergeOpt = 'S';
750dA            // still separate from automatic perspective
750dA            // but identify
750dA            zoneDiffer = *off;
750dA          when zoneMergeOpt = 'M';
750dA            // automatically merge pallets
750dA            zoneDiffer = *on;
750dA        endsl;
           endif;
         endif;

         // Update WORKLBL record

         chain (locdddrec.dddlblitm) worklbl;

         if not %found(worklbl);
           error = *on;
740cA      errmsg = dropStr;
740cM      errmsg += 'WORKLBL(2) record not found for '
                  + 'label ' + %char(locdddrec.dddlblitm) + ', '
                  + 'id ' + dropSent.dddid;
           unlock dddetail1;
           return;
         endif;

         // For a split, reduce pcs, cube, wgt of existing label
         // Otherwise, change pallet id to new pallet id

         if pCmd = 'SPLIT';
           lwqalc -= gSplitPcs;
           lwcube -= gSplitCube;
           lwswgt -= gSplitWgt;
         else;
           lwpal# = dropStp.dddplid;
         endif;
         update lwrec;

         // For a split, create new worklbl record for split

         if pCmd = 'SPLIT';
           lwqalc = gSplitPcs;
           lwcube = gSplitCube;
           lwswgt = gSplitWgt;
           lwpal# = dropStp.dddplid;
           pirlbl#(lwlbl#);
           write lwrec;
         endif;

         // For a split, reduce pcs, cube, wgt of existing DDDETAIL
         // Otherwise, update DDDETAIL record with new location info

         if pCmd = 'SPLIT';
           locdddrec.dddpcs -= gSplitPcs;
           locdddrec.dddcube -= gSplitCube;
           locdddrec.dddwgt -= gSplitWgt;
           locdddrec.ddditmsplt = 1;
         else;
           locdddrec.dddpid = dropStp.dddid;
           locdddrec.dddgroup = dropStp.dddgroup;
           locdddrec.dddrow = dropStp.dddrow;
           locdddrec.dddcol = dropStp.dddcol;
           locdddrec.dddplid = dropStp.dddplid;
           locdddrec.dddpltsct = dropStp.dddpltsct;
         endif;
         update dddrec locdddrec;

         // For a split, create new DDDETAIL record for split

         if pCmd = 'SPLIT';
           locdddrec.dddid = 'lbl' + %char(lwlbl#);
           locdddrec.dddpcs = gSplitPcs;
           locdddrec.dddcube = gSplitCube;
           locdddrec.dddwgt = gSplitWgt;
           locdddrec.dddpid = dropStp.dddid;
           locdddrec.dddgroup = dropStp.dddgroup;
           locdddrec.dddrow = dropStp.dddrow;
           locdddrec.dddcol = dropStp.dddcol;
           locdddrec.dddplid = dropStp.dddplid;
           locdddrec.dddpltsct = dropStp.dddpltsct;
           locdddrec.ddditmsplt = 1;
           locdddrec.dddlblitm = lwlbl#;
           locdddrecout = locdddrec;
           write dddrec locdddrecout;
         endif;

         // If item is marked as a split, see if it can be combined with spilt already on pallet
         // This needs to be done after the update because record might get deleted

         if locdddrec.ddditmsplt = 1;
           CombineSplit();
         endif;

       enddo;

      /end-free

     p                 e

740bA*----------------------------------------------------------------
740bA*  SetRouteLock   Set route lock
740bA*----------------------------------------------------------------
740bA
740bAp SetRouteLock    b
     d SetRouteLock    pi

     * Local Variables

     D count           s              1  0
     D maxCount        s              1  0 inz(2)
     D msg             s             99    varying
740cAd pos             s              3  0

      /free

740cA  // Create drop location string for error messages
740cA
740cA  dropStr = 'Error dropping on ';
740cA
740cA  select;
740cA
740cA    when pDropId = 'grpO' or pDropId = 'olr0c0';
740cA      dropStr += 'Overflow Location';
740cA
740cA    when %subst(pDropId: 1: 1) = 'm' or %subst(pDropId: 1: 1) = 'l';
740cA      pos = %scan('c': pDropId);
740cA      if pos = 0;
740cA        dropStr += 'Loction ' + pDropId + ' (1)';
740cA      else;
740cA        dropStr += 'Location Row ' + %subst(pDropId: 3: pos-3) + ' ';
740cA        if %len(pDropId) = pos;
740cA          dropStr += 'Column ? (' + pDropId + ')';
740cA        else;
740cA          dropStr += 'Column ' + %subst(pDropId: pos+1);
740cA        endif;
740cA      endif;
740cA
740cA    other;
740cA      dropStr += 'Location ' + pDropId + ' (2)';
740cA
740cA    endsl;
740cA
740cA    dropStr += ' - ';

         count = 0;

         dou count = maxCount;

           count += 1;

           chain(e) (pWhse: pRtId) ddlock;

           select;

             when %status(ddlock) = recordLocked;
               if count = MaxCount;
                 error = *on;
                 errmsg = dropStr
                        + 'Previous drop has not completed';
                 leave;
               else;
                 ClearDDTREC();
                 ddtwhse = pWhse;
                 ddtrtid = prtid;
                 ddttype = 'DROPREQ';
                 ddtsubtype = 'WAIT';
                 ddttaskgrp = gTaskGrp;
                 ddtseq = 1;
                 ddtid = '';
                 ddtstr = 'Waiting for previous drop to complete';
                 write ddtrec;
                 iter;
               endif;

             when not %found(ddlock);

               ddlwhse = pWhse;
               ddlrtid = pRtId;
               ddlcmd  = pCmd;
               ddlpgm  = '';
               ddluser = pUser;
               ddlsessid = pSessId;
               GetCurrStamp();
               ddlts   = currstampsys;
               ddluc   = currstampuc;
               ddlcusr = #curruser;
               ddljusr = #user;
               ddljob  = #job;
               ddlnbr  = #jobnbr;

               write(e) ddlrec;
               if %error;
                 error = *on;
                 errmsg = dropStr
                        + 'Error creating drop lock';
                 leave;
               endif;

               // Turn around and lock record

               chain(e) (pWhse: pRtId) ddlock;
               if %error;
                 error = *on;
                 errmsg = dropStr
                        + 'Error getting lock (w)';
                 leave;
               endif;

               leave;


             when %found(ddlock);

               ddlcmd  = pCmd;
               ddlpgm  = '';
               ddluser = pUser;
               ddlsessid = pSessId;
               GetCurrStamp();
               ddlts   = currstampsys;
               ddluc   = currstampuc;
               ddlcusr = #curruser;
               ddljusr = #user;
               ddljob  = #job;
               ddlnbr  = #jobnbr;

               update(e) ddlrec;
               if %error;
                 error = *on;
                 errmsg = dropStr
                        + 'Error updating lock';
               endif;

               // Turn around and lock record

               chain(e) (pWhse: pRtId) ddlock;
               if %error;
                 error = *on;
                 errmsg = dropStr
                        + 'Error getting lock (u)';
                 leave;
               endif;

               leave;

           when %error;
             leave;

           endsl;

         enddo;

      /end-free

     p                 e

720aA*----------------------------------------------------------------
720aA*  UpdateLocComp  Update location compartment
720aA*----------------------------------------------------------------
720aA
720aAp UpdateLocComp   b
720aAd UpdateLocComp   pi

     * Local Variables

     d  locComp        s                   like(dddcomp)
     d  saveComp       s                   like(dddcomp)
     d  saveTZon       s                   like(dddtzon)
     d  savePZon       s                   like(dddpzon)
     d  saveSZon       s                   like(dddszon)
     d  compMatch      s               n
     d  palletCount    s              3  0

      /free

       // Loop through all touched Locations

       for i = 1 to locCount;

         %occur(locList) = i;

         // Get current compartment for Location

         chain(n) (pWhse:  prtid: 0: locList.id) dddetail;
         if not %found(dddetail);
           iter;
         endif;
         locComp = dddcomp;

         // Loop through pallets for Location

         palletCount = 0;
         compMatch = *off;
         saveComp = '';

         setll (pWhse: pRtid: 0: locList.group: PALLETLVL:
                locList.row: locList.col) dddetail1;

         dow forever = forever;

           reade(n) (pWhse: pRtid: 0: locList.group: PALLETLVL:
                     locList.row: locList.col) dddetail1;

           if %eof(dddetail1);
             leave;
           endif;

           // If Pallet compartment matches Location compartment, get out.

           if dddcomp = locComp;
             compMatch = *on;
             leave;
           endif;

           // Save first compartment

           palletCount += 1;

           // Save lowest alphabetical compartment

           if saveComp = '' or dddcomp < saveComp;
             saveComp = dddcomp;
             saveTZon = dddtzon;
             savePZon = dddpzon;
             saveSZon = dddszon;
           endif;

         enddo;

         // If no pallets exist for Location, move on to next Location

         if palletCount = 0;
           iter;
         endif;

         // If a compartment match was found, move on to next Location

         if compMatch;
           iter;
         endif;

         // Otherwise, update DDDETAIL Location compartment.

         chain (pWhse:  prtid: 0: locList.id) dddetail;
         if %found(dddetail);
           dddcomp = saveComp;
           dddtzon = saveTZon;
           dddpzon = savePZon;
           dddszon = saveSZon;
           update dddrec;
         endif;

         // And update PLTSUM Location compartment.

         chain (pWhse: pRtid: 'O':
                1: locList.row: locList.col) pltsum2;
         if %found(pltsum2);
           pscomp = saveComp;
           pstzon = saveTZon;
           pspzon = savePZon;
           psszon = saveSZon;
           update psrec;
         endif;

       endfor;


      /end-free

     p                 e

     *----------------------------------------------------------------
     *  WriteError    Write drop error to DDTASK file
     *----------------------------------------------------------------

     p WriteError      b
     d WriteError      pi

      /free

       ClearDDTREC();

       ddtwhse = pWhse;
       ddtrtid = prtid;
       ddttype = 'ERROR';
       ddtsubtype = '';
       ddttaskgrp = gTaskGrp;
       ddtseq = 1;
       ddtid = '';
       ddtstr = errmsg;

       write ddtrec;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  WriteRequest    Write drop request to DDTASK file
     *----------------------------------------------------------------

     p WriteRequest    b
     d WriteRequest    pi

      /free

       ClearDDTREC();

       ddtwhse = pWhse;
       ddtrtid = prtid;
       ddttype = 'DROPREQ';
       ddtsubtype = 'REQUEST';
       ddttaskgrp = gTaskGrp;
       ddtseq = 1;
       ddtid = pDropId;
       ddtstr = %trim(pCmd) + ' - ' + pDragIds;

       write ddtrec;

      /end-free

     p                 e

750 A*----------------------------------------------------------------
750 A*  SpinUnsping    Update Spin and UnSpin status and icon
750 A*----------------------------------------------------------------
750 A
750 Ap SpinUnSpin      b
750 Ad SpinUnSpin      pi
750 A
750 A* Local File Data Structures
750 A
750 AD dddrec        E Ds                  Extname(DDDETAIL)
750 A
750 A* Local Variables
750 A
750 AD ddfilesp        s             10
750 Ad taskSeq         s                   like(ddtseq)
750 Ad saveSeq         s                   like(ddtseq)
750 AD pRtnCode        s             10
750 AD pRtnMsg         s            100
750 Ad pRtnStr         s          65535    varying
750 Ad searchPos       s              5  0
750 Ad searchJsonStr   s            200
750 Ad wrkdddjson      s           3074
750 A
750 A /free
750 A
750 A  gRtnStr = '';
750 A
750 A  // get dddetail record for specific location level 1 record
750 A  // only comes here when user clicks spin icon from frontend
750 A  // and that is only added to level one location records
750 A  // that location is passed in via the pDropId
750 A
750 A  exec sql select * into :dddrec from dddetail
750 A           where dddwhse=:pWhse and dddRtid=:pRtid and
750 A                 dddsnap=0 and dddid=:pDropId;
750 A
750 A      // get/set spin indicator
750 A      wrkspin = *blanks;
750 A      wrkmrg= *blanks;
750 A      wrkrow= *zeros;
750 A      wrkcol= *zeros;
750 A      // get record for this dd2 route id and rec type id
750 A      exWhse = pWhse;
750 A      wrkRtid= pRtid;
750 A      ddwrkflds ('*GET': exRtnCode: exRtnMsg: exWhse: wrkRtid:
750 A                  dddsnap: dddid: wrkrow:
750 A                  wrkcol: wrkmrg: wrkspin);
750 A
750 A      if exRtnCode = '*OK';
750 A        // when record was found then update flags
750 A        // Frontend sends either SPIN or UNSPIN based
750 A        // on the title of the link at the time and
750 A        // flips back and forth based on click of spin
750 A        // and un-spin
750 A        if pCmd = 'SPIN';
750 A          wrkspin = 'Y';
750 A        else;
750 A          wrkspin='N';
750 A        endif;
750 A        ddwrkflds ('*CHANGE': exRtnCode: exRtnMsg: exWhse: wrkRtid:
750 A                    dddsnap: dddid: dddrow:
750 A                    dddcol: wrkmrg: wrkspin);
750 A      else;
750 A        // perform insert when not found
750 A        wrkmrg='N';
750 A        if pCmd = 'SPIN';
750 A          wrkspin = 'Y';
750 A        else;
750 A          wrkspin='N';
750 A        endif;
750 A        ddwrkflds ('*ADD': exRtnCode: exRtnMsg: exWhse: wrkRtid:
750 A                    dddsnap: dddid: dddrow:
750 A                    dddcol: wrkmrg: wrkspin);
750 A      endif;
750 A  // Create Task to quickly update the one spin indicator or this location
750 A
750 A  taskSeq = 1;
750 A
750 A  // Start the task list
750 A
750 A  ClearDDTREC();
750 A
750 A  ddtwhse = pWhse;
750 A  ddtrtid = pRtid;
750 A  ddttype = 'DDTASKS';
750 A  ddtsubtype = 'START';
750 A  ddttaskgrp = gTaskGrp;
750 A  ddtseq = 1;
750 A  ddtstr = '{"grpid":"' + %char(gTaskGrp) + '","tasks":[';
750 A  write ddtrec;
750 A  gRtnStr += ddtstr;
750 A
750 A  // create json to update Spin icon and image path
750 A
750 A
750 A  // Add code to update spin icon/image
750 A  // this is ultimately processed in TruckUpdate function
750 A  // in frontend.  It simply updates the icon and title
750 A  // versus re-creating the location as a whole.  Less
750 A  // data sending that way
750 A
750 A  ClearDDTREC();
750 A
750 A  ddtwhse = pWhse;
750 A  ddtrtid = pRtid;
750 A  ddttype = 'DDTASKS';
750 A  ddtsubtype = 'START';
750 A  ddttaskgrp = gTaskGrp;
750 A  ddtseq += 1;
750 A  ddtstr = '{"upd":{"id":"' + %trim(dddid) + '","fields":' +
750 A           '{"ispin":"' + %trim(dddid) + %trim(wrkspin) + '"}}}';
750 A  write ddtrec;
750 A  gRtnStr += ddtstr;
750 A
750 A  // End the task list
750 A
750 A  saveSeq = ddtseq;
750 A  ClearDDTREC();
750 A  ddtwhse = pWhse;
750 A  ddtrtid = pRtid;
750 A  ddttype = 'DDTASKS';
750 A  ddtsubtype = 'END';
750 A  ddttaskgrp = gTaskGrp;
750 A  ddtseq += 1;
750 A  ddtstr = ']}';
750 A  write ddtrec;
750 A  gRtnStr += ddtstr;
750 A
750 A  // Update snapshot zero for this location in DDDETAIL
750 A  // for the ispin flag.  ispin json tag has id for location
750 A  // and either Y or N to indicate spun or not.  This block
750 A  // of code simply updates that section of dddjson in dddetail
750 A  // for this specific location level 1 record
750 A  exec sql select dddjson into :wrkdddjson
750 A             from dddetail
750 A         where dddwhse=:pWhse and dddRtid=:pRtid and dddsnap=0
750 A             and dddid=:pDropId;
750 A  // Build search string like ispin":"lr1c2 to find in dddjson
750 A  searchJsonStr = 'ispin":"' + %trim(dddid);
750 A  searchPos     = %scan(%trim(searchjSonStr):wrkdddjson);
750 A  // after finding then update snapshot zero with spin update
750 A  if searchPos > 0;
750 A    %subst(wrkdddjson:searchPos:%len(%trim(searchJsonStr))+1)=
750 A              %trim(searchJsonStr) + %trim(wrkspin);
750 A    exec sql update dddetail set dddjson = :wrkdddjson
750 A            where dddwhse=:pWhse and dddRtid=:pRtid and dddsnap=0
750 A                  and dddid=:pDropId;
750 A  endif;
750 A
750 A  // Rebuild group zero Truck tasks since coming out and back
750 A  // in uses snapshot zero to reload the screen
750 A  // If too slow, will need to revise to rebuild locations
750 A
750 A  WriteRteLog ('DD430': '1');   // Start logging DD430
750 A
750 A  dd430('RBLDTRUCK': '': pWhse: pRtid:
750 A        pUser: pSessId: pDict: pPgm: pRtnCode: pRtnMsg: pRtnStr);
750 A  if pRtnCode = '*ERROR';
750 A    error = *on;
750 A    passThruMsg = *on;
750 A    pJSON = pRtnMsg;
750 A    return;
750 A  endif;
750 A
750 A  WriteRteLog ('DD430': '2');   // End logging DD430
750 A
750 A /end-free
750 A
750 Ap                 e

     *----------------------------------------------------------------
     *  WriteDropTasks    Write out DDTASKS for Drop
     *----------------------------------------------------------------

     p WriteDropTasks  b
     d WriteDropTasks  pi

     * Local Variables

     d taskSeq         s                   like(ddtseq)
     d saveSeq         s                   like(ddtseq)
     D pRtnCode        s             10
     D pRtnMsg         s            100
     d pRtnStr         s          65535    varying

      /free

       gRtnStr = '';

       // First, update location summaries and JSON fields

720jA  WriteRteLog ('DD410': '1');   // Start DD410 logging

       for i = 1 to locCount;

         %occur(locList) = i;
         dd410('*UPDLOC': pWhse: pRtid: locList.group: locList.row:
               locList.col: pUser: pSessId: pDict: pPgm: pRtnCode: pRtnMsg);
         if pRtnCode = '*ERROR';
           error = *on;
           passThruMsg = *on;
           pJSON = pRtnMsg;
           return;
         endif;

       endfor;

720jA  WriteRteLog ('DD410': '2');   // End DD410 logging

       // Rebuild group zero Truck tasks
       // If too slow, will need to revise to rebuild locations

720jA  WriteRteLog ('DD430': '1');   // Start logging DD430

       dd430('RBLDTRUCK': '': pWhse: pRtid:
             pUser: pSessId: pDict: pPgm: pRtnCode: pRtnMsg: pRtnStr);
       if pRtnCode = '*ERROR';
         error = *on;
         passThruMsg = *on;
         pJSON = pRtnMsg;
         return;
       endif;

720jA  WriteRteLog ('DD430': '2');   // End logging DD430

720jA  WriteRteLog ('WRITE': '1');   // Start logging writting

       // Create DDTASKS

       taskSeq = 1;

       // Start the task list


       ClearDDTREC();

       ddtwhse = pWhse;
       ddtrtid = pRtid;
       ddttype = 'DDTASKS';
       ddtsubtype = 'START';
       ddttaskgrp = gTaskGrp;
       ddtseq = 1;
720jD  //ddtstr = '{"tasks":[';
720jM  ddtstr = '{"grpid":"' + %char(gTaskGrp) + '","tasks":[';
       write ddtrec;
       gRtnStr += ddtstr;

       // Create location Delete tasks

       for i = 1 to locCount;

         %occur(locList) = i;
         ddtsubtype = 'DELETE';
         ddtseq += 1;
         ddtstr = '{"dlt":"' + %trim(locList.Id) + '"},';
         write ddtrec;
         gRtnStr += ddtstr;

       endfor;

       // Create location Add tasks

       ddtsubtype = 'ADD';
       ddtstr = '';

       for i = 1 to locCount;

         %occur(locList) = i;

         setll (pWhse: pRtid: 0:
                locList.group: locList.row: locList.col ) dddetail3;

         dow forever = forever;

           reade (pWhse: pRtid: 0:
                  locList.group: locList.row: locList.col ) dddetail3;
           if %eof(dddetail3);
             leave;
           endif;

           // Skip Level 0 records

           if dddlevel = GROUPLVL;
             iter;
           endif;

           // Always writing after-the-fact to determine if comma is needed

           if dddjson > '';

             if ddtstr > '';
               ddtstr += ',';
               write ddtrec;
               gRtnStr += ddtstr;
             endif;

             ddtseq += 1;
             ddtid = dddid;
             ddtsnap = dddsnap;
             ddtgroup = dddgroup;
             ddtlevel = dddlevel;
             ddtrow = dddrow;
             ddtcol = dddcol;
             ddtplid = dddplid;
             ddtpltsct = dddpltsct;
             ddtstop = dddstop;
             ddtitmtyp = ddditmtyp;
             ddtlbltot = dddlbltot;
             ddtlblitm = dddlblitm;
             ddtstr = '{"add":' + dddjson + '}';

           endif;

         enddo;

       endfor;

       // Write out last record processed

       if ddtstr > '';
         ddtstr += ',';
         write ddtrec;
         gRtnStr += ddtstr;
       endif;

       // Write out pallet updates because pallet number may have changed

       setll (pWhse: pRtid: 0: 'M': PALLETLVL) dddetail1;

       dow forever = forever;

         reade (pWhse: pRtid: 0: 'M': PALLETLVL) dddetail1;
         if %eof(dddetail1);
           leave;
         endif;

         ddtsubtype = 'UPD';
         ddtseq += 1;
         ddtid = dddid;
         ddtsnap = dddsnap;
         ddtgroup = dddgroup;
         ddtlevel = dddlevel;
         ddtrow = dddrow;
         ddtcol = dddcol;
         ddtplid = dddplid;
         ddtpltsct = dddpltsct;
         ddtstop = dddstop;
         ddtitmtyp = ddditmtyp;
         ddtlbltot = dddlbltot;
         ddtlblitm = dddlblitm;
         ddtstr = '{"upd":' + dddjson + '},';
         write ddtrec;
         gRtnStr += ddtstr;

       enddo;

       setll (pWhse: pRtid: 0: 'O': PALLETLVL) dddetail1;

       dow forever = forever;

         reade (pWhse: pRtid: 0: 'O': PALLETLVL) dddetail1;
         if %eof(dddetail1);
           leave;
         endif;

         ddtsubtype = 'UPD';
         ddtseq += 1;
         ddtid = dddid;
         ddtsnap = dddsnap;
         ddtgroup = dddgroup;
         ddtlevel = dddlevel;
         ddtrow = dddrow;
         ddtcol = dddcol;
         ddtplid = dddplid;
         ddtpltsct = dddpltsct;
         ddtstop = dddstop;
         ddtitmtyp = ddditmtyp;
         ddtlbltot = dddlbltot;
         ddtlblitm = dddlblitm;
         ddtstr = '{"upd":' + dddjson + '},';
         write ddtrec;
         gRtnStr += ddtstr;

       enddo;

       // Write out group/side total updates, which come from level 0 records

         chain(n) (pWhse:  prtid: 0: 'grpM') dddetail;
         if %found(dddetail);

             ddtsubtype = 'UPD';
             ddtseq += 1;
             ddtid = dddid;
             ddtsnap = dddsnap;
             ddtgroup = dddgroup;
             ddtlevel = dddlevel;
             ddtrow = dddrow;
             ddtcol = dddcol;
             ddtplid = dddplid;
             ddtpltsct = dddpltsct;
             ddtstop = dddstop;
             ddtitmtyp = ddditmtyp;
             ddtlbltot = dddlbltot;
             ddtlblitm = dddlblitm;
             ddtstr = '{"upd":' + dddjson + '},';
             write ddtrec;
             gRtnStr += ddtstr;

         endif;

         chain(n) (pWhse:  prtid: 0: 'grpO') dddetail;
         if %found(dddetail);

             ddtsubtype = 'UPD';
             ddtseq += 1;
             ddtid = dddid;
             ddtsnap = dddsnap;
             ddtgroup = dddgroup;
             ddtlevel = dddlevel;
             ddtrow = dddrow;
             ddtcol = dddcol;
             ddtplid = dddplid;
             ddtpltsct = dddpltsct;
             ddtstop = dddstop;
             ddtitmtyp = ddditmtyp;
             ddtlbltot = dddlbltot;
             ddtlblitm = dddlblitm;
             ddtstr = '{"upd":' + dddjson + '}';
             write ddtrec;
             gRtnStr += ddtstr;

         endif;


       // End the task list

       saveSeq = ddtseq;
       ClearDDTREC();
       ddtwhse = pWhse;
       ddtrtid = pRtid;
       ddttype = 'DDTASKS';
       ddtsubtype = 'END';
       ddttaskgrp = gTaskGrp;
       ddtseq = saveSeq + 1;
       ddtstr = ']}';
       write ddtrec;
       gRtnStr += ddtstr;

720jA  WriteRteLog ('WRITE': '2');   // End logging writting

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetCurrStamp  Get current timestamps
     *----------------------------------------------------------------

     p GetCurrStamp    b
     d GetCurrStamp    pi

      /free

         getmicrotime(currstampuc:currstampsys);
         ucOffset = %diff(currstampuc: currstampsys: *HOURS);
         currstamploc = currstampsys + %hours(bfcoffset);

      /end-free

     p GetCurrStamp    e

720jA*----------------------------------------------------------------
720jA*  WriteRteLog   Write record to GLORTELOG file
720jA*----------------------------------------------------------------
720jA
720jAp WriteRteLog     b
     d WriteRteLog     pi
     d inSubGrp                      12    const
     d inType                         1    const

     * Local Variables

     d ddWhse          s              3  0
     d ddrtid          s              5
     d ddmrid          s             26
     d ddGrpId         s              7  0
     d ddGrpCode       s             10
     d ddSubGrp        s             12
     d ddType          s              1
     d ddUser          s             10
     d ddJobqTS        s             26
     d ddJobqUC        s             26

      /free

         ddRtid = pRtid;
         ddGrpId = gTaskGrp;
         ddSubGrp = inSubGrp;
         ddType = inType;
         ddGrpCode = 'DD' + pCmd;
         ddUser = pUser;

         wrtrtelog(pWhse: ddRtid: ddmrid: ddGrpId: ddGrpCode: ddSubGrp:
                   ddType: ddUser: #pgm: ddJobqTS: ddJobqUC);

      /end-free

     p                 e

720jA*----------------------------------------------------------------
720jA*  WriteRteLog6   Write type 6 record to GLORTELOG file
720jA*----------------------------------------------------------------
720jA
720jAp WriteRteLog6    b
     d WriteRteLog6    pi
     d inSubGrp                      12    const
     d inMin                          7  2

     * Local Variables

     d ddWhse          s              3  0
     d ddrtid          s              5
     d ddmrid          s             26
     d ddGrpId         s              7  0
     d ddGrpCode       s             10
     d ddSubGrp        s             12
     d ddType          s              1
     d ddUser          s             10
     d ddJobqTS        s             26
     d ddJobqUC        s             26

      /free

         ddRtid = pRtid;
         ddGrpId = gTaskGrp;
         ddSubGrp = inSubGrp;
         ddType = '6';
         ddGrpCode = 'DD' + pCmd;
         ddUser = pUser;

         wrtrtelog(pWhse: ddRtid: ddmrid: ddGrpId: ddGrpCode: ddSubGrp:
                   ddType: ddUser: #pgm: ddJobqTS: ddJobqUC: inMin);

      /end-free

     p                 e

