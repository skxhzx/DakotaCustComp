      /copy qcopysrc,hspecs
     H Dftactgrp(*No)
      *****************************************************************
      *
      *  To compile:
      *
      *             CRTSQLRPGI PGM(XXX/SQL003RG) SRCFILE(XXX/QRPGLESRC)
      *
      *
      * COMPILING. In order to compile this program you will need
      *            to use options which allow it to work correctly
      *            between machines. These options are---
      *
      *               COMMIT = *NONE
      *               RDB    = Machine name that you will connect to.
      *               DLYPRP = *YES
      *               SQLPKG = The name & library that you want to
      *                        use for the package. This will put the
      *                        package on the RDB machine that you
      *                        specify.
      *****************************************************************
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  UPDSUM004   Write Recall Summary records
     *  05 Aug 2015
     *  Retha Davis
     *
     *  Revisions
     *
700 A*    08/05/15  RBD  7.00
     *      - Created.
     *
700aA*    01/10/16  RBD  7.00a
     *      - Fix: Use ladisp from licactive rather than labase. Was
     *        not getting items in the warehouse that were in virtual
     *        slots.
     *
720aA*    06/06/18  RBD  7.20a
     *      - Fix: In updwrkenddate:
     *          Default enddte to current date.
     *          If license in licactive use current date.
     *          Revised sql logic to improve efficiency.
     *
730aA*     01/30/19  KDE  7.30a
     *       - Enh: Recompile due to PWRKORD change
     *
730bA*    06/26/19  RBD  7.30b
     *      - Fix: Replace apostrophe in customer name and item desc.
     *        Was causing sql syntax error when name included apostrophe.
     *
730cA*    07/10/19  RBD  7.30c
     *      - Fix: Add item matching to sqlstmt in WrtSelUci.
     *      - Changed deleterecs to clear workfile rather than just
     *        deleting records for the report id.  And will call
     *        deleterecs at inz too (already clears at LR)
     *        in case the program ends without making it to LR.
     *        This has happened and the stranded workfile records
     *        cause problems on subsequent recall reports.
     *
740aA*    02/21/20  RBD  7.40a
     *      - Enh: Added calls to EXSUM004H and EXSUM004 for new selection
     *        parms for route, route id, transaction(s) and delivery date.
     *        Changed from allowing single PO selection to allowing
     *        multiples.
     *      - If user doesn't enter an item they must enter route id.
     *        The program will loop through each item for that route id
     *        to create work file records.
     *
740bA*    05/18/20  RBD  7.40b
     *      - Added sqlstt 21000 check when multiple records found
     *        are a possibility.
     *      - Added label number to sum004 and sum004exa.
     *      - Added date type entered to sum004wrk and sum004exa.
     *
740cA*    12/08/20  RBD  7.40c
     *      - Revised all sum004wrk reads to include match to reportid.
     *      - Reinstate 730c mod that deletes records for report id.
     *      - Delete recs from sum004wrk, if any, older than 1 day.
     *
750aA*    01/20/21  RBD  7.50a
     *      - Include *NG selection recs for RPK when the RPK
     *        is put away into a slot with negative qty.
     *      - Fix: in wrtliclselsum routine changed join on
     *        license to join on item. Also added logic to
     *        include SEL records for cross docks which are
     *        found by looking for SEL records with *NG lic and
     *        associated NG (llaction) record.
     *      - Moved write to sum004 out of wrtliclselsum and into
     *        new routine wrtliclselsum1 so it can be called within
     *        the new cross dock logic (see fix above).
     *
750bA*    10/11/21  RBD  7.50b
     *      - If po is blank in recall rec get po for orig license.
     *        Requested by PAN because repacks weren't showing
     *        the po, which in the case of repacks, comes from the
     *        original license.
     *
750cA*    11/10/21  RBD  7.50c
     *      - Added report id qualifier to 750b rev.
     *      - Fix: changes to wrtliclselsum sql.
     *
750dA*    12/02/21  RBD  7.50d
     *      - Fix: don't look for *NG SEL recs if orig license
     *        in workfile is blank.
     *      - Fix: comment out cross dock logic in wrtliclselsum
     *        until we can get more clarity from Panos.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

750aDF*liclog11  if   E           k disk    rename(llrec:llrec11)
750aMFliclog11  if   E           k disk    rename(llrec:llrec11) prefix(l11_)
750aAFliclog    if   E           k disk    rename(llrec:llrecX)
750aAFliclog1   if   E           k disk    rename(llrec:llrec1) prefix(l1_)
750aMFliclog8   if   E           k disk    rename(llrec:llrec8) prefix(l8)
     Fliclog13  if   E           k disk    rename(llrec:llrec13)
     Fpwrkord   if   E           k disk
     Fpwrkordr2 if   E           k disk
     Fslot3     if   E           k disk
     Fslot4     if   E           k disk    rename(slrec:slrec4)
750aAFsum004    uf a E           k disk    rename(smrec:smrecx)
740aAFordhm2    if   E           k disk
     Fsum004wrk uf a E           k disk
     Fsum004wrk1uf   E           k disk    rename(swrec:swrec1)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.cvtdte
      /copy qcopysrc,p.cvtqty
      /copy qcopysrc,p.recall#

740aA*----------------------------------------------------------------
740aA*  Called program prototypes
740aA*----------------------------------------------------------------

740aAD/copy qcopysrc,p.exsum4h
740aAD/copy qcopysrc,p.exsum004

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d DeleteRecs      pr
     d FillLica        pr
     d FillLiclAdj     pr
750aAd FillLiclNeg     pr
     d FillLiclPrd     pr
     d FillLiclSel     pr
     d FillLicaUci     pr
     d FillSelUci      pr
     d GetOrdh         pr
     d GetCurrStamp    pr
     d WrtLicaSum      pr
     d WrtLicaUci      pr
     d WrtLiclAdjSum   pr
     d WrtLiclPrdSum   pr
     d WrtLiclSelSum   pr
750aAd WrtLiclSelSum1  pr
750aAd WrtLiclNegSum   pr
     d WrtSelUci       pr
     d UpdSum4H        pr
     d WrtSum4H        pr
740aAd getPoList       pr
740aAd getTranList     pr

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D FromStamp       s               z
     D ToStamp         s               z
     D oldeststamp     s               z
     D ts              s               z

     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

     D bfcoffset       s              3  0 inz(0)
     D ucOffset        s              3  0

     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Display File Information Data Structure
     *----------------------------------------------------------------

     Dinfo             ds
     D cfkey                 369    369

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     D blanks          s            100    inz(' ')

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D licactive     e ds                  inz
     D licinfo       e ds                  inz
     D ordh          e ds                  inz
     D rtehed        e ds                  inz
     D itrec         E ds                  extname(piritem) inz(*EXTDFT)
     D plrec         E ds                  extname(plined) inz(*EXTDFT)
     D llrec         E ds                  extname(liclog) inz(*EXTDFT)
750aAD dsllrec11     E ds                  extname(liclog11) prefix(l11_)
     D phrec         E ds                  extname(pohdr) inz(*EXTDFT)
     D phhrec        E ds                  extname(pohhdr) inz(*EXTDFT)
     D smrec         E ds                  extname(sum004) inz(*EXTDFT)
     D smhrec        E ds                  extname(sum004h) inz(*EXTDFT)
     D s1rec         E ds                  extname(sum004uci) inz(*EXTDFT)
     D dsswrec       E ds                  extname(sum004wrk) inz(*EXTDFT)
     D uciinfo       e ds                  inz

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  SQL fetch fields
     *----------------------------------------------------------------

     D fetchds         ds
     D   #fwhse                            like(lawhse)
     D   #fitem                            like(laitem)
     D   #flcns                            like(lalcns)
     D   #folcns                           like(laolcns)
     D   #fwhdp                            like(lawhdp)
     D   #fdisp                            like(ladisp)
     D   #ford                             like(llord)
     D   #fqty1                            like(laqty1)
     D   #fqty2                            like(laqty2)
     D   #fqty3                            like(laqty3)
     D   #fadduc                     26
     D   #flnpo                            like(lnpo)
     D   #fexpdt                           like(laexpd)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $code           s              2    inz(' ')
     D $count          s              8b 0 inz(0)
     D action          s              3
     D adj             s              3    inz('ADJ')
     D append1         s              1
     D append5         s              5
     D begdte          s                   like(swolddate)
     D booleanOn       s              3    inz('1')
     D cnt             s             10i 0
     D cqerm           s             60
     D cqqty1          s              7  0
     D cqqty2          s              7  0
     D cqqty3          s              7  0
     D cqrtn           s              8
     D cqum1           s              2
     D cqum2           s              2
     D cqum3           s              2
     D cqustr          s             17
     D curview         s              1  0 inz(1)
     D enddte          s                   like(swenddate)
     D eorder1         s             20    inz(' ')
     D eorder2         s             20    inz(' ')
     D first           s               n
     D foundCustOrd    s               n
     D groupby         S            100a   inz(' ')
     D groupfields     S            100a   inz(' ')
     D iorder1         s             20    inz(' ')
     D iorder2         s             20    inz(' ')
     D kyaction        s                   like(llaction)
     D kystat          s                   like(slstat)
     D kypick          s                   like(slpick)
     D lastitem        s                   like(laitem)
     D newordpos       s              3  0 inz(0)
     D noParmsPassed   s               n
     D oldestdate      s                   like(swolddate)
     D opcode          s              6
     D optiontaken     s             10    inz(' ')
     D order1          s             10    inz(' ')
     D order2          s             10    inz(' ')
     D orderby         S            100a   inz(' ')
     D orderfield      s             10    inz(' ')
     D orderposition   s              3  0 inz(0)
     D ordqty          s             10  0 inz(0)
     D piu             s              3    inz('PIU')
     D piw             s              3    inz('PIW')
     D posfld          s              5    inz(' ')
     D origlcns        s                   like(laolcns)
     D prodFlag        s              1
     D qty1            s              5  0 inz(0)
     D qty2            s              5  0 inz(0)
     D qty3            s              5  0 inz(0)
     D reportId        s              7  0
     D sav_item        s                   like(laitem)
     D sav_swlcns      s                   like(swlcns)
     D sel             s              3    inz('SEL')
     D slot            s                   like(labase)
     D sortorder1      s             10    inz(' ')
     D sortorder2      s             10    inz(' ')
     D sortorder3      s             10    inz(' ')
     D printflag       s               n
     D wkCount         s             10  0 inz(0)
     D woCYMD          s              8  0 inz(0)
     D w1expdta        s              8
     D yes             s              1    inz('Y')
740aAd pTranLen        s              3  0
740aAd singleTranLen   s              3  0
740aAd k               s              5  0
740aAd poCount         s              3  0
740aAd tranCount       s              3  0
740aAD tranFound       s               n

