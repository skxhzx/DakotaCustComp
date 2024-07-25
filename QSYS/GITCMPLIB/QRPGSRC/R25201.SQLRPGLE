      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  R25201     Selection Special Adjustment pcs
     *  12 July 2017
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
720 A*    07/12/18  LMC  7.20
     *      - Created
     *      - Copied from R25200 because additional parm is added
720a *    08/02/18  LMC  7.20a
     *      - fixed the sql selection for voexcp when the tran# is
     *        sent in.
730a *    08/28/19  LMC  7.30a
     *      - Enh: We will also calculate the scan % if the genpick
     *        global setting for verify upc is turned on.
     *      - Enh: If the item is uci selection we will count at 100%
     *      - Enh: NOUPC is also an errid now.
740a *    01/22/20  LMC  7.40a
     *      - Enh: Adding logic to handle new selection method 6
     *        UPC Verification Normal UOM only.
750a *    04/05/21  LMC  7.50a
     *      - Enh: We will also calculate the scan % if the genpick
     *        global setting for verify upc is turned on. One section
     *        was missed in the 730a mod
     *----------------------------------------------------------------
     *  Client Custom Revisions: Julius Silvert
     *
JSLaA*  08/15/19  RBD  JSLa
     *    - They want scan percentage to be the total number of items
     *      that could be scanned against the number of items that
     *      were scanned. To achieve that just force 100% if JSL and
     *      item is not selection method 4 or 5.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     Foptions   if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Customer id
     *
JSLaA /copy qcopysrc,id#jsl
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Clients
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getuser
     D client          s             10
     D clientloc       s             10

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

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


     *----------------------------------------------------------------
     * DRI Programs
     *----------------------------------------------------------------


      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------

     d driItemCalled   s               n
     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D*error           s               n
     D forevr          s               n
     d worknet         s              5  0
     d lblcount        s              5  0
     d workscanpct     s              5  0

     D e$whse          s              3  0
     D e$emp#          s              5  0
     D e$fnam          s             15
     D e$init          s              1
     D e$lnam          s             20
     D e$whdp          s              5
     D e$styp          s              1
     D e$shft          s              6
     D e$crew          s              6
     D e$nhrs          s              3  1
     D e$rtn           s              8
     D e$bpu           s              1
     D e$lng           s              2
     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------
     d GetItem         pr
     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

