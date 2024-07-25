610bA /copy *libl/qcopysrc,hspecs
650mAH dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PO120     PO detail maintenance - Display
     *  08 October, 1996
     *  Hemant Kapadia
     *
     *  SK110 - 1.01
     *
     *----------------------------------------------------------------
     *  Revisions
     *
416 A*    11/26/01  MLBm 4.16
     *      - Added support to program for Super P/O's.
     *      - Revised program to combine support for Mfr nbr order.
     *      - Major modifications, code cleaned up, new code not id.
416aA*    12/04/01  MLB  4.16a
     *      - Revised ZZWDW3 to load hold fields from subfile into
     *        DSUKEY fields when record is selected.
416bA*    12/20/01  MLB  4.16b
     *      - Revised ZZOPT to unlock PORCV if record found.
416cA*    12/21/01  MLB  4.16c
     *      - Revised ZZWDW to not display position to window for
     *        items or mfg# when only one record in subfile.
     *        If no items/mfg# are loaded into position to subfile,
     *        send message and don't display window.
416dA*    12/27/01  MLB  4.16d
     *      - Revision to above modification.  If the item/mfg# is
     *        found on only one p/o in the Super P/O, then position
     *        to the item and do not display the window.  If the item/
     *        mfg# not found, then display the window if values found
     *        that are greater than the value keyed in.
416eA*    05/23/02  RH   4.16e
    A*      - PORCV file changed, initialize POREDT and PORETI.
416fA*    10/31/02  HNK  4.16f
    A*      - Get putaway method from DEPTDSG file.  Use opposite
     *        method if record found in this file.
     *
417 A*    03/25/03  MLB  4.17
     *      - Enh: Added new option #14 Rcv exceptions.  This will
     *        allow users to log receiving exceptions for shorts/outs
     *        damages etc.
417aA*    04/03/03  RH   4.17a
     *      - Enh: Allow multiple items for one UPC code.
     *        Display window to select or mark for exception.
417bA*    04/15/03  MLB  4.17b
     *      - Enh: Extended length of W1UPC to 50 characters and
     *        renamed field W1UPCD.
417cA*    05/21/03  RH   4.17c
     *      - Enh: Only create one exception per item for multiple UPC
417dA*    05/21/03  RH   4.17d
     *      - Enh: Write UPC code to EXFDIS & EXTDIS using data struct
417eA*    05/23/03  MLB  4.17e
     *      - Enh: Create new option array ZOPT6 for DSPSFL6 subfile.
417fA*    06/02/03  RH   4.17f
     *      - FIX: Process 'X' options first, then '1' for select on
     *        window 6 (multiple UPC codes). Was not creating
     *        exception when X and 1 were entered at the same time.
417gA*    06/05/03  RH   4.17g
     *      - FIX: Allow selection of UPC on window.  Was loosing key
     *        $KPO when UPC item was not on PO.
417hA*    06/09/03  RH   4.17h
     *      - FIX: Right adjust UPC code after CVTBAR even if invalid.
417iA*    07/07/03  RH   4.17i
     *      - FIX: Set OPTSLT, was not selecting when 1 UPC was found.
417jA*    08/21/03  MLB  4.17j
     *      - Fix: Set OPTSLT. Was not selecting when 1 UPC was found
     *        when processing Super P/O's.
417kA*    04/20/04  RH   4.17k
     *      - ENH: Add F7 for Subtotal to PO120 for normal PO.
     *             Add DSPFSC7 for window4
417lA*    04/26/04  RH   4.17l
     *      - ENH: Add F8 for item subtotal to PO120 for Super PO
     *             Add DSPFSC8 for window4
     *      - ENH: Change F7 to F8 for item subtotal for normal PO.
417mA*    05/04/04  RH   4.17m
     *      - Fix: Set W1UPC = blanks if UPC was not found for item on
     *             PO or selected from window.
417nA*    05/12/04  RH   4.17n
     *      - FIX: Chain to DSPSFL2 not DSPSFL before update.
417oA*    08/18/04  MLB  4.17o
     *      - Fix: Revise routine ZZWDW to setof *IN21. This indicator
     *        is used to flag SFLNXTCHG on subfile records. It was not
     *        being reset between windows.
500 A*    01/18/05  RH   5.00
     *      - Fix: Add code to ZZCMD that was missed in 417 update.
500aA*    12/27/04  RH   5.00a
     *      - Enh: Add $CMD to allow *SPRECV directed put away to
     *        pick slot with no license.
500bA*    12/29/04  RH   5.00b
     *      - Enh: Disable option 7 Quick receive. Option doesn't work
     *        Removed from option display and option table at bottom.
500cA*    12/30/04  DAS  5.00c
     *      - Enh: For *SPRECV, displaying 1=StuffIt Rcv.
500dA*    03/21/05  RH   5.00d
     *      - Missed 417m change in V4.17 update, line 4325
500eA*    04/01/05  RH   5.00e
     *      - Add F11 to view un-checked lines only.
500fA*    09/07/05  MLB  5.00f
     *      - Fix: Revised ZZCHEK to remove requirement that item
     *        types: A,B,S or C, parent item must have a pick slot.
500gA*    10/23/05  JCJ  5.00g
     *      - Add HACCP edits with PO170.
510 A*    09/21/06  JCJ  5.10
     *      - Enh: Revised program to add support for Client id
510aA*    12/06/06  RH   5.10A
     *      - Enh: Remove BFCADR, no long used.
510bA*    12/13/07  RBD  5.10b
     *      - Enh: Added PO seq to scrn dspsfl and reduced the size
     *        of WOQOR and WOQRC from 15 to 12 to make room.
     *      - Revised standard option list ZOPT to not include option
     *        10, added option list ZOPTP for Packers which does include
     *        option 10, revised option edit accordingly.
     *
520 A*    09/25/08  CWM  5.20
     *      - Added Total Weight Received next to total qty.
520aA*    12/15/08  MLB  5.20a
     *      - Enh: Revised program to add support to display item message
     *        info sent by Host. Item msg will be sent in PODTLM file in
     *        field PDMPOM. Added new screen, WDWSC10 to display msg.
     *        Item number will be reverse image when note found for item.
     *      - Revised arrays, OPTLN, OPTLNP,OPTLNS to add opt# 7=Item msg.
     *      - Revised arrays, ZZOPT, ZZOPTP to add 7 as valid option.
     *      - Added file, PODTLM.
530aA*    11/11/10  RH   5.30a
     *      - Fix:  Write PORCV record & mark as touched on backorder
     *        when seq # was previously exported.
     *        Was preventing PO detail line for backorder to be touched.
610aA*    08/20/09  DAS  6.10a
     *      - Enh: Added option RC to call LT330 Recall Listing
     *             Converted to RPGLE
610bA*    08/14/09  GJA  6.10b
     *      - Enh: Add option 18 to reprint produce labels
     *             Converted to RPGLE
610cA*    08/26/09  RH   6.10c
     *      - Enh:  Change Stuffit to PICKSLT Pick Slot Receiving.
610dA*    09/04/09  RH   6.10d
     *      - Fix:  Send itdesc to print produce labels, was using
     *        wrong value.
610eA*    10/28/10  RH   6.10e
     *      - Fix:  Postion to received item.
     *
640 A*    01/13/11  MLB  6.40
     *      - Revised 5.30a mod to eliminate duplicated code.
     *        Duplicated code removed from pgm.
     *
640a *    08/01/11  GJA  6.40a
     *      - Enh:  Add F10 to show detail lines with qty discrepancy.
     *
640b *    10/03/11  GJA  6.40b
     *      - Fix:  Showing window6 when UPC had same item, show only
     *              display when there are different item numbers
640c *    06/04/12  RH   6.40c
     *      - Fix:  Remove 15=Item msg from OPTLNS and OPTLNP,
     *              7 is used.
640d *    07/31/12  LMC  6.40d
     *      - Enh:  Added LPN scanning ability, pass parms to PO232
     *      - Fix:  init svupci to blanks to allow the same upc to
     *              be scanned one after another.
640e *    08/16/12  LMC  6.40e
     *      - Enh:  Added GS1 multiple scanning process
     *      - Enh:  Changed display file to PO12004
640f *    04/19/12  LMC  6.40f
     *      - Enh:  Added new HACCP Processing.
     *              Remove old HACCP PO170 processing.
640g *    11/14/12  LMC  6.40g
     *      - Fix:  replaced UPC with UCI on F9 PO/MFG Code
     *      - Fix:  MJK scanning valid UPC, when cvtbar returned invalid
     *              GTIN - upc scanned was being cleared. w1upcd is now
     *              loaded with w1uci if invalid gtin is encountered.
     *      - Enh:  replaced PO12004 with PO12005
640h *    12/12/12  LMC  6.40h
     *      - Fix:  If NO Gtin is retrieve from barcode scan. Clear
     *      all other SENT fields from the CVTBAR *all.
640i *    12/14/12  LMC  6.40i
     *      - Fix:  Remove the zzchk1 check if the w1upcd field is not
     *      blank, this should be conditioned on w1uci or w1asn only.
     *      w1upcd was replaced with w1uci.
650aA*    03/22/13  LMC  6.50a
     *      - Enh: Add logic for passing parms needed for haccp cross
     *      reference file.
650bA*    04/15/13  LMC  6.50b
     *      - Enh: Add logic calling haccp on option 14 - exception
650cA*    04/15/13  LMC  6.50c
     *      - Enh: Check for the existence of haccp questions
650dA*    05/15/13  LMC  6.50d
     *      - Enh: Added RCVPO transaction.
650eA*    06/27/13  LMC  6.50e
     *      - Enh: Made GLPa mod a standard mod.
650fA*    10/03/13  LMC  6.50f
     *      - Fix: When entering haccp exceptions from a super po
     *        job was encountering a dec data error because the actual
     *        PO was not being sent to HA410.
650hA*    06/27/13  LMC  6.50h
     *      - Enh: PTI logic.
     *      - Enh: Added parm to pass GTIN/LOT and MFG DATE if
     *      extracted from the barcode to pass to PO132/PO232 for PTI.
     *      - Enh: Added and edit in ZZCHEK for items with selection
     *      method = 3 PTI selection.
     *      These items cannot be selected from the subfile. The
     *      receipt of these items must be started by scanning UCI.
     *      This is required so we can calculate the PTI needed at
     *      selection time.
     *      - Enh: Added a chain(no lock) to pohdr in order to get
     *      vendor number for the po, this is needed because CVTBAR
     *      has some client code specific to vendor on the size of
     *      the lot number field. This only occurs if a normal PO
     *      is being processed. Cannot determine vendor on super Po
     *      until the GTIN is identified in CVTBAR and it is too late
     *      at that point to know which vendor. If we determine this
     *      needs to also be done on super PO. We will need to add an
     *      additional call to CVTBAR once we know the PO/Vendor.
650iA*    12/09/13  LMC  6.50i
     *      - Fix: remove the call to UC112 at this time.
650jA*    01/23/14  RH   6.50j
     *      - Fix: Add missing 610f code below.
     *    10/01/09  GJA  6.10f
     *      - Enh: Create one spool file for produce labels
650kA*     04/11/14  RH   6.50k
     *       - Fix: Update PO header status to partial when line
     *         is marked with 'X' to allow export of PO with 0 receive
650lA*    06/05/14  LMC  6.50l
     *      - Enh: New internal off site storage.
     *        Allows for entry of options 1* * being a letter.
     *        The letter is passed to PO237/PO232 to designate
     *        user is doing OSS receiving.
650mA*    09/08/14  LMC  6.50m
     *      - Enh: Add program tracking.
     *        Data area PGMTRACK has been created to control whether
     *        log records should be written to file PGMTRCK.
     *        Records are written to the file when the data are
     *        contains a '1'.
650nA*    09/11/14  LMC  6.50n
     *      - Fix: Logic was forcing uci receiving when uci selection
     *        was turned on.
650oA*    09/23/14  LMC  6.50o
     *      - Enh: Do not pass the weight from the UCI scan unless UCI
     *        receiving is turned on. Complaints that the users are
     *        not being forced to enter a total weight, and just F20
     *        out of habit.
650pA*     07/25/14  LMC  6.50p
     *       - Enh: Added option RW to view Receiving weights by
     *         calling program UI320.
650qA*     12/31/14  MLB  6.50q
     *       - Fix: Revised routine ZZCHKUPC to use LF, UPC4 instead
     *         of UPC so that rcds are processed in upc/item seq.
650sA*     02/16/15  LMC  6.50s
     *       - Enh: Xdock wins over directed putaway. If the pdspcl
     *         field has 'XD' we will use PO232 instead of PO132.
     *         All the logic for cross dock already exist in PO236
     *         this will no longer call PO132 eliminating the need
     *         to change RC160 to handle our new cross dock rules.
700aA*     10/05/15  LMC/RH  7.00a
     *       - Fix: Clear W1UCI if scan not started in postion 1
700bA*    03/09/16  LMC  7.00b
     *      - Enh: Load expiration date from either the barcode       e
     *        expiration date AI=17, or the barcode Sell By Date AI-15
700cA*    03/22/16  LMC  7.00c
     *      - Fix: PO232 was never displaying an entry screen if      e
     *        Pick slot receiving and Xdock at the same time.
     *        Xdock will win over spick slot receiving. So we need
     *        will not set $lcmd = CHANGES if item is xdock.
     *        PO232 doesn't handle command CHANGES.
700d *    04/26/16  RTR  7.00d
     *      - Fix: Exclude } and \ from 650l check.
700e *    07/21/16  RH   7.00e
     *      - - Fix: Remove opt 10 from ZZOPT, part of 510b mod
700f *    09/28/16  LMC  7.00f
     *      - Added UOM to upc select subfile.
     *      - Changed display file name to PO12006
700g *    11/01/16  LMC  7.00g
     *      - Added RE option to review PCM Exceptions.
710a *    01/23/17  LMC  7.10a
     *      - Fix - do not load $barcode/$barcode2 unless $bcgtinsent
     *        is on.
710b *    03/22/17  LMC  7.10b
     *      - Fix - correct 710a base loadingn of barcode/barcode2
     *        on *nomore.
     *      - Enh - mfg date can be loaded from either $bcprodd or
     *        $bcpackd.
710c *    10/30/17  LMC  7.10c
     *      - Fix - Put back check for gtin before loading other
     *        fields from the gs1 barcode. We encoutered an issue
     *        where at upc code beginning with 10 sent back thinking
     *        it had found a gs1 barcode since ai code 10 is lot.
     *        Unless we find a GTIN in the scan, nothing else should
     *        be loaded from the scan, and the program should then
     *        treat the scan as a normal upc code.
740a *    01/16/20  LMC  7.40a
     *      - Enh - Added the ability to print GS1 labels for auto
     *        loading uci receiving on product that comes in without
     *        gs1 labels attached - Originally done for Canopy.
740b *    02/03/20  LMC  7.40b
     *      - Fix - only do this check on option EW.
740c *    05/22/20  LMC  7.40c
     *      - Enh: Send Vendor to all calls of CVTBAR so that the
     *        new decipher barcode process works.
740dA*    07/03/20  MLB  7.40d  ZD#2125
     *      - Enh: Changed @PRTPG to BFCPRTLBL from PRTLBL due to
     *        conflict with TL Ashford pgm of the same name.
750a *    08/23/21  LMC  7.50a
     *      - Enh: Directed putaway is not allowed for breakdown
     *        Receiving.
770dA*    07/28/23  RH  7.70d
     *      - Item dept cannot be default dept UNK.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: MJKELLNER
     *
MJKaA*    09/30/08  RH   MJKa
     *      - Display end  of line 1 extended desc in WODSC2.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Packer's
     *
PCK A*    08/27/06  JCJ  PCK
     *      - Add option 10 to option line / option list
     *
PCKaA*    02/25/07  JCJ  PCKa
     *      - Changed call in option 10 from UI316 to UI316CL
PCKbA*    05/01/07  TJ   PCKb
     *      - Add to Parm list for UI316: Export Date & Time, Dtl Seq#
     *----------------------------------------------------------------
     *  Client Custom Revisions: Capitol City Produce
     *
CCPaA*    04/14/10  RH   CCPa
     *      - Position cursor to item, not UPC
     *        NOTE: Had to force write of SCANREC to position cursor
     *        on refresh.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairylans
     *
DRYaA*    04/19/12  RH   DRYA
     *      - Remove '4' option from ZOPT to not allow 4=Delete
DRYbA*    12/30/13  MLB  DRYb
     *      - Do not allow F6=Create.
     *      - Added DRYb to SVLa mod.
DRYcA*    03/03/21  LMC  DRYc
     *      - Show W in touch field if CW lines have qty received
     *        but no weight entered.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Eastland Food Corporation
     *
EFCaA*    04/20/11  RH   EFCa
     *      - Put end of line 1 ext desc on line 2, need to see all
     *        of desc line 1 on screen.
EFCbA*    01/12/11  RH   EFCb
     *      - Right adj and continue to process UPC when *INVALID
     *        returned from CVTBAR.
     *----------------------------------------------------------------
     *  Client Custom Revisions: EGForrest
     *
EGFa *    01/04/10  RH   EGFa
     *      - Default to Mfg code display.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Farmboy
     *
FBYaA*    01/05/17  RH   FBYa
     *      - Remove '4' option from ZOPT to not allow 4=Delete
     *----------------------------------------------------------------
     *  Client Custom Revisions: FINKLE
     *
FKLaA*    08/19/08  RH   FKLa
     *      - Non-display tie/hi set on 88.
FKLbA*    10/17/08  RH   FKLb
     *      - Can only use 52 Stuffit receive on DRYC items
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: HM Wagner
HMWa *    11/18/14  RH   HMWa
     *      - Default to Mfg code display.
HMWb *    01/20/15  RTR  HMWb
     *      - Added HMW to MJKa mod to show ext desc in WODSC2
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: FISCHER
     *
FFCaA*    11/15/15  RH   FFCa
     *      - Remove '4' option from ZOPT to not allow 4=Delete
     *----------------------------------------------------------------
     *  Client Custom Revisions: Renzi Foodservice
     *
RNZaA*    09/25/08  CWM  5.20 RNZa
     *      - Added Total Weight Received next to total qty.
     *      - Converted to permanent mod, 12/17/08.
RNZbA*    03/01/09  MLB  RNZb
     *      - Revised program to retrieve w/h dept, section type and
     *        item desc. for all 9's items.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval Foodservice
     *
SVLaA*    08/13/09  RH   SVLa
     *      - Do not allow F6=Create.
     *      - Remove '4' option from ZOPT to not allow 4=Delete
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: YHata
     *
YHAaA*    12/20/07  RH  YHAa
     *      - If invalid UPC code, check file for code.
YHAbA*    12/20/07  RH  YHAb
     *      - Change command line so 14=Rcv Excp is on 1st screen.
YHAcA*    02/20/08  RH  YHAc
     *      - Remove F4 delete line.
YHAdA*    12/03/12  MLB  YHAd
     *      - Revised YHAb mod. Added 7=item msg to Y.Hata's custom
     *        option line.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: SoFo Foods
     *
SOFcA*    06/08/10  MLB  SOFc
     *      - Revised program to disable the 4=Delete option so that
     *        items cannot be deleted from the purchase order.
     *        Per Barb S. email dated 06/08/10.
SOFdA*    02/06/15  RH   SOFd
     *      - Disable 1* option for OSS.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Get Fresh
     *
GFS A*    02/11/13  MLB  GFS
     *      - Display end of line 1 extended desc in WODSC2.
     *      - Added GFS to MJKa mod.
GFSaA*    02/12/13  MLB  GFSa
     *      - Do not allow F6=Create.
     *      - Remove '4' option from ZOPT to not allow 4=Delete
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Menu Maker
GMMa *    08/08/12  RH   GMMa
     *      - Default to Mfg code display.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greenleaf Produce
     *
GLPaA*    04/15/13  LMC  GLPa
     *      - Use haccp exception processing only if REXI Questions
     *        exist, otherwise use po240.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: City Line
     *
CLDaA*    06/27/14  RBD  CLDa
     *      - When an item is marked with an X or any qty is received:
     *        Check to see if SMARTDOCK start time is blank, if so,
     *        update it. Then check to see if all line items on the PO
     *        have either been received or marked with an X, and if so,
     *        update the stop time.
     *----------------------------------------------------------------
     * Client Custom Revisions: Coastal Sunbelt
     *
CSPaA*    02/26/16  RH   CSPa
     *      - Enh: Disable option 1Alpha for Off Site Storage per Rich
     *        email
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kohl Wholesale
     *
KHLaA*    08/10/14  RH   KHLa
     *      - Do not allow F6=Create.
     *      - Remove '4' option from ZOPT to not allow 4=Delete
     *      - Default to Mfg code display.
     *----------------------------------------------------------------
     *  Client Custom Revisions: S.Bertram
     *
SBRa *    01/20/16  RH   SBRa
     *      - Enh: Add OSS check, Dept DRY = 'B', FRZ = 'C'.          .
SBRb *    06/17/16  RTR  SBRb
     *      - Enh: Added Dept FRZ = 'D'.
SBRc *    05/18/17  RTR  SBRc
     *      - Enh: Added OSS FRZ location 'F' for their whse 6.
SBRd *    08/01/18  RTR  SBRd
     *      - Enh: Added OSS FRZ location 'I' for their whse 9.
SBRe *    10/23/18  RTR  SBRe
     *      - Do not allow F6=Create.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Foods Galore
     *
FGLa *    07/21/16  RTR  FGLa
     *      - Enh: Add OSS check for 'C', 'I'.
FGLb *    12/30/16  RH   FGLb
     *      - Enh: Add Brand to desc line 2 WODSC2
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: FoodPro
     *
FPRa *    05/31/17  RTR  FPRa
     *      - Added FoodPro to mod CLDa to use SmartDock/PowerDock.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Jordano's
     *
JDOaA*    11/30/16  RH   JDOa
     *      - Enh: Disable option 1Alpha for Off Site Storage like CSP
     *----------------------------------------------------------------
     *  Client Custom Revisions: JACK PALMER
     *
JP1 A*    03/20/07  RH   JP1
     *      - Add Client code, default to *POMFR view.
     *      - Remove opt 2=change, 4=delete and F6=create
     *
JPFaA*    01/14/09  RH   JPFa
     *      - Add ZOPTJ and OPTLNJ for Jack Palmer options.
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        POSITION CURSOR
     *  21 - 29   FIELD INPUT ERROR (REVERSE DISPLAY)
520aA*  39        Reverse image item number when item msg found.
     *  40        Condition heading for Super P/O.
     *  41        Condition heading for Super P/O window.
     *  79        CHAIN INDICATOR
520aA*  83        NRF on chain to PODTLM.
     *  90        PROTECT INPUT FIELDS FOR DELETE DISPLAY
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
650mA*----------------------------------------------------------------
650mA*  Binding Directories
650mA*----------------------------------------------------------------
650mA
650mAHbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *
640aDF*****po120fm   cf   e             workstn
640dDF*po12001   cf   e             workstn
640eDF*po12002   cf   e             workstn
640gDF*po12004   cf   e             workstn
700fDF*po12005   cf   e             workstn
700fMFpo12006   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(dspsfl1:recno)
     F                                     sfile(dspsfl2:recno)
     F                                     sfile(dspsfl3:recno)
     F                                     sfile(dspsfl4:recno4)
     F                                     sfile(dspsfl5:recno4)
     F                                     sfile(dspsfl6:recno4)
     F                                     sfile(dspsfl7:recno4)
     F                                     sfile(dspsfl8:recno4)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(msgrec4:msgk4)
     Fworkopt   uf a e           k disk
     Fitemdef   if   e           k disk
     Fitemdsc   if   e           k disk
     Fitemlnk   if   e           k disk
417a Fitemmsc   if   e           k disk
     Foptions   if   e           k disk
     Foptiond   if   e           k disk
     Fpiritem   if   e           k disk
     Fpodtl     if   e           k disk
     Fpodtl1    if   e           k disk
     F                                     rename(pdrec:record)
     Fpodtl2    if   e           k disk
     F                                     rename(pdrec:record2)
     Fpodtl3    if   e           k disk
     F                                     rename(pdjrec:ptouch)
520aAFpodtlm    if   e           k disk
     Fpohdr     uf   e           k disk
     Fporcv     uf a e           k disk
     Fpospo3    if   e           k disk
     Fpo120a    if   e           k disk    usropn
     Fpo120b    if   e           k disk    usropn
     Fpo120c    if   e           k disk    usropn
     F                                     infds(ocinf)
     Fpo120d    if   e           k disk    usropn
     F                                     infds(odinf)
     Fslot3     if   e           k disk
     Fupc       if   e           k disk
650iAFupc4      if   e           k disk
650iAF                                     rename(uprec:uprec4)
     Fwarehs    if   e           k disk
416FAFdeptdsg   if   e           k disk
417aAFpospo     if   e           k disk
417cAFitmexcp2  if   e           k disk
     F                                     rename(exrec:xrec2)
417aAFitmexcp   o  a e           k disk
CLDaAFsmartdock uf   e           k disk
650mAFpgmtrck   o  a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a10             s              1    dim(10)
     D a75             s              1    dim(75)
     D a80             s              1    dim(80)
     D fkey            s             50    dim(10)
     D ukey            s             50    dim(10)
     D optlst          s              2    dim(24)
     D cmdlst          s              2    dim(24)
     D zopt            s              2    dim(20) ctdata perrcd(20)
510bAD zoptp           s              2    dim(20) ctdata perrcd(20)
JPFaAD zoptj           s              2    dim(20) ctdata perrcd(20)
417eMD zopt4           s              2    dim(1) ctdata perrcd(1)
417eD*                   ZOPT4   2   2  2
417AD*                   ZOPT4   1   1  2
417eAD zopt6           s              2    dim(2) ctdata perrcd(2)
     D optln           s             75    dim(4) ctdata perrcd(1)
PCK AD optlnp          s             75    dim(4) ctdata perrcd(1)
JPFaAD optlnj          s             75    dim(4) ctdata perrcd(1)
YHAbAD optlny          s             75    dim(4) ctdata perrcd(1)
500cAD optlns          s             75    dim(1) ctdata perrcd(1)
500eMD cmdln           s             79    dim(9) ctdata perrcd(1)
500eD*                   CMDLN   1   5 79
     D ovr             s             80    dim(4) ctdata perrcd(1)
     D qry1            s             80    dim(5) ctdata perrcd(1)
     D qry2            s             80    dim(5) ctdata perrcd(1)
     D qry3            s             80    dim(6) ctdata perrcd(1)
     D qry4            s             80    dim(6) ctdata perrcd(1)
     D cls1            s             80    dim(2) ctdata perrcd(1)
650aAd $lparm1         s             48    dim(20)
510 A*----------------------------------------------------------------
510 A*  Customer id
510 A*
     D @getcl          c                   const('GETCLIENT')
510 A*
510 A /COPY QCOPYSRC,ID#PACKERS
JPFaA /COPY QCOPYSRC,ID#PALMER
FKLaA /COPY QCOPYSRC,ID#FINKLE
SVLaA /COPY QCOPYSRC,ID#SAVAL
EGFaA /COPY QCOPYSRC,ID#EGF
CCPaA /COPY QCOPYSRC,ID#CAPITOL
SOFcA /COPY QCOPYSRC,ID#SOFO
EFCcA /COPY QCOPYSRC,ID#EASTLAN
DRYaA /COPY QCOPYSRC,ID#DAIRYLA
MJKaA /COPY QCOPYSRC,ID#MJKELLN
YHAaA /COPY QCOPYSRC,ID#YHATA
GFS A /COPY QCOPYSRC,ID#GFS
GLPaA /COPY QCOPYSRC,ID#GLP
HMWaA /COPY QCOPYSRC,ID#HMWAGNE
GMMaA /COPY QCOPYSRC,ID#GMM
CLDaA /copy qcopysrc,id#citylin
FFCaA /COPY QCOPYSRC,ID#FISCHER
KHLaA /COPY QCOPYSRC,ID#KHL
SBRaA /COPY QCOPYSRC,ID#sbr
FPRaA /copy qcopysrc,id#fpr
CSPaA /copy qcopysrc,id#coastal
JDOaA /copy qcopysrc,id#jordano
FGLaA /COPY QCOPYSRC,ID#fgl
FBYaA /copy qcopysrc,id#fby
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1     50
     D  $kwhse                 1      3  0
     D  $whsea                 1      3
     D  $kpo                   4     12
     D  $kspo                 13     21
     D  $spo                  47     50
740aA*----------------------------------------------------------------
740aA*  passing to gs110
740aA*
740aAD $gprtky         ds
740aAD  $glen50                1     50
740aAD  $gwhse                 1      3  0
740aAD  $gpo                   4     12
740aAD  $gposeq               13     17  0
740aAD  $gitem                18     32
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D  dsukey                 1     50
     D  pdwhse                 1      3  0 inz(0)
     D  pdpo                   4     12
     D  pdseq                 13     17  0 inz(0)
     D  pditem                18     32
     D  pdvitm                33     47
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
     *    OPPBRK  -  Break pallets by aisle (Y,N).
     *    OPMPUT  -  Manual Put away (Y,N).
     *
     * Data structure
     *
     D opddta          ds
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
     D  opmput                34     34
     D  opdend               117    117
     *
640dA*----------------------------------------------------------------
640dA*  Convert Barcode Parms
640dA*----------------------------------------------------------------

640dA /COPY *libl/qcopysrc,C#CVTPARMS
640dA /COPY *libl/qcopysrc,C#BARCODE
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
     D  $lpo                  22     30
     D  $lseq                 31     35  0
     D  $litem                36     50
750aAd  $lsvmput              68     68
     *
     D  $litm                 22     36
     D  $lxflg                37     37
640fA* used for haccp processing
640fAD  $llevel               22     25
640fAD  $llicense             26     40
640fAD  $lhpo                 41     49
640fAD  $lhseq                50     54  0
640fAD  $ltype                55     57
640fAD  $lspo                 58     61
650hA* used for upc check for pti selection items
650hAD  $lupc1                37     56
650hAD  $lven                 57     67  0
740aAD $gparm          ds
740aAD  $gcmd                  1      8
740aAD  $gprg                  9     18
740aAD  $guky                 19     68
740aAD  $grtn                 69     76
740aAD  $germ                 77    136
740aAD  $gmsg                 77     80
740aA*
740aA*   Redefine key
740aA*
740aAD* $gwhse                19     20p 0
740aAD* $gpo                  21     29
740aAD* $gseq                 30     32p 0
740aAD* $gitem                33     47
     *----------------------------------------------------------------
     * Data structure
     *
     D opdata          ds
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
     D  optend               117    117
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @chgpg          c                   const('PO122')
     D @delpg          c                   const('PO124')
610bDD*@prtpg          c                   const('*NONE')
740dMD @prtpg          c                   const('BFCPRTLBL')
PCK D***           'UI316'               C         @LSTPG
     D @lstpg          c                   const('UI316CL')