740aA*----------------------------------------------------------------
740aA*  PO List
740aA*----------------------------------------------------------------
740aAD poList          DS                  occurs(55) qualified
740aAD  poNum                         9

740aA*----------------------------------------------------------------
740aA*  Tran List
740aA*----------------------------------------------------------------
740aAD tranList        DS                  occurs(70) qualified
740aAD  tranNum                       7  0

     *----------------------------------------------------------------
     *  CVTDTE constant and parameter data structure.
     *----------------------------------------------------------------

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
     *  Parameters
     *----------------------------------------------------------------

     D  pDaysBefL      s              3  0
     D  pDaysAftL      s              3  0
     D  pDaysBefI      s              3  0
     D  pDaysAftI      s              3  0
     D  pFMfgDt        s              6  0
     D  pTMfgDt        s              6  0
     D  pFMfgEDt       s              6  0
     D  pTMfgEDt       s              6  0
     D  pFMfgDt8       s              8  0
     D  pTMfgDt8       s              8  0
     D  pFMfgEDt8      s              8  0
     D  pTMfgEDt8      s              8  0
     D  pItem          s             15
     D  pLcns          s             15
     D  pLot           s             30
     D  pErrMsg        s             99
     d  pObjLoc        s             10
     D  pPgm           s             10
740aDd**pPo            s              9
740aMd  pPO            s            500    varying
     D  pRptDesc       s             40
     D  pSerial        s             30
     d  pSessId        s             40
     D  pUser          s             10
     d  pWhse          s              3  0
740aAd  pRoute         s              5
740aAd  pRouteId       s              5
740aAd  pFdlvDat       s              6  0
740aAd  pTdlvDat       s              6  0
740aAd  pFdlvDat8      s              8  0
740aAd  pTdlvDat8      s              8  0
740aAd  pTran          s            500    varying

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pPgm        Program
     *      pObjLoc     Object location
     *      pWhse       Warehouse
     *      pRptDesc    Report description
740aD*      pItem       Item (required)
740aM*      pItem       Item (no longer required)
     *      pPo         PO number
     *      pLot        Lot code (starts with)
     *      pLcns       License
     *      pSerial     Serial number (starts with)
     *
     *      Dates: jquery drops leading zero, so if month is Jan-Sep
     *             the format will be MDDYY
     *      pFMfgDt     From Mfg Date (MMDDYY)
     *      pTMfgDt     To Mfg Date (MMDDYY)
     *      pFMfgEDt    From Mfg Exp Date (MMDDYY)
     *      pTMfgEDt    To Mfg Exp Date (MMDDYY)
     *
     *      pDaysBefL   Days before license in pick slot
     *      pDaysAftL   Days after license in pick slot
     *      pDaysBefI   Days before item in production
     *      pDaysAftI   Days after item in production
     *
740aA*      pRoute      Route
740aA*      pRouteId    Route id
740aA*      pFdlvDat    From delivery date
740aA*      pTdlvDat    To delivery date
740aA*      pTran       Transactions
     *
     *    Returned Parameters
     *      pErrMsg     (blank if okay)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pErrMsg
     c                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pPgm
     C                   parm                    pObjLoc
     C                   parm                    pWhse
     C                   parm                    pRptDesc
     C                   parm                    pItem
     C                   parm                    pPo
     C                   parm                    pLot
     C                   parm                    pLcns
     C                   parm                    pSerial
     C                   parm                    pFMfgDt
     C                   parm                    pTMfgDt
     C                   parm                    pFMfgEDt
     C                   parm                    pTMfgEDt
     C                   parm                    pDaysBefL
     C                   parm                    pDaysAftL
     C                   parm                    pDaysBefI
     C                   parm                    pDaysAftI
740aAC                   parm                    pRoute
740aAC                   parm                    pRouteId
740aAC                   parm                    pFdlvDat
740aAC                   parm                    pTdlvDat
740aAC                   parm                    pTran

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        pErrmsg = '';
        pUser = %xlate(xlower: xupper: pUser);
        pItem = %xlate(xlower: xupper: pItem);
        pPo = %xlate(xlower: xupper: pPo);
        pLcns = %xlate(xlower: xupper: pLcns);

        exsr zzinz2;

        exsr edit;

        // Write summary header file record.  At end of program will update the
        // same record with status and production flag.

        wrtSum4H();

        // Create workfile which will be used to create SUM004 summary files


740aA   // When item is left blank take the route id entered and for every
740aA   // item on the route run wrtLiciWrk to create the workfile records,
740aA   // checking first to be sure the item isn't already in the workfile.

740aA   select;
740aA     when pItem = *blanks;
740aA       SqlStmt = 'select '
740aA               +   'oditem, itdesc '
740aA               + 'from ordh '
740aA               + 'inner join ordd on odwhse=ohwhse and odord=ohord '
740aA               + 'inner join piritem on itwhse=ohwhse and ititem=oditem '
740aA               + 'where '
740aA               +   'ohwhse= ' + %char(pWhse) + ' '
740aA               +   'and ohrte=' + sq + %trimr(pRouteId) + sq + ' ';

740aA       exec sql prepare ordsel from :SqlStmt;
740aA       exec sql declare ordcsr cursor for ordsel;
740aA       exec sql open ordcsr;

740aA       dow forever = forever;

740aA         exec sql fetch next from ordcsr
740aA                  into :pitem, :itdesc;

740aA         if sqlstt <> sqlSuccess
740bA           and sqlstt <> '21000';
740aA           leave;
740aA         endif;

740aA         exec sql select * into :dsswrec
740aA                  from sum004wrk
740aA                  where swwhse = :pWhse
740aA                    and swreportid = :reportId
740aA                    and switem = :pItem;

740aA         if sqlstt = sqlSuccess
740bA           or sqlstt = '21000';
740aA           iter;
740aA         endif;

740aA         exsr wrtLiciWrk;

740aA       enddo;

740aA       exec sql close ordcsr;
740aA       eval pItem = *blanks;


740aA     // If item was entered ...

740aA     when pItem <> *blanks;
            exsr wrtLiciWrk;

740aA   endsl;

        exsr FGfromProd;
        exsr updPOdata;
        exsr wrtLiclWrk;
        exsr updWrkOldDate;
        exsr updWrkEndDate;
        exsr calcBegEndDts;

        // Create SUM004 summary files

        wrtLicaSum();
        wrtLiclAdjSum();
        wrtLiclPrdSum();
        wrtLiclSelSum();
750aA   wrtLiclNegSum();

        wrtLicaUci();
        wrtSelUci();
750bA   exsr updRecallPO;

        // Update summary header record with status and production flag.

        updSum4H();

        // Delete workfile records for this session (reportId)

        DeleteRecs();

        return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr *inzsr;


       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
      /free
       begsr zzinz2;

         // get next GUI recall report id number
         Recall#(pwhse: reportId);

         $cvprg = #prog;

730cA   DeleteRecs();

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  Edit -  Edit
     *
      /free
       begsr edit;

         // validate item and get description
740aA    if pItem <> *blanks;
           exec sql select * into :itrec
                    from piritem
                    where itwhse = :pWhse
                      and ititem = :pItem;

           if sqlstt <> sqlSuccess;
             error = *on;
             pErrMsg = 'Invalid Item';
             return;
           endif;
740aA    endif;

         // ---------------------------------------
         // Edit License
         if pLcns <> ' ';

           exec sql select lnlcns into :lnlcns
                from licinfo
                where lnwhse = :pWhse and lnlcns = :pLcns
                fetch first row only;

           if sqlstt <> sqlSuccess
740bA       and sqlstt <> '21000';
             error = *on;
             pErrMsg = 'Invalid License';
             return;
           endif;

         endif;

         // ---------------------------------------
         // Edit Lot
         if pLot <> ' ';

           exec sql select lnlot into :lnlot
                from licinfo
                where lnwhse = :pWhse and lnlot = :pLot
                fetch first row only;

           if sqlstt <> sqlSuccess
740bA       and sqlstt <> '21000';
             error = *on;
             pErrMsg = 'Invalid Lot';
             return;
           endif;

         endif;

         // ---------------------------------------
740aM    // Edit PO(s)
         if pPo <> ' ';

740aA      // Get list of PO's

740aA      getPoList();

740aA      // Loop through PO list

740aA      for k = 1 to poCount;

740aA        %occur(poList) = k;

             exec sql select lnpo into :lnpo
                  from licinfo
740aD          // where lnwhse = :pWhse and lnpo = :pPo
740aM             where lnwhse = :pWhse and lnpo = :poList.poNum
                  fetch first row only;

             if sqlstt <> sqlSuccess
740bA         and sqlstt <> '21000';
               error = *on;
               pErrMsg = 'Invalid PO';
               return;
             endif;

740aA      endfor;

         endif;

         // ---------------------------------------
         // convert and edit keyed dates, MDY to CMD

         if pFMfgDt > 0;
           $cvcmd = '*MDYCMD';
           $cvd6i = %char(pFMfgDt);
           cvtdte($cvtdt);
           pFMfgDt8 = $cvd8o;

           if $cvrtn = '*PGMQ   ';
             error = *on;
             pErrMsg = 'Invalid From Mfg Date';
             return;
           endif;

         endif;

         if pTMfgDt > 0;
           $cvcmd = '*MDYCMD';
           $cvd6i = %char(pTMfgDt);
           cvtdte($cvtdt);
           pTMfgDt8 = $cvd8o;

           if $cvrtn = '*PGMQ   ';
             error = *on;
             pErrMsg = 'Invalid To Mfg Date';
             return;
           endif;

         endif;

         if pFMfgEDt > 0;
           $cvcmd = '*MDYCMD';
           $cvd6i = %char(pFMfgEDt);
           cvtdte($cvtdt);
           pFMfgEDt8 = $cvd8o;

           if $cvrtn = '*PGMQ   ';
             error = *on;
             pErrMsg = 'Invalid From Mfg Exp Date';
             return;
           endif;

         endif;

         if pTMfgEDt > 0;
           $cvcmd = '*MDYCMD';
           $cvd6i = %char(pTMfgEDt);
           cvtdte($cvtdt);
           pTMfgEDt8 = $cvd8o;

           if $cvrtn = '*PGMQ   ';
             error = *on;
             pErrMsg = 'Invalid To Mfg Exp Date';
             return;
           endif;

         endif;

740aA    if pFdlvDat > 0;
740aA      $cvcmd = '*MDYCMD';
740aA      $cvd6i = %char(pFdlvDat);
740aA      cvtdte($cvtdt);
740aA      pFdlvDat8 = $cvd8o;

740aA      if $cvrtn = '*PGMQ   ';
740aA        error = *on;
740aA        pErrMsg = 'Invalid From Delivery Date';
740aA        return;
740aA      endif;

740aA    endif;

