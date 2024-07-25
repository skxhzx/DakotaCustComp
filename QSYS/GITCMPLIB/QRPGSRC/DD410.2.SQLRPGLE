      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
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
     *  DD410     DragDrop 2.0 - Create DDDETAIL file
     *  14 March 2018
     *  Dave Sommerville
     *
     *  Revisions
     *
720aA*   04/17/18  DAS  7.20a
     *     - Added 'side' logic
     *
720bA*   05/16/18  KDE  7.20b
     *     - Call DD430 to generate new color tasks when Compartment Color
     *       is changed in M180xx
     *     - Change color code to process all COMP configurations, not just
     *       *DEFAULT
     *
720cA*   05/21/18  DAS  7.20c
     *     - Added cube warning at pallet level.
     *
720dA*   05/23/18  DAS  7.20d
     *     - Revised to set max cube for location and pallet
     *       from pltsum in CRT routines.
     *
720eA*   06/04/18  DAS  7.20e
     *     - Added Weight warning at pallet level.
     *
720fA*   06/16/18  DAS  7.20f
     *     - Revised to get Host stop, drop
     *
720gA*   06/26/18  DAS  7.20g
     *     - A couple of places were trimming decimals from cube/wgt.
     *
720hA*   08/28/18  KDE  7.20h
     *     - Added BFCDEBUG along with changing Deleterecs.  When type
     *       comes in as Truck we added "0" snapshot to READE key.  A
     *       Refresh was removing snapshot 1 and therefore Replay would
     *       mot working.  We need Replay to help determine what is going
     *       going wrong with certain row/column combination not being displayed
     *       without doing a refresh
     *
730aA*   05/21/19  DAS  7.30a
     *     - Added pseq value for items to be used by PSeq Sort button.
     *
730bA*   09/30/19  KDE  7.30b
     *     - Added pcs (pieces) to Pallet level.  Marques originally requested
     *
