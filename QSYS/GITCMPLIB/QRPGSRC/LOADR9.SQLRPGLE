     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2004')
     H OPTION(*NODEBUGIO)
     F*----------------------------------------------------------------
     F*   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     F*   West Chicago, IL  60185
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  LOADR9    RF Loader Module - Pallet Loading / Unloading
     F*            11 X 20 Screens for hand held scanners
     F*
     F*  December 4, 2006
     F*  Jose G. Duque
     F*
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    07/02/08  RBD  5.20   P#00060
     *      - Right adjust route and use the last 2 chars for
     *        comparison to route from the route/pallet id combo
     *        field on the pallet label.  Because some clients use
     *        2 chars for route, some use 3, etc, this logic won't
     *        care, it will simply use the last 2 chars. The same
     *        logic should be used in PFMT when building the combo
     *        route/pallet id field which prints on the pallet label.
     *
520aA*    07/10/08  RBD  5.20a   P#00060
     *      - Enh: Added client custom code support to program.
     *
520bA*    02/24/09  RBD  5.20b
     *      - Enh: Added route id for scanning on screen1.  User will
     *        now have the option to enter the route or scan the route
     *        id.
     *
530 A*    11/24/09  RBD  5.30
     *      - Enh: Added screen4 for UNLOADING pallets.
     *        Changed format name LOADR9FM to LOADR901.
     *
530aA*    01/22/10  RBD  5.30a
     *      - Fix: Change chains to LDRHDR3 to chain(N) to prevent
     *        record lock.
     *
530bA*    01/22/10  RBD  5.30b
     *      - Enh: Create a new LOAD transaction record for each
     *        pallet loaded.
     *
530cA*    02/09/10  RBD  5.30c
     *      - Fix: Changed key for pallet counters, added route id.
     *
530dA*    06/24/10  RBD  5.30d
     *      - Fix: Recompiled for scrn chgs, trailer id's changed
     *        from 6 bytes to 8.
     *
530eA*    06/25/10  JCJ  5.30e
     *      - Fix: change program to use route id instead of route
     *        to get the 2 char piece of pallet id in ZZCHK3.
530fA*    07/08/10  RH   5.30f
     *      - Enh: Display dock door assinged in truck builder.
530gA*    07/14/10  RH   5.30g
     *      - Fix: Edit scanned pallet id for unload, remove first
     *        2 postions (hold last 2 char of Route ID.)
     *
530hA*    07/26/10  RBD  5.30h
     *      - Fix: If user enters route, rather than route id, on
     *        screen1, check to see if more than 1 current loader
     *        module route exists for the route entered, if so,
     *        require the user to enter the route id rather than
     *        the route.  FYI, add-on routes create the situation
     *        where there are multiple LDRHDR recs with the same
     *        route # but different route id's.
     *        Use DTKEY5 instead of HDKEY where route id is needed.
     *        Change DTKEY2 to include route id.
     *
     *    02/17/11  JGD  6.40
     *      - Enh: Revised the error message logic to provide the
     *      - Enh: trailer # in the event that the user scan the
     *      - Enh: wrong one. Change Dspf name to Loadr902.
640aA*    06/05/12  LMC  6.40a
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
640bA*    06/19/12  RH   640b
     *      - Disable trailer equipment requirements.  For the time
     *        being, no client will enter or track any trailer equip.
     *        Will change to table driven in future.
650aA*    05/15/13  RBD  650a
     *      - Changed format name to LOADR903.
     *      - Removed F9 logic, ability to do add ons no longer
     *        needed, route id negates duplicated pallet id's.
650bA*    05/28/13  RBD  6.50b
     *      - Fix: In zzupd2 use new key hdkey4 to retrieve loader header
     *        with saved route and route id retrieved from screen 1.
     *        Without this fix, if no trailer was assigned and user
     *        entered a trailer already assigned to another route,
     *        then entered a valid trailer, the key in zzupd2 contained
     *        the route and route id for the trailer already assigned.
650cA*    11/13/13  RH   650c
     *      - Additional code to disable trailer eq, missed in 640b
650dA*    01/15/14  RBD  6.50d
     *      - Enh: Added add-on route functionality by changing logic to
     *        allow a trailer to be assigned to multiple routes if the
     *        routes are all part of the same parent/child merge in the
     *        Trax merge file. Client does not have to be a Trax user.
     *      - Commented out trailer edit in zzchk2, using zztrlr instead.
650eA*    08/18/14  RBD  6.50e
     *      - Changed format name to LOADR904.
     *      - Increased size of entry field which holds the barcode scanned
     *        on the pallet label. Previously it was the last 2 char of
     *        route id + pallet id, now it's the full route id + pallet id.
     *        We're making this change because Coastal has more than 100
     *        trucks, which means we need more than the last 2 char of
     *        route id to ensure the barcode is unique for the day's routes.
     *        By using the full route id + pallet id we can be sure the
     *        combo field will always be unique, thus making it as fail safe
     *        as possible that the pallet gets loaded onto the right truck.
650fA*    10/03/14  RBD  6.50f
     *      - When a trailer is assigned, look for parent or child routes
     *        (add-ons) that are associated with this route and update
     *        their trailer in loader header too. Keep in mind that only
     *        routes which are at printed status or higher will exist
     *        in the loader header file.
650gA*    01/20/15  RBD  6.50g
     *      - Recompiled, LDRDETL and LDRDTLBK files changed.
650hA*    03/06/15  RBD  6.50h
     *      - Changed format name to LOADR905.
     *      - Enh: If new option OPVFYP "Verify pallet label against
     *        pick label" is Y require user to scan the Trax barcode
     *        from any pick label on the pallet, then go to ORDP to
     *        get the label#, then go to LABEL to compare the label's
     *        route id and pallet id to the pallet label and if they
     *        don't match throw an error.
     *
700aA*    07/14/15  NLK  7.00a
     *      - Changed format name to LOADR906.
     *      - w4plt# length from 7 to 10 on scrn
     *
700bA*    10/28/15  MLB  7.00b
     *      - Fix: Revised routine, ZZTRLR to not flag an error
     *        when w1rte = LHRTE and w1rtid <> lhrtid.
     *
700cA*    11/16/15  RBD  7.00c
     *      - Changed format name to LOADR907.
     *      - Reinstated F9 function (rev 650a) per Cheney's request.
     *
700dA*    02/02/16  RBD  7.00d
     *      - Changed format name to LOADR908.
     *      - Changed length of route id on screen1 from 5 to 10 in case
     *        the user wants to scan the route id/pallet barcode on
     *        the BIG pallet label.
     *      - Allow loader to scan all pallets for routes which are
     *        merged together after scanning only one of the route id's.
     *
700eA*    02/12/16  RBD  7.00e
     *      - Fix %subst of route id/pallet, should use %editc so it
     *        doesn't zero suppress route id, rather than %char which
     *        does zero suppress.
     *      - Wait until all pallets of an add-on route are loaded
     *        before updating to ended status.
     *
700fA*    08/23/16  RBD  7.00f
     *      - Fix: update add-on routes with the same start and close
     *        date and times as the route id being started or closed.
     *
700gA*    09/07/16  RBD  7.00g
     *      - If "verify pallet label" option is Y make sure there's at
     *        least 1 label record for the pallet that hasn't been shorted,
     *        otherwise don't ask the user to scan a pick label because
     *        there won't be one to scan.
     *      - Swapped out *in95 for opvfyp value for better readability.
     *        Don't remember why I used *in95 in the first place.
     *
710aA*    01/19/17  RBD  7.10a
     *      - Rewrote logic for writing LOAD transactions, will now use
     *        ADJTRAN2, plus write IDLE transactions.  No longer use subr's
     *        zzCrtTrn and zzWrtTrand.
     *
710bA*    04/05/17  RBD  7.10b
     *      - Don't allow pallet to be loaded if trans hasn't been started.
     *
710cA*    07/17/17  RBD  7.10c
     *      - Add "verify pallet label" logic for merge labels ... before
     *        if the loader scanned a merge label it threw an error.
     *
710dA*    10/12/17  RBD  7.10d
     *      - Changed format name to LOADR909.
     *      - Added F2=LoadEq.
     *