730aA*----------------------------------------------------------------
730aA*  *GENPICK -  General picking options.
730aA*----------------------------------------------------------------
730aA*
730aA* Fields
730aA*
730aA*    OPERPT  -  Print exception (short) error report (Y,N).
730aA*    OPELBL  -  Print exception (short) labels (Y,N)
730aA*    OPRFWC  -  Using RF will call (Y,N).
730aA*    OPNRSC  -  Number of pallet sections (1-9).
730aA*    OPHPWC  -  Host pick Will Call (Y/N).
730aA*    OPMRGA  -  Merge Add-on order(s) with Open Routes.
730aA*    OPPLSQ  -  Pallet number sequence. 1=Unload, 2=Load.
730aA*    OPEADJ  -  Close short labels without adjustment (Y,N).
730aA*    OPNOPK  -  Pick items without pick slot as bulk pick? (Y/N)
730aA*    OPGPK1  -  <Not Used / Available>
730aA*    OPGPK2  -  <Not Used / Available>
730aA*               task has been assigned. (Y/N)
730aA*    OPJITR  -  Create JIT Letdown or JIT Replenishment
730aA*                 0=None. No replenishments are created.
730aA*                 1=Letdowns are created during Truck Builder
730aA*                   Pick/Print processing.
730aA*                 2=Priority Replenishments are created during
730aA*                   Truck Builder Pick/Print processing.
730aA*                 3=JIT Letdowns created when transaction is
730aA*                   checked out.
730aA*                 4=JIT Priority Replenishments created when
730aA*                   transaction is checked out.
730aA*    OPPSET  -  Print separate set summary label for each pallet.
730aA*    OPRFUC  -  RF Pick Verify item with UPC.
730aA*    OPRFLC  -  RF Pick Verify item with license.
730aA*    OPUSF1  -  USF Option: Allow merge items for stop to be split.
730aA*               across truck pallets.
730aA*    OPRFSL  -  RF Pick Verify slot (Y/N)
730aA*    OPRBN1  -  Round robin printing compatable (Y/N)
730aA*    OPRBN2  -  Round robin Type ing compatable (Y/N)
730aA*               1=Off
730aA*               2=By route
730aA*               3=By transaction
730aA*    OPSUBT  -  Allow Customer Item Substitution (Y/N)
730aA*    OPRFQT  -  RF Pick Allow Qty Entry (Y,N)
730aA*    OPRFCS  -  RF Pick Allow Change Slot (Y,N)
730aA*    OPPMTA  -  USF Option: Allow multi-truck assignments.
730aA*    OPMAXA  -  USF Option: Staged route selection limit.
730aA*    OPDOCK  -  USF Option: Dock door prompt choice.
730aA*    OPRFQO  -  RF with Qty over.
730aA*    OPRFPM  -  RF Pick Method.
730aA*    OPRPLT  -  Print Pallet Label.
730aA*    OPRFUI  -  Scan individual UPC for each unit.
730aA*    OPRFZP  -  Zone Pickup.
730aA*    OPRFUW  -  Auto load weight if found in individual upc
730aA*
730aA* Data structure
730aA*
730aAD opdata          ds
730aAD  operpt                 1      1
730aAD  opelbl                 2      2
730aAD  oprfwc                 3      3
730aAD  opnrsc                 4      4  0
730aAD  ophpwc                 5      5
730aAD  opmrga                 6      6
730aAD  opplsq                 7      7
730aAD  opeadj                 8      8
730aAD  opnopk                 9      9
730aAD  opjitr                12     12
730aAD  oppset                13     13
730aAD  oprfuc                14     14
730aAD  oprflc                15     15
730aAD  opusf1                16     16
730aAD  oprfsl                17     17
730aAD  oprbn1                18     18
730aAD  oprbn2                19     19
730aAD  opsubt                20     20
730aAD  oprfqt                21     21
730aAD  oprfcs                22     22
730aAD  oppmta                23     23
730aAD  opmaxa                24     25  0
730aAD  opmaxab               24     25
730aAD  opdock                26     26
730aAD  oprfqo                27     29  0
730aAD  oprfpm                30     30
730aAD  oprplt                31     31
730aAD  oprfui                32     32
730aAD  oprfzp                33     33
730aAD  oprfuw                34     34
730aAD  optend               117    117
     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds


     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  puser          s             10
     D  ppgm           s             10
     D  pwhse          s              3  0
     D  ptran          s              7  0
     D  plabel         s              7  0
     D  psplnet        s              5  0
     D  psplnetadj     s              5  0
     D  pScanPct       s              3  0
     D  plabelcnt      s              5  0
     D  ptotscan       s              5  0

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
     D saveVer#        s                   like($itver#)
     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------
      /copy qcopysrc,p.driitem

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D sxrec         e ds                  extname(voexcp) inz(*EXTDFT)
     D lbrec         e ds                  extname(label) inz(*EXTDFT)
     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D lsrrec        E Ds                  Extname(logselrto)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pMessage    Message
     *      pUser       User
     *      pPgm        Program
     *      pWhse       Warehouse
     *      pTran       Transaction
     *      plabel      Transaction
     *      pSplNet     Special net pcs
     *      pSplNetAdj  Special Adjusted Net pieces
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pUser
     C                   parm                    pPgm
     C                   parm                    pWhse
     C                   parm                    pTran
     C                   parm                    pLabel
     C                   parm                    pSplNet
     C                   parm                    pSplNetAdj
     C                   parm                    pScanPct
     C                   parm                    plabelcnt
     C                   parm                    ptotScan

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        pMessage = '';
        error = *off;
        if ptran = 0
           and plabel = 0;
          return;
        endif;

        select;
          when ptran > 0;
            // get special pcs

            // The COALESCE function returns the first field that is not
            // null. If a LABELDO record is not found, its fields will
            // be null. Therefore, we are getting the value from LABELDO
            // if it exists, otherwise we use the LABEL value.

            exec sql
            SELECT SUM(FLOOR(COALESCE(LBOQTY,LBQPCK)/ESRRATIO)
                       + MOD(COALESCE(LBOQTY,LBQPCK),ESRRATIO)),
                   SUM(COALESCE(LBOQTY,LBQPCK))
            into :psplnetadj, :worknet
            from label
            inner join EPMSELRTO on LBITEM = ESRITEM AND ESRRATIO > 0
            left outer join LABELDO on LBOLBL#=LBLBL# and LBOTRN#=LBTRN#
                            and LBOACT='VPICK' and LBOPTYPE='SELECT'
            WHERE LBTRN# = :PTRAN AND LBTYPE <> 'A';

            if sqlstt <> sqlSuccess;
              pmessage = %char(sqlcode);
            else;
              psplnet = psplnet + worknet;
            endif;

            // get Excluded pcs

            // See above comment about COALESCE

            exec sql
            SELECT SUM(COALESCE(LBOQTY,LBQPCK)) into :worknet
            from label
            inner join EPMSELRTO on LBITEM = ESRITEM AND ESRRATIO = 0
            left outer join LABELDO on LBOLBL#=LBLBL# and LBOTRN#=LBTRN#
                            and LBOACT='VPICK' and LBOPTYPE='SELECT'
            WHERE LBTRN# = :PTRAN AND LBTYPE <> 'A';

            if sqlstt <> sqlSuccess;
              pmessage = %char(sqlcode);
            else;
              psplnet = psplnet + worknet;
            endif;

          when plabel > 0;
            // get special pcs

            // See above comment about COALESCE

            exec sql
            SELECT SUM(FLOOR(COALESCE(LBOQTY,LBQPCK)/ESRRATIO)
                       + MOD(COALESCE(LBOQTY,LBQPCK),ESRRATIO)),
                   SUM(COALESCE(LBOQTY,LBQPCK))
            into :psplnetadj, :worknet
            from label
            inner join EPMSELRTO on LBITEM = ESRITEM AND ESRRATIO > 0
            left outer join LABELDO on LBOLBL#=LBLBL# and LBOTRN#=LBTRN#
                            and LBOACT='VPICK' and LBOPTYPE='SELECT'
            WHERE LBLBL# = :PLABEL AND LBTYPE <> 'A';

            if sqlstt <> sqlSuccess;
              pmessage = %char(sqlcode);
            else;
              psplnet = psplnet + worknet;
            endif;

            // get Excluded pcs

            // See above comment about COALESCE

            exec sql
            SELECT SUM(COALESCE(LBOQTY,LBQPCK)) into :worknet
            from label
            inner join EPMSELRTO on LBITEM = ESRITEM AND ESRRATIO = 0
            left outer join LABELDO on LBOLBL#=LBLBL# and LBOTRN#=LBTRN#
                            and LBOACT='VPICK' and LBOPTYPE='SELECT'
            WHERE LBLBL# = :PLABEL AND LBTYPE <> 'A';

            if sqlstt <> sqlSuccess;
              pmessage = %char(sqlcode);
            else;
              psplnet = psplnet + worknet;
            endif;
        endsl;
        // need to calculate scan percentage
        // rules....
        // Items not setup for scanning will show 0 percent.
        // Items setup for scanning will show 100 percent unless
        // in voexcp there is an entry for BADUPC or SKPUPC in that
        // case the scan percent will be 0.
        // Depending on the clients task package, they may scan only
        // one upc or they may scan one for each unit being picked.
        // currently we have no system way of knowing which way the
        // clients task package works. So these rules are based on the
        // way Chef's task works, since they requested this change.
        select;
          when plabel > 0;
            exec sql select * into :lbrec
               from label
                where lblbl# = :plabel
                  and lbtype <> 'M'
                  and lbtype <> 'A'
                  and lbqpck > 0;
            if sqlstt = sqlSuccess;
              getItem();
              pScanPct = 0;
              plabelcnt= 0;
              ptotScan = 0;
              select;
                when %error or $drireturn <> '*OK';
                other;
                  // Item using upc scanning selection method 4 or 5.