650dAD @crtrcv         c                   const('CRTRCVTRN')
     *----------------------------------------------------------------
     *  Window Titles.
     *
     D titl01          c                   const('Select Purchase Orde-
     D                                     r')
     D titl02          c                   const('Display Purchase Ord-
     D                                     er Totals')
     D titl03          c                   const('Position To Item Num-
     D                                     ber')
     D titl04          c                   const('Position To Manufact-
     D                                     urer Number')
     D titl05          c                   const('Select item for UPC -
     D                                                ')
     D titl06          c                   const('Display Item Message')
     D hdr01           c                   const('Item Number')
     D hdr02           c                   const('Mfr Number')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $postn          ds
     D  $pocmd                 1      8
     D  $poprg                 9     18
     D  $pofky                19     68
     D  $pouky                69    118
     D  $podsc               119    307
     D                                     DIM(3)
     D  $popt1               308    322
     D  $popt2               323    335
     D  $portn               336    343
     D  $poerm               344    403
     D  $pomsg               336    339
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     D  $pwhse                19     21  0
     D  $ppo                  22     30
     D  $pseq                 31     35  0
     D  $pitem                36     50
     D  $pvitm                51     65
417dA*----------------------------------------------------------------
417dA*  Redefinition data structures
417dA*
417dAD                 ds
417dAD  dsupc                  1     20
417dAD  dsfdis                 1     12
417dAD  dstdis                13     24
     *----------------------------------------------------------------
     D $cvtdt          ds
417a *                                       1   8 $CVDOP
417a *                                       9  140$CVDD6
417a *                                      15  220$CVDD8
417a D  $cvcmd                 1      8
417a D  $cvprg                 9     18
417a D  $cvd6i                19     24
417a D  $cvd8i                25     32
417a D  $cvd6o                33     38  0
417a D  $cvd8o                39     46  0
417a D  $cvsto                47     64
417a D  $cvrtn                65     72
417a D  $cverm                73    132
417a D  $cvmsg                73     76
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
416cA*
416cAD  erp2tp                 1      4
416cAD  erspo                  5     13
416cAD  erp2vl                14     28
416cA*
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Error Message(s)
     *
     D err01           c                   const('1=Select can only be-
     D                                      used once.')
     D err02           c                   const('No item message on f-
     D                                     ile.       ')
640dAD err03           c                   const('Pallet LPN does not e-
640dAD                                     xist or is already received')
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
     *  Workstation exception data structure
     *
     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371
     *----------------------------------------------------------------
     *  Query file INFDS data structure
     *
     D ocinf           ds
     D  totrcc               316    319b 0
     D odinf           ds
     D  totrcd               316    319b 0
     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *
     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4
     *----------------------------------------------------------------
     *  Program info data structure
640eA /COPY *libl/qcopysrc,C#PGMINFDS
     *
640eDD*               sds
640eDD* #prog            *proc
640eDD* #job                 244    253
640eDD* #user                254    263
640eDD* #jobn                264    269
640eDD* #jobdt               276    281  0
640eDD* #jobtm               282    287  0
640fA*----------------------------------------------------------------
640fA*  Prototypes
640fA*----------------------------------------------------------------
640fAD ha410           pr                  extpgm('HA410')
640fA * Input
640fAD   pparm                       80
650aAD   pparm1                      48    dim(20)
640fAD ha412           pr                  extpgm('HA412')
640fA * Input
640fAD   pparm                       80
650cAD ha413           pr                  extpgm('HA413')
650cA * Input
650cAD   pparm                        8
650cAD   pparm1                       3  0
650cAD   pparm2                       4
650cAD   pparm3                       1
640eA*----------------------------------------------------------------
640eA*  DRI parameters
640eA*----------------------------------------------------------------
640eA /COPY *libl/qcopysrc,C#DRIPARMS
640eA
640eA*----------------------------------------------------------------
640eA*  Data Formats
640eA*----------------------------------------------------------------
640eA /COPY *libl/qcopysrc,C#ITEM
640eAD savever#        s                   like($itver#)
     *----------------------------------------------------------------
     *  Variables
     *
     D $code           s             10
     D $crew           s              6
     D $emp#           s              5  0
     D $fnam           s             15
     D $init           s              1
     D $lmput          s              1
     D $lnam           s             20
     D $msgf           s             10
     D $nhrs           s             31
CLDaAD $ok             s               n
     D $rtn            s              8
     D $shft           s              6
     D $styp           s              1
     D $swhse          s              3  0
     D $whdp           s              5
     D $whse           s              3  0
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D alpseq          s              5
640dAD asnok           s              1
     D bot             s              1
     D bsitem          s             15
     D bspick          s              1
     D bsstat          s              2
     D cancel          s              1
640eAD chk4err         s               n
     D clear           s              5  0
     D comand          s              5  0
CLDaAD curtime         s              6  0
640aAD desflg          s              1
     D doex            s              1
     D done            s              1
     D dsplyd          s              2  0
650mAD dsecs           s             14  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D first           s              1
     D forceb          s              1
     D forevr          s              1
     D frstky          s                   like($puky)
     D full            s              1
     D goback          s              2  0
     D help            s              5  0
CLDaAD hldtim          s             19
600dAD i               s              3  0
640eAD itemFlag        s               n
640eAD itmuci          s              1
     D k               s              3  0
     D kycode          s                   like(opdcod)
     D kyerid          s                   like(exerid)
     D kyesta          s                   like(exesta)
     D kyitem          s                   like(exitem)
     D kytask          s                   like(extask)
     D maxvwo          s              1  0
     D msgk            s              4  0
     D msgk4           s              4  0
     D n               s              3  0
640dAD noasn           s              1
     D nomore          s              1
     D noupc           s              1
     D noxflg          s              1
     D nr              s              2  0
     D nrslct          s              3  0
     D nxtscr          s              3
     D ocode           s              8
SBRaAD oopt            s              2
     D open1           s              1
     D open2           s              1
     D optslt          s              1
650lAD osscode         s              1
     D otaken          s              1
     D ovrtyp          s              8
     D p               s              2  0
     D pagcmd          s              8
     D part            s              1
650mAD pgmtracking     s               n
     D prcrec          s              2  0
     D prtupc          s              1
     D puttyp          s              1
     D recno           s              4  0
     D recno4          s              5  0
     D recv            s              1
     D refrsh          s              1
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D savpo           s                   like(pdpo)
650hAD sav$litem       s                   like($litem)
     D sclear          s              1
     D stop            s              1
     D svhi            s              2  0
     D svitem          s             15
     D svmput          s              1
     D svpo            s                   like(pdpo)
     D svp2po          s                   like(pdpo)
     D svp2vl          s                   like(pditem)
     D svtie           s              4  0
640bAD svupci          s             15
     D today           s              8  0
     D top             s              1
     D tqyor1          s              7  0
     D tqyrc1          s              7  0
     D ttlrcd          s             11  0
     D upcctr          s              3  0
     D upcok           s              1
     D uxflag          s              1
     D v               s              2  0
     D view            s              8
     D viewo           s              1  0
640bAD wk6svitm        s             15
     D warn            s              1
640dAD woasn           s             50
     D woitm#          s             15
     D woupc           s             20
     D wrkdte          s              6  0
     D w1upc           s                   like(upupc)
     D x               s              3  0
     D y               s              3  0
640eAD zmflag          s               n
640eAD zmsflag         s               n
650cAd $ckcmd          s              8
650cAd $ckwhse         s              3  0
650cAd $cklevl         s              4
650cAd $ckfound        s              1
650mA*----------------------------------------------------------------
650mA*  Time variables
650mA*----------------------------------------------------------------
650mA
650mAD CurrStamploc    s               z
650mAD CurrStampsys    s               z
650mAD CurrStampuc     s               z
650mA
650mAD bfcoffset       s              3  0 inz(0)
650mA*----------------------------------------------------------------
650mA* Function prototypes.
650mA*----------------------------------------------------------------
650mA
650mA /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PRTKY  Partial key
     *
     *    Returned Parameters
     *      $RTNCD  *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $cmd              8
     C                   parm                    $prtky
     C                   parm                    $rtncd            8
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
640dAC                   eval      *in43 = *off
     C                   eval      $rtncd = *blanks
640eAC                   eval      itemFlag = *off
510aD*                    CALL 'BFCADR'
510aD*                    PARM           $RTN    8
510aD*          $RTN      IFEQ '*EXPIRED'
510aD*                    MOVE 'EOJ'     NXTSCR
510aD*                    MOVE '*EXIT   '$RTNCD
510aD*                    ELSE
     C                   exsr      zzinz2
510aD*                    END
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
650mAc                   exsr      zzstrt
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C                   endcs
650mAc                   exsr      zzend
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   exsr      clrsch
     *
     C                   if        $rtncd = '*EXIT   '  or
     C                             $rtncd = '*CANCEL '
     *
     *    If processing a Super P/O, update Super P/O status on exit.
     C                   if        $spo = '*YES'
     C                   exsr      zzuhdr
     C                   endif
     C                   seton                                        lr
     C                   endif
640fA* remove haccps session id record
640fA*
640fA*  TEST FOR Haccp Programs
640fA*
640fA * check to make sure programs exist or don't do call
640fAC                   eval      qcmd = 'CHKOBJ '
640fAC                                  + 'OBJ(HA412) '
640fAC                                  + 'OBJTYPE(*PGM)'
640fAC                   call      'QCMDEXC'                            78
640fAC                   parm                    qcmd            256
640fAC                   parm      80            qlen             15 5
640fAc                   if        *in78 = *off
640fA /free
640fA   $lcmd = '*END    ';
640fA   ha412($lparm);
640fA /end-free
640fAc                   else
640fAc                   eval      *in78 = *off
640fAc                   endif
650dAc                   exsr      zzrcvpoclean
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
     *   Set OFF command key indicators
     *
     C                   setoff                                       kckekf
     C                   setoff                                       klki
     *
     *   Overlay screen with title
     *
     C                   write     title
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *   Overlay screen with subfile screen
     *
     C                   select
     C                   when      nxtscr = '01 '
     C                   select
     *
     *    Single line display and NOT a Super P/O.
     C                   when      uxflag = *off  and
     C                             $spo = '*NO '
     *
     C                   select
     C                   when      view = '*POITEM '
     *
     C                   exsr      sfldsp
     C                   read      postnrec                               50
     C                   read      scanrec                                50
     *
     C                   when      view = '*POMFR  '
     C                   exsr      sflds2
     C                   read      postnrc2                               50
     C                   read      scanrec2                               50
     C                   endsl
     *
     C                   other
     *
     C                   select
     C                   when      view = '*POITEM '
     C                   exsr      sflds1
     C                   read      postnrec                               50
     C                   read      scanrec                                50
     *
     C                   when      view = '*POMFR  '
     C                   exsr      sflds3
     C                   read      postnrc2                               50
     C                   read      scanrec2                               50
     C                   endsl
     *
     C                   endsl
     *
     C                   when      nxtscr = '02 '
     C                   exsr      deldsp
     *
     C                   endsl
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       2021
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cancel = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   select
     C                   when      uxflag = *off  and
     C                             $spo = '*NO '
     C                   select
     C                   when      view = '*POITEM '
     C                   read      dspsfc                                 50
     *
     C                   when      view = '*POMFR  '
     C                   read      dspsfc2                                50
     *
     C                   endsl
     *
     C                   other
     *
     C                   select
     C                   when      view = '*POITEM '
     C                   read      dspsfc1                                50
     *
     C                   when      view = '*POMFR  '
     C                   read      dspsfc3                                50
     *
     C                   endsl
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *     Screen initialization and wrap-up routines
     *
     *----------------------------------------------------------------
     *
     *  Screen 01 initialization
     *
     C     scr01i        begsr
     *
     *    If this is a Super P/O, then condition heading on TITLE fmt.
     C                   if        $spo = '*YES'
     C                   eval      *in40 = *on
     C                   else
     C                   eval      *in40 = *off
     C                   endif
     *
     C                   eval      nxtscr = '01 '
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   write     clr0306
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   eval      *in90 = *on
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   write     clr0306
     C                   write     delrec
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag02
     C                   write     cmddel
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 wrap-up
     *
     C     scr02e        begsr
     C                   eval      nxtscr = '01 '
     C                   eval      *in90 = *off
     C                   write     clr0306
     *
     *   If delete was not canceled (no errors)
     *     then reposition to record just before first deleted rec.
     *
     C                   if        cancel = *off
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = frstky
     C                   exsr      fgtway
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     C                   if        $portn = '*NOMORE '
     C                   eval      $pocmd = '*TOP    '
     C                   else
     *
     *   Otherwise, position to last record read.
     *
     C                   eval      $pocmd = '*POSTN2 '
     C                   endif
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   exsr      optns
     C                   else
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     C     status        caseq     rollup        roll01
     C     status        caseq     rolldn        roll01
     C     status        caseq     comand        cmd01
     C                   cas                     ent01
     C                   endcs
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     C     status        caseq     rollup        roll02
     C     status        caseq     rolldn        roll02
     C     status        caseq     comand        cmd02
     C                   cas                     ent02
     C                   endcs
     C     endsc2        endsr
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
650mAC     *dtaara       define    pgmtrack      pgmtracking
650mAC                   in        pgmtracking
510 A*
510 A* Get client id.
510 A*
510 AC                   call      @getcl
510 AC                   parm                    client           10
510 A*
     *  Initialize special keys
     *
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
     C                   exsr      zmims4
     *
     *  Initialize subfile (DSPSFL) record
     *
     C                   eval      recno = 1
     C                   write     dspsfl                               79
     C                   write     dspsfl1                              79
     C                   write     dspsfl2                              79
     C                   write     dspsfl3                              79
     C                   eval      recno4 = 1
     C                   write     dspsfl4                              79
     C                   write     dspsfl5                              79
417k C                   write     dspsfl7                              79
417l C                   write     dspsfl8                              79
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CLRSCH   Clear everything out of work file
     *
     C     clrsch        begsr
     C     wkoprt        setll     workopt
     C     wkoprt        reade     workopt                              7979
     C                   dow       not *in79
     C                   delete    wkorec
     C     wkoprt        reade     workopt                              7979
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CMD01    Screen 1 command key routine
     *
     C     cmd01         begsr
     *
     *  TEST FOR CMD3 - EXIT
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*EXIT   '
     C                   goto      cmd01e
     C                   endif
640dA*
640dA*  TEST FOR CMD13 - ASN Receiving
640dA*
640dAc                   if        *inkm
640dA * check to make sure programs exist or don't allow this command
640dAC                   eval      qcmd = 'CHKOBJ '
640dAC                                  + 'OBJ(GETASN) '
640dAC                                  + 'OBJTYPE(*PGM)'
640dAC                   call      'QCMDEXC'                            78
640dAC                   parm                    qcmd            256
640dAC                   parm      80            qlen             15 5
640dAc                   if        *in78 = *off
640dAc                   eval      *in43 = *on
640dAc                   eval      w1upcd= ' '
640dAc                   eval      w1asn = ' '
640dAc                   eval      w1uci = ' '
640dAc                   else
640dAc                   eval      *in78 = *off
640dAc                   endif
640dAc                   endif
640dA*
640dA*  TEST FOR CMD14 - UCI Receiving
640dA*
640dAc                   if        *inkn
640dAc                   eval      *in43 = *off
640dAc                   eval      w1upcd= ' '
640dAc                   eval      w1asn = ' '
640dAc                   eval      w1uci = ' '
640dAc                   endif
500e *
500e *  TEST FOR CMD11 - Un-touched or ALL
500e *
500e C                   if        *inkk
640aAC                   if        desflg = *on
640aAC                   eval      desflg = *off
640aAC                   eval      noxflg = *off
640aAC                   else
500e C                   if        noxflg = *on
500e C                   eval      noxflg = *off
500e C                   else
500e C                   eval      noxflg = *on
500e C                   endif
640aAC                   endif
500e C                   if        view = '*POITEM '
500e C                   select
500e C                   when      $spo = '*NO '
500e C                   if        noxflg = *off
500e C                   eval      cmdln1 = cmdln(1)
500e C                   else
500e C                   eval      cmdln1 = cmdln(6)
500e C                   endif
500e C                   when      $spo = '*YES'
500e C                   if        noxflg = *off
500e C                   eval      cmdln1 = cmdln(3)
500e C                   else
500e C                   eval      cmdln1 = cmdln(8)
500e C                   endif
500e C                   endsl
500e C                   endif
500e *
500e C                   if        view = '*POMFR  '
500e C                   select
500e C                   when      $spo = '*NO '
500e C                   if        noxflg = *off
500e C                   eval      cmdln1 = cmdln(2)
500e C                   else
500e C                   eval      cmdln1 = cmdln(7)
500e C                   endif
500e C                   when      $spo = '*YES'
500e C                   if        noxflg = *off
500e C                   eval      cmdln1 = cmdln(4)
500e C                   else
500e C                   eval      cmdln1 = cmdln(9)
500e C                   endif
500e C                   endsl
500e C                   endif
500e *
500e C                   eval      pagcmd = '*REFRESH'
500e C                   move      *loval        fkey
500e C                   move      *loval        ukey
500e C                   exsr      pag01
500e C                   endif
640aA*
640aA*  TEST FOR CMD10 - Quantity discrepancies
640aA*
640aAC                   if        *inkj
640aAC                   if        desflg = *on
640aAC                   eval      desflg = *off
640aAC                   else
640aAC                   eval      desflg = *on
640aAC                   endif
640aAC                   if        view = '*POITEM '
640aAC                   select
640aAC                   when      $spo = '*NO '
640aAC                   if        desflg = *off
640aAC                   eval      cmdln1 = cmdln(1)
640aAC                   else
640aAC                   eval      cmdln1 = cmdln(6)
640aAC                   endif
640aAC                   when      $spo = '*YES'
640aAC                   if        desflg = *off
640aAC                   eval      cmdln1 = cmdln(3)
640aAC                   else
640aAC                   eval      cmdln1 = cmdln(8)
640aAC                   endif
640aAC                   endsl
640aAC                   endif
640a *
640aAC                   if        view = '*POMFR  '
640aAC                   select
640aAC                   when      $spo = '*NO '
640aAC                   if        desflg = *off
640aAC                   eval      cmdln1 = cmdln(2)
640aAC                   else
640aAC                   eval      cmdln1 = cmdln(7)
640aAC                   endif
640aAC                   when      $spo = '*YES'
640aAC                   if        desflg = *off
640aAC                   eval      cmdln1 = cmdln(4)
640aAC                   else
640aAC                   eval      cmdln1 = cmdln(9)
640aAC                   endif
640aAC                   endsl
640aAC                   endif
640aA*
640aAC                   eval      pagcmd = '*REFRESH'
640aAC                   move      *loval        fkey
640aAC                   move      *loval        ukey
640aAC                   exsr      pag01
640aAC                   endif
     *
     *
     *  TEST FOR CMD9 - Change view.
     *
     C                   if        *inki
     *
     C                   select
     C                   when      view = '*POITEM '
     *    Process file override for OPNQRYF
     C                   eval      ovrtyp = '*POMFR  '
     C                   if        $spo = '*YES'
     C                   exsr      zzovr
     *
     *    Process OPNQRYF.
     C                   exsr      zzqry
     C                   exsr      zzopn
     C                   endif
     *
     C                   eval      view = '*POMFR  '
     C                   select
     C                   when      $spo = '*NO '
500e C                   if        noxflg = *off
     C                   eval      cmdln1 = cmdln(2)
500e C                   else
500e C                   eval      cmdln1 = cmdln(7)
500e C                   endif
     C                   when      $spo = '*YES'
500e C                   if        noxflg = *off
     C                   eval      cmdln1 = cmdln(4)
500e C                   else
500e C                   eval      cmdln1 = cmdln(9)
500e C                   endif
     C                   endsl
     C                   eval      pagcmd = '*REFRESH'
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   exsr      pag01
     *
     C                   when      view = '*POMFR  '
     *    Process file override for OPNQRYF
     C                   eval      ovrtyp = '*POITEM '
     C                   if        $spo = '*YES'
     C                   exsr      zzovr
     *
     *    Process OPNQRYF.
     C                   exsr      zzqry
     C                   exsr      zzopn
     C                   endif
     *
     C                   eval      view = '*POITEM '
     C                   select
     C                   when      $spo = '*NO '
500e C                   if        noxflg = *off
     C                   eval      cmdln1 = cmdln(1)
500e C                   else
500e C                   eval      cmdln1 = cmdln(6)
500e C                   endif
     C                   when      $spo = '*YES'
500e C                   if        noxflg = *off
     C                   eval      cmdln1 = cmdln(3)
500e C                   else
500e C                   eval      cmdln1 = cmdln(8)
500e C                   endif
     C                   endsl
     C                   eval      pagcmd = '*REFRESH'
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   exsr      pag01
     *
     C                   endsl
     *
     C                   endif
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*CANCEL '
     C                   goto      cmd01e
     C                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
     *     TEST FOR CMD5 - REFRESH
     *
     C                   if        *inke
640dAc                   eval      *in43 = '0'
640dAc                   eval      w1upcd= ' '
640dAc                   eval      w1asn = ' '
640dAc                   eval      w1uci = ' '
     C                   exsr      clrsch
     C                   if        uxflag = *off  and
     C                             $spo = '*NO '
     C                   select
     C                   when      view = '*POITEM '
     *
     C     1             do        10            x
     C     x             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      option = '  '
520aA*    Restore item message indicator.
520aAC                   eval      *in39 = hldi39
     C                   update    dspsfl
     C                   endif
     C                   enddo
     *
     C                   when      view = '*POMFR  '
     *
     C     1             do        10            x
     C     x             chain     dspsfl2                            79
     C                   if        not *in79
     C                   eval      option = '  '
520aA*    Restore item message indicator.
520aAC                   eval      *in39 = hldi39
     C                   update    dspsfl2
     C                   endif
     C                   enddo
     *
     C                   endsl
     *
     C                   else
     *
     C                   select
     C                   when      view = '*POITEM '
     *
     C     1             do        05            x
     C     x             chain     dspsfl1                            79
     C                   if        not *in79
     C                   eval      option = '  '
520aA*    Restore item message indicator.
520aAC                   eval      *in39 = hldi39
     C                   update    dspsfl1
     C                   endif
     C                   enddo
     *
     C                   when      view = '*POMFR  '
     *
     C     1             do        05            x
     C     x             chain     dspsfl3                            79
     C                   if        not *in79
     C                   eval      option = '  '
520aA*    Restore item message indicator.
520aAC                   eval      *in39 = hldi39
     C                   update    dspsfl3
     C                   endif
     C                   enddo
     *
     C                   endsl
     C                   endif
     *
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  VERIFY AND SAVE ANY OPTIONS THAT WERE ENTERED
     *
     C                   exsr      savopt
     C     error         cabeq     *on           cmd01e
     *
     *  EXECUTE COMMAND KEYS THAT DID NEED THE OPTIONS VERIFIED
     *
     *  TEST FOR CMD6 - ADD RECORD
     *
     C                   if        *inkf
SVLaAC                   if        client=saval
GFSaAC                             or client = Getfresh
DRYbAC                             or client = Dairyland
KHLaAC                             or client = Kohl
SBReAC                             or client = Sbertram
JP1 AC                             or client = palmer
SVLaAC                   eval      error=*on
SVLaAC                   exsr      ZM0104
SVLaAC                   goto      cmd01e
SVLaAC                   endif
     C                   exsr      inzpar
     C                   eval      $pcmd = '*ADD    '
     C                   call      @chgpg
     C                   parm                    $parms
     C                   if        $prtn = '*ERROR  '
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   else
     C                   if        $prtn <> '*CANCEL '  and
     C                             $prtn <> '*EXIT   '
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD10 - MOVE RECORD THAT CUSOR IS ON TO TOP
     *
640aDC*****              if        *inkj
640aDC*****              z-add     0             row#
640aDC*****              eval      row = rowin
640aDC*****              z-add     0             col#
640aDC*****              eval      col = colin
     *
     *     MAKE SURE CURSOR IS ON ONE OF THE DISPLAYED RECORDS
     *
     *R                   SUB  10        ROW#
640aDC*****              sub       prcrec        row#
640aDC*****              if        row# < 1  or
640aDC*****                        row# > dsplyd
640aDC*****              eval      error = *on
640aDC*****              eval      errmsg = *blanks
640aDC*****              exsr      zm0106
640aDC*****              goto      cmd01e
640aDC*****              endif
640aD*
640aD*     REPOSITION RECORD THAT CURSOR IS ON TO THE TOP
640aD*
640aDC*****              eval      $pocmd = '*POSTN2U'
640aDC*****              eval      $pouky = ukey(row#)
640aDC*****              exsr      fgtway
     *R         CLERR     CABEQ*ON       CMD01E
640aDC*****              eval      pagcmd = '*REPOS  '
640aDC*****              exsr      pag01
640aDC*****              goto      cmd01e
640aDC*****              endif
     *
     *  TEST FOR CMD17 - REPOSITION TO TOP OF DISPLAY
     *
     C                   if        *inkr
     C                   eval      pagcmd = '*TOP    '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD18 - REPOSITION TO BOTTOM OF DISPLAY
     *
     C                   if        *inks
     C                   eval      pagcmd = '*BOTTOM '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *   Process non-standard function keys.
     *
     C                   exsr      zzcmd
     C     cmd01e        endsr
     *----------------------------------------------------------------
     *
     *  CMD02    Screen 2 command key routine
     *
     C     cmd02         begsr
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      cancel = *on
     C                   exsr      scr02e
     C                   goto      cmd02e
     C                   endif
     C     cmd02e        endsr
     *----------------------------------------------------------------
     *
     *  DELADD   Add record to subfile for delete display
     *
     C     deladd        begsr
     C                   eval      nr = prcrec
     C                   add       1             nr
     *R         RECNO     IFLT 11
     C                   if        recno < nr
     C                   add       1             recno
     C                   z-add     recno         y
     *
     *  GET RECORD INFO
     *
     C                   eval      $pocmd = '*GET    '
     C                   eval      $pouky = wkokyu
     C                   exsr      fgtway
     *R         CLERR     CABEQ*ON       DELADE
     *
     *  SAVE KEY TO RECORD OF FIRST SCREEN LINE
     *
     C                   if        recno = 1
     C                   eval      $wkof = wkokyf
     C                   eval      $wkou = wkokyu
     C                   endif
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
     C                   eval      option = wkoopt
     C                   if        uxflag = '0'
     C                   select
     C                   when      view = '*POITEM '
     C                   write     dspsfl
     C                   when      view = '*POMFR  '
     C                   write     dspsfl2
     C                   endsl
     C                   else
     C                   select
     C                   when      view = '*POITEM '
     C                   write     dspsfl1
     C                   when      view = '*POMFR  '
     C                   write     dspsfl3
     C                   endsl
     C                   endif
     C                   endif
     C     delade        endsr
     *----------------------------------------------------------------
     *
     *  DELDSP   Display subfile of records marked for deletion
     *
     C     deldsp        begsr
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
     C                   if        uxflag = '0'
     C                   select
     C                   when      view = '*POITEM '
     C                   write     dspsfc
     C                   when      view = '*POMFR  '
     C                   write     dspsfl2
     C                   endsl
     C                   else
     C                   select
     C                   when      view = '*POITEM '
     C                   write     dspsfc1
     C                   when      view = '*POITEM '
     C                   write     dspsfc1
     C                   endsl
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ENT01    Screen 1 enter key routine
     *
     C     ent01         begsr
     *
     *  VERIFY AND SAVE OPTIONS
     *
     C                   exsr      savopt
     C     error         cabeq     *on           ent01e
     *
     *  SEE IF USER IS TRYING TO POSITION TO A CERTAIN SPOT
     *
     C                   eval      repos = *off
     C                   exsr      zzpos
     C     error         cabeq     *on           ent01e
     C                   if        repos = *on
     C                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*POSTN2 '
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      ent01e
     C                   endif
     *
     *  CHECK IF UPC CODE WAS ENTERED.
     *
417bD*R         W1UPC     IFNE *BLANKS
640iDC*                  if        w1upcd <> *blanks
640iDC*                            or w1asn <> *blanks
700aAC                   if        %subst(w1asn:1:1) = *blanks
700aAC                   eval      w1asn = *blanks
700aAC                   endif
700aAC                   if        %subst(w1uci:1:1) = *blanks
700aAC                   eval      w1uci = *blanks
700aAC                   endif
640iMC                   if           w1asn <> *blanks
640dAC                             or w1uci <> *blanks
     C                   exsr      zzchk1
     C     error         cabeq     *on           ent01e
417h C     optslt        cabeq     *off          ent01e
     C                   eval      $puky = dsukey
     C                   exsr      zzchek
     C     error         cabeq     *on           ent01e
     C                   exsr      zzrcv
     C                   eval      refrsh = *on
     C                   endif
     *
     *  IF NOT POSITIONING THEN EXECUTE THE ENTERED OPTIONS
     *
     C                   exsr      optns
     *
     *  IF OPTION WAS NOT TAKEN THEN RETURN LIKE CMD12 WAS ENTERED
     *
     *R         OTAKEN    IFEQ *OFF
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   GOTO ENT01E
     *R                   END
     C     ent01e        endsr
     *----------------------------------------------------------------
     *
     *  ENT02    Screen 2 enter key routine
     *
     C     ent02         begsr
     *
     *  Save first delete key.
     *
     C                   eval      frstky = $puky
     *
     *  Delete the records that have been selected
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     wkoprt        reade     workopt                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     *
     C                   if        wkoopt = ' 4'
     *
     *  Call delete program
     *
     C                   exsr      inzpar
     C                   eval      $pcmd = '*DELETE '
     C                   eval      $puky = wkokyu
     C                   call      @delpg
     C                   parm                    $parms
     *
     *     Error occured - Error message sent back
     *
     C                   if        $prtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     *
     *     Error occured - Error message sent to program msgq
     *
     C                   if        $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   else
     *
     *     Delete canceled
     *
     C                   if        $prtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   else
     *
     *     Delete was successful.
     *
     C                   if        $prtn = '*OK     '
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   if        cancel = *off
     C                   delete    wkorec
     C                   else
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   endif
     C                   endif
     *
     C                   endif
     C                   enddo
     C                   exsr      scr02e
     C     ent02e        endsr
     *----------------------------------------------------------------
     *
     *  FGTWAY   Gateway to file handling routines
     *
     *    Input Parameters
     *      $POCMD   *INIT    - Initialize and return
     *               *GET     - Get record for $POUKY value
     *               *GETNEXT - Get next record
     *               *GETPREV - Get previous record
     *               *WRITPOS - Write position record to display
     *               *READPOS - Read position record
     *               *POSTN2  - Position to $POFKY
     *               *POSTN2U - Position to $POUKY
     *               *TOP     - Position to top of file
     *               *BOTTOM  - Position to bottom of file
     *      $POFKY   Key for positioning within file
     *      $POUKY   Unique key used for change/delete operations
     *
     *    Returned Parameters
     *      $PORTN   *NOMORE  - Beginning/End of file was reached
     *               *NOTFND  - Record not found on a GET
     *               *FOUND   - Record found
     *               *REPOS   - Repositioning took place
     *               *ERROR   - Error occured
     *      $POERM   Error message
     *
     C     fgtway        begsr
     C                   eval      $portn = *blanks
     C     $pocmd        caseq     '*GET    '    fget
     C     $pocmd        caseq     '*GETNEXT'    fgetn
     C     $pocmd        caseq     '*GETPREV'    fgetp
     C     $pocmd        caseq     '*POSTN2 '    fpos2
     C     $pocmd        caseq     '*POSTN2U'    fpos2u
     C     $pocmd        caseq     '*TOP'        zzpos2
     C     $pocmd        caseq     '*BOTTOM'     zzpos2
     C                   endcs
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGET     Get record using file with unique key
     *
     *              In this case the lookup file and the unique key
     *              file are the same.
     *
     C     fget          begsr
     C                   eval      dsukey = $pouky
     C                   exsr      zzfget
     C                   if        *in79
     C                   eval      $portn = '*NOTFND '
     C                   eval      $pouky = *blanks
     C                   eval      $pofky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGETN    Get next record
     *
     C     fgetn         begsr
     C                   exsr      zzfgtn
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   eval      $pouky = *blanks
     C                   eval      $pofky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGETP    Get previous record
     *
     C     fgetp         begsr
     C                   exsr      zzfgtp
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   eval      $pouky = *blanks
     C                   eval      $pofky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS2    Position to record
     *
     C     fpos2         begsr
     C                   eval      dsfkey = $pofky
     C                   select
     C                   when      view = '*POITEM '  and
     C                             $spo = '*NO '
     C     fileky        setll     record
     *
     C                   when      view = '*POMFR  '  and
     C                             $spo = '*NO '
     C     filky2        setll     record2
     *
     C                   when      view = '*POITEM '  and
     C                             $spo = '*YES'
     C     filky3        setll     oqreca
     *
     C                   when      view = '*POMFR  '  and
     C                             $spo = '*YES'
     C     filky4        setll     oqrecb
     *
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS2U   Position to record using unique key
     *
     C     fpos2u        begsr
     *
     *  GET RECORD FOR UNIQUE KEY
     *
     C                   exsr      fget
     *
     *  POSITION TO RECORD IN LOOKUP FILE
     *
     C                   exsr      fpos2
     C                   endsr
     *----------------------------------------------------------------
     *
     *  INZPAR   Initialize parameters for calling add/chg/del program
     *
     C     inzpar        begsr
     C                   clear                   $parms
     C                   eval      $pprg = #prog
     C                   eval      $puky = $prtky
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPTNS    Perform options that user entered
     *
     C     optns         begsr
     C                   eval      otaken = *off
     *
     *     DO ALL DELETES FIRST (OPTION 4)
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C     wkoprt        reade     workopt                                79
     C                   dow       not *in79  and
     C                             wkoopt <> ' 4'
     C     wkoprt        reade     workopt                                79
     C                   enddo
     C                   if        not *in79  and
     C                             wkoopt = ' 4'
     C                   eval      otaken = *on
     C                   eval      $puky = wkokyu
     C                   exsr      scr02i
     C                   goto      optnse
     C                   endif
     *
     *  THEN DO THE OTHER OPTIONS IN THE ORDER THEY WERE ENTERED
     *     STOP WHEN NO MORE OPTIONS OR USER ENTERS CMD12
     *
     C     wkoprt        setll     workopt
     C                   eval      cancel = *off
     C                   eval      stop = *off
     C                   dou       stop = *on  or
     C                             cancel = *on
     C     wkoprt        reade     workopt                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   if        wkoopt <> '  '
     C                   eval      otaken = *on
     C                   exsr      optns2
     C     wkounq        chain     workopt                            78
     C                   eval      refrsh = *on
     C                   if        error = *off
     C                   delete    wkorec
     C                   endif
     C                   if        cancel = *on
     C                   eval      stop = *on
     C                   if        error = *on
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   endif
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   endif
     C                   endif
     C                   endif
     C                   enddo
     C                   if        refrsh = *on
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   endif
     C     optnse        endsr
     *----------------------------------------------------------------
     *
     *  OPTNS2   Execute individual options
     *
     C     optns2        begsr
     C                   exsr      inzpar
     C                   eval      $puky = wkokyu
     *
     *   Change
     *
     C                   if        wkoopt = ' 2'
     C                   eval      $pcmd = '*CHANGE '
     C                   call      @chgpg
     C                   parm                    $parms
     C                   else
     *
     *   View
     *
     C                   if        wkoopt = ' 5'
     C                   eval      $pcmd = '*VIEW   '
     C                   call      @chgpg
     C                   parm                    $parms
     C                   else
     *
     *   Print
     *
     C                   if        wkoopt = ' 6'
     C                   eval      $pcmd = '*PRINT  '
610bAC                   if        @prtpg <> 'NONE'
     C                   call      @prtpg
     C                   parm                    $parms
610bAC                   endif
     C                   else
     *
     *   Print produce labels
     *
610bAC                   if        wkoopt = '18'
610bAC                   exsr      zzprdlbl
610bAC                   else
     C                   exsr      zzopt
610bAC                   endif
     C                   endif
     C                   endif
     C                   endif
     *
     C                   if        $prtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   else
     C                   if        $prtn = '*ERROR  '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $prtn = '*PGMQ   '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PAG01    Screen 1 page routines
     *
     C     pag01         begsr
     *
     *  NEXT PAGE
     *
     C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag1fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV   '
     C                   exsr      pag1bk
     C                   else
     *
     *  TOP
     *
     C                   if        pagcmd = '*TOP    '
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     *R         CLERR     CABEQ*ON       PAG01E
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      forceb = *off
     C                   exsr      pag1fw
     C                   else
     *
     *  BOTTOM
     *
     C                   if        pagcmd = '*BOTTOM '
     C                   eval      bot = *on
     C                   eval      dsplyd = 0
     C                   exsr      pag1bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C                   if        fkey(1) = *loval
     C                   eval      $pocmd = '*TOP    '
     C                   else
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = fkey(1)
     C                   endif
     C                   exsr      fgtway
     *R         CLERR     CABEQ*ON       PAG01E
     C                   eval      bot = *off
     C                   exsr      pag1fw
     C                   else
     *
     *  REPOSITIONING
     *
     C                   if        pagcmd = '*REPOS  '
     C                   eval      bot = *off
     C                   eval      forceb = *off
     C                   exsr      pag1fw
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = *blanks
     C     pag01e        endsr
     *----------------------------------------------------------------
     *
     *  PAG02    Screen 2 page routines
     *
     C     pag02         begsr
     *
     *  NEXT PAGE
     *
     C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag2fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV   '
     C                   exsr      pag2bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C     deltop        setll     workopt
     C                   eval      bot = *off
     C                   exsr      pag2fw
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = *blanks
     C     pag02e        endsr
     *----------------------------------------------------------------
     *
     *  PAG1FW   Let's see that next page of records
     *
     C     pag1fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     *on           endf
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   exsr      sflclr
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     C                   eval      savpo = *blanks
     *
     *  GET 10 RECORDS TO DISPLAY
     *
     C                   dou       stop = *on
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfac
     C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *  OR EXTENDED DESCRIPTION- STOP AFTER 5 GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
     *R         P         IFGE 10
     C                   if        p >= prcrec
     C                   eval      stop = *on
     C                   if        forceb = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C     endfac        tag
     C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     C     endf          endsr
     *----------------------------------------------------------------
     *
     *  PAG1BK   Let's see the previous page
     *
     C     pag1bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     *on           endb
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     *R         DSPLYD    ADD  10        GOBACK  20
     C     dsplyd        add       prcrec        goback
     C                   if        bot = *on
     *R         GOBACK    IFEQ 10
     C                   if        goback = prcrec
     C                   eval      forceb = *on
     C                   endif
     C                   eval      $pocmd = '*BOTTOM '
     C                   exsr      fgtway
     C                   add       1             goback
     C                   endif
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      stop = *off
     *
     *  READ SPECIFIED FLITCHES FILE
     *
     C                   dou       stop = *on
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     *
     *  HIT TOP OF FILE
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk
     C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C     endbk         tag
     C                   enddo
     *
     * IF THE TOP WAS REACHED THEN POSITION POINTER TO TOP OF FILE
     *
     C                   if        top = *on
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     C                   endif
     C                   exsr      pag1fw
     C     endb          endsr
     *----------------------------------------------------------------
     *
     *  PAG2FW   Let's see that next page of delete records
     *
     C     pag2fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     *on           endf2
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   exsr      sflclr
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     *
     *  GET 10 RECORDS TO DISPLAY
     *
     C                   dou       stop = *on
     C     wkoprt        reade     workopt                                79
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfw2
     C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *  OR EXTENDED DESCRIPTION- STOP AFTER 5 GOOD RECORDS
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   exsr      deladd
     *R         P         IFGE 10
     C                   if        p >= prcrec
     C                   eval      stop = *on
     C                   if        forceb = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C                   endif
     C     endfw2        tag
     C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     C     endf2         endsr
     *----------------------------------------------------------------
     *
     *  PAG2BK   Let's see the previous page of delete records
     *
     C     pag2bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     *on           endb2
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     *R         DSPLYD    ADD  10        GOBACK  20
     C     dsplyd        add       prcrec        goback
     C                   if        bot = *on
     C     wkoprt        setgt     workopt
     C                   add       1             goback
     C                   endif
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      stop = *off
     *
     *  READ FILE
     *
     C                   dou       stop = *on
     C     wkoprt        readpe    workopt                                79
     *
     *  HIT TOP OF FILE
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk2
     C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C                   endif
     C     endbk2        tag
     C                   enddo
     *
     * IF WE HIT THE TOP REPOSITION POINTER TO TOP OF FILE
     *
     C                   if        top = *on
     C     wkoprt        setll     workopt
     C                   endif
     C                   exsr      pag2fw
     C     endb2         endsr
     *----------------------------------------------------------------
     *
     *  ROLL01   Screen 1 roll up/down routine
     *
     C     roll01        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C                   exsr      savopt
     C     error         cabeq     *on           rol01e
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   exsr      savopt
     C     error         cabeq     *on           rol01e
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     C     rol01e        endsr
     *----------------------------------------------------------------
     *
     *  ROLL02   Screen 2 roll up/down routine
     *
     C     roll02        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     C     rol02e        endsr
     *----------------------------------------------------------------
     *
     *  SAVOPT   Verify and save options that were entered
     *
     C     savopt        begsr
     *
     *  READ ONLY THE CHANGED OPTIONS
     *
     C                   eval      nomore = *off
     C                   eval      woyes = 'N'
     C                   dou       nomore = *on
     C                   eval      *in21 = *off
     C                   if        uxflag = '0'
     C                   select
     C                   when      view = '*POITEM '
     C                   readc     dspsfl                                 79
     C                   when      view = '*POMFR  '
     C                   readc     dspsfl2                                79
     C                   endsl
     C                   else
     C                   select
     C                   when      view = '*POITEM '
     C                   readc     dspsfl1                                79
     C                   when      view = '*POMFR  '
     C                   readc     dspsfl3                                79
     C                   endsl
     C                   endif
     C                   if        *in79
     C                   eval      nomore = *on
     C                   goto      enddo1
     C                   endif
650lA*
650lA*  Check for new internal oss receiving
650lA*
650lA /free
650la     osscode = ' ';
SOFdA   if client <> SofoFoods;
650la   if option >= '1A' and option <= '1Z'
700dA     and option <> '1}'
700dA     and option <> '1\'
CSPaA     and client <> coastl
JDOaA     and client <> jordanos;
650la     osscode = %subst(option:2:1);
SBRaa     oopt = option;
650la     option = '1 ';
650la     endif;
SOFda   endif;
650lA /end-free
     *
     *  DISPLAY ERROR IF OPTION IS NOT VALID
     *
     C                   if        option <> *blanks
     C                   movea     option        a2
     C                   if        a2(2) = ' '
     C                   eval      a2(2) = a2(1)
     C                   eval      a2(1) = ' '
     C                   movea     a2            option
     C                   endif
     *
     *    LOOK UP OPTION IN PROFILE - ERROR IF NOT FOUND
     *
JPFaAC                   select
510nAC                   when      client = packer
510bAC     option        lookup    zoptp                                  50
JPFaAC                   when      client = palmer
JPFaAC     option        lookup    zoptj                                  50
510bAC                   other
     C     option        lookup    zopt                                   50
JPFaMC                   endsl
     C                   if        not *in50
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0108
     C                   endif
740aA /free
740aA   if pditem<>' ' and %Check(' 0123456789.-':pditem)<>0
740aA      and option = 'EW';
740aA     error = *on;
740aA     ErrMsg = 'Item# must be numeric for this process';
740aA     exsr zm0105;
740aA   endif;
740aA   // item must be uci receiving to use this option
740bA   if option = 'EW';
740aA     exsr clr$item;

740aA     $itWhse = $kwhse;
740aA     $ititem = pditem;

740aA     $dricommand = '*ITEM';
740aA     $drisubcmd  = '%GETALL';
740aA     $drisys2upd = 'D';
740aA     chk4err = *on;
740aA     zmflag  = *off;
740aA     exsr zzzdricop;
740aA     if error = *on;
740aA       $ifrcvmth = ' ';
740aA     endif;
740aA     if $ifrcvmth <> '2';
740aA       error = *on;
740aA       ErrMsg = 'Item# must be UCI Received for this option';
740aA       exsr zm0105;
740aA     endif;
740bA   endif;
740aA /end-free
     C                   endif
     *
     *  SAVE OPTION
     *
     C                   z-add     recno         y
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C     wkounq        chain     workopt                            79
     C                   if        not *in79
     C                   if        option = *blanks
     C                   delete    wkorec
     C                   else
     C                   eval      wkoopt = option
     C                   move      *in21         wkoerr
     C                   update    wkorec
     C                   endif
     C                   else
     C                   if        option <> *blanks
     C                   eval      wkousr = #user
     C                   eval      wkopgm = #prog
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C                   eval      wkoopt = option
     C                   move      *in21         wkoerr
     C                   write     wkorec
     C                   endif
     C                   endif
     C     enddo1        tag
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     *
     *    Single line descriptions in use and not a Super P/O.
     C                   if        uxflag = *off  and
     C                             $spo = '*NO '
     *
     C                   if        recno < 11
     C                   add       1             recno
     C                   z-add     recno         y
     *
     *  SAVE FILE AND UNIQUE KEYS
     *
     C                   eval      fkey(y) = $pofky
     C                   eval      ukey(y) = $pouky
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
     *
     C                   select
     C                   when      view = '*POITEM '
     C                   write     dspsfl
     *
     C                   when      view = '*POMFR  '
     C                   write     dspsfl2
     *
     C                   endsl
     C                   endif
     C                   endif
     *
     *  Use extended description or this is a Super P/O.
     *
     C                   if        uxflag = *on
     C                   if        recno < 6
     C                   add       1             recno
     C                   z-add     recno         y
     *
     *  SAVE FILE AND UNIQUE KEYS
     *
     C                   eval      fkey(y) = $pofky
     C                   eval      ukey(y) = $pouky
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
     *
     C                   select
     C                   when      view = '*POITEM '
     C                   write     dspsfl1
     *
     C                   when      view = '*POMFR  '
     C                   write     dspsfl3
     *
     C                   endsl
     C                   endif
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLAD4   Add record to Window subfile 4
     *
     C     sflad4        begsr
     *
     C                   eval      hseq = pdseq
     C                   eval      hitem = pditem
     C                   eval      hvitm = pdvitm
     C                   add       1             recno4
     C                   write     dspsfl4
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLAD5   Add record to Window subfile 5
     *
     C     sflad5        begsr
     *
     C                   add       1             recno4
     C                   write     dspsfl5
     *
     C                   endsr
417a *----------------------------------------------------------------
417a *
417a *  SFLAD6   Add record to Window subfile 6
417a *
417a C     sflad6        begsr
417a *
417a C                   add       1             recno4
417a C                   write     dspsfl6
417a *
417a C                   endsr
417k *----------------------------------------------------------------
417k *
417k *  SFLAD7   Add record to Window subfile 7
417k *
417k C     sflad7        begsr
417k *
417k C                   add       1             recno4
417k C                   write     dspsfl7
417k *
417k C                   endsr
417l *----------------------------------------------------------------
417l *
417l *  SFLAD8   Add record to Window subfile 8
417l *
417l C     sflad8        begsr
417l *
417l C                   add       1             recno4
417l C                   write     dspsfl8
417l *
417l C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      *in01 = *off
     C                   select
     C                   when      uxflag = *off  and
     C                             $spo = '*NO '
     C                   select
     C                   when      view = '*POITEM '
     C                   write     dspsfc
     *
     C                   when      view = '*POMFR  '
     C                   write     dspsfc2
     *
     C                   endsl
     *
     C                   other
     *
     C                   select
     C                   when      view = '*POITEM '
     C                   write     dspsfc1
     *
     C                   when      view = '*POMFR  '
     C                   write     dspsfc3
     *
     C                   endsl
     C                   endsl
     *
     C                   eval      recno = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile , Item seq - Single line description.
     *
     C     sfldsp        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     C                   write     optrec
     C                   write     cmdrec
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     C                   write     postnrec
     C                   write     scanrec
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflopt
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> *on
     C     1             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      *in20 = *on
520aA*    Restore item message indicator.
520aAC                   eval      *in39 = hldi39
     C                   update    dspsfl
     C                   endif
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
     C                   write     dspsfc
CCPa C                   if        client=CapitolCity
CCPa C                   eval      *in22 = *on
CCPa C                   eval      *in20 = *off
CCPa C                   write     scanrec
CCPa C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDS1   Display subfile 1 , Item Seq - Extended description.
     *
     C     sflds1        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     C                   write     optrec
     C                   write     cmdrec
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     C                   write     postnrec
     C                   write     scanrec
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflop1
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> '1'
     C     1             chain     dspsfl1                            79
     C                   if        not *in79
     C                   eval      *in20 = *on
520aA*    Restore item message indicator.
520aAC                   eval      *in39 = hldi39
     C                   update    dspsfl1
     C                   endif
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
     C                   write     dspsfc1
CCPa C                   if        client=CapitolCity
CCPa C                   eval      *in22 = *on
CCPa C                   eval      *in20 = *off
CCPa C                   write     scanrec
CCPa C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDS2   Display subfile 2 - Mfr# Seq - Single line desc.
     *
     C     sflds2        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     C                   write     optrec
     C                   write     cmdrec
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     C                   write     postnrc2
     C                   write     scanrec2
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflop2
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> *on
417nD*R         1         CHAINDSPSFL               79
417nMC     1             chain     dspsfl2                            79
     C                   if        not *in79
     C                   eval      *in20 = *on
520aA*    Restore item message indicator.
520aAC                   eval      *in39 = hldi39
     C                   update    dspsfl2
     C                   endif
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
     C                   write     dspsfc2
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDS3   Display subfile 3 , Mfr# Seq. Extended description
     *
     C     sflds3        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     C                   write     optrec
     C                   write     cmdrec
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     C                   write     postnrc2
     C                   write     scanrec2
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflop3
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> *on
     C     1             chain     dspsfl3                            79
     C                   if        not *in79
     C                   eval      *in20 = *on
520aA*    Restore item message indicator.
520aAC                   eval      *in39 = hldi39
     C                   update    dspsfl3
     C                   endif
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
     C                   write     dspsfc3
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
     C     1             do        prcrec        x
     C     x             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt                            78
     C                   if        not *in78
     C                   eval      option = wkoopt
     C                   eval      *in21 = wkoerr
     C                   eval      *in20 = wkoerr
     C                   else
     C                   eval      option = *blanks
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
     C                   endif
520aA*    Restore item message indicator.
520aAC                   eval      *in39 = hldi39
     C                   update    dspsfl
     C                   endif
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOP1   Initialize options for subfile 1, extended description
     *
     C     sflop1        begsr
     C     1             do        05            x
     C     x             chain     dspsfl1                            79
     C                   if        not *in79
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt                            78
     C                   if        not *in78
     C                   eval      option = wkoopt
     C                   eval      *in21 = wkoerr
     C                   eval      *in20 = wkoerr
     C                   else
     C                   eval      option = *blanks
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
     C                   endif
520aA*    Restore item message indicator.
520aAC                   eval      *in39 = hldi39
     C                   update    dspsfl1
     C                   endif
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOP2   Initialize options for subfile 2 - Single line Mfr seq.
     *
     C     sflop2        begsr
     C     1             do        prcrec        x
     C     x             chain     dspsfl2                            79
     C                   if        not *in79
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt                            78
     C                   if        not *in78
     C                   eval      option = wkoopt
     C                   eval      *in21 = wkoerr
     C                   eval      *in20 = wkoerr
     C                   else
     C                   eval      option = *blanks
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
     C                   endif
520aA*    Restore item message indicator.
520aAC                   eval      *in39 = hldi39
     C                   update    dspsfl2
     C                   endif
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOP3   Initialize options for subfile 3, ext. desc. Mfr# Seq.
     *
     C     sflop3        begsr
     C     1             do        05            x
     C     x             chain     dspsfl3                            79
     C                   if        not *in79
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt                            78
     C                   if        not *in78
     C                   eval      option = wkoopt
     C                   eval      *in21 = wkoerr
     C                   eval      *in20 = wkoerr
     C                   else
     C                   eval      option = *blanks
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
     C                   endif
520aA*    Restore item message indicator.
520aAC                   eval      *in39 = hldi39
     C                   update    dspsfl3
     C                   endif
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMCMS4  Clear message record subfile in WINDOW4
     *
     C     zmcms4        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl4
     C                   eval      msgk4 = *zeros
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpms4
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   write     msgclr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr
     *
     *    ZMDMS4  Display message record subfile in WINDOW4
     *
     C     zmdms4        begsr
     C                   write     msgclr4
     C                   eval      *in97 = *on
     C                   if        msgk4 > 0
     C                   write     msgctl4
     C                   eval      msgk4 = *zeros
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
     *    ZMIMS4  Initialization necessary for message subfile in WINDOW4
     *
     C     zmims4        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcms4
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
     C                   parm      #prog         #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMPMS4  Add message record to subfile in WINDOW4
     *
     C     zmpms4        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      #prog         #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk4
     C                   write     msgrec4
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *
     *    ZMQMS4  Add message record to subfile from pgm queue in WINDOW4
     *
     C     zmqms4        begsr
     C                   add       1             msgk4
     C                   write     msgrec4
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     *R                   WRITECLRSCR
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      '*PREV'       #pgmq
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMnnnn  Build and send message nnnn to this program
640eA*----------------------------------------------------------------
640eA*    DRI0001  Local system caused error
640eA*----------------------------------------------------------------

640eAC     zm0001        begsr
640eAC                   if        %subst($drimessage:1:2) = 'H:'
640eAC                   move      'DRI0002'     #msgid
640eAC                   eval      $drimessage = %subst($drimessage:3)
640eAC                   else
640eAC                   move      'DRI0001'     #msgid
640eAC                   endif
640eAC                   eval      #msgtp = '*DIAG'
640eAC                   eval      #msgdt = $drimessage + $drireturn
640eAC                                    + $dricommand + $drisubcmd
640eAC                   exsr      zmpmsg
640eAC                   endsr

640eA*----------------------------------------------------------------
640eA*    DRI0001s Local system caused error (send to different program)
640eA*----------------------------------------------------------------

640eAC     zm0001s       begsr
640eAC                   if        %subst($drimessage:1:2) = 'H:'
640eAC                   move      'DRI0002'     #msgid
640eAC                   eval      $drimessage = %subst($drimessage:3)
640eAC                   else
640eAC                   move      'DRI0001'     #msgid
640eAC                   endif
640eAC                   eval      #msgtp = '*DIAG'
640eAC                   eval      #msgdt = $drimessage + $drireturn
640eAC                                    + $dricommand + $drisubcmd
640eAC                   exsr      zmsmsg
640eAC                   eval      $pmsg = #msgk
640eAC                   endsr

FKLbA*----------------------------------------------------------------
FKLbA*    PO12004  Stuffit Receivng not allowed for item.
FKLbA*
FKLbAC     zm2004        begsr
FKLbAC                   eval      #msgid = 'PO12004'
FKLbAC                   eval      #msgtp = '*DIAG  '
FKLbAC                   movea     errmsg        $md(1)
FKLbAC                   exsr      zmpmsg
FKLbAC                   endsr
650hA*----------------------------------------------------------------
650hA*    PO12005  PTI selection Item - must scan UCI at receiving
650hA*
650hAC     zm2005        begsr
650hAC                   eval      #msgid = 'PO12005'
650hAC                   eval      #msgtp = '*DIAG  '
650hAC                   movea     errmsg        $md(1)
650hAC                   exsr      zmpmsg
650hAC                   endsr
416cA*----------------------------------------------------------------
416cA*    PO13236  Position to x not found on Super P/O.
416cA*
416cAC     zm3236        begsr
416cAC                   eval      #msgid = 'PO13236'
416cAC                   eval      #msgtp = '*DIAG  '
416cAC                   movea     errmsg        $md(1)
416cAC                   exsr      zmpmsg
416cAC                   endsr
     *----------------------------------------------------------------
     *    PO20027  Item not on PO.
     *
     C     zm027         begsr
     C                   eval      #msgid = 'PO20027'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO20029  UPC not on file.
     *
     C     zm029         begsr
     C                   eval      #msgid = 'PO20029'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    IT12001  Item does not have a link record.
     *
     C     zm1201        begsr
     C                   eval      #msgid = 'IT12001'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    IT12212  Item does not have a Piritem record.
     *
     C     zm2212        begsr
     C                   eval      #msgid = 'IT12212'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    IT12002  Item does not have a pick slot.
     *
     C     zm1202        begsr
     C                   eval      #msgid = 'IT12002'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0101  Program not found.
     *
     C     zm0101        begsr
     C                   eval      #msgid = 'PIR0101'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0102  Program not found.
     *
     C     zm0102        begsr
     C                   eval      #msgid = 'PIR0102'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0103  Program not found while exec. subroutine.
     *
     C     zm0103        begsr
     C                   eval      #msgid = 'PIR0103'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0104  Pressed an invalid key.
     *
     C     zm0104        begsr
     C                   eval      #msgid = 'PIR0104'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *
     C     z40105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpms4
     C                   endsr
     *----------------------------------------------------------------
     *      0106  Invalid cursor position.
     *
     C     zm0106        begsr
     C                   eval      #msgid = 'PIR0106'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0107  Invalid value for "position To"
     *
     C     zm0107        begsr
     C                   eval      #msgid = 'PIR0107'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0108  Invalid Option.
     *
     C     zm0108        begsr
     C                   eval      #msgid = 'PIR0108'
     C                   eval      #msgtp = '*DIAG  '
     C                   movel     option        errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *    Error message for WINDOW4.
     C     z40108        begsr
     C                   eval      #msgid = 'PIR0108'
     C                   eval      #msgtp = '*DIAG  '
     C                   movel     option        errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpms4
     C                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
770dA*----------------------------------------------------------------
770dA*   PIR9911  Invalid item department.
770dA*
770dAC     zm9911        begsr
770dAC                   eval      #msgid = 'PIR9911'
770dAC                   eval      #msgtp = '*DIAG  '
770dAC                   eval      $md = *blanks
770dAC                   exsr      zmpmsg
770dAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD    Process non-standard function keys
     *
     C     zzcmd         begsr
     *
     *  TEST FOR CMD07 - Sub totals.
     *
     C                   if        *inkg
     *
     C                   eval      ovrtyp = '*SUBTOTL'
     C                   exsr      zzwdw
     *
     C                   goto      endcm1
     C                   endif
500 A*
500 A*  TEST FOR CMD08 - Item Sub totals.
500 A*
500 AC                   if        *inkh
500 A*
500 AC                   eval      ovrtyp = '*SUBITTL'
500 AC                   exsr      zzwdw
500 A*
500 AC                   goto      endcm1
500 AC                   endif
     *
     *  TEST FOR CMD23 - More options
     *
     C                   if        *inkx
     C                   if        viewo = maxvwo
     C                   eval      viewo = 1
     C                   else
     C                   add       1             viewo
     C                   endif
     C                   eval      v = viewo * 2
PCK AC                   select
PCK AC                   when      client = packer
PCK AC                   eval      optln2 = optlnp(v)
PCK AC                   eval      v = v - 1
PCK AC                   eval      optln1 = optlnp(v)
YHAbAC                   when      client = yhata
YHAbAC                   eval      optln2 = optlny(v)
YHAbAC                   eval      v = v - 1
YHAbAC                   eval      optln1 = optlny(v)
PCK AC                   other
     C                   eval      optln2 = optln(v)
     C                   eval      v = v - 1
     C                   eval      optln1 = optln(v)
PCK AC                   endsl
500cAC                   if        $cmd = '*SPRECV'  and
500cAC                             v = 1
500cAC                   eval      optln1 = optlns(v)
500cAC                   endif
     C                   goto      endcm1
     C                   endif
     *
     *  TEST FOR CMD24 - More Keys
     *
     C                   if        *inky
     C                   add       1             k
     C                   if        k > 2
     C                   eval      k = 1
     C                   endif
     *
     C                   select
     C                   when      k = 1
     C                   select
     C                   when      view = '*POITEM '  and
500e C                             $spo = '*YES'
     C                   eval      cmdln1 = cmdln(3)
     C                   when      view = '*POMFR  '  and
500e C                             $spo = '*YES'
     C                   eval      cmdln1 = cmdln(4)
500e C                   when      view = '*POITEM '  and
500e C                             $spo = '*NO '
500e C                   eval      cmdln1 = cmdln(1)
500e C                   when      view = '*POMFR  '  and
500e C                             $spo = '*NO '
500e C                   eval      cmdln1 = cmdln(2)
     C                   endsl
     C                   when      k = 2
     C                   eval      cmdln1 = cmdln(5)
     C                   endsl
     *
     C                   goto      endcm1
     C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     C                   eval      noupc = *off
417m C                   eval      upcok = *off
640dAC                   eval      noasn = *off
640dAC                   eval      asnok = *off

640dAc                   eval      $lqty = 0
640dAc                   eval      $l#pall = 0
640dAc                   eval      $lexpdt = 0
640dAc                   eval      $lwgt   = 0
640dAc                   eval      $lmfgdt = 0
640dAc                   eval      $llot = ' '
650hAc                   eval      $bcGtinSent = '0'
640dAc                   if        w1uci <> *blanks
650hA * retrieve vendor for regular po
650hA /free
650hA   if $kpo <> ' ';
650hA    chain(n) ($kwhse: $kpo) pohdr;
650hA   endif;
650hA /end-free
640dA * add the conversion of the uci barcode
640dAC                   eval      $cbcmd = '*ALL    '
640dAC                   eval      $cbbar = w1uci
640dAc                   clear                   $barcode
640dAc                   clear                   $barcode2
640dA*
640dAC                   call      'CVTBAR'
640dAC                   parm                    $cbcmd            8
640dAC                   parm                    $cbbar          100
640dAC                   parm                    $cbcod            3 0
640dAC                   parm                    $cbdec            1 0
640dAC                   parm                    $cbdsc           30
640dAC                   parm                    $cbpos            3 0
640dAC                   parm                    $cbtyp            1 0
640dAC                   parm                    $cbv1            11 3
640dAC                   parm                    $cbv2            50
640dAC                   parm                    $cbrtn            8
640dAC                   parm                    $cberm           60
650hDC*                  parm                    $cbven           10 0
650hMC                   parm      phven         $cbven           10 0
640dAC                   parm                    $cvtdata
640dAC                   parm                    $cvtdata2
640dAc                   endif
710bMc                   if        $cbrtn = '*NOMORE'
740cAc                             or $cbrtn = '*OK'
710bDc*                  if        $bcGtinSent
640dAc                   eval      $barcode = $cvtdata
640dAc                   eval      $barcode2 = $cvtdata2
710cAc                   endif
640dA * Load UPC
710aDc*                  if        $bcGtinSent
710cAc                   if        $bcGtinSent
640dAc                   eval      w1upcd = $bcGtin
640eAc                   else
640gA ** Needed this because all barcodes are not gs1
640gDc*                  eval      w1upcd = ' '
640gMc                   eval      w1upcd = w1uci
640gDc*                  exsr      zm029
640h c* if $bcgtinsent is not on we don't know what item this is.
640h c* so turn off all the other $bc sent fields, without the item non of
640h c* these are valid for our receiving purposes.
640h c                   eval      $bcExpDSent = *off
700bAc                   eval      $bcSlByDSent = *off
640hAc                   eval      $bcProdDSent = *off
710bAc                   eval      $bcPackDSent = *off
640hAc                   eval      $bcPNtLbSent = *off
640hAc                   eval      $bcLotSent = *off
640dAc                   endif
640dA * Load Expiration Date
700bAc                   select
700bDc*                  if        $bcExpDSent
700bMc                   when      $bcExpDSent
640dAc                   eval      $lexpdt = $bcExpD
700bAc                   when      $bcSlByDSent
700bAc                   eval      $lexpdt = $bcSlByD
700bDc*                  endif
700bMc                   endsl
640dA * Load Manufacturing Date
640dAc                   if        $bcProdDSent
640dAc                   eval      $lmfgdt = $bcProdD
640dAc                   endif
710bA * Load Manufacturing Date
710bAc                   if        $bcPackDSent
710bAc                   eval      $lmfgdt = $bcPackD
710bAc                   endif
640dA * Load Catch Weight
640dAc                   if        $bcPNtLbSent
650oAc                             and $ifrcvmth = '2'
640dAc                   eval      $lwgt   = $bcPNtLb
640dAc                   endif
640dA * Load Lot
640dAc                   if        $bcLotSent
640dAc                   eval      $llot   = $bcLot
640dAc                   endif
640dAc*                  eval      w1uci = ' '
640dAc*                  endif
640dA * ASN LPN scanned
640dAc                   if        w1asn <> *blanks
640dAc                   eval      $acmd = '*GETLPN'
640dAc                   call      'GETASN'
640dAc                   parm                    $acmd             8
640dAc                   parm      ' '           $artn             8
640dAc                   parm      $kwhse        $awhse            3 0
640dAc                   parm      $kpo          $apo              9
640dAc                   parm      w1asn         $aLPN            50
640dAc                   parm      ' '           $alcns           15
640dAc                   parm      ' '           $alot            20
640dAc                   parm      ' '           $aitem           15
640dAc                   parm      0             $aseq             5 0
640dAc                   parm      0             $aqty             8 0
640dAc                   parm      0             $amfgdt           6 0
640dAc                   parm      0             $aexpdt           6 0
640dAc                   parm      0             $awgt            11 3
640dAc                   parm      ' '           $aupc            20
640dA * invalid LPN scanned
640dAc                   if        $artn = '*INVALID'
640dAc                   eval      error = *on
640dAC                   eval      *in29 = *on
640dAC                   eval      *in09 = *on
640dAC                   eval      errmsg = err03
640dAC                   exsr      zm0105
640dAC                   eval      noasn = *on
640dAc                   endif

640dAc                   if        $artn = '*OK'
640dA * Load item
640dAc                   if        $aitem <> ' '
640dAc                   eval      pditem  = $aitem
640dAc                   eval      $aitem = ' '
640dAc                   endif
640dA * Load pieces
640dAc                   if        $aqty > 0
640dAc                   eval      $lqty   = $aqty
640dAc                   endif
640dA * Load # of pallets
640dAc                   if        $aqty > 0
640dAc                   eval      $l#pall = 1
640dAc                   else
640dAc                   eval      $l#pall = 0
640dAc                   eval      $aqty = 0
640dAc                   endif
640dA * Load Expiration Date
640dAc                   if        $aexpdt > 0
640dAc                   eval      $lexpdt = $aexpdt
640dAc                   eval      $aexpdt = 0
640dAc                   endif
640dA * Load Manufacturing Date
640dAc                   if        $amfgdt > 0
640dAc                   eval      $lmfgdt = $amfgdt
640dAc                   eval      $amfgdt = 0
640dAc                   endif
640dA * Load Catch Weight
640dAc                   if        $awgt > 0
640dAc                   eval      $lwgt   = $awgt
640dAc                   eval      $awgt   = 0
640dAc                   endif
640dA * Load Lot
640dAc                   if        $alot <> ' '
640dAc                   eval      $llot   = $alot
640dAc                   eval      $alot   = ' '
640dAc                   endif

640dA * Load upc
640dAc                   if        $aupc <> ' '
640dAc                   eval      $lupc   = $aupc
640dAc                   endif

640dAc                   endif
640dAc                   endif
     *
     *  UPC not entered.
     *
417bD*R         W1UPC     IFEQ *BLANKS
417bMC                   if        w1upcd = *blanks
     C                   eval      noupc = *on
     C                   eval      woupc = *blanks
     C                   endif
640dA*
640dA*  ASN not entered.
640dA*
640dAC                   if        w1asn  = *blanks
640dAC                   eval      noasn = *on
640dAC                   eval      woasn = *blanks
640dAC                   endif
     *
     *  UPC code not on file.
     *
417bD*R         W1UPC     IFNE *BLANKS
417bMC                   if        w1upcd <> *blanks
640dAc                             or w1asn <> *blanks
417bD*R                   MOVE W1UPC     WOUPC
417bA*
     *  Extract UPC code from entered string.
     *
640dAc                   if        w1upcd <> *blanks
     C                   eval      $cbcmd = '*UPC    '
     C                   eval      $cbbar = w1upcd
640dAc                   if        $bcGtinSent
640dAc                   eval      $cbbar = $bcGtin
640dAc                   endif
     *
     C                   call      'CVTBAR'
     C                   parm                    $cbcmd            8
     C                   parm                    $cbbar          100
     C                   parm                    $cbcod            3 0
     C                   parm                    $cbdec            1 0
     C                   parm                    $cbdsc           30
     C                   parm                    $cbpos            3 0
     C                   parm                    $cbtyp            1 0
     C                   parm                    $cbv1            11 3
     C                   parm                    $cbv2            50
     C                   parm                    $cbrtn            8
     C                   parm                    $cberm           60
740cAC                   parm      phven         $cbven           10 0
740cAC                   parm                    $cvtdata
740cAC                   parm                    $cvtdata2
     *
     C                   select
417hM**         $CBRTN    WHEQ '*OK'
417hAC                   when      $cbrtn <> '*INVALID'
EFCbAC                             or client = eastland
YHAaAC                             or client = yhata
     *
     *   Right adjust UPC code for file.
     *
     C                   eval      $cstr = *blanks
417bD*R                   MOVELW1UPC     $CSTR
EFCbAC                   if        client = eastland
EFCbAC                             and $cbv2 = *blanks
EFCbAC                   movel     $cbbar        $cstr
EFCbAC                   else
     C                   movel     $cbv2         $cstr
EFCbAC                   endif
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
     C                   move      $cstr         w1upc
417a *   Check if mulitple items exist for one UPC code.
417a *    UPCCTR = 0, error, upc code not found.
417a *    UPCCTR = 1, only one upc found, process for item.
417a *    UPCCTR > 1, multiple upc found, need to select item.
650hA * this was moved to subrouting zzchkupc
650hDC*                  eval      upcctr = 0
650hDc*                  eval      svupci = ' '
650hDC*    upckey        setll     upc
650hDC*                  dow       forevr = forevr
650hDC*    upckey        reade     upc                                    79
     *
650hDC*                  if        *in79
650hDC*                  leave
650hDC*                  else
650hDC*                  if        svupci <> upitem
650hDC*                  add       1             upcctr
650hDC*                  eval      svupci = upitem
650hDC*                  endif
650hDC*                  endif
     *
650hDC*                  enddo
650hMc                   exsr      zzchkupc
     *
417aD**         UPCKEY    CHAINUPC                  79
417aD**         *IN79     IFEQ *ON
650iDC*                  if        upcctr = 0
650iDc*                  if        $ifrcvmth <> ' ' or $ifsltmth = '3'
650hA * lets allow the user to add using UC112
650hAc
650hA /free
650iD    // save the item field first
650iD    //sav$litem = $litem;
650iD    //$lcmd  = '*ADD';
650iD    //$lwhse = $kwhse;
650iD    //$litm = ' ';
650iD    //$lupc1 = w1upc;
650iD    //chain(n) ($pwhse: pdpo) pohdr;
650iD      //if %found(pohdr);
650iD        //$lven = phven;
650iD      //else;
650iD        //$lven = 0;
650iD      //endif;
650hA /end-free
650iDc*                  call      'UC112'
650iDC*                  parm                    $lparm
650iD * then do recheck on upc
650iDc*                  exsr      zzchkupc
650iDc*                  endif
650iDc*                  endif
650iDc*                  eval      $litem = sav$litem
417a C                   if        upcctr = 0
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   exsr      zm029
     C                   eval      noupc = *on
     C                   endif
     *   Multiple items exist for UPC
417m C                   if        upcctr = 1
417m C                   eval      upcok = *on
417m C                   endif
417a C                   if        upcctr > 1
417a C                   eval      ovrtyp = '*UPCSLCT'
417a C                   exsr      zzwdw
417a C                   endif
417bA*
417bA*    If extract of UPC comes back invalid, treat UPC as if not
417bA*    on file.
     C                   other
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   exsr      zm029
     *    Log barcode conversion error.
     C                   movel     $cberm        errmsg
     C                   exsr      zm0105
     C                   eval      noupc = *on
     C                   endsl
640dAc                   endif
     *
     *   Verify Item exists on PO.
     *
     C                   if        noupc = *off
640dAC                             or noasn = *off
     C                   select
     *    Single P/O being processed.
     C                   when      $spo = '*NO '
     *
640dAc                   if        noupc = *off
     C                   eval      woitm# = upitem
640dAc                   endif
640dAc                   if        noasn = *off
640dAC                   eval      woitm# = pditem
640dAc                   endif
     C     podky1        setll     podtl1                             79
     C     podky1        reade     podtl1                                 79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
640dAc                   if        noupc = *off
417m C                   eval      upcok = *off
640dAc                   endif
640dAc                   if        noasn = *off
640dAC                   eval      asnok = *off
640dAc                   endif
     C                   exsr      zm027
417i C                   else
417i C                   eval      optslt = *on
640dAc                   if        noupc = *off
417m C                   eval      upcok = *on
640dAc                   endif
640dAc                   if        noasn = *off
640dAC                   eval      asnok = *on
640dAc                   endif
     C                   endif
     *
     *    Super P/O being processed.
     C                   when      $spo = '*YES'
     C                   eval      ptinp1 = upitem
     C                   eval      pditem = upitem
     C                   eval      ovrtyp = '*SLCTITM'
     C                   exsr      zzwdw
     C                   eval      ptinp1 = *blanks
     C                   select
     *    UPC not found on any P/O.
     C                   when      repos = *off
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
417m C                   eval      upcok = *off
     C                   exsr      zm027
416aA*    UPC found and selected for one p/o.
416aAC                   when      repos = *on
416aAC                   eval      pdseq = hseq
416aAC                   eval      pditem = hitem
416aAC                   eval      pdvitm = hvitm
417jAC                   eval      optslt = *on
417m C                   eval      upcok = *on
     C                   endsl
     *
     C                   endsl
     *
     *    Clear position to save fields when working with UPC.
     C                   eval      svp2po = *blanks
     C                   eval      svp2vl = *blanks
     *
     C                   endif
     *
     C                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHEK   Screen 1 EXTRA error checking.
     *
     C     zzchek        begsr
500gA*
500gA*   Do HACCP Checks
500gA*
640fA*  TEST FOR new Haccp Programs
640fA*
640fA * check to make sure programs exist or don't do call
640fAC                   eval      qcmd = 'CHKOBJ '
640fAC                                  + 'OBJ(HA410) '
640fAC                                  + 'OBJTYPE(*PGM)'
640fAC                   call      'QCMDEXC'                            78
640fAC                   parm                    qcmd            256
640fAC                   parm      80            qlen             15 5
640fAc                   if        *in78 = *on
500gAC                   if        wkoopt = ' 1'
500gAC                   eval      $pcmd = '*DTLCHK '
500gAC                   call      'PO170'
500gAC                   parm                    $parms
500gAC                   if        $prtn = '*PGMQ   '
500gAC                   eval      error = *on
500gAC                   eval      #msgk = $pmsg
500gAC                   exsr      zmqmsg
500gAC                   goto      endchk
500gAC                   endif
500gAC                   endif
640fAC                   endif
     C     itkey2        chain     piritem                            79
     C                   if        *in79
     C                   eval      ittype = *blanks
     C                   eval      error = *on
     C                   exsr      zm2212
     C                   endif
770dA* Item Dept cannot be default dept 'UNK'
770dAC                   if        itwhdp = 'UNK'
770dAC                   eval      error = *on
770dAC                   exsr      zm9911
770dAC                   goto      endchk
770dAC                   endif
770dA*
FKLbAC                   if        client = finkle
FKLbAC                   if        $cmd = '*SPRECV'  and
FKLb C                             itwhdp <> 'DRYC'
FKLb C                   eval      error = *on
FKLb C                   exsr      zm2004
FKLb C                   goto      endchk
FKLb C                   endif
FKLbAC                   endif
700aA*
     *  Verify OSS code is valid.
SBRaAC                   select
SBRaAC                   when      client = SBertram
SBRaAC                   if        option = ' 1'
SBRaAC                   if        osscode <> ' ' and
SBRaAC                             osscode <> 'B' and
SBRaAC                             osscode <> 'C'
SBRbAC                             and osscode <> 'D'
SBRcAC                             and osscode <> 'F'
SBRdAC                             and osscode <> 'I'
SBRaAC                   eval      error = *on
SBRaAC                   eval      option = oopt
SBRaAC                   eval      errmsg = *blanks
SBRaAC                   exsr      zm0108
SBRaAC                   goto      endchk
SBRaAC                   endif
SBRaAC                   if        osscode = 'B' and
SBRaAC                             itwhdp <> 'DRY'
SBRaAC                   eval      error = *on
SBRaAC                   eval      option = oopt
SBRaAC                   eval      errmsg = *blanks
SBRaAC                   eval      errmsg = 'Invalid option '
SBRaAC                                    + oopt
SBRaAC                                    + ' for item department '
SBRaAC                                    + itwhdp
SBRaAC                   exsr      zm0105
SBRaAC                   goto      endchk
SBRaAC                   endif
SBRaAC                   if        osscode = 'C' and
SBRaAC                             itwhdp <> 'FRZ'
SBRaAC                   eval      error = *on
SBRaAC                   eval      option = oopt
SBRaAC                   eval      errmsg = *blanks
SBRaAC                   eval      errmsg = 'Invalid option '
SBRaAC                                    + oopt
SBRaAC                                    + ' for item department '
SBRaAC                                    + itwhdp
SBRaAC                   exsr      zm0105
SBRaAC                   goto      endchk
SBRaAC                   endif
SBRbAC                   if        osscode = 'D' and
SBRbAC                             itwhdp <> 'FRZ'
SBRbAC                   eval      error = *on
SBRbAC                   eval      option = oopt
SBRbAC                   eval      errmsg = *blanks
SBRbAC                   eval      errmsg = 'Invalid option '
SBRbAC                                    + oopt
SBRbAC                                    + ' for item department '
SBRbAC                                    + itwhdp
SBRbAC                   exsr      zm0105
SBRbAC                   goto      endchk
SBRbAC                   endif
SBRcAC                   if        osscode = 'F' and
SBRcAC                             itwhdp <> 'FRZ'
SBRcAC                   eval      error = *on
SBRcAC                   eval      option = oopt
SBRcAC                   eval      errmsg = *blanks
SBRcAC                   eval      errmsg = 'Invalid option '
SBRcAC                                    + oopt
SBRcAC                                    + ' for item department '
SBRcAC                                    + itwhdp
SBRcAC                   exsr      zm0105
SBRcAC                   goto      endchk
SBRcAC                   endif
SBRdAC                   if        osscode = 'I' and
SBRdAC                             itwhdp <> 'FRZ'
SBRdAC                   eval      error = *on
SBRdAC                   eval      option = oopt
SBRdAC                   eval      errmsg = *blanks
SBRdAC                   eval      errmsg = 'Invalid option '
SBRdAC                                    + oopt
SBRdAC                                    + ' for item department '
SBRdAC                                    + itwhdp
SBRdAC                   exsr      zm0105
SBRdAC                   goto      endchk
SBRdAC                   endif
700aA*
SBRaAC                   endif
FGLaA*
FGLaAC                   when      client = FoodsGalore
FGLaAC                   if        option = ' 1'
FGLaAC                   if        osscode <> ' '
FGLaAC                             and osscode <> 'C'
FGLaAC                             and osscode <> 'I'
FGLaAC                   eval      error = *on
FGLaAC                   eval      option = oopt
FGLaAC                   eval      errmsg = *blanks
FGLaAC                   exsr      zm0108
FGLaAC                   goto      endchk
FGLaAC                   endif
FGLaAC                   endif
FGLaA*
SBRaAC                   endsl
     *  Item link record must exist.
     C                   if        ittype = 'A'  or
     C                             ittype = 'B'  or
     C                             ittype = 'C'  or
     C                             ittype = 'S'
     C     ilkey         chain     itemlnk                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm1201
     C                   endif
     C                   endif
650hA*  Edit for items with selection method = 3. Must scan uci
650hAc
650hA * add dri to get data from itemfld
650hA /free
650hA       exsr clr$item;

650hA       $itWhse = $kwhse;
650hA       $ititem = $pitem;

650hA       $dricommand = '*ITEM';
650hA       $drisubcmd  = '%GETALL';
650hA       $drisys2upd = 'D';
650hA       chk4err = *on;
650hA       zmflag  = *off;
650hA       exsr zzzdricop;
650hA       if error = *on;
650hA         $ifucicde = ' ';
650hA         $ifrcvmth = ' ';
650hA         $ifsltmth = ' ';
650hA       else;
650nD         //if $ifsltmth = '3' or
650nM         if $ifsltmth = '3';
650nD            //$ifucicde <> '1'and $ifrcvmth <> '2';
650hA           // uci must be scanned to start receiving
650hA           if $bcgtinsent = '0';
650hA             error = *on;
650hA             exsr zm2005;
650hA             leavesr;
650hA           endif;
650hA         endif;
650hA       endif;
650hA /end-free
     *  Fixed item - Pick slot must exist
     C                   if        itstyp = 'F'
     C                   select
     C                   when      ittype = ' '
     C                   eval      bsitem = $pitem
     C                   eval      bsstat = 'A '
     C                   eval      bspick = 'Y'
     C     slkey3        setll     slot3
     C                   dow       forevr = forevr
     C     slkey3        reade     slot3                                  79
     *
     C                   if        not *in79  and
     C                             slpick = 'Y'
     C                   goto      endchk
     C                   endif
     *
     C                   if        *in79
     *R                   MOVE *ON       ERROR
     *R                   EXSR ZM1202
     C                   goto      endchk
     C                   endif
     *
     C                   enddo
     *
     C                   when      ittype = 'A'  or
     C                             ittype = 'B'  or
     C                             ittype = 'C'  or
     C                             ittype = 'S'
     C     ilkey         chain     itemlnk                            79
     C                   if        not *in79
     C                   eval      bsitem = ilitm2
     C                   endif
     C                   eval      bsstat = 'A '
     C                   eval      bspick = 'Y'
     C     slkey3        setll     slot3
     C                   dow       forevr = forevr
     C     slkey3        reade     slot3                                  79
     *
     C                   if        not *in79  and
     C                             slpick = 'Y'
     C                   goto      endchk
     C                   endif
     *
     C                   if        *in79
500fD*                    MOVE *ON       ERROR
500fD*                    EXSR ZM1202
     C                   goto      endchk
     C                   endif
     *
     C                   enddo
     *
     C                   endsl
     C                   endif
     C     endchk        endsr
650hA*----------------------------------------------------------------
650hA*
650hA*  ZZCHKUPC Check upc.
650hA*
650hAC     zzchkupc      begsr
650hM*   Check if mulitple items exist for one UPC code.
650hM*    UPCCTR = 0, error, upc code not found.
650hM*    UPCCTR = 1, only one upc found, process for item.
650hM*    UPCCTR > 1, multiple upc found, need to select item.
650hMC                   eval      upcctr = 0
650hMc                   eval      svupci = ' '
650qDC*    upckey        setll     upc
650qMC     upckey        setll     upc4
650hMC                   dow       forevr = forevr
650qDC*    upckey        reade     upc                                    79
650qMC     upckey        reade     upc4                                   79
650hM*
650hMC                   if        *in79
650hMC                   leave
650hMC                   else
650hMC                   if        svupci <> upitem
650hMC                   add       1             upcctr
650hMC                   eval      svupci = upitem
650hMC                   endif
650hMC                   endif
650hM*
650hMC                   enddo
650hAC                   endsr
     *----------------------------------------------------------------
CLDaA*
CLDaA*  ZZCKRC   Check P/O to see if all detail lines have been received
CLDaA*           or touched.  If so, update stop time in SMARTDOCK file.
CLDaA*
CLDaAc     zzckrc        begsr
CLDaA
     c                   eval      $ok = *on
     c     partky        setll     podtl
     c     partky        reade     podtl                                  85
     c                   if        %eof
     c                   eval      $ok = *off
     c                   endif
     c     *in85         doweq     *off
     c     detlky        chain     podtl3
     c                   if        not %found(podtl3)
     c                   eval      $ok = *off
     c                   leave
     c                   endif
     c     partky        reade     podtl                                  85
     c                   enddo

     c                   if        $ok = *on
     c                   exsr      zzSDstop
     c                   endif

     c                   endsr
     *----------------------------------------------------------------
     *
416fA*  ZZDESG   Check dept-designation file fro putaway method.
416fA*
416fAC     zzdesg        begsr
     C     itkey2        chain     piritem                            79
     C                   if        *in79
     C                   goto      enddsg
     C                   endif
     *
     C     ddkeyp        setll     deptdsg
     C                   eval      puttyp = *off
     C                   dow       forevr = forevr
     C     ddkeyp        reade     deptdsg                                79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   if        dddesg = itdesg
     C                   eval      puttyp = *on
     C                   leave
     C                   endif
     C                   enddo
416fAC     enddsg        endsr
650mA*----------------------------------------------------------------
650mA*
650mA*  ZZEND   End timer
650mA*
650mAC     zzend         begsr
     *
650mAc                   eval      pgtnsc = nxtscr
650mAC                   callp     getmicrotime(currstampuc:currstampsys)
650mAc                   eval      pgtEndts = currstampsys
     *
650mAc     pgtEndts      subdur    pgtStrts      dsecs:*s
650mAc                   eval(h)   pgtsec = dsecs
650mA*
650mAC                   eval      pgtjob = #job
650mAC                   eval      pgtusr = #user
650mAC                   move      #jobn         pgtjb#
     *
650mAC                   if        pgmtracking
650mAC                   write     pgtrec
650mAc                   endif
     *
650mAC     endzze        endsr
650mA*----------------------------------------------------------------
650mA*
650mA*  ZZENDP  End timer - call to another program
650mA*
650mAC     zzendp        begsr
     *
650mAC                   callp     getmicrotime(currstampuc:currstampsys)
650mAc                   eval      pgtEndts = currstampsys
     *
650mAc     pgtEndts      subdur    pgtStrts      dsecs:*s
650mAc                   eval(h)   pgtsec = dsecs
     *
650mAC                   eval      pgtjob = #job
650mAC                   eval      pgtusr = #user
650mAC                   move      #jobn         pgtjb#
     *
650mAC                   if        pgmtracking
650mAC                   write     pgtrec
650mAc                   endif
     *
650mAC     endzzep       endsr
     *----------------------------------------------------------------
     *
     *  ZZFGET   Get record with unique key.
     *
     C     zzfget        begsr
     *
     *    Code to use when file key and unique key are the same.
     *
     C     filuky        chain     record                             79
     *
     *    Code to use when file key and unique key are different.
     *
     *R         FILUKY    CHAINRECORDU              79
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTN   Get next record
     *
     C     zzfgtn        begsr
     C     try1          tag
     *
     *    Code to use when we are not using a partial key.
     *
     *R                   READ RECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     C                   select
     C                   when      view = '*POITEM '  and
     C                             $spo = '*NO '
     C     partky        reade     record                                 79
     *
     C                   when      view = '*POMFR  '  and
     C                             $spo = '*NO '
     C     partky        reade     record2                                79
     *
     C                   when      view = '*POITEM '  and
     C                             $spo = '*YES'
     C     prtky2        reade     oqreca                                 79
     C                   if        not *in79
     C     pdkey         chain     podtl                              77
     C                   endif
     *
     C                   when      view = '*POMFR  '  and
     C                             $spo = '*YES'
     C     prtky2        reade     oqrecb                                 79
     C                   if        not *in79
     C     pdkey         chain     podtl                              77
     C                   endif
     *
     C                   endsl
     *
500e **   See if we only want untouched lines.
500e C                   if        noxflg = *on  and
500e C                             not *in79
500e C     detlky        chain     podtl3                             84
500e C     *in84         cabeq     *off          try1
500e C                   endif
     *
640aA**   See if we only want untouched lines.
640aAC                   if        desflg = *on  and
640aAC                             noxflg = *off and
640aAC                             not *in79
640aAC     detlky        chain     podtl3                             84
640aAC                   if        pdqor1=pdqrc1 and
640aAC                             pdqor2=pdqrc2 and
640aAC                             pdqor3=pdqrc3 and
640aAC                             *IN84=*off    or
640aAC                             *in84=*on
640aAC                   goto      try1
640aAC                   endif
640aAC                   endif
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTP   Get previous record
     *
     C     zzfgtp        begsr
     C     try2          tag
     *
     *    Code to use when we are not using a partial key.
     *
     *R                   READPRECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     C                   select
     C                   when      view = '*POITEM '  and
     C                             $spo = '*NO '
     C     partky        readpe    record                                 79
     *
     C                   when      view = '*POMFR  '  and
     C                             $spo = '*NO '
     C     partky        readpe    record2                                79
     *
     C                   when      view = '*POITEM '  and
     C                             $spo = '*YES'
     C     prtky2        readpe    oqreca                                 79
     C                   if        not *in79
     C     pdkey         chain     podtl                              77
     C                   endif
     *
     C                   when      view = '*POMFR  '  and
     C                             $spo = '*YES'
     C     prtky2        readpe    oqrecb                                 79
     C                   if        not *in79
     C     pdkey         chain     podtl                              77
     C                   endif
     *
     C                   endsl
     *
500e **   See if we only want untouched lines.
500e C                   if        noxflg = *on  and
500e C                             not *in79
500e C     detlky        chain     podtl3                             84
500e C     *in84         cabeq     *off          try2
500e C                   endif
640aA**   See if we only want qty descripency lines.
640aAC                   if        desflg = *on  and
640aAC                             not *in79
640aAC     detlky        chain     podtl3                             84
640aAC                   if        pdqor1=pdqrc1 and
640aAC                             pdqor2=pdqrc2 and
640aAC                             pdqor3=pdqrc3 and
640aAC                             *in84=*off    or
640aAC                             *in84=*on
640aAC                   goto      try2
640aAC                   endif
640aAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     *
     C                   select
     C                   when      view = '*POMFR  '
     C                   eval      womfr = pdvitm
     C                   endsl
     *
     C                   if        uxflag = '1'
     C     itkey         chain     itemdsc                            79
     C                   if        *in79
     C                   eval      wodsc1 = *blanks
     C                   eval      wodsc2 = *blanks
     C                   else
EFCaAC                   select
EFCaAC                   when      client=eastland
EFCaAC                   eval      wodsc1 = %subst(ixdsc1:1:22)
EFCaAC                   eval      wodsc2 = %subst(ixdsc1:23:18)
EFCaAC                                    + %subst(ixdsc2:1:4)
MJKaAC                   when      client=mjkellner
GFS AC                             or client=getfresh
HMWbAC                             or client=hmwagner
MJKaAC                   eval      wodsc1 = %subst(ixdsc1:1:22)
MJKaAC                   eval      wodsc2 = %subst(ixdsc1:23:18)
MJKaAC                                    + %subst(ixdsc2:1:4)
FGLbAC                   when      client = FoodsGalore
FGLbAC     itkey         chain     itemmsc                            79
FGLbAC                   if        not *in79
FGLbAC                   movel     imbrnd        wodsc2
FGLbAC                   endif
FGLbAC                   movel     ixdsc1        wodsc1
EFCaAC                   other
     C                   movel     ixdsc1        wodsc1
     C                   movel     ixdsc2        wodsc2
EFCaAC                   endsl
     C                   endif
     *  GET PACK DESCRIPTION
     C     itkey         chain     piritem                            79
     C                   if        not *in79
     C                   eval      wopdsc = itpdsc
     C                   else
     C                   eval      wopdsc = *blanks
     C                   endif
     *
     *    If no extended description found for the item,
     *    Load description from item.
     C                   if        not *in79  and
     C                             wodsc1 = *blanks  and
     C                             wodsc2 = *blanks
     C                   movel     itdesc        wodsc1
     C                   endif
     *
     *  GET TIE HI, PREFERRED OR 1ST RECORD.
     C                   eval      done = *off
     C                   eval      wotie = 0
     C                   eval      wohi = 0
     C                   eval      svtie = 0
     C                   eval      svhi = 0
     C     partk2        setll     itemdef
     C                   dou       done = *on
     C     partk2        reade     idrec                                  79
     C                   if        *in79
     C                   eval      done = *on
     C                   else
     C                   if        svtie = 0  and
     C                             svhi = 0
     C                   eval      svtie = idtie
     C                   eval      svhi = idhigh
     C                   endif
     C                   if        idpref = 'Y'
     C                   eval      wotie = idtie
     C                   eval      wohi = idhigh
     C                   eval      done = *on
     C                   endif
     C                   endif
     C                   enddo
     C                   if        wotie = 0  and
     C                             wohi = 0
     C                   eval      wotie = svtie
     C                   eval      wohi = svhi
     C                   endif
FKLaAC                   if        client = finkle
FKLaAC                   eval      *in88 = *on
FKLaAC                   else
FKLaAC                   eval      *in88 = *off
FKLaAC                   endif
     *
     *    When processing a Super P/O, load the individual P/O number
     *    in the subfile everytime the individual p/o changes.
     C                   if        $spo = '*YES'
     C                   if        savpo <> pdpo
     C                   eval      wopotx = 'PO:'
     C                   eval      wopo# = pdpo
     C                   eval      savpo = pdpo
     *
     C                   else
     C                   eval      wopotx = *blanks
     C                   eval      wopo# = *blanks
     C                   endif
     C                   endif
     *
     C                   else
     *
     *    Single line display.
     *
     C     itkey         chain     piritem                            79
     C                   if        not *in79
     C                   movel     itdesc        wodsc
     C                   else
     C                   eval      wodsc = *blanks
     C                   endif
     C                   endif
     *
     *   Convert quantity to string.
     *
     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg
     C                   eval      $cqty1 = pdqor1
     C                   eval      $cqty2 = pdqor2
     C                   eval      $cqty3 = pdqor3
     C                   exsr      zzcvqy
     *
     C                   select
     *    Single line display.
     C                   when      uxflag = *off
     C                   select
     *    Item display.
     C                   when      view = '*POITEM '
     C                   movel     $cqstr        woqor
     *    Mfr display.
     C                   when      view = '*POMFR  '
     C                   movel     $cqstr        woqor2
     C                   endsl
     *
     *    Extended line display.
     C                   when      uxflag = *on
     C                   select
     *    Item display.
     C                   when      view = '*POITEM '
     C                   movel     $cqstr        woqor
     *    Mfr display.
     C                   when      view = '*POMFR  '
     C                   movel     $cqstr        woqor2
     C                   endsl
     C                   endsl
     *
     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg
     C                   eval      $cqty1 = pdqrc1
     C                   eval      $cqty2 = pdqrc2
     C                   eval      $cqty3 = pdqrc3
     C                   exsr      zzcvqy
     *
     C                   select
     *    Single line display.
     C                   when      uxflag = *off
     C                   select
     *    Item display.
     C                   when      view = '*POITEM '
     C                   movel     $cqstr        woqrc
     *    Mfr display.
     C                   when      view = '*POMFR  '
     C                   movel     $cqstr        woqrc2
     C                   endsl
     *
     *    Extended line display.
     C                   when      uxflag = *on
     C                   select
     *    Item display.
     C                   when      view = '*POITEM '
     C                   movel     $cqstr        woqrc
     *    Mfr display.
     C                   when      view = '*POMFR  '
     C                   movel     $cqstr        woqrc2
     C                   endsl
     C                   endsl
     *
     **   See if line has been touched.  Flag accordingly.
     C     detlky        chain     podtl3                             84
     C                   if        *in84
     C                   eval      touch = *blanks
     C                   else
     C                   eval      touch = 'X'
     C                   endif
DRYcA /free
DRYcA    if client = dairyland and itcwgt = 'Y';
DRYcA      if pdqrc1 > 0 and pddwgt = 0 or
DRYcA         pdqrc2 > 0 and pddwgt = 0 or
DRYcA         pdqrc3 > 0 and pddwgt = 0;
DRYcA        touch = 'W';
DRYcA      endif;
DRYcA    endif;
DRYcA /end-free
520aA*
520aA**   See if item has item message on file.
520aAC     pdmkey        chain     podtlm                             83
520aAC                   if        *in83
520aAC                   eval      pdmpom = *blanks
520aAC                   eval      *in39 = *off
520aAC                   eval      hldi39 = *off
520aAC                   else
520aA**   Reverse image item number if text found in msg field.
520aAC                   if        pdmpom > *blanks
520aAC                   eval      *in39 = *on
520aAC                   eval      hldi39 = *on
520aAC                   else
520aAC                   eval      *in39 = *off
520aAC                   eval      hldi39 = *off
520aAC                   endif
520aA*
520aAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL4   Fill window subfile with values to be converted.
     *
     C     zzfil4        begsr
     *
     C                   eval      wopo4 = pdpo
     *
     C                   select
     *    User selected P/O sub-totals.
     C                   when      ovrtyp = '*SUBTOTL'  and
     C                             svpo = pdpo
     *
     C                   add       pdqor1        tqyor1
     C                   add       pdqor2        tqyor1
     C                   add       pdqor3        tqyor1
     *
     C                   add       pdqrc1        tqyrc1
     C                   add       pdqrc2        tqyrc1
     C                   add       pdqrc3        tqyrc1
     *
     *    User selected sub-totals - P/O changed - convert quantities.
     C                   when      ovrtyp = '*SUBTOTL'  and
     C                             svpo <> pdpo
     *
     *    End of file - replace low values with last po read.
     C                   if        svpo = *loval
     C                   eval      svpo = pdpo
     C                   eval      wopo4 = pdpo
     C                   else
     C                   eval      wopo4 = svpo
     C                   endif
     *
     C     phky2         chain(n)  pohdr                              77
     C                   if        *in77
     C                   eval      phven = *zeros
     C                   endif
     *
     C                   eval      woven = phven
     *
     *   Convert Total quantity ordered to string.
     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg
     C                   eval      $cqty1 = tqyor1
     C                   eval      $cqty2 = *zeros
     C                   eval      $cqty3 = *zeros
     C                   exsr      zzcvqy
     C                   movel     $cqstr        woqor
     *
     *   Convert Total quantity received to string.
     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg
     C                   eval      $cqty1 = tqyrc1
     C                   eval      $cqty2 = *zeros
     C                   eval      $cqty3 = *zeros
     C                   exsr      zzcvqy
     C                   movel     $cqstr        woqrc
     *
     C                   other
     *
     C     phkey         chain(n)  pohdr                              77
     C                   if        *in77
     C                   eval      phven = *zeros
     C                   endif
     *
     C                   eval      woven = phven
     *
     *   Convert quantity ordered to string.
     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg
     C                   eval      $cqty1 = pdqor1
     C                   eval      $cqty2 = pdqor2
     C                   eval      $cqty3 = pdqor3
     C                   exsr      zzcvqy
     C                   movel     $cqstr        woqor
     *
     *   Convert quantity received to string.
     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg
     C                   eval      $cqty1 = pdqrc1
     C                   eval      $cqty2 = pdqrc2
     C                   eval      $cqty3 = pdqrc3
     C                   exsr      zzcvqy
     C                   movel     $cqstr        woqrc
     *
     C                   endsl
     *
     C     endfl4        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL5   Fill window subfile with values to be converted.
     *
     C     zzfil5        begsr
     *
     C                   eval      w5po = pdpo
     C                   eval      hseq = pdseq
     *
     C                   select
     *    When position to item is selected, item number is loaded on
     *    on first line of subfile record.
     C                   when      ovrtyp = '*POS2ITM'
     C                   eval      w5val1 = pditem
     C                   eval      w5val2 = pdvitm
     *
     *    When position to Mfr# is selected, Manufacturer is loaded on
     *    on first line of subfile record.
     C                   when      ovrtyp = '*POS2MFR'
     C                   eval      w5val1 = pdvitm
     C                   eval      w5val2 = pditem
     *
     C                   endsl
     *
     *    Extended item description in use.
     C                   if        uxflag = '1'
     C     itkey         chain     itemdsc                            79
     C                   if        *in79
     C                   eval      w5desc = *blanks
     C                   else
     C                   eval      w5desc = ixdsc1
     C                   endif
     C                   endif
     *
     *    Get pack description.
     C     itkey         chain     piritem                            79
     C                   if        not *in79
     C                   eval      w5pdsc = itpdsc
     C                   else
     C                   eval      w5pdsc = *blanks
     C                   endif
     *
     *    If no extended description found for the item,
     *    Load description from item.
     C                   if        not *in79  and
     C                             w5desc = *blanks
     C                   eval      w5desc = itdesc
     C                   endif
     *
     C     endfl5        endsr
     *----------------------------------------------------------------
417a *
417a *  ZZFIL6   Fill window subfile with values to be converted.
417a *
417a C     zzfil6        begsr
417a *
417a C                   eval      w6txt2 = 'Mfr:'
417a *
417a *    Extended item description in use.
417a C                   if        uxflag = '1'
417A C     i6key         chain     itemdsc                            79
417a C                   if        *in79
417a C                   eval      w6desc = *blanks
417a C                   else
417a C                   eval      w6desc = ixdsc1
417a C                   endif
417a C                   endif
417a *
417a *    Get pack description.
417A C     i6key         chain     piritem                            79
417a C                   if        not *in79
417a C                   eval      w6pdsc = itpdsc
417a C                   else
417a C                   eval      w6pdsc = *blanks
417a C                   endif
417a *
417a *    If no extended description found for the item,
417a *    Load description from item.
417a C                   if        not *in79
417A ***        W6DESC    ANDEQ*BLANKS
417a C                   eval      w6desc = itdesc
417a C                   endif
417a *
417a *    Get brand.
417A C     i6key         chain     itemmsc                            79
417a C                   if        not *in79
417a C                   eval      w6brnd = imbrnd
417a C                   else
417a C                   eval      w6brnd = *blanks
417a C                   endif
417a *
417a *    Get pick slot.
417a C                   eval      bsitem = pditem
417a C                   eval      bsstat = 'A '
417a C                   eval      bspick = 'Y'
417a C     slkey3        setll     slot3
417a C                   dow       forevr = forevr
417a C     slkey3        reade     slot3                                  79
417a *
417a C                   eval      w6pslt = *blanks
417a C                   if        not *in79  and
417a C                             slpick = 'Y'
417a C                   eval      w6pslt = sldisp
417a C                   endif
417a C                   leave
417a C                   enddo
     *
417a *
417a C     endfl6        endsr
417k *----------------------------------------------------------------
417k *
417k *  ZZFIL7   Fill window subfile with values to be converted.
417k *
417k C     zzfil7        begsr
417k *
417k C                   eval      wopo4 = pdpo
417k *
417k C                   select
417k *    User selected item sub-totals.
417k C                   when      ovrtyp = '*SUBITTL'
417k *
417k C                   add       pdqor1        tqyor1
417k C                   add       pdqor2        tqyor1
417k C                   add       pdqor3        tqyor1
417k *
417k C                   add       pdqrc1        tqyrc1
417k C                   add       pdqrc2        tqyrc1
417k C                   add       pdqrc3        tqyrc1
417k *
417k *
417k ***        PHKY2     CHAINPOHDR               N77
417k ***        *IN77     IFEQ *ON
417k ***                  MOVE *ZEROS    PHVEN
417k ***                  ENDIF
417k *
417k ****                 Z-ADDPHVEN     WOVEN
417k *
417k C                   if        uxflag = '1'
417k C     itkey         chain     itemdsc                            79
417k C                   if        *in79
417k C                   eval      w7desc = *blanks
417k C                   else
417k C                   movel     ixdsc1        w7desc
417k C                   endif
417k C                   endif
417k C     itkey         chain     piritem                            79
417k *    If no extended description found for the item,
417k *    Load description from item.
417k C                   if        not *in79  and
417k C                             w7desc = *blanks
417k C                   movel     itdesc        w7desc
417k C                   endif
417k *
417k C                   eval      woitm = pditem
417k C                   eval      woseq = pdseq
417k *
417k *   Convert Total quantity ordered to string.
417k C                   eval      $ccmd = '*QTY2STR'
417k C                   move      '#PROG   '    $cprg
417k C                   eval      $cqty1 = tqyor1
417k C                   eval      $cqty2 = *zeros
417k C                   eval      $cqty3 = *zeros
417k C                   exsr      zzcvqy
417k C                   movel     $cqstr        woqor
417k *
417k *   Convert Total quantity received to string.
417k C                   eval      $ccmd = '*QTY2STR'
417k C                   move      '#PROG   '    $cprg
417k C                   eval      $cqty1 = tqyrc1
417k C                   eval      $cqty2 = *zeros
417k C                   eval      $cqty3 = *zeros
417k C                   exsr      zzcvqy
417k C                   movel     $cqstr        woqrc
417k *
417k C                   endsl
417k *
417k C     endfl7        endsr
417l *----------------------------------------------------------------
417l *
417l *  ZZFIL8   Fill window subfile with values to be converted.
417l *
417l C     zzfil8        begsr
417l *
417l C                   eval      w8po = pdpo
417l *
417l C                   select
417l *    User selected item sub-totals.
417l C                   when      ovrtyp = '*SUBITTL'
417l *
417l C                   add       pdqor1        tqyor1
417l C                   add       pdqor2        tqyor1
417l C                   add       pdqor3        tqyor1
417l *
417l C                   add       pdqrc1        tqyrc1
417l C                   add       pdqrc2        tqyrc1
417l C                   add       pdqrc3        tqyrc1
417l *
417l C                   if        uxflag = '1'
417l C     itkey         chain     itemdsc                            79
417l C                   if        *in79
417l C                   eval      w8desc = *blanks
417l C                   else
417l C                   movel     ixdsc1        w8desc
417l C                   endif
417l C                   endif
417l C     itkey         chain     piritem                            79
417l *    If no extended description found for the item,
417l *    Load description from item.
417l C                   if        not *in79  and
417l C                             w8desc = *blanks
417l C                   movel     itdesc        w8desc
417l C                   endif
417l *
417l C                   eval      woitm = pditem
417l C                   eval      woseq = pdseq
417l *
417l *   Convert Total quantity ordered to string.
417l C                   eval      $ccmd = '*QTY2STR'
417l C                   move      '#PROG   '    $cprg
417l C                   eval      $cqty1 = tqyor1
417l C                   eval      $cqty2 = *zeros
417l C                   eval      $cqty3 = *zeros
417l C                   exsr      zzcvqy
417l C                   eval      woqor8 = $cqstr
417l *
417l *   Convert Total quantity received to string.
417l C                   eval      $ccmd = '*QTY2STR'
417l C                   move      '#PROG   '    $cprg
417l C                   eval      $cqty1 = tqyrc1
417l C                   eval      $cqty2 = *zeros
417l C                   eval      $cqty3 = *zeros
417l C                   exsr      zzcvqy
417l C                   eval      woqrc8 = $cqstr
417l *
417l C                   endsl
417l *
417l C     endfl8        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *
     *  Define keys
     *
     *     WORKOPT  (Unique key)
     *
     C     wkounq        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     C                   kfld                    wkokyf
     C                   kfld                    wkokyu
     *
     *  Define full key for PODTL3 file.
     *
     C     detlky        klist
     C                   kfld                    pdwhse
     C                   kfld                    pdpo
     C                   kfld                    pdseq
     *
     *     WORKOPT  (Partial key)
     *
     C     wkoprt        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     *
     *     WORKOPT  (Save key for top record on delete display)
     *
     C     deltop        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     C                   kfld                    $wkof
     C                   kfld                    $wkou
     *
     *     USERCODE
     *
     C     uskey         klist
     C                   kfld                    #user
     *
     *  Define unique file key.
     *
     C     filuky        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kpo
     C                   kfld                    pditem
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kpo
     C                   kfld                    pditem
     *
     C     filky2        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kpo
     C                   kfld                    pdvitm
     *
     C     filky3        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kspo
     C                   kfld                    pdpo
     C                   kfld                    pditem
     *
     C     filky4        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kspo
     C                   kfld                    pdpo
     C                   kfld                    pdvitm
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kpo
     *
     *  Define partial key for Super P/O file (if needed).
     *
     C     prtky2        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kspo
     *
     C     prtky3        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kspo
     C                   kfld                    pditem
     *
     C     prtky4        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kspo
     C                   kfld                    pdvitm
     *
     *  Define key for PIRITEM file.
     *
     C     itkey         klist
     C                   kfld                    $kwhse
     C                   kfld                    pditem
     *
417A *  Define key for PIRITEM file.
417A *
417A C     i6key         klist
417A C                   kfld                    $kwhse
417A C                   kfld                    w6val1
     *
     *  Define key for PODTL file.
     *
     C     pdkey         klist
     C                   kfld                    pdwhse
     C                   kfld                    pdpo
     C                   kfld                    pdseq
     C                   kfld                    pditem
520aA*
520aA*  Define key for PODTLM file.
520aA*
520aAC     pdmkey        klist
520aAC                   kfld                    pdwhse
520aAC                   kfld                    pdpo
520aAC                   kfld                    pdseq
520aAC                   kfld                    pditem
     *
     *  Define key for POHDR file.
     *
     C     phkey         klist
     C                   kfld                    pdwhse
     C                   kfld                    pdpo
     C     phky2         klist
     C                   kfld                    pdwhse
     C                   kfld                    svpo
     *
     C     itkey2        klist
     C                   kfld                    $kwhse
     C                   kfld                    $pitem
     *
     C     slkey3        klist
     C                   kfld                    $kwhse
     C                   kfld                    bsitem
     C                   kfld                    bsstat
     C                   kfld                    bspick
     *
     *  Define key for OPTIOND.
     *
     C     opkey2        klist
     C                   kfld                    kycode
     C                   kfld                    $pwhse
     C                   kfld                    itwhdp
     C                   eval      kycode = '*PICK   '
     *
     *
     *  Define key for UPC file.
     *
     C     upckey        klist
     C                   kfld                    $kwhse
     C                   kfld                    w1upc
     *
417c *  Define key for ITMEXCP2 file
     *
417c C     ix2key        klist
417c C                   kfld                    $kwhse
417c C                   kfld                    kyitem
417c C                   kfld                    kytask
417c C                   kfld                    kyerid
417c C                   kfld                    kyesta
     *
     *  Define key for PODTL1 file.
     *
     C     podky1        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kpo
     C                   kfld                    woitm#
     *
     *     OPTIONS
     *
     C     opkey         klist
     C                   kfld                    $kwhse
     C                   kfld                    ocode
     *
     *  Define partial key for item tie/high definition file.
     *
     C     partk2        klist
     C                   kfld                    $kwhse
     C                   kfld                    pditem
     *
     *  ITEMLNK file.
     *
     C     ilkey         klist
     C                   kfld                    $kwhse
     C                   kfld                    pditem
     *
 16fAC     ddkeyp        klist
416fAC                   kfld                    $kwhse
416fAC                   kfld                    itwhdp
     *
     *  Setup option and command display lines.
     *
     C                   eval      viewo = 1
     C                   eval      maxvwo = 2
PCK AC                   select
PCK AC                   when      client = packer
PCK AC                   eval      optln1 = optlnp(1)
PCK AC                   eval      optln2 = optlnp(2)

JPFaAC                   when      client = palmer
JPFaAC                   eval      optln1 = optlnj(1)
JPFaAC                   eval      optln2 = optlnj(2)

YHAbAC                   when      client = yhata
YHAbAC                   eval      optln1 = optlny(1)
YHAbAC                   eval      optln2 = optlny(2)
PCK AC                   other
     C                   eval      optln1 = optln(1)
     C                   eval      optln2 = optln(2)
PCK AC                   endsl
500cAC                   if        $cmd = '*SPRECV'
500cAC                   eval      optln1 = optlns(1)
500cAC                   endif
SOFcA*
SOFcAC                   select
SOFcA *  Disable 4=Delete option.
SOFcAC                   when      client = SofoFoods
SOFcAC                   eval      zopt(3) = '  '
DRYaA *  Dairyland
DRYaAC                   when      client = Dairyland
GFSaAC                             or client = Getfresh
FFCaAC                             or client = fischerfoods
KHLaAC                             or client = Kohl
FBYaAC                             or client = farmboy
DRYaAC                   eval      zopt(3) = '  '
DRYaA*
SOFcAC                   endsl
SOFcA*
     C                   select
     C                   when      $spo = '*NO '
     C                   eval      cmdln1 = cmdln(1)
     C                   when      $spo = '*YES'
     C                   eval      cmdln1 = cmdln(3)
     C                   endsl
EGFaAC                   if        client=egf
HMWaAC                             or client=hmwagner
GMMaAC                             or client='MENUMAKER '
KHLaAC                             or client=kohl
JP1 AC                             or client=palmer
EGFaAC                   eval      view = '*POMFR  '
EGFaAC                   else
     C                   eval      view = '*POITEM '
EGFaAC                   endif
CCPa C                   if        client=CapitolCity
CCPa C                   eval      *in22 = *on
CCPa C                   eval      *in20 = *off
CCPa C                   endif
     *
     C                   eval      forevr = *off
     C                   eval      $pprg = #prog
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Initialize working variables.
     *
     C                   eval      savpo = *blanks
     C                   eval      ttlrcd = *zeros
     C                   eval      nrslct = *zeros
     C                   eval      n = *zeros
     C                   eval      k = *zeros
     C                   eval      tqyor1 = *zeros
     C                   eval      tqyrc1 = *zeros
     C                   eval      k = 1
     C                   eval      recno4 = *zeros
     C                   eval      optslt = *off
     C                   eval      open1 = *off
     C                   eval      open2 = *off
     C                   eval      first = *off
416FAC                   eval      svmput = *blanks
500eAC                   eval      noxflg = *off
640aAC                   eval      desflg = *off
520aAC                   eval      *in39 = *off
520aAC                   eval      hldi39 = *off
     *
     *   Get warehouse description.
     *
     C     $kwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
417a *
417a *  Convert today's date into century format.
417a *
417a C                   eval      $cvcmd = '*CURCMD '
417a C                   call      @cvtdt
417a C                   parm                    $cvtdt
417a C                   eval      today = $cvd8o
     *
     *   Load P/O for display.
     *
     C                   eval      ovrtyp = *blanks
     C                   select
     C                   when      $spo = '*YES'
     C                   eval      wopo = $kspo
     *
     *    Process file override for OPNQRYF
EGFaAC                   if        client=egf
HMWaAC                             or client=hmwagner
GMMaAC                             or client='MENUMAKER '
KHLaAC                             or client=kohl
JP1 AC                             or client=palmer
EGFaAC                   eval      ovrtyp = '*POMFR  '
EGFaAC                   else
     C                   eval      ovrtyp = '*POITEM '
EGFaAC                   endif
     C                   exsr      zzovr
     *
     *    Process OPNQRYF.
     C                   exsr      zzqry
     C                   exsr      zzopn
     *
     C                   other
     C                   eval      wopo = $kpo
     C                   endsl
     *
     C                   exsr      zzxopt
     C                   exsr      zztrcv
     C                   exsr      clrsch
     C                   exsr      scr01i
     *
     *    Get User's employee number to be written to PORCV file
     *    if any records are flagged as touched.
     *
     C                   eval      $code = #user
     C                   eval      $whse = *zeros
     C                   eval      $emp# = *zeros
     C                   eval      $fnam = *blanks
     C                   eval      $init = *blanks
     C                   eval      $lnam = *blanks
     C                   eval      $whdp = *blanks
     C                   eval      $styp = *blanks
     C                   eval      $shft = *blanks
     C                   eval      $crew = *blanks
     C                   eval      $nhrs = *blanks
     C                   eval      $rtn = *blanks
     C                   call      'GETUSER'
     C                   parm                    $code
     C                   parm                    $whse
     C                   parm                    $emp#
     C                   parm                    $fnam
     C                   parm                    $init
     C                   parm                    $lnam
     C                   parm                    $whdp
     C                   parm                    $styp
     C                   parm                    $shft
     C                   parm                    $crew
     C                   parm                    $nhrs
     C                   parm                    $rtn
     *
640fA* load haccps session id record
640fA*  TEST FOR Haccp Programs
640fA*
640fA * check to make sure programs exist or don't do call
640fAC                   eval      qcmd = 'CHKOBJ '
640fAC                                  + 'OBJ(HA412) '
640fAC                                  + 'OBJTYPE(*PGM)'
640fAC                   call      'QCMDEXC'                            78
640fAC                   parm                    qcmd            256
640fAC                   parm      80            qlen             15 5
640fAc                   if        *in78 = *off
640fA /free
640fA   $lcmd = '*START  ';
640fA   ha412($lparm);
640fA /end-free
640fAc                   else
640fAc                   eval      *in78 = *off
640fAc                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCVQY   Convert quantity to string or string to quantity.
     *
     C     zzcvqy        begsr
     C                   call      'CVTQTY'
     C                   parm                    $ccmd
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
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYF   Create key for file being used
     *
     C     zzkeyf        begsr
     C                   eval      $pofky = dsfkey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     C     zzkeyu        begsr
     C                   eval      $pouky = dsukey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS2.
     *
     C     zzopt         begsr
610aAC*
610aAC*   Call Recall Listing
610aAC*
610aAC                   if        wkoopt='RC'
610aAC                   move      $PUKY         DSUKEY
610aAC                   call      'LT330'
610aAC                   parm      '*DISPLAY'    $TCMD             8
610aAC                   parm      PDWHSE        $TWHSE            3 0
610aAC                   parm      PDPO          $TPO              9
610aAC                   parm      PDITEM        $TITEM           15
610aAC                   parm      ' '           $TDEV            10
610aAC                   parm      ' '           $TFORM           10
610aAC                   endif
650pAC*
650pAC*   Call Receiving Weight list
650pAC*
650pAC                   if        wkoopt='RW'
650pAC                   move      $PUKY         DSUKEY
650pAC                   call      'UI320'
650pAC                   parm      '*VIEW   '    $TCMD             8
650pAC                   parm      PDWHSE        $TWHSE            3 0
650pAC                   parm      PDITEM        $TITEM           15
650pAC                   parm      ' '           $TLCNS           15
650pAC                   parm      0             $TTRN#            7 0
650pAC                   parm      PDPO          $TPO              9
650pAC                   endif
700gAC*
700gAC*   Call PCM Exception list
700gAC*
700gAC                   if        wkoopt='RE'
700gAC                   move      $PUKY         DSUKEY
700gAC                   call      'HA300'
700gAc                   parm      ' '           $hacmd            8
700gMc                   parm      $pwhse        $hawhse15        15 5
700gAc                   parm      PDPO          $lhapo            9
700gAc                   parm      PDITEM        $lhaitem         15
700gAc                   parm      'REXI'        $lhlevl           4

700gAC                   endif
740aAC*   Call GS1 weight entry program
740aAC*
740aAC                   if        wkoopt='EW'
740aAC                   move      $PUKY         DSUKEY
740aAc                   eval      $gitem = pditem
740aAc                   eval      $gwhse  = $pwhse
740aAc                   eval      $gpo   = pdpo
740aAc                   eval      $gposeq = pdseq
740aAC                   call      'GS110'
740aAc                   parm                    $gprtky
740aAc                   parm                    $grtn

740aAC                   endif
     *
     *   Work with tie/high
     *
     C                   if        wkoopt = ' 8'
     C                   eval      $swhse = pdwhse
     C                   call      'IT141'
     C                   parm                    $swhse
     C                   parm                    $pitem
     C                   endif
     *
     *   Transactions.
     *
     C                   if        wkoopt = ' 9'
     C                   exsr      zzputo
     C                   eval      $lmput = opmput
     C                   eval      $luky = $puky
     C                   eval      $lrtn = *blanks
     C                   call      'PO140'
     C                   parm                    $luky
     C                   parm                    $lrtn
     C                   parm                    $lmput
     C                   exsr      zztrcv
     C                   endif
PCK A*
PCK A*   UCI Weight listing
PCK A*
PCK AC                   if        wkoopt = '10'
PCK AC                   eval      $lwhse = $kwhse
PCK AC                   eval      $lpo = $kpo
PCKbAC                   move      $pseq         alpseq
PCK AC                   call      @lstpg
PCKaMC                   parm                    $lwhse
PCKaAC                   parm                    $lpo
PCKbAC                   parm      *blanks       $lexdt            8
PCKbAC                   parm      *blanks       $lextm            6
PCKbAC                   parm      alpseq        $ldtsq            5
PCKaAC                   parm      *blanks       $ljobq            1
PCKaAC                   parm      *blanks       $lrtn
PCKaAC                   parm      *blanks       $ldev            10
PCKaAC                   parm      *blanks       $lform           10
PCK AC                   endif
     *
     *   Receive item
     *
     C                   if        wkoopt = ' 1'
     C                   exsr      zzchek
     C     error         cabeq     *on           endopt
     *
     C                   select
     *    No positioning used. Check if item/Mfr# on multiple p/o's.
     *    If found on multiple p/o's, display pop-up window.
     *    Note: This is ONLY for Super P/O's.
     C                   when      svp2po = *blanks  and
     C                             svp2vl = *blanks  and
     C                             $spo = '*YES'  or
     *
     *    Position to used, but different P/O selected.
     C                             svp2po > *blanks  and
     C                             svp2po <> $ppo  or
     *
     *    Position to used, but different Item selected.
     C                             svp2vl > *blanks  and
     C                             svp2vl <> $pitem
     *
     *    Super P/O being processed.
     C                   eval      ptinp1 = $pitem
     C                   eval      pditem = $pitem
     C                   eval      ovrtyp = '*SLCTITM'
     *
     C                   exsr      zzwdw
     C                   eval      ptinp1 = *blanks
     C                   eval      w1mfr = *blanks
     C                   select
     *    New P/O selected. Go to Receiving.
     C                   when      repos = *on
     C                   eval      $ppo = wopo4
     C                   eval      $pseq = hseq
     C                   eval      $pitem = hitem
     C                   eval      $pvitm = hvitm
     C                   exsr      zzrcv
     C                   eval      svp2po = *blanks
     C                   eval      svp2vl = *blanks
     C                   eval      repos = *off
     C                   endsl
     *
     *    User used Position to and has selected same item.
     C                   when      svp2po = $ppo  and
     C                             svp2vl = $pitem  or
     *
     *    User processing Single P/O.
     C                             $spo = '*NO '
     *
     C                   eval      svp2po = *blanks
     C                   eval      svp2vl = *blanks
     *
     C                   exsr      zzrcv
     C                   endsl
     C                   endif
     *
520aA*   Display item message.
     *
     C                   if        wkoopt = ' 7'
520aAC                   eval      dsukey = $puky
520aAC                   eval      ovrtyp = '*ITEMMSG'
520aAC                   exsr      zzwdw
520aA*
520aD*                    EXSR ZZCHEK
520aD*          ERROR     CABEQ*ON       ENDOPT
520aD*
520aD*                    SELEC
520aD*    No positioning used. Check if item/Mfr# on multiple p/o's.
520aD*    If found on multiple p/o's, display pop-up window.
520aD*    Note: This is ONLY for Super P/O's.
520aD*          SVP2PO    WHEQ *BLANKS
520aD*          SVP2VL    ANDEQ*BLANKS
520aD*          $SPO      ANDEQ'*YES'
520aD*
520aD*    Position to used, but different P/O selected.
520aD*          SVP2PO    ORGT *BLANKS
520aD*          SVP2PO    ANDNE$PPO
520aD*
520aD*    Position to used, but different Item selected.
520aD*          SVP2VL    ORGT *BLANKS
520aD*          SVP2VL    ANDNE$PITEM
520aD*
520aD*    Super P/O being processed.
520aD*                    SELEC
520aD*          VIEW      WHEQ '*POITEM '
520aD*          VIEW      OREQ '*POMFR  '
520aD*                    MOVE $PITEM    PTINP1
520aD*                    MOVE $PITEM    PDITEM
520aD*                    MOVE '*SLCTITM'OVRTYP
520aD*                    ENDSL
520aD*                    EXSR ZZWDW
520aD*                    MOVE *BLANKS   PTINP1
520aD*                    MOVE *BLANKS   W1MFR
520aD*                    SELEC
520aD*    New P/O selected. Go to Receiving.
520aD*          REPOS     WHEQ *ON
520aD*                    MOVE WOPO4     $PPO
520aD*                    Z-ADDHSEQ      $PSEQ
520aD*                    MOVE HITEM     $PITEM
520aD*                    MOVE HVITM     $PVITM
520aD*                    EXSR ZZRCV
520aD*                    MOVE *BLANKS   SVP2PO
520aD*                    MOVE *BLANKS   SVP2VL
520aD*                    MOVE *OFF      REPOS
520aD*                    ENDSL
520aD*
520aD*    User used Position to and has selected same item.
520aD*          SVP2PO    WHEQ $PPO
520aD*          SVP2VL    ANDEQ$PITEM
520aD*
520aD*    User processing Single P/O.
520aD*          $SPO      OREQ '*NO '
520aD*
520aD*                    MOVE *BLANKS   SVP2PO
520aD*                    MOVE *BLANKS   SVP2VL
520aD*
520aD*                    EXSR ZZRCV
520aD*                    ENDSL
     C                   endif
     *
     *   Enter HACCP information.
     *
     C                   if        wkoopt = '11'
     C                   eval      $pcmd = '*ITEM   '
640fA*  TEST FOR new Haccp Programs
640fA*
640fA * check to make sure programs exist or don't do call
640fAC                   eval      qcmd = 'CHKOBJ '
640fAC                                  + 'OBJ(HA410) '
640fAC                                  + 'OBJTYPE(*PGM)'
640fAC                   call      'QCMDEXC'                            78
640fAC                   parm                    qcmd            256
640fAC                   parm      80            qlen             15 5
640fAc                   if        *in78 = *off
640fA*
640fA*   Do Haccp Detail Processing.
640fA*
640fA /free
640fA
640fA   $lwhse = $kwhse;
640fA   $lcmd = '*PODTLCH';
640fA   $llevel = 'RCVI';
640fA   $llicense = $pitem;
640fA   if $spo = '*YES';
640fA     $lhpo = savpo;
640fA   else;
640fA     $lhpo = $kpo;
640fA   endif;
640fA   $lhseq = $pseq;
640fA   $ltype = ' ';
640fA   $lspo = $spo;
650aD   //ha410($lparm);
650aM   ha410($lparm:$lparm1);
640fA
640fA   $lwhse = $kwhse;
640fA   $lcmd = '*PODTLCH';
640fA   $llevel = 'RCVL';
640fA   $llicense = ' ';
640fA   if $spo = '*YES';
640fA     $lhpo = savpo;
640fA   else;
640fA     $lhpo = $kpo;
640fA   endif;
640fA   $lhseq = $pseq;
640fA   $ltype = ' ';
640fA   $lspo = $spo;
650aD   //ha410($lparm);
650aM   ha410($lparm:$lparm1);
640fA /end-free
640fAc                   else
640fAc                   eval      *in78 = *off
     C                   call      'PO170'
     C                   parm                    $parms
500gAC                   if        $prtn = '*PGMQ   '
500gAC                   eval      error = *on
500gAC                   eval      #msgk = $pmsg
500gAC                   exsr      zmqmsg
500gAC                   endif
640fAc                   endif

     C                   endif
     *
     *   Work with slots
     *
     C                   if        wkoopt = '12'
     C                   eval      $lwhse = $kwhse
     C                   eval      $litm = pditem
     C                   call      'IT130'
     C                   parm                    $luky
     C                   parm                    $lrtn
     C                   endif
     *
     *   Display Directed Putaway Receiving log.
     *
     C                   if        wkoopt = '99'
     C                   eval      $lwhse = $kwhse
     C                   eval      $lpo = $kpo
     C                   eval      $litem = pditem
     C                   call      'PO135'
     C                   parm                    $lparm
     C                   parm                    $lrtn
     C                   endif
     *
     *   Display PORCV entries.
     *
     C                   if        wkoopt = '13'
     C                   eval      $luky = $puky
     C                   eval      $lrtn = *blanks
     C                   call      'PO138'
     C                   parm                    $luky
     C                   parm                    $lrtn
     C                   endif
417 A*
417 A*   Maintain Receiving Exceptions.
417 A*
417 AC                   if        wkoopt = '14'
650bA*  TEST FOR new Haccp Programs
650bA*
650bA * check to make sure programs exist or don't do call
650bAC                   eval      qcmd = 'CHKOBJ '
650bAC                                  + 'OBJ(HA410) '
650bAC                                  + 'OBJTYPE(*PGM)'
650bAC                   call      'QCMDEXC'                            78
650bAC                   parm                    qcmd            256
650bAC                   parm      80            qlen             15 5
650bAc                   if        *in78 = *off
650bA /free
650bA
650bA   // Now do podtl processing.
650bA   $lwhse = $kwhse;
650bA   $lcmd = '*PODTL  ';
650bA   $llevel = 'REXI';
650bA   $llicense = $pitem;
650fA   if $spo = '*YES';
650fA     $lhpo = savpo;
650fA   else;
650fA     $lhpo = $kpo;
650fA   endif;
650fD   //$lhpo = $kpo;
650bA   $lhseq = $pseq;
650bA   $ltype = ' ';
650bA   $lspo = $spo;
650bA   ha410($lparm:$lparm1);
650bA   if $lrtn = '*EXIT';
650bA     error = *on;
650bA     leavesr;
650bA   endif;
650cA   $ckcmd = '*CHECK';
650cA   $ckwhse = $pwhse;
650cA   $cklevl = 'REXI';
650cA   $ckfound = ' ';
650cA   ha413($ckcmd:$ckwhse:$cklevl:$ckfound);
650bA /end-free
650bAc                   endif
650eDc*                  if        client = greenleaf and $ckfound = 'Y'
650eDc*                  else
650eMc                   if        $ckfound = 'Y                       '
650eMc                   else
417 AC                   eval      $lcmd = '*CHANGE '
417 AC                   eval      $luky = $puky
417 AC                   eval      $lrtn = *blanks
417 AC                   call      'PO240'
417 AC                   parm                    $lparm
417 AC                   parm                    $lrtn
GLPaAc                   endif
417 AC                   endif
520aA*   Display item message.
     *
     *     Mark as touched/checked
     *
     C                   if        wkoopt = ' X'

CLDaA*      Get start time
CLDaAC                   if        client = cityline
FPRaAC                             or client = FoodPro
CLDaAC                   exsr      zzSDtime
CLDaAC                   endif

     *
     *    Once answered yes process others in subfile without
     *    promptiong each time...
     *
     C                   if        woyes = 'N'
     C                   exfmt     verify
     C                   endif
     C                   if        woyes = 'Y'
     **
     **  Get key to
     *   Read PORCV.  If not found then add...
     C                   eval      dsukey = $puky
     C     detlky        setll     porcv
     C     detlky        reade     porcv                                  55
     C                   if        *in55
640 AC                             or *in55 = *off
640 AC                             and poredt > 0
     C                   eval      porwhs = pdwhse
     C                   eval      porpo = pdpo
     C                   eval      porseq = pdseq
     *
640eDC*                  move      #jobdt        $cvd6i
640eMC                   move      #jobdate      $cvd6i
610aAC                   eval      $cvcmd = '*MDYCMD '
610aAC                   call      @cvtdt
610aAC                   parm                    $cvtdt
610aAC                   eval      pordte = $cvd8o
610aDC**** #jobdt        mult      10000.01      wrkdte
610aDC**** 20000000      add       wrkdte        pordte
640eDC*                  eval      portim = #jobtm
640eMC                   eval      portim = #jobtime
     C                   eval      porusr = #user
     C                   eval      poremp = $emp#
     C                   eval      portrn = 0
416eD**                   Z-ADD0         PORLIC
416e C                   eval      porlic = *blanks
     C                   eval      porlbl = 0
     C                   eval      poract = 'X'
416eAC                   eval      poredt = 0
416eAC                   eval      poreti = 0
     C                   write     porrec
650kA*
650kA*    Update PO header to partial if status is open.
650kAC     phkey         chain     pohdr                              79
650kAC                   if        not *in79 and
650kAC                             phstat = '0'
650kAC                   eval      phstat = '1'
650kAC                   update    phrec
650kAC                   else
650kAC                   unlock    pohdr
650kAC                   endif
650kAC
     *
     C                   else
416bA*    Release lock if record found.
416bAC                   unlock    porcv
     C                   endif

CLDaA*  If specific client, check to see if SMARTDOCK start and/or stop
CLDaA*  times should be updated.
CLDaAC                   if        client = cityline
FPRaAC                             or client = FoodPro
CLDaAC                   exsr      zzSDstart
CLDaAC                   exsr      zzckrc
CLDaAC                   endif

     C                   endif
     C                   endif
     *
     C     endopt        endsr
     *----------------------------------------------------------------
     *
     *  ZZOPN    Process file OPEN.
     *
     C     zzopn         begsr
     *
     *   Process file Open for P/O by item view.
     C                   select
     C                   when      ovrtyp = '*POITEM '
     *
     C                   open      po120a
     C                   eval      open1 = *on
     *
     *   Process file Open for P/O by Mfr view.
     C                   when      ovrtyp = '*POMFR  '
     *
     C                   open      po120b
     C                   eval      open1 = *on
     *
     *   Process file Open for Position To P/O by item view.
     C                   when      ovrtyp = '*POS2ITM'  or
     C                             ovrtyp = '*SLCTITM'
     *
     C                   open      po120c
     C                   eval      open2 = *on
     *
     *   Process file Open for Position To P/O by Mfr view.
     C                   when      ovrtyp = '*POS2MFR'  or
     C                             ovrtyp = '*SLCTMFR'
     *
     C                   open      po120d
     C                   eval      open2 = *on
     *
     C                   endsl
     *
     C     endopn        endsr
     *----------------------------------------------------------------
     *
     *  ZZOVR    Process file overrides.
     *
     C     zzovr         begsr
     *
     *   Process file override for P/O by item view.
     C                   select
     C                   when      ovrtyp = '*POITEM '
     *
     *      If query file already open then close it.
     *
     C                   eval      qcmd = cls1(1)
     C                   call      'QCMDEXC'                            78
     C                   parm                    qcmd            256
     C                   parm      80            qlen             15 5
     *
     C                   if        open1 = *on
     C                   close     po120a                               78
     C                   close     po120b                               78
     C                   endif
     *
     *      Override database file.
     *
     *          OVRDBF FILE(PO120A) TOFILE(POSPO) SHARE(*YES)
     *
     C                   eval      qcmd = ovr(1)
     C                   call      'QCMDEXC'
     C                   parm                    qcmd
     C                   parm      80            qlen
     *
     *   Process file override for P/O by Mfr view.
     C                   when      ovrtyp = '*POMFR  '
     *
     *      If query file already open then close it.
     *
     C                   eval      qcmd = cls1(1)
     C                   call      'QCMDEXC'                            78
     C                   parm                    qcmd
     C                   parm      80            qlen
     *
     C                   if        open1 = *on
     C                   close     po120a                               78
     C                   close     po120b                               78
     C                   endif
     *
     *      Override database file.
     *
     *          OVRDBF FILE(PO120B) TOFILE(POSPO) SHARE(*YES)
     *
     C                   eval      qcmd = ovr(2)
     C                   call      'QCMDEXC'
     C                   parm                    qcmd
     C                   parm      80            qlen
     *
     *   Process file override for Position To P/O by item view.
     C                   when      ovrtyp = '*POS2ITM'  or
     C                             ovrtyp = '*SLCTITM'
     *
     *      If query file already open then close it.
     *
     C                   eval      qcmd = cls1(2)
     C                   call      'QCMDEXC'                            78
     C                   parm                    qcmd
     C                   parm      80            qlen
     *
     C                   if        open2 = *on
     C                   close     po120c                               78
     C                   close     po120d                               78
     C                   endif
     *
     *      Override database file.
     *          OVRDBF FILE(PO120C) TOFILE(POSPO2) SHARE(*YES)
     *
     C                   eval      qcmd = ovr(3)
     C                   call      'QCMDEXC'
     C                   parm                    qcmd
     C                   parm      80            qlen
     *
     *   Process file override for Position To P/O by Mfr view.
     C                   when      ovrtyp = '*POS2MFR'  or
     C                             ovrtyp = '*SLCTMFR'
     *
     *      If query file already open then close it.
     *
     C                   eval      qcmd = cls1(2)
     C                   call      'QCMDEXC'                            78
     C                   parm                    qcmd
     C                   parm      80            qlen
     *
     C                   if        open2 = *on
     C                   close     po120c                               78
     C                   close     po120d                               78
     C                   endif
     *
     *      Override database file.
     *
     *          OVRDBF FILE(PO120D) TOFILE(POSPO2) SHARE(*YES)
     *
     C                   eval      qcmd = ovr(4)
     C                   call      'QCMDEXC'
     C                   parm                    qcmd
     C                   parm      80            qlen
     *
     C                   endsl
     *
     C     endovr        endsr
     *  --------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *  See if user is trying to position to item or Mfr#
     C                   select
     *  Position to Item with a Single P/O.
     C                   when      ptinp1 <> *blanks  and
     C                             view = '*POITEM '  and
     C                             $spo = '*NO '
     C                   eval      pdseq = *loval
     C                   eval      pditem = ptinp1
     C                   eval      ptinp1 = *blanks
     C                   eval      repos = *on
     *
     *  Position to mfr# with a Single P/O.
     C                   when      w1mfr <> *blanks  and
     C                             view = '*POMFR  '  and
     C                             $spo = '*NO '
     C                   eval      pdvitm = w1mfr
     C                   eval      w1mfr = *blanks
     C                   eval      repos = *on
     *
     *    With a Super P/O.
     *
     *    Position to Item - Display Pop-up Window.
     C                   when      $spo = '*YES'  and
     C                             view = '*POITEM '  and
     C                             ptinp1 <> *blanks  and
     C                             ptinp2 = *blanks
     C                   eval      pditem = ptinp1
     C                   eval      ovrtyp = '*POS2ITM'
     C                   exsr      zzwdw
     C                   eval      ptinp1 = *blanks
     *
     *    Position to Mfr# - Display Pop-up Window.
     C                   when      $spo = '*YES'  and
     C                             view = '*POMFR  '  and
     C                             w1mfr <> *blanks  and
     C                             ptinp2 = *blanks
     C                   eval      pdvitm = w1mfr
     C                   eval      ovrtyp = '*POS2MFR'
     C                   exsr      zzwdw
     C                   eval      w1mfr = *blanks
     *
     *    Position to P/O and/or Item - No Window.
     C                   when      $spo = '*YES'  and
     C                             view = '*POITEM '  and
     C                             ptinp1 <> *blanks  and
     C                             ptinp2 <> *blanks  or
     *
     C                             $spo = '*YES'  and
     C                             view = '*POITEM '  and
     C                             ptinp1 = *blanks  and
     C                             ptinp2 <> *blanks
     C                   eval      pdseq = *loval
     C                   eval      pditem = ptinp1
     C                   eval      ptinp1 = *blanks
     C                   eval      pdpo = ptinp2
     C                   eval      ptinp2 = *blanks
     C                   eval      repos = *on
     *
     *    Position to Mfr# with a Super P/O - No Window.
     C                   when      $spo = '*YES'  and
     C                             view = '*POMFR  '  and
     C                             w1mfr <> *blanks  and
     C                             ptinp2 <> *blanks  or
     *
     C                             $spo = '*YES'  and
     C                             view = '*POMFR  '  and
     C                             ptinp1 = *blanks  and
     C                             ptinp2 <> *blanks
     C                   eval      pdvitm = w1mfr
     C                   eval      w1mfr = *blanks
     C                   eval      pdpo = ptinp2
     C                   eval      ptinp2 = *blanks
     C                   eval      repos = *on
     *
     C                   endsl
     C     endzps        endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS2   Position to record
     *
     C     zzpos2        begsr
     *
     *    Code to use when we are not using a partial key.
     *
     *R         $POCMD    IFEQ '*TOP'
     *R         *LOVAL    SETLLRECORD
     *R                   ELSE
     *R         $POCMD    IFEQ '*BOTTOM'
     *R         *HIVAL    SETLLRECORD
     *R                   END
     *R                   END
     *
     *    Code to use when we do have a partial key to use.
     *
     C                   select
     *
     *    Single P/O in Item sequence.
     C                   when      view = '*POITEM '  and
     C                             $spo = '*NO '
     *
     C                   if        $pocmd = '*TOP'
     C     partky        setll     record
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     partky        setgt     record
     C                   endif
     C                   endif
     *
     *    Single P/O in Mfr. sequence.
     C                   when      view = '*POMFR  '  and
     C                             $spo = '*NO '
     *
     C                   if        $pocmd = '*TOP'
     C     partky        setll     record2
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     partky        setgt     record2
     C                   endif
     C                   endif
     *
     *    Super P/O in Item sequence.
     C                   when      view = '*POITEM '  and
     C                             $spo = '*YES'
     *
     C                   if        $pocmd = '*TOP'
     C     prtky2        setll     oqreca
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     prtky2        setgt     oqreca
     C                   endif
     C                   endif
     *
     *    Super P/O in Mfr. sequence.
     C                   when      view = '*POMFR  '  and
     C                             $spo = '*YES'
     *
     C                   if        $pocmd = '*TOP'
     C     prtky2        setll     oqrecb
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     prtky2        setgt     oqrecb
     C                   endif
     C                   endif
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
610bA*
610bA*  ZZPRDLBL   Produce label creation
610bA*
     C     zzprdlbl      begsr
     C                   eval      w4dev  = '*JOB'
     C                   eval      w4lqty = 0

     *  Process window to produce license plates for external storage

     C                   dow       forevr = forevr
     C                   exfmt     Wprdlbl
     C                   if        *inkl = *on
     C                   leave
     C                   endif

     C                   eval      *in94 = *off

     *     Number of labels cannot be zero

     C                   if        w4lqty = 0
     C                   eval      *in94 = *on
     C                   iter
     C                   endif

     *     No errors, print labels

     *  Print label

     C                   eval      $plfmt = 'PRODUCE'
     C                   if        client = saval
     C                   eval      $plset = 'ZBRSVL'
     C                   else
     C                   eval      $plset = 'PLBL40'
     C                   endif
      *testing purpose
     C***                eval      $plset = 'ZBRSVL'
      *
610d C*                  if        w4dev <> '*JOB'
     C                   eval      $pdev  = w4dev
610d C*                  endif
     *  GET PACK DESCRIPTION
     C     itkey         chain     piritem                            79
     C                   if        not *in79
     C                   eval      $itpdsc = itpdsc
610d C                   eval      $itdesc = itdesc
     C                   else
     C                   eval      $itpdsc = *blanks
610d C                   eval      $itdesc = *blanks
     C                   endif

     C                   for       i = 1 to w4lqty

740dMC                   call      @PRTPG
     C                   parm                    $pcmd             8
     C                   parm                    $plset            6
     C                   parm                    $plfmt            8
     C                   parm      $pwhse        $plwhse           3 0
     C                   parm                    $pwhsd           30
     C                   parm                    itwhdp
     C                   parm                    sldisp
     C                   parm                    $pdispa           1
     C                   parm                    $pdispb          11
     C                   parm                    $pchkd1           3
     C                   parm                    $pchkd2           3
     C                   parm                    $pchkd3           3
     C                   parm                    wklic            15
     C                   parm                    $plcn2           15
     C                   parm                    pditem
     C                   parm                    $pbrnd           10
     C                   parm                    $itpdsc          15
610dDC*                  parm      wodsc         $itdesc          30
610dMC                   parm                    $itdesc          30
     C                   parm      $ppo          $ptxt1           30
     C                   parm                    $ptxt2           30
     C                   parm                    $ptxt3           30
     C                   parm                    $ptrailr          8
     C                   parm                    $psize            3
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm                    $pexpda           8
     C                   parm                    $pindta           8
     C                   endfor
650jA*  Add missing code from update.
610fA*  Force last record so it will close the spool
610fA*
610fAC                   if        i=w4lqty
740dMC                   call      @PRTPG
610fAC                   parm      '*PRODEND'    $pcmd             8
610fAC                   parm                    $plset            6
610fAC                   parm                    $plfmt            8
610fAC                   parm                    $plwhse           3 0
610fAC                   parm                    $pwhsd           30
610fAC                   parm                    $slwhdp           5
610fAC                   parm                    $sldisp          12
610fAC                   parm                    $pdispa           1
610fAC                   parm                    $pdispb          11
610fAC                   parm                    $pchkd1           3
610fAC                   parm                    $pchkd2           3
610fAC                   parm                    $pchkd3           3
610fAC                   parm                    wklic            15
610fAC                   parm                    $plcn2           15
610fAC                   parm                    $pditem          15
610fAC                   parm                    $pbrnd           10
610fAC                   parm                    $ppdesc          15
610fAC                   parm                    $itdesc          30
610fAC                   parm                    $ptxt1           30
610fAC                   parm                    $ptxt2           30
610fAC                   parm                    $ptxt3           30
610fAC                   parm                    $ptrailr          8
610fAC                   parm                    $psize            3
610fAC                   parm                    $pdev            10
610fAC                   parm                    $pform           10
610fAC                   parm                    $pexpda           8
610fAC                   parm                    $pindta           8
610fAC                   parm                    $lparm
610fAC                   endif
610fDC*                  leave

     C                   enddo

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPUTO   Get Put away option.
     *             Directed or Manual put away
     *
     C     zzputo        begsr
     *
     C     itkey2        chain     piritem                            79
     C                   if        not *in79
     C                   eval      kycode = '*PICK   '
     C     opkey2        chain     optiond                            79
     C                   if        *in79
     C                   eval      opmput = 'N'
     C                   endif
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZQRY    Process OPNQRYF.
     *
     C     zzqry         begsr
     *
     *    Run OPNQRYF to select records for Super P/O by P/O. by Item.
     C                   select
     C                   when      ovrtyp = '*POITEM '
     *
     *    Load QRYSLT selection values.
     C                   movea     qry1(2)       a80
     C                   movea     $whsea        a80(10)
     C                   movea     $kspo         a80(28)
     C                   movea     a80           qry1(2)
     *
     *    Build command string for query.
     C                   eval      qcmd = qry1(1)
     C     qcmd          cat       qry1(2):0     qcmd
     C     qcmd          cat       qry1(3):1     qcmd
     C     qcmd          cat       qry1(4):1     qcmd
     C     qcmd          cat       qry1(5):1     qcmd
     *
     C                   when      ovrtyp = '*POMFR  '
     *
     *    Load QRYSLT selection values.
     C                   movea     qry2(2)       a80
     C                   movea     $whsea        a80(10)
     C                   movea     $kspo         a80(28)
     C                   movea     a80           qry2(2)
     *
     *    Build command string for query.
     C                   eval      qcmd = qry2(1)
     C     qcmd          cat       qry2(2):0     qcmd
     C     qcmd          cat       qry2(3):1     qcmd
     C     qcmd          cat       qry2(4):1     qcmd
     C     qcmd          cat       qry2(5):1     qcmd
     *
     *    Run OPNQRYF to Position to Item(s) on Super P/O.
     C                   when      ovrtyp = '*POS2ITM'
     *
     *    Load QRYSLT selection values.
     C                   movea     qry3(6)       a80
     C                   movea     $whsea        a80(10)
     C                   movea     $kspo         a80(28)
     C                   movea     ptinp1        a80(54)
     C                   movea     a80           qry3(2)
     *
     *    Build command string for query.
     C                   eval      qcmd = qry3(1)
     C     qcmd          cat       qry3(2):0     qcmd
     C     qcmd          cat       qry3(3):1     qcmd
     C     qcmd          cat       qry3(4):1     qcmd
     C     qcmd          cat       qry3(5):1     qcmd
     *
     *    Run OPNQRYF to Position to Mfr#(s) on Super P/O.
     C                   when      ovrtyp = '*POS2MFR'
     *
     *    Load QRYSLT selection values.
     C                   movea     qry4(6)       a80
     C                   movea     $whsea        a80(10)
     C                   movea     $kspo         a80(28)
     C                   movea     w1mfr         a80(54)
     C                   movea     a80           qry4(2)
     *
     *    Build command string for query.
     C                   eval      qcmd = qry4(1)
     C     qcmd          cat       qry4(2):0     qcmd
     C     qcmd          cat       qry4(3):1     qcmd
     C     qcmd          cat       qry4(4):1     qcmd
     C     qcmd          cat       qry4(5):1     qcmd
     *
     *    Run OPNQRYF to select item from Super P/O.
     C                   when      ovrtyp = '*SLCTITM'
     *
     *    Load QRYSLT selection values.
     C                   movea     qry3(2)       a80
     C                   movea     $whsea        a80(10)
     C                   movea     $kspo         a80(28)
     C                   movea     ptinp1        a80(54)
     C                   movea     a80           qry3(2)
     *
     *    Build command string for query.
     C                   eval      qcmd = qry3(1)
     C     qcmd          cat       qry3(2):0     qcmd
     C     qcmd          cat       qry3(3):1     qcmd
     C     qcmd          cat       qry3(4):1     qcmd
     C     qcmd          cat       qry3(5):1     qcmd
     *
     C                   when      ovrtyp = '*SLCTMFR'
     *
     *    Load QRYSLT selection values.
     C                   movea     qry4(2)       a80
     C                   movea     $whsea        a80(10)
     C                   movea     $kspo         a80(28)
     C                   movea     w1mfr         a80(54)
     C                   movea     a80           qry4(2)
     *
     *    Build command string for query.
     C                   eval      qcmd = qry4(1)
     C     qcmd          cat       qry4(2):0     qcmd
     C     qcmd          cat       qry4(3):1     qcmd
     C     qcmd          cat       qry4(4):1     qcmd
     C     qcmd          cat       qry4(5):1     qcmd
     *
     C                   endsl
     *
     *    Process OPNQRYF to select records.
     C                   call      'QCMDEXC'
     C                   parm                    qcmd
     C                   parm      256           qlen
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZRCV    Receive item
     *
     C     zzrcv         begsr
650dA*
650dA*  Start RCVPO transaction
650dA*
650dAc                   exsr      zzrcvpo
     *
640fA*  TEST FOR new Haccp Programs
640fA*
640fA * check to make sure programs exist or don't do call
640fAC                   eval      qcmd = 'CHKOBJ '
640fAC                                  + 'OBJ(HA410) '
640fAC                                  + 'OBJTYPE(*PGM)'
640fAC                   call      'QCMDEXC'                            78
640fAC                   parm                    qcmd            256
640fAC                   parm      80            qlen             15 5
640fAc                   if        *in78 = *off
640fA /free
640fA   // first do pohdr processing, before detail
640fA   $lwhse = $kwhse;
640fA   $lcmd = '*POHDR  ';
640fA   $llevel = 'RCVH';
640fA   $llicense = ' ';
640fA   if $spo = '*YES';
640fA     $lhpo = $kspo;
640fA   else;
640fA     $lhpo = $kpo;
640fA   endif;
640fA   $lhseq = 0;
640fA   $ltype = ' ';
640fA   $lspo = $spo;
650aD   //ha410($lparm);
650aM   ha410($lparm:$lparm1);
640fA   if $lrtn = '*EXIT';
640fA     nxtscr = 'EOJ';
640fA     leavesr;
640fA   endif;
640fA
640fA   // Now do podtl processing.
640fA   $lwhse = $kwhse;
640fA   $lcmd = '*PODTL  ';
640fA   $llevel = 'RCVI';
640fA   $llicense = $pitem;
640fA   $lhpo = $kpo;
640fA   $lhseq = $pseq;
640fA   $ltype = ' ';
640fA   $lspo = $spo;
650aD   //ha410($lparm);
650aM   ha410($lparm:$lparm1);
640fA   if $lrtn = '*EXIT';
640fA     error = *on;
640fA     leavesr;
640fA   endif;
640fA /end-free
640fAc                   endif
     C                   exsr      zzputo
500a C                   if        $cmd = '*SPRECV '
500a C                   eval      opmput = 'N'
500a C                   endif
     *
     C                   if        wkoopt = ' 7'
     C                   eval      $lcmd = '*QUICK  '
     C                   else
     C                   eval      $lcmd = '*CHANGE '
     C                   endif
     *
     C                   eval      $luky = $puky
417m C                   eval      $lupc = *blanks
417m C                   if        upcok = *on
     C                   eval      $lupc = w1upc
417m C                   else
417m C                   eval      $lupc = *blanks
417m C                   endif
640dAc                   if        asnok  = *on and $aupc <> ' '
640dAc                   eval      $lupc = $aupc
640dAc                   eval      $aupc = ' '
640dAc                   endif
     C                   eval      w1upc = *blanks
417bAC                   eval      w1upcd = *blanks
     C                   eval      $lrsqt = 0
     *
416fAC                   eval      svmput = opmput
416fD**         OPMPUT    IFEQ 'N'
     *
416fA*  Note: For every item check the DEPTDSG file for designation
416fA*        code.  If the item's desig code is in the file, then
416fA*        use opposite putaway method than the default for the
416fA*        department (OPMPUT).
416fA*
416fA*        PUTTYP=*ON - Desig code found in file. Use opp. method.
416fA*        PUTTYP=*OFF - DSesig code not found.
     *
     *
416fAC                   exsr      zzdesg
     *
500a *   Do not execute for desig code for special receiving.
500a C                   if        $cmd <> '*SPRECV '
416fAC                   if        puttyp = *on  and
416fAC                             opmput = 'N'
416fAC                   eval      svmput = 'Y'
416fAC                   endif
     *
416fAC                   if        puttyp = *on  and
416fAC                             opmput = 'Y'
416fAC                   eval      svmput = 'N'
416fAC                   endif
500aAC                   endif
     *
500a C                   if        $cmd = '*SPRECV '
700cAc                             and pdspcl <> 'XD'
500a C                   eval      $lcmd = '*CHANGES'
500a C                   endif
640eA * add dri to get data from itemfld
640eA /free
640eA       exsr clr$item;

640eA       $itWhse = $pwhse;
640eA       $ititem = $litem;

640eA       $dricommand = '*ITEM';
640eA       $drisubcmd  = '%GETALL';
640eA       $drisys2upd = 'D';
640eA       chk4err = *on;
640eA       zmflag  = *off;
640eA       exsr zzzdricop;
640eA       if error = *on;
640eA         $ifucicde = ' ';
640eA         $ifrcvmth = ' ';
640eA       endif;
640eA /end-free
650sDC*                  if        svmput = 'N'
650sMC                   if        svmput = 'N' and pdspcl <> 'XD'
750aAc                   eval      $lsvmput = svmput
640eAc                   if        $ifrcvmth = '2'
640eAc                   call      'PO137'
640eAC                   parm                    $lparm
640eAC                   parm                    $lupc
640eAC                   parm                    $lrsqt
640eAc*                  parm                    $lqty             8 0
640eAc*                  parm                    $l#pall           5 0
640eAc                   parm                    $lexpdt           6 0
640eAc                   parm                    $lwgt            11 3
640eAc                   parm                    $lmfgdt           6 0
640eAc                   parm                    $llot            20
640eAc                   parm      w1asn         $llpn            50
640eAc                   parm      w1uci         $luci           100
640eAc                   parm      pdspcl        $lxd              2
650aAc                   parm                    $lparm1
650dAc                   parm                    $lsavetrn         7 0
640eAc*                  eval      w1uci = ' '
640eAc                   else
     C                   call      'PO132'
     C                   parm                    $lparm
     C                   parm                    $lupc            20
     C                   parm                    $lrsqt            7 0
640eAc                   parm                    $lexpdt           6 0
640eAc                   parm                    $lwgt            11 3
640eAc                   parm                    $lmfgdt           6 0
640eAc                   parm                    $llot            20
640eAc                   parm      w1asn         $llpn            50
640eAc                   parm      w1uci         $luci           100
640eAc                   parm      pdspcl        $lxd              2
650aAc                   parm                    $lparm1
650dAc                   parm                    $lsavetrn         7 0
650hAc                   parm                    $bcGtin
650hAc                   parm      $bcprodd      $pbcProdD         6 0
650hAc                   parm      $bclot        $pbcLot          20
640eAc                   endif
610eAC                   eval      fkey(1) = $luky
640eAc                   eval      w1uci = ' '
650hAc                   eval      $bcGtinSent = '0'
     *R                   ADD  $LRSQT    WOSRC
     C                   exsr      zztrcv
     C                   else
640eAc                   if        $ifrcvmth = '2'
640eAc                   call      'PO237'
640eAC                   parm                    $lparm
640eAC                   parm                    $lupc
640eAC                   parm                    $lrsqt
640eAc                   parm                    $lqty             8 0
640eAc                   parm                    $l#pall           5 0
640eAc                   parm                    $lexpdt           6 0
640eAc                   parm                    $lwgt            11 3
640eAc                   parm                    $lmfgdt           6 0
640eAc                   parm                    $llot            20
640eAc                   parm      w1asn         $llpn            50
640eAc                   parm      w1uci         $luci           100
640eAc                   parm      pdspcl        $lxd              2
650aAc                   parm                    $lparm1
650dAc                   parm                    $lsavetrn         7 0
650lAc                   parm      osscode       $osscode          1
640eAc*                  eval      w1uci = ' '
640eAc                   else

CLDaA*      Get start time
CLDaAC                   if        client = cityline
FPRaAC                             or client = FoodPro
CLDaAC                   exsr      zzSDtime
CLDaAC                   endif

650mAc                   eval      pgtnsc = 'PO232'
650mAc                   exsr      zzendp
     C                   call      'PO232'
     C                   parm                    $lparm
     C                   parm                    $lupc
     C                   parm                    $lrsqt
640dAc                   parm                    $lqty             8 0
640dAc                   parm                    $l#pall           5 0
640dAc                   parm                    $lexpdt           6 0
640dAc                   parm                    $lwgt            11 3
640dAc                   parm                    $lmfgdt           6 0
640dAc                   parm                    $llot            20
640dAc                   parm      w1asn         $llpn            50
650aAc                   parm                    $lparm1
650dAc                   parm                    $lsavetrn         7 0
650hAc                   parm                    $bcGtin
650hAc                   parm      $bcprodd      $pbcProdD         6 0
650hAc                   parm      $bclot        $pbcLot          20
650lAc                   parm      osscode       $osscode          1
650mAc                   exsr      zzstrt

CLDaA*  If specific client and qty was received, check to see if
CLDaA*  SMARTDOCK start and/or stop times should be updated.
CLDaAC                   if        client = cityline and $lrtn = '*OK     '
FPRaAC                             or client = FoodPro and $lrtn = '*OK     '
CLDaAC                   exsr      zzSDstart
CLDaAC                   exsr      zzckrc
CLDaAC                   endif

640eAC                   endif
640eAc                   eval      w1uci = ' '
640dAc                   eval      $lqty  = 0
640dAc                   eval      $l#pall = 0
640dAc                   eval      $lexpdt = 0
640dAc                   eval      $lwgt   = 0
640dAc                   eval      $lmfgdt = 0
640dAc                   eval      $llot   = ' '
640dAc                   eval      $llpn   = ' '
650hAc                   eval      $bcgtinsent = '0'
650hAc                   eval      $bcprodd = 0
650hAc                   eval      $bclot = ' '
650hAc                   eval      $bcgtin = ' '
610eAC                   eval      fkey(1) = $luky
     *R                   ADD  $LRSQT    WOSRC
     C                   exsr      zztrcv
     C                   endif
640dAC                   eval      w1asn = *blanks
     C                   if        $lrtn = '*OK     '
     *    Recalculate session total received.
     *
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     *
     C                   endsr
650dA*----------------------------------------------------------------
650dA*
650dA*  ZZRCVPOCLEAN CLEAN for started RCVPO Transaction
650dA*
650dAC     zzrcvpoclean  begsr
650dAc                   if        $lsavetrn   > 0
650dAC                   call      @crtrcv
650dAC                   parm      '*PO'         $lcmdr           10
650dAC                   parm      '*CLEAN'      $lsubcmd         10
650dAC                   parm      $pwhse        @lwhse            3 0
650dAC                   parm                    $lpcs             5 0
650dAC                   parm                    $lpallets         5 0
650dAC                   parm                    $lsavetrn         7 0
650dAC                   parm                    $lord             9
650dAC                   parm                    $litstyp          1
650dAC                   parm                    $litwhdp          5
650dAC*                  parm      '0'           $lomplete         1
650dAC                   parm                    $lrtnr           10
650dAc                   endif
650dAC                   endsr
650dA*----------------------------------------------------------------
650dA*
650dA*  ZZRCVPO  Create receiver transaction.
650dA*
650dAC     zzrcvpo       begsr
650dA*
650dA*     clear the return field used in po236
650dA*
650dAc                   eval      $lrtn = ' '
650dAC                   call      @crtrcv
650dAC                   parm      '*PO'         $lcmdr           10
650dAC                   parm      '*CREATE'     $lsubcmd         10
650dAC                   parm      $pwhse        @lwhse            3 0
650dAC                   parm      0             $lpcs             5 0
650dAC                   parm      0             $lpallets         5 0
650dAC                   parm      0             $lsavetrn         7 0
650dAC                   parm      $ppo          $lord             9
650dAC                   parm      itstyp        $litstyp          1
650dAC                   parm      itwhdp        $litwhdp          5
650dAC*                  parm      '0'           $lcomplete        1
650dAC                   parm                    $lrtnr           10
650dA*
650dAC                   endsr
CLDaA*----------------------------------------------------------------
CLDaA*
CLDaA*  ZZSDSTART   Update start time in SMARTDOCK file.
CLDaA*
CLDaAC     zzSDstart     begsr

     C     partky        chain     smartdock

     C                   if        %found and smdstr = *blanks
     C                   eval      smdstr = hldtim
     C                   update    smdrec
     C                   endif

     C                   unlock    smartdock
     C                   endsr
     *
CLDaA*----------------------------------------------------------------
CLDaA*
CLDaA*  ZZSDSTOP   Update stop time in SMARTDOCK file.
CLDaA*
CLDaAC     zzSDstop      begsr

     C     partky        chain     smartdock

     C                   if        %found and smdstp = *blanks
     C                   exsr      zzSDtime
     C                   eval      smdstp = hldtim
     C                   update    smdrec
     C                   endif

     C                   unlock    smartdock
     C                   endsr
     *
CLDaA*----------------------------------------------------------------
CLDaA*
CLDaA*  ZZSDTIME   Populate date and time field to write to SMARTDOCK file.
CLDaA*
CLDaAC     zzSDtime      begsr

     C                   time                    curtime
     C                   eval      hldtim=%trim(%subst(%editc(today:'X'):5:2))
     C                                   + '/' +
     C                                    %trim(%subst(%editc(today:'X'):7:2))
     C                                   + '/' +
     C                                    %trim(%subst(%editc(today:'X'):1:4))
     C                                   + ' ' +
     C                                    %trim(%subst(%editc(curtime:'X'):1:2))
     C                                   + ':' +
     C                                    %trim(%subst(%editc(curtime:'X'):3:2))
     C                                   + ':' +
     C                                    %trim(%subst(%editc(curtime:'X'):5:2))
     C                   endsr
650mA*----------------------------------------------------------------
650mA*
650mA*  ZZSTRT  Start timer
650mA*
650mAC     zzstrt        begsr
     *
650mAc                   eval      pgtpgm = #prog
650mAc                   eval      pgtscr = nxtscr
650mAc                   if        pgtnsc = 'PO232     '
650mAc                   eval      pgtscr = pgtnsc
650mAc                   endif
650mAC                   callp     getmicrotime(currstampuc:currstampsys)
650mAc                   eval      pgtStrts = currstampsys
     *
650mAC     endzzs        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZTRCV   Calculate total qty received for PO
     *
     C     zztrcv        begsr
     *
     C                   select
     C                   when      $spo = '*NO '
     *
     C                   eval      wosrc = *zeros
520 AC                   eval      wowgt = *zeros
     C     partky        setll     record
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     partky        reade     record                                 79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   add       pdqrc1        wosrc
     C                   add       pdqrc2        wosrc
     C                   add       pdqrc3        wosrc
520 AC                   add       pddwgt        wowgt
     C                   endif
     C                   enddo
     *
     *    Process Super P/O. Accumulate receiving totals.
     C                   when      $spo = '*YES'  and
     C                             view = '*POITEM '
     *
     C                   eval      wosrc = *zeros
520 AC                   eval      wowgt = *zeros
     C     prtky2        setll     oqreca
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     prtky2        reade     oqreca                                 79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   if        not *in79
     C     pdkey         chain     podtl                              77
     C                   endif
     C                   add       pdqrc1        wosrc
     C                   add       pdqrc2        wosrc
     C                   add       pdqrc3        wosrc
520 AC                   add       pddwgt        wowgt
     C                   endif
     C                   enddo
     *
     *    Process Super P/O. Accumulate receiving totals.
     C                   when      $spo = '*YES'  and
     C                             view = '*POMFR  '
     *
     C                   eval      wosrc = *zeros
520 AC                   eval      wowgt = *zeros
     C     prtky2        setll     po120b
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     prtky2        reade     po120b                                 79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   if        not *in79
     C     pdkey         chain     podtl                              77
     C                   endif
     C                   add       pdqrc1        wosrc
     C                   add       pdqrc2        wosrc
     C                   add       pdqrc3        wosrc
520 AC                   add       pddwgt        wowgt
     C                   endif
     C                   enddo
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUHDR   Update Super P/O status upon exit.
     *
     C     zzuhdr        begsr
     *
     C                   eval      full = *on
     C                   eval      part = *off
     C                   eval      recv = *off
     C     prtky2        setll     pujrec
     C                   dow       forevr = forevr
     C     prtky2        reade     pujrec                                 79
     C                   select
     C                   when      *in79
     C                   leave
     *
     C                   other
     *
     C                   if        not *in79
     C                   if        pdqrc1 < pdqor1
     C                   eval      part = *on
     C                   eval      full = *off
     C                   endif
     *
     C                   if        pdqrc2 < pdqor2
     C                   eval      part = *on
     C                   eval      full = *off
     C                   endif
     *
     C                   if        pdqrc3 < pdqor3
     C                   eval      part = *on
     C                   eval      full = *off
     C                   endif
     *
     C                   if        pdqrc1 > 0
     C                   eval      recv = *on
     C                   endif
     *
     C                   if        pdqrc2 > 0
     C                   eval      recv = *on
     C                   endif
     *
     C                   if        pdqrc3 > 0
     C                   eval      recv = *on
     C                   endif
     C                   endif
     C                   endsl
     C                   enddo
     *
     C                   if        recv = *off
     C                   eval      full = *off
     C                   eval      part = *off
     C                   endif
     *
     *    Update Super P/O header with new status.
     C     prtky2        chain     pohdr                              79
     C                   if        not *in79
     C                   select
     *    Super P/O partially received.
     C                   when      part = *on
     C                   eval      phstat = *on
     *
     *    Super P/O Fully received.
     C                   when      full = *on
     C                   eval      phstat = '2'
     *
     *    Super P/O still Open.
     C                   when      part = *off  and
     C                             full = *off
     C                   eval      phstat = *off
     C                   endsl
     C                   update    phrec
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZWDW    Build Pop-Up window for selection of item/Mfr.
     *
     C     zzwdw         begsr
     *
     C                   eval      svp2po = *blanks
     C                   eval      svp2vl = *blanks
     C                   eval      option = *blanks
417oAC                   eval      *in21 = *off
     *
     C                   select
     C                   when      ovrtyp = '*POS2ITM'  or
     C                             ovrtyp = '*POS2MFR'  or
     C                             ovrtyp = '*SLCTITM'  or
     C                             ovrtyp = '*SLCTMFR'
     *    Condition heading in window.
     C                   eval      *in41 = *on
     *    Process file override.
     C                   exsr      zzovr
     *    Process OPNQRYF.
     C                   exsr      zzqry
     *    Open file for processing.
     C                   exsr      zzopn
     C                   endsl
     *
     ********************************************************************
     *
     C                   eval      recno4 = *zeros
417b C                   eval      repos = *off
     *
     C                   select
     *    User chose to Select one Item.
     C                   when      ovrtyp = '*SLCTITM'
     *
     *    Find out if item on more than one P/O.
     *    If the item is on only ONE P/O, then position to the P/O
     *    and item.
     C                   eval      n = 1
     C                   eval      ttlrcd = *zeros
     C     prtky3        setll     oqrecc
     C     1             do        2             n
     C     prtky3        reade     oqrecc                                 79
     C                   select
     C                   when      *in79  and
     C                             n = 1
     C                   leave
     *
     *    Item found on more than one P/O.
     C                   when      n = 2
     C                   if        *in79
     C                   eval      ttlrcd = 1
     C                   else
     C                   eval      ttlrcd = n
     C                   endif
     C                   endsl
     C                   enddo
     *
     C                   select
     *    Item NOT found on any P/O. Don't reposition the screen.
     C                   when      ttlrcd < 1
     C                   eval      repos = *off
     *
     *    Item on only ONE P/O. Position to the item.
     C                   when      ttlrcd = 1
     C                   eval      wopo4 = pdpo
     C                   eval      hseq = pdseq
     C                   eval      hitem = pditem
     C                   eval      hvitm = pdvitm
     C                   eval      $kpo = pdpo
     C                   eval      svp2po = pdpo
     C                   eval      svp2vl = ptinp1
     C                   eval      repos = *on
     *
     *    Item on more than ONE P/O. Display select window.
     C                   when      ttlrcd > 1
     *
     C                   eval      w4titl = titl01
     C                   write     window4
     *    Clear subfile.
     C                   eval      *in01 = *off
     C                   write     dspsfc4
     C                   eval      *in01 = *on
     C                   eval      slctxt = 'Item:'
     C                   eval      slcval = ptinp1
     *
     *    Fill subfile.
     C     prtky3        setll     oqrecc
     C                   dow       forevr = forevr
     C     prtky3        reade     oqrecc                                 79
     C                   select
     C                   when      *in79
     C                   leave
     *
     C                   other
     C                   exsr      zzfil4
     C                   exsr      sflad4
     C                   endsl
     C                   enddo
     *
     *    Now that subfile is loaded, Display it to the user.
     C                   exsr      zzwdw2
     *
     C                   endsl
     *
     ********************************************************************
     *
     *    User chose to Select one Mfr#.
     C                   when      ovrtyp = '*SLCTMFR'
     *
     *    Find out if Mfr# on more than one P/O.
     *    If the Mfr# is on only ONE P/O, then position to the P/O
     *    and Mfr#.
     C                   eval      n = 1
     C                   eval      ttlrcd = *zeros
     C     prtky4        setll     oqrecd
     C     1             do        2             n
     C     prtky4        reade     oqrecd                                 79
     C                   select
     C                   when      *in79  and
     C                             n = 1
     C                   leave
     *
     *    Item found on more than one P/O.
     C                   when      n = 2
     C                   if        *in79
     C                   eval      ttlrcd = 1
     C                   else
     C                   eval      ttlrcd = n
     C                   endif
     C                   endsl
     C                   enddo
     *
     C                   select
     *    Mfr# NOT found on any P/O. Don't reposition the screen.
     C                   when      ttlrcd < 1
     C                   eval      repos = *off
     *
     *    Mfr# on only ONE P/O. Position to the Mfr#.
     C                   when      ttlrcd = 1
     C                   eval      wopo4 = pdpo
     C                   eval      hseq = pdseq
     C                   eval      hitem = pditem
     C                   eval      hvitm = pdvitm
     C                   eval      $kpo = pdpo
     C                   eval      svp2po = pdpo
     C                   eval      svp2vl = w1mfr
     C                   eval      repos = *on
     *
     *    Mfr# on more than ONE P/O. Display select window.
     C                   when      ttlrcd > 1
     *
     C                   eval      w4titl = titl01
     C                   write     window4
     *    Clear subfile.
     C                   eval      *in01 = *off
     C                   write     dspsfc4
     C                   eval      *in01 = *on
     C                   eval      slctxt = 'Mfr :'
     C                   eval      slcval = w1mfr
     *
     *    Fill subfile.
     C     prtky4        setll     oqrecd
     C                   dow       forevr = forevr
     C     prtky4        reade     oqrecd                                 79
     C                   select
     C                   when      *in79
     C                   leave
     C                   other
     *
     C                   exsr      zzfil4
     C                   exsr      sflad4
     C                   endsl
     C                   enddo
     *
     *    Now that subfile is built, Display it to the user.
     C                   exsr      zzwdw2
     *
     C                   endsl
     *
     ********************************************************************
     *
     *    User chose to Position to Item.
     C                   when      ovrtyp = '*POS2ITM'
416dA*
416dA*    Find out if item on more than one P/O.
416dA*    If the item is on only ONE P/O, then position to the P/O
416dA*    and item and do not display pop-up window.
416dAC                   eval      n = 1
416dAC                   eval      ttlrcd = *zeros
416dAC     prtky3        setll     oqrecc
416dAC     1             do        2             n
416dAC     prtky3        reade     oqrecc                                 79
416dAC                   select
416dAC                   when      *in79  and
416dAC                             n = 1
416dAC                   leave
416dA*
416dA*    Item found on more than one P/O.
416dAC                   when      n = 2
416dAC                   if        *in79
416dAC                   eval      ttlrcd = 1
416dAC                   else
416dAC                   eval      ttlrcd = n
416dAC                   endif
416dAC                   endsl
416dAC                   enddo
416dA*
416dAC                   select
416dA*    Item on only ONE P/O. Position to the item. No Window.
416dAC                   when      ttlrcd = 1
416dAC                   eval      wopo4 = pdpo
416dAC                   eval      hseq = pdseq
416dAC                   eval      hitem = pditem
416dAC                   eval      hvitm = pdvitm
416dAC                   eval      $kpo = pdpo
416dAC                   eval      svp2po = pdpo
416dAC                   eval      svp2vl = ptinp1
416dAC                   eval      repos = *on
416dA*
416dA*    Item on more than ONE P/O or item not found. Display window.
416dAC                   when      ttlrcd > 1  or
416dAC                             ttlrcd < 1
     *
     C                   eval      w4titl = titl03
     C                   write     window4
     *    Clear subfile.
     C                   eval      *in01 = *off
     C                   write     dspsfc5
     C                   eval      *in01 = *on
     *    Load headings.
     C                   eval      w5txt1 = hdr01
     C                   eval      w5txt2 = 'Mfr:'
     *
     *    Fill subfile.
     C     prtky3        setll     oqrecc
     C                   dow       forevr = forevr
     C     prtky2        reade     oqrecc                                 79
     C                   select
     C                   when      *in79
     C                   leave
     *
     C                   other
     C                   exsr      zzfil5
     C                   exsr      sflad5
     C                   endsl
     C                   enddo
     *
     *    Now that subfile is loaded, Display it to the user.
416cAC                   select
416cA*    When 2 or more records are loaded in subfile. Display window.
416cAC                   when      recno4 >= 2
     C                   exsr      zzwdw4
416cA*
416cA*    Only one item loaded. Position to that p/o/item in main sfl.
416cAC                   when      recno4 = 1
416cAC                   eval      wopo4 = pdpo
416cAC                   eval      hseq = pdseq
416cAC                   eval      hitem = pditem
416cAC                   eval      hvitm = pdvitm
416cAC                   eval      $kpo = pdpo
416cAC                   eval      svp2po = pdpo
416cAC                   eval      svp2vl = ptinp1
416cAC                   eval      repos = *on
416cA*
416cA*    No items loaded. Send error message.
416cAC                   when      recno4 <= 0
416caC                   eval      erp2tp = 'item'
416cAC                   eval      erspo = $kspo
416cAC                   eval      erp2vl = ptinp1
416cAC                   exsr      zm3236
416cA*
416cAC                   endsl
416dA*
416dAC                   endsl
     *
     ********************************************************************
     *
     *    User chose to Position to Mfr#.
     C                   when      ovrtyp = '*POS2MFR'
416dA*
416dA*    Find out if Mfr# on more than one P/O.
416dA*    If the Mfr# is on only ONE P/O, then position to the P/O
416dA*    and Mfr#.
416dAC                   eval      n = 1
416dAC                   eval      ttlrcd = *zeros
416dAC     prtky4        setll     oqrecd
416dAC     1             do        2             n
416dAC     prtky4        reade     oqrecd                                 79
416dAC                   select
416dAC                   when      *in79  and
416dAC                             n = 1
416dAC                   leave
416dA*
416dA*    Item found on more than one P/O.
416dAC                   when      n = 2
416dAC                   if        *in79
416dAC                   eval      ttlrcd = 1
416dAC                   else
416dAC                   eval      ttlrcd = n
416dAC                   endif
416dAC                   endsl
416dAC                   enddo
416dA*
416dAC                   select
416dA*    Mfr# on only ONE P/O. Position to the Mfr#.
416dAC                   when      ttlrcd = 1
416dAC                   eval      wopo4 = pdpo
416dAC                   eval      hseq = pdseq
416dAC                   eval      hitem = pditem
416dAC                   eval      hvitm = pdvitm
416dAC                   eval      $kpo = pdpo
416dAC                   eval      svp2po = pdpo
416dAC                   eval      svp2vl = w1mfr
416dAC                   eval      repos = *on
416dA*
416dA*    Mfr# on more than ONE P/O or not found. Display window.
416dAC                   when      ttlrcd > 1  or
416dAC                             ttlrcd < 1
     *
     C                   eval      w4titl = titl04
     C                   write     window4
     *    Clear subfile.
     C                   eval      *in01 = *off
     C                   write     dspsfc5
     C                   eval      *in01 = *on
     *    Load headings.
     C                   eval      w5txt1 = hdr02
     C                   eval      w5txt2 = 'Itm:'
     *
     *    Fill subfile.
     C     prtky4        setll     oqrecd
     C                   dow       forevr = forevr
     C     prtky2        reade     oqrecd                                 79
     C                   select
     C                   when      *in79
     C                   leave
     C                   other
     *
     C                   exsr      zzfil5
     C                   exsr      sflad5
     C                   endsl
     C                   enddo
     *
     *    Now that subfile is built, Display it to the user.
416cAC                   select
416cA*    When 2 or more records are loaded in subfile. Display window.
416cAC                   when      recno4 >= 2
     C                   exsr      zzwdw4
416cA*
416cA*    Only one item loaded. Position to that p/o/item in main sfl.
416cAC                   when      recno4 = 1
416cAC                   eval      wopo4 = pdpo
416cAC                   eval      hseq = pdseq
416cAC                   eval      hitem = pditem
416cAC                   eval      hvitm = pdvitm
416cAC                   eval      $kpo = pdpo
416cAC                   eval      svp2po = pdpo
416cAC                   eval      svp2vl = ptinp1
416cAC                   eval      repos = *on
416cA*
416cA*    No items loaded. Send error message.
416cAC                   when      recno4 <= 0
416caC                   eval      erp2tp = 'mfg#'
416cAC                   eval      erspo = $kspo
416cAC                   eval      erp2vl = w1mfr
416cAC                   exsr      zm3236
416cA*
416cAC                   endsl
416dA*
416dAC                   endsl
     *
     ********************************************************************
     *
     *    User chose to see sub-total by p/o.
417k *    Super PO.
     C                   when      ovrtyp = '*SUBTOTL'  and
417kAC                             $spo = '*YES'
     *
     *    Condition heading in window.
     C                   eval      *in41 = *off
     C                   eval      w4titl = titl02
     C                   write     window4
     *    Clear subfile.
     C                   eval      *in01 = *off
     C                   write     dspsfc4
     C                   eval      *in01 = *on
     C                   eval      slctxt = 'SPO :'
     C                   eval      slcval = $kspo
     C                   eval      svpo = *blanks
     C                   eval      tqyor1 = *zeros
     C                   eval      tqyrc1 = *zeros
     C                   eval      first = *off
     *    Protect option field - Display only.
     C                   eval      *in90 = *on
     *
     *    Fill subfile.
     C     prtky2        setll     pujrec
     C                   dow       forevr = forevr
     C     prtky2        reade     pujrec                                 79
     C                   select
     C                   when      *in79
     *
     *    End of p/o detail, convert totals.
     C                   move      *loval        svpo
     C                   exsr      zzfil4
     C                   exsr      sflad4
     C                   leave
     *
     C                   other
     *
     C                   if        first = *off
     C                   eval      first = *on
     C                   eval      svpo = pdpo
     C                   endif
     *
     C                   exsr      zzfil4
     *
     C                   select
     C                   when      svpo <> pdpo
     *    Write total record for P/O to subfile.
     C                   exsr      sflad4
     C                   eval      svpo = pdpo
     *    Clear total fields.
     C                   eval      tqyor1 = *zeros
     C                   eval      tqyrc1 = *zeros
     *    Add current record values to total.
     C                   exsr      zzfil4
     C                   endsl
     C                   endsl
     C                   enddo
     *
     *    Now that subfile is built, Display it to the user.
     C                   exsr      zzwdw2
     C                   eval      *in90 = *off
417k ********************************************************************
417k *
417k *    User chose to see item subtotal p/o, qty recvd <> ordered.
417k *    Normal PO.
417k C                   when      ovrtyp = '*SUBITTL'  and
417kAC                             $spo = '*NO'
417k *
417k *    Condition heading in window.
417k C                   eval      *in41 = *off
417k C                   eval      w4titl = titl02
417k C                   write     window4
417k *    Clear subfile.
417k C                   eval      *in01 = *off
417k C                   write     dspsfc7
417k C                   eval      *in01 = *on
417k C                   eval      slctxt = 'PO  :'
417k C                   eval      slcval = $kpo
417k C                   eval      svpo = *blanks
417k C                   eval      tqyor1 = *zeros
417k C                   eval      tqyrc1 = *zeros
417k C                   eval      first = *off
417k *    Protect option field - Display only.
417k C                   eval      *in90 = *on
417k *
417k *    Fill subfile.
417k C     partky        setll     record
417k C                   dow       forevr = forevr
417k C     partky        reade     record                                 79
417k C                   select
417k C                   when      *in79
417k C                   eval      svpo = $kpo
417k C                   leave
417k *
417k C                   other
417k C                   if        pdqor1 = pdqrc1  and
417k C                             pdqor2 = pdqrc2  and
417k C                             pdqor3 = pdqrc3
417k C                   iter
417k C                   endif
417k *
417k C                   if        first = *off
417k C                   eval      first = *on
417k C                   eval      svpo = pdpo
417k C                   endif
417k *
417k *    For each line #, convert totals.
417k *    Clear total fields.
417k C                   eval      tqyor1 = *zeros
417k C                   eval      tqyrc1 = *zeros
417k *
417k *    Add current record values to total.
417k C                   exsr      zzfil7
417k *    Write total record for P/O to subfile.
417k C                   exsr      sflad7
417k C                   endsl
417k C                   enddo
417k *
417k *    Now that subfile is built, Display it to the user.
417kD***                  EXSR ZZWDW2
417k C                   exsr      zzwdw8
417k C                   eval      *in90 = *off
417l ********************************************************************
417l *
417l *    User chose to see item subtotal p/o, qty recvd <> ordered.
417l *    Super PO.
417l C                   when      ovrtyp = '*SUBITTL'  and
417lAC                             $spo = '*YES'
417l *
417l *    Condition heading in window.
417l C                   eval      *in41 = *off
417l C                   eval      w4titl = titl02
417l C                   write     window4
417l *    Clear subfile.
417l C                   eval      *in01 = *off
417l C                   write     dspsfc8
417l C                   eval      *in01 = *on
417l C                   eval      slctxt = 'SPO :'
417l C                   eval      slcval = $kspo
417l C                   eval      svpo = *blanks
417l C                   eval      svitem = *blanks
417l C                   eval      tqyor1 = *zeros
417l C                   eval      tqyrc1 = *zeros
417l C                   eval      first = *off
417l *    Protect option field - Display only.
417l C                   eval      *in90 = *on
417l *
417l *    Fill subfile.
417l C     prtky2        setll     pujrec
417l C                   dow       forevr = forevr
417l C     prtky2        reade     pujrec                                 79
417l C                   select
417l C                   when      *in79
417l *
417l *    End of p/o detail, convert totals.
417l C                   move      *loval        svpo
417l C                   leave
417l *
417l C                   other
417k C                   if        pdqor1 = pdqrc1  and
417k C                             pdqor2 = pdqrc2  and
417k C                             pdqor3 = pdqrc3
417k C                   iter
417k C                   endif
417l *
417l C                   if        first = *off
417l C                   eval      first = *on
417l C                   eval      svpo = pdpo
417l C                   eval      svitem = pditem
417l C                   endif
417l *
417k *    For each line #, convert totals.
417k *    Clear total fields.
417k C                   eval      tqyor1 = *zeros
417k C                   eval      tqyrc1 = *zeros
417l *
417k *    Add current record values to total.
417l C                   exsr      zzfil8
417l *****                EXSR ZZFIL4
417k *    Write total record for item to subfile.
417k C                   exsr      sflad8
417l C                   endsl
417l C                   enddo
417l *
417l *    Now that subfile is built, Display it to the user.
417l C                   exsr      zzwdw9
417l C                   eval      *in90 = *off
417a ********************************************************************
417a *
417a *    Multiple Items exist for UPC, select item.
417a C                   when      ovrtyp = '*UPCSLCT'
417aA*
417a *
417a C                   eval      w4titl = titl05
417a C                   write     window4
417a *    Clear subfile.
417a C                   eval      *in01 = *off
417a C                   write     dspsfc6
417a C                   eval      *in01 = *on
417a *    Load headings.
417a C                   eval      w6txt1 = hdr01
417a C                   eval      w6txt2 = 'Itm:'
417aA*    Process for one po
417aAC                   if        $spo = '*NO'
417aAC     upckey        setll     upc
417a C                   dow       forevr = forevr
417aAC     upckey        reade     upc                                    79
417aAC                   if        *in79
417aAC                   leave
417aAC                   endif
417a *
417a C                   eval      woitm# = upitem
700fAc                   eval      w6uom = upuom
417a C     podky1        setll     podtl1                             78
417a C                   dow       forevr = forevr
     C     podky1        reade     podtl1                                 78
     C                   if        *in78
417a *
417a C                   eval      w6po = *blanks
417a C                   eval      hseq = 0
417a C                   eval      pditem = woitm#
417a C                   eval      w6val1 = woitm#
417a C                   eval      w6val2 = *blanks
     C                   leave
     C                   else
417a *
417a C                   eval      w6po = pdpo
417a C                   eval      hseq = pdseq
417a C                   eval      w6val1 = pditem
417a C                   eval      w6val2 = pdvitm
     C                   leave
     C                   endif
     *
417a C                   enddo
417a C                   exsr      zzfil6
417a C                   exsr      sflad6
417AAC                   enddo
417a *
417a *    Now that subfile is built, Display it to the user.
417a C                   exsr      zzwdw6
417AAC                   endif
417a *
417aA*    Process for SUPER po
417aAC                   if        $spo = '*YES'
417aAC     upckey        setll     upc
417a C                   dow       forevr = forevr
417aAC     upckey        reade     upc                                    79
417aAC                   if        *in79
417aAC                   leave
417aAC                   endif
417a C                   eval      woitm# = upitem
417a C                   eval      prtupc = *off
417a *    Get regular PO#
417a C     prtky2        setll     pospo                              77
417a C                   dow       forevr = forevr
     C     prtky2        reade     pospo                                  77
     C                   if        *in77
417aAC                   leave
417aAC                   else
417a C                   eval      $kpo = pupo
417aAC                   endif
417a *
417a C     podky1        setll     podtl1                             78
417a C                   dow       forevr = forevr
     C     podky1        reade     podtl1                                 78
     C                   if        *in78
417a *
417a C                   eval      w6po = *blanks
417a C                   eval      hseq = 0
417a C                   eval      pditem = woitm#
417a C                   eval      w6val1 = woitm#
417a C                   eval      w6val2 = *blanks
     C                   leave
     C                   else
417a *
417a C                   eval      w6po = pdpo
417a C                   eval      hseq = pdseq
417a C                   eval      w6val1 = pditem
417a C                   eval      w6val2 = pdvitm
     C                   leave
     C                   endif
     *
417a C                   enddo
417a C                   if        not *in78
417a C                   exsr      zzfil6
640bAC                   if        wk6svitm <> w6val1
417a C                   exsr      sflad6
640bAC                   eval      wk6svitm = w6val1
640bAC                   endif
417a C                   eval      prtupc = *on
417AAC                   endif
417a C                   enddo
417a C                   if        prtupc = *off
417a C                   exsr      zzfil6
417a C                   exsr      sflad6
417a C                   eval      prtupc = *on
417AAC                   endif
417AAC                   enddo
417a *
417a *    Now that subfile is built, Display it to the user.
417a C                   exsr      zzwdw6
417AAC                   endif
520aA*
520aA********************************************************************
520aA*
520aA*    Display item message.
520aAC                   when      ovrtyp = '*ITEMMSG'
520aA*
520aAC                   eval      w4titl = titl06
520aAC                   write     window4
520aA*
520aAC                   eval      w10po = $ppo
520aAC     phkey         chain(n)  pohdr                              79
520aAC                   if        *in79
520aAC                   eval      phvnam = *blanks
520aAC                   endif
520aAC                   eval      w10vnm = phvnam
520aA*
520aAC                   eval      w10itm = $pitem
520aAC     itkey2        chain     piritem                            79
520aAC                   if        *in79
520aAC                   eval      itdesc = *blanks
520aAC                   eval      itpdsc = *blanks
520aAC                   endif
520aAC                   eval      w10dsc = *blanks
520aAC     itpdsc        cat       '/':0         w10dsc
520aAC     w10dsc        cat       itdesc:0      w10dsc
520aA*    Retrieve item message from file.
520aAC     pdmkey        chain     podtlm                             79
520aAC                   if        *in79  or
520aAC                             pdmpom = *blanks
520aAC                   eval      pdmpom = err02
520aAC                   endif
520aA*
520aAC                   eval      w10msg = pdmpom
520aA*
520aA*    Now that screen is built, Display it to the user.
520aAC                   exsr      zzwd10
520aA*
     *
     C                   endsl
     ********************************************************************
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZWDW2   Display Pop-Up window for selection of item/Mfr.
     *
     C     zzwdw2        begsr
     *
     C                   if        recno4 = *zeros
     C                   write     blank4
     C                   eval      *in56 = *on
     C                   else
     C                   eval      *in56 = *off
     C                   endif
     *
     C                   eval      *in57 = *on
     C                   dow       forevr = forevr
     *
     *   Overlay screen with error messages
     C                   exsr      zmdms4
     *
     C                   exfmt     dspsfc4
     *
     *   Initialize error subfile
     C                   exsr      zmcms4
     *
     C                   select
     *    F12=Cancel selected.
     C                   when      *inkl
     C                   eval      *inkl = *off
     C                   leave
     *
     *    F5=Refresh selected.
     C                   when      *inke
     C                   exsr      clrsch
     C     1             do        05            x
     C     x             chain     dspsfl4                            79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    dspsfl4
     C                   endif
     C                   enddo
     *
     C                   other
     *
     *    Process subfile.
     C                   exsr      zzwdw3
     *
     *    User selected record from list.
     C                   if        optslt = *on  and
     C                             error = *off
     C                   leave
     C                   endif
     *
     C                   endsl
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZWDW3   Process subfile looking for selection.
     *
     C     zzwdw3        begsr
     *
     *    Read ONLY the changed options.
     C                   eval      error = *off
     C                   eval      nrslct = *zeros
     C                   eval      optslt = *off
     C                   dow       forevr = forevr
     C                   readc     dspsfl4                                79
     C                   select
     C                   when      *in79
     C                   leave
     *
     C                   other
     *
     *    Display error if option is not valid.
     C                   if        option <> *blanks
     C                   eval      *in21 = *on
     C                   update    dspsfl4
     *
     C                   movea     option        a2
     C                   if        a2(2) = ' '
     C                   eval      a2(2) = a2(1)
     C                   eval      a2(1) = ' '
     C                   movea     a2            option
     C                   endif
     *
     *    Look up option in profile - Error if not found.
     C     option        lookup    zopt4                                  50
     C                   if        not *in50
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   exsr      z40108
     C                   endif
     *
     *    Count number of entries when Option=1
     C                   if        option = ' 1'
     C                   add       1             nrslct
     C                   eval      pdpo = wopo4
     C                   eval      $kpo = wopo4
     C                   eval      svp2po = wopo4
     C                   eval      svp2vl = slcval
     *    If number selected greater than 1, Then display message.
     C                   select
     C                   when      nrslct = 1
     C                   eval      optslt = *on
     C                   eval      repos = *on
     C                   when      nrslct >= 2
     C                   eval      error = *on
     C                   eval      errmsg = err01
     C                   exsr      z40105
     C                   eval      optslt = *off
     C                   eval      repos = *off
     C                   endsl
     C                   endif
     C                   endif
     *
     C                   endsl
     C                   enddo
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZWDW4   Display Pop-Up window for Position to item/Mfr.
     *
     C     zzwdw4        begsr
     *
     C                   if        recno4 = *zeros
     C                   write     blank5
     C                   eval      *in56 = *on
     C                   else
     C                   eval      *in56 = *off
     C                   endif
     *
     C                   eval      *in57 = *on
     C                   dow       forevr = forevr
     *
     *   Overlay screen with error messages
     C                   exsr      zmdms4
     *
     C                   exfmt     dspsfc5
     *
     *   Initialize error subfile
     C                   exsr      zmcms4
     *
     C                   select
     *    F12=Cancel selected.
     C                   when      *inkl
     C                   eval      *inkl = *off
     C                   leave
     *
     *    F5=Refresh selected.
     C                   when      *inke
     C                   exsr      clrsch
     C     1             do        05            x
     C     x             chain     dspsfl5                            79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    dspsfl5
     C                   endif
     C                   enddo
     *
     C                   other
     *
     *    Process subfile.
     C                   exsr      zzwdw5
     *
     *    User selected record from list.
     C                   if        optslt = *on  and
     C                             error = *off
     C                   leave
     C                   endif
     *
     C                   endsl
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZWDW5   Process subfile5 looking for selection.
     *
     C     zzwdw5        begsr
     *
     *    Read ONLY the changed options.
     C                   eval      error = *off
     C                   eval      nrslct = *zeros
     C                   eval      optslt = *off
     C                   dow       forevr = forevr
     C                   readc     dspsfl5                                79
     C                   select
     C                   when      *in79
     C                   leave
     *
     C                   other
     *
     *    Display error if option is not valid.
     C                   if        option <> *blanks
     C                   eval      *in21 = *on
     C                   update    dspsfl5
     *
     C                   movea     option        a2
     C                   if        a2(2) = ' '
     C                   eval      a2(2) = a2(1)
     C                   eval      a2(1) = ' '
     C                   movea     a2            option
     C                   endif
     *
     *    Look up option in profile - Error if not found.
     C     option        lookup    zopt4                                  50
     C                   if        not *in50
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   exsr      z40108
     C                   endif
     *
     *    Count number of entries when Option=1
     C                   if        option = ' 1'
     C                   add       1             nrslct
     C                   eval      pdpo = w5po
     C                   eval      $kpo = w5po
     C                   eval      svp2po = w5po
     C                   eval      pdseq = hseq
     C                   select
     C                   when      ovrtyp = '*POS2ITM'
     C                   eval      pditem = w5val1
     C                   eval      svp2vl = w5val1
     C                   eval      pdvitm = w5val2
     C                   when      ovrtyp = '*POS2MFR'
     C                   eval      pdvitm = w5val1
     C                   eval      pditem = w5val2
     C                   eval      svp2vl = w5val2
     C                   endsl
     *    If number selected greater than 1, Then display message.
     C                   select
     C                   when      nrslct = 1
     C                   eval      optslt = *on
     C                   eval      repos = *on
     C                   when      nrslct >= 2
     C                   eval      error = *on
     C                   eval      errmsg = err01
     C                   exsr      z40105
     C                   eval      optslt = *off
     C                   eval      repos = *off
     C                   endsl
     C                   endif
     C                   endif
     *
     C                   endsl
     C                   enddo
     *
     C                   endsr
417a *----------------------------------------------------------------
417a *
417a *  ZZWDW6   Display Pop-Up window for UPC multiple items.
417a *
417a C     zzwdw6        begsr
417a *
417a C                   if        recno4 = *zeros
417a C                   write     blank5
417a C                   eval      *in56 = *on
417a C                   else
417a C                   eval      *in56 = *off
417a C                   endif
417a *
417a C                   eval      *in57 = *on
417a C                   dow       forevr = forevr
417a ***        REFRSH    CABEQ*ON       JMP1
417a *
417a *   Overlay screen with error messages
417a C                   exsr      zmdms4
417a *
417a C                   exfmt     dspsfc6
417a *
417a *   Initialize error subfile
417a C                   exsr      zmcms4
417a *
417a C                   select
417a *    F12=Cancel selected.
417a C                   when      *inkl
417a C                   eval      *inkl = *off
417a C                   leave
417a *
417a *    F5=Refresh selected.
417a C                   when      *inke  or
417a C                             refrsh = *on
417a C                   eval      refrsh = *off
417a C                   exsr      clrsch
417a C     1             do        05            x
417a C     x             chain     dspsfl6                            79
417a C                   if        not *in79
417a C                   eval      option = '  '
417a C                   update    dspsfl6
417a C                   endif
417a C                   enddo
417a *
417a C                   other
417a *
417a *    Process subfile.
417f C                   exsr      zzwdwx
417a C                   exsr      zzwdw7
417a *
417a *    User selected record from list.
417a C                   if        optslt = *on  and
417a C                             error = *off
417a C                   leave
417a C                   endif
417a *
417f *    User did NOT select record from list.
417f C                   if        optslt = *off  and
417f C                             error = *off
417f C                   leave
417f C                   endif
417f *
417a C                   endsl
417a C                   if        refrsh = *on
417a C                   eval      refrsh = *off
417a C                   exsr      clrsch
417a C     1             do        05            x
417a C     x             chain     dspsfl6                            79
417a C                   if        not *in79
417a C                   eval      option = '  '
417a C                   update    dspsfl6
417a C                   endif
417a C                   enddo
417a C                   iter
417a C                   endif
417a C                   enddo
417a *
417a C                   endsr
     *----------------------------------------------------------------
417a *
417a *  ZZWDW7   Process subfile6 looking for selection 1.
417a *
417a C     zzwdw7        begsr
417a *
417a *    Read ONLY the changed options.
417a C                   eval      error = *off
417a C                   eval      nrslct = *zeros
417a C                   eval      optslt = *off
417a C                   dow       forevr = forevr
417a C                   readc     dspsfl6                                79
417a C                   select
417a C                   when      *in79
417a C                   leave
417a *
417a C                   other
417a *
417a *    Display error if option is not valid.
417a C                   if        option <> *blanks
417a C                   eval      *in21 = *on
417a C                   update    dspsfl6
417a *
417a C                   movea     option        a2
417a C                   if        a2(2) = ' '
417a C                   eval      a2(2) = a2(1)
417a C                   eval      a2(1) = ' '
417a C                   movea     a2            option
417a C                   endif
417a *
417a *    Look up option in profile - Error if not found.
417eD*R         OPTION    LOKUPZOPT4                    50
417eMC     option        lookup    zopt6                                  50
417a C                   if        not *in50
417a C                   eval      error = *on
417a C                   eval      errmsg = *blanks
417a C                   exsr      z40108
417a C                   endif
417a *
417a *    Count number of entries when Option=1
417a C                   if        option = ' 1'
417a C                   add       1             nrslct
417a C                   eval      pdpo = w6po
417g C                   if        w6po <> *blanks
417a C                   eval      $kpo = w6po
417g C                   endif
417a C                   eval      svp2po = w6po
417a C                   eval      upitem = w6val1
417a C                   eval      pditem = w6val1
417a C                   eval      pdseq = hseq
417a C                   eval      pdvitm = w6val2
417a *    If number selected greater than 1, Then display message.
417a C                   select
417a C                   when      nrslct = 1
417h C                   eval      noupc = *off
417a C                   eval      optslt = *on
417a C                   eval      repos = *on
417a C                   when      nrslct >= 2
417a C                   eval      error = *on
417a C                   eval      errmsg = err01
417a C                   exsr      z40105
417a C                   eval      optslt = *off
417a C                   eval      repos = *off
417a C                   endsl
417a C                   endif
417a *
417a *
417a C                   endif
417a *
417a C                   endsl
417a C                   enddo
417a *
417a C                   endsr
417k *----------------------------------------------------------------
417k *
417k *  ZZWDW8   Display Pop-Up window for PO item subtotal
417k *
417k C     zzwdw8        begsr
417k *
417k C                   if        recno4 = *zeros
417k C                   write     blank4
417k C                   eval      *in56 = *on
417k C                   else
417k C                   eval      *in56 = *off
417k C                   endif
417k *
417k C                   eval      *in57 = *on
417k C                   dow       forevr = forevr
417k *
417k *   Overlay screen with error messages
417k C                   exsr      zmdms4
417k *
417k C                   exfmt     dspsfc7
417k *
417k *   Initialize error subfile
417k C                   exsr      zmcms4
417k *
417k C                   select
417k *    F12=Cancel selected.
417k C                   when      *inkl
417k C                   eval      *inkl = *off
417k C                   leave
417k *
417k *    F5=Refresh selected.
417k C                   when      *inke
417k C                   exsr      clrsch
417k C     1             do        05            x
417k C     x             chain     dspsfl7                            79
417k C                   if        not *in79
417k C                   eval      option = '  '
417k C                   update    dspsfl7
417k C                   endif
417k C                   enddo
417k *
417k C                   other
     *
     *    Process subfile.
417kd****                 EXSR ZZWDW3
417kd*
417kd*    User selected record from list.
417kd****       OPTSLT    IFEQ *ON
417kd****       ERROR     ANDEQ*OFF
417kd****                 LEAVE
417kd****                 ENDIF
417k *
417k C                   endsl
417k C                   enddo
417k *
417k C                   endsr
417l *----------------------------------------------------------------
417l *
417l *  ZZWDW9   Display Pop-Up window for Super PO item subtotal
417l *
417l C     zzwdw9        begsr
417l *
417l C                   if        recno4 = *zeros
417l C                   write     blank4
417l C                   eval      *in56 = *on
417l C                   else
417l C                   eval      *in56 = *off
417l C                   endif
417l *
417l C                   eval      *in57 = *on
417l C                   dow       forevr = forevr
417l *
417l *   Overlay screen with error messages
417l C                   exsr      zmdms4
417l *
417l C                   exfmt     dspsfc8
417l *
417l *   Initialize error subfile
417l C                   exsr      zmcms4
417l *
417l C                   select
417l *    F12=Cancel selected.
417l C                   when      *inkl
417l C                   eval      *inkl = *off
417l C                   leave
417l *
417l *    F5=Refresh selected.
417l C                   when      *inke
417l C                   exsr      clrsch
417l C     1             do        05            x
417l C     x             chain     dspsfl8                            79
417l C                   if        not *in79
417l C                   eval      option = '  '
417l C                   update    dspsfl8
417l C                   endif
417l C                   enddo
417l *
417l C                   other
     *
     *    Process subfile.
417ld****                 EXSR ZZWDW3
417ld*
417ld*    User selected record from list.
417ld****       OPTSLT    IFEQ *ON
417ld****       ERROR     ANDEQ*OFF
417ld****                 LEAVE
417ld****                 ENDIF
417l *
417l C                   endsl
417l C                   enddo
417l *
417l C                   endsr
520aA*
520aA*----------------------------------------------------------------
520aA*
520aA*  ZZWD10   Display Pop-Up window for Item Message
520aA*
520aAC     zzwd10        begsr
520aA*
520aAC                   eval      *in57 = *on
520aAC                   dow       forevr = forevr
520aA*
520aA*   Overlay screen with error messages
520aAC                   exsr      zmdms4
520aA*
520aAC                   exfmt     wdwsc10
520aA*
520aA*   Initialize error subfile
520aAC                   exsr      zmcms4
520aA*
520aAC                   select
520aA*    F3=Exit selected.
520aAC                   when      *inkc
520aAC                   eval      *inkc = *off
520aAC                   leave
520aA*
520aA*    F12=Cancel selected.
520aAC                   when      *inkl
520aAC                   eval      *inkl = *off
520aAC                   leave
520aA*
520aA*    F5=Refresh selected.
520aAC                   when      *inke
520aA*
520aAC                   other
520aA*
520aAC                   endsl
520aAC                   enddo
520aA*
520aAC                   endsr
520aA*
417f *----------------------------------------------------------------
417f *
417f *  ZZWDWX   Process subfile6 looking for selection X
417f *
417f C     zzwdwx        begsr
417h C                   eval      noupc = *on
417f *
417f *    Read ONLY the changed options.
417f C                   eval      error = *off
417f C                   eval      nrslct = *zeros
417f C                   eval      optslt = *off
417f C                   dow       forevr = forevr
417f C                   readc     dspsfl6                                79
417f C                   select
417f C                   when      *in79
417f C                   leave
417f *
417f C                   other
417f *
417f *    Display error if option is not valid.
417f C                   if        option <> *blanks
417f C                   eval      *in21 = *on
417f C                   update    dspsfl6
417f *
417f C                   movea     option        a2
417f C                   if        a2(2) = ' '
417f C                   eval      a2(2) = a2(1)
417f C                   eval      a2(1) = ' '
417f C                   movea     a2            option
417f C                   endif
417f *
417f *    Look up option in profile - Error if not found.
417eD*R         OPTION    LOKUPZOPT4                    50
417fMC     option        lookup    zopt6                                  50
417f C                   if        not *in50
417f C                   eval      error = *on
417f C                   eval      errmsg = *blanks
417f C                   exsr      z40108
417f C                   endif
417f *
417f *    Process exceptions Option=X
417f C                   if        option = ' X'
417fAC                   eval      kyitem = w6val1
417faC                   eval      kytask = 'RCV'
417fAC                   eval      kyerid = 'RDUPUPC'
417fAC                   eval      kyesta = '1 '
417f C     ix2key        setll     itmexcp2
417f C                   dow       forevr = forevr
417f C     ix2key        reade     itmexcp2                               79
     *
417f C                   if        *in79
417f C                   eval      doex = *on
417f C                   leave
417f C                   else
417f C                   eval      doex = *off
417f C                   leave
417f C                   endif
     *
417f C                   enddo
     *
417f C                   if        doex = *on
417fAC                   eval      pditem = w6val1
417f C     itkey         chain     piritem                            79
417f C                   if        not *in79
417fAC                   eval      exwhdp = itwhdp
417fAC                   eval      exstyp = itstyp
417fAC                   else
417fAC                   eval      exwhdp = *blanks
417fAC                   eval      exstyp = *blanks
417fAC                   endif
417f **                   ADD  1         NRSLCT
417fAC                   eval      exwhse = $kwhse
417fAC                   eval      exitem = w6val1
417fAC                   eval      exfdis = *blanks
417fAC                   eval      extdis = *blanks
417fAC                   eval      exgdte = today
417fAC                   time                    exgtim
417fMC                   eval      exqty = 0
417faC                   eval      extask = 'RCV'
417fAC                   eval      exgby = #user
417fAC                   eval      exerid = 'RDUPUPC'
417fAC                   eval      exesta = '1 '
417fAC                   eval      dsupc = w1upc
417fAC                   eval      exfdis = dsfdis
417fAC                   eval      extdis = dstdis
417fAC                   write     exrec
417f C                   endif
417g **                   MOVE *ON       REFRSH
417g **                   MOVE *OFF      *IN21
417g **                   LEAVE
417f C                   endif
417f *
417f C                   endif
417f *
417f C                   endsl
417f C                   enddo
417f *
417f C                   endsr
417f *----------------------------------------------------------------
     *
     *  ZZXOPT   Get use extended description option
     *
     C     zzxopt        begsr
     *
     *   Get extended description option.
     C                   eval      prcrec = 10
     C                   eval      uxflag = *off
     C                   eval      ocode = '*ITEMMNT'
     *
     C     opkey         chain     options                            79
     C                   if        not *in79
     C                   if        opxdsc = 'Y'
     C                   eval      uxflag = *on
     C                   eval      prcrec = 5
     C                   endif
     C                   endif
     *
     *   If processing a Super P/O, Force display to be displayed
     *   in 2-line mode.
     C                   if        $spo = '*YES'  and
     C                             uxflag = '0'
     C                   eval      uxflag = *on
     C                   eval      prcrec = 5
     C                   endif
     *
     C                   endsr
     *
640eA*----------------------------------------------------------------
640eA*  clr$item  Clear $item data structure fields
640eA*----------------------------------------------------------------

640eAC     clr$item      begsr
640eAC                   eval      savever# = $itver#
640eAC                   clear                   $item
640eAC                   clear                   $item2
640eAC                   eval      $itver# = savever#
640eAC                   endsr

640eA*----------------------------------------------------------------
640eA*  zzzdricop  Call DRICOP
640eA*----------------------------------------------------------------

640eAC     zzzdricop     begsr
640eAC                   eval      error = *off

640eAC                   select
640eAC                   when      $dricommand = '*ITEM'
640eAC                   eval      $dridata = $item
640eAC                   eval      $dridata2 = $item2
640eAC                   endsl

640eAC                   if        $dricommand = '*ITEM'
640eAC                   call(e)   'DRICOP'
640eAC                   parm                    $dricommand
640eAC                   parm                    $drisubcmd
640eAC                   parm                    $drisys2upd
640eAC                   parm      #pgm          $driprogram
640eAC                   parm      ' '           $drireturn
640eAC                   parm      ' '           $drimessage
640eAC                   parm                    $dridata
640eAC                   parm                    $dridata2
640eAC                   else
640eAC                   call(e)   'DRICOP'
640eAC                   parm                    $dricommand
640eAC                   parm                    $drisubcmd
640eAC                   parm                    $drisys2upd
640eAC                   parm      #pgm          $driprogram
640eAC                   parm      ' '           $drireturn
640eAC                   parm      ' '           $drimessage
640eAC                   parm                    $dridata
640eAC                   endif

640eAC                   select

640eAC                   when      chk4err and %error
640eAC                   eval      error = *on

640eAC                   when      chk4err and $drireturn <> '*OK'
640eAC                   eval      error = *on

640eAC                   endsl

640eAC                   select
640eAC                   when      $dricommand = '*ITEM'
640eAC                   eval      $item = $dridata
640eAC                   eval      $item2 = $dridata2
640eAC                   endsl

640eAC                   eval      zmflag = *off
640eAC                   eval      zmsflag = *off
640eAC                   eval      chk4err = *off
640eAC     enddricop     endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options
 1 2 4 5 7 8 9111213141899 XRCRWREEW
**  ZOPTP - Valid options for Packers
 1 2 4 5 7 8 9101112131499 X
**  ZOPTJ - Valid options for Jack Palmer
 1     5 7 8 91112131499 X
**  ZOPT4 - Valid options for WINDOW4
 1
**  ZOPT6 - Valid options for DSPSFL6
 1 X
**  OPTLN - Option display line
  1=Receive  2=Change  4=Delete  5=View  7=Item msg  8=Work w/tie/high
  9=Transactions  11=HACCP info  12=Work w/slots 13=View receiving  X=Check
  14=Rcv exceptions  18=Print produce lbl 99=View directed put away
  EW=Enter Wgt  RC=Recall Listing  RE=View PCM Exceptions
**  OPTLNP - Option display line - Packers
  1=Receive  2=Change  4=Delete  5=View  8=Work w/tie/high  9=Transactions
  10=UCI Weights  11=HACCP info  12=Work w/slots 13=View receiving  X=Check
  7=Item msg  14=Rcv exceptions  99=View putaway tracking

**  OPTLNJ - Option display line for Jack Palmer
  1=Receive                      5=View  8=Work w/tie/high
  9=Transactions  11=HACCP info  12=Work w/slots 13=View receiving  X=Check
  14=Rcv exceptions  99=View directed putaway tracking

**  OPTLNY - Option display line - YHata
  1=Receive 2=Change 4=Delete 5=View 8=Wrk w/ti/hi 7=Itemmsg 9=Transactions
  11=HACCP info  12=Work w/slots 13=View receiving 14=Rcv exception X=Check
  99=View directed putaway tracking  RE=View PCM Exceptions

**  OPTLNS - Option line 1 for *SPRECV
  1=PickSlt Rcv  2=Change  4=Delete  5=View  7=Item msg  8=Work w/tie/high
**  CMDLN - Command display line
F3=Exit  F5=Ref  F6=Create  F9=PO/Mfr Code  F10=Dcrp F11=No-X  F24=More keys
F3=Exit  F5=Ref  F6=Create  F9=PO/Item  F10=Dcrp  F11=No-X     F24=More keys
F3=Exit  F5=Ref  F6=Create  F7=Subtl  F9=PO/Mfr Code  F11=No-X F24=More keys
F3=Exit  F5=Ref  F6=Create  F7=Subtl  F9=PO/Item  F11=No-X     F24=More keys
F12=Cancel  F13=ASN Receive  F14=UCI Receive  23=More options  F24=More keys
F3=Exit  F5=Refresh  F6=Create  F9=PO/Mfr Code  F11=All   F24=More keys
F3=Exit  F5=Refresh  F6=Create  F9=PO/Item  F11=All       F24=More keys
F3=Exit  F5=Ref  F6=Create  F7=Subtl  F9=PO/Mfr Code  F11=All  F24=More keys
F3=Exit  F5=Ref  F6=Create  F7=Subtl  F9=PO/Item  F11=All   F24=More keys
**   OVRDBF statements
OVRDBF FILE(PO120A) TOFILE(POSPO) SHARE(*YES) LVLCHK(*NO)
OVRDBF FILE(PO120B) TOFILE(POSPO) SHARE(*YES) LVLCHK(*NO)
OVRDBF FILE(PO120C) TOFILE(POSPO2) SHARE(*YES) LVLCHK(*NO)
OVRDBF FILE(PO120D) TOFILE(POSPO2) SHARE(*YES) LVLCHK(*NO)
**   OPNQRYF statements for PO120A - whse/spo/po/item seq.
OPNQRYF FILE((POSPO) (PODTL)) FORMAT(PO120A) QRYSLT('
PUWHSE = 999 *AND PUSPO = "123456789"')
KEYFLD((1/PUWHSE) (1/PUSPO) (1/PUPO) (2/PDITEM))
JFLD((1/PUWHSE 2/PDWHSE *EQ) (1/PUPO 2/PDPO *EQ))
OPTIMIZE(*FIRSTIO) JDFTVAL(*NO) SEQONLY(*NO)
**   OPNQRYF statements for PO120B - whse/spo/po/vitm seq.
OPNQRYF FILE((POSPO) (PODTL)) FORMAT(PO120B) QRYSLT('
PUWHSE = 999 *AND PUSPO = "123456789"')
KEYFLD((1/PUWHSE) (1/PUSPO) (1/PUPO) (2/PDVITM))
JFLD((1/PUWHSE 2/PDWHSE *EQ) (1/PUPO 2/PDPO))
OPTIMIZE(*FIRSTIO) JDFTVAL(*NO) SEQONLY(*NO)
**   OPNQRYF statements for PO120C - whse/spo/item/po seq.
OPNQRYF FILE((POSPO2) (PODTL)) FORMAT(PO120C) QRYSLT('
PUWHSE = 999 *AND PUSPO = "123456789" *AND PDITEM = "123456789012345"')
KEYFLD((1/PUWHSE) (1/PUSPO) (2/PDITEM) (1/PUPO))
JFLD((1/PUWHSE 2/PDWHSE *EQ) (1/PUPO 2/PDPO))
OPTIMIZE(*FIRSTIO) JDFTVAL(*NO)
PUWHSE = 999 *AND PUSPO = "123456789" *AND PDITEM >="123456789012345"')
**   OPNQRYF statements for PO120D - whse/spo/vitm/po seq.
OPNQRYF FILE((POSPO2) (PODTL)) FORMAT(PO120D) QRYSLT('
PUWHSE = 999 *AND PUSPO = "123456789" *AND PDVITM  ="123456789012345"')
KEYFLD((1/PUWHSE) (1/PUSPO) (2/PDVITM) (1/PUPO))
JFLD((1/PUWHSE 2/PDWHSE *EQ) (1/PUPO 2/PDPO))
OPTIMIZE(*FIRSTIO) JDFTVAL(*NO)
PUWHSE = 999 *AND PUSPO = "123456789" *AND PDVITM >="123456789012345"')
**   CLOF statement.
CLOF POSPO
CLOF POSPO2
