     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RN120     Customer returns.
     *  13 October 1994
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    01/12/96  DAS  2.10
     *      - Took out PIRUSER file and corresponding code and replaced
     *        with call to GETWHSE.
     *
     *    05/15/96  RH   2.12
     *      - Change sc1 to sc3, Add new sc1 & sc2 to allow qty field
     *        to be entered as 3 qtys and 3 unit of measure fields.
     *      - Add USESC field, to select screen to use for version.
     *
213 A*    05/20/96  RH   2.13
     *      - Major revision.  Split into two screens.
     *      - Added new fields for breakdown display ITFLG1 & ITFLG2.
     *      - Added catchweight returned field.
     *      - Protect & non-display expiration date if ITFLGD<>Y.
     *      - Moved logic to write return history record from RC160
     *        into this program.
     *      - Added transaction number and corresponding item.
     *
218 A*    01/13/97  RH   2.18
     *      - Call RC160 with Parm $RSEQ, $RRPCK, $RPLBL
223 A*    07/02/97  RH   2.23
     *      - Add Parm $RDWGT catch weight for call to RC160.
     *      - Add OPPLCN use generic license option to set LCNFLG.
     *
413aA*    10/14/99  MLB  4.13a
     *      - Add F17=View rcv log to panels SCREEN1 and SCREEN2.
     *      - Add call to PO135 to ZZCMD1, ZZCMD2 subroutines.
415aA*    01/03/01  RH   4.15a
     *      - Add scan label #.
     *      - If label# scanned, do not enter license plates,
     *        write old label, new label and new transaction# to
     *        LABELNK link file.
     *      - MOVE F17 TO CMDBEFORE
415bA*    02/07/01  RH   4.15b
     *      - Change for Virtual Slots.
     *        If Manual put away, call RN250 after screen 1.
     *        If label scanned, get cust. order# OHCORD from ORDH file
415cA*    03/30/01  RH   4.15c
     *      - Add scan UPC.
     *
416 A*    10/15/01  MLB  4.16
     *      - Add support to allow return record to be updated when return
     *        putaway transaction is closed.
416aA*    10/17/01  RH   4.16a
     *      - Fix F4 Item and Whse lookup.
416bA*    10/30/01  RH   4.16b
     *      - Add W1VMFG Mfg code/vend item to screen1.
     *      - Can only enter one, label# or UPC or item# or mfg code.
     *      - Must enter one, label# or UPC or item# or mfg code.
     *      - Force Label entry if option OPRFLB='Y'.
     *      - Change existing screen3 to screen4, add new screen3.
     *      - If mispick, create label rec.for physical item W3CITM.
416cA*    11/14/01  RH   4.16c
     *      - QUICK=Y,*IN55 for quick returns.
     *      - Write upload date and time for quick returns.  By doing
     *        this, quick returns will not get exported to host.
     *      - Send Quick parameter to RN250.
416dA*    11/27/01  RH   4.16d
     *      - Fix F17 to use label, upc, item or Mfg code.
     *      - Fix Mfg Code error.
     *      - Position to label field after first time if no error.
     *      - Write exception for mispick or if RNINVF=Y.
416eA*    11/29/01  RH   4.16e
     *      - Add option to Export quick returns, N=write upload
     *        date and tiem so quick returns are not exported.
416fA*    02/04/02  RH   4.16f
     *      - Add option to use label for putaway (OPRULB).
     *      - Change field name W2FLBL to W2ULBL.
     *      - Remove USER from screen, default to #USER.
416gA*    03/21/02  RH   4.16g
     *      - Remove F17 - Receiving log.
416hA*    03/22/02  RH   4.16h
     *      - Add F9 to enable UOM for breakdown quantity.
416iA*    06/17/02  RH   4.16i
     *      - Add W1RORD to return whole order.
     *      - Add SCREEN 4 to return whole order.
416jA*    07/03/02  RH   4.16j
     *      - Can not return whole order more than once.
     *      - Mispick item cannot be ordered item.
416kA*    07/09/02  RH   4.16k
     *      - Write pick slot to ITMEXCP file.
416lA*    08/27/02  RH   4.16l
     *      - For mispick, create adjustments if both items have
     *        pick slots, otherwise create exception record.
     *      - Add ITEMADJ file.
416mA*    09/09/02  RH   4.16m
     *      - Create record in POMFR for expiration date.
     *      - Move manufacturer date to screen 3.
     *      - Move corresponding item to screen 2.
     *
417bA*    04/03/03  RH   4.17b
     *      - Recompiled, ITEMMSC file changed.
417aA*    04/09/03  RH   4.17a
     *      - Enh: Allow multiple items for one UPC code.
417cA*    06/06/03  MLB  4.17c
     *      - Fix: Revise ZZUPD3 to run convert date every time
     *        record is added to returns file. Revised ZZEXCP with
     *        same change for field EXGDTE.
417dA*    10/14/03  RH   4.17d
     *      - Enh: Check mfg date is not already expired.
417eA*    02/26/04  RH   4.17e
     *      - Enh: Call RC160 with $RFIFO
500aA*    11/04/04  RH   500a
     *      - Add screen 6 to allow whole order return with auto
     *        put away to pick slot or dock slot.
     *      - RN123CL is only called from the command line with parm 'A'.
     *        is not executed thru normal return process.
500bA*    02/07/05  RH   5.00b
     *      - Enh: For mispick, write *ORDER for ordered item and
     *        *PUT for returned item put away, put in EXFDIS.
500cA*    08/09/05  RH   5.00c
     *      - ENH: Change to ILE.
500dA*    08/09/05  RH   5.00d
     *      - Fix: For mispick, call DRI interface to create adjustments
     *        and update slot and warehouse quantities. Adjustments were
     *        created but not updating quantities.
500eA*    08/22/05  RH   5.00e
     *      - Fix: Move blanks to W1SLOT, zeros was causing RC160 error
     *      - Fix: Use ordered / picked item in FILL$ADJ.             r
500fA *    10/11/05  RH   5.00f
      *      - ENH: Revised to chain to POMFR1 with label#, update
      *        existing record if found.  Problem POMFR records
      *        already existing when label# have cycled around again
      *        and having previous item's expiration date info.
510aA*    08/17/06  RH   5.10a
     *      - Fix: UPC code was getting truncated in KYUPC field.     ts
520aA*    01/13/09  RH   5.20a
     *      - Fix: Refresh screen 01 when finished with ZZUPD4, was
     *        not clearing screen 01 fields.
520bA*    05/04/09  MLB  5.20b
     *      - Fix: Revised program to pass Quick Return Y/N and
     *        Export Quick Returns flag to RN122CL so that when an
     *        entire order is returned, if quick returns is used and
     *        quick returns are not exported, they are correctly flagged.
530aA*    11/20/09  RH   5.30a
     *      - Enh: Add W4memo memo for return whole order.            ts
530bA*    02/02/10  RH   5.30b
     *      - Enh: Add EG Forrest, capture customer #.
530cA*    09/09/10  JCJ  5.30c
     *      - Enh: increase label entry to 10 positions for Trax.
530dA*    08/26/10  RBD  5.30d
     *      - Added parms for call to RN250.
640aA*    02/14/11  RH   6.40a
     *      - Fix: blank new label field W1LBL#B from 530c
640bA*    01/10/12  RH/GJA 6.40b
     *      - Fix: Rename format to RN12002, added inv# to screen 4
640cA*    03/27/12  RH   6.40c
     *      - Fix: blank label files if error chaining to LABEL file
     *        Was causing program to execute like F17 was pressed.
640dA*    07/18/12  LMC  6.40d
     *      - Enh: Added logic to pass dates to RN146 for new LICINFO
     *        records *MFGDTE, *MFGEXP, *MFGDCOD
     *      - Enh: Added call to decipher code program
     *      - Enh: renamed display file rn12002 to rn12003
640eA*    11/09/12  LMC  6.40e - in process
640fA*    12/18/12  LMC  6.40f
     *      - Fix: Revised program to set W3EXpd, W3MFDT to zeros if
     *        return from MF200 returned with an error and the user
     *        had previously keyed an invalid date into the screen
     *        expiration or mfg date field.
     *
650 A*    01/22/13  RBD  6.50
     *      - Fix: renamed display file rn12003 to rn12004; changes
     *        to correct cursor positioning.
650aA*    02/26/13  LMC  6.50a
     *      - Fix: Turn on indicator 94 for non display on w1qt02 if
     *        the w1um2 field is set to blanks on SSB item.
650bA*    03/08/13  MLB  6.50b
     *      - Fix: Revised pgm to check if value loaded into exqty > 999
     *        and if yes, then set exqty = 999. Error found at Get
     *        Fresh who stores watermelon in lbs in qty fields.
650cA*    05/21/13  LMC  6.50c
     *      - Enh: RCVRTN transaction for MRC reporting
650dA*    06/05/13  LMC  6.50d
     *      - Enh: *NOSTOCK - returns that do not impact inventory
     *        will go thru RN246L instead of RC160.
650eA*    06/13/13  LMC  6.50e
     *      - Enh: Renamed display file from RN12004 to RN12005
     *        This was required because mod CSPa was made to display
     *        file RN12001 on client box and never brought back to dev
650fA*    11/09/12  LMC  6.50f
     *      - Enh: Added GS1/UCI logic.
650gA*    07/19/13  RH   6.50g
     *      - Fix: Change position cursor for 1st screen to When stmt
     *        to set indicators correctly for client specific.
650hA*    06/20/13  LMC  6.50h
     *      - Enh: Pass parm added to RN246 for GTIN. Used for
     *      calculating PTI for the LICINFO file.
     *      - Enh: Add call to CALCPTI
     *      NOTE: this enhancement needs to include Program CALCPTI
650iA*    10/31/13  LMC  6.50i
     *      - Enh: Added PTI code Entry field.
650jA*    10/28/13  MLB  6.50j
     *      - Fix: Revised routine ZZFIL1 to set WOINV# = ' '. Field
     *        was carrying over data from previous return.
650kA*    05/14/15  RBD  6.50k  P#01369
     *      - Renamed scrn format to RN12008.
     *      - Enh: Changed customer order number to 15 alpha from 7
     *        numeric on screen1. At this time won't change it for quick
     *        returns. Only Cash Wa will be allowed to enter alphas for
     *        customer order number, all others will still enter numbers.
700aA*    07/13/15  RH   7.00a
     *      - Renamed scrn format to RN12009.
     *      - Fix: When scanning TRAX for LABEL, the field had CHECKER
     *        and the scanner does enter causing Enter to be read twice
     *        Removed CHECKER from LABEL field on Screen1.
700cA*    01/07/16  LMc  7.00c
     *      - We are setting all directed putaway returns to be done
     *        Manually. Previously we only had one client using
     *        directly putaway in returns and that client had a mod
     *        WST1 that was forcing to manual.
     *        At this time only manual putaway is supported on returns
700dA*    01/18/16  MLB  7.00d
     *      - Fix: Revised 6.50k mod to extract 7 digits for w1ord from
     *        W1ORDA instead of 5.
     *      - Fix: Revised 6.50k mod to limit digits entered to 7 for
     *        Customer Order Nbr. Issue error if greater than 7.
700eA*    03/24/16  NLK  7.00e  (coming)
     *      - ENH: improve HELP messages
700fA*    06/14/16  RBD  7.00f
     *      - Fix: Position cursor not working correctly for CTW and SGC.
     *        Disabled CTWb and SGCd since standard code poitions to label.
     *
700hA*    11/03/16  LMC  7.00h
     *      - Enh: UPC file has a database change. Recompile only.
720aA*    02/07/18  NLK  7.20a
     *      - Enh: Add Parm of lbord into RN250