730aA             if $ifsltmth = '2';
730aA               pScanPct = 100;
730aA             endif;
                  if $ifsltmth = '4'
                     or  $ifsltmth = '5' and lbutyp <> 'N'
740aA                or  $ifsltmth = '6' and lbutyp =  'N'
730aA                or $ifsltmth = '1' and oprfuc = 'Y';
                    exec sql select * into :sxrec
                       from voexcp
                        where sxwhse = :lbwhse
                         and sxlbl# = :plabel
                         and sxerid = 'BADUPC'
                         or  sxwhse = :lbwhse
                         and sxlbl# = :plabel
                         and sxerid = 'SKPUPC'
730aA                    or  sxwhse = :lbwhse
730aA                    and sxlbl# = :plabel
730aA                    and sxerid = 'NOUPC'
                        fetch first row only;
                    if sqlstt = sqlSuccess;
                    else;
                      pScanPct = 100;
                    endif;
JSLaA             else;
JSLaA               if client = jsilvert;
JSLaA                 pScanPct = 100;
JSLaA               endif;
                  endif;
              endsl;
            endif;
          when ptran > 0;

            lblcount = 0;
            pScanPct = 0;
            plabelcnt= 0;
            ptotscan = 0;
            // Get labels for this transaction

            SqlStmt = 'select * '
                    + 'from label '
                    + 'where lbwhse = ' + %char(pwhse) + ' '
                    + 'and lbtype<>' + sq + 'M' + sq + ' '
                    + 'and lbqpck<>' + sq + '0' + sq + ' '
                    +   'and lbtrn# = ' + %char(pTran) + ' ' ;

            exec sql prepare updrtnstmt from :SqlStmt;
            exec sql declare updrtncsr cursor for updrtnstmt;
            exec sql open updrtncsr;

            sqlstt = sqlSuccess;
            dou sqlstt = sqlNoMoreData;
              exec sql fetch next from updrtncsr
                       into :lbrec;

              if sqlstt <> sqlSuccess;
                error = *on;
              else;
                lblcount = lblcount + 1;
                getItem();
                select;
                  when %error or $drireturn <> '*OK';
                  other;
                    // Item using upc scanning selection method 4 or 5.