720aA*    06/27/18  RBD  7.20a
     *      - Added logic to 710b rev for bulk pick labels, must get
     *        corresponding label (lbctr#) and then get and use its
     *        trans# to see if it's been started.
     *
720bA*    08/07/18  RBD  7.20b
     *      - Changed format name to LOADR910.
     *
720cA*    07/19/18  RBD  7.20c
     *      - Fix: Rev 720a referenced l13_ field, shoulda been l31_.
     *
720dA*    08/24/18  DAS  7.20d
     *      - Revised how pallet generation is checked. DD2 may use
     *        generations greater than 3.
     *      - Added subroutine GetGenInfo and gGen fields to go with it.
     *
730aA*    01/21/19  DAS  7.30a
     *      - Revised to prevent closing transaction if open order
     *        audit exists.
     *
730b *    06/12/19  GJA  7.30b
     *      - Fix:  Don't check for trailer clean/dirty question if
     *        *in66 is off
     *
730c *    07/22/19  RBD  7.30c
     *      - Fix:  Extend 730b fix to include w2lodq edit check.
     *
730d *    12/09/19  RBD  7.30d
     *      - Added client loc parm to GETCLIENT call, needed for CBIe.
     *
740a *    01/27/20  RBD  7.40a
     *      - Fix: if screen1 route is part of an add on group ensure
     *        the pallet scanned on screen3 is part of that same group.
740bA*    07/30/20  MLB  7.40b
     *      - Fix: Revised routine ZZCHK4 to not lock LDRDETL. Was
     *        causing record lock errors when using Unload Truck option.
     *        Found at Kohl Wholesale.
     *
740cA*    09/02/20  RBD  7.40c
     *      - Changed format name to LOADR911.
     *      - Changed pallet barcode scan from 10 pos to 9 to avoid potential
     *        conflict with Trax# barcode which is 10 pos. The pallet barcode
     *        will now consist of last 4 of route id + last 5 of pallet.
     *      - Reversed 700d rev, go back to 5 pos route id on screen1. Must
     *        go back to scanning route id barcode rather than having the
     *        option to scan the big pallet label barcode which consisted of
     *        route id and pallet.
     *      - Move transaction status check further down in zzchk3, should
     *        verify the pallet first.
     *
750a *    05/16/21  RBD  7.50a
     *      - Fix:  Revise 740c mod to go get full rtid when route is
     *        scanned rather than route id.
     *
750b *    03/18/22  RBD  7.50b
     *      - Fix:  Now that pallet barcode only contains pos 2-5 of
     *        route id we need to edit those positions when pallet
     *        barcode is scanned to ensure they match 2-5 of route id.
     *        Found this at SWT, was erroneously saying pallet already
     *        loaded when pallet barcode for different route was scanned
     *        and the last value in ldendd was not zero. Now the correct
     *        error, desc(30) will appear.
     *
760a *    04/21/22  RBD  7.60a
     *      - Reserved.
     *
760b *    05/02/22  RBD  7.60b
     *      - Reserved.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney
     *
CBI A*    07/11/08  RBD  CBI     P#00060
     *      - Coded "breakers" and merged pallet logic as specific
     *        to Cheney.
     *
CBIaA*    02/24/09  RBD  CBIa
     *      - Screen1, position cursor on route, rather than rte id.
     *
CBIbA*    10/09/15  JCJ  CBIb
     *      - Limit trailer assignment to one.
CBIcA*    02/01/16  RBD  CBIc
     *      - Reverse 640b change for Cheney, thus reinstating call
     *        to LOADR21 if Cheney.
     *      - Add FRZPIR to merged zones processing.
     *
CBIdA*    08/07/18  RBD  CBId
     *      - Added LDRDCOM questions per Keith Sanders.
     *        Used PIRMODSCBI/LOADR9 rev 3/16/09 CBI as base.
     *
CBIeA*    12/09/19  RBD  CBIe
     *      - Added zones CF-GWB and GWBFRZ to hardcoded merge
     *        zones for Cheney/Punta Gorda per Keith and Tam.
     *
CBIfA*    01/23/20  RBD  CBIf
     *      - Add CF-GWB to merged zones processing.
     *
CBIgA*    10/01/18  TDF  CBIg  Work List 2018166
     *      - Trailer type must be TRAILR.
CBIhA*    02/20/20  RBD  CBIh
     *      - Added zone FREE to hardcoded merge zones for Statesville
     *        per Keith and Tam.
CBIiA*    04/16/20  NLK  CBIi     2020045
     *      - Added zone FRZMT to hardcoded merge zones for Goldsboro
     *        per Keith and Tam.
CBIjA*    07/14/20  NLK  CBIJ (was CBIh)
     *      - zzCHK2 moved CBIb code and removed part of CBId code
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Line
     *
CLD A*    07/11/08  RBD  CLD     P#00060
     *      - Added logic to require pallet loading in pallet id seq.
     *
CLDaA*    11/04/08  RBD  CLDa
     *      - Disable trailer equipment requirements.  For the time
     *        being, City Line does not want to enter or track any
     *        trailer equipment.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Halsey
     *
HSY A*    04/27/10  RH   HSY
     *      - Added logic to require pallet loading in pallet id seq.
     *      - Added to CLD mod
HSYaA*    04/27/10  RH   HSYa
     *      - Disable trailer equipment requirements.  For the time
     *        being, Halsey does not want to enter or track any
     *        trailer equipment.
     *      - Added to CLD mod
HSYbA*    06/07/10  RBD  HSYb
     *      - Added logic to require pallet loading in column seq,
     *        thereby reversing rev HSY.
     *      - Added new lf LDRDETL1.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jordanos
JORaA*    09/16/10  RH   JORa
     *      - Disable trailer equipment requirements.  For the time
     *        being, Jordanos does not want to enter or track any
     *        trailer equipment.
     *      - Added to CLD mod
     *----------------------------------------------------------------
     *  Client Custom Revisions: Royal
RYLaA*    07/09/10  RH   RYLa
     *      - Disable trailer equipment requirements.  For the time
     *        being, Halsey does not want to enter or track any
     *        trailer equipment.
     *      - Added to CLD mod
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal
     *
CSP A*    08/18/14  RBD  CSP
     *      - Added logic to require pallet loading in pallet id seq.
     *
CSPaA*    08/25/16  RBD  CSPa
     *      - Reverse mod CSP, allow pallets to be loaded in any order.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Presto Foods
     *
PFCaA*    03/28/22  RBD  PFCa
     *      - Added logic to require pallet loading in column/pallet seq.
     *        This differs from HSYb in that HSYb requires all of the
     *        first column be loaded before the second column can begin
     *        being loaded, etc.
     *        PFCa allows pallets from any column to be loaded, as long as
     *        lower pallets in the same column are already loaded.
     *
     *----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  01 - 20   FIELD POSITION TO
     F*  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     F*  90        VIEW MODE (PROTECT INPUT FIELDS)
     F*  91        CHANGE MODE (PROTECT KEY)
     F*  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     F*  98        ERROR ON SCREEN (SOUND BUZZER)
     F*  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
530 DF*OADR9FM  CF   E             WORKSTN
650aDF*OADR902  CF   E             WORKSTN
650eDF*OADR903  CF   E             WORKSTN
650hDF*LOADR904  CF   E             WORKSTN
700aDF*OADR905  CF   E             WORKSTN
700aDF*OADR906  CF   E             WORKSTN
700dDF*LOADR907  CF   E             WORKSTN
710dDF*LOADR908  CF   E             WORKSTN
720bDF*LOADR909  CF   E             WORKSTN
740cDF*LOADR910  CF   E             WORKSTN
740cMFLOADR911  CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(MSGREC:MSGK)
     FEQUIP     IF   E           K DISK
     FLDRHDR2   IF   E           K DISK
     F                                     RENAME(LHREC:LHREC2)
520bAFLDRHDR3   UF   E           K DISK
520bAF                                     RENAME(LHREC:LHREC3)
     FRTEHED    IF   E           K DISK
     FORDH1     IF   E           K DISK
     FPIRUSER   IF   E           K DISK
700cMFLABEL90   IF   E           K DISK    rename(lbrec:lbrec90)
700gAFLABEL13   IF   E           K DISK    rename(lbrec:lbrec13)
700gAf                                     prefix(l13_)
710cAFLABEL11   IF   E           K DISK    rename(lbrec:lbrec11)
710cAf                                     prefix(l11_)
720aAFLABEL31   IF   E           K DISK    prefix(l31_)
     FLDRPLTQ   IF   E           K DISK
710bDF*PLTSUM1   IF   E           K DISK
710bMFPLTSUM15  IF   E           K DISK
     FLDRTEQ    IF   E           K DISK
     F*
     FLDRHDR    UF   E           K DISK
     FLDRDETL   UF   E           K DISK
HSYbAFLDRDETL1  UF   E           K DISK    rename(lddrec:lddrec1)
530 AFLDRDTLBK  IF   E           K DISK
710bDF*pirtran   o  a e           k disk
710bMFpirtran   if   e           k disk
530bAFtask      if   e           k disk
530fAFDocmtrx2  if   e           k disk
650dAFttmerg    if   e           k disk
700dAFttmerg1   if   e           k disk
650dAFttmerg2   if   e           k disk    rename(ttmrec:ttmrec2)
650hAFlabel     if   e           k disk
650hAFoptions   if   e           k disk
650hAFordp      if   e           k disk
CBIbAFldrhhdr2  if   e           k disk
700gAFrunner6   if   e           k disk
CBIdAFLDRHCOM   O    E           K DISK
CBIdAFLDRDCOM   O    E           K DISK
     *----------------------------------------------------------------
520aA*  Client ID's
520aA*
CBI A /copy qcopysrc,id#cheney
CBIeA /copy qcopysrc,id#cheneyp
CBIfA /copy qcopysrc,id#cheneyr
CLD A /copy qcopysrc,id#citylin
HSY A /copy qcopysrc,id#halsey
RYL A /copy qcopysrc,id#royal
JOR A /copy qcopysrc,id#jordano
VIP A /copy qcopysrc,id#vip
CSP A /copy qcopysrc,id#coastal
PFCaA /copy qcopysrc,id#pfc
520aA*
520aAD @getcl          c                   const('GETCLIENT')
     *
650hA*----------------------------------------------------------------
650hA*  *LOADER  -  Loader options
650hA*----------------------------------------------------------------
650hA*
650hA* Fields
650hA*
     *    OPSTTM  -  Start time for a day's routes.
     *    OPENTM  -  End time for a day's routes.
     *    OPLDOR  -  Loading order.
     *    OPTLID  -  Speak trailer id.
     *    OPRWCL  -  Speak row/column.
     *    OPVYPL  -  Verify pallet position.
     *    OPVFYP  -  Verify pallet label against pick label.
     *
     * Data structure
     *
     D opdata          ds
     D  opsttm                 1      6  0
     D  opentm                 7     12  0
     D  opldor                13     13
     D  optlid                14     14
     D  oprwcl                15     15
     D  opvypl                16     16
     D  opvfyp                17     17
     D  ldrend               117    117
     *
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
520bDD*DESC            S             50    DIM(16) CTDATA PERRCD(1)
530hDD*DESC            S             50    DIM(18) CTDATA PERRCD(1)
640 DD*DESC            S             50    DIM(19) CTDATA PERRCD(1)
650hDD*DESC            S             50    DIM(21) CTDATA PERRCD(1)
710bDD*DESC            S             50    DIM(23) CTDATA PERRCD(1)
CBIdDD*DESC            S             50    DIM(24) CTDATA PERRCD(1)
740aDD*DESC            S             50    DIM(28) CTDATA PERRCD(1)
CBIgDD*DESC            S             50    DIM(31) CTDATA PERRCD(1)
CBIgMD DESC            S             50    DIM(32) CTDATA PERRCD(1)
     *----------------------------------------------------------------
530bA*  Data structure for time calculations
     *
530bAD                 ds
530bAD  dshms                  1      6  0
530bAD  dshm                   1      4  0
530bAD  dshh                   1      2  0
530bAD  dsmm                   3      4  0
530bAD  dsss                   5      6  0
     *----------------------------------------------------------------
     D*  Redefinition data structures
     D*
     D $CERM           DS
     D  XCERM                  1     60
     D  $CMSG                  1      4
     *----------------------------------------------------------------
     *  Equipment types
     *
     D type01          c                   const('TRACTR')
     D type02          c                   const('TRAILR')
     D type03          c                   const('TRUCKS')
CBIbAD getloa          c                   const('GETLOARNG')
CBIbAD*----------------------------------------------------------------
CBIbAD*  Called programs
CBIbAD*
CBIbAD @CVTDT          C                   CONST('CVTDTE')
     D*----------------------------------------------------------------
700dDD*route           c                   const('Route ')
700dMD route           c                   const('Rte ')
     D loaded          c                   const('loaded')
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
     D*
     D $LPARM          DS
     D  $LCMD                  1      8
     D  $LPRG                  9     18
     D  $LUKY                 19     68
     D  $LRTN                 69     76
     D  $LERM                 77    136
     D  $LMSG                 77     80
     D  $LTYPE                81     88
     D*
     D*   Redefine key
     D*
     D  $LWHSE                19     21  0
     D  $LCODE                22     29
     D*
640 a*----------------------------------------------------------------
640 A*  Partial key redifinition
640 A*
640 AD $prtky          ds
640 AD $len50                  1     50
640 AD  $kwhse                 1     30
640 AD  $kcode                 4     11
     D*----------------------------------------------------------------
     D*
     D $CVTDT          DS
     D  $CVCMD                 1      8
     D  $CVPRG                 9     18
     D  $CVD6I                19     24
     D  $CVD8I                25     32
     D  $CVD6O                33     38  0
     D  $CVD8O                39     46  0
     D  $CVSTO                47     64
     D  $CVRTN                65     72
     D  $CVERM                73    132
     D  $CVMSG                73     76
     D*CurrStamp       s               z
     D*----------------------------------------------------------------
710dAD $bCmd           s              8
710dAD $bZone          s              6
710dAD $bRtid          s              5
     D*----------------------------------------------------------------
     D*  *ZEROVFY -  Zero verify options
     D*----------------------------------------------------------------
     D*
     D* Fields
     D*
     D*    OPVFYV  -  Verify virtual slot using RF (Y,N)
     D*
     D* Data structure
     D*
650hDD*OPDATA          DS
650hMD OPDAT1          DS
     D  OPVFYV                 1      1
     D  OPTEND               117    117
     I*
     D                 DS
     D  DSMISC                 1     20
     D  DSSDTE                 1      8
     D  DSSPCL                 9     11
     D  DSRPCK                12     12
     D  DSDOOR                13     14
     D  DSMEAT                15     15
     D  DSCODE                16     16
     D  DSRVS                 19     19
     D*
     D*
     D*
     D*----------------------------------------------------------------
     D RTE             DS
     D  RTE1                   1      5
     D*
     D*   Redefine DS
     D*
530eD **RTE23                  2      3  0
     D*
     D*----------------------------------------------------------------
     D PALLET          DS
     D  PLTID                  1      7  0
     D*
     D*   Redefine DS
     D*
     D  PLT12                  1      2  0
     D  PLT37                  3      7  0
     D*
     D  PLT#                   3      7
     D*
HSYbAD  COLUMN                 6      6
     D*
     D*----------------------------------------------------------------
PFCaAD LDRPAL          DS
PFCaAD  LDPAL                  1      7  0
PFCaAD*
PFCaAD*   Redefine DS
PFCaAD*
PFCaAD  LDCOL                  6      6
     D*
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     D $MDT            DS
     D  ERRMSG                 1     50
     D*
     D*                                   P   1   20ERWHSE
     D*
     D  ERFLD                  1     30
     D*
     D  ERQTY                  1      4P 0
     D  ERNQTY                 5      8P 0
     D                 DS
     D  $EC                    1      2P 0
     D*----------------------------------------------------------------
     D*  Message control
     D*
     D #MSGF           C                   CONST('PIRMSGF   ')
     D*
     D                 DS
     D  #MSGDT                 1    128
     D  $MD                    1    128
     D                                     DIM(128)
     D*----------------------------------------------------------------
     D*  Program info data structure
     D*
     D                SDS
     D  #PROG            *PROC
     D  #JOB                 244    253
     D  #USER                254    263
     D  #JOBN                264    269
     D  #JOBDT               276    281  0
     D  #JOBTM               282    287  0
710aAD  #curruser            358    367
     D*----------------------------------------------------------------
     D*  Workstation exception data structure
     D*
     D INFDS           DS
     D  STATUS           *STATUS
     D  ROWIN                370    370
     D  COLIN                371    371
     D*----------------------------------------------------------------
     D*  Workstation exception redefinition data structure
     D*
     D                 DS
     D  ROW#                   1      2B 0
     D  ROW                    2      2
     D  COL#                   3      4B 0
     D  COL                    4      4
640aA*----------------------------------------------------------------
640aA*  Prototypes
640aA*----------------------------------------------------------------
640aA
640aAD wrttran1        pr                  extpgm('WRTTRAN1')
640aA * Input
640aAD   ppcmd                        8
640aAD   ppwait                       2  0
640aAD   ppwhse                       3  0
640aAD   pptran#                      7  0
640aAD   ppfromdate                   8  0
640aAD   pptodate                     8  0
640aAD   ppemp#                       5  0

700gA*----------------------------------------------------------------
700gA*  Standard variables and constants
700gA*----------------------------------------------------------------

700gA /copy qcopysrc,c#stdvar

740cA*----------------------------------------------------------------
740cA*  Standard SQL variables and constants
740cA*----------------------------------------------------------------

740cA /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
530bA*  Variables
     *
710aAD @pcmd2          s             10
710aAD @ptype          s              8
710aAD @ptrn#          s              7  0
710aAD @ptask          s              6
710aAD @pwhse          s              3  0
710aAD @pwhdp          s              5
710aAD @pstyp          s              1
710aAD @pcube          s              9  3
710aAD @pswgt          s              9  2
710aAD @ppcs           s              5  0
710aAD @paisl          s              5  0
710aAD @pqty1          s              5  0
710aAD @pqty2          s              5  0
710aAD @pqty3          s              5  0
710aAD @prte           s              5
710aAD @ppo            s              9
710aAD @pgrp1          s              1
710aAD @pgrp2          s              1
710aAD @pdate          s              8  0
710aAD @ptime          s              6  0
710aAD @puser          s             10
710aAD @prtn           s              8
710aAD @pmsg           s              4
710aAD pntrn#          s              7  0
700gAD scnPckL         s               n
700gAD pal5            s              5  0
700gAD pal7            s              7  0
700dAd Sc1ParentRtid   s                   like(ttmpri)
700dAd Sc1ParentRte    s                   like(ttmprt)
740aAd Sc3ParentRtid   s                   like(ttmpri)
700dAd w1rtid          s                   like(ttmpri)
700dAD firstCnt        s               n
530hAD forevr          s              1
650fAD getOut          s              1
720aAD gGen            s              1  0
720aAD gGenTruck       s               n
720aAD gGenMerge       s               n
720aAD gGenOverflow    s               n
720aAD gGenTruckExt    s               n
720aAD gPltId          s                   like(lbpal#)
530hAD hdrctr          s              1  0
650bAD hldrte          s              5
650bAD hldrtid         s              5
700aAD hldw4pltrtid    s              5
700eAd hldlhendd       s                   like(lhendd)
700eAd hldlhendt       s                   like(lhendt)
720aAd hldpstrn#       s                   like(pstrn#)
700dAd kyrte1          s                   like(ttmpri)
650dAd kyrtid          s                   like(ttmpri)
700dAd kyrtid1         s                   like(ttmpri)
650hAd kyrtidordp      s                   like(orprid)
650hAd kytrax          s                   like(orpup#)
720aAd kytype          s                   like(lbtype)
640 AD lcmd            s              8
650fAD lhrtid3         s              5
640 AD lprg            s             10
640 AD lrtn            s              8
640 AD ltcode          s              8
640 AD lwhse           s              3  0
700dAD mrgCntr         s              3  0
650dAD ParentChild     s              1
700fAd sav_lhstrd      s                   like(lhstrd)
700fAd sav_lhstrt      s                   like(lhstrt)
650dAd sav_ttmpri      s                   like(ttmpri)
640 AD sort            s              1
530bAD timlen          s                   like(ptdmin)
530bAD tmpbeg          s              4  0
530bAD tmpend          s              4  0
650fAD updParent       s              1
640aAD wrtpcmd         s             10
640aAD wrtpwait        s              2  0
640aAD wrtpwhse        s              3  0
640aAD wrtptran#       s                   like(pttrn#)
640aAD wrtpfrmdate     s              8  0
640aAD wrtptodate      s              8  0
640aAd wrtpemp#        s                   like(ptemp#)
650eAD w3rtid          s              5
740cAD w1impd          s               d   inz(d'9999-12-31')
740cAD w1impdx         s              8  0
CBIbAD stime           s              6  0
CBIbAD etime           s              6  0
CBIbAD today           s              8  0
730aAD coaWhse         s              3  0
730aAD coaRtid         s              5
730aAD coaTran         s              7  0
730aAD coaOrdId        s              7  0
730aAD coaPltId        s              7  0
730aAD coaRtn          s             10
730aAD coaMsg          s            100

730aA*----------------------------------------------------------------
730aA*  Prototypes
730aA*----------------------------------------------------------------
730aA /copy qcopysrc,p.chkordau

     *----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      None
     C*
     C*    Returned Parameters
     C*      None
     C*
     C*----------------------------------------------------------------
     C*  Main line
     C*----------------------------------------------------------------
     C*
     C                   MOVE      *ON           *IN97
     C                   MOVE      *OFF          *IN90
     C                   MOVE      *OFF          *IN91
     C                   MOVE      *OFF          ERROR
     C*
     C                   EXSR      ZZINZ2
     C*
     C     NXTSCR        DOWNE     'EOJ'
     C                   EXSR      DSPSCR
     C     NXTSCR        CASEQ     '01 '         SC1
     C     NXTSCR        CASEQ     '02 '         SC2
     C     NXTSCR        CASEQ     '03 '         SC3
530 AC     NXTSCR        CASEQ     '04 '         SC4
     C                   ENDCS
     C*
     C*   Process Loader merged items pallet
     C*
     C     NXTSCR        IFEQ      '03 '
     C     MRGPLT        ANDEQ     *ON
     C*
     C*  Hold merged items pallet loading starting date
     C                   MOVE      '*CURCMD '    $CVCMD
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD8O        HLDSTD
     C*
     C*  Hold merged items pallet loading starting time
     C                   TIME                    HLDSTT
     C*
     C                   EXSR      ZZPG19
     C                   ENDIF
     C*
     C                   ENDDO
     C*
     C*   Do some clean up before leaving.
     C*
     C                   EXSR      ZSCLR
710aAC                   exsr      zzClose
     C                   SETON                                        LR
     C*----------------------------------------------------------------
     C*  DSPSCR - Display screen
     C*----------------------------------------------------------------
     C*
     C     DSPSCR        BEGSR
     C*
     C*   Set ON alarm indicator if error occured
     C*
     C     ERROR         IFEQ      *ON
     C                   MOVE      *ON           *IN98
     C                   ELSE
     C                   MOVE      *ON           *IN02
520bAC*  Default to position cursor on route id for screen1.
520bAC                   if        nxtscr = '01'
520bAC                   eval      *in02 = '0'
520bAC                   eval      *in09 = '1'
CBIaAC                   if        client = cheney
CBIaAC                   eval      *in02 = '1'
CBIaAC                   eval      *in09 = '0'
CBIaAC                   endif
520bAC                   endif
     C                   ENDIF
     C*
     C*   Overlay screen with error messages
     C*
     C                   EXSR      ZMDMSG
     C*
     C*  Overlay screen with screen to be processed.
     C*
     C                   select
     C                   when      nxtscr = '01 '
     C                   EXFMT     SCREEN1                              50
     C*
     C                   when      nxtscr = '02 '
     C                   EXFMT     SCREEN2                              50
     C*
     C                   when      nxtscr = '03 '
     C                   EXFMT     SCREEN3                              50
     C*
530 AC                   when      nxtscr = '04 '
530 AC                   EXFMT     SCREEN4                              50
     C*
     C                   ENDSL
     C*
     C*   Initialize error indicators and fields
     C*
     C                   SETOFF                                       010203
     C                   SETOFF                                       040506
     C                   SETOFF                                       070809
     C                   SETOFF                                       101112
     C                   SETOFF                                       131415
     C                   SETOFF                                       161718
     C                   SETOFF                                       1920
     C                   SETOFF                                       212223
     C                   SETOFF                                       24
     C                   SETOFF                                       29
     C                   SETOFF                                       303132
     C                   SETOFF                                       333435
     C                   SETOFF                                       363738
     C                   SETOFF                                       3940
     C                   SETOFF                                       9298
     C                   MOVE      *OFF          WARN              1
640 DC                   MOVE      *OFF          ERROR             1
     C                   MOVE      *OFF          CMDTKN            1
     C                   MOVE      *OFF          REDSPL            1
     C                   Z-ADD     0             E                 2 0
     C*
     C*   Initialize error subfile
     C*
     C                   EXSR      ZMCMSG
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*     Screen initialization and wrap-up routines
     C*
     C*----------------------------------------------------------------
     C*  Screen 01 initialization
     C*----------------------------------------------------------------
     C*
     C     SCR01I        BEGSR
     C                   MOVE      '01 '         NXTSCR            3
     C                   EXSR      ZZFIL1
     C                   MOVE      *OFF          REFRSH            1
700cMC                   MOVE      *OFF          TRYTRN
700cMC                   MOVE      *ON           *IN25
     C     END01I        ENDSR
     C*----------------------------------------------------------------
     C*  Screen 02 initialization
     C*----------------------------------------------------------------
     C*
     C     SCR02I        BEGSR
     C                   MOVE      '02 '         NXTSCR            3
     C                   EXSR      ZZFIL2
     C                   MOVE      *OFF          REFRSH
     C                   MOVE      *OFF          *IN44
CBIdAC                   MOVE      *ON           ADDING
     C     END02I        ENDSR
     C*----------------------------------------------------------------
     C*  Screen 03 initialization
     C*----------------------------------------------------------------
     C*
     C     SCR03I        BEGSR
     C                   MOVE      '03 '         NXTSCR            3
     C                   EXSR      ZZFIL3
     C                   MOVE      *OFF          REFRSH
     C                   MOVE      *OFF          *IN44
     C     END03I        ENDSR
     C*----------------------------------------------------------------
530 AC*  Screen 04 initialization
530 AC*----------------------------------------------------------------
530 AC*
530 AC     SCR04I        BEGSR
     C                   MOVE      '04 '         NXTSCR
     C                   EXSR      ZZFIL4
     C                   MOVE      *OFF          REFRSH
     C     END04I        ENDSR
     C*----------------------------------------------------------------
     C*              Screen Processing Routines
     C*
     C*----------------------------------------------------------------
     C*  SC1  -  Screen 1
     C*----------------------------------------------------------------
     C*
     C     SC1           BEGSR
     C*
     C*  Test for F3 - Exit
     C*
     C     *INKC         IFEQ      *ON
     C                   MOVE      'EOJ'         NXTSCR
     C*
     C                   GOTO      ENDSC1
     C                   ENDIF
     C*
     C*  Test for F5 - Refresh
     C*
     C     *INKE         IFEQ      *ON
     C                   MOVE      *ON           REFRSH
     C                   EXSR      SCR01I
     C                   GOTO      ENDSC1
     C                   ENDIF
     C*
     C*  Test for F12 - Previous
     C*
     C     *INKL         IFEQ      *ON
     C                   MOVE      'EOJ'         NXTSCR
     C*
     C                   GOTO      ENDSC1
     C                   ENDIF
     C*
530 AC*  Test for F1 - UNLOAD pallet
530 AC*
530 AC     *INKA         IFEQ      *ON
530 AC                   MOVE      *OFF          REFRSH
530 AC                   EXSR      SCR04I
530 AC                   GOTO      ENDSC1
530 AC                   ENDIF
     C*
710dAC*  Test for F2 - Load Equipment
710dAC*
710dAC     *inkb         ifeq      *on
710dAC                   call      'EQ480'
710dAC                   parm                    $bCmd
710dAC                   parm                    #prog
710dAC                   parm                    $bZone
710dAC                   parm                    $bRtid
710dAC                   goto      endsc1
710dAC                   endif
710dAC*
     C*  Test for F11 - Link to close rte application.
     C*
     C     *INKK         IFEQ      *ON
     C*
     C     @PRTN         IFEQ      '*NO'
     C*
     C*  Not authorized to close routes.
     C                   GOTO      ENDSC1
     C                   ELSE
     C                   CALL      'LOADR22'
     C                   GOTO      ENDSC1
     C                   ENDIF
     C*
     C                   ENDIF
     C*
     C*  Test for other command keys BEFORE verification and update.
     C*
     C                   MOVE      '*BEFORE '    CMDCHK            8
     C                   EXSR      ZZCMD1
     C     CMDTKN        CABEQ     *ON           ENDSC1
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     C                   EXSR      ZZCHK1
     C     ERROR         CABEQ     *ON           ENDSC1
     C     EQPIN         CABEQ     *ON           ENDSC1
     C
     C     DSPSCR2       IFEQ      '1'
     C                   EXSR      ZZUPD1
     C     ERROR         CABEQ     *ON           ENDSC1
     C                   ELSE
     C                   EXSR      SCR03I
     C                   ENDIF
     C
     C*
     C*  Test for other command keys AFTER verification and update.
     C*
     C                   MOVE      '*AFTER  '    CMDCHK
     C                   EXSR      ZZCMD1
     C     CMDTKN        CABEQ     *ON           ENDSC1
     C*
     C*
     C     ENDSC1        ENDSR
     C*----------------------------------------------------------------
     C*  SC2  -  Screen 2
     C*----------------------------------------------------------------
     C*
     C     SC2           BEGSR
     C*
     C*  Test for F3 - Exit
     C*
     C     *INKC         IFEQ      *ON
     C                   EXSR      SCR01I
     C                   GOTO      ENDSC2
     C                   ENDIF
     C*
     C*  Test for F5 - Refresh
     C*
     C     *INKE         IFEQ      *ON
     C                   MOVE      *ON           REFRSH
     C                   EXSR      SCR02I
     C                   MOVE      *OFF          *IN44
     C                   GOTO      ENDSC2
     C                   ENDIF
     C*
     C*  Test for F12 - Previous
     C*
     C     *INKL         IFEQ      *ON
     C                   MOVE      *OFF          REFRSH
     C                   EXSR      SCR01I
     C                   GOTO      ENDSC2
     C                   ENDIF
     C*
     C*  Test for other command keys BEFORE verification and update.
     C*
     C                   MOVE      '*BEFORE '    CMDCHK            8
     C                   EXSR      ZZCMD2
640 AC     ERROR         CABEQ     *ON           ENDSC2
     C     CMDTKN        CABEQ     *ON           ENDSC2
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     C                   EXSR      ZZCHK2
     C     ERROR         CABEQ     *ON           ENDSC2
      *
     C*  Redisplay screen to read in trailer #.
     C*
     C*>   *IN44         IFEQ      *OFF
     C*                  MOVE      *ON           *IN44
     C*                  MOVE      *ON           *IN23
     C*                  GOTO      ENDSC2
     C*>                 ENDIF
      *
CBIdAC     ADDING        IFEQ      *ON
CBIdAC     W2TRLQ        IFEQ      'N'
CBIdAC     W2TKQ         OREQ      'N'
CBIdAC                   MOVE      *OFF          ADDING
CBIdAC                   GOTO      ENDSC2
CBIdAC                   ELSE
CBIdAC                   MOVE      *OFF          ADDING
CBIdAC                   ENDIF
CBIdAC                   ENDIF
     C*
     C                   EXSR      ZZUPD2
     C     ERROR         CABEQ     *ON           ENDSC2
     C*
     C*  Test for other command keys AFTER verification and update.
     C*
     C                   MOVE      '*AFTER  '    CMDCHK
     C                   EXSR      ZZCMD2
     C     CMDTKN        CABEQ     *ON           ENDSC2
640 AC     ERROR         CABEQ     *ON           ENDSC2
     C*
     C                   EXSR      ZZFIL2
     C                   MOVE      *OFF          *IN44
     C*
     C     ENDSC2        ENDSR
     C*----------------------------------------------------------------
     C*  SC3  -  Screen 3
     C*----------------------------------------------------------------
     C*
     C     SC3           BEGSR
     C*
     C*  Test for F3 - Exit
     C*
     C     *INKC         IFEQ      *ON
     C                   EXSR      SCR01I
     C                   GOTO      ENDSC3
     C                   ENDIF
     C*
700cMC*  Test for F9 - Add-Ons
700cMC
700cMC     *INKI         IFEQ      *ON
700cMC     TRYTRN        IFEQ      *ON
700cMC                   MOVE      *OFF          TRYTRN
700cMC                   MOVE      *ON           *IN25
700cMC                   ELSE
700cMC     TRYTRN        IFEQ      *OFF
700cMC                   MOVE      *ON           TRYTRN
700cMC                   MOVE      *OFF          *IN25
700cMC                   ENDIF
700cMC                   ENDIF
700cMC                   MOVE      *ON           REFRSH
700cMC                   EXSR      SCR03I
700cMC                   MOVE      *OFF          *IN44
700cMC                   GOTO      ENDSC3
700cMC                   ENDIF
     C*
     C*  Test for F12 - Previous
     C*
     C     *INKL         IFEQ      *ON
     C                   MOVE      *OFF          REFRSH
     C                   EXSR      SCR01I
     C                   GOTO      ENDSC3
     C                   ENDIF
     C*
     C*  Test for other command keys BEFORE verification and update.
     C*
     C                   MOVE      '*BEFORE '    CMDCHK            8
     C                   EXSR      ZZCMD3
     C     CMDTKN        CABEQ     *ON           ENDSC3
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     C                   EXSR      ZZCHK3
      *
     C     ERROR         IFEQ      *ON
     C     MRGSCN        ANDEQ     *ZEROS
     C                   GOTO      BYPAS1
     C                   ENDIF
      *
     C     ERROR         CABEQ     *ON           ENDSC3
     C*
     C     BYPAS1        TAG
     C     MRGPLT        IFEQ      *ON
     C*  Pallet being process is a Loader Merged Items.
     C                   GOTO      ENDSC3
     C                   ENDIF
     *
700gA*  Look for a label record which has not been shorted, if you
700gA*  don't find one don't redisplay screen to read pick label
700gA*  barcode because there won't be one.
700gA*
     c                   move      w3plt#        pal5
     c                   z-add     pal5          pal7
      /free

        scnPckL = *off;
        if opvfyp = 'Y'
           and *in45 = *off;

          setll (lhwhse: lhrtid: pal7)
                label13;

          dow forever = forever;

            reade (lhwhse: lhrtid: pal7)
                  label13;

            if %eof(label13);
              leave;
            endif;

            chain (lhwhse: l13_lblbl#) runner6;

            if not %found;
              scnPckL = *on;
              leave;
            endif;

            if ruqyfd > 0;
              scnPckL = *on;
              leave;
            endif;

          enddo;

        endif;
      /end-free

     C*
650hAC*  Redisplay screen to read in pick label barcode.
     C*
700gMC                   if            opvfyp = 'Y'
650hAC                             and *in45 = *off
700gAC                             and scnPckL = *on
650hAC                   move      *on           *in45
650hAC                   if        $rtncd = *blanks
650hAC                   move      *on           *in31
650hAC                   goto      endsc3
650hAC                   endif
650hAC                   endif
     C*
     C*  Redisplay screen to read in trailer #.
     C*
     C     *IN44         IFEQ      *OFF
     C                   MOVE      *ON           *IN44
     C     HLDSTT        IFEQ      *ZEROS
     C*
     C*  Hold non-merged items pallet loading starting date
     C                   MOVE      '*CURCMD '    $CVCMD
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD8O        HLDSTD
     C*
     C*  Hold non-merged items pallet loading starting time
     C                   TIME                    HLDSTT            6 0
     C                   ENDIF
     C*
     C*  Check if Breakers to display proper function key
     C                   SUBST     W3RTE#:2      DIG045            2
     C     DIG045        IFEQ      '75'
CBI AC     client        andeq     cheney
     C                   SETON                                        2628
     C                   ENDIF
     C     $RTNCD        IFEQ      *BLANKS
     C*
     C*  Processing a non Loader Merged Items pallet.
     C                   MOVE      *ON           *IN23
     C                   GOTO      ENDSC3
     C                   ENDIF
     C                   ENDIF
      *
     C                   EXSR      ZZUPD3
     C     ERROR         CABEQ     *ON           ENDSC3
     C*
700cMC     W3TRN#        IFNE      *ZEROS
700cMC                   MOVE      *OFF          TRYTRN
700cMC                   MOVE      *ON           *IN25
700cMC                   ENDIF
     C*
     C*  Test for other command keys AFTER verification and update.
     C*
     C                   MOVE      '*AFTER  '    CMDCHK
     C                   EXSR      ZZCMD3
     C     CMDTKN        CABEQ     *ON           ENDSC3
     C*
     C                   EXSR      ZZFIL3
     C                   MOVE      *OFF          *IN44
650hAC                   MOVE      *OFF          *IN45
     C*
     C*
     C*  Check if all pallets for route being processed have been loaded.
     C*  If true then display trailer equipment screen
     C*
     C     *IN12         IFEQ      *ON
     C*
CLDaA *  For specified client/s, trailer equipment reqt's disabled.
     C*
CLDaAC                   select
     C*
HSYaDC*                  when      client = cityln
CLDaAC                   when      client = cityln or
HSYaAC                             client = halsey or
JORaAC                             client = jordanos or
RYLaAC                             client = royal
CLDaAC                   eval      $RTNCD = '*OK     '
     C*
CLDaAC                   other
     C*
640b C*  Skip equipment check for all clients.
CBIcAC*  EXCEPT cheney, still do equipment check for cheney
CBIcAC                   if        client <> cheney
640bAC                   eval      $RTNCD = '*OK     '
640bAC                   goto      skpeq
CBIcAC                   endif
     C                   MOVE      *BLANKS       $RTNCD
     C                   CALL      'LOADR21'
     C                   PARM                    LHWHSE
     C                   PARM                    LHRTE
     C                   PARM                    LHRTID
     C                   PARM                    LHTRLR
     C                   PARM                    $PPRG
     C                   PARM                    $RTNCD
      *
     C*  Check return code from trailer equipment screen.
     C*  Display msg if screen was not filled in.
     C     $RTNCD        IFNE      '*OK     '
     C                   MOVE      *ON           ERROR
     C                   MOVEL     DESC(13)      ERRMSG
     C                   EXSR      ZM0105
     C                   MOVE      '01 '         NXTSCR
     C                   GOTO      ENDSC3
     C                   ENDIF
      *
CLDaAC                   endsl
640bAC     skpeq         tag
      *
     C*  Trailer equipment screen is loaded display 'Route loaded' msg.
     C     ROUTE         CAT       W1RTE#        MSG1             10
     C     MSG1          CAT       LOADED        ERRMSG
     C                   EXSR      ZM0105
     C                   MOVE      '01 '         NXTSCR
     C                   ENDIF
     C
     C*
700dAC                   if        *in12 = *on
700dAC                   exsr      zzfil1
700dAC                   endif
     C*
     C     ENDSC3        ENDSR
     C*----------------------------------------------------------------
530 AC*  SC4  -  Screen 4   -   Unload pallet
530 AC*----------------------------------------------------------------
530 AC*
530 AC     SC4           BEGSR
     C*
     C*  Test for F3 - Exit
     C*
     C     *INKC         IFEQ      *ON
     C                   EXSR      SCR01I
     C                   GOTO      ENDSC4
     C                   ENDIF
     C*
     C*  Test for other command keys BEFORE verification and update.
     C*
     C                   MOVE      '*BEFORE '    CMDCHK            8
     C                   EXSR      ZZCMD4
     C     CMDTKN        CABEQ     *ON           ENDSC4
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     C                   EXSR      ZZCHK4
      *
     C     ERROR         CABEQ     *ON           ENDSC4
      *
     C                   EXSR      ZZUPD4
     C     ERROR         CABEQ     *ON           ENDSC4
     C*
     C*  Test for other command keys AFTER verification and update.
     C*
     C                   MOVE      '*AFTER  '    CMDCHK
     C                   EXSR      ZZCMD4
     C     CMDTKN        CABEQ     *ON           ENDSC4
     C*
     C                   EXSR      ZZFIL4
     C*
     C     ENDSC4        ENDSR
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*----------------------------------------------------------------
     C*  *INZSR  Initialization subrotine
     C*----------------------------------------------------------------
     C*
     C     *INZSR        BEGSR
520aA*
520aA*  Get Client ID
     *
520aAC                   call      @getcl
520aAC                   parm                    client           10
730dAC                   parm                    clientLoc        10
     *
     C*
     C*  Initialize special keys
     C*
700gDC**                 Z-ADD     0             ENTER             5 0
     C                   Z-ADD     2             COMAND            5 0
     C                   Z-ADD     01122         ROLLUP            5 0
     C                   Z-ADD     01123         ROLLDN            5 0
     C                   Z-ADD     01124         CLEAR             5 0
     C                   Z-ADD     01125         HELP              5 0
CBIbA*
CBIbA*  Convert today's date into century format.
CBIbA*
CBIbAC                   eval      $cvcmd = '*CURCMD '
CBIbAC                   call      @cvtdt
CBIbAC                   parm                    $cvtdt
CBIbAC                   eval      today = $cvd8o
     C*
     C*  Initialize message handling
     C*
     C                   EXSR      ZMIMSG
     C*
     C*   Call user added initialization routine.
     C*
     C                   EXSR      ZZINZ
     C                   ENDSR
     C*---------------------------------------------------------------
     C*
     C*  SUBROUTINE ZMxxxx  Control message display subfile
     C*
     C*----------------------------------------------------------------
     C*    ZMCMSG  Clear message record subfile
     C*----------------------------------------------------------------
     C*
     C     ZMCMSG        BEGSR
     C                   MOVE      *OFF          *IN97
     C                   WRITE     MSGCTL
     C                   Z-ADD     *ZERO         MSGK              4 0
     C                   WRITE     MSGCLR
     C                   MOVE      '*CLEAR '     #MSGID            7
     C                   MOVE      '*NULL  '     #MSGTP            7
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*    ZMDMSG  Display message record subfile
     C*----------------------------------------------------------------
     C*
     C     ZMDMSG        BEGSR
     C                   MOVE      *ON           *IN97
     C     MSGK          IFGT      0
     C                   WRITE     MSGCTL
     C                   Z-ADD     *ZERO         MSGK
     C                   END
     C                   ENDSR
     C*----------------------------------------------------------------
     C*    ZMIMSG  Initialization necessary for message subfile
     C*----------------------------------------------------------------
     C*
     C     ZMIMSG        BEGSR
     C                   MOVE      #PROG         #PGMQ            10
     C                   EXSR      ZMCMSG
     C                   ENDSR
     C*
     C*    ZMPMSG  Add message record to subfile
     C*
     C     ZMPMSG        BEGSR
     C     $MSGF         IFEQ      *BLANKS
     C                   MOVE      #MSGF         $MSGF            10
     C                   END
     C                   CALL      'PUTMSG'
     C                   PARM                    $MSGF
     C                   PARM                    #MSGID
     C                   PARM                    #MSGTP
     C                   PARM                    #MSGDT
     C                   PARM                    #PGMQ
     C                   PARM                    #MSGK
     C     #MSGID        IFNE      '*CLEAR '
     C                   ADD       1             MSGK
     C                   WRITE     MSGREC
     C                   END
     C                   MOVE      *BLANKS       #MSGDT
     C                   MOVE      *BLANKS       $MSGF
     C                   ENDSR
     C*----------------------------------------------------------------
     C*    ZSCLR   Clear screen
     C*----------------------------------------------------------------
     C*
     C     ZSCLR         BEGSR
     C                   WRITE     CLRSCR
     C                   MOVE      *ON           SCLEAR            1
     C                   ENDSR
     C*
     C*    ZMQMSG  Add message record to subfile from program queue
     C*
     C     ZMQMSG        BEGSR
     C                   ADD       1             MSGK
     C                   WRITE     MSGREC
     C                   ENDSR
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*   PIR7971  Error in writing a record.
     C*
     C     ZM71          BEGSR
     C                   MOVE      'PIR7971'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVE      *BLANKS       $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*   PIR7972  Error in updating a record.
     C*
     C     ZM72          BEGSR
     C                   MOVE      'PIR7972'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVE      *BLANKS       $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*      0105
     C*
     C     ZM0105        BEGSR
     C                   MOVE      'PIR0105'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD(1)
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*      0110  Number must be > 0
     C*
     C     ZM0110        BEGSR
     C                   MOVE      'PIR0110'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD(1)
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*    PIR1001  Invalid option entered.
     C*
     C     ZM1001        BEGSR
     C                   MOVE      'PIR1001'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
     *----------------------------------------------------------------
     *   EQ52003  Equipment type not valid.
     *
     C     zm2003        begsr
     C                   eval      #msgid = 'EQ52003'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   EQ52004  Equipment status not valid.
     *
     C     zm2004        begsr
     C                   eval      #msgid = 'EQ52004'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     C*----------------------------------------------------------------
     C*   PIR9905  Cursor not in correct position for lookup.
     C*
     C     ZM9905        BEGSR
     C                   MOVE      'PIR9905'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVE      *BLANKS       $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
650fA*
650fA*  ZZADDONS  Update trailer for add-on routes.
650fA*
650fAC     zzAddOns      begsr

650fAC                   eval      updParent = *off
650fAC                   eval      getOut = *off
650fAC     rtkey         chain     ttmerg2
650fAC                   if        %found
650fAC                   eval      kyrtid = ttmpri
650fAC                   eval      updParent = *on
650fAC                   else
650fAC                   eval      kyrtid = lhrtid
650fAC                   endif
650fAC     ttmkey        setll     ttmerg
650fAC                   dow       forevr = forevr
650fAC     ttmkey        reade     ttmerg
650fAC                   if        %eof
650fAC                             or getOut = *on
650fAC                   leave
650fAC                   endif

650fAC                   eval      lhrtid3 = ttmcri
650fAC     updParentHdr  tag
650fAC     lhkey3        chain     ldrhdr3
650fAC                   if        %found

650fAC                   eval      lhtrlr = w2trl#
650fAC                   eval      lhstat = '2'

650fA*  Move route starting loading date and time into Ldrhdr file.

700fDC**                 move      '*CURCMD '    $cvcmd
700fDC**                 call      @cvtdt
700fDC**                 parm                    $cvtdt
700fDC**                 eval      lhstrd = $cvd8o
700fMC                   eval      lhstrd = sav_lhstrd
700fDC**                 time                    lhstrt
700fMC                   eval      lhstrt = sav_lhstrt

650fA*  Get loader emp#

650fAC     #user         chain     piruser
650fAC                   if        %found
650fAC                   eval      lhemp# = usemp#
650fAC                   endif

650fAC                   update    lhrec3
650fAC                   endif
650fAC                   enddo

650fAC                   if        updParent = *on
650fAC                   eval      updParent = *off
650fAC                   eval      getOut = *on
650fAC                   eval      lhrtid3 = ttmpri
650fAC                   goto      updParentHdr
650fAC                   endif

650fA*  Bring back ldrhdr3 rec for the route being loaded

650fAC                   eval      lhrtid3 = hldrtid
650fAC     lhkey3        chain(n)  ldrhdr3

650fAC                   endsr
     C*----------------------------------------------------------------
700dA*
700dA*  ZZCHKMRG  Check for add-ons.
700dA*
700dAC     zzChkMrg      begsr
700dA
     *  Check to see if the route scanned is part of a merge
     *
     C                   eval      ParentChild = *blanks
     C                   eval      kyrtid = lhrtid
     C     ttmkey        chain     ttmerg
     C                   if        %found(ttmerg)
     C                   eval      ParentChild = 'P'
     C                   eval      Sc1ParentRtid = ttmpri
     C                   eval      Sc1ParentRte  = ttmprt
     C                   else
     C     ttmkey        chain     ttmerg2
     C                   if        %found(ttmerg2)
     C                   eval      ParentChild = 'C'
     C                   eval      Sc1ParentRtid = ttmpri
     C                   eval      Sc1ParentRte  = ttmprt
     C                   endif
     C                   endif

     C                   eval      mrgCntr = 0

     C                   endsr
730aA*----------------------------------------------------------------
730aA*
730aA*  zzChkOrdAud  Check for open order audits for transaction
730aA*
730aAC     zzChkOrdAud   begsr

      /free

       monitor;
         chkordaud ('*PALLET': coaWhse: coaRtid: coaTran: coaOrdId:
                    coaPltId: coaRtn: coaMsg);

         if coaRtn = '*OPEN';
           error = *on;
           errmsg = 'Cannot load pallet'
                  + ' - Open order audit exists';
           exsr zm0105;
         endif;
       on-error;
       endmon;

      /end-free

     C                   endsr
     C*----------------------------------------------------------------
700dA*
700dA*  ZZCNTMRG  The route scanned on screen1 is part of a merge, this
700dA*  subr counts how many pallets are on the additional routes.
700dA*  Don't count the pallets for the route just entered as they are
700dA*  counted in whatever subr calls this one.
700dA*
700dAC     zzCntMrg      begsr
700dA
     C                   eval      firstCnt = *on

     *  Count pallets of child routes
     C                   eval      kyrtid = Sc1ParentRtid

     C     ttmkey        setll     ttmerg1
     C                   dow       forevr = forevr
     C     ttmkey        reade     ttmerg1
     C                   if        %eof
     C                   leave
     C                   endif
     C                   if        ttmcri = lhrtid
     C                   iter
     C                   endif
     C                   eval      kyrte1 = ttmcrt
     C                   eval      kyrtid1 = ttmcri

     C     cntParent     tag
     C     ttmkey1       setll     ldrdetl
     C     ttmkey1       reade(N)  ldrdetl                                79

     C                   dow       *in79 = *off
     C     ldendt        ifeq      0
     C                   eval      mrgCntr = mrgCntr + 1
     C                   endif
     C     ttmkey1       reade(N)  ldrdetl                                79
     C                   enddo

     C                   enddo

     *  If route entered is not the parent route, count its pallets
     C                   if        lhrtid <> Sc1ParentRtid and
     C                             firstCnt = *on
     C                   eval      firstCnt = *off
     C                   eval      kyrte1 = Sc1ParentRte
     C                   eval      kyrtid1 = Sc1ParentRtid
     C                   goto      cntParent
     C                   endif

     C                   endsr
     C*----------------------------------------------------------------
700dA*
700dA*  ZZUPDMRGHDR  Update end date, end time and status in all associated
700dA*  loader headers.
700dA*
700dAC     zzUpdMrgHdr   begsr
700dA
     C                   eval      firstCnt = *on

     *  Update associated child routes
     C                   eval      kyrtid = Sc1ParentRtid

     C     ttmkey        setll     ttmerg1
     C                   dow       forevr = forevr
     C     ttmkey        reade     ttmerg1
     C                   if        %eof
     C                   leave
     C                   endif
     C                   if        ttmcri = lhrtid
     C                   iter
     C                   endif
     C                   eval      kyrte1 = ttmcrt
     C                   eval      kyrtid1 = ttmcri

     C     updParRte     tag
     C     ttmkey1       setll     ldrhdr
     C     ttmkey1       reade     ldrhdr                                 79

     C                   dow       *in79 = *off
700eAC                   eval      lhendd = hldlhendd
700eAC                   eval      lhendt = hldlhendt
     C                   move      '3'           lhstat
     C                   update    lhrec
     C     ttmkey1       reade     ldrhdr                                 79
     C                   enddo

     C                   enddo

     *  If route entered is not the parent route, update the parent
     C                   if        lhrtid <> Sc1ParentRtid and
     C                             firstCnt = *on
     C                   eval      firstCnt = *off
     C                   eval      kyrte1 = Sc1ParentRte
     C                   eval      kyrtid1 = Sc1ParentRtid
     C                   goto      updParRte
     C                   endif

     C                   endsr
     C*----------------------------------------------------------------
     C*  ZZCHK1   Screen 1 error checking.
     C*----------------------------------------------------------------
     C*
     C     ZZCHK1        BEGSR
      *
740cDC**                 eval      w1rtid = %subst(w1rtid10:1:5)
      *
     C                   MOVE      *OFF          ERROR
     C                   MOVE      *BLANKS       ERRMSG
     C                   MOVE      '0'           DSPSCR2           1
     C*
     C*   Verify warehouse and get description.
     C*
     C                   MOVE      '*VERIFY '    $LCMD
     C                   Z-ADD     W1WHSE        $LWHSE
     C                   CALL      'WH900'
     C                   PARM                    $LPARM
     C     $LRTN         IFEQ      '*ERROR  '
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN21
     C                   MOVE      *ON           *IN01
     C                   MOVEL     $LERM         ERRMSG
     C                   EXSR      ZM0105
     C                   ELSE
     C     $LRTN         IFEQ      '*PGMQ   '
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN21
     C                   MOVE      *ON           *IN01
     C                   MOVE      $LMSG         #MSGK
     C                   EXSR      ZMQMSG
     C                   ENDIF
     C                   ENDIF
      *
      *  Check if user id is found in user file.
      *
     C     #USER         CHAIN     PIRUSER                            79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
520bAC                   if        w1rtid = ' '
     C                   MOVE      *ON           *IN02
520bAC                   else
520bAC                   eval      *in09 = '1'
520bAC                   endif
     C                   MOVEA     DESC(8)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK1
     C                   ENDIF
     C*
520bAC*  Verify route id if entered, otherwise, verify route.
     C*
520bAC                   select
     C*
520bAC                   when      w1rtid <> ' '
     C*
520bAC*  Verify route id entered.
     C*
530aMC     HDKEY3        CHAIN(N)  ldrhdr3                            79
520bAC                   IF        *IN79
520bAC                   MOVE      *ON           ERROR
520bAC                   MOVE      *ON           *IN29
520bAC                   MOVE      *ON           *IN09
520bAC                   MOVE      *OFF          *IN01
520bAC                   IF        ERRMSG =      *BLANKS
520bAC                   MOVEL     DESC(16)      ERRMSG
520bAC                   EXSR      ZM0105
520bAC                   GOTO      ENDCK1
520bAC                   ENDIF
520bAC                   ENDIF
520bAC                   eval      w1rte# = lhrte
     C*
520bAC                   other
     C*
     C*  Verify route entered.
     C*
530hAC                   EVAL      HDRCTR = 0
530hDC**   HDKEY         CHAIN(N)  LHREC                              79
530hMC     HDKEY         SETLL     LHREC
530hAC                   DOW       FOREVR = FOREVR
530hAC     HDKEY         READE     LHREC                                  79
     C                   IF        *IN79
530hAC                   IF        HDRCTR > 0
530hAC                   LEAVE
530hAC                   ENDIF
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN22
     C                   MOVE      *ON           *IN02
     C                   MOVE      *OFF          *IN01
     C                   IF        ERRMSG =      *BLANKS
     C                   MOVEL     DESC(1)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK1
     C                   ENDIF
     C                   ENDIF
530hAC                   EVAL      HDRCTR = HDRCTR + 1
640 AC*--->              ENDDO
530hAC                   IF        HDRCTR > 1
530hAC                   MOVE      *ON           ERROR
640 DC*                  MOVE      *ON           *IN22
640 DC*                  MOVE      *ON           *IN02
640 MC                   MOVE      *ON           *IN29
640 MC                   MOVE      *ON           *IN09
530hAC                   MOVE      *OFF          *IN01
530hAC                   IF        ERRMSG =      *BLANKS
530hAC                   MOVEL     DESC(19)      ERRMSG
530hAC                   EXSR      ZM0105
530hAC                   GOTO      ENDCK1
530hAC                   ENDIF
530hAC                   ENDIF
640 AC                   ENDDO
      *
520bAC                   endsl
      *
      *  Check if all pallets are already loaded for this route.
      *
     C                   EXSR      ZZCHKL
     C     *IN12         IFEQ      *ON
     C     PLTCNT        ANDGT     *ZEROS
      *
      *  All pallets for this route have been loaded,
      *  now check if trailer equipment info has been input.
      *  If not, display screen to load it.
      *
CLDaA *  For specified client/s, trailer equipment reqt's disabled.
     C*
CLDaAC                   select
     C*
HSYaDC*                  when      client = cityln
CLDaAC                   when      client = cityln or
HSYaAC                             client = halsey or
JORaAC                             client = jordanos or
RYLaAC                             client = royal
CLDaAC                   eval      $RTNCD = '*OK     '
     C*
CLDaAC                   other
      *
650c C*  Skip equipment check for all clients.
CBIcAC*  EXCEPT cheney, still do equipment check for cheney
CBIcAC                   if        client <> cheney
650cAC                   eval      $RTNCD = '*OK     '
650cAC                   goto      skpeq2
CBIcAC                   endif
     C     EQPKEY        CHAIN     LDRTEQ                             79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *OFF          EQPIN             1
     C                   MOVE      *BLANKS       $RTNCD
     C                   CALL      'LOADR21'
     C                   PARM                    LHWHSE
     C                   PARM                    LHRTE
     C                   PARM                    LHRTID
     C                   PARM                    LHTRLR
     C                   PARM                    $PPRG
     C                   PARM                    $RTNCD
      *
     C     $RTNCD        IFNE      '*OK     '
      *
      *  Trailer equipment info was not loaded
     C                   MOVE      *ON           ERROR
     C                   MOVEL     DESC(13)      ERRMSG
     C                   EXSR      ZM0105
     C                   MOVE      '01 '         NXTSCR
     C                   GOTO      ENDCK1
     C                   ELSE
     C                   MOVE      *ON           EQPIN
     C     ROUTE         CAT       W1RTE#        MSG1             10
     C     MSG1          CAT       LOADED        ERRMSG
     C                   EXSR      ZM0105
     C                   MOVE      '01 '         NXTSCR
     C                   GOTO      ENDCK1
     C                   ENDIF
     C                   ENDIF
      *
CLDaAC                   endsl
650cAC     skpeq2        tag
      *
      *  Route is loaded,display friendly msg using error routine
     C                   MOVE      *ON           ERROR
520bAC                   if        w1rtid <> ' '
520bAC                   eval      *in09 = '1'
520bAC                   eval      *in29 = '1'
520bAC                   else
     C                   MOVE      *ON           *IN02
     C                   MOVE      *ON           *IN22
520bAC                   endif
     C                   MOVEL     DESC(5)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK1
     C                   ENDIF
      *
      *  Pltcnt=0=Rte has not pallets (error).
     C     PLTCNT        IFEQ      *ZEROS
     C                   MOVE      *ON           ERROR
520bAC                   if        w1rtid <> ' '
520bAC                   eval      *in09 = '1'
520bAC                   eval      *in29 = '1'
520bAC                   else
     C                   MOVE      *ON           *IN22
     C                   MOVE      *ON           *IN02
520bAC                   endif
     C                   MOVE      *OFF          *IN01
     C                   IF        ERRMSG =      *BLANKS
     C                   MOVEL     DESC(14)      ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK1
     C                   ENDIF
     C                   ENDIF
      *
      *  Check if route has not been assigned to a loader,
      *  if not, display screen to assign trailer#.
      *  NOTE; If Lhemp#=0=Rte not assigned
      *
     C     LHEMP#        IFEQ      *ZEROS
     C                   MOVE      '1'           DSPSCR2
     C                   ENDIF
      *
      *
     C     ENDCK1        ENDSR
     C*----------------------------------------------------------------
     C*  ZZCHK2   Screen 2 error checking.
     C*----------------------------------------------------------------
     C*
     C     ZZCHK2        BEGSR
     C*
     C                   MOVE      *OFF          ERROR
     C                   MOVE      *BLANKS       ERRMSG
CBIdAC*
730bAC     *IN66         IFEQ      *ON
CBIdAC     W2TRLQ        IFNE      'N'
CBIdAC     W2TRLQ        ANDNE     'Y'
CBIdAC                   MOVE      *ON           ERROR
CBIdAC                   MOVE      *ON           *IN21
CBIdAC                   MOVEL     DESC(25)      ERRMSG
CBIdAC                   EXSR      ZM0105
CBIdAC                   ENDIF
CBIdAC*
CBIdAC     W2TKQ         IFNE      'N'
CBIdAC     W2TKQ         ANDNE     'Y'
CBIdAC                   MOVE      *ON           ERROR
CBIdAC                   MOVE      *ON           *IN22
CBIdAC                   MOVEL     DESC(25)      ERRMSG
CBIdAC                   EXSR      ZM0105
CBIdAC                   ENDIF
730cDC**                 ENDIF
CBIdAC*
CBIdAC     W2LODQ        IFNE      'N'
CBIdAC     W2LODQ        ANDNE     'Y'
CBIdAC                   MOVE      *ON           ERROR
CBIdAC                   MOVE      *ON           *IN23
CBIdAC                   MOVEL     DESC(25)      ERRMSG
CBIdAC                   EXSR      ZM0105
CBIdAC                   ENDIF
730cAC                   ENDIF
      *
      *  Validate trailer id against equipment file.
      *
     C                   MOVEL     W2TRL#        HLDTRL
     C     TRLKEY        CHAIN     EQUIP                              79
CBIgAC                   if        client = cheney
CBIgAC                   if        *in79 = *on
CBIgAC                                or *in79 = *off
CBIgAC                                and eqtype <> 'TRAILR'
CBIgAC                   move      *ON           ERROR
CBIgAC                   move      *ON           *IN24
CBIgAC                   move      *ON           *IN01
CBIgAC     ERRMSG        IFEQ      *BLANKS
CBIgAC                   MOVEA     DESC(30)      ERRMSG
CBIgAC                   EXSR      ZM0105
CBIgAC                   GOTO      ENDCK2
CBIgAc                   endif
CBIgAc                   endif
CBIgAc                   endif
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
CBIgDC****               MOVE      *ON           *IN22
CBIgAC                   MOVE      *ON           *IN24
     C                   MOVE      *ON           *IN01
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(4)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK2
     C                   ENDIF
640 AC                   ELSE
640 AC                   EXSR      ZZTRLR
     C                   GOTO      ENDCK2
     C                   ENDIF
CBIjA* The following code of CBIb, was moved to ZZTRLR due to the
CBIjA*     ENDCK2 above this, it was not getting hit here.
CBIjA* In addt, below this CBId is actually checked at the beginning
CBIjA*     of zzCHK2 above, it was not getting hit down here either.

CBIbA*
CBIbA*      Get loader start and end times.
CBIbA*
CBIbAC*                  if        client = cheney
CBIbAC*                  call      getloa
CBIbAC*                  parm                    #whse
CBIbAC*                  parm      0             stime
CBIbAC*                  parm      0             etime

CBIbAC*    trlkey        setll     ldrhhdr2
CBIbAC*                  dou       forevr <> forevr
CBIbAC*    trlkey        reade     ldrhhdr2
CBIbAC*                  if        %eof(ldrhhdr2)
CBIbAC*                  leave
CBIbAC*                  endif

CBIbAC*                  if        lhhcld = today

CBIbAC*                  if        lhhclt >= stime
CBIbAC*                            and lhhclt <= etime
CBIbAC*                  eval      error = *on
CBIbAC*                  eval      *in22 = *on
CBIbAC*                  eval      *in01 = *on
CBIbAC*                  if        errmsg = *blanks
CBIbAC*    desc(7)       cat       lhrte:1       errmsg
CBIbAC*                  exsr      zm0105
CBIbAC*                  goto      endck2
CBIbAC*                  endif
CBIbAC*                  endif
CBIbAC*                  endif

CBIbAC*                  enddo
CBIbAC*                  endif
      *
650dA*  Trailer edit below not necessary, edit is done in zztrlr.
      *
650dD ** Make sure trailer is not being used to load another route.
      *
650dDC**   TRLKEY        CHAIN     LDRHDR2                            79
650dDC**   *IN79         IFEQ      *OFF
650dDC**   W1RTE#        ANDNE     LHRTE
650dDC**                 MOVE      *ON           ERROR
650dDC**                 MOVE      *ON           *IN22
650dDC**                 MOVE      *ON           *IN01
650dDC**   ERRMSG        IFEQ      *BLANKS
650dDC**   DESC(7)       CAT       LHRTE:1       ERRMSG
650dDC**                 EXSR      ZM0105
650dDC**                 GOTO      ENDCK2
650dDC**                 ENDIF
650dDC**                 ENDIF
     C*

CBIjA* as mentioned above -
CBIjA* In addt, below this CBId is actually checked at the beginning
CBIjA*     of zzCHK2 above, it was not getting hit down here either.
CBIdAC*  Check trailer condition status requires to display a message
CBIdAC*
CBIdAC*                  SELECT
CBIdAC*    W2TRLQ        WHENEQ    'N'
CBIdAC*    W2TKQ         ANDEQ     'N'
CBIdAC*                  MOVEL     DESC(26)      ERRMSG
CBIdAC*                  EXSR      ZM0105
CBIdAC*
CBIdAC*    W2TRLQ        WHENEQ    'N'
CBIdAC*                  MOVEL     DESC(27)      ERRMSG
CBIdAC*                  EXSR      ZM0105
CBIdAC*
CBIdAC*    W2TKQ         WHENEQ    'N'
CBIdAC*                  MOVEL     DESC(28)      ERRMSG
CBIdAC*                  EXSR      ZM0105
CBIdAC*
CBIdAC*                  ENDSL
      *
     C     ENDCK2        ENDSR
     C*----------------------------------------------------------------
     C*  ZZCHK3   Screen 3 error checking.
     C*----------------------------------------------------------------
     C*
     C     ZZCHK3        BEGSR
     C*
700eDC**                 if        %Subst(%char(w3plt#):1:5) <> lhrtid
740cDC**                 if        %Subst(%editc(w3plt#:'X'):1:5) <> lhrtid

740cMC**750aD            if        %Subst(%editc(w3plt#:'X'):1:4) <>
740cAC**750aD                      %Subst(lhrtid:2:4)
740cMC                   if        w1rtid = *blanks

740cAC                   exsr      zzGetFullRtid
740cAC                   if        error = *on
740cAC                   goto      endck3
740cAC                   endif
      *
700dAC                   exsr      zzChkMrg
700dAC                   if        ParentChild <> ' '

740aAC                   eval      Sc3ParentRtid = *blanks
740aAC                   eval      kyrtid = %subst(%editc(w3plt#:'X'):1:5)
740aAC     ttmkey        chain     ttmerg
740aAC                   if        %found(ttmerg)
740aAC                   eval      Sc3ParentRtid = ttmpri
740aAC                   else
740aAC     ttmkey        chain     ttmerg2
740aAC                   if        %found(ttmerg2)
740aAC                   eval      Sc3ParentRtid = ttmpri
740aAC                   endif
740aAC                   endif
740aAC                   if        Sc1ParentRtid <> Sc3ParentRtid
740aAC                   eval      error = '1'
740aAC                   eval      *in22 = '1'
740aAC                   movel     desc(31)      errmsg
740aAC                   exsr      zm0105
740aAC                   goto      endck3
740aAC                   endif

700dA*  Bring in ldrhdr3 rec for the pallet being loaded because it's
700dA*  different from the one scanned on screen1
700eDC**                 eval      lhrtid3 = %Subst(%char(w3plt#):1:5)
740cDC**                 eval      lhrtid3 = %Subst(%editc(w3plt#:'X'):1:5)
740cMC                   eval      lhrtid3 = rhrtid
700dAC     lhkey3        chain(n)  ldrhdr3
700dAC                   eval      w1rte# = lhrte
700dAC                   endif
740cAC                   else
740cAC                   eval      w3rtid = w1rtid
700dAC                   endif

750bAC                   if        %Subst(w3rtid:2:4) <>
750bAC                             %Subst(%editc(w3plt#:'X'):1:4)
750bAC                   eval      error = *on
750bAC                   eval      *in23 = *on
750bAC                   eval      errmsg = desc(30)
750bAC                   exsr      zm0105
750bAC                   goto      endck3
750bAC                   endif
     C*
     C                   MOVE      *OFF          ERROR
     C                   MOVE      *BLANKS       ERRMSG
     C                   MOVE      LHRTID        RTEID#            5
     C                   MOVE      '0'           MRGPLT
     C*
     C     RTN75         TAG

     C                   select

700cMC                   when      client = cheney
700cMC     DIGT45        IFEQ      '75'
700cMC                   EXSR      ZZRTID
700cMC     ERROR         CABEQ     *ON           ENDCK3
700cMC                   Z-ADD     LBPAL#        W3PLT#
700cMC                   Z-ADD     LBPAL#        PLTID
700cMC                   MOVE      LBRTE         RTEID#
700cMC                   GOTO      CHAIN
700cMC                   SETON                                        2628
700cMC                   ENDIF

     C                   endsl
     C*
530eMC*  The last two numbers of the route ID # have being added to the
     C*  pallet id label (only) to prevent loading a pallet into the
     C*  wrong trailer since the actual pallet ids (in BFC files) have
     C*  two zeros as first digits and the same pallet id numbers are
     C*  used in all routes, one could load a pallet on any trailer
     C*  without knowing that it belongs to a different route.
     *
650eA*  Disregard the previous 530e comments about using the last 2 char
650eA*  of route id to verify pallet, we are now using the full route
650eA*  id + pallet id to verify the pallet.
     C*
     C*  Verify pallet # entered.
     C*
530eD ***                MOVE      W1RTE#        RTE1
530eMC                   MOVE      lhrtid        RTE1
     C                   Z-ADD     W3PLT#        PLTID
740cDC**                 movel     w3plt#        w3rtid
     C*
650eDC**                 call      'ADJUST'
650eDC**                 parm      '*RIGHT  '    $ccmd             8
530eD ***                parm      w1rte#        $cstr            30
650eDC**                 parm      lhrtid        $cstr            30
650eDC**                 move      $cstr         last2rte          2 0
     C*
     C*  Pallet is not part of route being loaded
     C*
520 DC**   RTE23         IFNE      PLT12
650eDC**   last2rte      IFNE      PLT12
650eMC     rte1          IFNE      w3rtid
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN22
     C                   MOVEL     DESC(2)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK3
     C                   ENDIF
     C*
     C*  Zero out first two positions of scanned pallet id,
     C*  the first two digits are zeros in orig  pallet id.
     C*  that is how they are stored in the file.
     C*
     C                   Z-ADD     *ZEROS        PLT12

730aA*  Prevent user from loading pallet if transaction
730aA*  contains an open order audit.
730aAC                   eval      coaWhse = w1whse
730aAC                   eval      coaRtid = w3rtid
730aAC                   eval      coaPltId = pltid
730aAC                   exsr      zzchkordaud
730aAC                   if        error = '1'
730aAC                   eval      *in22 = '1'
730aAC                   goto      endck3
730aAC                   endif
     C*
CLD AC                   select

HSYbMC                   when      client = cityline
VIPaAC                             or client = vip
CSPaDC**                           or client = coastl
HYSbDC**                 when      client = cityline or
HSYbDC**                           client = halsey
CLD AC     dtkey         setll     LDRDETL
CLD AC     eqpkey        readpe(n) LDRDETL
CLD AC                   if        %eof(ldrdetl)
CLD AC                   else
CLD AC                   if        ldstrd = 0
CLD AC                   eval      error = '1'
CLD AC                   eval      *in22 = '1'
CLD AC                   movel     desc(15)      errmsg
CLD AC                   exsr      zm0105
CLD AC                   goto      endck3
CLD AC                   endif
CLD AC                   endif

HSYbAC                   when      client = halsey
HSYbAC     dtkey6        setll     LDRDETL1
HSYbAC     rtkey         readpe(n) LDRDETL1
HSYbAC                   if        %eof(ldrdetl1)
HSYbAC                   else
HSYbAC                   if        ldstrd = 0
HSYbAC                   eval      error = '1'
HSYbAC                   eval      *in22 = '1'
HSYbAC                   movel     desc(15)      errmsg
HSYbAC                   exsr      zm0105
HSYbAC                   goto      endck3
HSYbAC                   endif
HSYbAC                   endif

PFCaAC                   when      client = prestofoods
PFCaAC     dtkey6        setll     LDRDETL1
PFCaAC     rtkey         readpe(n) LDRDETL1
PFCaAC                   if        %eof(ldrdetl1)
PFCaAC                   else
PFCaAC                   eval      ldpal = ldplid
PFCaAC                   if        ldstrd = 0
PFCaAC                             and column = ldcol
PFCaAC                   eval      error = '1'
PFCaAC                   eval      *in22 = '1'
PFCaAC                   movel     desc(15)      errmsg
PFCaAC                   exsr      zm0105
PFCaAC                   goto      endck3
PFCaAC                   endif
PFCaAC                   endif

CLD AC                   endsl
     C*
     C     CHAIN         TAG
700cMC                   IF        *IN25
     C*  This is a regular route
     C     DTKEY         CHAIN     LDDREC                             79
700cMC                   ELSE
700cMC*  This is a Breakers route or regular route ADD-ONS.
700cMC     DTKEY3        CHAIN     LDDREC                             79
700cMC                   ENDIF
     C*
     C                   IF        *IN79
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN22
     C*
700cMC                   IF        *IN25
     C*  Invalid pallet Id.
     C                   MOVEL     DESC(2)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK3
700cMC                   ENDIF
     C*
700cMC                   IF        NOT *IN25
700cMC     TRYTRN        IFEQ      *ON
700cMC                   MOVEL     DESC(2)       ERRMSG
700cMC                   ELSE
700cMC*  Breakers pallet not found.
700cMC                   MOVEL     DESC(10)      ERRMSG
700cMC                   ENDIF
700cMC                   EXSR      ZM0105
700cMC                   GOTO      ENDCK3
700cMC                   ENDIF
     C                   ENDIF
     C*
     C     LDENDD        IFNE      *ZEROS
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN22
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEL     DESC(3)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK3
     C                   ENDIF
     C                   ENDIF
      *
     C     MRGSCN        IFEQ      *OFF
     C                   MOVE      '1'           MRGSCN
     C                   MOVE      '1'           *IN44
     C                   GOTO      CHK44
     C                   ENDIF
     C*
     C*  Verify if pallet# input is a Loader Merged Items.
     C*
      *    If not Cheney, bypass Cheney-specific merged items logic.
     C*
CBI AC                   if        client <> cheney
CBI AC                   goto      chk44
CBI AC                   endif
     C*
     C     LDTRKZ        IFEQ      'CHEM'
     C     LDTRKZ        OREQ      'CLM'
     C     LDTRKZ        OREQ      'OYS'
     C     LDTRKZ        OREQ      'ICE'
     C     LDTRKZ        OREQ      'PKCLR'
     C     LDTRKZ        OREQ      'PKDRY'
     C     LDTRKZ        OREQ      'DRYPIR'
CBIcAC     LDTRKZ        OREQ      'FRZPIR'
CBIeAC     ldtrkz        oreq      'CF-GWB'
CBIeAC     clientLoc     andeq     cheneypntgr
CBIeAC     ldtrkz        oreq      'GWBFRZ'
CBIeAC     clientLoc     andeq     cheneypntgr
CBIfAC     ldtrkz        oreq      'CF-GWB'
CBIfAC     clientLoc     andeq     cheneyriviera
CBIhAC     ldtrkz        oreq      'FREE'
CBIhAC     clientLoc     andeq     cbist
CBIiAC     ldtrkz        oreq      'FRZMT'
CBIiAC     clientLoc     andeq     cbigo
      *
     C                   MOVE      LDPCS         PCS#              5
      *
     C     DIGT45        IFNE      '75'
      *
     C*  This is not a 'Breakers' rte, so get 'Dtkey3' key values
     C*  Rteid & Plt# from 'Ldrdetl' file.
     C                   EVAL      LBRTE = LHRTID
     C                   EVAL      LBPAL# = PLTID
     C                   ENDIF
      *
     C*  'Ldrpltq' holds Loader Merged Items detail info
     C*   of pallet being loaded
     C     DTKEY3        SETLL     LDRPLTQ
     C     DTKEY3        READE     LDRPLTQ                                79
     C*
     C*  Beginning loading merged items pallet.
     C     *IN79         IFEQ      *ON
     C                   MOVE      '1'           MRGPLT
     C                   GOTO      CHK44
     C                   ENDIF
      *
     C*  Loading of merged items pallet already started.
     C     *IN79         DOWEQ     *OFF
     C     LPSCNQ        IFEQ      *ZEROS
     C     LPSTAT        ANDEQ     *BLANK
     C                   MOVE      '1'           MRGPLT
     C                   LEAVE
     C                   ENDIF
     C     DTKEY3        READE     LDRPLTQ                                79
     C                   ENDDO
      *
     C     MRGPLT        IFEQ      *OFF
     C     $RTNCD        ANDEQ     *BLANKS
      *
      *    Loader Merged Items pallet already scanned,
      *    send msg 'Close pallet to trailer'.
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN23
     C                   MOVE      '0'           MRGSCN
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEL     DESC(12)      ERRMSG
     C                   EXSR      ZM0105
     C                   ENDIF
     C                   GOTO      ENDCK3
     C                   ENDIF
     C                   ENDIF
     C*
     C     CHK44         TAG
     C     *IN44         IFEQ      *OFF
650hAC     *IN45         andeq     *OFF
     C     $RTNCD        ANDEQ     *BLANKS
     C                   GOTO      ENDCK3
     C                   ENDIF

710bA*  Verify that transaction has been started
710bA
710bAC                   eval      pstrn# = 0
720aAC                   eval      hldpstrn# = 0
710bAC     psumkey       chain     pltsum15
720aAc                   eval      hldpstrn# = pstrn#
720aAc                   if        hldpstrn# = 0
720aAc                   eval      kytype = 'M'
720aAc     lab31key      chain     label31
720aAc                   if        %found(label31)
720cDc**   l13_lbctr#    chain     label
720cMc     l31_lbctr#    chain     label
720aAc                   if        %found(label)
720aAc                   eval      hldpstrn# = lbtrn#
720aAc                   endif
720aAc                   endif
720aAc                   endif
720aDC**   pstrn#        chain     pirtran
720aMC     hldpstrn#     chain     pirtran
710bAC                   if        not %found(pirtran)
710bAC                             or ptstat < '2'
710bAC                             or ptstat > '4'
710bAC                   eval      error = '1'
710bAC                   eval      *in22 = '1'
710bAC                   movel     desc(24)      errmsg
710bAC                   exsr      zm0105
710bAC                   goto      endck3
710bAC                   endif
      *
650hA*  If option "Verify pallet label against pick label" is Y confirm
650hA*  that the route id and pallet in the pick label scanned matches the
650hA*  the pallet label.  If the option is N the user will not scan a
650hA*  pick label and this edit will be skipped.
     *
700gMC                   if        opvfyp = 'Y'
700gAC                             and scnPckl = *on
650hAC                   movel     w3pckl        kyrtidordp
650hAC                   move      w3pckl        kytrax
650hAC     ordpkey       chain     ordp
650hAC                   if        not %found
650hAC                   eval      error = '1'
650hAC                   eval      *in31 = '1'
650hAC                   movel     desc(22)      errmsg
650hAC                   exsr      zm0105
650hAC                   goto      endck3
650hAC                   else
650hAC     orplbl        chain     label
720dAC                   if        %found
720adC                   eval      gPltId = lbpal#
720adC                   exsr      GetGenInfo
720adC                   endif
650hAC                   if        not %found
710cMC                             or (%found and lbpal# <> pltid
720dDC**                               and lbpal# < 20000)
720dMC                                 and gGenTruck)
650hAC                             or (%found and lbrte  <> w3rtid)
650hAC                   eval      error = '1'
650hAC                   eval      *in31 = '1'
650hAC                   movel     desc(23)      errmsg
650hAC                   exsr      zm0105
650hAC                   goto      endck3
650hAC                   endif
710cA
710cA*      Retrieve pallet for merge label
720dDC**                 if        %found and lbpal# >= 20000
720dDC**                           and lbpal# <= 29999
720dMC                   if        %found and gGenMerge
710cAC                             and lbtype = 'O'
710cAC     lblbl#        setll     label11
710cAC                   dow       forevr = forevr
710cAC     lblbl#        reade     label11
710cAC                   if        %eof(label11)
710cAC                   eval      error = '1'
710cAC                   eval      *in31 = '1'
710cAC                   movel     desc(23)      errmsg
710cAC                   exsr      zm0105
710cAC                   goto      endck3
710cAC                   endif
710cA*
710cA*      Look for merge label with same pallet id as scanned
710cAC                   if        lbwhse = l11_lbwhse
710cAC                             and lbrte = l11_lbrte
710cAC                             and pltid = l11_lbpal#
710cAC                             and l11_lbqpck > 0
710cAC                   leave
710cAC                   endif
710cA*
710cAC                   enddo
710cA*
710cAC                   endif
710cA
650hAC                   endif
650hAC                   endif
     C*
650hAC                   if            *in45 = *on
650hAC                             and *in44 = *off
650hAC                             and $rtncd = *blanks
650hAC                   goto      endck3
650hAC                   endif
      *
     C*  Verify trailer # entered.
     C*
     C     W3TRL#        IFNE      LHTRLR
     C     W3TRL#        OREQ      *ZEROS
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN23
     C                   IF        ERRMSG =      *BLANKS
640 DC*                  MOVEL     DESC(4)       ERRMSG
640 AC     DESC(20)      CAT       LHTRLR:1      ERRMSG
     C                   EXSR      ZM0105
     C                   ENDIF
     C                   ENDIF
      *
     C*
     C*
     C     ENDCK3        ENDSR
     C*----------------------------------------------------------------
530 AC*  ZZCHK4   Screen 4 error checking.
530 AC*----------------------------------------------------------------
530 AC*
530 AC     ZZCHK4        BEGSR
     C                   MOVE      *OFF          ERROR
     C                   MOVE      *BLANKS       ERRMSG
     C*
     C*   Verify warehouse and get description.
     C*
     C                   MOVE      '*VERIFY '    $LCMD
     C                   Z-ADD     W4WHSE        $LWHSE
     C                   CALL      'WH900'
     C                   PARM                    $LPARM
     C     $LRTN         IFEQ      '*ERROR  '
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN21
     C                   MOVE      *ON           *IN01
     C                   MOVEL     $LERM         ERRMSG
     C                   EXSR      ZM0105
     C                   ELSE
     C     $LRTN         IFEQ      '*PGMQ   '
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN21
     C                   MOVE      *ON           *IN01
     C                   MOVE      $LMSG         #MSGK
     C                   EXSR      ZMQMSG
     C                   ENDIF
     C                   ENDIF
      *
     C*  Verify route id
     C*
530aMC     HDKEY2        CHAIN(N)  ldrhdr3
     C                   IF        not %found(ldrhdr3)
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN22
     C                   IF        ERRMSG =      *BLANKS
     C                   MOVEL     DESC(16)      ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK4
     C                   ENDIF
     C                   ENDIF
      *
     C*  Verify route not closed to loader module
     C*
     C                   if        %found(ldrhdr3)
     C                             and lhclsd <> 0
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN22
     C                   IF        ERRMSG =      *BLANKS
     C                   MOVEL     DESC(17)      ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK4
     C                   ENDIF
     C                   ENDIF
      *
740cAC                   if        %Subst(w4rtid:2:4) <>
740cAC                             %Subst(%editc(w4plt#:'X'):1:4)
740cAC                   eval      error = *on
740cAC                   eval      *in23 = *on
740cAC                   eval      errmsg = desc(30)
740cAC                   exsr      zm0105
740cAC                   goto      endck4
740cAC                   endif
      *
      *  Verify pallet and trailer have been loaded to the route id entered
      *  so that it can be unloaded.
      *
530gAC                   MOVE      w4plt#        plt#              5
530gAC                   MOVE      plt#          kyplt#            7 0
740cDC**                 MOVEl     w4plt#        hldw4pltrtid      5
740bDC*    dtkey4        chain     ldrdetl
740bMC     dtkey4        chain(n)  ldrdetl
     C                   if        not %found(ldrdetl)
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN23
     C                   IF        ERRMSG =      *BLANKS
     C                   MOVEL     DESC(2)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK4
     C                   ENDIF
     C                   ENDIF
      *
     C                   if        %found(ldrdetl)
     C                             and ldendt = 0
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN23
     C                   IF        ERRMSG =      *BLANKS
     C                   MOVEL     DESC(18)      ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK4
     C                   ENDIF
     C                   ENDIF
      *
     C                   if        w4trl# <> lhtrlr
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN24
     C                   IF        ERRMSG =      *BLANKS
640 DC*                  MOVEL     DESC(4)       ERRMSG
640 AC     DESC(20)      CAT       LHTRLR:1      ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK4
     C                   ENDIF
     C                   ENDIF
      *
     C     ENDCK4        ENDSR
     C*----------------------------------------------------------------
     C*  ZZCHKL   Check if route to be loaded is already loaded.
     C*----------------------------------------------------------------
     C*
     C     ZZCHKL        BEGSR
     C                   MOVE      *OFF          ERROR
      *
700dA*  Check to see if this route is part of a merge and if so we will
700dA*  count how many pallets are on the additional routes and add them
700dA*  to the pallet counter. This logic intentionally runs before the
700dA*  original counting logic so that the ldrdetl fields end up being
700dA*  populated with the route which was entered on screen1.
700dA*
700dAC                   exsr      zzChkMrg
700dAC                   if        ParentChild <> *blanks
700dAC                   exsr      zzCntMrg
700dAC                   endif
      *
      *  Check if all pallets are loaded for this route.
      *
     C                   SETON                                        12
     C                   Z-ADD     *ZEROS        PLTCNT            3 0
700dAC                   eval      pltcnt = pltcnt + mrgCntr
     C     DTKEY2        SETLL     LDRDETL
     C     DTKEY2        READE(N)  LDRDETL                                79
     C     *IN79         DOWEQ     *OFF
     C                   ADD       1             PLTCNT
700dAC                   if        mrgCntr > 0
700dAC                   eval      *in12 = *off
700dAC                   endif
     C     LDENDD        IFEQ      *ZEROS
     C                   SETOFF                                           12
     C                   LEAVE
     C                   ENDIF
     C     DTKEY2        READE(N)  LDRDETL                                79
     C                   ENDDO
     *
     C     ENDCKL        ENDSR
     C*----------------------------------------------------------------
     C*  ZZCMD1   User defined command keys for screen 1.
     C*----------------------------------------------------------------
     C*
     C     ZZCMD1        BEGSR
     C*
     C*  Command keys to check BEFORE verification and update.
     C*
     C     CMDCHK        IFEQ      '*BEFORE '
     C*
     C*  Test for F4 - Lookup
     C*
     C     *INKD         IFEQ      *ON
     C                   MOVE      *ON           CMDTKN
     C                   Z-ADD     0             ROW#
     C                   MOVE      ROWIN         ROW
     C                   Z-ADD     0             COL#
     C                   MOVE      COLIN         COL
     C                   SELECT
     C*
     C                   OTHER
     C*
     C*     Cursor not on a valid lookup field.
     C*
     C                   MOVE      *ON           ERROR
     C                   EXSR      ZM9905
     C                   ENDSL
     C                   GOTO      ENDCM1
     C                   ENDIF
     C                   ENDIF
     C*
     C*  Command keys to check AFTER verification and update.
     C*
     C     CMDCHK        IFEQ      '*AFTER  '
     C*
     C                   ENDIF
     C*
     C     ENDCM1        ENDSR
     C*----------------------------------------------------------------
     C*  ZZCMD2   User defined command keys for screen 2.
     C*----------------------------------------------------------------
     C*
     C     ZZCMD2        BEGSR
     C*
     C*  Command keys to check BEFORE verification and update.
     C*
     C     CMDCHK        IFEQ      '*BEFORE '
     C*
     C*
640 AC*  Command keys to check AFTER verification and update.
640 AC*
640 AC*  Test for F4 - Lookup
640 AC*
640 AC     *INKD         IFEQ      *ON
640 AC                   MOVE      *ON           CMDTKN
640 AC                   Z-ADD     0             ROW#
640 AC                   MOVE      ROWIN         ROW
640 AC                   Z-ADD     0             COL#
640 AC                   MOVE      COLIN         COL
     C*
640 AC                   SELECT
640 AC*
640 A*
640 AC     csrfld        wheneq    'W2TRL#'
640 AC                   move      *off          error
640 AC                   move      '*LOOKUP '    lcmd
640 AC                   z-add     1             lwhse
640 AC                   movel     $lwhse        $kwhse
640 AC                   move      #prog         lprg
640 AC                   movel     'TRAILR'      $kcode
640 AC                   move      *blanks       ltcode
640 AC                   move      '1'           sort
640 AC                   call      'EQ910'
640 AC                   parm                    $prtky
640 AC                   parm                    lrtn
640 AC                   parm                    ltcode
640 AC                   parm                    sort
640 AC     lrtn          ifeq      '*SELECT '
640 AC                   movel     ltcode        w2trl#
640 AC*    $lcode        ifeq      '7'
640 AC*    $paorc        andne     'U'
640 AC*                  move      *on           error
640 AC*                  move      *on           *in01
640 AC*                  move      *on           *in25
640 AC*                  move      *blanks       errmsg
640 AC*                  movea     desc(14)      errmsg
640 AC*                  exsr      zm0105
640 AC*                  else
640 AC                   exsr      zztrlr
640 AC*                  endif
640 AC                   endif
     C*
640 AC                   other
640 AC*
640 AC*     Cursor not on a valid lookup field.
640 AC*
640 AC                   MOVE      *ON           ERROR
640 AC                   EXSR      ZM9905
640 AC                   ENDSL
640 AC                   ENDIF
640 AC                   ENDIF
     C*
     C     ENDCM2        ENDSR
     C*----------------------------------------------------------------
     C*  ZZCMD3   User defined command keys for screen 3.
     C*----------------------------------------------------------------
     C*
     C     ZZCMD3        BEGSR
     C*
     C*  Command keys to check BEFORE verification and update.
     C*
     C     CMDCHK        IFEQ      '*BEFORE '
     C*
     C                   ENDIF
     C*
     C*  Command keys to check AFTER verification and update.
     C*
     C     CMDCHK        IFEQ      '*AFTER  '
     C*
     C                   ENDIF
     C*
     C     ENDCM3        ENDSR
     C*----------------------------------------------------------------
530 AC*  ZZCMD4   User defined command keys for screen 4.
530 AC*----------------------------------------------------------------
530 AC*
530 AC     ZZCMD4        BEGSR
     C*
     C*  Command keys to check BEFORE verification and update.
     C*
     C     CMDCHK        IFEQ      '*BEFORE '
     C*
     C                   ENDIF
     C*
     C*  Command keys to check AFTER verification and update.
     C*
     C     CMDCHK        IFEQ      '*AFTER  '
     C*
     C                   ENDIF
     C*
     C     ENDCM4        ENDSR
     C*----------------------------------------------------------------
530bAC*  zzCrtTrn  Create LOAD transaction record.
530bAC*
530bAC     zzCrtTrn      BEGSR
     C*
     *  Get transaction #
     C                   call      'PIRTRN#'
     C                   parm      0             pttrn#            7 0
     C                   eval      ptstat = '4'
     C                   eval      pttask = 'LOAD'
     C     pttask        chain     task
     C                   if        %found(task)
     C                   eval      ptcat = tkcat
     C                   eval      ptsub = tksub
     C                   else
     C                   eval      ptcat = ' '
     C                   eval      ptsub = ' '
     C                   endif
     C                   eval      ptwhse = ldwhse
     C                   eval      ptwhdp = *blanks
     C                   eval      ptstyp = *blanks
     C                   eval      ptshft = usshft
     C                   eval      ptcrew = uscrew
     C                   eval      ptemp# = ldemp#
     C                   eval      ptcube = ldcube
     C                   eval      ptswgt = 0
     C                   eval      ptpcs  = ldpcs
     C                   eval      ptaisl = 0
     C                   eval      ptqty1 = 0
     C                   eval      ptqty2 = 0
     C                   eval      ptqty3 = 0
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ptgdte = $cvd8o
     C                   time                    ptgtim
     C                   eval      ptsdte = ldstrd
     C                   eval      ptstim = ldstrt
     C                   eval      ptrdte = $cvd8o
     C                   eval      ptedte = ldendd
     C                   eval      ptetim = ldendt
     C                   eval      ptetyp = *blanks
     C                   eval      ptcdte = ldendd
     C                   eval      ptctim = ldendt
     C                   eval      ptrtpo = ldrtid
     C                   eval      ptgrp1 = *blanks
     C                   eval      ptgrp2 = *blanks
     * Calc direct/indirect time
     C                   exsr      zzTime
710bDC**                 write     ptrec                                79
     C     *in79         ifeq      '1'
     C                   move      '1'           error
     C                   exsr      zm71
     C                   goto      endcrtt
     C                   endif
640aAc                   exsr      zzwrttrand
     C*
     C     endcrtt       endsr
     C*
710aA*----------------------------------------------------------------
710aA*  zzLoad  Create LOAD transaction
710aA*
710aAC     zzLoad        begsr

     C                   eval      @pdate = ldstrd
     C                   eval      @ptime = ldstrt
     C                   call      'ADJTRAN2'
     C                   parm      '*CRTSTRT'    @pcmd2
     C                   parm                    #job
     C                   parm      '*INTER  '    @ptype
     C                   parm      0             @ptrn#
     C                   parm      'LOAD'        @ptask
     C                   parm      ldwhse        @pwhse
     C                   parm      ' '           @pwhdp
     C                   parm      ' '           @pstyp
     C                   parm      ldcube        @pcube
     C                   parm      0             @pswgt
     C                   parm      ldpcs         @ppcs
     C                   parm      0             @paisl
     C                   parm      0             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      ldrtid        @prte
     C                   parm      ' '           @ppo
     C                   parm      ' '           @pgrp1
     C                   parm      ' '           @pgrp2
     C                   parm                    @pdate
     C                   parm                    @ptime
     C                   parm      #curruser     @puser
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     *  Close the transaction
     C                   eval      pntrn# = @ptrn#
     C                   exsr      zzClose
     *
     C                   endsr
710aA*----------------------------------------------------------------
710aA*  zzClose  Close transaction
710aA*
710aAC     zzClose       begsr

     C                   call      'ADJTRAN2'
     C                   parm      '*CLOSE  '    @pcmd2
     C                   parm                    #job
     C                   parm      '*INTER  '    @ptype
     C                   parm      pntrn#        @ptrn#
     C                   parm      ' '           @ptask
     C                   parm      ldwhse        @pwhse
     C                   parm      ' '           @pwhdp
     C                   parm      ' '           @pstyp
     C                   parm                    @pcube
     C                   parm                    @pswgt
     C                   parm                    @ppcs
     C                   parm      0             @paisl
     C                   parm      0             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      ldrtid        @prte
     C                   parm      ' '           @ppo
     C                   parm      ' '           @pgrp1
     C                   parm      ' '           @pgrp2
     C                   parm      0             @pdate
     C                   parm      0             @ptime
     C                   parm      #curruser     @puser
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     C                   endsr
710aA*----------------------------------------------------------------
710aA*  zzIdle  Create IDLE transaction
710aA*
710aAC     zzIdle        begsr

     C                   eval      @pdate = 0
     C                   eval      @ptime = 0
     C                   call      'ADJTRAN2'
     C                   parm      '*CRTSTRT'    @pcmd2
     C                   parm                    #job
     C                   parm      '*INTER  '    @ptype
     C                   parm      0             @ptrn#
     C                   parm      'IDLE'        @ptask
     C                   parm      ldwhse        @pwhse
     C                   parm      ' '           @pwhdp
     C                   parm      ' '           @pstyp
     C                   parm      0             @pcube
     C                   parm      0             @pswgt
     C                   parm      0             @ppcs
     C                   parm      0             @paisl
     C                   parm      0             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      ldrtid        @prte
     C                   parm      ' '           @ppo
     C                   parm      ' '           @pgrp1
     C                   parm      ' '           @pgrp2
     C                   parm                    @pdate
     C                   parm                    @ptime
     C                   parm      #curruser     @puser
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
710aA*  The only time this value of pntrn# is used is at LR to close
710aA*  the last IDLE tran
710aAC                   eval      pntrn# = @ptrn#
     *
     C                   endsr
     C*----------------------------------------------------------------
     C*  ZZFIL1   Fill screen 1 fields with info from file.
     C*----------------------------------------------------------------
     C*
     C     ZZFIL1        BEGSR
     C*
     C                   MOVE      *BLANKS       W1RTE#
520bAC                   MOVE      *BLANKS       W1RTID
740cDC**                 MOVE      *BLANKS       W1RTID10
     C                   MOVE      *BLANKS       $RTNCD
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*  ZZFIL2   Fill screen 2 fields with info from file.
     C*----------------------------------------------------------------
     C*
     C     ZZFIL2        BEGSR
     C*
     C                   EVAL      W2RTE# = W1RTE#
     C                   EVAL      W2TRL# = *BLANKS
CBIdAC                   EVAL      W2TRLQ = *BLANKS
CBIdAC                   EVAL      W2TKQ  = *BLANKS
CBIdAC                   EVAL      W2LODQ = *BLANKS
      *
      *
      *  Get loading door number
     C                   EVAL      W2DOOR = *BLANKS
     C     RTKEY         CHAIN     RTEHED                             79
     C     *IN79         IFEQ      *OFF
      *
530f C                   SELECT
530fAC                   WHEN      CLIENT = CHENEY
     C     OHKEY         SETLL     ORDH1
     C     OHKEY         READE     ORDH1                                  79
     C     *IN79         IFEQ      *OFF
     C                   EVAL      DSMISC = OHMISC
     C                   EVAL      W2DOOR = DSDOOR
     C                   ENDIF
530FAC                   OTHER
530FAC     DCKEY         SETLL     DOCMTRX2
530FAC     DCKEY         READE     DOCMTRX2                               79
530FAC                   IF        NOT *IN79
530FAC                   MOVEL     DMDOOR        W2DOOR
530FAC                   MOVE      DMDOOR        DSDOOR
530FAC                   ENDIF
530FAC                   ENDSL
     C                   ENDIF
      *
700dA*  Check to see if this route is part of a merge and if so we will
700dA*  count how many pallets are on the additional routes and add them
700dA*  to the screen counter. This logic intentionally runs before the
700dA*  original counting logic so that the ldrdetl fields end up being
700dA*  populated with the route which was entered on screen1.
700dA*
700dAC                   exsr      zzChkMrg
700dAC                   if        ParentChild <> *blanks
700dAC                   exsr      zzCntMrg
700dAC                   endif
      *
      *  Find how many pallets in route being processed.
      *
     C                   EVAL      W2CNTR = *ZEROS
700dAC                   eval      w2cntr = w2cntr + mrgCntr
530cDC**   HDKEY         SETLL     LDRDETL
530cDC**   HDKEY         READE(N)  LDRDETL                                79
530cMC     DTKEY5        SETLL     LDRDETL
530cMC     DTKEY5        READE(N)  LDRDETL                                79
      *
     C                   DOW       *IN79 = *OFF
     C     LDENDT        IFEQ      *ZEROS
     C                   EVAL      W2CNTR = w2CNTR + 1
     C                   ENDIF
530cDC**   HDKEY         READE(N)  LDRDETL                                79
530cMC     DTKEY5        READE(N)  LDRDETL                                79
     C                   ENDDO
      *
650bAC                   eval      hldrte = lhrte
650bAC                   eval      hldrtid = lhrtid
      *
     C     ENDFL2        ENDSR
     C*----------------------------------------------------------------
     C*  ZZFIL3   Fill screen 3 fields with info from file.
     C*----------------------------------------------------------------
     C*
     C     ZZFIL3        BEGSR
     C*
700cMC                   SETON                                        25
     C                   SETOFF                                       2628
     C                   EVAL      W3RTE# = W1RTE#
      *
     C                   EVAL      W3PLT# = *ZEROS
700cMC                   EVAL      W3TRN# = *ZEROS
      *
650hAC                   EVAL      w3pckl = *ZEROS
     C                   EVAL      W3TRL# = *BLANKS
      *
     C                   SUBST     W3RTE#:2      DIGT45            2

     C                   select

     C                   when      client = cheney

     C     DIGT45        IFEQ      '75'
      *  This is a Breakers route, scan tran# instead of plt#
700cMC                   SETOFF                                       25
     C                   SETON                                        2628
     C                   GOTO      GETDOR
     C                   ENDIF
      *
700cMC     TRYTRN        IFEQ      *ON
700cM *  This could be a regular route ADD-ONS, scan tran# instead of plt#
700cMC                   MOVE      '75'          DIGT45
700cMC                   SETOFF                                       25
700cMC                   ENDIF
      *
     C                   endsl
      *
     C     GETDOR        TAG
      *
      *  Get loading door number
     C                   EVAL      W3DOOR = *BLANKS
     C     RTKEY         CHAIN     RTEHED                             79
     C     *IN79         IFEQ      *OFF
      *
530F C                   SELECT
530FAC                   WHEN      CLIENT = CHENEY
     C     OHKEY         SETLL     ORDH1
     C     OHKEY         READE     ORDH1                                  79
     C     *IN79         IFEQ      *OFF
     C                   EVAL      DSMISC = OHMISC
     C                   EVAL      W3DOOR = DSDOOR
     C                   ENDIF
530FAC                   OTHER
530FAC     DCKEY         SETLL     DOCMTRX2
530FAC     DCKEY         READE     DOCMTRX2                               79
530FAC                   IF        NOT *IN79
530FAC                   MOVEL     DMDOOR        W3DOOR
530FAC                   MOVE      DMDOOR        DSDOOR
530FAC                   ENDIF
530FAC                   ENDSL
     C                   ENDIF
      *
700dA*  Check to see if this route is part of a merge and if so we will
700dA*  count how many pallets are on the additional routes and add them
700dA*  to the screen counter. This logic intentionally runs before the
700dA*  original counting logic so that the ldrdetl fields end up being
700dA*  populated with the route which was entered on screen1.
700dA*
700dAC                   exsr      zzChkMrg
700dAC                   if        ParentChild <> *blanks
700dAC                   exsr      zzCntMrg
700dAC                   endif
      *
      *  Find how many pallets in route being processed.
      *
     C                   EVAL      W3CNTR = *ZEROS
700dAC                   eval      w3cntr = w3cntr + mrgCntr
530cDC**   HDKEY         SETLL     LDRDETL
530cDC**   HDKEY         READE(N)  LDRDETL                                79
530cMC     DTKEY5        SETLL     LDRDETL
530cMC     DTKEY5        READE(N)  LDRDETL                                79
      *
     C                   DOW       *IN79 = *OFF
     C     LDENDT        IFEQ      *ZEROS
     C                   EVAL      W3CNTR = W3CNTR + 1
     C                   ENDIF
530cDC**   HDKEY         READE(N)  LDRDETL                                79
530cMC     DTKEY5        READE(N)  LDRDETL                                79
     C                   ENDDO
      *
     C     ENDFL3        ENDSR
     C*----------------------------------------------------------------
530 AC*  ZZFIL4   Fill screen 4 fields with info from file.
530 AC*----------------------------------------------------------------
530 AC*
530 AC     ZZFIL4        BEGSR
      *
     C                   EVAL      W4WHSE = W1WHSE
     C                   EVAL      W4RTID = *blanks
     C                   EVAL      W4PLT# = *ZEROS
     C                   EVAL      W4TRL# = *BLANKS
530g C                   EVAL      KYPLT# = *ZEROS
      *
     C     ENDFL4        ENDSR
     C*----------------------------------------------------------------
     C*  ZZGET1   Get . . .
     C*----------------------------------------------------------------
     C*
     C     ZZGET1        BEGSR
     *
      *
     C     ENDGT1        ENDSR
     C*----------------------------------------------------------------
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*----------------------------------------------------------------
     C*
     C     ZZINZ         BEGSR
     C                   MOVE      #PROG         $LPRG
     C                   MOVE      #PROG         $CVPRG
     C                   MOVE      #PROG         $PPRG            10
     C                   MOVE      *OFF          *IN44
700cMC                   MOVE      *OFF          TRYTRN            1
     C                   MOVE      *OFF          MRGPLT            1
     C                   MOVE      '1'           MRGSCN            1
     C                   MOVE      *BLANKS       $RTNCD            8
CBIdAC                   MOVE      '0'           HEADER            1
CBIdAC                   MOVE      *ON           ADDING            1
     *
CBIaA*    If Cheney, position cursor on screen1 to route.
     *
CBIaAC                   if        client = cheney
CBIaAC                   eval      *in02 = '1'
CBIdAC                   eval      *in66 = '1'
CBIaAC                   else
520bAC                   eval      *in09 = '1'
CBIaAC                   endif
     *
     *  Define key for main file.
     *
     C     HDKEY         KLIST
     C                   KFLD                    W1WHSE
     C                   KFLD                    W1RTE#
     *
530 AC     HDKEY2        KLIST
     C                   KFLD                    W4WHSE
     C                   KFLD                    W4RTID
     *
520bAC     HDKEY3        KLIST
     C                   KFLD                    W1WHSE
     C                   KFLD                    W1RTID
     *
650bAC     HDKEY4        KLIST
650bAC                   KFLD                    W1WHSE
650bAC                   KFLD                    HLDRTE
650bAC                   KFLD                    HLDRTID
     *
     C     DTKEY         KLIST
     C                   KFLD                    W1WHSE
700dDC**                 KFLD                    W1RTE#
700dMC                   KFLD                    LHRTE
     C                   KFLD                    LHRTID
     C                   KFLD                    PLTID
      *
     C     DTKEY2        KLIST
     C                   KFLD                    W1WHSE
700dDC**                 KFLD                    W1RTE#
700dMC                   KFLD                    lhrte
530hAC                   KFLD                    LHRTID
      *
700cMC     LBLKEY        KLIST
700cMC                   KFLD                    W1WHSE
700cMC                   KFLD                    W3TRN#
      *
      *  Key to be used when processing Breakers route
     C     DTKEY3        KLIST
     C                   KFLD                    W1WHSE
700dDC**                 KFLD                    W1RTE#
700dMC                   KFLD                    lhrte
     C                   KFLD                    LBRTE
     C                   KFLD                    LBPAL#
      *
530 AC     DTKEY4        KLIST
530 AC                   KFLD                    w4whse
530 AC                   KFLD                    lhrte
740cMC                   KFLD                    w4rtid
740cDC**                 KFLD                    hldw4pltrtid
530gMC                   KFLD                    kyplt#
530gDC*                  KFLD                    w4plt#
      *
530cAC     DTKEY5        KLIST
530cAC                   KFLD                    w1whse
530cAC                   KFLD                    lhrte
530cAC                   KFLD                    lhrtid
     *
HSYbAC     DTKEY6        KLIST
HSYbAC                   KFLD                    w1whse
HSYbAC                   KFLD                    lhrtid
HSYbAC                   KFLD                    column
HSYbAC                   KFLD                    pltid
      *
     C     RTKEY         KLIST
     C                   KFLD                    W1WHSE
     C                   KFLD                    LHRTID
      *
     C     OHKEY         KLIST
     C                   KFLD                    RHPBAT
     C                   KFLD                    W1WHSE
     C                   KFLD                    LHRTID
      *
530f C     DCKEY         KLIST
530f C                   KFLD                    W1WHSE
530f C                   KFLD                    LHRTID
     C*
     C     TRLKEY        KLIST
     C                   KFLD                    W1WHSE
     C                   KFLD                    HLDTRL            8
     *
     C     EQPKEY        KLIST
     C                   KFLD                    W1WHSE
     C                   KFLD                    W1RTE#
     C                   KFLD                    LHRTID
     *
650dAC     ttmkey        KLIST
650dAC                   KFLD                    W1WHSE
650dAC                   KFLD                    kyrtid
     *
700dAC     ttmkey1       KLIST
700dAC                   KFLD                    W1WHSE
700dAC                   KFLD                    kyrte1
700dAC                   KFLD                    kyrtid1
     *
650fAC     lhkey3        KLIST
650fAC                   KFLD                    W1WHSE
650fAC                   KFLD                    lhrtid3
      *
650hA*  Define key for OPTIONS file.
650hA
650hAC     opkey         klist
650hAC                   kfld                    w1whse
650hAC                   kfld                    opcode
650hA*
650hA*  Define key for ORDP file.
650hA
650hAC     ordpkey       klist
650hAC                   kfld                    w1whse
650hAC                   kfld                    kyrtidordp
650hAC                   kfld                    kytrax
      *
710bA*  Define key for PLTSUM file.
710bA
710bAC     psumkey       klist
710bAC                   kfld                    w1whse
710bAC                   kfld                    lhrtid
710bAC                   kfld                    pltid

720aA*  Define key for LABEL31 file.
720aA
720aAC     lab31key      klist
720aAC                   kfld                    w1whse
720aAC                   kfld                    lhrtid
720aAC                   kfld                    kytype
720aAC                   kfld                    pltid

     C                   ENDSR
     C*----------------------------------------------------------------
     C*  ZZINZ2   Program initialization. Called from main line.
     C*----------------------------------------------------------------
     C*
     C     ZZINZ2        BEGSR
     C*
     C                   MOVE      *ON           REFRSH
     C                   MOVE      *OFF          MORE              1
     C                   MOVE      *OFF          DONE              1
     C                   MOVE      *OFF          EXCPTN            1
     C                   MOVE      *ZEROS        HLDSTT            6 0
     C                   MOVE      *ZEROS        HLDSTD            8 0
     *
     *    - Get default warehouse for the user.
     *
     C                   call      'GETUSER'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     C                   parm      0             #emp#             5 0
     C                   parm                    #fnam            15
     C                   parm                    #init             1
     C                   parm                    #lnam            20
     C                   parm                    #whdp             5
     C                   parm                    #styp             1
     C                   parm                    #shft             6
     C                   parm                    #crew             6
     C                   parm      0             #nhrs             3 1
     C                   parm                    #rtn              8
     *
     C                   Z-ADD     #WHSE         W1WHSE
      *
      *
      *  Check if user id is found in user file.
      *
     C     #EMP#         IFEQ      *ZEROS
     C                   MOVE      *ON           ERROR
520bAC**                 MOVE      *ON           *IN02
     C                   MOVEA     DESC(8)       ERRMSG
     C                   EXSR      ZM0105
     C                   ENDIF
      *
      *  Check if user is a loading supervisor or is allowed to close rtes.
      *
     C                   CALL      'CHKLIST'
     C                   PARM                    #PROG
     C                   PARM      ' '           @POPT            20
     C                   PARM                    #USER
     C                   PARM      ' '           @PRTN             8
     C*
     C     @PRTN         IFEQ      '*YES'
     C                   MOVE      *ON           *IN27
     C                   ENDIF
     C*
650hA*  Get loader options.
650hA
650hAC                   eval      opcode = '*LOADER'
650hAC     opkey         chain     options
     C*
     C                   EXSR      SCR01I
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*  ZZPG19   Process PIR merged items pallet
     C*----------------------------------------------------------------
     C*
     C     ZZPG19        BEGSR
     *
     C                   Z-ADD     W3PLT#        PLTID
     C                   MOVE      LHWHSE        WHSE              3
      *
     C                   CALL      'LOADR19'
     C                   PARM                    WHSE
     C                   PARM                    LHRTE
     C                   PARM                    RTEID#
     C                   PARM                    PLT#
     C                   PARM                    DSDOOR
     C                   PARM                    PCS#
     C                   PARM                    $RTNCD
     C*
     C*  Check if all items in Loader Merged pallet were scanned.
     C*  if true, redisplay 'Plt Load' screen 3 along with
     C*  msg; 'Close pallet to trailer'.
     C*
     C     $RTNCD        IFEQ      '*OK     '
     C                   MOVE      *BLANKS       ERRMSG
     C                   MOVE      *ON           *IN23
     C                   MOVE      DESC(12)      ERRMSG
     C                   EXSR      ZM0105
     C                   ELSE
     C                   Z-ADD     *ZEROS        W3PLT#
650hAC                   Z-ADD     *ZEROS        W3PCKL
700cMC                   Z-ADD     *ZEROS        W3TRN#
     C                   ENDIF
      *
      *
     C                   MOVE      '0'           MRGPLT
     C                   MOVE      '03 '         NXTSCR
      *
     C     ENDG19        ENDSR
     C*----------------------------------------------------------------
700cMC*  ZZRTID   Get route id from label record
700cMC*----------------------------------------------------------------
700cMC*
700cMC     ZZRTID        BEGSR
700cM*
700cMC     LBLKEY        CHAIN     LABEL90                            79
700cMC     *IN79         IFEQ      *ON
700cMC                   MOVE      *ON           ERROR
700cMC                   MOVE      *ON           *IN22
700cMC                   MOVEA     DESC(9)       ERRMSG
700cMC                   EXSR      ZM0105
700cMC                   GOTO      ENDTID
700cMC                   ENDIF
700cM *
700cMC     ENDTID        ENDSR
     C*----------------------------------------------------------------
530bA*
530bA*  ZZTIME   Calculate direct/indirect time
530bA*
530bAC     zztime        begsr
     *
     *      Calculate length of time in minutes for output.
     *
     C                   eval      dshms = ptstim
     *   Round up minute, if the seconds is >= 30
     C                   if        dsss >= 30
     C                   add       1             dsmm
     C                   endif
     C                   eval      tmpbeg = dshh * 60
     C                   add       dsmm          tmpbeg
     *
     C                   eval      dshms = ptetim
     *   Round up minute, if the seconds is >= 30
     C                   if        dsss >= 30
     C                   add       1             dsmm
     C                   endif
     *
     *   If the ending time is < starting time, than
     *   we have gone past the midnight.
     *
     C                   if        ptetim < ptstim
     C                   add       24            dshh
     C                   endif
     C                   eval      tmpend = dshh * 60
     C                   add       dsmm          tmpend
     *
     C                   eval      timlen = tmpend - tmpbeg
     C                   if        timlen < 0
     C                   eval      timlen = 0
     C                   endif
     *
     C     pttask        chain     task
     C                   if        not %found(task)
     C                   eval      ptimin = 0
     C                   eval      ptdmin = 0
     C                   goto      endtim
     C                   endif
     C                   if        tktype = 'I'
     C                   eval      ptimin = timlen
     C                   eval      ptdmin = 0
     C                   else
     C                   eval      ptdmin = timlen
     C                   eval      ptimin = 0
     C                   endif
     *
     C     endtim        endsr
640 A*----------------------------------------------------------------
640 A*
640 A*  ZZTRLR   Validate trailer.
640 A*
640 A*----------------------------------------------------------------
     C     zztrlr        begsr
     *
     C                   movel     w2trl#        hldtrl
     *
     C     trlkey        chain     ldrhdr2                            79
     C                   if        not *in79
     C                   if        w1rte# <> lhrte   or
     C                             W1rtid <> *blanks and
     C                             W1rtid <> lhrtid
700bAC                             and w1rte# <> lhrte
     *
650dA*   In order to allow the same trailer to be assigned to multiple routes,
650dA*   all of the routes must be part of the same parent/child merged route
650dA*   in the Trax merge file.
650dA*
650dA*   Find out if the route which already has the trailer assigned is
650dA*   a Trax merged route, and if so, whether it's the parent or a child.
650dA*
650dAC                   eval      ParentChild = *blanks
650dAC                   eval      kyrtid = lhrtid
650dAC     ttmkey        chain     ttmerg
650dAC                   if        %found(ttmerg)
650dAC                   eval      ParentChild = 'P'
650dAC                   eval      Sc1ParentRtid = ttmpri
650dAC                   else
650dAC     ttmkey        chain     ttmerg2
650dAC                   if        %found(ttmerg2)
650dAC                   eval      ParentChild = 'C'
650dAC                   eval      Sc1ParentRtid = ttmpri
650dAC                   endif
650dAC                   endif
650dAC                   if        ParentChild = *blanks
650dAC                   goto      trlrErr
650dAC                   endif
650dA
650dAC                   eval      kyrtid = hldrtid
650dA
650dAC                   select
650dA
650dAC                   when      ParentChild = 'P'
650dAC     ttmkey        chain     ttmerg2
650dAC                   if        %found(ttmerg2) and ttmpri = Sc1ParentRtid
650dAC                   goto      endtrl
650dAC                   endif
650dAC
650dAC                   when      ParentChild = 'C'
650dAC                   if        hldrtid = Sc1ParentRtid
650dAC                   goto      endtrl
650dAC                   endif
650dAC
650dAC                   endsl
650dAC
650dAC     trlrErr       tag
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C     desc(21)      cat       lhrte:1       errmsg
     C     errmsg        cat       lhrtid:1      errmsg
     C                   exsr      zm0105
     C                   endif
     C                   endif
CBIjA* Change here is CBIb was moved from zzchk2 to here, zztrlr.

CBIbA*
CBIbA*      Get loader start and end times.
CBIbA*
CBIbAC                   if        client = cheney
CBIbAC                   call      getloa
CBIbAC                   parm                    #whse
CBIbAC                   parm      0             stime
CBIbAC                   parm      0             etime

CBIbAC     trlkey        setll     ldrhhdr2
CBIbAC                   dou       forevr <> forevr
CBIbAC     trlkey        reade     ldrhhdr2
CBIbAC                   if        %eof(ldrhhdr2)
CBIbAC                   leave
CBIbAC                   endif

CBIbAC                   if        lhhcld = today

CBIbAC                   if        lhhclt >= stime
CBIbAC                             and lhhclt <= etime
CBIbAC                   eval      error = *on
CBIbAC                   eval      *in22 = *on
CBIbAC                   eval      *in01 = *on
CBIbAC                   if        errmsg = *blanks
CBIbAC     desc(7)       cat       lhrte:1       errmsg
CBIbAC                   exsr      zm0105
CBIjD *                  goto  **  endck2
CBIjMC                   goto      endtrl
CBIbAC                   endif
CBIbAC                   endif
CBIbAC                   endif

CBIbAC                   enddo
CBIbAC                   endif
     *
     C     endtrl        endsr
     C*----------------------------------------------------------------
     C*  ZZUPD1   Update for screen 1.
     C*----------------------------------------------------------------
     C*
     C     ZZUPD1        BEGSR
     C*
     C                   MOVE      *OFF          ERROR
     C*
     C                   EXSR      SCR02I
     C*
     C     ENDUP1        ENDSR
     C*----------------------------------------------------------------
     C     ZZUPD2        BEGSR
     C*----------------------------------------------------------------
     C*
     C                   MOVE      *OFF          ERROR
     C*
530hDC*    HDKEY         CHAIN     LHREC                              79
650bDC**   DTKEY5        CHAIN     LHREC                              79
650bMC     hdkey4        CHAIN     LHREC                              79
     C*  Move route starting loading date and time into Ldrhdr file.
     C*
     C                   MOVE      '*CURCMD '    $CVCMD
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD8O        LHSTRD
700fAC                   eval      sav_lhstrd = lhstrd
     C*
     C                   TIME                    LHSTRT
700fAC                   eval      sav_lhstrt = lhstrt
     C*
      *
      *  Get loader emp#
      *
     C     #USER         CHAIN     PIRUSER                            79
     C     *IN79         IFEQ      *OFF
     C                   Z-ADD     USEMP#        LHEMP#
     C                   ENDIF
      *
      *  Load trailer# and set route loading to 'started' status.
      *
     C                   MOVEL     W2TRL#        LHTRLR
     C                   MOVE      '2'           LHSTAT
      *
     C*
     C                   UPDATE    LHREC
     *
650fA*   When a trailer is assigned, look for parent or child routes
650fA*   (add-ons) that are associated with this route and update
650fA*   their trailer in loader header too.
     *
650fAC                   exsr      zzAddOns
     *
     C                   MOVE      *OFF          ERROR
     C*
CBIdAC                   CLEAR                   LCHREC
CBIdAC                   Z-ADD     LHWHSE        LCHWHS
CBIdAC                   MOVE      LHRTID        LCHRTI
CBIdAC                   MOVE      LHRTE         LCHRTE
CBIdAC                   MOVE      LHTRLR        LCHTRL
CBIdAC                   Z-ADD     LHSTRD        LCHSTD
CBIdAC                   Z-ADD     LHSTRT        LCHSTT
CBIdAC                   Z-ADD     LHEMP#        LCHEMP
CBIdAC                   WRITE     LCHREC
CBIdAC                   MOVE      '1'           HEADER
      *
CBIdAC                   CLEAR                   LCDREC
CBIdAC                   Z-ADD     LHWHSE        LCDWHS
CBIdAC                   MOVE      LHRTID        LCDRTI
CBIdAC                   MOVE      LHRTE         LCDRTE
CBIdAC                   Z-ADD     LHSTRD        LCDSTD
CBIdAC                   Z-ADD     LHSTRT        LCDSTT
CBIdAC                   Z-ADD     LHEMP#        LCDEMP
      *
CBIdAC     W2TRLQ        IFEQ      'Y'
CBIdAC                   MOVE      '02'          LCDTYP
CBIdAC*                  TrailerClean
CBIdAC                   MOVE      '07'          LCDRSC
CBIdAC                   WRITE     LCDREC
CBIdAC                   ENDIF
      *
CBIdAC     W2TRLQ        IFEQ      'N'
CBIdAC                   MOVE      '02'          LCDTYP
CBIdAC*                  TrailerDirty
CBIdAC                   MOVE      '04'          LCDRSC
CBIdAC                   WRITE     LCDREC
CBIdAC                   ENDIF
      *
CBIdAC     W2TKQ         IFEQ      'Y'
CBIdAC                   MOVE      '02'          LCDTYP
CBIdAC*                  TrailerPrecooled
CBIdAC                   MOVE      '08'          LCDRSC
CBIdAC                   ADD       000001        LCDSTT
CBIdAC                   WRITE     LCDREC
CBIdAC                   ENDIF
      *
CBIdAC     W2TKQ         IFEQ      'N'
CBIdAC                   MOVE      '02'          LCDTYP
CBIdAC*                  TrailerNoPrecooled
CBIdAC                   MOVE      '06'          LCDRSC
CBIdAC                   ADD       000001        LCDSTT
CBIdAC                   WRITE     LCDREC
CBIdAC                   ENDIF
      *
CBIdAC     W2LODQ        IFEQ      'Y'
CBIdAC                   MOVE      '02'          LCDTYP
CBIdAC*                  TrailerLoaded3Compartments
CBIdAC                   MOVE      '09'          LCDRSC
CBIdAC                   ADD       000001        LCDSTT
CBIdAC                   WRITE     LCDREC
CBIdAC                   ENDIF
      *
CBIdAC     W2LODQ        IFEQ      'N'
CBIdAC                   MOVE      '02'          LCDTYP
CBIdAC*                  TrailerNoLoaded3Compartments
CBIdAC                   MOVE      '10'          LCDRSC
CBIdAC                   ADD       000001        LCDSTT
CBIdAC                   WRITE     LCDREC
CBIdAC                   ENDIF
     C*
     C                   EXSR      SCR03I
     C*
     C     ENDUPD2       ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD3   Update for screen 3.
     C*
     C     ZZUPD3        BEGSR
     C                   MOVE      *OFF          ERROR
     C                   MOVE      *BLANKS       $RTNCD
     C*
     C*  The commented lines below were causing some problems when
     C*  starting loading time, captured at the beggining of loading,
     C*  had a before mid night time and current date obtained below,
     C*  had jumped to the following day, it'l be something like:
     C*  TIME = 23:59:20 and Date = 20080424 where the date is the
     C*  shift second day or after mid night date. Now, both starting
     C*  date and time are capture at the same time, for merged item
     C*  pallet is done in 'Main Line' logic and for non-merged item
     C*  pallet is done in 'SC3' routine.
     C*
     C*  Move starting loading date and time into Ldrdetl file
     C*
     C*
     C*>                 MOVE      '*CURCMD '    $CVCMD
     C*                  CALL      @CVTDT
     C*                  PARM                    $CVTDT
     C*>                 Z-ADD     $CVD8O        LDSTRD
     C*
     C                   Z-ADD     HLDSTD        LDSTRD
     C                   Z-ADD     HLDSTT        LDSTRT
     C*
     C                   SETOFF                                       13
     C*
     C*  Move ending loading date and time into Ldrdetl file
     C*
     C                   MOVE      '*CURCMD '    $CVCMD
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD8O        LDENDD
     C*
     C                   TIME                    LDENDT
     C                   SETON                                        13
      *
      *  Get loader emp#
      *
     C     #USER         CHAIN     PIRUSER                            79
     C     *IN79         IFEQ      *OFF
     C                   Z-ADD     USEMP#        LDEMP#
     C                   ENDIF
      *
     C                   UPDATE    LDDREC
     C                   Z-ADD     *ZEROS        HLDSTT
      *
530bA *  This pallet has now been loaded, so go create a LOAD transaction.
      *
710aDC**                 exsr      zzCrtTrn
710aMC                   exsr      zzLoad
710aA *
710aA *  After creating LOAD transaction create an IDLE transaction.
710aA *
710aAC                   exsr      zzIdle
      *
      *  Check if all pallets are loaded for this route to
      *  record its ended date and time in the header record.
     C*
     C                   EXSR      ZZCHKL
      *
     C     *IN12         IFEQ      *ON
530hDC**   HDKEY         CHAIN     LDRHDR                             79
530hMC     DTKEY5        CHAIN     LDRHDR                             79
     C     *IN79         IFEQ      *OFF
     C                   MOVE      $CVD8O        LHENDD
700eAC                   eval      hldlhendd = lhendd
     C                   TIME                    LHENDT
700eAC                   eval      hldlhendt = lhendt
     C                   MOVE      '3'           LHSTAT
     C                   UPDATE    LHREC
     C                   ENDIF
700dA*  If this is a merged route you must update end date, end time and
700dA*  status in all the associated loader headers
700dAC                   if        ParentChild <> ' '
700dAC                   exsr      zzupdMrgHdr
700dAC                   endif
     C                   ENDIF
     *
     C     ENDUPD3       ENDSR
     C*
     C*----------------------------------------------------------------
530 AC*  ZZUPD4   Update for screen 4.
530 AC*
530 AC     ZZUPD4        BEGSR
     C*
     C                   MOVE      *OFF          ERROR
     C*
     C*  Unload pallet
     C*
     C     dtkey4        chain     ldrdetl
     C                   if        %found(ldrdetl)
     C                   eval      ldstrd = 0
     C                   eval      ldstrt = 0
     C                   eval      ldendd = 0
     C                   eval      ldendt = 0
     C*
     C*  If unloaded pallet is outed pallet, grab cube and pcs.
     C*
     C     dtkey4        chain     ldrdtlbk
     C                   if        %found(ldrdtlbk)
     C                   eval      ldcube = ldbcub
     C                   eval      ldpcs  = ldbpcs
     C                   endif
     C*
     C                   update    lddrec
      *
      *  Clear date and time and set status to 'started' in loader hdr if route
      *  is 'ended' but not 'closed'.
      *
     C     hdkey2        chain     ldrhdr3
     C                   if        %found(ldrhdr3)
     C                             and lhendd <> 0
     C                             and lhclsd =  0
     C                   eval      lhendd = 0
     C                   eval      lhendt = 0
     C                   eval      lhstat = '2'
     C                   update    lhrec3
     C                   endif
      *
     C                   endif
      *
     C                   EXSR      SCR01I
     C*
     C     ENDUPD4       ENDSR
740cA*----------------------------------------------------------------*********
740cA*
740cA*  ZZGETFULLRTID  Using 4 pos rtid from pallet barcode go get the full
740cA*                 route id by matching the 4 pos rtid to the last 4 of
740cA*                 rhrtid AND the route imported date no older than 1
740cA*                 day less than the imported date of the route scanned
740cA*                 on screen1.
740cA*
740cA /free
740cA   begsr zzGetFullRtId;

         chain (lhwhse: lhrtid) rtehed;
         if not %found(rtehed);
           w1impd = (d'9999-12-31');
         else;
           w1impd = %date(rhimpd) - %days(1);
         endif;

         w1impdx = %dec(w1impd);
         w3rtid = *blanks;

         // FYI: The w3plt# barcode is pos 2-5 of route id and 3-7 of
         //      pallet.  The varchar turns w3plt# into an alpha for
         //      comparison against rhrtid but if there are leading
         //      zeros in w3plt# it drops them and left justifies it,
         //      so had to add the concat of zeros to retain the
         //      leading zeros.

         exec sql select rhwhse,rhrtid,max(rhimpd)
                  into :rhwhse,:rhrtid,:rhimpd
              from rtehed
              where rhwhse = :lhwhse and
                    substring(rhrtid,2,4) =
                    substring(right(concat('000000000',
                    cast(:w3plt# as varchar(9))),9),1,4) and
                    rhimpd >= :w1impdx
              group by rhwhse,rhrtid,rhimpd;

         if sqlstt <> sqlSuccess;
           error = *on;
           *in22 = *on;
           errmsg = desc(30);
           exsr zm0105;
         else;
           w3rtid = rhrtid;
         endif;

        endsr;
      /end-free
640aA*----------------------------------------------------------------*********
640aA*
640aA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640aA*
640aA /free
640aA   begsr zzwrttrand;
640aA     wrtpcmd = '*ONETRAN';
640aA     wrtpwait = 0;
640aA     wrtpwhse = ptwhse;
640aA     wrtptran# = pttrn#;
640aA     wrtpfrmdate = 0;
640aA     wrtptodate = 0;
640aA     wrtpemp# = 0;
640aA
640aA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640aA               wrtpfrmdate: wrtptodate: wrtpemp#);
640aA   endsr;
640aA /end-free

720dA*----------------------------------------------------------------
720dA*  GetGenInfo    Get pallet generation info
720dA*----------------------------------------------------------------
720dAC     GetGenInfo    begsr
      /free

        gGen = 1;
        gGenTruck = *off;
        gGenMerge = *off;
        gGenOverflow = *off;
        gGenTruckExt = *off;

        select;

          when gPltId < 20000;
            gGen = 1;
            gGenTruck = *on;

          when gPltId < 30000;
            gGen = 2;
            gGenMerge = *on;

          when gPltId < 40000;
            gGen = 3;
            gGenMerge = *on;

          when gPltId < 50000;
            gGen = 4;

          when gPltId < 60000;
            gGen = 5;
            gGenTruck = *on;
            gGenOverflow = *on;

          when gPltId < 70000;
            gGen = 6;
            gGenTruck = *on;
            gGenTruckExt = *on;

        endsl;
      /end-free
     C                   endsr

     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
** DESC - Message
Invalid Route #                                             1
Invalid pallet #                                            2
Pallet already loaded                                       3
Invalid trailer #                                           4
Route already loaded                                        5
Rte# not assigned yet                                       6
Trailer used by                                             7
User not found                                              8
Invalid tran #                                              9
Breakers plt not found                                     10
Pallet not in Pltsum                                       11
Close Plt to trailer                                       12
Trler equip not loaded                                     13
Route has no pallets                                       14
Cannot load plt out of seq, prior plt not loaded           15    -CLD A-
Invalid Route Id                                           16    -520bA-
Rte has been closed                                        17    -530 A-
Pallet not loaded                                          18    -530 A-
Enter route id, duplicate route exists                     19    -530hA-
Wrong trailer #,the right trailer # is                     20    -640 A
Input trailer # is being used by route                     21    -640 A
No LABEL record found for pick label scanned               22    -650hA
Pick lbl route id/pallet don't match pallet label          23    -650hA
Trans must be at started, ended or closed status           24    -710bA
Invalid input                                              25    -CBIdA
Cln trlr Turn TK on wait 30 Min.                           26    -CBIdA
Clean trailer                                              27    -CBIdA
Turn TK on, wait 30 Min.                                   28    -CBIdA
RtId/pallet n/f or not current                             29    -740aA
Pallet rte diff from Rte Id                                30    -740aA
Pallet not part of same add on group                       31    -740aA
Trailer Id is not type TRAILR                              32    -CBIgA