740aA    if pTdlvDat > 0;
740aA      $cvcmd = '*MDYCMD';
740aA      $cvd6i = %char(pTdlvDat);
740aA      cvtdte($cvtdt);
740aA      pTdlvDat8 = $cvd8o;

740aA      if $cvrtn = '*PGMQ   ';
740aA        error = *on;
740aA        pErrMsg = 'Invalid To Delivery Date';
740aA        return;
740aA      endif;

740aA    endif;

         // ---------------------------------------
         // Edit Serial Number
         if pSerial <> ' ';

           exec sql select uiserial into :uiserial
                from uciinfo
                where uiwhse = :pWhse and uiitem = :pItem
                  and uiserial = :pSerial
                fetch first row only;

           if sqlstt <> sqlSuccess
740bA       and sqlstt <> '21000';
             error = *on;
             pErrMsg = 'Invalid Serial Number';
             return;
           endif;

         endif;

740aA    // ---------------------------------------
740aA    // Edit route
740aA    if pRoute <> ' ';

740aA      exec sql select rhrte into :rhrte
740aA           from rtehed
740aA           where rhwhse = :pWhse and rhrte = :pRoute
740aA           fetch first row only;

740aA      if sqlstt <> sqlSuccess
740bA       and sqlstt <> '21000';
740aA        error = *on;
740aA        pErrMsg = 'Invalid Route';
740aA        return;
740aA      endif;

740aA    endif;

740aA    // ---------------------------------------
740aA    // Edit route id
740aA    if pRouteId <> ' ';

740aA      exec sql select rhrtid into :rhrtid
740aA           from rtehed
740aA           where rhwhse = :pWhse and rhrtid = :pRouteId
740aA           fetch first row only;

740aA      if sqlstt <> sqlSuccess;
740aA        error = *on;
740aA        pErrMsg = 'Invalid Route Id';
740aA        return;
740aA      endif;

740aA    endif;

740aA    // ---------------------------------------
740aA    // Edit transaction(s)
740aA    if pTran <> ' ';

740aA      // Get list of transactions

740aA      getTranList();

740aA      // Loop through transaction list

740aA      for k = 1 to tranCount;

740aA        %occur(tranList) = k;

740aA        exec sql select lltrn# into :lltrn#
740aA             from liclog
740aA             where llwhse = :pWhse and lltrn# = :tranList.tranNum
740aA             fetch first row only;

740aA        if sqlstt <> sqlSuccess
740bA         and sqlstt <> '21000';
740aA          error = *on;
740aA          pErrMsg = 'Invalid Tran';
740aA          return;
740aA        endif;

740aA      endfor;

740aA    endif;

740aA    // ---------------------------------------
740aA    // If item is blank user must enter route id

740aA    if pItem = *blanks and pRouteId = *blanks;
740aA      error = *on;
740aA      pErrMsg = 'If Item not entered you must enter Route Id';
740aA      return;
740aA    endif;

740aA    // ---------------------------------------
         // Edit combination of all selections
         sqlStmt =  'SELECT lnitem from licinfo '
740aD    //      +  'where lnitem = ' + sq + %trim(pItem) + sq;
740aM            +  'where lnwhse=' + %trim(%editc(pWhse:'Z'));

740aD    //if pWhse > 0;
740aD    //  sqlStmt = %trimr(sqlStmt) + ' '
740aD    //          +  'and lnwhse=' + %trim(%editc(pWhse:'Z'));
740aD    //endif;

740aA    if pItem <> *blanks;
740aA      sqlStmt = %trimr(sqlStmt) + ' '
740aA              +  'and lnitem =' + sq + %trim(pItem) + sq;
740aA    endif;

         if pLot <> *blanks;
           sqlStmt = %trimr(sqlStmt) + ' '
                   +  'and lnlot like ' + sq + %trim(pLot) + '%' + sq;
         endif;

         if pPo <> *blanks;
740aD      //sqlStmt = %trimr(sqlStmt) + ' '
740aD      //        +  'and lnpo =' + sq + %trim(pPo) + sq;
740aA      for k = 1 to poCount;
740aA        %occur(poList) = k;
740aM        sqlStmt = %trimr(sqlStmt) + ' '
740aM                +  'and lnpo =' + sq + %trim(poList.poNum) + sq;
740aA      endfor;
         endif;

         if pLcns <> *blanks;
           sqlStmt = %trimr(sqlStmt) + ' '
                   +  'and lnlcns =' + sq + %trim(pLcns) + sq;
         endif;

         if pFMfgDt8 > 0;
           sqlStmt = %trimr(sqlStmt) + ' '
                   +  'and lnmfgdate >=' +  %char(pFMfgDt8)
                   +  ' and lnmfgdate <=' +  %char(pTMfgDt8);
         endif;

         if pFMfgEDt8 > 0;
           sqlStmt = %trimr(sqlStmt) + ' '
                   +  'and lnmfgexp >=' + %char(pFMfgEDt8)
                   +  ' and lnmfgexp <=' + %char(pTMfgEDt8);
         endif;

         exec sql prepare chklnsel from :SqlStmt;
         exec sql declare chklncsr scroll cursor for chklnsel;
         exec sql open chklncsr;
           exec sql fetch first from chklncsr
                    into :smhitem;
           if sqlstt <> sqlSuccess
740bA       and sqlstt <> '21000';
             exec sql close chklncsr;
             error = *on;
             pErrMsg = 'No Licenses Exist for the Values Entered';
             return;
           endif;
           exec sql close chklncsr;

       /end-free

     C                   endsr
     *----------------------------------------------------------------
     *  calcBegEndDts  -  Calculate beginning and end dates
     *
     *    Note: Whip through the workfile and get the oldest date.
     *          Some records will have no oldest date, just ignore those.
     *          The oldest date (minus "days before" entered) will be
     *          the begin date for pulling SEL liclog records for the
     *          whse and item to write to the summary file.
     *
     *          Then, whip through the workfile and get the most recent
     *          end date. If you find ANY workfile record with an oldest
     *          date but no end date, then you won't have an end date
     *          because that means there's still an active license.
     *          In other words, you will show everything through today.
     *          So if you don't have an end date, of course you can
     *          disregard "days after" that the user might have entered.
     *          But if there is an end date, then add "days after" to it.
     *
     *----------------------------------------------------------------

      /free
       begsr calcBegEndDts;

         // figure out what begin date is going to be

         exec sql select min(swolddate)
                  into :begdte
                  from sum004wrk
                  where swolddate > 0
740cA                   and swreportid = :reportId;

         if sqlstt <> sqlSuccess;
           begdte = 00010101;
         else;
           begdte -= pDaysBefL;
         endif;


         // figure out what end date is going to be

         for i = 1 to 1;

          // if there any records with an oldest date but no end date
          // then end date will be set to today's date
          cnt = 0;
          exec sql select count(*) into :cnt
                     from sum004wrk
                    where swolddate > 0
                      and swenddate = 0
740cA                 and swreportid = :reportId;

          if sqlstt <> sqlSuccess
           or cnt <> 0;
            enddte = %dec(%date():*iso);
            leave;
          endif;

          // get most recent end date
          exec sql select max(swenddate)
                     into :enddte
                     from sum004wrk
740cA               where swreportid = :reportid;

          if sqlstt <> sqlSuccess;
            enddte = %dec(%date():*iso);
            leave;
          endif;

          // add 'days after' entered by user to end date
          enddte += pDaysAftL;

         endfor;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  updPOdata  -  Update PO data
     *
     *----------------------------------------------------------------

      /free
       begsr updPOdata;

         // Update work records with po data for active po's

         SqlStmt = 'select * '
                 + 'from sum004wrk '
                 + 'inner join pohdr '
                 +   'on swwhse = phwhse '
                 +     'and swpo = phpo '
740cA            +       'where swreportid = ' + %char(reportid);

         exec sql prepare updposel from :SqlStmt;
         exec sql declare updpocsr dynamic scroll cursor for updposel;
         exec sql open updpocsr;

         dow forever = forever;

           exec sql fetch next from updpocsr
                    into :dsswrec, :phrec;

           if sqlstt <> sqlSuccess
740bA       and sqlstt <> '21000';
             leave;
           endif;

           exec sql update sum004wrk set
                     swven    = :phven,
                     swvnam   = :phvnam,
                     swvad1   = :phvad1,
                     swvad2   = :phvad2,
                     swvcty   = :phvcty,
                     swvst    = :phvst,
                     swvzp1   = :phvzp1,
                     swvndldt = :phdate,
                     swvndltm = :phtime
                     where swwhse = :phwhse
                       and swpo   = :phpo;

         enddo;

         exec sql close updpocsr;


         // Update work records with po data for closed po's

         SqlStmt = 'select * '
                 + 'from sum004wrk '
                 + 'inner join pohhdr '
                 +   'on swwhse = phhwhs '
                 +     'and swpo = phhpo '
740cA            +       'where swreportid = ' + %char(reportid);

         exec sql prepare updpohsel from :SqlStmt;
         exec sql declare updpohcsr dynamic scroll cursor for updpohsel;
         exec sql open updpohcsr;

         dow forever = forever;

           exec sql fetch next from updpohcsr
                    into :dsswrec, :phhrec;

           if sqlstt <> sqlSuccess
740bA       and sqlstt <> '21000';
             leave;
           endif;

           exec sql update sum004wrk set
                     swven    = :phhven,
                     swvnam   = :phhvna,
                     swvad1   = :phhva1,
                     swvad2   = :phhva2,
                     swvcty   = :phhvct,
                     swvst    = :phhvst,
                     swvzp1   = :phhvzp,
                     swvndldt = :phhdte,
                     swvndltm = :phhtim
                     where swwhse = :phhwhs
                       and swpo   = :phhpo;

         enddo;

         exec sql close updpohcsr;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  updWrkEndDate
720aA*                 -  Default enddte to current date.
720aA*                 -  If license in licactive use curr date, else
720aM*                    write the license end date (if it has one)
     *                    in the workfile record.
     *
     *    Note: For each work record go to liclog and if you find a
     *          DELZRO for that license then write the add t/s date
     *          as the end date in the work record.
     *
720aA*          Revised sql logic to improve efficiency.
     *----------------------------------------------------------------

      /free
       begsr updWrkEndDate;

720aA    enddte = %dec(%date():*iso);

720aA    dow forever = forever;
720aA      exec sql select lalcns into :lalcns
720aA           from licactive
720aA           where lawhse = :swwhse and lalcns = :swlcns
720aA           fetch first row only;
720aA      if sqlstt = sqlSuccess
740bA       and sqlstt <> '21000';
720aA        leave;
720aA      endif;

           SqlStmt = 'select * '
                   + 'from sum004wrk '
                   + 'inner join liclog '
                   +   'on swwhse = llwhse '
                   +     'and swlcns = lllcns '
