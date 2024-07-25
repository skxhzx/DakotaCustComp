500eA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OI286S    Stage - Import FTP orders - Post
     *  02 March 2011
     *  Retha Davis
     *  Cloned from OI285
     *
     *----------------------------------------------------------------
     *WHEN MAKING CHANGES TO THIS PROGRAM ALSO APPLY CHANGES TO
     *  OI285S -- Non Route Manager Version
     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    CRTSQLRPGI OBJ(*) SRCFILE(*) TGTRLS(V5R3M0)
     *               COMMMIT(*NONE) DLYPRP(*YES)
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    01/21/09  MLB  5.20
     *      - Created.
520aA*    01/22/09  CWM  5.20a
     *      - Added Stop Cross Reference File Create.
     *
530 A*    11/20/09  MLB  5.30
     *      - Enh: Revised OI2551PR to add format DETAIL 22 which
     *        will print item pack/size on exception report.
530aA*    12/07/09  MLB  5.30a
     *      - Enh: Revised tmpcub, tmpwgt to reference rsordc, rsordw
     *        to prevent field overflow errors on cube, wgt.
530bA*    04/07/10  MLB  5.30b
     *      - Fix: Change to divide ITSWGT by brk qty to calculate wgt
     *        for type 'S' item.
530cA*    11/04/10  MLB  5.30c
     *      - Enh: Revised program to override to outq instead of device.
     *        From: OVRPRTF FILE(OI2861PR) OUTQ(*DEV) DEV(XXXXXXXXXX)
     *              FORMTYPE(XXXXXXXXXX)
     *        From: OVRPRTF FILE(OI286PR) OUTQ(*DEV) DEV(XXXXXXXXXX)
     *              FORMTYPE(XXXXXXXXXX)
530dA*    10/05/10  RBD  5.30d
     *      - Eliminated use of PODTL1 file as we no longer need to
     *        capture the po seq for the CROSSDK file.  Eventually
     *        the CROSSDK file will be eliminated altogether.
     *        This is possible because cross dock PO detail records
     *        will now be marked as 'XD' records in field PDSPCL.
     *      - Revised subr ZZXDCK to replace code which updates and
     *        writes slot records to instead use new subr ZZCRXD
     *        to call DRISLOT with %CRTXDOCK for all XD items and
     *        use %ALLOCATE to put the qty into the slot.
640aA*    03/02/11  RBD  6.40a
     *      - Created.
     *      - Use staging file impsordd in place of
     *        impfordd4 and impforddm.
     *      - Use staging file impsordh in place of
     *        impfordh4 and impfordhm.
640bA*    03/04/11  DAS  6.40b
     *      - Removed parameter $pimppo. This was used for Packers
     *        to pass back a po number to the CL program in order
     *        to create it. If that situation comes up in the future
     *        this program should call the program that will create
     *        the po.
     *
640cA*    03/06/11  DAS  6.40c
     *      - $PTYPE no longer used. Using OIHTYP instead.
     *        This means that multiple types can be mixed in a single
     *        batch.
     *      - Revised to treat Will Call and Single orders as
     *        individual routes.
     *      - Removed $PTRUK and $PRT* parameters.
     *      - Revised to call RH220 for Will Call orders.
     *
640dA*    04/07/11  JGD  6.40c
     *      - Add the capability of updating the order instead of
     *        creating a new order with a new order id when the
     *        same order is sent more than once.
     *
640eA*    05/03/11  RBD  6.40e
     *      - Fixed following 640d rev's:
     *        Moved 640d revs from zzgtod into fillod.
     *        When item changes, must calc qty picked using lbqpck
     *        in LABEL recs rather than qty picked in ORDD recs.
     *        Added update of qty's ordered when item changes.
     *        Rewrote zzzloopordd to retrieve qty picked from LABEL
     *        records and to update or delete ORDD and LABEL records.
     *      - Fix: Fixed zzgtod and fillod logic by taking item out of
     *        od1key.
     *      - Changed logic to create a new route id for each individual
     *        order, rather than creating a new route id for each host
     *        route.
     *      - If the imported order does not exist in ORDH, create
     *        a new transaction for the order with a new order id.
     *      - If the imported order exists and is already closed,
     *        throw an error.
     *      - When a rtehed rec is created, set it to printed status.
     *      - When an order detail record is created a LABEL record
     *        will be created as well.
     *      - When an order detail record is changed, the LABEL record
     *        will also be updated.
     *           a. If the items are different and qty has been
     *              picked, return an error.
     *      - After processing the staging records, loop through
     *        the ORDD file for the order and :
     *           a. Lookup up the detail in the staging file for the
     *              batch being processed.
     *           b. If a corresponding staging record is not found :
     *                 i. If nothing's been picked, delete ORDD and
     *                    its LABEL record/s.
     *                ii. If qty picked, set ordered qty to zero
     *                    in ORDD record and qty alloc to zero
     *                    in LABEL record.
     *      - When an order detail record is deleted, delete the
     *        associated LABEL record/s.
     *      - Added zzzdriclose subr to close files opened in DRI
     *        programs.
     *
640fA*    06/23/11  DAS  6.40f
     *      - Revised to create missing label record.
     *      - Revised zzchkrtsos routine to set @ptrn# if tran found.
     *
I40gA*    06/27/11  RBD  6.40g
     *      - Revised to load lbwhdp and lbdisp with the first pick
     *        slot for the item, or if no pick slots are found, the
     *        first overflow slot.
640hA*    07/01/11  MLB  6.40h
     *      - Fix: Revised program to skip records that are locked
     *        during customer order import processing.
640iA*    07/05/11  DAS  6.40i
     *      - Fix: Made some revisions to 640h.
640jA*    07/05/11  DAS  6.40j
     *      - Fix: Revised zzzLblDel to use rhrtid instead of oihrteid
     *        because oihrteid isn't initialized until the end.
640kA*    07/18/11  MLB  6.40k
     *      - Fix: Revised varianble SUBLIN to be 7,0 from 3,0. Orders
     *        greater than 999 lines causes RNQ0103 Variable too small
     *        to hold result error.
640lA*    07/28/11  RBD  6.40l
     *      - Fix: Recompiled, ORDH10 file changed to include OHORD.
     *        This will fix problem with wrong orders getting deleted.
640mA*    07/29/11  MLB  6.40m
     *      - Fix: Revised ZZGETSLOT to load LBWHDP with ITWHDP when
     *        no pick slot and not overflow slot is found for the item.
640nA*    08/02/11  RBD  6.40n
     *      - Fix: Revised program to use RTEHED2 when checking for
     *        Open routes. If a route was deleted, then re-imported
     *        the program was not finding the Open RTEHED rcd.
     *      - Fix: Revised program to correct duplicate key error
     *        when writing out ORDHM rcd for existing order.
     *      - Fix: Revised program to correct duplicate key error
     *        when writing out ORDDM rcd for existing order.
640oA*    08/02/11  RBD  6.40o
     *      - Fix: Revised program to move clearing of fields NEWRTE
     *        and NEWRTC. Fields were being cleared before they could
     *        be used by routine ZZCKR1.  This was causing a route header
     *        to be left behind with zero orders attached.
640pA*    08/05/11  RBD  6.40p
     *      - Fix: added code to ensure that logic for SOS orders is
     *        not also executed for normal orders.  For example, set
     *        route header status to '4' for SOS orders, set it to '1'
     *        for normal orders.
     *      - Fix: When SOS order and item changes, added calculation
     *        of qty's used to update RTESUM.
640qA*    09/27/11  MLB  6.40q
     *      - Fix: Revised ZZCKOR to remove test for OIHMEM = OHMEMO
     *        when determining whether order can be merged. Code was
     *        included in error. Was for H&S/Retalix only clients.
640rA*    11/28/11  MLB/RH  6.40r
     *      - Fix: Revised pgm to make SLOT3 input full procedural
     *        instead of update/full procedural. There were no updates
     *        being done to SLOT3.
     *      - Fix: Revised pgm to chain to PIRITEM to retrieve item
     *        description before skipping detail processing.
640sA*    06/14/12  MLB/RH  6.40s
     *      - Fix: Revised routines: ZZZLblPck, ZZZLblUpdZero to use
     *        RHRTID instead of OIHRTID which is not updated until the
     *        end of order processing. Same mods as Dave's 6.40j.
640tA*    09/20/12  MLB  6.40t
     *      - Enh: Revised program to add 2 new fields to file IMPSORDD.
     *        Added fields OIDSLT, OIDBLK to file for Outbound Only
     *        clients. Program will process these new fields only if
     *        field OPFEAT = '3'.
     *      - Added file ORDDS to program.
640uA*    11/30/12  RBD  6.40u
     *      - Fix: Added code in zzzLblUpdQ_1 routine to run zzgetslot
     *        to update lbwhdp and lbdisp if item changes.
640vA*    01/02/13  RBD  6.40v
     *      - Fix: Update lbqalc in all labels matching the item and
     *        sequence, not just the first match.
     *
650a *    02/13/13  GJA  6.50a
     *      - Fix: Revised to not allow selection of slot with
     *        designation code of BFC in zzgetslot.
650b *    05/23/13  RTR  6.50b
     *      - Enh: Created OI286S from OI285S, so that RMS staging will
     *        be separate.
     *      - Enh: Adding order number from staging file to RMS files
650cA*    07/28/14  MLB  6.50c
     *      - Fix: Revised program to prevent string error when OHWHS
     *        is zero.
     *
710a *    04/06/17  RTR  7.10a
     *      - Enh: Changed to use 5 digit stop number in RMS.
     *
720a *    03/07/18  RTR  7.20a
     *      - Enh: ?????
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Brothers, Inc.
     *
CBIaA*    01/16/06  DAS  CBIa
     *      - Revised to create a fictitious department PRD in RTESUM
     *        using a specific range of item numbers (405000 - 492999)
     *      - Revised to not call UPDRTE.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Packer's Provision
     *
PAK A*    06/23/06  MLB  PAK
     *      - Add file CUSTMISC to program.
     *        If customer found in file, load *SP into OHMISC.
     *      - If route number is blank, set OHTYPE=W for Will-Call.
PAKaA*    06/24/06  MLB  PAKa
     *      - Revised program to pass parm back to calling program,
     *        PI260CL that will call SPI260CL to perform p/o import
     *        when delivery type is 'ZPLF'.
PAKbA*    09/08/06  MLB  PAKb
     *      - Revised program to move data sent in OIMDSC field into
     *        Order Detail Misc 1 field in ORDDM file.
PAKcA*    09/18/06  MLB  PAKc
     *      - Change to mod PAKa. P/O import will only be done for
     *        orders coming from warehouses: 200, 300 or 310.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Halsey Foodservice
     *
HAL A*    01/04/09  MLB  HAL
     *      - Revised pgm to send new cmd, *DFTNOAU - Assign default
     *        truck, no auto assign truck template.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: BiRite Foodservice
     *
BIR A*    11/17/10  MLB  BIR
     *      - Revised pgm to send new cmd, *DFTNOAU - Assign default
     *        truck, no auto assign truck template.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt Produce
     *
CSP A*    10/05/10  RBD  CSP
     *      - Delete JIT slots whose status is 'Z'.
     *      - If imported item has a designation code of JIT, force
     *        oidspc and odspcl to be 'XD' so that it will be
     *        processed through the system as a cross dock item.
     *        Force aisle to be 'JIT'.
CSPaA*    03/11/11  MLB  CSPa
     *      - Revised program to scan import customer name field for
     *        a list of special characters and set them to blank if
     *        found. Per email from Stalio, Hemant dated 03/11/11.
     *      - Special char's were causing terminal errors in GUI
     *        Drag/Drop module.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Eastland
     *
EFC A*    08/11/11  RBD  EFC
     *      - For existing order, use route in ORDH to chain back
     *        to RTEHED, and if rhrte is different from route in the
     *        import file, update the route in RTEHED.
     *
EFCaA*    08/22/11  RBD  EFCa
     *      - If new delete flag is on and no qty has been picked,
     *        unpick and delete the route (using logic from RH140A
     *        and RH420A).  If flag is on and qty has been picked,
     *        write error to import file and report.
     *
EFCbA*    11/14/11  RH   EFCb
     *      - Fix: unlock RTEHED file, was locked before calling
     *        RH134 to delete route causing error
     *      - Revised routine ZZCKRTSOS to clear ORDH10 fields when
     *        the order isn't found on the system.
     *
EFCcA*    04/09/12  RBD  EFCc
     *      - Enh: added logic to process type 'R' routes into Route
     *        Manager files.
     *
EFCd *    02/05/13  GJA  EFCd
     *      - Enh: check in RMSROUTE to see if route should be sent
     *        to Route Manager.
     *      - Enh: if route is "S" change to "W" for willcall and do not process RH220
EFCe *    05/14/13  RTR  EFCe
     *      - Fix: Remove OIHDIV/OIDDIV division, not used at this time
EFCf *    05/21/13  RTR  EFCf
     *      - Enh: Allow zero qty detail records for Eastland.
EFCg *    12/07/13  RTR  EFCg
     *      - Fix: check route, if first char numeric set route type 'R'.
EFCh *    01/18/14  RTR  EFCh
     *      - Fix: Changed to ignore order type in ORDH for merge check.
     *        This handles if customer changes route from regular to or
     *        from SOS.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Indianhead Foods
     *