730aA               if $ifsltmth = '2';
730aA                 pScanPct = 100;
730aA               endif;
                    if $ifsltmth = '4'
740aA                  or  $ifsltmth = '6' and lbutyp = 'N'
750aA                  or $ifsltmth = '1' and oprfuc = 'Y'
                       or  $ifsltmth = '5' and lbutyp <> 'N';
                      exec sql select * into :sxrec
                         from voexcp
                          where sxwhse = :lbwhse
720aD                      //and sxlbl# = :plabel
720aM                      and sxlbl# = :lblbl#
                           and sxerid = 'BADUPC'
                           or  sxwhse = :lbwhse
720aD                      //and sxlbl# = :plabel
720aM                      and sxlbl# = :lblbl#
                           and sxerid = 'SKPUPC'
730aA                      or  sxwhse = :lbwhse
730aA                      and sxlbl# = :lblbl#
730aA                      and sxerid = 'NOUPC'
                          fetch first row only;
                      if sqlstt = sqlSuccess;
                      else;
                      workScanPct = workScanpct + 100;
                      eval sqlstt = sqlSuccess;
                      endif;

JSLaA               else;
JSLaA                 if client = jsilvert;
JSLaA                   workScanPct = workScanpct + 100;
JSLaA                 endif;

                  endif;
              endsl;
              endif;
            enddo;

            //pscanpct = pscanpct / lblcount;
            if lblcount <> 0;
              pscanpct = %dech(workscanpct / lblcount: 3: 0);
            else;
              pscanpct = 0;
            endif;
            plabelcnt = lblcount;
            ptotscan = workscanpct;
            exec sql close updrtncsr;
        endsl;
        if driItemCalled;
           driItem('%CLOSE': $pprogram: $drireturn: $drimessage:
                    $dridata: $dridata2);
        endif;
        return;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *Inzsr  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         // Convert fields to uppercase

         puser   = %xlate(xlower: xupper: puser);
         ppgm    = %xlate(xlower: xupper: ppgm);
         getclient(client: clientLoc);


         getUser(puser: e$whse: e$emp#: e$fnam: e$init: e$lnam:
                 e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                 e$bpu: e$lng);

730aA    chain (pWhse:'*GENPICK') options;
730aA    if not %found(options);
730aA      oprfuc = 'N';
730aA    endif;
      /end-free

      /free
       endsr;
      /end-free


     *----------------------------------------------------------------
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

      /free
       begsr getCurrStamp;

         getmicrotime(currstampuc:currstampsys);
         currstamploc = currstampsys + %hours(bfcoffset);

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  getItem  Get item info.
     *----------------------------------------------------------------

     p GetItem         b
     d GetItem         pi

      /free

         error = *off;

         savever# = $itver#;
         clear $item;
         clear $item2;
         $itver# = savever#;

         $itwhse = lbwhse;
         $ititem = lbitem;
         $dridata = $item;
         $dridata2 = $item2;

         driItemCalled = *on;
         driItem('%GETALL': $pprogram: $drireturn: $drimessage:
                  $dridata: $dridata2);
         $item = $dridata;
         $item2 = $dridata2;


      /end-free

     p GetItem         e