720bA*    02/13/18  NLK  7.20b
     *      - Enh: Check if Full or Partial Order already returned.
     *        In addition, make sure RN250 is poplulating oroord
     *      - DRYb: Client (Chef's) mandatory to have valid order#.
720cA*    10/10/18  NLK  7.20c
     *      - FIX: 720b reade rtnkey not to use whole order, kywhol
720dA*    10/12/18  LMC  7.20d
     *      - Enh: Additional receiving methods have been created.
     *        4,5 & 6. They all are standard receiving with an addon
     *        for printing labels (aka Box labeler).
720eA*    07/25/16  MR/LMC  7.20e reserved
     *      - Enh: Populate parm values in DRIUICINFO
     *             for new UCIINFO file format.
730aA*    04/02/19  KDE     7.30a
     *      - Enh: When whole order is specified ensure that either
     *             valid label# or valid order number is entered.  If
     *             valid order# is entered then find a label# for that
     *             Customer Order# and proceed with that label#
740aA*    06/16/20  LMC     7.40a
     *      - Enh: Adding some additional fields/logic for packers
740bA*    09/25/20  LMC     7.40b
     *      - Enh: New screen format for packers enhancement
740cA*    08/26/20  MLB     7.40c
     *      - Enh: Revised 7.30a mod to add code to check LBTYPE = B
     *        when looking up order information for whole order returns.
740dA*    01/04/21  LMC  7.40d
     *      - Enh: Added edit for returning ssb item when there is
     *        No breakdown uom setup on base item.
750aA*    06/10/21  LMC  7.50a
     *      - Enh: Added new pallet license plate on screen1 will
     *        assist in making putaway easier.
     *        We will associate each receiving license to the pallet
     *        license, and then putaway will scan the pallet license
     *        and we will treat it like they scanned each of the
     *        individual licenses associated with the return.
750bA*    06/23/21  LMC  7.50b
     *      - Enh: Added sending pallet license plate to rn122.
780aA*    04/22/24  DAS  7.80a
     *      - Enh: Revised to force a valid customer number when
     *        using Host Lot codes (currently just FreshByte and
     *        NetSuite). See notes on Host Lot codes below.
     *
     *----------------------------------------------------------------
     *  Custom Revisions
     *----------------------------------------------------------------
     *  City Wholesale
CTWaA*    02/06/09  GJA  CTWa
     *      - Check for discontinued item                             r
CTWbA*    03/21/12  LMC  CTWb
     *      - default to label field after first entry                r
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt Produce
CSPaA*    02/28/13  RTR  CSPa
     *      - Enh: Set default disposition from return code.
     *      - Renamed DSPF to RN12001 from RN120FM.
CSPbA*    06/12/13  LMC  CSPb
     *      - Revised to add lookup for customer order number
     *----------------------------------------------------------------
     *  Client Custom Revisions: SouthWest Trader
SWTa *    03/28/19  GJA  SWTa
     *      - Allow order number to be greater then 7
     *      - Do not force order number
     *      - Get invoice number from ORDHEXA
     *----------------------------------------------------------------
EGF A*    EG Forrest
EGFaA*    02/02/10  RH   EGFa
     *      - Enh: Force cust # to be entered.
     *----------------------------------------------------------------
     *  Custom Revisions
DRY A*    Dairyland
DRYaA*    04/07/11  RH   DRYa
     *      - Enh: Don't allow quick returns, add new error message
DRYbA*    02/13/18  NLK  DRYb
     *      - DRYb:Clients (Chef's) mandatory to have valid order#.
     *      - ORDD3: New logical file needed.
DRYcA*    12/18/18  NLK  DRYc
     *      - DRYc: same Ord # with more than one Route ID
DRYdA*    03/14/19  NLK  DRYd
     *      - CHG: CORD dup on diff orders. WAS to allow if diff dates
     *        NOW to allow no matter what date. -- remove 'if date'
     *        Kelly, "It is valid to have more than one order with
     *        same cust #, transmitts in more than one time."
     *      - CHG: Read ORDH by descending date to get newest order
DRYeA*    06/25/19  NLK  DRYe
     *      - CHG: Read ORDH by descending date to get newest order
     *        ReadE ALL CORD records and calc TOTAL qty - ORRTN qty to
     *          to see if the entered qty is still valid
     *      - ORRTN orord is CORD and should check all dates and ord#s
     *----------------------------------------------------------------
     *  Custom Revisions
JOR A*    Jordanos
JOR AF*    06/29/05  MLB  JOR1
     F*      - Revised program to force cursor to be positioned on
     F*        item number.
JORaAF*    05/02/06  RH   JORa
     F*      - Fix: cursor was only positioned to item # first time.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Brothers
CBI A*    11/26/16  MLB  CBI
     *      - Default cursor to label field always.
     *
     *----------------------------------------------------------------
     *  Custom Revisions Springfield Grocer
SGCaA*    05/18/09  RH   SGCa
     *      - Enh: Do not use OHMISC for invoice #                    ts
SGCb *    10/28/11  GJA  SGCb
     *      - Enh: Add invoice# for whole order return                ts
SGCc *    02/06/12  LMC  SGCc
     *      - Enh: Default to Customer order# after first return      ts
SGCd *    06/05/12  RBD  SGCd
     *      - Default to label field after first entry
     *----------------------------------------------------------------
WST A*    West Side Foods
WSTaA*    06/27/00  DAS  WS1  ORIGINALLY IN RN150
     *      - Forced field OPMPUT to 'N', thus reversing the 412
     *        change from 9/22/99. WestSide receives a lot of single
     *        case returns. Therefore, they want them to go directly
     *        to the home slot without needing to go through manual
     *        RF putaway. They close returns manually, not by RF.
WST2 *    06/24/03  MLB  WS2
     *      - Revised ZZFIL2 to set W1CODE to 'WR'. W2DCDE to 'STOCK'
     *        Revised ZZCHK2 to not flag error if catchwgt not entered
WSTc *    09/24/12  DAS  WSTc
     *      - Revised to force return to pick slot by sending *SPRECV
     *        to RC160.
WSTd *    09/29/12  GJA  WSTd
     *      - Revised to not prompt for license plate.
     *
     *----------------------------------------------------------------
KHL A*    Kohl Wholesale
KHLaA*    08/15/14  LMC  KHLa
     *      - Allow quick returns entry field customer order to have
     *        customer number entered.
     *----------------------------------------------------------------
     *    Client Custom Revisions: Cash Wa Distributing
CWD A*    10/28/13  MLB  CWD
     *      - Enh: Revised pgm to load Host Invoice# from OHCPO into
     *        WOINV#.
     *
     *----------------------------------------------------------------
     *    Client Custom Revisions: Graves Foods
GMM A*    06/11/20  MLB  GMM
     *      - Enh: Do not use OHMISC for invoice #
     *        Added GMM to SGCa mod.
     *
     *----------------------------------------------------------------
     *    Client Custom Revisions: Packers
PCKaA*    06/16/20  LMC  PCKa
     *      - Enh: special return logic for packers
PCKbA*    09/25/20  LMC  PCKb
     *      - Enh: quote 2242 - break screen 1 into 2 screens
PCKcA*    09/25/20  ???  PCKc
     *      - Enh:
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
530cDF*rn120fm   cf   e             workstn
640bDF*n12001   cf   e             workstn
640dDF*rn12002   cf   e             workstn
650 DF*rn12003   cf   e             workstn
650eDF*rn12004   cf   e             workstn
650fDF*rn12005   cf   e             workstn
650iDF*rn12006   cf   e             workstn
650kDF*rn12007   cf   e             workstn
700aDF*n12008   cf   e             workstn
740aDF*rn12009   cf   e             workstn
740bDF*rn12010   cf   e             workstn
750aDF*rn12011   cf   e             workstn
750aMFrn12012   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
PCKaAF                                     sfile(dspsfl6:recno6)
PCKaAF                                     sfile(msgrec6:msgk6)
     Funmesr    if   e           k disk
     Fpiritem   if   e           k disk
210 D*IRUSER IF  E           K        DISK
213 AForrtn     o  a e           k disk
219 AFoptions   if   e           k disk
415bAFoptiond   if   e           k disk
415aAFLabel     if   e           k disk
415aAFLabel2    if   e           k disk
     F                                     rename(lbrec:record)
780aAFLabel93   if   e           k disk    prefix(lb93_)
780aAF                                     rename(lbrec:lbrec93)
415aAFLabelnk   o  a e           k disk
415bAFordh      if   e           k disk
SWTaAFordhexa   if   e           k disk
500aAFordh5     if   e           k disk
     F                                     rename(ohrec:o5rec)
650kAFordh12    if   e           k disk
     F                                     rename(ohrec:o12rec)
DRYdAFordh14    if   e           k disk
     F                                     rename(ohrec:o14rec)
650kAFrtehed    if   e           k disk
416iAFordd      if   e           k disk
DRYbAFordd3     if   e           k disk    prefix(od3_)
DRYbAF                                     rename(odrec:o3rec)
415cAFupc       if   e           k disk
416bAFpiritem4  if   e           k disk
     F                                     rename(itrec:i4rec)
416bAFrdscode   if   e           k disk
416dAFrtncode   if   e           k disk
416jAForrtn2    if   e           k disk
     F                                     rename(orrec:r2rec)
416mAFitemmsc   if   e           k disk
416bAFitmexcp   o    e           k disk
500fDF*omfr     o    e             disk
500fAFpomfr1    uf a e           k disk
500dDF*temadj   o  a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
530cD ***desc            s             50    dim(11) ctdata perrcd(1)
CTWaD ***desc            s             50    dim(13) ctdata perrcd(1)
DRYaDD*desc            s             50    dim(14) ctdata perrcd(1)
650fDD*desc            s             50    dim(15) ctdata perrcd(1)
650iDD*desc            s             50    dim(18) ctdata perrcd(1)
650kDD*desc            s             50    dim(19) ctdata perrcd(1)
700dDD*desc            s             50    dim(21) ctdata perrcd(1)
DRYbDD*desc            s             50    dim(22) ctdata perrcd(1)
DRYbMD desc            s             50    dim(23) ctdata perrcd(1)
500aD*                   DESC    1  11 50
416bD*                   DESC    1   5 50
416cMD hed             s             50    dim(4) ctdata perrcd(1)
DRYeAD ORDnum          s              7  0 dim(99)
DRYeAD ORDqt1          s              5  0 dim(99)
DRYeAD ORDqt2          s              5  0 dim(99)
780aAD ORDqt3          s              5  0 dim(99)
PCKaAD zopt6           s              1    dim(1) ctdata perrcd(1)
500d *----------------------------------------------------------------
500d *  DRI parameters
500d *----------------------------------------------------------------

500d  /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
500d *  Data Formats
     *----------------------------------------------------------------

500d  /COPY *libl/qcopysrc,C#ITEM
500d  /COPY *libl/qcopysrc,C#SLOT
650fA /COPY *libl/qcopysrc,C#LICENSE
650fA /COPY *libl/qcopysrc,C#LICINFO
050fA /COPY *libl/qcopysrc,C#UCIINFO
500d D savever#        s                   like($slver#)
500d D saveaisl        s                   like($slaisl)
500d D saveloc         s                   like($slloc)
500d D saverlvl        s                   like($slrlvl)
500d D savehand        s                   like($slhand)
500d D slotds        e ds                  extname(slot)

530bA*----------------------------------------------------------------
530bA*  Customer id
530bA*
780aDD*@getcl          c                   const('GETCLIENT')
530bA*
EGFaA /COPY QCOPYSRC,ID#EGF
DRYaA /COPY QCOPYSRC,ID#DAIRYLA
SGCaA /copy qcopysrc,id#sgc
CTWaAD/copy qcopysrc,id#citywho
WSTaAD/copy qcopysrc,id#westsid
CWD AD/copy qcopysrc,id#cashwa
CSPbA /copy qcopysrc,id#coastal
JORaA /COPY QCOPYSRC,ID#JORDANO
KHLaA /copy qcopysrc,id#khl
CBI A /copy qcopysrc,id#cheney
SWTaA /copy qcopysrc,id#swt
GMM A /copy qcopysrc,id#gmm
PCKaA /copy qcopysrc,id#packers
780aA*----------------------------------------------------------------
780aA*  Host Systems (PIRCLIENT4)
780aA*
780aA /copy qcopysrc,hostsystem

     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
650fAD $emp#           s              5  0
650fAD $lexpdt6        s              6  0
650fAD $lmfgdt6        s              6  0
     D $lord           s              7  0
650hAD $lbcProdD       s              6  0
     D $msgf           s             10
740aAD $pckorg         s              4  0
650iAD $pw3pti         s              4  0
650cAD $rtnord         s              9
650fAD $unext          s             13  0
     D $wcode          s              2
     D $wcord          s              7
     D $wdcde          s              5
     D $winvf          s              1
SGCbAD $winv#          s              9
     D $wlord          s              7
530aAD $wmemo          s             30
     D $wmput          s              1
     D $wpbat          s              7
     D $wrtn           s              8
520bAD $wqck           s              1
520bAD $wrexq          s              1
     D $wusr           s             10
     D $wwhse          s              3
     D #msgid          s              7
     D #msgtp          s              7
     D #po             s             10
650fAD chk4err         s               n
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
650fAD difflot         s               n
650fAD diffexpd        s               n
     D dtfrmt          s              1  0
     D e               s              2  0
     D enter           s              5  0
650fDD*error           s              1
650fMD error           s               n
     D exod            s              8  0
650fAD expdwarn        s              1
650fAD expdovr         s              1
     D flbflg          s              1
     D forevr          s              1
     D G$DATE          s              6  0
     D G$DD            s              2  0
     D G$DW            s              1  0
     D G$JD            s              5  0
     D G$JYD           s              7  0
     D G$MM            s              2  0
     D G$MMWK          s              2  0
     D G$WK7           s              7  0
     D G$YY            s              2  0
     D G$YYWK          s              3  0
     D G$YYYY          s              4  0
     D GMWKSV          s              2  0
     D HELP            s              5  0
DRYdD *hlddt           s              8  0
     D J$DATE          s              6  0
     D J$DD            s              2  0
     D J$JD            s              5  0
     D J$MD            s              3  0
     D J$MM            s              2  0
     D J$TST           s              9  9
     D J$X             s              2  0
     D J$YD            s              7  0
     D J$YYWK          s              3  0
     D J$YYYY          s              4  0
650hAD k               s                   like($lnrcvqty)
     D KYCODE          s                   like(OPDCOD)
     D KYITEM          s                   like(ITITEM)
     D KYUPC           s                   like(UPUPC)
     D KYVMFG          s                   like(ITVIT#)
     D KYWHOL          s                   like(ORWHOL)
650fAD lastseq         s                   like($lnseq)
     D LCNFLG          s              1
650fAD lcnsExists      s               n
650fAD licinfoupd      s               n
650fAD lotwarn         s              1
650fAD lotovr          s              1
     D MFDTJ           s              5  0
     D MFGD            s              8  0
650fAD moretoscan      s              1
     D MSGK            s              4  0
PCKaAD msgk6           s              4  0
640dAD mexpd           s              8  0
640dAD mfgdte          s              8  0
PCKaAD n               s              3  0
PCKaAD nrslct          s              3  0
     D NXTSCR          s              3
     D OCODE           s              8
PCKaAD optslt          s              1    inz('0')
     D OSLOT           s             12
650iAD ovrrid          s              1
     D PICKSL          s              1
650cAD poppcs          s                   like($lpcs)
650kAD pos             s              5  0   inz(0)
650hAd pplot           s             20
650hAd pppti           s              4  0
     D PSLOT           s             12
650iAD ptiovr          s              1
650iAD ptichk          s              1
650iAd ptinodate       s              6  0
     D QUICK           s              1
650cAD rcvrtncomplete  s               n
PCKaAD recno6          s              5  0
     D REFRSH          s              1
     D ROLLDN          s              5  0
     D ROLLUP          s              5  0
     D RTNTYP          s              1
650fAD savew3mfdt      s                   like(w3mfdt)
650fAD savew3expd      s                   like(w3expd)
650fAD saveexpd        s                   like(expd)
650fAD savelotc        s                   like(w3lotc)
650fAD savewgt         s                   like(w1cwtr)
650fAD saveqty         s                   like($lnrcvqty)
     D SCLEAR          s              1
     D STOP            s              1
650iAD svpti           s              4  0
650fAD templcns        s             15
     D TODAY           s              8  0
DRYeAD totqt1          s              5  0
DRYeAD totqt2          s              5  0
780aAD totqt3          s              5  0
PCKaAD ttlrcd          s             11  0
650fAD uciexists       s               n
650fAD unexta          s             13
     D UPCCTR          s              3  0
     D USESC           s              1  0
650kAD valid           c                   const('0123456789 ')
     D WARN            s              1
     D WODCDE          s              5
650fAD woexdt          s              8  0
     D WOINV#          s              9
     D WOINVF          s              1
     D WOLBL#          s              7  0
650fAD womfdt          s              8  0
     D WOORD           s              7  0
DRYbAD wiord           s              7  0
     D WOREXQ          s              1
     D WORK1A          s              1
     D WORK2           s              2
     D WORK4           s              4
     D WOTRN#          s              7  0
     D WOULBL          s              1
     D WSCITM          s             15
     D WSITEM          s             15
     D WSLORD          s                   like(LBORD)
700dAD wklen           s              7  0 inz(0)
     D W1SLOT          s             12
650fAD W1upc           s             50
PCKaAD x               s              3  0
650fAD CKupc           s             50
     D AJCODE          s              2
650fAD zmflag          s               n
500d D zmsflag         s               n
530cAD w1lbl#          s              7  0
650kAD w1ord           s              7  0

750aAD $pltlcns        s             10
750aAD $hldpicklbl     s             10
750aAD hldpicklbl      s             10

780aAd vfyItemOnOrder  s               n
780aAd usingHostLots   s               n
780aAd client          s             10
780aAd clientloc       s             10
780aAd clientinit      s              3
780aAd clienthost      s             10
PCKaA*----------------------------------------------------------------
PCKaA* Window Titles
PCKaAD Title04         c                   const('Select Order')
650fA*----------------------------------------------------------------
650fA*  Prototypes
650fA*----------------------------------------------------------------

780aA /copy qcopysrc,p.getclien

650fAD ucilic#         pr                  extpgm('UCILIC#')
650fA * Input
650fAD   unext                       13  0 const
650fAD   uwhse                        3  0 const
650hAD calcpti         pr                  extpgm('CALCPTI')
650hA * Input
650hAD   pGTIN                             like($bcgtin)
650hAD   pLOT                              like(pplot)
650hAD   pPackDate                         like($lbcProdD)
650hAD   pPTI                              like(pppti)
650fA*----------------------------------------------------------------
650fA*  Convert Barcode Parms
650fA*----------------------------------------------------------------

650fA /COPY *libl/qcopysrc,C#CVTPARMS
650fA /COPY *libl/qcopysrc,C#BARCODE
750aA*----------------------------------------------------------------
750aA*  File field data structure.
750aA*----------------------------------------------------------------

750aAD rnlrec        e ds                  extname(PLTLCNS) inz(*EXTDFT)
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $litem                22     36
415bAD  $lusr                 37     46
415bAD  $ldev                 47     56
415bAD  $lform                57     66
     *
417a D  $lupc                 22     41
417a D  $litm1                42     56
     *
     D  $lcode                19     20
416bA*
416bAD  $ldcde                19     23
     *
     D  $ltrn#                19     25  0
     *
     D  $luser                19     28
     *
413aAD  $lrpo                 22     30
413aAD  $lrseq                31     35  0
413aAD  $lritm                36     50
     *
223 AD  $lpo                  37     45
223 AD  $lrq1                 46     50  0
223 AD  $lrq2                 51     55  0
223 AD  $lrq3                 56     60  0
223 AD  $lrpal                61     63  0
     *
640dAD  $lmfr#                22     32  0
640dAD  $lmfritem             33     47
640dAD  $ldakitem             48     62
     *
CSPbAD  $lstat                22     22
CSPbAD  $lohudte              23     30  0
CSPbAD  $lohcord              31     37  0
CSPbAD  $lcitem               38     52
     *
640dA*------------------------------------------------------------------
640dA* CLCDUR2 parameters
640dA*------------------------------------------------------------------

640dAD $cdcmd          s              8

640dAD $cddatein       s              8  0
640dAD $cdtimein       s              6  0

640dAD $cdyears        s              3  0
640dAD $cdmonths       s              3  0
640dAD $cddays         s              3  0
640dAD $cdhours        s              3  0
640dAD $cdminutes      s              3  0
640dAD $cdseconds      s              3  0

640dAD $cddateOut      s              8  0
640dAD $cdtimeOut      s              6  0

     *----------------------------------------------------------------
     *  Called programs
     *
650cAD @crtrcv         c                   const('CRTRCVTRN')
     D @cvtdt          c                   const('CVTDTE')
530cAD @cvtbarsel      c                   const('CVTBARSEL')
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
     *
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erulen                 1      3p 2
     D  eruwdt                 4      6p 2
     D  eruhgt                 7      9p 2
     D  ercalc                10     13p 3
     D  ercube                14     17p 3
     D  ercdiv                18     22p 2
     D  ercrng                23     24p 1
     D  ermax                 25     28p 4
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     D                 ds
     D  $ec                    1      2p 0
PCKaAD*----------------------------------------------------------------
PCKaAD*  Error Message(s)
PCKaAD*
PCKaAD ERR01           c                   const('1=Select can only be used onc-
PCKaAD                                     e.')
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
223 A* Data structure
223 A*
223 AD opdata          ds
223 AD  oplpgm                 1     10
223 AD  opupct                11     13  0
223 AD  oppdef                14     14  0
223 AD  oppbld                15     15  0
223 AD  oppact                16     16  0
223 AD  opfdef                17     17  0
223 AD  opfasl                18     18  0
223 AD  opfsid                19     19  0
223 AD  opflvl                20     20  0
223 AD  oppasl                21     21  0
223 AD  oppfrc                22     22
223 AD  opplcn                23     23
223 AD  opcum                 24     43
223 AD  opcdiv                44     52  2
223 AD  opcaut                53     53
223 AD  opcwrn                54     54
223 AD  opcrng                55     57  1
223 AD  opwum                 58     72
223 AD  opxdsc                73     73
223 AD  optend               117    117
415bA*----------------------------------------------------------------
415bA*  *PICK  -  Picking options
415bA*----------------------------------------------------------------
415bA*
415bA* Fields
415bA*
415bA*    OPNXTP  -  Next pallet number.
415bA*    OPBPCK  -  Bulk pick definition.
415bA*    OPPCUB  -  Maximum cube for PIR.
415bA*    OPFPAL  -  Pallets on fixed fork lift.
415bA*    OPFCUB  -  Maximum cube per fixed pallet.
415bA*    OPFSTP  -  Maximum stops per fixed pallet.
415bA*    OPINCL  -  Include PIR in fixed cube.
415bA*    OPSRCH  -  Number of previous pallets to search for space.
415bA*    OPFBLD  -  Fixed pallet building method.
415bA*                1 = By piece without concern for splitting stop.
415bA*                2 = By stop without splitting stop between plts.
415bA*    OPPBRK  -  Break pallets by aisle (Y,N).
415bA*    OPMPUT  -  Manual Put away (Y,N).
415bA*
415bA* Data structure
415bA*
415bAD opddta          ds
415bAD  opnxtp                 1      7  0 inz(0)
415bAD  oppcub                10     14  2 inz(0)
415bAD  opfpal                15     15  0 inz(0)
415bAD  opfcub                16     20  2 inz(0)
415bAD  opincl                22     22
415bAD  opsrch                23     24  0 inz(0)
415bAD  opfstp                25     26  0 inz(0)
415bAD  opfbld                27     27  0 inz(0)
415bAD  opbpck                28     30  0 inz(0)
415bAD  oppbrk                31     33
415bAD  opmput                34     34
415bAD  opdend               117    117
415bA*
416bA*----------------------------------------------------------------
416bA*  *RETURNS -  Customer Returns options
416bA*----------------------------------------------------------------
416bA*
416bA* Fields
416bA*
416bA*    OPRQCH  -  Allow changes to return quantity. (Y,N).
416bA*    OPRQEC  -  Allow changes to qty if return exported. (Y/N)
416bA*    OPRFLB  -  Force return label entry. (Y/N)
416cA*    OPREXQ  -  Export Quick returns.(Y/N)
416dA*    OPRULB  -  Use label for putaway.(Y/N)
750aA*    OPREAD  -  Export as adjustments. (Y/N)
750aA*    OPREAC  -  Adjustment code to use.
750aA*    OPPLTL  -  Allow Pallet License.(Y/N)
416bA*
416bA* Data structure
416bA*
416bAD oprdta          ds
416bAD  oprqch                 1      1
416bAD  oprqec                 2      2
416bAD  oprflb                 3      3
416eAD  oprexq                 4      4
416fAD  oprulb                 5      5
750aAD  opread                 6      6
750aAD  opreac                 7      8
750aAD  oppltl                 9      9
416bAD  oprend               117    117
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
     *  Workstation exception data structure
     *
     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371
     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *
     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
213 A*      $PCMD   *RETURN  - Customer return.
213 A*              *TFRRTN  - Transfer returns.
213 A*              *POSRTN  - POS returns.
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pqck             1
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
650cAc                   eval      rcvrtncomplete = *off
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   move      'EOJ'         nxtscr
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
740bAC     nxtscr        caseq     '00 '         sc0
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
416i C     nxtscr        caseq     '04 '         sc4
CIBa C     nxtscr        caseq     '06 '         sc6
650fAC     nxtscr        caseq     '07 '         sc7
650fAC     nxtscr        caseq     '08 '         sc8
650fAC     nxtscr        caseq     '09 '         sc9
650fAC     nxtscr        caseq     'CNL'         sccnl
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
650cAc                   exsr      zzrcvrtnclean
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = *on
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
740bAc                   if        nxtscr = '00 '
740bAC                   exfmt     screen0                              50
740bAC                   endif
     *
     C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   endif
     *
212 AC                   if        nxtscr = '02 '
     C                   exfmt     screen2                              50
     C                   endif
     *
212 AC                   if        nxtscr = '03 '
     C                   exfmt     screen3                              50
     C                   endif
     *
416iAC                   if        nxtscr = '04 '
416i C                   exfmt     screen4                              50
416i C                   endif
500a *
500aAC                   if        nxtscr = '06 '
500a C                   exfmt     screen6                              50
500a C                   endif
650fA*
650fAC                   if        nxtscr = '07 '
650fAC                   exfmt     screen7                              50
650fAC                   endif
650fA*
650fAC                   if        nxtscr = '08 '
650fAC                   exfmt     screen8                              50
650fAC                   endif
650fA*
650fAC                   if        nxtscr = '09 '
650fAC                   exfmt     screen9                              50
650fAC                   endif
650fA*
650fAC                   if        nxtscr = 'CNL'
650fAc                   exfmt     cnlwdw                               50
650fAC                   endif
     *
     *   Initialize error indicators and fields
     *
JORaAC                   if        client = jordanos
JORaMC                   setoff                                       0102
JORaAC                   else
     C                   setoff                                       010203
JORaAC                   endif
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       101112
     C                   setoff                                       131415
     C                   setoff                                       161718
     C                   setoff                                       1920
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       3031
     C                   setoff                                       333435
     C                   setoff                                       363738
     C                   setoff                                       3940
650fAC                   setoff                                       43
650iAC                   setoff                                       41
740aAC                   setoff                                       45
750aAC                   setoff                                       47
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *     Screen initialization and wrap-up routines
     *
     *----------------------------------------------------------------
740bA*
740bA*  Screen 00 initialization
740bA*
740bAC     scr00i        begsr
740bAC                   move      '00 '         nxtscr
740bAC                   if        refrsh = *on
740bAC                   exsr      zzfil0
740bAC                   endif
740bAC                   eval      refrsh = *off
740baC     end00i        endsr
     *
     *  Screen 01 initialization
     *
     C     scr01i        begsr
     C                   move      '01 '         nxtscr
     C                   if        refrsh = *on
PCKbAc                   if        *in44 = *on
PCKbAC                   exsr      zzfil1p
PCKbAc                   else
     C                   exsr      zzfil1
PCKbAc                   endif
     C                   endif
     C                   eval      refrsh = *off
     C     end01i        endsr
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   move      '02 '         nxtscr
     *R         REFRSH    IFEQ *ON
     C                   exsr      zzfil2
     *R                   ENDIF
CSPaA *
CSPaAC                   if        client = CoastalSunbelt
CSPaAC                   eval      *in89 = *on
CSPaAC                   endif
CSPaA *
     C                   eval      refrsh = *off
     C     end02i        endsr
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   move      '03 '         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil3
     C                   endif
     C                   eval      refrsh = *off
     C     end03i        endsr
416i *
416i *  Screen 04 initialization
416i *
416i C     scr04i        begsr
416i C                   move      '04 '         nxtscr
416i C                   if        refrsh = *on
416i C                   exsr      zzfil4
416i C                   endif
CSPaA *
CSPaAC                   if        client = CoastalSunbelt
CSPaAC                   eval      *in89 = *on
CSPaAC                   endif
CSPaA *
416i C                   eval      refrsh = *off
416i C     end04i        endsr
500a *
500aA*  Screen 06 initialization
500a *
500aAC     scr06i        begsr
500a C                   move      '06 '         nxtscr
500a C                   if        refrsh = *on
500a C                   exsr      zzfil6
500a C                   endif
500a C                   eval      refrsh = *off
500a C     end06i        endsr
500a *
     *----------------------------------------------------------------
650fA*
650fA*  Screen 07 initialization
650fA*
650fAC     scr07i        begsr
650fAC                   move      '07 '         nxtscr
650fAC                   exsr      zzfil2
650fAC                   eval      refrsh = *off
650fAC     end07i        endsr
     *----------------------------------------------------------------
650fA*
650fA*  Screen 08 initialization
650fA*
650fAC     scr08i        begsr
650fAC                   move      '08 '         nxtscr
650fAC                   exsr      zzfil8
650fAC                   eval      refrsh = *off
650fAC     end08i        endsr
     *----------------------------------------------------------------
650fA*
650fA*  Screen 09 initialization
650fA*
650fAC     scr09i        begsr
650fAC                   move      '09 '         nxtscr
650fAC                   exsr      zzfil9
650fAC                   eval      refrsh = *off
650fAC     end09i        endsr
650fA*
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
740bA*
740bA*  SC0  -  Screen 0
740bA*
740bAC     sc0           begsr
740bA*
740bA*  Test for F3 - Exit
740bA*
740bAC                   if        *inkc
740bAC                   move      'EOJ'         nxtscr
740bAC                   goto      endsc0
740bAC                   endif
740bA*
740bA*  Test for F5 - Refresh
740bA*
740bAC                   if        *inke
740bAC                   eval      refrsh = *on
740bAC                   exsr      scr00i
740bAC                   goto      endsc0
740bAC                   endif
740bA*
740bA*  Test for F12 - Previous
740bA*
740bAC                   if        *inkl
740bAC                   move      'EOJ'         nxtscr
740bAC                   goto      endsc0
740bAC                   endif
740bA*
740bA*  Test for other command keys BEFORE verification and update.
740bA*
740bAC                   move      '*BEFORE '    cmdchk
740bAC                   exsr      zzcmd0
740bAC     cmdtkn        cabeq     *on           endsc0
740bA*
740bA*  Some other key pressed.
740bA*
740bA*     Check input and write/update record.
740bA*
740bAC                   exsr      zzchk0
740bAC     error         cabeq     *on           endsc0
740bAC                   exsr      zzupd0
740bAC                   if        opmput = 'Y'  and
740bAC                             $lrtn = '*CANCEL '
740bAC                   move      '00 '         nxtscr
740bAC                   eval      refrsh = *on
740bAC                   goto      endsc0
740bAC                   endif
740bAC     error         cabeq     *on           endsc0
740bA*
740bA*  Test for other command keys AFTER verification and update.
740bA*
740bAC                   move      '*AFTER  '    cmdchk
740bAC                   exsr      zzcmd0
740bAC     cmdtkn        cabeq     *on           endsc0
740bA*
740bA*  Everything went fine so onto the next screen.
740bA*
740bAC                   if        w1rord = 'Y'
740bAC                   eval      refrsh = *on
740bAC                   exsr      scr04i
740bAC                   goto      endsc0
740bAC                   endif
740bA*
740bAC                   if        opmput = 'Y'
740bAC                   eval      refrsh = *on
740bAC                   exsr      scr01i
740bAC                   else
740bAC                   eval      refrsh = *on
740bAC                   endif
740bA*
740bAC     endsc0        endsr
740ba*
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      'EOJ'         nxtscr
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
416d **                   MOVE *OFF      *IN32
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
PCKbAc                   if        *in44 = *on
PCKbAC                   eval      refrsh = *on
PCKbAC                   exsr      scr00i
PCKbAc                   else
     C                   move      'EOJ'         nxtscr
PCKbAc                   endif
     C                   goto      endsc1
     C                   endif
416d *
     *  Get item# for F17 log.
416d C                   if        w1lbl# <> 0  or
650fDC*                            w1upc <> *blanks  or
650fMC                             w1uci <> *blanks  or
416d C                             w1item <> *blanks  or
416d C                             w1vmfg <> *blanks
416dAC                   exsr      zzitem
416dAC     error         cabeq     *on           endsc1
416dAC                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
416d *  Don't postion to label field if error.
416dAC                   if        error = *on
416dAC                   eval      *in12 = *off
416dAC                   endif
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
415bAC                   if        opmput = 'Y'  and
415bAC                             $lrtn = '*CANCEL '
415bAC                   move      '01 '         nxtscr
415bAC                   eval      refrsh = *on
415bAC                   goto      endsc1
415bAC                   endif
     C     error         cabeq     *on           endsc1
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Everything went fine so onto the next screen.
     *
416iAC                   if        w1rord = 'Y'
416iAC                   eval      refrsh = *on
416iAC                   exsr      scr04i
416iAC                   goto      endsc1
416iAC                   endif
     *
415bAC                   if        opmput = 'Y'
415bA****                 MOVE 'EOJ'     NXTSCR
415bAC                   eval      refrsh = *on
415bAC                   exsr      scr01i
415bAC                   else
416bAC                   eval      refrsh = *on
650fAc                   if        $ifrcvmth = '2' or $ifsltmth = '2'
650hAc                             or $ifucicde = '3' and $ifsltmth <> '2'
650fAc                   if        w1uci = ' '
650fAC                   exsr      scr08i
650fAc                   else
650fAC                   exsr      scr07i
650fAc                   endif
650fAc                   else
     C                   exsr      scr02i
650fAc                   endif
415bAC                   endif
     *
     C     endsc1        endsr
     *
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      'EOJ'         nxtscr
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      '01 '         nxtscr
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Everything went fine so onto the next screen.
     *
416B C                   eval      refrsh = *on
     C                   exsr      scr03i
     *
     C     endsc2        endsr
     *
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
650fAc                   if        $ifrcvmth = '2' or $ifsltmth = '2'
650fAC                   move      '07 '         nxtscr
650fAc                   else
     C                   move      '02 '         nxtscr
650fAc                   endif
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr03i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
650fAc                   if        $ifrcvmth = '2' or $ifsltmth = '2'
650fAC                   move      '07 '         nxtscr
650fAc                   else
     C                   move      '02 '         nxtscr
650fAc                   endif
     C                   goto      endsc3
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
650fAc                   if        $ifrcvmth = '2' or $ifsltmth = '2'
650fAc                   exsr      zzuci
650fAc                   else
     C                   exsr      zzupd3
650fAc                   endif
     C     error         cabeq     *on           endsc3
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     C     endsc3        endsr
     *
     *  SC4  -  Screen 4
     *
     C     sc4           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      '01 '         nxtscr
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr04i
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
730aAc                   if        w1rord='Y'
730aAc                   eval      w1lbl#b=*blanks
730aAc                   eval      w1item=*blanks
730aAc                   eval      wolbl#=*zeros
730aAc                   endif
500a C                   if        $pqck = 'A'
500a C                   move      '06 '         nxtscr
500a C                   else
     C                   move      '01 '         nxtscr
500a C                   endif
     C                   goto      endsc4
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk4
     C     error         cabeq     *on           endsc4
     C                   exsr      zzupd4
     C     error         cabeq     *on           endsc4
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     C     endsc4        endsr
500a *
500a *  SC6  -  Screen 6
500a *
500a C     sc6           begsr
500a *
500a *  Test for F3 - Exit
500a *
500a C                   if        *inkc
500a C                   move      'EOJ'         nxtscr
500a C                   goto      endsc6
500a C                   endif
500a *
500a *  Test for F5 - Refresh
500a *
500a C                   if        *inke
500a C                   eval      refrsh = *on
500a C                   exsr      scr06i
500a C                   goto      endsc6
500a C                   endif
500a *
500a *  Test for F12 - Previous
500a *
500a C                   if        *inkl
500a C                   move      'EOJ'         nxtscr
500a C                   goto      endsc6
500a C                   endif
500a *
500a *
500a *  Test for other command keys BEFORE verification and update.
500a *
500a C                   move      '*BEFORE '    cmdchk
500a C                   exsr      zzcmd6
500a C     cmdtkn        cabeq     *on           endsc6
500a *
500a *  Some other key pressed.
500a *
500a *     Check input and write/update record.
500a *
500a C                   exsr      zzchk6
500a C     error         cabeq     *on           endsc6
500a C                   exsr      zzupd6
500aAC                   if        opmput = 'Y'  and
500aAC                             $lrtn = '*CANCEL '
500aAC                   move      '06 '         nxtscr
500aAC                   eval      refrsh = *on
500aAC                   goto      endsc6
500aAC                   endif
500a C     error         cabeq     *on           endsc6
500a *
500a *  Test for other command keys AFTER verification and update.
500a *
500a C                   move      '*AFTER  '    cmdchk
500a C                   exsr      zzcmd6
500a C     cmdtkn        cabeq     *on           endsc6
500a *
500a *  Everything went fine so onto the next screen.
500a *
500aAC                   eval      refrsh = *on
500aAC                   exsr      scr04i
500aAC                   goto      endsc6
500a *
500a C     endsc6        endsr
650fA*
650fA*
650fA*  SC7  -  Screen 7
650fA*
650fAC     sc7           begsr
650fA*
650fA*  Test for F3 - Exit
650fA*
650fAC                   if        *inkc
650fAC                   move      'EOJ'         nxtscr
650fAC                   goto      endsc7
650fAC                   endif
650fA*
650fA*  Test for F5 - Refresh
650fA*
650fAC                   if        *inke
650fAC                   eval      refrsh = *on
650fAC                   exsr      scr07i
650fAC                   goto      endsc7
650fAC                   endif
650fA*
650fA*  Test for F12 - Previous
650fA*
650fAC                   if        *inkl
650fAC                   move      '01 '         nxtscr
650fAC                   goto      endsc7
650fAC                   endif
650fA*
650fA*  Test for other command keys BEFORE verification and update.
650fA*
650fAC                   move      '*BEFORE '    cmdchk
650fAC                   exsr      zzcmd2
650fAC     cmdtkn        cabeq     *on           endsc7
650fA*
650fA*  Some other key pressed.
650fA*
650fA*     Check input and write/update record.
650fA*
650fAC                   exsr      zzchk7
650fAC     error         cabeq     *on           endsc7
650fAC                   exsr      zzupd7
650fAC     error         cabeq     *on           endsc7
650fA*
650fA*  Test for other command keys AFTER verification and update.
650fA*
650fAC                   move      '*AFTER  '    cmdchk
650fAC                   exsr      zzcmd2
650fAC     cmdtkn        cabeq     *on           endsc7
650fA*
650fA*  Everything went fine so onto the next screen.
650fA*
650fAC                   eval      refrsh = *on
650fAC                   exsr      scr03i
650fA*
650fAC     endsc7        endsr
     *----------------------------------------------------------------
650fA*
650fA*
650fA*  SC8  -  Screen 8
650fA*
650fA /free
650fA   begsr sc8;

650fA     // Test for F3 - Exit
650fA     if *inkc;
650fA       if moretoscan = *on;
650fA         nxtscr = 'CNL';
650fA         leavesr;
650fA       endif;
650fA       setll (*loval) record;
650fA       nxtscr = 'EOJ';
650fA       leavesr;
650fA     endif;

650fA     // Test for F5 - Refresh
650fA     if *inke;
650fA       refrsh = *on;
650fA       exsr scr08i;
650fA       leavesr;
650fA     endif;

650fA     // Test for F12 - Previous
650fA     if *inkl;
650fA       if moretoscan = *on;
650fA         nxtscr = 'CNL';
650fA         leavesr;
650fA       endif;
650fA       setll (*loval) record;
650fA       nxtscr = '01 ';
650fA       w1uci = ' ';
650fA     endif;

650fA     // Test for other command keys BEFORE verification and updat e.
650fA     cmdchk = '*BEFORE ';
650fA     exsr zzcmd8;
650fA     if cmdtkn = *on;
650fA       leavesr;
650fA     endif;

          // Some other key pressed.
          // Check input and write/update record.
650fA     exsr zzchk8;
650fA     if error = *on;
650fA       leavesr;
650fA     endif;
650fA     if moretoscan <> *on;
650fA       leavesr;
650fA     endif;
650fA     exsr zzupd8;
650fA     if error;
650fA       leavesr;
650fA     endif;

          // Test for other command keys BEFORE verification and updat e.
650fA     cmdchk = '*AFTER  ';
650fA     exsr zzcmd8;
650fA     if cmdtkn = *on;
650fA       leavesr;
650fA     endif;

          // Everything went fine get next UCI.
650fA     refrsh = *on;
650fA   endsr;
650fA /end-free
     *----------------------------------------------------------------
650fA*
650fA*  SC9  -  Screen 9
650fA*
650fAC     sc9           begsr
650fA*
650fA*  Test for F3 - Exit
650fA*
650fAC                   if        *inkc
650fAC                   move      '08 '         nxtscr
650fAC                   goto      endsc9
650fAC                   endif
650fA*
650fA*  Test for F5 - Refresh
650fA*
650fAC                   if        *inke
650fAC                   eval      refrsh = *on
650fAC                   exsr      scr09i
650fAC                   goto      endsc9
650fAC                   endif
650fA*
650fA*  Test for F12 - Previous
650fA*
650fAC                   if        *inkl
650fAC                   move      '08 '         nxtscr
650fAC                   goto      endsc9
650fAC                   endif
650fA*
650fA*  Test for other command keys BEFORE verification and update.
650fA*
650fAC                   move      '*BEFORE '    cmdchk
650fAC                   exsr      zzcmd9
650fAC     cmdtkn        cabeq     *on           endsc9
650fA*
650fA*  Some other key pressed.
650fA*
650fA*     Check input and write/update record.
650fA*
650fAC                   exsr      zzchk9
650fAC     error         cabeq     *on           endsc9
650fAC                   exsr      zzupd9
650fAC     error         cabeq     *on           endsc9
650fA*
650fA*  Test for other command keys AFTER verification and update.
650fA*
650fAC                   move      '*AFTER  '    cmdchk
650fAC                   exsr      zzcmd9
650fAC     cmdtkn        cabeq     *on           endsc9
650fA*
650fA*  Everything went fine so onto the next screen.
650fA*
650fAC                   eval      refrsh = *on
650fAC                   exsr      scr01i
650fA*
650fAC     endsc9        endsr
     *----------------------------------------------------------------
650fA*
650fA*
650fA*  SCCNL-  Cancel Warning Window
650fA*
650fAC     scCnl         begsr
650fA*
650fA*  Test for F12 - Previous
650fA*
650fA /free
650fA   if *inkl;
650fA     nxtscr = '08 ';
650fA     leavesr;
650fA   endif;
650fA
650fA /end-free
650fA*
650fA*  Test for other command keys
650fA*
650fAC                   exsr      zzcmdcnl
650fAC     cmdtkn        cabeq     *on           endsccnl
650fA*
650fA*  Some other key pressed.
650fA*
650fA*     Check input and write/update record.
650fA*
650fAC                   exsr      zzupdcnl
650fAc                   if        *inkj
650fAC                   eval      nxtscr = 'EOJ'
650fAc                   endif
650fAC     endsccnl      endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
780aD*
780aD* Get client id.
780aD*
780aDC**                 call      @getcl
780aAC**                 parm                    client           10

750aAC                   call      'GETWHSE'
750aAC                   parm                    #user
750aAC     w1whse        parm      0             #whse             3 0
PCKaA /free
PCKaA   if client = pack730;
PCKaA     *in44 = *on;
PCKaA   endif;
PCKaA /end-free
750aA*
750aA*   Get Return Options.
750aA*
750aAC                   move      '*RETURNS'    ocode
750aA*
750aAC     opkey         chain     options                            79
750aAC                   if        not *in79
750aAC                   eval      oprdta = opdata
750aAc                   endif
750aA /free
750aA   if oppltl = 'Y';
750aA     *in46 = *on;
750aA   else;
750aA     *in46 = *off;
750aA   endif;
750aA /end-free
530bA*
     *  Initialize special keys
     *
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   z-add     01122         rollup
     C                   z-add     01123         rolldn
     C                   z-add     01124         clear
     C                   z-add     01125         help
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
416m *
416mA*                                                                   DOC
416mAC     gtoj$         begsr
416mAC                   move      g$date        g$date
416mA* SPLIT DATE INTO MONTH, DAY, YEAR FIELDS                           DOC
416mAC                   if        dtfrmt = 1
416mAC                   movel     g$date        g$yy
416mAC                   move      g$date        work4
416mAC                   movel     work4         g$mm
416mAC                   move      work4         g$dd
416mAC                   else
416mAC                   movel     g$date        g$mm
416mAC                   move      g$date        work4
416mAC                   movel     work4         g$dd
416mAC                   move      work4         g$yy
416mAC                   endif
416mA* CREATE 4 DIGIT YEAR                                               DOC
416mAC                   move      g$yy          g$yyyy
416mAC                   if        g$yy >= 60
416mAC                   movel     '19'          g$yyyy
416mAC                   else
416mAC                   movel     '20'          g$yyyy
416mAC                   endif
416mAC                   eval      g$jd = 0
416mAC                   eval      g$mmwk = g$mm - 3
416mAC                   eval      gmwksv = g$mmwk
416mAC                   if        g$mmwk < 0
416mAC                   add       12            g$mmwk
416mAC                   endif
416mAC                   if        gmwksv <> 0
416mAC     g$mmwk        mult(h)   30.6          g$jd
416mAC                   endif
416mAC                   add       g$dd          g$jd
416mAC     g$yyyy        sub       1900          g$yywk
416mAC                   if        g$yywk <> 0
416mAC                   if        gmwksv < 0
416mAC                   eval      g$yywk = g$yywk - 1
416mAC                   endif
416mAC                   endif
416mAC     g$yywk        mult      365.25        g$jyd
416mAC                   add       g$jyd         g$jd
416mAC     g$jd          div       7             g$wk7
416mAC                   mvr                     g$dw
416mAC                   endsr
     *----------------------------------------------------------------
416m *
416mA*                                                                   DOC
416mAC     jtog$         begsr
416mAC     j$jd          div       365.25        j$yywk
416mAC     j$jd          div       365.25        j$tst
416mAC                   if        j$tst = 0
416mAC                   eval      j$yywk = j$yywk - 1
416mAC                   endif
416mAC     j$yywk        mult      365.25        j$yd
416mAC                   eval      j$yd = j$jd - j$yd
416mAC                   if        j$yd > 306
416mAC                   add       1             j$yywk
416mAC                   endif
416mAC                   eval      j$x = 0
416mAC                   dou       j$yd <= j$md
416mAC                   add       1             j$x
416mAC     j$x           mult(h)   30.6          j$md
416mAC                   enddo
416mAC                   eval      j$x = j$x - 1
416mAC     j$x           mult(h)   30.6          j$md
416mAC                   eval      j$dd = j$yd - j$md
416mAC     j$x           add       3             j$mm
416mAC                   if        j$mm > 12
416mAC                   sub       12            j$mm
416mAC                   endif
416mAC     j$yywk        add       1900          j$yyyy
416mAC                   if        dtfrmt = 1
416mAC                   move      j$yyyy        work2
416mAC                   movel     j$mm          work4
416mAC                   move      j$dd          work4
416mAC                   movel     work2         j$date
416mAC                   move      work4         j$date
416mAC                   else
416mAC                   move      j$yyyy        work2
416mAC                   movel     j$mm          work4
416mAC                   move      j$dd          work4
416mAC                   move      work2         j$date
416mAC                   movel     work4         j$date
416mAC                   endif
416mAC                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
     C                   move      '*CLEAR '     #msgid
     C                   move      '*NULL  '     #msgtp
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr
     *
     *    ZMPMSG  Add message record to subfile
     *
     C     zmpmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   move      *on           sclear
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
500dA *    DRI0001  Local system caused error
     *----------------------------------------------------------------

500dAC     zm0001        begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmpmsg
500dAC                   endsr
650fA*----------------------------------------------------------------
650fA*   PIR0202  Code already exists.
650fA*
650fAC     zm02          begsr
650fAC                   eval      #msgid = 'PIR0202'
650fAC                   eval      #msgtp = '*DIAG  '
650fAC                   movea     errmsg        $md(1)
650fAC                   exsr      zmpmsg
650fAC                   endsr



     *      0105
     *
     C     zm0105        begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0109  Value can not be less than 0.
     *
     C     zm0109        begsr
     C                   move      'PIR0109'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0110  Value must be > 0.
     *
     C     zm0110        begsr
     C                   move      'PIR0110'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   move      'PIR0112'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
416b *----------------------------------------------------------------
416b *   PIR0203  Value can not be blank.
416b *
416b C     zm0203        begsr
416b C                   move      'PIR0203'     #msgid
416b C                   move      '*DIAG  '     #msgtp
416b C                   movea     errmsg        $md
416b C                   exsr      zmpmsg
416b C                   endsr
416b *----------------------------------------------------------------
416b *   PIR0204  Can only enter one value.
416b *
416b C     zm0204        begsr
416b C                   move      'PIR0204'     #msgid
416b C                   move      '*DIAG  '     #msgtp
416b C                   movea     errmsg        $md
416b C                   exsr      zmpmsg
416b C                   endsr
416b *----------------------------------------------------------------
416b *   PIR0205  Must enter one value.
416b *
416b C     zm0205        begsr
416b C                   move      'PIR0205'     #msgid
416b C                   move      '*DIAG  '     #msgtp
416b C                   movea     errmsg        $md
416b C                   exsr      zmpmsg
416b C                   endsr
650fA*----------------------------------------------------------------
650fA*    zm11202  Invalid value entered
650fA*
650fAC     zm11202       begsr
650fAC                   eval      #msgid = 'OR11202'
650fAC                   eval      #msgtp = '*DIAG  '
650fAC                   movea     errmsg        $md
650fAC                   exsr      zmpmsg
650fAC                   endsr
650iA*----------------------------------------------------------------
650iA*   PO23203  PTI doesn't match calculated PTI.
650iA*
650iAC     zm3203        begsr
650iAC                   eval      #msgid = 'PO23203'
650iAC                   eval      #msgtp = '*DIAG  '
650iAC                   movea     errmsg        $md(1)
650iAC                   exsr      zmpmsg
650iAC                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   move      'PIR9905'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   move      'PIR1001'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1008  Date is required.
     *
     C     zm1008        begsr
     C                   move      'PIR1008'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1009  Date must be > today's date.
     *
     C     zm1009        begsr
     C                   move      'PIR1009'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
416mA*----------------------------------------------------------------
416mA*    PIR1010  Date must be <OR= today's date.
416mA*
416mAC     zm1010        begsr
416mAC                   move      'PIR1010'     #msgid
416mAC                   move      '*DIAG  '     #msgtp
416mAC                   movea     errmsg        $md
416mAC                   exsr      zmpmsg
416mAC                   endsr
417dA*----------------------------------------------------------------
417dA*    PIR4002  Product expired.
417dA*
417dAC     zm4002        begsr
417dAC                   move      'PIR4002'     #msgid
417dAC                   move      '*DIAG  '     #msgtp
417dAC                   movea     errmsg        $md
417dAC                   exsr      zmpmsg
417dAC                   endsr
     *----------------------------------------------------------------
416j *    OR12201  Order previously returned.
     *
416j C     zm1201        begsr
416j C                   move      'OR12201'     #msgid
416j C                   move      '*DIAG  '     #msgtp
416j C                   movea     errmsg        $md
416j C                   exsr      zmpmsg
416j C                   endsr
     *----------------------------------------------------------------
416j *    OR12202  Mispick item cannot be ordered item.
     *
416j C     zm1202        begsr
416j C                   move      'OR12202'     #msgid
416j C                   move      '*DIAG  '     #msgtp
416j C                   movea     errmsg        $md
416j C                   exsr      zmpmsg
416j C                   endsr
     *----------------------------------------------------------------
500a *    OR12203  Disposition must impact inventory.
500a *
500a C     zm1203        begsr
500a C                   move      'OR12203'     #msgid
500a C                   move      '*DIAG  '     #msgtp
500a C                   movea     errmsg        $md
500a C                   exsr      zmpmsg
500a C                   endsr
     *----------------------------------------------------------------
     *    PO15021  P.O. number must be entered.
     *
     C     zm21          begsr
     C                   move      'PO15021'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
415cA*----------------------------------------------------------------
415cA*   PO20029  UPC not on file.
415cA*
415cAC     zm29          begsr
415cAC                   move      'PO20029'     #msgid
415cAC                   move      '*DIAG  '     #msgtp
415cAC                   movea     errmsg        $md(1)
415cAC                   exsr      zmpmsg
415cAC                   endsr
640dA*----------------------------------------------------------------
640dA*    ZM13250  Item not date sensitive.
640dA*
640dAC     zm13250       begsr
640dAC                   eval      #msgid = 'PO13250'
640dAC                   eval      #msgtp = '*DIAG  '
640dAC                   movea     errmsg        $md
640dAC                   exsr      zmpmsg
640dAC                   endsr
650fA*----------------------------------------------------------------
650fA*   PO23701  Mixed Lots on License.
650fA*
650fAC     zm3701        begsr
650fAC                   eval      #msgid = 'PO23701'
650fAC                   eval      #msgtp = '*DIAG  '
650fAC                   movea     errmsg        $md(1)
650fAC                   exsr      zmpmsg
650fAC                   endsr
650fA*----------------------------------------------------------------
650fA*   PO23702  Mixed Expiration Dates on License
650fA*
650fAC     zm3702        begsr
650fAC                   eval      #msgid = 'PO23702'
650fAC                   eval      #msgtp = '*DIAG  '
650fAC                   movea     errmsg        $md(1)
650fAC                   exsr      zmpmsg
650fAC                   endsr
     *----------------------------------------------------------------
740bA*
740bA*  ZZCHK0   Screen 0 error checking.
740bA*
740bAC     zzchk0        begsr
740bAC                   eval      error = *off
740bA*
740bA*  Verify warehouse code.
740bA*
740bAC                   eval      $lcmd = '*VERIFY '
740bAC                   eval      $lwhse = w1whse
740bAC                   call      'WH900'
740bAC                   parm                    $lparm
740bAC                   if        $lrtn = '*PGMQ   '
740bAC                   move      *on           error
740bAC                   eval      *in21 = *on
740bAC                   eval      *in01 = *on
740bAC                   eval      #msgk = $lmsg
740bAC                   exsr      zmqmsg
740bAC                   goto      endck0
740bAC                   else
740bAC                   eval      $fwhse = w1whse
740bAC                   movel     $lerm         $fdesc
740bAC                   call      'FRMTWH'
740bAC                   parm                    $fwhse            3 0
740bAC                   parm                    $fdesc           30
740bAC                   parm                    wowhse
740bAC                   endif
740bA*
740bA*   Get Return Options.
740bA*
740bAC                   move      '0'           flbflg
740bAC                   eval      worexq = *blanks
740bAC                   move      '*RETURNS'    ocode
740bA*
740bAC     opkey         chain     options                            79
740bAC                   if        not *in79
740bAC                   eval      oprdta = opdata
740bAC                   if        oprflb = 'Y'
740bAC                   move      '1'           flbflg
740bAC                   endif
750aA /free
750aA   if oppltl = 'Y';
750aA     *in46 = *on;
750aA   else;
750aA     *in46 = *off;
750aA   endif;
750aA /end-free
740bAC                   move      oprexq        worexq
740bAC                   endif
740bA*  Verify Return whole order Y/N.
740bA*
740bAC                   if        w1rord <> 'Y'  and
740bAC                             w1rord <> 'N'
740bAC                   move      *on           error
740bAC                   eval      *in24 = *on
740bAC                   eval      *in04 = *on
740bAC                   eval      errmsg = *blanks
740bAC                   eval      errmsg = desc(10)
740bAC                   exsr      zm1001
740bAC                   endif
740bA*
740bA*
740bA*
740bA*  If Cash Wa allow alphas in Customer order #, otherwise numeric.
740bA*
740bAC                   select
740bA*
740bA*    If Cash Wa, verify "Customer order #" against order header
740bA*    and route header.
740bAC                   when      (client = cashwa)
740bAC                             and W1orda > ' '
740bAC     oh12key       setll     ordh12
740bAC                   dow       forevr = forevr
740bAC     oh12key       reade     ordh12                                 79
740bAC                   if        %eof
740bAC                   eval      error = *on
740bAC                   leave
740bAC                   endif
740bAC     rhkey         chain     rtehed
740bAC                   if        rhstat > '6'
740bAC                   iter
740bAC                   else
740bAC                   leave
740bAC                   endif
740bAC                   enddo
740bA*    If error on you didn't find the order or the route status is > 6.
740bAC                   If        error = *on
740bAC                   eval      *in27 = *on
740bAC                   eval      *in07 = *on
740bAC                   eval      errmsg = *blanks
740bAC                   movel     desc(21)      errmsg
740bAC                   exsr      zm0105
740bAC                   goto      endck0
740bAC                   Endif
740bA*    Now you've got a Cash Wa order with route <= status 6 so save
740bA*    the customer order number for later in this routine.
740bAC                   eval      w1ord = ohcord
740bAC                   eval      woord = ohcord
740bAC                   eval      woinv# = ohcpo
740bA*
740bA*    If not Cash Wa verify "Customer order #" is entered numeric.
740bAC                   other
740bAC                   eval      pos  = %check (valid : w1orda)
740bA*      Invalid characters
740bAC                   If        pos  > 0
740bAC                   eval      error = *on
740bAC                   eval      *in27 = *on
740bAC                   eval      *in07 = *on
740bAC                   eval      errmsg = *blanks
740bAC                   movel     desc(20)      errmsg
740bAC                   exsr      zm0105
740bAC                   goto      endck0
740bAC                   Endif
740bA *
740bAC                   eval      wklen = %len(%trim(w1orda))
740bA*      Maximum digits allowed = 7.
740bAC                   If        client <> SWT
740bAC                             and wklen > 7
740bAC                   eval      error = *on
740bAC                   eval      *in27 = *on
740bAC                   eval      *in07 = *on
740bAC                   eval      errmsg = *blanks
740bAC                   movel     desc(22)      errmsg
740bAC                   exsr      zm0105
740bAC                   goto      endck0
740bAC                   Endif
740bA*
740bA*      Convert characters entered into numeric fields.
740bAC                   eval      w1ord = 0
740bA*
740bAC                   if        w1orda > ' '
740bAC                             and pos = 0
740bAC*                  eval      w1ord = %dec(w1orda:5:0)
740bAC                   eval      w1ord = %dec(w1orda:7:0)
740bAC                   endif
740bA*
740bAC                   endsl
740bA*
740bA*      If Customer Order was entered confirm as valid and fill
740bA*      label# from that found customer order#.  Only perform this
740bA*      logic when Whole Order is Yes and no label is entered
740bA*
740bA /free
740bA            if w1rord = 'Y'
740bA            and w1lbl#b = *blanks
740bA            and w1ord<>0;
740bA               exec sql select cast(lblbl# as char(7)),lblbl#
740bA                                into :w1lbl#b,:wolbl#
740bA                          from ordh5 left join label
740bA                           on ohwhse=lbwhse and ohord=lbord
740bA                         where ohwhse=:w1whse and ohcord=:w1ord
740bA                           and lbtype='O'
740bA                       order by ohsdte desc
740bA                        fetch first row only;
740bA               chain (wolbl#) label;
740bA               if %found(label);
740bA                 chain (lbwhse:lbitem) piritem;
740bA                 if %found(piritem);
740bA                   woitem = %trim(lbitem) + ' - ' + %trim(itdesc);
740bA                 endif;
740bA               endif;
740bA            endif;
740bA /end-free
740bA*
740bA*  Verify Packers sales org code.
740bA*
740bAc                   if        client = pack730
740bAC                   if        pckorg <> 2000 and
740bAC                             pckorg <> 2100
740bAC                   move      *on           error
740bAC                   eval      *in45 = *on
740bAC                   eval      errmsg = *blanks
740bAC                   eval      errmsg = 'Invalid Sales Org'
740bAC                   exsr      zm0105
740bAC                   goto      endck0
740bAC                   endif
740bA*  Verify Order #.
740bA*  For Alpha interface only.
740bAc                   if        w1ord = 0 and w1orda <> ' '
740bAC                   eval      w1ord = %dec(w1orda:7:0)
740bAc                   endif
740bA*
740bA*  Check for duplicate customer order numbers.
740bAC                   exsr      zzckdupord
740bAC                   if        error = '1'
740bAC                   goto      endck0
740bAC                   endif
740bA*
740bA*      No duplicate orders found or selected.
740bAC                   if        optslt = '0'
740bA /free
740bA   setll (w1whse: w1ord) ordh5;
740bA   dow forevr = forevr;
740bA     reade (w1whse: w1ord) ordh5;
740bA     if %eof(ordh5);
740bA       error = *on;
740bA       *in22 = *on;
740bA       *in02 = *on;
740bA       errmsg = *blanks;
740bA       errmsg = desc(1);
740bA       exsr zm1001;
740bA       leavesr;
740bA     endif;
740bA     chain (ohwhse: ohrte) rtehed;
740bA     if %found(rtehed);
740bA       select;
740bA         when rhrte<='00099' and pckorg= 2000
740bA              or  rhrte ='99   ' and pckorg= 2000
740bA              and rhtype = 'W';
740bA           w1ord = ohcord;
740bA           leave;
740bA
740bA         when rhrte<='00099' and pckorg= 2100
740bA              or  rhrte ='99   ' and pckorg= 2100
740bA              and rhtype = 'W';
740bA           iter;
740bA
740bA         when rhrte >= '00100' and rhrte <= '00199'
740bA              and pckorg = 2100
740bA              or  rhrte ='199  ' and pckorg= 2100
740bA              and rhtype = 'W';
740bA           w1ord = ohcord;
740bA           leave;
740bA
740bA         when rhrte>='00100' and pckorg= 2000
740bA              or  rhrte ='199  ' and pckorg= 2000
740bA              and rhtype = 'W';
740bA           iter;
740bA
740bA         when pckorg =  2200
740bA              and (rhrte >= '00200' and rhrte <= '00299'
740bA              or   rhrte = '299   ' and rhtype = 'W');
740bA           w1ord = ohcord;
740bA           leave;
740bA
740bA         other;
740bA           iter;
740bA       endsl;
740bA
740bA     endif;
740bA
740bA   enddo;
740bA /end-free
740bAc                   endif
740bA*
740bAC                   endif
740bA*
740bAC                   if        client = Pack730
740bAC                   eval      woinv# = %char(w1ord)
740bAC                   eval      wslord = lbord
740bAc                   endif
740bA*
740bA*  Verify whole order was not previously returned.               turns)
740bA*
740bAC                   if        w1rord = 'Y'
740bA **                 move  **  'Y'           kywhol
740bAC                   move      ' '           kywhol
740bA* look for ANY item returned if trying to Return Whole Order
740bA*   but still look if previous Return as Whole Order (Duplicate)
740bA*
740bAC     rtnkey        setll     orrtn2
740bAC                   move      *off          stop
740bAC                   dou       stop = *on
740bA *   *rtnkey        reade     orrtn2                                 79
740bAC     rtnkeyx       reade     orrtn2                                 79
740bAC                   if        *in79
740bAC                   move      *on           stop
740bAC                   else
740bAC                   move      *on           stop
740bAC                   move      *on           error
740bAC                   eval      errmsg = *blanks
740bAC                   eval      *in24 = *on
740bAC                   eval      *in04 = *on
740bAC                   exsr      zm1201
740bAC                   goto      endck0
740bAC                   endif
740bAC                   enddo
740bAC     ohkey         chain     ordh                               78
740bAC                   if        not *in78
740bAC                   eval      w1ord = ohcord
740bAC                   eval      woord = ohcord
740bAC                   endif
740bAC                   endif
740bA*
740bA*  Verify order number is within range. (Don't check for Quick Returns)
740bA*
740bAC                   if        $pqck = 'N'
740bAC                             and client <> cashwa
740bAC                             and client <> swt
740bAC                   if        w1ord < 1  or
740bAC                             w1ord > 9999999
740bAC                   eval      error = *on
740bAC                   eval      *in27 = *on
740bAC                   eval      *in07 = *on
740bAC                   eval      errmsg = *blanks
740bAC                   movel     desc(1)       erfld
740bAC                   movel     '1'           erfrom
740bAC                   movel     '9999999'     erto
740bAC                   exsr      zm0112
740bAC                   goto      endck0
740bAC                   endif
740bAC                   endif
740bA*
740bA*
740bA*
740bA*  Verify printer device.
740bA*
740bAC                   movel     w1dev         work1a
740bAC                   if        work1a = '*'  and
740bAC                             w1dev <> '*DEFAULT'  and
740bAC                             w1dev <> '*SYSVAL'  and
740bAC                             w1dev <> '*JOB'  or
740bAC                             w1dev = *blanks
740bAC                   move      *on           error
740bAC                   eval      *in28 = *on
740bAC                   eval      *in08 = *on
740bAC                   eval      errmsg = *blanks
740bAC                   eval      errmsg = desc(3)
740bAC                   exsr      zm1001
740bAC                   endif
740bA*
740bA*  Verify default form type
740bA*
740bAC                   movel     w1form        work1a
740bAC                   if        work1a = '*'  and
740bAC                             w1form <> '*DEFAULT'  and
740bAC                             w1form <> '*STD'  or
740bAC                             w1form = *blanks
740bAC                   move      *on           error
740bAC                   eval      *in29 = *on
740bAC                   eval      *in09 = *on
740bAC                   eval      errmsg = *blanks
740bAC                   eval      errmsg = desc(4)
740bAC                   exsr      zm1001
740bAC                   endif
740bA*
740bAC     endck0        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
416bAC                   eval      wsitem = *blanks
     *
     *  Verify warehouse code.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
416bAC                   goto      endck1
     C                   else
     C                   eval      $fwhse = w1whse
     C                   movel     $lerm         $fdesc
     C                   call      'FRMTWH'
     C                   parm                    $fwhse            3 0
     C                   parm                    $fdesc           30
     C                   parm                    wowhse
     C                   endif
DRYaA*
DRYaA*  Dairyland - Can not use quick returns.
DRYaA*
DRYaAC                   if        client = dairyl and
DRYaAC                             $pqck = 'Y'
DRYaAC                   eval      error = *on
DRYaAC                   eval      errmsg = *blanks
DRYaAC                   eval      errmsg = desc(15)
DRYaAC                   eval      *in35 = *on
DRYaAC                   eval      *in15 = *on
DRYaAC                   exsr      zm0203
DRYaAC                   goto      endck1
DRYaAC                   endif

780aA    // When using Host Lots and quick returns ...
780aA    //  - Label # must be entered.
780aA
780aA    if usingHostLots and $pqck = 'Y';
780aA      If w1lbl#b = '';
780aA        *in22 = *on;
780aA        *in02 = *on;
780aA        errmsg = 'Host Lots - Label # must be entered';
780aA        exsr zm0105;
780aA        leavesr;
780aA      endif;
780aA    endif;

780aA    // For Dairyland and Host Lots ...
780aA    //  - Set flag that will verify an entered item
780aA    //    exists on the customer order.
780aA
780aA    if usingHostLots or client = dairyl;
780aA      vfyItemOnOrder = *on;
780aA    else;
780aA      vfyItemOnOrder = *off;
780aA    endif;

416b *
416b *   Get Return Options.
416b *
416bAC                   move      '0'           flbflg
416bAC                   eval      worexq = *blanks
416eAC                   move      '*RETURNS'    ocode
416b *
416bAC     opkey         chain     options                            79
416bAC                   if        not *in79
416bAC                   eval      oprdta = opdata
416bAC                   if        oprflb = 'Y'
416bAC                   move      '1'           flbflg
416bAC                   endif
416eAC                   move      oprexq        worexq
416bAC                   endif
414 A*  Verify Return whole order Y/N.
     *
416iAC                   if        w1rord <> 'Y'  and
416iAC                             w1rord <> 'N'
416iAC                   move      *on           error
416iAC                   eval      *in24 = *on
416iAC                   eval      *in04 = *on
416iAC                   eval      errmsg = *blanks
416iAC                   eval      errmsg = desc(10)
416iAC                   exsr      zm1001
416iAC                   endif
414 A*  Pallet license
     *
750aAC                   if        *in46 and PLTLCNS <> ' '
750aAc                   if        %subst(pltlcns:1:6) <> 'RTNPLT'
750aAC                   move      *on           error
750aAC                   eval      *in47 = *on
750aAC                   eval      errmsg = *blanks
750aAC                   eval      errmsg = 'Invalid Pallet License +
750aAc                                      must begin with RTNPLT'
750aAC                   exsr      zm0105
750aAC                   goto      endck1
750aAC                   endif
750aA /free
750aA   // has putaway of pallet license begun
750aA   exec sql select * into :rnlrec
750aA        from pltlcns
750aA        where rnlwhse = :w1whse
750aA          and rnlpltlcns = :pltlcns
750aA          and rnlput = 'Y'
750aA            fetch first 1 rows only;

750aA   If sqlstt = sqlSuccess;
750aA     error = *on;
750aA     *in47 = *on;
750aA     errmsg = *blanks;
750aA     errmsg = 'Pallet is already in put away process';
750aA     exsr zm0105;
750aA   endif;
750aA /end-free
750aAC                   endif
     *
EGFaA*
EGFaA*  Force cust # to be entered for EGF, *IN56=off
EFGaA*
EGFaAC                   if        client = egf  and
EGFaAC                             w1cnum = 0
EGFaAC                   eval      error = *on
EGFaAC                   eval      errmsg = *blanks
EGFaAC                   eval      errmsg = desc(12)
EGFaMC                   eval      *in35 = *on
EGFaMC                   eval      *in15 = *on
EGFaAC                   exsr      zm0203
EGFaAC                   goto      endck1
EGFaAC                   endif
     *
650kA*  If Cash Wa allow alphas in Customer order #, otherwise numeric.
650kA*
650kAC                   select
650kA*
650kA*    If Cash Wa, verify "Customer order #" against order header
650kA*    and route header.
650kAC                   when      (client = cashwa)
650kAC                             and W1orda > ' '
650kAC     oh12key       setll     ordh12
650kAC                   dow       forevr = forevr
650kAC     oh12key       reade     ordh12                                 79
650kAC                   if        %eof
650kAC                   eval      error = *on
650kAC                   leave
650kAC                   endif
650kAC     rhkey         chain     rtehed
650kAC                   if        rhstat > '6'
650kAC                   iter
650kAC                   else
650kAC                   leave
650kAC                   endif
650kAC                   enddo
650kA*    If error on you didn't find the order or the route status is > 6.
650kAC                   If        error = *on
650kAC                   eval      *in27 = *on
650kAC                   eval      *in07 = *on
650kAC                   eval      errmsg = *blanks
650kAC                   movel     desc(21)      errmsg
650kAC                   exsr      zm0105
650kAC                   goto      endck1
650kAC                   Endif
650kA*    Now you've got a Cash Wa order with route <= status 6 so save
650kA*    the customer order number for later in this routine.
650kAC                   eval      w1ord = ohcord
650kAC                   eval      woord = ohcord
650kAC                   eval      woinv# = ohcpo
650kA*
650kA*    If not Cash Wa verify "Customer order #" is entered numeric.
650kAC                   other
650kAC                   eval      pos  = %check (valid : w1orda)
650kA*      Invalid characters
650kAC                   If        pos  > 0
650kAC                   eval      error = *on
650kAC                   eval      *in27 = *on
650kAC                   eval      *in07 = *on
650kAC                   eval      errmsg = *blanks
650kAC                   movel     desc(20)      errmsg
650kAC                   exsr      zm0105
650kAC                   goto      endck1
650kAC                   Endif
700dA *
700dAC                   eval      wklen = %len(%trim(w1orda))
700dA*      Maximum digits allowed = 7.
SWTaAC                   If        client <> SWT
700dAC                             and wklen > 7
700dAC                   eval      error = *on
700dAC                   eval      *in27 = *on
700dAC                   eval      *in07 = *on
700dAC                   eval      errmsg = *blanks
700dAC                   movel     desc(22)      errmsg
700dAC                   exsr      zm0105
700dAC                   goto      endck1
700dAC                   Endif
650kA*
650kA*      Convert characters entered into numeric fields.
650kAC                   eval      w1ord = 0
650kA*
650kAC                   if        w1orda > ' '
650kAC                             and pos = 0
700dDC*                  eval      w1ord = %dec(w1orda:5:0)
700dMC                   eval      w1ord = %dec(w1orda:7:0)
650kAC                   endif
650kA*
650kAC                   endsl
730aA*
730aA*      If Customer Order was entered confirm as valid and fill
730aA*      label# from that found customer order#.  Only perform this
730aA*      logic when Whole Order is Yes and no label is entered
730aA*
730aA /free
730aA            if w1rord = 'Y'
730aA            and w1lbl#b = *blanks
730aA            and w1ord<>0;
730aA               exec sql select cast(lblbl# as char(7)),lblbl#
730aA                                into :w1lbl#b,:wolbl#
730aA                          from ordh5 left join label
730aA                           on ohwhse=lbwhse and ohord=lbord
730aA                         where ohwhse=:w1whse and ohcord=:w1ord
740cD                           //and lbtype='O'
740cM                           and (lbtype='O' or lbtype = 'B')
730aA                       order by ohsdte desc
730aA                        fetch first row only;
730aA               chain (wolbl#) label;
730aA               if %found(label);
730aA                 chain (lbwhse:lbitem) piritem;
730aA                 if %found(piritem);
730aA                   woitem = %trim(lbitem) + ' - ' + %trim(itdesc);
730aA                 endif;
730aA               endif;
730aA            endif;
730aA /end-free
650kA*
     *
416fD*  Verify user id.
416fD*
416fD*R                   MOVE '*VERIFY '$LCMD
416fD*R                   MOVE W1USER    $LUSER
416fD*R                   CALL 'US900'
416fD*R                   PARM           $LPARM
416fD*R         $LRTN     IFEQ '*PGMQ   '
416fD*R                   MOVE *ON       ERROR
416fD*R                   MOVE *ON       *IN24
416fD*R                   MOVE *ON       *IN04
416fD*R                   MOVE $LMSG     #MSGK
416fD*R                   EXSR ZMQMSG
416fD*R                   GOTO ENDCK1
416fD*R                   ENDIF
416bA*
416bA*  Must enter one value Label, upc, item or mfg code/vendor item.
416bA*
530cD ***                if        w1lbl# = 0  and
530cD ***                          w1upc = *blanks  and
530cD ***                          w1item = *blanks  and
530cD ***                          w1vmfg = *blanks
530cMC                   if        w1lbl#b = *blanks
650fDC*                            and w1upc  = *blanks
650fMC                             and w1uci  = *blanks
530cMC                             and w1item = *blanks
530cMC                             and w1vmfg = *blanks
416bAC                   move      *on           error
416bAC                   eval      errmsg = *blanks
416bAC                   eval      errmsg = desc(1)
416bMC                   eval      *in22 = *on
416bMC                   eval      *in23 = *on
416bMC                   eval      *in25 = *on
416bMC                   eval      *in26 = *on
416bMC                   eval      *in02 = *on
416bAC                   exsr      zm0205
416bAC                   goto      endck1
416bAC                   endif
416iA*
416iA*  Force label to be entered if return whole order = Y.
416iA*
530cD ***                if        w1rord = 'Y'  and
530cD ***                          w1lbl# = 0
530cMC                   if        w1rord = 'Y'
530cMC                             and w1lbl#b = *blanks
416iAC                   eval      error = *on
416iAC                   eval      errmsg = *blanks
416iAC                   eval      errmsg = desc(6)
416iMC                   eval      *in22 = *on
416iMC                   eval      *in02 = *on
416iAC                   exsr      zm0203
416iAC                   goto      endck1
416iAC                   endif
416bA*
416bA*  Force label to be entered if option OPRFLB='Y'.
416bA*
530cD ***                if        flbflg = '1'  and
530cD ***                          w1lbl# = 0
530cMC                   if        flbflg = '1'
530cMC                             and w1lbl#b = *blanks
416bAC                   eval      error = *on
416bAC                   eval      errmsg = *blanks
416bAC                   eval      errmsg = desc(6)
416bMC                   eval      *in22 = *on
416bMC                   eval      *in02 = *on
416bAC                   exsr      zm0203
416bAC                   goto      endck1
416bAC                   endif
415aA*
415aA*  Verify label number.
415aA*
415aAC                   eval      wolbl# = 0
415aAC                   eval      wotrn# = 0
415aAC                   eval      woord = 0
530cD ***                if        w1lbl# <> 0
530cMC                   if        w1lbl#b <> *blanks
     * grab label#
530cAC                   move      w1whse        $pwhseb
530cAC                   movel     w1lbl#b       $pbarcode
530cAC                   call      @cvtbarsel
530cAC                   parm                    $pwhseb           3
530cAC                   parm                    $pbarcode        15
530cAC                   parm                    $plbl#            7 0
530cAC                   parm                    $prtid            5
530cAC                   parm                    $punq#            5
530cAC                   parm                    $preturn          8
530cAC                   parm                    $perrmsg         60
530cAC                   if        $preturn = '*OK'
530cAC                   eval      w1lbl# = $plbl#
750aAc                   eval      hldpicklbl = w1lbl#b
530cAC                   move      *blanks       w1lbl#b
530cAC                   move      $plbl#        w1lbl#b
530cAC                   else
530cAC                   eval      error = *on
530cAC                   eval      *in22 = *on
530cAC                   movel     desc(12)      errmsg
530cAC                   exsr      zm0110
530cAC                   endif
650fDC*                  if        w1upc = *blanks  and
650fMC                   if        w1uci = *blanks  and
416bAC                             w1item = *blanks  and
416bAC                             w1vmfg = *blanks
415aAC                   z-add     w1lbl#        wolbl#
415aAC     wolbl#        chain     label                              79
415aAC                   if        *in79
640cAC                   z-add     0             wolbl#
640cAC                   z-add     0             w1lbl#
415aAC                   eval      error = *on
415aAC                   eval      errmsg = *blanks
415aAC                   eval      errmsg = desc(1)
416bD**                   MOVE *ON       *IN34
416bD**                   MOVE *ON       *IN14
416bMC                   eval      *in22 = *on
416bMC                   eval      *in02 = *on
415aAC                   exsr      zm1001
416bAC                   goto      endck1
415aAC                   else
415aAC                   move      lbitem        wsitem
46iaAC                   z-add     lbord         wslord
415aAC                   z-add     lbtrn#        wotrn#
415bAC     ohkey         chain     ordh                               78
415bAC                   if        not *in78
415bAC                   eval      w1ord = ohcord
415bAC                   eval      woord = ohcord
CWD AC                   select
CWD MC                   when      client = sgc
GMM AC                             or client = MenuMaker
SGCaAC                   move      *blanks       woinv#
SWTaA*
SWTaAC                   when      client = swt
SWTaAC     ohkey         chain     ordhexa
SWTaAC                   if        *in79
SWTaAC                   move      *blanks       woinv#
SWTAAC                   else
SWTaAC                   eval      woinv# = ohaorda
SWTAAC                   endif
CWD A*
CWD AC                   when      client = cashwa
CWD AC                   eval      woinv# = ohcpo
CWD MC                   other
CWD A*
416dAC                   movel     ohmisc        woinv#
CWD MC                   endsl
CWD A*
415bAC                   endif
415aAC                   endif
416bAC                   else
416bA*  Error, more than one value entered.
416bAC                   move      *on           error
416bAC                   eval      *in22 = *on
416bAC                   eval      *in23 = *on
416bAC                   eval      *in25 = *on
416bAC                   eval      *in26 = *on
416bAC                   eval      *in02 = *on
416bAC                   eval      errmsg = *blanks
416bAC                   exsr      zm0204
416bAC                   goto      endck1
416bAC                   endif
415aAC                   endif
740aA*  Verify Packers sales org code.
740aA*
PCKaAc                   if        client = pack730
740aAC                   if        pckorg <> 2000 and
740aAC                             pckorg <> 2100
740aAC                   move      *on           error
740aAC                   eval      *in45 = *on
740aAC                   eval      errmsg = *blanks
740aAC                   eval      errmsg = 'Invalid Sales Org'
740aAC                   exsr      zm0105
740aAC                   goto      endck1
740aAC                   endif
PCKaA*  Verify Order #.
PCKaA*  For Alpha interface only.
PCKaAc                   if        w1ord = 0 and w1orda <> ' '
PCKaAC                   eval      w1ord = %dec(w1orda:7:0)
PCKaAc                   endif
PCKaA*
PCKaA*  Check for duplicate customer order numbers.
PCKaAC***                exsr      zzckdupord
PCKaAC***                if        error = '1'
PCKaAC***                goto      endck1
PCKaAC***                endif
PCKaA*
PCKaA*      No duplicate orders found or selected.
PCKaAC                   if        optslt = '0'
PCKaA /free
PCKaA   setll (w1whse: w1ord) ordh5;
PCKaA   dow forevr = forevr;
PCKaA     reade (w1whse: w1ord) ordh5;
PCKaA     if %eof(ordh5);
PCKaA       error = *on;
PCKaA       *in22 = *on;
PCKaA       *in02 = *on;
PCKaA       errmsg = *blanks;
PCKaA       errmsg = desc(1);
PCKaA       exsr zm1001;
PCKaA       leavesr;
PCKaA     endif;
PCKaA     chain (ohwhse: ohrte) rtehed;
PCKaA     if %found(rtehed);
PCKaA       select;
PCKaA         when rhrte<='00099' and pckorg= 2000
PCKaA              or  rhrte ='99   ' and pckorg= 2000
PCKaA              and rhtype = 'W';
PCKaA           w1ord = ohcord;
PCKaA           leave;
PCKaA
PCKaA         when rhrte<='00099' and pckorg= 2100
PCKaA              or  rhrte ='99   ' and pckorg= 2100
PCKaA              and rhtype = 'W';
PCKaA           iter;
PCKaA
PCKaA         when rhrte >= '00100' and rhrte <= '00199'
PCKaA              and pckorg = 2100
PCKaA              or  rhrte ='199  ' and pckorg= 2100
PCKaA              and rhtype = 'W';
PCKaA           w1ord = ohcord;
PCKaA           leave;
PCKaA
PCKaA         when rhrte>='00100' and pckorg= 2000
PCKaA              or  rhrte ='199  ' and pckorg= 2000
PCKaA              and rhtype = 'W';
PCKaA           iter;
PCKaA
PCKaA         when pckorg =  2200
PCKaA              and (rhrte >= '00200' and rhrte <= '00299'
PCKaA              or   rhrte = '299   ' and rhtype = 'W');
PCKaA           w1ord = ohcord;
PCKaA           leave;
PCKaA
PCKaA         other;
PCKaA           iter;
PCKaA       endsl;
PCKaA
PCKaA     endif;
PCKaA
PCKaA   enddo;
PCKaA /end-free
PCKaAc                   endif
PCKaA*
PCKaAC                   endif
PCKaA*
PCkaAC                   if        client = Pack730
PCKaAC                   eval      woinv# = %char(w1ord)
PCKaAc                   endif
     *
416j *  Verify whole order was not previously returned.               turns)
     *
416jAC                   if        w1rord = 'Y'
720bD **                 move  **  'Y'           kywhol
720bMC                   move      ' '           kywhol
720b * look for ANY item returned if trying to Return Whole Order
720c *   but still look if previous Return as Whole Order (Duplicate)
     *
416jAC     rtnkey        setll     orrtn2
416jAC                   move      *off          stop
416jAC                   dou       stop = *on
720cM *   *rtnkey        reade     orrtn2                                 79
720cMC     rtnkeyx       reade     orrtn2                                 79
416jAC                   if        *in79
416jAC                   move      *on           stop
416jAC                   else
416jAC                   move      *on           stop
416jAC                   move      *on           error
416jAC                   eval      errmsg = *blanks
416jAC                   eval      *in24 = *on
416jAC                   eval      *in04 = *on
416jAC                   exsr      zm1201
416jAC                   goto      endck1
416jAC                   endif
416jAC                   enddo
416jAC                   endif
     *
     *  Verify order number is within range. (Don't check for Quick Returns)
     *
416CAC                   if        $pqck = 'N'
650kAC                             and client <> cashwa
SWTaAC                             and client <> swt
     C                   if        w1ord < 1  or
     C                             w1ord > 9999999
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       erfld
     C                   movel     '1'           erfrom
     C                   movel     '9999999'     erto
     C                   exsr      zm0112
416bAC                   goto      endck1
     C                   endif
416CAC                   endif
415c *
415cAC                   select
415c *  UPC entered
650fDC*                  when      w1upc <> *blanks
650fMC                   when      w1uci <> *blanks
416bAC                   if        w1lbl# = 0  and
416bAC                             w1item = *blanks  and
416bAC                             w1vmfg = *blanks
415c *
650fDC*                  eval      $cbcmd = '*UPC    '
650fDC*                  movel     w1upc         $cbbar
650fMC                   eval      $cbcmd = '*ALL    '
650fMC                   movel     w1uci         $cbbar
415cAC                   call      'CVTBAR'
415cAC                   parm                    $cbcmd            8
415cAC                   parm                    $cbbar          100
415cAC                   parm                    $cbcod            3 0
415cAC                   parm                    $cbdec            1 0
415cAC                   parm                    $cbdsc           30
415cAC                   parm                    $cbpos            3 0
415cAC                   parm                    $cbtyp            1 0
415cAC                   parm                    $cbv1            11 3
415cAC                   parm                    $cbv2            50
415cAC                   parm                    $cbrtn            8
415cAC                   parm                    $cberm           60
650fAC                   parm                    $cbven           10 0
650fAC                   parm                    $cvtdata
650fAC                   parm                    $cvtdata2
415c *
650fAc                   eval      $barcode = $cvtdata
650fAc                   eval      $barcode2 = $cvtdata2
650fA * Load UPC
650fAc                   if        $bcGtinSent
650fAc                   eval      w1upc  = $bcGtin
650fAc                   eval      *in92 = *on
650fAc                   else
650fAc                   eval      w1upc  = w1uci
650fAc                   endif
650fA * Load Expiration Date
650fAc                   if        $bcExpDSent
650fAc                   eval      $lexpdt6 = $bcExpD
650fAc                   endif
650fA * Load Manufacturing Date
650fAc                   if        $bcProdDSent
650fAc                   eval      $lmfgdt6 = $bcProdD
650hAc                   eval      $lbcProdD = $bcProdD
650fAc                   endif
650fA * Load Catch Weight
650fAc                   if        $bcPNtLbSent
650fAc                   endif
650fDC*                  if        $cbrtn = '*OK'
650fDC*                  eval      w1upc = $cbv2
650fDC*                  endif
415c *
415c *   Right adjust UPC code for file.
415c *
415cAC                   eval      $cstr = *blanks
415cAC                   movel     w1upc         $cstr
415cAC                   call      'ADJUST'
415cAC                   parm      '*RIGHT  '    $ccmd             8
415cAC                   parm                    $cstr            30
510aDC*                  eval      kyupc = $cstr
510aMC                   move      $cstr         kyupc
417a *   Check if mulitple items exist for one UPC code.
417a *    UPCCTR = 0, error, upc code not found.
417a *    UPCCTR = 1, only one upc found, process for item.
417a *    UPCCTR > 1, multiple upc found, need to select item.
417a C                   eval      upcctr = 0
417a C     upckey        setll     upc
417a C                   dow       forevr = forevr
417a C     upckey        reade     upc                                    79
     *
417a C                   if        *in79
417a C                   leave
417a C                   else
417a C                   add       1             upcctr
417a C                   endif
     *
417a C                   enddo
     *
417aD**         UPCKEY    CHAINUPC                  79
417aD**         *IN79     IFEQ *ON
417a C                   if        upcctr = 0
415cAC                   move      *on           error
415cAC                   eval      *in25 = *on
415cAC                   eval      *in05 = *on
415cAC                   eval      errmsg = *blanks
415cAC                   exsr      zm29
415cAC                   goto      endck1
415cAC                   endif
     *
     *   Multiple items exist for UPC
417a C                   if        upcctr > 1
417a C                   eval      $lcmd = '*VERIFY '
417a C                   eval      $lwhse = w1whse
417a C                   move      kyupc         $lupc
417a C                   call      'UC920'
417a C                   parm                    $lparm
417a C                   if        $lrtn = '*ERROR  '
417a C                   move      *on           error
417a C                   eval      *in24 = *on
417a C                   eval      *in04 = *on
417a C                   movel     $lerm         errmsg
417a C                   exsr      zm0105
417a C                   else
417a C                   if        $lrtn = '*PGMQ   '
417a C                   move      *on           error
417a C                   eval      *in24 = *on
417a C                   eval      *in04 = *on
417a C                   eval      #msgk = $lmsg
417a C                   exsr      zmqmsg
417a C                   endif
417a C                   endif
417a C                   eval      upitem = $litm1
     *
417a C                   endif
     *
415c *
415cAC                   eval      wsitem = upitem
416bAC                   else
416bA*  Error, more than one value entered.
416bAC                   move      *on           error
416bAC                   eval      *in22 = *on
416bAC                   eval      *in23 = *on
416bAC                   eval      *in25 = *on
416bAC                   eval      *in26 = *on
416bAC                   eval      *in05 = *on
416bAC                   eval      errmsg = *blanks
416bAC                   exsr      zm0204
416bAC                   goto      endck1
416bAC                   endif
415c *
415cAC                   endsl
416b *
416b *  Verify Mfg code/vendor item.
416b *
416bAC                   if        w1vmfg <> *blanks
416bAC                   if        w1lbl# = 0  and
650fDC*                            w1upc = *blanks  and
650fMC                             w1uci = *blanks  and
416bAC                             w1item = *blanks
416bAC                   move      w1vmfg        kyvmfg
416bAC     mfgkey        chain     piritem4                           79
416bAC                   if        *in79
416bAC                   move      *on           error
416dAC                   eval      *in26 = *on
416dAC                   eval      *in06 = *on
416bAC                   eval      errmsg = *blanks
416dAC                   eval      errmsg = desc(9)
416dAC                   exsr      zm1001
416bAC                   goto      endck1
416bAC                   else
416bAC                   move      ititem        wsitem
416bAC                   endif
416bAC                   else
416bA*  Error, more than one value entered.
416bAC                   move      *on           error
416bAC                   eval      *in22 = *on
416bAC                   eval      *in23 = *on
416bAC                   eval      *in25 = *on
416bAC                   eval      *in26 = *on
416bAC                   eval      *in05 = *on
416bAC                   eval      errmsg = *blanks
416bAC                   exsr      zm0204
416bAC                   goto      endck1
416bAC                   endif
416bAC                   endif
     *
416bA*  Error, more than one value entered.
416bAC                   if        w1item <> *blanks
416bAC                   if        w1lbl# <> 0  or
650fDC*                            w1upc <> *blanks  or
650fMC                             w1uci <> *blanks  or
416bAC                             w1vmfg <> *blanks
416bAC                   move      *on           error
416bAC                   eval      *in22 = *on
416bAC                   eval      *in23 = *on
416bAC                   eval      *in25 = *on
416bAC                   eval      *in26 = *on
416bAC                   eval      *in03 = *on
416bAC                   eval      errmsg = *blanks
416bAC                   exsr      zm0204
416bAC                   goto      endck1
416bAC                   endif
416bAC                   endif
     *
     *  Get item # from other field entered.
     *
416bAC                   if        w1item = *blanks  and
416bAC                             wsitem <> *blanks
416bAC                   move      wsitem        w1item
416bAC                   endif
     *
     *  Verify item number.
     *
650fA * add dri to get data from itemfld
650fA /free
650fA   exsr clr$item;

650fA   $itWhse = w1whse;
650fA   $ititem = w1item;

650fA   $dricommand = '*ITEM';
650fA   $drisubcmd  = '%GETALL';
650fA   $drisys2upd = 'D';
650fA   chk4err = *on;
650fA   zmflag  = *off;
650fA   exsr zzzdricop;
650fA   if error = *on;
650fA     $ifucicde = ' ';
650fA     $ifrcvmth = ' ';
650fA   endif;

740dA   // check to make sure ssb item has a breakdown uom defined
740dA   if $ittype = 'S' and $itum2 = ' ';
740dA     error = *on;
740dA     errmsg = '';
740dA     errmsg = 'Missing Breakdown UOM - Fix item.';
740dA     exsr zm0105;
740dA     leavesr;
740dA   endif;
650fA   if $ifrcvmth = '2' or $ifsltmth = '2';
650fA     *in73 = *off;
650fA     if w7lcns <> ' ';
650fA       *in80 = *on;
650fA     endif;
650fA     // check to make sure UCI barcode does not already exist
650fA     if w1uci <> ' ';
650fA       exsr clr$uciinfo;
650fA
650fA       $uiWhse = w1whse;
650fA       $uiuci  = w1uci;
650fA       $uiitem = w1item;
650fA
650fA       $dricommand = '*UCIINFO';
650fA       $drisubcmd  = '%CHKACTV';
650fA       $drisys2upd = 'D';
650fA       chk4err = *on;
650fA       zmflag  = *off;
650fA       exsr zzzdricop;
650fA       // if return is *EXIST seton error
650fA       if $drireturn = '*EXIST';
650fA         error = *on;
650fA         errmsg = desc(17);
650fA         eval nxtscr = '01 ';
650fA         exsr zm02;
650fA         eval w1item = ' ';
650fA         leavesr;
650fA       endif;
650fA     endif;
650fA     //if w1uci = ' ' and w1lbl# = 0;
650fA       //error = *on;
650fA       //errmsg = desc(17);
650fA       //exsr zm0105;
650fA     //endif;
650fA   else;
650fA     *in73 = *on;
650fA   endif;
650fA /end-free
416bAC                   if        w1item <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $litem = w1item
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
416bAC                   goto      endck1
     C                   endif
CTWaAC                   if        client = citywho
CTWaAC     dckey         chain     piritem                            79
CTWaAC                   if        not *in79
CTWaAC                   if        ITACTV= 'DC'
CTWaAC                   move      *on           error
CTWaAC                   eval      *in23 = *on
CTWaAC                   eval      *in03 = *on
CTWaAC                   eval      errmsg = *blanks
CTWaAC                   eval      errmsg = desc(14)
CTWaAC                   exsr      zm1001
CTWaAC                   goto      endck1
CTWaAC                   endif
CTWaAC                   endif
CTWaAC                   endif
DRYb *  Verify w1item included on w1ord
DRYb *    Use CORD to get ORD to check ORDD file with w1item
DRYe *        was ordh5 now ordh14 to grab newest date
780aA*    Revised to use vfyItemOnOrder flag, set above

780aDC**                 if        client = dairyl
780aMC                   if        vfyItemOnOrder
DRYbAc                   eval      wiord = 0
DRYdMC     oh1key        setll     ordh14
DRYeAC                   eval      x = 0
DRYeAC                   eval      totqt1 = 0
DRYeAC                   eval      totqt2 = 0
780aAC                   eval      totqt3 = 0
DRYe *    Clear ARRAY to load ALL CORD hits when returning by item
DRYeAC                   clear                   ORDnum
DRYeAC                   clear                   ORDqt1
DRYeAC                   clear                   ORDqt2
780aAC                   clear                   ORDqt3
DRYbA**                  eval      hlddt = 0
DRYbA**    oh1key        setll     ordh5
DRYbAC                   dow       forevr = forevr
DRYdMC     oh1key        reade     ordh14                                 74
780aAC                   if        *in74
780aAC                   leave
780aAC                   endif
780aDc**                 if        not *in74
DRYbA**                  if        hlddt < ohsdte
DRYbA**                  eval      hlddt = ohsdte
DRYbAc                   eval      wiord = ohord
DRYcA*   Verify item is on order, yes then hold that ohord
DRYcA*   If not, look for next ohord with same cust#(cord)
DRYcA*     Will same item ever be on both orders returning full qty???
DRYcA*     keep looking at this IF
DRYcAC     orddkey       setll     ordd3
780aA*    Technically, an order can conatin the item multiple times
780aAC                   dow       forevr = forevr
DRYcAC     orddkey       reade     ordd3                                  79
780aAC                   if        *in79
780aAC                   leave
780aAC                   endif
780aDC**                 if        not *in79
DRYeAC*                            and (od3_odqpk1 > 0
DRYeAC*                            or od3_odqpk2 > 0)
     *            then build array; keep going to read ALL records
DRYeAC                   eval      x = x + 1
DRYeAC                   eval      totqt1 = od3_odqpk1
DRYeAC                   eval      totqt2 = od3_odqpk2
780aAC                   eval      totqt3 = od3_odqpk3
DRYeAC                   z-add     od3_odord     ORDnum(x)
DRYeAC                   z-add     od3_odqpk1    ORDqt1(x)
DRYeAC                   z-add     od3_odqpk2    ORDqt2(x)
780aAC                   z-add     od3_odqpk3    ORDqt3(x)

780aA     // For Host Lots, get label# for order detail line
780aA     // If more than one, we will grab the last one.
780aA
780aA     if usingHostLots;
780aA       if od3_odqpk1>0 or od3_odqpk2>0 or od3_odqpk3>0;
780aA         setll (od3_odwhse: od3_odord: od3_oditem: od3_odseq) label93;
780aA         dow forevr = forevr;
780aA           reade (od3_odwhse: od3_odord: od3_oditem: od3_odseq) label93;
780aA           if %eof(label93);
780aA             leave;
780aA           endif;
780aA           if lb93_lbtype<>'O' and lb93_lbtype<>'B';
780aA             iter;
780aA           endif;
780aA           // We need a lbl# with a picked qty
780aA           if lb93_lbqpck > 0;
780aA             wolbl# = lb93_lblbl#;
780aA             w1lbl# = lb93_lblbl#;
780aA             w1lbl#b = %char(lb93_lblbl#);
780aA             leave;
780aA           endif;
780aA         enddo;
780aA       endif;
780aA     endif;

780aDc**                 endif
780aAC                   enddo
DRYcA*
780aDc**                 else
780aDC**                 leave
780aDc**                 endif
DRYbAc                   enddo
DRYeA*   If I have qty>0, look if orrtn records exist
DRYeA*   and compare qty left vs qty being returned.
DRYeA*   (maybe not here)
DRYeA *           **     if        totqt1 > 0
DRYeA *           **               or totqt2 > 0
DRYeA *           **     exsr      chkorrtn
DRYeA *           **     endif
DRYbA*   Verify item is on order(s) in array exist
DRYeAC                   if        totqt1 = 0
DRYeAC                             and totqt2 = 0
780aAC                             and totqt3 = 0
DRYbAC                   move      *on           error
DRYbAC                   eval      *in23 = *on
DRYbAC                   eval      *in03 = *on
DRYbAC                   eval      errmsg = *blanks
DRYbAC                   eval      errmsg = desc(23)
DRYbAC                   exsr      zm1001
DRYbAC                   goto      endck1
DRYbAC                   endif
DRYbAC                   endif
DRYb *                       end if Chef's dairyland
416bAC                   endif
     *
     *  Verify printer device.
     *
     C                   movel     w1dev         work1a
     C                   if        work1a = '*'  and
     C                             w1dev <> '*DEFAULT'  and
     C                             w1dev <> '*SYSVAL'  and
     C                             w1dev <> '*JOB'  or
     C                             w1dev = *blanks
     C                   move      *on           error
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(3)
     C                   exsr      zm1001
     C                   endif
     *
     *  Verify default form type
     *
     C                   movel     w1form        work1a
     C                   if        work1a = '*'  and
     C                             w1form <> '*DEFAULT'  and
     C                             w1form <> '*STD'  or
     C                             w1form = *blanks
     C                   move      *on           error
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(4)
     C                   exsr      zm1001
     C                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   move      *off          error
650cAc                   exsr      zzrcvrtncheck
640dAC                   eval      wofifo = 0
640dAC                   eval      woindt = 0
416mAC                   eval      wscitm = *blanks
     *
     *  Verify normal quantity.
     *
     C                   if        w1qt01 < 0
     C                   move      *on           error
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(2)       erfld
     C                   exsr      zm0109
     C                   endif
     *
     *  Verify breakdown 1 quantity.
     *
     C                   if        w1qt02 < 0
     C                   move      *on           error
     C                   eval      *in31 = *on
     C                   eval      *in11 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(2)       erfld
     C                   exsr      zm0109
     C                   endif
     *
     *  Verify breakdown 2 quantity.
     *
     C                   if        w1qt03 < 0
     C                   move      *on           error
     C                   eval      *in30 = *on
     C                   eval      *in10 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(2)       erfld
     C                   exsr      zm0109
     C                   endif
416b *
416b *  Quantity must be entered.
416b *
416b C                   if        w1qt01 = 0  and
416b C                             w1qt02 = 0  and
416b C                             w1qt03 = 0
416b C                   move      *on           error
416b C                   eval      *in24 = *on
416b C                   eval      *in04 = *on
416b C                   eval      errmsg = *blanks
416b C                   movel     desc(2)       erfld
416b C                   exsr      zm0110
416b C                   endif
     *
     *   Verify catchweight.
     *
213 AC                   if        not *in95  and
213 AC                             w1cwtr = 0
WST2AC                             and client <> westside
213 AC                   move      *on           error
213 AC                   eval      *in33 = *on
213 AC                   eval      errmsg = *blanks
213 AC                   eval      errmsg = desc(5)
213 AC                   exsr      zm0110
213 AC                   endif
     *
     *
     *  Verify return code.
     *
     C                   eval      woinvf = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lcode = w1code
     C                   call      'RN900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   move      *on           error
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
416d C                   else
416dAC     w1code        chain     rtncode                            79
416dAC                   if        not *in79
416dAC                   move      rninvf        woinvf
CSPaA*
CSPaAC                   if        client = CoastalSunbelt
CSPaAC                             and %subst(rndesc:26:5) <> *blanks
CSPaAC                   eval      w2dcde = %subst(rndesc:26:5)
CSPaAC                   endif
CSPaA*
     C                   endif
     C                   endif
     C                   endif
416b *
416b *  Verify disposition code.
416b *
416b C                   eval      $lcmd = '*VERIFY '
416b C                   eval      $ldcde = w2dcde
416b C                   call      'RD900'
416b C                   parm                    $lparm
416b C                   if        $lrtn = '*ERROR  '
416b C                   move      *on           error
416b C                   eval      *in27 = *on
416b C                   eval      *in07 = *on
416b C                   movel     $lerm         errmsg
416b C                   exsr      zm0105
416b C                   else
416b C                   if        $lrtn = '*PGMQ   '
416b C                   move      *on           error
416b C                   eval      *in27 = *on
416b C                   eval      *in07 = *on
416b C                   eval      #msgk = $lmsg
416b C                   exsr      zmqmsg
416b C                   endif
416b C                   endif
     *
416bA*  Verify Use label for putaway Y/N.
     *
650fA * directed returns and license tracking don't replace the *DP
650fA * license - Using label for putaway is not allowed.
650fDC*                  if        w2ulbl <> 'Y'  and
650fDC*                            w2ulbl <> 'N'
650fMC                   if        w2ulbl =  'Y'
416bAC                   move      *on           error
416bAC                   eval      *in28 = *on
416bAC                   eval      *in08 = *on
416bAC                   eval      errmsg = *blanks
416bAC                   eval      errmsg = desc(7)
416bAC                   exsr      zm1001
416bAC                   endif
     *
416hA*  Verify Use label for putaway Y/N.
     *
416hAC                   if        w2ulbl = 'Y'  and
416hAC                             wolbl# = 0
416hAC                   move      *on           error
416hAC                   eval      *in28 = *on
416hAC                   eval      *in08 = *on
416hAC                   eval      errmsg = *blanks
416bAC                   eval      errmsg = desc(6)
416hAC                   exsr      zm0203
416hAC                   endif
     *
     *
     *  Verify transaction number.
     *
     C                   if        w1trn# <> 0
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $ltrn# = w1trn#
     C                   call      'PT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in34 = *on
     C                   eval      *in14 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
416b *  The code to verify item was moved to screen3.
     *  Verify item number.
416bD*
416bD**         W1CITM    IFNE *BLANKS
416bD*R                   MOVE '*VERIFY '$LCMD
416bD*R                   Z-ADDW1WHSE    $LWHSE
416bD*R                   MOVE W1CITM    $LITEM
416bD*R                   CALL 'IT900'
416bD*R                   PARM           $LPARM
416bD*R         $LRTN     IFEQ '*PGMQ   '
416bD*R                   MOVE *ON       ERROR
416bD*R                   MOVE *ON       *IN35
416bD*R                   MOVE *ON       *IN15
416bD*R                   MOVE $LMSG     #MSGK
416bD*R                   EXSR ZMQMSG
416bD*R                   ENDIF
416bD*R                   ENDIF
     *
416m *
416mAC                   select
416m *  UPC entered
416mAC                   when      w2upc <> *blanks
416mAC                   if        w2citm = *blanks  and
416mAC                             w2vmfg = *blanks
416m *
416mAC                   eval      $cbcmd = '*UPC    '
416mAC                   movel     w2upc         $cbbar
416mAC                   call      'CVTBAR'
416mAC                   parm                    $cbcmd
416mAC                   parm                    $cbbar
416mAC                   parm                    $cbcod
416mAC                   parm                    $cbdec
416mAC                   parm                    $cbdsc
416mAC                   parm                    $cbpos
416mAC                   parm                    $cbtyp
416mAC                   parm                    $cbv1
416mAC                   parm                    $cbv2
416mAC                   parm                    $cbrtn
416mAC                   parm                    $cberm
650fAC                   parm                    $cbven           10 0
650fAC                   parm                    $cvtdata
650fAC                   parm                    $cvtdata2
416m *
416mAC                   if        $cbrtn = '*OK'
416mAC                   eval      w2upc = $cbv2
416mAC                   endif
416m *
416m *   Right adjust UPC code for file.
416m *
416mAC                   eval      $cstr = *blanks
416mAC                   movel     w2upc         $cstr
416mAC                   call      'ADJUST'
416mAC                   parm      '*RIGHT  '    $ccmd
416mAC                   parm                    $cstr
510aDC**                 eval      kyupc = $cstr
510aMC                   move      $cstr         kyupc
417a *   Check if mulitple items exist for one UPC code.
417a *    UPCCTR = 0, error, upc code not found.
417a *    UPCCTR = 1, only one upc found, process for item.
417a *    UPCCTR > 1, multiple upc found, need to select item.
417a C                   eval      upcctr = 0
417a C     upckey        setll     upc
417a C                   dow       forevr = forevr
417a C     upckey        reade     upc                                    79
     *
417a C                   if        *in79
417a C                   leave
417a C                   else
417a C                   add       1             upcctr
417a C                   endif
     *
417a C                   enddo
     *
417aD*R         UPCKEY    CHAINUPC                  79
417aD*R         *IN79     IFEQ *ON
417aAC                   if        upcctr = 0
416mAC                   move      *on           error
416mAC                   eval      *in25 = *on
416mAC                   eval      *in05 = *on
416mAC                   eval      errmsg = *blanks
416mAC                   exsr      zm29
416mAC                   goto      endck2
416mAC                   endif
     *
     *   Multiple items exist for UPC
417a C                   if        upcctr > 1
417a C                   eval      $lcmd = '*VERIFY '
417a C                   eval      $lwhse = w1whse
417a C                   move      kyupc         $lupc
417a C                   call      'UC920'
417a C                   parm                    $lparm
417a C                   if        $lrtn = '*ERROR  '
417a C                   move      *on           error
417a C                   eval      *in24 = *on
417a C                   eval      *in04 = *on
417a C                   movel     $lerm         errmsg
417a C                   exsr      zm0105
417a C                   else
417a C                   if        $lrtn = '*PGMQ   '
417a C                   move      *on           error
417a C                   eval      *in24 = *on
417a C                   eval      *in04 = *on
417a C                   eval      #msgk = $lmsg
417a C                   exsr      zmqmsg
417a C                   endif
417a C                   endif
417a C                   eval      upitem = $litm1
     *
417a C                   endif
416m *
416mAC                   eval      wscitm = upitem
416mAC                   else
416mA*  Error, more than one value entered.
416mAC                   move      *on           error
416mAC                   eval      *in23 = *on
416mAC                   eval      *in25 = *on
416mAC                   eval      *in26 = *on
416mAC                   eval      *in05 = *on
416mAC                   eval      errmsg = *blanks
416mAC                   exsr      zm0204
416mAC                   goto      endck2
416mAC                   endif
416m *
416mAC                   endsl
416m *
416m *  Verify Mfg code/vendor item.
416m *
416mAC                   if        w2vmfg <> *blanks
416mAC                   if        w2upc = *blanks  and
416mAC                             w2citm = *blanks
416mAC                   move      w2vmfg        kyvmfg
416mAC     mfgkey        chain     piritem4                           79
416mAC                   if        *in79
416mAC                   move      *on           error
416mAC                   eval      *in26 = *on
416mAC                   eval      *in06 = *on
416mAC                   eval      errmsg = *blanks
416mAC                   eval      errmsg = desc(9)
416mAC                   exsr      zm1001
416mAC                   goto      endck2
416mAC                   else
416mAC                   move      ititem        wscitm
416mAC                   endif
416mAC                   else
416mA*  Error, more than one value entered.
416mAC                   move      *on           error
416mAC                   eval      *in23 = *on
416mAC                   eval      *in25 = *on
416mAC                   eval      *in26 = *on
416mAC                   eval      *in05 = *on
416mAC                   eval      errmsg = *blanks
416mAC                   exsr      zm0204
416mAC                   goto      endck2
416mAC                   endif
416mAC                   endif
     *
416mA*  Error, more than one value entered.
416mAC                   if        w2citm <> *blanks
416mAC                   if        w2upc <> *blanks  or
416mAC                             w2vmfg <> *blanks
416mAC                   move      *on           error
416mAC                   eval      *in23 = *on
416mAC                   eval      *in25 = *on
416mAC                   eval      *in26 = *on
416mAC                   eval      *in03 = *on
416mAC                   eval      errmsg = *blanks
416mAC                   exsr      zm0204
416mAC                   goto      endck2
416mAC                   endif
416mAC                   endif
     *
416m *  Get item # from other field entered.
   m *
416mAC                   if        w2citm = *blanks  and
416mAC                             wscitm <> *blanks
416mAC                   move      wscitm        w2citm
416mAC                   endif
416mA*  Mispick item must be different than ordered item.
     *
416mAC                   if        w2citm = w1item
416mAC                   move      *on           error
416mAC                   eval      *in23 = *on
416mAC                   eval      *in03 = *on
416mAC                   eval      errmsg = *blanks
416mAC                   eval      errmsg = desc(11)
416mAC                   exsr      zm1202
416mAC                   endif
     *
     *
416m *  Verify item number.
     *
416mAC                   if        w2citm <> *blanks
416m C                   eval      $lcmd = '*VERIFY '
416m C                   eval      $lwhse = w1whse
416m C                   eval      $litem = w2citm
416m C                   call      'IT900'
416m C                   parm                    $lparm
416m C                   if        $lrtn = '*PGMQ   '
416m C                   move      *on           error
416m C                   eval      *in23 = *on
416m C                   eval      *in03 = *on
416m C                   eval      #msgk = $lmsg
416m C                   exsr      zmqmsg
416mAC                   goto      endck2
416m C                   endif
416mAC                   endif
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   move      *off          error
650cAc                   exsr      zzrcvrtncheck
     *
416bA*  Verify Impact inventory Y/N.
     *
416bAC                   if        w3iinv <> 'Y'  and
416bAC                             w3iinv <> 'N'
416bAC                   move      *on           error
416bAC                   eval      *in28 = *on
416bAC                   eval      *in08 = *on
416bAC                   eval      errmsg = *blanks
416bAC                   eval      errmsg = desc(8)
416bAC                   exsr      zm1001
416bAC                   endif
     *
     *
416m *     Verify expired date (optional)
     *
416mAC                   if        not *in96  and
416mAC                             w3expd = 0
416mAC                   move      *on           error
416mAC                   eval      *in25 = *on
416mAC                   eval      *in05 = *on
416mAC                   eval      errmsg = *blanks
416mAC                   exsr      zm1008
416mAC                   else
416m C                   if        w3expd <> 0
416m C                   eval      $cvcmd = '*MDYEDT '
416m C                   move      w3expd        $cvd6i
416m C                   call      @cvtdt
416m C                   parm                    $cvtdt
416m C                   if        $cvrtn = '*PGMQ   '
416m C                   move      *on           error
416m C                   eval      *in25 = *on
416m C                   eval      *in05 = *on
416m C                   eval      #msgk = $cvmsg
416m C                   exsr      zmqmsg
416m C                   else
416m C                   eval      w3expd = $cvd6o
416mAC                   eval      $cvcmd = '*MDYCMD '
416mAC                   call      @cvtdt
416mAC                   parm                    $cvtdt
416mAC                   move      $cvd8o        expd              8 0
416mAC                   if        expd <= today
416mAC                   move      *on           error
416mAC                   eval      *in25 = *on
416mAC                   eval      *in05 = *on
416mAC                   eval      errmsg = *blanks
416mAC                   exsr      zm1009
416m C                   endif
416m C                   endif
416m C                   endif
416m C                   endif
416mA*
416mA*  Verify manufacturing date.
416mA*
416mAC                   if        not *in87
416mAC                   if        immflg = 'Y'  and
416mAC                             w3mfdt = 0
416mAC                   move      *on           error
416mAC                   eval      *in32 = *on
416mAC                   eval      *in12 = *on
416mAC                   eval      errmsg = *blanks
416mAC                   exsr      zm1008
416mAC                   else
416mAC                   if        w3mfdt <> 0
416mAC                   eval      $cvcmd = '*MDYEDT '
416mAC                   move      w3mfdt        $cvd6i
416mAC                   call      @cvtdt
416mAC                   parm                    $cvtdt
416mAC                   if        $cvrtn = '*PGMQ   '
416mAC                   move      *on           error
416mAC                   eval      *in32 = *on
416mAC                   eval      *in12 = *on
416mAC                   eval      #msgk = $cvmsg
416mA**                   EXSR ZMQMSG
416mA**                   GOTO ENDERR
416mAC                   else
416mAC                   eval      w3mfdt = $cvd6o
416mAC                   eval      $cvcmd = '*MDYCMD '
416mAC                   call      @cvtdt
416mAC                   parm                    $cvtdt
416mAC                   move      $cvd8o        mfgd
416mAC                   if        mfgd > today
416mAC                   move      *on           error
416mAC                   eval      *in32 = *on
416mAC                   eval      *in12 = *on
416mAC                   eval      errmsg = *blanks
416mAC                   exsr      zm1010
416mAC                   endif
416mAC                   endif
416mAC                   endif
416mAC                   endif
416mAC                   endif
650iA * pti check
650iA /free
650iA       // calculate the PTI.
650iA       if $bclot <> ' ' and $bcgtin <> ' ';
650iA         if w3pti = 0;
650iA           error = *on;
650iA           *in41 = *on;
650iA           errmsg = desc(19);
650iA           exsr zm0110;
650iA         endif;
650iA       endif;
650iA /end-free
416m *
416mAC     error         cabeq     *on           enderr
650iA /free
650iA   // calculate the PTI.
650iA   if $bclot <> ' ' and $bcgtin <> ' ';
650iA     pplot  = %subst($bclot: 1 : 20);
650iA     calcpti ($bcgtin: pplot: $lbcprodD: pppti);
650iA     if svpti <> w3pti;
650iA       ptichk = *off;
650ia     endif;
650ia     if ptichk = '2' and
650ia        ovrrid = *on;
650ia        ptiovr = *on;
650ia        ptichk = *on;
650ia     endif;
650ia     if ptichk <> '1';
650ia       ptichk = *on;
650iA       if w3pti <> pppti
650iA         and ptiovr <> '1';
650iA         // recalc pti without production date
650iA         calcpti ($bcgtin: pplot: ptinodate: pppti);
650iA         if w3pti <> pppti;
650iA           error = *on;
650iA           *in37 = *on;
650iA           *in17 = *on;
650ia           ptichk = '2';
650iA           warn = *on;
650iA           exsr zm3203;
650iA         endif;
650iA       endif;
650iA     endif;
650iA   endif;
650iA /end-free
650iAc     error         cabeq     *on           enderr
416mA*
416mAC                   if        immflg = 'Y'
416mA*  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
416mA*
416mAC                   move      w3mfdt        g$date
416mAC                   eval      dtfrmt = 2
416mAC                   exsr      gtoj$
416mAC                   eval      mfdtj = g$jd
416mA*
416mAC                   eval      j$jd = mfdtj + immday
416mAC                   eval      j$jd = j$jd - imuday
416mAC                   exsr      jtog$
416mAC                   move      j$date        $cvd6o
416mAC                   eval      w3expd = $cvd6o
416m *
416mAC                   eval      $cvcmd = '*MDYCMD '
416mAC                   move      w3expd        $cvd6i
416mAC                   call      @cvtdt
416mAC                   parm                    $cvtdt
416mAC                   move      $cvd8o        expd
416mA*
417dA*  Verify Expiration date is not already expired.                 days)
417d C                   if        expd <= today
417d C                   eval      expd = 0
417d C                   move      *on           error
417d C                   eval      *in32 = *on
417d C                   eval      *in12 = *on
417d C                   eval      errmsg = *blanks
417d C                   exsr      zm4002
417d C                   endif
416mAC                   endif
650iAc     enderr        tag
650iAc                   eval      svpti = w3pti
     *
     C     endck3        endsr
     *----------------------------------------------------------------
     *
416i *  ZZCHK4   Screen 4 error checking.
     *
416i C     zzchk4        begsr
416i C                   move      *off          error
650cAc                   exsr      zzrcvrtncheck
416i *
416i *  Verify return code.
416i *
416i C                   eval      $lcmd = '*VERIFY '
416i C                   eval      $lcode = w4code
416i C                   call      'RN900'
416i C                   parm                    $lparm
416i C                   if        $lrtn = '*ERROR  '
416i C                   move      *on           error
416i C                   eval      *in26 = *on
416i C                   eval      *in06 = *on
416i C                   movel     $lerm         errmsg
416i C                   exsr      zm0105
416i C                   else
416i C                   if        $lrtn = '*PGMQ   '
416i C                   move      *on           error
416i C                   eval      *in26 = *on
416i C                   eval      *in06 = *on
416i C                   eval      #msgk = $lmsg
416i C                   exsr      zmqmsg
416i C                   else
416i C     w4code        chain     rtncode                            79
416i C                   if        not *in79
416i C                   move      rninvf        woinvf
CSPaA*
CSPaAC                   if        client = CoastalSunbelt
CSPaAC                             and %subst(rndesc:26:5) <> *blanks
CSPaAC                   eval      w4dcde = %subst(rndesc:26:5)
CSPaAC                   endif
CSPaA*
416i C                   endif
416i C                   endif
416i C                   endif
416i *
416i *  Verify disposition code.
416i *
416i C                   eval      $lcmd = '*VERIFY '
416i C                   eval      $ldcde = w4dcde
416i C                   call      'RD900'
416i C                   parm                    $lparm
416i C                   if        $lrtn = '*ERROR  '
416i C                   move      *on           error
416i C                   eval      *in27 = *on
416i C                   eval      *in07 = *on
416i C                   movel     $lerm         errmsg
416i C                   exsr      zm0105
416i C                   else
416i C                   if        $lrtn = '*PGMQ   '
416i C                   move      *on           error
416i C                   eval      *in27 = *on
416i C                   eval      *in07 = *on
416i C                   eval      #msgk = $lmsg
416i C                   exsr      zmqmsg
416i C                   endif
416i C                   endif
500a *
500a *  Disposition code must impact inventory.
500a *
500a C                   if        $pqck = 'A'
500a C     w4dcde        chain     rdscode                            79
500a C                   if        not *in79  and
500a C                             rdiinv <> 'Y'
500a C                   move      *on           error
500a C                   eval      *in27 = *on
500a C                   eval      *in07 = *on
500a C                   eval      errmsg = *blanks
500a C                   exsr      zm1203
500a C                   endif
500a C                   endif
     *
     *
416i C     endck4        endsr
500a *----------------------------------------------------------------
500a *
500a *  ZZCHK6   Screen 6 error checking.
500a *
500a C     zzchk6        begsr
500a C                   move      *off          error
650cAc                   exsr      zzrcvrtncheck
500a C                   eval      wsitem = *blanks
500a *
500a *  Verify warehouse code.
500a *
500a C                   eval      $lcmd = '*VERIFY '
500a C                   eval      $lwhse = w6whse
500a C                   call      'WH900'
500a C                   parm                    $lparm
500a C                   if        $lrtn = '*PGMQ   '
500a C                   move      *on           error
500a C                   eval      *in21 = *on
500a C                   eval      *in01 = *on
500a C                   eval      #msgk = $lmsg
500a C                   exsr      zmqmsg
500a C                   goto      endck6
500a C                   else
500a C                   eval      $fwhse = w6whse
500a C                   movel     $lerm         $fdesc
500a C                   call      'FRMTWH'
500a C                   parm                    $fwhse
500a C                   parm                    $fdesc
500a C                   parm                    wowhse
500a C                   endif
500a *
500a *   Get Return Options.
500a *
500a C                   move      '0'           flbflg
500a C                   eval      worexq = *blanks
500a C                   move      '*RETURNS'    ocode
500a *
500a C     opkey         chain     options                            79
500a C                   if        not *in79
500a C                   eval      oprdta = opdata
500a C                   if        oprflb = 'Y'
500a C                   move      '1'           flbflg
500a C                   endif
750aA /free
750aA   if oppltl = 'Y';
750aA     *in46 = *on;
750aA   else;
750aA     *in46 = *off;
750aA   endif;
750aA /end-free
500a C                   move      oprexq        worexq
500a C                   endif
500a *
500a *  Verify customer order # is for customer # entered.
500aAC     oh5key        chain     ordh5                              78
500a *  Customer order # is for customer # entered.
500a C                   if        not *in78  and
500a C                             ohcust <> w6cust
500a C                   move      *on           error
500a C                   eval      *in25 = *on
500a C                   eval      *in05 = *on
500a C                   eval      errmsg = *blanks
500a C                   eval      errmsg = desc(12)
500a C                   exsr      zm1001
500a C                   goto      endck6
500a C                   endif
500a *  Invalid customer order # entered.
500aAC                   if        *in78
500a C                   move      *on           error
500a C                   eval      *in27 = *on
500a C                   eval      *in07 = *on
500a C                   eval      errmsg = *blanks
500a C                   eval      errmsg = desc(1)
500a C                   exsr      zm1001
500a C                   goto      endck6
500a C                   endif
500a *
500aAC                   eval      wslord = ohord
415bA******               Z-ADDOHCORD    W1ORD
415bA******               Z-ADDOHCORD    WOORD
415aA******               MOVE LBITEM    WSITEM
46iaA*******              Z-ADDLBORD     WSLORD
415aA*******              Z-ADDLBTRN#    WOTRN#
500a *
500a *
500a *  Verify printer device.
500a *
500a C                   movel     w6dev         work1a
500a C                   if        work1a = '*'  and
500a C                             w6dev <> '*DEFAULT'  and
500a C                             w6dev <> '*SYSVAL'  and
500a C                             w6dev <> '*JOB'  or
500a C                             w6dev = *blanks
500a C                   move      *on           error
500a C                   eval      *in28 = *on
500a C                   eval      *in08 = *on
500a C                   eval      errmsg = *blanks
500a C                   eval      errmsg = desc(3)
500a C                   exsr      zm1001
500a C                   endif
500a *
500a *  Verify default form type
500a *
500a C                   movel     w6form        work1a
500a C                   if        work1a = '*'  and
500a C                             w6form <> '*DEFAULT'  and
500a C                             w6form <> '*STD'  or
500a C                             w6form = *blanks
500a C                   move      *on           error
500a C                   eval      *in29 = *on
500a C                   eval      *in09 = *on
500a C                   eval      errmsg = *blanks
500a C                   eval      errmsg = desc(4)
500a C                   exsr      zm1001
500a C                   endif
500a *
500a C     endck6        endsr
650fA*----------------------------------------------------------------
650fA*
650fA*  ZZCHK7   Screen 7 error checking.
650fA*
650fA /free
650fA   begsr zzchk7;
650fA     exsr zzchk2;
650fA     if error;
650fA       leavesr;
650fA     endif;
650fA     if moretoscan <> *on;
650fA       exsr zzfil3;
650fA     endif;
650fA     // if use label for putaway load up uci temporary license
650fA    select;
650fA      when rdiinv <>'Y' and $ifsltmth = '2'
650fA        or rdiinv <>'Y' and $ifrcvmth = '2';
650fA        eval w7lcns = '*NO Stock';
650fA        eval templcns = 'NS' + #jobn;
650fA        eval *in80 = *on;
650fA    other;
650fA      eval templcns = ' ';
650fA      eval *in80 = *off;
650fA    endsl;
650fA    if $ifrcvmth = '2' and rdiinv = 'Y' or
650fA       $ifsltmth = '2' and rdiinv = 'Y';
650fA       // license must be entered
650fA       if w7lcns = ' '  or
650fA          w7lcns = '*NO Stock';
650fA         *in43 = *on;
650fA         error = *on;
650fA         erfld = desc(16);
650fA         exsr zm0203;
650fA         if w7lcns = '*NO Stock';
650fA           eval w7lcns = ' ';
650fA         endif;
650fA         eval *in73 = *off;
650fA         leavesr;
650fA       endif;
650fA     endif;
650fA     // Make sure license doesn't already exist if first scan
650fA     if *in80 = *off and w7lcns <> ' ';
650fA       exsr zzchklcns;
650fA     endif;
650fA   endsr;
650fA /end-free
650fA*----------------------------------------------------------------
650fA*
650fA*  ZZCHK8   Screen 8 error checking.
650fA*
650fA /free
650fA   begsr zzchk8;
650fA     if w1uci <> *blanks;
650fA       // check to make sure UCI barcode does not already exist
650fA       exsr clr$uciinfo;
650fA
650fA       $uiWhse = w1whse;
650fA       $uiuci  = w1uci;
650fA       $uiitem = w1item;
650fA
650fA       $dricommand = '*UCIINFO';
650fA       $drisubcmd  = '%CHKACTV';
650fA       $drisys2upd = 'D';
650fA       chk4err = *on;
650fA       zmflag  = *off;
650fA       exsr zzzdricop;
650fA       // if return is *EXIST seton error
650fA       if $drireturn = '*EXIST';
650fA         error = *on;
650fA         errmsg = desc(17);
650fA         eval nxtscr = '08 ';
650fA         exsr zm02;
650fA         leavesr;
650fA       endif;
650fA       if w1uci = ' ' and w1lbl# = 0;
650fA         error = *on;
650fA         errmsg = desc(17);
650fA         exsr zm0105;
650fA       endif;
650fA       exsr zzconvertuci;
650fA     if not $bcgtinsent;
650fA       error = *on;
650fA       exsr zm11202;
650fA       leavesr;
650fA     endif;
650fA     exsr zzupcck;
650fA     // diff item error
650fA     if w1item <> upitem;
650fA       errmsg = desc(18);
650fA       exsr zm0105;
650fA       error = *on;
650fA       leavesr;
650fA     endif;
650fA /end-free
650fAc
650fAc                   if        moretoscan <> *on
650fAc                   exsr      scr07i
650fAc                   else
650fAc                   exsr      zzfil3
650fAc                   endif
650fA * diff lot warning
650fA*  Different lot - entered manually
650fA /free
650fA   if $bclot <> savelotc and moretoscan = *on and difflot = *off;
650fA     error = *on;
650fA     warn = *on;
650fA     lotwarn = *on;
650fA     exsr zm3701;
650fA   endif;
650fA /end-free
650fAc                   else
650fAc                   eval      error = *on
650fAc                   endif
650fAC     error         cabeq     *on           endck8
650fA * diff exp date warning
650fAC     endck8        endsr
650fA*----------------------------------------------------------------
650fA*
650fA*  ZZCHK9   Screen 9 review screen error checking.
650fA*
650fAC     zzchk9        begsr
650fAC                   move      *off          error
650fA*
650fAC     endck9        endsr
740bA*----------------------------------------------------------------
740bA*
740bA*  ZZCMD0   User defined command keys for screen 0.
740bA*
740bAC     zzcmd0        begsr
740bA*
740bA*  Command keys to check BEFORE verification and update.
740bA*
740bAC                   if        cmdchk = '*BEFORE '
740bA*
740bA*  Test for F4 - Lookup
740bA*
740bAC                   if        *inkd
740bAC                   move      *on           cmdtkn
740bAC                   z-add     0             row#
740bAC                   eval      row = rowin
740bAC                   z-add     0             col#
740bAC                   eval      col = colin
740bAC                   select
740bA*
740bA*     Warehouse.
740bA*
740bAC                   when      row# = 5
740bAC                   eval      *in01 = *on
740bAC                   eval      $lcmd = '*LOOKUP '
740bAC                   eval      $lwhse = w1whse
740bAC                   call      'WH900'
740bAC                   parm                    $lparm
740bAC                   if        $lrtn = '*SELECT '
740bAC                   eval      w1whse = $lwhse
740bAC                   endif
740bA*
740bAC                   other
740bA*
740bA*     Cursor not on a valid lookup field.
740bA*
740bAC                   move      *on           error
740bAC                   exsr      zm9905
740bAC                   endsl
740bAC                   goto      endcm0
740bAC                   endif
740bAC                   endif
740bA*
740bA*  Command keys to check AFTER verification and update.
740bA*
740bAC                   if        cmdchk = '*AFTER  '
740bA*
740bAC                   endif
740bAC     endcm0        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   move      *on           cmdtkn
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     *     Warehouse.
     *
416aD**         ROW#      WHEQ 6
416aMC                   when      row# = 5
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whse = $lwhse
     C                   endif
CSPbA*
CSPbA*     Customer Order Lookup
CSPbA*
CSPbAC                   when      row# = 8 and client = CoastalSunbelt
CSPbAC                   eval      $lcmd = '        '
CSPbAC                   eval      $lwhse = w1whse
CSPbAC                   eval      $lstat = 'C'
CSPbAC                   eval      $lohudte = today
CSPbAC                   eval      $lohcord = 0
CSPbAC                   call      'RN330'
CSPbAC                   parm                    $lparm
CSPbAC                   if        $lrtn = '*SELECT '
CSPbAC                   eval      w1ord  = $lohcord
CSPbAC                   eval      w1item = $lcitem
CSPbAC                   endif
     *
     *     Item.
     *
416aD**         ROW#      WHEQ 8
416aMC                   when      row# = 14
     C                   eval      *in03 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lprg = #prog
     C                   eval      $lwhse = w1whse
     C                   eval      $litem = w1item
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1item = $litem
     C                   endif
     *
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   move      *on           error
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
     C                   endif
415aA*
415aA*  Test for F17 - View receiving log.
415aA*
415aAC                   select
415aAC                   when      *inkr  and
416dD**         W1ITEM    ANDGT*BLANKS
416dMC                             wsitem > *blanks
415aAC                   move      *on           cmdtkn
415 AC                   eval      $lwhse = w1whse
415aAC                   eval      $lrpo = '*RETURN '
415aAC                   eval      $lrseq = *zeros
415aAC                   move      wsitem        $lritm
415aAC                   call      'PO135'
415aAC                   parm                    $lparm
415aAC                   parm                    $lrtn
415aAC                   endsl
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
415aD*
415aD*  Test for F17 - View receiving log.
415aD*
415aD*R                   SELEC
415aD*R         *INKR     WHEQ *ON
415aD*R         W1ITEM    ANDGT*BLANKS
415aD*R                   MOVE *ON       CMDTKN
415 D*R                   Z-ADDW1WHSE    $LWHSE
415aD*R                   MOVEL'*RETURN '$LRPO     P
415aD*R                   MOVE *ZEROS    $LRSEQ
415aD*R                   MOVE W1ITEM    $LRITM
415aD*R                   CALL 'PO135'
415aD*R                   PARM           $LPARM
415aD*R                   PARM           $LRTN
415aD*R                   ENDSL
     *
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   move      *on           cmdtkn
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     *
     *     Return code.
     *
416b *R         ROW#      WHEQ 16
     C                   when      row# = 11
     C                   eval      *in06 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lprg = #prog
     C                   eval      $lcode = w1code
     C                   call      'RN900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1code = $lcode
     C                   endif
416b *
416b *     Disposition code.
416b *
416b C                   when      row# = 12
416b C                   eval      *in07 = *on
416b C                   eval      $lcmd = '*LOOKUP '
416b C                   eval      $lprg = #prog
416b C                   eval      $ldcde = w2dcde
416b C                   call      'RD900'
416b C                   parm                    $lparm
416b C                   if        $lrtn = '*SELECT '
416b C                   eval      w2dcde = $ldcde
416b C                   endif
     *
416b *     Lookup corresponding item moved to ZZCMD3
     *     Corresponding item number.
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   move      *on           error
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm2
     C                   endif
     *
416hA*  Test for F9 - Enable UOM Breakdown fields.
416h *
416hAC                   if        *inki
416hAC                   move      *on           cmdtkn
416hAC                   eval      *in93 = *off
416hAC                   eval      *in94 = *off
416hAC                   endif
416h *
413aA*
413aA*  Test for F17 - View receiving log.
413aA*
413aAC                   select
413aAC                   when      *inkr
413aAC                   eval      cmdtkn = *on
223 AC                   eval      $lwhse = w1whse
413aAC                   eval      $lrpo = '*RETURN '
413aAC                   eval      $lrseq = *zeros
413aAC                   eval      $lritm = w1item
413aAC                   call      'PO135'
413aAC                   parm                    $lparm
413aAC                   parm                    $lrtn
413aAC                   endsl
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   move      *on           cmdtkn
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
416b *
416b *     Corresponding item number.
416b *
416b C                   when      row# = 12
416b C                   eval      *in15 = *on
416b C                   eval      $lcmd = '*LOOKUP '
416b C                   eval      $lprg = #prog
416b C                   eval      $lwhse = w1whse
416B ***                  MOVE W1CITM    $LITEM
416B C                   eval      $litem = w2citm
416b C                   call      'IT900'
416b C                   parm                    $lparm
416b C                   if        $lrtn = '*SELECT '
416b C                   eval      w2citm = $litem
416b C                   endif
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   move      *on           error
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm3
     C                   endif
640dA*
640dA*      F11 - Manufacturer code decipher
640dA*
640dAc                   if        *inkk
640dAC                   eval      $lexpdat = 0
640dAC                   eval      $lmfrdat = 0
640dAc                   eval      $lrtn = ' '
640dA * f11 is only valid on date sensitive items
640dAc                   If        itflgd = 'Y' or immflg = 'Y'
640dAC                   eval      $lwhse = w1whse
640dAc                   eval      $lmfr#    = itven#
640dAc                   eval      $lmfritem = itvit#
640dAc                   eval      $ldakitem = ititem
640dAc                   eval      $lupc1    = kyupc
640dAc                   call      'MF200'                              66
640dAC                   parm                    $lparm
640dAC                   parm      0             $lexpdat          6 0
640dAC                   parm      0             $lmfrdat          6 0
640dAC                   parm                    $lupc1           20
640dAC                   parm      ' '           $ldecvalue       15
640fAc                   if        $lrtn <> *blanks and $lrtn <> 'OK'
640fAc                   eval      w3expd = 0
640fAc                   eval      w3mfdt = 0
640fAc                   endif
640dAc                   else
640dac                   exsr      zm13250
640dAc                   endif
640dAc                   exsr      zzmfrdates
640dAC                   eval      w3exPD = $lexpdat
640dAc                   if        immflg = 'Y'
640dAC                   eval      w3mfdt = $lmfrdat
640dAc                   endif
640dAc                   endif
     C                   endif
650iA*
650iA*      F20 - Accept Warning.
650iA*
650iAC                   if        *inku
650iAC                   eval      ovrrid = *on
650iAC                   else
650iAC                   eval      ovrrid = *off
650iAC                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm3        endsr
     *----------------------------------------------------------------
416i *
416i *  ZZCMD4   User defined command keys for screen 4.
416i *
416i C     zzcmd4        begsr
416i *
416i *  Command keys to check BEFORE verification and update.
416i *
416i C                   if        cmdchk = '*BEFORE '
416i *
416i *  Test for F4 - Lookup
416i *
416i C                   if        *inkd
416i C                   move      *on           cmdtkn
416i C                   z-add     0             row#
416i C                   eval      row = rowin
416i C                   z-add     0             col#
416i C                   eval      col = colin
416i C                   select
416i *
416i *
416i *     Return code.
416i *
416i C                   when      row# = 12
416i C                   eval      *in06 = *on
416i C                   eval      $lcmd = '*LOOKUP '
416i C                   eval      $lprg = #prog
416i C                   eval      $lcode = w1code
416i C                   call      'RN900'
416i C                   parm                    $lparm
416i C                   if        $lrtn = '*SELECT '
416i C                   eval      w4code = $lcode
CSPaA*
CSPaAC                   if        client = CoastalSunbelt
CSPaAC                             and %subst(rndesc:26:5) <> *blanks
CSPaAC                   eval      w4dcde = %subst(rndesc:26:5)
CSPaAC                   endif
CSPaA*
416i C                   endif
416i *
416i *     Disposition code.
416i *
416i C                   when      row# = 13
416i C                   eval      *in07 = *on
416i C                   eval      $lcmd = '*LOOKUP '
416i C                   eval      $lprg = #prog
416i C                   eval      $ldcde = w2dcde
416i C                   call      'RD900'
416i C                   parm                    $lparm
416i C                   if        $lrtn = '*SELECT '
416i C                   eval      w4dcde = $ldcde
416i C                   endif
416i *
416i *     Lookup corresponding item moved to ZZCMD3
416i *     Corresponding item number.
416i *
416i C                   other
416i *
416i *     Cursor not on a valid lookup field.
416i *
416i C                   move      *on           error
416i C                   exsr      zm9905
416i C                   endsl
416i C                   goto      endcm4
416i C                   endif
416i *
416i *
416i C                   endif
416i *
416i *  Command keys to check AFTER verification and update.
416i *
416i C                   if        cmdchk = '*AFTER  '
416i C                   endif
416i C     endcm4        endsr
     *----------------------------------------------------------------
500a *
500a *  ZZCMD6   User defined command keys for screen 6.
500a *
500a C     zzcmd6        begsr
500a *
500a *  Command keys to check BEFORE verification and update.
500a *
500a C                   if        cmdchk = '*BEFORE '
500a *
500a *  Test for F4 - Lookup
500a *
500a C                   if        *inkd
500a C                   move      *on           cmdtkn
500a C                   z-add     0             row#
500a C                   eval      row = rowin
500a C                   z-add     0             col#
500a C                   eval      col = colin
500a C                   select
500a *
500a *     Warehouse.
500a *
500a C                   when      row# = 5
500a C                   eval      *in01 = *on
500a C                   eval      $lcmd = '*LOOKUP '
500a C                   eval      $lwhse = w6whse
500a C                   call      'WH900'
500a C                   parm                    $lparm
500a C                   if        $lrtn = '*SELECT '
500a C                   eval      w6whse = $lwhse
500a C                   endif
500a *
500a C                   other
500a *
500a *     Cursor not on a valid lookup field.
500a *
500a C                   move      *on           error
500a C                   exsr      zm9905
500a C                   endsl
500a C                   goto      endcm6
500a C                   endif
500a C                   endif
500a *
500a *  Command keys to check AFTER verification and update.
500a *
500a C                   if        cmdchk = '*AFTER  '
500a *
500a C                   endif
500a C     endcm6        endsr
650fA*----------------------------------------------------------------
650fA*
650fA*  ZZCMD8   User defined command keys for screen 8.
650fA*
650fAC     zzcmd8        begsr
650fA*
650fA*  Command keys to check BEFORE verification and update.
650fA*
650fAC                   eval      cmdtkn = *off
650fA*
650fA*      F20 - Accept Warning.
650fA*
650fAC                   if        *inku
650fAC                             or *inkj
650fAc                   if        lotwarn = *on
650fAC                   eval      difflot = *on
650fAC                   eval      lotwarn = *off
650fAc                   endif
650fAC                   else
650fAC                   endif
650fA*
650fA*
650fA*      F22 - Complete License.
650fAC                   if        *inkw
650fAc                   if        saveqty > 0
650fAC                   eval      cmdtkn = *on
650fAc                   eval      nxtscr = '09 '
650fAc                   exsr      scr09i
650fAc                   endif
650fAC                   endif
650fA *
650fAC     endcm8        endsr
650fA*----------------------------------------------------------------
650fA*
650fA*  ZZCMD9   User defined command keys for screen 9.
650fA*
650fAC     zzcmd9        begsr
650fA*
650fA*  Command keys to check BEFORE verification and update.
650fA*
650fAC                   if        cmdchk = '*BEFORE '
650fAC                   endif
650fA*
650fA*
650fA*  Command keys to check AFTER verification and update.
650fA*
650fAC                   if        cmdchk = '*AFTER  '
650fAC                   endif
650fAC     endcm9        endsr
650fA*----------------------------------------------------------------
650fA*
650fA*  ZZCMDCNL User defined command keys for cancel window warning
650fA*
650fAC     zzcmdCnl      begsr
650fAC     endcmCnl      endsr
650fA*----------------------------------------------------------------
650fA*
650fA*  ZZCONVERTUCI Convert uci scanned
650fA*
650fAC     zzconvertuci  begsr
650fAC                   eval      $cbcmd = '*ALL    '
650fAC                   movel     w1uci         $cbbar
650fAC                   call      'CVTBAR'
650fAC                   parm                    $cbcmd            8
650fAC                   parm                    $cbbar          100
650fAC                   parm                    $cbcod            3 0
650fAC                   parm                    $cbdec            1 0
650fAC                   parm                    $cbdsc           30
650fAC                   parm                    $cbpos            3 0
650fAC                   parm                    $cbtyp            1 0
650fAC                   parm                    $cbv1            11 3
650fAC                   parm                    $cbv2            50
650fAC                   parm                    $cbrtn            8
650fAC                   parm                    $cberm           60
650fAC                   parm                    $cbven           10 0
650fAC                   parm                    $cvtdata
650fAC                   parm                    $cvtdata2
650fA*
650fAc                   eval      $barcode = $cvtdata
650fAc                   eval      $barcode2 = $cvtdata2
650fA * Load UPC
650fAc                   if        $bcGtinSent
650fAc                   eval      w1upc  = $bcGtin
650fAc                   eval      *in92 = *on
650fAc                   else
650fAc                   eval      w1upc  = w1uci
650fAc                   endif
650fA * Load Expiration Date
650fAc                   select

650fAc                   when      $bcExpDSent
650fAc                   eval      $lexpdt6 = $bcExpD

650fAc                   when      not $bcExpDSent and moretoscan = *on
650fAC                   eval      $cvcmd = '*MDYYMD '
650fAC                   move      savew3expd    $cvd6i
650fAC                   call      @cvtdt
650fAC                   parm                    $cvtdt
650fAC                   eval      $lexpdt6 = $cvd6o
650fA
650fAc                   endsl
650fA * Load Manufacturing Date
650fAc                   select
650fA
650fAc                   when      $bcProdDSent
650fAc                   eval      $lmfgdt6 = $bcProdD
650hAc                   eval      $lbcProdD = $bcProdD
650fA
650fAc                   when      not $bcProdDSent and moretoscan = *on
650fAC                   eval      $cvcmd = '*MDYYMD '
650fAC                   move      savew3mfdt    $cvd6i
650fAC                   call      @cvtdt
650fAC                   parm                    $cvtdt
650fAC                   eval      $lmfgdt6 = $cvd6o
650fA
650fAc                   endsl
650fAc
650fA * Load Catch Weight
650fAc                   if        $bcPNtLbSent
650fAc                   endif
650fAC                   endsr
500dA*----------------------------------------------------------------
500dA*  zzerrind    Set error indicators from DRI call.
500dA*----------------------------------------------------------------

500dAC     zzerrind      begsr

     C                   if        $sldispe = '1'
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   endif

     C                   if        $slstate = '1'
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   endif

     C                   if        $slprtye = '1'
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   endif

     C                   if        $slexpde = '1'
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   endif

     C                   if        $slexpde = '1'
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   endif

     C                   if        $sacodee = '1'
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   endif

     C                   if        $saqty1e = '1'
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   endif

     C                   if        $saqty2e = '1'
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   endif

     C                   if        $saqty3e = '1'
     C                   eval      *in30 = *on
     C                   eval      *in10 = *on
     C                   endif

     C                   if        $sacwtae = '1'
     C                   eval      *in33 = *on
     C                   endif

500dAC                   endsr

     *----------------------------------------------------------------
416b *
416b *  zzexcp Write item exception record to file.
416b *
416b C     zzexcp        begsr
416b *
416b *    Write an item exception record for item.
416b *
416bAC     itkey         chain     piritem                            79
416bAC                   if        not *in79
416bAC                   eval      exwhdp = itwhdp
416bAC                   eval      exstyp = itstyp
416bAC                   else
416bAC                   eval      exwhdp = *blanks
416bAC                   eval      exstyp = *blanks
416bAC                   endif
     *
416kAC                   eval      $scmd = '*FIRST'
416kAC                   call      'GETPSLT'
416kAC                   parm                    $scmd             8
416kAC                   parm      w1whse        $swhse            3 0
416kMC                   parm      exitem        #sitem           15
416kAC                   parm                    woslot           12
416kAC                   parm                    $saisl            3
416kAC                   parm                    $sloc             3 0
416kAC                   parm                    $srlvl            2 0
416kAC                   parm                    $shand            2
416kAC                   parm                    $srtn             8
416kAC                   if        $srtn <> '*NONE   '
416kAC                   eval      extdis = woslot
416kAC                   else
416b C                   eval      extdis = *blanks
416kAC                   endif
416b C                   eval      exwhse = w1whse
416b **                   MOVE W1ITEM    EXITEM
416b **                   MOVE W3CITM    EXCITM
650bA*
650bAC                   if        w1qty1 > 999
650bAC                   eval      exqty = 999
650bAC                   else
650bA*
416b C                   z-add     w1qty1        exqty
650bAC                   endif
650bA*
416b C                   z-add     w1qty2        exqty2
416b C                   z-add     w1qty3        exqty3
500bD**                   MOVE *BLANKS   EXFDIS
416b C                   eval      extask = 'PUTRTN'
416b **                   MOVE 'MISPICK' EXERID
417cA*    Retrieve current date.
417cAC                   eval      $cvcmd = '*CURCMD '
417cAC                   call      @cvtdt
417cAC                   parm                    $cvtdt
417cD*R                   Z-ADDTODAY     EXGDTE
417cMC                   eval      exgdte = $cvd8o
416b C                   time                    exgtim
416b C                   eval      exgby = #user
416b C                   eval      exesta = '1 '
416b C                   write     exrec
416b *
416b C     endexc        endsr
740bA*----------------------------------------------------------------
740bA*
740bA*  ZZFIL0   Fill screen 0 fields with info from file.
740bA*
740bAC     zzfil0        begsr
740bA*
740bAC                   call      'GETWHSE'
740bAC                   parm                    #user
740bAC     w1whse        parm      0             #whse             3 0
740bA*
740bA*
740bAC                   exsr      zzlcns
740bA*
740bAC                   eval      w1ord = 0
740bAC                   eval      w1orda = *blanks
740bAC                   eval      w1item = *blanks
740bAC                   eval      w1dev = *blanks
740bAC                   movel     '*DEFAULT'    w1dev
740bAC                   eval      w1form = *blanks
740bAC                   movel     '*DEFAULT'    w1form
740bAC                   eval      w1lbl# = 0
740bAC                   eval      w1lbl#b = *blanks
740bAC                   eval      w1uci = *blanks
740bAC                   eval      w1vmfg = *blanks
740bAC                   eval      w1rord = 'N'
740bAC                   eval      woinv# = ' '
740bAC                   clear                   $barcode
740bAC                   clear                   $barcode2
740bAc                   eval      pckorg = 0
740bAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
210 A*
210 AC                   call      'GETWHSE'
210 AC                   parm                    #user
210 AC     w1whse        parm      0             #whse             3 0
     *
EGFaAC                   if        client=egf
EGFaAC*                  eval      wocust = 'Customer # . . . . . . . . . . . .'
EGFaAC                   eval      w1cnum = 0
EGFaAC                   endif
210 A*
223 AC                   exsr      zzlcns
     *
     C                   eval      w1ord = 0
650kAC                   eval      w1orda = *blanks
416FD*R                   MOVE SVUSER    W1USER
415bD*R                   MOVE *BLANKS   W1USER
     C                   eval      w1item = *blanks
     C                   eval      w1dev = *blanks
JORaAC                   if        client = jordanos
JOR1AC                   eval      *in03 = *on
JORaAC                   endif
     C                   movel     '*DEFAULT'    w1dev
     C                   eval      w1form = *blanks
     C                   movel     '*DEFAULT'    w1form
415aAC                   eval      w1lbl# = 0
640aAC                   eval      w1lbl#b = *blanks
650fDC*                  eval      w1upc = *blanks
650fMC                   eval      w1uci = *blanks
416bAC                   eval      w1vmfg = *blanks
416iAC                   eval      w1rord = 'N'
650jAC                   eval      woinv# = ' '
650hAC                   clear                   $barcode
650hAC                   clear                   $barcode2
740aAc                   eval      pckorg = 0
     C                   endsr
PCKbA*----------------------------------------------------------------
PCKbA*
PCKbA*  ZZFIL1p  Fill screen 1p fields with info from file.
PCKbA*
PCKbAC     zzfil1p       begsr
PCKbA*
PCKbAC                   exsr      zzlcns
PCKbA*
PCKbAc                   eval      *in36 = *on
PCKbAC                   eval      w1item = *blanks
PCKbAC                   eval      w1lbl# = 0
PCKbAC                   eval      w1lbl#b = *blanks
PCKbAC                   eval      w1uci = *blanks
PCKbAC                   eval      w1vmfg = *blanks
PCKbAC                   clear                   $barcode
PCKbAC                   clear                   $barcode2
PCKbAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
210 A*
     *   Get Unit of measure fields
     C                   eval      w1um1 = *blanks
     C                   eval      w1um2 = *blanks
     C                   eval      w1um3 = *blanks
     C                   exsr      zzuom
     *
     *   Format item description
     *
     C                   call      'FRMTIT'
     C                   parm                    ititem
     C                   parm                    itdesc
     C                   parm                    itpdsc
     C                   parm                    $frtn            70
     C                   movel     $frtn         woitem
     *
     *   Initialize entry fields
     *
650fAC                   if        $ifrcvmth = '2' or $ifsltmth = '2'
650fAC                   eval      w1qt01 = 1
650fAc                   else
212 AC                   eval      w1qt01 = 0
650fAc                   endif
212 AC                   eval      w1qt02 = 0
212 AC                   eval      w1qt03 = 0
     C                   eval      w1cwtr = 0
650fAc                   if        moretoscan = *on
650fAc                   else
     C                   eval      w1code = *blanks
     C                   eval      w1memo = *blanks
     C                   eval      w1trn# = 0
416B **                   MOVE *BLANKS   W1CITM
500eDC*                  eval      w1slot = *zeros
500eMC                   eval      w1slot = *blanks
415aAC                   eval      w1trn# = wotrn#
416b C                   eval      w2dcde = *blanks
416b C                   eval      w2inv# = *blanks
416d C                   move      woinv#        w2inv#
416fMC                   eval      w2ulbl = oprulb
416mAC                   eval      w2upc = *blanks
416mAC                   eval      w2vmfg = *blanks
416m C                   eval      w2citm = *blanks
WST2 C                   if        client = westside
WST2AC                   eval      w1code = 'WR'
WST2AC                   eval      w2dcde = 'STOCK'
WST2 C                   endif
650fAc                   endif
416fD**         WOLBL#    IFNE 0
416fD**                   MOVE 'Y'       W2ULBL
416fD**                   ENDIF
213 AC                   if        itcwgt <> 'Y'
     C                   eval      *in95 = *on
     C                   else
650fAc                   if        $bcpntlbsent
650fAc                   eval      w1cwtr  = $bcPNtLb
650hAc                   if        $ifrcvmth <> '1'
720dAc                             and $ifrcvmth <> '4'
720dAc                             and $ifrcvmth <> '5'
720dAc                             and $ifrcvmth <> '6'
650fAc                   eval      *in72 = *on
650hAc                   endif
650fAc                   else
650fAc                   eval      w1cwtr = 0
650fAc                   eval      *in72 = *off
650fAc                   endif
     C                   eval      *in95 = *off
213 AC                   endif
213 AC                   if        itflgd <> 'Y'
     C                   eval      *in96 = *on
     C                   else
     C                   eval      *in96 = *off
213 AC                   endif
212 AC                   if        not *in32
212 AC                   endif
650fA /free
650fA   if rninvf = 'Y';
650fA     *in73 = *off;
650fA   else;
650fA     *in73 = *on;
650fA   endif;
650fA /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
416b *  ZZFIL3   Fill screen 3 fields with info from file.
     *
416b C     zzfil3        begsr
416b C     w2dcde        chain     rdscode                            79
416b C                   if        not *in79
416b C                   eval      w3iinv = rdiinv
416b C                   else
416b C                   eval      w3iinv = 'N'
416b C                   endif
     *
650fAc                   if        $bcproddsent
650fAc                   if        $ifrcvmth = '2' or $ifsltmth = '2'
650fAc                   eval      *in84 = *on
650fAc                   else
650fAc                   eval      *in84 = *off
650fAc                   endif
650fAC                   eval      $cvcmd = '*YMDMDY '
650fAC                   move      $lmfgdt6      $cvd6i
650fAC                   call      @cvtdt
650fAC                   parm                    $cvtdt
650fAC                   eval      w3mfdt = $cvd6o
650fAc                   else
650fAc                   if        moretoscan = *on and savew3mfdt > 0
650fAC                   eval      w3mfdt = savew3mfdt
650fAc                   eval      *in84 = *on
650fAc                   else
416m C                   eval      w3mfdt = 0
650fAc                   eval      *in84 = *off
650fAc                   endif
650fAc                   endif

650fAc                   if        $bcexpdsent
650fAc                   if        $ifrcvmth = '2' or $ifsltmth = '2'
650fAC                   eval      *in83 = *on
650fAc                   else
650fAC                   eval      *in83 = *off
650fAc                   endif
650fAC                   eval      $cvcmd = '*YMDMDY '
650fAC                   move      $lexpdt6      $cvd6i
650fAC                   call      @cvtdt
650fAC                   parm                    $cvtdt
650fAC                   eval      w3expd = $cvd6o
650fAc                   else
416m C                   eval      w3expd = 0
650fAC                   eval      *in83 = *off
650fAc                   endif

650fA * lot
650fAc                   if        $bclotsent
650fAc                   if        $ifrcvmth = '2'  or $ifsltmth = '2'
650fAc                   eval      *in85 = *on
650fAc                   else
650fAc                   eval      *in85 = *off
650fAc                   endif
650fAc                   eval      w3lotc = $bclot
650fAc                   else
650fAc                   eval      w3lotc = ' '
650fAc                   eval      *in85 = *off
650fAc                   endif

650iA * pti
650iAc                   if        $ifucicde <> '1'and $ifrcvmth <> '2'
650iAc                   eval      *in81 = *off
650iAc                   else
650iAc                   eval      *in81 = *on
650iAc                   endif
650iAc                   eval      w3pti = 0

     C                   eval      w3memo = *blanks
     *
416m *  If mispick, get info for mispick item.
416m C                   if        w2citm <> *blanks
416m C                   move      w2citm        kyitem
416m C                   endif
     *
416m C     itkey         chain     piritem                            75
416m C                   if        not *in75  and
416m C                             itflgd = 'Y'
416m C                   eval      *in96 = *off
416m C                   else
416m C                   eval      *in96 = *on
416m C                   endif
416m *    If mispick was entered, get item/description.
416m C                   if        w2citm <> *blanks
416m C                   eval      woitem = *blanks
416m C                   move      w2citm        woitem
     *   Format item description
416m C                   call      'FRMTIT'
416m C                   parm                    ititem
416m C                   parm                    itdesc
416m C                   parm                    itpdsc
416m C                   parm                    $frtn
416m C                   movel     $frtn         woitem
416m C                   endif
416mA*
416mA*   Enable Mfg date and disable Exp date, if Mfg date flag = 'Y'
416mA*
416mAC     imkey         chain     itemmsc                            79
416mAC                   if        not *in79  and
416mAC                             immflg = 'Y'
416mAC                   eval      *in87 = *off
416mAC                   eval      *in96 = *on
416mAC                   else
416mAC                   eval      *in87 = *on
416mAC                   endif
416mAC                   if        *in79
416mAC                   eval      immflg = 'N'
416mAC                   endif
     *
416b C                   endsr
     *----------------------------------------------------------------
416i *
416i *  ZZFIL4   Fill screen 4 fields with info from file.
     *
416i C     zzfil4        begsr
     *
     *   Initialize entry fields
     *
416i C                   eval      w4code = *blanks
416i C                   eval      w4dcde = *blanks
530a C                   eval      w4memo = *blanks
416i C                   endsr
500a *----------------------------------------------------------------
500a *
500a *  ZZFIL6   Fill screen 6 fields with info from file.
500a *
500a C     zzfil6        begsr
500aA*
500aAC                   call      'GETWHSE'
500aAC                   parm                    #user
500aAC     w6whse        parm      0             #whse             3 0
500aA*
500a *
500a C                   eval      w6ord = 0
500a C                   eval      w6cust = 0
500a C                   eval      w6dev = *blanks
500a C                   movel     '*DEFAULT'    w6dev
500a C                   eval      w6form = *blanks
500a C                   movel     '*DEFAULT'    w6form
500a C                   endsr
650fA*----------------------------------------------------------------
650fA*
650fA*  ZZFIL8   Fill screen 8 fields with info from file.
650fA*
650fAC     zzfil8        begsr
650fA*
650fA*   Format item description
650fA*
650fAC                   call      'FRMTIT'
650fAC                   parm                    ititem
650fAC                   parm                    itdesc
650fAC                   parm                    itpdsc
650fAC                   parm                    $frtn            70
650fAC                   movel     $frtn         woitem
650fAC                   endsr
650fA*----------------------------------------------------------------
650fA*
650fA*  ZZFIL9   Fill screen 9 fields with info from file.
650fA*
650fAC     zzfil9        begsr
650fA*
650fA*   Get Unit of measure fields
650fAC                   eval      w1um1 = *blanks
650fAC                   eval      w1um2 = *blanks
650fAC                   eval      w1um3 = *blanks
650fAC                   exsr      zzuom
650fA*
650fA*   Format item description
650fA*
650fAC                   call      'FRMTIT'
650fAC                   parm                    ititem
650fAC                   parm                    itdesc
650fAC                   parm                    itpdsc
650fAC                   parm                    $frtn            70
650fAC                   movel     $frtn         woitem
650fA*
650fA*   Initialize entry fields
650fA*
650fAC                   eval      w1qt01 = saveqty
650fAC                   eval      w1qt02 = 0
650fAC                   eval      w1qt03 = 0
650fAC                   eval      w1cwtr = 0
650fAC                   move      woinv#        w2inv#
650fAC                   eval      w2ulbl = oprulb
650fAC                   if        client = westside
650fAC                   eval      w1code = 'WR'
650fAC                   eval      w2dcde = 'STOCK'
650fAC                   endif
650fAC                   if        itcwgt <> 'Y'
650fAC                   eval      *in95 = *on
650fAC                   else
650fAc                   eval      w1cwtr  = savewgt
650fAC                   eval      *in95 = *off
650fAC                   endif
650fAC                   if        itflgd <> 'Y'
650fAC                   eval      *in96 = *on
650fAC                   else
650fAC                   eval      *in96 = *off
650fAC                   endif
650fAC                   if        not *in32
650fAC                   endif
650fA * fill3
650fAC     w2dcde        chain     rdscode                            79
650fAC                   if        not *in79
650fAC                   eval      w3iinv = rdiinv
650fAC                   else
650fAC                   eval      w3iinv = 'N'
650fAC                   endif
650fA*
650fAc                   if        savew3mfdt > 0
650fAC                   eval      w3mfdt = savew3mfdt
650fAc                   else
650fAC                   eval      w3mfdt = 0
650fAc                   endif
650fA
650fAc                   if        savew3expd > 0
650fAC                   eval      w3expd = savew3expd
650fAc                   else
650fAC                   eval      w3expd = 0
650fAc                   endif
650fA
650fA * lot
650fAc                   if        savelotc <> ' '
650fAc                   eval      w3lotc = savelotc
650fAc                   else
650fAc                   eval      w3lotc = ' '
650fAc                   endif
650fA
650fA*
650fA*  If mispick, get info for mispick item.
650fAC                   if        w2citm <> *blanks
650fAC                   move      w2citm        kyitem
650fAC                   endif
650fA*
650fAC     itkey         chain     piritem                            75
650fAC                   if        not *in75  and
650fAC                             itflgd = 'Y'
650fAC                   eval      *in96 = *off
650fAC                   else
650fAC                   eval      *in96 = *on
650fAC                   endif
650fA*    If mispick was entered, get item/description.
650fAC                   if        w2citm <> *blanks
650fAC                   eval      woitem = *blanks
650fAC                   move      w2citm        woitem
650fA*   Format item description
650fAC                   call      'FRMTIT'
650fAC                   parm                    ititem
650fAC                   parm                    itdesc
650fAC                   parm                    itpdsc
650fAC                   parm                    $frtn
650fAC                   movel     $frtn         woitem
650fAC                   endif
650fA*
650fA*   Enable Mfg date and disable Exp date, if Mfg date flag = 'Y'
650fA*
650fAC     imkey         chain     itemmsc                            79
650fAC                   if        not *in79  and
650fAc                             immflg = 'Y'
650fAC                   eval      *in87 = *off
650fAC                   eval      *in96 = *on
650fAC                   else
650fAC                   eval      *in87 = *on
650fAC                   endif
650fAC                   if        *in79
650fAC                   eval      immflg = 'N'
650fAC                   endif
650fA * from po137
650fAc                   eval      expd   = saveexpd
650fA*
650fAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
417a C                   move      *off          forevr
     C                   eval      $rprg = #prog
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog

780aA  // Get client info
780aA
780aA  getclient(client: clientLoc: clientinit: clienthost);
780aA
780aA  // Set Host Lots flag
780aA  // Currently hardcoded for FreshByte and NetSuite
780aA
780aA  if clienthost = FreshByte or clienthost = NetSuite;
780aA    usingHostLots = *on;
780aA  else;
780aA    usingHostLots = *off;
780aA  endif;

     *
     *  Define key for PIRITEM file.
     *
CTWaAC     dckey         klist
CTWaAC                   kfld                    w1whse
CTWaAC                   kfld                    w1item
     *
     C     itkey         klist
     C                   kfld                    w1whse
416b C                   kfld                    kyitem
416bD**                   KFLD           W1ITEM
415b *
415b C     ohkey         klist
415b C                   kfld                    w1whse
415b C                   kfld                    lbord
500a *
500a C     oh5key        klist
500a C                   kfld                    w6whse
500a C                   kfld                    w6ord
DRYbA* zzchk1 verify good order with entered item
DRYbAC     oh1key        klist
DRYbAC                   kfld                    w1whse
DRYbAC                   kfld                    w1ord
DRYbA*
DRYbAC     orddkey       klist
DRYbAC                   kfld                    w1whse
DRYbAC                   kfld                    wiord
DRYbAC                   kfld                    w1item
415cA*
650kAC     oh12key       klist
650kAC                   kfld                    w1whse
650kAC                   kfld                    w1orda
650kA*
650kAC     rhkey         klist
650kAC                   kfld                    w1whse
650kAC                   kfld                    ohrte
650kA*
415cA*  Define key for UPC file.
415cA*
415cAC     upckey        klist
415cAC                   kfld                    w1whse
415cAC                   kfld                    kyupc
415cA*
416bA*  Define key for PIRITEM4 MFG code.
416bA*
416bAC     mfgkey        klist
416bAC                   kfld                    w1whse
416bAC                   kfld                    kyvmfg
416jA*
416jA*  Define key for ORRTN2 return whole order.
416jA*
416jAC     rtnkey        klist
416jAC                   kfld                    w1whse
416jAC                   kfld                    wslord
416jAC                   kfld                    kywhol
720cA*
720cAC     rtnkeyx       klist
720cAC                   kfld                    w1whse
720cAC                   kfld                    wslord
     *
     C     partk2        klist
     C                   kfld                    $rord
     C                   kfld                    w1whse
223 A*
223 A*     OPTIONS
223 A*
223 AC     opkey         klist
223 AC                   kfld                    w1whse
223 AC                   kfld                    ocode
223 A*
415bA*
415bA*  Define key for OPTIOND.
415bA*
415bAC     opkey2        klist
415bAC                   kfld                    kycode
415bAC                   kfld                    itwhse
415bAC                   kfld                    itwhdp
415bAC                   move      '*PICK   '    kycode
416m *
416m *  Define key for ITEMMSC file.
416m *
416mAC     imkey         klist
416mAC                   kfld                    itwhse
416mAC                   kfld                    ititem
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
640dA * determine if mfr decipher is available to client
640dAc                   eval      $lcmd = '*OPEN'
640dAC                   eval      $lwhse = w1whse
640dAc                   call      'MF200'                              66
640dAC                   parm                    $lparm
640dAC                   parm      0             $lexpdat          6 0
640dAC                   parm      0             $lmfrdat          6 0
640dAC                   parm                    $lupc            20
640dAC                   parm      ' '           $ldecvalue       15
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
416cA*   Set flag if called from Quick Return .
416cAC                   if        $pqck = 'Y'
416cAC                   move      *on           quick
416cAC                   eval      *in55 = *on
416cAC                   else
416cAC                   eval      quick = *off
416cAC                   eval      *in55 = *off
416cAC                   endif
KHLaAc                   if        client = kohl
KHLaAC                   eval      *in55 = *off
KHLaAc                   endif
650fA*
650fAC                   call      'GETUSER'
650fAC                   parm      #user         $code            10
650fAC                   parm      0             $whse             3 0
650fAC                   parm      0             $emp#             5 0
650fAC                   parm      *blanks       $fnam            15
650fAC                   parm      *blanks       $init             1
650fAC                   parm      *blanks       $lnam            20
650fAC                   parm      *blanks       $whdp             5
650fAC                   parm      *blanks       $styp             1
650fAC                   parm      *blanks       $shft             6
650fAC                   parm      *blanks       $crew             6
650fAC                   parm      0             $nhrs             3 1
650fAC                   parm      *blanks       $rtn              8
     *
EGFaAC                   if        client=egf
EGFaAC                   eval      *in56 = *off
EGFaAC                   else
EGFaAC                   eval      *in56 = *on
EGFaAC                   endif
     *
     *   Open putaway program.
     *
     C                   call      'RC160'
     C                   parm      '*OPEN   '    $rcmd             8
     C                   parm                    $rprg            10
     C                   parm      '*INTER  '    $rtype            8
     C                   parm                    w1whse
     C                   parm                    $ritem           15
     C                   parm                    w1qty1
     C                   parm                    w1qty2
     C                   parm                    w1qty3
     C                   parm      *blanks       $rpo              9
     C                   parm      0             $rven            11 0
     C                   parm      *blanks       $rvnam           40
     C                   parm      *blanks       $rvitm           15
     C                   parm                    $rord             7 0
     C                   parm                    w1code
     C                   parm                    w1memo
     C                   parm                    $rexpd            8 0
417e C                   parm      0             $rfifo            8 0
     C                   parm                    w1dev            10
     C                   parm                    w1form           10
     C                   parm                    $rslot           12
218 AC                   parm      0             $rseq             5 0
218 AC                   parm                    $rrpck            1
218 AC                   parm                    $rplbl            1
223 AC                   parm      0             $rdwgt            9 2
     C                   parm                    $rrq1             5 0
     C                   parm                    $rrq2             5 0
     C                   parm                    $rrq3             5 0
     C                   parm                    $rrpal            3 0
     C                   parm                    $rrtn             8
     C                   parm                    $rmsg             4
     *
     *   Initialize headings and return type.
     *
     C                   select
     C                   when      $pcmd = '*RETURN '
416CD***                  MOVE ' '       RTNTYP  1
740bAC                   eval      w0scrn = 'RN120.00'
     C                   eval      w1scrn = 'RN120.01'
     C                   eval      w2scrn = 'RN120.02'
416b C                   eval      w3scrn = 'RN120.03'
530aAC                   eval      w4scrn = 'RN120.04'
500a C                   eval      w6scrn = 'RN120.06'
650fAC                   eval      w7scrn = 'RN120.07'
650fAC                   eval      w8scrn = 'RN120.08'
650fAC                   eval      w9scrn = 'RN120.09'
416cAC                   if        $pqck = 'N'
416CAC                   move      ' '           rtntyp
     C                   move      hed(1)        wohead
416cAC                   else
416CAC                   move      'Q'           rtntyp
416cAC                   move      hed(4)        wohead
500aAC                   move      hed(4)        w6head
416cAC                   endif
     C                   when      $pcmd = '*TFRRTN '
     C                   move      'T'           rtntyp
     C                   eval      w1scrn = 'RN125.01'
     C                   eval      w2scrn = 'RN125.02'
     C                   move      hed(2)        wohead
     C                   when      $pcmd = '*POSRTN '
     C                   move      'P'           rtntyp
     C                   eval      w1scrn = 'RN127.01'
     C                   eval      w2scrn = 'RN127.02'
     C                   move      hed(3)        wohead
     C                   endsl
     *
     *   Center screen heading.
     *
500aAC                   if        $pqck = 'A'
500aAC                   call      'CENTER'
500aAC                   parm                    w6head
500aAC                   parm      60            $clen
500aAC                   else
     C                   call      'CENTER'
     C                   parm                    wohead
     C                   parm      60            $clen             3 0
500aAC                   endif
     *
     *   Display first screen.
     *
     C                   move      *on           refrsh
     C                   eval      usesc = 1
416fD**         *LIKE     DEFN W1USER    SVUSER
416fD**                   MOVE *BLANKS   SVUSER
500aAC                   if        $pqck = 'A'
500aAC                   exsr      scr06i
500aAC                   else
     C                   if        usesc = 1
PCKbAc                   if        client = pack730
PCKbAc                   exsr      scr00i
PCKbAc                   else
     C                   exsr      scr01i
PCKbAc                   endif
     C                   else
     C                   exsr      scr03i
     C                   endif
500aAC                   endif
     C                   endsr
416d *----------------------------------------------------------------
416d *
416dA*  ZZITEM   Get item # for F17 log.
416d *
416dAC     zzitem        begsr
     *
416dAC                   eval      wsitem = *blanks
416dAC                   if        w1lbl# <> 0
416dAC     w1lbl#        chain     label                              79
416dAC                   if        *in79
416dAC                   move      *on           error
416dAC                   eval      errmsg = *blanks
416dAC                   eval      errmsg = desc(1)
416dD**                   MOVE *ON       *IN34
416dD**                   MOVE *ON       *IN14
416dMC                   eval      *in22 = *on
416dMC                   eval      *in02 = *on
416dAC                   exsr      zm1001
416dAC                   goto      enditm
416dAC                   else
416dAC                   move      lbitem        wsitem
416dAC                   endif
416dAC                   endif
416d *
416d *  UPC entered
650fDC*                  if        w1upc <> *blanks
650fMC                   if        w1uci <> *blanks
650fDC*                  eval      $cbcmd = '*UPC    '
650fDC*                  movel     w1upc         $cbbar
650fMC                   eval      $cbcmd = '*ALL    '
650fMC                   movel     w1uci         $cbbar
416dAC                   call      'CVTBAR'
416dAC                   parm                    $cbcmd
416dAC                   parm                    $cbbar
416dAC                   parm                    $cbcod
416dAC                   parm                    $cbdec
416dAC                   parm                    $cbdsc
416dAC                   parm                    $cbpos
416dAC                   parm                    $cbtyp
416dAC                   parm                    $cbv1
416dAC                   parm                    $cbv2
416dAC                   parm                    $cbrtn
416dAC                   parm                    $cberm
650fAC                   parm                    $cbven           10 0
650fAC                   parm                    $cvtdata
650fAC                   parm                    $cvtdata2

650fAc                   eval      $barcode = $cvtdata
650fAc                   eval      $barcode2 = $cvtdata2
650fA * Load UPC
650fAc                   if        $bcGtinSent
650fAc                   eval      w1upc  = $bcGtin
650fAc                   eval      *in92 = *on
650fAc                   else
650fAc                   eval      w1upc  = w1uci
650fAc                   endif
650fA * Load Expiration Date
650fAc                   if        $bcExpDSent
650fAc                   eval      $lexpdt6 = $bcExpD
650fAc                   endif
650fA * Load Manufacturing Date
650fAc                   if        $bcProdDSent
650fAc                   eval      $lmfgdt6 = $bcProdD
650hAc                   eval      $lbcProdD = $bcProdD
650fAc                   endif
650fA * Load Catch Weight
650fAc                   if        $bcPNtLbSent
650fAc                   endif
416d *
416dAC                   if        $cbrtn = '*OK'
416dAC                   eval      w1upc = $cbv2
416dAC                   endif
416d *
416d *   Right adjust UPC code for file.
416d *
416dAC                   eval      $cstr = *blanks
416dAC                   movel     w1upc         $cstr
416dAC                   call      'ADJUST'
416dAC                   parm      '*RIGHT  '    $ccmd
416dAC                   parm                    $cstr
510aDC*                  eval      kyupc = $cstr
510aMC                   move      $cstr         kyupc
416dAC     upckey        chain     upc                                79
416dAC                   if        *in79
416dAC                   move      *on           error
416dAC                   eval      *in25 = *on
416dAC                   eval      *in05 = *on
416dAC                   eval      errmsg = *blanks
416dAC                   exsr      zm29
416dAC                   goto      enditm
416dAC                   endif
416d *
416dAC                   move      upitem        wsitem
416dAC                   endif
416d *
416d *  Mfg code/vendor item entered.
416d *
416dAC                   if        w1vmfg <> *blanks
416dAC                   move      w1vmfg        kyvmfg
416dAC     mfgkey        chain     piritem4                           79
416dAC                   if        *in79
416dAC                   move      *on           error
416dAC                   eval      *in26 = *on
416dAC                   eval      *in06 = *on
416dAC                   eval      errmsg = *blanks
416dAC                   eval      errmsg = desc(9)
416dAC                   exsr      zm1001
416dAC                   goto      enditm
416dAC                   else
416dAC                   move      ititem        wsitem
416dAC                   endif
416dAC                   endif
     *
     *  Item number entered.
416dAC                   if        w1item <> *blanks
416d C                   eval      $lcmd = '*VERIFY '
416d C                   eval      $lwhse = w1whse
416d C                   eval      $litem = w1item
416d C                   call      'IT900'
416d C                   parm                    $lparm
416d C                   if        $lrtn = '*PGMQ   '
416d C                   move      *on           error
416d C                   eval      *in23 = *on
416d C                   eval      *in03 = *on
416d C                   eval      #msgk = $lmsg
416d C                   exsr      zmqmsg
416dAC                   goto      enditm
416d C                   else
416dAC                   move      ititem        wsitem
416d C                   endif
416dAC                   endif
     *
416dAC     enditm        tag
416dAC                   endsr
     *----------------------------------------------------------------
     *
223 A*  ZZLCNS   Get use generic license option
     *
223 AC     zzlcns        begsr
     *
223 A*   Get use generic license option.
223 AC                   move      '0'           lcnflg
223 AC                   move      '*RCVLBL '    ocode
     *
223 AC     opkey         chain     options                            79
223 AC                   if        not *in79
223 AC                   if        opplcn = 'Y'
223 AC                   move      '1'           lcnflg
223 AC                   endif
223 AC                   endif
     *
223 AC                   endsr
650fA*----------------------------------------------------------------
650fA*  ZZLICINFOCAN  User cancelled - licinfo needs to be deleted
650fA*----------------------------------------------------------------
650fA
650fA /free
650fA   begsr zzlicinfocan;
650fA
650fA     exsr clr$licinfo;
650fA
650fA     $lnwhse  = w1whse;
650fA     select;
650fA     when w3iinv = 'N';
650fA       $lnlcns  = templcns;
650fA     other;
650fA       $lnlcns  = w7lcns;
650fA     endsl;
650fA
650fA     $dricommand = '*LICINFO';
650fA     $drisubcmd  = '%DELETEALL';
650fA     $drisys2upd = 'D';
650fA     chk4err = *on;
650fA     exsr zzzdricop;
650fA     if error;
650fA     endif;
650fA
650fA   endsr;
650fA /end-free
650fA*----------------------------------------------------------------
650fA*  ZZLICINFOCHK  Check to see if licinfo exist for this lcnslot/exp
650fA*----------------------------------------------------------------
650fA
650fA /free
650fA   begsr zzlicinfochk;
650fA
650fA     Lastseq  = 1;
650fA     dow forevr = forevr;
650fA
650fA     exsr clr$licinfo;
650fA
650fA     $lnwhse  = w1whse;
650fA     select;
650fA     when w3iinv = 'N';
650fA       $lnlcns  = templcns;
650fA     other;
650fA       $lnlcns  = w7lcns;
650fA     endsl;
650fA     $lnseq  = lastseq + 1;
650fA
650fA     $dricommand = '*LICINFO';
650fA     $drisubcmd  = '%GET';
650fA     $drisys2upd = 'D';
650fA     chk4err = *on;
650fA     exsr zzzdricop;
650fA     if error;
650fA       leave;
650fA     else;
650fA       // compare lot and date fields
650fA       if $lnlot = w3lotc and
650fA          $lnexpdate = expd;
650fA         // add qty and weight, update licinfo
650fA         $lnttllbs = $lnttllbs + w1cwtr;
650fA         //$lnrcvqty = $lnrcvqty + 1;
650fA         $lnseqqty = $lnseqqty + 1;
650fA         $dricommand = '*LICINFO';
650fA         $drisubcmd  = '%CHANGES';
650fA         $drisys2upd = 'D';
650fA         chk4err = *on;
650fA         exsr zzzdricop;
650fA         licinfoupd = *on;
650fA         leave;
650fA       endif;
650fA       eval lastseq = lastseq + 1;
650fA     endif;
650fA
650fA   enddo;
650fA   endsr;
650fA /end-free
650fA*----------------------------------------------------------------
650fA*  ZZLICINFOSEQ  Used to get the current lnseqqty for accumulator
650fA*----------------------------------------------------------------
650fA
650fA /free
650fA   begsr zzlicinfoseq;
650fA
650fA     exsr clr$licinfo;
650fA
650fA     $lnwhse  = w1whse;
650fA     select;
650fA     when w3iinv = 'N';
650fA       $lnlcns  = templcns;
650fA     other;
650fA       $lnlcns  = w7lcns;
650fA     endsl;
650fA     $lnseq  = 1;
650fA
650fA     $dricommand = '*LICINFO';
650fA     $drisubcmd  = '%GET';
650fA     $drisys2upd = 'D';
650fA     chk4err = *on;
650fA     exsr zzzdricop;
650fA     if error;
650fA     else;
650fA       // accumulate the lnseqqty field
650fA       $lnseqqty = $lnseqqty + 1;
650fA       $dricommand = '*LICINFO';
650fA       $drisubcmd  = '%CHANGES';
650fA       $drisys2upd = 'D';
650fA       chk4err = *on;
650fA       exsr zzzdricop;
650fA       licinfoupd = *on;
650fA     endif;
650fA
650fA   endsr;
650fA /end-free
650fA*----------------------------------------------------------------
650fA*  ZZLICINFONew Update New format of LICINFO
650fA*----------------------------------------------------------------
650fA
650fA /free
650fA   begsr zzlicinfonew;
650fA
650fA     // Write out standard license information
650fA     exsr clr$licinfo;
650fA
650fA     $lnwhse  = w1whse;
650fA     select;
650fA       when w3iinv = 'N';
650fA         $lnlcns  = templcns;
650fA     other;
650fA       $lnlcns  = w7lcns;
650fA     endsl;
650fA
650fA     if difflot or diffexpd;
650fA       $lnseq = lastseq + 1;
650fA       $lnseqqty = $lnseqqty + 1;
650fA       //$lnrcvqty = 1;
650fA       $lnttllbs = w1cwtr;
650fA     else;
650fA       $lnseq = 1;
650fA       $lnseqqty = 1;
650fA     endif;
650fA     $lnpo = ' ';
650fA     $lnposeq = 0;
650fA     $lnitem = w1item;
650fA     // LNRCVTYP notes
650fA     // 1 = Manual quantity (original method)
650fA     // 2 = Manual quantity with initial GS1 scan
650fA     // 3 = UCI using Mfg GS1 barcodes
650fA     // 4 = UCI using Internal GS1 barcodes (start with 99)
650fA     // 5 = ASN file
650fA
650fA     select;
650fA       when $ifucicde = ' ';
650fA         $lnrcvtyp = '1';
650fA       when $ifucicde = '1';
650fA         $lnrcvtyp = '1';
650fA       when $ifucicde = '2';
650fA         $lnrcvtyp = '3';
650fA       when $ifucicde = '3';
650fA         $lnrcvtyp = '4';
650fA       // don't know exactly what 2 will represent
650fA     endsl;
650fA     $lnrcvtrn# = 0;
650fA     $lnrcvlbl# = 0;
650fA
650fA     select;
650fA       when wofifo <> 0;
650fA         $lnentdate = wofifo;
650fA       when w3mfdt <> 0;
650fA         $lnentdate = womfdt;
650fA       other;
650fA         $lnentdate = woexdt;
650fA     endsl;
650fA
650fA     if wofifo > 0;
650fA       $lnenttype = '*FIFODT';
650fA     else;
650fA       if $itflgd = 'Y';
650fA         select;
650fA           when $imuday > 0 or
650fA                $imdday > 0;
650fA             if $immflg = 'Y';
650fA               $lnenttype = '*MFGDTE';
650fA             else;
650fA               $lnenttype = '*USEDTE';
650fA             endif;
650fA           other;
650fA             $lnenttype = '*EXPDTE';
650fA         endsl;
650fA       else;
650fA         $lnenttype = '*ENTDTE';
650fA       endif;
650fA
650fA       $lndateflag = $itflgd;
650fA       $lnmfgflag = $immflg;
650fA
650fA       $lnmfgdays = $immday;
650fA       $lnusrdays = $imuday;
650fA       $lndstdays = $imdday;
650fA     endif;
650fA
650fA     $lnmfgdate = womfdt;
650fA
650fA     if mexpd > 0;
650fA       $lnmfgexp = mexpd;
650fA     endif;
650fA
650fA     if wofifo > 0;
650fA       $lnfifodate = wofifo;
650fA     endif;
650fA
650fA     if expd > 0;
650fA       $lnexpdate = expd;
650fA     endif;
650fA
650fA     if $ldecvalue > ' ';
650fA       $lnmfgcode = $ldecvalue;
650fA     endif;
650fA
650fA     $lnavglbs = 0;
650fA
650fA     if W3lotc <> ' ';
650fA       $lnlot = w3lotc;
650fA     endif;
650fA
650fA     //if w1brand <> ' ';
650fA       //$lnbrand = w1brand;
650fA     //endif;
650hA       // calculate the PTI.
650hA       if $bclot <> ' ' and $bcgtinsent;
650hA         pplot  = %subst($bclot: 1 : 20);
650hA         calcpti ($bcgtin: pplot: $lbcprodD: pppti);
650hA         if pppti > 0;
650hA           $lnlotPTI4 = %editc(pppti:'X');
650hA           $lnlotPTI2 = %Subst(%EditC(pppti:'X'):3:2);
650hA           // create detail pti records in UCIINFO for use at selection
650hA           // when item is not UCI receiving method
650hA           k = 0;
650hA           if $ifrcvmth <> '2';
650hA             dou k = $lnrcvqty;
650hA               k = k + 1;
650hA               exsr clr$uciinfo;
650hA               $uiWhse = w1whse;
650hA               $uiItem = w1item;
650hA               $uiuci = %trim(%editc(pppti:'X'));
650hA               ucilic#($unext: w1whse);
650hA               unexta = %editc($unext:'X');
650hA               $uiuciLcns = 'P:' + unexta;
650hA               $uiLcns = $lnlcns;
650hA               $uiseq = 1;
650hA               $uiSerial = ' ';
650hA               // weight is calculated as average
650hA               $uiwgtlbs = w1cwtr / $lnrcvqty;
650hA               $uiSelTrn# = 0;
650hA               $uiSelLbl# = 0;
650hA               $uiSelOrd = 0;
650hA               $uiSelSeq = 0;
650hA               $uiSelCSeq = 0;
650hA               $uiSelTrax = ' ';
650hA               $uiCrtBy = '2';
720eA               if uputyp   = *blanks;
720eA                  $uiaUTyp = 'N';
720eA                  $uiaSlUTyp = 'N';
720eA               endif;
720eA               if $bcgtin = *blanks;
720eA               $uiaGtin = 0;
720eA               else;
720eA               $uiaGtin  = %DEC($bcGTin:14:0);
720eA               endif;
720eA               $uiaLot   = $bclot;
720eA               if saveexpd = 0;
720eA                  $uiaExpD  = expd;
720eA               else;
720eA                  $uiaExpd = saveexpd;
720eA               endif;
720eA               $uiaEntD  = today;

650hA               $dricommand = '*UCIINFO';
650hA               $drisubcmd  = '%ADD';
650hA               $drisys2upd = 'D';
650hA               chk4err = *on;
650hA               zmflag  = *off;
650hA               exsr zzzdricop;
650hA             enddo;
650hA           endif;
650hA         endif;
650hA       endif;
650fA
650fA     $dricommand = '*LICINFO';
650fA     $drisubcmd  = '%ADDS';
650fA     $drisys2upd = 'D';
650fA     chk4err = *on;
650fA     exsr zzzdricop;
650fA     if error;
650fA     endif;
650fA
650fA   endsr;
650fA /end-free
640dA*----------------------------------------------------------------
640dA*
640dA*  ZZmfrdates  Set manufactures dates
640dA*
640dAC     zzmfrdates    begsr
640dAc                   select
640dAc                   when      $lmfrdat > 0 and $ldecvalue > ' '
640dA*
640dA*  Calculate Mfg Exp    date.(Mfg date + Mfg Shelf life days)
640dA*

640dAC                   eval      $cvcmd = '*MDYCMD '
640dAC                   move      $lmfrdat      $cvd6i
640dAC                   call      @cvtdt
640dAC                   parm                    $cvtdt
640dAC                   move      $cvd8o        mfgdte

640dA*  Create mfg expiration date mfgdate + mfg shelf life days
640dA
640dAC                   call      'CLCDUR2'
640dAC                   parm      '*ADD'        $cdcmd
640dAC                   parm      mfgdte        $cddatein
640dAC                   parm      0             $cdtimein
640dAC                   parm      0             $cdyears
640dAC                   parm      0             $cdmonths
640dAC                   parm      immday        $cddays
640dAC                   parm      0             $cdhours
640dAC                   parm      0             $cdminutes
640dAC                   parm      0             $cdseconds
640dAC     mexpd         parm      0             $cddateout
640dAC                   parm      0             $cdtimeout


640dA*
640dA*  Calculate Mfg date if mfg exp date is entered
640dA*
640dAc                   when      $lexpdat > 0 and $ldecvalue > ' '

640dA*
640dA*  Calculate Mfg date.(Mfg exp date - Mfg Shelf life days)
640dA*

640dAC                   eval      $cvcmd = '*MDYCMD '
640dAC                   move      $lexpdat      $cvd6i
640dAC                   call      @cvtdt
640dAC                   parm                    $cvtdt
630dAC                   move      $cvd8o        mexpd

640dA*  Create mfg date - date mfg exp date - mfg shelf life days
640dA
640dAC                   call      'CLCDUR2'
640dAC                   parm      '*SUB'        $cdcmd
640dAC                   parm      mexpd         $cddatein
640dAC                   parm      0             $cdtimein
640dAC                   parm      0             $cdyears
640dAC                   parm      0             $cdmonths
640dAC                   parm      immday        $cddays
640dAC                   parm      0             $cdhours
640dAC                   parm      0             $cdminutes
640dAC                   parm      0             $cdseconds
640dAC     mfgdte        parm      0             $cddateout
640dAC                   parm      0             $cdtimeout
640dAc                   if        immday = 0
     c                   eval      mfgdte = 0
640dAc                   endif

640dAc                   when      w3mfdt > 0 and itflgd = 'Y'
640dA*
640dA*  Calculate Mfg Exp    date.(Mfg date + Mfg Shelf life days)
640dA*

640dAC                   eval      $cvcmd = '*MDYCMD '
640dAC                   move      w3mfdt        $cvd6i
640dAC                   call      @cvtdt
640dAC                   parm                    $cvtdt
640dAC                   move      $cvd8o        mfgdte

640dA*  Create mfg expiration date mfgdate + mfg shelf life days
640dA
640dAC                   call      'CLCDUR2'
640dAC                   parm      '*ADD'        $cdcmd
640dAC                   parm      mfgdte        $cddatein
640dAC                   parm      0             $cdtimein
640dAC                   parm      0             $cdyears
640dAC                   parm      0             $cdmonths
640dAC                   parm      immday        $cddays
640dAC                   parm      0             $cdhours
640dAC                   parm      0             $cdminutes
640dAC                   parm      0             $cdseconds
640dAC     mexpd         parm      0             $cddateout
640dAC                   parm      0             $cdtimeout

640dAc                   when      w3expd > 0

640dA*
640dA*  Calculate Mfg date.(Mfg exp date - Mfg Shelf life days)
640dA*

640dAC                   eval      $cvcmd = '*MDYCMD '
640dAC                   move      w3expd        $cvd6i
640dAC                   call      @cvtdt
640dAC                   parm                    $cvtdt
640dAC                   move      $cvd8o        mexpd

640dA*  Create mfg date - date mfg exp date - mfg shelf life days
640dA
640dAC                   call      'CLCDUR2'
640dAC                   parm      '*SUB'        $cdcmd
640dAC                   parm      mexpd         $cddatein
640dAC                   parm      0             $cdtimein
640dAC                   parm      0             $cdyears
640dAC                   parm      0             $cdmonths
640dAC                   parm      immday        $cddays
640dAC                   parm      0             $cdhours
640dAC                   parm      0             $cdminutes
640dAC                   parm      0             $cdseconds
640dAC     mfgdte        parm      0             $cddateout
640dAC                   parm      0             $cdtimeout

640dAc                   if        immday = 0
640dAc                   eval      mfgdte = 0
640dAc                   endif

640dAc                   endsl
640dAC                   endsr
     *
416  *----------------------------------------------------------------
416  *
416iA*  ZZORD    Process to return whole order.
416  *
416iAC     zzord         begsr
416  *
416 A*   Process all records for order number.
416 AC                   move      '0'           lcnflg
416 AC                   move      '*RCVLBL '    ocode
416  *
416 AC     ohkey         setll     ordd
416aAC                   move      *off          stop
416aAC                   dou       stop = *on
416aAC     ohkey         reade     ordd                                   79
416aAC                   if        *in79
416aAC                   move      *on           stop
416aAC                   else
4166AC                   eval      lllblo = wolbl#
416 AC                   endif
416 AC                   enddo
     *
416 AC                   endsr
     *
416lA*----------------------------------------------------------------
416lA*
416lA*  ZZPSLT   Get Put pick slot for mispick items
416lA*
416lAC     zzpslt        begsr
     *
416lAC                   move      *off          picksl
416lAC                   eval      oslot = *zeros
416lAC                   eval      pslot = *zeros
416lAC                   movel     '*FIRST'      $scmd
416lAC                   call      'GETPSLT'
416lAC                   parm                    $scmd
416lAC                   parm      w1whse        $swhse
416lMC                   parm      exitem        #sitem
416lAC                   parm                    woslot
416lAC                   parm                    $saisl
416lAC                   parm                    $sloc
416lAC                   parm                    $srlvl
416lAC                   parm                    $shand
416lAC                   parm                    $srtn
416lAC                   if        $srtn <> '*NONE   '
416lAC                   move      woslot        oslot
     *
416lAC                   movel     '*FIRST'      $scmd
416lAC                   call      'GETPSLT'
416lAC                   parm                    $scmd
416lAC                   parm      w1whse        $swhse
416lMC                   parm      excitm        #sitem
416lAC                   parm                    woslot
416lAC                   parm                    $saisl
416lAC                   parm                    $sloc
416lAC                   parm                    $srlvl
416lAC                   parm                    $shand
416lAC                   parm                    $srtn
416lAC                   if        $srtn <> '*NONE   '
416lAC                   move      woslot        pslot
     *
416lAC                   move      *on           picksl
416lAC                   endif
416lAC                   endif
416lAC                   endsr
     *
415bA*----------------------------------------------------------------
415bA*
415bA*  ZZPUTO   Get Put away option.
415bA*             Directed or Manual put away
415bA*
415bAC     zzputo        begsr
415bA*
415bAC     itkey         chain     piritem                            79
415bAC                   if        not *in79
415bAC                   eval      kycode = '*PICK   '
415bAC     opkey2        chain     optiond                            79
415bAC                   if        *in79
415bAC                   eval      opmput = 'N'
415bAC                   endif
415bAC                   endif
WS1 AC*
WST1AC*   West Side Foods - Do not allow Manual returns.
700cA * these 3 lines of code were WST1 mod previously
700cDC*                  if        client = westside
WST1AC                   eval      opmput = 'Y'
700cDC*                  endif
415bA*
415bAC                   endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  ZZRCVRTNCLEAN   Check for remaining open RCVRTN transaction
650cA*
650cAC     zzrcvrtnclean begsr
650cA*
650cA*  See if RCVRTN transaction is status 2 - start new if needed
650cA*
650cAc                   if        $lsavetrn   > 0
650cAc                   move      w1ord         $rtnord
650cAC                   call      @crtrcv
650cAC                   parm      '*RETURN'     $lcmdr           10
650cAC                   parm      '*CLEAN'      $lsubcmd         10
650cAC                   parm      w1whse        @lwhse            3 0
650cAC                   parm                    $lpcs             5 0
650cAC                   parm                    $lpallets         5 0
650cAC                   parm                    $lsavetrn         7 0
650cAC                   parm                    $rtnord           9
650cAC                   parm                    $litstyp          1
650cAC                   parm                    $litwhdp          5
650cAC                   parm                    $lrtnr           10
650cAc                   endif
650cAC                   endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  ZZRCVRTNCHECK check for started RCVRTN Transaction
650cA*
650cAC     zzrcvrtncheck begsr
650cA*
650cA*  See if RCVRTN transaction is status 2 - start new if needed
650cA*
650cAc                   move      w1ord         $rtnord
650cAC                   call      @crtrcv
650cAC                   parm      '*RETURN'     $lcmdr           10
650cAC                   parm      '*CHECK '     $lsubcmd         10
650cAC                   parm      itwhse        @lwhse            3 0
650cAC                   parm      0             $lpcs             5 0
650cAC                   parm      0             $lpallets         5 0
650cAC                   parm                    $lsavetrn         7 0
650cAC                   parm                    $rtnord           9
650cAC                   parm      itstyp        $litstyp          1
650cAC                   parm      itwhdp        $litwhdp          5
650cAC                   parm                    $lrtnr           10
650cAC                   endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  ZZRCVRTN Create receiver transaction.
650cA*
650cAC     zzrcvrtn      begsr
650cA*
650cA*     clear the return field used in po236
650cA*
650cAc                   eval      $lrtn = ' '
650cAc                   move      w1ord         $rtnord
650cAC                   call      @crtrcv
650cAC                   parm      '*RETURN'     $lcmdr           10
650cAC                   parm      '*CREATE'     $lsubcmd         10
650cAC                   parm      itwhse        @lwhse            3 0
650cAC                   parm      0             $lpcs             5 0
650cAC                   parm      0             $lpallets         5 0
650cAC                   parm                    $lsavetrn         7 0
650cAC                   parm                    $rtnord           9
650cAC                   parm      itstyp        $litstyp          1
650cAC                   parm      itwhdp        $litwhdp          5
650cAC                   parm                    $lrtnr           10
650cA*
650cAC                   endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  ZZRCVRTNCLOSE  Close RCVRTN transaction.
650cA*
650cAC     zzrcvrtnclose begsr
650cAc                   if        rcvrtncomplete

650cAc                   select
650cAc                   when      $lrq1 > 0
650cAc                   eval      poppcs = $lrq1
650cAc                   when      $lrq2 > 0
650cAc                   eval      poppcs = $lrq2
650cAc                   when      $lrq3 > 0
650cAc                   eval      poppcs = $lrq3
650cAc                   endsl
650cAC                   call      @crtrcv
650cAC                   parm      '*RETURN'     $lcmdr           10
650cAC                   parm      '*COMPLETE'   $lsubcmd         10
650cAC                   parm      itwhse        @lwhse            3 0
650cAC                   parm      poppcs        $lpcs             5 0
650cAC                   parm      $lrpal        $lpallets         5 0
650cAC                   parm                    $lsavetrn         7 0
650cAC                   parm                    $rtnord           9
650cAC                   parm      itstyp        $litstyp          1
650cAC                   parm      itwhdp        $litwhdp          5
650cAC                   parm                    $lrtnr           10
650cA
650cAc                   else
650cA
650cAC                   call      @crtrcv
650cAC                   parm      '*RETURN'     $lcmdr           10
650cAC                   parm      '*CLOSE'      $lsubcmd         10
650cAC                   parm      itwhse        @lwhse            3 0
650cAC                   parm      0             $lpcs             5 0
650cAC                   parm      0             $lpallets         5 0
650cAC                   parm                    $lsavetrn         7 0
650cAC                   parm                    $rtnord           9
650cAC                   parm      itstyp        $litstyp          1
650cAC                   parm      itwhdp        $litwhdp          5
650cAC                   parm                    $lrtnr           10

650cAc                   endif
650cAC                   endsr
650fA*----------------------------------------------------------------
650fA*
650fA*  ZZUCI    Write UCI data
650fA*
650fAC     zzuci         begsr
650fAc                   if        $ldecvalue = ' '
650fAc                   exsr      zzmfrdates
650fAc                   endif
650fAC                   if        $immflg = 'Y'
650fA*
650fA*  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
650fA*
650fA
650fAC                   eval      $cvcmd = '*MDYCMD '
650fAC                   move      w3mfdt        $cvd6i
650fAC                   call      @cvtdt
650fAC                   parm                    $cvtdt
650fAC                   move      $cvd8o        expd
650fAC                   move      $cvd8o        womfdt
650fA
650fAC                   call      'CLCDUR2'
650fAC                   parm      '*ADD'        $cdcmd
650fAC                   parm      expd          $cddatein
650fAC                   parm      0             $cdtimein
650fAC                   parm      0             $cdyears
650fAC                   parm      0             $cdmonths
650fAC                   parm      $immday       $cddays
650fAC                   parm      0             $cdhours
650fAC                   parm      0             $cdminutes
650fAC                   parm      0             $cdseconds
650fAC                   parm      0             $cddateout
650fAC                   parm      0             $cdtimeout
650fA
650fAC                   call      'CLCDUR2'
650fAC                   parm      '*SUB'        $cdcmd
650fAC                   parm      $cddateout    $cddatein
650fAC                   parm      0             $cdtimein
650fAC                   parm      0             $cdyears
650fAC                   parm      0             $cdmonths
650fAC                   parm      $imuday       $cddays
650fAC                   parm      0             $cdhours
650fAC                   parm      0             $cdminutes
650fAC                   parm      0             $cdseconds
650fAC     expd          parm      0             $cddateout
650fAC                   parm      0             $cdtimeout
650fA
650fAC                   eval      $cvcmd = '*CMDMDY '
650fAC                   move      expd          $cvd8i
650fAC                   call      @cvtdt
650fAC                   parm                    $cvtdt
650fAC                   move      $cvd6o        w3expd
650fA
650fA*
650fAC                   endif
650fA* add records to uci file
650fA*
650fA /free
650fA   // need to determine if the licinfo record already exist for
650fA   // this lcns/lot/exp date - keep checking until we find a match
650fA   // or no more licinfo records exist - if no match and no licinfo
650fA   // exist need to write the next available seq# to licinfo.
650fA   // if licinfo record exist - just update the qty and the weight
650fA   select;
650fA     when moretoscan = *on and difflot = *on  or
650fA          moretoscan = *on and diffexpd = *on;
650fA       exsr zzlicinfochk;
650fA     when moretoscan = *on and difflot <> *on and diffexpd <> *on;
650fA       exsr zzlicinfoseq;
650fA   endsl;
650fA
650fA   if licinfoupd <> *on and difflot = *on or
650fA      licinfoupd <> *on and diffexpd = *on or
650fA      moretoscan <> *on;
650fA     exsr zzlicinfonew;
650fA   endif;
650fA
650fA   exsr clr$uciinfo;
650fA   $uiWhse = w1whse;
650fA   $uiItem = w1item;
650fA   $uiuci = w1uci;
650fA   ucilic#($unext: w1whse);
650fA   unexta = %editc($unext:'X');
650fA   $uiuciLcns = 'U:' + unexta;
650fA   select;
650fA   when w3iinv = 'N';
650fA     $uiLcns = templcns;
650fA   other;
650fA     $uiLcns = w7lcns;
650fA   endsl;
650fA   if difflot = *on or
650fA     diffexpd = *on;
650fA     $uiseq = $lnseq;
650fA   else;
650fA     $uiseq = 1;
650fA   endif;
650fA   $uiSerial = $bcSer#;
650fA   // if user entered weight use that/ if uci had weight use that
650fA   select;
650fA     when w1cwtr > 0;
650fA       $uiwgtlbs = w1cwtr;
650fA     when $bcPNtLbSent = *on;
650fA       $uiwgtlbs = $bcPNtLb;
650fA     other;
650fA       $uiwgtlbs = 0;
650fA   endsl;
650fA   // Weight KG  - only if uci barcode contained KG
650fA   if $bcPNtKgSent = *on;
650fA     $uiWgtKgs = $bcPntKg;
650fA   else;
650fA     $uiWgtKgs = 0;
650fA   endif;
650fA   $uiSelTrn# = 0;
650fA   $uiSelLbl# = 0;
650fA   $uiSelOrd = 0;
650fA   $uiSelSeq = 0;
650fA   $uiSelCSeq = 0;
650fA   $uiSelTrax = ' ';
650fA   $uiCrtBy = '2';
720eA   if uputyp  = ' ';
720eA      $uiaUTyp = 'N';
720eA      $uiaSlUTyp = 'N';
720eA   endif;
720eA   if $bcgtin = *blanks;
720eA      $uiaGtin = 0;
720eA   else;
720eA      $uiaGtin  = %DEC($bcGTin:14:0);
720eA   endif;
720eA   $uiaLot   = $bclot;
720eA   if saveexpd = 0;
720eA      $uiaExpD  = expd;
720eA   else;
720eA      $uiaExpD = saveexpd;
720eA   endif;
720eA   $uiaEntD  = today;
650fA
650fA   $dricommand = '*UCIINFO';
650fA   $drisubcmd  = '%ADD';
650fA   $drisys2upd = 'D';
650fA   chk4err = *on;
650fA   zmflag  = *off;
650fA   exsr zzzdricop;
650fA   if error;
650fA     uciExists = *on;
650fA     error = *on;
650fA     errmsg= desc(17);
650fA     exsr zm02;
650fA     leavesr;
650fA   else;
650fA     UciExists = *off;
650fA     error = *off;
650fA   endif;
650fA
650fA   // save the values from the first scan to be used for the license
650fA   if moretoscan <> *on;
650fA     if $immflg = 'Y';
650fA       savew3mfdt = w3mfdt;
650fA     endif;
650fA     if $itflgd = 'Y';
650fA       savew3expd = w3expd;
650fA     endif;
650fA     saveexpd = expd;
650fA     savelotc = w3lotc;
650fA   endif;
650fA   savewgt  = savewgt + w1cwtr;
650fA   saveqty  = saveqty + 1;
650fA   // scan some more uci barcodes
650fA   // save first scanned lot and dates
650fA   moretoscan = *on;
650fA   nxtscr = '08 ';
650fA   //$puci = ' ';
650fA   w1uci = ' ';
650fA   //ovrrid = *off;
650fA   difflot = *off;
650fA   diffexpd = *off;
650fA   lotwarn = *off;
650fA   expdwarn = *off;
650fA   lotovr  = *off;
650fA   expdovr  = *off;
650fA   licinfoupd = *off;
650fA
650fA /end-free
650fAc
650fAC     enduci        endsr
     *----------------------------------------------------------------
416mA*
416mA*  ZZUMFR   Update for POMFR FILE
416mA*
416mAC     zzumfr        begsr
416mA*
416mAC                   if        w3mfdt <> 0  or
416mAC                             w3expd <> 0
416mA**         W1EXPD    IFNE 0
416mAC     partk2        setll     label2
416mAC                   eval      stop = *off
416mAC                   dou       stop = *on
416mAC     partk2        reade     label2                                 79
416mA**         LBKEY     READELABEL2                   79
416mAC                   if        *in79
416mAC                   eval      stop = *on
416mAC                   else
500fAC     lblbl#        chain     pomfr1                             78
416mAC                   eval      pmwhse = w1whse
416mAC                   eval      pmpo = *blanks
416mAC                   eval      pmseq = 0
416mD**                   MOVE $PITEM    PMITEM
416mMC                   if        w2citm <> *blanks
416mMC                   eval      pmitem = w2citm
416mMC                   else
416mMC                   eval      pmitem = w1item
416mMC                   endif
416mAC                   eval      pmexpd = expd
416mA**                   Z-ADD$REXPD    PMEXPD
416mAC                   if        w3mfdt <> 0
416mAC                   move      w3mfdt        $cvd6i
416mAC                   eval      $cvcmd = '*MDYCMD '
416mAC                   call      @cvtdt
416mAC                   parm                    $cvtdt
416mAC                   eval      pmmfgd = $cvd8o
416mAC                   else
416mAC                   eval      pmmfgd = 0
416mAC                   endif
416mAC                   eval      pmtrn# = lbtrn#
416mAC                   eval      pmlbl# = lblbl#
500fAC                   if        *in78  = *off
500fAC                   update    pmrec
500fAC                   else
416mAC                   write     pmrec
500fAC                   endif
416mA*
416mAC                   endif
416mAC                   enddo
416mAC                   endif
416mA*
416mAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUOM    Get Unit Of Measure Normal, Breakdown1, Breakdown2.
     *
     C     zzuom         begsr
     *
     *   Get Unit of Measures.
     *    *IN91=Protect & non-display breakdown1 unit of measure
     *    *IN92=Protect & non-display breakdown2 unit of measure
     *
     *
     C                   eval      *in94 = *off
     C                   eval      *in93 = *off
     C     itkey         chain     piritem                            75
     C                   if        *in75
     C                   eval      *in94 = *on
     C                   eval      *in93 = *on
     C                   goto      enduom
     C                   else
     C                   if        itflg1 = 'N'
     C                   eval      *in94 = *on
     C                   endif
     C                   if        itflg2 = 'N'
     C                   eval      *in93 = *on
     C                   endif
     C                   endif
     *
720eAC                   eval      $uiaUTyp = uputyp
     C     itum1         chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w1um1 = umshrt
     C                   else
     C                   eval      w1um1 = *blanks
     C                   endif
     *
     C                   if        not *in94
     C     itum2         chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w1um2 = umshrt
     C                   else
     C                   eval      w1um2 = *blanks
     C                   endif
     C                   endif
     *
     C                   if        not *in93
     C     itum3         chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w1um3 = umshrt
     C                   else
     C                   eval      w1um3 = *blanks
     C                   endif
     C                   endif
415cA*
415cAC                   if        ittype = 'S'
415cAC                   eval      itum1 = itum2
415cAC                   eval      itum2 = itum3
415cAC                   eval      itum3 = *blanks
415cAC     itum1         chain     unmesr                             75
415cAC                   if        not *in75
415cAC                   eval      w1um1 = umshrt
415cAC                   else
415cAC                   eval      w1um1 = *blanks
415cAC                   endif
     *
415cAC     itum2         chain     unmesr                             75
415cAC                   if        not *in75
415cAC                   eval      w1um2 = umshrt
415cAC                   else
415cAC                   eval      w1um2 = *blanks
650aAc                   eval      *in94 = *on
415cAC                   endif
     *
415cAC                   endif
     *
     C     enduom        endsr
650fA*----------------------------------------------------------------
650fA*
650fA*  ZZUPCCK  Update for screen 1.
650fA*
650fAC     zzupcck       begsr
650fAC                   select
650fA*  UPC entered
650fAC                   when      w1uci <> ' '
650fA*
650fAC                   eval      $cbcmd = '*UPC    '
650fAC                   movel     w1uci         $cbbar
650fAC                   call      'CVTBAR'
650fAC                   parm                    $cbcmd            8
650fAC                   parm                    $cbbar          100
650fAC                   parm                    $cbcod            3 0
650fAC                   parm                    $cbdec            1 0
650fAC                   parm                    $cbdsc           30
650fAC                   parm                    $cbpos            3 0
650fAC                   parm                    $cbtyp            1 0
650fAC                   parm                    $cbv1            11 3
650fAC                   parm                    $cbv2            50
650fAC                   parm                    $cbrtn            8
650fAC                   parm                    $cberm           60
650fA*
650fAC                   if        $cbrtn = '*OK'
650fAC                   eval      ckupc = $cbv2
650fAC                   endif
650fA*
650fA*   Right adjust UPC code for file.
650fA*
650fAC                   eval      $cstr = *blanks
650fAC                   movel     ckupc         $cstr
650fAC                   call      'ADJUST'
650fAC                   parm      '*RIGHT  '    $ccmd             8
650fAC                   parm                    $cstr            30
650fAC                   move      $cstr         kyupc
650fA*   Check if mulitple items exist for one UPC code.
650fA*    UPCCTR = 0, error, upc code not found.
650fA*    UPCCTR = 1, only one upc found, process for item.
650fA*    UPCCTR > 1, multiple upc found, need to select item.
650fAC                   eval      upcctr = 0
650fAC     upckey        setll     upc
650fAC                   dow       forevr = forevr
650fAC     upckey        reade     upc                                    79
650fA*
650fAC                   if        *in79
650fAC                   leave
650fAC                   else
650fAC                   add       1             upcctr
650fAC                   endif
650fA*
650fAC                   enddo
650fA*
650fAC                   if        upcctr = 0
650fAC                   eval      error = *on
650fAC                   eval      *in25 = *on
650fAC                   eval      *in05 = *on
650fAC                   eval      errmsg = *blanks
650fAC                   exsr      zm29
650fAC                   goto      endupcck
650fAC                   endif
650fA*
650fA*   Multiple items exist for UPC
650fAC                   if        upcctr > 1
650fAC                   eval      $lcmd = '*VERIFY '
650fAC                   eval      $lwhse = w1whse
650fAC                   eval      $lupc = kyupc
650fAC                   call      'UC920'
650fAC                   parm                    $lparm
650fAC                   if        $lrtn = '*ERROR  '
650fAC                   eval      error = *on
650fAC                   eval      *in25 = *on
650fAC                   eval      *in05 = *on
650fAC                   movel     $lerm         errmsg
650fAC                   exsr      zm0105
650fAC                   else
650fAC                   if        $lrtn = '*PGMQ   '
650fAC                   eval      error = *on
650fAC                   eval      *in25 = *on
650fAC                   eval      *in05 = *on
650fAC                   eval      #msgk = $lmsg
650fAC                   exsr      zmqmsg
650fAC                   endif
650fAC                   endif
650fAC                   eval      upitem = $litm1
650fA*
650fAC                   endif
650fA*
650fAC                   endsl
650fAc     endupcck      endsr
740bA*----------------------------------------------------------------
740bA*
740bA*  ZZUPD0   Update for screen 0.
740bA*
740bAC     zzupd0        begsr
740bAC                   move      *off          error
740bA*
740bAC                   if        w1rord = 'Y'
740bAC                   goto      endup0
740bAC                   endif
740bAc                   exsr      zzrcvrtn
740bA*
740bAC                   if        w1rord = 'N'
740bAc                   eval      *in36 = *on
740bAc                   exsr      scr01i
740bAC                   endif
740bA*
740bAC     endup0        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   move      *off          error
416fD**                   MOVE W1USER    SVUSER
     *
415bA**         WOORD     IFGT 0
415bA**         OHKEY     CHAINORDH                 79
415bA**         *IN79     IFEQ *OFF
415bA**                   Z-ADDOHCORD    W1ORD
415bA**                   ENDIF
415bA**                   ENDIF
     *
416bAC                   move      w1item        kyitem
415bAC                   exsr      zzputo
     *
416iAC                   if        w1rord = 'Y'
416iAC                   goto      endup1
416iAC                   endif
650cAc                   exsr      zzrcvrtn
     *
416iAC                   if        w1rord = 'N'
415bAC                   if        opmput = 'Y'
415bAC                   eval      $lcmd = '*RETURN '
415bAC                   eval      $lprg = #prog
415bAC                   eval      $lwhse = w1whse
415bAC                   eval      $litem = w1item
416fMC                   eval      $lusr = #user
416fD*R                   MOVE W1USER    $LUSR
415bAC                   eval      $ldev = w1dev
415bAC                   eval      $lform = w1form
415aAC                   eval      $llbl# = wolbl#
415bAC                   eval      $lord# = w1ord
EGFaAC                   if        client=egf
EGFaAC                   eval      $lord# = w1cnum
EGFaAC                   endif
415bAC                   eval      $lltrn = wotrn#
416dAC                   move      woinv#        $linv#
DRYe *  Careful what values you pass vs plist in RN250 - messy
415bAC                   call      'RN250'
415bAC                   parm                    $lparm
415aAC                   parm                    $llbl#            7 0
415bAC                   parm                    $lord#            7 0
416bAC                   parm                    $lltrn            7 0
416CAC                   parm                    $pqck
416CAC                   parm                    $linv#            9
530dAC                   parm                    $qty1             5 0
530dAC                   parm                    $qty2             5 0
530dAC                   parm                    $qty3             5 0
530dAC                   parm                    $qty4             5 0
650cAC                   parm                    $lsavetrn         7 0
650fAC                   parm                    w1uci
720aAC                   parm                    lbord
740aAC                   parm                    pckorg
750aAC                   parm      pltlcns       $pltlcns
750aAC                   parm      hldpicklbl    $hldpicklbl
415bAC                   if        $lrtn = '*PGMQ   '
415bAC                   move      *on           error
415bAC                   eval      *in23 = *on
415bAC                   eval      *in03 = *on
415bAC                   eval      #msgk = $lmsg
415bAC                   exsr      zmqmsg
415bAC                   endif
415bAC                   if        $lrtn = '*CANCEL '
415bAC                   move      *off          refrsh
415bAC                   exsr      scr01i
415bAC                   goto      endup1
415bAC                   endif
415b *
415bAC                   else
     C                   exsr      zzlcns
415bAC                   endif
416iAC                   endif
     *
650gA*    Set indiciators after first time in to position cursor.
416d *    *in42 postiion to label field after 1st time in.
416mD*                    MOVE *ON       *IN32
SGCdDc**                 if        client = 'SGC'
SGCdDc**                 eval      *in07 = *on
SGCdDc**                 else
650gDC*                  if        client = citywho
650gA*
650gAC                   select
700fDC**                 when      client = citywho
700fDC**                           or client = sgc
700fDC**                 eval      *in32 = *on
650gA*
JORaAC                   when      client = jordanos
650gAc                   eval      *in32 = *off
650gAc                   eval      *in42 = *off
650gAc                   eval      *in03 = *on
CBI A*
CBI AC                   when      client = cheney
CBI Ac                   eval      *in01 = *off
CBI Ac                   eval      *in02 = *off
CBI Ac                   eval      *in03 = *on
CBI Ac                   eval      *in32 = *off
CBI Ac                   eval      *in42 = *on
PCKbA*
PCKbAC                   when      client = pack730
PCKbAc                   eval      *in36 = *on
PCKbAc                   eval      *in42 = *off
650gDc*                  else
650gA*
650gAc                   other
416mMC                   eval      *in42 = *on
650gAC                   endsl
650gA*
CTWbDc*                  endif
SGCdDc**                 endif
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
416f C                   eval      woulbl = w2ulbl
     *
416b *    Code to call RC160 was moved to ZZUPD3.
416b **                   CALL 'RC160'
     *
     C     endup2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update for screen 3.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
640dA* Move mfg or expire or fifo date to keyed in date field
640dA* to send to PO236
640dAC                   eval      woindt = 0
640dAC                   select
640dAC                   when      wofifo <> 0
640dAC                   eval      woindt = wofifo
640dAC                   when      w3mfdt <> 0
640dAC                   eval      woindt = mfgd
640dAC                   other
640dAC                   eval      woindt = expd
640dAC                   endsl
640dAc                   if        $ldecvalue = ' '
640dAc                   exsr      zzmfrdates
640dAc                   endif
     *
416b C                   if        w3iinv = 'N'
416b C                   movel     '*NOSTOCK'    $rpo
416b C                   move      *off          lcnflg
416f C                   move      'N'           woulbl
416b C                   else
416b C                   eval      $rpo = *blanks
416b C                   endif
     C                   if        w3expd = 0
     C                   eval      $rexpd = 0
     C                   else
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w3expd        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        $rexpd
     C                   endif
     *
     *
416b *  If mispick, create put away for corresponding (physical) item,
416b *  If mispick will impact inventory, force license entry.
416b C                   if        w2citm <> *blanks
416b C                   eval      $ritem = w2citm
416b C                   if        w3iinv = 'Y'
416b C                   move      *on           lcnflg
416f C                   move      'N'           woulbl
416b C                   endif
416b C                   else
416b C                   eval      $ritem = w1item
416b C                   endif
     *
WSTcAC                   if        client = westside
WSTcAC                   eval      $rcmd = '*SPRECV'
WSTcAC                   else
WSTcAC                   eval      $rcmd = $pcmd
WSTcAC                   endif
WSTcA
650fAc                   if        $ifrcvmth = '2' or $ifsltmth = '2'
650fAC                   eval      $rcmd = '*RETURN1'
650fAc                   endif
650dAc                   if        w3iinv <> 'Y'
650dAC                   eval      $lcmd = '*CHANGE '
650dAC                   eval      $lwhse = w1whse
650iDC*                  movel     '*NOSTOCK'    $lpo
650iMC                   movel     '*NOSTOCK '   $lpo
650dAC                   eval      $litem = w1item
650dAC                   eval      $lrq1 = w1qt01
650dAC                   eval      $lrq2 = w1qt02
650dAC                   eval      $lrq3 = w1qt03
650dAC                   eval      $lrpal = 1
650dAC                   z-add     w1ord         $lord
650dAC                   call      'RN246L'
650dAC                   parm                    $lparm
650dAC                   parm                    $lord
650dAC                   parm                    wolbl#
650dAC                   parm                    w1cwtr
650dAC                   parm                    expd
650dAC                   parm                    woindt
650dAC                   parm                    wofifo
650dAc                   parm                    $ldecvalue
650dAC                   parm      mexpd         $lmfgex           8 0
650dAC                   parm      mfgdte        $lmfgdt           8 0
650dAC                   parm                    $lsavetrn
650eAC                   parm                    w7lcns           15
650eAC                   parm                    w3lotc           30
650iDC*                  parm      ' '           $bcGtin
650iMC                   parm                    $bcGtin
650hAc                   parm                    $lbcProdD
650hAc                   parm                    $bclot
650iAc                   parm      w3pti         $pw3pti
650dAc                   eval      rcvrtncomplete = *on
650dAc                   else
     C                   call      'RC160'
WSTcDC**                 parm      $pcmd         $rcmd
WSTcMC                   parm                    $rcmd
     C                   parm                    $rprg
     C                   parm      '*INTER  '    $rtype
     C                   parm                    w1whse
     C                   parm                    $ritem
     C                   parm      w1qt01        w1qty1            5 0
     C                   parm      w1qt02        w1qty2            5 0
     C                   parm      w1qt03        w1qty3            5 0
416bD**                   PARM *BLANKS   $RPO    9
416bMC                   parm                    $rpo
     C                   parm      0             $rven
     C                   parm      *blanks       $rvnam
     C                   parm      *blanks       $rvitm
     C                   parm      w1ord         $rord
     C                   parm                    w1code
     C                   parm                    w1memo
     C                   parm                    $rexpd
417e C                   parm      0             $rfifo
     C                   parm                    w1dev
     C                   parm                    w1form
     C                   parm                    w1slot
218 AC                   parm      0             $rseq
218 AC                   parm                    $rrpck
218 AC                   parm                    $rplbl
223 AC                   parm      0             $rdwgt
     C                   parm                    $rrq1
     C                   parm                    $rrq2
     C                   parm                    $rrq3
     C                   parm                    $rrpal
     C                   parm                    $rrtn
     C                   parm                    $rmsg
650dAc                   endif
213 A*
213 A*   What happened with putaway?
213 A*
213 AC                   select
213 A*
213 A*      Error occured.
213 A*
213 D*          $RRTN     IFEQ '*PGMQ   '
213 AC                   when      $rrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      #msgk = $rmsg
     C                   exsr      zmqmsg
213 A*
223 A*      Enter license if LCNFLG is on.                            .
213 A*
213 D*                    ELSE
213 AC                   other
     *
223 AC                   if        lcnflg = *on  and
650fDC*                            woulbl = 'N' and
WSTdAC                             client <> Westside
416bD**         WOLBL#    ANDEQ0
223 AC                   eval      $lcmd = '*CHANGE '
223 AC                   eval      $lwhse = w1whse
223 AC                   move      w1ord         $lpo
223 AC                   eval      $litem = w1item
223 AC                   eval      $lrq1 = $rrq1
223 AC                   eval      $lrq2 = $rrq2
223 AC                   eval      $lrq3 = $rrq3
223 AC                   eval      $lrpal = $rrpal
223 AC                   z-add     $rord         $lord
650fAc                   if        $ifrcvmth = '2'  or $ifsltmth = '2'
650fAc                   eval      $lcns = w7lcns
650fAc                   endif
223 AC                   call      'RN146'
223 AC                   parm                    $lparm
223 D*R                   PARM           $LUM1
223 D*R                   PARM           $LUM2
223 D*R                   PARM           $LUM3
223 AC                   parm                    $lord
640dAC                   parm                    wolbl#
640dAC                   parm                    w1cwtr
640dAC                   parm                    expd
640dAC                   parm                    woindt            8 0
640dAC                   parm                    wofifo            8 0
640dAc                   parm                    $ldecvalue
640dAC                   parm      mexpd         $lmfgex           8 0
640dAC                   parm      mfgdte        $lmfgdt           8 0
650cAC                   parm                    $lsavetrn
650fAC                   parm                    $lcns            15
650fAC                   parm                    w3lotc
650hAC                   parm                    $bcGtin
650hAc                   parm                    $lbcProdD
650hAc                   parm                    $bclot
650iAc                   parm      w3pti         $pw3pti
650cAc                   eval      rcvrtncomplete = *on
223 AC                   endif
    A*
416mA*      Write expiration/manufacturer date to POMFR file.         .
416m C                   exsr      zzumfr
415aA*
415aA*      Write to label link file if Label # was entered.          .
415aA*
     *
415aAC                   if        wolbl# <> 0
415aAC                   exsr      zzulnk
415aAC                   endif
416bA*      If mispick, create exceptions for item and corresponding  .
416bA*      item if both items have pick slots.
416bA*
500a C                   eval      exfdis = *blanks
416bAC                   if        w2citm <> *blanks
416l *
416d C                   eval      exitem = w1item
416d C                   eval      excitm = w2citm
416d C                   eval      exerid = 'MISPICK'
416lAC                   exsr      zzpslt
416lAC                   if        picksl = *off
500a C                   movel     '*ORDER'      exfdis
416dAC                   exsr      zzexcp
416d C                   move      w2citm        kyitem
416d C                   eval      exitem = w2citm
416d C                   eval      excitm = w1item
416d C                   eval      exerid = 'MISPICK'
500b C                   movel     '*PUT  '      exfdis
416dAC                   exsr      zzexcp
416lAC                   else
416l *       Write adjustment for ordered item.
500dAC                   eval      ajcode = 'MO'
500dAC                   exsr      fill$adj
500dAC                   eval      $dricommand = '*SLOT'
500dAC                   eval      $drisubcmd  = '%ADJUST'
500dAC                   eval      $drisys2upd = 'D'
500dAC                   exsr      zzzdricop
416lAC*    itkey         chain     piritem                            79
416lAC*                  if        not *in79
416lAC*                  eval      iawhdp = itwhdp
416lAC*                  else
416lAC*                  eval      iawhdp = *blanks
416lAC*                  endif
416lAC*                  eval      iawhse = w1whse
416lAC*                  eval      iaitem = w1item
416lAC*                  eval      iadate = today
416lAC*                  time                    iatime
416lAC*                  movel     'RTN'         iaby
416lAC*                  move      oslot         iadisp
416lAC*                  eval      iacwta = 0
416lA*          W1QT01    MULT -1        IAQTY1
416lAC*                  eval      iaqty1 = w1qt01
416lAC*                  eval      iaqty2 = w1qt02
416lAC*                  eval      iaqty3 = w1qt03
416lAC*                  eval      iacode = 'MO'
416lAC*                  write     iarec
416l *       Write adjustment for physical item.
416l C                   move      w2citm        kyitem
500dAC                   eval      ajcode = 'MP'
500dAC                   exsr      fill$adj
500dAC                   eval      $dricommand = '*SLOT'
500dAC                   eval      $drisubcmd  = '%ADJUST'
500dAC                   eval      $drisys2upd = 'D'
500dAC                   exsr      zzzdricop
416lAC*    itkey         chain     piritem                            79
416lAC*                  if        not *in79
416lAC*                  eval      iawhdp = itwhdp
416lAC*                  else
416lAC*                  eval      iawhdp = *blanks
416lAC*                  endif
416lAC*                  eval      iawhse = w1whse
416lAC*                  eval      iaitem = w2citm
416lAC*                  eval      iadate = today
416lAC*                  time                    iatime
416lAC*                  movel     'RTN'         iaby
416lAC*                  move      pslot         iadisp
416lAC*                  eval      iacwta = 0
416lA*          W1QT01    MULT -1        IAQTY1
416lAC*                  eval      iaqty1 = w1qt01 * -1
416lAC*                  eval      iaqty2 = w1qt02 * -1
416lAC*                  eval      iaqty3 = w1qt03 * -1
416lAC*                  eval      iacode = 'MP'
416lAC*                  write     iarec
416lAC                   endif
416 A*
416dAC                   else
416dAC                   if        woinvf = 'Y'
500a C                   eval      exfdis = *blanks
416d C                   move      w1item        kyitem
416d C                   eval      exitem = w1item
416d C                   eval      excitm = *blanks
416d C                   eval      exerid = 'INVCTRL'
416dAC                   exsr      zzexcp
416dAC                   endif
416dAC                   endif
213 A*
213 A*      Product put away. Write history record and display message.
     C                   clear                   orrec
     C                   eval      orwhse = w1whse
     C                   eval      orord = w1ord
     C                   eval      oritem = w1item
416bAC                   if        w3iinv = 'N'
650dDC*                  eval      orqty1 = w1qty1
650dDC*                  eval      orqty2 = w1qty2
650dDC*                  eval      orqty3 = w1qty3
650dMC                   eval      orqty1 = w1qt01
650dMC                   eval      orqty2 = w1qt02
650dMC                   eval      orqty3 = w1qt03
416b C                   else
     C                   eval      orqty1 = $rrq1
     C                   eval      orqty2 = $rrq2
     C                   eval      orqty3 = $rrq3
416b C                   endif
     C                   eval      orcwtr = w1cwtr
417cA*    Retrieve current date.
417cAC                   eval      $cvcmd = '*CURCMD '
417cAC                   call      @cvtdt
417cAC                   parm                    $cvtdt
417cD*R                   Z-ADDTODAY     ORRDTE
417cMC                   eval      orrdte = $cvd8o
     C                   time                    orrtim
416fMC                   eval      orrusr = #user
416fD**                   MOVE W1USER    ORRUSR
     C                   move      rtntyp        ortype
     C                   eval      ortrn# = w1trn#
416 AC                   eval      orpbat = $rord
416b **                   MOVE W1CITM    ORCITM
416b C                   eval      orcitm = w2citm
     C                   eval      orrcod = w1code
416b C                   eval      ordcod = w2dcde
416b C                   eval      oriinv = w3iinv
416b C                   eval      orolb# = wolbl#
416b C                   move      w2inv#        orinv#
     C                   eval      orrmem = w3memo
     C                   move      w1slot        orslot
416cAC                   if        $pqck = 'Y'  and
416eAC                             worexq <> 'Y'
417cA*    Retrieve current date.
417cAC                   eval      $cvcmd = '*CURCMD '
417cAC                   call      @cvtdt
417cAC                   parm                    $cvtdt
417cD*R                   Z-ADDTODAY     ORUDTE
417cMC                   eval      orudte = $cvd8o
416cAC                   time                    orutim
416cAC                   endif
     C                   write     orrec
     *
     C                   eval      *in32 = *on
650dAc                   if        w3iinv <> 'Y'
650dAc                   else
     C                   eval      #msgk = $rmsg
     C                   exsr      zmqmsg
650dAc                   endif
415bD*R                   MOVE *OFF      REFRSH
415bMC                   move      *on           refrsh
416b C                   move      w2dcde        wodcde
     C                   exsr      scr01i
     *
     C                   endsl
650cAC                   exsr      zzrcvrtnclose
650cAc                   eval      rcvrtncomplete = *off
650cAc                   eval      $lsavetrn = 0
     *
     *
     C     endup3        endsr
     *----------------------------------------------------------------
416i *
416i *  ZZUPD4   Update for screen 4.
     *
416i C     zzupd4        begsr
416i C                   move      *off          error
416iAC                   if        w1rord = 'Y'
416iAC                   move      w1whse        $wwhse
416iAC                   eval      $wrtn = *blanks
416iAC                   move      wslord        $wlord
416iAC                   move      opmput        $wmput
416iAC                   move      w4code        $wcode
416iAC                   move      w4dcde        $wdcde
416iAC                   move      #user         $wusr
416iAC                   move      woord         $wcord
416iAC                   move      woinvf        $winvf
530aAC                   move      w4memo        $wmemo
740aAc                   eval      $pckorg = pckorg
PCKcA*
PCKcAC                   select
PCKcMC                   when      client = sgc
SGCbAC                   move      w4inv#        $winv#
PCKcA*
PCKcAC                   when      client = pack730
PCKcAC                   evalr     $winv# = ' '
PCKcA*
PCKcMC                   endsl
PCKcA*
416iAC                   call      'RN122CL'
416iAC                   parm                    $wwhse
416iAC                   parm                    $wrtn
416iAC                   parm                    $wlord
416iAC                   parm                    $wmput
416iAC                   parm                    $wcode
416iAC                   parm                    $wdcde
416iAC                   parm                    $wusr
416iAC                   parm                    $wcord
416iAC                   parm                    $winvf
520bAC                   parm      $pqck         $wqck
520bAC                   parm      oprexq        $wrexq
530aAC                   parm                    $wmemo
SGCbAC                   parm                    $winv#
740aAC                   parm                    $pckorg
750bAC                   parm      pltlcns       $pltlcns
750bAC                   parm      hldpicklbl    $hldpicklbl
416iAC                   if        $wrtn = '*CANCEL '
416iAC                   move      *off          refrsh
416iAC                   exsr      scr01i
416iAC                   goto      endup4
416iAC                   endif
416i *
730aAc                   call      'RN340'
730aAc                   parm                    w1whse
730aAc                   parm      ' '           $whdp
730aAc                   parm                    w1ord
730aA*
520aAC                   move      *on           refrsh
PCKbAc                   if        *in44 = *on
PCKbAC                   exsr      scr00i
PCKbAc                   else
416iAC                   exsr      scr01i
PCKbAc                   endif
416iAC                   goto      endup4
416iAC                   endif
     *
500aAC                   if        $pqck = 'A'
500aAC                   call      'PIRBAT#'
500aAC                   parm      *zeros        $wbat#            7 0
500aA*                                                                   GFG
500aAC                   move      w6whse        $wwhse
500aAC                   eval      $wrtn = *blanks
500aAC                   move      wslord        $wlord
500aAC                   move      opmput        $wmput
500aAC                   move      w4code        $wcode
500aAC                   move      w4dcde        $wdcde
500aAC                   move      #user         $wusr
500aAC                   move      w6ord         $wcord
500aAC                   move      woinvf        $winvf
500aAC                   move      $wbat#        $wpbat
500aAC                   call      'RN123CL'
500aAC                   parm                    $wwhse
500aAC                   parm                    $wrtn
500aAC                   parm                    $wlord
500aAC                   parm                    $wmput
500aAC                   parm                    $wcode
500aAC                   parm                    $wdcde
500aAC                   parm                    $wusr
500aAC                   parm                    $wcord
500aAC                   parm                    $winvf
500aAC                   parm                    $wpbat
500aAC                   if        $wrtn = '*CANCEL '
500aAC                   move      *off          refrsh
500aAC                   exsr      scr06i
500aAC                   goto      endup4
500aAC                   endif
500a *
500aAC                   exsr      scr06i
500aAC                   goto      endup4
500aAC                   endif
     *
     C     endup4        endsr
500a *----------------------------------------------------------------
500a *
500a *  ZZUPD6   Update for screen 1.
500a *
500a C     zzupd6        begsr
500a C                   move      *off          error
500a C                   eval      w1ord = w6ord
500a *
500a C     endup6        endsr
650fA*----------------------------------------------------------------
650fA*
650fA*  ZZUPD7   Update for screen 7.
650fA*
650fAC     zzupd7        begsr
650fAC                   eval      error = *off
650fAC                   eval      woulbl = w2ulbl
650fA*
650fA*
650fAC     endup7        endsr
650fA*----------------------------------------------------------------
650fA*
650fA*  ZZUPD8   Update for screen 8.
650fA*
650fAC     zzupd8        begsr
650fAC                   eval      error = *off
650fAc                   exsr      zzuci
650fA*
650fAC     endup8        endsr
650fA*----------------------------------------------------------------
650fA*
650fA*  ZZUPD9   Update for screen 9.
650fA*
650fAC     zzupd9        begsr
650fA*
650fAC                   eval      error = *off
650fA* Move mfg or expire or fifo date to keyed in date field
650fA* to send to PO236
650fAC                   eval      woindt = 0
650fAC                   select
650fAC                   when      wofifo <> 0
650fAC                   eval      woindt = wofifo
650fAC                   when      w3mfdt <> 0
650fAC                   eval      woindt = mfgd
650fAC                   other
650fAC                   eval      woindt = expd
650fAC                   endsl
650fAc                   if        $ldecvalue = ' '
650fAc                   exsr      zzmfrdates
650fAc                   endif
650fA*
650fAC                   if        w3iinv = 'N'
650iDC*                  movel     '*NOSTOCK'    $rpo
650iMC                   movel     '*NOSTOCK '   $rpo
650fAC                   move      *off          lcnflg
650fAC                   move      'N'           woulbl
650fAC                   else
650fAC                   eval      $rpo = *blanks
650fAC                   endif
650fAC                   if        w3expd = 0
650fAC                   eval      $rexpd = 0
650fAC                   else
650fAC                   eval      $cvcmd = '*MDYCMD '
650fAC                   move      w3expd        $cvd6i
650fAC                   call      @cvtdt
650fAC                   parm                    $cvtdt
650fAC                   move      $cvd8o        $rexpd
650fAC                   endif
650fA*
650fA*
650fA*  If mispick, create put away for corresponding (physical) item,
650fA*  If mispick will impact inventory, force license entry.
650fAC                   if        w2citm <> *blanks
650fAC                   eval      $ritem = w2citm
650fAC                   if        w3iinv = 'Y'
650fAC                   move      *on           lcnflg
650fAC                   move      'N'           woulbl
650fAC                   endif
650fAC                   else
650fAC                   eval      $ritem = w1item
650fAC                   endif
650fA*
650fAC                   if        client = westside
650fAC                   eval      $rcmd = '*SPRECV'
650fAC                   else
650fAC                   eval      $rcmd = $pcmd
650fAC                   endif
650fAc                   if        $ifrcvmth = '2' or $ifsltmth = '2'
650fAC                   eval      $rcmd = '*RETURN1'
650fAc                   endif
650fA
650fAc                   if        w3iinv <> 'Y'
650fAC                   eval      $lcmd = '*CHANGE '
650fAC                   eval      $lwhse = w1whse
650iDC*                  movel     '*NOSTOCK'    $lpo
650iMC                   movel     '*NOSTOCK '   $lpo
650fAC                   eval      $litem = w1item
650fAC                   eval      $lrq1 = w1qt01
650fAC                   eval      $lrq2 = w1qt02
650fAC                   eval      $lrq3 = w1qt03
650fAC                   eval      $lrpal = 1
650fAC                   z-add     w1ord         $lord
650fA /free
650fA     select;
650fA     when w3iinv = 'N';
650fA       w7lcns  = templcns;
650fA     endsl;
650fA /end-free
650fAC                   call      'RN246L'
650fAC                   parm                    $lparm
650fAC                   parm                    $lord
650fAC                   parm                    wolbl#
650fAC                   parm                    w1cwtr
650fAC                   parm                    expd
650fAC                   parm                    woindt
650fAC                   parm                    wofifo
650fAc                   parm                    $ldecvalue
650fAC                   parm      mexpd         $lmfgex           8 0
650fAC                   parm      mfgdte        $lmfgdt           8 0
650fAC                   parm                    $lsavetrn
650fAC                   parm                    w7lcns           15
650fAC                   parm                    w3lotc           30
650hAC                   parm                    $bcGtin
650hAc                   parm                    $lbcProdD
650hAc                   parm                    $bclot
650iAc                   parm      w3pti         $pw3pti
650dAc                   eval      rcvrtncomplete = *on
650dAc                   else
650fAC                   call      'RC160'
650fAC                   parm                    $rcmd
650fAC                   parm                    $rprg
650fAC                   parm      '*INTER  '    $rtype
650fAC                   parm                    w1whse
650fAC                   parm                    $ritem
650fAC                   parm      w1qt01        w1qty1            5 0
650fAC                   parm      w1qt02        w1qty2            5 0
650fAC                   parm      w1qt03        w1qty3            5 0
650fAC                   parm                    $rpo
650fAC                   parm      0             $rven
650fAC                   parm      *blanks       $rvnam
650fAC                   parm      *blanks       $rvitm
650fAC                   parm      w1ord         $rord
650fAC                   parm                    w1code
650fAC                   parm                    w1memo
650fAC                   parm                    $rexpd
650fAC                   parm      0             $rfifo
650fAC                   parm                    w1dev
650fAC                   parm                    w1form
650fAC                   parm                    w1slot
650fAC                   parm      0             $rseq
650fAC                   parm                    $rrpck
650fAC                   parm                    $rplbl
650fAC                   parm      0             $rdwgt
650fAC                   parm                    $rrq1
650fAC                   parm                    $rrq2
650fAC                   parm                    $rrq3
650fAC                   parm                    $rrpal
650fAC                   parm                    $rrtn
650fAC                   parm                    $rmsg
650fAc                   endif
650fA*
650fA*   What happened with putaway?
650fA*
650fAC                   select
650fA*
650fA*      Error occured.
650fA*
650fA*          $RRTN     IFEQ '*PGMQ   '
650fAC                   when      $rrtn = '*PGMQ   '
650fAC                   move      *on           error
650fAC                   eval      *in24 = *on
650fAC                   eval      *in04 = *on
650fAC                   eval      #msgk = $rmsg
650fAC                   exsr      zmqmsg
650fA*
650fA*      Enter license if LCNFLG is on.                            .
650fA*
650fA*                    ELSE
650fAC                   other
650fA*
650fAC                   if        lcnflg = *on
650fAC                   eval      $lcmd = '*CHANGE '
650fAC                   eval      $lwhse = w1whse
650fAC                   move      w1ord         $lpo
650fAC                   eval      $litem = w1item
650fAC                   eval      $lrq1 = $rrq1
650fAC                   eval      $lrq2 = $rrq2
650fAC                   eval      $lrq3 = $rrq3
650fAC                   eval      $lrpal = $rrpal
650fAC                   z-add     $rord         $lord
650fAc                   if        $ifrcvmth = '2'  or $ifsltmth = '2'
650fAc                   eval      $lcns = w7lcns
650fAc                   endif
650fAC                   call      'RN146'
650fAC                   parm                    $lparm
650fAC                   parm                    $lord
650fAC                   parm                    wolbl#
650fAC                   parm                    w1cwtr
650fAC                   parm                    expd
650fAC                   parm                    woindt            8 0
650fAC                   parm                    wofifo            8 0
650fAc                   parm                    $ldecvalue
650fAC                   parm      mexpd         $lmfgex           8 0
650fAC                   parm      mfgdte        $lmfgdt           8 0
650fAC                   parm                    $lsavetrn
650fAC                   parm                    $lcns            15
650fAC                   parm                    w3lotc
650hAC                   parm                    $bcGtin
650hAc                   parm                    $lbcProdD
650hAc                   parm                    $bclot
650iAc                   parm      w3pti         $pw3pti
650fAC                   endif
650fA*
650fA*      Write expiration/manufacturer date to POMFR file.         .
650fAC                   exsr      zzumfr
650fA*
650fA*      Write to label link file if Label # was entered.          .
650fA*
650fA*
650fAC                   if        wolbl# <> 0
650fAC                   exsr      zzulnk
650fAC                   endif
650fA*      If mispick, create exceptions for item and corresponding  .
650fA*      item if both items have pick slots.
650fA*
650fAC                   eval      exfdis = *blanks
650fAC                   if        w2citm <> *blanks
650fA*
650fAC                   eval      exitem = w1item
650fAC                   eval      excitm = w2citm
650fAC                   eval      exerid = 'MISPICK'
650fAC                   exsr      zzpslt
650fAC                   if        picksl = *off
650fAC                   movel     '*ORDER'      exfdis
650fAC                   exsr      zzexcp
650fAC                   move      w2citm        kyitem
650fAC                   eval      exitem = w2citm
650fAC                   eval      excitm = w1item
650fAC                   eval      exerid = 'MISPICK'
650fAC                   movel     '*PUT  '      exfdis
650fAC                   exsr      zzexcp
650fAC                   else
650fA*       Write adjustment for ordered item.
650fAC                   eval      ajcode = 'MO'
650fAC                   exsr      fill$adj
650fAC                   eval      $dricommand = '*SLOT'
650fAC                   eval      $drisubcmd  = '%ADJUST'
650fAC                   eval      $drisys2upd = 'D'
650fAC                   exsr      zzzdricop
650fA*       Write adjustment for physical item.
650fAC                   move      w2citm        kyitem
650fAC                   eval      ajcode = 'MP'
650fAC                   exsr      fill$adj
650fAC                   eval      $dricommand = '*SLOT'
650fAC                   eval      $drisubcmd  = '%ADJUST'
650fAC                   eval      $drisys2upd = 'D'
650fAC                   exsr      zzzdricop
650fAC                   endif
650fA*
650fAC                   else
650fAC                   if        woinvf = 'Y'
650fAC                   eval      exfdis = *blanks
650fAC                   move      w1item        kyitem
650fAC                   eval      exitem = w1item
650fAC                   eval      excitm = *blanks
650fAC                   eval      exerid = 'INVCTRL'
650fAC                   exsr      zzexcp
650fAC                   endif
650fAC                   endif
650fA*
650fA*      Product put away. Write history record and display message.
650fAC                   clear                   orrec
650fAC                   eval      orwhse = w1whse
650fAC                   eval      orord = w1ord
650fAC                   eval      oritem = w1item
650fAC                   if        w3iinv = 'N'
650fMC                   eval      orqty1 = w1qt01
650fMC                   eval      orqty2 = w1qt02
650fMC                   eval      orqty3 = w1qt03
650fAC                   else
650fAC                   eval      orqty1 = $rrq1
650fAC                   eval      orqty2 = $rrq2
650fAC                   eval      orqty3 = $rrq3
650fAC                   endif
650fAC                   eval      orcwtr = w1cwtr
650fA*    Retrieve current date.
650fAC                   eval      $cvcmd = '*CURCMD '
650fAC                   call      @cvtdt
650fAC                   parm                    $cvtdt
650fAC                   eval      orrdte = $cvd8o
650fAC                   time                    orrtim
650fAC                   eval      orrusr = #user
650fAC                   move      rtntyp        ortype
650fAC                   eval      ortrn# = w1trn#
650fAC                   eval      orpbat = $rord
650fAC                   eval      orcitm = w2citm
650fAC                   eval      orrcod = w1code
650fAC                   eval      ordcod = w2dcde
650fAC                   eval      oriinv = w3iinv
650fAC                   eval      orolb# = wolbl#
650fAC                   move      w2inv#        orinv#
650fAC                   eval      orrmem = w3memo
650fAC                   move      w1slot        orslot
650fAC                   if        $pqck = 'Y'  and
650fAC                             worexq <> 'Y'
650fA*    Retrieve current date.
650fAC                   eval      $cvcmd = '*CURCMD '
650fAC                   call      @cvtdt
650fAC                   parm                    $cvtdt
650fAC                   eval      orudte = $cvd8o
650fAC                   time                    orutim
650fAC                   endif
650fAC                   write     orrec
650fA*
650fAC                   eval      *in32 = *on
650fAc                   if        w3iinv <> 'Y'
650fAc                   else
650fAC                   eval      #msgk = $rmsg
650fAC                   exsr      zmqmsg
650fAc                   endif
650fAC                   move      *on           refrsh
650fAC                   move      w2dcde        wodcde
650fAc                   eval      moretoscan = '0'
650fAc                   eval      w7lcns = ' '
650fAC                   exsr      scr01i
650fA *
650fAC                   endsl
650fA*
650fAC     endup9        endsr
650fA*----------------------------------------------------------------
650fA*
650fA*  ZZUPDCnl Delete scanned records
650fA*
650fA*----------------------------------------------------------------
650fAC     zzupdCnl      begsr
650fAC                   eval      error = *off
650fA*   Remove any LICUCI records
650fA /free
650fA   if moretoscan = *on;
650fA     if *inkj;
650fA       // Delete LICINFO Records
650fA       exsr zzlicinfocan;
650fA
650fA       exsr clr$uciinfo;
650fA
650fA       // warehouse
650fA       $uiWhse = w1whse;
650fA
650fA       // License
650fA       select;
650fA       when w3iinv = 'N';
650fA         $uiLcns = templcns;
650fA       other;
650fA         $uiLcns = w7lcns;
650fA       endsl;
650fA
650fA       $dricommand = '*UCIINFO';
650fA       $drisubcmd  = '%CANCEL';
650fA       $drisys2upd = 'D';
650fA       chk4err = *on;
650fA       zmflag  = *off;
650fA       exsr zzzdricop;
650fA       if error;
650fA       endif;
650fA       moretoscan = *off;
650fA       //$puci = ' ';
650fA       w1uci = ' ';
650fA       w7lcns = ' ';
650fA       //templcns = ' ';
650fA       //ovrrid = *off;
650fA       //$pexpdt = 0;
650fA       //$pwgt = 0;
650fA       //$pmfgdt = 0;
650fA       //$plot = ' ';
650fA     endif;
650fA   endif;
650fA
650fA /end-free
650fAC     endupCnl      endsr
     *----------------------------------------------------------------*********
415aA*
415aA*  ZZULNK   Update for LABELNK FILE
415aA*
415aAC     zzulnk        begsr
415aA*
415aA*
415aA*      Write to label link file if Label # was entered.          .
415aA*
     *
415aAC                   if        wolbl# <> 0
415aAC     partk2        setll     label2
415aAC                   move      *off          stop
415aAC                   dou       stop = *on
415aAC     partk2        reade     label2                                 79
415aAC                   if        *in79
415aAC                   move      *on           stop
415aAC                   else
415aAC                   eval      lllblo = wolbl#
415aAC                   eval      lllbl# = lblbl#
415aAC                   eval      lltrn# = lbtrn#
415aAC                   eval      llqpck = lbqpck
415aAC                   eval      llucod = lbucod
415aAC                   write     llrec
415aAC                   endif
415aAC                   enddo
415aAC                   endif
415aAC     endlnk        endsr
650fA*----------------------------------------------------------------
650fA*
650fA*  ZZCHKLCNS  Check for active license
650fA*
650fAC     zzchklcns     begsr
650fAC                   eval      lcnsExists = *off
650fA
650fA*  See if license exists in licactive file.
650fA
650fAC                   exsr      clr$license
650fAC                   eval      $liToLcnsU = *on
650fAC                   eval      $liToLcns = w7lcns
650fAC                   eval      $dricommand = '*LICENSE'
650fAC                   eval      $drisubcmd  = '%GETLCNS'
650fAC                   eval      $drisys2upd = 'D'
650fAC                   eval      chk4err = *off
650fAC                   eval      zmflag  = *off
650fAC                   exsr      zzzdricop
650fAC                   if        error
650fAC                   eval      lcnsExists = *off
650fAC                   eval      error = *off
650fAC                   leavesr
650fAC                   else
650fAC                   eval      lcnsExists = *on
650fAC                   eval      error = *on
650fAC                   eval      *in43 = *on
650fAc                   eval      errmsg= desc(16)
650fAc                   exsr      zm02
650fAC                   endif
650fA
650fA
650fAC                   endsr
650fA*----------------------------------------------------------------
650fA*  clr$item  Clear $item data structure fields
650fA*----------------------------------------------------------------

650fAC     clr$item      begsr
650fAC                   eval      savever# = $itver#
650fAC                   clear                   $item
650fAC                   clear                   $item2
650fAC                   eval      $itver# = savever#
650fAC                   endsr

650fA*----------------------------------------------------------------
650fA*  clr$license  Clear $license data structure fields
650fA*----------------------------------------------------------------
650fA
650fAC     clr$license   begsr
650fAC                   eval      savever# = $liver#
650fAC                   clear                   $license
650fAC                   eval      $liver# = savever#
650fAC                   eval      $liemp# = $emp#
650fAC                   eval      $liuser = #user
650fAC                   eval      $lipgm  = #prog
650fAC                   eval      $lijob  = #job
650fAC                   eval      $lijobn = #jobn
650fAC                   eval      $liTowhse = w1whse
650fAC                   eval      $liTowhseu = *on
650fAC                   endsr
650fA*----------------------------------------------------------------
650fA*  clr$licinfo  Clear $licinfo data structure fields
650fA*----------------------------------------------------------------
650fA
650fAC     clr$licinfo   begsr
650fAC                   eval      savever# = $lnver#
650fAC                   clear                   $licinfo
650fAC                   clear                   $licinfo2
650fAC                   eval      $lnver# = savever#
650fA
650fAC                   eval      $lnuser = #user
650fAC                   eval      $lnemp# = $emp#
650fAC                   eval      $lnpgm  = #prog
650fAC                   eval      $lnjob  = #job
650fAC                   eval      $lnjobnbr = #jobn
650fA
650fAC                   endsr
650fA*----------------------------------------------------------------
650fA*  clr$uciinfo  Clear $uciinfo data structure fields
650fA*----------------------------------------------------------------
650fA
650fAC     clr$uciinfo   begsr
650fAC                   eval      savever# = $uiver#
650fAC                   clear                   $uciinfo
720eAC                   clear                   $uciinfo2
650fAC                   eval      $uiver# = savever#
650fAC                   eval      $uiaddemp = $emp#
650fAC                   eval      $uiaddusr = #user
650fAC                   eval      $uiaddpgm  = #prog
650fAC                   eval      $uiaddjob  = #job
650fAC                   eval      $uiaddnbr = #jobn
650fAC                   endsr
     *----------------------------------------------------------------
500d *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

500d C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
416cAC                   eval      $dridata2 = $item2
650fAC                   when      $dricommand = '*LICENSE'
650fAC                   eval      $dridata = $license
650fAC                   eval      $dridata2 = $license2
650fAC                   when      $dricommand = '*LICINFO'
650fAC                   eval      $dridata = $licinfo
650fAC                   eval      $dridata2 = $licinfo2
650fAC                   when      $dricommand = '*UCIINFO'
650fAC                   eval      $dridata = $uciinfo
720eAC                   eval      $dridata2 = $uciinfo2
     C                   endsl

416cAC                   select

416cAC                   when      $dricommand = '*ITEM'
650fAC                             or $dricommand = '*LICENSE'
650fAC                             or $dricommand = '*LICINFO'
720eAC                             or $dricommand = '*UCIINFO'
416cAC                   call(e)   'DRICOP'
416cAC                   parm                    $dricommand
416cAC                   parm                    $drisubcmd
416cAC                   parm                    $drisys2upd
416cAC                   parm      #prog         $driprogram
416cAC                   parm      ' '           $drireturn
416cAC                   parm      ' '           $drimessage
416cAC                   parm                    $dridata
416cAC                   parm                    $dridata2
416cA
416cAC                   other
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
416cA
416cAC                   endsl

     C                   select

650fDC*                  when      %error
650fMC                   when      chk4err and %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
500d C*                  if        zmsflag
500d C*                  exsr      zm0105s
500d C*                  else
     C                   exsr      zm0105
500d C*                  endif

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C*                  if        zmsflag
     C*                  exsr      zm0001s
     C*                  else
650fAc                   if        zmflag
     C                   exsr      zm0001
     C                   exsr      zzerrind
650fAc                   endif
     C*                  endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
416cAC                   eval      $item2 = $dridata2
650fAC                   when      $dricommand = '*LICENSE'
650fAC                   eval      $license = $dridata
650fAC                   eval      $license2 = $dridata2
650fAC                   when      $dricommand = '*LICINFO'
650fAC                   eval      $licinfo = $dridata
650fAC                   eval      $licinfo2 = $dridata2
650fAC                   when      $dricommand = '*UCIINFO'
650fAC                   eval      $uciinfo = $dridata
720eAC                   eval      $uciinfo2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
     C     enddricop     endsr

500d *----------------------------------------------------------------
500d *  fill$adj   Fill $slot data structure fields for adjustment.
500d *----------------------------------------------------------------
500d
500d C     fill$adj      begsr
500d
500d *  Initialize data structure
500d
500d C                   eval      savever# = $slver#
500d C                   clear                   $slot
500d C                   eval      $slver# = savever#
500d
500d *  Move fields from record to data structure.
500d
500d C                   eval      $slwhseu = *on
500d C                   eval      $slwhse  = w1whse
500d
500d C                   eval      $slwhdpu = *on
500dAC     itkey         chain     piritem                            79
500dAC                   if        not *in79
500dAC                   eval      $slwhdp = itwhdp
500dAC                   else
500dAC                   eval      $slwhdp = *blanks
500dAC                   endif
500d C**                 eval      $slwhdp  = $pwhdp
500d
500d C                   eval      $sldispu = *on
500bAC                   if        ajcode = 'MO'
500d C                   eval      $sldisp  = oslot
500bAC                   else
500b C                   eval      $sldisp  = pslot
500bAC                   endif
500d
500d C                   eval      $saitemu = *on
500eAC                   if        ajcode = 'MO'
500eDC*                  eval      $saitem  = kyitem
500eMC                   eval      $saitem  = exitem
500eAC                   else
500eAC                   eval      $saitem  = excitm
500eAC                   endif
500d
500d C                   eval      $saqtyu  = *on
500bAC                   if        ajcode = 'MO'
500d C                   eval      $saqty1  = w1qt01
500d C                   eval      $saqty2  = w1qt02
500d C                   eval      $saqty3  = w1qt03
500bAC                   else
500bDC                   eval      $saqty1  = w1qt01 * -1
500bDC                   eval      $saqty2  = w1qt02 * -1
500bDC                   eval      $saqty3  = w1qt03 * -1
500bAC                   endif
500d
500d C                   eval      $sacwtau = *on
500d C                   eval      $sacwta  = 0
500d
500d C                   eval      $sacodeu = *on
500d C                   eval      $sacode  = ajcode
500d
500d C                   eval      $samemou = *on
500d C                   eval      $samemo  = ' '
500d
500d C                   eval      $sabyu   = *on
500d C                   eval      $saby    = 'RTN'
500d
500d C                   endsr
500d
PCKaA*----------------------------------------------------------------
PCKaA*
PCKaA*  ZZCKDUPORD    Check for duplicate customer orders.
PCKaA*
PCKaAC     zzckdupord    begsr
PCKaA*
PCKaAC                   eval      option = *blanks
PCKaAC                   eval      *in21 = *off
PCKaA*
PCKaAC                   eval      recno6 = *zeros
PCKaA*
PCKaA*    Find out if customer order number exists on more than 1 order.
PCKaA*    If the item is on only ONE order, Then proceed w/o displaying w
PCKaA*    and item.
PCKaAC                   eval      n = 1
PCKaAC                   eval      ttlrcd = *zeros
PCKaA /free
PCKaA   setll (w1whse: w1ord) ordh5;
PCKaA   dow forevr = forevr;
PCKaA     reade (w1whse: w1ord) ordh5;
PCKaA /end-free
PCKaA*
PCKaAC                   if        not %eof(ordh5)
PCKaAC     rhkey         chain     rtehed
PCKaAC                   if        not %found(rtehed)
PCKaAC                   eval      rhrte  = ' '
PCKaAC                   eval      rhrtid = ' '
PCKaAC                   eval      rhimpd = 0
PCKaAC                   endif
PCKaAC                   endif
PCKaA*
PCKaAC                   select
PCKaAC                   when      %eof(ordh5)
PCKaAC                   leave
PCKaA*
PCKaAC                   when      not %eof(ordh5) and
PCKaAC                             n = 1
PCKaA*
PCKaAC                   select
PCKaA*      2000 = Packer's route
PCKaAC                   when      pckorg =  2000
PCKaAC                             and (rhrte >= '00001' and rhrte <= '00099'
PCKaAC                             or   rhrte = '99    ' and rhtype = 'W')
PCKaA*      2100 = LeGrand route
PCKaAC                             or pckorg =  2100
PCKaAC                             and (rhrte >= '00100' and rhrte <= '00199'
PCKaAC                             or   rhrte = '199   ' and rhtype = 'W')
PCKaAC                   eval      ttlrcd = ttlrcd + 1
PCKaAC                   endsl
PCKaA*
PCKaA*    Customer Order linked to more than 1 order id.
PCKaAC                   when      n = 2
PCKaAC                   if        %eof(ordh5)
PCKaAC                   eval      ttlrcd = 1
PCKaAC                   else
PCKaA*
PCKaAC                   select
PCKaA*      2000 = Packer's route
PCKaAC                   when      pckorg =  2000
PCKaAC                             and (rhrte >= '00001' and rhrte <= '00099'
PCKaAC                             or   rhrte = '99    ' and rhtype = 'W')
PCKaA*      2100 = LeGrand route
PCKaAC                             or pckorg =  2100
PCKaAC                             and (rhrte >= '00100' and rhrte <= '00199'
PCKaAC                             or   rhrte = '199   ' and rhtype = 'W')
PCKaAC                   eval      ttlrcd = ttlrcd + 1
PCKaAC                   endsl
PCKaA*
PCKaAC                   endif
PCKaA*
PCKaAC                   endsl
PCKaAC                   enddo
PCKaA*
PCKaAC                   select
PCKaA*
PCKaA*    Duplicate Customer Orders. Display select window.
PCKaAC                   when      ttlrcd > 1
PCKaA*
PCKaAC                   eval      w6title = title04
PCKaAC                   write     window6
PCKaA*    Clear subfile.
PCKaAC                   eval      *in01 = *off
PCKaAC                   write     dspsfc6
PCKaAC                   eval      *in01 = *on
PCKaAC                   eval      *in41 = *on
PCKaAC                   eval      slctxt = 'Order:'
PCKaAC                   eval      slcval = %editc(w1ord:'4')
PCKaA*
PCKaA*    Fill subfile.
PCKaA /free
PCKaA   setll (w1whse: w1ord) ordh5;
PCKaA   dow forevr = forevr;
PCKaA     reade (w1whse: w1ord) ordh5;
PCKaA /end-free
PCKaAC                   select
PCKaAC                   when      %eof(ordh5)
PCKaAC                   leave
PCKaA*
PCKaAC                   other
PCKaA*
PCKaAC     rhkey         chain     rtehed
PCKaAC                   if        not %found(rtehed)
PCKaAC                   eval      rhrte  = ' '
PCKaAC                   eval      rhrtid = ' '
PCKaAC                   eval      rhimpd = 0
PCKaAC                   endif
PCKaA*
PCKaAC                   select
PCKaA*      2000 = Packer's route
PCKaAC                   when      pckorg =  2000
PCKaAC                             and (rhrte >= '00001' and rhrte <= '00099'
PCKaAC                             or   rhrte = '99    ' and rhtype = 'W')
PCKaA*      2100 = LeGrand route
PCKaAC                             or pckorg =  2100
PCKaAC                             and (rhrte >= '00100' and rhrte <= '00199'
PCKaAC                             or   rhrte = '199   ' and rhtype = 'W')
PCKaAC                   exsr      zzfil6P
PCKaAC                   exsr      sfladd6
PCKaAC                   endsl
PCKaA*
PCKaAC                   endsl
PCKaA*
PCKaAC                   enddo
PCKaA*
PCKaA*    Now that subfile is loaded, Display it to the user.
PCKaAC                   exsr      zzwdw6
PCKaA*
PCKaAC                   endsl
PCKaA*
PCKbBc                   eval      *in01 = *off
PCKbBc                   eval      *in21 = *off
PCKbBc                   eval      *in41 = *off
PCKaAC                   endsr
PCKaA*
PCKaA*----------------------------------------------------------------
PCKaA*
PCKaA*  ZZWDW6   Display window for selection of Duplicate Customer Order
PCKaA*
PCKaAC     zzwdw6        begsr
PCKaA*
PCKaAC                   if        recno6 = *zeros
PCKaAC                   write     blank64
PCKaAC                   eval      *in56 = *on
PCKaAC                   else
PCKaAC                   eval      *in56 = *off
PCKaAC                   endif
PCKaA*
PCKaAC                   eval      *in57 = *on
PCKaAC                   dow       forevr = forevr
PCKaA*
PCKaA*   Overlay screen with error messages
PCKaAC                   exsr      zmdms6
PCKaA*
PCKaAC                   exfmt     dspsfc6
PCKaA*
PCKaA*   Initialize error subfile
PCKaAC                   exsr      zmcms6
PCKaA*
PCKaAC                   select
PCKaA*    F3/F12=Cancel selected.
PCKaAC                   when      *inkc
PCKaAC                             or *inkl
PCKaAC                   eval      error = '1'
PCKaAC                   eval      *inkc = '0'
PCKaAC                   eval      *inkl = '0'
PCKaAC                   leave
PCKaA*
PCKaA*    F5=Refresh selected.
PCKaAC                   when      *inke
PCKaAC     1             do        05            x
PCKaAC     x             chain     dspsfl6                            79
PCKaAC                   if        not *in79
PCKaAC                   eval      option = '  '
PCKaAC                   update    dspsfl6
PCKaAC                   endif
PCKaAC                   enddo
PCKaA*
PCKaAC                   other
PCKaA*
PCKaA*    Process subfile.
PCKaAC                   exsr      zzwdw61
PCKaA*
PCKaA*    User selected record from list.
PCKaAC                   if        optslt = *on  and
PCKaAC                             error = *off
PCKaAC                   leave
PCKaAC                   endif
PCKaA*
PCKaAC                   endsl
PCKaAC                   enddo
PCKaA*
PCKaAC                   endsr
PCKaA*
PCKaA*----------------------------------------------------------------
PCKaA*
PCKaA*  ZZWDW61   Process subfile looking for selection.
PCKaA*
PCKaAC     zzwdw61       begsr
PCKaA*
PCKaA*    Read ONLY the changed options.
PCKaAC                   eval      error = *off
PCKaAC                   eval      nrslct = *zeros
PCKaAC                   eval      optslt = *off
PCKaAC                   dow       forevr = forevr
PCKaAC                   readc     dspsfl6                                79
PCKaAC                   select
PCKaAC                   when      *in79 = '1'
PCKaAC                   leave
PCKaA*
PCKaAC                   other
PCKaA*
PCKaA*    Display error if option is not valid.
PCKaAC                   if        option <> *blanks
PCKaAC                   eval      *in21 = *on
PCKaAC                   update    dspsfl6
PCKaA*
PCKaA*    Look up option in profile - Error if not found.
PCKaAC     option        lookup    zopt6                                  50
PCKaAC                   if        not *in50
PCKaAC                   eval      error = *on
PCKaAC                   eval      errmsg = *blanks
PCKaAC                   exsr      z60108
PCKaAC                   endif
PCKaA*
PCKaA*    Count number of entries when Option=1
PCKaAC                   if        option = '1'
PCKaAC                   add       1             nrslct
PCKaAC                   eval      w1ord   = Hcord
PCKaAC*                  eval      kyordid = Hordid
PCKaA*    If number selected greater than 1, Then display message.
PCKaAC                   select
PCKaAC                   when      nrslct = 1
PCKaAC                   eval      optslt = *on
PCKaA /free
PCKaA   chain (w1whse: w1ord: Hordid) ordh5;
PCKaA /end-free
PCKaAC                   if        %found(ordh5)
PCKaAC     rhkey         chain     rtehed
PCKaAC                   if        not %found(rtehed)
PCKaAC                   eval      rhrte  = ' '
PCKaAC                   eval      rhrtid = ' '
PCKaAC                   eval      rhimpd = 0
PCKaAC                   endif
PCKaAC                   endif
PCKaA*
PCKaAC                   when      nrslct >= 2
PCKaAC                   eval      error = *on
PCKaAC                   eval      errmsg = err01
PCKaAC                   exsr      z60105
PCKaAC                   eval      optslt = *off
PCKaAC                   endsl
PCKaAC                   endif
PCKaAC                   endif
PCKaA*
PCKaAC                   endsl
PCKaAC                   enddo
PCKaA*
PCKaAC                   endsr
PCKaA*
PCKaA*----------------------------------------------------------------
PCKaA*
PCKaA*  SFLADD6   Add record to Window subfile 6
PCKaA*
PCKaAC     sfladd6       begsr
PCKaA*
PCKaAC                   add       1             recno6
PCKaAC                   write     dspsfl6
PCKaA*
PCKaAC                   endsr
PCKaA*----------------------------------------------------------------
PCKaA*
PCKaA*    ZMCMS6  Clear message record subfile in WINDOW6
PCKaA*
PCKaAC     zmcms6        begsr
PCKaAC                   eval      *in97 = *off
PCKaAC                   write     msgctl6
PCKaAC                   eval      msgk6 = *zeros
PCKaAC                   eval      #msgid = '*CLEAR '
PCKaAC                   eval      #msgtp = '*NULL  '
PCKaAC                   exsr      zmpms6
PCKaAC                   endsr
PCKaA*----------------------------------------------------------------
PCKaA*
PCKaA*    ZMDMS6  Display message record subfile in WINDOW6
PCKaA*
PCKaAC     zmdms6        begsr
PCKaAC                   write     msgclr6
PCKaAC                   eval      *in97 = *on
PCKaAC                   if        msgk6 > 0
PCKaAC                   write     msgctl6
PCKaAC                   eval      msgk6 = *zeros
PCKaAC                   endif
PCKaAC                   endsr
PCKaA*
PCKaA*----------------------------------------------------------------
PCKaAC     z60105        begsr
PCKaAC                   eval      #msgid = 'PIR0105'
PCKaAC                   eval      #msgtp = '*DIAG  '
PCKaAC                   movea     errmsg        $md(1)
PCKaAC                   exsr      zmpms6
PCKaAC                   endsr
PCKaA*----------------------------------------------------------------
PCKaA*      0108  Invalid Option.
PCKaA*
PCKaA*    Error message for WINDOW6.
PCKaA*
PCKaAC     z60108        begsr
PCKaAC                   eval      #msgid = 'PIR0108'
PCKaAC                   eval      #msgtp = '*DIAG  '
PCKaAC                   movel     option        errmsg
PCKaAC                   movea     errmsg        $md(1)
PCKaAC                   exsr      zmpms6
PCKaAC                   endsr
PCKaA*
PCKaA*----------------------------------------------------------------
PCKaA*
PCKaA*    ZMPMS6  Add message record to subfile in WINDOW6
PCKaA*
PCKaAC     zmpms6        begsr
PCKaAC                   if        $msgf = *blanks
PCKaAC                   eval      $msgf = #msgf
PCKaAC                   endif
PCKaAC                   call      'PUTMSG'
PCKaAC                   parm                    $msgf
PCKaAC                   parm                    #msgid
PCKaAC                   parm                    #msgtp
PCKaAC                   parm                    #msgdt
PCKaAC                   parm      #prog         #pgmq
PCKaAC                   parm                    #msgk
PCKaAC                   if        #msgid <> '*CLEAR '
PCKaAC                   add       1             msgk6
PCKaAC                   write     msgrec6
PCKaAC                   endif
PCKaAC                   eval      #msgdt = *blanks
PCKaAC                   eval      $msgf = *blanks
PCKaAC                   endsr
PCKaA*
PCKaA*----------------------------------------------------------------
PCKaA*
PCKaA*  ZZFIL6P  Fill window subfile with info from file.
PCKaA*
PCKaAC     zzfil6P       begsr
PCKaA*
PCKaA*      Populate hidden subfile fields.
PCKaAC                   eval      hordid = ohord
PCKaAC                   eval      Hcord  = ohcord
PCKaA*
PCKaA*      Populate displayed subfile fields.
PCKaAC                   eval      wocnam = ohcnam
PCKaA*      Convert Import Date into mm/dd/yy format.
PCKaAC                   eval      $cvcmd = '*CMDMDY '
PCKaAC                   eval      $cvd8i = %editc(rhimpd:'X')
PCKaAC                   call      @cvtdt
PCKaAC                   parm                    $cvtdt
PCKaAC                   eval      woimpd = $cvd6o
PCKaAC                   eval      worte  = rhrte
PCKaAC                   eval      wortid = ohrte
PCKaAC                   eval      wocust = ohcust
PCKaA*
PCKaAC                   endsr
PCKaA*
     *
     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
**
Order Number
Quantity Returned
Printer Device
Printer Form
Catch weight
Label #
Use label for putaway
Impact inventory
Mfg Code/Vendor item#
Return whole order
Coresponding item
Customer #
Invalid Label#
item, it is discontinued
Use full returns
License
UCI Barcode
Different Item on UCI
PTI Code
Only numbers allowed
Customer order # is invalid
Order # > 7 not allowed
item, item not on Cust Order
**  HED
Customer Returns
Transfer Returns
POS Returns
Quick Returns Putaway
**  ZOPT6 - Valid options for WINDOW6
1