720aA              +       'where '
720aA              +         'llexcd = ' + sq + 'DELZRO' + sq + ' '
740cA              +           'and swreportid =  ' + %char(reportid)
720aA              +             ' order by lladdts desc ';

           exec sql prepare updendsel from :SqlStmt;
           exec sql declare updendcsr dynamic scroll cursor for updendsel;
           exec sql open updendcsr;

720aD      //dow forever = forever;

720aD      //exec sql fetch next from updendcsr
720aM      exec sql fetch first from updendcsr
                    into :dsswrec, :llrec;

720aA      if sqlstt = sqlSuccess
740bA       or sqlstt = '21000';
             enddte = %dec(%date(lladdts):*iso);
720aA      endif;

720aD      //if llexcd <> 'DELZRO';
720aD      //  iter;
720aD      //endif;

720aA      leave;

720aA      enddo;

           exec sql update sum004wrk set
                     swenddate = :enddte
                     where swwhse = :llwhse
                       and swlcns = :lllcns;

720aD    //enddo;

         exec sql close updendcsr;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  updWrkOldDate  -  Write the "oldest date" in the work records.
     *
     *    Note: For a non production item look for pick slots and
     *          match the item, pick slot and license to PUT, RPL,
     *          or TFR records in LICLOG and find the oldest date of
     *          those LICLOG records and write it in the work record.
     *
     *          For a prodution item go look for slots based on the
     *          mfg line's Receiving Aisle.
     *
     *----------------------------------------------------------------

      /free
       begsr updWrkOldDate;

740cD    //setll (*loval) sum004wrk;
740cM      setll (pwhse:reportid) sum004wrk;

         dow forever = forever;

740cD      //read sum004wrk;
740cM      reade (pwhse:reportid) sum004wrk;
           if %eof(sum004wrk);
             leave;
           endif;

           oldestDate = 0;

           // If non production item look for pick slots, if production item
           // you must look for slots whose aisle matches the value from the
           // mfg line's Receiving Aisle

           select;

             when swwo# = ' ';

               // Non production items

               kystat='A';
               kypick='Y';
               setll (swwhse:switem:kystat:kypick) slot3;
               dow forever = forever;
                 reade (swwhse:switem:kystat:kypick) slot3;

                 if %eof(slot3);
                   leave;
                 endif;

                 // ignore special need slots
                 if sldesg = 'BFC';
                   iter;
                 endif;

                 exsr getLiclOldest;

               enddo;

             other;

               // If you made it here this is a production item, so retrieve
               // slot record based on the mfg line's Receiving Aisle

               exec sql select * into :plrec
                        from plined
                        where inwhse  = :swwhse
                          and inlneno = :swmfgno;

               if sqlstt <> sqlSuccess;
                 iter;
               endif;

               setll (swwhse:itwhdp:switem) slot4;
               dow forever = forever;
                 reade (swwhse:itwhdp:switem) slot4;

                 if %eof(slot4);
                   leave;
                 endif;

                 // if slot aisle <> mfg line receiving aisle keep looking
                 if slaisl <> inrcvaisl;
                   iter;
                 endif;

                 // if slot status is not A (active) keep looking
                 if slstat <> 'A';
                   iter;
                 endif;

                 // ignore special need slots
                 if sldesg = 'BFC';
                   iter;
                 endif;

                 exsr getLiclOldest;

               enddo;

           endsl;


           // write the oldest date in the work record
           eval swolddate = oldestdate;
           update swrec;

         enddo;

       endsr;
      /end-free

750bA*----------------------------------------------------------------
750bA*  updRecallPO - If po in recall record is blank and orig license is
750bA*             not, update recall record with licinfo po of the
750bA*             orig license.
750bA*
750bA*----------------------------------------------------------------

750bA /free
750bA  begsr updRecallPO;

750cD    //setll (*loval) sum004;
750cM    setll (pwhse:reportid) sum004;

         dow forever = forever;

750cD      //read sum004;
750cM      reade (pwhse:reportid) sum004;
           if %eof(sum004);
             leave;
           endif;
           if smpo <> ' ' or smolcns = ' ';
             iter;
           endif;

           exec sql select lnpo into :lnpo
                from licinfo
                where lnwhse = :pWhse and lnlcns = :smolcns
                fetch first row only;

           // write orig license po into recall record
           if sqlstt = sqlSuccess;
             smpo = lnpo;
             update smrecx;
           endif;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getLiclOldest  -  Get the liclog record for PUT, RPL, or TRF
     *                    with the oldest date.
     *
     *----------------------------------------------------------------

      /free
       begsr getLiclOldest;

         kyaction = 'PUT';
         setll (kyaction:swwhse:slwhdp:sldisp:switem:swlcns) liclog13;
         dow forever = forever;
           reade (kyaction:swwhse:slwhdp:sldisp:switem:swlcns)
                  liclog13;

           if %eof(liclog13);
             leave;
           endif;

           // capture the oldest date
           select;

             when oldestdate = 0 and swlcns = lllcns;
               oldestdate = %dec(%date(lladdts):*iso);

             when oldestdate > %dec(%date(lladdts):*iso)
                  and swlcns = lllcns;
               oldestdate = %dec(%date(lladdts):*iso);

           endsl;

         enddo;


         kyaction = 'RPL';
         setll (kyaction:swwhse:slwhdp:sldisp:switem:swlcns) liclog13;
         dow forever = forever;
           reade (kyaction:swwhse:slwhdp:sldisp:switem:swlcns)
                  liclog13;

           if %eof(liclog13);
             leave;
           endif;

           // capture the oldest date
           select;

             when oldestdate = 0 and swlcns = lllcns;
               oldestdate = %dec(%date(lladdts):*iso);

             when oldestdate > %dec(%date(lladdts):*iso)
                  and swlcns = lllcns;
               oldestdate = %dec(%date(lladdts):*iso);

           endsl;

         enddo;


         kyaction = 'TFR';
         setll (kyaction:swwhse:slwhdp:sldisp:switem:swlcns) liclog13;
         dow forever = forever;
           reade (kyaction:swwhse:slwhdp:sldisp:switem:swlcns)
                  liclog13;

           if %eof(liclog13);
             leave;
           endif;

           // capture the oldest date
           select;

             when oldestdate = 0 and swlcns = lllcns;
               oldestdate = %dec(%date(lladdts):*iso);

             when oldestdate > %dec(%date(lladdts):*iso)
                  and swlcns = lllcns;
               oldestdate = %dec(%date(lladdts):*iso);

           endsl;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  wrtLiciWrk  -  Write Licinfo workfile records
     *----------------------------------------------------------------

      /free
       begsr wrtLiciWrk;

         clear swrec;

730bA    dow %scan(sq:itdesc) > 0;
730bA       %subst(itdesc:%scan(sq:itdesc):1) = '';
730bA    enddo;

         sqlStmt = 'INSERT INTO sum004wrk '
                 + '(swwhse, swreportid, switem, swdesc,'
                 + 'swlcns, swpo, swlot, swlotpti2, swlotpti4,'
740bM            + 'swentdate, swmfgdate, swmfgexp, swliccrtus,'
740bA            + 'swdtetyp) '
                 +  'SELECT '
                 +  sq + %char(pwhse) + sq + ','
                 +  sq + %char(reportid) + sq + ','
                 +  sq + %trim(pitem) + sq + ','
                 +  sq + %trim(itdesc) + sq + ','
                 +  'lnlcns, lnpo, lnlot, lnlotpti2, lnlotpti4, '
740bM            +  'lnentdate, lnmfgdate, lnmfgexp, lnaddusr, '
740bA            +  'lnenttype '
                 +  'FROM licinfo as a '
                 +  'WHERE '
                 +  'a.lnitem = ' + sq + %trim(pItem) + sq;

         if pWhse > 0;
           sqlStmt = %trimr(sqlStmt) + ' '
                   +  'and lnwhse=' + %trim(%editc(pWhse:'Z'));
         endif;

         if pLot <> *blanks;
           sqlStmt = %trimr(sqlStmt) + ' '
                   +  'and lnlot like ' + sq + %trim(pLot) + '%' + sq;
         endif;

         if pPo <> *blanks;
740aD      //sqlStmt = %trimr(sqlStmt) + ' '
740aD      //        +  'and lnpo =' + sq + %trim(pPo) + sq;
740aA      // Loop through PO list
740aA      for k = 1 to poCount;
740aA        %occur(poList) = k;
740aM        sqlStmt = %trimr(sqlStmt) + ' '
740aM                +  'and lnpo =' + sq + %trim(poList.poNum) + sq;
740aA      endfor;
         endif;

         if pLcns <> *blanks;
           sqlStmt = %trimr(sqlStmt) + ' '
                   +  'and lnlcns =' + sq + %trim(pLcns) + sq;
         endif;

         if pFMfgDt8 > 0;
           sqlStmt = %trimr(sqlStmt) + ' '
                   +  'and lnmfgdate >=' +  %char(pFMfgDt8)
                   +  ' and lnmfgdate <=' +  %char(pTMfgDt8);
         endif;

         if pFMfgEDt8 > 0;
           sqlStmt = %trimr(sqlStmt) + ' '
                   +  'and lnmfgexp >=' + %char(pFMfgEDt8)
                   +  ' and lnmfgexp <=' + %char(pTMfgEDt8);
         endif;

         exec sql EXECUTE IMMEDIATE :sqlStmt;

         sqlstt = sqlstt;


       endsr;
      /end-free

     *----------------------------------------------------------------
     *  wrtLiciWrkProd  -  Write Licinfo production workfile records
     *----------------------------------------------------------------

      /free
       begsr wrtLiciWrkProd;

         clear swrec;

         setll (pwhse:sav_item) pwrkordr2;
         dow forever = forever;
           reade (pwhse:sav_item) pwrkordr2;

           if %eof(pwrkordr2);
             leave;
           endif;

           woCYMD = %dec(%subst(wodtetim:1:8):8:0);

           sqlStmt = 'INSERT INTO sum004wrk '
                   + '(swwhse, swreportid, switem, swwo#, '
                   + 'swmfgno, swwodate, swcustwo, swwostat, swrmitem, '
                   + 'swfgitem, swluk4mor, '
                   + 'swlcns, swpo, swlot, swlotpti2, swlotpti4, '