IFDa *    04/06/17  RTR  IFDa
     *      - Enh: Added Indianhead to some Eastland mods.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    This program assumes that there is only one route for one
     *    warehouse OR only one order in the member.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  61        - Special order (Customer # > 0)
     *  78        - EOF for IMPFORDD
     *  79        - EOF for IMPFORDH
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     * File Specs
     *
640aMFimpsordh  uf   e           k disk
640aDF*impfordhm uf   e           k disk    usropn
640aMFimpsordd  uf   e           k disk
640aDF*impforddm uf   e           k disk    usropn
EFCcAFrmsfordh  uf a e           k disk    usropn
710aAF                                     prefix(r)
EFCcAF                                     rename(oihrec:rihrec)
EFCcAFrmsfordd  uf a e           k disk    usropn
EFCcAF                                     rename(oidrec:ridrec)
EFCcAFrmsfordhm uf a e           k disk    usropn
EFCcAF                                     rename(ohmrec:rhmrec)
EFCcAFrmsforddm uf a e           k disk    usropn
EFCcAF                                     rename(oimrec:rimrec)
     Fwarehs    if   e           k disk
     Fpiritem   if   e           k disk
530dDF*slot1     uf a e           k disk
530dDF*slot4     uf   e           k disk
530dDF*                                    rename(slrec:slrec4)
     Fslot11    uf   e           k disk
     F                                     rename(slrec:slrec11)
640rDF*slot3     uf   e           k disk
640rMFslot3     if   e           k disk
640gAF                                     rename(slrec:slrec3)
     Frtesum    uf a e           k disk
     Fordh4     if   e           k disk
     F                                     rename(ohrec:ohrec4)
640eAFordh10    if   e           k disk
     Fordd1     uf   e           k disk
     F                                     rename(odrec:odrec1)
     Foptions   if   e           k disk
530dDF*podtl1    if   e           k disk
640eAFlabel     uf a e           k disk
640eAFlabel93   uf   e           k disk    rename(lbrec:lbrec93)
640eAFpirtran4  if   e           k disk
     Frtehed1   uf   e           k disk
     F                                     rename(rhrec:rhrec1)
640nAFrtehed2   if   e           k disk
640nAF                                     rename(rhrec:rhrec2)
EFC DF*rtehed    o  a e           k disk
EFC MFrtehed    uf a e           k disk
     Fordh      uf a e           k disk
     Fordhm     uf a e           k disk
     Fcrossdk   uf a e           k disk
     Fordd      o  a e           k disk
     Forddm     uf a e           k disk
640tAFordds     uf a e           k disk
520aAFrtestp    o  a e           k disk
EFCdAFrmsroute  if   e           k disk
     Foi286pr   o    e             printer oflind(*in91)
     F                                     usropn
     Foi2861pr  o    e             printer oflind(*in92)
     F                                     usropn

     *----------------------------------------------------------------
530dA*  DRI parameters
     *----------------------------------------------------------------
530dA /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
530dA*  Data Formats
     *----------------------------------------------------------------

530dA /COPY *libl/qcopysrc,C#ITEM
530dA /COPY *libl/qcopysrc,C#LICENSE
530dA /COPY *libl/qcopysrc,C#LICHIST
530dA /COPY *libl/qcopysrc,C#LICINFO
530dA /COPY *libl/qcopysrc,C#SLOT
530dA /COPY *libl/qcopysrc,C#XDOCK

     *----------------------------------------------------------------
     *  Table and array definitions
     *
640dDD*desc            s             20    dim(6) ctdata perrcd(1)
640eDD*desc            s             20    dim(7) ctdata perrcd(1)
EFCaDD*desc            s             20    dim(8) ctdata perrcd(1)
EFCaMD desc            s             20    dim(9) ctdata perrcd(1)
     D rdsc            s             50    dim(1) ctdata perrcd(1)
     D a80             s              1    dim(80)
     D ovrprt          s             80    dim(2) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
      /COPY QCOPYSRC,ID#CHENEY
      /COPY QCOPYSRC,ID#CHENEYO
      /COPY QCOPYSRC,ID#CHENEYR
      /COPY QCOPYSRC,ID#PACKERS
HAL   /copy qcopysrc,id#Halsey
BIR   /copy qcopysrc,id#BiRite
CSP A /COPY QCOPYSRC,Id#Coastal
EFC A /copy qcopysrc,id#eastlan
IFDaA /copy qcopysrc,id#ifd
     *
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
     *
     * Data structure
     *
     D opdata          ds
     D  operpt                 1      1
     D  opelbl                 2      2
     D  oprfwc                 3      3
     D  opnrsc                 4      4  0
     D  ophpwc                 5      5
     D  opmrga                 6      6
     D  opplsq                 7      7
     D  optend               117    117
640tA*----------------------------------------------------------------
640tA*  *FEATURE  -  PIR Feature options.
640tA*----------------------------------------------------------------
640tA*
640tA* Fields
640tA*
640tA*    OPFEAT  -  PIR Installed feature.
640tA*
640tA* Data structure
640tA*
640tAD opdataF         ds
640tAD  opfeat                 1      1
640tAD  optendF              117    117
     *----------------------------------------------------------------
     *  Re-definition field(s)
     *
     D                 ds
     D  oihmec                13     15
EFCaAD  oihdel                11     11
     D  oihmsc                 1     20
     D                 ds
     D  ohmemc                13     15
     D  ohmisc                 1     20
     *----------------------------------------------------------------
     *  Constants
     *
     D exchdr          c                   const('- Exceptions')
     D sts01           c                   const('** Added to existing-
     D                                      Open Order. ')
     D sts02           c                   const('** New Order Added t-
     D                                     o Open Route.')
     D sts03           c                   const('** Upd''d on existin-
     D                                     g Open Order.')
CSPaAD spclchar        c                   const('`~!@$%^&*()=+-[{]}\|-
CSPaAD                                     <>/?')
CSPaA* *IMPORTANT* If any special chars are added to string SPCLCHAR,
CSPaA*             NbrSpclChar must be updated for number added.
CSPaAD NbrSpclChar     s              3  0 inz(24)
     *
     *----------------------------------------------------------------
     *  Working variables
     *
640aDD*$pwhse          s              3  0
640eAD chk4err         s               n
530dAD ck4err          s               n
640fAD lblFound        s               n
     D count           s              3  0
640eAD crtNewTran      s              1
640eAD curdate         s              8  0
640eAD curtime         s              6  0
     D difqy1          s                   like(odqor1)
     D difqy2          s                   like(odqor2)
     D difqy3          s                   like(odqor3)
     D dummy           s              3  0
     D eofd            s              1
     D eofh            s              1
530dAD error           s               n
     D excprt          s              1
     D excpr1          s              1
640aAD filnam          s             10
     D forevr          s              1
     D good1           s              1
     D good2           s              1
640eAD hlditm          s             15
640eAD hldqor          s              5  0
     D impdte          s              8  0
640aAD importError     s               n
     D imptim          s              6  0
     D import_po       s              4    inz('*NO ')
640gAD keypick         s                   like(slpick)
640gAD keystat         s                   like(slstat)
     D kyaisl          s                   like(slaisl)
     D kydisp          s                   like(sldisp)
640eAD kygrp2          s                   like(ptgrp2)
640nAD kyrhstat        s                   like(rhstat)
640nAD                                     inz('1')
     D kyrtid          s                   like(rhrtid)
640eAD kyrtpo          s                   like(ptrtpo)
     D kystat          s                   like(odstat)
     D kywhdp          s                   like(itwhdp)
640eAD lasttime        s              6  0
     D len             s              1  0
     D linppg          s              3  0
     D lstrid          s                   like(oihrte)
     D lstrte          s                   like(oihrte)
640cAD lstType         s                   like(oihtyp)
     D lstwhs          s              3  0
     D mischdrupd      s              4    inz('*NO ')
     D miscupdate      s              4    inz('*NO ')
     D mrgitm          s              1
     D mrgord          s              1
     D mrgrte          s              1
     D neword          s                   like(ohord)
     D newrtc          s                   like(rhrte)
     D newrte          s                   like(rhrtid)
     D opened          s              1
     D opnorc          s                   like(ohord)
     D opnord          s                   like(ohord)
     D opnrtc          s                   like(rhrte)
     D opnrte          s                   like(rhrtid)
640eAD pick1           s              7  0
640eAD pick2           s              7  0
640eAD pick3           s              7  0
     D pflag           s              1
     D pos             s              1  0
     D prhdr1          s              1
640eAD qty1flag        s               n
640eAD qty2flag        s               n
640eAD qty3flag        s               n
     D rcdlck          s              1
     D rtcnt           s              3  0
530dAD savever#        s                   like($lnver#)
     D skpwrt          s              1
640nAD skpwrthdr       s              1    inz('0')
640nAD skpwrthdrm      s              1    inz('0')
640nAD skpwrtdtlm      s              1    inz('0')
CSPaAD s               s              3  0 inz(0)
CSPaAD start           s              3  0 inz(0)
640aAD stamp           s               z
640aAD stampUC         s               z
640kDD*sublin          s              3  0
640kMD sublin          s              7  0
     D subq1           s              7  0
     D subq2           s              7  0
     D subq3           s              7  0
530aDD*tmpcub          s                   like(itcube)
530aMD tmpcub          s                   like(rsordc)
     D tmploc          s              3  0
530aDD*tmpwgt          s                   like(itswgt)
530aMD tmpwgt          s                   like(rsordw)
     D today           s              8  0
EFCaAD totpck          s              7  0
EFCaAD trnflg          s              1
     D work3a          s              3
     D wrgsts          s              1

640aA*----------------------------------------------------------------
640aA*  Parameters
640aA*----------------------------------------------------------------
640aA
640aAD $pWhse          s              3p 0
640aAD $pWhse3A        s              3
640aAD $pBatId         s             11
640aAD $pReturn        s             10
640aAD $pMessage       s            200
640aA
640aA*----------------------------------------------------------------
640aA*  Standard SQL variables and constants
640aA*----------------------------------------------------------------
640aA
640aA /copy qcopysrc,c#stdsql

640aA*----------------------------------------------------------------
640aA*  File data data structure
640aA*----------------------------------------------------------------
640aA
640aAD sbrec         E ds                  extname(stgbatch) inz(*EXTDFT)

EFCaA*----------------------------------------------------------------
EFCaA*  Called program parameters
EFCaA*
EFCaAD $parms          ds
EFCaAD  $pcmd                  1      8
EFCaAD  $pprg                  9     18
EFCaAD  $puky                 19     68
EFCaAD  $prtn                 69     76
EFCaAD  $perm                 77    136
EFCaAD  $pmsg                 77     80
EFCaA*
EFCaAD  $pwhs                 19     21  0 inz(0)
EFCaAD  $prte                 22     26
EFCaAD  $prtid                27     31
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
EFCaAD @unpckpg        c                   const('RH134')
EFCaAD @delpg          c                   const('RH124')
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
530dA*  Program info data structure
     *
640aA /copy qcopysrc,c#pgminfds
     *
640aDD*               sds
640aDD* #prog            *proc
640aDD* #job                 244    253
640aDD* #user                254    263
640aDD* #jobn                264    269
640aDD* #jobdt               276    281  0
640aDD* #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
640aA*      $pWhse  - Warehouse
640aA*      $pBatId - Batch id
     *
     *    Returned Parameters
640aM*      $pWhse  - Warehouse
640aA*      $pReturn  - Return code
640aA*      $pMessage - Return message
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
640aMc                   parm                    $pWhse3A
640aAc                   parm                    $pBatId
640cDC**                 parm                    $ptype            1
640cDC**                 parm                    $ptruk           10
640cDC**                 parm                    $prt01            5
640cDC**                 parm                    $prt02            5
640cDC**                 parm                    $prt03            5
640cDC**                 parm                    $prt04            5
640cDC**                 parm                    $prt05            5
640cDC**                 parm                    $prt06            5
640cDC**                 parm                    $prt07            5
640cDC**                 parm                    $prt08            5
640cDC**                 parm                    $prt09            5
640cDC**                 parm                    $prt10            5
640bDC**                 parm                    $pimppo           4
640aAc                   parm                    $pReturn
640aAc                   parm                    $pMessage
640aA
640aAc                   eval      $pWhse = %dec($pWhse3A: 3: 0)
640aAc                   eval      $pReturn = '*OK'
640aAc                   eval      $pMessage = ' '
640eDC**                 eval      *inlr = *on

     *----------------------------------------------------------------
     * Main line
     *
640aA* Update stgbatch record to start process
640aA*
640aAC                   exsr      zzzStart
640aAC                   if        $pReturn <> '*OK'
640aAC                   return
640aAC                   endif
     *
     *----------------------------------------------------------------
     * Key definitions
     *
     * Download order detail file - Partial key
     *
     C     oidkey        klist
     C                   kfld                    oihwhs
     C                   kfld                    oihord
640tA*
640tA* ORDDS  Order detail pick slot file - Full key
640tA*
640tAC     oskey         klist
640tAC                   kfld                    odwhse
640tAC                   kfld                    odord
640tAC                   kfld                    odseq
640tAC                   kfld                    oditem
     *
     * Item file
     *
     C     itkey         klist
     C                   kfld                    oidwhs
     C                   kfld                    oiditm
     *
     * Route summary file
     *
     C     keyrs         klist
     C                   kfld                    rhwhse
     C                   kfld                    kyrtid
     C                   kfld                    kywhdp
     *
     *----------------------------------------------------------------
     *
     * Initialize route id's
     *
640cDC**                 eval      $prt01 = *blanks
640cDC**                 eval      $prt02 = *blanks
640cDC**                 eval      $prt03 = *blanks
640cDC**                 eval      $prt04 = *blanks
640cDC**                 eval      $prt05 = *blanks
640cDC**                 eval      $prt06 = *blanks
640cDC**                 eval      $prt07 = *blanks
640cDC**                 eval      $prt08 = *blanks
640cDC**                 eval      $prt09 = *blanks
640cDC**                 eval      $prt10 = *blanks
640cDC**                 eval      rtcnt = 0
     *
     * Get import date/time.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      impdte = $cvd8o
     C                   time                    imptim
     *
     * Get report heading.
     *
     C                   eval      w1head = *blanks
     C                   movel     rdsc(1)       $pstr
     C                   eval      $plen = 50
     *
     C                   call      'CENTER'
     C                   parm                    $pstr            60
     C                   parm                    $plen             3 0
     C                   movel     $pstr         w1head
     *
     *    Create heading for exceptions report.
     *
     C                   eval      $pstr = %trimr(rdsc(1)) + ' ' + exchdr
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         w1hdr1
     C                   eval      *in92 = *on
     C                   eval      prhdr1 = *off
     C                   eval      excprt = *off
     C                   eval      excpr1 = *off
     *
     * Initialize grand total fields
     *
     C                   eval      grdord = 0
     C                   eval      grdlin = 0
     C                   eval      grord1 = *zeros
     C                   eval      grlin1 = *zeros
     C                   eval      preoh = 0
     C                   eval      preod = 0
     C                   eval      noitem = 0
     C                   eval      badbrk = 0
     *
     * Whip through all the download header records
     *
     C                   eval      lstrte = '@@@@@'
640cAC                   eval      lstType = '@'
     C                   eval      lstrid = '@@@@@'
     *
     C                   eval      pflag = *off
     C                   eval      eofh = *off
     C                   eval      linppg = 55
     C                   eval      count = 0
     C                   eval      lstwhs = -(1)
     *
640aAC     keysoh        setll     impsordh
     C                   dou       eofh = *on
     C                   if        client <> cheney
     C                   exsr      updrte
     C                   endif
     *
640aAC                   eval      error = *off
     *
640aDC**                 read      impfordh4                              79
640aMC     keysoh        reade     impsordh                               79
     C                   if        *in79
     C                   eval      eofh = *on
520aA*
520aA*  When route changes, resquence stops in RTESTP file.
520aAC                   if        lstrte <> '@@@@@'
520aAC                   exsr      reseqstp
520aAC                   endif
520aA*
640nA*  Merge order(s) into Open routes allowed.
640nA*  Check if any orders attached to new open route. If no, delete.
640nA*
640nAC                   if        opmrga = 'Y'  and
640nAC                             oihtyp = ' '
EFCcAC                             or (opmrga = 'Y' and
EFCcAC                                 oihtyp = 'R')
640nAC                   exsr      zzckr1
640nAC                   endif
640nA*
     C                   goto      enddoh
     C                   endif
640aA*
640aA*  Skip processed records.
640aA*
640aAC                   if        oihstatus <> 'R'
640aAC                   iter
640aAC                   endif
CSPdA*
CSPaA*
CSPaAC                   if        client = CoastalSunbelt
CSPaAC                   exsr      stripspcl
CSPaAC                   endif
CSPaA*
EFCgA*  If eastland and route is numeric, make it regular route
EFCgAC                   if        client = eastland
EFCgAC                   if        %subst(oihrte:1:1) = '0'
EFCgAC                             or %subst(oihrte:1:1) = '1'
EFCgAC                             or %subst(oihrte:1:1) = '2'
EFCgAC                             or %subst(oihrte:1:1) = '3'
EFCgAC                             or %subst(oihrte:1:1) = '4'
EFCgAC                             or %subst(oihrte:1:1) = '5'
EFCgAC                             or %subst(oihrte:1:1) = '6'
EFCgAC                             or %subst(oihrte:1:1) = '7'
EFCgAC                             or %subst(oihrte:1:1) = '8'
EFCgAC                             or %subst(oihrte:1:1) = '9'
EFCgAC                   eval      oihtyp = 'R'
EFCgAC                   endif
EFCgAC                   endif
EFCdA*
EFCdA*  Decide if Eastland routes should be imported to RMS
EFCdAC                   if        client = Eastland
EFCdAC                   select
EFCdAC                   when      oihtyp = 'R'
EFCdAC                             or oihtyp = ' '
EFCdAC                   eval      rmswhs = oihwhs
EFCdAC                   eval      rmsrte = oihrte
EFCdAC     keyrms        chain     rmsroute
EFCdAC                   select
EFCdAC                   when      %found(rmsroute) and rteimp = 'N'
EFCdAC                   eval      oihtyp = 'S'
EFCdAC                   when      %found(rmsroute) and rteimp = 'Y'
EFCDaC                   eval      oihtyp = 'R'
EFCdAC                   other
EFCDaC                   eval      oihtyp = 'S'
EFCdAC                   endsl
EFCdAC                   endsl
EFCdAC                   endif
     *
     *  Create warehouse heading if necessary.
     *
     C                   if        lstwhs <> oihwhs
     *
     C                   eval      whcode = oihwhs
     C                   eval      $pwhse = oihwhs
     C     whcode        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     * Delete all status 'Z' XDK slots.
     *
     C                   exsr      zzzdelxdk
     *
CSP A* Delete all status 'Z' JIT slots.
CSP A*
CSP AC                   if        client = CoastalSunbelt
CSP AC                   exsr      zzzdeljit
CSP AC                   endif
     *
     *    Retrieve General Pick options for warehouse.
     *    This applies to only Regular orders.
     *
     C                   select
640cDC**                 when      $ptype = ' '
640cMC                   when      oihtyp = ' '
EFCcAC                             or oihtyp = 'R'
     C                   eval      opwhse = oihwhs
     C                   eval      opcode = '*GENPICK'
     C     opkey         chain     options                            7978
     C                   if        *in79
     C                   eval      opmrga = 'N'
     C                   endif
     *
     *    Force Allow Merge orders to Yes for 'S' orders.
     *
640cDC**                 when      $ptype = 'S'
640cMC                   when      oihtyp = 'S'
     C                   eval      opmrga = 'Y'
     *
     *    All other order types, force Allow Merge orders to No
     *
     C                   other
     C                   eval      opmrga = 'N'
     C                   endsl
     *
640tA*
640tAC                   eval      opcode = '*FEATURE'
640tAC     opkey         chain     options
640tAC                   if        not %found(options)
640tAC                   eval      opfeat = '2'
640tAC                   else
640tAC                   eval      opdataf = opdata
640tAC                   endif
640aMC                   eval      $pwhse = whcode
     C                   move      oihwhs        work3a
     C     ' 0'          check     work3a        pos
650cAC                   if        pos = 0
650cAC                   eval      pos = 1
650cAC                   endif
     C                   eval      len = 4 - pos
     C     len           subst     work3a:pos    whhead
     C     whhead        cat       '-':1         whhead
     C     whhead        cat       whdesc:1      whhead
     C                   call      'CENTER'
     C                   parm      whhead        $cstr            60
     C                   parm      40            $clen             3 0
     C                   movel     $cstr         whhead
     *
     C                   eval      lstwhs = oihwhs
     C                   eval      pflag = *off
     *    Get exceptions report override if any.
     C                   exsr      opnprt
     C                   endif
     *
     *    Print report heading if necessary.
     *
     C                   eval      prhdr1 = *off
     C                   if        pflag = *off  or
     C                             count >= linppg
     C                   eval      count = 0
     C                   write     head1
     C                   add       3             count
     C                   eval      pflag = *off
     C                   endif
     *
     *  Add record to route header file when route changes.
     *     or when processing 'S' orders.
     *
     C                   if        oihrte <> lstrte
640cAC                             or oihtyp = 'W'
640cAC                             or oihtyp = 'S'
640cAC                   if        lstType = 'W'
640cAC                   exsr      processWC
640cAC                   endif
     *
     C                   eval      mrgrte = *off
640oDC**                 eval      newrte = *blanks
640oDC**                 eval      newrtc = *blanks
     C                   eval      hedmsg = *blanks
     *
640eA*  For SOS orders :
640eA*    Use the imported customer order number to find out if the
640eA*    order is still open.
640eA*      a. if the order exists and the route id is open, the order will
640eA*         be merged into it.
640eA*      b. if the order exists and the route id is closed, an error
640eA*         will be returned.
640eA*      c. if the order does not exist, the order will be created with
640eA*         a new route id and a new order id.
640eA*
640eAC                   if        oihtyp = 'S'
640eAC                   exsr      zzckrtSOS
640eAC                   if        hedmsg = desc(8)
640eAC                   goto      skipProcessH
640eAC                   endif
640eAC                   endif
     *
EFCaA*  If SOS order and specific client, check incoming delete flag.
EFCaA*  If flag is on and no qty has been picked, unpick and delete
EFCaA*  the route (using logic from RH140A and RH420A).  If flag is
EFCaA*  on and qty has been picked, write error to import file and
EFCaA*  report.
EFCaA*
EFCaAC                   select
EFCaA*
EFCaAC                   when      oihtyp = 'S' and oihdel = *on
EFCaAC                             and client = eastland
EFCaAC                   exsr      zzzTotPck
EFCaAC                   if        totpck <> 0
EFCaAC                   eval      hedmsg = desc(9)
EFCaAC                   add       1             preoh
EFCaAC                   else
EFCbAC                   unlock    rtehed1
EFCaAC                   exsr      zzzUnpckDel
EFCaAC                   endif
EFCaAC                   goto      skipProcessH
EFCaA*
EFCaAC                   other
EFCaAC                   endsl
     *
640eA*  For non SOS orders :
     *    Merge order(s) into Open routes allowed.
     *    Check if Route still at Open status.
     *
     C                   if        opmrga = 'Y'  and
640cMC                             oihtyp = ' '
EFCcAC                             or (opmrga = 'Y' and
EFCcAC                                 oihtyp = 'R')
640cDC**                           $ptype = ' '
     C                   exsr      zzckr1
     C                   exsr      zzckrt
     C                   endif
520aA*
520aA*  When route changes, resquence stops in RTESTP file.
520aAC                   if        lstrte <> '@@@@@'
520aAC                   exsr      reseqstp
520aAC                   endif
     *
640oAC                   eval      newrte = *blanks
640oAC                   eval      newrtc = *blanks
640eAC                   if        mrgrte = *off
720aAC                             and oihtyp <> 'R'
     C                   exsr      fillrh
     C                   write     rhrec                                49
640eAC                   else
640eAC                   eval      lstrid = rhrtid
640eAC                   endif
     C                   eval      lstrte = oihrte
640cAC                   eval      lstType = oihtyp
     C                   endif
640eA*
640eA*    Create transaction if new order id.
640eA*
640eAC                   if        crtNewTran = *on
640eAC                   exsr      zzzCrtTran
640eAC                   endif
640eA*
     *    Add record to order header file. If an error occurs, assume
     *    it was caused by a duplicate record.
     *
     *    Route allows Add-on orders to be merged with existing Open orders.
     *    Check if order header still at Open status.
     *
     C                   eval      mrgord = *off
     C                   eval      opnord = *zeros
     C                   eval      wrgsts = *off
     C                   eval      opnorc = *zeros
     C                   if        mrgrte = *on
     C                   exsr      zzcko1
     C                   exsr      zzckor
     C                   endif
     *
EFCcA*    For SOS orders and specific client:
EFCcM*    If the order already exists, check to see if route
EFCcM*    changed, if so, update route header.
EFC AC                   if        mrgord = *on
EFC AC                             and client = eastland
EFCcAC                             and oihtyp = 'S'
EFC AC                   unlock    rtehed1
EFC AC     rhkey         chain     rtehed
EFC AC                   if        %found and rhrte <> oihrte
EFC AC                   eval      rhrte = oihrte
EFC AC                   eval      rhstsd = impdte
EFC AC                   eval      rhstst = imptim
EFC AC                   eval      rhimpd = impdte
EFC AC                   eval      rhimpt = imptim
EFC AC                   eval      rhrptd = impdte
EFC AC                   update    rhrec
EFChAC                   else
EFChAC                   if        %found and rhtype <> oihtyp
EFChAC                   eval      rhtype = oihtyp
EFChAC                   eval      rhstat = '4'
EFChAC                   eval      rhstsd = impdte
EFChAC                   eval      rhstst = imptim
EFChAC                   eval      rhimpd = impdte
EFChAC                   eval      rhimpt = imptim
EFChAC                   eval      rhrptd = impdte
EFChAC                   update    rhrec
EFChAC                   endif
EFC AC                   endif
EFC AC                   unlock    rtehed
EFC AC                   endif
     *
640nDC**                 if        mrgord = *off
     C                   exsr      filloh
640nDC**                 endif
     *
640aM*    Only update ORDHM fields if misc order hdr data was sent
640aA*    in IMPSORDH.
640aAC                   exsr      zzMiscH
     C                   if        mischdrupd = '*YES'
     C                   exsr      fillhm
     C                   endif
     *
640nDC**                 if        mrgord = *off
640nMC                   if        skpwrthdr = '0'
EFCcAC                   select
EFCcAC                   when      oihtyp = 'R'
710aAC                   eval      roihwhs = oihwhs
710aAC                   eval      roihord = oihord
710aAC                   eval      roihtyp = oihtyp
710aAC                   eval      roihcus = oihcus
710aAC                   eval      roihcpo = oihcpo
710aAC                   eval      roihcnm = oihcnm
710aAC                   eval      roihca1 = oihca1
710aAC                   eval      roihca2 = oihca2
710aAC                   eval      roihcct = oihcct
710aAC                   eval      roihcst = oihcst
710aAC                   eval      roihczp = oihczp
710aAC                   eval      roihrte = oihrte
710aAC                   eval      roihstp = oihest
710aAC                   eval      roihtrk = oihtrk
710aAC                   eval      roihmsc = oihmsc
EFCcAC                   write     rihrec                               49
EFCcAC                   other
     C                   write     ohrec                                49
EFCcAC                   endsl
640nAC                   endif
520aA*
520aA*    Fill Route Extended Stop file
520aAC                   exsr      fillxr
520aAC                   write (e) rtsrec
520aAC                   if        %error
520aAC                   endif
520aA*
     *
640aM*    Only add to ORDHM if misc order hdr data was sent
640aA*    in IMPSORDH.
     C                   if        mischdrupd = '*YES'
640nA*
640nAC                   if        skpwrthdrm = '0'
640nDC*                  write     hmrec
EFCcAC                   select
EFCcAC                   when      oihtyp = 'R' and mrgrte = *off
EFCcAC                   write (e) rhmrec
EFCcAC                   other
640nMC                   write (e) hmrec
EFCcAC                   endsl
     C                   if        %error
     C                   endif
640nAC                   endif
     C                   endif
     C                   if        *in49
     C                   eval      hedmsg = desc(1)
     C                   add       1             preoh
     C                   endif
640nDC**                 endif
     *
640eAC     skipProcessH  tag
     *
     *    Print order heading
     *
     C                   if        pflag = *off
     C                   write     head2
     C                   add       2             count
     C                   endif
     *
     C                   write     head3
     C                   add       2             count
     *
     C                   if        pflag = *off
     C                   write     head4
     C                   add       2             count
     C                   eval      pflag = *on
     C                   endif
     *
     *    Exception occurred, print on report.
     *
     C                   select
     C                   when      hedmsg > *blanks
     *
     *    Print exception report page headings.
     C                   if        *in92
     C                   write     head11                               92
     C                   write     head21
     C                   endif
     C                   write     head31
     *    Set on flag that customer heading printed already.
     C                   eval      prhdr1 = *on
     *
     C                   endsl
     *
     *    Initialize order subtotals
     *
     C                   eval      sublin = 0
     C                   eval      subq1 = 0
     C                   eval      subq2 = 0
     C                   eval      subq3 = 0
     C                   eval      subq11 = *zeros
     C                   eval      subq21 = *zeros
     C                   eval      subq31 = *zeros
     *
640eA*  If order header is good ...
640eAC                   if        hedmsg <> desc(8)
EFCaAC                             and hedmsg <> desc(9)
640eA*  Resquence stops in RTESTP file.
640eAC                   exsr      reseqstp
640eA*  Retrieve ORDH rec now that it has stop in it.
640eAC     ohkey1        chain(n)  ordh
640eAC                   endif
     *
     *    Whip through all the download detail records
     *
     C                   eval      eofd = *off
     C                   eval      excpr1 = *off
640aDC**   oidkey        setll     impfordd4
640aMC     keysod        setll     impsordd
     C                   dou       eofd = *on
     *
640aAC                   eval      error = *off
     *
640aDC**   oidkey        reade     impfordd4                              78
640aMC     keysod        reade     impsordd                               78
     C                   if        *in78
     C                   eval      eofd = *on
     C                   goto      enddod
     C                   endif
     *
640eA*  If order header is not good, skip past processing
640eA*  and just update the impsordd record.
640eAC                   if        hedmsg = desc(8)
640eAC                   eval      detmsg = desc(8)
640eAC                   eval      error = *on
640rA*
640rAC     itkey         chain     piritem
640rAC                   if        not %found(piritem)
640rAC                   eval      itdesc = ' '
640rAC                   eval      itpdsc = ' '
640rAC                   endif
640rA*
640eAC                   goto      skipProcessD
640eAC                   endif
EFCaA*
EFCaA*  If specific client and delete flag is on, skip past
EFCaA*  ordd processing and just update the impsordd record.
EFCaAC                   if        client = eastland and oihdel = *on
EFCcAC                             and oihtyp = 'S'
EFCaAC                   if        hedmsg = desc(9)
EFCaAC                   eval      detmsg = desc(9)
EFCaAC                   eval      error = *on
EFCaAC                   endif
640rA*
640rAC     itkey         chain     piritem
640rAC                   if        not %found(piritem)
640rAC                   eval      itdesc = ' '
640rAC                   eval      itpdsc = ' '
640rAC                   endif
640rA*
EFCaAC                   goto      skipProcessD
EFCaAC                   endif
640aA*
640aA*  Skip processed records.
640aA*
640aAC                   if        oidstatus <> 'R'
640aAC                   iter
640aAC                   endif
     *
     C                   eval      detmsg = *blanks
     C                   eval      good1 = 'N'
     C                   eval      good2 = 'N'
     C                   eval      mrgitm = *off
     C                   eval      stsmsg = *blanks
     *
     *       If item doesn't exist write error message.
     *
     C     itkey         chain     piritem                            76
     C                   if        *in76
640aAC                   eval      error = *on
     C                   eval      detmsg = desc(2)
     C                   add       1             noitem
640eAC                   eval      itwhdp = *blanks
640eAC                   eval      itstyp = *blanks
     C                   eval      itdesc = *blanks
530 AC                   eval      itpdsc = *blanks
CSP AC                   eval      itdesg = *blanks
     C                   movel     '*****'       itdesc
     C                   else
     *
CSP A*       If this item has a designation code of JIT, populate
CSP A*       oidspc with 'XD' so that it will be updated and
CSP A*       treated as a cross dock item.
CSP AC                   if        client = CoastalSunbelt
CSP AC                             and itdesg = 'JIT  '
CSP AC                   eval      oidspc = 'XD'
CSP AC                   endif
     *
     *       Check if breakdown qty is allowed using piritem file.
     *       Add rec if qty1, brk qty2 or brk qty3 has good qty.
     C                   exsr      zzbkdn
     *
     *       If qty1, brkdown qty2 or brkdown qty3 has good qty,
     *        add record to order detail file. If an error
     *        occurs, assume was caused by a duplicate record.
     *        Update route summary with detail information.
     *
     C                   if        good1 = 'Y'
     C                   exsr      zzxdck
     C                   if        good2 = 'Y'
     C                   exsr      fillod
640eAC                   if        detmsg = desc(7)
640pAC                             and oihtyp = 'S'
640eAC                   goto      skipProcessD
640eAC                   endif
     *
640tA*
640tA*    Update picking info for Outbound Only client.
640tAC                   if        opfeat = '3'
640tAC                   exsr      fillos
640tAC                   endif
     *
640aM*    Only update ORDDM fields if misc order det data was sent
640aA*    in IMPSORDD.
640aAC                   exsr      zzMiscD
     C                   if        miscupdate = '*YES'
     C                   exsr      fillom
     C                   endif
     *
     *    Record was updated in FILLOD.
     C                   if        skpwrt = *off
EFCcAC                   select
EFCcAC                   when      oihtyp = 'R' and mrgord = *off
EFCcAC                   write     ridrec                               49
EFCcAC                   other
     C                   write     odrec                                49
640tA*
640tAC                   if        opfeat = '3'
640tAC                   write     osrec                                48
640tAC                   endif
640tA*
EFCcAC                   endsl
     *
640pAC                   if        oihtyp = 'S'
640eAC                   exsr      zzzCrtLabel
640pAC                   endif
     *
640aM*    Only add to ORDDM if misc order det data was sent
640aA*    in IMPSORDD.
     C                   if        miscupdate = '*YES'
640nAC                   if        skpwrtdtlm = '0'
EFCcAC                   select
EFCcAC                   when      oihtyp = 'R' and mrgord = *off
EFCcAC                   write     rimrec                               49
EFCcAC                   other
     C                   write     omrec
EFCcAC                   endsl
     C                   if        %error
     C                   endif
640nAC                   endif
     C                   endif
     C                   if        *in49
640aAC                   eval      error = *on
     C                   eval      detmsg = desc(1)
     C                   add       1             preod
     C                   endif
     C                   endif
     C                   exsr      updsum
     C                   endif
     C                   endif
     *
     C                   endif
     *
640eAC     skipProcessD  tag
     *
     *       Print order detail and update subtotals
     *
     C                   exsr      zrhead
     C                   write     detail
     C                   add       1             count
     *
     *       Print order detail item merge info line.
     *
     C                   if        mrgrte = *on  and
     C                             mrgitm = *on
     C                   exsr      zrhead
     C                   write     detail2
     C                   add       1             count
     C                   endif
     *
     C                   add       1             sublin
     C                   add       oidq1         subq1
     C                   add       oidq2         subq2
     C                   add       oidq3         subq3
     *
     *       Delete detail record from download file
640aA*  DO NOT delete detail record from download file.
640aDC**                 delete    oidrec
     *
     *       Exception occurred, print on report.
     C                   select
     C                   when      detmsg > *blanks
     *
     *    Turn on flag to indicate at least one exception printed.
     *    Print grand totals when complete.
     C                   eval      excprt = *on
     *    Turn on flag to indicate at least one exception printed.
     *    Print sub totals when complete.
     C                   eval      excpr1 = *on
     *
     C                   add       oidq1         subq11
     C                   add       oidq2         subq21
     C                   add       oidq3         subq31
     *
     *    Print exception report page headings.
     C                   if        *in92
     C                   write     head11                               92
     C                   write     head21
     C                   write     head31
     C                   write     head41
     C                   eval      prhdr1 = *on
     C                   endif
     *
     *    Print exception report Customer info and headings.
     C                   if        prhdr1 = *off
     C                   write     head31                               92
     C                   eval      prhdr1 = *on
     C                   endif
     *
     *    Print exception report page headings.
     C                   if        *in92
     C                   write     head11                               92
     C                   write     head21
     C                   write     head31
     C                   write     head41
     C                   endif
     *
     C                   write     detail1                              92
     C                   add       1             grlin1
530 A*
530 A*    Print exception report page headings.
530 AC                   if        itpdsc > ' '
530 A*
530 AC                   if        *in92
530 AC                   write     head11                               92
530 AC                   write     head21
530 AC                   write     head31
530 AC                   write     head41
530 AC                   endif
530 AC                   write     detail22                             92
530 AC                   add       1             grlin1
530 A*
530 AC                   endif                                                  Endif - itpdsc > ' '
     *
     C                   endsl
     *
640aAC                   eval      oidordid = ohord
640aAC                   if        error
640aAC                   eval      importError = *on
640aAC                   eval      oidstatus = 'E'
640aAC                   eval      oidtext   = detmsg
640aAC                   eval      filnam    = 'IMPSORDD'
640aAC                   else
640aAC                   eval      oidstatus = 'S'
640aAC                   eval      oidtext = ' '
640aAC                   endif
640aAC                   exsr      zzzGetStamps
640aAC                   eval      oidststs = stamp
640aAC                   eval      oidstsuc = stampuc
640aAC                   update    oidrec
     *
     C     enddod        tag
     C                   enddo
     *
     *    Print order subtotals and update grand totals
     *
     C                   write     subttl
     C                   add       3             count
     C                   add       1             grdord
     C                   add       sublin        grdlin
     *
     *    Print Order exception subtotals.
     C                   if        excpr1 = *on
     C                   add       1             grord1
     C                   if        *in92
     C                   write     head11                               92
     C                   write     head21
     C                   write     head31
     C                   write     head41
     C                   endif
     C                   write     subttl1                              92
     C                   endif
     *
640pA*  For SOS orders ...
640eA*  Loop through ORDD recs for this order and compare to
640eA*  staging file for possible update or delete of ORDD record.
640pAC                   if        oihtyp = 'S'
640eAC                   exsr      zzzloopordd
640pAC                   endif
     *
     *  Delete header record from download file
640aA*  DO NOT delete header record from download file.
640aDC**                 delete    oihrec
     *
640aAC                   eval      oihrteid  = rhrtid
640aAC                   eval      oihordid  = ohord
640eDC**                 if        error
640eMC                   if        hedmsg <> *blanks
640aAC                   eval      importError = *on
640aAC                   eval      oihstatus = 'E'
640eDC**                 eval      oihtext   = detmsg
640eMC                   eval      oihtext   = hedmsg
640aAC                   eval      filnam    = 'IMPSORDH'
640aAC                   else
640aAC                   eval      oihstatus = 'S'
640aAC                   eval      oihtext = ' '
640aAC                   endif
640aAC                   exsr      zzzGetStamps
640aAC                   eval      oihststs = stamp
640aAC                   eval      oihstsuc = stampuc
640aAC                   update    oihrec
     *
     C     enddoh        tag
     C                   enddo

640cAC                   if        lstType = 'W'
640cAC                   exsr      processWC
640cAC                   endif
     *
     *  Print order grand totals
     *
     C                   if        pflag = *on
     C                   if        count >= linppg
     C                   write     head1
     C                   endif
     C                   write     grndttl
     C                   endif
     *
     *    Remove NEW Order Header if no items attached.
     C                   if        mrgord = *on
     C                   exsr      zzcko1
     C                   endif
     *
     *    Remove NEW Route Header if no orders attached.
     C                   if        mrgrte = *on
     C                   exsr      zzckr1
     C                   endif
     *
     *    Print exception grand totals.
     C                   if        excprt = *on
     C                   if        *in92
     C                   write     head11                               92
     C                   endif
     C                   write     grndttl1
     C                   endif
     *
640aAC                   exsr      zzzEnd
     *
     *  We are finished, so wrap things up and get out
     *
640eAC                   exsr      zzzDriClose
     *
     *    Call RMS Import Process
EFCfAC                   if        client = eastland
IFDaAC                             or client = ifd
EFCfAC                   close     rmsfordh
EFCfAC                   close     rmsfordd
EFCfAC                   close     rmsfordhm
EFCfAC                   close     rmsforddm
EFCfAC                   call      'RMS250CL'
EFCfAC                   endif
     *
640eAC                   eval      *inlr = *on
     *
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     C                   parm                    cliloc           10
     *
     *  Open RMS files.
     *
     C                   open      rmsfordh
     C                   open      rmsfordd
     C                   open      rmsfordhm
     C                   open      rmsforddm
     *
640aA*  Define key for impsordh file.
640aA*
640aAC     keysoh        klist
640aAC                   kfld                    $pWhse
640aAC                   kfld                    $pBatId
     *
640eA*  Define key for impsordd file.
640eA*
640eAC     impsdkey      klist
640eAC                   kfld                    $pWhse
640eAC                   kfld                    oihbatid
640eAC                   kfld                    oihord
640eAC                   kfld                    odseq
640eAC                   kfld                    oditem
     *
640aA*  Define key for impsordd file.
640aA*
640aAC     keysod        klist
640aAC                   kfld                    $pWhse
640aAC                   kfld                    $pBatId
640aAC                   kfld                    oihord
     *
     * CROSSDK  Cross Dock - Full key
     C     cdkey         klist
     C                   kfld                    slwhse
     C                   kfld                    slwhdp
     C                   kfld                    sldisp
     *
640eA* LABEL93 file - full key
640eAC     keylab93      klist
640eAC                   kfld                    $pwhse
640eAC                   kfld                    ohord
640eAC                   kfld                    hlditm
640eAC                   kfld                    oidseq
     *
     * ORDH Order header file - Partial key
     *
     C     ohkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    neword
640nA*
640nA* ORDH Order header file - Full key
640nA*
640nAC     opnohkey      klist
640nAC                   kfld                    $pwhse
640nAC                   kfld                    opnord
     *
640eA* ORDH Order header file
640eA*
640eAC     ohkey1        klist
640eAC                   kfld                    $pwhse
640eAC                   kfld                    ohord
     *
     * ORDH4 Order header file - Full key  (NEW Route)
     *
     C     oh3key        klist
     C                   kfld                    $pwhse
     C                   kfld                    newrte
     *
     * ORDH4 Order header file - Full key  (Open Route)
     *
     C     oh5key        klist
     C                   kfld                    $pwhse
     C                   kfld                    opnrte
     C                   kfld                    oihord
     *
640eA* ORDH10 Order header file joined to route
640eA*
640eAC     oh10key       klist
640eAC                   kfld                    $pwhse
640eAC                   kfld                    oihord
     *
     * ORDHM Order header misc. file - Full key
     *
     C     *like         define    hmord         kyord
     C     hmkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    kyord
     *
     * ORDD Order detail file - Partial key
     *
     C     odkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    neword
640eA*
640eA* ORDD Order detail file - Partial key
640eA*
640eAC     odkeyStg      klist
640eAC                   kfld                    $pwhse
640eAC                   kfld                    ohord
     *
     * ORDD1 Order detail file - Full key
     *
     C                   eval      kystat = 'O'
     C     od1key        klist
     C                   kfld                    $pwhse
     C                   kfld                    opnord
     C                   kfld                    kystat
     C                   kfld                    oidseq
640eDC**                 kfld                    oiditm
     *
     C     od2key        klist
     C                   kfld                    $pwhse
     C                   kfld                    neword
     C     od3key        klist
     C                   kfld                    $pwhse
640eMC                   kfld                    ohord
     C                   kfld                    kystat
     C                   kfld                    oidseq
     *
     * ORDDM  Order detail misc. file - Full key
     *
     C     omkey         klist
     C                   kfld                    odwhse
     C                   kfld                    odord
     C                   kfld                    odseq
     C                   kfld                    oditem
     *
     * OPTIONS Options file - Full key
     *
     C     opkey         klist
     C                   kfld                    opwhse
     C                   kfld                    opcode
     *
     * PODTL1 PO DETAIL file
     *
     C     keypd1        klist
     C                   kfld                    $pwhse
     C                   kfld                    oidpo
     C                   kfld                    oiditm
640eA*
640eA* PIRTRAN4 - Transaction file - Partial key
640eA*
640eAC     trnsky        klist
640eAC                   kfld                    $pwhse
640eAC                   kfld                    kygrp2
640eAC                   kfld                    kyrtpo
     *
     * RTEHED1 - Route header file - Partial key
     *
     C     rh1key        klist
     C                   kfld                    $pwhse
     C                   kfld                    oihrte
     *
     * RTEHED1 - Route header file - Full key
     C     rh2key        klist
     C                   kfld                    $pwhse
     C                   kfld                    newrtc
     C                   kfld                    newrte
     *
     * RTEHED1 - Route header file - Full key
     C     rh3key        klist
     C                   kfld                    $pwhse
     C                   kfld                    lstrte
     C                   kfld                    lstrid
640nA*
640nA* RTEHED2 - Route header file - Partial key
640nA*
640nAC     rh2akey       klist
640nAC                   kfld                    $pwhse
640nAC                   kfld                    kyrhstat
640nAC                   kfld                    oihtyp
640nAC                   kfld                    oihrte
     *
640eA* RTEHED1 - Route header file - Full key
640eAC     rh4key        klist
640eAC                   kfld                    $pwhse
640eAC                   kfld                    rhrte
640eAC                   kfld                    ohrte
     *
EFC A* RTEHED - Route header file - Full key
EFC AC     rhkey         klist
EFC AC                   kfld                    $pwhse
EFC AC                   kfld                    ohrte
     *
     * SLOT1 file
     C     keysl1        klist
     C                   kfld                    $pwhse
     C                   kfld                    itwhdp
     C                   kfld                    kyaisl
     *
640gA* SLOT3 file
640gAC     keysl3        klist
640gAC                   kfld                    $pwhse
640gAC                   kfld                    oiditm
640gAC                   kfld                    keystat
640gAC                   kfld                    keypick
     *
     * SLOT4 file
     C     keysl4        klist
     C                   kfld                    $pwhse
     C                   kfld                    itwhdp
     C                   kfld                    oiditm
     C                   kfld                    kydisp
     *
     * SLOT11 file
     C     keysl11       klist
     C                   kfld                    $pwhse
     C                   kfld                    kyaisl
EFCd *
EFCd * RMSROUTE file
EFCdAC     keyrms        klist
EFCdAC                   kfld                    rmswhs            6 0
EFCdAC                   kfld                    rmsrte            5
EFCdA*
     *  Variables and constants.
     *
640aAC                   eval      error  = *off
     C                   eval      forevr = *off
     C                   eval      mrgrte = *off
     C                   eval      mrgord = *off
     C                   eval      mrgitm = *off
     C                   eval      wrgsts = *off
     C                   eval      rcdlck = *off
     C                   eval      skpwrt = *off
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   endsr
     *----------------------------------------------------------------
530dA*  clr$slot  Clear $slot data structure fields
530dA*----------------------------------------------------------------
530dA
530dAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *
     *  FILLOD  Fill order detail fields.
     *
     C     fillod        begsr
     C                   eval      skpwrt = *off
     *
     *    Route & order at Open status. Check if item already on order.
     *    If yes, then compute difference between import qty's and order
     *    qty's. Then update order with import qty.
     C                   select
     C                   when      mrgrte = *on  and
     C                             mrgord = *on  and
     C                             wrgsts = *off
     *
     C                   eval      rcdlck = *on
     C                   exsr      zzgtod
     C                   eval      rcdlck = *off
     *
640pA*   SOS orders only ...
640eA*   Do not allow line item change if any qty has been picked
640eA*   and the item has been changed.
640eA*
640eAC                   if        not *in75 and oiditm <> oditem
640pAC                             and oihtyp = 'S'
640eAC                   exsr      zzzLblPck
640eDC**                 if        odqpk1 <> *zeros
640eMC                   if        pick1 <> *zeros
640eAC                             or pick2 <> *zeros
640eAC                             or pick3 <> *zeros
640dAC                   eval      error = '1'
640dAC                   eval      detmsg = desc(7)
640dAC                   eval      skpwrt = '1'
640dAC                   goto      endlod
640dAC                   endif
640eAC                   endif
     *
640eAC                   eval      hlditm = oditem
     *
     C                   select
     C                   when      not *in75  and
     C                             oiditm = oditem
     *
640eAC                   exsr      zzzSetQtyFlag
     *
     *    Calculate change in quantity to update RTESUM file.
     C                   eval      difqy1 = oidq1 - odqor1
     C                   eval      difqy2 = oidq2 - oidq2
     C                   eval      difqy3 = oidq3 - oidq3
     *
     C                   eval      odqor1 = oidq1
     C                   if        itflg1 = 'Y'
     C                   eval      odqor2 = oidq2
     C                   endif
     C                   if        itflg2 = 'Y'
     C                   eval      odqor3 = oidq3
     C                   endif
     C                   update    odrec1
640pM*    Update LABEL record for SOS orders.
640pAC                   if        oihtyp = 'S'
640eAC                   exsr      zzzLblUpdQ_I
640pAC                   endif
     *    Load print field for report.
     C                   move      odord         prtord
     C                   move      sts03         stsmsg
     C                   eval      mrgitm = *on
     C                   eval      skpwrt = *on
     C                   goto      endlod
     *
640pM*    Item# on SOS order is being changed.
640pDC**                 other
640pDC**   od3key        chain     ordd1                              75
640pDC**                 if        not *in75 and
640pDC**                           oditem <> oiditm
640pAC                   when      oihtyp = 'S'
640pAC     od3key        chain     ordd1                              75
640pAC                   if        not *in75 and oditem <> oiditm
     *
640eAC                   exsr      zzzSetQtyFlag
     *
640pA*    Calculate change in quantity to update RTESUM file.
640pAC                   eval      difqy1 = oidq1 - odqor1
640pAC                   eval      difqy2 = oidq2 - oidq2
640pAC                   eval      difqy3 = oidq3 - oidq3
     *
640dAC                   eval      oditem = oiditm
640eAC                   eval      odqor1 = oidq1
640eAC                   eval      odqor2 = oidq2
640eAC                   eval      odqor3 = oidq3
640eAC                   update    odrec1
640eA*    Update LABEL record.
640eAC                   exsr      zzzLblUpdQ_I
640eA*    Load print field for report.
640eAC                   move      odord         prtord
640eAC                   move      sts03         stsmsg
640eAC                   eval      mrgitm = *on
640eAC                   eval      skpwrt = *on
640eAC                   goto      endlod
640dAC                   endif
     *
     C                   endsl
     *
     C                   endsl
     *
     *  Initialize record
     *
     C                   clear                   odrec
     *
     *  Move fields from download file to purchase order header fields
     *
     C                   eval      odwhse = oidwhs
EFCcAC*                  eval      oiddiv = %char(oidwhs)
EFCeMC                   eval      oiddiv = *blanks
     *
     *    Open route found, Open order not found or at wrong status.
     *    Create order under current Open route.
     C                   select
     C                   when      mrgrte = *on  and
     C                             mrgord = *off  and
     C                             wrgsts = *off  or
     *
     C                             mrgrte = *on  and
     C                             mrgord = *off  and
     C                             wrgsts = *on
     C                   eval      odord = neword
     C                   move      sts02         stsmsg
     *
     *    Open route found, Open order found.
     *    Add item to current Open order.
     C                   when      mrgrte = *on  and
     C                             mrgord = *on  and
     C                             wrgsts = *off
     C                   eval      odord = opnord
     C                   move      sts01         stsmsg
     *
     C                   other
     C                   eval      odord = ohord
     C                   endsl
     *    Load print field for report.
     C                   move      odord         prtord
650bAC                   eval      oidror = odord
     *
     C                   eval      odseq = oidseq
     C                   eval      oditem = oiditm
     C                   eval      odqor1 = oidq1
     C                   eval      difqy1 = oidq1
     C                   if        itflg1 = 'Y'
     C                   eval      odqor2 = oidq2
     C                   eval      difqy2 = oidq2
     C                   else
     C                   eval      odqor2 = 0
     C                   eval      difqy2 = 0
     C                   endif
     C                   if        itflg2 = 'Y'
     C                   eval      odqor3 = oidq3
     C                   eval      difqy3 = oidq3
     C                   else
     C                   eval      odqor3 = 0
     C                   eval      difqy3 = 0
     C                   endif
     C                   eval      odwh2 = oidwh2
     C                   eval      odor2 = oidor2
     C                   eval      odoitm = oidoit
     C                   eval      odspcl = oidspc
     C                   eval      odstat = 'O'
     C                   eval      mrgitm = *on
     *
     C     endlod        tag
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILLOM  Fill order detail misc file fields.
     *
     C     filloM        begsr
640nAC                   eval      skpwrtdtlm = *off
640nAC                   if        miscupdate = '*NO '
640nAC                   eval      skpwrtdtlm = *on
640nAC                   goto      endlodm
640nAC                   endif
     *
     *    Route & order at Open status. Check if item already on order.
     *    If yes, then compute difference between import qty's and order
     *    qty's. Then update order with import qty.
     C                   select
     C                   when      mrgrte = *on  and
     C                             mrgord = *on  and
     C                             wrgsts = *off
     *
     C                   eval      rcdlck = *on
     C                   exsr      zzgtom
     C                   eval      rcdlck = *off
     *
     C                   select
     C                   when      %found(orddm) and
     C                             oiditm = oditem
     C                   eval      omodsc = oimdsc
     C                   eval      ompdsc = oimpds
     C                   eval      omrdsc = oimrds
     C                   eval      omcbox = oimbox
     C                   eval      omcexp = oimexp
     C                   eval      ommsc1 = oimms1
     C                   eval      ommsc2 = oimms2
     C                   eval      ommsc3 = oimms3
     C                   eval      ommsc4 = oimms4
     C                   eval      ommsc5 = oimms5
     C                   update    omrec
640nAC                   eval      skpwrtdtlm = '1'
     *
     C                   goto      endlodm
     C                   endsl
     *
     C                   endsl
     *
     *  Initialize record
     *
     C                   clear                   omrec
     *
     *  Move fields from download file to order detail misc file fields.
     *
EFCcAC                   if        oihtyp = 'R' and mrgord = *off
EFCcAC                   eval      oimwhs = oidwhs
EFCcAC                   eval      oimord = oidord
EFCcAC*                  eval      oimdiv = %char(oidwhs)
EFCeMC                   eval      oimdiv = *blanks
EFCcAC                   eval      oimseq = oidseq
EFCcAC                   eval      oimitm = oiditm
EFCcAC                   else
     C                   eval      omwhse = oidwhs
EFCcAC                   endif
     *
     *    Open route found, Open order not found or at wrong status.
     *    Create order under current Open route.
     C                   select
     C                   when      mrgrte = *on  and
     C                             mrgord = *off  and
     C                             wrgsts = *off  or
     *
     C                             mrgrte = *on  and
     C                             mrgord = *off  and
     C                             wrgsts = *on
     C                   eval      omord = neword
     *
     *    Open route found, Open order found.
     *    Add item to current Open order.
     C                   when      mrgrte = *on  and
     C                             mrgord = *on  and
     C                             wrgsts = *off
     C                   eval      omord = opnord
     *
     C                   other
     C                   eval      omord = ohord
     C                   endsl
     *
650bAC*                  eval      oimror = omord
650bAC                   eval      oimror = oidordid
     C                   eval      omseq  = oidseq
     C                   eval      omitem = oiditm
     C                   eval      omodsc = oimdsc
     C                   eval      ompdsc = oimpds
     C                   eval      omrdsc = oimrds
     C                   eval      omcbox = oimbox
     C                   eval      omcexp = oimexp
     C                   eval      ommsc1 = oimms1
     C                   eval      ommsc2 = oimms2
     C                   eval      ommsc3 = oimms3
     C                   eval      ommsc4 = oimms4
     C                   eval      ommsc5 = oimms5
     *
     C     endlodm       tag
     *
     C                   endsr
640tA*
640tA*----------------------------------------------------------------
640tA*
640tA*  FILLOS  Fill order detail pick slot fields.
640tA*
640tAC     filloS        begsr
640tA*
640tA*    Route & order at Open status. Check if item already on order.
640tA*    If yes, then compute difference between import qty's and order
640tA*    qty's. Then update order with import qty.
640tAC                   select
640tAC                   when      mrgrte = *on  and
640tAC                             mrgord = *on  and
640tAC                             wrgsts = *off
640tA*
640tAC                   exsr      zzgtos
640tA*
640tAC                   select
640tAC                   when          %found(ordds)
640tAC                             and oiditm = oditem
640tA*
640tAC                   eval      osdisp = oidslt
640tAC                   eval      osbulk = oidblk
640tAC                   update    osrec
640tA*
640tAC                   goto      endlods
640tAC                   endsl
640tA*
640tAC                   endsl
640tA*
640tA*  Initialize record
640tA*
640tAC                   clear                   osrec
640tA*
640tA*  Move fields from download file to purchase order header fields
640tA*
640tAC                   eval      oswhse = oidwhs
640tA*
640tA*    Open route found, Open order not found or at wrong status.
640tA*    Create order under current Open route.
640tAC                   select
640tAC                   when      mrgrte = *on  and
640tAC                             mrgord = *off  and
640tAC                             wrgsts = *off  or
640tA*
640tAC                             mrgrte = *on  and
640tAC                             mrgord = *off  and
640tAC                             wrgsts = *on
640tAC                   eval      osord = neword
640tA*
640tA*    Open route found, Open order found.
640tA*    Add item to current Open order.
640tAC                   when      mrgrte = *on  and
640tAC                             mrgord = *on  and
640tAC                             wrgsts = *off
640tAC                   eval      osord = opnord
640tA*
640tAC                   other
640tAC                   eval      osord = ohord
640tAC                   endsl
640tA*
640tAC                   eval      osseq  = oidseq
640tAC                   eval      ositem = oiditm
640tAC                   eval      osdisp = oidslt
640tAC                   eval      osbulk = oidblk
640tA*
640tAC     endlods       tag
640tA*
640tAC                   endsr
640tA*
     *----------------------------------------------------------------
     *
     *  FILLOH   Fill order header fields.
     *
     C     filloh        begsr
640nAC                   eval      skpwrthdr = '0'
640nA*
640nA*    Open route found, Open order found.
640nA*    Update existing order.
640nAC                   if        mrgrte = *on  and
640nAC                             mrgord = *on  and
640nAC                             wrgsts = *off
640nAC     opnohkey      chain     ordh
640nAC                   if        %found(ordh)
640nAC                   eval      ohcord = oihord
EFChAC                   if        client = eastland
EFChAC                   eval      ohtype = oihtyp
EFChAC                   endif
640nAC                   eval      ohcpo  = oihcpo
640nAC                   eval      ohcust = oihcus
640nAC                   eval      ohcnam = oihcnm
640nAC                   eval      ohcad1 = oihca1
640nAC                   eval      ohcad2 = oihca2
640nAC                   eval      ohccty = oihcct
640nAC                   eval      ohcst  = oihcst
640nAC                   eval      ohczip = oihczp
640nAC                   eval      ohmisc = oihmsc
640nA*
640nA*    Open route found, Open order found.
640nA*    Update existing order.
640nAC                   update    ohrec
640nAC                   eval      skpwrthdr = '1'
640nA*    Load print field for report.
640nAC                   eval      prtrte = ohrte
640nA*
640nAC                   goto      endlodh
640nA*
640nAC                   endif
640nA*
640nAC                   endif
     *
     *  Initialize record
     *
     *
     C                   clear                   ohrec
     *
     *  Move fields from download file to purchase order header fields
     *
     C                   eval      ohwhse = oihwhs
EFCcAC*                  eval      oihdiv = %char(oihwhs)
710aDC*                  eval      oihdiv = *blanks
710aMC                   eval      roihdiv = *blanks
     C                   call      'PIRORD#'
     C                   parm      ohwhse        $owhse            3 0
     C     ohord         parm      0             $oord             7 0
     C                   eval      neword = ohord
650bAC                   eval      roihror = neword
     C                   eval      ohtype = oihtyp
     C                   eval      ohcord = oihord
     C                   eval      ohcpo = oihcpo
     C                   eval      ohcust = oihcus
     C                   eval      ohcnam = oihcnm
     C                   eval      ohcad1 = oihca1
     C                   eval      ohcad2 = oihca2
     C                   eval      ohccty = oihcct
     C                   eval      ohcst = oihcst
     C                   eval      ohczip = oihczp
     *
     *    Open route found, Open order NOT found.
     *    Add Order to current Open Route.
     C                   select
     C                   when      mrgrte = *on  and
     C                             mrgord = *off  and
     C                             wrgsts = *off
     C                   eval      ohrte = opnrte
     *
     C                   other
     C                   eval      ohrte = rhrtid
     C                   endsl
     *    Load print field for report.
     C                   eval      prtrte = ohrte
     *
     *      Set stops to zero. OI300 will compute a sequential
     *      stop number to be populated into this field.
     C                   eval      ohstop = 0
     *
640cDC**                 eval      ohtruk = $ptruk
640cMC                   eval      ohtruk = rhtruk
     C                   eval      ohmisc = oihmsc
     C                   eval      ohsdte = impdte
     C                   eval      ohstim = imptim
640pAC                   if        oihtyp = 'S'
640pAC                   eval      ohstat = 'P'
640pAC                   else
     C                   eval      ohstat = 'O'
640pAC                   endif
640nA*
640nAC     endlodh       tag
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILLHM  Fill order header misc file fields.
     *
     C     fillHM        begsr
640nAC                   eval      skpwrthdrm = '0'
     *
     C                   select
     *    Open route found, Open order found.
     *    Retrieve Open Order Header Misc. file
     C                   when      mrgrte = *on  and
     C                             mrgord = *on  and
     C                             wrgsts = *off
     C                   eval      kyord = opnord
     *
     C                   other
     C                   eval      kyord = neword
     C                   endsl
     *
     C                   eval      rcdlck = *on
     C                   exsr      zzgethm
     C                   eval      rcdlck = *off
     *
     C                   select
     C                   when      %found(ordhm)
     *
     C                   select
     *    Open route found, Open order found.
     *    Leave route ID untouched.
     C                   when      mrgrte = *on  and
     C                             mrgord = *on  and
     C                             wrgsts = *off
     *
     *    Open route found, Open order NOT found.
     *    Add Order to current Open Route.
     C                   when      mrgrte = *on  and
     C                             mrgord = *off  and
     C                             wrgsts = *off
     C                   eval      hmrtid = opnrte
     C                   other
     C                   eval      hmrtid = rhrtid
     C                   endsl
     *
     C                   eval      hmmsc1 = ohmms1
     C                   eval      hmmsc1 = ohmms1
     C                   eval      hmmsc2 = ohmms2
     C                   eval      hmmsc3 = ohmms3
     C                   eval      hmmsc4 = ohmms4
     C                   eval      hmmsc5 = ohmms5
     C                   update    hmrec
640nAC                   eval      skpwrthdrm = '1'
     *
     C                   goto      endlodhm
     *
     C                   endsl
     *
     *  Initialize record
     *
     C                   clear                   hmrec
     *
     *  Move fields from download file to order detail misc file fields.
     *
EFCcAC                   if        oihtyp = 'R' and mrgord = *off
EFCcAC                   eval      ohmwhs = oihwhs
EFCcAC                   eval      ohmord = oihord
EFCcAC*                  eval      ohmdiv = %char(oihwhs)
EFCeMC                   eval      ohmdiv = *blanks
EFCcAC                   else
     C                   eval      hmwhse = oihwhs
     C                   eval      hmord = neword
EFCcAC                   endif
     C                   select
     *
     *    Open route found, Open order NOT found.
     *    Add Order to current Open Route.
     C                   when      mrgrte = *on  and
     C                             mrgord = *off  and
     C                             wrgsts = *off
     C                   eval      hmrtid = newrte
     *
     C                   other
     C                   eval      hmrtid = rhrtid
     C                   endsl
     *
650bAC*                  eval      ohmror = hmord
650bAC                   eval      ohmror = neword
     C                   eval      hmmsc1 = ohmms1
     C                   eval      hmmsc2 = ohmms2
     C                   eval      hmmsc3 = ohmms3
     C                   eval      hmmsc4 = ohmms4
     C                   eval      hmmsc5 = ohmms5
     *
     C     endlodhm      tag
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILLRH   Fill route header fields.
     *
     C     fillrh        begsr
     *
     *  Initialize record
     *
     C                   clear                   rhrec
     *
     *  Update fields.
     *
     C                   eval      rhwhse = oihwhs
     C                   call      'PIRRTE#'
     C                   parm      rhwhse        $rwhse            3 0
     C                   parm      ' '           rhrtid
     C                   eval      lstrid = rhrtid
     *
640cDC**                 add       1             rtcnt
640cDC**                 select
640cDC**                 when      rtcnt = 1
640cDC**                 eval      $prt01 = rhrtid
640cDC**                 when      rtcnt = 2
640cDC**                 eval      $prt02 = rhrtid
640cDC**                 when      rtcnt = 3
640cDC**                 eval      $prt03 = rhrtid
640cDC**                 when      rtcnt = 4
640cDC**                 eval      $prt04 = rhrtid
640cDC**                 when      rtcnt = 5
640cDC**                 eval      $prt05 = rhrtid
640cDC**                 when      rtcnt = 6
640cDC**                 eval      $prt06 = rhrtid
640cDC**                 when      rtcnt = 7
640cDC**                 eval      $prt07 = rhrtid
640cDC**                 when      rtcnt = 8
640cDC**                 eval      $prt08 = rhrtid
640cDC**                 when      rtcnt = 9
640cDC**                 eval      $prt09 = rhrtid
640cDC**                 when      rtcnt = 10
640cDC**                 eval      $prt10 = rhrtid
640cDC**                 endsl
     C                   eval      newrte = rhrtid
640cDC**                 if        $ptype = 'W'  and
640cMC                   if        oihtyp = 'W'  and
     C                             oihrte = *blanks
     C                   eval      rhrte = rhrtid
     C                   else
     C                   eval      rhrte = oihrte
     C                   endif
     C                   eval      newrtc = oihrte
     C                   eval      rhtype = oihtyp
640cDC**                 if        $ptype = 'W'  and
640cMC                   if        oihtyp = 'W'  and
     C                             oihtrk = *blanks
     *
     C                   eval      rhtruk = *blanks
     C                   movel     'WILLCALL'    rhtruk
     C                   else
     C                   eval      rhtruk = oihtrk
     C                   endif
     *
640cDC**                 eval      $ptruk = rhtruk
640eDC**                 eval      rhstat = *on
640pDC**                 eval      rhstat = '4'
     C                   eval      rhstsd = impdte
     C                   eval      rhstst = imptim
     C                   eval      rhimpd = impdte
     C                   eval      rhimpt = imptim
     C                   eval      rhrptd = impdte
     *
640pAC                   if        oihtyp = 'S'
640pAC                   eval      rhstat = '4'
640pAC                   else
640pAC                   eval      rhstat = '1'
640pAC                   endif
     *
     C                   endsr
520aA*
520aA*----------------------------------------------------------------
520aA*
520aA*  FILLXR   Fill Stop Xref File RTESTP
520aA*
520aAC     fillxr        begsr
520aA*
520aA*  Initialize record
520aA*
520aAc                   clear                   rtsRec
520aA*
520aAc                   eval      rtswhs = ohWhse
520aAc                   eval      rtsrid = ohRte
520aAc                   eval      rtsord = ohord
520aAc                   eval      rtsstp = 0
520aAc                   eval      rtsst5 = oihest
520aA*
520aAc                   endsr
520aA*
EFCaA*----------------------------------------------------------------
EFCaA*
EFCaA*  INZPAR   Initialize parameters for calling add/chg/del program
EFCaA*
     C     inzpar        begsr
     C                   clear                   $parms
     C                   eval      $pprg = #prog
     C                   eval      $pwhs = $pwhse
     C                   eval      $prte = rhrte
     C                   eval      $prtid = rhrtid
     C                   endsr
520aA*----------------------------------------------------------------
520aA*
520aA*  RESEQSTP   Call pgm to Re-Sequence ORDH file
520aA*
520aAC     reseqstp      begsr
520aA*
520aA*  Resequence stops in ORDH to make them unique.
520aA*
520aAc                   call      'OI300'
520aAc                   parm                    rhwhse
520aAc                   parm                    lstrid
520aA*
520aAc                   endsr
520aA*
CSPaA*----------------------------------------------------------------
CSPaA*
CSPaA*  STRIPSPCL   Strip special characters from customer name.
CSPaA*
CSPaAC     stripspcl     begsr
CSPaA*
CSPaA*      Loop through list of special char's and remove them
CSPaA*      from customer name, OIHCNM. Special char's are causing
CSPaA*      terminal errors in GUI Drag/Drop module.
CSPaA*
CSPaAc                   do        NbrSpclChar   s
CSPaAC                   Eval      Start = %Scan(%subst(spclchar:s:1): oihcnm:1)
CSPaA*
CSPaAc                   if        start = 0
CSPaAc                   iter
CSPaAc                   endif
CSPaA*
CSPaAC                   eval      oihcnm = %replace(' ': oihcnm: start)
CSPaA*      Loop to find all occurenances of current special char and
CSPaA*      replace it.
CSPaAc                   dow           start > 0
CSPaAc                             and start < 40
CSPaAC                   eval      start = start + 1
CSPaAC                   eval      start =
CSPaAC                               %scan(%subst(spclchar:s:1): oihcnm: start)
CSPaAc                   if        start > 0
CSPaAC                   eval      oihcnm = %replace(' ': oihcnm: start)
CSPaAC                   endif
CSPaA*
CSPaAC                   enddo
CSPaA*
CSPaAC                   enddo
CSPaA*
CSPaAc                   endsr
CSPaA*
     *----------------------------------------------------------------
     *
     *  OPNPRT  Open printer file.
     *
     C     opnprt        begsr
     *
     *   Get device and form type for department.
     *
     C                   call      'GETRPT'
     C                   parm      '*DEVFORM'    $cmd              8
     C                   parm      'OI2861PR'    $lrpt            10
     C                   parm      lstwhs        $whse             3 0
     C                   parm      *blanks       $styp             1
     C                   parm      *blanks       $whdp             5
     C                   parm                    $desc            50
     C                   parm                    $dev             10
     C                   parm                    $form            10
     C                   if        $dev = *blanks
     C                   movel     '*JOB'        $dev
     C                   endif
     C                   if        $form = *blanks
     C                   movel     '*STD'        $form
     C                   endif
     *
     *   Open printer file for department.
     *
     C                   if        opened <> *on
     *
     *      If printer already open then close it.
     *
     C                   if        opened = *on
     C                   close     oi2861pr
     C                   close     oi286pr
     C                   endif
     *
     *      Override printer file.
     *
     *          OVRPRTF FILE(OI2861PR) OUTQ(*DEV) DEV($dev)
     *                  FORMTYPE($form)
     *        NOTE: Ending array positions for $DEV 39, $FORM 60 are one
     *              greater than standard code. This is due to the
     *              extra character in the printer file name.
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
     *   Get device and form type for main report.
     *
     C                   call      'GETRPT'
     C                   parm      '*DEVFORM'    $cmd
     C                   parm      'OI286PR '    $lrpt
     C                   parm      lstwhs        $whse
     C                   parm      *blanks       $styp
     C                   parm      *blanks       $whdp
     C                   parm                    $desc
     C                   parm                    $dev
     C                   parm                    $form
     C                   if        $dev = *blanks
     C                   movel     '*JOB'        $dev
     C                   endif
     C                   if        $form = *blanks
     C                   movel     '*STD'        $form
     C                   endif
     *
     *      Override printer file.
     *
     *          OVRPRTF FILE(OI286PR) OUTQ(*DEV) DEV($dev)
     *                  FORMTYPE($form)
     *
     C                   movea     ovrprt(2)     a80
     C                   movea     $dev          a80(38)
     C                   movea     $form         a80(59)
     C                   movea     a80           qcmd
     *
     C                   call      'QCMDEXC'
     C                   parm                    qcmd
     C                   parm      80            qlen
     *
     *      Open printer file.
     *
     C                   open      oi2861pr
     C                   open      oi286pr
     C                   eval      opened = *on
     *
     C                   endif
     *
     C                   endsr
640cA*----------------------------------------------------------------
640cA*  ProcessWC   Call program to process Will Call
640cA*----------------------------------------------------------------
640cA*
640cAC     processWC     begsr

EFCdAC                   if        client <> Eastland
     C                   call      'RH220'
     C                   parm      rhwhse        $xWhse           15 5
     C                   parm      rhtruk        $xTruk           10
     C                   parm      '0'           $xJTyp            1
     C                   parm      #pgm          $xPrg            10
     C                   parm      rhrtid        $xRtId            5
     C                   parm      ' '           $xRtn             8
EFCdAC                   endif

     C                   endsr
     *----------------------------------------------------------------
     *
     *  UPDRTE   Update route with automatically assigned truck.
     *
     C     updrte        begsr
     *
     *  If first time throught, then get out.
     *
     C     lstrte        cabeq     '@@@@@'       endupr
     *
     *  Get route header record.
     *
     C     rh3key        chain     rtehed1                            73
     C                   if        *in73
     C                   goto      endupr
     C                   endif
     *
     *  If truck already defined, get out.
     *
     C                   if        rhtruk <> *blanks
     C                   unlock    rtehed1
     C                   goto      endupr
     C                   endif
     *
     *  Call program to automatically assign truck.
     *
HAL AC                   if        client = Halsey
BIR AC                             or client = BiRite
HAL A*      No truck template assigned if default not found.
HAL AC                   eval      $xcmd = '*DFTNOAU'
HAL AC                   else
HAL AC                   eval      $xcmd = '*DFLT   '
HAL AC                   endif
HAL A*
     C                   call      'OI260'
     C                   parm                    rhwhse
     C                   parm                    rhrtid
     C                   parm                    rhtruk
     C                   parm                    $xrtn             8
HAL DC*                  parm      '*DFLT  '     $xcmd             8
HAL MC                   parm                    $xcmd             8
     C                   if        $xrtn = '*OK'
     C                   update    rhrec1
     C                   else
     C                   unlock    rtehed1
     C                   endif
     *
     C     endupr        endsr
     *----------------------------------------------------------------
     *
     *  UPDSUM   Update route summary file with detail record.
     *
     C     updsum        begsr
     *
     *  Define work fields
     *
     *
     *  Try to get existing summary records for department.
     *
     C                   select
     *    Update route summary for Open route when Open Order
     *    found and at correct status.
     C                   when      mrgrte = *on  and
     C                             mrgord = *on  and
     C                             wrgsts = *off  and
     C                             mrgitm = *on  or
     *
     *    Update route summary for Open route when Open Order
     *    NOT found and at correct status.
     C                             mrgrte = *on  and
     C                             mrgord = *off  and
     C                             wrgsts = *off  and
     C                             mrgitm = *on
     C                   eval      kyrtid = opnrte
     *
     C                   other
     C                   eval      kyrtid = newrte
     C                   endsl
     *
     *     Determine department to use.
     *
     C                   select
     C                   when      client = cheney
     C                   if        ititem >= '405000'  and
     C                             ititem <= '492999'
     C                   eval      kywhdp = 'PRD  '
     C                   else
     C                   eval      kywhdp = itwhdp
     C                   endif
     C                   other
     C                   eval      kywhdp = itwhdp
     C                   endsl
     *
     C     keyrs         chain     rtesum                             77
     *
     *     Record does not exist - Initialize fields.
     *
     C                   if        *in77
     C                   eval      rswhse = rhwhse
     C                   eval      rsrtid = kyrtid
     C                   eval      rswhdp = kywhdp
     C                   eval      rsordc = 0
     C                   eval      rsordw = 0
     C                   eval      rsordp = 0
     C                   eval      rspckc = 0
     C                   eval      rspckw = 0
     C                   eval      rspckp = 0
     C                   endif
     *
     *     Update department totals.
     *
     *     Get base item for alias item.
     C                   eval      #bityp = *blanks
     C                   if        ittype = 'A'
     C                   call      'GETBASE'
     C                   parm      itwhse        $gwhse            3 0
     C                   parm      ititem        $gitem           15
     C                   parm      ' '           #bitem           15
     C                   parm                    #bityp            1
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     C                   parm                    #bwhdp            5
     C                   parm                    #bstyp            1
     C                   parm                    #bum1             2
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
     C                   parm                    #bcum1            2
     C                   parm                    #bcum2            2
     C                   parm                    #bcuq2            3 0
     C                   parm                    #bcum3            2
     C                   parm                    #bcuq3            3 0
     C                   parm                    #brtn             8
     C                   endif
     *
     C                   add       difqy1        rsordp
     C                   if        #bityp = 'S'  or
     C                             ittype = 'S'
     C                   if        itumq2 <= 0
     C                   eval      tmpcub = tmpcub * difqy1
530bAC                   eval      tmpwgt = tmpwgt * difqy1
     C                   else
     C     itcube        div(h)    itumq2        tmpcub
530bAC     itswgt        div(h)    itumq2        tmpwgt
     C                   eval      tmpcub = tmpcub * difqy1
530bAC                   eval      tmpwgt = tmpwgt * difqy1
     C                   endif
     C                   else
     C                   eval      tmpcub = itcube * difqy1
530bAC                   eval      tmpwgt = itswgt * difqy1
     C                   endif
     *
     C                   add       tmpcub        rsordc
530bDC*                  eval      tmpwgt = itswgt * difqy1
     C                   add       tmpwgt        rsordw
     *
     C                   add       difqy2        rsordp
     C                   if        difqy2 <> 0  and
     C                             itumq2 > 0
     C     itcube        div(h)    itumq2        tmpcub
     C                   eval      tmpcub = tmpcub * difqy2
     C                   add       tmpcub        rsordc
     C     itswgt        div(h)    itumq2        tmpwgt
     C                   eval      tmpwgt = tmpwgt * difqy2
     C                   add       tmpwgt        rsordw
     C                   endif
     *
     C                   add       difqy3        rsordp
     C                   if        difqy3 <> 0  and
     C                             itumq3 > 0
     C     itcube        div(h)    itumq3        tmpcub
     C                   eval      tmpcub = tmpcub * difqy3
     C                   add       tmpcub        rsordc
     C     itswgt        div(h)    itumq3        tmpwgt
     C                   eval      tmpwgt = tmpwgt * difqy3
     C                   add       tmpwgt        rsordw
     C                   endif
     *
     *     Add/Update summary record.
     *
     C                   if        *in77
     C                   write     rsrec
     C                   else
     C                   update    rsrec
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZBKDN  Check breakdown quantities.
     *
     C     zzbkdn        begsr
     C                   if        oidq2 <> 0  and
     C                             itflg1 <> 'Y'
640aAC                   eval      error = *on
     C                   eval      detmsg = desc(3)
     C                   add       1             badbrk
640pAC                   goto      bkdntag
     C                   endif
     *
     C                   if        oidq3 <> 0  and
     C                             itflg2 <> 'Y'
640aAC                   eval      error = *on
     C                   eval      detmsg = desc(3)
     C                   add       1             badbrk
640pAC                   goto      bkdntag
     C                   endif
640eA*
640pDC**                 if        error = *off
640pDC**                 eval      good1 = 'Y'
640pDC**                 endif
     *
640eD***Move fields from download file to purchase order header fields
640eD*
640pM*  SOS orders do not require a qty > 0.  It's possible that a 0 qty will
640eA*  be imported to set the qty to 0 for an item which was imported earlier
640eA*  with said qty > 0. Thus, only do the following logic for normal orders.
640eA*
640eDC**                 if        oidq1 <> 0
640eDC**                 eval      good1 = 'Y'
640eDC**                 else
640eDC**                 if        oidq2 <> 0  and
640eDC**                           itflg1 = 'Y'
640eDC**                 eval      good1 = 'Y'
640eDC**                 else
640eDC**                 if        oidq3 <> 0  and
640eDC**                           itflg2 = 'Y'
640eDC**                 eval      good1 = 'Y'
640eDC**                 endif
640eDC**                 endif
640eDC**                 endif
     *
640pAC                   if        oihtyp = ' '
EFCcAC                             or oihtyp = 'R'
640pAC                   eval      good1 = 'N'
640pAC                   eval      error = *on
640pAC                   if        oidq1 <> 0
640pAC                   eval      error = *off
640pAC                   else
640pAC                   if        oidq2 <> 0  and
640pAC                             itflg1 = 'Y'
640pAC                   eval      error = *off
640pAC                   else
640pAC                   if        oidq3 <> 0  and
640pAC                             itflg2 = 'Y'
640pAC                   eval      error = *off
640pAC                   endif
640pAC                   endif
640pAC                   endif
640pAC                   endif
     *
EFCfAC                   if        client = eastland
EFCfAC                   eval      error = *off
EFCfAC                   endif
     *
640pAC     bkdntag       tag
     *
640pAC                   if        error = *off
640pAC                   eval      good1 = 'Y'
640pAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
640eM*  ZZCKRT  Check if route still at Open Status for non SOS orders.
     *
     C     zzckrt        begsr
     *
     *    Position past last route, then read backward to get last route.
     *    If Regular route and status is Open, then allow orders to be
     *    merged to existing route.
     *
     *    NOTE: If we find the route that is being merged in,
     *          and the route is at Open status, we will leave the
     *          route header record locked till the merge is com-
     *          plete or we process a new route.  Leaving the record
     *          locked will prevent anyone from Allocating the route
     *          while we are importing new orders.
     *
640nDC*    rh1key        setgt     rtehed1
640nMC     rh2akey       setgt     rtehed2
640nDC*    rh1key        readpe    rtehed1                                73
640nMC     rh2akey       readpe    rtehed2                                72
     C                   select
640nDC*                  when      not *in73  and
640nMC                   when      not *in72  and
EFCcDC**                           rhtype = ' '  and
EFCcMC                             (rhtype = ' ' or rhtype = 'R') and
     C                             rhstat = '1'
     C                   eval      mrgrte = *on
     C                   eval      opnrte = rhrtid
     C                   eval      opnrtc = rhrte
     *
     C                   other
     C                   eval      mrgrte = *off
640nDC**                 unlock    rtehed1
     *
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
640eA*
640eA*  ZZCKRTSOS  Check if route still at Open Status for SOS orders.
640eA*
640eAC     zzckrtSOS     begsr
640eA*
     *    Use the imported customer order number to find out if the
     *    order is still open.
     *      a. if the order exists and the route id is open, the order will
     *         be merged into it.
     *      b. if the order exists and the route id is closed, an error
     *         will be returned.
     *      c. if the order does not exist, the order will be created with
     *         a new route id and a new order id.
     *
     *    NOTE: If we find the route that is being merged in,
     *          and the route is at Open status, we will leave the
     *          route header record locked till the merge is com-
     *          plete or we process a new route.  Leaving the record
     *          locked will prevent anyone from Allocating the route
     *          while we are importing new orders.
     *
     C                   eval      crtNewTran = *off
     *
     C     oh10key       chain     ordh10
     C                   select
     *
     C                   when      not %found
     C                   eval      mrgrte = *off
     C                   eval      crtNewTran = *on
EFCbAC                   eval      ohord  = 0
EFCbAC                   eval      ohcord = 0
EFCbAC                   eval      ohrte  = ' '
EFCbAC                   eval      rhrte  = ' '
EFCbAC                   eval      rhrtid = ' '
     *
     C                   when      %found and rhstat > '4'
     C                   eval      hedmsg = desc(8)
     C                   add       1             preoh
     *
     C                   when      %found and rhstat <= '4'
     C                   eval      mrgrte = *on
     C                   eval      opnrte = rhrtid
     C                   eval      opnrtc = rhrte
     *       Lock the route header record.
     C     rh4key        chain     rtehed1
     *       Check for existing transaction.
     C                   eval      kygrp2 = 'S'
     C                   eval      kyrtpo = rhrtid
     C     trnsky        setll     pirtran4
     C                   dow       forevr = forevr
     C     trnsky        reade     pirtran4
     C                   if        %eof
     C                   eval      crtNewTran = *on
     C                   leave
     C                   endif
     C                   if        ptgrp1 <> 'S'
     C                   iter
     C                   endif
640fAC                   eval      @ptrn# = pttrn#
     C                   leave
     C                   enddo
     *
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCKR1  Check if NEW route has any orders attached.
     *
     C     zzckr1        begsr
     *
     *    Check to see if any orders attached to NEW Route Header.
     *    If none found, then Delete NEW Route Header record.
     C     oh3key        setll     ordh4                                  77
     C                   if        not *in77
     C     rh2key        chain     rtehed1                            73
     C                   if        not *in73
     C                   delete    rhrec1
     C                   endif
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCKOR  Check if order header still at Open status.
     *
     C     zzckor        begsr
     *
     C     oh5key        setll     ordh4
     C                   dow       forevr = forevr
     C     oh5key        reade     ordh4                                  77
     C                   select
     C                   when      *in77
     *
     C                   leave
     *
     *    In order to merge an order being imported, the following have
     *    to match: Must be the same type, existing order must be open,
     *    same customer and for GFG ONLY: Memo codes must match.
     C                   when      not *in77  and
EFCcDC**                           oihtyp = ' '  and
EFCcMC                             (oihtyp = ' ' or oihtyp = 'R') and
EFCcDC**                           ohtype = ' '  and
EFCcMC                             (ohtype = ' ' or ohtype = 'R') and
640qDC*                            ohstat = 'O'  and
640qMC                             ohstat = 'O'
     *    Next line is for GFG ONLY: Memo codes must match.
640qDC*                            oihmec = ohmemc
     C                   eval      mrgord = *on
     C                   eval      opnord = ohord
     C                   eval      opnorc = ohcord
     C                   leave
     *
EFChAC                   when      client = eastland and
EFChAC                             not *in77  and
EFChAC                             oihtyp = 'S'
EFChAC                   eval      mrgord = *on
EFChAC                   eval      opnord = ohord
EFChAC                   eval      opnorc = ohcord
EFChAC                   leave
     *
640eAC                   when      not *in77  and
640eAC                             oihtyp = 'S'  and
640eAC                             ohtype = 'S'  and
640qDC*                            ohstat = 'P'  and
640qMC                             ohstat = 'P'
640qDC*                            oihmec = ohmemc
640eAC                   eval      mrgord = *on
640eAC                   eval      opnord = ohord
640eAC                   eval      opnorc = ohcord
640eAC                   leave
     *
     C                   other
     C                   eval      wrgsts = *on
     C                   leave
     *
     C                   endsl
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCKO1  Check if NEW order header has items attached.
     *
     C     zzcko1        begsr
     *
     *    Check to see if any Items attached to NEW Order Header.
     *    If none found, then Delete NEW Order Header record.
     C     odkey         setll     ordd1                                  75
     C                   if        not *in75
     C     ohkey         chain     ordh                               74
     C                   if        not *in74
     C                   delete    ohrec
     C                   endif
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
530dA*
530dA*  ZZCRXD   Use DRISLOT with %CRTXDOCK to create new cross dock
530dA*           slot if one does not exist.  Then use %ALLOCATE to
530dA*           put the qty into the slot.
530dA*
530dAC     zzcrxd        begsr
530dA*
     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = oidwhs
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = itwhdp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = oiditm
     C                   eval      $slaislu = *on
CSP AC                   if        client = CoastalSunbelt
CSP AC                   eval      $slaisl = 'JIT'
CSP AC                   else
     C                   eval      $slaisl  = 'XDK'
CSP AC                   endif
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd = '%CRTXDOCK'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error = *on
     C                   goto      endcrxd
     C                   endif
     *
     *  Use DRISLOT/%ALLOCATE to put the qty into the slot.
     *
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd = '%ALLOCATE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = $slitem
     C                   eval      $sldispu = *on
     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = oidq1
     C                   eval      $saqty2 = oidq2
     C                   eval      $saqty3 = oidq3
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error = *on
     C                   goto      endcrxd
     C                   endif
     *
     C     endcrxd       endsr
640eA*----------------------------------------------------------------
640eA*  zzgetdatetime  Get current date & time
640eA*----------------------------------------------------------------
640eA
640eAC     zzgetdatetime begsr
640eA
     C                   time                    curtime

     C                   if        curtime < lasttime or curdate = 0
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o
     C                   endif

     C                   eval      lasttime = curtime

     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZGETHM   Get order header misc. file rcd. (with/without) record lock.
     *
     C     zzgethm       begsr
     *
     C                   select
     C                   when      rcdlck = *off
     C     hmkey         chain(n)  ordhm
     *
     C                   when      rcdlck = *on
     C     hmkey         chain     ordhm
     *
     C                   endsl
     *
     *    Order header misc. record not found. Clear misc fields.
     C                   if        not %found(ordhm)
     C                   eval      hmmsc1 = ' '
     C                   eval      hmmsc2 = ' '
     C                   eval      hmmsc3 = ' '
     C                   eval      hmmsc4 = ' '
     C                   eval      hmmsc5 = ' '
     C                   endif
     *
     C                   endsr
     *
640gA*----------------------------------------------------------------
640gA*  zzgetslot  Get first pick slot for the item, or if no pick
640gA*             slots, get the first overflow slot.
640gA*----------------------------------------------------------------
640gA
640gAC     zzgetslot     begsr
640gA
     C                   eval      lbwhdp = *blanks
     C                   eval      lbdisp = *blanks
     C                   eval      keystat = 'A '
     *
     *  See if you can find a pick slot for the item.
     C                   eval      keypick = 'Y'
     C     keysl3        setll     slot3
650aAC                   dow       forevr = forevr
     C     keysl3        reade     slot3

     C                   if        %eof(slot3)
650aAc                   leave
650aAC                   endif

650aAC                   if        sldesg='BFC'
650aAC                   iter
650aAC                   endif

     C                   eval      lbwhdp = slwhdp
     C                   eval      lbdisp = sldisp
650aAC                   leavesr
650aAC                   enddo
     c*                  else
     *
     *  If no pick slot, look for an overflow slot.
     C                   eval      keypick = 'N'
     C     keysl3        setll     slot3
650aAC                   dow       forevr = forevr
     C     keysl3        reade     slot3
     C                   if        %eof(slot3)
     c                   leave
     c                   endif

650aAC                   if        sldesg='BFC'
650aAC                   iter
650aAC                   endif

     C                   eval      lbwhdp = slwhdp
     C                   eval      lbdisp = sldisp
650aAC                   leavesr
650aAC                   enddo
640mA*
640mA*      Default to warehouse dept from item.
640mAC*                  else
640mAC                   eval      lbwhdp = itwhdp
     C*                  endif

     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGTOD  Get order detail record. (with/without) record lock.
     *
     C     zzgtod        begsr
     *
     C                   select
     C                   when      rcdlck = *off
     C     od1key        chain(n)  ordd1                              75
     *
     C                   when      rcdlck = *on
     C     od1key        chain     ordd1                              75
     *
     C                   endsl
     *
640eD***  Order detail line item not found. Clear qty fields.
640eM*    Order detail line item not found, clear all fields.
     C                   if        *in75
640eDC**                 eval      odqor1 = *zeros
640eDC**                 eval      odqor2 = *zeros
640eDC**                 eval      odqor3 = *zeros
640eAC                   clear                   odrec1
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGTOM  Get order detail misc. file rcd. (with/without) record lock.
     *
     C     zzgtom        begsr
     *
     C                   select
     C                   when      rcdlck = *off
     C     omkey         chain(n)  orddm
     *
     C                   when      rcdlck = *on
     C     omkey         chain     orddm
     *
     C                   endsl
     *
     *    Order detail line item not found. Clear misc fields.
     C                   if        not %found(orddm)
     C                   eval      omodsc = ' '
     C                   eval      ompdsc = 'N'
     C                   eval      ompdsc = 'N'
     C                   eval      omrdsc = 'N'
     C                   eval      omcbox = 'N'
     C                   eval      omcexp = 'N'
     C                   eval      ommsc1 = ' '
     C                   eval      ommsc2 = ' '
     C                   eval      ommsc3 = ' '
     C                   eval      ommsc4 = ' '
     C                   eval      ommsc5 = ' '
     C                   endif
     *
     C                   endsr
640tA*
640tA*----------------------------------------------------------------
640tA*
640tA*  ZZGTOS  Get order detail pick slot record. (with) record lock.
640tA*
640tAC     zzgtos        begsr
640tA*
640tAC     oskey         chain     ordds
640tA*    Order detail line item not found. Clear qty fields.
640tAC                   if        not %found(ordds)
640tAC                   eval      osdisp = *blanks
640tAC                   eval      osbulk = 'N'
640tAC                   endif
640tA*
640tAC                   endsr
640tA*
     *----------------------------------------------------------------
640aA*
640aA*  ZZMISCD  Set flag on if miscellaneous order detail data exists.
640aA*
640aAC     zzMiscD       begsr
     *
     C                   eval      miscupdate = '*NO '
     *
     C                   if        oimdsc <> *blanks or
     C                             oimpds <> *blanks or
     C                             oimrds <> *blanks or
     C                             oimbox <> *blanks or
     C                             oimexp <> *blanks or
     C                             oimms1 <> *blanks or
     C                             oimms2 <> *blanks or
     C                             oimms3 <> *blanks or
     C                             oimms4 <> *blanks or
     C                             oimms5 <> *blanks
     C                   eval      miscupdate = '*YES'
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
640aA*  ZZMISCH  Set flag on if miscellaneous order header data exists.
640aA*
640aAC     zzMiscH       begsr
640aA*
     C                   eval      mischdrupd = '*NO '
     *
     C                   if        ohmms1 <> *blanks or
     C                             ohmms2 <> *blanks or
     C                             ohmms3 <> *blanks or
     C                             ohmms4 <> *blanks or
     C                             ohmms5 <> *blanks
     C                   eval      mischdrupd = '*YES'
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZXDCK  Attach cross dock item to PO detail line.
     *
     C     zzxdck        begsr
     *
     *    Retrieve Open item order detail line
     C                   if        mrgrte = *on  and
     C                             mrgord = *on
     C                   eval      rcdlck = *off
     C                   exsr      zzgtod
     C                   endif
     *
     *    If we find this item on an existing Open Order and the codes
     *    don't match or this is a cross dock item, force item to New
     *    Route, New Order.
     C                   if        mrgrte = *on  and
     C                             mrgord = *on  and
     C                             *in75  and
     C                             oidspc <> odspcl  or
     *
     C                             oidspc = 'XD'
     C                   eval      wrgsts = *on
     C                   endif
     *
     * Only work with cross dock items.
     C                   if        oidspc <> 'XD'
     C                   eval      good2 = 'Y'
     C                   goto      endxd
     C                   endif
530dA*
530dA* Create cross dock slot if it doesn't already exist.
530dA* Put allocated qty into slot.
530dAC                   exsr      zzcrxd
530dA*
530dD* Loop through P.O. detail records looking for item.
530dDC**   keypd1        setll     podtl1
530dDC**                 dow       forevr = forevr
530dDC**   keypd1        reade     podtl1                                 79
530dD* Error if none found.
530dDC**                 if        *in79
530dDC**                 eval      pdseq = 0
530dDC**                 eval      pdpo = oidpo
530dDC**                 endif
530dD* If cross dock slot record exists, update
530dDC**                 movel     'XDK'         kydisp
530dDC**   keysl4        setll     slot4
530dDC**                 dow       forevr = forevr
530dDC**                 read      slot4                                  79
530dDC**                 if        not *in79  and
530dDC**                           slstat = 'XD'  and
530dDC**                           slwhse = $pwhse  and
530dDC**                           slwhdp = itwhdp  and
530dDC**                           slitem = oiditm  and
530dDC**                           slaisl = 'XDK'
530dD* Pre-allocate product in case receiving is done before picking.
530dDC**                 add       oidq1         slalc1
530dDC**                 if        itflg1 = 'Y'
530dDC**                 add       oidq2         slalc2
530dDC**                 endif
530dDC**                 if        itflg2 = 'Y'
530dDC**                 add       oidq3         slalc3
530dDC**                 endif
530dDC**                 update    slrec4
530dDC**                 goto      addxdk
530dDC**                 else
530dDC**                 unlock    slot4
530dDC**                 leave
530dDC**                 endif
530dDC**                 enddo
530dD* Create cross dock slot record.
530dDC**                 eval      tmploc = 1
530dDC**                 eval      kyaisl = 'XDK'
530dDC**   keysl1        setll     slot1
530dDC**                 dow       forevr = forevr
530dDC**   keysl1        reade(n)  slot1                                  79
530dDC**                 if        *in79  or
530dDC**                           slloc > tmploc
530dDC**                 leave
530dDC**                 endif
530dDC**   slloc         add       1             tmploc
530dDC**                 enddo
     *
530dDC**                 clear                   slrec
530dDC**                 eval      slwhse = oidwhs
530dDC**                 eval      slwhdp = itwhdp
530dDC**                 eval      slaisl = 'XDK'
530dDC**                 eval      slloc = tmploc
530dDC**                 eval      slrlvl = 1
530dDC**                 eval      slhand = *blanks
530dDC**                 eval      slstyp = 'X'
530dDC**                 eval      slpseq = tmploc
530dDC**                 eval      slitem = oiditm
     *
530dDC**                 eval      slstat = oidspc
530dDC**                 eval      slsdte = today
530dDC**                 time                    slstim
530dDC**                 eval      slpick = 'N'
530dDC**                 eval      slrsrv = 'N'
530dD* Format display slot.
530dDC**                 call      'FRMTSL'
530dDC**                 parm                    slwhse
530dDC**                 parm                    slwhdp
530dDC**                 parm                    slaisl
530dDC**                 parm                    slloc
530dDC**                 parm                    slrlvl
530dDC**                 parm                    slhand
530dDC**                 parm                    slstyp
530dDC**                 parm                    slpseq
530dDC**                 parm                    sldisp
530dD* Pre-allocate product in case receiving is done before picking.
530dDC**                 eval      slalc1 = oidq1
530dDC**                 if        itflg1 = 'Y'
530dDC**                 z-add     oidq2         slalc2
530dDC**                 endif
530dDC**                 if        itflg2 = 'Y'
530dDC**                 z-add     oidq3         slalc3
530dDC**                 endif
530dD* Add record
530dDC**   slloc         div       2             dummy
530dDC**                 mvr                     slside
530dDC**                 if        slside < 0
530dDC**                 eval      slside = -(slside)
530dDC**                 endif
530dDC**                 write     slrec                                77
530dD* Error if slot not created.
530dDC**                 if        *in77
530dDC**                 eval      detmsg = desc(5)
530dDC**                 add       1             badpo
530dDC**                 leave
530dDC**                 endif
530dD* Create cross dock record.
530dDC**   addxdk        tag
530dDC**                 eval      cdwhse = slwhse
530dDC**                 eval      cdwhdp = slwhdp
530dDC**                 eval      cdslot = sldisp
530dDC**                 eval      cdord = ohord
530dDC**                 eval      cdorsq = oidseq
530dDC**                 eval      cdort# = 0
530dDC**                 eval      cdorl# = 0
530dDC**                 eval      cdpo = pdpo
530dDC**                 eval      cdposq = pdseq
530dDC**                 eval      cdpot# = 0
530dDC**                 eval      cdpol# = 0
530dDC**                 write     cdrec                                79
530dDC**                 if        *in79
530dDC**                 eval      detmsg = desc(6)
530dDC**                 add       1             badpo
530dDC**                 else
     C                   eval      good2 = 'Y'
530dDC**                 endif
530dDC**                 leave
530dDC**                 enddo
     *
     C     endxd         endsr
640eA*----------------------------------------------------------------
640eA*  ZZZCRTLABEL  Create label record.
640eA*----------------------------------------------------------------
640eA
640eAC     zzzcrtlabel   begsr
640eA

     C                   clear                   lbrec

     C                   exsr      zzgetdatetime

640gAC                   exsr      zzgetslot

     C                   eval      lbwhse = $pwhse
     C                   eval      lbseq  = oidseq
     C                   eval      lbitem = oiditm
     C                   eval      lbpbat = 0
     C                   eval      lbaisl = *blanks
     C                   eval      lbloc  = 0
     C                   eval      lbrlvl = 0
     C                   eval      lbhand = *blanks
     C                   eval      lbpseq = 0
     C                   eval      lbstyp = itstyp
     C                   eval      lbqavl = 0
     C                   eval      lbwhs2 = 0
     C                   eval      lbwhd2 = *blanks
     C                   eval      lbasl2 = *blanks
     C                   eval      lbloc2 = 0
     C                   eval      lblvl2 = 0
     C                   eval      lbhnd2 = *blanks
     C                   eval      lbdsp2 = *blanks
     C                   eval      lbrte  = rhrtid
     C                   eval      lbstop = ohstop
     C                   eval      lbord  = ohord
     C                   eval      lbspcl = *blanks
     C                   eval      lbpo   = *blanks
     C                   eval      lbucub = 0
     C                   eval      lbcube = 0
     C                   eval      lbuwgt = 0
     C                   eval      lbswgt = 0
     C                   eval      lbqrmn = 0
     C                   eval      lbtie  = 0
     C                   eval      lbhigh = 0
     C                   eval      lbgrp1 = 'S'
     C                   eval      lbgrp2 = rhtype
     C                   eval      lbtype = 'O'
     C                   eval      lbpal# = 0
     C                   eval      lbtrn# = @ptrn#
     C                   eval      lbctr# = 0
     C                   eval      lbstat = 'P'
     C                   eval      lbprty = 0
     C                   eval      lbsdte = curdate
     C                   eval      lbstim = curtime
     C                   eval      lbrdte = curdate
     C                   eval      lbvrfy = *blanks
     C                   eval      lbqpck = 0
     C                   if        lbstyp = 'P'
     C                   eval      lbqryf = 1
     C                   else
     C                   eval      lbqryf = 0
     C                   endif

     *  Create LABEL record for Normal quantity.

     C     odqor1        cable     0             brk1label

     C                   eval      lbqalc = odqor1
     C                   eval      lbutyp = 'N'
     C                   eval      lbucod = itum1
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   write     lbrec

     C     brk1label     tag

     *  Create LABEL record for Breakdown 1 quantity.

     C     odqor2        cable     0             brk2label

     C                   eval      lbqalc = odqor2
     C                   eval      lbutyp = '1'
     C                   eval      lbucod = itum2
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   write     lbrec

     C     brk2label     tag

     *  Create LABEL record for Breakdown 2 quantity.

     C     odqor3        cable     0             endCrtLabel

     C                   eval      lbqalc = odqor3
     C                   eval      lbutyp = '2'
     C                   eval      lbucod = itum3
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   write     lbrec

     C     endCrtLabel   endsr

640eA*----------------------------------------------------------------
640eA*  ZZZCRTTRAN   Create transaction
640eA*----------------------------------------------------------------
640eA
640eAC     zzzcrttran    begsr
640eA
     C                   call      'ADJTRAN2'
     C                   parm      '*CREATE'     @pcmd            10
     C                   parm      #prog         @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      0             @ptrn#            7 0
     C                   parm      'FIXED'       @ptask            6
     C                   parm      $pwhse        @pwhse            3 0
     C                   parm      ' '           @pwhdp            5
     C                   parm      ' '           @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      rhrte         @prte             5
     C                   parm      rhrtid        @ppo              9
     C                   parm      'S'           @pgrp1            1
     C                   parm      rhtype        @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
     C                   parm      #user         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr

     *----------------------------------------------------------------
CSP A*
CSP A*  ZZXDELJIT   Delete status 'Z' JIT slots
CSP A*
CSP AC     zzzDelJIT     begsr
CSP A
     C                   eval      kyaisl = 'JIT'
     C     keysl11       setll     slot11
     C                   dow       forevr = forevr
     C     keysl11       reade     slot11
     C                   if        %eof
     C                   leave
     C                   endif
     C                   if        slstat = 'Z'
     C                   delete    slrec11
     C                   endif
     C                   enddo

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZXDELXDK   Delete status 'Z' XDK slots
     *
     C     zzzDelXDK     begsr

     C                   eval      kyaisl = 'XDK'
     C     keysl11       setll     slot11
     C                   dow       forevr = forevr
     C     keysl11       reade     slot11
     C                   if        %eof
     C                   leave
     C                   endif
     C                   if        slstat = 'Z'
     C                   delete    slrec11
     *
     *      Delete matching record from Cross Dock file.
     C     cdkey         setll     crossdk
     C                   dow       forevr = forevr
     C     cdkey         reade     crossdk
     C                   if        %eof(crossdk)
     C                   leave
     C                   endif
     C
     C                   delete    cdrec
     C                   enddo
     *
     C                   endif
     C                   enddo

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZRHEAD   Print report headings.
     *
     C     zrhead        begsr
     *
     C                   if        count >= linppg
     C                   seton                                        81
     C                   eval      count = 0
     C                   write     head1
     C                   add       3             count
     C                   write     head2
     C                   add       2             count
     C                   write     head3
     C                   add       2             count
     C                   write     head4
     C                   add       2             count
     C                   setoff                                       81
     C                   endif
     *
     C                   endsr
640eA*----------------------------------------------------------------
640eA*  zzzdriclose   Close any open files or programs.
640eA*----------------------------------------------------------------
640eA
640eAC     zzzdriclose   begsr
640eA
640eA*  Close interfaces
640eA
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*XDOCK'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*LICINFO'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*LICHIST'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*LICENSE'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      chk4err = *off
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C                   endsr

     *----------------------------------------------------------------
530dA*  zzzdricop  Call DRICOP
530dA*----------------------------------------------------------------
530dA
530dAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*XDOCK'
     C                   eval      $dridata = $xdock
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
     C                   when      $dricommand = '*LICHIST'
     C                   eval      $dridata = $lichist
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $dridata = $license
     C                   eval      $dridata2 = $license2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                             or $dricommand = '*LICENSE'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      %error and ck4err = *on
     C                   eval      error = *on

     C                   when      $drireturn <> '*OK' and ck4err = *on
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*XDOCK'
     C                   eval      $xdock = $dridata
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
     C                   when      $dricommand = '*LICHIST'
     C                   eval      $lichist = $dridata
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $license = $dridata
     C                   eval      $license2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C     enddricop     endsr

640eA*----------------------------------------------------------------
640eA*
640eA*  zzzLblPck  Get total picked for normal, breakdown 1, and
640eA*             breakdown 2.
640eA*
640eAC     zzzLblPck     begsr
640eA*
     C                   eval      pick1 = 0
     C                   eval      pick2 = 0
     C                   eval      pick3 = 0
     *
     C/exec sql
     C+  select sum(lbqpck) into :pick1
     C+  from   label
640sDC*  where  lbwhse = :$pwhse and lbrte = :oihrteid and
640sMC+  where  lbwhse = :$pwhse and lbrte = :rhrtid and
     C+         lbord  = :odord  and lbseq = :odseq and
     C+         lbutyp = 'N'
     C/end-exec
     *
     C/exec sql
     C+  select sum(lbqpck) into :pick2
     C+  from   label
640sDC*  where  lbwhse = :$pwhse and lbrte = :oihrteid and
640sMC+  where  lbwhse = :$pwhse and lbrte = :rhrtid and
     C+         lbord  = :odord  and lbseq = :odseq and
     C+         lbutyp = '1'
     C/end-exec
     *
     C/exec sql
     C+  select sum(lbqpck) into :pick3
     C+  from   label
640sDC*  where  lbwhse = :$pwhse and lbrte = :oihrteid and
640sMC+  where  lbwhse = :$pwhse and lbrte = :rhrtid and
     C+         lbord  = :odord  and lbseq = :odseq and
     C+         lbutyp = '2'
     C/end-exec
     *
     C                   endsr
640eA*----------------------------------------------------------------
640eA*
640eA*  zzzLblDel  Delete label records.
640eA*
640eAC     zzzLblDel     begsr
640eA*
     C/exec sql
     C+  delete
     C+  from   label
640jDC** where  lbwhse = :$pwhse and lbrte = :oihrteid and
640jDC**        lbord  = :odord  and lbseq = :odseq
640jMC+  where  lbwhse = :$pwhse and lbrte = :rhrtid and
640jMC+         lbord  = :odord  and lbseq = :odseq
     C/end-exec
     *
     C                   endsr
640eA*----------------------------------------------------------------
640eA*
640eA*  zzzLblUpdQ_I  Update quantity allocated in LABEL record.
640eA*                Update item if it changed.
640eA*
640eAC     zzzLblUpdQ_I  begsr
640eA*
     C                   select
     C                   when      qty1flag = *on
     C                   eval      hldqor = oidq1
     C                   when      qty2flag = *on
     C                   eval      hldqor = oidq2
     C                   when      qty3flag = *on
     C                   eval      hldqor = oidq3
     C                   endsl

640fAC                   eval      lblFound = *off

640iAC     keylab93      setll     label93
640iDC**   keylab93      reade (e) label93
     C                   dow       forevr = forevr
640hDC**   keylab93      reade     label93
640hMC     keylab93      reade (e) label93
     C                   if        %eof
     C                   leave
     C                   endif
640hA*
640hAC                   if        %error()
640hA*      Bypass locked records.
640hAC                   if        %status(label93) = 1218
640iDC**                 iter
640iAC                   leavesr
640hAC                   endif
640hAC                   endif

640fAC                   eval      lblFound = *on

     C                   if        qty1flag = *on or
     C                             qty2flag = *on or
     C                             qty3flag = *on
     C                   eval      lbqalc = hldqor
     C                   endif
     *
     C                   if        lbitem <> oiditm
     C                   eval      lbitem = oiditm
640uAC                   exsr      zzgetslot
     C                   endif
     C                   update    lbrec93
     C                   unlock    label93
640vDC**                 leave
     *
     C                   enddo

640fA*  Create label if none found.
640fA
640fAC                   if        lblFound = *off
640fAC                   exsr      zzzCrtLabel
640fAC                   endif
     *
     C                   endsr
640eA*----------------------------------------------------------------
640eA*
640eA*  zzzLblUpdZero  Process label records when corresponding staging
640eA*                 record is not found.
640eA*
640eA*                 Zero qty alloc in label record when qty picked > 0.
640eA*
640eAC     zzzLblUpdZero begsr
640eA*
     c                   if        pick1 > 0
     c/exec sql
     c+ update label set lbqalc = 0
640sDC*  where  lbwhse = :$pwhse and lbrte = :oihrteid and
640sMC+  where  lbwhse = :$pwhse and lbrte = :rhrtid and
     C+         lbord  = :odord  and lbseq = :odseq and
     C+         lbutyp = 'N'
     c/end-exec
     c                   endif
     *
     c                   if        pick2 > 0
     c/exec sql
     c+ update label set lbqalc = 0
640sDC*  where  lbwhse = :$pwhse and lbrte = :oihrteid and
640sMC+  where  lbwhse = :$pwhse and lbrte = :rhrtid and
     C+         lbord  = :odord  and lbseq = :odseq and
     C+         lbutyp = '1'
     c/end-exec
     c                   endif
     *
     c                   if        pick3 > 0
     c/exec sql
     c+ update label set lbqalc = 0
640sDC*  where  lbwhse = :$pwhse and lbrte = :oihrteid and
640sMC+  where  lbwhse = :$pwhse and lbrte = :rhrtid and
     C+         lbord  = :odord  and lbseq = :odseq and
     C+         lbutyp = '2'
     c/end-exec
     c                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
640eA*
640eA*  ZZZLOOPORDD  Loop through ORDD recs for this order and compare
640eA*               to staging file for possible update or delete of
640eA*               ORDD and LABEL records.
640eA*
640eAC     zzzloopordd   begsr
640eA*
     *    If a corresponding staging record is not found :
     *       a. If nothing has been picked, delete the ORDD record and
     *          its LABEL record/s.
     *       b. If qty has been picked, then set the ordered qty to
     *          zero in the ORDD record and set qty alloc to zero
     *          in the LABEL record/s.
     *
     C     odkeyStg      setll     ordd1
     C                   dow       forevr = forevr
     C     odkeyStg      reade     ordd1
     C                   if        %eof(ordd1)
     C                   leave
     C                   endif
     *
     C     impsdkey      chain     impsordd
     C                   if        %found(impsordd)
     C                   iter
     C                   endif
     *
     *   Update or delete the ORDD record and its LABEL record/s.
     *
     C                   exsr      zzzLblPck
     C                   if        pick1=0 and pick2=0 and pick3=0
     C                   exsr      zzzLblDel
     C                   else
     C                   exsr      zzzLblUpdZero
     C                   endif
     *
     C                   if        pick1=0 and pick2=0 and pick3=0
     C                   delete    odrec1
     C                   else
     C                   eval      odqor1 = 0
     C                   eval      odqor2 = 0
     C                   eval      odqor3 = 0
     C                   update    odrec1
     C                   endif
     *
     C                   enddo
     *
     C                   endsr
     *
640eA*----------------------------------------------------------------
640eA*
640eA*  ZZZSETQTYFLAG  Determine which qty is being changed :
640eA*                 normal, breakdown 1, or breakdown 2.
640eA*                 Set corresponding qty flag to know which
640eA*                 qty to output to qty aloc in LABEL record.
640eA*
640eAC     zzzSetQtyFlag begsr
640eA*
     C                   eval      qty1flag = *off
     C                   eval      qty2flag = *off
     C                   eval      qty3flag = *off
     *
     C                   select
     C                   when      oidq1 <> odqor1
     C                   eval      qty1flag = *on
     C                   when      oidq2 <> odqor2
     C                   eval      qty2flag = *on
     C                   when      oidq3 <> odqor3
     C                   eval      qty3flag = *on
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
530dA*     ZZZS2D - Copy slot fields into data structure fields.
530dA*
530dAC     zzzs2d        begsr
530dA*
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse = slwhse
     *
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp = slwhdp
     *
     C                   eval      $sldispu = *on
     C                   eval      $sldisp = sldisp
     *
     C                   eval      $slaislu = *on
     C                   eval      $slaisl = slaisl
     *
     C                   eval      $sllocu = *on
     C                   eval      $slloc = slloc
     *
     C                   eval      $slrlvlu = *on
     C                   eval      $slrlvl = slrlvl
     *
     C                   eval      $slhandu = *on
     C                   eval      $slhand = slhand
     *
     C                   eval      $slsideu = *off
     C                   eval      $slside = slside
     *
     C                   eval      $slstypu = *off
     C                   eval      $slstyp = slstyp
     *
     C                   eval      $slstatu = *off
     C                   eval      $slstat = slstat
     *
     C                   eval      $slsdteu = *off
     C                   eval      $slsdte = slsdte
     *
     C                   eval      $slstimu = *off
     C                   eval      $slstim = slstim
     *
     C                   eval      $slsdefu = *off
     C                   eval      $slsdef = slsdef
     *
     C                   eval      $sldesgu = *off
     C                   eval      $sldesg = sldesg
     *
     C                   eval      $slactvu = *off
     C                   eval      $slactv = slactv
     *
     C                   eval      $slbldu = *off
     C                   eval      $slbld = slbld
     *
     C                   eval      $slpicku = *off
     C                   eval      $slpick = slpick
     *
     C                   eval      $slpsequ = *off
     C                   eval      $slpseq = slpseq
     *
     C                   eval      $slprtyu = *off
     C                   eval      $slprty = slprty
     *
     C                   eval      $slentdu = *off
     C                   eval      $slentd = slentd
     *
     C                   eval      $slexpdu = *off
     C                   eval      $slexpd = slexpd
     *
     C                   eval      $slslfdu = *off
     C                   eval      $slslfd = slslfd
     *
     C                   eval      $slrsrvu = *off
     C                   eval      $slrsrv = slrsrv
     *
     C                   eval      $slitemu = *off
     C                   eval      $slitem = slitem
     *
     C                   eval      $slstk1 = slstk1
     C                   eval      $slstk2 = slstk2
     C                   eval      $slstk3 = slstk3
     C                   eval      $slalc1 = slalc1
     C                   eval      $slalc2 = slalc2
     C                   eval      $slalc3 = slalc3
     C                   eval      $sltfr1 = sltfr1
     C                   eval      $sltfr2 = sltfr2
     C                   eval      $sltfr3 = sltfr3
     C                   eval      $slpck1 = slpck1
     C                   eval      $slpck2 = slpck2
     C                   eval      $slpck3 = slpck3
     C                   eval      $slrcv1 = slrcv1
     C                   eval      $slrcv2 = slrcv2
     C                   eval      $slrcv3 = slrcv3
     C                   eval      $slphy1 = 0
     C                   eval      $slphy2 = 0
     C                   eval      $slphy3 = 0
     C                   eval      $slavl1 = 0
     C                   eval      $slavl2 = 0
     C                   eval      $slavl3 = 0
     C                   eval      $sladj1 = 0
     C                   eval      $sladj2 = 0
     C                   eval      $sladj3 = 0
     *
     C                   eval      $saitemu = *off
     C                   eval      $saitem = *blanks
     *
     C                   eval      $saqtyu = *off
     C                   eval      $saqty1 = 0
     C                   eval      $saqty2 = 0
     C                   eval      $saqty3 = 0
     *
     C                   eval      $saorgu = *off
     C                   eval      $saorg1 = 0
     C                   eval      $saorg2 = 0
     C                   eval      $saorg3 = 0
     *
     C                   eval      $sacwtau = *off
     C                   eval      $sacwta = 0
     *
     C                   eval      $sacodeu = *off
     C                   eval      $sacode = *blanks
     *
     C                   eval      $samemou = *off
     C                   eval      $samemo = *blanks
     *
     C                   eval      $sabyu = *off
     C                   eval      $saby = *blanks
     *
     C                   eval      $sadateu = *off
     C                   eval      $sadate = 0
     *
     C                   eval      $satimeu = *off
     C                   eval      $satime = 0
     *
     C                   eval      $saFrmVrfyu = *off
     C                   eval      $saFrmVrfy = *blanks
     *
     C                   eval      $satrn#u = *off
     C                   eval      $satrn# = 0
     *
     C                   eval      $saFrmLcnsu = *off
     C                   eval      $saFrmLcns = *blanks
     *
     C                   eval      $satasku = *off
     C                   eval      $satask = *blanks
     *
     C                   eval      $sacdspu = *off
     C                   eval      $sacdsp = *blanks
     *
     C                   endsr
EFCaA*----------------------------------------------------------------
EFCaA*  ZZZUNPCKDEL  Unpick and delete route.
EFCaA*
EFCaAC     zzzUnpckDel   begsr
EFCaA*
     *    Check If any transactions have been scanned or started.
     *
     C                   eval      kygrp2 = 'S'
     C                   movel     rhrtid        kyrtpo
     C                   eval      trnflg = *off
     C     trnsky        setll     pirtran4
     C                   dow       forevr = forevr
     C     trnsky        reade     pirtran4                               79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   if        ptgrp1 <> 'S'
     C                   iter
     C                   endif
     C                   if        ptstat <> '1'
     C                   eval      trnflg = *on
     C                   leave
     C                   endif
     C                   iter
     C                   enddo
     *  If any transactions have been started, do not unpick.
     C                   if        trnflg = *on
     C                   eval      hedmsg = desc(9)
     C                   goto      endUnpckDel
     C                   endif

     *  Everything ok, undo the route.
     C                   exsr      inzpar
     C                   call      @unpckpg
     C                   parm                    $parms
     *     Error occured - Error message sent back
     C                   if        $prtn = '*ERROR  '
     C                             or $prtn = '*PGMQ   '
     C                   eval      hedmsg = desc(9)
     C                   goto      endUnpckDel
     C                   endif
     *
     *  Route unpicked, now delete it.
     C                   call      @delpg
     C                   parm                    $parms
     *     Error occured - Error message sent back
     C                   if        $prtn = '*ERROR  '
     C                             or $prtn = '*PGMQ   '
     C                   eval      hedmsg = desc(9)
     C                   endif
     *
     C     endUnpckDel   endsr
640aA*----------------------------------------------------------------
640aA*  zzzEnd     End processing
640aA*----------------------------------------------------------------
640aA
640aAc     zzzEnd        begsr
      /free

        if importError;
          sbstatus = 'E';
          sbtext   = 'Import completed with error(s). See '
                    + %trimr(filnam)
                    + ' file.';
          $pReturn = '*ERROR';
          $pMessage = sbtext;
          filnam   = *blanks;
        else;
          sbstatus = 'S';
          sbtext   = 'Import completed successfully';
        endif;

        exec sql
          update stgbatch
          set sbstatus = :sbstatus,
              sbtext   = :sbtext,
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone,
              sbendts  = current_timestamp,
              sbenduc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :$pBatId;

        if sqlstt <> sqlSuccess;
          $pReturn = '*SIUPDERR';
          $pMessage = %trimr(sbtext) + ' - '
                    + 'Error updating STGBATCH file for '
                    + 'batch id ' + %trim($pBatId) + ' '
                    + '- SQLSTT ' + sqlstt + ' '
                    + '- oi286s/zzzend';
          leavesr;
        endif;

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
640aA*  zzzStart   Start processing
640aA*----------------------------------------------------------------
640aA
640aAc     zzzStart      begsr
      /free

        exec sql
          update stgbatch
          set sbstatus = 'P',
              sbtext   = 'Import started',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone,
              sbstrts  = current_timestamp,
              sbstruc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :$pBatId;

        if sqlstt <> sqlSuccess;
          $pReturn = '*SIUPDERR';
          $pMessage = 'Error updating STGBATCH file for '
                    + 'batch id ' + %trim($pBatId) + ' '
                    + '- SQLSTT ' + sqlstt + ' '
                    + '- oi286s/zzzstart';
          leavesr;
        endif;

        importError = *off;

      /end-free
     c                   endsr

EFCaA*----------------------------------------------------------------
EFCaA*
EFCaA*  zzzTotPck  Get total picked for entire route.
EFCaA*
EFCaAC     zzzTotPck     begsr
EFCaA*
     C                   eval      totpck = 0
     *
     C/exec sql
     C+  select sum(lbqpck) into :totpck
     C+  from   label
     C+  where  lbwhse = :$pwhse and lbrte = :rhrtid
     C/end-exec
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
**
*EXIST*
*INVALID ITEM*
*BREAKDOWN INVALID*
*INVALID X-DOCK PO*
*XDK SLOT ERROR*
*NO XDK REC CREATED*
*QTY ORDERED PICKED*
*ORD ALREADY CLOSED*
*ERROR,CAN'T DELETE*
**
Import FTP Orders
**   OVRPRTF statment
OVRPRTF FILE(OI2861PR)           OUTQ(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
OVRPRTF FILE(OI286PR)           OUTQ(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