740 A*   02/21/20  KDE  7.40
     *     - Added Category and Class color code
     *     - Added Pallet counts to Route, Truck, Sides and Overflow
     *     - Added new field display of ... for color coding associated
     *       to Class/Category
     *     - Added code to populate new Category and Class colors to
     *       Color json map
     *     - Had to add changes for new Cat/Class to both CRTITEMS(only
     *       ran during original route creation in DD410 and the PROCESSLVL5
     *       which ultimately gets called by way of DD420
     *     - Revised to monitor opfwgt in case not initialized proper
     *       in zone setup.  Will force zero if fails
     *     - Revised to send down all DDOPTS as none display span tags
740aA*   07/22/20  KDE  7.40a
     *     - Add ability to override to history files for dddetail and
     *       ddtask.  Once routes get to pick and print they are moved
     *       to history files
     *
740bA*   10/29/20  DAS  7.40b
     *     - Revised ChkStopSplit to ignore 'B' recs
750 A*   03/24/21  KDE  7.50
     *     - Revised to handle merging unlike zones on one pallet
     *     - Cleanup a few sql indicator needs in joblog
750aA*   05/05/21  KDE  7.50a
     *     - Revised to handle Super Routes (Chefs first)
750bA*   10/04/21  KDE  7.50b
     *     - Revised to add color for Mix Zone Pallets
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

740aDF*dddetail  uf   e           k disk    rename(dddrec: dddrec0)
740aDF*dddetail1 uf a e           k disk
740aDF*dddetail2 uf a e           k disk    rename(dddrec: dddrec2)
740aMFdddetail  uf   e           k disk    rename(dddrec: dddrec0) usropn
740aAf                                     extfile(dddfile)
740aMFdddetail1 uf a e           k disk    usropn
740aAf                                     extfile(dddfile)
740aMFdddetail2 uf a e           k disk    rename(dddrec: dddrec2) usropn
740aAf                                     extfile(dddfile)
740 Afitemcls   if   e           k disk
740 Afddopts    if   e           k disk
750aAFsrord2    if   e           k disk
     Fordh      if   e           k disk
     Fworklbl   if   e           k disk
     Fworklbl11 if   e           k disk    rename(lwrec: lwrec11) prefix(lw11_)
     Fworklbl4  if   e           k disk    rename(lwrec: lwrec4) prefix(lw4_)
     Fpircolorsdif   e           k disk
720bAFpircolorshif   e           k disk
     Ftrktmpd   if   e           k disk
720eAFtruckh    if   e           k disk
     Frtehed    if   e           k disk
     Fpiritem   if   e           k disk
720cAFoptionz   if   e           k disk
720cAFworklbl6  if   e           k disk    rename(lwrec: lwrec6)
720hAFbfcdbgflg if   e           k disk    usropn
720hAFbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#Item
     D savever#        s                   like($itver#)
     D save$item       s                   like($item)
     D save$item2      s                   like($item2)

     *----------------------------------------------------------------
     *  DD2 Level Constants (iF used in SQL stmt, must be defined as variable)
     *----------------------------------------------------------------

     D GROUPLVL        c                   0
     D LOCATIONLVL     s              1  0 inz(1)
     D PALLETLVL       c                   2
     d PLTSECTLVL      c                   3
     D STOPLVL         c                   4
     D ITEMLVL         c                   5
     D TOTEITEMLVL     c                   6

     *----------------------------------------------------------------
     *  Working variables
     *
740aAD cmd             s           3000    varying
720hAD dbgflgExists    s               n
740aAd dddfile         s             10
720hAD debug           s               n
740aAd inRtnCode       s             10
740aAd inRtnMsg        s             60
740 Ad qryDesc         s             30
740 Ad qryCat          s             15
740 Ad qryCls          s             15
740 Ad bfccatcls       s               n
740 Ad optCnt          s              3  0
750 Ad ttlPcs_Ind      s              5i 0
750 Ad ttlCube_Ind     s              5i 0
750 Ad ttlWgt_Ind      s              5i 0
750 Ad ttlPlid_Ind     s              5i 0

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

720aA /copy qcopysrc,c#stdsql

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
750 Ad wrkspin         s             10
750 AD wrkmrg          s             10
750 Ad wrkrow          s              3  0
750 Ad wrkcol          s              2  0
750 AD wrkrtid         s              5
750 Ad mrgPzon         s              6
750 Ad mrgTzon         s              6
750 Ad mrgSzon         s              6
750 Ad mrgComp         s              1

     *----------------------------------------------------------------
     *  Global Variables
     *----------------------------------------------------------------
     D gGroupId        s              5  0
     D gSnap           s              2  0
720aAD gMaxLeftCol     s              3  0
720aAD gMinRightCol    s              3  0
740 Ad gfromTo         s             12
740 Ad gAnyRow         s              3  0
740 Ad gTrkPlid        s                   like(dddplid)
740 Ad gOvfPlid        s                   like(dddplid)
750 Ad gSavedComp      s              1

     *----------------------------------------------------------------
     *  JSON Global Variables
     *----------------------------------------------------------------

     D jsonDepth       s              3  0
     d jsonLine        s           3072    varying

     D jsonStack       ds                  occurs(20) Qualified
     D   firstEntry                    n

     *----------------------------------------------------------------
720cA*  *PICK  -  Picking options
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
650aA*    OPLBL   -  Pick Label Printing method.
650aA*                N = Normal
650aA*                S = Side by Side
656aA*                C = Custom
700aA*    OPPMTZ  -  Allow multi-truck assignments.
700aA*    OPDDDO  -  Dock door drop off order.
700aA*    OPMCUB  -  Minimum cube per fixed pallet.
710aA*    OPNBPS  -  Number of Pallet Sections.
720aA*    OPFWGT  -  Maximu weight per pallet.
720aA*    OPFPLT  -  Pallet code
720aA*    OPBSEQ  -  Build sequence number
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

     d ClearDDDREC     pr
     d  dddrec                             likerec(dddrec: *output)
     d                                     options(*nopass)

     d ChkItemSplit    pr             1  0
     d  lw6                                likerec(lwrec: *output)

     d ChkStopSplit    pr             1  0
     d  whse                               const like(dddwhse)
     d  rtid                               const like(dddrtid)
     d  comp                               const like(dddcomp)
     d  tzon                               const like(dddtzon)
     d  pzon                               const like(dddpzon)
     d  szon                               const like(dddszon)
     d  plid                               const like(dddplid)
     d  stop                               const like(dddstop)

     d CrtGroup        pr
     d  whse                          3  0 const
     d  rtid                          5    const
     d  group                         1    const

     d CrtLocations    pr
     d  whse                          3  0 const
     d  rtid                          5    const
     d  group                         1    const
     d  gen                           1  0 const
     d  dddrec                             const likerec(dddrec: *output)

     d CrtPallets      pr
     d  whse                          3  0 const
     d  rtid                          5    const
     d  group                         1    const
     d  gen                           1  0 const
     d  row                           3  0 const
     d  col                           3  0 const
     d  dddrec                             const likerec(dddrec: *output)

     d CrtStops        pr
     d  whse                          3  0 const
     d  rtid                          5    const
     d  plid                          7  0 const
     d  dddrec                             const likerec(dddrec: *output)

     d CrtItems        pr
     d  whse                          3  0 const
     d  rtid                          5    const
     d  plid                          7  0 const
     d  stop                          2  0 const
     d  dddrec                             const likerec(dddrec: *output)

     d CrtToteItems    pr
     d  whse                          3  0 const
     d  rtid                          5    const
     d  plid                          7  0 const
     d  dddrec                             const likerec(dddrec: *output)

     d DeleteRecs      pr
     d  type                         10    const
     d  whse                          3  0 const
     d  rtid                          5    const
     d  snap                          2  0 const options(*nopass)
     d  group                         1    const options(*nopass)
     d  row                           3  0 const options(*nopass)
     d  col                           2  0 const options(*nopass)
     d  plid                          7  0 const options(*nopass)

     d GetCurrStamp    pr

720aAd GetGrandTotal   pr
     d ttlPcs                              like(dddpcs)
     d ttlCube                             like(dddcube)
     d ttlWgt                              like(dddwgt)
740 Ad ttlPlid                             like(dddplid)

     d GetMaxColumns   pr
     d row                                 like(dddrow)

720aAd GetSideTotal    pr
     d side                           1    const
     d ttlPcs                              like(dddpcs)
     d ttlCube                             like(dddcube)
     d ttlWgt                              like(dddwgt)
740 Ad ttlPlid                             like(dddplid)

     d GetTotePlid     pr             7  0
     d  whse                          3  0 const
     d  lbl#                          7  0 const

720eAd GetZoneMaxWgt   pr             4s 0
720eAd  zone                               const like(dddtzon)

     d RebuildColors   pr
     d  whse                          3  0 const

     d RebuildLoc      pr
     d  whse                          3  0 const
     d  rtid                          5    const
     d  snap                          2  0 const
     d  group                         1    const
     d  row                           3  0 const
     d  col                           2  0 const

     d RebuildRte      pr
     d  whse                          3  0 const
     d  rtid                          5    const

     d RebuildTrk      pr
     d  whse                          3  0 const
     d  rtid                          5    const

     d SumLevel        pr

     d UpdLevel        pr
     d  whse                          3  0 const
     d  rtid                          5    const
     d  fromLevel                     2  0 const
     d  toLevel                       2  0 const
     d  row                           3  0 const options(*nopass)
     d  col                           2  0 const options(*nopass)

     d UpdPltNum       pr
     d  whse                          3  0 const
     d  rtid                          5    const
     d  pltid                         7  0 const
     d  pltNum                        7  0 const

     d CreateJSON      pr

     d processlvl0     pr

     d ProcessLvl1     pr

     d ProcessLvl2     pr

     d ProcessLvl3     pr

     d ProcessLvl4     pr

     d ProcessLvl5     pr


     d JsonAddArray    pr
     d  arrayValue                  500    const varying

     d JsonAddPair     pr
     d  pairName                    100    const varying
     d  pairValue                   500    const varying

     d JsonEndArray    pr

     d JsonEndObj      pr

     d JsonStartArray  pr
     d  arrayName                   100    const varying

     d JsonStartObj    pr
     d  objName                     100    const varying options(*nopass)

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

     d/copy qcopysrc,p.cvttext
     d/copy qcopysrc,p.dricop
     d/copy qcopysrc,p.bfcdteti
     d/copy qcopysrc,p.dd430
     d/copy qcopysrc,p.or627
720fAd/copy qcopysrc,p.getstop
740 Ad/copy qcopysrc,p.wrtrtelg
740aA /copy qcopysrc,p.dd2dtamo
740aAD/copy qcopysrc,p.qcmdexc
750 Ad/copy qcopysrc,p.ddwrkflds

     *----------------------------------------------------------------
     *  Parameters
     *
     *  $pCmd    - *COLORS - Rebuild colors
     *             *ROUTE - Rebuild route
     *             *LOCATION - Rebuild location
     *             *UPDLOC - Update location level summaries and JSON
     *  $pOutput - *FILE, *RTNSTR
     *  $pwhse   - Warehouse
     *  $prtid   - Route id
     *
     *----------------------------------------------------------------

     D DD410           pr                  extpgm('DD410')
     D  pCmd                         10    const
     D  pWhse                         3p 0 const
     D  pRtid                         5    const
     D  pGroup                        1    const
     D  pRow                          3p 0 const
     D  pCol                          2p 0 const
     D  pUser                        10    const
     D  pSessId                      40    const
     D  pDict                        10    const
     D  pPgm                         10    const
     D  pRtnCode                     10
     D  pRtnMsg                     100
     D  pPltId                        7p 0 const options(*nopass)
     D  pPltNum                       7p 0 const options(*nopass)

     D DD410           pi
     D  pCmd                         10    const
     D  pWhse                         3p 0 const
     D  pRtid                         5    const
     D  pGroup                        1    const
     D  pRow                          3p 0 const
     D  pCol                          2p 0 const
     D  pUser                        10    const
     D  pSessId                      40    const
     D  pDict                        10    const
     D  pPgm                         10    const
     D  pRtnCode                     10
     D  pRtnMsg                     100
     D  pPltId                        7p 0 const options(*nopass)
     D  pPltNum                       7p 0 const options(*nopass)

     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------

      /free
       *inlr = *on;
720hA
720hA  if dbgflgExists;
720hA    chain(e) (#pgm) bfcdbgflg;
720hA    if %found(bfcdbgflg);
720hA      debug = (bdfflag = 1);
720hA    else;
720hA      debug = *off;
720hA    endif;
720hA  endif;

       // Get timestamp to apply to records

       GetCurrStamp();
720hA
720hA  if debug;
720hA    exsr wrtDebugParms;
720hA  endif;

740aA  exsr opnDDfiles;

       // Get Route Header

       chain (pWhse: pRtid) rtehed;
       if not %found(rtehed);
         clear rhrec;
       endif;

       // Get Truck info

       chain (pWhse: rhtruk) truckh;
       if not %found(truckh);
         clear threc;
       endif;

       // Create records

       select;

         when pCmd = '*COLORS';
           RebuildColors(pWhse);

         when pCmd = '*ROUTE';
           RebuildRte(pWhse: pRtid);

         when pCmd = '*LOCATION';
           RebuildLoc(pWhse: pRtid: 0: pGroup: pRow: pCol);

         when pCmd = '*RBLDTRUCK';
           RebuildTrk(pWhse: pRtid);

         when pCmd = '*UPDLOC';
           UpdLevel(pWhse: pRtid: GROUPLVL: TOTEITEMLVL: pRow: pCol);

         when pCmd = '*UPDPLTNUM';
           UpdPltNum(pWhse: pRtid: pPltId: pPltNum);

       endsl;


      /end-free

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

      /free
       begsr *pssr;

         // Make sure we don't get caught in an infinite loop

         if pssrflag;
           *inlr = *on;
           return;
         endif;

         pssrflag = *on;

         //  Send message back to calling program

         dump(a);

         pRtnCode = '*ERROR';
         PRtnMsg = 'PSSR: ' + %trim(#pgm) + ' (' + %char(#stmt) + ') '
                 + #status + ' - ' + %trim(#pgmmsg);

         *inlr = *on;
         return;

       endsr;
      /end-free
720hA
720hA *----------------------------------------------------------
720hA *  *INZSR   Initialization subroutine
720hA *----------------------------------------------------------
720hA
720hA /free
720hA     begsr *INZSR;
720hA        open(e) bfcdbgflg;
720hA        if %error;
720hA          dbgflgExists = *off;
720hA        else;
720hA          dbgflgExists = *on;
720hA        endif;
720hA
720hA      endsr;
720hA
720hA /end-free
740aA
740aA *----------------------------------------------------------
740aA *  opnDDfiles - Open DD files pointed to live or history
740aA *----------------------------------------------------------
740aA
740aA /free
740aA
740aA  begsr opnDDfiles;
740aA
740aA    dd2dtamove('*DTALOCDDD': inRtnCode: inRtnMsg: pWhse: pRtid);
740aA    if inRtnCode = 'LIVE';
740aA      // will simply open without override since in live files
740aA      dddfile='DDDETAIL';
740aA      if not %open(dddetail);
740aA         open dddetail;
740aA      endif;
740aA      dddfile='DDDETAIL1';
740aA      if not %open(dddetail1);
740aA         open dddetail1;
740aA      endif;
740aA      dddfile='DDDETAIL2';
740aA      if not %open(dddetail2);
740aA         open dddetail2;
740aA      endif;
740aA    else;
740aA      // when not found in live we will override to history
740aA      // files and then open for use
740aA      dddfile='DDDETAILH';
740aA      if not %open(dddetail);
740aA         open dddetail;
740aA      endif;
740aA      dddfile='DDDETAILH1';
740aA      if not %open(dddetail1);
740aA         open dddetail1;
740aA      endif;
740aA      dddfile='DDDETAILH2';
740aA      if not %open(dddetail2);
740aA         open dddetail2;
740aA      endif;
740aA    endif;
740aA  endsr;
740aA
740aA /end-free
740aA
720hA *----------------------------------------------------------
720hA *  wrtDebugParms  Write out debug parm record
720hA *----------------------------------------------------------
720hA
720hA /free
720hA  begsr wrtDebugParms;
720hA
720hA    bdtype = 'PARMS';
720hA
720hA    bdvalues = '&pWhse = ' + %char(pWhse)
720hA             + '&pCmd=' + %trimr(pCmd)
720hA             + '&ppRtid=' + %trimr(pRtid)
720hA             + '&pGroup=' + %trimr(pGroup)
720hA             + '&pSessid=' + %trimr(pSessid);
720hA
720hA    bdaddts = %timestamp();
720hA    bdaddpgm = #pgm;
720hA    bdaddcusr = #curruser;
720hA    bdaddjusr = #user;
720hA    bdaddjob = #job;
720hA    bdaddnbr = #jobnbr;
720hA
720hA    write(e) bdrec;
720hA
720hA  endsr;
720hA /end-free
720hA
720hA *----------------------------------------------------------
720hA *  wrtDebugError  Write out debug error
720hA *----------------------------------------------------------
720hA
720hA /free
720hA  begsr wrtDebugError;
720hA
720hA    bdtype = 'ERROR';
720hA
720hA    bdvalues = ' ';
720hA
720hA    bdaddts = %timestamp();
720hA    bdaddpgm = #pgm;
720hA    bdaddcusr = #curruser;
720hA    bdaddjusr = #user;
720hA    bdaddjob = #job;
720hA    bdaddnbr = #jobnbr;
720hA
720hA    write(e) bdrec;
720hA
720hA  endsr;
720hA /end-free

     *----------------------------------------------------------------
     *  CLRDDDREC       Cleare DDDREC fields
     *----------------------------------------------------------------

     p ClearDDDREC     b
     d ClearDDDREC     pi
     d  locdddrec                          likerec(dddrec: *output)
     d                                     options(*nopass)

      /free

       if %parms = 0;

         clear dddrec;
         dddaddpgm = #pgm;
         dddaddts = currstampsys;
         dddadduc = currstampuc;
         if pUser = '';
           dddaddusr = #user;
         else;
           dddaddusr = pUser;
         endif;
         dddaddusrj = #user;
         dddaddjob = #job;
         dddaddnbr = #jobnbr;
         dddsessid = %trim(pSessId);

       else;

         clear locdddrec;
         locdddrec.dddaddpgm = #pgm;
         locdddrec.dddaddts = currstampsys;
         locdddrec.dddadduc = currstampuc;
         if pUser = '';
           locdddrec.dddaddusr = #user;
         else;
           locdddrec.dddaddusr = pUser;
         endif;
         locdddrec.dddaddusrj = #user;
         locdddrec.dddaddjob = #job;
         locdddrec.dddaddnbr = #jobnbr;
         locdddrec.dddsessid = %trim(pSessId);

       endif;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ChkItemSplit    Check for item split
     *                  Logic also used in DD420/CombinSplit
     *----------------------------------------------------------------

     p ChkItemSplit    b
     d ChkItemSplit    pi             1  0
     d  lw6                                likerec(lwrec: *output)

     * Local Variables

     d count           s              1  0

      /free

       count = 0;

       setll (lw6.lwwhse: lw6.lwrte: lw6.lword: lw6.lwseq:
              lw6.lwitem: lw6.lwtype) worklbl11;

       dow forever = forever;

         reade (lw6.lwwhse: lw6.lwrte: lw6.lword: lw6.lwseq:
                lw6.lwitem: lw6.lwtype) worklbl11;

         if %eof(worklbl11);
           leave;
         endif;

         // Doing extra checks instead of creating new LF

         if lw11_lwdisp <> lw6.lwdisp
           or lw11_lwctr# <> lw6.lwctr#
           or lw11_lwasl2 <> lw6.lwasl2
           or lw11_lwutyp <> lw6.lwutyp;
             iter;
         endif;

         count += 1;

         if count > 1;
           leave;
         endif;

       enddo;

       if count > 1;
         return 1;
       else;
         return 0;
       endif;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ChkStopSplit    Check for stop split
     *----------------------------------------------------------------

     p ChkStopSplit    b
     d ChkStopSplit    pi             1  0
     d  whse                               const like(dddwhse)
     d  rtid                               const like(dddrtid)
     d  comp                               const like(dddcomp)
     d  tzon                               const like(dddtzon)
     d  pzon                               const like(dddpzon)
     d  szon                               const like(dddszon)
     d  plid                               const like(dddplid)
     d  stop                               const like(dddstop)

     * Local Variables

     d count           s              1  0


      /free

       count = 0;

       setll (whse: rtid: comp: tzon: pzon: stop: szon) worklbl4;

       dow forever = forever;

         reade (whse: rtid: comp: tzon: pzon: stop: szon) worklbl4;

         if %eof(worklbl4);
           leave;
         endif;

         if lw4_lwpal# = plid;
           iter;
         endif;

740bA    if lw4_lwtype = 'B';
740bA      iter;
740bA    endif;

         if lw4_lwgen <> 1 and lw4_lwtype <> 'M';
           iter;
         endif;

         count += 1;

         if count >= 1;
           leave;
         endif;

       enddo;

       if count >= 1;
         return 1;
       else;
         return 0;
       endif;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  CrtGroup    Create records for a group
     *----------------------------------------------------------------

     p CrtGroup        b
     d CrtGroup        pi
     d  whse                          3  0 const
     d  rtid                          5    const
     d  group                         1    const

     * Local Variables

     d gen             s              1  0
     d lastCol         s              3  0
     d lastRow         s              3  0
     d locdddrec       ds                  likerec(dddrec: *output)

      /free

       // Create Group Record

       ClearDDDREC(locdddrec);

       locdddrec.dddsnap = gSnap;
       locdddrec.dddid = 'grp' + group;
       locdddrec.dddpid = '';
       locdddrec.dddwhse = whse;
       locdddrec.dddrtid = rtid;
       locdddrec.dddgroup = group;
       if group = 'O';
         locdddrec.dddrow = 1;
         locdddrec.dddcol = 1;
       endif;

       write dddrec locdddrec;

       select;

         when group = 'M'; // Truck Pallets

           // Rows 1 - 99
           gen = 1;
           CrtLocations(whse: rtid: group: gen: locdddrec);

           // Rows 100 - 198
           gen = 6;
           CrtLocations(whse: rtid: group: gen: locdddrec);

         when group = 'O'; // Overflow Pallets

           // Continue to use gen 1 until we can switch overflow to gen 5.
           //gen = 5;
           gen = 1;
           CrtLocations(whse: rtid: group: gen: locdddrec);

       endsl;


      /end-free

     p                 e

     *----------------------------------------------------------------
     *  CrtLocations    Create records for a locations
     *----------------------------------------------------------------

     p CrtLocations    b

     * Local Files

     Fpltsum2   if   e           k disk

     d CrtLocations    pi
     d  whse                          3  0 const
     d  rtid                          5    const
     d  group                         1    const
     d  gen                           1  0 const
     d  indddrec                           const likerec(dddrec: *output)

     * Local File Data Structures

     d ps2             ds                  likerec(psrec)

     * Local Variables

     d lastCol         s              3  0
     d lastRow         s              3  0
     d locdddrec       ds                  likerec(dddrec: *output)

      /free

       locdddrec = indddrec;

       // Always create a general overflow location

       if group = 'O';
         locdddrec.dddid = 'olr0c0';
         locdddrec.dddpid = 'or0c0';
         locdddrec.dddlevel = LOCATIONLVL;
         locdddrec.dddcomp = '';
         locdddrec.dddrow = 0;
         locdddrec.dddcol = 0;
         locdddrec.dddstpsplt = 0;
         locdddrec.ddditmsplt = 0;
         write dddrec locdddrec;
       endif;


       // Loop through PLTSUM records for group

       // pltsum2 - whse,rtid,type,gen,row,col

       lastRow = -1;
       lastCol = -1;

       setll (Whse: rtid: 'O': gen) pltsum2;

       dow forever;

         reade (whse: rtid: 'O': gen) pltsum2 ps2;
         if %eof(pltsum2);
           leave;
         endif;

         // Until we switch overflow to gen 5 ...
         // Group 'M' - only use pallets less than 71
         // Group 'O' - only use pallets 71 and greater

         if (group = 'M' and ps2.psunld >= 71)
            or (group = 'O' and ps2.psunld < 71);
           iter;
         endif;

         // Skip record if not new location

         if ps2.psrow = lastRow and ps2.pscol = lastCol;
           iter;
         endif;

         // Skip record if empty overflow

         if group = 'O' and ps2.pspcs = 0;
           iter;
         endif;

         lastRow = ps2.psrow;
         lastCol = ps2.pscol;

         // Create non-overflow Location record

         if group = 'O';
           locdddrec.dddid = 'olr' + %char(ps2.psrow) + 'c' + %char(ps2.pscol);
           //locdddrec.dddpid = 'or' + %char(ps2.psrow) + 'c' + %char(ps2.pscol);
           locdddrec.dddpid = 'or1c1';
           locdddrec.dddlevel = LOCATIONLVL;
           locdddrec.dddcomp = ps2.pscomp;
           locdddrec.dddrow = ps2.psrow;
           locdddrec.dddcol = ps2.pscol;
           locdddrec.dddgen = ps2.psgen;
           locdddrec.dddtzon = ps2.pstzon;
           locdddrec.dddpzon = ps2.pspzon;
           locdddrec.dddszon = ps2.psszon;
           locdddrec.ddduseq = ps2.psunld;
720dA      locdddrec.dddmaxc = ps2.psmaxc;
           locdddrec.dddstpsplt = 0;
           locdddrec.ddditmsplt = 0;
         else;
           locdddrec.dddid = 'lr' + %char(ps2.psrow) + 'c' + %char(ps2.pscol);
           locdddrec.dddpid = 'mr' + %char(ps2.psrow) + 'c' + %char(ps2.pscol);
           locdddrec.dddlevel = LOCATIONLVL;
           locdddrec.dddcomp = ps2.pscomp;
           locdddrec.dddrow = ps2.psrow;
           locdddrec.dddcol = ps2.pscol;
           locdddrec.dddgen = ps2.psgen;
           locdddrec.dddtzon = ps2.pstzon;
           locdddrec.dddpzon = ps2.pspzon;
           locdddrec.dddszon = ps2.psszon;
           locdddrec.ddduseq = ps2.psunld;
720dA      locdddrec.dddmaxc = ps2.psmaxc;
           locdddrec.dddstpsplt = 0;
           locdddrec.ddditmsplt = 0;
         endif;

         write dddrec locdddrec;

         // Create Pallets for location

         CrtPallets(whse: rtid: group: gen: ps2.psrow: ps2.pscol: locdddrec);

       enddo;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  CrtPallets    Create records for a pallets
     *----------------------------------------------------------------

     p CrtPallets      b

     * Local Files

     Fpltsum2   if   e           k disk

     d CrtPallets      pi
     d  whse                          3  0 const
     d  rtid                          5    const
     d  group                         1    const
     d  gen                           1  0 const
     d  row                           3  0 const
     d  col                           3  0 const
     d  indddrec                           const likerec(dddrec: *output)

     * Local File Data Structures

     d ps2             ds                  likerec(psrec)

     * Local Variables

     d locdddrec       ds                  likerec(dddrec: *output)

      /free

       locdddrec = indddrec;
       locdddrec.dddpid = locdddrec.dddid;

       // Loop through PLTSUM Pallet records for location

       // pltsum2 - whse,rtid,type,gen,row,col

       setll (Whse: rtid: 'P': gen: row: col) pltsum2;

       dow forever;

         reade (whse: rtid: 'P': gen: row: col) pltsum2 ps2;
         if %eof(pltsum2);
           leave;
         endif;

         if ps2.pspcs = 0;
           iter;
         endif;

         // Create Pallet record

         locdddrec.dddid = 'plid' + %char(ps2.psplid);
         locdddrec.dddlevel = PALLETLVL;
         locdddrec.dddplid = ps2.psplid;
         locdddrec.dddpalnum = ps2.pspal#;
         locdddrec.dddgen = ps2.psgen;
         locdddrec.dddcomp = ps2.pscomp;
         locdddrec.dddtzon = ps2.pstzon;
         locdddrec.dddpzon = ps2.pspzon;
         locdddrec.dddszon = ps2.psszon;
         locdddrec.dddstp1 = ps2.psstp1;
         locdddrec.dddstp2 = ps2.psstp2;
         locdddrec.ddduseq = ps2.psunld;
720dA    locdddrec.dddmaxc = ps2.psmaxc;
720eA    locdddrec.dddmaxw = GetZoneMaxWgt(ps2.pstzon);
         locdddrec.dddstpsplt = 0;
         locdddrec.ddditmsplt = 0;

         write dddrec locdddrec;

         // Create Stops for pallet

         CrtStops(whse: rtid: ps2.psplid: locdddrec);

       enddo;

       // Loop through PLTSUM Bulk records for location

       // pltsum2 - whse,rtid,type,gen,row,col

       setll (Whse: rtid: 'B': gen: row: col) pltsum2;

       dow forever;

         reade (whse: rtid: 'B': gen: row: col) pltsum2 ps2;
         if %eof(pltsum2);
           leave;
         endif;

         if ps2.pspcs = 0;
           iter;
         endif;

         // Create Pallet record

         locdddrec.dddid = 'plid' + %char(ps2.psplid);
         locdddrec.dddlevel = PALLETLVL;
         locdddrec.dddplid = ps2.psplid;
         locdddrec.dddpalnum = ps2.pspal#;
         locdddrec.dddgen = ps2.psgen;
         locdddrec.dddcomp = ps2.pscomp;
         locdddrec.dddtzon = ps2.pstzon;
         locdddrec.dddpzon = ps2.pspzon;
         locdddrec.dddszon = ps2.psszon;
         locdddrec.dddstp1 = ps2.psstp1;
         locdddrec.dddstp2 = ps2.psstp2;
         locdddrec.ddduseq = ps2.psunld;
720dA    locdddrec.dddmaxc = ps2.psmaxc;
720eA    locdddrec.dddmaxw = GetZoneMaxWgt(ps2.pstzon);
         locdddrec.dddstpsplt = 0;
         locdddrec.ddditmsplt = 0;

         write dddrec locdddrec;

         // Create Stops for pallet

         CrtStops(whse: rtid: ps2.psplid: locdddrec);

       enddo;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  CrtStops    Create records for a stops
     *----------------------------------------------------------------

     p CrtStops        b

     * Local Files

     Fworklbl6  if   e           k disk

     d CrtStops        pi
     d  whse                          3  0 const
     d  rtid                          5    const
     d  plid                          7  0 const
     d  indddrec                           const likerec(dddrec: *output)

     * Local File Data Structures

     d lw6             ds                  likerec(lwrec)

     * Local Variables

     d lastStop        s                   like(lw6.lwstop)
     d lastOrd         s                   like(lw6.lword)
     d lastMltOrd      s              1  0
     d locdddrec       ds                  likerec(dddrec: *output)
720fAd stopId          s              2  0
720fAd extDesc         s             30

      /free

       locdddrec = indddrec;
       locdddrec.dddpid = locdddrec.dddid;
720dA  locdddrec.dddmaxc = 0;
720eA  locdddrec.dddmaxw = 0;

       // Loop through WORKLBL records for pallet
       // We create the Stop record after-the-fact because we need to
       // check for multiple orders within the Stop.

       // worklbl6 - whse,rtid,plid,stop,type,whdp,aisl,pseq,rlvl,hand

       lastStop = -1;

       setll (Whse: rtid: plid) worklbl6;

       dow forever;

         reade (whse: rtid: plid) worklbl6 lw6;

         if %eof(worklbl6);

           if lastStop <> -1;

             // Create Stop record

             locdddrec.dddord = lastOrd;
             locdddrec.dddmltord = lastmltord;

             locdddrec.dddstpsplt = ChkStopSplit(locdddrec.dddwhse:
                                                 locdddrec.dddrtid:
                                                 locdddrec.dddcomp:
                                                 locdddrec.dddtzon:
                                                 locdddrec.dddpzon:
                                                 locdddrec.dddszon:
                                                 locdddrec.dddplid:
                                                 locdddrec.dddstop
                                    );
             locdddrec.ddditmsplt = 0;

             // Create Items for stop

             CrtItems(whse: rtid: plid: lastStop: locdddrec);

750 A        // Write Truck Zone from items
750 A        if mrgTzon <> *blanks;
750 A           locdddrec.dddtzon = mrgtzon;
750 A           locdddrec.dddszon = mrgszon;
750 A           locdddrec.dddpzon = mrgpzon;
750 A           locdddrec.dddcomp = mrgcomp;
750 A        endif;

             write dddrec locdddrec;


           endif;

           leave;

         endif;

         // When Stop changes

         if lw6.lwstop <> lastStop;

           if lastStop <> -1;

             locdddrec.dddord = lastOrd;
             locdddrec.dddmltord = lastmltord;

             chain (dddwhse: dddord) ordh;
             if not %found(ordh);
              clear ohrec;
             endif;

             locdddrec.dddstpsplt = ChkStopSplit(locdddrec.dddwhse:
                                                 locdddrec.dddrtid:
                                                 locdddrec.dddcomp:
                                                 locdddrec.dddtzon:
                                                 locdddrec.dddpzon:
                                                 locdddrec.dddszon:
                                                 locdddrec.dddplid:
                                                 locdddrec.dddstop
                                    );


             // Create Items for stop

             CrtItems(whse: rtid: plid: lastStop: locdddrec);

750 A        // Write Truck Zone from items
750 A        if mrgTzon <> *blanks;
750 A           locdddrec.dddtzon = mrgtzon;
750 A           locdddrec.dddszon = mrgszon;
750 A           locdddrec.dddpzon = mrgpzon;
750 A           locdddrec.dddcomp = mrgcomp;
750 A        endif;

             write dddrec locdddrec;

           endif;

           // Save Stop info

           //locdddrec.dddid = 'plid' + %char(lw6.lwpal#)
           //                + 's' + %char(lw6.lwstop);
           locdddrec.dddid = 's' + %char(lw6.lwstop)
                           + 'p' + %char(lw6.lwpal#);
           locdddrec.dddlevel = STOPLVL;
           locdddrec.dddstop = lw6.lwstop;
720fD      //locdddrec.dddhststp = lw6.lwstop;

720fA      GetStop('*ORDSTP': lw6.lwwhse: lw6.lwrte: lw6.lword:
720fA              stopid: locdddrec.dddhststp: locdddrec.ddddrop:
720fA              extdesc: locdddrec.dddstpdrp);

           lastStop = lw6.lwstop;
           lastOrd = lw6.lword;
           lastMltOrd = 0;

         endif;

         // Check if Stop has multiple orders

         if lw6.lword <> lastOrd;
           lastMltOrd = 1;
         endif;

       enddo;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  CrtItems    Create records for a item
     *----------------------------------------------------------------

     p CrtItems        b

     * Local Files

     Fworklbl6  if   e           k disk

     d CrtItems        pi
     d  whse                          3  0 const
     d  rtid                          5    const
     d  plid                          7  0 const
     d  stop                          2  0 const
     d  indddrec                           const likerec(dddrec: *output)

     * Local File Data Structures

     d lw6             ds                  likerec(lwrec)

     * Local Variables

     d lastStop        s                   like(lw6.lwstop)
     d lastOrd         s                   like(lw6.lword)
     d lastMltOrd      s              1  0
     d totePlid        s                   like(lw6.lwpal#)
     d locdddrec       ds                  likerec(dddrec: *output)
730aAd pseq            s            100    varying

      /free

       locdddrec = indddrec;
       locdddrec.dddpid = locdddrec.dddid;

       // Loop through WORKLBL records for pallet/stop

       // worklbl6 - whse,rtid,plid,stop,type,whdp,aisl,pseq,rlvl,hand

       lastStop = -1;

       setll (Whse: rtid: plid: stop) worklbl6;

       dow forever;

         reade (whse: rtid: plid: stop) worklbl6 lw6;

         if %eof(worklbl6);
           leave;
         endif;

         // Create Item record

         chain (lw6.lwwhse: lw6.lwitem) piritem;
         if not %found(piritem);
           clear itrec;
         endif;

750 A    mrgTzon = lw6.lwtzon;
750 A    mrgSzon = lw6.lwszon;
750 A    mrgpzon = lw6.lwpzon;
750 A    mrgComp = lw6.lwcomp;
750 A    locdddrec.dddtzon = lw6.lwtzon;
750 A    locdddrec.dddszon = lw6.lwszon;
750 A    locdddrec.dddpzon = lw6.lwpzon;
750 A    locdddrec.dddcomp = lw6.lwcomp;
         locdddrec.dddid = 'lbl' + %char(lw6.lwlbl#);
         locdddrec.dddlevel = ITEMLVL;

         if lw6.lwtype = 'M' and %subst(lw6.lwitem:1:5) = 'TOTE ';
           locdddrec.ddditmtyp = 'T';
           locdddrec.dddlbltot = lw6.lwlbl#;
           locdddrec.dddlblitm = lw6.lwlbl#;
         else;
           locdddrec.ddditmtyp = 'I';
           locdddrec.dddlbltot = 0;
           locdddrec.dddlblitm = lw6.lwlbl#;
        endif;

         locdddrec.dddlbltyp = lw6.lwtype;
         locdddrec.dddorgcmp = lw6.lwcomp;
         locdddrec.dddorgzon = lw6.lwtzon;
         locdddrec.dddutyp = lw6.lwutyp;
         locdddrec.ddducod = lw6.lwucod;
         locdddrec.dddpcs = lw6.lwqalc;
         locdddrec.dddcube = lw6.lwcube;
         locdddrec.dddwgt = lw6.lwswgt;

         locdddrec.dddstpsplt = 0;
         locdddrec.ddditmsplt = ChkItemSplit(lw6);
730aA
730aA    // Create field to use with PSeq Sort button
730aA
730aA    pseq = %editc(lw6.lwlvl2: 'X')
730aA         + lw6.lwwhdp
730aA         + lw6.lwaisl
730aA         + %editc(lw6.lwpseq: 'X')
730aA         + %editc(lw6.lwrlvl: 'X')
730aA         + lw6.lwhand
730aA         + %editc(lw6.lwlbl#: 'X');

         jsonDepth = 0;
         jsonLine = '';

         JsonStartObj();

           JsonAddPair('lvl': %char(locdddrec.dddLevel));
           JsonAddPair('id': locdddrec.dddid);
           JsonAddPair('pid': locdddrec.dddpid);
           JsonAddPair('comp': locdddrec.dddorgcmp);
           JsonAddPair('itype': locdddrec.ddditmtyp);
           JsonAddPair('cube': %char(locdddrec.dddcube));
           JsonAddPair('wgt': %char(locdddrec.dddwgt));
           JsonAddPair('pcs': %char(locdddrec.dddpcs));
           JsonAddPair('itm': lw6.lwitem);
           JsonAddPair('slt': lw6.lwdisp);
740 A      JsonAddPair('cccod': 'cc..');
           JsonAddPair('lbl': %char(lw6.lwlbl#));
           if locdddrec.ddditmsplt = 1;
             JsonAddPair('split': 'Y');
           endif;
730aA      JsonAddPair('pseq': pseq);

           JsonStartObj('fields');
740 A        // Setup new display value to color code for Class and Category
740 A        JsonStartObj('cccod');
740 A          JsonAddPair('dsp': '...');
740 A          // For Items add any class codes for given item for category
740 A          bfccatcls=*off;
740 A          qryCat=*blanks;
740 A          qryDesc=*blanks;
740 A          exec sql select ifcat,icdesc into :qryCat,:qryDesc
740 A                           from itemfld,itemcat
740 A                     where ifwhse=:lw6.lwwhse and ifitem=:lw6.lwitem
740 A                            and ifcat=iccode
740 A                         fetch first row only;
740 A          if sqlstt='00000' and qryCat<>*blanks;
740 A            // add for each color set in pircolorsd
740 A            setll (lw6.lwwhse:'CAT') pircolorsd;
740 A            dow forever=forever;
740 A              reade (lw6.lwwhse:'CAT') pircolorsd;
740 A              if %eof(pircolorsd) or not %equal(pircolorsd);
740 A                leave;
740 A              endif;
740 A              if clrdcode <> qryCat;
740 A                iter;
740 A              endif;
740 A              JsonAddPair('bg': 'cat' + %trim(qryCat));
740 A              JsonAddPair('dpd': %trim(locdddrec.dddpid));
740 A              JsonAddPair('cdsc': %trim(qryDesc));
740 A              bfccatcls=*on;
740 A            enddo;
740 A          endif;
740 A
740 A          // For Items add any class codes for given item for bfc class
               qryDesc=*blanks;
740 A          setll (lw6.lwwhse:lw6.lwitem) itemcls;
740 A          dow forever=forever;
740 A            reade (lw6.lwwhse:lw6.lwitem) itemcls;
740 A            if %eof(itemcls) or not %equal(itemcls);
740 A              leave;
740 A            endif;
740 A            qryCls=iclcde;
740 A            // add for each color set in pircolorsd
740 A            setll (lw6.lwwhse:'CLS') pircolorsd;
740 A            dow forever=forever;
740 A              reade (lw6.lwwhse:'CLS') pircolorsd;
740 A              if %eof(pircolorsd) or not %equal(pircolorsd);
740 A                leave;
740 A              endif;
740 A              if clrdcode <> qryCls;
740 A                iter;
740 A              endif;
740 A              JsonAddPair('bg': 'cls' + %trim(qryCls));
740 A              exec sql select cadesc into :qryDesc
740 A                          from class
740 A                       where cacode=:qrycls
740 A                        fetch first row only;
740 A              if qryDesc<>*blanks;
740 A                JsonAddPair('cdsc': %trim(qryDesc));
740 A              endif;
740 A              if not bfccatcls;
740 A                JsonAddPair('dpd': %trim(locdddrec.dddpid));
740 A              endif;
740 A            enddo;
740 A          enddo;
740 A        JsonEndObj();

             JsonStartObj('itm');
               JsonAddPair('dsp': %trim(lw6.lwitem));
               if locdddrec.ddditmsplt = 1;
                 JsonAddPair('bg': 'redltr');
               endif;
             JsonEndObj();


             JsonStartObj('dsc');
                 JsonAddPair('dsp': '- ' + %trim(itdesc));
               if locdddrec.ddditmsplt = 1;
                 JsonAddPair('bg': 'redltr');
               endif;
             JsonEndObj();

             JsonStartObj('cube');
720gD          //JsonAddPair('dsp': 'C: ' + %trim(%editc(locdddrec.dddcube:'P')));
720gM          JsonAddPair('dsp': 'C: '
720gM                      + %trim(%editc(%dech(locdddrec.dddcube:7:1):'P')));
               JsonAddPair('bg': 'cubeFont');
             JsonEndObj();

             JsonStartObj('wgt');
720gD          //JsonAddPair('dsp': 'W: ' + %trim(%editc(locdddrec.dddwgt:'P')));
720gM          JsonAddPair('dsp': 'W: '
720gM                      + %trim(%editc(%inth(locdddrec.dddwgt):'P')));
             JsonEndObj();

             JsonStartObj('pcs');
               JsonAddPair('dsp': 'P: ' + %trim(%editc(locdddrec.dddpcs:'P')));
             JsonEndObj();

             JsonStartObj('um');
               JsonAddPair('dsp': 'Um: ' + %trim(lw6.lwucod));
             JsonEndObj();

             JsonStartObj('dpt');
               JsonAddPair('dsp': 'Dept: ' + %trim(lw6.lwwhdp));
             JsonEndObj();

             JsonStartObj('typ');
               JsonAddPair('dsp': 'Type: ' + %trim(lw6.lwtype));
             JsonEndObj();

             JsonStartObj('slt');
               JsonAddPair('dsp': 'Slot: ' + %trim(lw6.lwdisp));
             JsonEndObj();

           //  JsonStartObj('lbl');
           //    JsonAddPair('dsp': 'L: '+ %char(lw6.lwlbl#));
           //  JsonEndObj();

           JsonEndObj();

         JsonEndObj();

         locdddrec.dddjson = jsonLine;

         write dddrec locdddrec;

         // For a Tote, create corresponding item records

         if locdddrec.ddditmtyp = 'T';
           totePlid = GetTotePlid(whse: lw6.lwctr#);
           if totePlid <> -1;
             CrtToteItems(whse: rtid: totePlid: locdddrec);
           endif;
         endif;

       enddo;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  CrtToteItems    Create records for a tote
     *----------------------------------------------------------------

     p CrtToteItems    b

     * Local Files

     Fworklbl6  if   e           k disk

     d CrtToteItems    pi
     d  whse                          3  0 const
     d  rtid                          5    const
     d  plid                          7  0 const
     d  indddrec                           const likerec(dddrec: *output)

     * Local File Data Structures

     d lw6             ds                  likerec(lwrec)

     * Local Variables

     d locdddrec       ds                  likerec(dddrec: *output)

      /free

       locdddrec = indddrec;
       locdddrec.dddpid = locdddrec.dddid;

       // Loop through WORKLBL records for pallet/stop

       // worklbl6 - whse,rtid,plid,stop,type,whdp,aisl,pseq,rlvl,hand

       setll (Whse: rtid: plid) worklbl6;

       dow forever;

         reade (whse: rtid: plid) worklbl6 lw6;

         if %eof(worklbl6);
           leave;
         endif;

         // Create Item record

         chain (lw6.lwwhse: lw6.lwitem) piritem;
         if not %found(piritem);
           clear itrec;
         endif;

         locdddrec.dddid = 'lbl' + %char(lw6.lwlbl#);
         locdddrec.dddlevel = TOTEITEMLVL;

         locdddrec.ddditmtyp = 'I';
         locdddrec.dddlblitm = lw6.lwlbl#;
         locdddrec.dddlbltyp = lw6.lwtype;
         locdddrec.dddorgcmp = lw6.lwcomp;
         locdddrec.dddorgzon = lw6.lwtzon;
         locdddrec.dddutyp = lw6.lwutyp;
         locdddrec.ddducod = lw6.lwucod;
         locdddrec.dddpcs = lw6.lwqalc;
         locdddrec.dddcube = lw6.lwcube;
         locdddrec.dddwgt = lw6.lwswgt;

         jsonDepth = 0;
         jsonLine = '';

         JsonStartObj();

           JsonAddPair('lvl': %char(locdddrec.dddLevel));
           JsonAddPair('id': locdddrec.dddid);
           JsonAddPair('pid': locdddrec.dddpid);
           JsonAddPair('comp': locdddrec.dddorgcmp);
           JsonAddPair('itype': locdddrec.ddditmtyp);

           JsonStartObj('fields');

             JsonStartObj('itm');
               JsonAddPair('dsp': lw6.lwitem);
             JsonEndObj();

             JsonStartObj('cube');
720gD          //JsonAddPair('dsp': 'C: ' + %trim(%editc(locdddrec.dddcube:'P')));
720gM          JsonAddPair('dsp': 'C: '
720gM                      + %trim(%editc(%dech(locdddrec.dddcube:7:1):'P')));
             JsonEndObj();

             JsonStartObj('wgt');
720gD          //JsonAddPair('dsp': 'W: ' + %trim(%editc(locdddrec.dddwgt:'P')));
720gM          JsonAddPair('dsp': 'W: '
720gM                      + %trim(%editc(%inth(locdddrec.dddwgt):'P')));
             JsonEndObj();

             JsonStartObj('pcs');
               JsonAddPair('dsp': 'P: ' + %trim(%editc(locdddrec.dddpcs:'P')));
             JsonEndObj();

             JsonStartObj('dsc');
               JsonAddPair('dsp': 'Desc: ' + %trim(itdesc));
             JsonEndObj();

             JsonStartObj('um');
               JsonAddPair('dsp': 'Um: ' + %trim(lw6.lwucod));
             JsonEndObj();

             JsonStartObj('dpt');
               JsonAddPair('dsp': 'Dept: ' + %trim(lw6.lwwhdp));
             JsonEndObj();

             JsonStartObj('typ');
               JsonAddPair('dsp': 'Type: ' + %trim(lw6.lwtype));
             JsonEndObj();

             JsonStartObj('slt');
               JsonAddPair('dsp': 'Slot: ' + %trim(lw6.lwdisp));
             JsonEndObj();

          //   JsonStartObj('lbl');
          //     JsonAddPair('dsp': 'L: '+ %char(lw6.lwlbl#));
          //   JsonEndObj();

           JsonEndObj();

         JsonEndObj();

         locdddrec.dddjson = jsonLine;

         write dddrec locdddrec;

       enddo;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  DeleteRecs   Delete records from DDDETAIL file
     *----------------------------------------------------------------

     p DeleteRecs      b
     d DeleteRecs      pi
     d  type                         10    const
     d  whse                          3  0 const
     d  rtid                          5    const
     d  snap                          2  0 const options(*nopass)
     d  group                         1    const options(*nopass)
     d  row                           3  0 const options(*nopass)
     d  col                           2  0 const options(*nopass)
     d  plid                          7  0 const options(*nopass)

      /free

       select;
         when type = 'ROUTE';
           setll (whse: rtid) dddetail2;

         when type = 'TRUCK';
           setll (whse: rtid: 0) dddetail2;

         when type = 'LOCATION';
           setll (whse: rtid: snap: group: row: col) dddetail2;

         when type = 'PALLET';
           setll (whse: rtid: snap: group: row: col: plid) dddetail2;

         when type = 'PALLETSEC';

         when type = 'STOP';

         when type = 'ITEM';

       endsl;

       dow forever;

         select;
           when type = 'ROUTE';
             reade (whse: rtid) dddetail2;

           when type = 'TRUCK';
720hD        //reade (whse: rtid) dddetail2;
720hA        reade (whse: rtid: 0) dddetail2;

           when type = 'LOCATION';
             reade (whse: rtid: snap: group: row: col) dddetail2;

           when type = 'PALLET';
             reade (whse: rtid: snap: group: row: col: plid) dddetail2;

           when type = 'PALLETSEC';

           when type = 'STOP';

           when type = 'ITEM';

         endsl;

         if %eof(dddetail2);
           leave;
         endif;

         delete dddrec2;

       enddo;

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

720aA*----------------------------------------------------------------
720aA*  GetGrandTtl    Get grand total (Truck + Overflow)
720aA*----------------------------------------------------------------
720aA
720aAp GetGrandTotal   b
720aAd GetGrandTotal   pi
     d ttlPcs                              like(dddpcs)
     d ttlCube                             like(dddcube)
     d ttlWgt                              like(dddwgt)
740 Ad ttlPlid                             like(dddplid)

      /free

740 A   ganyRow=0;
740 A   GetMaxColumns(ganyrow);        // result used in GetSideTotals
740 D   //exec sql select sum(dddpcs), sum(dddcube), sum(dddwgt)
740aD   //exec sql select sum(dddpcs), sum(dddcube), sum(dddwgt),
740aD   //          (select count(distinct dddplid) from
740aD   //            dddetail where dddwhse=:pWhse and
740aD   //               dddrtid=:pRtid and dddsnap=0 and
740aD   //               dddlevel=2)
740aD             //into :ttlPcs, :ttlCube, :ttlWgt
740aD   //          into :ttlPcs, :ttlCube, :ttlWgt, :ttlPlid
740aD   //         from dddetail
740aD   //         where dddwhse = :pWhse
740aD   //           and dddrtid = :pRtid
740aD   //           and dddsnap = 0
740aD    //          and dddlevel = :LOCATIONLVL;
740aA   // Change to dynamic query to control file name
740aA   if inRtnCode = 'LIVE';
740aA     dddfile = 'DDDETAIL';
740aA   else;
740aA     dddfile = 'DDDETAILH';
740aA   endif;
740aA   sqlstmt = 'select sum(dddpcs), sum(dddcube), sum(dddwgt),' +
740aA             ' (select count(distinct dddplid) from ' +
740aA             %trim(dddfile) + ' where dddwhse=' + %char(pWhse) +
740aA             ' and dddrtid=' + sq + %trim(pRtid) + sq +
740aA             ' and dddsnap=0 and ' + 'dddlevel=2) from ' +
740aA             %trim(dddfile) + ' where dddwhse=' +
740aA             %char(pWhse) + ' and dddrtid=' + sq + %trim(pRtid) + sq +
740aA             ' and dddsnap=0  and dddlevel=' + %char(locationlvl);
740aA   exec sql PREPARE tp FROM :SqlStmt;
740aA   exec sql DECLARE ttpcs SCROLL CURSOR FOR tp;
740aA   exec sql OPEN ttpcs;
740aA   exec sql fetch first from ttpcs
750 M   into :ttlPcs:ttlPcs_Ind, :ttlCube:ttlCube_Ind,
750 A        :ttlWgt:ttlWgt_Ind, :ttlPlid:ttlPlid_Ind;

        if sqlstt <> sqlSuccess;
750 A   if ttlPcs_Ind = -1;
750 A      ttlPcs=0;
750 A   endif;

750 A   if ttlCube_Ind = -1;
750 A      ttlCube=0;
750 A   endif;

750 A   if ttlWgt_Ind = -1;
750 A      ttlWgt=0;
750 A   endif;

750 A   if ttlPlid_Ind = -1;
750 A      ttlPlid=0;
750 A   endif;
        endif;

740aA   exec sql close ttpcs;

      /end-free

     p                 e

720aA*----------------------------------------------------------------
720aA*  GetMaxColumns  Get maximum column, used for side determination
720aA*                 DDDETAIL must be popluated first
720aA*----------------------------------------------------------------
720aA
720aAp GetMaxColumns   b
720aAd GetMaxColumns   pi
     d row                                 like(dddrow)

     * Local Variables

     d maxCol          s              3  0

      /free

740 A   // if passed row is zero get first row to calc values below
740 A   // This occurs when called from GetSideTotals to ensure min and max
740 A   // values are available for new sql used to get pallet count for headers
740 A   if row = *zeros;
740aD      //exec sql select dddrow into :row
740aD      //              from dddetail
740aD      //      where dddwhse = :pWhse
740aD      //        and dddrtid = :pRtid
740aD      //        and dddsnap = 0
740aD      //        and dddgroup = 'M'
740aD      //        and dddlevel = :LOCATIONLVL
740aD      //    fetch first row only;
740aA      // make dynamic to control file
740aA      if inRtnCode = 'LIVE';
740aA        dddfile = 'DDDETAIL';
740aA      else;
740aA        dddfile = 'DDDETAILH';
740aA      endif;
740aA      sqlstmt = 'select dddrow from ' + %trim(dddfile) +
740aA                ' where dddwhse=' + %char(pwhse) + ' and ' +
740aA                'dddrtid=' + sq + %trim(prtid) + sq + ' and dddsnap=0' +
740aA                ' and dddgroup=' + sq + 'M' + sq + ' and ' +
740aA                'dddlevel=' + %char(locationlvl);
740aA      exec sql PREPARE mr FROM :SqlStmt;
740aA      exec sql DECLARE mxrow SCROLL CURSOR FOR mr;
740aA      exec sql OPEN mxrow;
740aA      exec sql fetch first from mxrow into :row;
740aA      exec sql close mxrow;
740aD   endif;

740aD   //exec sql select max(dddcol) into :maxCol
740aD   //         from dddetail
740aD   //         where dddwhse = :pWhse
740aD   //           and dddrtid = :pRtid
740aD   //           and dddsnap = 0
740aD   //           and dddgroup = 'M'
740aD   //           and dddlevel = :LOCATIONLVL
740aD   //           and dddrow = :row;
740aA   // make dynamic to control file
740aA      if inRtnCode = 'LIVE';
740aA        dddfile = 'DDDETAIL';
740aA      else;
740aA        dddfile = 'DDDETAILH';
740aA      endif;
740aA      sqlstmt = 'select max(dddcol) from ' + %trim(dddfile) +
740aA                ' where dddwhse=' + %char(pWhse) +
740aA                ' and dddrtid=' + sq + %trim(dddrtid) + sq +
740aA                ' and dddsnap=0 and dddgroup=' + sq + 'M' + sq +
740aA                ' and dddlevel=' + %char(locationlvl) +
740aA                ' and dddrow=' + %char(row);
740aA      exec sql PREPARE mc FROM :SqlStmt;
740aA      exec sql DECLARE mxcol SCROLL CURSOR FOR mc;
740aA      exec sql OPEN mxcol;
740aA      exec sql fetch first from mxcol
740aA      into :maxCol;
        if sqlstt <> sqlSuccess;
          maxCol = 2;
        endif;
740aA   exec sql close mxcol;

        gMaxLeftCol = %div(maxCol: 2);
        gMinRightCol = gMaxLeftCol + 1 + %rem(maxCol: 2);

      /end-free

     p                 e

720aA*----------------------------------------------------------------
720aA*  GetSideTtl    Get side total
720aA*----------------------------------------------------------------
720aA
720aAp GetSideTotal    b
720aAd GetSideTotal    pi
     d side                           1    const
     d ttlPcs                              like(dddpcs)
     d ttlCube                             like(dddcube)
     d ttlWgt                              like(dddwgt)
740 Ad ttlPlid                             like(dddPlid)

740 Ad colValue        s              2  0

      /free

740aA   // make file dynamic
740aA   if inRtnCode='LIVE';
740aA     dddfile='DDDETAIL';
740aA   else;
740aA     dddfile='DDDETAILH';
740aA   endif;
740 A   // Removed old code for clarity.  Old sql found in saved version
740 A   sqlStmt = 'select sum(dddpcs), sum(dddcube), sum(dddwgt),' +
740aD             //'  (select count(distinct dddplid) from dddetail' +
740aM             '  (select count(distinct dddplid) from ' + %trim(dddfile) +
740 A             '    where dddwhse=' + %char(pWhse) + ' and dddrtid=' +
740 A                    sq + %trim(dddrtid) + sq + ' and dddsnap=0' +
740 A             '      and dddlevel=4 and dddgroup=' + sq + 'M' + sq;
740 A   // Determine condition for Left, Right or Middle column locations
740 A   select;
740 A     when side='L';
740 A       sqlStmt = %trim(sqlStmt) + ' and dddcol<=' + %char(gMaxLeftCol);
740 A     when side='R';
740 A       sqlStmt = %trim(sqlStmt) + ' and dddcol>=' + %char(gMinRightCol);
740 A     other;
740 A       sqlStmt = %trim(sqlStmt) + ' and dddcol>' + %char(gMaxLeftCol) +
740 A                ' and dddcol<' + %char(gMinRightCol);
740 A   endsl;
740aD   //sqlStmt = %trim(sqlStmt) + ') from dddetail ' +
740aM   sqlStmt = %trim(sqlStmt) + ') from ' + %trim(dddfile) +
740 A   '         where dddwhse=' + %char(pWhse) +
740 A   '           and dddrtid=' + sq + %trim(prtid) + sq +
740 A   '           and dddsnap=0 and dddgroup=' + sq + 'M' + sq +
740 A   '           and dddlevel=' + %char(locationlvl) +
740 A   '           and dddside=' + sq + side + sq;
740 A   exec sql PREPARE gs FROM :SqlStmt;
740 A   exec sql DECLARE getsd SCROLL CURSOR FOR gs;
740 A   exec sql OPEN getsd;
740 A
740 A   exec sql fetch first from getsd
750 M   into :ttlPcs:ttlPcs_Ind, :ttlCube:ttlCube_Ind,
750 A        :ttlWgt:ttlWgt_Ind, :ttlPlid:ttlPlid_Ind;

        if sqlstt <> sqlSuccess;
750 A   if ttlPcs_Ind = -1;
750 A      ttlPcs=0;
750 A   endif;

750 A   if ttlCube_Ind = -1;
750 A      ttlCube=0;
750 A   endif;

750 A   if ttlWgt_Ind = -1;
750 A      ttlWgt=0;
750 A   endif;

750 A   if ttlPlid_Ind = -1;
750 A      ttlPlid=0;
750 A   endif;
        endif;

740 A   exec sql close getsd;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetTotePlid    Get Tote pallet id
     *----------------------------------------------------------------

     p GetTotePlid     b

     * Local Files

     Fworklbl   if   e           k disk

     d GetTotePlid     pi             7  0
     d  whse                          3  0 const
     d  lbl#                          7  0 const

     * Local File Data Structures

     d lw              ds                  likerec(lwrec)

      /free

       chain (lbl#) worklbl lw;

       if not %found(worklbl);
         return -1;
       else;
         return lw.lwpal#;
       endif;

      /end-free

     p                 e

720eA*----------------------------------------------------------------
720eA*  GetZoneWgt    Get Zone maximum weight
720eA*----------------------------------------------------------------
720eA
720eAp GetZoneMaxWgt   b
     d GetZoneMaxWgt   pi             4s 0
     d  zone                               const like(dddtzon)

      /free

       chain ('*PICK': pWhse: thztmp: zone) optionz;
       If not %found(optionz);
         opfwgt = 0;
       endif;

740 A  monitor;
740 A   opfwgt = opfwgt;
740 A  on-error;
740 A   opfwgt = 0;
740 A  endmon;
740 D  //if opfwgtalpha = *blanks;
740 D  //  opfwgt = 0;
740 D  //endif;

       return opfwgt;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  RebuildColors    Rebuild colors
     *----------------------------------------------------------------

     p RebuildColors   b
     d RebuildColors   pi
     d  whse                          3  0 const

     * Local Variables

     d colorRtid       s              5
720bAD ddRtnCode       s             10
720bAD ddRtnMsg        s            100
720bAd ddRtnStr        s          65535    varying
720bAd rtid            s              5

      /free

       gSnap = 0;
       colorRtid = '*CLRS';

       // Delete records for route from DDDETAIL

       setll (whse: colorRtid: 0) dddetail2;
       dow forever;
         reade (whse: colorRtid: 0) dddetail2;
         if %eof(dddetail2);
           leave;
         endif;
         delete dddrec2;
       enddo;

       // Initialize DDDETAIL fields

       ClearDDDREC();

       dddwhse = whse;
       dddrtid = colorRtid;
       dddGroup = 'C';
       jsonLine = '';

       // Default colors - These must be first

       dddid = 'itemDefault';
       JsonStartObj();
       JsonAddPair(dddid: 'DarkKhaki');
       JsonEndObj();
       dddjson = jsonLine;
       dddrow += 1;
       write dddrec2;
       jsonLine = '';

750bA  // Set Default Color for Mixed Zone Pallets
750bA  chain (Whse: 'MIX ': '*DEFAULT') pircolorsd;
750bA  if %eof(pircolorsd);
750bA    clrdcolor = '#BDB76B';  // DarkKhaki
750bA  endif;
750bA  dddid = 'mixp' + clrdcode;
750bA  JsonStartObj();
750bA  JsonAddPair(dddid: clrdcolor);
750bA  JsonEndObj();
750bA  dddjson = jsonLine;
750bA
750bA  dddrow += 1;
750bA  write dddrec2;
750bA  jsonLine = '';

       // Compartment colors for Defaults

       setll (Whse: 'COMP': '*DEFAULT') pircolorsd;

       dow forever;
         reade (Whse: 'COMP': '*DEFAULT') pircolorsd;
         if %eof(pircolorsd);
           leave;
         endif;

         if clrdcolor = '';
           clrdcolor = '#BDB76B';  // DarkKhaki
         endif;

         dddid = 'comp' + clrdcode;
         JsonStartObj();
         JsonAddPair(dddid: clrdcolor);
         JsonEndObj();
         dddjson = jsonLine;

         dddrow += 1;
         write dddrec2;
         jsonLine = '';

       enddo;

740 A  // Category colors for Defaults
740 A
740 A  setll (Whse: 'CAT': '*DEFAULT') pircolorsd;
740 A
740 A  dow forever;
740 A    reade (Whse: 'CAT': '*DEFAULT') pircolorsd;
740 A    if %eof(pircolorsd);
740 A      leave;
740 A    endif;
740 A
740 A    dddid = 'cat' + clrdcode;
740 A    JsonStartObj();
740 A    JsonAddPair(dddid: clrdcolor);
740 A    JsonEndObj();
740 A    dddjson = jsonLine;
740 A
740 A    dddrow += 1;
740 A    write dddrec2;
740 A    jsonLine = '';
740 A
740 A  enddo;
740 A
740 A  // Class colors for Defaults
740 A
740 A  setll (Whse: 'CLS': '*DEFAULT') pircolorsd;
740 A
740 A  dow forever;
740 A    reade (Whse: 'CLS': '*DEFAULT') pircolorsd;
740 A    if %eof(pircolorsd);
740 A      leave;
740 A    endif;
740 A
740 A    dddid = 'cls' + clrdcode;
740 A    JsonStartObj();
740 A    JsonAddPair(dddid: clrdcolor);
740 A    JsonEndObj();
740 A    dddjson = jsonLine;
740 A
740 A    dddrow += 1;
740 A    write dddrec2;
740 A    jsonLine = '';
740 A
740 A  enddo;

750bA  // Set Default Color for Mixed Zone Pallets
750bA  setll (whse:'MIX') pircolorsd;
750bA  dow forever;
750bA    reade (Whse: 'MIX') pircolorsd;
750bA    if %eof(pircolorsd);
750bA      leave;
750bA    endif;
750bA
750bA    // *DEFAULT was processed above first
750bA    if clrdset='*DEFAULT';
750bA       iter;
750bA    endif;
750bA
750bA    dddid = %trim(clrdset) + 'mixp' + clrdcode;
750bA    JsonStartObj();
750bA    JsonAddPair(dddid: clrdcolor);
750bA    JsonEndObj();
750bA    dddjson = jsonLine;
750bA
750bA    dddrow += 1;
750bA    write dddrec2;
750bA    jsonLine = '';
750bA  enddo;

740 A  // Category colors for Configurations other than *DEFAULT
740 A  setll (Whse: 'CAT') pircolorsh;
740 A
740 A  dow forever;
740 A    reade (Whse: 'CAT') pircolorsh;
740 A    if %eof(pircolorsh);
740 A      leave;
740 A    endif;
740 A
740 A    // *DEFAULT was processed above first
740 A    if clrhset='*DEFAULT';
740 A       iter;
740 A    endif;
740 A
740 A    // loop through Colors Detail file for specific Color Set
740 A    setll (clrhwhse: clrhtype: clrhset) pircolorsd;
740 A
740 A    dow forever;
740 A      reade (clrhwhse: clrhtype: clrhset) pircolorsd;
740 A      if %eof(pircolorsd);
740 A        leave;
740 A      endif;
740 A
740 A      if clrdcolor = '';
740 A        clrdcolor = '#BDB76B';  // DarkKhaki
740 A      endif;
740 A
740 A      dddid = %trim(clrhset) + 'cat' + %trim(clrdcode);
740 A      JsonStartObj();
740 A      JsonAddPair(dddid: clrdcolor);
740 A      JsonEndObj();
740 A      dddjson = jsonLine;
740 A
740 A      dddrow += 1;
740 A      write dddrec2;
740 A      jsonLine = '';
740 A
740 A    enddo;
740 A  enddo;

740 A  // Class colors for Configurations other than *DEFAULT
740 A  setll (Whse: 'CLS') pircolorsh;
740 A
740 A  dow forever;
740 A    reade (Whse: 'CLS') pircolorsh;
740 A    if %eof(pircolorsh);
740 A      leave;
740 A    endif;
740 A
740 A    // *DEFAULT was processed above first
740 A    if clrhset='*DEFAULT';
740 A       iter;
740 A    endif;
740 A
740 A    // loop through Colors Detail file for specific Color Set
740 A    setll (clrhwhse: clrhtype: clrhset) pircolorsd;
740 A
740 A    dow forever;
740 A      reade (clrhwhse: clrhtype: clrhset) pircolorsd;
740 A      if %eof(pircolorsd);
740 A        leave;
740 A      endif;
740 A
740 A      if clrdcolor = '';
740 A        clrdcolor = '#BDB76B';  // DarkKhaki
740 A      endif;
740 A
740 A      dddid = %trim(clrhset) + 'cls' + %trim(clrdcode);
740 A      JsonStartObj();
740 A      JsonAddPair(dddid: clrdcolor);
740 A      JsonEndObj();
740 A      dddjson = jsonLine;
740 A
740 A      dddrow += 1;
740 A      write dddrec2;
740 A      jsonLine = '';
740 A
740 A    enddo;
740 A  enddo;

720bA  // Compartment colors for Configurations other than *DEFAULT
720bA  setll (Whse: 'COMP') pircolorsh;
720bA
720bA  dow forever;
720bA    reade (Whse: 'COMP') pircolorsh;
720bA    if %eof(pircolorsh);
720bA      leave;
720bA    endif;
720bA
720bA    // *DEFAULT was processed above first
720bA    if clrhset='*DEFAULT';
720bA       iter;
720bA    endif;
720bA
720bA    // loop through Colors Detail file for specific Color Set
720bA    setll (clrhwhse: clrhtype: clrhset) pircolorsd;
720bA
720bA    dow forever;
720bA      reade (clrhwhse: clrhtype: clrhset) pircolorsd;
720bA      if %eof(pircolorsd);
720bA        leave;
720bA      endif;
720bA
720bA      if clrdcolor = '';
720bA        clrdcolor = '#BDB76B';  // DarkKhaki
720bA      endif;
720bA
720bA      //dddid = 'comp' + %trim(clrdcode) + %trim(clrhset);
720bA      dddid = %trim(clrhset) + 'comp' + %trim(clrdcode);
720bA      JsonStartObj();
720bA      JsonAddPair(dddid: clrdcolor);
720bA      JsonEndObj();
720bA      dddjson = jsonLine;
720bA
720bA      dddrow += 1;
720bA      write dddrec2;
720bA      jsonLine = '';
720bA
720bA    enddo;
720bA  enddo;

       // Cube colors

       setll (Whse: 'CUBE': '*DEFAULT') pircolorsd;

       dow forever;
         reade (Whse: 'CUBE': '*DEFAULT') pircolorsd;
         if %eof(pircolorsd);
           leave;
         endif;

         if clrdcolor = '';
           iter;
         endif;

         dddid = clrdcode;
         JsonStartObj();
         JsonAddPair(dddid: clrdcolor);
         JsonEndObj();
         dddjson = jsonLine;

         dddrow += 1;
         write dddrec2;
         jsonLine = '';

       enddo;

750bA  // Cube colors, other than *DEFAULT
750bA
750bA  setll (Whse: 'CUBE') pircolorsd;
750bA
750bA  dow forever;
750bA    reade (Whse: 'CUBE') pircolorsd;
750bA    if %eof(pircolorsd);
750bA      leave;
750bA    endif;
750bA
750bA    if clrdcolor = '';
750bA      iter;
750bA    endif;
750bA
750bA    // *DEFAULT was processed above first
750bA    if clrdset='*DEFAULT';
750bA       iter;
750bA    endif;
750bA
750bA    dddid = %trim(clrdset) + clrdcode;
750bA    JsonStartObj();
750bA    JsonAddPair(dddid: clrdcolor);
750bA    JsonEndObj();
750bA    dddjson = jsonLine;
750bA
750bA    dddrow += 1;
750bA    write dddrec2;
750bA    jsonLine = '';
750bA
750bA  enddo;

       // Axle colors

       setll (Whse: 'AXLE': '*DEFAULT') pircolorsd;

       dow forever;
         reade (Whse: 'AXLE': '*DEFAULT') pircolorsd;
         if %eof(pircolorsd);
           leave;
         endif;

         if clrdcolor = '';
           iter;
         endif;

         dddid = clrdcode;
         JsonStartObj();
         JsonAddPair(dddid: clrdcolor);
         JsonEndObj();
         dddjson = jsonLine;

         dddrow += 1;
         write dddrec2;
         jsonLine = '';

       enddo;

750bA  // Axle colors, other than *DEFAULT

750bA  setll (Whse: 'AXLE') pircolorsd;
750bA
750bA  dow forever;
750bA    reade (Whse: 'AXLE') pircolorsd;
750bA    if %eof(pircolorsd);
750bA      leave;
750bA    endif;
750bA
750bA    if clrdcolor = '';
750bA      iter;
750bA    endif;
750bA
750bA    // *DEFAULT was processed above first
750bA    if clrdset='*DEFAULT';
750bA       iter;
750bA    endif;
750bA
750bA    dddid = %trim(clrdset) + clrdcode;
750bA    JsonStartObj();
750bA    JsonAddPair(dddid: clrdcolor);
750bA    JsonEndObj();
750bA    dddjson = jsonLine;
750bA
750bA    dddrow += 1;
750bA    write dddrec2;
750bA    jsonLine = '';
750bA
750bA  enddo;

       // Drag Selected color - This must be the last class

       dddid = 'dragSelected';
       JsonStartObj();
       JsonAddPair(dddid: 'DarkKhaki');
       JsonEndObj();
       dddjson = jsonLine;
       dddrow += 1;
       write dddrec2;
       jsonLine = '';

720bA  // Call program to create DDTASK records
720bA
720bA
720bA  dd430('RBLDCOLORS': '': whse: rtid: pUser: pSessId: pDict: pPgm:
720bA        ddRtnCode: ddRtnMsg: ddRtnStr);

      /end-free
     p                 e

     *----------------------------------------------------------------
     *  RebuildLoc    Rebuild records for location
     *----------------------------------------------------------------

     p RebuildLoc      b
     d RebuildLoc      pi
     d  whse                          3  0 const
     d  rtid                          5    const
     d  snap                          2  0 const
     d  group                         1    const
     d  row                           3  0 const
     d  col                           2  0 const

      /free

       // Delete records for route

       DeleteRecs('LOCATION': whse: rtid: snap: group: row: col);

       // Create Truck (M=Main)

       CrtGroup(whse: rtid: 'M');

       // Create Overflow

       CrtGroup(whse: rtid: 'O');

       // Update level totals

       UpdLevel(whse: rtid: GROUPLVL: STOPLVL);

      /end-free
     p                 e

     *----------------------------------------------------------------
     *  RebuildRte    Rebuild records for route
     *----------------------------------------------------------------

     p RebuildRte      b
     d RebuildRte      pi
     d  whse                          3  0 const
     d  rtid                          5    const

     * Local Variables

     D ddRtnCode       s             10
     D ddRtnMsg        s            100
     d ddRtnStr        s          65535    varying

      /free

       gSnap = 0;

       // Rebuild Colors

       RebuildColors(whse);

       // Delete records for route

       DeleteRecs('ROUTE': whse: rtid);

       // Rebuild pallet numbers in PLTSUM

       or627(whse: rtid);

       // Create Truck (M=Main)

       CrtGroup(whse: rtid: 'M');

       // Create Overflow

       CrtGroup(whse: rtid: 'O');

       // Update level totals

       UpdLevel(whse: rtid: GROUPLVL: STOPLVL);

       // Copy Snap 0 (Current) to Snap 1 (Original) Recs

       setll (whse: rtid: 0) dddetail2;
       dow forever;
         reade (whse: rtid: 0) dddetail2;
         if %eof(dddetail2);
           leave;
         endif;
         dddsnap = 1;
         write dddrec2;
       enddo;

       // Call program to create DDTASK records

       dd430('*CRTALL': '': whse: rtid: pUser: pSessId: pDict: pPgm:
             ddRtnCode: ddRtnMsg: ddRtnStr);

      /end-free
     p                 e

     *----------------------------------------------------------------
     *  RebuildTrk    Rebuild records for truck
     *----------------------------------------------------------------

     p RebuildTrk      b
     d RebuildTrk      pi
     d  whse                          3  0 const
     d  rtid                          5    const

     * Local Variables

     D ddRtnCode       s             10
     D ddRtnMsg        s            100
     d ddRtnStr        s          65535    varying

      /free

       gSnap = 0;

       // Delete records for route snapshot zero, leave snapshot 1.

       DeleteRecs('TRUCK': whse: rtid);

       // Rebuild pallet numbers in PLTSUM

       or627(whse: rtid);

       // Create Truck (M=Main)

       CrtGroup(whse: rtid: 'M');

       // Create Overflow

       CrtGroup(whse: rtid: 'O');

       // Update level totals

       UpdLevel(whse: rtid: GROUPLVL: STOPLVL);

       // Call program to create DDTASK records for truck

       dd430('*RBLDTRUCK': '': whse: rtid: pUser: pSessId: pDict: pPgm:
             ddRtnCode: ddRtnMsg: ddRtnStr);
       if ddRtnCode = '*ERROR';
         pRtnCode = '*ERROR';
         pRtnMsg = ddRtnStr;
         return;
       endif;

      /end-free
     p                 e

     *----------------------------------------------------------------
     *  SumLevel      Summarize Level records
     *
     *    It is assumed the calling routine is sitting on the
     *    DDDDETAIL record (level) to be updated.
     *    It is assumed that we would be updating levels in reverse order.
     *    Therefore, we will calculate the totals for the next level.
     *    For example, if the calling routine is sitting on a level 4
     *    record (Stop/Drop), this routine would summarize the
     *    corresponding level 5 records (Item/Totes).
     *----------------------------------------------------------------

     p SumLevel        b

     * Local Files

740aDF*dddetail1 if   e           k disk
740aMFdddetail1 if   e           k disk    extfile(dddfile) usropn

     d SumLevel        pi

     * Local File Data Structures

     d locdddrec       ds                  likerec(dddrec)

     * Local Variables

     d splitStopFlag   s              1
     d splitItemFlag   s              1

      /free

       dddpcs = 0;
       dddcube = 0;
720dD  //dddmaxc = 0;
       dddcubwrn = 0;
       dddwgt = 0;
720eD  //dddmaxw = 0;
       dddwgtwrn = 0;

       // Initialize some field

       select;

         when dddlevel = GROUPLVL;
           if dddgroup = 'M';
             dddrow = 0;
             dddcol = 0;
           endif;

         when dddlevel = LOCATIONLVL;
           dddstp1 = 0;
           dddstp2 = 0;
           dddstpsplt = 0;
           ddditmsplt = 0;

         when dddlevel = PALLETLVL;
           dddstp1 = 0;
           dddstp2 = 0;
           dddstpsplt = 0;
           ddditmsplt = 0;

         when dddlevel = PLTSECTLVL;
           dddstpsplt = 0;
           ddditmsplt = 0;

         when dddlevel = STOPLVL;
           ddditmsplt = 0;

       endsl;

740aA  // make file dynamic
740aA  if inRtnCode = 'LIVE';
740aA     dddfile='DDDETAIL1';
740aA  else;
740aA     dddfile='DDDETAILH1';
740aA  endif;
740aA  if not %open(DDDETAIL1);
740aA    open dddetail1;
740aA  endif;

       select;

         when dddLevel = GROUPLVL;

           setll (dddWhse: dddrtid: 0: dddgroup: LOCATIONLVL
                 ) dddetail1;

         when dddLevel = LOCATIONLVL;

           setll (dddWhse: dddrtid: 0: dddgroup: PALLETLVL:
                  dddrow: dddcol
                 ) dddetail1;

         when dddLevel = PALLETLVL;

           setll (dddWhse: dddrtid: 0: dddgroup: STOPLVL:
                  dddrow: dddcol: dddplid
                 ) dddetail1;

         when dddLevel = PLTSECTLVL;

           setll (dddWhse: dddrtid: 0: dddgroup: STOPLVL:
                  dddrow: dddcol: dddplid: dddpltsct
                 ) dddetail1;

         when dddLevel = STOPLVL;

           setll (dddWhse: dddrtid: 0: dddgroup: ITEMLVL:
                  dddrow: dddcol: dddplid: dddpltsct:
                  dddstop: ddddrop
                 ) dddetail1;

       endsl;

       dow forever;

         select;

           when dddLevel = GROUPLVL;

             reade (dddWhse: dddrtid: 0: dddgroup: LOCATIONLVL
                   ) dddetail1 locdddrec;

           when dddLevel = LOCATIONLVL;

             reade (dddWhse: dddrtid: 0: dddgroup: PALLETLVL:
                    dddrow: dddcol
                   ) dddetail1 locdddrec;

           when dddLevel = PALLETLVL;

             reade (dddWhse: dddrtid: 0: dddgroup: STOPLVL:
                    dddrow: dddcol: dddplid
                   ) dddetail1 locdddrec;

           when dddLevel = PLTSECTLVL;

             reade (dddWhse: dddrtid: 0: dddgroup: STOPLVL:
                    dddrow: dddcol: dddplid: dddpltsct
                   ) dddetail1 locdddrec;

           when dddLevel = STOPLVL;

             reade (dddWhse: dddrtid: 0: dddgroup: ITEMLVL:
                    dddrow: dddcol: dddplid: dddpltsct:
                    dddstop: ddddrop
                   ) dddetail1 locdddrec;

       endsl;

         if %eof(dddetail1);
           leave;
         endif;

         dddpcs += locdddrec.dddpcs;
         dddcube += locdddrec.dddcube;
         dddwgt += locdddrec.dddwgt;

         // For location and pallet levels, determine From/To Stops

         if dddlevel = PALLETLVL;
           if locdddrec.dddstop < dddstp1 or dddstp1 = 0;
             dddstp1 = locdddrec.dddstop;
           endif;
           if locdddrec.dddstop > dddstp2 or dddstp2 = 0;
             dddstp2 = locdddrec.dddstop;
           endif;
         endif;

         if dddlevel = LOCATIONLVL;
           if locdddrec.dddstp1 < dddstp1 or dddstp1 = 0;
             dddstp1 = locdddrec.dddstp1;
           endif;
           if locdddrec.dddstp2 > dddstp2 or dddstp2 = 0;
             dddstp2 = locdddrec.dddstp2;
           endif;
         endif;

         // Percolate split flags

         select;

           when dddlevel = LOCATIONLVL;
             if locdddrec.dddstpsplt = 1;
               dddstpsplt = 1;
             endif;
             if locdddrec.ddditmsplt = 1;
               ddditmsplt = 1;
             endif;

           when dddlevel = PALLETLVL;
             if locdddrec.dddstpsplt = 1;
               dddstpsplt = 1;
             endif;
             if locdddrec.ddditmsplt = 1;
               ddditmsplt = 1;
             endif;

           when dddlevel = PLTSECTLVL;
             if locdddrec.dddstpsplt = 1;
               dddstpsplt = 1;
             endif;
             if locdddrec.ddditmsplt = 1;
               ddditmsplt = 1;
             endif;

           when dddlevel = STOPLVL;
             if locdddrec.ddditmsplt = 1;
               ddditmsplt = 1;
             endif;

         endsl;

         // For level zero, group 'M',
         // Get max rows/columns

         if dddlevel = GROUPLVL and dddGroup = 'M';
           if locdddrec.dddrow > dddrow;
             dddrow = locdddrec.dddrow;
           endif;
           if locdddrec.dddcol > dddcol;
             dddcol = locdddrec.dddcol;
           endif;
         endif;

       enddo;

740aA  if %open(DDDETAIL1);
740aA    close dddetail1;
740aA  endif;

      /end-free
     p                 e

     *----------------------------------------------------------------
     *  UpdLevel     Update Level values
     *----------------------------------------------------------------

     p UpdLevel        b
     d UpdLevel        pi
     d  whse                          3  0 const
     d  rtid                          5    const
     d  fromLevel                     2  0 const
     d  toLevel                       2  0 const
     d  row                           3  0 const options(*nopass)
     d  col                           2  0 const options(*nopass)

     * Local Variables

     d currLevel       s              2  0
     d limitLocation   s               n
     d lastCol         s                   like(dddcol)
     d lastRow         s                   like(dddrow)
     d zoneMaxCube     s              5  2
     d locdddrec       ds                  likerec(dddrec: *output)

      /free


       // Get information for determining side

       //GetMaxColumns();

       // Determine if we are only updating a specific location

       if %parms >= 6;
         limitLocation = *on;
       else;
         limitLocation = *off;
       endif;

       // Work backwards

       currLevel = toLevel;

       // Loop through levels

       lastCol = 0;
       lastRow = 0;

       dow currLevel >= fromLevel;

         // Update the Truck records

         if limitLocation and currLevel > 0;
           setll (whse: rtid: 0: 'M': currLevel: row: col) dddetail1;
         else;
           setll (whse: rtid: 0: 'M': currLevel) dddetail1;
         endif;

         dow forever;

           if limitLocation and currLevel > 0;
             reade (whse: rtid: 0: 'M': currLevel: row: col) dddetail1;
           else;
             reade (whse: rtid: 0: 'M': currLevel) dddetail1;
           endif;

           if %eof(dddetail1);
             leave;
           endif;

           // Don't sum item levels

           if dddlevel < ITEMLVL;
             SumLevel();
           endif;

           // See if Stop is split

           if dddlevel = STOPLVL;
             dddstpsplt = ChkStopSplit(dddwhse:
                                       dddrtid:
                                       dddcomp:
                                       dddtzon:
                                       dddpzon:
                                       dddszon:
                                       dddplid:
                                       dddstop
                          );
           endif;

           // Set some Location level fields

           if dddlevel = LOCATIONLVL;

             if dddrow <> lastRow or dddcol <> lastCol;
               GetMaxColumns(dddrow);
               lastRow = dddrow;
               lastCol = dddcol;
             endif;

             select;
               when dddcol <= gMaxLeftCol;
                 dddside = 'L';
               when dddcol >= gMinRightCOl;
                 dddside = 'R';
               other;
                 dddside = 'M';
             endsl;

720dD        //dddmaxc = 0;
720dA        if dddmaxc > 0 and dddcube > dddmaxc;
720dA          dddcubwrn = 1;
720dA        else;
               dddcubwrn = 0;
720dA        endif;
720dD        //chain (pWhse: rhtruk: dddrow) trktmpd;
720dD        //if %found(trktmpd);
720dD        //  select;
720dD        //    when dddcol = 1;
720dD        //      dddmaxc = ttdcube1;
720dD        //      if dddcube > ttdcube1;
720dD        //        dddcubwrn = 1;
720dD        //      endif;
720dD        //    when dddcol = 2;
720dD        //      dddmaxc = ttdcube2;
720dD        //      if dddcube > ttdcube2;
720dD        //        dddcubwrn = 1;
720dD        //      endif;
720dD        //    when dddcol = 3;
720dD        //      dddmaxc = ttdcube3;
720dD        //      if dddcube > ttdcube3;
720dD        //        dddcubwrn = 1;
720dD        //      endif;
720dD        //   endsl;
720dD        //endif;

           endif;

720cA      // Set some Pallet level fields
720cA
720cA      if dddlevel = PALLETLVL;
720cA
720dD        //dddmaxc = GetZoneMaxCube(dddtzon);
720cA
720cA        if dddcube > dddmaxc;
720cA          dddcubwrn = 1;
720cA        else;
720cA          dddcubwrn = 0;
720cA        endif;
720eA
720eA        if dddmaxw > 0 and dddwgt > dddmaxw;
720eA          dddwgtwrn = 1;
720eA        else;
720eA          dddwgtwrn = 0;
720eA        endif;
720cA
720cA      endif;

           CreateJSON();
           dddjson = jsonLine;

           update dddrec;

         enddo;

         // Update the Overflow records

         if limitLocation and currLevel >= LOCATIONLVL;
           setll (whse: rtid: 0: 'O': currLevel: row: col) dddetail1;
         else;
           setll (whse: rtid: 0: 'O': currLevel) dddetail1;
         endif;

         dow forever;

           if limitLocation and currLevel >= LOCATIONLVL;
             reade (whse: rtid: 0: 'O': currLevel: row: col) dddetail1;
           else;
             reade (whse: rtid: 0: 'O': currLevel) dddetail1;
           endif;

           if %eof(dddetail1);
             leave;
           endif;


           // Don't sum item levels

           if dddlevel < ITEMLVL;
             SumLevel();
           endif;

           // See if Stop is split

           if dddlevel = STOPLVL;
             dddstpsplt = ChkStopSplit(dddwhse:
                                       dddrtid:
                                       dddcomp:
                                       dddtzon:
                                       dddpzon:
                                       dddszon:
                                       dddplid:
                                       dddstop
                          );
           endif;

720eA      // Set some Pallet level fields
720eA
720eA      if dddlevel = PALLETLVL;
720eA
720eA        if dddcube > dddmaxc;
720eA          dddcubwrn = 1;
720eA        else;
720eA          dddcubwrn = 0;
720eA        endif;
720eA
720eA        if dddmaxw > 0 and dddwgt > dddmaxw;
720eA          dddwgtwrn = 1;
720eA        else;
720eA          dddwgtwrn = 0;
720eA        endif;
720eA
720eA      endif;

           CreateJSON();
           dddjson = jsonLine;

           update dddrec;

         enddo;

         currLevel -= 1;

       enddo;

      /end-free
     p                 e

     *----------------------------------------------------------------
     *  UpdPltNum    Update pallet number
     *----------------------------------------------------------------

     p UpdPltNum       b
     d UpdPltNum       pi
     d  whse                          3  0 const
     d  rtid                          5    const
     d  pltid                         7  0 const
     d  pltnum                        7  0 const

     * Local Variables

     d id              s                   like(dddid)

      /free

       id = 'plid' + %char(pltid);

       chain (whse: rtid: 0: id) dddetail;
       if not %found(dddetail);
         return;
       endif;

       dddpalnum = pltnum;
       ProcessLvl2();
       dddjson = jsonLine;

       update dddrec0;

      /end-free
     p                 e

     *----------------------------------------------------------------
     *  CreateJSON   Create JSON string
     *----------------------------------------------------------------

     p CreateJSON      b
     d CreateJSON      pi

      /free

         jsonLine = '';

         select;

           when dddlevel = GROUPLVL;
             ProcessLvl0();

           when dddlevel = LOCATIONLVL;
             ProcessLvl1();

           when dddlevel = PALLETLVL;
             ProcessLvl2();

           when dddlevel = PLTSECTLVL;
             ProcessLvl3();

           when dddlevel = STOPLVL;
             ProcessLvl4();

           when dddlevel = ITEMLVL;
             ProcessLvl5();

           when dddlevel = TOTEITEMLVL;
             ProcessLvl5();

         endsl;


      /end-free
     p                 e

     *----------------------------------------------------------------
     *  ProcessLvl0   Process Level 0 - Group
     *----------------------------------------------------------------

     p ProcessLvl0     b
     d ProcessLvl0     pi

     * Local Variables

     d ttlPcs          s                   like(dddpcs)
     d ttlCube         s                   like(dddcube)
     d ttlWgt          s                   like(dddwgt)
740 Ad ttlPlid         s                   like(dddplid)
     d lftPcs          s                   like(dddpcs)
     d lftCube         s                   like(dddcube)
     d lftWgt          s                   like(dddwgt)
740 Ad lftPlid         s                   like(dddplid)
     d rgtPcs          s                   like(dddpcs)
     d rgtCube         s                   like(dddcube)
     d rgtWgt          s                   like(dddwgt)
740 Ad rgtPlid         s                   like(dddPlid)
     d midPcs          s                   like(dddpcs)
     d midCube         s                   like(dddcube)
     d midWgt          s                   like(dddwgt)
740 Ad midPlid         s                   like(dddPlid)
     d midPcs2         s                   like(dddpcs)
     d midCube2        s                   like(dddcube)
     d midWgt2         s                   like(dddwgt)
740 Ad midPlid2        s                   like(dddplid)

      /free

       // When processing group M ...

       //if dddid = 'grpM';

         // Get grand totals for truck and overflow

740 M    GetGrandTotal(ttlPcs: ttlCube: ttlWgt: ttlPlid);

         // Get side totals for truck (grpM) sections

740 M    GetSideTotal('L': lftPcs: lftCube: lftWgt: lftPlid);
740 M    GetSideTotal('R': rgtPcs: rgtCube: rgtWgt: rgtPlid);

         // Get middle totals for truck (grpM) and split between sides

740 M    GetSideTotal('M': midPcs: midCube: midWgt: midPlid);
         midPcs2 = midPcs / 2;
         midCube2 = midCube / 2;
         midWgt2 = midWgt / 2;
740 A    midPlid2 = midPlid / 2;

         lftPcs += midPcs2;
         lftCube += midCube2;
         lftWgt += midWgt2;
740 A    lftPlid += midPlid2;

         rgtPcs += midPcs2;
         rgtCube += midCube2;
         rgtWgt += midWgt2;
740 A    rgtPlid += midPlid2;

       //endif;

       jsonDepth = 0;
       jsonLine = '';

       JsonStartObj();

         JsonAddPair('lvl': %char(dddLevel));
         JsonAddPair('id': dddid);
         JsonAddPair('pid': dddpid);
         JsonAddPair('rows': %editc(dddrow:'P'));
         JsonAddPair('cols': %editc(dddcol:'P'));

       //if dddid = 'grpM';

           JsonStartObj('ttlcontainer');

             JsonStartObj('fields');

               JsonStartObj('section');
                 JsonAddPair('dsp': 'Route Totals: ');
               JsonEndObj();

               JsonStartObj('cube');
                 JsonAddPair('dsp': 'Cube: '
                              + %trim(%editc(%inth(ttlCube):'P')));
               JsonEndObj();

               JsonStartObj('wgt');
                 JsonAddPair('dsp': 'Weight: '
                             + %trim(%editc(%inth(ttlWgt):'P')));
               JsonEndObj();

               JsonStartObj('pcs');
                 JsonAddPair('dsp': 'Pieces: '
                              + %trim(%editc(ttlPcs:'P')));
               JsonEndObj();
740 A
740 A          JsonStartObj('plts');
740 A            JsonAddPair('dsp': 'Pallets: '
740 A                         + %trim(%editc(ttlPlid:'P')));
740 A          JsonEndObj();
740 A
740 A          // send down all DDOPTS to build as hidden span tags
740 A            setll (*loval) ddopts;
740 A            optcnt=0;
740 A            dow forever=forever;
740 A              read ddopts;
740 A              if %eof(ddopts);
740 A                leave;
740 A              endif;
                   if docode = 'BFC_EXPAND_ITEM_SPLITS' or
                      docode = 'BFC_PALLET_DISPLAY_PIECES' or
                      docode = 'BFC_LOCATION_DISPLAY_PIECES' or
                      docode = 'BFC_STOP_DISPLAY_PIECES' or
                      docode = 'BFC_ITEM_DISPLAY_PIECES' or
                      docode = 'BFC_STOP_DISPLAY_WEIGHT' or
                      docode = 'BFC_ITEM_DISPLAY_WEIGHT' or
                      docode = 'BFC_STOP_DISPLAY_CUSTOMER_NUMBER' or
                      docode = 'BFC_STOP_DISPLAY_CUSTOMER_NAME' or
750 A                 docode = 'BFC_MERGE_ZONES_SINGLE_PALLET';
740 A                 optcnt = optcnt + 1;
740 A                 JsonStartObj('opt' + %editc(optcnt:'X'));
740 A                   JsonAddPair('opt' :  %trim(docode) + '|'
740 A                                 + %trim(dovalue));
740 A                 JsonEndObj();
                   endif;
740 A            enddo;

             JsonEndObj();

           JsonEndObj();

         //endif;

         // Add group totals

         JsonStartObj('ttlgrp');

           JsonStartObj('fields');

             if dddid = 'grpO';
               JsonStartObj('section');
                 JsonAddPair('dsp': 'Overflow Totals: ');
               JsonEndObj();
             else;
               JsonStartObj('section');
                 JsonAddPair('dsp': 'Truck Totals: ');
               JsonEndObj();
740 A          gtrkPlid = lftPlid + rgtPlid;
740 A          govfPlid = ttlPlid - gTrkPlid;
             endif;
             JsonStartObj('cube');
               JsonAddPair('dsp': 'Cube: '
                            + %trim(%editc(%inth(dddcube):'P')));
             JsonEndObj();

             JsonStartObj('wgt');
               JsonAddPair('dsp': 'Weight: '
                           + %trim(%editc(%inth(dddwgt):'P')));
            JsonEndObj();

             JsonStartObj('pcs');
               JsonAddPair('dsp': 'Pieces: '
                           + %trim(%editc(dddpcs:'P')));
             JsonEndObj();
740 A        if dddid = 'grpO';
740 A          JsonStartObj('plts');
740 A            JsonAddPair('dsp': 'Pallets: '
740 A                           + %trim(%editc(govfPlid:'P')));
740 A          JsonEndObj();
740 A        else;
740 A          JsonStartObj('plts');
740 A            JsonAddPair('dsp': 'Pallets: '
740 A                           + %trim(%editc(gtrkplid:'P')));
740 A          JsonEndObj();
740 A        endif;

           JsonEndObj();

         JsonEndObj();

         // Add the side totals, only when grpM

         if dddid = 'grpM';

           JsonStartObj('ttlleft');

             JsonStartObj('fields');

               JsonStartObj('section');
                 JsonAddPair('dsp': 'Left Side: ');
               JsonEndObj();

               JsonStartObj('cube');
                 JsonAddPair('dsp': 'Cube: '
                              + %trim(%editc(%inth(lftcube):'P')));
               JsonEndObj();

               JsonStartObj('wgt');
                 JsonAddPair('dsp': 'Weight: '
                             + %trim(%editc(%inth(lftwgt):'P')));
              JsonEndObj();

               JsonStartObj('pcs');
                 JsonAddPair('dsp': 'Pieces: '
                             + %trim(%editc(lftpcs:'P')));
               JsonEndObj();
740 A
740 A          JsonStartObj('plts');
740 A            JsonAddPair('dsp': 'Pallets: '
740 A                         + %trim(%editc(lftPlid:'P')));
740 A          JsonEndObj();

             JsonEndObj();

           JsonEndObj();

           JsonStartObj('ttlright');

             JsonStartObj('fields');

               JsonStartObj('section');
                 JsonAddPair('dsp': 'Right Side: ');
               JsonEndObj();

               JsonStartObj('cube');
                 JsonAddPair('dsp': 'Cube: '
                              + %trim(%editc(%inth(rgtcube):'P')));
               JsonEndObj();

               JsonStartObj('wgt');
                 JsonAddPair('dsp': 'Weight: '
                             + %trim(%editc(%inth(rgtwgt):'P')));
              JsonEndObj();

               JsonStartObj('pcs');
                 JsonAddPair('dsp': 'Pieces: '
                             + %trim(%editc(rgtpcs:'P')));
               JsonEndObj();
740 A
740 A          JsonStartObj('plts');
740 A            JsonAddPair('dsp': 'Pallets: '
740 A                         + %trim(%editc(rgtPlid:'P')));
740 A          JsonEndObj();

             JsonEndObj();

           JsonEndObj();

         endif;

       JsonEndObj();

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ProcessLvl1   Process Level 1 - Location
     *----------------------------------------------------------------

     p ProcessLvl1     b
     d ProcessLvl1     pi

     * Local Variables

      /free

       jsonDepth = 0;
       jsonLine = '';

       JsonStartObj();
         JsonAddPair('lvl': %char(dddLevel));
         JsonAddPair('id': dddid);
         JsonAddPair('pid': dddpid);
         JsonAddPair('comp': dddcomp);

         JsonStartObj('fields');

           JsonStartObj('row');
             JsonAddPair('dsp': 'Row: ' + %trim(%editc(dddrow:'P')));
             if dddstpsplt = 1 or ddditmsplt = 1;
               JsonAddPair('bg': 'redltr');
             endif;
           JsonEndObj();

           JsonStartObj('col');
             JsonAddPair('dsp': 'Col: ' + %trim(%editc(dddcol:'P')));
             if dddstpsplt = 1 or ddditmsplt = 1;
               JsonAddPair('bg': 'redltr');
             endif;
           JsonEndObj();

           JsonStartObj('usq');
             JsonAddPair('dsp': 'USeq: ' + %trim(%editc(ddduseq:'P')));
           JsonEndObj();

           JsonStartObj('comp');
             JsonAddPair('dsp': 'Comp: ' + %trim(dddcomp));
           JsonEndObj();

           if dddpcs <> 0;

             JsonStartObj('cube');
               JsonAddPair('dsp': 'C: '+ %trim(%editc(%dech(dddcube:7:1):'P')));
               if dddcubwrn = 1;
750bD            //JsonAddPair('bg': 'cubewarning');
750bM            JsonAddPair('bg': 'CUBE_MAX');
               else;
                 JsonAddPair('bg': 'cubeFont');
               endif;
             JsonEndObj();

             JsonStartObj('wgt');
               JsonAddPair('dsp': 'W: '+ %trim(%editc(%inth(dddwgt):'P')));
             JsonEndObj();

740 M        // Reinstate piece count at Location Level per Hemant
740 M        JsonStartObj('pcs');
740 M          JsonAddPair('dsp': 'P: '+ %trim(%editc(%dech(dddpcs:7:0):'P')));
740 M        JsonEndObj();

750 A        // get additional flag for spin indicator
750 A        exWhse = pWhse;
750 A        wrkRtid= pRtid;
750 A        wrkspin = *blanks;
750 A        wrkmrg = *blanks;
750 A        wrkrow = *zeros;
750 A        wrkcol = *zeros;
750 A        ddwrkflds ('*GET': exRtnCode: exRtnMsg: exWhse: wrkRtid:
750 A                    dddsnap: dddid :wrkrow :wrkcol :wrkmrg :wrkspin);
750 A        if exRtnCode = '*OK';
750 A           if %trim(wrkspin) = 'Y';
750 A             JsonStartObj('ispin');
750 A                 JsonAddPair('ispin': %trim(dddid) + 'Y');
750 A             JsonEndObj();
750 A           else;
750 A              // if not found or not Yes(Y) so we know to show the no spin icon
750 A              JsonStartObj('ispin');
750 A                  JsonAddPair('ispin': %trim(dddid) + 'N');
750 A              JsonEndObj();
750 A          endif;
750 A        else;
750 A            // if not found or not Yes(Y) so we know to show the no spin icon
750 A            JsonStartObj('ispin');
750 A                JsonAddPair('ispin': %trim(dddid) + 'N');
750 A            JsonEndObj();
750 A        endif;

           endif;

         JsonEndObj();

       JsonEndObj();

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ProcessLvl2   Process Level 2 - Pallet
     *----------------------------------------------------------------

     p ProcessLvl2     b
     d ProcessLvl2     pi

      /free
750 A  gSavedComp = dddcomp;
       jsonDepth = 0;
       jsonLine = '';

       JsonStartObj();

         JsonAddPair('lvl': %char(dddLevel));
         JsonAddPair('id': dddid);
         JsonAddPair('pid': dddpid);
         JsonAddPair('comp': dddcomp);

         JsonStartObj('fields');

           JsonStartObj('plt');
             JsonAddPair('dsp': 'Pallet: ' + %trim(%editc(dddpalnum:'P')));
             //JsonAddPair('dsp': 'Pallet:');
             if dddstpsplt = 1 or ddditmsplt = 1;
               JsonAddPair('bg': 'redltr');
             endif;
           JsonEndObj();

           JsonStartObj('cz');
             JsonAddPair('dsp': %trim(dddcomp) + '-' + %trim(dddtzon));
             if dddstpsplt = 1 or ddditmsplt = 1;
               JsonAddPair('bg': 'redltr');
             endif;
           JsonEndObj();

           JsonStartObj('cube');
             JsonAddPair('dsp': 'C: '+ %trim(%editc(%dech(dddcube:7:1):'P')));
             if dddcubwrn = 1;
750bD          //JsonAddPair('bg': 'cubewarning');
750bM            JsonAddPair('bg': 'CUBE_MAX');
             else;
               JsonAddPair('bg': 'cubeFont');
             endif;
           JsonEndObj();

           JsonStartObj('wgt');
             JsonAddPair('dsp': 'W: '+ %trim(%editc(%inth(dddwgt):'P')));
             if dddwgtwrn = 1;
750bD          //JsonAddPair('bg': 'cubewarning');
750bM          JsonAddPair('bg': 'CUBE_MAX');
             endif;
           JsonEndObj();
730bA
730bA      JsonStartObj('pcs');
730bA        JsonAddPair('dsp': 'P: ' + %trim(%editc(dddpcs:'P')));
730bA      JsonEndObj();

750 A      // get merge icon flag for unlike pallets
750 A      exWhse = pWhse;
750 A      wrkRtid= pRtid;
750 A      wrkspin = *blanks;
750 A      wrkmrg = *blanks;
750 A      wrkrow = *zeros;
750 A      wrkcol = *zeros;
750 A      ddwrkflds ('*GET': exRtnCode: exRtnMsg: exWhse: wrkRtid:
750 A                  dddsnap: dddid :wrkrow :wrkcol :wrkmrg :wrkspin);
750 A      if exRtnCode = '*OK';
750 A         if %trim(wrkmrg) = 'Y';
750 A           JsonStartObj('imrg');
750 A               JsonAddPair('imrg': dddid);
750 A           JsonEndObj();
750 A         endif;
750 A      endif;

         JsonEndObj();

       JsonEndObj();

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ProcessLvl3   Process Level 3 - Pallet Area
     *----------------------------------------------------------------

     p ProcessLvl3     b
     d ProcessLvl3     pi

      /free

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ProcessLvl4   Process Level 4 - Stop/Drop
     *----------------------------------------------------------------

     p ProcessLvl4     b
     d ProcessLvl4     pi

      /free


       chain (dddwhse: dddord) ordh;
       if not %found(ordh);
         clear ohrec;
       endif;

       jsonDepth = 0;
       jsonLine = '';

       JsonStartObj();

         JsonAddPair('lvl': %char(dddLevel));
         JsonAddPair('id': dddid);
         JsonAddPair('pid': dddpid);
750 D      //JsonAddPair('comp': dddcomp);
750 M      JsonAddPair('comp': gSavedcomp);

         JsonStartObj('fields');

           JsonStartObj('scat');
               JsonAddPair('scat': dddid);
           JsonEndObj();

           JsonStartObj('stp');
750aA        if %subst(rhrte:1:3)='#SR';
750aA          chain (dddwhse:dddrtid:dddord) srord2;
750aA          if %found(srord2);
750aA            JsonAddPair('dsp': 'M Rte/Stop: ' + %trim(sromrte) +  '/' +
750aA                                %trim(%editc(dddHstStp:'P')));
750aA          else;
750aA            JsonAddPair('dsp': 'Stop: ' + %trim(%editc(dddHstStp:'P')));
750aA          endif;
750aA        else;
               JsonAddPair('dsp': 'Stop: ' + %trim(%editc(dddHstStp:'P')));
750aA        endif;
             if dddstpsplt = 1 or ddditmsplt = 1;
               JsonAddPair('bg': 'redltr');
             endif;
           JsonEndObj();

           JsonStartObj('cube');
             JsonAddPair('dsp': 'C: '+ %trim(%editc(%dech(dddcube:7:1):'P')));
             JsonAddPair('bg': 'cubeFont');
           JsonEndObj();

           JsonStartObj('wgt');
             JsonAddPair('dsp': 'W: '+ %trim(%editc(%inth(dddwgt):'P')));
           JsonEndObj();

           JsonStartObj('pcs');
             JsonAddPair('dsp': 'P: ' + %trim(%editc(dddpcs:'P')));
           JsonEndObj();

740 D      //JsonStartObj('cst');
740 D      //  JsonAddPair('dsp': %trim(%editc(ohcust:'P')) + '-'+ %trim(ohcnam));
740 D      //JsonEndObj();

740 A      JsonStartObj('cstnum');
740 A        JsonAddPair('dsp': %trim(%editc(ohcust:'P')));
740 A      JsonEndObj();

740 A      JsonStartObj('cstnam');
740 A        JsonAddPair('dsp': %trim(ohcnam));
740 A      JsonEndObj();

750 A      // get merge icon for unlike pallets
750 A      exWhse = pWhse;
750 A      wrkRtid= pRtid;
750 A      wrkspin = *blanks;
750 A      wrkmrg = *blanks;
           wrkrow = *zeros;
           wrkcol = *zeros;
750 A      ddwrkflds ('*GET': exRtnCode: exRtnMsg: exWhse: wrkRtid:
750 A                  dddsnap: dddid: wrkrow: wrkcol: wrkmrg: wrkspin);
750 A      if exRtnCode = '*OK';
750 A         if %trim(wrkmrg) = 'Y';
750 A           JsonStartObj('imrg');
750 A               JsonAddPair('imrg': dddid);
750 A           JsonEndObj();
750 A         endif;
750 A      endif;

         JsonEndObj();

       JsonEndObj();

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ProcessLvl5   Process Level 5 - Item
     *----------------------------------------------------------------

     p ProcessLvl5     b
     d ProcessLvl5     pi

730aA* Local Variables
730aA
730aAd pseq            s            100    varying

      /free

         chain (dddlblitm) worklbl;
         if not %found(worklbl);
           clear lwrec;
         endif;

         chain (dddwhse: lwitem) piritem;
         if not %found(piritem);
           clear itrec;
         endif;
730aA
730aA    // Create field to use with PSeq Sort button
730aA
730aA    pseq = %editc(lwlvl2: 'X')
730aA         + lwwhdp
730aA         + lwaisl
730aA         + %editc(lwpseq: 'X')
730aA         + %editc(lwrlvl: 'X')
730aA         + lwhand
730aA         + %editc(lwlbl#: 'X');

         jsonDepth = 0;
         jsonLine = '';

         JsonStartObj();

           JsonAddPair('lvl': %char(dddLevel));
           JsonAddPair('id': dddid);
           JsonAddPair('pid': dddpid);
           JsonAddPair('comp': dddorgcmp);
           JsonAddPair('itype': ddditmtyp);
           JsonAddPair('cube': %char(dddcube));
           JsonAddPair('wgt': %char(dddwgt));
           JsonAddPair('pcs': %char(dddpcs));
           JsonAddPair('itm': lwitem);
           JsonAddPair('slt': lwdisp);
           JsonAddPair('lbl': %char(lwlbl#));
           if ddditmsplt = 1;
             JsonAddPair('split': 'Y');
           endif;
730aA      JsonAddPair('pseq': pseq);

           JsonStartObj('fields');

740 A        // Setup new display value to color code for Class and Category
740 A        JsonStartObj('cccod');
740 A          JsonAddPair('dsp': '...');
740 A          // For Items add any class codes for given item for category
740 A          bfccatcls=*off;
740 A          qryCat=*blanks;
740 A          qryDesc=*blanks;
740 A          exec sql select ifcat,icdesc into :qryCat,:qryDesc
740 A                           from itemfld,itemcat
740 A                     where ifwhse=:lwwhse and ifitem=:lwitem
740 A                            and ifcat=iccode
740 A                         fetch first row only;
740 A          if sqlstt='00000' and qryCat<>*blanks;
740 A            // add for each color set in pircolorsd
740 A            setll (lwwhse:'CAT') pircolorsd;
740 A            dow forever=forever;
740 A              reade (lwwhse:'CAT') pircolorsd;
740 A              if %eof(pircolorsd) or not %equal(pircolorsd);
740 A                leave;
740 A              endif;
740 A              if clrdcode <> qryCat;
740 A                iter;
740 A              endif;
740 A              JsonAddPair('bg': 'cat' + %trim(qryCat));
740 A              JsonAddPair('dpd': %trim(dddpid));
740 A              JsonAddPair('cdsc': %trim(qryDesc));
740 A              bfccatcls=*on;
740 A            enddo;
740 A          endif;
740 A
740 A          // For Items add any class codes for given item for bfc class
               qryDesc=*blanks;
740 A          setll (lwwhse:lwitem) itemcls;
740 A          dow forever=forever;
740 A            reade (lwwhse:lwitem) itemcls;
740 A            if %eof(itemcls) or not %equal(itemcls);
740 A              leave;
740 A            endif;
740 A            qryCls=iclcde;
740 A            // add for each color set in pircolorsd
740 A            setll (lwwhse:'CLS') pircolorsd;
740 A            dow forever=forever;
740 A              reade (lwwhse:'CLS') pircolorsd;
740 A              if %eof(pircolorsd) or not %equal(pircolorsd);
740 A                leave;
740 A              endif;
740 A              if clrdcode <> qryCls;
740 A                iter;
740 A              endif;
740 A              JsonAddPair('bg': 'cls' + %trim(qryCls));
740 A              exec sql select cadesc into :qryDesc
740 A                          from class
740 A                       where cacode=:qrycls
740 A                        fetch first row only;
740 A              if qryDesc<>*blanks;
740 A                JsonAddPair('cdsc': %trim(qryDesc));
740 A              endif;
740 A              if not bfccatcls;
740 A                JsonAddPair('dpd': %trim(dddpid));
740 A              endif;
740 A            enddo;
740 A          enddo;
740 A        JsonEndObj();

             JsonStartObj('itm');
               JsonAddPair('dsp': lwitem);
               if ddditmsplt = 1;
                 JsonAddPair('bg': 'redltr');
               endif;
             JsonEndObj();

             JsonStartObj('dsc');
               JsonAddPair('dsp': '- ' + %trim(itdesc));
               if ddditmsplt = 1;
                 JsonAddPair('bg': 'redltr');
               endif;
             JsonEndObj();

             JsonStartObj('cube');
               JsonAddPair('dsp': 'C: '+ %trim(%editc(%dech(dddcube:7:1):'P')));
               JsonAddPair('bg': 'cubeFont');
             JsonEndObj();

             JsonStartObj('wgt');
               JsonAddPair('dsp': 'W: '+ %trim(%editc(%inth(dddwgt):'P')));
             JsonEndObj();

             JsonStartObj('pcs');
               JsonAddPair('dsp': 'P: ' + %trim(%editc(dddpcs:'P')));
             JsonEndObj();

             JsonStartObj('um');
               JsonAddPair('dsp': 'Um: ' + %trim(lwucod));
             JsonEndObj();

             JsonStartObj('dpt');
               JsonAddPair('dsp': 'Dept: ' + %trim(lwwhdp));
             JsonEndObj();

             JsonStartObj('typ');
               JsonAddPair('dsp': 'Type: ' + %trim(lwtype));
             JsonEndObj();

             JsonStartObj('slt');
               JsonAddPair('dsp': 'Slot: ' + %trim(lwdisp));
             JsonEndObj();

            // JsonStartObj('lbl');
            //   JsonAddPair('dsp': 'L: '+ %char(lwlbl#));
            // JsonEndObj();

           JsonEndObj();

         JsonEndObj();

         dddjson = jsonLine;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  JSON Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  JsonAddArray   Add array value to JSON object
     *----------------------------------------------------------------

     p JsonAddArray    b
     d JsonAddArray    pi
     d  arrayValue                  500    const varying

     * Local Variables

     d  cmd            s             10
     d  valueIn        s            500
     d  valueOut       s            500

      /free

        cmd = '*XML';
        valueIn = arrayValue;
        valueOut = '';
        CvtText(cmd: valueIn: valueOut);

        if jsonStack.firstEntry;
          jsonStack.firstEntry = *off;
        else;
          jsonLine += ',';
        endif;

        jsonLine += dq + %trim(valueOut) + dq + ':';

        return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  JsonAddPair    Add name/value pair to JSON object
     *----------------------------------------------------------------

     p JsonAddPair     b
     d JsonAddPair     pi
     d  pairName                    100    const varying
     d  pairValue                   500    const varying

     * Local Variables

     d  cmd            s             10
     d  valueIn        s            500
     d  valueOut       s            500

      /free

        cmd = '*XML';
        valueIn = pairValue;
        valueOut = '';
        CvtText(cmd: valueIn: valueOut);

        if jsonStack.firstEntry;
          jsonStack.firstEntry = *off;
        else;
          jsonLine += ',';
        endif;

        jsonLine += dq + %trim(pairName) + dq + ':' + dq + %trim(valueOut) + dq;

        return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  JsonEndArray  End JSON array
     *----------------------------------------------------------------

     p JsonEndArray    b
     d JsonEndArray    pi

      /free
        jsonLine += ']';
        jsonDepth -= 1;
        return;
      /end-free

     p                 e

     *----------------------------------------------------------------
     *  JsonEndObj    End JSON object
     *----------------------------------------------------------------

     p JsonEndObj      b
     d JsonEndObj      pi

      /free
        jsonLine += '}';
        jsonDepth -= 1;
        return;
      /end-free

     p                 e

     *----------------------------------------------------------------
     *  JsonStartArray    Start JSON array
     *----------------------------------------------------------------

     p JsonStartArray  b
     d JsonStartArray  pi
     d  arrayName                   100    const varying

     * Local Variables


      /free

        jsonLine += dq + arrayName + dq + ':[';

        jsonDepth += 1;
        %occur(jsonStack) = jsonDepth;
        jsonStack.firstEntry = *on;

        return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  JsonStartObj   Start JSON object
     *----------------------------------------------------------------

     p JsonStartObj    b
     d JsonStartObj    pi
     d  objName                     100    const varying options(*nopass)

      /free

        if jsonDepth > 0;
          if jsonStack.firstEntry;
            jsonStack.firstEntry = *off;
          else;
            jsonLine += ',';
          endif;
        endif;

        if %parms >= 1;
          jsonLine += dq + %trim(objName) + dq + ':{';
        else;
          jsonLine += '{';
        endif;

        jsonDepth += 1;
        %occur(jsonStack) = jsonDepth;
        jsonStack.firstEntry = *on;

        return;
      /end-free

     p                 e