740bM              + 'swentdate, swmfgdate, swmfgexp, swliccrtus, '
740bA              + 'swdtetyp) '
                   +  'SELECT '
                   +  sq + %char(pwhse) + sq + ','
                   +  sq + %char(reportid) + sq + ','
                   +  sq + %trim(wrfgi) + sq + ','
                   +  sq + %trim(wrwo#) + sq + ','
                   +  sq + %char(womfgno) + sq + ','
                   +  sq + %char(woCYMD) + sq + ','
                   +  sq + %trim(wocustwo) + sq + ','
                   +  sq + %trim(wrstat) + sq + ','
                   +  sq + %trim(writem) + sq + ','
                   +  sq + %trim(wrfgi) + sq + ','
                   +  sq + %trim(booleanOn) + sq + ','
                   +  'lnlcns, lnpo, lnlot, lnlotpti2, lnlotpti4, '
740bM              +  'lnentdate, lnmfgdate, lnmfgexp, lnaddusr, '
740bA              +  'lnenttype '
                   +  'FROM licinfo as a '
                   +  'WHERE '
                   +  'a.lnitem = ' + sq + %trim(wrfgi) + sq;

           if pWhse > 0;
             sqlStmt = %trimr(sqlStmt) + ' '
                     +  'and lnwhse=' + %trim(%editc(pWhse:'Z'));
           endif;

           if pFMfgDt8 > 0;
             sqlStmt = %trimr(sqlStmt) + ' '
                     +  'and woCYMD >=' +  %char(pFMfgDt8)
                     +  ' and woCYMD <=' +  %char(pTMfgDt8);
           endif;

           if pFMfgEDt8 > 0;
             sqlStmt = %trimr(sqlStmt) + ' '
                     +  'and woCYMD >=' + %char(pFMfgEDt8)
                     +  ' and woCYMD <=' + %char(pTMfgEDt8);
           endif;

           exec sql EXECUTE IMMEDIATE :sqlStmt;

           sqlstt = sqlstt;

           if sqlstt = sqlSuccess and prodFlag <> 'Y';
             prodFlag = 'Y';
           endif;

         setgt (pwhse:sav_item:wrfgi) pwrkordr2;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FGfromProd -  Execute wrtLiciWrkProd for the recall item, which
     *                will write a workfile record for each FG (finished
     *                good) the recall item goes into and turn on the
     *                swluk4mor flag.
     *
     *                Then loop through sum004wrk1 (which only has recs
     *                with swluk4mor turned on) and call wrtLiciWrkProd
     *                for the work record's FG item and write recs to the
     *                workfile for FG's that this FG goes into. Then turn
     *                off swluk4mor and update the record read from
     *                sum004wrk1 and go onto the next one, looping through
     *                sum004wrk1 until there are no records left with
     *                swluk4mor on.
     *
     *----------------------------------------------------------------

      /free
       begsr FGfromProd;

         sav_item = pitem;
         exsr wrtLiciWrkProd;

         setll (pWhse) sum004wrk1;
         dow forever = forever;
           reade (pwhse) sum004wrk1;

           if %eof(sum004wrk1);
             leave;
           endif;

740cA      if swreportid <> reportid;
740cA        iter;
740cA      endif;

           sav_item = swFGitem;
           exsr wrtLiciWrkProd;

           // Turn off swluk4mor for all workfile records for this FG

           exec sql update sum004wrk1 set swluk4mor = '0'
                    where swfgitem = :sav_item;

           setll (pWhse) sum004wrk1;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  wrtLiclWrk  -  Write Liclog workfile records
     *----------------------------------------------------------------

      /free
       begsr wrtLiclWrk;

740cD    //setll (*loval) sum004wrk;
740cM    setll (pwhse:reportid) sum004wrk;

         dow forever = forever;

740cD      //read sum004wrk;
740cM      reade (pwhse:reportid) sum004wrk;
           if %eof(sum004wrk);
             leave;
           endif;

           setll (swwhse:swlcns) liclog11;
           dow forever = forever;
             reade (swwhse:swlcns) liclog11;

             if %eof(liclog11);
               leave;
             endif;

750aD        //if lllcns = llolcns;
750aM        if l11_lllcns = l11_llolcns;
               iter;
             endif;

             eval sav_swlcns = swlcns;
750aM        eval swlcns = l11_lllcns;
750aM        eval swolcns = l11_llolcns;
             write swrec;
             eval swlcns = sav_swlcns;
             setgt (swwhse:swlcns:l11_lllcns) liclog11;

           enddo;
         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DeleteRecs    Delete records for this report id
     *----------------------------------------------------------------

     p DeleteRecs      b
     d DeleteRecs      pi

      /free

730cM   exec sql delete from sum004wrk
740cA            where swreportid = :reportId;
730cD         // where swreportid = :reportId;

740cA    GetCurrStamp();

740cA    exec sql delete from sum004wrk
740cA             where swwhse = :pwhse
740cA               and exists (select smhwhse
740cA                               from sum004h
740cA                               where smhwhse = :pwhse
740cA                                 and smhaddts < :currstampsys);


      /end-free

     p DeleteRecs      e

     *----------------------------------------------------------------
     *  FillLica    Fill summary fields for recs found in licactive
     *----------------------------------------------------------------

     p FillLica        b
     d FillLica        pi

      /free

        smwhsflg   = 'Y';
        smaction   = ' ';
        smord      = 0;
        smordtype  = ' ';
        smcust     = 0;
        smcord     = 0;
        smcpo      = ' ';
        smcnam     = ' ';
        smcad1     = ' ';
        smcad2     = ' ';
        smccty     = ' ';
        smcst      = ' ';
        smczip     = ' ';
        smrte      = ' ';
        smrtid     = ' ';
        smstop     = 0;
        smtruk     = ' ';
        smorupdt   = 0;
        smoruptm   = 0;

      /end-free

     p FillLica        e

     *------------------------------------------------------------------
     *  FillLicaUci  Fill summary uci fields for recs found in licactive
     *------------------------------------------------------------------

     p FillLicaUci     b
     d FillLicaUci     pi

      /free

        s1whsflg   = 'Y';
        s1qty1     = 1;
        s1qty2     = 0;
        s1qty3     = 0;

      /end-free

     p FillLicaUci     e

     *----------------------------------------------------------------
     *  FillLiclAdj  Fill summary fields for liclog ADJ records
     *----------------------------------------------------------------

     p FillLiclAdj     b
     d FillLiclAdj     pi

      /free

        smwhsflg   = 'N';
        smslot     = ' ';
        smseladjdt = %dec(%date(lladdts):*iso);


        // get order info
        getordh();


        // get route number
        exec sql select rhrte
                 into :smrte
                 from rtehed
                 where rhwhse = :pwhse
                   and rhrtid = :smrtid;

        if sqlstt <> sqlSuccess;
          smrte = ' ';
        endif;

      /end-free

     p FillLiclAdj     e

750aA*------------------------------------------------------------------
750aA*  FillLiclNeg  Fill summary fields for liclog negative SEL records
750aA*------------------------------------------------------------------
750aA
     p FillLiclNeg     b
     d FillLiclNeg     pi

      /free

        smwhse     = l1_llwhse;
        smreportid = reportId;
        smaction   = 'SEL';
        smlcns     = l1_lllcns;
        smolcns    = l1_llolcns;
        smqty1     = l1_llaqty1;
        smqty2     = l1_llaqty2;
        smqty3     = l1_llaqty3;
        smitem     = l1_llitem;
        smord      = l1_llord;
        smseladjus = l1_lladdeusr;
        smatran    = l1_lltrn#;
        smalbl     = l1_lllbl#;
        smlbl      = l1_lllbl#;
        smwhsflg   = 'N';
        smslot     = ' ';
        smseladjdt = %dec(%date(l1_lladdts):*iso);

        // get licinfo data if liclog original license is in workfile
        exec sql select replace(swdesc,chr(39),chr(0)),
                        swpo, swlot, swlotpti2, swlotpti4,
                        swolddate, swenddate, swentdate, swmfgdate,
                        swmfgexp, swven, swvnam, swvad1, swvad2,
                        swvcty, swvst, swvzp1, swvndldt, swvndltm,
                        swliccrtus, swdtetyp
                 into :smdesc, :smpo, :smlot, :smlotpti2, :smlotpti4,
                      :smolddate, :smenddate, :smentdate, :smmfgdate,
                      :smmfgexp, :smven, :smvnam, :smvad1, :smvad2,
                      :smvcty, :smvst, :smvzp1, :smvndldt, :smvndltm,
                      :smliccrtus, :swdtetyp
                 from sum004wrk
                 where swwhse = :pwhse
                   and swlcns = :smolcns
                   and swreportid = :reportid;

        if sqlstt <> sqlSuccess
         and sqlstt <> '21000';
          smdesc     = ' ';
          smpo       = ' ';
          smlot      = ' ';
          smlotpti2  = ' ';
          smlotpti4  = ' ';
          smolddate  = 0;
          smenddate  = 0;
          smentdate  = 0;
          smmfgdate  = 0;
          smmfgexp   = 0;
          smven      = 0;
          smvnam     = ' ';
          smvad1     = ' ';
          smvad2     = ' ';
          smvcty     = ' ';
          smvst      = ' ';
          smvzp1     = ' ';
          smvndldt   = 0;
          smvndltm   = 0;
          smliccrtus = ' ';
        endif;


        // get order info
        getordh();


        // get route number
        exec sql select rhrte
                 into :smrte
                 from rtehed
                 where rhwhse = :pwhse
                   and rhrtid = :smrtid;

        if sqlstt <> sqlSuccess;
          smrte = ' ';
        endif;

      /end-free

     p FillLiclNeg     e


     *----------------------------------------------------------------
     *  FillLiclPrd  Fill summary fields for liclog production recs
     *               (PIU and PIW)
     *----------------------------------------------------------------

     p FillLiclPrd     b
     d FillLiclPrd     pi

      /free

        smwhsflg   = 'N';
        smslot     = ' ';
        smseladjdt = %dec(%date(lladdts):*iso);


        // get order info
        getordh();


        // get route number
        exec sql select rhrte
                 into :smrte
                 from rtehed
                 where rhwhse = :pwhse
                   and rhrtid = :smrtid;

        if sqlstt <> sqlSuccess;
          smrte = ' ';
        endif;

      /end-free

     p FillLiclPrd     e

     *----------------------------------------------------------------
     *  FillLiclSel  Fill summary fields for liclog SEL records
     *----------------------------------------------------------------

     p FillLiclSel     b
     d FillLiclSel     pi

      /free

        smreportid = reportId;
        smwhsflg   = 'N';
        smslot     = ' ';
        smseladjdt = %dec(%date(lladdts):*iso);

        // get licinfo data if liclog original license is in workfile
730bD   //exec sql select swdesc, swpo, swlot, swlotpti2, swlotpti4,
730bM   exec sql select replace(swdesc,chr(39),chr(0)),
730bM                   swpo, swlot, swlotpti2, swlotpti4,
                        swolddate, swenddate, swentdate, swmfgdate,
                        swmfgexp, swven, swvnam, swvad1, swvad2,
                        swvcty, swvst, swvzp1, swvndldt, swvndltm,
740bM                   swliccrtus, swdtetyp
                 into :smdesc, :smpo, :smlot, :smlotpti2, :smlotpti4,
                      :smolddate, :smenddate, :smentdate, :smmfgdate,
                      :smmfgexp, :smven, :smvnam, :smvad1, :smvad2,
                      :smvcty, :smvst, :smvzp1, :smvndldt, :smvndltm,
740bM                 :smliccrtus, :swdtetyp
                 from sum004wrk
                 where swwhse = :pwhse
                   and swlcns = :smolcns
740cA              and swreportid = :reportid;

        if sqlstt <> sqlSuccess
740bA    and sqlstt <> '21000';
          smdesc     = ' ';
          smpo       = ' ';
          smlot      = ' ';
          smlotpti2  = ' ';
          smlotpti4  = ' ';
          smolddate  = 0;
          smenddate  = 0;
          smentdate  = 0;
          smmfgdate  = 0;
          smmfgexp   = 0;
          smven      = 0;
          smvnam     = ' ';
          smvad1     = ' ';
          smvad2     = ' ';
          smvcty     = ' ';
          smvst      = ' ';
          smvzp1     = ' ';
          smvndldt   = 0;
          smvndltm   = 0;
          smliccrtus = ' ';
        endif;


        // get order info
        getordh();


        // get route number
        exec sql select rhrte
                 into :smrte
                 from rtehed
                 where rhwhse = :pwhse
                   and rhrtid = :smrtid;

        if sqlstt <> sqlSuccess;
          smrte = ' ';
        endif;

740aA   //750aD  smatran = lltrn#;
740bA   //750aD  smlbl   = lllbl#;
740bA   //750aD  smalbl  = lllbl#;

      /end-free

     p FillLiclSel     e

     *----------------------------------------------------------------
     *  FillSelUci  Fill summary uci fields for selection records
     *------------------------------------------------------------------

     p FillSelUci      b
     d FillSelUci      pi

      /free

        s1whsflg   = 'N';

      /end-free

     p FillSelUci      e

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

     *----------------------------------------------------------------
     *  GetOrdh  Get order info
     *----------------------------------------------------------------

     p GetOrdh         b
     d GetOrdh         pi

      /free

730bD  //exec sql select ohtype, ohcust, ohcord, ohcpo, ohcnam,
730bM    exec sql select ohtype, ohcust, ohcord, ohcpo,
730bM                    replace(ohcnam,chr(39),chr(0)),
                         ohcad1, ohcad2, ohccty, ohcst, ohczip,
                         ohrte, ohstop, ohtruk, ohudte, ohutim
                  into :smordtype, :smcust, :smcord, :smcpo, :smcnam,
                       :smcad1, :smcad2, :smccty, :smcst, :smczip,
                       :smrtid, :smstop, :smtruk, :smorupdt, :smoruptm
                  from ordh
                  where ohwhse = :pwhse
                    and ohord  = :smord;

         if sqlstt <> sqlSuccess;
           smordtype = ' ';
           smcust    = 0;
           smcord    = 0;
           smcpo     = ' ';
           smcnam    = ' ';
           smcad1    = ' ';
           smcad2    = ' ';
           smccty    = ' ';
           smcst     = ' ';
           smczip    = ' ';
           smrtid    = ' ';
           smstop    = 0;
           smtruk    = ' ';
           smorupdt  = 0;
           smoruptm  = 0;
         endif;


740aA   chain (smwhse:smrtid) ordhm2;
740aA   if not %found;
740aA     smadlvdat = 20010101;

740aA   else;

740aA  // Departure date

740aA  //  Initialize delivery date if not numeric
740aA     if %check('0123456789' : %subst(hmmsc4:1:8)) <> 0;
740aA       smadlvdat = 20010101;

740aA     else;

740aA    //  Convert alpha date to numeric
740aA       smadlvdat = %dec(%subst(hmmsc4:1:8):8:0);

740aA     endif;

740aA   endif;


      /end-free

     p GetOrdh         e

740aA*----------------------------------------------------------------
740aA*  getPoList      Extract PO's into a list
740aA*----------------------------------------------------------------
740aA
     p getPoList       b
     d getPoList       pi

     * Local Variables

     d  pos            s              5  0
     d  start          s              5  0
     d  pPoLen         s              5  0
     d  singlePoLen    s              5  0

      /free

       // PO's are separated by blanks

       start = 1;
       pPoLen = %len(%trimr(pPo));
       poCount = 0;

       dow start <= pPoLen;
         pos = %scan(' ': pPo: start);

         select;

           when pos > 0;
             singlePoLen = pos - start;
             poCount += 1;
             %occur(poList) = poCount;
             poList.poNum = %subst(pPo: start: singlePoLen);
             start = pos + 1;

           when pos = 0;
             singlePoLen = %len(%trimr(pPo)) - start + 1;
             poCount += 1;
             %occur(poList) = poCount;
             poList.poNum = %subst(pPo: start: singlePoLen);
             leave;

           other;
             leave;

         endsl;

       enddo;

      /end-free

     p                 e

740aA*----------------------------------------------------------------
740aA*  getTranList    Extract transactions into a list
740aA*----------------------------------------------------------------
740aA
     p getTranList     b
     d getTranList     pi

     * Local Variables

     d  pos            s              5  0
     d  start          s              5  0
     d  pTranLen       s              5  0
     d  singleTranLen  s              5  0

      /free

       // Transactions are separated by blanks

       start = 1;
       pTranLen = %len(%trimr(pTran));
       tranCount = 0;

       dow start <= pTranLen;
         pos = %scan(' ': pTran: start);

         select;

           when pos > 0;
             singleTranLen = pos - start;
             tranCount += 1;
             %occur(tranList) = tranCount;
             tranList.tranNum = %dec(%subst(pTran: start: singleTranLen):7:0);
             start = pos + 1;

           when pos = 0;
             singleTranLen = %len(%trimr(pTran)) - start + 1;
             tranCount += 1;
             %occur(tranList) = tranCount;
             tranList.tranNum = %dec(%subst(pTran: start: singleTranLen):7:0);
             leave;

           other;
             leave;

         endsl;

       enddo;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  WrtLicaSum   Write licactive summary records
     *----------------------------------------------------------------

     p WrtLicaSum      b
     d WrtLicaSum      pi

      /free
        error = *off;

        // Loop through work file and join to licactive to write
        // summary records for licenses which are currently in the whse

        // SqlStmt = 'select '
        //      +   'swwhse, swreportid, switem, swdesc, lalcns, '
        //      +   'laolcns, swpo, swlot, swlotpti2, swlotpti4, '
        //      +   'swolddate, swentdate, swmfgdate, swmfgexp, '
700aD   //      +   'labase, laqty1, laqty2, laqty3, '
        //      +   'swven, swvnam, swvad1, swvad2, swvcty, '
        //      +   'swvst, swvzp1, swvndldt, swvndltm, '
        //      +   'swliccrtus '
        //      + 'from sum004wrk '
        //      + 'inner join licactive '
        //      +   'on swwhse = lawhse and swlcns = lalcns';

        SqlStmt = 'select '
730bD   //      +   'swwhse, swreportid, switem, swdesc, lalcns, '
730bM           +   'swwhse, swreportid, switem, '
730bM           +   'replace(swdesc,chr(39),chr(0)), lalcns, '
                +   'laolcns, swpo, swlot, swlotpti2, swlotpti4, '
                +   'swolddate, swentdate, swmfgdate, swmfgexp, '
700aM           +   'ladisp, laqty1, laqty2, laqty3, '
                +   'swven, swvnam, swvad1, swvad2, swvcty, '
                +   'swvst, swvzp1, swvndldt, swvndltm, '
                +   'swliccrtus '
                + 'from sum004wrk '
                + 'inner join licactive '
                +   'on swwhse = lawhse and swlcns = lalcns'
740cA           +     ' where swreportid =  ' + %char(reportid);

        exec sql prepare licasel from :SqlStmt;
        exec sql declare licacsr dynamic scroll cursor for licasel;
        exec sql open licacsr;

        dow forever = forever;

          exec sql fetch next from licacsr
                   into :smwhse, :smreportid, :smitem, :smdesc, :smlcns,
                        :smolcns, :smpo, :smlot, :smlotpti2, :smlotpti4,
                        :smolddate, :smentdate, :smmfgdate, :smmfgexp,
                        :smslot, :smqty1, :smqty2, :smqty3,
                        :smven, :smvnam, :smvad1, :smvad2, :smvcty,
                        :smvst, :smvzp1, :smvndldt, :smvndltm,
                        :smliccrtus;

          if sqlstt <> sqlSuccess
740bA      and sqlstt <> '21000';
             leave;
          endif;

        FillLica();

        // Create record

        exec sql insert into sum004 values(:smrec);

        if sqlstt <> sqlSuccess;
          error = *on;
          pErrMsg = 'Error adding lica record: '
                  + 'Sqlstt(' + sqlstt + ') '
                  + 'Whse(' + %char(pWhse) + ') '
                  + 'RptId(' + %char(reportId) + ') '
                  + 'Item(' + %trim(pItem) + ') '
                  + 'Pgm(' + %trim(#pgm) +')';
          leave;
        endif;

        enddo;

        exec sql close licacsr;

      /end-free

     p WrtLicaSum      e

     *----------------------------------------------------------------
     *  WrtLicaUci   Write UCI summary records for licenses currently
     *               in the whse, in other words, licenses which are in
     *               licactive ... and only when license and original
     *               license are the same.
     *----------------------------------------------------------------

     p WrtLicaUci      b
     d WrtLicaUci      pi

      /free
        error = *off;

        // Loop through "in whse" summary records and join to uciinfo
        // to write summary uci records for licenses currently in the whse

        SqlStmt = 'select '
                +   'smwhse, smreportid, smitem, smdesc, smlcns, '
                +   'uiuci, uiucilcns, uiserial, '
                +   'uiwgtlbs, uiwgtkgs, uisellbl#, uiseltrax '
                + 'from sum004 '
                + 'inner join uciinfo '
                +   'on smwhse = uiwhse and smlcns = uilcns '
                + 'where smwhse = ' + %char(pwhse)
                +   ' and smreportid = ' + %char(reportid)
                +   ' and smlcns = smolcns'
                +   ' and smwhsflg = ' + sq + %trim(yes) + sq;

        exec sql prepare uci1sel from :SqlStmt;
        exec sql declare uci1csr dynamic scroll cursor for uci1sel;
        exec sql open uci1csr;

        dow forever = forever;

          exec sql fetch next from uci1csr
                   into :s1whse, :s1reportid, :s1item, :s1desc, :s1lcns,
                        :s1uiuci, :s1uiucilcn, :s1uiserial,
                        :s1uiwgtlbs, :s1uiwgtkgs, :s1uisellbl, :s1uiseltrx;

          if sqlstt <> sqlSuccess
740bA      and sqlstt <> '21000';
             leave;
          endif;

        FillLicaUci();

        // Create record

        exec sql insert into sum004uci values(:s1rec);

        if sqlstt <> sqlSuccess;
          error = *on;
          pErrMsg = 'Error adding licaUCI record: '
                  + 'Sqlstt(' + sqlstt + ') '
                  + 'Whse(' + %char(pWhse) + ') '
                  + 'RptId(' + %char(reportId) + ') '
                  + 'Item(' + %trim(pItem) + ') '
                  + 'Pgm(' + %trim(#pgm) +')';
          leave;
        endif;

        enddo;

        exec sql close uci1csr;

      /end-free

     p WrtLicaUci      e

     *----------------------------------------------------------------
     *  WrtLiclAdjSum  Write liclog negative adjustment ADJ summary recs
     *----------------------------------------------------------------

     p WrtLiclAdjSum   b
     d WrtLiclAdjSum   pi

      /free
        error = *off;

        // Loop through work file and join to liclog and write a
        // summary record for each neg ADJ record

        SqlStmt = 'select '
730bD   //      +   'swwhse, swreportid, switem, swdesc, lllcns, '
730bM           +   'swwhse, swreportid, switem, '
730bM           +   'replace(swdesc,chr(39),chr(0)), lllcns, '
                +   'llolcns, swpo, swlot, swlotpti2, swlotpti4, '
                +   'swolddate, swentdate, swmfgdate, swmfgexp, '
                +   'llaqty1, llaqty2, llaqty3, llaction, llord, '
                +   'swven, swvnam, swvad1, swvad2, swvcty, '
                +   'swvst, swvzp1, swvndldt, swvndltm, '
                +   'swliccrtus, lladdts, lladdeusr '
                + 'from sum004wrk '
                + 'inner join liclog '
                +   'on swwhse = llwhse and swlcns = lllcns '
                + 'where llaction = ' + sq + %trim(adj) + sq
740cA           +   ' and swreportid = ' + %char(reportid);

        exec sql prepare licladjsel from :SqlStmt;
        exec sql declare licladjcsr dynamic scroll cursor for licladjsel;
        exec sql open licladjcsr;

        dow forever = forever;

          exec sql fetch next from licladjcsr
                   into :smwhse, :smreportid, :smitem, :smdesc, :smlcns,
                        :smolcns, :smpo, :smlot, :smlotpti2, :smlotpti4,
                        :smolddate, :smentdate, :smmfgdate, :smmfgexp,
                        :smqty1, :smqty2, :smqty3, :smaction, :smord,
                        :smven, :smvnam, :smvad1, :smvad2, :smvcty,
                        :smvst, :smvzp1, :smvndldt, :smvndltm,
                        :smliccrtus, :lladdts, :smseladjus;

          if sqlstt <> sqlSuccess
740bA      and sqlstt <> '21000';
            leave;
          endif;

          if (smqty1 + smqty2 + smqty3) >= 0;
            iter;
          endif;

        FillLiclAdj();

        // Create record

        exec sql insert into sum004 values(:smrec);

        if sqlstt <> sqlSuccess;
          error = *on;
          pErrMsg = 'Error adding licl ADJ record: '
                  + 'Sqlstt(' + sqlstt + ') '
                  + 'Whse(' + %char(pWhse) + ') '
                  + 'RptId(' + %char(reportId) + ') '
                  + 'Item(' + %trim(pItem) + ') '
                  + 'Pgm(' + %trim(#pgm) +')';
          leave;
        endif;

        enddo;

        exec sql close licladjcsr;

      /end-free

     p WrtLiclAdjSum   e

750aA*----------------------------------------------------------------
750aA*  WrtLiclNegSum  Write liclog *NG selection records for RPK when
     *                 the RPK is put away into a slot with negative qty.
750aA*----------------------------------------------------------------
750aA
     p WrtLiclNegSum   b
     d WrtLiclNegSum   pi

      /free
        error = *off;

        // Write a summary record for each *NG selection record tied to a repack

        // Loop through work file, join to liclog looking for repacks,
        // then with those hits look for NG's, then with those hits
        // look for the SEL records tied to them.

        // look for repacks ...
        setll (pwhse:reportid) sum004wrk;
        dow forever = forever;
          reade (pwhse:reportid) sum004wrk;

          if %eof(sum004wrk);
            leave;
          endif;

750dA     if swolcns = *blanks;
750dA       iter;
750dA     endif;

          setll (swwhse:swolcns) liclog11;
          dow forever = forever;
            reade (swwhse:swolcns) liclog11;

            if %eof(liclog11);
              leave;
            endif;

750dD       //if l11_llolcns = *blanks;
750dD       //  iter;
750dD       //endif;

            if l11_llaction <> 'RPK';
              iter;
            endif;

            if l11_llbase <> 'RCVREPACK';
              iter;
            endif;


          // look for NG's ...
          setll (l11_llwhse:l11_lllcns) liclog;
          dow forever = forever;
            reade (l11_llwhse:l11_lllcns) liclog;

            if %eof(liclog);
              leave;
            endif;

            if llaction <> 'NG ';
              iter;
            endif;

            // look for SEL records for the NG's

            setll (llwhse:llflcns) liclog1;
            dow forever = forever;
              reade (llwhse:llflcns) liclog1;

              if %eof(liclog1);
                leave;
              endif;

              if llflcns <> l1_lllcns or
                l1_llaction <> 'SEL';
                iter;
              endif;


              FillLiclNeg();

              // Create record

                write(e) smrecx;

                if %error;
                  error = *on;
                  pErrMsg = 'Error adding licl NEG SEL record: '
                          + 'Whse(' + %char(pWhse) + ') '
                          + 'RptId(' + %char(reportId) + ') '
                          + 'Item(' + %trim(pItem) + ') '
                          + 'Pgm(' + %trim(#pgm) +')';
                  leave;
                endif;

                exwhse = pWhse;
                monitor;
                  exsum004 ('*ADD': exRtnCode: exRtnMsg: exWhse: smreportid:
                          smlcns: smadlvdat: smatran: smalbl: swdtetyp);
                on-error;
                endmon;

              enddo;

            enddo;

          enddo;

        enddo;

      /end-free

     p WrtLiclNegSum   e

     *----------------------------------------------------------------
     *  WrtLiclPrdSum  Write liclog production PIU & PIW summary recs
     *                 PIU = Production end of day adjustments usage
     *                 PIW = Production end of day adjustments waste
     *----------------------------------------------------------------

     p WrtLiclPrdSum   b
     d WrtLiclPrdSum   pi

      /free
        error = *off;

        // Loop through work file and join to liclog and write a
        // summary record for each PIU and PIW record

        SqlStmt = 'select '
730bD   //      +   'swwhse, swreportid, switem, swdesc, lllcns, '
730bM           +   'swwhse, swreportid, switem, '
730bM           +   'replace(swdesc,chr(39),chr(0)), lllcns, '
                +   'llolcns, swpo, swlot, swlotpti2, swlotpti4, '
                +   'swolddate, swentdate, swmfgdate, swmfgexp, '
                +   'llaqty1, llaqty2, llaqty3, llaction, llord, '
                +   'swven, swvnam, swvad1, swvad2, swvcty, '
                +   'swvst, swvzp1, swvndldt, swvndltm, '
                +   'swliccrtus, lladdts, lladdeusr, '
                +   'swwo#, swmfgno, swwodate, swcustwo, '
                +   'swwostat, swrmitem, swfgitem '
                + 'from sum004wrk '
                + 'inner join liclog '
                +   'on swwhse = llwhse and swlcns = llolcns '
                + 'where llaction = ' + sq + %trim(piu) + sq
                +   ' or llaction = ' + sq + %trim(piw) + sq
740cA           +   ' and swreportid = ' + %char(reportid);

        exec sql prepare liclprdsel from :SqlStmt;
        exec sql declare liclprdcsr dynamic scroll cursor for liclprdsel;
        exec sql open liclprdcsr;

        dow forever = forever;

          exec sql fetch next from liclprdcsr
                   into :smwhse, :smreportid, :smitem, :smdesc, :smlcns,
                        :smolcns, :smpo, :smlot, :smlotpti2, :smlotpti4,
                        :smolddate, :smentdate, :smmfgdate, :smmfgexp,
                        :smqty1, :smqty2, :smqty3, :smaction, :smord,
                        :smven, :smvnam, :smvad1, :smvad2, :smvcty,
                        :smvst, :smvzp1, :smvndldt, :smvndltm,
                        :smliccrtus, :lladdts, :smseladjus,
                        :smwo#, :smmfgno, :smwodate, :smcustwo,
                        :smwostat, :smrmitem, :smfgitem;

          if sqlstt <> sqlSuccess
740bA      and sqlstt <> '21000';
            leave;
          endif;

        FillLiclPrd();

        // Create record

        exec sql insert into sum004 values(:smrec);

        if sqlstt <> sqlSuccess;
          error = *on;
          pErrMsg = 'Error adding licl PIU/PIW record: '
                  + 'Sqlstt(' + sqlstt + ') '
                  + 'Whse(' + %char(pWhse) + ') '
                  + 'RptId(' + %char(reportId) + ') '
                  + 'Item(' + %trim(pItem) + ') '
                  + 'Pgm(' + %trim(#pgm) +')';
          leave;
        endif;

        enddo;

        exec sql close liclprdcsr;

      /end-free

     p WrtLiclPrdSum   e

     *----------------------------------------------------------------
     *  WrtLiclSelSum   Write liclog selection (SEL) summary records
     *----------------------------------------------------------------

     p WrtLiclSelSum   b
     d WrtLiclSelSum   pi

      /free
        error = *off;

        // Get all liclog SEL records for the whse and item that are within
        // the begin and end date range.

750aM   SqlStmt = 'select distinct '
750cM           +   'l.llwhse, l.llaction, l.lllcns, l.llolcns, '
750cM           +   'l.llaqty1, l.llaqty2, l.llaqty3, l.llitem, '
750cM           +   'l.llord, l.lladdts, l.lladdeusr, l.lltrn#, '
750cM           +   'l.lllbl#, swdtetyp '
750cM           + 'from liclog8 as l '
                + 'inner join sum004wrk '
750aD       //  +   'on llwhse = swwhse and llolcns = swlcns '
750cM           +   'on l.llwhse = swwhse and l.llitem = switem '
750cM           + 'where l.llaction = ' + sq + %trim(sel) + sq
740cA           + ' and swreportid = ' + %char(reportid);

750cA    if pLcns <> *blanks;
750cA      sqlStmt = %trimr(sqlStmt) + ' '
750cA              +  'and l.llolcns =' + sq + %trim(pLcns) + sq;
750cA    endif;

        exec sql prepare licl8sel from :SqlStmt;
        exec sql declare licl8csr dynamic scroll cursor for licl8sel;
        exec sql open licl8csr;

        dow forever = forever;

          exec sql fetch next from licl8csr
                   into :smwhse, :smaction, :smlcns, :smolcns,
                        :smqty1, :smqty2, :smqty3, :smitem,
740aD                   //:smord, :lladdts, :smseladjus;
750aM                   :smord, :l8lladdts, :smseladjus, :l8lltrn#,
750aM                   :l8lllbl#, :swdtetyp;

          if sqlstt <> sqlSuccess
740bA      and sqlstt <> '21000';
            leave;
          endif;

750dD     // 750d Commented out this entire select set
750aA     //select;

750aA       //when begdte > %dec(%date(l8lladdts):*iso)
750aA            //and %subst(smlcns:1:3) = '*NG';

750aA         //exec sql select llaction into :llaction
750aA              //from liclog
750aA              //where llwhse = :pWhse and lllcns = :smlcns
750aA                    //and llaction = 'NG '
750aA              //fetch first row only;

750aA         //if sqlstt <> sqlSuccess;
750aA           //iter;
750aA         //endif;

750aA         //setll (smwhse:smlcns) liclog;
750aA         //dow forever = forever;
750aA           //reade (smwhse:smlcns) liclog;

750aA           //if %eof(liclog);
750aA             //leave;
750aA           //endif;

750aA           // ignore if action not SEL
750aA           //if llaction <> 'SEL';
750aA             //iter;
750aA           //else;
750aA           //endif;

750aA           //FillLiclSel();
750aA           //smseladjdt = %dec(%date(lladdts):*iso);
750aA           //smatran = lltrn#;
750aA           //smlbl   = lllbl#;
750aA           //smalbl  = lllbl#;
750aA           //WrtLiclSelSum1();

750aA         //enddo;
750aA     //endsl;

750aM     if begdte > %dec(%date(l8lladdts):*iso);
            iter;
          endif;

750aM     if enddte < %dec(%date(l8lladdts):*iso);
740aD     //  iter;
          endif;

          FillLiclSel();
750aA     smseladjdt = %dec(%date(l8lladdts):*iso);
750aA     smatran = l8lltrn#;
750aA     smlbl   = l8lllbl#;
750aA     smalbl  = l8lllbl#;
750aA     WrtLiclSelSum1();

        enddo;

        exec sql close licl8csr;

      /end-free

     p WrtLiclSelSum   e

750aA*----------------------------------------------------------------
750aA*  WrtLiclSelSum1  Write liclog selection (SEL) summary records
750aA*----------------------------------------------------------------
750aA
     p WrtLiclSelSum1  b
     d WrtLiclSelSum1  pi

      /free

        dow forever = forever;

          if pRoute <> ' ' and pRoute <> smrte;
            leave;
          endif;

          if pRouteId <> ' ' and pRouteId <> smrtid;
            leave;
          endif;

          if pFdlvDat8 <> 0 and pFdlvDat8 < smadlvdat;
            leave;
          endif;

          if pTdlvDat8 <> 0 and pTdlvDat8 > smadlvdat;
            leave;
          endif;

          if pTran <> ' ';
            tranFound = *off;
            // Loop through transaction list
            for k = 1 to tranCount;
              %occur(tranList) = k;
              if tranList.tranNum <> smatran;
                iter;
              else;
                tranFound = *on;
                leave;
              endif;
            endfor;
            if tranFound = *off;
              leave;
            endif;
          endif;

        // Create record

        exec sql insert into sum004 values(:smrec);

        if sqlstt <> sqlSuccess;
          error = *on;
          pErrMsg = 'Error adding licl SEL record: '
                  + 'Sqlstt(' + sqlstt + ') '
                  + 'Whse(' + %char(pWhse) + ') '
                  + 'RptId(' + %char(reportId) + ') '
                  + 'Item(' + %trim(smitem) + ') '
                  + 'Pgm(' + %trim(#pgm) +')';
          leave;
        endif;

        exwhse = pWhse;
        monitor;
          exsum004 ('*ADD': exRtnCode: exRtnMsg: exWhse: smreportid:
                    smlcns: smadlvdat: smatran: smalbl: swdtetyp);
        on-error;
        endmon;

        leave;

        enddo;

      /end-free

     p WrtLiclSelSum1  e

     *----------------------------------------------------------------
     *  WrtSelUci   Write UCI summary records for licenses which have
     *              gone out through selection ... only when license
     *              and original license are the same.
     *
     *----------------------------------------------------------------

     p WrtSelUci       b
     d WrtSelUci       pi

      /free
        error = *off;

        // Loop through "SEL" summary records (where lcns & orig lcns
        // match) and join to liclog and uciinfo to write summary uci
        // records for licenses that have gone out through selection

        // To tie SEL liclog record to uciinfo use lltrn# to go to
        // uciinfo and tie to uiseltrn#

730cA   // Add item match between summary(workfile) record and uciinfo

        SqlStmt = 'select '
                +   'smwhse, smreportid, smitem, smdesc, smlcns, '
                +   'llaqty1, llaqty2, llaqty3, '
                +   'uiuci, uiucilcns, uiserial, '
                +   'uiwgtlbs, uiwgtkgs, uisellbl#, uiseltrax '
                + 'from sum004 '
                + 'inner join liclog '
                +   'on smwhse = llwhse and smlcns = lllcns '
                + 'inner join uciinfo '
                +   'on smwhse = uiwhse and lltrn# = uiseltrn# '
                + 'where smwhse = ' + %char(pwhse)
                +   ' and smreportid = ' + %char(reportid)
730cA           +   ' and smitem = uiitem'
                +   ' and smlcns = smolcns'
                +   ' and smaction = ' + sq + %trim(sel) + sq
                +   ' and lltrn# <> 0 '
                + 'group by smwhse, smreportid, smitem, smdesc, smlcns, '
                +   'llaqty1, llaqty2, llaqty3, '
                +   'uiuci, uiucilcns, uiserial, '
                +   'uiwgtlbs, uiwgtkgs, uisellbl#, uiseltrax';

        exec sql prepare uci2sel from :SqlStmt;
        exec sql declare uci2csr dynamic scroll cursor for uci2sel;
        exec sql open uci2csr;

        dow forever = forever;

          exec sql fetch next from uci2csr
                   into :s1whse, :s1reportid, :s1item, :s1desc, :s1lcns,
                        :s1qty1, :s1qty2, :s1qty3,
                        :s1uiuci, :s1uiucilcn, :s1uiserial,
                        :s1uiwgtlbs, :s1uiwgtkgs, :s1uisellbl, :s1uiseltrx;

          if sqlstt <> sqlSuccess
740bA      and sqlstt <> '21000';
             leave;
          endif;

        FillSelUci();

        // Create record

        exec sql insert into sum004uci values(:s1rec);

        if sqlstt <> sqlSuccess;
          error = *on;
          pErrMsg = 'Error adding selUCI record: '
                  + 'Sqlstt(' + sqlstt + ') '
                  + 'Whse(' + %char(pWhse) + ') '
                  + 'RptId(' + %char(reportId) + ') '
                  + 'Item(' + %trim(pItem) + ') '
                  + 'Pgm(' + %trim(#pgm) +')';
          leave;
        endif;

        enddo;

        exec sql close uci2csr;

      /end-free

     p WrtSelUci       e

     *----------------------------------------------------------------
     *  updSum4H  -  Update summary header record
     *----------------------------------------------------------------

     p updSum4H        b
     d updSum4H        pi

      /free
         error = *off;

         if prodFlag <> 'Y';
           prodFlag = 'N';
         endif;

         exec sql update sum004h
                  set smhstatus  = 'C',
                      smhpflag   = :prodFlag
                  where smhwhse  = :pWhse
                    and smhrptid = :reportId;

         if sqlstt <> sqlSuccess;
           error = *on;
           pErrMsg = 'Error updating sum4h record: '
                   + 'Sqlstt(' + sqlstt + ') '
                   + 'Whse(' + %char(pWhse) + ') '
                   + 'RptId(' + %char(reportId) + ') '
                   + 'Item(' + %trim(pItem) + ') '
                   + 'Pgm(' + %trim(#pgm) +')';
         endif;

      /end-free

     p updSum4H        e

     *----------------------------------------------------------------
     *  wrtSum4H  -  Write summary header record
     *----------------------------------------------------------------

     p wrtSum4H        b
     d wrtSum4H        pi

      /free
         error = *off;

         smhwhse    = pWhse;
         smhrptid   = reportId;
         smhdesc    = pRptDesc;
         smhstatus  = 'P';
         smhpflag   = 'U';
         smhitem    = pItem;
         smhlcns    = pLcns;
         smhlot     = pLot;
         smhpo      = pPo;
         smhfrmfgdt = pFMfgDt8;
         smhtomfgdt = pTMfgDt8;
         smhfrmfgex = pFMfgEDt8;
         smhtomfgex = pTMfgEDt8;
         smhserial  = pSerial;
         smhdysbefl = pDaysBefL;
         smhdysaftl = pDaysAftL;
         smhdysbefi = pDaysBefI;
         smhdysafti = pDaysAftI;
         smhaddpgm  = pPgm;
         smhaddusr  = pUser;
         smhaddjob  = #job;
         smhaddnbr  = #jobnbr;

         GetCurrStamp();

         smhaddts = CurrStampSys;
         smhadduc = CurrStampUC;

         // Create record

         exec sql insert into sum004h values(:smhrec);

         if sqlstt <> sqlSuccess;
           error = *on;
           pErrMsg = 'Error adding sum4h record: '
                   + 'Sqlstt(' + sqlstt + ') '
                   + 'Whse(' + %char(pWhse) + ') '
                   + 'RptId(' + %char(reportId) + ') '
                   + 'Item(' + %trim(pItem) + ') '
                   + 'Pgm(' + %trim(#pgm) +')';
         endif;


740aA    exRtnCode  = '*OK';
740aA    exWhse     = pwhse;
740aA    sharoute   = pRoute;
740aA    shartid    = pRouteId;
740aA    shafdlvdat = pFdlvDat8;
740aA    shatdlvdat = pTdlvDat8;
740aA    shapo      = pPO;
740aA    shatrn     = pTran;
740aA    monitor;
740aA      exsum004h ('*ADD': exRtnCode: exRtnMsg: exWhse: smhrptid:
740aA            sharoute: shartid: shafdlvdat: shatdlvdat: shapo: shatrn);
740aA    on-error;
740aA    endmon;

740aA    if exRtnCode <> '*OK';
740aA      error = *on;
740aA      pErrMsg = 'Error adding sum004hexa record: '
740aA              + 'Sqlstt(' + sqlstt + ') '
740aA              + 'Whse(' + %char(pWhse) + ') '
740aA              + 'RptId(' + %char(reportId) + ') '
740aA              + 'Item(' + %trim(pItem) + ') '
740aA              + 'Pgm(' + %trim(#pgm) +')';

740aA    endif;


      /end-free

     p wrtSum4H        e

     *----------------------------------------------------------------
